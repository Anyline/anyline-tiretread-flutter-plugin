import 'dart:io';

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
                    Text('OS Version: ${snap.data?.version.release}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                    Text('Device: ${snap.data?.model}',
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
                    Text('OS Version: ${snap.data?.systemVersion}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                    Text('Device: ${snap.data?.modelName}',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primary)),
                  ],
                );
              }
              return const SizedBox.shrink();
            });
  }
}
