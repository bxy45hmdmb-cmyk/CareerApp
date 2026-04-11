from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import get_db, get_current_active_user
from app.crud.test_result import crud_test_result
from app.schemas.recommendation import RecommendationResponse
from app.models.user import User

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])


@router.get(
    "/",
    response_model=list[RecommendationResponse],
    summary="Get all career recommendations for the current user",
)
async def get_my_recommendations(
    lang: str = Query("kk"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    recommendations = await crud_test_result.get_user_recommendations(
        db, user_id=current_user.id
    )
    if not recommendations:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No recommendations found. Please complete the career test first.",
        )
    if lang == "ru":
        for rec in recommendations:
            p = rec.profession
            if hasattr(p, "title_ru") and p.title_ru:
                p.title = p.title_ru
            if hasattr(p, "category_ru") and p.category_ru:
                p.category = p.category_ru
    return recommendations