// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Etusivu';

  @override
  String get tabPhotoshoot => 'Kuvaus';

  @override
  String get tabCloset => 'Vaatekaappi';

  @override
  String get tabOutfits => 'Asut';

  @override
  String get tabMore => 'Lisää';

  @override
  String get actionAddItem => 'Lisää vaate';

  @override
  String get actionCreateOutfit => 'Luo asu';

  @override
  String get actionCancel => 'Peruuta';

  @override
  String get actionDelete => 'Poista';

  @override
  String get actionSave => 'Tallenna';

  @override
  String get actionRetry => 'Yritä uudelleen';

  @override
  String get actionDone => 'Valmis';

  @override
  String get actionNext => 'Seuraava';

  @override
  String get actionBack => 'Takaisin';

  @override
  String get actionClose => 'Sulje';

  @override
  String get actionSearch => 'Hae';

  @override
  String get actionContinue => 'Jatka';

  @override
  String get stateLoading => 'Ladataan';

  @override
  String get stateErrorTitle => 'Jotain meni pieleen';

  @override
  String get stateErrorBody =>
      'Yritä uudelleen. Jos ongelma jatkuu, ota yhteyttä tukeen.';

  @override
  String get stateOfflineTitle => 'Ei verkkoyhteyttä';

  @override
  String get stateOfflineBody =>
      'Muodosta yhteys synkronoidaksesi vaatekaapin ja luodaksesi asuja.';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String get settingsAccountSection => 'Tili';

  @override
  String get settingsPreferencesSection => 'Asetukset';

  @override
  String get settingsPlanBilling => 'Tilaus ja laskutus';

  @override
  String get settingsLanguage => 'Kieli';

  @override
  String get settingsNotifications => 'Ilmoitukset';

  @override
  String get settingsUnits => 'Mitat';

  @override
  String get settingsAppearance => 'Ulkoasu';

  @override
  String get settingsPrivacySection => 'Tietosuoja ja tiedot';

  @override
  String get settingsAboutSection => 'Tietoja';

  @override
  String get settingsSignOut => 'Kirjaudu ulos';

  @override
  String get settingsDeleteAccount => 'Poista tili';

  @override
  String get settingsDeleteAccountTitle => 'Haluatko poistaa tilisi?';

  @override
  String get settingsDeleteAccountBody =>
      'Tämä poistaa vaatekaappisi, asusi, kuvasi ja profiilisi. Toimintoa ei voi kumota.';

  @override
  String get settingsUnitsImperial => 'Brittiläiset (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metriset (cm, kg)';

  @override
  String get languageTitle => 'Kieli';

  @override
  String get languageSystem => 'Käytä laitteen kieltä';

  @override
  String get languageSystemBody => 'FitCheck AI noudattaa puhelimesi kieltä.';

  @override
  String get languageSearchHint => 'Hae kieliä';

  @override
  String get languageCurrent => 'Nykyinen';

  @override
  String get languageReviewNote =>
      'Tämä käännös on uusi. Kerro meille, jos jokin kuulostaa oudolta.';

  @override
  String get languageChanged => 'Kieli päivitetty';

  @override
  String get paywallTitle => 'Valitse tilaus';

  @override
  String get paywallTrialBadge => '1 kuukausi ilmaiseksi';

  @override
  String get paywallTrialTitle =>
      'Ensimmäinen kuukausi Pro-versiota on ilmainen';

  @override
  String get paywallTrialBody =>
      'Lataa koko vaatekaappisi kerralla. Lisää vaatteita myöhemmin tarpeen mukaan.';

  @override
  String get paywallFreeForeverTitle => 'Ilmainen ikuisesti';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Ei korttitietoja. Saat joka kuukausi $uploads tekoälylatausta, $outfits asua ja $images studiokuvaa päivässä.';
  }

  @override
  String get paywallCtaTrial => 'Aloita ilmainen kuukausi';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Päivitä tilaukseen $plan';
  }

  @override
  String get paywallRestore => 'Palauta ostokset';

  @override
  String get paywallManage => 'Hallinnoi tilausta';

  @override
  String get paywallTerms => 'Käyttöehdot';

  @override
  String get paywallPrivacy => 'Tietosuojakäytäntö';

  @override
  String get paywallPerMonth => 'kuukaudessa';

  @override
  String get paywallPerYear => 'vuodessa';

  @override
  String get paywallBestValue => 'Paras arvo';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Ilmainen kokeilujakso vain uusille tilaajille. Kokeilujakson jälkeen Pro uusiutuu hintaan $price, ellei sitä peruuteta vähintään 24 tuntia ennen jakson päättymistä.';
  }

  @override
  String get introTitle => 'Vaatekaappisi, vihdoin järjestyksessä';

  @override
  String get introBody =>
      'Kuvaa vaatteesi kerran. Saat asuideoita, sovituskuvia ja studiokuvia omista vaatteistasi.';

  @override
  String get introStart => 'Aloita';

  @override
  String get introHaveAccount => 'Minulla on jo tili';

  @override
  String get introSkip => 'Ohita';

  @override
  String get authSignIn => 'Kirjaudu sisään';

  @override
  String get authSignUp => 'Luo tili';

  @override
  String get authEmail => 'Sähköposti';

  @override
  String get authPassword => 'Salasana';

  @override
  String get authForgotPassword => 'Unohditko salasanan?';

  @override
  String get authContinueApple => 'Jatka Applella';

  @override
  String get authContinueGoogle => 'Jatka Googlella';

  @override
  String get authOrDivider => 'tai';

  @override
  String get wardrobeTitle => 'Vaatekaappi';

  @override
  String get wardrobeEmptyTitle => 'Vaatekaappisi on tyhjä';

  @override
  String get wardrobeEmptyBody =>
      'Lisää ensimmäinen vaate tai lataa kuva koko tangosta kerralla.';

  @override
  String get wardrobeAddFirst => 'Lisää ensimmäinen vaate';

  @override
  String get wardrobeSearchHint => 'Hae vaatekaapista';

  @override
  String get categoryTops => 'Yläosat';

  @override
  String get categoryBottoms => 'Alaosat';

  @override
  String get categoryShoes => 'Kengät';

  @override
  String get categoryAccessories => 'Asusteet';

  @override
  String get categoryOuterwear => 'Ulkoasut';

  @override
  String get categorySwimwear => 'Uima-asut';

  @override
  String get categoryActivewear => 'Urheiluvaatteet';

  @override
  String get categoryOther => 'Muut';

  @override
  String get conditionClean => 'Puhdas';

  @override
  String get conditionDirty => 'Likainen';

  @override
  String get conditionLaundry => 'Pesussa';

  @override
  String get conditionRepair => 'Korjattava';

  @override
  String get conditionDonate => 'Lahjoitettava';

  @override
  String get seasonSpring => 'Kevät';

  @override
  String get seasonSummer => 'Kesä';

  @override
  String get seasonFall => 'Syksy';

  @override
  String get seasonWinter => 'Talvi';

  @override
  String get seasonAll => 'Kaikki kaudet';

  @override
  String get styleCasual => 'Arkityyli';

  @override
  String get styleFormal => 'Juhla';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Urheilullinen';

  @override
  String get styleBohemian => 'Boheemi';

  @override
  String get styleStreetwear => 'Katumuoti';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistinen';

  @override
  String get styleRomantic => 'Romanttinen';

  @override
  String get styleEdgy => 'Roju';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Taiteellinen';

  @override
  String get styleClassic => 'Klassinen';

  @override
  String get styleElegant => 'Tyylikäs';

  @override
  String get styleOther => 'Muu';

  @override
  String get occasionWork => 'Työ';

  @override
  String get occasionDateNight => 'Treffit';

  @override
  String get occasionTravel => 'Matka';

  @override
  String get occasionWedding => 'Häät';

  @override
  String get occasionGym => 'Kuntosali';

  @override
  String get occasionWeekend => 'Viikonloppu';

  @override
  String get occasionParty => 'Juhlat';

  @override
  String get occasionInterview => 'Haastattelu';

  @override
  String get colorBlack => 'Musta';

  @override
  String get colorWhite => 'Valkoinen';

  @override
  String get colorGrey => 'Harmaa';

  @override
  String get colorNavy => 'Laivastonsininen';

  @override
  String get colorBrown => 'Ruskea';

  @override
  String get colorRed => 'Punainen';

  @override
  String get colorBlue => 'Sininen';

  @override
  String get colorGreen => 'Vihreä';

  @override
  String get colorPink => 'Vaaleanpunainen';

  @override
  String get colorPurple => 'Violetti';

  @override
  String get colorYellow => 'Keltainen';

  @override
  String get colorOrange => 'Oranssi';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Tänään';

  @override
  String get dateYesterday => 'Eilen';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count päivää sitten',
      one: '1 päivä sitten',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viikkoa sitten',
      one: '1 viikko sitten',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kuukautta sitten',
      one: '1 kuukausi sitten',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vuotta sitten',
      one: '1 vuosi sitten',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Pidätkö FitCheck AI -sovelluksesta?';

  @override
  String get ratingPromptBody => 'Nopea arvio auttaa muita löytämään tyylinsä.';

  @override
  String get ratingPromptYes => 'Arvioi sovellus';

  @override
  String get ratingPromptNo => 'Ei nyt';

  @override
  String get closetNoMatchesTitle => 'Ei osumia';

  @override
  String get closetNoMatchesBody =>
      'Kokeile vähemmän suodattimia tai toista hakua.';

  @override
  String get closetClearFilters => 'Tyhjennä suodattimet';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vaatetta',
      one: '1 vaate',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Ladataan vaatteitasi';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valittua',
      one: '1 valittu',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Poista valitut';

  @override
  String get closetCancelSelection => 'Peruuta valinta';

  @override
  String get closetCloseSearch => 'Sulje haku';

  @override
  String get closetShowGrid => 'Näytä ruudukkona';

  @override
  String get closetShowList => 'Näytä luettelona';

  @override
  String get closetShowRows => 'Näytä riveinä';

  @override
  String get closetStatsTitle => 'Vaatekaapin tilastot';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poistetaanko $count vaatetta?',
      one: 'Poistetaanko 1 vaate?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Nämä vaatteet poistetaan niitä käyttävistä asuista.';

  @override
  String get closetSortBy => 'Järjestä';

  @override
  String get closetFavourites => 'Suosikit';

  @override
  String get closetFavourite => 'Suosikki';

  @override
  String get closetUnfavourite => 'Poista suosikeista';

  @override
  String get closetWoreToday => 'Käytin tänään';

  @override
  String closetWornTimes(int count) {
    return 'Käytetty $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategoria';

  @override
  String get closetUseCaseLabel => 'Käyttötarkoitus';

  @override
  String get closetAnyUseCase => 'Kaikki';

  @override
  String get closetOtherUseCase => 'Muu käyttötarkoitus';

  @override
  String get closetOtherUseCaseHint => 'Esimerkiksi brunssi';

  @override
  String get closetUseUseCase => 'Käytä tätä';

  @override
  String get closetClearAll => 'Tyhjennä kaikki';

  @override
  String get sortNewest => 'Uusin ensin';

  @override
  String get sortOldest => 'Vanhin ensin';

  @override
  String get sortName => 'Nimi (A–Ö)';

  @override
  String get sortMostWorn => 'Eniten käytetty';

  @override
  String get useCaseInformal => 'Arki';

  @override
  String get useCaseDate => 'Treffit';

  @override
  String get useCaseDinner => 'Illallinen';

  @override
  String get useCaseLunch => 'Lounas';

  @override
  String get actionSelect => 'Valitse';

  @override
  String get actionEdit => 'Muokkaa';

  @override
  String get actionFilter => 'Suodata';

  @override
  String get actionSort => 'Järjestä';

  @override
  String get actionAll => 'Kaikki';

  @override
  String get dashboardStartClosetTitle => 'Aloita vaatekaappi';

  @override
  String get dashboardStartClosetBody =>
      'Kuvaa muutama vaate. Merkitsemme ne puolestasi.';

  @override
  String get dashboardPieces => 'vaatetta';

  @override
  String get dashboardOutfits => 'asua';

  @override
  String get dashboardDayStreak => 'päivän putki';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count tässä kuussa';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Paras $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suosikkia',
      one: '1 suosikki',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tallennettua asua',
      one: '1 tallennettu asu',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Eniten käytetty: $name, $count kertaa';
  }

  @override
  String get setupSkip => 'Ohita asennus';

  @override
  String get setupWhoTitle => 'Ketä stailataan?';

  @override
  String get setupWhoBody =>
      'Määrittää mallin sovitusta ja kuvauksia varten. Voit vaihtaa sen profiilissasi.';

  @override
  String get setupStyleTitle => 'Mitä käytät eniten?';

  @override
  String get setupStyleBody =>
      'Valitse haluamasi. Asuideat saavat alkunsa näistä.';

  @override
  String get setupClosetTitle => 'Lisää ensimmäiset vaatteesi.';

  @override
  String get setupClosetBody =>
      'Valokuvaa muutama vaate tai kasa vaatteita. Jokainen kappale rajataan ja arkistoidaan puolestasi.';

  @override
  String get setupAddClothes => 'Lisää vaatteita';

  @override
  String get setupStylesLabel => 'Tyylit';

  @override
  String get setupOccasionsLabel => 'Tilaisuudet';

  @override
  String get setupSkipStep => 'Ohita';

  @override
  String get setupLater => 'Myöhemmin';

  @override
  String get setupSaveError => 'Tallennus epäonnistui';

  @override
  String get genderWomen => 'Naiset';

  @override
  String get genderMen => 'Miehet';

  @override
  String get genderNonBinary => 'Muunsukupuolinen';

  @override
  String get genderPreferNotToSay => 'En halua sanoa';

  @override
  String get outfitEmptyTitle => 'Ei asuja vielä';

  @override
  String get outfitEmptyBody =>
      'Yhdistele vaatekaappisi kappaleita ja tallenna asu.';

  @override
  String get outfitNoMatchesTitle => 'Ei vastaavia asuja';

  @override
  String get outfitSearchHint => 'Hae asuistasi';

  @override
  String get outfitLoading => 'Ladataan asujasi';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asua',
      one: '1 asu',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Tyyli ja sesonki';

  @override
  String get outfitCollections => 'Kokoelmat';

  @override
  String get outfitDuplicate => 'Monista';

  @override
  String get outfitDeleteTitle => 'Poistetaanko tämä asu?';

  @override
  String get outfitDeleteBody => 'Sen vaatteet pysyvät vaatekaapissasi.';

  @override
  String get outfitDrafts => 'Luonnokset';

  @override
  String get outfitDraft => 'Luonnos';

  @override
  String get filterStyle => 'Tyyli';

  @override
  String get filterSeason => 'Kausi';

  @override
  String get itemDetailDeleteTitle => 'Poistetaanko tämä vaate?';

  @override
  String get itemDetailDeleteBody =>
      'Tätä vaatetta käyttävät asut menettävät sen.';

  @override
  String get itemAddFavourite => 'Lisää suosikkeihin';

  @override
  String itemSize(String size) {
    return 'Koko $size';
  }

  @override
  String get itemColours => 'Värit';

  @override
  String get itemMaterial => 'Materiaali';

  @override
  String get itemPattern => 'Kuvio';

  @override
  String get itemUseCases => 'Käyttötarkoitukset';

  @override
  String get itemKeptIn => 'Sijainti';

  @override
  String get itemPrice => 'Hinta';

  @override
  String get itemBought => 'Ostettu';

  @override
  String get itemTags => 'Tunnisteet';

  @override
  String get itemAdded => 'Lisätty';

  @override
  String get itemTimesWornLabel => 'käyttökertaa';

  @override
  String get itemLastWornLabel => 'käytetty viimeksi';

  @override
  String get itemNeverWorn => 'Ei kertaakaan';

  @override
  String get authEntryBody =>
      'Jokainen vaatteesi tekoälyn tyylittelemänä. Suunnittele asut, sovita ja kuvaa.';

  @override
  String get authCreateCloset => 'Luo vaatekaappisi';

  @override
  String get authWelcomeBack => 'Tervetuloa takaisin';

  @override
  String get authSignInBody => 'Kirjaudu sisään avataksesi vaatekaappisi.';

  @override
  String get authCreateAccount => 'Luo tili';

  @override
  String get authCreateClosetBody =>
      'Vievän vain hetken. Ensimmäiset tuotteesi ovat ilmaisia.';

  @override
  String get authName => 'Nimi';

  @override
  String get authConfirmPassword => 'Vahvista salasana';

  @override
  String get authReferralCode => 'Kutsukoodi (valinnainen)';

  @override
  String get authResetTitle => 'Palauta salasanasi';

  @override
  String get authResetBody =>
      'Lähetämme sähköpostiisi linkin uuden salasanan luomiseksi.';

  @override
  String get authSendResetLink => 'Lähetä palautuslinkki';

  @override
  String get authBackToSignIn => 'Takaisin kirjautumiseen';

  @override
  String get authEnterEmail => 'Kirjoita sähköpostiosoitteesi';

  @override
  String get authEnterValidEmail => 'Kirjoita kelvollinen sähköpostiosoite';

  @override
  String get authEnterPassword => 'Kirjoita salasanasi';

  @override
  String get authPasswordTooShort => 'Vähintään 6 merkkiä';

  @override
  String get authShowPassword => 'Näytä salasana';

  @override
  String get authHidePassword => 'Piilota salasana';

  @override
  String get authNewHere => 'Uusi täällä?';

  @override
  String authConfirmEmail(String email) {
    return 'Vahvista $email ennen sisäänkirjautumista. Tarkista postilaatikkosi.';
  }

  @override
  String get authResendEmail => 'Lähetä uudelleen';

  @override
  String get authResendingEmail => 'Lähetetään…';

  @override
  String get authPasswordsDoNotMatch => 'Salasanat eivät täsmää';

  @override
  String get authEnterName => 'Kirjoita nimesi';

  @override
  String get authChoosePassword => 'Valitse salasana';

  @override
  String get authHaveAccount => 'Onko sinulla jo tili?';

  @override
  String get authCodeAccepted => 'Koodi hyväksytty';

  @override
  String get authCodeNotFound => 'Koodia ei löytynyt';

  @override
  String authReferralFrom(String name) {
    return 'Käyttäjältä $name. Saatatte molemmat kuukauden ilmaiseksi.';
  }

  @override
  String get authReferralInvalid => 'Tätä koodia ei löytynyt.';

  @override
  String authResetSent(String email) {
    return 'Lähetetty osoitteeseen $email. Avaa linkki tällä puhelimella.';
  }

  @override
  String get introSlide1Title => 'Kuvaa vaatekaappisi kerralla.';

  @override
  String get introSlide1Body =>
      'Valokuvaa vaatepinota. Jokainen vaate rajataan ja tallennetaan puolestasi.';

  @override
  String get introSlide2Title => 'Pukeudu nopeammin.';

  @override
  String get introSlide2Body =>
      'Asuja omista vaatteistasi, sovitettuna menoihisi ja säähän.';

  @override
  String get introSlide3Title => 'Katso ennen kuin Pue.';

  @override
  String get introSlide3Body =>
      'Kokeile asuja omassa kuvassasi tai ota kampanjakuvia.';

  @override
  String get settingsTheme => 'Teema';

  @override
  String get settingsThemeSystem => 'Järjestelmä';

  @override
  String get settingsThemeLight => 'Vaalea';

  @override
  String get settingsThemeDark => 'Tumma';

  @override
  String get settingsTemperature => 'Lämpötila';

  @override
  String get settingsEmailUpdates => 'Sähköpostipäivitykset';

  @override
  String get settingsEmailUpdatesBody => 'Uutisia ja vinkkejä sähköpostitse';

  @override
  String get settingsOutfitReminders => 'Asumuistutukset';

  @override
  String get settingsOutfitRemindersBody =>
      'Muistutus päivän asun kirjaamiseen';

  @override
  String get settingsWeeklySummary => 'Viikkoyhteenveto';

  @override
  String get settingsWeeklySummaryBody => 'Viikkosi asut koottuna';

  @override
  String get settingsStyleSection => 'Tyyli';

  @override
  String get settingsPreferredStyles => 'Suosimasi tyylit';

  @override
  String get settingsPreferredColours => 'Suosimasi värit';

  @override
  String get settingsNoneChosen => 'Ei valittu';

  @override
  String get settingsPlanAiSection => 'Tilaus ja tekoäly';

  @override
  String get settingsPlanBillingBody => 'Tilaus, käyttö ja päivitykset';

  @override
  String get settingsPlanUsageBody => 'Tilaus ja käyttö';

  @override
  String get settingsInviteFriends => 'Kutsu kavereita';

  @override
  String get settingsInviteFriendsBody =>
      'Ilmainen kuukausi jokaisesta liittyvästä kaverista';

  @override
  String get settingsAiProvider => 'Tekoälyn tarjoaja';

  @override
  String get settingsAiProviderBody =>
      'Käytä omaa malliasi tunnisteisiin ja kuviin';

  @override
  String get settingsAppVersion => 'Sovelluksen versio';

  @override
  String get settingsPrivacyTerms => 'Tietosuoja ja ehdot';

  @override
  String get settingsReportProblem => 'Ilmoita ongelmasta';

  @override
  String get settingsChangePassword => 'Vaihda salasana';

  @override
  String get settingsExportData => 'Vie tietosi';

  @override
  String get settingsExportBody =>
      'Valmistelemme tiedoston kaikista tallennetuistasi ja avaamme latauksen.';

  @override
  String get settingsExportAction => 'Vie';

  @override
  String get settingsCurrentPassword => 'Nykyinen salasana';

  @override
  String get settingsNewPassword => 'Uusi salasana';

  @override
  String get settingsConfirmNewPassword => 'Vahvista uusi salasana';

  @override
  String get settingsEnterCurrentPassword => 'Kirjoita nykyinen salasanasi';

  @override
  String get settingsEnterNewPassword => 'Kirjoita uusi salasana';

  @override
  String get settingsPasswordMin8 => 'Käytä vähintään 8 merkkiä';

  @override
  String get settingsPasswordNeedsUpper => 'Lisää iso kirjain';

  @override
  String get settingsPasswordNeedsLower => 'Lisää pieni kirjain';

  @override
  String get settingsPasswordNeedsDigit => 'Lisää numero';

  @override
  String get settingsPasswordsNoMatch => 'Salasanat eivät täsmää';

  @override
  String get settingsChangeAction => 'Vaihda';

  @override
  String get itemAddSnapTitle => 'Kuvaa vaate';

  @override
  String get itemAddSnapBody =>
      'Tunnistamme kaikki kuvan vaatteet ja luomme niistä siistit tuotekuvat.';

  @override
  String get itemAddCamera => 'Ota kuva';

  @override
  String get itemAddGallery => 'Valitse galleriasta';

  @override
  String get itemAddOtherWays => 'Muut lisäystavat';

  @override
  String get itemAddSeveral => 'Lisää useita kuvia';

  @override
  String get itemAddSeveralBody => 'Enintään 50 kerralla';

  @override
  String get itemAddImportProfile => 'Tuo profiilista';

  @override
  String get itemAddImportProfileBody => 'Instagram tai Facebook';

  @override
  String get itemAddEnterDetails => 'Syötä tiedot itse';

  @override
  String get itemAddEnterDetailsBody => 'Ei vaadi kuvaa';

  @override
  String get itemManualIntro =>
      'Vain nimi vaaditaan. Lisää loput nyt tai myöhemmin.';

  @override
  String get itemManualNameHint => 'Esim. sininen puuvillapaita';

  @override
  String get itemManualEnterName => 'Kirjoita nimi';

  @override
  String get itemManualNotes => 'Muistiinpanot';

  @override
  String get itemManualBrand => 'Merkki';

  @override
  String get itemManualSize => 'Koko';

  @override
  String get itemManualEnterNumber => 'Syötä numero';

  @override
  String get itemManualSavePiece => 'Tallenna vaate';

  @override
  String get itemManualSaving => 'Tallennetaan';

  @override
  String get itemManualSavedTitle => 'Tallennettu';

  @override
  String itemManualSavedBody(String name) {
    return '$name on nyt vaatekaapissasi.';
  }

  @override
  String get itemManualNotSaved => 'Ei tallennettu';

  @override
  String get itemManualAddUseCase => 'Lisää käyttötarkoitus';

  @override
  String get itemManualAddUseCaseAction => 'Lisää käyttötarkoitus';

  @override
  String get itemPhotos => 'Kuvat';

  @override
  String get itemAddPhotos => 'Lisää kuvia';

  @override
  String get itemNoPhotoYet => 'Ei vielä kuvaa. Voit tallentaa ilmankin.';

  @override
  String get itemRemovePhoto => 'Poista kuva';

  @override
  String get itemRemovePiece => 'Poista vaate';

  @override
  String get filterConditionLabel => 'Kunto';

  @override
  String get photoshootStepPhotos => 'Kuvat';

  @override
  String get photoshootStepSetup => 'Asetukset';

  @override
  String get photoshootStepCreating => 'Luodaan';

  @override
  String get photoshootStepResults => 'Tulokset';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Vaihe $current / $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Yksi kuva epäonnistui. Yritä uudelleen alta.';

  @override
  String photoshootManyFailed(int count) {
    return '$count kuvaa epäonnistui. Yritä uudelleen.';
  }

  @override
  String get photoshootFormat => 'Muoto';

  @override
  String get photoshootHowMany => 'Montako';

  @override
  String get photoshootYourPrompt => 'Kehotteesi';

  @override
  String get photoshootPromptHint => 'Kultainen hetki katolla, pellavapaita';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Luo $count kuvaa',
      one: 'Luo 1 kuva',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kuvaa',
      one: 'kuva',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Päivän rajaa ei voitu tarkistaa.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan-tilaus: $remaining/$limit jäljellä tänään';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Ilmainen';

  @override
  String get photoshootGallery => 'Galleria';

  @override
  String get photoshootUseCamera => 'Käytä kameraa';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Poista kuva $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Kuvia ei palautunut';

  @override
  String get photoshootNoPhotosBody =>
      'Kuvaukset päättyivät ilman kuvia. Yritä uudelleen.';

  @override
  String get photoshootNewStyle => 'Uusi tyyli';

  @override
  String get photoshootNewPhotos => 'Uudet kuvat';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Avaa kuva $number';
  }

  @override
  String get photoshootReportPhoto => 'Ilmoita kuvasta';

  @override
  String get photoshootSaveToGallery => 'Tallenna galleriaan';

  @override
  String get actionUpgrade => 'Päivitä';

  @override
  String get referralLimitTitle => 'Päivän kuvat on käytetty';

  @override
  String get referralLimitBody =>
      'Ilmaiset kuvasipalautuvat huomenna. Kutsu ystävä ja saatte molemmat kuukauden Pro-tilausta ilmaiseksi.';

  @override
  String get referralLimitRefer => 'Kutsu ystävä';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Deittisovellus';

  @override
  String get photoshootUsePortfolio => 'Portfoliokuvat';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Esteettinen';

  @override
  String get photoshootUseCustom => 'Oma kehote';

  @override
  String get photoshootDescLinkedin => 'Ammattimaiset kasvokuvat';

  @override
  String get photoshootDescDating => 'Rentoutunut, lämmin ja luonnollinen';

  @override
  String get photoshootDescPortfolio => 'Muotilehtimäinen tyyli';

  @override
  String get photoshootDescInstagram => 'Lifestyle-kuvat syötteeseesi';

  @override
  String get photoshootDescAesthetic => 'Tunnelmalliset, taiteelliset ruudut';

  @override
  String get photoshootDescCustom => 'Kuvaile haluamasi tyyli';

  @override
  String get aspectSquare => 'Neliö';

  @override
  String get aspectPortrait => 'Pysty';

  @override
  String get aspectLandscape => 'Vaaka';

  @override
  String get aspectTall => 'Korkea';

  @override
  String get aspectWide => 'Leveä';

  @override
  String get tryOnAppBar => 'Virtuaalisovitus';

  @override
  String get tryOnYourPhoto => 'Oma kuva';

  @override
  String get tryOnGarment => 'Vaate';

  @override
  String get tryOnUploadingPhoto => 'Ladataan kuva';

  @override
  String get tryOnAddPhotoPrompt => 'Lisää kokovartalokuva itsestäsi';

  @override
  String get tryOnBodyPhotoHint => 'Kokovartalokuva toimii parhaiten';

  @override
  String get tryOnAddPhoto => 'Lisää kuva';

  @override
  String get tryOnChangePhoto => 'Vaihda kuva';

  @override
  String get tryOnPhotoLoadFailed => 'Kuvan lataus epäonnistui.';

  @override
  String get tryOnChooseGarment => 'Valitse vaatteen kuva';

  @override
  String get tryOnChooseOneGarment => 'Valitse yksi vaate';

  @override
  String get tryOnGarmentHint => 'Tuotekuva tai henkarikuva toimii parhaiten';

  @override
  String get tryOnChange => 'Vaihda';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Poista';

  @override
  String get tryOnLookTitle => 'Tyyli';

  @override
  String get tryOnStyle => 'Tyyli';

  @override
  String get tryOnBackground => 'Tausta';

  @override
  String get tryOnPose => 'Asento';

  @override
  String get tryOnDressingUp =>
      'Puetaan sinua. Tämä kestää noin puoli minuuttia.';

  @override
  String get tryOnEmptyResult => 'Sovitus näkyy täällä';

  @override
  String get tryOnReportImage => 'Ilmoita kuva';

  @override
  String get tryOnCreating => 'Luodaan';

  @override
  String get tryOnTryAgain => 'Yritä uudelleen';

  @override
  String get tryOnCreate => 'Luo sovitus';

  @override
  String get tryOnBackgroundStudioWhite => 'Studiovalkoinen';

  @override
  String get tryOnBackgroundStudioGrey => 'Studioharmaa';

  @override
  String get tryOnBackgroundUrban => 'Kaupunki';

  @override
  String get tryOnBackgroundNature => 'Luonto';

  @override
  String get tryOnBackgroundMinimal => 'Minimaalinen';

  @override
  String get tryOnPoseFront => 'Seisten edestä';

  @override
  String get tryOnPoseSide => 'Seisten sivulta';

  @override
  String get tryOnPoseWalking => 'Kävellen';

  @override
  String get dashboardGreetingMorning => 'Hyvää huomenta';

  @override
  String get dashboardGreetingAfternoon => 'Hyvää iltapäivää';

  @override
  String get dashboardGreetingEvening => 'Hyvää iltaa';

  @override
  String get dashboardWelcome => 'Tervetuloa';

  @override
  String get dashboardOpenProfile => 'Avaa profiili';

  @override
  String get dashboardRailToday => 'Tänään';

  @override
  String get dashboardRailRecently => 'Äskettäin';

  @override
  String get dashboardActivityEmpty => 'Uudet vaatteet ja asut näkyvät täällä.';

  @override
  String get quickAddPiece => 'Lisää vaate';

  @override
  String get quickAddPieceBody => 'Kuvaa ja merkitse';

  @override
  String get quickBuildOutfit => 'Luo asu';

  @override
  String get quickBuildOutfitBody => 'Yhdistele vaatteitasi';

  @override
  String get quickForYou => 'Sinulle';

  @override
  String get quickForYouBody => 'Päivän valinnat';

  @override
  String get quickPlanWeek => 'Suunnittele viikko';

  @override
  String get quickPlanWeekBody => 'Asut päivän mukaan';

  @override
  String get referralBannerUrgent => 'Loppumassa kesken? Kutsu kaveri.';

  @override
  String get referralBannerTitle => 'Anna kuukausi, saa kuukausi.';

  @override
  String get referralBannerBody =>
      'Sinä ja kaverisi saatte molemmat kuukauden Pro-tilausta.';

  @override
  String get referralBannerDismiss => 'Hylkää viikoksi';

  @override
  String get referralBannerShare => 'Jaa kutsu';

  @override
  String get referralBannerCopy => 'Kopioi linkki';

  @override
  String get itemEditPieceTitle => 'Muokkaa vaatetta';

  @override
  String get itemEditDescriptionLabel => 'Kuvaus';

  @override
  String get itemEditNotSaved => 'Ei tallennettu';

  @override
  String get itemEditSavedTitle => 'Tallennettu';

  @override
  String get itemEditSavedBody => 'Muutoksesi on tallennettu.';

  @override
  String get itemEditSavedStalePhotos =>
      'Tallennettu – kuvat saattavat olla vanhentuneita';

  @override
  String get itemEditRemovePieceHint => 'Poista tämä vaate tuotesivulta.';

  @override
  String get itemEditNoPhotos =>
      'Ei vielä kuvia. Lisää yksi galleriasta tai kamerasta.';

  @override
  String get itemEditKeepPhoto => 'Pidä kuva';

  @override
  String get itemEditRemoved => 'Poistettu';

  @override
  String get itemEditAddUseCaseAction => 'Lisää';

  @override
  String get statsNoStatsTitle => 'Ei vielä tilastoja';

  @override
  String get statsNoStatsBody =>
      'Lisää muutama vaate, niin vaatekaappisi jakauma näkyy täällä.';

  @override
  String get statsByCategory => 'Kategorioittain';

  @override
  String get statsTotalValue => 'kokonaisarvo';

  @override
  String get statsMostWorn => 'Eniten käytetyt';

  @override
  String get statsLeastWorn => 'Odottavat vuoroaan';

  @override
  String get statsUnnamedPiece => 'Nimetön vaate';

  @override
  String get jobsTitle => 'Skannaukset';

  @override
  String get jobsEmptyTitle => 'Ei vielä skannauksia';

  @override
  String get jobsEmptyBody =>
      'Napsauta kuva vaatteesta ja lähetä se taustalle – se jatkaa työtä täällä.';

  @override
  String get jobsNotCancelled => 'Ei peruutettu';

  @override
  String get jobsResume => 'Jatka';

  @override
  String get jobsReview => 'Tarkista';

  @override
  String get jobsStop => 'Pysäytä';

  @override
  String get jobsDismiss => 'Hylkää';

  @override
  String get reportTitle => 'Ilmoita sisällöstä';

  @override
  String reportIntro(String contentType) {
    return 'Kerro mikä tässä $contentType on vialla. Tiimimme tarkistaa jokaisen ilmoituksen.';
  }

  @override
  String get reportReasonInappropriate => 'Asiaton tai loukkaava';

  @override
  String get reportReasonNudity => 'Alastomuus tai seksuaalinen sisältö';

  @override
  String get reportReasonHarassment => 'Häirintä tai kiusaaminen';

  @override
  String get reportReasonImpersonation => 'Identiteettivarkaus';

  @override
  String get reportReasonOther => 'Muu';

  @override
  String get reportDetailsLabel => 'Lisätiedot (valinnainen)';

  @override
  String get reportSubmit => 'Lähetä ilmoitus';

  @override
  String get reportSubmittedTitle => 'Ilmoitus lähetetty';

  @override
  String get reportSubmittedBody => 'Kiitos. Tiimimme tarkistaa sisällön.';

  @override
  String get reportFailedTitle => 'Ilmoitusta ei voitu lähettää';

  @override
  String get reportFailedBody => 'Yritä uudelleen.';

  @override
  String get reportContentTryOnImage => 'AI-sovituskuva';

  @override
  String get reportContentSharedOutfit => 'jaettu asu';

  @override
  String get reportContentPhotoshootImage => 'AI-kuvauskuva';

  @override
  String get sharedOutfitTitle => 'Jaettu asu';

  @override
  String get sharedOutfitHideTooltip => 'Piilota tämä asu';

  @override
  String get sharedOutfitReportTooltip => 'Ilmianna tämä asu';

  @override
  String get sharedOutfitHideTitle => 'Piilotetaanko asu?';

  @override
  String get sharedOutfitHideBody =>
      'Se pysyy piilotettuna tällä laitteella. Voit myös ilmianna sen, jotta tiimimme voi tarkistaa ja poistaa sen.';

  @override
  String get sharedOutfitHideAction => 'Piilota';

  @override
  String get sharedOutfitHiddenInfo => 'Tämä asu ei näy enää tällä laitteella.';

  @override
  String get sharedOutfitHiddenToast => 'Asu piilotettu';

  @override
  String get sharedOutfitMissingTitle => 'Tätä asua ei enää löydy';

  @override
  String get sharedOutfitMissingBody =>
      'Se on saatettu poistaa tai linkki on virheellinen.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Piilotit tämän asun';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Jos sisältö on sopimatonta, ilmianna se kohdassa Tietosuoja ja käyttöehdot tai lähetä sähköpostia osoitteeseen $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Pidätkö tästä tyylistä?';

  @override
  String get sharedOutfitCtaBody =>
      'Luo vastaavia asuja omasta vaatekaapistasi.';

  @override
  String get sharedOutfitCtaButton => 'Hanki FitCheck AI';

  @override
  String get errorTitle => 'Virhe';

  @override
  String get errorUnknown => 'Odottamaton virhe tapahtui';

  @override
  String get errorNoConnection => 'Ei internetyhteyttä. Tarkista verkkosi.';

  @override
  String get errorTimeout => 'Aikakatkaisu. Yritä uudelleen.';

  @override
  String get errorServerError =>
      'Jotain meni pieleen päässäni. Yritä uudelleen.';

  @override
  String get errorBadGateway =>
      'Palvelimemme ei ole hetkeen tavoitettavissa. Yritä uudelleen.';

  @override
  String get errorServiceUnavailable =>
      'Palvelu on tilapäisesti poissa käytöstä. Yritä hetken kuluttua uudelleen.';

  @override
  String get errorInternalError => 'Jotain meni pieleen. Yritä uudelleen.';

  @override
  String get errorUnauthorized => 'Kirjaudu sisään jatkaaksesi.';

  @override
  String get errorForbidden => 'Sinulla ei ole käyttöoikeutta.';

  @override
  String get errorSessionExpired =>
      'Istuntosi vanheni. Kirjaudu sisään uudelleen.';

  @override
  String get errorInvalidCredentials => 'Sähköposti tai salasana on väärä.';

  @override
  String get errorTokenRefreshFailed =>
      'Istuntoa ei voitu päivittää. Kirjaudu sisään uudelleen.';

  @override
  String get errorRequestCancelled => 'Pyyntö peruutettu.';

  @override
  String get errorInvalidFormat => 'Tiedostomuotoa ei tueta.';

  @override
  String get errorFileTooLarge => 'Tiedosto on liian suuri.';

  @override
  String get errorUploadFailed => 'Lataus epäonnistui. Yritä uudelleen.';

  @override
  String get errorCacheCorrupted =>
      'Tallennetut tiedot vioittuivat ja ne on nollattu.';

  @override
  String get errorCacheNotFound => 'Mitään ei ole vielä tallennettu.';

  @override
  String get errorUserNotFound => 'Tiliä ei löytynyt.';

  @override
  String get errorItemNotFound => 'Tuotetta ei enää ole.';

  @override
  String get errorOutfitNotFound => 'Asua ei enää ole.';

  @override
  String get rewardsTitle => 'Palkinnot';

  @override
  String get rewardsNoAchievementsTitle => 'Ei saavutuksia vielä';

  @override
  String get rewardsNoAchievementsBody =>
      'Lisää vaatteita ja suunnittele asuja ansaitaksesi ensimmäisesi.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Ei vielä ketään tulostaululla';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Suunnittele asuja ansaitaksesi pisteitä ja näkyäksesi täällä.';

  @override
  String get legalViewPrivacyPolicy => 'Näytä tietosuojakäytäntö';

  @override
  String get aiConsentAgree => 'Hyväksyn ja jatkan';

  @override
  String get aiConsentNotNow => 'Ei nyt';

  @override
  String get imageViewerCloseTooltip => 'Sulje kuvankatselu';

  @override
  String get updateReadyTitle => 'Päivitys valmiina';

  @override
  String get updateReadyBody =>
      'Käynnistä FitCheck AI uudelleen ottaaksesi käyttöön viimeisimmät parannukset.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI tarvitsee kameran käyttöoikeuden ottaakseen valokuvia asuistasi ja vaatekaappisi tuotteista.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI tarvitsee pääsyn kuvakirjastoon valitakseen kuvia asuistasi ja vaatekaappisi tuotteista.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI tarvitsee luvan tallentaa tekoälyllä luodut asukuvat kuvakirjastoosi.';

  @override
  String get wardrobeSomePhotosSkipped => 'Joitakin kuvia ohitettiin';

  @override
  String get wardrobePhotosNotAdded => 'Kuvia ei lisätty';

  @override
  String get wardrobePhotoNotAdded => 'Kuvaa ei lisätty';

  @override
  String get wardrobeNotStartedTitle => 'Ei aloitettu';

  @override
  String get wardrobeNoRoomTitle => 'Ei tilaa';

  @override
  String get wardrobeAddPhotosSemantic => 'Lisää kuvia';

  @override
  String get batchAddTileLabel => 'Lisää';

  @override
  String get batchProfileLinkLabel => 'Profiililinkki';

  @override
  String get wardrobeImportFromProfileTitle => 'Tuo profiilista';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Lisää useita kuvia';

  @override
  String get wardrobeClearAction => 'Tyhjennä';

  @override
  String get wardrobeRefreshTooltip => 'Päivitä';

  @override
  String get batchNoPhotosYetTitle => 'Ei vielä kuvia';

  @override
  String get batchChoosePhotosAction => 'Valitse kuvat';

  @override
  String get batchWeFindEachPieceBody =>
      'Tunnistamme jokaisen vaatekappaleen ja teemme siitä studiokuvan.';

  @override
  String get batchPreparingPhotosSemantic => 'Valmistellaan kuvia';

  @override
  String get batchPhotosProcessedSemantic => 'Kuvat käsitelty';

  @override
  String get batchPasteProfileLinkTitle => 'Liitä profiililinkki';

  @override
  String get batchPasteProfileLinkBody =>
      'Julkinen Instagram- tai Facebook-profiili. Skannaamme sen kuvat, ja sinä valitset kaappiisi tulevat.';

  @override
  String get batchClearLinkTooltip => 'Tyhjennä linkki';

  @override
  String get batchStartingButton => 'Aloitetaan';

  @override
  String get batchStartImportAction => 'Aloita tuonti';

  @override
  String get batchReviewEveryPhotoTitle => 'Tarkistat jokaisen kuvan';

  @override
  String get batchReviewEveryPhotoBody =>
      'Mitään ei lisätä ennen kuin hyväksyt sen.';

  @override
  String get batchPrivateProfilesTitle => 'Yksityiset profiilit';

  @override
  String get batchPrivateProfilesBody =>
      'Yhdistä tilisi. Instagram pyytää myös käyttäjätunnusta ja salasanaa.';

  @override
  String get batchUseAnotherLinkAction => 'Käytä toista linkkiä';

  @override
  String get batchSignInNeededTitle => 'Kirjautuminen vaaditaan';

  @override
  String get batchEnterYourCodeTitle => 'Syötä koodisi';

  @override
  String get batchUseUsernamePasswordAction =>
      'Käytä käyttäjätunnusta ja salasanaa';

  @override
  String get batchAlreadyConnectedAction => 'Yhdistin jo selaimessa';

  @override
  String get batchEnterCodeAction => 'Syötä koodi';

  @override
  String get batchTryAnotherWayAction => 'Kokeile muuta tapaa';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Muodostetaan yhteyttä uudelleen';

  @override
  String get batchSignInToInstagramTitle => 'Kirjaudu Instagramiin';

  @override
  String get batchUsernameLabel => 'Käyttäjätunnus';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Koodi, jos käytät kaksivaiheista tunnistautumista';

  @override
  String get batchAuthenticatorCodeBody =>
      'Käytä tunnistnesovelluksen 6-numeroista koodia. Koodit vaihtuvat nopeasti.';

  @override
  String get batchVerifyAction => 'Vahvista';

  @override
  String get batchFindingPhotosTitle => 'Etsitään kuvia';

  @override
  String get batchImportPausedTitle => 'Tuonti keskeytetty';

  @override
  String get batchProcessingPhotosTitle => 'Käsitellään kuvia';

  @override
  String get batchWaitingNextPhoto => 'Odotetaan seuraavaa kuvaa';

  @override
  String get batchCancelImportAction => 'Peruuta tuonti';

  @override
  String get batchNoPiecesInPhotoBody => 'Kuvasta ei löytynyt vaatteita.';

  @override
  String get batchEditPieceColoursLabel => 'Värit pilkulla erotettuna';

  @override
  String get batchAddToClosetAction => 'Lisää vaatekaappiin';

  @override
  String get batchSkipPhotoAction => 'Ohita tämä kuva';

  @override
  String get batchImportCompleteTitle => 'Tuonti valmis';

  @override
  String get batchImportFailedTitle => 'Tuonti epäonnistui';

  @override
  String get batchImportCancelledTitle => 'Tuonti peruutettu';

  @override
  String get batchImportErrorBody => 'Tuonnissa tapahtui virhe.';

  @override
  String get batchNothingMoreImportedBody =>
      'Profilista ei tuoda enempää kohteita.';

  @override
  String get batchViewClosetAction => 'Näytä vaatekaappi';

  @override
  String get batchStartOverAction => 'Aloita alusta';

  @override
  String get wardrobeAddPieceTitle => 'Lisää vaate';

  @override
  String get wardrobeAddDetailsTitle => 'Lisää tiedot';

  @override
  String get wardrobeScanningTitle => 'Skannataan';

  @override
  String get batchReviewPiecesTitle => 'Tarkista vaatteet';

  @override
  String get wardrobeGalleryAction => 'Galleria';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Uusi';

  @override
  String get wardrobeRemovePhotoTooltip => 'Poista kuva';

  @override
  String get batchRunInBackgroundTooltip => 'Suorita taustalla';

  @override
  String get batchStepOneOfTwo => 'Vaihe 1/2';

  @override
  String get batchStepTwoOfTwo => 'Vaihe 2/2';

  @override
  String get batchUploadingPhotosTitle => 'Ladataan kuvia';

  @override
  String get batchFindingPiecesTitle => 'Etsitään vaatteita';

  @override
  String get batchMakingStudioPhotosTitle => 'Luodaan studiokuvia';

  @override
  String get batchStoppedLabel => 'Pysäytetty';

  @override
  String get batchFindingPiecesStoppedTitle => 'Vaatteiden haku pysäytetty';

  @override
  String get batchCancelledLabel => 'Peruttu';

  @override
  String get batchAllDoneTitle => 'Valmista';

  @override
  String get batchOpeningPiecesBody => 'Avataan vaatteitasi';

  @override
  String get batchNothingSavedBody => 'Mitään ei tallennettu.';

  @override
  String get batchFindingPiecesFailedBody => 'Vaatteiden haku epäonnistui.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Vaatteiden haku keskeytettiin.';

  @override
  String get batchStopFindingPiecesTitle => 'Pysäytetäänkö vaatteiden haku?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skannaus pysähtyy eikä mitään tallenneta. Jo löytyneet vaatteet säilyvät toiminnassasi, kunnes suljet ne.';

  @override
  String get batchKeepGoingAction => 'Jatka';

  @override
  String get batchTryAgainAction => 'Yritä uudelleen';

  @override
  String get batchBackToPhotosAction => 'Takaisin kuviiin';

  @override
  String get batchSkipAllAction => 'Ohita kaikki';

  @override
  String get batchIncludeAllAction => 'Sisällytä kaikki';

  @override
  String get batchNoPiecesFoundTitle => 'Vaatteita ei löytynyt';

  @override
  String get batchNoPiecesFoundBody => 'Näistä kuvista ei löytynyt vaatteita.';

  @override
  String get batchChooseOtherPhotosAction => 'Valitse toiset kuvat';

  @override
  String get batchUseCaseHelper =>
      'Lisätään jokaiseen tallennettuun vaatteeseen.';

  @override
  String get batchDiscardPiecesTitle => 'Hylätäänkö nämä vaatteet?';

  @override
  String get batchDiscardPiecesBody => 'Tästä erästä ei tallennettu mitään.';

  @override
  String get batchKeepAction => 'Pidä';

  @override
  String get batchDiscardAction => 'Hylkää';

  @override
  String get batchRemovePieceTitle => 'Poistetaanko tämä vaate?';

  @override
  String get batchRemovePieceBody => 'sitä ei ole tallennettu vaatekaappiisi.';

  @override
  String get batchRemoveAction => 'Poista';

  @override
  String get batchChoosePiecesToSave => 'Valitse tallennettavat vaatteet';

  @override
  String get batchDiscardAllAction => 'Hylkää kaikki';

  @override
  String get batchNothingSavedRetryBody =>
      'Mitään ei tallennettu. Yritä uudelleen.';

  @override
  String get batchNotSavedTitle => 'Ei tallennettu';

  @override
  String get batchSavingLabel => 'Tallennetaan';

  @override
  String get batchSendToBackgroundAction => 'Siirrä taustalle';

  @override
  String get batchStillWorkingMessage =>
      'Käsitellään vielä. Ilmoitamme, kun vaatteesi ovat valmiina.';

  @override
  String get batchRunningInBackgroundTitle => 'Suoritetaan taustalla';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studiokuvat keskeytyivät. Voit silti tallentaa nämä vaatteet.';

  @override
  String get batchTapPieceToSkip => 'Ohita napauttamalla vaatetta.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studiokuvat ovat vielä tulossa. Voit poistua – ilmoitamme sinulle.';

  @override
  String get batchLeaveAction => 'Poistu';

  @override
  String get batchPeopleInPhotosTitle => 'Ihmisiä kuvissa';

  @override
  String get batchIncludeAction => 'Sisällytä';

  @override
  String get batchSkipAction => 'Ohita';

  @override
  String get batchYourPhotoIsUsedLabel => 'Valokuvaasi käytetään';

  @override
  String get batchMakingStudioPhotoLabel => 'Luodaan studiokuvaa';

  @override
  String get batchNoStudioPhotoBody => 'Ei studiokuvaa. Valokuvaasi käytetään.';

  @override
  String get batchEnterDetailsYourselfAction => 'Syötä tiedot itse';

  @override
  String get batchChooseAnotherPhotoAction => 'Valitse toinen kuva';

  @override
  String get batchConnectionLostTitle => 'Yhteys katkesi';

  @override
  String get batchConnectionLostBody => 'Tarkista yhteys ja yritä uudelleen.';

  @override
  String get batchDailyLimitTitle => 'Päiväraja täynnä';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Päivitä Pro-tasolle saadaksesi lisää skannauksia tai syötä tiedot itse.';

  @override
  String get batchDailyLimitBodyFree =>
      'Skannauksesi nollautuvat huomenna. Voit syöttää tiedot itse nyt.';

  @override
  String get batchSeePlansAction => 'Katso sopimukset';

  @override
  String get batchAiBusyTitle => 'Tekoälymme on kiireinen';

  @override
  String get batchAiBusyBody =>
      'Tämä johtuu meistä. Yritä uudelleen hetken kuluttua.';

  @override
  String get batchNoPiecesBody =>
      'Kokeile tarkempaa kuvaa tai syötä tiedot itse.';

  @override
  String get batchScanningUnavailableTitle => 'Skannaus ei ole saatavilla';

  @override
  String get batchScanningUnavailableBody => 'Syötä tiedot itse toistaiseksi.';

  @override
  String get batchScanDidNotFinishTitle => 'Skannaus keskeytyi';

  @override
  String get batchTryAgainBody => 'Yritä uudelleen.';

  @override
  String get billingTitle => 'Tilaus';

  @override
  String get billingUpgradeHeading => 'Päivitä tilaustasi';

  @override
  String get billingUpgradeOnPlusBody => 'Samat ominaisuudet, isommat rajat.';

  @override
  String get billingUpgradeBody =>
      'Plus- ja Pro-tasoilla on samat ominaisuudet. Valitse tarpeisiisi sopivat rajat.';

  @override
  String get billingWebUnavailableBody =>
      'Verkkopäivitykset eivät ole vielä saatavilla. Kampanja- tai suosittelukoodi avaa silti Plus- tai Pro-tason. Kutsu ystäviä alta ansaitaksesi ilmaisia kuukausia.';

  @override
  String get billingPlansStale =>
      'Uusimpien sopimusten lataaminen epäonnistui. Hinnat saattavat olla vanhentuneita.';

  @override
  String get billingMonthly => 'Kuukausittain';

  @override
  String get billingYearly => 'Vuosittain';

  @override
  String get billingCurrentPlan => 'Nykyinen tilaus';

  @override
  String get billingActive => 'Aktiivinen';

  @override
  String get billingThisMonth => 'Tässä kuussa';

  @override
  String get billingItemExtractions => 'Vaatteiden poiminnat';

  @override
  String get billingOutfitVisualizations => 'Asujen visualisoinnit';

  @override
  String get billingNearLimitUpgrade =>
      'Lähestyt tämän kuun rajaa. Päivitä saadaksesi lisää.';

  @override
  String get billingNearLimitResets =>
      'Lähestyt tämän kuun rajaa. Se nollautuu ensi kuun alussa.';

  @override
  String get billingStoreUnavailable =>
      'Päivitykset eivät ole vielä saatavilla kaupassa. Yritä pian uudelleen.';

  @override
  String get billingManageHeading => 'Hallinnoi tilaustasi';

  @override
  String get billingCancelPlan => 'Peruuta tilaus';

  @override
  String get billingCancelKeepsAccess =>
      'Säilytät käyttöoikeuden tämän laskutuskauden loppuun asti.';

  @override
  String get billingCancelConfirmTitle => 'Haluatko peruuttaa tilauksesi?';

  @override
  String get billingKeepPlan => 'Pidä tilaus';

  @override
  String get billingCancelPlanAction => 'Peruuta tilaus';

  @override
  String get billingBilledMonthly => 'Laskutetaan kuukausittain';

  @override
  String get billingBilledYearly => 'Laskutetaan vuosittain';

  @override
  String get billingVirtualTryOn => 'Virtuaalinen sovitus';

  @override
  String get billingPrioritySupport => 'Priorisoitu tuki';

  @override
  String get billingDisclosureProRenewing =>
      'Pro on automaattisesti uusiutuva tilaus';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus ja Pro ovat automaattisesti uusiutuvia tilauksia';

  @override
  String get billingDisclosureAppleBilling =>
      'Maksu veloitetaan Apple ID -tililtäsi oston vahvistuksen yhteydessä.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Maksu veloitetaan Google Play -tililtäsi oston vahvistuksen yhteydessä.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Tilauksesi uusiutuu automaattisesti samalla jaksolla ja hinnalla, ellet poista automaattista uusintaa käytöstä vähintään 24 tuntia ennen nykyisen jakson päättymistä.';

  @override
  String get billingDisclosureAppleManage =>
      'Hallinnoi tai peruuta milloin tahansa asetuksista › Apple ID › Tilaukset.';

  @override
  String get billingDisclosureGoogleManage =>
      'Hallinnoi tai peruuta milloin tahansa Google Play › Maksut ja tilaukset.';

  @override
  String get billingReferFriend => 'Suosittele ystävälle';

  @override
  String get billingHowItWorks => 'Näin se toimii';

  @override
  String get billingHowShareTitle => 'Jaa linkkisi';

  @override
  String get billingHowShareBody => 'Lähetä se ystävälle.';

  @override
  String get billingHowSignUpTitle => 'He liittyvät';

  @override
  String get billingHowSignUpBody => 'Ystäväsi liittyy linkin kautta.';

  @override
  String get billingHowBothTitle => 'Saatatte molemmat Pro-version';

  @override
  String get billingHowBothBody =>
      'Molemmat saavat kuukauden Pro-versiota ilmaiseksi.';

  @override
  String get billingYourReferrals => 'Kutsusi';

  @override
  String get billingInvited => 'Kutsuttu';

  @override
  String get billingJoined => 'Liittynyt';

  @override
  String get billingMonthsEarned => 'Ansaitut kuukaudet';

  @override
  String get billingInviteFriend => 'Kutsu kaveri';

  @override
  String get billingInviteBody =>
      'Sinä ja kaverisi saatte molemmat kuukauden Pro-tilausta.';

  @override
  String get billingYourCode => 'Koodisi';

  @override
  String get billingCopyLink => 'Kopioi linkki';

  @override
  String get billingShareInvite => 'Jaa kutsu';

  @override
  String get giftUnavailable =>
      'Lahjakutsut eivät ole saatavilla tässä versiossa.';

  @override
  String get giftPageTitle => 'Lahjoita FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Ilmaisia lahjakutsuja ei ole tällä hetkellä saatavilla.';

  @override
  String get giftFormTitle => 'Lähetä ilmainen kutsu';

  @override
  String get giftFormBody =>
      'Vastaanottaja lunastaa lahjan tällä vahvistetulla sähköpostilla. Emme lähetä sähköpostia puolestasi.';

  @override
  String get giftFieldFrom => 'Lähettäjä';

  @override
  String get giftFieldRecipientName => 'Vastaanottajan nimi';

  @override
  String get giftFieldRecipientEmail => 'Vastaanottajan sähköposti';

  @override
  String get giftFieldOccasion => 'Tilaisuus (valinnainen)';

  @override
  String get giftNoOccasion => 'Ei tilaisuutta';

  @override
  String get giftOccasionBirthday => 'Syntymäpäivä';

  @override
  String get giftOccasionAnniversary => 'Vuosipäivä';

  @override
  String get giftOccasionOther => 'Muu';

  @override
  String get giftFieldCardGreeting => 'Kortin tervehdys';

  @override
  String get giftFieldCardGreetingHelper =>
      'Tämä näkyy kortissa täsmälleen kirjoitetussa muodossa.';

  @override
  String get giftFieldPrivateNote => 'Yksityinen viesti (valinnainen)';

  @override
  String get giftCreateAction => 'Luo ilmainen lahja';

  @override
  String get giftClaimedTitle => 'Lahja lunastettu';

  @override
  String get giftClaimedActive => 'FitCheck Pro -lahjasi on aktiivinen.';

  @override
  String get giftClaimedQueued =>
      'FitCheck Pro -lahjasi alkaa nykyisen käyttöoikeutesi jälkeen.';

  @override
  String get giftLinkCopied => 'Lahjalinkki kopioitu leikepöydälle.';

  @override
  String get giftErrorName => 'Kirjoita nimi.';

  @override
  String get giftErrorEmail => 'Kirjoita kelvollinen sähköpostiosoite.';

  @override
  String get giftErrorGreeting => 'Kirjoita kortin tervehdys.';

  @override
  String get giftErrorGreetingLength => 'Käytä enintään 80 merkkiä.';

  @override
  String get giftClaimAction => 'Lunasta lahja';

  @override
  String get giftCardPreview => 'Kortin esikatselu';

  @override
  String get giftGiftForYou => 'Lahja sinulle';

  @override
  String get giftGiftWaiting => 'Lahja odottaa sinua';

  @override
  String get giftOpenBody =>
      'Avaa lahjasi lunastaaksesi ne vahvistetulla sähköpostillasi.';

  @override
  String get giftOpenGifts => 'Avaa lahjat';

  @override
  String get giftSendInvitation => 'Lähetä kutsu';

  @override
  String get settingsAiProviderSection => 'Palveluntarjoaja';

  @override
  String get settingsAiCustom => 'Mukautettu';

  @override
  String get settingsAiUrlHelper =>
      'Käytä julkista URL-osoitetta, jonka palvelin tavoittaa. Paikallinen osoite ei toimi palvelimiltamme.';

  @override
  String get settingsAiConnectionSection => 'Yhteys';

  @override
  String get settingsAiApiUrl => 'API-osoite';

  @override
  String get settingsAiApiKey => 'API-avain';

  @override
  String get settingsAiApiKeySaved =>
      'Tallennettu. Jätä tyhjäksi säilyttääksesi.';

  @override
  String get settingsAiChatModel => 'Chat-malli';

  @override
  String get settingsAiVisionModel => 'Näkömalli (valinnainen)';

  @override
  String get settingsAiImageModel => 'Kuvamalli (valinnainen)';

  @override
  String get settingsAiImageModelNote =>
      'Kuvien luonti vaatii OpenAI-yhteensopivat chat-valmiudet.';

  @override
  String get settingsAiTestConnection => 'Testaa yhteys';

  @override
  String get calendarTitle => 'Kalenteri';

  @override
  String get calendarGoToToday => 'Siirry tähän päivään';

  @override
  String get calendarConnectTooltip => 'Yhdistä kalenteri';

  @override
  String get calendarAddEvent => 'Lisää tapahtuma';

  @override
  String get calendarEmptyTitle => 'Ei suunnitelmia';

  @override
  String get calendarEmptyBody => 'Lisää tapahtuma ja suunnittele asusi.';

  @override
  String get calendarPreviousMonth => 'Edellinen kuukausi';

  @override
  String get calendarNextMonth => 'Seuraava kuukausi';

  @override
  String get calendarAllDay => 'Koko päivä';

  @override
  String get calendarOutfitLinked => 'Asu yhdistetty';

  @override
  String get calendarEventOptions => 'Tapahtuman asetukset';

  @override
  String get calendarDeleteTitle => 'Poistetaanko tapahtuma?';

  @override
  String get calendarChangeOutfit => 'Vaihda asu';

  @override
  String get calendarLinkOutfit => 'Liitä asu';

  @override
  String get calendarRemoveOutfit => 'Poista asu';

  @override
  String get calendarNewEvent => 'Uusi tapahtuma';

  @override
  String get calendarEditEvent => 'Muokkaa tapahtumaa';

  @override
  String get calendarTitleLabel => 'Otsikko';

  @override
  String get calendarTitleRequired => 'Lisää otsikko';

  @override
  String get calendarEndBeforeStart => 'Päättyy alkamisajan jälkeen';

  @override
  String get calendarStarts => 'Alkaa';

  @override
  String get calendarEnds => 'Päättyy';

  @override
  String get calendarPlaceOptional => 'Paikka (valinnainen)';

  @override
  String get calendarNotesOptional => 'Muistiinpanot (valinnainen)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Luo asu ja liitä se tähän tapahtumaan.';

  @override
  String get calendarBuildOutfit => 'Luo asu';

  @override
  String get calendarConnectionsTitle => 'Kalenterit';

  @override
  String get calendarConnectionsBody =>
      'Tänne lisäämäsi tapahtumat pysyvät FitCheck AI:ssa.';

  @override
  String get calendarDisconnect => 'Katkaise yhteys';

  @override
  String get calendarNotAvailable => 'Ei vielä saatavilla';

  @override
  String get profileSectionExplore => 'Tutki';

  @override
  String get profileNavTryOn => 'Sovitus';

  @override
  String get profileNavRewards => 'Palkinnot';

  @override
  String get profileSupport => 'Tuki';

  @override
  String get profileHelp => 'Ohje';

  @override
  String get profileAbout => 'Tietoja';

  @override
  String get profileAboutBody =>
      'Vaatekaappisi, asusi ja suunnitelmasi yhdessä paikassa.';

  @override
  String get profileSignOutTitle => 'Kirjaudutaanko ulos?';

  @override
  String get profileSignOutBody =>
      'Voit kirjautua takaisin sisään milloin tahansa.';

  @override
  String get profileEditTitle => 'Muokkaa profiilia';

  @override
  String get profileYourProfile => 'Profiilisi';

  @override
  String get profileBodyProfiles => 'Kehoprofiilit';

  @override
  String get profileBodyEmptyTitle => 'Ei vielä kehoprofiileja';

  @override
  String get profileBodyEmptyBody =>
      'Lisää pituus ja vartalotyyppi paremman istuvuuden saamiseksi.';

  @override
  String get profileBodyAdd => 'Lisää profiili';

  @override
  String get profileBodyDefaultNote =>
      'Oletusprofiiliasi käytetään istuvuuteen ja sovitukseen.';

  @override
  String get profileBodyDefaultBadge => 'Oletus';

  @override
  String get profileBodyMakeDefault => 'Aseta oletukseksi';

  @override
  String get profileBodyDeleteBody => 'Tätä ei voi kumota.';

  @override
  String get profileBodyRequired => 'Pakollinen';

  @override
  String get profileBodyCheckNumber => 'Tarkista tämä luku';

  @override
  String get profileBodyNew => 'Uusi kehoprofiili';

  @override
  String get profileBodyNameHint => 'Esimerkiksi Minä';

  @override
  String get profileBodyHeight => 'Pituus';

  @override
  String get profileBodyWeight => 'Paino';

  @override
  String get profileBodyBuild => 'Vartalotyyppi';

  @override
  String get profileBodySkinTone => 'Ihon sävy';

  @override
  String get profileBirthDateNeededBody =>
      'Lisää syntymäaika syntymäkellonajan kaveriksi.';

  @override
  String get profileBirthDateNeededTitle => 'Syntymäaika tarvitaan';

  @override
  String get profilePartlySavedBody =>
      'Nimesi ja kuvasi tallennettiin. Syntymätietoja ei voitu tallentaa; yritä myöhemmin uudelleen.';

  @override
  String get profilePartlySavedTitle => 'Osittain tallennettu';

  @override
  String get profileSavedBody => 'Profiilisi on tallennettu.';

  @override
  String get profileChangePhoto => 'Vaihda profiilikuva';

  @override
  String get profilePhotoLabel => 'Profiilikuva';

  @override
  String get profilePhotoHint => 'Napauta valitaksesi uuden';

  @override
  String get profileBirthDateLabel => 'Syntymäaika (valinnainen)';

  @override
  String get profileBirthTimeLabel => 'Syntymäkellonaika (valinnainen)';

  @override
  String get profileBirthTimeHelper =>
      'Tekee veedisistä ehdotuksista tarkempia';

  @override
  String get profileBirthPlaceLabel => 'Syntymäpaikka (valinnainen)';

  @override
  String get profileBirthPlaceHint => 'Esimerkiksi New Delhi, Intia';

  @override
  String get profileHelpContactTitle => 'Kysy meiltä mitä tahansa';

  @override
  String get profileHelpContactBody =>
      'Lähetä viesti, niin vastaamme sähköpostitse yleensä vuorokauden kuluessa.';

  @override
  String get profileHelpContactAction => 'Ota yhteyttä tukeen';

  @override
  String get profileHelpFaqTitle => 'Usein kysytyt kysymykset';

  @override
  String get profileFaqAddPiecesTitle => 'Miten lisään vaatteita kaappiini?';

  @override
  String get profileFaqAddPiecesBody =>
      'Napauta Lisää vaate Vaatekaappi-välilehdellä. Ota kuva tai valitse se galleriasta; tunnistamme ja merkitsemme vaatteen puolestasi.';

  @override
  String get profileFaqMatchingTitle => 'Miten asujen yhdistely toimii?';

  @override
  String get profileFaqMatchingBody =>
      'Avaa Sinulle ja valitse omistamasi vaatteet. Ehdotamme sopivia yhdistelmiä ja luomme valmiita asuja kaapistasi.';

  @override
  String get profileFaqTryOnTitle =>
      'Voinko käyttää omia kuviani sovituksessa?';

  @override
  String get profileFaqTryOnBody =>
      'Kyllä. Lisää kokovartalokuva itsestäsi ja valitse sitten vaatteet nähdäksesi ne päälläsi.';

  @override
  String get profileFaqRewardsTitle => 'Miten saan palkintoja?';

  @override
  String get profileFaqRewardsBody =>
      'Suunnittele ja kirjaa asuja säännöllisesti. Putket ja saavutukset karttuvat tekemisen myötä.';

  @override
  String get profileFaqPrivacyTitle => 'Onko vaatekaappini yksityinen?';

  @override
  String get profileFaqPrivacyBody =>
      'Kyllä. Vaatekaappisi ja asusi ovat yksityisiä, ellet jaa linkkiä yksittäiseen asuun.';

  @override
  String get profileHelpMoreTitle => 'Lisää apua';

  @override
  String get profileHelpGuides => 'Oppaat';

  @override
  String get profileHelpGuidesBody => 'Miten kukin toiminto toimii';

  @override
  String get feedbackCategoryBug => 'Jokin meni rikki';

  @override
  String get feedbackCategoryIdea => 'Idea';

  @override
  String get feedbackCategoryGeneral => 'Yleistä';

  @override
  String get feedbackCategoryHelp => 'Tarvitsen apua';

  @override
  String get feedbackHintBug =>
      'Mitä tapahtui ja mitä odotit? Vaiheet auttavat meitä korjaamaan sen.';

  @override
  String get feedbackHintIdea => 'Mitä haluaisit ja miksi?';

  @override
  String get feedbackHintGeneral => 'Kerro mielipiteesi tai esitä kysymys.';

  @override
  String get feedbackAttachmentLimitBody => 'Voit lisätä enintään 5 kuvaa.';

  @override
  String get feedbackAttachmentLimitTitle => 'Raja saavutettu';

  @override
  String get feedbackImageTooLargeBody => 'Valitse alle 5 Mt:n kokoinen kuva.';

  @override
  String get feedbackImageTooLargeTitle => 'Liian suuri kuva';

  @override
  String get feedbackTitle => 'Lähetä palautetta';

  @override
  String get feedbackAboutLabel => 'Mistä on kyse?';

  @override
  String get feedbackSubjectLabel => 'Aihe';

  @override
  String get feedbackSubjectRequired => 'Lisää aihe';

  @override
  String get feedbackSubjectTooShort => 'Aiheen on oltava vähintään 3 merkkiä';

  @override
  String get feedbackDetailsLabel => 'Lisätiedot';

  @override
  String get feedbackDetailsRequired => 'Lisää tietoja';

  @override
  String get feedbackDetailsTooShort =>
      'Kuvauksen on oltava vähintään 10 merkkiä';

  @override
  String get feedbackAddScreenshot => 'Lisää kuvakaappaus';

  @override
  String get feedbackAttachmentHint => 'Enintään 5, á 5 Mt';

  @override
  String get feedbackSend => 'Lähetä';

  @override
  String get feedbackEmptyTitle => 'Ei lähetyksiä vielä';

  @override
  String get feedbackEmptyBody => 'Lähetyksesi näkyvät täällä tiloineen.';

  @override
  String get feedbackHistoryTitle => 'Lähetyksesi';

  @override
  String get feedbackStatusOpen => 'Avoin';

  @override
  String get feedbackStatusInProgress => 'Käsittelyssä';

  @override
  String get feedbackStatusResolved => 'Ratkaistu';

  @override
  String get feedbackStatusClosed => 'Suljettu';

  @override
  String get legalIntro =>
      'Miten suojaamme tietojasi ja FitCheck AI -sovelluksen käyttöehdot.';

  @override
  String get legalPolicies => 'Käytännöt';

  @override
  String get legalPrivacySubtitle => 'Mitä keräämme ja miksi';

  @override
  String get legalTermsTitle => 'Käyttöehdot';

  @override
  String get legalTermsSubtitle => 'Sovelluksen säännöt';

  @override
  String get legalLicences => 'Avoimen lähdekoodin lisenssit';

  @override
  String get legalSupportSubtitle => 'Tuki, yhteydenotto ja tietopyynnöt';

  @override
  String get legalReportAbuse => 'Ilmoita ongelmasta tai väärinkäytöksestä';

  @override
  String get permissionCameraTitle => 'Kameran käyttöoikeus';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI käyttää kameraasi vaatteiden ja asujen kuvaamiseen tekoälysovitusta ja vaatekaapin hallintaa varten.';

  @override
  String get permissionPhotoTitle => 'Kuvien käyttöoikeus';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI tarvitsee pääsyn kuviisi, jotta voit valita vaate- ja asukuvia tekoälyominaisuuksiin ja vaatekaappiisi.';

  @override
  String get permissionNotNow => 'Ei nyt';

  @override
  String get permissionOpenSettings => 'Avaa asetukset';

  @override
  String authSignedInAs(String name) {
    return 'Kirjautunut nimellä $name';
  }

  @override
  String get authSignedIn => 'Kirjautunut sisään';

  @override
  String get authWelcomeBackTitle => 'Tervetuloa takaisin';

  @override
  String get authSignInFailed => 'Kirjautuminen epäonnistui';

  @override
  String get authWelcomeTitle => 'Tervetuloa';

  @override
  String get authSignUpFailed => 'Rekisteröityminen epäonnistui';

  @override
  String get authGoogleSignInFailed => 'Google-kirjautuminen epäonnistui';

  @override
  String get authAppleSignInFailed => 'Apple-kirjautuminen epäonnistui';

  @override
  String get authConfirmEmailTitle => 'Vahvista sähköpostisi';

  @override
  String get authConfirmEmailBody =>
      'Tarkista sähköpostisi ja vahvista osoitteesi, kirjaudu sitten sisään.';

  @override
  String get authClosetReady => 'Vaatekaappisi on valmis.';

  @override
  String get authSignedOutTitle => 'Kirjautunut ulos';

  @override
  String get authSignedOutBody => 'Olet kirjautunut ulos.';

  @override
  String get authSignOutFailed => 'Uloskirjautuminen epäonnistui';

  @override
  String get authEmailSentTitle => 'Sähköposti lähetetty';

  @override
  String get authResetLinkSent =>
      'Tarkista sähköpostisi ja avaa palautuslinkki.';

  @override
  String get authPasswordUpdatedTitle => 'Salasana päivitetty';

  @override
  String get authPasswordUpdated => 'Salasanasi on päivitetty.';

  @override
  String get authPasswordNotUpdated => 'Salasanaa ei päivitetty';

  @override
  String get authCouldNotSendEmail => 'Sähköpostin lähetys epäonnistui';

  @override
  String get authEmailNotSent => 'Sähköpostia ei lähetetty';

  @override
  String get authResendSentBody => 'Lähetimme uuden vahvistussähköpostin.';

  @override
  String get outfitPreviewWithAi => 'Esikatsele tekoälyllä';

  @override
  String get outfitNewPreview => 'Luo uusi esikatselu';

  @override
  String get outfitBuilderClosetHeading => 'Kaappisi';

  @override
  String get outfitBuilderSearchHint => 'Hae vaatteita';

  @override
  String get outfitClearSearch => 'Tyhjennä haku';

  @override
  String get outfitBuilderAddPiecesTitle => 'Lisää vaatteita ensin';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Asunnot syntyvät kaappisi vaatteista.';

  @override
  String get outfitBuilderNoMatches => 'Ei vastaavia vaatteita.';

  @override
  String get outfitNameLabel => 'Asunnon nimi';

  @override
  String get outfitNameHint => 'Esim. Viikonloppulinen';

  @override
  String get outfitPreviewSemantic => 'Asunnon tekoälyesikatselu';

  @override
  String get outfitChoosePieces => 'Valitse vaatteet';

  @override
  String get outfitTapPiecesHint => 'Napauta vaatteita lisätäksesi niitä.';

  @override
  String get outfitShareTooltip => 'Jaa';

  @override
  String get outfitSaveFavourite => 'Tallenna suosikkeihin';

  @override
  String get outfitPiecesHeading => 'Vaatteet';

  @override
  String get outfitWearHistoryEmpty =>
      'Kanna asu ja päivämäärät näkyvät tässä.';

  @override
  String get outfitWearHistoryTitle => 'Kantohistoria';

  @override
  String get outfitWearHistoryError => 'Päivämääriä ei voitu ladata.';

  @override
  String get outfitWornOn => 'Kantopäivä';

  @override
  String get outfitEditTitle => 'Muokkaa asua';

  @override
  String get outfitSavedPhotosFailed => 'Tiedot tallennettu, kuvat eivät';

  @override
  String get outfitNoPhotosBody => 'Ei kuvia vielä. Asussa näkyy sen vaatteet.';

  @override
  String get outfitOccasionLabel => 'Tapaus';

  @override
  String get outfitOccasionNone => 'Ei ole';

  @override
  String get outfitTagsHint => 'Erota pilkuilla';

  @override
  String get outfitDraftBody => 'Piilossa päälistasta';

  @override
  String get outfitPublic => 'Julkinen';

  @override
  String get outfitPublicBody => 'Linkin omistava näkee sen';

  @override
  String get outfitDeleteFromDetail => 'Poista tämä asu tieto-sivulta.';

  @override
  String get outfitNewCollection => 'Uusi kokoelma';

  @override
  String get outfitNoCollectionsTitle => 'Ei kokoelmia vielä';

  @override
  String get outfitNoCollectionsBody =>
      'Järjestä asut matka-ajon, sesongin tai mielialan mukaan.';

  @override
  String get outfitCreateCollection => 'Luo kokoelma';

  @override
  String get outfitAddOutfits => 'Lisää asuja';

  @override
  String get outfitRename => 'Nimetään';

  @override
  String get outfitCollectionDeleteBody => 'Kokoelman asut säilytetään.';

  @override
  String get outfitCollectionsNotLoaded => 'Asuja ei ladattu';

  @override
  String get outfitRenameCollection => 'Nimetään kokoelma';

  @override
  String get outfitDescriptionOptional => 'Kuvaus (vapaaehtoinen)';

  @override
  String get outfitAllInCollection => 'Kaikki asut ovat jo tässä kokoelmassa.';

  @override
  String get photoshootSubtitleUpload => 'Studiovalokuvia omista valokuvistasi';

  @override
  String get photoshootSubtitleConfigure => 'Valitse tyyli, muoto ja määrä';

  @override
  String get photoshootSubtitleGenerating => 'Tämä vie minuutin tai kaksi';

  @override
  String get photoshootAddPhotosSemantic => 'Lisää valokuvia galleriastasi';

  @override
  String get photoshootUploadTitle => 'Lisää 1–4 valokuvaa itsestäsi';

  @override
  String get photoshootUploadBody => 'Paina valitaksesi galleriasta';

  @override
  String get photoshootAddToContinue => 'Lisää valokuva jatkaaaksesi';

  @override
  String get photoshootAddAnotherPhoto => 'Lisää toinen valokuva';

  @override
  String get photoshootTipsTitle => 'Parhaan tuloksen saamiseksi';

  @override
  String get photoshootTipsBody =>
      'Käytä selkiä, hyvin valaistuja kasvosi valokuvia eri kulmista. Vältä aurinkolaseja ja lakkuja.';

  @override
  String get photoshootStarting => 'Käynnistyy';

  @override
  String get photoshootCancelling => 'Perutaan';

  @override
  String get photoshootFailed => 'Ehtymä välinen';

  @override
  String get recommendTabMatches => 'Sopivaa';

  @override
  String get recommendTabComplete => 'Kokoelma';

  @override
  String get recommendTabWeather => 'Säätiedot';

  @override
  String get recommendTabColours => 'Värit';

  @override
  String get recommendTabShop => 'Kauppa';

  @override
  String get recommendNoMatchesTitle => 'Ei vielä sopivaa';

  @override
  String get recommendNoMatchesBody =>
      'Valitse kappale ja etsimme siihen sopivan.';

  @override
  String get recommendPickPiece => 'Valitse kappale';

  @override
  String get recommendNothingMatchesTitle => 'Ei vielä sopivia kappaleita';

  @override
  String get recommendNothingMatchesBody =>
      'Kokeile toisia kappaleita tai lisää vaatekaappiasi.';

  @override
  String get recommendChangePieces => 'Vaihda kappaleita';

  @override
  String get recommendDefaultReason => 'Se sopii valitsemiisi kappaleisiin.';

  @override
  String get recommendCompleteTitle => 'Täydennä asu';

  @override
  String get recommendCompleteBody => 'Valitse kappale ja täydennämme loput.';

  @override
  String get recommendWorking => 'Käsitellään';

  @override
  String get recommendGenerate => 'Luo';

  @override
  String get recommendChooseStyleBody => 'Valitse tyyli ja luo.';

  @override
  String get recommendNoLooksTitle => 'Ei asuja näille kappaleille';

  @override
  String get recommendNoLooksBody =>
      'Kokeile toista tyyliä tai muita kappaleita.';

  @override
  String get recommendDefaultLook => 'Asu kappaleillesi';

  @override
  String get recommendNoPiecesBody => 'Asuun ei löytynyt kappaleita.';

  @override
  String get recommendCityLabel => 'Kaupunki';

  @override
  String get recommendCheck => 'Tarkista';

  @override
  String get recommendWeatherTitle => 'Mikä on sää?';

  @override
  String get recommendWeatherBody =>
      'Syötä kaupunkisi päivän vinkkien saamiseksi.';

  @override
  String get recommendWearToday => 'Kanna tänään';

  @override
  String get recommendWeatherNoPieces =>
      'Ei vielä kappaleita vaatekaapissasi tälle säätilalle.';

  @override
  String get recommendBudgetLabel => 'Budjetti asti';

  @override
  String get recommendLooking => 'Etsitään';

  @override
  String get recommendFindWhatToBuy => 'Löydä ostettava';

  @override
  String get recommendFillGapsTitle => 'Täytä puutteet';

  @override
  String get recommendFillGapsBody =>
      'Määritä budjetti ja suosittelemme mitä kaappisi puuttuu.';

  @override
  String get recommendNoGapsTitle => 'Ei puutteita';

  @override
  String get recommendNoGapsBody =>
      'Kokeile suurempaa budjettia tai toista luokkaa.';

  @override
  String get recommendMoodEveryday => 'Arki';

  @override
  String get recommendMoodBigMeeting => 'Kokous';

  @override
  String get recommendDayLabel => 'Päivä';

  @override
  String get recommendReadingStars => 'Tulkitaan tähtiä';

  @override
  String get recommendGetMyColours => 'Hae värejäni';

  @override
  String get recommendLuckyColoursTitle => 'Onnisvärit';

  @override
  String get recommendLuckyColoursBody =>
      'Valitse päivä ja ehdotamme värejä ja vaatteita siihen.';

  @override
  String get recommendLuckyColoursSection => 'Onnisvärit';

  @override
  String get recommendAvoidColoursSection => 'Värit, joita kannattaa välttää';

  @override
  String get recommendBirthDateTitle => 'Lisää syntymäpäiväsi';

  @override
  String get recommendBirthDateBody =>
      'Tarkka syntymäpäivä tarvitaan värien tulkintaan.';

  @override
  String get recommendEditProfile => 'Muokkaa profiilia';

  @override
  String get recommendNothingThisDay => 'Ei mikään tähän päivään.';

  @override
  String get recommendUnnamedColour => 'Nimeämätön väri';

  @override
  String get recommendFromCloset => 'Kaapistasi';

  @override
  String get recommendNoPiecesInColours =>
      'Ei vaatteita näissä väreissä vielä.';

  @override
  String get recommendOutfitIdeas => 'Asustuksen ideat';

  @override
  String get recommendNoOutfitsInColours =>
      'Ei koko asua näissä väreissä vielä.';

  @override
  String get recommendDefaultOutfitIdea => 'Yksi asuste-idea';

  @override
  String get recommendPickUpToThree => 'Valitse enintään kolme vaatetta';

  @override
  String get recommendEmptyClosetBody =>
      'Lisää muutama vaate ensin, niin palataan täysistymäisiin.';

  @override
  String get dashboardDressForDay => 'Pukeudu tulevaan päivään.';

  @override
  String get dashboardOutfitOfDay => 'Päivän asu';

  @override
  String get dashboardFreshLook => 'Uusi ilme';

  @override
  String get subscriptionManageInStoreTitle => 'Hallitse kaupassa';

  @override
  String get subscriptionManageInStoreBody =>
      'Tämä tili suoritetaan kaupan kautta. Hallitse sitä kauppa-asetuksissasi.';

  @override
  String get subscriptionCancelledTitle => 'Tilaus peruutettu';

  @override
  String get subscriptionCancelledBody =>
      'Suorituksesi jatkuu, kunnes tämä laskukausi päättyy.';

  @override
  String get subscriptionCancelFailedTitle => 'Peruutettua ei voitu';

  @override
  String get subscriptionCouldNotOpenTitle => 'Aukseneminen epäonnistui';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Suoritusasetuksia ei voitu avata.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Linkkiä ei voitu avata.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Linkkiä ei voitu ladata';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Suoittelulinkkiä ei voitu ladata. Yritä uudelleen.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopioitu';

  @override
  String get subscriptionReferralCopiedBody => 'Suoittelulinkki kopioitu.';

  @override
  String get subscriptionReferralShareSubject =>
      'Kokeile FitCheck AI -sovellusta';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Liity FitCheck AI -sovellukseen, ja me molemmat saamme kuukauden Pro-palvelun. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Linkki kopioitu';

  @override
  String get subscriptionShareUnavailableBody =>
      'Jakaminen ei ole käytettävissä, joten linkki on kopioitu.';

  @override
  String get subscriptionShareFailedTitle => 'Jakaminen epäonnistui';

  @override
  String get subscriptionShareFailedBody =>
      'Kopioi linkki suoittelusivun sijaan.';

  @override
  String get subscriptionStoreReadyTitle => 'Kauppa valmis';

  @override
  String get subscriptionStoreReadyBody =>
      'Kaupan hinnat ovat käytettävissä. Voit päivittää nyt.';

  @override
  String get purchaseFailedTitle => 'Osto epäonnistui';

  @override
  String get purchaseUnavailableTitle => 'Osto ei ole käytettävissä';

  @override
  String get purchaseIapUnavailableBody =>
      'Sovelluksen sisäiset ostot eivät ole käytettävissä tällä laitteella.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Tämä suunnitelma ei ole vielä ostettavissa.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Tämä suunnitelma ei ole vielä käytettävissä kaupassa. Tarkista myöhemmin.';

  @override
  String get purchaseStartFailedBody =>
      'Ostoa ei voitu aloittaa. Yritä uudelleen.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Maksusuunnitteluprosessi ei palauttanut maksulinkkiä.';

  @override
  String get purchasePendingTitle => 'Osto odottaa';

  @override
  String get purchasePendingBody =>
      'Ostosi on odotuksissa hyväksyntään. Saat käyttöötoikeudet heti, kun se on hyväksytty.';

  @override
  String get purchaseFailedBody => 'Osto epäonnistui. Yritä uudelleen.';

  @override
  String get purchaseRestoredTitle => 'Palautettu';

  @override
  String get purchaseRestoredBody => 'Ostosi on palautettu.';

  @override
  String get purchaseActiveTitle => 'Tilaus voimassa';

  @override
  String get purchaseActiveBody => 'Tilauksesi on aktiivinen. Tervetuloa.';

  @override
  String get purchaseSignInRequiredTitle => 'Kirjautuminen vaaditaan';

  @override
  String get purchaseSignInRequiredBody =>
      'Kirjaudu sisään päättääksesi ostot.';

  @override
  String get purchaseErrorTitle => 'Ostovirhe';

  @override
  String get purchaseInvalidTransactionBody =>
      'Ostossa ei ollut todennettavaa transaktio-ID:ttä.';

  @override
  String get purchaseVerificationPendingTitle => 'Vahvistus meneillään';

  @override
  String get purchaseVerificationPendingBody =>
      'Voimme nyt todentaa ostostasi kaupassa. Se päättyy automaattisesti, ja sinua ei laskuteta kahdesti.';

  @override
  String get purchaseNotAppliedTitle => 'Ostoa ei voitu käyttää';

  @override
  String get purchaseNotAppliedBody =>
      'Ostoa ei voitu kirjauttaa tilillesi. Ota yhteyttä tukeen, ja älä osta uudelleen.';

  @override
  String get purchaseRestoreFailedTitle => 'Palautus epäonnistui';

  @override
  String get purchaseRestoreFailedBody =>
      'Ostoja ei voitu palauttaa. Yritä uudelleen.';

  @override
  String get purchaseRecoveredActiveBody => 'Tilauksesi on aktiivinen.';

  @override
  String get purchaseCompleteTitle => 'Osto onnistui';

  @override
  String get giftCreateFailedTitle => 'Lahjaa ei voitu luoda';

  @override
  String get giftClaimFailedTitle => 'Lahjaa ei voitu vastaanottaa';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lahjaa sinulle',
      one: 'Lahja sinulle',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 kuukausi',
      '12': '1 vuosi',
      'other': '$months kuukautta',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining jäljellä',
      one: '1 jäljellä',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro -kuukausia';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender lähetti sinulle $duration FitCheck Pro -kuukausia. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'FitCheck Pro -lahja $recipient:lle';
  }

  @override
  String giftFromSender(String sender) {
    return 'Lähettäjä: $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Vastaanottaja: $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Lähettäjä: $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'vastaanottajasi';

  @override
  String get giftPreviewPlaceholderSender => 'sinä';

  @override
  String get settingsSavedTitle => 'Tallennettu';

  @override
  String get settingsNotSavedTitle => 'Ei tallennettu';

  @override
  String get settingsAiChooseProviderBody => 'Valitse toimittaja.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Mukautettu toimittaja vaatii API-osoitteen.';

  @override
  String get settingsAiKeyRequiredBody => 'Syötä API-avain.';

  @override
  String get settingsAiSavedBody => 'AI-asetukset tallennettu.';

  @override
  String get settingsAiMissingDetailsTitle => 'Puuttuvat tiedot';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Syötä API-osoite ja chat-malli testattavaksi.';

  @override
  String get settingsAiKeyNeededTitle => 'API-avain tarvitaan';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Syötä API-avain testausta varten. Tallennettu avain pysyy salassa.';

  @override
  String get settingsAiKeyToTestBody => 'Syötä API-avain testausta varten.';

  @override
  String get settingsAiConnectedTitle => 'Yhteys muodostettu';

  @override
  String get settingsAiConnectedBody => 'Yhteys toimii.';

  @override
  String get settingsAiTestFailedTitle => 'Testi epäonnistui';

  @override
  String get settingsPreferencesSavedBody => 'Asetuksesi on tallennettu.';

  @override
  String get settingsPasswordNotChangedTitle => 'Salasanaa ei muutettu';

  @override
  String get settingsOAuthPasswordBody =>
      'Tili käyttää Google- tai Apple-kirjautumista. Käytä \"Unohdin salasanan\" -toimintoa salasanan asettamiseen.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Nykyinen salasana on virheellinen.';

  @override
  String get settingsExportReadyTitle => 'Vienti valmis';

  @override
  String get settingsExportReadyBody => 'Tietojen vienti on ladattavissa.';

  @override
  String get settingsLinkCopiedTitle => 'Linkki kopioitu';

  @override
  String get settingsExportClipboardBody =>
      'Selainta ei voitu avata, joten latauslinkki kopioitiin. Liitä se selaimen pikaisesti: se vanhentuu.';

  @override
  String get settingsExportFailedTitle => 'Vienti epäonnistui';

  @override
  String get settingsAccountNotDeletedTitle => 'Tiliä ei poistettu';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Voit lisätä enintään $max valokuvaa.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Kuvien rajamäärä';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Lisää vähintään yksi valokuva.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Ei kuvia';

  @override
  String get photoshootDescribeLookBody => 'Kuvaa toivomasi tyyli.';

  @override
  String get photoshootPromptNeededTitle => 'Kysely vaaditaan';

  @override
  String get photoshootConsentFeatureLabel => 'AI-valokuvaukset';

  @override
  String get photoshootStatusPreparing => 'Kuvanvalmistelu';

  @override
  String get photoshootStatusGenerating => 'Luodaan';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Erä $current/$total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done/$total valmista';
  }

  @override
  String get photoshootGenerationFailedBody => 'Luonti epäonnistui.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready valmista, $failed epäonnistui.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Osa valmis';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valokuvaa on valmis.',
      one: '1 valokuva on valmis.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => 'Yhteys katkesi. Yritä uudelleen.';

  @override
  String get photoshootCouldNotCancelTitle => 'Peruutettua ei voitu';

  @override
  String get photoshootRetryFailedTitle => 'Uuden yrityksen epäonnistui';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Kuva $number on valmis.';
  }

  @override
  String get photoshootReplacedTitle => 'Korvattu';

  @override
  String get photoshootSavedToGalleryBody => 'Tallennettu galleriaasi.';

  @override
  String get photoshootSavedTitle => 'Tallennettu';

  @override
  String get photoshootNotSavedTitle => 'Tallentamatta';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kaikki $count kuvaa ovat galleriassasi.',
      one: '1 kuva on galleriassasi.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved / $total tallennettu.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Jotkut kuvat tallentamatta';

  @override
  String get tryonConsentFeatureLabel => 'Virtuaalipukeutuminen';

  @override
  String get tryonAvatarUpdatedBody => 'Kuvasi on päivitetty.';

  @override
  String get tryonSavedTitle => 'Tallennettu';

  @override
  String get tryonUploadFailedTitle => 'Lähetys epäonnistui';

  @override
  String get tryonChooseGarmentFirstBody => 'Valitse vaatekuva ensin.';

  @override
  String get tryonNoGarmentTitle => 'Ei vaatekuvaa';

  @override
  String get tryonWaitForUploadBody => 'Odota, kunnes kuva on lähetetty.';

  @override
  String get tryonStillUploadingTitle => 'Lähetetään edelleen';

  @override
  String get tryonAddYourPhotoFirstBody => 'Lisää ensin oma kuvasi.';

  @override
  String get tryonReadyBody => 'Pukeutumisesi on valmis.';

  @override
  String get tryonFailedTitle => 'Pukeutuminen epäonnistui';

  @override
  String get tryonSavedToGalleryBody => 'Tallennettu galleriaasi.';

  @override
  String get tryonNotSavedTitle => 'Tallentamatta';

  @override
  String get calendarEventAddedBody => 'Tapahtuma lisätty';

  @override
  String get calendarEventPlannedTitle => 'Suunniteltu';

  @override
  String get calendarEventSavedBody => 'Tapahtuma tallennettu';

  @override
  String get calendarSavedTitle => 'Tallennettu';

  @override
  String get calendarEventNotSavedTitle => 'Tapahtumaa ei tallennettu';

  @override
  String get calendarEventRemovedBody => 'Tapahtuma poistettu';

  @override
  String get calendarEventDeletedTitle => 'Poistettu';

  @override
  String get calendarEventNotDeletedTitle => 'Tapahtumaa ei poistettu';

  @override
  String get calendarOutfitNotLinkedTitle => 'Pukeutumista ei liitetty';

  @override
  String get calendarLinkedTitle => 'Liitetty';

  @override
  String get calendarOutfitNotRemovedTitle => 'Pukeutumista ei poistettu';

  @override
  String get calendarOutfitRemovedBody => 'Pukeutuminen poistettu';

  @override
  String get calendarDisconnectedBody => 'Kalenteri irtisanottu';

  @override
  String get calendarDisconnectedTitle => 'Irrotettu';

  @override
  String get calendarNotDisconnectedTitle => 'Kalenteria ei irrotettu';

  @override
  String get calendarTodayLabel => 'tänään';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tapahtumaa',
      one: '1 tapahtuma',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, pukeutuminen liitetty';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '”$title” poistetaan.';
  }

  @override
  String get calendarThisAppLabel => 'Tämä sovellus';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synkronointi $provider:n kanssa ei ole vielä saatavilla. Voit silti lisätä tapahtumia tänne.';
  }

  @override
  String get calendarWeekdaySunShort => 'su';

  @override
  String get calendarWeekdayMonShort => 'ma';

  @override
  String get calendarWeekdayTueShort => 'ti';

  @override
  String get calendarWeekdayWedShort => 'ke';

  @override
  String get calendarWeekdayThuShort => 'to';

  @override
  String get calendarWeekdayFriShort => 'pe';

  @override
  String get calendarWeekdaySatShort => 'la';

  @override
  String get calendarWeekdayMonday => 'maanantai';

  @override
  String get calendarWeekdayTuesday => 'tiistai';

  @override
  String get calendarWeekdayWednesday => 'keskiviikko';

  @override
  String get calendarWeekdayThursday => 'torstai';

  @override
  String get calendarWeekdayFriday => 'perjantai';

  @override
  String get calendarWeekdaySaturday => 'lauantai';

  @override
  String get calendarWeekdaySunday => 'Sunnuntai';

  @override
  String get outfitSavedToFavouritesBody => 'Tallennettu suosikkeihin';

  @override
  String get outfitRemovedFromFavouritesBody => 'Poistettu suosikeista';

  @override
  String get outfitNotSavedTitle => 'Tallennus epäonnistui';

  @override
  String get outfitLoggedAsWornBody => 'Kirjattu käytetyksi tänään.';

  @override
  String get outfitNicePickTitle => 'Hyvä valinta';

  @override
  String get outfitRemovedBody => 'Pukeutuminen poistettu.';

  @override
  String get outfitDeletedTitle => 'Poistettu';

  @override
  String get outfitNotDeletedTitle => 'Poistaminen epäonnistui';

  @override
  String get outfitDuplicatedBody => 'Kopio on pukemistessasi.';

  @override
  String get outfitDuplicatedTitle => 'Kopioitu';

  @override
  String get outfitNotDuplicatedTitle => 'Kopiointi epäonnistui';

  @override
  String get outfitNotSharedTitle => 'Jakaminen epäonnistui';

  @override
  String outfitCollectionReadyBody(String name) {
    return '”$name” on valmis.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Kokoelmaa ei luotu';

  @override
  String get outfitCollectionUpdatedBody => 'Kokoelma päivitetty.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Päivitys epäonnistui';

  @override
  String get outfitCollectionDeletedBody => 'Kokoelma poistettu.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Poistaminen epäonnistui';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asua lisätty.',
      one: '1 asu lisätty.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Asuja ei lisätty';

  @override
  String get outfitPreviewNotCreatedTitle => 'Esikatselua ei luotu';

  @override
  String get outfitGiveNameBody => 'Anna asulle nimi.';

  @override
  String get outfitNameMissingTitle => 'Nimi';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Valitse vähintään yksi osuus.';

  @override
  String outfitCreatedBody(String name) {
    return '$name on asuissasi.';
  }

  @override
  String get outfitSavedTitle => 'Tallennettu';

  @override
  String get wardrobeAddedToFavouritesBody => 'Lisätty suosikkeihin';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Poistettu suosikeista';

  @override
  String get wardrobeNotSavedTitle => 'Tallennus epäonnistui';

  @override
  String get wardrobeLoggedAsWornBody => 'Kirjoitettu käytetyksi tänään.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Poistettu sinun kaappistasi.';

  @override
  String get wardrobeDeletedTitle => 'Poistettu';

  @override
  String get wardrobeNotDeletedTitle => 'Ei poistettu';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vaatetta poistettu kaapistasi.',
      one: '1 vaate poistettu kaapistasi.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Tee kaappiesinehto AI:lla';

  @override
  String get itemAddScanJobLabel => 'Skannaa';

  @override
  String get itemAddFoundEarlierBody => 'Löytyi aiemmasta skannista';

  @override
  String get itemAddLookingAtPhoto => 'Käsitellään valokuvaa';

  @override
  String get itemAddExtractionFailedBody => 'Tunnistaminen epäonnistui';

  @override
  String get itemAddJobFailedBody => 'Käsittely epäonnistui';

  @override
  String get itemAddConnectionLostBody => 'Yhteys katosi. Yritä uudelleen.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Yhteys katosi käsittelyn aikana.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Vaatetuote $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Vaatetuote';

  @override
  String get itemAddNotCancelledTitle => 'Ei peruttu';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vaatetta on nyt kaappissasi.',
      one: '1 vaate on nyt kaappissasi.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved / $total vaatetta tallennettu. Napauta tallennusta yrittääksi loput uudelleen.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Jotkut vaatteet eivät tallenneet';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'Valitse vähintään yksi valokuva.';

  @override
  String get batchPhotoUnreadableBody => 'Tätä valokuvaa ei voitu lukea.';

  @override
  String get batchNoPhotosReadableBody =>
      'Näitä valokuvia ei voitu lukea. Kokeile muita kuvia.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valokuvaa',
      one: '1 valokuva',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Yhteys katosi käsittelyn aikana. Yritä uudelleen.';

  @override
  String get batchNotCancelledTitle => 'Ei peruttu';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Julkaisulinkkejä ei tue. Kirjoita profiililinkeä.';

  @override
  String get batchLinkSpacesBody => 'Linkit eivät voi sisältää välilyöntejä.';

  @override
  String get batchEnterProfileLinkBody =>
      'Kirjoita Instagram- tai Facebook-profiilin linkki.';

  @override
  String get batchEnterProfileLinkShortBody => 'Kirjoita profiilin linkki.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Kirjautumissivu ei auennut. Yritä uudelleen.';

  @override
  String get batchSignInBrowserBody =>
      'Kirjaudu sisään selaimessasi ja palaa FitCheckiin.';

  @override
  String get batchConnectAccountTitle => 'Yhdistä tili';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Syötä koodi autentikaattorisovastuksesta.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram vaatii tietoturvavalvonnan. Kirjaudu ensin sisään selaimessa.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Syötä käyttäjänimi ja salasana uudelleen.';

  @override
  String get batchSignInFailedBody =>
      'Kirjautuminen epäonnistui. Tarkista käyttäjänimi ja salasana.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Kirjaudu sisään jatkaaksesi tuontia.';

  @override
  String get batchAccountNotConnectedBody => 'Tiliä ei yhdistetty.';

  @override
  String get batchAccountConnectedTitle => 'Tili yhdistetty';

  @override
  String get batchNotConnectedTitle => 'Ei yhdistetty';

  @override
  String get batchImportConnectionLostBody =>
      'Yhteys tuontiin katkesi. Päivitä tarkistaaksesi.';

  @override
  String batchPickUpToBody(int max) {
    return 'Valitse enintään $max kuvaa. Me löydämme vaatteet.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return 'Kuva $count/$total';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Kuvaa $done/$count valmiiksi';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Löydä vaatteet $count kuvasta',
      one: 'Löydä vaatteet 1 kuvasta',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return '$platform -tilisi käyttää kaksivaiheista kirjautumista. Syötä 6-numeroinen koodi autentikaattorista.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Tämä $platform -profiili on yksityinen tai vaatii kirjautumisen näytettäväksi.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Yhdistä $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kuvaa löytynyt',
      one: '1 kuva löytynyt',
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
    return '$processed/$total käsitelty · $added lisätty · $waiting odottava · $skipped ohitettu';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Kuvan $number skannaus';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Kuva $number seuraavaksi';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Kuva $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vaate löytynyt',
      one: '1 vaate löytynyt',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kuvaa lisätty pukeellasi.',
      one: '1 kuva lisätty pukeellasi.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count lisästudio-kuvaa tulossa. Voit tallentaa valmiin tai poistua — ilmoitamme sinulle.',
      one:
          '1 lisästudio-kuva tulossa. Voit tallentaa valmiin tai poistua — ilmoitamme sinulle.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Ei tallennettu: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces vaate',
      one: '1 vaate',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos kuvasta',
      one: '1 kuvasta',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen valittu. Napauta vaatetta ohittaaksesi.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tallennetaan $count vaate',
      one: 'Tallennetaan 1 vaate',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tallenna $count vaatekappalet',
      one: 'Tallenna 1 vaatekappale',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Rakeesi profiili on tallennettu.';

  @override
  String get bodyProfileSavedTitle => 'Tallennettu';

  @override
  String get bodyProfileNotSavedTitle => 'Ei tallennettu';

  @override
  String get bodyProfileSetDefaultBody => 'Aseta oletusprofiiliksasi.';

  @override
  String get bodyProfileDeletedBody => 'Rakeesi profiili poistettu.';

  @override
  String get bodyProfileDeletedTitle => 'Poistettu';

  @override
  String get bodyProfileNotDeletedTitle => 'Ei poistettu';

  @override
  String get feedbackNotSentTitle => 'Ei lähetetty';

  @override
  String get feedbackSentBody =>
      'Kiitos. Luki jokaisen viestin ja vastaamme, jos tarvitsemme lisätietoa.';

  @override
  String get feedbackSentTitle => 'Palaute lähetetty';

  @override
  String get recommendUnnamedPiece => 'Nimetön vaatekappale';

  @override
  String get recommendEnterCityBody =>
      'Syötä kaupunkisi, jotta voimme suosittella säätilan mukaan.';

  @override
  String get recommendWhichCityTitle => 'Mikä kaupunki?';

  @override
  String get aiConsentSheetTitle => 'Kuvien jakaminen tekoälypalveluun';

  @override
  String get aiConsentSheetBody =>
      'Suosituksiesi ja valokuvakokonaisuuksien luomiseksi FitCheck AI lähettää sinun tarjoamat valokuvat (mukaan lukien kasvosi ja kehosi kuvat) luotettavalle kolmansille osapuolelle olevalle tekoälypalveluntarjoajalle (kuten OpenAI tai Google Gemini) käsiteltäväksi. Ne generoivat kuvat eikä niitä käytetä mallien koulutukseen ehdottomien ehtojen mukaisesti. Valokuvat siirretään turvallisesti eikä niitä koskaan jaeta mainonnan tarkoituksiin.';

  @override
  String get aiConsentSheetPermission =>
      'Jatkamalla annat nimenomaisen luvan jakaa valokuviasi näillä tekoälypalveluntarjoajilla kuvien generointia varten.';

  @override
  String get skeletonsLoadMoreFailed => 'Enempää ei voitu ladata.';

  @override
  String get jobsPiecesReadyTitle => 'Vaatekappaleesi ovat valmiina';

  @override
  String get jobsScanStoppedTitle => 'Skannaus keskeytyi';

  @override
  String get jobsNothingSavedBody => 'Mitään ei tallennettu. Yritä uudelleen.';

  @override
  String get jobsPhotoUploadFailedBody => 'Valokuvan lataus epäonnistui.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google-kirjautuksen käynnistys epäonnistui. Yritä uudelleen.';

  @override
  String get referralAppliedTitle => 'Suositus lisätty!';

  @override
  String get billingStoreUnavailableBody =>
      'Kaupan ostot eivät ole käytettävissä tässä laitteessa.';

  @override
  String get billingPurchaseProcessingBody =>
      'Tämä ostoa on vielä käsittelemässä. Avaa sovellus uudelleen minuutin kuluttua nähdäksesi tilauksesi.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatarin lataus ei palauttanut kuvan URL-osoitetta.';

  @override
  String get rewardsDayStreakLabel => 'päivän putki';

  @override
  String rewardsBestStreak(int days) {
    return 'Paras $days päivää';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Vaaditaan $permission käyttö';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Pääsy kohteeseen $permission on tällä hetkellä estetty. Avaa asetukset, salli pääsy ja kokeile uudelleen.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Vaihe $step / 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Vaihe $step / $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Poista kuva $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Poista kuva $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pt';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Sähköpostitse $email. Katsomme ilmoituksen 24 tunnin kuluessa.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Poista $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Poista \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Lisää kohteeseen \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" poistettiin. Sen tuotteet säilyvät vaatekaappissasi.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Näytä kaikki ($count)';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count jäljellä tänään';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Kuva $index epäonnistui';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected / $max valittuna';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape vartalo · $tone iho';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Poista $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Asetukset: $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Useimmat käytetyt: $name, $count kertaa';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: ei määritetty';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent % osuma';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked / $max valittuna';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Poista $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency prioriteetti';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Tämä tilaus suoritetaan kautta $store. Muuta tai peruta se $store:n tilausasetuksista.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Hallitse ${store}ssa';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current / $max käytetty';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Noin $seconds s jäljellä';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done / $total studiokuva valmista';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready / $total studiokuva valmista. Napauta kohdetta ohittamaan se.';
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
  String get profileFieldNotSet => 'Ei';
}
