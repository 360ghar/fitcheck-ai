// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabPhotoshoot => 'Съемка';

  @override
  String get tabCloset => 'Гардероб';

  @override
  String get tabOutfits => 'Образы';

  @override
  String get tabMore => 'Ещё';

  @override
  String get actionAddItem => 'Добавить';

  @override
  String get actionCreateOutfit => 'Создать образ';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionSearch => 'Поиск';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get stateLoading => 'Загрузка';

  @override
  String get stateErrorTitle => 'Что-то пошло не так';

  @override
  String get stateErrorBody =>
      'Попробуйте еще раз. Если ошибка повторяется, обратитесь в поддержку.';

  @override
  String get stateOfflineTitle => 'Нет сети';

  @override
  String get stateOfflineBody =>
      'Подключитесь к интернету, чтобы синхронизировать гардероб и создавать образы.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAccountSection => 'Аккаунт';

  @override
  String get settingsPreferencesSection => 'Параметры';

  @override
  String get settingsPlanBilling => 'Тариф и оплата';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsUnits => 'Единицы измерения';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsPrivacySection => 'Конфиденциальность и данные';

  @override
  String get settingsAboutSection => 'О приложении';

  @override
  String get settingsSignOut => 'Выйти';

  @override
  String get settingsDeleteAccount => 'Удалить аккаунт';

  @override
  String get settingsDeleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get settingsDeleteAccountBody =>
      'Ваш гардероб, образы, фото и профиль будут удалены. Это действие необратимо.';

  @override
  String get settingsUnitsImperial => 'Английские (дюйм, фунт)';

  @override
  String get settingsUnitsMetric => 'Метрические (см, кг)';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystem => 'Как на устройстве';

  @override
  String get languageSystemBody =>
      'FitCheck AI использует язык вашего телефона.';

  @override
  String get languageSearchHint => 'Поиск языка';

  @override
  String get languageCurrent => 'Текущий';

  @override
  String get languageReviewNote =>
      'Этот перевод новый. Сообщите нам, если найдете неточности.';

  @override
  String get languageChanged => 'Язык обновлен';

  @override
  String get paywallTitle => 'Выберите тариф';

  @override
  String get paywallTrialBadge => '1 месяц бесплатно';

  @override
  String get paywallTrialTitle => 'Первый месяц Pro бесплатно';

  @override
  String get paywallTrialBody =>
      'Загрузите весь гардероб сразу, а новые вещи добавляйте по мере необходимости.';

  @override
  String get paywallFreeForeverTitle => 'Бесплатно всегда';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Карта не нужна. Каждый месяц вы получаете $uploads загрузок ИИ, $outfits образов и $images фото в день.';
  }

  @override
  String get paywallCtaTrial => 'Начать бесплатно';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Перейти на $plan';
  }

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallManage => 'Управление подпиской';

  @override
  String get paywallTerms => 'Условия использования';

  @override
  String get paywallPrivacy => 'Политика конфиденциальности';

  @override
  String get paywallPerMonth => 'в месяц';

  @override
  String get paywallPerYear => 'в год';

  @override
  String get paywallBestValue => 'Выгода';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Бесплатный период доступен только новым подписчикам. После окончания пробного периода подписка Pro продлевается за $price, если ее не отменить не позднее чем за 24 часа до окончания.';
  }

  @override
  String get introTitle => 'Ваш гардероб под контролем';

  @override
  String get introBody =>
      'Сфотографируйте вещи один из раз. Получайте идеи образов, примерку и студийные фото из того, что уже есть.';

  @override
  String get introStart => 'Начать';

  @override
  String get introHaveAccount => 'У меня уже есть аккаунт';

  @override
  String get introSkip => 'Пропустить';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignUp => 'Создать аккаунт';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authContinueApple => 'Продолжить с Apple';

  @override
  String get authContinueGoogle => 'Продолжить с Google';

  @override
  String get authOrDivider => 'или';

  @override
  String get wardrobeTitle => 'Гардероб';

  @override
  String get wardrobeEmptyTitle => 'Гардероб пуст';

  @override
  String get wardrobeEmptyBody =>
      'Добавьте первую вещь или загрузите фото вешалки целиком.';

  @override
  String get wardrobeAddFirst => 'Добавить первую вещь';

  @override
  String get wardrobeSearchHint => 'Поиск по гардеробу';

  @override
  String get categoryTops => 'Верх';

  @override
  String get categoryBottoms => 'Низ';

  @override
  String get categoryShoes => 'Обувь';

  @override
  String get categoryAccessories => 'Аксессуары';

  @override
  String get categoryOuterwear => 'Верхняя одежда';

  @override
  String get categorySwimwear => 'Купальники';

  @override
  String get categoryActivewear => 'Спорт';

  @override
  String get categoryOther => 'Другое';

  @override
  String get conditionClean => 'Чистое';

  @override
  String get conditionDirty => 'Грязное';

  @override
  String get conditionLaundry => 'В стирке';

  @override
  String get conditionRepair => 'В ремонт';

  @override
  String get conditionDonate => 'Отдать';

  @override
  String get seasonSpring => 'Весна';

  @override
  String get seasonSummer => 'Лето';

  @override
  String get seasonFall => 'Осень';

  @override
  String get seasonWinter => 'Зима';

  @override
  String get seasonAll => 'Всесезонное';

  @override
  String get styleCasual => 'Кэжуал';

  @override
  String get styleFormal => 'Строгий';

  @override
  String get styleBusiness => 'Деловой';

  @override
  String get styleSporty => 'Спортивный';

  @override
  String get styleBohemian => 'Бохо';

  @override
  String get styleStreetwear => 'Стритстайл';

  @override
  String get styleVintage => 'Винтаж';

  @override
  String get styleMinimalist => 'Минимализм';

  @override
  String get styleRomantic => 'Романтичный';

  @override
  String get styleEdgy => 'Дерзкий';

  @override
  String get stylePreppy => 'Преппи';

  @override
  String get styleArtsy => 'Арт';

  @override
  String get styleClassic => 'Классика';

  @override
  String get styleElegant => 'Элегантный';

  @override
  String get styleOther => 'Другое';

  @override
  String get occasionWork => 'Работа';

  @override
  String get occasionDateNight => 'Свидание';

  @override
  String get occasionTravel => 'Путешествие';

  @override
  String get occasionWedding => 'Свадьба';

  @override
  String get occasionGym => 'Зал';

  @override
  String get occasionWeekend => 'Уик-энд';

  @override
  String get occasionParty => 'Вечеринка';

  @override
  String get occasionInterview => 'Собеседование';

  @override
  String get colorBlack => 'Черный';

  @override
  String get colorWhite => 'Белый';

  @override
  String get colorGrey => 'Серый';

  @override
  String get colorNavy => 'Темно-синий';

  @override
  String get colorBrown => 'Коричневый';

  @override
  String get colorRed => 'Красный';

  @override
  String get colorBlue => 'Синий';

  @override
  String get colorGreen => 'Зеленый';

  @override
  String get colorPink => 'Розовый';

  @override
  String get colorPurple => 'Фиолетовый';

  @override
  String get colorYellow => 'Желтый';

  @override
  String get colorOrange => 'Оранжевый';

  @override
  String get colorBeige => 'Бежевый';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '1 день назад',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недель назад',
      many: '$count недель назад',
      few: '$count недели назад',
      one: '1 неделю назад',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяцев назад',
      many: '$count месяцев назад',
      few: '$count месяца назад',
      one: '1 месяц назад',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лет назад',
      many: '$count лет назад',
      few: '$count года назад',
      one: '1 год назад',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Нравится FitCheck AI?';

  @override
  String get ratingPromptBody => 'Ваша оценка поможет другим найти свой стиль.';

  @override
  String get ratingPromptYes => 'Оценить';

  @override
  String get ratingPromptNo => 'Не сейчас';

  @override
  String get closetNoMatchesTitle => 'Ничего не найдено';

  @override
  String get closetNoMatchesBody => 'Сбросьте фильтры или измените поиск.';

  @override
  String get closetClearFilters => 'Сбросить';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вещь',
      many: '$count вещей',
      few: '$count вещи',
      one: '1 вещь',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Загрузка вещей';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count',
      many: 'Выбрано $count',
      few: 'Выбрано $count',
      one: 'Выбрана 1',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Удалить выбранное';

  @override
  String get closetCancelSelection => 'Отмена';

  @override
  String get closetCloseSearch => 'Закрыть';

  @override
  String get closetShowGrid => 'Сетка';

  @override
  String get closetShowList => 'Список';

  @override
  String get closetShowRows => 'Строки';

  @override
  String get closetStatsTitle => 'Статистика';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count вещей?',
      many: 'Удалить $count вещей?',
      few: 'Удалить $count вещи?',
      one: 'Удалить 1 вещь?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Вещи будут удалены из всех образов.';

  @override
  String get closetSortBy => 'Сортировка';

  @override
  String get closetFavourites => 'Избранное';

  @override
  String get closetFavourite => 'В избранное';

  @override
  String get closetUnfavourite => 'Убрать из избранного';

  @override
  String get closetWoreToday => 'Надето сегодня';

  @override
  String closetWornTimes(int count) {
    return 'Надето $count×';
  }

  @override
  String get closetCategoryLabel => 'Категория';

  @override
  String get closetUseCaseLabel => 'Событие';

  @override
  String get closetAnyUseCase => 'Любое';

  @override
  String get closetOtherUseCase => 'Другое';

  @override
  String get closetOtherUseCaseHint => 'Например, бранч';

  @override
  String get closetUseUseCase => 'Применить';

  @override
  String get closetClearAll => 'Очистить все';

  @override
  String get sortNewest => 'Сначала новые';

  @override
  String get sortOldest => 'Сначала старые';

  @override
  String get sortName => 'По имени (А–Я)';

  @override
  String get sortMostWorn => 'Популярные';

  @override
  String get useCaseInformal => 'Повседневное';

  @override
  String get useCaseDate => 'Свидание';

  @override
  String get useCaseDinner => 'Ужин';

  @override
  String get useCaseLunch => 'Обед';

  @override
  String get actionSelect => 'Выбрать';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionFilter => 'Фильтр';

  @override
  String get actionSort => 'Сортировка';

  @override
  String get actionAll => 'Все';

  @override
  String get dashboardStartClosetTitle => 'Соберите гардероб';

  @override
  String get dashboardStartClosetBody =>
      'Сфотографируйте несколько вещей. Мы их распознаем.';

  @override
  String get dashboardPieces => 'вещей';

  @override
  String get dashboardOutfits => 'образов';

  @override
  String get dashboardDayStreak => 'дней подряд';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count в этом месяце';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Рекорд $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# избранного',
      many: '# избранных',
      few: '# избранных',
      one: '1 избранное',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# сохраненного образа',
      many: '# сохраненных образов',
      few: '# сохраненных образа',
      one: '1 сохраненный образ',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Чаще всего: $name, $count раз';
  }

  @override
  String get setupSkip => 'Пропустить настройку';

  @override
  String get setupWhoTitle => 'Для кого подбираем стиль?';

  @override
  String get setupWhoBody =>
      'Задает модель для примерки и съемок. Изменить можно в профиле.';

  @override
  String get setupStyleTitle => 'Что вы носите чаще всего?';

  @override
  String get setupStyleBody => 'Выберите любые. С них начнутся идеи образов.';

  @override
  String get setupClosetTitle => 'Добавьте первые вещи.';

  @override
  String get setupClosetBody =>
      'Сфотографируйте пару вещей или стопку одежды. Каждая вещь будет обработана и сохранена.';

  @override
  String get setupAddClothes => 'Добавить одежду';

  @override
  String get setupStylesLabel => 'Стили';

  @override
  String get setupOccasionsLabel => 'Поводы';

  @override
  String get setupSkipStep => 'Пропустить';

  @override
  String get setupLater => 'Позже';

  @override
  String get setupSaveError => 'Не удалось сохранить';

  @override
  String get genderWomen => 'Женский';

  @override
  String get genderMen => 'Мужской';

  @override
  String get genderNonBinary => 'Небинарный';

  @override
  String get genderPreferNotToSay => 'Не указывать';

  @override
  String get outfitEmptyTitle => 'Пока нет образов';

  @override
  String get outfitEmptyBody =>
      'Сочетайте вещи из гардероба и сохраняйте луки.';

  @override
  String get outfitNoMatchesTitle => 'Нет подходящих образов';

  @override
  String get outfitSearchHint => 'Поиск по образам';

  @override
  String get outfitLoading => 'Загрузка образов';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# образа',
      many: '# образов',
      few: '# образа',
      one: '1 образ',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Стиль и сезон';

  @override
  String get outfitCollections => 'Коллекции';

  @override
  String get outfitDuplicate => 'Дублировать';

  @override
  String get outfitDeleteTitle => 'Удалить этот образ?';

  @override
  String get outfitDeleteBody => 'Сами вещи останутся в гардеробе.';

  @override
  String get outfitDrafts => 'Черновики';

  @override
  String get outfitDraft => 'Черновик';

  @override
  String get filterStyle => 'Стиль';

  @override
  String get filterSeason => 'Сезон';

  @override
  String get itemDetailDeleteTitle => 'Удалить эту вещь?';

  @override
  String get itemDetailDeleteBody =>
      'Она пропадет из всех образов, где использовалась.';

  @override
  String get itemAddFavourite => 'В избранное';

  @override
  String itemSize(String size) {
    return 'Размер $size';
  }

  @override
  String get itemColours => 'Цвета';

  @override
  String get itemMaterial => 'Материал';

  @override
  String get itemPattern => 'Принт';

  @override
  String get itemUseCases => 'Поводы';

  @override
  String get itemKeptIn => 'Где хранится';

  @override
  String get itemPrice => 'Цена';

  @override
  String get itemBought => 'Куплено';

  @override
  String get itemTags => 'Теги';

  @override
  String get itemAdded => 'Добавлено';

  @override
  String get itemTimesWornLabel => 'раз надето';

  @override
  String get itemLastWornLabel => 'последний раз';

  @override
  String get itemNeverWorn => 'Никогда';

  @override
  String get authEntryBody =>
      'Ваш гардероб под управлением ИИ. Планируйте образы, примеряйте, снимайте.';

  @override
  String get authCreateCloset => 'Создать гардероб';

  @override
  String get authWelcomeBack => 'С возвращением';

  @override
  String get authSignInBody => 'Войдите, чтобы открыть гардероб.';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authCreateClosetBody =>
      'Это займет минуту. Первые вещи — бесплатно.';

  @override
  String get authName => 'Имя';

  @override
  String get authConfirmPassword => 'Подтвердите пароль';

  @override
  String get authReferralCode => 'Реферальный код (опционально)';

  @override
  String get authResetTitle => 'Сброс пароля';

  @override
  String get authResetBody => 'Мы отправим ссылку для смены пароля на почту.';

  @override
  String get authSendResetLink => 'Отправить ссылку';

  @override
  String get authBackToSignIn => 'Назад к входу';

  @override
  String get authEnterEmail => 'Введите email';

  @override
  String get authEnterValidEmail => 'Введите корректный email';

  @override
  String get authEnterPassword => 'Введите пароль';

  @override
  String get authPasswordTooShort => 'Минимум 6 символов';

  @override
  String get authShowPassword => 'Показать пароль';

  @override
  String get authHidePassword => 'Скрыть пароль';

  @override
  String get authNewHere => 'Впервые здесь?';

  @override
  String authConfirmEmail(String email) {
    return 'Подтвердите $email перед входом. Проверьте почту.';
  }

  @override
  String get authResendEmail => 'Отправить еще раз';

  @override
  String get authResendingEmail => 'Отправка...';

  @override
  String get authPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get authEnterName => 'Введите имя';

  @override
  String get authChoosePassword => 'Придумайте пароль';

  @override
  String get authHaveAccount => 'Уже есть аккаунт?';

  @override
  String get authCodeAccepted => 'Код принят';

  @override
  String get authCodeNotFound => 'Код не найден';

  @override
  String authReferralFrom(String name) {
    return 'От $name. Вы оба получите месяц бесплатно.';
  }

  @override
  String get authReferralInvalid => 'Код не найден.';

  @override
  String authResetSent(String email) {
    return 'Отправлено на $email. Откройте ссылку на этом телефоне.';
  }

  @override
  String get introSlide1Title => 'Сфотографируйте гардероб.';

  @override
  String get introSlide1Body =>
      'Сфотографируйте вещи. Мы сами вырежем и сохраним каждый предмет.';

  @override
  String get introSlide2Title => 'Одевайтесь быстрее.';

  @override
  String get introSlide2Body =>
      'Образы из ваших вещей с учетом планов и погоды.';

  @override
  String get introSlide3Title => 'Примерьте до выхода.';

  @override
  String get introSlide3Body =>
      'Примеряйте образы на своем фото или создавайте стильные сеты.';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Темная';

  @override
  String get settingsTemperature => 'Температура';

  @override
  String get settingsEmailUpdates => 'Email-рассылки';

  @override
  String get settingsEmailUpdatesBody => 'Новости и советы на почту';

  @override
  String get settingsOutfitReminders => 'Напоминания';

  @override
  String get settingsOutfitRemindersBody =>
      'Напоминание отметить, что вы надели';

  @override
  String get settingsWeeklySummary => 'Итоги недели';

  @override
  String get settingsWeeklySummaryBody => 'Ваша неделя в образах';

  @override
  String get settingsStyleSection => 'Стиль';

  @override
  String get settingsPreferredStyles => 'Любимые стили';

  @override
  String get settingsPreferredColours => 'Любимые цвета';

  @override
  String get settingsNoneChosen => 'Не выбрано';

  @override
  String get settingsPlanAiSection => 'Подписка и ИИ';

  @override
  String get settingsPlanBillingBody => 'Тариф, лимиты и улучшения';

  @override
  String get settingsPlanUsageBody => 'Тариф и лимиты';

  @override
  String get settingsInviteFriends => 'Пригласить друзей';

  @override
  String get settingsInviteFriendsBody => 'Месяц бесплатно за каждого друга';

  @override
  String get settingsAiProvider => 'Провайдер ИИ';

  @override
  String get settingsAiProviderBody => 'Своя модель для тегов и изображений';

  @override
  String get settingsAppVersion => 'Версия приложения';

  @override
  String get settingsPrivacyTerms => 'Конфиденциальность и условия';

  @override
  String get settingsReportProblem => 'Сообщить о проблеме';

  @override
  String get settingsChangePassword => 'Изменить пароль';

  @override
  String get settingsExportData => 'Экспорт данных';

  @override
  String get settingsExportBody =>
      'Мы подготовим файл со всеми данными и откроем загрузку.';

  @override
  String get settingsExportAction => 'Экспорт';

  @override
  String get settingsCurrentPassword => 'Текущий пароль';

  @override
  String get settingsNewPassword => 'Новый пароль';

  @override
  String get settingsConfirmNewPassword => 'Подтвердите новый пароль';

  @override
  String get settingsEnterCurrentPassword => 'Введите текущий пароль';

  @override
  String get settingsEnterNewPassword => 'Введите новый пароль';

  @override
  String get settingsPasswordMin8 => 'Минимум 8 символов';

  @override
  String get settingsPasswordNeedsUpper => 'Нужна заглавная буква';

  @override
  String get settingsPasswordNeedsLower => 'Нужна строчная буква';

  @override
  String get settingsPasswordNeedsDigit => 'Нужна цифра';

  @override
  String get settingsPasswordsNoMatch => 'Пароли не совпадают';

  @override
  String get settingsChangeAction => 'Изменить';

  @override
  String get itemAddSnapTitle => 'Сфотографировать вещь';

  @override
  String get itemAddSnapBody =>
      'Мы найдем каждую вещь на фото и сделаем чистый студийный снимок.';

  @override
  String get itemAddCamera => 'Сделать фото';

  @override
  String get itemAddGallery => 'Выбрать из галереи';

  @override
  String get itemAddOtherWays => 'Другие способы';

  @override
  String get itemAddSeveral => 'Добавить несколько фото';

  @override
  String get itemAddSeveralBody => 'До 50 за раз';

  @override
  String get itemAddImportProfile => 'Импорт из профиля';

  @override
  String get itemAddImportProfileBody => 'Instagram или Facebook';

  @override
  String get itemAddEnterDetails => 'Ввести данные вручную';

  @override
  String get itemAddEnterDetailsBody => 'Фото не требуется';

  @override
  String get itemManualIntro =>
      'Нужно только название. Остальное можно добавить позже.';

  @override
  String get itemManualNameHint => 'Например, синяя футболка';

  @override
  String get itemManualEnterName => 'Введите название';

  @override
  String get itemManualNotes => 'Заметки';

  @override
  String get itemManualBrand => 'Бренд';

  @override
  String get itemManualSize => 'Размер';

  @override
  String get itemManualEnterNumber => 'Введите число';

  @override
  String get itemManualSavePiece => 'Сохранить вещь';

  @override
  String get itemManualSaving => 'Сохранение';

  @override
  String get itemManualSavedTitle => 'Сохранено';

  @override
  String itemManualSavedBody(String name) {
    return '$name теперь в гардеробе.';
  }

  @override
  String get itemManualNotSaved => 'Не сохранено';

  @override
  String get itemManualAddUseCase => 'Добавить назначение';

  @override
  String get itemManualAddUseCaseAction => 'Добавить повод';

  @override
  String get itemPhotos => 'Фото';

  @override
  String get itemAddPhotos => 'Добавить фото';

  @override
  String get itemNoPhotoYet => 'Фото пока нет. Можно сохранить без него.';

  @override
  String get itemRemovePhoto => 'Удалить фото';

  @override
  String get itemRemovePiece => 'Удалить вещь';

  @override
  String get filterConditionLabel => 'Состояние';

  @override
  String get photoshootStepPhotos => 'Фото';

  @override
  String get photoshootStepSetup => 'Настройка';

  @override
  String get photoshootStepCreating => 'Создание';

  @override
  String get photoshootStepResults => 'Результаты';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Шаг $current из $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Ошибка в одном фото. Повторите попытку ниже.';

  @override
  String photoshootManyFailed(int count) {
    return '$count фото не сохранились. Повторите каждое ниже.';
  }

  @override
  String get photoshootFormat => 'Формат';

  @override
  String get photoshootHowMany => 'Количество';

  @override
  String get photoshootYourPrompt => 'Ваш запрос';

  @override
  String get photoshootPromptHint => 'Золотой час на крыше, льняная рубашка';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Создать $count фото',
      one: 'Создать 1 фото',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'фото',
      one: 'фото',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Не удалось проверить лимит.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Тариф $plan: $remaining из $limit на сегодня';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Бесплатный';

  @override
  String get photoshootGallery => 'Галерея';

  @override
  String get photoshootUseCamera => 'Камера';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Удалить фото $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Фото не созданы';

  @override
  String get photoshootNoPhotosBody =>
      'Съемка прошла без фото. Попробуйте еще раз.';

  @override
  String get photoshootNewStyle => 'Новый стиль';

  @override
  String get photoshootNewPhotos => 'Новые фото';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Открыть фото $number';
  }

  @override
  String get photoshootReportPhoto => 'Пожаловаться';

  @override
  String get photoshootSaveToGallery => 'В галерею';

  @override
  String get actionUpgrade => 'Улучшить';

  @override
  String get referralLimitTitle => 'Лимит исчерпан';

  @override
  String get referralLimitBody =>
      'Бесплатные фото обновятся завтра. Пригласите друга, и вы оба получите месяц Pro бесплатно.';

  @override
  String get referralLimitRefer => 'Пригласить друга';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Дейтинг';

  @override
  String get photoshootUsePortfolio => 'Портфолио';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Эстетика';

  @override
  String get photoshootUseCustom => 'Свой запрос';

  @override
  String get photoshootDescLinkedin => 'Деловые портреты';

  @override
  String get photoshootDescDating => 'Расслабленный, теплый, естественный';

  @override
  String get photoshootDescPortfolio => 'Editorial, высокая мода';

  @override
  String get photoshootDescInstagram => 'Лайфстайл для вашей ленты';

  @override
  String get photoshootDescAesthetic => 'Атмосферные, художественные кадры';

  @override
  String get photoshootDescCustom => 'Опишите желаемый образ';

  @override
  String get aspectSquare => 'Квадрат';

  @override
  String get aspectPortrait => 'Портрет';

  @override
  String get aspectLandscape => 'Альбомный';

  @override
  String get aspectTall => 'Вертикальный';

  @override
  String get aspectWide => 'Широкий';

  @override
  String get tryOnAppBar => 'Виртуальная примерка';

  @override
  String get tryOnYourPhoto => 'Ваше фото';

  @override
  String get tryOnGarment => 'Вещь';

  @override
  String get tryOnUploadingPhoto => 'Загрузка фото';

  @override
  String get tryOnAddPhotoPrompt => 'Добавьте фото в полный рост';

  @override
  String get tryOnBodyPhotoHint => 'Лучше всего подходит фото в полный рост';

  @override
  String get tryOnAddPhoto => 'Добавить фото';

  @override
  String get tryOnChangePhoto => 'Изменить фото';

  @override
  String get tryOnPhotoLoadFailed => 'Не удалось загрузить фото.';

  @override
  String get tryOnChooseGarment => 'Выберите фото вещи';

  @override
  String get tryOnChooseOneGarment => 'Выберите одно фото вещи';

  @override
  String get tryOnGarmentHint =>
      'Лучше всего подходит фото на вешалке или в разложенном виде';

  @override
  String get tryOnChange => 'Изменить';

  @override
  String get tryOnCamera => 'Камера';

  @override
  String get tryOnRemove => 'Удалить';

  @override
  String get tryOnLookTitle => 'Образ';

  @override
  String get tryOnStyle => 'Стиль';

  @override
  String get tryOnBackground => 'Фон';

  @override
  String get tryOnPose => 'Поза';

  @override
  String get tryOnDressingUp => 'Примеряем образ. Это займет около полминуты.';

  @override
  String get tryOnEmptyResult => 'Здесь появится ваша примерка';

  @override
  String get tryOnReportImage => 'Пожаловаться на фото';

  @override
  String get tryOnCreating => 'Создание';

  @override
  String get tryOnTryAgain => 'Попробовать снова';

  @override
  String get tryOnCreate => 'Создать примерку';

  @override
  String get tryOnBackgroundStudioWhite => 'Студийный белый';

  @override
  String get tryOnBackgroundStudioGrey => 'Студийный серый';

  @override
  String get tryOnBackgroundUrban => 'Городская улица';

  @override
  String get tryOnBackgroundNature => 'Природа';

  @override
  String get tryOnBackgroundMinimal => 'Минимализм';

  @override
  String get tryOnPoseFront => 'Вид спереди';

  @override
  String get tryOnPoseSide => 'Вид сбоку';

  @override
  String get tryOnPoseWalking => 'В движении';

  @override
  String get dashboardGreetingMorning => 'Доброе утро';

  @override
  String get dashboardGreetingAfternoon => 'Добрый день';

  @override
  String get dashboardGreetingEvening => 'Добрый вечер';

  @override
  String get dashboardWelcome => 'Добро пожаловать';

  @override
  String get dashboardOpenProfile => 'Открыть профиль';

  @override
  String get dashboardRailToday => 'Сегодня';

  @override
  String get dashboardRailRecently => 'Недавнее';

  @override
  String get dashboardActivityEmpty => 'Здесь появятся новые вещи и образы.';

  @override
  String get quickAddPiece => 'Добавить вещь';

  @override
  String get quickAddPieceBody => 'Сфотографировать и отметить';

  @override
  String get quickBuildOutfit => 'Создать образ';

  @override
  String get quickBuildOutfitBody => 'Комбинируйте вещи';

  @override
  String get quickForYou => 'Для вас';

  @override
  String get quickForYouBody => 'Подборка на сегодня';

  @override
  String get quickPlanWeek => 'План на неделю';

  @override
  String get quickPlanWeekBody => 'Образы по датам';

  @override
  String get referralBannerUrgent => 'Заканчиваются попытки? Пригласите друга.';

  @override
  String get referralBannerTitle => 'Месяц вам, месяц другу.';

  @override
  String get referralBannerBody => 'Вы и ваш друг получите месяц Pro.';

  @override
  String get referralBannerDismiss => 'Скрыть на неделю';

  @override
  String get referralBannerShare => 'Поделиться';

  @override
  String get referralBannerCopy => 'Скопировать ссылку';

  @override
  String get itemEditPieceTitle => 'Редактировать вещь';

  @override
  String get itemEditDescriptionLabel => 'Описание';

  @override
  String get itemEditNotSaved => 'Не сохранено';

  @override
  String get itemEditSavedTitle => 'Сохранено';

  @override
  String get itemEditSavedBody => 'Изменения сохранены.';

  @override
  String get itemEditSavedStalePhotos =>
      'Сохранено — фото могут быть неактуальны';

  @override
  String get itemEditRemovePieceHint =>
      'Удалить эту вещь со страницы предмета.';

  @override
  String get itemEditNoPhotos =>
      'Пока нет фото. Добавьте из галереи или камеры.';

  @override
  String get itemEditKeepPhoto => 'Оставить фото';

  @override
  String get itemEditRemoved => 'Удалено';

  @override
  String get itemEditAddUseCaseAction => 'Добавить';

  @override
  String get statsNoStatsTitle => 'Статистики пока нет';

  @override
  String get statsNoStatsBody =>
      'Добавьте несколько вещей, и здесь появится состав вашего гардероба.';

  @override
  String get statsByCategory => 'По категориям';

  @override
  String get statsTotalValue => 'общая стоимость';

  @override
  String get statsMostWorn => 'Чаще всего';

  @override
  String get statsLeastWorn => 'Ждут своей очереди';

  @override
  String get statsUnnamedPiece => 'Вещь без названия';

  @override
  String get jobsTitle => 'Сканирования';

  @override
  String get jobsEmptyTitle => 'Сканирований нет';

  @override
  String get jobsEmptyBody =>
      'Сфотографируйте вещь и отправьте в фон — процесс продолжится здесь.';

  @override
  String get jobsNotCancelled => 'Не отменено';

  @override
  String get jobsResume => 'Продолжить';

  @override
  String get jobsReview => 'Проверить';

  @override
  String get jobsStop => 'Остановить';

  @override
  String get jobsDismiss => 'Отклонить';

  @override
  String get reportTitle => 'Пожаловаться';

  @override
  String reportIntro(String contentType) {
    return 'Расскажите, что не так с этим $contentType. Наша команда проверяет все жалобы.';
  }

  @override
  String get reportReasonInappropriate =>
      'Неуместный или оскорбительный контент';

  @override
  String get reportReasonNudity => 'Нагота или контент сексуального характера';

  @override
  String get reportReasonHarassment => 'Домогательства или оскорбления';

  @override
  String get reportReasonImpersonation => 'Выдача себя за другого человека';

  @override
  String get reportReasonOther => 'Другое';

  @override
  String get reportDetailsLabel => 'Дополнительные детали (необязательно)';

  @override
  String get reportSubmit => 'Отправить жалобу';

  @override
  String get reportSubmittedTitle => 'Жалоба отправлена';

  @override
  String get reportSubmittedBody =>
      'Спасибо. Наша команда рассмотрит этот контент.';

  @override
  String get reportFailedTitle => 'Не удалось отправить жалобу';

  @override
  String get reportFailedBody => 'Пожалуйста, попробуйте еще раз.';

  @override
  String get reportContentTryOnImage => 'примерка с ИИ';

  @override
  String get reportContentSharedOutfit => 'опубликованный образ';

  @override
  String get reportContentPhotoshootImage => 'фотосессия с ИИ';

  @override
  String get sharedOutfitTitle => 'Общий образ';

  @override
  String get sharedOutfitHideTooltip => 'Скрыть этот образ';

  @override
  String get sharedOutfitReportTooltip => 'Пожаловаться на образ';

  @override
  String get sharedOutfitHideTitle => 'Скрыть этот образ?';

  @override
  String get sharedOutfitHideBody =>
      'Он будет скрыт на этом устройстве. Вы также можете пожаловаться на него, чтобы наша команда проверила и удалила его.';

  @override
  String get sharedOutfitHideAction => 'Скрыть';

  @override
  String get sharedOutfitHiddenInfo =>
      'Этот образ больше не будет отображаться на этом устройстве.';

  @override
  String get sharedOutfitHiddenToast => 'Образ скрыт';

  @override
  String get sharedOutfitMissingTitle => 'Этот образ больше недоступен';

  @override
  String get sharedOutfitMissingBody =>
      'Возможно, он был удален или ссылка неверна.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Вы скрыли этот образ';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Если контент неприемлем, сообщите об этом в разделе Конфиденциальность и условия или напишите на $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Нравится образ?';

  @override
  String get sharedOutfitCtaBody =>
      'Создавайте похожие образы из своего гардероба.';

  @override
  String get sharedOutfitCtaButton => 'Получить FitCheck AI';

  @override
  String get errorTitle => 'Ошибка';

  @override
  String get errorUnknown => 'Произошла непредвиденная ошибка';

  @override
  String get errorNoConnection =>
      'Нет подключения к интернету. Проверьте сеть.';

  @override
  String get errorTimeout => 'Превышено время ожидания. Попробуйте снова.';

  @override
  String get errorServerError =>
      'Что-то пошло не так на нашем сервере. Попробуйте снова.';

  @override
  String get errorBadGateway => 'Сервер временно недоступен. Попробуйте снова.';

  @override
  String get errorServiceUnavailable =>
      'Сервис временно недоступен. Попробуйте чуть позже.';

  @override
  String get errorInternalError => 'Что-то пошло не так. Попробуйте снова.';

  @override
  String get errorUnauthorized => 'Войдите, чтобы продолжить.';

  @override
  String get errorForbidden => 'У вас нет доступа.';

  @override
  String get errorSessionExpired => 'Сеанс истек. Войдите снова.';

  @override
  String get errorInvalidCredentials => 'Неверный email или пароль.';

  @override
  String get errorTokenRefreshFailed =>
      'Не удалось обновить сеанс. Войдите снова.';

  @override
  String get errorRequestCancelled => 'Запрос отменен.';

  @override
  String get errorInvalidFormat => 'Этот формат файла не поддерживается.';

  @override
  String get errorFileTooLarge => 'Файл слишком большой.';

  @override
  String get errorUploadFailed => 'Не удалось загрузить. Попробуйте снова.';

  @override
  String get errorCacheCorrupted =>
      'Сохраненные данные повреждены и были сброшены.';

  @override
  String get errorCacheNotFound => 'Ничего не сохранено.';

  @override
  String get errorUserNotFound => 'Аккаунт не найден.';

  @override
  String get errorItemNotFound => 'Эта вещь больше не существует.';

  @override
  String get errorOutfitNotFound => 'Этот образ больше не существует.';

  @override
  String get rewardsTitle => 'Награды';

  @override
  String get rewardsNoAchievementsTitle => 'Пока нет достижений';

  @override
  String get rewardsNoAchievementsBody =>
      'Добавляйте вещи и составляйте образы, чтобы получить первое.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'В таблице пока никого нет';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Составляйте образы, зарабатывайте очки и попадайте сюда.';

  @override
  String get legalViewPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get aiConsentAgree => 'Принять и продолжить';

  @override
  String get aiConsentNotNow => 'Не сейчас';

  @override
  String get imageViewerCloseTooltip => 'Закрыть просмотр';

  @override
  String get updateReadyTitle => 'Доступно обновление';

  @override
  String get updateReadyBody =>
      'Перезапустите FitCheck AI для применения улучшений.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI нужен доступ к камере для съемки ваших образов и вещей.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI нужен доступ к галерее для выбора фото ваших вещей и образов.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI нужно сохранять созданные образы в вашу галерею.';

  @override
  String get wardrobeSomePhotosSkipped => 'Часть фото пропущена';

  @override
  String get wardrobePhotosNotAdded => 'Фото не добавлены';

  @override
  String get wardrobePhotoNotAdded => 'Фото не добавлено';

  @override
  String get wardrobeNotStartedTitle => 'Не начато';

  @override
  String get wardrobeNoRoomTitle => 'Нет места';

  @override
  String get wardrobeAddPhotosSemantic => 'Добавить фото';

  @override
  String get batchAddTileLabel => 'Добавить';

  @override
  String get batchProfileLinkLabel => 'Ссылка на профиль';

  @override
  String get wardrobeImportFromProfileTitle => 'Импорт из профиля';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Добавить несколько фото';

  @override
  String get wardrobeClearAction => 'Очистить';

  @override
  String get wardrobeRefreshTooltip => 'Обновить';

  @override
  String get batchNoPhotosYetTitle => 'Нет фото';

  @override
  String get batchChoosePhotosAction => 'Выбрать фото';

  @override
  String get batchWeFindEachPieceBody =>
      'Мы найдем каждую вещь и сделаем ее студийное фото.';

  @override
  String get batchPreparingPhotosSemantic => 'Подготовка фото';

  @override
  String get batchPhotosProcessedSemantic => 'Фото обработаны';

  @override
  String get batchPasteProfileLinkTitle => 'Вставьте ссылку на профиль';

  @override
  String get batchPasteProfileLinkBody =>
      'Публичный профиль Instagram или Facebook. Мы сканируем фото, а вы выбираете вещи в шкаф.';

  @override
  String get batchClearLinkTooltip => 'Очистить ссылку';

  @override
  String get batchStartingButton => 'Запуск';

  @override
  String get batchStartImportAction => 'Начать импорт';

  @override
  String get batchReviewEveryPhotoTitle => 'Проверьте каждое фото';

  @override
  String get batchReviewEveryPhotoBody =>
      'Ничего не добавится, пока вы не подтвердите.';

  @override
  String get batchPrivateProfilesTitle => 'Закрытые профили';

  @override
  String get batchPrivateProfilesBody =>
      'Подключите аккаунт. Instagram также запрашивает имя пользователя и пароль.';

  @override
  String get batchUseAnotherLinkAction => 'Другая ссылка';

  @override
  String get batchSignInNeededTitle => 'Требуется вход';

  @override
  String get batchEnterYourCodeTitle => 'Введите код';

  @override
  String get batchUseUsernamePasswordAction => 'Войти по имени и паролю';

  @override
  String get batchAlreadyConnectedAction => 'Я уже вошел в браузере';

  @override
  String get batchEnterCodeAction => 'Ввести код';

  @override
  String get batchTryAnotherWayAction => 'Другой способ';

  @override
  String get batchLiveStatus => 'В сети';

  @override
  String get batchReconnectingStatus => 'Переподключение';

  @override
  String get batchSignInToInstagramTitle => 'Вход в Instagram';

  @override
  String get batchUsernameLabel => 'Имя пользователя';

  @override
  String get batchCodeIfTwoStepLabel => 'Код при двухэтапной проверке';

  @override
  String get batchAuthenticatorCodeBody =>
      'Введите 6-значный код из приложения аутентификации. Коды быстро меняются.';

  @override
  String get batchVerifyAction => 'Подтвердить';

  @override
  String get batchFindingPhotosTitle => 'Поиск фото';

  @override
  String get batchImportPausedTitle => 'Импорт приостановлен';

  @override
  String get batchProcessingPhotosTitle => 'Обработка фото';

  @override
  String get batchWaitingNextPhoto => 'Ожидание следующего фото';

  @override
  String get batchCancelImportAction => 'Отменить импорт';

  @override
  String get batchNoPiecesInPhotoBody => 'На этом фото вещи не найдены.';

  @override
  String get batchEditPieceColoursLabel => 'Цвета через запятую';

  @override
  String get batchAddToClosetAction => 'В гардероб';

  @override
  String get batchSkipPhotoAction => 'Пропустить фото';

  @override
  String get batchImportCompleteTitle => 'Импорт завершен';

  @override
  String get batchImportFailedTitle => 'Ошибка импорта';

  @override
  String get batchImportCancelledTitle => 'Импорт отменен';

  @override
  String get batchImportErrorBody => 'Что-то пошло не так при импорте.';

  @override
  String get batchNothingMoreImportedBody =>
      'Из этого профиля больше ничего не импортировано.';

  @override
  String get batchViewClosetAction => 'Открыть гардероб';

  @override
  String get batchStartOverAction => 'Начать сначала';

  @override
  String get wardrobeAddPieceTitle => 'Добавить вещь';

  @override
  String get wardrobeAddDetailsTitle => 'Добавить детали';

  @override
  String get wardrobeScanningTitle => 'Сканирование';

  @override
  String get batchReviewPiecesTitle => 'Просмотр вещей';

  @override
  String get wardrobeGalleryAction => 'Галерея';

  @override
  String get wardrobeCameraAction => 'Камера';

  @override
  String get wardrobeNewBadge => 'Новое';

  @override
  String get wardrobeRemovePhotoTooltip => 'Удалить фото';

  @override
  String get batchRunInBackgroundTooltip => 'В фоновом режиме';

  @override
  String get batchStepOneOfTwo => 'Шаг 1 из 2';

  @override
  String get batchStepTwoOfTwo => 'Шаг 2 из 2';

  @override
  String get batchUploadingPhotosTitle => 'Загрузка фото';

  @override
  String get batchFindingPiecesTitle => 'Поиск вещей';

  @override
  String get batchMakingStudioPhotosTitle => 'Создание студийных фото';

  @override
  String get batchStoppedLabel => 'Остановлено';

  @override
  String get batchFindingPiecesStoppedTitle => 'Поиск вещей остановлен';

  @override
  String get batchCancelledLabel => 'Отменено';

  @override
  String get batchAllDoneTitle => 'Готово';

  @override
  String get batchOpeningPiecesBody => 'Открытие ваших вещей';

  @override
  String get batchNothingSavedBody => 'Ничего не сохранено.';

  @override
  String get batchFindingPiecesFailedBody => 'Не удалось найти вещи.';

  @override
  String get batchFindingPiecesStoppedEarlyBody => 'Поиск вещей был прерван.';

  @override
  String get batchStopFindingPiecesTitle => 'Остановить поиск вещей?';

  @override
  String get batchStopFindingPiecesBody =>
      'Сканирование остановится, ничто не будет сохранено. Найденные вещи останутся в истории, пока вы их не скроете.';

  @override
  String get batchKeepGoingAction => 'Продолжить';

  @override
  String get batchTryAgainAction => 'Повторить';

  @override
  String get batchBackToPhotosAction => 'Назад к фото';

  @override
  String get batchSkipAllAction => 'Пропустить все';

  @override
  String get batchIncludeAllAction => 'Включить все';

  @override
  String get batchNoPiecesFoundTitle => 'Вещи не найдены';

  @override
  String get batchNoPiecesFoundBody => 'На этих фото нет одежды.';

  @override
  String get batchChooseOtherPhotosAction => 'Выбрать другие фото';

  @override
  String get batchUseCaseHelper => 'Добавляется к каждой сохраненной вещи.';

  @override
  String get batchDiscardPiecesTitle => 'Удалить эти вещи?';

  @override
  String get batchDiscardPiecesBody => 'Ничего из этой подборки не сохранено.';

  @override
  String get batchKeepAction => 'Оставить';

  @override
  String get batchDiscardAction => 'Удалить';

  @override
  String get batchRemovePieceTitle => 'Удалить эту вещь?';

  @override
  String get batchRemovePieceBody => 'Она не сохранена в вашем гардеробе.';

  @override
  String get batchRemoveAction => 'Удалить';

  @override
  String get batchChoosePiecesToSave => 'Выберите вещи для сохранения';

  @override
  String get batchDiscardAllAction => 'Удалить все';

  @override
  String get batchNothingSavedRetryBody =>
      'Ничего не сохранено. Попробуйте еще раз.';

  @override
  String get batchNotSavedTitle => 'Не сохранено';

  @override
  String get batchSavingLabel => 'Сохранение';

  @override
  String get batchSendToBackgroundAction => 'В фоновый режим';

  @override
  String get batchStillWorkingMessage =>
      'Обработка продолжается. Мы сообщим, когда вещи будут готовы.';

  @override
  String get batchRunningInBackgroundTitle => 'Работа в фоне';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Создание студийных фото остановлено. Вы все равно можете сохранить эти вещи.';

  @override
  String get batchTapPieceToSkip => 'Нажмите на вещь, чтобы пропустить.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Студийные фото еще создаются. Вы можете выйти — мы пришлем уведомление.';

  @override
  String get batchLeaveAction => 'Выйти';

  @override
  String get batchPeopleInPhotosTitle => 'Люди на фото';

  @override
  String get batchIncludeAction => 'Включить';

  @override
  String get batchSkipAction => 'Пропустить';

  @override
  String get batchYourPhotoIsUsedLabel => 'Используется ваше фото';

  @override
  String get batchMakingStudioPhotoLabel => 'Создание студийного фото';

  @override
  String get batchNoStudioPhotoBody =>
      'Нет студийного фото. Используется ваше фото.';

  @override
  String get batchEnterDetailsYourselfAction => 'Ввести данные вручную';

  @override
  String get batchChooseAnotherPhotoAction => 'Выбрать другое фото';

  @override
  String get batchConnectionLostTitle => 'Нет соединения';

  @override
  String get batchConnectionLostBody =>
      'Проверьте подключение и повторите попытку.';

  @override
  String get batchDailyLimitTitle => 'Лимит исчерпан';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Перейдите на Pro для увеличения лимита или введите данные вручную.';

  @override
  String get batchDailyLimitBodyFree =>
      'Лимит обновится завтра. Вы можете ввести данные вручную.';

  @override
  String get batchSeePlansAction => 'Посмотреть планы';

  @override
  String get batchAiBusyTitle => 'ИИ занят';

  @override
  String get batchAiBusyBody =>
      'Это временная неполадка на нашей стороне. Попробуйте через пару минут.';

  @override
  String get batchNoPiecesBody =>
      'Попробуйте более четкое фото или введите данные вручную.';

  @override
  String get batchScanningUnavailableTitle => 'Сканирование недоступно';

  @override
  String get batchScanningUnavailableBody => 'Пока введите данные вручную.';

  @override
  String get batchScanDidNotFinishTitle => 'Сканирование не завершено';

  @override
  String get batchTryAgainBody => 'Попробуйте снова.';

  @override
  String get billingTitle => 'Подписка';

  @override
  String get billingUpgradeHeading => 'Улучшить план';

  @override
  String get billingUpgradeOnPlusBody => 'Те же функции, выше лимиты.';

  @override
  String get billingUpgradeBody =>
      'Планы Plus и Pro имеют одинаковые функции. Выберите нужные лимиты.';

  @override
  String get billingWebUnavailableBody =>
      'Онлайн-покупка пока недоступна. Промокод или реферальный код разблокирует Plus или Pro. Приглашайте друзей, чтобы получить месяцы бесплатно.';

  @override
  String get billingPlansStale =>
      'Не удалось загрузить актуальные планы. Цены могут устареть.';

  @override
  String get billingMonthly => 'Ежемесячно';

  @override
  String get billingYearly => 'Ежегодно';

  @override
  String get billingCurrentPlan => 'Текущий план';

  @override
  String get billingActive => 'Активно';

  @override
  String get billingThisMonth => 'В этом месяце';

  @override
  String get billingItemExtractions => 'Распознанные вещи';

  @override
  String get billingOutfitVisualizations => 'Визуализации образов';

  @override
  String get billingNearLimitUpgrade =>
      'Вы близки к лимиту этого месяца. Улучшите план для увеличения.';

  @override
  String get billingNearLimitResets =>
      'Вы близки к лимиту этого месяца. Он обновится в начале следующего.';

  @override
  String get billingStoreUnavailable =>
      'Покупки в магазине пока недоступны. Загляните позже.';

  @override
  String get billingManageHeading => 'Управление подпиской';

  @override
  String get billingCancelPlan => 'Отменить подписку';

  @override
  String get billingCancelKeepsAccess =>
      'Доступ сохранится до конца текущего расчетного периода.';

  @override
  String get billingCancelConfirmTitle => 'Отменить подписку?';

  @override
  String get billingKeepPlan => 'Оставить план';

  @override
  String get billingCancelPlanAction => 'Отменить план';

  @override
  String get billingBilledMonthly => 'Оплата ежемесячно';

  @override
  String get billingBilledYearly => 'Оплата ежегодно';

  @override
  String get billingVirtualTryOn => 'Виртуальная примерка';

  @override
  String get billingPrioritySupport => 'Приоритетная поддержка';

  @override
  String get billingDisclosureProRenewing =>
      'Pro — это подписка с автопродлением';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus и Pro — это подписки с автопродлением';

  @override
  String get billingDisclosureAppleBilling =>
      'Оплата будет списана с вашего Apple ID при подтверждении покупки.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Оплата будет списана с вашего аккаунта Google Play при подтверждении покупки.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Подписка продлевается автоматически на тот же период по той же цене, если вы не отключите автопродление не менее чем за 24 часа до окончания текущего периода.';

  @override
  String get billingDisclosureAppleManage =>
      'Управляйте подпиской или отменяйте ее в Настройки › ваш Apple ID › Подписки.';

  @override
  String get billingDisclosureGoogleManage =>
      'Управляйте подпиской или отменяйте ее в Google Play › Платежи и подписки.';

  @override
  String get billingReferFriend => 'Пригласить друга';

  @override
  String get billingHowItWorks => 'Как это работает';

  @override
  String get billingHowShareTitle => 'Поделитесь ссылкой';

  @override
  String get billingHowShareBody => 'Отправьте ее другу.';

  @override
  String get billingHowSignUpTitle => 'Друг регистрируется';

  @override
  String get billingHowSignUpBody => 'Ваш друг присоединяется по ссылке.';

  @override
  String get billingHowBothTitle => 'Вы оба получаете Pro';

  @override
  String get billingHowBothBody =>
      'Каждый из вас получает месяц Pro бесплатно.';

  @override
  String get billingYourReferrals => 'Ваши приглашения';

  @override
  String get billingInvited => 'Приглашен';

  @override
  String get billingJoined => 'Присоединился';

  @override
  String get billingMonthsEarned => 'Получено месяцев';

  @override
  String get billingInviteFriend => 'Пригласить друга';

  @override
  String get billingInviteBody =>
      'Вы и ваш друг получите по месяцу подписки Pro.';

  @override
  String get billingYourCode => 'Ваш код';

  @override
  String get billingCopyLink => 'Скопировать ссылку';

  @override
  String get billingShareInvite => 'Поделиться';

  @override
  String get giftUnavailable =>
      'Подарочные приглашения недоступны в этой версии.';

  @override
  String get giftPageTitle => 'Подарить FitCheck Pro';

  @override
  String get giftNoAllowances => 'Сейчас нет доступных бесплатных приглашений.';

  @override
  String get giftFormTitle => 'Отправить бесплатное приглашение';

  @override
  String get giftFormBody =>
      'Получатель активирует подарок с помощью этого проверенного email. Мы не отправляем письмо за вас.';

  @override
  String get giftFieldFrom => 'От кого';

  @override
  String get giftFieldRecipientName => 'Имя получателя';

  @override
  String get giftFieldRecipientEmail => 'Email получателя';

  @override
  String get giftFieldOccasion => 'Повод (необязательно)';

  @override
  String get giftNoOccasion => 'Без повода';

  @override
  String get giftOccasionBirthday => 'День рождения';

  @override
  String get giftOccasionAnniversary => 'Годовщина';

  @override
  String get giftOccasionOther => 'Другое';

  @override
  String get giftFieldCardGreeting => 'Текст поздравления';

  @override
  String get giftFieldCardGreetingHelper =>
      'Появится на открытке в точности так, как написано.';

  @override
  String get giftFieldPrivateNote => 'Личная заметка (необязательно)';

  @override
  String get giftCreateAction => 'Создать подарок';

  @override
  String get giftClaimedTitle => 'Подарок активирован';

  @override
  String get giftClaimedActive => 'Ваш подарок FitCheck Pro активен.';

  @override
  String get giftClaimedQueued =>
      'Ваш подарок FitCheck Pro начнется после окончания текущей подписки.';

  @override
  String get giftLinkCopied => 'Ссылка скопирована в буфер обмена.';

  @override
  String get giftErrorName => 'Введите имя.';

  @override
  String get giftErrorEmail => 'Введите корректный email.';

  @override
  String get giftErrorGreeting => 'Введите текст поздравления.';

  @override
  String get giftErrorGreetingLength => 'Не более 80 символов.';

  @override
  String get giftClaimAction => 'Получить подарок';

  @override
  String get giftCardPreview => 'Предпросмотр открытки';

  @override
  String get giftGiftForYou => 'Подарок для вас';

  @override
  String get giftGiftWaiting => 'Вас ждет подарок';

  @override
  String get giftOpenBody =>
      'Откройте подарки и подтвердите их по электронной почте.';

  @override
  String get giftOpenGifts => 'Открыть подарки';

  @override
  String get giftSendInvitation => 'Отправить приглашение';

  @override
  String get settingsAiProviderSection => 'Провайдер';

  @override
  String get settingsAiCustom => 'Свой';

  @override
  String get settingsAiUrlHelper =>
      'Используйте публичный URL, доступный с сервера. Локальный адрес не подойдет.';

  @override
  String get settingsAiConnectionSection => 'Подключение';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'Ключ API';

  @override
  String get settingsAiApiKeySaved =>
      'Сохранено. Оставьте пустым, чтобы не менять.';

  @override
  String get settingsAiChatModel => 'Модель чата';

  @override
  String get settingsAiVisionModel => 'Модель зрения (опционально)';

  @override
  String get settingsAiImageModel => 'Модель изображений (опционально)';

  @override
  String get settingsAiImageModelNote =>
      'Для генерации нужен чат OpenAI с response_modalities.';

  @override
  String get settingsAiTestConnection => 'Проверить связь';

  @override
  String get calendarTitle => 'Календарь';

  @override
  String get calendarGoToToday => 'Сегодня';

  @override
  String get calendarConnectTooltip => 'Подключить календарь';

  @override
  String get calendarAddEvent => 'Добавить событие';

  @override
  String get calendarEmptyTitle => 'Планы отсутствуют';

  @override
  String get calendarEmptyBody => 'Добавьте событие и спланируйте образ.';

  @override
  String get calendarPreviousMonth => 'Прошлый месяц';

  @override
  String get calendarNextMonth => 'Следующий месяц';

  @override
  String get calendarAllDay => 'Весь день';

  @override
  String get calendarOutfitLinked => 'Образ привязан';

  @override
  String get calendarEventOptions => 'Параметры события';

  @override
  String get calendarDeleteTitle => 'Удалить событие?';

  @override
  String get calendarChangeOutfit => 'Изменить образ';

  @override
  String get calendarLinkOutfit => 'Привязать образ';

  @override
  String get calendarRemoveOutfit => 'Убрать образ';

  @override
  String get calendarNewEvent => 'Новое событие';

  @override
  String get calendarEditEvent => 'Изменить событие';

  @override
  String get calendarTitleLabel => 'Название';

  @override
  String get calendarTitleRequired => 'Добавьте название';

  @override
  String get calendarEndBeforeStart => 'Конец позже начала';

  @override
  String get calendarStarts => 'Начало';

  @override
  String get calendarEnds => 'Конец';

  @override
  String get calendarPlaceOptional => 'Место (необязательно)';

  @override
  String get calendarNotesOptional => 'Заметки (необязательно)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Соберите образ, затем привяжите его к событию.';

  @override
  String get calendarBuildOutfit => 'Собрать образ';

  @override
  String get calendarConnectionsTitle => 'Календари';

  @override
  String get calendarConnectionsBody =>
      'Добавленные здесь события остаются в FitCheck.';

  @override
  String get calendarDisconnect => 'Отключить';

  @override
  String get calendarNotAvailable => 'Пока недоступно';

  @override
  String get profileSectionExplore => 'Обзор';

  @override
  String get profileNavTryOn => 'Примерка';

  @override
  String get profileNavRewards => 'Бонусы';

  @override
  String get profileSupport => 'Поддержка';

  @override
  String get profileHelp => 'Помощь';

  @override
  String get profileAbout => 'О приложении';

  @override
  String get profileAboutBody => 'Ваш гардероб, образы и планы в одном месте.';

  @override
  String get profileSignOutTitle => 'Выйти?';

  @override
  String get profileSignOutBody => 'Вы сможете войти снова в любое время.';

  @override
  String get profileEditTitle => 'Редактировать профиль';

  @override
  String get profileYourProfile => 'Ваш профиль';

  @override
  String get profileBodyProfiles => 'Профили тела';

  @override
  String get profileBodyEmptyTitle => 'Нет профилей тела';

  @override
  String get profileBodyEmptyBody =>
      'Укажите рост и телосложение для точного подбора.';

  @override
  String get profileBodyAdd => 'Добавить профиль';

  @override
  String get profileBodyDefaultNote =>
      'Основной профиль используется для примерки и подбора.';

  @override
  String get profileBodyDefaultBadge => 'Основной';

  @override
  String get profileBodyMakeDefault => 'Сделать основным';

  @override
  String get profileBodyDeleteBody => 'Это действие нельзя отменить.';

  @override
  String get profileBodyRequired => 'Обязательно';

  @override
  String get profileBodyCheckNumber => 'Проверьте число';

  @override
  String get profileBodyNew => 'Новый профиль тела';

  @override
  String get profileBodyNameHint => 'Например, Я';

  @override
  String get profileBodyHeight => 'Рост';

  @override
  String get profileBodyWeight => 'Вес';

  @override
  String get profileBodyBuild => 'Телосложение';

  @override
  String get profileBodySkinTone => 'Тон кожи';

  @override
  String get profileBirthDateNeededBody =>
      'Укажите дату рождения для указанного времени.';

  @override
  String get profileBirthDateNeededTitle => 'Требуется дата рождения';

  @override
  String get profilePartlySavedBody =>
      'Имя и фото сохранены. Данные о рождении не сохранились, попробуйте позже.';

  @override
  String get profilePartlySavedTitle => 'Сохранено частично';

  @override
  String get profileSavedBody => 'Профиль сохранен.';

  @override
  String get profileChangePhoto => 'Изменить фото';

  @override
  String get profilePhotoLabel => 'Фото профиля';

  @override
  String get profilePhotoHint => 'Нажмите, чтобы выбрать новое';

  @override
  String get profileBirthDateLabel => 'Дата рождения (необязательно)';

  @override
  String get profileBirthTimeLabel => 'Время рождения (необязательно)';

  @override
  String get profileBirthTimeHelper => 'Делает ведические рекомендации точнее';

  @override
  String get profileBirthPlaceLabel => 'Место рождения (необязательно)';

  @override
  String get profileBirthPlaceHint => 'Например, Москва, Россия';

  @override
  String get profileHelpContactTitle => 'Задать вопрос';

  @override
  String get profileHelpContactBody =>
      'Напишите нам, и мы ответим на email, обычно в течение дня.';

  @override
  String get profileHelpContactAction => 'Служба поддержки';

  @override
  String get profileHelpFaqTitle => 'Частые вопросы';

  @override
  String get profileFaqAddPiecesTitle => 'Как добавить вещи в гардероб?';

  @override
  String get profileFaqAddPiecesBody =>
      'Нажмите «Добавить» на вкладке Гардероб. Сделайте фото или выберите из галереи — мы распознаем вещь и добавим теги.';

  @override
  String get profileFaqMatchingTitle => 'Как подбираются образы?';

  @override
  String get profileFaqMatchingBody =>
      'Откройте раздел Для вас и выберите свои вещи. Мы подскажем, с чем их носить, и соберем готовые образы.';

  @override
  String get profileFaqTryOnTitle => 'Можно ли примерять на свои фото?';

  @override
  String get profileFaqTryOnBody =>
      'Да. Загрузите свое фото в полный рост, затем выберите вещи, чтобы примерить их.';

  @override
  String get profileFaqRewardsTitle => 'Как получать награды?';

  @override
  String get profileFaqRewardsBody =>
      'Планируйте образы и отмечайте их. Серии и достижения будут расти по мере использования.';

  @override
  String get profileFaqPrivacyTitle => 'Мой гардероб приватный?';

  @override
  String get profileFaqPrivacyBody =>
      'Да. Ваш гардероб и образы видны только вам, если вы не поделитесь ссылкой на конкретный образ.';

  @override
  String get profileHelpMoreTitle => 'Другая помощь';

  @override
  String get profileHelpGuides => 'Руководства';

  @override
  String get profileHelpGuidesBody => 'Как работают функции';

  @override
  String get feedbackCategoryBug => 'Что-то сломалось';

  @override
  String get feedbackCategoryIdea => 'Идея';

  @override
  String get feedbackCategoryGeneral => 'Общее';

  @override
  String get feedbackCategoryHelp => 'Нужна помощь';

  @override
  String get feedbackHintBug =>
      'Что произошло и как должно быть? Шаги помогут нам исправить ошибку.';

  @override
  String get feedbackHintIdea => 'Что бы вы хотели изменить и почему?';

  @override
  String get feedbackHintGeneral => 'Поделитесь мнением или задайте вопрос.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Можно прикрепить до 5 изображений.';

  @override
  String get feedbackAttachmentLimitTitle => 'Лимит исчерпан';

  @override
  String get feedbackImageTooLargeBody =>
      'Выберите изображение размером до 5 МБ.';

  @override
  String get feedbackImageTooLargeTitle => 'Слишком большой файл';

  @override
  String get feedbackTitle => 'Отправить отзыв';

  @override
  String get feedbackAboutLabel => 'О чем речь?';

  @override
  String get feedbackSubjectLabel => 'Тема';

  @override
  String get feedbackSubjectRequired => 'Укажите тему';

  @override
  String get feedbackSubjectTooShort =>
      'Тема должна содержать не менее 3 символов';

  @override
  String get feedbackDetailsLabel => 'Подробности';

  @override
  String get feedbackDetailsRequired => 'Добавьте подробности';

  @override
  String get feedbackDetailsTooShort =>
      'Описание должно содержать не менее 10 символов';

  @override
  String get feedbackAddScreenshot => 'Добавить скриншот';

  @override
  String get feedbackAttachmentHint => 'До 5 файлов, до 5 МБ каждый';

  @override
  String get feedbackSend => 'Отправить';

  @override
  String get feedbackEmptyTitle => 'Пока ничего не отправлено';

  @override
  String get feedbackEmptyBody =>
      'Отправленные вами сообщения и их статусы появятся здесь.';

  @override
  String get feedbackHistoryTitle => 'Отправленные';

  @override
  String get feedbackStatusOpen => 'Открыто';

  @override
  String get feedbackStatusInProgress => 'В работе';

  @override
  String get feedbackStatusResolved => 'Решено';

  @override
  String get feedbackStatusClosed => 'Закрыто';

  @override
  String get legalIntro =>
      'Как мы защищаем ваши данные и условия использования FitCheck AI.';

  @override
  String get legalPolicies => 'Политики';

  @override
  String get legalPrivacySubtitle => 'Что и зачем мы собираем';

  @override
  String get legalTermsTitle => 'Условия обслуживания';

  @override
  String get legalTermsSubtitle => 'Правила использования приложения';

  @override
  String get legalLicences => 'Лицензии ПО';

  @override
  String get legalSupportSubtitle => 'Помощь, связь и запросы по данным';

  @override
  String get legalReportAbuse => 'Сообщить о проблеме';

  @override
  String get permissionCameraTitle => 'Доступ к камере';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI использует камеру для съемки одежды и образов для виртуальной примерки и каталога.';

  @override
  String get permissionPhotoTitle => 'Доступ к фото';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI нужен доступ к фото, чтобы вы могли выбирать снимки одежды для гардероба и функций ИИ.';

  @override
  String get permissionNotNow => 'Не сейчас';

  @override
  String get permissionOpenSettings => 'Открыть настройки';

  @override
  String authSignedInAs(String name) {
    return 'Вход выполнен как $name';
  }

  @override
  String get authSignedIn => 'Вход выполнен';

  @override
  String get authWelcomeBackTitle => 'С возвращением';

  @override
  String get authSignInFailed => 'Ошибка входа';

  @override
  String get authWelcomeTitle => 'Добро пожаловать';

  @override
  String get authSignUpFailed => 'Ошибка регистрации';

  @override
  String get authGoogleSignInFailed => 'Ошибка входа через Google';

  @override
  String get authAppleSignInFailed => 'Ошибка входа через Apple';

  @override
  String get authConfirmEmailTitle => 'Подтвердите email';

  @override
  String get authConfirmEmailBody =>
      'Проверьте почту, перейдите по ссылке для подтверждения и войдите.';

  @override
  String get authClosetReady => 'Ваш гардероб готов.';

  @override
  String get authSignedOutTitle => 'Выход выполнен';

  @override
  String get authSignedOutBody => 'Вы вышли из аккаунта.';

  @override
  String get authSignOutFailed => 'Ошибка выхода';

  @override
  String get authEmailSentTitle => 'Письмо отправлено';

  @override
  String get authResetLinkSent =>
      'Проверьте почту, мы отправили ссылку для сброса.';

  @override
  String get authPasswordUpdatedTitle => 'Пароль изменен';

  @override
  String get authPasswordUpdated => 'Ваш пароль успешно изменен.';

  @override
  String get authPasswordNotUpdated => 'Пароль не изменен';

  @override
  String get authCouldNotSendEmail => 'Не удалось отправить письмо';

  @override
  String get authEmailNotSent => 'Письмо не отправлено';

  @override
  String get authResendSentBody =>
      'Мы отправили новое письмо для подтверждения.';

  @override
  String get outfitPreviewWithAi => 'Предпросмотр с ИИ';

  @override
  String get outfitNewPreview => 'Новый предпросмотр';

  @override
  String get outfitBuilderClosetHeading => 'Ваш гардероб';

  @override
  String get outfitBuilderSearchHint => 'Поиск вещей';

  @override
  String get outfitClearSearch => 'Сбросить поиск';

  @override
  String get outfitBuilderAddPiecesTitle => 'Сначала добавьте вещи';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Аутфиты создаются из вещей в гардеробе.';

  @override
  String get outfitBuilderNoMatches => 'Вещи не найдены.';

  @override
  String get outfitNameLabel => 'Название аутфита';

  @override
  String get outfitNameHint => 'Например, Летний лен';

  @override
  String get outfitPreviewSemantic => 'Предпросмотр аутфита с ИИ';

  @override
  String get outfitChoosePieces => 'Выбор вещей';

  @override
  String get outfitTapPiecesHint => 'Нажмите на вещи ниже, чтобы добавить.';

  @override
  String get outfitShareTooltip => 'Поделиться';

  @override
  String get outfitSaveFavourite => 'В избранное';

  @override
  String get outfitPiecesHeading => 'Вещи';

  @override
  String get outfitWearHistoryEmpty =>
      'Наденьте один раз, и даты появятся здесь.';

  @override
  String get outfitWearHistoryTitle => 'История носки';

  @override
  String get outfitWearHistoryError => 'Не удалось загрузить даты.';

  @override
  String get outfitWornOn => 'Несено';

  @override
  String get outfitEditTitle => 'Редактировать аутфит';

  @override
  String get outfitSavedPhotosFailed => 'Детали сохранены, фото — нет';

  @override
  String get outfitNoPhotosBody => 'Фото пока нет. Показаны вещи аутфита.';

  @override
  String get outfitOccasionLabel => 'Повод';

  @override
  String get outfitOccasionNone => 'Нет';

  @override
  String get outfitTagsHint => 'Разделяйте запятыми';

  @override
  String get outfitDraftBody => 'Скрыто из общего списка';

  @override
  String get outfitPublic => 'Публичный';

  @override
  String get outfitPublicBody => 'Любой с ссылкой увидит аутфит';

  @override
  String get outfitDeleteFromDetail => 'Удалить этот образ со страницы деталей';

  @override
  String get outfitNewCollection => 'Новая коллекция';

  @override
  String get outfitNoCollectionsTitle => 'Коллекций пока нет';

  @override
  String get outfitNoCollectionsBody =>
      'Группируйте образы по поездкам, сезонам или настроению';

  @override
  String get outfitCreateCollection => 'Создать коллекцию';

  @override
  String get outfitAddOutfits => 'Добавить образы';

  @override
  String get outfitRename => 'Переименовать';

  @override
  String get outfitCollectionDeleteBody => 'Образы из неё сохранятся';

  @override
  String get outfitCollectionsNotLoaded => 'Образы не загружены';

  @override
  String get outfitRenameCollection => 'Переименовать коллекцию';

  @override
  String get outfitDescriptionOptional => 'Описание (необязательно)';

  @override
  String get outfitAllInCollection => 'Все образы уже в этой коллекции';

  @override
  String get photoshootSubtitleUpload => 'Студийные портреты по вашим фото';

  @override
  String get photoshootSubtitleConfigure =>
      'Выберите стиль, формат и количество';

  @override
  String get photoshootSubtitleGenerating => 'Это займёт одну-две минуты';

  @override
  String get photoshootAddPhotosSemantic => 'Добавить фото из галереи';

  @override
  String get photoshootUploadTitle => 'Добавьте 1–4 фото себя';

  @override
  String get photoshootUploadBody => 'Нажмите, чтобы выбрать из галереи';

  @override
  String get photoshootAddToContinue => 'Добавьте фото, чтобы продолжить';

  @override
  String get photoshootAddAnotherPhoto => 'Добавить ещё фото';

  @override
  String get photoshootTipsTitle => 'Для лучшего результата';

  @override
  String get photoshootTipsBody =>
      'Используйте чёткие, хорошо освещённые фото лица под разными углами. Без очков и головных уборов';

  @override
  String get photoshootStarting => 'Запуск';

  @override
  String get photoshootCancelling => 'Отмена';

  @override
  String get photoshootFailed => 'Ошибка';

  @override
  String get recommendTabMatches => 'Подходит';

  @override
  String get recommendTabComplete => 'Комплект';

  @override
  String get recommendTabWeather => 'Погода';

  @override
  String get recommendTabColours => 'Цвета';

  @override
  String get recommendTabShop => 'Магазин';

  @override
  String get recommendNoMatchesTitle => 'Совпадений пока нет';

  @override
  String get recommendNoMatchesBody =>
      'Выберите вещь — найдём, с чем она сочетается.';

  @override
  String get recommendPickPiece => 'Выбрать вещь';

  @override
  String get recommendNothingMatchesTitle => 'Совпадений нет';

  @override
  String get recommendNothingMatchesBody =>
      'Попробуйте другие вещи или пополните гардероб.';

  @override
  String get recommendChangePieces => 'Сменить вещи';

  @override
  String get recommendDefaultReason => 'Подошло к выбранным вещам.';

  @override
  String get recommendCompleteTitle => 'Собрать образ';

  @override
  String get recommendCompleteBody => 'Выберите вещь — дополним остальным.';

  @override
  String get recommendWorking => 'Обработка';

  @override
  String get recommendGenerate => 'Создать';

  @override
  String get recommendChooseStyleBody => 'Выберите стиль и создайте образ.';

  @override
  String get recommendNoLooksTitle => 'Нет образов для этих вещей';

  @override
  String get recommendNoLooksBody => 'Попробуйте другой стиль или другие вещи.';

  @override
  String get recommendDefaultLook => 'Образ для ваших вещей';

  @override
  String get recommendNoPiecesBody => 'Для этого образа нет вещей.';

  @override
  String get recommendCityLabel => 'Город';

  @override
  String get recommendCheck => 'Проверить';

  @override
  String get recommendWeatherTitle => 'Погода';

  @override
  String get recommendWeatherBody =>
      'Укажите город, чтобы получить подборку на сегодня.';

  @override
  String get recommendWearToday => 'На сегодня';

  @override
  String get recommendWeatherNoPieces =>
      'В гардеробе нет вещей для такой погоды.';

  @override
  String get recommendBudgetLabel => 'Бюджет до';

  @override
  String get recommendLooking => 'Поиск';

  @override
  String get recommendFindWhatToBuy => 'Подобрать покупки';

  @override
  String get recommendFillGapsTitle => 'Заполнить пробелы';

  @override
  String get recommendFillGapsBody =>
      'Задайте бюджет — подскажем, чего не хватает в гардеробе.';

  @override
  String get recommendNoGapsTitle => 'Пробелов не найдено';

  @override
  String get recommendNoGapsBody =>
      'Увеличьте бюджет или выберите другую категорию.';

  @override
  String get recommendMoodEveryday => 'На каждый день';

  @override
  String get recommendMoodBigMeeting => 'Большая встреча';

  @override
  String get recommendDayLabel => 'День';

  @override
  String get recommendReadingStars => 'Чтение звёзд';

  @override
  String get recommendGetMyColours => 'Получить мои цвета';

  @override
  String get recommendLuckyColoursTitle => 'Ваши счастливые цвета';

  @override
  String get recommendLuckyColoursBody =>
      'Выберите день, и мы подскажем цвета и вещи.';

  @override
  String get recommendLuckyColoursSection => 'Счастливые цвета';

  @override
  String get recommendAvoidColoursSection => 'Цвета, которых лучше избегать';

  @override
  String get recommendBirthDateTitle => 'Добавьте дату рождения';

  @override
  String get recommendBirthDateBody =>
      'Для анализа цветов нужна дата рождения.';

  @override
  String get recommendEditProfile => 'Изменить профиль';

  @override
  String get recommendNothingThisDay => 'Ничего на этот день.';

  @override
  String get recommendUnnamedColour => 'Без названия';

  @override
  String get recommendFromCloset => 'Из вашего гардероба';

  @override
  String get recommendNoPiecesInColours => 'Пока нет вещей этих цветов.';

  @override
  String get recommendOutfitIdeas => 'Идеи образов';

  @override
  String get recommendNoOutfitsInColours =>
      'Пока нет полного образа этих цветов.';

  @override
  String get recommendDefaultOutfitIdea => 'Идея образа';

  @override
  String get recommendPickUpToThree => 'Выберите до трёх вещей';

  @override
  String get recommendEmptyClosetBody =>
      'Сначала добавьте вещи, затем ищите сочетания.';

  @override
  String get dashboardDressForDay => 'Подберите наряд на день вперёд.';

  @override
  String get dashboardOutfitOfDay => 'Образ дня';

  @override
  String get dashboardFreshLook => 'Новый образ';

  @override
  String get subscriptionManageInStoreTitle => 'Управление в магазине';

  @override
  String get subscriptionManageInStoreBody =>
      'Этот план списывается через магазин. Настройте его в настройках аккаунта магазина.';

  @override
  String get subscriptionCancelledTitle => 'Подписка отменена';

  @override
  String get subscriptionCancelledBody =>
      'Ваш план будет активен до конца текущего расчётного периода.';

  @override
  String get subscriptionCancelFailedTitle => 'Не удалось отменить';

  @override
  String get subscriptionCouldNotOpenTitle => 'Не удалось открыть';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Не удалось открыть управление биллингом.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Не удалось открыть ссылку.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Не удалось загрузить вашу ссылку';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Не удалось загрузить вашу реферальную ссылку. Попробуйте ещё раз.';

  @override
  String get subscriptionReferralCopiedTitle => 'Скопировано';

  @override
  String get subscriptionReferralCopiedBody =>
      'Реферальная ссылка скопирована.';

  @override
  String get subscriptionReferralShareSubject => 'Попробуйте FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Присоединяйтесь к FitCheck AI, и мы оба получим месяц Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Ссылка скопирована';

  @override
  String get subscriptionShareUnavailableBody =>
      'Поделиться недоступно, поэтому ссылка скопирована.';

  @override
  String get subscriptionShareFailedTitle => 'Не удалось поделиться';

  @override
  String get subscriptionShareFailedBody =>
      'Скопируйте ссылку со страницы реферальной программы.';

  @override
  String get subscriptionStoreReadyTitle => 'Магазин готов';

  @override
  String get subscriptionStoreReadyBody =>
      'Цены в магазине доступны. Вы можете обновить тариф сейчас.';

  @override
  String get purchaseFailedTitle => 'Ошибка покупки';

  @override
  String get purchaseUnavailableTitle => 'Покупка недоступна';

  @override
  String get purchaseIapUnavailableBody =>
      'Покупки в приложении недоступны на этом устройстве.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Этот тариф ещё не доступен для покупки.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Этот тариф ещё не доступен в магазине. Загляните позже.';

  @override
  String get purchaseStartFailedBody =>
      'Не удалось начать покупку. Попробуйте ещё раз.';

  @override
  String get purchaseNoPaymentLinkBody => 'Касса не вернула ссылку для оплаты.';

  @override
  String get purchasePendingTitle => 'Покупка в ожидании';

  @override
  String get purchasePendingBody =>
      'Ваша покупка ожидает подтверждения. Доступ будет открыт сразу после одобрения.';

  @override
  String get purchaseFailedBody => 'Покупка не удалась. Попробуйте ещё раз.';

  @override
  String get purchaseRestoredTitle => 'Восстановлено';

  @override
  String get purchaseRestoredBody => 'Ваши покупки восстановлены.';

  @override
  String get purchaseActiveTitle => 'Подписка активна';

  @override
  String get purchaseActiveBody => 'Ваша подписка активна. Добро пожаловать.';

  @override
  String get purchaseSignInRequiredTitle => 'Требуется вход';

  @override
  String get purchaseSignInRequiredBody => 'Войдите, чтобы завершить покупку.';

  @override
  String get purchaseErrorTitle => 'Ошибка покупки';

  @override
  String get purchaseInvalidTransactionBody =>
      'Покупка не содержит проверяемого идентификатора транзакции.';

  @override
  String get purchaseVerificationPendingTitle => 'Проверка завершена';

  @override
  String get purchaseVerificationPendingBody =>
      'Сейчас не удалось проверить покупку через магазин. Процесс завершится автоматически, двойное списание не произойдёт.';

  @override
  String get purchaseNotAppliedTitle => 'Покупка не применена';

  @override
  String get purchaseNotAppliedBody =>
      'Не удалось применить покупку к вашему аккаунту. Обратитесь в поддержку и не покупайте повторно.';

  @override
  String get purchaseRestoreFailedTitle => 'Не удалось восстановить';

  @override
  String get purchaseRestoreFailedBody =>
      'Не удалось восстановить покупки. Попробуйте ещё раз.';

  @override
  String get purchaseRecoveredActiveBody => 'Ваша подписка активна.';

  @override
  String get purchaseCompleteTitle => 'Покупка завершена';

  @override
  String get giftCreateFailedTitle => 'Не удалось создать подарок';

  @override
  String get giftClaimFailedTitle => 'Не удалось получить подарок';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подарков для вас',
      many: 'Подарков для вас',
      few: 'Подарка для вас',
      one: 'Подарок для вас',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 месяц',
      '12': '1 год',
      'other': '$months мес.',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining осталось',
      many: 'осталось',
      few: 'осталось',
      one: 'остался',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender подарил(а) вам $duration FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Подарок FitCheck Pro для $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'От $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Для $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'От $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'получатель';

  @override
  String get giftPreviewPlaceholderSender => 'вы';

  @override
  String get settingsSavedTitle => 'Сохранено';

  @override
  String get settingsNotSavedTitle => 'Не сохранено';

  @override
  String get settingsAiChooseProviderBody => 'Выберите провайдера.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Для стороннего провайдера нужен URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Введите ключ API.';

  @override
  String get settingsAiSavedBody => 'Настройки ИИ сохранены.';

  @override
  String get settingsAiMissingDetailsTitle => 'Не хватает данных';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Введите URL API и модель чата для проверки.';

  @override
  String get settingsAiKeyNeededTitle => 'Нужен ключ API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Введите ключ API для проверки. Сохранённый ключ остаётся приватным.';

  @override
  String get settingsAiKeyToTestBody => 'Введите ключ API для проверки.';

  @override
  String get settingsAiConnectedTitle => 'Подключено';

  @override
  String get settingsAiConnectedBody => 'Соединение работает.';

  @override
  String get settingsAiTestFailedTitle => 'Ошибка проверки';

  @override
  String get settingsPreferencesSavedBody => 'Ваши настройки сохранены.';

  @override
  String get settingsPasswordNotChangedTitle => 'Пароль не изменён';

  @override
  String get settingsOAuthPasswordBody =>
      'Эта аккаунт использует вход через Google или Apple. Сначала задайте пароль через «Забыли пароль».';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Текущий пароль указан неверно.';

  @override
  String get settingsExportReadyTitle => 'Экспорт готов';

  @override
  String get settingsExportReadyBody => 'Экспорт данных готов к загрузке.';

  @override
  String get settingsLinkCopiedTitle => 'Ссылка скопирована';

  @override
  String get settingsExportClipboardBody =>
      'Не удалось открыть браузер, поэтому мы скопировали ссылку. Вставьте её в браузер как можно скорее: срок действия ограничен.';

  @override
  String get settingsExportFailedTitle => 'Ошибка экспорта';

  @override
  String get settingsAccountNotDeletedTitle => 'Аккаунт не удалён';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Можно добавить до $max фото.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Лимит фото';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Добавьте хотя бы одно фото.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Нет фото';

  @override
  String get photoshootDescribeLookBody => 'Опишите желаемый образ.';

  @override
  String get photoshootPromptNeededTitle => 'Нужен запрос';

  @override
  String get photoshootConsentFeatureLabel => 'AI-фотосессия';

  @override
  String get photoshootStatusPreparing => 'Подготовка фото';

  @override
  String get photoshootStatusGenerating => 'Генерация';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Партия $current из $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'Готово $done из $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Ошибка генерации.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return 'Готово $ready, не удалось $failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Частично завершено';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Готово $count фото.',
      many: 'Готово $count фото.',
      few: 'Готово $count фото.',
      one: 'Готово 1 фото.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Соединение потеряно. Повторите попытку.';

  @override
  String get photoshootCouldNotCancelTitle => 'Не удалось отменить';

  @override
  String get photoshootRetryFailedTitle => 'Повторная попытка не удалась';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Фото $number готово.';
  }

  @override
  String get photoshootReplacedTitle => 'Заменено';

  @override
  String get photoshootSavedToGalleryBody => 'Сохранено в галерею.';

  @override
  String get photoshootSavedTitle => 'Сохранено';

  @override
  String get photoshootNotSavedTitle => 'Не сохранено';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Все $count фото в вашей галерее.',
      many: 'Все $count фото в вашей галерее.',
      few: 'Все $count фото в вашей галерее.',
      one: '1 фото в вашей галерее.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'Сохранено $saved из $total.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Некоторые фото не сохранены';

  @override
  String get tryonConsentFeatureLabel => 'Виртуальная примерка';

  @override
  String get tryonAvatarUpdatedBody => 'Фото обновлено.';

  @override
  String get tryonSavedTitle => 'Сохранено';

  @override
  String get tryonUploadFailedTitle => 'Ошибка загрузки';

  @override
  String get tryonChooseGarmentFirstBody => 'Сначала выберите фото одежды.';

  @override
  String get tryonNoGarmentTitle => 'Нет одежды';

  @override
  String get tryonWaitForUploadBody => 'Дождитесь окончания загрузки фото.';

  @override
  String get tryonStillUploadingTitle => 'Идёт загрузка';

  @override
  String get tryonAddYourPhotoFirstBody => 'Сначала добавьте своё фото.';

  @override
  String get tryonReadyBody => 'Примерка готова.';

  @override
  String get tryonFailedTitle => 'Ошибка примерки';

  @override
  String get tryonSavedToGalleryBody => 'Сохранено в галерею.';

  @override
  String get tryonNotSavedTitle => 'Не сохранено';

  @override
  String get calendarEventAddedBody => 'Событие добавлено';

  @override
  String get calendarEventPlannedTitle => 'Запланировано';

  @override
  String get calendarEventSavedBody => 'Событие сохранено';

  @override
  String get calendarSavedTitle => 'Сохранено';

  @override
  String get calendarEventNotSavedTitle => 'Событие не сохранено';

  @override
  String get calendarEventRemovedBody => 'Событие удалено';

  @override
  String get calendarEventDeletedTitle => 'Удалено';

  @override
  String get calendarEventNotDeletedTitle => 'Событие не удалено';

  @override
  String get calendarOutfitNotLinkedTitle => 'Совместимость не настроена';

  @override
  String get calendarLinkedTitle => 'Совместимость настроена';

  @override
  String get calendarOutfitNotRemovedTitle => 'Совместимость не удалена';

  @override
  String get calendarOutfitRemovedBody => 'Совместимость удалена';

  @override
  String get calendarDisconnectedBody => 'Календарь отключен';

  @override
  String get calendarDisconnectedTitle => 'Отключен';

  @override
  String get calendarNotDisconnectedTitle => 'Календарь не отключен';

  @override
  String get calendarTodayLabel => 'сегодня';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# событий',
      many: '# событий',
      few: '# события',
      one: '# событие',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'с $start до $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, совместимость настроена';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" будет удалено.';
  }

  @override
  String get calendarThisAppLabel => 'Это приложение';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Синхронизация с $provider пока недоступна. Вы можете добавлять события здесь.';
  }

  @override
  String get calendarWeekdaySunShort => 'Вс';

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
  String get calendarWeekdayMonday => 'Понедельник';

  @override
  String get calendarWeekdayTuesday => 'Вторник';

  @override
  String get calendarWeekdayWednesday => 'Среда';

  @override
  String get calendarWeekdayThursday => 'Четверг';

  @override
  String get calendarWeekdayFriday => 'Пятница';

  @override
  String get calendarWeekdaySaturday => 'Суббота';

  @override
  String get calendarWeekdaySunday => 'Воскресенье';

  @override
  String get outfitSavedToFavouritesBody => 'Добавлено в избранное';

  @override
  String get outfitRemovedFromFavouritesBody => 'Удалено из избранного';

  @override
  String get outfitNotSavedTitle => 'Не сохранено';

  @override
  String get outfitLoggedAsWornBody => 'Отмечено как надетое сегодня.';

  @override
  String get outfitNicePickTitle => 'Отличный выбор';

  @override
  String get outfitRemovedBody => 'Комбинация удалена.';

  @override
  String get outfitDeletedTitle => 'Удалено';

  @override
  String get outfitNotDeletedTitle => 'Не удалено';

  @override
  String get outfitDuplicatedBody => 'Копия добавлена в ваши комбинации.';

  @override
  String get outfitDuplicatedTitle => 'Дублировано';

  @override
  String get outfitNotDuplicatedTitle => 'Не дублировано';

  @override
  String get outfitNotSharedTitle => 'Не отправлено';

  @override
  String outfitCollectionReadyBody(String name) {
    return '«$name» готово.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Коллекция не создана';

  @override
  String get outfitCollectionUpdatedBody => 'Коллекция обновлена.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Коллекция не обновлена';

  @override
  String get outfitCollectionDeletedBody => 'Коллекция удалена.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Коллекция не удалена';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлены $count комбинации.',
      many: 'Добавлены $count комбинаций.',
      few: 'Добавлены $count комбинации.',
      one: 'Добавлена 1 комбинация.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Комбинации не добавлены';

  @override
  String get outfitPreviewNotCreatedTitle => 'Предпросмотр не создан';

  @override
  String get outfitGiveNameBody => 'Введите название для комбинации.';

  @override
  String get outfitNameMissingTitle => 'Имя';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Выберите хотя бы одну вещь.';

  @override
  String outfitCreatedBody(String name) {
    return '$name добавлена в ваши комбинации.';
  }

  @override
  String get outfitSavedTitle => 'Сохранено';

  @override
  String get wardrobeAddedToFavouritesBody => 'Добавлено в избранное';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Удалено из избранного';

  @override
  String get wardrobeNotSavedTitle => 'Не сохранено';

  @override
  String get wardrobeLoggedAsWornBody => 'Отмечено как надето сегодня.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Убрано из вашего шкафа.';

  @override
  String get wardrobeDeletedTitle => 'Удалено';

  @override
  String get wardrobeNotDeletedTitle => 'Не удалено';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элементов удалено из вашего гардероба.',
      many: '$count предметов удалено из вашего гардероба.',
      few: '$count предмета удалено из вашего гардероба.',
      one: '1 предмет удалён из вашего гардероба.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Извлечение гардероба ИИ';

  @override
  String get itemAddScanJobLabel => 'Сканирование';

  @override
  String get itemAddFoundEarlierBody => 'Найдено в предыдущем сканировании';

  @override
  String get itemAddLookingAtPhoto => 'Анализ вашего фото';

  @override
  String get itemAddExtractionFailedBody => 'Не удалось извлечь';

  @override
  String get itemAddJobFailedBody => 'Операция не удалась';

  @override
  String get itemAddConnectionLostBody =>
      'Соединение потеряно. Попробуйте еще раз.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Соединение потеряно во время обработки.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Предмет $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Предмет';

  @override
  String get itemAddNotCancelledTitle => 'Не отменено';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предметов в вашем шкафу.',
      many: '$count предметов в вашем шкафу.',
      few: '$count предмета в вашем шкафу.',
      one: '1 предмет в вашем шкафу.',
      zero: 'Предметы отсутствуют.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'Сохранено $saved из $total предметов. Нажмите «Сохранить», чтобы попробовать остальные.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Некоторые предметы не сохранены';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Выберите хотя бы одно фото.';

  @override
  String get batchPhotoUnreadableBody => 'Это фото не удалось прочитать.';

  @override
  String get batchNoPhotosReadableBody =>
      'Ни одно из этих фото не удалось прочитать. Попробуйте другие.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Мы потеряли соединение во время работы. Попробуйте еще раз.';

  @override
  String get batchNotCancelledTitle => 'Не отменено';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Ссылки на публикации не поддерживаются. Введите ссылку на профиль.';

  @override
  String get batchLinkSpacesBody => 'Ссылки не должны содержать пробелов.';

  @override
  String get batchEnterProfileLinkBody =>
      'Введите ссылку на профиль Instagram или Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Введите ссылку на профиль.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Страница входа не открыта. Попробуйте снова.';

  @override
  String get batchSignInBrowserBody =>
      'Войдите в браузере, затем вернитесь в FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Подключите аккаунт';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Введите код из приложения-аутентификатора.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram требует проверку безопасности. Сначала войдите в браузере.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Введите имя пользователя и пароль снова.';

  @override
  String get batchSignInFailedBody =>
      'Ошибка входа. Проверьте имя пользователя и пароль.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Войдите, чтобы продолжить импорт.';

  @override
  String get batchAccountNotConnectedBody => 'Аккаунт не был подключен.';

  @override
  String get batchAccountConnectedTitle => 'Аккаунт подключен';

  @override
  String get batchNotConnectedTitle => 'Не подключено';

  @override
  String get batchImportConnectionLostBody =>
      'Соединение с импортом потеряно. Обновите страницу для проверки.';

  @override
  String batchPickUpToBody(int max) {
    return 'Выберите до $max фото. Мы найдем вещи.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count из $total фото';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Подготовка фото $done из $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найти вещи на $count фото',
      many: 'Найти вещи на $count фото',
      few: 'Найти вещи на $count фото',
      one: 'Найти вещи на 1 фото',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Ваш аккаунт $platform использует двухэтапный вход. Введите 6-значный код из приложения-аутентификатора.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Этот профиль $platform закрыт или требует входа для просмотра фото.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Подключить через $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count фото',
      many: 'Найдено $count фото',
      few: 'Найдено $count фото',
      one: 'Найдено 1 фото',
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
    return '$processed из $total обработано · $added добавлено · $waiting в ожидании · $skipped пропущено';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Сканирование фото $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Далее фото $number';
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
      other: 'Найдено $count вещь',
      many: 'Найдено $count вещей',
      few: 'Найдено $count вещи',
      one: 'Найдена 1 вещь',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото добавлено в гардероб.',
      many: '$count фото добавлено в гардероб.',
      few: '$count фото добавлены в гардероб.',
      one: '1 фото добавлено в гардероб.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Еще $count студийное фото в работе. Можно сохранить готовые или закрыть — мы сообщим.',
      many:
          'Еще $count студийных фото в работе. Можно сохранить готовые или закрыть — мы сообщим.',
      few:
          'Еще $count студийных фото в работе. Можно сохранить готовые или закрыть — мы сообщим.',
      one:
          'Еще 1 студийное фото в работе. Можно сохранить готовые или закрыть — мы сообщим.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Еще не сохранено: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces вещь',
      many: '$pieces вещей',
      few: '$pieces вещи',
      one: '1 вещь',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos фото',
      many: '$photos фото',
      few: '$photos фото',
      one: '1 фото',
    );
    return '$_temp0 из $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return 'Выбрано: $chosen. Нажмите на вещь, чтобы пропустить.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сохраняем $count вещей',
      one: 'Сохраняем 1 вещь',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сохранить $count вещей',
      one: 'Сохранить 1 вещь',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Ваш профиль тела сохранён.';

  @override
  String get bodyProfileSavedTitle => 'Сохранено';

  @override
  String get bodyProfileNotSavedTitle => 'Не сохранено';

  @override
  String get bodyProfileSetDefaultBody => 'Сделать основным профилем.';

  @override
  String get bodyProfileDeletedBody => 'Профиль тела удалён.';

  @override
  String get bodyProfileDeletedTitle => 'Удалено';

  @override
  String get bodyProfileNotDeletedTitle => 'Не удалено';

  @override
  String get feedbackNotSentTitle => 'Не отправлено';

  @override
  String get feedbackSentBody =>
      'Спасибо. Мы читаем каждое сообщение и отвечаем, если нужно уточнить детали.';

  @override
  String get feedbackSentTitle => 'Отзыв отправлен';

  @override
  String get recommendUnnamedPiece => 'Вещь без названия';

  @override
  String get recommendEnterCityBody =>
      'Укажите ваш город, чтобы получить подборку для погоды.';

  @override
  String get recommendWhichCityTitle => 'Какой город?';

  @override
  String get aiConsentSheetTitle => 'Передача фото в ИИ-сервис';

  @override
  String get aiConsentSheetBody =>
      'Чтобы создать изображения примерки и фотосессии, FitCheck AI отправляет предоставленные вами фотографии (включая изображения вашего лица и тела) в доверенный сторонний ИИ-провайдер (такой как OpenAI или Google Gemini) для обработки. Они генерируют ваши изображения и не используют их для обучения моделей в рамках наших условий. Фотографии передаются безопасно и никогда не используются для рекламы.';

  @override
  String get aiConsentSheetPermission =>
      'Продолжая, вы явно разрешаете передавать ваши фотографии этим ИИ-провайдерам для генерации изображений.';

  @override
  String get skeletonsLoadMoreFailed => 'Не удалось загрузить ещё.';

  @override
  String get jobsPiecesReadyTitle => 'Ваши вещи готовы';

  @override
  String get jobsScanStoppedTitle => 'Сканирование остановлено';

  @override
  String get jobsNothingSavedBody =>
      'Ничего не было сохранено. Попробуйте снова.';

  @override
  String get jobsPhotoUploadFailedBody => 'Ошибка загрузки фото.';

  @override
  String get authGoogleSignInStartFailed =>
      'Не удалось запустить вход через Google. Попробуйте ещё раз.';

  @override
  String get referralAppliedTitle => 'Реферал применён!';

  @override
  String get billingStoreUnavailableBody =>
      'Покупки в магазине недоступны на этом устройстве.';

  @override
  String get billingPurchaseProcessingBody =>
      'Эта покупка ещё обрабатывается. Откройте приложение через минуту, чтобы увидеть ваш план.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Загрузка аватара не вернула URL изображения.';

  @override
  String get rewardsDayStreakLabel => 'дневная серия';

  @override
  String rewardsBestStreak(int days) {
    return 'Лучшая серия $days дней';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Доступ к $permission необходим';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Доступ к $permission сейчас запрещён. Разрешите его в настройках, затем вернитесь и повторите.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Шаг $step из 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Убрать изображение $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Убрать изображение $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points б.';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Напишите на $email. Ответим в течение 24 часов.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Убрать $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Добавить в «$name»';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '«$name» удалено. Вещи остались в гардеробе.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Показать все $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Сегодня осталось $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Фото $index не удалось';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected из $max фото';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Силуэт $shape, тон кожи $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Настройки для $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Чаще всего носили: $name, $count раз(а)';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: не заполнено';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'Совпадение $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'Выбрано $picked из $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Убрать $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Приоритет $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Оплата плана идёт через $store. Меняйте или отменяйте его в настройках аккаунта $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Управляйте через $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: использовано $current из $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Осталось $seconds с';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return 'Готово $done из $total студийных фото';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return 'Готово $ready из $total студийных фото. Нажмите на предмет, чтобы пропустить.';
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
  String get profileFieldNotSet => 'Нет';
}
