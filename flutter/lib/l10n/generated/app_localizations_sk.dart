// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Domov';

  @override
  String get tabPhotoshoot => 'Fotenie';

  @override
  String get tabCloset => 'Šatník';

  @override
  String get tabOutfits => 'Outfity';

  @override
  String get tabMore => 'Viac';

  @override
  String get actionAddItem => 'Pridať kúsok';

  @override
  String get actionCreateOutfit => 'Vytvoriť outfit';

  @override
  String get actionCancel => 'Zrušiť';

  @override
  String get actionDelete => 'Vymazať';

  @override
  String get actionSave => 'Uložiť';

  @override
  String get actionRetry => 'Skúsiť znova';

  @override
  String get actionDone => 'Hotovo';

  @override
  String get actionNext => 'Ďalej';

  @override
  String get actionBack => 'Späť';

  @override
  String get actionClose => 'Zavrieť';

  @override
  String get actionSearch => 'Hľadať';

  @override
  String get actionContinue => 'Pokračovať';

  @override
  String get stateLoading => 'Načítava sa';

  @override
  String get stateErrorTitle => 'Niečo sa pokazilo';

  @override
  String get stateErrorBody =>
      'Skúste to znova. Ak problém pretrváva, kontaktujte podporu.';

  @override
  String get stateOfflineTitle => 'Ste offline';

  @override
  String get stateOfflineBody =>
      'Pripojte sa na internet a synchronizujte šatník a outfity.';

  @override
  String get settingsTitle => 'Nastavenia';

  @override
  String get settingsAccountSection => 'Účet';

  @override
  String get settingsPreferencesSection => 'Predvoľby';

  @override
  String get settingsPlanBilling => 'Predplatné a platby';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get settingsNotifications => 'Oznámenia';

  @override
  String get settingsUnits => 'Merné jednotky';

  @override
  String get settingsAppearance => 'Vzhľad';

  @override
  String get settingsPrivacySection => 'Súkromie a dáta';

  @override
  String get settingsAboutSection => 'O aplikácii';

  @override
  String get settingsSignOut => 'Odhlásiť sa';

  @override
  String get settingsDeleteAccount => 'Vymazať účet';

  @override
  String get settingsDeleteAccountTitle => 'Vymazať účet?';

  @override
  String get settingsDeleteAccountBody =>
      'Týmto odstránite svoj šatník, outfity, fotky a profil. Túto akciu nemožno vrátiť späť.';

  @override
  String get settingsUnitsImperial => 'Imperiálne (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrické (cm, kg)';

  @override
  String get languageTitle => 'Jazyk';

  @override
  String get languageSystem => 'Použiť jazyk zariadenia';

  @override
  String get languageSystemBody =>
      'FitCheck AI prispôsobí jazyk nastaveniu telefónu.';

  @override
  String get languageSearchHint => 'Hľadať jazyky';

  @override
  String get languageCurrent => 'Aktuálny';

  @override
  String get languageReviewNote =>
      'Tento preklad je nový. Dajte nám vedieť, ak niečo znie neprirodzene.';

  @override
  String get languageChanged => 'Jazyk bol aktualizovaný';

  @override
  String get paywallTitle => 'Vyberte si plán';

  @override
  String get paywallTrialBadge => '1 mesiac zadarmo';

  @override
  String get paywallTrialTitle => 'Prvý mesiac Pro máte zadarmo';

  @override
  String get paywallTrialBody =>
      'Nahrajte celý svoj šatník naraz. Ďalšie kúsky môžete pridávať priebežne.';

  @override
  String get paywallFreeForeverTitle => 'Zadarmo navždy';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Nepotrebujete kartu. Každý mesiac získate $uploads AI nahratí, $outfits outfitov a $images fotiek na fotenie denne.';
  }

  @override
  String get paywallCtaTrial => 'Spustiť mesiac zadarmo';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Prejsť na $plan';
  }

  @override
  String get paywallRestore => 'Obnoviť nákupy';

  @override
  String get paywallManage => 'Spravovať predplatné';

  @override
  String get paywallTerms => 'Podmienky používania';

  @override
  String get paywallPrivacy => 'Zásady ochrany osobných údajov';

  @override
  String get paywallPerMonth => 'za mesiac';

  @override
  String get paywallPerYear => 'za rok';

  @override
  String get paywallBestValue => 'Najlepšia hodnota';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Bezplatná skúšobná doba len pre nových predplatiteľov. Po jej skončení sa predplatné Pro obnoví za $price, pokiaľ ho zrušíte aspoň 24 hodín pred uplynutím obdobia.';
  }

  @override
  String get introTitle => 'Váš šatník, konečne usporiadaný';

  @override
  String get introBody =>
      'Ofoťte svoje oblečenie raz. Získajte nápady na oblečenie, náhľady vyskúšania a štúdiové fotky z toho, čo už vlastníte.';

  @override
  String get introStart => 'Začať';

  @override
  String get introHaveAccount => 'Už mám účet';

  @override
  String get introSkip => 'Preskočiť';

  @override
  String get authSignIn => 'Prihlásiť sa';

  @override
  String get authSignUp => 'Vytvoriť účet';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Heslo';

  @override
  String get authForgotPassword => 'Zabudli ste heslo?';

  @override
  String get authContinueApple => 'Pokračovať cez Apple';

  @override
  String get authContinueGoogle => 'Pokračovať cez Google';

  @override
  String get authOrDivider => 'alebo';

  @override
  String get wardrobeTitle => 'Šatník';

  @override
  String get wardrobeEmptyTitle => 'Váš šatník je prázdny';

  @override
  String get wardrobeEmptyBody =>
      'Pridajte svoj prvý kúsok alebo nahrajte fotku celého vešiaka naraz.';

  @override
  String get wardrobeAddFirst => 'Pridať prvý kúsok';

  @override
  String get wardrobeSearchHint => 'Hľadať v šatníku';

  @override
  String get categoryTops => 'Topy';

  @override
  String get categoryBottoms => 'Nohavice';

  @override
  String get categoryShoes => 'Topánky';

  @override
  String get categoryAccessories => 'Doplnky';

  @override
  String get categoryOuterwear => 'Vrchné oblečenie';

  @override
  String get categorySwimwear => 'Plavky';

  @override
  String get categoryActivewear => 'Športové';

  @override
  String get categoryOther => 'Iné';

  @override
  String get conditionClean => 'Čisté';

  @override
  String get conditionDirty => 'Špinavé';

  @override
  String get conditionLaundry => 'V praní';

  @override
  String get conditionRepair => 'Treba opraviť';

  @override
  String get conditionDonate => 'Na darovanie';

  @override
  String get seasonSpring => 'Jar';

  @override
  String get seasonSummer => 'Leto';

  @override
  String get seasonFall => 'Jeseň';

  @override
  String get seasonWinter => 'Zima';

  @override
  String get seasonAll => 'Celoročné';

  @override
  String get styleCasual => 'Ležérny';

  @override
  String get styleFormal => 'Formálny';

  @override
  String get styleBusiness => 'Biznis';

  @override
  String get styleSporty => 'Športový';

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
  String get styleEdgy => 'Odvážny';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Umelecký';

  @override
  String get styleClassic => 'Klasický';

  @override
  String get styleElegant => 'Elegantný';

  @override
  String get styleOther => 'Iný';

  @override
  String get occasionWork => 'Do práce';

  @override
  String get occasionDateNight => 'Na rande';

  @override
  String get occasionTravel => 'Na cesty';

  @override
  String get occasionWedding => 'Na svadbu';

  @override
  String get occasionGym => 'Do posilňovne';

  @override
  String get occasionWeekend => 'Na víkend';

  @override
  String get occasionParty => 'Na párty';

  @override
  String get occasionInterview => 'Pohovor';

  @override
  String get colorBlack => 'Čierna';

  @override
  String get colorWhite => 'Biela';

  @override
  String get colorGrey => 'Sivá';

  @override
  String get colorNavy => 'Tmavomodrá';

  @override
  String get colorBrown => 'Hnedá';

  @override
  String get colorRed => 'Červená';

  @override
  String get colorBlue => 'Modrá';

  @override
  String get colorGreen => 'Zelená';

  @override
  String get colorPink => 'Ružová';

  @override
  String get colorPurple => 'Fialová';

  @override
  String get colorYellow => 'Žltá';

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
      other: 'pred $count dňami',
      many: 'pred $count dňami',
      few: 'pred $count dňami',
      one: 'pred $count dňom',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pred $count týždňami',
      many: 'pred $count týždňami',
      few: 'pred $count týždňami',
      one: 'pred $count týždňom',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pred $count mesiacmi',
      many: 'pred $count mesiacmi',
      few: 'pred $count mesiacmi',
      one: 'pred $count mesiacom',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pred $count rokmi',
      many: 'pred $count rokmi',
      few: 'pred $count rokmi',
      one: 'pred $count rokom',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Páči sa vám FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Rýchle hodnotenie pomôže ostatným nájsť svoj štýl.';

  @override
  String get ratingPromptYes => 'Ohodnotiť aplikáciu';

  @override
  String get ratingPromptNo => 'Teraz nie';

  @override
  String get closetNoMatchesTitle => 'Žiadne položky';

  @override
  String get closetNoMatchesBody => 'Skúste zmeniť filtre alebo hľadanie.';

  @override
  String get closetClearFilters => 'Zrušiť filtre';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# kúskov',
      few: '# kúsky',
      one: '1 kúsok',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Načítavam kúsky';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vybraných',
      few: '$count vybrané',
      one: '1 vybraná',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Vymazať vybrané';

  @override
  String get closetCancelSelection => 'Zrušiť výber';

  @override
  String get closetCloseSearch => 'Zavrieť hľadanie';

  @override
  String get closetShowGrid => 'Zobraziť mriežku';

  @override
  String get closetShowList => 'Zobraziť zoznam';

  @override
  String get closetShowRows => 'Zobraziť riadky';

  @override
  String get closetStatsTitle => 'Štatistiky šatníka';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vymazať $count kúskov?',
      many: 'Vymazať $count kúskov?',
      few: 'Vymazať $count kúsky?',
      one: 'Vymazať 1 kúsok?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Tieto kúsky budú odstránené z outfitov.';

  @override
  String get closetSortBy => 'Zoradiť';

  @override
  String get closetFavourites => 'Obľúbené';

  @override
  String get closetFavourite => 'Obľúbené';

  @override
  String get closetUnfavourite => 'Odstrániť z obľúbených';

  @override
  String get closetWoreToday => 'Mám to dnes';

  @override
  String closetWornTimes(int count) {
    return 'Oblečené $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategória';

  @override
  String get closetUseCaseLabel => 'Príležitosť';

  @override
  String get closetAnyUseCase => 'Všetky';

  @override
  String get closetOtherUseCase => 'Iná príležitosť';

  @override
  String get closetOtherUseCaseHint => 'Napríklad brunch';

  @override
  String get closetUseUseCase => 'Použiť toto';

  @override
  String get closetClearAll => 'Vymazať všetko';

  @override
  String get sortNewest => 'Najnovšie';

  @override
  String get sortOldest => 'Najstaršie';

  @override
  String get sortName => 'Názov (A–Z)';

  @override
  String get sortMostWorn => 'Najčastejšie nosené';

  @override
  String get useCaseInformal => 'Neformálne';

  @override
  String get useCaseDate => 'Rande';

  @override
  String get useCaseDinner => 'Večera';

  @override
  String get useCaseLunch => 'Obed';

  @override
  String get actionSelect => 'Vybrať';

  @override
  String get actionEdit => 'Upraviť';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Zoradiť';

  @override
  String get actionAll => 'Všetky';

  @override
  String get dashboardStartClosetTitle => 'Založte si šatník';

  @override
  String get dashboardStartClosetBody =>
      'Odfotografujte pár kúskov. Označíme ich za vás.';

  @override
  String get dashboardPieces => 'kúsky';

  @override
  String get dashboardOutfits => 'outfity';

  @override
  String get dashboardDayStreak => 'dňová séria';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count tento mesiac';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Najlepšia $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count obľúbených',
      few: '$count obľúbené',
      one: '1 obľúbený',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uložených outfitov',
      few: '$count uložené outfity',
      one: '1 uložený outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Najčastejšie nosené: $name, $count-krát';
  }

  @override
  String get setupSkip => 'Preskočiť nastavenie';

  @override
  String get setupWhoTitle => 'Koho budeme štýlovať?';

  @override
  String get setupWhoBody =>
      'Nastaví model pre skúšanie a fotenie. Môžete to zmeniť vo svojom profile.';

  @override
  String get setupStyleTitle => 'Čo nosíte najčastejšie?';

  @override
  String get setupStyleBody =>
      'Vyberte čokoľvek. Nápady na outfity z toho vychádzajú.';

  @override
  String get setupClosetTitle => 'Pridajte svoje prvé kúsky.';

  @override
  String get setupClosetBody =>
      'Odfotografujte pár oblečenia alebo kopu vecí. Každý kúsok vystrihneme a zaradíme za vás.';

  @override
  String get setupAddClothes => 'Pridať oblečenie';

  @override
  String get setupStylesLabel => 'Štýly';

  @override
  String get setupOccasionsLabel => 'Príležitosti';

  @override
  String get setupSkipStep => 'Preskočiť';

  @override
  String get setupLater => 'Neskôr';

  @override
  String get setupSaveError => 'Nepodarilo sa uložiť';

  @override
  String get genderWomen => 'Ženy';

  @override
  String get genderMen => 'Muži';

  @override
  String get genderNonBinary => 'Neinári';

  @override
  String get genderPreferNotToSay => 'Neuvádzať';

  @override
  String get outfitEmptyTitle => 'Zatiaľ žiadne outfity';

  @override
  String get outfitEmptyBody =>
      'Skombinujte kúsky zo šatníka a uložte si vzhľad.';

  @override
  String get outfitNoMatchesTitle => 'Žiadne zodpovedajúce outfity';

  @override
  String get outfitSearchHint => 'Hľadať v outfitoch';

  @override
  String get outfitLoading => 'Načítavajú sa outfity';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfitov',
      few: '$count outfity',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Štýl a sezóna';

  @override
  String get outfitCollections => 'Kolekcie';

  @override
  String get outfitDuplicate => 'Duplikovať';

  @override
  String get outfitDeleteTitle => 'Vymazať tento outfit?';

  @override
  String get outfitDeleteBody => 'Jeho kúsky zostanú vo vašom šatníku.';

  @override
  String get outfitDrafts => 'Koncepty';

  @override
  String get outfitDraft => 'Koncept';

  @override
  String get filterStyle => 'Štýl';

  @override
  String get filterSeason => 'Sezóna';

  @override
  String get itemDetailDeleteTitle => 'Vymazať tento kúsok?';

  @override
  String get itemDetailDeleteBody =>
      'Outfity, ktoré ho používajú, o tento kúsok prídu.';

  @override
  String get itemAddFavourite => 'Pridať do obľúbených';

  @override
  String itemSize(String size) {
    return 'Veľkosť $size';
  }

  @override
  String get itemColours => 'Farby';

  @override
  String get itemMaterial => 'Materiál';

  @override
  String get itemPattern => 'Vzor';

  @override
  String get itemUseCases => 'Použitie';

  @override
  String get itemKeptIn => 'Umiestnenie';

  @override
  String get itemPrice => 'Cena';

  @override
  String get itemBought => 'Kúpené';

  @override
  String get itemTags => 'Značky';

  @override
  String get itemAdded => 'Pridané';

  @override
  String get itemTimesWornLabel => 'krát oblečené';

  @override
  String get itemLastWornLabel => 'naposledy oblečené';

  @override
  String get itemNeverWorn => 'Nikdy';

  @override
  String get authEntryBody =>
      'Každý kúsok vo vašom šatníku, stylizovaný cez FitCheck AI. Plánujte outfity, skúšajte ich a foťte.';

  @override
  String get authCreateCloset => 'Vytvoriť šatník';

  @override
  String get authWelcomeBack => 'Vitajte späť';

  @override
  String get authSignInBody => 'Prihláste sa a otvorte svoj šatník.';

  @override
  String get authCreateAccount => 'Vytvoriť účet';

  @override
  String get authCreateClosetBody => 'Trvá to minútu. Prvé kúsky máte zadarmo.';

  @override
  String get authName => 'Meno';

  @override
  String get authConfirmPassword => 'Potvrdiť heslo';

  @override
  String get authReferralCode => 'Odporúčací kód (nepovinné)';

  @override
  String get authResetTitle => 'Obnoviť heslo';

  @override
  String get authResetBody =>
      'Pošleme vám e-mail s odkazom na vytvorenie nového.';

  @override
  String get authSendResetLink => 'Odoslať odkaz na obnovenie';

  @override
  String get authBackToSignIn => 'Späť na prihlásenie';

  @override
  String get authEnterEmail => 'Zadajte e-mail';

  @override
  String get authEnterValidEmail => 'Zadajte platný e-mail';

  @override
  String get authEnterPassword => 'Zadajte heslo';

  @override
  String get authPasswordTooShort => 'Najmenej 6 znakov';

  @override
  String get authShowPassword => 'Zobraziť heslo';

  @override
  String get authHidePassword => 'Skryť heslo';

  @override
  String get authNewHere => 'Noví tu?';

  @override
  String authConfirmEmail(String email) {
    return 'Pred prihlásením potvrďte e-mail $email. Skontrolujte doručenú poštu.';
  }

  @override
  String get authResendEmail => 'Odoslať znova';

  @override
  String get authResendingEmail => 'Odosiela sa…';

  @override
  String get authPasswordsDoNotMatch => 'Heslá sa nezhodujú';

  @override
  String get authEnterName => 'Zadajte svoje meno';

  @override
  String get authChoosePassword => 'Zvoľte heslo';

  @override
  String get authHaveAccount => 'Máte účet?';

  @override
  String get authCodeAccepted => 'Kód prijatý';

  @override
  String get authCodeNotFound => 'Kód sa nenašiel';

  @override
  String authReferralFrom(String name) {
    return 'Od používateľa $name. Obaja získate mesiac zadarmo.';
  }

  @override
  String get authReferralInvalid => 'Tento kód sa nepodarilo nájsť.';

  @override
  String authResetSent(String email) {
    return 'Odoslané na $email. Otvorte odkaz v tomto telefóne.';
  }

  @override
  String get introSlide1Title => 'Odfoťte šatník raz.';

  @override
  String get introSlide1Body =>
      'Odfoťte kopu oblečenia. Každý kúsok sa vystrihne a uloží za vás.';

  @override
  String get introSlide2Title => 'Obliekajte sa rýchlejšie.';

  @override
  String get introSlide2Body =>
      'Outfity z toho, čo vlastníte, zladené s vašimi plánmi a počasím.';

  @override
  String get introSlide3Title => 'Pozrite si to predtým, než si to oblečiete.';

  @override
  String get introSlide3Body =>
      'Vyskúšajte si vzhľad na svojej fotke alebo ho odfoťte ako kampaň.';

  @override
  String get settingsTheme => 'Téma';

  @override
  String get settingsThemeSystem => 'Systémová';

  @override
  String get settingsThemeLight => 'Svetlá';

  @override
  String get settingsThemeDark => 'Tmavá';

  @override
  String get settingsTemperature => 'Teplota';

  @override
  String get settingsEmailUpdates => 'E-mailové novinky';

  @override
  String get settingsEmailUpdatesBody => 'Novinky a tipy e-mailom';

  @override
  String get settingsOutfitReminders => 'Pripomienky outfitov';

  @override
  String get settingsOutfitRemindersBody =>
      'Upozornenie na zaznamenanie toho, čo ste mali na sebe';

  @override
  String get settingsWeeklySummary => 'Týždenný súhrn';

  @override
  String get settingsWeeklySummaryBody => 'Váš týždeň v outfitoch';

  @override
  String get settingsStyleSection => 'Štýl';

  @override
  String get settingsPreferredStyles => 'Obľúbené štýly';

  @override
  String get settingsPreferredColours => 'Obľúbené farby';

  @override
  String get settingsNoneChosen => 'Žiadne zvolené';

  @override
  String get settingsPlanAiSection => 'Plán a FitCheck AI';

  @override
  String get settingsPlanBillingBody => 'Plán, využitie a upgrady';

  @override
  String get settingsPlanUsageBody => 'Plán a využitie';

  @override
  String get settingsInviteFriends => 'Pozvať priateľov';

  @override
  String get settingsInviteFriendsBody =>
      'Bezplatný mesiac za každého priateľa, ktorý sa pridá';

  @override
  String get settingsAiProvider => 'Poskytovateľ AI';

  @override
  String get settingsAiProviderBody =>
      'Použite vlastný model na označovanie a obrázky';

  @override
  String get settingsAppVersion => 'Verzia aplikácie';

  @override
  String get settingsPrivacyTerms => 'Súkromie a podmienky';

  @override
  String get settingsReportProblem => 'Nahlásiť problém';

  @override
  String get settingsChangePassword => 'Zmeniť heslo';

  @override
  String get settingsExportData => 'Exportovať dáta';

  @override
  String get settingsExportBody =>
      'Pripravíme súbor so všetkým, čo ste uložili, a otvoríme sťahovanie.';

  @override
  String get settingsExportAction => 'Exportovať';

  @override
  String get settingsCurrentPassword => 'Aktuálne heslo';

  @override
  String get settingsNewPassword => 'Nové heslo';

  @override
  String get settingsConfirmNewPassword => 'Potvrdiť nové heslo';

  @override
  String get settingsEnterCurrentPassword => 'Zadajte aktuálne heslo';

  @override
  String get settingsEnterNewPassword => 'Zadajte nové heslo';

  @override
  String get settingsPasswordMin8 => 'Použite aspoň 8 znakov';

  @override
  String get settingsPasswordNeedsUpper => 'Pridajte veľké písmeno';

  @override
  String get settingsPasswordNeedsLower => 'Pridajte malé písmeno';

  @override
  String get settingsPasswordNeedsDigit => 'Pridajte číslo';

  @override
  String get settingsPasswordsNoMatch => 'Heslá sa nezhodujú';

  @override
  String get settingsChangeAction => 'Zmeniť';

  @override
  String get itemAddSnapTitle => 'Odfotiť kúsok';

  @override
  String get itemAddSnapBody =>
      'Na fotke nájdeme každý kúsok a vytvoríme z neho čistý štúdiový záber.';

  @override
  String get itemAddCamera => 'Urobiť fotku';

  @override
  String get itemAddGallery => 'Vybrať z galérie';

  @override
  String get itemAddOtherWays => 'Iné spôsoby pridania';

  @override
  String get itemAddSeveral => 'Pridať viac fotiek';

  @override
  String get itemAddSeveralBody => 'Až 50 naraz';

  @override
  String get itemAddImportProfile => 'Importovať z profilu';

  @override
  String get itemAddImportProfileBody => 'Instagram alebo Facebook';

  @override
  String get itemAddEnterDetails => 'Zadať podrobnosti ručne';

  @override
  String get itemAddEnterDetailsBody => 'Fotka nie je potrebná';

  @override
  String get itemManualIntro =>
      'Stačí len názov. Zvyšok pridajte teraz alebo neskôr.';

  @override
  String get itemManualNameHint => 'Napríklad modré bavlnené tričko';

  @override
  String get itemManualEnterName => 'Zadajte názov';

  @override
  String get itemManualNotes => 'Poznámky';

  @override
  String get itemManualBrand => 'Značka';

  @override
  String get itemManualSize => 'Veľkosť';

  @override
  String get itemManualEnterNumber => 'Zadajte číslo';

  @override
  String get itemManualSavePiece => 'Uložiť kúsok';

  @override
  String get itemManualSaving => 'Ukladá sa';

  @override
  String get itemManualSavedTitle => 'Uložené';

  @override
  String itemManualSavedBody(String name) {
    return '$name je vo vašom šatníku.';
  }

  @override
  String get itemManualNotSaved => 'Neuložené';

  @override
  String get itemManualAddUseCase => 'Pridať účel použitia';

  @override
  String get itemManualAddUseCaseAction => 'Pridať účel';

  @override
  String get itemPhotos => 'Fotky';

  @override
  String get itemAddPhotos => 'Pridať fotky';

  @override
  String get itemNoPhotoYet => 'Zatiaľ žiadna fotka. Môžete uložiť aj bez nej.';

  @override
  String get itemRemovePhoto => 'Odstrániť fotku';

  @override
  String get itemRemovePiece => 'Odstrániť kúsok';

  @override
  String get filterConditionLabel => 'Stav';

  @override
  String get photoshootStepPhotos => 'Fotky';

  @override
  String get photoshootStepSetup => 'Nastavenie';

  @override
  String get photoshootStepCreating => 'Vytvára sa';

  @override
  String get photoshootStepResults => 'Výsledky';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Krok $current z $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Jedna fotka zlyhala. Skúste ju zopakovať nižšie.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotiek zlyhalo. Skúste každú zopakovať nižšie.';
  }

  @override
  String get photoshootFormat => 'Formát';

  @override
  String get photoshootHowMany => 'Koľko';

  @override
  String get photoshootYourPrompt => 'Vaša téma';

  @override
  String get photoshootPromptHint => 'Zlatá hodinka na streche, ľanová košeľa';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vytvoriť $count fotiek',
      few: 'Vytvoriť $count fotky',
      one: 'Vytvoriť 1 fotku',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotiek',
      few: 'fotky',
      one: 'fotka',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Dnešný limit sa nepodarilo overiť.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plán $plan: dnes zostáva $remaining z $limit';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Zadarmo';

  @override
  String get photoshootGallery => 'Galéria';

  @override
  String get photoshootUseCamera => 'Použiť fotoaparát';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Odstrániť fotku $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Žiadne fotky sa nevrátili';

  @override
  String get photoshootNoPhotosBody =>
      'Fotenie skončilo bez obrázkov. Skúste to znova.';

  @override
  String get photoshootNewStyle => 'Nový štýl';

  @override
  String get photoshootNewPhotos => 'Nové fotky';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Otvoriť fotku $number';
  }

  @override
  String get photoshootReportPhoto => 'Nahlásiť fotku';

  @override
  String get photoshootSaveToGallery => 'Uložiť do galérie';

  @override
  String get actionUpgrade => 'Inovovať';

  @override
  String get referralLimitTitle => 'Minuli ste dnešné fotky';

  @override
  String get referralLimitBody =>
      'Vaše bezplatné fotky sa vrátia zajtra. Odporučte priateľa a obaja získate mesiac Pro zadarmo.';

  @override
  String get referralLimitRefer => 'Odporučiť priateľa';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Zoznamka';

  @override
  String get photoshootUsePortfolio => 'Portfólio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetika';

  @override
  String get photoshootUseCustom => 'Vlastný popis';

  @override
  String get photoshootDescLinkedin => 'Profesionálne portréty do práce';

  @override
  String get photoshootDescDating => 'Uvoľnené, teplé a prirodzené';

  @override
  String get photoshootDescPortfolio => 'Editoriálne, high-fashion vzhľady';

  @override
  String get photoshootDescInstagram => 'Životné zábery pre váš feed';

  @override
  String get photoshootDescAesthetic => 'Náladové, umelecké zábery';

  @override
  String get photoshootDescCustom => 'Opíšte vzhľad, ktorý chcete';

  @override
  String get aspectSquare => 'Štvorcový';

  @override
  String get aspectPortrait => 'Na výšku';

  @override
  String get aspectLandscape => 'Na šírku';

  @override
  String get aspectTall => 'Vysoký';

  @override
  String get aspectWide => 'Široký';

  @override
  String get tryOnAppBar => 'Vyskúšať oblečenie';

  @override
  String get tryOnYourPhoto => 'Vaša fotka';

  @override
  String get tryOnGarment => 'Odev';

  @override
  String get tryOnUploadingPhoto => 'Nahratie vašej fotky';

  @override
  String get tryOnAddPhotoPrompt => 'Pridajte svoju celotelovú fotku';

  @override
  String get tryOnBodyPhotoHint => 'Najlepšie funguje celotelová fotka';

  @override
  String get tryOnAddPhoto => 'Pridať fotku';

  @override
  String get tryOnChangePhoto => 'Zmeniť fotku';

  @override
  String get tryOnPhotoLoadFailed => 'Fotku sa nepodarilo načítať.';

  @override
  String get tryOnChooseGarment => 'Vyberte fotku odevu';

  @override
  String get tryOnChooseOneGarment => 'Vyberte jednu fotku odevu';

  @override
  String get tryOnGarmentHint =>
      'Najlepšie funguje odev na rovnej podložke alebo na vešiaku';

  @override
  String get tryOnChange => 'Zmeniť';

  @override
  String get tryOnCamera => 'Fotoaparát';

  @override
  String get tryOnRemove => 'Odstrániť';

  @override
  String get tryOnLookTitle => 'Vzhľad';

  @override
  String get tryOnStyle => 'Štýl';

  @override
  String get tryOnBackground => 'Pozadie';

  @override
  String get tryOnPose => 'Póza';

  @override
  String get tryOnDressingUp => 'Obliekame vás. Trvá to asi pol minúty.';

  @override
  String get tryOnEmptyResult => 'Tvoj virtuálny model sa zobrazí tu';

  @override
  String get tryOnReportImage => 'Nahlásiť obrázok';

  @override
  String get tryOnCreating => 'Vytvára sa';

  @override
  String get tryOnTryAgain => 'Skúsiť znova';

  @override
  String get tryOnCreate => 'Vytvoriť model';

  @override
  String get tryOnBackgroundStudioWhite => 'Biele štúdio';

  @override
  String get tryOnBackgroundStudioGrey => 'Sivé štúdio';

  @override
  String get tryOnBackgroundUrban => 'Mestská ulica';

  @override
  String get tryOnBackgroundNature => 'Príroda';

  @override
  String get tryOnBackgroundMinimal => 'Minimál';

  @override
  String get tryOnPoseFront => 'Pohľad spredu';

  @override
  String get tryOnPoseSide => 'Pohľad zboku';

  @override
  String get tryOnPoseWalking => 'Chôdza';

  @override
  String get dashboardGreetingMorning => 'Dobré ráno';

  @override
  String get dashboardGreetingAfternoon => 'Dobrý deň';

  @override
  String get dashboardGreetingEvening => 'Dobrý večer';

  @override
  String get dashboardWelcome => 'Vitaj';

  @override
  String get dashboardOpenProfile => 'Otvoriť profil';

  @override
  String get dashboardRailToday => 'Dnes';

  @override
  String get dashboardRailRecently => 'Nedávne';

  @override
  String get dashboardActivityEmpty => 'Tu sa zobrazia nové kúsky a outfity.';

  @override
  String get quickAddPiece => 'Pridať kúsok';

  @override
  String get quickAddPieceBody => 'Odfotiť a označiť';

  @override
  String get quickBuildOutfit => 'Zostaviť outfit';

  @override
  String get quickBuildOutfitBody => 'Kombinuj svoje kúsky';

  @override
  String get quickForYou => 'Pre teba';

  @override
  String get quickForYouBody => 'Výber na dnešný deň';

  @override
  String get quickPlanWeek => 'Naplánovať týždeň';

  @override
  String get quickPlanWeekBody => 'Outfity podľa dní';

  @override
  String get referralBannerUrgent => 'Dochádzajú ti kredity? Pozvi priateľa.';

  @override
  String get referralBannerTitle => 'Daruj mesiac, získaj mesiac.';

  @override
  String get referralBannerBody =>
      'Ty aj tvoj priateľ získate mesiac Pro zadarmo.';

  @override
  String get referralBannerDismiss => 'Skryť na týždeň';

  @override
  String get referralBannerShare => 'Zdieľať pozvánku';

  @override
  String get referralBannerCopy => 'Kopírovať odkaz';

  @override
  String get itemEditPieceTitle => 'Upraviť kúsok';

  @override
  String get itemEditDescriptionLabel => 'Popis';

  @override
  String get itemEditNotSaved => 'Neulojené';

  @override
  String get itemEditSavedTitle => 'Uložené';

  @override
  String get itemEditSavedBody => 'Zmeny boli uložené.';

  @override
  String get itemEditSavedStalePhotos => 'Uložené — fotky môžu byť neaktuálne';

  @override
  String get itemEditRemovePieceHint => 'Vymaž tento kúsok zo stránky položky.';

  @override
  String get itemEditNoPhotos =>
      'Zatiaľ žiadne fotky. Pridaj ich z galérie alebo fotoaparátu.';

  @override
  String get itemEditKeepPhoto => 'Ponechať fotku';

  @override
  String get itemEditRemoved => 'Odstránené';

  @override
  String get itemEditAddUseCaseAction => 'Pridať';

  @override
  String get statsNoStatsTitle => 'Zatiaľ žiadne štatistiky';

  @override
  String get statsNoStatsBody =>
      'Pridaj pár kúskov a tu sa zobrazí prehľad tvojho šatníka.';

  @override
  String get statsByCategory => 'Podľa kategórie';

  @override
  String get statsTotalValue => 'celková hodnota';

  @override
  String get statsMostWorn => 'Najčastejšie nosené';

  @override
  String get statsLeastWorn => 'Čakajú na svoju šancu';

  @override
  String get statsUnnamedPiece => 'Nepomenovaný kúsok';

  @override
  String get jobsTitle => 'Skeny';

  @override
  String get jobsEmptyTitle => 'Zatiaľ žiadne skeny';

  @override
  String get jobsEmptyBody =>
      'Odfoť kúsok a pošli ho na pozadie — práca pokračuje tu.';

  @override
  String get jobsNotCancelled => 'Nezrušené';

  @override
  String get jobsResume => 'Pokračovať';

  @override
  String get jobsReview => 'Skontrolovať';

  @override
  String get jobsStop => 'Zastaviť';

  @override
  String get jobsDismiss => 'Zrušiť';

  @override
  String get reportTitle => 'Nahlásiť obsah';

  @override
  String reportIntro(String contentType) {
    return 'Povedzte nám, čo je s týmto $contentType v neporiadku. Náš tím kontroluje každé nahlásenie.';
  }

  @override
  String get reportReasonInappropriate => 'Nevhodné alebo urážlivé';

  @override
  String get reportReasonNudity => 'Nahota alebo sexuálny obsah';

  @override
  String get reportReasonHarassment => 'Obťažovanie alebo zneužívanie';

  @override
  String get reportReasonImpersonation => 'Vydávanie sa za niekoho iného';

  @override
  String get reportReasonOther => 'Iné';

  @override
  String get reportDetailsLabel => 'Ďalšie podrobnosti (voliteľné)';

  @override
  String get reportSubmit => 'Odoslať nahlásenie';

  @override
  String get reportSubmittedTitle => 'Nahlásenie odoslané';

  @override
  String get reportSubmittedBody =>
      'Ďakujeme. Náš tím tento obsah skontroluje.';

  @override
  String get reportFailedTitle => 'Nahlásenie sa nepodarilo odoslať';

  @override
  String get reportFailedBody => 'Skúste to znova.';

  @override
  String get reportContentTryOnImage => 'AI obrázok skúšania';

  @override
  String get reportContentSharedOutfit => 'zdieľaný outfit';

  @override
  String get reportContentPhotoshootImage => 'AI obrázok fotenia';

  @override
  String get sharedOutfitTitle => 'Zdieľaný outfit';

  @override
  String get sharedOutfitHideTooltip => 'Skryť tento outfit';

  @override
  String get sharedOutfitReportTooltip => 'Nahlásiť tento outfit';

  @override
  String get sharedOutfitHideTitle => 'Skryť tento outfit?';

  @override
  String get sharedOutfitHideBody =>
      'Na tomto zariadení zostane skrytý. Môžete ho aj nahlásiť, aby ho náš tím skontroloval a odstránil.';

  @override
  String get sharedOutfitHideAction => 'Skryť';

  @override
  String get sharedOutfitHiddenInfo =>
      'Tento outfit sa na tomto zariadení už nezobrazí.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit skrytý';

  @override
  String get sharedOutfitMissingTitle => 'Tento outfit tu už nie je';

  @override
  String get sharedOutfitMissingBody =>
      'Možno bol odstránený alebo je odkaz nesprávny.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Tento outfit ste skryli';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Ak je nevhodný, nahláste ho v časti Súkromie a podmienky alebo napíšte na $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Páči sa vám tento štýl?';

  @override
  String get sharedOutfitCtaBody =>
      'Vytvárajte podobné outfity zo svojho šatníka.';

  @override
  String get sharedOutfitCtaButton => 'Získať FitCheck AI';

  @override
  String get errorTitle => 'Chyba';

  @override
  String get errorUnknown => 'Vyskytla sa neočakávaná chyba';

  @override
  String get errorNoConnection =>
      'Žiadne pripojenie na internet. Skontrolujte svoju sieť.';

  @override
  String get errorTimeout =>
      'Vypršal časový limit požiadavky. Skúste to znova.';

  @override
  String get errorServerError =>
      'Na našej strane sa niečo pokazilo. Skúste to znova.';

  @override
  String get errorBadGateway =>
      'Náš server je dočasne nedostupný. Skúste to znova.';

  @override
  String get errorServiceUnavailable =>
      'Služba je dočasne nedostupná. Skúste to o chvíľu znova.';

  @override
  String get errorInternalError => 'Niečo sa pokazilo. Skúste to znova.';

  @override
  String get errorUnauthorized => 'Ak chcete pokračovať, prihláste sa.';

  @override
  String get errorForbidden => 'Na toto nemáte prístup.';

  @override
  String get errorSessionExpired =>
      'Vaša relácia vypršala. Prihláste sa znova.';

  @override
  String get errorInvalidCredentials =>
      'Zadaný e-mail alebo heslo nie je správne.';

  @override
  String get errorTokenRefreshFailed =>
      'Nepodarilo sa obnoviť vašu reláciu. Prihláste sa znova.';

  @override
  String get errorRequestCancelled => 'Požiadavka bola zrušená.';

  @override
  String get errorInvalidFormat => 'Tento formát súboru nie je podporovaný.';

  @override
  String get errorFileTooLarge => 'Tento súbor je príliš veľký.';

  @override
  String get errorUploadFailed => 'Nahranie zlyhalo. Skúste to znova.';

  @override
  String get errorCacheCorrupted =>
      'Uložené dáta boli poškodené a boli resetované.';

  @override
  String get errorCacheNotFound => 'Zatiaľ nič nie je uložené.';

  @override
  String get errorUserNotFound => 'Tento účet sa nenašiel.';

  @override
  String get errorItemNotFound => 'Táto položka už neexistuje.';

  @override
  String get errorOutfitNotFound => 'Tento outfit už neexistuje.';

  @override
  String get rewardsTitle => 'Odmeny';

  @override
  String get rewardsNoAchievementsTitle => 'Zatiaľ žiadne úspechy';

  @override
  String get rewardsNoAchievementsBody =>
      'Pridajte kúsky a plánujte outfity, aby ste získali prvý.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Zatiaľ nikto v rebríčku';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plánujte outfity, zbierajte body a ukážte sa tu.';

  @override
  String get legalViewPrivacyPolicy =>
      'Zobraziť zásady ochrany osobných údajov';

  @override
  String get aiConsentAgree => 'Súhlasím a pokračovať';

  @override
  String get aiConsentNotNow => 'Teraz nie';

  @override
  String get imageViewerCloseTooltip => 'Zavrieť zobrazenie obráka';

  @override
  String get updateReadyTitle => 'Aktualizácia je pripravená';

  @override
  String get updateReadyBody =>
      'Reštartujte FitCheck AI, aby sa použili najnovšie vylepšenia.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI potrebuje prístup k fotoaparátu na fotenie vašich outfitov a kúskov v šatníku.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI potrebuje prístup k fotkám na výber obrázkov vašich outfitov a kúskov v šatníku.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI potrebuje ukladať vaše AI vygenerované fotky outfitov do knižnice fotiek.';

  @override
  String get wardrobeSomePhotosSkipped => 'Niektoré fotky boli preskočené';

  @override
  String get wardrobePhotosNotAdded => 'Fotky neboli pridané';

  @override
  String get wardrobePhotoNotAdded => 'Fotka nebola pridaná';

  @override
  String get wardrobeNotStartedTitle => 'Nezapojené';

  @override
  String get wardrobeNoRoomTitle => 'Žiadne miesto';

  @override
  String get wardrobeAddPhotosSemantic => 'Pridať fotky';

  @override
  String get batchAddTileLabel => 'Pridať';

  @override
  String get batchProfileLinkLabel => 'Odkaz na profil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importovať z profilu';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Pridať viac fotiek';

  @override
  String get wardrobeClearAction => 'Vymazať';

  @override
  String get wardrobeRefreshTooltip => 'Obnoviť';

  @override
  String get batchNoPhotosYetTitle => 'Zatiaľ žiadne fotky';

  @override
  String get batchChoosePhotosAction => 'Vybrať fotky';

  @override
  String get batchWeFindEachPieceBody =>
      'Nájdem každý kúsok a vytvoríme z neho štúdiovú fotku.';

  @override
  String get batchPreparingPhotosSemantic => 'Pripravujú sa fotky';

  @override
  String get batchPhotosProcessedSemantic => 'Fotky spracované';

  @override
  String get batchPasteProfileLinkTitle => 'Prilepiť odkaz na profil';

  @override
  String get batchPasteProfileLinkBody =>
      'Verejný profil na Instagrame alebo Facebooku. Naskenujeme jeho fotky a vy si vyberiete, čo pôjde do vášho šatníka.';

  @override
  String get batchClearLinkTooltip => 'Vymazať odkaz';

  @override
  String get batchStartingButton => 'Spúšťa sa';

  @override
  String get batchStartImportAction => 'Spustiť import';

  @override
  String get batchReviewEveryPhotoTitle => 'Každú fotku skontrolujete';

  @override
  String get batchReviewEveryPhotoBody => 'Nič sa nepridá, kým to neschválite.';

  @override
  String get batchPrivateProfilesTitle => 'Súkromné profily';

  @override
  String get batchPrivateProfilesBody =>
      'Prepojte svoj účet. Instagram vyžaduje aj používateľské meno a heslo.';

  @override
  String get batchUseAnotherLinkAction => 'Použiť iný odkaz';

  @override
  String get batchSignInNeededTitle => 'Vyžaduje sa prihlásenie';

  @override
  String get batchEnterYourCodeTitle => 'Zadajte kód';

  @override
  String get batchUseUsernamePasswordAction => 'Použiť meno a heslo';

  @override
  String get batchAlreadyConnectedAction => 'Už som sa pripojil v prehliadači';

  @override
  String get batchEnterCodeAction => 'Zadať kód';

  @override
  String get batchTryAnotherWayAction => 'Skúsiť inak';

  @override
  String get batchLiveStatus => 'Naživo';

  @override
  String get batchReconnectingStatus => 'Pripájanie';

  @override
  String get batchSignInToInstagramTitle => 'Prihlásiť sa do Instagramu';

  @override
  String get batchUsernameLabel => 'Používateľské meno';

  @override
  String get batchCodeIfTwoStepLabel => 'Kód, ak používate dvojfázové overenie';

  @override
  String get batchAuthenticatorCodeBody =>
      'Zadajte 6-miestny kód z overovacej aplikácie. Kódy sa rýchlo menia.';

  @override
  String get batchVerifyAction => 'Overiť';

  @override
  String get batchFindingPhotosTitle => 'Hľadanie fotiek';

  @override
  String get batchImportPausedTitle => 'Import pozastavený';

  @override
  String get batchProcessingPhotosTitle => 'Spracovanie fotiek';

  @override
  String get batchWaitingNextPhoto => 'Čaká sa na ďalšiu fotku';

  @override
  String get batchCancelImportAction => 'Zrušiť import';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Na tejto fotke sa nenašli žiadne kúsky.';

  @override
  String get batchEditPieceColoursLabel => 'Farby oddelené čiarkami';

  @override
  String get batchAddToClosetAction => 'Pridať do šatníka';

  @override
  String get batchSkipPhotoAction => 'Preskočiť fotku';

  @override
  String get batchImportCompleteTitle => 'Import dokončený';

  @override
  String get batchImportFailedTitle => 'Import zlyhal';

  @override
  String get batchImportCancelledTitle => 'Import zrušený';

  @override
  String get batchImportErrorBody => 'Pri importe sa niečo pokazilo.';

  @override
  String get batchNothingMoreImportedBody =>
      'Z tohto profilu sa už nič ďalšie neimportuje.';

  @override
  String get batchViewClosetAction => 'Zobraziť šatník';

  @override
  String get batchStartOverAction => 'Začať odznova';

  @override
  String get wardrobeAddPieceTitle => 'Pridať kúsok';

  @override
  String get wardrobeAddDetailsTitle => 'Pridať podrobnosti';

  @override
  String get wardrobeScanningTitle => 'Skenovanie';

  @override
  String get batchReviewPiecesTitle => 'Skontrolovať kúsky';

  @override
  String get wardrobeGalleryAction => 'Galéria';

  @override
  String get wardrobeCameraAction => 'Fotoaparát';

  @override
  String get wardrobeNewBadge => 'Nové';

  @override
  String get wardrobeRemovePhotoTooltip => 'Odstrániť fotku';

  @override
  String get batchRunInBackgroundTooltip => 'Spustiť na pozadí';

  @override
  String get batchStepOneOfTwo => 'Krok 1 z 2';

  @override
  String get batchStepTwoOfTwo => 'Krok 2 z 2';

  @override
  String get batchUploadingPhotosTitle => 'Nahrávanie fotiek';

  @override
  String get batchFindingPiecesTitle => 'Hľadanie kúskov';

  @override
  String get batchMakingStudioPhotosTitle => 'Tvorba štúdiových fotiek';

  @override
  String get batchStoppedLabel => 'Zastavené';

  @override
  String get batchFindingPiecesStoppedTitle => 'Hľadanie kúskov zastavené';

  @override
  String get batchCancelledLabel => 'Zrušené';

  @override
  String get batchAllDoneTitle => 'Všetko je hotové';

  @override
  String get batchOpeningPiecesBody => 'Otvoríte svoje kúsky';

  @override
  String get batchNothingSavedBody => 'Nič sa neuložilo.';

  @override
  String get batchFindingPiecesFailedBody => 'Hľadanie kúskov zlyhalo.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Hľadanie kúskov sa predčasne zastavilo.';

  @override
  String get batchStopFindingPiecesTitle => 'Zastaviť hľadanie kúskov?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skenovanie sa zastaví a nič sa neuloží. Už nájdené kúsky zostanú vo vašej aktivite, kým ich neodstránite.';

  @override
  String get batchKeepGoingAction => 'Pokračovať';

  @override
  String get batchTryAgainAction => 'Skúsiť znova';

  @override
  String get batchBackToPhotosAction => 'Späť na fotky';

  @override
  String get batchSkipAllAction => 'Preskočiť všetko';

  @override
  String get batchIncludeAllAction => 'Zahrnúť všetko';

  @override
  String get batchNoPiecesFoundTitle => 'Nenašli sa žiadne kúsky';

  @override
  String get batchNoPiecesFoundBody =>
      'Na týchto fotkách sme nenašli žiadne oblečenie.';

  @override
  String get batchChooseOtherPhotosAction => 'Vybrať iné fotky';

  @override
  String get batchUseCaseHelper => 'Pridané ku každému uloženému kúsku.';

  @override
  String get batchDiscardPiecesTitle => 'Zahodiť tieto kúsky?';

  @override
  String get batchDiscardPiecesBody => 'Z tejto série sa nič neuloží.';

  @override
  String get batchKeepAction => 'Ponechať';

  @override
  String get batchDiscardAction => 'Zahodiť';

  @override
  String get batchRemovePieceTitle => 'Odstrániť tento kúsok?';

  @override
  String get batchRemovePieceBody => 'Nie je uložený vo vašom šatníku.';

  @override
  String get batchRemoveAction => 'Odstrániť';

  @override
  String get batchChoosePiecesToSave => 'Vybrať kúsky na uloženie';

  @override
  String get batchDiscardAllAction => 'Zahodiť všetko';

  @override
  String get batchNothingSavedRetryBody => 'Nič sa neuložilo. Skúste to znova.';

  @override
  String get batchNotSavedTitle => 'Neuložené';

  @override
  String get batchSavingLabel => 'Ukladá sa';

  @override
  String get batchSendToBackgroundAction => 'Presunúť na pozadie';

  @override
  String get batchStillWorkingMessage =>
      'Stále pracujeme. Dáme vám vedieť, keď budú vaše kúsky pripravené.';

  @override
  String get batchRunningInBackgroundTitle => 'Beží na pozadí';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Tvorba ateliérových fotiek sa zastavila. Tieto kúsky si stále môžete uložiť.';

  @override
  String get batchTapPieceToSkip => 'Ťuknutím na kúsok ho preskočíte.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Ateliérové fotky sú na ceste. Môžete odísť – dáme vám vedieť.';

  @override
  String get batchLeaveAction => 'Odísť';

  @override
  String get batchPeopleInPhotosTitle => 'Ľudia na fotkách';

  @override
  String get batchIncludeAction => 'Zahrnúť';

  @override
  String get batchSkipAction => 'Preskočiť';

  @override
  String get batchYourPhotoIsUsedLabel => 'Používa sa vaša fotka';

  @override
  String get batchMakingStudioPhotoLabel => 'Vytvára sa ateliérová fotka';

  @override
  String get batchNoStudioPhotoBody =>
      'Žiadna ateliérová fotka. Používa sa vaša.';

  @override
  String get batchEnterDetailsYourselfAction => 'Zadať údaje ručne';

  @override
  String get batchChooseAnotherPhotoAction => 'Vybrať inú fotku';

  @override
  String get batchConnectionLostTitle => 'Strata pripojenia';

  @override
  String get batchConnectionLostBody =>
      'Skontrolujte pripojenie a skúste to znova.';

  @override
  String get batchDailyLimitTitle => 'Denný limit dosiahnutý';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Prejdite na Pro pre viac skenov alebo zadajte údaje ručne.';

  @override
  String get batchDailyLimitBodyFree =>
      'Skeny sa resetujú zajtra. Údaje môžete zadať ručne hneď.';

  @override
  String get batchSeePlansAction => 'Zobraziť plány';

  @override
  String get batchAiBusyTitle => 'Naša AI je zaneprázdnená';

  @override
  String get batchAiBusyBody =>
      'Chyba je na našej strane. Skúste to o chvíľu znova.';

  @override
  String get batchNoPiecesBody =>
      'Skúste jasnejšiu fotku alebo zadajte údaje ručne.';

  @override
  String get batchScanningUnavailableTitle => 'Skenovanie je nedostupné';

  @override
  String get batchScanningUnavailableBody => 'Zatiaľ zadajte údaje ručne.';

  @override
  String get batchScanDidNotFinishTitle => 'Skenovanie sa nedokončilo';

  @override
  String get batchTryAgainBody => 'Skúste to znova.';

  @override
  String get billingTitle => 'Predplatné';

  @override
  String get billingUpgradeHeading => 'Inovovať plán';

  @override
  String get billingUpgradeOnPlusBody => 'Rovnaké funkcie, vyššie limity.';

  @override
  String get billingUpgradeBody =>
      'Plus a Pro majú rovnaké funkcie. Vyberte si limity, aké potrebujete.';

  @override
  String get billingWebUnavailableBody =>
      'Online inovácie zatiaľ nie sú dostupné. Promo kód alebo odporúčanie stále odomkne Plus alebo Pro. Pozvite priateľov nižšie a získajte mesiace zadarmo.';

  @override
  String get billingPlansStale =>
      'Nepodarilo sa načítať najnovšie plány. Ceny môžu byť neaktuálne.';

  @override
  String get billingMonthly => 'Mesačne';

  @override
  String get billingYearly => 'Ročne';

  @override
  String get billingCurrentPlan => 'Aktuálny plán';

  @override
  String get billingActive => 'Aktívne';

  @override
  String get billingThisMonth => 'Tento mesiac';

  @override
  String get billingItemExtractions => 'Extrakcie položiek';

  @override
  String get billingOutfitVisualizations => 'Vizualizácie outfitov';

  @override
  String get billingNearLimitUpgrade =>
      'Blížite sa k tohtomesačnému limitu. Inovujte pre viac.';

  @override
  String get billingNearLimitResets =>
      'Blížite sa k tohtomesačnému limitu. Obnoví sa začiatkom budúceho mesiaca.';

  @override
  String get billingStoreUnavailable =>
      'Aktualizácie zatiaľ nie sú v obchode dostupné. Skúste to neskôr.';

  @override
  String get billingManageHeading => 'Správa predplatného';

  @override
  String get billingCancelPlan => 'Zrušiť predplatné';

  @override
  String get billingCancelKeepsAccess =>
      'Prístup vám zostane do konca tohto fakturačného obdobia.';

  @override
  String get billingCancelConfirmTitle => 'Zrušiť predplatné?';

  @override
  String get billingKeepPlan => 'Ponechať predplatné';

  @override
  String get billingCancelPlanAction => 'Zrušiť plán';

  @override
  String get billingBilledMonthly => 'Fakturované mesačne';

  @override
  String get billingBilledYearly => 'Fakturované ročne';

  @override
  String get billingVirtualTryOn => 'Virtuálne skúšanie';

  @override
  String get billingPrioritySupport => 'Prednostná podpora';

  @override
  String get billingDisclosureProRenewing =>
      'Pro je automaticky obnovované predplatné';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus a Pro sú automaticky obnovované predplatné';

  @override
  String get billingDisclosureAppleBilling =>
      'Platba bude zaúčtovaná na váš účet Apple ID po potvrdení nákupu.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Platba bude zaúčtovaná na váš účet Google Play po potvrdení nákupu.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Predplatné sa automaticky obnovuje na rovnaké obdobie za rovnakú cenu, pokiaľ autoobnovenie nevypnete aspoň 24 hodín pred koncom aktuálneho obdobia.';

  @override
  String get billingDisclosureAppleManage =>
      'Spravujte alebo zrušte kedykoľvek v Nastavenia › vaše Apple ID › Predplatné.';

  @override
  String get billingDisclosureGoogleManage =>
      'Spravujte alebo zrušte kedykoľvek v Google Play › Platby a predplatné.';

  @override
  String get billingReferFriend => 'Odporučiť priateľovi';

  @override
  String get billingHowItWorks => 'Ako to funguje';

  @override
  String get billingHowShareTitle => 'Zdieľajte odkaz';

  @override
  String get billingHowShareBody => 'Pošlite ho priateľovi.';

  @override
  String get billingHowSignUpTitle => 'Priateľ sa zaregistruje';

  @override
  String get billingHowSignUpBody => 'Váš priateľ sa pripojí cez odkaz.';

  @override
  String get billingHowBothTitle => 'Obaja získate Pro';

  @override
  String get billingHowBothBody => 'Každý z vás získava mesiac Pro zadarmo.';

  @override
  String get billingYourReferrals => 'Vaše odporúčania';

  @override
  String get billingInvited => 'Pozvaní';

  @override
  String get billingJoined => 'Pripojení';

  @override
  String get billingMonthsEarned => 'Získané mesiace';

  @override
  String get billingInviteFriend => 'Pozvať priateľa';

  @override
  String get billingInviteBody =>
      'Vy aj váš priateľ získate mesiac predplatného Pro.';

  @override
  String get billingYourCode => 'Váš kód';

  @override
  String get billingCopyLink => 'Kopírovať odkaz';

  @override
  String get billingShareInvite => 'Zdieľať pozvánku';

  @override
  String get giftUnavailable =>
      'Darčekové pozvánky nie sú v tejto verzii dostupné.';

  @override
  String get giftPageTitle => 'Darovať FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Momentálne nie sú k dispozícii žiadne bezplatné pozvánky.';

  @override
  String get giftFormTitle => 'Odoslať bezplatnú pozvánku';

  @override
  String get giftFormBody =>
      'Obdarovaný si darček uplatní pomocou tohto overeného emailu. Email neodosielame za vás.';

  @override
  String get giftFieldFrom => 'Od';

  @override
  String get giftFieldRecipientName => 'Meno príjemcu';

  @override
  String get giftFieldRecipientEmail => 'Email príjemcu';

  @override
  String get giftFieldOccasion => 'Príležitosť (voliteľné)';

  @override
  String get giftNoOccasion => 'Bez príležitosti';

  @override
  String get giftOccasionBirthday => 'Narodeniny';

  @override
  String get giftOccasionAnniversary => 'Výročie';

  @override
  String get giftOccasionOther => 'Iné';

  @override
  String get giftFieldCardGreeting => 'Pozdrav na karte';

  @override
  String get giftFieldCardGreetingHelper =>
      'Toto sa zobrazí na karte presne tak, ako to napíšete.';

  @override
  String get giftFieldPrivateNote => 'Súkromná poznámka (voliteľné)';

  @override
  String get giftCreateAction => 'Vytvoriť bezplatný darček';

  @override
  String get giftClaimedTitle => 'Darček uplatnený';

  @override
  String get giftClaimedActive => 'Váš darček FitCheck Pro je aktívny.';

  @override
  String get giftClaimedQueued =>
      'Váš darček FitCheck Pro začne platiť po skončení aktuálneho prístupu.';

  @override
  String get giftLinkCopied => 'Odkaz na darček bol skopírovaný do schránky.';

  @override
  String get giftErrorName => 'Zadajte meno.';

  @override
  String get giftErrorEmail => 'Zadajte platnú emailovú adresu.';

  @override
  String get giftErrorGreeting => 'Zadajte pozdrav na karte.';

  @override
  String get giftErrorGreetingLength => 'Použite maximálne 80 znakov.';

  @override
  String get giftClaimAction => 'Získať darček';

  @override
  String get giftCardPreview => 'Náhľad karty';

  @override
  String get giftGiftForYou => 'Darček pre vás';

  @override
  String get giftGiftWaiting => 'Čaká na vás darček';

  @override
  String get giftOpenBody =>
      'Otvorte svoje darčeky a získajte ich pomocou overeného emailu.';

  @override
  String get giftOpenGifts => 'Otvoriť darčeky';

  @override
  String get giftSendInvitation => 'Odoslať pozvánku';

  @override
  String get settingsAiProviderSection => 'Poskytovateľ';

  @override
  String get settingsAiCustom => 'Vlastný';

  @override
  String get settingsAiUrlHelper =>
      'Použite verejnú URL, ktorú server dosiahne. Lokálny server nefunguje.';

  @override
  String get settingsAiConnectionSection => 'Pripojenie';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API kľúč';

  @override
  String get settingsAiApiKeySaved =>
      'Uložené. Nechajte prázdne, ak chcete zachovať.';

  @override
  String get settingsAiChatModel => 'Chatovací model';

  @override
  String get settingsAiVisionModel => 'Vizionársky model (voliteľné)';

  @override
  String get settingsAiImageModel => 'Model obrázkov (voliteľné)';

  @override
  String get settingsAiImageModelNote =>
      'Generovanie obrázkov vyžaduje chat kompatibilný s OpenAI pomocou response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testovať pripojenie';

  @override
  String get calendarTitle => 'Kalendár';

  @override
  String get calendarGoToToday => 'Prejsť na dnešok';

  @override
  String get calendarConnectTooltip => 'Pripojiť kalendár';

  @override
  String get calendarAddEvent => 'Pridať udalosť';

  @override
  String get calendarEmptyTitle => 'Žiadne plány';

  @override
  String get calendarEmptyBody =>
      'Pridajte udalosť a naplánujte si, čo si oblečiete.';

  @override
  String get calendarPreviousMonth => 'Predchádzajúci mesiac';

  @override
  String get calendarNextMonth => 'Nasledujúci mesiac';

  @override
  String get calendarAllDay => 'Celý deň';

  @override
  String get calendarOutfitLinked => 'Prepojený outfit';

  @override
  String get calendarEventOptions => 'Možnosti udalosti';

  @override
  String get calendarDeleteTitle => 'Vymazať túto udalosť?';

  @override
  String get calendarChangeOutfit => 'Zmeniť outfit';

  @override
  String get calendarLinkOutfit => 'Prepojiť outfit';

  @override
  String get calendarRemoveOutfit => 'Odstrániť outfit';

  @override
  String get calendarNewEvent => 'Nová udalosť';

  @override
  String get calendarEditEvent => 'Upraviť udalosť';

  @override
  String get calendarTitleLabel => 'Názov';

  @override
  String get calendarTitleRequired => 'Pridajte názov';

  @override
  String get calendarEndBeforeStart => 'Koniec po začiatku';

  @override
  String get calendarStarts => 'Začiatok';

  @override
  String get calendarEnds => 'Koniec';

  @override
  String get calendarPlaceOptional => 'Miesto (voliteľné)';

  @override
  String get calendarNotesOptional => 'Poznámky (voliteľné)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Vytvorte outfit a prepojte ho s touto udalosťou.';

  @override
  String get calendarBuildOutfit => 'Vytvoriť outfit';

  @override
  String get calendarConnectionsTitle => 'Kalendáre';

  @override
  String get calendarConnectionsBody =>
      'Udalosti pridané sem zostanú vo FitCheck AI.';

  @override
  String get calendarDisconnect => 'Odpojiť';

  @override
  String get calendarNotAvailable => 'Zatiaľ k dispozícii';

  @override
  String get profileSectionExplore => 'Objaviť';

  @override
  String get profileNavTryOn => 'Vyskúšať';

  @override
  String get profileNavRewards => 'Odmeny';

  @override
  String get profileSupport => 'Podpora';

  @override
  String get profileHelp => 'Pomoc';

  @override
  String get profileAbout => 'O aplikácii';

  @override
  String get profileAboutBody =>
      'Váš šatník, outfity a plány na jednom mieste.';

  @override
  String get profileSignOutTitle => 'Odhlásiť sa?';

  @override
  String get profileSignOutBody => 'Kedykoľvek sa môžete znova prihlásiť.';

  @override
  String get profileEditTitle => 'Upraviť profil';

  @override
  String get profileYourProfile => 'Váš profil';

  @override
  String get profileBodyProfiles => 'Profily postavy';

  @override
  String get profileBodyEmptyTitle => 'Zatiaľ žiadne profily';

  @override
  String get profileBodyEmptyBody =>
      'Pridajte svoju výšku a postavu pre lepšie výsledky.';

  @override
  String get profileBodyAdd => 'Pridať profil';

  @override
  String get profileBodyDefaultNote =>
      'Predvolený profil sa používa na strih a skúšanie.';

  @override
  String get profileBodyDefaultBadge => 'Predvolený';

  @override
  String get profileBodyMakeDefault => 'Nastaviť ako predvolený';

  @override
  String get profileBodyDeleteBody => 'Túto akciu nie je možné vrátiť späť.';

  @override
  String get profileBodyRequired => 'Povinné';

  @override
  String get profileBodyCheckNumber => 'Skontrolujte toto číslo';

  @override
  String get profileBodyNew => 'Nový profil postavy';

  @override
  String get profileBodyNameHint => 'Napríklad Ja';

  @override
  String get profileBodyHeight => 'Výška';

  @override
  String get profileBodyWeight => 'Hmotnosť';

  @override
  String get profileBodyBuild => 'Postava';

  @override
  String get profileBodySkinTone => 'Tón pleti';

  @override
  String get profileBirthDateNeededBody =>
      'Pridajte dátum narodenia k času narodenia.';

  @override
  String get profileBirthDateNeededTitle => 'Vyžaduje sa dátum narodenia';

  @override
  String get profilePartlySavedBody =>
      'Uložili sme vaše meno a fotku. Údaje o narodení sa neuložili, skúste to neskôr.';

  @override
  String get profilePartlySavedTitle => 'Čiastočne uložené';

  @override
  String get profileSavedBody => 'Váš profil je uložený.';

  @override
  String get profileChangePhoto => 'Zmeniť fotku profilu';

  @override
  String get profilePhotoLabel => 'Profilová fotka';

  @override
  String get profilePhotoHint => 'Ťuknutím vyberiete novú';

  @override
  String get profileBirthDateLabel => 'Dátum narodenia (voliteľné)';

  @override
  String get profileBirthTimeLabel => 'Čas narodenia (voliteľné)';

  @override
  String get profileBirthTimeHelper => 'Spresňuje védske odporúčania';

  @override
  String get profileBirthPlaceLabel => 'Miesto narodenia (voliteľné)';

  @override
  String get profileBirthPlaceHint => 'Napríklad Bratislava, Slovensko';

  @override
  String get profileHelpContactTitle => 'Opýtajte sa nás čokoľvek';

  @override
  String get profileHelpContactBody =>
      'Pošlite nám správu a odpovieme vám e-mailom, zvyčajne do jedného dňa.';

  @override
  String get profileHelpContactAction => 'Kontaktovať podporu';

  @override
  String get profileHelpFaqTitle => 'Časté otázky';

  @override
  String get profileFaqAddPiecesTitle => 'Ako pridám kúsky do šatníka?';

  @override
  String get profileFaqAddPiecesBody =>
      'Ťuknite na Pridať položku na karte Šatník. Ofoťte kúsok alebo vyberte fotku z galérie, my ho rozpoznáme a označíme za vás.';

  @override
  String get profileFaqMatchingTitle => 'Ako funguje vytváranie outfitov?';

  @override
  String get profileFaqMatchingBody =>
      'Otvorte Pre vás a vyberte si kúsok, ktorý vlastníte. Navrhneme vám k nemu vhodné kombinácie a zostavíme kompletné outfity z vášho šatníka.';

  @override
  String get profileFaqTryOnTitle => 'Môžem použiť vlastné fotky na skúšanie?';

  @override
  String get profileFaqTryOnBody =>
      'Áno. Pridajte svoju fotku celej postavy a vyberte si kúsky, ktoré si chcete na sebe vyskúšať.';

  @override
  String get profileFaqRewardsTitle => 'Ako získam odmeny?';

  @override
  String get profileFaqRewardsBody =>
      'Plánujte a zaznamenávajte si outfity pravidelne. Séria a úspechy pribúdajú s každým dňom.';

  @override
  String get profileFaqPrivacyTitle => 'Je môj šatník súkromný?';

  @override
  String get profileFaqPrivacyBody =>
      'Áno. Váš šatník a outfity sú súkromné, pokiaľ nezdieľate odkaz na konkrétny outfit.';

  @override
  String get profileHelpMoreTitle => 'Viac pomoci';

  @override
  String get profileHelpGuides => 'Príručky';

  @override
  String get profileHelpGuidesBody => 'Ako funguje jednotlivé funkcie';

  @override
  String get feedbackCategoryBug => 'Niečo nefunguje';

  @override
  String get feedbackCategoryIdea => 'Nápad';

  @override
  String get feedbackCategoryGeneral => 'Všeobecné';

  @override
  String get feedbackCategoryHelp => 'Potrebujem pomoc';

  @override
  String get feedbackHintBug =>
      'Čo sa stalo a čo ste očakávali? Kroky nám pomôžu chybu opraviť.';

  @override
  String get feedbackHintIdea => 'Čo by ste chceli a prečo?';

  @override
  String get feedbackHintGeneral =>
      'Napíšte nám svoj názor alebo položte otázku.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Môžete pridať maximálne 5 obrázkov.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limit dosiahnutý';

  @override
  String get feedbackImageTooLargeBody => 'Vyberte obrázok menší ako 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Obrázok je príliš veľký';

  @override
  String get feedbackTitle => 'Odoslať spätnú väzbu';

  @override
  String get feedbackAboutLabel => 'O čo ide?';

  @override
  String get feedbackSubjectLabel => 'Predmet';

  @override
  String get feedbackSubjectRequired => 'Zadajte predmet';

  @override
  String get feedbackSubjectTooShort => 'Predmet musí mať aspoň 3 znaky';

  @override
  String get feedbackDetailsLabel => 'Podrobnosti';

  @override
  String get feedbackDetailsRequired => 'Zadajte podrobnosti';

  @override
  String get feedbackDetailsTooShort => 'Popis musí mať aspoň 10 znakov';

  @override
  String get feedbackAddScreenshot => 'Pridať snímku obrazovky';

  @override
  String get feedbackAttachmentHint => 'Najviac 5, každá max. 5 MB';

  @override
  String get feedbackSend => 'Odoslať';

  @override
  String get feedbackEmptyTitle => 'Zatiaľ nič odoslané';

  @override
  String get feedbackEmptyBody =>
      'Vaše odoslané správy a ich stav sa zobrazia tu.';

  @override
  String get feedbackHistoryTitle => 'Vaše odoslané';

  @override
  String get feedbackStatusOpen => 'Otvorené';

  @override
  String get feedbackStatusInProgress => 'Rieši sa';

  @override
  String get feedbackStatusResolved => 'Vyriešené';

  @override
  String get feedbackStatusClosed => 'Zatvorené';

  @override
  String get legalIntro =>
      'Ako chránime vaše údaje a podmienky používania aplikácie FitCheck AI.';

  @override
  String get legalPolicies => 'Zásady';

  @override
  String get legalPrivacySubtitle => 'Čo zbierame a prečo';

  @override
  String get legalTermsTitle => 'Podmienky služby';

  @override
  String get legalTermsSubtitle => 'Pravidlá používania aplikácie';

  @override
  String get legalLicences => 'Licencie open-source';

  @override
  String get legalSupportSubtitle => 'Pomoc, kontakt a žiadosti o súkromie';

  @override
  String get legalReportAbuse => 'Nahlásiť problém alebo zneužitie';

  @override
  String get permissionCameraTitle => 'Prístup ku kamere';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI používa kameru na fotenie oblečenia a outfitov pre AI skúšanie a organizáciu šatníka.';

  @override
  String get permissionPhotoTitle => 'Prístup k fotkám';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI potrebuje prístup k fotkám, aby ste mohli vyberať obrázky oblečenia pre AI funkcie a šatník.';

  @override
  String get permissionNotNow => 'Teraz nie';

  @override
  String get permissionOpenSettings => 'Otvoriť nastavenia';

  @override
  String authSignedInAs(String name) {
    return 'Prihlásený ako $name';
  }

  @override
  String get authSignedIn => 'Prihlásený';

  @override
  String get authWelcomeBackTitle => 'Vitajte späť';

  @override
  String get authSignInFailed => 'Prihlásenie zlyhalo';

  @override
  String get authWelcomeTitle => 'Vitajte';

  @override
  String get authSignUpFailed => 'Registrácia zlyhala';

  @override
  String get authGoogleSignInFailed => 'Prihlásenie cez Google zlyhalo';

  @override
  String get authAppleSignInFailed => 'Prihlásenie cez Apple zlyhalo';

  @override
  String get authConfirmEmailTitle => 'Potvrďte svoj email';

  @override
  String get authConfirmEmailBody =>
      'Skontrolujte doručenú poštu a potvrďte email, potom sa prihláste.';

  @override
  String get authClosetReady => 'Váš šatník je pripravený.';

  @override
  String get authSignedOutTitle => 'Odhlásený';

  @override
  String get authSignedOutBody => 'Ste odhlásení.';

  @override
  String get authSignOutFailed => 'Odhlásenie zlyhalo';

  @override
  String get authEmailSentTitle => 'Email odoslaný';

  @override
  String get authResetLinkSent => 'Skontrolujte email pre odkaz na obnovenie.';

  @override
  String get authPasswordUpdatedTitle => 'Heslo aktualizované';

  @override
  String get authPasswordUpdated => 'Vaše heslo je aktualizované.';

  @override
  String get authPasswordNotUpdated => 'Heslo nebolo aktualizované';

  @override
  String get authCouldNotSendEmail => 'Nepodarilo sa odoslať email';

  @override
  String get authEmailNotSent => 'Email nebol odoslaný';

  @override
  String get authResendSentBody => 'Odoslali sme nový potvrdzujúci email.';

  @override
  String get outfitPreviewWithAi => 'Náhľad s AI';

  @override
  String get outfitNewPreview => 'Vytvoriť nový náhľad';

  @override
  String get outfitBuilderClosetHeading => 'Tvoja skriňa';

  @override
  String get outfitBuilderSearchHint => 'Hľadať kúsky';

  @override
  String get outfitClearSearch => 'Zmazať hľadanie';

  @override
  String get outfitBuilderAddPiecesTitle => 'Najprv pridaj kúsky';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfity sa skladajú z kúskov v tvojej skrini.';

  @override
  String get outfitBuilderNoMatches => 'Žiadne kúsky nezodpovedajú.';

  @override
  String get outfitNameLabel => 'Názov outfitu';

  @override
  String get outfitNameHint => 'Napríklad, Ľan na víkend';

  @override
  String get outfitPreviewSemantic => 'AI náhľad outfitu';

  @override
  String get outfitChoosePieces => 'Vybrať kúsky';

  @override
  String get outfitTapPiecesHint => 'Dotkním sa kúskov nižšie ich pridáš.';

  @override
  String get outfitShareTooltip => 'Zdieľať';

  @override
  String get outfitSaveFavourite => 'Uložiť do obľúbených';

  @override
  String get outfitPiecesHeading => 'Kúsky';

  @override
  String get outfitWearHistoryEmpty => 'Nosi to raz a dátumy sa zobrazia tu.';

  @override
  String get outfitWearHistoryTitle => 'História nosenia';

  @override
  String get outfitWearHistoryError => 'Dátumy sa nepodarilo načítať.';

  @override
  String get outfitWornOn => 'Nosené dňa';

  @override
  String get outfitEditTitle => 'Upraviť outfit';

  @override
  String get outfitSavedPhotosFailed => 'Podrobnosti uložené, fotky nie';

  @override
  String get outfitNoPhotosBody =>
      'Zatiaľ bez fotiek. Outfit ukazuje svoje kúsky.';

  @override
  String get outfitOccasionLabel => 'Príležitosť';

  @override
  String get outfitOccasionNone => 'Žiadna';

  @override
  String get outfitTagsHint => 'Oddel záporníkmi';

  @override
  String get outfitDraftBody => 'Skryté z tvojho hlavného zoznamu';

  @override
  String get outfitPublic => 'Verejný';

  @override
  String get outfitPublicBody => 'Každý s odkazom ho vidí';

  @override
  String get outfitDeleteFromDetail => 'Odstrániť tento outfit z detailu.';

  @override
  String get outfitNewCollection => 'Nová kolekcia';

  @override
  String get outfitNoCollectionsTitle => 'Zatiaľ bez kolekcií';

  @override
  String get outfitNoCollectionsBody =>
      'Skupinujte odevy podľa cesty, sezóny alebo nálady.';

  @override
  String get outfitCreateCollection => 'Vytvoriť kolekciu';

  @override
  String get outfitAddOutfits => 'Pridať odevy';

  @override
  String get outfitRename => 'Pomenovať';

  @override
  String get outfitCollectionDeleteBody => 'Odevy v nej sa zachovajú.';

  @override
  String get outfitCollectionsNotLoaded => 'Odevy neboli načítané';

  @override
  String get outfitRenameCollection => 'Pomenovať kolekciu';

  @override
  String get outfitDescriptionOptional => 'Popis (nepovinné)';

  @override
  String get outfitAllInCollection => 'Všetky odevy už sú v tejto kolekcii.';

  @override
  String get photoshootSubtitleUpload =>
      'Ateliérové portréty z vašich fotografií';

  @override
  String get photoshootSubtitleConfigure => 'Vyberte štýl, formát a počet';

  @override
  String get photoshootSubtitleGenerating => 'Trvá to minútu alebo dve';

  @override
  String get photoshootAddPhotosSemantic => 'Pridať fotky z galérie';

  @override
  String get photoshootUploadTitle => 'Pridajte 1 až 4 fotky seba';

  @override
  String get photoshootUploadBody => 'Klepnite a vyberte z galérie';

  @override
  String get photoshootAddToContinue => 'Pridajte fotku pre pokračovanie';

  @override
  String get photoshootAddAnotherPhoto => 'Pridať ďalšiu fotku';

  @override
  String get photoshootTipsTitle => 'Pre najlepšie výsledky';

  @override
  String get photoshootTipsBody =>
      'Používajte jasné, dobre osvetlené fotky tváre z viacerých úhlú. Vynechajte slnečné okuliare a čiapky.';

  @override
  String get photoshootStarting => 'Spúšťanie';

  @override
  String get photoshootCancelling => 'Zrušovanie';

  @override
  String get photoshootFailed => 'Zlyhalo';

  @override
  String get recommendTabMatches => 'Súlad';

  @override
  String get recommendTabComplete => 'Doplnenie';

  @override
  String get recommendTabWeather => 'Povedenie';

  @override
  String get recommendTabColours => 'Farby';

  @override
  String get recommendTabShop => 'Obchod';

  @override
  String get recommendNoMatchesTitle => 'Zatiaľ bez výsledkov';

  @override
  String get recommendNoMatchesBody =>
      'Vyber si kúsok a nájde sa k nemu pasujúce.';

  @override
  String get recommendPickPiece => 'Vybrať kúsok';

  @override
  String get recommendNothingMatchesTitle => 'Zatiaľ sa to nehodí';

  @override
  String get recommendNothingMatchesBody =>
      'Skúšaj iné kúsky alebo dopĺňaj šatník.';

  @override
  String get recommendChangePieces => 'Zmeniť kúsky';

  @override
  String get recommendDefaultReason => 'Pasuje k vybratým kúskom.';

  @override
  String get recommendCompleteTitle => 'Dokončenie outfitu';

  @override
  String get recommendCompleteBody => 'Vyber kúsok a doplníme zvyšok.';

  @override
  String get recommendWorking => 'Spracováva sa';

  @override
  String get recommendGenerate => 'Vytvoriť';

  @override
  String get recommendChooseStyleBody => 'Vyber štýl a vytvor outfit.';

  @override
  String get recommendNoLooksTitle => 'Žiadne outfity k týmto kúskom';

  @override
  String get recommendNoLooksBody => 'Skúšaj iný štýl alebo iné kúsky.';

  @override
  String get recommendDefaultLook => 'Outfit pre tvoje kúsky';

  @override
  String get recommendNoPiecesBody =>
      'Pre tento outfit neboli nájdené žiadne kúsky.';

  @override
  String get recommendCityLabel => 'Mesto';

  @override
  String get recommendCheck => 'Skontrolovať';

  @override
  String get recommendWeatherTitle => 'Aké je počasie?';

  @override
  String get recommendWeatherBody => 'Zadaj svoje mesto pre návrhy na dnešok.';

  @override
  String get recommendWearToday => 'Nosiť dnes';

  @override
  String get recommendWeatherNoPieces => 'Zatiaľ nemáš kúsky do tohto počasia.';

  @override
  String get recommendBudgetLabel => 'rozpočet až do';

  @override
  String get recommendLooking => 'Hľadám';

  @override
  String get recommendFindWhatToBuy => 'Výber čo nakúpiť';

  @override
  String get recommendFillGapsTitle => 'Doplnenie chýb';

  @override
  String get recommendFillGapsBody =>
      'Nastav rozpočet a navrhni, čo v šatníku chýba.';

  @override
  String get recommendNoGapsTitle => 'Chýby neboli nájdené';

  @override
  String get recommendNoGapsBody =>
      'Skúšaj vyšší rozpočet alebo inú kategóriu.';

  @override
  String get recommendMoodEveryday => 'Každodenný';

  @override
  String get recommendMoodBigMeeting => 'Veľké stretnutie';

  @override
  String get recommendDayLabel => 'Deň';

  @override
  String get recommendReadingStars => 'Čítanie hviezd';

  @override
  String get recommendGetMyColours => 'Moje farby';

  @override
  String get recommendLuckyColoursTitle => 'Vaše šťastné farby';

  @override
  String get recommendLuckyColoursBody =>
      'Vyberte deň a my vám navrhneme farby a kúsky.';

  @override
  String get recommendLuckyColoursSection => 'Šťastné farby';

  @override
  String get recommendAvoidColoursSection => 'Farby na pozor';

  @override
  String get recommendBirthDateTitle => 'Pridajte dátum narodenia';

  @override
  String get recommendBirthDateBody =>
      'Na určenie farieb potrebujeme váš dátum narodenia.';

  @override
  String get recommendEditProfile => 'Upraviť profil';

  @override
  String get recommendNothingThisDay => 'Pre tento deň nič.';

  @override
  String get recommendUnnamedColour => 'Nezverejnená farba';

  @override
  String get recommendFromCloset => 'Z vašej špajže';

  @override
  String get recommendNoPiecesInColours =>
      'Zatiaľ tu nie sú žiadne kusy v týchto farbách.';

  @override
  String get recommendOutfitIdeas => 'Nápad na outfit';

  @override
  String get recommendNoOutfitsInColours =>
      'Zatiaľ tu nie je žiadny kompletný outfit v týchto farbách.';

  @override
  String get recommendDefaultOutfitIdea => 'Nápad na outfit';

  @override
  String get recommendPickUpToThree => 'Vyberte až tri kusy';

  @override
  String get recommendEmptyClosetBody =>
      'Najprv pridajte niekoľko kusov, potom sa vráťte po zlúčeniny.';

  @override
  String get dashboardDressForDay => 'Oblečte sa na prípadný deň.';

  @override
  String get dashboardOutfitOfDay => 'Outfit dňa';

  @override
  String get dashboardFreshLook => 'Čerstvý vzhľad';

  @override
  String get subscriptionManageInStoreTitle => 'Spravujte v obchode';

  @override
  String get subscriptionManageInStoreBody =>
      'Tento plán sa účtuje cez obchod. Spravujte ho v nastaveniach svojho účtu.';

  @override
  String get subscriptionCancelledTitle => 'Predplatné zrušené';

  @override
  String get subscriptionCancelledBody =>
      'Váš plán zostane aktívny do konca obdobia fakturácie.';

  @override
  String get subscriptionCancelFailedTitle => 'Zrušenie zlyhalo';

  @override
  String get subscriptionCouldNotOpenTitle => 'Nedá sa otvoriť';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Nedá sa otvoriť správa fakturácie.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Odkaz sa nedá otvoriť.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Odkaz sa nepodarilo načítať';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Odkaz na odporúčanie sa nepodarilo načítať. Skúste to znova.';

  @override
  String get subscriptionReferralCopiedTitle => 'Skopírované';

  @override
  String get subscriptionReferralCopiedBody =>
      'Odkaz na odporúčanie bol skopírovaný.';

  @override
  String get subscriptionReferralShareSubject => 'Skúste FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Pripojte sa k FitCheck AI a získať mesiac Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Odkaz bol skopírovaný';

  @override
  String get subscriptionShareUnavailableBody =>
      'Zdieľanie nie je dostupné, odkaz bol preto skopírovaný.';

  @override
  String get subscriptionShareFailedTitle => 'Zdieľanie zlyhalo';

  @override
  String get subscriptionShareFailedBody =>
      'Odkaz skopírujte zo stránky odporúčania.';

  @override
  String get subscriptionStoreReadyTitle => 'Obchod je pripravený';

  @override
  String get subscriptionStoreReadyBody =>
      'Ceny v obchode sú dostupné. Môžete ho teraz upgradovať.';

  @override
  String get purchaseFailedTitle => 'Kúp zlyhala';

  @override
  String get purchaseUnavailableTitle => 'Kúpa nedostupná';

  @override
  String get purchaseIapUnavailableBody =>
      'Aplikácie s úlohami nie sú na tomto zariadení dostupné.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Toto plán ešte nie je k dispozícii na kúpu.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Tento plán ešte nie je v obchode. Skúste neskôr.';

  @override
  String get purchaseStartFailedBody =>
      'Kúpu sa nepodarilo spustiť. Skúste to znova.';

  @override
  String get purchaseNoPaymentLinkBody => 'Predajca neposkytol platobný odkaz.';

  @override
  String get purchasePendingTitle => 'Kúpa čaká na schválenie';

  @override
  String get purchasePendingBody =>
      'Vaša kúpa čaká na schválenie. Prístup získate, hneď ako bude schválená.';

  @override
  String get purchaseFailedBody => 'Kúp zlyhala. Skúste to znova.';

  @override
  String get purchaseRestoredTitle => 'Obnovené';

  @override
  String get purchaseRestoredBody => 'Vaše nákupy boli obnovené.';

  @override
  String get purchaseActiveTitle => 'Predplatné aktívne';

  @override
  String get purchaseActiveBody => 'Vaše predplatné je aktívne. Vitajte.';

  @override
  String get purchaseSignInRequiredTitle => 'Vyžaduje sa prihlásenie';

  @override
  String get purchaseSignInRequiredBody =>
      'Prihláste sa pre dokončenie nákupu.';

  @override
  String get purchaseErrorTitle => 'Chyba pri nákupe';

  @override
  String get purchaseInvalidTransactionBody =>
      'Kúpa neobsahovala overiteľné ID transakcie.';

  @override
  String get purchaseVerificationPendingTitle => 'Kontrola čaká';

  @override
  String get purchaseVerificationPendingBody =>
      'Kúpu nepodarilo sa v tomto okamihu overiť vo svojsklade. Dokončí sa automaticky a nepočetuje sa dvakrát.';

  @override
  String get purchaseNotAppliedTitle => 'Kúpa sa nepoužila';

  @override
  String get purchaseNotAppliedBody =>
      'Kúpu sa nepodarilo aplikovať na váš účet. Kontaktujte podporu a nekupujte ju znova.';

  @override
  String get purchaseRestoreFailedTitle => 'Obnova zlyhala';

  @override
  String get purchaseRestoreFailedBody =>
      'Kúpy sa nepodarilo obnoviť. Skúste to znova.';

  @override
  String get purchaseRecoveredActiveBody => 'Váše predplatné je aktívne.';

  @override
  String get purchaseCompleteTitle => 'Kúpa dokončená';

  @override
  String get giftCreateFailedTitle => 'Darček sa nepodarilo vytvoriť';

  @override
  String get giftClaimFailedTitle => 'Darček sa nepodarilo uplatniť';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darčeky pre vás',
      one: 'Darček pre vás',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mesiac',
      '12': '1 rok',
      'other': '$months mesiacov',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining zostáva',
      one: '1 zostáva',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender vám poslal/a $duration FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Darček FitCheck Pro pre $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Od $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Pre $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Od $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'v príjemca';

  @override
  String get giftPreviewPlaceholderSender => 'vy';

  @override
  String get settingsSavedTitle => 'Uložené';

  @override
  String get settingsNotSavedTitle => 'Neuložené';

  @override
  String get settingsAiChooseProviderBody => 'Vyberte poskytovateľa.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Vlastný poskytovateľ potrebuje URL rozhrania API.';

  @override
  String get settingsAiKeyRequiredBody => 'Zadajte kľúč API.';

  @override
  String get settingsAiSavedBody => 'Nastavenia AI sú uložené.';

  @override
  String get settingsAiMissingDetailsTitle => 'Chýbajúce údaje';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Zadajte URL rozhrania API a model chatu na testovanie.';

  @override
  String get settingsAiKeyNeededTitle => 'Potrebný kľúč API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Zadajte svoje kľúčové API na testovanie. Uložený kľúč zostane súkromný.';

  @override
  String get settingsAiKeyToTestBody =>
      'Zadajte svoje kľúčové API na testovanie.';

  @override
  String get settingsAiConnectedTitle => 'Pripojené';

  @override
  String get settingsAiConnectedBody => 'Pripojenie funguje.';

  @override
  String get settingsAiTestFailedTitle => 'Test zlyhal';

  @override
  String get settingsPreferencesSavedBody => 'Vaše preferencie boli uložené.';

  @override
  String get settingsPasswordNotChangedTitle => 'Heslo nebolo zmenené';

  @override
  String get settingsOAuthPasswordBody =>
      'Tento účet sa prihlasuje cez Google alebo Apple. Najprv použite \"Zabudnuté heslo\" na nastavenie hesla.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Aktuálne heslo je nesprávne.';

  @override
  String get settingsExportReadyTitle => 'Export pripravený';

  @override
  String get settingsExportReadyBody =>
      'Váš export dát je pripravený na stiahnutie.';

  @override
  String get settingsLinkCopiedTitle => 'Odkaz skopírovaný';

  @override
  String get settingsExportClipboardBody =>
      'Nepodarilo sa nám otvoriť váš prehliadač, preto sme skopírovali odkaz na stiahnutie. Vložte ho do prehliadača čoskoro: expíruje.';

  @override
  String get settingsExportFailedTitle => 'Export zlyhal';

  @override
  String get settingsAccountNotDeletedTitle => 'Účet nebolo zrušený';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Môžete pridať až $max fotiek.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limit fotiek';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Pridajte aspoň jednu fotku.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Žiadne fotky';

  @override
  String get photoshootDescribeLookBody =>
      'Popíšte look, ktorý chcete dosiahnuť.';

  @override
  String get photoshootPromptNeededTitle => 'Vyžaduje sa zadanie';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Príprava fotiek';

  @override
  String get photoshootStatusGenerating => 'Generovanie';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Dáta $current z $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'Hotovo: $done z $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generovanie zlyhalo.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return 'Hotovo: $ready, zlyhalo: $failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Čiastočne dokončené';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotiek je pripravených.',
      many: '$count fotiek je pripravených.',
      few: '$count fotky sú pripravené.',
      one: '1 fotka je pripravená.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Prepojenie sa stratilo. Skúste to znova.';

  @override
  String get photoshootCouldNotCancelTitle => 'Nepodarilo sa zrušiť';

  @override
  String get photoshootRetryFailedTitle => 'Opätovný pokus zlyhal';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Fotka $number je pripravená.';
  }

  @override
  String get photoshootReplacedTitle => 'Nahradené';

  @override
  String get photoshootSavedToGalleryBody => 'Uložené do galérie.';

  @override
  String get photoshootSavedTitle => 'Uložené';

  @override
  String get photoshootNotSavedTitle => 'Neuložené';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Všetky $count fotiek sú vo vašej galérii.',
      few: 'Všetky $count fotky sú vo vašej galérii.',
      one: '1 fotka je vo vašej galérii.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'Uložené $saved z $total.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Niektoré fotky sa nuložili';

  @override
  String get tryonConsentFeatureLabel => 'Virtuálne skúšanie';

  @override
  String get tryonAvatarUpdatedBody => 'Vaša fotka je aktualizovaná.';

  @override
  String get tryonSavedTitle => 'Uložené';

  @override
  String get tryonUploadFailedTitle => 'Nahranie zlyhalo';

  @override
  String get tryonChooseGarmentFirstBody => 'Najprv vyberte fotku oblečenia.';

  @override
  String get tryonNoGarmentTitle => 'Žiadne oblečenie';

  @override
  String get tryonWaitForUploadBody =>
      'Počkajte, kým sa fotka dokončí nahrávanie.';

  @override
  String get tryonStillUploadingTitle => 'Nahráva sa';

  @override
  String get tryonAddYourPhotoFirstBody => 'Najprv pridajte fotku seba.';

  @override
  String get tryonReadyBody => 'Vaše skúšanie je pripravené.';

  @override
  String get tryonFailedTitle => 'Skúšanie zlyhalo';

  @override
  String get tryonSavedToGalleryBody => 'Uložené do galérie.';

  @override
  String get tryonNotSavedTitle => 'Neuložené';

  @override
  String get calendarEventAddedBody => 'Podujatie bolo pridané';

  @override
  String get calendarEventPlannedTitle => 'Naplánované';

  @override
  String get calendarEventSavedBody => 'Podujatie bolo uložené';

  @override
  String get calendarSavedTitle => 'Uložené';

  @override
  String get calendarEventNotSavedTitle => 'Podujatie sa nuložilo';

  @override
  String get calendarEventRemovedBody => 'Podujatie bolo odstranených';

  @override
  String get calendarEventDeletedTitle => 'Odstránené';

  @override
  String get calendarEventNotDeletedTitle => 'Podujatie sa neodstránilo';

  @override
  String get calendarOutfitNotLinkedTitle => 'Oblečenie sa nespojilo';

  @override
  String get calendarLinkedTitle => 'Spojené';

  @override
  String get calendarOutfitNotRemovedTitle => 'Oblečenie sa neodstránilo';

  @override
  String get calendarOutfitRemovedBody => 'Oblečenie odstránené';

  @override
  String get calendarDisconnectedBody => 'Kalendár odpojený';

  @override
  String get calendarDisconnectedTitle => 'Odpojené';

  @override
  String get calendarNotDisconnectedTitle => 'Kalendár sa neodpojil';

  @override
  String get calendarTodayLabel => 'dnes';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count udalostí',
      one: '1 udalosť',
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
    return '$title, $time, spoje s oblečením';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" sa odstráni.';
  }

  @override
  String get calendarThisAppLabel => 'Táto aplikácia';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synchronizácia s $provider zatiaľ nie je k dispozícii. Sem ešte môžete pridávať udalosti.';
  }

  @override
  String get calendarWeekdaySunShort => 'ne';

  @override
  String get calendarWeekdayMonShort => 'po';

  @override
  String get calendarWeekdayTueShort => 'ut';

  @override
  String get calendarWeekdayWedShort => 'st';

  @override
  String get calendarWeekdayThuShort => 'št';

  @override
  String get calendarWeekdayFriShort => 'pi';

  @override
  String get calendarWeekdaySatShort => 'so';

  @override
  String get calendarWeekdayMonday => 'pondelok';

  @override
  String get calendarWeekdayTuesday => 'utorok';

  @override
  String get calendarWeekdayWednesday => 'streda';

  @override
  String get calendarWeekdayThursday => 'štvrtok';

  @override
  String get calendarWeekdayFriday => 'piatok';

  @override
  String get calendarWeekdaySaturday => 'sobota';

  @override
  String get calendarWeekdaySunday => 'Nedeľa';

  @override
  String get outfitSavedToFavouritesBody => 'Uložené do obľúbených';

  @override
  String get outfitRemovedFromFavouritesBody => 'Odstránené z obľúbených';

  @override
  String get outfitNotSavedTitle => 'Nesušilo sa';

  @override
  String get outfitLoggedAsWornBody => 'Zaznamenané ako nosené dnes.';

  @override
  String get outfitNicePickTitle => 'Skvelá voľba';

  @override
  String get outfitRemovedBody => 'Kombinácia odobraná.';

  @override
  String get outfitDeletedTitle => 'Vymazané';

  @override
  String get outfitNotDeletedTitle => 'Nevymazalo sa';

  @override
  String get outfitDuplicatedBody => 'Kópia je vo vašich kombináciách.';

  @override
  String get outfitDuplicatedTitle => 'Zdvojené';

  @override
  String get outfitNotDuplicatedTitle => 'Nezdvojilo sa';

  @override
  String get outfitNotSharedTitle => 'Nesdieľalo sa';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" je pripravené.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Kolekcia sa nevytvorila';

  @override
  String get outfitCollectionUpdatedBody => 'Kolekcia aktualizovaná.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Kolekcia sa neaktualizovala';

  @override
  String get outfitCollectionDeletedBody => 'Kolekcia vymazaná.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Kolekcia sa nevymazala';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kombinácie pridané.',
      one: '1 kombinácia pridaná.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Kombinácie nepridané';

  @override
  String get outfitPreviewNotCreatedTitle => 'Náhľad sa nevytvoril';

  @override
  String get outfitGiveNameBody => 'Priradte kombinácii názov.';

  @override
  String get outfitNameMissingTitle => 'Názov';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Vyberte aspoň jeden kus.';

  @override
  String outfitCreatedBody(String name) {
    return '$name je vo vašich kombináciách.';
  }

  @override
  String get outfitSavedTitle => 'Uložené';

  @override
  String get wardrobeAddedToFavouritesBody => 'Pridané do obľúbených';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Odstránené z obľúbených';

  @override
  String get wardrobeNotSavedTitle => 'Nesušilo sa';

  @override
  String get wardrobeLoggedAsWornBody => 'Zaznamenané ako nosené dnes.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Odstránené z vášho šatníka.';

  @override
  String get wardrobeDeletedTitle => 'Vymazané';

  @override
  String get wardrobeNotDeletedTitle => 'Nevymazané';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kúsky odstránené z vášho šatníka.',
      one: '1 kúsok odstránený z vášho šatníka.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI extrakcia šatníka';

  @override
  String get itemAddScanJobLabel => 'Skenovanie';

  @override
  String get itemAddFoundEarlierBody => 'Nájdené pri skôr skenovaní';

  @override
  String get itemAddLookingAtPhoto => 'Analyzujeme vašu fotku';

  @override
  String get itemAddExtractionFailedBody => 'Extrakcia zlyhala';

  @override
  String get itemAddJobFailedBody => 'Úloha zlyhala';

  @override
  String get itemAddConnectionLostBody =>
      'Konekcia sa stratila. Skúste to znova.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Konekcia sa stratila pri spracovaní.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Kúsok $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Kúsok';

  @override
  String get itemAddNotCancelledTitle => 'Nezrušené';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kúsky sú vo vašom šatníku.',
      one: '1 kúsok je vo vašom šatníku.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'Uložených $saved z $total kúskov. Ťuknutím na uloženie skúste zvyšné znova.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Niektoré kúsky sa neuložili';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Vyberte aspoň jednu fotku.';

  @override
  String get batchPhotoUnreadableBody => 'Tú fotku sa nepodarilo prečítať.';

  @override
  String get batchNoPhotosReadableBody =>
      'Žiadna z týchto fotiek sa dala prečítať. Skúste iné fotky.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotky',
      one: '1 fotka',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Konekcia sa stratila počas práce. Skúste to znova.';

  @override
  String get batchNotCancelledTitle => 'Nezrušené';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Odkazy na prísady sa nepodporujú. Zadajte odkaz na profil.';

  @override
  String get batchLinkSpacesBody => 'Odkazy nemôžu obsahovať medzery.';

  @override
  String get batchEnterProfileLinkBody =>
      'Zadajte odkaz na profil na Instagrame alebo Facebooku.';

  @override
  String get batchEnterProfileLinkShortBody => 'Zadajte odkaz na profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Stránka prihlásenia sa neotvorila. Skúste to znova.';

  @override
  String get batchSignInBrowserBody =>
      'Prihláste sa v prehliadači a vráťte sa do aplikácie FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Prepojenie účtu';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Zadajte kód z aplikácie na autentifikáciu.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram vyžaduje bezpečnostnú kontrolu. Najprv sa prihláste v prehliadači.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Zadajte svoje používateľské meno a heslo znova.';

  @override
  String get batchSignInFailedBody =>
      'Prihlásenie zlyhalo. Skontrolujte používateľské meno a heslo.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Pre pokračovanie importu sa prihláste.';

  @override
  String get batchAccountNotConnectedBody => 'Váš účet sa nepodarilo prepojiť.';

  @override
  String get batchAccountConnectedTitle => 'Účet prepojený';

  @override
  String get batchNotConnectedTitle => 'Neprepojené';

  @override
  String get batchImportConnectionLostBody =>
      'Stratili sme pripojenie k importu. Obnovte stránku pre kontrolu.';

  @override
  String batchPickUpToBody(int max) {
    return 'Vyberte až $max fotiek. My nájdeme kúsky.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count z $total fotiek';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Príprava fotky $done z $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hľadať kúsky na $count fotkách',
      few: 'Hľadať kúsky na $count fotkách',
      one: 'Hľadať kúsky na 1 fotke',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Váš účet $platform používa dvojfázové prihlásenie. Zadajte 6-miestny kód z aplikácie na autentifikáciu.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Tento profil $platform je súkromný alebo vyžaduje prihlásenie pre zobrazenie fotiek.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Pripojiť s $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nájdené $count fotiek',
      few: 'Nájdené $count fotky',
      one: 'Nájdená 1 fotka',
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
    return 'Spracované $processed z $total · Pridané $added · Počkajúce $waiting · Preskočené $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Skúmanie fotky $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Dalej je fotka $number';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Fotka $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nájdené $count kusov',
      few: 'Nájdené $count kúsky',
      one: 'Nájdený 1 kúsok',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotiek bolo pridaných do vašej skrine.',
      few: '$count fotky boli pridané do vašej skrine.',
      one: '1 fotka bola pridaná do vašej skrine.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ďalších studiových fotiek je na ceste. Môžete uložiť to, čo je hotové, alebo odísť – dáme vám vedieť.',
      few:
          '$count ďalšie studiové fotky sú na ceste. Môžete uložiť to, čo je hotové, alebo odísť – dáme vám vedieť.',
      one:
          'Ďalšia studiová fotka je na ceste. Môžete uložiť to, čo je hotové, alebo odísť – dáme vám vedieť.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Zatiaj neuložené: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces kusov',
      few: '$pieces kúsky',
      one: '1 kúsok',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotiek',
      few: '$photos fotiek',
      one: '1 fotky',
    );
    return '$_temp0 z $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen vybrané. Ťuknite na kúsok pre preskočenie.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ukladanie $count kusov',
      few: 'Ukladanie $count kusov',
      one: 'Ukladanie 1 kúska',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uložiť $count diely',
      one: 'Uložiť 1 diel',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Profil tela bol uložený.';

  @override
  String get bodyProfileSavedTitle => 'Uložené';

  @override
  String get bodyProfileNotSavedTitle => 'Neuložené';

  @override
  String get bodyProfileSetDefaultBody => 'Nastaviť ako predvolený profil.';

  @override
  String get bodyProfileDeletedBody => 'Profil tela bol odobraný.';

  @override
  String get bodyProfileDeletedTitle => 'Odstránené';

  @override
  String get bodyProfileNotDeletedTitle => 'Neodstránené';

  @override
  String get feedbackNotSentTitle => 'Nedoručené';

  @override
  String get feedbackSentBody =>
      'Ďakujeme. Prečítame si každé správanie a odpovieme, ak budeme potrebovať viac.';

  @override
  String get feedbackSentTitle => 'Spätná väzba odoslaná';

  @override
  String get recommendUnnamedPiece => 'Nepomenovaný diel';

  @override
  String get recommendEnterCityBody =>
      'Zadajte svoje mesto, aby sme vám odporúčali podľa počasia.';

  @override
  String get recommendWhichCityTitle => 'Ktoré mesto?';

  @override
  String get aiConsentSheetTitle => 'Zdieľanie fotiek s AI službou';

  @override
  String get aiConsentSheetBody =>
      'Aby sme vytvorili vaše obrázky na skúšobné oblečenie a fotenie, FitCheck AI odosíla vaše fotky (vrátane úprav tváre a tela) dôveryhodnému externému AI poskytovateľovi (napr. OpenAI alebo Google Gemini) na spracovanie. Vytvárajú vaše obrázky a podľa našich podmienok ich nepoužívajú na školenie svojich modelov. Fotky sa odosielajú bezpečne a nikdy sa nezdieľajú na reklamné účely.';

  @override
  String get aiConsentSheetPermission =>
      'Pokračovaním dávate výrazné povolenie zdieľať vaše fotky s týmito AI poskytovateľmi na generovanie obrázkov.';

  @override
  String get skeletonsLoadMoreFailed => 'Nepodarilo sa načítať viac.';

  @override
  String get jobsPiecesReadyTitle => 'Vaše diely sú pripravené';

  @override
  String get jobsScanStoppedTitle => 'Skenovanie sa zastavilo';

  @override
  String get jobsNothingSavedBody => 'Nič sa neuložilo. Skúste znova.';

  @override
  String get jobsPhotoUploadFailedBody => 'Nahrávanie fotky zlyhalo.';

  @override
  String get authGoogleSignInStartFailed =>
      'Nepodarilo sa spustiť prihlásenie Google. Skúste to znova.';

  @override
  String get referralAppliedTitle => 'Odporúčanie upravené!';

  @override
  String get billingStoreUnavailableBody =>
      'Kúpy v obchode nie sú na tomto zariadení dostupné.';

  @override
  String get billingPurchaseProcessingBody =>
      'Táto kúpa sa ešte spracúva. Po minúte otvorte appu znova a uvidíte svoj plán.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Nahrávanie avatara nevrátilo URL obrázka.';

  @override
  String get rewardsDayStreakLabel => 'denné sérii';

  @override
  String rewardsBestStreak(int days) {
    return 'Najlepšie $days dni';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Potrebný prístup $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Pristup k $permission je momentálne odmietnutý. Otvorte Nastavenia na povolenie, potom sa vráťte a skúste to znova.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Krok $step zo 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Krok $step z $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Odstrániť obrázok $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Odstrániť obrázok $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points b.';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Napíšte na $email. Hlásenia vyhodnocujeme do 24 hodín.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Odstrániť $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Odstrániť „$name“?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Pridať do „$name“';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '„$name“ bolo odstránené. Jednotlivé položky zostanú vo vašom skrinke.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Zobraziť všetko ($count)';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count zostáva dnes';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index zlyhalo';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected z $max fotiek';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape stavba · $tone pleť';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Odstrániť $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Možnosti pre $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Najviac nosené: $name, $count×';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: neznáme';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% zhoda';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked z $max vybraných';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Odstrániť $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Priorita: $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Tento plán sa účtuje cez $store. Zmeny alebo zrušenie nastaviť v účte $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Spravovať v $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: použitých $current z $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Zostáva približne $seconds s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done z $total štúdiových fotík pripravených';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready z $total štúdiových fotík pripravených. Ťuknutím na položku ju preskočíte.';
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
