# AgriVyn — Complete System Flow & Build Architecture
**SIH 2026 Problem Statement ID: 26180**

This document details the architectural and procedural flow diagrams of how the AgriVyn application is built, trained, connected, and executed across mobile devices and edge servers.

---

## 1. End-to-End Application Runtime Flow

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Farmer / Evaluator
    participant Mobile as Flutter UI (Pixel 7a / Web / Desktop)
    participant Provider as FarmProvider (State Management)
    participant ApiClient as ApiService (HTTP Client & Auto-Discovery)
    participant Backend as FastAPI Server (Uvicorn ASGI)
    participant CV as CVEngine (In-Memory AI Singleton)
    participant Rules as ICAR Advisory & Irrigation Engine
    participant DB as SQLite DB (agrivyn.db)

    Farmer->>Mobile: Opens App & Selects "AI Crop Scan"
    Farmer->>Mobile: Takes Photo or Chooses Sample
    Mobile->>Provider: executeUnifiedScan(imageBytes, filename, fieldId)
    Provider->>ApiClient: POST /api/predict/unified-scan (Multipart Form)
    ApiClient->>Backend: HTTP Request (over Wi-Fi / USB reverse)
    
    rect rgb(235, 245, 235)
        note over Backend,CV: Multi-Model AI Inference Pipeline
        Backend->>CV: validate_image(imageBytes)
        CV->>CV: 1. MobileNetV3 Disease Classifier (38 Classes)
        CV->>CV: 2. YOLOv8n AgroPest Detector (12 Classes + BBoxes)
        CV->>CV: 3. MobileNetV3 Nutrient Classifier (N/K Stress)
        CV->>CV: 4. YOLOv8n-seg Lesion Area Estimator (%)
        CV-->>Backend: Consolidated Raw Predictions
    end

    Backend->>Rules: Synthesize Plain-Language ICAR Advisory
    Rules-->>Backend: 4-Part Farmer Action Plan
    Backend->>DB: Persist Scan, Alerts & Bounding Boxes
    Backend-->>ApiClient: Return JSON (UnifiedScanResponse)
    ApiClient-->>Provider: Strongly-Typed Dart Models
    Provider->>Provider: notifyListeners()
    Provider-->>Mobile: Re-render UI with Bounding Boxes & Confidence Tier
    Mobile-->>Farmer: Visual Diagnosis, Top-3 Bar Chart & Next Actions
```

---

## 2. Deep Learning Models Build & Training Flow

```mermaid
graph TD
    subgraph Data_Layer [Raw Authentic Field Datasets in DATASETS/]
        D1[PlantVillage - 54,305 Images]
        D2[AgroPest-12 - 13,143 Images]
        D3[EarlyNSD - 2,700 Leaf Images]
        D4[Sugarcane Lesion - Polygon Masks]
        D5[ICAR Diagnostic - 30 Question CSVs]
    end

    subgraph Training_Pipelines [Training Scripts in training/]
        T1[train_disease.py - Transfer Learning & Hardswish]
        T2[train_pest.py - Ultralytics Anchor-Free Fine-Tuning]
        T3[train_nutrient.py - Foliar N/K Chlorosis Tuning]
        T4[train_seg.py - Instance Mask Head Training]
        T5[train_symptom.py - RandomForest Classifier]
    end

    subgraph Model_Artifacts [Model Checkpoints & Exports in models/]
        M1[disease_model_v1.pt - 6.07 MB - 96.18% Val Acc]
        M2[pest_model_v1.pt - 5.93 MB & pest_model.onnx - 11.6 MB]
        M3[nutrient_model_v1.pt - 5.95 MB - 55.05% Precision]
        M4[seg_model_v1.pt - 6.43 MB - 41.7% Recall]
        M5[symptom_models.joblib - 0.31 MB - 100% Test Acc]
    end

    D1 --> T1 --> M1
    D2 --> T2 --> M2
    D3 --> T3 --> M3
    D4 --> T4 --> M4
    D5 --> T5 --> M5
