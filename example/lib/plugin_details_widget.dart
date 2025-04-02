import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/main.dart';
import 'package:flutter/material.dart';

class PluginDetailsWidget extends StatelessWidget {
  const PluginDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
            future: tireTreadPlugin.sdkVersion,
            builder: (context, snap) {
              if (snap.hasData) {
                return Text('${AppStrings.labelSdkVersion}: ${snap.data}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.primary));
              }
              return const SizedBox.shrink();
            }),
        FutureBuilder(
            future: tireTreadPlugin.pluginVersion,
            builder: (context, snap) {
              if (snap.hasData) {
                return Text('${AppStrings.labelPluginVersion}: ${snap.data}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.primary));
              }
              return const SizedBox.shrink();
            }),
      ],
    );
  }
}
