from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.models.profession import Profession, DevelopmentPath, ProfessionTranslation
from app.models.university import University


class CRUDProfession:
    async def get(
        self, db: AsyncSession, id: int, load_path: bool = False
    ) -> Optional[Profession]:
        query = select(Profession).where(Profession.id == id)
        if load_path:
            query = query.options(selectinload(Profession.development_path))
        result = await db.execute(query)
        return result.scalar_one_or_none()

    async def get_by_slug(
        self, db: AsyncSession, slug: str
    ) -> Optional[Profession]:
        result = await db.execute(
            select(Profession)
            .where(Profession.slug == slug)
            .options(selectinload(Profession.development_path))
        )
        return result.scalar_one_or_none()

    async def get_multi(
        self,
        db: AsyncSession,
        skip: int = 0,
        limit: int = 50,
        category: str | None = None,
    ) -> list[Profession]:
        query = select(Profession).where(Profession.is_active == True)
        if category:
            query = query.where(Profession.category == category)
        query = query.offset(skip).limit(limit)
        result = await db.execute(query)
        return list(result.scalars().all())

    async def get_by_category_keys(
        self, db: AsyncSession, category_keys: list[str]
    ) -> list[Profession]:
        result = await db.execute(
            select(Profession)
            .where(Profession.category_key.in_(category_keys))
            .where(Profession.is_active == True)
            .options(selectinload(Profession.development_path))
        )
        return list(result.scalars().all())

    async def get_all_active(self, db: AsyncSession) -> list[Profession]:
        result = await db.execute(
            select(Profession).where(Profession.is_active == True)
        )
        return list(result.scalars().all())

    async def get_development_path(
        self, db: AsyncSession, profession_id: int
    ) -> Optional[DevelopmentPath]:
        result = await db.execute(
            select(DevelopmentPath).where(
                DevelopmentPath.profession_id == profession_id
            )
        )
        return result.scalar_one_or_none()

    async def get_universities_for_profession(
        self, db: AsyncSession, category_key: str
    ) -> list[University]:
        result = await db.execute(select(University))
        all_unis = list(result.scalars().all())
        return [u for u in all_unis if category_key in (u.category_keys or [])]


    async def get_translation(
        self, db: AsyncSession, profession_id: int, lang: str
    ) -> Optional[ProfessionTranslation]:
        result = await db.execute(
            select(ProfessionTranslation).where(
                ProfessionTranslation.profession_id == profession_id,
                ProfessionTranslation.lang == lang,
            )
        )
        return result.scalar_one_or_none()


crud_profession = CRUDProfession()