"""
Async database engine, session factory, and FastAPI dependency.

Usage in route handlers:
    from src.core.database import get_db
    from sqlalchemy.ext.asyncio import AsyncSession

    @router.get("/items")
    async def list_items(db: AsyncSession = Depends(get_db)):
        result = await db.execute(select(Item))
        return result.scalars().all()
"""

from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from src.core.config import settings

# ── Engine ────────────────────────────────────────────────────────────────────
# echo=True logs all SQL statements in development. Set to False in production.
engine: AsyncEngine = create_async_engine(
    settings.DATABASE_URL,
    echo=(settings.MODE == "development"),
    pool_pre_ping=True,   # Verify connection before checkout
    pool_size=10,         # Max persistent connections
    max_overflow=20,      # Extra connections allowed under burst load
    pool_recycle=3600,    # Recycle connections after 1 hour
)

# ── Session factory ───────────────────────────────────────────────────────────
AsyncSessionLocal: async_sessionmaker[AsyncSession] = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,  # Keep model attrs accessible after commit
    autocommit=False,
    autoflush=False,
)


# ── FastAPI Dependency ────────────────────────────────────────────────────────
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Yield an async database session per request.

    Automatically commits on success, rolls back on exception,
    and always closes the session when the request is done.

    Inject with:  db: AsyncSession = Depends(get_db)
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


# ── Lifecycle helpers (called from main.py lifespan) ─────────────────────────
async def create_db_tables() -> None:
    """
    Create all tables that don't exist yet.

    NOTE: In production, use Alembic migrations instead.
    This is a convenience helper for development / testing.
    """
    from src.models.base import Base  # noqa: F401 — imports all model metadata
    import src.models  # noqa: F401 — ensures all models are registered

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def dispose_engine() -> None:
    """Cleanly dispose of the engine connection pool on shutdown."""
    await engine.dispose()
