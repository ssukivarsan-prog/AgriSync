import '../models/quotation_models.dart';
import '../models/field_zone.dart';
import '../models/farmer_profile.dart';

class CropQuotationService {
  // 1. Comprehensive Agronomic & Economic Benchmarks for 8 Candidate Crops
  static final Map<String, Map<String, dynamic>> cropBenchmarks = {
    "Groundnut (Peanut)": {
      "seed_cost_per_acre": 5200.0,
      "seed_desc": "Certified Bold Kernel Seeds (TAG-24 @ 40 kg/acre)",
      "fertilizer_cost_per_acre": 4800.0,
      "fert_desc": "Basal Gypsum (200kg) + SSP + Rhizobium Bio-inoculant (N-fixing)",
      "irrigation_cost_per_acre": 3500.0,
      "irrig_desc": "Drip/Furrow scheduling at pod development stage",
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
      "is_legume": true,
      "heat_tolerance": "High",
      "moisture_need": "Low-Moderate",
    },
    "Tomato": {
      "seed_cost_per_acre": 6500.0,
      "seed_desc": "Certified F1 Hybrid Seeds / Raised Nursery Trays (15,000 seedlings)",
      "fertilizer_cost_per_acre": 11500.0,
      "fert_desc": "Basal DAP + MOP + Water Soluble Fertigation (NPK 19-19-19 & 0-52-34)",
      "irrigation_cost_per_acre": 7000.0,
      "irrig_desc": "Inline Root-Zone Drip Lateral Maintenance & Solar Pump Energy",
      "protection_cost_per_acre": 5500.0,
      "protect_desc": "Neem bio-pesticides, Trichoderma drench, preventive copper spray",
      "labor_cost_per_acre": 13500.0,
      "labor_desc": "Trellising bamboo stakes, manual weeding, pruning & staking",
      "harvest_logistics_per_acre": 5000.0,
      "harvest_desc": "Multiple picking rounds (4-6 harvests) + crates & mandi freight",
      "yield_quintals_per_acre": 175.0,
      "mandi_price_per_quintal": 1800.0,
      "cycle_days": 115,
      "water_req_mm": 550.0,
      "optimal_soil": "Loamy Soil",
      "optimal_ph_min": 6.0,
      "optimal_ph_max": 7.0,
      "is_legume": false,
      "heat_tolerance": "Moderate",
      "moisture_need": "Moderate",
    },
    "Maize (Corn)": {
      "seed_cost_per_acre": 3800.0,
      "seed_desc": "High-Yielding Single-Cross Hybrid Seeds (Pioneer / Ganga-11 @ 8 kg/acre)",
      "fertilizer_cost_per_acre": 8500.0,
      "fert_desc": "Nitrogen-Rich Split Schedule (Urea 3 splits + Zinc Sulfate + SSP)",
      "irrigation_cost_per_acre": 4500.0,
      "irrig_desc": "Critical stage watering at knee-high, tasseling & silking stages",
      "protection_cost_per_acre": 3200.0,
      "protect_desc": "Fall Armyworm pheromone traps + biological spray",
      "labor_cost_per_acre": 6500.0,
      "labor_desc": "Mechanical tractor sowing, inter-row cultivation & weed scraping",
      "harvest_logistics_per_acre": 4000.0,
      "harvest_desc": "Cob de-husking, shelling machine operation & storage bags",
      "yield_quintals_per_acre": 36.0,
      "mandi_price_per_quintal": 2250.0,
      "cycle_days": 105,
      "water_req_mm": 440.0,
      "optimal_soil": "Clay Loam",
      "optimal_ph_min": 6.5,
      "optimal_ph_max": 7.5,
      "is_legume": false,
      "heat_tolerance": "High",
      "moisture_need": "Moderate",
    },
    "Paddy (Rice)": {
      "seed_cost_per_acre": 4200.0,
      "seed_desc": "Certified High-Yielding Dwarf Paddy (Arka Rakshak / Basmati @ 20 kg)",
      "fertilizer_cost_per_acre": 9800.0,
      "fert_desc": "Basal NPK + Zinc Sulfate (10kg) + Neem Coated Urea splits",
      "irrigation_cost_per_acre": 8500.0,
      "irrig_desc": "Puddled field shallow water regime (5cm standing layer)",
      "protection_cost_per_acre": 4200.0,
      "protect_desc": "Blast & Sheath Blight IPM shield + stem borer light traps",
      "labor_cost_per_acre": 9500.0,
      "labor_desc": "Nursery uprooting, mechanical transplanting & rotary weeding",
      "harvest_logistics_per_acre": 5200.0,
      "harvest_desc": "Combine harvester thrashing, grain cleaning & transport",
      "yield_quintals_per_acre": 26.0,
      "mandi_price_per_quintal": 2300.0,
      "cycle_days": 125,
      "water_req_mm": 950.0,
      "optimal_soil": "Clay Loam",
      "optimal_ph_min": 5.8,
      "optimal_ph_max": 7.0,
      "is_legume": false,
      "heat_tolerance": "Moderate",
      "moisture_need": "High",
    },
    "Soybean": {
      "seed_cost_per_acre": 4500.0,
      "seed_desc": "Certified JS-335 / JS-9560 Seeds treated with Trichoderma (@ 30 kg/acre)",
      "fertilizer_cost_per_acre": 5200.0,
      "fert_desc": "DAP + Potassium Schoenite + Bradyrhizobium Culture",
      "irrigation_cost_per_acre": 3200.0,
      "irrig_desc": "Protective rainfed supplementary sprinkler/drip during dry spell",
      "protection_cost_per_acre": 3500.0,
      "protect_desc": "Yellow mosaic virus vector whitefly sticky traps + bio-shield",
      "labor_cost_per_acre": 5800.0,
      "labor_desc": "Broadbed furrow planting, manual inter-culture & rogueing",
      "harvest_logistics_per_acre": 3800.0,
      "harvest_desc": "Sickle harvesting, mechanical threshing & bag stitching",
      "yield_quintals_per_acre": 11.5,
      "mandi_price_per_quintal": 4800.0,
      "cycle_days": 100,
      "water_req_mm": 420.0,
      "optimal_soil": "Black Alluvial Loam",
      "optimal_ph_min": 6.3,
      "optimal_ph_max": 7.5,
      "is_legume": true,
      "heat_tolerance": "High",
      "moisture_need": "Moderate",
    },
    "Cotton": {
      "seed_cost_per_acre": 3600.0,
      "seed_desc": "Approved Bt Cotton Hybrid Packets (BG-II @ 2 packets/acre)",
      "fertilizer_cost_per_acre": 10500.0,
      "fert_desc": "High Potassium & Boron split fertigation (N:P:K 120:60:60)",
      "irrigation_cost_per_acre": 6000.0,
      "irrig_desc": "Alternate furrow / micro-drip with moisture conservation mulching",
      "protection_cost_per_acre": 6800.0,
      "protect_desc": "Pink bollworm mating disruption ropes + bio-fungicides",
      "labor_cost_per_acre": 12000.0,
      "labor_desc": "Nipping vegetative tips, inter-row de-weeding & earthing",
      "harvest_logistics_per_acre": 6500.0,
      "harvest_desc": "Manual picking rounds (3-4 rounds) & clean grading",
      "yield_quintals_per_acre": 14.0,
      "mandi_price_per_quintal": 7200.0,
      "cycle_days": 160,
      "water_req_mm": 680.0,
      "optimal_soil": "Black Alluvial Loam",
      "optimal_ph_min": 6.5,
      "optimal_ph_max": 8.0,
      "is_legume": false,
      "heat_tolerance": "Very High",
      "moisture_need": "Moderate",
    },
    "Potato": {
      "seed_cost_per_acre": 18000.0,
      "seed_desc": "Certified Seed Tubers (Grade A Kufri Jyoti @ 12-14 Quintals/acre)",
      "fertilizer_cost_per_acre": 13000.0,
      "fert_desc": "Heavy Potassium Basal (SOP) + Urea Splits + Organic Vermicompost",
      "irrigation_cost_per_acre": 6500.0,
      "irrig_desc": "Furrow / Drip Irrigation with soil moisture regulated for tuberization",
      "protection_cost_per_acre": 6000.0,
      "protect_desc": "Mancozeb Tuber Treatment + Early/Late Blight Bio-Shield Spray",
      "labor_cost_per_acre": 11000.0,
      "labor_desc": "Earthing-Up Mounding (2 rounds), De-haulming & Field Preparation",
      "harvest_logistics_per_acre": 8500.0,
      "harvest_desc": "Tractor Digger Operation, Manual Sorting, Grading & Storage Jute Bags",
      "yield_quintals_per_acre": 120.0,
      "mandi_price_per_quintal": 1550.0,
      "cycle_days": 95,
      "water_req_mm": 480.0,
      "optimal_soil": "Sandy Loam",
      "optimal_ph_min": 5.8,
      "optimal_ph_max": 6.8,
      "is_legume": false,
      "heat_tolerance": "Low",
      "moisture_need": "Moderate",
    },
    "Bell Pepper": {
      "seed_cost_per_acre": 9500.0,
      "seed_desc": "High-Yield F1 Hybrid Capsicum Seedlings (Indra @ 14,000 plants)",
      "fertilizer_cost_per_acre": 14000.0,
      "fert_desc": "Calcium Nitrate + Potassium Schoenite + Micro-nutrient Blend",
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
      "is_legume": false,
      "heat_tolerance": "Moderate",
      "moisture_need": "High",
    },
    "Banana (Vazhai)": {
      "seed_cost_per_acre": 14000.0,
      "seed_desc": "TNAU Certified Tissue Culture Grand Naine / Poovan suckers (1,000 plants/acre)",
      "fertilizer_cost_per_acre": 16500.0,
      "fert_desc": "Basal FYM (10t) + Urea, SSP, MOP split fertigation + micronutrients",
      "irrigation_cost_per_acre": 8500.0,
      "irrig_desc": "Root-zone drip irrigation (15-20 L/plant/day) with mulch cover",
      "protection_cost_per_acre": 6500.0,
      "protect_desc": "Sigatoka leaf spot mineral oil spray + Pseudostem borer trap",
      "labor_cost_per_acre": 14000.0,
      "labor_desc": "Pit digging, sucker planting, desuckering, earthing up & propping",
      "harvest_logistics_per_acre": 8000.0,
      "harvest_desc": "Bunch de-handing, foam padding, crate loading & mandi logistics",
      "yield_quintals_per_acre": 280.0,
      "mandi_price_per_quintal": 2200.0,
      "cycle_days": 330,
      "water_req_mm": 1200.0,
      "optimal_soil": "Alluvial Clay Loam",
      "optimal_ph_min": 6.5,
      "optimal_ph_max": 7.5,
      "is_legume": false,
      "heat_tolerance": "High",
      "moisture_need": "High",
    },
    "Turmeric (Manjal)": {
      "seed_cost_per_acre": 16000.0,
      "seed_desc": "TNAU BSR-2 / Erode Local rhizomes treated with Trichoderma viride",
      "fertilizer_cost_per_acre": 12500.0,
      "fert_desc": "Neem cake (200kg) + VAM + NPK 120:60:120 kg/ha splits",
      "irrigation_cost_per_acre": 6500.0,
      "irrig_desc": "Drip fertigation at 4-day intervals with raised bed furrows",
      "protection_cost_per_acre": 5000.0,
      "protect_desc": "Rhizome rot Pseudomonas drenching + shoot borer light traps",
      "labor_cost_per_acre": 13000.0,
      "labor_desc": "Raised bed preparation, rhizome dibbling, weeding & mulching",
      "harvest_logistics_per_acre": 7500.0,
      "harvest_desc": "Mechanical tractor digger, rhizome boiling & sun drying",
      "yield_quintals_per_acre": 24.0,
      "mandi_price_per_quintal": 13500.0,
      "cycle_days": 260,
      "water_req_mm": 750.0,
      "optimal_soil": "Red Loamy Soil",
      "optimal_ph_min": 5.8,
      "optimal_ph_max": 7.2,
      "is_legume": false,
      "heat_tolerance": "High",
      "moisture_need": "Moderate",
    },
    "Sugarcane (Karumbu)": {
      "seed_cost_per_acre": 12000.0,
      "seed_desc": "Certified Co 86032 setts treated with carbendazim + carbofuran",
      "fertilizer_cost_per_acre": 14000.0,
      "fert_desc": "Basal SSP (150kg) + Urea 3 splits + MOP (80kg) + Gluconacetobacter",
      "irrigation_cost_per_acre": 7500.0,
      "irrig_desc": "Sub-surface drip or alternate furrow irrigation regime",
      "protection_cost_per_acre": 5500.0,
      "protect_desc": "Early shoot borer granulosis virus + red rot bio-prevention",
      "labor_cost_per_acre": 12500.0,
      "labor_desc": "Deep furrow opening, sett planting, partial earthing up & detrashing",
      "harvest_logistics_per_acre": 9500.0,
      "harvest_desc": "Base cutting, detrashing, bundle tying & sugar mill transport",
      "yield_quintals_per_acre": 420.0,
      "mandi_price_per_quintal": 315.0,
      "cycle_days": 340,
      "water_req_mm": 1500.0,
      "optimal_soil": "Clay Loam",
      "optimal_ph_min": 6.5,
      "optimal_ph_max": 8.0,
      "is_legume": false,
      "heat_tolerance": "Very High",
      "moisture_need": "High",
    },
    "Black Gram (Ulundu)": {
      "seed_cost_per_acre": 2200.0,
      "seed_desc": "TNAU Vamban-8 Seeds treated with Rhizobium + Phosphobacteria",
      "fertilizer_cost_per_acre": 3200.0,
      "fert_desc": "DAP foliar spray 2% at flowering + Gypsum + Zinc Sulfate",
      "irrigation_cost_per_acre": 2400.0,
      "irrig_desc": "Protective sprinkler/furrow watering at flowering & pod filling",
      "protection_cost_per_acre": 2200.0,
      "protect_desc": "Yellow mosaic virus vector whitefly sticky traps + Neem spray",
      "labor_cost_per_acre": 4500.0,
      "labor_desc": "Broadcasting / line sowing in delta rice fallows, inter-cultivation",
      "harvest_logistics_per_acre": 3200.0,
      "harvest_desc": "Manual plant pulling, threshing machine operation & grain grading",
      "yield_quintals_per_acre": 4.8,
      "mandi_price_per_quintal": 8200.0,
      "cycle_days": 70,
      "water_req_mm": 280.0,
      "optimal_soil": "Cauvery Alluvial Clay Loam",
      "optimal_ph_min": 6.2,
      "optimal_ph_max": 7.5,
      "is_legume": true,
      "heat_tolerance": "High",
      "moisture_need": "Low-Moderate",
    },
    "Chillies (Milagai)": {
      "seed_cost_per_acre": 4500.0,
      "seed_desc": "TNAU K2 / Ramnad Mundu chilli seedlings raised in shade net",
      "fertilizer_cost_per_acre": 9200.0,
      "fert_desc": "NPK 100:50:50 kg/ha split fertigation + micronutrient spray",
      "irrigation_cost_per_acre": 5200.0,
      "irrig_desc": "Drip fertigation with silver-black mulch sheet",
      "protection_cost_per_acre": 5800.0,
      "protect_desc": "Thrips & mite management using blue/yellow sticky traps & bio-spray",
      "labor_cost_per_acre": 11000.0,
      "labor_desc": "Ridge bed making, transplantation, hand weeding & 4-5 pickings",
      "harvest_logistics_per_acre": 4800.0,
      "harvest_desc": "Sun drying on clean tarpaulins, cleaning, sorting & gunny packaging",
      "yield_quintals_per_acre": 16.0,
      "mandi_price_per_quintal": 18500.0,
      "cycle_days": 150,
      "water_req_mm": 500.0,
      "optimal_soil": "Red Sandy Loam",
      "optimal_ph_min": 6.0,
      "optimal_ph_max": 7.5,
      "is_legume": false,
      "heat_tolerance": "High",
      "moisture_need": "Moderate",
    },
    "Coconut (Thennai)": {
      "seed_cost_per_acre": 9000.0,
      "seed_desc": "TNAU Certified West Coast Tall / Pollachi Green Dwarf seedlings",
      "fertilizer_cost_per_acre": 8500.0,
      "fert_desc": "Basal Neem cake (5kg/palm) + NPK 500:320:1200g/tree/year + Borax",
      "irrigation_cost_per_acre": 6000.0,
      "irrig_desc": "Circular basin / drip button emitter (80-100 L/palm/day)",
      "protection_cost_per_acre": 4200.0,
      "protect_desc": "Rhinoceros beetle pheromone traps + Rugose whitefly bio-wash",
      "labor_cost_per_acre": 7500.0,
      "labor_desc": "Basin digging, ring manuring, palm climbing & bunch cutting",
      "harvest_logistics_per_acre": 4500.0,
      "harvest_desc": "Nut de-husking, copra drying & Pollachi mandi transport",
      "yield_quintals_per_acre": 65.0,
      "mandi_price_per_quintal": 3200.0,
      "cycle_days": 365,
      "water_req_mm": 1100.0,
      "optimal_soil": "Red Sandy Loam",
      "optimal_ph_min": 5.5,
      "optimal_ph_max": 8.0,
      "is_legume": false,
      "heat_tolerance": "High",
      "moisture_need": "Moderate",
    },
  };

