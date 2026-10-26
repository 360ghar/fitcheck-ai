// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Kezdőlap';

  @override
  String get tabPhotoshoot => 'Fotózás';

  @override
  String get tabCloset => 'Szekrény';

  @override
  String get tabOutfits => 'Szettek';

  @override
  String get tabMore => 'Továbbiak';

  @override
  String get actionAddItem => 'Elem hozzáadása';

  @override
  String get actionCreateOutfit => 'Szett összeállítása';

  @override
  String get actionCancel => 'Mégse';

  @override
  String get actionDelete => 'Törlés';

  @override
  String get actionSave => 'Mentés';

  @override
  String get actionRetry => 'Újra';

  @override
  String get actionDone => 'Kész';

  @override
  String get actionNext => 'Tovább';

  @override
  String get actionBack => 'Vissza';

  @override
  String get actionClose => 'Bezárás';

  @override
  String get actionSearch => 'Keresés';

  @override
  String get actionContinue => 'Folytatás';

  @override
  String get stateLoading => 'Betöltés';

  @override
  String get stateErrorTitle => 'Valami hiba történt';

  @override
  String get stateErrorBody =>
      'Próbáld újra. Ha a hiba fennáll, lépj kapcsolatba az ügyfélszolgálattal.';

  @override
  String get stateOfflineTitle => 'Nincs internetkapcsolat';

  @override
  String get stateOfflineBody =>
      'Csatlakozz újra a szekrény szinkronizálásához és szettek generálásához.';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String get settingsAccountSection => 'Fiók';

  @override
  String get settingsPreferencesSection => 'Személyre szabás';

  @override
  String get settingsPlanBilling => 'Előfizetés és számlázás';

  @override
  String get settingsLanguage => 'Nyelv';

  @override
  String get settingsNotifications => 'Értesítések';

  @override
  String get settingsUnits => 'Mértékegységek';

  @override
  String get settingsAppearance => 'Megjelenés';

  @override
  String get settingsPrivacySection => 'Adatvédelem és adatok';

  @override
  String get settingsAboutSection => 'Névjegy';

  @override
  String get settingsSignOut => 'Kijelentkezés';

  @override
  String get settingsDeleteAccount => 'Fiók törlése';

  @override
  String get settingsDeleteAccountTitle => 'Törlöd a fiókodat?';

  @override
  String get settingsDeleteAccountBody =>
      'Ez eltávolítja a szekrényedet, szettjeidet, fotóidat és profilodat. Ez a művelet nem vonható vissza.';

  @override
  String get settingsUnitsImperial => 'Angolszász (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrikus (cm, kg)';

  @override
  String get languageTitle => 'Nyelv';

  @override
  String get languageSystem => 'Eszköz nyelvének használata';

  @override
  String get languageSystemBody => 'A FitCheck AI követi a telefonod nyelvét.';

  @override
  String get languageSearchHint => 'Nyelvek keresése';

  @override
  String get languageCurrent => 'Jelenlegi';

  @override
  String get languageReviewNote =>
      'Ez a fordítás új. Szólj, ha valami furcsán hangzik.';

  @override
  String get languageChanged => 'Nyelv frissítve';

  @override
  String get paywallTitle => 'Válassz csomagot';

  @override
  String get paywallTrialBadge => '1 hónap ingyen';

  @override
  String get paywallTrialTitle => 'Az első Pro hónapod ingyenes';

  @override
  String get paywallTrialBody =>
      'Töltsd fel az egész szekrényed egyszerre. Utána add hozzá a darabokat menet közben.';

  @override
  String get paywallFreeForeverTitle => 'Örökké ingyenes';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Kártya nem szükséges. Minden hónapban $uploads AI-feltöltést, $outfits szettet és naponta $images fotózás képet kapsz.';
  }

  @override
  String get paywallCtaTrial => 'Ingyenes hónap indítása';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Frissítés erre: $plan';
  }

  @override
  String get paywallRestore => 'Vásárlások visszaállítása';

  @override
  String get paywallManage => 'Előfizetés kezelése';

  @override
  String get paywallTerms => 'Felhasználási feltételek';

  @override
  String get paywallPrivacy => 'Adatvédelmi irányelvek';

  @override
  String get paywallPerMonth => 'hónaponta';

  @override
  String get paywallPerYear => 'évente';

  @override
  String get paywallBestValue => 'Legjobb ár';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Ingyenes próbaidőszak csak új előfizetőknek. A próba után a Pro megújul ennyiért: $price, hacsak nem mondják le legalább 24 órával a vége előtt.';
  }

  @override
  String get introTitle => 'A ruhatárad, végre rendezve';

  @override
  String get introBody =>
      'Fotózd le a ruháidat egyszer. Szerezz szettötleteket, próbafotókat és stúdióképeket a meglévő darabjaidból.';

  @override
  String get introStart => 'Kezdés';

  @override
  String get introHaveAccount => 'Már van fiókom';

  @override
  String get introSkip => 'Kihagyás';

  @override
  String get authSignIn => 'Bejelentkezés';

  @override
  String get authSignUp => 'Fiók létrehozása';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Jelszó';

  @override
  String get authForgotPassword => 'Elfelejtett jelszó?';

  @override
  String get authContinueApple => 'Folytatás az Apple-lel';

  @override
  String get authContinueGoogle => 'Folytatás a Google-lel';

  @override
  String get authOrDivider => 'vagy';

  @override
  String get wardrobeTitle => 'Garderob';

  @override
  String get wardrobeEmptyTitle => 'A gardróbod üres';

  @override
  String get wardrobeEmptyBody =>
      'Add hozzá az első darabot, vagy tölts fel egy fotót az egész ruhaállványról egyszerre.';

  @override
  String get wardrobeAddFirst => 'Első darab hozzáadása';

  @override
  String get wardrobeSearchHint => 'Keresés a ruhatárban';

  @override
  String get categoryTops => 'Felsők';

  @override
  String get categoryBottoms => 'Alsók';

  @override
  String get categoryShoes => 'Cipők';

  @override
  String get categoryAccessories => 'Kiegészítők';

  @override
  String get categoryOuterwear => 'Kabárok';

  @override
  String get categorySwimwear => 'Fürdőruhák';

  @override
  String get categoryActivewear => 'Sportruházat';

  @override
  String get categoryOther => 'Egyéb';

  @override
  String get conditionClean => 'Tiszta';

  @override
  String get conditionDirty => 'Piszkos';

  @override
  String get conditionLaundry => 'Mosásban';

  @override
  String get conditionRepair => 'Javításra szorul';

  @override
  String get conditionDonate => 'Adományozásra';

  @override
  String get seasonSpring => 'Tavasz';

  @override
  String get seasonSummer => 'Nyár';

  @override
  String get seasonFall => 'Ősz';

  @override
  String get seasonWinter => 'Tél';

  @override
  String get seasonAll => 'Minden évszak';

  @override
  String get styleCasual => 'Alkalmi';

  @override
  String get styleFormal => 'Elegáns';

  @override
  String get styleBusiness => 'Üzleti';

  @override
  String get styleSporty => 'Sportos';

  @override
  String get styleBohemian => 'Bohém';

  @override
  String get styleStreetwear => 'Utcai';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romantikus';

  @override
  String get styleEdgy => 'Lázadó';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Művészi';

  @override
  String get styleClassic => 'Klasszikus';

  @override
  String get styleElegant => 'Elegáns';

  @override
  String get styleOther => 'Egyéb';

  @override
  String get occasionWork => 'Munka';

  @override
  String get occasionDateNight => 'Randevú';

  @override
  String get occasionTravel => 'Utazás';

  @override
  String get occasionWedding => 'Esküvő';

  @override
  String get occasionGym => 'Edzés';

  @override
  String get occasionWeekend => 'Hétvége';

  @override
  String get occasionParty => 'Buli';

  @override
  String get occasionInterview => 'Interjú';

  @override
  String get colorBlack => 'Fekete';

  @override
  String get colorWhite => 'Fehér';

  @override
  String get colorGrey => 'Szürke';

  @override
  String get colorNavy => 'Sötétkék';

  @override
  String get colorBrown => 'Barna';

  @override
  String get colorRed => 'Piros';

  @override
  String get colorBlue => 'Kék';

  @override
  String get colorGreen => 'Zöld';

  @override
  String get colorPink => 'Rózsaszín';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorYellow => 'Sárga';

  @override
  String get colorOrange => 'Narancssárga';

  @override
  String get colorBeige => 'Bézs';

  @override
  String get dateToday => 'Ma';

  @override
  String get dateYesterday => 'Tegnap';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count napja',
      one: '1 napja',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hete',
      one: '1 hete',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hónapja',
      one: '1 hónapja',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éve',
      one: '1 éve',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Kedveled a FitCheck AI appot?';

  @override
  String get ratingPromptBody =>
      'Egy gyors értékelés segít másoknak is megtalálni a stílusukat.';

  @override
  String get ratingPromptYes => 'Értékelés';

  @override
  String get ratingPromptNo => 'Most nem';

  @override
  String get closetNoMatchesTitle => 'Nincs találat';

  @override
  String get closetNoMatchesBody =>
      'Próbálj kevesebb szűrőt vagy más keresést.';

  @override
  String get closetClearFilters => 'Szűrők törlése';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darab',
      one: '1 darab',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Darabok betöltése';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kiválasztva',
      one: '1 kiválasztva',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Kiválasztottak törlése';

  @override
  String get closetCancelSelection => 'Kiválasztás törlése';

  @override
  String get closetCloseSearch => 'Keresés bezárása';

  @override
  String get closetShowGrid => 'Rács nézet';

  @override
  String get closetShowList => 'Lista nézet';

  @override
  String get closetShowRows => 'Sorok nézet';

  @override
  String get closetStatsTitle => 'Ruhatár statisztika';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Törölsz $count darabot?',
      one: 'Törölsz 1 darabot?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Az ezeket használó szettek hiányossá válnak.';

  @override
  String get closetSortBy => 'Rendezés';

  @override
  String get closetFavourites => 'Kedvencek';

  @override
  String get closetFavourite => 'Kedvenc';

  @override
  String get closetUnfavourite => 'Eltávolítás a kedvencekből';

  @override
  String get closetWoreToday => 'Ma viseltem';

  @override
  String closetWornTimes(int count) {
    return 'Viselve $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategória';

  @override
  String get closetUseCaseLabel => 'Alkalom';

  @override
  String get closetAnyUseCase => 'Bármilyen';

  @override
  String get closetOtherUseCase => 'Más alkalom';

  @override
  String get closetOtherUseCaseHint => 'Például brunch';

  @override
  String get closetUseUseCase => 'Használat';

  @override
  String get closetClearAll => 'Összes törlése';

  @override
  String get sortNewest => 'Legújabb elöl';

  @override
  String get sortOldest => 'Legrégebbi elöl';

  @override
  String get sortName => 'Név (A–Z)';

  @override
  String get sortMostWorn => 'Legtöbbet viselt';

  @override
  String get useCaseInformal => 'Hétköznapi';

  @override
  String get useCaseDate => 'Randi';

  @override
  String get useCaseDinner => 'Vacsora';

  @override
  String get useCaseLunch => 'Ebéd';

  @override
  String get actionSelect => 'Kiválaszt';

  @override
  String get actionEdit => 'Szerkesztés';

  @override
  String get actionFilter => 'Szűrő';

  @override
  String get actionSort => 'Rendezés';

  @override
  String get actionAll => 'Összes';

  @override
  String get dashboardStartClosetTitle => 'Gardrób építése';

  @override
  String get dashboardStartClosetBody =>
      'Fotózz le néhány darabat. Mi felcímkézzük neked.';

  @override
  String get dashboardPieces => 'darab';

  @override
  String get dashboardOutfits => 'szett';

  @override
  String get dashboardDayStreak => 'napos sorozat';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count ebben a hónapban';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Legjobb $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kedvenc',
      one: '1 kedvenc',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mentett szett',
      one: '1 mentett szett',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Legtöbbet viselt: $name, $count alkalommal';
  }

  @override
  String get setupSkip => 'Beállítás kihagyása';

  @override
  String get setupWhoTitle => 'Kit öltöztessünk?';

  @override
  String get setupWhoBody =>
      'Beállítja a modellt a próbához és fotózáshoz. Később a profilodban módosíthatod.';

  @override
  String get setupStyleTitle => 'Mit hordasz a leggyakrabban?';

  @override
  String get setupStyleBody =>
      'Válassz ki néhányat. Az öltözékötletek ezekből indulnak ki.';

  @override
  String get setupClosetTitle => 'Add hozzá az első darabokat.';

  @override
  String get setupClosetBody =>
      'Fotózz le néhány ruhát vagy egy halmot. Minden darabot kivágunk és rendszerezünk neked.';

  @override
  String get setupAddClothes => 'Ruhák hozzáadása';

  @override
  String get setupStylesLabel => 'Stílusok';

  @override
  String get setupOccasionsLabel => 'Alalmak';

  @override
  String get setupSkipStep => 'Kihagyás';

  @override
  String get setupLater => 'Később';

  @override
  String get setupSaveError => 'Nem sikerült menteni';

  @override
  String get genderWomen => 'Női';

  @override
  String get genderMen => 'Férfi';

  @override
  String get genderNonBinary => 'Nonbináris';

  @override
  String get genderPreferNotToSay => 'Inkább nem válaszolok';

  @override
  String get outfitEmptyTitle => 'Még nincsenek szettek';

  @override
  String get outfitEmptyBody =>
      'Párosíts darabokat a gardróbodbol, és mentsd el a külsőt.';

  @override
  String get outfitNoMatchesTitle => 'Nincs egyező szett';

  @override
  String get outfitSearchHint => 'Szettek keresése';

  @override
  String get outfitLoading => 'Szettek betöltése';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count szett',
      one: '1 szett',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Stílus és évszak';

  @override
  String get outfitCollections => 'Kollekciók';

  @override
  String get outfitDuplicate => 'Másolat';

  @override
  String get outfitDeleteTitle => 'Törlöd ezt a szettet?';

  @override
  String get outfitDeleteBody => 'A darabjai megmaradnak a gardróbodban.';

  @override
  String get outfitDrafts => 'Vázlatok';

  @override
  String get outfitDraft => 'Vázlat';

  @override
  String get filterStyle => 'Stílus';

  @override
  String get filterSeason => 'Évszak';

  @override
  String get itemDetailDeleteTitle => 'Törlöd ezt a darabot?';

  @override
  String get itemDetailDeleteBody =>
      'Az ezt használó szettekből hiányozni fog.';

  @override
  String get itemAddFavourite => 'Hozzáadás a kedvencekhez';

  @override
  String itemSize(String size) {
    return 'Méret: $size';
  }

  @override
  String get itemColours => 'Színek';

  @override
  String get itemMaterial => 'Anyag';

  @override
  String get itemPattern => 'Minta';

  @override
  String get itemUseCases => 'Alkalmak';

  @override
  String get itemKeptIn => 'Tárolóhely';

  @override
  String get itemPrice => 'Ár';

  @override
  String get itemBought => 'Vásárolva';

  @override
  String get itemTags => 'Címkék';

  @override
  String get itemAdded => 'Hozzáadva';

  @override
  String get itemTimesWornLabel => 'alkalommal viselve';

  @override
  String get itemLastWornLabel => 'utoljára viselve';

  @override
  String get itemNeverWorn => 'Soha';

  @override
  String get authEntryBody =>
      'Minden ruhád, mesterséges intelligenciával stilizálva. Tervezz szetteket, próbáld fel őket.';

  @override
  String get authCreateCloset => 'Garderob létrehozása';

  @override
  String get authWelcomeBack => 'Üdv újra';

  @override
  String get authSignInBody => 'Jelentkezz be a gardróbod megnyitásához.';

  @override
  String get authCreateAccount => 'Fiók létrehozása';

  @override
  String get authCreateClosetBody =>
      'Csak egy perc. Az első darabok ingyenesek.';

  @override
  String get authName => 'Név';

  @override
  String get authConfirmPassword => 'Jelszó megerősítése';

  @override
  String get authReferralCode => 'Ajánlókód (opcionális)';

  @override
  String get authResetTitle => 'Jelszó visszaállítása';

  @override
  String get authResetBody =>
      'Küldünk egy linket e-mailben az új jelszó megadásához.';

  @override
  String get authSendResetLink => 'Visszaállító link küldése';

  @override
  String get authBackToSignIn => 'Vissza a bejelentkezéshez';

  @override
  String get authEnterEmail => 'Add meg az e-mail címed';

  @override
  String get authEnterValidEmail => 'Adj meg egy érvényes e-mail címet';

  @override
  String get authEnterPassword => 'Add meg a jelszavad';

  @override
  String get authPasswordTooShort => 'Legalább 6 karakter';

  @override
  String get authShowPassword => 'Jelszó mutatása';

  @override
  String get authHidePassword => 'Jelszó elrejtése';

  @override
  String get authNewHere => 'Új vagy itt?';

  @override
  String authConfirmEmail(String email) {
    return 'Bejelentkezés előtt erősítsd meg a következőt: $email. Ellenőrizd a beérkezett üzeneteket.';
  }

  @override
  String get authResendEmail => 'Újraküldés';

  @override
  String get authResendingEmail => 'Küldés...';

  @override
  String get authPasswordsDoNotMatch => 'A jelszavak nem egyeznek';

  @override
  String get authEnterName => 'Add meg a neved';

  @override
  String get authChoosePassword => 'Válassz jelszót';

  @override
  String get authHaveAccount => 'Van már fiókod?';

  @override
  String get authCodeAccepted => 'Kód elfogadva';

  @override
  String get authCodeNotFound => 'A kód nem található';

  @override
  String authReferralFrom(String name) {
    return 'Tőle: $name. Mindketten kapsztok egy ingyen hónapot.';
  }

  @override
  String get authReferralInvalid => 'Nem találtuk ezt a kódot.';

  @override
  String authResetSent(String email) {
    return 'Elküldve ide: $email. Nyisd meg a linket ezen a telefonon.';
  }

  @override
  String get introSlide1Title => 'Fotózd le a gardróbod egyszer.';

  @override
  String get introSlide1Body =>
      'Fotózz le egy halom ruhát. Minden darabot kivágunk és rendszerezünk neked.';

  @override
  String get introSlide2Title => 'Öltözz fel gyorsabban.';

  @override
  String get introSlide2Body =>
      'Szettek a meglévő ruháidból, a terveidhez és az időjáráshoz igazítva.';

  @override
  String get introSlide3Title => 'Lásd mielőtt felveszed.';

  @override
  String get introSlide3Body =>
      'Próbáld fel a lookokat a saját fotódon, vagy készíts kampányfotókat.';

  @override
  String get settingsTheme => 'Téma';

  @override
  String get settingsThemeSystem => 'Rendszer';

  @override
  String get settingsThemeLight => 'Világos';

  @override
  String get settingsThemeDark => 'Sötét';

  @override
  String get settingsTemperature => 'Hőmérséklet';

  @override
  String get settingsEmailUpdates => 'E-mail értesítések';

  @override
  String get settingsEmailUpdatesBody => 'Hírek és tippek e-mailben';

  @override
  String get settingsOutfitReminders => 'Szett emlékeztetők';

  @override
  String get settingsOutfitRemindersBody =>
      'Egy kis lökés a viselt ruhák rögzítéséhez';

  @override
  String get settingsWeeklySummary => 'Heti összegzés';

  @override
  String get settingsWeeklySummaryBody => 'A te heted szettekben';

  @override
  String get settingsStyleSection => 'Stílus';

  @override
  String get settingsPreferredStyles => 'Kedvelt stílusok';

  @override
  String get settingsPreferredColours => 'Kedvelt színek';

  @override
  String get settingsNoneChosen => 'Nincs kiválasztva';

  @override
  String get settingsPlanAiSection => 'Csomag és AI';

  @override
  String get settingsPlanBillingBody => 'Csomag, használat és bővítések';

  @override
  String get settingsPlanUsageBody => 'Csomag és használat';

  @override
  String get settingsInviteFriends => 'Barátok meghívása';

  @override
  String get settingsInviteFriendsBody =>
      'Egy ingyen hónap minden csatlakozó barát után';

  @override
  String get settingsAiProvider => 'AI szolgáltató';

  @override
  String get settingsAiProviderBody =>
      'Használd saját modelledet a címkézéshez és a képekhez';

  @override
  String get settingsAppVersion => 'Alkalmazás verziója';

  @override
  String get settingsPrivacyTerms => 'Adatvédelem és feltételek';

  @override
  String get settingsReportProblem => 'Probléma jelentése';

  @override
  String get settingsChangePassword => 'Jelszó módosítása';

  @override
  String get settingsExportData => 'Adatok exportálása';

  @override
  String get settingsExportBody =>
      'Készítünk egy fájlt az összes mentett adatodról és elindítjuk a letöltést.';

  @override
  String get settingsExportAction => 'Exportálás';

  @override
  String get settingsCurrentPassword => 'Jelenlegi jelszó';

  @override
  String get settingsNewPassword => 'Új jelszó';

  @override
  String get settingsConfirmNewPassword => 'Új jelszó megerősítése';

  @override
  String get settingsEnterCurrentPassword => 'Add meg a jelenlegi jelszavad';

  @override
  String get settingsEnterNewPassword => 'Add meg az új jelszót';

  @override
  String get settingsPasswordMin8 => 'Legalább 8 karakter szükséges';

  @override
  String get settingsPasswordNeedsUpper => 'Legyen benne nagybetű';

  @override
  String get settingsPasswordNeedsLower => 'Legyen benne kisbetű';

  @override
  String get settingsPasswordNeedsDigit => 'Legyen benne szám';

  @override
  String get settingsPasswordsNoMatch => 'A jelszavak nem egyeznek';

  @override
  String get settingsChangeAction => 'Módosítás';

  @override
  String get itemAddSnapTitle => 'Fotózz le egy darabot';

  @override
  String get itemAddSnapBody =>
      'Keresünk minden darabot a fotón és mindegyikről tiszta stúdióképet készítünk.';

  @override
  String get itemAddCamera => 'Fotó készítése';

  @override
  String get itemAddGallery => 'Választás a galériából';

  @override
  String get itemAddOtherWays => 'Más hozzáadási módok';

  @override
  String get itemAddSeveral => 'Több fotó hozzáadása';

  @override
  String get itemAddSeveralBody => 'Legfeljebb 50 egyszerre';

  @override
  String get itemAddImportProfile => 'Importálás profilból';

  @override
  String get itemAddImportProfileBody => 'Instagram vagy Facebook';

  @override
  String get itemAddEnterDetails => 'Részletek megadása manuálisan';

  @override
  String get itemAddEnterDetailsBody => 'Nem szükséges fotó';

  @override
  String get itemManualIntro =>
      'Csak egy név szükséges. Add meg a többit most vagy később.';

  @override
  String get itemManualNameHint => 'Például kék pamut póló';

  @override
  String get itemManualEnterName => 'Adj meg egy nevet';

  @override
  String get itemManualNotes => 'Jegyzetek';

  @override
  String get itemManualBrand => 'Márka';

  @override
  String get itemManualSize => 'Méret';

  @override
  String get itemManualEnterNumber => 'Adj meg egy számot';

  @override
  String get itemManualSavePiece => 'Darab mentése';

  @override
  String get itemManualSaving => 'Mentés';

  @override
  String get itemManualSavedTitle => 'Mentve';

  @override
  String itemManualSavedBody(String name) {
    return '$name a szekrényedben van.';
  }

  @override
  String get itemManualNotSaved => 'Nincs mentve';

  @override
  String get itemManualAddUseCase => 'Használati eset hozzáadása';

  @override
  String get itemManualAddUseCaseAction => 'Használati eset hozzáadása';

  @override
  String get itemPhotos => 'Fotók';

  @override
  String get itemAddPhotos => 'Fotók hozzáadása';

  @override
  String get itemNoPhotoYet => 'Még nincs fotó. Fotó nélkül is mentheted.';

  @override
  String get itemRemovePhoto => 'Fotó eltávolítása';

  @override
  String get itemRemovePiece => 'Darab eltávolítása';

  @override
  String get filterConditionLabel => 'Állapot';

  @override
  String get photoshootStepPhotos => 'Fotók';

  @override
  String get photoshootStepSetup => 'Beállítás';

  @override
  String get photoshootStepCreating => 'Létrehozás';

  @override
  String get photoshootStepResults => 'Eredmények';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return '$current. lépés ($total ből), $name';
  }

  @override
  String get photoshootOneFailed =>
      'Egy fotó feldolgozása sikertelen. Próbáld újra alább.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotó nem sikerült. Próbáld újra egyenként alább.';
  }

  @override
  String get photoshootFormat => 'Formátum';

  @override
  String get photoshootHowMany => 'Mennyi';

  @override
  String get photoshootYourPrompt => 'Leírás';

  @override
  String get photoshootPromptHint => 'Aranyóra a tetőn, lenin ing';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotó készítése',
      one: '1 fotó készítése',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotó',
      one: 'fotó',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Nem sikerült ellenőrizni a mai limitet.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan csomag: $remaining/$limit maradt mára';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Ingyenes';

  @override
  String get photoshootGallery => 'Galéria';

  @override
  String get photoshootUseCamera => 'Kamera használata';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '$number. fotó törlése';
  }

  @override
  String get photoshootNoPhotosTitle => 'Nem érkeztek fotók';

  @override
  String get photoshootNoPhotosBody =>
      'A fotózás kép nélkül fejeződött be. Próbáld újra.';

  @override
  String get photoshootNewStyle => 'Új stílus';

  @override
  String get photoshootNewPhotos => 'Új fotók';

  @override
  String photoshootOpenPhoto(int number) {
    return '$number. fotó megnyitása';
  }

  @override
  String get photoshootReportPhoto => 'Fotó jelentése';

  @override
  String get photoshootSaveToGallery => 'Mentés a galériába';

  @override
  String get actionUpgrade => 'Frissítés';

  @override
  String get referralLimitTitle => 'Elhasználtad a mai fotókat';

  @override
  String get referralLimitBody =>
      'Az ingyenes fotóid holnap megújulnak. Hívj meg egy barátot, és mindketten kaptok egy hónap Pro csomagot ingyen.';

  @override
  String get referralLimitRefer => 'Barát meghívása';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Társkereső';

  @override
  String get photoshootUsePortfolio => 'Portfólió';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Esztétikus';

  @override
  String get photoshootUseCustom => 'Saját leírás';

  @override
  String get photoshootDescLinkedin => 'Professzionális portrék munkához';

  @override
  String get photoshootDescDating => 'Laza, barátságos és természetes';

  @override
  String get photoshootDescPortfolio => 'Divatmagazinba illő megjelenés';

  @override
  String get photoshootDescInstagram => 'Életmód fotók a hírfolyamodba';

  @override
  String get photoshootDescAesthetic => 'Hangulatos, művészi keretek';

  @override
  String get photoshootDescCustom => 'Írd le a kívánt megjelenést';

  @override
  String get aspectSquare => 'Négyzet';

  @override
  String get aspectPortrait => 'Álló';

  @override
  String get aspectLandscape => 'Fekvő';

  @override
  String get aspectTall => 'Magas';

  @override
  String get aspectWide => 'Széles';

  @override
  String get tryOnAppBar => 'Virtuális felpróbálás';

  @override
  String get tryOnYourPhoto => 'Saját fotó';

  @override
  String get tryOnGarment => 'Ruhadarab';

  @override
  String get tryOnUploadingPhoto => 'Fotó feltöltése';

  @override
  String get tryOnAddPhotoPrompt => 'Adj hozzá egy egész alakos fotót magadról';

  @override
  String get tryOnBodyPhotoHint => 'Egy egész alakos fotó működik a legjobban';

  @override
  String get tryOnAddPhoto => 'Fotó hozzáadása';

  @override
  String get tryOnChangePhoto => 'Fotó cseréje';

  @override
  String get tryOnPhotoLoadFailed => 'Nem sikerült betölteni a fotót.';

  @override
  String get tryOnChooseGarment => 'Válassz egy ruhadarabot';

  @override
  String get tryOnChooseOneGarment => 'Válassz egy ruhadarab fotót';

  @override
  String get tryOnGarmentHint =>
      'A simára fektetett vagy vállfás fotó a legjobb';

  @override
  String get tryOnChange => 'Módosítás';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Eltávolítás';

  @override
  String get tryOnLookTitle => 'Összeállítás';

  @override
  String get tryOnStyle => 'Stílus';

  @override
  String get tryOnBackground => 'Háttér';

  @override
  String get tryOnPose => 'Póz';

  @override
  String get tryOnDressingUp =>
      'Felöltöztetünk. Ez körülbelül fél percet vesz igénybe.';

  @override
  String get tryOnEmptyResult => 'Itt jelenik meg a felpróbálás';

  @override
  String get tryOnReportImage => 'Kép jelentése';

  @override
  String get tryOnCreating => 'Létrehozás';

  @override
  String get tryOnTryAgain => 'Próbáld újra';

  @override
  String get tryOnCreate => 'Felpróbálás készítése';

  @override
  String get tryOnBackgroundStudioWhite => 'Stúdiófehér';

  @override
  String get tryOnBackgroundStudioGrey => 'Stúdiószürke';

  @override
  String get tryOnBackgroundUrban => 'Városi utca';

  @override
  String get tryOnBackgroundNature => 'Természet';

  @override
  String get tryOnBackgroundMinimal => 'Minimál';

  @override
  String get tryOnPoseFront => 'Elölnézet';

  @override
  String get tryOnPoseSide => 'Oldalnézet';

  @override
  String get tryOnPoseWalking => 'Járás';

  @override
  String get dashboardGreetingMorning => 'Jó reggelt';

  @override
  String get dashboardGreetingAfternoon => 'Jó napot';

  @override
  String get dashboardGreetingEvening => 'Jó estét';

  @override
  String get dashboardWelcome => 'Üdvözlünk';

  @override
  String get dashboardOpenProfile => 'Profil megnyitása';

  @override
  String get dashboardRailToday => 'Ma';

  @override
  String get dashboardRailRecently => 'Legutóbbi';

  @override
  String get dashboardActivityEmpty =>
      'Az új ruhák és szettek itt jelennek meg.';

  @override
  String get quickAddPiece => 'Darab hozzáadása';

  @override
  String get quickAddPieceBody => 'Fotózd le és címkézd';

  @override
  String get quickBuildOutfit => 'Szett összeállítása';

  @override
  String get quickBuildOutfitBody => 'Kombináld ruháid';

  @override
  String get quickForYou => 'Neked';

  @override
  String get quickForYouBody => 'Mai ajánlatok';

  @override
  String get quickPlanWeek => 'Hét tervezése';

  @override
  String get quickPlanWeekBody => 'Szettek dátum szerint';

  @override
  String get referralBannerUrgent => 'Kifogyóban? Hívj meg egy barátot.';

  @override
  String get referralBannerTitle => 'Adj egy hónapot, kapj egy hónapot.';

  @override
  String get referralBannerBody =>
      'Te és a barátod is egy-egy hónap Pro-t kaptok.';

  @override
  String get referralBannerDismiss => 'Emlékeztető egy hét múlva';

  @override
  String get referralBannerShare => 'Meghívó megosztása';

  @override
  String get referralBannerCopy => 'Link másolása';

  @override
  String get itemEditPieceTitle => 'Darab szerkesztése';

  @override
  String get itemEditDescriptionLabel => 'Leírás';

  @override
  String get itemEditNotSaved => 'Nincs mentve';

  @override
  String get itemEditSavedTitle => 'Mentve';

  @override
  String get itemEditSavedBody => 'A változtatások elmentve.';

  @override
  String get itemEditSavedStalePhotos => 'Mentve – a fotók elavultak lehetnek';

  @override
  String get itemEditRemovePieceHint => 'Töröld ezt a darabot az adatlapjáról.';

  @override
  String get itemEditNoPhotos =>
      'Még nincsenek fotók. Adj hozzá a galériából vagy a kamerával.';

  @override
  String get itemEditKeepPhoto => 'Fotó megtartása';

  @override
  String get itemEditRemoved => 'Eltávolítva';

  @override
  String get itemEditAddUseCaseAction => 'Hozzáadás';

  @override
  String get statsNoStatsTitle => 'Még nincsenek statisztikák';

  @override
  String get statsNoStatsBody =>
      'Adj hozzá néhány darabot, és a ruhatárad összetétele itt látszik.';

  @override
  String get statsByCategory => 'Kategória szerint';

  @override
  String get statsTotalValue => 'összérték';

  @override
  String get statsMostWorn => 'Legtöbbször viselt';

  @override
  String get statsLeastWorn => 'Sorjára vár';

  @override
  String get statsUnnamedPiece => 'Névtelen darab';

  @override
  String get jobsTitle => 'Feldolgozások';

  @override
  String get jobsEmptyTitle => 'Még nincsenek feldolgozások';

  @override
  String get jobsEmptyBody =>
      'Fotózz le egy darabot és küldd a háttérbe – itt folytatódik a munka.';

  @override
  String get jobsNotCancelled => 'Nincs megszakítva';

  @override
  String get jobsResume => 'Folytatás';

  @override
  String get jobsReview => 'Átnézés';

  @override
  String get jobsStop => 'Leállítás';

  @override
  String get jobsDismiss => 'Bezárás';

  @override
  String get reportTitle => 'Tartalom jelentése';

  @override
  String reportIntro(String contentType) {
    return 'Mondd el, mi a probléma ezzel a $contentType tartalommal. Csapatunk minden jelentést átnéz.';
  }

  @override
  String get reportReasonInappropriate => 'Nem megfelelő vagy sértő';

  @override
  String get reportReasonNudity => 'Meztelenség vagy szexuális tartalom';

  @override
  String get reportReasonHarassment => 'Zaklatás vagy bántalmazás';

  @override
  String get reportReasonImpersonation => 'Másnak való kiadás';

  @override
  String get reportReasonOther => 'Egyéb';

  @override
  String get reportDetailsLabel => 'További részletek (opcionális)';

  @override
  String get reportSubmit => 'Jelentés küldése';

  @override
  String get reportSubmittedTitle => 'Jelentés elküldve';

  @override
  String get reportSubmittedBody =>
      'Köszönjük. Csapatunk át fogja tekinteni a tartalmat.';

  @override
  String get reportFailedTitle => 'A jelentés nem küldhető el';

  @override
  String get reportFailedBody => 'Kérjük, próbáld újra.';

  @override
  String get reportContentTryOnImage => 'AI próbafotó';

  @override
  String get reportContentSharedOutfit => 'megosztott szett';

  @override
  String get reportContentPhotoshootImage => 'AI fotózás kép';

  @override
  String get sharedOutfitTitle => 'Megosztott szett';

  @override
  String get sharedOutfitHideTooltip => 'Szett elrejtése';

  @override
  String get sharedOutfitReportTooltip => 'Szett jelentése';

  @override
  String get sharedOutfitHideTitle => 'Elrejted ezt a szettet?';

  @override
  String get sharedOutfitHideBody =>
      'Ezen az eszközön elrejtve marad. Jelentheted is, hogy csapatunk felülvizsgálja és eltávolítsa.';

  @override
  String get sharedOutfitHideAction => 'Elrejtés';

  @override
  String get sharedOutfitHiddenInfo =>
      'Ez a szett többé nem jelenik meg ezen az eszközön.';

  @override
  String get sharedOutfitHiddenToast => 'Szett elrejtve';

  @override
  String get sharedOutfitMissingTitle => 'Ez a szett már nem elérhető';

  @override
  String get sharedOutfitMissingBody =>
      'Lehet, hogy törölték, vagy a link hibás.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Elrejtetted ezt a szettet';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Ha kifogásolható, jelentsd az Adatvédelem és feltételek menüben vagy írj ide: $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Tetszik ez a stílus?';

  @override
  String get sharedOutfitCtaBody =>
      'Állíts össze hasonló szetteket a saját ruhatáradból.';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'Hiba';

  @override
  String get errorUnknown => 'Vratlan hiba tortent';

  @override
  String get errorNoConnection =>
      'Nincs internetkapcsolat. Ellenorizze a halozatot.';

  @override
  String get errorTimeout => 'A keres ideje lejart. Probalja ujra.';

  @override
  String get errorServerError => 'Valami hiba tortent nallunk. Probalja ujra.';

  @override
  String get errorBadGateway =>
      'A szerverunk most nem elerheto. Probalja ujra.';

  @override
  String get errorServiceUnavailable =>
      'A szolgaltatas ideiglenesen nem elerheto. Probalja ujra.';

  @override
  String get errorInternalError => 'Valami hiba tortent. Probalja ujra.';

  @override
  String get errorUnauthorized => 'A folytatashoz jelentkezz be.';

  @override
  String get errorForbidden => 'Ehhez nincs hozzaferesed.';

  @override
  String get errorSessionExpired => 'A munkamenet lejart. Jelentkezz be ujra.';

  @override
  String get errorInvalidCredentials =>
      'Az e-mail-cim vagy a jelszo nem megfelelo.';

  @override
  String get errorTokenRefreshFailed =>
      'Nem sikerult frissiteni a munkamenetet. Jelentkezz be ujra.';

  @override
  String get errorRequestCancelled => 'Keres torolve.';

  @override
  String get errorInvalidFormat => 'Ez a fajtolormatum nem tamogatott.';

  @override
  String get errorFileTooLarge => 'Ez a fajl tul nagy.';

  @override
  String get errorUploadFailed => 'A feltoltes nem sikerult. Probalja ujra.';

  @override
  String get errorCacheCorrupted =>
      'A mentett adatok serultek es ujra lettek allitva.';

  @override
  String get errorCacheNotFound => 'Meg nincs semmi mentve.';

  @override
  String get errorUserNotFound => 'Nem talalhato ilyen fiok.';

  @override
  String get errorItemNotFound => 'Ez az elem mar nem letezik.';

  @override
  String get errorOutfitNotFound => 'Ez az szett mar nem letezik.';

  @override
  String get rewardsTitle => 'Jutalmak';

  @override
  String get rewardsNoAchievementsTitle => 'Meg nincsenek eredmenyek';

  @override
  String get rewardsNoAchievementsBody =>
      'Adj hozza darabokat es tervezz szetteket az elso eleresehez.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Meg senki sincs a listan';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Tervezz szetteket pontokert es kerulj fel ide.';

  @override
  String get legalViewPrivacyPolicy => 'Adatvedelmi iranyelvek megtekintese';

  @override
  String get aiConsentAgree => 'Elfogadom es tovabb';

  @override
  String get aiConsentNotNow => 'Most nem';

  @override
  String get imageViewerCloseTooltip => 'Kép bezárása';

  @override
  String get updateReadyTitle => 'Frissítés elérhető';

  @override
  String get updateReadyBody =>
      'Indítsd újra a FitCheck AI-t a legújabb fejlesztések alkalmazásához.';

  @override
  String get permissionCameraUsage =>
      'A FitCheck AI-nak a kamerához kell hozzáférnie, hogy fotókat készíthess az öltözékeidről és ruháidról.';

  @override
  String get permissionPhotoLibraryUsage =>
      'A FitCheck AI-nak a fotókönyvtárhoz kell hozzáférnie, hogy képeket választhass ki az öltözékeidről és ruháidról.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'A FitCheck AI-nak mentenie kell az MI által generált öltözékfotókat a fotókönyvtáradba.';

  @override
  String get wardrobeSomePhotosSkipped => 'Néhány fotó kihagyva';

  @override
  String get wardrobePhotosNotAdded => 'A fotók nem lettek hozzáadva';

  @override
  String get wardrobePhotoNotAdded => 'A fotó nem lett hozzáadva';

  @override
  String get wardrobeNotStartedTitle => 'Nem kezdődött el';

  @override
  String get wardrobeNoRoomTitle => 'Nincs hely';

  @override
  String get wardrobeAddPhotosSemantic => 'Fotók hozzáadása';

  @override
  String get batchAddTileLabel => 'Hozzáadás';

  @override
  String get batchProfileLinkLabel => 'Profil linkje';

  @override
  String get wardrobeImportFromProfileTitle => 'Importálás profilból';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Több fotó hozzáadása';

  @override
  String get wardrobeClearAction => 'Törlés';

  @override
  String get wardrobeRefreshTooltip => 'Frissítés';

  @override
  String get batchNoPhotosYetTitle => 'Még nincsenek fotók';

  @override
  String get batchChoosePhotosAction => 'Fotók kiválasztása';

  @override
  String get batchWeFindEachPieceBody =>
      'Keresünk minden darabot és stúdiófotót készítünk róla.';

  @override
  String get batchPreparingPhotosSemantic => 'Fotók előkészítése';

  @override
  String get batchPhotosProcessedSemantic => 'Feldolgozott fotók';

  @override
  String get batchPasteProfileLinkTitle => 'Illessz be egy profillinket';

  @override
  String get batchPasteProfileLinkBody =>
      'Egy nyilvános Instagram- vagy Facebook-profil. Átnézzük a fotóit, és te döntöd el, mi kerül a szekrényedbe.';

  @override
  String get batchClearLinkTooltip => 'Link törlése';

  @override
  String get batchStartingButton => 'Indítás';

  @override
  String get batchStartImportAction => 'Importálás indítása';

  @override
  String get batchReviewEveryPhotoTitle => 'Minden fotót átnézel';

  @override
  String get batchReviewEveryPhotoBody =>
      'Semmi sem kerül hozzáadásra a jóváhagyásod nélkül.';

  @override
  String get batchPrivateProfilesTitle => 'Privát profilok';

  @override
  String get batchPrivateProfilesBody =>
      'Csatlakoztasd a fiókodat. Az Instagramhoz felhasználónév és jelszó is szükséges.';

  @override
  String get batchUseAnotherLinkAction => 'Másik link használata';

  @override
  String get batchSignInNeededTitle => 'Bejelentkezés szükséges';

  @override
  String get batchEnterYourCodeTitle => 'Add meg a kódot';

  @override
  String get batchUseUsernamePasswordAction =>
      'Felhasználónév és jelszó használata';

  @override
  String get batchAlreadyConnectedAction => 'Már csatlakoztam a böngészőben';

  @override
  String get batchEnterCodeAction => 'Kód megadása';

  @override
  String get batchTryAnotherWayAction => 'Próbáld meg másik módszerrel';

  @override
  String get batchLiveStatus => 'Élő';

  @override
  String get batchReconnectingStatus => 'Újracsatlakozás';

  @override
  String get batchSignInToInstagramTitle => 'Bejelentkezés az Instagramra';

  @override
  String get batchUsernameLabel => 'Felhasználónév';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kód, ha kétlépcsős azonosítást használsz';

  @override
  String get batchAuthenticatorCodeBody =>
      'Add meg a hitelesítő app 6 jegyű kódját. A kódok gyorsan változnak.';

  @override
  String get batchVerifyAction => 'Ellenőrzés';

  @override
  String get batchFindingPhotosTitle => 'Fotók keresése';

  @override
  String get batchImportPausedTitle => 'Importálás szüneteltetve';

  @override
  String get batchProcessingPhotosTitle => 'Fotók feldolgozása';

  @override
  String get batchWaitingNextPhoto => 'Várakozás a következő fotóra';

  @override
  String get batchCancelImportAction => 'Importálás megszakítása';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Nem találtunk darabokat ezen a fotón.';

  @override
  String get batchEditPieceColoursLabel => 'Színek vesszővel elválasztva';

  @override
  String get batchAddToClosetAction => 'Hozzáadás a gardróbhoz';

  @override
  String get batchSkipPhotoAction => 'Fotó kihagyása';

  @override
  String get batchImportCompleteTitle => 'Importálás kész';

  @override
  String get batchImportFailedTitle => 'Az importálás sikertelen';

  @override
  String get batchImportCancelledTitle => 'Importálás megszakítva';

  @override
  String get batchImportErrorBody => 'Hiba történt az importálás során.';

  @override
  String get batchNothingMoreImportedBody =>
      'Ebből a profilból nem lett több importálva.';

  @override
  String get batchViewClosetAction => 'Ruhatár megtekintése';

  @override
  String get batchStartOverAction => 'Újrakezdés';

  @override
  String get wardrobeAddPieceTitle => 'Darab hozzáadása';

  @override
  String get wardrobeAddDetailsTitle => 'Részletek hozzáadása';

  @override
  String get wardrobeScanningTitle => 'Szkennelés';

  @override
  String get batchReviewPiecesTitle => 'Darabok ellenőrzése';

  @override
  String get wardrobeGalleryAction => 'Galéria';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Új';

  @override
  String get wardrobeRemovePhotoTooltip => 'Fotó eltávolítása';

  @override
  String get batchRunInBackgroundTooltip => 'Futtatás a háttérben';

  @override
  String get batchStepOneOfTwo => '1. lépés (2-ből)';

  @override
  String get batchStepTwoOfTwo => '2. lépés (2-ből)';

  @override
  String get batchUploadingPhotosTitle => 'Fotók feltöltése';

  @override
  String get batchFindingPiecesTitle => 'Darabok keresése';

  @override
  String get batchMakingStudioPhotosTitle => 'Stúdiófotók készítése';

  @override
  String get batchStoppedLabel => 'Leállítva';

  @override
  String get batchFindingPiecesStoppedTitle => 'A darabok keresése leállt';

  @override
  String get batchCancelledLabel => 'Megszakítva';

  @override
  String get batchAllDoneTitle => 'Minden kész';

  @override
  String get batchOpeningPiecesBody => 'Darabok megnyitása';

  @override
  String get batchNothingSavedBody => 'Semmi sem lett mentve.';

  @override
  String get batchFindingPiecesFailedBody => 'A darabok keresése sikertelen.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'A darabok keresése korán leállt.';

  @override
  String get batchStopFindingPiecesTitle => 'Leállítja a darabok keresését?';

  @override
  String get batchStopFindingPiecesBody =>
      'A szkennelés leáll, és semmi sem mentődik. A már megtalált darabok a tevékenységedben maradnak, amíg el nem rejted őket.';

  @override
  String get batchKeepGoingAction => 'Folytatás';

  @override
  String get batchTryAgainAction => 'Újra';

  @override
  String get batchBackToPhotosAction => 'Vissza a fotókhoz';

  @override
  String get batchSkipAllAction => 'Összes kihagyása';

  @override
  String get batchIncludeAllAction => 'Összes kijelölése';

  @override
  String get batchNoPiecesFoundTitle => 'Nem találtunk darabokat';

  @override
  String get batchNoPiecesFoundBody => 'Nem találtunk ruhát ezeken a fotókon.';

  @override
  String get batchChooseOtherPhotosAction => 'Másik fotók választása';

  @override
  String get batchUseCaseHelper => 'Minden elmentett darabhoz hozzáadva.';

  @override
  String get batchDiscardPiecesTitle => 'Eldobod ezeket a darabokat?';

  @override
  String get batchDiscardPiecesBody =>
      'Ebből a kötegből semmi sem lett elmentve.';

  @override
  String get batchKeepAction => 'Megtartás';

  @override
  String get batchDiscardAction => 'Elvetés';

  @override
  String get batchRemovePieceTitle => 'Eltávolítod ezt a darabot?';

  @override
  String get batchRemovePieceBody => 'Nincs elmentve a szekrényedbe.';

  @override
  String get batchRemoveAction => 'Eltávolítás';

  @override
  String get batchChoosePiecesToSave => 'Válaszd ki a mentendő darabokat';

  @override
  String get batchDiscardAllAction => 'Összes elvetése';

  @override
  String get batchNothingSavedRetryBody =>
      'Semmi sem lett elmentve. Próbáld újra.';

  @override
  String get batchNotSavedTitle => 'Nincs elmentve';

  @override
  String get batchSavingLabel => 'Mentés';

  @override
  String get batchSendToBackgroundAction => 'Küldés a háttérbe';

  @override
  String get batchStillWorkingMessage =>
      'Még dolgozunk rajta. Szólunk, ha a darabjaid készen állnak.';

  @override
  String get batchRunningInBackgroundTitle => 'Futás a háttérben';

  @override
  String get batchStudioPhotosStoppedBody =>
      'A stúdiófotók készítése korábban leállt. Ezeket a darabokat még elmentheted.';

  @override
  String get batchTapPieceToSkip => 'Koppints egy darabra a kihagyásához.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'A stúdiófotók még úton vannak. Elmehetsz – szólunk, ha kész.';

  @override
  String get batchLeaveAction => 'Kilépés';

  @override
  String get batchPeopleInPhotosTitle => 'Emberek a fotókon';

  @override
  String get batchIncludeAction => 'Beleértve';

  @override
  String get batchSkipAction => 'Kihagyás';

  @override
  String get batchYourPhotoIsUsedLabel => 'A saját fotód van használatban';

  @override
  String get batchMakingStudioPhotoLabel => 'Stúdiófotó készítése';

  @override
  String get batchNoStudioPhotoBody =>
      'Nincs stúdiófotó. A saját fotód van használatban.';

  @override
  String get batchEnterDetailsYourselfAction => 'Add meg magad';

  @override
  String get batchChooseAnotherPhotoAction => 'Másik fotó';

  @override
  String get batchConnectionLostTitle => 'Nincs kapcsolat';

  @override
  String get batchConnectionLostBody =>
      'Ellenőrizd a kapcsolatot, majd próbáld újra.';

  @override
  String get batchDailyLimitTitle => 'Napi limit elérve';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Válts át Pro-ra a több szkennelésért, vagy add meg az adatokat magad.';

  @override
  String get batchDailyLimitBodyFree =>
      'A szkenneléseid holnap újraindulnak. Add meg az adatokat magad most.';

  @override
  String get batchSeePlansAction => 'Csomagok megtekintése';

  @override
  String get batchAiBusyTitle => 'Az AI elfoglalt';

  @override
  String get batchAiBusyBody =>
      'Ez a mi oldalunkon történt. Próbáld újra pár perc múlva.';

  @override
  String get batchNoPiecesBody =>
      'Próbálj meg egy tisztább fotót, vagy add meg az adatokat magad.';

  @override
  String get batchScanningUnavailableTitle => 'A szkennelés nem érhető el';

  @override
  String get batchScanningUnavailableBody =>
      'Add meg az adatokat magad egyelőre.';

  @override
  String get batchScanDidNotFinishTitle => 'A szkennelés nem fejeződött be';

  @override
  String get batchTryAgainBody => 'Próbáld újra.';

  @override
  String get billingTitle => 'Előfizetés';

  @override
  String get billingUpgradeHeading => 'Csomag frissítése';

  @override
  String get billingUpgradeOnPlusBody =>
      'Ugyanazok a funkciók, magasabb limitek.';

  @override
  String get billingUpgradeBody =>
      'A Plus és a Pro ugyanazokat a funkciókat tartalmazza. Válaszd ki a neked való limiteket.';

  @override
  String get billingWebUnavailableBody =>
      'Az online frissítés még nem érhető el. Egy promó- vagy ajánlói kód még feloldhatja a Plus vagy Pro csomagot. Hívj meg barátokat lent ingyen hónapokért.';

  @override
  String get billingPlansStale =>
      'Nem sikerült betölteni a legfrissebb csomagokat. Az árak elavultak lehetnek.';

  @override
  String get billingMonthly => 'Havi';

  @override
  String get billingYearly => 'Éves';

  @override
  String get billingCurrentPlan => 'Jelenlegi csomag';

  @override
  String get billingActive => 'Aktív';

  @override
  String get billingThisMonth => 'Ebben a hónapban';

  @override
  String get billingItemExtractions => 'Darabok kinyerése';

  @override
  String get billingOutfitVisualizations => 'Szettvizualizációk';

  @override
  String get billingNearLimitUpgrade =>
      'Közel jársz a havi limithez. Válts át többért.';

  @override
  String get billingNearLimitResets =>
      'Közel jársz a havi limithez. Újraindul a következő hónap elején.';

  @override
  String get billingStoreUnavailable =>
      'Az előfizetések még nem érhetők el az áruházban. Kérjük, próbálja újra később.';

  @override
  String get billingManageHeading => 'Előfizetés kezelése';

  @override
  String get billingCancelPlan => 'Előfizetés lemondása';

  @override
  String get billingCancelKeepsAccess =>
      'A hozzáférése megmarad ennek a számlázási időszaknak a végéig.';

  @override
  String get billingCancelConfirmTitle => 'Lemondja az előfizetését?';

  @override
  String get billingKeepPlan => 'Előfizetés megtartása';

  @override
  String get billingCancelPlanAction => 'Előfizetés lemondása';

  @override
  String get billingBilledMonthly => 'Havonta számlázva';

  @override
  String get billingBilledYearly => 'Évente számlázva';

  @override
  String get billingVirtualTryOn => 'Virtuális felpróbálás';

  @override
  String get billingPrioritySupport => 'Kiemelt ügyfélszolgálat';

  @override
  String get billingDisclosureProRenewing =>
      'A Pro egy automatikusan megújuló előfizetés';

  @override
  String get billingDisclosureBothRenewing =>
      'A Plus és a Pro automatikusan megújuló előfizetések';

  @override
  String get billingDisclosureAppleBilling =>
      'A fizetés a vásárlás megerősítésekor terhelődik az Apple ID fiókjára.';

  @override
  String get billingDisclosureGoogleBilling =>
      'A fizetés a vásárlás megerősítésekor terhelődik a Google Play fiókjára.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Előfizetése automatikusan megújul ugyanazon időtartamra és áron, ha nem kapcsolja ki az automatikus megújítást az aktuális időszak vége előtt legalább 24 órával.';

  @override
  String get billingDisclosureAppleManage =>
      'Bármikor kezelheti vagy lemondhatja a Beállítások › Apple ID › Előfizetések menüpontban.';

  @override
  String get billingDisclosureGoogleManage =>
      'Bármikor kezelheti vagy lemondhatja a Google Play › Fizetések és előfizetések menüpontban.';

  @override
  String get billingReferFriend => 'Hívjon meg egy barátot';

  @override
  String get billingHowItWorks => 'Hogyan működik';

  @override
  String get billingHowShareTitle => 'Ossza meg a linkjét';

  @override
  String get billingHowShareBody => 'Küldje el egy barátjának.';

  @override
  String get billingHowSignUpTitle => 'Regisztrálnak';

  @override
  String get billingHowSignUpBody => 'Barátja csatlakozik a linken keresztül.';

  @override
  String get billingHowBothTitle => 'Mindketten megkapják a Pro-t';

  @override
  String get billingHowBothBody =>
      'Mindketten kapnak egy ingyenes Pro hónapot.';

  @override
  String get billingYourReferrals => 'Meghívásai';

  @override
  String get billingInvited => 'Meghívva';

  @override
  String get billingJoined => 'Csatlakozott';

  @override
  String get billingMonthsEarned => 'Megszerzett hónapok';

  @override
  String get billingInviteFriend => 'Barát meghívása';

  @override
  String get billingInviteBody =>
      'Te és a barátod is kapsz egy hónap Pro hozzáférést.';

  @override
  String get billingYourCode => 'A te kódod';

  @override
  String get billingCopyLink => 'Link másolása';

  @override
  String get billingShareInvite => 'Meghívó megosztása';

  @override
  String get giftUnavailable =>
      'Ajándék meghívók nem érhetők el ebben a verzióban.';

  @override
  String get giftPageTitle => 'Ajándékozz FitCheck Pro-t';

  @override
  String get giftNoAllowances =>
      'Jelenleg nincsenek ingyenes ajándék meghívók.';

  @override
  String get giftFormTitle => 'Ingyenes meghívó küldése';

  @override
  String get giftFormBody =>
      'A ajándékozott ezzel az ellenőrzött e-mail címmel érvényesítheti az ajándékot. Nem küldjük el helyetted az e-mailt.';

  @override
  String get giftFieldFrom => 'Feladó';

  @override
  String get giftFieldRecipientName => 'Címzett neve';

  @override
  String get giftFieldRecipientEmail => 'Címzett e-mail címe';

  @override
  String get giftFieldOccasion => 'Alalom (opcionális)';

  @override
  String get giftNoOccasion => 'Nincs alkalom';

  @override
  String get giftOccasionBirthday => 'Születésnap';

  @override
  String get giftOccasionAnniversary => 'Évforduló';

  @override
  String get giftOccasionOther => 'Egyéb';

  @override
  String get giftFieldCardGreeting => 'Üdvözlőkártya szövege';

  @override
  String get giftFieldCardGreetingHelper =>
      'Pontosan így fog megjelenni a kártyán.';

  @override
  String get giftFieldPrivateNote => 'Személyes üzenet (opcionális)';

  @override
  String get giftCreateAction => 'Ingyenes ajándék létrehozása';

  @override
  String get giftClaimedTitle => 'Ajándék beváltva';

  @override
  String get giftClaimedActive => 'A FitCheck Pro ajándékod aktív.';

  @override
  String get giftClaimedQueued =>
      'A FitCheck Pro ajándékod a jelenlegi előfizetésed lejárta után kezdődik.';

  @override
  String get giftLinkCopied => 'Az ajándék linkje a vágólapra másolva.';

  @override
  String get giftErrorName => 'Add meg a nevet.';

  @override
  String get giftErrorEmail => 'Adj meg egy érvényes e-mail címet.';

  @override
  String get giftErrorGreeting => 'Add meg a kártya szövegét.';

  @override
  String get giftErrorGreetingLength => 'Legfeljebb 80 karaktert használj.';

  @override
  String get giftClaimAction => 'Ajándék beváltása';

  @override
  String get giftCardPreview => 'Kártya előnézete';

  @override
  String get giftGiftForYou => 'Ajándék neked';

  @override
  String get giftGiftWaiting => 'Ajándék vár rád';

  @override
  String get giftOpenBody =>
      'Nyisd meg az ajándékaidat, és válaszd be őket a megerősített e-mail címeddel.';

  @override
  String get giftOpenGifts => 'Ajándékok megnyitása';

  @override
  String get giftSendInvitation => 'Meghívó küldése';

  @override
  String get settingsAiProviderSection => 'Szolgáltató';

  @override
  String get settingsAiCustom => 'Egyéni';

  @override
  String get settingsAiUrlHelper =>
      'Használj egy nyilvános URL-t, amelyet a szerver elér. A helyi kiszolgáló (localhost) nem működik a szervereinkről.';

  @override
  String get settingsAiConnectionSection => 'Kapcsolat';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API-kulcs';

  @override
  String get settingsAiApiKeySaved => 'Mentve. Hagyd üresen a megtartásához.';

  @override
  String get settingsAiChatModel => 'Csevegési modell';

  @override
  String get settingsAiVisionModel => 'Látási modell (opcionális)';

  @override
  String get settingsAiImageModel => 'Képmodell (opcionális)';

  @override
  String get settingsAiImageModelNote =>
      'A képgeneráláshoz OpenAI-kompatibilis csevegési kiegészítések szükségesek response_modalities paraméterrel.';

  @override
  String get settingsAiTestConnection => 'Kapcsolat tesztelése';

  @override
  String get calendarTitle => 'Naptár';

  @override
  String get calendarGoToToday => 'Ugrás a mára';

  @override
  String get calendarConnectTooltip => 'Naptár összekapcsolása';

  @override
  String get calendarAddEvent => 'Esemény hozzáadása';

  @override
  String get calendarEmptyTitle => 'Nincs tervezett program';

  @override
  String get calendarEmptyBody =>
      'Adj hozzá egy eseményt, és tervezd meg, mit veszel fel.';

  @override
  String get calendarPreviousMonth => 'Előző hónap';

  @override
  String get calendarNextMonth => 'Következő hónap';

  @override
  String get calendarAllDay => 'Egész nap';

  @override
  String get calendarOutfitLinked => 'Összeállítás csatolva';

  @override
  String get calendarEventOptions => 'Esemény beállításai';

  @override
  String get calendarDeleteTitle => 'Törlöd ezt az eseményt?';

  @override
  String get calendarChangeOutfit => 'Szett cseréje';

  @override
  String get calendarLinkOutfit => 'Szett csatolása';

  @override
  String get calendarRemoveOutfit => 'Szett eltávolítása';

  @override
  String get calendarNewEvent => 'Új esemény';

  @override
  String get calendarEditEvent => 'Esemény szerkesztése';

  @override
  String get calendarTitleLabel => 'Cím';

  @override
  String get calendarTitleRequired => 'Adj meg egy címet';

  @override
  String get calendarEndBeforeStart => 'A kezdés után véget ér';

  @override
  String get calendarStarts => 'Kezdet';

  @override
  String get calendarEnds => 'Vég';

  @override
  String get calendarPlaceOptional => 'Helyszín (opcionális)';

  @override
  String get calendarNotesOptional => 'Jegyzetek (opcionális)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Összeállíthatsz egy szettet, majd csatolhatod ehhez az eseményhez.';

  @override
  String get calendarBuildOutfit => 'Szett összeállítása';

  @override
  String get calendarConnectionsTitle => 'Naptárak';

  @override
  String get calendarConnectionsBody =>
      'Az itt hozzáadott események a FitCheckben maradnak.';

  @override
  String get calendarDisconnect => 'Kapcsolat bontása';

  @override
  String get calendarNotAvailable => 'Még nem érhető el';

  @override
  String get profileSectionExplore => 'Felfedezés';

  @override
  String get profileNavTryOn => 'Felpróbálás';

  @override
  String get profileNavRewards => 'Jutalmak';

  @override
  String get profileSupport => 'Támogatás';

  @override
  String get profileHelp => 'Segítség';

  @override
  String get profileAbout => 'Névjegy';

  @override
  String get profileAboutBody =>
      'Garderobjaid, szettjeid és előfizetéseid egy helyen.';

  @override
  String get profileSignOutTitle => 'Kijelentkezel?';

  @override
  String get profileSignOutBody => 'Bármikor újra bejelentkezhetsz.';

  @override
  String get profileEditTitle => 'Profil szerkesztése';

  @override
  String get profileYourProfile => 'A profilod';

  @override
  String get profileBodyProfiles => 'Testalkatok';

  @override
  String get profileBodyEmptyTitle => 'Még nincsenek testalkatok';

  @override
  String get profileBodyEmptyBody =>
      'Add meg a magasságod és testalkatod a jobb illeszkedéshez.';

  @override
  String get profileBodyAdd => 'Profil hozzáadása';

  @override
  String get profileBodyDefaultNote =>
      'Az alapértelmezett profilod használjuk a mérethez és a próbához.';

  @override
  String get profileBodyDefaultBadge => 'Alapértelmezett';

  @override
  String get profileBodyMakeDefault => 'Legyen alapértelmezett';

  @override
  String get profileBodyDeleteBody => 'Ez nem vonható vissza.';

  @override
  String get profileBodyRequired => 'Kötelező';

  @override
  String get profileBodyCheckNumber => 'Ellenőrizd ezt a számot';

  @override
  String get profileBodyNew => 'Új testalkat';

  @override
  String get profileBodyNameHint => 'Például: Én';

  @override
  String get profileBodyHeight => 'Magasság';

  @override
  String get profileBodyWeight => 'Súly';

  @override
  String get profileBodyBuild => 'Testalkat';

  @override
  String get profileBodySkinTone => 'Bőrtónus';

  @override
  String get profileBirthDateNeededBody =>
      'Add meg a születési dátumot a születési időhöz.';

  @override
  String get profileBirthDateNeededTitle => 'Születési dátum szükséges';

  @override
  String get profilePartlySavedBody =>
      'Mentettük a neved és a fotód. A születési adatok mentése sikertelen volt, próbáld újra később.';

  @override
  String get profilePartlySavedTitle => 'Részben mentve';

  @override
  String get profileSavedBody => 'A profilodat mentettük.';

  @override
  String get profileChangePhoto => 'Profilfotó módosítása';

  @override
  String get profilePhotoLabel => 'Profilfotó';

  @override
  String get profilePhotoHint => 'Koppints új választásához';

  @override
  String get profileBirthDateLabel => 'Születési dátum (opcionális)';

  @override
  String get profileBirthTimeLabel => 'Születési idő (opcionális)';

  @override
  String get profileBirthTimeHelper => 'Pontosabb védikus javaslatokat ad';

  @override
  String get profileBirthPlaceLabel => 'Születési hely (opcionális)';

  @override
  String get profileBirthPlaceHint => 'Például: Budapest, Magyarország';

  @override
  String get profileHelpContactTitle => 'Kérdezz tőlünk bármit';

  @override
  String get profileHelpContactBody =>
      'Írjon nekünk, és általában egy napon belül válaszolunk e-mailben.';

  @override
  String get profileHelpContactAction => 'Ügyfélszolgálat';

  @override
  String get profileHelpFaqTitle => 'Gyakori kérdések';

  @override
  String get profileFaqAddPiecesTitle =>
      'Hogyan adhatok darabokat a ruhatáramhoz?';

  @override
  String get profileFaqAddPiecesBody =>
      'Koppintson a Darab hozzáadása gombra a Ruhatár fülön. Készítsen fotót vagy válasszon a galériából; mi megtaláljuk és felcímkézzük az egyes darabokat.';

  @override
  String get profileFaqMatchingTitle => 'Hogyan működik az öltözékpárosítás?';

  @override
  String get profileFaqMatchingBody =>
      'Nyissa meg a Neked fülön a meglévő darabjait. Javaslatot teszünk a kiegészítésekre, és teljes szetteket állítunk össze a ruhatárából.';

  @override
  String get profileFaqTryOnTitle =>
      'Használhatom a saját fotóimat a felpróbáláshoz?';

  @override
  String get profileFaqTryOnBody =>
      'Igen. Adjon hozzá egy teljes alakos fotót magáról, majd válasszon darabokat, hogy lássa őket magán.';

  @override
  String get profileFaqRewardsTitle => 'Hogyan szerezhetek jutalmakat?';

  @override
  String get profileFaqRewardsBody =>
      'Tervezze és rögzítse szettjeit rendszeresen. A sorozatok és elérések maguktól épülnek.';

  @override
  String get profileFaqPrivacyTitle => 'Privát a ruhatáram?';

  @override
  String get profileFaqPrivacyBody =>
      'Igen. A ruhatára és a szettjei magánjellegűek, hacsak meg nem oszt egyetlen szettre mutató hivatkozást.';

  @override
  String get profileHelpMoreTitle => 'További segítség';

  @override
  String get profileHelpGuides => 'Útmutatók';

  @override
  String get profileHelpGuidesBody => 'Hogyan működnek az egyes funkciók';

  @override
  String get feedbackCategoryBug => 'Valami elromlott';

  @override
  String get feedbackCategoryIdea => 'Egy ötlet';

  @override
  String get feedbackCategoryGeneral => 'Általános';

  @override
  String get feedbackCategoryHelp => 'Segítségre van szükségem';

  @override
  String get feedbackHintBug =>
      'Mi történt, és mit várt volna? A lépések segítenek a javításban.';

  @override
  String get feedbackHintIdea => 'Mit szeretne, és miért?';

  @override
  String get feedbackHintGeneral =>
      'Írja meg véleményét, vagy tegyen fel egy kérdést.';

  @override
  String get feedbackAttachmentLimitBody => 'Legfeljebb 5 képet adhat hozzá.';

  @override
  String get feedbackAttachmentLimitTitle => 'Elérte a limitet';

  @override
  String get feedbackImageTooLargeBody => 'Válasszon 5 MB alatti képet.';

  @override
  String get feedbackImageTooLargeTitle => 'Túl nagy kép';

  @override
  String get feedbackTitle => 'Visszajelzés küldése';

  @override
  String get feedbackAboutLabel => 'Miről van szó?';

  @override
  String get feedbackSubjectLabel => 'Tárgy';

  @override
  String get feedbackSubjectRequired => 'Add meg a tárgyat';

  @override
  String get feedbackSubjectTooShort =>
      'A tárgynak legalább 3 karakternek kell lennie';

  @override
  String get feedbackDetailsLabel => 'Részletek';

  @override
  String get feedbackDetailsRequired => 'Adj meg részleteket';

  @override
  String get feedbackDetailsTooShort =>
      'A leírásnak legalább 10 karakternek kell lennie';

  @override
  String get feedbackAddScreenshot => 'Képernyőkép hozzáadása';

  @override
  String get feedbackAttachmentHint => 'Legfeljebb 5, egyenként 5 MB';

  @override
  String get feedbackSend => 'Küldés';

  @override
  String get feedbackEmptyTitle => 'Még nincs elküldve semmi';

  @override
  String get feedbackEmptyBody =>
      'Az elküldött elemek és státuszuk itt jelennek meg.';

  @override
  String get feedbackHistoryTitle => 'Elküldve';

  @override
  String get feedbackStatusOpen => 'Nyitott';

  @override
  String get feedbackStatusInProgress => 'Folyamatban';

  @override
  String get feedbackStatusResolved => 'Megoldva';

  @override
  String get feedbackStatusClosed => 'Lezárva';

  @override
  String get legalIntro =>
      'Hogyan védjük az adataidat, és a FitCheck AI használati feltételei.';

  @override
  String get legalPolicies => 'Irányelvek';

  @override
  String get legalPrivacySubtitle => 'Mit gyűjtünk és miért';

  @override
  String get legalTermsTitle => 'Felhasználási feltételek';

  @override
  String get legalTermsSubtitle => 'Az alkalmazás használati szabályai';

  @override
  String get legalLicences => 'Nyílt forráskódú licencek';

  @override
  String get legalSupportSubtitle => 'Súgó, kapcsolat és adatvédelmi kérések';

  @override
  String get legalReportAbuse => 'Probléma vagy visszaélés jelentése';

  @override
  String get permissionCameraTitle => 'Kamera hozzáférés';

  @override
  String get permissionCameraRationale =>
      'A FitCheck AI a kamerát használja a ruhák és szettek fotózásához az AI felpróbáláshoz és a ruhatár rendszerezéséhez.';

  @override
  String get permissionPhotoTitle => 'Fotók hozzáférés';

  @override
  String get permissionPhotoRationale =>
      'A FitCheck AI hozzáférést kér a fotóidhoz, hogy ruhákat és szetteket választhass az AI funkciókhoz és a ruhatáradhoz.';

  @override
  String get permissionNotNow => 'Most nem';

  @override
  String get permissionOpenSettings => 'Beállítások megnyitása';

  @override
  String authSignedInAs(String name) {
    return 'Bejelentkezve mint $name';
  }

  @override
  String get authSignedIn => 'Bejelentkezve';

  @override
  String get authWelcomeBackTitle => 'Üdv újra';

  @override
  String get authSignInFailed => 'A bejelentkezés sikertelen';

  @override
  String get authWelcomeTitle => 'Üdvözlünk';

  @override
  String get authSignUpFailed => 'A regisztráció sikertelen';

  @override
  String get authGoogleSignInFailed => 'A Google-bejelentkezés sikertelen';

  @override
  String get authAppleSignInFailed => 'Az Apple-bejelentkezés sikertelen';

  @override
  String get authConfirmEmailTitle => 'Erősítsd meg az e-mail címed';

  @override
  String get authConfirmEmailBody =>
      'Nézd meg a postaládádat a megerősítő e-mailért, majd jelentkezz be.';

  @override
  String get authClosetReady => 'A gardróbod készen áll.';

  @override
  String get authSignedOutTitle => 'Kijelentkezve';

  @override
  String get authSignedOutBody => 'Sikeresen kijelentkeztél.';

  @override
  String get authSignOutFailed => 'A kijelentkezés sikertelen';

  @override
  String get authEmailSentTitle => 'E-mail elküldve';

  @override
  String get authResetLinkSent =>
      'Nézd meg az e-mailjeidet a jelszó-visszaállító linkért.';

  @override
  String get authPasswordUpdatedTitle => 'Jelszó frissítve';

  @override
  String get authPasswordUpdated => 'A jelszavad frissítve lett.';

  @override
  String get authPasswordNotUpdated => 'A jelszó nem frissült';

  @override
  String get authCouldNotSendEmail => 'Az e-mailt nem sikerült elküldeni';

  @override
  String get authEmailNotSent => 'Az e-mail nem lett elküldve';

  @override
  String get authResendSentBody => 'Elküldtünk egy új megerősítő e-mailt.';

  @override
  String get outfitPreviewWithAi => 'Nézetbeállítás AI-val';

  @override
  String get outfitNewPreview => 'Új nézet készítése';

  @override
  String get outfitBuilderClosetHeading => 'Ívesed';

  @override
  String get outfitBuilderSearchHint => 'Keresd a darabokat';

  @override
  String get outfitClearSearch => 'Keresés törlése';

  @override
  String get outfitBuilderAddPiecesTitle => 'Add hozzá előbb a darabokat';

  @override
  String get outfitBuilderAddPiecesBody =>
      'A szettek a szekrényedben lévő darabokból állnak.';

  @override
  String get outfitBuilderNoMatches => 'Nincs egyező darab.';

  @override
  String get outfitNameLabel => 'Szett neve';

  @override
  String get outfitNameHint => 'Például, Hétvégi línemű';

  @override
  String get outfitPreviewSemantic => 'A szett AI alapú előnézete';

  @override
  String get outfitChoosePieces => 'Darabok kiválasztása';

  @override
  String get outfitTapPiecesHint =>
      'Nyisd meg lent a darabokat a hozzáadáshoz.';

  @override
  String get outfitShareTooltip => 'Megosztás';

  @override
  String get outfitSaveFavourite => 'Kedvencekhez mentve';

  @override
  String get outfitPiecesHeading => 'Darabok';

  @override
  String get outfitWearHistoryEmpty =>
      'Hordj egyszer, és itt jelennek meg a dátumok.';

  @override
  String get outfitWearHistoryTitle => 'Hordás naplój';

  @override
  String get outfitWearHistoryError => 'Nem sikerült betölteni a dátumokat.';

  @override
  String get outfitWornOn => 'Hordva:';

  @override
  String get outfitEditTitle => 'Szett szerkesztése';

  @override
  String get outfitSavedPhotosFailed => 'Részletek mentve, a fotók nem';

  @override
  String get outfitNoPhotosBody =>
      'Még nincs fotó. A szett helyette a darabokat mutatja.';

  @override
  String get outfitOccasionLabel => 'Alkalmi';

  @override
  String get outfitOccasionNone => 'Nincs';

  @override
  String get outfitTagsHint => 'Vesszővel elválasztva';

  @override
  String get outfitDraftBody => 'Rejtve a főlistádból';

  @override
  String get outfitPublic => 'Nyilvános';

  @override
  String get outfitPublicBody => 'A linkkel rendelkezőki láthatják';

  @override
  String get outfitDeleteFromDetail =>
      'E szett törlése a részletező oldaláról.';

  @override
  String get outfitNewCollection => 'Új gyűjtemény';

  @override
  String get outfitNoCollectionsTitle => 'Még nincs gyűjtemény';

  @override
  String get outfitNoCollectionsBody =>
      'Csoportosítsd összeállításokat utazás, évszak vagy hangulat szerint.';

  @override
  String get outfitCreateCollection => 'Gyűjtemény létrehozása';

  @override
  String get outfitAddOutfits => 'Összeállítások hozzáadása';

  @override
  String get outfitRename => 'Átnevezés';

  @override
  String get outfitCollectionDeleteBody =>
      'A benne lévő összeállítások megmaradnak.';

  @override
  String get outfitCollectionsNotLoaded => 'Összeállítások nem betöltve';

  @override
  String get outfitRenameCollection => 'Gyűjtemény átnevezése';

  @override
  String get outfitDescriptionOptional => 'Leírás (opcionális)';

  @override
  String get outfitAllInCollection =>
      'Minden összeállítás már ebből a gyűjteményből származik.';

  @override
  String get photoshootSubtitleUpload => 'Stúdiós portrék a saját fotóidból';

  @override
  String get photoshootSubtitleConfigure =>
      'Stílus, formátum és darabszám kiválasztása';

  @override
  String get photoshootSubtitleGenerating => 'Ez egy-két percet vesz igénybe';

  @override
  String get photoshootAddPhotosSemantic => 'Fotók hozzáadása a galériádból';

  @override
  String get photoshootUploadTitle => 'Ad hozzá 1–4 saját fotót';

  @override
  String get photoshootUploadBody =>
      'Érintsd meg a galériadból való kiválasztáshoz';

  @override
  String get photoshootAddToContinue => 'Add hozzá a fotót a folytatáshoz';

  @override
  String get photoshootAddAnotherPhoto => 'Egyéb fotó hozzáadása';

  @override
  String get photoshootTipsTitle => 'A legjobb eredményhez';

  @override
  String get photoshootTipsBody =>
      'Használj tiszta, jól megvilágított arcfotót több szögből is. Kerüld a napszemüveget és a sapkát.';

  @override
  String get photoshootStarting => 'Indítás';

  @override
  String get photoshootCancelling => 'Mégse';

  @override
  String get photoshootFailed => 'Hiba';

  @override
  String get recommendTabMatches => 'Illik';

  @override
  String get recommendTabComplete => 'Teljesít';

  @override
  String get recommendTabWeather => 'Idő';

  @override
  String get recommendTabColours => 'Színek';

  @override
  String get recommendTabShop => 'Bolt';

  @override
  String get recommendNoMatchesTitle => 'Még nincs találat';

  @override
  String get recommendNoMatchesBody =>
      'Válassz egy darabot, és megkeressük, ami passzol hozzá.';

  @override
  String get recommendPickPiece => 'Darab kiválasztása';

  @override
  String get recommendNothingMatchesTitle => 'Eddig nincs illő pár ehhez';

  @override
  String get recommendNothingMatchesBody =>
      'Próbálj meg más darabokat, vagy bővítsz gardróbad.';

  @override
  String get recommendChangePieces => 'Darabok megváltoztatása';

  @override
  String get recommendDefaultReason => 'Illik a kiválasztott darabokhoz.';

  @override
  String get recommendCompleteTitle => 'Készíts egy stílust';

  @override
  String get recommendCompleteBody =>
      'Válassz egy darabot, és kitöltjük a többit.';

  @override
  String get recommendWorking => 'Feldolgozás';

  @override
  String get recommendGenerate => 'Generálás';

  @override
  String get recommendChooseStyleBody => 'Válassz stílust, majd generálj.';

  @override
  String get recommendNoLooksTitle => 'Nincs stílus ezekhez a darabokhoz';

  @override
  String get recommendNoLooksBody => 'Próbálj más stílust vagy más darabokat.';

  @override
  String get recommendDefaultLook => 'Stílus a darabjaidhoz';

  @override
  String get recommendNoPiecesBody => 'Nem érkezett darab ehhez a stílushoz.';

  @override
  String get recommendCityLabel => 'Város';

  @override
  String get recommendCheck => 'Ellenőrzés';

  @override
  String get recommendWeatherTitle => 'Milyen az időjárás?';

  @override
  String get recommendWeatherBody =>
      'Add meg a városod, és megadjuk a ma alkalmas darabokat.';

  @override
  String get recommendWearToday => 'Ma viseld';

  @override
  String get recommendWeatherNoPieces =>
      'Nincsenek ekkorára alkalmas darabok a gardróbadban.';

  @override
  String get recommendBudgetLabel => 'Költségkeret legfeljebb';

  @override
  String get recommendLooking => 'Keresés';

  @override
  String get recommendFindWhatToBuy => 'Mire költsek';

  @override
  String get recommendFillGapsTitle => 'Töltsd ki a hiányokat';

  @override
  String get recommendFillGapsBody =>
      'Állíts be költségkeretet, és javasoljuk, mi hiányzik a gardróbadban.';

  @override
  String get recommendNoGapsTitle => 'Nem található hiány';

  @override
  String get recommendNoGapsBody =>
      'Próbálj nagyobb költségkeretet vagy más kategóriát.';

  @override
  String get recommendMoodEveryday => 'Mindennapi';

  @override
  String get recommendMoodBigMeeting => 'Nagy megbeszélés';

  @override
  String get recommendDayLabel => 'Nap';

  @override
  String get recommendReadingStars => 'Csillagokat olvassuk';

  @override
  String get recommendGetMyColours => 'Megkapom a színeim';

  @override
  String get recommendLuckyColoursTitle => 'A szerencse színeid';

  @override
  String get recommendLuckyColoursBody =>
      'Válassz napot, és mi javasolunk hozzá színeket és ruhákat.';

  @override
  String get recommendLuckyColoursSection => 'Szerencse színei';

  @override
  String get recommendAvoidColoursSection => 'Amit kevésbé célszerű viselni';

  @override
  String get recommendBirthDateTitle => 'Add meg a születési dátumed';

  @override
  String get recommendBirthDateBody =>
      'Születési dátumod kellen a színeid elemzéséhez.';

  @override
  String get recommendEditProfile => 'Profil szerkesztése';

  @override
  String get recommendNothingThisDay => 'Ezzel a nappal nincs.';

  @override
  String get recommendUnnamedColour => 'Névtelen szín';

  @override
  String get recommendFromCloset => 'A szekrényedből';

  @override
  String get recommendNoPiecesInColours =>
      'Még nincsenek darabok ezekben a színekben.';

  @override
  String get recommendOutfitIdeas => 'Outfit ötletek';

  @override
  String get recommendNoOutfitsInColours =>
      'Még nincs teljes outfit ezekkel a színekkel.';

  @override
  String get recommendDefaultOutfitIdea => 'Egy outfit ötlet';

  @override
  String get recommendPickUpToThree => 'Válassz max. három darabot';

  @override
  String get recommendEmptyClosetBody =>
      'Kezdjen néhány ruhadarabbal, utána keressünk kombinációkat.';

  @override
  String get dashboardDressForDay => 'Öltözködj a következő napra.';

  @override
  String get dashboardOutfitOfDay => 'A nap outfitje';

  @override
  String get dashboardFreshLook => 'Egy friss megjelenés';

  @override
  String get subscriptionManageInStoreTitle => 'Kezelés az üzletben';

  @override
  String get subscriptionManageInStoreBody =>
      'Ezen a csomagon keresztül a bolt vonja le a díjat. Állítsd be a bolti fiókod beállításaiban.';

  @override
  String get subscriptionCancelledTitle => 'Előfizetés lemondva';

  @override
  String get subscriptionCancelledBody =>
      'A csomagod aktív marad a jelenlegi számlázási ciklus végéig.';

  @override
  String get subscriptionCancelFailedTitle => 'Nem sikerült lemondani';

  @override
  String get subscriptionCouldNotOpenTitle => 'Nem nyitható meg';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Nem sikerült megnyitni a számlázási beállításokat.';

  @override
  String get subscriptionOpenLinkFailedBody =>
      'Nem sikerült megnyitni a linket.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'A hivatkozási link betöltése nem sikerült';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'A hivatkozási link betöltése nem sikerült. Próbáld újra.';

  @override
  String get subscriptionReferralCopiedTitle => 'Másolva';

  @override
  String get subscriptionReferralCopiedBody =>
      'A hivatkozási linkot bemásoltuk.';

  @override
  String get subscriptionReferralShareSubject => 'Próbáld ki a FitCheck AI-t';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Csatlakozz a FitCheck AI-hoz, és mindkettőnknek lesz egy hónapnyi Pro hozzáférésünk. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link bemásolva';

  @override
  String get subscriptionShareUnavailableBody =>
      'A megosztás nem elérhető, ezért bemásoltuk a linket.';

  @override
  String get subscriptionShareFailedTitle => 'Megosztás sikertelen';

  @override
  String get subscriptionShareFailedBody =>
      'Másold ki a linket a hivatkozási oldalról.';

  @override
  String get subscriptionStoreReadyTitle => 'Az üzlet készen áll';

  @override
  String get subscriptionStoreReadyBody =>
      'Az áruk elérhetők. Most frissítheted a csomagodat.';

  @override
  String get purchaseFailedTitle => 'Sikertelen megvásárlás';

  @override
  String get purchaseUnavailableTitle => 'Nem vásárolható meg';

  @override
  String get purchaseIapUnavailableBody =>
      'Az alkalmazáson belüli vásárlás nem elérhető ezen az eszközön.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Ez a csomag még nem vásárolható meg.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Ez a csomag még nem érhető el az üzletben. Kérjük, később ellátogatsz ide.';

  @override
  String get purchaseStartFailedBody =>
      'A megvásárlás nem indítható el. Próbáld újra.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'A kiadás nem adta vissza a fizetési linket.';

  @override
  String get purchasePendingTitle => 'Függőben lévő megvásárlás';

  @override
  String get purchasePendingBody =>
      'A megvásárlásod jóváhagyásra vár. Amint jóváhagyják, hozzáférhetsz.';

  @override
  String get purchaseFailedBody =>
      'A megvásárlás sikertelen volt. Próbáld újra.';

  @override
  String get purchaseRestoredTitle => 'Visszaállítva';

  @override
  String get purchaseRestoredBody => 'A vásárlásaid visszaálltak.';

  @override
  String get purchaseActiveTitle => 'Aktív előfizetés';

  @override
  String get purchaseActiveBody => 'Az előfizetésed aktív. Üdvözöllek.';

  @override
  String get purchaseSignInRequiredTitle => 'Bejelentkezés szükséges';

  @override
  String get purchaseSignInRequiredBody =>
      'Jelents be, hogy lefejezd a megvásárlást.';

  @override
  String get purchaseErrorTitle => 'Vásárlási hiba';

  @override
  String get purchaseInvalidTransactionBody =>
      'A megvásárlás nem tartalmazott ellenőrizhető tranzakció-azonosítót.';

  @override
  String get purchaseVerificationPendingTitle => 'Ellenőrzés folyamatban';

  @override
  String get purchaseVerificationPendingBody =>
      'Most nem sikerült ellenőriznünk a vásárlásodat az üzletnél. A folyamat automatikusan befejeződik, és nem leszel kétszer számlázva.';

  @override
  String get purchaseNotAppliedTitle => 'A vásárlás nem élt';

  @override
  String get purchaseNotAppliedBody =>
      'Nem sikerült felhasználni a vásárlásodat a fiókodon. Keress meg minket a támogatáson keresztül, és ne vedd meg újra.';

  @override
  String get purchaseRestoreFailedTitle => 'Visszaállítás sikertelen';

  @override
  String get purchaseRestoreFailedBody =>
      'Nem sikerült visszaállítani a vásárlásokat. Próbáld újra.';

  @override
  String get purchaseRecoveredActiveBody => 'Az előfizetésed aktív.';

  @override
  String get purchaseCompleteTitle => 'Sikeres vásárlás';

  @override
  String get giftCreateFailedTitle => 'Nem sikerült létrehozni az ajándékot';

  @override
  String get giftClaimFailedTitle => 'Nem sikerült igénybevenni az ajándékot';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ajándék neked',
      one: 'Egy ajándék neked',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 hónap',
      '12': '1 év',
      'other': '$months hónap',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining maradék',
      one: '1 maradék',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration a FitCheck Pro-ból';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender küldött neked $duration Hónapot a FitCheck Pro-hoz. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'FitCheck Pro ajándék $recipient számára';
  }

  @override
  String giftFromSender(String sender) {
    return 'Ezt küldte: $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Ehhez: $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Eztől: $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'a címzette';

  @override
  String get giftPreviewPlaceholderSender => 'te';

  @override
  String get settingsSavedTitle => 'Mentve';

  @override
  String get settingsNotSavedTitle => 'Nem mentve';

  @override
  String get settingsAiChooseProviderBody => 'Válassz egy szolgáltatót.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'A személyre szabott szolgáltatóhoz API URL szükséges.';

  @override
  String get settingsAiKeyRequiredBody => 'Adj meg egy API-kulcsot.';

  @override
  String get settingsAiSavedBody => 'Az AI beállításaid mentve lettek.';

  @override
  String get settingsAiMissingDetailsTitle => 'Hiányzó adatok';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Add meg az API URL-t és egy chat-modellt a teszteléshez.';

  @override
  String get settingsAiKeyNeededTitle => 'API-kulcs szükséges';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Add meg az API-kulcsodat a teszteléshez. A mentett kulcsod privát marad.';

  @override
  String get settingsAiKeyToTestBody =>
      'Add meg az API-kulcsodat a teszteléshez.';

  @override
  String get settingsAiConnectedTitle => 'Kapcsolódva';

  @override
  String get settingsAiConnectedBody => 'A kapcsolat működik.';

  @override
  String get settingsAiTestFailedTitle => 'Sikertelen teszt';

  @override
  String get settingsPreferencesSavedBody => 'Beállításaid mentve lettek.';

  @override
  String get settingsPasswordNotChangedTitle => 'A jelszó nem változott';

  @override
  String get settingsOAuthPasswordBody =>
      'Ezen a fiókhoz Google vagy Apple belépés van beállítva. Használd az „Elfelejtett jelszó” opciót, és állíts be először jelszót.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'A jelenlegi jelszó nem megfelelő.';

  @override
  String get settingsExportReadyTitle => 'Készítési export elkészült';

  @override
  String get settingsExportReadyBody =>
      'Az adataid exportálása letöltésre kész.';

  @override
  String get settingsLinkCopiedTitle => 'Link másolva';

  @override
  String get settingsExportClipboardBody =>
      'Nem tudtuk megnyitni a böngésződet, ezért bemásoltuk a letöltési linket. Illeszd be egy böngészőbe hamarosan: lejár.';

  @override
  String get settingsExportFailedTitle => 'Kilépési hiba';

  @override
  String get settingsAccountNotDeletedTitle => 'A fiók nem törlődött';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Legfeljebb $max fotót tölthetsz fel.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Fotó limit';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Add hozzá legalább egy fotót.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Nincs kiválasztva fotó';

  @override
  String get photoshootDescribeLookBody => 'Írd le a kívánt hangulatot.';

  @override
  String get photoshootPromptNeededTitle => 'Leírás szükséges';

  @override
  String get photoshootConsentFeatureLabel => 'AI fotós';

  @override
  String get photoshootStatusPreparing => 'Fotóid előkészítése';

  @override
  String get photoshootStatusGenerating => 'Generálás';

  @override
  String photoshootStatusBatch(int current, int total) {
    return '$current / $total batch';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done / $total kész';
  }

  @override
  String get photoshootGenerationFailedBody => 'A generálás sikertelen volt.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready kész, $failed sikertelen.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Részben kész';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotó kész.',
      one: '1 fotó kész.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Elveszett a kapcsolat. Kérjük, próbáld újra.';

  @override
  String get photoshootCouldNotCancelTitle => 'Nem tudtuk megemelni';

  @override
  String get photoshootRetryFailedTitle => 'A próba sikertelen';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'A(z) $number számú fotó kész.';
  }

  @override
  String get photoshootReplacedTitle => 'Cserélve';

  @override
  String get photoshootSavedToGalleryBody => 'Elmentve a galériádba.';

  @override
  String get photoshootSavedTitle => 'Elmentve';

  @override
  String get photoshootNotSavedTitle => 'Nem mentett el';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minden $count fotó a galériádban van.',
      one: '1 fotó került a galériádba.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved/$total mentve.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Néhány fotó nem mentett el';

  @override
  String get tryonConsentFeatureLabel => 'Virtuális próbavételi';

  @override
  String get tryonAvatarUpdatedBody => 'A fotód frissült.';

  @override
  String get tryonSavedTitle => 'Elmentve';

  @override
  String get tryonUploadFailedTitle => 'Sikertelen feltöltés';

  @override
  String get tryonChooseGarmentFirstBody => 'Először válassz egy ruha-fotót.';

  @override
  String get tryonNoGarmentTitle => 'Nincs ruha';

  @override
  String get tryonWaitForUploadBody => 'Várj, amíg befejeződik a feltöltés.';

  @override
  String get tryonStillUploadingTitle => 'Feltöltés folyamatban';

  @override
  String get tryonAddYourPhotoFirstBody => 'Először adj hozzá egy saját fotót.';

  @override
  String get tryonReadyBody => 'A próbavételi készen áll.';

  @override
  String get tryonFailedTitle => 'A próbavételi sikertelen';

  @override
  String get tryonSavedToGalleryBody => 'Elmentve a galériádba.';

  @override
  String get tryonNotSavedTitle => 'Nem mentett el';

  @override
  String get calendarEventAddedBody => 'Esemény hozzáadva';

  @override
  String get calendarEventPlannedTitle => 'Tervezve';

  @override
  String get calendarEventSavedBody => 'Esemény mentve';

  @override
  String get calendarSavedTitle => 'Elmentve';

  @override
  String get calendarEventNotSavedTitle => 'Az eseményt nem mentettük el';

  @override
  String get calendarEventRemovedBody => 'Esemény eltávolítva';

  @override
  String get calendarEventDeletedTitle => 'Törölve';

  @override
  String get calendarEventNotDeletedTitle => 'Az esemény nem törlődött';

  @override
  String get calendarOutfitNotLinkedTitle => 'A kombináció nem kapcsolódott';

  @override
  String get calendarLinkedTitle => 'Kapcsolódva';

  @override
  String get calendarOutfitNotRemovedTitle => 'A kombináció nem távolítható el';

  @override
  String get calendarOutfitRemovedBody => 'Kombináció eltávolítva';

  @override
  String get calendarDisconnectedBody => 'Naptár szétválasztva';

  @override
  String get calendarDisconnectedTitle => 'Szétválasztva';

  @override
  String get calendarNotDisconnectedTitle => 'A naptár nem válik szét';

  @override
  String get calendarTodayLabel => 'ma';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esemény',
      one: '1 esemény',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start és $end között';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, kombináció csatolva';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return 'A(z) „$title” törlésre kerül.';
  }

  @override
  String get calendarThisAppLabel => 'Ez az alkalmazás';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'A(z) $provider szinkronizálása még nem elérhető. Eseményeket itt továbbra is hozzáadhatsz.';
  }

  @override
  String get calendarWeekdaySunShort => 'V';

  @override
  String get calendarWeekdayMonShort => 'H';

  @override
  String get calendarWeekdayTueShort => 'Ke';

  @override
  String get calendarWeekdayWedShort => 'Sze';

  @override
  String get calendarWeekdayThuShort => 'Cs';

  @override
  String get calendarWeekdayFriShort => 'P';

  @override
  String get calendarWeekdaySatShort => 'Szo';

  @override
  String get calendarWeekdayMonday => 'Hétfő';

  @override
  String get calendarWeekdayTuesday => 'Kedd';

  @override
  String get calendarWeekdayWednesday => 'Szerda';

  @override
  String get calendarWeekdayThursday => 'Csütörtök';

  @override
  String get calendarWeekdayFriday => 'Péntek';

  @override
  String get calendarWeekdaySaturday => 'Szombat';

  @override
  String get calendarWeekdaySunday => 'Vasárnap';

  @override
  String get outfitSavedToFavouritesBody => 'Hozzáadva a kedvencekhez';

  @override
  String get outfitRemovedFromFavouritesBody => 'Eltávolítva a kedvencekből';

  @override
  String get outfitNotSavedTitle => 'Nem mentve';

  @override
  String get outfitLoggedAsWornBody => 'Megjelölve viseltként ma.';

  @override
  String get outfitNicePickTitle => 'Szuper választás';

  @override
  String get outfitRemovedBody => 'Az öltöny eltávolítva.';

  @override
  String get outfitDeletedTitle => 'Törölve';

  @override
  String get outfitNotDeletedTitle => 'Nem törölve';

  @override
  String get outfitDuplicatedBody => 'Egy másolat a ruhatáradban.';

  @override
  String get outfitDuplicatedTitle => 'Másolva';

  @override
  String get outfitNotDuplicatedTitle => 'Nem másolva';

  @override
  String get outfitNotSharedTitle => 'Nem megosztva';

  @override
  String outfitCollectionReadyBody(String name) {
    return '„$name” kész.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Gyűjtemény nem létrehozva';

  @override
  String get outfitCollectionUpdatedBody => 'Gyűjtemény frissítve.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Gyűjtemény nem frissítve';

  @override
  String get outfitCollectionDeletedBody => 'Gyűjtemény törölve.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Gyűjtemény nem törölve';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öltöny hozzáadva.',
      one: '1 öltöny hozzáadva.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Öltönyök nem hozzáadva';

  @override
  String get outfitPreviewNotCreatedTitle => 'Előnézet nem létrehozva';

  @override
  String get outfitGiveNameBody => 'Nevezd el az öltönyöt.';

  @override
  String get outfitNameMissingTitle => 'Név';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Válassz legalább egy darabot.';

  @override
  String outfitCreatedBody(String name) {
    return 'A(z) $name az öltönyeid között.';
  }

  @override
  String get outfitSavedTitle => 'Mentve';

  @override
  String get wardrobeAddedToFavouritesBody => 'Hozzáadva a kedvencekhez';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Eltávolítva a kedvencekből';

  @override
  String get wardrobeNotSavedTitle => 'Nem mentve';

  @override
  String get wardrobeLoggedAsWornBody => 'Ma viszként rögzítve.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Eltávolítva a szekrényedből.';

  @override
  String get wardrobeDeletedTitle => 'Törölve';

  @override
  String get wardrobeNotDeletedTitle => 'Nem törölve';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darab eltávolítva a szekrényedből.',
      one: '1 darab eltávolítva a szekrényedből.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI alapú ruhafelismerés';

  @override
  String get itemAddScanJobLabel => 'Képeszköb';

  @override
  String get itemAddFoundEarlierBody => 'Korábbi szkennálásnál talált';

  @override
  String get itemAddLookingAtPhoto => 'A fotód áttekintése';

  @override
  String get itemAddExtractionFailedBody => 'A felismerés sikertelen';

  @override
  String get itemAddJobFailedBody => 'Sikertelen művelet';

  @override
  String get itemAddConnectionLostBody => 'Elment a kapcsolat. Próbáld újra.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Elment a kapcsolat a feldolgozás közben.';

  @override
  String itemAddGeneratingPiece(int number) {
    return '$number. darab';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Darab';

  @override
  String get itemAddNotCancelledTitle => 'Nem történt meg';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darab most a szekrényedben van.',
      one: '1 darab most a szekrényedben van.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved / $total darab mentve. Nyomd meg a mentést a többihez is.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Nem mentett darabok';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Válassz legalább egy fotót.';

  @override
  String get batchPhotoUnreadableBody => 'Ezt a fotót nem lehet beolvasni.';

  @override
  String get batchNoPhotosReadableBody =>
      'Ezeket a fotókat nem lehet beolvasni. Próbálj másokat.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotó',
      one: '1 fotó',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Működés közben elveszett a kapcsolat. Próbáld újra.';

  @override
  String get batchNotCancelledTitle => 'Nem történt meg';

  @override
  String get batchPostLinkUnsupportedBody =>
      'A bejegyzési linkek nem támogatottak. Adj meg egy profillinket.';

  @override
  String get batchLinkSpacesBody => 'A linkek nem tartalmazhatnak szóközt.';

  @override
  String get batchEnterProfileLinkBody =>
      'Adj meg egy Instagram vagy Facebook profillinket.';

  @override
  String get batchEnterProfileLinkShortBody => 'Adj meg egy profillinket.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Nem nyitott meg a bejelentkező oldal. Próbáld újra.';

  @override
  String get batchSignInBrowserBody =>
      'Jelkezz be a böngészőben, majd térj vissza a FitCheckhez.';

  @override
  String get batchConnectAccountTitle => 'Fiók bekötése';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Add meg az autentikátor-alkalmazásból származó kódot.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Az Instagram biztonsági ellenőrzést kér. Előbb jelentkezz be a böngészőben.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Add meg újra a felhasználónevedet és jelszavadat.';

  @override
  String get batchSignInFailedBody =>
      'A bejelentkezés sikertelen. Ellenőrizd a felhasználónevedet és jelszavadat.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Jelentkezz be az importálás folytatásához.';

  @override
  String get batchAccountNotConnectedBody => 'A fiók nem kapcsolódott be.';

  @override
  String get batchAccountConnectedTitle => 'Fiók bekötve';

  @override
  String get batchNotConnectedTitle => 'Nincs kapcsolat';

  @override
  String get batchImportConnectionLostBody =>
      'Elveszett a kapcsolódás az importtal. Frissítsd az ellenőrzéshez.';

  @override
  String batchPickUpToBody(int max) {
    return 'Válassz ki legfeljebb $max fotót. Mi megtaláljuk a darabokat.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count / $total fotó';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Készítem a $done / $count fotót';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Darabok keresése $count fotón',
      one: 'Darabok keresése 1 fotón',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'A $platform fiókja kétlépcsős bejelentkezést használ. Add meg a 6 számjegyű kódot az autentikátorból.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Ez a $platform profil privát vagy bejelentkezést igényel a fotók megjelenítéséhez.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Kapcsolódás $platform fiókkal';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotó található eddig',
      one: '1 fotó található eddig',
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
    return '$processed / $total feldolgozva · $added hozzáadva · $waiting várakozik · $skipped kihagyva';
  }

  @override
  String batchScanningPhoto(int number) {
    return '$number fotó szkennálása';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Következik: $number fotó';
  }

  @override
  String batchPhotoLabel(int number) {
    return '$number fotó';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darab található',
      one: '1 darab található',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotó került a gardróbozodba.',
      one: '1 fotó került a gardróbozodba.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count stúdiófotó úton van. Mentheted, ami kész, vagy elhagyhatsz — értesítünk.',
      one:
          '1 stúdiófotó úton van. Mentheted, ami kész, vagy elhagyhatsz — értesítünk.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Nem mentve: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces darab',
      one: '1 darab',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotóból',
      one: '1 fotóból',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen kiválasztva. Érints meg a darabot a kihagyásához.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darab mentése',
      one: '1 darab mentése',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darab mentése',
      one: '1 darab mentése',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'A testprofilod elmentettük.';

  @override
  String get bodyProfileSavedTitle => 'Mentve';

  @override
  String get bodyProfileNotSavedTitle => 'Nem mentve';

  @override
  String get bodyProfileSetDefaultBody =>
      'Alapértelmezett profilként beállítva.';

  @override
  String get bodyProfileDeletedBody => 'Testprofil törölve.';

  @override
  String get bodyProfileDeletedTitle => 'Törlve';

  @override
  String get bodyProfileNotDeletedTitle => 'Nem törlve';

  @override
  String get feedbackNotSentTitle => 'Nem küldve';

  @override
  String get feedbackSentBody =>
      'Köszönjük! Minden üzenetet elolvassunk, és válaszolunk, ha kell.';

  @override
  String get feedbackSentTitle => 'Visszajelzés küldve';

  @override
  String get recommendUnnamedPiece => 'Nevetlen darab';

  @override
  String get recommendEnterCityBody =>
      'Add meg a városodat a időjárási ajánlásokhoz.';

  @override
  String get recommendWhichCityTitle => 'Melyik város?';

  @override
  String get aiConsentSheetTitle => 'Fotók megosztása AI szolgáltatással';

  @override
  String get aiConsentSheetBody =>
      'A próbafoto és fotószesszió képek elkészítéséhez a FitCheck AI a feltöltött fotóidat (beleértve az arcod és tested képét) egy megbízható harmadik féltől származó AI-szolgáltatóhoz (pl. OpenAI vagy Google Gemini) küldi feldolgozásra. Ők generálják a képeidet, és a feltételeink szerint nem használják a modelljük oktatására. A fotók biztonságosan kerülnek továbbításra, és soha nem használják őket hirdetésekre.';

  @override
  String get aiConsentSheetPermission =>
      'Folytatásoddal kifejezetten engedélyt adsz a fotóid megosztására ezek az AI-szolgáltatókkal képgenerálási célból.';

  @override
  String get skeletonsLoadMoreFailed => 'Nem sikerült többet betölteni.';

  @override
  String get jobsPiecesReadyTitle => 'Kész a darabjaid';

  @override
  String get jobsScanStoppedTitle => 'Megállt a szkennelés';

  @override
  String get jobsNothingSavedBody => 'Semmi sem mentett. Próbáld újra.';

  @override
  String get jobsPhotoUploadFailedBody => 'Sikertelen fotófeltöltés.';

  @override
  String get authGoogleSignInStartFailed =>
      'Nem sikerült elindítani a Google-bejelentkezést. Próbáld újra.';

  @override
  String get referralAppliedTitle => 'Utalás érvényesítve!';

  @override
  String get billingStoreUnavailableBody =>
      'Ezen az eszközön nem lehet vásárolni az App Store-ban.';

  @override
  String get billingPurchaseProcessingBody =>
      'Ez a vásárlás még feldolgozás alatt van. Nyisd újra az alkalmazást egy perc múlva a csomagod megtekintéséhez.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Az avatár feltöltése nem adott vissza kép-URL-t.';

  @override
  String get rewardsDayStreakLabel => 'napos széria';

  @override
  String rewardsBestStreak(int days) {
    return 'Legjobb $days nap';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission hozzáférés szükséges';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'A(z) $permission hozzáférés jelenleg meg van vonva. Nyisd meg a Beállításokat, hogy engedélyezd, majd térj vissza és próbáld újra.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '$step. lépés a 4-ből';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '$step. lépés $total alapján';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '$index képkijelölés törlése';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '$index képkijelölés törlése';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points p';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Küldj e-mailt erre: $email. Jelentéseinket 24 órán belül felülvizsgáljuk.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece eltávolítása';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Törlöd a(z) „$name”-t?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Hozzáadás a(z) „$name”-hoz';
  }

  @override
  String outfitNamedRemoved(String name) {
    return 'A(z) „$name” törölve. A darabok maradnak a gardróbad.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Összes $count megjelenítése';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Ma $count maradt';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return '$index. fotó sikertelen';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected fotó $max közül';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape testalkat · $tone bőrszín';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Törlöd a(z) $name profilját?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opciók a(z) $name profilhoz';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Legjobban viselt: $name, $count alkalommal';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: nem állítva';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% egyezés';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked $max-ból kiválasztva';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item eltávolítása';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency prioritás';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Ezt a csomagot a(z) $store tartoztatja. Változtatás vagy lemondás esetén lásd a(z) $store fiókbeállításokat.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Kezelés a(z) $store-ban';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max $current felhasználva';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Kb. $seconds mp maradt';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done $total stúdiófotó kész';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready $total stúdiófotó kész. Égess egy darabot, ha át akarod ugrani.';
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
  String get profileFieldNotSet => 'Nem';
}
