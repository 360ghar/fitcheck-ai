// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Početna';

  @override
  String get tabPhotoshoot => 'Snimanje';

  @override
  String get tabCloset => 'Ormar';

  @override
  String get tabOutfits => 'Kombinacije';

  @override
  String get tabMore => 'Još';

  @override
  String get actionAddItem => 'Dodaj komad';

  @override
  String get actionCreateOutfit => 'Nova kombinacija';

  @override
  String get actionCancel => 'Odustani';

  @override
  String get actionDelete => 'Izbriši';

  @override
  String get actionSave => 'Spremi';

  @override
  String get actionRetry => 'Pokušaj ponovno';

  @override
  String get actionDone => 'Gotovo';

  @override
  String get actionNext => 'Dalje';

  @override
  String get actionBack => 'Natrag';

  @override
  String get actionClose => 'Zatvori';

  @override
  String get actionSearch => 'Pretraži';

  @override
  String get actionContinue => 'Nastavi';

  @override
  String get stateLoading => 'Učitavanje';

  @override
  String get stateErrorTitle => 'Nešto je pošlo po zlu';

  @override
  String get stateErrorBody =>
      'Pokušajte ponovno. Ako se problem nastavi, obratite se podršci.';

  @override
  String get stateOfflineTitle => 'Niste na vezi';

  @override
  String get stateOfflineBody =>
      'Povežite se s internetom za sinkronizaciju ormara i izradu kombinacija.';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get settingsAccountSection => 'Račun';

  @override
  String get settingsPreferencesSection => 'Postavke';

  @override
  String get settingsPlanBilling => 'Pretplata i naplata';

  @override
  String get settingsLanguage => 'Jezik';

  @override
  String get settingsNotifications => 'Obavijesti';

  @override
  String get settingsUnits => 'Mjerne jedinice';

  @override
  String get settingsAppearance => 'Izgled';

  @override
  String get settingsPrivacySection => 'Privatnost i podaci';

  @override
  String get settingsAboutSection => 'O aplikaciji';

  @override
  String get settingsSignOut => 'Odjavi se';

  @override
  String get settingsDeleteAccount => 'Izbriši račun';

  @override
  String get settingsDeleteAccountTitle => 'Izbrisati račun?';

  @override
  String get settingsDeleteAccountBody =>
      'Time ćete trajno ukloniti svoj ormar, kombinacije, fotografije i profil. Radnja se ne može poništiti.';

  @override
  String get settingsUnitsImperial => 'Imperijalne (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metričke (cm, kg)';

  @override
  String get languageTitle => 'Jezik';

  @override
  String get languageSystem => 'Jezik uređaja';

  @override
  String get languageSystemBody => 'FitCheck AI koristi jezik vašeg telefona.';

  @override
  String get languageSearchHint => 'Pretraži jezike';

  @override
  String get languageCurrent => 'Trenutno';

  @override
  String get languageReviewNote =>
      'Ovaj prijevod je nov. Recite nam ako nešto zvuči neprirodno.';

  @override
  String get languageChanged => 'Jezik je ažuriran';

  @override
  String get paywallTitle => 'Odaberite plan';

  @override
  String get paywallTrialBadge => '1 mjesec besplatno';

  @override
  String get paywallTrialTitle => 'Prvi mjesec Pro plana je besplatan';

  @override
  String get paywallTrialBody =>
      'Učitajte cijeli ormar odjednom. Nove komade možete dodavati usput.';

  @override
  String get paywallFreeForeverTitle => 'Besplatno zauvijek';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Kartica nije potrebna. Svaki mjesec dobivate $uploads AI prijenosa, $outfits kombinacija i $images fotografija za snimanje dnevno.';
  }

  @override
  String get paywallCtaTrial => 'Započni besplatni mjesec';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Nadogradi na $plan';
  }

  @override
  String get paywallRestore => 'Obnovi kupnju';

  @override
  String get paywallManage => 'Upravljaj pretplatom';

  @override
  String get paywallTerms => 'Uvjeti korištenja';

  @override
  String get paywallPrivacy => 'Pravila o privatnosti';

  @override
  String get paywallPerMonth => 'mjesečno';

  @override
  String get paywallPerYear => 'godišnje';

  @override
  String get paywallBestValue => 'Najbolja vrijednost';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Besplatno probno razdoblje samo za nove pretplatnike. Nakon probnog razdoblja, Pro se obnavlja po cijeni od $price osim ako se ne otkaže najmanje 24 sata prije isteka.';
  }

  @override
  String get introTitle => 'Vaš ormar, napokon organiziran';

  @override
  String get introBody =>
      'Fotografirajte svoju odjeću jednom. Dobijte ideje za odjevne kombinacije, isprobavanje i studijske fotografije od onoga što već posjedujete.';

  @override
  String get introStart => 'Započni';

  @override
  String get introHaveAccount => 'Već imam račun';

  @override
  String get introSkip => 'Preskoči';

  @override
  String get authSignIn => 'Prijava';

  @override
  String get authSignUp => 'Izradi račun';

  @override
  String get authEmail => 'E-pošta';

  @override
  String get authPassword => 'Lozinka';

  @override
  String get authForgotPassword => 'Zaboravljena lozinka?';

  @override
  String get authContinueApple => 'Nastavi s Appleom';

  @override
  String get authContinueGoogle => 'Nastavi s Googleom';

  @override
  String get authOrDivider => 'ili';

  @override
  String get wardrobeTitle => 'Ormar';

  @override
  String get wardrobeEmptyTitle => 'Vaš ormar je prazan';

  @override
  String get wardrobeEmptyBody =>
      'Dodajte svoj prvi komad ili učitajte fotografiju cijelog ormara odjednom.';

  @override
  String get wardrobeAddFirst => 'Dodaj prvi artikl';

  @override
  String get wardrobeSearchHint => 'Pretraži ormar';

  @override
  String get categoryTops => 'Gornji dijelovi';

  @override
  String get categoryBottoms => 'Donji dijelovi';

  @override
  String get categoryShoes => 'Cipele';

  @override
  String get categoryAccessories => 'Modni dodaci';

  @override
  String get categoryOuterwear => 'Gornja odjeća';

  @override
  String get categorySwimwear => 'Kupaći kostimi';

  @override
  String get categoryActivewear => 'Sportska odjeća';

  @override
  String get categoryOther => 'Ostalo';

  @override
  String get conditionClean => 'Čisto';

  @override
  String get conditionDirty => 'Prljavo';

  @override
  String get conditionLaundry => 'Na pranju';

  @override
  String get conditionRepair => 'Treba popravak';

  @override
  String get conditionDonate => 'Za donaciju';

  @override
  String get seasonSpring => 'Proljeće';

  @override
  String get seasonSummer => 'Ljeto';

  @override
  String get seasonFall => 'Jesen';

  @override
  String get seasonWinter => 'Zima';

  @override
  String get seasonAll => 'Sve sezone';

  @override
  String get styleCasual => 'Ležerno';

  @override
  String get styleFormal => 'Svečano';

  @override
  String get styleBusiness => 'Poslovno';

  @override
  String get styleSporty => 'Sportski';

  @override
  String get styleBohemian => 'Boho';

  @override
  String get styleStreetwear => 'Ulična moda';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistički';

  @override
  String get styleRomantic => 'Romantično';

  @override
  String get styleEdgy => 'Odvažno';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Umjetnički';

  @override
  String get styleClassic => 'Klasično';

  @override
  String get styleElegant => 'Elegantno';

  @override
  String get styleOther => 'Ostalo';

  @override
  String get occasionWork => 'Posao';

  @override
  String get occasionDateNight => 'Izlazak';

  @override
  String get occasionTravel => 'Putovanje';

  @override
  String get occasionWedding => 'Vjenčanje';

  @override
  String get occasionGym => 'Teretana';

  @override
  String get occasionWeekend => 'Vikend';

  @override
  String get occasionParty => 'Zabava';

  @override
  String get occasionInterview => 'Razgovor za posao';

  @override
  String get colorBlack => 'Crna';

  @override
  String get colorWhite => 'Bijela';

  @override
  String get colorGrey => 'Siva';

  @override
  String get colorNavy => 'Tamnoplava';

  @override
  String get colorBrown => 'Smeđa';

  @override
  String get colorRed => 'Crvena';

  @override
  String get colorBlue => 'Plava';

  @override
  String get colorGreen => 'Zelena';

  @override
  String get colorPink => 'Ružičasta';

  @override
  String get colorPurple => 'Ljubičasta';

  @override
  String get colorYellow => 'Žuta';

  @override
  String get colorOrange => 'Narančasta';

  @override
  String get colorBeige => 'Bež';

  @override
  String get dateToday => 'Danas';

  @override
  String get dateYesterday => 'Jučer';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prije $count dana',
      few: 'Prije $count dana',
      one: 'Prije 1 dan',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prije $count tjedana',
      few: 'Prije $count tjedna',
      one: 'Prije 1 tjedan',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prije $count mjeseci',
      few: 'Prije $count mjeseca',
      one: 'Prije 1 mjesec',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prije $count godina',
      few: 'Prije $count godine',
      one: 'Prije 1 godinu',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Volite li FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Kratka ocjena pomaže drugima pronaći svoj stil.';

  @override
  String get ratingPromptYes => 'Ocijeni aplikaciju';

  @override
  String get ratingPromptNo => 'Ne sada';

  @override
  String get closetNoMatchesTitle => 'Nema rezultata';

  @override
  String get closetNoMatchesBody =>
      'Uklonite neke filtre ili pokrenite drugu pretragu.';

  @override
  String get closetClearFilters => 'Ukloni filtre';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count komada',
      few: '$count komada',
      one: '1 komad',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Učitavanje garderobe';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odabranih',
      few: '$count odabrana',
      one: '1 odabrano',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Izbriši odabrano';

  @override
  String get closetCancelSelection => 'Odustani';

  @override
  String get closetCloseSearch => 'Zatvori pretragu';

  @override
  String get closetShowGrid => 'Prikaži kao mrežu';

  @override
  String get closetShowList => 'Prikaži kao popis';

  @override
  String get closetShowRows => 'Prikaži u redovima';

  @override
  String get closetStatsTitle => 'Statistika ormara';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Izbrisati $count komada?',
      few: 'Izbrisati $count komada?',
      one: 'Izbrisati 1 komad?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Ove će komade izgubiti kombinacije koje ih koriste.';

  @override
  String get closetSortBy => 'Sortiraj po';

  @override
  String get closetFavourites => 'Omiljeno';

  @override
  String get closetFavourite => 'Omiljeno';

  @override
  String get closetUnfavourite => 'Ukloni iz omiljenih';

  @override
  String get closetWoreToday => 'Nošeno danas';

  @override
  String closetWornTimes(int count) {
    return 'Nošeno $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategorija';

  @override
  String get closetUseCaseLabel => 'Prigoda';

  @override
  String get closetAnyUseCase => 'Sve';

  @override
  String get closetOtherUseCase => 'Druga prigoda';

  @override
  String get closetOtherUseCaseHint => 'Na primjer, brunch';

  @override
  String get closetUseUseCase => 'Koristi ovo';

  @override
  String get closetClearAll => 'Poništi sve';

  @override
  String get sortNewest => 'Najnovije';

  @override
  String get sortOldest => 'Najstarije';

  @override
  String get sortName => 'Naziv (A–Z)';

  @override
  String get sortMostWorn => 'Najčešće nošeno';

  @override
  String get useCaseInformal => 'Ležerno';

  @override
  String get useCaseDate => 'Spoj';

  @override
  String get useCaseDinner => 'Večera';

  @override
  String get useCaseLunch => 'Ručak';

  @override
  String get actionSelect => 'Odaberi';

  @override
  String get actionEdit => 'Uredi';

  @override
  String get actionFilter => 'Filtriraj';

  @override
  String get actionSort => 'Sortiraj';

  @override
  String get actionAll => 'Sve';

  @override
  String get dashboardStartClosetTitle => 'Započni ormar';

  @override
  String get dashboardStartClosetBody =>
      'Fotografiraj nekoliko komada. Mi ćemo ih označiti umjesto tebe.';

  @override
  String get dashboardPieces => 'komada';

  @override
  String get dashboardOutfits => 'kombinacija';

  @override
  String get dashboardDayStreak => 'dana u nizu';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count ovog mjeseca';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Najbolje $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favorita',
      few: '$count favorita',
      one: '1 favorit',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spremljenih kombinacija',
      few: '$count spremljene kombinacije',
      one: '1 spremljena kombinacija',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Najčešće nošeno: $name, $count puta';
  }

  @override
  String get setupSkip => 'Preskoči postavljanje';

  @override
  String get setupWhoTitle => 'Koga stiliziramo?';

  @override
  String get setupWhoBody =>
      'Postavlja model za isprobavanje i snimanja. Možeš to promijeniti u profilu.';

  @override
  String get setupStyleTitle => 'Što najčešće nosiš?';

  @override
  String get setupStyleBody =>
      'Odaberi bilo što. Ideje za kombinacije kreću od ovoga.';

  @override
  String get setupClosetTitle => 'Dodaj svoje prve komade.';

  @override
  String get setupClosetBody =>
      'Fotografiraj nekoliko komada odjeće ili gomilu. Svaki komad se izrezuje i sprema za tebe.';

  @override
  String get setupAddClothes => 'Dodaj odjeću';

  @override
  String get setupStylesLabel => 'Stilovi';

  @override
  String get setupOccasionsLabel => 'Prigode';

  @override
  String get setupSkipStep => 'Preskoči';

  @override
  String get setupLater => 'Kasnije';

  @override
  String get setupSaveError => 'Spremanje nije uspjelo';

  @override
  String get genderWomen => 'Žene';

  @override
  String get genderMen => 'Muškarci';

  @override
  String get genderNonBinary => 'Neprimarno';

  @override
  String get genderPreferNotToSay => 'Ne želim reći';

  @override
  String get outfitEmptyTitle => 'Još nema kombinacija';

  @override
  String get outfitEmptyBody => 'Uparite komade iz ormara i spremite izgled.';

  @override
  String get outfitNoMatchesTitle => 'Nema odgovarajućih kombinacija';

  @override
  String get outfitSearchHint => 'Pretraži kombinacije';

  @override
  String get outfitLoading => 'Učitavanje kombinacija';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kombinacija',
      few: '$count kombinacije',
      one: '1 kombinacija',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Stil i sezona';

  @override
  String get outfitCollections => 'Kolekcije';

  @override
  String get outfitDuplicate => 'Dupliciraj';

  @override
  String get outfitDeleteTitle => 'Izbrisati ovu kombinaciju?';

  @override
  String get outfitDeleteBody => 'Njezini komadi ostaju u tvom ormaru.';

  @override
  String get outfitDrafts => 'Skice';

  @override
  String get outfitDraft => 'Skica';

  @override
  String get filterStyle => 'Stil';

  @override
  String get filterSeason => 'Sezona';

  @override
  String get itemDetailDeleteTitle => 'Izbrisati ovaj komad?';

  @override
  String get itemDetailDeleteBody =>
      'Kombinacije koje ga koriste izgubit će ovaj komad.';

  @override
  String get itemAddFavourite => 'Dodaj u favorite';

  @override
  String itemSize(String size) {
    return 'Veličina $size';
  }

  @override
  String get itemColours => 'Boje';

  @override
  String get itemMaterial => 'Materijal';

  @override
  String get itemPattern => 'Uzorak';

  @override
  String get itemUseCases => 'Namjena';

  @override
  String get itemKeptIn => 'Drži se u';

  @override
  String get itemPrice => 'Cijena';

  @override
  String get itemBought => 'Kupljeno';

  @override
  String get itemTags => 'Oznake';

  @override
  String get itemAdded => 'Dodano';

  @override
  String get itemTimesWornLabel => 'nošeno puta';

  @override
  String get itemLastWornLabel => 'zadnji put nošeno';

  @override
  String get itemNeverWorn => 'Nikad';

  @override
  String get authEntryBody =>
      'Svaki komad koji posjeduješ, stiliziran uz FitCheck AI. Planiraj odjevne kombinacije, isprobaj ih, uslikaj se.';

  @override
  String get authCreateCloset => 'Izradi svoj ormar';

  @override
  String get authWelcomeBack => 'Dobro došli natrag';

  @override
  String get authSignInBody => 'Prijavi se za otvaranje ormara.';

  @override
  String get authCreateAccount => 'Izradi račun';

  @override
  String get authCreateClosetBody => 'Traje minutu. Prvi komadi su besplatni.';

  @override
  String get authName => 'Ime';

  @override
  String get authConfirmPassword => 'Potvrdi lozinku';

  @override
  String get authReferralCode => 'Kod preporuke (opcionalno)';

  @override
  String get authResetTitle => 'Ponovo postavi lozinku';

  @override
  String get authResetBody =>
      'Poslat ćemo ti poveznicu e-poštom za odabir nove.';

  @override
  String get authSendResetLink => 'Pošalji poveznicu';

  @override
  String get authBackToSignIn => 'Natrag na prijavu';

  @override
  String get authEnterEmail => 'Unesi e-poštu';

  @override
  String get authEnterValidEmail => 'Unesi valjanu e-poštu';

  @override
  String get authEnterPassword => 'Unesi lozinku';

  @override
  String get authPasswordTooShort => 'Najmanje 6 znakova';

  @override
  String get authShowPassword => 'Prikaži lozinku';

  @override
  String get authHidePassword => 'Sakrij lozinku';

  @override
  String get authNewHere => 'Novi si ovdje?';

  @override
  String authConfirmEmail(String email) {
    return 'Potvrdi $email prije prijave. Provjeri pretinac.';
  }

  @override
  String get authResendEmail => 'Pošalji ponovno';

  @override
  String get authResendingEmail => 'Slanje…';

  @override
  String get authPasswordsDoNotMatch => 'Lozinke se ne podudaraju';

  @override
  String get authEnterName => 'Unesi svoje ime';

  @override
  String get authChoosePassword => 'Odaberi lozinku';

  @override
  String get authHaveAccount => 'Već imaš račun?';

  @override
  String get authCodeAccepted => 'Kod je prihvaćen';

  @override
  String get authCodeNotFound => 'Kod nije pronađen';

  @override
  String authReferralFrom(String name) {
    return 'Od $name. Oboje dobivate mjesec dana besplatno.';
  }

  @override
  String get authReferralInvalid => 'Nismo uspjeli pronaći ovaj kod.';

  @override
  String authResetSent(String email) {
    return 'Poslano na $email. Otvori poveznicu na ovom telefonu.';
  }

  @override
  String get introSlide1Title => 'Slikaj ormar jednom.';

  @override
  String get introSlide1Body =>
      'Fotografiraj hrpu odjeće. Svaki komad se izrezuje i sprema za tebe.';

  @override
  String get introSlide2Title => 'Odjeni se brže.';

  @override
  String get introSlide2Body =>
      'Kombinacije od tvoje odjeće, usklađene s planovima i vremenom.';

  @override
  String get introSlide3Title => 'Vidi prije nego odjeneš.';

  @override
  String get introSlide3Body =>
      'Isprobaj kombinacije na svojoj slici ili ih snimi poput kampanje.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sustav';

  @override
  String get settingsThemeLight => 'Svijetlo';

  @override
  String get settingsThemeDark => 'Tamno';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Obavijesti e-poštom';

  @override
  String get settingsEmailUpdatesBody => 'Novosti i savjeti putem e-pošte';

  @override
  String get settingsOutfitReminders => 'Podsjetnici za odjeću';

  @override
  String get settingsOutfitRemindersBody =>
      'Podsjetnik da zabilježiš što si nosio';

  @override
  String get settingsWeeklySummary => 'Tjedni sažetak';

  @override
  String get settingsWeeklySummaryBody =>
      'Tvoj tjedan u odjevnim kombinacijama';

  @override
  String get settingsStyleSection => 'Stil';

  @override
  String get settingsPreferredStyles => 'Stilovi koje voliš';

  @override
  String get settingsPreferredColours => 'Boje koje voliš';

  @override
  String get settingsNoneChosen => 'Ništa odabrano';

  @override
  String get settingsPlanAiSection => 'Plan i AI';

  @override
  String get settingsPlanBillingBody => 'Plan, potrošnja i nadogradnje';

  @override
  String get settingsPlanUsageBody => 'Plan i potrošnja';

  @override
  String get settingsInviteFriends => 'Pozovi prijatelje';

  @override
  String get settingsInviteFriendsBody =>
      'Besplatan mjesec za svakog prijatelja koji se pridruži';

  @override
  String get settingsAiProvider => 'AI pružatelj';

  @override
  String get settingsAiProviderBody =>
      'Koristite vlastiti model za označavanje i slike';

  @override
  String get settingsAppVersion => 'Verzija aplikacije';

  @override
  String get settingsPrivacyTerms => 'Privatnost i uvjeti';

  @override
  String get settingsReportProblem => 'Prijavi problem';

  @override
  String get settingsChangePassword => 'Promijeni lozinku';

  @override
  String get settingsExportData => 'Izvezi svoje podatke';

  @override
  String get settingsExportBody =>
      'Pripremamo datoteku sa svim spremljenim sadržajem i pokrećemo preuzimanje.';

  @override
  String get settingsExportAction => 'Izvezi';

  @override
  String get settingsCurrentPassword => 'Trenutačna lozinka';

  @override
  String get settingsNewPassword => 'Nova lozinka';

  @override
  String get settingsConfirmNewPassword => 'Potvrdi novu lozinku';

  @override
  String get settingsEnterCurrentPassword => 'Unesite trenutačnu lozinku';

  @override
  String get settingsEnterNewPassword => 'Unesite novu lozinku';

  @override
  String get settingsPasswordMin8 => 'Koristite najmanje 8 znakova';

  @override
  String get settingsPasswordNeedsUpper => 'Dodajte veliko slovo';

  @override
  String get settingsPasswordNeedsLower => 'Dodajte malo slovo';

  @override
  String get settingsPasswordNeedsDigit => 'Dodajte broj';

  @override
  String get settingsPasswordsNoMatch => 'Lozinke se ne podudaraju';

  @override
  String get settingsChangeAction => 'Promijeni';

  @override
  String get itemAddSnapTitle => 'Fotografirajte komad';

  @override
  String get itemAddSnapBody =>
      'Pronaći ćemo svaki komad na fotografiji i izraditi čistu studijsku sliku svakog.';

  @override
  String get itemAddCamera => 'Snimi fotografiju';

  @override
  String get itemAddGallery => 'Odaberi iz galerije';

  @override
  String get itemAddOtherWays => 'Drugi načini dodavanja';

  @override
  String get itemAddSeveral => 'Dodaj nekoliko fotografija';

  @override
  String get itemAddSeveralBody => 'Do 50 odjednom';

  @override
  String get itemAddImportProfile => 'Uvezi s profila';

  @override
  String get itemAddImportProfileBody => 'Instagram ili Facebook';

  @override
  String get itemAddEnterDetails => 'Unesi detalje sami';

  @override
  String get itemAddEnterDetailsBody => 'Fotografija nije potrebna';

  @override
  String get itemManualIntro =>
      'Potreban je samo naziv. Dodajte ostalo sada ili kasnije.';

  @override
  String get itemManualNameHint => 'Na primjer, plava pamučna majica';

  @override
  String get itemManualEnterName => 'Unesi naziv';

  @override
  String get itemManualNotes => 'Bilješke';

  @override
  String get itemManualBrand => 'Marka';

  @override
  String get itemManualSize => 'Veličina';

  @override
  String get itemManualEnterNumber => 'Unesi broj';

  @override
  String get itemManualSavePiece => 'Spremi komad';

  @override
  String get itemManualSaving => 'Spremanje';

  @override
  String get itemManualSavedTitle => 'Spremljeno';

  @override
  String itemManualSavedBody(String name) {
    return '$name je u vašem ormaru.';
  }

  @override
  String get itemManualNotSaved => 'Nije spremljeno';

  @override
  String get itemManualAddUseCase => 'Dodaj namjenu';

  @override
  String get itemManualAddUseCaseAction => 'Dodaj namjenu';

  @override
  String get itemPhotos => 'Fotografije';

  @override
  String get itemAddPhotos => 'Dodaj fotografije';

  @override
  String get itemNoPhotoYet => 'Još nema fotografije. Možete spremiti bez nje.';

  @override
  String get itemRemovePhoto => 'Ukloni fotografiju';

  @override
  String get itemRemovePiece => 'Ukloni komad';

  @override
  String get filterConditionLabel => 'Stanje';

  @override
  String get photoshootStepPhotos => 'Fotografije';

  @override
  String get photoshootStepSetup => 'Postavljanje';

  @override
  String get photoshootStepCreating => 'Izrada';

  @override
  String get photoshootStepResults => 'Rezultati';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Korak $current od $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Jedna fotografija nije uspjela. Pokušajte ponovno ispod.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotografija nije uspjelo. Pokušaj ponovno za svaku ispod.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Koliko';

  @override
  String get photoshootYourPrompt => 'Vaš opis';

  @override
  String get photoshootPromptHint => 'Zlatni sat na krovu, lanena košulja';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Izradi $count fotografija',
      few: 'Izradi $count fotografije',
      one: 'Izradi 1 fotografiju',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotografija',
      few: 'fotografije',
      one: 'fotografija',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Nismo mogli provjeriti današnje ograničenje.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan plan: preostaje $remaining od $limit danas';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Besplatno';

  @override
  String get photoshootGallery => 'Galerija';

  @override
  String get photoshootUseCamera => 'Upotrijebi kameru';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Ukloni fotografiju $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Nema vraćenih fotografija';

  @override
  String get photoshootNoPhotosBody =>
      'Snimanje je završilo bez slika. Pokušajte ponovno.';

  @override
  String get photoshootNewStyle => 'Novi stil';

  @override
  String get photoshootNewPhotos => 'Nove fotografije';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Otvori fotografiju $number';
  }

  @override
  String get photoshootReportPhoto => 'Prijavi fotografiju';

  @override
  String get photoshootSaveToGallery => 'Spremi u galeriju';

  @override
  String get actionUpgrade => 'Nadogradi';

  @override
  String get referralLimitTitle => 'Iskoristili ste današnje fotografije';

  @override
  String get referralLimitBody =>
      'Vaše besplatne fotografije vraćaju se sutra. Preporučite prijatelja i oboje dobivate mjesec dana Pro besplatno.';

  @override
  String get referralLimitRefer => 'Preporuči prijatelja';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Aplikacija za spojeve';

  @override
  String get photoshootUsePortfolio => 'Portfelj';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetika';

  @override
  String get photoshootUseCustom => 'Vaš vlastiti opis';

  @override
  String get photoshootDescLinkedin => 'Oštri portreti za posao';

  @override
  String get photoshootDescDating => 'Opušteno, toplo i prirodno';

  @override
  String get photoshootDescPortfolio => 'Urednički, visokomodni izgled';

  @override
  String get photoshootDescInstagram => 'Lifestyle snimke za vaš feed';

  @override
  String get photoshootDescAesthetic => 'Moody, umjetnički kadrovi';

  @override
  String get photoshootDescCustom => 'Opišite izgled koji želite';

  @override
  String get aspectSquare => 'Kvadrat';

  @override
  String get aspectPortrait => 'Portret';

  @override
  String get aspectLandscape => 'Pejzaž';

  @override
  String get aspectTall => 'Visoko';

  @override
  String get aspectWide => 'Široko';

  @override
  String get tryOnAppBar => 'Virtualno isprobavanje';

  @override
  String get tryOnYourPhoto => 'Vaša fotografija';

  @override
  String get tryOnGarment => 'Odjevni predmet';

  @override
  String get tryOnUploadingPhoto => 'Učitavanje vaše fotografije';

  @override
  String get tryOnAddPhotoPrompt => 'Dodajte svoju fotografiju cijelog tijela';

  @override
  String get tryOnBodyPhotoHint =>
      'Fotografija cijelog tijela najbolje funkcionira';

  @override
  String get tryOnAddPhoto => 'Dodaj fotografiju';

  @override
  String get tryOnChangePhoto => 'Promijeni fotografiju';

  @override
  String get tryOnPhotoLoadFailed => 'Nismo mogli učitati vašu fotografiju.';

  @override
  String get tryOnChooseGarment => 'Odaberite fotografiju odjevnog predmeta';

  @override
  String get tryOnChooseOneGarment =>
      'Odaberite jednu fotografiju odjevnog predmeta';

  @override
  String get tryOnGarmentHint =>
      'Fotografija na ravnoj podlozi ili vješalici najbolje funkcionira';

  @override
  String get tryOnChange => 'Promijeni';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Ukloni';

  @override
  String get tryOnLookTitle => 'Izgled';

  @override
  String get tryOnStyle => 'Stil';

  @override
  String get tryOnBackground => 'Pozadina';

  @override
  String get tryOnPose => 'Poza';

  @override
  String get tryOnDressingUp => 'Odijevamo vas. Ovo traje oko pola minute.';

  @override
  String get tryOnEmptyResult =>
      'Vaše virtualno isprobavanje pojavit će se ovdje';

  @override
  String get tryOnReportImage => 'Prijavi sliku';

  @override
  String get tryOnCreating => 'Izrada';

  @override
  String get tryOnTryAgain => 'Pokušaj ponovno';

  @override
  String get tryOnCreate => 'Kreiraj isprobavanje';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio bijela';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio siva';

  @override
  String get tryOnBackgroundUrban => 'Urbana ulica';

  @override
  String get tryOnBackgroundNature => 'Priroda';

  @override
  String get tryOnBackgroundMinimal => 'Minimalno';

  @override
  String get tryOnPoseFront => 'Stojeći sprijeda';

  @override
  String get tryOnPoseSide => 'Stojeći bočno';

  @override
  String get tryOnPoseWalking => 'U hodu';

  @override
  String get dashboardGreetingMorning => 'Dobro jutro';

  @override
  String get dashboardGreetingAfternoon => 'Dobar dan';

  @override
  String get dashboardGreetingEvening => 'Dobra večer';

  @override
  String get dashboardWelcome => 'Dobrodošli';

  @override
  String get dashboardOpenProfile => 'Otvori profil';

  @override
  String get dashboardRailToday => 'Danas';

  @override
  String get dashboardRailRecently => 'Nedavno';

  @override
  String get dashboardActivityEmpty =>
      'Novi komadi i kombinacije pojavit će se ovdje.';

  @override
  String get quickAddPiece => 'Dodaj komad';

  @override
  String get quickAddPieceBody => 'Fotografiraj i označi';

  @override
  String get quickBuildOutfit => 'Složi kombinaciju';

  @override
  String get quickBuildOutfitBody => 'Kombiniraj odjeću';

  @override
  String get quickForYou => 'Za vas';

  @override
  String get quickForYouBody => 'Prijedlozi za danas';

  @override
  String get quickPlanWeek => 'Planiraj tjedan';

  @override
  String get quickPlanWeekBody => 'Kombinacije po danima';

  @override
  String get referralBannerUrgent => 'Ponestaje vam? Pozovite prijatelja.';

  @override
  String get referralBannerTitle => 'Poklonite mjesec, dobijte mjesec.';

  @override
  String get referralBannerBody =>
      'Vi i vaš prijatelj dobivate mjesec dana pretplate Pro.';

  @override
  String get referralBannerDismiss => 'Sakrij na tjedan dana';

  @override
  String get referralBannerShare => 'Podijeli pozivnicu';

  @override
  String get referralBannerCopy => 'Kopiraj poveznicu';

  @override
  String get itemEditPieceTitle => 'Uredi komad';

  @override
  String get itemEditDescriptionLabel => 'Opis';

  @override
  String get itemEditNotSaved => 'Nije spremljeno';

  @override
  String get itemEditSavedTitle => 'Spremljeno';

  @override
  String get itemEditSavedBody => 'Vaše promjene su spremljene.';

  @override
  String get itemEditSavedStalePhotos =>
      'Spremljeno — fotografije možda nisu ažurne';

  @override
  String get itemEditRemovePieceHint =>
      'Izbriši ovaj komad sa stranice predmeta.';

  @override
  String get itemEditNoPhotos =>
      'Još nema fotografija. Dodajte je iz galerije ili kamere.';

  @override
  String get itemEditKeepPhoto => 'Zadrži fotografiju';

  @override
  String get itemEditRemoved => 'Uklonjeno';

  @override
  String get itemEditAddUseCaseAction => 'Dodaj';

  @override
  String get statsNoStatsTitle => 'Još nema statistike';

  @override
  String get statsNoStatsBody =>
      'Dodajte nekoliko komada i ovdje će se prikazati analiza.';

  @override
  String get statsByCategory => 'Po kategorijama';

  @override
  String get statsTotalValue => 'ukupna vrijednost';

  @override
  String get statsMostWorn => 'Najčešće nošeno';

  @override
  String get statsLeastWorn => 'Čeka svoj red';

  @override
  String get statsUnnamedPiece => 'Neimenovani komad';

  @override
  String get jobsTitle => 'Skeniranja';

  @override
  String get jobsEmptyTitle => 'Još nema skeniranja';

  @override
  String get jobsEmptyBody =>
      'Fotografirajte komad i pošaljite ga u pozadinu — rad se nastavlja ovdje.';

  @override
  String get jobsNotCancelled => 'Nije otkazano';

  @override
  String get jobsResume => 'Nastavi';

  @override
  String get jobsReview => 'Pregledaj';

  @override
  String get jobsStop => 'Zaustavi';

  @override
  String get jobsDismiss => 'Odbaci';

  @override
  String get reportTitle => 'Prijavi sadržaj';

  @override
  String reportIntro(String contentType) {
    return 'Reci nam što nije u redu s ovim $contentType. Naš tim pregledava svaku prijavu.';
  }

  @override
  String get reportReasonInappropriate => 'Neprimjereno ili uvredljivo';

  @override
  String get reportReasonNudity => 'Golotinja ili seksualni sadržaj';

  @override
  String get reportReasonHarassment => 'Uznemiravanje ili zlostavljanje';

  @override
  String get reportReasonImpersonation => 'Lažno predstavljanje';

  @override
  String get reportReasonOther => 'Drugo';

  @override
  String get reportDetailsLabel => 'Dodatni detalji (neobavezno)';

  @override
  String get reportSubmit => 'Pošalji prijavu';

  @override
  String get reportSubmittedTitle => 'Prijava poslana';

  @override
  String get reportSubmittedBody =>
      'Hvala. Naš tim će pregledati ovaj sadržaj.';

  @override
  String get reportFailedTitle => 'Prijava nije poslana';

  @override
  String get reportFailedBody => 'Molimo pokušaj ponovno.';

  @override
  String get reportContentTryOnImage => 'AI slika isprobavanja';

  @override
  String get reportContentSharedOutfit => 'podijeljena odjevna kombinacija';

  @override
  String get reportContentPhotoshootImage => 'AI slika snimanja';

  @override
  String get sharedOutfitTitle => 'Podijeljena kombinacija';

  @override
  String get sharedOutfitHideTooltip => 'Sakrij ovu kombinaciju';

  @override
  String get sharedOutfitReportTooltip => 'Prijavi ovu kombinaciju';

  @override
  String get sharedOutfitHideTitle => 'Sakriti ovu kombinaciju?';

  @override
  String get sharedOutfitHideBody =>
      'Ostat će skrivena na ovom uređaju. Možete je i prijaviti kako bi je naš tim pregledao i uklonio.';

  @override
  String get sharedOutfitHideAction => 'Sakrij';

  @override
  String get sharedOutfitHiddenInfo =>
      'Ova se kombinacija više neće prikazivati na ovom uređaju.';

  @override
  String get sharedOutfitHiddenToast => 'Kombinacija skrivena';

  @override
  String get sharedOutfitMissingTitle => 'Ova kombinacija više ne postoji';

  @override
  String get sharedOutfitMissingBody =>
      'Možda je uklonjena ili je poveznica pogrešna.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Sakrili ste ovu kombinaciju';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Ako je neprimjerena, prijavite je putem Privatnosti i uvjeta ili pošaljite e-mail na $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Sviđa vam se ovaj look?';

  @override
  String get sharedOutfitCtaBody =>
      'Slažite slične kombinacije iz vlastitog ormara.';

  @override
  String get sharedOutfitCtaButton => 'Preuzmi FitCheck AI';

  @override
  String get errorTitle => 'Greška';

  @override
  String get errorUnknown => 'Došlo je do neočekivane greške';

  @override
  String get errorNoConnection =>
      'Nema internetske veze. Provjerite svoju mrežu.';

  @override
  String get errorTimeout => 'Zahtjev je istekao. Pokušajte ponovno.';

  @override
  String get errorServerError =>
      'Nešto je pošlo po zlu s naše strane. Pokušajte ponovno.';

  @override
  String get errorBadGateway =>
      'Naš poslužitelj je privremeno nedostupan. Pokušajte ponovno.';

  @override
  String get errorServiceUnavailable =>
      'Usluga je privremeno nedostupan. Pokušajte ponovno uskoro.';

  @override
  String get errorInternalError => 'Nešto je pošlo po zlu. Pokušajte ponovno.';

  @override
  String get errorUnauthorized => 'Prijavite se za nastavak.';

  @override
  String get errorForbidden => 'Nemate pristup tome.';

  @override
  String get errorSessionExpired =>
      'Sesija vam je istekla. Prijavite se ponovno.';

  @override
  String get errorInvalidCredentials => 'E-adresa ili lozinka nisu točni.';

  @override
  String get errorTokenRefreshFailed =>
      'Nismo uspjeli osvježiti vašu sesiju. Prijavite se ponovno.';

  @override
  String get errorRequestCancelled => 'Zahtjev je otkazan.';

  @override
  String get errorInvalidFormat => 'Format datoteke nije podržan.';

  @override
  String get errorFileTooLarge => 'Datoteka je prevelika.';

  @override
  String get errorUploadFailed => 'Prijenos nije uspio. Pokušajte ponovno.';

  @override
  String get errorCacheCorrupted =>
      'Spremljeni podaci su oštećeni i vraćeni su na početne postavke.';

  @override
  String get errorCacheNotFound => 'Još ništa nije spremljeno.';

  @override
  String get errorUserNotFound => 'Nismo pronašli taj račun.';

  @override
  String get errorItemNotFound => 'Taj artikl više ne postoji.';

  @override
  String get errorOutfitNotFound => 'Ta odjevna kombinacija više ne postoji.';

  @override
  String get rewardsTitle => 'Nagrade';

  @override
  String get rewardsNoAchievementsTitle => 'Još nema postignuća';

  @override
  String get rewardsNoAchievementsBody =>
      'Dodajte komade i planirajte odjevne kombinacije da zaradite prvo.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Još nitko nije na ljestvici';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planirajte odjevne kombinacije za bodove i pojavite se ovdje.';

  @override
  String get legalViewPrivacyPolicy => 'Pregledaj pravila privatnosti';

  @override
  String get aiConsentAgree => 'Slažem se i nastavi';

  @override
  String get aiConsentNotNow => 'Ne sada';

  @override
  String get imageViewerCloseTooltip => 'Zatvori preglednik slika';

  @override
  String get updateReadyTitle => 'Ažuriranje spremno';

  @override
  String get updateReadyBody =>
      'Ponovno pokrenite FitCheck AI kako biste primijenili najnovija poboljšanja.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI treba pristup kameri za fotografiranje vaših odjevnih kombinacija i komada odjeće.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI treba pristup galeriji fotografija za odabir slika vaše odjeće i modnih dodataka.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI treba spremiti vaše AI-generirane fotografije odjevnih kombinacija u vašu galeriju.';

  @override
  String get wardrobeSomePhotosSkipped => 'Neke fotografije su preskočene';

  @override
  String get wardrobePhotosNotAdded => 'Fotografije nisu dodane';

  @override
  String get wardrobePhotoNotAdded => 'Fotografija nije dodana';

  @override
  String get wardrobeNotStartedTitle => 'Nije započeto';

  @override
  String get wardrobeNoRoomTitle => 'Nema prostora';

  @override
  String get wardrobeAddPhotosSemantic => 'Dodaj fotografije';

  @override
  String get batchAddTileLabel => 'Dodaj';

  @override
  String get batchProfileLinkLabel => 'Poveznica profila';

  @override
  String get wardrobeImportFromProfileTitle => 'Uvezi s profila';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Dodaj nekoliko fotografija';

  @override
  String get wardrobeClearAction => 'Očisti';

  @override
  String get wardrobeRefreshTooltip => 'Osvježi';

  @override
  String get batchNoPhotosYetTitle => 'Još nema fotografija';

  @override
  String get batchChoosePhotosAction => 'Odaberi fotografije';

  @override
  String get batchWeFindEachPieceBody =>
      'Pronaći ćemo svaki komad i izraditi njegovu studijsku fotografiju.';

  @override
  String get batchPreparingPhotosSemantic => 'Priprema fotografija';

  @override
  String get batchPhotosProcessedSemantic => 'Fotografije obrađene';

  @override
  String get batchPasteProfileLinkTitle => 'Zalijepi poveznicu profila';

  @override
  String get batchPasteProfileLinkBody =>
      'Javni Instagram ili Facebook profil. Skeniramo njegove fotografije, a vi birate što ide u vaš ormar.';

  @override
  String get batchClearLinkTooltip => 'Ukloni poveznicu';

  @override
  String get batchStartingButton => 'Pokretanje';

  @override
  String get batchStartImportAction => 'Pokreni uvoz';

  @override
  String get batchReviewEveryPhotoTitle => 'Vi pregledavate svaku fotografiju';

  @override
  String get batchReviewEveryPhotoBody =>
      'Ništa se ne dodaje dok to ne odobrite.';

  @override
  String get batchPrivateProfilesTitle => 'Privatni profili';

  @override
  String get batchPrivateProfilesBody =>
      'Povežite svoj račun. Instagram traži i korisničko ime i lozinku.';

  @override
  String get batchUseAnotherLinkAction => 'Upotrijebi drugu vezu';

  @override
  String get batchSignInNeededTitle => 'Potrebna prijava';

  @override
  String get batchEnterYourCodeTitle => 'Unesite kod';

  @override
  String get batchUseUsernamePasswordAction =>
      'Upotrijebi korisničko ime i lozinku';

  @override
  String get batchAlreadyConnectedAction => 'Već sam se povezao u pregledniku';

  @override
  String get batchEnterCodeAction => 'Unesi kod';

  @override
  String get batchTryAnotherWayAction => 'Pokušaj na drugi način';

  @override
  String get batchLiveStatus => 'Uživo';

  @override
  String get batchReconnectingStatus => 'Ponovno povezivanje';

  @override
  String get batchSignInToInstagramTitle => 'Prijavite se na Instagram';

  @override
  String get batchUsernameLabel => 'Korisničko ime';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kod, ako koristite dvostupanjsku prijavu';

  @override
  String get batchAuthenticatorCodeBody =>
      'Upotrijebite šesteroznamenkasti kod iz aplikacije za autentifikaciju. Kodovi se brzo mijenjaju.';

  @override
  String get batchVerifyAction => 'Potvrdi';

  @override
  String get batchFindingPhotosTitle => 'Pronalaženje fotografija';

  @override
  String get batchImportPausedTitle => 'Uvoz pauziran';

  @override
  String get batchProcessingPhotosTitle => 'Obrada fotografija';

  @override
  String get batchWaitingNextPhoto => 'Čekanje sljedeće fotografije';

  @override
  String get batchCancelImportAction => 'Otkaži uvoz';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Na ovoj fotografiji nisu pronađeni odjevni predmeti.';

  @override
  String get batchEditPieceColoursLabel => 'Boje, odvojene zarezom';

  @override
  String get batchAddToClosetAction => 'Dodaj u ormar';

  @override
  String get batchSkipPhotoAction => 'Preskoči ovu fotografiju';

  @override
  String get batchImportCompleteTitle => 'Uvoz završen';

  @override
  String get batchImportFailedTitle => 'Uvoz nije uspio';

  @override
  String get batchImportCancelledTitle => 'Uvoz otkazan';

  @override
  String get batchImportErrorBody => 'Nešto je pošlo po zlu tijekom uvoza.';

  @override
  String get batchNothingMoreImportedBody =>
      'S ovog profila se više ništa ne uvozi.';

  @override
  String get batchViewClosetAction => 'Pogledaj ormar';

  @override
  String get batchStartOverAction => 'Kreni ispočetka';

  @override
  String get wardrobeAddPieceTitle => 'Dodaj komad';

  @override
  String get wardrobeAddDetailsTitle => 'Dodaj detalje';

  @override
  String get wardrobeScanningTitle => 'Skeniranje';

  @override
  String get batchReviewPiecesTitle => 'Pregledaj komade';

  @override
  String get wardrobeGalleryAction => 'Galerija';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Novo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Ukloni fotografiju';

  @override
  String get batchRunInBackgroundTooltip => 'Pokreni u pozadini';

  @override
  String get batchStepOneOfTwo => '1. korak od 2';

  @override
  String get batchStepTwoOfTwo => '2. korak od 2';

  @override
  String get batchUploadingPhotosTitle => 'Učitavanje fotografija';

  @override
  String get batchFindingPiecesTitle => 'Pronalaženje komada';

  @override
  String get batchMakingStudioPhotosTitle => 'Izrada studijskih fotografija';

  @override
  String get batchStoppedLabel => 'Zaustavljeno';

  @override
  String get batchFindingPiecesStoppedTitle =>
      'Pronalaženje komada zaustavljeno';

  @override
  String get batchCancelledLabel => 'Otkazano';

  @override
  String get batchAllDoneTitle => 'Sve je spremno';

  @override
  String get batchOpeningPiecesBody => 'Otvaranje vaših komada';

  @override
  String get batchNothingSavedBody => 'Ništa nije spremljeno.';

  @override
  String get batchFindingPiecesFailedBody =>
      'Pronalaženje komada nije uspjelo.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Pronalaženje komada ranije je zaustavljeno.';

  @override
  String get batchStopFindingPiecesTitle => 'Zaustaviti pronalaženje komada?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skeniranje se zaustavlja i ništa se ne sprema. Komadi koji su već pronađeni ostaju u vašoj aktivnosti dok ih ne uklonite.';

  @override
  String get batchKeepGoingAction => 'Nastavi';

  @override
  String get batchTryAgainAction => 'Pokušaj ponovo';

  @override
  String get batchBackToPhotosAction => 'Natrag na fotografije';

  @override
  String get batchSkipAllAction => 'Preskoči sve';

  @override
  String get batchIncludeAllAction => 'Uključi sve';

  @override
  String get batchNoPiecesFoundTitle => 'Nema pronađenih komada';

  @override
  String get batchNoPiecesFoundBody =>
      'Nismo pronašli odjeću na ovim fotografijama.';

  @override
  String get batchChooseOtherPhotosAction => 'Odaberi druge fotografije';

  @override
  String get batchUseCaseHelper => 'Dodano svakom spremljenom komadu.';

  @override
  String get batchDiscardPiecesTitle => 'Odbaciti ove komade?';

  @override
  String get batchDiscardPiecesBody => 'Ništa iz ove serije nije spremljeno.';

  @override
  String get batchKeepAction => 'Zadrži';

  @override
  String get batchDiscardAction => 'Odbaci';

  @override
  String get batchRemovePieceTitle => 'Ukloniti ovaj komad?';

  @override
  String get batchRemovePieceBody => 'Nije spremljeno u tvoj ormar.';

  @override
  String get batchRemoveAction => 'Ukloni';

  @override
  String get batchChoosePiecesToSave => 'Odaberi komade za spremanje';

  @override
  String get batchDiscardAllAction => 'Odbaci sve';

  @override
  String get batchNothingSavedRetryBody =>
      'Ništa nije spremljeno. Pokušaj ponovno.';

  @override
  String get batchNotSavedTitle => 'Nije spremljeno';

  @override
  String get batchSavingLabel => 'Spremanje';

  @override
  String get batchSendToBackgroundAction => 'Pošalji u pozadinu';

  @override
  String get batchStillWorkingMessage =>
      'Još uvijek radimo. Javit ćemo ti kad tvoji komadi budu spremni.';

  @override
  String get batchRunningInBackgroundTitle => 'Radi u pozadini';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studio fotografije su rano zaustavljene. Još uvijek možeš spremiti ove komade.';

  @override
  String get batchTapPieceToSkip => 'Dodirni komad da ga preskočiš.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studio fotografije stižu uskoro. Možeš otići – javit ćemo ti.';

  @override
  String get batchLeaveAction => 'Napusti';

  @override
  String get batchPeopleInPhotosTitle => 'Ljudi na fotografijama';

  @override
  String get batchIncludeAction => 'Uključi';

  @override
  String get batchSkipAction => 'Preskoči';

  @override
  String get batchYourPhotoIsUsedLabel => 'Tvoja fotografija je korištena';

  @override
  String get batchMakingStudioPhotoLabel => 'Izrada studio fotografije';

  @override
  String get batchNoStudioPhotoBody =>
      'Nema studio fotografije. Koristi se tvoja.';

  @override
  String get batchEnterDetailsYourselfAction => 'Unesi podatke ručno';

  @override
  String get batchChooseAnotherPhotoAction => 'Odaberi drugu fotografiju';

  @override
  String get batchConnectionLostTitle => 'Veza je prekinuta';

  @override
  String get batchConnectionLostBody => 'Provjeri vezu pa pokušaj ponovno.';

  @override
  String get batchDailyLimitTitle => 'Dnevni limit dosegnut';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Nadogradi na Pro za više skeniranja ili unesi podatke ručno.';

  @override
  String get batchDailyLimitBodyFree =>
      'Skeniranja se obnavljaju sutra. Sada možeš unijeti podatke ručno.';

  @override
  String get batchSeePlansAction => 'Pogledaj pakete';

  @override
  String get batchAiBusyTitle => 'Naš AI je zauzet';

  @override
  String get batchAiBusyBody =>
      'Problem je s naše strane. Pokušaj ponovno za nekoliko minuta.';

  @override
  String get batchNoPiecesBody =>
      'Pokušaj s jasnijom fotografijom ili unesi podatke ručno.';

  @override
  String get batchScanningUnavailableTitle => 'Skeniranje nije dostupno';

  @override
  String get batchScanningUnavailableBody => 'Za sada unesi podatke ručno.';

  @override
  String get batchScanDidNotFinishTitle => 'Skeniranje nije završeno';

  @override
  String get batchTryAgainBody => 'Pokušaj ponovno.';

  @override
  String get billingTitle => 'Pretplata';

  @override
  String get billingUpgradeHeading => 'Nadogradi paket';

  @override
  String get billingUpgradeOnPlusBody => 'Iste značajke, viši limiti.';

  @override
  String get billingUpgradeBody =>
      'Plus i Pro imaju iste značajke. Odaberi limit koji ti treba.';

  @override
  String get billingWebUnavailableBody =>
      'Online nadogradnje još nisu dostupne. Promo kod ili preporuka i dalje otključavaju Plus ili Pro. Pozovi prijatelje ispod i osvoji besplatne mjesece.';

  @override
  String get billingPlansStale =>
      'Učitavanje najnovijih paketa nije uspjelo. Cijene možda nisu ažurne.';

  @override
  String get billingMonthly => 'Mjesečno';

  @override
  String get billingYearly => 'Godišnje';

  @override
  String get billingCurrentPlan => 'Trenutni paket';

  @override
  String get billingActive => 'Aktivno';

  @override
  String get billingThisMonth => 'Ovaj mjesec';

  @override
  String get billingItemExtractions => 'Izdvajanja predmeta';

  @override
  String get billingOutfitVisualizations =>
      'Vizualizacije odjevnih kombinacija';

  @override
  String get billingNearLimitUpgrade =>
      'Blizu si ovomjesečnog limita. Nadogradi za više.';

  @override
  String get billingNearLimitResets =>
      'Blizu si ovomjesečnog limita. Obnavlja se početkom sljedećeg mjeseca.';

  @override
  String get billingStoreUnavailable =>
      'Nadogradnje još nisu dostupne u trgovini. Provjerite uskoro.';

  @override
  String get billingManageHeading => 'Upravljajte pretplatom';

  @override
  String get billingCancelPlan => 'Otkaži pretplatu';

  @override
  String get billingCancelKeepsAccess =>
      'Zadržavate pristup do kraja ovog obračunskog razdoblja.';

  @override
  String get billingCancelConfirmTitle => 'Otkazati pretplatu?';

  @override
  String get billingKeepPlan => 'Zadrži pretplatu';

  @override
  String get billingCancelPlanAction => 'Otkaži pretplatu';

  @override
  String get billingBilledMonthly => 'Naplaćuje se mjesečno';

  @override
  String get billingBilledYearly => 'Naplaćuje se godišnje';

  @override
  String get billingVirtualTryOn => 'Virtualno isprobavanje';

  @override
  String get billingPrioritySupport => 'Prioritetna podrška';

  @override
  String get billingDisclosureProRenewing =>
      'Pro je pretplata koja se automatski obnavlja';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus i Pro su pretplate koje se automatski obnavljaju';

  @override
  String get billingDisclosureAppleBilling =>
      'Plaćanje se naplaćuje s vašeg Apple ID-ja prilikom potvrde kupnje.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Plaćanje se naplaćuje s vašeg Google Play računa prilikom potvrde kupnje.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Pretplata se automatski obnavlja za isto razdoblje po istoj cijeni osim ako ne isključite automatsku obnovu najmanje 24 sata prije isteka tekućeg razdoblja.';

  @override
  String get billingDisclosureAppleManage =>
      'Upravljajte ili otkažite bilo kada u Postavke › vaš Apple ID › Pretplate.';

  @override
  String get billingDisclosureGoogleManage =>
      'Upravljajte ili otkažite bilo kada u Google Play › Plaćanja i pretplate.';

  @override
  String get billingReferFriend => 'Preporuči prijatelju';

  @override
  String get billingHowItWorks => 'Kako radi';

  @override
  String get billingHowShareTitle => 'Podijelite poveznicu';

  @override
  String get billingHowShareBody => 'Pošaljite je prijatelju.';

  @override
  String get billingHowSignUpTitle => 'Prijavljuju se';

  @override
  String get billingHowSignUpBody =>
      'Vaš prijatelj se pridružuje putem poveznice.';

  @override
  String get billingHowBothTitle => 'Oboje dobivate Pro';

  @override
  String get billingHowBothBody =>
      'Svatko od vas dobiva mjesec dana Pro besplatno.';

  @override
  String get billingYourReferrals => 'Vaše preporuke';

  @override
  String get billingInvited => 'Pozvano';

  @override
  String get billingJoined => 'Pridruženo';

  @override
  String get billingMonthsEarned => 'Zarađeni mjeseci';

  @override
  String get billingInviteFriend => 'Pozovi prijatelja';

  @override
  String get billingInviteBody =>
      'Ti i tvoj prijatelj dobivate mjesec dana pretplate Pro.';

  @override
  String get billingYourCode => 'Tvoj kod';

  @override
  String get billingCopyLink => 'Kopiraj poveznicu';

  @override
  String get billingShareInvite => 'Podijeli pozivnicu';

  @override
  String get giftUnavailable =>
      'Poklon-pozivnice nisu dostupne u ovoj verziji.';

  @override
  String get giftPageTitle => 'Pokloni FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Trenutno nema dostupnih besplatnih poklon-pozivnica.';

  @override
  String get giftFormTitle => 'Pošalji besplatnu pozivnicu';

  @override
  String get giftFormBody =>
      'Primatelj preuzima poklon s pomoću ove provjerene e-adrese. Mi ne šaljemo e-poštu umjesto tebe.';

  @override
  String get giftFieldFrom => 'Od';

  @override
  String get giftFieldRecipientName => 'Ime primatelja';

  @override
  String get giftFieldRecipientEmail => 'E-adresa primatelja';

  @override
  String get giftFieldOccasion => 'Prigoda (neobavezno)';

  @override
  String get giftNoOccasion => 'Bez prigode';

  @override
  String get giftOccasionBirthday => 'Rođendan';

  @override
  String get giftOccasionAnniversary => 'Godišnjica';

  @override
  String get giftOccasionOther => 'Ostalo';

  @override
  String get giftFieldCardGreeting => 'Poruka na čestitki';

  @override
  String get giftFieldCardGreetingHelper =>
      'Ovo se prikazuje na čestitki točno onako kako je napisano.';

  @override
  String get giftFieldPrivateNote => 'Privatna bilješka (neobavezno)';

  @override
  String get giftCreateAction => 'Stvori besplatni poklon';

  @override
  String get giftClaimedTitle => 'Poklon preuzet';

  @override
  String get giftClaimedActive => 'Tvoj poklon FitCheck Pro je aktivan.';

  @override
  String get giftClaimedQueued =>
      'Tvoj poklon FitCheck Pro počinje nakon isteka trenutnog pristupa.';

  @override
  String get giftLinkCopied => 'Poveznica na poklon kopirana u međuspremnik.';

  @override
  String get giftErrorName => 'Unesi ime.';

  @override
  String get giftErrorEmail => 'Unesi valjanu e-adresu.';

  @override
  String get giftErrorGreeting => 'Unesi poruku na čestitki.';

  @override
  String get giftErrorGreetingLength => 'Upotrijebi najviše 80 znakova.';

  @override
  String get giftClaimAction => 'Preuzmi dar';

  @override
  String get giftCardPreview => 'Pregled kartice';

  @override
  String get giftGiftForYou => 'Dar za tebe';

  @override
  String get giftGiftWaiting => 'Dar te čeka';

  @override
  String get giftOpenBody =>
      'Otvorite darove i preuzmite ih s potvrđenom e-adresom.';

  @override
  String get giftOpenGifts => 'Otvori darove';

  @override
  String get giftSendInvitation => 'Pošalji pozivnicu';

  @override
  String get settingsAiProviderSection => 'Pružatelj';

  @override
  String get settingsAiCustom => 'Prilagođeno';

  @override
  String get settingsAiUrlHelper =>
      'Koristite javni URL koji poslužitelj može dosegnuti. Lokalni poslužitelj ne radi s naših poslužitelja.';

  @override
  String get settingsAiConnectionSection => 'Veza';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API ključ';

  @override
  String get settingsAiApiKeySaved =>
      'Spremljeno. Ostavite prazno za zadržavanje.';

  @override
  String get settingsAiChatModel => 'Model za chat';

  @override
  String get settingsAiVisionModel => 'Model za vid (neobavezno)';

  @override
  String get settingsAiImageModel => 'Model za slike (neobavezno)';

  @override
  String get settingsAiImageModelNote =>
      'Generiranje slika zahtijeva chat completions kompatibilne s OpenAI-jem uz response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testiraj vezu';

  @override
  String get calendarTitle => 'Kalendar';

  @override
  String get calendarGoToToday => 'Idi na danas';

  @override
  String get calendarConnectTooltip => 'Poveži kalendar';

  @override
  String get calendarAddEvent => 'Dodaj događaj';

  @override
  String get calendarEmptyTitle => 'Nema planova';

  @override
  String get calendarEmptyBody =>
      'Dodajte događaj i isplanirajte što odjenuti.';

  @override
  String get calendarPreviousMonth => 'Prethodni mjesec';

  @override
  String get calendarNextMonth => 'Sljedeći mjesec';

  @override
  String get calendarAllDay => 'Cijeli dan';

  @override
  String get calendarOutfitLinked => 'Povezana odjevna kombinacija';

  @override
  String get calendarEventOptions => 'Opcije događaja';

  @override
  String get calendarDeleteTitle => 'Izbrisati ovaj događaj?';

  @override
  String get calendarChangeOutfit => 'Promijeni odjevnu kombinaciju';

  @override
  String get calendarLinkOutfit => 'Poveži odjevnu kombinaciju';

  @override
  String get calendarRemoveOutfit => 'Ukloni odjevnu kombinaciju';

  @override
  String get calendarNewEvent => 'Novi događaj';

  @override
  String get calendarEditEvent => 'Uredi događaj';

  @override
  String get calendarTitleLabel => 'Naziv';

  @override
  String get calendarTitleRequired => 'Dodajte naziv';

  @override
  String get calendarEndBeforeStart => 'Završetak nakon početka';

  @override
  String get calendarStarts => 'Početak';

  @override
  String get calendarEnds => 'Završetak';

  @override
  String get calendarPlaceOptional => 'Mjesto (nije obavezno)';

  @override
  String get calendarNotesOptional => 'Bilješke (nisu obavezne)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Sastavite odjevnu kombinaciju, a zatim je povežite s ovim događajem.';

  @override
  String get calendarBuildOutfit => 'Sastavi odjevnu kombinaciju';

  @override
  String get calendarConnectionsTitle => 'Kalendari';

  @override
  String get calendarConnectionsBody =>
      'Događaji koje ovdje dodate ostaju u FitCheck AI.';

  @override
  String get calendarDisconnect => 'Prekini vezu';

  @override
  String get calendarNotAvailable => 'Još nije dostupno';

  @override
  String get profileSectionExplore => 'Istraži';

  @override
  String get profileNavTryOn => 'Isprobavanje';

  @override
  String get profileNavRewards => 'Nagrade';

  @override
  String get profileSupport => 'Podrška';

  @override
  String get profileHelp => 'Pomoć';

  @override
  String get profileAbout => 'O aplikaciji';

  @override
  String get profileAboutBody =>
      'Vaš ormar, odjevne kombinacije i planovi na jednom mjestu.';

  @override
  String get profileSignOutTitle => 'Odjaviti se?';

  @override
  String get profileSignOutBody =>
      'Možete se ponovo prijaviti u bilo kojem trenutku.';

  @override
  String get profileEditTitle => 'Uredi profil';

  @override
  String get profileYourProfile => 'Vaš profil';

  @override
  String get profileBodyProfiles => 'Tjelesni profili';

  @override
  String get profileBodyEmptyTitle => 'Još nema tjelesnih profila';

  @override
  String get profileBodyEmptyBody =>
      'Unesi visinu i građu tijela za bolje pristajanje odjeće.';

  @override
  String get profileBodyAdd => 'Dodaj profil';

  @override
  String get profileBodyDefaultNote =>
      'Tvoj zadani profil koristi se za provjeru veličine i isprobavanje.';

  @override
  String get profileBodyDefaultBadge => 'Zadani';

  @override
  String get profileBodyMakeDefault => 'Postavi kao zadano';

  @override
  String get profileBodyDeleteBody => 'Ovu radnju nije moguće poništiti.';

  @override
  String get profileBodyRequired => 'Obavezno';

  @override
  String get profileBodyCheckNumber => 'Provjeri ovaj broj';

  @override
  String get profileBodyNew => 'Novi tjelesni profil';

  @override
  String get profileBodyNameHint => 'Na primjer, Ja';

  @override
  String get profileBodyHeight => 'Visina';

  @override
  String get profileBodyWeight => 'Težina';

  @override
  String get profileBodyBuild => 'Građa tijela';

  @override
  String get profileBodySkinTone => 'Ton kože';

  @override
  String get profileBirthDateNeededBody =>
      'Dodaj datum rođenja uz vrijeme rođenja.';

  @override
  String get profileBirthDateNeededTitle => 'Potreban je datum rođenja';

  @override
  String get profilePartlySavedBody =>
      'Spremili smo tvoje ime i fotografiju. Podaci o rođenju nisu spremljeni; pokušaj ponovno kasnije.';

  @override
  String get profilePartlySavedTitle => 'Djelomično spremljeno';

  @override
  String get profileSavedBody => 'Tvoj profil je spremljen.';

  @override
  String get profileChangePhoto => 'Promijeni fotografiju profila';

  @override
  String get profilePhotoLabel => 'Profilna fotografija';

  @override
  String get profilePhotoHint => 'Dodirni za odabir nove';

  @override
  String get profileBirthDateLabel => 'Datum rođenja (neobavezno)';

  @override
  String get profileBirthTimeLabel => 'Vrijeme rođenja (neobavezno)';

  @override
  String get profileBirthTimeHelper => 'Čini vedske prijedloge preciznijima';

  @override
  String get profileBirthPlaceLabel => 'Mjesto rođenja (neobavezno)';

  @override
  String get profileBirthPlaceHint => 'Na primjer, Zagreb, Hrvatska';

  @override
  String get profileHelpContactTitle => 'Pitaj nas bilo što';

  @override
  String get profileHelpContactBody =>
      'Pošaljite poruku i odgovorit ćemo vam e-poštom, obično unutar jednog dana.';

  @override
  String get profileHelpContactAction => 'Kontaktirajte podršku';

  @override
  String get profileHelpFaqTitle => 'Česta pitanja';

  @override
  String get profileFaqAddPiecesTitle => 'Kako dodati komade u ormar?';

  @override
  String get profileFaqAddPiecesBody =>
      'Dodirnite Dodaj predmet u kartici Ormar. Snimite fotografiju ili odaberite iz galerije; mi ćemo pronaći svaki komad i označiti ga za vas.';

  @override
  String get profileFaqMatchingTitle => 'Kako radi kombiniranje odjeće?';

  @override
  String get profileFaqMatchingBody =>
      'Otvorite Za vas i odaberite komade koje posjedujete. Predlažemo što ide uz njih i slažemo cijele kombinacije iz vašeg ormara.';

  @override
  String get profileFaqTryOnTitle =>
      'Mogu li koristiti vlastite fotografije za isprobavanje?';

  @override
  String get profileFaqTryOnBody =>
      'Da. Dodajte svoju fotografiju u cijeloj dužini, a zatim odaberite komade kako biste ih vidjeli na sebi.';

  @override
  String get profileFaqRewardsTitle => 'Kako zarađivati nagrade?';

  @override
  String get profileFaqRewardsBody =>
      'Planirajte i često bilježite kombinacije. Nizovi i postignuća rastu kako napredujete.';

  @override
  String get profileFaqPrivacyTitle => 'Je li moj ormar privatan?';

  @override
  String get profileFaqPrivacyBody =>
      'Da. Vaš ormar i kombinacije su privatni osim ako ne podijelite vezu na jednu kombinaciju.';

  @override
  String get profileHelpMoreTitle => 'Više pomoći';

  @override
  String get profileHelpGuides => 'Vodiči';

  @override
  String get profileHelpGuidesBody => 'Kako radi svaka značajka';

  @override
  String get feedbackCategoryBug => 'Nešto se srušilo';

  @override
  String get feedbackCategoryIdea => 'Ideja';

  @override
  String get feedbackCategoryGeneral => 'Općenito';

  @override
  String get feedbackCategoryHelp => 'Trebam pomoć';

  @override
  String get feedbackHintBug =>
      'Što se dogodilo i što ste očekivali? Koraci nam pomažu to popraviti.';

  @override
  String get feedbackHintIdea => 'Što biste željeli i zašto?';

  @override
  String get feedbackHintGeneral =>
      'Recite nam što mislite ili postavite pitanje.';

  @override
  String get feedbackAttachmentLimitBody => 'Možete dodati do 5 slika.';

  @override
  String get feedbackAttachmentLimitTitle => 'Dostignut limit';

  @override
  String get feedbackImageTooLargeBody => 'Odaberite sliku manju od 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Slika je prevelika';

  @override
  String get feedbackTitle => 'Pošaljite povratne informacije';

  @override
  String get feedbackAboutLabel => 'O čemu se radi?';

  @override
  String get feedbackSubjectLabel => 'Predmet';

  @override
  String get feedbackSubjectRequired => 'Dodajte predmet';

  @override
  String get feedbackSubjectTooShort => 'Predmet mora imati najmanje 3 znaka';

  @override
  String get feedbackDetailsLabel => 'Detalji';

  @override
  String get feedbackDetailsRequired => 'Dodajte neke detalje';

  @override
  String get feedbackDetailsTooShort => 'Opis mora imati najmanje 10 znakova';

  @override
  String get feedbackAddScreenshot => 'Dodaj snimku zaslona';

  @override
  String get feedbackAttachmentHint => 'Do 5, svaka do 5 MB';

  @override
  String get feedbackSend => 'Pošalji';

  @override
  String get feedbackEmptyTitle => 'Još ništa poslano';

  @override
  String get feedbackEmptyBody =>
      'Ono što pošaljete pojavit će se ovdje s statusom.';

  @override
  String get feedbackHistoryTitle => 'Što ste poslali';

  @override
  String get feedbackStatusOpen => 'Otvoreno';

  @override
  String get feedbackStatusInProgress => 'U tijeku';

  @override
  String get feedbackStatusResolved => 'Riješeno';

  @override
  String get feedbackStatusClosed => 'Zatvoreno';

  @override
  String get legalIntro =>
      'Kako štitimo vaše podatke i uvjeti korištenja za FitCheck AI.';

  @override
  String get legalPolicies => 'Pravila';

  @override
  String get legalPrivacySubtitle => 'Što prikupljamo i zašto';

  @override
  String get legalTermsTitle => 'Uvjeti korištenja';

  @override
  String get legalTermsSubtitle => 'Pravila korištenja aplikacije';

  @override
  String get legalLicences => 'Licence otvorenog koda';

  @override
  String get legalSupportSubtitle => 'Pomoć, kontakt i zahtjevi za privatnost';

  @override
  String get legalReportAbuse => 'Prijavi problem ili zlouporabu';

  @override
  String get permissionCameraTitle => 'Pristup kameri';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI koristi vašu kameru za snimanje odjeće i odjevnih kombinacija za AI isprobavanje i organizaciju ormara.';

  @override
  String get permissionPhotoTitle => 'Pristup fotografijama';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI treba pristup vašim fotografijama kako biste mogli odabrati slike odjeće za AI značajke i svoj ormar.';

  @override
  String get permissionNotNow => 'Ne sada';

  @override
  String get permissionOpenSettings => 'Otvori postavke';

  @override
  String authSignedInAs(String name) {
    return 'Prijavljeni ste kao $name';
  }

  @override
  String get authSignedIn => 'Prijavljeni ste';

  @override
  String get authWelcomeBackTitle => 'Dobrodošli natrag';

  @override
  String get authSignInFailed => 'Prijava nije uspjela';

  @override
  String get authWelcomeTitle => 'Dobrodošli';

  @override
  String get authSignUpFailed => 'Registracija nije uspjela';

  @override
  String get authGoogleSignInFailed => 'Google prijava nije uspjela';

  @override
  String get authAppleSignInFailed => 'Apple prijava nije uspjela';

  @override
  String get authConfirmEmailTitle => 'Potvrdite e-poštu';

  @override
  String get authConfirmEmailBody =>
      'Provjerite pristiglu poštu za poruku potvrde, a zatim se prijavite.';

  @override
  String get authClosetReady => 'Vaš ormar je spreman.';

  @override
  String get authSignedOutTitle => 'Odjavljeni ste';

  @override
  String get authSignedOutBody => 'Odjavljeni ste iz sustava.';

  @override
  String get authSignOutFailed => 'Odjava nije uspjela';

  @override
  String get authEmailSentTitle => 'E-pošta poslana';

  @override
  String get authResetLinkSent =>
      'Provjerite e-poštu za poveznicu za resetiranje.';

  @override
  String get authPasswordUpdatedTitle => 'Lozinka ažurirana';

  @override
  String get authPasswordUpdated => 'Vaša lozinka je ažurirana.';

  @override
  String get authPasswordNotUpdated => 'Lozinka nije ažurirana';

  @override
  String get authCouldNotSendEmail => 'Slanje e-pošte nije uspjelo';

  @override
  String get authEmailNotSent => 'E-pošta nije poslana';

  @override
  String get authResendSentBody => 'Poslali smo novu e-poštu za potvrdu.';

  @override
  String get outfitPreviewWithAi => 'Pregled s AI';

  @override
  String get outfitNewPreview => 'Nova previja';

  @override
  String get outfitBuilderClosetHeading => 'Tvoj ormarić';

  @override
  String get outfitBuilderSearchHint => 'Pretraži komade';

  @override
  String get outfitClearSearch => 'Očisti pretragu';

  @override
  String get outfitBuilderAddPiecesTitle => 'Prvo dodaj komade';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Odori su sastavljeni od komada iz tvog ormarića.';

  @override
  String get outfitBuilderNoMatches => 'Nema odgovarajućih komada.';

  @override
  String get outfitNameLabel => 'Naziv odora';

  @override
  String get outfitNameHint => 'Npr. Opopan od lanene';

  @override
  String get outfitPreviewSemantic => 'AI pregled odora';

  @override
  String get outfitChoosePieces => 'Odaberi komade';

  @override
  String get outfitTapPiecesHint => 'Dodirni komade ispod za dodavanje.';

  @override
  String get outfitShareTooltip => 'Podijeli';

  @override
  String get outfitSaveFavourite => 'Spremi u omiljene';

  @override
  String get outfitPiecesHeading => 'Komadi';

  @override
  String get outfitWearHistoryEmpty =>
      'Stavi ga jednom i datumi će se prikazati ovdje.';

  @override
  String get outfitWearHistoryTitle => 'Povijest nošenja';

  @override
  String get outfitWearHistoryError => 'Datumi nisu učitani.';

  @override
  String get outfitWornOn => 'Nošeno na';

  @override
  String get outfitEditTitle => 'Uredi odor';

  @override
  String get outfitSavedPhotosFailed =>
      'Detalji su spremljeni, fotografije nisu';

  @override
  String get outfitNoPhotosBody =>
      'Još nema fotografija. Odor prikazuje svoje komade.';

  @override
  String get outfitOccasionLabel => 'Povod';

  @override
  String get outfitOccasionNone => 'Bez povoda';

  @override
  String get outfitTagsHint => 'Odvoj zarezima';

  @override
  String get outfitDraftBody => 'Skriveno iz glavnog popisa';

  @override
  String get outfitPublic => 'Javno';

  @override
  String get outfitPublicBody => 'Svaki s linkom može vidjeti';

  @override
  String get outfitDeleteFromDetail =>
      'Uklonite ovaj odor s detaljne stranice.';

  @override
  String get outfitNewCollection => 'Nova kolekcija';

  @override
  String get outfitNoCollectionsTitle => 'Još nema kolekcija';

  @override
  String get outfitNoCollectionsBody =>
      'Grupirajte odjeću po putovanju, sezoni ili raspoloženju.';

  @override
  String get outfitCreateCollection => 'Napravi kolekciju';

  @override
  String get outfitAddOutfits => 'Dodaj kombinacije';

  @override
  String get outfitRename => 'Preimenuj';

  @override
  String get outfitCollectionDeleteBody => 'Kombinacije ostaju sačuvane.';

  @override
  String get outfitCollectionsNotLoaded => 'Kombinacije se nisu učitale';

  @override
  String get outfitRenameCollection => 'Preimenuj kolekciju';

  @override
  String get outfitDescriptionOptional => 'Opis (neobavezno)';

  @override
  String get outfitAllInCollection =>
      'Sve kombinacije su već u ovoj kolekciji.';

  @override
  String get photoshootSubtitleUpload =>
      'Studijenske portrete iz vlastitih fotografija';

  @override
  String get photoshootSubtitleConfigure => 'Odaberi stil, format i broj';

  @override
  String get photoshootSubtitleGenerating => 'Traje minut-dva';

  @override
  String get photoshootAddPhotosSemantic => 'Dodaj fotografije iz galerije';

  @override
  String get photoshootUploadTitle => 'Dodaj od 1 do 4 fotografije sebe';

  @override
  String get photoshootUploadBody => 'Pritisni za odabir iz galerije';

  @override
  String get photoshootAddToContinue => 'Dodaj fotografiju za nastavak';

  @override
  String get photoshootAddAnotherPhoto => 'Dodaj još jednu fotografiju';

  @override
  String get photoshootTipsTitle => 'Za najbolje rezultate';

  @override
  String get photoshootTipsBody =>
      'Koristi jasne, dobro osvijetljene fotografije lica iz nekoliko kutova. Izbjegni sunčane naočale i kape.';

  @override
  String get photoshootStarting => 'Pokretanje';

  @override
  String get photoshootCancelling => 'Poništavanje';

  @override
  String get photoshootFailed => 'Neuspjelo';

  @override
  String get recommendTabMatches => 'Podudaranja';

  @override
  String get recommendTabComplete => 'Kompletiranje';

  @override
  String get recommendTabWeather => 'Vrijeme';

  @override
  String get recommendTabColours => 'Boje';

  @override
  String get recommendTabShop => 'Prodavnica';

  @override
  String get recommendNoMatchesTitle => 'Još nema podudaranja';

  @override
  String get recommendNoMatchesBody =>
      'Odaberite dio i pronaći ćemo što se s njim dobro slaže.';

  @override
  String get recommendPickPiece => 'Odaberite dio';

  @override
  String get recommendNothingMatchesTitle => 'Nema još ništa u istom stilu';

  @override
  String get recommendNothingMatchesBody =>
      'Pokušajte s drugim dijelovima ili dodajte više u ormar.';

  @override
  String get recommendChangePieces => 'Promijenite odjeću';

  @override
  String get recommendDefaultReason => 'Dobro se slaže s odabranim dijelovima.';

  @override
  String get recommendCompleteTitle => 'Završite look';

  @override
  String get recommendCompleteBody => 'Odaberite dio i popunjit ćemo ostatak.';

  @override
  String get recommendWorking => 'Uradni';

  @override
  String get recommendGenerate => 'Generiraj';

  @override
  String get recommendChooseStyleBody => 'Odaberite stil, a zatim generirajte.';

  @override
  String get recommendNoLooksTitle => 'Nema lookova za ove dijelove';

  @override
  String get recommendNoLooksBody => 'Pokušajte drugi stil ili druge dijelove.';

  @override
  String get recommendDefaultLook => 'Look za vaše odijelo';

  @override
  String get recommendNoPiecesBody => 'Za ovaj look nema vraćenih dijelova.';

  @override
  String get recommendCityLabel => 'Grad';

  @override
  String get recommendCheck => 'Provjeri';

  @override
  String get recommendWeatherTitle => 'Kakvo je vrijeme?';

  @override
  String get recommendWeatherBody => 'Unesite grad za prijedloge za danas.';

  @override
  String get recommendWearToday => 'Nosi danas';

  @override
  String get recommendWeatherNoPieces =>
      'Još nema dijelova u ormaru za ovo vrijeme.';

  @override
  String get recommendBudgetLabel => 'Budžet do';

  @override
  String get recommendLooking => 'Tražim';

  @override
  String get recommendFindWhatToBuy => 'Pronađi što kupiti';

  @override
  String get recommendFillGapsTitle => 'Popunite prazne rupe';

  @override
  String get recommendFillGapsBody =>
      'Postavite budžet i predložit ćemo što vašem ormaru nedostaje.';

  @override
  String get recommendNoGapsTitle => 'Nema praznih';

  @override
  String get recommendNoGapsBody =>
      'Pokušajte veći budžet ili drugu kategoriju.';

  @override
  String get recommendMoodEveryday => 'Svakodnevno';

  @override
  String get recommendMoodBigMeeting => 'Veliki sastanak';

  @override
  String get recommendDayLabel => 'Dan';

  @override
  String get recommendReadingStars => 'Čitanje zvijezda';

  @override
  String get recommendGetMyColours => 'Moje boje';

  @override
  String get recommendLuckyColoursTitle => 'Tvoje srećne boje';

  @override
  String get recommendLuckyColoursBody =>
      'Odaberi dan i predložit ćemo boje i komade.';

  @override
  String get recommendLuckyColoursSection => 'Srećne boje';

  @override
  String get recommendAvoidColoursSection => 'Boje za koje budi oprezna';

  @override
  String get recommendBirthDateTitle => 'Dodaj datum rođenja';

  @override
  String get recommendBirthDateBody =>
      'Za čitanje boja nam je potreban datum rođenja.';

  @override
  String get recommendEditProfile => 'Uredi profil';

  @override
  String get recommendNothingThisDay => 'Za ovaj dan nema prijedloga.';

  @override
  String get recommendUnnamedColour => 'Neimenovana boja';

  @override
  String get recommendFromCloset => 'Iz tvoje ormarice';

  @override
  String get recommendNoPiecesInColours => 'Još nema komada u ovim bojama.';

  @override
  String get recommendOutfitIdeas => 'Ideje za kombinacije';

  @override
  String get recommendNoOutfitsInColours =>
      'Još nema kompletne kombinacije u ovim bojama.';

  @override
  String get recommendDefaultOutfitIdea => 'Ideja za kombinaciju';

  @override
  String get recommendPickUpToThree => 'Odaberi do tri komada';

  @override
  String get recommendEmptyClosetBody =>
      'Prvo dodaj nekoliko komada, pa se vrati za kombinacije.';

  @override
  String get dashboardDressForDay => 'Odevenje za dan koji dolazi.';

  @override
  String get dashboardOutfitOfDay => 'Kombinacija dana';

  @override
  String get dashboardFreshLook => 'Svježi stil';

  @override
  String get subscriptionManageInStoreTitle => 'Upravljanje u trgovini';

  @override
  String get subscriptionManageInStoreBody =>
      'Ovaj plan se naplaćuje putem trgovine. Upravljanje u postavkama računa trgovine.';

  @override
  String get subscriptionCancelledTitle => 'Pretplotka otkažena';

  @override
  String get subscriptionCancelledBody =>
      'Tvoj plan ostaje aktivan do kraja ovog obračunskog razdoblja.';

  @override
  String get subscriptionCancelFailedTitle => 'Puklo je otkazivanje';

  @override
  String get subscriptionCouldNotOpenTitle => 'Nije moguće otvoriti';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Nije moguće otvoriti upravljanje naplatom.';

  @override
  String get subscriptionOpenLinkFailedBody =>
      'Nije moguće otvoriti poveznicu.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Link se nije mogao učitati';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Link za preporuku se nije mogao učitati. Pokušaj ponovno.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopirano';

  @override
  String get subscriptionReferralCopiedBody => 'Link za preporuku je kopiran.';

  @override
  String get subscriptionReferralShareSubject => 'Probaj FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Pridruži se FitCheck AI i oboje dobivate mjesec Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link kopiran';

  @override
  String get subscriptionShareUnavailableBody =>
      'Dijeljenje nije dostupno, pa smo kopirali link.';

  @override
  String get subscriptionShareFailedTitle => 'Dijeljenje nije uspjelo';

  @override
  String get subscriptionShareFailedBody =>
      'Umjesto toga kopirajte link s stranice za preporuku.';

  @override
  String get subscriptionStoreReadyTitle => 'Poslovica je spremna';

  @override
  String get subscriptionStoreReadyBody =>
      'Cijene u trgovini su dostupne. Sada nadograđuje.';

  @override
  String get purchaseFailedTitle => 'Kupnja nije uspjela';

  @override
  String get purchaseUnavailableTitle => 'Kupnja nije dostupna';

  @override
  String get purchaseIapUnavailableBody =>
      'Ugradbeni dodaci nisu dostupni na ovom uređaju.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Ovaj plan još nije dostupan za kupnju.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Ovaj plan još nije dostupan u trgovini. Vratite se uskoro.';

  @override
  String get purchaseStartFailedBody =>
      'Kupnja nije uspjela započeti. Pokušaj ponovno.';

  @override
  String get purchaseNoPaymentLinkBody => 'Kasa nije vratila link za plaćanje.';

  @override
  String get purchasePendingTitle => 'Kupnja u tijeku';

  @override
  String get purchasePendingBody =>
      'Tvoja kupnja čeka odobrenje. Dostup bit će odmah nakon odobrenja.';

  @override
  String get purchaseFailedBody => 'Kupnja nije uspjela. Pokušaj ponovno.';

  @override
  String get purchaseRestoredTitle => 'Vraćeno';

  @override
  String get purchaseRestoredBody => 'Tvoje kupnje su vraćene.';

  @override
  String get purchaseActiveTitle => 'pretplata aktivna';

  @override
  String get purchaseActiveBody => 'Tvoja pretplata je aktivna. Dobrodošli.';

  @override
  String get purchaseSignInRequiredTitle => 'Potrebno je prijava';

  @override
  String get purchaseSignInRequiredBody => 'Prijavi se za završetak kupnje.';

  @override
  String get purchaseErrorTitle => 'Pogreška pri kupnji';

  @override
  String get purchaseInvalidTransactionBody =>
      'Kupnja nije sadržavala provjerljiv ID transakcije.';

  @override
  String get purchaseVerificationPendingTitle => 'Provjera u tijeku';

  @override
  String get purchaseVerificationPendingBody =>
      'Upravo ne možemo potvrditi vašu kupnju kod trgovine. Proces će se dovršiti automatski, a neće vas se naplatiti duplo.';

  @override
  String get purchaseNotAppliedTitle => 'Kupnja nije primijenjena';

  @override
  String get purchaseNotAppliedBody =>
      'Vaša kupnja nije primijenjena na vaš račun. Kontaktirajte podršku i nemojte ponovno kupovati.';

  @override
  String get purchaseRestoreFailedTitle => 'Vrsta nije uspjela';

  @override
  String get purchaseRestoreFailedBody =>
      'Kupnje se nisu mogle vratiti. Pokušajte ponovno.';

  @override
  String get purchaseRecoveredActiveBody => 'Vaša pretplatnja je aktivna.';

  @override
  String get purchaseCompleteTitle => 'Kupnja završena';

  @override
  String get giftCreateFailedTitle => 'Poklon se nije mogao izraditi';

  @override
  String get giftClaimFailedTitle => 'Poklon se nije mogao preuzeti';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count poklona za vas',
      one: 'Poklon za vas',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mjesec',
      '12': '1 godina',
      'other': '$months mjeseci',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'ostaje $remaining',
      few: 'ostaje $remaining',
      one: 'ostaje 1',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro-a';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender vam je poslao $duration FitCheck Pro-a. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'FitCheck Pro poklon za $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Od $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Za $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Od $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'primatelj';

  @override
  String get giftPreviewPlaceholderSender => 'vi';

  @override
  String get settingsSavedTitle => 'Spremljeno';

  @override
  String get settingsNotSavedTitle => 'Nije spremljeno';

  @override
  String get settingsAiChooseProviderBody => 'Odaberite dobavljača.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Za prilagođenog dobavljača potreban je URL API-ja.';

  @override
  String get settingsAiKeyRequiredBody => 'Unesite ključ API-ja.';

  @override
  String get settingsAiSavedBody => 'Vaše postavke AI-ja su spremljene.';

  @override
  String get settingsAiMissingDetailsTitle => 'Nedostaju podaci';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Unesite URL API-ja i model chata za testiranje.';

  @override
  String get settingsAiKeyNeededTitle => 'Potreban je ključ API-ja';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Unesite svoj ključ za testiranje. Vaš spremljeni ključ ostaje privatna stvar.';

  @override
  String get settingsAiKeyToTestBody => 'Unesite svoj ključ za testiranje.';

  @override
  String get settingsAiConnectedTitle => 'Povezano';

  @override
  String get settingsAiConnectedBody => 'Povezina radi.';

  @override
  String get settingsAiTestFailedTitle => 'Test nije uspio';

  @override
  String get settingsPreferencesSavedBody => 'Vaše postavke su spremljene.';

  @override
  String get settingsPasswordNotChangedTitle => 'Lozinka nije promijenjena';

  @override
  String get settingsOAuthPasswordBody =>
      'Ovaj se račun prijavljuje putem Googlea ili Applea. Koristite opciju \"Zaboravljena lozinka\" za prvo postavljanje lozinke.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Trenutna lozinka je netočna.';

  @override
  String get settingsExportReadyTitle => 'Izvoz spreman';

  @override
  String get settingsExportReadyBody =>
      'Vaš izvoz podataka je spreman za preuzimanje.';

  @override
  String get settingsLinkCopiedTitle => 'Poveznica kopirana';

  @override
  String get settingsExportClipboardBody =>
      'Nismo uspjeli otvoriti preglednik, pa smo kopirali link za preuzimanje. Umetnite ga u preglednik ubrzo: istječe.';

  @override
  String get settingsExportFailedTitle => 'Izvoz nije uspio';

  @override
  String get settingsAccountNotDeletedTitle => 'Račun nije izbrisan';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Možete dodati do $max fotografija.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limit fotografija';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Dodajte barem jednu fotografiju.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Nema fotografija';

  @override
  String get photoshootDescribeLookBody => 'Opišite look koji želite.';

  @override
  String get photoshootPromptNeededTitle => 'Potreban opis';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Priprema fotografija';

  @override
  String get photoshootStatusGenerating => 'Generiranje';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Serijska $current od $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'Gotovo $done od $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generiranje nije uspjelo.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready spremno, $failed nije uspjelo.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Djelomice gotovo';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografija je spremno.',
      one: '1 fotografija je spremna.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Povezanje je prekinuto. Pokušajte ponovno.';

  @override
  String get photoshootCouldNotCancelTitle => 'Otkazivanje nije uspjelo';

  @override
  String get photoshootRetryFailedTitle => 'Ponovni pokušaj nije uspio';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Fotografija $number je spremna.';
  }

  @override
  String get photoshootReplacedTitle => 'Zamijenjeno';

  @override
  String get photoshootSavedToGalleryBody => 'Spremljeno u vašu galeriju.';

  @override
  String get photoshootSavedTitle => 'Spremljeno';

  @override
  String get photoshootNotSavedTitle => 'Nije spremljeno';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sve $count fotografije su u vašoj galeriji.',
      one: '1 fotografija je u vašoj galeriji.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved od $total spremljeno.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Nekoliko fotografija nije spremljeno';

  @override
  String get tryonConsentFeatureLabel => 'Virtualni proba';

  @override
  String get tryonAvatarUpdatedBody => 'Vaša fotografija je ažurirana.';

  @override
  String get tryonSavedTitle => 'Spremljeno';

  @override
  String get tryonUploadFailedTitle => 'Prenos nije uspio';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Prvo odaberite fotografiju odjeće.';

  @override
  String get tryonNoGarmentTitle => 'Nema odjeće';

  @override
  String get tryonWaitForUploadBody =>
      'Pričekajte dok se vaša fotografija ne prenese.';

  @override
  String get tryonStillUploadingTitle => 'Još se prenosi';

  @override
  String get tryonAddYourPhotoFirstBody => 'Prvo dodajte svoju fotografiju.';

  @override
  String get tryonReadyBody => 'Vaša proba je spremna.';

  @override
  String get tryonFailedTitle => 'Proba nije uspjela';

  @override
  String get tryonSavedToGalleryBody => 'Spremljeno u vašu galeriju.';

  @override
  String get tryonNotSavedTitle => 'Nije spremljeno';

  @override
  String get calendarEventAddedBody => 'Događaj dodan';

  @override
  String get calendarEventPlannedTitle => 'Planirano';

  @override
  String get calendarEventSavedBody => 'Događaj spremljen';

  @override
  String get calendarSavedTitle => 'Spremljeno';

  @override
  String get calendarEventNotSavedTitle => 'Događaj nije spremljen';

  @override
  String get calendarEventRemovedBody => 'Događaj uklonjen';

  @override
  String get calendarEventDeletedTitle => 'Izbrisano';

  @override
  String get calendarEventNotDeletedTitle => 'Događaj nije izbrisan';

  @override
  String get calendarOutfitNotLinkedTitle => 'Odijelo nije povezano';

  @override
  String get calendarLinkedTitle => 'Povezano';

  @override
  String get calendarOutfitNotRemovedTitle => 'Odijelo nije uklonjeno';

  @override
  String get calendarOutfitRemovedBody => 'Odijelo uklonjeno';

  @override
  String get calendarDisconnectedBody => 'Kalendar odspojen';

  @override
  String get calendarDisconnectedTitle => 'Odspojeno';

  @override
  String get calendarNotDisconnectedTitle => 'Kalendar nije odspojen';

  @override
  String get calendarTodayLabel => 'danas';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count događaja',
      one: '1 događaj',
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
    return '$title, $time, odijelo povezano';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return 'Događaj \"$title\" bit će uklonjen.';
  }

  @override
  String get calendarThisAppLabel => 'Ova aplikacija';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Sinkronizacija s $provider još nije dostupna. Događaje možete nastaviti dodavati ovdje.';
  }

  @override
  String get calendarWeekdaySunShort => 'Ned';

  @override
  String get calendarWeekdayMonShort => 'Pon';

  @override
  String get calendarWeekdayTueShort => 'Uto';

  @override
  String get calendarWeekdayWedShort => 'Sri';

  @override
  String get calendarWeekdayThuShort => 'Čet';

  @override
  String get calendarWeekdayFriShort => 'Pet';

  @override
  String get calendarWeekdaySatShort => 'Sub';

  @override
  String get calendarWeekdayMonday => 'Ponedjeljak';

  @override
  String get calendarWeekdayTuesday => 'Utorak';

  @override
  String get calendarWeekdayWednesday => 'Srijeda';

  @override
  String get calendarWeekdayThursday => 'Četvrtak';

  @override
  String get calendarWeekdayFriday => 'Petak';

  @override
  String get calendarWeekdaySaturday => 'Subota';

  @override
  String get calendarWeekdaySunday => 'nedjelja';

  @override
  String get outfitSavedToFavouritesBody => 'Spremljeno u favorite';

  @override
  String get outfitRemovedFromFavouritesBody => 'Uklonjeno iz favorita';

  @override
  String get outfitNotSavedTitle => 'Nije spremljeno';

  @override
  String get outfitLoggedAsWornBody => 'Označeno kao nošeno danas.';

  @override
  String get outfitNicePickTitle => 'Odličan izbor';

  @override
  String get outfitRemovedBody => 'Styling uklonjen.';

  @override
  String get outfitDeletedTitle => 'Izbrisano';

  @override
  String get outfitNotDeletedTitle => 'Nije izbrisano';

  @override
  String get outfitDuplicatedBody => 'Kopija je u vašim stilovima.';

  @override
  String get outfitDuplicatedTitle => 'Duplicirano';

  @override
  String get outfitNotDuplicatedTitle => 'Nije duplicirano';

  @override
  String get outfitNotSharedTitle => 'Nije podijeljeno';

  @override
  String outfitCollectionReadyBody(String name) {
    return '„$name” je spremno.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Kolekcija nije stvorena';

  @override
  String get outfitCollectionUpdatedBody => 'Kolekcija ažurirana.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Kolekcija nije ažurirana';

  @override
  String get outfitCollectionDeletedBody => 'Kolekcija izbrisana.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Kolekcija nije izbrisana';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dodanih stilova.',
      one: 'dodano 1 styling.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Stilovi nisu dodani';

  @override
  String get outfitPreviewNotCreatedTitle => 'Pregled nije stvoren';

  @override
  String get outfitGiveNameBody => 'Dajte stilu naziv.';

  @override
  String get outfitNameMissingTitle => 'Naziv';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Odaberite barem jedan komad.';

  @override
  String outfitCreatedBody(String name) {
    return '$name je u vašim stilovima.';
  }

  @override
  String get outfitSavedTitle => 'Spremljeno';

  @override
  String get wardrobeAddedToFavouritesBody => 'Dodano u favorite';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Uklonjeno iz favorita';

  @override
  String get wardrobeNotSavedTitle => 'Nije spremljeno';

  @override
  String get wardrobeLoggedAsWornBody => 'Označeno kao nošeno danas.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Uklonjeno iz vašeg ormara.';

  @override
  String get wardrobeDeletedTitle => 'Izbrisano';

  @override
  String get wardrobeNotDeletedTitle => 'Nije izbrisano';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predmeta uklonjena iz vašeg ormara.',
      one: '1 predmet uklonjen iz vašeg ormara.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI ekstrakcija ormana';

  @override
  String get itemAddScanJobLabel => 'Skeniranje';

  @override
  String get itemAddFoundEarlierBody => 'Pronađeno u ranijem skeniranju';

  @override
  String get itemAddLookingAtPhoto => 'Obrada vaše fotografije';

  @override
  String get itemAddExtractionFailedBody => 'Ekstrakcija nije uspjela';

  @override
  String get itemAddJobFailedBody => 'Rad nije uspio';

  @override
  String get itemAddConnectionLostBody =>
      'Povezani je izgubljen. Pokušajte ponovno.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Povezani je izgubljen tijekom obrade.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Predmet $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Predmet';

  @override
  String get itemAddNotCancelledTitle => 'Nije otkazano';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count predmeta su u vašem ormaru.',
      one: '1 predmet je u vašem ormaru.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved od $total predmeta spremljeno. Dodirnite spremanje za pokušaj ostataka.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Neki predmeti nisu spremljeni';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'Odaberite barem jednu fotografiju.';

  @override
  String get batchPhotoUnreadableBody =>
      'Ova fotografija se ne može pročitati.';

  @override
  String get batchNoPhotosReadableBody =>
      'Nijedna od ovih fotografija se ne može pročitati. Pokušajte s drugim.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografije',
      one: '1 fotografija',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Povezani je izgubljen tijekom rada. Pokušajte ponovno.';

  @override
  String get batchNotCancelledTitle => 'Nije otkazano';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Poveznice na objave nisu podržane. Unesite poveznicu na profil.';

  @override
  String get batchLinkSpacesBody => 'Poveznice ne smiju sadržavati razmake.';

  @override
  String get batchEnterProfileLinkBody =>
      'Unesite link na Instagram ili Facebook profil.';

  @override
  String get batchEnterProfileLinkShortBody => 'Unesite link na profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Stranica za prijavu se nije otvorila. Pokušajte ponovno.';

  @override
  String get batchSignInBrowserBody =>
      'Prijavite se u pregledniku, zatim se vratite u FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Povežite svoj račun';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Unesite kod iz aplikacije za autenticiranje.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram traži provjeru sigurnosti. Prvo se prijavite u pregledniku.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Unesite svoje korisničko ime i lozinku ponovno.';

  @override
  String get batchSignInFailedBody =>
      'Prijava nije uspjela. Provjerite korisničko ime i lozinku.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Prijavite se za nastavak uvoza.';

  @override
  String get batchAccountNotConnectedBody => 'Račun nije povezan.';

  @override
  String get batchAccountConnectedTitle => 'Račun povezan';

  @override
  String get batchNotConnectedTitle => 'Nije povezano';

  @override
  String get batchImportConnectionLostBody =>
      'Izgubili smo povezivanje s uvozom. Osvježite da biste provjerili.';

  @override
  String batchPickUpToBody(int max) {
    return 'Odaberite do $max fotografija. Mi nalazimo komade.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count od $total fotografija';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Priprema fotografije $done od $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pronađi komade na $count fotografija',
      one: 'Pronađi komade na 1 fotografiji',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Vaš $platform račun koristi dvostupanjsku prijavu. Unesite 6-znamenkasti kod iz aplikacije za autenticiranje.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Ovaj $platform profil je privatan ili zahtijeva prijavu za prikaz fotografija.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Poveži se s $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pronađeno $count fotografija',
      one: 'Pronađena 1 fotografija',
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
    return '$processed od $total obrađeno · $added dodano · $waiting na čekanju · $skipped preskočeno';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Skeniranje fotografije $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Fotografija $number je sljedeća';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Fotografija $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pronađeno $count komada',
      one: 'Pronađen 1 komad',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografija dodano je u vaš ormar.',
      one: '1 fotografija dodana je u vaš ormar.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count studijskih fotografija na putu. Spremno možete spremiti ili otići — javit ćemo vam se.',
      one:
          'Još 1 studijska fotografija na putu. Spremno možete spremiti ili otići — javit ćemo vam se.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Još nije spremljeno: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces komada',
      one: '1 komad',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotografija',
      one: '1 fotografije',
    );
    return '$_temp0 iz $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return 'Odabrano $chosen. Dodirnite komad za preskakanje.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spremanje $count komada',
      one: 'Spremanje 1 komada',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spremi $count komada',
      many: 'Spremi $count komada',
      few: 'Spremi $count komada',
      one: 'Spremi 1 komad',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Profili tijela su spremljeni.';

  @override
  String get bodyProfileSavedTitle => 'Spremljeno';

  @override
  String get bodyProfileNotSavedTitle => 'Nije spremljeno';

  @override
  String get bodyProfileSetDefaultBody => 'Postavi kao zadani profil.';

  @override
  String get bodyProfileDeletedBody => 'Profil tijela je obrisano.';

  @override
  String get bodyProfileDeletedTitle => 'Obrisano';

  @override
  String get bodyProfileNotDeletedTitle => 'Nije obrisano';

  @override
  String get feedbackNotSentTitle => 'Nije poslano';

  @override
  String get feedbackSentBody =>
      'Hvala. Čitamo svaku poruku i odgovaramo kad nam treba više.';

  @override
  String get feedbackSentTitle => 'Povratna informacija poslana';

  @override
  String get recommendUnnamedPiece => 'Naslovljen komad';

  @override
  String get recommendEnterCityBody => 'Unesite grad za prijedloge po vremenu.';

  @override
  String get recommendWhichCityTitle => 'Koji grad?';

  @override
  String get aiConsentSheetTitle => 'Dijeljenje fotografija s AI uslugom';

  @override
  String get aiConsentSheetBody =>
      'Za izradu virtualnih probiraj i fotografija, FitCheck AI šalje vaše fotografije (uključujući slike lica i tijela) pouzdanoj trećoj strana AI pružatelju (npr. OpenAI ili Google Gemini) za obradu. One generiraju vaše slike i ne koriste ih za obuku svojih modela prema našim uvjetima. Fotografije se prijenose sigurno i nikad ne dijele za reklame.';

  @override
  String get aiConsentSheetPermission =>
      'Nastavkom dajete izričito dopuštenje za dijeljenje fotografija s ovim AI pružateljima za generiranje slika.';

  @override
  String get skeletonsLoadMoreFailed => 'Ne mogu učitati više.';

  @override
  String get jobsPiecesReadyTitle => 'Vaši komadi su spremni';

  @override
  String get jobsScanStoppedTitle => 'Skeniranje je stalo';

  @override
  String get jobsNothingSavedBody =>
      'Ništa nije spremljeno. Pokušajte ponovno.';

  @override
  String get jobsPhotoUploadFailedBody => 'Pregled fotografije nije uspio.';

  @override
  String get authGoogleSignInStartFailed =>
      'Ne mogu pokrenuti prijavu s Googleom. Pokušajte ponovno.';

  @override
  String get referralAppliedTitle => 'Preporuka primijenjena!';

  @override
  String get billingStoreUnavailableBody =>
      'Nabavke iz trgovine nisu dostupne na ovom uređaju.';

  @override
  String get billingPurchaseProcessingBody =>
      'Ova kupnja se još uvijek obrađuje. Otvorite aplikaciju za minutu da vidite svoj plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Pregled avatara nije vratio URL slike.';

  @override
  String get rewardsDayStreakLabel => 'dana niza';

  @override
  String rewardsBestStreak(int days) {
    return 'Najbolje $days dana';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Potrebna dozvola $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Pristup opciji $permission je trenutno odbijen. Otvori Postavke, omogući ga, pa se vrati i pokušaj ponovno.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Korak $step od 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Korak $step od $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Ukloni sliku $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Ukloni sliku $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points bodova';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Pošalji email na $email. Prijavu pregledavamo u roku od 24 sata.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Ukloni $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Izbrisati \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Dodaj u \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" je uklonjen. Dijelovi i dalje ostaju u tvojoj ormanu.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Prikaži svih $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Preostalo danas: $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Slika $index nije uspjela';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected od $max slika';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape građa · $tone ten';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Izbrisati $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opcije za $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Najčešće nošeno: $name, $count puta';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: nije postavljeno';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% podudaranja';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'Odabrano $picked od $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Ukloni $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency prioritet';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Ovaj plan se naplaćuje preko trgovine $store. Promijeni ili otkaži ga u postavkama svog računa u trgovini $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Upravljanje u trgovini $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: korišteno $current od $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Preostalo otprilike ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done od $total studijskih fotografija je spremno';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready od $total studijskih fotografija je spremno. Dodirni komad za preskakanje.';
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
