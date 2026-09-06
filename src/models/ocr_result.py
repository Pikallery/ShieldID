"""OCRResult ORM model — stores text extraction output from document images."""

import uuid
from datetime import date
from typing import TYPE_CHECKING

from sqlalchemy import Date, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, UUIDMixin

if TYPE_CHECKING:
    from src.models.document import Document


class OCRResult(UUIDMixin, Base):
    """
    Stores the output of OCR processing on a document image.

    Has a strict 1:1 relationship with Document. One document
    produces exactly one OCR result record.

    The `extracted_data_json` JSONB column stores the full structured
    extraction (all fields) for flexibility, while the individual
    columns like `extracted_name`, `extracted_doc_number` etc. are
    indexed copies of the most frequently queried fields.
    """

    __tablename__ = "ocr_results"

    # ── Foreign key (1:1) ─────────────────────────────────────────────────
    document_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("documents.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    # ── Raw output ────────────────────────────────────────────────────────
    raw_text: Mapped[str] = mapped_column(Text, nullable=False)
    confidence_score: Mapped[float] = mapped_column(Float, nullable=False)

    # ── Parsed fields (indexed for querying) ──────────────────────────────
    extracted_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    extracted_dob: Mapped[date | None] = mapped_column(Date, nullable=True)
    extracted_doc_number: Mapped[str | None] = mapped_column(
        String(100), nullable=True, index=True
    )
    extracted_expiry_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    extracted_nationality: Mapped[str | None] = mapped_column(
        String(100), nullable=True
    )
    extracted_gender: Mapped[str | None] = mapped_column(String(20), nullable=True)

    # ── Full structured extraction (flexible JSON) ─────────────────────────
    extracted_data_json: Mapped[dict | None] = mapped_column(JSONB, nullable=True)

    # ── Processing metadata ────────────────────────────────────────────────
    ocr_engine: Mapped[str] = mapped_column(
        String(50), nullable=False, default="easyocr", server_default="easyocr"
    )
    processing_time_ms: Mapped[int | None] = mapped_column(Integer, nullable=True)

    # ── Timestamp ─────────────────────────────────────────────────────────
    from datetime import datetime

    from sqlalchemy import DateTime
    from sqlalchemy import func as _func
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=_func.now()
    )

    # ── Relationship ──────────────────────────────────────────────────────
    document: Mapped["Document"] = relationship(  # type: ignore[name-defined]
        "Document", back_populates="ocr_result"
    )

    def __repr__(self) -> str:
        return (
            f"<OCRResult id={self.id} doc={self.document_id} "
            f"confidence={self.confidence_score:.2f}>"
        )
