from __future__ import annotations
import os, sys, pathlib
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

# Alembic Config
config = context.config

# DB URL from env
db_url = os.getenv("DATABASE_URL", "sqlite:///./dev.db")
config.set_main_option("sqlalchemy.url", db_url)

# Logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Make sure we can import `app` whether code sits at /app or /app/backend
here = pathlib.Path(__file__).resolve()
roots = {
    here.parents[1],                  # .../backend
    here.parents[2],                  # .../ (if env.py is /app/alembic)
    pathlib.Path("/app/backend"),
    pathlib.Path("/app"),
}
for p in roots:
    sp = str(p)
    if sp not in sys.path:
        sys.path.append(sp)

from app.db import Base  # type: ignore
from app import models    # type: ignore

target_metadata = Base.metadata

def run_migrations_offline():
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
        future=True,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
        )
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
