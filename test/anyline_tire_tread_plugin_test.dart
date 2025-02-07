import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/scan_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAnylineTireTreadPluginPlatform
    with MockPlatformInterfaceMixin
    implements AnylineTireTreadPluginPlatform {
  @override
  Future<bool?> initialize({required String licenseKey}) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getSdkVersion() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getResult({required String measurementUUID}) {
    throw UnimplementedError();
  }

  @override
  Stream<ScanEvent> get onScanningEvent => throw UnimplementedError();

  @override
  Future<bool?> scan({required ScanOptions options}) {
    throw UnimplementedError();
  }

  @override
  Future<String?> getHeatMap({required String measurementUUID}) {
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
