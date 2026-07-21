import 'dart:typed_data';

import 'package:anyline_tire_tread_plugin/src/enum/environment_lighting.dart';
import 'package:anyline_tire_tread_plugin/src/models/sdk_error.dart';
import 'package:anyline_tire_tread_plugin/src/sidewall_constants.dart';

/// Outcome of a Tire Sidewall (TSW) scan, delivered once when
/// `TireSidewallPlugin.scan` completes.
///
/// Mirrors the SDK's `TswScanResult` sealed type.
sealed class TswScanOutcome {
  const TswScanOutcome();

  factory TswScanOutcome.fromMap(Map<String, dynamic> map) {
    final kind = map[SidewallConstants.OUTCOME_KIND] as String? ?? '';
    switch (kind) {
      case SidewallConstants.KIND_COMPLETED:
        return TswScanCompleted(
          resultJson:
              map[SidewallConstants.OUTCOME_RESULT_JSON] as String? ?? '',
          imageBytes: _asBytes(map[SidewallConstants.OUTCOME_IMAGE_BYTES]),
          lighting: EnvironmentLighting.fromName(
              map[SidewallConstants.OUTCOME_ENVIRONMENT_LIGHTING] as String?),
        );
      case SidewallConstants.KIND_ABORTED:
        return const TswScanAborted();
      case SidewallConstants.KIND_FAILED:
        final rawError = map[SidewallConstants.OUTCOME_ERROR];
        return TswScanFailed(
          error: rawError == null
              ? const SdkError(
                  code: ErrorCode.unknownError,
                  type: ErrorType.scanError,
                  message: 'Unknown error',
                )
              : SdkError.fromMap(Map<String, dynamic>.from(rawError as Map)),
        );
      default:
        return const TswScanFailed(
          error: SdkError(
            code: ErrorCode.unknownError,
            type: ErrorType.scanError,
            message: 'Unknown sidewall scan outcome',
          ),
        );
    }
  }

  String get kind;

  /// Coerces the platform-channel byte payload (Android `byte[]` / iOS
  /// `FlutterStandardTypedData`, both surfaced as [Uint8List]) into a
  /// [Uint8List], tolerating a generic `List<int>` just in case.
  static Uint8List _asBytes(Object? raw) {
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return Uint8List(0);
  }
}

/// Scan succeeded. Carries the raw cloud result JSON, the captured (upright)
/// image bytes, and the ambient [lighting] at capture time.
class TswScanCompleted extends TswScanOutcome {
  const TswScanCompleted({
    required this.resultJson,
    required this.imageBytes,
    this.lighting,
  });

  /// The cloud response for the sidewall scan, as a raw JSON string. Parse it
  /// in your app; a typed model may be added once the response schema is final.
  final String resultJson;

  /// The captured sidewall image, re-encoded upright for naive decoders.
  final Uint8List imageBytes;

  /// Ambient lighting detected for the captured frame, or `null` if unavailable.
  final EnvironmentLighting? lighting;

  @override
  String get kind => SidewallConstants.KIND_COMPLETED;
}

/// User aborted before capture.
class TswScanAborted extends TswScanOutcome {
  const TswScanAborted();

  @override
  String get kind => SidewallConstants.KIND_ABORTED;
}

/// Scan failed. Carries a typed [SdkError].
class TswScanFailed extends TswScanOutcome {
  const TswScanFailed({required this.error});

  final SdkError error;

  @override
  String get kind => SidewallConstants.KIND_FAILED;
}
