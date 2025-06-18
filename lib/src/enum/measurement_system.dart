// ignore_for_file: constant_identifier_names

/// The measurement system to be displayed.
enum MeasurementSystem {
  /// Metric system (millimeters)
  Metric,

  /// Imperial system (inches)
  Imperial;

  @override
  String toString() => name;
}
