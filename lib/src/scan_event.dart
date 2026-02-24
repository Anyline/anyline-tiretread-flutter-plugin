/// Base class for all tire scanning events.
///
/// Events are emitted during the scanning process to communicate
/// progress, completion, or errors to the application.
abstract class ScanEvent {
  /// Creates a new scan event with the associated measurement UUID.
  const ScanEvent({required this.measurementUUID});

  /// Unique identifier for the measurement associated with this event.
  final String? measurementUUID;

  /// Converts this event to a map representation.
  Map<String, dynamic> toMap() => {'measurementUUID': measurementUUID};
}

/// Event emitted when the user cancels the scanning process.
///
/// This event is fired when the user explicitly aborts the scan
/// before completion, typically by pressing a cancel or back button.
class ScanAborted extends ScanEvent {
  /// Creates a new [ScanAborted] event.
  const ScanAborted({required super.measurementUUID});

  /// Creates a [ScanAborted] event from a map.
  factory ScanAborted.fromMap(Map<String, dynamic> map) =>
      ScanAborted(measurementUUID: map['measurementUUID'] as String?);
}

/// Event emitted when tire scanning begins.
///
/// This event is fired when the scanning process successfully starts
/// and provides the measurement UUID that will be used for this scan.
class ScanStarted extends ScanEvent {
  /// Creates a new [ScanStarted] event.
  const ScanStarted({required super.measurementUUID});

  /// Creates a [ScanStarted] event from a map.
  factory ScanStarted.fromMap(Map<String, dynamic> map) =>
      ScanStarted(measurementUUID: map['measurementUUID'] as String);
}

/// Event emitted when the scanning process completes successfully.
///
/// This event indicates that the tire scan has finished and results
/// are available for retrieval using the provided measurement UUID.
class ScanProcessCompleted extends ScanEvent {
  /// Creates a new [ScanProcessCompleted] event.
  const ScanProcessCompleted({required super.measurementUUID});

  /// Creates a [ScanProcessCompleted] event from a map.
  factory ScanProcessCompleted.fromMap(Map<String, dynamic> map) =>
      ScanProcessCompleted(measurementUUID: map['measurementUUID'] as String);
}

/// Event emitted when the scanning process fails due to an error.
///
/// This event provides both the measurement UUID and a descriptive
/// error message explaining why the scan failed.
class ScanFailed extends ScanEvent {
  /// Creates a [ScanFailed] event from a map.
  factory ScanFailed.fromMap(Map<String, dynamic> map) => ScanFailed(
      measurementUUID: map['measurementUUID'] as String,
      error: map['error'] as String);

  /// Creates a new [ScanFailed] event.
  const ScanFailed({required super.measurementUUID, required this.error});

  /// Error message describing why the scan failed.
  final String error;
}
