from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.university import University


class CRUDUniversity:
    async def get_all(self, db: AsyncSession) -> list[University]:
        result = await db.execute(
            select(University).order_by(University.rating.desc(), University.name)
        )
        return list(result.scalars().all())

    async def get_by_category_key(
        self, db: AsyncSession, category_key: str
    ) -> list[University]:
        result = await db.execute(select(University))
        all_unis = list(result.scalars().all())
        # Filter where category_key appears in the JSON list
        return [u for u in all_unis if category_key in (u.category_keys or [])]

    async def get_by_city(
        self, db: AsyncSession, city: str
    ) -> list[University]:
        result = await db.execute(
            select(University).where(University.city == city)
        )
        return list(result.scalars().all())


crud_university = CRUDUniversity()