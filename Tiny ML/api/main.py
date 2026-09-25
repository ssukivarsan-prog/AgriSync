from fastapi import FastAPI
from pydantic import BaseModel
import xgboost as xgb
import pandas as pd
import uvicorn
import os

# 1. Initialize FastAPI
app = FastAPI(
    title="AgriSync Smart Assistant API",
    description="Backend for early crop health and risk detection"
)

# 2. Load the trained AI Model
# Ensure the path points to your trained model
MODEL_PATH = "models/risk_xgboost.json"
model = xgb.XGBRegressor()
if os.path.exists(MODEL_PATH):
    model.load_model(MODEL_PATH)
else:
    print(f"❌ Error: Model file {MODEL_PATH} not found!")

# 3. Define the "Sensor Data" Schema (Data validation)
class SensorData(BaseModel):
    temp: float
    humidity: float
    month: int
    day: int
    pH: float = 7.0
    N: float = 50.0
    P: float = 20.0
    K: float = 30.0
    rainfall: float = 0.0

# 4. Create the Prediction Endpoint
@app.post("/predict")
async def predict_risk(data: SensorData):
    # Convert incoming JSON to a DataFrame for the model
    # MUST be in the same order as training
    features = ['temp', 'humidity', 'month', 'day', 'pH', 'N', 'P', 'K']
    input_df = pd.DataFrame([[
        data.temp, data.humidity, 
        data.month, data.day, data.pH, data.N, data.P, data.K
    ]], columns=features)
    
    # AI Prediction
    prediction = float(model.predict(input_df)[0])
    
    # Logic for Risk Level
    risk_level = "LOW"
    advice = "Environmental conditions are stable for the current crop cycle."
    
    if prediction < 0.30 or prediction < 15:
        risk_level = "HIGH (DROUGHT)"
        advice = "Critical soil moisture deficiency. Immediate irrigation recommended."
    elif prediction > 0.60 or prediction > 45:
        risk_level = "MODERATE (OVER-WATERED)"
        advice = "High moisture levels detected. Reduce irrigation to prevent root rot."

    return {
        "predicted_soil_moisture": f"{prediction:.4f}",
        "risk_level": risk_level,
        "recommendation": advice,
        "status": "Success"
    }

# Home route for testing
@app.get("/")
def home():
    return {
        "project": "AgriSync",
        "region": "Tamil Nadu",
        "accuracy": "95.72%",
        "status": "Online"
    }

if __name__ == "__main__":
    # Run the server locally on port 8000
    uvicorn.run(app, host="127.0.0.1", port=8000)