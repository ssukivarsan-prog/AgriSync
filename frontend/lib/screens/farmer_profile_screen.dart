import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/farmer_profile.dart';
import '../core/theme.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _farmNameController;
  late double _farmSize;

  late String _language;
  late String _experience;
  late String _soilType;
  late String _irrigation;
  late String _waterAvail;
  late String _prevCrop;
  late String _season;

  final List<String> _languages = ['English', 'Hindi', 'Marathi', 'Telugu', 'Tamil', 'Kannada'];
  final List<String> _experiences = ['1-3 Years', '5-10 Years', '10+ Years (Experienced)'];
  final List<String> _soilTypes = ['Loamy', 'Sandy Loam', 'Clay Loam', 'Black Soil', 'Red Soil'];
  final List<String> _irrigationTypes = ['Drip Irrigation', 'Canal / Furrow', 'Sprinkler', 'Rainfed'];
  final List<String> _waterTypes = ['Ample (Borewell)', 'Moderate', 'Scarce / Seasonal'];
  final List<String> _prevCrops = ['Groundnut', 'Rice', 'Maize', 'Cotton', 'Sugarcane', 'Fallow'];
  final List<String> _seasons = ['Kharif', 'Rabi', 'Zaid'];

  @override
  void initState() {
    super.initState();
    final f = context.read<FarmProvider>().farmer;
    _nameController = TextEditingController(text: f.name);
    _locationController = TextEditingController(text: f.location);
    _farmNameController = TextEditingController(text: f.farmName);
    _farmSize = f.farmSizeAcres;
    _language = f.preferredLanguage;
    _experience = f.farmingExperience;
    _soilType = f.soilType;
    _irrigation = f.irrigationAvailability;
    _waterAvail = f.waterAvailability;
    _prevCrop = f.previousCrop;
    _season = f.currentSeason;
  }

  void _saveProfile() {
    final updated = FarmerProfile(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Farmer",
      location: _locationController.text.trim(),
      preferredLanguage: _language,
      farmingExperience: _experience,
      farmName: _farmNameController.text.trim().isNotEmpty ? _farmNameController.text.trim() : "My Farm",
      farmSizeAcres: _farmSize,
      soilType: _soilType,
      irrigationAvailability: _irrigation,
      waterAvailability: _waterAvail,
      previousCrop: _prevCrop,
      currentSeason: _season,
    );

    context.read<FarmProvider>().updateFarmerProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Farmer profile & farm parameters updated successfully!'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          'Farmer & Farm Profile',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'SAVE',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Farmer Details
            Text(
              '1. FARMER INFORMATION',
              style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF4B5E52)),
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
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location / District',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _languages.contains(_language) ? _language : _languages[0],
                    decoration: const InputDecoration(
                      labelText: 'Preferred Language',
                      prefixIcon: Icon(Icons.language_rounded),
                    ),
                    items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                    onChanged: (v) => setState(() => _language = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _experiences.contains(_experience) ? _experience : _experiences[1],
                    decoration: const InputDecoration(
                      labelText: 'Farming Experience',
                      prefixIcon: Icon(Icons.workspace_premium_outlined),
                    ),
                    items: _experiences.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _experience = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Farm & Soil Parameters
            Text(
              '2. FARM & SOIL PARAMETERS',
              style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: const Color(0xFF4B5E52)),
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
                    controller: _farmNameController,
                    decoration: const InputDecoration(
                      labelText: 'Farm Name',
                      prefixIcon: Icon(Icons.landscape_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Farm Size:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${_farmSize.toStringAsFixed(1)} Acres',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    ],
                  ),
                  Slider(
                    value: _farmSize,
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (v) => setState(() => _farmSize = v),
                  ),
                  const Divider(height: 20),

                  DropdownButtonFormField<String>(
                    value: _soilTypes.contains(_soilType) ? _soilType : _soilTypes[0],
                    decoration: const InputDecoration(
                      labelText: 'Soil Type',
                      prefixIcon: Icon(Icons.terrain_rounded),
                    ),
                    items: _soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _soilType = v!),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _irrigationTypes.contains(_irrigation) ? _irrigation : _irrigationTypes[0],
                    decoration: const InputDecoration(
                      labelText: 'Irrigation Setup',
                      prefixIcon: Icon(Icons.water_drop_outlined),
                    ),
                    items: _irrigationTypes.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                    onChanged: (v) => setState(() => _irrigation = v!),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _waterTypes.contains(_waterAvail) ? _waterAvail : _waterTypes[0],
                    decoration: const InputDecoration(
                      labelText: 'Water Availability',
                      prefixIcon: Icon(Icons.opacity_rounded),
                    ),
                    items: _waterTypes.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                    onChanged: (v) => setState(() => _waterAvail = v!),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _prevCrops.contains(_prevCrop) ? _prevCrop : _prevCrops[0],
                    decoration: const InputDecoration(
                      labelText: 'Previous Cultivated Crop',
                      prefixIcon: Icon(Icons.history_rounded),
                    ),
                    items: _prevCrops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _prevCrop = v!),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _seasons.contains(_season) ? _season : _seasons[0],
                    decoration: const InputDecoration(
                      labelText: 'Current Agricultural Season',
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                    items: _seasons.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _season = v!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save & Update Farm Context', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
