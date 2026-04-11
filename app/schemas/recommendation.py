from datetime import datetime
from pydantic import BaseModel
from app.schemas.profession import ProfessionListResponse


class RecommendationResponse(BaseModel):
    id: int
    profession_id: int
    match_percentage: float
    rank: int
    profession: ProfessionListResponse
    created_at: datetime

    model_config = {"from_attributes": True}


class TestResultWithRecommendations(BaseModel):
    test_result_id: int
    category_scores: dict[str, float]
    total_questions: int
    completed_at: datetime
    recommendations: list[RecommendationResponse]

    model_config = {"from_attributes": True}