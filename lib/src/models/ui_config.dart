import 'package:anyline_tire_tread_plugin/src/enum/appearance.dart';
import 'package:anyline_tire_tread_plugin/src/enum/measurement_system.dart';
import 'package:anyline_tire_tread_plugin/src/enum/scan_speed.dart';

/// Configuration for the distance indicator UI element.
///
/// The distance indicator guides users to maintain the optimal distance
/// from the tire during scanning by displaying contextual text messages.
class DistanceIndicatorConfig {
  /// Creates a new instance of [DistanceIndicatorConfig].
  DistanceIndicatorConfig();

  /// Creates a [DistanceIndicatorConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the distance indicator is visible
  /// - `textOk`: Text shown when distance is correct
  /// - `textMoveCloser`: Text shown when user should move closer
  /// - `textMoveAway`: Text shown when user should move away
  factory DistanceIndicatorConfig.fromJson(Map<String, dynamic> json) {
    final config = DistanceIndicatorConfig();
    config.visible = json['visible'] as bool?;
    config.textOk = json['textOk'] as String?;
    config.textMoveCloser = json['textMoveCloser'] as String?;
    config.textMoveAway = json['textMoveAway'] as String?;
    return config;
  }

  /// Whether the distance indicator UI element is visible during scanning.
  bool? visible;

  /// Text displayed when the distance from the tire is optimal for scanning.
  String? textOk;

  /// Text displayed when the user needs to move closer to the tire.
  String? textMoveCloser;

  /// Text displayed when the user needs to move away from the tire.
  String? textMoveAway;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (textOk != null) map['textOk'] = textOk;
    if (textMoveCloser != null) map['textMoveCloser'] = textMoveCloser;
    if (textMoveAway != null) map['textMoveAway'] = textMoveAway;
    return map;
  }
}

/// Configuration for the focus point tooltip UI element.
///
/// The focus point tooltip helps users align the tire correctly
/// within the scanning frame by highlighting the target focus area.
class FocusPointTooltipConfig {
  /// Creates a new instance of [FocusPointTooltipConfig].
  FocusPointTooltipConfig();

  /// Creates a [FocusPointTooltipConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the focus point tooltip is visible
  /// - `smallText`: Small text displayed in the tooltip
  /// - `text`: Main text displayed in the tooltip
  factory FocusPointTooltipConfig.fromJson(Map<String, dynamic> json) {
    final config = FocusPointTooltipConfig();
    config.visible = json['visible'] as bool?;
    config.smallText = json['smallText'] as String?;
    config.text = json['text'] as String?;
    return config;
  }

  /// Whether the focus point tooltip is visible during scanning.
  bool? visible;

  /// Small supplementary text displayed in the tooltip.
  String? smallText;

  /// Main instructional text displayed in the tooltip.
  String? text;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (smallText != null) map['smallText'] = smallText;
    if (text != null) map['text'] = text;
    return map;
  }
}

/// Configuration for the tap to start scanning tooltip UI element.
///
/// This tooltip appears before scanning begins and instructs users
/// to tap the screen when they are ready to start the tire scan.
class TapToStartScanningTooltipConfig {
  /// Creates a new instance of [TapToStartScanningTooltipConfig].
  TapToStartScanningTooltipConfig();

  /// Creates a [TapToStartScanningTooltipConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the tooltip is visible
  /// - `textOk`: Text shown when tire width is known
  /// - `textNotOkMetric`: Text shown when tire width unknown (metric)
  /// - `textNotOkImperial`: Text shown when tire width unknown (imperial)
  factory TapToStartScanningTooltipConfig.fromJson(Map<String, dynamic> json) {
    final config = TapToStartScanningTooltipConfig();
    config.visible = json['visible'] as bool?;
    config.textOk = json['textOk'] as String?;
    config.textNotOkMetric = json['textNotOkMetric'] as String?;
    config.textNotOkImperial = json['textNotOkImperial'] as String?;
    return config;
  }

  /// Whether the tap to start scanning tooltip is visible.
  bool? visible;

  /// Text displayed when the tire width is already known.
  String? textOk;

