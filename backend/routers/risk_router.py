from fastapi import APIRouter
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from schemas.risk_schema import ClientData
from services.risk_engine import risk_service

router = APIRouter()

@router.post("/predict")
def predict(data: ClientData):
    # İşi uzmanına (Service) devret
    return risk_service.calculate_risk(data)