import 'package:anyline_tire_tread_plugin/src/enum/movement_direction.dart';

/// Metadata describing how a tire tread measurement was captured.
///
/// New in SDK v15. Currently exposes the [movementDirection] detected during
/// the scan.
class MeasurementMetadata {
  /// Creates a new instance of [MeasurementMetadata].
  MeasurementMetadata({this.movementDirection});

  /// Creates a [MeasurementMetadata] from a JSON map.
  MeasurementMetadata.fromJson(Map<String, dynamic> json) {
    final direction = json['movementDirection'] as String?;
    movementDirection =
        direction == null ? null : MovementDirection.fromString(direction);
  }

  /// The direction the device moved across the tire during the scan.
  MovementDirection? movementDirection;

  /// Converts this metadata to a JSON map, omitting unset fields.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (movementDirection != null) {
      data['movementDirection'] = movementDirection!.name;
    }
    return data;
  }
}
