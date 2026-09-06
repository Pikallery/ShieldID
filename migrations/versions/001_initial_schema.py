# migrations/versions/001_initial_schema.py
# ⚠️ OWNER: Dev 1 - Initial database migration ⚠️
"""initial_schema

Revision ID: 001
Revises: None
Create Date: 2026-09-05
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ---------- VERIFICATIONS TABLE ----------
    op.create_table(
        "verifications",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("document_type", sa.String(50), nullable=False),
        sa.Column("document_number", sa.String(50), nullable=False),
        sa.Column("risk_score", sa.Float(), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("location_lat", sa.Float(), nullable=True),
        sa.Column("location_lng", sa.Float(), nullable=True),
        sa.Column("timestamp", sa.DateTime(), server_default=sa.func.now()),
        sa.Column("extracted_data", sa.dialects.postgresql.JSONB(), nullable=False),
        sa.Column("tamper_result", sa.dialects.postgresql.JSONB(), nullable=True),
    )

    # ---------- REPORTS TABLE ----------
    op.create_table(
        "reports",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("fir_number", sa.String(50), unique=True, nullable=False),
        sa.Column("document_type", sa.String(50), nullable=False),
        sa.Column("description", sa.String(500), nullable=False),
        sa.Column("reporter_name", sa.String(100), nullable=True),
        sa.Column("reporter_phone", sa.String(15), nullable=True),
        sa.Column("location_lat", sa.Float(), nullable=True),
        sa.Column("location_lng", sa.Float(), nullable=True),
        sa.Column("status", sa.String(20), server_default="pending"),
        sa.Column("timestamp", sa.DateTime(), server_default=sa.func.now()),
    )

    # ---------- INDEXES ----------
    op.create_index("idx_verifications_status", "verifications", ["status"])
    op.create_index("idx_verifications_risk", "verifications", ["risk_score"])
    op.create_index("idx_verifications_timestamp", "verifications", ["timestamp"])
    op.create_index("idx_verifications_doc_number", "verifications", ["document_number"])
    op.create_index("idx_reports_fir", "reports", ["fir_number"])
    op.create_index("idx_reports_status", "reports", ["status"])
    op.create_index("idx_reports_timestamp", "reports", ["timestamp"])


def downgrade() -> None:
    op.drop_index("idx_reports_timestamp")
    op.drop_index("idx_reports_status")
    op.drop_index("idx_reports_fir")
    op.drop_index("idx_verifications_doc_number")
    op.drop_index("idx_verifications_timestamp")
    op.drop_index("idx_verifications_risk")
    op.drop_index("idx_verifications_status")
    op.drop_table("reports")
    op.drop_table("verifications")
