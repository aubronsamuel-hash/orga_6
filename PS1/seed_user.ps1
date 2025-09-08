param(
  [Parameter(Mandatory=$true)][string]$Email,
  [Parameter(Mandatory=$true)][string]$Password,
  [Parameter(Mandatory=$false)][string]$FullName = "Admin"
)

# This script seeds a user directly in the running API container using SQLAlchemy.
# It supports Docker Compose default service name 'api'. Adjust $Service if different.

$ErrorActionPreference = "Stop"
$Service = "api"

Write-Host "[seed_user] Email=$Email FullName=$FullName"

# Python snippet to run inside the API container
$py = @'
import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.core.settings import settings
from app.auth.hash import hash_password

engine = create_engine(settings.database_url, future=True, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)

email = os.environ.get("SEED_EMAIL")
password = os.environ.get("SEED_PASSWORD")
full_name = os.environ.get("SEED_FULLNAME", "Admin")

pwd_hash = hash_password(password)

with SessionLocal() as db:
    # upsert naive
    user = db.execute(text("SELECT id FROM users WHERE email=:e"), {"e": email}).fetchone()
    if user is None:
        db.execute(text("INSERT INTO users(email, full_name, password_hash) VALUES (:e, :f, :p)"), {"e": email, "f": full_name, "p": pwd_hash})
        db.commit()
        print("created")
    else:
        db.execute(text("UPDATE users SET full_name=:f, password_hash=:p WHERE email=:e"), {"e": email, "f": full_name, "p": pwd_hash})
        db.commit()
        print("updated")
'@

# Pass values as env to the container process
$envs = @(
  "SEED_EMAIL=$Email",
  "SEED_PASSWORD=$Password",
  "SEED_FULLNAME=$FullName"
)

# Try docker compose v2 ("docker compose"), then fallback to v1 ("docker-compose")
function Invoke-InContainer {
  param([string]$Service,[string]$Script,[string[]]$EnvVars)
  try {
    $envArgs = $EnvVars | ForEach-Object { "-e", $_ }
    docker compose exec -T @envArgs $Service python - <<EOF
$Script
EOF
  } catch {
    $envArgs = $EnvVars | ForEach-Object { "-e", $_ }
    docker-compose exec -T @envArgs $Service python - <<EOF
$Script
EOF
  }
}

Invoke-InContainer -Service $Service -Script $py -EnvVars $envs
Write-Host "[seed_user] done"

