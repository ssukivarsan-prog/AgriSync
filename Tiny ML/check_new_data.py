import pandas as pd
import os

folder = "data/raw/"
files = [f for f in os.listdir(folder) if f.endswith(".csv")]

print("--- DETAILED COLUMN REPORT ---")
for file in files:
    try:
        df = pd.read_csv(os.path.join(folder, file), nrows=0)
        print(f"\n?? FILE: {file}")
        print(f"   COLUMNS: {list(df.columns)}")
    except Exception as e:
        print(f"   Could not read {file}: {e}")
