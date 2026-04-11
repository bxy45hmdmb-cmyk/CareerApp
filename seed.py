"""
Full seed: questions + professions + development paths + universities
Run: python seed.py
"""
import asyncio
from sqlalchemy import select
from app.database import async_session_maker, create_all_tables
from app.models.question import Question
from app.models.profession import Profession, DevelopmentPath
from app.models.university import University

# ── Questions (same as before, already in original seed) ─────────────────────
QUESTIONS = [
    {
        "text": "Бос уақытыңда не істегенді ұнатасың?",
        "category": "interest", "order": 1,
        "options": [
            "💻 Компьютерде бағдарлама немесе ойын жасау",
            "🎨 Сурет салу, дизайн жасау",
            "📚 Кітап оқу, жаңа нәрселер үйрену",
            "🤝 Адамдармен сөйлесу, жаңа достар табу",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 0, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 1, "engineering": 0, "medicine": 0, "art": 3, "law": 0, "business": 1},
            "2": {"technology": 1, "engineering": 1, "medicine": 2, "art": 1, "law": 2, "business": 1},
            "3": {"technology": 0, "engineering": 0, "medicine": 2, "art": 1, "law": 2, "business": 3},
        },
    },
    {
        "text": "Мектепте қай пән саған ең жеңіл берілетін?",
        "category": "subject", "order": 2,
        "options": [
            "➗ Математика және физика",
            "🧬 Биология және химия",
            "🗣️ Тіл пәндері (қазақ, ағылшын)",
            "🏛️ Тарих және география",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 1, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 1, "engineering": 1, "medicine": 3, "art": 0, "law": 0, "business": 0},
            "2": {"technology": 0, "engineering": 0, "medicine": 1, "art": 2, "law": 3, "business": 2},
            "3": {"technology": 0, "engineering": 0, "medicine": 0, "art": 2, "law": 2, "business": 3},
        },
    },
    {
        "text": "Топтық жобада сен қандай рөлде болғанды ұнатасың?",
        "category": "skill", "order": 3,
        "options": [
            "🎯 Жетекші (лидер)",
            "🔬 Зерттеуші",
            "✏️ Жасаушы (іс жүзіне асырушы)",
            "🤝 Ұйымдастырушы",
        ],
        "weights": {
            "0": {"technology": 1, "engineering": 1, "medicine": 1, "art": 1, "law": 2, "business": 3},
            "1": {"technology": 2, "engineering": 2, "medicine": 3, "art": 1, "law": 1, "business": 1},
            "2": {"technology": 3, "engineering": 3, "medicine": 1, "art": 3, "law": 1, "business": 1},
            "3": {"technology": 1, "engineering": 1, "medicine": 2, "art": 1, "law": 2, "business": 3},
        },
    },
    {
        "text": "Болашақта не жасағың келеді?",
        "category": "interest", "order": 4,
        "options": [
            "🌍 Әлемді өзгертетін технология жасағым келеді",
            "❤️ Адамдарға көмектескім, емдегім келеді",
            "🎭 Өнер, дизайн, музыкамен айналысқым келеді",
            "📊 Бизнес ашып, экономикаға үлес қосқым келеді",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 0, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 3, "art": 1, "law": 1, "business": 0},
            "2": {"technology": 1, "engineering": 0, "medicine": 0, "art": 3, "law": 0, "business": 1},
            "3": {"technology": 1, "engineering": 1, "medicine": 0, "art": 0, "law": 2, "business": 3},
        },
    },
    {
        "text": "Қандай жұмыс ортасы саған ыңғайлы?",
        "category": "skill", "order": 5,
        "options": [
            "🏠 Үйден қашықтан жұмыс (Remote)",
            "🏢 Үлкен командада офисте",
            "🏥 Адамдармен тікелей жұмыс",
            "🔬 Зертхана немесе ғылыми орта",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 1, "medicine": 0, "art": 2, "law": 0, "business": 1},
            "1": {"technology": 1, "engineering": 2, "medicine": 1, "art": 1, "law": 2, "business": 3},
            "2": {"technology": 0, "engineering": 0, "medicine": 3, "art": 1, "law": 3, "business": 2},
            "3": {"technology": 2, "engineering": 3, "medicine": 2, "art": 0, "law": 1, "business": 0},
        },
    },
    {
        "text": "Мәселені шешкенде қалай ойлайсың?",
        "category": "skill", "order": 6,
        "options": [
            "🧮 Логика мен сандар арқылы",
            "🎨 Шығармашылық тәсілмен",
            "📖 Зерттеп, ақпарат жинап",
            "💬 Басқалармен ақылдасып",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 1, "art": 0, "law": 2, "business": 2},
            "1": {"technology": 1, "engineering": 1, "medicine": 0, "art": 3, "law": 1, "business": 2},
            "2": {"technology": 2, "engineering": 2, "medicine": 3, "art": 1, "law": 3, "business": 1},
            "3": {"technology": 0, "engineering": 0, "medicine": 2, "art": 1, "law": 2, "business": 3},
        },
    },
    {
        "text": "Саған қай жетістік маңыздырақ?",
        "category": "interest", "order": 7,
        "options": [
            "💡 Жаңа нәрсе ойлап табу",
            "🏆 Байқауларда жеңіске жету",
            "❤️ Адамдарға пайдалы болу",
            "💰 Жоғары табыс табу",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 1, "art": 2, "law": 0, "business": 1},
            "1": {"technology": 2, "engineering": 2, "medicine": 1, "art": 2, "law": 2, "business": 2},
            "2": {"technology": 0, "engineering": 0, "medicine": 3, "art": 1, "law": 2, "business": 1},
            "3": {"technology": 1, "engineering": 1, "medicine": 1, "art": 0, "law": 2, "business": 3},
        },
    },
    {
        "text": "Қай олимпиадаға немесе байқауға қатысқың келер еді?",
        "category": "subject", "order": 8,
        "options": [
            "🖥️ Информатика олимпиадасы",
            "🔭 Физика немесе математика олимпиадасы",
            "🎨 Шығармашылық байқаулар",
            "🗣️ Пікірсайыс (дебаттар)",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 1, "medicine": 0, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 2, "engineering": 3, "medicine": 1, "art": 0, "law": 0, "business": 0},
            "2": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 1, "business": 2},
            "3": {"technology": 0, "engineering": 0, "medicine": 1, "art": 1, "law": 3, "business": 3},
        },
    },
    {
        "text": "Саған қай жоба қызықтырақ болар еді?",
        "category": "interest", "order": 9,
        "options": [
            "💻 Мобильді қосымша немесе веб-сайт жасау",
            "🏗️ Ғимарат немесе механикалық конструкция жобалау",
            "❤️ Адамдарды емдейтін медициналық зерттеу",
            "📊 Бизнес жоспар немесе стартап ашу",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 1, "medicine": 0, "art": 1, "law": 0, "business": 1},
            "1": {"technology": 1, "engineering": 3, "medicine": 0, "art": 1, "law": 0, "business": 0},
            "2": {"technology": 0, "engineering": 0, "medicine": 3, "art": 0, "law": 0, "business": 0},
            "3": {"technology": 1, "engineering": 0, "medicine": 0, "art": 0, "law": 1, "business": 3},
        },
    },
    {
        "text": "Физика пәнінен қай тақырып сені қызықтырады?",
        "category": "subject", "order": 10,
        "options": [
            "⚡ Электр және электроника",
            "🚀 Механика және қозғалыс заңдары",
            "🌊 Термодинамика және жылу алмасу",
            "🌌 Астрофизика және ғарыш",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 0, "art": 0, "law": 0, "business": 0},
            "1": {"technology": 1, "engineering": 3, "medicine": 0, "art": 0, "law": 0, "business": 0},
            "2": {"technology": 1, "engineering": 3, "medicine": 1, "art": 0, "law": 0, "business": 0},
            "3": {"technology": 2, "engineering": 2, "medicine": 0, "art": 1, "law": 0, "business": 0},
        },
    },
    {
        "text": "Адамдарды қандай жетістігің үшін таныйды деп ойлайсың?",
        "category": "skill", "order": 11,
        "options": [
            "🚀 Тамаша технология немесе өнертабыс жасадым",
            "🎨 Керемет өнер туындысы шығардым",
            "⚖️ Қоғамға әділдік орнатуға үлес қостым",
            "💰 Табысты бизнес жүргіздім, жұмыс бердім",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 1, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 0, "business": 1},
            "2": {"technology": 0, "engineering": 0, "medicine": 1, "art": 0, "law": 3, "business": 1},
            "3": {"technology": 1, "engineering": 1, "medicine": 0, "art": 0, "law": 1, "business": 3},
        },
    },
    {
        "text": "Жаз/қыс демалысыңда не жасайсың?",
        "category": "interest", "order": 12,
        "options": [
            "🖥️ Бағдарламалау немесе жаңа технология үйренемін",
            "🎭 Театр, кино немесе музыкамен айналысамын",
            "🏆 Спорт, жарыс немесе іс-шара ұйымдастырамын",
            "🔭 Ғылыми кітап оқып, зерттеу жасаймын",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 0, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 1, "business": 1},
            "2": {"technology": 0, "engineering": 1, "medicine": 1, "art": 1, "law": 1, "business": 3},
            "3": {"technology": 2, "engineering": 2, "medicine": 3, "art": 0, "law": 1, "business": 0},
        },
    },
    {
        "text": "Маңызды шешім қабылдар алдында не жасайсың?",
        "category": "skill", "order": 13,
        "options": [
            "📊 Деректерді жинап, мұқият талдайсың",
            "🤝 Достарыңмен немесе отбасыңмен ақылдасасың",
            "🖊️ Артықшылықтар мен кемшіліктерін жазасың",
            "💡 Интуицияңа сенесің",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 2, "art": 0, "law": 2, "business": 2},
            "1": {"technology": 0, "engineering": 0, "medicine": 2, "art": 1, "law": 2, "business": 3},
            "2": {"technology": 1, "engineering": 1, "medicine": 1, "art": 0, "law": 3, "business": 2},
            "3": {"technology": 1, "engineering": 1, "medicine": 1, "art": 3, "law": 0, "business": 1},
        },
    },
    {
        "text": "Заңдар мен ережелер туралы не ойлайсың?",
        "category": "interest", "order": 14,
        "options": [
            "⚖️ Заңдар адамдарды қорғауы керек, мен оны өзгертгім келеді",
            "💻 Технологиялық заңнамалар маңызды",
            "🏥 Медициналық этика мен заңдар өте күрделі",
            "💼 Бизнес заңдарын білу кәсіпкерге қажет",
        ],
        "weights": {
            "0": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 3, "business": 1},
            "1": {"technology": 2, "engineering": 1, "medicine": 0, "art": 0, "law": 2, "business": 1},
            "2": {"technology": 0, "engineering": 0, "medicine": 2, "art": 0, "law": 2, "business": 0},
            "3": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 2, "business": 3},
        },
    },
    {
        "text": "Химия пәнінен не үйренгенді ұнатасың?",
        "category": "subject", "order": 15,
        "options": [
            "🧪 Лабораториялық тәжірибелер жасау",
            "💊 Фармакология — дәрі-дәрмек туралы",
            "🔋 Электрохимия және материалтану",
            "🌿 Органикалық химия мен табиғи заттар",
        ],
        "weights": {
            "0": {"technology": 1, "engineering": 2, "medicine": 2, "art": 0, "law": 0, "business": 0},
            "1": {"technology": 0, "engineering": 0, "medicine": 3, "art": 0, "law": 0, "business": 0},
            "2": {"technology": 2, "engineering": 3, "medicine": 1, "art": 0, "law": 0, "business": 0},
            "3": {"technology": 0, "engineering": 1, "medicine": 2, "art": 1, "law": 0, "business": 0},
        },
    },
    {
        "text": "Жаңа адаммен таныссаң, не туралы сұрайсың?",
        "category": "skill", "order": 16,
        "options": [
            "💻 Қандай технологиялармен жұмыс жасайсың?",
            "🎨 Хобби мен шығармашылығың туралы айтшы",
            "💼 Қандай бизнес немесе жобаң бар?",
            "📚 Оқыған немесе зерттеген нәрселерің туралы",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 1, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 1, "business": 1},
            "2": {"technology": 1, "engineering": 0, "medicine": 0, "art": 0, "law": 1, "business": 3},
            "3": {"technology": 2, "engineering": 2, "medicine": 3, "art": 1, "law": 2, "business": 1},
        },
    },
    {
        "text": "Сен қандай жауапкершілік алғанды ұнатасың?",
        "category": "skill", "order": 17,
        "options": [
            "🔧 Техникалық жүйенің жұмысы үшін",
            "👥 Команда немесе топ мүшелері үшін",
            "📋 Жоба немесе процестің нәтижесі үшін",
            "🎨 Шығармашылық жоба сапасы үшін",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 1, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 1, "medicine": 2, "art": 1, "law": 2, "business": 3},
            "2": {"technology": 1, "engineering": 1, "medicine": 1, "art": 0, "law": 2, "business": 3},
            "3": {"technology": 1, "engineering": 0, "medicine": 0, "art": 3, "law": 0, "business": 1},
        },
    },
    {
        "text": "Ғылым мен технологияның қай жаңалығы сені қуантады?",
        "category": "interest", "order": 18,
        "options": [
            "🤖 Жасанды интеллект пен машиналық оқыту",
            "🧬 Гендік инженерия мен биотехнология",
            "🌱 Жасыл энергия мен экологиялық шешімдер",
            "🌍 Космос зерттеулері мен ғарышты игеру",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 1, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 2, "engineering": 1, "medicine": 3, "art": 0, "law": 0, "business": 0},
            "2": {"technology": 1, "engineering": 3, "medicine": 1, "art": 1, "law": 1, "business": 2},
            "3": {"technology": 2, "engineering": 3, "medicine": 0, "art": 1, "law": 0, "business": 0},
        },
    },
    {
        "text": "Математикада қай тақырыпты жақсы көресің?",
        "category": "subject", "order": 19,
        "options": [
            "📐 Геометрия мен кеңістіктік ойлау",
            "📊 Статистика мен ықтималдық теориясы",
            "🔢 Алгебра мен теңдеулер жүйесі",
            "∫ Математикалық талдау (интеграл, туынды)",
        ],
        "weights": {
            "0": {"technology": 1, "engineering": 3, "medicine": 0, "art": 2, "law": 0, "business": 0},
            "1": {"technology": 2, "engineering": 1, "medicine": 2, "art": 0, "law": 1, "business": 3},
            "2": {"technology": 3, "engineering": 2, "medicine": 1, "art": 0, "law": 1, "business": 1},
            "3": {"technology": 3, "engineering": 3, "medicine": 1, "art": 0, "law": 0, "business": 1},
        },
    },
    {
        "text": "Сен жасаған жұмыс туралы пікір алсаң...",
        "category": "skill", "order": 20,
        "options": [
            "📝 Жазбаша егжей-тегжейлі пікір сұраймын",
            "💬 Тікелей сөйлесіп, пікір алғанды ұнатамын",
            "📊 Сандық нәтиже мен метрикалар жеткілікті",
            "🎨 Шығармашылық бостандық берілсе жеткілікті",
        ],
        "weights": {
            "0": {"technology": 1, "engineering": 1, "medicine": 2, "art": 1, "law": 3, "business": 2},
            "1": {"technology": 0, "engineering": 1, "medicine": 3, "art": 2, "law": 2, "business": 3},
            "2": {"technology": 3, "engineering": 2, "medicine": 1, "art": 0, "law": 1, "business": 2},
            "3": {"technology": 1, "engineering": 1, "medicine": 0, "art": 3, "law": 0, "business": 1},
        },
    },
    {
        "text": "Тарих пәнінен қай кезең сені қызықтырады?",
        "category": "subject", "order": 21,
        "options": [
            "🏛️ Ежелгі өркениеттер мен мәдениет",
            "⚔️ Соғыстар мен саяси төңкерістер",
            "🔭 Ғылыми революциялар мен өнертабыстар",
            "💰 Экономикалық дамулар мен сауда жолдары",
        ],
        "weights": {
            "0": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 2, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 1, "law": 3, "business": 2},
            "2": {"technology": 2, "engineering": 2, "medicine": 2, "art": 1, "law": 0, "business": 0},
            "3": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 1, "business": 3},
        },
    },
    {
        "text": "Адамға кеңес берген кезде...",
        "category": "skill", "order": 22,
        "options": [
            "🔍 Фактілер мен зерттеулерге негіздеп айтамын",
            "❤️ Сезімдерін түсініп, эмпатиямен жақындаймын",
            "📋 Нақты жоспар мен қадамдар ұсынамын",
            "⚖️ Заңдық немесе этикалық тұрғыдан бағалаймын",
        ],
        "weights": {
            "0": {"technology": 2, "engineering": 2, "medicine": 2, "art": 0, "law": 2, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 3, "art": 2, "law": 1, "business": 1},
            "2": {"technology": 1, "engineering": 2, "medicine": 1, "art": 0, "law": 1, "business": 3},
            "3": {"technology": 0, "engineering": 0, "medicine": 1, "art": 0, "law": 3, "business": 1},
        },
    },
    {
        "text": "Ағылшын тілін қалай пайдаланасың?",
        "category": "subject", "order": 23,
        "options": [
            "💻 Техникалық құжаттамалар мен IT материалдарды оқу",
            "🎬 Фильм, музыка, мәдени контент тұтыну",
            "📰 Жаңалықтар мен заңдық мәтіндер оқу",
            "🤝 Халықаралық бизнес коммуникация жүргізу",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 1, "art": 0, "law": 0, "business": 0},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 1, "business": 1},
            "2": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 3, "business": 1},
            "3": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 1, "business": 3},
        },
    },
    {
        "text": "Сен мектепте немесе үйде жоба жасадың ба? Қандай?",
        "category": "skill", "order": 24,
        "options": [
            "🖥️ Сайт, бот немесе бағдарлама жаздым",
            "🎨 Сурет, бейне немесе музыка жасадым",
            "🤝 Іс-шара ұйымдастырдым немесе волонтер болдым",
            "💡 Бизнес идея немесе кіші сауда жасадым",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 0, "art": 1, "law": 0, "business": 1},
            "1": {"technology": 1, "engineering": 0, "medicine": 0, "art": 3, "law": 0, "business": 1},
            "2": {"technology": 0, "engineering": 0, "medicine": 2, "art": 1, "law": 2, "business": 2},
            "3": {"technology": 1, "engineering": 0, "medicine": 0, "art": 0, "law": 1, "business": 3},
        },
    },
    {
        "text": "Сенің өмірде ең маңызды деп санайтын нәрсең?",
        "category": "interest", "order": 25,
        "options": [
            "💡 Жаңалық пен ашылыстар жасау",
            "❤️ Адамдарға денсаулық пен бақыт сыйлау",
            "⚖️ Қоғамда теңдік пен әділдік орнату",
            "💰 Материалдық тұрақтылық пен бостандық",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 1, "art": 2, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 3, "art": 1, "law": 1, "business": 0},
            "2": {"technology": 0, "engineering": 0, "medicine": 1, "art": 1, "law": 3, "business": 1},
            "3": {"technology": 1, "engineering": 1, "medicine": 0, "art": 0, "law": 1, "business": 3},
        },
    },
    {
        "text": "Оқу уақытыңда қай іс-шараға белсенді қатысасың?",
        "category": "interest", "order": 26,
        "options": [
            "🖥️ Хакатон немесе IT байқаулары",
            "🎭 Өнер кеші немесе шығармашылық фестиваль",
            "🗣️ Дебаттар, ситуациялық ойындар",
            "💼 Жас кәсіпкерлер клубы немесе Model UN",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 0, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 1, "business": 1},
            "2": {"technology": 0, "engineering": 0, "medicine": 1, "art": 1, "law": 3, "business": 2},
            "3": {"technology": 1, "engineering": 0, "medicine": 0, "art": 0, "law": 2, "business": 3},
        },
    },
    {
        "text": "Болашақта ең үлкен мәселелердің бірін шешуге мүмкіндігің болса...",
        "category": "interest", "order": 27,
        "options": [
            "🌡️ Климаттық өзгерісті тоқтататын жүйе жасаймын",
            "🧬 Онкологиялық немесе жұқпалы аурулардан арыламын",
            "⚖️ Халықаралық заңдар мен бейбітшілікті орнатамын",
            "🚀 Адамзатты ғарышқа кеңейтетін технология жасаймын",
        ],
        "weights": {
            "0": {"technology": 2, "engineering": 3, "medicine": 1, "art": 1, "law": 1, "business": 2},
            "1": {"technology": 2, "engineering": 1, "medicine": 3, "art": 0, "law": 0, "business": 0},
            "2": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 3, "business": 2},
            "3": {"technology": 3, "engineering": 3, "medicine": 0, "art": 0, "law": 0, "business": 1},
        },
    },
    {
        "text": "Сенің ең мықты жағың не?",
        "category": "skill", "order": 28,
        "options": [
            "🧩 Күрделі техникалық мәселелерді шешемін",
            "🎨 Шығармашылықпен ерекше идеялар ұсынамын",
            "🤝 Адамдармен тіл табысып, ынтымақтасамын",
            "📢 Ойымды нақты, сенімді жеткіземін",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 1, "art": 0, "law": 1, "business": 1},
            "1": {"technology": 1, "engineering": 0, "medicine": 0, "art": 3, "law": 1, "business": 2},
            "2": {"technology": 0, "engineering": 1, "medicine": 3, "art": 1, "law": 2, "business": 3},
            "3": {"technology": 0, "engineering": 0, "medicine": 1, "art": 1, "law": 3, "business": 2},
        },
    },
    {
        "text": "Демалыс кезінде қандай бағдарлама немесе подкаст тыңдайсың?",
        "category": "interest", "order": 29,
        "options": [
            "🤖 Технология, бағдарламалау, AI туралы",
            "🎨 Өнер, дизайн, музыка немесе кино туралы",
            "⚖️ Саясат, заң, қоғам туралы",
            "💼 Бизнес, инвестиция, кәсіпкерлік туралы",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 2, "medicine": 1, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 1, "business": 1},
            "2": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 3, "business": 2},
            "3": {"technology": 1, "engineering": 0, "medicine": 0, "art": 0, "law": 1, "business": 3},
        },
    },
    {
        "text": "Болашақта қандай мамандықта жұмыс жасасаң мақтанасың?",
        "category": "interest", "order": 30,
        "options": [
            "👨‍💻 IT-маман, инженер немесе ғалым",
            "🎭 Суретші, дизайнер немесе музыкант",
            "⚖️ Заңгер, судья немесе дипломат",
            "👩‍⚕️ Дәрігер, психолог немесе фармацевт",
        ],
        "weights": {
            "0": {"technology": 3, "engineering": 3, "medicine": 0, "art": 0, "law": 0, "business": 1},
            "1": {"technology": 0, "engineering": 0, "medicine": 0, "art": 3, "law": 0, "business": 1},
            "2": {"technology": 0, "engineering": 0, "medicine": 0, "art": 0, "law": 3, "business": 2},
            "3": {"technology": 0, "engineering": 0, "medicine": 3, "art": 0, "law": 0, "business": 0},
        },
    },
]

