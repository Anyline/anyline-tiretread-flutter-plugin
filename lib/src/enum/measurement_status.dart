/// Processing status of a tire tread measurement, mirroring the SDK v15
/// `MeasurementStatus` enum.
enum MeasurementStatus {
  /// Status could not be determined.
  Unknown,

  /// The measurement is uploaded and waiting for images to be processed.
  WaitingForImages,

  /// The measurement is being processed.
  Processing,

  /// The tread-depth result is ready.
  ResultReady,

  /// Both the result and the report are ready.
  ResultAndReportReady,

  /// The measurement completed.
  Completed,

  /// The measurement was aborted.
  Aborted,

  /// The measurement failed.
  Failed;

  /// Parses an SDK status string into a [MeasurementStatus].
  ///
  /// Matching is case-insensitive against the SDK's constant names; any
  /// unrecognized value maps to [Unknown] rather than throwing.
  static MeasurementStatus fromString(String value) {
    final normalized = value.toLowerCase();
    return MeasurementStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => MeasurementStatus.Unknown,
    );
  }
}
