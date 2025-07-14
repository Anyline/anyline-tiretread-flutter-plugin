import Foundation

struct Constants {
    // MARK: - Method Names
    static let METHOD_GET_SDK_VERSION: String = "METHOD_GET_SDK_VERSION"
    static let METHOD_INITIALIZE: String = "METHOD_INITIALIZE"
    static let METHOD_SCAN: String = "METHOD_SCAN"
    static let METHOD_GET_RESULT: String = "METHOD_GET_RESULT"
    static let METHOD_GET_HEATMAP: String = "METHOD_GET_HEATMAP"
    static let METHOD_SEND_FEEDBACK_COMMENT: String = "METHOD_SEND_FEEDBACK_COMMENT"
    static let METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK: String = "METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK"
    static let METHOD_SET_EXPERIMENTAL_FLAGS: String = "METHOD_SET_EXPERIMENTAL_FLAGS"
    static let METHOD_CLEAR_EXPERIMENTAL_FLAGS: String = "METHOD_CLEAR_EXPERIMENTAL_FLAGS"

    // MARK: - Argument Keys
    static let EXTRA_MEASUREMENT_UUID: String = "EXTRA_MEASUREMENT_UUID"
    static let EXTRA_LICENSE_KEY: String = "EXTRA_LICENSE_KEY"
    static let EXTRA_PLUGIN_VERSION: String = "EXTRA_PLUGIN_VERSION"
    static let EXTRA_FEEDBACK_COMMENT: String = "EXTRA_FEEDBACK_COMMENT"
    static let EXTRA_TREAD_DEPTH_RESULT_FEEDBACK: String = "EXTRA_TREAD_DEPTH_RESULT_FEEDBACK"

    // MARK: - Error Codes
    static let ERROR_CODE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY: String = "1000"
    static let ERROR_CODE_SDK_INITIALIZATION_FAILED: String = "1001"
    static let ERROR_CODE_GENERIC_EXCEPTION: String = "1003"
    
    // MARK: - Error Messages
    static let ERROR_MESSAGE_LICENSE_KEY_NOT_FOUND: String = "License key parameter not found"
    static let ERROR_MESSAGE_UUID_NOT_FOUND: String = "uuid parameter not found"
    static let ERROR_MESSAGE_COMMENT_NOT_FOUND: String = "comment parameter not found"
    static let ERROR_MESSAGE_REGIONS_NOT_FOUND: String = "regions parameter not found"
    static let ERROR_MESSAGE_EXPERIMENTAL_FLAGS_NULL: String = "Experimental flags are null"
    static let ERROR_MESSAGE_PLUGIN_NOT_ATTACHED_TO_ACTIVITY: String = "Plugin is not attached to main activity"
    static let ERROR_MESSAGE_SDK_INITIALIZATION_FAILED: String = "Tire Tread SDK could not be initialized"
    static let ERROR_MESSAGE_SCAN_CANCELLED: String = "Scan was cancelled"
    static let ERROR_MESSAGE_UNKNOWN_ERROR: String = "Unknown error"
    static let ERROR_MESSAGE_UNKNOWN_EXCEPTION: String = "Unknown exception"
    static let ERROR_MESSAGE_UNABLE_TO_GET_TREAD_DEPTH_RESULT: String = "Unable to get tread depth result: "
    static let ERROR_MESSAGE_UNABLE_TO_GET_HEATMAP_RESULT: String = "Unable to get heatmap result: "
    static let ERROR_MESSAGE_ENCODING_REGIONS_STRING: String = "Error encoding regions string"
    static let ERROR_MESSAGE_ENCODING_JSON_DATA: String = "Error encoding JSON data"
    static let ERROR_MESSAGE_DESERIALIZING_JSON: String = "Error deserializing JSON: "
    static let ERROR_MESSAGE_LICENSE_KEY_FORBIDDEN: String = "License key forbidden"
    static let ERROR_MESSAGE_INVALID_LICENSE_KEY: String = "Invalid license key"
    static let ERROR_MESSAGE_NO_CONNECTION: String = "No connection"
}
