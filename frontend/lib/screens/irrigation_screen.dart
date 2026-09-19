import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/irrigation_result.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  double _soilMoisture = 26.5;
  double _temperature = 32.4;
  double _humidity = 55.0;
  final double _rainfall = 0.0;
  String _selectedCrop = 'Tomato';
  String _selectedStage = 'Flowering';
  final String _selectedSoil = 'Loamy';
  bool _forecastRain = false;
  bool _isValveActive = false;

  IrrigationResultModel? _result;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysis();
    });
  }

  Future<void> _runAnalysis() async {
    setState(() => _isAnalyzing = true);
    final provider = context.read<FarmProvider>();

    final res = await provider.runIrrigationAnalysis(
      soilMoisture: _soilMoisture,
      temperature: _temperature,
      humidity: _humidity,
      rainfall: _rainfall,
      crop: _selectedCrop,
      growthStage: _selectedStage,
      soilType: _selectedSoil,
      forecastRain: _forecastRain,
    );

    if (!mounted) return;

    setState(() {
      _result = res;
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precision Irrigation & Water',
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0284C7),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'IoT Soil & Microclimate Telemetry',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5A6E61),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Recalculate Water Requirements',
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.waterCyan),
                  )
                : const Icon(Icons.refresh_rounded, color: AppTheme.primaryDark),
            onPressed: _isAnalyzing ? null : _runAnalysis,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.waterCyan,
        onRefresh: _runAnalysis,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Irrigation Pattern & Schedule Hub Card
              _buildHeroIrrigationPatternCard(),

              const SizedBox(height: 18),

              // 2. Crop & Growth Stage Quick Selectors (Compact Chip Carousel)
              _buildCropAndStageSelector(),

              const SizedBox(height: 18),

              // 3. Compact Hi-Fi Sensor Sliders & Telemetry Panel
              _buildCompactSensorControlPanel(),

              const SizedBox(height: 18),

              // 4. Automated Rain Bypass Switch Card
              _buildRainBypassCard(),

              const SizedBox(height: 18),

              // 5. Agronomic Decision Factors Breakdown
              if (_result != null) _buildDecisionFactorsList(_result!),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Hero Irrigation Pattern & Schedule Hub Card
  Widget _buildHeroIrrigationPatternCard() {
    final res = _result;
    final isIrrigate = res?.status == 'IRRIGATE NOW';
    final isDelay = res?.status == 'DELAY IRRIGATION';

    final gradientColors = isIrrigate
        ? const [Color(0xFF0F2847), Color(0xFF0284C7), Color(0xFF0369A1)]
        : (isDelay
            ? const [Color(0xFF0F3823), Color(0xFF059669), Color(0xFF10B981)]
            : const [Color(0xFF1F2937), Color(0xFFD97706), Color(0xFFB45309)]);

    final statusTitle = res?.status ?? 'CALCULATING IRRIGATION...';
    final durationMins = res?.recommendedDurationMinutes ?? 35;
    final method = res?.recommendedMethod.isNotEmpty == true
        ? res!.recommendedMethod
        : 'Root-Zone Micro Drip Line';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Status Header + Valve State
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isIrrigate ? Icons.water_drop_rounded : (isDelay ? Icons.pause_circle_filled_rounded : Icons.check_circle_rounded),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY\'S IRRIGATION STATUS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            statusTitle,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.2,
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
              const SizedBox(width: 8),
              // Smart Valve Pill Button
              GestureDetector(
                onTap: () {
                  setState(() => _isValveActive = !_isValveActive);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isValveActive ? 'Smart Drip Valve OPENED for $_selectedCrop.' : 'Smart Drip Valve CLOSED.',
                      ),
                      backgroundColor: _isValveActive ? const Color(0xFF0284C7) : Colors.grey[800],
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isValveActive ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isValveActive ? Icons.power_rounded : Icons.power_off_rounded,
                        size: 13,
                        color: _isValveActive ? const Color(0xFF0C2A1B) : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isValveActive ? 'VALVE ON' : 'VALVE AUTO',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _isValveActive ? const Color(0xFF0C2A1B) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-Column Pattern Summary Grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPatternStat(
                    title: 'DURATION',
                    value: isIrrigate ? '$durationMins Mins' : '0 Mins',
                    icon: Icons.timer_outlined,
                    color: const Color(0xFF7DD3FC),
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white24),
                Expanded(
                  child: _buildPatternStat(
                    title: 'TYPE',
                    value: method.contains('Drip') ? 'Micro-Drip' : 'Sprinkler',
                    icon: Icons.grain_rounded,
                    color: const Color(0xFFBAE6FD),
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white24),
                Expanded(
                  child: _buildPatternStat(
                    title: 'WINDOW',
                    value: '06:30 AM',
                    icon: Icons.wb_twilight_rounded,
                    color: const Color(0xFFFDE68A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Reasoning Text
          Text(
            res?.reasoning ?? 'Calculating soil moisture depletion rate and crop evapotranspiration coefficient.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 3),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.75),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // 2. Crop & Growth Stage Quick Selectors (Compact Chip Carousel)
  Widget _buildCropAndStageSelector() {
    return Container(
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
              Text(
                'TARGET CROP & GROWTH STAGE',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B5E52),
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'Kc: 1.15',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.waterCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Crop Horizontal Scroll Pills
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.supportedCrops.length,
              itemBuilder: (ctx, i) {
                final crop = AppConstants.supportedCrops[i];
                final isSelected = _selectedCrop == crop;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCrop = crop);
                    _runAnalysis();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFECFDF5) : const Color(0xFFF4F7F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryGreen : const Color(0xFFE2E9E3),
                        width: isSelected ? 1.4 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        crop,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppTheme.primaryGreen : const Color(0xFF4B5E52),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Stage Horizontal Scroll Pills
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.growthStages.length,
              itemBuilder: (ctx, i) {
                final stage = AppConstants.growthStages[i];
                final isSelected = _selectedStage == stage;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStage = stage);
                    _runAnalysis();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0F9FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE5EAE5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        stage,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. Compact Hi-Fi Sensor Sliders & Telemetry Panel
  Widget _buildCompactSensorControlPanel() {
    return Container(
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
              Text(
                'LIVE SENSOR TELEMETRY & SLIDERS',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B5E52),
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'INTERACTIVE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Soil Moisture Slider
          _buildCompactSlider(
            label: 'Soil Root-Zone Moisture',
            valueText: '${_soilMoisture.toStringAsFixed(1)}%',
            value: _soilMoisture,
            min: 5.0,
            max: 95.0,
            statusPill: _soilMoisture < 30.0 ? 'DEFICIT' : 'OPTIMAL',
            activeColor: _soilMoisture < 30.0 ? const Color(0xFFD97706) : const Color(0xFF059669),
            onChanged: (val) {
              setState(() => _soilMoisture = val);
              _runAnalysis();
            },
          ),
          const Divider(height: 16),

          // Ambient Temperature Slider
          _buildCompactSlider(
            label: 'Canopy Temperature',
            valueText: '${_temperature.toStringAsFixed(1)}°C',
            value: _temperature,
            min: 15.0,
            max: 48.0,
            statusPill: _temperature > 35.0 ? 'HEAT RISK' : 'NORMAL',
            activeColor: _temperature > 35.0 ? AppTheme.riskHigh : const Color(0xFFF59E0B),
            onChanged: (val) {
              setState(() => _temperature = val);
              _runAnalysis();
            },
          ),
          const Divider(height: 16),

          // Relative Humidity Slider
          _buildCompactSlider(
            label: 'Air Relative Humidity',
            valueText: '${_humidity.toStringAsFixed(0)}%',
            value: _humidity,
            min: 10.0,
            max: 100.0,
            statusPill: '${_humidity.toStringAsFixed(0)}% RH',
            activeColor: const Color(0xFF0284C7),
            onChanged: (val) {
              setState(() => _humidity = val);
              _runAnalysis();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSlider({
    required String label,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required String statusPill,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF141F17),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusPill,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    valueText,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: activeColor,
            inactiveTrackColor: const Color(0xFFE5EAE5),
            thumbColor: activeColor,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // 4. Automated Rain Bypass Switch Card
  Widget _buildRainBypassCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _forecastRain ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _forecastRain ? const Color(0xFFBAE6FD) : const Color(0xFFE5EAE5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF0284C7), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24-Hour Rain Forecast Auto-Bypass',
                  style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
                ),
                Text(
                  _forecastRain ? 'Active: Halting scheduled water' : 'No natural rain expected today',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF5A6E61)),
                ),
              ],
            ),
          ),
          Switch(
            value: _forecastRain,
            activeThumbColor: const Color(0xFF0284C7),
            onChanged: (val) {
              setState(() => _forecastRain = val);
              _runAnalysis();
            },
          ),
        ],
      ),
    );
  }

  // 5. Agronomic Decision Factors Breakdown
  Widget _buildDecisionFactorsList(IrrigationResultModel res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DECISION FACTORS & AGRONOMIC RATIONALE',
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4B5E52),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        ...res.factors.map((f) {
          final isMoisture = f.parameter.contains('Moisture');
          final iconColor = isMoisture ? const Color(0xFF0284C7) : (f.parameter.contains('Temp') ? const Color(0xFFD97706) : AppTheme.primaryGreen);
          final bg = isMoisture ? const Color(0xFFF0F9FF) : const Color(0xFFF9FAFB);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EAE5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMoisture ? Icons.water_drop_rounded : (f.parameter.contains('Temp') ? Icons.thermostat_rounded : Icons.eco_rounded),
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              AppConstants.cleanLabel(f.parameter),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: const Color(0xFF141F17),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Target: ${AppConstants.cleanLabel(f.targetOptimal)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: iconColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.impact,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF4B5E52),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Measured Value: ${f.measuredValue}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF141F17),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
