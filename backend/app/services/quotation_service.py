import datetime
from typing import Dict, Any, List, Optional
from backend.app.schemas.quotation import (
    CropQuotationRequest, CropQuotationResponse, CropFinancialSummary,
    QuotationLineItem, CropVarianceDiff
)

# 1. Zone IoT Sensor Hardware Topology
ZONE_PROFILES: Dict[str, Dict[str, Any]] = {
    "zone_a": {
        "id": "zone_a",
        "name": "North Field Zone A",
        "hardware": "Master LoRaWAN Gateway + Optical NPK + Multi-Depth Probe",
        "soil_type": "Loamy Soil",
        "soil_ph": 6.8,
        "soil_n_kg_ha": 140.0,
        "soil_p_kg_ha": 45.0,
        "soil_k_kg_ha": 180.0,
        "soil_moisture_pct": 32.0,
        "canopy_temp_c": 31.5,
        "humidity_pct": 56.0,
        "is_fallow": False,
        "crop": "Paddy (Rice)",
        "tinyml_edge_decision": "North Field — Normal",
        "preferred_crops": ["Tomato", "Bell Pepper", "Ashgourd", "Bittergourd"],
    },
    "zone_1": {
        "id": "zone_1",
        "name": "North Field (3.5 Acres)",
        "hardware": "Master LoRaWAN Gateway + Optical NPK + Multi-Depth Probe",
        "soil_type": "Loamy Soil",
        "soil_ph": 6.8,
        "soil_n_kg_ha": 140.0,
        "soil_p_kg_ha": 45.0,
        "soil_k_kg_ha": 180.0,
        "soil_moisture_pct": 32.0,
        "canopy_temp_c": 31.5,
        "humidity_pct": 56.0,
        "is_fallow": False,
        "crop": "Paddy (Rice)",
        "tinyml_edge_decision": "North Field — Normal",
        "preferred_crops": ["Tomato", "Bell Pepper", "Ashgourd", "Bittergourd"],
    },
    "zone_b": {
        "id": "zone_b",
        "name": "South Field Zone B",
        "hardware": "Sub-Node Sensor Kit #2 (Dual Depth Probe + Canopy Thermal)",
        "soil_type": "Sandy Loam (High Infiltration)",
        "soil_ph": 6.4,
        "soil_n_kg_ha": 110.0,
        "soil_p_kg_ha": 50.0,
        "soil_k_kg_ha": 140.0,
        "soil_moisture_pct": 24.5,
        "canopy_temp_c": 32.8,
        "humidity_pct": 52.0,
        "is_fallow": False,
        "crop": "Tomato",
        "tinyml_edge_decision": "South Field — Water Stress",
        "preferred_crops": ["Potato", "Groundnut", "Tomato", "Carrot"],
    },
    "zone_2": {
        "id": "zone_2",
        "name": "South Field (2.5 Acres)",
        "hardware": "Sub-Node Sensor Kit #2 (Dual Depth Probe + Canopy Thermal)",
        "soil_type": "Sandy Loam (High Infiltration)",
        "soil_ph": 6.4,
        "soil_n_kg_ha": 110.0,
        "soil_p_kg_ha": 50.0,
        "soil_k_kg_ha": 140.0,
        "soil_moisture_pct": 24.5,
        "canopy_temp_c": 32.8,
        "humidity_pct": 52.0,
        "is_fallow": False,
        "crop": "Tomato",
        "tinyml_edge_decision": "South Field — Water Stress",
        "preferred_crops": ["Potato", "Groundnut", "Tomato", "Carrot"],
    },
    "zone_c": {
        "id": "zone_c",
        "name": "East Field Zone C",
        "hardware": "Sub-Node Sensor Kit #3 (Heavy Soil Retentive Probe)",
        "soil_type": "Clay Loam (High Water Holding)",
        "soil_ph": 7.2,
        "soil_n_kg_ha": 160.0,
        "soil_p_kg_ha": 38.0,
        "soil_k_kg_ha": 195.0,
        "soil_moisture_pct": 42.0,
        "canopy_temp_c": 30.2,
        "humidity_pct": 62.0,
        "is_fallow": False,
        "crop": "Maize (Corn)",
        "tinyml_edge_decision": "East Field — Normal",
        "preferred_crops": ["Corn (Maize)", "Sugarcane", "Sorghum", "Cotton"],
    },
    "zone_3": {
        "id": "zone_3",
        "name": "East Field (2.5 Acres)",
        "hardware": "Sub-Node Sensor Kit #3 (Heavy Soil Retentive Probe)",
        "soil_type": "Clay Loam (High Water Holding)",
        "soil_ph": 7.2,
        "soil_n_kg_ha": 160.0,
        "soil_p_kg_ha": 38.0,
        "soil_k_kg_ha": 195.0,
        "soil_moisture_pct": 42.0,
        "canopy_temp_c": 30.2,
        "humidity_pct": 62.0,
        "is_fallow": False,
        "crop": "Maize (Corn)",
        "tinyml_edge_decision": "East Field — Normal",
        "preferred_crops": ["Corn (Maize)", "Sugarcane", "Sorghum", "Cotton"],
    },
    "zone_d": {
        "id": "zone_d",
        "name": "West Plot (1.5 Acres - Fallow)",
        "hardware": "Sub-Node Kit #4 (Multi-Depth Soil Probe)",
        "soil_type": "Sandy Loam (pH 6.6)",
        "soil_ph": 6.6,
        "soil_n_kg_ha": 105.0,
        "soil_p_kg_ha": 42.0,
        "soil_k_kg_ha": 150.0,
        "soil_moisture_pct": 26.5,
        "canopy_temp_c": 32.0,
        "humidity_pct": 52.0,
        "is_fallow": True,
        "previous_harvest": "Groundnut (Peanut)",
        "preferred_crops": ["Groundnut", "Corn (Maize)", "Tomato", "Potato"],
    },
    "zone_4": {
        "id": "zone_4",
        "name": "West Plot (1.5 Acres - Fallow)",
        "hardware": "Sub-Node Kit #4 (Multi-Depth Soil Probe)",
        "soil_type": "Sandy Loam (pH 6.6)",
        "soil_ph": 6.6,
        "soil_n_kg_ha": 105.0,
        "soil_p_kg_ha": 42.0,
        "soil_k_kg_ha": 150.0,
        "soil_moisture_pct": 26.5,
        "canopy_temp_c": 32.0,
        "humidity_pct": 52.0,
        "is_fallow": True,
        "previous_harvest": "Groundnut (Peanut)",
        "preferred_crops": ["Groundnut", "Corn (Maize)", "Tomato", "Potato"],
    },
}

