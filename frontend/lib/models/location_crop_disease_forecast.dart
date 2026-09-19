class CropCultivationForecast {
  final String cropName;
  final String tamilName;
  final int suitabilityScore;
  final String suitabilityTier;
  final String expectedYield;
  final String seasonFit;
  final String tamilSeason;
  final String durationDays;
  final String waterRequirement;
  final String primaryMandi;
  final List<String> reasonsWhy;

  const CropCultivationForecast({
    required this.cropName,
    required this.tamilName,
    required this.suitabilityScore,
    required this.suitabilityTier,
    required this.expectedYield,
    required this.seasonFit,
    required this.tamilSeason,
    required this.durationDays,
    required this.waterRequirement,
    required this.primaryMandi,
    required this.reasonsWhy,
  });

  factory CropCultivationForecast.fromJson(Map<String, dynamic> json) {
    return CropCultivationForecast(
      cropName: json['crop_name'] ?? '',
      tamilName: json['tamil_name'] ?? '',
      suitabilityScore: json['suitability_score'] is int ? json['suitability_score'] : (json['suitability_score'] as num?)?.toInt() ?? 80,
      suitabilityTier: json['suitability_tier'] ?? 'High Suitability',
      expectedYield: json['expected_yield'] ?? '',
      seasonFit: json['season_fit'] ?? '',
      tamilSeason: json['tamil_season'] ?? '',
      durationDays: json['duration_days'] ?? '',
      waterRequirement: json['water_requirement'] ?? '',
      primaryMandi: json['primary_mandi'] ?? '',
      reasonsWhy: (json['reasons_why'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'crop_name': cropName,
    'tamil_name': tamilName,
    'suitability_score': suitabilityScore,
    'suitability_tier': suitabilityTier,
    'expected_yield': expectedYield,
    'season_fit': seasonFit,
    'tamil_season': tamilSeason,
    'duration_days': durationDays,
    'water_requirement': waterRequirement,
    'primary_mandi': primaryMandi,
    'reasons_why': reasonsWhy,
  };
}

class PredictedDiseaseOutbreak {
  final String diseaseName;
  final String tamilName;
  final String targetCrop;
  final String riskLevel; // HIGH, MODERATE, LOW
  final int riskScore;
  final String pathogenType; // Fungal, Bacterial, Viral, Pest Vector
  final String climateTriggers;
  final List<String> symptoms;
  final String tnauProtocol;

  const PredictedDiseaseOutbreak({
    required this.diseaseName,
    required this.tamilName,
    required this.targetCrop,
    required this.riskLevel,
    required this.riskScore,
    required this.pathogenType,
    required this.climateTriggers,
    required this.symptoms,
    required this.tnauProtocol,
  });

  factory PredictedDiseaseOutbreak.fromJson(Map<String, dynamic> json) {
    return PredictedDiseaseOutbreak(
      diseaseName: json['disease_name'] ?? '',
      tamilName: json['tamil_name'] ?? '',
      targetCrop: json['target_crop'] ?? '',
      riskLevel: json['risk_level'] ?? 'MODERATE',
      riskScore: json['risk_score'] is int ? json['risk_score'] : (json['risk_score'] as num?)?.toInt() ?? 65,
      pathogenType: json['pathogen_type'] ?? 'Fungal',
      climateTriggers: json['climate_triggers'] ?? '',
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tnauProtocol: json['tnau_protocol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'disease_name': diseaseName,
    'tamil_name': tamilName,
    'target_crop': targetCrop,
    'risk_level': riskLevel,
    'risk_score': riskScore,
    'pathogen_type': pathogenType,
    'climate_triggers': climateTriggers,
    'symptoms': symptoms,
    'tnau_protocol': tnauProtocol,
  };
}

class LocationForecastResult {
  final String detectedDistrict;
  final String tamilDistrict;
  final String? townTaluk;
  final String zoneName;
  final String tamilZoneName;
  final String typicalSoilType;
  final double typicalPh;
  final String activeSeason;
  final String tamilSeason;
  final List<CropCultivationForecast> cultivationPredictions;
  final List<PredictedDiseaseOutbreak> diseasePredictions;
  final String weatherForecast;
  final String? gpsCoordinates;

  const LocationForecastResult({
    required this.detectedDistrict,
    required this.tamilDistrict,
    this.townTaluk,
    required this.zoneName,
    required this.tamilZoneName,
    required this.typicalSoilType,
    required this.typicalPh,
    required this.activeSeason,
    required this.tamilSeason,
    required this.cultivationPredictions,
    required this.diseasePredictions,
    required this.weatherForecast,
    this.gpsCoordinates,
  });

  factory LocationForecastResult.fromJson(Map<String, dynamic> json, {String? coords}) {
    return LocationForecastResult(
      detectedDistrict: json['detected_district'] ?? 'Tamil Nadu',
      tamilDistrict: json['tamil_district'] ?? 'தமிழ்நாடு',
      townTaluk: json['town_taluk'],
      zoneName: json['zone_name'] ?? 'Tamil Nadu Agro-Climatic Zone',
      tamilZoneName: json['tamil_zone_name'] ?? 'தமிழ்நாடு மண்டலம்',
      typicalSoilType: json['typical_soil_type'] ?? 'Red Loam',
      typicalPh: (json['typical_ph'] as num?)?.toDouble() ?? 6.8,
      activeSeason: json['active_season'] ?? 'Aadi Pattam',
      tamilSeason: json['tamil_season'] ?? 'ஆடிப்பட்டம்',
      cultivationPredictions: (json['cultivation_predictions'] as List<dynamic>?)
              ?.map((e) => CropCultivationForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      diseasePredictions: (json['disease_predictions'] as List<dynamic>?)
              ?.map((e) => PredictedDiseaseOutbreak.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weatherForecast: json['weather_forecast'] ?? 'Normal agricultural weather.',
      gpsCoordinates: coords,
    );
  }

  Map<String, dynamic> toJson() => {
    'detected_district': detectedDistrict,
    'tamil_district': tamilDistrict,
    'town_taluk': townTaluk,
    'zone_name': zoneName,
    'tamil_zone_name': tamilZoneName,
    'typical_soil_type': typicalSoilType,
    'typical_ph': typicalPh,
    'active_season': activeSeason,
    'tamil_season': tamilSeason,
    'cultivation_predictions': cultivationPredictions.map((e) => e.toJson()).toList(),
    'disease_predictions': diseasePredictions.map((e) => e.toJson()).toList(),
    'weather_forecast': weatherForecast,
  };
}
