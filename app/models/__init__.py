from app.models.user import User
from app.models.question import Question, Answer
from app.models.profession import Profession, DevelopmentPath
from app.models.test_result import TestResult, Recommendation
from app.models.favorites import Favorite
from app.models.university import University
from app.models.otp import OTPCode

__all__ = [
    "User", "Question", "Answer",
    "Profession", "DevelopmentPath",
    "TestResult", "Recommendation",
    "Favorite", "University", "OTPCode",
]