import random
import string
import aiosmtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings


def generate_otp(length: int = 6) -> str:
    return "".join(random.choices(string.digits, k=length))


async def send_email(to: str, subject: str, html_body: str) -> bool:
    if not settings.EMAIL_USER or not settings.EMAIL_PASSWORD:
        # Dev mode: print to console
        print(f"\n[EMAIL] To: {to}\nSubject: {subject}\n{html_body}\n")
        return True
    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = f"{settings.EMAIL_FROM_NAME} <{settings.EMAIL_USER}>"
        msg["To"] = to
        msg.attach(MIMEText(html_body, "html", "utf-8"))

        await aiosmtplib.send(
            msg,
            hostname=settings.EMAIL_HOST,
            port=settings.EMAIL_PORT,
            username=settings.EMAIL_USER,
            password=settings.EMAIL_PASSWORD,
            use_tls=settings.EMAIL_USE_TLS,
            start_tls=settings.EMAIL_USE_STARTTLS,
        )
        return True
    except Exception as e:
        print(f"[EMAIL ERROR] {e}")
        return False


async def send_verification_email(to: str, full_name: str, code: str) -> bool:
    subject = "CareerApp — Email растау коды"
    html = f"""
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:32px;
                background:#f8f9ff;border-radius:16px;">
      <h2 style="color:#6C63FF;margin-bottom:8px;">Сәлем, {full_name}! 👋</h2>
      <p style="color:#444;font-size:15px;margin-bottom:24px;">
        CareerApp-қа тіркелу үшін төмендегі кодты енгізіңіз:
      </p>
      <div style="background:#6C63FF;border-radius:12px;padding:24px;text-align:center;">
        <span style="color:#fff;font-size:40px;font-weight:800;letter-spacing:10px;">
          {code}
        </span>
      </div>
      <p style="color:#888;font-size:13px;margin-top:20px;">
        Код 10 минут бойы жарамды. Егер сіз тіркелмеген болсаңыз, хабарды елемеңіз.
      </p>
    </div>
    """
    return await send_email(to, subject, html)


async def send_reset_password_email(to: str, code: str) -> bool:
    subject = "CareerApp — Құпиясөзді қалпына келтіру"
    html = f"""
    <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;padding:32px;
                background:#f8f9ff;border-radius:16px;">
      <h2 style="color:#6C63FF;margin-bottom:8px;">Құпиясөзді қалпына келтіру 🔐</h2>
      <p style="color:#444;font-size:15px;margin-bottom:24px;">
        Жаңа құпиясөз орнату үшін осы кодты пайдаланыңыз:
      </p>
      <div style="background:#FF6B6B;border-radius:12px;padding:24px;text-align:center;">
        <span style="color:#fff;font-size:40px;font-weight:800;letter-spacing:10px;">
          {code}
        </span>
      </div>
      <p style="color:#888;font-size:13px;margin-top:20px;">
        Код 10 минут бойы жарамды. Сіз бұл сұраныс жасамаған болсаңыз, хабарды елемеңіз.
      </p>
    </div>
    """
    return await send_email(to, subject, html)
