// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Acasă';

  @override
  String get tabPhotoshoot => 'Ședință foto';

  @override
  String get tabCloset => 'Garderobă';

  @override
  String get tabOutfits => 'Ținute';

  @override
  String get tabMore => 'Mai mult';

  @override
  String get actionAddItem => 'Adaugă articol';

  @override
  String get actionCreateOutfit => 'Creează ținută';

  @override
  String get actionCancel => 'Anulează';

  @override
  String get actionDelete => 'Șterge';

  @override
  String get actionSave => 'Salvează';

  @override
  String get actionRetry => 'Reîncearcă';

  @override
  String get actionDone => 'Gata';

  @override
  String get actionNext => 'Înainte';

  @override
  String get actionBack => 'Înapoi';

  @override
  String get actionClose => 'Închide';

  @override
  String get actionSearch => 'Caută';

  @override
  String get actionContinue => 'Continuă';

  @override
  String get stateLoading => 'Se încarcă';

  @override
  String get stateErrorTitle => 'Ceva nu a mers bine';

  @override
  String get stateErrorBody =>
      'Încearcă din nou. Dacă problema persistă, contactează asistența.';

  @override
  String get stateOfflineTitle => 'Ești offline';

  @override
  String get stateOfflineBody =>
      'Reconectează-te pentru a-ți sincroniza garderoba și a genera ținute.';

  @override
  String get settingsTitle => 'Setări';

  @override
  String get settingsAccountSection => 'Cont';

  @override
  String get settingsPreferencesSection => 'Preferințe';

  @override
  String get settingsPlanBilling => 'Abonament și facturare';

  @override
  String get settingsLanguage => 'Limbă';

  @override
  String get settingsNotifications => 'Notificări';

  @override
  String get settingsUnits => 'Unități de măsură';

  @override
  String get settingsAppearance => 'Aspect';

  @override
  String get settingsPrivacySection => 'Confidențialitate și date';

  @override
  String get settingsAboutSection => 'Despre';

  @override
  String get settingsSignOut => 'Deconectare';

  @override
  String get settingsDeleteAccount => 'Șterge contul';

  @override
  String get settingsDeleteAccountTitle => 'Ștergi contul?';

  @override
  String get settingsDeleteAccountBody =>
      'Această acțiune îți va șterge garderoba, ținutele, fotografiile și profilul. Nu poate fi anulată.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metric (cm, kg)';

  @override
  String get languageTitle => 'Limbă';

  @override
  String get languageSystem => 'Folosește limba dispozitivului';

  @override
  String get languageSystemBody =>
      'FitCheck AI utilizează limba setată pe telefonul tău.';

  @override
  String get languageSearchHint => 'Caută limbi';

  @override
  String get languageCurrent => 'Actuală';

  @override
  String get languageReviewNote =>
      'Această traducere este nouă. Spune-ne dacă ceva nu sună natural.';

  @override
  String get languageChanged => 'Limbă actualizată';

  @override
  String get paywallTitle => 'Alege-ți abonamentul';

  @override
  String get paywallTrialBadge => '1 lună gratuită';

  @override
  String get paywallTrialTitle => 'Prima lună Pro este gratuită';

  @override
  String get paywallTrialBody =>
      'Încarcă-ți toată garderoba dintr-o dată. Adaugă piese pe parcurs după aceea.';

  @override
  String get paywallFreeForeverTitle => 'Gratuit pentru totdeauna';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Fără card necesar. În fiecare lună primești $uploads încărcări AI, $outfits ținute și $images imagini foto pe zi.';
  }

  @override
  String get paywallCtaTrial => 'Începe luna gratuită';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Treci la $plan';
  }

  @override
  String get paywallRestore => 'Restaurează achizițiile';

  @override
  String get paywallManage => 'Gestionează abonamentul';

  @override
  String get paywallTerms => 'Termeni de utilizare';

  @override
  String get paywallPrivacy => 'Politică de confidențialitate';

  @override
  String get paywallPerMonth => 'pe lună';

  @override
  String get paywallPerYear => 'pe an';

  @override
  String get paywallBestValue => 'Cel mai bun preț';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Probă gratuită doar pentru abonații noi. După probă, Pro se reînnoiește la $price cu cel puțin 24 de ore înainte de sfârșit, dacă nu este anulat.';
  }

  @override
  String get introTitle => 'Garderoba ta, în sfârșit organizată';

  @override
  String get introBody =>
      'Fotografiază-ți hainele o singură dată. Obține idei de ținute, previzualizări de probă și fotografii de studio din ceea ce ai deja.';

  @override
  String get introStart => 'Începe';

  @override
  String get introHaveAccount => 'Am deja cont';

  @override
  String get introSkip => 'Sări';

  @override
  String get authSignIn => 'Autentificare';

  @override
  String get authSignUp => 'Creează cont';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Parolă';

  @override
  String get authForgotPassword => 'Ai uitat parola?';

  @override
  String get authContinueApple => 'Continuă cu Apple';

  @override
  String get authContinueGoogle => 'Continuă cu Google';

  @override
  String get authOrDivider => 'sau';

  @override
  String get wardrobeTitle => 'Garderobă';

  @override
  String get wardrobeEmptyTitle => 'Garderoba ta este goală';

  @override
  String get wardrobeEmptyBody =>
      'Adaugă prima piesă sau încarcă o poză cu întregul șifonier deodată.';

  @override
  String get wardrobeAddFirst => 'Adaugă primul articol';

  @override
  String get wardrobeSearchHint => 'Caută în garderobă';

  @override
  String get categoryTops => 'Topuri';

  @override
  String get categoryBottoms => 'Pantaloni';

  @override
  String get categoryShoes => 'Încălțăminte';

  @override
  String get categoryAccessories => 'Accesorii';

  @override
  String get categoryOuterwear => 'Jachete';

  @override
  String get categorySwimwear => 'Costume de baie';

  @override
  String get categoryActivewear => 'Sport';

  @override
  String get categoryOther => 'Altele';

  @override
  String get conditionClean => 'Curat';

  @override
  String get conditionDirty => 'Murdar';

  @override
  String get conditionLaundry => 'La spălat';

  @override
  String get conditionRepair => 'De reparat';

  @override
  String get conditionDonate => 'De donat';

  @override
  String get seasonSpring => 'Primăvară';

  @override
  String get seasonSummer => 'Vară';

  @override
  String get seasonFall => 'Toamnă';

  @override
  String get seasonWinter => 'Iarnă';

  @override
  String get seasonAll => 'Toate sezoanele';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sport';

  @override
  String get styleBohemian => 'Boem';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalist';

  @override
  String get styleRomantic => 'Romantic';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Clasic';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Altele';

  @override
  String get occasionWork => 'Serviciu';

  @override
  String get occasionDateNight => 'Întâlnire';

  @override
  String get occasionTravel => 'Călătorie';

  @override
  String get occasionWedding => 'Nuntă';

  @override
  String get occasionGym => 'Sală';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Petrecere';

  @override
  String get occasionInterview => 'Interviu';

  @override
  String get colorBlack => 'Negru';

  @override
  String get colorWhite => 'Alb';

  @override
  String get colorGrey => 'Gri';

  @override
  String get colorNavy => 'Bleumarin';

  @override
  String get colorBrown => 'Maro';

  @override
  String get colorRed => 'Roșu';

  @override
  String get colorBlue => 'Albastru';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPink => 'Roz';

  @override
  String get colorPurple => 'Mov';

  @override
  String get colorYellow => 'Galben';

  @override
  String get colorOrange => 'Portocaliu';

  @override
  String get colorBeige => 'Bej';

  @override
  String get dateToday => 'Astăzi';

  @override
  String get dateYesterday => 'Ieri';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Acum $count de zile',
      few: 'Acum $count zile',
      one: 'Acum 1 zi',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Acum $count de săptămâni',
      few: 'Acum $count săptămâni',
      one: 'Acum 1 săptămână',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Acum $count de luni',
      few: 'Acum $count luni',
      one: 'Acum 1 lună',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Acum $count de ani',
      few: 'Acum $count ani',
      one: 'Acum 1 an',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Îți place FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'O evaluare rapidă îi ajută și pe alții să-și găsească stilul.';

  @override
  String get ratingPromptYes => 'Evaluează aplicația';

  @override
  String get ratingPromptNo => 'Nu acum';

  @override
  String get closetNoMatchesTitle => 'Nicio piesă găsită';

  @override
  String get closetNoMatchesBody =>
      'Încearcă mai puține filtre sau altă căutare.';

  @override
  String get closetClearFilters => 'Șterge filtrele';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de piese',
      few: '$count piese',
      one: '1 piesă',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Se încarcă piesele';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selectate',
      few: '$count selectate',
      one: '1 selectată',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Șterge selectate';

  @override
  String get closetCancelSelection => 'Anulează selecția';

  @override
  String get closetCloseSearch => 'Închide căutarea';

  @override
  String get closetShowGrid => 'Afișează ca grilă';

  @override
  String get closetShowList => 'Afișează ca listă';

  @override
  String get closetShowRows => 'Afișează ca rânduri';

  @override
  String get closetStatsTitle => 'Statistici dulap';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ștergi $count de piese?',
      few: 'Ștergi $count piese?',
      one: 'Ștergi 1 piesă?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Ținutele care le conțin vor pierde aceste piese.';

  @override
  String get closetSortBy => 'Sortează după';

  @override
  String get closetFavourites => 'Favorite';

  @override
  String get closetFavourite => 'Favorit';

  @override
  String get closetUnfavourite => 'Elimină din favorite';

  @override
  String get closetWoreToday => 'Purtat azi';

  @override
  String closetWornTimes(int count) {
    return 'Purtat de $count×';
  }

  @override
  String get closetCategoryLabel => 'Categorie';

  @override
  String get closetUseCaseLabel => 'Ocazie';

  @override
  String get closetAnyUseCase => 'Oricare';

  @override
  String get closetOtherUseCase => 'Altă ocazie';

  @override
  String get closetOtherUseCaseHint => 'De exemplu, brunch';

  @override
  String get closetUseUseCase => 'Folosește asta';

  @override
  String get closetClearAll => 'Șterge tot';

  @override
  String get sortNewest => 'Cele mai noi';

  @override
  String get sortOldest => 'Cele mai vechi';

  @override
  String get sortName => 'Nume (A–Z)';

  @override
  String get sortMostWorn => 'Cele mai purtate';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Întâlnire';

  @override
  String get useCaseDinner => 'Cină';

  @override
  String get useCaseLunch => 'Prânz';

  @override
  String get actionSelect => 'Selectează';

  @override
  String get actionEdit => 'Editează';

  @override
  String get actionFilter => 'Filtrează';

  @override
  String get actionSort => 'Sortează';

  @override
  String get actionAll => 'Toate';

  @override
  String get dashboardStartClosetTitle => 'Începe-ți garderoba';

  @override
  String get dashboardStartClosetBody =>
      'Fotografiază câteva piese. Noi le etichetăm pentru tine.';

  @override
  String get dashboardPieces => 'piese';

  @override
  String get dashboardOutfits => 'ținute';

  @override
  String get dashboardDayStreak => 'zile consecutive';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count luna aceasta';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Cel mai bun: $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de favorite',
      few: '$count favorite',
      one: '1 favorit',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de ținute salvate',
      few: '$count ținute salvate',
      one: '1 ținută salvată',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Cel mai purtat: $name, de $count ori';
  }

  @override
  String get setupSkip => 'Sări peste configurare';

  @override
  String get setupWhoTitle => 'Pentru cine facem ținute?';

  @override
  String get setupWhoBody =>
      'Setează modelul pentru probă și ședințe foto. Îl poți schimba în profil.';

  @override
  String get setupStyleTitle => 'Ce porți cel mai des?';

  @override
  String get setupStyleBody =>
      'Alege oricare. Ideile de ținute pornesc de aici.';

  @override
  String get setupClosetTitle => 'Adaugă primele piese.';

  @override
  String get setupClosetBody =>
      'Fotografiază câteva haine sau o grămadă din ele. Fiecare piesă este decupată și salvată pentru tine.';

  @override
  String get setupAddClothes => 'Adaugă haine';

  @override
  String get setupStylesLabel => 'Stiluri';

  @override
  String get setupOccasionsLabel => 'Ocazii';

  @override
  String get setupSkipStep => 'Sări';

  @override
  String get setupLater => 'Mai târziu';

  @override
  String get setupSaveError => 'Salvare eșuată';

  @override
  String get genderWomen => 'Femei';

  @override
  String get genderMen => 'Bărbați';

  @override
  String get genderNonBinary => 'Non-binar';

  @override
  String get genderPreferNotToSay => 'Prefer să nu menționez';

  @override
  String get outfitEmptyTitle => 'Nicio ținută încă';

  @override
  String get outfitEmptyBody =>
      'Combină piese din garderobă și salvează aspectul.';

  @override
  String get outfitNoMatchesTitle => 'Nicio ținută nu se potrivește';

  @override
  String get outfitSearchHint => 'Caută în ținute';

  @override
  String get outfitLoading => 'Se încarcă ținutele';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de ținute',
      few: '$count ținute',
      one: '1 ținută',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Stil și sezon';

  @override
  String get outfitCollections => 'Colecții';

  @override
  String get outfitDuplicate => 'Duplică';

  @override
  String get outfitDeleteTitle => 'Ștergi această ținută?';

  @override
  String get outfitDeleteBody => 'Piesele ei rămân în garderobă.';

  @override
  String get outfitDrafts => 'Ciorne';

  @override
  String get outfitDraft => 'Ciornă';

  @override
  String get filterStyle => 'Stil';

  @override
  String get filterSeason => 'Sezon';

  @override
  String get itemDetailDeleteTitle => 'Ștergi această piesă?';

  @override
  String get itemDetailDeleteBody =>
      'Ținutele care o folosesc vor pierde această piesă.';

  @override
  String get itemAddFavourite => 'Adaugă la favorite';

  @override
  String itemSize(String size) {
    return 'Mărimea $size';
  }

  @override
  String get itemColours => 'Culori';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Model';

  @override
  String get itemUseCases => 'Utilizări';

  @override
  String get itemKeptIn => 'Păstrat în';

  @override
  String get itemPrice => 'Preț';

  @override
  String get itemBought => 'Cumpărat';

  @override
  String get itemTags => 'Etichete';

  @override
  String get itemAdded => 'Adăugat';

  @override
  String get itemTimesWornLabel => 'purtat de';

  @override
  String get itemLastWornLabel => 'purtat ultima oară';

  @override
  String get itemNeverWorn => 'Niciodată';

  @override
  String get authEntryBody =>
      'Fiecare articol din garderobă, stilizat de AI. Planifică ținute, probează-le, fotografiază-le.';

  @override
  String get authCreateCloset => 'Creează-ți garderoba';

  @override
  String get authWelcomeBack => 'Bun revenit';

  @override
  String get authSignInBody => 'Autentifică-te pentru a-ți deschide garderoba.';

  @override
  String get authCreateAccount => 'Creează un cont';

  @override
  String get authCreateClosetBody =>
      'Durează un minut. Primele articole sunt gratuite.';

  @override
  String get authName => 'Nume';

  @override
  String get authConfirmPassword => 'Confirmă parola';

  @override
  String get authReferralCode => 'Cod de recomandare (opțional)';

  @override
  String get authResetTitle => 'Resetează parola';

  @override
  String get authResetBody =>
      'Îți vom trimite un link pe email pentru a alege una nouă.';

  @override
  String get authSendResetLink => 'Trimite linkul';

  @override
  String get authBackToSignIn => 'Înapoi la autentificare';

  @override
  String get authEnterEmail => 'Introdu adresa de email';

  @override
  String get authEnterValidEmail => 'Introdu un email valid';

  @override
  String get authEnterPassword => 'Introdu parola';

  @override
  String get authPasswordTooShort => 'Cel puțin 6 caractere';

  @override
  String get authShowPassword => 'Arată parola';

  @override
  String get authHidePassword => 'Ascunde parola';

  @override
  String get authNewHere => 'Ești nou aici?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirmă $email înainte de autentificare. Verifică-ți inboxul.';
  }

  @override
  String get authResendEmail => 'Trimite din nou';

  @override
  String get authResendingEmail => 'Se trimite…';

  @override
  String get authPasswordsDoNotMatch => 'Parolele nu coincid';

  @override
  String get authEnterName => 'Introdu numele';

  @override
  String get authChoosePassword => 'Alege o parolă';

  @override
  String get authHaveAccount => 'Ai deja cont?';

  @override
  String get authCodeAccepted => 'Cod acceptat';

  @override
  String get authCodeNotFound => 'Cod negăsit';

  @override
  String authReferralFrom(String name) {
    return 'De la $name. Primiți amândoi o lună gratuită.';
  }

  @override
  String get authReferralInvalid => 'Nu am putut găsi acest cod.';

  @override
  String authResetSent(String email) {
    return 'Trimis la $email. Deschide linkul pe acest telefon.';
  }

  @override
  String get introSlide1Title => 'Fotografiază-ți garderoba o singură dată.';

  @override
  String get introSlide1Body =>
      'Pozează un teanc de haine. Fiecare piesă este decupată și salvată pentru tine.';

  @override
  String get introSlide2Title => 'Te îmbraci mai repede.';

  @override
  String get introSlide2Body =>
      'Ținute din hainele tale, adaptate planurilor și vremii.';

  @override
  String get introSlide3Title => 'Vezi ținuta înainte s-o porți.';

  @override
  String get introSlide3Body =>
      'Probează lookuri pe propria poză sau fotografiază-le ca într-o campanie.';

  @override
  String get settingsTheme => 'Temă';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Deschisă';

  @override
  String get settingsThemeDark => 'Închisă';

  @override
  String get settingsTemperature => 'Temperatură';

  @override
  String get settingsEmailUpdates => 'Actualizări prin email';

  @override
  String get settingsEmailUpdatesBody => 'Noutăți și sfaturi prin email';

  @override
  String get settingsOutfitReminders => 'Notificări pentru ținute';

  @override
  String get settingsOutfitRemindersBody => 'Un memento să notezi ce ai purtat';

  @override
  String get settingsWeeklySummary => 'Sumar săptămânal';

  @override
  String get settingsWeeklySummaryBody => 'Săptămâna ta în ținute';

  @override
  String get settingsStyleSection => 'Stil';

  @override
  String get settingsPreferredStyles => 'Stiluri preferate';

  @override
  String get settingsPreferredColours => 'Culori preferate';

  @override
  String get settingsNoneChosen => 'Niciuna aleasă';

  @override
  String get settingsPlanAiSection => 'Plan și AI';

  @override
  String get settingsPlanBillingBody => 'Plan, utilizare și upgrade-uri';

  @override
  String get settingsPlanUsageBody => 'Plan și utilizare';

  @override
  String get settingsInviteFriends => 'Invită prieteni';

  @override
  String get settingsInviteFriendsBody =>
      'O lună gratuită pentru fiecare prieten care se alătură';

  @override
  String get settingsAiProvider => 'Furnizor AI';

  @override
  String get settingsAiProviderBody =>
      'Folosește propriul tău model pentru etichetare și imagini';

  @override
  String get settingsAppVersion => 'Versiune aplicație';

  @override
  String get settingsPrivacyTerms => 'Confidențialitate și termeni';

  @override
  String get settingsReportProblem => 'Raportează o problemă';

  @override
  String get settingsChangePassword => 'Schimbă parola';

  @override
  String get settingsExportData => 'Exportă-ți datele';

  @override
  String get settingsExportBody =>
      'Pregătim un fișier cu tot ce ai salvat și deschidem descărcarea.';

  @override
  String get settingsExportAction => 'Exportă';

  @override
  String get settingsCurrentPassword => 'Parolă curentă';

  @override
  String get settingsNewPassword => 'Parolă nouă';

  @override
  String get settingsConfirmNewPassword => 'Confirmă parola nouă';

  @override
  String get settingsEnterCurrentPassword => 'Introdu parola curentă';

  @override
  String get settingsEnterNewPassword => 'Introdu o parolă nouă';

  @override
  String get settingsPasswordMin8 => 'Folosește cel puțin 8 caractere';

  @override
  String get settingsPasswordNeedsUpper => 'Adaugă o literă mare';

  @override
  String get settingsPasswordNeedsLower => 'Adaugă o literă mică';

  @override
  String get settingsPasswordNeedsDigit => 'Adaugă un număr';

  @override
  String get settingsPasswordsNoMatch => 'Parolele nu se potrivesc';

  @override
  String get settingsChangeAction => 'Schimbă';

  @override
  String get itemAddSnapTitle => 'Fotografiază o piesă';

  @override
  String get itemAddSnapBody =>
      'Găsim fiecare piesă din poză și creăm o fotografie de studio curată pentru fiecare.';

  @override
  String get itemAddCamera => 'Fă o poză';

  @override
  String get itemAddGallery => 'Alege din galerie';

  @override
  String get itemAddOtherWays => 'Alte moduri de adăugare';

  @override
  String get itemAddSeveral => 'Adaugă mai multe poze';

  @override
  String get itemAddSeveralBody => 'Până la 50 odată';

  @override
  String get itemAddImportProfile => 'Importă dintr-un profil';

  @override
  String get itemAddImportProfileBody => 'Instagram sau Facebook';

  @override
  String get itemAddEnterDetails => 'Introdu detaliile manual';

  @override
  String get itemAddEnterDetailsBody => 'Fără poză necesară';

  @override
  String get itemManualIntro =>
      'Este nevoie doar de un nume. Adaugă restul acum sau mai târziu.';

  @override
  String get itemManualNameHint => 'De exemplu, tricou albastru din bumbac';

  @override
  String get itemManualEnterName => 'Introdu un nume';

  @override
  String get itemManualNotes => 'Notițe';

  @override
  String get itemManualBrand => 'Marcă';

  @override
  String get itemManualSize => 'Mărime';

  @override
  String get itemManualEnterNumber => 'Introdu un număr';

  @override
  String get itemManualSavePiece => 'Salvează piesa';

  @override
  String get itemManualSaving => 'Se salvează';

  @override
  String get itemManualSavedTitle => 'Salvat';

  @override
  String itemManualSavedBody(String name) {
    return '$name este în garderoba ta.';
  }

  @override
  String get itemManualNotSaved => 'Nesalvat';

  @override
  String get itemManualAddUseCase => 'Adaugă o utilizare';

  @override
  String get itemManualAddUseCaseAction => 'Adaugă utilizare';

  @override
  String get itemPhotos => 'Fotografii';

  @override
  String get itemAddPhotos => 'Adaugă fotografii';

  @override
  String get itemNoPhotoYet => 'Nicio poză încă. Poți salva și fără.';

  @override
  String get itemRemovePhoto => 'Elimină poza';

  @override
  String get itemRemovePiece => 'Elimină piesa';

  @override
  String get filterConditionLabel => 'Stare';

  @override
  String get photoshootStepPhotos => 'Fotografii';

  @override
  String get photoshootStepSetup => 'Configurare';

  @override
  String get photoshootStepCreating => 'Se creează';

  @override
  String get photoshootStepResults => 'Rezultate';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Pasul $current din $total, $name';
  }

  @override
  String get photoshootOneFailed => 'O poză a eșuat. Reîncearcă mai jos.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotografii au eșuat. Reîncearcă fiecare mai jos.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Câte';

  @override
  String get photoshootYourPrompt => 'Descrierea ta';

  @override
  String get photoshootPromptHint => 'Oră de aur pe o terasă, cămașă de in';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Creează $count de poze',
      few: 'Creează $count poze',
      one: 'Creează 1 poză',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'de poze',
      few: 'poze',
      one: 'poză',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Nu am putut verifica limita de azi.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plan $plan: $remaining din $limit rămase azi';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratuit';

  @override
  String get photoshootGallery => 'Galerie';

  @override
  String get photoshootUseCamera => 'Folosește camera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Șterge poza $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Nicio poză generată';

  @override
  String get photoshootNoPhotosBody =>
      'Sesiunea s-a încheiat fără imagini. Încearcă din nou.';

  @override
  String get photoshootNewStyle => 'Stil nou';

  @override
  String get photoshootNewPhotos => 'Poze noi';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Deschide poza $number';
  }

  @override
  String get photoshootReportPhoto => 'Raportează poza';

  @override
  String get photoshootSaveToGallery => 'Salvează în galerie';

  @override
  String get actionUpgrade => 'Treci la Pro';

  @override
  String get referralLimitTitle => 'Ai folosit pozele de azi';

  @override
  String get referralLimitBody =>
      'Pozele gratuite revin mâine. Recomandă un prieten și amândoi primiți o lună de Pro gratuit.';

  @override
  String get referralLimitRefer => 'Recomandă un prieten';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Aplicație de dating';

  @override
  String get photoshootUsePortfolio => 'Portofoliu';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetic';

  @override
  String get photoshootUseCustom => 'Descrierea ta';

  @override
  String get photoshootDescLinkedin => 'Portrete profesionale pentru muncă';

  @override
  String get photoshootDescDating => 'Relaxate, calde și naturale';

  @override
  String get photoshootDescPortfolio => 'Look-uri editoriale, high-fashion';

  @override
  String get photoshootDescInstagram => 'Cadre lifestyle pentru feed-ul tău';

  @override
  String get photoshootDescAesthetic => 'Cadre artistice, pline de atmosferă';

  @override
  String get photoshootDescCustom => 'Descrie look-ul dorit';

  @override
  String get aspectSquare => 'Pătrat';

  @override
  String get aspectPortrait => 'Portret';

  @override
  String get aspectLandscape => 'Peisaj';

  @override
  String get aspectTall => 'Înalt';

  @override
  String get aspectWide => 'Lat';

  @override
  String get tryOnAppBar => 'Probă virtuală';

  @override
  String get tryOnYourPhoto => 'Poza ta';

  @override
  String get tryOnGarment => 'Articol';

  @override
  String get tryOnUploadingPhoto => 'Se încarcă poza ta';

  @override
  String get tryOnAddPhotoPrompt => 'Adaugă o poză cu tine în întregime';

  @override
  String get tryOnBodyPhotoHint =>
      'O poză din cap până în picioare funcționează cel mai bine';

  @override
  String get tryOnAddPhoto => 'Adaugă poză';

  @override
  String get tryOnChangePhoto => 'Schimbă poza';

  @override
  String get tryOnPhotoLoadFailed => 'Nu am putut încărca poza ta.';

  @override
  String get tryOnChooseGarment => 'Alege o poză cu haina';

  @override
  String get tryOnChooseOneGarment => 'Alege o poză cu o haină';

  @override
  String get tryOnGarmentHint =>
      'O poză pe plat sau pe umeraș funcționează cel mai bine';

  @override
  String get tryOnChange => 'Schimbă';

  @override
  String get tryOnCamera => 'Cameră';

  @override
  String get tryOnRemove => 'Șterge';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Stil';

  @override
  String get tryOnBackground => 'Fundal';

  @override
  String get tryOnPose => 'Poză';

  @override
  String get tryOnDressingUp =>
      'Te îmbrăcăm. Durează aproximativ jumătate de minut.';

  @override
  String get tryOnEmptyResult => 'Proba ta apare aici';

  @override
  String get tryOnReportImage => 'Raportează imaginea';

  @override
  String get tryOnCreating => 'Se creează';

  @override
  String get tryOnTryAgain => 'Încearcă din nou';

  @override
  String get tryOnCreate => 'Creează proba';

  @override
  String get tryOnBackgroundStudioWhite => 'Alb studio';

  @override
  String get tryOnBackgroundStudioGrey => 'Gri studio';

  @override
  String get tryOnBackgroundUrban => 'Stradă urbană';

  @override
  String get tryOnBackgroundNature => 'Natură';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Față';

  @override
  String get tryOnPoseSide => 'Profil';

  @override
  String get tryOnPoseWalking => 'În mers';

  @override
  String get dashboardGreetingMorning => 'Bună dimineața';

  @override
  String get dashboardGreetingAfternoon => 'Bună ziua';

  @override
  String get dashboardGreetingEvening => 'Bună seara';

  @override
  String get dashboardWelcome => 'Bun venit';

  @override
  String get dashboardOpenProfile => 'Deschide profilul';

  @override
  String get dashboardRailToday => 'Astăzi';

  @override
  String get dashboardRailRecently => 'Recent';

  @override
  String get dashboardActivityEmpty => 'Piesele și ținutele noi apar aici.';

  @override
  String get quickAddPiece => 'Adaugă o piesă';

  @override
  String get quickAddPieceBody => 'Fotografiază și etichetează';

  @override
  String get quickBuildOutfit => 'Creează o ținută';

  @override
  String get quickBuildOutfitBody => 'Combină piesele';

  @override
  String get quickForYou => 'Pentru tine';

  @override
  String get quickForYouBody => 'Alegeri pentru azi';

  @override
  String get quickPlanWeek => 'Planifică săptămâna';

  @override
  String get quickPlanWeekBody => 'Ținute după dată';

  @override
  String get referralBannerUrgent => 'Mai ai nevoie? Invită un prieten.';

  @override
  String get referralBannerTitle => 'Oferă o lună, primești o lună.';

  @override
  String get referralBannerBody =>
      'Tu și prietenul tău primiți fiecare câte o lună de Pro.';

  @override
  String get referralBannerDismiss => 'Ascunde o săptămână';

  @override
  String get referralBannerShare => 'Trimite invitația';

  @override
  String get referralBannerCopy => 'Copiază linkul';

  @override
  String get itemEditPieceTitle => 'Editează piesa';

  @override
  String get itemEditDescriptionLabel => 'Descriere';

  @override
  String get itemEditNotSaved => 'Nesalvat';

  @override
  String get itemEditSavedTitle => 'Salvat';

  @override
  String get itemEditSavedBody => 'Modificările au fost salvate.';

  @override
  String get itemEditSavedStalePhotos => 'Salvat — fotografiile pot fi vechi';

  @override
  String get itemEditRemovePieceHint =>
      'Șterge această piesă din pagina articolului.';

  @override
  String get itemEditNoPhotos =>
      'Nicio fotografie încă. Adaugă din galerie sau cameră.';

  @override
  String get itemEditKeepPhoto => 'Păstrează poza';

  @override
  String get itemEditRemoved => 'Șters';

  @override
  String get itemEditAddUseCaseAction => 'Adaugă';

  @override
  String get statsNoStatsTitle => 'Nicio statistică încă';

  @override
  String get statsNoStatsBody =>
      'Adaugă câteva piese pentru a vedea mixul din dulap.';

  @override
  String get statsByCategory => 'După categorie';

  @override
  String get statsTotalValue => 'valoare totală';

  @override
  String get statsMostWorn => 'Cel mai purtat';

  @override
  String get statsLeastWorn => 'În așteptare';

  @override
  String get statsUnnamedPiece => 'Piesă fără nume';

  @override
  String get jobsTitle => 'Scanări';

  @override
  String get jobsEmptyTitle => 'Nicio scanare';

  @override
  String get jobsEmptyBody =>
      'Fotografiază o piesă și trimite-o în fundal — va rula aici.';

  @override
  String get jobsNotCancelled => 'Necanelat';

  @override
  String get jobsResume => 'Reia';

  @override
  String get jobsReview => 'Revizuiește';

  @override
  String get jobsStop => 'Oprește';

  @override
  String get jobsDismiss => 'Închide';

  @override
  String get reportTitle => 'Raportează conținutul';

  @override
  String reportIntro(String contentType) {
    return 'Spune-ne ce este în neregulă cu acest $contentType. Echipa noastră analizează fiecare raport.';
  }

  @override
  String get reportReasonInappropriate => 'Inadecvat sau ofensator';

  @override
  String get reportReasonNudity => 'Nuditate sau conținut sexual';

  @override
  String get reportReasonHarassment => 'Hărțuire sau abuz';

  @override
  String get reportReasonImpersonation => 'Imitarea altei persoane';

  @override
  String get reportReasonOther => 'Altele';

  @override
  String get reportDetailsLabel => 'Detalii suplimentare (opțional)';

  @override
  String get reportSubmit => 'Trimite raportul';

  @override
  String get reportSubmittedTitle => 'Raport trimis';

  @override
  String get reportSubmittedBody =>
      'Mulțumim. Echipa noastră va analiza acest conținut.';

  @override
  String get reportFailedTitle => 'Raportul nu a putut fi trimis';

  @override
  String get reportFailedBody => 'Te rugăm să încerci din nou.';

  @override
  String get reportContentTryOnImage => 'imagine AI try-on';

  @override
  String get reportContentSharedOutfit => 'ținută partajată';

  @override
  String get reportContentPhotoshootImage => 'imagine AI photoshoot';

  @override
  String get sharedOutfitTitle => 'Ținută partajată';

  @override
  String get sharedOutfitHideTooltip => 'Ascunde această ținută';

  @override
  String get sharedOutfitReportTooltip => 'Raportează această ținută';

  @override
  String get sharedOutfitHideTitle => 'Ascunzi această ținută?';

  @override
  String get sharedOutfitHideBody =>
      'Va rămâne ascunsă pe acest dispozitiv. O poți raporta pentru ca echipa noastră să o verifice și să o elimine.';

  @override
  String get sharedOutfitHideAction => 'Ascunde';

  @override
  String get sharedOutfitHiddenInfo =>
      'Această ținută nu va mai apărea pe acest dispozitiv.';

  @override
  String get sharedOutfitHiddenToast => 'Ținută ascunsă';

  @override
  String get sharedOutfitMissingTitle =>
      'Această ținută nu mai este disponibilă';

  @override
  String get sharedOutfitMissingBody =>
      'Poate a fost eliminată sau linkul este incorect.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Ai ascuns această ținută';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Dacă este inadecvată, raportează din Confidențialitate și termeni sau trimite un email la $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Îți place acest look?';

  @override
  String get sharedOutfitCtaBody =>
      'Creează ținute similare din propria garderobă.';

  @override
  String get sharedOutfitCtaButton => 'Obține FitCheck AI';

  @override
  String get errorTitle => 'Eroare';

  @override
  String get errorUnknown => 'A apărut o eroare neașteptată';

  @override
  String get errorNoConnection =>
      'Fără conexiune la internet. Verifică rețeaua.';

  @override
  String get errorTimeout => 'Timpul a expirat. Încearcă din nou.';

  @override
  String get errorServerError =>
      'Ceva nu a funcționat pe server. Încearcă din nou.';

  @override
  String get errorBadGateway =>
      'Serverul este indisponibil temporar. Încearcă din nou.';

  @override
  String get errorServiceUnavailable =>
      'Serviciul este temporar indisponibil. Încearcă în curând.';

  @override
  String get errorInternalError => 'Ceva nu a funcționat. Încearcă din nou.';

  @override
  String get errorUnauthorized => 'Autentifică-te pentru a continua.';

  @override
  String get errorForbidden => 'Nu ai acces la această secțiune.';

  @override
  String get errorSessionExpired =>
      'Sesiunea a expirat. Autentifică-te din nou.';

  @override
  String get errorInvalidCredentials => 'Emailul sau parola sunt incorecte.';

  @override
  String get errorTokenRefreshFailed =>
      'Sesiunea nu a putut fi reîmprospătată. Autentifică-te din nou.';

  @override
  String get errorRequestCancelled => 'Cerere anulată.';

  @override
  String get errorInvalidFormat => 'Acest format de fișier nu este acceptat.';

  @override
  String get errorFileTooLarge => 'Fișierul este prea mare.';

  @override
  String get errorUploadFailed => 'Încărcarea a eșuat. Încearcă din nou.';

  @override
  String get errorCacheCorrupted =>
      'Datele salvate au fost deteriorate și resetate.';

  @override
  String get errorCacheNotFound => 'Nu există nimic salvat încă.';

  @override
  String get errorUserNotFound => 'Nu am găsit acest cont.';

  @override
  String get errorItemNotFound => 'Acest articol nu mai există.';

  @override
  String get errorOutfitNotFound => 'Această ținută nu mai există.';

  @override
  String get rewardsTitle => 'Recompense';

  @override
  String get rewardsNoAchievementsTitle => 'Nicio realizare încă';

  @override
  String get rewardsNoAchievementsBody =>
      'Adaugă piese și planifică ținute pentru prima realizare.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Niciun utilizator în clasament';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planifică ținute pentru puncte și apari în clasament.';

  @override
  String get legalViewPrivacyPolicy => 'Vezi Politica de confidențialitate';

  @override
  String get aiConsentAgree => 'Sunt de acord și continuu';

  @override
  String get aiConsentNotNow => 'Nu acum';

  @override
  String get imageViewerCloseTooltip => 'Închide vizualizatorul';

  @override
  String get updateReadyTitle => 'Actualizare disponibilă';

  @override
  String get updateReadyBody =>
      'Repornește FitCheck AI pentru a aplica ultimele îmbunătățiri.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI are nevoie de acces la cameră pentru a fotografia hainele și ținutele tale.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI are nevoie de acces la poze pentru a selecta imagini cu hainele și ținutele tale.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI trebuie să salveze pozele generate cu ținutele tale în galerie.';

  @override
  String get wardrobeSomePhotosSkipped => 'Unele poze au fost omise';

  @override
  String get wardrobePhotosNotAdded => 'Pozele nu au fost adăugate';

  @override
  String get wardrobePhotoNotAdded => 'Poza nu a fost adăugată';

  @override
  String get wardrobeNotStartedTitle => 'Nenînceput';

  @override
  String get wardrobeNoRoomTitle => 'Fără spațiu';

  @override
  String get wardrobeAddPhotosSemantic => 'Adaugă poze';

  @override
  String get batchAddTileLabel => 'Adaugă';

  @override
  String get batchProfileLinkLabel => 'Link profil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importă dintr-un profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Adaugă mai multe poze';

  @override
  String get wardrobeClearAction => 'Șterge';

  @override
  String get wardrobeRefreshTooltip => 'Reîmprospătează';

  @override
  String get batchNoPhotosYetTitle => 'Nicio poză încă';

  @override
  String get batchChoosePhotosAction => 'Alege pozele';

  @override
  String get batchWeFindEachPieceBody =>
      'Identificăm fiecare piesă și creăm o poză de studio pentru ea.';

  @override
  String get batchPreparingPhotosSemantic => 'Se pregătesc pozele';

  @override
  String get batchPhotosProcessedSemantic => 'Poze procesate';

  @override
  String get batchPasteProfileLinkTitle => 'Lipește un link de profil';

  @override
  String get batchPasteProfileLinkBody =>
      'Un profil public de Instagram sau Facebook. Scanăm pozele, iar tu alegi ce intră în garderobă.';

  @override
  String get batchClearLinkTooltip => 'Șterge linkul';

  @override
  String get batchStartingButton => 'Se pornește';

  @override
  String get batchStartImportAction => 'Începe importul';

  @override
  String get batchReviewEveryPhotoTitle => 'Verifici fiecare poză';

  @override
  String get batchReviewEveryPhotoBody => 'Nimic nu se adaugă până nu aprobi.';

  @override
  String get batchPrivateProfilesTitle => 'Profiluri private';

  @override
  String get batchPrivateProfilesBody =>
      'Conectează-ți contul. Instagram necesită, de asemenea, un nume de utilizator și o parolă.';

  @override
  String get batchUseAnotherLinkAction => 'Folosește alt link';

  @override
  String get batchSignInNeededTitle => 'Autentificare necesară';

  @override
  String get batchEnterYourCodeTitle => 'Introdu codul';

  @override
  String get batchUseUsernamePasswordAction =>
      'Folosește numele de utilizator și parola';

  @override
  String get batchAlreadyConnectedAction => 'M-am conectat deja în browser';

  @override
  String get batchEnterCodeAction => 'Introdu codul';

  @override
  String get batchTryAnotherWayAction => 'Încearcă altă metodă';

  @override
  String get batchLiveStatus => 'Activ';

  @override
  String get batchReconnectingStatus => 'Se reconectează';

  @override
  String get batchSignInToInstagramTitle => 'Conectare la Instagram';

  @override
  String get batchUsernameLabel => 'Nume de utilizator';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Codul, dacă folosești autentificarea în doi pași';

  @override
  String get batchAuthenticatorCodeBody =>
      'Folosește codul din 6 cifre din aplicația ta de autentificare. Codurile se schimbă rapid.';

  @override
  String get batchVerifyAction => 'Verifică';

  @override
  String get batchFindingPhotosTitle => 'Se caută fotografii';

  @override
  String get batchImportPausedTitle => 'Import întrerupt';

  @override
  String get batchProcessingPhotosTitle => 'Se procesează fotografiile';

  @override
  String get batchWaitingNextPhoto => 'Se așteaptă următoarea fotografie';

  @override
  String get batchCancelImportAction => 'Anulează importul';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Nu s-au găsit piese în această fotografie.';

  @override
  String get batchEditPieceColoursLabel => 'Culori, separate prin virgulă';

  @override
  String get batchAddToClosetAction => 'Adaugă în șifonier';

  @override
  String get batchSkipPhotoAction => 'Sari peste';

  @override
  String get batchImportCompleteTitle => 'Import finalizat';

  @override
  String get batchImportFailedTitle => 'Import eșuat';

  @override
  String get batchImportCancelledTitle => 'Import anulat';

  @override
  String get batchImportErrorBody =>
      'A apărut o problemă în timpul importului.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nu se mai importă nimic din acest profil.';

  @override
  String get batchViewClosetAction => 'Vezi dulapul';

  @override
  String get batchStartOverAction => 'Ia de la capăt';

  @override
  String get wardrobeAddPieceTitle => 'Adaugă o piesă';

  @override
  String get wardrobeAddDetailsTitle => 'Adaugă detalii';

  @override
  String get wardrobeScanningTitle => 'Se scanează';

  @override
  String get batchReviewPiecesTitle => 'Verifică piesele';

  @override
  String get wardrobeGalleryAction => 'Galerie';

  @override
  String get wardrobeCameraAction => 'Cameră';

  @override
  String get wardrobeNewBadge => 'Nou';

  @override
  String get wardrobeRemovePhotoTooltip => 'Șterge poza';

  @override
  String get batchRunInBackgroundTooltip => 'Rulează în fundal';

  @override
  String get batchStepOneOfTwo => 'Pasul 1 din 2';

  @override
  String get batchStepTwoOfTwo => 'Pasul 2 din 2';

  @override
  String get batchUploadingPhotosTitle => 'Se încarcă pozele';

  @override
  String get batchFindingPiecesTitle => 'Se caută piesele';

  @override
  String get batchMakingStudioPhotosTitle => 'Se generează poze de studio';

  @override
  String get batchStoppedLabel => 'Oprit';

  @override
  String get batchFindingPiecesStoppedTitle => 'Căutarea pieselor oprită';

  @override
  String get batchCancelledLabel => 'Anulat';

  @override
  String get batchAllDoneTitle => 'Totul este gata';

  @override
  String get batchOpeningPiecesBody => 'Se deschid piesele tale';

  @override
  String get batchNothingSavedBody => 'Nimic nu a fost salvat.';

  @override
  String get batchFindingPiecesFailedBody => 'Căutarea pieselor a eșuat.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Căutarea pieselor s-a oprit prematur.';

  @override
  String get batchStopFindingPiecesTitle => 'oprești căutarea pieselor?';

  @override
  String get batchStopFindingPiecesBody =>
      'Scanarea se oprește și nimic nu se salvează. Piesele deja găsite rămân în activitatea ta până le închizi.';

  @override
  String get batchKeepGoingAction => 'Continuă';

  @override
  String get batchTryAgainAction => 'Încearcă din nou';

  @override
  String get batchBackToPhotosAction => 'Înapoi la poze';

  @override
  String get batchSkipAllAction => 'Sari peste toate';

  @override
  String get batchIncludeAllAction => 'Include toate';

  @override
  String get batchNoPiecesFoundTitle => 'Nu s-au găsit piese';

  @override
  String get batchNoPiecesFoundBody =>
      'Nu am găsit haine în aceste fotografii.';

  @override
  String get batchChooseOtherPhotosAction => 'Alege alte poze';

  @override
  String get batchUseCaseHelper => 'Adăugat la fiecare piesă salvată.';

  @override
  String get batchDiscardPiecesTitle => 'Renunți la aceste piese?';

  @override
  String get batchDiscardPiecesBody => 'Nimic din acest lot nu este salvat.';

  @override
  String get batchKeepAction => 'Păstrează';

  @override
  String get batchDiscardAction => 'Renunță';

  @override
  String get batchRemovePieceTitle => 'Elimini această piesă?';

  @override
  String get batchRemovePieceBody => 'Nu este salvată în garderobă.';

  @override
  String get batchRemoveAction => 'Elimină';

  @override
  String get batchChoosePiecesToSave => 'Alege piesele de salvat';

  @override
  String get batchDiscardAllAction => 'Renunță la toate';

  @override
  String get batchNothingSavedRetryBody => 'Nimic salvat. Încearcă din nou.';

  @override
  String get batchNotSavedTitle => 'Nesalvat';

  @override
  String get batchSavingLabel => 'Se salvează';

  @override
  String get batchSendToBackgroundAction => 'Trimite în fundal';

  @override
  String get batchStillWorkingMessage =>
      'Lucrăm în continuare. Te anunțăm când piesele sunt gata.';

  @override
  String get batchRunningInBackgroundTitle => 'Rulează în fundal';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Fotografiile de studio s-au oprit prematur. Poți salva totuși aceste piese.';

  @override
  String get batchTapPieceToSkip => 'Atinge o piesă pentru a o sări.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Fotografiile de studio sunt pe drum. Poți pleca – te anunțăm noi.';

  @override
  String get batchLeaveAction => 'Părăsește';

  @override
  String get batchPeopleInPhotosTitle => 'Persoane în fotografii';

  @override
  String get batchIncludeAction => 'Include';

  @override
  String get batchSkipAction => 'Sari';

  @override
  String get batchYourPhotoIsUsedLabel => 'Se folosește poza ta';

  @override
  String get batchMakingStudioPhotoLabel => 'Se creează poza de studio';

  @override
  String get batchNoStudioPhotoBody =>
      'Fără poză de studio. Se folosește poza ta.';

  @override
  String get batchEnterDetailsYourselfAction => 'Introdu detaliile manual';

  @override
  String get batchChooseAnotherPhotoAction => 'Alege altă poză';

  @override
  String get batchConnectionLostTitle => 'Conexiune pierdută';

  @override
  String get batchConnectionLostBody =>
      'Verifică conexiunea și încearcă din nou.';

  @override
  String get batchDailyLimitTitle => 'Limită zilnică atinsă';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Treci la Pro pentru mai multe scanări sau introdu detaliile manual.';

  @override
  String get batchDailyLimitBodyFree =>
      'Scanările se resetează mâine. Poți introduce detaliile manual acum.';

  @override
  String get batchSeePlansAction => 'Vezi planurile';

  @override
  String get batchAiBusyTitle => 'AI-ul nostru este ocupat';

  @override
  String get batchAiBusyBody =>
      'Este o problemă de la noi. Încearcă din nou în câteva minute.';

  @override
  String get batchNoPiecesBody =>
      'Încearcă o poză mai clară sau introdu detaliile manual.';

  @override
  String get batchScanningUnavailableTitle => 'Scanarea nu este disponibilă';

  @override
  String get batchScanningUnavailableBody =>
      'Introdu detaliile manual deocamdată.';

  @override
  String get batchScanDidNotFinishTitle => 'Scanarea nu s-a finalizat';

  @override
  String get batchTryAgainBody => 'Încearcă din nou.';

  @override
  String get billingTitle => 'Abonament';

  @override
  String get billingUpgradeHeading => 'Actualizează-ți planul';

  @override
  String get billingUpgradeOnPlusBody => 'Aceleași funcții, limite mai mari.';

  @override
  String get billingUpgradeBody =>
      'Plus și Pro au aceleași funcții. Alege limitele de care ai nevoie.';

  @override
  String get billingWebUnavailableBody =>
      'Actualizările online nu sunt disponibile încă. Un cod promoțional sau de recomandare deblochează totuși Plus sau Pro. Invită prieteni mai jos pentru luni gratuite.';

  @override
  String get billingPlansStale =>
      'Nu s-au putut încărca ultimele planuri. Prețurile pot fi expirate.';

  @override
  String get billingMonthly => 'Lunar';

  @override
  String get billingYearly => 'Anual';

  @override
  String get billingCurrentPlan => 'Plan curent';

  @override
  String get billingActive => 'Activ';

  @override
  String get billingThisMonth => 'Luna aceasta';

  @override
  String get billingItemExtractions => 'Extracții de articole';

  @override
  String get billingOutfitVisualizations => 'Vizualizări de ținute';

  @override
  String get billingNearLimitUpgrade =>
      'Ești aproape de limita pe luna aceasta. Fă upgrade pentru mai multe.';

  @override
  String get billingNearLimitResets =>
      'Ești aproape de limita pe luna aceasta. Se resetează la începutul lunii viitoare.';

  @override
  String get billingStoreUnavailable =>
      'Actualizările nu sunt disponibile încă în magazin. Revino în curând.';

  @override
  String get billingManageHeading => 'Gestionează abonamentul';

  @override
  String get billingCancelPlan => 'Anulează abonamentul';

  @override
  String get billingCancelKeepsAccess =>
      'Păstrezi accesul până la sfârșitul acestei perioade de facturare.';

  @override
  String get billingCancelConfirmTitle => 'Anulezi abonamentul?';

  @override
  String get billingKeepPlan => 'Păstrează abonamentul';

  @override
  String get billingCancelPlanAction => 'Anulează abonamentul';

  @override
  String get billingBilledMonthly => 'Facturat lunar';

  @override
  String get billingBilledYearly => 'Facturat anual';

  @override
  String get billingVirtualTryOn => 'Probă virtuală';

  @override
  String get billingPrioritySupport => 'Asistență prioritară';

  @override
  String get billingDisclosureProRenewing =>
      'Pro este un abonament cu reînnoire automată';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus și Pro sunt abonamente cu reînnoire automată';

  @override
  String get billingDisclosureAppleBilling =>
      'Plata se va face prin contul tău Apple ID la confirmarea achiziției.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Plata se va face prin contul tău Google Play la confirmarea achiziției.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Abonamentul tău se reînnoiește automat pentru aceeași perioadă la același preț, cu excepția cazului în care dezactivezi reînnoirea automată cu cel puțin 24 de ore înainte de sfârșitul perioadei curente.';

  @override
  String get billingDisclosureAppleManage =>
      'Gestionează sau anulează oricând din Setări › Apple ID › Abonamente.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gestionează sau anulează oricând din Google Play › Plăți și abonamente.';

  @override
  String get billingReferFriend => 'Recomandă unui prieten';

  @override
  String get billingHowItWorks => 'Cum funcționează';

  @override
  String get billingHowShareTitle => 'Distribuie linkul tău';

  @override
  String get billingHowShareBody => 'Trimite-l unui prieten.';

  @override
  String get billingHowSignUpTitle => 'Se înregistrează';

  @override
  String get billingHowSignUpBody =>
      'Prietenul tău se alătură folosind linkul.';

  @override
  String get billingHowBothTitle => 'Primiți amândoi Pro';

  @override
  String get billingHowBothBody =>
      'Fiecare dintre voi primește o lună de Pro gratuit.';

  @override
  String get billingYourReferrals => 'Recomandările tale';

  @override
  String get billingInvited => 'Invitați';

  @override
  String get billingJoined => 'Înscriși';

  @override
  String get billingMonthsEarned => 'Luni câștigate';

  @override
  String get billingInviteFriend => 'Invită un prieten';

  @override
  String get billingInviteBody =>
      'Tu și prietenul tău primiți fiecare o lună de Pro.';

  @override
  String get billingYourCode => 'Codul tău';

  @override
  String get billingCopyLink => 'Copiază linkul';

  @override
  String get billingShareInvite => 'Trimite invitația';

  @override
  String get giftUnavailable =>
      'Invitațiile cadou nu sunt disponibile în această versiune.';

  @override
  String get giftPageTitle => 'Oferă FitCheck Pro cadou';

  @override
  String get giftNoAllowances =>
      'Nu ai nicio invitație cadou disponibilă acum.';

  @override
  String get giftFormTitle => 'Trimite o invitație gratuită';

  @override
  String get giftFormBody =>
      'Destinatarul revendică cadoul folosind acest e-mail verificat. Noi nu trimitem e-mailul în locul tău.';

  @override
  String get giftFieldFrom => 'De la';

  @override
  String get giftFieldRecipientName => 'Numele destinatarului';

  @override
  String get giftFieldRecipientEmail => 'E-mailul destinatarului';

  @override
  String get giftFieldOccasion => 'Ocazie (opțional)';

  @override
  String get giftNoOccasion => 'Fără ocazie';

  @override
  String get giftOccasionBirthday => 'Zi de naștere';

  @override
  String get giftOccasionAnniversary => 'Aniversare';

  @override
  String get giftOccasionOther => 'Altele';

  @override
  String get giftFieldCardGreeting => 'Mesaj felicitare';

  @override
  String get giftFieldCardGreetingHelper =>
      'Acesta apare pe felicitare exact așa cum este scris.';

  @override
  String get giftFieldPrivateNote => 'Notă privată (opțional)';

  @override
  String get giftCreateAction => 'Creează cadou gratuit';

  @override
  String get giftClaimedTitle => 'Cadou revendicat';

  @override
  String get giftClaimedActive => 'Cadoul tău FitCheck Pro este activ.';

  @override
  String get giftClaimedQueued =>
      'Cadoul tău FitCheck Pro începe după expirarea accesului actual.';

  @override
  String get giftLinkCopied => 'Linkul cadou a fost copiat în clipboard.';

  @override
  String get giftErrorName => 'Introdu un nume.';

  @override
  String get giftErrorEmail => 'Introdu o adresă de e-mail validă.';

  @override
  String get giftErrorGreeting => 'Introdu mesajul pentru felicitare.';

  @override
  String get giftErrorGreetingLength => 'Folosește cel mult 80 de caractere.';

  @override
  String get giftClaimAction => 'Revendică cadoul';

  @override
  String get giftCardPreview => 'Previzualizare card';

  @override
  String get giftGiftForYou => 'Un cadou pentru tine';

  @override
  String get giftGiftWaiting => 'Un cadou te așteaptă';

  @override
  String get giftOpenBody =>
      'Deschide cadourile pentru a le revendica cu emailul tău verificat.';

  @override
  String get giftOpenGifts => 'Deschide cadourile';

  @override
  String get giftSendInvitation => 'Trimite invitația';

  @override
  String get settingsAiProviderSection => 'Furnizor';

  @override
  String get settingsAiCustom => 'Personalizat';

  @override
  String get settingsAiUrlHelper =>
      'Folosește un URL public accesibil serverului. Localhost nu funcționează de pe serverele noastre.';

  @override
  String get settingsAiConnectionSection => 'Conexiune';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'Cheie API';

  @override
  String get settingsAiApiKeySaved => 'Salvat. Lăsați gol pentru a păstra.';

  @override
  String get settingsAiChatModel => 'Model de chat';

  @override
  String get settingsAiVisionModel => 'Model de viziune (opțional)';

  @override
  String get settingsAiImageModel => 'Model de imagine (opțional)';

  @override
  String get settingsAiImageModelNote =>
      'Generarea de imagini necesită completări de chat compatibile OpenAI cu response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testează conexiunea';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarGoToToday => 'Mergi la azi';

  @override
  String get calendarConnectTooltip => 'Conectează un calendar';

  @override
  String get calendarAddEvent => 'Adaugă eveniment';

  @override
  String get calendarEmptyTitle => 'Nimic planificat';

  @override
  String get calendarEmptyBody =>
      'Adaugă un eveniment și planifică ce să porți.';

  @override
  String get calendarPreviousMonth => 'Luna anterioară';

  @override
  String get calendarNextMonth => 'Luna următoare';

  @override
  String get calendarAllDay => 'Toată ziua';

  @override
  String get calendarOutfitLinked => 'Ținută conectată';

  @override
  String get calendarEventOptions => 'Opțiuni eveniment';

  @override
  String get calendarDeleteTitle => 'Ștergi acest eveniment?';

  @override
  String get calendarChangeOutfit => 'Schimbă ținută';

  @override
  String get calendarLinkOutfit => 'Adaugă o ținută';

  @override
  String get calendarRemoveOutfit => 'Elimină ținuta';

  @override
  String get calendarNewEvent => 'Eveniment nou';

  @override
  String get calendarEditEvent => 'Editează evenimentul';

  @override
  String get calendarTitleLabel => 'Titlu';

  @override
  String get calendarTitleRequired => 'Adaugă un titlu';

  @override
  String get calendarEndBeforeStart => 'Sfârșitul după ora de început';

  @override
  String get calendarStarts => 'Începe';

  @override
  String get calendarEnds => 'Se termină';

  @override
  String get calendarPlaceOptional => 'Locație (opțional)';

  @override
  String get calendarNotesOptional => 'Notițe (opțional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Creează o ținută, apoi adaugă-o la acest eveniment.';

  @override
  String get calendarBuildOutfit => 'Creează o ținută';

  @override
  String get calendarConnectionsTitle => 'Calendare';

  @override
  String get calendarConnectionsBody =>
      'Evenimentele adăugate aici rămân în FitCheck.';

  @override
  String get calendarDisconnect => 'Deconectare';

  @override
  String get calendarNotAvailable => 'Indisponibil momentan';

  @override
  String get profileSectionExplore => 'Explorează';

  @override
  String get profileNavTryOn => 'Probare';

  @override
  String get profileNavRewards => 'Recompense';

  @override
  String get profileSupport => 'Asistență';

  @override
  String get profileHelp => 'Ajutor';

  @override
  String get profileAbout => 'Despre';

  @override
  String get profileAboutBody =>
      'Garderoba, ținutele și planurile tale într-un singur loc.';

  @override
  String get profileSignOutTitle => 'Te deconectezi?';

  @override
  String get profileSignOutBody => 'Te poți autentifica din nou oricând.';

  @override
  String get profileEditTitle => 'Editează profilul';

  @override
  String get profileYourProfile => 'Profilul tău';

  @override
  String get profileBodyProfiles => 'Profile corporale';

  @override
  String get profileBodyEmptyTitle => 'Niciun profil corporal';

  @override
  String get profileBodyEmptyBody =>
      'Adaugă înălțimea și constituția pentru o potrivire mai bună.';

  @override
  String get profileBodyAdd => 'Adaugă un profil';

  @override
  String get profileBodyDefaultNote =>
      'Profilul tău implicit este folosit pentru potrivire și probare.';

  @override
  String get profileBodyDefaultBadge => 'Implicit';

  @override
  String get profileBodyMakeDefault => 'Setează implicit';

  @override
  String get profileBodyDeleteBody => 'Nu poți anula această acțiune.';

  @override
  String get profileBodyRequired => 'Obligatoriu';

  @override
  String get profileBodyCheckNumber => 'Verifică acest număr';

  @override
  String get profileBodyNew => 'Profil corporal nou';

  @override
  String get profileBodyNameHint => 'De exemplu, Eu';

  @override
  String get profileBodyHeight => 'Înălțime';

  @override
  String get profileBodyWeight => 'Greutate';

  @override
  String get profileBodyBuild => 'Constituție';

  @override
  String get profileBodySkinTone => 'Ton de piele';

  @override
  String get profileBirthDateNeededBody =>
      'Adaugă o dată a nașterii pentru ora nașterii.';

  @override
  String get profileBirthDateNeededTitle => 'Data nașterii necesară';

  @override
  String get profilePartlySavedBody =>
      'Am salvat numele și poza ta. Detaliile nașterii nu s-au salvat; încearcă din nou mai târziu.';

  @override
  String get profilePartlySavedTitle => 'Salvat parțial';

  @override
  String get profileSavedBody => 'Profilul tău a fost salvat.';

  @override
  String get profileChangePhoto => 'Schimbă poza de profil';

  @override
  String get profilePhotoLabel => 'Poză de profil';

  @override
  String get profilePhotoHint => 'Atinge pentru a alege una nouă';

  @override
  String get profileBirthDateLabel => 'Data nașterii (opțional)';

  @override
  String get profileBirthTimeLabel => 'Ora nașterii (opțional)';

  @override
  String get profileBirthTimeHelper => 'Face sugestiile vedice mai exacte';

  @override
  String get profileBirthPlaceLabel => 'Locul nașterii (opțional)';

  @override
  String get profileBirthPlaceHint => 'De exemplu, București, România';

  @override
  String get profileHelpContactTitle => 'Întreabă-ne orice';

  @override
  String get profileHelpContactBody =>
      'Trimite un mesaj și îți răspundem pe email, de obicei în cel puțin o zi.';

  @override
  String get profileHelpContactAction => 'Contactează suportul';

  @override
  String get profileHelpFaqTitle => 'Întrebări frecvente';

  @override
  String get profileFaqAddPiecesTitle => 'Cum adaug piese în dulap?';

  @override
  String get profileFaqAddPiecesBody =>
      'Apasă Adaugă articol în tabul Dulap. Fă o poză sau alege una din galerie; noi găsim fiecare piesă și o etichetăm pentru tine.';

  @override
  String get profileFaqMatchingTitle =>
      'Cum funcționează potrivirea ținutelor?';

  @override
  String get profileFaqMatchingBody =>
      'Deschide Pentru tine și alege piese pe care le deții. Îți sugerăm ce se potrivește cu ele și construim ținute complete din dulapul tău.';

  @override
  String get profileFaqTryOnTitle => 'Pot folosi propriile poze pentru probă?';

  @override
  String get profileFaqTryOnBody =>
      'Da. Adaugă o poză întreagă cu tine, apoi alege piesele pentru a le vedea pe tine.';

  @override
  String get profileFaqRewardsTitle => 'Cum câştig recompense?';

  @override
  String get profileFaqRewardsBody =>
      'Planifică și înregistrează ținute des. Seriile și realizările cresc pe măsură ce avansezi.';

  @override
  String get profileFaqPrivacyTitle => 'Este dulapul meu privat?';

  @override
  String get profileFaqPrivacyBody =>
      'Da. Dulapul și ținutele tale sunt private, cu excepția cazului în care ajuți la partajarea unui link către o singură ținută.';

  @override
  String get profileHelpMoreTitle => 'Mai mult ajutor';

  @override
  String get profileHelpGuides => 'Ghiduri';

  @override
  String get profileHelpGuidesBody => 'Cum funcționează fiecare funcție';

  @override
  String get feedbackCategoryBug => 'Ceva nu funcționează';

  @override
  String get feedbackCategoryIdea => 'O idee';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'Am nevoie de ajutor';

  @override
  String get feedbackHintBug =>
      'Ce s-a întâmplat și la ce te așteptai? Pașii ne ajută să remediem.';

  @override
  String get feedbackHintIdea => 'Ce ai dori și de ce?';

  @override
  String get feedbackHintGeneral => 'Spune-ne părerea ta sau pune o întrebare.';

  @override
  String get feedbackAttachmentLimitBody => 'Poți adăuga până la 5 imagini.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limită atinsă';

  @override
  String get feedbackImageTooLargeBody => 'Alege o imagine sub 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imaginea este prea mare';

  @override
  String get feedbackTitle => 'Trimite feedback';

  @override
  String get feedbackAboutLabel => 'Despre ce este vorba?';

  @override
  String get feedbackSubjectLabel => 'Subiect';

  @override
  String get feedbackSubjectRequired => 'Adaugă un subiect';

  @override
  String get feedbackSubjectTooShort =>
      'Subiectul trebuie săaibă cel puțin 3 caractere';

  @override
  String get feedbackDetailsLabel => 'Detalii';

  @override
  String get feedbackDetailsRequired => 'Adaugă câteva detalii';

  @override
  String get feedbackDetailsTooShort =>
      'Descrierea trebuie să aibă cel puțin 10 caractere';

  @override
  String get feedbackAddScreenshot => 'Adaugă o captură de ecran';

  @override
  String get feedbackAttachmentHint => 'Maxim 5, de 5 MB fiecare';

  @override
  String get feedbackSend => 'Trimite';

  @override
  String get feedbackEmptyTitle => 'Nimic trimis încă';

  @override
  String get feedbackEmptyBody =>
      'Ce trimiți va apărea aici împreună cu starea sa.';

  @override
  String get feedbackHistoryTitle => 'Ce ai trimis';

  @override
  String get feedbackStatusOpen => 'Deschis';

  @override
  String get feedbackStatusInProgress => 'În curs';

  @override
  String get feedbackStatusResolved => 'Rezolvat';

  @override
  String get feedbackStatusClosed => 'Închis';

  @override
  String get legalIntro =>
      'Cum îți protejăm datele și termenii de utilizare pentru FitCheck AI.';

  @override
  String get legalPolicies => 'Politici';

  @override
  String get legalPrivacySubtitle => 'Ce colectăm și de ce';

  @override
  String get legalTermsTitle => 'Termeni și condiții';

  @override
  String get legalTermsSubtitle => 'Regulile de utilizare a aplicației';

  @override
  String get legalLicences => 'Licențe open-source';

  @override
  String get legalSupportSubtitle =>
      'Ajutor, contact și cereri de confidențialitate';

  @override
  String get legalReportAbuse => 'Raportează o problemă sau abuz';

  @override
  String get permissionCameraTitle => 'Acces la cameră';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI folosește camera pentru a fotografia hainele și ținutele pentru proba virtuală AI și organizarea dulapului.';

  @override
  String get permissionPhotoTitle => 'Acces la poze';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI are nevoie de acces la poze pentru a putea selecta imagini cu haine și ținute destinate funcțiilor AI și dulapului tău.';

  @override
  String get permissionNotNow => 'Acum nu';

  @override
  String get permissionOpenSettings => 'Deschide setările';

  @override
  String authSignedInAs(String name) {
    return 'Conectat ca $name';
  }

  @override
  String get authSignedIn => 'Autentificat';

  @override
  String get authWelcomeBackTitle => 'Bun venit înapoi';

  @override
  String get authSignInFailed => 'Autentificare eșuată';

  @override
  String get authWelcomeTitle => 'Bun venit';

  @override
  String get authSignUpFailed => 'Înregistrare eșuată';

  @override
  String get authGoogleSignInFailed => 'Autentificarea cu Google a eșuat';

  @override
  String get authAppleSignInFailed => 'Autentificarea cu Apple a eșuat';

  @override
  String get authConfirmEmailTitle => 'Confirmă adresa de e-mail';

  @override
  String get authConfirmEmailBody =>
      'Verifică-ți inboxul pentru e-mailul de confirmare, apoi autentifică-te.';

  @override
  String get authClosetReady => 'Garderoba ta este gata.';

  @override
  String get authSignedOutTitle => 'Deconectat';

  @override
  String get authSignedOutBody => 'Ești deconectat.';

  @override
  String get authSignOutFailed => 'Deconectare eșuată';

  @override
  String get authEmailSentTitle => 'E-mail trimis';

  @override
  String get authResetLinkSent =>
      'Verifică-ți e-mailul pentru linkul de resetare.';

  @override
  String get authPasswordUpdatedTitle => 'Parolă actualizată';

  @override
  String get authPasswordUpdated => 'Parola ta a fost actualizată.';

  @override
  String get authPasswordNotUpdated => 'Parola nu a fost actualizată';

  @override
  String get authCouldNotSendEmail => 'E-mailul nu a putut fi trimis';

  @override
  String get authEmailNotSent => 'E-mailul nu a fost trimis';

  @override
  String get authResendSentBody => 'Am trimis un nou e-mail de confirmare.';

  @override
  String get outfitPreviewWithAi => 'Previzualizare cu AI';

  @override
  String get outfitNewPreview => 'Creează o nouă previzualizare';

  @override
  String get outfitBuilderClosetHeading => 'Dulapul tău';

  @override
  String get outfitBuilderSearchHint => 'Caută articole';

  @override
  String get outfitClearSearch => 'Șterge căutarea';

  @override
  String get outfitBuilderAddPiecesTitle => 'Adaugă mai întâi articole';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Ieșurile sunt create din articolele din dulapul tău.';

  @override
  String get outfitBuilderNoMatches => 'Niciun articol nu corespunde.';

  @override
  String get outfitNameLabel => 'Numele ținutului';

  @override
  String get outfitNameHint => 'De exemplu, InWeekend';

  @override
  String get outfitPreviewSemantic => 'Previzualizare cu AI a ținutului';

  @override
  String get outfitChoosePieces => 'Alege articole';

  @override
  String get outfitTapPiecesHint =>
      'Atinge articolele de mai jos pentru a le adăuga.';

  @override
  String get outfitShareTooltip => 'Partajare';

  @override
  String get outfitSaveFavourite => 'Salvează la favorite';

  @override
  String get outfitPiecesHeading => 'Articole';

  @override
  String get outfitWearHistoryEmpty =>
      'Poartă-l o dată și datele vor apărea aici.';

  @override
  String get outfitWearHistoryTitle => 'Istoric de purtare';

  @override
  String get outfitWearHistoryError => 'Nu au putut fi încărcate datele.';

  @override
  String get outfitWornOn => 'Purtat pe';

  @override
  String get outfitEditTitle => 'Editează ținut';

  @override
  String get outfitSavedPhotosFailed => 'Detaliile salvate, fotografiile nu';

  @override
  String get outfitNoPhotosBody =>
      'Nicio fotografie încă. Ținutul afișează articolele în loc.';

  @override
  String get outfitOccasionLabel => 'Ocazie';

  @override
  String get outfitOccasionNone => 'Nicio';

  @override
  String get outfitTagsHint => 'Separat prin virgulă';

  @override
  String get outfitDraftBody => 'Ascuns din lista principală';

  @override
  String get outfitPublic => 'Public';

  @override
  String get outfitPublicBody => 'Oricine cu linkul poate să-l vadă';

  @override
  String get outfitDeleteFromDetail =>
      'Șterge acest ținut de pe pagina de detalii.';

  @override
  String get outfitNewCollection => 'Colecție nouă';

  @override
  String get outfitNoCollectionsTitle => 'Nicio colecție încă';

  @override
  String get outfitNoCollectionsBody =>
      'Grupează ținuturile după călătorie, sezon sau dispoziție.';

  @override
  String get outfitCreateCollection => 'Creează o colecție';

  @override
  String get outfitAddOutfits => 'Adaugă ținuturi';

  @override
  String get outfitRename => 'Redenumește';

  @override
  String get outfitCollectionDeleteBody => 'Ținuturile din ea sunt păstrate.';

  @override
  String get outfitCollectionsNotLoaded => 'Ținuturi încărcate';

  @override
  String get outfitRenameCollection => 'Redenumește colecția';

  @override
  String get outfitDescriptionOptional => 'Descriere (opțional)';

  @override
  String get outfitAllInCollection =>
      'Toate ținuturile sunt deja în această colecție.';

  @override
  String get photoshootSubtitleUpload =>
      'Portrete de studio din fotografiile tale';

  @override
  String get photoshootSubtitleConfigure =>
      'Alege un stil, un format și un număr';

  @override
  String get photoshootSubtitleGenerating => 'Aceasta durează un minut sau doi';

  @override
  String get photoshootAddPhotosSemantic => 'Adaugă fotografii din galeria ta';

  @override
  String get photoshootUploadTitle => 'Adaugă 1-4 fotografii cu tine';

  @override
  String get photoshootUploadBody => 'Atinge pentru a alege din galerie';

  @override
  String get photoshootAddToContinue => 'Adaugă o fotografie pentru a continua';

  @override
  String get photoshootAddAnotherPhoto => 'Adaugă altă fotografie';

  @override
  String get photoshootTipsTitle => 'Pentru cele mai bune rezultate';

  @override
  String get photoshootTipsBody =>
      'Folosește fotografii clare, bine luminate, cu fața ta din mai unghiuri. Omită ochelarii de soare și pălăriile.';

  @override
  String get photoshootStarting => 'Se începe';

  @override
  String get photoshootCancelling => 'Se anulează';

  @override
  String get photoshootFailed => 'Eșuat';

  @override
  String get recommendTabMatches => 'Potriviri';

  @override
  String get recommendTabComplete => 'Complet';

  @override
  String get recommendTabWeather => 'Meteo';

  @override
  String get recommendTabColours => 'Culori';

  @override
  String get recommendTabShop => 'Magazin';

  @override
  String get recommendNoMatchesTitle => 'Nicio potrivire încă';

  @override
  String get recommendNoMatchesBody =>
      'Alege o piesă și îți vom găsi ce merge cu ea.';

  @override
  String get recommendPickPiece => 'Alege o piesă';

  @override
  String get recommendNothingMatchesTitle => 'Nimic nu se potrivește încă';

  @override
  String get recommendNothingMatchesBody =>
      'Încearcă alte piese sau adaugă la dulap.';

  @override
  String get recommendChangePieces => 'Schimbă piesele';

  @override
  String get recommendDefaultReason => 'Se potrivește cu piesele alese.';

  @override
  String get recommendCompleteTitle => 'Completează look';

  @override
  String get recommendCompleteBody => 'Alege o piesă și noi completăm restul.';

  @override
  String get recommendWorking => 'Se procesează';

  @override
  String get recommendGenerate => 'Generează';

  @override
  String get recommendChooseStyleBody => 'Alege un stil, apoi generează.';

  @override
  String get recommendNoLooksTitle => 'Niciun look pentru aceste piese';

  @override
  String get recommendNoLooksBody => 'Încearcă alt stil sau alte piese.';

  @override
  String get recommendDefaultLook => 'Un look pentru piesele tale';

  @override
  String get recommendNoPiecesBody => 'Nicio piesă pentru acest look.';

  @override
  String get recommendCityLabel => 'Oraș';

  @override
  String get recommendCheck => 'Verifică';

  @override
  String get recommendWeatherTitle => 'Care e vremea?';

  @override
  String get recommendWeatherBody => 'Introdu orașul pentru sugestii de azi.';

  @override
  String get recommendWearToday => 'Purtat azi';

  @override
  String get recommendWeatherNoPieces =>
      'Nicio piesă în dulap pentru această vreme.';

  @override
  String get recommendBudgetLabel => 'Buget până la';

  @override
  String get recommendLooking => 'Caut';

  @override
  String get recommendFindWhatToBuy => 'Găsește ce să cumperi';

  @override
  String get recommendFillGapsTitle => 'Completează golurile';

  @override
  String get recommendFillGapsBody =>
      'Stabilește bugetul și îți sugerez ce lipsește.';

  @override
  String get recommendNoGapsTitle => 'Fără goluri';

  @override
  String get recommendNoGapsBody =>
      'Probați un buget mai mare sau altă categorie.';

  @override
  String get recommendMoodEveryday => 'Zilnic';

  @override
  String get recommendMoodBigMeeting => 'Ședință importantă';

  @override
  String get recommendDayLabel => 'Ziua';

  @override
  String get recommendReadingStars => 'Citesc stelele';

  @override
  String get recommendGetMyColours => 'Culoarile mele';

  @override
  String get recommendLuckyColoursTitle => 'Culoarile norocoase';

  @override
  String get recommendLuckyColoursBody =>
      'Alege o zi și îți sugerează culori și piese potrivite.';

  @override
  String get recommendLuckyColoursSection => 'Culori norocoase';

  @override
  String get recommendAvoidColoursSection => 'Culori de evitat';

  @override
  String get recommendBirthDateTitle => 'Adaugă data nașterii';

  @override
  String get recommendBirthDateBody =>
      'Ai nevoie de data nașterii pentru a citi culorile.';

  @override
  String get recommendEditProfile => 'Modifică profilul';

  @override
  String get recommendNothingThisDay => 'Nimic pentru această zi.';

  @override
  String get recommendUnnamedColour => 'Culoare nespecificată';

  @override
  String get recommendFromCloset => 'Din dulapul tău';

  @override
  String get recommendNoPiecesInColours => 'Nicio piesă în aceste culori încă.';

  @override
  String get recommendOutfitIdeas => 'Idei de ținute';

  @override
  String get recommendNoOutfitsInColours =>
      'Nicio ținută completă în aceste culori încă.';

  @override
  String get recommendDefaultOutfitIdea => 'O idee de ținută';

  @override
  String get recommendPickUpToThree => 'Alege până la trei piese';

  @override
  String get recommendEmptyClosetBody =>
      'Adaugă câteva piese mai întâi, apoi revino pentru potriviri.';

  @override
  String get dashboardDressForDay => 'Îmbracă-te pentru ziua care urmează.';

  @override
  String get dashboardOutfitOfDay => 'Tinuta zilei';

  @override
  String get dashboardFreshLook => 'Un look nou';

  @override
  String get subscriptionManageInStoreTitle => 'Gestionează în magazin';

  @override
  String get subscriptionManageInStoreBody =>
      'Acest plan este facturat prin magazin. Gestionează-l din setările contului tău de magazin.';

  @override
  String get subscriptionCancelledTitle => 'Abonament anulat';

  @override
  String get subscriptionCancelledBody =>
      'Planul rămâne activ până la sfârșitul acestei perioade de facturare.';

  @override
  String get subscriptionCancelFailedTitle => 'Nu s-a putut anula';

  @override
  String get subscriptionCouldNotOpenTitle => 'Nu s-a putut deschide';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Nu s-a putut deschis gestionarea facturării.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Nu s-a putut deschis link-ul.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Link-ul nu s-a încărcat';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Link-ul de recomandare nu s-a încărcat. Încearcă din nou.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiat';

  @override
  String get subscriptionReferralCopiedBody =>
      'Link-ul de recomandare a fost copiat.';

  @override
  String get subscriptionReferralShareSubject => 'Încearcă FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Alătură-te lui FitCheck AI și obținem amândouă un lunar Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copiat';

  @override
  String get subscriptionShareUnavailableBody =>
      'Partajarea nu este disponibilă, așa că am copiat link-ul.';

  @override
  String get subscriptionShareFailedTitle => 'Partajare eșuată';

  @override
  String get subscriptionShareFailedBody =>
      'Copiază link-ul de pe pagina de recomandare.';

  @override
  String get subscriptionStoreReadyTitle => 'Store pregătit';

  @override
  String get subscriptionStoreReadyBody =>
      'Prețurile din store sunt disponibile. Poți face upgrade acum.';

  @override
  String get purchaseFailedTitle => 'Achiziție eșuată';

  @override
  String get purchaseUnavailableTitle => 'Achiziție indisponibilă';

  @override
  String get purchaseIapUnavailableBody =>
      'Achizițiile în-app nu sunt disponibile pe acest dispozitiv.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Acest plan nu este încă disponibil pentru achiziție.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Acest plan nu este încă disponibil în store. Verifică mai târziu.';

  @override
  String get purchaseStartFailedBody =>
      'Achiziția nu a putut fi inițiată. Încearcă din nou.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Checkout nu a returnat un link de plată.';

  @override
  String get purchasePendingTitle => 'Achiziție în așteptare';

  @override
  String get purchasePendingBody =>
      'Achiziția ta așteaptă aprobarea. Vei avea acces de îndată ce este aprobată.';

  @override
  String get purchaseFailedBody => 'Achiziția a eșuat. Încearcă din nou.';

  @override
  String get purchaseRestoredTitle => 'Restaurat';

  @override
  String get purchaseRestoredBody => 'Achizițiile tale au fost restaurate.';

  @override
  String get purchaseActiveTitle => 'Abonament activ';

  @override
  String get purchaseActiveBody => 'Abonamentul tău este activ. Bine ai venit.';

  @override
  String get purchaseSignInRequiredTitle => 'Necesită autentificare';

  @override
  String get purchaseSignInRequiredBody =>
      'Autentifică-te pentru a finaliza achiziția.';

  @override
  String get purchaseErrorTitle => 'Eroare de achiziție';

  @override
  String get purchaseInvalidTransactionBody =>
      'Achiziția nu a inclus un ID de tranzacție verificabil.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificare în așteptare';

  @override
  String get purchaseVerificationPendingBody =>
      'Nu am putut verifica achiziția ta în magazin momentan. Procesul va fi finalizat automat și nu vei fi taxat(ă) de două ori.';

  @override
  String get purchaseNotAppliedTitle => 'Achiziție neaplicată';

  @override
  String get purchaseNotAppliedBody =>
      'Achiziția ta nu a putut fi aplicată contului tău. Contactează asistența și nu o achiziționa din nou.';

  @override
  String get purchaseRestoreFailedTitle => 'Restaurare eșuată';

  @override
  String get purchaseRestoreFailedBody =>
      'Nu s-au putut restaura achizițiile. Încearcă din nou.';

  @override
  String get purchaseRecoveredActiveBody => 'Abonamentul tău este activ.';

  @override
  String get purchaseCompleteTitle => 'Achiziție completată';

  @override
  String get giftCreateFailedTitle => 'Nu s-a putut crea cadoul';

  @override
  String get giftClaimFailedTitle => 'Nu s-a putut revendica cadoul';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cadouri pentru tine',
      one: 'Un cadou pentru tine',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 lună',
      '12': '1 an',
      'other': '$months luni',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining rămase',
      one: '1 rămas',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration de FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender ți-a trimis $duration de FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Un cadou FitCheck Pro pentru $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'De la $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Pentru $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'De la $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'destinatariul tău';

  @override
  String get giftPreviewPlaceholderSender => 'tu';

  @override
  String get settingsSavedTitle => 'Salvat';

  @override
  String get settingsNotSavedTitle => 'Nesalvat';

  @override
  String get settingsAiChooseProviderBody => 'Alege un furnizor.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Furnizorul personalizat necesită o URL de API.';

  @override
  String get settingsAiKeyRequiredBody => 'Introdu o cheie de API.';

  @override
  String get settingsAiSavedBody => 'Setările tale AI sunt salvate.';

  @override
  String get settingsAiMissingDetailsTitle => 'Date lipsă';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Introdu o URL de API și un model de chat pentru testare.';

  @override
  String get settingsAiKeyNeededTitle => 'Cheie de API necesară';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Introdu cheia API pentru testare. Cheia salvată rămâne privată.';

  @override
  String get settingsAiKeyToTestBody => 'Introdu cheia API pentru testare.';

  @override
  String get settingsAiConnectedTitle => 'Conectat';

  @override
  String get settingsAiConnectedBody => 'Conexiunea funcționează.';

  @override
  String get settingsAiTestFailedTitle => 'Testul a eșuat';

  @override
  String get settingsPreferencesSavedBody => 'Preferințele au fost salvate.';

  @override
  String get settingsPasswordNotChangedTitle => 'Parola nu a fost schimbată';

  @override
  String get settingsOAuthPasswordBody =>
      'Acest cont se autentifică cu Google sau Apple. Folosiți „Parolă uitată” pentru a configura mai întâi o parolă.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Parola actuală este incorectă.';

  @override
  String get settingsExportReadyTitle => 'Export pregătit';

  @override
  String get settingsExportReadyBody =>
      'Exportul datelor este gata de descărcat.';

  @override
  String get settingsLinkCopiedTitle => 'Link copiat';

  @override
  String get settingsExportClipboardBody =>
      'Nu am putut deschide browserul, deci am copiat linkul de descărcare. Lipiți-l într-un browser curând: expiră.';

  @override
  String get settingsExportFailedTitle => 'Export eșuat';

  @override
  String get settingsAccountNotDeletedTitle => 'Contul nu a fost șters';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Puteți adăuga până la $max fotografii.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limită de fotografii';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Adăugați cel puțin o fotografie.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Fără fotografii';

  @override
  String get photoshootDescribeLookBody => 'Descrieți aspectul dorit.';

  @override
  String get photoshootPromptNeededTitle => 'Este necesar promptul';

  @override
  String get photoshootConsentFeatureLabel => 'Ședință foto AI';

  @override
  String get photoshootStatusPreparing => 'Se pregătesc fotografiile';

  @override
  String get photoshootStatusGenerating => 'Se generează';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Grup $current din $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done din $total finalizate';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generarea a eșuat.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready gata, $failed eșuate.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Parțial finalizat';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografii sunt gata.',
      one: '1 fotografie este gata.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Am pierdut conexiunea. Vă rugăm să încercați din nou.';

  @override
  String get photoshootCouldNotCancelTitle => 'Nu a putut fi anulat';

  @override
  String get photoshootRetryFailedTitle => 'Reîncercarea a eșuat';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Fotografia $number este gata.';
  }

  @override
  String get photoshootReplacedTitle => 'Înlocuit';

  @override
  String get photoshootSavedToGalleryBody => 'Salvat în galeria dvs.';

  @override
  String get photoshootSavedTitle => 'Salvat';

  @override
  String get photoshootNotSavedTitle => 'Nu a fost salvat';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toate cele $count fotografii sunt în galeria dvs.',
      one: '1 fotografie este în galeria dvs.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved din $total salvate.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Unele fotografii nu au fost salvate';

  @override
  String get tryonConsentFeatureLabel => 'Inceperea virtuală';

  @override
  String get tryonAvatarUpdatedBody => 'Fotografia dvs. a fost actualizată.';

  @override
  String get tryonSavedTitle => 'Salvat';

  @override
  String get tryonUploadFailedTitle => 'Încărcarea a eșuat';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Alegeți mai întâi o fotografie cu haine.';

  @override
  String get tryonNoGarmentTitle => 'Fără haine';

  @override
  String get tryonWaitForUploadBody => 'Așteptați până se încarcă fotografia.';

  @override
  String get tryonStillUploadingTitle => 'Se încarcă încă';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Adăugați mai întâi o fotografie cu dumneavoastră.';

  @override
  String get tryonReadyBody => 'Începerea virtuală este gata.';

  @override
  String get tryonFailedTitle => 'Inceperea virtuală a eșuat';

  @override
  String get tryonSavedToGalleryBody => 'Salvat în galeria dvs.';

  @override
  String get tryonNotSavedTitle => 'Nu a fost salvat';

  @override
  String get calendarEventAddedBody => 'Eveniment adăugat';

  @override
  String get calendarEventPlannedTitle => 'Planificat';

  @override
  String get calendarEventSavedBody => 'Eveniment salvat';

  @override
  String get calendarSavedTitle => 'Salvat';

  @override
  String get calendarEventNotSavedTitle => 'Eveniment ne salvat';

  @override
  String get calendarEventRemovedBody => 'Eveniment eliminat';

  @override
  String get calendarEventDeletedTitle => 'Șters';

  @override
  String get calendarEventNotDeletedTitle => 'Evenimentul nu a fost șters';

  @override
  String get calendarOutfitNotLinkedTitle => 'Ținuta nu a fost asociată';

  @override
  String get calendarLinkedTitle => 'Asociat';

  @override
  String get calendarOutfitNotRemovedTitle => 'Ținuta nu a fost eliminată';

  @override
  String get calendarOutfitRemovedBody => 'Ținută eliminată';

  @override
  String get calendarDisconnectedBody => 'Calendar deconectat';

  @override
  String get calendarDisconnectedTitle => 'Deconectat';

  @override
  String get calendarNotDisconnectedTitle => 'Calendarul nu a fost deconectat';

  @override
  String get calendarTodayLabel => 'azi';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count evenimente',
      one: '1 eveniment',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'de la $start la $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, ținută asociată';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '„$title” va fi eliminat.';
  }

  @override
  String get calendarThisAppLabel => 'Această aplicație';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Sincronizarea cu $provider nu este încă disponibilă. Poți adăuga evenimente aici.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dum';

  @override
  String get calendarWeekdayMonShort => 'Lun';

  @override
  String get calendarWeekdayTueShort => 'Mar';

  @override
  String get calendarWeekdayWedShort => 'Mie';

  @override
  String get calendarWeekdayThuShort => 'Joi';

  @override
  String get calendarWeekdayFriShort => 'Vin';

  @override
  String get calendarWeekdaySatShort => 'Sâm';

  @override
  String get calendarWeekdayMonday => 'Luni';

  @override
  String get calendarWeekdayTuesday => 'Marți';

  @override
  String get calendarWeekdayWednesday => 'Miercuri';

  @override
  String get calendarWeekdayThursday => 'Joi';

  @override
  String get calendarWeekdayFriday => 'Vineri';

  @override
  String get calendarWeekdaySaturday => 'Sâmbătă';

  @override
  String get calendarWeekdaySunday => 'Duminică';

  @override
  String get outfitSavedToFavouritesBody => 'Salvat la favorite';

  @override
  String get outfitRemovedFromFavouritesBody => 'Eliminat de la favorite';

  @override
  String get outfitNotSavedTitle => 'Nu a fost salvat';

  @override
  String get outfitLoggedAsWornBody => 'Înregistrat ca purtat azi.';

  @override
  String get outfitNicePickTitle => 'Bună alegere';

  @override
  String get outfitRemovedBody => 'Outfit eliminat.';

  @override
  String get outfitDeletedTitle => 'Șters';

  @override
  String get outfitNotDeletedTitle => 'Nu a fost șters';

  @override
  String get outfitDuplicatedBody => 'O copiere se află în outfit-urile tale.';

  @override
  String get outfitDuplicatedTitle => 'Duplicat';

  @override
  String get outfitNotDuplicatedTitle => 'Nu a fost duplicat';

  @override
  String get outfitNotSharedTitle => 'Nu a fost partajat';

  @override
  String outfitCollectionReadyBody(String name) {
    return '„$name” este gata.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Colectia nu a fost creată';

  @override
  String get outfitCollectionUpdatedBody => 'Colectie actualizată.';

  @override
  String get outfitCollectionNotUpdatedTitle =>
      'Colectia nu a fost actualizată';

  @override
  String get outfitCollectionDeletedBody => 'Colectie ștearsă.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Colectia nu a fost ștearsă';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfituri adăugate.',
      one: '1 outfit adăugat.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle =>
      'Outfit-uri nu au fost adăugate';

  @override
  String get outfitPreviewNotCreatedTitle => 'Previzualizarea nu a fost creată';

  @override
  String get outfitGiveNameBody => 'Dă outfit-ului un nume.';

  @override
  String get outfitNameMissingTitle => 'Nume';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Alege cel puțin o piesă.';

  @override
  String outfitCreatedBody(String name) {
    return '$name se află în outfit-urile tale.';
  }

  @override
  String get outfitSavedTitle => 'Salvat';

  @override
  String get wardrobeAddedToFavouritesBody => 'Adăugat la favorite';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Eliminat de la favorite';

  @override
  String get wardrobeNotSavedTitle => 'Nu a fost salvat';

  @override
  String get wardrobeLoggedAsWornBody => 'Adăugat ca purtat azi.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Eliminat din garderobă.';

  @override
  String get wardrobeDeletedTitle => 'Șters';

  @override
  String get wardrobeNotDeletedTitle => 'Nu a fost șters';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piese eliminate din garderobă.',
      one: '1 piesă eliminată din garderobă.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extracție garderobă AI';

  @override
  String get itemAddScanJobLabel => 'Scanare';

  @override
  String get itemAddFoundEarlierBody => 'Găsit într-o scanare anterioară';

  @override
  String get itemAddLookingAtPhoto => 'Analizează fotografia';

  @override
  String get itemAddExtractionFailedBody => 'Eșec la extragere';

  @override
  String get itemAddJobFailedBody => 'Eșec la procesare';

  @override
  String get itemAddConnectionLostBody =>
      'Conexiune întreruptă. Încearcă din nou.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Conexiune pierdută în timpul procesării.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Piesa $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Piesă';

  @override
  String get itemAddNotCancelledTitle => 'Nu a fost anulat';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piese sunt în garderobă.',
      one: '1 piesă este în garderobă.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved din $total piese salvate. Atinge salvarea pentru a încerca restul.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Unele piese nu au fost salvate';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Alege cel puțin o fotografie.';

  @override
  String get batchPhotoUnreadableBody =>
      'Această fotografie nu a putut fi citită.';

  @override
  String get batchNoPhotosReadableBody =>
      'Nicio fotografie din acestea nu a putut fi citită. Încearcă alte fotografii.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografii',
      one: '1 fotografie',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Am pierdut conexiunea în timpul procesării. Încearcă din nou.';

  @override
  String get batchNotCancelledTitle => 'Nu a fost anulat';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Linkurile la postări nu sunt suportate. Introdu un link de profil.';

  @override
  String get batchLinkSpacesBody => 'Linkurile nu pot conține spații.';

  @override
  String get batchEnterProfileLinkBody =>
      'Introdu un link de profil Instagram sau Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Introdu un link de profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Pagina de autentificare nu s-a deschis. Încearcă din nou.';

  @override
  String get batchSignInBrowserBody =>
      'Autentifică-te în browser, apoi revino în FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Conectează-ți contul';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Introdu codul din aplicația ta de autentificare.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram necesită o verificare de securitate. Autentifică-te mai întâi în browser.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Introdu din nou numele de utilizator și parola.';

  @override
  String get batchSignInFailedBody =>
      'Autentificarea a eșuat. Verifică numele de utilizator și parola.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Autentifică-te pentru a continua importul.';

  @override
  String get batchAccountNotConnectedBody => 'Contul nu a fost conectat.';

  @override
  String get batchAccountConnectedTitle => 'Cont conectat';

  @override
  String get batchNotConnectedTitle => 'Neconectat';

  @override
  String get batchImportConnectionLostBody =>
      'Am pierdut conexiunea la import. Actualizează pentru a verifica.';

  @override
  String batchPickUpToBody(int max) {
    return 'Alege până la $max fotografii. Identificăm piesele.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count din $total fotografii';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Pregătire fotografie $done din $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Găsește piese în $count fotografii',
      one: 'Găsește piese în 1 fotografie',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Contul tău $platform folosește autentificare în doi pași. Introdu codul numeric de 6 cifre din aplicația de autentificare.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Acest profil $platform este privat sau necesită autentificare pentru a afișa fotografii.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Conectează-te cu $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografii găsite până acum',
      one: '1 fotografie găsită până acum',
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
    return '$processed din $total procesate · $added adăugate · $waiting în așteptare · $skipped sărite';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Scanare fotografie $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Fotografia $number este urmatoarea';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Fotografia $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piese găsite',
      one: '1 piesă găsită',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografii au fost adăugate în dulapul tău.',
      one: '1 fotografie a fost adăugată în dulapul tău.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count alte fotografii de studio vin. Puteți salva ce este gata sau plecați — vă vom anunța.',
      one:
          '1 altă fotografie de studio vine. Puteți salva ce este gata sau plecați — vă vom anunța.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Nesalvat încă: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces piese',
      one: '1 piesă',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotografii',
      one: '1 fotografie',
    );
    return '$_temp0 din $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen alese. Atingeți o piesă pentru a o sari.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvare $count piese',
      one: 'Salvare 1 piesă',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvează $count piese',
      one: 'Salvează 1 piesă',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Profilul tău de corp a fost salvat.';

  @override
  String get bodyProfileSavedTitle => 'Salvat';

  @override
  String get bodyProfileNotSavedTitle => 'Nesalvat';

  @override
  String get bodyProfileSetDefaultBody => 'Setează ca profil implicit.';

  @override
  String get bodyProfileDeletedBody => 'Profil de corp șters.';

  @override
  String get bodyProfileDeletedTitle => 'Șters';

  @override
  String get bodyProfileNotDeletedTitle => 'Neșters';

  @override
  String get feedbackNotSentTitle => 'Nesosit';

  @override
  String get feedbackSentBody =>
      'Mulțumim. Citim fiecare mesaj și răspundem dacă avem nevoie de mai multe.';

  @override
  String get feedbackSentTitle => 'Feedbac trimis';

  @override
  String get recommendUnnamedPiece => 'Piesă nesemnificată';

  @override
  String get recommendEnterCityBody =>
      'Introduce-ți orașul pentru selecții pe vreme.';

  @override
  String get recommendWhichCityTitle => 'Care oraș?';

  @override
  String get aiConsentSheetTitle =>
      'Partajarea fotografiilor cu un serviciu AI';

  @override
  String get aiConsentSheetBody =>
      'Pentru a crea imaginile tale de probă și de sesiune foto, FitCheck AI trimite fotografiile pe care le oferi (inclusiv imagini cu fața și corpul) unui furnizor terț de încredere AI (cum ar fi OpenAI sau Google Gemini) pentru procesare. Aceștia generează imaginile și nu le folosesc pentru antrenarea modelelor conform termenilor noștri. Fotografiile sunt transmise în siguranță și nu sunt niciodată partajate pentru publicitate.';

  @override
  String get aiConsentSheetPermission =>
      'Prin continuare, acorzi permisiunea explicită de a-ți partaja fotografiile cu acești furnizori AI pentru generarea imaginilor.';

  @override
  String get skeletonsLoadMoreFailed => 'Nu am putut încărca mai multe.';

  @override
  String get jobsPiecesReadyTitle => 'Piesele tale sunt gata';

  @override
  String get jobsScanStoppedTitle => 'Scanarea s-a oprit';

  @override
  String get jobsNothingSavedBody =>
      'Nimic nu a fost salvat. Încearcă din nou.';

  @override
  String get jobsPhotoUploadFailedBody => 'Încărcarea fotografiei a eșuat.';

  @override
  String get authGoogleSignInStartFailed =>
      'Nu am putut iniția Google Sign-In. Te rugăm să încerci din nou.';

  @override
  String get referralAppliedTitle => 'Recomandare aplicată!';

  @override
  String get billingStoreUnavailableBody =>
      'Achizițiile din magazin nu sunt disponibile pe acest dispozitiv.';

  @override
  String get billingPurchaseProcessingBody =>
      'Această achiziție este încă în procesare. Deschide din nou aplicația peste un minut pentru a-ți vedea planul.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Încărcarea avatarului nu a returnat un URL de imagine.';

  @override
  String get rewardsDayStreakLabel => 'streak zilnic';

  @override
  String rewardsBestStreak(int days) {
    return 'Cele mai bune $days zile';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Necesită acces la $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Accesul la $permission este în prezent refuzat. Deschideți Setările pentru a-l permite, apoi reveniți și încercați din nou.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Pasul $step din 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Pasul $step din $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Elimină imaginea $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Elimină imaginea $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points p.';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'E-mail la $email. Analizăm rapoartele în 24 de ore.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Elimină $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Ștergi „$name”?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Adaugă la „$name”';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '„$name” a fost eliminat. Articolele rămân în dulapul tău.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Afișează toate cele $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count rămase astăzi';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Fotografia $index a eșuat';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected din $max fotografii';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Constituție $shape · Ten $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Ștergi $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opțiuni pentru $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Cel mai purtat: $name, de $count ori';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: nesetat';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'Potrivire $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked din $max selectate';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Elimină $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioritate $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Acest plan este facturat prin $store. Modifică-l sau anulează-l în setările contului tău din $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gestionează în $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current din $max utilizate';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Aproape ${seconds}s rămase';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done din $total fotografii de studio sunt gata';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready din $total fotografii de studio sunt gata. Atinge un articol pentru a-l sări.';
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
  String get profileFieldNotSet => 'Nu';
}
