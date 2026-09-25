import json
import xgboost as xgb
import os

# The exact order the C++ array x[] will use (0-indexed for 8 features)
FEATURE_MAP = {
    'temp': 0,
    'humidity': 1,
    'month': 2,
    'day': 3,
    'pH': 4,
    'N': 5,
    'P': 6,
    'K': 7,
}

def parse_tree(node, depth):
    if "leaf" in node:
        return f"{node['leaf']}f"
    
    # Get the feature name (e.g., 'month' or 'temp')
    feature_name = node['split']
    
    # Map the name to our C++ array index x[i]
    if feature_name in FEATURE_MAP:
        feat_idx = FEATURE_MAP[feature_name]
    else:
        # Fallback if names are stored as 'f0', 'f1', etc.
        try:
            feat_idx = int(feature_name[1:])
        except:
            feat_idx = 0 # Default fallback
            
    threshold = node['split_condition']
    
    left = parse_tree(node['children'][0], depth + 1)
    right = parse_tree(node['children'][1], depth + 1)
    
    return f"(x[{feat_idx}] < {threshold}f ? {left} : {right})"

def generate_cpp_code(tree_list):
    cpp_code = "float predict_risk(float* x) {\n    float score = 0.5f; // Base bias\n"
    for i, tree in enumerate(tree_list):
        cpp_code += f"    score += {parse_tree(tree, 1)};\n"
    cpp_code += "    return score;\n}"
    return cpp_code

def run_export():
    print("🚀 Running Custom AgriSync TinyML Converter (Feature Mapping Enabled)...")
    
    if not os.path.exists("models/risk_xgboost.json"):
        print("❌ Error: models/risk_xgboost.json not found!")
        return
        
    # Load model
    model = xgb.XGBRegressor()
    model.load_model("models/risk_xgboost.json")
    
    # Export to JSON
    model_json = model.get_booster().get_dump(with_stats=False, dump_format='json')
    trees = [json.loads(t) for t in model_json]
    
    # Generate C++ content
    header_content = """/* 
 * AgriSync TinyML Model (Generated for ESP32/Arduino)
 * 
 * Input Array Mapping:
 * x[0] = Temperature
 * x[1] = Humidity
 * x[2] = Month
 * x[3] = Day
 * x[4] = pH
 * x[5] = Nitrogen (N)
 * x[6] = Phosphorus (P)
 * x[7] = Potassium (K)
 */

"""
    header_content += generate_cpp_code(trees)
    
    # Save to firmware folder
    if not os.path.exists('firmware'): os.makedirs('firmware')
    with open("firmware/agrisync_model.h", "w") as f:
        f.write("#ifndef AGRISYNC_MODEL_H\n#define AGRISYNC_MODEL_H\n\n")
        f.write(header_content)
        f.write("\n\n#endif")
    
    print("✅ SUCCESS: firmware/agrisync_model.h is now ready!")
    print("This file contains the full AI logic as a C++ function.")

if __name__ == "__main__":
    run_export()