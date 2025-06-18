import 'package:anyline_tire_tread_plugin/src/models/additional_context.dart';
import 'package:anyline_tire_tread_plugin/src/models/scan_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/ui_config.dart';
import 'package:flutter/foundation.dart';

/// Configuration for tire tread scanning, including UI configuration.
/// This class wraps the TireTreadConfig from the native SDK.
class TireTreadConfig {
  /// Creates a new instance of [TireTreadConfig].
  TireTreadConfig();

  /// Creates a [TireTreadConfig] instance from a JSON object.
  factory TireTreadConfig.fromJson(Map<String, dynamic> json) {
    final config = TireTreadConfig();

    // Handle scanConfig
    try {
      if (json['scanConfig'] != null) {
        config.scanConfig =
            ScanConfig.fromJson(json['scanConfig'] as Map<String, dynamic>);
      } else {
        config.scanConfig = ScanConfig();
      }
    } catch (e) {
      debugPrint('Warning: Failed to parse scanConfig, using default: $e');
      config.scanConfig = ScanConfig();
    }

    // Handle additionalContext
    try {
      if (json['additionalContext'] != null) {
        config.additionalContext = AdditionalContext.fromJson(
            json['additionalContext'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Warning: Failed to parse additionalContext: $e');
    }

    // Handle uiConfig
    if (json['uiConfig'] != null) {
      try {
        config.uiConfig =
            UiConfig.fromJson(json['uiConfig'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Warning: Failed to parse uiConfig: $e');
      }
    }

    return config;
  }

  /// Configuration for the scanning process.
  ScanConfig scanConfig = ScanConfig();

  /// Additional context for the scan.
  AdditionalContext? additionalContext;

  /// UI configuration settings.
  UiConfig? uiConfig;

  /// Converts the [TireTreadConfig] instance to a JSON object.
  Map<String, dynamic> toJson() {
    final json = {
      'scanConfig': scanConfig.toJson(),
      if (additionalContext != null)
        'additionalContext': additionalContext?.toJson(),
      if (uiConfig != null) 'uiConfig': uiConfig?.toJson(),
    };
    return json;
  }
}
