class DetectionBoxModel {
  final String className;
  final double confidence;
  final List<double> bbox;

  DetectionBoxModel({
    required this.className,
    required this.confidence,
    required this.bbox,
  });

  factory DetectionBoxModel.fromJson(Map<String, dynamic> json) {
    return DetectionBoxModel(
      className: json['class_name'] ?? 'Pest',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      bbox: (json['bbox'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}

class TopPredictionModel {
  final String label;
  final double confidence;
  final String? crop;
  final String? condition;

  TopPredictionModel({
    required this.label,
    required this.confidence,
    this.crop,
    this.condition,
  });

  factory TopPredictionModel.fromJson(Map<String, dynamic> json) {
    return TopPredictionModel(
      label: json['label'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      crop: json['crop'],
      condition: json['condition'],
    );
  }
}

class DiseasePredictionModel {
  final String crop;
  final String prediction;
  final double confidence;
  final String healthStatus;
  final String confidenceTier;
  final List<TopPredictionModel> topPredictions;
  final String recommendation;
  final bool isUncertain;

  DiseasePredictionModel({
    required this.crop,
    required this.prediction,
    required this.confidence,
    required this.healthStatus,
    required this.confidenceTier,
    required this.topPredictions,
    required this.recommendation,
    required this.isUncertain,
  });

  factory DiseasePredictionModel.fromJson(Map<String, dynamic> json) {
    var topList = <TopPredictionModel>[];
    if (json['top_predictions'] != null) {
      topList = (json['top_predictions'] as List)
          .map((e) => TopPredictionModel.fromJson(e))
          .toList();
    }
    return DiseasePredictionModel(
      crop: json['crop'] ?? 'Crop',
      prediction: json['prediction'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      healthStatus: json['health_status'] ?? 'UNCERTAIN',
      confidenceTier: json['confidence_tier'] ?? 'UNCERTAIN',
      topPredictions: topList,
      recommendation: json['recommendation'] ?? '',
      isUncertain: json['is_uncertain'] ?? false,
    );
  }
}

class PestPredictionModel {
  final List<DetectionBoxModel> detections;
  final int pestCount;
  final String? primaryPest;
  final double confidence;
  final String infestationRisk;
  final String explanation;

  PestPredictionModel({
    required this.detections,
    required this.pestCount,
    this.primaryPest,
    required this.confidence,
    required this.infestationRisk,
    required this.explanation,
  });

  factory PestPredictionModel.fromJson(Map<String, dynamic> json) {
    var boxList = <DetectionBoxModel>[];
    if (json['detections'] != null) {
      boxList = (json['detections'] as List)
          .map((e) => DetectionBoxModel.fromJson(e))
          .toList();
    }
    return PestPredictionModel(
      detections: boxList,
      pestCount: json['pest_count'] ?? 0,
      primaryPest: json['primary_pest'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      infestationRisk: json['infestation_risk'] ?? 'LOW',
      explanation: json['explanation'] ?? '',
    );
  }
}

class NutrientPredictionModel {
  final String crop;
  final String deficiency;
  final double confidence;
  final String visualIndication;
  final String verificationRecommendation;
  final String nextAction;

  NutrientPredictionModel({
    required this.crop,
    required this.deficiency,
    required this.confidence,
    required this.visualIndication,
    required this.verificationRecommendation,
    required this.nextAction,
  });

  factory NutrientPredictionModel.fromJson(Map<String, dynamic> json) {
    return NutrientPredictionModel(
      crop: json['crop'] ?? 'Crop',
      deficiency: json['deficiency'] ?? 'Optimal',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      visualIndication: json['visual_indication'] ?? '',
      verificationRecommendation: json['verification_recommendation'] ?? '',
      nextAction: json['next_action'] ?? '',
    );
  }
}

class SegmentationPredictionModel {
  final double affectedAreaPercentage;
  final int lesionCount;
  final String severityCategory;
  final String explanation;

  SegmentationPredictionModel({
    required this.affectedAreaPercentage,
    required this.lesionCount,
    required this.severityCategory,
    required this.explanation,
  });

  factory SegmentationPredictionModel.fromJson(Map<String, dynamic> json) {
    return SegmentationPredictionModel(
      affectedAreaPercentage:
          (json['affected_area_percentage'] as num?)?.toDouble() ?? 0.0,
      lesionCount: json['lesion_count'] ?? 0,
      severityCategory: json['severity_category'] ?? 'NONE',
      explanation: json['explanation'] ?? '',
    );
  }
}

class PathogenRootCauseModel {
  final String pathogenName;
  final String primaryCause;
  final String environmentalTriggers;
  final String climateWeather;
  final String soilMetrics;
  final String airMoistureHumidity;
  final String socialSurroundings;

  PathogenRootCauseModel({
    required this.pathogenName,
    required this.primaryCause,
    required this.environmentalTriggers,
    required this.climateWeather,
    required this.soilMetrics,
    required this.airMoistureHumidity,
    required this.socialSurroundings,
  });

  factory PathogenRootCauseModel.fromJson(Map<String, dynamic> json) {
    return PathogenRootCauseModel(
      pathogenName: json['pathogen_name'] ?? 'Botanical Stress',
      primaryCause: json['primary_cause'] ?? '',
      environmentalTriggers: json['environmental_triggers'] ?? '',
      climateWeather: json['climate_weather'] ?? 'Elevated canopy temperature (31-34°C) and cloudy spells.',
      soilMetrics: json['soil_metrics'] ?? 'Soil pH 6.4-6.8 with Nitrogen abundance creating tender leaf tissues.',
      airMoistureHumidity: json['air_moisture_humidity'] ?? 'Relative humidity >70% maintaining free water films on leaves.',
      socialSurroundings: json['social_surroundings'] ?? 'Neighboring Solanaceous host plots and field margins harboring vectors.',
    );
  }
}

class PredictiveIrrigationAdviceModel {
  final String status;
  final String headline;
  final int waterDurationMins;
  final String scientificReasoning;

  PredictiveIrrigationAdviceModel({
    required this.status,
    required this.headline,
    required this.waterDurationMins,
    required this.scientificReasoning,
  });

  factory PredictiveIrrigationAdviceModel.fromJson(Map<String, dynamic> json) {
    return PredictiveIrrigationAdviceModel(
      status: json['status'] ?? 'OPTIMAL_MAINTENANCE',
      headline: json['headline'] ?? 'Standard Drip Irrigation',
      waterDurationMins: json['water_duration_mins'] ?? 30,
      scientificReasoning: json['scientific_reasoning'] ?? '',
    );
  }
}

class NutrientProfileCorrectionModel {
  final String nitrogenAction;
  final String potassiumAction;
  final String recommendedFormulation;

  NutrientProfileCorrectionModel({
    required this.nitrogenAction,
    required this.potassiumAction,
    required this.recommendedFormulation,
  });

  factory NutrientProfileCorrectionModel.fromJson(Map<String, dynamic> json) {
    return NutrientProfileCorrectionModel(
      nitrogenAction: json['nitrogen_action'] ?? '',
      potassiumAction: json['potassium_action'] ?? '',
      recommendedFormulation: json['recommended_formulation'] ?? '',
    );
  }
}

class CropStressAnalysisModel {
  final double stressScore;
  final String stressLevel;
  final String bioticStress;
  final String abioticStress;
  final String resilienceOutlook;

  CropStressAnalysisModel({
    required this.stressScore,
    required this.stressLevel,
    required this.bioticStress,
    required this.abioticStress,
    required this.resilienceOutlook,
  });

  factory CropStressAnalysisModel.fromJson(Map<String, dynamic> json) {
    return CropStressAnalysisModel(
      stressScore: (json['stress_score'] as num?)?.toDouble() ?? 0.0,
      stressLevel: json['stress_level'] ?? 'LOW',
      bioticStress: json['biotic_stress'] ?? '',
      abioticStress: json['abiotic_stress'] ?? '',
      resilienceOutlook: json['resilience_outlook'] ?? '',
    );
  }
}

class UnifiedScanResultModel {
  final String crop;
  final String overallHealth;
  final DiseasePredictionModel disease;
  final PestPredictionModel? pest;
  final NutrientPredictionModel? nutrient;
  final SegmentationPredictionModel? segmentation;
  final PathogenRootCauseModel? rootCause;
  final PredictiveIrrigationAdviceModel? predictiveIrrigation;
  final NutrientProfileCorrectionModel? nutrientProfile;
  final CropStressAnalysisModel? cropStress;
  final String advisorySummary;
  final List<String> recommendedActions;
  final String disclaimer;
  final String timestamp;

  UnifiedScanResultModel({
    required this.crop,
    required this.overallHealth,
    required this.disease,
    this.pest,
    this.nutrient,
    this.segmentation,
    this.rootCause,
    this.predictiveIrrigation,
    this.nutrientProfile,
    this.cropStress,
    required this.advisorySummary,
    required this.recommendedActions,
    required this.disclaimer,
    required this.timestamp,
  });

  factory UnifiedScanResultModel.fromJson(Map<String, dynamic> json) {
    return UnifiedScanResultModel(
      crop: json['crop'] ?? 'Crop',
      overallHealth: json['overall_health'] ?? 'HEALTHY',
      disease: DiseasePredictionModel.fromJson(json['disease'] ?? {}),
      pest: json['pest'] != null ? PestPredictionModel.fromJson(json['pest']) : null,
      nutrient: json['nutrient'] != null
          ? NutrientPredictionModel.fromJson(json['nutrient'])
          : null,
      segmentation: json['segmentation'] != null
          ? SegmentationPredictionModel.fromJson(json['segmentation'])
          : null,
      rootCause: json['root_cause'] != null
          ? PathogenRootCauseModel.fromJson(json['root_cause'])
          : null,
      predictiveIrrigation: json['predictive_irrigation'] != null
          ? PredictiveIrrigationAdviceModel.fromJson(json['predictive_irrigation'])
          : null,
      nutrientProfile: json['nutrient_profile'] != null
          ? NutrientProfileCorrectionModel.fromJson(json['nutrient_profile'])
          : null,
      cropStress: json['crop_stress'] != null
          ? CropStressAnalysisModel.fromJson(json['crop_stress'])
          : null,
      advisorySummary: json['advisory_summary'] ?? '',
      recommendedActions: (json['recommended_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      disclaimer: json['disclaimer'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
