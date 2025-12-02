from pydantic import BaseModel

# Girdi Modeli (Request)
class ClientData(BaseModel):
    income: float       # Aylık Gelir
    credit_amount: float # Kredi Tutarı
    age: int            # Yaş
    education: str      # Eğitim
    years_employed: float # Kıdem
    is_married: bool    # Evli mi
    credit_term: int    # Vade
    ext_score_guess: float # KKB

# Çıktı Modeli (Response) - İstersek bunu da özelleştirebiliriz ama şimdilik gerek yok.