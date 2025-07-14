package io.anyline.tiretread.flutter

object Constants {
    const val METHOD_INITIALIZE = "METHOD_INITIALIZE"
    const val METHOD_GET_SDK_VERSION = "METHOD_GET_SDK_VERSION"
    const val METHOD_SCAN = "METHOD_SCAN"
    const val METHOD_GET_RESULT = "METHOD_GET_RESULT"
    const val METHOD_GET_HEATMAP = "METHOD_GET_HEATMAP"
    const val METHOD_SEND_FEEDBACK_COMMENT = "METHOD_SEND_FEEDBACK_COMMENT"
    const val METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK = "METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK"
    const val METHOD_SET_EXPERIMENTAL_FLAGS = "METHOD_SET_EXPERIMENTAL_FLAGS"
    const val METHOD_CLEAR_EXPERIMENTAL_FLAGS = "METHOD_CLEAR_EXPERIMENTAL_FLAGS"

    const val EXTRA_LICENSE_KEY = "EXTRA_LICENSE_KEY"
    const val EXTRA_MEASUREMENT_UUID = "EXTRA_MEASUREMENT_UUID";
    const val EXTRA_PLUGIN_VERSION = "EXTRA_PLUGIN_VERSION";
    const val EXTRA_FEEDBACK_COMMENT = "EXTRA_FEEDBACK_COMMENT";
    const val EXTRA_TREAD_DEPTH_RESULT_FEEDBACK = "EXTRA_TREAD_DEPTH_RESULT_FEEDBACK";
    const val EXTRA_EXPERIMENTAL_FLAGS = "EXTRA_EXPERIMENTAL_FLAGS";

    const val ERROR_CODE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY = "1000"
    const val ERROR_CODE_SDK_INITIALIZATION_FAILED = "1001"
    const val ERROR_CODE_GENERIC_EXCEPTION = "1003"

    // MARK: - Error Messages
    const val ERROR_MESSAGE_LICENSE_KEY_NOT_FOUND = "License key parameter not found"
    const val ERROR_MESSAGE_UUID_NOT_FOUND = "uuid parameter not found"
    const val ERROR_MESSAGE_COMMENT_NOT_FOUND = "comment parameter not found"
    const val ERROR_MESSAGE_REGIONS_NOT_FOUND = "regions parameter not found"
    const val ERROR_MESSAGE_EXPERIMENTAL_FLAGS_NULL = "Experimental flags are null"
    const val ERROR_MESSAGE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY = "Plugin is not attached to main activity"
    const val ERROR_MESSAGE_SDK_INITIALIZATION_FAILED = "Tire Tread SDK could not be initialized"
    const val ERROR_MESSAGE_SCAN_CANCELLED = "Scan was cancelled"
    const val ERROR_MESSAGE_UNKNOWN_ERROR = "Unknown error"
    const val ERROR_MESSAGE_UNKNOWN_EXCEPTION = "Unknown exception"
    const val ERROR_MESSAGE_UNABLE_TO_GET_TREAD_DEPTH_RESULT = "Unable to get tread depth result: "
    const val ERROR_MESSAGE_UNABLE_TO_GET_HEATMAP_RESULT = "Unable to get heatmap result: "
    const val ERROR_MESSAGE_ENCODING_REGIONS_STRING = "Error encoding regions string"
    const val ERROR_MESSAGE_ENCODING_JSON_DATA = "Error encoding JSON data"
    const val ERROR_MESSAGE_DESERIALIZING_JSON = "Error deserializing JSON: "
    const val ERROR_MESSAGE_LICENSE_KEY_FORBIDDEN = "License key forbidden"
    const val ERROR_MESSAGE_INVALID_LICENSE_KEY = "Invalid license key"
    const val ERROR_MESSAGE_NO_CONNECTION = "No connection"

}
