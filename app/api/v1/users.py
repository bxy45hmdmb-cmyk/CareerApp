import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.core.dependencies import get_db, get_current_active_user
from app.crud.user import crud_user
from app.crud.favorites import crud_favorite
from app.models.test_result import TestResult, Recommendation
from app.schemas.user import UserResponse, UserUpdate, UserProgressResponse, ChangePasswordRequest
from app.core.security import verify_password, get_password_hash
from app.models.user import User

router = APIRouter(prefix="/users", tags=["Users"])

UPLOAD_DIR = "uploads/avatars"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_active_user)):
    return current_user


@router.patch("/me", response_model=UserResponse)
async def update_me(
    payload: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    return await crud_user.update(db, db_obj=current_user, obj_in=payload)


@router.post("/me/avatar", response_model=UserResponse)
async def upload_avatar(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    allowed = {"image/jpeg", "image/png", "image/webp"}
    if file.content_type not in allowed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only JPEG, PNG, and WebP images are allowed",
        )
    ext = file.filename.split(".")[-1] if file.filename else "jpg"
    filename = f"{uuid.uuid4()}.{ext}"
    filepath = os.path.join(UPLOAD_DIR, filename)

    content = await file.read()
    with open(filepath, "wb") as f:
        f.write(content)

    avatar_url = f"/static/avatars/{filename}"
    from app.schemas.user import UserUpdate as UU
    updated = await crud_user.update(
        db, db_obj=current_user, obj_in=UU(avatar_url=avatar_url)
    )
    return updated


@router.get("/me/progress", response_model=UserProgressResponse)
async def get_progress(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    # Check if test completed
    test_result = await db.execute(
        select(TestResult)
        .where(TestResult.user_id == current_user.id)
        .order_by(TestResult.completed_at.desc())
        .limit(1)
    )
    latest = test_result.scalar_one_or_none()

    test_count_result = await db.execute(
        select(func.count(TestResult.id)).where(
            TestResult.user_id == current_user.id
        )
    )
    test_count = test_count_result.scalar() or 0

    favorites_count = await crud_favorite.count(db, user_id=current_user.id)

    top_category = None
    top_match = None
    if latest and latest.category_scores:
        scores = latest.category_scores
        top_category = max(scores, key=scores.get)

        top_rec = await db.execute(
            select(Recommendation)
            .where(Recommendation.test_result_id == latest.id)
            .order_by(Recommendation.rank.asc())
            .limit(1)
        )
        top_rec_obj = top_rec.scalar_one_or_none()
        if top_rec_obj:
            top_match = top_rec_obj.match_percentage

    return UserProgressResponse(
        test_completed=latest is not None,
        test_count=test_count,
        favorites_count=favorites_count,
        top_category=top_category,
        top_match_percentage=top_match,
    )


@router.post("/me/change-password", response_model=dict, summary="Change password")
async def change_password(
    payload: ChangePasswordRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    if not verify_password(payload.current_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ағымдағы құпиясөз қате",
        )
    current_user.hashed_password = get_password_hash(payload.new_password)
    db.add(current_user)
    await db.commit()
    return {"message": "Құпиясөз сәтті өзгертілді"}


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def deactivate_me(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    await crud_user.deactivate(db, id=current_user.id)