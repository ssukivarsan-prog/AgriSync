import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/app_localization.dart';
import 'providers/farm_provider.dart';

// Screens
import 'screens/home_dashboard_screen.dart';
import 'screens/field_monitoring_screen.dart';
import 'screens/crop_diagnosis_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/education_portal_screen.dart';
import 'screens/crop_recommendation_screen.dart';
import 'screens/crop_quotation_screen.dart';
import 'screens/farmer_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/quick_demo_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/ai_scan_screen.dart';
import 'screens/pest_detection_screen.dart';
import 'screens/nutrient_analysis_screen.dart';
import 'screens/irrigation_screen.dart';
import 'screens/environment_screen.dart';
import 'screens/farm_analytics_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/model_info_screen.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
  runApp(const AgriSyncApp());
}

class AgriSyncApp extends StatelessWidget {
  const AgriSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FarmProvider()..initialize()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/profile': (_) => const FarmerProfileScreen(),
          '/quotation': (_) => const CropQuotationScreen(),
          '/recommendation': (_) => const CropRecommendationScreen(),
          '/assistant': (_) => const AiAssistantScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboardScreen(onNavigate: _navigateTo), // 0: HOME
      const FieldMonitoringScreen(),                // 1: FIELD
      const CropDiagnosisScreen(),                  // 2: DIAGNOSE
      const InsightsScreen(),                       // 3: INSIGHTS
      const EducationPortalScreen(),                // 4: LEARN
      const CropRecommendationScreen(),             // 5: PREVENT (Crop Recommender)
      const CropQuotationScreen(),                  // 6: Financial Quotation
      const FarmerProfileScreen(),                  // 7: Profile
      const SettingsScreen(),                       // 8: Settings & Demo Mode
      const AiAssistantScreen(),                    // 9: AgriSync Assistant
      QuickDemoScreen(onNavigate: _navigateTo),     // 10: Interactive Tour
      const AIScanScreen(),                         // 11: Scan Leaf (Legacy CV)
      const PestDetectionScreen(),                  // 12: AgroPest (YOLOv8n)
      const IrrigationScreen(),                     // 13: Irrigation
      const NutrientAnalysisScreen(),               // 14: Nutrients
      const EnvironmentScreen(),                    // 15: Weather
      const FarmAnalyticsScreen(),                  // 16: Analytics
      const ScanHistoryScreen(),                    // 17: History
      const ModelInfoScreen(),                      // 18: Model Specs
    ];

    final isWide = MediaQuery.of(context).size.width >= 850;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex > 9 ? 0 : _currentIndex,
              onDestinationSelected: (val) => setState(() => _currentIndex = val),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/logo_128.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.eco, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: Text('HOME')),
                NavigationRailDestination(icon: Icon(Icons.sensors_outlined), selectedIcon: Icon(Icons.sensors_rounded), label: Text('FIELD')),
                NavigationRailDestination(icon: Icon(Icons.center_focus_strong_outlined), selectedIcon: Icon(Icons.center_focus_strong_rounded), label: Text('DIAGNOSE')),
                NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: Text('INSIGHTS')),
                NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: Text('LEARN')),
                NavigationRailDestination(icon: Icon(Icons.grass_outlined), selectedIcon: Icon(Icons.grass_rounded), label: Text('CROPS')),
                NavigationRailDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate_rounded), label: Text('QUOTATION')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: Text('PROFILE')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: Text('SETTINGS')),
                NavigationRailDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy_rounded), label: Text('ASSISTANT')),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: screens[_currentIndex.clamp(0, screens.length - 1)]),
          ],
        ),
      );
    }

    // Mobile layout with the exact required 5 bottom navigation destinations:
    // HOME, FIELD, DIAGNOSE, INSIGHTS, LEARN
    final activeBottomIndex = _currentIndex > 4 ? 0 : _currentIndex;

    final provider = context.watch<FarmProvider>();
    final isTamil = provider.isTamil;

    return Scaffold(
      body: screens[_currentIndex.clamp(0, screens.length - 1)],
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CropQuotationScreen()),
                );
              },
              backgroundColor: const Color(0xFF059669),
              elevation: 4,
              icon: const Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
              label: Text(
                isTamil ? 'பயிர் நிதி மதிப்பீடு' : 'Financial Quotation',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFEEF3EE), width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          height: 66,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD1FAE5),
          selectedIndex: activeBottomIndex,
          onDestinationSelected: (val) {
            setState(() => _currentIndex = val);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded, color: AppTheme.primaryGreen),
              label: isTamil ? 'முகப்பு' : 'HOME',
            ),
            NavigationDestination(
              icon: const Icon(Icons.sensors_outlined),
              selectedIcon: const Icon(Icons.sensors_rounded, color: AppTheme.primaryGreen),
              label: isTamil ? 'வயல்' : 'FIELD',
            ),
            NavigationDestination(
              icon: const Icon(Icons.center_focus_strong_outlined),
              selectedIcon: const Icon(Icons.center_focus_strong_rounded, color: AppTheme.primaryGreen),
              label: isTamil ? 'ஸ்கேன்' : 'DIAGNOSE',
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights_rounded, color: AppTheme.primaryGreen),
              label: isTamil ? 'பகுப்பாய்வு' : 'INSIGHTS',
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryGreen),
              label: isTamil ? 'கற்க' : 'LEARN',
            ),
          ],
        ),
      ),
    );
  }
}
