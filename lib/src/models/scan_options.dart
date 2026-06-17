/// Options controlling scan behavior (TTR SDK v15 `ScanOptions`).
///
/// Passed to the native SDK alongside the `scan` configuration. Mirrors the
/// SDK's `ScanOptions` shape: only non-null fields are serialized so the SDK
/// applies its own defaults.
class ScanOptions {
  /// Creates a new instance of [ScanOptions].
  ScanOptions({this.enableDebugLogging});

  /// Creates a [ScanOptions] from a JSON map.
  factory ScanOptions.fromJson(Map<String, dynamic> json) {
    return ScanOptions(
      enableDebugLogging: json['enableDebugLogging'] as bool?,
    );
  }

  /// Whether the SDK should emit verbose debug logging during the scan.
  ///
  /// Defaults to `false` in the SDK when not set.
  bool? enableDebugLogging;

  /// Converts these options to a JSON map, omitting unset fields.
  Map<String, dynamic> toJson() => {
        if (enableDebugLogging != null)
          'enableDebugLogging': enableDebugLogging,
      };
}
