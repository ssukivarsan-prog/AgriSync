from fastapi import APIRouter, HTTPException
from backend.app.schemas.irrigation import IrrigationAnalysisRequest, IrrigationAnalysisResponse
from backend.app.services.irrigation_service import analyze_irrigation

router = APIRouter(prefix="/irrigation", tags=["Smart Irrigation Engine"])

@router.post("/analyze", response_model=IrrigationAnalysisResponse)
async def analyze_irrigation_endpoint(req: IrrigationAnalysisRequest):
    """Analyze soil moisture, environmental parameters, and crop stage to generate precision irrigation advice."""
    try:
        return analyze_irrigation(req)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Irrigation analysis error: {str(e)}")
