from __future__ import annotations

from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import DateTime, ForeignKey, Integer, JSON, Float, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base

if TYPE_CHECKING:
    from app.models.user import User
    from app.models.profession import Profession
    from app.models.question import Answer


class TestResult(Base):
    __tablename__ = "test_results"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    category_scores: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    total_questions: Mapped[int] = mapped_column(Integer, default=0)
    completed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    user: Mapped["User"] = relationship("User", back_populates="test_results")
    answers: Mapped[list["Answer"]] = relationship(
        "Answer", back_populates="test_result", cascade="all, delete-orphan"
    )
    recommendations: Mapped[list["Recommendation"]] = relationship(
        "Recommendation", back_populates="test_result", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<TestResult id={self.id} user_id={self.user_id}>"


class Recommendation(Base):
    __tablename__ = "recommendations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    test_result_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("test_results.id", ondelete="CASCADE"), nullable=False
    )
    profession_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("professions.id", ondelete="CASCADE"), nullable=False
    )
    match_percentage: Mapped[float] = mapped_column(Float, nullable=False)
    rank: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    user: Mapped["User"] = relationship("User", back_populates="recommendations")
    test_result: Mapped["TestResult"] = relationship(
        "TestResult", back_populates="recommendations"
    )
    profession: Mapped["Profession"] = relationship(
        "Profession", back_populates="recommendations"
    )

    def __repr__(self) -> str:
        return (
            f"<Recommendation id={self.id} "
            f"profession_id={self.profession_id} "
            f"match={self.match_percentage}%>"
        )
