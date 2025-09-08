import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

# ok-any: demo token assertion is string only

def test_health_ok():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json().get("status") == "ok"

# NOTE: pour un test e2e reel, il faut avoir un user seed en DB.
# Ce test est un placeholder minimal pour verifier la route existe.