  /// Text displayed when tire width is unknown and metric system is used.
  String? textNotOkMetric;

  /// Text displayed when tire width is unknown and imperial system is used.
  String? textNotOkImperial;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (textOk != null) map['textOk'] = textOk;
    if (textNotOkMetric != null) map['textNotOkMetric'] = textNotOkMetric;
    if (textNotOkImperial != null) map['textNotOkImperial'] = textNotOkImperial;
    return map;
  }
}

/// Configuration for the tire overlay UI element.
///
/// The tire overlay shows a visual outline or guide that helps users
/// position the tire correctly within the scanning frame.
class TireOverlayConfig {
  /// Creates a new instance of [TireOverlayConfig].
  TireOverlayConfig();

  /// Creates a [TireOverlayConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the tire overlay is visible
  factory TireOverlayConfig.fromJson(Map<String, dynamic> json) {
    final config = TireOverlayConfig();
    config.visible = json['visible'] as bool?;
    return config;
  }

  /// Whether the tire overlay guide is visible during scanning.
  bool? visible;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    return map;
  }
}

/// Configuration for the upload view UI element.
///
/// The upload view is displayed during the processing phase when
/// scan data is being uploaded and analyzed.
class UploadViewConfig {
  /// Creates a new instance of [UploadViewConfig].
  UploadViewConfig();

  /// Creates a [UploadViewConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the upload view is visible
  /// - `text`: Text displayed during upload
  factory UploadViewConfig.fromJson(Map<String, dynamic> json) {
    final config = UploadViewConfig();
    config.visible = json['visible'] as bool?;
    config.text = json['text'] as String?;
    return config;
  }

  /// Whether the upload view is displayed during processing.
  bool? visible;

  /// Text message shown to the user during the upload process.
  String? text;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (text != null) map['text'] = text;
    return map;
  }
}

/// Configuration for the orientation warning UI element.
///
/// Displays a warning message when the device orientation is incorrect
/// for scanning (e.g., device should be held in landscape mode).
class OrientationWarningConfig {
  /// Creates a new instance of [OrientationWarningConfig].
  OrientationWarningConfig();

  /// Creates an [OrientationWarningConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the orientation warning is visible
  /// - `text`: Main warning text
  /// - `rotationLockHint`: Hint about device rotation lock
  factory OrientationWarningConfig.fromJson(Map<String, dynamic> json) {
    final config = OrientationWarningConfig();
    config.visible = json['visible'] as bool?;
    config.text = json['text'] as String?;
    config.rotationLockHint = json['rotationLockHint'] as String?;
    return config;
  }

  /// Whether the orientation warning is displayed when orientation is wrong.
  bool? visible;

  /// Main text of the orientation warning message.
  String? text;

  /// Additional hint about disabling device rotation lock.
  String? rotationLockHint;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (text != null) map['text'] = text;
    if (rotationLockHint != null) map['rotationLockHint'] = rotationLockHint;
    return map;
  }
}

/// Configuration for the countdown UI element.
///
/// Displays a countdown timer before scanning begins, giving users
/// time to prepare and position the device correctly.
class CountdownConfig {
  /// Creates a new instance of [CountdownConfig].
  CountdownConfig();

  /// Creates a [CountdownConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the countdown is displayed
  factory CountdownConfig.fromJson(Map<String, dynamic> json) {
    final config = CountdownConfig();
    config.visible = json['visible'] as bool?;
    return config;
  }

  /// Whether the countdown timer is displayed before scanning starts.
  bool? visible;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    return map;
  }
}

/// Configuration for the scan direction UI element.
///
/// Shows visual guidance indicating the direction in which the user
/// should move the device during the tire scanning process.
class ScanDirectionConfig {
  /// Creates a new instance of [ScanDirectionConfig].
  ScanDirectionConfig();

  /// Creates a [ScanDirectionConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the scan direction indicator is visible
  factory ScanDirectionConfig.fromJson(Map<String, dynamic> json) {
    final config = ScanDirectionConfig();
    config.visible = json['visible'] as bool?;
    return config;
  }

  /// Whether the scan direction indicator is displayed during scanning.
  bool? visible;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    return map;
  }
}

