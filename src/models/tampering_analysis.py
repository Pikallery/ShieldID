"""TamperingAnalysis ORM model — AI forgery and tampering detection results."""

import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Integer, String, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, UUIDMixin

if TYPE_CHECKING:
    from src.models.document import Document


class TamperingAnalysis(UUIDMixin, Base):
    """
    Stores results of AI-based document tampering detection.

    Has a strict 1:1 relationship with Document.

    Detection methods:
        - ela_analysis  : Error Level Analysis
        - neural_cnn    : Convolutional Neural Network
        - hybrid        : Combination of ELA + CNN

    tampering_regions is a JSONB array of region labels,
    e.g. ["photo_area", "signature_block", "mrz_zone"].
    """

    __tablename__ = "tampering_analyses"

    # ── Foreign key (1:1) ─────────────────────────────────────────────────
    document_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("documents.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    # ── Primary verdict ───────────────────────────────────────────────────
    is_tampered: Mapped[bool] = mapped_column(Boolean, nullable=False, index=True)
    tamper_score: Mapped[float] = mapped_column(Float, nullable=False)
    detection_method: Mapped[str] = mapped_column(String(100), nullable=False)

    # ── Affected regions ──────────────────────────────────────────────────
    tampering_regions: Mapped[list] = mapped_column(
        JSONB, nullable=False, default=list, server_default="[]"
    )

    # ── Sub-scores per tampering category ─────────────────────────────────
    ela_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    copy_move_detected: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    photo_swap_detected: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    text_alteration_detected: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    stamp_forgery_detected: Mapped[bool | None] = mapped_column(Boolean, nullable=True)

    # ── Full model output (for auditability) ──────────────────────────────
    raw_analysis_json: Mapped[dict | None] = mapped_column(JSONB, nullable=True)

    # ── Processing metadata ────────────────────────────────────────────────
    processing_time_ms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    # ── Relationship ──────────────────────────────────────────────────────
    document: Mapped["Document"] = relationship(  # type: ignore[name-defined]
        "Document", back_populates="tampering_analysis"
    )

    def __repr__(self) -> str:
        return (
            f"<TamperingAnalysis id={self.id} doc={self.document_id} "
            f"is_tampered={self.is_tampered} score={self.tamper_score:.2f}>"
        )
