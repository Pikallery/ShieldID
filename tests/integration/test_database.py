from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.database import (
    Base,
    get_db,
    init_db,
)
from src.models.document import Document
from src.models.fraud_report import FraudReport

# ==============================================================================
# 1. ORM Model & Schema Metadata Inspection Tests
# ==============================================================================


def test_document_table_structure():
    """Verify table name, columns, types, and primary key for Document."""
    table = Document.__table__
    assert table.name == "documents"

    # Primary key
    assert table.c.id.primary_key is True

    # Required columns
    assert table.c.document_type.nullable is False
    assert table.c.original_filename.nullable is False
    assert table.c.file_path.nullable is False
    assert table.c.file_hash.nullable is False
    assert table.c.mime_type.nullable is False
    assert table.c.file_size_bytes.nullable is False


def test_document_indexes():
    """Verify essential performance indexes exist on documents table."""
    table = Document.__table__
    index_names = {idx.name for idx in table.indexes}

    assert any("document_type" in name for name in index_names)
    assert any("file_hash" in name for name in index_names)


def test_fraud_report_table_structure():
    """Verify table name, columns, constraints, and types for FraudReport."""
    table = FraudReport.__table__
    assert table.name == "fraud_reports"

    # Primary key
    assert table.c.id.primary_key is True

    # Unique constraint on fir_number
    assert table.c.fir_number.unique is True or any(
        table.c.fir_number in uc.columns
        for uc in table.constraints
        if hasattr(uc, "columns")
    )
    assert table.c.fir_number.nullable is False


def test_fraud_report_indexes():
    """Verify required indexes exist on fraud_reports table."""
    table = FraudReport.__table__
    index_names = {idx.name for idx in table.indexes}

    assert any("fir_number" in name for name in index_names)


# ==============================================================================
# 2. Model Instantiation & Field Assignment Tests
# ==============================================================================


def test_create_document_instance():
    """Test instantiating a Document with complete attributes."""
    doc = Document(
        document_type="passport",
        original_filename="passport.jpg",
        file_path="/uploads/passport.jpg",
        file_hash="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        mime_type="image/jpeg",
        file_size_bytes=102400,
    )

    assert doc.document_type == "passport"
    assert doc.original_filename == "passport.jpg"
    assert doc.file_path == "/uploads/passport.jpg"
    assert doc.file_hash.startswith("e3b0c442")
    assert doc.mime_type == "image/jpeg"
    assert doc.file_size_bytes == 102400


def test_create_fraud_report_instance():
    """Test instantiating a FraudReport with FIR and incident details."""
    report = FraudReport(
        fir_number="FIR-2026-AB12CD",
        description="Tampered Aadhaar card presented for KYC at bank branch",
        assigned_station="Central Police Station",
        report_status="filed",
    )

    assert report.fir_number == "FIR-2026-AB12CD"
    assert report.description.startswith("Tampered Aadhaar")
    assert report.assigned_station == "Central Police Station"
    assert report.report_status == "filed"


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


def test_select_documents_by_type_query():
    """Test SQL query construction for querying documents by type."""
    stmt = select(Document).where(Document.document_type == "passport")
    compiled_sql = str(stmt)
    assert "documents.document_type = :document_type_1" in compiled_sql


def test_select_fraud_reports_by_fir_query():
    """Test SQL query construction for locating an incident report by FIR number."""
    target_fir = "FIR-2026-009988"
    stmt = select(FraudReport).where(FraudReport.fir_number == target_fir)
    compiled_sql = str(stmt)
    assert "fraud_reports.fir_number = :fir_number_1" in compiled_sql
