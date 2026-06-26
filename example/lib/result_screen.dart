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
  late final Future<String?> _heatMap =
      tireTreadPlugin.getHeatMap(measurementUUID: widget.uuid);
  late final Future<TreadDepthResult?> _result =
      tireTreadPlugin.getResult(measurementUUID: widget.uuid);

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.titleResult)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.labelHeatmap,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ds.brand)),
              const SizedBox(height: 12),
              Center(
                child: FutureBuilder<String?>(
                  future: _heatMap,
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Text(snap.error.toString(),
                          style: TextStyle(color: ds.fg3));
                    }
                    if (snap.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(snap.data ?? '',
                            errorBuilder: (_, __, ___) => const SizedBox()),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.titleResult,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ds.brand)),
              const SizedBox(height: 12),
              FutureBuilder<TreadDepthResult?>(
                future: _result,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Text(snap.error.toString(),
                        style: TextStyle(color: ds.fg3));
                  }
                  if (snap.hasData) {
                    final json = snap.data != null
                        ? const JsonEncoder.withIndent('  ')
                            .convert(snap.data!.toJson())
                        : '';
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ds.inset,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(json,
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: ds.fg2)),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child:
                        CircularProgressIndicator(color: AppColors.primary),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
