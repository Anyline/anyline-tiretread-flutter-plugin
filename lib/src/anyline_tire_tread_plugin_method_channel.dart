// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin/src/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';

/// An implementation of [AnylineTireTreadPluginPlatform] that uses method channels.
class MethodChannelAnylineTireTreadPlugin
    extends AnylineTireTreadPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('anyline_tire_tread_plugin');

  final _eventsChannel = const EventChannel('anyline_tire_tread_plugin/events');

  @override
  Future<String?> getSdkVersion() async {
    final version = await methodChannel
        .invokeMethod<String>(Constants.METHOD_GET_SDK_VERSION);
    return version;
  }

  @override
  Future<bool?> initialize(
      {required String licenseKey, required String pluginVersion}) async {
    final result =
    await methodChannel.invokeMethod<bool>(Constants.METHOD_INITIALIZE, {
      Constants.EXTRA_LICENSE_KEY: licenseKey,
      Constants.EXTRA_PLUGIN_VERSION: pluginVersion
    });
    return result;
  }

  @override
  Future<bool?> scan({required TireTreadConfig config}) async {
    final result = await methodChannel.invokeMethod<bool>(
        Constants.METHOD_SCAN, config.toJson());
    return result;
  }

  @override
  Future<TreadDepthResult?> getResult({required String measurementUUID}) async {
    final result = await methodChannel.invokeMethod<String>(
        Constants.METHOD_GET_RESULT,
        {Constants.EXTRA_MEASUREMENT_UUID: measurementUUID});
    return TreadDepthResult.fromJson(
        jsonDecode(result!) as Map<String, dynamic>);
  }

  @override
  Future<String?> getHeatMap({required String measurementUUID}) async {
    final version = await methodChannel.invokeMethod<String>(
        Constants.METHOD_GET_HEATMAP,
        {Constants.EXTRA_MEASUREMENT_UUID: measurementUUID});
    return version;
  }

  @override
  Stream<ScanEvent> get onScanningEvent {
    return _eventsChannel.receiveBroadcastStream().map((event) {
      final Map<String, dynamic> eventType =
          jsonDecode(event as String) as Map<String, dynamic>;
      String measurementResultStatus =
          (eventType['measurementResultStatus']['type'] as String)
              .split('.')
              .last;
      switch (measurementResultStatus) {
        case 'ScanAborted':
          return ScanAborted.fromMap(eventType);
        case 'ScanProcessCompleted':
          return ScanProcessCompleted.fromMap(eventType);
        case 'ScanFailed':
          return ScanFailed.fromMap(eventType);
        case 'ScanStarted':
          return ScanStarted.fromMap(eventType);
        default:
          return ScanAborted.fromMap(eventType);
      }
    });
  }

  @override
  Future<String?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) async {
    final result = await methodChannel
        .invokeMethod<String>(Constants.METHOD_SEND_FEEDBACK_COMMENT, {
      Constants.EXTRA_MEASUREMENT_UUID: measurementUUID,
      Constants.EXTRA_FEEDBACK_COMMENT: comment
    });
    return result;
  }

  @override
  Future<String?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) async {
    final result = await methodChannel.invokeMethod<String>(
        Constants.METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK, {
      Constants.EXTRA_MEASUREMENT_UUID: measurementUUID,
      Constants.EXTRA_TREAD_DEPTH_RESULT_FEEDBACK:
          jsonEncode(resultRegions.map((obj) => obj.toJson()).toList())
    });
    return result;
  }

  @override
  Future<void> setExperimentalFlags(
      {required List<String> experimentalFlags}) async {
    final result = await methodChannel.invokeMethod<void>(
        Constants.METHOD_SET_EXPERIMENTAL_FLAGS,
        {Constants.EXTRA_EXPERIMENTAL_FLAGS: experimentalFlags});
    return result;
  }

  @override
  Future<void> clearExperimentalFlags() async {
    final result = await methodChannel.invokeMethod<void>(
        Constants.METHOD_CLEAR_EXPERIMENTAL_FLAGS);
    return result;
  }
}
