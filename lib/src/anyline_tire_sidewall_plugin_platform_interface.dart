import 'package:anyline_tire_tread_plugin/src/anyline_tire_sidewall_plugin_method_channel.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_support.dart';
import 'package:anyline_tire_tread_plugin/src/tire_sidewall_outcome.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AnylineTireSidewallPluginPlatform extends PlatformInterface {
  AnylineTireSidewallPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AnylineTireSidewallPluginPlatform _instance =
      MethodChannelAnylineTireSidewallPlugin();

  static AnylineTireSidewallPluginPlatform get instance => _instance;

  static set instance(AnylineTireSidewallPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<TswScanOutcome> scan(
      {required String clientId, TireSidewallConfig? config}) {
    throw UnimplementedError('scan() has not been implemented.');
  }

  Future<TireSidewallSupport> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  Future<void> resolvePlayServices() {
    throw UnimplementedError('resolvePlayServices() has not been implemented.');
  }
}
