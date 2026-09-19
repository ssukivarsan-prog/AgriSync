# AGRI VYN — Comprehensive Dataset Audit Report
**SIH 2026 Problem Statement ID: 26180**
**Date of Audit**: August 2026
**Audited Location**: `d:\FLUTTER PROJECTS\AgriVyn`

---

## 1. Executive Summary

A comprehensive, non-destructive audit of all datasets in the AgriVyn project workspace was conducted. 
The workspace contains **5 major dataset groups comprising 89,224 images and 300 diagnostic survey records**, spanning crop disease identification, nutrient stress classification, pest object detection, disease lesion segmentation, and agronomic diagnostic inference.

---

## 2. Dataset Breakdown & Task Characterization

### Dataset 1: PlantVillage Crop Disease Dataset
- **Relative Path**: `DATASETS/Crop Disease Detection/PlantVillage`
- **Machine Learning Task**: Multi-Class Image Classification
- **Total Images**: 54,305 (Train: 43,444, Val: 10,861)
- **Number of Classes**: 38 classes
- **Crops Covered**: 14 agricultural crops: Apple, Blueberry, Cherry, Corn (Maize), Grape, Orange, Peach, Bell Pepper, Potato, Raspberry, Soybean, Squash, Strawberry, Tomato.
- **Image Specifications**: 256×256 pixels, RGB, JPEG format.
- **Integrity**: 100% valid files, zero corrupted images identified.
- **Recommended Model Architecture**: MobileNetV3-Small / SqueezeNet (optimized for edge and CPU inference).

### Dataset 2: EarlyNSD Nutrient Stress Dataset
- **Relative Path**: `DATASETS/Nutrient Deficiency Detection`
- **Machine Learning Task**: Multi-Class Image Classification
- **Total Images**: 2,700 (Train: 1,890, Val: 405, Test: 405)
- **Number of Classes**: 9 classes (Ashgourd fresh/healthy, Ashgourd nitrogen stress, Ashgourd potassium stress, Bittergourd fresh, Bittergourd nitrogen, Bittergourd potassium, Snakegourd fresh, Snakegourd nitrogen, Snakegourd potassium).
- **Class Balance**: Perfectly balanced (210 train / 45 val / 45 test per class).
- **Image Specifications**: High-resolution 5544×5544 JPEG photography.
- **Recommended Preprocessing**: Center crop and resize to 224×224 with bicubic interpolation.
- **Recommended Model**: MobileNetV3-Small / EfficientNet-B0.

### Dataset 3: AgroPest-12 Pest Object Detection Dataset
- **Relative Path**: `DATASETS/Pest Detection`
- **Machine Learning Task**: Multi-Class Object Detection (Bounding Boxes)
- **Total Images**: 13,143 (Train: 11,502, Valid: 1,095, Test: 546)
- **Number of Classes**: 12 classes (Ants, Bees, Beetles, Caterpillars, Earthworms, Earwigs, Grasshoppers, Moths, Slugs, Snails, Wasps, Weevils).
- **Annotation Format**: YOLO format (`class_id x_center y_center width height` normalized to [0, 1]).
- **Recommended Model Architecture**: Ultralytics YOLOv8n / YOLO11n.

### Dataset 4: IP102 Agricultural Pest Benchmark Dataset
- **Relative Path**: `DATASETS/Larger Pest Dataset/IP102_YOLOv5`
- **Machine Learning Task**: 102-Class Pest Object Detection
- **Total Images**: 18,975 (Train: 17,646, Val: 1,329)
- **Annotation Format**: YOLOv5 format.
- **Role in AgriVyn**: Reference benchmark and expansive pest encyclopedia.

### Dataset 5: Sugarcane-Focused Disease, Insect & Diagnostic Dataset
- **Relative Path**: `DATASETS/Crop Dataset — Sugarcane-focused`
- **Sub-datasets**:
  1. `Crop_Diseases` (50 images): Contains **actual polygon segmentation annotations** (`class_id x1 y1 x2 y2 ...` up to 829 normalized coordinate vertices). Task: **Instance Segmentation** of disease lesions.
  2. `Crop_Insects` (50 images): Contains YOLO bounding box annotations. Task: **Object Detection**.
  3. `synthetic_disease_presence_30_questions.csv` (150 instances, 30 features): Tabular agronomic symptom diagnostic questions for Early Blight.
  4. `synthetic_insect_presence_30_questions.csv` (150 instances, 30 features): Tabular agronomic symptom diagnostic questions for insect infestation.
- **Role in AgriVyn**: Powers lesion visual segmentation overlay (affected area %) and the conversational Agronomic Advisory Question Engine.

---

## 3. Data Quality & Preprocessing Strategy
1. **Normalization**: Standard ImageNet mean `[0.485, 0.456, 0.406]` and std `[0.229, 0.224, 0.225]`.
2. **Stratified Sampling for CPU Training**: To prevent CPU overheating or multi-day training loops on the Intel Core i7-1255U host, representative stratified subsets with a fixed seed (`seed=42`) are utilized for training while preserving complete held-out evaluation.
3. **No Artificial Data Inventions**: Only classes and annotations genuinely present in the data are utilized.
