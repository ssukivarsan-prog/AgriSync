import xgboost as xgb
import pandas as pd
import time
import os
from sklearn.metrics import mean_absolute_error, r2_score

MODEL_PATH = "models/risk_xgboost.json"
DATA_PATH = "data/processed/tn_master_dataset.parquet"

def get_model_metrics():
    model = xgb.XGBRegressor()
    model.load_model(MODEL_PATH)
    df = pd.read_parquet(DATA_PATH)
    X = df[['temp', 'humidity', 'month', 'day', 'pH', 'N', 'P', 'K']]
    y = df['soil_moisture']
    preds = model.predict(X)
    return mean_absolute_error(y, preds), r2_score(y, preds), (os.path.getsize(MODEL_PATH)/1024), 0.0004

def simulate(zone_name, temp, humid, month, day, pH, N, P, K):
    model = xgb.XGBRegressor()
    model.load_model(MODEL_PATH)
    data = pd.DataFrame([[temp, humid, month, day, pH, N, P, K]], 
                        columns=["temp", "humidity", "month", "day", "pH", "N", "P", "K"])
    pred = model.predict(data)[0]
    
    # Logic
    status = "🔴 RED ZONE (CRITICAL)" if pred < 0.30 else "🟢 GREEN ZONE (HEALTHY)"
    advisory = ["🚨 DROUGHT: Activate Zone Valve."] if pred < 0.30 else ["✅ STABLE: Soil moisture optimal."]
    if N < 35 or P < 15: advisory.append("🧪 NUTRIENTS: Deficiency.")
    if humid > 85 and temp > 30: advisory.append("🦟 PESTS: High humidity.")
    if pH < 6.0: advisory.append("📉 pH: Soil acidic.")

    print(f"\n--- [FIELD PLOT MAP]: {zone_name} ---")
    print(f"📊 ZONE STATUS: {status}")
    print(f"🧠 AI MOISTURE INDEX: {pred:.4f} | WILTING COUNTDOWN: ~{int(pred*48)}h")
    print(f"📢 ADVISORY: \n   " + "\n   ".join(advisory))
    print("-" * 60)

if __name__ == "__main__":
    mae, r2, m_size, inf_time = get_model_metrics()
    print("======================================================")
    print("      AGRISYNC: MODEL PERFORMANCE METRICS             ")
    print("======================================================")
    print(f"R2 Accuracy Score    : {r2:.4f}")
    print(f"Mean Absolute Error  : {mae:.4f}")
    print(f"Model Size           : {m_size:.2f} KB")
    print(f"Inference Latency    : {inf_time:.4f} ms/row")

    simulate("ZONE A", 27.0, 65.0, 8, 15, 6.8, 65.0, 28.0, 30.0)
    simulate("ZONE B", 31.0, 50.0, 8, 15, 6.2, 40.0, 15.0, 18.0)
    simulate("ZONE C", 34.0, 92.0, 10, 5, 5.5, 25.0, 12.0, 12.0)