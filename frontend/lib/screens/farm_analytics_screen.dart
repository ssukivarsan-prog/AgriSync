import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/farm_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class FarmAnalyticsScreen extends StatelessWidget {
  const FarmAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final analytics = provider.analytics;

    final diseaseDist = (analytics?['disease_distribution'] as Map<String, dynamic>?) ?? {
      'Tomato Early Blight': 12,
      'Potato Early Blight': 6,
      'Tomato Healthy': 28,
      'Corn Common Rust': 5,
    };

    final moistureTrend = (analytics?['soil_moisture_trend'] as List<dynamic>?) ?? [
      {'time': '06:00', 'moisture': 34.0, 'temp': 24.5},
      {'time': '09:00', 'moisture': 32.0, 'temp': 28.0},
      {'time': '12:00', 'moisture': 28.5, 'temp': 33.2},
      {'time': '15:00', 'moisture': 26.5, 'temp': 34.1},
      {'time': '18:00', 'moisture': 26.0, 'temp': 31.0},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Analytics & Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadAnalytics(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Analytics KPIs
            Row(
              children: [
                Expanded(
                  child: _buildKPI(
                    'TOTAL SCANS',
                    '${analytics?['total_scans_logged'] ?? 51}',
                    Icons.document_scanner,
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKPI(
                    'HEALTH RATIO',
                    '${provider.farmSummary?.cropHealthScore ?? 92.0}%',
                    Icons.eco,
                    AppTheme.healthOptimal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKPI(
                    'WATER DEFICIT',
                    '${provider.farmSummary?.waterStatus.contains("DEFICIT") == true ? "ACTIVE" : "NONE"}',
                    Icons.water_drop,
                    AppTheme.waterCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Soil Moisture & Temperature Diurnal Trend Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'SOIL MOISTURE (%) & TEMPERATURE (°C) TREND',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF72796F)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            _buildLegendDot(AppTheme.waterCyan, 'Moisture'),
                            const SizedBox(width: 10),
                            _buildLegendDot(const Color(0xFFF4A261), 'Temp'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10,
                            getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 10,
                                reservedSize: 32,
                                getTitlesWidget: (v, meta) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10, color: Color(0xFF72796F))),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, meta) {
                                  final idx = v.toInt();
                                  if (idx >= 0 && idx < moistureTrend.length) {
                                    return Text(moistureTrend[idx]['time'].toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF72796F)));
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // Soil Moisture Line
                            LineChartBarData(
                              spots: moistureTrend.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), (e.value['moisture'] as num).toDouble());
                              }).toList(),
                              isCurved: true,
                              color: AppTheme.waterCyan,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                            ),
                            // Temperature Line
                            LineChartBarData(
                              spots: moistureTrend.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), (e.value['temp'] as num).toDouble());
                              }).toList(),
                              isCurved: true,
                              color: const Color(0xFFF4A261),
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Disease Frequency Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DISEASE FREQUENCY DISTRIBUTION (HISTORICAL LOG)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF72796F)),
                    ),
                    const SizedBox(height: 16),
                    ...diseaseDist.entries.map((e) {
                      final label = AppConstants.cleanLabel(e.key);
                      final count = (e.value as num).toInt();
                      final pct = count / 50.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('$count cases', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: pct > 1.0 ? 1.0 : pct,
                              color: label.toLowerCase().contains('healthy') ? AppTheme.healthOptimal : AppTheme.riskHigh,
                              backgroundColor: Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPI(String title, String val, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(val, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF72796F))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color col, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF72796F))),
      ],
    );
  }
}
