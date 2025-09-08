import os
from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    app_env: str = Field(default=os.getenv("APP_ENV", "dev"))
    app_debug: bool = Field(default=os.getenv("APP_DEBUG", "true").lower() == "true")
    database_url: str = Field(default=os.getenv("DATABASE_URL", "sqlite:///./dev.db"))

settings = Settings()
