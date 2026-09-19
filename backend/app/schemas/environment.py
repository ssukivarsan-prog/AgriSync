from typing import Optional, List
from pydantic import BaseModel, Field

class EnvironmentRiskRequest(BaseModel):
    temperature: float = Field(..., description="Ambient temperature in Celsius")
    humidity: float = Field(..., description="Relative humidity percentage (0-100%)")
    soil_moisture: float = Field(..., description="Current soil moisture percentage (0-100%)")
    rainfall: float = Field(default=0.0, description="Past 24h rainfall in mm")
    wind_speed: float = Field(default=8.5, description="Wind speed in km/h")
    forecast_rain_expected: bool = Field(default=False)
    is_demo: bool = Field(default=False)

class RiskDetail(BaseModel):
    category: str
    level: str  # LOW, MODERATE, HIGH
    score: float # 0.0 - 1.0
    indicator: str
    why: str
    action: str

class EnvironmentRiskResponse(BaseModel):
    overall_environmental_risk: str # LOW, MODERATE, HIGH
    overall_risk_score: float
    drought_risk: RiskDetail
    heat_stress: RiskDetail
    flood_risk: RiskDetail
    disease_favorable: RiskDetail
    general_crop_stress: RiskDetail
    explanation_summary: str
    recommended_mitigation: List[str]
    is_demo: bool = False
    timestamp: str
