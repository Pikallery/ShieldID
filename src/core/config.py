
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "ShieldID"
    VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"
    DATABASE_URL: str = "postgresql+asyncpg://shieldid:admin123@db:5432/shieldid"
    REDIS_URL: str = "redis://redis:6379/0"
    SECRET_KEY: str = "dev-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    ALLOWED_ORIGINS: list[str] = ["*"]
    MODE: str = "development"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()