from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.question import Question, Answer
from app.models.test_result import TestResult
from app.schemas.question import QuestionCreate, QuestionUpdate


class CRUDQuestion:
    async def get(self, db: AsyncSession, id: int) -> Optional[Question]:
        result = await db.execute(select(Question).where(Question.id == id))
        return result.scalar_one_or_none()

    async def get_multi_active(self, db: AsyncSession) -> list[Question]:
        result = await db.execute(
            select(Question)
            .where(Question.is_active == True)
            .order_by(Question.order.asc())
        )
        return list(result.scalars().all())

    async def get_by_ids(
        self, db: AsyncSession, ids: list[int]
    ) -> list[Question]:
        result = await db.execute(
            select(Question).where(Question.id.in_(ids))
        )
        return list(result.scalars().all())

    async def create(self, db: AsyncSession, obj_in: QuestionCreate) -> Question:
        q = Question(**obj_in.model_dump())
        db.add(q)
        await db.flush()
        await db.refresh(q)
        return q

    async def update(self, db: AsyncSession, db_obj: Question, obj_in: QuestionUpdate) -> Question:
        data = obj_in.model_dump(exclude_unset=True)
        for field, value in data.items():
            setattr(db_obj, field, value)
        db.add(db_obj)
        await db.flush()
        await db.refresh(db_obj)
        return db_obj

    async def delete(self, db: AsyncSession, id: int) -> None:
        await db.execute(delete(Question).where(Question.id == id))
        await db.flush()

    async def create_answer(
        self,
        db: AsyncSession,
        test_result_id: int,
        question_id: int,
        selected_option_index: int,
    ) -> Answer:
        answer = Answer(
            test_result_id=test_result_id,
            question_id=question_id,
            selected_option_index=selected_option_index,
        )
        db.add(answer)
        await db.flush()
        return answer


crud_question = CRUDQuestion()