/// Configuration for the allowable tire width range.
///
/// Defines the minimum and maximum tire width values that can be
/// entered or used during the scanning process.
class TireWidthRange {
  /// Creates a new instance of [TireWidthRange].
  TireWidthRange();

  /// Creates a [TireWidthRange] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `lowerLimit`: Minimum allowable tire width
  /// - `upperLimit`: Maximum allowable tire width
  factory TireWidthRange.fromJson(Map<String, dynamic> json) {
    final range = TireWidthRange();
    range.lowerLimit = json['lowerLimit'] as num?;
    range.upperLimit = json['upperLimit'] as num?;
    return range;
  }

  /// Minimum allowable tire width value in millimeters.
  num? lowerLimit;

  /// Maximum allowable tire width value in millimeters.
  num? upperLimit;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (lowerLimit != null) map['lowerLimit'] = lowerLimit;
    if (upperLimit != null) map['upperLimit'] = upperLimit;
    return map;
  }
}

/// Configuration for the tire width input UI element.
///
/// Controls the display and behavior of the tire width input screen,
/// which allows users to specify the tire width before scanning.
class TireWidthInputConfig {
  /// Creates a new instance of [TireWidthInputConfig].
  TireWidthInputConfig();

  /// Creates a [TireWidthInputConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `visible`: Whether the tire width input screen is shown
  /// - `skipButtonText`: Text for the skip button (deprecated on Android)
  /// - `titleText`: Title text of the input screen
  /// - `explanationText`: Explanation text describing why tire width is needed
  /// - `continueButtonText`: Text for the continue button
  /// - `prefilledTireWidth`: Default tire width value pre-filled in the input
  /// - `tireWidthRange`: Allowable tire width range
  /// - `tireWidthOptions`: Predefined tire width options to choose from
  factory TireWidthInputConfig.fromJson(Map<String, dynamic> json) {
    final config = TireWidthInputConfig();
    config.visible = json['visible'] as bool?;
    config.skipButtonText = json['skipButtonText'] as String?;
    config.titleText = json['titleText'] as String?;
    config.explanationText = json['explanationText'] as String?;
    config.continueButtonText = json['continueButtonText'] as String?;
    config.prefilledTireWidth = json['prefilledTireWidth'] as int?;
    if (json['tireWidthRange'] != null) {
      config.tireWidthRange = TireWidthRange.fromJson(
          json['tireWidthRange'] as Map<String, dynamic>);
    }
    if (json['tireWidthOptions'] != null) {
      config.tireWidthOptions = (json['tireWidthOptions'] as List<dynamic>)
          .map((e) => e as int)
          .toList();
    }
    return config;
  }

  /// Whether the tire width input screen is displayed before scanning.
  bool? visible;

  /// **Deprecated on Android.** Text for the skip button.
  ///
  /// This property is deprecated and will be removed in the next major SDK release.
  String? skipButtonText;

  /// Title text displayed at the top of the tire width input screen.
  String? titleText;

  /// Explanation text describing why tire width information is needed.
  String? explanationText;

  /// Text for the continue/confirm button on the tire width input screen.
  String? continueButtonText;

  /// Default tire width value (in mm) that is pre-filled in the input field.
  int? prefilledTireWidth;

  /// Range of allowable tire width values that can be entered.
  TireWidthRange? tireWidthRange;

  /// Predefined list of tire width options for quick selection.
  List<int>? tireWidthOptions;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (skipButtonText != null) map['skipButtonText'] = skipButtonText;
    if (titleText != null) map['titleText'] = titleText;
    if (explanationText != null) map['explanationText'] = explanationText;
    if (continueButtonText != null) {
      map['continueButtonText'] = continueButtonText;
    }
    if (prefilledTireWidth != null) {
      map['prefilledTireWidth'] = prefilledTireWidth;
    }
    if (tireWidthRange != null) {
      map['tireWidthRange'] = tireWidthRange?.toJson();
    }
    if (tireWidthOptions != null) map['tireWidthOptions'] = tireWidthOptions;
    return map;
  }
}

