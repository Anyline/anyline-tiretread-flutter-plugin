/// Centralized error messages for the Anyline Tire Tread Plugin.
/// This class contains all error messages used across Android and iOS implementations
/// to ensure consistency and reduce string repetition.
class ErrorMessages {
  // Parameter validation errors
  static const String licenseKeyNotFound = "License key parameter not found";
  static const String uuidNotFound = "uuid parameter not found";
  static const String commentNotFound = "comment parameter not found";
  static const String regionsNotFound = "regions parameter not found";
  static const String experimentalFlagsNull = "Experimental flags are null";

  // SDK initialization errors
  static const String sdkInitializationFailed =
      "Tire Tread SDK could not be initialized";
  static const String pluginNotAttachedToActivity =
      "Plugin is not attached to main activity";

  // Scan errors
  static const String scanCancelled = "Scan was cancelled";
  static const String scanAborted = "Scan Aborted";
  static const String uploadAborted = "Upload Aborted";
  static const String measurementError = "Measurement Error";

  // Result retrieval errors
  static const String unableToGetTreadDepthResult =
      "Unable to get tread depth result: ";
  static const String unableToGetHeatmapResult =
      "Unable to get heatmap result: ";
  static const String getMeasurementResultError = "GetMeasurementResult Error";
  static const String getHeatMapResultError = "GetHeatMapResult Error";

  // JSON processing errors
  static const String errorEncodingRegionsString =
      "Error encoding regions string";
  static const String errorEncodingJsonData = "Error encoding JSON data";
  static const String errorDeserializingJson = "Error deserializing JSON: ";

  // Generic errors
  static const String unknownError = "Unknown error";
  static const String unknownException = "Unknown exception";
  static const String genericException = "Generic exception occurred";

  // Exception details
  static const String licenseKeyForbidden = "License key forbidden";
  static const String invalidLicenseKey = "Invalid license key";
  static const String noConnection = "No connection";

  /// Creates a formatted error message for JSON deserialization errors
  static String jsonDeserializationError(String error) =>
      "$errorDeserializingJson$error";

  /// Creates a formatted error message for tread depth result errors
  static String treadDepthResultError(String exception) =>
      "$unableToGetTreadDepthResult$exception";

  /// Creates a formatted error message for heatmap result errors
  static String heatmapResultError(String exception) =>
      "$unableToGetHeatmapResult$exception";
}
