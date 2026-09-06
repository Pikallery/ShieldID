from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.database import (
    Base,
    ReportRecord,
    VerificationRecord,
    get_db,
    init_db,
)


# ==============================================================================
# 1. ORM Model & Schema Metadata Inspection Tests
# ==============================================================================

def test_verification_record_table_structure():
    """Verify table name, columns, types, and primary key for VerificationRecord."""
    table = VerificationRecord.__table__
    assert table.name == "verifications"

    # Primary key
    assert table.c.id.primary_key is True

    # Required columns
    assert table.c.document_type.nullable is False
    assert table.c.document_number.nullable is False
    assert table.c.risk_score.nullable is False
    assert table.c.extracted_data.nullable is False

    # Optional / defaulted columns
    assert table.c.status.default is not None or table.c.status.server_default is not None
    assert table.c.location_lat.nullable is True
    assert table.c.location_lng.nullable is True
    assert table.c.tamper_result.nullable is True


def test_verification_record_indexes():
    """Verify essential performance indexes exist on verifications table."""
    table = VerificationRecord.__table__
    index_names = {idx.name for idx in table.indexes}

    assert "idx_verifications_status" in index_names
    assert "idx_verifications_risk" in index_names
    assert "idx_verifications_timestamp" in index_names
    assert "idx_verifications_doc_number" in index_names


def test_report_record_table_structure():
    """Verify table name, columns, constraints, and types for ReportRecord."""
    table = ReportRecord.__table__
    assert table.name == "reports"

    # Primary key
    assert table.c.id.primary_key is True

    # Unique constraint on fir_number
    assert table.c.fir_number.unique is True or any(
        table.c.fir_number in uc.columns for uc in table.constraints if hasattr(uc, "columns")
    )
    assert table.c.fir_number.nullable is False

    # Required fields
    assert table.c.document_type.nullable is False
    assert table.c.description.nullable is False

    # Optional fields
    assert table.c.reporter_name.nullable is True
    assert table.c.reporter_phone.nullable is True
    assert table.c.location_lat.nullable is True
    assert table.c.location_lng.nullable is True


def test_report_record_indexes():
    """Verify required indexes exist on reports table."""
    table = ReportRecord.__table__
    index_names = {idx.name for idx in table.indexes}

    assert "idx_reports_fir" in index_names
    assert "idx_reports_status" in index_names
    assert "idx_reports_timestamp" in index_names


# ==============================================================================
# 2. Model Instantiation & Field Assignment Tests
# ==============================================================================

def test_create_verification_record_instance():
    """Test instantiating a VerificationRecord with complete attributes."""
    extracted_info = {
        "name": "Rahul Sharma",
        "passport_number": "Z1234567",
        "nationality": "Indian",
        "dob": "1990-01-15",
    }
    tamper_info = {
        "is_tampered": False,
        "tamper_score": 0.05,
        "regions": [],
    }

    record = VerificationRecord(
        document_type="passport",
        document_number="Z1234567",
        risk_score=15.5,
        status="verified",
        location_lat=28.6139,
        location_lng=77.2090,
        extracted_data=extracted_info,
        tamper_result=tamper_info,
    )

    assert record.document_type == "passport"
    assert record.document_number == "Z1234567"
    assert record.risk_score == 15.5
    assert record.status == "verified"
    assert record.location_lat == 28.6139
    assert record.location_lng == 77.2090
    assert record.extracted_data["name"] == "Rahul Sharma"
    assert record.tamper_result["is_tampered"] is False


def test_create_report_record_instance():
    """Test instantiating a ReportRecord with FIR and incident details."""
    report = ReportRecord(
        fir_number="FIR-2026-AB12CD",
        document_type="aadhaar",
        description="Tampered Aadhaar card presented for KYC at bank branch",
        reporter_name="Inspector S. Verma",
        reporter_phone="9876543210",
        location_lat=19.0760,
        location_lng=72.8777,
        status="pending",
    )

    assert report.fir_number == "FIR-2026-AB12CD"
    assert report.document_type == "aadhaar"
    assert report.description.startswith("Tampered Aadhaar")
    assert report.reporter_name == "Inspector S. Verma"
    assert report.reporter_phone == "9876543210"
    assert report.location_lat == 19.0760
    assert report.location_lng == 72.8777
    assert report.status == "pending"


# ==============================================================================
# 3. Async Database Session & Dependency Tests
# ==============================================================================

@pytest.mark.asyncio
async def test_get_db_session_yields_async_session():
    """Verify get_db dependency yields an active AsyncSession context."""
    mock_session = AsyncMock(spec=AsyncSession)
    mock_session_maker = MagicMock()
    mock_session_maker.return_value.__aenter__.return_value = mock_session

    with patch("src.core.database.AsyncSessionLocal", mock_session_maker):
        generator = get_db()
        session = await generator.__anext__()
        assert session == mock_session

        # Finish generator to test cleanup
        try:
            await generator.__anext__()
        except StopAsyncIteration:
            pass


@pytest.mark.asyncio
async def test_init_db_executes_create_all():
    """Verify init_db invokes Base.metadata.create_all on engine."""
    mock_conn = AsyncMock()
    mock_engine = MagicMock()
    mock_engine.begin.return_value.__aenter__.return_value = mock_conn

    with patch("src.core.database.engine", mock_engine):
        await init_db()
        mock_conn.run_sync.assert_called_once_with(Base.metadata.create_all)


# ==============================================================================
# 4. Query Construction & Filter Logic Tests
# ==============================================================================

def test_select_verifications_by_status_query():
    """Test SQL query construction for querying verifications by status."""
    stmt = select(VerificationRecord).where(VerificationRecord.status == "verified")
    compiled_sql = str(stmt)
    assert "verifications.status = :status_1" in compiled_sql


def test_select_verifications_by_risk_score_query():
    """Test SQL query construction for filtering high-risk verifications."""
    threshold = 50.0
    stmt = select(VerificationRecord).where(VerificationRecord.risk_score >= threshold)
    compiled_sql = str(stmt)
    assert "verifications.risk_score >=" in compiled_sql


def test_select_reports_by_fir_number_query():
    """Test SQL query construction for locating an incident report by FIR number."""
    target_fir = "FIR-2026-009988"
    stmt = select(ReportRecord).where(ReportRecord.fir_number == target_fir)
    compiled_sql = str(stmt)
    assert "reports.fir_number = :fir_number_1" in compiled_sql
