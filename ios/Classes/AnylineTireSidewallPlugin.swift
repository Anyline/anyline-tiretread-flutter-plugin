import Flutter
import UIKit
import AnylineTireTreadSdk

/// Bridges the Tire Sidewall (TSW) scanner to Flutter over the dedicated
/// `anyline_tire_sidewall_plugin` channel.
///
/// Registered from `AnylineTireTreadPlugin.register(with:)` because a Flutter
/// package declares a single `pluginClass` per platform.
public class AnylineTireSidewallPlugin: NSObject, FlutterPlugin {

    private var pendingScanResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: SidewallConstants.CHANNEL,
                                           binaryMessenger: registrar.messenger())
        let instance = AnylineTireSidewallPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case SidewallConstants.METHOD_SCAN:
            scan(result: result, call: call)
        case SidewallConstants.METHOD_IS_SUPPORTED:
            isSupported(result: result)
        case SidewallConstants.METHOD_RESOLVE_PLAY_SERVICES:
            // Android-only; no-op on iOS.
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - SDK Methods

    private func scan(result: @escaping FlutterResult, call: FlutterMethodCall) {
        if pendingScanResult != nil {
            result(failedOutcome(code: .alreadyRunning, message: "A sidewall scan is already in progress"))
            return
        }

        // Present from the topmost view controller (parity with the tread
        // scanner): presenting from the root VC fails when another controller
        // is already presented.
        guard let presenter = topViewController() else {
            result(failedOutcome(code: .invalidArgument,
                                 message: "Unable to present scan: no active view controller"))
            return
        }

        let arguments = call.arguments as? [String: Any]
        let clientId = arguments?[SidewallConstants.EXTRA_CLIENT_ID] as? String ?? ""
        let configJson = arguments?[SidewallConstants.EXTRA_CONFIG_JSON] as? String

        pendingScanResult = result

        AnylineTireSidewallScanner().scan(
            from: presenter,
            clientId: clientId,
            config: buildConfig(configJson)
        ) { [weak self] scanResult in
            DispatchQueue.main.async {
                guard let pending = self?.pendingScanResult else { return }
                self?.pendingScanResult = nil
                pending(self?.serialize(scanResult) ?? [:])
            }
        }
    }

    private func isSupported(result: @escaping FlutterResult) {
        AnylineTireSidewallScanner.companion.isSupported { status, _ in
            DispatchQueue.main.async {
                if let unavailable = status as? TswSupportStatus.Unavailable {
                    result([
                        "supported": false,
                        "userResolvable": unavailable.userResolvable,
                        "error": unavailable.error.toMap(),
                    ])
                } else {
                    // iOS reports the sidewall scanner as always supported.
                    result(["supported": true])
                }
            }
        }
    }

    // MARK: - Helpers

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

    private func serialize(_ result: TswScanResult) -> [String: Any] {
        if let completed = result as? TswScanResult.Completed {
            var map: [String: Any] = [
                "kind": "completed",
                "resultJson": completed.resultJson,
                "imageBytes": FlutterStandardTypedData(bytes: toData(completed.imageBytes)),
            ]
            if let lighting = completed.scanMetadata.environmentLighting {
                map["environmentLighting"] = lighting.name
            }
            return map
        }
        if let failed = result as? TswScanResult.Failed {
            return ["kind": "failed", "error": failed.error.toMap()]
        }
        // TswScanResult.Aborted
        return ["kind": "aborted"]
    }

    private func failedOutcome(code: ErrorCode, message: String) -> [String: Any] {
        let error = SdkError(
            code: code,
            type: ErrorType.companion.fromCode(code: code),
            message: message,
            debug: nil
        )
        return ["kind": "failed", "error": error.toMap()]
    }

    private func buildConfig(_ configJson: String?) -> TswScannerConfig {
        let config = TswScannerConfig()
        guard let configJson = configJson,
              let data = configJson.data(using: .utf8),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return config
        }

        if let correlationId = root["correlationId"] as? String {
            config.correlationId = correlationId
        }
        if let texts = root["texts"] as? [String: Any] {
            let t = config.texts
            if let v = texts["initializing"] as? String { t.textInitializing = v }
            if let v = texts["alignTire"] as? String { t.textAlignTire = v }
            if let v = texts["moveCloser"] as? String { t.textMoveCloser = v }
            if let v = texts["moveAway"] as? String { t.textMoveAway = v }
            if let v = texts["faceTire"] as? String { t.textFaceTire = v }
            if let v = texts["ready"] as? String { t.textReady = v }
            if let v = texts["holdSteady"] as? String { t.textHoldSteady = v }
            if let v = texts["focusing"] as? String { t.textFocusing = v }
            if let v = texts["calibratingWhiteBalance"] as? String { t.textCalibratingWhiteBalance = v }
            if let v = texts["calibratingExposure"] as? String { t.textCalibratingExposure = v }
            if let v = texts["tooDark"] as? String { t.textTooDark = v }
        }
        return config
    }

    /// Copies a Kotlin `ByteArray` (bridged as `KotlinByteArray`) into `Data`.
    ///
    /// NOTE: this copies byte-by-byte across the Kotlin/Native boundary. For
    /// large images consider adding a `ByteArray` → `NSData` accessor on the
    /// SDK side to avoid the per-byte bridge cost.
    private func toData(_ array: KotlinByteArray) -> Data {
        let count = Int(array.size)
        guard count > 0 else { return Data() }
        var data = Data(count: count)
        data.withUnsafeMutableBytes { (raw: UnsafeMutableRawBufferPointer) in
            let dst = raw.bindMemory(to: Int8.self).baseAddress!
            for i in 0..<count {
                dst[i] = array.get(index: Int32(i))
            }
        }
        return data
    }
}