/// Configuration for the missing permission UI element.
///
/// Displayed when required permissions (e.g., camera access) are not granted,
/// prompting the user to enable them.
class MissingPermissionConfig {
  /// Creates a new instance of [MissingPermissionConfig].
  MissingPermissionConfig();

  /// Creates a [MissingPermissionConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `title`: Title text for the permission dialog
  /// - `text`: Body text explaining which permissions are needed
  factory MissingPermissionConfig.fromJson(Map<String, dynamic> json) {
    final config = MissingPermissionConfig();
    config.title = json['title'] as String?;
    config.text = json['text'] as String?;
    return config;
  }

  /// Title text of the missing permission dialog.
  String? title;

  /// Body text explaining which permissions are required and why.
  String? text;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (text != null) map['text'] = text;
    return map;
  }
}

/// Main UI configuration class that contains all UI-related settings.
///
/// This class aggregates all individual UI component configurations and
/// provides global settings like measurement system, appearance, and scan speed.
class UiConfig {
  /// Creates a new instance of [UiConfig].
  UiConfig();

  /// Creates a [UiConfig] from a JSON map.
  ///
  /// Parses the following JSON keys:
  /// - `measurementSystem`: Unit system (Metric or Imperial)
  /// - `appearance`: UI appearance style (None, Classic, or Neon)
  /// - `scanSpeed`: Scanning speed preference (Fast or Slow)
  /// - `distanceIndicatorConfig`: Distance indicator configuration
  /// - `focusPointTooltipConfig`: Focus point tooltip configuration
  /// - `tapToStartScanningTooltipConfig`: Tap to start tooltip configuration
  /// - `tireOverlayConfig`: Tire overlay configuration
  /// - `uploadViewConfig`: Upload view configuration
  /// - `orientationWarningConfig`: Orientation warning configuration
  /// - `countdownConfig`: Countdown configuration
  /// - `scanDirectionConfig`: Scan direction indicator configuration
  /// - `tireWidthInputConfig`: Tire width input configuration
  /// - `missingPermissionConfig`: Missing permission dialog configuration
  ///
  /// Throws [ArgumentError] if enum values are invalid.
  factory UiConfig.fromJson(Map<String, dynamic> json) {
    final config = UiConfig();
    if (json['measurementSystem'] != null) {
      config.measurementSystem = MeasurementSystem.values.firstWhere(
        (e) => e.name == json['measurementSystem'],
        orElse: () => throw ArgumentError(
            'measurementSystem must be either "Metric" or "Imperial"'),
      );
    }
    if (json['appearance'] != null) {
      config.appearance = Appearance.values.firstWhere(
        (e) => e.name == json['appearance'],
        orElse: () => throw ArgumentError(
            'appearance must be "None", "Classic", or "Neon"'),
      );
    }
    if (json['scanSpeed'] != null) {
      config.scanSpeed = ScanSpeed.values.firstWhere(
        (e) => e.name == json['scanSpeed'],
        orElse: () =>
            throw ArgumentError('scanSpeed must be either "Fast" or "Slow"'),
      );
    }
    if (json['distanceIndicatorConfig'] != null) {
      config.distanceIndicatorConfig = DistanceIndicatorConfig.fromJson(
          json['distanceIndicatorConfig'] as Map<String, dynamic>);
    }
    if (json['focusPointTooltipConfig'] != null) {
      config.focusPointTooltipConfig = FocusPointTooltipConfig.fromJson(
          json['focusPointTooltipConfig'] as Map<String, dynamic>);
    }
    if (json['tapToStartScanningTooltipConfig'] != null) {
      config.tapToStartScanningTooltipConfig =
          TapToStartScanningTooltipConfig.fromJson(
              json['tapToStartScanningTooltipConfig'] as Map<String, dynamic>);
    }
    if (json['tireOverlayConfig'] != null) {
      config.tireOverlayConfig = TireOverlayConfig.fromJson(
          json['tireOverlayConfig'] as Map<String, dynamic>);
    }
    if (json['uploadViewConfig'] != null) {
      config.uploadViewConfig = UploadViewConfig.fromJson(
          json['uploadViewConfig'] as Map<String, dynamic>);
    }
    if (json['orientationWarningConfig'] != null) {
      config.orientationWarningConfig = OrientationWarningConfig.fromJson(
          json['orientationWarningConfig'] as Map<String, dynamic>);
    }
    if (json['countdownConfig'] != null) {
      config.countdownConfig = CountdownConfig.fromJson(
          json['countdownConfig'] as Map<String, dynamic>);
    }
    if (json['scanDirectionConfig'] != null) {
      config.scanDirectionConfig = ScanDirectionConfig.fromJson(
          json['scanDirectionConfig'] as Map<String, dynamic>);
    }
    if (json['tireWidthInputConfig'] != null) {
      config.tireWidthInputConfig = TireWidthInputConfig.fromJson(
          json['tireWidthInputConfig'] as Map<String, dynamic>);
    }
    if (json['missingPermissionConfig'] != null) {
      config.missingPermissionConfig = MissingPermissionConfig.fromJson(
          json['missingPermissionConfig'] as Map<String, dynamic>);
    }
    return config;
  }

