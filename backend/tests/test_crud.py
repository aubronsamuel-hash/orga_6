import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from fastapi.testclient import TestClient
from app.main import app
from app.db import Base, engine

Base.metadata.create_all(bind=engine)

client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"

def test_user_crud():
    r = client.post("/users", json={"email":"u1@example.com","full_name":"User One"})
    assert r.status_code == 201
    user = r.json()
    uid = user["id"]

    r = client.get(f"/users/{uid}")
    assert r.status_code == 200
    assert r.json()["email"] == "u1@example.com"

    r = client.patch(f"/users/{uid}", json={"full_name":"User Uno"})
    assert r.status_code == 200
    assert r.json()["full_name"] == "User Uno"

    r = client.delete(f"/users/{uid}")
    assert r.status_code == 204

def test_mission_and_assignment_flow():
    u = client.post("/users", json={"email":"tech@example.com","full_name":"Tech One"}).json()
    m = client.post("/missions", json={"title":"Show","location":"Paris"}).json()
    payload = {
        "user_id": u["id"],
        "mission_id": m["id"],
        "role": "Light",
        "start_at": "2025-09-08T10:00:00Z",
        "end_at": "2025-09-08T18:00:00Z"
    }
    a = client.post("/assignments", json=payload)
    assert a.status_code == 201
    body = a.json()
    assert body["user_id"] == u["id"]
    assert body["mission_id"] == m["id"]
