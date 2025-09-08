#!/usr/bin/env bash
set -euo pipefail

# Ensure we are in backend dir
cd /app/backend

# Wait for DB if using Postgres
if [[ "${DATABASE_URL:-}" == postgresql* ]]; then
  python - <<'PY'
import os, time
import psycopg
url=os.getenv("DATABASE_URL")
for i in range(60):
    try:
        with psycopg.connect(url, connect_timeout=3) as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        break
    except Exception as e:
        print("DB not ready, retrying...", e)
        time.sleep(2)
else:
    raise SystemExit("DB never became ready")
PY
fi

# Apply migrations
alembic upgrade head

# Start API
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
