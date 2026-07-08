// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin/src/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';

class MethodChannelAnylineTireTreadPlugin
    extends AnylineTireTreadPluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('anyline_tire_tread_plugin');

  @override
  Future<String?> getSdkVersion() async {
    final version = await methodChannel
        .invokeMethod<String>(Constants.METHOD_GET_SDK_VERSION);
    return version;
  }

  @override
  Future<bool?> initialize(
      {required String licenseKey,
      required String pluginVersion,
      String? customTag,
      int? uploadTimeoutMillis}) async {
    final result =
        await methodChannel.invokeMethod<bool>(Constants.METHOD_INITIALIZE, {
      Constants.EXTRA_LICENSE_KEY: licenseKey,
      Constants.EXTRA_PLUGIN_VERSION: pluginVersion,
      Constants.EXTRA_CUSTOM_TAG: customTag,
      Constants.EXTRA_UPLOAD_TIMEOUT_MILLIS: uploadTimeoutMillis,
    });
    return result;
  }

  @override
  Future<ScanOutcome> scan(
      {required TireTreadConfig config, ScanOptions? options}) async {
    final result = await methodChannel
        .invokeMapMethod<String, dynamic>(Constants.METHOD_SCAN, {
      Constants.EXTRA_CONFIG_JSON: jsonEncode(config.toJson()),
      Constants.EXTRA_SCAN_OPTIONS_JSON:
          options == null ? null : jsonEncode(options.toJson()),
    });
    if (result == null) {
      return const ScanFailed(
        measurementUUID: null,
        error: SdkError(
          code: ErrorCode.unknownError,
          type: ErrorType.scanError,
          message: 'Scan returned null',
        ),
      );
    }
    return ScanOutcome.fromMap(result);
  }

  @override
  Future<bool> isDeviceSupported() async {
    final result = await methodChannel
        .invokeMethod<bool>(Constants.METHOD_IS_DEVICE_SUPPORTED);
    return result ?? false;
  }

  @override
  Future<TreadDepthResult?> getResult(
      {required String measurementUUID, int? timeoutSeconds}) async {
    final args = <String, dynamic>{
      Constants.EXTRA_MEASUREMENT_UUID: measurementUUID,
    };
    if (timeoutSeconds != null) {
      args[Constants.EXTRA_TIMEOUT_SECONDS] = timeoutSeconds;
    }
    final result = await methodChannel.invokeMethod<String>(
        Constants.METHOD_GET_RESULT, args);
    if (result == null) {
      return null;
    }
    return TreadDepthResult.fromJson(
        jsonDecode(result) as Map<String, dynamic>);
  }

  @override
  Future<String?> getHeatMap(
      {required String measurementUUID, int? timeoutSeconds}) async {
    final args = <String, dynamic>{
      Constants.EXTRA_MEASUREMENT_UUID: measurementUUID,
    };
    if (timeoutSeconds != null) {
      args[Constants.EXTRA_TIMEOUT_SECONDS] = timeoutSeconds;
    }
    final result = await methodChannel.invokeMethod<String>(
        Constants.METHOD_GET_HEATMAP, args);
    return result;
  }

  @override
  Future<MeasurementInfo?> sendFeedbackComment(
      {required String measurementUUID, required String comment}) async {
    final result = await methodChannel
        .invokeMethod<String>(Constants.METHOD_SEND_FEEDBACK_COMMENT, {
      Constants.EXTRA_MEASUREMENT_UUID: measurementUUID,
      Constants.EXTRA_FEEDBACK_COMMENT: comment
    });
    return _parseMeasurementInfo(result);
  }

  @override
  Future<MeasurementInfo?> sendTreadDepthResultFeedback(
      {required String measurementUUID,
      required List<TreadResultRegion> resultRegions}) async {
    final result = await methodChannel.invokeMethod<String>(
        Constants.METHOD_SEND_TREAD_DEPTH_RESULT_FEEDBACK, {
      Constants.EXTRA_MEASUREMENT_UUID: measurementUUID,
      Constants.EXTRA_TREAD_DEPTH_RESULT_FEEDBACK:
          jsonEncode(resultRegions.map((obj) => obj.toJson()).toList())
    });
    return _parseMeasurementInfo(result);
  }

  @override
  Future<MeasurementInfo?> sendTireIdFeedback(
      {required String measurementUUID, required String tireId}) async {
    final result = await methodChannel
        .invokeMethod<String>(Constants.METHOD_SEND_TIRE_ID_FEEDBACK, {
      Constants.EXTRA_MEASUREMENT_UUID: measurementUUID,
      Constants.EXTRA_TIRE_ID: tireId
    });
    return _parseMeasurementInfo(result);
  }

  /// Parses a feedback reply. Native returns the updated [MeasurementInfo] as a
  /// JSON string (or a bare measurement UUID for backward compatibility).
  MeasurementInfo? _parseMeasurementInfo(String? raw) {
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return MeasurementInfo.fromJson(Map<String, dynamic>.from(decoded));
      }
    } on FormatException {
      // Not JSON — fall through to treat it as a bare UUID.
    }
    return MeasurementInfo(measurementUUID: raw);
  }

  @override
  Future<void> setExperimentalFlags(
      {required List<String> experimentalFlags}) async {
    await methodChannel.invokeMethod<void>(
        Constants.METHOD_SET_EXPERIMENTAL_FLAGS,
        {Constants.EXTRA_EXPERIMENTAL_FLAGS: experimentalFlags});
  }

  @override
  Future<void> clearExperimentalFlags() async {
    await methodChannel
        .invokeMethod<void>(Constants.METHOD_CLEAR_EXPERIMENTAL_FLAGS);
  }
}
