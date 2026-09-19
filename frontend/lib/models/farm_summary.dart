class FieldModel {
  final int id;
  final String name;
  final String crop;
  final String? variety;
  final String growthStage;
  final double areaAcres;
  final String? soilType;

  FieldModel({
    required this.id,
    required this.name,
    required this.crop,
    this.variety,
    required this.growthStage,
    required this.areaAcres,
    this.soilType,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? '',
      crop: json['crop'] ?? 'Tomato',
      variety: json['variety'],
      growthStage: json['growth_stage'] ?? 'Flowering',
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 2.5,
      soilType: json['soil_type'],
    );
  }
}

class AlertModel {
  final int id;
  final String severity;
  final String title;
  final String message;
  final String? action;
  final String timestamp;

  AlertModel({
    required this.id,
    required this.severity,
    required this.title,
    required this.message,
    this.action,
    required this.timestamp,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? 0,
      severity: json['severity'] ?? 'MODERATE',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      action: json['action'],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class LatestSensorModel {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double rainfall;
  final bool isDemo;
  final String dataLabel;

  LatestSensorModel({
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.isDemo,
    required this.dataLabel,
  });

  factory LatestSensorModel.fromJson(Map<String, dynamic> json) {
    return LatestSensorModel(
      soilMoisture: (json['soil_moisture'] as num?)?.toDouble() ?? 30.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 60.0,
      rainfall: (json['rainfall'] as num?)?.toDouble() ?? 0.0,
      isDemo: json['is_demo'] ?? false,
      dataLabel: json['data_label'] ?? (json['is_demo'] == true ? 'DEMO SENSOR DATA' : 'REAL IOT DATA'),
    );
  }
}

class FarmSummaryModel {
  final String farmName;
  final String location;
  final double totalAreaAcres;
  final double overallFarmHealthScore;
  final double cropHealthScore;
  final String pestRisk;
  final String waterStatus;
  final String heatRisk;
  final String environmentalRisk;
  final int totalFields;
  final List<FieldModel> fields;
  final int activeAlertsCount;
  final List<AlertModel> recentAlerts;
  final LatestSensorModel latestSensor;
  final String timestamp;

  FarmSummaryModel({
    required this.farmName,
    required this.location,
    required this.totalAreaAcres,
    required this.overallFarmHealthScore,
    required this.cropHealthScore,
    required this.pestRisk,
    required this.waterStatus,
    required this.heatRisk,
    required this.environmentalRisk,
    required this.totalFields,
    required this.fields,
    required this.activeAlertsCount,
    required this.recentAlerts,
    required this.latestSensor,
    required this.timestamp,
  });

  factory FarmSummaryModel.fromJson(Map<String, dynamic> json) {
    var fieldList = <FieldModel>[];
    if (json['fields'] != null) {
      fieldList = (json['fields'] as List).map((e) => FieldModel.fromJson(e)).toList();
    }

    var alertList = <AlertModel>[];
    if (json['recent_alerts'] != null) {
      alertList = (json['recent_alerts'] as List).map((e) => AlertModel.fromJson(e)).toList();
    }

    return FarmSummaryModel(
      farmName: json['farm_name'] ?? 'AgriSync Farm',
      location: json['location'] ?? 'India',
      totalAreaAcres: (json['total_area_acres'] as num?)?.toDouble() ?? 10.0,
      overallFarmHealthScore: (json['overall_farm_health_score'] as num?)?.toDouble() ?? 85.0,
      cropHealthScore: (json['crop_health_score'] as num?)?.toDouble() ?? 90.0,
      pestRisk: json['pest_risk'] ?? 'LOW',
      waterStatus: json['water_status'] ?? 'OPTIMAL',
      heatRisk: json['heat_risk'] ?? 'LOW',
      environmentalRisk: json['environmental_risk'] ?? 'LOW',
      totalFields: json['total_fields'] ?? fieldList.length,
      fields: fieldList,
      activeAlertsCount: json['active_alerts_count'] ?? alertList.length,
      recentAlerts: alertList,
      latestSensor: LatestSensorModel.fromJson(json['latest_sensor'] ?? {}),
      timestamp: json['timestamp'] ?? '',
    );
  }
}