  /// Evaluates Zone IoT telemetry + IMD weather + occupancy state to recommend the optimal crop.
  static String recommendBestCropForZone({
    required FieldZone zone,
    required ImdWeatherData weather,
    required FarmerProfile farmer,
    required double budgetInr,
    required double areaAcres,
  }) {
    final scoredCrops = evaluateAllCropSuitabilities(
      zone: zone,
      weather: weather,
      farmer: farmer,
      budgetInr: budgetInr,
      areaAcres: areaAcres,
    );

    scoredCrops.sort((a, b) => b.score.compareTo(a.score));
    return scoredCrops.first.cropName;
  }

  /// Calculates suitability score (0-100) for every candidate crop
  static List<ScoredCrop> evaluateAllCropSuitabilities({
    required FieldZone zone,
    required ImdWeatherData weather,
    required FarmerProfile farmer,
    required double budgetInr,
    required double areaAcres,
  }) {
    final budgetPerAcre = budgetInr / (areaAcres > 0 ? areaAcres : 1.0);
    final isFallow = zone.isEmptyPlot;
    final soilTextureLower = zone.soilTexture.toLowerCase();
    final prevCrop = zone.previousHarvestedCrop.toLowerCase();

    final List<ScoredCrop> results = [];

    cropBenchmarks.forEach((cropName, b) {
      double score = 75.0;

      // 1. Soil Texture Alignment
      final optSoil = (b['optimal_soil'] as String).toLowerCase();
      if (soilTextureLower.contains(optSoil) || optSoil.contains(soilTextureLower.split(' ')[0])) {
        score += 10.0;
      }

      // 2. Soil pH Tolerances
      final phMin = b['optimal_ph_min'] as double;
      final phMax = b['optimal_ph_max'] as double;
      if (zone.soilPh >= phMin && zone.soilPh <= phMax) {
        score += 8.0;
      } else {
        score -= ((zone.soilPh < phMin ? phMin - zone.soilPh : zone.soilPh - phMax) * 12.0);
      }

      // 3. Soil Moisture & Evapotranspiration
      final moistureNeed = b['moisture_need'] as String;
      if (zone.soilMoisturePct < 26.0) {
        // Soil is dry/water deficit
        if (moistureNeed.contains('Low')) score += 8.0;
        if (moistureNeed.contains('High')) score -= 14.0;
      } else if (zone.soilMoisturePct > 36.0) {
        // Soil is saturated/heavy
        if (moistureNeed.contains('High')) score += 8.0;
        if (moistureNeed.contains('Low')) score -= 10.0;
      }

      // 4. Residual NPK Chemistry
      final isLegume = b['is_legume'] as bool;
      if (zone.nitrogenKgHa < 120.0) {
        // Soil is deficient in Nitrogen -> Boost Legumes to fix nitrogen
        if (isLegume) score += 12.0;
      } else if (zone.nitrogenKgHa > 150.0) {
        // High nitrogen -> Great for cereals & vegetables
        if (!isLegume) score += 6.0;
      }

      // 5. Weather & Temperature Conditions
      final temp = weather.temperatureC;
      final heatTol = b['heat_tolerance'] as String;
      if (temp > 33.0) {
        if (heatTol.contains('High')) score += 7.0;
        if (heatTol.contains('Low')) score -= 16.0; // Potato in high heat fails
      } else if (temp < 24.0) {
        if (heatTol.contains('Low')) score += 8.0;
      }

      // 6. 24h Rain Forecast & Foliar Disease Threat
      if (weather.rainfallMm24h > 15.0 || weather.humidityPct > 70.0) {
        // High fungal risk -> penalize sensitive horticultural crops
        if (cropName == 'Tomato' || cropName == 'Bell Pepper') {
          score -= 8.0;
        }
      }

      // 7. Crop Rotation & Empty/Filled Logic
      if (isFallow) {
        // For empty fallow plots:
        if (prevCrop.contains('groundnut') || prevCrop.contains('legume')) {
          // Following legume with cereal (Maize/Rice) is agronomic gold standard!
          if (cropName.contains('Maize') || cropName.contains('Rice')) score += 10.0;
        } else {
          // If unplanted or previous cereal, planting a legume restores fertility
          if (isLegume) score += 9.0;
        }
      } else {
        // For filled active plots:
        // Do not recommend the exact same standing crop to avoid mono-cropping!
        if (zone.crop.toLowerCase().contains(cropName.toLowerCase())) {
          score -= 15.0; // Discourage repeat crop immediately
        }
      }

      // 8. Financial Capital Constraint
      final baseCostPerAcre = (b['seed_cost_per_acre'] as double) +
          (b['fertilizer_cost_per_acre'] as double) +
          (b['irrigation_cost_per_acre'] as double) +
          (b['protection_cost_per_acre'] as double) +
          (b['labor_cost_per_acre'] as double) +
          (b['harvest_logistics_per_acre'] as double);

      if (budgetPerAcre < baseCostPerAcre * 0.85) {
        score -= 18.0; // Unaffordable
      } else if (budgetPerAcre >= baseCostPerAcre) {
        score += 5.0; // Well within budget
      }

      // 9. Hardware Node TinyML On-Device Decision
      final tinymlDecision = zone.tinymlEdgeDecision.toLowerCase();
      if (tinymlDecision.contains('stress') || tinymlDecision.contains('moisture deficit')) {
        if (b['moisture_need'] == 'High') {
          score -= 12.0; // Penalize water-heavy crops when hardware TinyML flags water stress
        } else if (b['heat_tolerance'] == 'High' || (b['moisture_need'] as String).contains('Low')) {
          score += 6.0; // Boost drought-hardy crops
        }
      } else if (tinymlDecision.contains('fungal') || tinymlDecision.contains('spore alert')) {
        if (cropName == 'Tomato' || cropName == 'Potato' || cropName == 'Bell Pepper') {
          score -= 10.0; // Penalize blight/rot prone horticultural crops
        }
      } else if (tinymlDecision.contains('waterlog') || tinymlDecision.contains('saturation')) {
        if (cropName == 'Paddy (Rice)') {
          score += 8.0; // Paddy thrives in heavy saturation
        } else if (cropName == 'Groundnut' || cropName == 'Potato') {
          score -= 14.0; // Rot risk in standing water
        }
      }

      final finalScore = score.clamp(45.0, 97.0).round();
      results.add(ScoredCrop(cropName: cropName, score: finalScore));
    });

    return results;
  }

