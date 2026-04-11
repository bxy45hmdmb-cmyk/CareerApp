from datetime import datetime
from pydantic import BaseModel, EmailStr, field_validator


class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    grade: int
    school: str | None = None
    city: str | None = None

    @field_validator("grade")
    @classmethod
    def validate_grade(cls, v: int) -> int:
        if v < 7 or v > 11:
            raise ValueError("Grade must be between 7 and 11")
        return v


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    full_name: str | None = None
    grade: int | None = None
    school: str | None = None
    city: str | None = None
    avatar_url: str | None = None

    @field_validator("grade")
    @classmethod
    def validate_grade(cls, v: int | None) -> int | None:
        if v is not None and (v < 7 or v > 11):
            raise ValueError("Grade must be between 7 and 11")
        return v


class UserResponse(UserBase):
    id: int
    is_active: bool
    is_verified: bool
    avatar_url: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


class UserProgressResponse(BaseModel):
    test_completed: bool
    test_count: int
    favorites_count: int
    top_category: str | None
    top_match_percentage: float | None

    model_config = {"from_attributes": True}