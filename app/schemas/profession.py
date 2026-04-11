from datetime import datetime
from pydantic import BaseModel
from app.schemas.university import UniversityResponse


class DevelopmentPathResponse(BaseModel):
    id: int
    profession_id: int
    required_subjects: list[str]
    skills_to_develop: list[str]
    suggested_courses: list[dict]
    olympiads: list[str]
    projects: list[str]
    roadmap_steps: list[dict]
    estimated_duration_months: int | None

    model_config = {"from_attributes": True}


class ProfessionBase(BaseModel):
    title: str
    description: str
    category: str
    icon_emoji: str
    color_hex: str
    required_skills: list[str]
    future_opportunities: list[str]
    salary_min: int | None
    salary_max: int | None
    salary_currency: str
    demand_level: str
    growth_rate: str | None


class ProfessionResponse(ProfessionBase):
    id: int
    slug: str
    category_key: str
    is_active: bool
    created_at: datetime
    development_path: DevelopmentPathResponse | None = None
    universities: list[UniversityResponse] = []

    model_config = {"from_attributes": True}


class ProfessionListResponse(BaseModel):
    id: int
    title: str
    slug: str
    category: str
    icon_emoji: str
    color_hex: str
    demand_level: str
    salary_min: int | None
    salary_max: int | None

    model_config = {"from_attributes": True}