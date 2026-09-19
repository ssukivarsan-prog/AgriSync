import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../services/weather_intelligence_service.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';
import '../widgets/language_toggle_chip.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isTamil = provider.isTamil;
    final zones = provider.zones;
    final weather = provider.weather;
    final farmer = provider.farmer;
    final primaryZone = zones[1]; // South Field (active demo zone)

    final climateRisks = WeatherIntelligenceService.evaluateClimateRisks(
      primaryZone: primaryZone,
      weather: weather,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTamil ? 'வானிலை & இடர் பகுப்பாய்வு' : 'Agro-Climate Risk Insights',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            Text(
              isTamil ? 'வானிலை நுண்ணறிவு & பண்ணை நிகழ்வு காலவரிசை' : 'Weather Intelligence & Field History Timeline',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF5A6E61),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: LanguageToggleChip(isCompact: true),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppTheme.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTamil
                          ? 'அனைத்து தகவல்களும் IoT சென்சார்கள் & IMD மாதிரி அடிப்படையிலான முன்கூட்டிய இடர் மதிப்பீடுகளே ஆகும்.'
                          : 'All entries are predictive RISK ASSESSMENTS based on fused IoT sensors & IMD gridded models, not guaranteed forecasts.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF14532D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 1. Weather / Climate Risk Assessments Grid
            Text(
              isTamil ? 'காலநிலை & சுற்றுச்சூழல் இடர் மதிப்பீடுகள்' : 'CLIMATE & ENVIRONMENTAL RISK ASSESSMENTS',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: const Color(0xFF4B5E52),
              ),
            ),
            const SizedBox(height: 10),

            ...climateRisks.map((risk) => _buildRiskCard(risk)),

            const SizedBox(height: 20),

            // 2. Comprehensive Farm History & Event Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FARM CHRONOLOGICAL TIMELINE',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: const Color(0xFF4B5E52),
                  ),
                ),
                Text(
                  farmer.farmName,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildTimelineCard(
              timeLabel: "TODAY",
              eventTitle: "Microclimatic Risk Assessment Active",
              severity: provider.currentScenario.riskLabel,
              description: provider.currentScenario.riskReason,
              actionTaken: provider.currentScenario.recommendedAction,
              color: const Color(0xFFC2410C), // Warm Terracotta Attention Alert
              icon: Icons.notifications_active_rounded,
            ),
            _buildTimelineCard(
              timeLabel: "YESTERDAY",
              eventTitle: "Scheduled Root-Zone Irrigation Cycle",
              severity: "Action Executed",
              description: "45-minute drip cycle completed for Zone 2. Soil moisture elevated to 32% temporarily.",
              actionTaken: "Borewell pump run from 07:00 AM to 07:45 AM.",
              color: const Color(0xFF0284C7),
              icon: Icons.water_drop_rounded,
            ),
            _buildTimelineCard(
              timeLabel: "7 DAYS AGO",
              eventTitle: "Routine Foliar Scouting & Crop Health Check",
              severity: "Normal Condition",
              description: "No fungal mycelium or pest egg clutches observed during field perimeter walk.",
              actionTaken: "Preventative organic Neem spray (1% concentration) applied to border plants.",
              color: const Color(0xFF059669),
              icon: Icons.eco_rounded,
            ),
            _buildTimelineCard(
              timeLabel: "PREVIOUS SEASON",
              eventTitle: "Rotational Harvest: ${farmer.previousCrop}",
              severity: "Harvest Complete",
              description: "Harvested ${farmer.previousCrop} across 8.0 acres; residual root biomass incorporated into soil.",
              actionTaken: "Soil testing conducted before current ${farmer.currentSeason} planning.",
              color: const Color(0xFF7C3AED),
              icon: Icons.history_edu_rounded,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(ClimateRiskCardData risk) {
    final Color color = Color(risk.severityColorCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  risk.title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF141F17),
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  risk.riskLevel,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            risk.metricSummary,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF4B5E52), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            risk.explanation,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF2C3E33), height: 1.45),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5EAE5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_right_alt_rounded, size: 20, color: AppTheme.primaryGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    risk.action,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF141F17)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard({
    required String timeLabel,
    required String eventTitle,
    required String severity,
    required String description,
    required String actionTaken,
    required Color color,
    required IconData icon,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE5EAE5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Event Details
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5EAE5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          timeLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          severity,
                          style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    eventTitle,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4B5E52), height: 1.35),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "• Action: $actionTaken",
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
