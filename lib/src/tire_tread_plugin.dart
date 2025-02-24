import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/models/tread_depth_result.dart';
import 'package:anyline_tire_tread_plugin/src/scan_event.dart';
import 'package:flutter/services.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

/// This library provides functionality to scan and analyze tire tread depth.
class TireTreadPlugin {
  Future<String?> get sdkVersion =>
      AnylineTireTreadPluginPlatform.instance.getSdkVersion();

  Future<String> get pluginVersion async {
    final fileContent = await rootBundle
        .loadString('packages/anyline_tire_tread_plugin/pubspec.yaml');
    final pubspec = Pubspec.parse(fileContent);
    return pubspec.version?.toString() ?? '';
  }

  Future<bool?> initialize(String licenseKey) async {
    final version = await pluginVersion;
    return AnylineTireTreadPluginPlatform.instance
        .initialize(licenseKey: licenseKey, pluginVersion: version);
  }

  Future<bool?> scan({required ScanOptions options}) async {
    return AnylineTireTreadPluginPlatform.instance.scan(options: options);
  }

  Future<TreadDepthResult?> getResult({required String measurementUUID}) {
    return AnylineTireTreadPluginPlatform.instance
        .getResult(measurementUUID: measurementUUID);
  }

  Future<String?> getHeatMap({required String measurementUUID}) {
    return AnylineTireTreadPluginPlatform.instance
        .getHeatMap(measurementUUID: measurementUUID);
  }

  Stream<ScanEvent> get onScanningEvent {
    return AnylineTireTreadPluginPlatform.instance.onScanningEvent;
  }

  Future<String?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) {
    return AnylineTireTreadPluginPlatform.instance.sendFeedbackComment(
        measurementUUID: measurementUUID, comment: comment);
  }

  Future<String?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) {
    return AnylineTireTreadPluginPlatform.instance.sendTreadDepthResultFeedback(
        measurementUUID: measurementUUID, resultRegions: resultRegions);
  }
}
