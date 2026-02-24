// ignore_for_file: constant_identifier_names

/// The side of the tire on the vehicle.
///
/// Used to specify which side of the vehicle a tire is mounted on,
/// from the perspective of facing the direction of travel.
enum TireSide {
  /// Left side of the vehicle (driver's side in left-hand drive vehicles).
  Left,

  /// Right side of the vehicle (passenger's side in left-hand drive vehicles).
  Right,

  /// Center position (for vehicles with center-mounted tires, e.g., trailers).
  Center,
}
