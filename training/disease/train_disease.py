import os
import sys
import json
import time
import random
from pathlib import Path
from PIL import Image

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import models, transforms
from sklearn.metrics import precision_score, recall_score, f1_score, accuracy_score, classification_report

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
MODELS_DIR = ROOT / "models" / "disease"
EXPORT_DIR = ROOT / "models" / "exported"
MODELS_DIR.mkdir(parents=True, exist_ok=True)
EXPORT_DIR.mkdir(parents=True, exist_ok=True)

# Set random seeds for reproducibility
SEED = 42
random.seed(SEED)
torch.manual_seed(SEED)

class PlantVillageDataset(Dataset):
    def __init__(self, samples, class_to_idx, transform=None):
        self.samples = samples
        self.class_to_idx = class_to_idx
        self.transform = transform

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, class_name = self.samples[idx]
        image = Image.open(img_path).convert("RGB")
        if self.transform:
            image = self.transform(image)
        label = self.class_to_idx[class_name]
        return image, label

def load_data_samples(pv_dir, split, sample_limit_per_class=70):
    split_dir = pv_dir / split
    classes = sorted([d.name for d in split_dir.iterdir() if d.is_dir()])
    samples = []
    
    for c in classes:
        all_imgs = list((split_dir / c).glob("*.*"))
        random.seed(SEED)
        random.shuffle(all_imgs)
        selected = all_imgs[:sample_limit_per_class] if sample_limit_per_class else all_imgs
        for img in selected:
            samples.append((str(img), c))
            
    return classes, samples

def train_disease_model():
    print("=== Training Disease Detection Model (MobileNetV3-Small) ===")
    pv_dir = ROOT / "DATASETS" / "Crop Disease Detection" / "PlantVillage"
    
    classes, train_samples = load_data_samples(pv_dir, "train", sample_limit_per_class=60)
    _, val_samples = load_data_samples(pv_dir, "val", sample_limit_per_class=20)
    
    class_to_idx = {c: i for i, c in enumerate(classes)}
    idx_to_class = {i: c for i, c in enumerate(classes)}
    
    # Save class mapping
    with open(MODELS_DIR / "class_mapping.json", "w") as f:
        json.dump({"class_to_idx": class_to_idx, "idx_to_class": idx_to_class, "num_classes": len(classes)}, f, indent=2)
        
    print(f"Loaded {len(train_samples)} training samples and {len(val_samples)} validation samples across {len(classes)} classes.")

    train_transforms = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(brightness=0.15, contrast=0.15),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    val_transforms = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    train_dataset = PlantVillageDataset(train_samples, class_to_idx, transform=train_transforms)
    val_dataset = PlantVillageDataset(val_samples, class_to_idx, transform=val_transforms)

    train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True, num_workers=0)
    val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False, num_workers=0)

    # Initialize MobileNetV3-Small
    model = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.DEFAULT)
    in_features = model.classifier[3].in_features
    model.classifier[3] = nn.Linear(in_features, len(classes))

    criterion = nn.CrossEntropyLoss()
    optimizer = optim.AdamW(model.parameters(), lr=0.001, weight_decay=1e-4)
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=5)

    device = torch.device("cpu")
    model.to(device)

    start_time = time.time()
    epochs = 4
    best_acc = 0.0

    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        correct = 0
        total = 0

        for images, labels in train_loader:
            images, labels = images.to(device), labels.to(device)
            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item() * images.size(0)
            _, predicted = outputs.max(1)
            total += labels.size(0)
            correct += predicted.eq(labels).sum().item()

        scheduler.step()
        train_loss = running_loss / total
        train_acc = correct / total

        # Validation
        model.eval()
        val_loss = 0.0
        val_correct = 0
        val_total = 0
        y_true = []
        y_pred = []

        with torch.no_grad():
            for images, labels in val_loader:
                images, labels = images.to(device), labels.to(device)
                outputs = model(images)
                loss = criterion(outputs, labels)
                val_loss += loss.item() * images.size(0)
                _, predicted = outputs.max(1)
                val_total += labels.size(0)
                val_correct += predicted.eq(labels).sum().item()
                y_true.extend(labels.cpu().numpy())
                y_pred.extend(predicted.cpu().numpy())

        epoch_val_acc = val_correct / val_total
        print(f"Epoch [{epoch+1}/{epochs}] - Train Loss: {train_loss:.4f} Acc: {train_acc:.4f} | Val Loss: {val_loss/val_total:.4f} Val Acc: {epoch_val_acc:.4f}")

        if epoch_val_acc > best_acc:
            best_acc = epoch_val_acc
            # Save checkpoint
            torch.save({
                "model_state_dict": model.state_dict(),
                "num_classes": len(classes),
                "classes": classes,
                "val_accuracy": epoch_val_acc,
                "architecture": "mobilenet_v3_small",
                "version": "1.0.0",
                "date": "2026-08-27"
            }, MODELS_DIR / "disease_model_v1.pt")

    training_time = time.time() - start_time

    # Final Comprehensive Evaluation
    model.eval()
    y_true = []
    y_pred = []
    inference_times = []

    with torch.no_grad():
        for images, labels in val_loader:
            t0 = time.time()
            outputs = model(images)
            inference_times.append((time.time() - t0) / images.size(0))
            _, predicted = outputs.max(1)
            y_true.extend(labels.cpu().numpy())
            y_pred.extend(predicted.cpu().numpy())

    final_acc = float(accuracy_score(y_true, y_pred))
    final_prec = float(precision_score(y_true, y_pred, average="weighted", zero_division=0))
    final_rec = float(recall_score(y_true, y_pred, average="weighted", zero_division=0))
    final_f1 = float(f1_score(y_true, y_pred, average="weighted", zero_division=0))
    avg_latency_ms = float(sum(inference_times) / len(inference_times) * 1000)

    model_size_mb = (MODELS_DIR / "disease_model_v1.pt").stat().st_size / (1024 * 1024)

    # Export to ONNX
    dummy_input = torch.randn(1, 3, 224, 224, device=device)
    onnx_path = EXPORT_DIR / "disease_model.onnx"
    try:
        torch.onnx.export(
            model, dummy_input, str(onnx_path),
            input_names=["input"], output_names=["output"],
            dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
            opset_version=14
        )
        print(f"Exported ONNX model to {onnx_path}")
    except Exception as e:
        print(f"ONNX export warning: {e}")

    metrics = {
        "model_name": "AgriVyn Crop Disease Classifier",
        "architecture": "MobileNetV3-Small",
        "task": "MULTI_CLASS_CLASSIFICATION",
        "num_classes": len(classes),
        "total_train_samples": len(train_samples),
        "total_val_samples": len(val_samples),
        "training_time_seconds": round(training_time, 2),
        "accuracy": round(final_acc, 4),
        "precision": round(final_prec, 4),
        "recall": round(final_rec, 4),
        "f1_score": round(final_f1, 4),
        "avg_cpu_latency_ms": round(avg_latency_ms, 2),
        "model_size_mb": round(model_size_mb, 2),
        "version": "1.0.0",
        "edge_ready": True,
        "onnx_exported": onnx_path.exists()
    }

    with open(MODELS_DIR / "metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)

    print("=== Disease Model Evaluation Summary ===")
    print(json.dumps(metrics, indent=2))

if __name__ == "__main__":
    train_disease_model()
