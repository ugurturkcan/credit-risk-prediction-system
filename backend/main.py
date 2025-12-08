import uvicorn
from fastapi import FastAPI
from config import API_TITLE, API_VERSION, HOST, PORT
from routers import risk_router
from fastapi.middleware.cors import CORSMiddleware

# Uygulamayı Başlat
app = FastAPI(title=API_TITLE, version=API_VERSION)


# --- CORS AYARLARI (Web İçin Zorunlu) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tüm sitelerden (Web, Mobil) gelen isteklere izin ver
    allow_credentials=True,
    allow_methods=["*"],  # GET, POST her şeye izin ver
    allow_headers=["*"],
)
# ----------------------------------------

# Rotaları (Garsonları) Dahil Et
app.include_router(risk_router.router)

if __name__ == "__main__":
    print(f"🚀 {API_TITLE} Başlatılıyor...")
    uvicorn.run(app, host=HOST, port=PORT)