  /// Generates a comprehensive quotation for the selected zone
  static CropQuotationResponseModel generateQuotationForZone({
    required FieldZone zone,
    required ImdWeatherData weather,
    required FarmerProfile farmer,
    required double areaAcres,
    required double budgetInr,
    String? customCropOverride,
    String season = 'Kharif',
  }) {
    // 1. Run AI recommendation
    final scoredCrops = evaluateAllCropSuitabilities(
      zone: zone,
      weather: weather,
      farmer: farmer,
      budgetInr: budgetInr,
      areaAcres: areaAcres,
    );
    scoredCrops.sort((a, b) => b.score.compareTo(a.score));

    final recommendedCropName = scoredCrops.first.cropName;
    final altCropName = scoredCrops.length > 1 ? scoredCrops[1].cropName : "Maize (Corn)";

    // 2. Generate financial summary for recommended crop
    final recSummary = _buildCropFinancialSummary(
      cropName: recommendedCropName,
      suitabilityScore: scoredCrops.first.score,
      zone: zone,
      weather: weather,
      areaAcres: areaAcres,
      budgetInr: budgetInr,
    );

    // 3. Alternative summary
    final altSummary = _buildCropFinancialSummary(
      cropName: altCropName,
      suitabilityScore: scoredCrops.length > 1 ? scoredCrops[1].score : 80,
      zone: zone,
      weather: weather,
      areaAcres: areaAcres,
      budgetInr: budgetInr,
    );

    // 4. Comparison if overridden by farmer
    CropVarianceDiffModel? comparison;
    if (customCropOverride != null && customCropOverride.isNotEmpty) {
      final overrideScore = scoredCrops.firstWhere(
        (c) => c.cropName.toLowerCase() == customCropOverride.toLowerCase(),
        orElse: () => ScoredCrop(cropName: customCropOverride, score: 70),
      ).score;

      final overrideSummary = _buildCropFinancialSummary(
        cropName: customCropOverride,
        suitabilityScore: overrideScore,
        zone: zone,
        weather: weather,
        areaAcres: areaAcres,
        budgetInr: budgetInr,
      );

      comparison = _compareCropVariance(recSummary, overrideSummary, zone, weather);
    }

    return CropQuotationResponseModel(
      zoneId: zone.id,
      zoneName: zone.name,
      zoneHardwareType: "${zone.hardwareNode} • TinyML: ${zone.tinymlEdgeDecision}",
      areaAcres: areaAcres,
      budgetInr: budgetInr,
      recommendedCrop: recSummary,
      alternativeCrop: altSummary,
      comparisonIfChanged: comparison,
      allSupportedCrops: cropBenchmarks.keys.toList(),
      timestamp: DateTime.now().toIso8601String(),
      tinymlDecision: zone.tinymlEdgeDecision,
    );
  }

