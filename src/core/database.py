# src/core/database.py
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker
from sqlalchemy.orm import declarative_base, Mapped, mapped_column
from sqlalchemy import String, Integer, Float, DateTime, func, Index
from sqlalchemy.dialects.postgresql import JSONB
from datetime import datetime
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

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)