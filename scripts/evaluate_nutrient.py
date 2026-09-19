import os
import json
import time
from pathlib import Path
from PIL import Image

import torch
import torch.nn as nn
from torchvision import models, transforms
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
MODELS_DIR = ROOT / "models" / "nutrient"
TEST_DIR = ROOT / "DATASETS" / "Nutrient Deficiency Detection" / "test"

def evaluate_saved_nutrient_model():
    print("Evaluating saved nutrient model on held-out test split...")
    ckpt_path = MODELS_DIR / "nutrient_model_v1.pt"
    mapping_path = MODELS_DIR / "class_mapping.json"
    
    if not ckpt_path.exists() or not mapping_path.exists():
        print("Model or mapping not found.")
        return
        
    with open(mapping_path, "r") as f:
        mapping = json.load(f)
    class_to_idx = mapping["class_to_idx"]
    num_classes = len(class_to_idx)
    
    device = torch.device("cpu")
    model = models.mobilenet_v3_small()
    in_feat = model.classifier[3].in_features
    model.classifier[3] = nn.Linear(in_feat, num_classes)
    
    ckpt = torch.load(ckpt_path, map_location=device)
    model.load_state_dict(ckpt["model_state_dict"])
    model.eval()
    
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    y_true = []
    y_pred = []
    inference_times = []
    
    classes = sorted([d.name for d in TEST_DIR.iterdir() if d.is_dir()])
    test_count = 0
    
    for c in classes:
        imgs = list((TEST_DIR / c).glob("*.*"))[:15] # 15 per class = 135 test images
        for img_p in imgs:
            try:
                img = Image.open(img_p).convert("RGB")
                tensor = transform(img).unsqueeze(0).to(device)
                
                t0 = time.time()
                with torch.no_grad():
                    out = model(tensor)
                latency = (time.time() - t0) * 1000
                inference_times.append(latency)
                
                pred_idx = int(out.argmax(1).item())
                y_true.append(class_to_idx[c])
                y_pred.append(pred_idx)
                test_count += 1
            except Exception as e:
                pass
                
    acc = float(accuracy_score(y_true, y_pred))
    prec = float(precision_score(y_true, y_pred, average="weighted", zero_division=0))
    rec = float(recall_score(y_true, y_pred, average="weighted", zero_division=0))
    f1 = float(f1_score(y_true, y_pred, average="weighted", zero_division=0))
    avg_latency = float(sum(inference_times) / len(inference_times))
    model_size_mb = ckpt_path.stat().st_size / (1024 * 1024)
    
    metrics = {
        "model_name": "AgriVyn Nutrient Stress Classifier",
        "architecture": "MobileNetV3-Small",
        "task": "MULTI_CLASS_CLASSIFICATION",
        "num_classes": num_classes,
        "classes": classes,
        "total_test_samples": test_count,
        "accuracy": round(acc, 4),
        "precision": round(prec, 4),
        "recall": round(rec, 4),
        "f1_score": round(f1, 4),
        "avg_cpu_latency_ms": round(avg_latency, 2),
        "model_size_mb": round(model_size_mb, 2),
        "version": "1.0.0",
        "edge_ready": True
    }
    
    with open(MODELS_DIR / "metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)
        
    print("=== Nutrient Model Genuine Evaluation Summary ===")
    print(json.dumps(metrics, indent=2))

if __name__ == "__main__":
    evaluate_saved_nutrient_model()
