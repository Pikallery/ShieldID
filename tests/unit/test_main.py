from src.main import app


def test_app_metadata():
    """Test FastAPI application metadata setup."""
    assert app.title == "ShieldID API"
    assert app.description == "AI-Powered Identity Verification Platform"
    assert app.version == "1.0.0"
    assert app.docs_url == "/api/docs"
    assert app.redoc_url == "/api/redoc"


def test_root_endpoint(client):
    """Test GET / root endpoint status and output."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "ShieldID"
    assert data["version"] == "1.0.0"
    assert data["status"] == "operational"
    assert data["docs"] == "/api/docs"


def test_health_endpoint(client):
    """Test GET /health healthcheck endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data == {"status": "healthy"}
