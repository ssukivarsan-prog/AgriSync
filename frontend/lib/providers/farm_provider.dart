import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../core/api_service.dart';
import '../models/farm_summary.dart';
import '../models/scan_result.dart';
import '../models/irrigation_result.dart';
import '../models/environment_result.dart';
import '../models/quotation_models.dart';
import '../models/farmer_profile.dart';
import '../models/field_zone.dart';
import '../models/crop_recommendation.dart';
import '../models/context_fusion_risk.dart';
import '../models/demo_scenario.dart';
import '../services/risk_assessment_service.dart';
import '../services/crop_recommendation_service.dart';
import '../services/ai_assistant_service.dart';
import '../services/crop_quotation_service.dart';
import '../services/location_service.dart';
import '../models/location_crop_disease_forecast.dart';
import '../services/crop_disease_forecasting_service.dart';
import '../core/app_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  FarmSummaryModel? _farmSummary;
  Map<String, dynamic>? _analytics;
  List<Map<String, dynamic>> _historyItems = [];
  List<Map<String, dynamic>> _modelsInfo = [];
  bool _isDemoSensorMode = false;
  FieldModel? _selectedField;

  UnifiedScanResultModel? _lastScanResult;
  PestPredictionModel? _lastPestResult;
  NutrientPredictionModel? _lastNutrientResult;
  IrrigationResultModel? _lastIrrigationResult;
  EnvironmentResultModel? _lastEnvironmentResult;

  // AgriSync Prototype Enhanced State
  FarmerProfile _farmer = FarmerProfile();
  DemoScenario _currentScenario = DemoScenario.allScenarios[1]; // Start with Scenario 2 (Water Stress) for compelling demonstration
  ImdWeatherData _weather = ImdWeatherData();
  late List<FieldZone> _zones;
  ContextFusionAssessment? _latestFusionAssessment;
  final List<ChatMessage> _chatMessages = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FarmSummaryModel? get farmSummary => _farmSummary;
  Map<String, dynamic>? get analytics => _analytics;
  List<Map<String, dynamic>> get historyItems => _historyItems;
  List<Map<String, dynamic>> get modelsInfo => _modelsInfo;
  bool get isDemoSensorMode => _isDemoSensorMode;
  FieldModel? get selectedField => _selectedField;

  UnifiedScanResultModel? get lastScanResult => _lastScanResult;
  PestPredictionModel? get lastPestResult => _lastPestResult;
  NutrientPredictionModel? get lastNutrientResult => _lastNutrientResult;
  IrrigationResultModel? get lastIrrigationResult => _lastIrrigationResult;
  EnvironmentResultModel? get lastEnvironmentResult => _lastEnvironmentResult;
  ApiService get apiService => _api;
  bool get isOffline => _api.isOffline;

  TamilNaduDistrictProfile _currentDistrict = LocationService.defaultDistrict;
  LocationForecastResult? _locationForecast;
  AppLanguage _appLanguage = AppLanguage.english;

  // AgriSync Enhanced Prototype Getters
  FarmerProfile get farmer => _farmer;
  FarmerProfile get farmerProfile => _farmer;
  DemoScenario get currentScenario => _currentScenario;
  ImdWeatherData get weather => _weather;
  List<FieldZone> get zones => _zones;
  ContextFusionAssessment? get latestFusionAssessment => _latestFusionAssessment;
  List<ChatMessage> get chatMessages => _chatMessages;
  TamilNaduDistrictProfile get currentDistrict => _currentDistrict;
  LocationForecastResult? get locationForecast => _locationForecast;
  AppLanguage get appLanguage => _appLanguage;
  bool get isTamil => _appLanguage == AppLanguage.tamil;

  Future<void> setLanguage(AppLanguage lang) async {
    _appLanguage = lang;
    _initChat();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', lang == AppLanguage.tamil ? 'ta' : 'en');
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final next = _appLanguage == AppLanguage.tamil ? AppLanguage.english : AppLanguage.tamil;
    await setLanguage(next);
  }

  FarmProvider() {
    _initZones();
    _initChat();
    _initDeviceLocation();
  }

  bool _hasManualLocationOverride = false;

  void _initDeviceLocation() async {
    try {
      final dist = await LocationService.fetchCurrentLocation();
      if (!_hasManualLocationOverride) {
        _applyDistrict(dist);
      }
    } catch (_) {}
  }

  void updateFarmerProfile(FarmerProfile updated) {
    _farmer = updated;
    notifyListeners();

    // Auto-sync mobile farmer profile to SQLite backend so it appears on VAO Admin Portal
    _api.registerMobileFarmer(
      name: updated.name,
      nameTamil: updated.name,
      phoneNumber: updated.phoneNumber,
      location: updated.location,
      farmName: updated.farmName,
      farmSizeAcres: updated.farmSizeAcres,
      primaryCrop: updated.previousCrop.isNotEmpty ? updated.previousCrop : 'Paddy (CR1009 / Samba)',
      soilType: updated.soilType,
      waterSource: updated.irrigationAvailability,
    );
  }

  void _initZones() {
    _zones = [
      FieldZone(
        id: "zone_1",
        name: "North Field (3.5 Acres - Delta Paddy)",
        crop: "Paddy (Rice)",
        variety: "ADT-45 / CR-1009 Sub 1",
        stage: "Tillering Stage",
        areaAcres: 3.5,
        soilMoisturePct: 34.0,
        soilPh: 6.8,
        nitrogenKgHa: 140.0,
        phosphorusKgHa: 45.0,
        potassiumKgHa: 180.0,
        soilTempC: 26.5,
        airTempC: 31.8,
        humidityPct: 76.0,
        status: ZoneStatus.normal,
        statusHeadline: "North Field — Normal Condition",
        statusReason: "Root-zone hydration is balanced; normal vegetative vigor in Cauvery Delta.",
        recommendedAction: "Maintain scheduled morning micro-irrigation cycle.",
        gpsCoordinates: "10.7870° N, 79.1378° E",
        hardwareNode: "Master LoRaWAN Gateway #1 (Delta Hub)",
        relativeX: 0.32,
        relativeY: 0.30,
        soilTexture: "Cauvery Alluvial Clay Loam",
        batteryPct: 96,
        signalRssiDbm: -64,
      ),
      FieldZone(
        id: "zone_2",
        name: "South Field (2.5 Acres - Tomato)",
        crop: "Tomato",
        variety: "PKM-1 / Shivam",
        stage: "Flowering Stage",
        areaAcres: 2.5,
        soilMoisturePct: 24.8,
        soilPh: 6.5,
        nitrogenKgHa: 110.0,
        phosphorusKgHa: 50.0,
        potassiumKgHa: 140.0,
        soilTempC: 34.2,
        airTempC: 37.4,
        humidityPct: 44.0,
        status: ZoneStatus.critical,
        statusHeadline: "South Field — Water Stress Warning",
        statusReason: "Soil moisture dropped to 24.8% while ambient temp is 37.4°C.",
        recommendedAction: "Prioritize root-zone drip irrigation for South Field within 3 hours.",
        gpsCoordinates: "10.7850° N, 79.1390° E",
        hardwareNode: "Sub-Node Kit #2 (Dual Probe)",
        relativeX: 0.32,
        relativeY: 0.72,
        soilTexture: "Red Sandy Loam",
        batteryPct: 88,
        signalRssiDbm: -76,
      ),
      FieldZone(
        id: "zone_3",
        name: "East Field (2.5 Acres - Banana)",
        crop: "Banana",
        variety: "Grand Naine / Poovan",
        stage: "Shooting Stage",
        areaAcres: 2.5,
        soilMoisturePct: 36.2,
        soilPh: 7.0,
        nitrogenKgHa: 160.0,
        phosphorusKgHa: 38.0,
        potassiumKgHa: 195.0,
        soilTempC: 27.1,
        airTempC: 31.0,
        humidityPct: 68.0,
        status: ZoneStatus.normal,
        statusHeadline: "East Field — Normal Condition",
        statusReason: "Vegetative biomass shows strong photosynthetic activity in riverbank alluvium.",
        recommendedAction: "Next split Potassium fertigation scheduled in 7 days.",
        gpsCoordinates: "10.7890° N, 79.1410° E",
        hardwareNode: "Sub-Node Kit #3 (Heavy Retentive)",
        relativeX: 0.75,
        relativeY: 0.50,
        soilTexture: "Riverbank Alluvial Loam",
        batteryPct: 92,
        signalRssiDbm: -71,
      ),
      FieldZone(
        id: "zone_4",
        name: "West Plot (1.5 Acres - Fallow)",
        crop: "Fallow (Ready for Sowing)",
        variety: "Unplanted",
        stage: "Tilled / Seedbed Ready",
        areaAcres: 1.5,
        soilMoisturePct: 26.5,
        soilPh: 6.6,
        nitrogenKgHa: 105.0,
        phosphorusKgHa: 42.0,
        potassiumKgHa: 150.0,
        soilTempC: 28.0,
        airTempC: 32.0,
        humidityPct: 52.0,
        status: ZoneStatus.normal,
        statusHeadline: "West Plot — Ready for Sowing",
        statusReason: "Empty parcel with tilled seedbed. Soil chemistry is analyzed and awaiting sowing decision.",
        recommendedAction: "Review AI crop recommendation and generate sowing budget quotation.",
        gpsCoordinates: "10.7860° N, 79.1350° E",
        hardwareNode: "Sub-Node Kit #4 (Multi-Depth Soil Probe)",
        relativeX: 0.72,
        relativeY: 0.80,
        soilTexture: "Sandy Loam",
        batteryPct: 94,
        signalRssiDbm: -68,
        isFallow: true,
        previousHarvestedCrop: "Groundnut (VRI-2)",
      ),
    ];
    _applyScenarioToZones();
    _applyDistrict(_currentDistrict);
  }

  void setDemoScenario(DemoScenarioType type) {
    _currentScenario = DemoScenario.allScenarios.firstWhere((s) => s.type == type);
    _weather = ImdWeatherData(
      temperatureC: _currentScenario.airTemp,
      humidityPct: _currentScenario.humidity,
      rainfallMm24h: _currentScenario.rainfall24h,
      forecastSummary: _currentScenario.weatherForecast,
      weatherRisk: _currentScenario.riskLabel,
    );
    _applyScenarioToZones();
    notifyListeners();
  }

  void _applyScenarioToZones() {
    if (_zones.length < 3) return;
    if (_currentScenario.type == DemoScenarioType.waterStress) {
      _zones[0] = _zones[0].copyWith(soilMoisturePct: 34.0, status: ZoneStatus.normal, statusHeadline: "North Field — Normal");
      _zones[1] = _zones[1].copyWith(
        soilMoisturePct: _currentScenario.soilMoisture,
        airTempC: _currentScenario.airTemp,
        status: ZoneStatus.critical,
        statusHeadline: "South Field — Water Stress",
        statusReason: _currentScenario.riskReason,
        recommendedAction: _currentScenario.recommendedAction,
      );
      _zones[2] = _zones[2].copyWith(soilMoisturePct: 32.0, status: ZoneStatus.warning, statusHeadline: "East Field — Depleting");
      if (_zones.length > 3) {
        _zones[3] = _zones[3].copyWith(soilMoisturePct: 24.0, status: ZoneStatus.warning, statusHeadline: "West Plot — Dry Seedbed");
      }
    } else if (_currentScenario.type == DemoScenarioType.diseaseRisk) {
      _zones[0] = _zones[0].copyWith(
        humidityPct: 86.0,
        status: ZoneStatus.critical,
        statusHeadline: "North Field — Fungal Risk",
        statusReason: _currentScenario.riskReason,
        recommendedAction: _currentScenario.recommendedAction,
      );
      _zones[1] = _zones[1].copyWith(soilMoisturePct: 38.0, status: ZoneStatus.warning, statusHeadline: "South Field — High Humidity");
      _zones[2] = _zones[2].copyWith(soilMoisturePct: 40.0, status: ZoneStatus.warning, statusHeadline: "East Field — Spore Alert");
      if (_zones.length > 3) {
        _zones[3] = _zones[3].copyWith(status: ZoneStatus.normal, statusHeadline: "West Plot — Fallow (No Canopy Spore Risk)");
      }
    } else if (_currentScenario.type == DemoScenarioType.heavyRainWaterlogging) {
      _zones[0] = _zones[0].copyWith(soilMoisturePct: 65.0, status: ZoneStatus.warning, statusHeadline: "North Field — Saturation");
      _zones[1] = _zones[1].copyWith(soilMoisturePct: 64.0, status: ZoneStatus.warning, statusHeadline: "South Field — Ponding Risk");
      _zones[2] = _zones[2].copyWith(
        soilMoisturePct: _currentScenario.soilMoisture,
        status: ZoneStatus.critical,
        statusHeadline: "East Field — Waterlogging",
        statusReason: _currentScenario.riskReason,
        recommendedAction: _currentScenario.recommendedAction,
      );
      if (_zones.length > 3) {
        _zones[3] = _zones[3].copyWith(soilMoisturePct: 58.0, status: ZoneStatus.warning, statusHeadline: "West Plot — Heavy Saturation");
      }
    } else {
      for (int i = 0; i < _zones.length; i++) {
        _zones[i] = _zones[i].copyWith(
          soilMoisturePct: 34.0 + (i * 2),
          status: ZoneStatus.normal,
          statusHeadline: "${_zones[i].name.split(' ')[0]} — Normal",
          statusReason: _zones[i].isEmptyPlot
              ? "Tilled seedbed prepared for fresh sowing."
              : "Stable soil moisture and healthy photosynthetic activity.",
          recommendedAction: _zones[i].isEmptyPlot
              ? "Run AI Crop Quotation to decide optimal seed variety."
              : "Maintain standard preventative scouting.",
        );
      }
    }
  }

  void _initChat() {
    _chatMessages.clear();
    final bool isTamil = _appLanguage == AppLanguage.tamil;
    _chatMessages.add(ChatMessage(
      text: isTamil
          ? "வணக்கம் ${_farmer.name}! நான் உங்கள் அக்ரிவைன் AI உதவியாளர். உங்கள் வயல் சென்சார்கள், வானிலை மற்றும் பயிர் நோய் தரவுகளை ஆய்வு செய்து வழிகாட்ட தயார். இன்று உங்களுக்கு எவ்வாறு உதவட்டும்?"
          : "Namaste ${_farmer.name}! I am your AgriSync AI Assistant. I have live access to your field sensors, IMD weather, and crop diagnosis. How can I help you today?",
      isUser: false,
      timestamp: isTamil ? "இப்போது" : "Just now",
      suggestions: isTamil
          ? [
              "என்ன பயிர் நடவு செய்ய வேண்டும்?",
              "பயிரில் நீர்ப்பற்றாக்குறை உள்ளதா?",
              "நோய் பாதிப்பை தடுப்பது எப்படி?",
              "மழைக்கு முன் என்ன செய்ய வேண்டும்?",
            ]
          : [
              "What should I sow?",
              "Why is my crop under stress?",
              "How can I reduce disease risk?",
              "What should I do before heavy rain?",
            ],
    ));
  }

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    _chatMessages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: "Just now",
    ));
    notifyListeners();

    final botReply = AiAssistantService.generateContextualResponse(
      query: text,
      farmer: _farmer,
      zones: _zones,
      weather: _weather,
      latestAssessment: _latestFusionAssessment,
    );

    _chatMessages.add(ChatMessage(
      text: botReply,
      isUser: false,
      timestamp: "Just now",
      suggestions: [
        "Check Zone 2 irrigation status",
        "Explain cropping rotation pattern",
        "View weather risk intelligence",
      ],
    ));
    notifyListeners();
  }

  ContextFusionAssessment runContextFusionAnalysis({
    required String cvPrediction,
    required double confidence,
    int pestCount = 0,
    String? primaryPest,
    String zoneId = "zone_2",
    bool isVideoAnalysis = false,
    String? videoMotionSummary,
    String? districtTamilNadu,
  }) {
    final zone = _zones.firstWhere((z) => z.id == zoneId, orElse: () => _zones[1]);
    final assessment = RiskAssessmentService.evaluateContextFusion(
      cvRawPrediction: cvPrediction,
      cvConfidence: confidence,
      pestCountObserved: pestCount,
      primaryPestObserved: primaryPest,
      zone: zone,
      weather: _weather,
      farmer: _farmer,
      isVideoAnalysis: isVideoAnalysis,
      videoMotionSummary: videoMotionSummary,
      districtTamilNadu: districtTamilNadu ?? _currentDistrict.name,
    );
    _latestFusionAssessment = assessment;
    notifyListeners();
    return assessment;
  }

  Future<void> fetchAndApplyFarmerLocation({
    String? manualDistrict,
    double? manualLat,
    double? manualLng,
  }) async {
    _setLoading(true);
    TamilNaduDistrictProfile dist;
    if (manualDistrict != null && manualDistrict.isNotEmpty) {
      _hasManualLocationOverride = true;
      LocationService.detectedTownOrTaluk = null;
      dist = LocationService.getDistrict(manualDistrict);
    } else {
      _hasManualLocationOverride = false;
      dist = await LocationService.fetchCurrentLocation(
        manualLat: manualLat,
        manualLng: manualLng,
      );
    }
    _applyDistrict(dist);
    _setLoading(false);
  }

  void _applyDistrict(TamilNaduDistrictProfile dist) {
    _currentDistrict = dist;
    final townPrefix = (LocationService.detectedTownOrTaluk != null && LocationService.wasFetchedFromDeviceGps)
        ? "${LocationService.detectedTownOrTaluk}, "
        : "";
    _farmer = _farmer.copyWith(
      location: "$townPrefix${dist.name}, Tamil Nadu",
      districtTamilNadu: dist.name,
      agroClimaticZone: dist.zoneName,
      soilType: dist.typicalSoilType,
    );
    _weather = ImdWeatherData(
      temperatureC: dist.avgTempC,
      humidityPct: dist.avgHumidityPct,
      rainfallMm24h: dist.avgRainfallMm,
      forecastSummary: dist.weatherForecast,
      weatherRisk: dist.avgRainfallMm > 5.0 ? "MODERATE (RAIN)" : "LOW",
    );
    final String coordsString = LocationService.wasFetchedFromDeviceGps &&
            LocationService.lastRealLatitude != null &&
            LocationService.lastRealLongitude != null
        ? "${LocationService.lastRealLatitude!.toStringAsFixed(4)}° N, ${LocationService.lastRealLongitude!.toStringAsFixed(4)}° E"
        : "${dist.latitude.toStringAsFixed(4)}° N, ${dist.longitude.toStringAsFixed(4)}° E";

    for (int i = 0; i < _zones.length; i++) {
      _zones[i] = _zones[i].copyWith(
        gpsCoordinates: coordsString,
        soilTexture: dist.typicalSoilType,
        soilPh: dist.typicalPh,
      );
    }

    // Auto-compute location-driven crop cultivation & disease forecast
    _locationForecast = CropDiseaseForecastingService.generateLocalForecast(
      district: dist,
      soilPh: dist.typicalPh,
      soilMoisture: _zones.isNotEmpty ? _zones[0].soilMoisturePct : dist.typicalMoisturePct,
      weather: _weather,
      latitude: LocationService.lastRealLatitude,
      longitude: LocationService.lastRealLongitude,
      townTaluk: LocationService.detectedTownOrTaluk,
    );

    notifyListeners();
  }

  Future<void> refreshLocationForecast() async {
    _locationForecast = await CropDiseaseForecastingService.getForecast(
      district: _currentDistrict,
      soilPh: _currentDistrict.typicalPh,
      soilMoisture: _zones.isNotEmpty ? _zones[0].soilMoisturePct : _currentDistrict.typicalMoisturePct,
      weather: _weather,
      baseUrl: _api.baseUrl,
      latitude: LocationService.lastRealLatitude,
      longitude: LocationService.lastRealLongitude,
      townTaluk: LocationService.detectedTownOrTaluk,
    );
    notifyListeners();
  }

  String? get liveGpsStatusMessage => LocationService.lastGpsStatusMessage;
  String? get detectedTownOrTaluk => LocationService.detectedTownOrTaluk;
  bool get wasFetchedFromDeviceGps => LocationService.wasFetchedFromDeviceGps;
  double? get liveLatitude => LocationService.lastRealLatitude;
  double? get liveLongitude => LocationService.lastRealLongitude;


  Future<bool> setServerUrl(String url) async {
    _setLoading(true);
    final isOnline = await _api.setBaseUrl(url);
    if (isOnline) {
      _errorMessage = null;
      await loadFarmSummary();
      await loadAnalytics();
      await loadHistory();
      await loadModelsInfo();
    } else {
      _errorMessage = 'Could not connect to server at ${_api.baseUrl}';
    }
    _setLoading(false);
    notifyListeners();
    return isOnline;
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('app_language');
      if (langCode == 'ta') {
        _appLanguage = AppLanguage.tamil;
      } else {
        _appLanguage = AppLanguage.english;
      }
    } catch (_) {}
    await _api.initialize();
    await loadFarmSummary();
    await loadAnalytics();
    await loadHistory();
    await loadModelsInfo();
    _setLoading(false);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void toggleDemoSensorMode() {
    _isDemoSensorMode = !_isDemoSensorMode;
    notifyListeners();
  }

  void selectField(FieldModel field) {
    _selectedField = field;
    notifyListeners();
  }

  Future<void> loadFarmSummary() async {
    try {
      final data = await _api.getFarmSummary();
      _farmSummary = FarmSummaryModel.fromJson(data);
      if (_farmSummary!.fields.isNotEmpty && _selectedField == null) {
        _selectedField = _farmSummary!.fields.first;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadAnalytics() async {
    try {
      _analytics = await _api.getFarmAnalytics();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> loadHistory() async {
    try {
      final res = await _api.getHistory();
      _historyItems = (res['items'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    } catch (_) {}
    notifyListeners();
  }

  Future<void> deleteHistory(int id) async {
    try {
      await _api.deleteHistoryItem(id);
      _historyItems.removeWhere((item) => item['id'] == id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadModelsInfo() async {
    try {
      final res = await _api.getModelsInfo();
      _modelsInfo = (res['models'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    } catch (_) {}
    notifyListeners();
  }

  // Unified Scan Workflow
  Future<UnifiedScanResultModel?> executeUnifiedScan(
      Uint8List imageBytes, String filename, int fieldId, {String? crop}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final effectiveCrop = crop ?? _selectedField?.crop;
      final data = await _api.unifiedScan(imageBytes, filename, fieldId, crop: effectiveCrop);
      _lastScanResult = UnifiedScanResultModel.fromJson(data);
      await loadHistory();
      await loadFarmSummary();
      _setLoading(false);
      return _lastScanResult;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // Dedicated Pest Detection
  Future<PestPredictionModel?> executePestDetection(
      Uint8List imageBytes, String filename) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final data = await _api.detectPest(imageBytes, filename);
      _lastPestResult = PestPredictionModel.fromJson(data);
      _setLoading(false);
      return _lastPestResult;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // Dedicated Nutrient Analysis
  Future<NutrientPredictionModel?> executeNutrientAnalysis(
      Uint8List imageBytes, String filename) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final data = await _api.analyzeNutrient(imageBytes, filename);
      _lastNutrientResult = NutrientPredictionModel.fromJson(data);
      _setLoading(false);
      return _lastNutrientResult;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // Irrigation Analysis
  Future<IrrigationResultModel?> runIrrigationAnalysis({
    required double soilMoisture,
    required double temperature,
    required double humidity,
    double rainfall = 0.0,
    String crop = 'Tomato',
    String growthStage = 'Flowering',
    String soilType = 'Loamy',
    bool forecastRain = false,
  }) async {
    _setLoading(true);
    try {
      final data = await _api.analyzeIrrigation({
        'soil_moisture': soilMoisture,
        'temperature': temperature,
        'humidity': humidity,
        'rainfall': rainfall,
        'crop': crop,
        'growth_stage': growthStage,
        'soil_type': soilType,
        'forecast_rain_expected': forecastRain,
        'is_demo': _isDemoSensorMode,
      });
      _lastIrrigationResult = IrrigationResultModel.fromJson(data);
      _setLoading(false);
      return _lastIrrigationResult;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // Environmental Risk Analysis
  Future<EnvironmentResultModel?> runEnvironmentAnalysis({
    required double temperature,
    required double humidity,
    required double soilMoisture,
    double rainfall = 0.0,
    double windSpeed = 8.5,
    bool forecastRain = false,
  }) async {
    _setLoading(true);
    try {
      final data = await _api.evaluateEnvironment({
        'temperature': temperature,
        'humidity': humidity,
        'soil_moisture': soilMoisture,
        'rainfall': rainfall,
        'wind_speed': windSpeed,
        'forecast_rain_expected': forecastRain,
        'is_demo': _isDemoSensorMode,
      });
      _lastEnvironmentResult = EnvironmentResultModel.fromJson(data);
      _setLoading(false);
      return _lastEnvironmentResult;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  // IoT Hardware Zones
  List<IoTZoneModel> _iotZones = [];
  List<IoTZoneModel> get iotZones => _iotZones;

  Future<List<IoTZoneModel>> loadIoTZones() async {
    try {
      final rawList = await _api.fetchIoTZones();
      _iotZones = rawList.map((e) => IoTZoneModel.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
      return _iotZones;
    } catch (_) {
      return [];
    }
  }

  // Crop Financial Quotation (AI Powered with Zone IoT + Weather Context)
  Future<CropQuotationResponseModel?> generateCropQuotation({
    required String zoneId,
    required double areaAcres,
    required double budgetInr,
    String season = 'Kharif',
    String? customCropSelection,
  }) async {
    _setLoading(true);
    try {
      final matchedZone = _zones.firstWhere(
        (z) => z.id.toLowerCase() == zoneId.toLowerCase() ||
               z.name.toLowerCase().contains(zoneId.toLowerCase()),
        orElse: () => _zones.first,
      );

      // Dedicated AI Crop Quotation Service synthesizing Zone IoT metrics + Live Weather
      final res = CropQuotationService.generateQuotationForZone(
        zone: matchedZone,
        weather: _weather,
        farmer: _farmer,
        areaAcres: areaAcres,
        budgetInr: budgetInr,
        customCropOverride: customCropSelection,
        season: season,
      );
      _setLoading(false);
      return res;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }
}
