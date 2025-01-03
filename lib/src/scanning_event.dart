abstract class ScanningEvent {
  const ScanningEvent({required this.measurementUUID});

  final String? measurementUUID;

  Map<String, dynamic> toMap() => {'measurementUUID': measurementUUID};
}

class ScanningAborted extends ScanningEvent {
  const ScanningAborted({required super.measurementUUID});

  factory ScanningAborted.fromMap(Map<String, dynamic> map) => ScanningAborted(
        measurementUUID: map['measurementUUID'] as String,
      );
}

class UploadAbortedEvent extends ScanningEvent {
  const UploadAbortedEvent({required super.measurementUUID});

  factory UploadAbortedEvent.fromMap(Map<String, dynamic> map) =>
      UploadAbortedEvent(measurementUUID: map['measurementUUID'] as String);
}

class UploadCompletedEvent extends ScanningEvent {
  const UploadCompletedEvent({required super.measurementUUID});

  factory UploadCompletedEvent.fromMap(Map<String, dynamic> map) =>
      UploadCompletedEvent(measurementUUID: map['measurementUUID'] as String);
}

class UploadFailedEvent extends ScanningEvent {
  factory UploadFailedEvent.fromMap(Map<String, dynamic> map) => UploadFailedEvent(
        measurementUUID: map['measurementUUID'] as String,
        error: map['error'] as String,
      );

  const UploadFailedEvent({
    required super.measurementUUID,
    required this.error,
  });

  final String error;
}
