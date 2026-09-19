import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  String _searchQuery = '';
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final items = provider.historyItems.where((item) {
      final crop = (item['crop'] ?? '').toString().toLowerCase();
      final disease = (item['disease_prediction'] ?? '').toString().toLowerCase();
      final status = (item['health_status'] ?? '').toString();

      final matchesQuery = _searchQuery.isEmpty ||
          crop.contains(_searchQuery.toLowerCase()) ||
          disease.contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == null || status == _selectedStatus;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter / Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by crop or disease...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String?>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (val) => setState(() => _selectedStatus = val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('All Statuses')),
                    const PopupMenuItem(value: 'HEALTHY', child: Text('Healthy Only')),
                    const PopupMenuItem(value: 'AT_RISK', child: Text('At Risk Only')),
                  ],
                ),
              ],
            ),
          ),

          // Scan list
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history, size: 48, color: Color(0xFF72796F)),
                        SizedBox(height: 12),
                        Text('No scan records found in database.', style: TextStyle(color: Color(0xFF72796F))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: items.length,
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      final isHealthy = item['health_status'] == 'HEALTHY';
                      final conf = (item['disease_confidence'] as num?)?.toDouble() ?? 0.0;
                      final id = item['id'] as int;

                      return Dismissible(
                        key: Key('scan_$id'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppTheme.riskHigh,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => provider.deleteHistory(id),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isHealthy ? AppTheme.healthOptimal : AppTheme.riskHigh).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isHealthy ? Icons.check_circle : Icons.warning,
                                color: isHealthy ? AppTheme.healthOptimal : AppTheme.riskHigh,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              '${item['crop']} — ${(item['disease_prediction'] ?? '').toString().replaceAll('___', ' - ').replaceAll('_', ' ')}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            subtitle: Text(
                              'Confidence: ${(conf * 100).toStringAsFixed(1)}% | ${item['timestamp'] ?? ''}',
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _showDetailModal(context, item),
                            ),
                            onTap: () => _showDetailModal(context, item),
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

  void _showDetailModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${item['crop']} Scan Report #${item['id']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Timestamp: ${item['timestamp']}', style: const TextStyle(fontSize: 12, color: Color(0xFF72796F))),
                  const Divider(height: 24),
                  _buildDetailRow('Condition Detected', AppConstants.cleanLabel((item['disease_prediction'] ?? '').toString())),
                  _buildDetailRow('Confidence', '${(((item['disease_confidence'] as num?)?.toDouble() ?? 0.0) * 100).toStringAsFixed(1)}%'),
                  _buildDetailRow('Status', AppConstants.cleanLabel(item['health_status'] ?? 'Uncertain')),
                  if (item['nutrient_prediction'] != null)
                    _buildDetailRow('Nutrient Stress', AppConstants.cleanLabel(item['nutrient_prediction'])),
                  if (item['affected_area_pct'] != null && (item['affected_area_pct'] as num) > 0)
                    _buildDetailRow('Lesion Area', '${item['affected_area_pct']}%'),
                  const SizedBox(height: 16),
                  const Text('Advisory Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(item['advisory_notes'] ?? 'No advisory notes recorded.', style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Color(0xFF72796F), fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }
}
