import 'dart:convert';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/main.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.uuid});

  final String uuid;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  TreadDepthResult? result;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<TreadDepthResult?> _fetchData() async {
    result = await tireTreadPlugin.getResult(measurementUUID: widget.uuid);
    return Future.value(result);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(result);
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000),
          title: const Text(AppStrings.appTitle,
              style: TextStyle(color: AppColors.primary)),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.labelHeatmap,
                  style: TextStyle(fontSize: 24, color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                    future: tireTreadPlugin.getHeatMap(
                        measurementUUID: widget.uuid),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Text(snap.error.toString(),
                            style: const TextStyle(color: AppColors.white));
                      }
                      if (snap.hasData) {
                        return Image.network(
                          snap.data ?? '',
                          errorBuilder: (context, _, __) {
                            return const SizedBox();
                          },
                        );
                      }
                      return const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(
                              color: AppColors.primary));
                    }),
                const SizedBox(height: 20),
                const Text(AppStrings.titleResult,
                    style: TextStyle(fontSize: 24, color: AppColors.primary)),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: FutureBuilder<TreadDepthResult?>(
                        future: _fetchData(),
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return Text(snap.error.toString(),
                                style: const TextStyle(color: AppColors.white));
                          }
                          if (snap.hasData) {
                            return Text(
                                (snap.data != null)
                                    ? '${AppStrings.titleResult}: ${const JsonEncoder.withIndent('  ').convert(snap.data?.toJson())}'
                                    : '',
                                style: const TextStyle(
                                    fontSize: 16, color: AppColors.primary));
                          }
                          return const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                  color: AppColors.primary));
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
