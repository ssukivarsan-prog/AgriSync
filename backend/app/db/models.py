import datetime
from sqlalchemy import Column, Integer, Float, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()

class Farm(Base):
    __tablename__ = "farms"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False, default="AgriVyn Model Farm")
    location = Column(String(150), default="Nashik, Maharashtra, India")
    total_area_acres = Column(Float, default=12.5)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    fields = relationship("Field", back_populates="farm", cascade="all, delete-orphan")


class Field(Base):
    __tablename__ = "fields"

    id = Column(Integer, primary_key=True, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=False)
    name = Column(String(100), nullable=False)
    crop = Column(String(50), nullable=False, default="Tomato")
    variety = Column(String(50), default="Arka Rakshak")
    growth_stage = Column(String(50), default="Flowering")  # Vegetative, Flowering, Fruiting, Maturity
    soil_type = Column(String(50), default="Loamy")         # Clay, Sandy, Loamy, Silt
    area_acres = Column(Float, default=2.5)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    farm = relationship("Farm", back_populates="fields")
    sensor_readings = relationship("SensorReading", back_populates="field", cascade="all, delete-orphan")
    scan_results = relationship("ScanResult", back_populates="field", cascade="all, delete-orphan")
    alerts = relationship("Alert", back_populates="field", cascade="all, delete-orphan")


class SensorReading(Base):
    __tablename__ = "sensor_readings"

    id = Column(Integer, primary_key=True, index=True)
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=True)
    device_id = Column(String(50), default="NODE-ESP32-001")
    soil_moisture = Column(Float, nullable=False)   # Percentage (0-100%)
    temperature = Column(Float, nullable=False)     # Celsius
    humidity = Column(Float, nullable=False)        # Percentage (0-100%)
    rainfall = Column(Float, default=0.0)           # mm
    is_demo = Column(Boolean, default=False)        # Explicit DEMO DATA label
    timestamp = Column(DateTime, default=datetime.datetime.utcnow, index=True)

    field = relationship("Field", back_populates="sensor_readings")


class ScanResult(Base):
    __tablename__ = "scan_results"

    id = Column(Integer, primary_key=True, index=True)
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=True)
    crop = Column(String(50), nullable=False)
    disease_prediction = Column(String(100), nullable=False)
    disease_confidence = Column(Float, nullable=False)
    health_status = Column(String(50), default="HEALTHY") # HEALTHY, AT_RISK, UNCERTAIN
    top_predictions_json = Column(Text, nullable=True)     # JSON array of top-3 predictions
    pest_detections_json = Column(Text, nullable=True)     # JSON array of bounding box detections
    nutrient_prediction = Column(String(100), nullable=True)
    nutrient_confidence = Column(Float, nullable=True)
    affected_area_pct = Column(Float, default=0.0)         # Visual AI affected area %
    advisory_notes = Column(Text, nullable=True)
    image_path = Column(String(255), nullable=True)
    model_version = Column(String(50), default="1.0.0")
    timestamp = Column(DateTime, default=datetime.datetime.utcnow, index=True)

    field = relationship("Field", back_populates="scan_results")


class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    field_id = Column(Integer, ForeignKey("fields.id"), nullable=True)
    severity = Column(String(20), default="MODERATE") # LOW, MODERATE, HIGH, CRITICAL
    title = Column(String(150), nullable=False)
    message = Column(Text, nullable=False)
    action_needed = Column(Text, nullable=True)
    is_resolved = Column(Boolean, default=False)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow, index=True)

    field = relationship("Field", back_populates="alerts")
