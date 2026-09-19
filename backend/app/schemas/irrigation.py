from typing import Optional, List
from pydantic import BaseModel, Field

class IrrigationAnalysisRequest(BaseModel):
    soil_moisture: float = Field(..., description="Soil moisture percentage (0-100%)")
    temperature: float = Field(..., description="Temperature in Celsius")
    humidity: float = Field(..., description="Relative humidity percentage (0-100%)")
    rainfall: float = Field(default=0.0, description="Recent rainfall in mm")
    crop: str = Field(default="Tomato")
    growth_stage: str = Field(default="Flowering")  # Vegetative, Flowering, Fruiting, Maturity
    soil_type: str = Field(default="Loamy")         # Sandy, Loamy, Clay, Silt
    forecast_rain_expected: bool = Field(default=False)
    is_demo: bool = Field(default=False)

class IrrigationFactor(BaseModel):
    parameter: str
    measured_value: str
    target_optimal: str
    impact: str

class IrrigationAnalysisResponse(BaseModel):
    status: str  # IRRIGATE NOW, MONITOR, DELAY IRRIGATION
    action_urgency: str # URGENT, MODERATE, LOW, NONE
    water_deficit_percentage: float
    recommended_duration_minutes: int
    recommended_method: str
    factors: List[IrrigationFactor]
    reasoning: str
    is_demo: bool = False
    timestamp: str
