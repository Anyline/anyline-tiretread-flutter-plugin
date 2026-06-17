import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_tread_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tread_depth_result.dart';
import 'package:anyline_tire_tread_plugin/src/scan_outcome.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_method_channel.dart';

abstract class AnylineTireTreadPluginPlatform extends PlatformInterface {
  AnylineTireTreadPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AnylineTireTreadPluginPlatform _instance =
      MethodChannelAnylineTireTreadPlugin();

  static AnylineTireTreadPluginPlatform get instance => _instance;

  static set instance(AnylineTireTreadPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getSdkVersion() {
    throw UnimplementedError('getSdkVersion() has not been implemented.');
  }

  Future<bool?> initialize(
      {required String licenseKey,
      required String pluginVersion,
      String? customTag}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<ScanOutcome> scan(
      {required TireTreadConfig config, ScanOptions? options}) {
    throw UnimplementedError('scan() has not been implemented.');
  }

  Future<bool> isDeviceSupported() {
    throw UnimplementedError('isDeviceSupported() has not been implemented.');
  }

  Future<TreadDepthResult?> getResult(
      {required String measurementUUID, int? timeoutSeconds}) {
    throw UnimplementedError('getResult() has not been implemented.');
  }

  Future<String?> getHeatMap(
      {required String measurementUUID, int? timeoutSeconds}) {
    throw UnimplementedError('getHeatMap() has not been implemented.');
  }

  Future<MeasurementInfo?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) {
    throw UnimplementedError('sendFeedbackComment() has not been implemented.');
  }

  Future<MeasurementInfo?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) {
    throw UnimplementedError(
        'sendTreadDepthResultFeedback() has not been implemented.');
  }

  Future<MeasurementInfo?> sendTireIdFeedback(
      {required String measurementUUID, required String tireId}) {
    throw UnimplementedError('sendTireIdFeedback() has not been implemented.');
  }

  Future<void> setExperimentalFlags({required List<String> experimentalFlags}) {
    throw UnimplementedError(
        'setExperimentalFlags() has not been implemented.');
  }

  Future<void> clearExperimentalFlags() {
    throw UnimplementedError(
        'clearExperimentalFlags() has not been implemented.');
  }
}
