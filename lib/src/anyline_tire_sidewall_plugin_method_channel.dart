import 'dart:convert';

import 'package:anyline_tire_tread_plugin/src/anyline_tire_sidewall_plugin_platform_interface.dart';
import 'package:anyline_tire_tread_plugin/src/models/sdk_error.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_support.dart';
import 'package:anyline_tire_tread_plugin/src/sidewall_constants.dart';
import 'package:anyline_tire_tread_plugin/src/tire_sidewall_outcome.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Method-channel implementation for the Tire Sidewall (TSW) scanner.
///
/// Talks over the dedicated `anyline_tire_sidewall_plugin` channel, kept
/// separate from the tire-tread channel.
class MethodChannelAnylineTireSidewallPlugin
    extends AnylineTireSidewallPluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('anyline_tire_sidewall_plugin');

  @override
  Future<TswScanOutcome> scan(
      {required String clientId, TireSidewallConfig? config}) async {
    final result = await methodChannel
        .invokeMapMethod<String, dynamic>(SidewallConstants.METHOD_SCAN, {
      SidewallConstants.EXTRA_CLIENT_ID: clientId,
      SidewallConstants.EXTRA_CONFIG_JSON:
          config == null ? null : jsonEncode(config.toJson()),
    });
    if (result == null) {
      return const TswScanFailed(
        error: SdkError(
          code: ErrorCode.unknownError,
          type: ErrorType.scanError,
          message: 'Sidewall scan returned null',
        ),
      );
    }
    return TswScanOutcome.fromMap(result);
  }

  @override
  Future<TireSidewallSupport> isSupported() async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
        SidewallConstants.METHOD_IS_SUPPORTED);
    if (result == null) {
      return const TireSidewallSupport(supported: false);
    }
    return TireSidewallSupport.fromMap(result);
  }

  @override
  Future<void> resolvePlayServices() async {
    await methodChannel
        .invokeMethod<void>(SidewallConstants.METHOD_RESOLVE_PLAY_SERVICES);
  }
}
