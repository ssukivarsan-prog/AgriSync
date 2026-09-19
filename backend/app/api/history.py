import json
from typing import Optional
from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from backend.app.db.database import get_db
from backend.app.db.models import ScanResult

router = APIRouter(prefix="/history", tags=["Scan History"])

@router.get("")
async def get_scan_history(
    crop: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve previous AI scan diagnostic reports."""
    query = select(ScanResult).order_by(desc(ScanResult.timestamp))
    if crop:
        query = query.where(ScanResult.crop.ilike(f"%{crop}%"))
    if status:
        query = query.where(ScanResult.health_status == status)

    query = query.limit(limit)
    res = await db.execute(query)
    records = res.scalars().all()

    items = []
    for r in records:
        top_preds = []
        if r.top_predictions_json:
            try:
                top_preds = json.loads(r.top_predictions_json)
            except Exception:
                pass

        pest_dets = []
        if r.pest_detections_json:
            try:
                pest_dets = json.loads(r.pest_detections_json)
            except Exception:
                pass

        items.append({
            "id": r.id,
            "field_id": r.field_id,
            "crop": r.crop,
            "disease_prediction": r.disease_prediction,
            "disease_confidence": r.disease_confidence,
            "health_status": r.health_status,
            "top_predictions": top_preds,
            "pest_detections": pest_dets,
            "nutrient_prediction": r.nutrient_prediction,
            "nutrient_confidence": r.nutrient_confidence,
            "affected_area_pct": r.affected_area_pct,
            "advisory_notes": r.advisory_notes,
            "image_path": r.image_path,
            "model_version": r.model_version,
            "timestamp": r.timestamp.isoformat()
        })

    return {
        "count": len(items),
        "items": items
    }

@router.get("/{scan_id}")
async def get_scan_detail(scan_id: int, db: AsyncSession = Depends(get_db)):
    """Fetch detailed single scan record."""
    res = await db.execute(select(ScanResult).where(ScanResult.id == scan_id))
    r = res.scalars().first()
    if not r:
        raise HTTPException(status_code=404, detail="Scan record not found.")

    return {
        "id": r.id,
        "crop": r.crop,
        "disease_prediction": r.disease_prediction,
        "disease_confidence": r.disease_confidence,
        "health_status": r.health_status,
        "top_predictions": json.loads(r.top_predictions_json) if r.top_predictions_json else [],
        "pest_detections": json.loads(r.pest_detections_json) if r.pest_detections_json else [],
        "nutrient_prediction": r.nutrient_prediction,
        "nutrient_confidence": r.nutrient_confidence,
        "affected_area_pct": r.affected_area_pct,
        "advisory_notes": r.advisory_notes,
        "image_path": r.image_path,
        "timestamp": r.timestamp.isoformat()
    }

@router.delete("/{scan_id}")
async def delete_scan_record(scan_id: int, db: AsyncSession = Depends(get_db)):
    """Delete a scan record from history."""
    res = await db.execute(select(ScanResult).where(ScanResult.id == scan_id))
    r = res.scalars().first()
    if not r:
        raise HTTPException(status_code=404, detail="Scan record not found.")

    await db.delete(r)
    await db.commit()
    return {"status": "SUCCESS", "message": f"Scan record {scan_id} deleted."}
