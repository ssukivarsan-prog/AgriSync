import os
import json
import joblib
import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report

ROOT = Path(r"d:\FLUTTER PROJECTS\AgriVyn")
MODELS_DIR = ROOT / "models" / "diagnostic"
MODELS_DIR.mkdir(parents=True, exist_ok=True)

def train_tabular_models():
    print("=== Training Diagnostic Symptom Models ===")
    sc_dir = ROOT / "DATASETS" / "Crop Dataset — Sugarcane-focused"
    
    # 1. Disease Presence Model (30 symptom questions)
    df_disease = pd.read_csv(sc_dir / "synthetic_disease_presence_30_questions.csv")
    feature_cols_d = [c for c in df_disease.columns if c != "Disease_Present"]
    
    # Clean and encode Yes/No to 1/0
    X_d = df_disease[feature_cols_d].copy()
    for c in feature_cols_d:
        X_d[c] = X_d[c].astype(str).str.strip().map({"Yes": 1, "No": 0, "yes": 1, "no": 0}).fillna(0).astype(int)
    y_d = df_disease["Disease_Present"].astype(str).str.strip().map({"Present": 1, "Not Present": 0}).fillna(0).astype(int)
    
    X_train_d, X_test_d, y_train_d, y_test_d = train_test_split(X_d, y_d, test_size=0.25, random_state=42, stratify=y_d)
    
    clf_disease = RandomForestClassifier(n_estimators=100, max_depth=6, random_state=42)
    clf_disease.fit(X_train_d, y_train_d)
    y_pred_d = clf_disease.predict(X_test_d)
    
    acc_d = float(accuracy_score(y_test_d, y_pred_d))
    prec_d = float(precision_score(y_test_d, y_pred_d))
    rec_d = float(recall_score(y_test_d, y_pred_d))
    f1_d = float(f1_score(y_test_d, y_pred_d))
    cv_scores_d = cross_val_score(clf_disease, X_d, y_d, cv=5)
    
    print(f"Disease Presence Model - Accuracy: {acc_d:.4f}, Precision: {prec_d:.4f}, Recall: {rec_d:.4f}, F1: {f1_d:.4f}, CV Mean: {cv_scores_d.mean():.4f}")
    
    # Feature importances
    importances_d = sorted(zip(feature_cols_d, clf_disease.feature_importances_), key=lambda x: x[1], reverse=True)
    top_symptoms_d = [{"symptom": k, "importance": float(v)} for k, v in importances_d[:10]]
    
    # 2. Insect Presence Model (30 symptom questions)
    df_insect = pd.read_csv(sc_dir / "synthetic_insect_presence_30_questions.csv")
    feature_cols_i = [c for c in df_insect.columns if c != "Insect_Present"]
    
    # Clean and encode Yes/No to 1/0
    X_i = df_insect[feature_cols_i].copy()
    for c in feature_cols_i:
        X_i[c] = X_i[c].astype(str).str.strip().map({"Yes": 1, "No": 0, "yes": 1, "no": 0}).fillna(0).astype(int)
    y_i = df_insect["Insect_Present"].astype(str).str.strip().map({"Present": 1, "Not Present": 0}).fillna(0).astype(int)
    
    X_train_i, X_test_i, y_train_i, y_test_i = train_test_split(X_i, y_i, test_size=0.25, random_state=42, stratify=y_i)
    
    clf_insect = RandomForestClassifier(n_estimators=100, max_depth=6, random_state=42)
    clf_insect.fit(X_train_i, y_train_i)
    y_pred_i = clf_insect.predict(X_test_i)
    
    acc_i = float(accuracy_score(y_test_i, y_pred_i))
    prec_i = float(precision_score(y_test_i, y_pred_i))
    rec_i = float(recall_score(y_test_i, y_pred_i))
    f1_i = float(f1_score(y_test_i, y_pred_i))
    cv_scores_i = cross_val_score(clf_insect, X_i, y_i, cv=5)
    
    print(f"Insect Presence Model - Accuracy: {acc_i:.4f}, Precision: {prec_i:.4f}, Recall: {rec_i:.4f}, F1: {f1_i:.4f}, CV Mean: {cv_scores_i.mean():.4f}")
    
    importances_i = sorted(zip(feature_cols_i, clf_insect.feature_importances_), key=lambda x: x[1], reverse=True)
    top_symptoms_i = [{"symptom": k, "importance": float(v)} for k, v in importances_i[:10]]
    
    # Save models
    saved_bundle = {
        "disease_model": clf_disease,
        "disease_features": feature_cols_d,
        "insect_model": clf_insect,
        "insect_features": feature_cols_i,
    }
    joblib.dump(saved_bundle, MODELS_DIR / "symptom_models.joblib")
    
    metrics = {
        "disease_diagnostic": {
            "model": "RandomForestClassifier",
            "num_features": len(feature_cols_d),
            "test_accuracy": acc_d,
            "test_precision": prec_d,
            "test_recall": rec_d,
            "test_f1": f1_d,
            "cv_5fold_mean": float(cv_scores_d.mean()),
            "top_symptoms": top_symptoms_d
        },
        "insect_diagnostic": {
            "model": "RandomForestClassifier",
            "num_features": len(feature_cols_i),
            "test_accuracy": acc_i,
            "test_precision": prec_i,
            "test_recall": rec_i,
            "test_f1": f1_i,
            "cv_5fold_mean": float(cv_scores_i.mean()),
            "top_symptoms": top_symptoms_i
        }
    }
    
    with open(MODELS_DIR / "metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)
        
    print("Symptom models and metrics saved successfully!")

if __name__ == "__main__":
    train_tabular_models()
