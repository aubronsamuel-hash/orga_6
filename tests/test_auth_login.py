from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

# ok-any: demo token assertion is string only

def test_health_ok():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json().get("status") == "ok"
