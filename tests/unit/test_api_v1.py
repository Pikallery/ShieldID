def test_verify_document_endpoint(client, dummy_file_payload):
    """Test POST /api/v1/verify/document endpoint with single document file."""
    filename, file_obj, content_type = dummy_file_payload
    files = {"document": (filename, file_obj, content_type)}

    response = client.post("/api/v1/verify/document", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "verified"
    assert data["risk_score"] == 15
    assert data["document_type"] == "passport"
    assert data["recommendation"] == "APPROVE"


def test_verify_document_with_selfie(client, dummy_file_payload, dummy_image_payload):
    """Test POST /api/v1/verify/document endpoint with document and selfie files."""
    doc_name, doc_bytes, doc_type = dummy_file_payload
    selfie_name, selfie_bytes, selfie_type = dummy_image_payload

    files = [
        ("document", (doc_name, doc_bytes, doc_type)),
        ("selfie", (selfie_name, selfie_bytes, selfie_type)),
    ]

    response = client.post("/api/v1/verify/document", files=files)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "verified"


def test_verify_status_endpoint(client):
    """Test GET /api/v1/verify/status/{verification_id} endpoint."""
    verification_id = "VER-2026-9876"
    response = client.get(f"/api/v1/verify/status/{verification_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "completed"
    assert data["verification_id"] == verification_id


def test_instant_kyc_endpoint(client):
    """Test POST /api/v1/kyc/instant endpoint with valid request JSON."""
    payload = {
        "purpose": "bank_account",
        "return_url": "https://client.app/callback",
        "consent": True,
    }
    response = client.post("/api/v1/kyc/instant", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "pending"
    assert "kyc_token" in data
    assert "qr_code" in data
    assert "digilocker_redirect" in data


def test_instant_kyc_missing_required_fields(client):
    """Test POST /api/v1/kyc/instant fails with 422 if mandatory purpose field is omitted."""
    response = client.post("/api/v1/kyc/instant", json={})
    assert response.status_code == 422


def test_report_fake_document_endpoint(client, dummy_file_payload):
    """Test POST /api/v1/report/fake endpoint."""
    filename, file_obj, content_type = dummy_file_payload
    files = {"document": (filename, file_obj, content_type)}
    data = {
        "description": "Forged text on Aadhaar card photo area",
        "latitude": 28.6139,
        "longitude": 77.2090,
    }

    response = client.post("/api/v1/report/fake", files=files, data=data)
    assert response.status_code == 200
    res_json = response.json()
    assert res_json["status"] == "success"
    assert res_json["fir_number"].startswith("FIR-2026-")
    assert "assigned_station" in res_json
