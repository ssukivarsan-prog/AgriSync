import 'package:flutter_test/flutter_test.dart';
import 'package:agrivyn/models/field_zone.dart';
import 'package:agrivyn/models/farmer_profile.dart';
import 'package:agrivyn/services/crop_quotation_service.dart';

void main() {
  group('CropQuotationService AI Engine Tests', () {
    final weather = ImdWeatherData(
      temperatureC: 32.0,
      humidityPct: 52.0,
      rainfallMm24h: 0.0,
      forecastSummary: 'Partly cloudy, light evening showers',
      weatherRisk: 'LOW',
    );

    final farmer = FarmerProfile(
      name: 'Ramesh Patil',
      farmSizeAcres: 10.0,
      soilType: 'Sandy Loam',
    );

    test('Empty / Fallow Zone (Zone 4) generates fresh sowing quotation', () {
      final emptyZone = FieldZone(
        id: 'zone_4',
        name: 'West Plot (1.5 Acres - Fallow)',
        crop: 'Fallow (Ready for Sowing)',
        variety: 'Unplanted',
        stage: 'Tilled / Seedbed Ready',
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
        statusHeadline: 'West Plot — Fallow',
        statusReason: 'Tilled and ready for sowing',
        recommendedAction: 'Select optimal crop',
        gpsCoordinates: '18.5200° N, 73.8510° E',
        hardwareNode: 'Sub-Node Kit #4',
        relativeX: 0.72,
        relativeY: 0.80,
        soilTexture: 'Sandy Loam (pH 6.6)',
        batteryPct: 94,
        signalRssiDbm: -68,
        isFallow: true,
        previousHarvestedCrop: 'Groundnut (Peanut)',
      );

      expect(emptyZone.isEmptyPlot, isTrue);

      final quotation = CropQuotationService.generateQuotationForZone(
        zone: emptyZone,
        weather: weather,
        farmer: farmer,
        areaAcres: 1.5,
        budgetInr: 100000.0,
      );

      expect(quotation.recommendedCrop.cropName, isNotEmpty);
      expect(quotation.recommendedCrop.suitabilityScore, greaterThanOrEqualTo(75));
      expect(quotation.recommendedCrop.totalEstimatedCost, greaterThan(0));
      expect(quotation.recommendedCrop.lineItems.length, 6);

      // Verify empty plot includes pre-sowing deep tillage
      final laborItem = quotation.recommendedCrop.lineItems.firstWhere((i) => i.category.contains('Labor'));
      expect(laborItem.details.contains('deep ploughing') || laborItem.itemName.contains('Deep Tillage'), isTrue);
    });

    test('Filled Zone (Zone 2 - Tomato) penalizes repeat monoculture & recommends rotation', () {
      final filledZone = FieldZone(
        id: 'zone_2',
        name: 'South Field (2.5 Acres)',
        crop: 'Tomato',
        variety: 'Kufri Jyoti',
        stage: 'Flowering Stage',
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
        statusHeadline: 'South Field — Water Stress',
        statusReason: 'Water stress detected',
        recommendedAction: 'Irrigate',
        gpsCoordinates: '18.5192° N, 73.8550° E',
        hardwareNode: 'Sub-Node Kit #2',
        relativeX: 0.32,
        relativeY: 0.72,
        soilTexture: 'Sandy Loam (pH 6.5)',
        batteryPct: 88,
        signalRssiDbm: -76,
      );

      expect(filledZone.isEmptyPlot, isFalse);

      final scores = CropQuotationService.evaluateAllCropSuitabilities(
        zone: filledZone,
        weather: weather,
        farmer: farmer,
        budgetInr: 100000.0,
        areaAcres: 2.5,
      );

      final tomatoScore = scores.firstWhere((s) => s.cropName == 'Tomato').score;
      final altScore = scores.firstWhere((s) => s.cropName != 'Tomato').score;

      // Because Tomato is already standing on this plot, mono-crop penalty is applied
      expect(tomatoScore, lessThan(altScore));
    });

    test('Crop override produces comprehensive variance difference model', () {
      final emptyZone = FieldZone(
        id: 'zone_4',
        name: 'West Plot (1.5 Acres - Fallow)',
        crop: 'Fallow',
        variety: 'None',
        stage: 'Ready',
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
        statusHeadline: 'Normal',
        statusReason: 'Ready',
        recommendedAction: 'Sow',
        gpsCoordinates: '18.5200° N, 73.8510° E',
        hardwareNode: 'Node 4',
        relativeX: 0.7,
        relativeY: 0.8,
        soilTexture: 'Sandy Loam',
        batteryPct: 90,
        signalRssiDbm: -70,
        isFallow: true,
      );

      final quotation = CropQuotationService.generateQuotationForZone(
        zone: emptyZone,
        weather: weather,
        farmer: farmer,
        areaAcres: 1.5,
        budgetInr: 150000.0,
        customCropOverride: 'Tomato',
      );

      expect(quotation.comparisonIfChanged, isNotNull);
      final diff = quotation.comparisonIfChanged!;
      expect(diff.suggestedCrop, isNotEmpty);
      expect(diff.selectedCrop, 'Tomato');
      expect(diff.keyTradeoffs, isNotEmpty);
      expect(diff.aiAgronomistVerdict, isNotEmpty);
    });
  });
}
