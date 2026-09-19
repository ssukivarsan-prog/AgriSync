import datetime
from typing import Optional
from pydantic import BaseModel, Field

class SensorIngestRequest(BaseModel):
    device_id: str = Field(..., example="ESP32-NODE-01")
    field_id: Optional[int] = Field(default=1, example=1)
    soil_moisture: float = Field(..., ge=0.0, le=100.0, example=28.4, description="Soil moisture percentage")
    temperature: float = Field(..., example=32.1, description="Temperature in Celsius")
    humidity: float = Field(..., ge=0.0, le=100.0, example=55.0, description="Relative humidity percentage")
    rainfall: float = Field(default=0.0, ge=0.0, example=0.0, description="Rainfall in mm")
    is_demo: bool = Field(default=False, description="Must be true if simulated or demo data")
    timestamp: Optional[str] = None

class SensorIngestResponse(BaseModel):
    status: str = "SUCCESS"
    message: str
    reading_id: int
    data_type: str # REAL IOT DATA or DEMO SENSOR DATA
    timestamp: str
