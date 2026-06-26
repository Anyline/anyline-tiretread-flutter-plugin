import 'package:flutter/material.dart';

/// Brand constants kept for backwards compatibility with existing widgets.
class AppColors {
  static const Color primary = Color(0xFF0099FF);
  static const Color white = Color(0xFFFFFFFF);
}

/// Anyline design-system accents and surfaces for the redesigned API Explorer.
///
/// A plain palette with [light] and [dark] variants. Pick the one matching the
/// current theme via [DevExColors.of] — or the [DevExColorsX.ds] shorthand:
/// `context.ds.brand`.
@immutable
class DevExColors {
  const DevExColors({
    required this.brand,
    required this.correlation,
    required this.success,
    required this.inset,
    required this.fg2,
    required this.fg3,
  });

  /// Brand accent — primary action + both scanner icons.
  final Color brand;

  /// Correlation ID (shared, optional) identity.
  final Color correlation;

  /// Supported / Initialized / success states.
  final Color success;

  /// Inset surfaces: segmented tracks, mono blocks, metric tiles.
  final Color inset;

  /// Secondary text.
  final Color fg2;

  /// Tertiary / hint text.
  final Color fg3;

  static const DevExColors light = DevExColors(
    brand: Color(0xFF0099FF),
    correlation: Color(0xFF5246E0),
    success: Color(0xFF00A37A),
    inset: Color(0xFFF0F1F4),
    fg2: Color(0xDB3C3C43),
    fg3: Color(0x8C3C3C43),
  );

  static const DevExColors dark = DevExColors(
    brand: Color(0xFF0A9DFF),
    correlation: Color(0xFFA09DF6),
    success: Color(0xFF2EE0AB),
    inset: Color(0xFF2C2C2E),
    fg2: Color(0xD1FAFAFA),
    fg3: Color(0x85FAFAFA),
  );

  /// The palette matching the current theme's brightness.
  static DevExColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

extension DevExColorsX on BuildContext {
  /// Anyline DS accents/surfaces for the current theme.
  DevExColors get ds => DevExColors.of(this);
}