```

---

## 3. Frontend Architecture (Flutter MVVM + Provider)

```mermaid
graph TD
    subgraph View_Layer [Flutter Presentation Layer]
        V1[HomeDashboardScreen]
        V2[AIScanScreen]
        V3[PestDetectionScreen]
        V4[NutrientAnalysisScreen]
        V5[IrrigationScreen]
        V6[EnvironmentScreen]
        V7[QuickDemoScreen - 3-Min Pitch]
    end

    subgraph ViewModel_Layer [State Management - Provider]
        P1[FarmProvider]
        P2[Notifier Streams]
        P3[Offline Mode State & Server URL]
    end

    subgraph Model_Data_Layer [Data & Service Bridge]
        M_API[ApiService HTTP REST Client]
        M_MODELS[Dart Strongly-Typed Models]
        M_STORAGE[SharedPreferences & Offline Cache]
    end

    V1 & V2 & V3 & V4 & V5 & V6 & V7 --> P1
    P1 --> P2 & P3
    P1 --> M_API
    M_API --> M_MODELS
    M_API --> M_STORAGE
```

---

## 4. Smart Irrigation & Multi-Hazard Weather Risk Engine Flow

```mermaid
flowchart TD
    Start([Sensor Input: Moisture, Temp, Humidity, Rain]) --> SensorCheck{Is Moisture < Threshold?}
    
    SensorCheck -- Yes (Moisture < 25%) --> Deficit[Calculate Depletion % & Kc Factor]
    SensorCheck -- No (Moisture >= 30%) --> StatusDelay[Status: DELAY IRRIGATION / OPTIMAL]
    
    Deficit --> RainCheck{Forecast Rain Expected?}
    RainCheck -- Yes --> DelayRain[Status: DELAY IRRIGATION - Rain Imminent]
    RainCheck -- No --> DurationCalc[Calculate Duration = Deficit % x 2.8 x Stage Factor]
    DurationCalc --> StatusIrrigate[Status: IRRIGATE NOW with Duration in Mins]

    Start --> HazardEval[Evaluate Environmental Multi-Hazards]
    HazardEval --> H1{Temp >= 38°C?} -->|Yes| HeatStress[HEAT WAVE RISK: Severe Evaporation Alert]
    HazardEval --> H2{Rain >= 50mm?} -->|Yes| FloodRisk[FLOOD & WATERLOGGING RISK: Drainage Alert]
    HazardEval --> H3{Humidity >= 80% & Rain > 10mm?} -->|Yes| FungalRisk[DISEASE FAVORABLE: Fungal Infection Alert]

    HeatStress & FloodRisk & FungalRisk --> CompoundIndex[Synthesize Compound Risk Score 0.0 to 1.0]
    CompoundIndex --> Advisory[Generate Priority Mitigation Protocols]
```

---

## 5. Physical Mobile Device Network Architecture

```mermaid
graph LR
    subgraph Physical_Android_Phone [Android Phone - Pixel 7a]
        App[AgriVyn Flutter APK]
        Cam[Phone Camera & Gallery]
    end

    subgraph Connection_Modes [Network Communication Bridge]
        WIFI[Wi-Fi Local Network: http://10.43.166.33:8000/api]
        USB[USB Cable: adb reverse tcp:8000 tcp:8000 -> http://127.0.0.1:8000/api]
        EMU[Virtual Gateway: http://10.0.2.2:8000/api]
    end

    subgraph Host_Workstation [Laptop / Edge Server]
        Uvicorn[FastAPI / Uvicorn Host 0.0.0.0:8000]
        DL_Suite[PyTorch & YOLOv8 Inference Suite]
        SQLite[(Local SQLite Database)]
    end

    App --> WIFI & USB & EMU
    WIFI & USB & EMU --> Uvicorn
    Uvicorn --> DL_Suite
    Uvicorn --> SQLite
```
