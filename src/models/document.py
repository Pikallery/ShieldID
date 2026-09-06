"""Document ORM model — central hub for each uploaded document submission."""

import uuid
from typing import TYPE_CHECKING

from sqlalchemy import BigInteger, ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import INET, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, TimestampMixin, UUIDMixin

if TYPE_CHECKING:
    from src.models.audit_log import AuditLog
    from src.models.face_verification import FaceVerification
    from src.models.fraud_report import FraudReport
    from src.models.kyc_session import KYCSession
    from src.models.ocr_result import OCRResult
    from src.models.screening_result import ScreeningResult
    from src.models.tampering_analysis import TamperingAnalysis
    from src.models.user import User


class Document(UUIDMixin, TimestampMixin, Base):
    """
    One record per document upload submission.

    Acts as the central hub that all AI analysis tables (OCR, tampering,
    face verification, screening) reference via a 1:1 foreign key.

    document_type values (from DocumentType enum in schemas):
        passport | visa | aadhaar | pan | driving_license | voter_id
    """

    __tablename__ = "documents"

    # ── Owner (nullable: anonymous submissions allowed) ────────────────────
    user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )

    # ── Document metadata ─────────────────────────────────────────────────
    document_type: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    original_filename: Mapped[str] = mapped_column(String(255), nullable=False)
    file_path: Mapped[str] = mapped_column(Text, nullable=False)
    file_hash: Mapped[str] = mapped_column(
        String(64), nullable=False, index=True
    )  # SHA-256 for deduplication
    mime_type: Mapped[str] = mapped_column(String(100), nullable=False)
    file_size_bytes: Mapped[int] = mapped_column(BigInteger, nullable=False)

    # ── Optional selfie for face verification ─────────────────────────────
    selfie_path: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Submission context ─────────────────────────────────────────────────
    submission_ip: Mapped[str | None] = mapped_column(INET, nullable=True)
    submission_purpose: Mapped[str | None] = mapped_column(
        String(100), nullable=True
    )  # bank | hotel | airport | etc.

    # ── Processing status ─────────────────────────────────────────────────
    status: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="pending",
        server_default="pending",
        index=True,
    )  # pending | processing | completed | failed

    # ── Relationships ─────────────────────────────────────────────────────
    user: Mapped["User"] = relationship(  # type: ignore[name-defined]
        "User", back_populates="documents"
    )
    ocr_result: Mapped["OCRResult | None"] = relationship(  # type: ignore[name-defined]
        "OCRResult", back_populates="document", uselist=False, lazy="noload"
    )
    tampering_analysis: Mapped["TamperingAnalysis | None"] = relationship(  # type: ignore[name-defined]
        "TamperingAnalysis", back_populates="document", uselist=False, lazy="noload"
    )
    face_verification: Mapped["FaceVerification | None"] = relationship(  # type: ignore[name-defined]
        "FaceVerification", back_populates="document", uselist=False, lazy="noload"
    )
    screening_result: Mapped["ScreeningResult | None"] = relationship(  # type: ignore[name-defined]
        "ScreeningResult", back_populates="document", uselist=False, lazy="noload"
    )
    kyc_session: Mapped["KYCSession | None"] = relationship(  # type: ignore[name-defined]
        "KYCSession", back_populates="document", uselist=False, lazy="noload"
    )
    fraud_reports: Mapped[list["FraudReport"]] = relationship(  # type: ignore[name-defined]
        "FraudReport", back_populates="document", lazy="noload"
    )
    audit_logs: Mapped[list["AuditLog"]] = relationship(  # type: ignore[name-defined]
        "AuditLog",
        primaryjoin="and_(AuditLog.resource_type=='document', foreign(AuditLog.resource_id)==Document.id)",
        lazy="noload",
        viewonly=True,
    )

    def __repr__(self) -> str:
        return f"<Document id={self.id} type={self.document_type} status={self.status}>"
