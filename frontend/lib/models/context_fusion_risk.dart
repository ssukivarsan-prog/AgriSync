class ContextFusionAssessment {
  final String cvObservation;
  final double cvConfidencePct;
  final String observedPestSummary;
  final String fieldTelemetrySummary;
  final String weatherContextSummary;
  final String finalRiskTitle; // e.g. "Elevated Disease Risk"
  final String severity; // "LOW", "MODERATE", "ELEVATED", "CRITICAL"
  final String scientificExplanation;
  final String immediateAction;
  final List<String> preventativeSteps;
  final List<String> relevantEducationTopics;
  final String timestamp;
  final bool isVideo;
  final String? videoAnalysisSummary;
  final String? tamilDiagnosisName;
  final String? tnauTreatmentProtocol;
  final String? districtLocation;

  // Dedicated Tamil Localization Fields
  final String? tamilRiskTitle;
  final String? tamilSeverity;
  final String? tamilScientificExplanation;
  final String? tamilImmediateAction;
  final String? tamilTnauTreatmentProtocol;
  final List<String>? tamilPreventativeSteps;
  final String? tamilObservedPestSummary;
  final String? tamilFieldTelemetrySummary;
  final String? tamilWeatherContextSummary;
  final List<String>? tamilRelevantEducationTopics;

  ContextFusionAssessment({
    required this.cvObservation,
    required this.cvConfidencePct,
    required this.observedPestSummary,
    required this.fieldTelemetrySummary,
    required this.weatherContextSummary,
    required this.finalRiskTitle,
    required this.severity,
    required this.scientificExplanation,
    required this.immediateAction,
    required this.preventativeSteps,
    required this.relevantEducationTopics,
    required this.timestamp,
    this.isVideo = false,
    this.videoAnalysisSummary,
    this.tamilDiagnosisName,
    this.tnauTreatmentProtocol,
    this.districtLocation,
    this.tamilRiskTitle,
    this.tamilSeverity,
    this.tamilScientificExplanation,
    this.tamilImmediateAction,
    this.tamilTnauTreatmentProtocol,
    this.tamilPreventativeSteps,
    this.tamilObservedPestSummary,
    this.tamilFieldTelemetrySummary,
    this.tamilWeatherContextSummary,
    this.tamilRelevantEducationTopics,
  });

  String? get videoMotionSummary => videoAnalysisSummary;
  String get overallRiskTitle => finalRiskTitle;

  String getRiskTitle(bool isTamil) =>
      (isTamil && tamilRiskTitle != null && tamilRiskTitle!.isNotEmpty) ? tamilRiskTitle! : finalRiskTitle;

  String getSeverity(bool isTamil) =>
      (isTamil && tamilSeverity != null && tamilSeverity!.isNotEmpty) ? tamilSeverity! : severity;

  String getExplanation(bool isTamil) =>
      (isTamil && tamilScientificExplanation != null && tamilScientificExplanation!.isNotEmpty)
          ? tamilScientificExplanation!
          : scientificExplanation;

  String getImmediateAction(bool isTamil) =>
      (isTamil && tamilImmediateAction != null && tamilImmediateAction!.isNotEmpty)
          ? tamilImmediateAction!
          : immediateAction;

  List<String> getPreventativeSteps(bool isTamil) =>
      (isTamil && tamilPreventativeSteps != null && tamilPreventativeSteps!.isNotEmpty)
          ? tamilPreventativeSteps!
          : preventativeSteps;

  String getPestSummary(bool isTamil) =>
      (isTamil && tamilObservedPestSummary != null && tamilObservedPestSummary!.isNotEmpty)
          ? tamilObservedPestSummary!
          : observedPestSummary;

  String getTelemetrySummary(bool isTamil) =>
      (isTamil && tamilFieldTelemetrySummary != null && tamilFieldTelemetrySummary!.isNotEmpty)
          ? tamilFieldTelemetrySummary!
          : fieldTelemetrySummary;

  String? getTnauProtocol(bool isTamil) =>
      (isTamil && tamilTnauTreatmentProtocol != null && tamilTnauTreatmentProtocol!.isNotEmpty)
          ? tamilTnauTreatmentProtocol
          : tnauTreatmentProtocol;

  String getWeatherSummary(bool isTamil) =>
      (isTamil && tamilWeatherContextSummary != null && tamilWeatherContextSummary!.isNotEmpty)
          ? tamilWeatherContextSummary!
          : weatherContextSummary;
}
