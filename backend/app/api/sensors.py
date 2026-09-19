import datetime
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from backend.app.db.database import get_db
from backend.app.db.models import SensorReading
from backend.app.schemas.sensor import SensorIngestRequest, SensorIngestResponse

router = APIRouter(prefix="/sensors", tags=["IoT Sensor Integration"])

@router.post("/ingest", response_model=SensorIngestResponse)
async def ingest_sensor_data(req: SensorIngestRequest, db: AsyncSession = Depends(get_db)):
    """Ingest real-time IoT node measurements (ESP32/Arduino/Soil probes)."""
    try:
        now = datetime.datetime.utcnow()
        reading = SensorReading(
            field_id=req.field_id,
            device_id=req.device_id,
            soil_moisture=req.soil_moisture,
            temperature=req.temperature,
            humidity=req.humidity,
            rainfall=req.rainfall,
            is_demo=req.is_demo,
            timestamp=now
        )
        db.add(reading)
        await db.commit()
        await db.refresh(reading)

        data_label = "DEMO SENSOR DATA" if req.is_demo else "REAL IOT DATA"

        return SensorIngestResponse(
            status="SUCCESS",
            message=f"Sensor reading ingested successfully from {req.device_id} ({data_label})",
            reading_id=reading.id,
            data_type=data_label,
            timestamp=now.isoformat()
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Sensor ingestion error: {str(e)}")

@router.get("/latest")
async def get_latest_sensor_reading(field_id: int = 1, db: AsyncSession = Depends(get_db)):
    """Fetch the latest sensor reading for a field."""
    stmt = select(SensorReading).where(SensorReading.field_id == field_id).order_by(desc(SensorReading.timestamp)).limit(1)
    res = await db.execute(stmt)
    reading = res.scalars().first()

    if not reading:
        return {
            "device_id": "DEMO-NODE-001",
            "field_id": field_id,
            "soil_moisture": 32.5,
            "temperature": 29.4,
            "humidity": 62.0,
            "rainfall": 0.0,
            "is_demo": True,
            "data_label": "DEMO SENSOR DATA",
            "timestamp": datetime.datetime.utcnow().isoformat()
        }

    return {
        "id": reading.id,
        "device_id": reading.device_id,
        "field_id": reading.field_id,
        "soil_moisture": reading.soil_moisture,
        "temperature": reading.temperature,
        "humidity": reading.humidity,
        "rainfall": reading.rainfall,
        "is_demo": reading.is_demo,
        "data_label": "DEMO SENSOR DATA" if reading.is_demo else "REAL IOT DATA",
        "timestamp": reading.timestamp.isoformat()
    }