# 2. Comprehensive Agronomic Financial Cost Engine (Per Acre Base Benchmarks)
CROP_COST_BENCHMARKS: Dict[str, Dict[str, Any]] = {
    "Tomato": {
        "seed_cost_per_acre": 6500.0,
        "seed_desc": "Certified F1 Hybrid Seeds / Raised Nursery Plug Trays (15,000 seedlings)",
        "fertilizer_cost_per_acre": 11500.0,
        "fert_desc": "Basal DAP + MOP + Water Soluble Fertigation Feed (NPK 19-19-19 & 0-52-34)",
        "irrigation_cost_per_acre": 7000.0,
        "irrig_desc": "Inline Drip Lateral Maintenance, Micro-Filters & Solar Pumping Energy",
        "protection_cost_per_acre": 5500.0,
        "protect_desc": "Neem Bio-pesticides, Trichoderma Soil Drench, Preventive Copper Spray",
        "labor_cost_per_acre": 13500.0,
        "labor_desc": "Trellising Stakes, Manual Weeding, Pruning & Staking Operations",
        "harvest_logistics_per_acre": 5000.0,
        "harvest_desc": "Multiple Picking Rounds (4-6 harvests) + Crates & Mandi Transport",
        "yield_quintals_per_acre": 175.0,
        "mandi_price_per_quintal": 1800.0,
        "cycle_days": 115,
        "water_req_mm": 550.0,
        "optimal_soil": "Loamy Soil",
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 7.0,
    },
    "Potato": {
        "seed_cost_per_acre": 18000.0,
        "seed_desc": "Certified Seed Tubers (Grade A Kufri Jyoti / Pukhraj @ 12-14 Quintals/acre)",
        "fertilizer_cost_per_acre": 13000.0,
        "fert_desc": "Heavy Potassium Basal (SOP) + Urea Splits + Organic Vermicompost",
        "irrigation_cost_per_acre": 6500.0,
        "irrig_desc": "Furrow / Drip Irrigation with soil moisture regulated for tuberization",
        "protection_cost_per_acre": 6000.0,
        "protect_desc": "Mancozeb Tuber Treatment + Early/Late Blight Bio-Shield Spray",
        "labor_cost_per_acre": 11000.0,
        "labor_desc": "Earthing-Up Mounding (2 rounds), De-haulming & Field Preparation",
        "harvest_logistics_per_acre": 8500.0,
        "harvest_desc": "Tractor Digger Operation, Manual Sorting, Grading & Cold Storage Jute Bags",
        "yield_quintals_per_acre": 120.0,
        "mandi_price_per_quintal": 1550.0,
        "cycle_days": 95,
        "water_req_mm": 480.0,
        "optimal_soil": "Sandy Loam (High Infiltration)",
        "optimal_ph_min": 5.8,
        "optimal_ph_max": 6.8,
    },
    "Corn (Maize)": {
        "seed_cost_per_acre": 3800.0,
        "seed_desc": "High Yield Hybrid Maize Seeds (Ganga-11 / Pioneer @ 8 kg/acre)",
        "fertilizer_cost_per_acre": 8500.0,
        "fert_desc": "Nitrogen-Rich Schedule (Urea 3 splits + Zinc Sulfate + SSP)",
        "irrigation_cost_per_acre": 4500.0,
        "irrig_desc": "Critical stage irrigation at knee-high, tasseling & silking stages",
        "protection_cost_per_acre": 3200.0,
        "protect_desc": "Fall Armyworm Pheromone Traps + Emamectin Benzoate Spray",
        "labor_cost_per_acre": 6500.0,
        "labor_desc": "Mechanical Sowing, Inter-row Cultivation & Weed Scraping",
        "harvest_logistics_per_acre": 4000.0,
        "harvest_desc": "Cob Harvesting, Shelling Machine Operation & Bagging",
        "yield_quintals_per_acre": 36.0,
        "mandi_price_per_quintal": 2250.0,
        "cycle_days": 105,
        "water_req_mm": 420.0,
        "optimal_soil": "Clay Loam (High Water Holding)",
        "optimal_ph_min": 6.5,
        "optimal_ph_max": 7.5,
    },
    "Bell Pepper": {
        "seed_cost_per_acre": 9500.0,
        "seed_desc": "Greenhouse / Open Field F1 Hybrid Capsicum Seedlings (Indra @ 14,000 plants)",
        "fertilizer_cost_per_acre": 14000.0,
        "fert_desc": "Calcium Nitrate + Potassium Schoenite + Micro-nutrient Chelated Blend",
        "irrigation_cost_per_acre": 8500.0,
        "irrig_desc": "Automated Micro-Drip with Mulch Film Soil Moisture Retention",
        "protection_cost_per_acre": 7500.0,
        "protect_desc": "Thrips & Mite Management (Yellow sticky traps + Biological acaricides)",
        "labor_cost_per_acre": 15000.0,
        "labor_desc": "2-Stem Training & Trellising, Regular De-suckering & Manual Weeding",
        "harvest_logistics_per_acre": 6500.0,
        "harvest_desc": "Staggered Pickings, Foam Wrapping & Premium Market Crates",
        "yield_quintals_per_acre": 140.0,
        "mandi_price_per_quintal": 2800.0,
        "cycle_days": 135,
        "water_req_mm": 600.0,
        "optimal_soil": "Loamy Soil",
        "optimal_ph_min": 6.2,
        "optimal_ph_max": 7.2,
    },
    "Sugarcane": {
        "seed_cost_per_acre": 12500.0,
        "seed_desc": "Certified Sett Treatment (Co 86032 @ 25,000 two-budded setts/acre)",
        "fertilizer_cost_per_acre": 16500.0,
        "fert_desc": "Heavy NPK Basal + Pressmud Compost + 4-Stage Nitrogen Fertigation",
        "irrigation_cost_per_acre": 11000.0,
        "irrig_desc": "Sub-surface Drip Irrigation or Alternate Furrow Schedule",
        "protection_cost_per_acre": 4500.0,
        "protect_desc": "Early Shoot Borer & Red Rot preventive biological drench",
        "labor_cost_per_acre": 14000.0,
        "labor_desc": "Sett planting, earthing up, detrashed leaf mulching & trash shredding",
        "harvest_logistics_per_acre": 12000.0,
        "harvest_desc": "Cane Cutting Gang + Mill Transport Trolleys",
        "yield_quintals_per_acre": 450.0,
        "mandi_price_per_quintal": 360.0,
        "cycle_days": 330,
        "water_req_mm": 1500.0,
        "optimal_soil": "Clay Loam (High Water Holding)",
        "optimal_ph_min": 6.5,
        "optimal_ph_max": 7.8,
    },
    "Groundnut": {
        "seed_cost_per_acre": 5200.0,
        "seed_desc": "Certified Bold Kernel Seeds (TAG-24 @ 40 kg/acre)",
        "fertilizer_cost_per_acre": 4800.0,
        "fert_desc": "Basal Gypsum (200kg) + SSP + Rhizobium Bio-inoculant (N-fixing)",
        "irrigation_cost_per_acre": 3500.0,
        "irrig_desc": "Drip/Furrow scheduling at pegging & pod development stage",
        "protection_cost_per_acre": 3000.0,
        "protect_desc": "Tikka disease preventive bio-fungicide + Neem oil spray",
        "labor_cost_per_acre": 6200.0,
        "labor_desc": "Bed forming, mechanical dibbling, shallow hoeing & weeding",
        "harvest_logistics_per_acre": 4200.0,
        "harvest_desc": "Plant lifting, pod stripper operation, sun drying & bagging",
        "yield_quintals_per_acre": 12.5,
        "mandi_price_per_quintal": 6400.0,
        "cycle_days": 110,
        "water_req_mm": 380.0,
        "optimal_soil": "Sandy Loam",
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 7.0,
    },
    "Soybean": {
        "seed_cost_per_acre": 3400.0,
        "seed_desc": "Certified JS-335 Seed with Rhizobium bio-fertilizer @ 25 kg/acre",
        "fertilizer_cost_per_acre": 5200.0,
        "fert_desc": "Basal DAP (50kg) + MOP + Sulfur granule top-dress",
        "irrigation_cost_per_acre": 3000.0,
        "irrig_desc": "Protective irrigation at flowering & pod filling stages",
        "protection_cost_per_acre": 2800.0,
        "protect_desc": "Girdle beetle & Spodoptera pheromone lure + NPV spray",
        "labor_cost_per_acre": 5500.0,
        "labor_desc": "Line sowing, post-emergence herbicide & mechanical weeding",
        "harvest_logistics_per_acre": 3800.0,
        "harvest_desc": "Tractor thresher operation, moisture check & bagging",
        "yield_quintals_per_acre": 10.5,
        "mandi_price_per_quintal": 4900.0,
        "cycle_days": 95,
        "water_req_mm": 360.0,
        "optimal_soil": "Loamy Soil",
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 7.2,
    },
}

