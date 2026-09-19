import os
import json
import datetime
import logging
from pathlib import Path
from typing import Optional, Dict, Any
from fastapi import APIRouter, Request, Response, HTTPException, Depends, Form
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from backend.app.core.config import settings, BASE_DIR
from backend.app.db.database import get_db
from backend.app.db.admin_models import FarmerEntity, CallNote
from backend.app.services.telephony_service import telephony_service, TelephonyService
from backend.app.api.admin import generate_ai_agronomist_reply

logger = logging.getLogger("AgriVynTelephonyAPI")
router = APIRouter(prefix="/telephony", tags=["Telephony & AI Voice Calls"])

# In-memory call conversation log — stores the last 50 real phone call exchanges
# Each entry: {"call_sid", "farmer", "crop", "timestamp", "turns": [{speaker, text, time}]}
_CALL_LOG: list = []
_ACTIVE_CALLS: dict = {}  # call_sid -> log entry index

class RealCallRequest(BaseModel):
    phone_number: str
    farmer_name: Optional[str] = "Murugan Selvam"
    crop: Optional[str] = "Paddy (Samba)"
    reason: Optional[str] = "Soil Moisture Deficit (மண் ஈரப்பதம் குறைவு)"
    recommended_action: Optional[str] = "Run 1.5-hour furrow wetting cycle immediately"
    language: Optional[str] = "ta"
    custom_message: Optional[str] = None
    farmer_id: Optional[int] = None

class UpdateTelephonyConfigRequest(BaseModel):
    account_sid: str
    auth_token: str
    phone_number: str
    public_server_url: Optional[str] = None


@router.get("/config-status")
async def get_telephony_config_status():
    """Returns current status of Twilio voice credentials (safely masked)."""
    masked_sid = ""
    masked_phone = ""
    if settings.TWILIO_ACCOUNT_SID:
        masked_sid = settings.TWILIO_ACCOUNT_SID[:6] + "..." + settings.TWILIO_ACCOUNT_SID[-4:]
    if settings.TWILIO_PHONE_NUMBER:
        masked_phone = settings.TWILIO_PHONE_NUMBER[:4] + "***" + settings.TWILIO_PHONE_NUMBER[-3:]

    return {
        "is_configured": settings.is_twilio_configured,
        "account_sid_masked": masked_sid,
        "twilio_phone_masked": masked_phone,
        "public_server_url": settings.PUBLIC_SERVER_URL or "Not Set (Direct TwiML Mode Active)",
        "default_language": settings.DEFAULT_CALL_LANGUAGE,
        "mode": "interactive_webhook" if (settings.PUBLIC_SERVER_URL and settings.PUBLIC_SERVER_URL.startswith("http")) else "direct_inline_twiml"
    }


@router.post("/update-config")
async def update_telephony_config(req: UpdateTelephonyConfigRequest):
    """
    Dynamically saves Twilio credentials to .env file and updates settings in-memory.
    Allows user to enter credentials directly from the VAO Admin Web Portal.
    """
    sid = req.account_sid.strip()
    token = req.auth_token.strip()
    phone = req.phone_number.strip()
    public_url = (req.public_server_url or "").strip()

    if not sid or not token or not phone:
        raise HTTPException(status_code=400, detail="Account SID, Auth Token, and Phone Number are required.")

    # Update in-memory settings
    settings.TWILIO_ACCOUNT_SID = sid
    settings.TWILIO_AUTH_TOKEN = token
    settings.TWILIO_PHONE_NUMBER = phone
    settings.PUBLIC_SERVER_URL = public_url

    # Persist to .env
    env_path = BASE_DIR / ".env"
    env_content = (
        f"# AgriVyn Telephony Configuration (Updated {datetime.datetime.utcnow().isoformat()})\n"
        f"TWILIO_ACCOUNT_SID={sid}\n"
        f"TWILIO_AUTH_TOKEN={token}\n"
        f"TWILIO_PHONE_NUMBER={phone}\n"
        f"PUBLIC_SERVER_URL={public_url}\n"
        f"DEFAULT_CALL_LANGUAGE={settings.DEFAULT_CALL_LANGUAGE}\n"
    )
    env_path.write_text(env_content, encoding="utf-8")
    logger.info("Saved updated Twilio credentials to .env")

    return {
        "success": True,
        "message": "Twilio Telephony credentials successfully saved and activated.",
        "is_configured": settings.is_twilio_configured,
        "phone_number": phone
    }


