import io
from datetime import date

import pytest
from fastapi.testclient import TestClient

from src.main import app
from src.schemas import (
    AadhaarData,
    KYCRequest,
    PANData,
    PassportData,
)


@pytest.fixture
def client():
    """FastAPI TestClient fixture."""
    return TestClient(app)


@pytest.fixture
def sample_passport_data():
    return PassportData(
        name="Rahul Sharma",
        passport_number="Z1234567",
        nationality="Indian",
        date_of_birth=date(1990, 1, 15),
        date_of_expiry=date(2030, 1, 14),
        gender="M",
    )


@pytest.fixture
def sample_aadhaar_data():
    return AadhaarData(
        name="Priya Patel",
        aadhaar_number="1234 5678 9012",
        date_of_birth=date(1995, 5, 20),
        gender="F",
    )


@pytest.fixture
def sample_pan_data():
    return PANData(
        name="Amit Kumar",
        pan_number="ABCDE1234F",
        date_of_birth=date(1988, 12, 10),
    )


@pytest.fixture
def sample_kyc_request():
    return KYCRequest(
        purpose="bank_account_opening",
        return_url="https://example.com/callback",
        consent=True,
    )


@pytest.fixture
def dummy_file_payload():
    """Generates a tuple suitable for FastAPI UploadFile testing."""
    file_bytes = b"Fake document content for testing"
    return ("test_document.pdf", io.BytesIO(file_bytes), "application/pdf")


@pytest.fixture
def dummy_image_payload():
    """Generates a tuple suitable for selfie/image testing."""
    image_bytes = b"Fake image content for testing"
    return ("selfie.jpg", io.BytesIO(image_bytes), "image/jpeg")
