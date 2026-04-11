from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import get_db, get_current_active_user
from app.crud.test_result import crud_test_result
from app.schemas.question import TestSubmitRequest
from app.schemas.recommendation import TestResultWithRecommendations
from app.schemas.test_result import TestResultResponse
from app.services.recommendation import recommendation_service
from app.models.user import User

router = APIRouter(prefix="/tests", tags=["Career Test"])


@router.post(
    "/submit",
    response_model=TestResultWithRecommendations,
    status_code=status.HTTP_201_CREATED,
    summary="Submit test answers and receive career recommendations",
)
async def submit_test(
    payload: TestSubmitRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    if not payload.answers:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="No answers provided",
        )

    result = await recommendation_service.process_test_submission(
        db=db,
        user_id=current_user.id,
        answers=payload.answers,
    )
    return result


@router.get(
    "/my-results",
    response_model=list[TestResultWithRecommendations],
    summary="Get all test results for the current user",
)
async def get_my_results(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    results = await crud_test_result.get_user_results(db, user_id=current_user.id)
    return [
        {
            "test_result_id": r.id,
            "category_scores": r.category_scores,
            "total_questions": r.total_questions,
            "completed_at": r.completed_at,
            "recommendations": [
                {
                    "id": rec.id,
                    "profession_id": rec.profession_id,
                    "match_percentage": rec.match_percentage,
                    "rank": rec.rank,
                    "profession": rec.profession,
                    "created_at": rec.created_at,
                }
                for rec in r.recommendations
            ],
        }
        for r in results
    ]


@router.get(
    "/latest",
    response_model=TestResultWithRecommendations,
    summary="Get the most recent test result",
)
async def get_latest_result(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    result = await crud_test_result.get_latest_result(
        db, user_id=current_user.id
    )
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No test results found. Please complete the career test first.",
        )
    return {
        "test_result_id": result.id,
        "category_scores": result.category_scores,
        "total_questions": result.total_questions,
        "completed_at": result.completed_at,
        "recommendations": [
            {
                "id": rec.id,
                "profession_id": rec.profession_id,
                "match_percentage": rec.match_percentage,
                "rank": rec.rank,
                "profession": rec.profession,
                "created_at": rec.created_at,
            }
            for rec in result.recommendations
        ],
    }