import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_texts.dart';

/// Configuration for a Tire Sidewall (TSW) scan.
///
/// Mirrors the SDK's `TswScannerConfig`. Construct one, override only what you
/// need, and pass it to `TireSidewallPlugin.scan`. UI strings live under
/// [texts]; scan-level inputs (such as [correlationId]) sit at the top level.
///
/// ```dart
/// final config = TireSidewallConfig()
///   ..correlationId = myWorkflowId // version-4 UUID
///   ..texts = (TireSidewallTexts()..alignTire = 'Align the tire');
/// ```
class TireSidewallConfig {
  /// Localizable UI strings shown by the scanner overlay.
  TireSidewallTexts texts = TireSidewallTexts();

  /// Optional ID to correlate scans across Anyline products (e.g. Tire
  /// Sidewall and Tire Tread). Must be a version-4 UUID when set; leave `null`
  /// to send none. An invalid value fails the scan with
  /// `ErrorCode.invalidUuid`.
  String? correlationId;

  Map<String, dynamic> toJson() {
    final textsJson = texts.toJson();
    return {
      if (textsJson.isNotEmpty) 'texts': textsJson,
      if (correlationId != null) 'correlationId': correlationId,
    };
  }
}
