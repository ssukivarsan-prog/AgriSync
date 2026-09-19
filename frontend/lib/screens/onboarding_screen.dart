import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/farmer_profile.dart';
import '../core/theme.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isFromSettings;

  const OnboardingScreen({super.key, this.isFromSettings = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Farmer
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  String _language = 'English';
  String _experience = '5-10 Years';

  // Step 2: Farm
  late TextEditingController _farmNameController;
  double _farmSize = 8.5;
  String _soilType = 'Loamy';
  String _irrigation = 'Drip Irrigation';
  String _waterAvail = 'Moderate';
  String _prevCrop = 'Groundnut';
  String _season = 'Kharif';

  final List<String> _languages = ['English', 'Hindi', 'Marathi', 'Telugu', 'Tamil', 'Kannada'];
  final List<String> _experiences = ['< 3 Years', '3-5 Years', '5-10 Years', '10+ Years'];
  final List<String> _soilTypes = ['Loamy', 'Sandy Loam', 'Clay Loam', 'Black Soil', 'Red Soil'];
  final List<String> _irrigationTypes = ['Drip Irrigation', 'Canal / Furrow', 'Sprinkler', 'Rainfed'];
  final List<String> _waterTypes = ['Ample (Borewell)', 'Moderate', 'Scarce / Seasonal'];
  final List<String> _prevCrops = ['Groundnut', 'Rice', 'Maize', 'Cotton', 'Sugarcane', 'Fallow'];
  final List<String> _seasons = ['Kharif (Monsoon)', 'Rabi (Winter)', 'Zaid (Summer)'];

  @override
  void initState() {
    super.initState();
    final f = context.read<FarmProvider>().farmer;
    _nameController = TextEditingController(text: f.name);
    _locationController = TextEditingController(text: f.location);
    _farmNameController = TextEditingController(text: f.farmName);
    _farmSize = f.farmSizeAcres;
    _language = f.preferredLanguage;
    _soilType = f.soilType;
    _irrigation = f.irrigationAvailability;
    _prevCrop = f.previousCrop;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _farmNameController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    final updated = FarmerProfile(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Ramesh Patil",
      location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : "Pune District, Maharashtra",
      preferredLanguage: _language,
      farmingExperience: _experience,
      farmName: _farmNameController.text.trim().isNotEmpty ? _farmNameController.text.trim() : "Green Valley Farm",
      farmSizeAcres: _farmSize,
      soilType: _soilType,
      irrigationAvailability: _irrigation,
      waterAvailability: _waterAvail,
      previousCrop: _prevCrop,
      currentSeason: _season.split(' ')[0],
    );

    context.read<FarmProvider>().updateFarmerProfile(updated);

    if (widget.isFromSettings) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
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
        leading: widget.isFromSettings
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.primaryDark),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo_128.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 24),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AgriSync Onboarding',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.isFromSettings)
            TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Skip to Demo',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _currentStep == 0 ? 'Step 1 of 2: Farmer Profile' : 'Step 2 of 2: Farm & Soil Conditions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / 2 * 100).toInt()}% Complete',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Form Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                children: [
                  _buildFarmerStep(),
                  _buildFarmStep(),
                ],
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF374151)),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep == 0) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 0 ? 'Next: Farm Setup' : 'Save & Enter AgriSync',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentStep == 0 ? Icons.arrow_forward_rounded : Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell Us About Yourself',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 4),
          Text(
            'This enables localized agronomic advisories and weather warnings.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF5A6E61)),
          ),
          const SizedBox(height: 20),

          // Name
          _buildTextField(
            label: 'Farmer Full Name',
            hint: 'e.g. Ramesh Patil',
            controller: _nameController,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),

          // Location
          _buildTextField(
            label: 'Location / District',
            hint: 'e.g. Pune District, Maharashtra',
            controller: _locationController,
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 18),

          // Preferred Language
          Text(
            'Preferred Language',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languages.map((lang) {
              final isSel = _language == lang;
              return ChoiceChip(
                label: Text(lang),
                selected: isSel,
                onSelected: (val) => setState(() => _language = lang),
                selectedColor: const Color(0xFFD1FAE5),
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? const Color(0xFF065F46) : const Color(0xFF4B5E52),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isSel ? AppTheme.primaryGreen : const Color(0xFFE5E7EB)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Farming Experience
          Text(
            'Farming Experience',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _experiences.map((exp) {
              final isSel = _experience == exp;
              return ChoiceChip(
                label: Text(exp),
                selected: isSel,
                onSelected: (val) => setState(() => _experience = exp),
                selectedColor: const Color(0xFFD1FAE5),
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? const Color(0xFF065F46) : const Color(0xFF4B5E52),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isSel ? AppTheme.primaryGreen : const Color(0xFFE5E7EB)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm & Agronomic Context',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 4),
          Text(
            'Used by the Random Forest Crop Recommender and IoT Field Engine.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: const Color(0xFF5A6E61)),
          ),
          const SizedBox(height: 18),

          // Farm Name
          _buildTextField(
            label: 'Farm / Holding Name',
            hint: 'e.g. Green Valley Farm',
            controller: _farmNameController,
            icon: Icons.landscape_rounded,
          ),
          const SizedBox(height: 16),

          // Farm Size Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Farm Size (Acres)',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_farmSize.toStringAsFixed(1)} Acres',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
              ),
            ],
          ),
          Slider(
            value: _farmSize,
            min: 0.5,
            max: 50.0,
            divisions: 99,
            activeColor: AppTheme.primaryGreen,
            onChanged: (val) => setState(() => _farmSize = val),
          ),
          const SizedBox(height: 12),

          // Soil Type
          Text(
            'Primary Soil Type',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _soilType,
            decoration: _inputDecoration(icon: Icons.layers_rounded),
            items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _soilType = val ?? _soilType),
          ),
          const SizedBox(height: 16),

          // Irrigation Availability
          Text(
            'Irrigation Infrastructure',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _irrigation,
            decoration: _inputDecoration(icon: Icons.water_drop_rounded),
            items: _irrigationTypes.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: (val) => setState(() => _irrigation = val ?? _irrigation),
          ),
          const SizedBox(height: 16),

          // Water Availability
          Text(
            'Water Availability Level',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _waterAvail,
            decoration: _inputDecoration(icon: Icons.opacity_rounded),
            items: _waterTypes.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
            onChanged: (val) => setState(() => _waterAvail = val ?? _waterAvail),
          ),
          const SizedBox(height: 16),

          // Previous Crop
          Text(
            'Previous Crop Harvested',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _prevCrop,
            decoration: _inputDecoration(icon: Icons.history_rounded),
            items: _prevCrops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => _prevCrop = val ?? _prevCrop),
          ),
          const SizedBox(height: 16),

          // Current Season
          Text(
            'Current Cultivation Season',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _seasons.firstWhere((s) => s.startsWith(_season), orElse: () => _seasons.first),
            decoration: _inputDecoration(icon: Icons.calendar_today_rounded),
            items: _seasons.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _season = (val ?? 'Kharif').split(' ')[0]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hint: hint, icon: icon),
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5, color: const Color(0xFF141F17)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
      ),
    );
  }
}
