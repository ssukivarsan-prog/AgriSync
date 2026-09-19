import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../core/theme.dart';

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();

    if (!provider.isDemoSensorMode) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        color: AppTheme.primaryGreen.withOpacity(0.08),
        child: Row(
          children: [
            const Icon(Icons.sensors, size: 16, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'REAL IOT SENSOR STREAM ACTIVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppTheme.primaryGreen,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => provider.toggleDemoSensorMode(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Switch to Demo Mode', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: const Color(0xFFFFF3CD),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFF856404)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'DEMO SENSOR MODE ACTIVE — Sensor inputs are simulated for SIH presentation',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Color(0xFF856404),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => provider.toggleDemoSensorMode(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Switch to Real IoT', style: TextStyle(fontSize: 11, color: Color(0xFF856404))),
          ),
        ],
      ),
    );
  }
}
