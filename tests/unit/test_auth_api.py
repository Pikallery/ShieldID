"""
Unit tests for the OAuth 2.0 and Sovereign Authentication API.
"""

from fastapi.testclient import TestClient


def test_oauth_verify_google(client: TestClient):
    payload = {
        "provider": "google",
        "email": "officer.verma@delhiairport.aero",
        "full_name": "Inspector Rajesh Verma",
        "badge_id": "IGI-AIRPORT-8842",
    }
    response = client.post("/api/v1/auth/oauth/verify", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert data["officer"]["email"] == "officer.verma@delhiairport.aero"
    assert data["officer"]["role"] == "Lead Border Control Officer"
    assert data["officer"]["auth_method"] == "Google OAuth 2.0"


def test_oauth_verify_sso(client: TestClient):
    payload = {
        "provider": "sso",
        "email": "command.clearance@digiyatra.gov.in",
        "full_name": "Commander Vikramaditya Singh",
        "badge_id": "DY-SOV-0012",
    }
    response = client.post("/api/v1/auth/oauth/verify", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["officer"]["auth_method"] == "DigiYatra Sovereign SSO"
    assert data["officer"]["role"] == "Sovereign Transit Command Director"


def test_oauth_verify_invalid_provider(client: TestClient):
    payload = {
        "provider": "unsupported_provider",
    }
    response = client.post("/api/v1/auth/oauth/verify", json=payload)
    assert response.status_code == 400
    assert "Unsupported OAuth provider" in response.json()["detail"]


def test_get_current_officer_me(client: TestClient):
    # First get token
    verify_resp = client.post(
        "/api/v1/auth/oauth/verify",
        json={"provider": "google", "email": "test.officer@shieldid.gov.in"},
    )
    token = verify_resp.json()["access_token"]

    # Now query /me
    me_resp = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert me_resp.status_code == 200
    me_data = me_resp.json()
    assert me_data["authenticated"] is True
    assert me_data["clearance_level"] == "LEVEL_4_BORDER_CONTROL"


def test_get_current_officer_unauthorized(client: TestClient):
    me_resp = client.get("/api/v1/auth/me")
    assert me_resp.status_code == 401
