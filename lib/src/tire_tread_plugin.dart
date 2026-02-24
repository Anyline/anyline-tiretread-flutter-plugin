import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_tread_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tread_depth_result.dart';
import 'package:anyline_tire_tread_plugin/src/scan_event.dart';
import 'package:flutter/services.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

/// Main entry point for the Anyline Tire Tread SDK Flutter Plugin.
///
/// This class provides all functionality to scan and analyze tire tread depth,
/// including SDK initialization, scanning operations, result retrieval, and
/// feedback submission.
class TireTreadPlugin {
  /// Creates a new instance of [TireTreadPlugin].
  TireTreadPlugin();

  /// Gets the version of the native Anyline Tire Tread SDK.
  ///
  /// Returns the SDK version string from the underlying native SDK,
  /// or null if the version cannot be determined.
  Future<String?> get sdkVersion =>
      AnylineTireTreadPluginPlatform.instance.getSdkVersion();

  /// Gets the version of this Flutter plugin.
  ///
  /// Returns the plugin version as defined in pubspec.yaml.
  Future<String> get pluginVersion async {
    final fileContent = await rootBundle
        .loadString('packages/anyline_tire_tread_plugin/pubspec.yaml');
    final pubspec = Pubspec.parse(fileContent);
    return pubspec.version?.toString() ?? '';
  }

  /// Initializes the Anyline SDK with the provided license key.
  ///
  /// This method must be called before any scanning operation.
  /// The [licenseKey] will be validated against the Anyline license server.
  ///
  /// Returns `true` if initialization was successful, `false` otherwise.
  /// Throws an exception if the license key is invalid or expired.
  ///
  /// Example:
  /// ```dart
  /// final plugin = TireTreadPlugin();
  /// final success = await plugin.initialize('YOUR_LICENSE_KEY');
  /// ```
  Future<bool?> initialize(String licenseKey) async {
    final version = await pluginVersion;
    return AnylineTireTreadPluginPlatform.instance
        .initialize(licenseKey: licenseKey, pluginVersion: version);
  }

  /// Starts a tire tread scanning session with the provided configuration.
  ///
  /// Opens a full-screen scanning view that guides the user through the
  /// tire scanning process. The scanning behavior and UI can be customized
  /// through the [config] parameter.
  ///
  /// Returns `true` if the scan view was opened successfully.
  /// Listen to [onScanningEvent] to receive scan progress updates and results.
  ///
  /// The SDK must be initialized with [initialize] before calling this method.
  ///
  /// Example:
  /// ```dart
  /// final config = TireTreadConfig()
  ///   ..scanConfig = (ScanConfig()..tireWidth = 185);
  /// await plugin.scan(config: config);
  /// ```
  Future<bool?> scan({required TireTreadConfig config}) async {
    return AnylineTireTreadPluginPlatform.instance.scan(config: config);
  }

  /// Retrieves the detailed tread depth result for a completed measurement.
  ///
  /// The [measurementUUID] is provided in the [ScanProcessCompleted] event
  /// after a successful scan.
  ///
  /// Returns a [TreadDepthResult] containing tread depth measurements,
  /// or null if the measurement UUID is invalid or results are unavailable.
  ///
  /// Example:
  /// ```dart
  /// plugin.onScanningEvent.listen((event) async {
  ///   if (event is ScanProcessCompleted) {
  ///     final result = await plugin.getResult(
  ///       measurementUUID: event.measurementUUID
  ///     );
  ///   }
  /// });
  /// ```
  Future<TreadDepthResult?> getResult({required String measurementUUID}) {
    return AnylineTireTreadPluginPlatform.instance
        .getResult(measurementUUID: measurementUUID);
  }

  /// Retrieves the heatmap image for a completed measurement.
  ///
  /// The heatmap visualizes the tread depth distribution across the tire surface.
  /// The [measurementUUID] is provided in the [ScanProcessCompleted] event.
  ///
  /// Returns a base64-encoded image string, or null if unavailable.
  ///
  /// Example:
  /// ```dart
  /// final heatmapBase64 = await plugin.getHeatMap(
  ///   measurementUUID: measurementUUID
  /// );
  /// final imageBytes = base64Decode(heatmapBase64);
  /// ```
  Future<String?> getHeatMap({required String measurementUUID}) {
    return AnylineTireTreadPluginPlatform.instance
        .getHeatMap(measurementUUID: measurementUUID);
  }

