import Foundation
import Flutter

enum PluginError: Error {
    
    case pluginNotAttachedToActivityError
    case sdkInitializationFailedError
    case genericExceptionError(String?)
    
    func throwToResult(result: @escaping FlutterResult, details: Any? = nil) {
        switch self {
        case .pluginNotAttachedToActivityError:
            result(FlutterError(code: "pluginNotAttachedToActivityError",
                                message: "Plugin is not attached to main activity", details: details))
            
        case .sdkInitializationFailedError:
            result(FlutterError(code: "sdkInitializationFailedError",
                                message: "Tire Tread SDK could not be initialized", details: details))
            
        case .genericExceptionError(let exceptionMessage):
            result(FlutterError(code: "genericExceptionError",
                                message: exceptionMessage, details: exceptionMessage))
        }
    }
}
