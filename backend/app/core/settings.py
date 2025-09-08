import os
from dataclasses import dataclass

@dataclass
class Settings:
    APP_ENV: str = os.getenv("APP_ENV", "dev")
    APP_HOST: str = os.getenv("APP_HOST", "0.0.0.0")
    APP_PORT: int = int(os.getenv("APP_PORT", "8000"))
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql+psycopg://orga:orga@db:5432/orga")

settings = Settings()
