import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/scan_result.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../widgets/bounding_box_painter.dart';
import 'education_portal_screen.dart';

class AIScanScreen extends StatefulWidget {
  const AIScanScreen({super.key});

  @override
  State<AIScanScreen> createState() => _AIScanScreenState();
}

class _AIScanScreenState extends State<AIScanScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  UnifiedScanResultModel? _result;
  bool _isAnalyzing = false;
  bool _isVideo = false;
  String? _videoName;

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
          _isVideo = false;
          _videoName = null;
          _selectedImageBytes = bytes;
          _selectedFileName = file.name;
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

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );
      if (video != null) {
        final bytes = await video.readAsBytes();
        if (!mounted) return;
        setState(() {
          _isVideo = true;
          _videoName = video.name;
          _selectedImageBytes = bytes.isNotEmpty ? bytes.sublist(0, bytes.length > 300000 ? 300000 : bytes.length) : Uint8List(0);
          _selectedFileName = video.name;
          _result = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting video: $e')),
      );
    }
  }

  Future<void> _loadSample(String filename) async {
    try {
      final byteData = await rootBundle.load('assets/samples/$filename');
      final bytes = byteData.buffer.asUint8List();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = filename;
        _isVideo = false;
        _videoName = null;
        _result = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load sample: $e')),
      );
    }
  }

  Future<void> _runScan() async {
    if (_selectedImageBytes == null || _selectedFileName == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    final provider = context.read<FarmProvider>();
    final fieldId = provider.selectedField?.id ?? 1;

    final res = await provider.executeUnifiedScan(
      _selectedImageBytes!,
      _selectedFileName!,
      fieldId,
    );

    if (!mounted) return;

    setState(() {
      _result = res;
      _isAnalyzing = false;
    });

    if (res == null) {
      final err = provider.errorMessage ?? 'Could not connect to AI backend. Check server connection.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppTheme.riskHigh,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _runScan,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'AI Crop Health Scan',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
        ),
        actions: [
          if (_selectedImageBytes != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF5A6E61)),
              tooltip: 'Clear Media',
              onPressed: () {
                setState(() {
                  _selectedImageBytes = null;
                  _selectedFileName = null;
                  _isVideo = false;
                  _videoName = null;
                  _result = null;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tamil Nadu Location & Agro-Climatic Zone Badge
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tamil Nadu Location: ${context.watch<FarmProvider>().currentDistrict.name} (${context.watch<FarmProvider>().currentDistrict.tamilName}) • ${context.watch<FarmProvider>().currentDistrict.zoneName}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF065F46),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Upload / Capture Card
            if (_selectedImageBytes == null)
              _buildUploadPlaceholder()
            else if (_isVideo)
              _buildVideoPreview()
            else
              _buildImagePreview(),

            const SizedBox(height: 16),

            if (_selectedImageBytes != null && _result == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _runScan,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.analytics_rounded),
                  label: Text(_isAnalyzing ? 'Running AI Vision Models...' : 'Analyze Foliage with AgriSync AI'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Diagnostic Results
            if (_result != null) _buildDiagnosticReport(_result!),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD1E0D4), width: 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 40,
              color: Color(0xFF059669),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Capture or Select Leaf Photo',
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF141F17),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Take a clear, close-up photo of a single crop leaf in natural daylight for instant multi-model disease, pest & nutrient diagnosis.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF5A6E61),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Open Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('From Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickVideo(ImageSource.camera),
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: const Text('Record Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E22CE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickVideo(ImageSource.gallery),
                  icon: const Icon(Icons.video_library_rounded, size: 18),
                  label: const Text('Upload Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7E22CE),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.science_rounded, size: 16, color: AppTheme.primaryGreen),
              const SizedBox(width: 6),
              Text(
                'Quick Test with Calibrated AI Samples:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSampleChip('Early Blight', 'tomato_early_blight.jpg', const Color(0xFFEA580C)),
              _buildSampleChip('AgroPest (Ants)', 'pest_sample.jpg', const Color(0xFFDC2626)),
              _buildSampleChip('Nitrogen Stress', 'nutrient_nitrogen.jpg', const Color(0xFFD97706)),
              _buildSampleChip('Healthy Leaf', 'tomato_healthy.jpg', const Color(0xFF16A34A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSampleChip(String title, String filename, Color accentColor) {
    return InkWell(
      onTap: () => _loadSample(filename),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8B4FE), width: 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF7E22CE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.videocam_rounded, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Field Inspection Video Loaded',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 4),
          Text(
            _videoName ?? 'canopy_sweep.mp4',
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF7E22CE), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Temporal canopy sweep and underside leaf pest movement will be analyzed across extracted keyframes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF5A6E61)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5EAE5)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.memory(
                  _selectedImageBytes!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),
                if (_result?.pest?.detections.isNotEmpty ?? false)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BoundingBoxPainter(
                        detections: _result!.pest!.detections,
                        imageOriginalSize: const Size(416, 416),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFileName ?? 'Crop Leaf Sample',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF141F17),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${(_selectedImageBytes!.length / 1024).toStringAsFixed(0)} KB • Ready for AI Analysis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF5A6E61),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.primaryGreen),
                  label: const Text('Change', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticReport(UnifiedScanResultModel report) {
    final isAtRisk = report.overallHealth == 'AT_RISK';
    final isHealthy = report.overallHealth == 'HEALTHY';
    final disease = report.disease;

    final bannerBg = isAtRisk
        ? AppTheme.riskHighBg
        : (isHealthy ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB));
    final bannerBorder = isAtRisk
        ? AppTheme.riskHighSoft
        : (isHealthy ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A));
    final bannerColor = isAtRisk
        ? AppTheme.riskHigh
        : (isHealthy ? AppTheme.healthOptimal : const Color(0xFFD97706));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Overall Diagnosis Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bannerBorder, width: 1.5),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: bannerColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAtRisk
                                ? Icons.warning_rounded
                                : (isHealthy ? Icons.check_circle_rounded : Icons.help_outline_rounded),
                            color: bannerColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'CROP HEALTH: ${AppConstants.cleanLabel(report.overallHealth)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: bannerColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bannerBorder),
                    ),
                    child: Text(
                      AppConstants.cleanLabel(disease.confidenceTier),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: bannerColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppConstants.cleanLabel(disease.prediction),
                style: GoogleFonts.outfit(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF141F17),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.psychology_rounded, size: 15, color: Color(0xFF5A6E61)),
                  const SizedBox(width: 4),
                  Text(
                    'AI Diagnostic Confidence: ${(disease.confidence * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4B5E52),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EducationPortalScreen(
                          recommendedTopic: AppConstants.cleanLabel(disease.prediction),
                          cropName: AppConstants.cleanLabel(disease.crop),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.smart_display_rounded, size: 18),
                  label: const Text('🎥 Watch Video & Practical Farmer Guide'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Multi-Model Synthesis Grid (3 Cards)
        Row(
          children: [
            Expanded(
              child: _buildMiniReportCard(
                'PEST STATUS',
                AppConstants.cleanLabel(report.pest?.primaryPest ?? 'Zero Pests'),
                report.pest != null && report.pest!.pestCount > 0
                    ? '${report.pest!.pestCount} sightings'
                    : 'Clean Foliage',
                Icons.bug_report_rounded,
                report.pest != null && report.pest!.pestCount > 0 ? const Color(0xFFEA580C) : AppTheme.healthOptimal,
                const Color(0xFFFFF7ED),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniReportCard(
                'NUTRIENTS',
                AppConstants.cleanLabel(report.nutrient?.deficiency ?? 'Optimal'),
                report.nutrient != null ? '${(report.nutrient!.confidence * 100).toStringAsFixed(0)}% Conf.' : 'Balanced',
                Icons.spa_rounded,
                report.nutrient != null && !report.nutrient!.deficiency.contains('Healthy')
                    ? const Color(0xFFD97706)
                    : AppTheme.healthOptimal,
                const Color(0xFFECFDF5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniReportCard(
                'LESION AREA',
                report.segmentation != null && report.segmentation!.affectedAreaPercentage > 0
                    ? '${report.segmentation!.affectedAreaPercentage}%'
                    : '0.0%',
                AppConstants.cleanLabel(report.segmentation?.severityCategory ?? 'None'),
                Icons.blur_on_rounded,
                AppTheme.waterCyan,
                const Color(0xFFF0F9FF),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. Multi-Factor Root Cause Analysis (Climate + Soil + Air Moisture + Social Context)
        if (report.rootCause != null) ...[
          Container(
            padding: const EdgeInsets.all(18),
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
                        const SizedBox(width: 10),
                        Text(
                          'MULTI-FACTOR ROOT CAUSE ANALYSIS',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF141F17),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pillar 1: Climate & Weather
                _buildPillarTile(
                  title: 'Climate & Weather Trigger',
                  details: report.rootCause!.climateWeather,
                  icon: Icons.wb_sunny_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                ),
                const SizedBox(height: 8),

                // Pillar 2: Soil Metrics & NPK/pH
                _buildPillarTile(
                  title: 'Soil Chemistry & NPK / pH',
                  details: report.rootCause!.soilMetrics,
                  icon: Icons.science_rounded,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                ),
                const SizedBox(height: 8),

                // Pillar 3: Air Moisture & Foliar Wetness
                _buildPillarTile(
                  title: 'Canopy Air Moisture & Humidity',
                  details: report.rootCause!.airMoistureHumidity,
                  icon: Icons.cloud_queue_rounded,
                  color: const Color(0xFF0284C7),
                  bg: const Color(0xFFF0F9FF),
                ),
                const SizedBox(height: 8),

                // Pillar 4: Social & Surrounding Cultivation
                _buildPillarTile(
                  title: 'Surrounding Fields & Social Context',
                  details: report.rootCause!.socialSurroundings,
                  icon: Icons.nature_people_rounded,
                  color: const Color(0xFF7C3AED),
                  bg: const Color(0xFFFAF5FF),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 4. Recommended Farmer Action Plan
        Container(
          padding: const EdgeInsets.all(18),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.checklist_rounded, color: AppTheme.primaryGreen, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PRACTICAL FARMER ACTION PLAN',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF141F17),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                disease.recommendation,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: const Color(0xFF2C3E33),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillarTile({
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
            decoration: BoxDecoration(
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

  Widget _buildMiniReportCard(String title, String mainVal, String subVal, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            mainVal,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF141F17),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subVal,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
