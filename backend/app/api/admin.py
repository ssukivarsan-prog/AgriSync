import json
import datetime
from typing import Optional, List
from pydantic import BaseModel
from fastapi import APIRouter, HTTPException, Depends, Query
import logging
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from backend.app.db.database import get_db
from backend.app.db.admin_models import Village, FarmerEntity, SMSDispatchLog, CallNote

router = APIRouter(prefix="/admin", tags=["Village Admin & Field Officer Portal"])

# ----------------- Pydantic Schemas -----------------
class SendSMSRequest(BaseModel):
    message_tamil: Optional[str] = None
    message_english: str

class AICallChatRequest(BaseModel):
    user_message: str
    conversation_history: List[dict] = []

class SaveCallNotesRequest(BaseModel):
    call_duration_seconds: int = 90
    farmer_mood: str = "SEEKING_ADVICE"
    extracted_queries: List[str] = []
    ai_response_summary: str
    officer_action_items: List[str] = []
    transcript: List[dict] = []

class RegisterFarmerRequest(BaseModel):
    village_id: int = 1
    name: str
    name_tamil: Optional[str] = None
    phone_number: str
    hamlet: str = "Melattur Main Street"
    farm_name: Optional[str] = None
    farm_size_acres: float = 3.5
    primary_crop: str = "Paddy (CR1009 / Samba)"
    crop_stage: str = "Tillering Stage"
    soil_type: str = "Cauvery Alluvial Clay Loam"
    water_source: str = "Canal + Borewell"
    soil_moisture_pct: float = 22.5
    has_smartphone: bool = False
    device_type: str = "FEATURE_PHONE (2G Keypad - No Smartphone)"
    recent_disease: Optional[str] = "Paddy Blast Suspected"
    disease_tamil: Optional[str] = "குலை நோய் அபாயம்"
    recommended_action: Optional[str] = "Run 1.5-hour furrow irrigation immediately; apply Tricyclazole 75WP."
    recommended_action_tamil: Optional[str] = "உடனடியாக 1.5 மணி நேரம் பாசனம் செய்யவும்; ட்ரைசைக்ளசோல் 75WP மருந்து தெளிக்கவும்."

class DirectCallRequest(BaseModel):
    phone_number: str
    caller_name: Optional[str] = "Farmer"
    crop: Optional[str] = "Paddy (Samba)"

