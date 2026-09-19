import '../core/app_localization.dart';

enum DemoScenarioType {
  healthyField,
  waterStress,
  diseaseRisk,
  heavyRainWaterlogging,
}

class DemoScenario {
  final DemoScenarioType type;
  final String title;
  final String description;
  final int farmRiskScore; // 0-100
  final String riskLabel; // e.g. "Optimal Field Condition", "Moderate Water Stress Risk", etc.
  final String riskReason;
  final String recommendedAction;
  final double soilMoisture;
  final double soilPh;
  final double soilTemp;
  final double airTemp;
  final double humidity;
  final double rainfall24h;
  final String weatherForecast;
  final String primaryZoneConcern;

  const DemoScenario({
    required this.type,
    required this.title,
    required this.description,
    required this.farmRiskScore,
    required this.riskLabel,
    required this.riskReason,
    required this.recommendedAction,
    required this.soilMoisture,
    required this.soilPh,
    required this.soilTemp,
    required this.airTemp,
    required this.humidity,
    required this.rainfall24h,
    required this.weatherForecast,
    required this.primaryZoneConcern,
  });

  int get _index {
    switch (type) {
      case DemoScenarioType.healthyField:
        return 0;
      case DemoScenarioType.waterStress:
        return 1;
      case DemoScenarioType.diseaseRisk:
        return 2;
      case DemoScenarioType.heavyRainWaterlogging:
        return 3;
    }
  }

  String titleFor(bool isTamil) => AppLocalization.scenarioTitle(_index, isTamil: isTamil);
  String descriptionFor(bool isTamil) => AppLocalization.scenarioDescription(_index, isTamil: isTamil);
  String riskLabelFor(bool isTamil) => AppLocalization.scenarioRiskLabel(_index, isTamil: isTamil);
  String riskReasonFor(bool isTamil) => AppLocalization.scenarioRiskReason(_index, isTamil: isTamil);
  String recommendedActionFor(bool isTamil) => AppLocalization.scenarioRecommendedAction(_index, isTamil: isTamil);
  String weatherForecastFor(bool isTamil) => AppLocalization.scenarioWeatherForecast(_index, isTamil: isTamil);
  String primaryZoneConcernFor(bool isTamil) => AppLocalization.scenarioPrimaryZoneConcern(_index, isTamil: isTamil);

  static const List<DemoScenario> allScenarios = [
    DemoScenario(
      type: DemoScenarioType.healthyField,
      title: "Scenario 1: Healthy Field",
      description: "Balanced root-zone moisture, normal microclimate, zero biotic pressure.",
      farmRiskScore: 18,
      riskLabel: "Optimal Field Condition (Low Risk)",
      riskReason: "All soil chemical sensors and microclimate stations indicate stable agronomic equilibrium.",
      recommendedAction: "Maintain standard morning irrigation schedule and regular visual scouting.",
      soilMoisture: 36.5,
      soilPh: 6.8,
      soilTemp: 25.4,
      airTemp: 29.2,
      humidity: 54.0,
      rainfall24h: 0.0,
      weatherForecast: "Clear skies with mild breeze; no environmental alerts.",
      primaryZoneConcern: "All zones nominal",
    ),
    DemoScenario(
      type: DemoScenarioType.waterStress,
      title: "Scenario 2: Water Stress",
      description: "Moisture 25%, Temp 37°C, Humidity 45%, Rainfall 0 mm.",
      farmRiskScore: 78,
      riskLabel: "High Water Stress Risk",
      riskReason: "Soil moisture is declining sharply while ambient temperatures remain elevated.",
      recommendedAction: "Prioritize root-zone drip irrigation for Zone 2 within the next 4 hours.",
      soilMoisture: 24.8,
      soilPh: 6.7,
      soilTemp: 34.2,
      airTemp: 37.4,
      humidity: 44.0,
      rainfall24h: 0.0,
      weatherForecast: "Intense daytime heat with low afternoon humidity.",
      primaryZoneConcern: "Zone 2 — Critical Moisture Depletion",
    ),
    DemoScenario(
      type: DemoScenarioType.diseaseRisk,
      title: "Scenario 3: Disease Risk",
      description: "High humidity >82%, leaf wetness, cloudy canopy, favorable fungal spore conditions.",
      farmRiskScore: 82,
      riskLabel: "Elevated Foliar Disease Risk",
      riskReason: "Extended leaf wetness (>3 hrs) combined with high relative humidity creates favorable spore germination conditions.",
      recommendedAction: "Cease any overhead sprinkler watering; inspect lower leaves in Zone 1 for lesion spots.",
      soilMoisture: 42.0,
      soilPh: 6.5,
      soilTemp: 26.8,
      airTemp: 28.5,
      humidity: 86.0,
      rainfall24h: 4.5,
      weatherForecast: "Overcast with persistent high humidity and stagnant air.",
      primaryZoneConcern: "Zone 1 — Microclimatic Fungal Incubation",
    ),
    DemoScenario(
      type: DemoScenarioType.heavyRainWaterlogging,
      title: "Scenario 4: Heavy Rain / Waterlogging",
      description: "Rainfall >55 mm, saturated soil, oxygen deficit risk in root zone.",
      farmRiskScore: 88,
      riskLabel: "Severe Waterlogging / Root Hypoxia Risk",
      riskReason: "Excessive continuous precipitation has saturated soil pore spaces, risking root suffocation.",
      recommendedAction: "Open drainage furrows immediately in Zone 3 to clear standing surface water.",
      soilMoisture: 68.0,
      soilPh: 6.9,
      soilTemp: 23.1,
      airTemp: 24.2,
      humidity: 94.0,
      rainfall24h: 62.0,
      weatherForecast: "Heavy rainfall alert issued by IMD for the next 24 hours.",
      primaryZoneConcern: "Zone 3 — Surface Runoff Ponding",
    ),
  ];
}
