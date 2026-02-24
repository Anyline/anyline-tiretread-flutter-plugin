// ignore_for_file: avoid_dynamic_calls, inference_failure_on_untyped_parameter

/// Represents the complete tread depth measurement result from a tire scan.
///
/// Contains global measurements, regional measurements, and metadata about
/// the measurement process.
class TreadDepthResult {
  /// Creates a new instance of [TreadDepthResult].
  ///
  /// All parameters are optional and can be null if not available.
  TreadDepthResult({this.global, this.regions, this.measurementInfo});

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
  }

  /// Global (average) tread depth measurement across the entire tire.
  TreadResultRegion? global;

  /// List of regional tread depth measurements for specific tire sections.
  List<TreadResultRegion>? regions;

  /// Metadata about the measurement, including UUID and status.
  MeasurementInfo? measurementInfo;

  /// Gets the region with the minimum tread depth value.
  ///
  /// Returns the region with the lowest measurement among available regions,
  /// or the global measurement if no regional data is available.
  TreadResultRegion? get minimumValue {
    return regions?.where((region) => region.available).reduce(
            (current, next) =>
                current.valueMm < next.valueMm ? current : next) ??
        global;
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
    return data;
  }
}

/// Metadata about a tire tread measurement.
///
/// Contains the unique identifier for the measurement and its processing status.
class MeasurementInfo {
  /// Creates a new instance of [MeasurementInfo].
  MeasurementInfo({this.measurementUuid, this.status});

  /// Creates a [MeasurementInfo] from a JSON map.
  ///
  /// Parses the measurement UUID and status.
  MeasurementInfo.fromJson(Map<String, dynamic> json) {
    measurementUuid = json['measurementUuid'] as String;
    status = json['status'] as String;
  }

  /// Unique identifier for this measurement.
  String? measurementUuid;

  /// Processing status of the measurement (e.g., "completed", "processing").
  String? status;

  /// Converts this measurement info to a JSON map.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['measurementUuid'] = measurementUuid;
    data['status'] = status;
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
  TreadResultRegion.initGlobalMm(double value) {
    TreadResultRegion.initMm(available: true, valueMm: value);
  }

  /// Creates a global (average) measurement from an inch value.
  TreadResultRegion.initGlobalInch(double value) {
    TreadResultRegion.initInch(available: true, valueInch: value);
  }

  /// Creates a [TreadResultRegion] from a JSON map.
  ///
  /// Parses all measurement values in different units.
  TreadResultRegion.fromJson(Map<String, dynamic> json) {
    available = json['available'] as bool;
    valueMm = json['value_mm'] as double;
    valueInch = json['value_inch'] as double;
    valueInch32nds = json['value_inch_32nds'] as int;
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
