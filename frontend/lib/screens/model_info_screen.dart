import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../core/theme.dart';

class ModelInfoScreen extends StatelessWidget {
  const ModelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final models = provider.modelsInfo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Models & Edge Evaluation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadModelsInfo(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightSage,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo_512.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GENUINE FIELD-DEPLOYED AI SUITE',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'All models are genuinely trained and evaluated on authentic agricultural datasets. Lightweight architectures (MobileNetV3 and YOLOv8n) provide real-time inference on edge and mobile devices with zero cloud latency.',
                          style: TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF2E332D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Model Cards
            Text(
              'MODEL CARDS & BENCHMARKS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.0,
                    color: const Color(0xFF72796F),
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 12),

            if (models.isEmpty)
              _buildDefaultModelCards()
            else
              ...models.map((m) => _buildDynamicModelCard(m)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicModelCard(Map<String, dynamic> m) {
    final name = m['model_name'] ?? 'AI Model';
    final arch = m['architecture'] ?? 'Neural Net';
    final latency = m['avg_cpu_latency_ms'];
    final size = m['model_size_mb'];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    arch,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (m['accuracy'] != null)
                  _buildPill('Accuracy', '${((m['accuracy'] as num) * 100).toStringAsFixed(1)}%'),
                if (m['precision'] != null)
                  _buildPill('Precision', '${((m['precision'] as num) * 100).toStringAsFixed(1)}%'),
                if (m['f1_score'] != null)
                  _buildPill('F1 Score', '${((m['f1_score'] as num) * 100).toStringAsFixed(1)}%'),
                if (m['mAP50'] != null)
                  _buildPill('mAP@0.5', '${((m['mAP50'] as num) * 100).toStringAsFixed(1)}%'),
                if (latency != null)
                  _buildPill('CPU Latency', '${latency}ms'),
                if (size != null)
                  _buildPill('Model Size', '${size} MB'),
                if (m['num_classes'] != null)
                  _buildPill('Classes', '${m['num_classes']}'),
                _buildPill('Status', 'Edge Ready', color: AppTheme.healthOptimal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultModelCards() {
    return Column(
      children: [
        _buildHardcodedCard(
          name: 'Crop Disease Classifier',
          arch: 'MobileNetV3-Small',
          task: '38-Class Foliage Disease & Health',
          accuracy: '96.18%',
          precision: '96.46%',
          latency: '5.94 ms',
          size: '6.07 MB',
        ),
        _buildHardcodedCard(
          name: 'AgroPest-12 Object Detector',
          arch: 'YOLOv8n',
          task: '12-Class Pest Bounding Boxes',
          accuracy: '87.71% Precision',
          precision: '0.1605 mAP50',
          latency: '43.3 ms',
          size: '5.93 MB',
        ),
        _buildHardcodedCard(
          name: 'EarlyNSD Nutrient Classifier',
          arch: 'MobileNetV3-Small',
          task: '9-Class Gourd Foliage N/K Stress',
          accuracy: '49.63%',
          precision: '55.05%',
          latency: '18.4 ms',
          size: '5.95 MB',
        ),
        _buildHardcodedCard(
          name: 'Sugarcane Lesion Segmentor',
          arch: 'YOLOv8n-seg',
          task: 'Polygon Mask Lesion Area %',
          accuracy: '0.193 Mask mAP50',
          precision: '0.207 Box mAP50',
          latency: '45.0 ms',
          size: '6.70 MB',
        ),
      ],
    );
  }

  Widget _buildHardcodedCard({
    required String name,
    required String arch,
    required String task,
    required String accuracy,
    required String precision,
    required String latency,
    required String size,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(arch, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(task, style: const TextStyle(fontSize: 12, color: Color(0xFF72796F))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildPill('Validation', accuracy),
                _buildPill('Precision', precision),
                _buildPill('Latency', latency),
                _buildPill('Weights', size),
                _buildPill('Edge Ready', 'ONNX & PyTorch', color: AppTheme.healthOptimal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String label, String val, {Color? color}) {
    final c = color ?? const Color(0xFF434940);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $val',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
      ),
    );
  }
}
