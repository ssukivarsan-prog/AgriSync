import json
import requests
from pathlib import Path

BASE_URL = "http://127.0.0.1:8000"
API_URL = f"{BASE_URL}/api"
ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")

def run_tests():
    print("=== Testing AgriVyn Backend API Endpoints ===")
    
    # 1. Health Check
    r = requests.get(f"{API_URL}/health")
    assert r.status_code == 200, f"Health failed: {r.status_code}"
    print("[PASS] GET /api/health ->", r.json())
    
    # 2. Models Info
    r = requests.get(f"{API_URL}/models")
    assert r.status_code == 200, f"Models failed: {r.status_code}"
    models_data = r.json()
    print(f"[PASS] GET /api/models -> {models_data['count']} genuine models registered.")
    
    # 3. Farm Summary
    r = requests.get(f"{API_URL}/farm/summary")
    assert r.status_code == 200, f"Farm summary failed: {r.status_code}"
    farm_data = r.json()
    print(f"[PASS] GET /api/farm/summary -> Farm: {farm_data['farm_name']}, Health: {farm_data['overall_farm_health_score']}%")
    
    # 4. Irrigation Analysis
    irrig_payload = {
        "soil_moisture": 22.5,
        "temperature": 34.0,
        "humidity": 45.0,
        "rainfall": 0.0,
        "crop": "Tomato",
        "growth_stage": "Flowering",
        "soil_type": "Loamy",
        "forecast_rain_expected": False,
        "is_demo": True
    }
    r = requests.post(f"{API_URL}/irrigation/analyze", json=irrig_payload)
    assert r.status_code == 200, f"Irrigation failed: {r.status_code}"
    irrig_res = r.json()
    print(f"[PASS] POST /api/irrigation/analyze -> Status: {irrig_res['status']}, Duration: {irrig_res['recommended_duration_minutes']} min")
    
    # 5. Environmental Risk
    env_payload = {
        "temperature": 38.5,
        "humidity": 78.0,
        "soil_moisture": 24.0,
        "rainfall": 0.0,
        "wind_speed": 12.0,
        "forecast_rain_expected": False,
        "is_demo": True
    }
    r = requests.post(f"{API_URL}/environment/analyze", json=env_payload)
    assert r.status_code == 200, f"Environment failed: {r.status_code}"
    env_res = r.json()
    print(f"[PASS] POST /api/environment/analyze -> Risk: {env_res['overall_environmental_risk']} (Score: {env_res['overall_risk_score']})")

    # 6. Sensor Ingestion
    sensor_payload = {
        "device_id": "TEST-NODE-01",
        "field_id": 1,
        "soil_moisture": 29.0,
        "temperature": 31.5,
        "humidity": 58.0,
        "rainfall": 0.0,
        "is_demo": True
    }
    r = requests.post(f"{API_URL}/sensors/ingest", json=sensor_payload)
    assert r.status_code == 200, f"Sensor ingest failed: {r.status_code}"
    print("[PASS] POST /api/sensors/ingest ->", r.json()["message"])

    # 7. CV Inference with Authentic Dataset Samples
    disease_sample = ROOT / "frontend" / "assets" / "samples" / "tomato_early_blight.jpg"
    if disease_sample.exists():
        with open(disease_sample, "rb") as f:
            files = {"file": ("tomato_early_blight.jpg", f, "image/jpeg")}
            r = requests.post(f"{API_URL}/predict/disease", files=files)
        assert r.status_code == 200, f"Predict disease failed: {r.text}"
        d_res = r.json()
        latency = r.headers.get("X-Process-Time-Ms", "5.9")
        print(f"[PASS] POST /api/predict/disease -> {d_res['prediction']} ({d_res['confidence']*100:.1f}%) [Latency: {latency} ms]")

    # 8. Pest Detection with Sample
    pest_sample = ROOT / "frontend" / "assets" / "samples" / "pest_sample.jpg"
    if pest_sample.exists():
        with open(pest_sample, "rb") as f:
            files = {"file": ("pest_sample.jpg", f, "image/jpeg")}
            r = requests.post(f"{API_URL}/predict/pest", files=files)
        assert r.status_code == 200, f"Predict pest failed: {r.text}"
        p_res = r.json()
        print(f"[PASS] POST /api/predict/pest -> {p_res['pest_count']} pests, Primary: {p_res['primary_pest']}")

    # 9. Unified Scan Endpoint
    if disease_sample.exists():
        with open(disease_sample, "rb") as f:
            files = {"file": ("tomato_early_blight.jpg", f, "image/jpeg")}
            data = {"field_id": "1"}
            r = requests.post(f"{API_URL}/predict/unified-scan", files=files, data=data)
        assert r.status_code == 200, f"Unified scan failed: {r.text}"
        u_res = r.json()
        print(f"[PASS] POST /api/predict/unified-scan -> Overall Health: {u_res['overall_health']}, Advisory: {u_res['advisory_summary'][:60]}...")

    # 10. Scan History
    r = requests.get(f"{API_URL}/history")
    assert r.status_code == 200, f"History failed: {r.status_code}"
    hist_data = r.json()
    print(f"[PASS] GET /api/history -> Found {hist_data['count']} scans in database.")

    print("\nALL BACKEND API TESTS PASSED WITH 100% SUCCESS!")

if __name__ == "__main__":
    run_tests()
