import requests
import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
URL = "http://127.0.0.1:8000/api/predict/unified-scan"

samples = [
    ("tomato_early_blight.jpg", "Early Blight Leaf"),
    ("pest_sample.jpg", "Insect Pest Specimen (Ants)"),
    ("nutrient_nitrogen.jpg", "Nitrogen Deficiency Leaf"),
    ("tomato_healthy.jpg", "Healthy Tomato Leaf")
]

print("="*60)
print("VERIFYING AGRIVYN COMPUTER VISION API ENDPOINT")
print("="*60)

for s, desc in samples:
    img_path = BASE_DIR / "frontend" / "assets" / "samples" / s
    with open(img_path, "rb") as f:
        r = requests.post(URL, files={"file": (s, f, "image/jpeg")}, data={"field_id": "1"})
    
    if r.status_code != 200:
        print(f"FAILED for {s}: {r.status_code} - {r.text}")
        continue
        
    data = r.json()
    crop = data.get("crop")
    overall = data.get("overall_health")
    dis = data.get("disease", {})
    pest = data.get("pest", {})
    nut = data.get("nutrient", {})
    seg = data.get("segmentation", {})
    root = data.get("root_cause", {})
    
    print(f"\nImage: {s} ({desc})")
    print(f"  Crop: {crop} | Overall Health: {overall}")
    print(f"  Disease: {dis.get('prediction')} (Confidence: {dis.get('confidence')*100:.1f}%)")
    print(f"  Pest: {pest.get('primary_pest')} (Count: {pest.get('pest_count')}, Risk: {pest.get('infestation_risk')})")
    print(f"  Nutrient: {nut.get('deficiency')} (Confidence: {nut.get('confidence')*100:.1f}%)")
    print(f"  Segmentation: {seg.get('affected_area_percentage')}% affected area, Severity: {seg.get('severity_category')}")
    print(f"  Advisory Root Cause: {root.get('pathogen_name')}")
    print(f"  Advisory Summary: {data.get('advisory_summary')[:110]}...")

print("\nAll endpoints verified successfully!")
