import xgboost as xgb
import pandas as pd

# Load the trained model
model = xgb.XGBRegressor()
model.load_model("models/risk_xgboost.json")

def get_farmer_advice(temp, humidity, month, day, pH=7.0, N=50.0, P=20.0, K=30.0, rainfall=0.0):
    # Prepare the input data with ALL 8 features used in training
    features = ['temp', 'humidity', 'month', 'day', 'pH', 'N', 'P', 'K']
    input_values = [[temp, humidity, month, day, pH, N, P, K]]
    
    input_data = pd.DataFrame(input_values, columns=features)
    
    # Predict soil moisture
    predicted_sm = model.predict(input_data)[0]
    
    print(f"\n--- AgriSync Assistant Report ---")
    print(f"Predicted Soil Moisture: {predicted_sm:.2f}%")
    print(f"Current Soil Context: pH={pH}, N={N}, P={P}, K={K}")
    
    # 1. Irrigation Advice
    if predicted_sm < 0.30 or predicted_sm < 15: # Support both normalized 0-1 and percentage
        advice = "🚨 RISK: Critical Soil Dryness! Activate irrigation immediately."
    elif predicted_sm > 0.60 or predicted_sm > 40:
        advice = "⚠️ ALERT: High water saturation. Stop irrigation to prevent root rot."
    else:
        advice = "✅ STABLE: Soil moisture is optimal."

    # 2. Nutrient Advice
    if pH < 6.0:
        advice += "\n🧪 SOIL NOTE: Soil is acidic. Consider adding lime to stabilize pH."
    elif pH > 8.5:
        advice += "\n🧪 SOIL NOTE: Soil is alkaline. Consider adding gypsum."
    if N < 35 or P < 15 or K < 20:
        advice += "\n🌱 NUTRIENT NOTE: Low NPK detected. Consider balanced NPK fertilizer."

    return advice

# Example: Testing the assistant with specific Tamil Nadu data
if __name__ == "__main__":
    # Simulate: June 15th, 35C Temp, 40% Humidity, and Soil Health data
    print("Testing Assistant for a dry day in Dharmapuri...")
    report = get_farmer_advice(
        temp=35, 
        humidity=40, 
        month=6, 
        day=15, 
        pH=6.5, 
        N=45.0, 
        P=18.0,
        K=25.0
    )
    print(report)