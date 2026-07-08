import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_tread_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tread_depth_result.dart';
import 'package:anyline_tire_tread_plugin/src/scan_outcome.dart';
import 'package:flutter/services.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class TireTreadPlugin {
  TireTreadPlugin();

  Future<String?> get sdkVersion =>
      AnylineTireTreadPluginPlatform.instance.getSdkVersion();

  Future<String> get pluginVersion async {
    final fileContent = await rootBundle
        .loadString('packages/anyline_tire_tread_plugin/pubspec.yaml');
    final pubspec = Pubspec.parse(fileContent);
    return pubspec.version?.toString() ?? '';
  }

  /// Initializes the SDK with the provided [licenseKey].
  ///
  /// An optional [customTag] can be supplied to tag measurements; it is
  /// forwarded to the SDK's `InitOptions.customTag`.
  ///
  /// [uploadTimeoutMillis] overrides the maximum time (in milliseconds) allowed
  /// per attempt when uploading a single captured image. Each image is tried up
  /// to 2 times (1 retry) internally. Raise for poor-connectivity fleets, lower
  /// to fail fast. Defaults to `20000` when `null` is passed.
  Future<bool?> initialize(String licenseKey,
      {String? customTag, int? uploadTimeoutMillis}) async {
    final version = await pluginVersion;
    return AnylineTireTreadPluginPlatform.instance.initialize(
        licenseKey: licenseKey,
        pluginVersion: version,
        customTag: customTag,
        uploadTimeoutMillis: uploadTimeoutMillis);
  }

  /// Starts a scan and completes with its [ScanOutcome]
  /// ([ScanCompleted], [ScanAborted] or [ScanFailed]).
  ///
  /// [options] maps to the SDK's `ScanOptions` (e.g. `enableDebugLogging`).
  Future<ScanOutcome> scan(
      {required TireTreadConfig config, ScanOptions? options}) {
    return AnylineTireTreadPluginPlatform.instance
        .scan(config: config, options: options);
  }

  Future<bool> isDeviceSupported() {
    return AnylineTireTreadPluginPlatform.instance.isDeviceSupported();
  }

  Future<TreadDepthResult?> getResult(
      {required String measurementUUID, int? timeoutSeconds}) {
    return AnylineTireTreadPluginPlatform.instance.getResult(
        measurementUUID: measurementUUID, timeoutSeconds: timeoutSeconds);
  }

  /// Returns the heatmap image URL for [measurementUUID], or `null` if none is
  /// available.
  ///
  /// The returned value is a short-lived **signed URL** (valid for roughly 15
  /// minutes). Load it promptly and do not persist it; request a fresh URL with
  /// another call if it has expired. Errors surface as a [PlatformException]
  /// whose `code` equals the SDK `ErrorCode` name.
  ///
  /// The native SDK models this as a `Heatmap { url }` object; this wrapper
  /// returns the `url` directly because it is currently the only field. If a
  /// future SDK adds fields, this may become a `Heatmap` model.
  Future<String?> getHeatMap(
      {required String measurementUUID, int? timeoutSeconds}) {
    return AnylineTireTreadPluginPlatform.instance.getHeatMap(
        measurementUUID: measurementUUID, timeoutSeconds: timeoutSeconds);
  }

  /// Submits a free-text comment for [measurementUUID].
  ///
  /// Returns the updated [MeasurementInfo] (including the latest
  /// `MeasurementStatus`); errors are thrown as [PlatformException] with
  /// `code` equal to the SDK `ErrorCode` name.
  Future<MeasurementInfo?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) {
    return AnylineTireTreadPluginPlatform.instance.sendFeedbackComment(
        measurementUUID: measurementUUID, comment: comment);
  }

  /// Submits corrected tread-depth regions for [measurementUUID].
  ///
  /// Returns the updated [MeasurementInfo]; errors are thrown as
  /// [PlatformException] with `code` equal to the SDK `ErrorCode` name.
  Future<MeasurementInfo?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) {
    return AnylineTireTreadPluginPlatform.instance.sendTreadDepthResultFeedback(
        measurementUUID: measurementUUID, resultRegions: resultRegions);
  }

  /// Submits a tire identifier for [measurementUUID].
  ///
  /// Returns the updated [MeasurementInfo]; errors are thrown as
  /// [PlatformException] with `code` equal to the SDK `ErrorCode` name.
  Future<MeasurementInfo?> sendTireIdFeedback(
      {required String measurementUUID, required String tireId}) {
    return AnylineTireTreadPluginPlatform.instance
        .sendTireIdFeedback(measurementUUID: measurementUUID, tireId: tireId);
  }

  Future<void> setExperimentalFlags({required List<String> experimentalFlags}) {
    return AnylineTireTreadPluginPlatform.instance
        .setExperimentalFlags(experimentalFlags: experimentalFlags);
  }

  Future<void> clearExperimentalFlags() {
    return AnylineTireTreadPluginPlatform.instance.clearExperimentalFlags();
  }
}
