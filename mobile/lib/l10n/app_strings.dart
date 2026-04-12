class AppStrings {
  final String locale;
  const AppStrings(this.locale);
  bool get isKk => locale == 'kk';

  // General
  String get appName => isKk ? 'Кәсіптік Бағдар' : 'Карьерный Гид';
  String get retry => isKk ? 'Қайталау' : 'Повторить';
  String get cancel => isKk ? 'Болдырмау' : 'Отмена';
  String get save => isKk ? 'Сақтау' : 'Сохранить';
  String get close => isKk ? 'Жабу' : 'Закрыть';
  String get serverError => isKk ? 'Серверге қосылу мүмкін болмады' : 'Не удалось подключиться к серверу';

  // Bottom nav
  String get navHome => isKk ? 'Басты' : 'Главная';
  String get navTest => isKk ? 'Тест' : 'Тест';
  String get navFavorites => isKk ? 'Таңдаулы' : 'Избранное';
  String get navProfile => isKk ? 'Профиль' : 'Профиль';

  // Home screen
  String get greeting => isKk ? 'Қайырлы күн! 👋' : 'Добрый день! 👋';
  String get dataLoadFailed => isKk ? 'Деректерді жүктеу сәтсіз аяқталды' : 'Не удалось загрузить данные';
  String get highDemand => isKk ? '🔥 Сұранысы жоғары мамандықтар' : '🔥 Востребованные профессии';
  String get progressSection => isKk ? '📊 Прогрес' : '📊 Прогресс';
  String get recommended => isKk ? '⭐ Ұсынылған мамандықтар' : '⭐ Рекомендуемые профессии';
  String get findProfession => isKk ? 'Мамандығыңды тап! 🎯' : 'Найди свою профессию! 🎯';
  String gradeStudent(int g) => isKk ? '$g-сынып оқушысысың' : 'Ты ученик $g класса';
  String get takeTestBtn => isKk ? 'Тест тапсыр →' : 'Пройти тест →';
  String get takeTestBanner => isKk ? 'Тест тапсырыңыз!' : 'Пройдите тест!';
  String get takeTestBannerDesc => isKk ? 'Мамандық ұсыныстарын алу үшін тест тапсырыңыз' : 'Пройдите тест чтобы получить рекомендации';
  String get testCompletion => isKk ? 'Тест аяқталу' : 'Прохождение теста';
  String testCount(int n) => isKk ? '$n рет тапсырылды' : 'Пройдено $n раз';
  String get testNotDone => isKk ? 'Тест тапсырылмаған' : 'Тест не пройден';
  String get favoriteProfessions => isKk ? 'Таңдаулы мамандықтар' : 'Избранные профессии';
  String favSaved(int n) => isKk ? '$n мамандық сақталды' : '$n профессий сохранено';
  String favCount(int n) => isKk ? '$n мамандық' : '$n профессий';

  // Demand levels
  String demandLevel(String level) {
    final kk = {
      'very_high': 'Өте жоғары сұраныс',
      'high': 'Жоғары сұраныс',
      'medium': 'Орташа сұраныс',
      'low': 'Төмен сұраныс',
    };
    final ru = {
      'very_high': 'Очень высокий спрос',
      'high': 'Высокий спрос',
      'medium': 'Средний спрос',
      'low': 'Низкий спрос',
    };
    return isKk ? (kk[level] ?? level) : (ru[level] ?? level);
  }

  // Profile screen
  String get myProfile => isKk ? 'Менің профилім' : 'Мой профиль';
  String get edit => isKk ? '✏️ Өңдеу' : '✏️ Изменить';
  String gradeLabel(int g) => isKk ? '$g-сынып оқушысы' : 'Ученик $g класса';
  String get emailLabel => isKk ? 'Email' : 'Email';
  String get schoolLabel => isKk ? 'Мектеп' : 'Школа';
  String get cityLabel => isKk ? 'Қала' : 'Город';
  String get notFilled => isKk ? 'Жазылмаған' : 'Не указано';
  String get registrationDate => isKk ? 'Тіркелу' : 'Регистрация';
  String get profileLoadFailed => isKk ? 'Профиль деректерін жүктеу сәтсіз' : 'Не удалось загрузить профиль';
  String get profileUpdated => isKk ? 'Профиль жаңартылды ✅' : 'Профиль обновлён ✅';
  String get photoUpdated => isKk ? 'Фото жаңартылды ✅' : 'Фото обновлено ✅';
  String get uploadFailed => isKk ? 'Жүктеу сәтсіз' : 'Ошибка загрузки';
  String get saveFailed => isKk ? 'Сақтау сәтсіз' : 'Не удалось сохранить';
  String get noData => isKk ? 'Деректер жоқ' : 'Данных нет';
  String get changePassword => isKk ? 'Парольді жаңарту' : 'Изменить пароль';
  String get changePhoto => isKk ? 'Фото өзгерту' : 'Изменить фото';
  String get settings => isKk ? 'Баптаулар' : 'Настройки';
  String get logout => isKk ? 'Шығу' : 'Выйти';
  String get editProfile => isKk ? 'Профильді өңдеу' : 'Редактировать профиль';

  // Change password dialog
  String get currentPassword => isKk ? 'Ағымдағы құпиясөз' : 'Текущий пароль';
  String get newPassword => isKk ? 'Жаңа құпиясөз' : 'Новый пароль';
  String get confirmNewPassword => isKk ? 'Жаңа құпиясөзді растаңыз' : 'Подтвердите новый пароль';
  String get fillAllFields => isKk ? 'Барлық өрістерді толтырыңыз' : 'Заполните все поля';
  String get passwordsDoNotMatch => isKk ? 'Жаңа құпиясөздер сәйкес келмейді' : 'Пароли не совпадают';
  String get passwordRequirementsNotMet => isKk ? 'Жаңа құпиясөз барлық талаптарды орындауы керек' : 'Пароль должен соответствовать всем требованиям';
  String get passwordChanged => isKk ? 'Құпиясөз сәтті өзгертілді' : 'Пароль успешно изменён';

  // Edit profile dialog
  String get fullName => isKk ? 'Аты-жөні' : 'Имя и фамилия';
  String get gradeField => isKk ? 'Сыныбы' : 'Класс';

  // Password hints
  String get pwRequirements => isKk ? 'Құпиясөз талаптары:' : 'Требования к паролю:';
  String get pwLength => isKk ? 'Кемінде 7 символ' : 'Минимум 7 символов';
  String get pwUpper => isKk ? 'Кемінде 1 бас әріп (A-Z)' : 'Минимум 1 заглавная буква (A-Z)';
  String get pwDigit => isKk ? 'Кемінде 1 цифр (0-9)' : 'Минимум 1 цифра (0-9)';
  String get pwSpecial => isKk ? 'Кемінде 1 арнайы символ (!@#\$...)' : 'Минимум 1 спецсимвол (!@#\$...)';
  String get pwSpecialShort => isKk ? 'Кемінде 1 арнайы символ' : 'Минимум 1 спецсимвол';

  // Auth screen
  String get loginTitle => isKk ? 'Қош келдің! 👋' : 'С возвращением! 👋';
  String get loginSubtitle => isKk ? 'Жеке кабинетіңе кір' : 'Войдите в свой аккаунт';
  String get registerTitle => isKk ? 'Тіркел! 🚀' : 'Регистрация 🚀';
  String get registerSubtitle => isKk ? 'Жаңа аккаунт жасап бастап кет' : 'Создайте новый аккаунт';
  String get loginButton => isKk ? 'Кіру' : 'Войти';
  String get registerButton => isKk ? 'Тіркелу' : 'Зарегистрироваться';
  String get alreadyHaveAccount => isKk ? 'Аккаунтың бар ма?' : 'Уже есть аккаунт?';
  String get noAccount => isKk ? 'Аккаунтың жоқ па?' : 'Нет аккаунта?';
  String get toLogin => isKk ? 'Кіру' : 'Войти';
  String get toRegister => isKk ? 'Тіркел' : 'Регистрация';
  String get forgotPassword => isKk ? 'Құпиясөзді ұмыттым' : 'Забыл пароль';
  String get emailFieldLabel => isKk ? 'Электронды пошта' : 'Электронная почта';
  String get passwordFieldLabel => isKk ? 'Құпиясөз' : 'Пароль';
  String get nameFieldLabel => isKk ? 'Аты-жөні' : 'Имя и фамилия';
  String get nameFieldHint => isKk ? 'Мысалы: Айдана Сейтқали' : 'Напр.: Иван Иванов';
  String get schoolFieldLabel => isKk ? 'Мектеп (міндетті емес)' : 'Школа (необязательно)';
  String get schoolFieldHint => isKk ? 'НЗМ №1' : 'Школа №1';
  String get cityFieldLabel => isKk ? 'Қала (міндетті емес)' : 'Город (необязательно)';
  String get cityFieldHint => isKk ? 'Астана' : 'Астана';
  String get gradeSelector => isKk ? 'Сыныбы' : 'Класс';
  String get enterEmailAndPw => isKk ? 'Email мен құпиясөзді толтырыңыз' : 'Введите email и пароль';
  String get enterNameError => isKk ? 'Атыңызды жазыңыз' : 'Введите ваше имя';

  // Onboarding
  String get skip => isKk ? 'Өткізіп жібер' : 'Пропустить';
  String get continueBtn => isKk ? 'Жалғастыру' : 'Продолжить';
  String get startBtn => isKk ? 'Бастау 🚀' : 'Начать 🚀';
  // Onboarding pages
  String get ob1Title => isKk ? 'Өз жолыңды тап!' : 'Найди свой путь!';
  String get ob1Subtitle => isKk
      ? 'Мектеп оқушыларына арналған кәсіптік бағдар беру жүйесі. Қызығушылықтарың мен қабілеттеріңе сай мамандық таңда.'
      : 'Система профориентации для школьников. Выбери профессию по своим интересам и способностям.';
  String get ob2Title => isKk ? 'Қызығушылықтарыңды анықта' : 'Узнай свои интересы';
  String get ob2Subtitle => isKk
      ? 'Тест тапсыр, өзіңнің күшті жақтарыңды біл және саған сай мамандықтарды ашып көр.'
      : 'Пройди тест, узнай свои сильные стороны и открой подходящие профессии.';
  String get ob3Title => isKk ? 'Даму жолыңды жоспарла' : 'Спланируй путь развития';
  String get ob3Subtitle => isKk
      ? 'Таңдаған мамандығыңа жету үшін қажетті қадамдар, курстар және ресурстар туралы нақты ақпарат ал.'
      : 'Получи конкретную информацию о шагах, курсах и ресурсах для достижения выбранной профессии.';

  // Verification screen
  String get verifyEmail => isKk ? 'Email-ді растаңыз' : 'Подтверждение Email';
  String get verifyCodeSent => isKk
      ? 'Келесі мекен-жайға 6 таңбалы код жіберілді:'
      : 'На следующий адрес отправлен 6-значный код:';
  String get verify => isKk ? 'Растау' : 'Подтвердить';
  String get resendCode => isKk ? 'Кодты қайта жіберу' : 'Отправить код повторно';
  String get codeSentAgain => isKk ? 'Растау коды қайта жіберілді' : 'Код подтверждения отправлен повторно';
  String get enterFullCode => isKk ? '6 таңбалы кодты толық енгізіңіз' : 'Введите полный 6-значный код';

  // Forgot password
  String get resetPasswordTitle => isKk ? 'Құпиясөзді қалпына келтіру' : 'Восстановление пароля';
  String get resetPasswordDesc => isKk
      ? 'Тіркелген email мекен-жайыңызды енгізіңіз. Сізге қалпына келтіру коды жіберіледі.'
      : 'Введите email вашего аккаунта. Вам будет отправлен код восстановления.';
  String get sendCode => isKk ? 'Код жіберу' : 'Отправить код';
  String get newPasswordTitle => isKk ? 'Жаңа құпиясөз' : 'Новый пароль';
  String codeSentTo(String mail) => isKk
      ? '$mail адресіне жіберілген 6 таңбалы кодты енгізіңіз.'
      : 'Введите 6-значный код, отправленный на $mail.';
  String get passwordResetSuccess => isKk ? 'Құпиясөз сәтті өзгертілді' : 'Пароль успешно изменён';
  String get passwordMismatch => isKk ? 'Құпиясөздер сәйкес келмейді' : 'Пароли не совпадают';
  String get passwordRequirementsFailed => isKk
      ? 'Құпиясөз барлық талаптарды орындауы керек'
      : 'Пароль должен соответствовать всем требованиям';
  String get enterEmailError => isKk ? 'Email-ды енгізіңіз' : 'Введите email';

  // Settings screen
  String get settingsTitle => isKk ? 'Баптаулар' : 'Настройки';
  String get appearance => isKk ? '🎨 Сыртқы түр' : '🎨 Внешний вид';
  String get darkMode => isKk ? 'Қараңғы режим' : 'Тёмный режим';
  String get lightMode => isKk ? 'Жарық режим' : 'Светлый режим';
  String get notificationsSection => isKk ? '🔔 Хабарландырулар' : '🔔 Уведомления';
  String get pushNotifications => isKk ? 'Push хабарландырулар' : 'Push-уведомления';
  String get aboutApp => isKk ? 'ℹ️ Қосымша туралы' : 'ℹ️ О приложении';
  String get version => isKk ? 'Нұсқа' : 'Версия';
  String get privacyPolicy => isKk ? 'Құпиялылық саясаты' : 'Политика конфиденциальности';
  String get privacyPolicyContent => isKk
      ? 'Деректеріңіз қорғалған және үшінші тараптарға берілмейді.'
      : 'Ваши данные защищены и не передаются третьим лицам.';
  String get termsOfUse => isKk ? 'Пайдалану шарттары' : 'Условия использования';
  String get termsContent => isKk
      ? 'Бұл қосымша мектеп оқушыларына кәсіптік бағдар беру мақсатында жасалған.'
      : 'Это приложение создано для профессиональной ориентации школьников.';
  String get accountSection => isKk ? '⚠️ Аккаунт' : '⚠️ Аккаунт';
  String get logoutConfirm => isKk
      ? 'Аккаунтыңыздан шығуға сенімдісіз бе?'
      : 'Вы уверены, что хотите выйти из аккаунта?';

  // Language section
  String get languageSection => isKk ? '🌐 Тіл' : '🌐 Язык';
  String get kazakh => isKk ? 'Қазақша' : 'Казахский';
  String get russian => isKk ? 'Орысша' : 'Русский';

  // Career test screen
  String get testTitle => isKk ? 'Кәсіптік тест' : 'Профориентационный тест';
  String get testIntroTitle => isKk ? 'Кәсіптік\nБағдар Тесті 🎯' : 'Профориентационный\nТест 🎯';
  String get testIntroDesc => isKk
      ? 'Бұл тест сенің қызығушылықтарыңды, қабілеттеріңді және пәндік бейімділіктеріңді анықтап, саған сай мамандықтарды ұсынады.'
      : 'Этот тест определит твои интересы, способности и склонности, чтобы предложить подходящие профессии.';
  String get questionCountLabel => isKk ? 'Сұрақ саны' : 'Количество вопросов';
  String questionCountValue(int n) => isKk ? '$n сұрақ' : '$n вопросов';
  String get estimatedTimeLabel => isKk ? 'Болжалды уақыт' : 'Примерное время';
  String get resultLabel => isKk ? 'Нәтиже' : 'Результат';
  String get resultDesc => isKk ? 'Жеке мамандық ұсыныстары' : 'Персональные рекомендации';
  String get testHistoryBtn => isKk ? 'Тест тарихы' : 'История тестов';
  String get computing => isKk ? 'Нәтиже есептелуде...' : 'Вычисляем результат...';
  String questionCounter(int current, int total) => isKk ? 'Сұрақ $current / $total' : 'Вопрос $current / $total';
  String get testDesc => isKk
      ? 'Өзіңе сай мамандықты анықтауға арналған сұрақтарға жауап бер'
      : 'Ответь на вопросы для определения подходящей тебе профессии';
  String get startTest => isKk ? 'Тестті бастау' : 'Начать тест';
  String get viewHistory => isKk ? 'Нәтижелер тарихы' : 'История результатов';
  String get questionLoadFailed => isKk ? 'Сұрақтарды жүктеу сәтсіз' : 'Не удалось загрузить вопросы';
  String get noQuestions => isKk ? 'Сұрақтар табылмады' : 'Вопросы не найдены';
  String get question => isKk ? 'Сұрақ' : 'Вопрос';
  String get submitTest => isKk ? 'Аяқтау' : 'Завершить';
  String get answerAll => isKk ? 'Барлық сұрақтарға жауап беріңіз' : 'Ответьте на все вопросы';
  String get submitting => isKk ? 'Жіберілуде...' : 'Отправка...';
  String get testSubmitFailed => isKk ? 'Тест жіберу сәтсіз' : 'Не удалось отправить тест';
  String get retakeTest => isKk ? 'Қайта тапсыру' : 'Пройти заново';
  String get testCompleted => isKk ? 'Тест тапсырылды ✅' : 'Тест пройден ✅';
  String get testCompletedDesc => isKk
      ? 'Нәтижеңізге сәйкес мамандықтар ұсынылды'
      : 'По вашим результатам рекомендованы профессии';
  String get viewResults => isKk ? 'Нәтижені қарау' : 'Посмотреть результаты';

  // Profession details screen
  String get descriptionSection => isKk ? '📋 Сипаттама' : '📋 Описание';
  String get skillsSection => isKk ? '💪 Қажетті дағдылар' : '💪 Необходимые навыки';
  String get opportunitiesSection => isKk ? '🌟 Болашақ мүмкіндіктері' : '🌟 Перспективы';
  String universitiesSection(int n) => isKk ? '🏛️ Қазақстандағы университеттер ($n)' : '🏛️ Университеты Казахстана ($n)';
  String get noUniversities => isKk ? 'Бұл мамандық бойынша университет деректері жоқ' : 'Нет данных об университетах для этой профессии';
  String get professionNotFound => isKk ? 'Мамандық табылмады' : 'Профессия не найдена';
  String get nationalUniversity => isKk ? '🏆 Ұлттық университет' : '🏆 Национальный университет';
  String get salaryLabel => isKk ? 'Жалақы' : 'Зарплата';
  String get demandLabel => isKk ? 'Сұраныс' : 'Спрос';
  String get growthLabel => isKk ? 'Өсім' : 'Рост';
  String get noSalaryData => isKk ? 'Жоқ деректер' : 'Нет данных';
  String get addToFavorites => isKk ? 'Таңдаулыларға қосу' : 'В избранное';
  String get removeFromFavoritesBtn => isKk ? 'Таңдаулылардан жою' : 'Удалить из избранного';
  String get addedToFavorites => isKk ? 'Таңдаулыларға қосылды ⭐' : 'Добавлено в избранное ⭐';
  String get removedFromFavorites => isKk ? 'Таңдаулылардан жойылды' : 'Удалено из избранного';
  String get favoriteSaveFailed => isKk ? 'Сақтау сәтсіз аяқталды' : 'Не удалось сохранить';
  String demandLevelShort(String level) {
    final kk = {'very_high': 'Өте жоғары', 'high': 'Жоғары', 'medium': 'Орташа', 'low': 'Төмен'};
    final ru = {'very_high': 'Очень высокий', 'high': 'Высокий', 'medium': 'Средний', 'low': 'Низкий'};
    return isKk ? (kk[level] ?? level) : (ru[level] ?? level);
  }

  // Favorites screen
  String get favoritesTitle => isKk ? 'Таңдаулы мамандықтар' : 'Избранные профессии';
  String get noFavorites => isKk ? 'Таңдаулы мамандықтар жоқ' : 'Нет избранных профессий';
  String get noFavoritesDesc => isKk
      ? 'Мамандықтарды зерттеп, ұнағандарын сақтаңыз'
      : 'Изучайте профессии и сохраняйте понравившиеся';
  String get browseProfessions => isKk ? 'Мамандықтарды қарау' : 'Просмотр профессий';
  String get removeFromFavorites => isKk ? 'Таңдаулыдан алып тастау' : 'Удалить из избранного';
  String get favoritesLoadFailed => isKk ? 'Таңдаулыларды жүктеу сәтсіз' : 'Не удалось загрузить избранное';
}
