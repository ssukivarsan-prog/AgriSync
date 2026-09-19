import json
import time
from pathlib import Path
import numpy as np
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
MODELS_DIR = ROOT / "models" / "environment"
MODELS_DIR.mkdir(parents=True, exist_ok=True)

def generate_environmental_dataset(n_samples=2500, random_seed=42):
    np.random.seed(random_seed)
    
    # Generate realistic soil and weather parameters based on ICAR agronomic profiles
    sm = np.random.uniform(10.0, 75.0, n_samples)          # Soil Moisture (%)
    temp = np.random.uniform(12.0, 46.0, n_samples)        # Temperature (C)
    rh = np.random.uniform(20.0, 98.0, n_samples)          # Relative Humidity (%)
    rain = np.random.exponential(scale=12.0, size=n_samples) # Rainfall (mm)
    ph = np.random.uniform(4.5, 9.0, n_samples)            # Soil pH
    n_val = np.random.uniform(40.0, 280.0, n_samples)      # Nitrogen (mg/kg)
    p_val = np.random.uniform(10.0, 90.0, n_samples)       # Phosphorus (mg/kg)
    k_val = np.random.uniform(30.0, 320.0, n_samples)      # Potassium (mg/kg)

    X = np.column_stack([sm, temp, rh, rain, ph, n_val, p_val, k_val])
    y = np.zeros(n_samples, dtype=int)

    # Class 0: OPTIMAL
    # Class 1: DROUGHT_STRESS (low moisture, high temp, no rain)
    # Class 2: HEAT_STRESS (extreme temp >= 38C)
    # Class 3: WATERLOGGING_FLOOD (excess moisture >= 55% & heavy rain >= 40mm)
    # Class 4: NUTRIENT_DEPLETED (low NPK or extreme pH)
    for i in range(n_samples):
        if sm[i] < 22.0 and rain[i] < 5.0:
            y[i] = 1 # DROUGHT_STRESS
        elif temp[i] >= 38.0:
            y[i] = 2 # HEAT_STRESS
        elif sm[i] >= 55.0 and rain[i] >= 35.0:
            y[i] = 3 # WATERLOGGING_FLOOD
        elif n_val[i] < 70.0 or k_val[i] < 60.0 or ph[i] < 5.5 or ph[i] > 8.2:
            y[i] = 4 # NUTRIENT_DEPLETED
        else:
            y[i] = 0 # OPTIMAL

    return X, y

def train_xgboost():
    print("=== Training XGBoost Soil & Environmental Condition Model ===")
    X, y = generate_environmental_dataset(n_samples=3000)
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    
    model = xgb.XGBClassifier(
        n_estimators=100,
        max_depth=5,
        learning_rate=0.08,
        objective="multi:softmax",
        num_class=5,
        random_state=42,
        eval_metric="mlogloss"
    )

    t0 = time.time()
    model.fit(X_train, y_train)
    train_time = time.time() - t0

    # Evaluate latency & accuracy
    t_start = time.time()
    y_pred = model.predict(X_test)
    test_latency_ms = ((time.time() - t_start) / len(X_test)) * 1000

    acc = accuracy_score(y_test, y_pred)
    prec = precision_score(y_test, y_pred, average="weighted", zero_division=0)
    rec = recall_score(y_test, y_pred, average="weighted", zero_division=0)
    f1 = f1_score(y_test, y_pred, average="weighted", zero_division=0)

    print(f"XGBoost Test Accuracy: {acc*100:.2f}%")
    print(f"XGBoost Test Precision: {prec*100:.2f}%")
    print(f"XGBoost CPU Latency: {test_latency_ms:.4f} ms")

    # Save model
    model_file = MODELS_DIR / "xgboost_soil_env.json"
    model.save_model(str(model_file))
    print(f"Saved model to: {model_file}")

    class_names = [
        "OPTIMAL",
        "DROUGHT_STRESS",
        "HEAT_STRESS",
        "WATERLOGGING_FLOOD",
        "NUTRIENT_DEPLETED"
    ]

    metrics = {
        "model_name": "XGBoost Soil & Environmental Condition Classifier",
        "architecture": "Gradient Boosted Decision Trees (XGBoost 3.4.0)",
        "num_trees": 100,
        "max_depth": 5,
        "classes": class_names,
        "accuracy": round(float(acc), 4),
        "precision": round(float(prec), 4),
        "recall": round(float(rec), 4),
        "f1_score": round(float(f1), 4),
        "cpu_latency_ms": round(float(test_latency_ms), 3),
        "training_time_s": round(train_time, 2),
        "model_size_mb": round(model_file.stat().st_size / (1024 * 1024), 3)
    }

    with open(MODELS_DIR / "metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)

    with open(MODELS_DIR / "class_mapping.json", "w") as f:
        json.dump({str(i): c for i, c in enumerate(class_names)}, f, indent=2)

    print("XGBoost training pipeline completed successfully!")

if __name__ == "__main__":
    train_xgboost()
