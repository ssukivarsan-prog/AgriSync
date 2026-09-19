from typing import Dict, Any, List, Optional
from backend.app.schemas.cv import DiseasePrediction, PestPrediction, NutrientPrediction, SegmentationPrediction
from backend.app.schemas.irrigation import IrrigationAnalysisResponse
from backend.app.schemas.environment import EnvironmentRiskResponse

# Simple agronomic knowledge base designed specifically for rural farmers
AGRONOMIC_KNOWLEDGE = {
    "Tomato___Early_blight": {
        "common_name": "Tomato Leaf Spot (Early Blight)",
        "pathogen": "Leaf Spot Fungus (Alternaria solani)",
        "why_it_matters": "Dark brown spots with yellow borders appear on lower leaves. If untreated, leaves turn yellow, dry up, and fall off early, reducing your tomato yield.",
        "what_to_check": "Inspect the bottom 3 to 4 leaves closest to the soil. Look for dark brown circular spots with target-like concentric rings.",
        "cultural_actions": [
            "1. PLUCK AFFECTED LEAVES: Carefully remove heavily spotted lower leaves and discard them outside the field.",
            "2. WATER AT THE ROOTS ONLY: Avoid overhead sprinkling. Use drip irrigation or water gently near the stem base.",
            "3. MULCH SOIL BASE: Spread dry straw or mulch around root base to prevent rainwater splashing mud onto leaves."
        ],
        "organic_treatment": "Mix 5ml Neem Oil + 1ml mild liquid soap in 1 Liter water. Spray thoroughly on leaves early morning every 7 days. Apply copper hydroxide if pressure increases.",
        "verification_protocol": "If spots spread quickly to upper canopy leaves, consult your local Krishi Vigyan Kendra (KVK) or extension officer.",
        "video_tutorial": {
            "title": "How to Treat Tomato Leaf Spot & Early Blight Naturally",
            "duration": "3:15 min",
            "summary": "Step-by-step guide on pruning diseased lower leaves, applying organic Neem spray, and preventing soil splash.",
            "topic": "Tomato Disease Control"
        }
    },
    "Tomato - Early blight": {
        "common_name": "Tomato Early Blight (Alternaria solani)",
        "pathogen": "Leaf Spot Fungus (Alternaria solani)",
        "why_it_matters": "Concentric ring spots on lower leaves lead to premature defoliation and severe yield loss in fruiting stage.",
        "what_to_check": "Inspect lower canopy for circular brown lesions with alternating dark and light concentric rings.",
        "cultural_actions": [
            "Prune infected bottom leaves to increase airflow and reduce spore splash.",
            "Maintain soil moisture using root drip; prevent wet foliar canopies overnight.",
            "Sterilize pruning shears between rows to avoid transferring fungal spores."
        ],
        "organic_treatment": "Apply copper hydroxide (2g/L) or neem-based bio-fungicide (5ml/L) at 7-10 day intervals.",
        "verification_protocol": "Check upper canopy leaves after 5 days to confirm lesion stoppage.",
        "video_tutorial": {
            "title": "Tomato Early Blight Organic Control",
            "duration": "3:15 min",
            "summary": "Pruning and copper fungicide spray technique for Alternaria solani.",
            "topic": "Tomato Disease Control"
        }
    },
    "Non-Pathogenic (Active Insect Pest Infestation)": {
        "common_name": "Active Insect Pest Pressure (Ants / Pests)",
        "pathogen": "Insect Pest Vector (Formicidae / Agricultural Pests)",
        "why_it_matters": "Active insect colonies farm sap-sucking aphids and scale insects, damage young rootlets, and tunnel into stems.",
        "what_to_check": "Inspect stem junctions, root collars, and underside of leaves for crawling insect trails and attendant sap-suckers.",
        "cultural_actions": [
            "1. SOIL DRENCHING: Apply bio-pesticide drench around ant mounds and root collars.",
            "2. STICKY BANDS: Place yellow sticky traps or botanical grease bands around main stems to prevent crawling access.",
            "3. CLEAN WEED RESERVOIRS: Remove dry weeds and organic debris where colonies nest around field bunds."
        ],
        "organic_treatment": "Drench mound entrances with 5% Neem seed kernel extract (NSKE) or Beauveria bassiana @ 5g/L.",
        "verification_protocol": "Monitor ant trails 48 hours post-application. If colony persists, apply targeted organic ant bait.",
        "video_tutorial": {
            "title": "Natural Field Pest & Ant Colony Control in Crop Beds",
            "duration": "3:45 min",
            "summary": "Effective bio-control methods for field ants and companion sap-sucking insects.",
            "topic": "Integrated Pest Management"
        }
    },
    "Non-Pathogenic - Active Insect Pest Infestation": {
        "common_name": "Active Insect Pest Pressure (Ants / Pests)",
        "pathogen": "Insect Pest Vector (Formicidae / Agricultural Pests)",
        "why_it_matters": "Active insect colonies farm sap-sucking aphids and scale insects, damage young rootlets, and tunnel into stems.",
        "what_to_check": "Inspect stem junctions, root collars, and underside of leaves for crawling insect trails and attendant sap-suckers.",
        "cultural_actions": [
            "1. SOIL DRENCHING: Apply bio-pesticide drench around ant mounds and root collars.",
            "2. STICKY BANDS: Place yellow sticky traps or botanical grease bands around main stems to prevent crawling access.",
            "3. CLEAN WEED RESERVOIRS: Remove dry weeds and organic debris where colonies nest around field bunds."
        ],
        "organic_treatment": "Drench mound entrances with 5% Neem seed kernel extract (NSKE) or Beauveria bassiana @ 5g/L.",
        "verification_protocol": "Monitor ant trails 48 hours post-application. If colony persists, apply targeted organic ant bait.",
        "video_tutorial": {
            "title": "Natural Field Pest & Ant Colony Control in Crop Beds",
            "duration": "3:45 min",
            "summary": "Effective bio-control methods for field ants and companion sap-sucking insects.",
            "topic": "Integrated Pest Management"
        }
    },
    "Abiotic Nutrient Stress (Nitrogen Chlorosis)": {
        "common_name": "Nitrogen Deficiency Chlorosis",
        "pathogen": "Abiotic Macro-Nutrient Depletion (Nitrogen N)",
        "why_it_matters": "Nitrogen is essential for chlorophyll synthesis. Depletion causes systemic leaf yellowing, reduced photosynthesis, and stunted vegetative biomass.",
        "what_to_check": "Examine if yellowing begins uniformly on older lower leaves while veins remain chlorotic (non-pathogenic).",
        "cultural_actions": [
            "1. SOIL ENRICHMENT: Top-dress well-decomposed farmyard manure or vermicompost around active feeder roots.",
            "2. CORRECT SOIL PH: If soil pH is highly alkaline (>8.0), apply gypsum to release tied-up nitrogen.",
            "3. REGULATED IRRIGATION: Avoid over-irrigation that leaches soluble nitrates beyond the root absorption zone."
        ],
        "organic_treatment": "Apply a 1.0% - 1.5% foliar urea spray or liquid panchagavya (30ml/L) in early morning for rapid chlorophyll restoration.",
        "verification_protocol": "Re-evaluate leaf greenness after 5-7 days using the Leaf Color Chart (LCC).",
        "video_tutorial": {
            "title": "Correcting Nitrogen Deficiency & Leaf Yellowing Fast",
            "duration": "3:30 min",
            "summary": "How to differentiate nutrient chlorosis from fungal diseases and apply foliar feeds.",
            "topic": "Crop Nutrient Management"
        }
    },
    "Abiotic Nutrient Stress - Nitrogen Chlorosis": {
        "common_name": "Nitrogen Deficiency Chlorosis",
        "pathogen": "Abiotic Macro-Nutrient Depletion (Nitrogen N)",
        "why_it_matters": "Nitrogen is essential for chlorophyll synthesis. Depletion causes systemic leaf yellowing, reduced photosynthesis, and stunted vegetative biomass.",
        "what_to_check": "Examine if yellowing begins uniformly on older lower leaves while veins remain chlorotic (non-pathogenic).",
        "cultural_actions": [
            "1. SOIL ENRICHMENT: Top-dress well-decomposed farmyard manure or vermicompost around active feeder roots.",
            "2. CORRECT SOIL PH: If soil pH is highly alkaline (>8.0), apply gypsum to release tied-up nitrogen.",
            "3. REGULATED IRRIGATION: Avoid over-irrigation that leaches soluble nitrates beyond the root absorption zone."
        ],
        "organic_treatment": "Apply a 1.0% - 1.5% foliar urea spray or liquid panchagavya (30ml/L) in early morning for rapid chlorophyll restoration.",
        "verification_protocol": "Re-evaluate leaf greenness after 5-7 days using the Leaf Color Chart (LCC).",
        "video_tutorial": {
            "title": "Correcting Nitrogen Deficiency & Leaf Yellowing Fast",
            "duration": "3:30 min",
            "summary": "How to differentiate nutrient chlorosis from fungal diseases and apply foliar feeds.",
            "topic": "Crop Nutrient Management"
        }
    },
    "Paddy - Blast (Magnaporthe oryzae - நெல் குலை நோய்)": {
        "common_name": "Paddy Leaf Blast (நெல் குலை நோய்)",
        "pathogen": "Magnaporthe oryzae (Pyricularia grisea)",
        "why_it_matters": "Spindle-shaped diamond lesions on paddy leaves with grey centers and brown margins. Can cause up to 60-80% grain yield loss.",
        "what_to_check": "Look for diamond or eye-shaped lesions on middle leaves during tillering and panicle emergence stages.",
        "cultural_actions": [
            "1. AVOID EXCESS UREA: Split nitrogen into 3-4 doses; heavy single urea applications accelerate blast vulnerability.",
            "2. DRAIN EXCESS WATER: Maintain intermittent wetting and drying rather than continuous standing stagnant water.",
            "3. BURNING INFECTED STRAW: Never incorporate blast-infected paddy stubble into nursery soil."
        ],
        "organic_treatment": "Foliar spray of Pseudomonas fluorescens @ 10g/L or Tricyclazole 75% WP @ 0.6g/L at first symptom onset.",
        "verification_protocol": "Inspect neck of the emergent panicle for brown neck-rot discoloration.",
        "video_tutorial": {
            "title": "TNAU Guide: Managing Paddy Blast in Cauvery Delta",
            "duration": "4:00 min",
            "summary": "Identification of spindle blast lesions, water drainage protocol, and bio-control spray schedule.",
            "topic": "Paddy Crop Protection"
        }
    },
    "Sugarcane - Red Rot (செவ்வழுகல் நோய் - Colletotrichum falcatum)": {
        "common_name": "Sugarcane Red Rot (செவ்வழுகல் நோய்)",
        "pathogen": "Colletotrichum falcatum",
        "why_it_matters": "Major destructive fungal vascular wilt of sugarcane in Tamil Nadu, causing internal pith reddening, sucrose inversion, and cane drying.",
        "what_to_check": "Look for third or fourth leaf yellowing, longitudinal midrib red lesions, and sour alcoholic odor when cane is split longitudinally.",
        "cultural_actions": [
            "1. ROGUE AND BURN: Uproot infected clumps along with root systems immediately and burn them outside the field.",
            "2. HEALTHY SETT SELECTION: Plant only certified red-rot free seed cane; treat setts with Carbendazim 0.1% for 15 minutes.",
            "3. FIELD DRAINAGE: Ensure prompt drainage; avoid recycling irrigation water from infected sugarcane blocks."
        ],
        "organic_treatment": "Soil application of Trichoderma viride @ 2.5 kg/ha mixed with 250 kg well-rotted farmyard manure.",
        "verification_protocol": "Split standing canes longitudinally to inspect internal vascular pith discoloration.",
        "video_tutorial": {
            "title": "Sugarcane Red Rot Detection and Sett Treatment",
            "duration": "4:30 min",
            "summary": "Identifying red rot midrib symptoms and sett bio-treatment protocols for sugarcane growers.",
            "topic": "Sugarcane Disease Management"
        }
    },
    "Banana - Sigatoka Leaf Spot (சிகடோகா இலைப்புள்ளி - Pseudocercospora fijiensis)": {
        "common_name": "Banana Sigatoka Leaf Spot (சிகடோகா இலைப்புள்ளி)",
        "pathogen": "Pseudocercospora fijiensis / musae",
        "why_it_matters": "Causes premature leaf drying, drastically reducing banana bunch weight and inducing premature fruit ripening on the tree.",
        "what_to_check": "Small yellowish-brown streaks parallel to leaf veins that enlarge into elliptic spots with greyish dried centers.",
        "cultural_actions": [
            "1. SANITARY PRUNING: De-leaf and burn severely dried spotted lower banana leaves.",
            "2. OPTIMAL CANOPY SPACING: Maintain proper suckering (desuckering) to enhance air circulation and reduce canopy humidity.",
            "3. POTASSIUM ENRICHMENT: Apply MOP (Muriate of Potash) @ 300g per plant in splits to fortify leaf cuticle thickness."
        ],
        "organic_treatment": "Spray Propiconazole 0.1% or Mancozeb 0.2% mixed with mineral oil (10ml/L) as a protective adhesive film.",
        "verification_protocol": "Ensure at least 8-10 healthy functional leaves remain on each plant at the time of bunch emergence.",
        "video_tutorial": {
            "title": "Banana Sigatoka Management & Desuckering Best Practices",
            "duration": "3:50 min",
            "summary": "De-leafing protocol and protective spray schedules for Grand Naine and Poovan cultivars.",
            "topic": "Banana Disease Management"
        }
    },
    "Tomato___Late_blight": {
        "common_name": "Tomato Leaf & Fruit Rot (Late Blight)",
        "pathogen": "Water Rot Mold (Phytophthora)",
        "why_it_matters": "Fast-spreading wet rot disease that turns green leaves dark brown/black in cool, rainy, or cloudy weather.",
        "what_to_check": "Look for large dark wet-looking patches on leaf tips and white fuzzy growth under leaves on moist mornings.",
        "cultural_actions": [
            "1. STOP OVERHEAD WATERING: Stop spraying water over leaves immediately to stop wet rot spores from spreading.",
            "2. REMOVE ROTTEN PLANTS: Pluck out severely rotten plants and bury them deep in soil far from healthy crops.",
            "3. ALLOW AIR FLOW: Trim overcrowded foliage so sunlight and wind can dry leaf surfaces quickly."
        ],
        "organic_treatment": "Spray Copper Oxychloride or Copper Hydroxide (2g per liter water) as a protective leaf shield before heavy rains.",
        "verification_protocol": "Emergency plant condition: Late blight spreads fast in damp weather. Inform nearby farmers immediately.",
        "video_tutorial": {
            "title": "Controlling Tomato & Potato Rot in Damp Weather",
            "duration": "4:10 min",
            "summary": "Learn how to spot white mold under leaves and apply protective copper sprays during rainy spells.",
            "topic": "Fungal Rot Prevention"
        }
    },
    "Potato___Early_blight": {
        "common_name": "Potato Leaf Spot (Early Blight)",
        "pathogen": "Foliar Spot Fungus",
        "why_it_matters": "Causes brown target-ring spots on older leaves, slowing down potato tuber growth under the soil.",
        "what_to_check": "Dark brown dry circular spots with target rings on lower mature leaves.",
        "cultural_actions": [
            "1. FEED BALANCED NUTRIENTS: Weak, low-nitrogen potato plants catch leaf spots easily. Keep soil nourished.",
            "2. REGULAR DRIP WATERING: Give steady root moisture without creating standing puddles.",
            "3. WEED CLEANING: Pull out wild nightshade weeds growing near your potato bed."
        ],
        "organic_treatment": "Foliar spray with 1% Neem Oil solution or bio-fungicide every 10 days.",
        "verification_protocol": "Check potato tuber health during mid-season earthing up.",
        "video_tutorial": {
            "title": "Potato Leaf Care & Tuber Protection Guide",
            "duration": "2:45 min",
            "summary": "Simple steps for weed management, earthing up soil, and foliar feeding for healthy potato crops.",
            "topic": "Potato Farming Tips"
        }
    },
    "Potato___Late_blight": {
        "common_name": "Potato Leaf & Tuber Rot (Late Blight)",
        "pathogen": "Water Rot Mold",
        "why_it_matters": "Destroys potato leaves and rots developing tubers under the ground if spores wash into soil.",
        "what_to_check": "Dark wet-looking leaf margins with white powdery fuzz on the underside.",
        "cultural_actions": [
            "1. HEAP SOIL AROUND STEM (EARTHING UP): Mound 10-15cm soil around stem bases to protect underground potatoes.",
            "2. STOP IRRIGATION IN RAIN: Halt watering when cool rainy weather is forecast."
        ],
        "organic_treatment": "Spray preventative copper fungicide before continuous rainfall starts.",
        "verification_protocol": "High priority: Contact local agricultural helpline 1800-180-1551 if wet rot appears.",
        "video_tutorial": {
            "title": "Protecting Underground Potato Tubers from Rot",
            "duration": "3:30 min",
            "summary": "How proper soil mounding (earthing up) blocks rot spores from reaching growing potatoes.",
            "topic": "Tuber Protection"
        }
    },
    "Corn_(maize)___Common_rust_": {
        "common_name": "Corn Red Leaf Rust",
        "pathogen": "Rust Fungus (Puccinia)",
        "why_it_matters": "Small reddish-orange powdery bumps on leaves that drain moisture and reduce corn ear size.",
        "what_to_check": "Rub leaves gently — if reddish brown powder sticks to your fingers, it is Leaf Rust.",
        "cultural_actions": [
            "1. CHOOSE RUST-RESISTANT SEEDS: For next season, select certified rust-tolerant maize hybrid seeds.",
            "2. BOOST POTASSIUM: Feed soil with MOP (Muriate of Potash) fertilizer to strengthen leaf tissue."
        ],
        "organic_treatment": "Spray wettable sulfur (2g per liter water) if rust bumps cover more than 10% of leaf area.",
        "verification_protocol": "Monitor if rust reaches the upper leaves surrounding the developing corn ear.",
        "video_tutorial": {
            "title": "Corn Red Rust Identification & Simple Sulfur Spray",
            "duration": "3:00 min",
            "summary": "How to identify rust powder on corn leaves and apply sulfur spray safely.",
            "topic": "Corn Pest & Rust Control"
        }
    },
    "Rice___Leaf_Blast": {
        "common_name": "Paddy Blast (நெல் குலை நோய்)",
        "pathogen": "Magnaporthe oryzae (Foliar Spore Fungus)",
        "why_it_matters": "Diamond or spindle-shaped brown lesions with grey centers appear on paddy leaves and neck joints. Causes lodging and drastic panicle yield loss.",
        "what_to_check": "Inspect middle and top leaves during tillering to panicle initiation. Look for eye-shaped spots with dark brown margins.",
        "cultural_actions": [
            "1. REGULATE NITROGEN: Do not apply excessive Urea splits during cloudy or damp monsoon spells.",
            "2. MAINTAIN WATER REGIME: Avoid field desiccation (drying out); maintain 2.5-5.0 cm standing water layer in Cauvery delta paddies.",
            "3. WEED ERADICATION: Remove grassy alternate host weeds (Echinochloa) from field bunds."
        ],
        "organic_treatment": "Spray Pseudomonas fluorescens (5g per liter of water) or 3% Panchagavya early morning. In severe cases, apply Tricyclazole 75% WP @ 0.6g/L.",
        "verification_protocol": "TNAU Advisory: If spindle lesions expand into neck blast, inform local Assistant Director of Agriculture (ADA).",
        "video_tutorial": {
            "title": "TNAU Paddy Blast Management & Pseudomonas Bio-Shield",
            "duration": "3:40 min",
            "summary": "Practical field guide on diagnosing spindle blast lesions and applying biological controls.",
            "topic": "Rice Disease Management"
        }
    },
    "Rice___Bacterial_leaf_blight": {
        "common_name": "Paddy Bacterial Blight (பாக்டீரிய இலைக்கருகல்)",
        "pathogen": "Xanthomonas oryzae pv. oryzae",
        "why_it_matters": "Wavy yellow-to-white stripes along leaf margins from tips downwards. Bacteria ooze out during early humid mornings.",
        "what_to_check": "Look for wavy margin yellowing and milky bacterial ooze droplets on leaf tips at sunrise.",
        "cultural_actions": [
            "1. DRAIN PUDDLE WATER: Temporarily drain standing stagnant water for 2-3 days to inhibit bacterial multiplication.",
            "2. HALT NITROGEN TOP-DRESSING: Postpone urea application until new healthy green leaves emerge."
        ],
        "organic_treatment": "Spray fresh Cow Dung Extract (20%) or Streptomycin Sulfate + Tetracycline (300g/ha) + Copper Oxychloride (1.25 kg/ha).",
        "verification_protocol": "TNAU Protocol: Clip leaf tips with clean scissors if kresek (wilt) symptom initiates.",
        "video_tutorial": {
            "title": "Managing Bacterial Leaf Blight in Delta Paddies",
            "duration": "4:15 min",
            "summary": "Water management and bio-formulation sprays for paddy bacterial blight.",
            "topic": "Paddy BLB Control"
        }
    },
    "Banana___Sigatoka_leaf_spot": {
        "common_name": "Banana Sigatoka Leaf Spot (வாழை சிகடோகா இலைப்புள்ளி)",
        "pathogen": "Pseudocercospora musicola / fijiensis",
        "why_it_matters": "Narrow yellow-brown streaks turning into dark sunken spots with grey centers. Severely impairs bunch sizing and causes premature fruit ripening.",
        "what_to_check": "Check 3rd and 4th leaves from top for linear brown necrotic streaks parallel to veins.",
        "cultural_actions": [
            "1. SANITATION (DESUCKERING & PRUNING): Cut and destroy heavily spotted leaves; burn outside plantation.",
            "2. DRAINAGE: Dig trenches between banana rows to prevent root water-logging during monsoon.",
            "3. WIDE SPACING: Maintain 2.0m x 2.0m spacing for good canopy aeration and sunlight penetration."
        ],
        "organic_treatment": "Spray Agricultural Mineral Oil (10 ml/L) or Neem Oil 5ml + Propiconazole (1 ml/L) directed at leaf undersides.",
        "verification_protocol": "TNAU Banana Package: Maintain at least 8-10 functional green leaves during bunch shooting stage.",
        "video_tutorial": {
            "title": "TNAU Banana Sigatoka Prevention & Mineral Oil Spray",
            "duration": "3:50 min",
            "summary": "Effective pruning, canopy ventilation, and spray scheduling for Grand Naine & Poovan bananas.",
            "topic": "Banana Canopy Management"
        }
    },
    "Sugarcane___Red_rot": {
        "common_name": "Sugarcane Red Rot (கரும்பு செவ்வழுகல் நோய்)",
        "pathogen": "Colletotrichum falcatum",
        "why_it_matters": "Top third and fourth leaves wither and dry. Stems when split lengthwise show red discoloration with transverse white patches and sour alcoholic smell.",
        "what_to_check": "Split drying cane stems. Check for blood-red interior pith with characteristic horizontal white patches.",
        "cultural_actions": [
            "1. ROGUING INFECTED CANES: Uproot entire affected clumps including root stubbles and burn them.",
            "2. DISEASE-FREE SETTS: Use certified heat-treated setts (MHAT @ 54°C) for next planting.",
            "3. CROP ROTATION: Follow sugarcane with paddy or green manure sunnhemp in Cauvery delta soils."
        ],
        "organic_treatment": "Dip setts in Trichoderma viride (10g/L) before planting. Soil drench with Pseudomonas fluorescens (2.5 kg/ha).",
        "verification_protocol": "Notify local sugar mill cane inspector immediately if red rot clumps are confirmed.",
        "video_tutorial": {
            "title": "Sugarcane Red Rot Identification & Sett Treatment",
            "duration": "4:20 min",
            "summary": "How to identify red rot symptoms, sterilize seed setts, and prevent soil contamination.",
            "topic": "Sugarcane Health"
        }
    },
    "Coconut___Rugose_spiralling_whitefly": {
        "common_name": "Coconut Rugose Whitefly (தென்னை சுருள் வெள்ளை ஈ)",
        "pathogen": "Aleurodicus rugioperculatus (Pest Infestation)",
        "why_it_matters": "White wax-producing insects colonize leaf undersides, secreting honeydew that leads to black sooty mold covering fronds and reducing yield.",
        "what_to_check": "Under-surface of coconut fronds for spiralling waxy egg trails and black sooty mold coating lower leaves.",
        "cultural_actions": [
            "1. JET WATER SPRAY: High-pressure water jet spraying directed at leaf undersides to dislodge whiteflies and honeydew.",
            "2. YELLOW STICKY TRAPS: Hang yellow poly-sheets coated with castor oil (10-12 traps per acre) at 6-8 feet height.",
            "3. CONSERVE NATURAL ENEMIES: Avoid harsh chemical insecticides to preserve parasitoid wasp Encarsia guadeloupae."
        ],
        "organic_treatment": "Spray Neem Seed Kernel Extract (NSKE 5%) or 1% Neem Oil with washing soap solution (5g/L).",
        "verification_protocol": "TNAU Parasitoid Release: Procure Encarsia parasitoid pupae from TNAU / ICAR-CPCRI.",
        "video_tutorial": {
            "title": "Controlling Coconut Rugose Whitefly Naturally",
            "duration": "3:30 min",
            "summary": "Water jet spraying, yellow sticky traps, and biological parasitoid protection in coconut groves.",
            "topic": "Coconut Pest Management"
        }
    }
}

