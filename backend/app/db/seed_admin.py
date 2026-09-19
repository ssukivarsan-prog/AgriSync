import json
import datetime
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from backend.app.db.admin_models import Village, FarmerEntity, SMSDispatchLog, CallNote

async def seed_admin_village_data(session: AsyncSession):
    """Seed initial village, farmers cohort, SMS logs, and AI call notes if empty."""
    res = await session.execute(select(Village))
    existing_village = res.scalars().first()

    if existing_village:
        return

    now = datetime.datetime.utcnow()

    # 1. Primary Village (Melattur Panchayat, Thanjavur)
    village = Village(
        name="Melattur Panchayat",
        name_tamil="மெலட்டூர் ஊராட்சி",
        district="Thanjavur (தஞ்சாவூர்)",
        state="Tamil Nadu",
        officer_name="Dr. K. Rathinavelu, Agri Extension Officer",
        officer_contact="+91 94432 10874",
        agro_zone="Cauvery Delta Agro-Climatic Zone",
        created_at=now
    )
    session.add(village)
    await session.flush()

    # 2. Farmers cohort
    farmers = [
        FarmerEntity(
            village_id=village.id,
            name="Murugan Selvam",
            name_tamil="முருகன் செல்வம்",
            phone_number="+91 98421 78210",
            has_smartphone=False,
            device_type="FEATURE_PHONE (Nokia 105 2G)",
            has_facilities=False,
            hamlet="Melattur South Agraharam",
            farm_name="Cauvery Delta Smart Farm",
            farm_size_acres=5.5,
            primary_crop="Paddy (CR1009 / Samba)",
            crop_stage="Panicle Initiation",
            soil_type="Cauvery Alluvial Clay Loam",
            water_source="Cauvery Canal + Borewell",
            risk_level="CRITICAL",
            risk_title="Acute Water Stress & Canopy Heat Vulnerability (நீர் பற்றாக்குறை அழுத்தம்)",
            soil_moisture_pct=19.4,
            soil_ph=6.7,
            nitrogen_kg_ha=145.0,
            phosphorus_kg_ha=16.0,
            potassium_kg_ha=120.0,
            soil_temp_c=32.8,
            tinyml_edge_decision="IRRIGATE_URGENT_EVAPOTRANSPIRATION_SPIKE",
            recent_disease="Paddy Blast Spore Incubation (குலை நோய் அபாயம்)",
            disease_tamil="குலை நோய் (Paddy Blast)",
            recommended_action="Run 1.5-hour furrow irrigation immediately. Apply Tricyclazole 75 WP @ 1g/L of water at dusk.",
            recommended_action_tamil="உடனடியாக 1.5 மணி நேரம் பாசனம் செய்யவும். ட்ரைசைக்ளசோல் 75 WP மருந்தை ஒரு லிட்டர் தண்ணீருக்கு 1 கிராம் கலந்து மாலையில் தெளிக்கவும்.",
            last_interaction=now - datetime.timedelta(hours=3),
            created_at=now - datetime.timedelta(days=15)
        ),
        FarmerEntity(
            village_id=village.id,
            name="Palanisamy Gounder",
            name_tamil="பழனிச்சாமி கவுண்டர்",
            phone_number="+91 94435 44102",
            has_smartphone=False,
            device_type="FEATURE_PHONE (Samsung Guru Basic)",
            has_facilities=False,
            hamlet="East Canal Road",
            farm_name="Palani Nilam",
            farm_size_acres=3.2,
            primary_crop="Groundnut (VRI 8)",
            crop_stage="Pegging Stage",
            soil_type="Red Sandy Loam",
            water_source="Borewell Drip",
            risk_level="ELEVATED",
            risk_title="Elevated Fungal Spore Incubation (பூஞ்சாண நோய் பரவல் அபாயம்)",
            soil_moisture_pct=42.5,
            soil_ph=6.4,
            nitrogen_kg_ha=110.0,
            phosphorus_kg_ha=22.0,
            potassium_kg_ha=150.0,
            soil_temp_c=28.2,
            tinyml_edge_decision="FUNGAL_TIKKA_LEAF_SPOT_ALERT",
            recent_disease="Tikka Leaf Spot (டிக்கா இலைப்புள்ளி நோய்)",
            disease_tamil="டிக்கா இலைப்புள்ளி நோய்",
            recommended_action="Spray Mancozeb @ 2g/L; avoid night-time irrigation to prevent prolonged leaf wetness.",
            recommended_action_tamil="மேன்கோசெப் 2 கிராம்/லிட்டர் தெளிக்கவும்; இலை ஈரப்பதத்தை குறைக்க இரவில் நீர் பாய்ச்சுவதை தவிர்க்கவும்.",
            last_interaction=now - datetime.timedelta(hours=8),
            created_at=now - datetime.timedelta(days=20)
        ),
        FarmerEntity(
            village_id=village.id,
            name="Meenakshi Ammal",
            name_tamil="மீனாட்சி அம்மாள்",
            phone_number="+91 97890 23145",
            has_smartphone=False,
            device_type="FEATURE_PHONE (Itel 2160 Keypad)",
            has_facilities=False,
            hamlet="West Street",
            farm_name="Meenakshi Thottam",
            farm_size_acres=2.5,
            primary_crop="Cotton (MCU 5)",
            crop_stage="Squaring & Boll Formation",
            soil_type="Black Cotton Soil",
            water_source="Canal Seasonal",
            risk_level="CRITICAL",
            risk_title="Active Insect Pest Infestation (பூச்சி தாக்குதல் அபாயம்)",
            soil_moisture_pct=27.0,
            soil_ph=7.4,
            nitrogen_kg_ha=130.0,
            phosphorus_kg_ha=14.0,
            potassium_kg_ha=165.0,
            soil_temp_c=31.0,
            tinyml_edge_decision="AMERICAN_BOLLWORM_DEFOLIATION_RISK",
            recent_disease="American Bollworm & Whitefly (பருத்தி காய்ப்புழு / வெள்ளை ஈ)",
            disease_tamil="பருத்தி காய்ப்புழு மற்றும் வெள்ளை ஈ",
            recommended_action="Erect 5 pheromone traps per acre. Spray 5% Neem Seed Kernel Extract (NSKE) or Flonicamid 50 WG @ 0.3g/L.",
            recommended_action_tamil="ஏக்கருக்கு 5 இனக்கவர்ச்சி பொறிகளை அமைக்கவும். 5% வேப்பங்கொட்டை சாறு அல்லது புளோனிகமிட் 50 WG 0.3 கிராம்/லிட்டர் தெளிக்கவும்.",
            last_interaction=now - datetime.timedelta(hours=14),
            created_at=now - datetime.timedelta(days=12)
        ),
        FarmerEntity(
            village_id=village.id,
            name="Kavitha Sundar",
            name_tamil="கவிதா சுந்தர்",
            phone_number="+91 99420 89123",
            has_smartphone=True,
            device_type="SMARTPHONE (Redmi Note 12 - AgriVyn App Active)",
            has_facilities=True,
            hamlet="North Garden",
            farm_name="Green Horizon Nursery",
            farm_size_acres=4.0,
            primary_crop="Tomato (Arka Rakshak)",
            crop_stage="Flowering & Early Fruit Set",
            soil_type="Red Loamy Soil",
            water_source="Automated Drip Borewell",
            risk_level="OPTIMAL",
            risk_title="Optimal Crop Health & Vigor (ஆரோக்கியமான வளர்ச்சி)",
            soil_moisture_pct=36.4,
            soil_ph=6.5,
            nitrogen_kg_ha=175.0,
            phosphorus_kg_ha=26.0,
            potassium_kg_ha=190.0,
            soil_temp_c=27.8,
            tinyml_edge_decision="TINYML_MONITOR_NORMAL_HEALTH",
            recent_disease="None (Healthy Foliage)",
            disease_tamil="நோயற்ற பசுமை பயிர்",
            recommended_action="Maintain current fertigation schedule (NPK 19:19:19 @ 3kg/acre weekly).",
            recommended_action_tamil="வழக்கமான உரப்பாசனத்தை தொடரவும் (19:19:19 NPK ஏக்கருக்கு 3 கிலோ).",
            last_interaction=now - datetime.timedelta(hours=1),
            created_at=now - datetime.timedelta(days=30)
        ),
        FarmerEntity(
            village_id=village.id,
            name="Annamalai Thevar",
            name_tamil="அண்ணாமலை தேவர்",
            phone_number="+91 96291 33456",
            has_smartphone=False,
            device_type="FEATURE_PHONE (Lava A1 Keypad)",
            has_facilities=False,
            hamlet="Old Temple Street",
            farm_name="Cauvery Valam Sugarcane",
            farm_size_acres=6.0,
            primary_crop="Sugarcane (Co 86032)",
            crop_stage="Early Tillering Stage",
            soil_type="Deep Clay Loam",
            water_source="Canal Gravity Flow",
            risk_level="MODERATE",
            risk_title="Early Shoot Borer Warning (குருத்துப்பூச்சி எச்சரிக்கை)",
            soil_moisture_pct=31.5,
            soil_ph=7.1,
            nitrogen_kg_ha=190.0,
            phosphorus_kg_ha=19.0,
            potassium_kg_ha=140.0,
            soil_temp_c=30.2,
            tinyml_edge_decision="HEAT_STRESS_EVAP_WARNING",
            recent_disease="Early Shoot Borer (இளம் குருத்துப்பூச்சி)",
            disease_tamil="இளம் குருத்துப்பூச்சி தாக்குதல்",
            recommended_action="Apply Chlorantraniliprole 0.4% G @ 7.5 kg/acre in root zone, followed by light irrigation.",
            recommended_action_tamil="குளோரான்ட்ரனிலிப்ரோல் 0.4% குருணையை ஏக்கருக்கு 7.5 கிலோ வேர்ப்பகுதியில் இட்டு லேசான நீர் பாய்ச்சவும்.",
            last_interaction=now - datetime.timedelta(days=1),
            created_at=now - datetime.timedelta(days=18)
        ),
        FarmerEntity(
            village_id=village.id,
            name="Senthil Nathan",
            name_tamil="செந்தில் நாதன்",
            phone_number="+91 94862 11980",
            has_smartphone=True,
            device_type="SMARTPHONE (Samsung Galaxy M14 5G)",
            has_facilities=True,
            hamlet="Kottai Medu",
            farm_name="Nathan Agro Farm",
            farm_size_acres=7.5,
            primary_crop="Paddy (BPT 5204 / Samba Mahsuri)",
            crop_stage="Grain Filling Stage",
            soil_type="Delta Clay Alluvium",
            water_source="River Sluice + Deep Tube Well",
            risk_level="ELEVATED",
            risk_title="Bacterial Leaf Blight Alert (பாக்டீரியா இலைக்கருகல்)",
            soil_moisture_pct=40.8,
            soil_ph=6.9,
            nitrogen_kg_ha=210.0,
            phosphorus_kg_ha=18.0,
            potassium_kg_ha=160.0,
            soil_temp_c=29.0,
            tinyml_edge_decision="HIGH_HUMIDITY_PATHOGEN_INDEX",
            recent_disease="Bacterial Leaf Blight (பாக்டீரியா இலைக்கருகல்)",
            disease_tamil="பாக்டீரியா இலைக்கருகல் நோய்",
            recommended_action="Withhold nitrogen fertilizer. Spray Streptocycline 100g + Copper Oxychloride 500g in 200L water.",
            recommended_action_tamil="தழைச்சத்து உரத்தை நிறுத்தவும். ஸ்ட்ரெப்டோசைக்ளின் 100 கிராம் + காப்பர் ஆக்ஸிகுளோரைடு 500 கிராம் 200 லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும்.",
            last_interaction=now - datetime.timedelta(hours=5),
            created_at=now - datetime.timedelta(days=25)
        ),
        FarmerEntity(
            village_id=village.id,
            name="Muthulakshmi",
            name_tamil="முத்துலட்சுமி",
            phone_number="+91 98940 77654",
            has_smartphone=False,
            device_type="FEATURE_PHONE (JioPhone Basic 2G)",
            has_facilities=False,
            hamlet="Kulathu Mettu Street",
            farm_name="Lakshmi Vazhai Thottam",
            farm_size_acres=2.2,
            primary_crop="Banana (Grand Naine / G9)",
            crop_stage="Shooting & Bunch Development",
            soil_type="Rich Silt Loam",
            water_source="Well Basin Irrigation",
            risk_level="CRITICAL",
            risk_title="Sigatoka Leaf Spot Spore Detection (சிகடோகா இலைப்புள்ளி)",
            soil_moisture_pct=23.8,
            soil_ph=6.6,
            nitrogen_kg_ha=155.0,
            phosphorus_kg_ha=20.0,
            potassium_kg_ha=240.0,
            soil_temp_c=31.2,
            tinyml_edge_decision="SIGATOKA_FUNGAL_THRESHOLD_MET",
            recent_disease="Yellow Sigatoka Leaf Spot (சிகடோகா இலைப்புள்ளி)",
            disease_tamil="மஞ்சள் சிகடோகா இலைப்புள்ளி",
            recommended_action="Prune and safely burn infected dry leaves; spray Propiconazole 1ml/L + mineral oil (10ml/L).",
            recommended_action_tamil="பாதிக்கப்பட்ட காய்ந்த இலைகளை வெட்டி எரிக்கவும்; புரோபிகோனசோல் 1 மிலி/லிட்டர் + மினரல் ஆயில் கலந்து தெளிக்கவும்.",
            last_interaction=now - datetime.timedelta(hours=22),
            created_at=now - datetime.timedelta(days=14)
        ),
    ]
    session.add_all(farmers)
    await session.flush()

    # 3. Seed initial SMS Dispatch Logs for feature phone farmers
    sms_logs = [
        SMSDispatchLog(
            farmer_id=farmers[0].id,
            recipient_phone=farmers[0].phone_number,
            message_tamil="வணக்கம் முருகன் அண்ணா, உங்கள் வயலில் ஈரப்பதம் 19.4% குறைந்துவிட்டது. இன்று மாலை உடனே 1.5 மணி நேரம் பாசனம் செய்யவும். குலை நோய் தடுப்புக்கு ட்ரைசைக்ளசோல் 75WP மருந்து தெளிக்கவும். - மெலட்டூர் வேளாண் மையம்.",
            message_english="AgriVyn Alert for Murugan Selvam: Soil moisture critical at 19.4%. Run 1.5hr furrow irrigation today before dusk. Paddy blast risk elevated; spray Tricyclazole 75WP @ 1g/L. - Melattur Agri Office.",
            delivery_status="DELIVERED",
            carrier_ref="BSNL-SMS-TN-88219",
            timestamp=now - datetime.timedelta(hours=3)
        ),
        SMSDispatchLog(
            farmer_id=farmers[1].id,
            recipient_phone=farmers[1].phone_number,
            message_tamil="வணக்கம் பழனிச்சாமி ஐயா, வேர்க்கடலையில் டிக்கா இலைப்புள்ளி அறிகுறிகள் உள்ளன. மேன்கோசெப் 2 கிராம்/லிட்டர் தெளிக்கவும்; இரவில் நீர் பாய்ச்ச வேண்டாம். - மெலட்டூர் வேளாண் மையம்.",
            message_english="AgriVyn Advisory: Tikka leaf spot detected in Groundnut field. Spray Mancozeb 2g/L. Avoid night irrigation. - Melattur Agri Office.",
            delivery_status="DELIVERED",
            carrier_ref="AIRTEL-SMS-TN-44120",
            timestamp=now - datetime.timedelta(hours=8)
        )
    ]
    session.add_all(sms_logs)

    # 4. Seed initial Call Note for demonstration
    call_note = CallNote(
        farmer_id=farmers[0].id,
        call_duration_seconds=145,
        farmer_mood="SEEKING_ADVICE",
        extracted_queries_json=json.dumps([
            "மண்ணில் ஈரப்பதம் குறைந்துவிட்டது, கால்வாய் தண்ணீர் எப்போது திறப்பார்கள்?",
            "குலை நோய் மருந்து கூட்டுறவு சங்கத்தில் மானிய விலையில் கிடைக்குமா?",
            "அடுத்த உரம் எப்போது போட வேண்டும்?"
        ], ensure_ascii=False),
        ai_response_summary="AI voice assistant explained urgent need for borewell furrow wetting, recommended Tricyclazole dosage, and confirmed availability of subsidized bio-fertilizers at the Primary Agricultural Cooperative Credit Society (PACCS).",
        officer_action_items_json=json.dumps([
            "Coordinate with Melattur PACCS for Tricyclazole 75WP supply to farmer",
            "Verify canal release timetable with PWD Water Resources Department",
            "Field visit scheduled by VAO for upcoming Thursday morning"
        ], ensure_ascii=False),
        is_resolved=False,
        transcript_json=json.dumps([
            {"speaker": "AI_AGENT", "text": "வணக்கம் முருகன் அண்ணா! நான் அக்ரிவின் AI வேளாண்மை உதவியாளர் பேசுகிறேன். உங்கள் வயல் மண்டலம் 1-ல் மண்ணின் ஈரப்பதம் 19% ஆக குறைந்துள்ளது. உங்களுக்கு ஏதேனும் சந்தேகங்கள் உள்ளதா?"},
            {"speaker": "FARMER", "text": "ஆமாங்க ஐயா, தண்ணீர் ரொம்ப குறைவா இருக்கு. கால்வாய் தண்ணீர் எப்போது வரும்? கூட்டுறவு சங்கத்தில் மருந்து கிடைக்குமா?"},
            {"speaker": "AI_AGENT", "text": "முருகன் அண்ணா, கால்வாய் நீர் வர 2 நாட்கள் ஆகும், அதற்குள் போர்வெல் மூலம் உடனடியாக 1 மணி நேரம் நீர் பாய்ச்சுங்கள். மேலும் குலை நோய் தடுப்புக்கு ட்ரைசைக்ளசோல் மருந்து மெலட்டூர் தொடக்க வேளாண்மை கூட்டுறவு வங்கியில் 50% மானியத்தில் கிடைக்கும். வேளாண் அலுவலர் உங்களுக்கு உதவ குறிப்பு எடுத்துக்கொண்டுள்ளார்."},
            {"speaker": "FARMER", "text": "ரொம்ப நன்றிங்க ஐயா. உடனே தண்ணீர் பாய்ச்ச ஏற்பாடு செய்கிறேன்."}
        ], ensure_ascii=False),
        timestamp=now - datetime.timedelta(hours=3)
    )
    session.add(call_note)
    await session.commit()
