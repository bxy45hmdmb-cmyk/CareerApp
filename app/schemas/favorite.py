from datetime import datetime
from pydantic import BaseModel
from app.schemas.profession import ProfessionListResponse


class FavoriteCreate(BaseModel):
    profession_id: int


class FavoriteResponse(BaseModel):
    id: int
    profession_id: int
    profession: ProfessionListResponse
    created_at: datetime

    model_config = {"from_attributes": True}


class FavoriteStatusResponse(BaseModel):
    is_favorite: bool
    profession_id: int