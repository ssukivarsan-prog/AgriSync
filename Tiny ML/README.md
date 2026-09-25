# AgriSync - TinyML & Edge AI Module

This module provides **ultra-lightweight, edge-deployable AI models** and micro-services for the AgriSync Smart Agriculture Ecosystem. It is designed to run offline on resource-constrained microcontrollers (e.g., ESP32, Arduino, ARM Cortex-M) as well as online via FastAPI microservices.

---

## 🌟 Key Capabilities

1. **Edge TinyML Firmware (`firmware/agrisync_model.h`)**:
   - Pure C++ header file containing compiled decision trees exported from gradient-boosted models.
   - Zero external dependencies; runs directly on ESP32 / Arduino / ARM MCU with sub-millisecond inference latency (~0.0004 ms/row) and minimal memory footprint (<200 KB).
   - Real-time soil moisture prediction and drought risk scoring right on field edge devices.

2. **Smart Advisory Engine (`src/assistant.py`)**:
   - Translates raw predictions and multi-sensor readings (temp, humidity, pH, NPK) into actionable irrigation & soil remediation recommendations.

3. **FastAPI Microservice (`api/main.py`)**:
   - High-throughput REST API for IoT telemetry ingestion and real-time risk assessment (`/predict`).

4. **Data Preprocessing & Training Pipelines (`src/`)**:
   - `data_engine.py`: Merges and standardizes meteorological, telemetry, and soil nutrient datasets for Tamil Nadu.
   - `risk_model.py`: Trains XGBoost regressor & classifier.
   - `export_tinyml.py`: Compiles trained XGBoost booster trees into C++ header code for microcontroller deployment.
   - `visualization.py`: Generates accuracy curves and feature importance charts.

5. **Quick Verification & Benchmarking (`demo.py`)**:
   - Evaluates $R^2$ accuracy score, MAE, inference speed, and simulates field zone plot alerts.

---

## 📂 Project Structure

```
Tiny ML/
├── api/
│   └── main.py                     # FastAPI REST server for edge/cloud prediction
├── data/
│   ├── processed/
│   │   └── tn_master_dataset.parquet # Clean preprocessed master dataset
│   └── raw/
│       ├── humid_tel_hr_tamil_nadu_sw_gw_tn_2026_2030.csv
│       ├── new_tn_npk.csv
│       ├── sm_Tamilnadu_2020.csv
│       ├── Tables.csv
│       └── temprature_tel_hr_tamil_nadu_sw_gw_tn_2021_2025.csv.zip
├── firmware/
│   └── agrisync_model.h            # Exported C++ TinyML model for ESP32/Arduino
├── models/
│   ├── risk_xgboost.json           # Trained XGBoost regressor model
│   └── risk_classifier.json        # Trained categorical classifier
├── plots/
│   ├── accuracy_chart.png          # Actual vs Predicted validation plot
│   └── feature_importance.png      # Key agricultural risk drivers plot
├── src/
│   ├── assistant.py                # Agronomic rule engine & advisory
│   ├── data_engine.py              # Data alignment & preprocessing pipeline
│   ├── export_tinyml.py            # Model to C++ header converter
│   ├── risk_model.py               # XGBoost training pipeline
│   └── visualization.py            # Analytics visualization generator
├── check_new_data.py               # Column inspection utility
├── demo.py                         # Benchmark metrics & simulation demo
├── requirements.txt                # Python dependencies
└── README.md                       # Documentation
```

---

## 🚀 Getting Started

### 1. Installation

```bash
pip install -r requirements.txt
```

### 2. Run the Benchmark Demo

```bash
python demo.py
```

### 3. Start the FastAPI Service

```bash
python api/main.py
# Or with uvicorn:
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
```
Interactive API documentation will be available at: `http://localhost:8000/docs`

### 4. Deploying to Microcontroller (ESP32 / Arduino)

Include `firmware/agrisync_model.h` in your Arduino sketch or ESP-IDF project:

```cpp
#include "agrisync_model.h"

void loop() {
    // Array order: [temp, humidity, month, day, pH, N, P, K]
    float sensor_readings[8] = { 28.5f, 65.0f, 6.0f, 15.0f, 6.8f, 50.0f, 20.0f, 30.0f };
    float predicted_moisture = predict_risk(sensor_readings);

    if (predicted_moisture < 0.30f) {
        // Trigger irrigation relay
        digitalWrite(PUMP_PIN, HIGH);
    }
    delay(60000);
}
```

---

## 📊 Model Performance

- **Target Metric**: Soil Moisture Index (0.0 - 1.0)
- **Model Type**: Gradient Boosted Trees (XGBoost)
- **Model File Size**: ~165 KB
- **Inference Latency**: ~0.0004 ms per inference
- **Deployment Platform**: ESP32, Arduino, Raspberry Pi, Cloud API