def generate_crop_financial_summary(
    crop_name: str,
    area_acres: float,
    budget_inr: float,
    zone: Dict[str, Any]
) -> CropFinancialSummary:
    bench = CROP_COST_BENCHMARKS.get(crop_name, CROP_COST_BENCHMARKS["Tomato"])

    # 1. Compute Zone Soil Suitability Score
    score = 80
    if bench["optimal_soil"] in zone["soil_type"]:
        score += 15
    if bench["optimal_ph_min"] <= zone["soil_ph"] <= bench["optimal_ph_max"]:
        score += 5
    score = min(98, max(55, score))

    # 2. Adjust fertilizer cost dynamically according to live Zone NPK levels
    fert_adj = 1.0
    if zone["soil_n_kg_ha"] > 130 and zone["soil_k_kg_ha"] > 160:
        fert_adj = 0.92  # 8% savings on fertilizer due to rich residual NPK
    elif zone["soil_n_kg_ha"] < 100 or zone["soil_k_kg_ha"] < 120:
        fert_adj = 1.10  # 10% extra needed for basal enrichment

    seed_cost = bench["seed_cost_per_acre"] * area_acres
    fert_cost = (bench["fertilizer_cost_per_acre"] * fert_adj) * area_acres
    irrig_cost = bench["irrigation_cost_per_acre"] * area_acres
    protect_cost = bench["protection_cost_per_acre"] * area_acres
    labor_adj = 1.10 if zone.get("is_fallow", False) else 0.95
    labor_cost = (bench["labor_cost_per_acre"] * labor_adj) * area_acres
    harvest_cost = bench["harvest_logistics_per_acre"] * area_acres

    # TinyML on-device decision adjustments
    tinyml_decision = zone.get("tinyml_edge_decision", "Normal")
    if "Water Stress" in tinyml_decision:
        irrig_cost = round(irrig_cost * 1.10, 2)

    total_cost = round(seed_cost + fert_cost + irrig_cost + protect_cost + labor_cost + harvest_cost, 2)
    cost_per_acre = round(total_cost / area_acres, 2)
    surplus_deficit = round(budget_inr - total_cost, 2)

    if surplus_deficit >= 0:
        status = "Within Budget" if surplus_deficit <= budget_inr * 0.25 else "Comfortable Margin"
    else:
        status = "Exceeds Budget"

    # Revenue & Yield Projections
    total_yield = round(bench["yield_quintals_per_acre"] * area_acres, 1)
    gross_revenue = round(total_yield * bench["mandi_price_per_quintal"], 2)
    net_profit = round(gross_revenue - total_cost, 2)
    roi_pct = round((net_profit / total_cost) * 100.0, 1) if total_cost > 0 else 0.0

    line_items = [
        QuotationLineItem(
            category="Seed & Nursery",
            item_name=bench["seed_desc"].split("(")[0].strip(),
            cost_per_acre=bench["seed_cost_per_acre"],
            total_cost=round(seed_cost, 2),
            details=bench["seed_desc"]
        ),
        QuotationLineItem(
            category="Fertilizer & Soil Nutrition",
            item_name="Basal + Fertigation Macro/Micro Mix",
            cost_per_acre=round(bench["fertilizer_cost_per_acre"] * fert_adj, 2),
            total_cost=round(fert_cost, 2),
            details=f"{bench['fert_desc']} (Adjusted for Zone NPK: N={zone['soil_n_kg_ha']:.0f}, K={zone['soil_k_kg_ha']:.0f})"
        ),
        QuotationLineItem(
            category="Micro-Drip Irrigation & Energy",
            item_name="Root-Zone Drip & Pumping",
            cost_per_acre=bench["irrigation_cost_per_acre"],
            total_cost=round(irrig_cost, 2),
            details=bench["irrig_desc"]
        ),
        QuotationLineItem(
            category="Crop Protection & Bio-Inputs",
            item_name="Biologicals & IPM Shield",
            cost_per_acre=bench["protection_cost_per_acre"],
            total_cost=round(protect_cost, 2),
            details=bench["protect_desc"]
        ),
        QuotationLineItem(
            category="Field Labor & Operations",
            item_name="Land Prep, Weeding & Trellising",
            cost_per_acre=bench["labor_cost_per_acre"],
            total_cost=round(labor_cost, 2),
            details=bench["labor_desc"]
        ),
        QuotationLineItem(
            category="Harvesting & Logistics",
            item_name="Picking, Crates & Mandi Freight",
            cost_per_acre=bench["harvest_logistics_per_acre"],
            total_cost=round(harvest_cost, 2),
            details=bench["harvest_desc"]
        ),
    ]

    return CropFinancialSummary(
        crop_name=crop_name,
        suitability_score=score,
        zone_compatibility=f"{score}% Match with {zone['soil_type']} (pH {zone['soil_ph']}, Moisture {zone['soil_moisture_pct']}%)",
        cost_per_acre=cost_per_acre,
        total_estimated_cost=total_cost,
        budget_surplus_deficit=surplus_deficit,
        budget_status=status,
        expected_yield_quintals_per_acre=bench["yield_quintals_per_acre"],
        total_expected_yield_quintals=total_yield,
        expected_mandi_price_per_quintal=bench["mandi_price_per_quintal"],
        projected_gross_revenue=gross_revenue,
        projected_net_profit=net_profit,
        projected_roi_percent=roi_pct,
        growing_cycle_days=bench["cycle_days"],
        water_requirement_mm=bench["water_req_mm"],
        line_items=line_items,
        zone_iot_context={
            "zone_id": zone["id"],
            "zone_name": zone["name"],
            "hardware_type": zone["hardware"],
            "tinyml_edge_decision": tinyml_decision,
            "soil_type": zone["soil_type"],
            "soil_ph": zone["soil_ph"],
            "soil_moisture": f"{zone['soil_moisture_pct']}%",
            "soil_npk": f"N:{zone['soil_n_kg_ha']:.0f} | P:{zone['soil_p_kg_ha']:.0f} | K:{zone['soil_k_kg_ha']:.0f} kg/ha"
        },
        tinyml_edge_decision=tinyml_decision,
    )

