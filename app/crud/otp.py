from datetime import datetime, timedelta, timezone
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.otp import OTPCode
from app.core.config import settings


class CRUDOtp:
    async def create(
        self, db: AsyncSession, email: str, code: str, purpose: str
    ) -> OTPCode:
        # Delete old codes for same email+purpose
        await db.execute(
            delete(OTPCode).where(
                OTPCode.email == email, OTPCode.purpose == purpose
            )
        )
        expires_at = datetime.now(timezone.utc) + timedelta(
            minutes=settings.OTP_EXPIRE_MINUTES
        )
        otp = OTPCode(
            email=email,
            code=code,
            purpose=purpose,
            expires_at=expires_at,
        )
        db.add(otp)
        await db.flush()
        return otp

    async def verify(
        self, db: AsyncSession, email: str, code: str, purpose: str
    ) -> bool:
        now = datetime.now(timezone.utc)
        result = await db.execute(
            select(OTPCode).where(
                OTPCode.email == email,
                OTPCode.code == code,
                OTPCode.purpose == purpose,
                OTPCode.is_used == False,
                OTPCode.expires_at > now,
            )
        )
        otp = result.scalar_one_or_none()
        if not otp:
            return False
        otp.is_used = True
        db.add(otp)
        await db.flush()
        return True


crud_otp = CRUDOtp()
