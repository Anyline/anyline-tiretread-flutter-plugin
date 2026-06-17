import 'package:anyline_tire_tread_plugin/src/models/sdk_error.dart';

/// Sealed class representing the outcome of a tire tread scan.
sealed class ScanOutcome {
  const ScanOutcome({required this.measurementUUID});

  factory ScanOutcome.fromMap(Map<String, dynamic> map) {
    final kind = map['kind'] as String? ?? '';
    final measurementUUID = map['measurementUUID'] as String?;

    switch (kind) {
      case 'ScanCompleted':
        return ScanCompleted(measurementUUID: measurementUUID ?? '');
      case 'ScanAborted':
        return ScanAborted(measurementUUID: measurementUUID);
      case 'ScanFailed':
        final rawError = map['error'];
        final errorMap = rawError == null
            ? null
            : Map<String, dynamic>.from(rawError as Map);
        return ScanFailed(
          measurementUUID: measurementUUID,
          error: errorMap != null
              ? SdkError.fromMap(errorMap)
              : const SdkError(
                  code: ErrorCode.unknownError,
                  type: ErrorType.scanError,
                  message: 'Unknown error',
                ),
        );
      default:
        return ScanFailed(
          measurementUUID: measurementUUID,
          error: const SdkError(
            code: ErrorCode.unknownError,
            type: ErrorType.scanError,
            message: 'Unknown scan outcome',
          ),
        );
    }
  }

  final String? measurementUUID;

  String get kind;
}

/// Scan completed successfully. [measurementUUID] is always non-null.
class ScanCompleted extends ScanOutcome {
  const ScanCompleted({required String super.measurementUUID});

  @override
  String get kind => 'ScanCompleted';

  @override
  String get measurementUUID => super.measurementUUID!;
}

/// Scan was aborted by the user. [measurementUUID] may be null.
class ScanAborted extends ScanOutcome {
  const ScanAborted({required super.measurementUUID});

  @override
  String get kind => 'ScanAborted';
}

/// Scan failed with an error. [measurementUUID] may be null.
class ScanFailed extends ScanOutcome {
  const ScanFailed({required super.measurementUUID, required this.error});

  final SdkError error;

  @override
  String get kind => 'ScanFailed';
}
