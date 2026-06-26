/// Error codes matching v15 TTR SDK.
enum ErrorCode {
  invalidLicense,
  licenseKeyForbidden,
  invalidArgument,
  initializationFailed,
  sdkNotInitialized,
  sdkNotVerified,
  sessionCreationFailed,
  alreadyRunning,
  cameraPermissionDenied,
  playServicesUnavailable,
  measurementError,
  invalidUuid,
  resultError,
  heatmapError,
  noConnection,
  uploadFailed,
  timeout,
  internalError,
  unknownError,
}

/// Error type categories matching v15 TTR SDK.
enum ErrorType {
  licenseError,
  configError,
  networkError,
  scanError,
  resultError,
}

/// Structured error from the TTR SDK v15.
class SdkError {
  const SdkError({
    required this.code,
    required this.type,
    required this.message,
    this.debug,
  });

  factory SdkError.fromMap(Map<String, dynamic> map) {
    return SdkError(
      code: _parseErrorCode(map['code'] as String? ?? ''),
      type: _parseErrorType(map['type'] as String? ?? ''),
      message: map['message'] as String? ?? '',
      debug: map['debug'] == null
          ? null
          : Map<String, dynamic>.from(map['debug'] as Map),
    );
  }

  final ErrorCode code;
  final ErrorType type;
  final String message;
  final Map<String, dynamic>? debug;

  Map<String, dynamic> toMap() => {
        'code': code.name,
        'type': type.name,
        'message': message,
        if (debug != null) 'debug': debug,
      };

  static final _codeMap = <String, ErrorCode>{
    'INVALID_LICENSE': ErrorCode.invalidLicense,
    'LICENSE_KEY_FORBIDDEN': ErrorCode.licenseKeyForbidden,
    'INVALID_ARGUMENT': ErrorCode.invalidArgument,
    'INITIALIZATION_FAILED': ErrorCode.initializationFailed,
    'SDK_NOT_INITIALIZED': ErrorCode.sdkNotInitialized,
    'SDK_NOT_VERIFIED': ErrorCode.sdkNotVerified,
    'SESSION_CREATION_FAILED': ErrorCode.sessionCreationFailed,
    'ALREADY_RUNNING': ErrorCode.alreadyRunning,
    'CAMERA_PERMISSION_DENIED': ErrorCode.cameraPermissionDenied,
    'PLAY_SERVICES_UNAVAILABLE': ErrorCode.playServicesUnavailable,
    'MEASUREMENT_ERROR': ErrorCode.measurementError,
    'INVALID_UUID': ErrorCode.invalidUuid,
    'RESULT_ERROR': ErrorCode.resultError,
    'HEATMAP_ERROR': ErrorCode.heatmapError,
    'NO_CONNECTION': ErrorCode.noConnection,
    'UPLOAD_FAILED': ErrorCode.uploadFailed,
    'TIMEOUT': ErrorCode.timeout,
    'INTERNAL_ERROR': ErrorCode.internalError,
    'UNKNOWN_ERROR': ErrorCode.unknownError,
  };

  static final _typeMap = <String, ErrorType>{
    'LICENSE_ERROR': ErrorType.licenseError,
    'CONFIG_ERROR': ErrorType.configError,
    'NETWORK_ERROR': ErrorType.networkError,
    'SCAN_ERROR': ErrorType.scanError,
    'RESULT_ERROR': ErrorType.resultError,
  };

  static ErrorCode _parseErrorCode(String raw) =>
      _codeMap[raw] ?? ErrorCode.unknownError;

  static ErrorType _parseErrorType(String raw) =>
      _typeMap[raw] ?? ErrorType.scanError;
}
