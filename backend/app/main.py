from fastapi import FastAPI
from .routers import users, missions, assignments

app = FastAPI(title="Orga API")

@app.get("/health")
def health():
    return {"status": "ok"}

app.include_router(users.router)
app.include_router(missions.router)
app.include_router(assignments.router)
