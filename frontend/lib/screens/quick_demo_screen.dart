import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class QuickDemoScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const QuickDemoScreen({super.key, required this.onNavigate});

  @override
  State<QuickDemoScreen> createState() => _QuickDemoScreenState();
}

class _QuickDemoScreenState extends State<QuickDemoScreen> {
  int _currentStep = 0;
  bool _isExecuting = false;
  String _statusText = 'Ready to demonstrate AgriVyn Smart Farming AI suite.';
  Map<String, dynamic>? _lastExecutedResult;

  Future<void> _runDemoStep(int stepIndex) async {
    setState(() {
      _currentStep = stepIndex;
      _isExecuting = true;
      _statusText = 'Executing Demo Step ${stepIndex + 1}...';
    });

    final provider = context.read<FarmProvider>();

    try {
      if (stepIndex == 0) {
        // Step 1: Real Early Blight Scan
        final byteData = await rootBundle.load('assets/samples/tomato_early_blight.jpg');
        final bytes = byteData.buffer.asUint8List();
        final res = await provider.executeUnifiedScan(bytes, 'tomato_early_blight.jpg', 1);

        if (!mounted) return;
        setState(() {
          _statusText = 'Step 1 Complete: Detected ${AppConstants.cleanLabel(res?.disease.prediction)} with ${((res?.disease.confidence ?? 0) * 100).toStringAsFixed(1)}% confidence!';
          _lastExecutedResult = {'type': 'disease', 'data': res};
        });
      } else if (stepIndex == 1) {
        // Step 2: Real AgroPest YOLO Object Detection
        final byteData = await rootBundle.load('assets/samples/pest_sample.jpg');
        final bytes = byteData.buffer.asUint8List();
        final res = await provider.executePestDetection(bytes, 'pest_sample.jpg');

        if (!mounted) return;
        setState(() {
          _statusText = 'Step 2 Complete: Detected ${res?.pestCount} pest instances (${AppConstants.cleanLabel(res?.primaryPest)}) with ${((res?.confidence ?? 0) * 100).toStringAsFixed(1)}% confidence!';
          _lastExecutedResult = {'type': 'pest', 'data': res};
        });
      } else if (stepIndex == 2) {
        // Step 3: Real EarlyNSD Nutrient Classification
        final byteData = await rootBundle.load('assets/samples/nutrient_nitrogen.jpg');
        final bytes = byteData.buffer.asUint8List();
        final res = await provider.executeNutrientAnalysis(bytes, 'nutrient_nitrogen.jpg');

        if (!mounted) return;
        setState(() {
          _statusText = 'Step 3 Complete: Detected ${AppConstants.cleanLabel(res?.deficiency)} with ${((res?.confidence ?? 0) * 100).toStringAsFixed(1)}% confidence!';
          _lastExecutedResult = {'type': 'nutrient', 'data': res};
        });
      } else if (stepIndex == 3) {
        // Step 4: Smart Irrigation Decision Engine
        final res = await provider.runIrrigationAnalysis(
          soilMoisture: 22.0, // Deficit level
          temperature: 36.5,  // High heat
          humidity: 42.0,
          rainfall: 0.0,
          crop: 'Tomato',
          growthStage: 'Flowering',
          soilType: 'Loamy',
          forecastRain: false,
        );

        if (!mounted) return;
        setState(() {
          _statusText = 'Step 4 Complete: Status is ${AppConstants.cleanLabel(res?.status)} — Duration: ${res?.recommendedDurationMinutes} mins!';
          _lastExecutedResult = {'type': 'irrigation', 'data': res};
        });
      } else if (stepIndex == 4) {
        // Step 5: Compound Environmental Risk
        final res = await provider.runEnvironmentAnalysis(
          temperature: 38.0,
          humidity: 78.0,
          soilMoisture: 24.0,
          rainfall: 0.0,
          windSpeed: 14.0,
          forecastRain: false,
        );

        if (!mounted) return;
        setState(() {
          _statusText = 'Step 5 Complete: Environmental Risk Level is ${res?.overallEnvironmentalRisk} (Score: ${(res?.overallRiskScore ?? 0) * 100}%)!';
          _lastExecutedResult = {'type': 'environment', 'data': res};
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusText = 'Demo execution notice: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isExecuting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Feature Tour'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pitch Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E5128), Color(0xFF2D6A4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo_512.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AGRIVYN AI SYSTEM WALKTHROUGH',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Demonstrates all 5 functional AI pillars of AgriVyn in sequence using authentic trained weights and genuine validation metrics.',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.5, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Demo Action Buttons
            _buildDemoCard(
              index: 0,
              title: '1. Crop Disease Detection (MobileNetV3)',
              subtitle: 'Classifies 38 foliar diseases in real-time (PlantVillage 96.18% Val Acc).',
              icon: Icons.eco,
              color: AppTheme.primaryGreen,
              onTap: () => _runDemoStep(0),
              onOpenScreen: () => widget.onNavigate(1),
            ),
            _buildDemoCard(
              index: 1,
              title: '2. Multi-Pest Detection (YOLOv8n)',
              subtitle: 'Detects 12 insect pests with bounding boxes (AgroPest-12 87.71% Prec).',
              icon: Icons.bug_report,
              color: const Color(0xFFE76F51),
              onTap: () => _runDemoStep(1),
              onOpenScreen: () => widget.onNavigate(2),
            ),
            _buildDemoCard(
              index: 2,
              title: '3. Nutrient Stress Foliar AI (EarlyNSD)',
              subtitle: 'Identifies early Nitrogen & Potassium stress before yield decline.',
              icon: Icons.spa,
              color: const Color(0xFF2A9D8F),
              onTap: () => _runDemoStep(2),
              onOpenScreen: () => widget.onNavigate(3),
            ),
            _buildDemoCard(
              index: 3,
              title: '4. ICAR-Calibrated Smart Irrigation',
              subtitle: 'Calculates soil depletion & crop coefficient ETc to advise watering.',
              icon: Icons.water_drop,
              color: AppTheme.waterCyan,
              onTap: () => _runDemoStep(3),
              onOpenScreen: () => widget.onNavigate(4),
            ),
            _buildDemoCard(
              index: 4,
              title: '5. Multi-Hazard Environmental Engine',
              subtitle: 'Forecasts Drought, Heat Wave, Flood, and Fungal Infection risks.',
              icon: Icons.thunderstorm,
              color: const Color(0xFFF4A261),
              onTap: () => _runDemoStep(4),
              onOpenScreen: () => widget.onNavigate(5),
            ),

            const SizedBox(height: 20),

            // Live Execution Output Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'LIVE DEMO FEEDBACK',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF72796F)),
                      ),
                      if (_isExecuting)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusText,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  if (_lastExecutedResult != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Target Pipeline: ${_lastExecutedResult!['type'].toString().toUpperCase()} AI',
                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
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

  Widget _buildDemoCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onOpenScreen,
  }) {
    final isSelected = _currentStep == index;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? color : Colors.black.withOpacity(0.06),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF72796F)), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: _isExecuting ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Run', style: TextStyle(fontSize: 11.5)),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Open Full Interactive Screen',
              icon: const Icon(Icons.open_in_new, size: 18),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(4),
              onPressed: onOpenScreen,
            ),
          ],
        ),
      ),
    );
  }
}
