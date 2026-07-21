// ignore_for_file: avoid_dynamic_calls, inference_failure_on_untyped_parameter

import 'package:anyline_tire_tread_plugin/src/enum/measurement_status.dart';
import 'package:anyline_tire_tread_plugin/src/models/additional_context.dart';
import 'package:anyline_tire_tread_plugin/src/models/measurement_metadata.dart';

/// Represents the complete tread depth measurement result from a tire scan.
///
/// Contains global measurements, regional measurements, and metadata about
/// the measurement process.
class TreadDepthResult {
  /// Creates a new instance of [TreadDepthResult].
  ///
  /// All parameters are optional and can be null if not available.
  TreadDepthResult(
      {this.global,
      this.regions,
      this.measurementInfo,
      this.measurementMetadata});

  /// Creates a [TreadDepthResult] from a JSON map.
  ///
  /// Parses global measurements, regional measurements, and measurement metadata.
  TreadDepthResult.fromJson(Map<String, dynamic> json) {
    global = json['global'] != null
        ? TreadResultRegion.fromJson(json['global'] as Map<String, dynamic>)
        : null;
    if (json['regions'] != null) {
      regions = (json['regions'] as List)
          .cast<Map<String, dynamic>>()
          .where((regionMap) => regionMap.isNotEmpty)
          .map((regionMap) => TreadResultRegion.fromJson(regionMap))
          .toList();
    }
    measurementInfo = json['measurementInfo'] != null
        ? MeasurementInfo.fromJson(
            json['measurementInfo'] as Map<String, dynamic>)
        : null;
    measurementMetadata = json['measurementMetadata'] != null
        ? MeasurementMetadata.fromJson(
            json['measurementMetadata'] as Map<String, dynamic>)
        : null;
  }

  /// Global (average) tread depth measurement across the entire tire.
  TreadResultRegion? global;

  /// List of regional tread depth measurements for specific tire sections.
  List<TreadResultRegion>? regions;

  /// Metadata about the measurement, including UUID and status.
  MeasurementInfo? measurementInfo;

  /// Capture metadata (e.g. movement direction). New in SDK v15.
  MeasurementMetadata? measurementMetadata;

  /// Gets the region with the minimum tread depth value.
  ///
  /// Returns the region with the lowest measurement among available regions,
  /// or the global measurement if no regional data is available.
  TreadResultRegion? get minimumValue {
    final availableRegions =
        regions?.where((region) => region.available).toList();
    if (availableRegions == null || availableRegions.isEmpty) {
      return global;
    }
    return availableRegions.reduce(
        (current, next) => current.valueMm < next.valueMm ? current : next);
  }

  /// Converts this result to a JSON map.
  ///
  /// Only includes non-null values in the output.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (global != null) {
      data['global'] = global!.toJson();
    }
    if (regions != null) {
      data['regions'] = regions!.map((v) => v.toJson()).toList();
    }
    if (measurementInfo != null) {
      data['measurementInfo'] = measurementInfo!.toJson();
    }
    if (measurementMetadata != null) {
      data['measurementMetadata'] = measurementMetadata!.toJson();
    }
    return data;
  }
}

/// Metadata about a tire tread measurement.
///
/// Contains the unique identifier for the measurement and its processing status.
class MeasurementInfo {
  /// Creates a new instance of [MeasurementInfo].
  MeasurementInfo({this.measurementUUID, this.status, this.additionalContext});

  /// Creates a [MeasurementInfo] from a JSON map.
  ///
  /// Parses the measurement UUID, typed [status] and any [additionalContext]
  /// the SDK echoes back.
  MeasurementInfo.fromJson(Map<String, dynamic> json) {
    measurementUUID = json['measurementUUID'] as String?;
    final rawStatus = json['status'] as String?;
    status = rawStatus == null ? null : MeasurementStatus.fromString(rawStatus);
    additionalContext = json['additionalContext'] != null
        ? AdditionalContext.fromJson(
            json['additionalContext'] as Map<String, dynamic>)
        : null;
  }

  /// Unique identifier for this measurement.
  String? measurementUUID;

  /// Typed processing status of the measurement.
  MeasurementStatus? status;

  /// Context the SDK echoes back (correlation ID, tire position).
  AdditionalContext? additionalContext;

  /// Converts this measurement info to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['measurementUUID'] = measurementUUID;
    if (status != null) data['status'] = status!.name;
    if (additionalContext != null) {
      data['additionalContext'] = additionalContext!.toJson();
    }
    return data;
  }
}

/// Represents a tread depth measurement for a specific region or the entire tire.
///
/// Stores depth values in multiple units: millimeters, inches, and 32nds of an inch.
class TreadResultRegion {
  /// Creates a new instance of [TreadResultRegion] with default values.
  TreadResultRegion(
      {this.available = false,
      this.valueMm = 0.0,
      this.valueInch = 0.0,
      this.valueInch32nds = 0});

  /// Creates a [TreadResultRegion] from a millimeter value.
  ///
  /// Automatically converts to inch and 32nds of inch.
  TreadResultRegion.initMm({required this.available, required this.valueMm}) {
    valueInch = valueMm / 25.4;
    millimeterToInch32nds();
  }

  /// Creates a [TreadResultRegion] from an inch value.
  ///
  /// Automatically converts to millimeters and 32nds of inch.
  TreadResultRegion.initInch(
      {required this.available, required this.valueInch}) {
    valueMm = (valueInch * 25.4);
    millimeterToInch32nds();
  }

  /// Creates a global (average) measurement from a millimeter value.
  TreadResultRegion.initGlobalMm(double value)
      : this.initMm(available: true, valueMm: value);

  /// Creates a global (average) measurement from an inch value.
  TreadResultRegion.initGlobalInch(double value)
      : this.initInch(available: true, valueInch: value);

  /// Creates a [TreadResultRegion] from a JSON map.
  ///
  /// SDK v15 omits fields that equal their defaults (`available=false`,
  /// `value_mm=0.0`, ...) from the serialized JSON, so every field must be
  /// treated as optional. Missing unit conversions are derived from
  /// `value_mm`.
  TreadResultRegion.fromJson(Map<String, dynamic> json) {
    available = json['available'] as bool? ?? false;
    valueMm = (json['value_mm'] as num?)?.toDouble() ?? 0.0;
    valueInch = (json['value_inch'] as num?)?.toDouble() ?? valueMm / 25.4;
    valueInch32nds = (json['value_inch_32nds'] as num?)?.toInt() ??
        (valueMm / 25.4 * 32).round();
  }

  /// Converts the millimeter value to 32nds of an inch.
  ///
  /// Updates the [valueInch32nds] property based on the current [valueMm].
  void millimeterToInch32nds() {
    var inch = valueMm / 25.4;
    var inch32nds = (inch * 32).round();
    valueInch32nds = inch32nds.toInt();
  }

  /// Whether this measurement is available and valid.
  bool available = false;

  /// Tread depth value in millimeters.
  double valueMm = 0.0;

  /// Tread depth value in inches.
  double valueInch = 0.0;

  /// Tread depth value in 32nds of an inch (common US tire measurement).
  int valueInch32nds = 0;

  /// Converts this region to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['available'] = available;
    data['value_mm'] = valueMm;
    data['value_inch'] = valueInch;
    data['value_inch_32nds'] = valueInch32nds;
    return data;
  }
}
