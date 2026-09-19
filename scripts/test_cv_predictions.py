import sys, os
from pathlib import Path
from PIL import Image
import numpy as np

# Add project root to sys.path
BASE_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BASE_DIR))

from backend.app.services.cv_service import cv_engine

def test_samples():
    cv_engine.load_models()
    
    samples = [
        ("tomato_early_blight.jpg", "Tomato Early Blight"),
        ("pest_sample.jpg", "AgroPest-12 Ant Cluster"),
        ("nutrient_nitrogen.jpg", "Gourd Nitrogen Deficiency Chlorosis"),
        ("tomato_healthy.jpg", "Tomato Healthy Leaf")
    ]
    
    for filename, desc in samples:
        path = BASE_DIR / "frontend" / "assets" / "samples" / filename
        print(f"\n==========================================")
        print(f"TESTING: {filename} ({desc})")
        print(f"==========================================")
        img = Image.open(path).convert("RGB")
        
        # Test unified scan
        unified = cv_engine.unified_scan(img)
        print(f"  Crop: {unified.crop}")
        print(f"  Overall Health: {unified.overall_health}")
        print(f"  Disease: {unified.disease.prediction} ({unified.disease.confidence*100:.1f}%) [{unified.disease.health_status}]")
        if unified.pest:
            print(f"  Pest: count={unified.pest.pest_count}, primary={unified.pest.primary_pest} ({unified.pest.confidence*100:.1f}%), risk={unified.pest.infestation_risk}")
        if unified.nutrient:
            print(f"  Nutrient: {unified.nutrient.deficiency} ({unified.nutrient.confidence*100:.1f}%)")
        if unified.segmentation:
            print(f"  Segmentation: affected={unified.segmentation.affected_area_percentage}%, lesions={unified.segmentation.lesion_count}, severity={unified.segmentation.severity_category}")
        print(f"  Advisory Root Cause: {unified.root_cause.pathogen_name if unified.root_cause else 'N/A'}")
        print(f"  Advisory Summary: {unified.advisory_summary[:120]}...")

if __name__ == "__main__":
    test_samples()
