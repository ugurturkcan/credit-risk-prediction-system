import sys
import os
import pytest

# Proje ana dizinini yola ekle (Import hatası almamak için)
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from schemas.risk_schema import ClientData
from services.risk_engine import risk_service

# --- TEST SENARYOLARI ---

def test_under_age_rejection():
    """Senaryo 1: 17 Yaşındaki biri başvurursa sistem RED vermeli."""
    data = ClientData(
        income=50000, credit_amount=100000, age=17, # <--- KRİTİK
        education="Lise", years_employed=5, is_married=False,
        credit_term=12, ext_score_guess=0.5
    )
    
    result = risk_service.calculate_risk(data)
    
    assert result["status"] == "REJECT"
    assert "yaş sınırı" in result["reason"].lower()
    print("\n✅ Test 1 Başarılı: 17 Yaş Engellendi.")

def test_high_dti_rejection():
    """Senaryo 2: Maaş yetersizse sistem RED vermeli."""
    # Maaş 10.000, Taksit yaklaşık 80.000 çıkacak (1 Milyon kredi)
    data = ClientData(
        income=10000, credit_amount=1000000, age=30,
        education="Universite", years_employed=5, is_married=False,
        credit_term=12, ext_score_guess=0.8
    )
    
    result = risk_service.calculate_risk(data)
    
    assert result["status"] == "REJECT"
    assert "gelir yetersiz" in result["reason"].lower() or "taksit" in result["reason"].lower()
    print("✅ Test 2 Başarılı: Yüksek Borç Engellendi.")

def test_valid_application():
    """Senaryo 3: Her şey düzgünse sistem ÇALIŞMALI (Hata vermemeli)."""
    data = ClientData(
        income=100000, credit_amount=50000, age=30,
        education="Universite", years_employed=5, is_married=True,
        credit_term=24, ext_score_guess=0.7
    )
    
    result = risk_service.calculate_risk(data)
    
    # Onay veya Ret önemli değil, önemli olan "ERROR" dönmemesi.
    assert result["status"] in ["APPROVE", "REJECT"]
    print(f"✅ Test 3 Başarılı: Geçerli başvuru işlendi. Sonuç: {result['status']}")

# Bu dosyayı direkt çalıştırırsak testleri başlat
if __name__ == "__main__":
    test_under_age_rejection()
    test_high_dti_rejection()
    test_valid_application()
    print("\n🚀 TÜM TESTLER BAŞARIYLA GEÇTİ!")