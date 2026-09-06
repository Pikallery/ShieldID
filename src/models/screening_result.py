"""ScreeningResult ORM model — final aggregated risk score and recommendation."""

import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, Float, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, TimestampMixin, UUIDMixin

if TYPE_CHECKING:
    from src.models.document import Document
    from src.models.fraud_report import FraudReport
    from src.models.user import User


class ScreeningResult(UUIDMixin, TimestampMixin, Base):
    """
    Final aggregated screening verdict for a document submission.

    Combines sub-scores from OCR analysis, tampering detection, and
    face verification into a composite risk score and a recommendation.

    recommendation values:
        - APPROVE         : Low risk, document appears authentic
        - REVIEW_MANUALLY : Medium risk, requires human review
        - REJECT          : High risk, document likely fraudulent

    final_status values (post human-review if applicable):
        - pending   : Awaiting automated or manual decision
        - approved  : Cleared
        - flagged   : Sent for manual review
        - rejected  : Marked as fraudulent/invalid
    """

    __tablename__ = "screening_results"

    # ── Foreign key (1:1) ─────────────────────────────────────────────────
    document_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("documents.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    # ── Composite risk scores ─────────────────────────────────────────────
    overall_risk: Mapped[float] = mapped_column(Float, nullable=False, index=True)
    ocr_risk: Mapped[float] = mapped_column(Float, nullable=False)
    tamper_risk: Mapped[float] = mapped_column(Float, nullable=False)
    face_risk: Mapped[float] = mapped_column(Float, nullable=False)

    # ── AI recommendation ─────────────────────────────────────────────────
    recommendation: Mapped[str] = mapped_column(
        String(50), nullable=False, index=True
    )  # APPROVE | REVIEW_MANUALLY | REJECT

    # ── Final status (may differ from AI recommendation after human review) ─
    final_status: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="pending",
        server_default="pending",
        index=True,
    )

    # ── Human review (optional) ───────────────────────────────────────────
    reviewed_by_user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    reviewed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    reviewer_notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Relationships ─────────────────────────────────────────────────────
    document: Mapped["Document"] = relationship(  # type: ignore[name-defined]
        "Document", back_populates="screening_result"
    )
    reviewed_by_user: Mapped["User | None"] = relationship(  # type: ignore[name-defined]
        "User", back_populates="reviewed_screenings"
    )
    fraud_reports: Mapped[list["FraudReport"]] = relationship(  # type: ignore[name-defined]
        "FraudReport", back_populates="screening_result", lazy="noload"
    )

    def __repr__(self) -> str:
        return (
            f"<ScreeningResult id={self.id} doc={self.document_id} "
            f"risk={self.overall_risk:.1f} rec={self.recommendation}>"
        )
