import '../core/app_localization.dart';

enum ZoneStatus { normal, warning, critical }

class FieldZone {
  final String id;
  final String name;
  final String crop;
  final String variety;
  final String stage;
  final double areaAcres;
  final double soilMoisturePct;
  final double soilPh;
  final double nitrogenKgHa;
  final double phosphorusKgHa;
  final double potassiumKgHa;
  final double soilTempC;
  final double airTempC;
  final double humidityPct;
  final ZoneStatus status;
  final String statusHeadline;
  final String statusReason;
  final String recommendedAction;
  final String gpsCoordinates;
  final String hardwareNode;
  final double relativeX;
  final double relativeY;
  final String soilTexture;
  final int batteryPct;
  final int signalRssiDbm;
  final bool isFallow;
  final String previousHarvestedCrop;

  FieldZone({
    required this.id,
    required this.name,
    required this.crop,
    required this.variety,
    required this.stage,
    required this.areaAcres,
    required this.soilMoisturePct,
    required this.soilPh,
    required this.nitrogenKgHa,
    required this.phosphorusKgHa,
    required this.potassiumKgHa,
    required this.soilTempC,
    required this.airTempC,
    required this.humidityPct,
    required this.status,
    required this.statusHeadline,
    required this.statusReason,
    required this.recommendedAction,
    this.gpsCoordinates = "18.5204° N, 73.8567° E",
    this.hardwareNode = "LoRa IoT Node",
    this.relativeX = 0.5,
    this.relativeY = 0.5,
    this.soilTexture = "Loamy Soil",
    this.batteryPct = 92,
    this.signalRssiDbm = -72,
    this.isFallow = false,
    this.previousHarvestedCrop = "None",
  });

  bool get isEmptyPlot => isFallow || crop.toLowerCase().contains('fallow') || crop.toLowerCase().contains('empty');
  String get tinymlEdgeDecision => statusHeadline;
  String get hardwareNodeLabel => hardwareNode.split('(')[0].trim();

  String nameFor(bool isTamil) => AppLocalization.zoneName(id.isNotEmpty ? id : name, isTamil: isTamil);
  String shortNameFor(bool isTamil) => AppLocalization.zoneShortName(id.isNotEmpty ? id : name, isTamil: isTamil);
  String cropFor(bool isTamil) => AppLocalization.cropName(crop, isTamil: isTamil);
  String stageFor(bool isTamil) => AppLocalization.stageName(stage, isTamil: isTamil);
  String soilTextureFor(bool isTamil) => AppLocalization.soilTexture(soilTexture, isTamil: isTamil);
  String statusHeadlineFor(bool isTamil) => AppLocalization.zoneStatusHeadline(statusHeadline, isTamil: isTamil);
  String statusReasonFor(bool isTamil) => AppLocalization.zoneStatusReason(statusReason, isTamil: isTamil);
  String recommendedActionFor(bool isTamil) => AppLocalization.zoneRecommendedAction(recommendedAction, isTamil: isTamil);
  String statusLabelFor(bool isTamil) => AppLocalization.zoneStatus(status, isTamil: isTamil);

  FieldZone copyWith({
    double? soilMoisturePct,
    double? soilPh,
    double? nitrogenKgHa,
    double? phosphorusKgHa,
    double? potassiumKgHa,
    double? soilTempC,
    double? airTempC,
    double? humidityPct,
    ZoneStatus? status,
    String? statusHeadline,
    String? statusReason,
    String? recommendedAction,
    String? gpsCoordinates,
    String? hardwareNode,
    double? relativeX,
    double? relativeY,
    String? soilTexture,
    int? batteryPct,
    int? signalRssiDbm,
    bool? isFallow,
    String? previousHarvestedCrop,
  }) {
    return FieldZone(
      id: id,
      name: name,
      crop: crop,
      variety: variety,
      stage: stage,
      areaAcres: areaAcres,
      soilMoisturePct: soilMoisturePct ?? this.soilMoisturePct,
      soilPh: soilPh ?? this.soilPh,
      nitrogenKgHa: nitrogenKgHa ?? this.nitrogenKgHa,
      phosphorusKgHa: phosphorusKgHa ?? this.phosphorusKgHa,
      potassiumKgHa: potassiumKgHa ?? this.potassiumKgHa,
      soilTempC: soilTempC ?? this.soilTempC,
      airTempC: airTempC ?? this.airTempC,
      humidityPct: humidityPct ?? this.humidityPct,
      status: status ?? this.status,
      statusHeadline: statusHeadline ?? this.statusHeadline,
      statusReason: statusReason ?? this.statusReason,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      hardwareNode: hardwareNode ?? this.hardwareNode,
      relativeX: relativeX ?? this.relativeX,
      relativeY: relativeY ?? this.relativeY,
      soilTexture: soilTexture ?? this.soilTexture,
      batteryPct: batteryPct ?? this.batteryPct,
      signalRssiDbm: signalRssiDbm ?? this.signalRssiDbm,
      isFallow: isFallow ?? this.isFallow,
      previousHarvestedCrop: previousHarvestedCrop ?? this.previousHarvestedCrop,
    );
  }
}

class ImdWeatherData {
  final double temperatureC;
  final double humidityPct;
  final double rainfallMm24h;
  final double windSpeedKmh;
  final String forecastSummary;
  final String weatherRisk; // "Low Risk", "Moderate Rain Expected", "Heatwave Advisory"
  final String source; // "India Meteorological Department (IMD) Gridded Data"

  ImdWeatherData({
    this.temperatureC = 31.8,
    this.humidityPct = 58.0,
    this.rainfallMm24h = 0.0,
    this.windSpeedKmh = 11.2,
    this.forecastSummary = "Partly cloudy with scattered afternoon sunshine",
    this.weatherRisk = "Low Environmental Stress",
    this.source = "IMD Weather Intelligence (Automated Agro-Met Station)",
  });

  String forecastSummaryFor(bool isTamil) {
    if (!isTamil) return forecastSummary;
    final lower = forecastSummary.toLowerCase();
    if (lower.contains('partly cloudy')) return 'பகுதி மேகமூட்டம் மற்றும் மிதமான பிற்பகல் வெயில்';
    if (lower.contains('clear skies')) return 'தெளிவான வானம் மற்றும் மிதமான காற்று';
    if (lower.contains('intense daytime')) return 'பகலில் தீவிர வெப்பம் மற்றும் பிற்பகலில் குறைந்த ஈரப்பதம்';
    if (lower.contains('overcast')) return 'மேகமூட்டம், தொடர் அதிக ஈரப்பதம் மற்றும் காற்று வீசாத சூழல்';
    if (lower.contains('heavy rainfall')) return 'அடுத்த 24 மணி நேரத்திற்கு இந்திய வானிலை மையம் கனமழை எச்சரிக்கை விடுத்துள்ளது';
    return forecastSummary;
  }
}