  /// Stream of scanning events during the tire scanning process.
  ///
  /// Emits events such as:
  /// - [ScanStarted]: When scanning begins
  /// - [ScanProcessCompleted]: When scanning completes successfully
  /// - [ScanAborted]: When the user cancels the scan
  /// - [ScanFailed]: When scanning fails with an error
  ///
  /// Subscribe to this stream before calling [scan] to receive all events.
  ///
  /// Example:
  /// ```dart
  /// plugin.onScanningEvent.listen((event) {
  ///   switch (event) {
  ///     case ScanStarted():
  ///       print('Scan started: ${event.measurementUUID}');
  ///     case ScanProcessCompleted():
  ///       print('Scan completed');
  ///     case ScanAborted():
  ///       print('Scan cancelled by user');
  ///     case ScanFailed():
  ///       print('Scan failed: ${event.errorMessage}');
  ///   }
  /// });
  /// ```
  Stream<ScanEvent> get onScanningEvent {
    return AnylineTireTreadPluginPlatform.instance.onScanningEvent;
  }

  /// Submits a text feedback comment for a measurement.
  ///
  /// This allows users to provide additional context or notes about
  /// a specific measurement. The [measurementUUID] identifies the measurement,
  /// and [comment] contains the feedback text.
  ///
  /// Returns the feedback ID if submission was successful, or null otherwise.
  ///
  /// Example:
  /// ```dart
  /// await plugin.sendFeedbackComment(
  ///   measurementUUID: measurementUUID,
  ///   comment: 'Tire had visible damage on the left side'
  /// );
  /// ```
  Future<String?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) {
    return AnylineTireTreadPluginPlatform.instance.sendFeedbackComment(
        measurementUUID: measurementUUID, comment: comment);
  }

  /// Submits corrected tread depth measurement feedback.
  ///
  /// This allows users to provide manual corrections to the automated
  /// tread depth measurements. The [measurementUUID] identifies the measurement,
  /// and [resultRegions] contains the corrected depth values for each region.
  ///
  /// Returns the feedback ID if submission was successful, or null otherwise.
  ///
  /// Example:
  /// ```dart
  /// await plugin.sendTreadDepthResultFeedback(
  ///   measurementUUID: measurementUUID,
  ///   resultRegions: [
  ///     TreadResultRegion(region: 1, depth: 5.2),
  ///     TreadResultRegion(region: 2, depth: 4.8),
  ///   ]
  /// );
  /// ```
  Future<String?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) {
    return AnylineTireTreadPluginPlatform.instance.sendTreadDepthResultFeedback(
        measurementUUID: measurementUUID, resultRegions: resultRegions);
  }

  /// Enables experimental features by setting feature flags.
  ///
  /// This allows access to features that are under development or testing.
  /// The [experimentalFlags] list contains flag names to enable.
  ///
  /// Warning: Experimental features may be unstable or change without notice.
  ///
  /// Example:
  /// ```dart
  /// await plugin.setExperimentalFlags(
  ///   experimentalFlags: ['feature_a', 'feature_b']
  /// );
  /// ```
  Future<void> setExperimentalFlags({required List<String> experimentalFlags}) {
    return AnylineTireTreadPluginPlatform.instance
        .setExperimentalFlags(experimentalFlags: experimentalFlags);
  }

  /// Clears all experimental feature flags.
  ///
  /// This disables any previously enabled experimental features and returns
  /// the SDK to its default behavior.
  ///
  /// Example:
  /// ```dart
  /// await plugin.clearExperimentalFlags();
  /// ```
  Future<void> clearExperimentalFlags() {
    return AnylineTireTreadPluginPlatform.instance.clearExperimentalFlags();
  }
}