PROFESSIONS = [
    {
        "title": "Бағдарламашы", "slug": "programmer",
        "description": "Бағдарламашылар компьютерлік бағдарламалар мен қосымшаларды жасайды. Олар алгоритмдер мен деректер құрылымдарын қолданып, күрделі мәселелерді шешеді.",
        "category": "Технология", "category_key": "technology",
        "icon_emoji": "💻", "color_hex": "#6C63FF",
        "required_skills": ["Логикалық ойлау", "Математика", "Шығармашылық", "Командада жұмыс"],
        "future_opportunities": ["Google, Apple, Microsoft компанияларында", "Фриланс", "Стартап ашу", "Халықаралық нарық"],
        "salary_min": 500000, "salary_max": 2000000, "salary_currency": "KZT",
        "demand_level": "very_high", "growth_rate": "+25% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Физика", "Информатика"],
            "skills_to_develop": ["Python", "Flutter", "Алгоритмдер", "Деректер қорлары", "Git"],
            "suggested_courses": [
                {"name": "CS50 (Harvard)", "platform": "edX", "url": "https://cs50.harvard.edu", "is_free": True},
                {"name": "Flutter & Dart", "platform": "Udemy", "url": "https://udemy.com", "is_free": False},
            ],
            "olympiads": ["Республикалық информатика олимпиадасы", "IOI", "Google Code Jam"],
            "projects": ["Портфолио сайт", "Мобильді қосымша", "Чат-бот"],
            "roadmap_steps": [
                {"order": 1, "title": "Негіздер", "description": "Python, HTML, CSS", "duration": "3-6 ай"},
                {"order": 2, "title": "Жобалар", "description": "Алғашқы жобалар", "duration": "6-12 ай"},
                {"order": 3, "title": "Алгоритмдер", "description": "DS & Algorithms", "duration": "6-9 ай"},
                {"order": 4, "title": "Internship", "description": "IT компаниясында", "duration": "3-6 ай"},
            ],
            "estimated_duration_months": 24,
        },
    },
    {
        "title": "Дәрігер", "slug": "doctor",
        "description": "Дәрігерлер адамдардың денсаулығын сақтап, ауруларды емдейді. Медицина саласы үнемі дамып, жаңа технологиялармен толығып отырады.",
        "category": "Медицина", "category_key": "medicine",
        "icon_emoji": "🏥", "color_hex": "#48CAE4",
        "required_skills": ["Эмпатия", "Зейін", "Шыдамдылық", "Аналитикалық ойлау"],
        "future_opportunities": ["Мемлекеттік клиникалар", "Жеке клиникалар", "Ғылыми зерттеулер", "Халықаралық миссиялар"],
        "salary_min": 400000, "salary_max": 1500000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+15% жыл сайын",
        "path": {
            "required_subjects": ["Биология", "Химия", "Физика"],
            "skills_to_develop": ["Анатомия", "Диагностика", "Дәрі-дәрмек білімі"],
            "suggested_courses": [
                {"name": "Introduction to Biology", "platform": "Coursera", "url": "https://coursera.org", "is_free": True},
            ],
            "olympiads": ["Биология олимпиадасы", "IBO", "Химия олимпиадасы"],
            "projects": ["Денсаулық сақтау жобасы", "Ғылыми зерттеу"],
            "roadmap_steps": [
                {"order": 1, "title": "Биология мен химия", "description": "Терең деңгейде", "duration": "1-2 жыл"},
                {"order": 2, "title": "Медициналық университет", "description": "Дайындық", "duration": "6 ай"},
            ],
            "estimated_duration_months": 36,
        },
    },
    {
        "title": "Дизайнер", "slug": "designer",
        "description": "Дизайнерлер визуалды коммуникацияны жасайды. UI/UX, графикалық, өнеркәсіптік дизайн бағыттарында жұмыс жасауға болады.",
        "category": "Өнер және дизайн", "category_key": "art",
        "icon_emoji": "🎨", "color_hex": "#FF6B6B",
        "required_skills": ["Шығармашылық ойлау", "Эстетикалық сезім", "Figma", "Adobe"],
        "future_opportunities": ["Агенттіктерде жұмыс", "Фриланс", "Өз студиясы", "Халықаралық жобалар"],
        "salary_min": 350000, "salary_max": 1200000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+20% жыл сайын",
        "path": {
            "required_subjects": ["Өнер", "Информатика"],
            "skills_to_develop": ["Figma", "Adobe Photoshop", "Illustrator", "UX зерттеу"],
            "suggested_courses": [
                {"name": "Figma UI Design", "platform": "Coursera", "url": "https://coursera.org", "is_free": False},
            ],
            "olympiads": ["Дизайн конкурстары", "Хакатондар"],
            "projects": ["Мобильді қосымша UI", "Бренд айналымы"],
            "roadmap_steps": [
                {"order": 1, "title": "Дизайн негіздері", "description": "Түс теориясы, типография", "duration": "2-4 ай"},
                {"order": 2, "title": "Figma", "description": "UI/UX дизайн", "duration": "3-6 ай"},
            ],
            "estimated_duration_months": 18,
        },
    },
    {
        "title": "Инженер", "slug": "engineer",
        "description": "Инженерлер технологиялық жүйелерді жобалайды, жасайды және жетілдіреді.",
        "category": "Инженерия", "category_key": "engineering",
        "icon_emoji": "⚙️", "color_hex": "#FF9800",
        "required_skills": ["Математикалық ойлау", "Техникалық білім", "3D модельдеу"],
        "future_opportunities": ["Өнеркәсіп", "Ғылыми институттар", "Халықаралық компаниялар"],
        "salary_min": 400000, "salary_max": 1600000, "salary_currency": "KZT",
        "demand_level": "very_high", "growth_rate": "+18% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Физика", "Химия"],
            "skills_to_develop": ["AutoCAD", "3D модельдеу", "Жобалау"],
            "suggested_courses": [
                {"name": "Engineering Mathematics", "platform": "Coursera", "url": "https://coursera.org", "is_free": True},
            ],
            "olympiads": ["Физика олимпиадасы", "IPhO"],
            "projects": ["Роботтехника жобасы", "Механикалық конструкция"],
            "roadmap_steps": [
                {"order": 1, "title": "Физика мен математика", "description": "Терең деңгейде", "duration": "1-2 жыл"},
                {"order": 2, "title": "CAD бағдарламалар", "description": "AutoCAD үйрену", "duration": "6 ай"},
            ],
            "estimated_duration_months": 30,
        },
    },
    {
        "title": "Заңгер", "slug": "lawyer",
        "description": "Заңгерлер заңдық мәселелер бойынша кеңес береді және клиенттерін сот процестерінде қорғайды.",
        "category": "Заң", "category_key": "law",
        "icon_emoji": "⚖️", "color_hex": "#4CAF50",
        "required_skills": ["Риторика", "Аналитикалық ойлау", "Коммуникация"],
        "future_opportunities": ["Заң кеңселері", "Мемлекеттік органдар", "Халықаралық ұйымдар"],
        "salary_min": 450000, "salary_max": 1800000, "salary_currency": "KZT",
        "demand_level": "medium", "growth_rate": "+10% жыл сайын",
        "path": {
            "required_subjects": ["Тарих", "Қазақ тілі", "Ағылшын тілі"],
            "skills_to_develop": ["Пікірталас", "Заңнама", "Жазу дағдысы"],
            "suggested_courses": [
                {"name": "Introduction to Law", "platform": "Coursera", "url": "https://coursera.org", "is_free": True},
            ],
            "olympiads": ["Пікірсайыс (Дебаттар)", "Заңгерлер байқауы"],
            "projects": ["Заң эссесі", "Мок-сот процесі"],
            "roadmap_steps": [
                {"order": 1, "title": "Тіл дайындығы", "description": "Қазақша, орысша, ағылшынша", "duration": "1 жыл"},
            ],
            "estimated_duration_months": 24,
        },
    },
    {
        "title": "Кәсіпкер", "slug": "entrepreneur",
        "description": "Кәсіпкерлер жаңа бизнес идеяларды іске асырады, командалар мен ресурстарды басқарады.",
        "category": "Бизнес", "category_key": "business",
        "icon_emoji": "📊", "color_hex": "#9C27B0",
        "required_skills": ["Лидерлік", "Коммуникация", "Стратегиялық ойлау"],
        "future_opportunities": ["Стартап ашу", "Инвесторлармен жұмыс", "Халықаралық бизнес"],
        "salary_min": 300000, "salary_max": 5000000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+22% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Экономика"],
            "skills_to_develop": ["Маркетинг", "Қаржы", "Менеджмент"],
            "suggested_courses": [
                {"name": "Entrepreneurship", "platform": "Coursera", "url": "https://coursera.org", "is_free": False},
            ],
            "olympiads": ["Жас кәсіпкерлер байқауы"],
            "projects": ["Бизнес жоспар жасау", "Шағын бизнес ашу"],
            "roadmap_steps": [
                {"order": 1, "title": "Бизнес негіздері", "description": "Маркетинг, қаржы", "duration": "6 ай"},
            ],
            "estimated_duration_months": 18,
        },
    },
    {
        "title": "Деректер ғалымы", "slug": "data-scientist",
        "description": "Деректер ғалымдары үлкен деректер жиынтықтарын талдап, машиналық оқыту алгоритмдері арқылы болашақты болжайды. Бизнес шешімдерін деректерге негіздейді.",
        "category": "Технология", "category_key": "technology",
        "icon_emoji": "📊", "color_hex": "#3F51B5",
        "required_skills": ["Статистика", "Python", "SQL", "Машиналық оқыту", "Визуализация"],
        "future_opportunities": ["IT компаниялары", "Банктер", "Мемлекеттік органдар", "Ғылыми зерттеу орталықтары"],
        "salary_min": 600000, "salary_max": 2500000, "salary_currency": "KZT",
        "demand_level": "very_high", "growth_rate": "+35% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Статистика", "Информатика"],
            "skills_to_develop": ["Python", "Pandas", "TensorFlow", "SQL", "Tableau"],
            "suggested_courses": [
                {"name": "Data Science with Python", "platform": "Coursera", "url": "https://coursera.org", "is_free": False},
            ],
            "olympiads": ["Kaggle competitions", "Информатика олимпиадасы"],
            "projects": ["Деректер талдау жобасы", "ML модель жасау"],
            "roadmap_steps": [
                {"order": 1, "title": "Математика негіздері", "description": "Статистика, сызықтық алгебра", "duration": "3-6 ай"},
                {"order": 2, "title": "Python & Pandas", "description": "Деректерді өңдеу", "duration": "3-6 ай"},
                {"order": 3, "title": "ML алгоритмдері", "description": "Машиналық оқыту", "duration": "6-9 ай"},
            ],
            "estimated_duration_months": 18,
        },
    },
    {
        "title": "Кибер қауіпсіздік маманы", "slug": "cybersecurity",
        "description": "Кибер қауіпсіздік мамандары компьютерлік жүйелерді, желілерді және деректерді хакерлерден қорғайды. Цифрлы дүниенің қорғаушылары.",
        "category": "Технология", "category_key": "technology",
        "icon_emoji": "🔐", "color_hex": "#F44336",
        "required_skills": ["Желі қауіпсіздігі", "Этикалық хакинг", "Криптография", "Linux"],
        "future_opportunities": ["Банктер", "Мемлекеттік органдар", "IT компаниялары", "Халықаралық ұйымдар"],
        "salary_min": 700000, "salary_max": 3000000, "salary_currency": "KZT",
        "demand_level": "very_high", "growth_rate": "+40% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Информатика", "Физика"],
            "skills_to_develop": ["Linux", "Python", "Желі хаттамалары", "Penetration Testing"],
            "suggested_courses": [
                {"name": "CompTIA Security+", "platform": "CompTIA", "url": "https://comptia.org", "is_free": False},
            ],
            "olympiads": ["CTF (Capture The Flag) жарыстары", "CyberPatriot"],
            "projects": ["Желі қауіпсіздік аудиті", "Этикалық хакинг жобасы"],
            "roadmap_steps": [
                {"order": 1, "title": "Желі негіздері", "description": "TCP/IP, OSI моделі", "duration": "3-6 ай"},
                {"order": 2, "title": "Linux & Security", "description": "Операциялық жүйелер", "duration": "6 ай"},
                {"order": 3, "title": "Penetration Testing", "description": "Этикалық хакинг", "duration": "6-12 ай"},
            ],
            "estimated_duration_months": 24,
        },
    },
    {
        "title": "Психолог", "slug": "psychologist",
        "description": "Психологтар адамдардың психикалық денсаулығын сақтауға, мінез-құлық мәселелерін шешуге көмектеседі. Жеке немесе топтық кеңестер береді.",
        "category": "Медицина", "category_key": "medicine",
        "icon_emoji": "🧠", "color_hex": "#9C27B0",
        "required_skills": ["Эмпатия", "Белсенді тыңдау", "Аналитикалық ойлау", "Коммуникация"],
        "future_opportunities": ["Мектептер", "Клиникалар", "Корпоративтік секторы", "Жеке практика"],
        "salary_min": 350000, "salary_max": 1200000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+20% жыл сайын",
        "path": {
            "required_subjects": ["Биология", "Қазақ тілі", "Ағылшын тілі"],
            "skills_to_develop": ["Психотерапия техникалары", "CBT", "Тест әдістемелері"],
            "suggested_courses": [
                {"name": "Introduction to Psychology", "platform": "Coursera", "url": "https://coursera.org", "is_free": True},
            ],
            "olympiads": ["Психология пәні олимпиадасы"],
            "projects": ["Психологиялық зерттеу", "Кеңес беру тәжірибесі"],
            "roadmap_steps": [
                {"order": 1, "title": "Психология негіздері", "description": "Жалпы психология", "duration": "1 жыл"},
                {"order": 2, "title": "Тәжірибелік дағдылар", "description": "Кеңес беру практикасы", "duration": "6 ай"},
            ],
            "estimated_duration_months": 36,
        },
    },
    {
        "title": "Биотехнолог", "slug": "biotechnologist",
        "description": "Биотехнологтар тірі организмдерді қолданып жаңа дәрілер, вакциналар, өнімдер жасайды. Медицина мен инженерияны біріктіретін мамандық.",
        "category": "Медицина", "category_key": "medicine",
        "icon_emoji": "🧬", "color_hex": "#00BCD4",
        "required_skills": ["Биохимия", "Молекулалық биология", "Лабораториялық техника", "ГМО технологиялары"],
        "future_opportunities": ["Фармацевтикалық компаниялар", "Ғылыми зертханалар", "Ауыл шаруашылығы", "Халықаралық зерттеу орталықтары"],
        "salary_min": 450000, "salary_max": 1800000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+25% жыл сайын",
        "path": {
            "required_subjects": ["Биология", "Химия", "Физика", "Математика"],
            "skills_to_develop": ["PCR техникасы", "Ген инженериясы", "Биоинформатика"],
            "suggested_courses": [
                {"name": "Molecular Biology", "platform": "edX", "url": "https://edx.org", "is_free": True},
            ],
            "olympiads": ["Биология олимпиадасы", "IBO", "Химия олимпиадасы"],
            "projects": ["Биотехнологиялық зерттеу жобасы"],
            "roadmap_steps": [
                {"order": 1, "title": "Биохимия негіздері", "description": "Жасуша биологиясы", "duration": "1-2 жыл"},
                {"order": 2, "title": "Зертхана дағдылары", "description": "Практикалық тәжірибе", "duration": "1 жыл"},
            ],
            "estimated_duration_months": 36,
        },
    },
    {
        "title": "Архитектор", "slug": "architect",
        "description": "Архитекторлар ғимараттар мен кеңістіктерді жобалайды. Функционалдылық пен эстетиканы біріктіріп, адамдар үшін ыңғайлы орта жасайды.",
        "category": "Инженерия", "category_key": "engineering",
        "icon_emoji": "🏛️", "color_hex": "#795548",
        "required_skills": ["3D модельдеу", "Сызбалар", "Математика", "Шығармашылық ойлау"],
        "future_opportunities": ["Жобалау кеңселері", "Мемлекеттік органдар", "Жеке практика", "Халықаралық компаниялар"],
        "salary_min": 400000, "salary_max": 1500000, "salary_currency": "KZT",
        "demand_level": "medium", "growth_rate": "+12% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Физика", "Өнер", "Геометрия"],
            "skills_to_develop": ["AutoCAD", "Revit", "SketchUp", "3ds Max"],
            "suggested_courses": [
                {"name": "Architectural Design", "platform": "Coursera", "url": "https://coursera.org", "is_free": False},
            ],
            "olympiads": ["Архитектура байқаулары", "Дизайн конкурстары"],
            "projects": ["Тұрғын үй жобасы", "Қала дизайны жобасы"],
            "roadmap_steps": [
                {"order": 1, "title": "Сызба негіздері", "description": "Техникалық сызба", "duration": "6 ай"},
                {"order": 2, "title": "CAD бағдарламалары", "description": "AutoCAD, Revit", "duration": "6-12 ай"},
                {"order": 3, "title": "Жоба жасау", "description": "Нақты архитектуралық жоба", "duration": "6-12 ай"},
            ],
            "estimated_duration_months": 30,
        },
    },
    {
        "title": "Журналист", "slug": "journalist",
        "description": "Журналистер маңызды жаңалықтарды жинап, өңдеп, қоғамға жеткізеді. Сөз бостандығы мен ақпарат берудің маңызды буыны.",
        "category": "Өнер және дизайн", "category_key": "art",
        "icon_emoji": "📰", "color_hex": "#FF5722",
        "required_skills": ["Жазу дағдысы", "Сұхбат алу", "Зерттеу", "Коммуникация"],
        "future_opportunities": ["Телеарналар", "Газет-журналдар", "Онлайн медиа", "Мемлекеттік органдар"],
        "salary_min": 300000, "salary_max": 1000000, "salary_currency": "KZT",
        "demand_level": "medium", "growth_rate": "+10% жыл сайын",
        "path": {
            "required_subjects": ["Қазақ тілі", "Ағылшын тілі", "Тарих", "Әлеуметтану"],
            "skills_to_develop": ["Мәтін жазу", "Сұхбат алу техникасы", "Бейне өңдеу", "SMM"],
            "suggested_courses": [
                {"name": "Journalism Essentials", "platform": "Coursera", "url": "https://coursera.org", "is_free": True},
            ],
            "olympiads": ["Мектеп газеті байқауы", "Жас журналистер конкурсы"],
            "projects": ["Мектеп газеті", "YouTube канал", "Подкаст жасау"],
            "roadmap_steps": [
                {"order": 1, "title": "Мәтін жазу дағдысы", "description": "Журналистикалық жазу стилі", "duration": "6 ай"},
                {"order": 2, "title": "Медиа практика", "description": "Редакцияда тәжірибе", "duration": "6 ай"},
            ],
            "estimated_duration_months": 18,
        },
    },
    {
        "title": "Геймдев маманы", "slug": "game-developer",
        "description": "Ойын жасаушылар компьютерлік ойындарды жобалайды, кодтайды және жасайды. Шығармашылық пен технологияны біріктіретін мамандық.",
        "category": "Өнер және дизайн", "category_key": "art",
        "icon_emoji": "🎮", "color_hex": "#673AB7",
        "required_skills": ["Unity/Unreal Engine", "Бағдарламалау", "3D модельдеу", "Ойын дизайны"],
        "future_opportunities": ["Ойын студиялары", "Инди разработчик", "Mobile games", "Метавселенная"],
        "salary_min": 500000, "salary_max": 2000000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+30% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Информатика", "Өнер"],
            "skills_to_develop": ["Unity", "C#", "3D модельдеу", "Ойын дизайны негіздері"],
            "suggested_courses": [
                {"name": "Unity Game Development", "platform": "Udemy", "url": "https://udemy.com", "is_free": False},
            ],
            "olympiads": ["Game Jam жарыстары", "Хакатондар"],
            "projects": ["Алғашқы мобильді ойын", "2D платформер"],
            "roadmap_steps": [
                {"order": 1, "title": "Бағдарламалау негіздері", "description": "C# тілі", "duration": "3-6 ай"},
                {"order": 2, "title": "Unity Engine", "description": "Ойын жасау платформасы", "duration": "6-12 ай"},
                {"order": 3, "title": "Бірінші ойын", "description": "Толыққанды жоба", "duration": "3-6 ай"},
            ],
            "estimated_duration_months": 18,
        },
    },
    {
        "title": "Маркетолог", "slug": "marketer",
        "description": "Маркетологтар өнімдер мен қызметтерді тұтынушыларға жеткізеді, бренд имиджін қалыптастырады. Цифрлы маркетинг болашақтың бағыты.",
        "category": "Бизнес", "category_key": "business",
        "icon_emoji": "📱", "color_hex": "#E91E63",
        "required_skills": ["SMM", "SEO", "Деректер талдауы", "Шығармашылық", "Коммуникация"],
        "future_opportunities": ["IT компаниялары", "Медиа агенттіктер", "Фриланс", "Өз агенттігі"],
        "salary_min": 350000, "salary_max": 1500000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+25% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Тіл пәндері", "Психология"],
            "skills_to_develop": ["Google Ads", "SMM", "Контент жасау", "Analytics"],
            "suggested_courses": [
                {"name": "Digital Marketing", "platform": "Google", "url": "https://grow.google", "is_free": True},
            ],
            "olympiads": ["Маркетинг байқаулары", "Жас кәсіпкерлер конкурсы"],
            "projects": ["Бренд стратегиясы", "Әлеуметтік медиа кампания"],
            "roadmap_steps": [
                {"order": 1, "title": "Маркетинг негіздері", "description": "4P, бренд стратегиясы", "duration": "3-6 ай"},
                {"order": 2, "title": "Цифрлы маркетинг", "description": "SMM, SEO, Google Ads", "duration": "6 ай"},
            ],
            "estimated_duration_months": 12,
        },
    },
    {
        "title": "Қаржы аналитигі", "slug": "financial-analyst",
        "description": "Қаржы аналитиктері компаниялардың қаржылық жағдайын бағалайды, инвестиция стратегияларын жасайды. Банк пен қор нарығында жұмыс жасайды.",
        "category": "Бизнес", "category_key": "business",
        "icon_emoji": "💹", "color_hex": "#4CAF50",
        "required_skills": ["Қаржылық талдау", "Excel", "Математика", "Экономика", "Аналитикалық ойлау"],
        "future_opportunities": ["Банктер", "Инвестициялық компаниялар", "Консалтинг", "Мемлекеттік органдар"],
        "salary_min": 500000, "salary_max": 2000000, "salary_currency": "KZT",
        "demand_level": "high", "growth_rate": "+18% жыл сайын",
        "path": {
            "required_subjects": ["Математика", "Экономика", "Статистика"],
            "skills_to_develop": ["Excel", "Bloomberg", "Қаржылық модельдеу", "Python"],
            "suggested_courses": [
                {"name": "Financial Analysis", "platform": "Coursera", "url": "https://coursera.org", "is_free": False},
            ],
            "olympiads": ["Экономика олимпиадасы", "Бизнес байқаулары"],
            "projects": ["Инвестициялық портфель талдауы", "Компания қаржылық есебі"],
            "roadmap_steps": [
                {"order": 1, "title": "Қаржы негіздері", "description": "Бухгалтерия, экономика", "duration": "6-12 ай"},
                {"order": 2, "title": "Қаржылық модельдеу", "description": "Excel, деректер талдауы", "duration": "6 ай"},
            ],
            "estimated_duration_months": 24,
        },
    },
]

