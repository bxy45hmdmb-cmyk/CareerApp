class AppStrings {
  final String locale;
  const AppStrings(this.locale);
  bool get isKk => locale == 'kk';
  bool get isRu => locale == 'ru';

  // General
  String get appName => isKk ? 'Кәсіптік Бағдар' : isRu ? 'Карьерный Гид' : 'Career Guide';
  String get retry => isKk ? 'Қайталау' : isRu ? 'Повторить' : 'Retry';
  String get cancel => isKk ? 'Болдырмау' : isRu ? 'Отмена' : 'Cancel';
  String get save => isKk ? 'Сақтау' : isRu ? 'Сохранить' : 'Save';
  String get close => isKk ? 'Жабу' : isRu ? 'Закрыть' : 'Close';
  String get serverError => isKk ? 'Серверге қосылу мүмкін болмады' : isRu ? 'Не удалось подключиться к серверу' : 'Could not connect to server';

  // Bottom nav
  String get navHome => isKk ? 'Басты' : isRu ? 'Главная' : 'Home';
  String get navTest => isKk ? 'Тест' : isRu ? 'Тест' : 'Test';
  String get navFavorites => isKk ? 'Таңдаулы' : isRu ? 'Избранное' : 'Favorites';
  String get navProfile => isKk ? 'Профиль' : isRu ? 'Профиль' : 'Profile';

  // Home screen
  String get greeting => isKk ? 'Қайырлы күн! 👋' : isRu ? 'Добрый день! 👋' : 'Good day! 👋';
  String get dataLoadFailed => isKk ? 'Деректерді жүктеу сәтсіз аяқталды' : isRu ? 'Не удалось загрузить данные' : 'Failed to load data';
  String get highDemand => isKk ? '🔥 Сұранысы жоғары мамандықтар' : isRu ? '🔥 Востребованные профессии' : '🔥 High-demand professions';
  String get progressSection => isKk ? '📊 Прогрес' : isRu ? '📊 Прогресс' : '📊 Progress';
  String get recommended => isKk ? '⭐ Ұсынылған мамандықтар' : isRu ? '⭐ Рекомендуемые профессии' : '⭐ Recommended professions';
  String get findProfession => isKk ? 'Мамандығыңды тап! 🎯' : isRu ? 'Найди свою профессию! 🎯' : 'Find your profession! 🎯';
  String gradeStudent(int g) => isKk ? '$g-сынып оқушысысың' : isRu ? 'Ты ученик $g класса' : 'You are a grade $g student';
  String get takeTestBtn => isKk ? 'Тест тапсыр →' : isRu ? 'Пройти тест →' : 'Take test →';
  String get takeTestBanner => isKk ? 'Тест тапсырыңыз!' : isRu ? 'Пройдите тест!' : 'Take the test!';
  String get takeTestBannerDesc => isKk ? 'Мамандық ұсыныстарын алу үшін тест тапсырыңыз' : isRu ? 'Пройдите тест чтобы получить рекомендации' : 'Take the test to get profession recommendations';
  String get testCompletion => isKk ? 'Тест аяқталу' : isRu ? 'Прохождение теста' : 'Test completion';
  String testCount(int n) => isKk ? '$n рет тапсырылды' : isRu ? 'Пройдено $n раз' : 'Completed $n times';
  String get testNotDone => isKk ? 'Тест тапсырылмаған' : isRu ? 'Тест не пройден' : 'Test not completed';
  String get favoriteProfessions => isKk ? 'Таңдаулы мамандықтар' : isRu ? 'Избранные профессии' : 'Favorite professions';
  String favSaved(int n) => isKk ? '$n мамандық сақталды' : isRu ? '$n профессий сохранено' : '$n professions saved';
  String favCount(int n) => isKk ? '$n мамандық' : isRu ? '$n профессий' : '$n professions';

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
    final en = {
      'very_high': 'Very high demand',
      'high': 'High demand',
      'medium': 'Medium demand',
      'low': 'Low demand',
    };
    return isKk ? (kk[level] ?? level) : isRu ? (ru[level] ?? level) : (en[level] ?? level);
  }

  // Profile screen
  String get myProfile => isKk ? 'Менің профилім' : isRu ? 'Мой профиль' : 'My Profile';
  String get edit => isKk ? '✏️ Өңдеу' : isRu ? '✏️ Изменить' : '✏️ Edit';
  String gradeLabel(int g) => isKk ? '$g-сынып оқушысы' : isRu ? 'Ученик $g класса' : 'Grade $g student';
  String get emailLabel => 'Email';
  String get schoolLabel => isKk ? 'Мектеп' : isRu ? 'Школа' : 'School';
  String get cityLabel => isKk ? 'Қала' : isRu ? 'Город' : 'City';
  String get notFilled => isKk ? 'Жазылмаған' : isRu ? 'Не указано' : 'Not specified';
  String get registrationDate => isKk ? 'Тіркелу' : isRu ? 'Регистрация' : 'Registration';
  String get profileLoadFailed => isKk ? 'Профиль деректерін жүктеу сәтсіз' : isRu ? 'Не удалось загрузить профиль' : 'Failed to load profile';
  String get profileUpdated => isKk ? 'Профиль жаңартылды ✅' : isRu ? 'Профиль обновлён ✅' : 'Profile updated ✅';
  String get photoUpdated => isKk ? 'Фото жаңартылды ✅' : isRu ? 'Фото обновлено ✅' : 'Photo updated ✅';
  String get uploadFailed => isKk ? 'Жүктеу сәтсіз' : isRu ? 'Ошибка загрузки' : 'Upload failed';
  String get saveFailed => isKk ? 'Сақтау сәтсіз' : isRu ? 'Не удалось сохранить' : 'Failed to save';
  String get noData => isKk ? 'Деректер жоқ' : isRu ? 'Данных нет' : 'No data';
  String get changePassword => isKk ? 'Парольді жаңарту' : isRu ? 'Изменить пароль' : 'Change password';
  String get changePhoto => isKk ? 'Фото өзгерту' : isRu ? 'Изменить фото' : 'Change photo';
  String get settings => isKk ? 'Баптаулар' : isRu ? 'Настройки' : 'Settings';
  String get logout => isKk ? 'Шығу' : isRu ? 'Выйти' : 'Log out';
  String get editProfile => isKk ? 'Профильді өңдеу' : isRu ? 'Редактировать профиль' : 'Edit profile';

  // Change password dialog
  String get currentPassword => isKk ? 'Ағымдағы құпиясөз' : isRu ? 'Текущий пароль' : 'Current password';
  String get newPassword => isKk ? 'Жаңа құпиясөз' : isRu ? 'Новый пароль' : 'New password';
  String get confirmNewPassword => isKk ? 'Жаңа құпиясөзді растаңыз' : isRu ? 'Подтвердите новый пароль' : 'Confirm new password';
  String get fillAllFields => isKk ? 'Барлық өрістерді толтырыңыз' : isRu ? 'Заполните все поля' : 'Fill in all fields';
  String get passwordsDoNotMatch => isKk ? 'Жаңа құпиясөздер сәйкес келмейді' : isRu ? 'Пароли не совпадают' : 'Passwords do not match';
  String get passwordRequirementsNotMet => isKk ? 'Жаңа құпиясөз барлық талаптарды орындауы керек' : isRu ? 'Пароль должен соответствовать всем требованиям' : 'Password must meet all requirements';
  String get passwordChanged => isKk ? 'Құпиясөз сәтті өзгертілді' : isRu ? 'Пароль успешно изменён' : 'Password changed successfully';

  // Edit profile dialog
  String get fullName => isKk ? 'Аты-жөні' : isRu ? 'Имя и фамилия' : 'Full name';
  String get gradeField => isKk ? 'Сыныбы' : isRu ? 'Класс' : 'Grade';

  // Password hints
  String get pwRequirements => isKk ? 'Құпиясөз талаптары:' : isRu ? 'Требования к паролю:' : 'Password requirements:';
  String get pwLength => isKk ? 'Кемінде 7 символ' : isRu ? 'Минимум 7 символов' : 'At least 7 characters';
  String get pwUpper => isKk ? 'Кемінде 1 бас әріп (A-Z)' : isRu ? 'Минимум 1 заглавная буква (A-Z)' : 'At least 1 uppercase letter (A-Z)';
  String get pwDigit => isKk ? 'Кемінде 1 цифр (0-9)' : isRu ? 'Минимум 1 цифра (0-9)' : 'At least 1 digit (0-9)';
  String get pwSpecial => isKk ? 'Кемінде 1 арнайы символ (!@#\$...)' : isRu ? 'Минимум 1 спецсимвол (!@#\$...)' : 'At least 1 special character (!@#\$...)';
  String get pwSpecialShort => isKk ? 'Кемінде 1 арнайы символ' : isRu ? 'Минимум 1 спецсимвол' : 'At least 1 special character';

  // Auth screen
  String get loginTitle => isKk ? 'Қош келдің! 👋' : isRu ? 'С возвращением! 👋' : 'Welcome back! 👋';
  String get loginSubtitle => isKk ? 'Жеке кабинетіңе кір' : isRu ? 'Войдите в свой аккаунт' : 'Sign in to your account';
  String get registerTitle => isKk ? 'Тіркел! 🚀' : isRu ? 'Регистрация 🚀' : 'Register! 🚀';
  String get registerSubtitle => isKk ? 'Жаңа аккаунт жасап бастап кет' : isRu ? 'Создайте новый аккаунт' : 'Create a new account';
  String get loginButton => isKk ? 'Кіру' : isRu ? 'Войти' : 'Sign in';
  String get registerButton => isKk ? 'Тіркелу' : isRu ? 'Зарегистрироваться' : 'Register';
  String get alreadyHaveAccount => isKk ? 'Аккаунтың бар ма?' : isRu ? 'Уже есть аккаунт?' : 'Already have an account?';
  String get noAccount => isKk ? 'Аккаунтың жоқ па?' : isRu ? 'Нет аккаунта?' : 'No account?';
  String get toLogin => isKk ? 'Кіру' : isRu ? 'Войти' : 'Sign in';
  String get toRegister => isKk ? 'Тіркел' : isRu ? 'Регистрация' : 'Register';
  String get forgotPassword => isKk ? 'Құпиясөзді ұмыттым' : isRu ? 'Забыл пароль' : 'Forgot password';
  String get emailFieldLabel => isKk ? 'Электронды пошта' : isRu ? 'Электронная почта' : 'Email address';
  String get passwordFieldLabel => isKk ? 'Құпиясөз' : isRu ? 'Пароль' : 'Password';
  String get nameFieldLabel => isKk ? 'Аты-жөні' : isRu ? 'Имя и фамилия' : 'Full name';
  String get nameFieldHint => isKk ? 'Мысалы: Айдана Сейтқали' : isRu ? 'Напр.: Иван Иванов' : 'E.g.: John Smith';
  String get schoolFieldLabel => isKk ? 'Мектеп (міндетті емес)' : isRu ? 'Школа (необязательно)' : 'School (optional)';
  String get schoolFieldHint => isKk ? 'НЗМ №1' : isRu ? 'Школа №1' : 'School №1';
  String get cityFieldLabel => isKk ? 'Қала (міндетті емес)' : isRu ? 'Город (необязательно)' : 'City (optional)';
  String get cityFieldHint => isKk ? 'Астана' : isRu ? 'Астана' : 'Astana';
  String get gradeSelector => isKk ? 'Сыныбы' : isRu ? 'Класс' : 'Grade';
  String get enterEmailAndPw => isKk ? 'Email мен құпиясөзді толтырыңыз' : isRu ? 'Введите email и пароль' : 'Enter email and password';
  String get enterNameError => isKk ? 'Атыңызды жазыңыз' : isRu ? 'Введите ваше имя' : 'Enter your name';

  // Onboarding
  String get skip => isKk ? 'Өткізіп жібер' : isRu ? 'Пропустить' : 'Skip';
  String get continueBtn => isKk ? 'Жалғастыру' : isRu ? 'Продолжить' : 'Continue';
  String get startBtn => isKk ? 'Бастау 🚀' : isRu ? 'Начать 🚀' : 'Start 🚀';
  // Onboarding pages
  String get ob1Title => isKk ? 'Өз жолыңды тап!' : isRu ? 'Найди свой путь!' : 'Find your path!';
  String get ob1Subtitle => isKk
      ? 'Мектеп оқушыларына арналған кәсіптік бағдар беру жүйесі. Қызығушылықтарың мен қабілеттеріңе сай мамандық таңда.'
      : isRu
          ? 'Система профориентации для школьников. Выбери профессию по своим интересам и способностям.'
          : 'A career guidance system for school students. Choose a profession that matches your interests and abilities.';
  String get ob2Title => isKk ? 'Қызығушылықтарыңды анықта' : isRu ? 'Узнай свои интересы' : 'Discover your interests';
  String get ob2Subtitle => isKk
      ? 'Тест тапсыр, өзіңнің күшті жақтарыңды біл және саған сай мамандықтарды ашып көр.'
      : isRu
          ? 'Пройди тест, узнай свои сильные стороны и открой подходящие профессии.'
          : 'Take the test, discover your strengths, and explore professions that suit you.';
  String get ob3Title => isKk ? 'Даму жолыңды жоспарла' : isRu ? 'Спланируй путь развития' : 'Plan your development path';
  String get ob3Subtitle => isKk
      ? 'Таңдаған мамандығыңа жету үшін қажетті қадамдар, курстар және ресурстар туралы нақты ақпарат ал.'
      : isRu
          ? 'Получи конкретную информацию о шагах, курсах и ресурсах для достижения выбранной профессии.'
          : 'Get specific information about the steps, courses, and resources needed to reach your chosen profession.';

  // Verification screen
  String get verifyEmail => isKk ? 'Email-ді растаңыз' : isRu ? 'Подтверждение Email' : 'Verify Email';
  String get verifyCodeSent => isKk
      ? 'Келесі мекен-жайға 6 таңбалы код жіберілді:'
      : isRu
          ? 'На следующий адрес отправлен 6-значный код:'
          : 'A 6-digit code was sent to:';
  String get verify => isKk ? 'Растау' : isRu ? 'Подтвердить' : 'Verify';
  String get resendCode => isKk ? 'Кодты қайта жіберу' : isRu ? 'Отправить код повторно' : 'Resend code';
  String get codeSentAgain => isKk ? 'Растау коды қайта жіберілді' : isRu ? 'Код подтверждения отправлен повторно' : 'Verification code resent';
  String get enterFullCode => isKk ? '6 таңбалы кодты толық енгізіңіз' : isRu ? 'Введите полный 6-значный код' : 'Enter the full 6-digit code';

  // Forgot password
  String get resetPasswordTitle => isKk ? 'Құпиясөзді қалпына келтіру' : isRu ? 'Восстановление пароля' : 'Reset password';
  String get resetPasswordDesc => isKk
      ? 'Тіркелген email мекен-жайыңызды енгізіңіз. Сізге қалпына келтіру коды жіберіледі.'
      : isRu
          ? 'Введите email вашего аккаунта. Вам будет отправлен код восстановления.'
          : 'Enter your account email. A recovery code will be sent to you.';
  String get sendCode => isKk ? 'Код жіберу' : isRu ? 'Отправить код' : 'Send code';
  String get newPasswordTitle => isKk ? 'Жаңа құпиясөз' : isRu ? 'Новый пароль' : 'New password';
  String codeSentTo(String mail) => isKk
      ? '$mail адресіне жіберілген 6 таңбалы кодты енгізіңіз.'
      : isRu
          ? 'Введите 6-значный код, отправленный на $mail.'
          : 'Enter the 6-digit code sent to $mail.';
  String get passwordResetSuccess => isKk ? 'Құпиясөз сәтті өзгертілді' : isRu ? 'Пароль успешно изменён' : 'Password reset successfully';
  String get passwordMismatch => isKk ? 'Құпиясөздер сәйкес келмейді' : isRu ? 'Пароли не совпадают' : 'Passwords do not match';
  String get passwordRequirementsFailed => isKk
      ? 'Құпиясөз барлық талаптарды орындауы керек'
      : isRu
          ? 'Пароль должен соответствовать всем требованиям'
          : 'Password must meet all requirements';
  String get enterEmailError => isKk ? 'Email-ды енгізіңіз' : isRu ? 'Введите email' : 'Enter email';

  // Settings screen
  String get settingsTitle => isKk ? 'Баптаулар' : isRu ? 'Настройки' : 'Settings';
  String get appearance => isKk ? '🎨 Сыртқы түр' : isRu ? '🎨 Внешний вид' : '🎨 Appearance';
  String get darkMode => isKk ? 'Қараңғы режим' : isRu ? 'Тёмный режим' : 'Dark mode';
  String get lightMode => isKk ? 'Жарық режим' : isRu ? 'Светлый режим' : 'Light mode';
  String get notificationsSection => isKk ? '🔔 Хабарландырулар' : isRu ? '🔔 Уведомления' : '🔔 Notifications';
  String get pushNotifications => isKk ? 'Push хабарландырулар' : isRu ? 'Push-уведомления' : 'Push notifications';
  String get aboutApp => isKk ? 'ℹ️ Қосымша туралы' : isRu ? 'ℹ️ О приложении' : 'ℹ️ About app';
  String get version => isKk ? 'Нұсқа' : isRu ? 'Версия' : 'Version';
  String get privacyPolicy => isKk ? 'Құпиялылық саясаты' : isRu ? 'Политика конфиденциальности' : 'Privacy policy';
  String get privacyPolicyContent => isKk
      ? 'Деректеріңіз қорғалған және үшінші тараптарға берілмейді.'
      : isRu
          ? 'Ваши данные защищены и не передаются третьим лицам.'
          : 'Your data is protected and not shared with third parties.';
  String get termsOfUse => isKk ? 'Пайдалану шарттары' : isRu ? 'Условия использования' : 'Terms of use';
  String get termsContent => isKk
      ? 'Бұл қосымша мектеп оқушыларына кәсіптік бағдар беру мақсатында жасалған.'
      : isRu
          ? 'Это приложение создано для профессиональной ориентации школьников.'
          : 'This app was created for career guidance of school students.';
  String get accountSection => isKk ? '⚠️ Аккаунт' : isRu ? '⚠️ Аккаунт' : '⚠️ Account';
  String get logoutConfirm => isKk
      ? 'Аккаунтыңыздан шығуға сенімдісіз бе?'
      : isRu
          ? 'Вы уверены, что хотите выйти из аккаунта?'
          : 'Are you sure you want to log out?';

  // Language section
  String get languageSection => isKk ? '🌐 Тіл' : isRu ? '🌐 Язык' : '🌐 Language';
  String get kazakh => isKk ? 'Қазақша' : isRu ? 'Казахский' : 'Kazakh';
  String get russian => isKk ? 'Орысша' : isRu ? 'Русский' : 'Russian';
  String get english => isKk ? 'Ағылшынша' : isRu ? 'Английский' : 'English';

  // Career test screen
  String get testTitle => isKk ? 'Кәсіптік тест' : isRu ? 'Профориентационный тест' : 'Career test';
  String get testIntroTitle => isKk ? 'Кәсіптік\nБағдар Тесті 🎯' : isRu ? 'Профориентационный\nТест 🎯' : 'Career\nGuidance Test 🎯';
  String get testIntroDesc => isKk
      ? 'Бұл тест сенің қызығушылықтарыңды, қабілеттеріңді және пәндік бейімділіктеріңді анықтап, саған сай мамандықтарды ұсынады.'
      : isRu
          ? 'Этот тест определит твои интересы, способности и склонности, чтобы предложить подходящие профессии.'
          : 'This test will identify your interests, abilities, and inclinations to suggest suitable professions.';
  String get questionCountLabel => isKk ? 'Сұрақ саны' : isRu ? 'Количество вопросов' : 'Number of questions';
  String questionCountValue(int n) => isKk ? '$n сұрақ' : isRu ? '$n вопросов' : '$n questions';
  String get estimatedTimeLabel => isKk ? 'Болжалды уақыт' : isRu ? 'Примерное время' : 'Estimated time';
  String get resultLabel => isKk ? 'Нәтиже' : isRu ? 'Результат' : 'Result';
  String get resultDesc => isKk ? 'Жеке мамандық ұсыныстары' : isRu ? 'Персональные рекомендации' : 'Personal recommendations';
  String get testHistoryBtn => isKk ? 'Тест тарихы' : isRu ? 'История тестов' : 'Test history';
  String get computing => isKk ? 'Нәтиже есептелуде...' : isRu ? 'Вычисляем результат...' : 'Computing result...';
  String questionCounter(int current, int total) => isKk ? 'Сұрақ $current / $total' : isRu ? 'Вопрос $current / $total' : 'Question $current / $total';
  String get testDesc => isKk
      ? 'Өзіңе сай мамандықты анықтауға арналған сұрақтарға жауап бер'
      : isRu
          ? 'Ответь на вопросы для определения подходящей тебе профессии'
          : 'Answer questions to determine the right profession for you';
  String get startTest => isKk ? 'Тестті бастау' : isRu ? 'Начать тест' : 'Start test';
  String get viewHistory => isKk ? 'Нәтижелер тарихы' : isRu ? 'История результатов' : 'Results history';
  String get questionLoadFailed => isKk ? 'Сұрақтарды жүктеу сәтсіз' : isRu ? 'Не удалось загрузить вопросы' : 'Failed to load questions';
  String get noQuestions => isKk ? 'Сұрақтар табылмады' : isRu ? 'Вопросы не найдены' : 'No questions found';
  String get question => isKk ? 'Сұрақ' : isRu ? 'Вопрос' : 'Question';
  String get submitTest => isKk ? 'Аяқтау' : isRu ? 'Завершить' : 'Submit';
  String get answerAll => isKk ? 'Барлық сұрақтарға жауап беріңіз' : isRu ? 'Ответьте на все вопросы' : 'Answer all questions';
  String get submitting => isKk ? 'Жіберілуде...' : isRu ? 'Отправка...' : 'Submitting...';
  String get testSubmitFailed => isKk ? 'Тест жіберу сәтсіз' : isRu ? 'Не удалось отправить тест' : 'Failed to submit test';
  String get retakeTest => isKk ? 'Қайта тапсыру' : isRu ? 'Пройти заново' : 'Retake test';
  String get testCompleted => isKk ? 'Тест тапсырылды ✅' : isRu ? 'Тест пройден ✅' : 'Test completed ✅';
  String get testCompletedDesc => isKk
      ? 'Нәтижеңізге сәйкес мамандықтар ұсынылды'
      : isRu
          ? 'По вашим результатам рекомендованы профессии'
          : 'Professions have been recommended based on your results';
  String get viewResults => isKk ? 'Нәтижені қарау' : isRu ? 'Посмотреть результаты' : 'View results';

  // Profession details screen
  String get descriptionSection => isKk ? '📋 Сипаттама' : isRu ? '📋 Описание' : '📋 Description';
  String get skillsSection => isKk ? '💪 Қажетті дағдылар' : isRu ? '💪 Необходимые навыки' : '💪 Required skills';
  String get opportunitiesSection => isKk ? '🌟 Болашақ мүмкіндіктері' : isRu ? '🌟 Перспективы' : '🌟 Future opportunities';
  String universitiesSection(int n) => isKk ? '🏛️ Қазақстандағы университеттер ($n)' : isRu ? '🏛️ Университеты Казахстана ($n)' : '🏛️ Universities in Kazakhstan ($n)';
  String get noUniversities => isKk ? 'Бұл мамандық бойынша университет деректері жоқ' : isRu ? 'Нет данных об университетах для этой профессии' : 'No university data for this profession';
  String get professionNotFound => isKk ? 'Мамандық табылмады' : isRu ? 'Профессия не найдена' : 'Profession not found';
  String get nationalUniversity => isKk ? '🏆 Ұлттық университет' : isRu ? '🏆 Национальный университет' : '🏆 National university';
  String get salaryLabel => isKk ? 'Жалақы' : isRu ? 'Зарплата' : 'Salary';
  String get demandLabel => isKk ? 'Сұраныс' : isRu ? 'Спрос' : 'Demand';
  String get growthLabel => isKk ? 'Өсім' : isRu ? 'Рост' : 'Growth';
  String get noSalaryData => isKk ? 'Жоқ деректер' : isRu ? 'Нет данных' : 'No data';
  String get addToFavorites => isKk ? 'Таңдаулыларға қосу' : isRu ? 'В избранное' : 'Add to favorites';
  String get removeFromFavoritesBtn => isKk ? 'Таңдаулылардан жою' : isRu ? 'Удалить из избранного' : 'Remove from favorites';
  String get addedToFavorites => isKk ? 'Таңдаулыларға қосылды ⭐' : isRu ? 'Добавлено в избранное ⭐' : 'Added to favorites ⭐';
  String get removedFromFavorites => isKk ? 'Таңдаулылардан жойылды' : isRu ? 'Удалено из избранного' : 'Removed from favorites';
  String get favoriteSaveFailed => isKk ? 'Сақтау сәтсіз аяқталды' : isRu ? 'Не удалось сохранить' : 'Failed to save';
  String demandLevelShort(String level) {
    final kk = {'very_high': 'Өте жоғары', 'high': 'Жоғары', 'medium': 'Орташа', 'low': 'Төмен'};
    final ru = {'very_high': 'Очень высокий', 'high': 'Высокий', 'medium': 'Средний', 'low': 'Низкий'};
    final en = {'very_high': 'Very high', 'high': 'High', 'medium': 'Medium', 'low': 'Low'};
    return isKk ? (kk[level] ?? level) : isRu ? (ru[level] ?? level) : (en[level] ?? level);
  }

  // Favorites screen
  String get favoritesTitle => isKk ? 'Таңдаулы мамандықтар' : isRu ? 'Избранные профессии' : 'Favorite professions';
  String get noFavorites => isKk ? 'Таңдаулы мамандықтар жоқ' : isRu ? 'Нет избранных профессий' : 'No favorite professions';
  String get noFavoritesDesc => isKk
      ? 'Мамандықтарды зерттеп, ұнағандарын сақтаңыз'
      : isRu
          ? 'Изучайте профессии и сохраняйте понравившиеся'
          : 'Explore professions and save the ones you like';
  String get browseProfessions => isKk ? 'Мамандықтарды қарау' : isRu ? 'Просмотр профессий' : 'Browse professions';
  String get removeFromFavorites => isKk ? 'Таңдаулыдан алып тастау' : isRu ? 'Удалить из избранного' : 'Remove from favorites';
  String get favoritesLoadFailed => isKk ? 'Таңдаулыларды жүктеу сәтсіз' : isRu ? 'Не удалось загрузить избранное' : 'Failed to load favorites';
}
