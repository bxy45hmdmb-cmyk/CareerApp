from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import get_db, get_current_active_user
from app.crud.favorites import crud_favorite
from app.crud.profession import crud_profession
from app.schemas.favorite import FavoriteResponse, FavoriteCreate, FavoriteStatusResponse
from app.models.user import User
from sqlalchemy.orm import selectinload
from sqlalchemy import select
from app.models.favorites import Favorite

router = APIRouter(prefix="/favorites", tags=["Favorites"])


@router.get(
    "/",
    response_model=list[FavoriteResponse],
    summary="Get all favorites for current user",
)
async def get_favorites(
    lang: str = Query("kk"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    result = await db.execute(
        select(Favorite)
        .where(Favorite.user_id == current_user.id)
        .options(selectinload(Favorite.profession))
        .order_by(Favorite.created_at.desc())
    )
    favs = list(result.scalars().all())
    if lang != "kk":
        for fav in favs:
            if fav.profession:
                t = await crud_profession.get_translation(db, fav.profession.id, lang)
                if t:
                    fav.profession.title = t.title
                    fav.profession.description = t.description
                    fav.profession.category = t.category
                    fav.profession.required_skills = t.required_skills
                    fav.profession.future_opportunities = t.future_opportunities
    return favs


@router.post(
    "/",
    response_model=FavoriteResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add a profession to favorites",
)
async def add_favorite(
    payload: FavoriteCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    profession = await crud_profession.get(db, id=payload.profession_id)
    if not profession:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profession not found",
        )
    fav = await crud_favorite.add(
        db, user_id=current_user.id, profession_id=payload.profession_id
    )
    # Reload with profession
    result = await db.execute(
        select(Favorite)
        .where(Favorite.id == fav.id)
        .options(selectinload(Favorite.profession))
    )
    return result.scalar_one()


@router.delete(
    "/{profession_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Remove a profession from favorites",
)
async def remove_favorite(
    profession_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    removed = await crud_favorite.remove(
        db, user_id=current_user.id, profession_id=profession_id
    )
    if not removed:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Favorite not found",
        )


@router.get(
    "/{profession_id}/status",
    response_model=FavoriteStatusResponse,
    summary="Check if a profession is in favorites",
)
async def check_favorite_status(
    profession_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    is_fav = await crud_favorite.is_favorite(
        db, user_id=current_user.id, profession_id=profession_id
    )
    return FavoriteStatusResponse(
        is_favorite=is_fav,
        profession_id=profession_id,
    )