from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import get_db, get_current_active_user
from app.crud.profession import crud_profession
from app.crud.university import crud_university
from app.schemas.profession import (
    ProfessionResponse,
    ProfessionListResponse,
    DevelopmentPathResponse,
)
from app.models.user import User

router = APIRouter(prefix="/professions", tags=["Professions"])


def _apply_translation(p, t):
    """Overwrite profession fields with translation data."""
    p.title = t.title
    p.description = t.description
    p.category = t.category
    p.required_skills = t.required_skills
    p.future_opportunities = t.future_opportunities
    return p


@router.get("/", response_model=list[ProfessionListResponse])
async def list_professions(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    category: str | None = Query(None),
    lang: str = Query("kk"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    profs = await crud_profession.get_multi(db, skip=skip, limit=limit, category=category)
    if lang != "kk":
        for p in profs:
            t = await crud_profession.get_translation(db, p.id, lang)
            if t:
                db.expunge(p)
                _apply_translation(p, t)
    return profs


@router.get("/high-demand", response_model=list[ProfessionListResponse])
async def get_high_demand_professions(
    limit: int = Query(15, ge=1, le=50),
    lang: str = Query("kk"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    all_profs = await crud_profession.get_all_active(db)
    demand_order = {"very_high": 0, "high": 1, "medium": 2, "low": 3}
    sorted_profs = sorted(all_profs, key=lambda p: demand_order.get(p.demand_level, 9))[:limit]
    if lang != "kk":
        for p in sorted_profs:
            t = await crud_profession.get_translation(db, p.id, lang)
            if t:
                db.expunge(p)
                _apply_translation(p, t)
    return sorted_profs


@router.get("/{slug}", response_model=ProfessionResponse)
async def get_profession(
    slug: str,
    lang: str = Query("kk"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    profession = await crud_profession.get_by_slug(db, slug=slug)
    if not profession:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Profession '{slug}' not found",
        )
    if lang != "kk":
        t = await crud_profession.get_translation(db, profession.id, lang)
        if t:
            db.expunge(profession)
            _apply_translation(profession, t)
    universities = await crud_profession.get_universities_for_profession(
        db, category_key=profession.category_key
    )
    resp = ProfessionResponse.model_validate(profession)
    resp.universities = universities
    return resp


@router.get("/{slug}/development-path", response_model=DevelopmentPathResponse)
async def get_development_path(
    slug: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    profession = await crud_profession.get_by_slug(db, slug=slug)
    if not profession:
        raise HTTPException(status_code=404, detail="Profession not found")
    path = await crud_profession.get_development_path(db, profession_id=profession.id)
    if not path:
        raise HTTPException(status_code=404, detail="Development path not found")
    return path
