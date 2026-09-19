from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field

class PredictionItem(BaseModel):
    label: str
    confidence: float
    crop: Optional[str] = None
    condition: Optional[str] = None

class DetectionBox(BaseModel):
    class_name: str
    confidence: float
    bbox: List[float] = Field(..., description="[x1, y1, x2, y2] normalized or pixel coords")

class DiseasePrediction(BaseModel):
    crop: str
    prediction: str
    confidence: float
    health_status: str  # HEALTHY, AT_RISK, UNCERTAIN
    confidence_tier: str # HIGH CONFIDENCE, MODERATE CONFIDENCE, UNCERTAIN
    top_predictions: List[PredictionItem] = []
    recommendation: str
    model_version: str = "1.0.0"
    is_uncertain: bool = False

class PestPrediction(BaseModel):
    detections: List[DetectionBox] = []
    pest_count: int = 0
    primary_pest: Optional[str] = None
    confidence: float = 0.0
    infestation_risk: str = "LOW"  # LOW, MODERATE, HIGH
    explanation: str
    model_version: str = "1.0.0"

class NutrientPrediction(BaseModel):
    crop: str
    deficiency: str
    confidence: float
    visual_indication: str
    verification_recommendation: str
    next_action: str
    model_version: str = "1.0.0"

class SegmentationPrediction(BaseModel):
    affected_area_percentage: float
    lesion_count: int = 0
    severity_category: str = "MILD"  # NONE, MILD, MODERATE, SEVERE
    explanation: str
    model_version: str = "1.0.0"

class PathogenRootCause(BaseModel):
    pathogen_name: str
    primary_cause: str
    environmental_triggers: str

class PredictiveIrrigationAdvice(BaseModel):
    status: str # "RESTRICT_OVERHEAD", "OPTIMAL_DRIP_ONLY", "HOLD_WATER"
    headline: str
    water_duration_mins: int
    scientific_reasoning: str

class NutrientProfileCorrection(BaseModel):
    nitrogen_action: str
    potassium_action: str
    recommended_formulation: str

class CropStressAnalysis(BaseModel):
    stress_score: float # 0.0 to 1.0
    stress_level: str # "HIGH", "MODERATE", "LOW"
    biotic_stress: str
    abiotic_stress: str
    resilience_outlook: str

class UnifiedScanResponse(BaseModel):
    status: str = "SUCCESS"
    crop: str
    overall_health: str
    disease: DiseasePrediction
    pest: Optional[PestPrediction] = None
    nutrient: Optional[NutrientPrediction] = None
    segmentation: Optional[SegmentationPrediction] = None
    root_cause: Optional[PathogenRootCause] = None
    predictive_irrigation: Optional[PredictiveIrrigationAdvice] = None
    nutrient_profile: Optional[NutrientProfileCorrection] = None
    crop_stress: Optional[CropStressAnalysis] = None
    advisory_summary: str
    recommended_actions: List[str]
    disclaimer: str = (
        "AgriVyn provides AI-assisted decision support. Results should be verified "
        "through field inspection and qualified agronomic guidance before major agricultural treatment decisions."
    )
    timestamp: str

class LocationForecastRequest(BaseModel):
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    district: Optional[str] = None
    soil_ph: Optional[float] = 6.8
    soil_moisture: Optional[float] = 28.0
    temperature: Optional[float] = 31.0
    humidity: Optional[float] = 62.0

class CultivationCropPrediction(BaseModel):
    crop_name: str
    tamil_name: str
    suitability_score: int
    suitability_tier: str
    expected_yield: str
    season_fit: str
    tamil_season: str
    duration_days: str
    water_requirement: str
    primary_mandi: str
    reasons_why: List[str]

class PredictedCropDisease(BaseModel):
    disease_name: str
    tamil_name: str
    target_crop: str
    risk_level: str  # HIGH, MODERATE, LOW
    risk_score: int
    pathogen_type: str  # Fungal, Bacterial, Viral, Pest Vector
    climate_triggers: str
    symptoms: List[str]
    tnau_protocol: str

class LocationForecastResponse(BaseModel):
    status: str = "SUCCESS"
    detected_district: str
    tamil_district: str
    town_taluk: Optional[str] = None
    zone_name: str
    tamil_zone_name: str
    typical_soil_type: str
    typical_ph: float
    active_season: str
    tamil_season: str
    cultivation_predictions: List[CultivationCropPrediction] = []
    disease_predictions: List[PredictedCropDisease] = []
    weather_forecast: str
    timestamp: str
