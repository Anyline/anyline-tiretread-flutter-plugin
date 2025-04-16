import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/device_details_widget.dart';
import 'package:anyline_tire_tread_plugin_example/env_info.dart';
import 'package:anyline_tire_tread_plugin_example/experimental_flags_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/feedback_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/initalize_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/main.dart';
import 'package:anyline_tire_tread_plugin_example/plugin_details_widget.dart';
import 'package:anyline_tire_tread_plugin_example/result_screen.dart';
import 'package:anyline_tire_tread_plugin_example/tread_depth_feedback_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showLoader = false;

  String _uuid = '';
  TreadDepthResult? _result;
  String selectedConfig = '';
  int? tireWidth;
  List<String> selectedFlags = [];

  ValueNotifier<InitializationStatus> initializationStatus =
      ValueNotifier(InitializationStatus.pending);

  @override
  void initState() {
    tireTreadPlugin.onScanningEvent.listen((event) {
      switch (event) {
        case ScanAborted():
          debugPrint('UUID : ${event.measurementUUID}');
        case ScanProcessCompleted():
          debugPrint('UUID : ${event.measurementUUID}');
          setState(() => _uuid = event.measurementUUID ?? '');
        case ScanFailed():
          debugPrint('Error : ${event.error}');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(AppStrings.appTitle,
            style: TextStyle(color: AppColors.primary)),
      ),
      body: SafeArea(
          child: Column(
        children: [
          ValueListenableBuilder(
              valueListenable: initializationStatus,
              builder: (context, status, _) {
                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        experimentalFlagsButton(),
                        sizedBox,
                        initializeButton(status, context),
                        sizedBox,
                        scanButton(status),
                        sizedBox,
                        getResultButton(status, context),
                        sizedBox,
                        sendFeedbackValuesinMmButton(status, context),
                        sizedBox,
                        sendFeedbackValuesIn32InchButton(status, context),
                        sizedBox,
                        sendFeedbackCommentsButton(status, context),
                        sizedBox,
                        initializationStatusView(status),
                        sizedBox,
                        if (_uuid.isNotEmpty)
                          Text(
                            'UUID: $_uuid',
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.primary),
                          ),
                        sizedBox,
                        if (showLoader)
                          const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                  color: AppColors.primary)),
                      ],
                    ),
                  ),
                );
              }),
          const PluginDetailsWidget(),
          const DeviceDetailsWidget()
        ],
      )),
    );
  }

  AppButton initializeButton(
      InitializationStatus status, BuildContext context) {
    return AppButton(
        onPressed: (status != InitializationStatus.start)
            ? () async {
                EnvInfo.runTimeLicenseKey = EnvInfo.licenseKey ?? '';
                showDialog<void>(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      child: InitializeDialog(onCancel: () {
                        Navigator.pop(context);
                      }, onDone: (licenseKey, selectedFile, tireWidth) async {
                        EnvInfo.runTimeLicenseKey = licenseKey;
                        Navigator.of(context).pop();
                        setState(() {
                          _uuid = '';
                          _result = null;
                          selectedConfig = selectedFile;
                          this.tireWidth = tireWidth;
                        });
                        await startInitialization();
                      }),
                    );
                  },
                );
              }
            : null,
        title: AppStrings.btnInitialize);
  }

  AppButton experimentalFlagsButton() {
    return AppButton(
        onPressed: () async {
          showDialog<void>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext con) {
              return Dialog(
                backgroundColor: Colors.white,
                child: ExperimentalFlagsDialog(
                  selectedFlags: selectedFlags,
                  onCancel: () {
                    Navigator.pop(con);
                  },
                  onDone: (flags) async {
                    Navigator.of(con).pop();
                    try {
                      setState(() {
                        showLoader = true;
                        selectedFlags = flags;
                      });
                      await tireTreadPlugin.setExperimentalFlags(
                          experimentalFlags: flags);
                    } on PlatformException catch (error) {
                      showSnackBar(context, error.message as String);
                    } finally {
                      setState(() {
                        showLoader = false;
                      });
                    }
                  },
                  onClearFlags: () async {
                    Navigator.of(con).pop();
                    try {
                      setState(() {
                        showLoader = true;
                        selectedFlags.clear();
                      });
                      await tireTreadPlugin.clearExperimentalFlags();
                    } on PlatformException catch (error) {
                      showSnackBar(context, error.message as String);
                    } finally {
                      setState(() {
                        showLoader = false;
                      });
                    }
                  },
                ),
              );
            },
          );
        },
        title: AppStrings.btnExperimentalFlags);
  }

  AppButton scanButton(InitializationStatus status) {
    return AppButton(
        onPressed: (status == InitializationStatus.done)
            ? () async {
                try {
                  setState(() {
                    _uuid = '';
                    _result = null;
                  });

                  ScanOptions option = ScanOptions();
                  if (selectedConfig.isNotEmpty) {
                    var data = await rootBundle.loadString(selectedConfig);
                    option.configFileContent = data;
                  }
                  if (tireWidth != null) {
                    option.tireWidth = tireWidth;
                  }

                  tireTreadPlugin.scan(options: option);
                } on PlatformException catch (error) {
                  if (kDebugMode) {
                    print(error);
                  }
                }
              }
            : null,
        title: AppStrings.btnScan);
  }

  AppButton getResultButton(InitializationStatus status, BuildContext context) {
    return AppButton(
        onPressed: (status == InitializationStatus.done && _uuid.isNotEmpty)
            ? () async {
                _result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResultScreen(uuid: _uuid)),
                );
                setState(() {});
              }
            : null,
        title: AppStrings.btnGetResult);
  }

  AppButton sendFeedbackCommentsButton(
      InitializationStatus status, BuildContext context) {
    return AppButton(
        onPressed: (status == InitializationStatus.done &&
                _uuid.isNotEmpty &&
                _result != null)
            ? () async {
                showDialog<void>(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext con) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      child: FeedbackDialog(onCancel: () {
                        Navigator.pop(con);
                      }, onDone: (comment) async {
                        Navigator.of(con).pop();
                        try {
                          setState(() {
                            showLoader = true;
                          });
                          await tireTreadPlugin.sendFeedbackComment(
                              measurementUUID: _uuid, comment: comment);

                          showSnackBar(
                              context, AppStrings.messageFeedbackSuccess);
                        } on PlatformException catch (error) {
                          showSnackBar(context, error.message as String);
                        } finally {
                          setState(() {
                            showLoader = false;
                          });
                        }
                      }),
                    );
                  },
                );
              }
            : null,
        title: AppStrings.btnSendFeedback);
  }

  AppButton sendFeedbackValuesIn32InchButton(
      InitializationStatus status, BuildContext context) {
    return AppButton(
        onPressed: (status == InitializationStatus.done &&
                _uuid.isNotEmpty &&
                _result != null)
            ? () async {
                showDialog<void>(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      child: TreadDepthResultFeedbackDialog(
                          isValueInMm: false,
                          onCancel: () {
                            Navigator.pop(dialogContext);
                          },
                          onDone: (regions) async {
                            Navigator.of(dialogContext).pop();
                            try {
                              setState(() {
                                showLoader = true;
                              });
                              await tireTreadPlugin
                                  .sendTreadDepthResultFeedback(
                                      measurementUUID: _uuid,
                                      resultRegions: regions);
                              showSnackBar(
                                  context, AppStrings.messageFeedbackSuccess);
                            } on PlatformException catch (error) {
                              showSnackBar(context, error.message as String);
                            } finally {
                              setState(() {
                                showLoader = false;
                              });
                            }
                          }),
                    );
                  },
                );
              }
            : null,
        title: AppStrings.btnSendTreadDepthFeedback32);
  }

  AppButton sendFeedbackValuesinMmButton(
      InitializationStatus status, BuildContext context) {
    return AppButton(
        onPressed: (status == InitializationStatus.done &&
                _uuid.isNotEmpty &&
                _result != null)
            ? () async {
                showDialog<void>(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      child: TreadDepthResultFeedbackDialog(
                          isValueInMm: true,
                          onCancel: () {
                            Navigator.pop(dialogContext);
                          },
                          onDone: (regions) async {
                            Navigator.of(dialogContext).pop();
                            try {
                              setState(() {
                                showLoader = true;
                              });
                              await tireTreadPlugin
                                  .sendTreadDepthResultFeedback(
                                      measurementUUID: _uuid,
                                      resultRegions: regions);
                              showSnackBar(
                                  context, AppStrings.messageFeedbackSuccess);
                            } on PlatformException catch (error) {
                              showSnackBar(context, error.message as String);
                            } finally {
                              setState(() {
                                showLoader = false;
                              });
                            }
                          }),
                    );
                  },
                );
              }
            : null,
        title: AppStrings.btnSendTreadDepthFeedback);
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> startInitialization() async {
    try {
      setState(() {
        _uuid = '';
        showLoader = true;
      });
      initializationStatus.value = InitializationStatus.start;
      await tireTreadPlugin.initialize(EnvInfo.licenseKey ?? '');
      initializationStatus.value = InitializationStatus.done;
    } on PlatformException catch (error) {
      initializationStatus.value = InitializationStatus.fail;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.details as String)),
      );
    } finally {
      setState(() {
        showLoader = false;
      });
    }
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
    return Text('Initialization $message',
        style: const TextStyle(fontSize: 16, color: AppColors.primary));
  }
}