# Full Kazakhstan university dataset
UNIVERSITIES = [
    # Астана
    {"name": "Назарбаев Университеті", "short_name": "NU", "city": "Астана",
     "website": "https://nu.edu.kz", "is_national": True, "rating": 5,
     "category_keys": ["technology", "engineering", "medicine", "business", "law"],
     "description": "Қазақстанның жетекші зерттеу университеті"},
    {"name": "Л.Н. Гумилев атындағы Еуразия ұлттық университеті", "short_name": "ЕҰУ", "city": "Астана",
     "website": "https://enu.kz", "is_national": True, "rating": 5,
     "category_keys": ["technology", "engineering", "law", "business", "art"],
     "description": "Астанадағы жетекші мемлекеттік университет"},
    {"name": "Астана IT университеті", "short_name": "AITU", "city": "Астана",
     "website": "https://astanait.edu.kz", "is_national": False, "rating": 4,
     "category_keys": ["technology"],
     "description": "IT мамандықтарына бағытталған заманауи университет"},
    {"name": "Қазақстан-Британдық техникалық университеті", "short_name": "ҚБТУ", "city": "Астана",
     "website": "https://kbtu.kz", "is_national": False, "rating": 4,
     "category_keys": ["technology", "engineering", "business"],
     "description": "Техникалық және бизнес мамандықтары"},
    {"name": "Медицина университеті Астана", "short_name": "МУА", "city": "Астана",
     "website": "https://amu.kz", "is_national": False, "rating": 4,
     "category_keys": ["medicine"],
     "description": "Медицина саласындағы ведущий университет"},
    {"name": "Қазақ ұлттық аграрлық зерттеу университеті", "short_name": "ҚазНАЗУ", "city": "Астана",
     "website": "https://kaznaru.edu.kz", "is_national": True, "rating": 3,
     "category_keys": ["engineering", "medicine"],
     "description": "Ауыл шаруашылығы мен инженерлік мамандықтар"},
    {"name": "Халықаралық бизнес академиясы", "short_name": "МБА Астана", "city": "Астана",
     "website": "https://mba.kz", "is_national": False, "rating": 3,
     "category_keys": ["business"],
     "description": "Бизнес мамандықтарының академиясы"},

    # Алматы
    {"name": "Әл-Фараби атындағы Қазақ ұлттық университеті", "short_name": "ҚазҰУ", "city": "Алматы",
     "website": "https://kaznu.kz", "is_national": True, "rating": 5,
     "category_keys": ["technology", "law", "medicine", "art", "business", "engineering"],
     "description": "Қазақстанның ең ірі классикалық университеті"},
    {"name": "Қазақ ұлттық техникалық зерттеу университеті", "short_name": "ҚазҰТЗУ", "city": "Алматы",
     "website": "https://kaznitu.kz", "is_national": True, "rating": 4,
     "category_keys": ["technology", "engineering"],
     "description": "Техникалық мамандықтардың ведущий орталығы"},
    {"name": "Алматы менеджмент университеті", "short_name": "AlmaU", "city": "Алматы",
     "website": "https://almau.edu.kz", "is_national": False, "rating": 4,
     "category_keys": ["business", "law"],
     "description": "Бизнес пен менеджмент мамандықтары"},
    {"name": "КИМЭП университеті", "short_name": "КИМЭП", "city": "Алматы",
     "website": "https://kimep.kz", "is_national": False, "rating": 4,
     "category_keys": ["business", "law"],
     "description": "Халықаралық бизнес пен заң"},
    {"name": "Қазақ ұлттық медицина университеті", "short_name": "ҚазҰМУ", "city": "Алматы",
     "website": "https://kaznmu.kz", "is_national": True, "rating": 5,
     "category_keys": ["medicine"],
     "description": "Медицина саласының жетекші университеті"},
    {"name": "Қазақ өнер және мәдениет академиясы", "short_name": "ҚӨМА", "city": "Алматы",
     "website": "https://kaznai.kz", "is_national": True, "rating": 4,
     "category_keys": ["art"],
     "description": "Өнер мен мәдениет мамандықтары"},
    {"name": "Алматы технологиялық университеті", "short_name": "АТУ", "city": "Алматы",
     "website": "https://atu.kz", "is_national": False, "rating": 3,
     "category_keys": ["technology", "engineering"],
     "description": "Технологиялық мамандықтар"},
    {"name": "Халықаралық информатика және басқару институты", "short_name": "МУИТ", "city": "Алматы",
     "website": "https://muit.kz", "is_national": False, "rating": 3,
     "category_keys": ["technology"],
     "description": "Информатика және IT мамандықтары"},
    {"name": "Сәйкес медицина университеті", "short_name": "СМУ", "city": "Алматы",
     "website": "https://sdu.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["medicine"],
     "description": "Медицина мамандықтары"},
    {"name": "Дизайн академиясы", "short_name": "ДА Алматы", "city": "Алматы",
     "website": "https://design.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["art"],
     "description": "Дизайн мамандықтары"},

    # Шымкент
    {"name": "М. Әуезов атындағы Оңтүстік Қазақстан университеті", "short_name": "ОҚУ", "city": "Шымкент",
     "website": "https://sku.edu.kz", "is_national": True, "rating": 4,
     "category_keys": ["technology", "engineering", "medicine", "law", "business"],
     "description": "Оңтүстік Қазақстандағы жетекші университет"},
    {"name": "Оңтүстік Қазақстан медицина академиясы", "short_name": "ОҚМА", "city": "Шымкент",
     "website": "https://skma.edu.kz", "is_national": False, "rating": 4,
     "category_keys": ["medicine"],
     "description": "Медицина мамандықтары"},
    {"name": "Шымкент университеті", "short_name": "ШУ", "city": "Шымкент",
     "website": "https://univer.kz", "is_national": False, "rating": 3,
     "category_keys": ["business", "law", "technology"],
     "description": "Жан-жақты мамандықтар"},

    # Қарағанды
    {"name": "Е.А. Бөкетов атындағы Қарағанды университеті", "short_name": "ҚарУ", "city": "Қарағанды",
     "website": "https://kstu.kz", "is_national": True, "rating": 4,
     "category_keys": ["technology", "engineering", "law", "business", "medicine"],
     "description": "Орталық Қазақстанның жетекші университеті"},
    {"name": "Қарағанды техникалық университеті", "short_name": "ҚарТУ", "city": "Қарағанды",
     "website": "https://kargtu.kz", "is_national": False, "rating": 3,
     "category_keys": ["technology", "engineering"],
     "description": "Техникалық мамандықтар"},
    {"name": "Қарағанды медицина университеті", "short_name": "ҚМУ", "city": "Қарағанды",
     "website": "https://qmu.kz", "is_national": False, "rating": 4,
     "category_keys": ["medicine"],
     "description": "Медицина мамандықтарының орталығы"},

    # Өскемен
    {"name": "Д. Серікбаев атындағы Шығыс Қазақстан техникалық университеті", "short_name": "ШҚТУ", "city": "Өскемен",
     "website": "https://ektu.kz", "is_national": False, "rating": 3,
     "category_keys": ["technology", "engineering"],
     "description": "Техникалық мамандықтар"},
    {"name": "Шығыс Қазақстан университеті", "short_name": "ШҚУ", "city": "Өскемен",
     "website": "https://vku.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["business", "law", "medicine"],
     "description": "Жан-жақты мамандықтар"},

    # Атырау
    {"name": "Атырау университеті", "short_name": "АУ", "city": "Атырау",
     "website": "https://au.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["engineering", "business"],
     "description": "Мұнай-газ инженерлігі мен бизнес"},

    # Ақтөбе
    {"name": "Қ. Жұбанов атындағы Ақтөбе өңірлік университеті", "short_name": "АкТУ", "city": "Ақтөбе",
     "website": "https://zhubanov.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["technology", "engineering", "medicine", "law"],
     "description": "Өңірлік жетекші университет"},

    # Павлодар
    {"name": "Торайғыров университеті", "short_name": "ТорУ", "city": "Павлодар",
     "website": "https://toraighyrov.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["technology", "engineering", "business", "law"],
     "description": "Павлодар өңірінің жетекші университеті"},

    # Орал
    {"name": "М. Өтемісов атындағы Батыс Қазақстан университеті", "short_name": "БҚУ", "city": "Орал",
     "website": "https://wku.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["law", "business", "medicine"],
     "description": "Батыс Қазақстанның жетекші университеті"},

    # Қостанай
    {"name": "Қостанай өңірлік университеті", "short_name": "ҚӨУ", "city": "Қостанай",
     "website": "https://kru.edu.kz", "is_national": False, "rating": 3,
     "category_keys": ["business", "law", "engineering"],
     "description": "Қостанай өңірінің жетекші университеті"},
]


