import '../models/field_zone.dart';

class ClimateRiskCardData {
  final String title;
  final String riskLevel; // "LOW", "MODERATE", "HIGH", "CRITICAL"
  final String metricSummary;
  final String explanation;
  final String action;
  final int severityColorCode; // hex integer

  ClimateRiskCardData({
    required this.title,
    required this.riskLevel,
    required this.metricSummary,
    required this.explanation,
    required this.action,
    required this.severityColorCode,
  });
}

class WeatherIntelligenceService {
  /// Computes contextual climate and field risk assessments.
  /// Always labeled as RISK ASSESSMENT, not absolute forecast.
  static List<ClimateRiskCardData> evaluateClimateRisks({
    required FieldZone primaryZone,
    required ImdWeatherData weather,
  }) {
    final List<ClimateRiskCardData> risks = [];

    // 1. Water Stress Risk
    if (primaryZone.soilMoisturePct < 28.0 && (weather.temperatureC > 33.0 || primaryZone.airTempC > 33.0)) {
      risks.add(ClimateRiskCardData(
        title: "WATER STRESS RISK",
        riskLevel: "HIGH",
        metricSummary: "Moisture: ${primaryZone.soilMoisturePct.toStringAsFixed(1)}% | Ambient: ${weather.temperatureC.toStringAsFixed(1)}°C",
        explanation: "Low soil moisture combined with high ambient temperature and minimal precipitation increases crop transpiration deficits.",
        action: "Schedule targeted root-zone drip irrigation for affected zones early morning.",
        severityColorCode: 0xFFC2410C, // Warm Terracotta / Burnt Sienna
      ));
    } else if (primaryZone.soilMoisturePct < 32.0) {
      risks.add(ClimateRiskCardData(
        title: "WATER STRESS RISK",
        riskLevel: "MODERATE",
        metricSummary: "Moisture: ${primaryZone.soilMoisturePct.toStringAsFixed(1)}% | Ambient: ${weather.temperatureC.toStringAsFixed(1)}°C",
        explanation: "Soil moisture is approaching the lower threshold for flowering stages.",
        action: "Monitor root-zone depletion; prepare irrigation cycle within 24 hours.",
        severityColorCode: 0xFFD97706, // Amber
      ));
    } else {
      risks.add(ClimateRiskCardData(
        title: "WATER STRESS RISK",
        riskLevel: "LOW",
        metricSummary: "Moisture: ${primaryZone.soilMoisturePct.toStringAsFixed(1)}% | Adequate",
        explanation: "Root zone moisture is within the optimal agronomic range for the current crop growth stage.",
        action: "Maintain standard scheduled maintenance.",
        severityColorCode: 0xFF059669, // Green
      ));
    }

    // 2. Heat Stress Risk
    if (weather.temperatureC >= 36.0 || primaryZone.airTempC >= 36.0) {
      risks.add(ClimateRiskCardData(
        title: "HEAT STRESS RISK",
        riskLevel: "HIGH",
        metricSummary: "Peak Canopy: ${primaryZone.airTempC.toStringAsFixed(1)}°C",
        explanation: "Temperatures exceeding 36°C can impair pollen viability and accelerate cellular moisture loss.",
        action: "Apply organic mulch on exposed beds and maintain adequate root moisture to mitigate thermal stress.",
        severityColorCode: 0xFFC2410C,
      ));
    } else if (weather.temperatureC >= 32.0) {
      risks.add(ClimateRiskCardData(
        title: "HEAT STRESS RISK",
        riskLevel: "MODERATE",
        metricSummary: "Canopy: ${primaryZone.airTempC.toStringAsFixed(1)}°C | Warm",
        explanation: "Moderate heat conditions; increased evapotranspiration rates observed.",
        action: "Avoid midday chemical or fertilizer applications.",
        severityColorCode: 0xFFD97706,
      ));
    } else {
      risks.add(ClimateRiskCardData(
        title: "HEAT STRESS RISK",
        riskLevel: "LOW",
        metricSummary: "Canopy: ${primaryZone.airTempC.toStringAsFixed(1)}°C | Optimal",
        explanation: "Thermal conditions are favorable for vegetative and reproductive metabolism.",
        action: "No thermal mitigation required.",
        severityColorCode: 0xFF059669,
      ));
    }

    // 3. Waterlogging / Flood Risk
    if (primaryZone.soilMoisturePct > 60.0 || weather.rainfallMm24h > 40.0) {
      risks.add(ClimateRiskCardData(
        title: "WATERLOGGING / FLOOD RISK",
        riskLevel: "CRITICAL",
        metricSummary: "Soil Saturation: ${primaryZone.soilMoisturePct.toStringAsFixed(1)}% | 24h Rain: ${weather.rainfallMm24h.toStringAsFixed(1)} mm",
        explanation: "Continuous high moisture saturates soil macro-pores, cutting off oxygen supply to roots.",
        action: "Immediately open drainage trenches and ensure zero standing water around crop crowns.",
        severityColorCode: 0xFFC2410C,
      ));
    } else {
      risks.add(ClimateRiskCardData(
        title: "WATERLOGGING / FLOOD RISK",
        riskLevel: "LOW",
        metricSummary: "Soil Drainage: Normal | Rain: ${weather.rainfallMm24h.toStringAsFixed(1)} mm",
        explanation: "Soil aeration is healthy with no ponding observed or expected in the near forecast.",
        action: "Keep field drainage channels free of weed debris.",
        severityColorCode: 0xFF059669,
      ));
    }

    // 4. Disease-Favorable Conditions
    if (weather.humidityPct > 75.0 || primaryZone.humidityPct > 75.0) {
      risks.add(ClimateRiskCardData(
        title: "DISEASE-FAVORABLE CONDITIONS",
        riskLevel: "ELEVATED",
        metricSummary: "RH: ${primaryZone.humidityPct.toStringAsFixed(0)}% | Fungal Incubation Window",
        explanation: "High atmospheric humidity with dew formation sustains leaf moisture films, favoring fungal spore germination.",
        action: "Avoid overhead irrigation; inspect lower leaves for early lesions tomorrow morning.",
        severityColorCode: 0xFFD97706,
      ));
    } else {
      risks.add(ClimateRiskCardData(
        title: "DISEASE-FAVORABLE CONDITIONS",
        riskLevel: "LOW",
        metricSummary: "RH: ${primaryZone.humidityPct.toStringAsFixed(0)}% | Rapid Leaf Drying",
        explanation: "Canopy air circulation is adequate and humidity is below fungal incubation thresholds.",
        action: "Maintain standard preventative scouting.",
        severityColorCode: 0xFF059669,
      ));
    }

    return risks;
  }
}
