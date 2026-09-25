import xgboost as xgb
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.preprocessing import LabelEncoder
import os
import warnings

# Suppress the "use_label_encoder" warning
warnings.filterwarnings("ignore")

INPUT_FILE = "data/processed/tn_master_dataset.parquet"
MODEL_PATH = "models/risk_xgboost.json"

def train_agrisync_ai():
    print(" Initializing AgriSync AI Classifier...")
    
    if not os.path.exists(INPUT_FILE):
        print("❌ Error: Master dataset not found!")
        return
    
    df = pd.read_parquet(INPUT_FILE)
    
    # 1. Categorize Moisture into Labels
    def categorize(val):
        if val < 0.30: return "Drought"
        elif val > 0.60: return "Healthy"
        else: return "Warning"
    
    df['class'] = df['soil_moisture'].apply(categorize)
    
    # 2. Encode Labels
    le = LabelEncoder()
    y = le.fit_transform(df['class'])
    
    # Select features (Ensure these exist in your processed data)
    X = df[['temp', 'humidity', 'month', 'day', 'pH', 'N', 'P', 'K']]
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # 3. Train Soil Moisture Regressor (for Continuous Risk Index & TinyML Export)
    y_reg = df['soil_moisture']
    X_train_r, X_test_r, y_train_r, y_test_r = train_test_split(X, y_reg, test_size=0.2, random_state=42)
    
    reg_model = xgb.XGBRegressor(n_estimators=50, max_depth=5, learning_rate=0.1, random_state=42)
    reg_model.fit(X_train_r, y_train_r)
    
    # 4. Save Regressor Model (Loaded by demo, API, assistant, and TinyML C++ exporter)
    if not os.path.exists('models'): os.makedirs('models')
    reg_model.save_model(MODEL_PATH)
    print(f"\n✅ Soil Moisture Regressor saved to {MODEL_PATH}")
    
    # 5. Train Classifier for categorical reporting (Drought / Warning / Healthy)
    clf = xgb.XGBClassifier(eval_metric='mlogloss', n_estimators=50, max_depth=5, random_state=42)
    clf.fit(X_train, y_train)
    preds = clf.predict(X_test)
    
    print("\n--- CLASSIFICATION METRICS (For Reviewer) ---")
    print(classification_report(y_test, preds, target_names=le.classes_))
    
    print("\n--- CONFUSION MATRIX ---")
    print(confusion_matrix(y_test, preds))
    
    clf.save_model("models/risk_classifier.json")
    print(f"✅ Risk Classifier saved to models/risk_classifier.json")

if __name__ == "__main__":
    train_agrisync_ai()