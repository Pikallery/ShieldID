"""
Alembic async migration environment.

This file is executed by Alembic for both `alembic revision --autogenerate`
and `alembic upgrade head`. It is configured for asyncpg (async driver)
using SQLAlchemy's async engine.

Key design decisions:
    - DATABASE_URL is read from src.core.config.settings (single source of truth)
    - target_metadata is set to Base.metadata so autogenerate works
    - run_migrations_online() uses asyncio.run() with an async engine
"""

import asyncio
from logging.config import fileConfig

from alembic import context
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import create_async_engine

# ── Alembic config object (alembic.ini values) ────────────────────────────────
config = context.config

# ── Logging setup from alembic.ini ────────────────────────────────────────────
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# ── Import all models so Alembic can auto-detect schema changes ───────────────
from src.models.base import Base   # noqa: E402
import src.models                  # noqa: E402, F401 — registers all models

target_metadata = Base.metadata

# ── Read DATABASE_URL from application settings ───────────────────────────────
from src.core.config import settings  # noqa: E402

DATABASE_URL = settings.DATABASE_URL


# ── Offline migrations (generate SQL without connecting) ──────────────────────
def run_migrations_offline() -> None:
    """
    Run migrations in 'offline' mode.

    Generates SQL DDL statements to stdout/file without connecting
    to the database. Useful for previewing or applying via DBA.
    """
    context.configure(
        url=DATABASE_URL,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
        compare_server_default=True,
    )
    with context.begin_transaction():
        context.run_migrations()


# ── Online migrations (connect and apply directly) ────────────────────────────
def do_run_migrations(connection: Connection) -> None:
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,
        compare_server_default=True,
    )
    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    """Create an async engine and run migrations via a sync-compatible wrapper."""
    connectable = create_async_engine(
        DATABASE_URL,
        poolclass=pool.NullPool,  # No pooling during migrations
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode (connects to the database)."""
    asyncio.run(run_async_migrations())


# ── Entry point ───────────────────────────────────────────────────────────────
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
