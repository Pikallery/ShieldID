import io
import pytest
from fastapi.testclient import TestClient

from src.main import app


@pytest.fixture
def client():
    """FastAPI TestClient fixture for integration testing."""
    return TestClient(app)


# ==============================================================================
# 1. System Liveness & Operational Endpoints
# ==============================================================================

def test_root_endpoint_integration(client):
    """Test GET / returns service information and active API docs route."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "ShieldID"
    assert data["version"] == "1.0.0"
    assert data["status"] == "operational"
    assert "docs" in data


def test_health_check_endpoint_integration(client):
    """Test GET /health returns healthy status for container probes."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_openapi_schema_generation(client):
    """Test OpenAPI schema JSON is available and contains registered endpoints."""
    response = client.get("/openapi.json")
    assert response.status_code == 200
    schema = response.json()
    assert schema["info"]["title"] == "ShieldID API"
    assert "/api/v1/verify/document" in schema["paths"]
    assert "/api/v1/kyc/instant" in schema["paths"]
    assert "/api/v1/report/fake" in schema["paths"]


# ==============================================================================
# 2. Document Verification Integration Flow
# ==============================================================================

def test_verify_document_pdf_upload(client):
    """Test POST /api/v1/verify/document with PDF file upload."""
    pdf_content = b"%PDF-1.4 Mock Indian Passport Document Stream"
    files = {"document": ("passport.pdf", io.BytesIO(pdf_content), "application/pdf")}

    response = client.post("/api/v1/verify/document", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "verified"
    assert data["risk_score"] == 15
    assert data["document_type"] == "passport"
    assert data["name"] == "Rahul Sharma"
    assert data["recommendation"] == "APPROVE"


def test_verify_document_jpeg_with_selfie(client):
    """Test POST /api/v1/verify/document with both document and selfie images."""
    doc_bytes = b"\xff\xd8\xff\xe0Mock Aadhaar Card Image Stream"
    selfie_bytes = b"\xff\xd8\xff\xe0Mock Selfie Photo Stream"

    files = [
        ("document", ("aadhaar.jpg", io.BytesIO(doc_bytes), "image/jpeg")),
        ("selfie", ("selfie.jpg", io.BytesIO(selfie_bytes), "image/jpeg")),
    ]

    response = client.post("/api/v1/verify/document", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "verified"
    assert "recommendation" in data


def test_verify_document_missing_file_returns_422(client):
    """Test POST /api/v1/verify/document without document payload returns 422."""
    response = client.post("/api/v1/verify/document", files={})
    assert response.status_code == 422


def test_get_verification_status_polling(client):
    """Test GET /api/v1/verify/status/{verification_id} polling flow."""
    test_id = "SHIELD-VER-2026-XYZ123"
    response = client.get(f"/api/v1/verify/status/{test_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "completed"
    assert data["verification_id"] == test_id


# ==============================================================================
# 3. Instant KYC Integration Flow
# ==============================================================================

def test_instant_kyc_successful_request(client):
    """Test POST /api/v1/kyc/instant creates token, QR code, and DigiLocker redirect."""
    payload = {
        "purpose": "telecom_sim_activation",
        "return_url": "https://telecom.example.com/kyc/callback",
        "consent": True,
    }
    response = client.post("/api/v1/kyc/instant", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "pending"
    assert data["kyc_token"].startswith("SHIELD-KYC-")
    assert "api.qrserver.com" in data["qr_code"]
    assert "digilocker.gov.in" in data["digilocker_redirect"]
    assert "Redirecting to DigiLocker" in data["message"]


def test_instant_kyc_default_consent_and_optional_return_url(client):
    """Test POST /api/v1/kyc/instant with minimal required fields."""
    payload = {"purpose": "fintech_loan_approval"}
    response = client.post("/api/v1/kyc/instant", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "pending"
    assert "kyc_token" in data


def test_instant_kyc_validation_error_on_empty_payload(client):
    """Test POST /api/v1/kyc/instant returns 422 when required purpose is missing."""
    response = client.post("/api/v1/kyc/instant", json={})
    assert response.status_code == 422
    errors = response.json()["detail"]
    assert any("purpose" in err["loc"] for err in errors)


# ==============================================================================
# 4. Fraud Document Reporting & FIR Integration Flow
# ==============================================================================

def test_report_fake_document_with_coordinates(client):
    """Test POST /api/v1/report/fake generates an FIR number and dispatches station."""
    fake_doc_bytes = b"FORGED_PAN_CARD_SCAN_CONTENT"
    files = {"document": ("forged_pan.jpg", io.BytesIO(fake_doc_bytes), "image/jpeg")}
    data = {
        "description": "Altered date of birth and forged hologram detected",
        "latitude": 19.0760,
        "longitude": 72.8777,
    }

    response = client.post("/api/v1/report/fake", files=files, data=data)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["fir_number"].startswith("FIR-2026-")
    assert "Police notified" in data["message"]
    assert data["assigned_station"] == "Nearest Police Station"


def test_report_fake_document_minimal_inputs(client):
    """Test POST /api/v1/report/fake with only document file provided."""
    files = {"document": ("fake_card.pdf", io.BytesIO(b"FAKE_DATA"), "application/pdf")}
    response = client.post("/api/v1/report/fake", files=files)
    assert response.status_code == 200
    assert response.json()["status"] == "success"


def test_report_fake_document_missing_file_returns_422(client):
    """Test POST /api/v1/report/fake without document file returns 422."""
    response = client.post("/api/v1/report/fake", data={"description": "Suspicious"})
    assert response.status_code == 422


# ==============================================================================
# 5. Routing, Methods, and CORS
# ==============================================================================

def test_nonexistent_route_returns_404(client):
    """Test accessing an undefined route returns 404 Not Found."""
    response = client.get("/api/v1/nonexistent_service")
    assert response.status_code == 404


def test_method_not_allowed_returns_405(client):
    """Test unsupported HTTP method on defined route returns 405 Method Not Allowed."""
    response = client.delete("/api/v1/kyc/instant")
    assert response.status_code == 405
