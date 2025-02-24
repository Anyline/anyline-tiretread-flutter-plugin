// ignore_for_file: avoid_dynamic_calls, inference_failure_on_untyped_parameter

class TreadDepthResult {
  TreadDepthResult({this.global, this.regions, this.measurementInfo});

  TreadDepthResult.fromJson(Map<String, dynamic> json) {
    global = json['global'] != null
        ? TreadResultRegion.fromJson(json['global'] as Map<String, dynamic>)
        : null;
    if (json['regions'] != null) {
      regions = <TreadResultRegion>[];
      json['regions'].forEach((v) {
        regions!.add(TreadResultRegion.fromJson(v as Map<String, dynamic>));
      });
    }
    measurementInfo = json['measurementInfo'] != null
        ? MeasurementInfo.fromJson(
            json['measurementInfo'] as Map<String, dynamic>)
        : null;
  }

  TreadResultRegion? global;
  List<TreadResultRegion>? regions;
  MeasurementInfo? measurementInfo;

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
      {this.available, this.valueMm, this.valueInch, this.valueInch32nds});

  TreadResultRegion.initMm({this.available, this.valueMm});

  TreadResultRegion.initInch({this.available, this.valueInch});

  TreadResultRegion.fromJson(Map<String, dynamic> json) {
    available = json['available'] as bool?;
    valueMm = json['value_mm'] as double?;
    valueInch = json['value_inch'] as double?;
    valueInch32nds = json['value_inch_32nds'] as int?;
  }

  bool? available = false;
  double? valueMm = 0.0;
  double? valueInch = 0.0;
  int? valueInch32nds = 0;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['available'] = available;
    data['value_mm'] = valueMm;
    data['value_inch'] = valueInch;
    data['value_inch_32nds'] = valueInch32nds;
    return data;
  }
}
