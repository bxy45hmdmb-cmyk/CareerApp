"""
Точка входа FastAPI-приложения «Кәсіптік Бағдар» (Career Guidance).

Здесь регистрируются middleware, обработчики ошибок, роутеры и
статические файлы. Жизненный цикл приложения (запуск / завершение)
управляется через asynccontextmanager lifespan.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi.staticfiles import StaticFiles
from app.core.config import settings
from app.database import create_all_tables
from app.api.router import api_router
import os
import logging

# Настраиваем логирование на уровне INFO — достаточно для продакшена
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Директория для хранения аватаров пользователей создаётся при старте,
# чтобы StaticFiles не упал с ошибкой «папка не найдена»
os.makedirs("uploads/avatars", exist_ok=True)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Управление жизненным циклом приложения.

    При старте: создаём все таблицы БД (если не существуют).
    После yield: код завершения (логируем shutdown).
    Использование asynccontextmanager вместо on_event — рекомендованный
    способ в FastAPI >= 0.93.
    """
    logger.info("Starting Career Guidance API...")
    await create_all_tables()
    logger.info("Tables ready.")
    yield
    logger.info("Shutdown.")


# Создаём экземпляр приложения с метаданными из конфигурации
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Career Guidance System for students grades 7-11",
    lifespan=lifespan,
)

# CORS: разрешаем все источники для упрощённой разработки.
# В продакшене следует ограничить список через settings.ALLOWED_ORIGINS.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Отдаём загруженные аватары как статику — Flutter читает их по URL
app.mount("/static/avatars", StaticFiles(directory="uploads/avatars"), name="avatars")


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """
    Форматируем ошибки валидации Pydantic в читаемый JSON.

    Стандартный ответ FastAPI содержит вложенные массивы; здесь мы
    упрощаем структуру: каждая ошибка — это объект с полем и сообщением.
    """
    errors = [
        {"field": "→".join(str(l) for l in e["loc"]), "message": e["msg"]}
        for e in exc.errors()
    ]
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": "Validation error", "errors": errors},
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """
    Глобальный перехватчик необработанных исключений.

    Логируем traceback на сервере, но клиенту возвращаем нейтральное
    сообщение, чтобы не раскрывать внутренние детали системы.
    """
    logger.error(f"Unhandled: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500, content={"detail": "Internal server error"}
    )


# Подключаем все маршруты API v1 под единым префиксом из конфигурации
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/health", tags=["Health"])
async def health():
    """Эндпоинт проверки работоспособности сервиса (health-check)."""
    return {"status": "healthy", "version": settings.APP_VERSION}


@app.get("/", tags=["Root"])
async def root():
    """Корневой эндпоинт — приветствие и ссылка на Swagger-документацию."""
    return {"message": "Career Guidance API", "docs": "/docs"}
