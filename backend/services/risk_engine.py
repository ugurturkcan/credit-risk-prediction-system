import pandas as pd
import joblib
import os
import logging
import sys

# Ayarlar ve Yollar
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from config import MODEL_PATH, COLUMNS_PATH

# --- 1. PROFESYONEL LOGLAMA KURULUMU ---
# Bu ayar sayesinde her işlem 'system.log' dosyasına tarih/saat ile kaydedilecek.
logging.basicConfig(
    filename='system.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    encoding='utf-8' # Türkçe karakter sorunu olmasın
)
logger = logging.getLogger(__name__)

class RiskService:
    def __init__(self):
        self.model = None
        self.model_columns = None
        self._load_model()

    def _load_model(self):
        try:
            self.model = joblib.load(MODEL_PATH)
            self.model_columns = joblib.load(COLUMNS_PATH)
            logger.info("✅ AI Model ve Sütunlar başarıyla yüklendi.")
        except Exception as e:
            logger.error(f"❌ MODEL YÜKLEME HATASI: {e}")

    def calculate_risk(self, data):
        logger.info(f"Yeni Başvuru Geldi: Gelir={data.income}, Kredi={data.credit_amount}")
        
        decision_log = []
        suggestion = None # Kullanıcıya vereceğimiz tavsiye

        # --- HESAPLAMALAR ---
        total_payment = data.credit_amount * (1 + (0.03 * data.credit_term))
        monthly_installment = total_payment / data.credit_term
        dti_ratio = monthly_installment / data.income

        # --- 1. RULE ENGINE (KURALLAR) ---
        if data.age < 18:
            logger.warning("Başvuru Reddedildi: Yaş Sınırı")
            return self._build_response("REJECT", 0, 0, monthly_installment, "Yasal yaş sınırı (18) altındasınız.", None)
        
        # DTI Kuralı (Maaşın %65'i)
        if dti_ratio > 0.65:
            # --- AKILLI ÖNERİ 1: Kredi Miktarını Düşür ---
            # Formül: (Gelir * 0.65 * Vade) / (1 + Faiz) -> Kabaca ne kadar alabilir?
            max_affordable_installment = data.income * 0.65
            max_total_payment = max_affordable_installment * data.credit_term
            max_loan_principal = max_total_payment / (1 + (0.03 * data.credit_term))
            
            suggestion = f"Geliriniz bu taksidi karşılamıyor. Kredi tutarını {int(max_loan_principal)} TL seviyesine çekerseniz onay alabilirsiniz."
            
            logger.warning(f"Başvuru Reddedildi: DTI Yüksek ({dti_ratio:.2f})")
            return self._build_response("REJECT", 0, 0, monthly_installment, "Gelir/Taksit dengesi yetersiz.", suggestion)

        # --- 2. AI TAHMİNİ ---
        if not self.model:
            return self._build_response("ERROR", 0, 0, 0, "Model servisi çalışmıyor.", None)

        try:
            # Feature Engineering
            credit_income_ratio = data.credit_amount / data.income
            annuity_income_ratio = monthly_installment / data.income
            
            education_map = {'Ortaokul': 1, 'Lise': 2, 'Incomplete higher': 3, 'Universite': 4, 'Yuksek Lisans': 5, 'Doktora': 5}
            edu_encoded = education_map.get(data.education, 2)

            features = {
                'AMT_INCOME_TOTAL': data.income,
                'AMT_CREDIT': data.credit_amount,
                'CREDIT_INCOME_RATIO': credit_income_ratio,
                'ANNUITY_INCOME_RATIO': annuity_income_ratio,
                'CREDIT_TERM': data.credit_term/30 if data.credit_term > 60 else data.credit_term,
                'AGE': data.age,
                'YEARS_EMPLOYED': data.years_employed,
                'EDUCATION_LEVEL': edu_encoded,
                'IS_MARRIED': 1 if data.is_married else 0,
                'EXT_SOURCE_2': data.ext_score_guess
            }
            
            input_df = pd.DataFrame([features])
            for col in self.model_columns:
                if col not in input_df.columns: input_df[col] = 0
            input_df = input_df[self.model_columns]

            # Tahmin
            risk_prob = self.model.predict_proba(input_df)[0][1]
            score = int((1 - risk_prob) * 1000)
            status = "REJECT" if risk_prob > 0.45 else "APPROVE"
            
            reason = "Yapay Zeka Onayladı"
            
            if status == "REJECT":
                reason = "Yapay Zeka Yüksek Risk Buldu"
                logger.info(f"AI Reddedildi. Skor: {score}, Risk: {risk_prob:.2f}")
                
                # --- AKILLI ÖNERİ 2: "What-If" Analizi (Loop) ---
                # Geliri %10, %20... %50 artırarak deneme yapalım
                # "Acaba maaşı ne kadar olsaydı kurtarırdı?"
                original_income = data.income
                found_solution = False
                
                for increase in [1.10, 1.20, 1.30, 1.40, 1.50]: # %10'dan %50'ye kadar artış dene
                    temp_income = original_income * increase
                    
                    # Geçici DataFrame'de geliri ve oranları güncelle
                    input_df.at[0, 'AMT_INCOME_TOTAL'] = temp_income
                    input_df.at[0, 'CREDIT_INCOME_RATIO'] = data.credit_amount / temp_income
                    input_df.at[0, 'ANNUITY_INCOME_RATIO'] = monthly_installment / temp_income
                    
                    # Tekrar Modele Sor
                    new_prob = self.model.predict_proba(input_df)[0][1]
                    
                    if new_prob <= 0.45: # Eğer bu gelirle geçiyorsa
                        suggestion = f"Mevcut şartlarda riskli görünüyorsunuz. Ancak aylık geliriniz {int(temp_income)} TL olsaydı onaylanabilirdiniz."
                        found_solution = True
                        break
                
                if not found_solution:
                    suggestion = "Risk skoru çok yüksek. Vadeyi uzatmayı veya daha düşük tutar istemeyi deneyin."

            else:
                logger.info(f"AI Onayladı. Skor: {score}")

            return self._build_response(status, score, risk_prob, monthly_installment, reason, suggestion)

        except Exception as e:
            logger.error(f"HESAPLAMA HATASI: {e}")
            return self._build_response("ERROR", 0, 0, 0, str(e), None)

    def _build_response(self, status, score, prob, installment, reason, suggestion):
        return {
            "status": status,
            "credit_score": score,
            "risk_probability": round(prob, 2),
            "monthly_installment": int(installment),
            "reason": reason,
            "suggestion": suggestion # <--- Yeni eklenen alan
        }

risk_service = RiskService()