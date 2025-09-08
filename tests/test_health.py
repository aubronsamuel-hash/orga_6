import os
import requests

BASE = os.getenv("API_BASE", "http://localhost:8000")

def test_health():
    r = requests.get(f"{BASE}/health", timeout=5)
    assert r.status_code == 200
    data = r.json()
    assert data.get("status") == "ok"
