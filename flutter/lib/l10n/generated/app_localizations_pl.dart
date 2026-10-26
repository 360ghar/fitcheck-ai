// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Główna';

  @override
  String get tabPhotoshoot => 'Sesja';

  @override
  String get tabCloset => 'Szafa';

  @override
  String get tabOutfits => 'Stylizacje';

  @override
  String get tabMore => 'Więcej';

  @override
  String get actionAddItem => 'Dodaj rzecz';

  @override
  String get actionCreateOutfit => 'Stwórz stylizację';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionRetry => 'Spróbuj ponownie';

  @override
  String get actionDone => 'Gotowe';

  @override
  String get actionNext => 'Dalej';

  @override
  String get actionBack => 'Wstecz';

  @override
  String get actionClose => 'Zamknij';

  @override
  String get actionSearch => 'Szukaj';

  @override
  String get actionContinue => 'Kontynuuj';

  @override
  String get stateLoading => 'Ładowanie';

  @override
  String get stateErrorTitle => 'Coś poszło nie tak';

  @override
  String get stateErrorBody =>
      'Spróbuj ponownie. Jeśli problem nie zniknie, skontaktuj się ze wsparciem.';

  @override
  String get stateOfflineTitle => 'Brak połączenia';

  @override
  String get stateOfflineBody =>
      'Połącz się z internetem, aby zsynchronizować szafę i tworzyć stylizacje.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsPreferencesSection => 'Preferencje';

  @override
  String get settingsPlanBilling => 'Plan i płatności';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsNotifications => 'Powiadomienia';

  @override
  String get settingsUnits => 'Jednostki miary';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsPrivacySection => 'Prywatność i dane';

  @override
  String get settingsAboutSection => 'O aplikacji';

  @override
  String get settingsSignOut => 'Wyloguj się';

  @override
  String get settingsDeleteAccount => 'Usuń konto';

  @override
  String get settingsDeleteAccountTitle => 'Usunąć konto?';

  @override
  String get settingsDeleteAccountBody =>
      'To usunie Twoją szafę, stylizacje, zdjęcia i profil. Tej operacji nie można cofnąć.';

  @override
  String get settingsUnitsImperial => 'Imperialne (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metryczne (cm, kg)';

  @override
  String get languageTitle => 'Język';

  @override
  String get languageSystem => 'Użyj języka urządzenia';

  @override
  String get languageSystemBody =>
      'FitCheck AI dopasuje się do języka Twojego telefonu.';

  @override
  String get languageSearchHint => 'Szukaj języków';

  @override
  String get languageCurrent => 'Aktualny';

  @override
  String get languageReviewNote =>
      'To nowe tłumaczenie. Daj nam znać, jeśli coś brzmi nienaturalnie.';

  @override
  String get languageChanged => 'Zaktualizowano język';

  @override
  String get paywallTitle => 'Wybierz plan';

  @override
  String get paywallTrialBadge => '1 miesiąc gratis';

  @override
  String get paywallTrialTitle => 'Pierwszy miesiąc Pro masz za darmo';

  @override
  String get paywallTrialBody =>
      'Dodaj całą szafę na raz. Potem możesz dokładać kolejne rzeczy.';

  @override
  String get paywallFreeForeverTitle => 'Zawsze darmowy';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Karta nie jest wymagana. Co miesiąc otrzymujesz $uploads wgrań AI, $outfits stylizacji i $images zdjęć studyjnych dziennie.';
  }

  @override
  String get paywallCtaTrial => 'Rozpocznij darmowy miesiąc';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Przejdź na $plan';
  }

  @override
  String get paywallRestore => 'Przywróć zakupy';

  @override
  String get paywallManage => 'Zarządzaj subskrypcją';

  @override
  String get paywallTerms => 'Warunki użytkowania';

  @override
  String get paywallPrivacy => 'Polityka prywatności';

  @override
  String get paywallPerMonth => 'miesięcznie';

  @override
  String get paywallPerYear => 'rocznie';

  @override
  String get paywallBestValue => 'Najlepsza opcja';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Darmowy okres próbny tylko dla nowych użytkowników. Po jego zakończeniu subskrypcja Pro odnawia się za $price, chyba że zostanie anulowana co najmniej 24 godziny przed końcem.';
  }

  @override
  String get introTitle => 'Twoja szafa wreszcie uporządkowana';

  @override
  String get introBody =>
      'Zrób zdjęcia ubrań raz. Otrzymuj pomysły na stylizacje, przymierzaj wirtualnie i twórz zdjęcia studyjne z tego, co już masz.';

  @override
  String get introStart => 'Rozpocznij';

  @override
  String get introHaveAccount => 'Mam już konto';

  @override
  String get introSkip => 'Pomiń';

  @override
  String get authSignIn => 'Zaloguj się';

  @override
  String get authSignUp => 'Utwórz konto';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Hasło';

  @override
  String get authForgotPassword => 'Nie pamiętasz hasła?';

  @override
  String get authContinueApple => 'Kontynuuj z Apple';

  @override
  String get authContinueGoogle => 'Kontynuuj z Google';

  @override
  String get authOrDivider => 'lub';

  @override
  String get wardrobeTitle => 'Szafa';

  @override
  String get wardrobeEmptyTitle => 'Twoja szafa jest pusta';

  @override
  String get wardrobeEmptyBody =>
      'Dodaj pierwszą rzecz lub wgraj zdjęcie całej zawartości na raz.';

  @override
  String get wardrobeAddFirst => 'Dodaj pierwszy element';

  @override
  String get wardrobeSearchHint => 'Szukaj w szafie';

  @override
  String get categoryTops => 'Góra';

  @override
  String get categoryBottoms => 'Dół';

  @override
  String get categoryShoes => 'Buty';

  @override
  String get categoryAccessories => 'Dodatki';

  @override
  String get categoryOuterwear => 'Okrycia wierzchnie';

  @override
  String get categorySwimwear => 'Stroje kąpielowe';

  @override
  String get categoryActivewear => 'Sportowe';

  @override
  String get categoryOther => 'Inne';

  @override
  String get conditionClean => 'Czyste';

  @override
  String get conditionDirty => 'Brudne';

  @override
  String get conditionLaundry => 'W praniu';

  @override
  String get conditionRepair => 'Do naprawy';

  @override
  String get conditionDonate => 'Do oddania';

  @override
  String get seasonSpring => 'Wiosna';

  @override
  String get seasonSummer => 'Lato';

  @override
  String get seasonFall => 'Jesień';

  @override
  String get seasonWinter => 'Zima';

  @override
  String get seasonAll => 'Całoroczne';

  @override
  String get styleCasual => 'Codzienny';

  @override
  String get styleFormal => 'Formalny';

  @override
  String get styleBusiness => 'Biznesowy';

  @override
  String get styleSporty => 'Sportowy';

  @override
  String get styleBohemian => 'Boho';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistyczny';

  @override
  String get styleRomantic => 'Romantyczny';

  @override
  String get styleEdgy => 'Z pazurem';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artystyczny';

  @override
  String get styleClassic => 'Klasyczny';

  @override
  String get styleElegant => 'Elegancki';

  @override
  String get styleOther => 'Inny';

  @override
  String get occasionWork => 'Do pracy';

  @override
  String get occasionDateNight => 'Na randkę';

  @override
  String get occasionTravel => 'W podróż';

  @override
  String get occasionWedding => 'Na wesele';

  @override
  String get occasionGym => 'Na siłownię';

  @override
  String get occasionWeekend => 'Na weekend';

  @override
  String get occasionParty => 'Na imprezę';

  @override
  String get occasionInterview => 'Rozmowa kwalifikacyjna';

  @override
  String get colorBlack => 'Czarny';

  @override
  String get colorWhite => 'Biały';

  @override
  String get colorGrey => 'Szary';

  @override
  String get colorNavy => 'Granatowy';

  @override
  String get colorBrown => 'Brązowy';

  @override
  String get colorRed => 'Czerwony';

  @override
  String get colorBlue => 'Niebieski';

  @override
  String get colorGreen => 'Zielony';

  @override
  String get colorPink => 'Różowy';

  @override
  String get colorPurple => 'Fioletowy';

  @override
  String get colorYellow => 'Żółty';

  @override
  String get colorOrange => 'Pomarańczowy';

  @override
  String get colorBeige => 'Beżowy';

  @override
  String get dateToday => 'Dzisiaj';

  @override
  String get dateYesterday => 'Wczoraj';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni temu',
      many: '$count dni temu',
      few: '$count dni temu',
      one: '1 dzień temu',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tygodni temu',
      many: '$count tygodni temu',
      few: '$count tygodnie temu',
      one: '1 tydzień temu',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miesięcy temu',
      many: '$count miesięcy temu',
      few: '$count miesiące temu',
      one: '1 miesiąc temu',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lat temu',
      many: '$count lat temu',
      few: '$count lata temu',
      one: '1 rok temu',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Lubisz FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Szybka ocena pomaga innym odnaleźć swój styl.';

  @override
  String get ratingPromptYes => 'Oceń aplikację';

  @override
  String get ratingPromptNo => 'Nie teraz';

  @override
  String get closetNoMatchesTitle => 'Brak pasujących rzeczy';

  @override
  String get closetNoMatchesBody =>
      'Zastosuj mniej filtrów lub wyszukaj coś innego.';

  @override
  String get closetClearFilters => 'Wyczyść filtry';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rzeczy',
      many: '$count rzeczy',
      few: '$count rzeczy',
      one: '1 rzecz',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Wczytywanie garderoby';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wybranych',
      many: '$count wybranych',
      few: '$count wybrane',
      one: '1 wybrana',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Usuń zaznaczone';

  @override
  String get closetCancelSelection => 'Anuluj';

  @override
  String get closetCloseSearch => 'Zamknij wyszukiwanie';

  @override
  String get closetShowGrid => 'Widok siatki';

  @override
  String get closetShowList => 'Widok listy';

  @override
  String get closetShowRows => 'Widok wierszy';

  @override
  String get closetStatsTitle => 'Statystyki szafy';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunąć $count rzeczy?',
      many: 'Usunąć $count rzeczy?',
      few: 'Usunąć $count rzeczy?',
      one: 'Usunąć 1 rzecz?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Stylizacje zawierające te rzeczy je stracą.';

  @override
  String get closetSortBy => 'Sortuj według';

  @override
  String get closetFavourites => 'Ulubione';

  @override
  String get closetFavourite => 'Ulubione';

  @override
  String get closetUnfavourite => 'Usuń z ulubionych';

  @override
  String get closetWoreToday => 'Założone dzisiaj';

  @override
  String closetWornTimes(int count) {
    return 'Założono $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategoria';

  @override
  String get closetUseCaseLabel => 'Okazja';

  @override
  String get closetAnyUseCase => 'Wszystkie';

  @override
  String get closetOtherUseCase => 'Inna okazja';

  @override
  String get closetOtherUseCaseHint => 'Na przykład brunch';

  @override
  String get closetUseUseCase => 'Użyj tego';

  @override
  String get closetClearAll => 'Wyczyść wszystko';

  @override
  String get sortNewest => 'Najnowsze';

  @override
  String get sortOldest => 'Najstarsze';

  @override
  String get sortName => 'Nazwa (A–Z)';

  @override
  String get sortMostWorn => 'Najczęściej noszone';

  @override
  String get useCaseInformal => 'Na co dzień';

  @override
  String get useCaseDate => 'Randka';

  @override
  String get useCaseDinner => 'Kolacja';

  @override
  String get useCaseLunch => 'Lunch';

  @override
  String get actionSelect => 'Wybierz';

  @override
  String get actionEdit => 'Edytuj';

  @override
  String get actionFilter => 'Filtruj';

  @override
  String get actionSort => 'Sortuj';

  @override
  String get actionAll => 'Wszystkie';

  @override
  String get dashboardStartClosetTitle => 'Uzupełnij szafę';

  @override
  String get dashboardStartClosetBody =>
      'Zrób zdjęcia kilku rzeczom. Oznaczymy je za Ciebie.';

  @override
  String get dashboardPieces => 'sztuki';

  @override
  String get dashboardOutfits => 'zestawy';

  @override
  String get dashboardDayStreak => 'dni z rzędu';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count w tym miesiącu';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Rekord: $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ulubionego',
      many: '$count ulubionych',
      few: '$count ulubione',
      one: '1 ulubiony',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zapisanych stylizacji',
      few: '$count zapisane stylizacje',
      one: '1 zapisana stylizacja',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Najczęściej noszone: $name, $count razy';
  }

  @override
  String get setupSkip => 'Pomiń konfigurację';

  @override
  String get setupWhoTitle => 'Kogo stylizujemy?';

  @override
  String get setupWhoBody =>
      'Ustala model do przymierzalni i sesji. Zmienisz to w profilu.';

  @override
  String get setupStyleTitle => 'Co nosisz najczęściej?';

  @override
  String get setupStyleBody =>
      'Wybierz dowolne. Od nich zaczną się pomysły na zestawy.';

  @override
  String get setupClosetTitle => 'Dodaj pierwsze rzeczy.';

  @override
  String get setupClosetBody =>
      'Sfotografuj kilka ubrań lub ich stos. Każdy element zostanie wycięty i uporządkowany dla Ciebie.';

  @override
  String get setupAddClothes => 'Dodaj ubrania';

  @override
  String get setupStylesLabel => 'Style';

  @override
  String get setupOccasionsLabel => 'Okazje';

  @override
  String get setupSkipStep => 'Pomiń';

  @override
  String get setupLater => 'Później';

  @override
  String get setupSaveError => 'Nie udało się zapisać';

  @override
  String get genderWomen => 'Kobiety';

  @override
  String get genderMen => 'Mężczyźni';

  @override
  String get genderNonBinary => 'Osoby niebinarne';

  @override
  String get genderPreferNotToSay => 'Wolę nie podawać';

  @override
  String get outfitEmptyTitle => 'Brak stylizacji';

  @override
  String get outfitEmptyBody => 'Połącz rzeczy z szafy i zapisz swój zestaw.';

  @override
  String get outfitNoMatchesTitle => 'Brak pasujących stylizacji';

  @override
  String get outfitSearchHint => 'Szukaj w stylizacjach';

  @override
  String get outfitLoading => 'Ładowanie stylizacji';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stylizacji',
      many: '$count stylizacji',
      few: '$count stylizacje',
      one: '1 stylizacja',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Styl i sezon';

  @override
  String get outfitCollections => 'Kolekcje';

  @override
  String get outfitDuplicate => 'Duplikuj';

  @override
  String get outfitDeleteTitle => 'Usunąć tę stylizację?';

  @override
  String get outfitDeleteBody => 'Jej elementy pozostaną w Twojej szafie.';

  @override
  String get outfitDrafts => 'Szkice';

  @override
  String get outfitDraft => 'Szkic';

  @override
  String get filterStyle => 'Styl';

  @override
  String get filterSeason => 'Sezon';

  @override
  String get itemDetailDeleteTitle => 'Usunąć tę rzecz?';

  @override
  String get itemDetailDeleteBody =>
      'Stylizacje, które jej używają, stracą ten element.';

  @override
  String get itemAddFavourite => 'Dodaj do ulubionych';

  @override
  String itemSize(String size) {
    return 'Rozmiar $size';
  }

  @override
  String get itemColours => 'Kolory';

  @override
  String get itemMaterial => 'Materiał';

  @override
  String get itemPattern => 'Wzór';

  @override
  String get itemUseCases => 'Zastosowanie';

  @override
  String get itemKeptIn => 'Przechowywane w';

  @override
  String get itemPrice => 'Cena';

  @override
  String get itemBought => 'Kupiono';

  @override
  String get itemTags => 'Tagi';

  @override
  String get itemAdded => 'Dodano';

  @override
  String get itemTimesWornLabel => 'załozone razy';

  @override
  String get itemLastWornLabel => 'ostatnio włożone';

  @override
  String get itemNeverWorn => 'Nigdy';

  @override
  String get authEntryBody =>
      'Wszystko, co masz w szafie, stylizowane przez FitCheck AI. Planuj zestawy, przymierzaj, twórz.';

  @override
  String get authCreateCloset => 'Utwórz szafę';

  @override
  String get authWelcomeBack => 'Witaj ponownie';

  @override
  String get authSignInBody => 'Zaloguj się, aby otworzyć szafę.';

  @override
  String get authCreateAccount => 'Utwórz konto';

  @override
  String get authCreateClosetBody =>
      'To zajmuje chwilę. Pierwsze rzeczy są za darmo.';

  @override
  String get authName => 'Imię';

  @override
  String get authConfirmPassword => 'Potwierdź hasło';

  @override
  String get authReferralCode => 'Kod polecenia (opcjonalnie)';

  @override
  String get authResetTitle => 'Zresetuj hasło';

  @override
  String get authResetBody => 'Wyślemy Ci link do ustawienia nowego hasła.';

  @override
  String get authSendResetLink => 'Wyślij link resetowania';

  @override
  String get authBackToSignIn => 'Powrót do logowania';

  @override
  String get authEnterEmail => 'Podaj e-mail';

  @override
  String get authEnterValidEmail => 'Podaj poprawny e-mail';

  @override
  String get authEnterPassword => 'Podaj hasło';

  @override
  String get authPasswordTooShort => 'Minimum 6 znaków';

  @override
  String get authShowPassword => 'Pokaż hasło';

  @override
  String get authHidePassword => 'Ukryj hasło';

  @override
  String get authNewHere => 'Nowy tutaj?';

  @override
  String authConfirmEmail(String email) {
    return 'Potwierdź $email przed zalogowaniem. Sprawdź skrzynkę.';
  }

  @override
  String get authResendEmail => 'Wyślij ponownie';

  @override
  String get authResendingEmail => 'Wysyłanie…';

  @override
  String get authPasswordsDoNotMatch => 'Hasła nie pasują do siebie';

  @override
  String get authEnterName => 'Podaj imię';

  @override
  String get authChoosePassword => 'Wybierz hasło';

  @override
  String get authHaveAccount => 'Masz już konto?';

  @override
  String get authCodeAccepted => 'Kod przyjęty';

  @override
  String get authCodeNotFound => 'Nie znaleziono kodu';

  @override
  String authReferralFrom(String name) {
    return 'Od $name. Oboje zyskujecie miesiąc gratis.';
  }

  @override
  String get authReferralInvalid => 'Nie znaleziono takiego kodu.';

  @override
  String authResetSent(String email) {
    return 'Wysłano na $email. Otwórz link na tym telefonie.';
  }

  @override
  String get introSlide1Title => 'Z fotografuj szafę raz.';

  @override
  String get introSlide1Body =>
      'Zrób zdjęcie stosu ubrań. Każda rzecz zostanie wycięta i uporządkowana.';

  @override
  String get introSlide2Title => 'Ubieraj się szybciej.';

  @override
  String get introSlide2Body =>
      'Zestawy z Twoich ubrań, dobrane do planów i pogody.';

  @override
  String get introSlide3Title => 'Zobacz to, zanim włożysz.';

  @override
  String get introSlide3Body =>
      'Przymierzaj stylizacje na własnym zdjęciu lub prezentuj je jak w kampanii.';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Powiadomienia e-mail';

  @override
  String get settingsEmailUpdatesBody => 'Nowości i porady w wiadomościach';

  @override
  String get settingsOutfitReminders => 'Przypomnienia o ubiorze';

  @override
  String get settingsOutfitRemindersBody =>
      'Zachęta do zapisu tego, co masz na sobie';

  @override
  String get settingsWeeklySummary => 'Podsumowanie tygodnia';

  @override
  String get settingsWeeklySummaryBody => 'Twój tydzień w stylizacjach';

  @override
  String get settingsStyleSection => 'Styl';

  @override
  String get settingsPreferredStyles => 'Ulubione style';

  @override
  String get settingsPreferredColours => 'Ulubione kolory';

  @override
  String get settingsNoneChosen => 'Nie wybrano';

  @override
  String get settingsPlanAiSection => 'Plan i AI';

  @override
  String get settingsPlanBillingBody => 'Plan, użycie i ulepszenia';

  @override
  String get settingsPlanUsageBody => 'Plan i użycie';

  @override
  String get settingsInviteFriends => 'Zaproś znajomych';

  @override
  String get settingsInviteFriendsBody =>
      'Darmowy miesiąc za każdego poleconego znajomego';

  @override
  String get settingsAiProvider => 'Dostawca AI';

  @override
  String get settingsAiProviderBody =>
      'Użyj własnego modelu do tagowania i obrazów';

  @override
  String get settingsAppVersion => 'Wersja aplikacji';

  @override
  String get settingsPrivacyTerms => 'Prywatność i regulamin';

  @override
  String get settingsReportProblem => 'Zgłoś problem';

  @override
  String get settingsChangePassword => 'Zmień hasło';

  @override
  String get settingsExportData => 'Eksportuj dane';

  @override
  String get settingsExportBody =>
      'Przygotujemy plik ze wszystkimi zapisanymi danymi do pobrania.';

  @override
  String get settingsExportAction => 'Eksportuj';

  @override
  String get settingsCurrentPassword => 'Obecne hasło';

  @override
  String get settingsNewPassword => 'Nowe hasło';

  @override
  String get settingsConfirmNewPassword => 'Potwierdź nowe hasło';

  @override
  String get settingsEnterCurrentPassword => 'Wpisz obecne hasło';

  @override
  String get settingsEnterNewPassword => 'Wpisz nowe hasło';

  @override
  String get settingsPasswordMin8 => 'Użyj co najmniej 8 znaków';

  @override
  String get settingsPasswordNeedsUpper => 'Dodaj wielką literę';

  @override
  String get settingsPasswordNeedsLower => 'Dodaj małą literę';

  @override
  String get settingsPasswordNeedsDigit => 'Dodaj cyfrę';

  @override
  String get settingsPasswordsNoMatch => 'Hasła nie zgadzają się';

  @override
  String get settingsChangeAction => 'Zmień';

  @override
  String get itemAddSnapTitle => 'Zrob zdjęcie';

  @override
  String get itemAddSnapBody =>
      'Znajdziemy każdy element na zdjęciu i przygotujemy czyste zdjęcie studyjne każdego z nich.';

  @override
  String get itemAddCamera => 'Zrób zdjęcie';

  @override
  String get itemAddGallery => 'Wybierz z galerii';

  @override
  String get itemAddOtherWays => 'Inne sposoby dodawania';

  @override
  String get itemAddSeveral => 'Dodaj kilka zdjęć';

  @override
  String get itemAddSeveralBody => 'Do 50 naraz';

  @override
  String get itemAddImportProfile => 'Importuj z profilu';

  @override
  String get itemAddImportProfileBody => 'Instagram lub Facebook';

  @override
  String get itemAddEnterDetails => 'Wprowadź dane ręcznie';

  @override
  String get itemAddEnterDetailsBody => 'Zdjęcie nie jest wymagane';

  @override
  String get itemManualIntro =>
      'Wystarczy sama nazwa. Resztę możesz dodać teraz lub później.';

  @override
  String get itemManualNameHint => 'Na przykład niebieski bawełniany t-shirt';

  @override
  String get itemManualEnterName => 'Wpisz nazwę';

  @override
  String get itemManualNotes => 'Notatki';

  @override
  String get itemManualBrand => 'Marka';

  @override
  String get itemManualSize => 'Rozmiar';

  @override
  String get itemManualEnterNumber => 'Wpisz liczbę';

  @override
  String get itemManualSavePiece => 'Zapisz element';

  @override
  String get itemManualSaving => 'Zapisywanie';

  @override
  String get itemManualSavedTitle => 'Zapisano';

  @override
  String itemManualSavedBody(String name) {
    return '$name jest w Twojej szafie.';
  }

  @override
  String get itemManualNotSaved => 'Nie zapisano';

  @override
  String get itemManualAddUseCase => 'Dodaj zastosowanie';

  @override
  String get itemManualAddUseCaseAction => 'Dodaj zastosowanie';

  @override
  String get itemPhotos => 'Zdjęcia';

  @override
  String get itemAddPhotos => 'Dodaj zdjęcia';

  @override
  String get itemNoPhotoYet => 'Brak zdjęcia. Możesz zapisać bez niego.';

  @override
  String get itemRemovePhoto => 'Usuń zdjęcie';

  @override
  String get itemRemovePiece => 'Usuń element';

  @override
  String get filterConditionLabel => 'Stan';

  @override
  String get photoshootStepPhotos => 'Zdjęcia';

  @override
  String get photoshootStepSetup => 'Konfiguracja';

  @override
  String get photoshootStepCreating => 'Tworzenie';

  @override
  String get photoshootStepResults => 'Wyniki';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Krok $current z $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Jedno zdjęcie nie powiodło się. Spróbuj ponownie poniżej.';

  @override
  String photoshootManyFailed(int count) {
    return '$count zdjęć nie powiodło się. Spróbuj ponownie dla każdego z nich poniżej.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Ile';

  @override
  String get photoshootYourPrompt => 'Twój opis';

  @override
  String get photoshootPromptHint => 'Złota godzina na dachu, lniana koszula';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stwórz $count zdjęcia',
      many: 'Stwórz $count zdjęć',
      few: 'Stwórz $count zdjęcia',
      one: 'Stwórz 1 zdjęcie',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'zdjęcia',
      many: 'zdjęć',
      few: 'zdjęcia',
      one: 'zdjęcie',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Nie udało się sprawdzić dzisiejszego limitu.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plan $plan: pozostało $remaining z $limit na dziś';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Darmowy';

  @override
  String get photoshootGallery => 'Galeria';

  @override
  String get photoshootUseCamera => 'Użyj aparatu';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Usuń zdjęcie $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Brak zdjęć';

  @override
  String get photoshootNoPhotosBody =>
      'Sesja zakończyła się bez obrazów. Spróbuj ponownie.';

  @override
  String get photoshootNewStyle => 'Nowy styl';

  @override
  String get photoshootNewPhotos => 'Nowe zdjęcia';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Otwórz zdjęcie $number';
  }

  @override
  String get photoshootReportPhoto => 'Zgłoś zdjęcie';

  @override
  String get photoshootSaveToGallery => 'Zapisz w galerii';

  @override
  String get actionUpgrade => 'Ulepsz';

  @override
  String get referralLimitTitle => 'Wykorzystano dzisiejsze zdjęcia';

  @override
  String get referralLimitBody =>
      'Darmowe zdjęcia odnowią się jutro. Poleć znajomemu, a obaj otrzymacie miesiąc Pro za darmo.';

  @override
  String get referralLimitRefer => 'Poleć znajomemu';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Aplikacja randkowa';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetyka';

  @override
  String get photoshootUseCustom => 'Własny opis';

  @override
  String get photoshootDescLinkedin => 'Profesjonalne portrety do pracy';

  @override
  String get photoshootDescDating => 'Swobodne, ciepłe i naturalne';

  @override
  String get photoshootDescPortfolio => 'Edytorskie, wysokomodne stylizacje';

  @override
  String get photoshootDescInstagram => 'Zdjęcia lifestylowe na profil';

  @override
  String get photoshootDescAesthetic => 'Klimatyczne, artystyczne kadry';

  @override
  String get photoshootDescCustom => 'Opisz wyczekiwany wygląd';

  @override
  String get aspectSquare => 'Kwadrat';

  @override
  String get aspectPortrait => 'Pion';

  @override
  String get aspectLandscape => 'Poziom';

  @override
  String get aspectTall => 'Wysoki';

  @override
  String get aspectWide => 'Szeroki';

  @override
  String get tryOnAppBar => 'Wirtualna przymierzalnia';

  @override
  String get tryOnYourPhoto => 'Twoje zdjęcie';

  @override
  String get tryOnGarment => 'Ubranie';

  @override
  String get tryOnUploadingPhoto => 'Wysyłanie zdjęcia';

  @override
  String get tryOnAddPhotoPrompt => 'Dodaj swoje zdjęcie całej sylwetki';

  @override
  String get tryOnBodyPhotoHint => 'Najlepsze jest zdjęcie całej sylwetki';

  @override
  String get tryOnAddPhoto => 'Dodaj zdjęcie';

  @override
  String get tryOnChangePhoto => 'Zmień zdjęcie';

  @override
  String get tryOnPhotoLoadFailed => 'Nie udało się wczytać zdjęcia.';

  @override
  String get tryOnChooseGarment => 'Wybierz zdjęcie ubrania';

  @override
  String get tryOnChooseOneGarment => 'Wybierz jedno zdjęcie ubrania';

  @override
  String get tryOnGarmentHint =>
      'Najlepiej sprawdza się zdjęcie na płasko lub na wieszaku';

  @override
  String get tryOnChange => 'Zmień';

  @override
  String get tryOnCamera => 'Aparat';

  @override
  String get tryOnRemove => 'Usuń';

  @override
  String get tryOnLookTitle => 'Stylizacja';

  @override
  String get tryOnStyle => 'Styl';

  @override
  String get tryOnBackground => 'Tło';

  @override
  String get tryOnPose => 'Poza';

  @override
  String get tryOnDressingUp => 'Przymierzamy. To zajmie około pół minuty.';

  @override
  String get tryOnEmptyResult => 'Tutaj pojawi się przymiarka';

  @override
  String get tryOnReportImage => 'Zgłoś zdjęcie';

  @override
  String get tryOnCreating => 'Tworzenie';

  @override
  String get tryOnTryAgain => 'Spróbuj ponownie';

  @override
  String get tryOnCreate => 'Stwórz przymiarkę';

  @override
  String get tryOnBackgroundStudioWhite => 'Białe studio';

  @override
  String get tryOnBackgroundStudioGrey => 'Szare studio';

  @override
  String get tryOnBackgroundUrban => 'Ulica';

  @override
  String get tryOnBackgroundNature => 'Natura';

  @override
  String get tryOnBackgroundMinimal => 'Minimalistyczne';

  @override
  String get tryOnPoseFront => 'Stojąca przodem';

  @override
  String get tryOnPoseSide => 'Stojąca bokiem';

  @override
  String get tryOnPoseWalking => 'Chodzenie';

  @override
  String get dashboardGreetingMorning => 'Dzień dobry';

  @override
  String get dashboardGreetingAfternoon => 'Dzień dobry';

  @override
  String get dashboardGreetingEvening => 'Dobry wieczór';

  @override
  String get dashboardWelcome => 'Witaj';

  @override
  String get dashboardOpenProfile => 'Otwórz profil';

  @override
  String get dashboardRailToday => 'Dzisiaj';

  @override
  String get dashboardRailRecently => 'Ostatnio';

  @override
  String get dashboardActivityEmpty =>
      'Nowe elementy i stylizacje pojawią się tutaj.';

  @override
  String get quickAddPiece => 'Dodaj element';

  @override
  String get quickAddPieceBody => 'Zrób zdjęcie i oznacz';

  @override
  String get quickBuildOutfit => 'Stwórz zestaw';

  @override
  String get quickBuildOutfitBody => 'Połącz swoje ubrania';

  @override
  String get quickForYou => 'Dla Ciebie';

  @override
  String get quickForYouBody => 'Propozycje na dziś';

  @override
  String get quickPlanWeek => 'Zaplanuj tydzień';

  @override
  String get quickPlanWeekBody => 'Stylizacje na każdy dzień';

  @override
  String get referralBannerUrgent => 'Kończą się limity? Zaproś znajomego.';

  @override
  String get referralBannerTitle => 'Daj miesiąc, zyskaj miesiąc.';

  @override
  String get referralBannerBody =>
      'Ty i Twój znajomy otrzymacie po miesiącu planu Pro.';

  @override
  String get referralBannerDismiss => 'Ukryj na tydzień';

  @override
  String get referralBannerShare => 'Udostępnij zaproszenie';

  @override
  String get referralBannerCopy => 'Kopiuj link';

  @override
  String get itemEditPieceTitle => 'Edytuj element';

  @override
  String get itemEditDescriptionLabel => 'Opis';

  @override
  String get itemEditNotSaved => 'Nie zapisano';

  @override
  String get itemEditSavedTitle => 'Zapisano';

  @override
  String get itemEditSavedBody => 'Twoje zmiany zostały zapisane.';

  @override
  String get itemEditSavedStalePhotos =>
      'Zapisano – zdjęcia mogą być nieaktualne';

  @override
  String get itemEditRemovePieceHint =>
      'Usuń ten element ze strony przedmiotu.';

  @override
  String get itemEditNoPhotos => 'Brak zdjęć. Dodaj je z galerii lub aparatu.';

  @override
  String get itemEditKeepPhoto => 'Zachowaj zdjęcie';

  @override
  String get itemEditRemoved => 'Usunięto';

  @override
  String get itemEditAddUseCaseAction => 'Dodaj';

  @override
  String get statsNoStatsTitle => 'Brak statystyk';

  @override
  String get statsNoStatsBody =>
      'Dodaj kilka ubrań, a statystyki szafy pojawią się tutaj.';

  @override
  String get statsByCategory => 'Wg kategorii';

  @override
  String get statsTotalValue => 'łączna wartość';

  @override
  String get statsMostWorn => 'Najczęściej noszone';

  @override
  String get statsLeastWorn => 'Czekają na swoją kolej';

  @override
  String get statsUnnamedPiece => 'Element bez nazwy';

  @override
  String get jobsTitle => 'Skanowania';

  @override
  String get jobsEmptyTitle => 'Brak skanów';

  @override
  String get jobsEmptyBody =>
      'Zrób zdjęcie i wyślij w tle – zadanie będzie kontynuowane tutaj.';

  @override
  String get jobsNotCancelled => 'Nie anulowano';

  @override
  String get jobsResume => 'Wznów';

  @override
  String get jobsReview => 'Sprawdź';

  @override
  String get jobsStop => 'Zatrzymaj';

  @override
  String get jobsDismiss => 'Odrzuć';

  @override
  String get reportTitle => 'Zgłoś treść';

  @override
  String reportIntro(String contentType) {
    return 'Powiedz nam, co jest nie tak z $contentType. Nasz zespół sprawdza każde zgłoszenie.';
  }

  @override
  String get reportReasonInappropriate => 'Nieodpowiednie lub obraźliwe';

  @override
  String get reportReasonNudity => 'Nagość lub treści seksualne';

  @override
  String get reportReasonHarassment => 'Nękanie lub nadużycia';

  @override
  String get reportReasonImpersonation => 'Podszywanie się';

  @override
  String get reportReasonOther => 'Inne';

  @override
  String get reportDetailsLabel => 'Dodatkowe szczegóły (opcjonalnie)';

  @override
  String get reportSubmit => 'Wyślij zgłoszenie';

  @override
  String get reportSubmittedTitle => 'Zgłoszenie wysłane';

  @override
  String get reportSubmittedBody =>
      'Dziękujemy. Nasz zespół sprawdzi tę treść.';

  @override
  String get reportFailedTitle => 'Nie udało się wysłać zgłoszenia';

  @override
  String get reportFailedBody => 'Spróbuj ponownie.';

  @override
  String get reportContentTryOnImage => 'obrazu z przymierzalni AI';

  @override
  String get reportContentSharedOutfit => 'udostępnionej stylizacji';

  @override
  String get reportContentPhotoshootImage => 'obrazu z sesji AI';

  @override
  String get sharedOutfitTitle => 'Udostępniona stylizacja';

  @override
  String get sharedOutfitHideTooltip => 'Ukryj tę stylizację';

  @override
  String get sharedOutfitReportTooltip => 'Zgłoś tę stylizację';

  @override
  String get sharedOutfitHideTitle => 'Ukryć tę stylizację?';

  @override
  String get sharedOutfitHideBody =>
      'Zostanie ukryta na tym urządzeniu. Możesz ją również zgłosić, aby nasz zespół mógł ją sprawdzić i usunąć.';

  @override
  String get sharedOutfitHideAction => 'Ukryj';

  @override
  String get sharedOutfitHiddenInfo =>
      'Ta stylizacja nie będzie już wyświetlana na tym urządzeniu.';

  @override
  String get sharedOutfitHiddenToast => 'Stylizacja ukryta';

  @override
  String get sharedOutfitMissingTitle => 'Ta stylizacja już tu nie jest';

  @override
  String get sharedOutfitMissingBody =>
      'Mogła zostać usunięta lub link jest błędny.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Ukryto tę stylizację';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Jeśli jest niestosowna, zgłoś ją w sekcji Prywatność i warunki lub napisz na $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Podoba Ci się ten look?';

  @override
  String get sharedOutfitCtaBody => 'Twórz podobne stylizacje z własnej szafy.';

  @override
  String get sharedOutfitCtaButton => 'Pobierz FitCheck AI';

  @override
  String get errorTitle => 'Błąd';

  @override
  String get errorUnknown => 'Wystąpił nieoczekiwany błąd';

  @override
  String get errorNoConnection => 'Brak połączenia z internetem. Sprawdź sieć.';

  @override
  String get errorTimeout => 'Przekroczono czas oczekiwania. Spróbuj ponownie.';

  @override
  String get errorServerError =>
      'Coś poszło nie tak po naszej stronie. Spróbuj ponownie.';

  @override
  String get errorBadGateway =>
      'Nasz serwer jest chwilowo niedostępny. Spróbuj ponownie.';

  @override
  String get errorServiceUnavailable =>
      'Usługa jest tymczasowo niedostępna. Spróbuj za chwilę.';

  @override
  String get errorInternalError => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get errorUnauthorized => 'Zaloguj się, aby kontynuować.';

  @override
  String get errorForbidden => 'Brak dostępu.';

  @override
  String get errorSessionExpired => 'Sesja wygasła. Zaloguj się ponownie.';

  @override
  String get errorInvalidCredentials => 'Niepoprawny e-mail lub hasło.';

  @override
  String get errorTokenRefreshFailed =>
      'Nie udało się odświeżyć sesji. Zaloguj się ponownie.';

  @override
  String get errorRequestCancelled => 'Żądanie anulowane.';

  @override
  String get errorInvalidFormat => 'Format pliku nie jest obsługiwany.';

  @override
  String get errorFileTooLarge => 'Plik jest za duży.';

  @override
  String get errorUploadFailed =>
      'Przesyłanie nie powiodło się. Spróbuj ponownie.';

  @override
  String get errorCacheCorrupted =>
      'Zapisane dane zostały uszkodzone i zresetowane.';

  @override
  String get errorCacheNotFound => 'Nic jeszcze nie zapisano.';

  @override
  String get errorUserNotFound => 'Nie znaleziono takiego konta.';

  @override
  String get errorItemNotFound => 'Ten element już nie istnieje.';

  @override
  String get errorOutfitNotFound => 'Ta stylizacja już nie istnieje.';

  @override
  String get rewardsTitle => 'Nagrody';

  @override
  String get rewardsNoAchievementsTitle => 'Brak osiągnięć';

  @override
  String get rewardsNoAchievementsBody =>
      'Dodawaj rzeczy i planuj stylizacje, aby zdobyć pierwsze.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Brak wpisów w rankingu';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planuj stylizacje, aby zdobywać punkty i pojawić się tutaj.';

  @override
  String get legalViewPrivacyPolicy => 'Polityka prywatności';

  @override
  String get aiConsentAgree => 'Zgadzam się i kontynuuję';

  @override
  String get aiConsentNotNow => 'Nie teraz';

  @override
  String get imageViewerCloseTooltip => 'Zamknij podgląd zdjęcia';

  @override
  String get updateReadyTitle => 'Aktualizacja gotowa';

  @override
  String get updateReadyBody =>
      'Uruchom ponownie FitCheck AI, aby zastosować najnowsze ulepszenia.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI potrzebuje dostępu do aparatu, aby robić zdjęcia Twoich stylizacji i ubrań.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI potrzebuje dostępu do biblioteki zdjęć, aby wybrać zdjęcia Twoich stylizacji i ubrań.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI potrzebuje możliwości zapisu wygenerowanych przez sztuczną inteligencję zdjęć stylizacji do Twojej biblioteki.';

  @override
  String get wardrobeSomePhotosSkipped => 'Pominięto niektóre zdjęcia';

  @override
  String get wardrobePhotosNotAdded => 'Nie dodano zdjęć';

  @override
  String get wardrobePhotoNotAdded => 'Nie dodano zdjęcia';

  @override
  String get wardrobeNotStartedTitle => 'Nie rozpoczęto';

  @override
  String get wardrobeNoRoomTitle => 'Brak miejsca';

  @override
  String get wardrobeAddPhotosSemantic => 'Dodaj zdjęcia';

  @override
  String get batchAddTileLabel => 'Dodaj';

  @override
  String get batchProfileLinkLabel => 'Link do profilu';

  @override
  String get wardrobeImportFromProfileTitle => 'Importuj z profilu';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Dodaj kilka zdjęć';

  @override
  String get wardrobeClearAction => 'Wyczyść';

  @override
  String get wardrobeRefreshTooltip => 'Odśwież';

  @override
  String get batchNoPhotosYetTitle => 'Brak zdjęć';

  @override
  String get batchChoosePhotosAction => 'Wybierz zdjęcia';

  @override
  String get batchWeFindEachPieceBody =>
      'Znajdziemy każdy element i utworzymy jego zdjęcie studyjne.';

  @override
  String get batchPreparingPhotosSemantic => 'Przygotowywanie zdjęć';

  @override
  String get batchPhotosProcessedSemantic => 'Przetworzone zdjęcia';

  @override
  String get batchPasteProfileLinkTitle => 'Wklej link do profilu';

  @override
  String get batchPasteProfileLinkBody =>
      'Publiczny profil na Instagramie lub Facebooku. Przeskanujemy jego zdjęcia, a Ty wybierzesz, co trafia do Twojej szafy.';

  @override
  String get batchClearLinkTooltip => 'Wyczyść link';

  @override
  String get batchStartingButton => 'Uruchamianie';

  @override
  String get batchStartImportAction => 'Rozpocznij import';

  @override
  String get batchReviewEveryPhotoTitle => 'Sprawdzasz każde zdjęcie';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nic nie zostanie dodane, dopóki tego nie zatwierdzisz.';

  @override
  String get batchPrivateProfilesTitle => 'Profile prywatne';

  @override
  String get batchPrivateProfilesBody =>
      'Połącz swoje konto. Instagram wymaga również nazwy użytkownika i hasła.';

  @override
  String get batchUseAnotherLinkAction => 'Użyj innego linku';

  @override
  String get batchSignInNeededTitle => 'Wymagane logowanie';

  @override
  String get batchEnterYourCodeTitle => 'Wprowadź kod';

  @override
  String get batchUseUsernamePasswordAction => 'Użyj nazwy użytkownika i hasła';

  @override
  String get batchAlreadyConnectedAction => 'Połączono już w przeglądarce';

  @override
  String get batchEnterCodeAction => 'Wprowadź kod';

  @override
  String get batchTryAnotherWayAction => 'Spróbuj inaczej';

  @override
  String get batchLiveStatus => 'Na żywo';

  @override
  String get batchReconnectingStatus => 'Ponowne łączenie';

  @override
  String get batchSignInToInstagramTitle => 'Zaloguj się do Instagrama';

  @override
  String get batchUsernameLabel => 'Nazwa użytkownika';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kod, jeśli używasz weryfikacji dwuetapowej';

  @override
  String get batchAuthenticatorCodeBody =>
      'Użyj 6-cyfrowego kodu z aplikacji uwierzytelniającej. Kody szybko się zmieniają.';

  @override
  String get batchVerifyAction => 'Zweryfikuj';

  @override
  String get batchFindingPhotosTitle => 'Wyszukiwanie zdjęć';

  @override
  String get batchImportPausedTitle => 'Wstrzymano import';

  @override
  String get batchProcessingPhotosTitle => 'Przetwarzanie zdjęć';

  @override
  String get batchWaitingNextPhoto => 'Oczekiwanie na kolejne zdjęcie';

  @override
  String get batchCancelImportAction => 'Anuluj import';

  @override
  String get batchNoPiecesInPhotoBody => 'Nie znaleziono ubrań na tym zdjęciu.';

  @override
  String get batchEditPieceColoursLabel => 'Kolory rozdzielone przecinkami';

  @override
  String get batchAddToClosetAction => 'Dodaj do szafy';

  @override
  String get batchSkipPhotoAction => 'Pomiń zdjęcie';

  @override
  String get batchImportCompleteTitle => 'Import zakończony';

  @override
  String get batchImportFailedTitle => 'Import nie powiódł się';

  @override
  String get batchImportCancelledTitle => 'Anulowano import';

  @override
  String get batchImportErrorBody => 'Coś poszło nie tak podczas importu.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nie zimportowano nic więcej z tego profilu.';

  @override
  String get batchViewClosetAction => 'Zobacz szafę';

  @override
  String get batchStartOverAction => 'Zacznij od nowa';

  @override
  String get wardrobeAddPieceTitle => 'Dodaj element';

  @override
  String get wardrobeAddDetailsTitle => 'Dodaj szczegóły';

  @override
  String get wardrobeScanningTitle => 'Skanowanie';

  @override
  String get batchReviewPiecesTitle => 'Sprawdź elementy';

  @override
  String get wardrobeGalleryAction => 'Galeria';

  @override
  String get wardrobeCameraAction => 'Aparat';

  @override
  String get wardrobeNewBadge => 'Nowość';

  @override
  String get wardrobeRemovePhotoTooltip => 'Usuń zdjęcie';

  @override
  String get batchRunInBackgroundTooltip => 'Działaj w tle';

  @override
  String get batchStepOneOfTwo => 'Krok 1 z 2';

  @override
  String get batchStepTwoOfTwo => 'Krok 2 z 2';

  @override
  String get batchUploadingPhotosTitle => 'Wysyłanie zdjęć';

  @override
  String get batchFindingPiecesTitle => 'Wyszukiwanie elementów';

  @override
  String get batchMakingStudioPhotosTitle => 'Tworzenie zdjęć studyjnych';

  @override
  String get batchStoppedLabel => 'Zatrzymano';

  @override
  String get batchFindingPiecesStoppedTitle => 'Zatrzymano wyszukiwanie';

  @override
  String get batchCancelledLabel => 'Anulowano';

  @override
  String get batchAllDoneTitle => 'Gotowe';

  @override
  String get batchOpeningPiecesBody => 'Otwieranie elementów';

  @override
  String get batchNothingSavedBody => 'Nic nie zapisano.';

  @override
  String get batchFindingPiecesFailedBody => 'Wyszukiwanie nie powiodło się.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Wyszukiwanie przerwano wcześniej.';

  @override
  String get batchStopFindingPiecesTitle => 'Zatrzymać wyszukiwanie?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skan zostanie przerwany i nic nie zostanie zapisane. Znalezione elementy pozostaną w aktywności, dopóki ich nie odrzucisz.';

  @override
  String get batchKeepGoingAction => 'Kontynuuj';

  @override
  String get batchTryAgainAction => 'Spróbuj ponownie';

  @override
  String get batchBackToPhotosAction => 'Wróć do zdjęć';

  @override
  String get batchSkipAllAction => 'Pomiń wszystko';

  @override
  String get batchIncludeAllAction => 'Dołącz wszystkie';

  @override
  String get batchNoPiecesFoundTitle => 'Nie znaleziono ubrań';

  @override
  String get batchNoPiecesFoundBody =>
      'Nie znaleźliśmy ubrań na tych zdjęciach.';

  @override
  String get batchChooseOtherPhotosAction => 'Wybierz inne zdjęcia';

  @override
  String get batchUseCaseHelper => 'Dodane do każdego zapisanego elementu.';

  @override
  String get batchDiscardPiecesTitle => 'Odrzucić te elementy?';

  @override
  String get batchDiscardPiecesBody => 'Nic z tej serii nie zostało zapisane.';

  @override
  String get batchKeepAction => 'Zachowaj';

  @override
  String get batchDiscardAction => 'Odrzuć';

  @override
  String get batchRemovePieceTitle => 'Usunąć ten element?';

  @override
  String get batchRemovePieceBody => 'Nie został zapisany w szafie.';

  @override
  String get batchRemoveAction => 'Usuń';

  @override
  String get batchChoosePiecesToSave => 'Wybierz elementy do zapisu';

  @override
  String get batchDiscardAllAction => 'Odrzuć wszystkie';

  @override
  String get batchNothingSavedRetryBody =>
      'Nic nie zapisano. Spróbuj ponownie.';

  @override
  String get batchNotSavedTitle => 'Nie zapisano';

  @override
  String get batchSavingLabel => 'Zapisywanie';

  @override
  String get batchSendToBackgroundAction => 'Przenieś do tła';

  @override
  String get batchStillWorkingMessage =>
      'Nadal pracujemy. Dam Ci znać, gdy Twoje ubrania będą gotowe.';

  @override
  String get batchRunningInBackgroundTitle => 'Działa w tle';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Tworzenie zdjęć studyjnych przerwano. Nadal możesz zapisać te elementy.';

  @override
  String get batchTapPieceToSkip => 'Stuknij element, aby go pominąć.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Zdjęcia studyjne są w drodze. Możesz wyjść – damy Ci znać.';

  @override
  String get batchLeaveAction => 'Wyjdź';

  @override
  String get batchPeopleInPhotosTitle => 'Osoby na zdjęciach';

  @override
  String get batchIncludeAction => 'Dołącz';

  @override
  String get batchSkipAction => 'Pomiń';

  @override
  String get batchYourPhotoIsUsedLabel => 'Użyto Twojego zdjęcia';

  @override
  String get batchMakingStudioPhotoLabel => 'Tworzenie zdjęcia studyjnego';

  @override
  String get batchNoStudioPhotoBody =>
      'Brak zdjęcia studyjnego. Użyto Twojego.';

  @override
  String get batchEnterDetailsYourselfAction => 'Wpisz dane samodzielnie';

  @override
  String get batchChooseAnotherPhotoAction => 'Wybierz inne zdjęcie';

  @override
  String get batchConnectionLostTitle => 'Brak połączenia';

  @override
  String get batchConnectionLostBody =>
      'Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get batchDailyLimitTitle => 'Osiągnięto dzienny limit';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Uaktualnij do Pro, aby zyskać więcej skanów, lub wpisz dane samodzielnie.';

  @override
  String get batchDailyLimitBodyFree =>
      'Twoje skany zresetują się jutro. Możesz teraz wpisać dane samodzielnie.';

  @override
  String get batchSeePlansAction => 'Zobacz plany';

  @override
  String get batchAiBusyTitle => 'Nasze AI jest zajęte';

  @override
  String get batchAiBusyBody =>
      'Problem leży po naszej stronie. Spróbuj ponownie za kilka minut.';

  @override
  String get batchNoPiecesBody =>
      'Spróbuj użyć wyraźniejszego zdjęcia lub wpisz dane samodzielnie.';

  @override
  String get batchScanningUnavailableTitle => 'Skanowanie jest niedostępne';

  @override
  String get batchScanningUnavailableBody =>
      'Na razie wpisz dane samodzielnie.';

  @override
  String get batchScanDidNotFinishTitle => 'Skan nie został ukończony';

  @override
  String get batchTryAgainBody => 'Spróbuj ponownie.';

  @override
  String get billingTitle => 'Subskrypcja';

  @override
  String get billingUpgradeHeading => 'Uaktualnij plan';

  @override
  String get billingUpgradeOnPlusBody => 'Te same funkcje, wyższe limity.';

  @override
  String get billingUpgradeBody =>
      'Plany Plus i Pro oferują te same funkcje. Wybierz limity, których potrzebujesz.';

  @override
  String get billingWebUnavailableBody =>
      'Uaktualnienia online nie są jeszcze dostępne. Kod promocyjny lub polecenia nadal odblokowują Plus lub Pro. Zapraszaj znajomych poniżej, aby zdobyć darmowe miesiące.';

  @override
  String get billingPlansStale =>
      'Nie udało się wczytać najnowszych planów. Ceny mogą być nieaktualne.';

  @override
  String get billingMonthly => 'Miesięcznie';

  @override
  String get billingYearly => 'Rocznie';

  @override
  String get billingCurrentPlan => 'Obecny plan';

  @override
  String get billingActive => 'Aktywny';

  @override
  String get billingThisMonth => 'W tym miesiącu';

  @override
  String get billingItemExtractions => 'Wydobyte elementy';

  @override
  String get billingOutfitVisualizations => 'Wizualizacje zestawów';

  @override
  String get billingNearLimitUpgrade =>
      'Zbliżasz się do miesięcznego limitu. Uaktualnij, aby zyskać więcej.';

  @override
  String get billingNearLimitResets =>
      'Zbliżasz się do miesięcznego limitu. Zresetuje się on na początku przyszłego miesiąca.';

  @override
  String get billingStoreUnavailable =>
      'Uaktualnienia nie są jeszcze dostępne w sklepie. Wróć wkrótce.';

  @override
  String get billingManageHeading => 'Zarządzaj planem';

  @override
  String get billingCancelPlan => 'Anuluj subskrypcję';

  @override
  String get billingCancelKeepsAccess =>
      'Zachowasz dostęp do końca obecnego okresu rozliczeniowego.';

  @override
  String get billingCancelConfirmTitle => 'Anulować subskrypcję?';

  @override
  String get billingKeepPlan => 'Zachowaj plan';

  @override
  String get billingCancelPlanAction => 'Anuluj plan';

  @override
  String get billingBilledMonthly => 'Rozliczane co miesiąc';

  @override
  String get billingBilledYearly => 'Rozliczane co rok';

  @override
  String get billingVirtualTryOn => 'Wirtualna przymierzalnia';

  @override
  String get billingPrioritySupport => 'Priorytetowe wsparcie';

  @override
  String get billingDisclosureProRenewing =>
      'Pro to subskrypcja odnawiająca się automatycznie';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus i Pro to subskrypcje odnawiające się automatycznie';

  @override
  String get billingDisclosureAppleBilling =>
      'Płatność zostanie pobrana z Twojego Apple ID po potwierdzeniu zakupu.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Płatność zostanie pobrana z Twojego konta Google Play po potwierdzeniu zakupu.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Subskrypcja odnawia się automatycznie na ten sam okres w tej samej cenie, chyba że wyłączysz automatyczne odnawianie co najmniej 24 godziny przed końcem bieżącego okresu.';

  @override
  String get billingDisclosureAppleManage =>
      'Zarządzaj lub anuluj w dowolnym momencie w Ustawienia › Twoje Apple ID › Subskrypcje.';

  @override
  String get billingDisclosureGoogleManage =>
      'Zarządzaj lub anuluj w dowolnym momencie w Google Play › Płatności i subskrypcje.';

  @override
  String get billingReferFriend => 'Poleć znajomemu';

  @override
  String get billingHowItWorks => 'Jak to działa';

  @override
  String get billingHowShareTitle => 'Udostępnij link';

  @override
  String get billingHowShareBody => 'Wyślij go znajomemu.';

  @override
  String get billingHowSignUpTitle => 'Znajomy się rejestruje';

  @override
  String get billingHowSignUpBody => 'Twój znajomy dołącza z linku.';

  @override
  String get billingHowBothTitle => 'Obaj dostajecie Pro';

  @override
  String get billingHowBothBody => 'Oboje otrzymujecie miesiąc Pro za darmo.';

  @override
  String get billingYourReferrals => 'Twoje polecenia';

  @override
  String get billingInvited => 'Zaprošeni';

  @override
  String get billingJoined => 'Dołączyli';

  @override
  String get billingMonthsEarned => 'Zdobyte miesiące';

  @override
  String get billingInviteFriend => 'Zaproś znajomego';

  @override
  String get billingInviteBody => 'Ty i Twój znajomy otrzymacie miesiąc Pro.';

  @override
  String get billingYourCode => 'Twój kod';

  @override
  String get billingCopyLink => 'Kopiuj link';

  @override
  String get billingShareInvite => 'Udostępnij zaproszenie';

  @override
  String get giftUnavailable =>
      'Zaproszenia w prezencie są niedostępne w tej wersji.';

  @override
  String get giftPageTitle => 'Podaruj FitCheck Pro';

  @override
  String get giftNoAllowances => 'Brak darmowych zaproszeń w prezencie.';

  @override
  String get giftFormTitle => 'Wyślij darmowe zaproszenie';

  @override
  String get giftFormBody =>
      'Obdarowana osoba odbiera prezent za pomocą tego zweryfikowanego adresu e-mail. Nie wysyłamy wiadomości w Twoim imieniu.';

  @override
  String get giftFieldFrom => 'Od';

  @override
  String get giftFieldRecipientName => 'Imię odbiorcy';

  @override
  String get giftFieldRecipientEmail => 'E-mail odbiorcy';

  @override
  String get giftFieldOccasion => 'Okazja (opcjonalnie)';

  @override
  String get giftNoOccasion => 'Brak okazji';

  @override
  String get giftOccasionBirthday => 'Urodziny';

  @override
  String get giftOccasionAnniversary => 'Rocznica';

  @override
  String get giftOccasionOther => 'Inna';

  @override
  String get giftFieldCardGreeting => 'Treść życzeń';

  @override
  String get giftFieldCardGreetingHelper =>
      'Pojawi się na kartce dokładnie w tej formie.';

  @override
  String get giftFieldPrivateNote => 'Prywatna notatka (opcjonalnie)';

  @override
  String get giftCreateAction => 'Utwórz darmowy prezent';

  @override
  String get giftClaimedTitle => 'Prezent odebrany';

  @override
  String get giftClaimedActive => 'Twój prezent FitCheck Pro jest aktywny.';

  @override
  String get giftClaimedQueued =>
      'Twój prezent FitCheck Pro zaczniesz po zakończeniu obecnego dostępu.';

  @override
  String get giftLinkCopied => 'Skopiowano link do schowka.';

  @override
  String get giftErrorName => 'Wpisz imię.';

  @override
  String get giftErrorEmail => 'Wpisz poprawny adres e-mail.';

  @override
  String get giftErrorGreeting => 'Wpisz treść życzeń.';

  @override
  String get giftErrorGreetingLength => 'Użyj maksymalnie 80 znaków.';

  @override
  String get giftClaimAction => 'Odbierz prezent';

  @override
  String get giftCardPreview => 'Podgląd karty';

  @override
  String get giftGiftForYou => 'Prezent dla Ciebie';

  @override
  String get giftGiftWaiting => 'Prezent czeka na Ciebie';

  @override
  String get giftOpenBody =>
      'Otwórz prezenty, aby je odebrać za pomocą zweryfikowanego adresu e-mail.';

  @override
  String get giftOpenGifts => 'Otwórz prezenty';

  @override
  String get giftSendInvitation => 'Wyślij zaproszenie';

  @override
  String get settingsAiProviderSection => 'Dostawca';

  @override
  String get settingsAiCustom => 'Niestandardowy';

  @override
  String get settingsAiUrlHelper =>
      'Użyj publicznego adresu URL dostępnego dla serwera. Adres localhost nie działa z naszych serwerów.';

  @override
  String get settingsAiConnectionSection => 'Połączenie';

  @override
  String get settingsAiApiUrl => 'Adres URL API';

  @override
  String get settingsAiApiKey => 'Klucz API';

  @override
  String get settingsAiApiKeySaved => 'Zapisano. Pozostaw puste, aby zachować.';

  @override
  String get settingsAiChatModel => 'Model czatu';

  @override
  String get settingsAiVisionModel => 'Model wizyjny (opcjonalnie)';

  @override
  String get settingsAiImageModel => 'Model obrazu (opcjonalnie)';

  @override
  String get settingsAiImageModelNote =>
      'Generowanie obrazu wymaga uzupełnień czatu kompatybilnych z OpenAI z response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testuj połączenie';

  @override
  String get calendarTitle => 'Kalendarz';

  @override
  String get calendarGoToToday => 'Przejdź do dzisiaj';

  @override
  String get calendarConnectTooltip => 'Połącz kalendarz';

  @override
  String get calendarAddEvent => 'Dodaj wydarzenie';

  @override
  String get calendarEmptyTitle => 'Brak planów';

  @override
  String get calendarEmptyBody =>
      'Dodaj wydarzenie i zaplanuj co na siebie włożyć.';

  @override
  String get calendarPreviousMonth => 'Poprzedni miesiąc';

  @override
  String get calendarNextMonth => 'Następny miesiąc';

  @override
  String get calendarAllDay => 'Cały dzień';

  @override
  String get calendarOutfitLinked => 'Powiązany strój';

  @override
  String get calendarEventOptions => 'Opcje wydarzenia';

  @override
  String get calendarDeleteTitle => 'Usunąć to wydarzenie?';

  @override
  String get calendarChangeOutfit => 'Zmień zestaw';

  @override
  String get calendarLinkOutfit => 'Połącz z zestawem';

  @override
  String get calendarRemoveOutfit => 'Usuń zestaw';

  @override
  String get calendarNewEvent => 'Nowe wydarzenie';

  @override
  String get calendarEditEvent => 'Edytuj wydarzenie';

  @override
  String get calendarTitleLabel => 'Tytuł';

  @override
  String get calendarTitleRequired => 'Dodaj tytuł';

  @override
  String get calendarEndBeforeStart => 'Koniec po czasie rozpoczęcia';

  @override
  String get calendarStarts => 'Początek';

  @override
  String get calendarEnds => 'Koniec';

  @override
  String get calendarPlaceOptional => 'Miejsce (opcjonalnie)';

  @override
  String get calendarNotesOptional => 'Notatki (opcjonalnie)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Stwórz zestaw, a następnie połącz go z tym wydarzeniem.';

  @override
  String get calendarBuildOutfit => 'Stwórz zestaw';

  @override
  String get calendarConnectionsTitle => 'Kalendarze';

  @override
  String get calendarConnectionsBody =>
      'Wydarzenia dodane tutaj pozostają w FitCheck.';

  @override
  String get calendarDisconnect => 'Odłącz';

  @override
  String get calendarNotAvailable => 'Niedostępne';

  @override
  String get profileSectionExplore => 'Odkrywaj';

  @override
  String get profileNavTryOn => 'Przymierzalnia';

  @override
  String get profileNavRewards => 'Nagrody';

  @override
  String get profileSupport => 'Wsparcie';

  @override
  String get profileHelp => 'Pomoc';

  @override
  String get profileAbout => 'O aplikacji';

  @override
  String get profileAboutBody =>
      'Twoja szafa, zestawy i plany w jednym miejscu.';

  @override
  String get profileSignOutTitle => 'Wylogować się?';

  @override
  String get profileSignOutBody =>
      'Możesz zalogować się ponownie w dowolnym momencie.';

  @override
  String get profileEditTitle => 'Edytuj profil';

  @override
  String get profileYourProfile => 'Twój profil';

  @override
  String get profileBodyProfiles => 'Profile sylwetki';

  @override
  String get profileBodyEmptyTitle => 'Brak profili sylwetki';

  @override
  String get profileBodyEmptyBody =>
      'Dodaj wzrost i budowę, aby uzyskać lepsze dopasowanie.';

  @override
  String get profileBodyAdd => 'Dodaj profil';

  @override
  String get profileBodyDefaultNote =>
      'Twój domyślny profil jest używany do dopasowywania i przymiarki.';

  @override
  String get profileBodyDefaultBadge => 'Domyślny';

  @override
  String get profileBodyMakeDefault => 'Ustaw jako domyślny';

  @override
  String get profileBodyDeleteBody => 'Ta operacja jest nieodwracalna.';

  @override
  String get profileBodyRequired => 'Wymagane';

  @override
  String get profileBodyCheckNumber => 'Sprawdź tę liczbę';

  @override
  String get profileBodyNew => 'Nowy profil sylwetki';

  @override
  String get profileBodyNameHint => 'Na przykład Ja';

  @override
  String get profileBodyHeight => 'Wzrost';

  @override
  String get profileBodyWeight => 'Waga';

  @override
  String get profileBodyBuild => 'Budowa ciała';

  @override
  String get profileBodySkinTone => 'Odcień skóry';

  @override
  String get profileBirthDateNeededBody =>
      'Dodaj datę urodzenia, aby pasowała do godziny urodzenia.';

  @override
  String get profileBirthDateNeededTitle => 'Wymagana data urodzenia';

  @override
  String get profilePartlySavedBody =>
      'Zapisano imię i zdjęcie. Szczegóły urodzenia nie zostały zapisane, spróbuj ponownie później.';

  @override
  String get profilePartlySavedTitle => 'Zapisano częściowo';

  @override
  String get profileSavedBody => 'Profil został zapisany.';

  @override
  String get profileChangePhoto => 'Zmień zdjęcie profilowe';

  @override
  String get profilePhotoLabel => 'Zdjęcie profilowe';

  @override
  String get profilePhotoHint => 'Stuknij, aby wybrać nowe';

  @override
  String get profileBirthDateLabel => 'Data urodzenia (opcjonalnie)';

  @override
  String get profileBirthTimeLabel => 'Godzina urodzenia (opcjonalnie)';

  @override
  String get profileBirthTimeHelper =>
      'Czyni sugestie wedyjskie dokładniejszymi';

  @override
  String get profileBirthPlaceLabel => 'Miejsce urodzenia (opcjonalnie)';

  @override
  String get profileBirthPlaceHint => 'Na przykład Warszawa, Polska';

  @override
  String get profileHelpContactTitle => 'Zadaj nam pytanie';

  @override
  String get profileHelpContactBody =>
      'Wiadomość wyślesz nam tutaj, a my odpowiadamy zazwyczaj w ciągu dnia.';

  @override
  String get profileHelpContactAction => 'Skontaktuj się z wsparciem';

  @override
  String get profileHelpFaqTitle => 'Częste pytania';

  @override
  String get profileFaqAddPiecesTitle => 'Jak dodać ubrania do szafy?';

  @override
  String get profileFaqAddPiecesBody =>
      'Stuknij Dodaj w zakładce Szafa. Zrób zdjęcie lub wybierz je z galerii, a my znajdziemy każdą rzecz i oznaczymy ją za Ciebie.';

  @override
  String get profileFaqMatchingTitle => 'Jak działa dobieranie stylizacji?';

  @override
  String get profileFaqMatchingBody =>
      'Otwórz Dla Ciebie i wybierz posiadane ubrania. Podpowiemy, co do nich pasuje i skompletujemy pełne zestawy z Twojej szafy.';

  @override
  String get profileFaqTryOnTitle =>
      'Czy mogę przymierzać ubrania na swoich zdjęciach?';

  @override
  String get profileFaqTryOnBody =>
      'Tak. Dodaj swoje zdjęcie w pełnej postaci, a następnie wybierz ubrania, aby zobaczyć je na sobie.';

  @override
  String get profileFaqRewardsTitle => 'Jak zdobywać nagrody?';

  @override
  String get profileFaqRewardsBody =>
      'Planuj i zapisuj stylizacje. Serie i osiągnięcia rosną w miarę korzystania z aplikacji.';

  @override
  String get profileFaqPrivacyTitle => 'Czy moja szafa jest prywatna?';

  @override
  String get profileFaqPrivacyBody =>
      'Tak. Twoja szafa i stylizacje są prywatne, chyba że udostępnisz link do konkretnego zestawu.';

  @override
  String get profileHelpMoreTitle => 'Więcej pomocy';

  @override
  String get profileHelpGuides => 'Poradniki';

  @override
  String get profileHelpGuidesBody => 'Jak działa każda funkcja';

  @override
  String get feedbackCategoryBug => 'Coś nie działa';

  @override
  String get feedbackCategoryIdea => 'Pomysł';

  @override
  String get feedbackCategoryGeneral => 'Ogólne';

  @override
  String get feedbackCategoryHelp => 'Potrzebuję pomocy';

  @override
  String get feedbackHintBug =>
      'Co się stało i czego oczekiwałeś? Kroki pomogą nam to naprawić.';

  @override
  String get feedbackHintIdea => 'Czego potrzebujesz i dlaczego?';

  @override
  String get feedbackHintGeneral => 'Podziel się opinią lub zadaj pytanie.';

  @override
  String get feedbackAttachmentLimitBody => 'Możesz dodać maksymalnie 5 zdjęć.';

  @override
  String get feedbackAttachmentLimitTitle => 'Osiągnięto limit';

  @override
  String get feedbackImageTooLargeBody =>
      'Wybierz zdjęcie o wadze poniżej 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Za duże zdjęcie';

  @override
  String get feedbackTitle => 'Wyślij opinię';

  @override
  String get feedbackAboutLabel => 'Czego dotyczy?';

  @override
  String get feedbackSubjectLabel => 'Temat';

  @override
  String get feedbackSubjectRequired => 'Dodaj temat';

  @override
  String get feedbackSubjectTooShort => 'Temat musi mieć co najmniej 3 znaki';

  @override
  String get feedbackDetailsLabel => 'Szczegóły';

  @override
  String get feedbackDetailsRequired => 'Dodaj szczegóły';

  @override
  String get feedbackDetailsTooShort => 'Opis musi mieć co najmniej 10 znaków';

  @override
  String get feedbackAddScreenshot => 'Dodaj zrzut ekranu';

  @override
  String get feedbackAttachmentHint => 'Maksymalnie 5, po 5 MB każdy';

  @override
  String get feedbackSend => 'Wyślij';

  @override
  String get feedbackEmptyTitle => 'Nic jeszcze nie wysłano';

  @override
  String get feedbackEmptyBody =>
      'Twoje zgłoszenia i ich status pojawią się tutaj.';

  @override
  String get feedbackHistoryTitle => 'Twoje zgłoszenia';

  @override
  String get feedbackStatusOpen => 'Otwarte';

  @override
  String get feedbackStatusInProgress => 'W toku';

  @override
  String get feedbackStatusResolved => 'Rozwiązane';

  @override
  String get feedbackStatusClosed => 'Zamknięte';

  @override
  String get legalIntro =>
      'Jak chronimy Twoje dane i warunki korzystania z FitCheck AI.';

  @override
  String get legalPolicies => 'Zasady';

  @override
  String get legalPrivacySubtitle => 'Co zbieramy i dlaczego';

  @override
  String get legalTermsTitle => 'Regulamin';

  @override
  String get legalTermsSubtitle => 'Zasady korzystania z aplikacji';

  @override
  String get legalLicences => 'Licencje open-source';

  @override
  String get legalSupportSubtitle =>
      'Pomoc, kontakt i wnioski dotyczące prywatności';

  @override
  String get legalReportAbuse => 'Zgłoś problem lub nadużycie';

  @override
  String get permissionCameraTitle => 'Dostęp do aparatu';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI używa aparatu do robienia zdjęć ubrań i stylizacji na potrzeby przymierzalni AI i organizacji szafy.';

  @override
  String get permissionPhotoTitle => 'Dostęp do zdjęć';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI potrzebuje dostępu do zdjęć, aby można było wybrać zdjęcia ubrań i stylizacji dla funkcji AI oraz szafy.';

  @override
  String get permissionNotNow => 'Nie teraz';

  @override
  String get permissionOpenSettings => 'Otwórz ustawienia';

  @override
  String authSignedInAs(String name) {
    return 'Zalogowano jako $name';
  }

  @override
  String get authSignedIn => 'Zalogowano';

  @override
  String get authWelcomeBackTitle => 'Witaj ponownie';

  @override
  String get authSignInFailed => 'Logowanie nie powiodło się';

  @override
  String get authWelcomeTitle => 'Witaj';

  @override
  String get authSignUpFailed => 'Rejestracja nie powiodła się';

  @override
  String get authGoogleSignInFailed =>
      'Logowanie przez Google nie powiodło się';

  @override
  String get authAppleSignInFailed => 'Logowanie przez Apple nie powiodło się';

  @override
  String get authConfirmEmailTitle => 'Potwierdź adres e-mail';

  @override
  String get authConfirmEmailBody =>
      'Sprawdź skrzynkę odbiorczą i potwierdź e-mail, a następnie się zaloguj.';

  @override
  String get authClosetReady => 'Twoja szafa jest gotowa.';

  @override
  String get authSignedOutTitle => 'Wylogowano';

  @override
  String get authSignedOutBody => 'Jesteś wylogowany.';

  @override
  String get authSignOutFailed => 'Wylogowanie nie powiodło się';

  @override
  String get authEmailSentTitle => 'Wysłano e-mail';

  @override
  String get authResetLinkSent =>
      'Sprawdź e-mail, aby uzyskać link do resetowania.';

  @override
  String get authPasswordUpdatedTitle => 'Zaktualizowano hasło';

  @override
  String get authPasswordUpdated => 'Twoje hasło zostało zaktualizowane.';

  @override
  String get authPasswordNotUpdated => 'Nie zaktualizowano hasła';

  @override
  String get authCouldNotSendEmail => 'Nie udało się wysłać e-maila';

  @override
  String get authEmailNotSent => 'Nie wysłano e-maila';

  @override
  String get authResendSentBody => 'Wysłaliśmy nowy e-mail z potwierdzeniem.';

  @override
  String get outfitPreviewWithAi => 'Podgląd z AI';

  @override
  String get outfitNewPreview => 'Nowy podgląd';

  @override
  String get outfitBuilderClosetHeading => 'Twoja szafa';

  @override
  String get outfitBuilderSearchHint => 'Szukaj elementów';

  @override
  String get outfitClearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get outfitBuilderAddPiecesTitle => 'Najpierw dodaj elementy';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Stroje tworzą się z elementów w Twojej szafie.';

  @override
  String get outfitBuilderNoMatches => 'Brak dopasowanych elementów.';

  @override
  String get outfitNameLabel => 'Nazwa stroju';

  @override
  String get outfitNameHint => 'Np. Weekendowy len';

  @override
  String get outfitPreviewSemantic => 'Podgląd stroju z AI';

  @override
  String get outfitChoosePieces => 'Wybierz elementy';

  @override
  String get outfitTapPiecesHint => 'Dotknij elementów poniżej, aby je dodać.';

  @override
  String get outfitShareTooltip => 'Udostępnij';

  @override
  String get outfitSaveFavourite => 'Zapisz do ulubionych';

  @override
  String get outfitPiecesHeading => 'Elementy';

  @override
  String get outfitWearHistoryEmpty => 'Załóż raz, a daty pojawią się tutaj.';

  @override
  String get outfitWearHistoryTitle => 'Historia noszenia';

  @override
  String get outfitWearHistoryError => 'Nie udało się wczytać dat.';

  @override
  String get outfitWornOn => 'Noszono';

  @override
  String get outfitEditTitle => 'Edytuj strój';

  @override
  String get outfitSavedPhotosFailed => 'Zapisano dane, nie zapisano zdjęć';

  @override
  String get outfitNoPhotosBody => 'Brak zdjęć. Strój pokazuje jego elementy.';

  @override
  String get outfitOccasionLabel => 'Okazja';

  @override
  String get outfitOccasionNone => 'Brak';

  @override
  String get outfitTagsHint => 'Oddziel przecinkami';

  @override
  String get outfitDraftBody => 'Ukryty z głównej listy';

  @override
  String get outfitPublic => 'Publiczny';

  @override
  String get outfitPublicBody => 'Każdy z linkiem może go zobaczyć';

  @override
  String get outfitDeleteFromDetail =>
      'Usuń ten strój z jego strony szczegółów.';

  @override
  String get outfitNewCollection => 'Nowa kolekcja';

  @override
  String get outfitNoCollectionsTitle => 'Brak kolekcji';

  @override
  String get outfitNoCollectionsBody =>
      'Grupuj stroje według wyjazdu, pory roku lub nastroju.';

  @override
  String get outfitCreateCollection => 'Utwórz kolekcję';

  @override
  String get outfitAddOutfits => 'Dodaj stroje';

  @override
  String get outfitRename => 'Zmień nazwę';

  @override
  String get outfitCollectionDeleteBody =>
      'Stroje w kolekcji zostaną zachowane.';

  @override
  String get outfitCollectionsNotLoaded => 'Stroje nie zostały załadowane';

  @override
  String get outfitRenameCollection => 'Zmień nazwę kolekcji';

  @override
  String get outfitDescriptionOptional => 'Opis (opcjonalnie)';

  @override
  String get outfitAllInCollection => 'Wszystkie stroje są już w tej kolekcji.';

  @override
  String get photoshootSubtitleUpload => 'Studio portretów z Twoich zdjęć';

  @override
  String get photoshootSubtitleConfigure => 'Wybierz styl, format i liczbę';

  @override
  String get photoshootSubtitleGenerating => 'To zajmie minutę lub dwie';

  @override
  String get photoshootAddPhotosSemantic => 'Dodaj zdjęcia z galerii';

  @override
  String get photoshootUploadTitle => 'Dodaj 1–4 zdjęcia siebie';

  @override
  String get photoshootUploadBody => 'Dotknij, aby wybrać z galerii';

  @override
  String get photoshootAddToContinue => 'Dodaj zdjęcie, aby kontynuować';

  @override
  String get photoshootAddAnotherPhoto => 'Dodaj kolejne zdjęcie';

  @override
  String get photoshootTipsTitle => 'Dla najlepszych efektów';

  @override
  String get photoshootTipsBody =>
      'Użyj wyraźnych, dobrze oświetlonych zdjęć twarzy z różnych kątów. Wyklucz okulary przeciwsłoneczne i nakrycia głowy.';

  @override
  String get photoshootStarting => 'Rozpoczynanie';

  @override
  String get photoshootCancelling => 'Anulowanie';

  @override
  String get photoshootFailed => 'Niepowodzenie';

  @override
  String get recommendTabMatches => 'Dopasowania';

  @override
  String get recommendTabComplete => 'Komplet';

  @override
  String get recommendTabWeather => 'Pogoda';

  @override
  String get recommendTabColours => 'Kolory';

  @override
  String get recommendTabShop => 'Sklep';

  @override
  String get recommendNoMatchesTitle => 'Brak dopasowań';

  @override
  String get recommendNoMatchesBody =>
      'Wybierz jeden element, a znajdziemy do niego dopasowanie.';

  @override
  String get recommendPickPiece => 'Wybierz element';

  @override
  String get recommendNothingMatchesTitle => 'Brak dopasowań';

  @override
  String get recommendNothingMatchesBody =>
      'Wypróbuj inne elementy lub dodaj więcej do swojej szafy.';

  @override
  String get recommendChangePieces => 'Zmień elementy';

  @override
  String get recommendDefaultReason => 'Dobrze pasuje do wybranych elementów.';

  @override
  String get recommendCompleteTitle => 'Uzupełnij stylizację';

  @override
  String get recommendCompleteBody =>
      'Wybierz jeden element, a uzupełnimy resztę.';

  @override
  String get recommendWorking => 'Przetwarzanie';

  @override
  String get recommendGenerate => 'Generuj';

  @override
  String get recommendChooseStyleBody => 'Wybierz styl, a następnie generuj.';

  @override
  String get recommendNoLooksTitle => 'Brak stylizacji dla tych elementów';

  @override
  String get recommendNoLooksBody => 'Wypróbuj inny styl lub inne elementy.';

  @override
  String get recommendDefaultLook => 'Stylizacja z Twoimi elementami';

  @override
  String get recommendNoPiecesBody => 'Brak elementów dla tej stylizacji.';

  @override
  String get recommendCityLabel => 'Miasto';

  @override
  String get recommendCheck => 'Sprawdź';

  @override
  String get recommendWeatherTitle => 'Jakie jest dziś powietrze?';

  @override
  String get recommendWeatherBody =>
      'Podaj miasto, aby otrzymać propozycje na dziś.';

  @override
  String get recommendWearToday => 'Noś dziś';

  @override
  String get recommendWeatherNoPieces =>
      'Brak elementów w szafie dla takich warunków pogodowych.';

  @override
  String get recommendBudgetLabel => 'Budżet do';

  @override
  String get recommendLooking => 'Szukasz';

  @override
  String get recommendFindWhatToBuy => 'Znajdź, co kupić';

  @override
  String get recommendFillGapsTitle => 'Uzupełnij braki';

  @override
  String get recommendFillGapsBody =>
      'Ustal budżet, a wskażemy, czego brakuje w Twojej szafie.';

  @override
  String get recommendNoGapsTitle => 'Brak luk';

  @override
  String get recommendNoGapsBody =>
      'Wypróbuj wyższy budżet lub inną kategorię.';

  @override
  String get recommendMoodEveryday => 'Na co dzień';

  @override
  String get recommendMoodBigMeeting => 'Ważne spotkanie';

  @override
  String get recommendDayLabel => 'Dzień';

  @override
  String get recommendReadingStars => 'Odczytanie znaków';

  @override
  String get recommendGetMyColours => 'Moi kolor';

  @override
  String get recommendLuckyColoursTitle => 'Twoje szczęśliwe kolory';

  @override
  String get recommendLuckyColoursBody =>
      'Wybierz dzień, a podpowiemy kolory i ubrania.';

  @override
  String get recommendLuckyColoursSection => 'Szczęśliwe kolory';

  @override
  String get recommendAvoidColoursSection => 'Kolory na rezerwie';

  @override
  String get recommendBirthDateTitle => 'Podaj datę urodzenia';

  @override
  String get recommendBirthDateBody =>
      'Potrzebujemy daty urodzenia, by odczytać kolory.';

  @override
  String get recommendEditProfile => 'Edytuj profil';

  @override
  String get recommendNothingThisDay => 'Brak na ten dzień.';

  @override
  String get recommendUnnamedColour => 'Nieznany kolor';

  @override
  String get recommendFromCloset => 'Z Twojej szafy';

  @override
  String get recommendNoPiecesInColours => 'Brak ubrań w tych kolorach.';

  @override
  String get recommendOutfitIdeas => 'Pomysły na stylizacje';

  @override
  String get recommendNoOutfitsInColours => 'Brak kompletów w tych kolorach.';

  @override
  String get recommendDefaultOutfitIdea => 'Pomysł na stylizację';

  @override
  String get recommendPickUpToThree => 'Wybierz do trzech elementów';

  @override
  String get recommendEmptyClosetBody =>
      'Najpierw dodaj ubrania, potem pasowania.';

  @override
  String get dashboardDressForDay => 'Przebierz się na nadchodzący dzień.';

  @override
  String get dashboardOutfitOfDay => 'Stylizacja dnia';

  @override
  String get dashboardFreshLook => 'Świeży look';

  @override
  String get subscriptionManageInStoreTitle => 'Zarządzaj w sklepie';

  @override
  String get subscriptionManageInStoreBody =>
      'Płatność za ten plan rozlicza sklep. Zarządzaj w ustawieniach konta.';

  @override
  String get subscriptionCancelledTitle => 'Subskrypcja anulowana';

  @override
  String get subscriptionCancelledBody =>
      'Plan pozostaje aktywny do końca okresu rozliczeniowego.';

  @override
  String get subscriptionCancelFailedTitle => 'Nie udało się anulować';

  @override
  String get subscriptionCouldNotOpenTitle => 'Nie udało się otworzyć';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Nie udało się otworzyć rozliczeń.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Nie udało się otworzyć linku.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Nie udało się załadować linku';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Nie udało się załadować linku polecania. Spróbuj ponownie.';

  @override
  String get subscriptionReferralCopiedTitle => 'Skopiowano';

  @override
  String get subscriptionReferralCopiedBody => 'Skopiowano link polecania.';

  @override
  String get subscriptionReferralShareSubject => 'Wypróbuj FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Dołącz do FitCheck AI i oboje zyskacie miesiąc Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Skopiowano link';

  @override
  String get subscriptionShareUnavailableBody =>
      'Udostępnianie jest niedostępne, więc skopiowaliśmy link.';

  @override
  String get subscriptionShareFailedTitle => 'Nie udało się udostępnić';

  @override
  String get subscriptionShareFailedBody => 'Skopiuj link z strony polecania.';

  @override
  String get subscriptionStoreReadyTitle => 'Sklep gotowy';

  @override
  String get subscriptionStoreReadyBody =>
      'Ceny w sklepie są dostępne. Możesz teraz ulepszyć subskrypcję.';

  @override
  String get purchaseFailedTitle => 'Nieudany zakup';

  @override
  String get purchaseUnavailableTitle => 'Zakup niedostępny';

  @override
  String get purchaseIapUnavailableBody =>
      'Zakupy w aplikacji są niedostępne na tym urządzeniu.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Ten plan nie jest jeszcze dostępny do zakupu.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Ten plan jest jeszcze niedostępny w sklepie. Sprawdź ponownie wkrótce.';

  @override
  String get purchaseStartFailedBody =>
      'Nie udało się rozpocząć zakupu. Spróbuj ponownie.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Rozliczenie nie zwróciło linku płatności.';

  @override
  String get purchasePendingTitle => 'Zakup oczekuje';

  @override
  String get purchasePendingBody =>
      'Twój zakup oczekuje na zatwierdzenie. Zostanie przyznany dostęp po zatwierdzeniu.';

  @override
  String get purchaseFailedBody => 'Zakup nie powiódł się. Spróbuj ponownie.';

  @override
  String get purchaseRestoredTitle => 'Przywrócono';

  @override
  String get purchaseRestoredBody => 'Twoje zakupy zostały przywrócone.';

  @override
  String get purchaseActiveTitle => 'Aktywna subskrypcja';

  @override
  String get purchaseActiveBody => 'Twoja subskrypcja jest aktywna. Witamy.';

  @override
  String get purchaseSignInRequiredTitle => 'Wymagane logowanie';

  @override
  String get purchaseSignInRequiredBody => 'Zaloguj się, aby zakończyć zakup.';

  @override
  String get purchaseErrorTitle => 'Błąd zakupu';

  @override
  String get purchaseInvalidTransactionBody =>
      'Zakup nie zawierał weryfikowalnego identyfikatora transakcji.';

  @override
  String get purchaseVerificationPendingTitle => 'Weryfikacja oczekuje';

  @override
  String get purchaseVerificationPendingBody =>
      'Nie mogliśmy zweryfikować Twojej zakupu w sklepie. Proces zakończy się automatycznie i nie zapłacisz dwukrotnie.';

  @override
  String get purchaseNotAppliedTitle => 'Zakup nie został dodany';

  @override
  String get purchaseNotAppliedBody =>
      'Nie udało się dodać zakupu do Twojego konta. Skontaktuj się z supportem. Nie kupuj ponownie.';

  @override
  String get purchaseRestoreFailedTitle => 'Przywracanie nie powiodło się';

  @override
  String get purchaseRestoreFailedBody =>
      'Nie udało się przywrócić zakupów. Spróbuj ponownie.';

  @override
  String get purchaseRecoveredActiveBody => 'Twoja subskrypcja jest aktywna.';

  @override
  String get purchaseCompleteTitle => 'Zakup zakończony';

  @override
  String get giftCreateFailedTitle => 'Nie udało się utworzyć prezentu';

  @override
  String get giftClaimFailedTitle => 'Nie udało się odebrać prezentu';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prezenty dla Ciebie',
      one: 'Masz prezent',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 miesiąc',
      '12': '1 rok',
      'other': '$months miesięcy',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining pozostałe',
      one: '1 pozostały',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender wysłał Ci $duration FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Prezent FitCheck Pro dla $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Od $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Dla $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Od $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'Twój odbiorca';

  @override
  String get giftPreviewPlaceholderSender => 'Ty';

  @override
  String get settingsSavedTitle => 'Zapisano';

  @override
  String get settingsNotSavedTitle => 'Nie zapisano';

  @override
  String get settingsAiChooseProviderBody => 'Wybierz dostawcę.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Własny dostawca wymaga adresu API.';

  @override
  String get settingsAiKeyRequiredBody => 'Wpisz klucz API.';

  @override
  String get settingsAiSavedBody => 'Ustawienia AI zostały zapisane.';

  @override
  String get settingsAiMissingDetailsTitle => 'Brakujące dane';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Wpisz adres API i model czatu, aby przetestować.';

  @override
  String get settingsAiKeyNeededTitle => 'Wymagany klucz API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Wprowadź klucz API, aby wykonać test. Zapisany klucz pozostaje prywatny.';

  @override
  String get settingsAiKeyToTestBody => 'Wprowadź klucz API, aby wykonać test.';

  @override
  String get settingsAiConnectedTitle => 'Połączono';

  @override
  String get settingsAiConnectedBody => 'Połączenie działa.';

  @override
  String get settingsAiTestFailedTitle => 'Test nieudany';

  @override
  String get settingsPreferencesSavedBody => 'Zapisano preferencje.';

  @override
  String get settingsPasswordNotChangedTitle => 'Hasło nie zostało zmienione';

  @override
  String get settingsOAuthPasswordBody =>
      'To konto loguje się przez Google lub Apple. Najpierw ustaw hasło, korzystając z opcji „Nie pamiętam hasła”.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Obecne hasło jest nieprawidłowe.';

  @override
  String get settingsExportReadyTitle => 'Eksporc gotowy';

  @override
  String get settingsExportReadyBody =>
      'Plik z danymi do eksportu jest gotowy do pobrania.';

  @override
  String get settingsLinkCopiedTitle => 'Skopiowano link';

  @override
  String get settingsExportClipboardBody =>
      'Nie udało się otworzyć przeglądarki, więc skopiowano link do pobrania. Wklej go w przeglądarce: ma ograniczony czas ważności.';

  @override
  String get settingsExportFailedTitle => 'Błąd eksportu';

  @override
  String get settingsAccountNotDeletedTitle => 'Konto nie zostało usunięte';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Możesz dodać do $max zdjęć.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limit zdjęć';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Dodaj co najmniej jedno zdjęcie.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Brak zdjęć';

  @override
  String get photoshootDescribeLookBody => 'Opisz stylizację, jakiej chcesz.';

  @override
  String get photoshootPromptNeededTitle => 'Wymagany prompt';

  @override
  String get photoshootConsentFeatureLabel => 'Fotografia AI';

  @override
  String get photoshootStatusPreparing => 'Przygotowywanie zdjęć';

  @override
  String get photoshootStatusGenerating => 'Generowanie';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Partia $current z $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'Wygenerowano $done z $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generowanie nie powiodło się.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return 'Gotowe: $ready, niepowodzenie: $failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Częściowo ukończono';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zdjęcia są gotowe.',
      one: '1 zdjęcie jest gotowe.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Utracono połączenie. Spróbuj ponownie.';

  @override
  String get photoshootCouldNotCancelTitle => 'Nie można anulować';

  @override
  String get photoshootRetryFailedTitle => 'Ponowienie nie powiodło się';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Zdjęcie $number jest gotowe.';
  }

  @override
  String get photoshootReplacedTitle => 'Zastąpiono';

  @override
  String get photoshootSavedToGalleryBody => 'Zapisano w galerii.';

  @override
  String get photoshootSavedTitle => 'Zapisano';

  @override
  String get photoshootNotSavedTitle => 'Nie zapisano';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wszystkie $count zdjęcia są w Twojej galerii.',
      one: '1 zdjęcie jest w Twojej galerii.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'Zapisano $saved z $total.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Niektóre zdjęcia nie zostały zapisane';

  @override
  String get tryonConsentFeatureLabel => 'Wirtualne przymierzanie';

  @override
  String get tryonAvatarUpdatedBody => 'Zdjęcie zostało zaktualizowane.';

  @override
  String get tryonSavedTitle => 'Zapisano';

  @override
  String get tryonUploadFailedTitle => 'Błąd przesyłania';

  @override
  String get tryonChooseGarmentFirstBody => 'Najpierw wybierz zdjęcie ubrania.';

  @override
  String get tryonNoGarmentTitle => 'Brak ubrania';

  @override
  String get tryonWaitForUploadBody =>
      'Poczekaj, aż zakończy się przesyłanie zdjęcia.';

  @override
  String get tryonStillUploadingTitle => 'Przesyłanie...';

  @override
  String get tryonAddYourPhotoFirstBody => 'Najpierw dodaj zdjęcie z sobą.';

  @override
  String get tryonReadyBody => 'Twoje przymierzanie jest gotowe.';

  @override
  String get tryonFailedTitle => 'Przymierzanie nie powiodło się';

  @override
  String get tryonSavedToGalleryBody => 'Zapisano w galerii.';

  @override
  String get tryonNotSavedTitle => 'Nie zapisano';

  @override
  String get calendarEventAddedBody => 'Wydarzenie dodane';

  @override
  String get calendarEventPlannedTitle => 'Zaplanowane';

  @override
  String get calendarEventSavedBody => 'Wydarzenie zapisane';

  @override
  String get calendarSavedTitle => 'Zapisano';

  @override
  String get calendarEventNotSavedTitle => 'Nie zapisano wydarzenia';

  @override
  String get calendarEventRemovedBody => 'Wydarzenie usunięte';

  @override
  String get calendarEventDeletedTitle => 'Usunięto';

  @override
  String get calendarEventNotDeletedTitle => 'Nie udało się usunąć wydarzenia';

  @override
  String get calendarOutfitNotLinkedTitle =>
      'Nie udało się powiązać stylizacji';

  @override
  String get calendarLinkedTitle => 'Powiązane';

  @override
  String get calendarOutfitNotRemovedTitle => 'Nie udało się usunąć stylizacji';

  @override
  String get calendarOutfitRemovedBody => 'Stylizacja usunięta';

  @override
  String get calendarDisconnectedBody => 'Kalendarz odłączony';

  @override
  String get calendarDisconnectedTitle => 'Odłączono';

  @override
  String get calendarNotDisconnectedTitle =>
      'Nie udało się odłączyć kalendarza';

  @override
  String get calendarTodayLabel => 'dziś';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydarzeń',
      many: 'wydarzeń',
      few: 'wydarzenia',
      one: '1 wydarzenie',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'od $start do $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, powiązana stylizacja';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" zostanie usunięte.';
  }

  @override
  String get calendarThisAppLabel => 'Ta aplikacja';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synchronizacja z $provider jest jeszcze niedostępna. Możesz nadal dodawać wydarzenia tutaj.';
  }

  @override
  String get calendarWeekdaySunShort => 'Ndz';

  @override
  String get calendarWeekdayMonShort => 'Pon';

  @override
  String get calendarWeekdayTueShort => 'Wt';

  @override
  String get calendarWeekdayWedShort => 'Śr';

  @override
  String get calendarWeekdayThuShort => 'Czw';

  @override
  String get calendarWeekdayFriShort => 'Pt';

  @override
  String get calendarWeekdaySatShort => 'Sob';

  @override
  String get calendarWeekdayMonday => 'Poniedziałek';

  @override
  String get calendarWeekdayTuesday => 'Wtorek';

  @override
  String get calendarWeekdayWednesday => 'Środa';

  @override
  String get calendarWeekdayThursday => 'Czwartek';

  @override
  String get calendarWeekdayFriday => 'Piątek';

  @override
  String get calendarWeekdaySaturday => 'Sobota';

  @override
  String get calendarWeekdaySunday => 'Niedziela';

  @override
  String get outfitSavedToFavouritesBody => 'Dodano do ulubionych';

  @override
  String get outfitRemovedFromFavouritesBody => 'Usunięto z ulubionych';

  @override
  String get outfitNotSavedTitle => 'Nie zapisano';

  @override
  String get outfitLoggedAsWornBody => 'Zaznaczono jako noszone dzisiaj.';

  @override
  String get outfitNicePickTitle => 'Dobry wybór';

  @override
  String get outfitRemovedBody => 'Usunięto zestaw.';

  @override
  String get outfitDeletedTitle => 'Usunięto';

  @override
  String get outfitNotDeletedTitle => 'Nie usunięto';

  @override
  String get outfitDuplicatedBody => 'Kopia dodana do zestawów.';

  @override
  String get outfitDuplicatedTitle => 'Zduplikowano';

  @override
  String get outfitNotDuplicatedTitle => 'Nie zduplikowano';

  @override
  String get outfitNotSharedTitle => 'Nie udostępniono';

  @override
  String outfitCollectionReadyBody(String name) {
    return 'Kolekcja „$name” jest gotowa.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Nie utworzono kolekcji';

  @override
  String get outfitCollectionUpdatedBody => 'Zaktualizowano kolekcję.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Nie zaktualizowano kolekcji';

  @override
  String get outfitCollectionDeletedBody => 'Usunięto kolekcję.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Nie usunięto kolekcji';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zestawów dodanych.',
      many: '$count zestawów dodanych.',
      few: '$count zestawy dodane.',
      one: 'Dodano 1 zestaw.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Nie dodano zestawów';

  @override
  String get outfitPreviewNotCreatedTitle => 'Nie utworzono podglądu';

  @override
  String get outfitGiveNameBody => 'Nadaj zestawowi nazwę.';

  @override
  String get outfitNameMissingTitle => 'Nazwa';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'Wybierz co najmniej jedną część.';

  @override
  String outfitCreatedBody(String name) {
    return '$name jest w Twoich zestawach.';
  }

  @override
  String get outfitSavedTitle => 'Zapisano';

  @override
  String get wardrobeAddedToFavouritesBody => 'Dodano do ulubionych';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Usunięto z ulubionych';

  @override
  String get wardrobeNotSavedTitle => 'Nie zapisano';

  @override
  String get wardrobeLoggedAsWornBody => 'Zarejestrowano jako noszone dziś.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Usunięto z Twojej szafy.';

  @override
  String get wardrobeDeletedTitle => 'Usunięto';

  @override
  String get wardrobeNotDeletedTitle => 'Nie usunięto';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przedmioty usunięte z Twojej szafy.',
      one: '1 przedmiot usunięty z Twojej szafy.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Wykrywanie garderoby przez AI';

  @override
  String get itemAddScanJobLabel => 'Skanuj';

  @override
  String get itemAddFoundEarlierBody => 'Znaleziono w poprzednim skanowaniu';

  @override
  String get itemAddLookingAtPhoto => 'Przyglądamy się Twojemu zdjęciu';

  @override
  String get itemAddExtractionFailedBody => 'Wyciąganie nie powiodło się';

  @override
  String get itemAddJobFailedBody => 'Zadanie nie powiodło się';

  @override
  String get itemAddConnectionLostBody =>
      'Utracono połączenie. Spróbuj ponownie.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Utracono połączenie podczas przetwarzania.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Element $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Element';

  @override
  String get itemAddNotCancelledTitle => 'Nie anulowano';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przedmioty w Twojej szafie.',
      one: '1 przedmiot w Twojej szafie.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'Zapisano $saved z $total elementów. Dotknij Zapisz, aby spróbować reszty ponownie.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Niektóre elementy nie zostały zapisane';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'Wybierz co najmniej jedno zdjęcie.';

  @override
  String get batchPhotoUnreadableBody => 'Nie udało się odczytać tego zdjęcia.';

  @override
  String get batchNoPhotosReadableBody =>
      'Nie udało się odczytać żadnego z tych zdjęć. Spróbuj użyć innych.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zdjęcia',
      one: '1 zdjęcie',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Utracono połączenie podczas pracy. Spróbuj ponownie.';

  @override
  String get batchNotCancelledTitle => 'Nie anulowano';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Linki do postów nie są obsługiwane. Wprowadź link do profilu.';

  @override
  String get batchLinkSpacesBody => 'Linki nie mogą zawierać spacji.';

  @override
  String get batchEnterProfileLinkBody =>
      'Wprowadź link do profilu na Instagramie lub Facebooku.';

  @override
  String get batchEnterProfileLinkShortBody => 'Wprowadź link do profilu.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Strona logowania nie została otwarta. Spróbuj ponownie.';

  @override
  String get batchSignInBrowserBody =>
      'Zaloguj się w przeglądarce, a następnie wróć do FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Połącz konto';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Wpisz kod z aplikacji do uwierzytelniania.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram wymaga weryfikacji bezpieczeństwa. Zaloguj się wcześniej w przeglądarce.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Wpisz ponownie nazwę użytkownika i hasło.';

  @override
  String get batchSignInFailedBody =>
      'Logowanie nie powiodło się. Sprawdź nazwę użytkownika i hasło.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Zaloguj się, aby kontynuować import.';

  @override
  String get batchAccountNotConnectedBody => 'Konto nie zostało połączone.';

  @override
  String get batchAccountConnectedTitle => 'Konto połączone';

  @override
  String get batchNotConnectedTitle => 'Brak połączenia';

  @override
  String get batchImportConnectionLostBody =>
      'Utraciliśmy połączenie z importem. Odśwież, aby to sprawdzić.';

  @override
  String batchPickUpToBody(int max) {
    return 'Wybierz do $max zdjęć. Znajdziemy elementy garderoby.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count z $total zdjęć';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Przygotowanie zdjęcia $done z $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znajdź elementy na $count zdjęciach',
      one: 'Znajdź elementy na 1 zdjęciu',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Konto na platformie $platform używa dwuetapowego logowania. Wpisz 6-cyfrowy kod z aplikacji do uwierzytelniania.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Ten profil na platformie $platform jest prywatny lub wymaga zalogowania, aby wyświetlić zdjęcia.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Połącz z $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znaleziono dotąd $count zdjęć',
      one: 'Znaleziono dotąd 1 zdjęcie',
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
    return '$processed z $total przetworzono · dodano $added · oczekuje $waiting · pominięto $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Skanowanie zdjęcia $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Zdjęcie $number następne';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Zdjęcie $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znaleziono $count elementów',
      one: 'Znaleziono 1 element',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano $count zdjęć do Twojej garderoby.',
      one: '1 zdjęcie zostało dodane do Twojej garderoby.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count kolejne zdjęcia studyjne w przygotowaniu. Możesz zapisać gotowe, albo odejść — damy znać.',
      one:
          '1 kolejne zdjęcie studyjne w przygotowaniu. Możesz zapisać gotowe, albo odejść — damy znać.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Nie zapisano jeszcze: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces elementów',
      one: '1 element',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos zdjęć',
      one: '1 zdjęcia',
    );
    return '$_temp0 z $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return 'Wybrano $chosen. Dotknij elementu, aby go pominąć.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zapisywanie $count elementów',
      one: 'Zapisywanie 1 elementu',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zapisz $count elementów',
      one: 'Zapisz 1 element',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Zapisano profil Twojego ciała.';

  @override
  String get bodyProfileSavedTitle => 'Zapisano';

  @override
  String get bodyProfileNotSavedTitle => 'Nie zapisano';

  @override
  String get bodyProfileSetDefaultBody => 'Ustaw jako domyślny profil.';

  @override
  String get bodyProfileDeletedBody => 'Usunięto profil ciała.';

  @override
  String get bodyProfileDeletedTitle => 'Usunięto';

  @override
  String get bodyProfileNotDeletedTitle => 'Nie usunięto';

  @override
  String get feedbackNotSentTitle => 'Nie wysłano';

  @override
  String get feedbackSentBody =>
      'Dzięki. Czytamy każdą wiadomość i odpisujemy, gdy potrzebujemy więcej.';

  @override
  String get feedbackSentTitle => 'Wysłano opinię';

  @override
  String get recommendUnnamedPiece => 'Nienazwany element';

  @override
  String get recommendEnterCityBody =>
      'Wpisz swoje miasto, aby otrzymać rekomendacje pogodowe.';

  @override
  String get recommendWhichCityTitle => 'Które miasto?';

  @override
  String get aiConsentSheetTitle => 'Udostępnianie zdjęć usłudze AI';

  @override
  String get aiConsentSheetBody =>
      'Aby tworzyć Twoje zdjęcia przymierzania i sesje zdjęciowe, FitCheck AI wysyła dostarczone przez Ciebie zdjęcia (w tym zdjęcia twarzy i ciała) zaufanemu zewnętrzemu dostawcy AI (takim jak OpenAI lub Google Gemini) do obróbki. Generują Twoje obrazy i nie używają ich do trenowania modeli zgodnie z naszymi warunkami. Zdjęcia są przesyłane bezpiecznie i nigdy nie są udostępniane do reklam.';

  @override
  String get aiConsentSheetPermission =>
      'Kontynuując, wyraźnie zezwalasz na udostępnianie swoich zdjęć tym dostawcom AI do generowania obrazów.';

  @override
  String get skeletonsLoadMoreFailed => 'Nie udało się załadować więcej.';

  @override
  String get jobsPiecesReadyTitle => 'Twoje elementy są gotowe';

  @override
  String get jobsScanStoppedTitle => 'Skanowanie zatrzymane';

  @override
  String get jobsNothingSavedBody =>
      'Nic nie zostało zapisane. Spróbuj ponownie.';

  @override
  String get jobsPhotoUploadFailedBody => 'Nie udało się przesłać zdjęcia.';

  @override
  String get authGoogleSignInStartFailed =>
      'Nie można uruchomić logowania Google. Spróbuj ponownie.';

  @override
  String get referralAppliedTitle => 'Zrealizowano polecenie!';

  @override
  String get billingStoreUnavailableBody =>
      'Zakupy w sklepie są niedostępne na tym urządzeniu.';

  @override
  String get billingPurchaseProcessingBody =>
      'Ta transakcja jest nadal przetwarzana. Otwórz aplikację ponownie za minutę, aby zobaczyć swój plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Przesyłanie awatara nie zwróciła adresu URL obrazu.';

  @override
  String get rewardsDayStreakLabel => 'dni seria';

  @override
  String rewardsBestStreak(int days) {
    return 'Najlepsza seria $days dni';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Wymagany dostęp $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Dostęp do $permission jest obecnie odrzucony. Otwórz Ustawienia, aby go umożliwić, a następnie wróć i spróbuj ponownie.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Krok $step z 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Krok $step z $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Usuń zdjęcie $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Usuń zdjęcie $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pkt';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Napisz na $email. Sprawdzamy zgłoszenia w ciągu 24 godzin.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Usuń $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Usunąć „$name”?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Dodaj do „$name”';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '„$name” zostało usunięte. Jego elementy nadal są w Twojej szafie.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Pokaż wszystkie ($count)';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Pozostało $count dzisiaj';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Zdjęcie $index nie powiodło się';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected z $max zdjęć';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Sylwetka: $shape · Kolor skóry: $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Usunąć $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opcje dla $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Najczęściej noszone: $name, $count razy';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: nie ustawiono';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% dopasowania';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'Wybrano $picked z $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Usuń $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Priorytet: $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Tę subskrypcję rozlicza $store. Zmień lub anuluj ją w ustawieniach konta $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Zarządzaj w $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: wykorzystano $current z $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Pozostało około ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return 'Gotowe $done z $total zdjęć studyjnych';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return 'Gotowe $ready z $total zdjęć studyjnych. Dotknij elementu, aby pominąć go.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height cm · $weight kg';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'Nie';
}
