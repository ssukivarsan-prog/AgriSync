# SIH 2026 Problem Statement 26180 — Direct Compliance Matrix
**Project: AgriVyn — Field-Deployable AI Smart Farming Assistant**

---

## Official Problem Requirement

> **“A field-deployable AI-powered Smart Farming Assistant that helps farmers detect crop diseases, pests, nutrient deficiencies, and irrigation needs at an early stage, while improving resilience against droughts, floods, heat waves, and other agricultural risks common in India. The solution should enable higher yields, lower input costs, more efficient water usage, and faster response to emerging threats through real-time on-device intelligence.”**

---

## Detailed Requirement-to-Implementation Mapping

| # | Official Problem Aspect | AgriVyn Solution Implementation | Code & Artifact Location |
|---|---|---|---|
| **1** | **Crop Disease Early Detection** | MobileNetV3-Small deep CNN trained on 38 classes (96.18% validation accuracy, 5.94 ms latency). Provides top-3 probability distribution, confidence tiering, and agronomic management instructions. | `models/disease/`, `backend/app/api/predict.py`, `frontend/lib/screens/ai_scan_screen.dart` |
| **2** | **Pest Detection & Counting** | YOLOv8n object detection model fine-tuned on AgroPest-12 (87.71% precision, 43.3 ms latency). Detects multiple pest instances in one frame, draws bounding boxes, identifies primary pest species, and classifies infestation risk (LOW / MODERATE / HIGH). | `models/pest/`, `frontend/lib/screens/pest_detection_screen.dart`, `frontend/lib/widgets/bounding_box_painter.dart` |
| **3** | **Nutrient Deficiency Detection** | MobileNetV3-Small foliar classifier trained on EarlyNSD for nitrogen (N) and potassium (K) stresses. Delivers visual symptom explanations, petiole/EC verification guidance, and actionable soil recommendations without chemical hallucination. | `models/nutrient/`, `frontend/lib/screens/nutrient_analysis_screen.dart` |
| **4** | **Irrigation Needs & Water Efficiency** | ICAR-calibrated precision irrigation rule engine combining soil moisture depletion, crop coefficient ($K_c$), stage sensitivity, and 24-hour weather forecasts. Outputs exact recommendations: `IRRIGATE NOW` with duration in minutes, `MONITOR`, or `DELAY IRRIGATION`. | `backend/app/services/irrigation_service.py`, `frontend/lib/screens/irrigation_screen.dart` |
| **5** | **Resilience against Drought, Heat, Flood** | Multi-hazard environmental risk engine evaluating 5 disaster categories (Drought, Heat Stress, Flood, Disease-Favorable weather, and Compound Stress Index) with tailored agricultural mitigation measures. | `backend/app/services/environment_service.py`, `frontend/lib/screens/environment_screen.dart` |
| **6** | **Real-Time On-Device Intelligence** | Compact models total under 25 MB. Sub-50ms CPU inference latencies. ONNX models exported for on-device mobile execution (`models/exported/`). Works completely offline with cached farm states. | `models/exported/`, `reports/model_evaluation.md` |
| **7** | **Lower Input Costs & Higher Yields** | Prevents indiscriminate over-spraying of expensive pesticides through threshold-based pest counts; prevents urea/fertilizer misuse through soil-test verification protocols; saves up to 40% water through schedule optimization. | `backend/app/services/advisory_service.py`, `backend/app/services/irrigation_service.py` |
| **8** | **Farmer Advisory & Decision Support** | Plain-language, actionable 4-part farmer guidance: (1) WHAT WAS DETECTED, (2) WHY IT MATTERS, (3) WHAT TO CHECK IN THE FIELD, (4) WHAT ACTION TO TAKE NEXT. Responsible AI disclaimer included. | `backend/app/services/advisory_service.py`, `frontend/lib/screens/ai_scan_screen.dart` |
| **9** | **Real Sensor vs. Demo Transparency** | Sensor endpoints and UI feature transparent banners: `REAL IOT SENSOR STREAM ACTIVE` vs `DEMO SENSOR MODE ACTIVE`. No simulated readings are ever disguised as real telemetry. | `backend/app/api/sensors.py`, `frontend/lib/widgets/demo_mode_banner.dart` |
| **10** | **Field Usability & Architecture** | Responsive Flutter application (Android mobile, Web, Desktop) with deep green agricultural Material 3 theme, navigation rail/bar, historical analytics, scan history in SQLite, and a dedicated 3-minute presentation flow for judges. | `frontend/lib/main.dart`, `frontend/lib/screens/quick_demo_screen.dart` |
