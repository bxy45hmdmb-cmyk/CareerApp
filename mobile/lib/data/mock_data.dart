import '../models/career_model.dart';
import '../models/question_model.dart';

class MockData {
  static List<CareerModel> get careers => [
        CareerModel(
          id: '1',
          title: 'Бағдарламашы',
          description:
              'Бағдарламашылар компьютерлік бағдарламалар мен қосымшаларды жасайды. '
              'Олар алгоритмдер мен деректер құрылымдарын қолданып, '
              'күрделі мәселелерді шешеді.',
          iconEmoji: '💻',
          category: 'Технология',
          requiredSkills: [
            'Логикалық ойлау',
            'Математика',
            'Шығармашылық',
            'Командада жұмыс',
          ],
          requiredSubjects: ['Математика', 'Физика', 'Информатика'],
          salaryRange: '500 000 – 2 000 000 ₸',
          demandLevel: 'Өте жоғары',
          growthRate: '+25% жыл сайын',
          opportunities: [
            'Google, Apple, Microsoft сияқты компанияларда жұмыс',
            'Фриланс мүмкіндіктері',
            'Стартап ашу',
            'Халықаралық нарықта жұмыс',
          ],
          color: '0xFF6C63FF',
          matchPercentage: 92,
        ),
        CareerModel(
          id: '2',
          title: 'Дәрігер',
          description:
              'Дәрігерлер адамдардың денсаулығын сақтап, ауруларды емдейді. '
              'Медицина саласы үнемі дамып, жаңа технологиялармен толығып отырады.',
          iconEmoji: '🏥',
          category: 'Медицина',
          requiredSkills: [
            'Эмпатия',
            'Зейін',
            'Шыдамдылық',
            'Аналитикалық ойлау',
          ],
          requiredSubjects: ['Биология', 'Химия', 'Физика'],
          salaryRange: '400 000 – 1 500 000 ₸',
          demandLevel: 'Жоғары',
          growthRate: '+15% жыл сайын',
          opportunities: [
            'Мемлекеттік және жеке клиникаларда жұмыс',
            'Ғылыми зерттеулер',
            'Халықаралық гуманитарлық миссиялар',
            'Медициналық стартаптар',
          ],
          color: '0xFF48CAE4',
          matchPercentage: 78,
        ),
        CareerModel(
          id: '3',
          title: 'Дизайнер',
          description:
              'Дизайнерлер визуалды коммуникацияны жасайды. '
              'UI/UX, графикалық, өнеркәсіптік дизайн бағыттарында жұмыс жасауға болады.',
          iconEmoji: '🎨',
          category: 'Өнер және дизайн',
          requiredSkills: [
            'Шығармашылық ойлау',
            'Эстетикалық сезім',
            'Техникалық дағдылар',
            'Коммуникация',
          ],
          requiredSubjects: ['Өнер', 'Информатика', 'Математика'],
          salaryRange: '350 000 – 1 200 000 ₸',
          demandLevel: 'Жоғары',
          growthRate: '+20% жыл сайын',
          opportunities: [
            'Агенттіктерде жұмыс',
            'Фриланс',
            'Өз студиясын ашу',
            'Халықаралық жобаларда қатысу',
          ],
          color: '0xFFFF6B6B',
          matchPercentage: 85,
        ),
        CareerModel(
          id: '4',
          title: 'Заңгер',
          description:
              'Заңгерлер заңдық мәселелер бойынша кеңес береді және '
              'клиенттерін сот процестерінде қорғайды.',
          iconEmoji: '⚖️',
          category: 'Заң',
          requiredSkills: [
            'Риторика',
            'Аналитикалық ойлау',
            'Зейін',
            'Коммуникация',
          ],
          requiredSubjects: ['Тарих', 'Қазақ тілі', 'Орыс тілі'],
          salaryRange: '450 000 – 1 800 000 ₸',
          demandLevel: 'Орташа',
          growthRate: '+10% жыл сайын',
          opportunities: [
            'Заң кеңселерінде жұмыс',
            'Мемлекеттік органдарда қызмет',
            'Халықаралық ұйымдарда жұмыс',
            'Жеке тәжірибе',
          ],
          color: '0xFF4CAF50',
          matchPercentage: 70,
        ),
        CareerModel(
          id: '5',
          title: 'Инженер',
          description:
              'Инженерлер технологиялық жүйелерді жобалайды, жасайды және '
              'жетілдіреді. Механикалық, электрлік, азаматтық бағыттары бар.',
          iconEmoji: '⚙️',
          category: 'Инженерия',
          requiredSkills: [
            'Математикалық ойлау',
            'Шығармашылық',
            'Техникалық білім',
            'Мәселені шешу',
          ],
          requiredSubjects: ['Математика', 'Физика', 'Химия'],
          salaryRange: '400 000 – 1 600 000 ₸',
          demandLevel: 'Өте жоғары',
          growthRate: '+18% жыл сайын',
          opportunities: [
            'Өнеркәсіп орындарында жұмыс',
            'Ғылыми-зерттеу институттарында',
            'Халықаралық компанияларда',
            'Стартаптар',
          ],
          color: '0xFFFF9800',
          matchPercentage: 88,
        ),
      ];

