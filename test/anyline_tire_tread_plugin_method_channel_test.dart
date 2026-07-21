import 'dart:convert';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin/src/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelAnylineTireTreadPlugin platform;
  const MethodChannel channel = MethodChannel('anyline_tire_tread_plugin');

  setUp(() {
    platform = MethodChannelAnylineTireTreadPlugin();
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

  group('initialize', () {
    test('throws PlatformException on SDK initialization failure', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_INITIALIZE) {
          throw PlatformException(
              code: 'ERROR',
              message: 'Tire Tread SDK could not be initialized');
        }
        return null;
      });

      try {
        await platform.initialize(licenseKey: '', pluginVersion: '');
        fail('Expected PlatformException');
      } on PlatformException catch (e) {
        expect(e.message, 'Tire Tread SDK could not be initialized');
      }
    });

    test(
        'passes licenseKey, pluginVersion, customTag and uploadTimeoutMillis to native',
        () async {
      Map<String, dynamic>? capturedArguments;
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_INITIALIZE) {
          capturedArguments =
              Map<String, dynamic>.from(methodCall.arguments as Map);
          return true;
        }
        return null;
      });

      await platform.initialize(
          licenseKey: 'key',
          pluginVersion: '4.0.0',
          customTag: 'garage-7',
          uploadTimeoutMillis: 30000);

      expect(capturedArguments?[Constants.EXTRA_LICENSE_KEY], 'key');
      expect(capturedArguments?[Constants.EXTRA_PLUGIN_VERSION], '4.0.0');
      expect(capturedArguments?[Constants.EXTRA_CUSTOM_TAG], 'garage-7');
      expect(capturedArguments?[Constants.EXTRA_UPLOAD_TIMEOUT_MILLIS], 30000);
    });

    test('passes null customTag and uploadTimeoutMillis when not provided',
        () async {
      Map<String, dynamic>? capturedArguments;
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_INITIALIZE) {
          capturedArguments =
              Map<String, dynamic>.from(methodCall.arguments as Map);
          return true;
        }
        return null;
      });

      await platform.initialize(licenseKey: 'key', pluginVersion: '4.0.0');

      expect(capturedArguments?.containsKey(Constants.EXTRA_CUSTOM_TAG), true);
      expect(capturedArguments?[Constants.EXTRA_CUSTOM_TAG], isNull);
      expect(
          capturedArguments?.containsKey(Constants.EXTRA_UPLOAD_TIMEOUT_MILLIS),
          true);
      expect(capturedArguments?[Constants.EXTRA_UPLOAD_TIMEOUT_MILLIS], isNull);
    });
  });

  group('scan', () {
    test('returns ScanCompleted when native returns completed outcome',
        () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          return <String, dynamic>{
            'kind': 'ScanCompleted',
            'measurementUUID': 'test-uuid',
          };
        }
        return null;
      });

      final result = await platform.scan(config: TireTreadConfig());
      expect(result, isA<ScanCompleted>());
      expect(result.measurementUUID, 'test-uuid');
    });

    test('returns ScanAborted when native returns aborted outcome', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          return <String, dynamic>{
            'kind': 'ScanAborted',
            'measurementUUID': null,
          };
        }
        return null;
      });

      final result = await platform.scan(config: TireTreadConfig());
      expect(result, isA<ScanAborted>());
    });

    test('returns ScanFailed when native returns null', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          return null;
        }
        return null;
      });

      final result = await platform.scan(config: TireTreadConfig());
      expect(result, isA<ScanFailed>());
    });

    test('returns ScanFailed with structured error when native reports failure',
        () async {
      // Unlike the direct ScanOutcome.fromMap unit test, the value returned
      // here is encoded and decoded by StandardMethodCodec (exactly what
      // happens on a real device). The codec rebuilds every map as
      // Map<Object?, Object?>, including the nested `error` map. This is the
      // real on-device shape of a ScanFailed outcome carrying an error.
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          return <String, dynamic>{
            'kind': 'ScanFailed',
            'measurementUUID': null,
            'error': <String, dynamic>{
              'code': 'MEASUREMENT_ERROR',
              'type': 'SCAN_ERROR',
              'message': 'Camera failed',
            },
          };
        }
        return null;
      });

      final result = await platform.scan(config: TireTreadConfig());
      expect(result, isA<ScanFailed>());
      final failed = result as ScanFailed;
      expect(failed.error.code, ErrorCode.measurementError);
      expect(failed.error.type, ErrorType.scanError);
      expect(failed.error.message, 'Camera failed');
    });

    test('throws PlatformException with SCAN_ERROR when scan fails', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          throw PlatformException(
            code: 'SCAN_ERROR',
            message: 'Scan failed: camera error',
          );
        }
        return null;
      });

      try {
        await platform.scan(config: TireTreadConfig());
        fail('Expected PlatformException');
      } on PlatformException catch (e) {
        expect(e.code, 'SCAN_ERROR');
        expect(e.message, 'Scan failed: camera error');
      }
    });

    test(
        'returns ScanFailed with alreadyRunning when native reports '
        'a scan in progress (RN-parity outcome, not an exception)', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          return <String, dynamic>{
            'kind': 'ScanFailed',
            'measurementUUID': null,
            'error': {
              'code': 'ALREADY_RUNNING',
              'type': 'CONFIG_ERROR',
              'message': 'A scan is already in progress',
            },
          };
        }
        return null;
      });

      final result = await platform.scan(config: TireTreadConfig());
      expect(result, isA<ScanFailed>());
      expect((result as ScanFailed).error.code, ErrorCode.alreadyRunning);
    });

    test('passes config and options as JSON strings to method channel',
        () async {
      Map<String, dynamic>? capturedArguments;
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          capturedArguments =
              Map<String, dynamic>.from(methodCall.arguments as Map);
          return <String, dynamic>{
            'kind': 'ScanCompleted',
            'measurementUUID': 'test-uuid',
          };
        }
        return null;
      });

      final config = TireTreadConfig()
        ..scanConfig = (ScanConfig()..tireWidth = 205);
      await platform.scan(
          config: config, options: ScanOptions(enableDebugLogging: true));

      final configJson =
          capturedArguments?[Constants.EXTRA_CONFIG_JSON] as String?;
      expect(configJson, isNotNull);
      final decodedConfig = jsonDecode(configJson!) as Map<String, dynamic>;
      expect((decodedConfig['scanConfig'] as Map<String, dynamic>)['tireWidth'],
          205);

      final optionsJson =
          capturedArguments?[Constants.EXTRA_SCAN_OPTIONS_JSON] as String?;
      expect(optionsJson, isNotNull);
      expect(jsonDecode(optionsJson!), {'enableDebugLogging': true});
    });

    test('passes null options JSON when no options provided', () async {
      Map<String, dynamic>? capturedArguments;
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SCAN) {
          capturedArguments =
              Map<String, dynamic>.from(methodCall.arguments as Map);
          return <String, dynamic>{
            'kind': 'ScanCompleted',
            'measurementUUID': 'test-uuid',
          };
        }
        return null;
      });

      await platform.scan(config: TireTreadConfig());

      expect(capturedArguments?[Constants.EXTRA_SCAN_OPTIONS_JSON], isNull);
    });
  });

  group('isDeviceSupported', () {
    test('returns true when native returns true', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_IS_DEVICE_SUPPORTED) {
          return true;
        }
        return null;
      });

      final result = await platform.isDeviceSupported();
      expect(result, true);
    });

    test('returns false when native returns null', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_IS_DEVICE_SUPPORTED) {
          return null;
        }
        return null;
      });

      final result = await platform.isDeviceSupported();
      expect(result, false);
    });
  });

  group('feedback returns MeasurementInfo', () {
    test('parses full MeasurementInfo JSON from native', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SEND_TIRE_ID_FEEDBACK) {
          return jsonEncode({
            'measurementUUID': 'uuid-9',
            'status': 'ResultAndReportReady',
            'additionalContext': {'correlationId': 'corr-9'},
          });
        }
        return null;
      });

      final info = await platform.sendTireIdFeedback(
          measurementUUID: 'uuid-9', tireId: 'TIRE-123');
      expect(info?.measurementUUID, 'uuid-9');
      expect(info?.status, MeasurementStatus.ResultAndReportReady);
      expect(info?.additionalContext?.correlationId, 'corr-9');
    });

    test('falls back to a bare UUID string (backward compatibility)', () async {
      setMockHandler((methodCall) async {
        if (methodCall.method == Constants.METHOD_SEND_FEEDBACK_COMMENT) {
          return 'feedback-id';
        }
        return null;
      });

      final info = await platform.sendFeedbackComment(
          measurementUUID: 'x', comment: 'c');
      expect(info?.measurementUUID, 'feedback-id');
      expect(info?.status, isNull);
    });

    test('returns null when native returns null', () async {
      setMockHandler((methodCall) async => null);

      final info =
          await platform.sendTireIdFeedback(measurementUUID: 'x', tireId: 'y');
      expect(info, isNull);
    });
  });
}
