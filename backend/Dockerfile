FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# System deps needed by healthcheck and psycopg
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend

# Install Python deps
COPY backend/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy backend sources
COPY backend/ /app/backend/

EXPOSE 8000
CMD ["bash","-lc","./docker/entrypoint.sh"]
