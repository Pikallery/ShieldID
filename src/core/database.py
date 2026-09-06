# src/core/database.py
# ⚠️ OWNER: Dev 1 (Tech Lead) - DO NOT MODIFY WITHOUT PERMISSION ⚠️

import enum
from datetime import datetime
from typing import Optional

from sqlalchemy import (
    JSON,
    Boolean,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
)
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import Mapped, declarative_base, mapped_column, relationship

from src.core.config import settings

# ---------- ENGINE & SESSION (YOUR CONTROL) ----------
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.MODE == "development",
    pool_size=20,  # Your control
    max_overflow=10,  # Your control
    pool_pre_ping=True,  # Your control
    pool_recycle=3600,  # Your control
)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)
Base = declarative_base()

# ---------- ENUMS (Your Control) ----------
class DocumentTypeEnum(str, enum.Enum):
    PASSPORT = "passport"
    VISA = "visa"
    AADHAAR = "aadhaar"
    PAN = "pan"
    DRIVING_LICENSE = "driving_license"
    VOTER_ID = "voter_id"
    RATION_CARD = "ration_card"

class VerificationStatusEnum(str, enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    VERIFIED = "verified"
    SUSPICIOUS = "suspicious"
    FAKE = "fake"
    REJECTED = "rejected"

class ReportStatusEnum(str, enum.Enum):
    PENDING = "pending"
    UNDER_INVESTIGATION = "under_investigation"
    RESOLVED = "resolved"
    CLOSED = "closed"

class UserRoleEnum(str, enum.Enum):
    CITIZEN = "citizen"
    POLICE = "police"
    BANK = "bank"
    ADMIN = "admin"
    SUPER_ADMIN = "super_admin"

# ---------- TABLES (YOUR DESIGN) ----------

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    phone: Mapped[str] = mapped_column(String(15), unique=True, index=True)
    name: Mapped[str] = mapped_column(String(200))
    role: Mapped[UserRoleEnum] = mapped_column(Enum(UserRoleEnum), default=UserRoleEnum.CITIZEN)
    hashed_password: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    
    # Relationships
    verifications: Mapped[list["VerificationRecord"]] = relationship(back_populates="user")
    reports: Mapped[list["ReportRecord"]] = relationship(back_populates="user")
    
    # Indexes (Your control)
    __table_args__ = (
        Index("idx_user_email_phone", "email", "phone"),
    )

class VerificationRecord(Base):
    __tablename__ = "verifications"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    
    # Document details
    document_type: Mapped[DocumentTypeEnum] = mapped_column(Enum(DocumentTypeEnum))
    document_number: Mapped[str] = mapped_column(String(100), index=True)
    document_hash: Mapped[str] = mapped_column(String(64))  # SHA-256 for deduplication
    
    # Extracted data (full JSON)
    extracted_data: Mapped[dict] = mapped_column(JSON)
    
    # AI Results
    ocr_confidence: Mapped[float] = mapped_column(Float)
    tamper_score: Mapped[float] = mapped_column(Float)
    tamper_details: Mapped[dict] = mapped_column(JSON, nullable=True)
    face_similarity: Mapped[float | None] = mapped_column(Float, nullable=True)
    face_details: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    
    # Overall
    risk_score: Mapped[float] = mapped_column(Float, index=True)
    status: Mapped[VerificationStatusEnum] = mapped_column(Enum(VerificationStatusEnum), default=VerificationStatusEnum.PENDING)
    recommendation: Mapped[str] = mapped_column(String(20))  # APPROVE, REVIEW, REJECT
    
    # Location data
    location_lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_address: Mapped[str | None] = mapped_column(Text, nullable=True)
    
    # Metadata
    device_info: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    ip_address: Mapped[str | None] = mapped_column(String(45), nullable=True)
    user_agent: Mapped[str | None] = mapped_column(Text, nullable=True)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    
    # Relationships
    user: Mapped["User"] = relationship(back_populates="verifications")
    reports: Mapped[list["ReportRecord"]] = relationship(back_populates="verification")
    
    # Indexes (Your control - performance optimized)
    __table_args__ = (
        Index("idx_verification_user_date", "user_id", "created_at"),
        Index("idx_verification_doc_number", "document_number"),
        Index("idx_verification_risk_status", "risk_score", "status"),
        Index("idx_verification_location", "location_lat", "location_lng"),
        Index("idx_verification_doc_hash", "document_hash"),
    )

class ReportRecord(Base):
    __tablename__ = "reports"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    verification_id: Mapped[int | None] = mapped_column(ForeignKey("verifications.id"), nullable=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    
    # Report details
    fir_number: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    document_type: Mapped[DocumentTypeEnum] = mapped_column(Enum(DocumentTypeEnum))
    document_number: Mapped[str] = mapped_column(String(100), index=True)
    
    # Description
    description: Mapped[str] = mapped_column(Text)
    fraud_category: Mapped[str] = mapped_column(String(50))  # photo_replace, text_tamper, stamp_forgery, etc.
    
    # Evidence
    evidence_url: Mapped[str] = mapped_column(Text)
    evidence_hash: Mapped[str] = mapped_column(String(64))
    
    # Reporter details
    reporter_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    reporter_phone: Mapped[str | None] = mapped_column(String(15), nullable=True)
    is_anonymous: Mapped[bool] = mapped_column(Boolean, default=False)
    
    # Location
    location_lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_lng: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_address: Mapped[str | None] = mapped_column(Text, nullable=True)
    
    # Police assignment
    assigned_station: Mapped[str | None] = mapped_column(Text, nullable=True)
    assigned_officer: Mapped[str | None] = mapped_column(String(200), nullable=True)
    status: Mapped[ReportStatusEnum] = mapped_column(Enum(ReportStatusEnum), default=ReportStatusEnum.PENDING)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    
    # Relationships
    user: Mapped["User"] = relationship(back_populates="reports")
    verification: Mapped[Optional["VerificationRecord"]] = relationship(back_populates="reports")
    
    # Indexes (Your control)
    __table_args__ = (
        Index("idx_report_fir", "fir_number"),
        Index("idx_report_status_date", "status", "created_at"),
        Index("idx_report_location", "location_lat", "location_lng"),
    )

class KYCRecord(Base):
    __tablename__ = "kyc_records"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    
    # KYC details
    kyc_token: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    purpose: Mapped[str] = mapped_column(String(50))
    verification_id: Mapped[int] = mapped_column(ForeignKey("verifications.id"))
    
    # Status
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    shared_data: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    
    # Third-party
    third_party_app: Mapped[str | None] = mapped_column(String(100), nullable=True)
    third_party_data: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    
    # Timestamps
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime)  # Token expiry
    
    # Indexes
    __table_args__ = (
        Index("idx_kyc_token", "kyc_token"),
        Index("idx_kyc_user_status", "user_id", "is_completed"),
    )

class HeatmapData(Base):
    __tablename__ = "heatmap_data"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    location_lat: Mapped[float] = mapped_column(Float)
    location_lng: Mapped[float] = mapped_column(Float)
    risk_score: Mapped[float] = mapped_column(Float)
    incident_count: Mapped[int] = mapped_column(Integer, default=1)
    fraud_category: Mapped[str] = mapped_column(String(50))
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)
    
    # Indexes for fast geospatial queries
    __table_args__ = (
        Index("idx_heatmap_location", "location_lat", "location_lng"),
        Index("idx_heatmap_date", "timestamp"),
    )