  /// Unit system for displaying measurements (Metric or Imperial).
  MeasurementSystem? measurementSystem;

  /// UI appearance style combining visual theme and haptic feedback.
  Appearance? appearance;

  /// Scanning speed preference affecting capture rate and quality.
  ScanSpeed? scanSpeed;

  /// Configuration for the distance indicator UI component.
  DistanceIndicatorConfig? distanceIndicatorConfig;

  /// Configuration for the focus point tooltip UI component.
  FocusPointTooltipConfig? focusPointTooltipConfig;

  /// Configuration for the tap to start scanning tooltip UI component.
  TapToStartScanningTooltipConfig? tapToStartScanningTooltipConfig;

  /// Configuration for the tire overlay guide UI component.
  TireOverlayConfig? tireOverlayConfig;

  /// Configuration for the upload/processing view UI component.
  UploadViewConfig? uploadViewConfig;

  /// Configuration for the orientation warning UI component.
  OrientationWarningConfig? orientationWarningConfig;

  /// Configuration for the countdown timer UI component.
  CountdownConfig? countdownConfig;

  /// Configuration for the scan direction indicator UI component.
  ScanDirectionConfig? scanDirectionConfig;

  /// Configuration for the tire width input screen UI component.
  TireWidthInputConfig? tireWidthInputConfig;

  /// Configuration for the missing permission dialog UI component.
  MissingPermissionConfig? missingPermissionConfig;

  /// Converts this configuration to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (measurementSystem != null) {
      map['measurementSystem'] = measurementSystem!.name;
    }
    if (appearance != null) {
      map['appearance'] = appearance!.name;
    }
    if (scanSpeed != null) {
      map['scanSpeed'] = scanSpeed!.name;
    }
    if (distanceIndicatorConfig != null) {
      map['distanceIndicatorConfig'] = distanceIndicatorConfig?.toJson();
    }
    if (focusPointTooltipConfig != null) {
      map['focusPointTooltipConfig'] = focusPointTooltipConfig?.toJson();
    }
    if (tapToStartScanningTooltipConfig != null) {
      map['tapToStartScanningTooltipConfig'] =
          tapToStartScanningTooltipConfig?.toJson();
    }
    if (tireOverlayConfig != null) {
      map['tireOverlayConfig'] = tireOverlayConfig?.toJson();
    }
    if (uploadViewConfig != null) {
      map['uploadViewConfig'] = uploadViewConfig?.toJson();
    }
    if (orientationWarningConfig != null) {
      map['orientationWarningConfig'] = orientationWarningConfig?.toJson();
    }
    if (countdownConfig != null) {
      map['countdownConfig'] = countdownConfig?.toJson();
    }
    if (scanDirectionConfig != null) {
      map['scanDirectionConfig'] = scanDirectionConfig?.toJson();
    }
    if (tireWidthInputConfig != null) {
      map['tireWidthInputConfig'] = tireWidthInputConfig?.toJson();
    }
    if (missingPermissionConfig != null) {
      map['missingPermissionConfig'] = missingPermissionConfig?.toJson();
    }
    return map;
  }
}
