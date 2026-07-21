import 'dart:typed_data';

import 'package:anyline_tire_tread_plugin/src/enum/environment_lighting.dart';
import 'package:anyline_tire_tread_plugin/src/models/sdk_error.dart';
import 'package:anyline_tire_tread_plugin/src/tire_sidewall_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TswScanOutcome variants', () {
    test('TswScanCompleted carries kind, resultJson, image bytes and lighting',
        () {
      final outcome = TswScanCompleted(
        resultJson: '{"foo":"bar"}',
        imageBytes: Uint8List.fromList([1, 2, 3]),
        lighting: EnvironmentLighting.Good,
      );
      expect(outcome.kind, 'completed');
      expect(outcome.resultJson, '{"foo":"bar"}');
      expect(outcome.imageBytes, Uint8List.fromList([1, 2, 3]));
      expect(outcome.lighting, EnvironmentLighting.Good);
    });

    test('TswScanCompleted allows null lighting', () {
      final outcome =
          TswScanCompleted(resultJson: '{}', imageBytes: Uint8List(0));
      expect(outcome.lighting, isNull);
    });

    test('TswScanAborted has the aborted kind', () {
      const outcome = TswScanAborted();
      expect(outcome.kind, 'aborted');
    });

    test('TswScanFailed has the failed kind and carries the error', () {
      const error = SdkError(
        code: ErrorCode.uploadFailed,
        type: ErrorType.networkError,
        message: 'Upload failed',
      );
      const outcome = TswScanFailed(error: error);
      expect(outcome.kind, 'failed');
      expect(outcome.error.code, ErrorCode.uploadFailed);
    });
  });

  group('TswScanOutcome.fromMap', () {
    test('parses a completed outcome with Uint8List image bytes', () {
      final outcome = TswScanOutcome.fromMap({
        'kind': 'completed',
        'resultJson': '{"ok":true}',
        'imageBytes': Uint8List.fromList([9, 8, 7]),
        'environmentLighting': 'Bright',
      });
      expect(outcome, isA<TswScanCompleted>());
      final completed = outcome as TswScanCompleted;
      expect(completed.resultJson, '{"ok":true}');
      expect(completed.imageBytes, Uint8List.fromList([9, 8, 7]));
      expect(completed.lighting, EnvironmentLighting.Bright);
    });

    test('coerces a List<int> image payload into Uint8List', () {
      final outcome = TswScanOutcome.fromMap({
        'kind': 'completed',
        'resultJson': '{}',
        'imageBytes': <int>[10, 20, 30],
      });
      final completed = outcome as TswScanCompleted;
      expect(completed.imageBytes, isA<Uint8List>());
      expect(completed.imageBytes, Uint8List.fromList([10, 20, 30]));
    });

    test('falls back to empty bytes when the image payload is missing', () {
      final outcome = TswScanOutcome.fromMap({
        'kind': 'completed',
        'resultJson': '{}',
      });
      final completed = outcome as TswScanCompleted;
      expect(completed.imageBytes, isEmpty);
    });

    test('defaults resultJson to empty string when absent', () {
      final outcome = TswScanOutcome.fromMap({
        'kind': 'completed',
        'imageBytes': Uint8List(0),
      });
      expect((outcome as TswScanCompleted).resultJson, '');
    });

    test('parses an aborted outcome', () {
      final outcome = TswScanOutcome.fromMap({'kind': 'aborted'});
      expect(outcome, isA<TswScanAborted>());
    });

    test('parses a failed outcome with a structured error', () {
      final outcome = TswScanOutcome.fromMap({
        'kind': 'failed',
        'error': {
          'code': 'INVALID_UUID',
          'type': 'SCAN_ERROR',
          'message': 'Bad correlation id',
        },
      });
      expect(outcome, isA<TswScanFailed>());
      final failed = outcome as TswScanFailed;
      expect(failed.error.code, ErrorCode.invalidUuid);
      expect(failed.error.message, 'Bad correlation id');
    });

    test('failed outcome without an error map yields an unknown error', () {
      final outcome = TswScanOutcome.fromMap({'kind': 'failed'});
      expect(outcome, isA<TswScanFailed>());
      expect((outcome as TswScanFailed).error.code, ErrorCode.unknownError);
    });

    test('maps an unknown kind to TswScanFailed with an unknown error', () {
      final outcome = TswScanOutcome.fromMap({'kind': 'bogus'});
      expect(outcome, isA<TswScanFailed>());
      expect((outcome as TswScanFailed).error.code, ErrorCode.unknownError);
    });

    test('maps a missing kind to TswScanFailed', () {
      final outcome = TswScanOutcome.fromMap(<String, dynamic>{});
      expect(outcome, isA<TswScanFailed>());
    });
  });

  group('EnvironmentLighting.fromName', () {
    test('parses every known value', () {
      expect(EnvironmentLighting.fromName('Dark'), EnvironmentLighting.Dark);
      expect(
          EnvironmentLighting.fromName('Bright'), EnvironmentLighting.Bright);
      expect(EnvironmentLighting.fromName('Good'), EnvironmentLighting.Good);
    });

    test('returns null for an unknown or absent name', () {
      expect(EnvironmentLighting.fromName(null), isNull);
      expect(EnvironmentLighting.fromName('Dim'), isNull);
      expect(EnvironmentLighting.fromName(''), isNull);
    });
  });
}
