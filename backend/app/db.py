from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from .core.settings import settings


def _normalize_db_url(url: str) -> str:
    """Convert filesystem-style paths to proper SQLite URLs."""
    if url.startswith("file:"):
        path = url[5:]
        if not (path.startswith("./") or path.startswith("/")):
            path = "./" + path
        return f"sqlite:///{path}"
    if url.startswith("sqlite://") and not url.startswith("sqlite:///"):
        rest = url[len("sqlite://"):]
        return f"sqlite:///{rest}"
    return url


SQLALCHEMY_DATABASE_URL = _normalize_db_url(settings.database_url)
engine = create_engine(SQLALCHEMY_DATABASE_URL, future=True, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
