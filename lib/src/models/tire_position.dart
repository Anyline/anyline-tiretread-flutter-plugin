import 'package:anyline_tire_tread_plugin/src/enum/tire_side.dart';

/// Position where the tire is mounted on the vehicle, considering the primary direction of travel.
/// E.g. the front left tire of a passenger car would be specified as `axle=1`, `side=TireSide.Left`, `positionOnAxle=1`
/// and the rear right tire of a passenger car as `axle=2`, `side=TireSide.Right`, `positionOnAxle=1`.
class TirePosition {
  /// Creates a new instance of [TirePosition].
  TirePosition();

  /// Creates a [TirePosition] instance from a JSON object.
  factory TirePosition.fromJson(Map<String, dynamic> json) {
    final position = TirePosition();
    position._axle = json['axle'] as int;
    position.side = TireSide.values.firstWhere((e) => e.name == json['side']);
    position._positionOnAxle = json['positionOnAxle'] as int;

    // Validate the values
    if (position._axle < 1) {
      throw ArgumentError('axle must be at least 1');
    }
    if (position._positionOnAxle < 1) {
      throw ArgumentError('positionOnAxle must be at least 1');
    }

    return position;
  }

  /// Number of the axle, whereas 1 is the front axle (in direction of travel).
  /// Value MUST be at least 1.
  int _axle = 1;

  /// The side of the tire.
  TireSide side = TireSide.Left;

  /// Position on the axle.
  /// Value MUST be at least 1.
  int _positionOnAxle = 1;

  /// Gets the axle number.
  int get axle => _axle;

  /// Gets the position on axle.
  int get positionOnAxle => _positionOnAxle;

  /// Sets the axle number and validates it.
  /// Throws [ArgumentError] if axle is less than 1.
  set axle(int value) {
    if (value < 1) {
      throw ArgumentError('axle must be at least 1');
    }
    _axle = value;
  }

  /// Sets the position on axle and validates it.
  /// Throws [ArgumentError] if positionOnAxle is less than 1.
  set positionOnAxle(int value) {
    if (value < 1) {
      throw ArgumentError('positionOnAxle must be at least 1');
    }
    _positionOnAxle = value;
  }

  /// Converts the [TirePosition] instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'axle': _axle,
      'side': side.name,
      'positionOnAxle': _positionOnAxle,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TirePosition &&
        other._axle == _axle &&
        other.side == side &&
        other._positionOnAxle == _positionOnAxle;
  }

  @override
  int get hashCode => Object.hash(_axle, side, _positionOnAxle);
}
