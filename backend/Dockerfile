FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System deps needed by healthcheck (curl); psycopg[binary] bundles libpq
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend

# Copy backend sources
COPY backend/ /app/backend/

# Install Python deps (include email-validator and newer psycopg[binary])
RUN pip install --no-cache-dir \
    fastapi==0.112.2 \
    uvicorn[standard]==0.30.6 \
    SQLAlchemy==2.0.35 \
    pydantic==2.8.2 \
    pydantic-settings==2.4.0 \
    email-validator>=2.2.0 \
    'psycopg[binary]==3.2.10' \
    alembic==1.13.2 \
    python-multipart==0.0.9 \
    PyJWT==2.9.0 \
    bcrypt==4.2.0

EXPOSE 8000
CMD ["bash","-lc","./docker/entrypoint.sh"]
