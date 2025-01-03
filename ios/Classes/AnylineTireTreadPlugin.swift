import Flutter
import UIKit
import AnylineTireTreadSdk

public class AnylineTireTreadPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "anyline_tire_tread_plugin",
                                           binaryMessenger: registrar.messenger())
        let instance = AnylineTireTreadPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // set up Tire Tread Plugin events channel
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
                let eventChannel = FlutterEventChannel(name: "anyline_tire_tread_plugin/events",
                                                       binaryMessenger: rootViewController.binaryMessenger)
                eventChannel.setStreamHandler(TTEventHandler.shared)
            }
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
        switch call.method {
        case Constants.METHOD_GET_SDK_VERSION:
            result(AnylineTireTreadSdk.shared.sdkVersion)
        case Constants.METHOD_INITIALIZE:
            initializeSdk(result: result, call: call)
        case Constants.METHOD_SCAN:
            scan(result: result, call: call)
        case Constants.METHOD_GET_RESULT:
            Task{
                await getResultJSON(result: result, call: call)
            }
        case Constants.METHOD_GET_HEATMAP:
            Task{
                await getHeatMap(result: result, call: call)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeSdk(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        let licenseKey = arguments?[Constants.EXTRA_LICENSE_KEY] as? String
        if (licenseKey != nil) {
            do {
                try AnylineTireTreadSdk.shared.doInit(licenseKey: licenseKey ?? "")
                result(true)
            } catch let error as SdkInitializeFailedException {
                PluginError.sdkInitializationFailedError.throwToResult(result: result, details: error.message)
            } catch {
                PluginError.genericExceptionError(error.localizedDescription).throwToResult(result: result,
                                                                                            details: error.localizedDescription)
            }
        }
    }
    
    private func scan(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let config = TireTreadScanViewConfig() // using default config
        let viewController = TireScannerViewController(config: config)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    private func getResultJSON(result: @escaping FlutterResult, call: FlutterMethodCall) async {
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            PluginError.genericExceptionError("uuid parameter not found").throwToResult(result: result)
            return
        }
        
        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.getTreadDepthReportResult(measurementUuid: uuid, timeoutSeconds: 30) { response in
                switch(response) {
                case let response as ResponseSuccess<TreadDepthResult>:
                    continuation.resume(returning:  result(response.data.toJson()))
                case let response as ResponseError<TreadDepthResult>:
                    let message = response.errorMessage ?? "Unknown error"
                    continuation.resume(returning:  PluginError.genericExceptionError(message).throwToResult(result: result))
                case let responseException as ResponseException<TreadDepthResult>:
                    let exceptionMessage = "Unable to get tread depth result: " + (responseException.exception.message ?? "Unknown exception")
                    continuation.resume(returning:  PluginError.genericExceptionError(exceptionMessage).throwToResult(result: result))
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func getHeatMap(result: @escaping FlutterResult, call: FlutterMethodCall) async{
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            PluginError.genericExceptionError("uuid parameter not found").throwToResult(result: result)
            return
        }
        
        
        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.getHeatmap(measurementUuid: uuid, timeoutSeconds: 30) { response in
                switch(response) {
                case let response as ResponseSuccess<Heatmap>:
                    continuation.resume(returning:  result(response.data.url))
                case let response as ResponseError<Heatmap>:
                    let message = response.errorMessage ?? "Unknown error"
                    continuation.resume(returning:  PluginError.genericExceptionError(message).throwToResult(result: result))
                case let responseException as ResponseException<Heatmap>:
                    let exceptionMessage = "Unable to get heatmap result: " + (responseException.exception.message ?? "Unknown exception")
                    continuation.resume(returning:  PluginError.genericExceptionError(exceptionMessage).throwToResult(result: result))
                    break
                default:
                    break
                }
            }
        }
    }
}


public class TTEventHandler: NSObject, FlutterStreamHandler {
    
    public static let shared = TTEventHandler()
    
    private var eventSink: FlutterEventSink?
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        
        self.eventSink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    public func sendEvent(type: String, uuid: String? = nil) {
        let eventStr = TTEventHandler.eventString(type: type, uuid: uuid)
        self.eventSink?(eventStr)
    }
    
    static func eventString(type: String, uuid: String? = nil) -> String {
        // measurementUUID is required, event if the event doesn't come with it.
        return "{\"measurementResultStatus\":{\"type\":\"io.anyline.tiretread.scanningevent.\(type)\"},\"measurementUUID\":\"\(uuid ?? "")\"}"
    }
}
