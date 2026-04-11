from fastapi import APIRouter
from app.api.v1 import (
    auth, users, questions,
    professions, test_results,
    recommendations, favorites, universities,
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(users.router)
api_router.include_router(questions.router)
api_router.include_router(professions.router)
api_router.include_router(test_results.router)
api_router.include_router(recommendations.router)
api_router.include_router(favorites.router)
api_router.include_router(universities.router)