  static List<DevelopmentPath> get developmentPaths => [
        DevelopmentPath(
          careerId: '1',
          title: 'Бағдарламашы болу жолы',
          steps: [
            PathStep(
              order: 1,
              title: 'Негіздерді үйрену',
              description: 'HTML, CSS, Python негіздерін үйрен',
              duration: '3-6 ай',
              isCompleted: true,
            ),
            PathStep(
              order: 2,
              title: 'Бағдарлама жазу',
              description: 'Алғашқы жобаларыңды жаса',
              duration: '6-12 ай',
              isCompleted: true,
            ),
            PathStep(
              order: 3,
              title: 'Алгоритмдер',
              description: 'Деректер құрылымдары мен алгоритмдерді үйрен',
              duration: '6-9 ай',
              isCompleted: false,
            ),
            PathStep(
              order: 4,
              title: 'Портфолио жасау',
              description: 'GitHub профиль және жобалар жина',
              duration: '3-6 ай',
              isCompleted: false,
            ),
            PathStep(
              order: 5,
              title: 'Тәжірибе (Internship)',
              description: 'IT компанияларда тәжірибеден өт',
              duration: '3-6 ай',
              isCompleted: false,
            ),
          ],
          recommendedCourses: [
            'CS50 (Harvard) — тегін',
            'Flutter & Dart (Udemy)',
            'Python for Beginners',
            'Алгоритмдер курсы (Coursera)',
            'Web Development Bootcamp',
          ],
          olympiads: [
            'Республикалық информатика олимпиадасы',
            'International Olympiad in Informatics (IOI)',
            'Google Code Jam',
            'Codeforces турнирлері',
          ],
          projects: [
            'Жеке блог немесе портфолио сайт',
            'Мобильді қосымша (Flutter)',
            'Чат-бот жасау',
            'Деректерді талдау жобасы',
          ],
        ),
        DevelopmentPath(
          careerId: '3',
          title: 'Дизайнер болу жолы',
          steps: [
            PathStep(
              order: 1,
              title: 'Дизайн негіздері',
              description: 'Түс теориясы, типография, композиция',
              duration: '2-4 ай',
              isCompleted: true,
            ),
            PathStep(
              order: 2,
              title: 'Figma үйрену',
              description: 'UI/UX дизайн құралдарын меңгер',
              duration: '3-6 ай',
              isCompleted: false,
            ),
            PathStep(
              order: 3,
              title: 'Портфолио',
              description: 'Дизайн жобаларын Behance-ке жүктеу',
              duration: '4-6 ай',
              isCompleted: false,
            ),
          ],
          recommendedCourses: [
            'Figma UI Design (Coursera)',
            'Graphic Design Specialization',
            'Adobe Creative Suite',
            'UX Research Fundamentals',
          ],
          olympiads: [
            'Дизайн конкурстары',
            'Хакатондар',
            'Kreativ Award',
          ],
          projects: [
            'Мобильді қосымша UI дизайны',
            'Бренд айналымы',
            'Веб-сайт прототипі',
          ],
        ),
      ];

