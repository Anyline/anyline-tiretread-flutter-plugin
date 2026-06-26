import 'package:anyline_tire_tread_plugin/src/anyline_tire_sidewall_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_support.dart';
import 'package:anyline_tire_tread_plugin/src/tire_sidewall_outcome.dart';

/// Flutter entry point for the Anyline **Tire Sidewall (TSW)** scanner.
///
/// TSW is a separate product from tire-tread depth: it captures a single
/// sidewall image on-device, uploads it, and returns the result synchronously.
/// It does not use the tread scanner's `measurementUUID` / result-polling flow.
///
/// ```dart
/// final plugin = TireSidewallPlugin();
///
/// final support = await plugin.isSupported();
/// if (!support.supported) {
///   if (support.userResolvable) await plugin.resolvePlayServices();
///   return;
/// }
///
/// final outcome = await plugin.scan(clientId: 'YOUR_CLIENT_ID');
/// switch (outcome) {
///   case TswScanCompleted():
///     // outcome.resultJson, outcome.imageBytes, outcome.lighting
///   case TswScanAborted():
///     // user cancelled
///   case TswScanFailed():
///     // outcome.error.code / outcome.error.message
/// }
/// ```
class TireSidewallPlugin {
  TireSidewallPlugin();

  /// Starts a sidewall scan and completes with its [TswScanOutcome]
  /// ([TswScanCompleted], [TswScanAborted] or [TswScanFailed]).
  ///
  /// [clientId] is required and identifies the integrator to the sidewall
  /// backend. [config] is optional; omit it to use the SDK defaults.
  Future<TswScanOutcome> scan(
      {required String clientId, TireSidewallConfig? config}) {
    return AnylineTireSidewallPluginPlatform.instance
        .scan(clientId: clientId, config: config);
  }

  /// Checks whether this device can run the sidewall scanner.
  ///
  /// On Android this verifies Google Play Services and its TFLite runtime; on
  /// iOS the scanner is always supported. Does not require SDK initialization.
  Future<TireSidewallSupport> isSupported() {
    return AnylineTireSidewallPluginPlatform.instance.isSupported();
  }

  /// Shows the Google Play Services resolution dialog after [isSupported]
  /// reported a user-resolvable failure. No-op on iOS and when Play Services is
  /// already available.
  Future<void> resolvePlayServices() {
    return AnylineTireSidewallPluginPlatform.instance.resolvePlayServices();
  }
}
