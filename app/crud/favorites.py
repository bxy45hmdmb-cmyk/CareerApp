from typing import Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.models.favorites import Favorite


class CRUDFavorite:
    async def get_user_favorites(
        self, db: AsyncSession, user_id: int
    ) -> list[Favorite]:
        result = await db.execute(
            select(Favorite)
            .where(Favorite.user_id == user_id)
            .options(selectinload(Favorite.profession))
            .order_by(Favorite.created_at.desc())
        )
        return list(result.scalars().all())

    async def get(
        self, db: AsyncSession, user_id: int, profession_id: int
    ) -> Optional[Favorite]:
        result = await db.execute(
            select(Favorite).where(
                Favorite.user_id == user_id,
                Favorite.profession_id == profession_id,
            )
        )
        return result.scalar_one_or_none()

    async def add(
        self, db: AsyncSession, user_id: int, profession_id: int
    ) -> Favorite:
        existing = await self.get(db, user_id=user_id, profession_id=profession_id)
        if existing:
            return existing
        fav = Favorite(user_id=user_id, profession_id=profession_id)
        db.add(fav)
        await db.flush()
        await db.refresh(fav)
        return fav

    async def remove(
        self, db: AsyncSession, user_id: int, profession_id: int
    ) -> bool:
        result = await db.execute(
            delete(Favorite).where(
                Favorite.user_id == user_id,
                Favorite.profession_id == profession_id,
            )
        )
        return result.rowcount > 0

    async def is_favorite(
        self, db: AsyncSession, user_id: int, profession_id: int
    ) -> bool:
        existing = await self.get(db, user_id=user_id, profession_id=profession_id)
        return existing is not None

    async def count(self, db: AsyncSession, user_id: int) -> int:
        result = await db.execute(
            select(Favorite).where(Favorite.user_id == user_id)
        )
        return len(result.scalars().all())


crud_favorite = CRUDFavorite()