import os

# Proje Ana Dizini
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Model Yolları
MODEL_PATH = os.path.join(BASE_DIR, "models", "credit_risk_model_final.pkl")
COLUMNS_PATH = os.path.join(BASE_DIR, "models", "model_columns_final.pkl")

# API Ayarları
API_TITLE = "AI Risk (Enterprise Edition)"
API_VERSION = "4.0"
HOST = "0.0.0.0"
PORT = 8000