# ----------------- Helper AI Reasoning -----------------
def generate_ai_agronomist_reply(farmer: FarmerEntity, query: str) -> dict:
    """Intelligent rule and context-based agronomy assistant for Tamil Nadu agriculture."""
    q_lower = query.lower()
    crop = farmer.primary_crop
    moisture = farmer.soil_moisture_pct
    disease = farmer.recent_disease or "Normal"

    # Default greetings or queries
    is_tamil = any("\u0b80" <= ch <= "\u0bff" for ch in query)
    
    # 1. Water / Irrigation / Canal queries
    if any(w in q_lower for w in ["water", "irrigation", "dry", "moisture", "தண்ணீர்", "பாசனம்", "ஈரப்பதம்", "கால்வாய்"]):
        if is_tamil:
            reply = (
                f"{farmer.name_tamil or farmer.name} ஐயா, உங்கள் {farmer.primary_crop} வயலில் சென்சார் "
                f"ஈரப்பதம் {moisture}% ஆக பதிவாகியுள்ளது. இது அனுமதிக்கப்பட்ட அளவை விட குறைவாக உள்ளது. "
                f"கால்வாய் நீர் வரும் வரை காத்திருக்காமல், உடனடியாக போர்வெல் மூலம் 1 முதல் 1.5 மணி நேரம் பாசனம் செய்யவும். "
                f"வேளாண் அலுவலர் மேலதிக உதவிக்காக உங்கள் வயல் விபரங்களை குறித்துக்கொண்டுள்ளார்."
            )
        else:
            reply = (
                f"Mr. {farmer.name}, your {farmer.primary_crop} soil moisture sensor is reading {moisture}%, "
                f"which is below the safe threshold. We recommend initiating a 1 to 1.5-hour furrow wetting cycle immediately "
                f"using your borewell. The Village Officer has logged this for water-release follow-up."
            )
        action = f"Verify immediate irrigation for {farmer.name}'s {farmer.primary_crop} field (Moisture: {moisture}%)"
        category = "IRRIGATION_CRITICAL"

    # 2. Disease / Pest / Medicine queries
    elif any(w in q_lower for w in ["disease", "pest", "spray", "medicine", "blast", "fungus", "நோய்", "மருந்து", "பூச்சி", "புழு", "தெளிக்க"]):
        rec_ta = farmer.recommended_action_tamil or "பரிந்துரைக்கப்பட்ட பூஞ்சாண கொல்லியை தெளிக்கவும்."
        rec_en = farmer.recommended_action or "Apply recommended TNAU protective spray."
        if is_tamil:
            reply = (
                f"{farmer.name_tamil or farmer.name} அவர்களே, உங்கள் பயிரில் சமீபத்திய ஆய்வில் {farmer.disease_tamil or disease} "
                f"அறிகுறிகள் பதிவாகியுள்ளன. தமிழ்நாடு வேளாண்மை பல்கலைக்கழக (TNAU) பரிந்துரைப்படி: {rec_ta} "
                f"மெலட்டூர் தொடக்க வேளாண் கூட்டுறவு வங்கியில் இந்த மருந்து 50% மானியத்தில் கிடைக்கும்."
            )
        else:
            reply = (
                f"Mr. {farmer.name}, our diagnostic scan detected early symptoms of {disease}. "
                f"As per TNAU agronomy protocol: {rec_en} Subsidized stock is available at the local agricultural society."
            )
        action = f"Supply subsidized pesticide/bio-agent for {disease} to {farmer.name} ({farmer.phone_number})"
        category = "PEST_AND_DISEASE"

    # 3. Fertilizer / Urea / NPK queries
    elif any(w in q_lower for w in ["fertilizer", "urea", "potash", "npk", "உரம்", "யூரியா", "பொட்டாஷ்", "தழைச்சத்து"]):
        n, p, k = farmer.nitrogen_kg_ha, farmer.phosphorus_kg_ha, farmer.potassium_kg_ha
        if is_tamil:
            reply = (
                f"{farmer.name_tamil or farmer.name} ஐயா, உங்கள் வயல் மண்ணில் தழைச்சத்து (N) {n} kg/ha, மணிச்சத்து (P) {p} kg/ha, "
                f"சாம்பல் சத்து (K) {k} kg/ha உள்ளது. பயிர் {farmer.crop_stage} நிலையில் உள்ளதால், தழைச்சத்து அதிகமாக போடாமல் "
                f"பொட்டாஷ் மற்றும் வேப்பம்பிண்ணாக்கு கலந்து இடவும். இது நோய் எதிர்ப்பு திறனை அதிகரிக்கும்."
            )
        else:
            reply = (
                f"Soil telemetry for your field shows N: {n}, P: {p}, K: {k} kg/ha. At the {farmer.crop_stage}, "
                f"avoid excessive nitrogen top-dressing. Balance with muriate of potash and neem cake to strengthen plant cuticle."
            )
        action = f"Provide soil health card advisory & balanced NPK guidance to {farmer.name}"
        category = "FERTILIZER_MANAGEMENT"

    # 4. Subsidy / Government / Officer help
    elif any(w in q_lower for w in ["subsidy", "scheme", "officer", "help", "மானிய", "திட்டம்", "அதிகாரி", "உதவி"]):
        if is_tamil:
            reply = (
                f"{farmer.name_tamil or farmer.name} அவர்களே, உங்கள் பகுதி வேளாண் விரிவாக்க அலுவலர் "
                f"{farmer.village.officer_name if farmer.village else 'Dr. K. Rathinavelu'} இந்த வாரம் உங்கள் கிராமத்திற்கு வருகிறார். "
                f"உங்கள் கோரிக்கை பதிவு செய்யப்பட்டுள்ளது. சொட்டுநீர் பாசன மானியம் மற்றும் பயிர் காப்பீடு விபரங்களுடன் உங்களை நேரில் சந்திப்பார்."
            )
        else:
            reply = (
                f"Mr. {farmer.name}, your request has been registered with Village Extension Officer "
                f"{farmer.village.officer_name if farmer.village else 'Dr. K. Rathinavelu'}. He will inspect your field this week "
                f"with PM-KISAN, crop insurance, and micro-irrigation subsidy applications."
            )
        action = f"Village Agriculture Officer to visit {farmer.name} in {farmer.hamlet} regarding government subsidies"
        category = "GOVERNMENT_SCHEME"

    # General / Default response
    else:
        if is_tamil:
            reply = (
                f"வணக்கம் {farmer.name_tamil or farmer.name} ஐயா. நான் அக்ரிவின் வேளாண்மை AI உதவியாளர். "
                f"உங்கள் {farmer.primary_crop} பயிர் தற்பொழுது {farmer.crop_stage} பருவத்தில் உள்ளது. "
                f"மண்ணின் ஈரப்பதம் {moisture}%. பாசனம், உரம் அல்லது பூச்சி தாக்குதல் குறித்து ஏதேனும் உதவி தேவையா?"
            )
        else:
            reply = (
                f"Hello Mr. {farmer.name}, I am your AgriVyn AI Agronomist assistant. "
                f"Your {farmer.primary_crop} crop is currently in {farmer.crop_stage}. "
                f"Current soil moisture is {moisture}%. How can I assist you with irrigation, pest management, or nutrients today?"
            )
        action = f"General agronomy checkup logged for {farmer.name}"
        category = "GENERAL_INQUIRY"

    return {
        "reply": reply,
        "suggested_action": action,
        "category": category
    }

