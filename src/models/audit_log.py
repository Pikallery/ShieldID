"""AuditLog ORM model — immutable, append-only compliance event trail."""

import uuid
from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, String, Text, func
from sqlalchemy.dialects.postgresql import INET, JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base


class AuditLog(Base):
    """
    Immutable compliance and traceability event log.

    Every significant action in ShieldID generates one audit log entry.
    This table is append-only — no UPDATE or DELETE operations should
    ever be issued against it.

    Uses BIGSERIAL (integer sequence) as PK instead of UUID because:
        - Audit logs are high-volume (one per API action)
        - Sequential integer PKs are more efficient for high-insert tables
        - Natural chronological ordering without a separate index

    Common action values:
        - user_registered
        - user_login
        - document_uploaded
        - ocr_completed
        - tampering_analysis_completed
        - face_verification_completed
        - screening_completed
        - kyc_initiated
        - kyc_verified
        - fraud_report_filed
        - manual_review_started
        - manual_review_completed

    resource_type values:
        document | user | kyc_session | fraud_report | screening_result
    """

    __tablename__ = "audit_logs"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)

    # ── Actor ─────────────────────────────────────────────────────────────
    actor_user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )

    # ── Action ────────────────────────────────────────────────────────────
    action: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    resource_type: Mapped[str] = mapped_column(
        String(50), nullable=False, index=True
    )
    resource_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), nullable=True, index=True
    )

    # ── Request context ───────────────────────────────────────────────────
    ip_address: Mapped[str | None] = mapped_column(INET, nullable=True)
    user_agent: Mapped[str | None] = mapped_column(Text, nullable=True)
    request_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), nullable=True
    )

    # ── Structured detail payload ─────────────────────────────────────────
    details: Mapped[dict | None] = mapped_column(JSONB, nullable=True)

    # ── Timestamp (set once at insert — never updated) ─────────────────────
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    # ── Relationship ──────────────────────────────────────────────────────
    actor_user: Mapped["User | None"] = relationship(  # type: ignore[name-defined]
        "User", back_populates="audit_logs"
    )

    def __repr__(self) -> str:
        return (
            f"<AuditLog id={self.id} action={self.action} "
            f"resource={self.resource_type}:{self.resource_id}>"
        )
