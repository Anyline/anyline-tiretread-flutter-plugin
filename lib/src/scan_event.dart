abstract class ScanEvent {
  const ScanEvent({required this.measurementUUID});

  final String? measurementUUID;

  Map<String, dynamic> toMap() => {'measurementUUID': measurementUUID};
}

class ScanAborted extends ScanEvent {
  const ScanAborted({required super.measurementUUID});

  factory ScanAborted.fromMap(Map<String, dynamic> map) =>
      ScanAborted(measurementUUID: map['measurementUUID'] as String?);
}

class ScanStarted extends ScanEvent {
  const ScanStarted({required super.measurementUUID});

  factory ScanStarted.fromMap(Map<String, dynamic> map) =>
      ScanStarted(measurementUUID: map['measurementUUID'] as String);
}

class ScanProcessCompleted extends ScanEvent {
  const ScanProcessCompleted({required super.measurementUUID});

  factory ScanProcessCompleted.fromMap(Map<String, dynamic> map) =>
      ScanProcessCompleted(measurementUUID: map['measurementUUID'] as String);
}

class ScanFailed extends ScanEvent {
  factory ScanFailed.fromMap(Map<String, dynamic> map) => ScanFailed(
      measurementUUID: map['measurementUUID'] as String,
      error: map['error'] as String);

  const ScanFailed({required super.measurementUUID, required this.error});

  final String error;
}
