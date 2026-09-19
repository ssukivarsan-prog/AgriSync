import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/crop_recommendation.dart';
import '../models/field_zone.dart';
import '../models/location_crop_disease_forecast.dart';
import '../services/crop_recommendation_service.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import 'crop_quotation_screen.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefreshGps(FarmProvider provider) async {
    setState(() => _isRefreshing = true);
    await provider.fetchAndApplyFarmerLocation();
    await provider.refreshLocationForecast();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.isTamil ? 'ஜிபிஎஸ் இருப்பிடம் புதுப்பிக்கப்பட்டது' : 'GPS location updated',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.primaryDark,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isTamil = provider.isTamil;
    final farmer = provider.farmer;
    final weather = provider.weather;
    final primaryZone = provider.zones.isNotEmpty ? provider.zones[0] : null;
    final forecast = provider.locationForecast;

    final recommendations = CropRecommendationService.recommendCrops(
      farmer: farmer,
      soilPh: primaryZone?.soilPh ?? 6.8,
      nitrogenKgHa: primaryZone?.nitrogenKgHa ?? 120.0,
      phosphorusKgHa: primaryZone?.phosphorusKgHa ?? 45.0,
      potassiumKgHa: primaryZone?.potassiumKgHa ?? 180.0,
      soilMoisture: primaryZone?.soilMoisturePct ?? 34.0,
      weather: weather,
      zone: primaryZone,
    );

    final rotation = CropRecommendationService.recommendCroppingPattern(
      farmer: farmer,
      currentCrop: primaryZone?.crop ?? 'Paddy (Rice)',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalization.tr('crop_intelligence_title', isTamil: isTamil),
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            Text(
              AppLocalization.tr('crop_intelligence_sub', isTamil: isTamil),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF5A6E61),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: const Color(0xFF6B7280),
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5),
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          tabs: [
            Tab(text: AppLocalization.tr('tab_crops_to_sow', isTamil: isTamil)),
            Tab(text: AppLocalization.tr('tab_disease_risks', isTamil: isTamil)),
            Tab(text: AppLocalization.tr('tab_rotation', isTamil: isTamil)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildGpsHeaderBanner(provider, forecast, isTamil),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCultivationTab(forecast, recommendations, farmer, primaryZone, isTamil, context),
                _buildDiseaseForecastTab(forecast, isTamil, context),
                _buildRotationTab(rotation, farmer, isTamil, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsHeaderBanner(FarmProvider provider, LocationForecastResult? forecast, bool isTamil) {
    final bool isRealGps = provider.wasFetchedFromDeviceGps;
    final String districtName = forecast?.detectedDistrict ?? provider.currentDistrict.name;
    final String? townTaluk = forecast?.townTaluk ?? provider.detectedTownOrTaluk;
    final String locationDisplay = townTaluk != null && townTaluk.isNotEmpty
        ? '$townTaluk, $districtName'
        : (isTamil ? '$districtName, தமிழ்நாடு' : '$districtName, Tamil Nadu');

    final String coordsStr = provider.liveLatitude != null && provider.liveLongitude != null
        ? '${provider.liveLatitude!.toStringAsFixed(2)}° N, ${provider.liveLongitude!.toStringAsFixed(2)}° E'
        : (forecast?.gpsCoordinates ?? '10.82° N, 78.68° E');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isRealGps ? const Color(0xFFECFDF5) : const Color(0xFFF0FDF4),
        border: Border(
          bottom: BorderSide(color: isRealGps ? const Color(0xFFA7F3D0) : const Color(0xFFDCFCE7), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isRealGps ? const Color(0xFF059669) : const Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRealGps
                      ? (isTamil ? 'ஜிபிஎஸ்: $locationDisplay' : 'GPS: $locationDisplay')
                      : (isTamil ? 'இருப்பிடம்: $locationDisplay' : 'LOCATION: $locationDisplay'),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$coordsStr • ${provider.currentDistrict.zoneName}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF047857),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (provider.zones.isNotEmpty)
                  Text(
                    isTamil
                        ? '📡 சென்சார்: ${provider.zones[0].hardwareNodeLabel} • AI: ${provider.zones[0].tinymlEdgeDecision}'
                        : '📡 Hardware: ${provider.zones[0].hardwareNodeLabel} • TinyML: ${provider.zones[0].tinymlEdgeDecision}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: const Color(0xFF065F46),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                )
              : OutlinedButton.icon(
                  onPressed: () => _handleRefreshGps(provider),
                  icon: const Icon(Icons.refresh_rounded, size: 11, color: AppTheme.primaryDark),
                  label: Text(
                    AppLocalization.tr('rescan_btn', isTamil: isTamil),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    side: const BorderSide(color: Color(0xFF059669), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(0, 26),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCultivationTab(
    LocationForecastResult? forecast,
    List<CropRecommendationItem> recommendations,
    dynamic farmer,
    FieldZone? primaryZone,
    bool isTamil,
    BuildContext context,
  ) {
    final List<CropCultivationForecast> cultivationItems = forecast?.cultivationPredictions ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (cultivationItems.isNotEmpty)
          ...cultivationItems.map((c) => _buildSimpleForecastCard(c, primaryZone, isTamil, context))
        else
          ...recommendations.map((c) => _buildSimpleFallbackCard(c, isTamil, context)),

        const SizedBox(height: 12),

        // Clean & Compact Quotation CTA
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.tr('cost_roi_title', isTamil: isTamil),
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppLocalization.tr('cost_roi_desc', isTamil: isTamil),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFFD8F3DC),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CropQuotationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(0, 30),
                ),
                child: Text(
                  AppLocalization.tr('get_quote_btn', isTamil: isTamil),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleForecastCard(
    CropCultivationForecast crop,
    FieldZone? primaryZone,
    bool isTamil,
    BuildContext context,
  ) {
    final bool isTop = crop.suitabilityScore >= 90;
    final badgeColor = isTop ? const Color(0xFF059669) : const Color(0xFF0284C7);

    // Strictly pure English in English mode, strictly pure Tamil in Tamil mode
    final String displayName = isTamil
        ? (crop.tamilName.isNotEmpty ? crop.tamilName : AppLocalization.cropName(crop.cropName, isTamil: true))
        : AppLocalization.cleanEnglish(crop.cropName);

    final String durationStr = isTamil
        ? crop.durationDays.replaceAll('Days', 'நாட்கள்').replaceAll('days', 'நாட்கள்')
        : AppLocalization.cleanEnglish(crop.durationDays);

    final String yieldStr = isTamil
        ? crop.expectedYield.replaceAll('Tons/Acre', 'டன்/ஏக்கர்').replaceAll('tons/acre', 'டன்/ஏக்கர்').replaceAll('Tons / Acre', 'டன்/ஏக்கர்')
        : AppLocalization.cleanEnglish(crop.expectedYield);

    final String mandiStr = isTamil
        ? crop.primaryMandi.replaceAll('Mandi', 'சந்தை').replaceAll('Market', 'சந்தை')
        : AppLocalization.cleanEnglish(crop.primaryMandi);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop ? badgeColor.withValues(alpha: 0.3) : const Color(0xFFE5EAE5),
          width: 1.0,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF141F17),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${crop.suitabilityScore}% ${isTamil ? "பொருத்தம்" : "FIT"}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Compact metrics wrap
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildSimpleChip(Icons.timer_outlined, durationStr),
              _buildSimpleChip(Icons.trending_up_rounded, yieldStr),
              if (mandiStr.isNotEmpty)
                _buildSimpleChip(Icons.storefront_outlined, mandiStr),
            ],
          ),

          if (crop.reasonsWhy.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 13),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isTamil
                        ? 'தற்போதைய பருவநிலை, மண் தரம் மற்றும் சந்தை தேவைக்கு மிகவும் உகந்த பயிர் தேர்வாகும்.'
                        : AppLocalization.cleanEnglish(crop.reasonsWhy.first),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF374151),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleFallbackCard(
    CropRecommendationItem crop,
    bool isTamil,
    BuildContext context,
  ) {
    final bool isTop = crop.modelSuitabilityScore >= 90;
    final badgeColor = isTop ? const Color(0xFF059669) : const Color(0xFF0284C7);

    final String displayName = isTamil
        ? AppLocalization.cropName(crop.cropName, isTamil: true)
        : AppLocalization.cropName(crop.cropName, isTamil: false);

    final String durationStr = isTamil
        ? crop.durationDays.replaceAll('Days', 'நாட்கள்').replaceAll('days', 'நாட்கள்')
        : AppLocalization.cleanEnglish(crop.durationDays);

    final String yieldStr = isTamil
        ? crop.estimatedYield.replaceAll('Tons/Acre', 'டன்/ஏக்கர்').replaceAll('tons/acre', 'டன்/ஏக்கர்')
        : AppLocalization.cleanEnglish(crop.estimatedYield);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAE5)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${crop.modelSuitabilityScore}% ${isTamil ? "பொருத்தம்" : "FIT"}',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildSimpleChip(Icons.timer_outlined, durationStr),
              _buildSimpleChip(Icons.trending_up_rounded, yieldStr),
            ],
          ),
          if (crop.reasonsWhy.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              isTamil
                  ? 'மண் சத்துக்கள் மற்றும் நீர் மேலாண்மைக்கு ஏற்ப பரிந்துரைக்கப்பட்டது.'
                  : AppLocalization.cleanEnglish(crop.reasonsWhy.first),
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF374151)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (crop.hardwareTinyMlNote != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: crop.hardwareTinyMlNote!.contains('⚠️') ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: crop.hardwareTinyMlNote!.contains('⚠️') ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
                  width: 0.8,
                ),
              ),
              child: Text(
                isTamil
                    ? (crop.hardwareTinyMlNote!.contains('⚠️')
                        ? 'சென்சார் எச்சரிக்கை: மண் ஊட்டச்சத்து குறைபாடு கவனிக்கப்பட்டது.'
                        : 'சென்சார் கணிப்பு: பயிர் வளர்ச்சிக்கு உகந்த சூழல்.')
                    : AppLocalization.cleanEnglish(crop.hardwareTinyMlNote!),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: crop.hardwareTinyMlNote!.contains('⚠️') ? const Color(0xFF991B1B) : const Color(0xFF065F46),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Simple & Neat Disease Outbreaks
  Widget _buildDiseaseForecastTab(
    LocationForecastResult? forecast,
    bool isTamil,
    BuildContext context,
  ) {
    final List<PredictedDiseaseOutbreak> outbreaks = forecast?.diseasePredictions ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (outbreaks.isNotEmpty) ...[
          Text(
            isTamil
                ? 'கணிக்கப்பட்ட நோய் பரவல் முன்னறிவிப்பு (${outbreaks.length})'
                : 'PREDICTED DISEASE OUTBREAKS (${outbreaks.length})',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: const Color(0xFF4B5E52),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (outbreaks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                isTamil
                    ? 'இந்த இடத்திற்கு அதிக நோய் அபாயம் கண்டறியப்படவில்லை.'
                    : 'No high disease risk detected for this location.',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF6B7280)),
              ),
            ),
          )
        else
          ...outbreaks.map((d) => _buildSimpleDiseaseCard(d, isTamil, context)),
      ],
    );
  }

  Widget _buildSimpleDiseaseCard(
    PredictedDiseaseOutbreak outbreak,
    bool isTamil,
    BuildContext context,
  ) {
    final bool isHigh = outbreak.riskLevel.toUpperCase() == 'HIGH';
    final Color riskColor = isHigh
        ? const Color(0xFFDC2626)
        : (outbreak.riskLevel.toUpperCase() == 'MODERATE' ? const Color(0xFFD97706) : const Color(0xFF059669));
    final Color riskBg = isHigh
        ? const Color(0xFFFEF2F2)
        : (outbreak.riskLevel.toUpperCase() == 'MODERATE' ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5));

    final String diseaseTitle = isTamil
        ? (outbreak.tamilName.isNotEmpty ? outbreak.tamilName : outbreak.diseaseName)
        : AppLocalization.cleanEnglish(outbreak.diseaseName);

    final String targetCrop = isTamil
        ? AppLocalization.cropName(outbreak.targetCrop, isTamil: true)
        : AppLocalization.cropName(outbreak.targetCrop, isTamil: false);

    final String riskBadgeText = isTamil
        ? '${outbreak.riskScore}% ${isHigh ? "அதி தீவிர அபாயம்" : (outbreak.riskLevel.toUpperCase() == "MODERATE" ? "மிதமான அபாயம்" : "குறைந்த அபாயம்")}'
        : '${outbreak.riskScore}% ${outbreak.riskLevel.toUpperCase()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.25), width: 1.0),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF141F17),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTamil
                          ? 'பயிர்: $targetCrop • வகை: ${outbreak.pathogenType}'
                          : 'Target: $targetCrop • Type: ${outbreak.pathogenType}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: riskBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  riskBadgeText,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Climate trigger
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_outlined, size: 12, color: Color(0xFF6B7280)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    isTamil
                        ? 'காரணம்: ${outbreak.climateTriggers}'
                        : 'Trigger: ${AppLocalization.cleanEnglish(outbreak.climateTriggers)}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF4B5563)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // TNAU Action
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Icon(Icons.verified_rounded, size: 13, color: Color(0xFF059669)),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    isTamil
                        ? 'TNAU பரிந்துரை: ${outbreak.tnauProtocol}'
                        : 'TNAU: ${AppLocalization.cleanEnglish(outbreak.tnauProtocol)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF065F46),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: Simple Rotation
  Widget _buildRotationTab(
    CroppingPatternRecommendation rotation,
    dynamic farmer,
    bool isTamil,
    BuildContext context,
  ) {
    final String rotationSeq = isTamil
        ? rotation.rotationSequence
            .replaceAll('Paddy', 'நெல்')
            .replaceAll('Groundnut', 'நிலக்கடலை')
            .replaceAll('Pulses', 'பயறு வகைகள்')
            .replaceAll('Banana', 'வாழை')
            .replaceAll('Tomato', 'தக்காளி')
            .replaceAll('Maize', 'மக்காச்சோளம்')
            .replaceAll('Blackgram', 'உளுந்து')
            .replaceAll('Sesame', 'எள்ளு')
        : AppLocalization.cleanEnglish(rotation.rotationSequence);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5EAE5)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.sync_alt_rounded, color: Color(0xFF7C3AED), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTamil ? 'பரிந்துரைக்கப்பட்ட பயிர் சுழற்சி முறை' : 'RECOMMENDED ROTATION PATTERN',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF141F17),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Text(
                  rotationSeq,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B21A8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isTamil
                    ? 'முந்தைய பருவ சாகுபடியைத் தொடர்ந்து மண் ஊட்டச்சத்தை மீட்டெடுக்கவும் நோய் சங்கிலியை உடைக்கவும் இந்த பயிர் சுழற்சி பரிந்துரைக்கப்படுகிறது.'
                    : AppLocalization.cleanEnglish(rotation.agronomicJustification),
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF374151), height: 1.35),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isTamil
                            ? 'மண் நுண்ணுயிரி சமநிலை மற்றும் தழைச்சத்து நிலைத்தன்மையை மேம்படுத்துகிறது.'
                            : AppLocalization.cleanEnglish(rotation.biologicalContext),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF78350F),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