  static CropFinancialSummaryModel _buildCropFinancialSummary({
    required String cropName,
    required int suitabilityScore,
    required FieldZone zone,
    required ImdWeatherData weather,
    required double areaAcres,
    required double budgetInr,
  }) {
    final b = cropBenchmarks[cropName] ?? cropBenchmarks["Tomato"]!;
    final isFallow = zone.isEmptyPlot;

    // Dynamic fertilizer adjustment based on live Zone NPK levels
    double fertAdj = 1.0;
    if (zone.nitrogenKgHa > 135.0 && zone.potassiumKgHa > 165.0) {
      fertAdj = 0.90; // 10% saving due to rich residual NPK
    } else if (zone.nitrogenKgHa < 110.0 || zone.potassiumKgHa < 125.0) {
      fertAdj = 1.12; // 12% extra basal fertilizer needed
    }

    // Land preparation labor is slightly higher if preparing fallow land
    double laborAdj = isFallow ? 1.10 : 0.95;

    // Irrigation pumping energy adjusted based on soil moisture and TinyML decision
    double irrigAdj = zone.soilMoisturePct < 26.0 ? 1.15 : (zone.soilMoisturePct > 36.0 ? 0.88 : 1.0);
    double protectAdj = 1.0;
    final tinymlDecision = zone.tinymlEdgeDecision.toLowerCase();
    if (tinymlDecision.contains('stress') || tinymlDecision.contains('moisture deficit')) {
      irrigAdj *= 1.10; // Extra 10% booster pumping energy for live water stress
    } else if (tinymlDecision.contains('fungal') || tinymlDecision.contains('spore alert')) {
      protectAdj = 1.15; // +15% preventive bio-fungicide
    }

    final seedCostPerAcre = b['seed_cost_per_acre'] as double;
    final fertCostPerAcre = (b['fertilizer_cost_per_acre'] as double) * fertAdj;
    final irrigCostPerAcre = (b['irrigation_cost_per_acre'] as double) * irrigAdj;
    final protectCostPerAcre = (b['protection_cost_per_acre'] as double) * protectAdj;
    final laborCostPerAcre = (b['labor_cost_per_acre'] as double) * laborAdj;
    final harvestCostPerAcre = b['harvest_logistics_per_acre'] as double;

    final costPerAcre = (seedCostPerAcre + fertCostPerAcre + irrigCostPerAcre + protectCostPerAcre + laborCostPerAcre + harvestCostPerAcre).roundToDouble();
    final totalCost = (costPerAcre * areaAcres).roundToDouble();

    final totalYield = ((b['yield_quintals_per_acre'] as double) * areaAcres).roundToDouble();
    final mandiPrice = b['mandi_price_per_quintal'] as double;
    final grossRev = (totalYield * mandiPrice).roundToDouble();
    final profit = (grossRev - totalCost).roundToDouble();
    final roi = totalCost > 0 ? ((profit / totalCost) * 100.0).roundToDouble() : 0.0;
    final surplusDeficit = (budgetInr - totalCost).roundToDouble();

    final status = surplusDeficit >= 0
        ? (surplusDeficit >= budgetInr * 0.2 ? "Comfortable Surplus (+₹${surplusDeficit.toStringAsFixed(0)})" : "Within Budget")
        : "Budget Deficit (-₹${(-surplusDeficit).toStringAsFixed(0)})";

    final lineItems = [
      QuotationLineItemModel(
        category: "Seed & Nursery",
        itemName: b['seed_desc'].toString().split("(")[0].trim(),
        costPerAcre: seedCostPerAcre,
        totalCost: seedCostPerAcre * areaAcres,
        details: b['seed_desc'].toString(),
      ),
      QuotationLineItemModel(
        category: "Fertilizer & Soil Nutrition",
        itemName: "Basal + Water Soluble Fertigation",
        costPerAcre: fertCostPerAcre.roundToDouble(),
        totalCost: (fertCostPerAcre * areaAcres).roundToDouble(),
        details: "${b['fert_desc']} (Adjusted for Zone NPK: N=${zone.nitrogenKgHa.toInt()}, P=${zone.phosphorusKgHa.toInt()}, K=${zone.potassiumKgHa.toInt()} kg/ha)",
      ),
      QuotationLineItemModel(
        category: "Micro-Irrigation & Energy",
        itemName: "Root-Zone Drip & Pumping Energy",
        costPerAcre: irrigCostPerAcre.roundToDouble(),
        totalCost: (irrigCostPerAcre * areaAcres).roundToDouble(),
        details: "${b['irrig_desc']} (Calibrated to live soil moisture ${zone.soilMoisturePct.toStringAsFixed(1)}%)",
      ),
      QuotationLineItemModel(
        category: "Crop Protection & Bio-Inputs",
        itemName: "Biologicals & IPM Shield",
        costPerAcre: protectCostPerAcre,
        totalCost: protectCostPerAcre * areaAcres,
        details: b['protect_desc'].toString(),
      ),
      QuotationLineItemModel(
        category: "Field Labor & Operations",
        itemName: isFallow ? "Deep Tillage, Furrow & Operations" : "Inter-culture, Weeding & Operations",
        costPerAcre: laborCostPerAcre.roundToDouble(),
        totalCost: (laborCostPerAcre * areaAcres).roundToDouble(),
        details: "${b['labor_desc']} (${isFallow ? 'Includes pre-sowing deep ploughing' : 'Maintenance of standing plot'})",
      ),
      QuotationLineItemModel(
        category: "Harvesting & Mandi Logistics",
        itemName: "Harvesting, Grading & Mandi Freight",
        costPerAcre: harvestCostPerAcre,
        totalCost: harvestCostPerAcre * areaAcres,
        details: b['harvest_desc'].toString(),
      ),
    ];

    final compatibility = "$suitabilityScore% AI Match • ${zone.soilTexture} (pH ${zone.soilPh.toStringAsFixed(1)}, Moisture ${zone.soilMoisturePct.toStringAsFixed(1)}%)";

    return CropFinancialSummaryModel(
      cropName: cropName,
      suitabilityScore: suitabilityScore,
      zoneCompatibility: compatibility,
      costPerAcre: costPerAcre,
      totalEstimatedCost: totalCost,
      budgetSurplusDeficit: surplusDeficit,
      budgetStatus: status,
      expectedYieldQuintalsPerAcre: b['yield_quintals_per_acre'] as double,
      totalExpectedYieldQuintals: totalYield,
      expectedMandiPricePerQuintal: mandiPrice,
      projectedGrossRevenue: grossRev,
      projectedNetProfit: profit,
      projectedRoiPercent: roi,
      growingCycleDays: b['cycle_days'] as int,
      waterRequirementMm: b['water_req_mm'] as double,
      lineItems: lineItems,
      zoneIotContext: {
        "zone_id": zone.id,
        "zone_name": zone.name,
        "hardware_node": zone.hardwareNode,
        "tinyml_edge_decision": zone.tinymlEdgeDecision,
        "is_fallow": isFallow,
        "soil_type": zone.soilTexture,
        "soil_ph": zone.soilPh,
        "soil_moisture": "${zone.soilMoisturePct.toStringAsFixed(1)}%",
        "soil_npk": "N:${zone.nitrogenKgHa.toInt()} | P:${zone.phosphorusKgHa.toInt()} | K:${zone.potassiumKgHa.toInt()} kg/ha",
        "weather_temp": "${weather.temperatureC.toStringAsFixed(1)}°C",
        "weather_humidity": "${weather.humidityPct.toStringAsFixed(0)}%",
      },
    );
  }

