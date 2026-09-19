import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/demo_scenario.dart';
import '../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _serverController;

  @override
  void initState() {
    super.initState();
    _serverController = TextEditingController(text: context.read<FarmProvider>().apiService.baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final currentScenario = provider.currentScenario;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings & Demo Scenarios',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Prototype Demo Mode Scenarios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROTOTYPE DEMO SCENARIOS',
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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '2-DAY PROTOTYPE MODE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Switching a scenario updates sensor telemetry, IMD climate data, farm risk scores, and AI recommendations across the entire app.',
            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),

          ...DemoScenario.allScenarios.map((scenario) {
            final isSelected = currentScenario.type == scenario.type;
            Color cardColor = const Color(0xFF059669);
            if (scenario.type == DemoScenarioType.waterStress) {
              cardColor = const Color(0xFFC2410C); // Warm Terracotta
            } else if (scenario.type == DemoScenarioType.diseaseRisk) {
              cardColor = const Color(0xFFD97706);
            } else if (scenario.type == DemoScenarioType.heavyRainWaterlogging) {
              cardColor = const Color(0xFF0284C7);
            }

            return GestureDetector(
              onTap: () {
                provider.setDemoScenario(scenario.type);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Switched to ${scenario.title}! All screens updated.'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: cardColor,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? cardColor : const Color(0xFFE5EAE5),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cardColor.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            scenario.title,
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF141F17),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cardColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ACTIVE SCENARIO',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: cardColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.description,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF4B5E52)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAF9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Risk: ${scenario.riskLabel} • Score: ${scenario.farmRiskScore}/100",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cardColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 18),

          // Section 2: Server Backend Connection
          Text(
            'BACKEND AI ENGINE HOST',
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: const Color(0xFF4B5E52),
            ),
          ),
          const SizedBox(height: 8),

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
                TextField(
                  controller: _serverController,
                  decoration: const InputDecoration(
                    labelText: 'FastAPI Server Base URL',
                    prefixIcon: Icon(Icons.dns_rounded),
                    hintText: 'http://10.0.2.2:8000/api',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await provider.setServerUrl(_serverController.text.trim());
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Connected to AI Backend!' : 'Server connection failed, using mock mode.'),
                          backgroundColor: ok ? AppTheme.primaryGreen : Colors.orange,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Test & Save Server URL'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
