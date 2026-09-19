import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/environment_result.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';

class EnvironmentScreen extends StatefulWidget {
  const EnvironmentScreen({super.key});

  @override
  State<EnvironmentScreen> createState() => _EnvironmentScreenState();
}

class _EnvironmentScreenState extends State<EnvironmentScreen> {
  double _temp = 32.5;
  double _humidity = 68.0;
  double _soilMoisture = 28.0;
  double _rainfall = 0.0;
  double _windSpeed = 10.0;
  bool _forecastRain = false;

  EnvironmentResultModel? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  Future<void> _evaluate() async {
    setState(() => _isLoading = true);
    final provider = context.read<FarmProvider>();

    final res = await provider.runEnvironmentAnalysis(
      temperature: _temp,
      humidity: _humidity,
      soilMoisture: _soilMoisture,
      rainfall: _rainfall,
      windSpeed: _windSpeed,
      forecastRain: _forecastRain,
    );

    if (!mounted) return;

    setState(() {
      _result = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isTamil = provider.isTamil;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.tr('env_screen_title', isTamil: isTamil)),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _evaluate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Environmental Risk Banner
                  if (_result != null) _buildOverallRiskBanner(_result!, isTamil),

                  const SizedBox(height: 20),

                  // Environmental Parameter Controls
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalization.tr('env_sim_params', isTamil: isTamil),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF72796F),
                            ),
                          ),
                          const SizedBox(height: 14),

                          _buildSlider(
                            AppLocalization.tr('temp_param', isTamil: isTamil),
                            '${_temp.toStringAsFixed(1)}°C',
                            _temp,
                            15.0,
                            48.0,
                            const Color(0xFFF4A261),
                            (v) {
                              setState(() => _temp = v);
                              _evaluate();
                            },
                          ),

                          _buildSlider(
                            AppLocalization.tr('rel_humidity_param', isTamil: isTamil),
                            '${_humidity.toStringAsFixed(0)}%',
                            _humidity,
                            10.0,
                            100.0,
                            const Color(0xFF2A9D8F),
                            (v) {
                              setState(() => _humidity = v);
                              _evaluate();
                            },
                          ),

                          _buildSlider(
                            AppLocalization.tr('soil_moisture_param', isTamil: isTamil),
                            '${_soilMoisture.toStringAsFixed(1)}%',
                            _soilMoisture,
                            5.0,
                            95.0,
                            AppTheme.waterCyan,
                            (v) {
                              setState(() => _soilMoisture = v);
                              _evaluate();
                            },
                          ),

                          _buildSlider(
                            AppLocalization.tr('rainfall_param', isTamil: isTamil),
                            '${_rainfall.toStringAsFixed(1)} mm',
                            _rainfall,
                            0.0,
                            120.0,
                            const Color(0xFF457B9D),
                            (v) {
                              setState(() => _rainfall = v);
                              _evaluate();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5 Detailed Hazard Cards
                  if (_result != null) ...[
                    Text(
                      isTamil ? 'சுற்றுச்சூழல் இடர் பிரிவுகள்' : 'MULTI-HAZARD RISK BREAKDOWN',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            letterSpacing: 1.0,
                            color: const Color(0xFF72796F),
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 10),

                    _buildHazardCard(_result!.droughtRisk, Icons.grass, isTamil ? 'வறட்சி அபாயம்' : 'Drought Risk', isTamil),
                    _buildHazardCard(_result!.heatStress, Icons.thermostat, isTamil ? 'வெப்ப அழுத்த அபாயம்' : 'Heat Stress Risk', isTamil),
                    _buildHazardCard(_result!.floodRisk, Icons.flood, isTamil ? 'வெள்ளம் / நீர் தேக்க அபாயம்' : 'Flood / Waterlogging Risk', isTamil),
                    _buildHazardCard(_result!.diseaseFavorable, Icons.biotech, isTamil ? 'நோய் பரவலுக்கு சாதகமான சூழல்' : 'Disease-Favorable Weather', isTamil),
                    _buildHazardCard(_result!.generalCropStress, Icons.all_inclusive, isTamil ? 'கூட்டு பயிர் அழுத்த குறியீடு' : 'Compound Stress Index', isTamil),

                    const SizedBox(height: 16),

                    // Mitigation Protocol
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: AppTheme.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  isTamil ? 'முன்னுரிமை தடுப்பு நடவடிக்கைகள்' : 'PRIORITY MITIGATION ACTIONS',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF72796F)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._result!.recommendedMitigation.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check, size: 18, color: AppTheme.primaryGreen),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          isTamil ? AppLocalization.cleanTamil(m) : AppLocalization.cleanEnglish(m),
                                          style: const TextStyle(fontSize: 13, height: 1.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRiskBanner(EnvironmentResultModel res, bool isTamil) {
    final isHigh = res.overallEnvironmentalRisk == 'HIGH';
    final isMod = res.overallEnvironmentalRisk == 'MODERATE';
    final color = isHigh ? AppTheme.riskHigh : (isMod ? AppTheme.warningModerate : AppTheme.healthOptimal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isTamil
                      ? 'ஒட்டுமொத்த அபாயம்: ${AppLocalization.zoneStatus(res.overallEnvironmentalRisk, isTamil: true)}'
                      : 'OVERALL RISK: ${res.overallEnvironmentalRisk}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  isTamil
                      ? 'மதிப்பெண்: ${(res.overallRiskScore * 100).toStringAsFixed(0)}/100'
                      : 'Risk Score: ${(res.overallRiskScore * 100).toStringAsFixed(0)}/100',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isTamil ? AppLocalization.cleanTamil(res.explanationSummary) : AppLocalization.cleanEnglish(res.explanationSummary),
            style: const TextStyle(fontSize: 13, color: Color(0xFF2E332D)),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardCard(RiskDetailModel detail, IconData icon, String title, bool isTamil) {
    final isHigh = detail.level == 'HIGH';
    final isMod = detail.level == 'MODERATE';
    final color = isHigh ? AppTheme.riskHigh : (isMod ? AppTheme.warningModerate : AppTheme.healthOptimal);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          isTamil ? AppLocalization.zoneStatus(detail.level, isTamil: true) : detail.level,
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTamil ? AppLocalization.cleanTamil(detail.why) : AppLocalization.cleanEnglish(detail.why),
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF434940), height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isTamil
                        ? 'நடவடிக்கை: ${AppLocalization.cleanTamil(detail.action)}'
                        : 'Action: ${AppLocalization.cleanEnglish(detail.action)}',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, String valueText, double val, double min, double max, Color col, ValueChanged<double> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            Text(valueText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: col)),
          ],
        ),
        Slider(value: val, min: min, max: max, activeColor: col, onChanged: onChange),
      ],
    );
  }
}