class BlacklistRecord(Base):
    __tablename__ = "blacklist_records"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    document_number: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    document_type: Mapped[DocumentTypeEnum] = mapped_column(Enum(DocumentTypeEnum))
    reason: Mapped[str] = mapped_column(Text)
    source: Mapped[str] = mapped_column(String(50))  # INTERPOL, RBI, NCRP, etc.
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

# ---------- DATABASE FUNCTIONS (YOUR CONTROL) ----------

async def get_db() -> AsyncSession:
    """Dependency for FastAPI routes"""
    async with AsyncSessionLocal() as session:
        yield session

async def init_db():
    """Initialize database - RUN THIS ONCE"""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("✅ Database initialized successfully")

async def drop_db():
    """⚠️ DANGER: Drops all tables - USE WITH CAUTION"""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    print("⚠️ Database dropped")

async def create_super_admin():
    """Create first super admin user"""
    from src.core.security import get_password_hash
    async with AsyncSessionLocal() as session:
        admin = User(
            email="admin@shieldid.gov.in",
            phone="9999999999",
            name="System Administrator",
            role=UserRoleEnum.SUPER_ADMIN,
            hashed_password=get_password_hash("Admin@2026"),
            is_verified=True
        )
        session.add(admin)
        await session.commit()
        print("✅ Super admin created")

# ---------- MIGRATION CONTROL (YOURS) ----------
# To run migrations:
# 1. Create migration: alembic revision --autogenerate -m "description"
# 2. Apply migration: alembic upgrade head