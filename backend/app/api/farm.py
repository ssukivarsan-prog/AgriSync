import json
import datetime
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from backend.app.db.database import get_db
from backend.app.db.models import Farm, Field, ScanResult, SensorReading, Alert
from backend.app.schemas.quotation import CropQuotationRequest
from backend.app.services.quotation_service import generate_crop_quotation

router = APIRouter(prefix="/farm", tags=["Farm Management & Analytics"])

@router.get("/summary")
async def get_farm_summary(db: AsyncSession = Depends(get_db)):
    """Retrieve top-level farm overview, overall health scores, alerts, and field states."""
    try:
        # Get primary farm
        farm_res = await db.execute(select(Farm))
        farm = farm_res.scalars().first()

        # Get fields
        fields_res = await db.execute(select(Field))
        fields = fields_res.scalars().all()

        # Get recent scans
        scans_res = await db.execute(select(ScanResult).order_by(desc(ScanResult.timestamp)).limit(10))
        scans = scans_res.scalars().all()

        # Get active alerts
        alerts_res = await db.execute(select(Alert).where(Alert.is_resolved == False).order_by(desc(Alert.timestamp)).limit(5))
        alerts = alerts_res.scalars().all()

        # Get latest sensor reading
        sensor_res = await db.execute(select(SensorReading).order_by(desc(SensorReading.timestamp)).limit(1))
        latest_sensor = sensor_res.scalars().first()

        # Compute genuine aggregate health score
        total_scans = len(scans)
        healthy_scans = sum(1 for s in scans if s.health_status == "HEALTHY")
        crop_health_pct = round((healthy_scans / total_scans * 100.0), 1) if total_scans > 0 else 88.0

        # Soil moisture indicator
        sm = latest_sensor.soil_moisture if latest_sensor else 34.0
        if sm < 28.0:
            water_status = "DEFICIT (NEEDS WATER)"
            water_score = 60
        elif sm > 65.0:
            water_status = "SATURATED"
            water_score = 75
        else:
            water_status = "OPTIMAL"
            water_score = 95

        pest_risk = "LOW"
        for s in scans:
            if s.pest_detections_json:
                try:
                    dets = json.loads(s.pest_detections_json)
                    if len(dets) >= 5:
                        pest_risk = "HIGH"
                        break
                    elif len(dets) >= 2:
                        pest_risk = "MODERATE"
                except Exception:
                    pass

        farm_health = round((crop_health_pct * 0.5 + water_score * 0.3 + (95 if pest_risk == "LOW" else (70 if pest_risk == "MODERATE" else 45)) * 0.2), 1)

        return {
            "farm_name": farm.name if farm else "AgriSync Model Farm",
            "location": farm.location if farm else "Maharashtra, India",
            "total_area_acres": farm.total_area_acres if farm else 15.0,
            "overall_farm_health_score": farm_health,
            "crop_health_score": crop_health_pct,
            "pest_risk": pest_risk,
            "water_status": water_status,
            "heat_risk": "MODERATE" if (latest_sensor and latest_sensor.temperature > 33.0) else "LOW",
            "environmental_risk": "MODERATE" if alerts else "LOW",
            "total_fields": len(fields),
            "fields": [
                {
                    "id": f.id,
                    "name": f.name,
                    "crop": f.crop,
                    "variety": f.variety,
                    "growth_stage": f.growth_stage,
                    "area_acres": f.area_acres,
                    "soil_type": f.soil_type
                } for f in fields
            ],
            "active_alerts_count": len(alerts),
            "recent_alerts": [
                {
                    "id": a.id,
                    "severity": a.severity,
                    "title": a.title,
                    "message": a.message,
                    "action": a.action_needed,
                    "timestamp": a.timestamp.isoformat()
                } for a in alerts
            ],
            "latest_sensor": {
                "soil_moisture": sm,
                "temperature": latest_sensor.temperature if latest_sensor else 30.5,
                "humidity": latest_sensor.humidity if latest_sensor else 55.0,
                "rainfall": latest_sensor.rainfall if latest_sensor else 0.0,
                "is_demo": latest_sensor.is_demo if latest_sensor else True,
                "data_label": "DEMO SENSOR DATA" if (latest_sensor and latest_sensor.is_demo) else "REAL IOT DATA"
            },
            "timestamp": datetime.datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Farm summary error: {str(e)}")

@router.get("/analytics")
async def get_farm_analytics(db: AsyncSession = Depends(get_db)):
    """Return historical time-series analytics for charts."""
    scans_res = await db.execute(select(ScanResult).order_by(ScanResult.timestamp))
    scans = scans_res.scalars().all()

    sensors_res = await db.execute(select(SensorReading).order_by(SensorReading.timestamp).limit(20))
    sensors = sensors_res.scalars().all()

    # Build trend series
    disease_counts = {}
    for s in scans:
        disease_counts[s.disease_prediction] = disease_counts.get(s.disease_prediction, 0) + 1

    moisture_trend = [
        {"time": s.timestamp.strftime("%H:%M"), "moisture": s.soil_moisture, "temp": s.temperature}
        for s in sensors
    ]

    return {
        "disease_distribution": disease_counts,
        "soil_moisture_trend": moisture_trend,
        "total_scans_logged": len(scans),
        "timestamp": datetime.datetime.utcnow().isoformat()
    }

@router.get("/zones")
async def get_iot_zones():
    """Retrieve the available IoT hardware zones and their live baseline telemetry."""
    from backend.app.services.quotation_service import ZONE_PROFILES
    return list(ZONE_PROFILES.values())

@router.post("/quotation/generate")
async def generate_crop_quotation_api(req: CropQuotationRequest):
    """Generate an AI-assisted crop investment quotation & variance diff for a specific IoT Zone."""
    try:
        return generate_crop_quotation(req)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Quotation generation error: {str(e)}")
