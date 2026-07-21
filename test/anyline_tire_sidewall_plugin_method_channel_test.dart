import 'dart:convert';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_sidewall_plugin_method_channel.dart';
import 'package:anyline_tire_tread_plugin/src/sidewall_constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelAnylineTireSidewallPlugin platform;
  const MethodChannel channel = MethodChannel('anyline_tire_sidewall_plugin');

  setUp(() {
    platform = MethodChannelAnylineTireSidewallPlugin();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  void setMockHandler(
      Future<Object?>? Function(MethodCall methodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  group('scan', () {
    test('returns TswScanCompleted with resultJson, image bytes and lighting',
        () async {
      // The returned value is encoded/decoded by StandardMethodCodec, exactly
      // as on a real device: byte arrays round-trip as Uint8List, nested maps
      // as Map<Object?, Object?>.
      setMockHandler((methodCall) async {
        if (methodCall.method == SidewallConstants.METHOD_SCAN) {
          return <String, dynamic>{
            'kind': 'completed',
            'resultJson': '{"foo":"bar"}',
            'imageBytes': Uint8List.fromList([1, 2, 3, 4]),
            'environmentLighting': 'Dark',
          };
        }
        return null;
      });

      final outcome = await platform.scan(clientId: 'client-1');
      expect(outcome, isA<TswScanCompleted>());
      final completed = outcome as TswScanCompleted;
      expect(completed.resultJson, '{"foo":"bar"}');
      expect(completed.imageBytes, Uint8List.fromList([1, 2, 3, 4]));
      expect(completed.lighting, EnvironmentLighting.Dark);
    });

    test('returns TswScanCompleted with null lighting when absent', () async {
      setMockHandler((methodCall) async {
        return <String, dynamic>{
          'kind': 'completed',
          'resultJson': '{}',
          'imageBytes': Uint8List(0),
        };
      });

      final outcome = await platform.scan(clientId: 'client-1');
      expect(outcome, isA<TswScanCompleted>());
      expect((outcome as TswScanCompleted).lighting, isNull);
    });

    test('returns TswScanAborted when native reports aborted', () async {
      setMockHandler(
          (methodCall) async => <String, dynamic>{'kind': 'aborted'});

      final outcome = await platform.scan(clientId: 'client-1');
      expect(outcome, isA<TswScanAborted>());
    });

    test('returns TswScanFailed when native returns null', () async {
      setMockHandler((methodCall) async => null);

      final outcome = await platform.scan(clientId: 'client-1');
      expect(outcome, isA<TswScanFailed>());
    });

    test('returns TswScanFailed with structured error', () async {
      setMockHandler((methodCall) async {
        return <String, dynamic>{
          'kind': 'failed',
          'error': <String, dynamic>{
            'code': 'UPLOAD_FAILED',
            'type': 'NETWORK_ERROR',
            'message': 'Upload failed',
          },
        };
      });

      final outcome = await platform.scan(clientId: 'client-1');
      expect(outcome, isA<TswScanFailed>());
      final failed = outcome as TswScanFailed;
      expect(failed.error.code, ErrorCode.uploadFailed);
      expect(failed.error.type, ErrorType.networkError);
      expect(failed.error.message, 'Upload failed');
    });

    test('passes clientId and config JSON to the method channel', () async {
      Map<String, dynamic>? capturedArguments;
      setMockHandler((methodCall) async {
        if (methodCall.method == SidewallConstants.METHOD_SCAN) {
          capturedArguments =
              Map<String, dynamic>.from(methodCall.arguments as Map);
          return <String, dynamic>{'kind': 'aborted'};
        }
        return null;
      });

      final config = TireSidewallConfig()
        ..correlationId = 'corr-1'
        ..texts = (TireSidewallTexts()..alignTire = 'Align it');
      await platform.scan(clientId: 'client-7', config: config);

      expect(capturedArguments?[SidewallConstants.EXTRA_CLIENT_ID], 'client-7');
      final configJson =
          capturedArguments?[SidewallConstants.EXTRA_CONFIG_JSON] as String?;
      expect(configJson, isNotNull);
      final decoded = jsonDecode(configJson!) as Map<String, dynamic>;
      expect(decoded['correlationId'], 'corr-1');
      expect(
          (decoded['texts'] as Map<String, dynamic>)['alignTire'], 'Align it');
    });

    test('passes null config JSON when no config provided', () async {
      Map<String, dynamic>? capturedArguments;
      setMockHandler((methodCall) async {
        capturedArguments =
            Map<String, dynamic>.from(methodCall.arguments as Map);
        return <String, dynamic>{'kind': 'aborted'};
      });

      await platform.scan(clientId: 'client-7');

      expect(
          capturedArguments?.containsKey(SidewallConstants.EXTRA_CONFIG_JSON),
          true);
      expect(capturedArguments?[SidewallConstants.EXTRA_CONFIG_JSON], isNull);
    });
  });

  group('isSupported', () {
    test('returns supported when native reports supported', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == SidewallConstants.METHOD_IS_SUPPORTED) {
          return <String, dynamic>{'supported': true};
        }
        return null;
      });

      final support = await platform.isSupported();
      expect(support.supported, true);
      expect(support.error, isNull);
    });

    test('returns unavailable with userResolvable error', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == SidewallConstants.METHOD_IS_SUPPORTED) {
          return <String, dynamic>{
            'supported': false,
            'userResolvable': true,
            'error': <String, dynamic>{
              'code': 'PLAY_SERVICES_UNAVAILABLE',
              'type': 'SCAN_ERROR',
              'message': 'Play Services unavailable',
            },
          };
        }
        return null;
      });

      final support = await platform.isSupported();
      expect(support.supported, false);
      expect(support.userResolvable, true);
      expect(support.error?.code, ErrorCode.playServicesUnavailable);
    });

    test('returns unsupported when native returns null', () async {
      setMockHandler((methodCall) async => null);

      final support = await platform.isSupported();
      expect(support.supported, false);
    });
  });

  group('resolvePlayServices', () {
    test('invokes the resolve method on the channel', () async {
      var invoked = false;
      setMockHandler((methodCall) async {
        if (methodCall.method ==
            SidewallConstants.METHOD_RESOLVE_PLAY_SERVICES) {
          invoked = true;
        }
        return null;
      });

      await platform.resolvePlayServices();
      expect(invoked, true);
    });
  });

  group('TswScanOutcome.fromMap', () {
    test('maps an unknown kind to TswScanFailed', () {
      final outcome =
          TswScanOutcome.fromMap(<String, dynamic>{'kind': 'something-else'});
      expect(outcome, isA<TswScanFailed>());
      expect((outcome as TswScanFailed).error.code, ErrorCode.unknownError);
    });
  });

  group('EnvironmentLighting.fromName', () {
    test('parses known names and null-safes unknown/absent', () {
      expect(EnvironmentLighting.fromName('Good'), EnvironmentLighting.Good);
      expect(
          EnvironmentLighting.fromName('Bright'), EnvironmentLighting.Bright);
      expect(EnvironmentLighting.fromName(null), isNull);
      expect(EnvironmentLighting.fromName('nope'), isNull);
    });
  });
}
