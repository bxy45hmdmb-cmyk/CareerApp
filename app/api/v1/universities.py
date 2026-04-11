from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import get_db, get_current_active_user
from app.crud.university import crud_university
from app.schemas.university import UniversityResponse
from app.models.user import User

router = APIRouter(prefix="/universities", tags=["Universities"])


@router.get(
    "/",
    response_model=list[UniversityResponse],
    summary="Get all universities in Kazakhstan",
)
async def get_all_universities(
    city: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    if city:
        return await crud_university.get_by_city(db, city=city)
    return await crud_university.get_all(db)


@router.get(
    "/by-profession/{category_key}",
    response_model=list[UniversityResponse],
    summary="Get universities relevant to a profession category",
)
async def get_universities_by_profession(
    category_key: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    return await crud_university.get_by_category_key(db, category_key=category_key)