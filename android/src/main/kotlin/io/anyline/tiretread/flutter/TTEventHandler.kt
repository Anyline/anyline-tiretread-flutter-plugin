package io.anyline.tiretread.flutter

import io.flutter.plugin.common.EventChannel

/**
 * Unified Event Handler for Tire Tread Plugin events
 * 
 * This class provides a centralized way to send events to the Flutter layer,
 * maintaining consistency with the iOS implementation.
 */
class TTEventHandler private constructor() : EventChannel.StreamHandler {
    
    companion object {
        @JvmStatic
        val shared = TTEventHandler()
    }
    
    private var eventSink: EventChannel.EventSink? = null
    
    /**
     * Send an event to the Flutter layer as a map
     * 
     * @param type The event type (e.g., "ScanStarted", "ScanCompleted", "ScanAborted", "ScanFailed")
     * @param uuid The measurement UUID associated with the event (optional)
     * @param error Error message if applicable (optional)
     */
    fun sendEvent(type: String, uuid: String? = null, error: String? = null) {
        val eventMap = mapOf(
            "type" to type,
            "uuid" to (uuid ?: ""),
            "error" to (error ?: "")
        )
        android.util.Log.d("TTEventHandler", "Sending event: $eventMap")
        eventSink?.success(eventMap)
    }
    
    // EventChannel.StreamHandler implementation
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}