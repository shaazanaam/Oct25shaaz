"""Configuration settings for LangGraph execution service."""

from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Server
    port: int = 8000
    host: str = "0.0.0.0"
    environment: str = "development"

    # Database (Read-only for loading agent definitions)
    database_url: str

    # Redis (State management)
    redis_url: str

    # NestJS Control Plane
    nest_api_url: str
    nest_api_key: Optional[str] = None

    # LLM (Optional - for direct LLM calls)
    openai_api_key: Optional[str] = None

    class Config:
        env_file = ".env"
        case_sensitive = False


# Global settings instance
settings = Settings()