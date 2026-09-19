import datetime
from typing import Dict, Any, List
from backend.app.schemas.irrigation import IrrigationAnalysisRequest, IrrigationAnalysisResponse, IrrigationFactor

# Agronomic thresholds based on Indian Council of Agricultural Research (ICAR) guidelines
CROP_IRRIGATION_PROFILES = {
    "Tomato": {
        "Vegetative": {"min_moisture": 30.0, "optimal_min": 38.0, "optimal_max": 50.0, "kc": 0.6},
        "Flowering": {"min_moisture": 35.0, "optimal_min": 42.0, "optimal_max": 55.0, "kc": 1.15},
        "Fruiting": {"min_moisture": 32.0, "optimal_min": 40.0, "optimal_max": 52.0, "kc": 0.9},
        "Maturity": {"min_moisture": 25.0, "optimal_min": 30.0, "optimal_max": 42.0, "kc": 0.7}
    },
    "Potato": {
        "Vegetative": {"min_moisture": 32.0, "optimal_min": 40.0, "optimal_max": 52.0, "kc": 0.5},
        "Tuber Formation": {"min_moisture": 38.0, "optimal_min": 45.0, "optimal_max": 58.0, "kc": 1.1},
        "Maturity": {"min_moisture": 25.0, "optimal_min": 30.0, "optimal_max": 40.0, "kc": 0.65}
    },
    "Corn (Maize)": {
        "Vegetative": {"min_moisture": 28.0, "optimal_min": 35.0, "optimal_max": 48.0, "kc": 0.4},
        "Tasseling/Silking": {"min_moisture": 36.0, "optimal_min": 44.0, "optimal_max": 56.0, "kc": 1.2},
        "Grain Filling": {"min_moisture": 30.0, "optimal_min": 38.0, "optimal_max": 50.0, "kc": 0.85}
    },
    "Bell Pepper": {
        "Vegetative": {"min_moisture": 30.0, "optimal_min": 36.0, "optimal_max": 48.0, "kc": 0.6},
        "Flowering": {"min_moisture": 34.0, "optimal_min": 40.0, "optimal_max": 52.0, "kc": 1.05},
        "Fruiting": {"min_moisture": 32.0, "optimal_min": 38.0, "optimal_max": 50.0, "kc": 0.9}
    },
    "Sugarcane": {
        "Germination": {"min_moisture": 32.0, "optimal_min": 40.0, "optimal_max": 55.0, "kc": 0.5},
        "Tillering": {"min_moisture": 36.0, "optimal_min": 45.0, "optimal_max": 60.0, "kc": 1.0},
        "Grand Growth": {"min_moisture": 38.0, "optimal_min": 48.0, "optimal_max": 65.0, "kc": 1.25},
        "Ripening": {"min_moisture": 25.0, "optimal_min": 30.0, "optimal_max": 45.0, "kc": 0.6}
    }
}

# Soil Water Retention characteristics
SOIL_FACTORS = {
    "Sandy": {"retention_factor": 0.8, "infiltration_rate": "High", "drip_duration_multiplier": 0.75},
    "Sandy Loam": {"retention_factor": 0.9, "infiltration_rate": "Moderate-High", "drip_duration_multiplier": 0.9},
    "Loamy": {"retention_factor": 1.0, "infiltration_rate": "Optimal", "drip_duration_multiplier": 1.0},
    "Clay Loam": {"retention_factor": 1.15, "infiltration_rate": "Moderate-Low", "drip_duration_multiplier": 1.15},
    "Clay": {"retention_factor": 1.3, "infiltration_rate": "Low", "drip_duration_multiplier": 1.3}
}

