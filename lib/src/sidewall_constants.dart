// ignore_for_file: constant_identifier_names

/// Method and argument keys for the `anyline_tire_sidewall_plugin` channel.
///
/// Kept separate from the tire-tread `Constants` because the Tire Sidewall
/// (TSW) scanner is a distinct product exposed over its own method channel.
class SidewallConstants {
  static const String METHOD_SCAN = 'METHOD_SIDEWALL_SCAN';
  static const String METHOD_IS_SUPPORTED = 'METHOD_SIDEWALL_IS_SUPPORTED';
  static const String METHOD_RESOLVE_PLAY_SERVICES =
      'METHOD_SIDEWALL_RESOLVE_PLAY_SERVICES';

  static const String EXTRA_CLIENT_ID = 'EXTRA_CLIENT_ID';
  static const String EXTRA_CONFIG_JSON = 'EXTRA_CONFIG_JSON';

  // Keys present in the outcome map returned by the native `scan` handler.
  static const String OUTCOME_KIND = 'kind';
  static const String OUTCOME_RESULT_JSON = 'resultJson';
  static const String OUTCOME_IMAGE_BYTES = 'imageBytes';
  static const String OUTCOME_ENVIRONMENT_LIGHTING = 'environmentLighting';
  static const String OUTCOME_ERROR = 'error';

  static const String KIND_COMPLETED = 'completed';
  static const String KIND_ABORTED = 'aborted';
  static const String KIND_FAILED = 'failed';

  // Keys present in the support-status map returned by `isSupported`.
  static const String SUPPORT_SUPPORTED = 'supported';
  static const String SUPPORT_USER_RESOLVABLE = 'userResolvable';
  static const String SUPPORT_ERROR = 'error';
}
