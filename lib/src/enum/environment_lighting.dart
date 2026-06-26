/// Ambient lighting condition detected during a sidewall scan.
///
/// Mirrors the SDK's `EnvironmentLighting` enum. Reported as telemetry on the
/// captured frame; it is not a prediction input.
enum EnvironmentLighting {
  /// The environment was too dark for an ideal capture.
  Dark,

  /// The environment was too bright for an ideal capture.
  Bright,

  /// The lighting was suitable for capture.
  Good;

  /// Parses the SDK enum name (e.g. `"Dark"`), returning `null` for an unknown
  /// or absent value.
  static EnvironmentLighting? fromName(String? name) {
    if (name == null) return null;
    for (final value in EnvironmentLighting.values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