def compare_crop_variance(
    recommended: CropFinancialSummary,
    selected: CropFinancialSummary,
    zone: Dict[str, Any]
) -> CropVarianceDiff:
    cost_diff = round(selected.total_estimated_cost - recommended.total_estimated_cost, 2)
    cost_diff_pct = round((cost_diff / recommended.total_estimated_cost) * 100.0, 1) if recommended.total_estimated_cost > 0 else 0.0
    profit_diff = round(selected.projected_net_profit - recommended.projected_net_profit, 2)
    roi_diff = round(selected.projected_roi_percent - recommended.projected_roi_percent, 1)
    water_diff = round(selected.water_requirement_mm - recommended.water_requirement_mm, 1)
    suitability_diff = recommended.suitability_score - selected.suitability_score

    tradeoffs = []
    if cost_diff > 0:
        tradeoffs.append(f"Requires ₹{abs(cost_diff):,.0f} (+{cost_diff_pct}%) more upfront investment capital.")
    else:
        tradeoffs.append(f"Saves ₹{abs(cost_diff):,.0f} ({abs(cost_diff_pct)}%) in initial cultivation expenses.")

    if profit_diff > 0:
        tradeoffs.append(f"Higher upside potential with ₹{abs(profit_diff):,.0f} additional projected net profit.")
    else:
        tradeoffs.append(f"Generates ₹{abs(profit_diff):,.0f} lower projected net profit compared to {recommended.crop_name}.")

    if water_diff > 0:
        tradeoffs.append(f"Demands {water_diff:.0f} mm more water volume, increasing pump runtime and drought vulnerability.")
    elif water_diff < 0:
        tradeoffs.append(f"Conserves {abs(water_diff):.0f} mm water volume, ideal for drought conservation.")

    if suitability_diff > 0:
        tradeoffs.append(f"Agronomic soil compatibility drops by {suitability_diff}% in {zone['name']} ({zone['soil_type']}).")

    if selected.crop_name == recommended.crop_name:
        verdict = f"{recommended.crop_name} is already the optimal scientific and financial recommendation for {zone['name']}."
    elif profit_diff >= 0 and selected.suitability_score >= 75:
        verdict = f"{selected.crop_name} is a viable commercial alternative, provided you have sufficient capital (₹{selected.total_estimated_cost:,.0f}) and strict micro-irrigation management."
    else:
        verdict = f"We strongly recommend {recommended.crop_name} over {selected.crop_name}. {recommended.crop_name} offers higher ROI (+{recommended.projected_roi_percent}%) with superior agronomic alignment to {zone['soil_type']} and pH {zone['soil_ph']}."

    return CropVarianceDiff(
        suggested_crop=recommended.crop_name,
        selected_crop=selected.crop_name,
        cost_difference_inr=cost_diff,
        cost_difference_percent=cost_diff_pct,
        profit_difference_inr=profit_diff,
        roi_difference_percent=roi_diff,
        water_demand_difference_mm=water_diff,
        suitability_drop_percent=max(0, suitability_diff),
        key_tradeoffs=tradeoffs,
        ai_agronomist_verdict=verdict
    )

