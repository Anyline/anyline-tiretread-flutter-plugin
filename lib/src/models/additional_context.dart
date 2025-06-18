import 'package:anyline_tire_tread_plugin/src/models/tire_position.dart';

/// Provides additional context to a scan. This makes sense in a workflow,
/// where a scan is connected to other TireTread scans or other information in a larger context.
class AdditionalContext {
  /// Creates a new instance of [AdditionalContext].
  AdditionalContext();

  /// Creates an [AdditionalContext] instance from a JSON object.
  factory AdditionalContext.fromJson(Map<String, dynamic> json) {
    final context = AdditionalContext();
    context.correlationId = json['correlationId'] as String?;
    if (json['tirePosition'] != null) {
      context.tirePosition =
          TirePosition.fromJson(json['tirePosition'] as Map<String, dynamic>);
    }
    return context;
  }

  /// An optional correlation ID to connect this scan with other scans or data.
  String? correlationId;

  /// The position of the tire being scanned.
  TirePosition? tirePosition;

  /// Converts the [AdditionalContext] instance to a JSON object.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (correlationId != null) map['correlationId'] = correlationId;
    if (tirePosition != null) map['tirePosition'] = tirePosition?.toJson();
    return map;
  }
}
