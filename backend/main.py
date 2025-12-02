import uvicorn
from fastapi import FastAPI
from config import API_TITLE, API_VERSION, HOST, PORT
from routers import risk_router

# Uygulamayı Başlat
app = FastAPI(title=API_TITLE, version=API_VERSION)

# Rotaları (Garsonları) Dahil Et
app.include_router(risk_router.router)

if __name__ == "__main__":
    print(f"🚀 {API_TITLE} Başlatılıyor...")
    uvicorn.run(app, host=HOST, port=PORT)