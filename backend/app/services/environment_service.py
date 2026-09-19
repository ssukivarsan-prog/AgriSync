import datetime
from pathlib import Path
from typing import List
import numpy as np
import xgboost as xgb
from backend.app.schemas.environment import (
    EnvironmentRiskRequest, EnvironmentRiskResponse, RiskDetail
)

# Load trained XGBoost model if available
XGB_ENV_PATH = Path(__file__).resolve().parent.parent.parent / "models" / "environment" / "xgboost_soil_env.json"
xgb_env_model = None
if XGB_ENV_PATH.exists():
    try:
        xgb_env_model = xgb.XGBClassifier()
        xgb_env_model.load_model(str(XGB_ENV_PATH))
    except Exception:
        xgb_env_model = None

XGB_CLASS_NAMES = [
    "Optimal",
    "Drought Stress",
    "Heat Stress",
    "Waterlogging & Flood",
    "Nutrient Depleted"
]

def evaluate_environmental_risk(req: EnvironmentRiskRequest) -> EnvironmentRiskResponse:
    t = req.temperature
    rh = req.humidity
    sm = req.soil_moisture
    rain = req.rainfall

    # 1. Drought Risk
    if sm < 22.0 and rain < 2.0:
        drought_lvl = "HIGH"
        drought_score = 0.88
        drought_why = f"Soil moisture is severely depleted ({sm:.1f}%) with zero recent precipitation, creating dangerous root wilting conditions."
        drought_act = "Engage emergency deep-root irrigation; apply organic straw mulch to arrest soil evaporation."
    elif sm < 32.0 and rain < 5.0:
        drought_lvl = "MODERATE"
        drought_score = 0.58
        drought_why = f"Soil moisture ({sm:.1f}%) is in continuous decline with negligible rainfall over past 48 hours."
        drought_act = "Schedule supplemental irrigation cycle within 12 hours; monitor moisture sensor trend."
    else:
        drought_lvl = "LOW"
        drought_score = 0.18
        drought_why = f"Soil moisture reserves ({sm:.1f}%) are adequate to support normal transpiration."
        drought_act = "Maintain standard scheduled irrigation checks."

    # 2. Heat Stress Risk
    if t >= 38.0:
        heat_lvl = "HIGH"
        heat_score = 0.92
        heat_why = f"Extreme temperature ({t:.1f}°C) exceeds photosynthetic enzyme optimum, inducing flower drop and pollen sterility."
        heat_act = "Operate micro-sprinklers for evaporative canopy cooling between 12:00 PM and 3:00 PM; deploy shade netting if available."
    elif t >= 33.0:
        heat_lvl = "MODERATE"
        heat_score = 0.60
        heat_why = f"Elevated temperature ({t:.1f}°C) accelerates water loss and induces midday stomatal closure."
        heat_act = "Ensure soil profile is well-hydrated prior to midday sun; avoid foliage trimming."
    else:
        heat_lvl = "LOW"
        heat_score = 0.15
        heat_why = f"Temperature ({t:.1f}°C) is in the favorable metabolic range for subtropical/tropical crops."
        heat_act = "Favorable thermal conditions; no corrective intervention needed."

    # 3. Flood / Waterlogging Risk
    if (rain > 65.0 or (rain > 30.0 and sm > 75.0)):
        flood_lvl = "HIGH"
        flood_score = 0.85
        flood_why = f"Excess precipitation ({rain:.1f} mm) and high soil saturation ({sm:.1f}%) cause root zone anoxia (oxygen starvation)."
        flood_act = "Clear drainage channels immediately to discharge standing surface water; inspect for soil erosion."
    elif (rain > 25.0 or (sm > 65.0 and req.forecast_rain_expected)):
        flood_lvl = "MODERATE"
        flood_score = 0.52
        flood_why = f"Substantial rainfall ({rain:.1f} mm) has elevated moisture ({sm:.1f}%) near field capacity with further rain possible."
        flood_act = "Halt all irrigation; inspect perimeter trenches for unhindered runoff flow."
    else:
        flood_lvl = "LOW"
        flood_score = 0.10
        flood_why = f"Recent precipitation ({rain:.1f} mm) is comfortably absorbed without water stagnation risk."
        flood_act = "Standard field maintenance."

    # 4. Disease-Favorable Conditions (Fungal & Bacterial Spore Germination)
    # Prolonged high humidity (RH > 75%) and temperatures between 20°C - 30°C favor Early Blight, Downy Mildew, Rust
    if rh >= 78.0 and 19.0 <= t <= 31.0:
        dis_lvl = "HIGH"
        dis_score = 0.90
        dis_why = (
            f"Sustained high humidity ({rh:.1f}%) combined with warm temperature ({t:.1f}°C) creates ideal free moisture "
            f"for fungal and bacterial spore germination (e.g. Early Blight, Anthracnose)."
        )
        dis_act = "Avoid sprinkler irrigation to prevent leaf wetness; inspect lower leaves for early lesions; prepare bio-fungicide spray if symptoms appear."
    elif rh >= 65.0 and 18.0 <= t <= 33.0:
        dis_lvl = "MODERATE"
        dis_score = 0.55
        dis_why = f"Moderate humidity ({rh:.1f}%) creates partial canopy microclimate conducive to pathogen propagation."
        dis_act = "Improve row aeration through pruning and weed suppression; inspect susceptible crop varieties."
    else:
        dis_lvl = "LOW"
        dis_score = 0.20
        dis_why = f"Atmospheric moisture ({rh:.1f}%) is low enough that plant foliage dries rapidly, inhibiting spore incubation."
        dis_act = "Pathogen risk is minimal under current atmospheric profile."

    # 5. General Crop Stress
    stress_score = round((drought_score + heat_score + flood_score + dis_score) / 4.0, 2)
    if stress_score >= 0.65:
        stress_lvl = "HIGH"
        stress_why = "Multiple compounding environmental stressors (heat/drought/humidity) are straining crop resilience."
        stress_act = "Prioritize root protection and canopy cooling; avoid high-nitrogen fertilizers during acute abiotic stress."
    elif stress_score >= 0.40:
        stress_lvl = "MODERATE"
        stress_why = "Localized environmental stress detected. Crop growth rate may be slightly subdued."
        stress_act = "Monitor sensor readings and address the primary stress factor."
    else:
        stress_lvl = "LOW"
        stress_why = "Overall environmental indices are conducive to healthy vegetative and reproductive growth."
        stress_act = "Continue standard crop management calendar."

    # Calculate overall risk
    max_score = max(drought_score, heat_score, flood_score, dis_score)
    if max_score >= 0.75:
        overall_lvl = "HIGH"
    elif max_score >= 0.45:
        overall_lvl = "MODERATE"
    else:
        overall_lvl = "LOW"

    mitigations = []
    if drought_lvl in ["HIGH", "MODERATE"]: mitigations.append(drought_act)
    if heat_lvl in ["HIGH", "MODERATE"]: mitigations.append(heat_act)
    if flood_lvl in ["HIGH", "MODERATE"]: mitigations.append(flood_act)
    if dis_lvl in ["HIGH", "MODERATE"]: mitigations.append(dis_act)
    if not mitigations: mitigations.append("Continue standard crop monitoring; conditions are currently optimal.")

    # Predict condition via XGBoost
    xgb_pred_text = ""
    if xgb_env_model:
        try:
            sample = np.array([[sm, t, rh, rain, 6.8, 140.0, 45.0, 180.0]])
            pred_idx = int(xgb_env_model.predict(sample)[0])
            xgb_label = XGB_CLASS_NAMES[pred_idx] if pred_idx < len(XGB_CLASS_NAMES) else "OPTIMAL"
            xgb_pred_text = f" [XGBoost ML Classification: {xgb_label}]"
        except Exception:
            pass

    return EnvironmentRiskResponse(
        overall_environmental_risk=overall_lvl,
        overall_risk_score=max_score,
        drought_risk=RiskDetail(category="Drought", level=drought_lvl, score=drought_score, indicator=f"Moisture: {sm:.1f}%", why=drought_why, action=drought_act),
        heat_stress=RiskDetail(category="Heat Stress", level=heat_lvl, score=heat_score, indicator=f"Temperature: {t:.1f}°C", why=heat_why, action=heat_act),
        flood_risk=RiskDetail(category="Flood / Waterlogging", level=flood_lvl, score=flood_score, indicator=f"Rainfall: {rain:.1f} mm", why=flood_why, action=flood_act),
        disease_favorable=RiskDetail(category="Disease-Favorable Weather", level=dis_lvl, score=dis_score, indicator=f"Humidity: {rh:.1f}% at {t:.1f}°C", why=dis_why, action=dis_act),
        general_crop_stress=RiskDetail(category="Compound Stress Index", level=stress_lvl, score=stress_score, indicator=f"Composite Index: {stress_score}", why=stress_why, action=stress_act),
        explanation_summary=f"Primary environmental concern is {overall_lvl} risk driven by {'heat and moisture factors' if max_score >= 0.45 else 'benign weather'}.{xgb_pred_text}",
        recommended_mitigation=mitigations[:3],
        is_demo=req.is_demo,
        timestamp=datetime.datetime.utcnow().isoformat()
    )
