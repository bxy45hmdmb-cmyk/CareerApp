from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.core.dependencies import get_current_active_user
from app.core.config import settings
from app.models.user import User
import anthropic

router = APIRouter(prefix="/chat", tags=["AI Chat"])

SYSTEM_PROMPT = """Сен CareerApp-тың AI кеңесшісісің. Қазақстандық мектеп оқушыларына (7-11 сынып) мансап пен кәсіптік бағдар бойынша кеңес бересің.

Ережелер:
- Тек қазақ тілінде жауап бер
- Жауаптарың қысқа, нақты және пайдалы болсын (3-5 сөйлем)
- Мамандық, университет, оқу бағыты туралы сұрақтарға жауап бер
- Оқушыны ынталандыр, оң көзқараспен жауап бер
- Тек білім, мансап, дамуға байланысты тақырыптарда кеңес бер
- Басқа тақырыптарда: "Мен тек кәсіптік бағдар бойынша кеңес бере аламын" де
"""


class ChatMessage(BaseModel):
    message: str
    history: list[dict] = []


class ChatResponse(BaseModel):
    reply: str


@router.post("/", response_model=ChatResponse)
async def chat(
    payload: ChatMessage,
    current_user: User = Depends(get_current_active_user),
):
    if not settings.ANTHROPIC_API_KEY:
        raise HTTPException(status_code=503, detail="AI сервисі қол жетімді емес")

    if len(payload.message.strip()) == 0:
        raise HTTPException(status_code=400, detail="Хабарлама бос болмауы керек")

    if len(payload.message) > 1000:
        raise HTTPException(status_code=400, detail="Хабарлама тым ұзын (макс. 1000 символ)")

    try:
        client = anthropic.Anthropic(api_key=settings.ANTHROPIC_API_KEY)

        # Build conversation history
        messages = []
        for msg in payload.history[-10:]:
            role = msg.get("role", "user")
            text = msg.get("text", "")
            if role == "model":
                role = "assistant"
            if role in ("user", "assistant") and text:
                messages.append({"role": role, "content": text})

        # Add current user message
        messages.append({"role": "user", "content": payload.message})

        response = client.messages.create(
            model="claude-haiku-4-5-20251001",
            max_tokens=1024,
            system=SYSTEM_PROMPT,
            messages=messages,
        )

        return ChatResponse(reply=response.content[0].text)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI қатесі: {str(e)}")
