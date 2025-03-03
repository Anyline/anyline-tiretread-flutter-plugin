import Foundation
import Flutter

enum PluginError: Error {
    
    case pluginNotAttachedToActivityError
    case sdkInitializationFailedError
    case genericExceptionError(String?,String?)
    
    func throwToResult(result: @escaping FlutterResult, details: Any? = nil) {
        switch self {
        case .pluginNotAttachedToActivityError:
            result(FlutterError(code: Constants.ERROR_CODE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY,
                                message: "Plugin is not attached to main activity", details: details))
            
        case .sdkInitializationFailedError:
            result(FlutterError(code: Constants.ERROR_CODE_SDK_INITIALIZATION_FAILED,
                                message: "Tire Tread SDK could not be initialized", details: details))
            
        case .genericExceptionError(let code,let exceptionMessage):
            result(FlutterError(code: code ?? "",
                                message: exceptionMessage, details: ["code": code ?? "","message": exceptionMessage ?? ""]))
        }
    }
}
