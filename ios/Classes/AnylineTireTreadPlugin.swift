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
        case Constants.METHOD_SEND_FEEDBACK_COMMENT:
            Task{
                await postFeedbackComment(result: result, call: call)
            }
        case Constants.METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK:
            Task{
                await sendTreadDepthResultFeedback(result: result, call: call)
            }
        case Constants.METHOD_SET_EXPERIMENTAL_FLAGS:
            result(true)
        case Constants.METHOD_CLEAR_EXPERIMENTAL_FLAGS:
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeSdk(result: @escaping FlutterResult, call: FlutterMethodCall) {
            let arguments = call.arguments as? [String: Any]
            let licenseKey = arguments?[Constants.EXTRA_LICENSE_KEY] as? String
            let pluginVersion = arguments?[Constants.EXTRA_PLUGIN_VERSION] as? String

            if (licenseKey != nil) {
                do {
                    try AnylineTireTreadSdk.shared.doInit(
                        licenseKey: licenseKey ?? "",
                        customTag: nil,
                        wrapperInfo: WrapperInfo.Flutter(version: pluginVersion ?? "")
                    )

                    result(true)
                } catch {
                    let kotlinException = (error as NSError).userInfo["KotlinException"]
                    // handle pre-identified types of errors
                    if let sdkInitException = kotlinException as? SdkLicenseKeyForbiddenException {
                        PluginError.sdkInitializationFailedError.throwToResult(result: result, details: sdkInitException.message)
                    }else if let sdkInitException = kotlinException as? SdkLicenseKeyInvalidException {
                        PluginError.sdkInitializationFailedError.throwToResult(result: result, details: sdkInitException.message)
                    }else if let sdkInitException = kotlinException as? NoConnectionException {
                        PluginError.sdkInitializationFailedError.throwToResult(result: result, details: sdkInitException.message)
                    }
                    else {
                        // the catch-all generic exception
                        PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION, error.localizedDescription).throwToResult(result: result, details: error.localizedDescription)
                    }
                }
            }
        }
    
    
    private func scan(result: @escaping FlutterResult, call: FlutterMethodCall) {
        
        var viewController = TireScannerViewController(config: TireTreadConfig())

        if let args = call.arguments as? [String: Any] {
            // Convert TireTreadConfig dictionary to JSON string
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: args, options: [])
                if let tireTreadConfigJson = String(data: jsonData, encoding: .utf8) {
                    viewController = TireScannerViewController(tireTreadConfigJson: tireTreadConfigJson)
                }
            } catch {
                print("Failed to serialize TireTreadConfig to JSON: \(error)")
                // Fallback to default config
                viewController = TireScannerViewController(config: TireTreadConfig())
            }
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            viewController.modalPresentationStyle = .fullScreen
            window.rootViewController?.present(viewController, animated: true, completion: nil)
        }
    }
    
    
    private func getResultJSON(result: @escaping FlutterResult, call: FlutterMethodCall) async {
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,"uuid parameter not found").throwToResult(result: result)
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
                    continuation.resume(returning:  PluginError.genericExceptionError(response.errorCode,message).throwToResult(result: result))
                case let responseException as ResponseException<TreadDepthResult>:
                    let exceptionMessage = "Unable to get tread depth result: " + (responseException.exception.message ?? "Unknown exception")
                    continuation.resume(returning:  PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,exceptionMessage).throwToResult(result: result))
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
            PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,"uuid parameter not found").throwToResult(result: result)
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
                    continuation.resume(returning:  PluginError.genericExceptionError(response.errorCode,message).throwToResult(result: result))
                case let responseException as ResponseException<Heatmap>:
                    let exceptionMessage = "Unable to get heatmap result: " + (responseException.exception.message ?? "Unknown exception")
                    continuation.resume(returning:  PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,exceptionMessage).throwToResult(result: result))
                    break
                default:
                    break
                }
            }
        }
    }
    
    /// Sends feedback comment for a specific measurement.
    /// - Parameters:
    ///   - result: The Flutter result callback.
    ///   - call: The Flutter method call containing arguments.
    private func postFeedbackComment(result: @escaping FlutterResult, call: FlutterMethodCall) async{
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,"uuid parameter not found").throwToResult(result: result)
            return
        }
        guard let comment = arguments?[Constants.EXTRA_FEEDBACK_COMMENT] as? String else {
            PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,"comment parameter not found").throwToResult(result: result)
            return
        }


        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.sendCommentFeedback(uuid: uuid, comment: comment) { response in
                switch(response) {
                case let response as ResponseSuccess<MeasurementInfo>:
                    continuation.resume(returning:  result(response.data.measurementUuid))
                case let response as ResponseError<MeasurementInfo>:
                    let message = response.errorMessage ?? "Unknown error"
                    continuation.resume(returning:  PluginError.genericExceptionError(response.errorCode,message).throwToResult(result: result))
                case let responseException as ResponseException<MeasurementInfo>:
                    let exceptionMessage = "Unable to get tread depth result: " + (responseException.exception.message ?? "Unknown exception")
                    continuation.resume(returning:  PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,exceptionMessage).throwToResult(result: result))
                    break
                default:
                    break
                }
            }
        }
    }

    /// Sends tread depth result feedback for a specific measurement.
    /// - Parameters:
    ///   - result: The Flutter result callback.
    ///   - call: The Flutter method call containing arguments.
    private func sendTreadDepthResultFeedback(result: @escaping FlutterResult, call: FlutterMethodCall) async{
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,"uuid parameter not found").throwToResult(result: result)
            return
        }
        guard let regionsAsString = arguments?[Constants.EXTRA_TREAD_DEPTH_RESULT_FEEDBACK] as? String else {
            PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,"comment parameter not found").throwToResult(result: result)
            return
        }

        let data = regionsAsString.data(using: .utf8)
        var regions: [TreadResultRegion] = []
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                for name in jsonArray {
                    let deit = String(data: try  JSONSerialization.data(withJSONObject: name), encoding: .utf8)!
                    regions.append(TreadResultRegion.companion.fromJson(json: deit))
                }
            }
        } catch {
            PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,"Error deserializing JSON: \(error)").throwToResult(result: result)
        }

        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.sendTreadDepthResultFeedback(resultUuid: uuid, treadResultRegions:regions) { response in
                switch(response) {
                case let response as ResponseSuccess<MeasurementInfo>:
                    continuation.resume(returning:  result(response.data.measurementUuid))
                case let response as ResponseError<MeasurementInfo>:
                    let message = response.errorMessage ?? "Unknown error"
                    continuation.resume(returning:  PluginError.genericExceptionError(response.errorCode,message).throwToResult(result: result))
                case let responseException as ResponseException<MeasurementInfo>:
                    let exceptionMessage = "Unable to get tread depth result: " + (responseException.exception.message ?? "Unknown exception")
                    continuation.resume(returning:  PluginError.genericExceptionError(Constants.ERROR_CODE_GENERIC_EXCEPTION,exceptionMessage).throwToResult(result: result))
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
    
    public func sendEvent(type: String, uuid: String? = nil, error: String? = nil) {
        let eventStr = TTEventHandler.eventString(type: type, uuid: uuid, error: error)
        self.eventSink?(eventStr)
    }
    
    static func eventString(type: String, uuid: String? = nil, error: String? = nil) -> String {
        // measurementUUID, error is required, event if the event doesn't come with it.
        return "{\"measurementResultStatus\":{\"type\":\"io.anyline.tiretread.scanningevent.\(type)\"},\"measurementUUID\":\"\(uuid ?? "")\",\"error\":\"\(error ?? "")\"}"
    }
}
