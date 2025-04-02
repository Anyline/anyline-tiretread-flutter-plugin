
import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/env_info.dart';
import 'package:anyline_tire_tread_plugin_example/home_screen.dart';
import 'package:flutter/material.dart';

enum InitializationStatus { start, pending, done, fail }

final TireTreadPlugin tireTreadPlugin = TireTreadPlugin();

void main() {
  EnvInfo.initialize();
  runApp(const MaterialApp(home: HomeScreen()));
}
