import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/scanning_event.dart';
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

  Future<bool?> initialize(String licenseKey) {
    return AnylineTireTreadPluginPlatform.instance
        .initialize(licenseKey: licenseKey);
  }

  Future<bool?> scan({required ScanOptions options}) async {
    return AnylineTireTreadPluginPlatform.instance.scan(options: options);
  }

  Future<String?> getResult({required String measurementUUID}) {
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
}
