import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:flutter/material.dart';

/// Light/dark themes for the API Explorer example, built from the Anyline DS
/// tokens (handoff §3). The redesign is presentation-only: cards read their
/// surface from [ThemeData.cardColor], borders from [ThemeData.dividerColor],
/// and accents from the [DevExColors] extension.
class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final ds = isDark ? DevExColors.dark : DevExColors.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: ds.brand,
      brightness: brightness,
      primary: ds.brand,
      surface: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
      onSurface: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF0B0B0C),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF000000) : const Color(0xFFEEF0F3),
      cardColor: scheme.surface,
      dividerColor: isDark ? const Color(0xFF38383A) : const Color(0x263C3C43),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF000000) : const Color(0xFFEEF0F3),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? ds.brand : ds.inset),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
