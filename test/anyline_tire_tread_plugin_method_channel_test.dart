import 'package:anyline_tire_tread_plugin/src/Constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAnylineTireTreadPlugin platform =
      MethodChannelAnylineTireTreadPlugin();
  const MethodChannel channel = MethodChannel('anyline_tire_tread_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == Constants.METHOD_INITIALIZE) {
          throw PlatformException(
              code: 'ERROR',
              message: 'Tire Tread SDK could not be initialized');
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('setupWithEmptyLicenseKey', () async {
    try {
      await platform.initialize(licenseKey: '', pluginVersion: '');
    } on PlatformException catch (e) {
      await expectLater(e.message, 'Tire Tread SDK could not be initialized');
    }
  });
}
