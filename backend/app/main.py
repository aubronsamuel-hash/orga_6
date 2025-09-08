from fastapi import FastAPI
from .core.settings import settings

app = FastAPI(title="Orga API", version="0.1.0")

@app.get("/health")
def health():
    return {"status": "ok", "env": settings.APP_ENV}