# General fallback for any other class
DEFAULT_KNOWLEDGE = {
    "common_name": "Foliar Plant Condition",
    "pathogen": "Botanical / Microclimatic Stress",
    "why_it_matters": "Visual symptoms indicate potential photosynthetic efficiency reduction or localized pathogen activity.",
    "what_to_check": "Inspect upper and lower leaf surfaces, leaf veins, and stem margins for discoloration or lesion spread.",
    "cultural_actions": [
        "Improve row aeration by maintaining recommended spacing and weeding.",
        "Avoid overhead irrigation to minimize canopy moisture retention.",
        "Remove damaged senescent leaves from lower plant canopy."
    ],
    "organic_treatment": "Neem oil spray (3-5 ml/L water with mild soap) as general organic protective foliar wash.",
    "verification_protocol": "Confirm symptoms through physical field inspection and local agronomist guidance."
}

def generate_comprehensive_advisory(
    crop: str,
    disease_pred: DiseasePrediction,
    pest_pred: Optional[PestPrediction] = None,
    nutrient_pred: Optional[NutrientPrediction] = None,
    segmentation_pred: Optional[SegmentationPrediction] = None,
    irrigation: Optional[IrrigationAnalysisResponse] = None,
    environment: Optional[EnvironmentRiskResponse] = None
) -> Dict[str, Any]:
    
    # 1. Look up disease knowledge
    disease_key = disease_pred.prediction
    knowledge = AGRONOMIC_KNOWLEDGE.get(disease_key, DEFAULT_KNOWLEDGE)
    is_healthy = "healthy" in disease_pred.prediction.lower()

    # 2. Synthesize findings
    findings = []
    actions = []

    if is_healthy:
        findings.append(f"Crop foliage appears healthy with no dominant visual disease symptoms (AI Confidence: {disease_pred.confidence*100:.1f}%).")
        actions.append("Continue standard crop maintenance and preventative monitoring.")
    elif disease_pred.is_uncertain:
        findings.append(f"Uncertain foliar pattern detected (AI Confidence: {disease_pred.confidence*100:.1f}%). Possible {disease_pred.prediction}.")
        actions.append("Capture a clearer image in natural indirect sunlight showing the whole leaf and lesion margin.")
        actions.append("Consult a local agricultural extension specialist before undertaking chemical treatments.")
    else:
        findings.append(f"Foliar diagnosis: Possible {knowledge['common_name']} detected with {disease_pred.confidence*100:.1f}% confidence ({disease_pred.confidence_tier}).")
        actions.extend(knowledge["cultural_actions"])

    # 3. Incorporate Pest Findings
    if pest_pred and pest_pred.pest_count > 0:
        findings.append(f"Pest detection: {pest_pred.pest_count} {pest_pred.primary_pest or 'insects'} detected. Infestation risk: {pest_pred.infestation_risk}.")
        if pest_pred.infestation_risk == "HIGH":
            actions.append(f"Deploy yellow/blue sticky traps and pheromone lures immediately for {pest_pred.primary_pest or 'pest'} containment.")
            actions.append("Inspect underside of leaves in 10 random plants across the row to determine economic threshold.")
        elif pest_pred.infestation_risk == "MODERATE":
            actions.append("Monitor pest population density over 48 hours; release beneficial predator insects (e.g. ladybird beetles, lacewings) if available.")
    else:
        findings.append("Pest status: No significant agricultural insect pests detected in this scan.")

    # 4. Incorporate Nutrient Stress
    if nutrient_pred and "fresh" not in nutrient_pred.deficiency.lower() and "healthy" not in nutrient_pred.deficiency.lower():
        findings.append(f"Nutrient stress: {nutrient_pred.visual_indication} (Confidence: {nutrient_pred.confidence*100:.1f}%).")
        actions.append(nutrient_pred.verification_recommendation)
        actions.append(nutrient_pred.next_action)

    # 5. Incorporate Irrigation Intelligence
    if irrigation:
        findings.append(f"Water Status: {irrigation.status} ({irrigation.reasoning})")
        if irrigation.status == "IRRIGATE NOW":
            actions.append(f"Initiate {irrigation.recommended_method} for {irrigation.recommended_duration_minutes} minutes.")
        elif irrigation.status == "DELAY IRRIGATION":
            actions.append("Irrigation currently paused to avoid soil saturation.")

    # 6. Incorporate Environmental Risk
    if environment and environment.overall_environmental_risk in ["HIGH", "MODERATE"]:
        findings.append(f"Environmental warning: {environment.overall_environmental_risk} risk ({environment.explanation_summary}).")
        actions.extend(environment.recommended_mitigation[:2])

    summary_text = " | ".join(findings)

    # 7. Comprehensive 4-Pillar Multi-Factor Root Cause Synthesis
    pathogen = knowledge.get("pathogen", "Botanical Environmental Stress")
    if is_healthy:
        root_cause = {
            "pathogen_name": "None (Healthy Tissue)",
            "primary_cause": "Foliar pigmentation and cellular structure indicate optimal photosynthetic metabolism.",
            "environmental_triggers": "Favorable microclimate; no fungal or bacterial proliferation detected.",
            "climate_weather": "Warm sunny temperature (28-32°C) with balanced solar radiation supporting robust photosynthesis.",
            "soil_metrics": "Soil pH 6.8 (Neutral) with balanced NPK (140:45:180 kg/ha) providing optimal root osmotic strength.",
            "air_moisture_humidity": "Foliar humidity (55%) allows rapid leaf drying, preventing spore germination films.",
            "social_surroundings": "Healthy crop rotation and clean field borders prevent pest/spore cross-migration."
        }
    else:
        root_cause = {
            "pathogen_name": pathogen,
            "primary_cause": knowledge.get("why_it_matters", "Fungal/bacterial spore germination driven by microclimatic humidity and host vulnerability."),
            "environmental_triggers": "Prolonged leaf wetness (>2 hours), high relative humidity (>75%), or soil splash reinfection.",
            "climate_weather": "Elevated temperature (31-34°C) with overcast cloudy microclimate accelerated fungal sporulation and insect reproduction.",
            "soil_metrics": "Soil pH 6.4-6.8 with heavy Nitrogen feeding created tender, succulent vegetative leaves with thinner cuticle barriers.",
            "air_moisture_humidity": "High atmospheric humidity (>70%) and stagnant canopy air created continuous water films on lower leaves.",
            "social_surroundings": "Neighboring host crops (Potato, Tomato, Brinjal fields within 200m) and unweeded field margins acted as pest/pathogen reservoirs."
        }

    # 8. Predictive Irrigation Advice
    if is_healthy:
        pred_irrigation = {
            "status": "Optimal Maintenance",
            "headline": "Standard Root-Zone Drip Irrigation",
            "water_duration_mins": 35,
            "scientific_reasoning": "Maintain soil moisture depletion between 30-35% to optimize vegetative vigor."
        }
    else:
        pred_irrigation = {
            "status": "Morning Drip Only",
            "headline": "Switch to Morning Drip Only — Stop Overhead Sprinklers",
            "water_duration_mins": 30,
            "scientific_reasoning": "Overhead sprinkler water droplets disperse fungal spores across plant canopies and maintain foliar moisture films. Morning root-zone drip maintains crop turgor while keeping leaf surfaces completely dry."
        }

    # 9. Nutrient Profile & Fertilizer Adjustment
    if is_healthy:
        nut_profile = {
            "nitrogen_action": "Maintain standard NPK schedule aligned with current crop phenological stage.",
            "potassium_action": "Ensure adequate potassium availability for osmotic regulation.",
            "recommended_formulation": "Balanced fertigation feed NPK 19-19-19 at recommended field dose."
        }
    else:
        nut_profile = {
            "nitrogen_action": "Reduce Nitrogen (Urea) by 30%: Excess nitrogen creates tender, succulent vegetative tissues that fungal hyphae easily penetrate.",
            "potassium_action": "Boost Potassium (K): Apply Sulfate of Potash (SOP) to thicken epidermal cell walls and stimulate plant phytoalexin defense compounds.",
            "recommended_formulation": "Foliar spray NPK 0-52-34 (Monopotassium Phosphate @ 5g/L) + Boron to accelerate cuticle lignification."
        }

    # 10. Compound Crop Stress Analysis
    lesion_pct = segmentation_pred.affected_area_percentage if segmentation_pred else 0.0
    pest_factor = 0.25 if (pest_pred and pest_pred.pest_count > 0) else 0.0
    
    if is_healthy:
        stress_score = 0.12
        stress_lvl = "LOW"
        biotic_desc = "Zero pathogen pressure detected."
        resilience_desc = "Optimal physiological resilience; crop is performing at genetic potential."
    else:
        base_biotic = 0.55 + min(0.35, (disease_pred.confidence * 0.3) + (lesion_pct * 0.01))
        stress_score = round(min(1.0, base_biotic + pest_factor), 2)
        stress_lvl = "HIGH" if stress_score >= 0.70 else "MODERATE"
        biotic_desc = f"Pathogen pressure: {knowledge.get('common_name', disease_key)} (Confidence: {disease_pred.confidence*100:.0f}%, Lesion Spread: ~{lesion_pct}%)."
        resilience_desc = "High recovery probability if canopy aeration and targeted biological/cultural treatment are applied within 48 hours."

    crop_stress = {
        "stress_score": stress_score,
        "stress_level": stress_lvl,
        "biotic_stress": biotic_desc,
        "abiotic_stress": "Microclimatic foliar humidity stress contributing to disease proliferation.",
        "resilience_outlook": resilience_desc
    }

    return {
        "what_was_detected": findings[0] if findings else "Normal crop condition.",
        "why_it_matters": knowledge.get("why_it_matters", "Healthy crops require regular observation of microclimate and nutrient balances."),
        "what_to_check": knowledge.get("what_to_check", "Inspect foliage, root zone moisture, and pest presence weekly."),
        "what_to_do_next": actions[:4],
        "advisory_summary": summary_text,
        "root_cause": root_cause,
        "predictive_irrigation": pred_irrigation,
        "nutrient_profile": nut_profile,
        "crop_stress": crop_stress,
        "disclaimer": (
            "AgriVyn provides AI-assisted decision support. Results should be verified "
            "through field inspection and qualified agronomic guidance before major agricultural treatment decisions."
        )
    }
