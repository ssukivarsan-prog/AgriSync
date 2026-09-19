import requests
from pathlib import Path

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
API_URL = "http://127.0.0.1:8000/api"

def test_pest_detection():
    # Test on multiple pest images in agropest_subset
    val_pest_dir = ROOT / "data" / "processed" / "agropest_subset" / "images" / "val"
    imgs = list(val_pest_dir.glob("*.jpg"))[:5]
    print(f"Testing YOLO inference on {len(imgs)} validation pest images...")
    
    for img_p in imgs:
        with open(img_p, "rb") as f:
            files = {"file": (img_p.name, f, "image/jpeg")}
            r = requests.post(f"{API_URL}/predict/pest", files=files)
            if r.status_code == 200:
                data = r.json()
                print(f"[{img_p.name[:25]}...] Count: {data['pest_count']}, Primary: {data['primary_pest']}, Risk: {data['infestationRisk'] if 'infestationRisk' in data else data.get('infestation_risk')}")
            else:
                print(f"Error {r.status_code}: {r.text}")

if __name__ == "__main__":
    test_pest_detection()
