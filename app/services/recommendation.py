from sqlalchemy.ext.asyncio import AsyncSession
from app.crud.question import crud_question
from app.crud.profession import crud_profession
from app.crud.test_result import crud_test_result
from app.models.question import Question
from app.schemas.question import AnswerSubmit


class RecommendationService:
    """
    Recommendation engine — returns up to 30 ranked professions.
    """

    TOP_N_RECOMMENDATIONS = 6

    async def process_test_submission(
        self,
        db: AsyncSession,
        user_id: int,
        answers: list[AnswerSubmit],
    ) -> dict:
        # Load questions by ids
        question_ids = [a.question_id for a in answers]
        questions_list = await crud_question.get_by_ids(db, ids=question_ids)
        questions_map: dict[int, Question] = {q.id: q for q in questions_list}

        # Accumulate raw category scores
        category_scores: dict[str, float] = {}
        valid_answers: list[AnswerSubmit] = []

        for answer in answers:
            question = questions_map.get(answer.question_id)
            if not question:
                continue
            option_key = str(answer.selected_option_index)
            weights: dict = question.weights.get(option_key, {})
            for category, weight in weights.items():
                category_scores[category] = (
                    category_scores.get(category, 0.0) + float(weight)
                )
            valid_answers.append(answer)

        normalized_scores = self._normalize_scores(category_scores)

        # Persist TestResult
        test_result = await crud_test_result.create(
            db=db,
            user_id=user_id,
            category_scores=normalized_scores,
            total_questions=len(valid_answers),
        )

        # Persist Answers
        for answer in valid_answers:
            await crud_question.create_answer(
                db=db,
                test_result_id=test_result.id,
                question_id=answer.question_id,
                selected_option_index=answer.selected_option_index,
            )

        # Generate and persist recommendations
        recommendations = await self._generate_recommendations(
            db=db,
            user_id=user_id,
            test_result_id=test_result.id,
            normalized_scores=normalized_scores,
        )

        await db.flush()

        return {
            "test_result_id": test_result.id,
            "category_scores": normalized_scores,
            "total_questions": len(valid_answers),
            "completed_at": test_result.completed_at,
            "recommendations": recommendations,
        }

    def _normalize_scores(
        self, raw_scores: dict[str, float]
    ) -> dict[str, float]:
        if not raw_scores:
            return {}
        max_score = max(raw_scores.values()) if raw_scores else 1.0
        if max_score == 0:
            return {k: 0.0 for k in raw_scores}
        return {
            cat: round((score / max_score) * 100, 2)
            for cat, score in raw_scores.items()
        }

    async def _generate_recommendations(
        self,
        db: AsyncSession,
        user_id: int,
        test_result_id: int,
        normalized_scores: dict[str, float],
    ) -> list[dict]:
        all_professions = await crud_profession.get_all_active(db)

        # Score every profession, give small bonus for high demand
        demand_bonus = {"very_high": 5.0, "high": 3.0, "medium": 1.0, "low": 0.0}
        scored: list[tuple] = []
        for prof in all_professions:
            base_score = normalized_scores.get(prof.category_key, 0.0)
            bonus = demand_bonus.get(prof.demand_level, 0.0)
            final_score = min(round(base_score + bonus, 2), 100.0)
            scored.append((prof, final_score))

        scored.sort(key=lambda x: x[1], reverse=True)
        top = scored[: self.TOP_N_RECOMMENDATIONS]

        result_recommendations = []
        for rank, (profession, match_pct) in enumerate(top, start=1):
            rec = await crud_test_result.create_recommendation(
                db=db,
                user_id=user_id,
                test_result_id=test_result_id,
                profession_id=profession.id,
                match_percentage=match_pct,
                rank=rank,
            )
            result_recommendations.append(
                {
                    "id": rec.id,
                    "profession_id": profession.id,
                    "match_percentage": match_pct,
                    "rank": rank,
                    "profession": {
                        "id": profession.id,
                        "title": profession.title,
                        "slug": profession.slug,
                        "category": profession.category,
                        "icon_emoji": profession.icon_emoji,
                        "color_hex": profession.color_hex,
                        "demand_level": profession.demand_level,
                        "salary_min": profession.salary_min,
                        "salary_max": profession.salary_max,
                    },
                    "created_at": rec.created_at,
                }
            )

        return result_recommendations


recommendation_service = RecommendationService()