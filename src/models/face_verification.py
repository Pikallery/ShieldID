"""FaceVerification ORM model — biometric face matching results."""

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Integer, String, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, UUIDMixin


class FaceVerification(UUIDMixin, Base):
    """
    Stores biometric face matching results between the photo
    embedded in the document and the live selfie uploaded by the user.

    This record is only created when a selfie is provided during
    document submission (documents.selfie_path IS NOT NULL).

    Has a strict 1:1 relationship with Document.
    """

    __tablename__ = "face_verifications"

    # ── Foreign key (1:1) ─────────────────────────────────────────────────
    document_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("documents.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    # ── Document photo detection ───────────────────────────────────────────
    face_detected: Mapped[bool] = mapped_column(Boolean, nullable=False)
    face_confidence: Mapped[float] = mapped_column(Float, nullable=False)

    # ── Selfie detection ──────────────────────────────────────────────────
    selfie_face_detected: Mapped[bool | None] = mapped_column(Boolean, nullable=True)

    # ── Similarity verdict ────────────────────────────────────────────────
    similarity_score: Mapped[float] = mapped_column(Float, nullable=False)
    is_same_person: Mapped[bool] = mapped_column(Boolean, nullable=False, index=True)

    # ── Liveness / anti-spoofing ──────────────────────────────────────────
    liveness_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    liveness_passed: Mapped[bool | None] = mapped_column(Boolean, nullable=True)

    # ── Model metadata ─────────────────────────────────────────────────────
    model_used: Mapped[str] = mapped_column(
        String(100), nullable=False, default="deepface", server_default="deepface"
    )
    processing_time_ms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    # ── Relationship ──────────────────────────────────────────────────────
    document: Mapped["Document"] = relationship(  # type: ignore[name-defined]
        "Document", back_populates="face_verification"
    )

    def __repr__(self) -> str:
        return (
            f"<FaceVerification id={self.id} doc={self.document_id} "
            f"is_same_person={self.is_same_person} sim={self.similarity_score:.2f}>"
        )
