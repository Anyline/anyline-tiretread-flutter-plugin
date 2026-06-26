import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_theme.dart';
import 'package:anyline_tire_tread_plugin_example/env_info.dart';
import 'package:anyline_tire_tread_plugin_example/home_screen.dart';
import 'package:flutter/material.dart';

enum InitializationStatus { start, pending, done, fail }

final TireTreadPlugin tireTreadPlugin = TireTreadPlugin();
final TireSidewallPlugin tireSidewallPlugin = TireSidewallPlugin();

void main() {
  EnvInfo.initialize();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    home: const HomeScreen(),
  ));
}
