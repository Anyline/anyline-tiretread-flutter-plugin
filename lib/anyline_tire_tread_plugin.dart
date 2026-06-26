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
/// final outcome = await plugin.scan(config: config);
/// switch (outcome) {
///   case ScanCompleted():
///     final result = await plugin.getResult(
///       measurementUUID: outcome.measurementUUID,
///     );
///   case ScanAborted():
///     print('Scan was cancelled');
///   case ScanFailed():
///     print('Scan failed: ${outcome.error.message}');
/// }
/// ```
library;

export 'package:anyline_tire_tread_plugin/src/tire_tread_plugin.dart';
export 'src/scan_outcome.dart';
export 'src/models/sdk_error.dart';
// Tire Sidewall (TSW) scanner — separate channel, same package.
export 'package:anyline_tire_tread_plugin/src/tire_sidewall_plugin.dart';
export 'src/tire_sidewall_outcome.dart';
export 'src/models/tire_sidewall_config.dart';
export 'src/models/tire_sidewall_texts.dart';
export 'src/models/tire_sidewall_support.dart';
export 'src/enum/environment_lighting.dart';
export 'src/enum/appearance.dart';
export 'src/enum/measurement_system.dart';
export 'src/enum/scan_speed.dart';
export 'src/enum/heatmap_style.dart';
export 'src/enum/tire_side.dart';
export 'src/enum/measurement_status.dart';
export 'src/enum/movement_direction.dart';
export 'src/models/measurement_metadata.dart';
export 'src/models/tread_depth_result.dart';
export 'src/models/tire_position.dart';
export 'src/models/additional_context.dart';
export 'src/models/scan_config.dart';
export 'src/models/scan_options.dart';
export 'src/models/tire_tread_config.dart';
export 'src/models/ui_config.dart';
export 'src/experimental_flags.dart';
