class CropRecommendationItem {
  final String cropName;
  final String suitabilityTier; // "High Suitability", "Good Suitability", "Moderate Suitability"
  final int modelSuitabilityScore; // e.g. 94, 86, 75
  final String soilSuitability;
  final String waterRequirement; // e.g. "450 - 550 mm", "Low - Moderate"
  final String weatherSuitability;
  final String riskLevel; // "Low Risk", "Moderate Risk", "High Risk"
  final List<String> reasonsWhy; // "✓ Suitable soil pH", etc.
  final String seasonFit;
  final String estimatedYield;
  final String durationDays;
  final String? hardwareTinyMlNote;

  CropRecommendationItem({
    required this.cropName,
    required this.suitabilityTier,
    required this.modelSuitabilityScore,
    required this.soilSuitability,
    required this.waterRequirement,
    required this.weatherSuitability,
    required this.riskLevel,
    required this.reasonsWhy,
    required this.seasonFit,
    required this.estimatedYield,
    required this.durationDays,
    this.hardwareTinyMlNote,
  });
}

class CroppingPatternRecommendation {
  final String currentCrop;
  final String previousCrop;
  final String recommendedNextCrop;
  final String rotationSequence; // e.g. "Rice → Chickpea / Green Gram (Legume)"
  final String agronomicJustification;
  final String biologicalContext;
  final List<String> managementConsiderations;

  CroppingPatternRecommendation({
    required this.currentCrop,
    required this.previousCrop,
    required this.recommendedNextCrop,
    required this.rotationSequence,
    required this.agronomicJustification,
    required this.biologicalContext,
    required this.managementConsiderations,
  });
}
