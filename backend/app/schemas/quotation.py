from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional

class CropQuotationRequest(BaseModel):
    zone_id: str = Field(..., description="Selected IoT Zone (zone_a, zone_b, zone_c)")
    area_acres: float = Field(..., ge=0.2, le=50.0, description="Approximate cultivation area in acres")
    budget_inr: float = Field(..., ge=5000.0, description="Farmer available capital investment in INR")
    season: str = Field(default="Kharif", description="Crop season: Kharif, Rabi, Zaid")
    custom_crop_selection: Optional[str] = Field(default=None, description="Optional manual crop override to evaluate")

class QuotationLineItem(BaseModel):
    category: str
    item_name: str
    cost_per_acre: float
    total_cost: float
    details: str

class CropFinancialSummary(BaseModel):
    crop_name: str
    suitability_score: int
    zone_compatibility: str
    cost_per_acre: float
    total_estimated_cost: float
    budget_surplus_deficit: float
    budget_status: str  # "Within Budget", "Exceeds Budget", "Comfortable Margin"
    expected_yield_quintals_per_acre: float
    total_expected_yield_quintals: float
    expected_mandi_price_per_quintal: float
    projected_gross_revenue: float
    projected_net_profit: float
    projected_roi_percent: float
    growing_cycle_days: int
    water_requirement_mm: float
    line_items: List[QuotationLineItem]
    zone_iot_context: Dict[str, Any]
    tinyml_edge_decision: Optional[str] = None

class CropVarianceDiff(BaseModel):
    suggested_crop: str
    selected_crop: str
    cost_difference_inr: float
    cost_difference_percent: float
    profit_difference_inr: float
    roi_difference_percent: float
    water_demand_difference_mm: float
    suitability_drop_percent: int
    key_tradeoffs: List[str]
    ai_agronomist_verdict: str

class CropQuotationResponse(BaseModel):
    zone_id: str
    zone_name: str
    zone_hardware_type: str  # "Master LoRa Gateway + Full Suite" or "Sub-Node Sensor Kit"
    area_acres: float
    budget_inr: float
    recommended_crop: CropFinancialSummary
    alternative_crop: Optional[CropFinancialSummary] = None
    comparison_if_changed: Optional[CropVarianceDiff] = None
    all_supported_crops: List[str]
    timestamp: str
    tinyml_edge_decision: Optional[str] = None
