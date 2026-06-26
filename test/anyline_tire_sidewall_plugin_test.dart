import 'dart:typed_data';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_sidewall_plugin_method_channel.dart';
import 'package:anyline_tire_tread_plugin/src/anyline_tire_sidewall_plugin_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAnylineTireSidewallPluginPlatform
    with MockPlatformInterfaceMixin
    implements AnylineTireSidewallPluginPlatform {
  String? lastClientId;
  TireSidewallConfig? lastConfig;
  int resolvePlayServicesCalls = 0;

  @override
  Future<TswScanOutcome> scan(
      {required String clientId, TireSidewallConfig? config}) {
    lastClientId = clientId;
    lastConfig = config;
    return Future.value(
      TswScanCompleted(resultJson: '{}', imageBytes: Uint8List(0)),
    );
  }

  @override
  Future<TireSidewallSupport> isSupported() {
    return Future.value(const TireSidewallSupport(supported: true));
  }

  @override
  Future<void> resolvePlayServices() {
    resolvePlayServicesCalls++;
    return Future.value();
  }
}

void main() {
  final AnylineTireSidewallPluginPlatform initialPlatform =
      AnylineTireSidewallPluginPlatform.instance;

  test('$MethodChannelAnylineTireSidewallPlugin is the default instance', () {
    expect(initialPlatform,
        isInstanceOf<MethodChannelAnylineTireSidewallPlugin>());
  });

  group('TireSidewallPlugin', () {
    late MockAnylineTireSidewallPluginPlatform mock;
    late TireSidewallPlugin plugin;

    setUp(() {
      mock = MockAnylineTireSidewallPluginPlatform();
      AnylineTireSidewallPluginPlatform.instance = mock;
      plugin = TireSidewallPlugin();
    });

    tearDown(() {
      AnylineTireSidewallPluginPlatform.instance = initialPlatform;
    });

    test('scan forwards clientId and config to the platform', () async {
      final config = TireSidewallConfig()..correlationId = 'corr-1';

      final outcome = await plugin.scan(clientId: 'client-9', config: config);

      expect(outcome, isA<TswScanCompleted>());
      expect(mock.lastClientId, 'client-9');
      expect(mock.lastConfig, same(config));
    });

    test('scan forwards a null config when none is provided', () async {
      await plugin.scan(clientId: 'client-9');

      expect(mock.lastClientId, 'client-9');
      expect(mock.lastConfig, isNull);
    });

    test('isSupported delegates to the platform', () async {
      final support = await plugin.isSupported();

      expect(support.supported, true);
    });

    test('resolvePlayServices delegates to the platform', () async {
      await plugin.resolvePlayServices();

      expect(mock.resolvePlayServicesCalls, 1);
    });
  });
}