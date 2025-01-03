import 'dart:convert';

import 'package:anyline_tire_tread_plugin/src/constants.dart';
import 'package:anyline_tire_tread_plugin/src/models/scan_options.dart';
import 'package:anyline_tire_tread_plugin/src/scanning_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:anyline_tire_tread_plugin/src/anyline_tire_tread_plugin_platform_interface.dart';

/// An implementation of [AnylineTireTreadPluginPlatform] that uses method channels.
class MethodChannelAnylineTireTreadPlugin extends AnylineTireTreadPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('anyline_tire_tread_plugin');

  final _eventsChannel = const EventChannel('anyline_tire_tread_plugin/events');

  @override
  Future<String?> getSdkVersion() async {
    final version = await methodChannel.invokeMethod<String>(Constants.METHOD_GET_SDK_VERSION);
    return version;
  }

  @override
  Future<bool?> initialize({required String licenseKey}) async {
    final result =
        await methodChannel.invokeMethod<bool>(Constants.METHOD_INITIALIZE, {Constants.EXTRA_LICENSE_KEY: licenseKey});
    return result;
  }

  @override
  Future<bool?> scan({required ScanOptions options}) async {
    final result = await methodChannel.invokeMethod<bool>(Constants.METHOD_SCAN, options.toJson());
    return result;
  }

  @override
  Future<String?> getResult({required String measurementUUID}) async {
    final version = await methodChannel
        .invokeMethod<String>(Constants.METHOD_GET_RESULT, {Constants.EXTRA_MEASUREMENT_UUID: measurementUUID});
    return version;
  }

  @override
  Future<String?> getHeatMap({required String measurementUUID}) async {
    final version = await methodChannel
        .invokeMethod<String>(Constants.METHOD_GET_HEATMAP, {Constants.EXTRA_MEASUREMENT_UUID: measurementUUID});
    return version;
  }

  @override
  Stream<ScanningEvent> get onScanningEvent {
    return _eventsChannel.receiveBroadcastStream().map((event) {
      final Map<String, dynamic> eventType = jsonDecode(event as String) as Map<String, dynamic>;
      String measurementResultStatus = (eventType['measurementResultStatus']['type'] as String).split('.').last;
      switch (measurementResultStatus) {
        case 'ScanningAborted':
          return ScanningAborted.fromMap(eventType);
        case 'UploadAborted':
          return UploadAbortedEvent.fromMap(eventType);
        case 'UploadCompleted':
          return UploadCompletedEvent.fromMap(eventType);
        case 'UploadFailed':
          return UploadFailedEvent.fromMap(eventType);
        default:
          return ScanningAborted.fromMap(eventType);
      }
    });
  }
}
