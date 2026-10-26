// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Головна';

  @override
  String get tabPhotoshoot => 'Зйомка';

  @override
  String get tabCloset => 'Гардероб';

  @override
  String get tabOutfits => 'Образи';

  @override
  String get tabMore => 'Ще';

  @override
  String get actionAddItem => 'Додати річ';

  @override
  String get actionCreateOutfit => 'Створити образ';

  @override
  String get actionCancel => 'Скасувати';

  @override
  String get actionDelete => 'Видалити';

  @override
  String get actionSave => 'Зберегти';

  @override
  String get actionRetry => 'Спробувати знову';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionNext => 'Далі';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionClose => 'Закрити';

  @override
  String get actionSearch => 'Пошук';

  @override
  String get actionContinue => 'Продовжити';

  @override
  String get stateLoading => 'Завантаження';

  @override
  String get stateErrorTitle => 'Щось пішло не так';

  @override
  String get stateErrorBody =>
      'Спробуйте ще раз. Якщо помилка повторюється, зверніться до підтримки.';

  @override
  String get stateOfflineTitle => 'Немає підключення';

  @override
  String get stateOfflineBody =>
      'Підключіться до мережі, щоб синхронізувати гардероб та створювати образи.';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsAccountSection => 'Акаунт';

  @override
  String get settingsPreferencesSection => 'Параметри';

  @override
  String get settingsPlanBilling => 'План та оплата';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsNotifications => 'Сповіщення';

  @override
  String get settingsUnits => 'Одиниці виміру';

  @override
  String get settingsAppearance => 'Вигляд';

  @override
  String get settingsPrivacySection => 'Конфіденційність та дані';

  @override
  String get settingsAboutSection => 'Про програму';

  @override
  String get settingsSignOut => 'Вийти';

  @override
  String get settingsDeleteAccount => 'Видалити акаунт';

  @override
  String get settingsDeleteAccountTitle => 'Видалити акаунт?';

  @override
  String get settingsDeleteAccountBody =>
      'Це видалить ваш гардероб, образи, фото та профіль. Відновити дані буде неможливо.';

  @override
  String get settingsUnitsImperial => 'Імперська (дюйми, фунти)';

  @override
  String get settingsUnitsMetric => 'Метрична (см, кг)';

  @override
  String get languageTitle => 'Мова';

  @override
  String get languageSystem => 'Як у системі';

  @override
  String get languageSystemBody =>
      'FitCheck AI використовує мову вашого пристрою.';

  @override
  String get languageSearchHint => 'Пошук мов';

  @override
  String get languageCurrent => 'Поточна';

  @override
  String get languageReviewNote =>
      'Цей переклад новий. Повідомте, якщо щось звучить некоректно.';

  @override
  String get languageChanged => 'Мову оновлено';

  @override
  String get paywallTitle => 'Оберіть план';

  @override
  String get paywallTrialBadge => '1 місяць безкоштовно';

  @override
  String get paywallTrialTitle => 'Перший місяць Pro безкоштовно';

  @override
  String get paywallTrialBody =>
      'Завантажте весь гардероб одразу. Потім додавайте речі поступово.';

  @override
  String get paywallFreeForeverTitle => 'Безкоштовно назавжди';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Картка не потрібна. Щомісяця ви отримуєте $uploads ШІ-завантажень, $outfits образів та $images фотосесій на день.';
  }

  @override
  String get paywallCtaTrial => 'Почати безкоштовний місяць';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Перейти на $plan';
  }

  @override
  String get paywallRestore => 'Відновити покупки';

  @override
  String get paywallManage => 'Керувати підпискою';

  @override
  String get paywallTerms => 'Умови використання';

  @override
  String get paywallPrivacy => 'Політика конфіденційності';

  @override
  String get paywallPerMonth => 'на місяць';

  @override
  String get paywallPerYear => 'на рік';

  @override
  String get paywallBestValue => 'Найкраща ціна';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Безкоштовна пробна версія лише для нових користувачів. Після завершення пробного періоду підписка Pro поновлюється за $price, якщо її не скасувати принаймні за 24 години до закінчення.';
  }

  @override
  String get introTitle => 'Ваш гардероб нарешті впорядковано';

  @override
  String get introBody =>
      'Сфотографуйте свій одяг один раз. Отримуйте ідеї образів, віртуальні примірки та студійні фото з того, що вже маєте.';

  @override
  String get introStart => 'Почати';

  @override
  String get introHaveAccount => 'Я вже маю акаунт';

  @override
  String get introSkip => 'Пропустити';

  @override
  String get authSignIn => 'Увійти';

  @override
  String get authSignUp => 'Створити акаунт';

  @override
  String get authEmail => 'Електронна пошта';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authForgotPassword => 'Забули пароль?';

  @override
  String get authContinueApple => 'Продовжити з Apple';

  @override
  String get authContinueGoogle => 'Продовжити з Google';

  @override
  String get authOrDivider => 'або';

  @override
  String get wardrobeTitle => 'Гардероб';

  @override
  String get wardrobeEmptyTitle => 'Ваш гардероб порожній';

  @override
  String get wardrobeEmptyBody =>
      'Додайте першу річ або завантажте фото всього гардероба одразу.';

  @override
  String get wardrobeAddFirst => 'Додати першу річ';

  @override
  String get wardrobeSearchHint => 'Пошук у гардеробі';

  @override
  String get categoryTops => 'Верх';

  @override
  String get categoryBottoms => 'Низ';

  @override
  String get categoryShoes => 'Взуття';

  @override
  String get categoryAccessories => 'Аксесуари';

  @override
  String get categoryOuterwear => 'Верхній одяг';

  @override
  String get categorySwimwear => 'Купальники';

  @override
  String get categoryActivewear => 'Спортивний одяг';

  @override
  String get categoryOther => 'Інше';

  @override
  String get conditionClean => 'Чистий';

  @override
  String get conditionDirty => 'Брудний';

  @override
  String get conditionLaundry => 'У пранні';

  @override
  String get conditionRepair => 'Потребує ремонту';

  @override
  String get conditionDonate => 'Віддати';

  @override
  String get seasonSpring => 'Весна';

  @override
  String get seasonSummer => 'Літо';

  @override
  String get seasonFall => 'Осінь';

  @override
  String get seasonWinter => 'Зима';

  @override
  String get seasonAll => 'Всесезонний';

  @override
  String get styleCasual => 'Кежуал';

  @override
  String get styleFormal => 'Офіційний';

  @override
  String get styleBusiness => 'Діловий';

  @override
  String get styleSporty => 'Спортивний';

  @override
  String get styleBohemian => 'Бохо';

  @override
  String get styleStreetwear => 'Вуличний';

  @override
  String get styleVintage => 'Вінтаж';

  @override
  String get styleMinimalist => 'Мінімалізм';

  @override
  String get styleRomantic => 'Романтичний';

  @override
  String get styleEdgy => 'Зухвалий';

  @override
  String get stylePreppy => 'Преппі';

  @override
  String get styleArtsy => 'Арт';

  @override
  String get styleClassic => 'Класичний';

  @override
  String get styleElegant => 'Елегантний';

  @override
  String get styleOther => 'Інше';

  @override
  String get occasionWork => 'Робота';

  @override
  String get occasionDateNight => 'Побачення';

  @override
  String get occasionTravel => 'Подорож';

  @override
  String get occasionWedding => 'Весілля';

  @override
  String get occasionGym => 'Спортзал';

  @override
  String get occasionWeekend => 'Вихідні';

  @override
  String get occasionParty => 'Вечірка';

  @override
  String get occasionInterview => 'Співбесіда';

  @override
  String get colorBlack => 'Чорний';

  @override
  String get colorWhite => 'Білий';

  @override
  String get colorGrey => 'Сірий';

  @override
  String get colorNavy => 'Темно-синій';

  @override
  String get colorBrown => 'Коричневий';

  @override
  String get colorRed => 'Червоний';

  @override
  String get colorBlue => 'Синій';

  @override
  String get colorGreen => 'Зелений';

  @override
  String get colorPink => 'Рожевий';

  @override
  String get colorPurple => 'Фіолетовий';

  @override
  String get colorYellow => 'Жовтий';

  @override
  String get colorOrange => 'Помаранчевий';

  @override
  String get colorBeige => 'Бежевий';

  @override
  String get dateToday => 'Сьогодні';

  @override
  String get dateYesterday => 'Вчора';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count днів тому',
      few: '$count дні тому',
      one: '1 день тому',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тижнів тому',
      few: '$count тижні тому',
      one: '1 тиждень тому',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count місяців тому',
      few: '$count місяці тому',
      one: '1 місяць тому',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count років тому',
      few: '$count роки тому',
      one: '1 рік тому',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Подобається FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Ваша оцінка допоможе іншим знайти свій стиль.';

  @override
  String get ratingPromptYes => 'Оцінити';

  @override
  String get ratingPromptNo => 'Не зараз';

  @override
  String get closetNoMatchesTitle => 'Немає результатів';

  @override
  String get closetNoMatchesBody => 'Спробуйте змінити фільтри або пошук.';

  @override
  String get closetClearFilters => 'Очистити фільтри';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count речей',
      few: '$count речі',
      one: '1 річ',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Завантаження речей';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вибрано',
      one: '1 вибрано',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Видалити вибране';

  @override
  String get closetCancelSelection => 'Скасувати вибір';

  @override
  String get closetCloseSearch => 'Закрити пошук';

  @override
  String get closetShowGrid => 'Сіткою';

  @override
  String get closetShowList => 'Списком';

  @override
  String get closetShowRows => 'Рядами';

  @override
  String get closetStatsTitle => 'Статистика гардероба';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видалити $count речі?',
      many: 'Видалити $count речей?',
      few: 'Видалити $count речі?',
      one: 'Видалити 1 річ?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Образи, що містять ці речі, зміняться.';

  @override
  String get closetSortBy => 'Сортувати за';

  @override
  String get closetFavourites => 'Обране';

  @override
  String get closetFavourite => 'Додати в обране';

  @override
  String get closetUnfavourite => 'Видалити з обраного';

  @override
  String get closetWoreToday => 'Вдягав сьогодні';

  @override
  String closetWornTimes(int count) {
    return 'Вдягнено $count×';
  }

  @override
  String get closetCategoryLabel => 'Категорія';

  @override
  String get closetUseCaseLabel => 'Привід';

  @override
  String get closetAnyUseCase => 'Будь-який';

  @override
  String get closetOtherUseCase => 'Інший привід';

  @override
  String get closetOtherUseCaseHint => 'Наприклад, бранч';

  @override
  String get closetUseUseCase => 'Використати';

  @override
  String get closetClearAll => 'Очистити все';

  @override
  String get sortNewest => 'Спочатку нові';

  @override
  String get sortOldest => 'Спочатку старі';

  @override
  String get sortName => 'Назва (А–Я)';

  @override
  String get sortMostWorn => 'Найчастіше вдягані';

  @override
  String get useCaseInformal => 'Повсякденний';

  @override
  String get useCaseDate => 'Побачення';

  @override
  String get useCaseDinner => 'Вечеря';

  @override
  String get useCaseLunch => 'Обід';

  @override
  String get actionSelect => 'Вибрати';

  @override
  String get actionEdit => 'Редагувати';

  @override
  String get actionFilter => 'Фільтр';

  @override
  String get actionSort => 'Сортувати';

  @override
  String get actionAll => 'Усі';

  @override
  String get dashboardStartClosetTitle => 'Створіть гардероб';

  @override
  String get dashboardStartClosetBody =>
      'Сфотографуйте кілька речей. Ми додамо теги автоматично.';

  @override
  String get dashboardPieces => 'речей';

  @override
  String get dashboardOutfits => 'образів';

  @override
  String get dashboardDayStreak => 'днів поспіль';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count цього місяця';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Рекорд: $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count улюблених',
      many: '$count улюблених',
      few: '$count улюблені',
      one: '1 улюблений',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count збережених образів',
      few: '$count збережених образи',
      one: '1 збережений образ',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Найчастіше: $name, $count разів';
  }

  @override
  String get setupSkip => 'Пропустити налаштування';

  @override
  String get setupWhoTitle => 'Кого ми одягаємо?';

  @override
  String get setupWhoBody =>
      'Виберіть модель для примірки. Ви зможете змінити це у профілі.';

  @override
  String get setupStyleTitle => 'Що ви носите найчастіше?';

  @override
  String get setupStyleBody =>
      'Виберіть будь-що. Ми підберемо образи на основі вашого вибору.';

  @override
  String get setupClosetTitle => 'Додайте перші речі.';

  @override
  String get setupClosetBody =>
      'Сфотографуйте одяг окремо або купою. Кожна річ буде розпізнана та збережена.';

  @override
  String get setupAddClothes => 'Додати одяг';

  @override
  String get setupStylesLabel => 'Стилі';

  @override
  String get setupOccasionsLabel => 'Приводи';

  @override
  String get setupSkipStep => 'Пропустити';

  @override
  String get setupLater => 'Пізніше';

  @override
  String get setupSaveError => 'Не вдалося зберегти';

  @override
  String get genderWomen => 'Жіночий';

  @override
  String get genderMen => 'Чоловічий';

  @override
  String get genderNonBinary => 'Небінарна';

  @override
  String get genderPreferNotToSay => 'Не вказано';

  @override
  String get outfitEmptyTitle => 'Ще немає образів';

  @override
  String get outfitEmptyBody =>
      'Поєднуйте речі зі своєї шафи та зберігайте образи.';

  @override
  String get outfitNoMatchesTitle => 'Образів не знайдено';

  @override
  String get outfitSearchHint => 'Пошук образів';

  @override
  String get outfitLoading => 'Завантаження образів';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count образів',
      few: '$count образи',
      one: '1 образ',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Стиль та сезон';

  @override
  String get outfitCollections => 'Колекції';

  @override
  String get outfitDuplicate => 'Дублювати';

  @override
  String get outfitDeleteTitle => 'Видалити цей образ?';

  @override
  String get outfitDeleteBody => 'Речі залишаться у вашій шафі.';

  @override
  String get outfitDrafts => 'Чернетки';

  @override
  String get outfitDraft => 'Чернетка';

  @override
  String get filterStyle => 'Стиль';

  @override
  String get filterSeason => 'Сезон';

  @override
  String get itemDetailDeleteTitle => 'Видалити цю річ?';

  @override
  String get itemDetailDeleteBody => 'Образи з цією річчю втратять її.';

  @override
  String get itemAddFavourite => 'Додати до обраного';

  @override
  String itemSize(String size) {
    return 'Розмір $size';
  }

  @override
  String get itemColours => 'Кольори';

  @override
  String get itemMaterial => 'Матеріал';

  @override
  String get itemPattern => 'Принт';

  @override
  String get itemUseCases => 'Призначення';

  @override
  String get itemKeptIn => 'Зберігається в';

  @override
  String get itemPrice => 'Ціна';

  @override
  String get itemBought => 'Куплено';

  @override
  String get itemTags => 'Теги';

  @override
  String get itemAdded => 'Додано';

  @override
  String get itemTimesWornLabel => 'кількість одягань';

  @override
  String get itemLastWornLabel => 'останній раз';

  @override
  String get itemNeverWorn => 'Жодного разу';

  @override
  String get authEntryBody =>
      'Кожна річ у вашому гардеробі, стилізована FitCheck AI. Плануйте образи, приміряйте та фотографуйте.';

  @override
  String get authCreateCloset => 'Створити гардероб';

  @override
  String get authWelcomeBack => 'З поверненням';

  @override
  String get authSignInBody => 'Увійдіть, щоб відкрити свій гардероб.';

  @override
  String get authCreateAccount => 'Створити акаунт';

  @override
  String get authCreateClosetBody =>
      'Це займе хвилину. Перші речі безкоштовно.';

  @override
  String get authName => 'Ім\'я';

  @override
  String get authConfirmPassword => 'Підтвердьте пароль';

  @override
  String get authReferralCode => 'Реферальний код (необов\'язково)';

  @override
  String get authResetTitle => 'Скинути пароль';

  @override
  String get authResetBody =>
      'Ми надішлемо посилання для створення нового пароля.';

  @override
  String get authSendResetLink => 'Надіслати посилання';

  @override
  String get authBackToSignIn => 'Назад до входу';

  @override
  String get authEnterEmail => 'Введіть email';

  @override
  String get authEnterValidEmail => 'Введіть коректний email';

  @override
  String get authEnterPassword => 'Введіть пароль';

  @override
  String get authPasswordTooShort => 'Мінімум 6 символів';

  @override
  String get authShowPassword => 'Показати пароль';

  @override
  String get authHidePassword => 'Приховати пароль';

  @override
  String get authNewHere => 'Вперше тут?';

  @override
  String authConfirmEmail(String email) {
    return 'Підтвердьте $email перед входом. Перевірте пошту.';
  }

  @override
  String get authResendEmail => 'Надіслати ще раз';

  @override
  String get authResendingEmail => 'Надсилання…';

  @override
  String get authPasswordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get authEnterName => 'Введіть ім\'я';

  @override
  String get authChoosePassword => 'Оберіть пароль';

  @override
  String get authHaveAccount => 'Вже маєте акаунт?';

  @override
  String get authCodeAccepted => 'Код прийнято';

  @override
  String get authCodeNotFound => 'Код не знайдено';

  @override
  String authReferralFrom(String name) {
    return 'Від $name. Ви обидва отримаєте місяць безкоштовно.';
  }

  @override
  String get authReferralInvalid => 'Ми не змогли знайти цей код.';

  @override
  String authResetSent(String email) {
    return 'Надіслано на $email. Відкрийте посилання на цьому телефоні.';
  }

  @override
  String get introSlide1Title => 'Сфотографуйте гардероб';

  @override
  String get introSlide1Body =>
      'Зробіть фото купи одягу. Кожна річ буде автоматично розпізнана та збережена.';

  @override
  String get introSlide2Title => 'Одягайтеся швидше';

  @override
  String get introSlide2Body =>
      'Образи з вашого гардероба, підібрані під ваші плани та погоду.';

  @override
  String get introSlide3Title => 'Приміряйте перед виходом';

  @override
  String get introSlide3Body =>
      'Приміряйте образи на своє фото або знімайте їх як у професійній зйомці.';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsTemperature => 'Температура';

  @override
  String get settingsEmailUpdates => 'Email-розсилка';

  @override
  String get settingsEmailUpdatesBody => 'Новини та поради на пошту';

  @override
  String get settingsOutfitReminders => 'Нагадування про образи';

  @override
  String get settingsOutfitRemindersBody =>
      'Нагадування відмітити, що ви вдягли';

  @override
  String get settingsWeeklySummary => 'Тижневий звіт';

  @override
  String get settingsWeeklySummaryBody => 'Ваш тиждень в образах';

  @override
  String get settingsStyleSection => 'Стиль';

  @override
  String get settingsPreferredStyles => 'Улюблені стилі';

  @override
  String get settingsPreferredColours => 'Улюблені кольори';

  @override
  String get settingsNoneChosen => 'Не обрано';

  @override
  String get settingsPlanAiSection => 'План та ШІ';

  @override
  String get settingsPlanBillingBody => 'План, використання та оновлення';

  @override
  String get settingsPlanUsageBody => 'План та використання';

  @override
  String get settingsInviteFriends => 'Запросити друзів';

  @override
  String get settingsInviteFriendsBody =>
      'Безкоштовний місяць за кожного друга, який приєднається';

  @override
  String get settingsAiProvider => 'Провайдер ШІ';

  @override
  String get settingsAiProviderBody =>
      'Використовуйте власну модель для тегів та зображень';

  @override
  String get settingsAppVersion => 'Версія додатка';

  @override
  String get settingsPrivacyTerms => 'Конфіденційність та умови';

  @override
  String get settingsReportProblem => 'Повідомити про проблему';

  @override
  String get settingsChangePassword => 'Змінити пароль';

  @override
  String get settingsExportData => 'Експорт даних';

  @override
  String get settingsExportBody =>
      'Ми підготуємо файл з усіма вашими даними та відкриємо завантаження.';

  @override
  String get settingsExportAction => 'Експортувати';

  @override
  String get settingsCurrentPassword => 'Поточний пароль';

  @override
  String get settingsNewPassword => 'Новий пароль';

  @override
  String get settingsConfirmNewPassword => 'Підтвердьте новий пароль';

  @override
  String get settingsEnterCurrentPassword => 'Введіть поточний пароль';

  @override
  String get settingsEnterNewPassword => 'Введіть новий пароль';

  @override
  String get settingsPasswordMin8 => 'Використовуйте принаймні 8 символів';

  @override
  String get settingsPasswordNeedsUpper => 'Додайте велику літеру';

  @override
  String get settingsPasswordNeedsLower => 'Додайте малу літеру';

  @override
  String get settingsPasswordNeedsDigit => 'Додайте цифру';

  @override
  String get settingsPasswordsNoMatch => 'Паролі не збігаються';

  @override
  String get settingsChangeAction => 'Змінити';

  @override
  String get itemAddSnapTitle => 'Зробити знімок';

  @override
  String get itemAddSnapBody =>
      'Ми знайдемо кожну річ на фото та зробимо чистий студійний знімок кожної.';

  @override
  String get itemAddCamera => 'Зробити фото';

  @override
  String get itemAddGallery => 'Вибрати з галереї';

  @override
  String get itemAddOtherWays => 'Інші способи додавання';

  @override
  String get itemAddSeveral => 'Додати кілька фото';

  @override
  String get itemAddSeveralBody => 'До 50 за раз';

  @override
  String get itemAddImportProfile => 'Імпорт з профілю';

  @override
  String get itemAddImportProfileBody => 'Instagram або Facebook';

  @override
  String get itemAddEnterDetails => 'Ввести дані вручну';

  @override
  String get itemAddEnterDetailsBody => 'Фото не потрібне';

  @override
  String get itemManualIntro =>
      'Потрібна лише назва. Решту можна додати пізніше.';

  @override
  String get itemManualNameHint => 'Наприклад, синя бавовняна футболка';

  @override
  String get itemManualEnterName => 'Введіть назву';

  @override
  String get itemManualNotes => 'Нотатки';

  @override
  String get itemManualBrand => 'Бренд';

  @override
  String get itemManualSize => 'Розмір';

  @override
  String get itemManualEnterNumber => 'Введіть число';

  @override
  String get itemManualSavePiece => 'Зберегти річ';

  @override
  String get itemManualSaving => 'Збереження';

  @override
  String get itemManualSavedTitle => 'Збережено';

  @override
  String itemManualSavedBody(String name) {
    return '$name тепер у вашій шафі.';
  }

  @override
  String get itemManualNotSaved => 'Не збережено';

  @override
  String get itemManualAddUseCase => 'Додати призначення';

  @override
  String get itemManualAddUseCaseAction => 'Додати призначення';

  @override
  String get itemPhotos => 'Фото';

  @override
  String get itemAddPhotos => 'Додати фото';

  @override
  String get itemNoPhotoYet => 'Фото ще немає. Можна зберегти без нього.';

  @override
  String get itemRemovePhoto => 'Видалити фото';

  @override
  String get itemRemovePiece => 'Видалити річ';

  @override
  String get filterConditionLabel => 'Стан';

  @override
  String get photoshootStepPhotos => 'Фото';

  @override
  String get photoshootStepSetup => 'Налаштування';

  @override
  String get photoshootStepCreating => 'Створення';

  @override
  String get photoshootStepResults => 'Результати';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Крок $current з $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Помилка фото. Спробуйте ще раз нижче.';

  @override
  String photoshootManyFailed(int count) {
    return 'Помилка $count фото. Спробуйте ще раз для кожного.';
  }

  @override
  String get photoshootFormat => 'Формат';

  @override
  String get photoshootHowMany => 'Скільки';

  @override
  String get photoshootYourPrompt => 'Ваш запит';

  @override
  String get photoshootPromptHint => 'Золота година на даху, лляна сорочка';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Створити $count фото',
      few: 'Створити $count фото',
      one: 'Створити 1 фото',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'фото',
      few: 'фото',
      one: 'фото',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Не вдалося перевірити ліміт на сьогодні.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'План $plan: залишилося $remaining з $limit на сьогодні';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Безкоштовний';

  @override
  String get photoshootGallery => 'Галерея';

  @override
  String get photoshootUseCamera => 'Використати камеру';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Видалити фото $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Фото не знайдено';

  @override
  String get photoshootNoPhotosBody =>
      'Зйомка завершилася без зображень. Спробуйте ще раз.';

  @override
  String get photoshootNewStyle => 'Новий стиль';

  @override
  String get photoshootNewPhotos => 'Нові фото';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Відкрити фото $number';
  }

  @override
  String get photoshootReportPhoto => 'Поскаржитися на фото';

  @override
  String get photoshootSaveToGallery => 'Зберегти в галерею';

  @override
  String get actionUpgrade => 'Оновити';

  @override
  String get referralLimitTitle => 'Ви використали ліміт фото';

  @override
  String get referralLimitBody =>
      'Ваші безкоштовні фото оновляться завтра. Запросіть друга, і ви обидва отримаєте місяць Pro безкоштовно.';

  @override
  String get referralLimitRefer => 'Запросити друга';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Знайомства';

  @override
  String get photoshootUsePortfolio => 'Портфоліо';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Естетика';

  @override
  String get photoshootUseCustom => 'Власний запит';

  @override
  String get photoshootDescLinkedin => 'Ділові портрети для роботи';

  @override
  String get photoshootDescDating => 'Розслаблений, теплий та природний';

  @override
  String get photoshootDescPortfolio => 'Редакційний, висока мода';

  @override
  String get photoshootDescInstagram => 'Лайфстайл для вашої стрічки';

  @override
  String get photoshootDescAesthetic => 'Атмосферні, художні кадри';

  @override
  String get photoshootDescCustom => 'Опишіть бажаний образ';

  @override
  String get aspectSquare => 'Квадрат';

  @override
  String get aspectPortrait => 'Портрет';

  @override
  String get aspectLandscape => 'Альбомний';

  @override
  String get aspectTall => 'Високий';

  @override
  String get aspectWide => 'Широкий';

  @override
  String get tryOnAppBar => 'Віртуальна примірка';

  @override
  String get tryOnYourPhoto => 'Ваше фото';

  @override
  String get tryOnGarment => 'Одяг';

  @override
  String get tryOnUploadingPhoto => 'Завантаження фото';

  @override
  String get tryOnAddPhotoPrompt => 'Додайте фото в повний зріст';

  @override
  String get tryOnBodyPhotoHint => 'Найкраще підходить фото в повний зріст';

  @override
  String get tryOnAddPhoto => 'Додати фото';

  @override
  String get tryOnChangePhoto => 'Змінити фото';

  @override
  String get tryOnPhotoLoadFailed => 'Не вдалося завантажити фото.';

  @override
  String get tryOnChooseGarment => 'Оберіть фото одягу';

  @override
  String get tryOnChooseOneGarment => 'Оберіть одне фото одягу';

  @override
  String get tryOnGarmentHint =>
      'Найкраще підходить фото на рівній поверхні або на вішаку';

  @override
  String get tryOnChange => 'Змінити';

  @override
  String get tryOnCamera => 'Камера';

  @override
  String get tryOnRemove => 'Видалити';

  @override
  String get tryOnLookTitle => 'Образ';

  @override
  String get tryOnStyle => 'Стиль';

  @override
  String get tryOnBackground => 'Фон';

  @override
  String get tryOnPose => 'Поза';

  @override
  String get tryOnDressingUp =>
      'Приміряємо одяг. Це займе близько пів хвилини.';

  @override
  String get tryOnEmptyResult => 'Ваша примірка з\'явиться тут';

  @override
  String get tryOnReportImage => 'Поскаржитися на зображення';

  @override
  String get tryOnCreating => 'Створення';

  @override
  String get tryOnTryAgain => 'Спробувати знову';

  @override
  String get tryOnCreate => 'Створити примірку';

  @override
  String get tryOnBackgroundStudioWhite => 'Студійний білий';

  @override
  String get tryOnBackgroundStudioGrey => 'Студійний сірий';

  @override
  String get tryOnBackgroundUrban => 'Міська вулиця';

  @override
  String get tryOnBackgroundNature => 'Природа';

  @override
  String get tryOnBackgroundMinimal => 'Мінімалізм';

  @override
  String get tryOnPoseFront => 'Стоячи прямо';

  @override
  String get tryOnPoseSide => 'Стоячи боком';

  @override
  String get tryOnPoseWalking => 'У русі';

  @override
  String get dashboardGreetingMorning => 'Доброго ранку';

  @override
  String get dashboardGreetingAfternoon => 'Доброго дня';

  @override
  String get dashboardGreetingEvening => 'Доброго вечора';

  @override
  String get dashboardWelcome => 'Вітаємо';

  @override
  String get dashboardOpenProfile => 'Відкрити профіль';

  @override
  String get dashboardRailToday => 'Сьогодні';

  @override
  String get dashboardRailRecently => 'Нещодавно';

  @override
  String get dashboardActivityEmpty => 'Тут з\'являться нові речі та образи.';

  @override
  String get quickAddPiece => 'Додати річ';

  @override
  String get quickAddPieceBody => 'Сфотографуйте та додайте теги';

  @override
  String get quickBuildOutfit => 'Скласти образ';

  @override
  String get quickBuildOutfitBody => 'Комбінуйте свій одяг';

  @override
  String get quickForYou => 'Для вас';

  @override
  String get quickForYouBody => 'Підбірка на сьогодні';

  @override
  String get quickPlanWeek => 'Планування тижня';

  @override
  String get quickPlanWeekBody => 'Образи за датами';

  @override
  String get referralBannerUrgent => 'Закінчується ліміт? Запросіть друга.';

  @override
  String get referralBannerTitle => 'Подаруйте місяць, отримайте місяць';

  @override
  String get referralBannerBody => 'Ви та ваш друг отримаєте по місяцю Pro';

  @override
  String get referralBannerDismiss => 'Приховати на тиждень';

  @override
  String get referralBannerShare => 'Поділитися запрошенням';

  @override
  String get referralBannerCopy => 'Копіювати посилання';

  @override
  String get itemEditPieceTitle => 'Редагувати річ';

  @override
  String get itemEditDescriptionLabel => 'Опис';

  @override
  String get itemEditNotSaved => 'Не збережено';

  @override
  String get itemEditSavedTitle => 'Збережено';

  @override
  String get itemEditSavedBody => 'Ваші зміни збережено';

  @override
  String get itemEditSavedStalePhotos =>
      'Збережено — фото можуть бути застарілими';

  @override
  String get itemEditRemovePieceHint => 'Видалити цю річ зі сторінки предмета';

  @override
  String get itemEditNoPhotos => 'Ще немає фото. Додайте з галереї або камери';

  @override
  String get itemEditKeepPhoto => 'Залишити фото';

  @override
  String get itemEditRemoved => 'Видалено';

  @override
  String get itemEditAddUseCaseAction => 'Додати';

  @override
  String get statsNoStatsTitle => 'Статистики ще немає';

  @override
  String get statsNoStatsBody =>
      'Додайте кілька речей, і тут з\'явиться аналіз вашого гардероба';

  @override
  String get statsByCategory => 'За категоріями';

  @override
  String get statsTotalValue => 'загальна вартість';

  @override
  String get statsMostWorn => 'Найчастіше носите';

  @override
  String get statsLeastWorn => 'Чекають своєї черги';

  @override
  String get statsUnnamedPiece => 'Річ без назви';

  @override
  String get jobsTitle => 'Сканування';

  @override
  String get jobsEmptyTitle => 'Сканувань ще немає';

  @override
  String get jobsEmptyBody =>
      'Сфотографуйте річ і залиште обробку у фоновому режимі — вона триватиме тут';

  @override
  String get jobsNotCancelled => 'Не скасовано';

  @override
  String get jobsResume => 'Відновити';

  @override
  String get jobsReview => 'Переглянути';

  @override
  String get jobsStop => 'Зупинити';

  @override
  String get jobsDismiss => 'Відхилити';

  @override
  String get reportTitle => 'Поскаржитися на контент';

  @override
  String reportIntro(String contentType) {
    return 'Розкажіть, що не так з цим $contentType. Наша команда перевіряє кожну скаргу.';
  }

  @override
  String get reportReasonInappropriate => 'Недоречний або образливий';

  @override
  String get reportReasonNudity => 'Оголеність або сексуальний контент';

  @override
  String get reportReasonHarassment => 'Цькування або образи';

  @override
  String get reportReasonImpersonation => 'Видача себе за іншу особу';

  @override
  String get reportReasonOther => 'Інше';

  @override
  String get reportDetailsLabel => 'Додаткові деталі (необов\'язково)';

  @override
  String get reportSubmit => 'Надіслати скаргу';

  @override
  String get reportSubmittedTitle => 'Скаргу надіслано';

  @override
  String get reportSubmittedBody =>
      'Дякуємо. Наша команда перевірить цей контент.';

  @override
  String get reportFailedTitle => 'Не вдалося надіслати скаргу';

  @override
  String get reportFailedBody => 'Будь ласка, спробуйте ще раз.';

  @override
  String get reportContentTryOnImage => 'зображення примірки AI';

  @override
  String get reportContentSharedOutfit => 'поділений образ';

  @override
  String get reportContentPhotoshootImage => 'зображення фотосесії AI';

  @override
  String get sharedOutfitTitle => 'Спільний образ';

  @override
  String get sharedOutfitHideTooltip => 'Приховати цей образ';

  @override
  String get sharedOutfitReportTooltip => 'Поскаржитися на цей образ';

  @override
  String get sharedOutfitHideTitle => 'Приховати цей образ?';

  @override
  String get sharedOutfitHideBody =>
      'Він залишиться прихованим на цьому пристрої. Ви також можете поскаржитися на нього, щоб наша команда перевірила та видалила його.';

  @override
  String get sharedOutfitHideAction => 'Приховати';

  @override
  String get sharedOutfitHiddenInfo =>
      'Цей образ більше не відображатиметься на цьому пристрої.';

  @override
  String get sharedOutfitHiddenToast => 'Образ приховано';

  @override
  String get sharedOutfitMissingTitle => 'Цього образу більше немає';

  @override
  String get sharedOutfitMissingBody =>
      'Можливо, його було видалено або посилання невірне.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Ви приховали цей образ';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Якщо він є неприйнятним, повідомте про це в розділі Конфіденційність та умови або напишіть на $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Подобається цей образ?';

  @override
  String get sharedOutfitCtaBody =>
      'Створюйте подібні образи зі свого гардероба.';

  @override
  String get sharedOutfitCtaButton => 'Отримати FitCheck AI';

  @override
  String get errorTitle => 'Помилка';

  @override
  String get errorUnknown => 'Сталася непередбачувана помилка';

  @override
  String get errorNoConnection =>
      'Немає підключення до інтернету. Перевірте мережу.';

  @override
  String get errorTimeout => 'Час запиту вичерпано. Спробуйте ще раз.';

  @override
  String get errorServerError =>
      'Щось пішло не так на нашому боці. Спробуйте знову.';

  @override
  String get errorBadGateway =>
      'Наш сервер тимчасово недоступний. Спробуйте ще раз.';

  @override
  String get errorServiceUnavailable =>
      'Сервіс тимчасово недоступний. Спробуйте трохи згодом.';

  @override
  String get errorInternalError => 'Щось пішло не так. Спробуйте ще раз.';

  @override
  String get errorUnauthorized => 'Увійдіть, щоб продовжити.';

  @override
  String get errorForbidden => 'У вас немає доступу до цього.';

  @override
  String get errorSessionExpired => 'Сеанс закінчився. Увійдіть знову.';

  @override
  String get errorInvalidCredentials => 'Неправильна пошта або пароль.';

  @override
  String get errorTokenRefreshFailed =>
      'Не вдалося оновити сеанс. Увійдіть знову.';

  @override
  String get errorRequestCancelled => 'Запит скасовано.';

  @override
  String get errorInvalidFormat => 'Цей формат файлу не підтримується.';

  @override
  String get errorFileTooLarge => 'Цей файл занадто великий.';

  @override
  String get errorUploadFailed => 'Не вдалося завантажити. Спробуйте ще раз.';

  @override
  String get errorCacheCorrupted => 'Збережені дані пошкоджено й скинуто.';

  @override
  String get errorCacheNotFound => 'Ще нічого не збережено.';

  @override
  String get errorUserNotFound => 'Не вдалося знайти цей акаунт.';

  @override
  String get errorItemNotFound => 'Цей елемент більше не існує.';

  @override
  String get errorOutfitNotFound => 'Цей образ більше не існує.';

  @override
  String get rewardsTitle => 'Нагороди';

  @override
  String get rewardsNoAchievementsTitle => 'Ще немає досягнень';

  @override
  String get rewardsNoAchievementsBody =>
      'Додавайте речі та плануйте образи, щоб отримати перше.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'У таблиці ще нікого немає';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Створюйте образи, заробляйте бали та з\'являйтеся тут.';

  @override
  String get legalViewPrivacyPolicy => 'Політика конфіденційності';

  @override
  String get aiConsentAgree => 'Згоден і далі';

  @override
  String get aiConsentNotNow => 'Не зараз';

  @override
  String get imageViewerCloseTooltip => 'Закрити перегляд';

  @override
  String get updateReadyTitle => 'Доступне оновлення';

  @override
  String get updateReadyBody =>
      'Перезапустіть FitCheck AI для застосування покращень.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI потрібен доступ до камери для зйомки образів та речей гардероба.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI потрібен доступ до медіатеки для вибору фото образів та речей.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI потрібно зберігати створені ШІ фото образів у вашу медіатеку.';

  @override
  String get wardrobeSomePhotosSkipped => 'Деякі фото пропущено';

  @override
  String get wardrobePhotosNotAdded => 'Фото не додано';

  @override
  String get wardrobePhotoNotAdded => 'Фото не додано';

  @override
  String get wardrobeNotStartedTitle => 'Не розпочато';

  @override
  String get wardrobeNoRoomTitle => 'Немає місця';

  @override
  String get wardrobeAddPhotosSemantic => 'Додати фото';

  @override
  String get batchAddTileLabel => 'Додати';

  @override
  String get batchProfileLinkLabel => 'Посилання на профіль';

  @override
  String get wardrobeImportFromProfileTitle => 'Імпорт з профілю';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Додати кілька фото';

  @override
  String get wardrobeClearAction => 'Очистити';

  @override
  String get wardrobeRefreshTooltip => 'Оновити';

  @override
  String get batchNoPhotosYetTitle => 'Ще немає фото';

  @override
  String get batchChoosePhotosAction => 'Обрати фото';

  @override
  String get batchWeFindEachPieceBody =>
      'Ми знайдемо кожну річ і створимо її студійне фото.';

  @override
  String get batchPreparingPhotosSemantic => 'Підготовка фото';

  @override
  String get batchPhotosProcessedSemantic => 'Фото оброблено';

  @override
  String get batchPasteProfileLinkTitle => 'Вставте посилання на профіль';

  @override
  String get batchPasteProfileLinkBody =>
      'Публічний профіль Instagram чи Facebook. Ми скануємо фото, а ви обираєте речі до шафи.';

  @override
  String get batchClearLinkTooltip => 'Очистити посилання';

  @override
  String get batchStartingButton => 'Запуск';

  @override
  String get batchStartImportAction => 'Почати імпорт';

  @override
  String get batchReviewEveryPhotoTitle => 'Ви переглядаєте кожне фото';

  @override
  String get batchReviewEveryPhotoBody =>
      'Нічого не додається без вашого схвалення.';

  @override
  String get batchPrivateProfilesTitle => 'Приватні профілі';

  @override
  String get batchPrivateProfilesBody =>
      'Підключіть свій обліковий запис. Instagram також запитує ім\'я користувача та пароль.';

  @override
  String get batchUseAnotherLinkAction => 'Використати інше посилання';

  @override
  String get batchSignInNeededTitle => 'Потрібен вхід';

  @override
  String get batchEnterYourCodeTitle => 'Введіть код';

  @override
  String get batchUseUsernamePasswordAction =>
      'Використати ім\'я користувача та пароль';

  @override
  String get batchAlreadyConnectedAction => 'Я вже підключився у браузері';

  @override
  String get batchEnterCodeAction => 'Ввести код';

  @override
  String get batchTryAnotherWayAction => 'Спробувати інший спосіб';

  @override
  String get batchLiveStatus => 'Наживо';

  @override
  String get batchReconnectingStatus => 'Перепідключення';

  @override
  String get batchSignInToInstagramTitle => 'Увійти в Instagram';

  @override
  String get batchUsernameLabel => 'Ім\'я користувача';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Код, якщо увімкнено двоетапну перевірку';

  @override
  String get batchAuthenticatorCodeBody =>
      'Введіть 6-значний код із програми для автентифікації. Коди швидко змінюються.';

  @override
  String get batchVerifyAction => 'Підтвердити';

  @override
  String get batchFindingPhotosTitle => 'Пошук фотографій';

  @override
  String get batchImportPausedTitle => 'Імпорт зупинено';

  @override
  String get batchProcessingPhotosTitle => 'Обробка фотографій';

  @override
  String get batchWaitingNextPhoto => 'Очікування наступного фото';

  @override
  String get batchCancelImportAction => 'Скасувати імпорт';

  @override
  String get batchNoPiecesInPhotoBody => 'На цьому фото речей не знайдено.';

  @override
  String get batchEditPieceColoursLabel => 'Кольори через кому';

  @override
  String get batchAddToClosetAction => 'Додати до гардероба';

  @override
  String get batchSkipPhotoAction => 'Пропустити це фото';

  @override
  String get batchImportCompleteTitle => 'Імпорт завершено';

  @override
  String get batchImportFailedTitle => 'Помилка імпорту';

  @override
  String get batchImportCancelledTitle => 'Імпорт скасовано';

  @override
  String get batchImportErrorBody => 'Під час імпорту сталася помилка.';

  @override
  String get batchNothingMoreImportedBody =>
      'З цього профілю більше нічого не імпортовано.';

  @override
  String get batchViewClosetAction => 'Переглянути гардероб';

  @override
  String get batchStartOverAction => 'Почати знову';

  @override
  String get wardrobeAddPieceTitle => 'Додати річ';

  @override
  String get wardrobeAddDetailsTitle => 'Додати деталі';

  @override
  String get wardrobeScanningTitle => 'Сканування';

  @override
  String get batchReviewPiecesTitle => 'Перевірити речі';

  @override
  String get wardrobeGalleryAction => 'Галерея';

  @override
  String get wardrobeCameraAction => 'Камера';

  @override
  String get wardrobeNewBadge => 'Нове';

  @override
  String get wardrobeRemovePhotoTooltip => 'Видалити фото';

  @override
  String get batchRunInBackgroundTooltip => 'Працювати у фоні';

  @override
  String get batchStepOneOfTwo => 'Крок 1 із 2';

  @override
  String get batchStepTwoOfTwo => 'Крок 2 із 2';

  @override
  String get batchUploadingPhotosTitle => 'Завантаження фото';

  @override
  String get batchFindingPiecesTitle => 'Пошук речей';

  @override
  String get batchMakingStudioPhotosTitle => 'Створення студійних фото';

  @override
  String get batchStoppedLabel => 'Зупинено';

  @override
  String get batchFindingPiecesStoppedTitle => 'Пошук речей зупинено';

  @override
  String get batchCancelledLabel => 'Скасовано';

  @override
  String get batchAllDoneTitle => 'Готово';

  @override
  String get batchOpeningPiecesBody => 'Відкриваємо ваші речі';

  @override
  String get batchNothingSavedBody => 'Нічого не збережено.';

  @override
  String get batchFindingPiecesFailedBody => 'Не вдалося знайти речі.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Пошук речей припинено достроково.';

  @override
  String get batchStopFindingPiecesTitle => 'Зупинити пошук речей?';

  @override
  String get batchStopFindingPiecesBody =>
      'Сканування зупиниться, нічого не буде збережено. Знайдені речі залишаться в активності, доки ви їх не приберете.';

  @override
  String get batchKeepGoingAction => 'Продовжити';

  @override
  String get batchTryAgainAction => 'Спробувати знову';

  @override
  String get batchBackToPhotosAction => 'Назад до фото';

  @override
  String get batchSkipAllAction => 'Пропустити все';

  @override
  String get batchIncludeAllAction => 'Додати все';

  @override
  String get batchNoPiecesFoundTitle => 'Речі не знайдено';

  @override
  String get batchNoPiecesFoundBody => 'Ми не знайшли одяг на цих фото.';

  @override
  String get batchChooseOtherPhotosAction => 'Обрати інші фото';

  @override
  String get batchUseCaseHelper => 'Додається до кожної збереженої речі.';

  @override
  String get batchDiscardPiecesTitle => 'Видалити ці речі?';

  @override
  String get batchDiscardPiecesBody =>
      'Жодну річ із цієї підбірки не збережено.';

  @override
  String get batchKeepAction => 'Залишити';

  @override
  String get batchDiscardAction => 'Видалити';

  @override
  String get batchRemovePieceTitle => 'Видалити цю річ?';

  @override
  String get batchRemovePieceBody => 'Її не збережено у вашій шафі.';

  @override
  String get batchRemoveAction => 'Видалити';

  @override
  String get batchChoosePiecesToSave => 'Оберіть речі для збереження';

  @override
  String get batchDiscardAllAction => 'Видалити все';

  @override
  String get batchNothingSavedRetryBody =>
      'Нічого не збережено. Спробуйте ще раз.';

  @override
  String get batchNotSavedTitle => 'Не збережено';

  @override
  String get batchSavingLabel => 'Збереження';

  @override
  String get batchSendToBackgroundAction => 'Згорнути';

  @override
  String get batchStillWorkingMessage =>
      'Ще працюємо. Ми повідомимо, коли ваші речі будуть готові.';

  @override
  String get batchRunningInBackgroundTitle => 'Працює у фоновому режимі';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Студійні фото зупинено раніше. Ви все одно можете зберегти ці речі.';

  @override
  String get batchTapPieceToSkip => 'Натисніть на річ, щоб пропустити її.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Студійні фото ще створюються. Ви можете вийти — ми повідомимо.';

  @override
  String get batchLeaveAction => 'Вийти';

  @override
  String get batchPeopleInPhotosTitle => 'Люди на фото';

  @override
  String get batchIncludeAction => 'Додати';

  @override
  String get batchSkipAction => 'Пропустити';

  @override
  String get batchYourPhotoIsUsedLabel => 'Використовується ваше фото';

  @override
  String get batchMakingStudioPhotoLabel => 'Створення студійного фото';

  @override
  String get batchNoStudioPhotoBody =>
      'Без студійного фото. Використовується ваше фото.';

  @override
  String get batchEnterDetailsYourselfAction => 'Ввести дані самостійно';

  @override
  String get batchChooseAnotherPhotoAction => 'Вибрати інше фото';

  @override
  String get batchConnectionLostTitle => 'Зв\'язок втрачено';

  @override
  String get batchConnectionLostBody =>
      'Перевірте підключення та спробуйте знову.';

  @override
  String get batchDailyLimitTitle => 'Досягнуто денного ліміту';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Оновіть до Pro для більшої кількості сканувань або введіть дані самостійно.';

  @override
  String get batchDailyLimitBodyFree =>
      'Ваші сканування оновляться завтра. Ви можете ввести дані самостійно зараз.';

  @override
  String get batchSeePlansAction => 'Переглянути плани';

  @override
  String get batchAiBusyTitle => 'Наша AI зайнята';

  @override
  String get batchAiBusyBody =>
      'Це проблема на нашому боці. Спробуйте за кілька хвилин.';

  @override
  String get batchNoPiecesBody =>
      'Спробуйте чіткіше фото або введіть дані самостійно.';

  @override
  String get batchScanningUnavailableTitle => 'Сканування недоступне';

  @override
  String get batchScanningUnavailableBody => 'Поки що введіть дані самостійно.';

  @override
  String get batchScanDidNotFinishTitle => 'Сканування не завершено';

  @override
  String get batchTryAgainBody => 'Спробуйте знову.';

  @override
  String get billingTitle => 'Підписка';

  @override
  String get billingUpgradeHeading => 'Оновіть план';

  @override
  String get billingUpgradeOnPlusBody => 'Ті ж функції, вищі ліміти.';

  @override
  String get billingUpgradeBody =>
      'Plus і Pro мають однакові функції. Виберіть потрібні ліміти.';

  @override
  String get billingWebUnavailableBody =>
      'Онлайн-оновлення поки недоступні. Промокод або реферальний код усе ще розблоковує Plus або Pro. Запрошуйте друзів нижче, щоб отримати безкоштовні місяці.';

  @override
  String get billingPlansStale =>
      'Не вдалося завантажити останні плани. Ціни можуть бути застарілими.';

  @override
  String get billingMonthly => 'Щомісяця';

  @override
  String get billingYearly => 'Щорічно';

  @override
  String get billingCurrentPlan => 'Поточний план';

  @override
  String get billingActive => 'Активний';

  @override
  String get billingThisMonth => 'Цього місяця';

  @override
  String get billingItemExtractions => 'Розпізнавання речей';

  @override
  String get billingOutfitVisualizations => 'Візуалізація образів';

  @override
  String get billingNearLimitUpgrade =>
      'Ви наблизилися до місячного ліміту. Оновіть план для більших можливостей.';

  @override
  String get billingNearLimitResets =>
      'Ви наблизилися до місячного ліміту. Він оновиться на початку наступного місяця.';

  @override
  String get billingStoreUnavailable =>
      'Оновлення в магазині поки недоступні. Зазирніть пізніше.';

  @override
  String get billingManageHeading => 'Керування планом';

  @override
  String get billingCancelPlan => 'Скасувати підписку';

  @override
  String get billingCancelKeepsAccess =>
      'Доступ зберігається до кінця поточного розрахункового періоду.';

  @override
  String get billingCancelConfirmTitle => 'Скасувати підписку?';

  @override
  String get billingKeepPlan => 'Зберегти план';

  @override
  String get billingCancelPlanAction => 'Скасувати план';

  @override
  String get billingBilledMonthly => 'Щомісячна оплата';

  @override
  String get billingBilledYearly => 'Щорічна оплата';

  @override
  String get billingVirtualTryOn => 'Віртуальна примірка';

  @override
  String get billingPrioritySupport => 'Пріоритетна підтримка';

  @override
  String get billingDisclosureProRenewing =>
      'Pro є підпискою з автопоновленням';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus та Pro є підписками з автопоновленням';

  @override
  String get billingDisclosureAppleBilling =>
      'Оплата стягується з вашого Apple ID після підтвердження покупки.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Оплата стягується з вашого облікового запису Google Play після підтвердження покупки.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Підписка автоматично поновлюється на той самий період за ту саму ціну, якщо ви не вимкнете автопоновлення принаймні за 24 години до кінця поточного періоду.';

  @override
  String get billingDisclosureAppleManage =>
      'Керуйте або скасовуйте будь-коли в Налаштуваннях › ваш Apple ID › Підписки.';

  @override
  String get billingDisclosureGoogleManage =>
      'Керуйте або скасовуйте будь-коли в Google Play › Платежі та підписки.';

  @override
  String get billingReferFriend => 'Запросити друга';

  @override
  String get billingHowItWorks => 'Як це працює';

  @override
  String get billingHowShareTitle => 'Поділіться посиланням';

  @override
  String get billingHowShareBody => 'Надішліть його другу.';

  @override
  String get billingHowSignUpTitle => 'Друг реєструється';

  @override
  String get billingHowSignUpBody => 'Ваш друг приєднується за посиланням.';

  @override
  String get billingHowBothTitle => 'Обидва отримують Pro';

  @override
  String get billingHowBothBody =>
      'Кожен із вас отримує місяць Pro безкоштовно.';

  @override
  String get billingYourReferrals => 'Ваші запрошення';

  @override
  String get billingInvited => 'Запрошено';

  @override
  String get billingJoined => 'Доєднався(-лась)';

  @override
  String get billingMonthsEarned => 'Зароблено місяців';

  @override
  String get billingInviteFriend => 'Запросити друга';

  @override
  String get billingInviteBody => 'Ви та ваш друг отримуєте по місяцю Pro.';

  @override
  String get billingYourCode => 'Ваш код';

  @override
  String get billingCopyLink => 'Копіювати посилання';

  @override
  String get billingShareInvite => 'Поділитися запрошенням';

  @override
  String get giftUnavailable =>
      'Подарункові запрошення недоступні в цій збірці.';

  @override
  String get giftPageTitle => 'Подарувати FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Зараз немає безплатних подарункових запрошень.';

  @override
  String get giftFormTitle => 'Надіслати безплатне запрошення';

  @override
  String get giftFormBody =>
      'Отримувач активує подарунок за допомогою цієї підтвердженої електронної адреси. Ми не надсилаємо лист за вас.';

  @override
  String get giftFieldFrom => 'Від кого';

  @override
  String get giftFieldRecipientName => 'Ім\'я отримувача';

  @override
  String get giftFieldRecipientEmail => 'Email отримувача';

  @override
  String get giftFieldOccasion => 'Привід (необов\'язково)';

  @override
  String get giftNoOccasion => 'Без приводу';

  @override
  String get giftOccasionBirthday => 'День народження';

  @override
  String get giftOccasionAnniversary => 'Річниця';

  @override
  String get giftOccasionOther => 'Інше';

  @override
  String get giftFieldCardGreeting => 'Привітання на листівці';

  @override
  String get giftFieldCardGreetingHelper =>
      'З\'явиться на листівці саме так, як написано.';

  @override
  String get giftFieldPrivateNote => 'Особиста нотатка (необов\'язково)';

  @override
  String get giftCreateAction => 'Створити безплатний подарунок';

  @override
  String get giftClaimedTitle => 'Подарунок активовано';

  @override
  String get giftClaimedActive => 'Ваш подарунок FitCheck Pro активний.';

  @override
  String get giftClaimedQueued =>
      'Ваш подарунок FitCheck Pro почнеться після закінчення поточного доступу.';

  @override
  String get giftLinkCopied => 'Посилання на подарунок скопійовано.';

  @override
  String get giftErrorName => 'Введіть ім\'я.';

  @override
  String get giftErrorEmail => 'Введіть дійсну електронну адресу.';

  @override
  String get giftErrorGreeting => 'Введіть привітання на листівці.';

  @override
  String get giftErrorGreetingLength => 'Використовуйте не більше 80 символів.';

  @override
  String get giftClaimAction => 'Отримати подарунок';

  @override
  String get giftCardPreview => 'Попередній перегляд';

  @override
  String get giftGiftForYou => 'Подарунок для вас';

  @override
  String get giftGiftWaiting => 'На вас чекає подарунок';

  @override
  String get giftOpenBody =>
      'Відкрийте свої подарунки та отримайте їх на підтверджену електронну пошту.';

  @override
  String get giftOpenGifts => 'Відкрити подарунки';

  @override
  String get giftSendInvitation => 'Надіслати запрошення';

  @override
  String get settingsAiProviderSection => 'Провайдер';

  @override
  String get settingsAiCustom => 'Власний';

  @override
  String get settingsAiUrlHelper =>
      'Використовуйте публічну URL-адресу, доступну для сервера. Локальний хост не працює з наших серверів.';

  @override
  String get settingsAiConnectionSection => 'Підключення';

  @override
  String get settingsAiApiUrl => 'URL-адреса API';

  @override
  String get settingsAiApiKey => 'Ключ API';

  @override
  String get settingsAiApiKeySaved =>
      'Збережено. Залиште порожнім, щоб не змінювати.';

  @override
  String get settingsAiChatModel => 'Модель чату';

  @override
  String get settingsAiVisionModel => 'Модель зору (необов\'язково)';

  @override
  String get settingsAiImageModel => 'Модель зображень (необов\'язково)';

  @override
  String get settingsAiImageModelNote =>
      'Для генерації зображень потрібні сумісні з OpenAI завершення чату з response_modalities.';

  @override
  String get settingsAiTestConnection => 'Перевірити з\'єднання';

  @override
  String get calendarTitle => 'Календар';

  @override
  String get calendarGoToToday => 'Сьогодні';

  @override
  String get calendarConnectTooltip => 'Підключити календар';

  @override
  String get calendarAddEvent => 'Додати подію';

  @override
  String get calendarEmptyTitle => 'Нічого не заплановано';

  @override
  String get calendarEmptyBody => 'Додайте подію та сплануйте, що одягнути.';

  @override
  String get calendarPreviousMonth => 'Попередній місяць';

  @override
  String get calendarNextMonth => 'Наступний місяць';

  @override
  String get calendarAllDay => 'Увесь день';

  @override
  String get calendarOutfitLinked => 'Образ прив\'язано';

  @override
  String get calendarEventOptions => 'Параметри події';

  @override
  String get calendarDeleteTitle => 'Видалити подію?';

  @override
  String get calendarChangeOutfit => 'Змінити образ';

  @override
  String get calendarLinkOutfit => 'Прив\'язати образ';

  @override
  String get calendarRemoveOutfit => 'Видалити образ';

  @override
  String get calendarNewEvent => 'Нова подія';

  @override
  String get calendarEditEvent => 'Редагувати подію';

  @override
  String get calendarTitleLabel => 'Назва';

  @override
  String get calendarTitleRequired => 'Введіть назву';

  @override
  String get calendarEndBeforeStart => 'Кінець після початку';

  @override
  String get calendarStarts => 'Початок';

  @override
  String get calendarEnds => 'Кінець';

  @override
  String get calendarPlaceOptional => 'Місце (необов\'язково)';

  @override
  String get calendarNotesOptional => 'Нотатки (необов\'язково)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Створіть образ і прив\'яжіть його до цієї події.';

  @override
  String get calendarBuildOutfit => 'Створити образ';

  @override
  String get calendarConnectionsTitle => 'Календарі';

  @override
  String get calendarConnectionsBody =>
      'Події, додані тут, залишаються у FitCheck AI.';

  @override
  String get calendarDisconnect => 'Відключити';

  @override
  String get calendarNotAvailable => 'Поки недоступно';

  @override
  String get profileSectionExplore => 'Огляд';

  @override
  String get profileNavTryOn => 'Примірка';

  @override
  String get profileNavRewards => 'Бонуси';

  @override
  String get profileSupport => 'Підтримка';

  @override
  String get profileHelp => 'Допомога';

  @override
  String get profileAbout => 'Про додаток';

  @override
  String get profileAboutBody => 'Ваша шафа, образи та плани в одному місці.';

  @override
  String get profileSignOutTitle => 'Вийти?';

  @override
  String get profileSignOutBody => 'Ви зможете увійти знову в будь-який час.';

  @override
  String get profileEditTitle => 'Редагувати профіль';

  @override
  String get profileYourProfile => 'Ваш профіль';

  @override
  String get profileBodyProfiles => 'Профілі тіла';

  @override
  String get profileBodyEmptyTitle => 'Ще немає профілів тіла';

  @override
  String get profileBodyEmptyBody =>
      'Додайте свій зріст і статуру для кращої посадки.';

  @override
  String get profileBodyAdd => 'Додати профіль';

  @override
  String get profileBodyDefaultNote =>
      'Ваш основний профіль використовується для посадки та примірки.';

  @override
  String get profileBodyDefaultBadge => 'Основний';

  @override
  String get profileBodyMakeDefault => 'Зробити основним';

  @override
  String get profileBodyDeleteBody => 'Цю дію неможливо скасувати.';

  @override
  String get profileBodyRequired => 'Обов\'язково';

  @override
  String get profileBodyCheckNumber => 'Перевірте це число';

  @override
  String get profileBodyNew => 'Новий профіль тіла';

  @override
  String get profileBodyNameHint => 'Наприклад, Я';

  @override
  String get profileBodyHeight => 'Зріст';

  @override
  String get profileBodyWeight => 'Вага';

  @override
  String get profileBodyBuild => 'Статура';

  @override
  String get profileBodySkinTone => 'Відтінок шкіри';

  @override
  String get profileBirthDateNeededBody =>
      'Додайте дату народження до часу народження.';

  @override
  String get profileBirthDateNeededTitle => 'Потрібна дата народження';

  @override
  String get profilePartlySavedBody =>
      'Ми зберегли ваше ім\'я та фото. Дані про народження не збереглися, спробуйте пізніше.';

  @override
  String get profilePartlySavedTitle => 'Збережено частково';

  @override
  String get profileSavedBody => 'Ваш профіль збережено.';

  @override
  String get profileChangePhoto => 'Змінити фото профілю';

  @override
  String get profilePhotoLabel => 'Фото профілю';

  @override
  String get profilePhotoHint => 'Торкніться, щоб вибрати нове';

  @override
  String get profileBirthDateLabel => 'Дата народження (необов\'язково)';

  @override
  String get profileBirthTimeLabel => 'Час народження (необов\'язково)';

  @override
  String get profileBirthTimeHelper => 'Роблить ведичні поради точнішими';

  @override
  String get profileBirthPlaceLabel => 'Місце народження (необов\'язково)';

  @override
  String get profileBirthPlaceHint => 'Наприклад, Київ, Україна';

  @override
  String get profileHelpContactTitle => 'Запитайте нас про все';

  @override
  String get profileHelpContactBody =>
      'Надішліть повідомлення, і ми відповімо електронною поштою, зазвичай протягом дня.';

  @override
  String get profileHelpContactAction => 'Звернутися до підтримки';

  @override
  String get profileHelpFaqTitle => 'Поширені запитання';

  @override
  String get profileFaqAddPiecesTitle => 'Як додати речі до гардероба?';

  @override
  String get profileFaqAddPiecesBody =>
      'Натисніть Додати річ на вкладці Гардероб. Зробіть фото або виберіть з галереї; ми розпізнаємо кожну річ і позначимо її для вас.';

  @override
  String get profileFaqMatchingTitle => 'Як працює підбір комплектів?';

  @override
  String get profileFaqMatchingBody =>
      'Відкрийте Для вас і виберіть свої речі. Ми запропонуємо доповнення та складемо повні образи з вашого гардероба.';

  @override
  String get profileFaqTryOnTitle =>
      'Чи можна використовувати власні фото для примірки?';

  @override
  String get profileFaqTryOnBody =>
      'Так. Додайте своє фото в повний зріст, а потім виберіть речі, щоб приміряти їх.';

  @override
  String get profileFaqRewardsTitle => 'Як заробляти нагороди?';

  @override
  String get profileFaqRewardsBody =>
      'Плануйте та носіть образи регулярно. Серії та досягнення накопичуються з часом.';

  @override
  String get profileFaqPrivacyTitle => 'Чи конфіденційний мій гардероб?';

  @override
  String get profileFaqPrivacyBody =>
      'Так. Ваш гардероб та образи приватні, якщо ви не поділитеся посиланням на один образ.';

  @override
  String get profileHelpMoreTitle => 'Більше допомоги';

  @override
  String get profileHelpGuides => 'Посібники';

  @override
  String get profileHelpGuidesBody => 'Як працює кожна функція';

  @override
  String get feedbackCategoryBug => 'Щось зламалося';

  @override
  String get feedbackCategoryIdea => 'Ідея';

  @override
  String get feedbackCategoryGeneral => 'Загальне';

  @override
  String get feedbackCategoryHelp => 'Потрібна допомога';

  @override
  String get feedbackHintBug =>
      'Що сталося і чого ви очікували? Кроки допоможуть нам це виправити.';

  @override
  String get feedbackHintIdea => 'Що б ви хотіли та чому?';

  @override
  String get feedbackHintGeneral => 'Поділіться думкою або поставте запитання.';

  @override
  String get feedbackAttachmentLimitBody => 'Можна додати до 5 зображень.';

  @override
  String get feedbackAttachmentLimitTitle => 'Ліміт вичерпано';

  @override
  String get feedbackImageTooLargeBody =>
      'Виберіть зображення розміром до 5 МБ.';

  @override
  String get feedbackImageTooLargeTitle => 'Зображення завелике';

  @override
  String get feedbackTitle => 'Надіслати відгук';

  @override
  String get feedbackAboutLabel => 'Про що йдеться?';

  @override
  String get feedbackSubjectLabel => 'Тема';

  @override
  String get feedbackSubjectRequired => 'Додайте тему';

  @override
  String get feedbackSubjectTooShort => 'Тема має містити щонайменше 3 символи';

  @override
  String get feedbackDetailsLabel => 'Деталі';

  @override
  String get feedbackDetailsRequired => 'Додайте трохи деталей';

  @override
  String get feedbackDetailsTooShort =>
      'Опис має містити щонайменше 10 символів';

  @override
  String get feedbackAddScreenshot => 'Додати знімок екрана';

  @override
  String get feedbackAttachmentHint => 'До 5, до 5 МБ кожне';

  @override
  String get feedbackSend => 'Надіслати';

  @override
  String get feedbackEmptyTitle => 'Ще нічого не надіслано';

  @override
  String get feedbackEmptyBody =>
      'Надіслані вами матеріали з\'являться тут разом зі статусом.';

  @override
  String get feedbackHistoryTitle => 'Надіслане вами';

  @override
  String get feedbackStatusOpen => 'Відкрито';

  @override
  String get feedbackStatusInProgress => 'У роботі';

  @override
  String get feedbackStatusResolved => 'Вирішено';

  @override
  String get feedbackStatusClosed => 'Закрито';

  @override
  String get legalIntro =>
      'Як ми захищаємо ваші дані та правила використання FitCheck AI.';

  @override
  String get legalPolicies => 'Політики';

  @override
  String get legalPrivacySubtitle => 'Що і навіщо ми збираємо';

  @override
  String get legalTermsTitle => 'Умови використання';

  @override
  String get legalTermsSubtitle => 'Правила використання додатку';

  @override
  String get legalLicences => 'Ліцензії ПЗ з відкритим кодом';

  @override
  String get legalSupportSubtitle =>
      'Допомога, контакти та запити щодо приватності';

  @override
  String get legalReportAbuse => 'Повідомити про проблему чи порушення';

  @override
  String get permissionCameraTitle => 'Доступ до камери';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI використовує вашу камеру для зйомки одягу та образів для примірки ШІ та організації гардероба.';

  @override
  String get permissionPhotoTitle => 'Доступ до фото';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI потрібен доступ до фотографій, щоб ви могли обирати зображення одягу та образів.';

  @override
  String get permissionNotNow => 'Не зараз';

  @override
  String get permissionOpenSettings => 'Відкрити налаштування';

  @override
  String authSignedInAs(String name) {
    return 'Увійшли як $name';
  }

  @override
  String get authSignedIn => 'Вхід виконано';

  @override
  String get authWelcomeBackTitle => 'З поверненням';

  @override
  String get authSignInFailed => 'Помилка входу';

  @override
  String get authWelcomeTitle => 'Вітаємо';

  @override
  String get authSignUpFailed => 'Помилка реєстрації';

  @override
  String get authGoogleSignInFailed => 'Помилка входу через Google';

  @override
  String get authAppleSignInFailed => 'Помилка входу через Apple';

  @override
  String get authConfirmEmailTitle => 'Підтвердьте email';

  @override
  String get authConfirmEmailBody =>
      'Перевірте пошту та підтвердьте адресу, потім увійдіть.';

  @override
  String get authClosetReady => 'Ваша гардеробна готова.';

  @override
  String get authSignedOutTitle => 'Вихід виконано';

  @override
  String get authSignedOutBody => 'Ви вийшли з облікового запису.';

  @override
  String get authSignOutFailed => 'Помилка виходу';

  @override
  String get authEmailSentTitle => 'Лист надіслано';

  @override
  String get authResetLinkSent => 'Перевірте пошту для скидання пароля.';

  @override
  String get authPasswordUpdatedTitle => 'Пароль оновлено';

  @override
  String get authPasswordUpdated => 'Ваш пароль оновлено.';

  @override
  String get authPasswordNotUpdated => 'Пароль не оновлено';

  @override
  String get authCouldNotSendEmail => 'Не вдалося надіслати лист';

  @override
  String get authEmailNotSent => 'Лист не надіслано';

  @override
  String get authResendSentBody => 'Ми надіслали новий лист для підтвердження.';

  @override
  String get outfitPreviewWithAi => 'Превʼю з ШІ';

  @override
  String get outfitNewPreview => 'Створити нове превʼю';

  @override
  String get outfitBuilderClosetHeading => 'Ваш шафа';

  @override
  String get outfitBuilderSearchHint => 'Шукати предмети';

  @override
  String get outfitClearSearch => 'Очистити пошук';

  @override
  String get outfitBuilderAddPiecesTitle => 'Спочатку додайте предмети';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Оутфіти формуються з предметів у вашій шафі.';

  @override
  String get outfitBuilderNoMatches => 'Немає відповідних предметів.';

  @override
  String get outfitNameLabel => 'Назва оутфіту';

  @override
  String get outfitNameHint => 'Наприклад, Лляний вихідний';

  @override
  String get outfitPreviewSemantic => 'Превʼю оутфіту з ШІ';

  @override
  String get outfitChoosePieces => 'Виберіть предмети';

  @override
  String get outfitTapPiecesHint => 'Торкніться предметів нижче, щоб додати.';

  @override
  String get outfitShareTooltip => 'Поділитися';

  @override
  String get outfitSaveFavourite => 'Зберегти в улюблене';

  @override
  String get outfitPiecesHeading => 'Предмети';

  @override
  String get outfitWearHistoryEmpty => 'Приладьте його, і дати зʼявляться тут.';

  @override
  String get outfitWearHistoryTitle => 'Історія носіння';

  @override
  String get outfitWearHistoryError => 'Не вдалося завантажити дати.';

  @override
  String get outfitWornOn => 'Несено';

  @override
  String get outfitEditTitle => 'Редагувати оутфіт';

  @override
  String get outfitSavedPhotosFailed => 'Деталі збережено, фото — ні';

  @override
  String get outfitNoPhotosBody =>
      'Ще немає фото. Оутфіт показує свої предмети.';

  @override
  String get outfitOccasionLabel => 'Співідповідність';

  @override
  String get outfitOccasionNone => 'Немає';

  @override
  String get outfitTagsHint => 'Розділяйте комами';

  @override
  String get outfitDraftBody => 'Приховано від основного списку';

  @override
  String get outfitPublic => 'Публічний';

  @override
  String get outfitPublicBody => 'Будь-хто за посиланням зможе побачити';

  @override
  String get outfitDeleteFromDetail =>
      'Видалити цей оутфіт із сторінки деталей.';

  @override
  String get outfitNewCollection => 'Нова колекція';

  @override
  String get outfitNoCollectionsTitle => 'Ще немає колекцій';

  @override
  String get outfitNoCollectionsBody =>
      'Групіруйте образи за подорожами, сезонами чи настроєм.';

  @override
  String get outfitCreateCollection => 'Створити колекцію';

  @override
  String get outfitAddOutfits => 'Додати образи';

  @override
  String get outfitRename => 'Перейменувати';

  @override
  String get outfitCollectionDeleteBody => 'Образи в ній збережуться.';

  @override
  String get outfitCollectionsNotLoaded => 'Образи не завантажено';

  @override
  String get outfitRenameCollection => 'Перейменувати колекцію';

  @override
  String get outfitDescriptionOptional => 'Опис (за бажанням)';

  @override
  String get outfitAllInCollection => 'Усі образи вже в цій колекції.';

  @override
  String get photoshootSubtitleUpload => 'Студійні портрети з ваших фото';

  @override
  String get photoshootSubtitleConfigure => 'Оберіть стиль, формат і кількість';

  @override
  String get photoshootSubtitleGenerating => 'Це займе одну-дві хвилини';

  @override
  String get photoshootAddPhotosSemantic => 'Додати фото з галереї';

  @override
  String get photoshootUploadTitle => 'Додайте 1–4 своїх фото';

  @override
  String get photoshootUploadBody => 'Натисніть, щоб обрати з галереї';

  @override
  String get photoshootAddToContinue => 'Додайте фото, щоб продовжити';

  @override
  String get photoshootAddAnotherPhoto => 'Додати ще одне фото';

  @override
  String get photoshootTipsTitle => 'Для кращого результату';

  @override
  String get photoshootTipsBody =>
      'Використовуйте чіткі, добре освітлені фото обличчя з різних ракурсів. Без сонцезахисних окулярів і капелюхів.';

  @override
  String get photoshootStarting => 'Початок';

  @override
  String get photoshootCancelling => 'Скасування';

  @override
  String get photoshootFailed => 'Помилка';

  @override
  String get recommendTabMatches => 'Підходження';

  @override
  String get recommendTabComplete => 'Поєднання';

  @override
  String get recommendTabWeather => 'Погода';

  @override
  String get recommendTabColours => 'Кольори';

  @override
  String get recommendTabShop => 'Магазин';

  @override
  String get recommendNoMatchesTitle => 'Ще немає підбірок';

  @override
  String get recommendNoMatchesBody =>
      'Оберіть річ, і ми знайдемо, що до неї пасує.';

  @override
  String get recommendPickPiece => 'Оберіть річ';

  @override
  String get recommendNothingMatchesTitle => 'Ще нічого не підійшло';

  @override
  String get recommendNothingMatchesBody =>
      'Спробуйте інші речі або додайте більше в шафу.';

  @override
  String get recommendChangePieces => 'Змінити речі';

  @override
  String get recommendDefaultReason => 'Підходить до обраних речей.';

  @override
  String get recommendCompleteTitle => 'Повний образ';

  @override
  String get recommendCompleteBody => 'Оберіть річ, і ми доповнимо решту.';

  @override
  String get recommendWorking => 'Обробка';

  @override
  String get recommendGenerate => 'Створити';

  @override
  String get recommendChooseStyleBody => 'Оберіть стиль, потім створіть образ.';

  @override
  String get recommendNoLooksTitle => 'Немає образів для цих речей';

  @override
  String get recommendNoLooksBody => 'Спробуйте інший стиль або інші речі.';

  @override
  String get recommendDefaultLook => 'Образ для ваших речей';

  @override
  String get recommendNoPiecesBody => 'Для цього образу не знайдено речей.';

  @override
  String get recommendCityLabel => 'Місто';

  @override
  String get recommendCheck => 'Перевірити';

  @override
  String get recommendWeatherTitle => 'Яка погода?';

  @override
  String get recommendWeatherBody =>
      'Введіть місто, щоб отримати рекомендації на сьогодні.';

  @override
  String get recommendWearToday => 'Надягти сьогодні';

  @override
  String get recommendWeatherNoPieces => 'У шафі немає речей для такої погоди.';

  @override
  String get recommendBudgetLabel => 'Бюджет до';

  @override
  String get recommendLooking => 'Пошук';

  @override
  String get recommendFindWhatToBuy => 'Що купити';

  @override
  String get recommendFillGapsTitle => 'Доповніть колекцію';

  @override
  String get recommendFillGapsBody =>
      'Вкажіть бюджет, і ми порадимо, чого не вистачає у шафі.';

  @override
  String get recommendNoGapsTitle => 'Усі діри закриті';

  @override
  String get recommendNoGapsBody =>
      'Спробуйте більший бюджет або іншу категорію.';

  @override
  String get recommendMoodEveryday => 'Побутовий';

  @override
  String get recommendMoodBigMeeting => 'Важлива зустріч';

  @override
  String get recommendDayLabel => 'День';

  @override
  String get recommendReadingStars => 'Зчитуємо зірки';

  @override
  String get recommendGetMyColours => 'Отримати мої кольори';

  @override
  String get recommendLuckyColoursTitle => 'Ваші щасливі кольори';

  @override
  String get recommendLuckyColoursBody =>
      'Оберіть день, і ми підкажемо підходящі кольори та предмети.';

  @override
  String get recommendLuckyColoursSection => 'Щасливі кольори';

  @override
  String get recommendAvoidColoursSection => 'Кольори, яких варто уникати';

  @override
  String get recommendBirthDateTitle => 'Вкажіть дату народження';

  @override
  String get recommendBirthDateBody =>
      'Потрібна дата народження, щоб визначити ваші кольори.';

  @override
  String get recommendEditProfile => 'Редагувати профіль';

  @override
  String get recommendNothingThisDay => 'На цей день нічого немає.';

  @override
  String get recommendUnnamedColour => 'Без назви колір';

  @override
  String get recommendFromCloset => 'З вашої шафи';

  @override
  String get recommendNoPiecesInColours => 'Поки немає предметів цих кольорів.';

  @override
  String get recommendOutfitIdeas => 'Ідеї образів';

  @override
  String get recommendNoOutfitsInColours =>
      'Поки немає повного образу цих кольорів.';

  @override
  String get recommendDefaultOutfitIdea => 'Ідея образу';

  @override
  String get recommendPickUpToThree => 'Оберіть до трьох предметів';

  @override
  String get recommendEmptyClosetBody =>
      'Спершу додайте кілька предметів, потім поверніться до пошуку пар.';

  @override
  String get dashboardDressForDay => 'Одягайтеся відповідно до дня.';

  @override
  String get dashboardOutfitOfDay => 'Образ дня';

  @override
  String get dashboardFreshLook => 'Свіжий образ';

  @override
  String get subscriptionManageInStoreTitle => 'Керування в магазині';

  @override
  String get subscriptionManageInStoreBody =>
      'Цей тариф сплачується через магазин. Керуйте ним у налаштуваннях акаунта магазину.';

  @override
  String get subscriptionCancelledTitle => 'Підписку скасовано';

  @override
  String get subscriptionCancelledBody =>
      'Ваш тариф залишиться активним до кінця розрахункового періоду.';

  @override
  String get subscriptionCancelFailedTitle => 'Не вдалося скасувати';

  @override
  String get subscriptionCouldNotOpenTitle => 'Не вдалося відкрити';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Не вдалося відкрити керування розрахунками.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Не вдалося відкрити посилання.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Не вдалося завантажити посилання';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Не вдалося завантажити реферальне посилання. Спробуйте ще раз.';

  @override
  String get subscriptionReferralCopiedTitle => 'Скопійовано';

  @override
  String get subscriptionReferralCopiedBody =>
      'Реферальне посилання скопійовано.';

  @override
  String get subscriptionReferralShareSubject => 'Спробуйте FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Приєднуйтесь до FitCheck AI, і обидва отримаєте місяць Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Посилання скопійовано';

  @override
  String get subscriptionShareUnavailableBody =>
      'Обмін недоступний, тому ми скопіювали посилання.';

  @override
  String get subscriptionShareFailedTitle => 'Не вдалося обмінятися';

  @override
  String get subscriptionShareFailedBody =>
      'Скопіюйте посилання зі сторінки запрошення.';

  @override
  String get subscriptionStoreReadyTitle => 'Магазин готовий';

  @override
  String get subscriptionStoreReadyBody =>
      'Ціни у магазині доступні. Тепер можна оновити підписку.';

  @override
  String get purchaseFailedTitle => 'Помилка покупки';

  @override
  String get purchaseUnavailableTitle => 'Покупка недоступна';

  @override
  String get purchaseIapUnavailableBody =>
      'Всерединна покупка недоступна на цьому пристрої.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Цей тариф ще не доступний для покупки.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Цей тариф ще не доступний у магазині. Зверніться пізніше.';

  @override
  String get purchaseStartFailedBody =>
      'Не вдалося розпочати покупку. Спробуйте ще раз.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Систему оплати не вдалося отримати з платіжного посилання.';

  @override
  String get purchasePendingTitle => 'Покупка в очікуванні';

  @override
  String get purchasePendingBody =>
      'Вашу покупку очікує на затвердження. Доступ буде надано після підтвердження.';

  @override
  String get purchaseFailedBody => 'Покупка не вдалася. Спробуйте ще раз.';

  @override
  String get purchaseRestoredTitle => 'Відновлено';

  @override
  String get purchaseRestoredBody => 'Ваші покупки відновлено.';

  @override
  String get purchaseActiveTitle => 'Підписку активовано';

  @override
  String get purchaseActiveBody => 'Вашу підписку активовано. Вітаємо!';

  @override
  String get purchaseSignInRequiredTitle => 'Потрібен вхід';

  @override
  String get purchaseSignInRequiredBody => 'Увійдіть, щоб завершити покупку.';

  @override
  String get purchaseErrorTitle => 'Помилка покупки';

  @override
  String get purchaseInvalidTransactionBody =>
      'У покупці відсутній перевірюваний ID транзакції.';

  @override
  String get purchaseVerificationPendingTitle => 'Підтвердження в очікуванні';

  @override
  String get purchaseVerificationPendingBody =>
      'Зараз не вдалося підтвердити покупку в магазині. Процес завершиться автоматично, подвійного списання не відбудеться.';

  @override
  String get purchaseNotAppliedTitle => 'Покупку не застосовано';

  @override
  String get purchaseNotAppliedBody =>
      'Не вдалося застосувати покупку до вашого акаунта. Зверніться в підтримку та не купуйте повторно.';

  @override
  String get purchaseRestoreFailedTitle => 'Помилка відновлення';

  @override
  String get purchaseRestoreFailedBody =>
      'Не вдалося відновити покупки. Спробуйте ще раз.';

  @override
  String get purchaseRecoveredActiveBody => 'Ваш підписання активне.';

  @override
  String get purchaseCompleteTitle => 'Покупку завершено';

  @override
  String get giftCreateFailedTitle => 'Не вдалося створити подарунок';

  @override
  String get giftClaimFailedTitle => 'Не вдалося отримати подарунок';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подарунки для вас',
      one: 'Подарунок для вас',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 місяць',
      '12': '1 рік',
      'other': '$months місяців',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining залишилось',
      one: '1 залишилось',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender надіслав вам $duration FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Подарунок FitCheck Pro для $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Від $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Для $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Від $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'ваш отримувач';

  @override
  String get giftPreviewPlaceholderSender => 'ви';

  @override
  String get settingsSavedTitle => 'Збережено';

  @override
  String get settingsNotSavedTitle => 'Не збережено';

  @override
  String get settingsAiChooseProviderBody => 'Оберіть провайдера.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Для власного провайдера потрібен URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Введіть ключ API.';

  @override
  String get settingsAiSavedBody => 'Ваші налаштування ШІ збережено.';

  @override
  String get settingsAiMissingDetailsTitle => 'Відсутні дані';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Введіть URL API та модель чату для тесту.';

  @override
  String get settingsAiKeyNeededTitle => 'Потрібен ключ API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Введіть ваш API-ключ для тестування. Збережений ключ конфіденційний.';

  @override
  String get settingsAiKeyToTestBody => 'Введіть ваш API-ключ для тестування.';

  @override
  String get settingsAiConnectedTitle => 'Підключено';

  @override
  String get settingsAiConnectedBody => 'З\'єднання працює.';

  @override
  String get settingsAiTestFailedTitle => 'Тест не вдався';

  @override
  String get settingsPreferencesSavedBody => 'Ваші налаштування збережено.';

  @override
  String get settingsPasswordNotChangedTitle => 'Пароль не змінено';

  @override
  String get settingsOAuthPasswordBody =>
      'Цей акаунт входить через Google або Apple. Спочатку встановіть пароль через «Пароль втрачено».';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Поточний пароль невірний.';

  @override
  String get settingsExportReadyTitle => 'Експорт готово';

  @override
  String get settingsExportReadyBody =>
      'Експорт ваших даних готовий до завантаження.';

  @override
  String get settingsLinkCopiedTitle => 'Посилання скопійовано';

  @override
  String get settingsExportClipboardBody =>
      'Не вдалося відкрити браузер, тому ми скопіювали посилання для завантаження. Вставте його у браузер невідкладно: воно має строк дії.';

  @override
  String get settingsExportFailedTitle => 'Помилка експорту';

  @override
  String get settingsAccountNotDeletedTitle => 'Акаунт не видалено';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Можна додати до $max фото.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Обмеження фото';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Додайте хоча б одне фото.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Без фото';

  @override
  String get photoshootDescribeLookBody => 'Опишіть бажаний образ.';

  @override
  String get photoshootPromptNeededTitle => 'Потрібен запит';

  @override
  String get photoshootConsentFeatureLabel => 'AI фотосесія';

  @override
  String get photoshootStatusPreparing => 'Готуємо ваші фото';

  @override
  String get photoshootStatusGenerating => 'Генерується';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Партиія $current із $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'Готово $done із $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Помилка генерації.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready готово, $failed з помилкою.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Частково завершено';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото готово.',
      one: '1 фото готове.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'З\'єднання втрачено. Спробуйте ще раз.';

  @override
  String get photoshootCouldNotCancelTitle => 'Не вдалося скасувати';

  @override
  String get photoshootRetryFailedTitle => 'Повтор не вдалося';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Фото $number готово.';
  }

  @override
  String get photoshootReplacedTitle => 'Замінено';

  @override
  String get photoshootSavedToGalleryBody => 'Збережено у вашу галерею.';

  @override
  String get photoshootSavedTitle => 'Збережено';

  @override
  String get photoshootNotSavedTitle => 'Не збережено';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Усі $count фото у вашій галереї.',
      one: '1 фото у вашій галереї.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'Збережено $saved із $total.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Деякі фото не збережено';

  @override
  String get tryonConsentFeatureLabel => 'Віртуальна примірка';

  @override
  String get tryonAvatarUpdatedBody => 'Ваше фото оновлено.';

  @override
  String get tryonSavedTitle => 'Збережено';

  @override
  String get tryonUploadFailedTitle => 'Помилка завантаження';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Спершу оберіть фото предмета одягу.';

  @override
  String get tryonNoGarmentTitle => 'Немає одягу';

  @override
  String get tryonWaitForUploadBody =>
      'Зачekaйте, поки ваше фото завантажиться.';

  @override
  String get tryonStillUploadingTitle => 'Все ще завантажується';

  @override
  String get tryonAddYourPhotoFirstBody => 'Спершу додайте власне фото.';

  @override
  String get tryonReadyBody => 'Вашу примірку підготовлено.';

  @override
  String get tryonFailedTitle => 'Помилка примірки';

  @override
  String get tryonSavedToGalleryBody => 'Збережено у вашу галерею.';

  @override
  String get tryonNotSavedTitle => 'Не збережено';

  @override
  String get calendarEventAddedBody => 'Подію додано';

  @override
  String get calendarEventPlannedTitle => 'Заплановано';

  @override
  String get calendarEventSavedBody => 'Подію збережено';

  @override
  String get calendarSavedTitle => 'Збережено';

  @override
  String get calendarEventNotSavedTitle => 'Подію не збережено';

  @override
  String get calendarEventRemovedBody => 'Подію видалено';

  @override
  String get calendarEventDeletedTitle => 'Вилучено';

  @override
  String get calendarEventNotDeletedTitle => 'Подію не вилучено';

  @override
  String get calendarOutfitNotLinkedTitle => 'Комплект не прив\'язано';

  @override
  String get calendarLinkedTitle => 'Прив\'язано';

  @override
  String get calendarOutfitNotRemovedTitle => 'Комплект не вилучено';

  @override
  String get calendarOutfitRemovedBody => 'Комплект вилучено';

  @override
  String get calendarDisconnectedBody => 'Календар від\'єднано';

  @override
  String get calendarDisconnectedTitle => 'Від\'єднано';

  @override
  String get calendarNotDisconnectedTitle => 'Календар не від\'єднано';

  @override
  String get calendarTodayLabel => 'сьогодні';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подій',
      one: '1 подія',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'від $start до $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, комплект прив\'язано';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '«$title» буде вилучено.';
  }

  @override
  String get calendarThisAppLabel => 'Цей додаток';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Синхронізація з $provider ще недоступна. Ви все одно можете додавати події.';
  }

  @override
  String get calendarWeekdaySunShort => 'Нд';

  @override
  String get calendarWeekdayMonShort => 'Пн';

  @override
  String get calendarWeekdayTueShort => 'Вт';

  @override
  String get calendarWeekdayWedShort => 'Ср';

  @override
  String get calendarWeekdayThuShort => 'Чт';

  @override
  String get calendarWeekdayFriShort => 'Пт';

  @override
  String get calendarWeekdaySatShort => 'Сб';

  @override
  String get calendarWeekdayMonday => 'Понеділок';

  @override
  String get calendarWeekdayTuesday => 'Вівторок';

  @override
  String get calendarWeekdayWednesday => 'Середа';

  @override
  String get calendarWeekdayThursday => 'Четвер';

  @override
  String get calendarWeekdayFriday => 'П\'ятниця';

  @override
  String get calendarWeekdaySaturday => 'Субота';

  @override
  String get calendarWeekdaySunday => 'Неділя';

  @override
  String get outfitSavedToFavouritesBody => 'Додано до обраного';

  @override
  String get outfitRemovedFromFavouritesBody => 'Видалено з обраного';

  @override
  String get outfitNotSavedTitle => 'Не збережено';

  @override
  String get outfitLoggedAsWornBody => 'Відмічено як носилося сьогодні.';

  @override
  String get outfitNicePickTitle => 'Хороший вибір';

  @override
  String get outfitRemovedBody => 'Одяг видалено.';

  @override
  String get outfitDeletedTitle => 'Видалено';

  @override
  String get outfitNotDeletedTitle => 'Не видалено';

  @override
  String get outfitDuplicatedBody => 'Копія додана до ваших образів.';

  @override
  String get outfitDuplicatedTitle => 'Дубльовано';

  @override
  String get outfitNotDuplicatedTitle => 'Не дубльовано';

  @override
  String get outfitNotSharedTitle => 'Не поділено';

  @override
  String outfitCollectionReadyBody(String name) {
    return '«$name» готово.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Колекцію не створено';

  @override
  String get outfitCollectionUpdatedBody => 'Колекцію оновлено.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Колекцію не оновлено';

  @override
  String get outfitCollectionDeletedBody => 'Колекцію видалено.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Колекцію не видалено';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count одягів додано.',
      few: '$count одяги додано.',
      one: '1 одяг додано.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Одяг не додано';

  @override
  String get outfitPreviewNotCreatedTitle => 'Прев’ю не створено';

  @override
  String get outfitGiveNameBody => 'Назвайте цей образ.';

  @override
  String get outfitNameMissingTitle => 'Назва';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'Оберіть щонайменше один предмет.';

  @override
  String outfitCreatedBody(String name) {
    return '$name додано до ваших образів.';
  }

  @override
  String get outfitSavedTitle => 'Збережено';

  @override
  String get wardrobeAddedToFavouritesBody => 'Додано до обраного';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Видалено з обраного';

  @override
  String get wardrobeNotSavedTitle => 'Не збережено';

  @override
  String get wardrobeLoggedAsWornBody => 'Зареєстровано як одягнений сьогодні.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Видалено з вашої шафи.';

  @override
  String get wardrobeDeletedTitle => 'Видалено';

  @override
  String get wardrobeNotDeletedTitle => 'Не видалено';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предмети видалено з вашої шафи.',
      one: '1 предмет видалено з вашої шафи.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Занесення гардеробу через ШІ';

  @override
  String get itemAddScanJobLabel => 'Сканування';

  @override
  String get itemAddFoundEarlierBody => 'Знайдено в попередньому скануванні';

  @override
  String get itemAddLookingAtPhoto => 'Аналіз вашого фото';

  @override
  String get itemAddExtractionFailedBody => 'Помилка обробки';

  @override
  String get itemAddJobFailedBody => 'Помилка запиту';

  @override
  String get itemAddConnectionLostBody =>
      'З\'єднання втрачено. Спробуйте ще раз.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'З\'єднання втрачено під час обробки.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Предмет $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Предмет';

  @override
  String get itemAddNotCancelledTitle => 'Не скасовано';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предмети у вашій шафі.',
      one: '1 предмет у вашій шафі.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'Збережено $saved із $total предметів. Натисніть «Зберегти», щоб спробувати решту.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Деякі предмети не збережено';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Виберіть щонайменше одне фото.';

  @override
  String get batchPhotoUnreadableBody => 'Це фото не читати.';

  @override
  String get batchNoPhotosReadableBody =>
      'Жодне з цих фото не читається. Спробуйте інші.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото',
      one: '1 фото',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'З\'єднання втрачено під час обробки. Спробуйте ще раз.';

  @override
  String get batchNotCancelledTitle => 'Не скасовано';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Посилання на пости не підтримуються. Введіть посилання на профіль.';

  @override
  String get batchLinkSpacesBody => 'Посилання не містять пробілів.';

  @override
  String get batchEnterProfileLinkBody =>
      'Введіть посилання на профіль у Instagram або Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Введіть посилання на профіль.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Сторінка входу не відкрилася. Спробуйте ще раз.';

  @override
  String get batchSignInBrowserBody =>
      'Увійдіть у браузері, а потім поверніться до FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Під\'єднайте акаунт';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Введіть код із додатка-автентифікатора.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram вимагає перевірку безпеки. Спочатку увійдіть у браузері.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Введіть ім\'я користувача та пароль знову.';

  @override
  String get batchSignInFailedBody =>
      'Помилка входу. Перевірте ім\'я користувача та пароль.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Увійдіть, щоб продовжити імпортування.';

  @override
  String get batchAccountNotConnectedBody => 'Акаунт не під\'єднано.';

  @override
  String get batchAccountConnectedTitle => 'Акаунт під\'єднано';

  @override
  String get batchNotConnectedTitle => 'Не під\'єднано';

  @override
  String get batchImportConnectionLostBody =>
      'З\'єднання з імпортом втрачено. Оновіть, щоб перевірити.';

  @override
  String batchPickUpToBody(int max) {
    return 'Оберіть до $max фото. Ми знайдемо речі.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count із $total фото';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Підготовка фото $done із $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Знайти речі на $count фото',
      one: 'Знайти речі на 1 фото',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Акаунт $platform використовує двостадійний вхід. Введіть 6-значний код із додатка-автентифікатора.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Цей профіль $platform є приватним або потребує входу для перегляду фото.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Під\'єднати через $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Знайдено $count фото',
      one: 'Знайдено 1 фото',
    );
    return '$_temp0';
  }

  @override
  String batchImportStatusLine(
    int processed,
    int total,
    int added,
    int waiting,
    int skipped,
  ) {
    return 'Оброблено $processed із $total · Додано $added · Очікує $waiting · Пропущено $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Сканування фото $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Далі фото $number';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Фото $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Знайдено $count речей',
      one: 'Знайдено 1 річ',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото додано до вашої шафи.',
      one: '1 фото додано до вашої шафи.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ще $count студійних фото на підході. Ви можете зберегти те, що готово, або піти — ми повідомимо.',
      one:
          'Ще 1 студійне фото на підході. Ви можете зберегти те, що готово, або піти — ми повідомимо.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Ще не збережено: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces речей',
      one: '1 річ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos фото',
      one: '1 фото',
    );
    return '$_temp0 з $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return 'Обрано $chosen. Тисніть на річ, щоб пропустити.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Збереження $count речей',
      one: 'Збереження 1 речі',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Зберегти $count речей',
      one: 'Зберегти 1 реч',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Ваш профіль тіла збережено.';

  @override
  String get bodyProfileSavedTitle => 'Збережено';

  @override
  String get bodyProfileNotSavedTitle => 'Не збережено';

  @override
  String get bodyProfileSetDefaultBody => 'Установити як основний профіль.';

  @override
  String get bodyProfileDeletedBody => 'Профіль тіла видалено.';

  @override
  String get bodyProfileDeletedTitle => 'Видалено';

  @override
  String get bodyProfileNotDeletedTitle => 'Не видалено';

  @override
  String get feedbackNotSentTitle => 'Не надіслано';

  @override
  String get feedbackSentBody =>
      'Дякуємо. Ми читаємо всі повідомлення та відповідаємо, якщо потрібно більше деталей.';

  @override
  String get feedbackSentTitle => 'Зворотний зв’язок надіслано';

  @override
  String get recommendUnnamedPiece => 'Річ без назви';

  @override
  String get recommendEnterCityBody =>
      'Вкажіть місто, щоб отримати поради з урахуванням погоди.';

  @override
  String get recommendWhichCityTitle => 'Яке місто?';

  @override
  String get aiConsentSheetTitle => 'Передача фото в AI-сервіс';

  @override
  String get aiConsentSheetBody =>
      'Щоб створювати зображення спробувати одяг і фотосесії, FitCheck AI передає ваші фото (включаючи обличчя та тіло) надійному зовнішньому AI-провайдеру (наприклад, OpenAI або Google Gemini) для обробки. Вони генерують ваші зображення і не використовують їх для навчання моделей відповідно до наших умов. Фото передаються захищено і ніколи не використовуються для реклами.';

  @override
  String get aiConsentSheetPermission =>
      'Продовжуючи, ви надаєте явну дозволу на передачу ваших фото цим AI-провайдерам для генерації зображень.';

  @override
  String get skeletonsLoadMoreFailed => 'Не вдалося завантажити більше.';

  @override
  String get jobsPiecesReadyTitle => 'Ваші речі готові';

  @override
  String get jobsScanStoppedTitle => 'Сканування зупинено';

  @override
  String get jobsNothingSavedBody => 'Нічого не збережено. Спробуйте ще раз.';

  @override
  String get jobsPhotoUploadFailedBody => 'Не вдалося завантажити фото.';

  @override
  String get authGoogleSignInStartFailed =>
      'Не вдалося запустити вхід через Google. Спробуйте ще раз.';

  @override
  String get referralAppliedTitle => 'Реферал застосовано!';

  @override
  String get billingStoreUnavailableBody =>
      'Покупки в магазині недоступні на цьому пристрої.';

  @override
  String get billingPurchaseProcessingBody =>
      'Цю покупку все ще обробляють. Відкрийте застосунок через хвилину, щоб побачити свій план.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Завантаження аватара не повернуло посилання на зображення.';

  @override
  String get rewardsDayStreakLabel => 'ден стрік';

  @override
  String rewardsBestStreak(int days) {
    return 'Кращий стрік $days днів';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Потрібен доступ: $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Доступ до $permission у даний момент відхилено. Відкрийте Параметри, щоб надати дозвіл, а потім поверніться та спробуйте ще раз.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Крок $step із 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Крок $step із $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Видалити зображення $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Видалити зображення $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points пт';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Напишіть на $email. Ми розглядаємо звіти протягом 24 годин.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Видалити $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Видалити «$name»?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Додати до «$name»';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '«$name» видалено. Предмети лишаються в шафі.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Показати всі $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Сьогодні залишилось $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Фото $index не вдалося';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected із $max фото';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape статури · $tone тону шкіри';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Опції для $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Найчастіше носили: $name, $count разів';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: не вказано';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'Суперництво $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'Вибрано $picked із $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Видалити $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Пріоритет: $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Цей план обліковується через $store. Змініть або скашіть його в налаштуваннях свого облікового запису $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Керувати в $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: використано $current із $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Залишилось приблизно $seconds с';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return 'Готово $done із $total студійних фото';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return 'Готово $ready із $total студійних фото. Торкніться предмета, щоб пропустити.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height см · $weight кг';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'Ні';
}
