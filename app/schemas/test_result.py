from datetime import datetime
from pydantic import BaseModel


class TestResultResponse(BaseModel):
    id: int
    user_id: int
    category_scores: dict[str, float]
    total_questions: int
    completed_at: datetime

    model_config = {"from_attributes": True}