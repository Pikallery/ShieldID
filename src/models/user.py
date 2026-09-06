"""User ORM model — platform operators, agents, and end-users."""

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, TimestampMixin, UUIDMixin


class User(UUIDMixin, TimestampMixin, Base):
    """
    Represents a ShieldID platform user.

    Roles:
        - admin    : Full platform access
        - operator : Can view verification results, file reports
        - user     : End-user submitting documents for KYC
    """

    __tablename__ = "users"

    email: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=False, index=True
    )
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(
        String(50), nullable=False, default="user", server_default="user"
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True, server_default="true"
    )
    is_verified: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default="false"
    )
    last_login_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # ── Relationships ─────────────────────────────────────────────────────────
    documents: Mapped[list["Document"]] = relationship(  # type: ignore[name-defined]
        "Document", back_populates="user", lazy="noload"
    )
    kyc_sessions: Mapped[list["KYCSession"]] = relationship(  # type: ignore[name-defined]
        "KYCSession", back_populates="user", lazy="noload"
    )
    fraud_reports: Mapped[list["FraudReport"]] = relationship(  # type: ignore[name-defined]
        "FraudReport", back_populates="reported_by_user", lazy="noload",
        foreign_keys="FraudReport.reported_by_user_id",
    )
    audit_logs: Mapped[list["AuditLog"]] = relationship(  # type: ignore[name-defined]
        "AuditLog", back_populates="actor_user", lazy="noload"
    )
    reviewed_screenings: Mapped[list["ScreeningResult"]] = relationship(  # type: ignore[name-defined]
        "ScreeningResult", back_populates="reviewed_by_user", lazy="noload"
    )

    def __repr__(self) -> str:
        return f"<User id={self.id} email={self.email} role={self.role}>"
