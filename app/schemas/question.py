from datetime import datetime
from pydantic import BaseModel


class QuestionBase(BaseModel):
    text: str
    category: str
    options: list[str]
    order: int = 0


class QuestionCreate(QuestionBase):
    weights: dict[str, dict[str, float]]


class QuestionUpdate(BaseModel):
    text: str | None = None
    category: str | None = None
    options: list[str] | None = None
    weights: dict[str, dict[str, float]] | None = None
    order: int | None = None
    is_active: bool | None = None


class QuestionResponse(QuestionBase):
    id: int
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class AnswerSubmit(BaseModel):
    question_id: int
    selected_option_index: int


class TestSubmitRequest(BaseModel):
    answers: list[AnswerSubmit]

    model_config = {"json_schema_extra": {
        "example": {
            "answers": [
                {"question_id": 1, "selected_option_index": 0},
                {"question_id": 2, "selected_option_index": 2},
            ]
        }
    }}