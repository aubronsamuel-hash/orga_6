FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System deps needed by healthcheck and psycopg
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend

# Copy backend sources
COPY backend/ /app/backend/

# Install Python deps
RUN pip install --no-cache-dir \
    fastapi==0.112.2 \
    uvicorn[standard]==0.30.6 \
    SQLAlchemy==2.0.35 \
    pydantic==2.8.2 \
    pydantic-settings==2.4.0 \
    psycopg[binary]==3.2.1 \
    psycopg-binary==3.2.1 \
    alembic==1.13.2 \
    python-multipart==0.0.9

EXPOSE 8000
CMD ["bash","-lc","./docker/entrypoint.sh"]
