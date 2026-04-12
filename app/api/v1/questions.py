from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import get_db, get_current_active_user
from app.crud.question import crud_question
from app.schemas.question import QuestionResponse, QuestionCreate, QuestionUpdate
from app.models.user import User

router =  APIRouter(prefix="/questions", tags=["Career Test Questions"])


@router.get(
    "/",
    response_model=list[QuestionResponse],
    summary="Fetch all active career test questions",
)
async def get_questions(
    lang: str = Query("kk"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    questions = await crud_question.get_multi_active(db)
    if lang != "kk":
        trans_map = await crud_question.get_translations_for_lang(db, lang)
        for q in questions:
            t = trans_map.get(q.id)
            if t:
                db.expunge(q)
                q.text = t.text
                q.options = t.options
    return questions


@router.post(
    "/",
    response_model=QuestionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Add a new question (admin)",
)
async def create_question(
    payload: QuestionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    return await crud_question.create(db, obj_in=payload)


@router.patch(
    "/{question_id}",
    response_model=QuestionResponse,
    summary="Update a question (admin)",
)
async def update_question(
    question_id: int,
    payload: QuestionUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    q = await crud_question.get(db, id=question_id)
    if not q:
        raise HTTPException(status_code=404, detail="Сұрақ табылмады")
    return await crud_question.update(db, db_obj=q, obj_in=payload)


@router.delete(
    "/{question_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a question (admin)",
)
async def delete_question(
    question_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    q = await crud_question.get(db, id=question_id)
    if not q:
        raise HTTPException(status_code=404, detail="Сұрақ табылмады")
    await crud_question.delete(db, id=question_id)