  static List<QuestionModel> get testQuestions => [
        QuestionModel(
          id: 'q1',
          question: 'Бос уақытыңда не істегенді ұнатасың?',
          category: 'Қызығушылық',
          options: [
            '💻 Компьютерде бағдарлама немесе ойын жасау',
            '🎨 Сурет салу, дизайн жасау',
            '📚 Кітап оқу, жаңа нәрселер үйрену',
            '🤝 Адамдармен сөйлесу, жаңа достар табу',
          ],
        ),
        QuestionModel(
          id: 'q2',
          question: 'Мектепте қай пән саған ең жеңіл берілетін?',
          category: 'Пәндік бейімділік',
          options: [
            '➗ Математика және физика',
            '🧬 Биология және химия',
            '🗣️ Тіл пәндері (қазақ, ағылшын)',
            '🏛️ Тарих және география',
          ],
        ),
        QuestionModel(
          id: 'q3',
          question: 'Топтық жобада сен қандай рөлде болғанды ұнатасың?',
          category: 'Қабілет',
          options: [
            '🎯 Жетекші (лидер)',
            '🔬 Зерттеуші',
            '✏️ Жасаушы (іс жүзіне асырушы)',
            '🤝 Ұйымдастырушы',
          ],
        ),
        QuestionModel(
          id: 'q4',
          question: 'Болашақта не жасағың келеді?',
          category: 'Қызығушылық',
          options: [
            '🌍 Әлемді өзгертетін технология жасағым келеді',
            '❤️ Адамдарға көмектескім, емдегім келеді',
            '🎭 Өнер, дизайн, музыкамен айналысқым келеді',
            '📊 Бизнес ашып, экономикаға үлес қосқым келеді',
          ],
        ),
        QuestionModel(
          id: 'q5',
          question: 'Қандай жұмыс ортасы саған ыңғайлы?',
          category: 'Қабілет',
          options: [
            '🏠 Үйден қашықтан жұмыс (Remote)',
            '🏢 Үлкен командада офисте',
            '🏥 Адамдармен тікелей жұмыс',
            '🔬 Зертхана немесе ғылыми орта',
          ],
        ),
        QuestionModel(
          id: 'q6',
          question: 'Мәселені шешкенде қалай ойлайсың?',
          category: 'Қабілет',
          options: [
            '🧮 Логика мен сандар арқылы',
            '🎨 Шығармашылық тәсілмен',
            '📖 Зерттеп, ақпарат жинап',
            '💬 Басқалармен ақылдасып',
          ],
        ),
        QuestionModel(
          id: 'q7',
          question: 'Саған қай жетістік маңыздырақ?',
          category: 'Қызығушылық',
          options: [
            '💡 Жаңа нәрсе ойлап табу',
            '🏆 Байқауларда жеңіске жету',
            '❤️ Адамдарға пайдалы болу',
            '💰 Жоғары табыс табу',
          ],
        ),
        QuestionModel(
          id: 'q8',
          question: 'Қай олимпиадаға немесе байқауға қатысқың келер еді?',
          category: 'Пәндік бейімділік',
          options: [
            '🖥️ Информатика олимпиадасы',
            '🔭 Физика немесе математика олимпиадасы',
            '🎨 Шығармашылық байқаулар',
            '🗣️ Пікірсайыс (дебаттар)',
          ],
        ),
      ];
}