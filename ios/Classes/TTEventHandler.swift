import Flutter
import Foundation

/**
 * Unified Event Handler for Tire Tread Plugin events
 * 
 * This class provides a centralized way to send events to the Flutter layer,
 * maintaining consistency with the Android implementation.
 */
public class TTEventHandler: NSObject, FlutterStreamHandler {
    
    public static let shared = TTEventHandler()
    
    private var eventSink: FlutterEventSink?
    
    /**
     * Send an event to the Flutter layer as a dictionary
     * 
     * @param type The event type (e.g., "ScanStarted", "ScanCompleted", "ScanAborted", "ScanFailed")
     * @param uuid The measurement UUID associated with the event (optional)
     * @param error Error message if applicable (optional)
     */
    public func sendEvent(type: String, uuid: String? = nil, error: String? = nil) {
        let eventDict: [String: Any] = [
            "type": type,
            "uuid": uuid ?? "",
            "error": error ?? ""
        ]
        print("TTEventHandler: Sending event: \(eventDict)")
        self.eventSink?(eventDict)
    }
    
    // MARK: - FlutterStreamHandler implementation
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        
        self.eventSink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
} 