def generate_crop_quotation(req: CropQuotationRequest) -> CropQuotationResponse:
    zone = ZONE_PROFILES.get(req.zone_id.lower(), ZONE_PROFILES["zone_a"])

    # Determine primary recommended crop based on Zone soil match & budget per acre
    budget_per_acre = req.budget_inr / req.area_acres
    candidate_crops = zone["preferred_crops"]

    # Pick candidate that fits closest within budget per acre with highest suitability
    best_crop = candidate_crops[0]
    if budget_per_acre < 35000 and "Corn (Maize)" in CROP_COST_BENCHMARKS:
        best_crop = "Corn (Maize)"
    elif budget_per_acre >= 60000 and "Bell Pepper" in candidate_crops:
        best_crop = "Bell Pepper"

    recommended_summary = generate_crop_financial_summary(best_crop, req.area_acres, req.budget_inr, zone)

    # Optional alternative candidate
    alt_crop = [c for c in candidate_crops if c != best_crop]
    alt_summary = generate_crop_financial_summary(alt_crop[0], req.area_acres, req.budget_inr, zone) if alt_crop else None

    # If user provided a custom crop selection, compare it against recommended
    comparison = None
    if req.custom_crop_selection and req.custom_crop_selection in CROP_COST_BENCHMARKS:
        user_selected_summary = generate_crop_financial_summary(req.custom_crop_selection, req.area_acres, req.budget_inr, zone)
        comparison = compare_crop_variance(recommended_summary, user_selected_summary, zone)

    return CropQuotationResponse(
        zone_id=zone["id"],
        zone_name=zone["name"],
        zone_hardware_type=f"{zone['hardware']} • TinyML: {zone.get('tinyml_edge_decision', 'Normal')}",
        area_acres=req.area_acres,
        budget_inr=req.budget_inr,
        recommended_crop=recommended_summary,
        alternative_crop=alt_summary,
        comparison_if_changed=comparison,
        all_supported_crops=list(CROP_COST_BENCHMARKS.keys()),
        timestamp=datetime.datetime.utcnow().isoformat(),
        tinyml_edge_decision=zone.get("tinyml_edge_decision", "Normal"),
    )
