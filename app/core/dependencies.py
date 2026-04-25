"""
FastAPI-зависимости (Dependencies) для внедрения сессии БД и текущего пользователя.

Эти функции используются через Depends() в роутерах и обеспечивают:
  - управление транзакцией (автокоммит/откат),
  - проверку JWT-токена и извлечение авторизованного пользователя.
"""

from typing import AsyncGenerator
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import async_session_maker
from app.core.security import decode_token
from app.crud.user import crud_user

# Схема авторизации: Bearer-токен в заголовке Authorization
security = HTTPBearer()


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Зависимость: предоставляет асинхронную сессию БД на время одного запроса.

    Логика управления транзакцией:
    - Если роутер добавил/изменил/удалил объекты, делаем коммит автоматически.
    - При любом исключении откатываем транзакцию, чтобы не оставить БД
      в неконсистентном состоянии.
    - Сессия всегда закрывается в блоке finally.
    """
    async with async_session_maker() as session:
        try:
            yield session
            # Коммитим только если есть реальные изменения — избегаем лишних
            # round-trip'ов к БД на read-only запросах
            if session.new or session.dirty or session.deleted:
                await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
):
    """
    Зависимость: декодирует JWT access-токен и возвращает объект пользователя.

    Проверяет:
    1. Токен является валидным JWT (подпись + срок действия).
    2. Тип токена — «access» (не refresh).
    3. Пользователь с указанным ID существует в БД.
    4. Аккаунт пользователя активен (is_active=True).

    Бросает HTTP 401 при любом нарушении — не раскрывая причину клиенту.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    token = credentials.credentials
    payload = decode_token(token)

    if payload is None:
        raise credentials_exception

    # Убеждаемся, что токен именно access, а не refresh
    token_type = payload.get("type")
    if token_type != "access":
        raise credentials_exception

    # «sub» (subject) хранит ID пользователя как строку
    user_id: str = payload.get("sub")
    if user_id is None:
        raise credentials_exception

    user = await crud_user.get(db, id=int(user_id))
    if user is None:
        raise credentials_exception

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )

    return user


async def get_current_active_user(
    current_user=Depends(get_current_user),
):
    """
    Зависимость-обёртка: дополнительная проверка активности пользователя.

    В большинстве случаев достаточно get_current_user, но эта зависимость
    явно гарантирует, что пользователь не был деактивирован между запросами.
    """
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    return current_user