  static CropVarianceDiffModel _compareCropVariance(
    CropFinancialSummaryModel rec,
    CropFinancialSummaryModel chosen,
    FieldZone zone,
    ImdWeatherData weather,
  ) {
    final costDiff = chosen.totalEstimatedCost - rec.totalEstimatedCost;
    final costDiffPct = rec.totalEstimatedCost > 0 ? (costDiff / rec.totalEstimatedCost) * 100.0 : 0.0;
    final profitDiff = chosen.projectedNetProfit - rec.projectedNetProfit;
    final roiDiff = chosen.projectedRoiPercent - rec.projectedRoiPercent;
    final waterDiff = chosen.waterRequirementMm - rec.waterRequirementMm;
    final suitabilityDiff = rec.suitabilityScore - chosen.suitabilityScore;

    final List<String> tradeoffs = [];
    if (costDiff > 0) {
      tradeoffs.add("Requires ₹${costDiff.toStringAsFixed(0)} (+${costDiffPct.toStringAsFixed(1)}%) more upfront capital.");
    } else if (costDiff < 0) {
      tradeoffs.add("Saves ₹${(-costDiff).toStringAsFixed(0)} (${(-costDiffPct).toStringAsFixed(1)}%) in initial cultivation expenses.");
    }

    if (profitDiff > 0) {
      tradeoffs.add("Higher upside with ₹${profitDiff.toStringAsFixed(0)} additional projected net profit.");
    } else if (profitDiff < 0) {
      tradeoffs.add("Yields ₹${(-profitDiff).toStringAsFixed(0)} lower projected net profit than AI recommendation (${rec.cropName}).");
    }

    if (waterDiff > 0) {
      tradeoffs.add("Consumes ${waterDiff.toStringAsFixed(0)} mm more irrigation water volume.");
    } else if (waterDiff < 0) {
      tradeoffs.add("Conserves ${(-waterDiff).toStringAsFixed(0)} mm water volume — better water resilience.");
    }

    if (suitabilityDiff > 0) {
      tradeoffs.add("Zone soil & weather suitability score drops by $suitabilityDiff% for ${chosen.cropName}.");
    }

    String verdict;
    if (chosen.cropName == rec.cropName) {
      verdict = "${rec.cropName} is already the optimal scientific and financial choice for ${zone.name}.";
    } else if (profitDiff >= 0 && chosen.suitabilityScore >= 75) {
      verdict = "${chosen.cropName} is a viable commercial alternative, provided you have sufficient investment budget and strict micro-irrigation scheduling.";
    } else {
      verdict = "AI strongly advises sticking with ${rec.cropName}. It delivers higher ROI (+${rec.projectedRoiPercent.toStringAsFixed(0)}%) with superior alignment to ${zone.soilTexture} (pH ${zone.soilPh.toStringAsFixed(1)}) and current weather (${weather.temperatureC.toStringAsFixed(1)}°C).";
    }

    return CropVarianceDiffModel(
      suggestedCrop: rec.cropName,
      selectedCrop: chosen.cropName,
      costDifferenceInr: costDiff,
      costDifferencePercent: costDiffPct,
      profitDifferenceInr: profitDiff,
      roiDifferencePercent: roiDiff,
      waterDemandDifferenceMm: waterDiff,
      suitabilityDropPercent: suitabilityDiff > 0 ? suitabilityDiff : 0,
      keyTradeoffs: tradeoffs,
      aiAgronomistVerdict: verdict,
    );
  }
}

class ScoredCrop {
  final String cropName;
  final int score;

  ScoredCrop({required this.cropName, required this.score});
}
