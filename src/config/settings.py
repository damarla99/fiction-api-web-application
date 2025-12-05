"""
Application settings and configuration
"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""

    # Application
    app_name: str = "Fictions API"
    app_version: str = "1.0.0"
    debug: bool = False
    port: int = 3000

    # Database
    mongodb_uri: str = "mongodb://mongodb:27017/fictions_db"
    db_name: str = "fictions_db"

    # Security
    jwt_secret: str = "dev-secret-change-me-in-production-12345678"
    jwt_algorithm: str = "HS256"
    jwt_expiration_hours: int = 24

    # Rate Limiting
    rate_limit_window_ms: int = 900000  # 15 minutes
    rate_limit_max_requests: int = 100
    auth_rate_limit: str = "5/15minutes"
    api_rate_limit: str = "100/15minutes"

    # CORS
    cors_origins: list = ["*"]

    class Config:
        env_file = ".env"
        case_sensitive = False


# Global settings instance
settings = Settings()
