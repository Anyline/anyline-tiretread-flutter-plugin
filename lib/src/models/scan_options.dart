import 'package:anyline_tire_tread_plugin/src/enum/measurement_system.dart';
import 'package:anyline_tire_tread_plugin/src/enum/scan_speed.dart';

/// The `ScanOptions` class allows customization of various parameters
/// for the tire tread scanning process, including scan speed, measurement
/// system, tire width, guidance display, and configuration file content.
class ScanOptions {
  /// Creates a new instance of [ScanOptions].
  ///
  /// The [scanSpeed] parameter specifies the speed of the scan.
  /// The [measurementSystem] parameter defines the measurement system to use (e.g., metric or imperial).
  /// The [tireWidth] parameter sets the width of the tire to be scanned.
  /// The [showGuidance] parameter indicates whether to show guidance during the scan.
  /// The [configFileContent] parameter contains the content of the configuration file.
  ScanOptions({
    this.scanSpeed,
    this.measurementSystem,
    this.tireWidth,
    this.showGuidance = true,
    this.configFileContent,
  });

  /// The speed of the scan.
  final ScanSpeed? scanSpeed;

  /// This parameter defines the units of measurement for the scan results.
  final MeasurementSystem? measurementSystem;

  /// The width of the tire to be scanned.
  final int? tireWidth;

  /// Whether to show guidance during the scan.
  final bool showGuidance;

  /// This parameter contains the configuration settings required for the scan.
  final String? configFileContent;

  /// Converts the [ScanOptions] instance to a JSON object.
  ///
  /// This method returns a map representation of the [ScanOptions] instance,
  /// which can be used for serialization.
  Map<String, dynamic> toJson() {
    return {
      'configFileContent': configFileContent,
      'scanSpeed': scanSpeed?.name,
      'measurementSystem': measurementSystem?.name,
      'tireWidth': tireWidth,
      'showGuidance': showGuidance,
    };
  }
}
