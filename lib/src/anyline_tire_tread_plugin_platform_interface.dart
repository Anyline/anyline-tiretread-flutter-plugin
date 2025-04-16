import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/models/tread_depth_result.dart';
import 'package:anyline_tire_tread_plugin/src/scan_event.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_method_channel.dart';

abstract class AnylineTireTreadPluginPlatform extends PlatformInterface {
  /// Constructs a AnylineTireTreadPluginPlatform.
  AnylineTireTreadPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AnylineTireTreadPluginPlatform _instance =
      MethodChannelAnylineTireTreadPlugin();

  /// The default instance of [AnylineTireTreadPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAnylineTireTreadPlugin].
  static AnylineTireTreadPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AnylineTireTreadPluginPlatform] when
  /// they register themselves.
  static set instance(AnylineTireTreadPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getSdkVersion() {
    throw UnimplementedError('getSdkVersion() has not been implemented.');
  }

  Future<bool?> initialize(
      {required String licenseKey, required String pluginVersion}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool?> scan({required ScanOptions options}) {
    throw UnimplementedError('scan() has not been implemented.');
  }

  Future<TreadDepthResult?> getResult({required String measurementUUID}) {
    throw UnimplementedError('getResult() has not been implemented.');
  }

  Future<String?> getHeatMap({required String measurementUUID}) {
    throw UnimplementedError('getHeatMap() has not been implemented.');
  }

  Stream<ScanEvent> get onScanningEvent {
    throw UnimplementedError('onEvent has not been implemented.');
  }

  Future<String?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) {
    throw UnimplementedError('sendFeedbackComment() has not been implemented.');
  }

  Future<String?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) {
    throw UnimplementedError(
        'sendTreadDepthResultFeedback() has not been implemented.');
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