@router.post("/call-real-phone")
async def call_real_phone(req: RealCallRequest, db: AsyncSession = Depends(get_db)):
    """
    DIALS A REAL OUTBOUND TELEPHONE CALL TO THE GIVEN MOBILE NUMBER.
    Speaks an agricultural advisory tailored to the crop and farmer.
    """
    logger.info(f"Received request to dial real mobile phone: {req.phone_number} for farmer: {req.farmer_name}")

    # Initiate call via telephony service
    result = telephony_service.make_real_call(
        to_phone=req.phone_number,
        farmer_name=req.farmer_name or "Farmer",
        crop=req.crop or "Paddy (Samba)",
        reason=req.reason or "Soil Moisture Deficit",
        recommended_action=req.recommended_action,
        language=req.language or "ta",
        custom_message=req.custom_message
    )

    # If call succeeded and a farmer_id was associated, log interaction
    if result.get("success") and req.farmer_id:
        try:
            res = await db.execute(select(FarmerEntity).where(FarmerEntity.id == req.farmer_id))
            farmer = res.scalars().first()
            if farmer:
                farmer.last_interaction = datetime.datetime.utcnow()
                note = CallNote(
                    farmer_id=farmer.id,
                    call_duration_seconds=0,
                    farmer_mood="CALLED_OUTBOUND",
                    extracted_queries_json=json.dumps([f"Outbound AI Telephony Call: {req.reason}"], ensure_ascii=False),
                    ai_response_summary=f"Automated Voice Call SID: {result.get('call_sid')}. Spoken: {req.reason}",
                    officer_action_items_json=json.dumps([f"Verify farmer received advisory at {req.phone_number}"], ensure_ascii=False),
                    is_resolved=False,
                    transcript_json=json.dumps([{"role": "assistant", "message": result.get("spoken_preview", "")}], ensure_ascii=False),
                    timestamp=datetime.datetime.utcnow()
                )
                db.add(note)
                await db.commit()
                result["note_id"] = note.id
        except Exception as e:
            logger.error(f"Error recording CallNote for real phone call: {e}")

    return result



@router.api_route("/twiml/welcome", methods=["GET", "POST"])
async def twiml_welcome(
    request: Request,
    lang: str = "ta",
    name: str = "Farmer",
    crop: str = "Paddy",
    reason: str = "Field advisory",
    action: str = ""
):
    """TwiML Webhook endpoint called by Twilio when the farmer answers the phone.
    Uses crop, reason, and action from URL query parameters so the real advisory
    data from the admin portal is spoken — not hardcoded test content.
    """
    callback_action_url = ""
    if settings.PUBLIC_SERVER_URL:
        callback_action_url = (
            f"{settings.PUBLIC_SERVER_URL.rstrip('/')}/api/telephony/twiml/conversation"
            f"?lang={lang}&name={name}&crop={crop}"
        )

    message = TelephonyService.build_advisory_message(
        farmer_name=name,
        crop=crop,
        reason=reason,
        recommended_action=action if action else None,
        language=lang
    )

    # Log this call to the in-memory call log
    call_sid = None
    if request.method == "POST":
        try:
            form = await request.form()
            call_sid = form.get("CallSid")
        except Exception:
            pass
    if not call_sid:
        call_sid = request.query_params.get("CallSid", f"sim_{datetime.datetime.now().strftime('%H%M%S')}")

    now = datetime.datetime.now().strftime("%H:%M:%S")
    log_entry = {
        "call_sid": call_sid,
        "farmer": name,
        "crop": crop,
        "reason": reason,
        "action": action,
        "language": lang,
        "started_at": now,
        "turns": [
            {"speaker": "AI", "text": message, "time": now}
        ]
    }
    _CALL_LOG.append(log_entry)
    if len(_CALL_LOG) > 50:
        _CALL_LOG.pop(0)
    _ACTIVE_CALLS[call_sid] = len(_CALL_LOG) - 1
    logger.info(f"[CallLog] New call started: SID={call_sid}, Farmer={name}, Crop={crop}")

    twiml_xml = TelephonyService.build_inline_twiml(
        message=message,
        language=lang,
        allow_farmer_reply=bool(callback_action_url),
        webhook_action_url=callback_action_url
    )

    return Response(content=twiml_xml, media_type="application/xml")



