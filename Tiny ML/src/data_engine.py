import pandas as pd
import os

RAW_PATH = "data/raw/"
PROCESSED_PATH = "data/processed/"

def process_agrisync_data():
    print("🔄 Standardizing Datasets (Using Position-Based Mapping)...")

    # 1. Load Weather & Soil
    humid = pd.read_csv(RAW_PATH + "humid_tel_hr_tamil_nadu_sw_gw_tn_2026_2030.csv")
    humid = humid.rename(columns={'Data Acquisition Time': 'timestamp', 'District': 'district', 'Telemetry Hourly Relative Humidity (%)': 'humidity'})

    temp_csv = RAW_PATH + "temprature_tel_hr_tamil_nadu_sw_gw_tn_2021_2025.csv"
    temp_zip = RAW_PATH + "temprature_tel_hr_tamil_nadu_sw_gw_tn_2021_2025.csv.zip"
    if not os.path.exists(temp_csv) and os.path.exists(temp_zip):
        import zipfile
        print("📦 Unzipping compressed temperature dataset for first-time use...")
        with zipfile.ZipFile(temp_zip, 'r') as zf:
            zf.extractall(RAW_PATH)

    temp = pd.read_csv(temp_csv)
    temp = temp.rename(columns={'Data Acquisition Time': 'timestamp', 'District': 'district', 'Air Temperature Telemetry Hourly (ºC)': 'temp'})

    soil = pd.read_csv(RAW_PATH + "sm_Tamilnadu_2020.csv")
    soil = soil.rename(columns={'Date': 'timestamp', 'DistrictName': 'district', 'Average Soilmoisture Level (at 15cm)': 'soil_moisture'})

    # 2. Load NEW Nutrient Data (Using Column Positions to avoid Name Errors)
    try:
        nutrients_raw = pd.read_csv(RAW_PATH + "new_tn_npk.csv")
        print(f"📊 Found {len(nutrients_raw.columns)} columns in new_tn_npk.csv")
        
        # We assume: Column 0 = District, Column 1 = pH, Column 2 = N, Column 3 = P, Column 4 = K
        # If your file has a different order, this iloc will still grab the first 5 available columns
        nutrients = nutrients_raw.iloc[:, [0, 1, 2, 3, 4]].copy()
        nutrients.columns = ['district', 'pH', 'N', 'P', 'K']
        
    except Exception as e:
        print(f"❌ Error loading new_tn_npk.csv: {e}")
        return

    print("Parsing dates and aligning seasons...")
    for df in [humid, temp, soil]:
        df['timestamp'] = pd.to_datetime(df['timestamp'], dayfirst=True, errors='coerce', format='mixed')
        df.dropna(subset=['timestamp'], inplace=True)
        df['month'] = df['timestamp'].dt.month
        df['day'] = df['timestamp'].dt.day
        df['hour'] = df['timestamp'].dt.hour
        df['district'] = df['district'].astype(str).str.strip().str.upper()
    
    nutrients['district'] = nutrients['district'].astype(str).str.strip().str.upper()

    print("Merging Weather and Soil...")
    weather = pd.merge(humid, temp[['month', 'day', 'hour', 'Station', 'temp']], on=['month', 'day', 'hour', 'Station'], how='inner')
    master_df = pd.merge(weather, soil[['month', 'day', 'district', 'soil_moisture']], on=['month', 'day', 'district'], how='inner')
    
    print("Merging Statewide Nutrients...")
    # Using 'left' join so we don't lose data if a district name is slightly different
    master_df = pd.merge(master_df, nutrients, on='district', how='left')

    # Ensure all are numeric and fill missing values with mean
    numeric_cols = ['N', 'P', 'K', 'pH', 'temp', 'humidity', 'soil_moisture']
    for col in numeric_cols:
        master_df[col] = pd.to_numeric(master_df[col], errors='coerce')
        master_df[col] = master_df[col].fillna(master_df[col].mean())

    # Final Output
    if not os.path.exists(PROCESSED_PATH): os.makedirs(PROCESSED_PATH)
    master_df.to_parquet(os.path.join(PROCESSED_PATH, "tn_master_dataset.parquet"))
    
    print("\n" + "="*40)
    print("✅ FINAL MASTER DATASET READY!")
    print("="*40)
    print(f"Features Integrated: {list(master_df.columns)}")

if __name__ == "__main__":
    process_agrisync_data()