import 'package:anyline_tire_tread_plugin/src/enum/measurement_system.dart';
import 'package:anyline_tire_tread_plugin/src/enum/scan_speed.dart';

/// Configuration for the distance indicator UI element.
class DistanceIndicatorConfig {
  /// Creates a new instance of [DistanceIndicatorConfig].
  DistanceIndicatorConfig();

  factory DistanceIndicatorConfig.fromJson(Map<String, dynamic> json) {
    final config = DistanceIndicatorConfig();
    config.visible = json['visible'] as bool?;
    config.textOk = json['textOk'] as String?;
    config.textMoveCloser = json['textMoveCloser'] as String?;
    config.textMoveAway = json['textMoveAway'] as String?;
    return config;
  }

  bool? visible;
  String? textOk;
  String? textMoveCloser;
  String? textMoveAway;

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
class FocusPointTooltipConfig {
  /// Creates a new instance of [FocusPointTooltipConfig].
  FocusPointTooltipConfig();

  factory FocusPointTooltipConfig.fromJson(Map<String, dynamic> json) {
    final config = FocusPointTooltipConfig();
    config.visible = json['visible'] as bool?;
    config.smallText = json['smallText'] as String?;
    config.text = json['text'] as String?;
    return config;
  }

  bool? visible;
  String? smallText;
  String? text;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (smallText != null) map['smallText'] = smallText;
    if (text != null) map['text'] = text;
    return map;
  }
}

/// Configuration for the tap to start scanning tooltip UI element.
class TapToStartScanningTooltipConfig {
  /// Creates a new instance of [TapToStartScanningTooltipConfig].
  TapToStartScanningTooltipConfig();

  factory TapToStartScanningTooltipConfig.fromJson(Map<String, dynamic> json) {
    final config = TapToStartScanningTooltipConfig();
    config.visible = json['visible'] as bool?;
    config.textOk = json['textOk'] as String?;
    config.textNotOkMetric = json['textNotOkMetric'] as String?;
    config.textNotOkImperial = json['textNotOkImperial'] as String?;
    return config;
  }

  bool? visible;
  String? textOk;
  String? textNotOkMetric;
  String? textNotOkImperial;

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
class TireOverlayConfig {
  /// Creates a new instance of [TireOverlayConfig].
  TireOverlayConfig();

  factory TireOverlayConfig.fromJson(Map<String, dynamic> json) {
    final config = TireOverlayConfig();
    config.visible = json['visible'] as bool?;
    return config;
  }

  bool? visible;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    return map;
  }
}

/// Configuration for the upload view UI element.
class UploadViewConfig {
  /// Creates a new instance of [UploadViewConfig].
  UploadViewConfig();

  factory UploadViewConfig.fromJson(Map<String, dynamic> json) {
    final config = UploadViewConfig();
    config.visible = json['visible'] as bool?;
    config.text = json['text'] as String?;
    return config;
  }

  bool? visible;
  String? text;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (text != null) map['text'] = text;
    return map;
  }
}

/// Configuration for the orientation warning UI element.
class OrientationWarningConfig {
  /// Creates a new instance of [OrientationWarningConfig].
  OrientationWarningConfig();

  factory OrientationWarningConfig.fromJson(Map<String, dynamic> json) {
    final config = OrientationWarningConfig();
    config.visible = json['visible'] as bool?;
    config.text = json['text'] as String?;
    config.rotationLockHint = json['rotationLockHint'] as String?;
    return config;
  }

  bool? visible;
  String? text;
  String? rotationLockHint;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    if (text != null) map['text'] = text;
    if (rotationLockHint != null) map['rotationLockHint'] = rotationLockHint;
    return map;
  }
}

/// Configuration for the countdown UI element.
class CountdownConfig {
  /// Creates a new instance of [CountdownConfig].
  CountdownConfig();

  factory CountdownConfig.fromJson(Map<String, dynamic> json) {
    final config = CountdownConfig();
    config.visible = json['visible'] as bool?;
    return config;
  }

  bool? visible;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    return map;
  }
}

/// Configuration for the scan direction UI element.
class ScanDirectionConfig {
  /// Creates a new instance of [ScanDirectionConfig].
  ScanDirectionConfig();

  factory ScanDirectionConfig.fromJson(Map<String, dynamic> json) {
    final config = ScanDirectionConfig();
    config.visible = json['visible'] as bool?;
    return config;
  }

  bool? visible;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (visible != null) map['visible'] = visible;
    return map;
  }
}

/// Configuration for the tire width range.
class TireWidthRange {
  /// Creates a new instance of [TireWidthRange].
  TireWidthRange();

  factory TireWidthRange.fromJson(Map<String, dynamic> json) {
    final range = TireWidthRange();
    range.lowerLimit = json['lowerLimit'] as num?;
    range.upperLimit = json['upperLimit'] as num?;
    return range;
  }

  num? lowerLimit;
  num? upperLimit;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (lowerLimit != null) map['lowerLimit'] = lowerLimit;
    if (upperLimit != null) map['upperLimit'] = upperLimit;
    return map;
  }
}

/// Configuration for the tire width input UI element.
class TireWidthInputConfig {
  /// Creates a new instance of [TireWidthInputConfig].
  TireWidthInputConfig();

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

  bool? visible;
  String? skipButtonText;
  String? titleText;
  String? explanationText;
  String? continueButtonText;
  int? prefilledTireWidth;
  TireWidthRange? tireWidthRange;
  List<int>? tireWidthOptions;

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
class MissingPermissionConfig {
  /// Creates a new instance of [MissingPermissionConfig].
  MissingPermissionConfig();

  factory MissingPermissionConfig.fromJson(Map<String, dynamic> json) {
    final config = MissingPermissionConfig();
    config.title = json['title'] as String?;
    config.text = json['text'] as String?;
    return config;
  }

  String? title;
  String? text;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (text != null) map['text'] = text;
    return map;
  }
}

/// Main UI configuration class that contains all UI-related settings.
class UiConfig {
  /// Creates a new instance of [UiConfig].
  UiConfig();

  factory UiConfig.fromJson(Map<String, dynamic> json) {
    final config = UiConfig();
    if (json['measurementSystem'] != null) {
      config.measurementSystem = MeasurementSystem.values.firstWhere(
        (e) => e.name == json['measurementSystem'],
        orElse: () => throw ArgumentError(
            'measurementSystem must be either "Metric" or "Imperial"'),
      );
    }
    config.useDefaultUi = json['useDefaultUi'] as bool?;
    config.useDefaultHaptic = json['useDefaultHaptic'] as bool?;
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

  MeasurementSystem? measurementSystem;
  bool? useDefaultUi;
  bool? useDefaultHaptic;
  ScanSpeed? scanSpeed;
  DistanceIndicatorConfig? distanceIndicatorConfig;
  FocusPointTooltipConfig? focusPointTooltipConfig;
  TapToStartScanningTooltipConfig? tapToStartScanningTooltipConfig;
  TireOverlayConfig? tireOverlayConfig;
  UploadViewConfig? uploadViewConfig;
  OrientationWarningConfig? orientationWarningConfig;
  CountdownConfig? countdownConfig;
  ScanDirectionConfig? scanDirectionConfig;
  TireWidthInputConfig? tireWidthInputConfig;
  MissingPermissionConfig? missingPermissionConfig;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (measurementSystem != null) {
      map['measurementSystem'] = measurementSystem!.name;
    }
    if (useDefaultUi != null) {
      map['useDefaultUi'] = useDefaultUi;
    }
    if (useDefaultHaptic != null) {
      map['useDefaultHaptic'] = useDefaultHaptic;
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
