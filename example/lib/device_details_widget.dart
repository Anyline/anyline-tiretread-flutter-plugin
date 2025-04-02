import 'dart:io';

import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:anyline_tire_tread_plugin_example/app_colors.dart';

class DeviceDetailsWidget extends StatelessWidget {
  const DeviceDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return (Platform.isAndroid)
        ? FutureBuilder<AndroidDeviceInfo>(
            future: DeviceInfoPlugin().androidInfo,
            builder: (context, snap) {
              if (snap.hasData) {
                return Column(
                  children: [
                    Text(
                        '${AppStrings.labelOsVersion}: ${snap.data?.version.release}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                    Text('${AppStrings.labelDevice}: ${snap.data?.model}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                  ],
                );
              }
              return const SizedBox.shrink();
            })
        : FutureBuilder<IosDeviceInfo>(
            future: DeviceInfoPlugin().iosInfo,
            builder: (context, snap) {
              if (snap.hasData) {
                return Column(
                  children: [
                    Text(
                        '${AppStrings.labelOsVersion}: ${snap.data?.systemVersion}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                    Text('${AppStrings.labelDevice}: ${snap.data?.modelName}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                  ],
                );
              }
              return const SizedBox.shrink();
            });
  }
}
