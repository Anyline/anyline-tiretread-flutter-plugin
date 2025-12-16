/// Combination of UI and haptic feedback that should be used.
enum Appearance {
  /// No UI elements or haptic feedback displayed.
  None,

  /// Classic UI appearance with haptic feedback.
  Classic,

  /// Neon UI appearance with haptic feedback (default).
  Neon;

  @override
  String toString() => name;
}
