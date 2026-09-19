class AppConstants {
  static const String appName = 'AgriSync';
  static const String appTagline =
      'AI-powered intelligence for healthier, smarter and more resilient farms.';
  static const String problemStatementId = 'AgriSync Smart Farming AI';

  // Base API URL - defaults to ADB Reverse localhost & active Wi-Fi IP
  static const String defaultBaseUrl = 'http://127.0.0.1:8000/api';
  static const String currentWifiBaseUrl = 'http://10.75.225.33:8000/api';
  static const String emulatorBaseUrl = 'http://10.0.2.2:8000/api';

  static String cleanLabel(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .replaceAll('___', ' - ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const List<String> supportedCrops = [
    'Tomato',
    'Potato',
    'Corn (Maize)',
    'Bell Pepper',
    'Grape',
    'Apple',
    'Peach',
    'Strawberry',
    'Sugarcane',
    'Ashgourd',
    'Bittergourd',
    'Snakegourd'
  ];

  static const List<String> growthStages = [
    'Vegetative',
    'Flowering',
    'Fruiting',
    'Tuber Formation',
    'Tasseling/Silking',
    'Maturity'
  ];

  static const List<String> soilTypes = [
    'Loamy',
    'Sandy',
    'Sandy Loam',
    'Clay',
    'Clay Loam',
    'Silt'
  ];
}
