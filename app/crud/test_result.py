from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.models.test_result import TestResult, Recommendation


class CRUDTestResult:
    async def create(
        self,
        db: AsyncSession,
        user_id: int,
        category_scores: dict,
        total_questions: int,
    ) -> TestResult:
        test_result = TestResult(
            user_id=user_id,
            category_scores=category_scores,
            total_questions=total_questions,
        )
        db.add(test_result)
        await db.flush()
        await db.refresh(test_result)
        return test_result

    async def get(
        self,
        db: AsyncSession,
        id: int,
        load_recommendations: bool = False
    ) -> Optional[TestResult]:
        query = select(TestResult).where(TestResult.id == id)
        if load_recommendations:
            query = query.options(
                selectinload(TestResult.recommendations).selectinload(
                    Recommendation.profession
                )
            )
        result = await db.execute(query)
        return result.scalar_one_or_none()

    async def get_user_results(
        self, db: AsyncSession, user_id: int
    ) -> list[TestResult]:
        result = await db.execute(
            select(TestResult)
            .where(TestResult.user_id == user_id)
            .order_by(TestResult.completed_at.desc())
            .options(
                selectinload(TestResult.recommendations).selectinload(
                    Recommendation.profession
                )
            )
        )
        return list(result.scalars().all())

    async def get_latest_result(
        self, db: AsyncSession, user_id: int
    ) -> Optional[TestResult]:
        result = await db.execute(
            select(TestResult)
            .where(TestResult.user_id == user_id)
            .order_by(TestResult.completed_at.desc())
            .limit(1)
            .options(
                selectinload(TestResult.recommendations).selectinload(
                    Recommendation.profession
                )
            )
        )
        return result.scalar_one_or_none()

    async def create_recommendation(
        self,
        db: AsyncSession,
        user_id: int,
        test_result_id: int,
        profession_id: int,
        match_percentage: float,
        rank: int,
    ) -> Recommendation:
        rec = Recommendation(
            user_id=user_id,
            test_result_id=test_result_id,
            profession_id=profession_id,
            match_percentage=match_percentage,
            rank=rank,
        )
        db.add(rec)
        await db.flush()
        return rec

    async def get_user_recommendations(
        self, db: AsyncSession, user_id: int
    ) -> list[Recommendation]:
        result = await db.execute(
            select(Recommendation)
            .where(Recommendation.user_id == user_id)
            .order_by(Recommendation.rank.asc())
            .options(selectinload(Recommendation.profession))
        )
        return list(result.scalars().all())


crud_test_result = CRUDTestResult()