import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/scan_result.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class NutrientAnalysisScreen extends StatefulWidget {
  const NutrientAnalysisScreen({super.key});

  @override
  State<NutrientAnalysisScreen> createState() => _NutrientAnalysisScreenState();
}

class _NutrientAnalysisScreenState extends State<NutrientAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _fileName;
  NutrientPredictionModel? _result;
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
    final res = await provider.executeNutrientAnalysis(_imageBytes!, _fileName!);

    if (!mounted) return;

    setState(() {
      _result = res;
      _isLoading = false;
    });

    if (res == null) {
      final err = provider.errorMessage ?? 'Could not connect to AI backend for nutrient analysis.';
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
        title: const Text('Nutrient Stress Analysis'),
        actions: [
          if (_imageBytes != null)
            IconButton(
              icon: const Icon(Icons.refresh),
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
            if (_imageBytes == null)
              _buildUploadBox()
            else
              _buildImageCard(),

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
                      : const Icon(Icons.spa_outlined),
                  label: Text(_isLoading ? 'Analyzing Foliage with EarlyNSD...' : 'Analyze Nutrient Stress'),
                ),
              ),

            const SizedBox(height: 16),

            if (_result != null) _buildResultCard(_result!),
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
                  color: AppTheme.lightSage,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_outlined, size: 48, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 16),
              const Text(
                'Early Nutrient Stress Detection (EarlyNSD)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Detects Nitrogen and Potassium deficiencies at early stages before permanent foliar chlorosis sets in.',
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

  Widget _buildImageCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.memory(_imageBytes!, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _fileName ?? 'Leaf Image',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.cached, size: 16),
                  label: const Text('Change', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(NutrientPredictionModel res) {
    final isDeficient = !res.deficiency.toLowerCase().contains('healthy') &&
        !res.deficiency.toLowerCase().contains('optimal');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDeficient ? AppTheme.warningModerate : AppTheme.healthOptimal).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDeficient ? AppTheme.warningModerate : AppTheme.healthOptimal).withOpacity(0.3),
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
                      AppConstants.cleanLabel(res.deficiency).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDeficient ? AppTheme.warningModerate : AppTheme.healthOptimal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${(res.confidence * 100).toStringAsFixed(1)}% Confidence',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${AppConstants.cleanLabel(res.crop)} Foliage Analysis', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(res.visualIndication, style: const TextStyle(fontSize: 13, color: Color(0xFF434940))),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.science_outlined, color: AppTheme.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'RECOMMENDED VERIFICATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF72796F)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(res.verificationRecommendation, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.checklist, color: AppTheme.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'NEXT AGRONOMIC ACTION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF72796F)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(res.nextAction, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