def analyze_irrigation(req: IrrigationAnalysisRequest) -> IrrigationAnalysisResponse:
    # 1. Retrieve crop & stage thresholds
    crop_name = req.crop if req.crop in CROP_IRRIGATION_PROFILES else "Tomato"
    stages = CROP_IRRIGATION_PROFILES[crop_name]
    stage_data = stages.get(req.growth_stage, list(stages.values())[0])

    min_moisture = stage_data["min_moisture"]
    opt_min = stage_data["optimal_min"]
    opt_max = stage_data["optimal_max"]
    kc = stage_data["kc"]

    # 2. Adjust for Soil Type
    soil_info = SOIL_FACTORS.get(req.soil_type, SOIL_FACTORS["Loamy"])
    
    # 3. Reference Evapotranspiration Estimate (Hargreaves simplified proxy)
    # Higher temp and lower humidity significantly amplify water loss
    vapor_deficit = max(0.0, (100.0 - req.humidity) / 100.0)
    et0 = max(2.5, (req.temperature * 0.18) * (1.0 + vapor_deficit * 0.5))
    etc = round(et0 * kc, 2)

    # 4. Decision Rule Engine
    measured_moisture = req.soil_moisture
    factors: List[IrrigationFactor] = []

    factors.append(IrrigationFactor(
        parameter="Soil Moisture",
        measured_value=f"{measured_moisture:.1f}%",
        target_optimal=f"{opt_min:.1f}% - {opt_max:.1f}%",
        impact="Primary Trigger: Below critical threshold" if measured_moisture < min_moisture else ("Within optimal range" if measured_moisture <= opt_max else "Adequate / Field Saturated")
    ))

    factors.append(IrrigationFactor(
        parameter="Temperature & Evapotranspiration",
        measured_value=f"{req.temperature:.1f}°C (ETc: {etc} mm/day)",
        target_optimal="20°C - 30°C",
        impact="High evaporative demand accelerating root depletion" if req.temperature > 32.0 else "Normal atmospheric water demand"
    ))

    factors.append(IrrigationFactor(
        parameter="Crop Stage Sensitivity",
        measured_value=f"{crop_name} ({req.growth_stage}, Kc={kc})",
        target_optimal="Critical water need stage" if kc >= 1.0 else "Moderate need",
        impact="Flowering/fruiting is highly vulnerable to moisture stress" if kc >= 1.0 else "Vegetative/maturing stage"
    ))

    factors.append(IrrigationFactor(
        parameter="Recent / Forecast Rain",
        measured_value=f"{req.rainfall:.1f} mm rain (Forecast: {'Yes' if req.forecast_rain_expected else 'No'})",
        target_optimal="No rain expected",
        impact="Rain anticipated within 24h; irrigation can be delayed" if (req.forecast_rain_expected or req.rainfall > 10.0) else "No natural replenishment expected"
    ))

    # Determine status & reasoning
    if (req.forecast_rain_expected or req.rainfall > 15.0) and measured_moisture >= min_moisture - 3.0:
        status = "DELAY IRRIGATION"
        urgency = "LOW"
        deficit = 0.0
        duration = 0
        method = "Delay irrigation - Natural precipitation anticipated"
        reasoning = f"Rainfall ({req.rainfall:.1f} mm) or imminent precipitation expected. Delay irrigation to conserve water and prevent root waterlogging."
    elif measured_moisture < min_moisture:
        status = "IRRIGATE NOW"
        urgency = "URGENT" if measured_moisture < min_moisture - 5.0 else "MODERATE"
        deficit = round(max(0.0, opt_min - measured_moisture), 1)
        base_mins = int(deficit * 4.5 * soil_info["drip_duration_multiplier"])
        duration = max(25, min(90, base_mins))
        method = f"Drip Irrigation ({soil_info['infiltration_rate']} Infiltration)"
        reasoning = (
            f"Soil moisture ({measured_moisture:.1f}%) has fallen below the critical {min_moisture:.1f}% threshold "
            f"for {crop_name} in the {req.growth_stage} stage. High temperature ({req.temperature:.1f}°C) creates a daily "
            f"crop evapotranspiration loss of ~{etc} mm/day. Immediate irrigation is recommended."
        )
    elif measured_moisture < opt_min:
        status = "MONITOR"
        urgency = "LOW"
        deficit = round(opt_min - measured_moisture, 1)
        duration = int(20 * soil_info["drip_duration_multiplier"])
        method = "Light Maintenance Drip"
        reasoning = (
            f"Soil moisture ({measured_moisture:.1f}%) is marginally below optimal ({opt_min:.1f}%), but above stress limit. "
            f"Monitor sensor trend over the next 4 hours. Schedule irrigation early morning if depletion continues."
        )
    else:
        status = "DELAY IRRIGATION"
        urgency = "NONE"
        deficit = 0.0
        duration = 0
        method = "No action required"
        reasoning = f"Soil moisture ({measured_moisture:.1f}%) is in the optimal root zone range ({opt_min:.1f}% - {opt_max:.1f}%). Irrigation not required."

    return IrrigationAnalysisResponse(
        status=status,
        action_urgency=urgency,
        water_deficit_percentage=deficit,
        recommended_duration_minutes=duration,
        recommended_method=method,
        factors=factors,
        reasoning=reasoning,
        is_demo=req.is_demo,
        timestamp=datetime.datetime.utcnow().isoformat()
    )
