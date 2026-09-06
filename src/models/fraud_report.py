"""FraudReport ORM model — fraudulent document reports and FIR dispatch records."""

import uuid
from decimal import Decimal
from typing import TYPE_CHECKING

from sqlalchemy import ForeignKey, Numeric, String, Text
from sqlalchemy.dialects.postgresql import INET, JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.models.base import Base, TimestampMixin, UUIDMixin

if TYPE_CHECKING:
    from src.models.document import Document
    from src.models.screening_result import ScreeningResult
    from src.models.user import User


class FraudReport(UUIDMixin, TimestampMixin, Base):
    """
    A record of a reported fake/fraudulent document submission.

    Can be:
        - Filed manually by a user (POST /api/v1/report/fake)
        - Auto-triggered when a ScreeningResult recommendation is REJECT

    report_status values:
        - filed               : Initial state — FIR number assigned
        - under_investigation : Police station has taken it up
        - closed              : Case resolved
    """

    __tablename__ = "fraud_reports"

    # ── Links to related records ──────────────────────────────────────────
    document_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("documents.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    reported_by_user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )
    screening_result_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("screening_results.id", ondelete="SET NULL"),
        nullable=True,
    )

    # ── FIR details ───────────────────────────────────────────────────────
    fir_number: Mapped[str] = mapped_column(
        String(100), unique=True, nullable=False, index=True
    )
    description: Mapped[str | None] = mapped_column(Text, nullable=True)

    # ── Geo-location ──────────────────────────────────────────────────────
    latitude: Mapped[Decimal | None] = mapped_column(
        Numeric(9, 6), nullable=True
    )
    longitude: Mapped[Decimal | None] = mapped_column(
        Numeric(9, 6), nullable=True
    )
    assigned_station: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # ── Status ────────────────────────────────────────────────────────────
    report_status: Mapped[str] = mapped_column(
        String(50),
        nullable=False,
        default="filed",
        server_default="filed",
        index=True,
    )

    # ── Evidence ──────────────────────────────────────────────────────────
    evidence_paths: Mapped[list | None] = mapped_column(JSONB, nullable=True)
    reporter_ip: Mapped[str | None] = mapped_column(INET, nullable=True)

    # ── Relationships ─────────────────────────────────────────────────────
    document: Mapped["Document | None"] = relationship(  # type: ignore[name-defined]
        "Document", back_populates="fraud_reports"
    )
    reported_by_user: Mapped["User | None"] = relationship(  # type: ignore[name-defined]
        "User",
        back_populates="fraud_reports",
        foreign_keys=[reported_by_user_id],
    )
    screening_result: Mapped["ScreeningResult | None"] = relationship(  # type: ignore[name-defined]
        "ScreeningResult", back_populates="fraud_reports"
    )

    def __repr__(self) -> str:
        return (
            f"<FraudReport id={self.id} fir={self.fir_number} "
            f"status={self.report_status}>"
        )
