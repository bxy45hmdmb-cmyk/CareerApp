from datetime import datetime
from sqlalchemy import DateTime, ForeignKey, Integer, JSON, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base


class Question(Base):
    __tablename__ = "questions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    text_ru: Mapped[str | None] = mapped_column(Text, nullable=True)
    category: Mapped[str] = mapped_column(
        String(100), nullable=False
    )  # e.g. interest, skill, subject
    options: Mapped[list] = mapped_column(JSON, nullable=False)
    options_ru: Mapped[list | None] = mapped_column(JSON, nullable=True)
    # Maps each option index to career category weights
    # e.g. {"0": {"technology": 3, "medicine": 0}, "1": {...}}
    weights: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    order: Mapped[int] = mapped_column(Integer, default=0)
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    # Relationships
    answers: Mapped[list["Answer"]] = relationship(
        "Answer", back_populates="question"
    )
    translations: Mapped[list["QuestionTranslation"]] = relationship(
        "QuestionTranslation", back_populates="question", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Question id={self.id} category={self.category}>"


class QuestionTranslation(Base):
    """Stores translated text/options for a question (e.g. lang='ru')."""
    __tablename__ = "question_translations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    question_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("questions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    lang: Mapped[str] = mapped_column(String(10), nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    options: Mapped[list] = mapped_column(JSON, nullable=False, default=list)

    question: Mapped["Question"] = relationship("Question", back_populates="translations")


class Answer(Base):
    __tablename__ = "answers"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    test_result_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("test_results.id", ondelete="CASCADE"), nullable=False
    )
    question_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("questions.id", ondelete="CASCADE"), nullable=False
    )
    selected_option_index: Mapped[int] = mapped_column(Integer, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    # Relationships
    test_result: Mapped["TestResult"] = relationship(
        "TestResult", back_populates="answers"
    )
    question: Mapped["Question"] = relationship(
        "Question", back_populates="answers"
    )

    def __repr__(self) -> str:
        return f"<Answer id={self.id} question_id={self.question_id}>"