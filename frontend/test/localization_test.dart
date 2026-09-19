import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrivyn/core/app_localization.dart';
import 'package:agrivyn/models/demo_scenario.dart';
import 'package:agrivyn/providers/farm_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalization Tests', () {
    final tamilRegex = RegExp(r'[\u0B80-\u0BFF]');

    test('English mode returns 100% pure English without Tamil characters', () {
      expect(AppLocalization.tr('nav_home', isTamil: false), equals('Home'));
      expect(AppLocalization.tr('what_should_i_sow', isTamil: false), equals('WHAT SHOULD I SOW?'));
      expect(AppLocalization.tr('how_is_my_field_doing', isTamil: false), equals('HOW IS MY FIELD DOING?'));
      expect(AppLocalization.tr('metric_soil_moisture', isTamil: false), equals('Soil Moisture'));
      expect(AppLocalization.cropName('Tomato', isTamil: false), equals('Tomato'));
      expect(AppLocalization.cropName('Paddy', isTamil: false), equals('Paddy (Rice)'));
      expect(AppLocalization.stageName('Tillering Stage', isTamil: false), equals('Tillering Stage'));
      expect(AppLocalization.zoneStatus('CRITICAL', isTamil: false), equals('CRITICAL'));
      expect(AppLocalization.zoneStatus('WARNING', isTamil: false), equals('WARNING'));
      expect(AppLocalization.zoneStatus('NORMAL', isTamil: false), equals('NORMAL'));

      // Verify no Tamil unicode range (\u0B80 - \u0BFF) in English strings
      expect(tamilRegex.hasMatch(AppLocalization.tr('nav_home', isTamil: false)), isFalse);
      expect(tamilRegex.hasMatch(AppLocalization.tr('what_should_i_sow', isTamil: false)), isFalse);
      expect(tamilRegex.hasMatch(AppLocalization.cropName('Tomato', isTamil: false)), isFalse);
      expect(tamilRegex.hasMatch(AppLocalization.stageName('Flowering Stage', isTamil: false)), isFalse);
    });

    test('Tamil mode returns 100% pure Tamil strings', () {
      expect(AppLocalization.tr('nav_home', isTamil: true), equals('முகப்பு'));
      expect(AppLocalization.tr('what_should_i_sow', isTamil: true), equals('என்ன பயிர் நடவு செய்ய வேண்டும்?'));
      expect(AppLocalization.tr('how_is_my_field_doing', isTamil: true), equals('என் வயல் நலம் எவ்வாறு உள்ளது?'));
      expect(AppLocalization.tr('metric_soil_moisture', isTamil: true), equals('மண் ஈரப்பதம்'));
      expect(AppLocalization.cropName('Tomato', isTamil: true), equals('தக்காளி'));
      expect(AppLocalization.cropName('Paddy', isTamil: true), equals('நெல்'));
      expect(AppLocalization.cropName('Banana', isTamil: true), equals('வாழை'));
      expect(AppLocalization.stageName('Tillering Stage', isTamil: true), equals('தூர்கட்டும் பருவம்'));
      expect(AppLocalization.zoneStatus('CRITICAL', isTamil: true), equals('அவசர கவனம்'));
      expect(AppLocalization.zoneStatus('WARNING', isTamil: true), equals('எச்சரிக்கை'));
      expect(AppLocalization.zoneStatus('NORMAL', isTamil: true), equals('நலம்'));

      expect(tamilRegex.hasMatch(AppLocalization.tr('nav_home', isTamil: true)), isTrue);
      expect(tamilRegex.hasMatch(AppLocalization.cropName('Paddy', isTamil: true)), isTrue);
    });

    test('All DemoScenarios provide 100% pure English in English mode and Tamil in Tamil mode', () {
      for (final s in DemoScenario.allScenarios) {
        // English mode: MUST NOT contain any Tamil characters
        expect(tamilRegex.hasMatch(s.titleFor(false)), isFalse,
            reason: 'Scenario ${s.type.name} title contains Tamil in English mode');
        expect(tamilRegex.hasMatch(s.descriptionFor(false)), isFalse,
            reason: 'Scenario ${s.type.name} description contains Tamil in English mode');
        expect(tamilRegex.hasMatch(s.riskLabelFor(false)), isFalse,
            reason: 'Scenario ${s.type.name} riskLabel contains Tamil in English mode');
        expect(tamilRegex.hasMatch(s.riskReasonFor(false)), isFalse,
            reason: 'Scenario ${s.type.name} riskReason contains Tamil in English mode');
        expect(tamilRegex.hasMatch(s.recommendedActionFor(false)), isFalse,
            reason: 'Scenario ${s.type.name} recommendedAction contains Tamil in English mode');
        expect(tamilRegex.hasMatch(s.weatherForecastFor(false)), isFalse,
            reason: 'Scenario ${s.type.name} weatherForecast contains Tamil in English mode');
        expect(tamilRegex.hasMatch(s.primaryZoneConcernFor(false)), isFalse,
            reason: 'Scenario ${s.type.name} primaryZoneConcern contains Tamil in English mode');

        // Tamil mode: MUST contain authentic Tamil characters
        expect(tamilRegex.hasMatch(s.titleFor(true)), isTrue,
            reason: 'Scenario ${s.type.name} title missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(s.descriptionFor(true)), isTrue,
            reason: 'Scenario ${s.type.name} description missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(s.riskLabelFor(true)), isTrue,
            reason: 'Scenario ${s.type.name} riskLabel missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(s.riskReasonFor(true)), isTrue,
            reason: 'Scenario ${s.type.name} riskReason missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(s.recommendedActionFor(true)), isTrue,
            reason: 'Scenario ${s.type.name} recommendedAction missing Tamil in Tamil mode');
      }
    });

    test('All FieldZones provide 100% pure English in English mode and Tamil in Tamil mode', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = FarmProvider();
      await provider.initialize();

      for (final z in provider.zones) {
        // English mode: strictly 0 Tamil characters
        expect(tamilRegex.hasMatch(z.nameFor(false)), isFalse,
            reason: 'Zone ${z.id} name contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.shortNameFor(false)), isFalse,
            reason: 'Zone ${z.id} shortName contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.cropFor(false)), isFalse,
            reason: 'Zone ${z.id} crop contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.stageFor(false)), isFalse,
            reason: 'Zone ${z.id} stage contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.soilTextureFor(false)), isFalse,
            reason: 'Zone ${z.id} soilTexture contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.statusHeadlineFor(false)), isFalse,
            reason: 'Zone ${z.id} statusHeadline contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.statusReasonFor(false)), isFalse,
            reason: 'Zone ${z.id} statusReason contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.recommendedActionFor(false)), isFalse,
            reason: 'Zone ${z.id} recommendedAction contains Tamil in English mode');
        expect(tamilRegex.hasMatch(z.statusLabelFor(false)), isFalse,
            reason: 'Zone ${z.id} statusLabel contains Tamil in English mode');

        // Tamil mode: MUST contain authentic Tamil characters
        expect(tamilRegex.hasMatch(z.nameFor(true)), isTrue,
            reason: 'Zone ${z.id} name missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.shortNameFor(true)), isTrue,
            reason: 'Zone ${z.id} shortName missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.cropFor(true)), isTrue,
            reason: 'Zone ${z.id} crop missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.stageFor(true)), isTrue,
            reason: 'Zone ${z.id} stage missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.soilTextureFor(true)), isTrue,
            reason: 'Zone ${z.id} soilTexture missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.statusHeadlineFor(true)), isTrue,
            reason: 'Zone ${z.id} statusHeadline missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.statusReasonFor(true)), isTrue,
            reason: 'Zone ${z.id} statusReason missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.recommendedActionFor(true)), isTrue,
            reason: 'Zone ${z.id} recommendedAction missing Tamil in Tamil mode');
        expect(tamilRegex.hasMatch(z.statusLabelFor(true)), isTrue,
            reason: 'Zone ${z.id} statusLabel missing Tamil in Tamil mode');
      }
    });

    test('FarmProvider toggles and persists language', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = FarmProvider();
      await provider.initialize();

      // Default is English
      expect(provider.appLanguage, equals(AppLanguage.english));
      expect(provider.isTamil, isFalse);

      // Toggle to Tamil
      provider.toggleLanguage();
      expect(provider.appLanguage, equals(AppLanguage.tamil));
      expect(provider.isTamil, isTrue);

      // Explicit set to English
      provider.setLanguage(AppLanguage.english);
      expect(provider.appLanguage, equals(AppLanguage.english));
      expect(provider.isTamil, isFalse);

      // Explicit set to Tamil
      provider.setLanguage(AppLanguage.tamil);
      expect(provider.appLanguage, equals(AppLanguage.tamil));
      expect(provider.isTamil, isTrue);
    });
  });
}
