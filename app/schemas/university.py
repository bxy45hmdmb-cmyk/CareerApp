from pydantic import BaseModel


class UniversityResponse(BaseModel):
    id: int
    name: str
    short_name: str | None
    city: str
    website: str | None
    description: str | None
    category_keys: list[str]
    rating: int
    is_national: bool

    model_config = {"from_attributes": True}