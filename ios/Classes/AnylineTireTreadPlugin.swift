import Flutter
import UIKit
import AnylineTireTreadSdk

public class AnylineTireTreadPlugin: NSObject, FlutterPlugin {

    private var pendingScanResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "anyline_tire_tread_plugin",
                                           binaryMessenger: registrar.messenger())
        let instance = AnylineTireTreadPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case Constants.METHOD_GET_SDK_VERSION:
            result(AnylineTireTread.shared.sdkVersion)
        case Constants.METHOD_INITIALIZE:
            initializeSdk(result: result, call: call)
        case Constants.METHOD_SCAN:
            scan(result: result, call: call)
        case Constants.METHOD_IS_DEVICE_SUPPORTED:
            isDeviceSupported(result: result)
        case Constants.METHOD_GET_RESULT:
            getResult(result: result, call: call)
        case Constants.METHOD_GET_HEATMAP:
            getHeatmap(result: result, call: call)
        case Constants.METHOD_SEND_FEEDBACK_COMMENT:
            sendCommentFeedback(result: result, call: call)
        case Constants.METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK:
            sendTreadDepthResultFeedback(result: result, call: call)
        case Constants.METHOD_SEND_TIRE_ID_FEEDBACK:
            sendTireIdFeedback(result: result, call: call)
        case Constants.METHOD_SET_EXPERIMENTAL_FLAGS:
            setExperimentalFlags(result: result, call: call)
        case Constants.METHOD_CLEAR_EXPERIMENTAL_FLAGS:
            clearExperimentalFlags(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - SDK Methods

    private func initializeSdk(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        guard let licenseKey = arguments?[Constants.EXTRA_LICENSE_KEY] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "License key parameter not found", details: nil))
            return
        }
        let pluginVersion = arguments?[Constants.EXTRA_PLUGIN_VERSION] as? String ?? ""
        let rawCustomTag = (arguments?[Constants.EXTRA_CUSTOM_TAG] as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let customTag = (rawCustomTag?.isEmpty ?? true) ? nil : rawCustomTag

        AnylineTireTread.shared.initialize(
            licenseKey: licenseKey,
            options: InitOptions(
                customTag: customTag,
                wrapperInfo: WrapperInfo.Flutter(version: pluginVersion)
            )
        ) { sdkResult in
            DispatchQueue.main.async {
                if sdkResult.isOk {
                    result(true)
                } else if let error = sdkResult.error {
                    result(FlutterError(
                        code: error.code.name,
                        message: error.message,
                        details: error.debug?.description
                    ))
                }
            }
        }
    }

    private func scan(result: @escaping FlutterResult, call: FlutterMethodCall) {
        if pendingScanResult != nil {
            result(failedOutcome(code: .alreadyRunning, message: "A scan is already in progress"))
            return
        }

        // Present from the topmost view controller (parity with the RN
        // wrapper's RCTPresentedViewController): presenting from the root VC
        // fails when another controller is already presented.
        guard let presenter = topViewController() else {
            result(failedOutcome(
                code: .invalidArgument,
                message: "Unable to present scan: no active view controller"))
            return
        }

        pendingScanResult = result

        let arguments = call.arguments as? [String: Any]
        let configJson = arguments?[Constants.EXTRA_CONFIG_JSON] as? String
        let optionsJson = arguments?[Constants.EXTRA_SCAN_OPTIONS_JSON] as? String

        AnylineTireTreadScanner().scan(
            from: presenter,
            configJson: configJson,
            optionsJson: optionsJson
        ) { [weak self] outcome in
            DispatchQueue.main.async {
                guard let pending = self?.pendingScanResult else { return }
                self?.pendingScanResult = nil
                pending(self?.sanitizedOutcome(outcome) ?? [:])
            }
        }
    }

    /// Returns the topmost presented view controller of the key window.
    private func topViewController() -> UIViewController? {
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
        let window = windows.first { $0.isKeyWindow } ?? windows.first
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    private func failedOutcome(code: ErrorCode, message: String) -> [String: Any] {
        let error = SdkError(
            code: code,
            type: ErrorType.companion.fromCode(code: code),
            message: message,
            debug: nil
        )
        return sanitizedOutcome(FailedOutcome(measurementUUID: nil, error: error))
    }

    private func isDeviceSupported(result: @escaping FlutterResult) {
        AnylineTireTread.shared.isDeviceSupported { sdkResult in
            DispatchQueue.main.async {
                if let supported = sdkResult.result as? Bool {
                    result(supported)
                } else if let error = sdkResult.error {
                    result(FlutterError(
                        code: error.code.name,
                        message: error.message,
                        details: error.debug?.description
                    ))
                }
            }
        }
    }

    private func getResult(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "uuid parameter not found", details: nil))
            return
        }
        let timeout = (arguments?[Constants.EXTRA_TIMEOUT_SECONDS] as? NSNumber)?.int32Value ?? 60

        AnylineTireTread.shared.getResult(
            measurementUUID: uuid,
            timeoutSeconds: timeout
        ) { sdkResult in
            DispatchQueue.main.async {
                if let treadResult = sdkResult.result {
                    result(treadResult.toJson())
                } else if let error = sdkResult.error {
                    result(FlutterError(
                        code: error.code.name,
                        message: error.message,
                        details: error.debug?.description
                    ))
                }
            }
        }
    }

    private func getHeatmap(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "uuid parameter not found", details: nil))
            return
        }
        let timeout = (arguments?[Constants.EXTRA_TIMEOUT_SECONDS] as? NSNumber)?.int32Value ?? 60

        AnylineTireTread.shared.getHeatmap(
            measurementUUID: uuid,
            timeoutSeconds: timeout
        ) { sdkResult in
            DispatchQueue.main.async {
                if let heatmap = sdkResult.result {
                    result(heatmap.url)
                } else if let error = sdkResult.error {
                    result(FlutterError(
                        code: error.code.name,
                        message: error.message,
                        details: error.debug?.description
                    ))
                }
            }
        }
    }

    private func sendCommentFeedback(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "uuid parameter not found", details: nil))
            return
        }
        guard let comment = arguments?[Constants.EXTRA_FEEDBACK_COMMENT] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "comment parameter not found", details: nil))
            return
        }

        AnylineTireTread.shared.sendCommentFeedback(
            measurementUUID: uuid,
            comment: comment
        ) { sdkResult in
            DispatchQueue.main.async {
                if let info = sdkResult.result {
                    result(self.measurementInfoJson(info))
                } else if let error = sdkResult.error {
                    result(FlutterError(
                        code: error.code.name,
                        message: error.message,
                        details: nil
                    ))
                }
            }
        }
    }

    private func sendTreadDepthResultFeedback(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "uuid parameter not found", details: nil))
            return
        }
        guard let regionsString = arguments?[Constants.EXTRA_TREAD_DEPTH_RESULT_FEEDBACK] as? String,
              let data = regionsString.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "regions parameter not found", details: nil))
            return
        }

        let regions: [TreadResultRegion] = jsonArray.map { region in
            let available = region["available"] as? Bool ?? false
            let valueMm = region["value_mm"] as? Double ?? 0.0
            return TreadResultRegion.companion.doInitMm(isAvailable: available, value: valueMm)
        }

        AnylineTireTread.shared.sendTreadDepthResultFeedback(
            measurementUUID: uuid,
            treadResultRegions: regions
        ) { sdkResult in
            DispatchQueue.main.async {
                if let info = sdkResult.result {
                    result(self.measurementInfoJson(info))
                } else if let error = sdkResult.error {
                    result(FlutterError(
                        code: error.code.name,
                        message: error.message,
                        details: nil
                    ))
                }
            }
        }
    }

    private func sendTireIdFeedback(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        guard let uuid = arguments?[Constants.EXTRA_MEASUREMENT_UUID] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "uuid parameter not found", details: nil))
            return
        }
        guard let tireId = arguments?[Constants.EXTRA_TIRE_ID] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "tireId parameter not found", details: nil))
            return
        }

        AnylineTireTread.shared.sendTireIdFeedback(
            measurementUUID: uuid,
            tireId: tireId
        ) { sdkResult in
            DispatchQueue.main.async {
                if let info = sdkResult.result {
                    result(self.measurementInfoJson(info))
                } else if let error = sdkResult.error {
                    result(FlutterError(
                        code: error.code.name,
                        message: error.message,
                        details: nil
                    ))
                }
            }
        }
    }

    private func setExperimentalFlags(result: @escaping FlutterResult, call: FlutterMethodCall) {
        let arguments = call.arguments as? [String: Any]
        guard let flags = arguments?[Constants.EXTRA_EXPERIMENTAL_FLAGS] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Experimental flags are null", details: nil))
            return
        }
        AnylineTireTreadSdk.shared.setExperimentalFlags(newFlags: flags)
        result(true)
    }

    private func clearExperimentalFlags(result: @escaping FlutterResult) {
        AnylineTireTreadSdk.shared.clearExperimentalFlags()
        result(true)
    }

    // MARK: - Helpers

    /// Serializes a [MeasurementInfo] to the JSON shape the Dart
    /// `MeasurementInfo.fromJson` expects. The SDK type exposes no toJson(),
    /// so we build it from its typed properties.
    private func measurementInfoJson(_ info: MeasurementInfo) -> String? {
        var map: [String: Any] = [
            "measurementUUID": info.measurementUUID,
            "status": info.status.name,
        ]
        if let context = info.additionalContext {
            var contextMap: [String: Any] = [:]
            if let correlationId = context.correlationId {
                contextMap["correlationId"] = correlationId
            }
            if let position = context.tirePosition {
                contextMap["tirePosition"] = [
                    "axle": Int(position.axle),
                    "positionOnAxle": Int(position.positionOnAxle),
                    "side": position.side.name,
                ]
            }
            if !contextMap.isEmpty {
                map["additionalContext"] = contextMap
            }
        }
        guard let data = try? JSONSerialization.data(withJSONObject: map),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }
        return json
    }

    private func sanitizedOutcome(_ outcome: ScanOutcome) -> [String: Any] {
        // Use the SDK's Bridge to obtain a Flutter-codec-safe map, matching the
        // Android implementation. The model's own toMap() embeds non-codec
        // types on the failure path — notably SdkError.debug, a map of kotlinx
        // JsonElement objects — which crash StandardMessageCodec when the reply
        // is encoded. Bridge flattens everything to Foundation primitives.
        let raw = Bridge.shared.outcome(scanOutcome: outcome)
        return raw.filter { Self.allowedOutcomeKeys.contains($0.key) }
    }

    private static let allowedOutcomeKeys: Set<String> = ["kind", "measurementUUID", "error"]
}
