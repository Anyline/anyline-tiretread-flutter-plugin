import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_tread_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tread_depth_result.dart';
import 'package:anyline_tire_tread_plugin/src/scan_outcome.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAnylineTireTreadPluginPlatform
    with MockPlatformInterfaceMixin
    implements AnylineTireTreadPluginPlatform {
  @override
  Future<bool?> initialize(
      {required String licenseKey,
      required String pluginVersion,
      String? customTag}) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getSdkVersion() {
    throw UnimplementedError();
  }

  @override
  Future<TreadDepthResult?> getResult(
      {required String measurementUUID, int? timeoutSeconds}) {
    throw UnimplementedError();
  }

  @override
  Future<ScanOutcome> scan(
      {required TireTreadConfig config, ScanOptions? options}) {
    return Future.value(const ScanCompleted(measurementUUID: ''));
  }

  @override
  Future<bool> isDeviceSupported() {
    return Future.value(true);
  }

  @override
  Future<String?> getHeatMap(
      {required String measurementUUID, int? timeoutSeconds}) {
    throw UnimplementedError();
  }

  @override
  Future<MeasurementInfo?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) {
    throw UnimplementedError();
  }

  @override
  Future<MeasurementInfo?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) {
    throw UnimplementedError();
  }

  @override
  Future<MeasurementInfo?> sendTireIdFeedback(
      {required String measurementUUID, required String tireId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearExperimentalFlags() {
    throw UnimplementedError();
  }

  @override
  Future<void> setExperimentalFlags({required List<String> experimentalFlags}) {
    throw UnimplementedError();
  }
}

void main() {
  final AnylineTireTreadPluginPlatform initialPlatform =
      AnylineTireTreadPluginPlatform.instance;

  test('$MethodChannelAnylineTireTreadPlugin is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelAnylineTireTreadPlugin>());
  });
}
