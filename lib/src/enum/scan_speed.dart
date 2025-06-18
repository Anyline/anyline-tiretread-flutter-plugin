// ignore_for_file: constant_identifier_names

/// The speed at which the tire tread scan should be performed.
enum ScanSpeed {
  /// Fast scan takes 7 seconds
  Fast,

  /// Slow scan takes 10 seconds
  Slow;

  @override
  String toString() => name;
}
