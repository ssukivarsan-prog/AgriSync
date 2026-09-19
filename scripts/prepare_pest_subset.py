import os
import shutil
import random
from pathlib import Path

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
RAW_DIR = ROOT / "DATASETS" / "Pest Detection"
OUT_DIR = ROOT / "data" / "processed" / "agropest_subset"

SEED = 42
random.seed(SEED)

def prepare_pest_subset():
    print("Preparing balanced AgroPest-12 subset for CPU training...")
    for split in ["train", "val", "test"]:
        (OUT_DIR / "images" / split).mkdir(parents=True, exist_ok=True)
        (OUT_DIR / "labels" / split).mkdir(parents=True, exist_ok=True)
        
    # Map raw splits
    raw_splits = {
        "train": (RAW_DIR / "train" / "images", RAW_DIR / "train" / "labels", 400),
        "val": (RAW_DIR / "valid" / "images", RAW_DIR / "valid" / "labels", 100),
        "test": (RAW_DIR / "test" / "images", RAW_DIR / "test" / "labels", 100),
    }
    
    for split_name, (img_dir, lbl_dir, limit) in raw_splits.items():
        all_imgs = sorted(list(img_dir.glob("*.jpg")) + list(img_dir.glob("*.png")))
        random.seed(SEED)
        random.shuffle(all_imgs)
        selected = all_imgs[:limit]
        
        for img_p in selected:
            lbl_p = lbl_dir / f"{img_p.stem}.txt"
            shutil.copy(str(img_p), str(OUT_DIR / "images" / split_name / img_p.name))
            if lbl_p.exists():
                shutil.copy(str(lbl_p), str(OUT_DIR / "labels" / split_name / lbl_p.name))
                
        print(f"Copied {len(selected)} samples for {split_name}.")
        
    # Create YAML config
    yaml_content = f"""path: {OUT_DIR.as_posix()}
train: images/train
val: images/val
test: images/test

nc: 12
names: [
  "Ants",
  "Bees",
  "Beetles",
  "Caterpillars",
  "Earthworms",
  "Earwigs",
  "Grasshoppers",
  "Moths",
  "Slugs",
  "Snails",
  "Wasps",
  "Weevils"
]
"""
    yaml_path = OUT_DIR / "data.yaml"
    with open(yaml_path, "w") as f:
        f.write(yaml_content)
        
    print(f"AgroPest subset YAML written to {yaml_path}")
    return yaml_path

if __name__ == "__main__":
    prepare_pest_subset()
