import os
from pathlib import Path
from dataclasses import dataclass, field
import dotenv

BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent

# Load .env file from project root if present
dotenv.load_dotenv(BASE_DIR / ".env")

@dataclass
class Settings:
    PROJECT_NAME: str = "AgriSync"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api"
    
    # Base and Data paths
    ROOT_DIR: Path = BASE_DIR
    DATA_DIR: Path = BASE_DIR / "data"
    MODELS_DIR: Path = BASE_DIR / "models"
    UPLOAD_DIR: Path = BASE_DIR / "data" / "uploads"
    
    # Model Weights
    DISEASE_MODEL_PATH: Path = BASE_DIR / "models" / "disease" / "disease_model_v1.pt"
    DISEASE_MAPPING_PATH: Path = BASE_DIR / "models" / "disease" / "class_mapping.json"
    
    NUTRIENT_MODEL_PATH: Path = BASE_DIR / "models" / "nutrient" / "nutrient_model_v1.pt"
    NUTRIENT_MAPPING_PATH: Path = BASE_DIR / "models" / "nutrient" / "class_mapping.json"
    
    PEST_MODEL_PATH: Path = BASE_DIR / "models" / "pest" / "pest_model_v1.pt"
    SEG_MODEL_PATH: Path = BASE_DIR / "models" / "segmentation" / "seg_model_v1.pt"
    DIAGNOSTIC_MODEL_PATH: Path = BASE_DIR / "models" / "diagnostic" / "symptom_models.joblib"
    
    # Database
    DATABASE_URL: str = f"sqlite+aiosqlite:///{BASE_DIR / 'data' / 'agrivyn.db'}"
    
    # Upload limits (15 MB)
    MAX_UPLOAD_SIZE: int = 15 * 1024 * 1024
    ALLOWED_EXTENSIONS: set = field(default_factory=lambda: {".jpg", ".jpeg", ".png", ".webp"})
    
    # Confidence Thresholds
    CONFIDENCE_HIGH: float = 0.80
    CONFIDENCE_MODERATE: float = 0.60
    
    # Telephony & Twilio Voice Configuration
    TWILIO_ACCOUNT_SID: str = os.getenv("TWILIO_ACCOUNT_SID", "").strip()
    TWILIO_AUTH_TOKEN: str = os.getenv("TWILIO_AUTH_TOKEN", "").strip()
    TWILIO_PHONE_NUMBER: str = os.getenv("TWILIO_PHONE_NUMBER", "").strip()
    PUBLIC_SERVER_URL: str = os.getenv("PUBLIC_SERVER_URL", "").strip()
    TWILIO_VOICE_URL: str = os.getenv("TWILIO_VOICE_URL", "https://webhooks.twilio.com/v1/Voice/Template/voice_speech_recognition").strip()
    DEFAULT_CALL_LANGUAGE: str = os.getenv("DEFAULT_CALL_LANGUAGE", "ta").strip()

    @property
    def is_twilio_configured(self) -> bool:
        return bool(self.TWILIO_ACCOUNT_SID and self.TWILIO_AUTH_TOKEN and self.TWILIO_PHONE_NUMBER and "your_" not in self.TWILIO_ACCOUNT_SID)

settings = Settings()

# Ensure directories exist
settings.DATA_DIR.mkdir(parents=True, exist_ok=True)
settings.MODELS_DIR.mkdir(parents=True, exist_ok=True)
settings.UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

