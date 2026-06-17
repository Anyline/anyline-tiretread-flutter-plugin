import 'package:anyline_tire_tread_plugin/src/scan_outcome.dart';
import 'package:anyline_tire_tread_plugin/src/models/sdk_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScanOutcome', () {
    test('ScanCompleted has kind and measurementUUID', () {
      const outcome = ScanCompleted(measurementUUID: 'uuid-123');
      expect(outcome.kind, 'ScanCompleted');
      expect(outcome.measurementUUID, 'uuid-123');
    });

    test('ScanAborted has kind and nullable measurementUUID', () {
      const outcome = ScanAborted(measurementUUID: null);
      expect(outcome.kind, 'ScanAborted');
      expect(outcome.measurementUUID, isNull);
    });

    test('ScanFailed has kind, nullable measurementUUID, and error', () {
      const error = SdkError(
        code: ErrorCode.measurementError,
        type: ErrorType.scanError,
        message: 'Camera failed',
      );
      const outcome = ScanFailed(measurementUUID: 'uuid-456', error: error);
      expect(outcome.kind, 'ScanFailed');
      expect(outcome.measurementUUID, 'uuid-456');
      expect(outcome.error.message, 'Camera failed');
    });

    test('ScanOutcome.fromMap parses ScanCompleted', () {
      final outcome = ScanOutcome.fromMap({
        'kind': 'ScanCompleted',
        'measurementUUID': 'abc',
      });
      expect(outcome, isA<ScanCompleted>());
      expect(outcome.measurementUUID, 'abc');
    });

    test('ScanOutcome.fromMap parses ScanAborted', () {
      final outcome = ScanOutcome.fromMap({
        'kind': 'ScanAborted',
        'measurementUUID': null,
      });
      expect(outcome, isA<ScanAborted>());
      expect(outcome.measurementUUID, isNull);
    });

    test('ScanOutcome.fromMap parses ScanFailed with error map', () {
      final outcome = ScanOutcome.fromMap({
        'kind': 'ScanFailed',
        'measurementUUID': 'xyz',
        'error': {
          'code': 'MEASUREMENT_ERROR',
          'type': 'SCAN_ERROR',
          'message': 'Something went wrong',
        },
      });
      expect(outcome, isA<ScanFailed>());
      final failed = outcome as ScanFailed;
      expect(failed.error.code, ErrorCode.measurementError);
      expect(failed.error.type, ErrorType.scanError);
      expect(failed.error.message, 'Something went wrong');
    });

    test('ScanOutcome.fromMap defaults unknown kind to ScanFailed', () {
      final outcome = ScanOutcome.fromMap({
        'kind': 'SomethingUnknown',
      });
      expect(outcome, isA<ScanFailed>());
    });
  });

  group('SdkError', () {
    test('fromMap parses all fields', () {
      final error = SdkError.fromMap({
        'code': 'NO_CONNECTION',
        'type': 'NETWORK_ERROR',
        'message': 'No internet',
      });
      expect(error.code, ErrorCode.noConnection);
      expect(error.type, ErrorType.networkError);
      expect(error.message, 'No internet');
    });

    test('fromMap handles unknown code gracefully', () {
      final error = SdkError.fromMap({
        'code': 'FUTURE_CODE',
        'type': 'FUTURE_TYPE',
        'message': 'something',
      });
      expect(error.code, ErrorCode.unknownError);
      expect(error.type, ErrorType.scanError);
    });
  });
}
