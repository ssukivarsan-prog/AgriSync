import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';
import '../widgets/language_toggle_chip.dart';
import '../services/location_service.dart';
import '../services/firestore_service.dart';
import '../main.dart';

class FarmerQuickEntryScreen extends StatefulWidget {
  const FarmerQuickEntryScreen({super.key});

  @override
  State<FarmerQuickEntryScreen> createState() => _FarmerQuickEntryScreenState();
}

class _FarmerQuickEntryScreenState extends State<FarmerQuickEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _locationController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool _isDetectingGps = false;

  final List<String> _quickDistrictsEn = [
    'Thanjavur, Tamil Nadu',
    'Thiruvarur, Tamil Nadu',
    'Nagapattinam, Tamil Nadu',
    'Melattur, Thanjavur',
    'Coimbatore, Tamil Nadu',
  ];

  final List<String> _quickDistrictsTa = [
    'தஞ்சாவூர், தமிழ்நாடு',
    'திருவாரூர், தமிழ்நாடு',
    'நாகப்பட்டினம், தமிழ்நாடு',
    'மேலட்டூர், தஞ்சாவூர்',
    'கோயம்புத்தூர், தமிழ்நாடு',
  ];

  @override
  void initState() {
    super.initState();
    final f = context.read<FarmProvider>().farmer;
    _locationController = TextEditingController(text: f.location.isNotEmpty ? f.location : "Thanjavur, Tamil Nadu");
    _nameController = TextEditingController(text: f.name.isNotEmpty ? f.name : "Murugan Selvam");
    _phoneController = TextEditingController(text: f.phoneNumber.isNotEmpty ? f.phoneNumber : "+91 98421 78210");
  }

  @override
  void dispose() {
    _locationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _autoDetectLocation() async {
    final isTamil = context.read<FarmProvider>().isTamil;
    setState(() => _isDetectingGps = true);
    try {
      final profile = await LocationService.fetchCurrentLocation();
      final district = isTamil ? profile.tamilName : profile.name;
      setState(() {
        _locationController.text = "$district, ${isTamil ? 'தமிழ்நாடு' : 'Tamil Nadu'}";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  isTamil
                      ? 'இருப்பிடம் கண்டறியப்பட்டது: ${profile.tamilName}'
                      : 'Location mapped: ${profile.name}',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Location detection error: $e');
    } finally {
      if (mounted) {
        setState(() => _isDetectingGps = false);
      }
    }
  }

  void _proceedToFieldMap() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final phone = _phoneController.text.trim();

    final provider = context.read<FarmProvider>();
    final current = provider.farmer;

    // Determine district for agro-climatic zone tuning
    String district = "Thanjavur";
    for (final d in LocationService.tamilNaduDistricts) {
      if (location.toLowerCase().contains(d.name.toLowerCase()) ||
          location.toLowerCase().contains(d.tamilName.toLowerCase())) {
        district = d.name;
        break;
      }
    }

    final updated = current.copyWith(
      name: name,
      location: location,
      phoneNumber: phone,
      districtTamilNadu: district,
      agroClimaticZone: "$district Agro-Climatic Zone",
    );

    provider.updateFarmerProfile(updated);

    // Sync to Firestore in background
    FirestoreService.saveFarmerProfile(
      uid: "farmer_${phone.replaceAll(RegExp(r'[^0-9]'), '')}",
      profile: updated,
    );

    // Directly navigate to the Field Plot screen for zones with the virtual interactive map!
    // MainNavigationShell index 1 is FieldMonitoringScreen.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, anim, secAnim) => const MainNavigationShell(initialIndex: 1),
        transitionsBuilder: (context, animation, secAnim, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = context.watch<FarmProvider>().isTamil;
    final quickDistricts = isTamil ? _quickDistrictsTa : _quickDistrictsEn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              isTamil ? 'அக்ரிவின் பதிவு' : 'AgriVyn Farm Access',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: LanguageToggleChip(isCompact: true),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF065F46).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isTamil ? 'உடனடி பதிவு' : 'QUICK SETUP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.map_rounded, color: Colors.white70, size: 20),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isTamil ? 'உங்கள் பண்ணை & மண்டல அமைப்பு' : 'Map Your Farm & Virtual Zones',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTamil
                            ? 'உங்கள் நேரடி வயல் வரைபடம், பயிர் மண்டலங்கள் மற்றும் மண் ஈரப்பதம் சென்சார்களை தொடங்க கீழே உள்ள 3 விவரங்களை உள்ளிடவும்.'
                            : 'Enter your 3 details below to directly launch your live field plot with interactive root-zone sensors & virtual acre map.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // FIELD 1: LOCATION
                _buildFieldLabel(
                  title: isTamil ? '1. பண்ணை அமைவிடம் & மாவட்டம்' : '1. FARM LOCATION & DISTRICT',
                  icon: Icons.location_on_rounded,
                  color: const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? (isTamil ? 'தயவுசெய்து பண்ணை இருப்பிடத்தை உள்ளிடவும்' : 'Please enter your farm location')
                      : null,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                  decoration: InputDecoration(
                    hintText: isTamil ? 'உதா. தஞ்சாவூர், தமிழ்நாடு' : 'e.g. Thanjavur / Melattur, Tamil Nadu',
                    prefixIcon: const Icon(Icons.place_outlined, color: AppTheme.primaryGreen, size: 20),
                    suffixIcon: IconButton(
                      icon: _isDetectingGps
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                            )
                          : const Icon(Icons.my_location_rounded, color: AppTheme.primaryGreen),
                      tooltip: isTamil ? 'தற்போதைய இருப்பிடத்தை கண்டறி' : 'Auto-detect Location',
                      onPressed: _isDetectingGps ? null : _autoDetectLocation,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                    ),
                  ),
                ),

                // Quick location chips
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: quickDistricts.map((loc) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(
                            loc.split(',')[0],
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          onPressed: () {
                            setState(() => _locationController.text = loc);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // FIELD 2: FARMER NAME
                _buildFieldLabel(
                  title: isTamil ? '2. விவசாயி பெயர்' : '2. FARMER NAME',
                  icon: Icons.person_rounded,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? (isTamil ? 'தயவுசெய்து உங்கள் பெயரை உள்ளிடவும்' : 'Please enter your name')
                      : null,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                  decoration: InputDecoration(
                    hintText: isTamil ? 'உதா. முருகன் செல்வம்' : 'e.g. Murugan Selvam',
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF2563EB), size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // FIELD 3: MOBILE NUMBER
                _buildFieldLabel(
                  title: isTamil ? '3. அலைபேசி எண்' : '3. MOBILE NUMBER',
                  icon: Icons.phone_android_rounded,
                  color: const Color(0xFFD97706),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return isTamil ? 'தயவுசெய்து அலைபேசி எண்ணை உள்ளிடவும்' : 'Please enter your mobile number';
                    }
                    if (val.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                      return isTamil ? '10 இலக்க செல்லுபடியாகும் எண்ணை உள்ளிடவும்' : 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                  decoration: InputDecoration(
                    hintText: '+91 98421 78210',
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFFD97706), size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // PRIMARY ACTION BUTTON: DIRECTLY TO FIELD PLOT MAP
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _proceedToFieldMap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map_outlined, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          isTamil ? 'வயல் வரைபடத்தைத் தொடங்கு ➔' : 'Launch Field Plot & Virtual Map ➔',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    isTamil
                        ? 'நேரடி பயிர் பரப்பு, மண் ஈரப்பதம், நோய் கண்டறிதல் & பாசன மேலாண்மை'
                        : 'Direct access to Acre Plot, Root-Zone Sensors, Diagnostics & Irrigation',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({required String title, required IconData icon, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
