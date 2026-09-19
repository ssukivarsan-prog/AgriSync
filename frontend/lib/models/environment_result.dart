class RiskDetailModel {
  final String category;
  final String level; // LOW, MODERATE, HIGH
  final double score;
  final String indicator;
  final String why;
  final String action;

  RiskDetailModel({
    required this.category,
    required this.level,
    required this.score,
    required this.indicator,
    required this.why,
    required this.action,
  });

  factory RiskDetailModel.fromJson(Map<String, dynamic> json) {
    return RiskDetailModel(
      category: json['category'] ?? '',
      level: json['level'] ?? 'LOW',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      indicator: json['indicator'] ?? '',
      why: json['why'] ?? '',
      action: json['action'] ?? '',
    );
  }
}

class EnvironmentResultModel {
  final String overallEnvironmentalRisk;
  final double overallRiskScore;
  final RiskDetailModel droughtRisk;
  final RiskDetailModel heatStress;
  final RiskDetailModel floodRisk;
  final RiskDetailModel diseaseFavorable;
  final RiskDetailModel generalCropStress;
  final String explanationSummary;
  final List<String> recommendedMitigation;
  final bool isDemo;
  final String timestamp;

  EnvironmentResultModel({
    required this.overallEnvironmentalRisk,
    required this.overallRiskScore,
    required this.droughtRisk,
    required this.heatStress,
    required this.floodRisk,
    required this.diseaseFavorable,
    required this.generalCropStress,
    required this.explanationSummary,
    required this.recommendedMitigation,
    required this.isDemo,
    required this.timestamp,
  });

  factory EnvironmentResultModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentResultModel(
      overallEnvironmentalRisk: json['overall_environmental_risk'] ?? 'LOW',
      overallRiskScore: (json['overall_risk_score'] as num?)?.toDouble() ?? 0.0,
      droughtRisk: RiskDetailModel.fromJson(json['drought_risk'] ?? {}),
      heatStress: RiskDetailModel.fromJson(json['heat_stress'] ?? {}),
      floodRisk: RiskDetailModel.fromJson(json['flood_risk'] ?? {}),
      diseaseFavorable: RiskDetailModel.fromJson(json['disease_favorable'] ?? {}),
      generalCropStress: RiskDetailModel.fromJson(json['general_crop_stress'] ?? {}),
      explanationSummary: json['explanation_summary'] ?? '',
      recommendedMitigation: (json['recommended_mitigation'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isDemo: json['is_demo'] ?? false,
      timestamp: json['timestamp'] ?? '',
    );
  }
}
