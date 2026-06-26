import 'package:anyline_tire_tread_plugin/src/models/sdk_error.dart';
import 'package:anyline_tire_tread_plugin/src/sidewall_constants.dart';

/// Result of `TireSidewallPlugin.isSupported`.
///
/// Mirrors the SDK's `TswSupportStatus`:
/// - [supported] is `true` when the device can run the sidewall scanner.
/// - When `false`, [error] explains why and [userResolvable] indicates whether
///   the user can fix it (e.g. install/update Google Play Services on Android).
///   On a user-resolvable failure, call `TireSidewallPlugin.resolvePlayServices`.
class TireSidewallSupport {
  const TireSidewallSupport({
    required this.supported,
    this.userResolvable = false,
    this.error,
  });

  factory TireSidewallSupport.fromMap(Map<String, dynamic> map) {
    final rawError = map[SidewallConstants.SUPPORT_ERROR];
    return TireSidewallSupport(
      supported: map[SidewallConstants.SUPPORT_SUPPORTED] as bool? ?? false,
      userResolvable:
          map[SidewallConstants.SUPPORT_USER_RESOLVABLE] as bool? ?? false,
      error: rawError == null
          ? null
          : SdkError.fromMap(Map<String, dynamic>.from(rawError as Map)),
    );
  }

  final bool supported;
  final bool userResolvable;
  final SdkError? error;
}
