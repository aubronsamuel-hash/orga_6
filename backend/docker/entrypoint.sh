#!/usr/bin/env bash
set -euo pipefail

# Ensure we are in backend dir
cd /app/backend

# Normalize DATABASE_URL for psycopg wait: convert sqlalchemy scheme to postgres uri
DB_URL="${DATABASE_URL:-}"
if [[ -n "$DB_URL" && "$DB_URL" == postgresql+psycopg://* ]]; then
  DB_URL_PG="${DB_URL/postgresql+psycopg:/postgresql:}"
else
  DB_URL_PG="$DB_URL"
fi
export DB_URL_PG

# Wait for DB (Postgres only)
if [[ "${DB_URL_PG:-}" == postgresql* ]]; then
  python - <<'PY'
import os, time
import psycopg
url=os.environ.get("DB_URL_PG") or os.environ.get("DATABASE_URL")
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
