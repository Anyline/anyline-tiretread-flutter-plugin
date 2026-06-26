import 'package:anyline_tire_tread_plugin/src/models/sdk_error.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_config.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_support.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_sidewall_texts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TireSidewallConfig.toJson', () {
    test('omits texts and correlationId when nothing is set', () {
      final json = TireSidewallConfig().toJson();
      expect(json, isEmpty);
    });

    test('includes correlationId when set', () {
      final json = (TireSidewallConfig()..correlationId = 'corr-1').toJson();
      expect(json['correlationId'], 'corr-1');
      expect(json.containsKey('texts'), isFalse);
    });

    test('nests only the overridden texts', () {
      final config = TireSidewallConfig()
        ..texts = (TireSidewallTexts()..alignTire = 'Align the tire');
      final json = config.toJson();
      final texts = json['texts'] as Map<String, dynamic>;
      expect(texts, {'alignTire': 'Align the tire'});
      expect(json.containsKey('correlationId'), isFalse);
    });

    test('omits the texts key when no text is overridden', () {
      final config = TireSidewallConfig()..texts = TireSidewallTexts();
      expect(config.toJson().containsKey('texts'), isFalse);
    });

    test('serializes both texts and correlationId together', () {
      final config = TireSidewallConfig()
        ..correlationId = 'corr-2'
        ..texts = (TireSidewallTexts()..holdSteady = 'Hold steady');
      final json = config.toJson();
      expect(json['correlationId'], 'corr-2');
      expect((json['texts'] as Map<String, dynamic>)['holdSteady'],
          'Hold steady');
    });
  });

  group('TireSidewallTexts.toJson', () {
    test('is empty when no string is overridden', () {
      expect(TireSidewallTexts().toJson(), isEmpty);
    });

    test('serializes only the non-null strings', () {
      final texts = TireSidewallTexts()
        ..initializing = 'Init'
        ..tooDark = 'Too dark';
      expect(texts.toJson(), {'initializing': 'Init', 'tooDark': 'Too dark'});
    });

    test('serializes every string when all are set', () {
      final texts = TireSidewallTexts()
        ..initializing = 'a'
        ..alignTire = 'b'
        ..moveCloser = 'c'
        ..moveAway = 'd'
        ..faceTire = 'e'
        ..ready = 'f'
        ..holdSteady = 'g'
        ..focusing = 'h'
        ..calibratingWhiteBalance = 'i'
        ..calibratingExposure = 'j'
        ..tooDark = 'k';
      final json = texts.toJson();
      expect(json.length, 11);
      expect(json['calibratingWhiteBalance'], 'i');
      expect(json['calibratingExposure'], 'j');
    });
  });

  group('TireSidewallSupport.fromMap', () {
    test('parses a supported status', () {
      final support = TireSidewallSupport.fromMap({'supported': true});
      expect(support.supported, true);
      expect(support.userResolvable, false);
      expect(support.error, isNull);
    });

    test('parses an unavailable, user-resolvable status with an error', () {
      final support = TireSidewallSupport.fromMap({
        'supported': false,
        'userResolvable': true,
        'error': {
          'code': 'PLAY_SERVICES_UNAVAILABLE',
          'type': 'SCAN_ERROR',
          'message': 'Update Play Services',
        },
      });
      expect(support.supported, false);
      expect(support.userResolvable, true);
      expect(support.error?.code, ErrorCode.playServicesUnavailable);
    });

    test('defaults missing fields to unsupported and not user-resolvable', () {
      final support = TireSidewallSupport.fromMap(<String, dynamic>{});
      expect(support.supported, false);
      expect(support.userResolvable, false);
      expect(support.error, isNull);
    });
  });
}