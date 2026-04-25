"""
Утилиты безопасности: хэширование паролей и работа с JWT-токенами.

Используется библиотека passlib (bcrypt) для паролей и python-jose для JWT.
Все токены содержат поле «type» для различия access и refresh.
"""

from datetime import datetime, timedelta, timezone
from typing import Optional, Union
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.core.config import settings

# Контекст хэширования паролей: bcrypt — современный и безопасный алгоритм.
# deprecated="auto" автоматически перехэшивает устаревшие схемы при проверке.
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Проверяет соответствие открытого пароля его хэшу.

    Используется при аутентификации: сравниваем введённый пароль с хэшем в БД.
    Bcrypt намеренно медленный — это защита от брутфорс-атак.
    """
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """
    Хэширует открытый пароль с помощью bcrypt.

    Вызывается при регистрации и смене пароля.
    Соль генерируется автоматически — два хэша одного пароля будут разными.
    """
    return pwd_context.hash(password)


def create_access_token(
    subject: Union[str, int],
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    Создаёт JWT access-токен для краткосрочной аутентификации.

    Access-токен живёт ACCESS_TOKEN_EXPIRE_MINUTES минут (по умолчанию 30).
    Поле «type»: «access» позволяет отличить его от refresh-токена
    и не принять refresh там, где ожидается access.

    Args:
        subject: ID пользователя (строка или int), кодируется в поле «sub».
        expires_delta: переопределить срок жизни (опционально).
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    to_encode = {
        "exp": expire,                          # время истечения
        "sub": str(subject),                    # ID пользователя
        "type": "access",                       # тип токена
        "iat": datetime.now(timezone.utc),      # время создания
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(
    subject: Union[str, int],
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    Создаёт JWT refresh-токен для получения новой пары токенов.

    Refresh-токен живёт REFRESH_TOKEN_EXPIRE_DAYS дней (по умолчанию 7).
    Хранится на клиенте и используется только в эндпоинте /auth/refresh.
    В случае компрометации необходимо инвалидировать через rotation или blacklist.

    Args:
        subject: ID пользователя.
        expires_delta: переопределить срок жизни (опционально).
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            days=settings.REFRESH_TOKEN_EXPIRE_DAYS
        )

    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "type": "refresh",                      # тип токена — отличается от access
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_token(token: str) -> Optional[dict]:
    """
    Декодирует и верифицирует JWT-токен.

    Проверяет подпись и срок действия. Возвращает словарь payload или None
    при любой ошибке (истёк срок, неверная подпись, повреждённый токен).
    Возврат None вместо исключения позволяет вызывающему коду
    самостоятельно решить, как реагировать на невалидный токен.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        # Любая ошибка JWT (истёкший, неверная подпись и т.д.) возвращает None
        return None
