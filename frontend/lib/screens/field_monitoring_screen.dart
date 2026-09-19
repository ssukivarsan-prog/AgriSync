import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/field_zone.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';
import '../widgets/language_toggle_chip.dart';
import '../widgets/interactive_field_map.dart';

class FieldMonitoringScreen extends StatefulWidget {
  const FieldMonitoringScreen({super.key});

  @override
  State<FieldMonitoringScreen> createState() => _FieldMonitoringScreenState();
}

class _FieldMonitoringScreenState extends State<FieldMonitoringScreen> {
  int _selectedZoneIndex = 1; // Default to Zone 2

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isTamil = provider.isTamil;
    final zones = provider.zones;
    final weather = provider.weather;
    final selectedZone = zones[_selectedZoneIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTamil ? 'வயல் கண்காணிப்பு & வரைபடம்' : 'Field Monitoring & Acre Map',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            Text(
              isTamil ? 'நேரடி வயல் பரப்பு & வேர் மண்டல சென்சார்கள்' : 'Interactive Geospatial Acreage & Root-Zone Sensors',
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
            // 1. Interactive Whole-Acreage Map
            InteractiveFieldMap(
              zones: zones,
              selectedIndex: _selectedZoneIndex,
              totalFarmAcres: provider.farmer.farmSizeAcres,
              onZoneSelected: (idx) {
                setState(() => _selectedZoneIndex = idx);
              },
            ),

            const SizedBox(height: 18),

            // 2. Farm Parcel Selection Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTamil ? 'பண்ணை மண்டலங்கள் (${zones.length})' : 'FARM SECTORS (${zones.length})',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: const Color(0xFF4B5E52),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isTamil ? 'சென்சார் இணைப்பு இயங்குகிறது' : 'IOT SENSOR NET ACTIVE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Zone Selector Cards
            Row(
              children: List.generate(zones.length, (i) {
                final z = zones[i];
                final isSelected = i == _selectedZoneIndex;
                final isCritical = z.status == ZoneStatus.critical;
                final isWarning = z.status == ZoneStatus.warning;

                // Mild, attention-provoking warm terracotta / amber instead of alarming harsh red
                final Color statusColor = isCritical
                    ? const Color(0xFFC2410C)
                    : (isWarning ? const Color(0xFFD97706) : const Color(0xFF059669));

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedZoneIndex = i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < zones.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? statusColor : const Color(0xFFE5EAE5),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  z.shortNameFor(isTamil),
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF141F17),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${z.areaAcres} ${isTamil ? 'ஏக்கர்' : 'Ac'} • ${z.cropFor(isTamil)}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF5A6E61),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppLocalization.zoneStatus(z.status, isTamil: isTamil),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 18),

            // 3. Active Zone Status & Action Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selectedZone.status == ZoneStatus.critical
                      ? const Color(0xFFFED7AA)
                      : const Color(0xFFE5EAE5),
                  width: selectedZone.status == ZoneStatus.critical ? 1.5 : 1.0,
                ),
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
                          selectedZone.statusHeadlineFor(isTamil).toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: selectedZone.status == ZoneStatus.critical
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF065F46),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${selectedZone.cropFor(isTamil)} • ${selectedZone.stageFor(isTamil)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4B5E52),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedZone.statusReasonFor(isTamil),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2C3E33),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Hardware Node & GPS Telemetry Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.memory_rounded, size: 13, color: AppTheme.primaryGreen),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  isTamil
                                      ? "📡 சாதனம்: ${selectedZone.hardwareNodeLabel} • TinyML: ${selectedZone.statusHeadlineFor(true)}"
                                      : "${selectedZone.hardwareNodeLabel} • TinyML: ${selectedZone.statusHeadlineFor(false)}",
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.battery_charging_full_rounded, size: 13, color: Color(0xFF059669)),
                            Text(
                              "${selectedZone.batteryPct}%",
                              style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.signal_cellular_alt_rounded, size: 13, color: Color(0xFF059669)),
                            Text(
                              "${selectedZone.signalRssiDbm} dBm",
                              style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAF9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5EAE5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.touch_app_outlined, size: 16, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${isTamil ? 'பரிந்துரைக்கப்படும் செயல்' : 'Action'}: ${selectedZone.recommendedActionFor(isTamil)}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF141F17),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 3. Complete IoT Sensor Telemetry Grid (Moisture, pH, NPK, Soil Temp, Air Temp, Humidity)
            Text(
              isTamil ? 'வேர் மண்டல & தாவர சென்சார் அளவீடுகள்' : 'ROOT-ZONE & CANOPY TELEMETRY',
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: const Color(0xFF4B5E52),
              ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.28,
              children: [
                _buildSensorCard(
                  title: isTamil ? 'மண் ஈரப்பதம்' : 'Soil Moisture',
                  value: '${selectedZone.soilMoisturePct.toStringAsFixed(1)}%',
                  subtext: isTamil ? 'ஆழம்: 20 செ.மீ' : 'Depth: 20 cm',
                  status: selectedZone.soilMoisturePct < 28.0 ? (isTamil ? 'குறைவு' : 'LOW') : (isTamil ? 'உகந்தது' : 'OPTIMAL'),
                  color: selectedZone.soilMoisturePct < 28.0 ? const Color(0xFFC2410C) : const Color(0xFF0284C7),
                  icon: Icons.water_drop_rounded,
                ),
                _buildSensorCard(
                  title: isTamil ? 'மண் pH காரத்தன்மை' : 'Soil pH Level',
                  value: selectedZone.soilPh.toStringAsFixed(1),
                  subtext: isTamil ? 'உகந்தது: 6.0 - 7.0' : 'Optimal: 6.0 - 7.0',
                  status: isTamil ? 'சமநிலை' : 'NEUTRAL',
                  color: const Color(0xFF059669),
                  icon: Icons.science_rounded,
                ),
                _buildSensorCard(
                  title: isTamil ? 'மண் வெப்பநிலை' : 'Soil Temperature',
                  value: '${selectedZone.soilTempC.toStringAsFixed(1)}°C',
                  subtext: isTamil ? 'வேர் பகுதி வெப்பம்' : 'Root-Zone Temp',
                  status: selectedZone.soilTempC > 32.0 ? (isTamil ? 'வெப்பம்' : 'WARM') : (isTamil ? 'இயல்பு' : 'NORMAL'),
                  color: const Color(0xFFD97706),
                  icon: Icons.thermostat_rounded,
                ),
                _buildSensorCard(
                  title: isTamil ? 'சுற்றுப்புற காற்று வெப்பம்' : 'Canopy Air Temp',
                  value: '${selectedZone.airTempC.toStringAsFixed(1)}°C',
                  subtext: isTamil ? 'நுண் காலநிலை' : 'Microclimate',
                  status: selectedZone.airTempC > 35.0 ? (isTamil ? 'அதிக வெப்பம்' : 'HOT') : (isTamil ? 'இயல்பு' : 'NORMAL'),
                  color: const Color(0xFFEA580C),
                  icon: Icons.wb_sunny_rounded,
                ),
                _buildSensorCard(
                  title: isTamil ? 'இலைப்பரப்பு ஈரப்பதம்' : 'Canopy Humidity',
                  value: '${selectedZone.humidityPct.toStringAsFixed(0)}%',
                  subtext: isTamil ? 'காற்றின் ஈரப்பதம்' : 'Foliar RH',
                  status: selectedZone.humidityPct > 75.0 ? (isTamil ? 'அதிகம்' : 'HIGH') : (isTamil ? 'இயல்பு' : 'NORMAL'),
                  color: const Color(0xFF0D9488),
                  icon: Icons.cloud_outlined,
                ),
                _buildSensorCard(
                  title: isTamil ? 'NPK உர சமநிலை' : 'NPK Balance',
                  value: '${selectedZone.nitrogenKgHa.toStringAsFixed(0)}:${selectedZone.phosphorusKgHa.toStringAsFixed(0)}:${selectedZone.potassiumKgHa.toStringAsFixed(0)}',
                  subtext: isTamil ? 'த : ம : சா (கிகி/ஹெ)' : 'N : P : K (kg/ha)',
                  status: isTamil ? 'சமநிலை' : 'BALANCED',
                  color: const Color(0xFF7C3AED),
                  icon: Icons.pie_chart_rounded,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. IMD Gridded Weather Intelligence (No claimed rain/wind sensors)
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
                    children: [
                      const Icon(Icons.satellite_alt_rounded, size: 18, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Text(
                        isTamil ? 'IMD வானிலை வழிகாட்டல்' : 'IMD WEATHER INTELLIGENCE',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0369A1),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.source,
                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: const Color(0xFF0284C7)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeatherStat(isTamil ? '24 மணி மழை' : '24h Rainfall', "${weather.rainfallMm24h.toStringAsFixed(1)} mm"),
                      _buildWeatherStat(isTamil ? 'காற்று வெப்பம்' : 'Ambient Temp', "${weather.temperatureC.toStringAsFixed(1)}°C"),
                      _buildWeatherStat(isTamil ? 'காற்று ஈரப்பதம்' : 'Air Humidity', "${weather.humidityPct.toStringAsFixed(0)}%"),
                      _buildWeatherStat(isTamil ? 'காற்றின் வேகம்' : 'Wind Speed', "${weather.windSpeedKmh.toStringAsFixed(1)} km/h"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isTamil
                        ? "முன்னறிவிப்பு: ${weather.forecastSummary} • ஆலோசனை: ${weather.weatherRisk}"
                        : "Forecast: ${weather.forecastSummary} • Advisory: ${weather.weatherRisk}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF075985),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String subtext,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAE5)),
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4B5E52),
                  ),
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
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF141F17),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subtext,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF0369A1))),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.outfit(fontSize: 15.5, fontWeight: FontWeight.w900, color: const Color(0xFF0C4A6E))),
      ],
    );
  }
}
