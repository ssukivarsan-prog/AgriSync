<div align="center">
  <img src="frontend/assets/images/logo_512.png" width="140" alt="AgriVyn Logo" />
  <h1>🌾 AgriSync — AI-Powered Smart Farming Assistant</h1>
  <p><strong>Field-deployable AI for crop disease detection, pest surveillance, nutrient analysis, smart irrigation & real-time AI voice advisory calls.</strong></p>
  <p><em>Smart India Hackathon 2026 — Problem Statement ID: 26180</em></p>
</div>

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.41.4-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.141.1-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.13.0-EE4C2C?logo=pytorch&logoColor=white)](https://pytorch.org)
[![YOLOv8](https://img.shields.io/badge/Ultralytics-YOLOv8n-blueviolet)](https://ultralytics.com)
[![Twilio](https://img.shields.io/badge/Twilio-Voice_API-F22F46?logo=twilio&logoColor=white)](https://twilio.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [System Architecture](#-system-architecture)
- [AI Models & Benchmarks](#-ai-models--benchmarks)
- [Project Structure](#-project-structure)
- [Quickstart Guide](#-quickstart-guide)
- [Admin & Voice Portal](#-admin--voice-portal)
- [API Reference](#-api-reference)
- [Contributing](#-contributing)

---

## 🌟 Overview

AgriVyn is a **full-stack, field-deployable precision agriculture platform** built for Indian farming conditions. It combines on-device computer vision, real-time IoT sensor integration, and AI-powered voice advisory calls (in Tamil & English) to empower farmers and village agronomy officers.

**Problem it solves:** Indian farmers—especially small and marginal landholders—lack access to timely, accurate, and affordable agricultural intelligence. AgriVyn puts an AI agronomist in every farmer's pocket, and on every village officer's dashboard.

---

## ✨ Features

| Feature | Technology | Status |
|---|---|---|
| 🔬 **Crop Disease Detection** | MobileNetV3-Small · 38 classes | ✅ Live |
| 🐛 **Pest Surveillance** | YOLOv8n · AgroPest-12 · 12 classes | ✅ Live |
| 🧪 **Nutrient Deficiency Analysis** | MobileNetV3-Small · 9 classes | ✅ Live |
| ✂️ **Disease Lesion Segmentation** | YOLOv8n-seg · Polygon masks | ✅ Live |
| 💧 **Smart Irrigation Engine** | Rule engine + IoT sensor data | ✅ Live |
| 🌦️ **Multi-Hazard Environment Risk** | XGBoost · Drought/Heat/Disease | ✅ Live |
| 📞 **AI Voice Advisory Calls** | Twilio + ngrok · Tamil & English | ✅ Live |
| 💬 **SMS Dispatch** | Twilio SMS · Bilingual alerts | ✅ Live |
| 🏛️ **Village Officer Admin Portal** | Vanilla HTML/CSS/JS dashboard | ✅ Live |
| 📊 **Symptom Diagnostic Engine** | Random Forest · ICAR surveys | ✅ Live |

---

## 🏛️ System Architecture

```
AgriSync/
│
├── backend/                     # FastAPI Python Backend
│   ├── main.py                  # App entrypoint, lifespan, CORS, static mounts
│   ├── admin_web/               # Village Officer Admin Portal (HTML/CSS/JS)
│   │   ├── index.html           # Single-page admin dashboard
│   │   ├── admin.js             # All portal logic (farmers, calls, SMS, transcripts)
│   │   └── admin.css            # Premium dark-green design system
│   └── app/
│       ├── api/                 # REST Endpoints
│       │   ├── predict.py       # POST /predict/unified-scan (disease+pest+nutrient+seg)
│       │   ├── irrigation.py    # POST /irrigation/recommend
│       │   ├── environment.py   # POST /environment/risk
│       │   ├── sensors.py       # GET/POST /sensors (IoT sensor data)
│       │   ├── farm.py          # GET/POST /farm (polygon, crop metadata)
│       │   ├── history.py       # GET /history (scan & alert history)
│       │   ├── models_info.py   # GET /models (model registry)
│       │   ├── admin.py         # Village officer CRM: farmers, call notes, SMS
│       │   └── telephony.py     # Twilio Voice: outbound calls, TwiML webhooks,
│       │                        #   call-log (in-memory live transcripts)
│       ├── core/
│       │   └── config.py        # Settings, BASE_DIR, env loading (Pydantic)
│       ├── db/
│       │   ├── database.py      # SQLAlchemy async engine & session factory
│       │   ├── admin_models.py  # ORM: Village, FarmerEntity, SMSDispatchLog, CallNote
│       │   ├── models.py        # ORM: ScanRecord, AlertHistory
│       │   └── seed_admin.py    # Seeds realistic Tamil Nadu farmer demo data
│       ├── schemas/             # Pydantic request/response schemas
│       └── services/
│           ├── cv_service.py        # CVEngine: disease, pest, nutrient, segmentation
│           ├── telephony_service.py # Twilio REST + TwiML builder
│           ├── irrigation_service.py
│           ├── environment_service.py
│           └── ai_advisory_service.py
│
├── frontend/                    # Flutter Cross-Platform App
│   ├── pubspec.yaml             # Dependencies
│   └── lib/
│       ├── main.dart            # Responsive shell, navigation, theme
│       ├── core/
│       │   ├── api_client.dart  # HTTP service with error handling
│       │   ├── theme.dart       # Material 3 deep-green agricultural palette
│       │   └── constants.dart
│       ├── models/              # Dart data models (ScanResult, FarmData, etc.)
│       ├── providers/           # FarmProvider (ChangeNotifier state management)
│       ├── screens/             # 10 feature screens
│       │   ├── home_dashboard_screen.dart
│       │   ├── crop_diagnosis_screen.dart
│       │   ├── pest_detection_screen.dart
│       │   ├── nutrient_analysis_screen.dart
│       │   ├── irrigation_screen.dart
│       │   ├── environment_screen.dart
│       │   ├── farm_analytics_screen.dart
│       │   ├── education_portal_screen.dart
│       │   ├── crop_quotation_screen.dart
│       │   └── quick_demo_screen.dart
│       └── widgets/             # Reusable components
│           ├── metric_card.dart
│           ├── bounding_box_painter.dart
│           └── demo_mode_banner.dart
│
├── models/                      # AI Model Checkpoints
│   ├── disease/                 # MobileNetV3 (38-class PlantVillage)
│   ├── pest/                    # YOLOv8n (AgroPest-12, 12-class)
│   ├── nutrient/                # MobileNetV3 (EarlyNSD 9-class)
│   ├── segmentation/            # YOLOv8n-seg (Sugarcane lesion masks)
│   ├── diagnostic/              # RandomForest symptom model
│   ├── environment/             # XGBoost multi-hazard risk model
│   └── exported/                # ONNX & TFLite edge-ready exports
│
├── training/                    # Model Training Pipelines
│   ├── train_disease.py
│   ├── train_pest_yolo.py
│   ├── train_nutrient.py
│   └── train_segmentation.py
│
├── scripts/                     # Developer Utilities
│   ├── get_server_urls.py       # Print all connection URLs for current network
│   └── seed_database.py
│
├── tests/                       # Test Suite
│   ├── test_api.py              # FastAPI endpoint integration tests
│   └── test_cv_inference.py     # CV model inference unit tests
│
├── docs/                        # Documentation
│   ├── api_reference.md
│   └── architecture.md
│
├── configs/                     # Model config files
├── reports/                     # Evaluation reports, confusion matrices
├── .env.example                 # Environment variable template
├── start_server.py              # One-command server launcher
├── start_voice_calls.py         # Launches backend + ngrok tunnel
└── README.md
```

---

## 📊 AI Models & Benchmarks

> **All metrics are from real validation runs on held-out test sets — no simulation.**

| Model | Task | Dataset | Architecture | Validation Accuracy | Precision | Latency (CPU) | Size |
|---|---|---|---|---|---|---|---|
| Disease Classifier | 38-class leaf pathology | PlantVillage 54k | MobileNetV3-Small | **96.18%** | **96.46%** | **5.94 ms** | 6.07 MB |
| AgroPest-12 Detector | 12-class pest bounding box | AgroPest-12 13k | YOLOv8n (3.0M params) | — | **87.71%** mAP50 | **43.3 ms** | 5.93 MB |
| Nutrient Classifier | Gourd N/K/Healthy stress | EarlyNSD 2.7k | MobileNetV3-Small | **49.63%** | **55.05%** | **18.4 ms** | 5.95 MB |
| Lesion Segmentor | Sugarcane polygon lesion % | Field masks | YOLOv8n-seg (3.2M) | 41.7% Recall | **mAP50 0.19** | **54.19 ms** | 6.43 MB |
| Symptom Diagnostic | Questionnaire symptom check | ICAR Surveys | RandomForest (100 est.) | **100.0%** | **100.0%** | **0.42 ms** | 0.31 MB |

**Total AI suite footprint: < 25 MB** — runs entirely on CPU, no GPU required.

---

## 🚀 Quickstart Guide

### Prerequisites

- **Python** 3.10+ (Tested on 3.14)
- **Flutter** 3.20+ (Tested on 3.41.4)
- **Git**
- *(Optional)* [ngrok](https://ngrok.com) for real phone call webhooks

### 1. Clone the Repository

```bash
git clone https://github.com/ssukivarsan-prog/AgriSync.git
cd AgriSync
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your Twilio credentials (for voice calls)
```

`.env` variables:
```env
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=+1XXXXXXXXXX
PUBLIC_SERVER_URL=https://your-ngrok-url.ngrok-free.app
DEFAULT_CALL_LANGUAGE=ta
```

### 3. Install Python Dependencies

```bash
pip install -r backend/requirements.txt
```

### 4. Download Model Weights

> Model `.pt` files are excluded from git due to size. Download from [Releases](https://github.com/ssukivarsan-prog/AgriSync/releases) and place in `models/` subdirectories.

```
models/
├── disease/disease_model_v1.pt
├── pest/pest_model_v1.pt
├── nutrient/nutrient_model_v1.pt
├── segmentation/seg_model_v1.pt
└── diagnostic/   (auto-trains on first run)
```

### 5. Start the Backend Server

```bash
python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
```

Or use the convenience launcher:

```bash
python start_server.py
```

| URL | Purpose |
|---|---|
| `http://localhost:8000/docs` | Interactive Swagger API docs |
| `http://localhost:8000/api/health` | Backend health check |
| `http://localhost:8000/admin` | Village Officer Admin Portal |

### 6. Launch Flutter App

```bash
cd frontend
flutter pub get

# Android device/emulator
flutter run -d android

# Chrome / Web
flutter run -d chrome

# Windows Desktop
flutter run -d windows
```

Set the **Server URL** in the app settings to your machine's IP:
- USB tethered phone: `http://127.0.0.1:8000/api`
- Wi-Fi: `http://<your-local-ip>:8000/api`

---

## 🏛️ Admin & Voice Portal

The **Village Officer Admin Portal** (`http://localhost:8000/admin`) is a standalone web app for agronomy field officers:

- 👥 **Farmer CRM** — manage farmer profiles, crop data, and IoT sensor readings
- 📞 **Real AI Phone Calls** — one-click outbound Twilio Voice calls with Tamil/English advisory
- 📡 **Live Call Transcripts** — auto-refreshing chat-style view of farmer↔AI phone conversations
- 💬 **Bilingual SMS Dispatch** — one-click Tamil + English advisory SMS
- 📊 **Call Notes & Follow-up** — log officer observations and action items per farmer
- 🗺️ **Interactive Field Map** — acre map with per-zone moisture and risk overlays

### Setting up Real Phone Calls

1. Get a free Twilio account at [twilio.com](https://www.twilio.com)
2. Add your Twilio credentials to `.env`
3. Start ngrok: `ngrok http 8000`
4. Update `PUBLIC_SERVER_URL` in `.env` with the ngrok HTTPS URL
5. Open the Admin Portal → click a farmer → click **📞 Ring Mobile Phone Now**

---

## 📡 API Reference

Base URL: `http://localhost:8000/api/v1`

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/predict/unified-scan` | Run disease + pest + nutrient + segmentation |
| `POST` | `/irrigation/recommend` | Smart irrigation recommendation |
| `POST` | `/environment/risk` | Multi-hazard environmental risk assessment |
| `GET` | `/sensors` | Get current IoT sensor readings |
| `POST` | `/telephony/call-real-phone` | Initiate real AI outbound phone call |
| `GET` | `/telephony/call-log` | Get live call conversation transcripts |
| `POST` | `/telephony/twiml/welcome` | Twilio TwiML welcome webhook |
| `POST` | `/telephony/twiml/conversation` | Twilio TwiML speech AI conversation |
| `GET` | `/admin/farmers` | List all farmers in the CRM |
| `POST` | `/admin/send-sms` | Dispatch bilingual advisory SMS |

Full interactive docs: `http://localhost:8000/docs`

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add: your feature description'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## ⚖️ Responsible AI & Disclaimer

AgriVyn provides AI-assisted agronomic decision support based on agricultural university protocols (ICAR / FAO guidelines). Recommendations are decision support tools — farmers should always verify critical chemical interventions through physical field inspections and qualified agronomy extension officers.

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">
  <strong>Built with ❤️ for Indian farmers — Smart India Hackathon 2026</strong><br/>
  <em>AgriVyn Team · Problem Statement ID: 26180</em>
</div>
