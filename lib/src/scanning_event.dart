abstract class ScanEvent {
  const ScanEvent({required this.measurementUUID});

  final String? measurementUUID;

  Map<String, dynamic> toMap() => {'measurementUUID': measurementUUID};
}

class ScanAborted extends ScanEvent {
  const ScanAborted({required super.measurementUUID});

  factory ScanAborted.fromMap(Map<String, dynamic> map) =>
      ScanAborted(measurementUUID: map['measurementUUID'] as String);
}

class UploadAborted extends ScanEvent {
  const UploadAborted({required super.measurementUUID});

  factory UploadAborted.fromMap(Map<String, dynamic> map) =>
      UploadAborted(measurementUUID: map['measurementUUID'] as String);
}

class UploadCompleted extends ScanEvent {
  const UploadCompleted({required super.measurementUUID});

  factory UploadCompleted.fromMap(Map<String, dynamic> map) =>
      UploadCompleted(measurementUUID: map['measurementUUID'] as String);
}

class UploadFailed extends ScanEvent {
  factory UploadFailed.fromMap(Map<String, dynamic> map) => UploadFailed(
      measurementUUID: map['measurementUUID'] as String,
      error: map['error'] as String);

  const UploadFailed({required super.measurementUUID, required this.error});

  final String error;
}
