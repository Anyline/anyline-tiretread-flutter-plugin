/// Direction the device moved across the tire during a scan, mirroring the
/// SDK v15 `MovementDirection` enum.
enum MovementDirection {
  /// Movement direction could not be determined.
  Unknown,

  /// The device moved from left to right across the tire.
  LeftToRight,

  /// The device moved from right to left across the tire.
  RightToLeft;

  /// Parses an SDK movement-direction string into a [MovementDirection].
  ///
  /// Matching is case-insensitive against the SDK's constant names; any
  /// unrecognized value maps to [Unknown] rather than throwing.
  static MovementDirection fromString(String value) {
    final normalized = value.toLowerCase();
    return MovementDirection.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => MovementDirection.Unknown,
    );
  }
}
