import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agrivyn/services/location_service.dart';
import 'package:agrivyn/services/risk_assessment_service.dart';
import 'package:agrivyn/services/crop_quotation_service.dart';
import 'package:agrivyn/models/field_zone.dart';
import 'package:agrivyn/models/farmer_profile.dart';
import 'package:agrivyn/models/location_crop_disease_forecast.dart';
import 'package:agrivyn/services/crop_disease_forecasting_service.dart';
import 'package:agrivyn/providers/farm_provider.dart';
import 'package:agrivyn/screens/crop_diagnosis_screen.dart';
import 'package:agrivyn/screens/crop_recommendation_screen.dart';
import 'package:agrivyn/services/crop_recommendation_service.dart';
import 'package:agrivyn/services/ai_assistant_service.dart';

void main() {
  group('Tamil Nadu Agro-Climatic & Location Service Tests', () {
    test('Contains all 38 Tamil Nadu districts across 7 agro-climatic zones', () {
      final districts = LocationService.tamilNaduDistricts;
      expect(districts.length, equals(38));

      // Verify representations of key agro-climatic zones
      final zones = districts.map((d) => d.zoneName).toSet();
      expect(zones.contains('Cauvery Delta Agro-Climatic Zone'), isTrue);
      expect(zones.contains('Western Agro-Climatic Zone'), isTrue);
      expect(zones.contains('Southern Agro-Climatic Zone'), isTrue);
      expect(zones.contains('North Eastern Agro-Climatic Zone'), isTrue);
      expect(zones.contains('North Western Agro-Climatic Zone'), isTrue);
      expect(zones.contains('High Rainfall Agro-Climatic Zone'), isTrue);
      expect(zones.contains('Hilly and High Altitude Agro-Climatic Zone'), isTrue);
    });

    test('Each district has valid Tamil names, major crops, soil types, and coordinates', () {
      for (var d in LocationService.tamilNaduDistricts) {
        expect(d.name.isNotEmpty, isTrue);
        expect(d.tamilName.isNotEmpty, isTrue);
        expect(d.zoneName.isNotEmpty, isTrue);
        expect(d.tamilZoneName.isNotEmpty, isTrue);
        expect(d.majorCrops.isNotEmpty, isTrue);
        expect(d.majorCropsTamil.isNotEmpty, isTrue);
        expect(d.typicalSoilType.isNotEmpty, isTrue);
        expect(d.typicalPh, inInclusiveRange(4.5, 9.0));
        expect(d.latitude, inInclusiveRange(8.0, 14.0));
        expect(d.longitude, inInclusiveRange(76.0, 81.0));
      }
    });

    test('getDistrict retrieves district profile accurately by English or ID', () {
      final thanjavur = LocationService.getDistrict('Thanjavur');
      expect(thanjavur.name, equals('Thanjavur'));
      expect(thanjavur.tamilName, equals('தஞ்சாவூர்'));
      expect(thanjavur.zoneName, contains('Cauvery Delta'));

      final coimbatore = LocationService.getDistrict('coimbatore');
      expect(coimbatore.name, equals('Coimbatore'));
      expect(coimbatore.tamilName, equals('கோயம்புத்தூர்'));
      expect(coimbatore.zoneName, contains('Western'));
    });

    test('fetchCurrentLocation with coordinates finds closest Tamil Nadu district via Haversine', () async {
      // Coordinates near Madurai Meenakshi Amman Temple (9.9195, 78.1198)
      final profile = await LocationService.fetchCurrentLocation(
        manualLat: 9.92,
        manualLng: 78.12,
      );
      expect(profile.name, equals('Madurai'));
      expect(profile.tamilName, equals('மதுரை'));
      expect(profile.zoneName, contains('Southern'));
    });

    test('fetchCurrentLocation with Sathyamangalam coordinates (11.4957, 77.2789) accurately resolves to Erode', () async {
      final profile = await LocationService.fetchCurrentLocation(
        manualLat: 11.4957,
        manualLng: 77.2789,
      );
      expect(profile.name, equals('Erode'));
      expect(profile.tamilName, equals('ஈரோடு'));
      expect(profile.zoneName, contains('Western'));
      // If online reverse geocoding succeeded, town/taluk is also extracted
      if (LocationService.detectedTownOrTaluk != null) {
        expect(
          LocationService.detectedTownOrTaluk!.toLowerCase(),
          anyOf(contains('sathyamangalam'), contains('satyamangalam')),
        );
      }
    });
  });

  group('Multi-Modal Video & Tamil Nadu Context Fusion Tests', () {
    final zone = FieldZone(
      id: 'zone_1',
      name: 'North Delta Plot (Paddy ADT 53)',
      crop: 'Paddy (Nellu)',
      variety: 'ADT 53 (Samba)',
      stage: 'Tillering Stage',
      areaAcres: 3.0,
      soilMoisturePct: 34.0,
      soilPh: 6.8,
      nitrogenKgHa: 135.0,
      phosphorusKgHa: 38.0,
      potassiumKgHa: 175.0,
      soilTempC: 28.5,
      airTempC: 31.0,
      humidityPct: 78.0,
      status: ZoneStatus.normal,
      statusHeadline: 'Active Samba Paddy',
      statusReason: 'Optimal delta conditions',
      recommendedAction: 'Maintain 5cm standing water layer',
      gpsCoordinates: '10.7870° N, 79.1378° E',
      hardwareNode: 'Cauvery Delta LoRa Node #1',
      relativeX: 0.32,
      relativeY: 0.28,
      soilTexture: 'Cauvery Alluvial Clay Loam (pH 6.8)',
      batteryPct: 96,
      signalRssiDbm: -62,
    );

    final weather = ImdWeatherData(
      temperatureC: 31.0,
      humidityPct: 78.0,
      rainfallMm24h: 12.0,
      forecastSummary: 'Scattered monsoon showers with humid breeze',
      weatherRisk: 'MODERATE',
    );

    final farmer = FarmerProfile(
      name: 'Murugan Selvam',
      farmSizeAcres: 6.0,
      soilType: 'Cauvery Alluvial Clay Loam',
      districtTamilNadu: 'Thanjavur',
      agroClimaticZone: 'Cauvery Delta Agro-Climatic Zone',
    );

    test('Video analysis correctly populates temporal dynamics, TNAU management, and Tamil title', () {
      final assessment = RiskAssessmentService.evaluateContextFusion(
        cvRawPrediction: 'Rice___Leaf_Blast',
        cvConfidence: 0.92,
        pestCountObserved: 7,
        primaryPestObserved: 'Brown Planthopper (BPH)',
        zone: zone,
        weather: weather,
        farmer: farmer,
        isVideoAnalysis: true,
        videoMotionSummary: 'Temporal optical sweep across 14 keyframes detected leaf underside fluttering BPH nymphs.',
        districtTamilNadu: 'Thanjavur',
      );

      expect(assessment.isVideo, isTrue);
      expect(assessment.videoAnalysisSummary, contains('Temporal optical sweep'));
      expect(assessment.videoMotionSummary, contains('Temporal optical sweep'));
      expect(assessment.districtLocation, equals('Thanjavur'));
      expect(assessment.tamilDiagnosisName, contains('குலை நோய்'));
      expect(assessment.tnauTreatmentProtocol, isNotNull);
      expect(assessment.tnauTreatmentProtocol, contains('TNAU'));
      expect(assessment.tnauTreatmentProtocol, contains('Pseudomonas fluorescens'));
    });

    test('Banana Sigatoka diagnostic fusion generates TNAU protocol and Tamil diagnosis', () {
      final assessment = RiskAssessmentService.evaluateContextFusion(
        cvRawPrediction: 'Banana___Sigatoka_leaf_spot',
        cvConfidence: 0.88,
        pestCountObserved: 3,
        primaryPestObserved: 'Pseudostem Weevil',
        zone: zone,
        weather: weather,
        farmer: farmer,
        isVideoAnalysis: true,
        videoMotionSummary: 'Canopy sweep detected foliar streak lesions and pseudostem bore holes.',
        districtTamilNadu: 'Tiruchirappalli',
      );

      expect(assessment.tamilDiagnosisName, contains('சிகடோகா இலைப்புள்ளி நோய்'));
      expect(assessment.tnauTreatmentProtocol, contains('Mineral oil'));
      expect(assessment.districtLocation, equals('Tiruchirappalli'));
    });
  });

  group('Tamil Nadu Native Crops Quotation Benchmarks Tests', () {
    test('Tamil Nadu crops are present in benchmarks with realistic economic metrics', () {
      final benchmarks = CropQuotationService.cropBenchmarks;

      expect(benchmarks.containsKey('Banana (Vazhai)'), isTrue);
      expect(benchmarks.containsKey('Coconut (Thennai)'), isTrue);
      expect(benchmarks.containsKey('Turmeric (Manjal)'), isTrue);
      expect(benchmarks.containsKey('Sugarcane (Karumbu)'), isTrue);
      expect(benchmarks.containsKey('Black Gram (Ulundu)'), isTrue);
      expect(benchmarks.containsKey('Chillies (Milagai)'), isTrue);

      final banana = benchmarks['Banana (Vazhai)']!;
      expect(banana['yield_quintals_per_acre'], equals(280.0));
      expect(banana['mandi_price_per_quintal'], equals(2200.0));

      final turmeric = benchmarks['Turmeric (Manjal)']!;
      expect(turmeric['optimal_soil'], contains('Red Loamy'));
      expect(turmeric['mandi_price_per_quintal'], equals(13500.0));
    });

    test('evaluateAllCropSuitabilities generates competitive scores for Tamil Nadu native crops', () {
      final zone = FieldZone(
        id: 'zone_4',
        name: 'West Plot Fallow',
        crop: 'Fallow',
        variety: 'Unplanted',
        stage: 'Tilled',
        areaAcres: 2.0,
        soilMoisturePct: 30.0,
        soilPh: 6.8,
        nitrogenKgHa: 110.0,
        phosphorusKgHa: 40.0,
        potassiumKgHa: 160.0,
        soilTempC: 28.0,
        airTempC: 32.0,
        humidityPct: 65.0,
        status: ZoneStatus.normal,
        statusHeadline: 'Fallow Ready',
        statusReason: 'Tilled',
        recommendedAction: 'Plant pulse/legume',
        gpsCoordinates: '10.7870° N, 79.1378° E',
        hardwareNode: 'Node 4',
        relativeX: 0.7,
        relativeY: 0.7,
        soilTexture: 'Cauvery Alluvial Clay Loam',
        batteryPct: 90,
        signalRssiDbm: -65,
        isFallow: true,
      );

      final weather = ImdWeatherData(
        temperatureC: 32.0,
        humidityPct: 65.0,
        rainfallMm24h: 5.0,
        forecastSummary: 'Partly cloudy',
        weatherRisk: 'LOW',
      );

      final farmer = FarmerProfile(
        name: 'Murugan Selvam',
        farmSizeAcres: 6.0,
        soilType: 'Cauvery Alluvial Clay Loam',
        districtTamilNadu: 'Thanjavur',
        agroClimaticZone: 'Cauvery Delta Agro-Climatic Zone',
      );

      final scored = CropQuotationService.evaluateAllCropSuitabilities(
        zone: zone,
        weather: weather,
        farmer: farmer,
        budgetInr: 100000.0,
        areaAcres: 2.0,
      );

      expect(scored.isNotEmpty, isTrue);
      // Check that Tamil Nadu crops are evaluated
      final scoredNames = scored.map((s) => s.cropName).toList();
      expect(scoredNames.contains('Banana (Vazhai)'), isTrue);
      expect(scoredNames.contains('Black Gram (Ulundu)'), isTrue);
      expect(scoredNames.contains('Turmeric (Manjal)'), isTrue);
    });
  });

  group('FarmProvider Tamil Nadu Integration Tests', () {
    test('Default district is Thanjavur and can be updated to any Tamil Nadu district', () async {
      final provider = FarmProvider();
      expect(provider.currentDistrict.name, equals('Thanjavur'));
      expect(provider.currentDistrict.tamilName, equals('தஞ்சாவூர்'));

      // Change district to Madurai
      await provider.fetchAndApplyFarmerLocation(manualDistrict: 'Madurai');
      expect(provider.currentDistrict.name, equals('Madurai'));
      expect(provider.currentDistrict.tamilName, equals('மதுரை'));
      expect(provider.farmerProfile.districtTamilNadu, equals('Madurai'));
      expect(provider.farmerProfile.agroClimaticZone, contains('Southern'));
    });

    test('Device GPS coordinate lock resolves to exact Tamil Nadu district and updates field zones', () async {
      // Coordinates for Coimbatore (11.0168, 76.9558)
      final profile = await LocationService.fetchCurrentLocation(
        manualLat: 11.0168,
        manualLng: 76.9558,
      );
      expect(profile.name, equals('Coimbatore'));
      expect(profile.tamilName, equals('கோயம்புத்தூர்'));
      expect(LocationService.wasFetchedFromDeviceGps, isTrue);
      expect(LocationService.lastRealLatitude, equals(11.0168));
      expect(LocationService.lastRealLongitude, equals(76.9558));

      final provider = FarmProvider();
      await provider.fetchAndApplyFarmerLocation();
      // Verify zones received GPS coordinates
      expect(provider.zones.first.gpsCoordinates.isNotEmpty, isTrue);
    });

    test('Sathyamangalam GPS coordinates lock to Erode district and update Farmer profile', () async {
      final provider = FarmProvider();
      await provider.fetchAndApplyFarmerLocation(
        manualLat: 11.4957,
        manualLng: 77.2789,
      );
      expect(provider.currentDistrict.name, equals('Erode'));
      expect(provider.currentDistrict.tamilName, equals('ஈரோடு'));
      expect(provider.farmerProfile.districtTamilNadu, equals('Erode'));
      expect(provider.farmerProfile.location, contains('Erode'));
    });

    testWidgets('CropDiagnosisScreen renders with zero overflow on narrow screen (360px)', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final provider = FarmProvider();
      await provider.fetchAndApplyFarmerLocation(
        manualLat: 11.4957,
        manualLng: 77.2789,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FarmProvider>.value(
            value: provider,
            child: const CropDiagnosisScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify no RenderFlex overflow exceptions occurred
      expect(tester.takeException(), isNull);
      // Verify the location card header is present with Erode
      expect(find.textContaining('Erode'), findsWidgets);
      // Verify both action buttons are rendered
      expect(find.text('Device GPS'), findsOneWidget);
      expect(find.text('Change District'), findsOneWidget);
    });
  });

  group('Location-Aware Sowing & Disease Outbreak Forecasting Tests', () {
    test('generateLocalForecast for Sathyamangalam (Erode) accurately predicts Turmeric cultivation and Rhizome Rot outbreak', () {
      final erodeDist = LocationService.getDistrict('Erode');
      final weather = ImdWeatherData(
        temperatureC: 30.5,
        humidityPct: 78.0,
        rainfallMm24h: 8.0,
        forecastSummary: 'Partly cloudy with intermittent showers',
        weatherRisk: 'LOW',
      );

      final forecast = CropDiseaseForecastingService.generateLocalForecast(
        district: erodeDist,
        soilPh: 6.8,
        soilMoisture: 36.0,
        weather: weather,
        latitude: 11.4957,
        longitude: 77.2789,
        townTaluk: 'Sathyamangalam',
      );

      expect(forecast.detectedDistrict, equals('Erode'));
      expect(forecast.townTaluk, equals('Sathyamangalam'));
      expect(forecast.zoneName, contains('Western'));

      // Verify cultivation predictions include native crops
      final cropNames = forecast.cultivationPredictions.map((c) => c.cropName).toList();
      expect(cropNames.any((n) => n.contains('Turmeric')), isTrue);
      expect(cropNames.any((n) => n.contains('Sugarcane')), isTrue);
      expect(cropNames.any((n) => n.contains('Banana')), isTrue);

      final turmeric = forecast.cultivationPredictions.firstWhere((c) => c.cropName.contains('Turmeric'));
      expect(turmeric.suitabilityScore, greaterThanOrEqualTo(90));
      expect(turmeric.tamilName, contains('மஞ்சள்'));
      expect(turmeric.primaryMandi, contains('Erode'));

      // Verify disease predictions include Turmeric Rhizome Rot
      final diseaseNames = forecast.diseasePredictions.map((d) => d.diseaseName).toList();
      expect(diseaseNames.any((d) => d.contains('Rhizome Rot')), isTrue);

      final rhizomeRot = forecast.diseasePredictions.firstWhere((d) => d.diseaseName.contains('Rhizome Rot'));
      expect(rhizomeRot.riskLevel, anyOf(equals('HIGH'), equals('MODERATE')));
      expect(rhizomeRot.targetCrop, contains('Turmeric'));
      expect(rhizomeRot.tnauProtocol.isNotEmpty, isTrue);
    });

    test('generateLocalForecast for Thanjavur predicts Delta Paddy & Blast disease outbreak', () {
      final thanjavurDist = LocationService.getDistrict('Thanjavur');
      final weather = ImdWeatherData(
        temperatureC: 32.0,
        humidityPct: 82.0,
        rainfallMm24h: 15.0,
        forecastSummary: 'High humidity delta breeze with monsoon rain',
        weatherRisk: 'MODERATE',
      );

      final forecast = CropDiseaseForecastingService.generateLocalForecast(
        district: thanjavurDist,
        soilPh: 6.8,
        soilMoisture: 38.0,
        weather: weather,
        latitude: 10.7870,
        longitude: 79.1378,
      );

      expect(forecast.detectedDistrict, equals('Thanjavur'));
      expect(forecast.zoneName, contains('Cauvery Delta'));

      // Verify cultivation predictions
      final cropNames = forecast.cultivationPredictions.map((c) => c.cropName).toList();
      expect(cropNames.any((n) => n.contains('Paddy')), isTrue);

      // Verify disease predictions
      final diseaseNames = forecast.diseasePredictions.map((d) => d.diseaseName).toList();
      expect(diseaseNames.any((d) => d.contains('Blast') || d.contains('Blight')), isTrue);
    });

    test('LocationForecastResult correctly serializes and deserializes JSON', () {
      final erodeDist = LocationService.getDistrict('Erode');
      final weather = ImdWeatherData(
        temperatureC: 30.5,
        humidityPct: 78.0,
        rainfallMm24h: 8.0,
        forecastSummary: 'Clear sky',
        weatherRisk: 'LOW',
      );

      final original = CropDiseaseForecastingService.generateLocalForecast(
        district: erodeDist,
        soilPh: 6.8,
        soilMoisture: 36.0,
        weather: weather,
        latitude: 11.4957,
        longitude: 77.2789,
        townTaluk: 'Sathyamangalam',
      );

      final jsonMap = original.toJson();
      final restored = LocationForecastResult.fromJson(jsonMap);

      expect(restored.detectedDistrict, equals(original.detectedDistrict));
      expect(restored.townTaluk, equals(original.townTaluk));
      expect(restored.cultivationPredictions.length, equals(original.cultivationPredictions.length));
      expect(restored.diseasePredictions.length, equals(original.diseasePredictions.length));
      expect(restored.cultivationPredictions.first.cropName, equals(original.cultivationPredictions.first.cropName));
    });

    test('FarmProvider maintains and auto-updates locationForecast on GPS lock', () async {
      final provider = FarmProvider();
      expect(provider.locationForecast, isNotNull);

      // Apply Sathyamangalam, Erode GPS location
      await provider.fetchAndApplyFarmerLocation(
        manualLat: 11.4957,
        manualLng: 77.2789,
      );

      expect(provider.locationForecast, isNotNull);
      expect(provider.locationForecast!.detectedDistrict, equals('Erode'));
      expect(provider.locationForecast!.cultivationPredictions.isNotEmpty, isTrue);
      expect(provider.locationForecast!.diseasePredictions.isNotEmpty, isTrue);
      expect(
        provider.locationForecast!.cultivationPredictions.any((c) => c.cropName.contains('Turmeric')),
        isTrue,
      );
    });

    testWidgets('CropRecommendationScreen renders all 3 tabs without overflow on 360px screen', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final provider = FarmProvider();
      await provider.fetchAndApplyFarmerLocation(
        manualLat: 11.4957,
        manualLng: 77.2789,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FarmProvider>.value(
            value: provider,
            child: const CropRecommendationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check for zero RenderFlex overflows
      expect(tester.takeException(), isNull);

      // Verify all 3 tabs are present
      expect(find.text('CROPS TO SOW'), findsOneWidget);
      expect(find.text('DISEASE RISKS'), findsOneWidget);
      expect(find.text('ROTATION'), findsOneWidget);

      // Verify GPS banner is rendered
      expect(find.textContaining('Erode'), findsWidgets);

      // Switch to Disease Risks tab
      await tester.tap(find.text('DISEASE RISKS'));
      await tester.pumpAndSettle();

      // Check for zero RenderFlex overflows on Disease Risks tab
      expect(tester.takeException(), isNull);
      expect(find.textContaining('PREDICTED DISEASE OUTBREAKS'), findsOneWidget);
      expect(find.textContaining('TNAU'), findsWidgets);

      // Switch to Rotation tab
      await tester.tap(find.text('ROTATION'));
      await tester.pumpAndSettle();

      // Check for zero RenderFlex overflows on Rotation tab
      expect(tester.takeException(), isNull);
      expect(find.text('RECOMMENDED ROTATION PATTERN'), findsOneWidget);
    });
  });

  group('Hardware Device TinyML Decisions Integration Tests', () {
    final farmer = FarmerProfile(
      name: 'Ramasamy',
      farmName: 'Ramasamy Cauvery Farm',
      currentSeason: 'Samba Season',
      previousCrop: 'Paddy',
      soilType: 'Cauvery Alluvial Clay Loam',
      waterAvailability: 'Canal & Borewell',
      districtTamilNadu: 'Thanjavur',
      agroClimaticZone: 'Cauvery Delta Agro-Climatic Zone',
    );

    final weather = ImdWeatherData(
      temperatureC: 32.0,
      humidityPct: 65.0,
      rainfallMm24h: 0.0,
    );

    final waterStressZone = FieldZone(
      id: 'stress_zone',
      name: 'South Field (Water Stress)',
      crop: 'Tomato',
      variety: 'PKM-1',
      stage: 'Flowering',
      areaAcres: 2.5,
      soilMoisturePct: 22.0,
      soilPh: 6.5,
      nitrogenKgHa: 110.0,
      phosphorusKgHa: 50.0,
      potassiumKgHa: 140.0,
      soilTempC: 34.0,
      airTempC: 36.0,
      humidityPct: 45.0,
      status: ZoneStatus.critical,
      statusHeadline: 'South Field — Water Stress',
      statusReason: 'Soil moisture dropped to 22.0%',
      recommendedAction: 'Initiate urgent drip cycle',
      hardwareNode: 'Sub-Node Kit #2 (Dual Probe)',
    );

    test('CropRecommendationService accounts for hardware node TinyML Water Stress decision', () {
      final recs = CropRecommendationService.recommendCrops(
        farmer: farmer,
        soilPh: waterStressZone.soilPh,
        nitrogenKgHa: waterStressZone.nitrogenKgHa,
        phosphorusKgHa: waterStressZone.phosphorusKgHa,
        potassiumKgHa: waterStressZone.potassiumKgHa,
        soilMoisture: waterStressZone.soilMoisturePct,
        weather: weather,
        zone: waterStressZone,
      );

      expect(recs, isNotEmpty);
      // Verify hardware TinyML note is present
      expect(recs.first.hardwareTinyMlNote, isNotNull);
      expect(recs.first.hardwareTinyMlNote, contains('Hardware TinyML Decision'));
      expect(recs.first.hardwareTinyMlNote, contains('Sub-Node Kit #2'));

      // Verify drought-hardy crops have positive recommendation
      final groundnut = recs.firstWhere((r) => r.cropName.contains('Groundnut'));
      expect(groundnut.hardwareTinyMlNote, contains('Prioritized for drought-hardiness'));
    });

    test('CropQuotationService accounts for hardware TinyML decision in quotation summary', () {
      final quote = CropQuotationService.generateQuotationForZone(
        zone: waterStressZone,
        weather: weather,
        farmer: farmer,
        areaAcres: 2.5,
        budgetInr: 100000.0,
      );

      expect(quote.tinymlDecision, equals('South Field — Water Stress'));
      expect(quote.zoneHardwareType, contains('TinyML'));
      expect(quote.recommendedCrop.zoneIotContext['tinyml_edge_decision'], equals('South Field — Water Stress'));
    });

    test('RiskAssessmentService fuses CV detection with hardware TinyML decision', () {
      final assessment = RiskAssessmentService.evaluateContextFusion(
        cvRawPrediction: 'Tomato___Early_blight',
        cvConfidence: 0.89,
        pestCountObserved: 0,
        primaryPestObserved: null,
        zone: waterStressZone,
        weather: weather,
        farmer: farmer,
        districtTamilNadu: 'Thanjavur',
      );

      expect(assessment.scientificExplanation, contains('Edge Hardware'));
      expect(assessment.scientificExplanation, contains('TinyML Decision'));
      expect(assessment.scientificExplanation, contains('Sub-Node Kit #2'));
    });

    test('AiAssistantService incorporates hardware TinyML decision in response', () {
      final reply = AiAssistantService.generateContextualResponse(
        query: 'What should I sow?',
        farmer: farmer,
        zones: [waterStressZone],
        weather: weather,
        latestAssessment: null,
      );

      expect(reply, contains('TinyML decision'));
      expect(reply, contains('Sub-Node Kit #2'));
    });
  });
}

