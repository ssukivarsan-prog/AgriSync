import '../models/farmer_profile.dart';
import '../models/field_zone.dart';
import '../models/context_fusion_risk.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}

class AiAssistantService {
  /// Generates a deeply context-aware response incorporating live field zone telemetry,
  /// current IMD weather data, recent diagnosis, and farmer profile.
  static String generateContextualResponse({
    required String query,
    required FarmerProfile farmer,
    required List<FieldZone> zones,
    required ImdWeatherData weather,
    required ContextFusionAssessment? latestAssessment,
  }) {
    final q = query.toLowerCase().trim();

    // Find zone with lowest moisture
    FieldZone driestZone = zones.first;
    for (var z in zones) {
      if (z.soilMoisturePct < driestZone.soilMoisturePct) {
        driestZone = z;
      }
    }

    // 1. "What should I sow?" / Crop choice
    if (q.contains('what should i sow') || q.contains('what to sow') || q.contains('recommend crop') || q.contains('which crop')) {
      final tinymlDecision = driestZone.tinymlEdgeDecision;
      return "According to the on-device TinyML decision from your hardware node (${driestZone.hardwareNodeLabel}: '$tinymlDecision'), your ${farmer.soilType} soil (pH ~6.8), and current ${farmer.currentSeason} season:\n\n"
          "1. 🌾 Paddy (Rice) / Maize: High suitability given your irrigation and regional Cauvery/Western corridor.\n"
          "2. 🥜 Groundnut (Legume): Prioritized by hardware TinyML if moisture deficit occurs or to naturally regenerate soil Nitrogen.\n\n"
          "You can visit the 'Crop Intelligence' section in the app to view the complete model suitability score breakdown.";
    }

    // 2. "Why is my crop under stress?" / "Why is soil moisture low?"
    if (q.contains('stress') || q.contains('moisture') || q.contains('water') || q.contains('dry')) {
      if (driestZone.soilMoisturePct < 30.0) {
        return "The TinyML model running locally on hardware ${driestZone.hardwareNodeLabel} has flagged '${driestZone.tinymlEdgeDecision}'.\n\n"
            "Root-zone soil moisture dropped to ${driestZone.soilMoisturePct.toStringAsFixed(1)}% "
            "(below the 32% threshold for flowering ${driestZone.crop}) while canopy temperature is ${driestZone.airTempC.toStringAsFixed(1)}°C with ${weather.humidityPct.toStringAsFixed(0)}% relative humidity. "
            "We recommend scheduling a 45-minute root-zone drip irrigation cycle for ${driestZone.name} before 10:00 AM.";
      } else {
        return "All field hardware nodes report nominal conditions (averaging ~${((zones[0].soilMoisturePct + zones[1].soilMoisturePct + zones[2].soilMoisturePct) / 3).toStringAsFixed(0)}% moisture). "
            "On-device TinyML status across all probes is 'Normal'. Continue routine morning monitoring.";
      }
    }

    // 3. "How can I reduce disease risk?" / Disease prevention
    if (q.contains('disease') || q.contains('fungal') || q.contains('blight') || q.contains('rot')) {
      if (latestAssessment != null && latestAssessment.severity != 'LOW') {
        return "Your latest visual scan indicated '${latestAssessment.cvObservation}' with ${latestAssessment.severity} risk.\n\n"
            "Key immediate steps:\n"
            "• Stop overhead sprinkler watering immediately to keep leaf surfaces dry.\n"
            "• Prune infected lower leaves and discard them outside the field.\n"
            "• Spray organic Neem Oil (5ml/L) or protective bio-fungicide during early morning hours.";
      } else {
        return "To prevent foliar diseases in ${farmer.farmName}:\n\n"
            "1. Water at the roots only using drip lines — avoid wetting upper foliage.\n"
            "2. Thin overcrowded leaves to ensure good sunlight penetration and air movement.\n"
            "3. Apply organic straw mulch to stop rainwater splashing soil-borne spores onto leaves.";
      }
    }

    // 4. "What should I do before heavy rain?" / Rain prep
    if (q.contains('rain') || q.contains('waterlog') || q.contains('flood') || q.contains('storm')) {
      return "According to current IMD weather intelligence (${weather.forecastSummary}):\n\n"
          "Before forecasted precipitation:\n"
          "1. Inspect and clear drainage channels and furrows, especially in low-lying zones (${zones.last.name}).\n"
          "2. Pause planned fertilizer or pesticide applications to avoid wash-off into groundwater.\n"
          "3. Ensure trellised crops (like Tomato or Pepper) are securely staked against wind gusts.";
    }

    // 5. "Pest" / Insects
    if (q.contains('pest') || q.contains('insect') || q.contains('bug')) {
      return "For sustainable pest management in ${farmer.farmName}:\n\n"
          "• Install 8-10 yellow sticky traps per acre to catch whiteflies, thrips, and aphids early.\n"
          "• Use cold-pressed Neem Oil spray (5ml + 1ml liquid soap per liter of water) every 7-10 days.\n"
          "• Keep field borders clean of wild nightshade weeds that harbor pest colonies.";
    }

    // Fallback contextual greeting & synthesis
    return "Hello ${farmer.name}! I am your AgriSync AI Field Assistant.\n\n"
        "Currently in ${farmer.farmName}:\n"
        "• ${driestZone.name} (${driestZone.hardwareNodeLabel}) TinyML Decision: ${driestZone.tinymlEdgeDecision} (Moisture: ${driestZone.soilMoisturePct.toStringAsFixed(0)}%).\n"
        "• IMD reports ${weather.temperatureC.toStringAsFixed(1)}°C, ${weather.humidityPct.toStringAsFixed(0)}% humidity.\n\n"
        "How can I help you today? You can ask me about crop choice, irrigation, pest control, or weather prep!";
  }
}
