/// Anyline Tire Tread SDK Flutter Plugin
///
/// This library provides Flutter bindings for the Anyline Tire Tread SDK,
/// enabling tire tread depth measurement and analysis in Flutter applications.
///
/// ## Features
/// - Initialize SDK with license key validation
/// - Scan tire tread depth with customizable UI configuration
/// - Retrieve measurement results and heatmap visualizations
/// - Submit feedback comments and tread depth corrections
/// - Configure experimental features
///
/// ## Usage
///
/// ```dart
/// final plugin = TireTreadPlugin();
///
/// // Initialize with your license key
/// await plugin.initialize('YOUR_LICENSE_KEY');
///
/// // Configure and start scanning
/// final config = TireTreadConfig()
///   ..scanConfig = (ScanConfig()..tireWidth = 185)
///   ..uiConfig = (UiConfig()
///     ..measurementSystem = MeasurementSystem.Metric
///     ..scanSpeed = ScanSpeed.Fast);
///
/// await plugin.scan(config: config);
///
/// // Listen for scan events
/// plugin.onScanningEvent.listen((event) {
///   if (event is ScanProcessCompleted) {
///     // Retrieve results
///     final result = await plugin.getResult(
///       measurementUUID: event.measurementUUID
///     );
///   }
/// });
/// ```
library;

export 'package:anyline_tire_tread_plugin/src/tire_tread_plugin.dart';
export 'src/scan_event.dart';
export 'src/enum/appearance.dart';
export 'src/enum/measurement_system.dart';
export 'src/enum/scan_speed.dart';
export 'src/enum/heatmap_style.dart';
export 'src/enum/tire_side.dart';
export 'src/models/tread_depth_result.dart';
export 'src/models/tire_position.dart';
export 'src/models/additional_context.dart';
export 'src/models/scan_config.dart';
export 'src/models/tire_tread_config.dart';
export 'src/models/ui_config.dart';
export 'src/experimental_flags.dart';
