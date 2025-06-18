import 'package:anyline_tire_tread_plugin/src/enum/heatmap_style.dart';

/// Configuration for the scanning process.
class ScanConfig {
  /// Creates a new instance of [ScanConfig].
  ScanConfig();

  /// Creates a [ScanConfig] instance from a JSON object.
  factory ScanConfig.fromJson(Map<String, dynamic> json) {
    final config = ScanConfig();
    config.heatmapStyle = json['heatmapStyle'] != null
        ? HeatmapStyle.values.firstWhere(
            (e) => e.name == json['heatmapStyle'],
            orElse: () => throw ArgumentError(
                'heatmapStyle must be either "Colored" or "GrayScale"'),
          )
        : HeatmapStyle.Colored; // Default value from schema
    config.showMeasuringSpots = json['showMeasuringSpots'] as bool? ??
        true; // Default value from schema
    config.tireWidth = json['tireWidth'] as int?;
    return config;
  }

  /// The style of the heatmap image.
  HeatmapStyle heatmapStyle = HeatmapStyle.Colored;

  /// Whether to show measuring spots in the result image.
  bool showMeasuringSpots = true;

  /// The width of the tire to be scanned.
  int? tireWidth;

  /// Converts the [ScanConfig] instance to a JSON object.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'heatmapStyle': heatmapStyle.name,
      'showMeasuringSpots': showMeasuringSpots,
    };
    if (tireWidth != null) {
      map['tireWidth'] = tireWidth;
    }
    return map;
  }
}
