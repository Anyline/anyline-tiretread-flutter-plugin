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
        let eventChannel = FlutterEventChannel(name: "anyline_tire_tread_plugin/events",
                                               binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(TTEventHandler.shared)
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
            guard let licenseKey = arguments?[Constants.EXTRA_LICENSE_KEY] as? String else {
                result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_LICENSE_KEY_NOT_FOUND, details: nil))
                return
            }
            let pluginVersion = arguments?[Constants.EXTRA_PLUGIN_VERSION] as? String ?? ""

            do {
                try AnylineTireTreadSdk.shared.doInit(
                    licenseKey: licenseKey,
                    customTag: nil,
                    wrapperInfo: WrapperInfo.Flutter(version: pluginVersion)
                )
                result(true)
            } catch {
                let kotlinException = (error as NSError).userInfo["KotlinException"]
                let (details, code, message): (String, String, String)
                switch kotlinException {
                case let ex as SdkLicenseKeyForbiddenException:
                    details = ex.message ?? Constants.ERROR_MESSAGE_LICENSE_KEY_FORBIDDEN
                    code = Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED
                    message = Constants.ERROR_MESSAGE_SDK_INITIALIZATION_FAILED
                case let ex as SdkLicenseKeyInvalidException:
                    details = ex.message ?? Constants.ERROR_MESSAGE_INVALID_LICENSE_KEY
                    code = Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED
                    message = Constants.ERROR_MESSAGE_SDK_INITIALIZATION_FAILED
                case let ex as NoConnectionException:
                    details = ex.message ?? Constants.ERROR_MESSAGE_NO_CONNECTION
                    code = Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED
                    message = Constants.ERROR_MESSAGE_SDK_INITIALIZATION_FAILED
                default:
                    details = error.localizedDescription
                    code = Constants.ERROR_CODE_GENERIC_EXCEPTION
                    message = error.localizedDescription
                }
                result(FlutterError(code: code, message: message, details: details))
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
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_UUID_NOT_FOUND, details: nil))
            return
        }
        
        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.getTreadDepthReportResult(measurementUuid: uuid, timeoutSeconds: 30) { response in
                switch(response) {
                case let response as ResponseSuccess<TreadDepthResult>:
                    continuation.resume(returning:  result(response.data.toJson()))
                case let response as ResponseError<TreadDepthResult>:
                    let message = response.errorMessage ?? Constants.ERROR_MESSAGE_UNKNOWN_ERROR
                    continuation.resume(returning:  result(FlutterError(code: response.errorCode ?? "UNKNOWN_ERROR", message: message, details: nil)))
                case let responseException as ResponseException<TreadDepthResult>:
                    let exceptionMessage = Constants.ERROR_MESSAGE_UNABLE_TO_GET_TREAD_DEPTH_RESULT + (responseException.exception.message ?? Constants.ERROR_MESSAGE_UNKNOWN_EXCEPTION)
                    continuation.resume(returning:  result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: exceptionMessage, details: nil)))
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
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_UUID_NOT_FOUND, details: nil))
            return
        }

        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.getHeatmap(measurementUuid: uuid, timeoutSeconds: 30) { response in
                switch(response) {
                case let response as ResponseSuccess<Heatmap>:
                    continuation.resume(returning:  result(response.data.url))
                case let response as ResponseError<Heatmap>:
                    let message = response.errorMessage ?? Constants.ERROR_MESSAGE_UNKNOWN_ERROR
                    continuation.resume(returning:  result(FlutterError(code: response.errorCode ?? "UNKNOWN_ERROR", message: message, details: nil)))
                case let responseException as ResponseException<Heatmap>:
                    let exceptionMessage = Constants.ERROR_MESSAGE_UNABLE_TO_GET_HEATMAP_RESULT + (responseException.exception.message ?? Constants.ERROR_MESSAGE_UNKNOWN_EXCEPTION)
                    continuation.resume(returning:  result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: exceptionMessage, details: nil)))
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
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_UUID_NOT_FOUND, details: nil))
            return
        }
        guard let comment = arguments?[Constants.EXTRA_FEEDBACK_COMMENT] as? String else {
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_COMMENT_NOT_FOUND, details: nil))
            return
        }


        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.sendCommentFeedback(uuid: uuid, comment: comment) { response in
                switch(response) {
                case let response as ResponseSuccess<MeasurementInfo>:
                    continuation.resume(returning:  result(response.data.measurementUuid))
                case let response as ResponseError<MeasurementInfo>:
                    let message = response.errorMessage ?? Constants.ERROR_MESSAGE_UNKNOWN_ERROR
                    continuation.resume(returning:  result(FlutterError(code: response.errorCode ?? "UNKNOWN_ERROR", message: message, details: nil)))
                case let responseException as ResponseException<MeasurementInfo>:
                    let exceptionMessage = Constants.ERROR_MESSAGE_UNABLE_TO_GET_TREAD_DEPTH_RESULT + (responseException.exception.message ?? Constants.ERROR_MESSAGE_UNKNOWN_EXCEPTION)
                    continuation.resume(returning:  result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: exceptionMessage, details: nil)))
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
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_UUID_NOT_FOUND, details: nil))
            return
        }
        guard let regionsAsString = arguments?[Constants.EXTRA_TREAD_DEPTH_RESULT_FEEDBACK] as? String else {
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_COMMENT_NOT_FOUND, details: nil))
            return
        }

        guard let data = regionsAsString.data(using: .utf8) else {
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_ENCODING_REGIONS_STRING, details: nil))
            return
        }
        var regions: [TreadResultRegion] = []
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for name in jsonArray {
                    let jsonData = try JSONSerialization.data(withJSONObject: name)
                    guard let deit = String(data: jsonData, encoding: .utf8) else {
                        result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_ENCODING_JSON_DATA, details: nil))
                        return
                    }
                    regions.append(TreadResultRegion.companion.fromJson(json: deit))
                }
            }
        } catch {
            result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: Constants.ERROR_MESSAGE_DESERIALIZING_JSON + "\(error)", details: nil))
            return
        }

        await withCheckedContinuation {
            continuation in
            AnylineTireTreadSdk.shared.sendTreadDepthResultFeedback(resultUuid: uuid, treadResultRegions:regions) { response in
                switch(response) {
                case let response as ResponseSuccess<MeasurementInfo>:
                    continuation.resume(returning:  result(response.data.measurementUuid))
                case let response as ResponseError<MeasurementInfo>:
                    let message = response.errorMessage ?? Constants.ERROR_MESSAGE_UNKNOWN_ERROR
                    continuation.resume(returning:  result(FlutterError(code: response.errorCode ?? "UNKNOWN_ERROR", message: message, details: nil)))
                case let responseException as ResponseException<MeasurementInfo>:
                    let exceptionMessage = Constants.ERROR_MESSAGE_UNABLE_TO_GET_TREAD_DEPTH_RESULT + (responseException.exception.message ?? Constants.ERROR_MESSAGE_UNKNOWN_EXCEPTION)
                    continuation.resume(returning:  result(FlutterError(code: Constants.ERROR_CODE_GENERIC_EXCEPTION, message: exceptionMessage, details: nil)))
                    break
                default:
                    break
                }
            }
        }

    }
}