@router.api_route("/twiml/conversation", methods=["GET", "POST"])
async def twiml_conversation(
    request: Request,
    lang: str = "ta",
    name: str = "Farmer"
):
    """
    TwiML Webhook endpoint called when the farmer speaks during the call.
    Receives SpeechResult from Twilio Speech-to-Text, consults the AI Agronomist,
    and returns a spoken response directly back to the phone call.
    """
    speech_result = None
    if request.method == "POST":
        try:
            form = await request.form()
            speech_result = form.get("SpeechResult")
        except Exception:
            pass
    if not speech_result:
        speech_result = request.query_params.get("SpeechResult")

    logger.info(f"Telephony Call SpeechResult received from {name}: '{speech_result}'")
    user_query = speech_result or "வணக்கம்"

    # Log farmer speech turn
    call_sid = None
    if request.method == "POST":
        try:
            form = await request.form()
            call_sid = form.get("CallSid")
        except Exception:
            pass
    if not call_sid:
        call_sid = request.query_params.get("CallSid", "unknown")
    now = datetime.datetime.now().strftime("%H:%M:%S")
    if call_sid in _ACTIVE_CALLS:
        idx = _ACTIVE_CALLS[call_sid]
        if idx < len(_CALL_LOG):
            _CALL_LOG[idx]["turns"].append({"speaker": "FARMER", "text": user_query, "time": now})

    # Create synthetic farmer context for reasoning
    crop_param = request.query_params.get("crop", "Paddy (Samba)")
    fake_farmer = FarmerEntity(
        name=name,
        name_tamil=name,
        primary_crop=crop_param,
        soil_moisture_pct=22.0,
        recent_disease="Paddy Blast Suspected"
    )

    # Query the AI Agronomist engine
    ai_result = generate_ai_agronomist_reply(fake_farmer, user_query)
    reply_text = ai_result["reply"]

    # Log AI reply turn
    now2 = datetime.datetime.now().strftime("%H:%M:%S")
    if call_sid in _ACTIVE_CALLS:
        idx = _ACTIVE_CALLS[call_sid]
        if idx < len(_CALL_LOG):
            _CALL_LOG[idx]["turns"].append({"speaker": "AI", "text": reply_text, "time": now2})

    # Wrap in TwiML response
    twiml_xml = TelephonyService.build_inline_twiml(
        message=reply_text,
        language=lang,
        allow_farmer_reply=False
    )

    return Response(content=twiml_xml, media_type="application/xml")


@router.api_route("/twiml/status-callback", methods=["GET", "POST"])
async def twiml_status_callback(
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """Twilio Call Status Webhook: Logs final duration and completion to database."""
    call_sid = None
    call_status = None
    call_duration = None

    if request.method == "POST":
        try:
            form = await request.form()
            call_sid = form.get("CallSid")
            call_status = form.get("CallStatus")
            call_duration = form.get("CallDuration")
        except Exception:
            pass

    if not call_sid:
        call_sid = request.query_params.get("CallSid")
        call_status = request.query_params.get("CallStatus")
        call_duration = request.query_params.get("CallDuration")

    logger.info(f"Twilio Call Status Callback: SID={call_sid}, Status={call_status}, Duration={call_duration}s")
    
    if call_duration and call_sid:
        try:
            duration = int(call_duration)
            # Find and update CallNote if matches CallSid
            res = await db.execute(
                select(CallNote)
                .where(CallNote.ai_response_summary.contains(call_sid))
            )
            note = res.scalars().first()
            if note:
                note.call_duration_seconds = duration
                await db.commit()
                logger.info(f"Updated CallNote #{note.id} with final duration {duration}s")
        except Exception as e:
            logger.error(f"Failed to update CallNote status: {e}")

    return {"status": "recorded", "call_sid": call_sid}


@router.get("/call-log")
async def get_call_log():
    """Returns the in-memory log of real phone call conversations.
    Each entry contains the farmer name, crop, advisory reason, and all dialogue turns
    (AI advisory + farmer speech responses). Used by the admin portal to display
    live call transcripts.
    """
    return list(reversed(_CALL_LOG))  # Newest first
