"""
Конфигурация приложения на основе Pydantic Settings.

Все параметры читаются из переменных окружения (файл .env).
Pydantic автоматически валидирует типы и выбросит ошибку при старте,
если обязательные поля (DATABASE_URL, SECRET_KEY и др.) не заданы.
"""

from pydantic_settings import BaseSettings
from pydantic import field_validator
from typing import List
import os
from dotenv import load_dotenv

# Загружаем .env до создания Settings, чтобы переменные попали в окружение
load_dotenv()


class Settings(BaseSettings):
    """
    Централизованное хранилище всех настроек приложения.

    Секретные ключи (SECRET_KEY, EMAIL_PASSWORD, GEMINI_API_KEY и т.д.)
    никогда не должны быть зафиксированы в git — только через .env или
    переменные окружения CI/CD.
    """

    # ── Приложение ────────────────────────────────────────────────────────────
    APP_NAME: str = "Career Guidance API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True           # В продакшене установить False
    API_V1_PREFIX: str = "/api/v1"

    # ── База данных ───────────────────────────────────────────────────────────
    # Асинхронный URL (asyncpg / aiosqlite) — используется SQLAlchemy
    DATABASE_URL: str
    # Синхронный URL — может понадобиться для Alembic-миграций
    SYNC_DATABASE_URL: str

    # ── JWT-безопасность ──────────────────────────────────────────────────────
    SECRET_KEY: str                            # Секретный ключ подписи токенов
    ALGORITHM: str = "HS256"                   # Алгоритм подписи JWT
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30      # Срок жизни access-токена (мин)
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7         # Срок жизни refresh-токена (дней)

    # ── Email (SMTP) ──────────────────────────────────────────────────────────
    EMAIL_HOST: str = "smtp.gmail.com"
    EMAIL_PORT: int = 465
    EMAIL_USER: str = ""
    EMAIL_PASSWORD: str = ""
    EMAIL_FROM_NAME: str = "CareerApp"
    EMAIL_USE_TLS: bool = True
    EMAIL_USE_STARTTLS: bool = False
    OTP_EXPIRE_MINUTES: int = 10    # Время жизни одноразового кода подтверждения

    # ── AI-интеграции ─────────────────────────────────────────────────────────
    GEMINI_API_KEY: str = ""        # Google Gemini — для генерации рекомендаций
    ANTHROPIC_API_KEY: str = ""     # Anthropic Claude — альтернативный AI

    # ── CORS ──────────────────────────────────────────────────────────────────
    # Список разрешённых источников через запятую (для Swagger UI, фронтенда)
    ALLOWED_ORIGINS: str = "http://localhost:3000"

    @property
    def allowed_origins_list(self) -> List[str]:
        """Преобразует строку с источниками в список для CORSMiddleware."""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]

    class Config:
        env_file = ".env"
        case_sensitive = True   # DATABASE_URL ≠ database_url


# Глобальный синглтон настроек — импортируется во всех модулях
settings = Settings()
