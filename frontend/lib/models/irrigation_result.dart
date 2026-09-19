class IrrigationFactorModel {
  final String parameter;
  final String measuredValue;
  final String targetOptimal;
  final String impact;

  IrrigationFactorModel({
    required this.parameter,
    required this.measuredValue,
    required this.targetOptimal,
    required this.impact,
  });

  factory IrrigationFactorModel.fromJson(Map<String, dynamic> json) {
    return IrrigationFactorModel(
      parameter: json['parameter'] ?? '',
      measuredValue: json['measured_value'] ?? '',
      targetOptimal: json['target_optimal'] ?? '',
      impact: json['impact'] ?? '',
    );
  }
}

class IrrigationResultModel {
  final String status; // IRRIGATE NOW, MONITOR, DELAY IRRIGATION
  final String actionUrgency;
  final double waterDeficitPercentage;
  final int recommendedDurationMinutes;
  final String recommendedMethod;
  final List<IrrigationFactorModel> factors;
  final String reasoning;
  final bool isDemo;
  final String timestamp;

  IrrigationResultModel({
    required this.status,
    required this.actionUrgency,
    required this.waterDeficitPercentage,
    required this.recommendedDurationMinutes,
    required this.recommendedMethod,
    required this.factors,
    required this.reasoning,
    required this.isDemo,
    required this.timestamp,
  });

  factory IrrigationResultModel.fromJson(Map<String, dynamic> json) {
    var fList = <IrrigationFactorModel>[];
    if (json['factors'] != null) {
      fList = (json['factors'] as List)
          .map((e) => IrrigationFactorModel.fromJson(e))
          .toList();
    }

    return IrrigationResultModel(
      status: json['status'] ?? 'MONITOR',
      actionUrgency: json['action_urgency'] ?? 'LOW',
      waterDeficitPercentage:
          (json['water_deficit_percentage'] as num?)?.toDouble() ?? 0.0,
      recommendedDurationMinutes:
          json['recommended_duration_minutes'] ?? 0,
      recommendedMethod: json['recommended_method'] ?? 'Drip Irrigation',
      factors: fList,
      reasoning: json['reasoning'] ?? '',
      isDemo: json['is_demo'] ?? false,
      timestamp: json['timestamp'] ?? '',
    );
  }
}
