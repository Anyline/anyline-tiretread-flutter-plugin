// ignore_for_file: avoid_dynamic_calls, inference_failure_on_untyped_parameter

class TreadDepthResult {
  TreadDepthResult({this.global, this.regions, this.measurementInfo});

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

  TreadResultRegion? global;
  List<TreadResultRegion>? regions;
  MeasurementInfo? measurementInfo;

  TreadResultRegion? get minimumValue {
    return regions?.where((region) => region.available).reduce(
            (current, next) =>
                current.valueMm < next.valueMm ? current : next) ??
        global;
  }

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

class MeasurementInfo {
  MeasurementInfo({this.measurementUuid, this.status});

  MeasurementInfo.fromJson(Map<String, dynamic> json) {
    measurementUuid = json['measurementUuid'] as String;
    status = json['status'] as String;
  }

  String? measurementUuid;
  String? status;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['measurementUuid'] = measurementUuid;
    data['status'] = status;
    return data;
  }
}

class TreadResultRegion {
  TreadResultRegion(
      {this.available = false,
      this.valueMm = 0.0,
      this.valueInch = 0.0,
      this.valueInch32nds = 0});

  TreadResultRegion.initMm({required this.available, required this.valueMm}) {
    valueInch = valueMm / 25.4;
    millimeterToInch32nds();
  }

  TreadResultRegion.initInch(
      {required this.available, required this.valueInch}) {
    valueMm = (valueInch * 25.4);
    millimeterToInch32nds();
  }

  TreadResultRegion.initGlobalMm(double value) {
    TreadResultRegion.initMm(available: true, valueMm: value);
  }

  TreadResultRegion.initGlobalInch(double value) {
    TreadResultRegion.initInch(available: true, valueInch: value);
  }

  TreadResultRegion.fromJson(Map<String, dynamic> json) {
    available = json['available'] as bool;
    valueMm = json['value_mm'] as double;
    valueInch = json['value_inch'] as double;
    valueInch32nds = json['value_inch_32nds'] as int;
  }

  void millimeterToInch32nds() {
    var inch = valueMm / 25.4;
    var inch32nds = (inch * 32).round();
    valueInch32nds = inch32nds.toInt();
  }

  bool available = false;
  double valueMm = 0.0;
  double valueInch = 0.0;
  int valueInch32nds = 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['available'] = available;
    data['value_mm'] = valueMm;
    data['value_inch'] = valueInch;
    data['value_inch_32nds'] = valueInch32nds;
    return data;
  }
}
