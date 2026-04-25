"""
ORM-модели для профессий и связанных сущностей.

Содержит три таблицы:
  - Profession         — основные данные профессии (на казахском).
  - ProfessionTranslation — переводы полей профессии на другие языки.
  - DevelopmentPath    — дорожная карта развития для профессии.
"""

from datetime import datetime
from sqlalchemy import DateTime, ForeignKey, Integer, JSON, String, Text, Float, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Profession(Base):
    """
    Основная модель профессии.

    Хранит данные на базовом языке (казахский, 'kk').
    Поля с суффиксом _ru — устаревший способ хранения русского перевода;
    новый подход — таблица ProfessionTranslation.
    Поле category_key используется алгоритмом подбора профессий по результатам теста.
    """
    __tablename__ = "professions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)

    # Название профессии на казахском; индекс для быстрого поиска
    title: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    title_ru: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # Уникальный человекочитаемый идентификатор (используется в URL)
    slug: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)

    description: Mapped[str] = mapped_column(Text, nullable=False)
    description_ru: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Категория профессии (например «Технологии», «Медицина»)
    category: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    category_ru: Mapped[str | None] = mapped_column(String(100), nullable=True)

    # Визуальные атрибуты — используются во Flutter-интерфейсе
    icon_emoji: Mapped[str] = mapped_column(String(10), default="💼")
    color_hex: Mapped[str] = mapped_column(String(20), default="#6C63FF")

    # Навыки и перспективы хранятся как JSON-массивы строк
    required_skills: Mapped[list] = mapped_column(JSON, default=list)
    required_skills_ru: Mapped[list | None] = mapped_column(JSON, nullable=True)
    future_opportunities: Mapped[list] = mapped_column(JSON, default=list)
    future_opportunities_ru: Mapped[list | None] = mapped_column(JSON, nullable=True)

    # Диапазон зарплат в тенге (KZT) — опционален, так как данные могут отсутствовать
    salary_min: Mapped[int | None] = mapped_column(Integer, nullable=True)
    salary_max: Mapped[int | None] = mapped_column(Integer, nullable=True)
    salary_currency: Mapped[str] = mapped_column(String(10), default="KZT")

    # Уровень спроса на рынке труда: low / medium / high / very_high
    demand_level: Mapped[str] = mapped_column(
        String(50), default="medium"
    )  # low, medium, high, very_high
    growth_rate: Mapped[str | None] = mapped_column(String(50), nullable=True)

    # Ключ категории для алгоритма сопоставления результатов теста с профессиями
    category_key: Mapped[str] = mapped_column(String(100), nullable=False)

    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )

    # ── Связи ─────────────────────────────────────────────────────────────────
    # Дорожная карта развития — один-к-одному, удаляется вместе с профессией
    development_path: Mapped["DevelopmentPath"] = relationship(
        "DevelopmentPath", back_populates="profession",
        cascade="all, delete-orphan", uselist=False
    )
    # Рекомендации, связанные с профессией (результаты тестов)
    recommendations: Mapped[list["Recommendation"]] = relationship(
        "Recommendation", back_populates="profession"
    )
    # Переводы текстовых полей профессии на разные языки
    translations: Mapped[list["ProfessionTranslation"]] = relationship(
        "ProfessionTranslation", back_populates="profession",
        cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Profession id={self.id} title={self.title}>"


class ProfessionTranslation(Base):
    """
    Перевод полей профессии на конкретный язык.

    Вместо дублирования колонок (title_ru, description_ru и т.д.) в основной
    таблице, используем отдельную таблицу переводов — это позволяет легко
    добавить новые языки без изменения схемы.

    Поле lang: ISO 639-1 код языка ('ru', 'en', 'kz' и т.д.).
    """
    __tablename__ = "profession_translations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    lang: Mapped[str] = mapped_column(String(10), nullable=False)  # 'ru', 'en', ...
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    category: Mapped[str] = mapped_column(String(100), nullable=False)
    required_skills: Mapped[list] = mapped_column(JSON, default=list)
    future_opportunities: Mapped[list] = mapped_column(JSON, default=list)

    # Обратная ссылка на родительскую профессию
    profession: Mapped["Profession"] = relationship("Profession", back_populates="translations")


class DevelopmentPath(Base):
    """
    Дорожная карта профессионального развития для конкретной профессии.

    Содержит структурированные данные о том, что нужно изучить, какие
    курсы пройти и как поэтапно достичь выбранной профессии.
    Все списки хранятся как JSON-массивы для гибкости.
    """
    __tablename__ = "development_paths"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    # Уникальный FK: у каждой профессии только одна дорожная карта
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"),
        nullable=False, unique=True
    )

    # Список школьных предметов, важных для этой профессии
    required_subjects: Mapped[list] = mapped_column(JSON, default=list)
    # Навыки, которые необходимо развить
    skills_to_develop: Mapped[list] = mapped_column(JSON, default=list)
    # Рекомендуемые онлайн-курсы и ресурсы
    suggested_courses: Mapped[list] = mapped_column(JSON, default=list)
    # Олимпиады, в которых стоит участвовать
    olympiads: Mapped[list] = mapped_column(JSON, default=list)
    # Практические проекты для портфолио
    projects: Mapped[list] = mapped_column(JSON, default=list)
    # Пошаговый план развития (roadmap)
    roadmap_steps: Mapped[list] = mapped_column(JSON, default=list)
    # Примерное время достижения цели в месяцах
    estimated_duration_months: Mapped[int | None] = mapped_column(
        Integer, nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )

    # ── Связи ─────────────────────────────────────────────────────────────────
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="development_path"
    )

    def __repr__(self) -> str:
        return f"<DevelopmentPath id={self.id} profession_id={self.profession_id}>"
