import pandas as pd
import xgboost as xgb
import matplotlib.pyplot as plt
import seaborn as sns
import os

# Paths
DATA_PATH = "data/processed/tn_master_dataset.parquet"
MODEL_PATH = "models/risk_xgboost.json"
PLOT_DIR = "plots"

def create_visuals():
    print("📊 Generating AgriSync Visual Analytics for Tamil Nadu...")
    
    # 1. Load Data and Model
    if not os.path.exists(DATA_PATH):
        print("❌ Error: Processed data not found!")
        return
    
    df = pd.read_parquet(DATA_PATH)
    model = xgb.XGBRegressor()
    model.load_model(MODEL_PATH)
    
    # 2. Select Features (Must match the ones used in training)
    features = ['temp', 'humidity', 'month', 'day', 'pH', 'N', 'P', 'K']
    
    # 3. Create 'Actual vs Predicted' Sample
    # We take a slice of 100 rows to show a clear trend
    sample = df.sample(100).sort_values(by=['month', 'day'])
    X_sample = sample[features]
    y_actual = sample['soil_moisture']
    y_pred = model.predict(X_sample)
    
    # Ensure the plot directory exists
    if not os.path.exists(PLOT_DIR): os.makedirs(PLOT_DIR)

    # --- CHART 1: Actual vs Predicted (Accuracy Proof) ---
    plt.figure(figsize=(12, 6))
    plt.plot(y_actual.values, label='Actual Ground Truth', color='#1f77b4', linewidth=2, marker='o', markersize=4)
    plt.plot(y_pred, label='AgriSync AI Prediction', color='#ff7f0e', linestyle='--', linewidth=2, marker='x', markersize=4)
    
    plt.title("AgriSync AI: Soil Moisture Prediction Accuracy (Tamil Nadu)", fontsize=16, fontweight='bold')
    plt.xlabel("Sample Timeline (Randomly Sampled)", fontsize=12)
    plt.ylabel("Soil Moisture %", fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    plt.savefig(f"{PLOT_DIR}/accuracy_chart.png", dpi=300)
    print("✅ Saved: plots/accuracy_chart.png")

    # --- CHART 2: Feature Importance (Decision Logic) ---
    plt.figure(figsize=(10, 6))
    importances = model.feature_importances_
    feat_import_df = pd.DataFrame({'Feature': features, 'Importance': importances})
    feat_import_df = feat_import_df.sort_values(by='Importance', ascending=False)
    
    sns.barplot(x='Importance', y='Feature', data=feat_import_df, palette='viridis')
    plt.title("Key Drivers of Agricultural Risk in Tamil Nadu", fontsize=16, fontweight='bold')
    plt.xlabel("Importance Score (Contribution to Risk Detection)", fontsize=12)
    
    plt.savefig(f"{PLOT_DIR}/feature_importance.png", dpi=300)
    print("✅ Saved: plots/feature_importance.png")
    
    plt.show()

if __name__ == "__main__":
    create_visuals()