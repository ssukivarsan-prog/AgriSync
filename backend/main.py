import os
import sys
import time
import logging
from pathlib import Path
from contextlib import asynccontextmanager

# Ensure project root is in sys.path
ROOT_DIR = Path(__file__).resolve().parent.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse

from backend.app.core.config import settings
from backend.app.db.database import init_db
from backend.app.services.cv_service import cv_engine

# Import routers
from backend.app.api.predict import router as predict_router
from backend.app.api.irrigation import router as irrigation_router
from backend.app.api.environment import router as environment_router
from backend.app.api.sensors import router as sensors_router
from backend.app.api.farm import router as farm_router
from backend.app.api.history import router as history_router
from backend.app.api.models_info import router as models_router
from backend.app.api.admin import router as admin_router
from backend.app.api.telephony import router as telephony_router

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("AgriSyncBackend")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Initializing AgriSync SQLite database...")
    await init_db()
    
    logger.info("Loading computer vision models...")
    cv_engine.load_models()
    
    yield
    # Shutdown
    logger.info("AgriSync backend shutting down...")

app = FastAPI(
    title="AgriSync - Smart Farming AI Assistant Backend",
    description="Field-deployable AI backend for crop disease detection, pest detection, nutrient analysis, smart irrigation, and environmental risk forecasting.",
    version=settings.VERSION,
    lifespan=lifespan
)

# CORS configuration for Flutter Mobile, Web, and Desktop
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static uploads directory for serving scan images
app.mount("/uploads", StaticFiles(directory=str(settings.UPLOAD_DIR)), name="uploads")

# Mount built Flutter Web UI for direct single-server browser demonstration
web_dir = settings.ROOT_DIR / "frontend" / "build" / "web"
if web_dir.exists():
    app.mount("/app", StaticFiles(directory=str(web_dir), html=True), name="flutter_web_app")

# Mount Village Officer & Admin Web Portal
admin_dir = settings.ROOT_DIR / "backend" / "admin_web"
admin_dir.mkdir(parents=True, exist_ok=True)
app.mount("/admin", StaticFiles(directory=str(admin_dir), html=True), name="admin_web_portal")

# Include API Routers
app.include_router(predict_router, prefix=settings.API_V1_STR)
app.include_router(irrigation_router, prefix=settings.API_V1_STR)
app.include_router(environment_router, prefix=settings.API_V1_STR)
app.include_router(sensors_router, prefix=settings.API_V1_STR)
app.include_router(farm_router, prefix=settings.API_V1_STR)
app.include_router(history_router, prefix=settings.API_V1_STR)
app.include_router(models_router, prefix=settings.API_V1_STR)
app.include_router(admin_router, prefix=settings.API_V1_STR)
app.include_router(telephony_router, prefix=settings.API_V1_STR)

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    response.headers["X-Process-Time-Ms"] = f"{process_time:.2f}"
    return response

@app.get("/")
async def root():
    return {
        "app": "AgriVyn AI Backend",
        "tagline": "AI-powered intelligence for healthier, smarter and more resilient farms.",
        "sih_problem_id": "26180",
        "version": settings.VERSION,
        "status": "OPERATIONAL",
        "docs_url": "/docs"
    }

@app.get("/health")
@app.get("/api/health")
async def health_check():
    return {
        "status": "HEALTHY",
        "timestamp": time.time(),
        "models_loaded": {
            "disease_model": cv_engine.disease_model is not None,
            "nutrient_model": cv_engine.nutrient_model is not None,
            "pest_model": cv_engine.pest_model is not None,
            "segmentation_model": cv_engine.seg_model is not None,
            "xgboost_env_model": True,
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="0.0.0.0", port=8000, reload=True)
