import 'dart:convert';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/device_details_widget.dart';
import 'package:anyline_tire_tread_plugin_example/env_info.dart';
import 'package:anyline_tire_tread_plugin_example/initalize_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

enum InitializationStatus { start, pending, done, fail }

void main() {
  EnvInfo.initialize();
  runApp(const AnylineTireTreadPluginExample());
}

class AnylineTireTreadPluginExample extends StatefulWidget {
  const AnylineTireTreadPluginExample({super.key});

  @override
  State<AnylineTireTreadPluginExample> createState() =>
      _AnylineTireTreadPluginExampleState();
}

class _AnylineTireTreadPluginExampleState
    extends State<AnylineTireTreadPluginExample> {
  bool showLoader = false;

  static GlobalKey<ScaffoldMessengerState> snackBarKey =
      GlobalKey<ScaffoldMessengerState>();

  String _uuid = '';
  String _result = '';
  String _heatmap = '';

  ValueNotifier<InitializationStatus> initializationStatus =
      ValueNotifier(InitializationStatus.pending);

  final TireTreadPlugin _tireTreadPlugin = TireTreadPlugin();
  final GlobalKey heatMapViewKey = GlobalKey();
  final GlobalKey resultViewKey = GlobalKey();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    _tireTreadPlugin.onScanningEvent.listen((event) {
      switch (event) {
        case ScanAborted():
          debugPrint('UUID : ${event.measurementUUID}');
        case UploadAborted():
          debugPrint('UUID : ${event.measurementUUID}');
        case UploadCompleted():
          debugPrint('UUID : ${event.measurementUUID}');
          setState(() => _uuid = event.measurementUUID ?? '');
        case UploadFailed():
          debugPrint('UUID : ${event.error}');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: snackBarKey,
      home: Scaffold(
          backgroundColor: const Color(0xFF000000),
          appBar: AppBar(
            backgroundColor: const Color(0xFF000000),
            title: const Text(
              'Anyline Tire Tread Plugin Example',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Column(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: initializationStatus,
                        builder: (context, status, _) {
                          return Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  AppButton(
                                      onPressed: (status !=
                                              InitializationStatus.start)
                                          ? () async {
                                              EnvInfo.runTimeLicenseKey =
                                                  EnvInfo.licenseKey ?? '';
                                              showDialog<void>(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: InitializeDialog(
                                                        onCancel: () {
                                                      Navigator.pop(context);
                                                    }, onDone:
                                                            (licenseKey) async {
                                                      EnvInfo.runTimeLicenseKey =
                                                          licenseKey;
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        _uuid = '';
                                                        _result = '';
                                                      });
                                                      await startInitialization();
                                                    }),
                                                  );
                                                },
                                              );
                                            }
                                          : null,
                                      title: 'Initialize'),
                                  sizedBox,
                                  AppButton(
                                      onPressed:
                                          (status == InitializationStatus.done)
                                              ? () {
                                                  try {
                                                    setState(() {
                                                      _uuid = '';
                                                      _result = '';
                                                      _heatmap = '';
                                                    });
                                                    _tireTreadPlugin.scan(
                                                        options: ScanOptions());
                                                  } on PlatformException catch (error) {
                                                    if (kDebugMode) {
                                                      print(error);
                                                    }
                                                  }
                                                }
                                              : null,
                                      title: 'Scan'),
                                  sizedBox,
                                  AppButton(
                                      onPressed: (status ==
                                                  InitializationStatus.done &&
                                              _uuid.isNotEmpty)
                                          ? () async {
                                              try {
                                                setState(() {
                                                  showLoader = true;
                                                });
                                                Scrollable.ensureVisible(
                                                    resultViewKey
                                                        .currentContext!,
                                                    duration: const Duration(
                                                        milliseconds: 300));

                                                _result =
                                                    (await _tireTreadPlugin
                                                        .getResult(
                                                            measurementUUID:
                                                                _uuid))!;
                                              } on PlatformException catch (error) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              error.details
                                                                  as String)));
                                                }
                                              } finally {
                                                setState(() {
                                                  showLoader = false;
                                                });
                                              }
                                            }
                                          : null,
                                      title: 'Get Result'),
                                  sizedBox,
                                  AppButton(
                                      onPressed: (status ==
                                                  InitializationStatus.done &&
                                              _uuid.isNotEmpty)
                                          ? () async {
                                              try {
                                                setState(() {
                                                  showLoader = true;
                                                });
                                                Scrollable.ensureVisible(
                                                    heatMapViewKey
                                                        .currentContext!,
                                                    duration: const Duration(
                                                        milliseconds: 300));

                                                _heatmap =
                                                    (await _tireTreadPlugin
                                                        .getHeatMap(
                                                            measurementUUID:
                                                                _uuid))!;
                                              } on PlatformException catch (error) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              error.details
                                                                  as String)));
                                                }
                                              } finally {
                                                setState(() {
                                                  showLoader = false;
                                                });
                                              }
                                            }
                                          : null,
                                      title: 'Get HeatMap'),
                                  sizedBox,
                                  initializationStatusView(status),
                                  sizedBox,
                                  if (_uuid.isNotEmpty)
                                    Text(
                                      'UUID: $_uuid',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.primary),
                                    ),
                                  sizedBox,
                                  if (showLoader)
                                    const SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(
                                            color: AppColors.primary)),
                                  sizedBox,
                                  Image.network(
                                    _heatmap,
                                    key: heatMapViewKey,
                                    errorBuilder: (
                                      context,
                                      _,
                                      __,
                                    ) {
                                      return const SizedBox();
                                    },
                                  ),
                                  sizedBox,
                                  Text(
                                    (_result.isNotEmpty)
                                        ? 'Result: ${const JsonEncoder.withIndent('  ').convert(jsonDecode(_result))}'
                                        : '',
                                    key: resultViewKey,
                                    style: const TextStyle(
                                        fontSize: 16, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    pluginDetailsWidget(),
                    const DeviceDetailsWidget()
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<void> startInitialization() async {
    try {
      setState(() {
        _uuid = '';
        showLoader = true;
      });
      initializationStatus.value = InitializationStatus.start;
      await _tireTreadPlugin.initialize(EnvInfo.licenseKey ?? '');
      initializationStatus.value = InitializationStatus.done;
    } on PlatformException catch (error) {
      initializationStatus.value = InitializationStatus.fail;

      snackBarKey.currentState
          ?.showSnackBar(SnackBar(content: Text(error.details as String)));
    } finally {
      setState(() {
        showLoader = false;
      });
    }
  }

  Column pluginDetailsWidget() {
    return Column(
      children: [
        FutureBuilder(
            future: _tireTreadPlugin.sdkVersion,
            builder: (context, snap) {
              if (snap.hasData) {
                return Text('SDK Version: ${snap.data}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.primary));
              }
              return const SizedBox.shrink();
            }),
        FutureBuilder(
            future: _tireTreadPlugin.pluginVersion,
            builder: (context, snap) {
              if (snap.hasData) {
                return Text('Plugin Version: ${snap.data}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.primary));
              }
              return const SizedBox.shrink();
            }),
      ],
    );
  }

  Widget initializationStatusView(InitializationStatus status) {
    String message = '';
    if (status == InitializationStatus.pending) {
      message = 'Pending';
    } else if (status == InitializationStatus.start) {
      message = 'Started';
    } else if (status == InitializationStatus.fail) {
      message = 'Failed';
    } else {
      message = 'Success';
    }
    return Text(
      'init Result: Initialization $message',
      style: const TextStyle(fontSize: 16, color: AppColors.primary),
    );
  }
}
