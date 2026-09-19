from fastapi import APIRouter, HTTPException
from backend.app.schemas.environment import EnvironmentRiskRequest, EnvironmentRiskResponse
from backend.app.services.environment_service import evaluate_environmental_risk

router = APIRouter(prefix="/environment", tags=["Environmental Risk Engine"])

@router.post("/analyze", response_model=EnvironmentRiskResponse)
async def analyze_environment_endpoint(req: EnvironmentRiskRequest):
    """Evaluate multi-category risks (Drought, Heat Stress, Flood, Disease-Favorable Conditions)."""
    try:
        return evaluate_environmental_risk(req)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Environmental analysis error: {str(e)}")