async def seed():
    await create_all_tables()
    async with async_session_maker() as db:
        # Questions — add any missing ones (by order)
        existing_orders_result = await db.execute(select(Question.order))
        existing_orders = {row[0] for row in existing_orders_result.fetchall()}
        new_count = 0
        for q in QUESTIONS:
            if q["order"] not in existing_orders:
                db.add(Question(**q, is_active=True))
                new_count += 1
        if new_count:
            print(f"[OK] {new_count} new questions added (total: {len(QUESTIONS)})")
        else:
            print(f"[SKIP] All {len(QUESTIONS)} questions already exist")

        # Professions + paths — add any missing ones (by slug)
        existing_slugs_result = await db.execute(select(Profession.slug))
        existing_slugs = {row[0] for row in existing_slugs_result.fetchall()}
        new_prof_count = 0
        for p_data in PROFESSIONS:
            if p_data["slug"] not in existing_slugs:
                path_data = p_data.pop("path")
                prof = Profession(**p_data)
                db.add(prof)
                await db.flush()
                db.add(DevelopmentPath(profession_id=prof.id, **path_data))
                new_prof_count += 1
        if new_prof_count:
            print(f"[OK] {new_prof_count} new professions added (total: {len(PROFESSIONS)})")
        else:
            print(f"[SKIP] All {len(PROFESSIONS)} professions already exist")

        # Universities
        existing_u = await db.execute(select(University).limit(1))
        if not existing_u.scalar_one_or_none():
            for u in UNIVERSITIES:
                db.add(University(**u))
            print(f"[OK] {len(UNIVERSITIES)} universities seeded")
        else:
            print("[SKIP] Universities already exist")

        await db.commit()
        print("[DONE] Seeding complete!")


if __name__ == "__main__":
    asyncio.run(seed())