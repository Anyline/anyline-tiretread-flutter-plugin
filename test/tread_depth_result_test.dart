import 'package:anyline_tire_tread_plugin/src/enum/measurement_status.dart';
import 'package:anyline_tire_tread_plugin/src/enum/movement_direction.dart';
import 'package:anyline_tire_tread_plugin/src/models/tread_depth_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// SDK v15 serializes results with kotlinx `encodeDefaults=false`, so any
/// field that equals its default (`available=false`, `value_mm=0.0`,
/// `value_inch=0.0`, `value_inch_32nds=0`) is OMITTED from the JSON.
/// Parsing must tolerate partially-present region maps.
void main() {
  group('TreadResultRegion.fromJson (v15 partial JSON)', () {
    test('parses fully populated region', () {
      final region = TreadResultRegion.fromJson({
        'available': true,
        'value_mm': 4.2,
        'value_inch': 0.16535433070866143,
        'value_inch_32nds': 5,
      });
      expect(region.available, true);
      expect(region.valueMm, 4.2);
      expect(region.valueInch32nds, 5);
    });

    test('tolerates omitted "available" (default false, non-zero value)', () {
      // SDK omits available=false; value_mm present.
      final region = TreadResultRegion.fromJson({
        'value_mm': 3.0,
        'value_inch': 0.11811023622047245,
        'value_inch_32nds': 4,
      });
      expect(region.available, false);
      expect(region.valueMm, 3.0);
    });

    test('tolerates omitted value fields (available=true, 0.0 mm reading)', () {
      // Fully worn tire: value_mm == 0.0 is omitted by the SDK serializer.
      final region = TreadResultRegion.fromJson({'available': true});
      expect(region.available, true);
      expect(region.valueMm, 0.0);
      expect(region.valueInch, 0.0);
      expect(region.valueInch32nds, 0);
    });

    test('tolerates integer-encoded numeric values', () {
      final region = TreadResultRegion.fromJson({
        'available': true,
        'value_mm': 4,
        'value_inch_32nds': 5,
      });
      expect(region.valueMm, 4.0);
    });
  });

  group('MeasurementInfo (v15 typed status + additionalContext)', () {
    test('parses typed status and additionalContext', () {
      final info = MeasurementInfo.fromJson({
        'measurementUUID': 'uuid-2',
        'status': 'ResultReady',
        'additionalContext': {'correlationId': 'corr-1'},
      });
      expect(info.measurementUUID, 'uuid-2');
      expect(info.status, MeasurementStatus.ResultReady);
      expect(info.additionalContext?.correlationId, 'corr-1');
    });

    test('status parsing is case-insensitive', () {
      final info = MeasurementInfo.fromJson({'status': 'resultandreportready'});
      expect(info.status, MeasurementStatus.ResultAndReportReady);
    });

    test('unrecognized status -> Unknown; absent status -> null', () {
      expect(MeasurementInfo.fromJson({'status': 'wat'}).status,
          MeasurementStatus.Unknown);
      expect(MeasurementInfo.fromJson({'measurementUUID': 'x'}).status, isNull);
    });
  });

  group('MeasurementMetadata / MovementDirection (v15)', () {
    test('parses measurementMetadata.movementDirection', () {
      final result = TreadDepthResult.fromJson({
        'global': {'available': true, 'value_mm': 4.0},
        'measurementMetadata': {'movementDirection': 'LeftToRight'},
      });
      expect(result.measurementMetadata?.movementDirection,
          MovementDirection.LeftToRight);
    });

    test('movementDirection case-insensitive; metadata absent -> null', () {
      expect(
          TreadDepthResult.fromJson({
            'measurementMetadata': {'movementDirection': 'righttoleft'}
          }).measurementMetadata?.movementDirection,
          MovementDirection.RightToLeft);
      expect(
          TreadDepthResult.fromJson({
            'global': {'available': true}
          }).measurementMetadata,
          isNull);
    });
  });

  group('TreadResultRegion global initializers', () {
    test('initGlobalMm sets available + value and derives units', () {
      final region = TreadResultRegion.initGlobalMm(7.5);
      expect(region.available, true);
      expect(region.valueMm, 7.5);
      expect(region.valueInch, closeTo(7.5 / 25.4, 1e-9));
      expect(region.valueInch32nds, (7.5 / 25.4 * 32).round());
    });

    test('initGlobalInch sets available + value and derives mm', () {
      final region = TreadResultRegion.initGlobalInch(0.25);
      expect(region.available, true);
      expect(region.valueInch, 0.25);
      expect(region.valueMm, closeTo(0.25 * 25.4, 1e-9));
      expect(region.valueInch32nds, 8);
    });
  });

  group('TreadDepthResult.fromJson (v15 payload)', () {
    test('parses result with empty (all-defaults) regions filtered out', () {
      final result = TreadDepthResult.fromJson({
        'global': {'available': true, 'value_mm': 4.2},
        'regions': [
          <String, dynamic>{},
          {'available': true, 'value_mm': 3.1},
        ],
        'measurementInfo': {
          'measurementUUID': 'uuid-1',
          'status': 'ResultReady',
        },
      });
      expect(result.global?.valueMm, 4.2);
      expect(result.regions, hasLength(1));
      expect(result.measurementInfo?.measurementUUID, 'uuid-1');
    });

    test('minimumValue falls back to global when no region is available', () {
      final result = TreadDepthResult.fromJson({
        'global': {'available': true, 'value_mm': 4.2},
        'regions': [
          {'value_mm': 2.5}, // available omitted -> false
        ],
      });
      expect(result.minimumValue?.valueMm, 4.2);
    });

    test('minimumValue picks lowest available region', () {
      final result = TreadDepthResult.fromJson({
        'global': {'available': true, 'value_mm': 4.2},
        'regions': [
          {'available': true, 'value_mm': 3.1},
          {'available': true, 'value_mm': 2.8},
          {'value_mm': 0.5}, // not available, must be ignored
        ],
      });
      expect(result.minimumValue?.valueMm, 2.8);
    });

    test('parses result with partial region maps without crashing', () {
      final result = TreadDepthResult.fromJson({
        'global': {'available': true},
        'regions': [
          {'value_mm': 2.5},
          {'available': true},
        ],
      });
      expect(result.regions, hasLength(2));
      expect(result.regions![0].available, false);
      expect(result.regions![0].valueMm, 2.5);
      expect(result.regions![1].available, true);
      expect(result.regions![1].valueMm, 0.0);
    });
  });
}
