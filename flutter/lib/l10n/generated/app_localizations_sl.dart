// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Domov';

  @override
  String get tabPhotoshoot => 'Slikanje';

  @override
  String get tabCloset => 'Omara';

  @override
  String get tabOutfits => 'Kombinacije';

  @override
  String get tabMore => 'Več';

  @override
  String get actionAddItem => 'Dodaj kos';

  @override
  String get actionCreateOutfit => 'Ustvari kombinacijo';

  @override
  String get actionCancel => 'Prekliči';

  @override
  String get actionDelete => 'Izbriši';

  @override
  String get actionSave => 'Shrani';

  @override
  String get actionRetry => 'Poskusi znova';

  @override
  String get actionDone => 'Končano';

  @override
  String get actionNext => 'Naprej';

  @override
  String get actionBack => 'Nazaj';

  @override
  String get actionClose => 'Zapri';

  @override
  String get actionSearch => 'Išči';

  @override
  String get actionContinue => 'Nadaljuj';

  @override
  String get stateLoading => 'Nalaganje';

  @override
  String get stateErrorTitle => 'N nekaj je šlo narobe';

  @override
  String get stateErrorBody =>
      'Poskusite znova. Če težava ni odpravljena, se obrnite na podporo.';

  @override
  String get stateOfflineTitle => 'Niste povezani';

  @override
  String get stateOfflineBody =>
      'Vzpostavite povezavo za sinhronizacijo omare in ustvarjanje kombinacij.';

  @override
  String get settingsTitle => 'Nastavitve';

  @override
  String get settingsAccountSection => 'Račun';

  @override
  String get settingsPreferencesSection => 'Možnosti';

  @override
  String get settingsPlanBilling => 'Naročnina in plačila';

  @override
  String get settingsLanguage => 'Jezik';

  @override
  String get settingsNotifications => 'Obvestila';

  @override
  String get settingsUnits => 'Merske enote';

  @override
  String get settingsAppearance => 'Videz';

  @override
  String get settingsPrivacySection => 'Zasebnost in podatki';

  @override
  String get settingsAboutSection => 'O aplikaciji';

  @override
  String get settingsSignOut => 'Odjava';

  @override
  String get settingsDeleteAccount => 'Izbriši račun';

  @override
  String get settingsDeleteAccountTitle => 'Želite izbrisati račun?';

  @override
  String get settingsDeleteAccountBody =>
      'To odstrani vašo omaro, kombinacije, fotografije in profil. Tega ni mogoče razveljaviti.';

  @override
  String get settingsUnitsImperial => 'Imperialne (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrične (cm, kg)';

  @override
  String get languageTitle => 'Jezik';

  @override
  String get languageSystem => 'Uporabi jezik naprave';

  @override
  String get languageSystemBody =>
      'FitCheck AI prevzame jezik vašega telefona.';

  @override
  String get languageSearchHint => 'Išči jezike';

  @override
  String get languageCurrent => 'Trenutni';

  @override
  String get languageReviewNote =>
      'Ta prevod je nov. Sporočite nam, če kaj zveni neustrezno.';

  @override
  String get languageChanged => 'Jezik je posodobljen';

  @override
  String get paywallTitle => 'Izberite paket';

  @override
  String get paywallTrialBadge => '1 mesec brezplačno';

  @override
  String get paywallTrialTitle => 'Prvi mesec Pro je brezplačen';

  @override
  String get paywallTrialBody =>
      'Naložite celotno omaro naenkrat. Kose lahko dodajate sproti.';

  @override
  String get paywallFreeForeverTitle => 'Brezplačno za vedno';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Kartica ni potrebna. Vsak mesec prejmete $uploads umetno podprtih nalaganj, $outfits kombinacij in $images slik za slikanje na dan.';
  }

  @override
  String get paywallCtaTrial => 'Začni brezplačni mesec';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Preidi na $plan';
  }

  @override
  String get paywallRestore => 'Obnovi kakupe';

  @override
  String get paywallManage => 'Upravljaj naročnino';

  @override
  String get paywallTerms => 'Pogoji uporabe';

  @override
  String get paywallPrivacy => 'Politika zasebnosti';

  @override
  String get paywallPerMonth => 'na mesec';

  @override
  String get paywallPerYear => 'na leto';

  @override
  String get paywallBestValue => 'Najboljša vrednost';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Brezplačni preizkus samo za nove naročnike. Po preizkusu se naročnina Pro samodejno obnova za $price, razen če jo prekličete vsaj 24 ur pred koncem.';
  }

  @override
  String get introTitle => 'Vaša omara, končno urejena';

  @override
  String get introBody =>
      'Fotografirajte svoja oblačila enkrat. Pridobite ideje za obleke, predoglede pomerjanja in studijske fotografije iz tistega, kar že imate.';

  @override
  String get introStart => 'Začni';

  @override
  String get introHaveAccount => 'Že imam račun';

  @override
  String get introSkip => 'Preskoči';

  @override
  String get authSignIn => 'Prijava';

  @override
  String get authSignUp => 'Ustvari račun';

  @override
  String get authEmail => 'E-pošta';

  @override
  String get authPassword => 'Geslo';

  @override
  String get authForgotPassword => 'Ste pozabili geslo?';

  @override
  String get authContinueApple => 'Nadaljuj z Apple';

  @override
  String get authContinueGoogle => 'Nadaljuj z Google';

  @override
  String get authOrDivider => 'ali';

  @override
  String get wardrobeTitle => 'Omara';

  @override
  String get wardrobeEmptyTitle => 'Vaša omara je prazna';

  @override
  String get wardrobeEmptyBody =>
      'Dodajte svoj prvi kos ali naložite fotografijo celotnega obešalnika hkrati.';

  @override
  String get wardrobeAddFirst => 'Dodaj prvi kos';

  @override
  String get wardrobeSearchHint => 'Išči po omari';

  @override
  String get categoryTops => 'Zgornji deli';

  @override
  String get categoryBottoms => 'Spodnji deli';

  @override
  String get categoryShoes => 'Čevlji';

  @override
  String get categoryAccessories => 'Modni dodatki';

  @override
  String get categoryOuterwear => 'Vrhunska oblačila';

  @override
  String get categorySwimwear => 'Kopalna oblačila';

  @override
  String get categoryActivewear => 'Športna oblačila';

  @override
  String get categoryOther => 'Drugo';

  @override
  String get conditionClean => 'Čisto';

  @override
  String get conditionDirty => 'Umazano';

  @override
  String get conditionLaundry => 'V pralnem stroju';

  @override
  String get conditionRepair => 'Potrebno popravilo';

  @override
  String get conditionDonate => 'Za donacijo';

  @override
  String get seasonSpring => 'Pomlad';

  @override
  String get seasonSummer => 'Poletje';

  @override
  String get seasonFall => 'Jesen';

  @override
  String get seasonWinter => 'Zima';

  @override
  String get seasonAll => 'Vse sezone';

  @override
  String get styleCasual => 'Ležerno';

  @override
  String get styleFormal => 'Formalno';

  @override
  String get styleBusiness => 'Poslovno';

  @override
  String get styleSporty => 'Športno';

  @override
  String get styleBohemian => 'Boemsko';

  @override
  String get styleStreetwear => 'Ulična moda';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistično';

  @override
  String get styleRomantic => 'Romantično';

  @override
  String get styleEdgy => 'Drzno';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Umetniško';

  @override
  String get styleClassic => 'Klasično';

  @override
  String get styleElegant => 'Elegantno';

  @override
  String get styleOther => 'Drugo';

  @override
  String get occasionWork => 'Služba';

  @override
  String get occasionDateNight => 'Zmenek';

  @override
  String get occasionTravel => 'Potovanje';

  @override
  String get occasionWedding => 'Poroka';

  @override
  String get occasionGym => 'Fitnes';

  @override
  String get occasionWeekend => 'Konec tedna';

  @override
  String get occasionParty => 'Zabava';

  @override
  String get occasionInterview => 'Razgovor';

  @override
  String get colorBlack => 'Črna';

  @override
  String get colorWhite => 'Bela';

  @override
  String get colorGrey => 'Siva';

  @override
  String get colorNavy => 'Temno modra';

  @override
  String get colorBrown => 'Rjava';

  @override
  String get colorRed => 'Rdeča';

  @override
  String get colorBlue => 'Modra';

  @override
  String get colorGreen => 'Zelena';

  @override
  String get colorPink => 'Rožnata';

  @override
  String get colorPurple => 'Vijolična';

  @override
  String get colorYellow => 'Rumena';

  @override
  String get colorOrange => 'Oranžna';

  @override
  String get colorBeige => 'Bež';

  @override
  String get dateToday => 'Danes';

  @override
  String get dateYesterday => 'Včeraj';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pred $count dnevi',
      few: 'Pred $count dnevi',
      two: 'Pred $count dnevoma',
      one: 'Pred 1 dnevom',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pred $count tedni',
      few: 'Pred $count tedni',
      two: 'Pred $count tednoma',
      one: 'Pred 1 tednom',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pred $count meseci',
      few: 'Pred $count meseci',
      two: 'Pred $count mesecema',
      one: 'Pred 1 mesecem',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pred $count leti',
      few: 'Pred $count leti',
      two: 'Pred $count letoma',
      one: 'Pred 1 letom',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Uživate v FitCheck AI?';

  @override
  String get ratingPromptBody => 'Hitra ocena pomaga drugim najti svoj stil.';

  @override
  String get ratingPromptYes => 'Oceni aplikacijo';

  @override
  String get ratingPromptNo => 'Ne zdaj';

  @override
  String get closetNoMatchesTitle => 'Ni ujemajočih kosov';

  @override
  String get closetNoMatchesBody =>
      'Poskusite z manj filtri ali drugim iskanjem.';

  @override
  String get closetClearFilters => 'Počisti filtre';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kosov',
      few: '$count kosi',
      two: '$count kosa',
      one: '1 kos',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Nalaganje vaših kosov';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count izbranih',
      few: '$count izbrani',
      two: '$count izbrana',
      one: '1 izbran',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Izbriši izbrano';

  @override
  String get closetCancelSelection => 'Prekliči izbor';

  @override
  String get closetCloseSearch => 'Zapri iskanje';

  @override
  String get closetShowGrid => 'Prikaži kot mrežo';

  @override
  String get closetShowList => 'Prikaži kot seznam';

  @override
  String get closetShowRows => 'Prikaži v vrsticah';

  @override
  String get closetStatsTitle => 'Statistika omare';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Izbrišem $count kosov?',
      few: 'Izbrišem $count kose?',
      two: 'Izbrišem $count kosa?',
      one: 'Izbrišem 1 kos?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Obleke, ki jih uporabljajo, bodo izgubile te kose.';

  @override
  String get closetSortBy => 'Razvrsti po';

  @override
  String get closetFavourites => 'Priljubljene';

  @override
  String get closetFavourite => 'Priljubljeno';

  @override
  String get closetUnfavourite => 'Odstrani priljubljeno';

  @override
  String get closetWoreToday => 'Nošeno danes';

  @override
  String closetWornTimes(int count) {
    return 'Nošeno $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategorija';

  @override
  String get closetUseCaseLabel => 'Priložnost';

  @override
  String get closetAnyUseCase => 'Vse';

  @override
  String get closetOtherUseCase => 'Druga priložnost';

  @override
  String get closetOtherUseCaseHint => 'Na primer kava';

  @override
  String get closetUseUseCase => 'Uporabi to';

  @override
  String get closetClearAll => 'Počisti vse';

  @override
  String get sortNewest => 'Najnovejše';

  @override
  String get sortOldest => 'Najstarejše';

  @override
  String get sortName => 'Ime (A–Ž)';

  @override
  String get sortMostWorn => 'Največkrat nošeno';

  @override
  String get useCaseInformal => 'Sproščeno';

  @override
  String get useCaseDate => 'Zmenek';

  @override
  String get useCaseDinner => 'Večerja';

  @override
  String get useCaseLunch => 'Kosilo';

  @override
  String get actionSelect => 'Izberi';

  @override
  String get actionEdit => 'Uredi';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Razvrsti';

  @override
  String get actionAll => 'Vse';

  @override
  String get dashboardStartClosetTitle => 'Začni svojo omaro';

  @override
  String get dashboardStartClosetBody =>
      'Fotografiraj nekaj kosov. Mi jih označimo zate.';

  @override
  String get dashboardPieces => 'kosi';

  @override
  String get dashboardOutfits => 'oprave';

  @override
  String get dashboardDayStreak => 'dni zapored';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count ta mesec';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Najboljši $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count priljubljenih',
      one: '1 priljubljen',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shranjenih oprav',
      one: '1 shranjena oprava',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Največkrat nošeno: $name, $count-krat';
  }

  @override
  String get setupSkip => 'Preskoči nastavitev';

  @override
  String get setupWhoTitle => 'Koga stiliziramo?';

  @override
  String get setupWhoBody =>
      'Določi model za pomerjanje in fotografiranje. To lahko spremeniš v profilu.';

  @override
  String get setupStyleTitle => 'Kaj najraje nosiš?';

  @override
  String get setupStyleBody =>
      'Izberi karkoli. Ideje za oprave izhajajo iz tega.';

  @override
  String get setupClosetTitle => 'Dodaj svoje prve kose.';

  @override
  String get setupClosetBody =>
      'Fotografiraj nekaj oblačil ali cel kup. Vsak kos je izrezan in shranjen zate.';

  @override
  String get setupAddClothes => 'Dodaj oblačila';

  @override
  String get setupStylesLabel => 'Slogi';

  @override
  String get setupOccasionsLabel => 'Priložnosti';

  @override
  String get setupSkipStep => 'Preskoči';

  @override
  String get setupLater => 'Pozneje';

  @override
  String get setupSaveError => 'Shranjevanje ni uspelo';

  @override
  String get genderWomen => 'Ženske';

  @override
  String get genderMen => 'Moški';

  @override
  String get genderNonBinary => 'Neprimarno';

  @override
  String get genderPreferNotToSay => 'Ne želim navesti';

  @override
  String get outfitEmptyTitle => 'Še ni oprav';

  @override
  String get outfitEmptyBody => 'Poveži kose iz omare in shrani videz.';

  @override
  String get outfitNoMatchesTitle => 'Ni ujemajočih se oprav';

  @override
  String get outfitSearchHint => 'Išči po opravah';

  @override
  String get outfitLoading => 'Nalaganje oprav';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oprav',
      one: '1 oprava',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Slog in sezona';

  @override
  String get outfitCollections => 'Kolekcije';

  @override
  String get outfitDuplicate => 'Podvoji';

  @override
  String get outfitDeleteTitle => 'Izbrišem to opravo?';

  @override
  String get outfitDeleteBody => 'Njeni kosi ostanejo v omari.';

  @override
  String get outfitDrafts => 'Osnutki';

  @override
  String get outfitDraft => 'Osnutek';

  @override
  String get filterStyle => 'Slog';

  @override
  String get filterSeason => 'Sezona';

  @override
  String get itemDetailDeleteTitle => 'Izbrišem ta kos?';

  @override
  String get itemDetailDeleteBody =>
      'Oprave, ki ga uporabljajo, bodo izgubile ta kos.';

  @override
  String get itemAddFavourite => 'Dodaj med priljubljene';

  @override
  String itemSize(String size) {
    return 'Velikost $size';
  }

  @override
  String get itemColours => 'Barve';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Vzorec';

  @override
  String get itemUseCases => 'Priložnosti';

  @override
  String get itemKeptIn => 'Shranjeno v';

  @override
  String get itemPrice => 'Cena';

  @override
  String get itemBought => 'Kupljeno';

  @override
  String get itemTags => 'Oznake';

  @override
  String get itemAdded => 'Dodano';

  @override
  String get itemTimesWornLabel => 'nošenje';

  @override
  String get itemLastWornLabel => 'nazadnje nošeno';

  @override
  String get itemNeverWorn => 'Nikoli';

  @override
  String get authEntryBody =>
      'Vsak kos v vaši omari, ki ga uredi FitCheck AI. Načrtujte obleke, preizkusite jih in jih fotografirajte.';

  @override
  String get authCreateCloset => 'Ustvarite omaro';

  @override
  String get authWelcomeBack => 'Dobrodošli nazaj';

  @override
  String get authSignInBody => 'Prijavite se za dostop do omare.';

  @override
  String get authCreateAccount => 'Ustvarite račun';

  @override
  String get authCreateClosetBody =>
      'Traja le minuto. Prvi kosi so brezplačni.';

  @override
  String get authName => 'Ime';

  @override
  String get authConfirmPassword => 'Potrdite geslo';

  @override
  String get authReferralCode => 'Koda priporočila (neobvezno)';

  @override
  String get authResetTitle => 'Ponastavitev gesla';

  @override
  String get authResetBody =>
      'Na e-pošto vam bomo poslali povezavo za novo geslo.';

  @override
  String get authSendResetLink => 'Pošlji povezavo';

  @override
  String get authBackToSignIn => 'Nazaj na prijavo';

  @override
  String get authEnterEmail => 'Vnesite e-pošto';

  @override
  String get authEnterValidEmail => 'Vnesite veljavno e-pošto';

  @override
  String get authEnterPassword => 'Vnesite geslo';

  @override
  String get authPasswordTooShort => 'Vsaj 6 znakov';

  @override
  String get authShowPassword => 'Pokaži geslo';

  @override
  String get authHidePassword => 'Skrij geslo';

  @override
  String get authNewHere => 'Novinec?';

  @override
  String authConfirmEmail(String email) {
    return 'Pred prijavo potrdite $email. Preverite nabiralnik.';
  }

  @override
  String get authResendEmail => 'Pošlji ponovno';

  @override
  String get authResendingEmail => 'Pošiljanje…';

  @override
  String get authPasswordsDoNotMatch => 'Gesli se ne ujemata';

  @override
  String get authEnterName => 'Vnesite ime';

  @override
  String get authChoosePassword => 'Izberite geslo';

  @override
  String get authHaveAccount => 'Že imate račun?';

  @override
  String get authCodeAccepted => 'Koda sprejeta';

  @override
  String get authCodeNotFound => 'Koda ni najdena';

  @override
  String authReferralFrom(String name) {
    return 'Od $name. Oba prejmeta mesec brezplačno.';
  }

  @override
  String get authReferralInvalid => 'Te kode ni mogoče najti.';

  @override
  String authResetSent(String email) {
    return 'Poslano na $email. Odprite povezavo na tej napravi.';
  }

  @override
  String get introSlide1Title => 'Posnemite omaro.';

  @override
  String get introSlide1Body =>
      'Fotografirajte kup oblačil. Vsak kos bo samodejno izrezan in shranjen.';

  @override
  String get introSlide2Title => 'Hitreje izberite obleko.';

  @override
  String get introSlide2Body =>
      'Kombinacije iz vaših oblačil, prilagojene načrtom in vremenu.';

  @override
  String get introSlide3Title => 'Preizkusite, preden oblečete.';

  @override
  String get introSlide3Body =>
      'Obleke preizkusite na svoji fotografiji ali jih posnemite kot kampanjo.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistemska';

  @override
  String get settingsThemeLight => 'Svetla';

  @override
  String get settingsThemeDark => 'Temna';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'E-poštne novice';

  @override
  String get settingsEmailUpdatesBody => 'Novice in nasveti po e-pošti';

  @override
  String get settingsOutfitReminders => 'Opomniki za obleko';

  @override
  String get settingsOutfitRemindersBody =>
      'Opomnik za beleženje nošenih oblačil';

  @override
  String get settingsWeeklySummary => 'Tedenski povzetek';

  @override
  String get settingsWeeklySummaryBody => 'Vaš teden v oblekah';

  @override
  String get settingsStyleSection => 'Slog';

  @override
  String get settingsPreferredStyles => 'Priljubljeni slogi';

  @override
  String get settingsPreferredColours => 'Priljubljene barve';

  @override
  String get settingsNoneChosen => 'Ni izbrano';

  @override
  String get settingsPlanAiSection => 'Načrt in FitCheck AI';

  @override
  String get settingsPlanBillingBody => 'Načrt, poraba in nadgradnje';

  @override
  String get settingsPlanUsageBody => 'Načrt in poraba';

  @override
  String get settingsInviteFriends => 'Povabi prijatelje';

  @override
  String get settingsInviteFriendsBody =>
      'Brezplačen mesec za vsakega prijatelja, ki se pridruži';

  @override
  String get settingsAiProvider => 'Ponudnik AI';

  @override
  String get settingsAiProviderBody =>
      'Uporabite lastni model za označevanje in slike';

  @override
  String get settingsAppVersion => 'Različica aplikacije';

  @override
  String get settingsPrivacyTerms => 'Zasebnost in pogoji';

  @override
  String get settingsReportProblem => 'Prijavi težavo';

  @override
  String get settingsChangePassword => 'Spremeni geslo';

  @override
  String get settingsExportData => 'Izvozi podatke';

  @override
  String get settingsExportBody =>
      'Pripravili bomo datoteko z vsem shranjenim in jo odprli za prenos.';

  @override
  String get settingsExportAction => 'Izvozi';

  @override
  String get settingsCurrentPassword => 'Trenutno geslo';

  @override
  String get settingsNewPassword => 'Novo geslo';

  @override
  String get settingsConfirmNewPassword => 'Potrdi novo geslo';

  @override
  String get settingsEnterCurrentPassword => 'Vnesite trenutno geslo';

  @override
  String get settingsEnterNewPassword => 'Vnesite novo geslo';

  @override
  String get settingsPasswordMin8 => 'Uporabite vsaj 8 znakov';

  @override
  String get settingsPasswordNeedsUpper => 'Dodajte veliko črko';

  @override
  String get settingsPasswordNeedsLower => 'Dodajte malo črko';

  @override
  String get settingsPasswordNeedsDigit => 'Dodajte številko';

  @override
  String get settingsPasswordsNoMatch => 'Gesli se ne ujemata';

  @override
  String get settingsChangeAction => 'Spremeni';

  @override
  String get itemAddSnapTitle => 'Slikaj oblačilo';

  @override
  String get itemAddSnapBody =>
      'Na fotografiji najdemo vsak kos in ustvarimo čisto studijsko sliko.';

  @override
  String get itemAddCamera => 'Fotografiraj';

  @override
  String get itemAddGallery => 'Izberi iz galerije';

  @override
  String get itemAddOtherWays => 'Drugi načini dodajanja';

  @override
  String get itemAddSeveral => 'Dodaj več fotografij';

  @override
  String get itemAddSeveralBody => 'Do 50 hkrati';

  @override
  String get itemAddImportProfile => 'Uvozi iz profila';

  @override
  String get itemAddImportProfileBody => 'Instagram ali Facebook';

  @override
  String get itemAddEnterDetails => 'Vnesi podatke ročno';

  @override
  String get itemAddEnterDetailsBody => 'Fotografija ni potrebna';

  @override
  String get itemManualIntro =>
      'Potrebno je le ime. Preostalo dodajte zdaj ali kasneje.';

  @override
  String get itemManualNameHint => 'Na primer modra bombažna majica';

  @override
  String get itemManualEnterName => 'Vnesite ime';

  @override
  String get itemManualNotes => 'Opombe';

  @override
  String get itemManualBrand => 'Znamka';

  @override
  String get itemManualSize => 'Velikost';

  @override
  String get itemManualEnterNumber => 'Vnesite številko';

  @override
  String get itemManualSavePiece => 'Shrani kos';

  @override
  String get itemManualSaving => 'Shranjevanje';

  @override
  String get itemManualSavedTitle => 'Shranjeno';

  @override
  String itemManualSavedBody(String name) {
    return '$name je v vaši omari.';
  }

  @override
  String get itemManualNotSaved => 'Ni shranjeno';

  @override
  String get itemManualAddUseCase => 'Dodaj namen uporabe';

  @override
  String get itemManualAddUseCaseAction => 'Dodaj namen';

  @override
  String get itemPhotos => 'Fotografije';

  @override
  String get itemAddPhotos => 'Dodaj fotografije';

  @override
  String get itemNoPhotoYet =>
      'Še ni fotografije. Shranite lahko tudi brez nje.';

  @override
  String get itemRemovePhoto => 'Odstrani fotografijo';

  @override
  String get itemRemovePiece => 'Odstrani kos';

  @override
  String get filterConditionLabel => 'Stanje';

  @override
  String get photoshootStepPhotos => 'Fotografije';

  @override
  String get photoshootStepSetup => 'Nastavitev';

  @override
  String get photoshootStepCreating => 'Ustvarjanje';

  @override
  String get photoshootStepResults => 'Rezultati';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Korak $current od $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Ena fotografija ni uspela. Poskusite znova spodaj.';

  @override
  String photoshootManyFailed(int count) {
    return 'Neuspešno fotografiranje $count slik. Poskusite posamezno spodaj.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Koliko';

  @override
  String get photoshootYourPrompt => 'Vaš opis';

  @override
  String get photoshootPromptHint => 'Zlata ura na strehi, lanena srajca';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ustvari $count fotografije',
      one: 'Ustvari 1 fotografijo',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotografije',
      one: 'fotografija',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Današnje omejitve ni bilo mogoče preveriti.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Paket $plan: še $remaining od $limit danes';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Brezplačno';

  @override
  String get photoshootGallery => 'Galerija';

  @override
  String get photoshootUseCamera => 'Uporabi kamero';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Odstrani fotografijo $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Ni vrnjenih fotografij';

  @override
  String get photoshootNoPhotosBody =>
      'Slikanje se je končalo brez slik. Poskusite znova.';

  @override
  String get photoshootNewStyle => 'Nov slog';

  @override
  String get photoshootNewPhotos => 'Nove fotografije';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Odpri fotografijo $number';
  }

  @override
  String get photoshootReportPhoto => 'Prijavi fotografijo';

  @override
  String get photoshootSaveToGallery => 'Shrani v galerijo';

  @override
  String get actionUpgrade => 'Nadgradi';

  @override
  String get referralLimitTitle => 'Porabili ste današnje fotografije';

  @override
  String get referralLimitBody =>
      'Brezplačne fotografije bodo na voljo jutri. Povabite prijatelja in oba bosta prejela mesec naročnine Pro brezplačno.';

  @override
  String get referralLimitRefer => 'Povabi prijatelja';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Zmenki';

  @override
  String get photoshootUsePortfolio => 'Portfelj';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetika';

  @override
  String get photoshootUseCustom => 'Vaš lastni opis';

  @override
  String get photoshootDescLinkedin => 'Ostre portretne slike za delo';

  @override
  String get photoshootDescDating => 'Sproščeno, toplo in naravno';

  @override
  String get photoshootDescPortfolio => 'Uredniški videzi visoke moške mode';

  @override
  String get photoshootDescInstagram => 'Življenjski utrinki za vaš profil';

  @override
  String get photoshootDescAesthetic => 'Zamišljeni, umetniški okvirji';

  @override
  String get photoshootDescCustom => 'Opišite videz, ki si ga želite';

  @override
  String get aspectSquare => 'Kvadrat';

  @override
  String get aspectPortrait => 'Pokončno';

  @override
  String get aspectLandscape => 'Ležeče';

  @override
  String get aspectTall => 'Visoko';

  @override
  String get aspectWide => 'Široko';

  @override
  String get tryOnAppBar => 'Navidezno pomerjanje';

  @override
  String get tryOnYourPhoto => 'Vaša fotografija';

  @override
  String get tryOnGarment => 'Oblačilo';

  @override
  String get tryOnUploadingPhoto => 'Nalaganje vaše fotografije';

  @override
  String get tryOnAddPhotoPrompt => 'Dodajte fotografijo celotnega telesa';

  @override
  String get tryOnBodyPhotoHint => 'Najbolje deluje fotografija celega telesa';

  @override
  String get tryOnAddPhoto => 'Dodaj fotografijo';

  @override
  String get tryOnChangePhoto => 'Spremeni fotografijo';

  @override
  String get tryOnPhotoLoadFailed =>
      'Vaše fotografije ni bilo mogoče naložiti.';

  @override
  String get tryOnChooseGarment => 'Izberite fotografijo oblačila';

  @override
  String get tryOnChooseOneGarment => 'Izberite eno fotografijo oblačila';

  @override
  String get tryOnGarmentHint =>
      'Najbolje deluje slika na ravni podlagi ali obešalniku';

  @override
  String get tryOnChange => 'Spremeni';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Odstrani';

  @override
  String get tryOnLookTitle => 'Videz';

  @override
  String get tryOnStyle => 'Slog';

  @override
  String get tryOnBackground => 'Ozadje';

  @override
  String get tryOnPose => 'Poza';

  @override
  String get tryOnDressingUp =>
      'Oblačimo vas. To trajalo približno pol minute.';

  @override
  String get tryOnEmptyResult => 'Tukaj se prikaže virtualno pomerjanje';

  @override
  String get tryOnReportImage => 'Prijavi sliko';

  @override
  String get tryOnCreating => 'Ustvarjanje';

  @override
  String get tryOnTryAgain => 'Poskusi znova';

  @override
  String get tryOnCreate => 'Ustvari pomerjanje';

  @override
  String get tryOnBackgroundStudioWhite => 'Bel studio';

  @override
  String get tryOnBackgroundStudioGrey => 'Siv studio';

  @override
  String get tryOnBackgroundUrban => 'Mestna ulica';

  @override
  String get tryOnBackgroundNature => 'Narava';

  @override
  String get tryOnBackgroundMinimal => 'Minimalistično';

  @override
  String get tryOnPoseFront => 'Stoje od spredaj';

  @override
  String get tryOnPoseSide => 'Stoje od strani';

  @override
  String get tryOnPoseWalking => 'Hoja';

  @override
  String get dashboardGreetingMorning => 'Dobro jutro';

  @override
  String get dashboardGreetingAfternoon => 'Dober dan';

  @override
  String get dashboardGreetingEvening => 'Dober večer';

  @override
  String get dashboardWelcome => 'Dobrodošli';

  @override
  String get dashboardOpenProfile => 'Odpri profil';

  @override
  String get dashboardRailToday => 'Danes';

  @override
  String get dashboardRailRecently => 'Nedavno';

  @override
  String get dashboardActivityEmpty =>
      'Tukaj se prikažejo novi kosi in obleke.';

  @override
  String get quickAddPiece => 'Dodaj kos';

  @override
  String get quickAddPieceBody => 'Fotografiraj in označi';

  @override
  String get quickBuildOutfit => 'Sestavi obleko';

  @override
  String get quickBuildOutfitBody => 'Združi svoje kose';

  @override
  String get quickForYou => 'Zanje zate';

  @override
  String get quickForYouBody => 'Izbor za danes';

  @override
  String get quickPlanWeek => 'Načrtuj teden';

  @override
  String get quickPlanWeekBody => 'Obleke po datumu';

  @override
  String get referralBannerUrgent =>
      'Zmanjkuje ti prostora? Povabi prijatelja.';

  @override
  String get referralBannerTitle => 'Podari mesec, dobi mesec.';

  @override
  String get referralBannerBody =>
      'Ti in tvoj prijatelj prejmeta mesec naročnine Pro.';

  @override
  String get referralBannerDismiss => 'Skrij za teden dni';

  @override
  String get referralBannerShare => 'Deli povabilo';

  @override
  String get referralBannerCopy => 'Kopiraj povezavo';

  @override
  String get itemEditPieceTitle => 'Uredi kos';

  @override
  String get itemEditDescriptionLabel => 'Opis';

  @override
  String get itemEditNotSaved => 'Ni shranjeno';

  @override
  String get itemEditSavedTitle => 'Shranjeno';

  @override
  String get itemEditSavedBody => 'Spremembe so shranjene.';

  @override
  String get itemEditSavedStalePhotos =>
      'Shranjeno – fotografije so morda zastarele';

  @override
  String get itemEditRemovePieceHint => 'Izbriši ta kos s strani predmeta.';

  @override
  String get itemEditNoPhotos =>
      'Ni še fotografij. Dodaj jo iz galerije ali s kamero.';

  @override
  String get itemEditKeepPhoto => 'Obdrži fotografijo';

  @override
  String get itemEditRemoved => 'Odstranjeno';

  @override
  String get itemEditAddUseCaseAction => 'Dodaj';

  @override
  String get statsNoStatsTitle => 'Ni še statistike';

  @override
  String get statsNoStatsBody =>
      'Dodaj nekaj kosov in tukaj se prikaže sestava tvoje omare.';

  @override
  String get statsByCategory => 'Po kategorijah';

  @override
  String get statsTotalValue => 'skupna vrednost';

  @override
  String get statsMostWorn => 'Največkrat nošeno';

  @override
  String get statsLeastWorn => 'Čaka na vrsto';

  @override
  String get statsUnnamedPiece => 'Neimenovan kos';

  @override
  String get jobsTitle => 'Pregledi';

  @override
  String get jobsEmptyTitle => 'Ni še pregledov';

  @override
  String get jobsEmptyBody =>
      'Fotografiraj kos in ga pošlji v ozadje – delo se nadaljuje tukaj.';

  @override
  String get jobsNotCancelled => 'Ni preklicano';

  @override
  String get jobsResume => 'Nadaljuj';

  @override
  String get jobsReview => 'Preglej';

  @override
  String get jobsStop => 'Ustavi';

  @override
  String get jobsDismiss => 'Opusti';

  @override
  String get reportTitle => 'Prijavi vsebino';

  @override
  String reportIntro(String contentType) {
    return 'Povej nam, kaj je narobe s to vsebino: $contentType. Naša ekipa pregleda vsako prijavo.';
  }

  @override
  String get reportReasonInappropriate => 'Neprimerno ali žaljivo';

  @override
  String get reportReasonNudity => 'Golota ali spolna vsebina';

  @override
  String get reportReasonHarassment => 'Nadlegovanje ali zloraba';

  @override
  String get reportReasonImpersonation => 'Lažno predstavljanje';

  @override
  String get reportReasonOther => 'Drugo';

  @override
  String get reportDetailsLabel => 'Dodatne podrobnosti (neobvezno)';

  @override
  String get reportSubmit => 'Pošlji prijavo';

  @override
  String get reportSubmittedTitle => 'Prijava poslana';

  @override
  String get reportSubmittedBody =>
      'Hvala. Naša ekipa bo pregledala to vsebino.';

  @override
  String get reportFailedTitle => 'Prijave ni bilo mogoče poslati';

  @override
  String get reportFailedBody => 'Poskusi znova.';

  @override
  String get reportContentTryOnImage => 'slika pomerjanja z AI';

  @override
  String get reportContentSharedOutfit => 'deljena oprava';

  @override
  String get reportContentPhotoshootImage => 'slika fotografiranja z AI';

  @override
  String get sharedOutfitTitle => 'Deljena opravljenost';

  @override
  String get sharedOutfitHideTooltip => 'Skrij to opravljenost';

  @override
  String get sharedOutfitReportTooltip => 'Prijavi to opravljenost';

  @override
  String get sharedOutfitHideTitle => 'Skrijem to opravljenost?';

  @override
  String get sharedOutfitHideBody =>
      'Na tej napravi bo skrita. Lahko jo tudi prijaviš, da jo naša ekipa pregleda in odstrani.';

  @override
  String get sharedOutfitHideAction => 'Skrij';

  @override
  String get sharedOutfitHiddenInfo =>
      'Ta opravljenost se na tej napravi ne bo več prikazala.';

  @override
  String get sharedOutfitHiddenToast => 'Opravljenost skrita';

  @override
  String get sharedOutfitMissingTitle => 'Te opravljenosti ni več';

  @override
  String get sharedOutfitMissingBody =>
      'Morda je bila odstranjena ali pa je povezava napačna.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Skril si to opravljenost';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Če je neprimerna, jo prijavi v razdelku Zasebnost in pogoji ali piši na $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Ti je všeč ta videz?';

  @override
  String get sharedOutfitCtaBody =>
      'Ustvari podobne opravljenosti iz svoje omare.';

  @override
  String get sharedOutfitCtaButton => 'Prenesi FitCheck AI';

  @override
  String get errorTitle => 'Napaka';

  @override
  String get errorUnknown => 'Prišlo je do nepričakovane napake';

  @override
  String get errorNoConnection => 'Ni internetne povezave. Preverite omrežje.';

  @override
  String get errorTimeout => 'Čas zahteve je potekel. Poskusite znova.';

  @override
  String get errorServerError => 'Nekaj je šlo narobe. Poskusite znova.';

  @override
  String get errorBadGateway =>
      'Strežnik je začasno nedosegljiv. Poskusite znova.';

  @override
  String get errorServiceUnavailable =>
      'Storitev je začasno nedosegljiva. Poskusite znova kasneje.';

  @override
  String get errorInternalError => 'Nekaj je šlo narobe. Poskusite znova.';

  @override
  String get errorUnauthorized => 'Za nadaljevanje se prijavite.';

  @override
  String get errorForbidden => 'Do tega nimate dostopa.';

  @override
  String get errorSessionExpired => 'Seja je potekla. Prijavite se znova.';

  @override
  String get errorInvalidCredentials =>
      'E-poštni naslov ali geslo ni pravilno.';

  @override
  String get errorTokenRefreshFailed =>
      'Seje ni bilo mogoče osvežiti. Prijavite se znova.';

  @override
  String get errorRequestCancelled => 'Zahteva preklicana.';

  @override
  String get errorInvalidFormat => 'Ta format datoteke ni podprt.';

  @override
  String get errorFileTooLarge => 'Datoteka je prevelika.';

  @override
  String get errorUploadFailed => 'Nalaganje ni uspelo. Poskusite znova.';

  @override
  String get errorCacheCorrupted =>
      'Shranjeni podatki so bili poškodovani in ponastavljeni.';

  @override
  String get errorCacheNotFound => 'Ni še nič shranjenega.';

  @override
  String get errorUserNotFound => 'Računa ni bilo mogoče najti.';

  @override
  String get errorItemNotFound => 'Ta kos več ne obstaja.';

  @override
  String get errorOutfitNotFound => 'Ta oprava več ne obstaja.';

  @override
  String get rewardsTitle => 'Nagrade';

  @override
  String get rewardsNoAchievementsTitle => 'Ni še dosežkov';

  @override
  String get rewardsNoAchievementsBody =>
      'Dodajte kose in sestavite oprave za prvi dosežek.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Na lestvici ni nikogar';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Sestavljajte oprave, zbirajte točke in se uvrstite sem.';

  @override
  String get legalViewPrivacyPolicy => 'Politika zasebnosti';

  @override
  String get aiConsentAgree => 'Strinjam se in nadaljujem';

  @override
  String get aiConsentNotNow => 'Ne zdaj';

  @override
  String get imageViewerCloseTooltip => 'Zapri pregledovalnik slik';

  @override
  String get updateReadyTitle => 'Posodobitev je pripravljena';

  @override
  String get updateReadyBody =>
      'Ponovno zaženite FitCheck AI, da uveljavite najnovejše izboljšave.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI potrebuje dostop do kamere za fotografiranje vaših oblačil in kosov v omari.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI potrebuje dostop do galerije za izbiro slik vaših oblačil in garderobe.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI mora shraniti vaše AI-ustvarjene fotografije oblek v vašo galerijo.';

  @override
  String get wardrobeSomePhotosSkipped =>
      'Nkatere fotografije so bile preskočene';

  @override
  String get wardrobePhotosNotAdded => 'Fotografije niso dodane';

  @override
  String get wardrobePhotoNotAdded => 'Fotografija ni dodana';

  @override
  String get wardrobeNotStartedTitle => 'Ni začeto';

  @override
  String get wardrobeNoRoomTitle => 'Ni prostora';

  @override
  String get wardrobeAddPhotosSemantic => 'Dodaj fotografije';

  @override
  String get batchAddTileLabel => 'Dodaj';

  @override
  String get batchProfileLinkLabel => 'Povezava do profila';

  @override
  String get wardrobeImportFromProfileTitle => 'Uvozi iz profila';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Dodaj več fotografij';

  @override
  String get wardrobeClearAction => 'Počisti';

  @override
  String get wardrobeRefreshTooltip => 'Osveži';

  @override
  String get batchNoPhotosYetTitle => 'Še ni fotografij';

  @override
  String get batchChoosePhotosAction => 'Izberi fotografije';

  @override
  String get batchWeFindEachPieceBody =>
      'Najdemo vsak kos in iz njega naredimo studijsko fotografijo.';

  @override
  String get batchPreparingPhotosSemantic => 'Priprava fotografij';

  @override
  String get batchPhotosProcessedSemantic => 'Obdelane fotografije';

  @override
  String get batchPasteProfileLinkTitle => 'Prilepi povezavo do profila';

  @override
  String get batchPasteProfileLinkBody =>
      'Javni profil na Instagramu ali Facebooku. Pregledamo njegove fotografije, vi pa izberete, kaj gre v vašo omaro.';

  @override
  String get batchClearLinkTooltip => 'Počisti povezavo';

  @override
  String get batchStartingButton => 'Zagon';

  @override
  String get batchStartImportAction => 'Začni uvoz';

  @override
  String get batchReviewEveryPhotoTitle => 'Pregledate vsako fotografijo';

  @override
  String get batchReviewEveryPhotoBody => 'Nič ni dodano, dokler ne potrdite.';

  @override
  String get batchPrivateProfilesTitle => 'Zasebni profili';

  @override
  String get batchPrivateProfilesBody =>
      'Povežite svoj račun. Instagram zahteva tudi uporabniško ime in geslo.';

  @override
  String get batchUseAnotherLinkAction => 'Uporabi drugo povezavo';

  @override
  String get batchSignInNeededTitle => 'Potrebna je prijava';

  @override
  String get batchEnterYourCodeTitle => 'Vnesite kodo';

  @override
  String get batchUseUsernamePasswordAction =>
      'Uporabi uporabniško ime in geslo';

  @override
  String get batchAlreadyConnectedAction => 'V brskalniku sem se že povezal';

  @override
  String get batchEnterCodeAction => 'Vnesi kodo';

  @override
  String get batchTryAnotherWayAction => 'Poskusi na drug način';

  @override
  String get batchLiveStatus => 'V živo';

  @override
  String get batchReconnectingStatus => 'Ponovno povezovanje';

  @override
  String get batchSignInToInstagramTitle => 'Prijava v Instagram';

  @override
  String get batchUsernameLabel => 'Uporabniško ime';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Koda, če uporabljate dvstopenjsko prijavo';

  @override
  String get batchAuthenticatorCodeBody =>
      'Uporabite 6-mestno kodo iz aplikacije za avtentikacijo. Kode se hitro menjajo.';

  @override
  String get batchVerifyAction => 'Potrdi';

  @override
  String get batchFindingPhotosTitle => 'Iskanje fotografij';

  @override
  String get batchImportPausedTitle => 'Uvoz zaustavljen';

  @override
  String get batchProcessingPhotosTitle => 'Obdelava fotografij';

  @override
  String get batchWaitingNextPhoto => 'Čakanje na naslednjo fotografijo';

  @override
  String get batchCancelImportAction => 'Prekliči uvoz';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Na tej fotografiji ni najdenih kosov.';

  @override
  String get batchEditPieceColoursLabel => 'Barve, ločene z vejicami';

  @override
  String get batchAddToClosetAction => 'Dodaj v omaro';

  @override
  String get batchSkipPhotoAction => 'Preskoči to fotografijo';

  @override
  String get batchImportCompleteTitle => 'Uvoz je končan';

  @override
  String get batchImportFailedTitle => 'Uvoz ni uspel';

  @override
  String get batchImportCancelledTitle => 'Uvoz preklican';

  @override
  String get batchImportErrorBody => 'Pri uvozu je prišlo do napake.';

  @override
  String get batchNothingMoreImportedBody =>
      'Iz tega profila ni več uvoženih predmetov.';

  @override
  String get batchViewClosetAction => 'Oglej si omaro';

  @override
  String get batchStartOverAction => 'Začni znova';

  @override
  String get wardrobeAddPieceTitle => 'Dodaj kos';

  @override
  String get wardrobeAddDetailsTitle => 'Dodaj podrobnosti';

  @override
  String get wardrobeScanningTitle => 'Skeniranje';

  @override
  String get batchReviewPiecesTitle => 'Preglej kose';

  @override
  String get wardrobeGalleryAction => 'Galerija';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Novo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Odstrani fotografijo';

  @override
  String get batchRunInBackgroundTooltip => 'Izvajaj v ozadju';

  @override
  String get batchStepOneOfTwo => '1. korak od 2';

  @override
  String get batchStepTwoOfTwo => '2. korak od 2';

  @override
  String get batchUploadingPhotosTitle => 'Nalaganje fotografij';

  @override
  String get batchFindingPiecesTitle => 'Iiskanje kosov';

  @override
  String get batchMakingStudioPhotosTitle =>
      'Ustvarjanje studijskih fotografij';

  @override
  String get batchStoppedLabel => 'Ustavljeno';

  @override
  String get batchFindingPiecesStoppedTitle => 'Iskanje kosov ustavljeno';

  @override
  String get batchCancelledLabel => 'Preklicano';

  @override
  String get batchAllDoneTitle => 'Vse končano';

  @override
  String get batchOpeningPiecesBody => 'Odpiranje vaših kosov';

  @override
  String get batchNothingSavedBody => 'Nič ni bilo shranjeno.';

  @override
  String get batchFindingPiecesFailedBody => 'Iskanje kosov ni uspelo.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Iskanje kosov se je prezgodaj ustavilo.';

  @override
  String get batchStopFindingPiecesTitle => 'Ustavi iskanje kosov?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skeniranje se ustavi in nič se ne shrani. Že najdeni kosi ostanejo v vaši dejavnosti, dokler jih ne zaprete.';

  @override
  String get batchKeepGoingAction => 'Nadaljuj';

  @override
  String get batchTryAgainAction => 'Poskusi znova';

  @override
  String get batchBackToPhotosAction => 'Nazaj na fotografije';

  @override
  String get batchSkipAllAction => 'Preskoči vse';

  @override
  String get batchIncludeAllAction => 'Vključi vse';

  @override
  String get batchNoPiecesFoundTitle => 'Ni najdenih kosov';

  @override
  String get batchNoPiecesFoundBody => 'Na teh fotografijah ni bilo oblačil.';

  @override
  String get batchChooseOtherPhotosAction => 'Izberi druge fotografije';

  @override
  String get batchUseCaseHelper => 'Dodano vsakemu shranjenemu kosu.';

  @override
  String get batchDiscardPiecesTitle => 'Zavržem te kose?';

  @override
  String get batchDiscardPiecesBody => 'Nič iz te serije ni shranjeno.';

  @override
  String get batchKeepAction => 'Obdrži';

  @override
  String get batchDiscardAction => 'Zavrzi';

  @override
  String get batchRemovePieceTitle => 'Odstranim ta kos?';

  @override
  String get batchRemovePieceBody => 'Ni shranjen v vaši omari.';

  @override
  String get batchRemoveAction => 'Odstrani';

  @override
  String get batchChoosePiecesToSave => 'Izberite kose za shranjevanje';

  @override
  String get batchDiscardAllAction => 'Zavrzi vse';

  @override
  String get batchNothingSavedRetryBody =>
      'Nič ni bilo shranjeno. Poskusite znova.';

  @override
  String get batchNotSavedTitle => 'Ni shranjeno';

  @override
  String get batchSavingLabel => 'Shranjevanje';

  @override
  String get batchSendToBackgroundAction => 'Pošlji v ozadje';

  @override
  String get batchStillWorkingMessage =>
      'Še delamo. Obvestili vas bomo, ko bodo kosi pripravljeni.';

  @override
  String get batchRunningInBackgroundTitle => 'Teče v ozadju';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studio fotografije so se prezgodaj ustavile. Te kose lahko še vedno shranite.';

  @override
  String get batchTapPieceToSkip => 'Tapnite kos, da ga preskočite.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studio fotografije so na poti. Lahko odidete – obvestili vas bomo.';

  @override
  String get batchLeaveAction => 'Odhodi';

  @override
  String get batchPeopleInPhotosTitle => 'Osebe na fotografijah';

  @override
  String get batchIncludeAction => 'Vključi';

  @override
  String get batchSkipAction => 'Preskoči';

  @override
  String get batchYourPhotoIsUsedLabel => 'Vaša fotografija je uporabljena';

  @override
  String get batchMakingStudioPhotoLabel => 'Ustvarjanje studio fotografije';

  @override
  String get batchNoStudioPhotoBody =>
      'Brez studijske fotografije. Uporabljena je vaša.';

  @override
  String get batchEnterDetailsYourselfAction => 'Vnesi podatke ročno';

  @override
  String get batchChooseAnotherPhotoAction => 'Izberi drugo fotografijo';

  @override
  String get batchConnectionLostTitle => 'Povezava prekinjena';

  @override
  String get batchConnectionLostBody =>
      'Preverite povezavo in poskusite znova.';

  @override
  String get batchDailyLimitTitle => 'Dosežena dnevna omejitev';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Nadgradite na Pro za več skeniranj ali vnesite podatke ročno.';

  @override
  String get batchDailyLimitBodyFree =>
      'Skeniranja se ponastavijo jutri. Podatke lahko vnesete ročno takoj.';

  @override
  String get batchSeePlansAction => 'Poglej pakete';

  @override
  String get batchAiBusyTitle => 'Naša umetna inteligenca je zasedena';

  @override
  String get batchAiBusyBody =>
      'Težava je na naši strani. Poskusite znova čez nekaj minut.';

  @override
  String get batchNoPiecesBody =>
      'Poskusite z bolj jasno fotografijo ali vnesite podatke ročno.';

  @override
  String get batchScanningUnavailableTitle => 'Skeniranje ni na voljo';

  @override
  String get batchScanningUnavailableBody => 'Za zdaj vnesite podatke ročno.';

  @override
  String get batchScanDidNotFinishTitle => 'Skeniranje se ni zaključilo';

  @override
  String get batchTryAgainBody => 'Poskusite znova.';

  @override
  String get billingTitle => 'Naročnina';

  @override
  String get billingUpgradeHeading => 'Nadgradite paket';

  @override
  String get billingUpgradeOnPlusBody => 'Iste funkcije, višje omejitve.';

  @override
  String get billingUpgradeBody =>
      'Paketa Plus in Pro imata enake funkcije. Izberite omejitve, ki jih potrebujete.';

  @override
  String get billingWebUnavailableBody =>
      'Spletne nadgradnje še niso na voljo. Promo ali referenčna koda še vedno odklene Plus ali Pro. Povabite prijatelje spodaj in pridobite brezplačne mesece.';

  @override
  String get billingPlansStale =>
      'Najnovejših paketov ni bilo mogoče naložiti. Cene so morda zastarale.';

  @override
  String get billingMonthly => 'Mesečno';

  @override
  String get billingYearly => 'Letno';

  @override
  String get billingCurrentPlan => 'Trenutni paket';

  @override
  String get billingActive => 'Aktivno';

  @override
  String get billingThisMonth => 'Ta mesec';

  @override
  String get billingItemExtractions => 'Ekstrakcije kosov';

  @override
  String get billingOutfitVisualizations => 'Vizualizacije oprave';

  @override
  String get billingNearLimitUpgrade =>
      'Blizu ste letošnji omejitvi. Nadgradite za več.';

  @override
  String get billingNearLimitResets =>
      'Blizu ste letošnji omejitvi. Ponastavi se v začetku naslednjega meseca.';

  @override
  String get billingStoreUnavailable =>
      'Nadgradnje v trgovini še niso na voljo. Poskusite znova kasneje.';

  @override
  String get billingManageHeading => 'Upravljajte svoj paket';

  @override
  String get billingCancelPlan => 'Prekliči naročnino';

  @override
  String get billingCancelKeepsAccess =>
      'Dostop obdržite do konca tega obračunskega obdobja.';

  @override
  String get billingCancelConfirmTitle => 'Ali želite preklicati naročnino?';

  @override
  String get billingKeepPlan => 'Ohrani paket';

  @override
  String get billingCancelPlanAction => 'Prekliči paket';

  @override
  String get billingBilledMonthly => 'Mesečno obračunavanje';

  @override
  String get billingBilledYearly => 'Letno obračunavanje';

  @override
  String get billingVirtualTryOn => 'Navidezno pomerjanje';

  @override
  String get billingPrioritySupport => 'Prednostna podpora';

  @override
  String get billingDisclosureProRenewing =>
      'Pro je samodejno obnavljajoča se naročnina';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus in Pro sta samodejno obnavljajoči se naročnini';

  @override
  String get billingDisclosureAppleBilling =>
      'Plačilo bo bremenilo vaš Apple ID ob potrditvi nakupa.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Plačilo bo bremenilo vaš račun Google Play ob potrditvi nakupa.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Naročnina se samodejno podaljša za enako obdobje po isti ceni, razen če samodejno podaljšanje izklopite vsaj 24 ur pred koncem trenutnega obdobja.';

  @override
  String get billingDisclosureAppleManage =>
      'Upravljajte ali prekličite kadarkoli v Nastavitve › vaš Apple ID › Naročnine.';

  @override
  String get billingDisclosureGoogleManage =>
      'Upravljajte ali prekličite kadarkoli v Google Play › Plačila in naročnine.';

  @override
  String get billingReferFriend => 'Priporočite prijatelju';

  @override
  String get billingHowItWorks => 'Kako deluje';

  @override
  String get billingHowShareTitle => 'Delite povezavo';

  @override
  String get billingHowShareBody => 'Pošljite jo prijatelju.';

  @override
  String get billingHowSignUpTitle => 'Prijavita se';

  @override
  String get billingHowSignUpBody =>
      'Vaš prijatelj se pridruži preko povezave.';

  @override
  String get billingHowBothTitle => 'Oba dobita Pro';

  @override
  String get billingHowBothBody => 'Vsak od vidva prejme mesec Pro brezplačno.';

  @override
  String get billingYourReferrals => 'Vaša priporočila';

  @override
  String get billingInvited => 'Povabljeni';

  @override
  String get billingJoined => 'Pridruženi';

  @override
  String get billingMonthsEarned => 'Prisluženi meseci';

  @override
  String get billingInviteFriend => 'Povabi prijatelja';

  @override
  String get billingInviteBody =>
      'Vidva s prijateljem dobita vsak po en mesec naročnine Pro.';

  @override
  String get billingYourCode => 'Vaša koda';

  @override
  String get billingCopyLink => 'Kopiraj povezavo';

  @override
  String get billingShareInvite => 'Deli povabilo';

  @override
  String get giftUnavailable =>
      'Darilna povabila v tej različici niso na voljo.';

  @override
  String get giftPageTitle => 'Podari FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Trenutno ni na voljo brezplačnih darilnih povabil.';

  @override
  String get giftFormTitle => 'Pošlji brezplačno povabilo';

  @override
  String get giftFormBody =>
      'Prejemnik prevzame darilo s tem preverjenim e-poštnim naslovom. E-pošte ne pošljemo namesto vas.';

  @override
  String get giftFieldFrom => 'Od';

  @override
  String get giftFieldRecipientName => 'Ime prejemnika';

  @override
  String get giftFieldRecipientEmail => 'E-pošta prejemnika';

  @override
  String get giftFieldOccasion => 'Priložnost (izbirno)';

  @override
  String get giftNoOccasion => 'Brez priložnosti';

  @override
  String get giftOccasionBirthday => 'Rojstni dan';

  @override
  String get giftOccasionAnniversary => 'Obletnica';

  @override
  String get giftOccasionOther => 'Drugo';

  @override
  String get giftFieldCardGreeting => 'Voščilo na kartici';

  @override
  String get giftFieldCardGreetingHelper =>
      'To se na kartici prikaže točno tako, kot je zapisano.';

  @override
  String get giftFieldPrivateNote => 'Zasebna opomba (izbirno)';

  @override
  String get giftCreateAction => 'Ustvari brezplačno darilo';

  @override
  String get giftClaimedTitle => 'Darilo prevzeto';

  @override
  String get giftClaimedActive => 'Vaše darilo FitCheck Pro je aktivno.';

  @override
  String get giftClaimedQueued =>
      'Vaše darilo FitCheck Pro se začne po izteku trenutnega dostopa.';

  @override
  String get giftLinkCopied => 'Povezava do darila je kopirana v odložišče.';

  @override
  String get giftErrorName => 'Vnesite ime.';

  @override
  String get giftErrorEmail => 'Vnesite veljaven e-poštni naslov.';

  @override
  String get giftErrorGreeting => 'Vnesite voščilo na kartici.';

  @override
  String get giftErrorGreetingLength => 'Uporabite največ 80 znakov.';

  @override
  String get giftClaimAction => 'Prevzemi darilo';

  @override
  String get giftCardPreview => 'Predogled kartice';

  @override
  String get giftGiftForYou => 'Darilo zate';

  @override
  String get giftGiftWaiting => 'Darilo te čakao';

  @override
  String get giftOpenBody =>
      'Odprite darila in jih prevzemite s potrjenim e-poštnim naslovom.';

  @override
  String get giftOpenGifts => 'Odpri darila';

  @override
  String get giftSendInvitation => 'Pošlji povabilo';

  @override
  String get settingsAiProviderSection => 'Ponudnik';

  @override
  String get settingsAiCustom => 'Po meri';

  @override
  String get settingsAiUrlHelper =>
      'Uporabite javni URL, ki ga strežnik doseže. Lokalni strežnik ne deluje.';

  @override
  String get settingsAiConnectionSection => 'Povezava';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'Ključ API';

  @override
  String get settingsAiApiKeySaved => 'Shranjeno. Pustite prazno za ohranitev.';

  @override
  String get settingsAiChatModel => 'Model za klepet';

  @override
  String get settingsAiVisionModel => 'Vidni model (izbirno)';

  @override
  String get settingsAiImageModel => 'Model za slike (izbirno)';

  @override
  String get settingsAiImageModelNote =>
      'Ustvarjanje slik zahteva klepet z OpenAI-združljivimi odgovori in response_modalities.';

  @override
  String get settingsAiTestConnection => 'Preizkusi povezavo';

  @override
  String get calendarTitle => 'Koledar';

  @override
  String get calendarGoToToday => 'Pojdi na danes';

  @override
  String get calendarConnectTooltip => 'Poveži koledar';

  @override
  String get calendarAddEvent => 'Dodaj dogodek';

  @override
  String get calendarEmptyTitle => 'Nič ni načrtovano';

  @override
  String get calendarEmptyBody => 'Dodajte dogodek in načrtujte obleko.';

  @override
  String get calendarPreviousMonth => 'Prejšnji mesec';

  @override
  String get calendarNextMonth => 'Naslednji mesec';

  @override
  String get calendarAllDay => 'Ves dan';

  @override
  String get calendarOutfitLinked => 'Obleka povezana';

  @override
  String get calendarEventOptions => 'Možnosti dogodka';

  @override
  String get calendarDeleteTitle => 'Izbrišem ta dogodek?';

  @override
  String get calendarChangeOutfit => 'Spremeni obleko';

  @override
  String get calendarLinkOutfit => 'Poveži obleko';

  @override
  String get calendarRemoveOutfit => 'Odstrani obleko';

  @override
  String get calendarNewEvent => 'Nov dogodek';

  @override
  String get calendarEditEvent => 'Uredi dogodek';

  @override
  String get calendarTitleLabel => 'Naslov';

  @override
  String get calendarTitleRequired => 'Dodajte naslov';

  @override
  String get calendarEndBeforeStart => 'Konec po začetnem času';

  @override
  String get calendarStarts => 'Začetek';

  @override
  String get calendarEnds => 'Konec';

  @override
  String get calendarPlaceOptional => 'Kraj (izbirno)';

  @override
  String get calendarNotesOptional => 'Opombe (izbirno)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Sestavite obleko in jo povežite s tem dogodkom.';

  @override
  String get calendarBuildOutfit => 'Sestavi obleko';

  @override
  String get calendarConnectionsTitle => 'Koledarji';

  @override
  String get calendarConnectionsBody =>
      'Dogodki, ki jih dodate sem, ostanejo v FitCheck AI.';

  @override
  String get calendarDisconnect => 'Prekini povezavo';

  @override
  String get calendarNotAvailable => 'Še ni na voljo';

  @override
  String get profileSectionExplore => 'Razišči';

  @override
  String get profileNavTryOn => 'Preizkusi';

  @override
  String get profileNavRewards => 'Nagrade';

  @override
  String get profileSupport => 'Podpora';

  @override
  String get profileHelp => 'Pomoč';

  @override
  String get profileAbout => 'O aplikaciji';

  @override
  String get profileAboutBody => 'Vaša omara, obleke in načrti na enem mestu.';

  @override
  String get profileSignOutTitle => 'Odjava?';

  @override
  String get profileSignOutBody =>
      'V sistem se lahko ponovno prijavite kadarkoli.';

  @override
  String get profileEditTitle => 'Uredi profil';

  @override
  String get profileYourProfile => 'Vaš profil';

  @override
  String get profileBodyProfiles => 'Profili postave';

  @override
  String get profileBodyEmptyTitle => 'Ni še profilov postave';

  @override
  String get profileBodyEmptyBody =>
      'Dodajte višino in postavo za boljše prileganje.';

  @override
  String get profileBodyAdd => 'Dodaj profil';

  @override
  String get profileBodyDefaultNote =>
      'Vaš privzeti profil se uporablja za pomerjanje.';

  @override
  String get profileBodyDefaultBadge => 'Privzeto';

  @override
  String get profileBodyMakeDefault => 'Nastavi kot privzeto';

  @override
  String get profileBodyDeleteBody => 'Tega dejanja ni mogoče razveljaviti.';

  @override
  String get profileBodyRequired => 'Obvezno';

  @override
  String get profileBodyCheckNumber => 'Preverite to številko';

  @override
  String get profileBodyNew => 'Nov profil postave';

  @override
  String get profileBodyNameHint => 'Na primer: Jaz';

  @override
  String get profileBodyHeight => 'Višina';

  @override
  String get profileBodyWeight => 'Teža';

  @override
  String get profileBodyBuild => 'Postava';

  @override
  String get profileBodySkinTone => 'Odtenek kože';

  @override
  String get profileBirthDateNeededBody =>
      'Dodajte datum rojstva k času rojstva.';

  @override
  String get profileBirthDateNeededTitle => 'Potreben je datum rojstva';

  @override
  String get profilePartlySavedBody =>
      'Shranili smo vaše ime in fotografijo. Podatki o rojstvu niso bili shranjeni; poskusite znova kasneje.';

  @override
  String get profilePartlySavedTitle => 'Delno shranjeno';

  @override
  String get profileSavedBody => 'Vaš profil je shranjen.';

  @override
  String get profileChangePhoto => 'Spremeni profilno fotografijo';

  @override
  String get profilePhotoLabel => 'Profilna fotografija';

  @override
  String get profilePhotoHint => 'Tapnite za izbiro nove';

  @override
  String get profileBirthDateLabel => 'Datum rojstva (neobvezno)';

  @override
  String get profileBirthTimeLabel => 'Čas rojstva (neobvezno)';

  @override
  String get profileBirthTimeHelper => 'Izboljša točnost predlogov';

  @override
  String get profileBirthPlaceLabel => 'Kraj rojstva (neobvezno)';

  @override
  String get profileBirthPlaceHint => 'Na primer: Ljubljana, Slovenija';

  @override
  String get profileHelpContactTitle => 'Vprašajte nas karkoli';

  @override
  String get profileHelpContactBody =>
      'Pošljite sporočilo in odgovorili vam bomo po e-pošti, običajno v enem dnevu.';

  @override
  String get profileHelpContactAction => 'Kontaktirajte podporo';

  @override
  String get profileHelpFaqTitle => 'Pogosta vprašanja';

  @override
  String get profileFaqAddPiecesTitle => 'Kako dodam kose v omaro?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tapnite Dodaj v zavihku Omara. Posnemite fotografijo ali jo izberite iz galerije; vsak kos bomo našli in označili za vas.';

  @override
  String get profileFaqMatchingTitle => 'Kako deluje kombiniranje oblačil?';

  @override
  String get profileFaqMatchingBody =>
      'Odprite Za vas in izberite kose, ki jih imate. Predlagamo vam, kaj se poda k njim, in sestavimo celotne obleke iz vaše omare.';

  @override
  String get profileFaqTryOnTitle =>
      'Ali lahko uporabim svoje fotografije za pomerjanje?';

  @override
  String get profileFaqTryOnBody =>
      'Da. Dodajte svojo fotografijo v celotni postavi, nato izberite kose, da jih vidite na sebi.';

  @override
  String get profileFaqRewardsTitle => 'Kako zbiram nagrade?';

  @override
  String get profileFaqRewardsBody =>
      'Redno načrtujte in beležite obleke. Z uporabo gradite nize in dosegate dosežke.';

  @override
  String get profileFaqPrivacyTitle => 'Ali je moja omara zasebna?';

  @override
  String get profileFaqPrivacyBody =>
      'Da. Vaša omara in obleke so zasebne, razen če delite povezavo do posamezne obleke.';

  @override
  String get profileHelpMoreTitle => 'Več pomoči';

  @override
  String get profileHelpGuides => 'Vodiči';

  @override
  String get profileHelpGuidesBody => 'Kako deluje posamezna funkcija';

  @override
  String get feedbackCategoryBug => 'N nekaj se je pokvarilo';

  @override
  String get feedbackCategoryIdea => 'Ideja';

  @override
  String get feedbackCategoryGeneral => 'Splošno';

  @override
  String get feedbackCategoryHelp => 'Potrebujem pomoč';

  @override
  String get feedbackHintBug =>
      'Kaj se je zgodilo in kaj ste pričakovali? Koraki nam pomagajo odpraviti težavo.';

  @override
  String get feedbackHintIdea => 'Kaj bi želeli in zakaj?';

  @override
  String get feedbackHintGeneral =>
      'Povejte nam svoje mnenje ali postavite vprašanje.';

  @override
  String get feedbackAttachmentLimitBody => 'Dodate lahko do 5 slik.';

  @override
  String get feedbackAttachmentLimitTitle => 'Dosežena omejitev';

  @override
  String get feedbackImageTooLargeBody => 'Izberite sliko, manjšo od 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Slika je prevelika';

  @override
  String get feedbackTitle => 'Pošljite povratne informacije';

  @override
  String get feedbackAboutLabel => 'O čem gre?';

  @override
  String get feedbackSubjectLabel => 'Zadeva';

  @override
  String get feedbackSubjectRequired => 'Vnesite zadevo';

  @override
  String get feedbackSubjectTooShort => 'Zadeva mora imeti vsaj 3 znake';

  @override
  String get feedbackDetailsLabel => 'Podrobnosti';

  @override
  String get feedbackDetailsRequired => 'Dodajte podrobnosti';

  @override
  String get feedbackDetailsTooShort => 'Opis mora imeti vsaj 10 znakov';

  @override
  String get feedbackAddScreenshot => 'Dodaj posnetek zaslona';

  @override
  String get feedbackAttachmentHint => 'Do 5, vsaka do 5 MB';

  @override
  String get feedbackSend => 'Pošlji';

  @override
  String get feedbackEmptyTitle => 'Še nič poslanega';

  @override
  String get feedbackEmptyBody =>
      'Poslana sporočila in njihov status bodo prikazani tukaj.';

  @override
  String get feedbackHistoryTitle => 'Vaša sporočila';

  @override
  String get feedbackStatusOpen => 'Odprto';

  @override
  String get feedbackStatusInProgress => 'V obdelavi';

  @override
  String get feedbackStatusResolved => 'Rešeno';

  @override
  String get feedbackStatusClosed => 'Zaprto';

  @override
  String get legalIntro =>
      'Kako varujemo vaše podatki in pogoji uporabe aplikacije FitCheck AI.';

  @override
  String get legalPolicies => 'Pravilniki';

  @override
  String get legalPrivacySubtitle => 'Kaj zbiramo in zakaj';

  @override
  String get legalTermsTitle => 'Pogoji uporabe';

  @override
  String get legalTermsSubtitle => 'Pravila uporabe aplikacije';

  @override
  String get legalLicences => 'Licence odprtokodne programske opreme';

  @override
  String get legalSupportSubtitle => 'Pomoč, stiki in zahteve glede zasebnosti';

  @override
  String get legalReportAbuse => 'Prijavi težavo ali zlorabo';

  @override
  String get permissionCameraTitle => 'Dostop do kamere';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI uporablja kamero za fotografiranje oblačil in oprave za umetno inteligenco ter urejanje omare.';

  @override
  String get permissionPhotoTitle => 'Dostop do galerije';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI potrebuje dostop do fotografij, da lahko izberete slike oblačil in oprave za funkcije umetne inteligence in omaro.';

  @override
  String get permissionNotNow => 'Ne zdaj';

  @override
  String get permissionOpenSettings => 'Odpri nastavitve';

  @override
  String authSignedInAs(String name) {
    return 'Prijavljeni ste kot $name';
  }

  @override
  String get authSignedIn => 'Prijavljeni';

  @override
  String get authWelcomeBackTitle => 'Dobrodošli nazaj';

  @override
  String get authSignInFailed => 'Prijava ni uspela';

  @override
  String get authWelcomeTitle => 'Dobrodošli';

  @override
  String get authSignUpFailed => 'Registracija ni uspela';

  @override
  String get authGoogleSignInFailed => 'Prijava z Googlom ni uspela';

  @override
  String get authAppleSignInFailed => 'Prijava z Apple ni uspela';

  @override
  String get authConfirmEmailTitle => 'Potrdite svoj e-poštni naslov';

  @override
  String get authConfirmEmailBody =>
      'Preverite prejeto pošto za potrditveno sporočilo in se nato prijavite.';

  @override
  String get authClosetReady => 'Vaša omara je pripravljena.';

  @override
  String get authSignedOutTitle => 'Odjavljeni';

  @override
  String get authSignedOutBody => 'Odjavljeni ste.';

  @override
  String get authSignOutFailed => 'Odjava ni uspela';

  @override
  String get authEmailSentTitle => 'E-poštno sporočilo poslano';

  @override
  String get authResetLinkSent =>
      'Preverite e-pošto za povezavo za ponastavitev.';

  @override
  String get authPasswordUpdatedTitle => 'Geslo posodobljeno';

  @override
  String get authPasswordUpdated => 'Vaše geslo je posodobljeno.';

  @override
  String get authPasswordNotUpdated => 'Geslo ni posodobljeno';

  @override
  String get authCouldNotSendEmail =>
      'E-poštnega sporočila ni bilo mogoče poslati';

  @override
  String get authEmailNotSent => 'E-pošta ni bila poslana';

  @override
  String get authResendSentBody => 'Poslali smo novo potrditveno e-pošto.';

  @override
  String get outfitPreviewWithAi => 'Predogled z AI';

  @override
  String get outfitNewPreview => 'Ustvari nov predogled';

  @override
  String get outfitBuilderClosetHeading => 'Tvoj omarica';

  @override
  String get outfitBuilderSearchHint => 'Išči dela';

  @override
  String get outfitClearSearch => 'Počisti iskanje';

  @override
  String get outfitBuilderAddPiecesTitle => 'Najprej dodaj dela';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Sezonske kombinacije nastanejo iz del v tvoji omarici.';

  @override
  String get outfitBuilderNoMatches => 'Nobeno delo ne ujema.';

  @override
  String get outfitNameLabel => 'Ime kombinacije';

  @override
  String get outfitNameHint => 'Npr. Tedenski len';

  @override
  String get outfitPreviewSemantic => 'AI predogled kombinacije';

  @override
  String get outfitChoosePieces => 'Izberi dela';

  @override
  String get outfitTapPiecesHint => 'Dotakni se del spodaj za dodajanje.';

  @override
  String get outfitShareTooltip => 'Deli';

  @override
  String get outfitSaveFavourite => 'Shrani v priljubljene';

  @override
  String get outfitPiecesHeading => 'Dela';

  @override
  String get outfitWearHistoryEmpty =>
      'Nosite enkrat in datumi se prikažejo tukaj.';

  @override
  String get outfitWearHistoryTitle => 'Zgodovina nošenja';

  @override
  String get outfitWearHistoryError => 'Datumov ni mogoče naložiti.';

  @override
  String get outfitWornOn => 'Nošeno na';

  @override
  String get outfitEditTitle => 'Uredi kombinacijo';

  @override
  String get outfitSavedPhotosFailed =>
      'Podrobnosti so shranjene, fotografije pa ne.';

  @override
  String get outfitNoPhotosBody =>
      'Nihče fotografij še. Kombinacija namesto tega prikaže svoja dela.';

  @override
  String get outfitOccasionLabel => 'Priložnost';

  @override
  String get outfitOccasionNone => 'Brez';

  @override
  String get outfitTagsHint => 'Loči z vejico';

  @override
  String get outfitDraftBody => 'Skrit iz glavnega seznama';

  @override
  String get outfitPublic => 'Javna';

  @override
  String get outfitPublicBody => 'Vsi, ki imajo povezavo, ga lahko vidijo.';

  @override
  String get outfitDeleteFromDetail =>
      'Izbriši to kombinacijo z njezine strani s podrobnostmi.';

  @override
  String get outfitNewCollection => 'Nova zbirka';

  @override
  String get outfitNoCollectionsTitle => 'Ni zbirk';

  @override
  String get outfitNoCollectionsBody =>
      'Kombinacije združuj po potovanju, letnem času ali razpoloženju.';

  @override
  String get outfitCreateCollection => 'Ustvari zbirko';

  @override
  String get outfitAddOutfits => 'Dodaj kombinacije';

  @override
  String get outfitRename => 'Preimenuj';

  @override
  String get outfitCollectionDeleteBody => 'Kombinacije v njej bodo ohranjene.';

  @override
  String get outfitCollectionsNotLoaded => 'Kombinacije niso naložene';

  @override
  String get outfitRenameCollection => 'Preimenuj zbirko';

  @override
  String get outfitDescriptionOptional => 'Opis (neobvezno)';

  @override
  String get outfitAllInCollection => 'Vse kombinacije so že v tej zbirki.';

  @override
  String get photoshootSubtitleUpload =>
      'Studijski portreti iz lastnih fotografij';

  @override
  String get photoshootSubtitleConfigure => 'Izberi slog, format in število';

  @override
  String get photoshootSubtitleGenerating => 'To traja minuto ali dve';

  @override
  String get photoshootAddPhotosSemantic => 'Dodaj fotografije iz albume';

  @override
  String get photoshootUploadTitle => 'Dodaj od 1 do 4 fotografij sebe';

  @override
  String get photoshootUploadBody => 'Dotakni se za izbor iz albume';

  @override
  String get photoshootAddToContinue => 'Dodaj fotografijo za nadaljevanje';

  @override
  String get photoshootAddAnotherPhoto => 'Dodaj še eno fotografijo';

  @override
  String get photoshootTipsTitle => 'Za najboljši rezultat';

  @override
  String get photoshootTipsBody =>
      'Uporabite jasne, dobro osvetljene fotografije obraza iz različnih zornih kotov. Sončna očala in kape pustite čez.';

  @override
  String get photoshootStarting => 'Zagon';

  @override
  String get photoshootCancelling => 'Preklicanje';

  @override
  String get photoshootFailed => 'Napaka';

  @override
  String get recommendTabMatches => 'Uparjanje';

  @override
  String get recommendTabComplete => 'Popolni';

  @override
  String get recommendTabWeather => 'Vreme';

  @override
  String get recommendTabColours => 'Barve';

  @override
  String get recommendTabShop => 'Nakup';

  @override
  String get recommendNoMatchesTitle => 'Ni ujemanj';

  @override
  String get recommendNoMatchesBody =>
      'Izberi kos in izberem kaj se lepo ujema.';

  @override
  String get recommendPickPiece => 'Izberi kos';

  @override
  String get recommendNothingMatchesTitle => 'Ni ujemanj za te kose';

  @override
  String get recommendNothingMatchesBody =>
      'Poskusi druge kose ali dodaš več v omaro.';

  @override
  String get recommendChangePieces => 'Spremeni kose';

  @override
  String get recommendDefaultReason => 'Ujema se s kosmi, ki si jih izbral/a.';

  @override
  String get recommendCompleteTitle => 'Dokončaj look';

  @override
  String get recommendCompleteBody => 'Izberi kos, ostalo popolnimo.';

  @override
  String get recommendWorking => 'Delujem';

  @override
  String get recommendGenerate => 'Ustvari';

  @override
  String get recommendChooseStyleBody => 'Izberi slog in ustvari look.';

  @override
  String get recommendNoLooksTitle => 'Ni lookov za te kose';

  @override
  String get recommendNoLooksBody => 'Poskusi drug slog ali druge kose.';

  @override
  String get recommendDefaultLook => 'Look za tvoje kose';

  @override
  String get recommendNoPiecesBody => 'Za ta look ni bilo kose.';

  @override
  String get recommendCityLabel => 'Mesto';

  @override
  String get recommendCheck => 'Preveri';

  @override
  String get recommendWeatherTitle => 'Kako je vreme?';

  @override
  String get recommendWeatherBody => 'Vpiši svoje mesto za danes predloge.';

  @override
  String get recommendWearToday => 'Nositi danes';

  @override
  String get recommendWeatherNoPieces => 'Ni kose za to vreme v omari.';

  @override
  String get recommendBudgetLabel => 'Budžet do';

  @override
  String get recommendLooking => 'Iščem';

  @override
  String get recommendFindWhatToBuy => 'Poišči kaj kupiti';

  @override
  String get recommendFillGapsTitle => 'Izpolni pomanjkanja';

  @override
  String get recommendFillGapsBody =>
      'Nastavi budžet in predlagam manjkajoče kose.';

  @override
  String get recommendNoGapsTitle => 'Ni pomanjkanj';

  @override
  String get recommendNoGapsBody =>
      'Poskusi večji budžet ali drugo kategorijo.';

  @override
  String get recommendMoodEveryday => 'Dnevno';

  @override
  String get recommendMoodBigMeeting => 'Velika seja';

  @override
  String get recommendDayLabel => 'Dan';

  @override
  String get recommendReadingStars => 'Beremo zvezde';

  @override
  String get recommendGetMyColours => 'Poglej moje barve';

  @override
  String get recommendLuckyColoursTitle => 'Tvoje srečne barve';

  @override
  String get recommendLuckyColoursBody =>
      'Izberi dan in ti predložimo barve ter kos oblačil zanj.';

  @override
  String get recommendLuckyColoursSection => 'Srečne barve';

  @override
  String get recommendAvoidColoursSection => 'Barve, na katere pazi';

  @override
  String get recommendBirthDateTitle => 'Dodaj datum rojstva';

  @override
  String get recommendBirthDateBody =>
      'Za branje barv potrebujemo tvoj datum rojstva.';

  @override
  String get recommendEditProfile => 'Uredi profil';

  @override
  String get recommendNothingThisDay => 'Za ta dan ni predlogov.';

  @override
  String get recommendUnnamedColour => 'Imenovanobarva';

  @override
  String get recommendFromCloset => 'Iz tvojega omre';

  @override
  String get recommendNoPiecesInColours => 'Še ni kosov teh barv.';

  @override
  String get recommendOutfitIdeas => 'Ideje za kombinacije';

  @override
  String get recommendNoOutfitsInColours =>
      'Še ni celotne kombinacije teh barv.';

  @override
  String get recommendDefaultOutfitIdea => 'Ideja za kombinacijo';

  @override
  String get recommendPickUpToThree => 'Izberi do tri kos oblačil';

  @override
  String get recommendEmptyClosetBody =>
      'Najprej dodaj nekaj kosov, nato se vrni po ujemanja.';

  @override
  String get dashboardDressForDay => 'Oblači se za prihajajoči dan.';

  @override
  String get dashboardOutfitOfDay => 'Kombinacija dneva';

  @override
  String get dashboardFreshLook => 'Svež videz';

  @override
  String get subscriptionManageInStoreTitle => 'Upravljanje v trgovini';

  @override
  String get subscriptionManageInStoreBody =>
      'Ta načrt se obračuna prek trgovine. Upravljaj ga v nastavitvah svojega računa trgovine.';

  @override
  String get subscriptionCancelledTitle => 'Naročilo preklicano';

  @override
  String get subscriptionCancelledBody =>
      'Tvoj načrt bo aktiven do konca tega obračunskega obdobja.';

  @override
  String get subscriptionCancelFailedTitle => 'Preklic ni mogoč';

  @override
  String get subscriptionCouldNotOpenTitle => 'Odpiranje ni mogoče';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Upravljanja obračunavanja ni bilo mogoče odpreti.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Linke ni bilo mogoče odpreti.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Lazko naloži tvoj povezava';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Lazko naloži tvoj preporočilni link. Poskusi znova.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopirano';

  @override
  String get subscriptionReferralCopiedBody =>
      'Preporočilni link je bil kopiran.';

  @override
  String get subscriptionReferralShareSubject => 'Poskusi FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Pridruži se FitCheck AI in oboje prejme mesec Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Povezava je bila kopirana';

  @override
  String get subscriptionShareUnavailableBody =>
      'Deljenje ni na voljo, zato je bila povezava kopirana.';

  @override
  String get subscriptionShareFailedTitle => 'Deljenje ni bilo mogoče';

  @override
  String get subscriptionShareFailedBody =>
      'Povezavo namesto tega kopiraj s strani za preporočila.';

  @override
  String get subscriptionStoreReadyTitle => 'Skladišče je pripravljen';

  @override
  String get subscriptionStoreReadyBody =>
      'Cene skladišča so na voljo. Zaposlitveno lahko preklopiš.';

  @override
  String get purchaseFailedTitle => 'Nakup ni bil uspešen';

  @override
  String get purchaseUnavailableTitle => 'Nakup ni na voljo';

  @override
  String get purchaseIapUnavailableBody =>
      'Nakupi v aplikaciji na tem napravi niso na voljo.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Ta načrt še ni na voljo za nakup.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Ta načrt še ni na voljo v trgovini. Prosim preverite kasneje.';

  @override
  String get purchaseStartFailedBody =>
      'Nakup ni bil lahko zahtevati. Poskusi znova.';

  @override
  String get purchaseNoPaymentLinkBody => 'Vpis ni vrnil plačilne povezave.';

  @override
  String get purchasePendingTitle => 'Nakup čaka potrjevanje';

  @override
  String get purchasePendingBody =>
      'Tvoj nakup čaka potrjevanje. Dostop dobiš, kadar je potrjen.';

  @override
  String get purchaseFailedBody => 'Nakup ni bil uspešen. Poskusi znova.';

  @override
  String get purchaseRestoredTitle => 'Vrnjeno';

  @override
  String get purchaseRestoredBody => 'Tvoji nakupi so bili vrnjeni.';

  @override
  String get purchaseActiveTitle => 'Naročnina je aktivna';

  @override
  String get purchaseActiveBody => 'Tvoja naročnina je aktivna. Dobrodošel.';

  @override
  String get purchaseSignInRequiredTitle => 'Prijavitev je potrebna';

  @override
  String get purchaseSignInRequiredBody => 'Prijavi se, da končaš svoj nakup.';

  @override
  String get purchaseErrorTitle => 'Napaka pri nakupu';

  @override
  String get purchaseInvalidTransactionBody =>
      'Nakup ni vključeval preverljivega ID-ja transakcije.';

  @override
  String get purchaseVerificationPendingTitle => 'Potrditev v teku';

  @override
  String get purchaseVerificationPendingBody =>
      'Trenutno ne moremo potrditi vašega nakupa v trgovini. Postopek se bo samodejno končal, dvakrat pa vam ne bodo zaračunali.';

  @override
  String get purchaseNotAppliedTitle => 'Nakup ni bil upoštevan';

  @override
  String get purchaseNotAppliedBody =>
      'Vašega nakupa ni bilo mogoče upoštevati na vašem računu. Kontaktirajte podporo in ga ne kupujte znova.';

  @override
  String get purchaseRestoreFailedTitle => 'Obnovitev ni uspela';

  @override
  String get purchaseRestoreFailedBody =>
      'Nakupov ni bilo mogoče obnoviti. Poskusite znova.';

  @override
  String get purchaseRecoveredActiveBody => 'Vaša naročnina je aktivna.';

  @override
  String get purchaseCompleteTitle => 'Nakup končan';

  @override
  String get giftCreateFailedTitle => 'Podarila ni bilo mogoče ustvariti';

  @override
  String get giftClaimFailedTitle => 'Podarila ni bilo mogoče prevzeti';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podarila za vas',
      one: 'Podarilo za vas',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mesec',
      '12': '1 leto',
      'other': '$months mesecev',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining še',
      one: 'še 1',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration za FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender vam je poslal $duration FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Podarilo FitCheck Pro za $recipient';
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
  String get giftPreviewPlaceholderRecipient => 'prejemnik';

  @override
  String get giftPreviewPlaceholderSender => 'vi';

  @override
  String get settingsSavedTitle => 'Shranjeno';

  @override
  String get settingsNotSavedTitle => 'Ni shranjeno';

  @override
  String get settingsAiChooseProviderBody => 'Izberite ponudnika.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Prilagoditveni ponudnik potrebuje API naslov.';

  @override
  String get settingsAiKeyRequiredBody => 'Vnesite API ključ.';

  @override
  String get settingsAiSavedBody => 'Vaše AI nastavitve so shranjene.';

  @override
  String get settingsAiMissingDetailsTitle => 'Manjkajo podrobnosti';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Vnesite API naslov in pogovorni model za testiranje.';

  @override
  String get settingsAiKeyNeededTitle => 'Potreben API ključ';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Vnesite API ključ za preizkus. Vaš shranjen ključ ostane zaseben.';

  @override
  String get settingsAiKeyToTestBody => 'Vnesite API ključ za preizkus.';

  @override
  String get settingsAiConnectedTitle => 'Povezano';

  @override
  String get settingsAiConnectedBody => 'Povezava deluje.';

  @override
  String get settingsAiTestFailedTitle => 'Preizkus ni uspel';

  @override
  String get settingsPreferencesSavedBody => 'Vaše nastavitve so shranjene.';

  @override
  String get settingsPasswordNotChangedTitle => 'Geslo ni spremenjeno';

  @override
  String get settingsOAuthPasswordBody =>
      'Ta račun se prijavlja prek Googla ali Appleja. Za nastavitev gesla uporabite »Geslo pozabil«.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Trenutno geslo ni pravilno.';

  @override
  String get settingsExportReadyTitle => 'Izvoz pripravljen';

  @override
  String get settingsExportReadyBody =>
      'Izvoz podatkov je pripravljen za prenos.';

  @override
  String get settingsLinkCopiedTitle => 'Povezava kopirana';

  @override
  String get settingsExportClipboardBody =>
      'Preglednika ni bilo mogoče odpreti, zato smo kopirali povezavo za prenos. Prilepite jo v pregledovalniku čimprej: razveljavi se.';

  @override
  String get settingsExportFailedTitle => 'Izvoz ni uspel';

  @override
  String get settingsAccountNotDeletedTitle => 'Račun ni izbrisan';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Dodate lahko največ $max fotografij.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Omejitev fotografij';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Dodajte vsaj eno fotografijo.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Ni izbranih fotografij';

  @override
  String get photoshootDescribeLookBody => 'Opišite videz, ki ga želite.';

  @override
  String get photoshootPromptNeededTitle => 'Potrebna navodila';

  @override
  String get photoshootConsentFeatureLabel => 'AI fotografski dnevnik';

  @override
  String get photoshootStatusPreparing => 'Priprava fotografij';

  @override
  String get photoshootStatusGenerating => 'Ustvarjanje';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Skupina $current od $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'opravljeno $done od $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Ustvarjanje ni uspel.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return 'Pripravljeno $ready, spodrlo $failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Delno dokončano';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografij je pripravljenih.',
      few: '$count fotografije so pripravljene.',
      two: '2 fotografiji sta pripravljeni.',
      one: '1 fotografija je pripravljena.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Povezava je prekinjena. Poskusite znova.';

  @override
  String get photoshootCouldNotCancelTitle => 'Preklic ni mogoč';

  @override
  String get photoshootRetryFailedTitle => 'Poskus ni uspel';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Fotografija $number je pripravljena.';
  }

  @override
  String get photoshootReplacedTitle => 'Zamenjano';

  @override
  String get photoshootSavedToGalleryBody => 'Shranjeno v vašo galerijo.';

  @override
  String get photoshootSavedTitle => 'Shranjeno';

  @override
  String get photoshootNotSavedTitle => 'Ni shranjeno';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vse $count fotografij je v vaši galeriji.',
      few: '$count fotografije so v vaši galeriji.',
      two: '2 fotografiji sta v vaši galeriji.',
      one: '1 fotografija je v vaši galeriji.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'Shranjenih je $saved od $total.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Nekatere fotografije niso shranjene';

  @override
  String get tryonConsentFeatureLabel => 'Virtualno preizkušanje';

  @override
  String get tryonAvatarUpdatedBody => 'Vaša fotografija je posodobljena.';

  @override
  String get tryonSavedTitle => 'Shranjeno';

  @override
  String get tryonUploadFailedTitle => 'Nalaganje ni uspelo';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Najprej izberite fotografijo oblačila.';

  @override
  String get tryonNoGarmentTitle => 'Ni oblačila';

  @override
  String get tryonWaitForUploadBody =>
      'Počakajte, da se vaša fotografija konča nalaganje.';

  @override
  String get tryonStillUploadingTitle => 'Nadaljuje se nalaganje';

  @override
  String get tryonAddYourPhotoFirstBody => 'Najprej dodajte svojo fotografijo.';

  @override
  String get tryonReadyBody => 'Vaše preizkušanje je pripravljeno.';

  @override
  String get tryonFailedTitle => 'Preizkušanje ni uspelo';

  @override
  String get tryonSavedToGalleryBody => 'Shranjeno v vašo galerijo.';

  @override
  String get tryonNotSavedTitle => 'Ni shranjeno';

  @override
  String get calendarEventAddedBody => 'Dogodek je dodan';

  @override
  String get calendarEventPlannedTitle => 'Načrtovano';

  @override
  String get calendarEventSavedBody => 'Dogodek je shranjen';

  @override
  String get calendarSavedTitle => 'Shranjeno';

  @override
  String get calendarEventNotSavedTitle => 'Dogodek ni shranjen';

  @override
  String get calendarEventRemovedBody => 'Dogodek odstranjen';

  @override
  String get calendarEventDeletedTitle => 'Izbrisano';

  @override
  String get calendarEventNotDeletedTitle => 'Dogodek ni izbrisan';

  @override
  String get calendarOutfitNotLinkedTitle => 'Oblačila niso povezana';

  @override
  String get calendarLinkedTitle => 'Povezano';

  @override
  String get calendarOutfitNotRemovedTitle => 'Oblačila niso odstranjena';

  @override
  String get calendarOutfitRemovedBody => 'Oblačila odstranjena';

  @override
  String get calendarDisconnectedBody => 'Koledar odklopljen';

  @override
  String get calendarDisconnectedTitle => 'Odklopljeno';

  @override
  String get calendarNotDisconnectedTitle => 'Koledar ni odklopljen';

  @override
  String get calendarTodayLabel => 'danes';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dogodkov',
      many: '$count dogodkov',
      few: '$count dogodki',
      one: '1 dogodek',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start do $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, oblačila povezana';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" bo odstranjen.';
  }

  @override
  String get calendarThisAppLabel => 'Ta aplikacija';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Usklajevanje s $provider še ni na voljo. Dogodke lahko še vedno dodajate tukaj.';
  }

  @override
  String get calendarWeekdaySunShort => 'Ned';

  @override
  String get calendarWeekdayMonShort => 'Pon';

  @override
  String get calendarWeekdayTueShort => 'Tor';

  @override
  String get calendarWeekdayWedShort => 'Sre';

  @override
  String get calendarWeekdayThuShort => 'Čet';

  @override
  String get calendarWeekdayFriShort => 'Pet';

  @override
  String get calendarWeekdaySatShort => 'Sob';

  @override
  String get calendarWeekdayMonday => 'ponedeljek';

  @override
  String get calendarWeekdayTuesday => 'torek';

  @override
  String get calendarWeekdayWednesday => 'sreda';

  @override
  String get calendarWeekdayThursday => 'četrtek';

  @override
  String get calendarWeekdayFriday => 'petek';

  @override
  String get calendarWeekdaySaturday => 'Sobota';

  @override
  String get calendarWeekdaySunday => 'Nedelja';

  @override
  String get outfitSavedToFavouritesBody => 'Shranjeno v priljubljene';

  @override
  String get outfitRemovedFromFavouritesBody => 'Odstranjeno iz priljubljenih';

  @override
  String get outfitNotSavedTitle => 'Ni shranjeno';

  @override
  String get outfitLoggedAsWornBody => 'Zabeleženo kot nosiš danes.';

  @override
  String get outfitNicePickTitle => 'Brezplačni izbor';

  @override
  String get outfitRemovedBody => 'Kostimodoba odstranjena.';

  @override
  String get outfitDeletedTitle => 'Izbrisano';

  @override
  String get outfitNotDeletedTitle => 'Ni izbrisano';

  @override
  String get outfitDuplicatedBody => 'Kopija je med vašimi kombinacijami.';

  @override
  String get outfitDuplicatedTitle => 'Pomnoženo';

  @override
  String get outfitNotDuplicatedTitle => 'Ni pomnoženo';

  @override
  String get outfitNotSharedTitle => 'Ni deljeno';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" je pripravljen.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Kolekcija ni ustvarjena';

  @override
  String get outfitCollectionUpdatedBody => 'Kolekcija posodobljena.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Kolekcija ni posodobljena';

  @override
  String get outfitCollectionDeletedBody => 'Kolekcija izbrisana.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Kolekcija ni izbrisana';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kombinacij dodanih.',
      many: '$count kombinacij dodanih.',
      few: '$count kombinacije dodane.',
      two: '$count kombinaciji dodani.',
      one: '1 kombinacija dodana.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Kombinacije niso dodane';

  @override
  String get outfitPreviewNotCreatedTitle => 'Predogled ni ustvarjen';

  @override
  String get outfitGiveNameBody => 'Dajte kombinaciji ime.';

  @override
  String get outfitNameMissingTitle => 'Ime';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Izberite vsaj en kos.';

  @override
  String outfitCreatedBody(String name) {
    return '$name je med vaškimi kombinacijami.';
  }

  @override
  String get outfitSavedTitle => 'Shranjeno';

  @override
  String get wardrobeAddedToFavouritesBody => 'Dodano v priljubljene';

  @override
  String get wardrobeRemovedFromFavouritesBody =>
      'Odstranjeno iz priljubljenih';

  @override
  String get wardrobeNotSavedTitle => 'Ni shranjeno';

  @override
  String get wardrobeLoggedAsWornBody => 'Zabeleženo kot nošeno danes.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Odstranjeno iz vaše omare.';

  @override
  String get wardrobeDeletedTitle => 'Izbrisano';

  @override
  String get wardrobeNotDeletedTitle => 'Ni izbrisano';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# kosov odstranjenih iz vaše omare.',
      many: '# kosov odstranjenih iz vaše omare.',
      few: '# kosi odstranjeni iz vaše omare.',
      one: '1 kos odstranjen iz vaše omare.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI ekstrakcija omare';

  @override
  String get itemAddScanJobLabel => 'Skeniranje';

  @override
  String get itemAddFoundEarlierBody => 'Pridobljeno pri prejšnjem skeniranju';

  @override
  String get itemAddLookingAtPhoto => 'Pregled fotografije';

  @override
  String get itemAddExtractionFailedBody => 'Ekstrakcija ni uspela';

  @override
  String get itemAddJobFailedBody => 'Naloga ni uspela';

  @override
  String get itemAddConnectionLostBody =>
      'Povezava je prekinjena. Poskusite znova.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Povezava izgubljena med predelavo.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Kos $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Kos';

  @override
  String get itemAddNotCancelledTitle => 'Ni preklicano';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# kosov je v vaši omari.',
      many: '# kosov je v vaši omari.',
      few: '# kosi so v vaši omari.',
      one: '1 kos je v vaši omari.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'Shranjeno $saved od $total kosov. Tapnite za shranitev preostalih.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Nekateri kosovi niso shranjeni';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Izberite vsaj eno fotografijo.';

  @override
  String get batchPhotoUnreadableBody => 'Te fotografije ni mogoče prebrati.';

  @override
  String get batchNoPhotosReadableBody =>
      'Nobenih teh fotografij ni mogoče prebrati. Poskusite z drugimi.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# fotografij',
      many: '# fotografij',
      few: '# fotografije',
      one: '1 fotografija',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Med delom smo izgubili povezavo. Poskusite znova.';

  @override
  String get batchNotCancelledTitle => 'Ni preklicano';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Povezave objav niso podprte. Vnesite povezavo profila.';

  @override
  String get batchLinkSpacesBody => 'Povezave ne smejo vsebovati presledkov.';

  @override
  String get batchEnterProfileLinkBody =>
      'Vnesite povezavo profila Instagram ali Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Vnesite povezavo profila.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Stran za prijavo se ni odprla. Poskusite znova.';

  @override
  String get batchSignInBrowserBody =>
      'Prijavite se v brskalniku, nato se vrnite v FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Povežite svoj račun';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Vnesite kodo iz vaše aplikacije za avtentikacijo.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram zahteva varnostni postopek. Najprej se prijavite v brskalniku.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Vnesite uporabniško ime in geslo znova.';

  @override
  String get batchSignInFailedBody =>
      'Prijava ni uspela. Preverite uporabniško ime in geslo.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Prijavite se, da nadaljujete uvažanje.';

  @override
  String get batchAccountNotConnectedBody => 'Račun ni bil povezan.';

  @override
  String get batchAccountConnectedTitle => 'Račun je povezan';

  @override
  String get batchNotConnectedTitle => 'Ni povezano';

  @override
  String get batchImportConnectionLostBody =>
      'Izgubili smo povezavo z uvažanjem. Osvežite, da jo preverite.';

  @override
  String batchPickUpToBody(int max) {
    return 'Izberite do $max fotografij. Predmete poiščemo mi.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count od $total fotografij';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Pripravljam fotografijo $done od $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Išči predmete na $count fotografijah',
      one: 'Išči predmete na 1 fotografiji',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Vaš račun na $platform uporablja dvokoračno prijavo. Vnesite 6-mestno kodo iz aplikacije za avtentikacijo.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Ta profil na $platform je zaseben ali za prikaz fotografij zahteva prijavo.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Poveži s $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count naštenih fotografij',
      one: 'Najdena je 1 fotografija',
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
    return '$processed od $total obdelanih · $added dodanih · $waiting na čakanju · $skipped preskočenih';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Skeniram fotografijo $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Fotografija $number je naslednja';
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
      other: '$count najdenih predmetov',
      one: 'Najden je 1 predmet',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografij so bile dodane v vaš omara.',
      one: '1 fotografija je bila dodana v vaš omara.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count studio fotografij je na poti. Shranite kar je pripravljeno ali zapustite — obvestili vas bomo.',
      one:
          'Še 1 studio fotografija je na poti. Shranite kar je pripravljeno ali zapustite — obvestili vas bomo.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Še ni shranjeno: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces predmetov',
      one: '1 predmet',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotografij',
      one: '1 fotografije',
    );
    return '$_temp0 iz $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen izbranih. Dotaknite se predmeta, da ga preskočite.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Shranjujem $count kosov',
      many: 'Shranjujem $count kosov',
      few: 'Shranjujem $count kosi',
      one: 'Shranjujem 1 kos',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Shrani $count kosov',
      many: 'Shrani $count kosov',
      few: 'Shrani $count kosi',
      one: 'Shrani 1 kos',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Vaš profil telesa je shranjen.';

  @override
  String get bodyProfileSavedTitle => 'Shranjeno';

  @override
  String get bodyProfileNotSavedTitle => 'Ni shranjeno';

  @override
  String get bodyProfileSetDefaultBody => 'Nastavite kot privzeti profil.';

  @override
  String get bodyProfileDeletedBody => 'Profil telesa je izbrisan.';

  @override
  String get bodyProfileDeletedTitle => 'Izbrisano';

  @override
  String get bodyProfileNotDeletedTitle => 'Ni izbrisano';

  @override
  String get feedbackNotSentTitle => 'Ni poslano';

  @override
  String get feedbackSentBody =>
      'Hvala. Preberemo vsako sporočilo in odgovorimo, če potrebujemo več podrobnosti.';

  @override
  String get feedbackSentTitle => 'Povratna informacija poslana';

  @override
  String get recommendUnnamedPiece => 'Imenovan kos';

  @override
  String get recommendEnterCityBody =>
      'Vnesite svoje mesto, da dobite predloge za vreme.';

  @override
  String get recommendWhichCityTitle => 'Katero mesto?';

  @override
  String get aiConsentSheetTitle => 'Deljenje fotografij z AI storitvijo';

  @override
  String get aiConsentSheetBody =>
      'Za ustvarjanje poskusnih oblačil in fotografij s posnetki FitCheck AI pošlje fotografije, ki jih predložite (vključno s fotografijami vašega obraza in telesa), zanesljivemu zunanji AI ponudniku (npr. OpenAI ali Google Gemini) za obdelavo. Ti ustvarijo vaše slike in jih v okviru naših pogojev ne uporabijo za usposabljanje svojih modelov. Fotografije se pošiljajo varno in se nikoli ne delijo za oglasovanje.';

  @override
  String get aiConsentSheetPermission =>
      'S nadaljevanjem izrecno dovolite deljenje svojih fotografij s temi AI ponudniki za generiranje slik.';

  @override
  String get skeletonsLoadMoreFailed => 'Nisem mogel naložiti več.';

  @override
  String get jobsPiecesReadyTitle => 'Vaši kosi so pripravljeni';

  @override
  String get jobsScanStoppedTitle => 'Snemanje se je ustavilo';

  @override
  String get jobsNothingSavedBody => 'Nič ni bilo shranjeno. Poskusite znova.';

  @override
  String get jobsPhotoUploadFailedBody => 'Nalaganje fotografije ni uspelo.';

  @override
  String get authGoogleSignInStartFailed =>
      'Ni bilo mogoče začeti prijave z Google. Poskusite znova.';

  @override
  String get referralAppliedTitle => 'Priporočilo upoštevano!';

  @override
  String get billingStoreUnavailableBody =>
      'Nakupi v trgovini na tem napravah niso na voljo.';

  @override
  String get billingPurchaseProcessingBody =>
      'Ta nakup se še obdeluje. Ponovno odprite aplikacijo po minutni da vidite svoj načrt.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Nalaganje avatarja ni vrnilo URL slike.';

  @override
  String get rewardsDayStreakLabel => 'dnevna serija';

  @override
  String rewardsBestStreak(int days) {
    return 'Najboljših $days dni';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Zahtevan dostop do $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Dostop do $permission je trenutno zavrnjen. Odpri Nastavitve, da ga omogočiš, nato se vrni in poskusi znova.';
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
    return 'Odstrani sliko $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Odstrani sliko $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points točk';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Pošlji e-pošto na $email. Poročila pregledujemo v 24 urah.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Odstrani $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Izbrišem \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Dodaj v \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '»$name« je odstranjena. Njeni predmeti ostanejo v tvojem omari.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Pokaži vse $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Danes je še $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Slika $index ni uspela';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected od $max fotografij';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Oblika: $shape · Ten: $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Izbrišem $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Možnosti za $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Največ nošen: $name, $count krat';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: ni nastavljeno';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'Ustreznost $percent %';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'Izbranih $picked od $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Odstrani $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prednost: $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Ta tarifni načrt se obračunava prek $store. Spremenite ga ali prekličite v nastavitvah svojega računa $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Upravljanje v $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: uporabljenih $current od $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Še približno $seconds s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return 'Pripravljenih $done od $total studio fotografij';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready od $total studijskih fotografij je pripravljenih. Dotaknite se kosov, ki jih želite preskočiti.';
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
