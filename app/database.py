"""
Инициализация подключения к базе данных через SQLAlchemy (async).

Поддерживаются два бэкенда:
  - SQLite (для разработки/тестирования) — не требует пула соединений.
  - PostgreSQL (для продакшена) — использует pool_size и max_overflow.
Нужный бэкенд определяется автоматически по DATABASE_URL.
"""

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase
from app.core.config import settings

# Определяем тип базы данных, чтобы передать корректные аргументы движку.
# SQLite не поддерживает параметры пула (pool_size, max_overflow).
_is_sqlite = settings.DATABASE_URL.startswith("sqlite")

# Асинхронный движок SQLAlchemy.
# echo=True в DEBUG-режиме выводит все SQL-запросы в лог — удобно при отладке.
# check_same_thread=False необходим для SQLite при использовании asyncio.
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    **({"connect_args": {"check_same_thread": False}} if _is_sqlite else {
        "pool_pre_ping": True,   # проверяем соединение перед использованием
        "pool_size": 10,         # базовое количество постоянных соединений
        "max_overflow": 20,      # дополнительные соединения сверх pool_size
    }),
)

# Фабрика сессий: expire_on_commit=False позволяет обращаться к атрибутам
# объектов после коммита без дополнительного SELECT-запроса.
async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


class Base(DeclarativeBase):
    """
    Базовый класс для всех моделей SQLAlchemy.

    Все модели проекта наследуются от этого класса, что позволяет
    create_all_tables / drop_all_tables работать с единым реестром метаданных.
    """
    pass


async def create_all_tables():
    """
    Создаёт все таблицы в базе данных (если они ещё не существуют).

    Вызывается при старте приложения в функции lifespan.
    Не изменяет уже существующие таблицы — для миграций используйте Alembic.
    """
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def drop_all_tables():
    """
    Удаляет все таблицы из базы данных.

    Используется только в тестах или при сбросе данных.
    Вызов в продакшене приведёт к безвозвратной потере данных!
    """
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
