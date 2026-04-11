# CareerApp — Кәсіптік Бағдар

Мектеп оқушыларына арналған кәсіптік бағдар беру жүйесі (7-11 сыныптар).

## Технологиялар

- **Backend**: FastAPI + SQLite (aiosqlite) + JWT аутентификация
- **Mobile**: Flutter (Android)
- **Email**: Gmail SMTP (OTP кодтары)

## Жылдам бастау (Quick Start)

### 1. Репозиторийді клондау

```bash
git clone https://github.com/YOUR_USERNAME/CareerApp.git
cd CareerApp
```

### 2. Backend орнату

```bash
# Python виртуалды ортасын жасау
python -m venv venv

# Активтендіру
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# Тәуелділіктерді орнату
pip install -r requirements.txt
```

### 3. .env файлын баптау

```bash
copy .env.example .env   # Windows
cp .env.example .env     # Mac/Linux
```

`.env` файлын ашып толтырыңыз:
- `SECRET_KEY` — кез келген ұзын кездейсоқ жол
- `EMAIL_USER` — Gmail мекен-жайы
- `EMAIL_PASSWORD` — Gmail App Password

### 4. Дерекқорды инициализациялау

```bash
python seed.py
```

### 5. Серверді іске қосу

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8003 --reload
```

API документациясы: http://localhost:8003/docs

---

### 6. Flutter қолданбасын орнату

**Алдын ала қажет:** Flutter SDK 3.0+, Android Studio

```bash
cd mobile
flutter pub get
```

### 7. IP мекен-жайын өзгерту

`mobile/lib/core/api_service.dart` файлынан `baseUrl` мәнін өзгертіңіз:

```dart
static const String baseUrl = 'http://YOUR_PC_IP:8003/api/v1';
```

IP табу: Windows — `ipconfig`, Mac/Linux — `ifconfig`

### 8. Қолданбаны іске қосу

```bash
flutter run
```

### APK жасау

```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Жоба құрылымы

```
CareerApp/
├── app/                    # FastAPI backend
│   ├── api/v1/            # API эндпоинттері
│   ├── core/              # Конфигурация, security, email
│   ├── crud/              # Дерекқор операциялары
│   ├── models/            # SQLAlchemy модельдері
│   └── schemas/           # Pydantic схемалары
├── mobile/                 # Flutter қолданба
│   └── lib/
│       ├── core/          # API service, token storage, lang
│       ├── l10n/          # Локализация (қазақша/орысша)
│       ├── screens/       # Экрандар
│       ├── theme/         # Жасыл тема
│       └── widgets/       # Виджеттер
├── .env.example           # Environment шаблоны
├── requirements.txt       # Python тәуелділіктері
└── seed.py                # Дерекқорды толтыру
```

## Функциялар

- JWT аутентификация (тіркелу/кіру/шығу)
- Email OTP верификация
- Құпиясөзді қалпына келтіру
- Кәсіптік тест (30 сұрақ)
- Мамандық ұсыныстары
- Таңдаулы мамандықтар
- Профиль өңдеу + аватар
- Қараңғы/жарық тема
- Қазақша/орысша тіл
