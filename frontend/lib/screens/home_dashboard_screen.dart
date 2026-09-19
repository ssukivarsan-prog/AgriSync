import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../services/crop_recommendation_service.dart';
import '../models/location_crop_disease_forecast.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/app_localization.dart';
import '../widgets/language_toggle_chip.dart';
import 'crop_recommendation_screen.dart';
import 'farmer_profile_screen.dart';
import 'settings_screen.dart';
import 'ai_assistant_screen.dart';
import 'quick_demo_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const HomeDashboardScreen({super.key, this.onNavigate});

  void _showNotifications(BuildContext context, FarmProvider provider) {
    final isTamil = provider.isTamil;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalization.tr('alerts_sheet_title', isTamil: isTamil),
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  _buildAlertTile(
                    title: provider.currentScenario.riskLabelFor(isTamil),
                    whatHappened: provider.currentScenario.riskReasonFor(isTamil),
                    actionNeeded: provider.currentScenario.recommendedActionFor(isTamil),
                    severity: provider.currentScenario.farmRiskScore > 75
                        ? AppLocalization.tr('critical', isTamil: isTamil)
                        : AppLocalization.tr('warning', isTamil: isTamil),
                    timeAgo: AppLocalization.tr('alert_live', isTamil: isTamil),
                    isTamil: isTamil,
                  ),
                  _buildAlertTile(
                    title: AppLocalization.tr('weather_advisory_title', isTamil: isTamil),
                    whatHappened: isTamil
                        ? "${provider.weather.forecastSummaryFor(true)} • 24 மணி நேர மழை: ${provider.weather.rainfallMm24h.toStringAsFixed(1)} மி.மீ."
                        : "${provider.weather.forecastSummary} • 24h Rain: ${provider.weather.rainfallMm24h.toStringAsFixed(1)} mm.",
                    actionNeeded: AppLocalization.tr('weather_advisory_action', isTamil: isTamil),
                    severity: isTamil ? "தகவல்" : "INFO",
                    timeAgo: AppLocalization.tr('time_1hr_ago', isTamil: isTamil),
                    isTamil: isTamil,
                  ),
                  _buildAlertTile(
                    title: AppLocalization.tr('presowing_title', isTamil: isTamil),
                    whatHappened: AppLocalization.tr('presowing_desc', isTamil: isTamil),
                    actionNeeded: AppLocalization.tr('presowing_action', isTamil: isTamil),
                    severity: isTamil ? "தகவல்" : "INFO",
                    timeAgo: AppLocalization.tr('time_yesterday', isTamil: isTamil),
                    isTamil: isTamil,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAlertTile({
    required String title,
    required String whatHappened,
    required String actionNeeded,
    required String severity,
    required String timeAgo,
    bool isTamil = false,
  }) {
    final isHigh = severity == "HIGH" || severity == "CRITICAL" || severity == "அவசர கவனம்";
    final Color badgeColor = isHigh ? const Color(0xFFC2410C) : const Color(0xFF0284C7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHigh ? const Color(0xFFFED7AA) : const Color(0xFFE5EAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  severity,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "${AppLocalization.tr('what_happened_prefix', isTamil: isTamil)} $whatHappened",
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: const Color(0xFF374151), height: 1.35),
          ),
          const SizedBox(height: 6),
          Text(
            "${AppLocalization.tr('action_needed_prefix', isTamil: isTamil)} $actionNeeded",
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF141F17)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final farmer = provider.farmer;
    final zones = provider.zones;
    final weather = provider.weather;
    final scenario = provider.currentScenario;
    final primaryZone = zones[1]; // Zone 2 (South Field)

    final cropRecommendations = CropRecommendationService.recommendCrops(
      farmer: farmer,
      soilPh: primaryZone.soilPh,
      nitrogenKgHa: primaryZone.nitrogenKgHa,
      phosphorusKgHa: primaryZone.phosphorusKgHa,
      potassiumKgHa: primaryZone.potassiumKgHa,
      soilMoisture: primaryZone.soilMoisturePct,
      weather: weather,
    );
    final forecast = provider.locationForecast;
    final topCrop = cropRecommendations.first;
    final topForecastCrop = (forecast != null && forecast.cultivationPredictions.isNotEmpty)
        ? forecast.cultivationPredictions.first
        : null;
    final topDiseaseAlert = (forecast != null && forecast.diseasePredictions.isNotEmpty)
        ? forecast.diseasePredictions.first
        : null;

    final isRiskHigh = scenario.farmRiskScore >= 75;
    final isTamil = provider.isTamil;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_128.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, _) => Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.eco, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  Text(
                    AppLocalization.tr('app_tagline', isTamil: isTamil),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          const LanguageToggleChip(isCompact: true),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.primaryDark),
            tooltip: AppLocalization.tr('alerts', isTamil: isTamil),
            onPressed: () => _showNotifications(context, provider),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy_outlined, color: AppTheme.primaryGreen),
            tooltip: AppLocalization.tr('assistant', isTamil: isTamil),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.primaryDark),
            tooltip: AppLocalization.tr('more_options', isTamil: isTamil),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerProfileScreen()));
              } else if (val == 'tour') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => QuickDemoScreen(onNavigate: onNavigate ?? (_) {})));
              } else if (val == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 18, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(AppLocalization.tr('farmer_profile', isTamil: isTamil)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tour',
                child: Row(
                  children: [
                    const Icon(Icons.help_outline_rounded, size: 18, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(AppLocalization.tr('help_tour', isTamil: isTamil)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 18, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(AppLocalization.tr('settings_scenarios', isTamil: isTamil)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Welcome & Scenario Switcher Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTamil ? 'வணக்கம், ${farmer.name}' : 'Namaste, ${farmer.name}',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${farmer.farmName} • ${farmer.location}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4B5E52)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune_rounded, size: 14, color: Color(0xFFB45309)),
                        const SizedBox(width: 4),
                        Text(
                          scenario.titleFor(isTamil).split(':')[0],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 1. CORE QUESTION 3 & 4: FARM RISK SCORE & RECOMMENDED ACTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Mild, natural earthy terracotta & warm bronze instead of alarming harsh red
                  colors: isRiskHigh
                      ? [const Color(0xFF8A2E0F), const Color(0xFFB84518)]
                      : [const Color(0xFF065F46), const Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalization.tr('current_farm_risk_score', isTamil: isTamil),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isRiskHigh ? const Color(0xFFFFEDD5) : const Color(0xFFD1FAE5),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${scenario.farmRiskScore} / 100',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    scenario.riskLabelFor(isTamil),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scenario.riskReasonFor(isTamil),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF3F4F6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Recommended Action
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.flash_on_rounded, color: Color(0xFFFBBF24), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalization.tr('recommended_action', isTamil: isTamil),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFDE68A),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scenario.recommendedActionFor(isTamil),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. CORE QUESTION 1: WHAT SHOULD I GROW? (CROP & DISEASE FORECAST)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5EAE5)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFECFDF5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.grass_rounded, color: AppTheme.primaryGreen, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalization.tr('what_should_i_sow', isTamil: isTamil),
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF141F17),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${AppLocalization.tr('gps_prefix', isTamil: isTamil)}${forecast?.townTaluk != null ? "${forecast!.townTaluk}, " : ""}${isTamil ? provider.currentDistrict.tamilName : provider.currentDistrict.name} • ${isTamil ? provider.currentDistrict.tamilZoneName : provider.currentDistrict.zoneName}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF059669),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CropRecommendationScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalization.tr('view_all', isTamil: isTamil),
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTamil
                                  ? (topForecastCrop?.tamilName.isNotEmpty == true ? topForecastCrop!.tamilName : AppLocalization.cropName(topCrop.cropName, isTamil: true))
                                  : (topForecastCrop?.cropName ?? topCrop.cropName),
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTamil
                                  ? (topForecastCrop?.tamilSeason.isNotEmpty == true
                                      ? topForecastCrop!.tamilSeason
                                      : 'இப்பருவத்திற்கு உகந்த பயிர் பரிந்துரை')
                                  : (topForecastCrop != null
                                      ? (topForecastCrop.reasonsWhy.isNotEmpty ? topForecastCrop.reasonsWhy.first : topForecastCrop.seasonFit)
                                      : topCrop.reasonsWhy.first),
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF4B5E52)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          '${topForecastCrop?.suitabilityScore ?? topCrop.modelSuitabilityScore}% ${AppLocalization.tr('suitability', isTamil: isTamil)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Disease Outbreak Alert Banner
                  if (topDiseaseAlert != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isTamil
                                  ? '${AppLocalization.tr('predicted_disease_risk', isTamil: true)}: ${topDiseaseAlert.tamilName} (${topDiseaseAlert.riskScore}% ${AppLocalization.zoneStatus(topDiseaseAlert.riskLevel, isTamil: true)})'
                                  : 'Predicted Disease Risk: ${topDiseaseAlert.diseaseName} (${topDiseaseAlert.riskScore}% ${topDiseaseAlert.riskLevel})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF991B1B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. CORE QUESTION 2: HOW IS MY FIELD DOING? (FIELD STATUS WITH 8 METRICS)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${AppLocalization.tr('how_is_my_field_doing', isTamil: isTamil)} (${AppLocalization.cropName(primaryZone.crop, isTamil: isTamil).toUpperCase()})',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: const Color(0xFF4B5E52),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => onNavigate?.call(1), // Go to Field tab with Interactive Acre Map
                  child: Row(
                    children: [
                      const Icon(Icons.map_rounded, size: 15, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalization.tr('acre_map', isTamil: isTamil),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 8 Metrics Grid with NORMAL / WARNING / CRITICAL badges
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.28,
              children: [
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_soil_moisture', isTamil: isTamil),
                  value: '${primaryZone.soilMoisturePct.toStringAsFixed(1)}%',
                  status: primaryZone.soilMoisturePct < 28.0 ? 'CRITICAL' : 'NORMAL',
                  isCritical: primaryZone.soilMoisturePct < 28.0,
                  icon: Icons.water_drop_rounded,
                  isTamil: isTamil,
                ),
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_soil_ph', isTamil: isTamil),
                  value: primaryZone.soilPh.toStringAsFixed(1),
                  status: 'NORMAL',
                  isCritical: false,
                  icon: Icons.science_rounded,
                  isTamil: isTamil,
                ),
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_nitrogen', isTamil: isTamil),
                  value: '${primaryZone.nitrogenKgHa.toStringAsFixed(0)} kg/ha',
                  status: 'NORMAL',
                  isCritical: false,
                  icon: Icons.eco_outlined,
                  isTamil: isTamil,
                ),
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_phosphorus', isTamil: isTamil),
                  value: '${primaryZone.phosphorusKgHa.toStringAsFixed(0)} kg/ha',
                  status: 'NORMAL',
                  isCritical: false,
                  icon: Icons.spa_outlined,
                  isTamil: isTamil,
                ),
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_potassium', isTamil: isTamil),
                  value: '${primaryZone.potassiumKgHa.toStringAsFixed(0)} kg/ha',
                  status: 'NORMAL',
                  isCritical: false,
                  icon: Icons.energy_savings_leaf_outlined,
                  isTamil: isTamil,
                ),
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_soil_temp', isTamil: isTamil),
                  value: '${primaryZone.soilTempC.toStringAsFixed(1)}°C',
                  status: primaryZone.soilTempC > 32.0 ? 'WARNING' : 'NORMAL',
                  isCritical: false,
                  icon: Icons.thermostat_rounded,
                  isTamil: isTamil,
                ),
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_air_temp', isTamil: isTamil),
                  value: '${primaryZone.airTempC.toStringAsFixed(1)}°C',
                  status: primaryZone.airTempC > 36.0 ? 'WARNING' : 'NORMAL',
                  isCritical: false,
                  icon: Icons.wb_sunny_rounded,
                  isTamil: isTamil,
                ),
                _buildFieldMetricTile(
                  title: AppLocalization.tr('metric_humidity', isTamil: isTamil),
                  value: '${primaryZone.humidityPct.toStringAsFixed(0)}%',
                  status: primaryZone.humidityPct > 80.0 ? 'WARNING' : 'NORMAL',
                  isCritical: false,
                  icon: Icons.cloud_outlined,
                  isTamil: isTamil,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // 4. WEATHER INTELLIGENCE (IMD Gridded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_sync_rounded, size: 18, color: Color(0xFF0284C7)),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalization.tr('weather_intelligence', isTamil: isTamil),
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0369A1),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isTamil ? "சீரானது" : weather.weatherRisk,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0369A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildWeatherPill(isTamil ? "வெப்பம்" : "Temp", "${weather.temperatureC.toStringAsFixed(1)}°C")),
                      Expanded(child: _buildWeatherPill(isTamil ? "ஈரப்பதம்" : "Humidity", "${weather.humidityPct.toStringAsFixed(0)}%")),
                      Expanded(child: _buildWeatherPill(isTamil ? "24ம மழை" : "24h Rain", "${weather.rainfallMm24h.toStringAsFixed(1)} mm")),
                      Expanded(child: _buildWeatherPill(isTamil ? "காற்று" : "Wind", "${weather.windSpeedKmh.toStringAsFixed(0)} km/h")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTamil
                        ? "வானிலை: ${weather.forecastSummaryFor(true)}"
                        : "Forecast: ${weather.forecastSummary}",
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF075985)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldMetricTile({
    required String title,
    required String value,
    required String status,
    required bool isCritical,
    required IconData icon,
    bool isTamil = false,
  }) {
    // Mild, attention-provoking warm terracotta / amber instead of alarming harsh red
    final Color color = isCritical
        ? const Color(0xFFC2410C)
        : (status == 'WARNING' ? const Color(0xFFD97706) : const Color(0xFF059669));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical ? const Color(0xFFFED7AA) : const Color(0xFFE5EAE5),
          width: isCritical ? 1.5 : 1.0,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF4B5E52)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: color),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              AppLocalization.zoneStatus(status, isTamil: isTamil),
              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherPill(String label, String val) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0369A1))),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.outfit(fontSize: 15.5, fontWeight: FontWeight.bold, color: const Color(0xFF0C4A6E))),
      ],
    );
  }
}
