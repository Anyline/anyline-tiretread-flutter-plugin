/// Combination of UI and haptic feedback that should be used.
///
/// Mirrors the SDK's `Appearance` enum, which defines only [Classic] and
/// [Neon]. There is intentionally no `None` value: sending one would not match
/// any SDK case and the SDK would silently fall back to its default ([Neon]).
enum Appearance {
  /// Classic UI appearance with haptic feedback.
  Classic,

  /// Neon UI appearance with haptic feedback (default).
  Neon;

  @override
  String toString() => name;
}
