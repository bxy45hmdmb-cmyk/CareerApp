from datetime import datetime
from sqlalchemy import DateTime, ForeignKey, Integer, JSON, String, Text, Float, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Profession(Base):
    __tablename__ = "professions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    title_ru: Mapped[str | None] = mapped_column(String(255), nullable=True)
    slug: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    description_ru: Mapped[str | None] = mapped_column(Text, nullable=True)
    category: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    category_ru: Mapped[str | None] = mapped_column(String(100), nullable=True)
    icon_emoji: Mapped[str] = mapped_column(String(10), default="💼")
    color_hex: Mapped[str] = mapped_column(String(20), default="#6C63FF")
    required_skills: Mapped[list] = mapped_column(JSON, default=list)
    required_skills_ru: Mapped[list | None] = mapped_column(JSON, nullable=True)
    future_opportunities: Mapped[list] = mapped_column(JSON, default=list)
    future_opportunities_ru: Mapped[list | None] = mapped_column(JSON, nullable=True)
    salary_min: Mapped[int | None] = mapped_column(Integer, nullable=True)
    salary_max: Mapped[int | None] = mapped_column(Integer, nullable=True)
    salary_currency: Mapped[str] = mapped_column(String(10), default="KZT")
    demand_level: Mapped[str] = mapped_column(
        String(50), default="medium"
    )  # low, medium, high, very_high
    growth_rate: Mapped[str | None] = mapped_column(String(50), nullable=True)
    # Career category key for matching algorithm
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

    # Relationships
    development_path: Mapped["DevelopmentPath"] = relationship(
        "DevelopmentPath", back_populates="profession",
        cascade="all, delete-orphan", uselist=False
    )
    recommendations: Mapped[list["Recommendation"]] = relationship(
        "Recommendation", back_populates="profession"
    )
    translations: Mapped[list["ProfessionTranslation"]] = relationship(
        "ProfessionTranslation", back_populates="profession",
        cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Profession id={self.id} title={self.title}>"


class ProfessionTranslation(Base):
    """Stores translated fields for a profession (e.g. lang='ru')."""
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

    profession: Mapped["Profession"] = relationship("Profession", back_populates="translations")


class DevelopmentPath(Base):
    __tablename__ = "development_paths"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"),
        nullable=False, unique=True
    )
    required_subjects: Mapped[list] = mapped_column(JSON, default=list)
    skills_to_develop: Mapped[list] = mapped_column(JSON, default=list)
    suggested_courses: Mapped[list] = mapped_column(JSON, default=list)
    olympiads: Mapped[list] = mapped_column(JSON, default=list)
    projects: Mapped[list] = mapped_column(JSON, default=list)
    # Step-by-step roadmap
    roadmap_steps: Mapped[list] = mapped_column(JSON, default=list)
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

    # Relationships
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="development_path"
    )

    def __repr__(self) -> str:
        return f"<DevelopmentPath id={self.id} profession_id={self.profession_id}>"