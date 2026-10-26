// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Domů';

  @override
  String get tabPhotoshoot => 'Focení';

  @override
  String get tabCloset => 'Šatník';

  @override
  String get tabOutfits => 'Outfity';

  @override
  String get tabMore => 'Více';

  @override
  String get actionAddItem => 'Přidat kousek';

  @override
  String get actionCreateOutfit => 'Vytvořit outfit';

  @override
  String get actionCancel => 'Zrušit';

  @override
  String get actionDelete => 'Smazat';

  @override
  String get actionSave => 'Uložit';

  @override
  String get actionRetry => 'Zkusit znovu';

  @override
  String get actionDone => 'Hotovo';

  @override
  String get actionNext => 'Další';

  @override
  String get actionBack => 'Zpět';

  @override
  String get actionClose => 'Zavřít';

  @override
  String get actionSearch => 'Hledat';

  @override
  String get actionContinue => 'Pokračovat';

  @override
  String get stateLoading => 'Načítání';

  @override
  String get stateErrorTitle => 'Něco se pokazilo';

  @override
  String get stateErrorBody =>
      'Zkuste to znovu. Pokud potíže přetrvají, kontaktujte podporu.';

  @override
  String get stateOfflineTitle => 'Jste offline';

  @override
  String get stateOfflineBody =>
      'Připojte se k internetu pro synchronizaci šatníku a generování outfitů.';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsAccountSection => 'Účet';

  @override
  String get settingsPreferencesSection => 'Předvolby';

  @override
  String get settingsPlanBilling => 'Předplatné a platby';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get settingsNotifications => 'Oznámení';

  @override
  String get settingsUnits => 'Měrné jednotky';

  @override
  String get settingsAppearance => 'Vzhled';

  @override
  String get settingsPrivacySection => 'Soukromí a data';

  @override
  String get settingsAboutSection => 'O aplikaci';

  @override
  String get settingsSignOut => 'Odhlásit se';

  @override
  String get settingsDeleteAccount => 'Smazat účet';

  @override
  String get settingsDeleteAccountTitle => 'Smazat váš účet?';

  @override
  String get settingsDeleteAccountBody =>
      'Tímto odstraníte svůj šatník, outfity, fotky i profil. Tuto akci nelze vrátit zpět.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrické (cm, kg)';

  @override
  String get languageTitle => 'Jazyk';

  @override
  String get languageSystem => 'Jazyk zařízení';

  @override
  String get languageSystemBody => 'FitCheck AI používá jazyk vašeho telefonu.';

  @override
  String get languageSearchHint => 'Hledat jazyky';

  @override
  String get languageCurrent => 'Aktuální';

  @override
  String get languageReviewNote =>
      'Tento překlad je nový. Dejte nám vědět, pokud něco nesedí.';

  @override
  String get languageChanged => 'Jazyk byl aktualizován';

  @override
  String get paywallTitle => 'Vyberte si tarif';

  @override
  String get paywallTrialBadge => '1 měsíc zdarma';

  @override
  String get paywallTrialTitle => 'První měsíc Pro máte zdarma';

  @override
  String get paywallTrialBody =>
      'Nahrávejte celý šatník najednou. Další kousky můžete přidávat postupně.';

  @override
  String get paywallFreeForeverTitle => 'Zadarmo navždy';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Karta není potřeba. Každý měsíc získáte $uploads nahrání s AI, $outfits outfitů a $images fotek denně.';
  }

  @override
  String get paywallCtaTrial => 'Získat měsíc zdarma';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Přejít na $plan';
  }

  @override
  String get paywallRestore => 'Obnovit nákupy';

  @override
  String get paywallManage => 'Spravovat předplatné';

  @override
  String get paywallTerms => 'Podmínky použití';

  @override
  String get paywallPrivacy => 'Zásady ochrany osobních údajů';

  @override
  String get paywallPerMonth => 'za měsíc';

  @override
  String get paywallPerYear => 'za rok';

  @override
  String get paywallBestValue => 'Nejvýhodnější';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Bezplatné zkušební období pouze pro nové předplatitele. Po jeho skončení se předplatné Pro obnoví za cenu $price, pokud jej nezrušíte alespoň 24 hodin před koncem.';
  }

  @override
  String get introTitle => 'Váš šatník konečně přehledně';

  @override
  String get introBody =>
      'Vyfoťte své oblečení jednou. Získejte tipy na oblečení, náhledy zkoušení a studiové fotky z toho, co už vlastníte.';

  @override
  String get introStart => 'Začít';

  @override
  String get introHaveAccount => 'Už mám účet';

  @override
  String get introSkip => 'Přeskočit';

  @override
  String get authSignIn => 'Přihlásit se';

  @override
  String get authSignUp => 'Vytvořit účet';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Heslo';

  @override
  String get authForgotPassword => 'Zapomenuté heslo?';

  @override
  String get authContinueApple => 'Pokračovat přes Apple';

  @override
  String get authContinueGoogle => 'Pokračovat přes Google';

  @override
  String get authOrDivider => 'nebo';

  @override
  String get wardrobeTitle => 'Šatník';

  @override
  String get wardrobeEmptyTitle => 'Váš šatník je prázdný';

  @override
  String get wardrobeEmptyBody =>
      'Přidejte první kousek, nebo nahrávejte celou tyč s ramínky najednou.';

  @override
  String get wardrobeAddFirst => 'Přidat první kousek';

  @override
  String get wardrobeSearchHint => 'Prohledat šatník';

  @override
  String get categoryTops => 'Topy';

  @override
  String get categoryBottoms => 'Spodní díly';

  @override
  String get categoryShoes => 'Boty';

  @override
  String get categoryAccessories => 'Doplňky';

  @override
  String get categoryOuterwear => 'Svrchní oblečení';

  @override
  String get categorySwimwear => 'Plavky';

  @override
  String get categoryActivewear => 'Sportovní oblečení';

  @override
  String get categoryOther => 'Ostatní';

  @override
  String get conditionClean => 'Čisté';

  @override
  String get conditionDirty => 'Špinavé';

  @override
  String get conditionLaundry => 'V prádle';

  @override
  String get conditionRepair => 'K opravě';

  @override
  String get conditionDonate => 'Na darování';

  @override
  String get seasonSpring => 'Jaro';

  @override
  String get seasonSummer => 'Léto';

  @override
  String get seasonFall => 'Podzim';

  @override
  String get seasonWinter => 'Zima';

  @override
  String get seasonAll => 'Celoroční';

  @override
  String get styleCasual => 'Ležérní';

  @override
  String get styleFormal => 'Formální';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sportovní';

  @override
  String get styleBohemian => 'Boho';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistický';

  @override
  String get styleRomantic => 'Romantický';

  @override
  String get styleEdgy => 'Odvážný';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Umělecký';

  @override
  String get styleClassic => 'Klasický';

  @override
  String get styleElegant => 'Elegantní';

  @override
  String get styleOther => 'Jiné';

  @override
  String get occasionWork => 'Do práce';

  @override
  String get occasionDateNight => 'Rande';

  @override
  String get occasionTravel => 'Na cesty';

  @override
  String get occasionWedding => 'Svatba';

  @override
  String get occasionGym => 'Do fitka';

  @override
  String get occasionWeekend => 'Na víkend';

  @override
  String get occasionParty => 'Párty';

  @override
  String get occasionInterview => 'Pohovor';

  @override
  String get colorBlack => 'Černá';

  @override
  String get colorWhite => 'Bílá';

  @override
  String get colorGrey => 'Šedá';

  @override
  String get colorNavy => 'Tmavě modrá';

  @override
  String get colorBrown => 'Hnědá';

  @override
  String get colorRed => 'Červená';

  @override
  String get colorBlue => 'Modrá';

  @override
  String get colorGreen => 'Zelená';

  @override
  String get colorPink => 'Růžová';

  @override
  String get colorPurple => 'Fialová';

  @override
  String get colorYellow => 'Žlutá';

  @override
  String get colorOrange => 'Oranžová';

  @override
  String get colorBeige => 'Béžová';

  @override
  String get dateToday => 'Dnes';

  @override
  String get dateYesterday => 'Včera';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Před $count dny',
      few: 'Před $count dny',
      one: 'Před 1 dnem',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Před $count týdny',
      few: 'Před $count týdny',
      one: 'Před 1 týdnem',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Před $count měsíci',
      few: 'Před $count měsíci',
      one: 'Před 1 měsícem',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Před $count lety',
      few: 'Před $count lety',
      one: 'Před 1 rokem',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Baví vás FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Rychlé hodnocení pomůže ostatním najít jejich styl.';

  @override
  String get ratingPromptYes => 'Ohodnotit aplikaci';

  @override
  String get ratingPromptNo => 'Teď ne';

  @override
  String get closetNoMatchesTitle => 'Žádné kousky neodpovídají';

  @override
  String get closetNoMatchesBody => 'Zkuste méně filtrů nebo jiné hledání.';

  @override
  String get closetClearFilters => 'Zrušit filtry';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kousků',
      few: '$count kousky',
      one: '1 kousek',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Načítání vašich kousků';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vybráno',
      many: '$count vybráno',
      few: '$count vybrány',
      one: '1 vybráno',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Smazat vybrané';

  @override
  String get closetCancelSelection => 'Zrušit výběr';

  @override
  String get closetCloseSearch => 'Zavřít hledání';

  @override
  String get closetShowGrid => 'Zobrazit mřížku';

  @override
  String get closetShowList => 'Zobrazit seznam';

  @override
  String get closetShowRows => 'Zobrazit řádky';

  @override
  String get closetStatsTitle => 'Statistiky šatníku';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Smazat $count kousků?',
      few: 'Smazat $count kousky?',
      one: 'Smazat 1 kousek?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Outfit, které je využívají, o tyto kousky přijdou.';

  @override
  String get closetSortBy => 'Seřadit podle';

  @override
  String get closetFavourites => 'Oblíbené';

  @override
  String get closetFavourite => 'Oblíbené';

  @override
  String get closetUnfavourite => 'Odebrat z oblíbených';

  @override
  String get closetWoreToday => 'Měl/a jsem dnes';

  @override
  String closetWornTimes(int count) {
    return 'Nošeno $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategorie';

  @override
  String get closetUseCaseLabel => 'Příležitost';

  @override
  String get closetAnyUseCase => 'Všechny';

  @override
  String get closetOtherUseCase => 'Jiná příležitost';

  @override
  String get closetOtherUseCaseHint => 'Například brunch';

  @override
  String get closetUseUseCase => 'Použít';

  @override
  String get closetClearAll => 'Vymazat vše';

  @override
  String get sortNewest => 'Od nejnovějších';

  @override
  String get sortOldest => 'Od nejstarších';

  @override
  String get sortName => 'Název (A–Z)';

  @override
  String get sortMostWorn => 'Nejčastěji nošené';

  @override
  String get useCaseInformal => 'Neformální';

  @override
  String get useCaseDate => 'Rande';

  @override
  String get useCaseDinner => 'Večeře';

  @override
  String get useCaseLunch => 'Oběd';

  @override
  String get actionSelect => 'Vybrat';

  @override
  String get actionEdit => 'Upravit';

  @override
  String get actionFilter => 'Filtrovat';

  @override
  String get actionSort => 'Seřadit';

  @override
  String get actionAll => 'Vše';

  @override
  String get dashboardStartClosetTitle => 'Založte si šatník';

  @override
  String get dashboardStartClosetBody =>
      'Vyfoťte pár kousků. Označíme je za vás.';

  @override
  String get dashboardPieces => 'kousků';

  @override
  String get dashboardOutfits => 'outfitů';

  @override
  String get dashboardDayStreak => 'dní v řadě';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count tento měsíc';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Nejlepší $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oblíbených',
      few: '$count oblíbené',
      one: '1 oblíbený',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uložených outfitů',
      few: '$count uložené outfitu',
      one: '1 uložený outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Nejnošenější: $name, ${count}krát';
  }

  @override
  String get setupSkip => 'Přeskočit nastavení';

  @override
  String get setupWhoTitle => 'Koho budeme oblékat?';

  @override
  String get setupWhoBody =>
      'Nastaví model pro zkoušení a focení. Můžete to změnit ve svém profilu.';

  @override
  String get setupStyleTitle => 'Co nosíte nejčastěji?';

  @override
  String get setupStyleBody =>
      'Vyberte libovolné. Nápady na outfit z toho vycházejí.';

  @override
  String get setupClosetTitle => 'Přidejte své první kousky.';

  @override
  String get setupClosetBody =>
      'Vyfoťte několik kusů oblečení nebo hromadu. Každý kousek se vystřihne a uloží.';

  @override
  String get setupAddClothes => 'Přidat oblečení';

  @override
  String get setupStylesLabel => 'Styly';

  @override
  String get setupOccasionsLabel => 'Příležitosti';

  @override
  String get setupSkipStep => 'Přeskočit';

  @override
  String get setupLater => 'Později';

  @override
  String get setupSaveError => 'Nepodařilo se uložit';

  @override
  String get genderWomen => 'Ženy';

  @override
  String get genderMen => 'Muži';

  @override
  String get genderNonBinary => 'Neinarní';

  @override
  String get genderPreferNotToSay => 'Neuvedeno';

  @override
  String get outfitEmptyTitle => 'Zatím žádné outfity';

  @override
  String get outfitEmptyBody => 'Slaďte kousky ze šatníku a uložte si look.';

  @override
  String get outfitNoMatchesTitle => 'Žádné odpovídající outfity';

  @override
  String get outfitSearchHint => 'Hledat v outfitech';

  @override
  String get outfitLoading => 'Načítání outfitů';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfitů',
      few: '$count outfity',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Styl a sezóna';

  @override
  String get outfitCollections => 'Kolekce';

  @override
  String get outfitDuplicate => 'Duplikovat';

  @override
  String get outfitDeleteTitle => 'Smazat tento outfit?';

  @override
  String get outfitDeleteBody => 'Jejich kousky zůstanou ve vašem šatníku.';

  @override
  String get outfitDrafts => 'Koncepty';

  @override
  String get outfitDraft => 'Koncept';

  @override
  String get filterStyle => 'Styl';

  @override
  String get filterSeason => 'Sezóna';

  @override
  String get itemDetailDeleteTitle => 'Smazat tento kousek?';

  @override
  String get itemDetailDeleteBody =>
      'Outfity, které jej používají, tento kousek ztratí.';

  @override
  String get itemAddFavourite => 'Přidat do oblíbených';

  @override
  String itemSize(String size) {
    return 'Velikost $size';
  }

  @override
  String get itemColours => 'Barvy';

  @override
  String get itemMaterial => 'Materiál';

  @override
  String get itemPattern => 'Vzor';

  @override
  String get itemUseCases => 'Příležitosti';

  @override
  String get itemKeptIn => 'Uloženo v';

  @override
  String get itemPrice => 'Cena';

  @override
  String get itemBought => 'Zakoupeno';

  @override
  String get itemTags => 'Štítky';

  @override
  String get itemAdded => 'Přidáno';

  @override
  String get itemTimesWornLabel => 'nošení';

  @override
  String get itemLastWornLabel => 'naposledy na sobě';

  @override
  String get itemNeverWorn => 'Nikdy';

  @override
  String get authEntryBody =>
      'Všechno oblečení ve vašem šatníku, stylizované pomocí FitCheck AI. Plánujte outfity, zkoušejte je a foťte.';

  @override
  String get authCreateCloset => 'Vytvořit šatník';

  @override
  String get authWelcomeBack => 'Vítejte zpět';

  @override
  String get authSignInBody => 'Přihlaste se a otevřete svůj šatník.';

  @override
  String get authCreateAccount => 'Vytvořit účet';

  @override
  String get authCreateClosetBody =>
      'Trvá to chvíli. První kousky máte zdarma.';

  @override
  String get authName => 'Jméno';

  @override
  String get authConfirmPassword => 'Potvrdit heslo';

  @override
  String get authReferralCode => 'Doporučující kód (nepovinné)';

  @override
  String get authResetTitle => 'Obnovit heslo';

  @override
  String get authResetBody => 'Pošleme vám e-mailem odkaz pro výběr nového.';

  @override
  String get authSendResetLink => 'Odeslat odkaz';

  @override
  String get authBackToSignIn => 'Zpět k přihlášení';

  @override
  String get authEnterEmail => 'Zadejte svůj e-mail';

  @override
  String get authEnterValidEmail => 'Zadejte platný e-mail';

  @override
  String get authEnterPassword => 'Zadejte své heslo';

  @override
  String get authPasswordTooShort => 'Alespoň 6 znaků';

  @override
  String get authShowPassword => 'Zobrazit heslo';

  @override
  String get authHidePassword => 'Skrýt heslo';

  @override
  String get authNewHere => 'Noví zde?';

  @override
  String authConfirmEmail(String email) {
    return 'Před přihlášením potvrďte $email. Zkontrolujte doručenou poštu.';
  }

  @override
  String get authResendEmail => 'Odeslat znovu';

  @override
  String get authResendingEmail => 'Odesílání…';

  @override
  String get authPasswordsDoNotMatch => 'Hesla se neshodují';

  @override
  String get authEnterName => 'Zadejte své jméno';

  @override
  String get authChoosePassword => 'Zvolte heslo';

  @override
  String get authHaveAccount => 'Máte účet?';

  @override
  String get authCodeAccepted => 'Kód přijat';

  @override
  String get authCodeNotFound => 'Kód nenalezen';

  @override
  String authReferralFrom(String name) {
    return 'Od uživatele $name. Oba získáte měsíc zdarma.';
  }

  @override
  String get authReferralInvalid => 'Tento kód se nepodařilo najít.';

  @override
  String authResetSent(String email) {
    return 'Odesláno na $email. Otevřete odkaz v tomto telefonu.';
  }

  @override
  String get introSlide1Title => 'Vyfoťte šatník naráz.';

  @override
  String get introSlide1Body =>
      'Vyfoťte hromadu oblečení. Každý kousek se automaticky vystřihne a uloží.';

  @override
  String get introSlide2Title => 'Oblékejte se rychleji.';

  @override
  String get introSlide2Body =>
      'Outfity z toho, co vlastníte, sladěné s vašimi plány a počasím.';

  @override
  String get introSlide3Title => 'Vyzkoušejte to před oblečením.';

  @override
  String get introSlide3Body =>
      'Zkuste modely na své fotce nebo je nafoťte jako kampaň.';

  @override
  String get settingsTheme => 'Vzhled';

  @override
  String get settingsThemeSystem => 'Systémový';

  @override
  String get settingsThemeLight => 'Světlý';

  @override
  String get settingsThemeDark => 'Tmavý';

  @override
  String get settingsTemperature => 'Teplota';

  @override
  String get settingsEmailUpdates => 'E-mailové novinky';

  @override
  String get settingsEmailUpdatesBody => 'Zprávy a tipy e-mailem';

  @override
  String get settingsOutfitReminders => 'Připomenutí outfitů';

  @override
  String get settingsOutfitRemindersBody =>
      'Upozornění na zaznamenání toho, co jste měli na sobě';

  @override
  String get settingsWeeklySummary => 'Týdenní souhrn';

  @override
  String get settingsWeeklySummaryBody => 'Váš týden v outfittech';

  @override
  String get settingsStyleSection => 'Styl';

  @override
  String get settingsPreferredStyles => 'Oblíbené styly';

  @override
  String get settingsPreferredColours => 'Oblíbené barvy';

  @override
  String get settingsNoneChosen => 'Nic vybráno';

  @override
  String get settingsPlanAiSection => 'Plán a AI';

  @override
  String get settingsPlanBillingBody => 'Plán, využití a upgradování';

  @override
  String get settingsPlanUsageBody => 'Plán a využití';

  @override
  String get settingsInviteFriends => 'Pozvat přátele';

  @override
  String get settingsInviteFriendsBody =>
      'Zdarma měsíc pro každého pozvaného přítele';

  @override
  String get settingsAiProvider => 'Poskytovatel AI';

  @override
  String get settingsAiProviderBody =>
      'Použijte vlastní model pro štítky a obrázky';

  @override
  String get settingsAppVersion => 'Verze aplikace';

  @override
  String get settingsPrivacyTerms => 'Soukromí a podmínky';

  @override
  String get settingsReportProblem => 'Nahlásit problém';

  @override
  String get settingsChangePassword => 'Změnit heslo';

  @override
  String get settingsExportData => 'Exportovat data';

  @override
  String get settingsExportBody =>
      'Připravíme soubor se vším, co jste uložili, a otevřeme stažení.';

  @override
  String get settingsExportAction => 'Exportovat';

  @override
  String get settingsCurrentPassword => 'Aktuální heslo';

  @override
  String get settingsNewPassword => 'Nové heslo';

  @override
  String get settingsConfirmNewPassword => 'Potvrdit nové heslo';

  @override
  String get settingsEnterCurrentPassword => 'Zadejte aktuální heslo';

  @override
  String get settingsEnterNewPassword => 'Zadejte nové heslo';

  @override
  String get settingsPasswordMin8 => 'Použijte alespoň 8 znaků';

  @override
  String get settingsPasswordNeedsUpper => 'Přidejte velké písmeno';

  @override
  String get settingsPasswordNeedsLower => 'Přidejte malé písmeno';

  @override
  String get settingsPasswordNeedsDigit => 'Přidejte číslo';

  @override
  String get settingsPasswordsNoMatch => 'Hesla se neshodují';

  @override
  String get settingsChangeAction => 'Změnit';

  @override
  String get itemAddSnapTitle => 'Vyfoťte kousek';

  @override
  String get itemAddSnapBody =>
      'Na fotce najdeme každý kousek a vytvoříme z něj čistý katalogový snímek.';

  @override
  String get itemAddCamera => 'Vyfotit';

  @override
  String get itemAddGallery => 'Vybrat z galerie';

  @override
  String get itemAddOtherWays => 'Další způsoby přidání';

  @override
  String get itemAddSeveral => 'Přidat více fotek';

  @override
  String get itemAddSeveralBody => 'Až 50 najednou';

  @override
  String get itemAddImportProfile => 'Importovat z profilu';

  @override
  String get itemAddImportProfileBody => 'Instagram nebo Facebook';

  @override
  String get itemAddEnterDetails => 'Zadat podrobnosti ručně';

  @override
  String get itemAddEnterDetailsBody => 'Fotka není potřeba';

  @override
  String get itemManualIntro =>
      'Stačí jen název. Zbytek můžete doplnit hned nebo později.';

  @override
  String get itemManualNameHint => 'Například modré bavlněné tričko';

  @override
  String get itemManualEnterName => 'Zadejte název';

  @override
  String get itemManualNotes => 'Poznámky';

  @override
  String get itemManualBrand => 'Značka';

  @override
  String get itemManualSize => 'Velikost';

  @override
  String get itemManualEnterNumber => 'Zadejte číslo';

  @override
  String get itemManualSavePiece => 'Uložit kousek';

  @override
  String get itemManualSaving => 'Ukládá se';

  @override
  String get itemManualSavedTitle => 'Uloženo';

  @override
  String itemManualSavedBody(String name) {
    return '$name je ve vašem šatníku.';
  }

  @override
  String get itemManualNotSaved => 'Neuloženo';

  @override
  String get itemManualAddUseCase => 'Přidat příležitost';

  @override
  String get itemManualAddUseCaseAction => 'Přidat příležitost';

  @override
  String get itemPhotos => 'Fotky';

  @override
  String get itemAddPhotos => 'Přidat fotky';

  @override
  String get itemNoPhotoYet => 'Zatím bez fotky. Můžete uložit i bez ní.';

  @override
  String get itemRemovePhoto => 'Ostranit fotku';

  @override
  String get itemRemovePiece => 'Odstranit kousek';

  @override
  String get filterConditionLabel => 'Stav';

  @override
  String get photoshootStepPhotos => 'Fotky';

  @override
  String get photoshootStepSetup => 'Nastavení';

  @override
  String get photoshootStepCreating => 'Vytváření';

  @override
  String get photoshootStepResults => 'Výsledky';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Krok $current z $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Jedna fotka selhala. Zkuste ji zopakovat níže.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotek selhalo. Zkuste každou zopakovat níže.';
  }

  @override
  String get photoshootFormat => 'Formát';

  @override
  String get photoshootHowMany => 'Kolik';

  @override
  String get photoshootYourPrompt => 'Vaše zadání';

  @override
  String get photoshootPromptHint => 'Zlatá hodinka na střeše, lněná košile';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vytvořit $count fotek',
      many: 'Vytvořit $count fotek',
      few: 'Vytvořit $count fotky',
      one: 'Vytvořit 1 fotku',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotek',
      many: 'fotek',
      few: 'fotky',
      one: 'fotka',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Dnešní limit se nepodařilo ověřit.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Tarif $plan: dnes zbývá $remaining z $limit';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Free';

  @override
  String get photoshootGallery => 'Galerie';

  @override
  String get photoshootUseCamera => 'Použít fotoaparát';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Odstranit fotku $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Žádné fotky se nevrátily';

  @override
  String get photoshootNoPhotosBody =>
      'Focení skončilo bez snímků. Zkuste to znovu.';

  @override
  String get photoshootNewStyle => 'Nový styl';

  @override
  String get photoshootNewPhotos => 'Nové fotky';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Otevřít fotku $number';
  }

  @override
  String get photoshootReportPhoto => 'Nahlásit fotku';

  @override
  String get photoshootSaveToGallery => 'Uložit do galerie';

  @override
  String get actionUpgrade => 'Přejít na vyšší tarif';

  @override
  String get referralLimitTitle => 'Dnešní fotky jste vyčerpali';

  @override
  String get referralLimitBody =>
      'Vaše bezplatné fotky se vrátí zítra. Doporučte aplikaci příteli a oba získáte měsíc Pro zdarma.';

  @override
  String get referralLimitRefer => 'Doporučit příteli';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Seznamka';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetika';

  @override
  String get photoshootUseCustom => 'Vlastní zadání';

  @override
  String get photoshootDescLinkedin => 'Ostré portréty do práce';

  @override
  String get photoshootDescDating => 'Uvolněné, vřelé a přirozené';

  @override
  String get photoshootDescPortfolio => 'Redakční a vysoce módní vzhled';

  @override
  String get photoshootDescInstagram => 'Lifestyle snímky pro váš feed';

  @override
  String get photoshootDescAesthetic => 'Náladové, umělecké snímky';

  @override
  String get photoshootDescCustom => 'Popište vzhled, který chcete';

  @override
  String get aspectSquare => 'Čtverec';

  @override
  String get aspectPortrait => 'Na výšku';

  @override
  String get aspectLandscape => 'Na šířku';

  @override
  String get aspectTall => 'Vysoký';

  @override
  String get aspectWide => 'Široký';

  @override
  String get tryOnAppBar => 'Virtuální zkoušení';

  @override
  String get tryOnYourPhoto => 'Vaše fotka';

  @override
  String get tryOnGarment => 'Oblečení';

  @override
  String get tryOnUploadingPhoto => 'Nahrávání vaší fotky';

  @override
  String get tryOnAddPhotoPrompt => 'Přidejte svou celou postavu na fotce';

  @override
  String get tryOnBodyPhotoHint => 'Nejlépe funguje fotka celé postavy';

  @override
  String get tryOnAddPhoto => 'Přidat fotku';

  @override
  String get tryOnChangePhoto => 'Změnit fotku';

  @override
  String get tryOnPhotoLoadFailed => 'Vaši fotku se nepodařilo načíst.';

  @override
  String get tryOnChooseGarment => 'Vyberte fotku oblečení';

  @override
  String get tryOnChooseOneGarment => 'Vyberte jednu fotku oblečení';

  @override
  String get tryOnGarmentHint =>
      'Nejlépe funguje fotka na ploše nebo na ramínku';

  @override
  String get tryOnChange => 'Změnit';

  @override
  String get tryOnCamera => 'Fotoaparát';

  @override
  String get tryOnRemove => 'Odstranit';

  @override
  String get tryOnLookTitle => 'Outfit';

  @override
  String get tryOnStyle => 'Styl';

  @override
  String get tryOnBackground => 'Pozadí';

  @override
  String get tryOnPose => 'Pózování';

  @override
  String get tryOnDressingUp => 'Oblékáme vás. Trvá to asi půl minuty.';

  @override
  String get tryOnEmptyResult => 'Zde se zobrazí zkouška';

  @override
  String get tryOnReportImage => 'Nahlásit obrázek';

  @override
  String get tryOnCreating => 'Vytváří se';

  @override
  String get tryOnTryAgain => 'Zkusit znovu';

  @override
  String get tryOnCreate => 'Vytvořit zkoušku';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio bílé';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio šedé';

  @override
  String get tryOnBackgroundUrban => 'Městská ulice';

  @override
  String get tryOnBackgroundNature => 'Příroda';

  @override
  String get tryOnBackgroundMinimal => 'Minimální';

  @override
  String get tryOnPoseFront => 'Čelní postoj';

  @override
  String get tryOnPoseSide => 'Boční postoj';

  @override
  String get tryOnPoseWalking => 'Chůze';

  @override
  String get dashboardGreetingMorning => 'Dobré ráno';

  @override
  String get dashboardGreetingAfternoon => 'Dobré odpoledne';

  @override
  String get dashboardGreetingEvening => 'Dobrý večer';

  @override
  String get dashboardWelcome => 'Vítejte';

  @override
  String get dashboardOpenProfile => 'Otevřít profil';

  @override
  String get dashboardRailToday => 'Dnes';

  @override
  String get dashboardRailRecently => 'Nedávné';

  @override
  String get dashboardActivityEmpty => 'Zde se zobrazí nové kousky a outfity.';

  @override
  String get quickAddPiece => 'Přidat kousek';

  @override
  String get quickAddPieceBody => 'Vyfotit a označit';

  @override
  String get quickBuildOutfit => 'Sestavit outfit';

  @override
  String get quickBuildOutfitBody => 'Kombinovat kousky';

  @override
  String get quickForYou => 'Pro vás';

  @override
  String get quickForYouBody => 'Dnešní výběr';

  @override
  String get quickPlanWeek => 'Naplánovat týden';

  @override
  String get quickPlanWeekBody => 'Outfity podle data';

  @override
  String get referralBannerUrgent => 'Docházejí vám? Pozvěte přítele.';

  @override
  String get referralBannerTitle => 'Dopřejte měsíc, získejte měsíc.';

  @override
  String get referralBannerBody => 'Vy i váš přítel získáte měsíc Pro.';

  @override
  String get referralBannerDismiss => 'Skrýt na týden';

  @override
  String get referralBannerShare => 'Sdílet pozvánku';

  @override
  String get referralBannerCopy => 'Kopírovat odkaz';

  @override
  String get itemEditPieceTitle => 'Upravit kousek';

  @override
  String get itemEditDescriptionLabel => 'Popis';

  @override
  String get itemEditNotSaved => 'Neuloženo';

  @override
  String get itemEditSavedTitle => 'Uloženo';

  @override
  String get itemEditSavedBody => 'Vaše změny jsou uloženy.';

  @override
  String get itemEditSavedStalePhotos => 'Uloženo – fotky mohou být zastaralé';

  @override
  String get itemEditRemovePieceHint =>
      'Smazat tento kousek ze stránky položky.';

  @override
  String get itemEditNoPhotos =>
      'Zatím žádné fotky. Přidejte nějakou z galerie nebo fotoaparátu.';

  @override
  String get itemEditKeepPhoto => 'Ponechat fotku';

  @override
  String get itemEditRemoved => 'Odstraněno';

  @override
  String get itemEditAddUseCaseAction => 'Přidat';

  @override
  String get statsNoStatsTitle => 'Zatím žádné statistiky';

  @override
  String get statsNoStatsBody =>
      'Přidejte pár kousků a zde se zobrazí složení vašeho šatníku.';

  @override
  String get statsByCategory => 'Podle kategorie';

  @override
  String get statsTotalValue => 'celková hodnota';

  @override
  String get statsMostWorn => 'Nejčastěji nošené';

  @override
  String get statsLeastWorn => 'Čeká na řadu';

  @override
  String get statsUnnamedPiece => 'Pojmenovaný kousek';

  @override
  String get jobsTitle => 'Skeny';

  @override
  String get jobsEmptyTitle => 'Zatím žádné skeny';

  @override
  String get jobsEmptyBody =>
      'Vyfoťte kousek a pošlete ho na pozadí – bude pokračovat zde.';

  @override
  String get jobsNotCancelled => 'Nezrušeno';

  @override
  String get jobsResume => 'Pokračovat';

  @override
  String get jobsReview => 'Zkontrolovat';

  @override
  String get jobsStop => 'Zastavit';

  @override
  String get jobsDismiss => 'Zavřít';

  @override
  String get reportTitle => 'Nahlásit obsah';

  @override
  String reportIntro(String contentType) {
    return 'Řekněte nám, co je s tímto $contentType v nepořádku. Náš tým každé nahlášení prověří.';
  }

  @override
  String get reportReasonInappropriate => 'Nevhodný nebo urážlivý obsah';

  @override
  String get reportReasonNudity => 'Nahota nebo sexuální obsah';

  @override
  String get reportReasonHarassment => 'Obtěžování nebo šikana';

  @override
  String get reportReasonImpersonation => 'Vydávání se za někoho jiného';

  @override
  String get reportReasonOther => 'Jiné';

  @override
  String get reportDetailsLabel => 'Další podrobnosti (nepovinné)';

  @override
  String get reportSubmit => 'Odeslat nahlášení';

  @override
  String get reportSubmittedTitle => 'Nahlášení odesláno';

  @override
  String get reportSubmittedBody => 'Děkujeme. Náš tým obsah prověří.';

  @override
  String get reportFailedTitle => 'Nahlášení se nepodařilo odeslat';

  @override
  String get reportFailedBody => 'Zkuste to prosím znovu.';

  @override
  String get reportContentTryOnImage => 'obrázek zkoušky oblečení AI';

  @override
  String get reportContentSharedOutfit => 'sdílený outfit';

  @override
  String get reportContentPhotoshootImage => 'obrázek focení AI';

  @override
  String get sharedOutfitTitle => 'Sdílený outfit';

  @override
  String get sharedOutfitHideTooltip => 'Skrýt tento outfit';

  @override
  String get sharedOutfitReportTooltip => 'Nahlásit tento outfit';

  @override
  String get sharedOutfitHideTitle => 'Skrýt tento outfit?';

  @override
  String get sharedOutfitHideBody =>
      'Na tomto zařízení zůstane skrytý. Můžete ho také nahlásit, aby jej náš tým mohl zkontrolovat a odstranit.';

  @override
  String get sharedOutfitHideAction => 'Skrýt';

  @override
  String get sharedOutfitHiddenInfo =>
      'Tento outfit se na tomto zařízení již nezobrazí.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit skryt';

  @override
  String get sharedOutfitMissingTitle => 'Tento outfit už zde není';

  @override
  String get sharedOutfitMissingBody =>
      'Možná byl odstraněn nebo je odkaz chybný.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Tento outfit jste skryli';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Pokud je nevhodný, nahlaste jej v sekci Soukromí a podmínky nebo napište na $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Líbí se vám tento vzhled?';

  @override
  String get sharedOutfitCtaBody =>
      'Vytvářejte podobné outfity ze svého šatníku.';

  @override
  String get sharedOutfitCtaButton => 'Získat FitCheck AI';

  @override
  String get errorTitle => 'Chyba';

  @override
  String get errorUnknown => 'Došlo k neočekávané chybě';

  @override
  String get errorNoConnection =>
      'Žádné připojení k internetu. Zkontrolujte síť.';

  @override
  String get errorTimeout => 'Vypršel časový limit požadavku. Zkuste to znovu.';

  @override
  String get errorServerError =>
      'Na našich stranách se něco pokazilo. Zkuste to znovu.';

  @override
  String get errorBadGateway =>
      'Náš server je dočasně nedostupný. Zkuste to znovu.';

  @override
  String get errorServiceUnavailable =>
      'Služba je dočasně nedostupná. Zkuste to za chvíli.';

  @override
  String get errorInternalError => 'Něco se pokazilo. Zkuste to znovu.';

  @override
  String get errorUnauthorized => 'Pro pokračování se přihlaste.';

  @override
  String get errorForbidden => 'K tomu nemáte přístup.';

  @override
  String get errorSessionExpired =>
      'Platnost relace vypršela. Přihlaste se znovu.';

  @override
  String get errorInvalidCredentials =>
      'Zadaný e-mail nebo heslo není správné.';

  @override
  String get errorTokenRefreshFailed =>
      'Relaci se nepodařilo obnovit. Přihlaste se znovu.';

  @override
  String get errorRequestCancelled => 'Požadavek zrušen.';

  @override
  String get errorInvalidFormat => 'Tento formát souboru není podporován.';

  @override
  String get errorFileTooLarge => 'Soubor je příliš velký.';

  @override
  String get errorUploadFailed => 'Nahrávání selhalo. Zkuste to znovu.';

  @override
  String get errorCacheCorrupted =>
      'Uložená data byla poškozena a byla resetována.';

  @override
  String get errorCacheNotFound => 'Zatím nic nebylo uloženo.';

  @override
  String get errorUserNotFound => 'Tento účet se nepodařilo najít.';

  @override
  String get errorItemNotFound => 'Tato položka již neexistuje.';

  @override
  String get errorOutfitNotFound => 'Tento outfit již neexistuje.';

  @override
  String get rewardsTitle => 'Odměny';

  @override
  String get rewardsNoAchievementsTitle => 'Zatím žádné úspěchy';

  @override
  String get rewardsNoAchievementsBody =>
      'Přidejte kousky a plánujte outfit k získání prvního.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Zatím nikdo v žebříčku';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plánujte outfit k získání bodů a zobrazení zde.';

  @override
  String get legalViewPrivacyPolicy => 'Zobrazit zásady ochrany osobních údajů';

  @override
  String get aiConsentAgree => 'Souhlasím a pokračovat';

  @override
  String get aiConsentNotNow => 'Teď ne';

  @override
  String get imageViewerCloseTooltip => 'Zavřít zobrazení obrázku';

  @override
  String get updateReadyTitle => 'Aktualizace je připravena';

  @override
  String get updateReadyBody =>
      'Restartujte FitCheck AI pro použití nejnovějších vylepšení.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI potřebuje přístup k fotoaparátu pro focení vašich outfitů a kousků v šatníku.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI potřebuje přístup ke knihovně fotek pro výběr snímků vašich outfitů a kousků.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI potřebuje ukládat vygenerované fotky outfitů do vaší knihovny fotek.';

  @override
  String get wardrobeSomePhotosSkipped => 'Některé fotky byly přeskočeny';

  @override
  String get wardrobePhotosNotAdded => 'Fotky nebyly přidány';

  @override
  String get wardrobePhotoNotAdded => 'Fotka nebyla přidána';

  @override
  String get wardrobeNotStartedTitle => 'Nezahájeno';

  @override
  String get wardrobeNoRoomTitle => 'Žádné místo';

  @override
  String get wardrobeAddPhotosSemantic => 'Přidat fotky';

  @override
  String get batchAddTileLabel => 'Přidat';

  @override
  String get batchProfileLinkLabel => 'Odkaz na profil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importovat z profilu';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Přidat více fotek';

  @override
  String get wardrobeClearAction => 'Vymazat';

  @override
  String get wardrobeRefreshTooltip => 'Aktualizovat';

  @override
  String get batchNoPhotosYetTitle => 'Zatím žádné fotky';

  @override
  String get batchChoosePhotosAction => 'Vybrat fotky';

  @override
  String get batchWeFindEachPieceBody =>
      'Najdeme každý kousek a vytvoříme jeho studiovou fotku.';

  @override
  String get batchPreparingPhotosSemantic => 'Připravují se fotky';

  @override
  String get batchPhotosProcessedSemantic => 'Fotky zpracovány';

  @override
  String get batchPasteProfileLinkTitle => 'Vložit odkaz na profil';

  @override
  String get batchPasteProfileLinkBody =>
      'Veřejný profil na Instagramu nebo Facebooku. Prozkoumáme jeho fotky a vy si vyberete, co půjde do vašeho šatníku.';

  @override
  String get batchClearLinkTooltip => 'Vymazat odkaz';

  @override
  String get batchStartingButton => 'Spouští se';

  @override
  String get batchStartImportAction => 'Spustit import';

  @override
  String get batchReviewEveryPhotoTitle => 'Každou fotku zkontrolujete';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nic se nepřidá, dokud to neschválíte.';

  @override
  String get batchPrivateProfilesTitle => 'Soukromé profily';

  @override
  String get batchPrivateProfilesBody =>
      'Propojte svůj účet. Instagram vyžaduje také uživatelské jméno a heslo.';

  @override
  String get batchUseAnotherLinkAction => 'Použít jiný odkaz';

  @override
  String get batchSignInNeededTitle => 'Vyžadováno přihlášení';

  @override
  String get batchEnterYourCodeTitle => 'Zadejte svůj kód';

  @override
  String get batchUseUsernamePasswordAction =>
      'Použít uživatelské jméno a heslo';

  @override
  String get batchAlreadyConnectedAction => 'V prohlížeči jsem se již připojil';

  @override
  String get batchEnterCodeAction => 'Zadat kód';

  @override
  String get batchTryAnotherWayAction => 'Zkusit jinak';

  @override
  String get batchLiveStatus => 'Živě';

  @override
  String get batchReconnectingStatus => 'Připojování';

  @override
  String get batchSignInToInstagramTitle => 'Přihlásit se k Instagramu';

  @override
  String get batchUsernameLabel => 'Uživatelské jméno';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kód, pokud používáte dvoufázové ověření';

  @override
  String get batchAuthenticatorCodeBody =>
      'Použijte 6místný kód z autentizační aplikace. Kódy se rychle mění.';

  @override
  String get batchVerifyAction => 'Ověřit';

  @override
  String get batchFindingPhotosTitle => 'Hledání fotek';

  @override
  String get batchImportPausedTitle => 'Import pozastaven';

  @override
  String get batchProcessingPhotosTitle => 'Zpracování fotek';

  @override
  String get batchWaitingNextPhoto => 'Čekání na další fotku';

  @override
  String get batchCancelImportAction => 'Zrušit import';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Na této fotce nebyly nalezeny žádné kousky.';

  @override
  String get batchEditPieceColoursLabel => 'Barvy oddělené čárkou';

  @override
  String get batchAddToClosetAction => 'Přidat do šatníku';

  @override
  String get batchSkipPhotoAction => 'Přeskočit fotku';

  @override
  String get batchImportCompleteTitle => 'Import dokončen';

  @override
  String get batchImportFailedTitle => 'Import se nezdařil';

  @override
  String get batchImportCancelledTitle => 'Import zrušen';

  @override
  String get batchImportErrorBody => 'Při importu došlo k chybě.';

  @override
  String get batchNothingMoreImportedBody =>
      'Z tohoto profilu se už nic dalšího nestáhne.';

  @override
  String get batchViewClosetAction => 'Zobrazit šatník';

  @override
  String get batchStartOverAction => 'Začít znovu';

  @override
  String get wardrobeAddPieceTitle => 'Přidat kousek';

  @override
  String get wardrobeAddDetailsTitle => 'Přidat detaily';

  @override
  String get wardrobeScanningTitle => 'Skenování';

  @override
  String get batchReviewPiecesTitle => 'Zkontrolovat kousky';

  @override
  String get wardrobeGalleryAction => 'Galerie';

  @override
  String get wardrobeCameraAction => 'Fotoaparát';

  @override
  String get wardrobeNewBadge => 'Nové';

  @override
  String get wardrobeRemovePhotoTooltip => 'Odstranit fotku';

  @override
  String get batchRunInBackgroundTooltip => 'Spustit na pozadí';

  @override
  String get batchStepOneOfTwo => 'Krok 1 z 2';

  @override
  String get batchStepTwoOfTwo => 'Krok 2 z 2';

  @override
  String get batchUploadingPhotosTitle => 'Nahrávání fotek';

  @override
  String get batchFindingPiecesTitle => 'Hledání kousků';

  @override
  String get batchMakingStudioPhotosTitle => 'Tvorba fotek';

  @override
  String get batchStoppedLabel => 'Zastaveno';

  @override
  String get batchFindingPiecesStoppedTitle => 'Hledání kousků zastaveno';

  @override
  String get batchCancelledLabel => 'Zrušeno';

  @override
  String get batchAllDoneTitle => 'Hotovo';

  @override
  String get batchOpeningPiecesBody => 'Otevírání vašich kousků';

  @override
  String get batchNothingSavedBody => 'Nic nebylo uloženo.';

  @override
  String get batchFindingPiecesFailedBody => 'Hledání kousků selhalo.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Hledání kousků bylo předčasně zastaveno.';

  @override
  String get batchStopFindingPiecesTitle => 'Zastavit hledání kousků?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skenování se zastaví a nic se neuloží. Nalezené kousky zůstanou v aktivitě, dokud je neodstraníte.';

  @override
  String get batchKeepGoingAction => 'Pokračovat';

  @override
  String get batchTryAgainAction => 'Zkusit znovu';

  @override
  String get batchBackToPhotosAction => 'Zpět na fotky';

  @override
  String get batchSkipAllAction => 'Přeskočit vše';

  @override
  String get batchIncludeAllAction => 'Zahrnout vše';

  @override
  String get batchNoPiecesFoundTitle => 'Žádné kousky nenalezeny';

  @override
  String get batchNoPiecesFoundBody =>
      'Na těchto fotkách jsme nenašli žádné oblečení.';

  @override
  String get batchChooseOtherPhotosAction => 'Vybrat jiné fotky';

  @override
  String get batchUseCaseHelper => 'Přidáno ke každému uloženému kousku.';

  @override
  String get batchDiscardPiecesTitle => 'Zahodit tyto kousky?';

  @override
  String get batchDiscardPiecesBody => 'Z této série nebylo nic uloženo.';

  @override
  String get batchKeepAction => 'Ponechat';

  @override
  String get batchDiscardAction => 'Zahodit';

  @override
  String get batchRemovePieceTitle => 'Odebrat tento kousek?';

  @override
  String get batchRemovePieceBody => 'Není uložen ve vašem šatníku.';

  @override
  String get batchRemoveAction => 'Odebrat';

  @override
  String get batchChoosePiecesToSave => 'Vybrat kousky k uložení';

  @override
  String get batchDiscardAllAction => 'Zahodit vše';

  @override
  String get batchNothingSavedRetryBody =>
      'Nic nebylo uloženo. Zkuste to znovu.';

  @override
  String get batchNotSavedTitle => 'Neuloženo';

  @override
  String get batchSavingLabel => 'Ukládá se';

  @override
  String get batchSendToBackgroundAction => 'Přejít na pozadí';

  @override
  String get batchStillWorkingMessage =>
      'Stále pracujeme. Jakmile budou kousky připravené, dáme vám vědět.';

  @override
  String get batchRunningInBackgroundTitle => 'Běží na pozadí';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studio fotky byly předčasně zastaveny. Tyto kousky můžete stále uložit.';

  @override
  String get batchTapPieceToSkip => 'Klepnutím kousek přeskočíte.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studio fotky jsou na cestě. Můžete odejít – dáme vám vědět.';

  @override
  String get batchLeaveAction => 'Odejít';

  @override
  String get batchPeopleInPhotosTitle => 'Lidé na fotkách';

  @override
  String get batchIncludeAction => 'Zahrnout';

  @override
  String get batchSkipAction => 'Přeskočit';

  @override
  String get batchYourPhotoIsUsedLabel => 'Použije se vaše fotka';

  @override
  String get batchMakingStudioPhotoLabel => 'Vytváří se studio fotka';

  @override
  String get batchNoStudioPhotoBody =>
      'Žádná studio fotka. Použije se vaše fotka.';

  @override
  String get batchEnterDetailsYourselfAction => 'Zadat podrobnosti ručně';

  @override
  String get batchChooseAnotherPhotoAction => 'Vybrat jinou fotku';

  @override
  String get batchConnectionLostTitle => 'Ztraceno připojení';

  @override
  String get batchConnectionLostBody =>
      'Zkontrolujte připojení a zkuste to znovu.';

  @override
  String get batchDailyLimitTitle => 'Denní limit vyčerpán';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Přejděte na Pro pro více skenů nebo zadejte podrobnosti ručně.';

  @override
  String get batchDailyLimitBodyFree =>
      'Skeny se obnoví zítra. Podrobnosti můžete zadat ručně hned teď.';

  @override
  String get batchSeePlansAction => 'Zobrazit plány';

  @override
  String get batchAiBusyTitle => 'Naše AI je zaneprázdněná';

  @override
  String get batchAiBusyBody =>
      'Chyba je na naší straně. Zkuste to za pár minut znovu.';

  @override
  String get batchNoPiecesBody =>
      'Zkuste ostřejší fotku nebo zadejte podrobnosti ručně.';

  @override
  String get batchScanningUnavailableTitle => 'Skenování je nedostupné';

  @override
  String get batchScanningUnavailableBody => 'Zatím zadejte podrobnosti ručně.';

  @override
  String get batchScanDidNotFinishTitle => 'Skenování se nedokončilo';

  @override
  String get batchTryAgainBody => 'Zkusit znovu.';

  @override
  String get billingTitle => 'Předplatné';

  @override
  String get billingUpgradeHeading => 'Vylepšit plán';

  @override
  String get billingUpgradeOnPlusBody => 'Stejné funkce, vyšší limity.';

  @override
  String get billingUpgradeBody =>
      'Plus a Pro mají stejné funkce. Zvolte si limity, jaké potřebujete.';

  @override
  String get billingWebUnavailableBody =>
      'Online upgrady ještě nejsou dostupné. Promo nebo doporučující kód vám ale Plus nebo Pro odemkne. Pozvěte přátele níže a získejte měsíce zdarma.';

  @override
  String get billingPlansStale =>
      'Nepodařilo se načíst nejnovější plány. Ceny mohou být zastaralé.';

  @override
  String get billingMonthly => 'Měsíčně';

  @override
  String get billingYearly => 'Ročně';

  @override
  String get billingCurrentPlan => 'Aktuální plán';

  @override
  String get billingActive => 'Aktivní';

  @override
  String get billingThisMonth => 'Tento měsíc';

  @override
  String get billingItemExtractions => 'Extrakce kousků';

  @override
  String get billingOutfitVisualizations => 'Vizualizace outfitů';

  @override
  String get billingNearLimitUpgrade =>
      'Blížíte se k měsíčnímu limitu. Přejděte na vyšší plán.';

  @override
  String get billingNearLimitResets =>
      'Blížíte se k měsíčnímu limitu. Obnoví se začátkem příštího měsíce.';

  @override
  String get billingStoreUnavailable =>
      'Nákupy v obchodu nejsou dostupné. Zkuste to brzy znovu.';

  @override
  String get billingManageHeading => 'Správa předplatného';

  @override
  String get billingCancelPlan => 'Zrušit předplatné';

  @override
  String get billingCancelKeepsAccess =>
      'Přístup vám zůstane do konce tohoto fakturačního období.';

  @override
  String get billingCancelConfirmTitle => 'Zrušit předplatné?';

  @override
  String get billingKeepPlan => 'Ponechat tarif';

  @override
  String get billingCancelPlanAction => 'Zrušit tarif';

  @override
  String get billingBilledMonthly => 'Účtováno měsíčně';

  @override
  String get billingBilledYearly => 'Účtováno ročně';

  @override
  String get billingVirtualTryOn => 'Virtuální zkoušení';

  @override
  String get billingPrioritySupport => 'Prioritní podpora';

  @override
  String get billingDisclosureProRenewing =>
      'Tarif Pro je automaticky obnovované předplatné';

  @override
  String get billingDisclosureBothRenewing =>
      'Tarify Plus a Pro jsou automaticky obnovované předplatné';

  @override
  String get billingDisclosureAppleBilling =>
      'Platba bude stržena z vašeho Apple ID při potvrzení nákupu.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Platba bude stržena z vašeho účtu Google Play při potvrzení nákupu.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Předplatné se automaticky obnovuje na stejné období za stejnou cenu, pokud nevypnete automatické obnovení alespoň 24 hodin před koncem aktuálního období.';

  @override
  String get billingDisclosureAppleManage =>
      'Spravujte nebo zrušte kdykoli v Nastavení › vaše Apple ID › Předplatné.';

  @override
  String get billingDisclosureGoogleManage =>
      'Spravujte nebo zrušte kdykoli v Google Play › Platby a předplatné.';

  @override
  String get billingReferFriend => 'Doporučit příteli';

  @override
  String get billingHowItWorks => 'Jak to funguje';

  @override
  String get billingHowShareTitle => 'Sdílejte odkaz';

  @override
  String get billingHowShareBody => 'Pošlete ho příteli.';

  @override
  String get billingHowSignUpTitle => 'Přítel se zaregistruje';

  @override
  String get billingHowSignUpBody => 'Přítel se připojí přes váš odkaz.';

  @override
  String get billingHowBothTitle => 'Oba získáte Pro';

  @override
  String get billingHowBothBody => 'Každý z vás získá měsíc Pro zdarma.';

  @override
  String get billingYourReferrals => 'Vaše doporučení';

  @override
  String get billingInvited => 'Pozváno';

  @override
  String get billingJoined => 'Připojeno';

  @override
  String get billingMonthsEarned => 'Získané měsíce';

  @override
  String get billingInviteFriend => 'Pozvat přátele';

  @override
  String get billingInviteBody => 'Vy i váš přítel získáte měsíc Pro zdarma.';

  @override
  String get billingYourCode => 'Váš kód';

  @override
  String get billingCopyLink => 'Kopírovat odkaz';

  @override
  String get billingShareInvite => 'Sdílet pozvánku';

  @override
  String get giftUnavailable =>
      'Dárkové pozvánky nejsou v této verzi k dispozici.';

  @override
  String get giftPageTitle => 'Darovat FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'V tuto chvíli nejsou k dispozici žádné bezplatné dárkové pozvánky.';

  @override
  String get giftFormTitle => 'Odeslat bezplatnou pozvánku';

  @override
  String get giftFormBody =>
      'Obdarovaný si dárek vyzvedne pomocí tohoto ověřeného e-mailu. E-mail za vás neodesíláme.';

  @override
  String get giftFieldFrom => 'Od';

  @override
  String get giftFieldRecipientName => 'Jméno příjemce';

  @override
  String get giftFieldRecipientEmail => 'E-mail příjemce';

  @override
  String get giftFieldOccasion => 'Příležitost (volitelně)';

  @override
  String get giftNoOccasion => 'Bez příležitosti';

  @override
  String get giftOccasionBirthday => 'Narozeniny';

  @override
  String get giftOccasionAnniversary => 'Výročí';

  @override
  String get giftOccasionOther => 'Jiné';

  @override
  String get giftFieldCardGreeting => 'Text přání';

  @override
  String get giftFieldCardGreetingHelper =>
      'Zobrazí se na kartě přesně tak, jak je napsáno.';

  @override
  String get giftFieldPrivateNote => 'Soukromá poznámka (volitelně)';

  @override
  String get giftCreateAction => 'Vytvořit dárek zdarma';

  @override
  String get giftClaimedTitle => 'Dárek uplatněn';

  @override
  String get giftClaimedActive => 'Váš dárek FitCheck Pro je aktivní.';

  @override
  String get giftClaimedQueued =>
      'Váš dárek FitCheck Pro začne platit po skončení aktuálního přístupu.';

  @override
  String get giftLinkCopied => 'Odkaz na dárek byl zkopírován do schránky.';

  @override
  String get giftErrorName => 'Zadejte jméno.';

  @override
  String get giftErrorEmail => 'Zadejte platnou e-mailovou adresu.';

  @override
  String get giftErrorGreeting => 'Zadejte text přání.';

  @override
  String get giftErrorGreetingLength => 'Použijte maximálně 80 znaků.';

  @override
  String get giftClaimAction => 'Uplatnit dárek';

  @override
  String get giftCardPreview => 'Náhled karty';

  @override
  String get giftGiftForYou => 'Dárek pro vás';

  @override
  String get giftGiftWaiting => 'Čeká na vás dárek';

  @override
  String get giftOpenBody =>
      'Otevřete své dárky a uplatněte je pomocí ověřeného e-mailu.';

  @override
  String get giftOpenGifts => 'Otevřít dárky';

  @override
  String get giftSendInvitation => 'Odeslat pozvánku';

  @override
  String get settingsAiProviderSection => 'Poskytovatel';

  @override
  String get settingsAiCustom => 'Vlastní';

  @override
  String get settingsAiUrlHelper =>
      'Použijte veřejnou URL adresu, kterou server dosáhne. Localhost z našich serverů nefunguje.';

  @override
  String get settingsAiConnectionSection => 'Připojení';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API klíč';

  @override
  String get settingsAiApiKeySaved =>
      'Uloženo. Ponechte prázdné pro zachování.';

  @override
  String get settingsAiChatModel => 'Chatovací model';

  @override
  String get settingsAiVisionModel => 'Vizuální model (volitelné)';

  @override
  String get settingsAiImageModel => 'Model obrázků (volitelné)';

  @override
  String get settingsAiImageModelNote =>
      'Generování obrázků vyžaduje chatovací doplnění kompatibilní s OpenAI a response_modalities.';

  @override
  String get settingsAiTestConnection => 'Otestovat připojení';

  @override
  String get calendarTitle => 'Kalendář';

  @override
  String get calendarGoToToday => 'Dnes';

  @override
  String get calendarConnectTooltip => 'Připojit kalendář';

  @override
  String get calendarAddEvent => 'Přidat událost';

  @override
  String get calendarEmptyTitle => 'Nic v plánu';

  @override
  String get calendarEmptyBody =>
      'Přidejte událost a naplánujte si, co si vzít na sebe.';

  @override
  String get calendarPreviousMonth => 'Předchozí měsíc';

  @override
  String get calendarNextMonth => 'Následující měsíc';

  @override
  String get calendarAllDay => 'Celý den';

  @override
  String get calendarOutfitLinked => 'Propojený outfit';

  @override
  String get calendarEventOptions => 'Možnosti události';

  @override
  String get calendarDeleteTitle => 'Smazat událost?';

  @override
  String get calendarChangeOutfit => 'Změnit outfit';

  @override
  String get calendarLinkOutfit => 'Propojit outfit';

  @override
  String get calendarRemoveOutfit => 'Odebrat outfit';

  @override
  String get calendarNewEvent => 'Nová událost';

  @override
  String get calendarEditEvent => 'Upravit událost';

  @override
  String get calendarTitleLabel => 'Název';

  @override
  String get calendarTitleRequired => 'Přidejte název';

  @override
  String get calendarEndBeforeStart => 'Konec po začátku';

  @override
  String get calendarStarts => 'Začátek';

  @override
  String get calendarEnds => 'Konec';

  @override
  String get calendarPlaceOptional => 'Místo (nepovinné)';

  @override
  String get calendarNotesOptional => 'Poznámky (nepovinné)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Sestavte outfit a propojte ho s touto událostí.';

  @override
  String get calendarBuildOutfit => 'Sestavit outfit';

  @override
  String get calendarConnectionsTitle => 'Kalendáře';

  @override
  String get calendarConnectionsBody =>
      'Události, které zde přidáte, zůstanou ve FitCheck.';

  @override
  String get calendarDisconnect => 'Odpojit';

  @override
  String get calendarNotAvailable => 'Zatím k dispozici';

  @override
  String get profileSectionExplore => 'Prozkoumat';

  @override
  String get profileNavTryOn => 'Zkoušení';

  @override
  String get profileNavRewards => 'Odměny';

  @override
  String get profileSupport => 'Podpora';

  @override
  String get profileHelp => 'Nápověda';

  @override
  String get profileAbout => 'O aplikaci';

  @override
  String get profileAboutBody =>
      'Tvůj šatník, outfity a plány na jednom místě.';

  @override
  String get profileSignOutTitle => 'Odhlásit se?';

  @override
  String get profileSignOutBody => 'Kdykoliv se můžeš znovu přihlásit.';

  @override
  String get profileEditTitle => 'Upravit profil';

  @override
  String get profileYourProfile => 'Tvůj profil';

  @override
  String get profileBodyProfiles => 'Tělesné profily';

  @override
  String get profileBodyEmptyTitle => 'Zatím žádné profily';

  @override
  String get profileBodyEmptyBody =>
      'Přidejte svou výšku a postavu pro lepší střih.';

  @override
  String get profileBodyAdd => 'Přidat profil';

  @override
  String get profileBodyDefaultNote =>
      'Váš výchozí profil se používá pro střih a zkoušení.';

  @override
  String get profileBodyDefaultBadge => 'Výchozí';

  @override
  String get profileBodyMakeDefault => 'Nastavit jako výchozí';

  @override
  String get profileBodyDeleteBody => 'Tuto akci nelze vrátit zpět.';

  @override
  String get profileBodyRequired => 'Povinné';

  @override
  String get profileBodyCheckNumber => 'Zkontrolujte toto číslo';

  @override
  String get profileBodyNew => 'Nový tělesný profil';

  @override
  String get profileBodyNameHint => 'Například Já';

  @override
  String get profileBodyHeight => 'Výška';

  @override
  String get profileBodyWeight => 'Váha';

  @override
  String get profileBodyBuild => 'Postava';

  @override
  String get profileBodySkinTone => 'Tón pleti';

  @override
  String get profileBirthDateNeededBody =>
      'Přidejte datum narození k času narození.';

  @override
  String get profileBirthDateNeededTitle => 'Chybí datum narození';

  @override
  String get profilePartlySavedBody =>
      'Uložili jsme vaše jméno a fotku. Údaje o narození se neuložily, zkuste to později.';

  @override
  String get profilePartlySavedTitle => 'Částečně uloženo';

  @override
  String get profileSavedBody => 'Váš profil je uložen.';

  @override
  String get profileChangePhoto => 'Změnit fotku profilu';

  @override
  String get profilePhotoLabel => 'Profilová fotka';

  @override
  String get profilePhotoHint => 'Klepnutím vyberte novou';

  @override
  String get profileBirthDateLabel => 'Datum narození (volitelně)';

  @override
  String get profileBirthTimeLabel => 'Čas narození (volitelně)';

  @override
  String get profileBirthTimeHelper => 'Upřesní védská doporučení';

  @override
  String get profileBirthPlaceLabel => 'Místo narození (volitelně)';

  @override
  String get profileBirthPlaceHint => 'Například Praha, Česká republika';

  @override
  String get profileHelpContactTitle => 'Zeptejte se nás';

  @override
  String get profileHelpContactBody =>
      'Napište nám zprávu a my odpovíme e-mailem, obvykle do jednoho dne.';

  @override
  String get profileHelpContactAction => 'Kontaktovat podporu';

  @override
  String get profileHelpFaqTitle => 'Časté dotazy';

  @override
  String get profileFaqAddPiecesTitle => 'Jak přidám kousky do šatníku?';

  @override
  String get profileFaqAddPiecesBody =>
      'Klepněte na Přidat položku na kartě Šatník. Vyfoťte ji nebo vyberte z galerie; my ji najdeme a označíme za vás.';

  @override
  String get profileFaqMatchingTitle => 'Jak funguje párování outfitů?';

  @override
  String get profileFaqMatchingBody =>
      'Otevřete Pro vás a vyberte kousky, které vlastníte. Navrhneme vám, co se k nim hodí, a sestavíme celé ouftity z vašeho šatníku.';

  @override
  String get profileFaqTryOnTitle => 'Mohu pro zkoušení použít vlastní fotky?';

  @override
  String get profileFaqTryOnBody =>
      'Ano. Přidejte svou celofigurální fotku a poté vyberte kousky, abyste je viděli na sobě.';

  @override
  String get profileFaqRewardsTitle => 'Jak získáte odměny?';

  @override
  String get profileFaqRewardsBody =>
      'Plánujte a zaznamenávejte outfity. Série a úspěchy přibývají s tím, jak je nosíte.';

  @override
  String get profileFaqPrivacyTitle => 'Je můj šatník soukromý?';

  @override
  String get profileFaqPrivacyBody =>
      'Ano. Váš šatník a outfity jsou soukromé, dokud nesdílíte odkaz na konkrétní outfit.';

  @override
  String get profileHelpMoreTitle => 'Další nápověda';

  @override
  String get profileHelpGuides => 'Návody';

  @override
  String get profileHelpGuidesBody => 'Jak funguje jednotlivé funkce';

  @override
  String get feedbackCategoryBug => 'Něco se rozbilo';

  @override
  String get feedbackCategoryIdea => 'Nápad';

  @override
  String get feedbackCategoryGeneral => 'Obecné';

  @override
  String get feedbackCategoryHelp => 'Potřebuji pomoc';

  @override
  String get feedbackHintBug =>
      'Co se stalo a co jste očekávali? Kroky nám pomohou chybu opravit.';

  @override
  String get feedbackHintIdea => 'Co byste si přáli a proč?';

  @override
  String get feedbackHintGeneral => 'Napište nám svůj názor nebo zeptejte se.';

  @override
  String get feedbackAttachmentLimitBody => 'Můžete přidat až 5 obrázků.';

  @override
  String get feedbackAttachmentLimitTitle => 'Dosažen limit';

  @override
  String get feedbackImageTooLargeBody => 'Vyberte obrázek menší než 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Obrázek je příliš velký';

  @override
  String get feedbackTitle => 'Odeslat zpětnou vazbu';

  @override
  String get feedbackAboutLabel => 'Čeho se to týká?';

  @override
  String get feedbackSubjectLabel => 'Předmět';

  @override
  String get feedbackSubjectRequired => 'Doplňte předmět';

  @override
  String get feedbackSubjectTooShort => 'Předmět musí mít alespoň 3 znaky';

  @override
  String get feedbackDetailsLabel => 'Podrobnosti';

  @override
  String get feedbackDetailsRequired => 'Doplňte podrobnosti';

  @override
  String get feedbackDetailsTooShort => 'Popis musí mít alespoň 10 znaků';

  @override
  String get feedbackAddScreenshot => 'Přidat snímek obrazovky';

  @override
  String get feedbackAttachmentHint => 'Až 5, max. 5 MB každý';

  @override
  String get feedbackSend => 'Odeslat';

  @override
  String get feedbackEmptyTitle => 'Zatím nic odesláno';

  @override
  String get feedbackEmptyBody =>
      'Zde se zobrazí to, co odešlete, včetně stavu.';

  @override
  String get feedbackHistoryTitle => 'Co jste odeslali';

  @override
  String get feedbackStatusOpen => 'Otevřeno';

  @override
  String get feedbackStatusInProgress => 'Řeší se';

  @override
  String get feedbackStatusResolved => 'Vyřešeno';

  @override
  String get feedbackStatusClosed => 'Uzavřeno';

  @override
  String get legalIntro =>
      'Jak chráníme vaše data a podmínky používání aplikace FitCheck AI.';

  @override
  String get legalPolicies => 'Zásady';

  @override
  String get legalPrivacySubtitle => 'Co sbíráme a proč';

  @override
  String get legalTermsTitle => 'Podmínky použití';

  @override
  String get legalTermsSubtitle => 'Pravidla pro používání aplikace';

  @override
  String get legalLicences => 'Open-source licence';

  @override
  String get legalSupportSubtitle =>
      'Nápověda, kontakt a žádosti o ochranu soukromí';

  @override
  String get legalReportAbuse => 'Nahlásit problém nebo zneužití';

  @override
  String get permissionCameraTitle => 'Přístup k fotoaparátu';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI používá fotoaparát k pořizování snímků vašeho oblečení a outfitů pro AI zkoušení a organizaci šatníku.';

  @override
  String get permissionPhotoTitle => 'Přístup k fotkám';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI potřebuje přístup k vašim fotkám, abyste mohli vybírat obrázky oblečení a outfitů pro funkce AI a váš šatník.';

  @override
  String get permissionNotNow => 'Teď ne';

  @override
  String get permissionOpenSettings => 'Otevřít nastavení';

  @override
  String authSignedInAs(String name) {
    return 'Přihlášen(a) jako $name';
  }

  @override
  String get authSignedIn => 'Přihlášeno';

  @override
  String get authWelcomeBackTitle => 'Vítejte zpět';

  @override
  String get authSignInFailed => 'Přihlášení se nezdařilo';

  @override
  String get authWelcomeTitle => 'Vítejte';

  @override
  String get authSignUpFailed => 'Registrace se nezdařila';

  @override
  String get authGoogleSignInFailed => 'Přihlášení přes Google se nezdařilo';

  @override
  String get authAppleSignInFailed => 'Přihlášení přes Apple se nezdařilo';

  @override
  String get authConfirmEmailTitle => 'Potvrďte svůj e-mail';

  @override
  String get authConfirmEmailBody =>
      'Zkontrolujte svou doručenou poštu a potvrďte e-mail, poté se přihlaste.';

  @override
  String get authClosetReady => 'Váš šatník je připraven.';

  @override
  String get authSignedOutTitle => 'Odhlášeno';

  @override
  String get authSignedOutBody => 'Jste odhlášeni.';

  @override
  String get authSignOutFailed => 'Odhlášení se nezdařilo';

  @override
  String get authEmailSentTitle => 'E-mail byl odeslán';

  @override
  String get authResetLinkSent => 'Zkontrolujte e-mail pro odkaz k obnovení.';

  @override
  String get authPasswordUpdatedTitle => 'Heslo bylo aktualizováno';

  @override
  String get authPasswordUpdated => 'Vaše heslo je aktualizováno.';

  @override
  String get authPasswordNotUpdated => 'Heslo nebylo aktualizováno';

  @override
  String get authCouldNotSendEmail => 'E-mail se nepodařilo odeslat';

  @override
  String get authEmailNotSent => 'E-mail nebyl odeslán';

  @override
  String get authResendSentBody => 'Odeslali jsme nový potvrzovací e-mail.';

  @override
  String get outfitPreviewWithAi => 'Náhled s AI';

  @override
  String get outfitNewPreview => 'Vytvořit nový náhled';

  @override
  String get outfitBuilderClosetHeading => 'Tvoje šatník';

  @override
  String get outfitBuilderSearchHint => 'Hledat kousky';

  @override
  String get outfitClearSearch => 'Zrušit hledání';

  @override
  String get outfitBuilderAddPiecesTitle => 'Nejprve přidejte kousky';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfity se tvoří z kousků ve vašem šatníku.';

  @override
  String get outfitBuilderNoMatches => 'Žádné kousky neodpovídají.';

  @override
  String get outfitNameLabel => 'Název outfitu';

  @override
  String get outfitNameHint => 'Např. Víkendový lněný';

  @override
  String get outfitPreviewSemantic => 'AI náhled outfitu';

  @override
  String get outfitChoosePieces => 'Vyberte kousky';

  @override
  String get outfitTapPiecesHint => 'Klepněte na kousky níže pro přidání.';

  @override
  String get outfitShareTooltip => 'Sdílet';

  @override
  String get outfitSaveFavourite => 'Uložit do oblíbených';

  @override
  String get outfitPiecesHeading => 'Kousky';

  @override
  String get outfitWearHistoryEmpty => 'Nošený jednou a datum se zde zobrazí.';

  @override
  String get outfitWearHistoryTitle => 'Historie nošení';

  @override
  String get outfitWearHistoryError => 'Data se nepodařila načíst.';

  @override
  String get outfitWornOn => 'Nošeno';

  @override
  String get outfitEditTitle => 'Upravit outfit';

  @override
  String get outfitSavedPhotosFailed => 'Detaily uloženy, fotky ne';

  @override
  String get outfitNoPhotosBody =>
      'Zatím žádné fotky. Místo toho se zobrazí kousky.';

  @override
  String get outfitOccasionLabel => 'Okází';

  @override
  String get outfitOccasionNone => 'Žádná';

  @override
  String get outfitTagsHint => 'Oddělte čárkami';

  @override
  String get outfitDraftBody => 'Skryto z hlavního seznamu';

  @override
  String get outfitPublic => 'Veřejný';

  @override
  String get outfitPublicBody => 'Kdo má odkaz, ho uvidí';

  @override
  String get outfitDeleteFromDetail => 'Smazat tento outfit z detailu.';

  @override
  String get outfitNewCollection => 'Nová kolekce';

  @override
  String get outfitNoCollectionsTitle => 'Zatím žádné kolekce';

  @override
  String get outfitNoCollectionsBody =>
      'Skládejte outfity podle cesty, ročního období nebo nálady.';

  @override
  String get outfitCreateCollection => 'Vytvořit kolekci';

  @override
  String get outfitAddOutfits => 'Přidat outfity';

  @override
  String get outfitRename => 'Přejmenovat';

  @override
  String get outfitCollectionDeleteBody => 'Outfity v ní zůstávají zachovány.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfity nebyly načteny';

  @override
  String get outfitRenameCollection => 'Přejmenovat kolekci';

  @override
  String get outfitDescriptionOptional => 'Popis (nepovinné)';

  @override
  String get outfitAllInCollection => 'Každý outfit je už v této kolekci.';

  @override
  String get photoshootSubtitleUpload =>
      'Studijní portréty z vašich fotografií';

  @override
  String get photoshootSubtitleConfigure => 'Zvolte styl, formát a počet';

  @override
  String get photoshootSubtitleGenerating => 'Trvá minutu dvě';

  @override
  String get photoshootAddPhotosSemantic => 'Přidat fotky z galerie';

  @override
  String get photoshootUploadTitle => 'Přidejte 1 až 4 fotky sebe';

  @override
  String get photoshootUploadBody => 'Dotknutím se vyberte z galerie';

  @override
  String get photoshootAddToContinue => 'Přidejte fotku pro pokračování';

  @override
  String get photoshootAddAnotherPhoto => 'Přidat další fotku';

  @override
  String get photoshootTipsTitle => 'Pro nejlepší výsledek';

  @override
  String get photoshootTipsBody =>
      'Používejte jasné, dobře osvětlené fotky vaší tváře z různých úhlů. Vyhněte se slunečním brýlím a čepicím.';

  @override
  String get photoshootStarting => 'Spouštím';

  @override
  String get photoshootCancelling => 'Zrušuji';

  @override
  String get photoshootFailed => 'Neúspěch';

  @override
  String get recommendTabMatches => 'Shody';

  @override
  String get recommendTabComplete => 'Doplnit';

  @override
  String get recommendTabWeather => 'Počasí';

  @override
  String get recommendTabColours => 'Barvy';

  @override
  String get recommendTabShop => 'Obchod';

  @override
  String get recommendNoMatchesTitle => 'Zatím žádné shody';

  @override
  String get recommendNoMatchesBody =>
      'Vyberte kus a najdeme k němu správný styl.';

  @override
  String get recommendPickPiece => 'Vybrat kus';

  @override
  String get recommendNothingMatchesTitle => 'Zatím nic neodpovídá';

  @override
  String get recommendNothingMatchesBody =>
      'Zkuste jiné kousky nebo doplněte svůj šatník.';

  @override
  String get recommendChangePieces => 'Změnit kousky';

  @override
  String get recommendDefaultReason => 'Vybrané kousky k sobě ladí.';

  @override
  String get recommendCompleteTitle => 'Doplň outfit';

  @override
  String get recommendCompleteBody => 'Vyberte kus a my doplníme zbytek.';

  @override
  String get recommendWorking => 'Zpracovávám';

  @override
  String get recommendGenerate => 'Vygenerovat';

  @override
  String get recommendChooseStyleBody =>
      'Vyberte styl a klikněte na Vygenerovat.';

  @override
  String get recommendNoLooksTitle => 'Pro tyto kusy neexistuje outfit';

  @override
  String get recommendNoLooksBody => 'Zkuste jiný styl nebo jiné kousky.';

  @override
  String get recommendDefaultLook => 'Outfit pro vaše kousky';

  @override
  String get recommendNoPiecesBody =>
      'Pro tento outfit nebyly nalezeny žádné kusy.';

  @override
  String get recommendCityLabel => 'Město';

  @override
  String get recommendCheck => 'Zkontrolovat';

  @override
  String get recommendWeatherTitle => 'Jaké je počasí?';

  @override
  String get recommendWeatherBody => 'Zadejte své město pro návrhy na dnešek.';

  @override
  String get recommendWearToday => 'Nobít dnes';

  @override
  String get recommendWeatherNoPieces =>
      'Pro toto počasí dosud nemáte žádné kousky ve šatníku.';

  @override
  String get recommendBudgetLabel => 'Rozpočet do';

  @override
  String get recommendLooking => 'Vyhledávám';

  @override
  String get recommendFindWhatToBuy => 'Najít, co koupit';

  @override
  String get recommendFillGapsTitle => 'Doplnit šatník';

  @override
  String get recommendFillGapsBody =>
      'Nastavte rozpočet a navrhneme, co ve šatníku chybí.';

  @override
  String get recommendNoGapsTitle => 'Chyby nenalezeny';

  @override
  String get recommendNoGapsBody =>
      'Zkuste vyšší rozpočet nebo jinou kategorii.';

  @override
  String get recommendMoodEveryday => 'Každý den';

  @override
  String get recommendMoodBigMeeting => 'Velká schůzka';

  @override
  String get recommendDayLabel => 'Den';

  @override
  String get recommendReadingStars => 'Čtem hvězdy';

  @override
  String get recommendGetMyColours => 'Moje barvy';

  @override
  String get recommendLuckyColoursTitle => 'Vaše štěstivé barvy';

  @override
  String get recommendLuckyColoursBody =>
      'Vyberte den a my vám navrhneme barvy i kousky.';

  @override
  String get recommendLuckyColoursSection => 'Štěstivé barvy';

  @override
  String get recommendAvoidColoursSection => 'Barvy, které používejte opatrně';

  @override
  String get recommendBirthDateTitle => 'Přidejte datum narození';

  @override
  String get recommendBirthDateBody =>
      'K přečtení barev potřebujeme vaše datum narození.';

  @override
  String get recommendEditProfile => 'Upravit profil';

  @override
  String get recommendNothingThisDay => 'Na tento den nic.';

  @override
  String get recommendUnnamedColour => 'Nepojmenovaná barva';

  @override
  String get recommendFromCloset => 'Z vaší skříňky';

  @override
  String get recommendNoPiecesInColours =>
      'Zatím žádné kousky v těchto barvách.';

  @override
  String get recommendOutfitIdeas => 'Nápad outfity';

  @override
  String get recommendNoOutfitsInColours =>
      'Zatím žádný kompletní outfit v těchto barvách.';

  @override
  String get recommendDefaultOutfitIdea => 'Nápad outfitu';

  @override
  String get recommendPickUpToThree => 'Vyberte až tři kousky';

  @override
  String get recommendEmptyClosetBody =>
      'Nejprve přidejte pár kousků a pak se vraťte k ladění.';

  @override
  String get dashboardDressForDay => 'Oblečte se pro předchozí den.';

  @override
  String get dashboardOutfitOfDay => 'Oblíbený outfit dne';

  @override
  String get dashboardFreshLook => 'Čerstvý look';

  @override
  String get subscriptionManageInStoreTitle => 'Spravovat ve obchodu';

  @override
  String get subscriptionManageInStoreBody =>
      'Tento plán se účtuje přes obchod. Spravujte ho v nastavení účtu.';

  @override
  String get subscriptionCancelledTitle => 'Předplatné zrušeno';

  @override
  String get subscriptionCancelledBody =>
      'Váš plán zůstává aktivní do konce tohoto účtovacího období.';

  @override
  String get subscriptionCancelFailedTitle => 'Nepodařilo se zrušit';

  @override
  String get subscriptionCouldNotOpenTitle => 'Nepodařilo se otevřít';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Nepodařilo se otevřít správu fakturace.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Nepodařilo se otevřít odkaz.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Nepodařilo se načíst odkaz';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Nepodařilo se načíst odkaz ke slevě. Zkuste to znovu.';

  @override
  String get subscriptionReferralCopiedTitle => 'Zkopírováno';

  @override
  String get subscriptionReferralCopiedBody => 'Odkaz ke slevě zkopírován.';

  @override
  String get subscriptionReferralShareSubject => 'Vyzkoušejte FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Připojte se k FitCheck AI a oba získáte měsíc Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Odkaz zkopírován';

  @override
  String get subscriptionShareUnavailableBody =>
      'Sdílení není dostupné, odkaz jsme proto zkopírovali.';

  @override
  String get subscriptionShareFailedTitle => 'Sdílení se nepodařilo';

  @override
  String get subscriptionShareFailedBody =>
      'Místo toho zkopírujte odkaz ze stránky slevy.';

  @override
  String get subscriptionStoreReadyTitle => 'Obchot připraven';

  @override
  String get subscriptionStoreReadyBody =>
      'Ceny v obchodě jsou dostupné. Teď lze upgradovat.';

  @override
  String get purchaseFailedTitle => 'Nákup selhal';

  @override
  String get purchaseUnavailableTitle => 'Nákup nedostupný';

  @override
  String get purchaseIapUnavailableBody =>
      'Nákupy v aplikaci nejsou na tomto zařízení dostupné.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Tento plán zatím není k dispozici.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Tento plán zatím není v obchodě. Zkuste to později.';

  @override
  String get purchaseStartFailedBody =>
      'Nákup se nepodařilo spustit. Zkuste to znovu.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Překlad checkoutu nevrátil platební odkaz.';

  @override
  String get purchasePendingTitle => 'Nákup čeká';

  @override
  String get purchasePendingBody =>
      'Váš nákup čeká na schválení. Přístup získáte po schválení.';

  @override
  String get purchaseFailedBody => 'Nákup selhal. Zkuste to znovu.';

  @override
  String get purchaseRestoredTitle => 'Obnoveno';

  @override
  String get purchaseRestoredBody => 'Všechny nákupy byly obnoveny.';

  @override
  String get purchaseActiveTitle => 'Předplatné aktivní';

  @override
  String get purchaseActiveBody => 'Vaše předplatné je aktivní. Vítejte.';

  @override
  String get purchaseSignInRequiredTitle => 'Vyžadováno přihlášení';

  @override
  String get purchaseSignInRequiredBody => 'Přihlaste se pro dokončení nákupu.';

  @override
  String get purchaseErrorTitle => 'Chyba nákupu';

  @override
  String get purchaseInvalidTransactionBody =>
      'Nákup neobsahoval ověřitelné ID transakce.';

  @override
  String get purchaseVerificationPendingTitle => 'Ověření čeká';

  @override
  String get purchaseVerificationPendingBody =>
      'Nyní jsme nedokázali ověřit váš nákup v obchodě. Dokončí se automaticky a nebudete dvakrát platit.';

  @override
  String get purchaseNotAppliedTitle => 'Nákup se neprojevil';

  @override
  String get purchaseNotAppliedBody =>
      'Váš nákup se nedal aplikovat na váš účet. Kontaktujte podporu a nekupujte to znovu.';

  @override
  String get purchaseRestoreFailedTitle => 'Obnovení se nezdařilo';

  @override
  String get purchaseRestoreFailedBody =>
      'Nepodařilo se obnovit nákupy. Zkuste to znovu.';

  @override
  String get purchaseRecoveredActiveBody => 'Vaše předplatné je aktivní.';

  @override
  String get purchaseCompleteTitle => 'Nákup dokončen';

  @override
  String get giftCreateFailedTitle => 'Dar se nepodařilo vytvořit';

  @override
  String get giftClaimFailedTitle => 'Dar se nepodařilo převzít';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dary pro vás',
      one: 'Dar pro vás',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 měsíc',
      '12': '1 rok',
      'other': '$months měsíce',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'zbývá $remaining',
      one: 'zbývá 1',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender vám poslal $duration FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Dar FitCheck Pro pro $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Od $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Pro $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Od $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'váš příjemce';

  @override
  String get giftPreviewPlaceholderSender => 'vy';

  @override
  String get settingsSavedTitle => 'Uloženo';

  @override
  String get settingsNotSavedTitle => 'Neuloženo';

  @override
  String get settingsAiChooseProviderBody => 'Vyberte poskytovatele.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Vlastní poskytovatel vyžaduje URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Zadejte klíč API.';

  @override
  String get settingsAiSavedBody => 'Vaše nastavení AI je uloženo.';

  @override
  String get settingsAiMissingDetailsTitle => 'Chybí údaje';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Zadejte URL API a chatovací model pro test.';

  @override
  String get settingsAiKeyNeededTitle => 'Vyžaduje se klíč API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Zadejte svůj API klíč pro testování. Uložený klíč zůstává soukromý.';

  @override
  String get settingsAiKeyToTestBody => 'Zadejte svůj API klíč pro testování.';

  @override
  String get settingsAiConnectedTitle => 'Připojeno';

  @override
  String get settingsAiConnectedBody => 'Pojitování funguje.';

  @override
  String get settingsAiTestFailedTitle => 'Test selhal';

  @override
  String get settingsPreferencesSavedBody => 'Vaše předvolby byly uloženy.';

  @override
  String get settingsPasswordNotChangedTitle => 'Heslo nezměněno';

  @override
  String get settingsOAuthPasswordBody =>
      'Tento účet se přihlašuje přes Google nebo Apple. Nejdříve nastavte heslo pomocí „Zapomněné heslo“.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Současné heslo je nesprávné.';

  @override
  String get settingsExportReadyTitle => 'Export připraven';

  @override
  String get settingsExportReadyBody =>
      'Váše export dat je připraven ke stažení.';

  @override
  String get settingsLinkCopiedTitle => 'Odkaz zkopírován';

  @override
  String get settingsExportClipboardBody =>
      'Nepodařilo se otevřít prohlížeč, proto jsme zkopírovali odkaz ke stažení. Vložte ho do prohlížeče brzy: platnost expiruje.';

  @override
  String get settingsExportFailedTitle => 'Export selhal';

  @override
  String get settingsAccountNotDeletedTitle => 'Účet nebyl smazán';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Můžete přidat nejvýše $max fotek.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limit fotek';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Přidejte alespoň jednu fotku.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Žádné fotky';

  @override
  String get photoshootDescribeLookBody => 'Popište vzhled, který chcete.';

  @override
  String get photoshootPromptNeededTitle => 'Potřebný dotaz';

  @override
  String get photoshootConsentFeatureLabel => 'AI fotografování';

  @override
  String get photoshootStatusPreparing => 'Připravuji vaše fotky';

  @override
  String get photoshootStatusGenerating => 'Generuji';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Dávka $current z $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'Dokončeno $done z $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generování selhalo.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return 'Připraveno $ready, selhalo $failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Části dokončeno';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotek je připraveno.',
      many: '$count fotek je připraveno.',
      few: '$count fotky jsou připraveny.',
      one: '1 fotka je připravena.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Spojení bylo ztraceno. Zkuste to znovu.';

  @override
  String get photoshootCouldNotCancelTitle => 'Zrušení se nepovedlo';

  @override
  String get photoshootRetryFailedTitle => 'Opětovný pokus selhal';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Foto $number je připraveno.';
  }

  @override
  String get photoshootReplacedTitle => 'Nahrazeno';

  @override
  String get photoshootSavedToGalleryBody => 'Uloženo do vaší galerie.';

  @override
  String get photoshootSavedTitle => 'Uloženo';

  @override
  String get photoshootNotSavedTitle => 'Neuloženo';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Všechny $count fotky jsou ve vaší galerii.',
      one: '1 foto je ve vaší galerii.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'Uloženo $saved z $total.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Některé fotky se neuložily';

  @override
  String get tryonConsentFeatureLabel => 'Virtuální trial';

  @override
  String get tryonAvatarUpdatedBody => 'Vaše foto bylo aktualizováno.';

  @override
  String get tryonSavedTitle => 'Uloženo';

  @override
  String get tryonUploadFailedTitle => 'Nahrání se nezdařilo';

  @override
  String get tryonChooseGarmentFirstBody => 'Nejprve vyberte foto oděvu.';

  @override
  String get tryonNoGarmentTitle => 'Žádný oděv';

  @override
  String get tryonWaitForUploadBody =>
      'Počkejte, až se vaše foto dokončí nahrávání.';

  @override
  String get tryonStillUploadingTitle => 'Stále se nahrává';

  @override
  String get tryonAddYourPhotoFirstBody => 'Nejprve přidejte své foto.';

  @override
  String get tryonReadyBody => 'Váš virtuální trial je připraven.';

  @override
  String get tryonFailedTitle => 'Virtuální trial selhalo';

  @override
  String get tryonSavedToGalleryBody => 'Uloženo do vaší galerie.';

  @override
  String get tryonNotSavedTitle => 'Neuloženo';

  @override
  String get calendarEventAddedBody => 'Událost přidána';

  @override
  String get calendarEventPlannedTitle => 'Naplánováno';

  @override
  String get calendarEventSavedBody => 'Událost uložena';

  @override
  String get calendarSavedTitle => 'Uloženo';

  @override
  String get calendarEventNotSavedTitle => 'Událost neuložena';

  @override
  String get calendarEventRemovedBody => 'Událost odebrána';

  @override
  String get calendarEventDeletedTitle => 'Smazáno';

  @override
  String get calendarEventNotDeletedTitle => 'Událost nesmazána';

  @override
  String get calendarOutfitNotLinkedTitle => 'Oblečení nesynchronizováno';

  @override
  String get calendarLinkedTitle => 'Propojeno';

  @override
  String get calendarOutfitNotRemovedTitle => 'Oblečení neodstraněno';

  @override
  String get calendarOutfitRemovedBody => 'Oblečení odstraněno';

  @override
  String get calendarDisconnectedBody => 'Kalendář odpojen';

  @override
  String get calendarDisconnectedTitle => 'Odpojeno';

  @override
  String get calendarNotDisconnectedTitle => 'Kalendář neodpojen';

  @override
  String get calendarTodayLabel => 'dnes';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# událostí',
      few: '# události',
      one: '1 událost',
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
    return '$title, $time, propojeno oblečení';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '„$title“ bude odstraněna.';
  }

  @override
  String get calendarThisAppLabel => 'Tato aplikace';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synchronizace s $provider zatím není k dispozici. Zde můžete nadále přidávat události.';
  }

  @override
  String get calendarWeekdaySunShort => 'Ne';

  @override
  String get calendarWeekdayMonShort => 'Po';

  @override
  String get calendarWeekdayTueShort => 'Út';

  @override
  String get calendarWeekdayWedShort => 'St';

  @override
  String get calendarWeekdayThuShort => 'Čt';

  @override
  String get calendarWeekdayFriShort => 'Pá';

  @override
  String get calendarWeekdaySatShort => 'So';

  @override
  String get calendarWeekdayMonday => 'Pondělí';

  @override
  String get calendarWeekdayTuesday => 'Úterý';

  @override
  String get calendarWeekdayWednesday => 'Středa';

  @override
  String get calendarWeekdayThursday => 'Čtvrtek';

  @override
  String get calendarWeekdayFriday => 'Pátek';

  @override
  String get calendarWeekdaySaturday => 'Sobota';

  @override
  String get calendarWeekdaySunday => 'Neděle';

  @override
  String get outfitSavedToFavouritesBody => 'Přidáno do oblíbených';

  @override
  String get outfitRemovedFromFavouritesBody => 'Odebráno z oblíbených';

  @override
  String get outfitNotSavedTitle => 'Neuloženo';

  @override
  String get outfitLoggedAsWornBody => 'Zaznamenáno jako nositelné dnes.';

  @override
  String get outfitNicePickTitle => 'Skvělý výběr';

  @override
  String get outfitRemovedBody => 'Oblečení odebráno.';

  @override
  String get outfitDeletedTitle => 'Smazáno';

  @override
  String get outfitNotDeletedTitle => 'Nesmazáno';

  @override
  String get outfitDuplicatedBody => 'Kopie je ve vašich outfitech.';

  @override
  String get outfitDuplicatedTitle => 'Duplikováno';

  @override
  String get outfitNotDuplicatedTitle => 'Neduplikováno';

  @override
  String get outfitNotSharedTitle => 'Nedíleno';

  @override
  String outfitCollectionReadyBody(String name) {
    return 'Kolekce „$name“ je připravena.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Kolekce nebyla vytvořena';

  @override
  String get outfitCollectionUpdatedBody => 'Kolekce aktualizována.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Kolekce nebyla aktualizována';

  @override
  String get outfitCollectionDeletedBody => 'Kolekce smazána.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Kolekce nebyla smazána';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přidáno $count outfitů.',
      many: 'Přidány $count outify.',
      few: 'Přidány $count outify.',
      one: 'Přidán 1 outfit.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfity nepřidány';

  @override
  String get outfitPreviewNotCreatedTitle => 'Náhled nebyl vytvořen';

  @override
  String get outfitGiveNameBody => 'Dejte outfitu název.';

  @override
  String get outfitNameMissingTitle => 'Název';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Vyberte alespoň jeden kus.';

  @override
  String outfitCreatedBody(String name) {
    return '$name je ve vašich outfitech.';
  }

  @override
  String get outfitSavedTitle => 'Uloženo';

  @override
  String get wardrobeAddedToFavouritesBody => 'Přidáno do oblíbených';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Odebráno z oblíbených';

  @override
  String get wardrobeNotSavedTitle => 'Neuloženo';

  @override
  String get wardrobeLoggedAsWornBody => 'Zaznamenáno jako nošené dnes.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Odebráno z vašeho šatníku.';

  @override
  String get wardrobeDeletedTitle => 'Smazáno';

  @override
  String get wardrobeNotDeletedTitle => 'Nesmazáno';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kousky odebrány ze šatníku.',
      one: '1 kousek odebrán ze šatníku.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI extrakce šatníku';

  @override
  String get itemAddScanJobLabel => 'Skenovat';

  @override
  String get itemAddFoundEarlierBody => 'Nalezeno v předchozím skenu';

  @override
  String get itemAddLookingAtPhoto => 'Prohlížení fotografie';

  @override
  String get itemAddExtractionFailedBody => 'Extrakce se nezdařila';

  @override
  String get itemAddJobFailedBody => 'Úkol se nezdařil';

  @override
  String get itemAddConnectionLostBody =>
      'Konejce byl přerušen. Zkuste to znovu.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Konejce byl přerušen při zpracování.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Kousek $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Kousek';

  @override
  String get itemAddNotCancelledTitle => 'Zrušeno';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kousky jsou ve vašem šatníku.',
      one: '1 kousek je ve vašem šatníku.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'Uloženo $saved z $total kusů. Klikněte pro zkusit zbytek znovu.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Některé kousky neuloženy';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'Vyberte alespoň jednu fotografii.';

  @override
  String get batchPhotoUnreadableBody => 'Tuto fotografii nelze přečíst.';

  @override
  String get batchNoPhotosReadableBody =>
      'Žádné z těchto fotografií nelze přečíst. Zkuste jiné.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Spojení bylo přerušeno při zpracování. Zkuste to znovu.';

  @override
  String get batchNotCancelledTitle => 'Nizrušeno';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Odkazy příspěvků nejsou podporovány. Zadejte odkaz na profil.';

  @override
  String get batchLinkSpacesBody => 'Odkazy nemohou obsahovat mezerníky.';

  @override
  String get batchEnterProfileLinkBody =>
      'Zadejte odkaz na profil Instagram nebo Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Zadejte odkaz na profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Stránka pro přihlášení se neotevřela. Zkuste to znovu.';

  @override
  String get batchSignInBrowserBody =>
      'Přihlaste se v prohlížeči a poté se vraťte do aplikace FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Propojte účet';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Zadejte kód z aplikace autentifikačního nástroje.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram vyžaduje kontrolu bezpečnosti. Nejprve se přihlaste v prohlížeči.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Zadejte uživatelské jméno a heslo znovu.';

  @override
  String get batchSignInFailedBody =>
      'Přihlášení se nezdařilo. Zkontrolujte uživatelské jméno a heslo.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Přihlaste se pro pokračování importu.';

  @override
  String get batchAccountNotConnectedBody => 'Účet nebyl propojen.';

  @override
  String get batchAccountConnectedTitle => 'Účet propojen';

  @override
  String get batchNotConnectedTitle => 'Nepropojeno';

  @override
  String get batchImportConnectionLostBody =>
      'Připojení k importu se přerušilo. Obnovte stránku pro kontrolu.';

  @override
  String batchPickUpToBody(int max) {
    return 'Vyberte až $max fotografií. My najdeme kousky.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count z $total fotografií';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Příprava fotografie $done z $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Najít kousky na $count fotografiích',
      one: 'Najít kousky na 1 fotografii',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Váš účet $platform používá dvoufázové přihlašování. Zadejte 6místný kód z aplikace autentifikačního nástroje.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Tento profil $platform je soukromý nebo vyžaduje přihlášení pro zobrazení fotografií.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Propojit přes $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografií nalezeno',
      one: '1 fotografie nalezena',
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
    return '$processed z $total zpracováno · $added přidáno · $waiting čeká · $skipped přeskočeno';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Skenování fotografie $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Fotografie $number je následující';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Fotografie $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kusů nalezeno',
      one: '1 kus nalezen',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografií bylo přidáno do šatníku.',
      one: '1 fotografie byla přidána do šatníku.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count dalších studiových fotografií se připravuje. Co je hotové, můžete uložit, nebo odejít – dáme vám vědět.',
      one:
          '1 další studiová fotografie se připravuje. Co je hotové, můžete uložit, nebo odejít – dáme vám vědět.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Zatím neuloženo: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces kusů',
      one: '1 kus',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotografií',
      one: '1 fotografie',
    );
    return '$_temp0 z $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen vybráno. Klepnutím na kousek ho přeskočíte.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ukládám $count kusů',
      one: 'Ukládám 1 kus',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uložit $count kusů',
      one: 'Uložit 1 kousek',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Váš profil těla je uložen.';

  @override
  String get bodyProfileSavedTitle => 'Uloženo';

  @override
  String get bodyProfileNotSavedTitle => 'Neuloženo';

  @override
  String get bodyProfileSetDefaultBody => 'Nastavit jako výchozí profil.';

  @override
  String get bodyProfileDeletedBody => 'Profil těla byl smazán.';

  @override
  String get bodyProfileDeletedTitle => 'Smazáno';

  @override
  String get bodyProfileNotDeletedTitle => 'Nesmázáno';

  @override
  String get feedbackNotSentTitle => 'Neposileno';

  @override
  String get feedbackSentBody =>
      'Díky. Každou zprávu čteme a odpovíme, pokud budeme potřebovat víc.';

  @override
  String get feedbackSentTitle => 'Zpětná vazba odeslána';

  @override
  String get recommendUnnamedPiece => 'Pojmenovaný kousek';

  @override
  String get recommendEnterCityBody =>
      'Zadejte své město a dostanete tipy dle počasí.';

  @override
  String get recommendWhichCityTitle => 'Které město?';

  @override
  String get aiConsentSheetTitle => 'Sdílení fotografií s AI službou';

  @override
  String get aiConsentSheetBody =>
      'Pro vytvoření vašich pokusných fotí a portrétů FitCheck AI odesílá vaše poskytnuté fotografie (včetně obrázků obličeje a těla) důvěryhodnému třetímu poskytovateli AI (např. OpenAI nebo Google Gemini) ke zpracování. Generují vaše obrázky a podle našich podmínek je nepoužívají k trénování modelů. Fotografie se přenášejí bezpečně a nikdy se nesdílejí pro reklamu.';

  @override
  String get aiConsentSheetPermission =>
      'Pokračováním dáváte výslovné svolení ke sdílení svých fotografií s těmito poskytovateli AI pro generování obrázků.';

  @override
  String get skeletonsLoadMoreFailed => 'Nepodařilo se načíst další.';

  @override
  String get jobsPiecesReadyTitle => 'Vaše kousky jsou připraveny';

  @override
  String get jobsScanStoppedTitle => 'Naskenováním bylo ukončeno';

  @override
  String get jobsNothingSavedBody => 'Nic nebylo uloženo. Zkuste to znovu.';

  @override
  String get jobsPhotoUploadFailedBody => 'Nahrání fotografie se nezdařilo.';

  @override
  String get authGoogleSignInStartFailed =>
      'Nedaří se spustit přihlášení Googlem. Zkuste to znovu.';

  @override
  String get referralAppliedTitle => 'Doporučení aplikováno!';

  @override
  String get billingStoreUnavailableBody =>
      'Nákupy ve skladě nejsou na tomto zařízení k dispozici.';

  @override
  String get billingPurchaseProcessingBody =>
      'Tato platba se stále zpracovává. Otevřete aplikaci za minutu a podívejte se na svůj plán.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Nahrání avatara nevrátilo URL obrázku.';

  @override
  String get rewardsDayStreakLabel => 'denní série';

  @override
  String rewardsBestStreak(int days) {
    return 'Nejlepší $days dní';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Vyžaduje se přístup: $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Přístup k $permission je aktuálně zamítnut. Otevřete Nastavení a povolte ho, pak se vraťte a zkuste to znovu.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Krok $step ze 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Krok $step z $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Odebrat obrázek $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Odebrat obrázek $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points bodů';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Napište na $email. Hlášení zkoumáme do 24 hodin.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Odebrat $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Smazat „$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Přidat do „$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '„$name\" bylo odebráno. Jeho díly zůstávají ve šatní skříní.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Zobrazit všech $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Zbývá dnes $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Snímek $index se nepodařilo zpracovat';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected z $max snímků';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'postava $shape · tón $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Smazat $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Možnosti pro $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Nejvíce nošeno: $name, $count×';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: nastaveno';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% shoda';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'Vybráno $picked z $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Odebrat $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'priorita $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Tento plán je účtován přes $store. Změny a zrušení provedete v nastavení účtu $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Spravovat v $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: použito $current z $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Zbývá asi ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return 'Připraveno $done z $total studiových snímků';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return 'Připraveno $ready z $total studiových snímků. Dotkněte se dílu a přeskočte ho.';
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
  String get profileFieldNotSet => 'Ne';
}
