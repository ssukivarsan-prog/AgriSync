import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/scan_result.dart';
import '../widgets/bounding_box_painter.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class PestDetectionScreen extends StatefulWidget {
  const PestDetectionScreen({super.key});

  @override
  State<PestDetectionScreen> createState() => _PestDetectionScreenState();
}

class _PestDetectionScreenState extends State<PestDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _fileName;
  PestPredictionModel? _result;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        setState(() {
          _imageBytes = bytes;
          _fileName = file.name;
          _result = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _analyze() async {
    if (_imageBytes == null || _fileName == null) return;
    setState(() => _isLoading = true);

    final provider = context.read<FarmProvider>();
    final res = await provider.executePestDetection(_imageBytes!, _fileName!);

    if (!mounted) return;

    setState(() {
      _result = res;
      _isLoading = false;
    });

    if (res == null) {
      final err = provider.errorMessage ?? 'Could not connect to AI backend for pest analysis.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppTheme.riskHigh,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgroPest AI Detector'),
        actions: [
          if (_imageBytes != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
              onPressed: () => setState(() {
                _imageBytes = null;
                _result = null;
              }),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload / Preview Area
            if (_imageBytes == null)
              _buildUploadBox()
            else
              _buildDetectionCanvas(),

            const SizedBox(height: 16),

            if (_imageBytes != null && _result == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyze,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Detecting Pests with YOLO...' : 'Run AgroPest Detection'),
                ),
              ),

            const SizedBox(height: 16),

            // Detection Findings
            if (_result != null) _buildResultView(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4A261).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bug_report_outlined, size: 48, color: Color(0xFFE76F51)),
              ),
              const SizedBox(height: 16),
              const Text(
                'AgroPest-12 Object Detector',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Trained on 12 agricultural pest classes. Detects multiple insects in one frame with bounding boxes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF72796F)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionCanvas() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final canvasWidth = constraints.maxWidth;
              final canvasHeight = canvasWidth * 0.75;

              return SizedBox(
                width: canvasWidth,
                height: canvasHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_imageBytes!, fit: BoxFit.fill),
                    if (_result != null && _result!.detections.isNotEmpty)
                      CustomPaint(
                        size: Size(canvasWidth, canvasHeight),
                        painter: BoundingBoxPainter(
                          detections: _result!.detections,
                          imageOriginalSize: const Size(416, 416),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _fileName ?? 'Pest Image',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 16),
                  label: const Text('Change Image', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(PestPredictionModel res) {
    final isHigh = res.infestationRisk == 'HIGH';
    final isMod = res.infestationRisk == 'MODERATE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isHigh ? AppTheme.riskHigh : (isMod ? AppTheme.warningModerate : AppTheme.healthOptimal))
                .withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isHigh ? AppTheme.riskHigh : (isMod ? AppTheme.warningModerate : AppTheme.healthOptimal))
                  .withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'INFESTATION RISK: ${AppConstants.cleanLabel(res.infestationRisk)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isHigh ? AppTheme.riskHigh : (isMod ? AppTheme.warningModerate : AppTheme.healthOptimal),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${res.pestCount} Detected',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                res.primaryPest != null ? 'Primary Pest: ${AppConstants.cleanLabel(res.primaryPest)}' : 'No Pest Detected',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(res.explanation, style: const TextStyle(fontSize: 13, color: Color(0xFF434940))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Multi-Factor Outbreak Cause Breakdown (Climate, Soil, Humidity, Social Surroundings)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5EAE5)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Color(0xFFD97706), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'MULTI-FACTOR PEST OUTBREAK CAUSES',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF141F17),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildPestCauseTile(
                title: 'Climate & Weather Trigger',
                details: 'High daytime heat (32-34°C) with dry sunny periods rapidly accelerated insect reproduction cycles.',
                icon: Icons.wb_sunny_rounded,
                color: const Color(0xFFD97706),
                bg: const Color(0xFFFFFBEB),
              ),
              const SizedBox(height: 8),
              _buildPestCauseTile(
                title: 'Soil Chemistry & NPK Ratio',
                details: 'Excessive Nitrogen fertilizer application produced tender succulent shoots, attracting chewing/sucking pests.',
                icon: Icons.science_rounded,
                color: const Color(0xFF059669),
                bg: const Color(0xFFECFDF5),
              ),
              const SizedBox(height: 8),
              _buildPestCauseTile(
                title: 'Air Humidity & Canopy Aeration',
                details: 'Dense, unpruned crop canopy created a sheltered microclimate protecting eggs and larvae from wind and sun.',
                icon: Icons.cloud_queue_rounded,
                color: const Color(0xFF0284C7),
                bg: const Color(0xFFF0F9FF),
              ),
              const SizedBox(height: 8),
              _buildPestCauseTile(
                title: 'Social & Surrounding Cultivation',
                details: 'Adjacent weed borders and neighboring host vegetable plots within 150m acted as pest breeding reservoirs.',
                icon: Icons.nature_people_rounded,
                color: const Color(0xFF7C3AED),
                bg: const Color(0xFFFAF5FF),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Detection Box Details
        if (res.detections.isNotEmpty) ...[
          const Text(
            'DETECTION BREAKDOWN',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF72796F)),
          ),
          const SizedBox(height: 8),
          ...res.detections.map((det) => Card(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.bug_report, color: Color(0xFFE76F51)),
                  title: Text(AppConstants.cleanLabel(det.className), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Coordinates: [${det.bbox.map((e) => e.toStringAsFixed(0)).join(', ')}]'),
                  trailing: Text(
                    '${(det.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                  ),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildPestCauseTile({
    required String title,
    required String details,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: const Color(0xFF2C3E33),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
