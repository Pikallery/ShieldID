from src.core.config import settings, Settings


def test_default_settings():
    """Test default settings attributes."""
    assert settings.PROJECT_NAME == "ShieldID"
    assert settings.VERSION == "1.0.0"
    assert settings.API_V1_PREFIX == "/api/v1"
    assert "postgresql+asyncpg://" in settings.DATABASE_URL
    assert "redis://" in settings.REDIS_URL
    assert settings.JWT_ALGORITHM == "HS256"
    assert settings.ACCESS_TOKEN_EXPIRE_MINUTES == 30
    assert settings.ALLOWED_ORIGINS == ["*"]
    assert settings.MODE == "development"


def test_custom_settings_instantiation():
    """Test instantiating Settings with custom values."""
    custom_settings = Settings(
        PROJECT_NAME="CustomShield",
        MODE="production",
        ACCESS_TOKEN_EXPIRE_MINUTES=60,
    )
    assert custom_settings.PROJECT_NAME == "CustomShield"
    assert custom_settings.MODE == "production"
    assert custom_settings.ACCESS_TOKEN_EXPIRE_MINUTES == 60
