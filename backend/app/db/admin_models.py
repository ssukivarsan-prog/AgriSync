import datetime
from sqlalchemy import Column, Integer, Float, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from backend.app.db.models import Base

class Village(Base):
    __tablename__ = "villages"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    name_tamil = Column(String(100), nullable=True)
    district = Column(String(100), default="Thanjavur")
    state = Column(String(100), default="Tamil Nadu")
    officer_name = Column(String(100), default="Dr. K. Rathinavelu (VAO)")
    officer_contact = Column(String(50), default="+91 94432 10874")
    agro_zone = Column(String(150), default="Cauvery Delta Agro-Climatic Zone")
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    farmers = relationship("FarmerEntity", back_populates="village", cascade="all, delete-orphan")


class FarmerEntity(Base):
    __tablename__ = "farmer_entities"

    id = Column(Integer, primary_key=True, index=True)
    village_id = Column(Integer, ForeignKey("villages.id"), nullable=False)
    name = Column(String(100), nullable=False)
    name_tamil = Column(String(100), nullable=True)
    phone_number = Column(String(30), nullable=False)
    has_smartphone = Column(Boolean, default=False)
    device_type = Column(String(100), default="FEATURE_PHONE (2G Keypad)")
    has_facilities = Column(Boolean, default=False)
    hamlet = Column(String(100), default="Main Street")
    farm_name = Column(String(100), default="Cauvery Family Farm")
    farm_size_acres = Column(Float, default=4.0)
    primary_crop = Column(String(100), default="Paddy (CR1009 / Samba)")
    crop_stage = Column(String(50), default="Tillering / Active Growth")
    soil_type = Column(String(100), default="Alluvial Clay Loam")
    water_source = Column(String(100), default="Borewell + Canal")
    
    # Telemetry & AI Risk
    risk_level = Column(String(30), default="MODERATE") # CRITICAL, ELEVATED, MODERATE, OPTIMAL
    risk_title = Column(String(200), default="Optimal Crop Health & Vigor")
    soil_moisture_pct = Column(Float, default=32.0)
    soil_ph = Column(Float, default=6.8)
    nitrogen_kg_ha = Column(Float, default=165.0)
    phosphorus_kg_ha = Column(Float, default=18.0)
    potassium_kg_ha = Column(Float, default=135.0)
    soil_temp_c = Column(Float, default=29.5)
    tinyml_edge_decision = Column(String(100), default="TINYML_MONITOR_NORMAL")
    recent_disease = Column(String(150), nullable=True)
    disease_tamil = Column(String(150), nullable=True)
    recommended_action = Column(Text, nullable=True)
    recommended_action_tamil = Column(Text, nullable=True)
    last_interaction = Column(DateTime, default=datetime.datetime.utcnow)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    village = relationship("Village", back_populates="farmers")
    sms_logs = relationship("SMSDispatchLog", back_populates="farmer", cascade="all, delete-orphan")
    call_notes = relationship("CallNote", back_populates="farmer", cascade="all, delete-orphan")


class SMSDispatchLog(Base):
    __tablename__ = "sms_dispatch_logs"

    id = Column(Integer, primary_key=True, index=True)
    farmer_id = Column(Integer, ForeignKey("farmer_entities.id"), nullable=False)
    recipient_phone = Column(String(30), nullable=False)
    message_tamil = Column(Text, nullable=True)
    message_english = Column(Text, nullable=False)
    delivery_status = Column(String(30), default="DELIVERED") # DELIVERED, QUEUED, FAILED
    carrier_ref = Column(String(100), default="BSNL-AGRI-IVR-TX")
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)

    farmer = relationship("FarmerEntity", back_populates="sms_logs")


class CallNote(Base):
    __tablename__ = "call_notes"

    id = Column(Integer, primary_key=True, index=True)
    farmer_id = Column(Integer, ForeignKey("farmer_entities.id"), nullable=False)
    call_duration_seconds = Column(Integer, default=120)
    farmer_mood = Column(String(50), default="SEEKING_ADVICE") # ANXIOUS, SEEKING_ADVICE, RELIEVED, SATISFIED
    extracted_queries_json = Column(Text, nullable=True) # JSON list of questions
    ai_response_summary = Column(Text, nullable=True)
    officer_action_items_json = Column(Text, nullable=True) # JSON list of tasks
    is_resolved = Column(Boolean, default=False)
    transcript_json = Column(Text, nullable=True) # Full conversation history
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)

    farmer = relationship("FarmerEntity", back_populates="call_notes")