# ----------------- API Endpoints -----------------

@router.get("/villages")
async def get_villages(db: AsyncSession = Depends(get_db)):
    """Retrieve all villages with summary metrics of farmers, devices, and alerts."""
    villages_res = await db.execute(select(Village))
    villages = villages_res.scalars().all()

    results = []
    for v in villages:
        farmers_res = await db.execute(select(FarmerEntity).where(FarmerEntity.village_id == v.id))
        farmers = farmers_res.scalars().all()

        total = len(farmers)
        smartphone_count = sum(1 for f in farmers if f.has_smartphone)
        feature_phone_count = total - smartphone_count
        critical_alerts_count = sum(1 for f in farmers if f.risk_level in ["CRITICAL", "ELEVATED"])

        results.append({
            "id": v.id,
            "name": v.name,
            "name_tamil": v.name_tamil,
            "district": v.district,
            "state": v.state,
            "officer_name": v.officer_name,
            "officer_contact": v.officer_contact,
            "agro_zone": v.agro_zone,
            "total_farmers": total,
            "smartphone_farmers": smartphone_count,
            "feature_phone_farmers": feature_phone_count,
            "critical_alerts_count": critical_alerts_count
        })

    return results


@router.get("/farmers")
async def list_farmers(
    village_id: Optional[int] = None,
    has_smartphone: Optional[bool] = None,
    risk_level: Optional[str] = None,
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    """List farmers for the admin portal with filters for smartphone availability, risk level, and search."""
    stmt = select(FarmerEntity)

    if village_id is not None:
        stmt = stmt.where(FarmerEntity.village_id == village_id)
    if has_smartphone is not None:
        stmt = stmt.where(FarmerEntity.has_smartphone == has_smartphone)
    if risk_level and risk_level.upper() != "ALL":
        stmt = stmt.where(FarmerEntity.risk_level == risk_level.upper())

    stmt = stmt.order_by(
        # Put critical first
        FarmerEntity.risk_level.desc(),
        FarmerEntity.has_smartphone.asc(),
        FarmerEntity.name.asc()
    )

    res = await db.execute(stmt)
    farmers = res.scalars().all()

    # In-memory search filter if provided
    if search:
        s = search.lower()
        farmers = [
            f for f in farmers
            if s in f.name.lower() or
               (f.name_tamil and s in f.name_tamil) or
               s in f.phone_number or
               s in f.primary_crop.lower() or
               s in f.hamlet.lower()
        ]

    # Return structured items
    return [
        {
            "id": f.id,
            "village_id": f.village_id,
            "name": f.name,
            "name_tamil": f.name_tamil,
            "phone_number": f.phone_number,
            "has_smartphone": f.has_smartphone,
            "device_type": f.device_type,
            "has_facilities": f.has_facilities,
            "hamlet": f.hamlet,
            "farm_name": f.farm_name,
            "farm_size_acres": f.farm_size_acres,
            "primary_crop": f.primary_crop,
            "crop_stage": f.crop_stage,
            "risk_level": f.risk_level,
            "risk_title": f.risk_title,
            "soil_moisture_pct": f.soil_moisture_pct,
            "tinyml_edge_decision": f.tinyml_edge_decision,
            "recent_disease": f.recent_disease,
            "disease_tamil": f.disease_tamil,
            "recommended_action": f.recommended_action,
            "recommended_action_tamil": f.recommended_action_tamil,
            "last_interaction": f.last_interaction.isoformat() if f.last_interaction else None
        }
        for f in farmers
    ]


@router.get("/farmers/{farmer_id}")
async def get_farmer_details(farmer_id: int, db: AsyncSession = Depends(get_db)):
    """Retrieve comprehensive single-farm telemetry, diagnosis, SMS history, and call notes."""
    res = await db.execute(select(FarmerEntity).where(FarmerEntity.id == farmer_id))
    farmer = res.scalars().first()
    if not farmer:
        raise HTTPException(status_code=404, detail="Farmer record not found")

    # Fetch SMS history
    sms_res = await db.execute(
        select(SMSDispatchLog)
        .where(SMSDispatchLog.farmer_id == farmer_id)
        .order_by(desc(SMSDispatchLog.timestamp))
    )
    sms_logs = sms_res.scalars().all()

    # Fetch Call notes
    call_res = await db.execute(
        select(CallNote)
        .where(CallNote.farmer_id == farmer_id)
        .order_by(desc(CallNote.timestamp))
    )
    call_notes = call_res.scalars().all()

    # Parse call notes JSON
    formatted_call_notes = []
    for cn in call_notes:
        queries = []
        actions = []
        transcript = []
        try:
            if cn.extracted_queries_json:
                queries = json.loads(cn.extracted_queries_json)
            if cn.officer_action_items_json:
                actions = json.loads(cn.officer_action_items_json)
            if cn.transcript_json:
                transcript = json.loads(cn.transcript_json)
        except Exception:
            pass

        formatted_call_notes.append({
            "id": cn.id,
            "call_duration_seconds": cn.call_duration_seconds,
            "farmer_mood": cn.farmer_mood,
            "extracted_queries": queries,
            "ai_response_summary": cn.ai_response_summary,
            "officer_action_items": actions,
            "is_resolved": cn.is_resolved,
            "transcript": transcript,
            "timestamp": cn.timestamp.isoformat()
        })

    # Auto-generate recommended SMS templates for quick admin broadcast
    default_sms_tamil = (
        f"வணக்கம் {farmer.name_tamil or farmer.name} ஐயா, அக்ரிவின் கள ஆய்வு எச்சரிக்கை: உங்கள் {farmer.primary_crop} "
        f"வயலில் ஈரப்பதம் {farmer.soil_moisture_pct}%. நிலைமை: {farmer.risk_level}. "
        f"பரிந்துரை: {farmer.recommended_action_tamil or farmer.recommended_action} - மெலட்டூர் வேளாண் மையம்."
    )
    default_sms_english = (
        f"AgriVyn Advisory for {farmer.name}: Field {farmer.farm_name} ({farmer.primary_crop}). "
        f"Soil Moisture: {farmer.soil_moisture_pct}%. Status: {farmer.risk_level}. "
        f"Action: {farmer.recommended_action} - Melattur Agri Office."
    )

    return {
        "id": farmer.id,
        "village_id": farmer.village_id,
        "name": farmer.name,
        "name_tamil": farmer.name_tamil,
        "phone_number": farmer.phone_number,
        "has_smartphone": farmer.has_smartphone,
        "device_type": farmer.device_type,
        "has_facilities": farmer.has_facilities,
        "hamlet": farmer.hamlet,
        "farm_name": farmer.farm_name,
        "farm_size_acres": farmer.farm_size_acres,
        "primary_crop": farmer.primary_crop,
        "crop_stage": farmer.crop_stage,
        "soil_type": farmer.soil_type,
        "water_source": farmer.water_source,
        "telemetry": {
            "soil_moisture_pct": farmer.soil_moisture_pct,
            "soil_ph": farmer.soil_ph,
            "nitrogen_kg_ha": farmer.nitrogen_kg_ha,
            "phosphorus_kg_ha": farmer.phosphorus_kg_ha,
            "potassium_kg_ha": farmer.potassium_kg_ha,
            "soil_temp_c": farmer.soil_temp_c,
            "tinyml_edge_decision": farmer.tinyml_edge_decision,
        },
        "risk": {
            "level": farmer.risk_level,
            "title": farmer.risk_title,
            "recent_disease": farmer.recent_disease,
            "disease_tamil": farmer.disease_tamil,
            "recommended_action": farmer.recommended_action,
            "recommended_action_tamil": farmer.recommended_action_tamil,
        },
        "suggested_sms": {
            "tamil": default_sms_tamil,
            "english": default_sms_english
        },
        "sms_history": [
            {
                "id": s.id,
                "recipient_phone": s.recipient_phone,
                "message_tamil": s.message_tamil,
                "message_english": s.message_english,
                "delivery_status": s.delivery_status,
                "carrier_ref": s.carrier_ref,
                "timestamp": s.timestamp.isoformat()
            }
            for s in sms_logs
        ],
        "call_notes": formatted_call_notes,
        "last_interaction": farmer.last_interaction.isoformat() if farmer.last_interaction else None
    }


@router.post("/farmers/{farmer_id}/send-sms")
async def send_farmer_sms(
    farmer_id: int,
    req: SendSMSRequest,
    db: AsyncSession = Depends(get_db)
):
    """Simulate dispatching a mobile summary bulletin / SMS to a farmer with live carrier receipt logging."""
    res = await db.execute(select(FarmerEntity).where(FarmerEntity.id == farmer_id))
    farmer = res.scalars().first()
    if not farmer:
        raise HTTPException(status_code=404, detail="Farmer not found")

    carrier_ref = f"AIRTEL-SMS-TN-{datetime.datetime.utcnow().strftime('%H%M%S%f')[:10]}"
    sms_log = SMSDispatchLog(
        farmer_id=farmer.id,
        recipient_phone=farmer.phone_number,
        message_tamil=req.message_tamil,
        message_english=req.message_english,
        delivery_status="DELIVERED",
        carrier_ref=carrier_ref,
        timestamp=datetime.datetime.utcnow()
    )
    farmer.last_interaction = datetime.datetime.utcnow()
    db.add(sms_log)
    await db.commit()

    return {
        "success": True,
        "status": "DELIVERED",
        "carrier_reference": carrier_ref,
        "recipient": farmer.name,
        "phone": farmer.phone_number,
        "device_type": farmer.device_type,
        "timestamp": sms_log.timestamp.isoformat(),
        "message_english": req.message_english,
        "message_tamil": req.message_tamil
    }


@router.post("/farmers/{farmer_id}/ai-call/chat")
async def ai_call_chat(
    farmer_id: int,
    req: AICallChatRequest,
    db: AsyncSession = Depends(get_db)
):
    """Conversational AI agent endpoint answering farmer queries in Tamil & English."""
    res = await db.execute(select(FarmerEntity).where(FarmerEntity.id == farmer_id))
    farmer = res.scalars().first()
    if not farmer:
        raise HTTPException(status_code=404, detail="Farmer not found")

    result = generate_ai_agronomist_reply(farmer, req.user_message)
    return {
        "reply": result["reply"],
        "suggested_action": result["suggested_action"],
        "category": result["category"],
        "timestamp": datetime.datetime.utcnow().isoformat()
    }


@router.post("/farmers/{farmer_id}/ai-call/save-notes")
async def save_call_notes(
    farmer_id: int,
    req: SaveCallNotesRequest,
    db: AsyncSession = Depends(get_db)
):
    """Save the transcribed call notes, extracted queries, and officer action items."""
    res = await db.execute(select(FarmerEntity).where(FarmerEntity.id == farmer_id))
    farmer = res.scalars().first()
    if not farmer:
        raise HTTPException(status_code=404, detail="Farmer not found")

    call_note = CallNote(
        farmer_id=farmer.id,
        call_duration_seconds=req.call_duration_seconds,
        farmer_mood=req.farmer_mood,
        extracted_queries_json=json.dumps(req.extracted_queries, ensure_ascii=False),
        ai_response_summary=req.ai_response_summary,
        officer_action_items_json=json.dumps(req.officer_action_items, ensure_ascii=False),
        is_resolved=False,
        transcript_json=json.dumps(req.transcript, ensure_ascii=False),
        timestamp=datetime.datetime.utcnow()
    )
    farmer.last_interaction = datetime.datetime.utcnow()
    db.add(call_note)
    await db.commit()

    return {
        "success": True,
        "note_id": call_note.id,
        "farmer_name": farmer.name,
        "extracted_queries": req.extracted_queries,
        "officer_action_items": req.officer_action_items,
        "timestamp": call_note.timestamp.isoformat()
    }


@router.patch("/call-notes/{note_id}/resolve")
async def toggle_call_note_status(note_id: int, db: AsyncSession = Depends(get_db)):
    """Toggle resolution state of a call note / action item."""
    res = await db.execute(select(CallNote).where(CallNote.id == note_id))
    note = res.scalars().first()
    if not note:
        raise HTTPException(status_code=404, detail="Call note not found")

    note.is_resolved = not note.is_resolved
    await db.commit()
    return {"id": note.id, "is_resolved": note.is_resolved}


@router.post("/farmers/register")
async def register_offline_farmer(req: RegisterFarmerRequest, db: AsyncSession = Depends(get_db)):
    """Register an offline / mobile farmer directly into the database."""
    import logging
    logger = logging.getLogger(__name__)

    # Validate village existence, fallback gracefully to existing village or create village 1
    village_id = req.village_id
    village_res = await db.execute(select(Village).where(Village.id == village_id))
    village = village_res.scalars().first()
    if not village:
        first_village_res = await db.execute(select(Village))
        first_v = first_village_res.scalars().first()
        if first_v:
            village_id = first_v.id
        else:
            default_v = Village(
                id=1,
                name="Melattur Panchayat",
                name_tamil="மெலட்டூர் ஊராட்சி",
                district="Thanjavur",
                state="Tamil Nadu",
                officer_name="Dr. K. Rathinavelu",
                officer_contact="+91 94431 82910",
                agro_zone="Cauvery Delta Agro-Climatic Zone VII",
                total_farmland_acres=1450.0,
                active_weather_alert="High Canopy Humidity (88%) - Fungal Blight Advisory Active",
                canal_water_status="Borewell Augmented",
            )
            db.add(default_v)
            await db.commit()
            village_id = default_v.id

    # Compute initial risk
    if req.soil_moisture_pct < 25.0:
        risk_level = "CRITICAL"
        risk_title = "Acute Water Stress & Canopy Heat Vulnerability (நீர் பற்றாக்குறை அழுத்தம்)"
        tinyml = "IRRIGATE_URGENT_EVAPOTRANSPIRATION_SPIKE"
    elif req.soil_moisture_pct > 40.0:
        risk_level = "ELEVATED"
        risk_title = "Elevated Fungal Spore Incubation (பூஞ்சாண நோய் பரவல் அபாயம்)"
        tinyml = "HIGH_HUMIDITY_PATHOGEN_INDEX"
    else:
        risk_level = "OPTIMAL"
        risk_title = "Optimal Crop Health & Vigor (ஆரோக்கியமான வளர்ச்சி)"
        tinyml = "TINYML_MONITOR_NORMAL_HEALTH"

    try:
        # Check if farmer with this phone number already exists; if so, update their profile
        existing_res = await db.execute(select(FarmerEntity).where(FarmerEntity.phone_number == req.phone_number))
        farmer = existing_res.scalars().first()

        if farmer:
            farmer.name = req.name
            farmer.name_tamil = req.name_tamil or req.name
            farmer.has_smartphone = req.has_smartphone
            farmer.device_type = req.device_type
            farmer.has_facilities = req.has_smartphone
            farmer.hamlet = req.hamlet
            farmer.farm_name = req.farm_name or farmer.farm_name or f"{req.name}'s Farm"
            farmer.farm_size_acres = req.farm_size_acres
            farmer.primary_crop = req.primary_crop
            farmer.crop_stage = req.crop_stage
            farmer.soil_type = req.soil_type
            farmer.water_source = req.water_source
            farmer.risk_level = risk_level
            farmer.risk_title = risk_title
            farmer.soil_moisture_pct = req.soil_moisture_pct
            farmer.tinyml_edge_decision = tinyml
            if req.recent_disease:
                farmer.recent_disease = req.recent_disease
            if req.disease_tamil:
                farmer.disease_tamil = req.disease_tamil
            if req.recommended_action:
                farmer.recommended_action = req.recommended_action
            if req.recommended_action_tamil:
                farmer.recommended_action_tamil = req.recommended_action_tamil
            farmer.last_interaction = datetime.datetime.utcnow()
        else:
            farmer = FarmerEntity(
                village_id=village_id,
                name=req.name,
                name_tamil=req.name_tamil or req.name,
                phone_number=req.phone_number,
                has_smartphone=req.has_smartphone,
                device_type=req.device_type,
                has_facilities=req.has_smartphone,
                hamlet=req.hamlet,
                farm_name=req.farm_name or f"{req.name}'s Farm",
                farm_size_acres=req.farm_size_acres,
                primary_crop=req.primary_crop,
                crop_stage=req.crop_stage,
                soil_type=req.soil_type,
                water_source=req.water_source,
                risk_level=risk_level,
                risk_title=risk_title,
                soil_moisture_pct=req.soil_moisture_pct,
                soil_ph=6.7,
                nitrogen_kg_ha=145.0,
                phosphorus_kg_ha=16.0,
                potassium_kg_ha=125.0,
                soil_temp_c=31.0,
                tinyml_edge_decision=tinyml,
                recent_disease=req.recent_disease or "Normal Health",
                disease_tamil=req.disease_tamil or "ஆரோக்கியமான வளர்ச்சி",
                recommended_action=req.recommended_action or "Routine crop scouting.",
                recommended_action_tamil=req.recommended_action_tamil or "வழக்கமான பயிர் கண்காணிப்பு.",
                last_interaction=datetime.datetime.utcnow(),
                created_at=datetime.datetime.utcnow(),
            )
            db.add(farmer)

        await db.commit()
        await db.refresh(farmer)
        return {
            "success": True,
            "id": farmer.id,
            "name": farmer.name,
            "phone_number": farmer.phone_number,
            "device_type": farmer.device_type,
            "farm_name": farmer.farm_name,
            "risk_level": farmer.risk_level,
            "soil_moisture_pct": farmer.soil_moisture_pct,
            "message": f"Successfully registered {farmer.name} on the VAO Agronomy Portal",
        }
    except Exception as exc:
        await db.rollback()
        logger.exception("Failed to register farmer: %s", exc)
        return {"success": False, "message": f"Registration failed: {str(exc)}"}




@router.post("/farmers/direct-call/initiate")
async def initiate_direct_call(req: DirectCallRequest, db: AsyncSession = Depends(get_db)):
    """Initiate an instant AI voice call to any given phone number, mapping to existing profile if found."""
    clean_num = req.phone_number.strip().replace(" ", "").replace("-", "")
    res = await db.execute(select(FarmerEntity))
    all_farmers = res.scalars().all()
    
    farmer = None
    for f in all_farmers:
        f_clean = f.phone_number.strip().replace(" ", "").replace("-", "")
        if clean_num in f_clean or f_clean in clean_num:
            farmer = f
            break

    if farmer:
        greeting_ta = (
            f"வணக்கம் {farmer.name_tamil or farmer.name} ஐயா! நான் அக்ரிவின் AI வேளாண்மை உதவியாளர் பேசுகிறேன். "
            f"உங்கள் {farmer.primary_crop} வயலில் சென்சார் ஈரப்பதம் {farmer.soil_moisture_pct}% ஆக உள்ளது. "
            f"உங்களுக்கு ஏதேனும் சந்தேகங்கள் அல்லது உதவிகள் தேவையா?"
        )
        greeting_en = (
            f"Hello Mr. {farmer.name}! I am AgriVyn AI Agriculture Officer calling from the Village Center. "
            f"Your {farmer.primary_crop} field sensor moisture is currently at {farmer.soil_moisture_pct}%. "
            f"Do you have any questions or require any assistance today?"
        )
    else:
        # Create a new offline farmer profile for this phone number so all queries, maps, and notes are saved
        farmer = FarmerEntity(
            village_id=1,
            name=req.caller_name or f"Farmer ({clean_num[-4:] if len(clean_num)>=4 else clean_num})",
            name_tamil="விவசாயி",
            phone_number=req.phone_number,
            has_smartphone=False,
            device_type="FEATURE_PHONE (Low Connectivity / Keypad)",
            has_facilities=False,
            hamlet="Melattur Panchayat",
            farm_name=f"Field Plot ({req.phone_number})",
            farm_size_acres=3.2,
            primary_crop=req.crop or "Paddy (CR1009 / Samba)",
            crop_stage="Panicle Initiation",
            soil_type="Cauvery Delta Clay Loam",
            water_source="Canal + Borewell",
            risk_level="CRITICAL",
            risk_title="Acute Water Stress & Canopy Heat Vulnerability (நீர் பற்றாக்குறை அழுத்தம்)",
            soil_moisture_pct=20.8,
            tinyml_edge_decision="IRRIGATE_URGENT_EVAPOTRANSPIRATION_SPIKE",
            recent_disease="Paddy Blast Spore Incubation (குலை நோய் அபாயம்)",
            disease_tamil="குலை நோய்",
            recommended_action="Run 1.5-hour furrow irrigation immediately. Apply Tricyclazole 75 WP @ 1g/L of water at dusk.",
            recommended_action_tamil="உடனடியாக 1.5 மணி நேரம் பாசனம் செய்யவும். ட்ரைசைக்ளசோல் 75 WP மாலையில் தெளிக்கவும்.",
            last_interaction=datetime.datetime.utcnow(),
            created_at=datetime.datetime.utcnow(),
        )
        db.add(farmer)
        await db.commit()
        await db.refresh(farmer)

        greeting_ta = (
            f"வணக்கம் {farmer.name} ஐயா! நான் மெலட்டூர் வேளாண்மை மையம் அக்ரிவின் AI உதவியாளர் பேசுகிறேன். "
            f"உங்கள் அலைபேசி எண் {farmer.phone_number} இணைக்கப்பட்டுள்ளது. உங்கள் பயிர் சாகுபடி குறித்து என்ன சந்தேகம் உள்ளது?"
        )
        greeting_en = (
            f"Hello {farmer.name}! This is the AgriVyn AI Village Agriculture Assistant calling. "
            f"Your mobile number {farmer.phone_number} is connected. How can we help you with your crop today?"
        )

    farmer_data = {
        "id": farmer.id,
        "name": farmer.name,
        "name_tamil": farmer.name_tamil,
        "phone_number": farmer.phone_number,
        "primary_crop": farmer.primary_crop,
        "soil_moisture_pct": farmer.soil_moisture_pct,
        "risk_level": farmer.risk_level,
        "recommended_action": farmer.recommended_action
    }

    return {
        "success": True,
        "phone_number": req.phone_number,
        "greeting_tamil": greeting_ta,
        "greeting_en": greeting_en,
        "farmer": farmer_data
    }

