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
    import src.models  # noqa: F401 — ensures all models are registered
    from src.models.base import Base

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def dispose_engine() -> None:
    """Cleanly dispose of the engine connection pool on shutdown."""
    await engine.dispose()
# src/core/database.py
from datetime import datetime

from sqlalchemy import DateTime, Float, Index, String, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine
from sqlalchemy.orm import Mapped, declarative_base, mapped_column

from src.core.config import settings

engine = create_async_engine(settings.DATABASE_URL, echo=settings.MODE == "development")
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)
Base = declarative_base()

class VerificationRecord(Base):
    __tablename__ = "verifications"
    __table_args__ = (
        Index("idx_verifications_status", "status"),
        Index("idx_verifications_risk", "risk_score"),
        Index("idx_verifications_timestamp", "timestamp"),
        Index("idx_verifications_doc_number", "document_number"),
    )
    
    id: Mapped[int] = mapped_column(primary_key=True)
    document_type: Mapped[str] = mapped_column(String(50), nullable=False)
    document_number: Mapped[str] = mapped_column(String(50), nullable=False)
    risk_score: Mapped[float] = mapped_column(Float, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="pending", server_default="pending", nullable=False)
    location_lat: Mapped[float] = mapped_column(Float, nullable=True)
    location_lng: Mapped[float] = mapped_column(Float, nullable=True)
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, server_default=func.now(), nullable=True)
    extracted_data: Mapped[dict] = mapped_column(JSONB, nullable=False)
    tamper_result: Mapped[dict] = mapped_column(JSONB, nullable=True)

class ReportRecord(Base):
    __tablename__ = "reports"
    __table_args__ = (
        Index("idx_reports_fir", "fir_number"),
        Index("idx_reports_status", "status"),
        Index("idx_reports_timestamp", "timestamp"),
    )
    
    id: Mapped[int] = mapped_column(primary_key=True)
    fir_number: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    document_type: Mapped[str] = mapped_column(String(50), nullable=False)
    description: Mapped[str] = mapped_column(String(500), nullable=False)
    reporter_name: Mapped[str] = mapped_column(String(100), nullable=True)
    reporter_phone: Mapped[str] = mapped_column(String(15), nullable=True)
    location_lat: Mapped[float] = mapped_column(Float, nullable=True)
    location_lng: Mapped[float] = mapped_column(Float, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="pending", server_default="pending", nullable=True)
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, server_default=func.now(), nullable=True)

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
