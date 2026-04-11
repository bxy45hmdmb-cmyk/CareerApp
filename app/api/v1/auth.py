from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.dependencies import get_db
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_password_hash,
)
from app.core.config import settings
from app.core.email_service import (
    generate_otp,
    send_verification_email,
    send_reset_password_email,
)
from app.crud.user import crud_user
from app.crud.otp import crud_otp
from app.schemas.auth import (
    LoginRequest,
    RegisterRequest,
    RefreshTokenRequest,
    TokenResponse,
    VerifyEmailRequest,
    ResendVerificationRequest,
    ForgotPasswordRequest,
    ResetPasswordRequest,
    MessageResponse,
)
from app.schemas.user import UserCreate, UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/register",
    response_model=MessageResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new student account",
)
async def register(
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    existing = await crud_user.get_by_email(db, email=payload.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Бұл email-мен аккаунт бұрын тіркелген",
        )

    user_in = UserCreate(
        email=payload.email,
        password=payload.password,
        full_name=payload.full_name,
        grade=payload.grade,
        school=payload.school,
        city=payload.city,
    )
    user = await crud_user.create(db, obj_in=user_in)

    # Send verification OTP
    code = generate_otp()
    await crud_otp.create(db, email=payload.email, code=code, purpose="email_verification")
    await db.commit()

    await send_verification_email(
        to=payload.email,
        full_name=payload.full_name,
        code=code,
    )

    return MessageResponse(message="Тіркелу сәтті аяқталды. Email-ға растау коды жіберілді.")


@router.post(
    "/verify-email",
    response_model=TokenResponse,
    summary="Verify email with OTP code",
)
async def verify_email(
    payload: VerifyEmailRequest,
    db: AsyncSession = Depends(get_db),
):
    valid = await crud_otp.verify(
        db, email=payload.email, code=payload.code, purpose="email_verification"
    )
    if not valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Код қате немесе мерзімі өтіп кеткен",
        )

    user = await crud_user.get_by_email(db, email=payload.email)
    if not user:
        raise HTTPException(status_code=404, detail="Пайдаланушы табылмады")

    user.is_verified = True
    db.add(user)
    await db.commit()

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)
    return TokenResponse(access_token=access_token, refresh_token=refresh_token)


@router.post(
    "/resend-verification",
    response_model=MessageResponse,
    summary="Resend email verification code",
)
async def resend_verification(
    payload: ResendVerificationRequest,
    db: AsyncSession = Depends(get_db),
):
    user = await crud_user.get_by_email(db, email=payload.email)
    if not user:
        raise HTTPException(status_code=404, detail="Пайдаланушы табылмады")
    if user.is_verified:
        raise HTTPException(status_code=400, detail="Email бұрын расталған")

    code = generate_otp()
    await crud_otp.create(db, email=payload.email, code=code, purpose="email_verification")
    await db.commit()

    await send_verification_email(
        to=payload.email, full_name=user.full_name, code=code
    )
    return MessageResponse(message="Растау коды қайта жіберілді")


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Login and receive JWT tokens",
)
async def login(
    payload: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    user = await crud_user.authenticate(
        db, email=payload.email, password=payload.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email немесе құпиясөз қате",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Аккаунт өшірілген",
        )
    if not user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Email расталмаған. Алдымен email-ды растаңыз.",
        )

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)
    return TokenResponse(access_token=access_token, refresh_token=refresh_token)


@router.post(
    "/forgot-password",
    response_model=MessageResponse,
    summary="Send password reset OTP",
)
async def forgot_password(
    payload: ForgotPasswordRequest,
    db: AsyncSession = Depends(get_db),
):
    user = await crud_user.get_by_email(db, email=payload.email)
    # Always return success to prevent email enumeration
    if user and user.is_active:
        code = generate_otp()
        await crud_otp.create(
            db, email=payload.email, code=code, purpose="password_reset"
        )
        await db.commit()
        await send_reset_password_email(to=payload.email, code=code)

    return MessageResponse(
        message="Егер email тіркелген болса, қалпына келтіру коды жіберілді"
    )


@router.post(
    "/reset-password",
    response_model=MessageResponse,
    summary="Reset password with OTP code",
)
async def reset_password(
    payload: ResetPasswordRequest,
    db: AsyncSession = Depends(get_db),
):
    valid = await crud_otp.verify(
        db, email=payload.email, code=payload.code, purpose="password_reset"
    )
    if not valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Код қате немесе мерзімі өтіп кеткен",
        )

    user = await crud_user.get_by_email(db, email=payload.email)
    if not user:
        raise HTTPException(status_code=404, detail="Пайдаланушы табылмады")

    user.hashed_password = get_password_hash(payload.new_password)
    db.add(user)
    await db.commit()

    return MessageResponse(message="Құпиясөз сәтті өзгертілді")


@router.post(
    "/refresh",
    response_model=TokenResponse,
    summary="Refresh access token using refresh token",
)
async def refresh_token(
    payload: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
):
    token_data = decode_token(payload.refresh_token)
    if not token_data or token_data.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Жарамсыз немесе мерзімі өткен refresh token",
        )

    user_id = int(token_data.get("sub"))
    user = await crud_user.get(db, id=user_id)
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Пайдаланушы табылмады немесе өшірілген",
        )

    new_access = create_access_token(subject=user.id)
    new_refresh = create_refresh_token(subject=user.id)
    return TokenResponse(access_token=new_access, refresh_token=new_refresh)
