import re
from pydantic import BaseModel, EmailStr, field_validator


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    sub: str
    type: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str

    model_config = {"json_schema_extra": {
        "example": {
            "email": "student@example.com",
            "password": "SecurePass1!"
        }
    }}


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    grade: int
    school: str | None = None
    city: str | None = None

    @field_validator("grade")
    @classmethod
    def validate_grade(cls, v: int) -> int:
        if v < 7 or v > 11:
            raise ValueError("Сынып 7-ден 11-ге дейін болуы керек")
        return v

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        errors = []
        if len(v) < 7:
            errors.append("кемінде 7 символ болуы керек")
        if not re.search(r"[A-Z]", v):
            errors.append("кемінде 1 бас әріп (A-Z) болуы керек")
        if not re.search(r"\d", v):
            errors.append("кемінде 1 цифр болуы керек")
        if not re.search(r"[!@#$%^&*()_+\-=\[\]{};':\"\\|,.<>/?`~]", v):
            errors.append("кемінде 1 арнайы символ болуы керек (!@#$%^&* т.б.)")
        if errors:
            raise ValueError("Құпиясөз талаптары: " + ", ".join(errors))
        return v

    @field_validator("full_name")
    @classmethod
    def validate_full_name(cls, v: str) -> str:
        v = v.strip()
        if len(v) < 2:
            raise ValueError("Аты-жөні кемінде 2 символдан тұруы керек")
        return v

    model_config = {"json_schema_extra": {
        "example": {
            "email": "student@example.com",
            "password": "SecurePass1!",
            "full_name": "Айдана Сейтқали",
            "grade": 9,
            "school": "НЗМ №1",
            "city": "Астана"
        }
    }}


# ── OTP / Verification ────────────────────────────────────────────────────────

class VerifyEmailRequest(BaseModel):
    email: EmailStr
    code: str


class ResendVerificationRequest(BaseModel):
    email: EmailStr


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    code: str
    new_password: str

    @field_validator("new_password")
    @classmethod
    def validate_new_password(cls, v: str) -> str:
        errors = []
        if len(v) < 7:
            errors.append("кемінде 7 символ")
        if not re.search(r"[A-Z]", v):
            errors.append("кемінде 1 бас әріп")
        if not re.search(r"\d", v):
            errors.append("кемінде 1 цифр")
        if not re.search(r"[!@#$%^&*()_+\-=\[\]{};':\"\\|,.<>/?`~]", v):
            errors.append("кемінде 1 арнайы символ")
        if errors:
            raise ValueError("Құпиясөз талаптары: " + ", ".join(errors))
        return v


class MessageResponse(BaseModel):
    message: str
