"""KYCSession ORM model — tracks DigiLocker-style KYC token lifecycle."""

import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import Boolean, DateTime, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, TimestampMixin, UUIDMixin

if TYPE_CHECKING:
    from src.models.document import Document
    from src.models.user import User


class KYCSession(UUIDMixin, TimestampMixin, Base):
    """
    Tracks an instant KYC session from token issuance to completion.

    Flow:
        1. User initiates KYC (POST /api/v1/kyc/instant)
        2. A KYCSession is created with status='pending' and a unique kyc_token
        3. User is redirected to DigiLocker (or scans QR code)
        4. On consent, document is linked (document_id populated)
        5. Session status is updated to 'verified' or 'rejected'
        6. Session expires after expires_at timestamp

    status values:
        - pending   : Token issued, waiting for user consent
        - verified  : KYC complete, identity confirmed
        - rejected  : KYC failed (document rejected or consent denied)
        - expired   : Token TTL passed without completion
    """

    __tablename__ = "kyc_sessions"

    # ── Owner (nullable: session may be created before user is known) ──────
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )

    # ── Linked document (populated after document upload) ─────────────────
    document_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("documents.id", ondelete="SET NULL"),
        nullable=True,
        unique=True,
    )

    # ── Token fields ──────────────────────────────────────────────────────
    kyc_token: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=False, index=True
    )
    qr_code_url: Mapped[str] = mapped_column(Text, nullable=False)

    # ── Session context ───────────────────────────────────────────────────
    purpose: Mapped[str] = mapped_column(String(100), nullable=False)
    return_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    digilocker_redirect: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Consent ───────────────────────────────────────────────────────────
    consent_given: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default="false"
    )
    consent_timestamp: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # ── Lifecycle ─────────────────────────────────────────────────────────
    status: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="pending",
        server_default="pending",
        index=True,
    )
    expires_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )

    # ── Relationships ─────────────────────────────────────────────────────
    user: Mapped["User | None"] = relationship(  # type: ignore[name-defined]
        "User", back_populates="kyc_sessions"
    )
    document: Mapped["Document | None"] = relationship(  # type: ignore[name-defined]
        "Document", back_populates="kyc_session"
    )

    def __repr__(self) -> str:
        return (
            f"<KYCSession id={self.id} token={self.kyc_token} "
            f"status={self.status} purpose={self.purpose}>"
        )
