// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Hjem';

  @override
  String get tabPhotoshoot => 'Photoshoot';

  @override
  String get tabCloset => 'Garderobe';

  @override
  String get tabOutfits => 'Sæt';

  @override
  String get tabMore => 'Mere';

  @override
  String get actionAddItem => 'Tilføj del';

  @override
  String get actionCreateOutfit => 'Opret sæt';

  @override
  String get actionCancel => 'Annuller';

  @override
  String get actionDelete => 'Slet';

  @override
  String get actionSave => 'Gem';

  @override
  String get actionRetry => 'Prøv igen';

  @override
  String get actionDone => 'Færdig';

  @override
  String get actionNext => 'Næste';

  @override
  String get actionBack => 'Tilbage';

  @override
  String get actionClose => 'Luk';

  @override
  String get actionSearch => 'Søg';

  @override
  String get actionContinue => 'Fortsæt';

  @override
  String get stateLoading => 'Indlæser';

  @override
  String get stateErrorTitle => 'Noget gik galt';

  @override
  String get stateErrorBody =>
      'Prøv igen. Kontakt support, hvis problemet fortsætter.';

  @override
  String get stateOfflineTitle => 'Du er offline';

  @override
  String get stateOfflineBody =>
      'Opret forbindelse for at synkronisere garderobe og generere sæt.';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsPreferencesSection => 'Præferencer';

  @override
  String get settingsPlanBilling => 'Abonnement og betaling';

  @override
  String get settingsLanguage => 'Sprog';

  @override
  String get settingsNotifications => 'Notifikationer';

  @override
  String get settingsUnits => 'Måleenheder';

  @override
  String get settingsAppearance => 'Udseende';

  @override
  String get settingsPrivacySection => 'Sikkerhed og data';

  @override
  String get settingsAboutSection => 'Om';

  @override
  String get settingsSignOut => 'Log ud';

  @override
  String get settingsDeleteAccount => 'Slet konto';

  @override
  String get settingsDeleteAccountTitle => 'Vil du slette din konto?';

  @override
  String get settingsDeleteAccountBody =>
      'Dette sletter din garderobe, sæt, fotos og profil. Handlingen kan ikke foergydes.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrisk (cm, kg)';

  @override
  String get languageTitle => 'Sprog';

  @override
  String get languageSystem => 'Brug enhedens sprog';

  @override
  String get languageSystemBody => 'FitCheck AI følger din telefons sprog.';

  @override
  String get languageSearchHint => 'Søg efter sprog';

  @override
  String get languageCurrent => 'Aktuelt';

  @override
  String get languageReviewNote =>
      'Denne oversættelse er ny. Fortæl os, hvis noget lyder forkert.';

  @override
  String get languageChanged => 'Sprog opdateret';

  @override
  String get paywallTitle => 'Vælg dit abonnement';

  @override
  String get paywallTrialBadge => '1 måned gratis';

  @override
  String get paywallTrialTitle => 'Din første måned med Pro er gratis';

  @override
  String get paywallTrialBody =>
      'Upload hele din garderobe på en gang. Tilføj tøj undervejs derefter.';

  @override
  String get paywallFreeForeverTitle => 'Gratis for altid';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Intet kort påkrævet. Hver måned får du $uploads AI-uploads, $outfits outfits og $images fotoshoot-billeder om dagen.';
  }

  @override
  String get paywallCtaTrial => 'Start min gratis måned';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Opgrader til $plan';
  }

  @override
  String get paywallRestore => 'Gendan køb';

  @override
  String get paywallManage => 'Administrer abonnement';

  @override
  String get paywallTerms => 'Vilkår for brug';

  @override
  String get paywallPrivacy => 'Privatlivspolitik';

  @override
  String get paywallPerMonth => 'om måneden';

  @override
  String get paywallPerYear => 'om året';

  @override
  String get paywallBestValue => 'Bedste værdi';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Gratis prøveperiode kun for nye abonnenter. Efter prøveperioden fornyes Pro til $price, medmindre den opsiges mindst 24 timer før udløb.';
  }

  @override
  String get introTitle => 'Din garderobe, endelig organiseret';

  @override
  String get introBody =>
      'Fotografér dit tøj en gang. Få outfit-idéer, prøve-forhåndsvisninger og studiebilleder af det, du allerede ejer.';

  @override
  String get introStart => 'Kom i gang';

  @override
  String get introHaveAccount => 'Jeg har allerede en konto';

  @override
  String get introSkip => 'Spring over';

  @override
  String get authSignIn => 'Log ind';

  @override
  String get authSignUp => 'Opret konto';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Adgangskode';

  @override
  String get authForgotPassword => 'Glemt adgangskode?';

  @override
  String get authContinueApple => 'Fortsæt med Apple';

  @override
  String get authContinueGoogle => 'Fortsæt med Google';

  @override
  String get authOrDivider => 'eller';

  @override
  String get wardrobeTitle => 'Garderobe';

  @override
  String get wardrobeEmptyTitle => 'Din garderobe er tom';

  @override
  String get wardrobeEmptyBody =>
      'Tilføj dit første stykke tøj, eller upload et foto af hele tøjstativet på en gang.';

  @override
  String get wardrobeAddFirst => 'Tilføj dit første element';

  @override
  String get wardrobeSearchHint => 'Søg i din garderobe';

  @override
  String get categoryTops => 'Overdele';

  @override
  String get categoryBottoms => 'Underdele';

  @override
  String get categoryShoes => 'Sko';

  @override
  String get categoryAccessories => 'Tilbehør';

  @override
  String get categoryOuterwear => 'Ydertøj';

  @override
  String get categorySwimwear => 'Badetøj';

  @override
  String get categoryActivewear => 'Sportstøj';

  @override
  String get categoryOther => 'Andet';

  @override
  String get conditionClean => 'Ren';

  @override
  String get conditionDirty => 'Brugt';

  @override
  String get conditionLaundry => 'Til vask';

  @override
  String get conditionRepair => 'Skal repareres';

  @override
  String get conditionDonate => 'Til donation';

  @override
  String get seasonSpring => 'Forår';

  @override
  String get seasonSummer => 'Sommer';

  @override
  String get seasonFall => 'Efterår';

  @override
  String get seasonWinter => 'Vinter';

  @override
  String get seasonAll => 'Hele året';

  @override
  String get styleCasual => 'Afslappet';

  @override
  String get styleFormal => 'Formel';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sporty';

  @override
  String get styleBohemian => 'Boheme';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistisk';

  @override
  String get styleRomantic => 'Romantisk';

  @override
  String get styleEdgy => 'Råt';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Kunstnerisk';

  @override
  String get styleClassic => 'Klassisk';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Andet';

  @override
  String get occasionWork => 'Arbejde';

  @override
  String get occasionDateNight => 'Date aften';

  @override
  String get occasionTravel => 'Rejse';

  @override
  String get occasionWedding => 'Bryllup';

  @override
  String get occasionGym => 'Træning';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Fest';

  @override
  String get occasionInterview => 'Jobinterview';

  @override
  String get colorBlack => 'Sort';

  @override
  String get colorWhite => 'Hvid';

  @override
  String get colorGrey => 'Grå';

  @override
  String get colorNavy => 'Marineblå';

  @override
  String get colorBrown => 'Brun';

  @override
  String get colorRed => 'Rød';

  @override
  String get colorBlue => 'Blå';

  @override
  String get colorGreen => 'Grøn';

  @override
  String get colorPink => 'Lyserød';

  @override
  String get colorPurple => 'Lilla';

  @override
  String get colorYellow => 'Gul';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'I dag';

  @override
  String get dateYesterday => 'I går';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'For $count dage siden',
      one: 'For 1 dag siden',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'For $count uger siden',
      one: 'For 1 uge siden',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'For $count måneder siden',
      one: 'For 1 måned siden',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'For $count år siden',
      one: 'For 1 år siden',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Glad for FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'En hurtig bedømmelse hjælper andre med at finde deres stil.';

  @override
  String get ratingPromptYes => 'Bedøm appen';

  @override
  String get ratingPromptNo => 'Ikke nu';

  @override
  String get closetNoMatchesTitle => 'Ingen matchende dele';

  @override
  String get closetNoMatchesBody => 'Prøv færre filtre eller en anden søgning.';

  @override
  String get closetClearFilters => 'Ryd filtre';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dele',
      one: '1 del',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Indlæser dine dele';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valgte',
      one: '1 valgt',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Slet valgte';

  @override
  String get closetCancelSelection => 'Annuller valg';

  @override
  String get closetCloseSearch => 'Luk søgning';

  @override
  String get closetShowGrid => 'Vis som gitter';

  @override
  String get closetShowList => 'Vis som liste';

  @override
  String get closetShowRows => 'Vis som rækker';

  @override
  String get closetStatsTitle => 'Garderobestatistik';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slet $count dele?',
      one: 'Slet 1 del?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Outfits, der bruger dem, mister disse dele.';

  @override
  String get closetSortBy => 'Sorter efter';

  @override
  String get closetFavourites => 'Favoritter';

  @override
  String get closetFavourite => 'Favorit';

  @override
  String get closetUnfavourite => 'Fjern favorit';

  @override
  String get closetWoreToday => 'Brugt i dag';

  @override
  String closetWornTimes(int count) {
    return 'Brugt $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategori';

  @override
  String get closetUseCaseLabel => 'Anvendelse';

  @override
  String get closetAnyUseCase => 'Alle';

  @override
  String get closetOtherUseCase => 'Anden anvendelse';

  @override
  String get closetOtherUseCaseHint => 'F.eks. brunch';

  @override
  String get closetUseUseCase => 'Brug denne';

  @override
  String get closetClearAll => 'Ryd alle';

  @override
  String get sortNewest => 'Nyeste først';

  @override
  String get sortOldest => 'Ældste først';

  @override
  String get sortName => 'Navn (A–Z)';

  @override
  String get sortMostWorn => 'Mest brugt';

  @override
  String get useCaseInformal => 'Uformel';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Middag';

  @override
  String get useCaseLunch => 'Frokost';

  @override
  String get actionSelect => 'Vælg';

  @override
  String get actionEdit => 'Rediger';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sorter';

  @override
  String get actionAll => 'Alle';

  @override
  String get dashboardStartClosetTitle => 'Start din garderobe';

  @override
  String get dashboardStartClosetBody =>
      'Fotografer et par dele. Vi tagger dem for dig.';

  @override
  String get dashboardPieces => 'dele';

  @override
  String get dashboardOutfits => 'outfits';

  @override
  String get dashboardDayStreak => 'dages stime';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count denne måned';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Bedste $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritter',
      one: '1 favorit',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemte outfits',
      one: '1 gemt outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Mest brugt: $name, $count gange';
  }

  @override
  String get setupSkip => 'Spring over';

  @override
  String get setupWhoTitle => 'Hvem styler vi?';

  @override
  String get setupWhoBody =>
      'Vælger modellen til prøvning og fotoshoots. Du kan ændre det i din profil.';

  @override
  String get setupStyleTitle => 'Hvad går du mest i?';

  @override
  String get setupStyleBody =>
      'Vælg frit. Outfit-ideer tager udgangspunkt i disse.';

  @override
  String get setupClosetTitle => 'Tilføj dine første stykker tøj.';

  @override
  String get setupClosetBody =>
      'Fotografer et stykke tøj eller enbunke. Hvert stykke tøj udskæres og gemmes for dig.';

  @override
  String get setupAddClothes => 'Tilføj tøj';

  @override
  String get setupStylesLabel => 'Stilarter';

  @override
  String get setupOccasionsLabel => 'Anledninger';

  @override
  String get setupSkipStep => 'Spring over';

  @override
  String get setupLater => 'Senere';

  @override
  String get setupSaveError => 'Kunne ikke gemme';

  @override
  String get genderWomen => 'Kvinder';

  @override
  String get genderMen => 'Mænd';

  @override
  String get genderNonBinary => 'Ikke-binær';

  @override
  String get genderPreferNotToSay => 'Vil ikke oplyse';

  @override
  String get outfitEmptyTitle => 'Ingen outfits endnu';

  @override
  String get outfitEmptyBody => 'Sæt tøj sammen fra dit skab og gem looket.';

  @override
  String get outfitNoMatchesTitle => 'Ingen outfits matcher';

  @override
  String get outfitSearchHint => 'Søg i dine outfits';

  @override
  String get outfitLoading => 'Indlæser dine outfits';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Stil og sæson';

  @override
  String get outfitCollections => 'Kollektioner';

  @override
  String get outfitDuplicate => 'Duplikér';

  @override
  String get outfitDeleteTitle => 'Slet dette outfit?';

  @override
  String get outfitDeleteBody => 'Tøjet bliver i dit skab.';

  @override
  String get outfitDrafts => 'Kladder';

  @override
  String get outfitDraft => 'Kladde';

  @override
  String get filterStyle => 'Stil';

  @override
  String get filterSeason => 'Sæson';

  @override
  String get itemDetailDeleteTitle => 'Slet dette stykke tøj?';

  @override
  String get itemDetailDeleteBody =>
      'Outfits, der bruger det, mister dette stykke tøj.';

  @override
  String get itemAddFavourite => 'Tilføj til favoritter';

  @override
  String itemSize(String size) {
    return 'Størrelse $size';
  }

  @override
  String get itemColours => 'Farver';

  @override
  String get itemMaterial => 'Materiale';

  @override
  String get itemPattern => 'Mønster';

  @override
  String get itemUseCases => 'Anvendelse';

  @override
  String get itemKeptIn => 'Opbevaret i';

  @override
  String get itemPrice => 'Pris';

  @override
  String get itemBought => 'Købt';

  @override
  String get itemTags => 'Tags';

  @override
  String get itemAdded => 'Tilføjet';

  @override
  String get itemTimesWornLabel => 'gange brugt';

  @override
  String get itemLastWornLabel => 'sidst brugt';

  @override
  String get itemNeverWorn => 'Aldrig';

  @override
  String get authEntryBody =>
      'Hvert eneste stykke tøj, du ejer, stilet af FitCheck AI. Planlæg outfits, prøv dem på, skyd dem.';

  @override
  String get authCreateCloset => 'Opret din garderobe';

  @override
  String get authWelcomeBack => 'Velkommen tilbage';

  @override
  String get authSignInBody => 'Log ind for at åbne din garderobe.';

  @override
  String get authCreateAccount => 'Opret en konto';

  @override
  String get authCreateClosetBody =>
      'Det tager et minut. Dine første ting er gratis.';

  @override
  String get authName => 'Navn';

  @override
  String get authConfirmPassword => 'Bekræft adgangskode';

  @override
  String get authReferralCode => 'Henvisningskode (valgfri)';

  @override
  String get authResetTitle => 'Nulstil din adgangskode';

  @override
  String get authResetBody => 'Vi sender dig et link til at vælge en ny.';

  @override
  String get authSendResetLink => 'Send nulstillingslink';

  @override
  String get authBackToSignIn => 'Tilbage til login';

  @override
  String get authEnterEmail => 'Indtast din e-mail';

  @override
  String get authEnterValidEmail => 'Indtast en gyldig e-mail';

  @override
  String get authEnterPassword => 'Indtast din adgangskode';

  @override
  String get authPasswordTooShort => 'Mindst 6 tegn';

  @override
  String get authShowPassword => 'Vis adgangskode';

  @override
  String get authHidePassword => 'Skjul adgangskode';

  @override
  String get authNewHere => 'Ny her?';

  @override
  String authConfirmEmail(String email) {
    return 'Bekræft $email, før du logger ind. Tjek din indbakke.';
  }

  @override
  String get authResendEmail => 'Send igen';

  @override
  String get authResendingEmail => 'Sender…';

  @override
  String get authPasswordsDoNotMatch => 'Adgangskoderne ens';

  @override
  String get authEnterName => 'Indtast dit navn';

  @override
  String get authChoosePassword => 'Vælg en adgangskode';

  @override
  String get authHaveAccount => 'Har du en konto?';

  @override
  String get authCodeAccepted => 'Kode accepteret';

  @override
  String get authCodeNotFound => 'Kode ikke fundet';

  @override
  String authReferralFrom(String name) {
    return 'Fra $name. I får begge en måned gratis.';
  }

  @override
  String get authReferralInvalid => 'Vi kunne ikke finde denne kode.';

  @override
  String authResetSent(String email) {
    return 'Sendt til $email. Åbn linket på denne telefon.';
  }

  @override
  String get introSlide1Title => 'Fotografer din garderobe én gang.';

  @override
  String get introSlide1Body =>
      'Fotografer en bunke tøj. Hvert stykke tøj fritlægges og gemmes for dig.';

  @override
  String get introSlide2Title => 'Bliv hurtigere klar.';

  @override
  String get introSlide2Body =>
      'Outfits fra det, du ejer, matchet til dine planer og vejret.';

  @override
  String get introSlide3Title => 'Se det, før du tager det på.';

  @override
  String get introSlide3Body =>
      'Prøv tøj på dit eget foto, eller skyd dem som en kampagne.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Lyst';

  @override
  String get settingsThemeDark => 'Mørkt';

  @override
  String get settingsTemperature => 'Temperatur';

  @override
  String get settingsEmailUpdates => 'E-mailopdateringer';

  @override
  String get settingsEmailUpdatesBody => 'Nyheder og tips via e-mail';

  @override
  String get settingsOutfitReminders => 'Outfit-påmindelser';

  @override
  String get settingsOutfitRemindersBody =>
      'Et pub til at logge det, du havde på';

  @override
  String get settingsWeeklySummary => 'Ugentlig oversigt';

  @override
  String get settingsWeeklySummaryBody => 'Din uge i outfits';

  @override
  String get settingsStyleSection => 'Stil';

  @override
  String get settingsPreferredStyles => 'Stilarter du kan lide';

  @override
  String get settingsPreferredColours => 'Farver du kan lide';

  @override
  String get settingsNoneChosen => 'Ingen valgt';

  @override
  String get settingsPlanAiSection => 'Abonnement og AI';

  @override
  String get settingsPlanBillingBody => 'Abonnement, forbrug og opgraderinger';

  @override
  String get settingsPlanUsageBody => 'Abonnement og forbrug';

  @override
  String get settingsInviteFriends => 'Inviter venner';

  @override
  String get settingsInviteFriendsBody =>
      'En gratis måned for hver ven, der tilmelder sig';

  @override
  String get settingsAiProvider => 'AI-udbyder';

  @override
  String get settingsAiProviderBody =>
      'Brug din egen model til tags og billeder';

  @override
  String get settingsAppVersion => 'App-version';

  @override
  String get settingsPrivacyTerms => 'Privlivspolitik og vilkår';

  @override
  String get settingsReportProblem => 'Rapporter et problem';

  @override
  String get settingsChangePassword => 'Skift adgangskode';

  @override
  String get settingsExportData => 'Eksporter dine data';

  @override
  String get settingsExportBody =>
      'Vi forbereder en fil med alt, du har gemt, og åbner download.';

  @override
  String get settingsExportAction => 'Eksporter';

  @override
  String get settingsCurrentPassword => 'Nuværende adgangskode';

  @override
  String get settingsNewPassword => 'Ny adgangskode';

  @override
  String get settingsConfirmNewPassword => 'Bekræft ny adgangskode';

  @override
  String get settingsEnterCurrentPassword =>
      'Indtast din nuværende adgangskode';

  @override
  String get settingsEnterNewPassword => 'Indtast en ny adgangskode';

  @override
  String get settingsPasswordMin8 => 'Brug mindst 8 tegn';

  @override
  String get settingsPasswordNeedsUpper => 'Tilføj et stort bogstav';

  @override
  String get settingsPasswordNeedsLower => 'Tilføj et lille bogstav';

  @override
  String get settingsPasswordNeedsDigit => 'Tilføj et tal';

  @override
  String get settingsPasswordsNoMatch => 'Adgangskoderne enser ikke';

  @override
  String get settingsChangeAction => 'Skift';

  @override
  String get itemAddSnapTitle => 'Tag et billede';

  @override
  String get itemAddSnapBody =>
      'Vi finder hvert enkelt stykke tøj på billedet og laver et rent studiebillede af det.';

  @override
  String get itemAddCamera => 'Tag et billede';

  @override
  String get itemAddGallery => 'Vælg fra galleri';

  @override
  String get itemAddOtherWays => 'Andre måder at tilføje på';

  @override
  String get itemAddSeveral => 'Tilføj flere billeder';

  @override
  String get itemAddSeveralBody => 'Op til 50 på en gang';

  @override
  String get itemAddImportProfile => 'Importer fra en profil';

  @override
  String get itemAddImportProfileBody => 'Instagram eller Facebook';

  @override
  String get itemAddEnterDetails => 'Indtast detaljer selv';

  @override
  String get itemAddEnterDetailsBody => 'Intet billede nødvendigt';

  @override
  String get itemManualIntro =>
      'Kun et navn er nødvendigt. Tilføj resten nu eller senere.';

  @override
  String get itemManualNameHint => 'F.eks. blå bomulds-t-shirt';

  @override
  String get itemManualEnterName => 'Indtast et navn';

  @override
  String get itemManualNotes => 'Noter';

  @override
  String get itemManualBrand => 'Mærke';

  @override
  String get itemManualSize => 'Størrelse';

  @override
  String get itemManualEnterNumber => 'Indtast et nummer';

  @override
  String get itemManualSavePiece => 'Gem del';

  @override
  String get itemManualSaving => 'Gemmer';

  @override
  String get itemManualSavedTitle => 'Gemt';

  @override
  String itemManualSavedBody(String name) {
    return '$name er i dit skab.';
  }

  @override
  String get itemManualNotSaved => 'Ikke gemt';

  @override
  String get itemManualAddUseCase => 'Tilføj anvendelse';

  @override
  String get itemManualAddUseCaseAction => 'Tilføj anvendelse';

  @override
  String get itemPhotos => 'Billeder';

  @override
  String get itemAddPhotos => 'Tilføj billeder';

  @override
  String get itemNoPhotoYet => 'Intet billede endnu. Du kan gemme uden.';

  @override
  String get itemRemovePhoto => 'Fjern billede';

  @override
  String get itemRemovePiece => 'Fjern del';

  @override
  String get filterConditionLabel => 'Stand';

  @override
  String get photoshootStepPhotos => 'Billeder';

  @override
  String get photoshootStepSetup => 'Opsætning';

  @override
  String get photoshootStepCreating => 'Opretter';

  @override
  String get photoshootStepResults => 'Resultater';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Trin $current af $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Et billede fejlede. Prøv igen herunder.';

  @override
  String photoshootManyFailed(int count) {
    return '$count billeder fejlede. Prøv igen for hvert enkelt herunder.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Hvor mange';

  @override
  String get photoshootYourPrompt => 'Din prompt';

  @override
  String get photoshootPromptHint => 'Gylden time på et tag, hørskjorte';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Opret $count fotos',
      one: 'Opret 1 foto',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotos',
      one: 'foto',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Vi kunne ikke tjekke dagens grænse.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan-plan: $remaining af $limit tilbage i dag';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratis';

  @override
  String get photoshootGallery => 'Galleri';

  @override
  String get photoshootUseCamera => 'Brug kamera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Fjern foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Ingen fotos modtaget';

  @override
  String get photoshootNoPhotosBody =>
      'Optagelsen afsluttedes uden billeder. Prøv igen.';

  @override
  String get photoshootNewStyle => 'Ny stil';

  @override
  String get photoshootNewPhotos => 'Nye fotos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Åbn foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Rapporter foto';

  @override
  String get photoshootSaveToGallery => 'Gem i galleri';

  @override
  String get actionUpgrade => 'Opgrader';

  @override
  String get referralLimitTitle => 'Du har brugt dagens fotos';

  @override
  String get referralLimitBody =>
      'Dine gratis fotos kommer tilbage i morgen. Henvis en ven, og I får begge en måned med Pro gratis.';

  @override
  String get referralLimitRefer => 'Henvis en ven';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating-app';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Æstetisk';

  @override
  String get photoshootUseCustom => 'Din egen prompt';

  @override
  String get photoshootDescLinkedin => 'Skarpe portrætter til arbejde';

  @override
  String get photoshootDescDating => 'Afslappet, varmt og naturligt';

  @override
  String get photoshootDescPortfolio => 'Redaktionelle high-fashion-looks';

  @override
  String get photoshootDescInstagram => 'Livsstilsbilleder til dit feed';

  @override
  String get photoshootDescAesthetic => 'Stemningsfulde, kunstneriske rammer';

  @override
  String get photoshootDescCustom => 'Beskriv det look du ønsker';

  @override
  String get aspectSquare => 'Kvadratisk';

  @override
  String get aspectPortrait => 'Portræt';

  @override
  String get aspectLandscape => 'Landskab';

  @override
  String get aspectTall => 'Høj';

  @override
  String get aspectWide => 'Bred';

  @override
  String get tryOnAppBar => 'Virtuel prøvning';

  @override
  String get tryOnYourPhoto => 'Dit foto';

  @override
  String get tryOnGarment => 'Tøjstykke';

  @override
  String get tryOnUploadingPhoto => 'Uploader dit foto';

  @override
  String get tryOnAddPhotoPrompt => 'Tilføj et helkropsbillede af dig selv';

  @override
  String get tryOnBodyPhotoHint => 'Et helkropsbillede fungerer bedst';

  @override
  String get tryOnAddPhoto => 'Tilføj foto';

  @override
  String get tryOnChangePhoto => 'Skift foto';

  @override
  String get tryOnPhotoLoadFailed => 'Vi kunne ikke indlæse dit foto.';

  @override
  String get tryOnChooseGarment => 'Vælg et tøjfoto';

  @override
  String get tryOnChooseOneGarment => 'Vælg et tøjfoto';

  @override
  String get tryOnGarmentHint =>
      'Et fladt layout eller bøjleskud fungerer bedst';

  @override
  String get tryOnChange => 'Skift';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Fjern';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Stil';

  @override
  String get tryOnBackground => 'Baggrund';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Klæder dig på. Dette tager ca. et halvt minut.';

  @override
  String get tryOnEmptyResult => 'Din prøvning vises her';

  @override
  String get tryOnReportImage => 'Rapporter billede';

  @override
  String get tryOnCreating => 'Opretter';

  @override
  String get tryOnTryAgain => 'Prøv igen';

  @override
  String get tryOnCreate => 'Opret prøvning';

  @override
  String get tryOnBackgroundStudioWhite => 'Studiéhvid';

  @override
  String get tryOnBackgroundStudioGrey => 'Studiégrå';

  @override
  String get tryOnBackgroundUrban => 'Storby';

  @override
  String get tryOnBackgroundNature => 'Natur';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Stående forfra';

  @override
  String get tryOnPoseSide => 'Stående fra siden';

  @override
  String get tryOnPoseWalking => 'Gående';

  @override
  String get dashboardGreetingMorning => 'Godmorgen';

  @override
  String get dashboardGreetingAfternoon => 'Goddag';

  @override
  String get dashboardGreetingEvening => 'Godeften';

  @override
  String get dashboardWelcome => 'Velkommen';

  @override
  String get dashboardOpenProfile => 'Åbn profil';

  @override
  String get dashboardRailToday => 'I dag';

  @override
  String get dashboardRailRecently => 'Seneste';

  @override
  String get dashboardActivityEmpty => 'Nye dele og outfits vises her.';

  @override
  String get quickAddPiece => 'Tilføj del';

  @override
  String get quickAddPieceBody => 'Fotografer og tag';

  @override
  String get quickBuildOutfit => 'Byg et outfit';

  @override
  String get quickBuildOutfitBody => 'Kombiner dine dele';

  @override
  String get quickForYou => 'Til dig';

  @override
  String get quickForYouBody => 'Valg til i dag';

  @override
  String get quickPlanWeek => 'Planlæg ugen';

  @override
  String get quickPlanWeekBody => 'Outfits efter dato';

  @override
  String get referralBannerUrgent => 'Ved at løbe tør? Inviter en ven.';

  @override
  String get referralBannerTitle => 'Giv en måned, få en måned.';

  @override
  String get referralBannerBody => 'Du og din ven får hver en måned med Pro.';

  @override
  String get referralBannerDismiss => 'Skjul i en uge';

  @override
  String get referralBannerShare => 'Del invitation';

  @override
  String get referralBannerCopy => 'Kopier link';

  @override
  String get itemEditPieceTitle => 'Rediger del';

  @override
  String get itemEditDescriptionLabel => 'Beskrivelse';

  @override
  String get itemEditNotSaved => 'Ikke gemt';

  @override
  String get itemEditSavedTitle => 'Gemt';

  @override
  String get itemEditSavedBody => 'Dine ændringer er gemt.';

  @override
  String get itemEditSavedStalePhotos => 'Gemt – fotos er muligvis forældede';

  @override
  String get itemEditRemovePieceHint => 'Slet denne del fra varens side.';

  @override
  String get itemEditNoPhotos =>
      'Ingen fotos endnu. Tilføj et fra dit galleri eller kamera.';

  @override
  String get itemEditKeepPhoto => 'Behold foto';

  @override
  String get itemEditRemoved => 'Fjernet';

  @override
  String get itemEditAddUseCaseAction => 'Tilføj';

  @override
  String get statsNoStatsTitle => 'Ingen statistik endnu';

  @override
  String get statsNoStatsBody =>
      'Tilføj et par dele, og din garderobefordeling vises her.';

  @override
  String get statsByCategory => 'Efter kategori';

  @override
  String get statsTotalValue => 'samlet værdi';

  @override
  String get statsMostWorn => 'Brugt mest';

  @override
  String get statsLeastWorn => 'Venter på tur';

  @override
  String get statsUnnamedPiece => 'Unavngivet del';

  @override
  String get jobsTitle => 'Scanninger';

  @override
  String get jobsEmptyTitle => 'Ingen scanninger endnu';

  @override
  String get jobsEmptyBody =>
      'Tag et foto af en del, og send den til baggrunden – den arbejder videre her.';

  @override
  String get jobsNotCancelled => 'Ikke annulleret';

  @override
  String get jobsResume => 'Genoptag';

  @override
  String get jobsReview => 'Gennemse';

  @override
  String get jobsStop => 'Stop';

  @override
  String get jobsDismiss => 'Afvis';

  @override
  String get reportTitle => 'Anmeld indhold';

  @override
  String reportIntro(String contentType) {
    return 'Fortæl os, hvad der er galt med dette $contentType. Vores team gennemgår alle anmeldelser.';
  }

  @override
  String get reportReasonInappropriate => 'Upassende eller stødende';

  @override
  String get reportReasonNudity => 'Nøgenhed eller seksuelt indhold';

  @override
  String get reportReasonHarassment => 'Chikane eller misbrug';

  @override
  String get reportReasonImpersonation => 'Identitetstyveri';

  @override
  String get reportReasonOther => 'Andet';

  @override
  String get reportDetailsLabel => 'Yderligere detaljer (valgfrit)';

  @override
  String get reportSubmit => 'Send anmeldelse';

  @override
  String get reportSubmittedTitle => 'Anmeldelse sendt';

  @override
  String get reportSubmittedBody =>
      'Tak. Vores team vil gennemgå dette indhold.';

  @override
  String get reportFailedTitle => 'Kunne ikke sende anmeldelse';

  @override
  String get reportFailedBody => 'Prøv venligst igen.';

  @override
  String get reportContentTryOnImage => 'AI-prøverumsbillede';

  @override
  String get reportContentSharedOutfit => 'delt outfit';

  @override
  String get reportContentPhotoshootImage => 'AI-fotoshootbillede';

  @override
  String get sharedOutfitTitle => 'Delt outfit';

  @override
  String get sharedOutfitHideTooltip => 'Skjul dette outfit';

  @override
  String get sharedOutfitReportTooltip => 'Anmeld dette outfit';

  @override
  String get sharedOutfitHideTitle => 'Skjul dette outfit?';

  @override
  String get sharedOutfitHideBody =>
      'Det forbliver skjult på denne enhed. Du kan også anmelde det, så vores team kan gennemgå og fjerne det.';

  @override
  String get sharedOutfitHideAction => 'Skjul';

  @override
  String get sharedOutfitHiddenInfo =>
      'Dette outfit vises ikke igen på denne enhed.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit skjult';

  @override
  String get sharedOutfitMissingTitle => 'Dette outfit findes ikke længere';

  @override
  String get sharedOutfitMissingBody =>
      'Det kan være blevet fjernet, eller linket er forkert.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Du har skjult dette outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Hvis det var upassende, kan du anmelde det under Privatliv og vilkår eller sende en mail til $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Kan du lide stilen?';

  @override
  String get sharedOutfitCtaBody =>
      'Sammensæt outfits som dette fra din egen garderobe.';

  @override
  String get sharedOutfitCtaButton => 'Hent FitCheck AI';

  @override
  String get errorTitle => 'Fejl';

  @override
  String get errorUnknown => 'Der opstod en uventet fejl';

  @override
  String get errorNoConnection =>
      'Ingen internetforbindelse. Tjek dit netværk.';

  @override
  String get errorTimeout => 'Anmodningen fik timeout. Prøv igen.';

  @override
  String get errorServerError => 'Noget gik galt hos os. Prøv igen.';

  @override
  String get errorBadGateway =>
      'Vores server er midlertidigt utilgængelig. Prøv igen.';

  @override
  String get errorServiceUnavailable =>
      'Tjenesten er midlertidigt utilgængelig. Prøv igen om lidt.';

  @override
  String get errorInternalError => 'Noget gik galt. Prøv igen.';

  @override
  String get errorUnauthorized => 'Log ind for at fortsætte.';

  @override
  String get errorForbidden => 'Du har ikke adgang til dette.';

  @override
  String get errorSessionExpired => 'Din session er udløbet. Log ind igen.';

  @override
  String get errorInvalidCredentials => 'Ugyldig e-mail eller adgangskode.';

  @override
  String get errorTokenRefreshFailed =>
      'Kunne ikke opdatere din session. Log ind igen.';

  @override
  String get errorRequestCancelled => 'Anmodning annulleret.';

  @override
  String get errorInvalidFormat => 'Filformatet understøttes ikke.';

  @override
  String get errorFileTooLarge => 'Filen er for stor.';

  @override
  String get errorUploadFailed => 'Upload mislykkedes. Prøv igen.';

  @override
  String get errorCacheCorrupted =>
      'Gemte data blev beskadiget og er nulstillet.';

  @override
  String get errorCacheNotFound => 'Intet gemt endnu.';

  @override
  String get errorUserNotFound => 'Kunne ikke finde den konto.';

  @override
  String get errorItemNotFound => 'Elementet findes ikke længere.';

  @override
  String get errorOutfitNotFound => 'Outfitsegmentet findes ikke længere.';

  @override
  String get rewardsTitle => 'Belønninger';

  @override
  String get rewardsNoAchievementsTitle => 'Ingen præstationer endnu';

  @override
  String get rewardsNoAchievementsBody =>
      'Tilføj tøj og planlæg outfits for at optjene din første.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Ingen på listen endnu';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planlæg outfits for at optjene point og vises her.';

  @override
  String get legalViewPrivacyPolicy => 'Se privatlivspolitik';

  @override
  String get aiConsentAgree => 'Accepter & fortsæt';

  @override
  String get aiConsentNotNow => 'Ikke nu';

  @override
  String get imageViewerCloseTooltip => 'Luk billedvisning';

  @override
  String get updateReadyTitle => 'Opdatering klar';

  @override
  String get updateReadyBody =>
      'Genstart FitCheck AI for at anvende de seneste forbedringer.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI behøver kamerabrug for at tage billeder af dine outfits og garderobe.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI behøver adgang til billedbiblioteket for at vælge billeder af dine outfits og garderobe.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI behøver at gemme dine AI-genererede outfitbilleder i dit billedbibliotek.';

  @override
  String get wardrobeSomePhotosSkipped => 'Nogle billeder blev udeladt';

  @override
  String get wardrobePhotosNotAdded => 'Billeder ikke tilføjet';

  @override
  String get wardrobePhotoNotAdded => 'Billede ikke tilføjet';

  @override
  String get wardrobeNotStartedTitle => 'Ikke startet';

  @override
  String get wardrobeNoRoomTitle => 'Ingen plads';

  @override
  String get wardrobeAddPhotosSemantic => 'Tilføj billeder';

  @override
  String get batchAddTileLabel => 'Tilføj';

  @override
  String get batchProfileLinkLabel => 'Profil-link';

  @override
  String get wardrobeImportFromProfileTitle => 'Importer fra en profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Tilføj flere billeder';

  @override
  String get wardrobeClearAction => 'Ryd';

  @override
  String get wardrobeRefreshTooltip => 'Genopfrisk';

  @override
  String get batchNoPhotosYetTitle => 'Ingen billeder endnu';

  @override
  String get batchChoosePhotosAction => 'Vælg billeder';

  @override
  String get batchWeFindEachPieceBody =>
      'Vi finder hvert enkelt stykke tøj og laver et studiebillede af det.';

  @override
  String get batchPreparingPhotosSemantic => 'Forbereder billeder';

  @override
  String get batchPhotosProcessedSemantic => 'Billeder behandlet';

  @override
  String get batchPasteProfileLinkTitle => 'Indsæt et profil-link';

  @override
  String get batchPasteProfileLinkBody =>
      'En offentlig Instagram- eller Facebook-profil. Vi scanner dens billeder, og du vælger, hvad der kommer i skabet.';

  @override
  String get batchClearLinkTooltip => 'Ryd link';

  @override
  String get batchStartingButton => 'Starter';

  @override
  String get batchStartImportAction => 'Start import';

  @override
  String get batchReviewEveryPhotoTitle => 'Du gennemgår hvert billede';

  @override
  String get batchReviewEveryPhotoBody =>
      'Intet tilføjes, før du godkender det.';

  @override
  String get batchPrivateProfilesTitle => 'Private profiler';

  @override
  String get batchPrivateProfilesBody =>
      'Forbind din konto. Instagram bruger også brugernavn og adgangskode.';

  @override
  String get batchUseAnotherLinkAction => 'Brug et andet link';

  @override
  String get batchSignInNeededTitle => 'Log ind påkrævet';

  @override
  String get batchEnterYourCodeTitle => 'Indtast din kode';

  @override
  String get batchUseUsernamePasswordAction => 'Brug brugernavn og adgangskode';

  @override
  String get batchAlreadyConnectedAction =>
      'Jeg har allerede forbundet i browseren';

  @override
  String get batchEnterCodeAction => 'Indtast kode';

  @override
  String get batchTryAnotherWayAction => 'Prøv en anden metode';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Genopretter forbindelse';

  @override
  String get batchSignInToInstagramTitle => 'Log ind på Instagram';

  @override
  String get batchUsernameLabel => 'Brugernavn';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kode, hvis du bruger totrinsbekræftelse';

  @override
  String get batchAuthenticatorCodeBody =>
      'Brug den 6-cifrede kode fra din authenticator-app. Koder skifter hurtigt.';

  @override
  String get batchVerifyAction => 'Bekræft';

  @override
  String get batchFindingPhotosTitle => 'Finder billeder';

  @override
  String get batchImportPausedTitle => 'Import sat på pause';

  @override
  String get batchProcessingPhotosTitle => 'Behandler billeder';

  @override
  String get batchWaitingNextPhoto => 'Venter på næste billede';

  @override
  String get batchCancelImportAction => 'Annuller import';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Ingen genstande fundet på dette billede.';

  @override
  String get batchEditPieceColoursLabel => 'Farver, adskilt af kommaer';

  @override
  String get batchAddToClosetAction => 'Føj til garderobe';

  @override
  String get batchSkipPhotoAction => 'Spring billede over';

  @override
  String get batchImportCompleteTitle => 'Import fuldført';

  @override
  String get batchImportFailedTitle => 'Import mislykkedes';

  @override
  String get batchImportCancelledTitle => 'Import annulleret';

  @override
  String get batchImportErrorBody => 'Noget gik galt under importen.';

  @override
  String get batchNothingMoreImportedBody =>
      'Intet yderligere importeres fra denne profil.';

  @override
  String get batchViewClosetAction => 'Vis skab';

  @override
  String get batchStartOverAction => 'Start forfra';

  @override
  String get wardrobeAddPieceTitle => 'Tilføj del';

  @override
  String get wardrobeAddDetailsTitle => 'Tilføj detaljer';

  @override
  String get wardrobeScanningTitle => 'Scanner';

  @override
  String get batchReviewPiecesTitle => 'Gennemse dele';

  @override
  String get wardrobeGalleryAction => 'Galleri';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Ny';

  @override
  String get wardrobeRemovePhotoTooltip => 'Fjern billede';

  @override
  String get batchRunInBackgroundTooltip => 'Kør i baggrunden';

  @override
  String get batchStepOneOfTwo => 'Trin 1 af 2';

  @override
  String get batchStepTwoOfTwo => 'Trin 2 af 2';

  @override
  String get batchUploadingPhotosTitle => 'Uploader billeder';

  @override
  String get batchFindingPiecesTitle => 'Finder dele';

  @override
  String get batchMakingStudioPhotosTitle => 'Opretter studiobilleder';

  @override
  String get batchStoppedLabel => 'Stoppet';

  @override
  String get batchFindingPiecesStoppedTitle => 'Søgning efter dele stoppet';

  @override
  String get batchCancelledLabel => 'Annulleret';

  @override
  String get batchAllDoneTitle => 'Helt færdig';

  @override
  String get batchOpeningPiecesBody => 'Åbner dine dele';

  @override
  String get batchNothingSavedBody => 'Intet blev gemt.';

  @override
  String get batchFindingPiecesFailedBody => 'Kunne ikke finde dele.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Søgning efter dele stoppede for tidligt.';

  @override
  String get batchStopFindingPiecesTitle => 'Stop søgning?';

  @override
  String get batchStopFindingPiecesBody =>
      'Scanningen stopper, og intet gemmes. Dele, der allerede er fundet, forbliver i din aktivitet, indtil du fjerner dem.';

  @override
  String get batchKeepGoingAction => 'Fortsæt';

  @override
  String get batchTryAgainAction => 'Prøv igen';

  @override
  String get batchBackToPhotosAction => 'Tilbage til billeder';

  @override
  String get batchSkipAllAction => 'Spring alle over';

  @override
  String get batchIncludeAllAction => 'Inkluder alle';

  @override
  String get batchNoPiecesFoundTitle => 'Ingen dele fundet';

  @override
  String get batchNoPiecesFoundBody =>
      'Vi fandt ingen tøjdele på disse billeder.';

  @override
  String get batchChooseOtherPhotosAction => 'Vælg andre billeder';

  @override
  String get batchUseCaseHelper => 'Tilføjet til hver del, du gemmer.';

  @override
  String get batchDiscardPiecesTitle => 'Slet disse dele?';

  @override
  String get batchDiscardPiecesBody => 'Intet fra denne batch gemmes.';

  @override
  String get batchKeepAction => 'Behold';

  @override
  String get batchDiscardAction => 'Slet';

  @override
  String get batchRemovePieceTitle => 'Fjern denne del?';

  @override
  String get batchRemovePieceBody => 'Den er ikke gemt i dit skab.';

  @override
  String get batchRemoveAction => 'Fjern';

  @override
  String get batchChoosePiecesToSave => 'Vælg dele, der skal gemmes';

  @override
  String get batchDiscardAllAction => 'Slet alle';

  @override
  String get batchNothingSavedRetryBody => 'Intet blev gemt. Prøv igen.';

  @override
  String get batchNotSavedTitle => 'Ikke gemt';

  @override
  String get batchSavingLabel => 'Gemmer';

  @override
  String get batchSendToBackgroundAction => 'Kør i baggrunden';

  @override
  String get batchStillWorkingMessage =>
      'Arbejder stadig. Vi giver besked, når dine dele er klar.';

  @override
  String get batchRunningInBackgroundTitle => 'Kører i baggrunden';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studiobilleder stoppet før tid. Du kan stadig gemme disse dele.';

  @override
  String get batchTapPieceToSkip => 'Tryk på en del for at springe den over.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studiobilleder er på vej. Du kan forlade appen – vi giver besked.';

  @override
  String get batchLeaveAction => 'Forlad';

  @override
  String get batchPeopleInPhotosTitle => 'Personer på billederne';

  @override
  String get batchIncludeAction => 'Inkluder';

  @override
  String get batchSkipAction => 'Spring over';

  @override
  String get batchYourPhotoIsUsedLabel => 'Dit foto bruges';

  @override
  String get batchMakingStudioPhotoLabel => 'Opretter studiofoto';

  @override
  String get batchNoStudioPhotoBody => 'Intet studiofoto. Dit foto bruges.';

  @override
  String get batchEnterDetailsYourselfAction => 'Indtast detaljer selv';

  @override
  String get batchChooseAnotherPhotoAction => 'Vælg et andet foto';

  @override
  String get batchConnectionLostTitle => 'Forbindelsen afbrudt';

  @override
  String get batchConnectionLostBody => 'Tjek din forbindelse, og prøv igen.';

  @override
  String get batchDailyLimitTitle => 'Daglig grænse nået';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Opgrader til Pro for flere scanninger, eller indtast detaljerne selv.';

  @override
  String get batchDailyLimitBodyFree =>
      'Dine scanninger nulstilles i morgen. Du kan indtast detaljerne selv nu.';

  @override
  String get batchSeePlansAction => 'Se planer';

  @override
  String get batchAiBusyTitle => 'Vores AI har travlt';

  @override
  String get batchAiBusyBody =>
      'Dette er på vores side. Prøv igen om et øjeblik.';

  @override
  String get batchNoPiecesBody =>
      'Prøv et klarere foto, eller indtast detaljerne selv.';

  @override
  String get batchScanningUnavailableTitle => 'Scanning er utilgængelig';

  @override
  String get batchScanningUnavailableBody =>
      'Indtast detaljerne selv foreløbig.';

  @override
  String get batchScanDidNotFinishTitle => 'Scanningen blev ikke færdig';

  @override
  String get batchTryAgainBody => 'Prøv igen.';

  @override
  String get billingTitle => 'Abonnement';

  @override
  String get billingUpgradeHeading => 'Opgrader din plan';

  @override
  String get billingUpgradeOnPlusBody => 'Samme funktioner, højere grænser.';

  @override
  String get billingUpgradeBody =>
      'Plus og Pro har de samme funktioner. Vælg de grænser, du har brug for.';

  @override
  String get billingWebUnavailableBody =>
      'Onlineopgraderinger er ikke tilgængelige endnu. En promo- eller henvisningskode låser stadig Plus eller Pro op. Inviter venner herunder for at optjene gratis måneder.';

  @override
  String get billingPlansStale =>
      'Kunne ikke indlæse de nyeste planer. Priserne kan være forældede.';

  @override
  String get billingMonthly => 'Månedlig';

  @override
  String get billingYearly => 'Årlig';

  @override
  String get billingCurrentPlan => 'Nuværende plan';

  @override
  String get billingActive => 'Aktiv';

  @override
  String get billingThisMonth => 'Denne måned';

  @override
  String get billingItemExtractions => 'Genstandsudtræk';

  @override
  String get billingOutfitVisualizations => 'Outfit-visualiseringer';

  @override
  String get billingNearLimitUpgrade =>
      'Du er tæt på månedens grænse. Opgrader for at få mere.';

  @override
  String get billingNearLimitResets =>
      'Du er tæt på månedens grænse. Den nulstilles i starten af næste måned.';

  @override
  String get billingStoreUnavailable =>
      'Opgraderinger er ikke tilgængelige i butikken endnu. Kig forbi igen snart.';

  @override
  String get billingManageHeading => 'Administrer dit abonnement';

  @override
  String get billingCancelPlan => 'Opsig abonnement';

  @override
  String get billingCancelKeepsAccess =>
      'Du beholder adgangen indtil udgangen af denne betalingsperiode.';

  @override
  String get billingCancelConfirmTitle => 'Vil du opsige dit abonnement?';

  @override
  String get billingKeepPlan => 'Behold abonnement';

  @override
  String get billingCancelPlanAction => 'Opsig abonnement';

  @override
  String get billingBilledMonthly => 'Faktureres månedligt';

  @override
  String get billingBilledYearly => 'Faktureres årligt';

  @override
  String get billingVirtualTryOn => 'Virtuel prøvning';

  @override
  String get billingPrioritySupport => 'Prioriteret support';

  @override
  String get billingDisclosureProRenewing =>
      'Pro er et automatisk fornyende abonnement';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus og Pro er automatisk fornyende abonnementer';

  @override
  String get billingDisclosureAppleBilling =>
      'Betalingen trækkes fra dit Apple ID ved købsbekræftelse.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Betalingen trækkes fra din Google Play-konto ved købsbekræftelse.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Dit abonnement fornyes automatisk for samme periode til samme pris, medmindre du slår automatisk fornyelse fra mindst 24 timer før den aktuelle periode udløber.';

  @override
  String get billingDisclosureAppleManage =>
      'Administrer eller opsig når som helst i Indstillinger › dit Apple ID › Abonnementer.';

  @override
  String get billingDisclosureGoogleManage =>
      'Administrer eller opsig når som helst i Google Play › Betalinger og abonnementer.';

  @override
  String get billingReferFriend => 'Verv en ven';

  @override
  String get billingHowItWorks => 'Sådan fungerer det';

  @override
  String get billingHowShareTitle => 'Del dit link';

  @override
  String get billingHowShareBody => 'Send det til en ven.';

  @override
  String get billingHowSignUpTitle => 'De tilmelder sig';

  @override
  String get billingHowSignUpBody => 'Din ven tilmelder sig via linket.';

  @override
  String get billingHowBothTitle => 'I får begge Pro';

  @override
  String get billingHowBothBody => 'I får begge en måned med Pro gratis.';

  @override
  String get billingYourReferrals => 'Dine vervninger';

  @override
  String get billingInvited => 'Inviteret';

  @override
  String get billingJoined => 'Tilmeldt';

  @override
  String get billingMonthsEarned => 'Optjente måneder';

  @override
  String get billingInviteFriend => 'Inviter en ven';

  @override
  String get billingInviteBody => 'Du og din ven får en måned med Pro.';

  @override
  String get billingYourCode => 'Din kode';

  @override
  String get billingCopyLink => 'Kopiér link';

  @override
  String get billingShareInvite => 'Del invitation';

  @override
  String get giftUnavailable =>
      'Gaveinvitationer er ikke tilgængelige i denne version.';

  @override
  String get giftPageTitle => 'Giv FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Ingen gratis gaveinvitationer tilgængelige lige nu.';

  @override
  String get giftFormTitle => 'Send en gratis invitation';

  @override
  String get giftFormBody =>
      'Modtageren indløser gaven med denne verificerede e-mail. Vi sender ikke e-mailen for dig.';

  @override
  String get giftFieldFrom => 'Fra';

  @override
  String get giftFieldRecipientName => 'Modtagers navn';

  @override
  String get giftFieldRecipientEmail => 'Modtagers e-mail';

  @override
  String get giftFieldOccasion => 'Anledning (valgfrit)';

  @override
  String get giftNoOccasion => 'Ingen anledning';

  @override
  String get giftOccasionBirthday => 'Fødselsdag';

  @override
  String get giftOccasionAnniversary => 'Jubilæum';

  @override
  String get giftOccasionOther => 'Andet';

  @override
  String get giftFieldCardGreeting => 'Korthilsen';

  @override
  String get giftFieldCardGreetingHelper =>
      'Dette vises på kortet præcist som skrevet.';

  @override
  String get giftFieldPrivateNote => 'Privat note (valgfrit)';

  @override
  String get giftCreateAction => 'Opret gratis gave';

  @override
  String get giftClaimedTitle => 'Gave indløst';

  @override
  String get giftClaimedActive => 'Din FitCheck Pro-gave er aktiv.';

  @override
  String get giftClaimedQueued =>
      'Din FitCheck Pro-gave starter efter din nuværende adgang.';

  @override
  String get giftLinkCopied => 'Gavelink kopieret til udklipsholderen.';

  @override
  String get giftErrorName => 'Indtast et navn.';

  @override
  String get giftErrorEmail => 'Indtast en gyldig e-mailadresse.';

  @override
  String get giftErrorGreeting => 'Indtast korthilsenen.';

  @override
  String get giftErrorGreetingLength => 'Brug højst 80 tegn.';

  @override
  String get giftClaimAction => 'Modtag gave';

  @override
  String get giftCardPreview => 'Korteksempel';

  @override
  String get giftGiftForYou => 'En gave til dig';

  @override
  String get giftGiftWaiting => 'En gave venter på dig';

  @override
  String get giftOpenBody =>
      'Åbn dine gaver for at hente dem med din verificerede e-mail.';

  @override
  String get giftOpenGifts => 'Åbn gaver';

  @override
  String get giftSendInvitation => 'Send invitation';

  @override
  String get settingsAiProviderSection => 'Udbyder';

  @override
  String get settingsAiCustom => 'Brugerendt';

  @override
  String get settingsAiUrlHelper =>
      'Brug en offentlig URL, som serveren kan nå. Localhost virker ikke fra vores servere.';

  @override
  String get settingsAiConnectionSection => 'Forbindelse';

  @override
  String get settingsAiApiUrl => 'API-URL';

  @override
  String get settingsAiApiKey => 'API-nøgle';

  @override
  String get settingsAiApiKeySaved =>
      'Gemt. Lad den være tom for at beholde den.';

  @override
  String get settingsAiChatModel => 'Chatmodel';

  @override
  String get settingsAiVisionModel => 'Visionmodel (valgfri)';

  @override
  String get settingsAiImageModel => 'Billedmodel (valgfri)';

  @override
  String get settingsAiImageModelNote =>
      'Billedgenerering kræver OpenAI-kompatible chat-completions med response_modalities.';

  @override
  String get settingsAiTestConnection => 'Test forbindelse';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarGoToToday => 'Gå til i dag';

  @override
  String get calendarConnectTooltip => 'Forbind en kalender';

  @override
  String get calendarAddEvent => 'Tilføj begivenhed';

  @override
  String get calendarEmptyTitle => 'Intet planlagt';

  @override
  String get calendarEmptyBody => 'Tilføj en begivenhed og planlæg dit tøj.';

  @override
  String get calendarPreviousMonth => 'Forrige måned';

  @override
  String get calendarNextMonth => 'Næste måned';

  @override
  String get calendarAllDay => 'Hele dagen';

  @override
  String get calendarOutfitLinked => 'Outfit tilknyttet';

  @override
  String get calendarEventOptions => 'Begivenhedsmuligheder';

  @override
  String get calendarDeleteTitle => 'Slet denne begivenhed?';

  @override
  String get calendarChangeOutfit => 'Skift sæt';

  @override
  String get calendarLinkOutfit => 'Knyt et sæt til';

  @override
  String get calendarRemoveOutfit => 'Fjern sæt';

  @override
  String get calendarNewEvent => 'Ny begivenhed';

  @override
  String get calendarEditEvent => 'Rediger begivenhed';

  @override
  String get calendarTitleLabel => 'Titel';

  @override
  String get calendarTitleRequired => 'Tilføj en titel';

  @override
  String get calendarEndBeforeStart => 'Slut efter starttidspunktet';

  @override
  String get calendarStarts => 'Starter';

  @override
  String get calendarEnds => 'Slutter';

  @override
  String get calendarPlaceOptional => 'Sted (valgfrit)';

  @override
  String get calendarNotesOptional => 'Noter (valgfrit)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Sammensæt et sæt, og knyt det til denne begivenhed.';

  @override
  String get calendarBuildOutfit => 'Sammensæt et sæt';

  @override
  String get calendarConnectionsTitle => 'Kalendere';

  @override
  String get calendarConnectionsBody =>
      'Begivenheder du tilføjer her forbliver i FitCheck AI.';

  @override
  String get calendarDisconnect => 'Afbryd forbindelse';

  @override
  String get calendarNotAvailable => 'Ikke tilgængelig endnu';

  @override
  String get profileSectionExplore => 'Udforsk';

  @override
  String get profileNavTryOn => 'Prøv på';

  @override
  String get profileNavRewards => 'Belønninger';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Hjælp';

  @override
  String get profileAbout => 'Om';

  @override
  String get profileAboutBody => 'Dit skab, dine sæt og planer ét sted.';

  @override
  String get profileSignOutTitle => 'Log ud?';

  @override
  String get profileSignOutBody => 'Du kan logge ind igen når som helst.';

  @override
  String get profileEditTitle => 'Rediger profil';

  @override
  String get profileYourProfile => 'Din profil';

  @override
  String get profileBodyProfiles => 'Kropsprofiler';

  @override
  String get profileBodyEmptyTitle => 'Ingen kropsprofiler endnu';

  @override
  String get profileBodyEmptyBody =>
      'Tilføj din højde og kropsbygning for at få et bedre fit.';

  @override
  String get profileBodyAdd => 'Tilføj profil';

  @override
  String get profileBodyDefaultNote =>
      'Din standardprofil bruges til pasform og prøvning.';

  @override
  String get profileBodyDefaultBadge => 'Standard';

  @override
  String get profileBodyMakeDefault => 'Gør til standard';

  @override
  String get profileBodyDeleteBody => 'Dette kan ikke fortrydes.';

  @override
  String get profileBodyRequired => 'Påkrævet';

  @override
  String get profileBodyCheckNumber => 'Tjek dette tal';

  @override
  String get profileBodyNew => 'Ny kropsprofil';

  @override
  String get profileBodyNameHint => 'F.eks. Mig';

  @override
  String get profileBodyHeight => 'Højde';

  @override
  String get profileBodyWeight => 'Vægt';

  @override
  String get profileBodyBuild => 'Kropsbygning';

  @override
  String get profileBodySkinTone => 'Hudtone';

  @override
  String get profileBirthDateNeededBody =>
      'Tilføj en fødselsdato, der passer til fødselstidspunktet.';

  @override
  String get profileBirthDateNeededTitle => 'Fødselsdato påkrævet';

  @override
  String get profilePartlySavedBody =>
      'Vi gemte dit navn og billede. Fødselsdetaljer blev ikke gemt; prøv igen senere.';

  @override
  String get profilePartlySavedTitle => 'Delvist gemt';

  @override
  String get profileSavedBody => 'Din profil er gemt.';

  @override
  String get profileChangePhoto => 'Skift profilbillede';

  @override
  String get profilePhotoLabel => 'Profilbillede';

  @override
  String get profilePhotoHint => 'Tryk for at vælge et nyt';

  @override
  String get profileBirthDateLabel => 'Fødselsdato (valgfri)';

  @override
  String get profileBirthTimeLabel => 'Fødselstidspunkt (valgfrit)';

  @override
  String get profileBirthTimeHelper => 'Gør vediske forslag mere præcise';

  @override
  String get profileBirthPlaceLabel => 'Fødested (valgfrit)';

  @override
  String get profileBirthPlaceHint => 'F.eks. New Delhi, Indien';

  @override
  String get profileHelpContactTitle => 'Spørg os om alt';

  @override
  String get profileHelpContactBody =>
      'Send os en besked, og vi svarer via e-mail, normalt inden for et døgn.';

  @override
  String get profileHelpContactAction => 'Kontakt support';

  @override
  String get profileHelpFaqTitle => 'Ofte stillede spørgsmål';

  @override
  String get profileFaqAddPiecesTitle =>
      'Hvordan tilføjer jeg tøj til min garderobe?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tryk på Tilføj på fanen Garderobe. Tag et billede eller vælg et fra dit galleri; vi finder tøjet og tagster det for dig.';

  @override
  String get profileFaqMatchingTitle => 'Hvordan fungerer outfitsammensætning?';

  @override
  String get profileFaqMatchingBody =>
      'Åbn Til dig, og vælg ting, du ejet. Vi foreslår, hvad der passer til, og sammensætter komplette outfits fra din garderobe.';

  @override
  String get profileFaqTryOnTitle =>
      'Kan jeg bruge mine egne billeder til prøvning?';

  @override
  String get profileFaqTryOnBody =>
      'Ja. Tilføj et helkropsbillede af dig selv, og vælg derefter tøj for at se det på dig.';

  @override
  String get profileFaqRewardsTitle => 'Hvordan optjener jeg belønninger?';

  @override
  String get profileFaqRewardsBody =>
      'Planlæg og log outfits ofte. Streaks og præstationer opbygges undervejs.';

  @override
  String get profileFaqPrivacyTitle => 'Er min garderobe privat?';

  @override
  String get profileFaqPrivacyBody =>
      'Ja. Din garderobe og dine outfits er private, medmindre du deler et link til et enkelt outfit.';

  @override
  String get profileHelpMoreTitle => 'Mere hjælp';

  @override
  String get profileHelpGuides => 'Guides';

  @override
  String get profileHelpGuidesBody => 'Sådan fungerer hver funktion';

  @override
  String get feedbackCategoryBug => 'Noget gik i stykker';

  @override
  String get feedbackCategoryIdea => 'En ide';

  @override
  String get feedbackCategoryGeneral => 'Generelt';

  @override
  String get feedbackCategoryHelp => 'Jeg har brug for hjælp';

  @override
  String get feedbackHintBug =>
      'Hvad skete der, og hvad forventede du? Trin hjælper os med at rette det.';

  @override
  String get feedbackHintIdea => 'Hvad kunne du tænke dig, og hvorfor?';

  @override
  String get feedbackHintGeneral =>
      'Fortæl os din mening, eller stil et spørgsmål.';

  @override
  String get feedbackAttachmentLimitBody => 'Du kan tilføje op til 5 billeder.';

  @override
  String get feedbackAttachmentLimitTitle => 'Grænse nået';

  @override
  String get feedbackImageTooLargeBody => 'Vælg et billede på under 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Billede for stort';

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackAboutLabel => 'Hvad drejer det sig om?';

  @override
  String get feedbackSubjectLabel => 'Emne';

  @override
  String get feedbackSubjectRequired => 'Tilføj et emne';

  @override
  String get feedbackSubjectTooShort => 'Emnet skal være mindst 3 tegn';

  @override
  String get feedbackDetailsLabel => 'Detaljer';

  @override
  String get feedbackDetailsRequired => 'Tilføj flere detaljer';

  @override
  String get feedbackDetailsTooShort => 'Beskrivelsen skal være mindst 10 tegn';

  @override
  String get feedbackAddScreenshot => 'Tilføj skærmbillede';

  @override
  String get feedbackAttachmentHint => 'Op til 5, maks. 5 MB hver';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackEmptyTitle => 'Intet sendt endnu';

  @override
  String get feedbackEmptyBody => 'Det du sender vises her sammen med status.';

  @override
  String get feedbackHistoryTitle => 'Det du sendte';

  @override
  String get feedbackStatusOpen => 'Åben';

  @override
  String get feedbackStatusInProgress => 'I gang';

  @override
  String get feedbackStatusResolved => 'Løst';

  @override
  String get feedbackStatusClosed => 'Lukket';

  @override
  String get legalIntro =>
      'Hvordan vi beskytter dine data, og vilkårene for at bruge FitCheck AI.';

  @override
  String get legalPolicies => 'Politikker';

  @override
  String get legalPrivacySubtitle => 'Hvad vi indsamler og hvorfor';

  @override
  String get legalTermsTitle => 'Brugervilkår';

  @override
  String get legalTermsSubtitle => 'Reglerne for brug af appen';

  @override
  String get legalLicences => 'Open source-licenser';

  @override
  String get legalSupportSubtitle =>
      'Hjælp, kontakt og anmodninger om privatliv';

  @override
  String get legalReportAbuse => 'Rapporter et problem eller misbrug';

  @override
  String get permissionCameraTitle => 'Kameraadgang';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI bruger dit kamera til at tage billeder af dit tøj og outfits til AI-prøvning og garderobeorganisering.';

  @override
  String get permissionPhotoTitle => 'Billedadgang';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI skal have adgang til dine billeder, så du kan vælge tøj- og outfitbilleder til AI-funktioner og din garderobe.';

  @override
  String get permissionNotNow => 'Ikke nu';

  @override
  String get permissionOpenSettings => 'Åbn indstillinger';

  @override
  String authSignedInAs(String name) {
    return 'Logget ind som $name';
  }

  @override
  String get authSignedIn => 'Logget ind';

  @override
  String get authWelcomeBackTitle => 'Velkommen tilbage';

  @override
  String get authSignInFailed => 'Log ind mislykkedes';

  @override
  String get authWelcomeTitle => 'Velkommen';

  @override
  String get authSignUpFailed => 'Tilmelding mislykkedes';

  @override
  String get authGoogleSignInFailed => 'Google-login mislykkedes';

  @override
  String get authAppleSignInFailed => 'Apple-login mislykkedes';

  @override
  String get authConfirmEmailTitle => 'Bekræft din e-mail';

  @override
  String get authConfirmEmailBody =>
      'Tjek din indbakke for en bekræftelses-e-mail, og log ind.';

  @override
  String get authClosetReady => 'Dit skab er klar.';

  @override
  String get authSignedOutTitle => 'Logget ud';

  @override
  String get authSignedOutBody => 'Du er logget ud.';

  @override
  String get authSignOutFailed => 'Log ud mislykkedes';

  @override
  String get authEmailSentTitle => 'E-mail sendt';

  @override
  String get authResetLinkSent =>
      'Tjek din e-mail for et link til nulstilling.';

  @override
  String get authPasswordUpdatedTitle => 'Adgangskode opdateret';

  @override
  String get authPasswordUpdated => 'Din adgangskode er opdateret.';

  @override
  String get authPasswordNotUpdated => 'Adgangskode ikke opdateret';

  @override
  String get authCouldNotSendEmail => 'Kunne ikke sende e-mailen';

  @override
  String get authEmailNotSent => 'E-mail ikke sendt';

  @override
  String get authResendSentBody => 'Vi har sendt en ny bekræftelses-e-mail.';

  @override
  String get outfitPreviewWithAi => 'Forhåndsvis med AI';

  @override
  String get outfitNewPreview => 'Lav ny forhåndsvisning';

  @override
  String get outfitBuilderClosetHeading => 'Din skab';

  @override
  String get outfitBuilderSearchHint => 'Søg i dele';

  @override
  String get outfitClearSearch => 'Ryd søgning';

  @override
  String get outfitBuilderAddPiecesTitle => 'Tilføj dele først';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits laves ud fra delene i dit skab.';

  @override
  String get outfitBuilderNoMatches => 'Ingen dele matcher.';

  @override
  String get outfitNameLabel => 'Outfit-navn';

  @override
  String get outfitNameHint => 'F.eks. Ugentligt lin';

  @override
  String get outfitPreviewSemantic => 'AI-forhåndsvisning af outfit';

  @override
  String get outfitChoosePieces => 'Vælg dele';

  @override
  String get outfitTapPiecesHint =>
      'Tryk på delene herunder for at tilføje dem.';

  @override
  String get outfitShareTooltip => 'Del';

  @override
  String get outfitSaveFavourite => 'Gem i favoritter';

  @override
  String get outfitPiecesHeading => 'Dele';

  @override
  String get outfitWearHistoryEmpty =>
      'Bær det én gang, så vises datoerne her.';

  @override
  String get outfitWearHistoryTitle => 'Bærehistorik';

  @override
  String get outfitWearHistoryError => 'Kunne ikke indlæse datoerne.';

  @override
  String get outfitWornOn => 'Båret den';

  @override
  String get outfitEditTitle => 'Rediger outfit';

  @override
  String get outfitSavedPhotosFailed => 'Detaljer gemt, billeder ej';

  @override
  String get outfitNoPhotosBody =>
      'Ingen billeder endnu. Outfit viser sine dele i stedet.';

  @override
  String get outfitOccasionLabel => 'Anledning';

  @override
  String get outfitOccasionNone => 'Ingen';

  @override
  String get outfitTagsHint => 'Adskil med kommaer';

  @override
  String get outfitDraftBody => 'Skjult fra din hovedliste';

  @override
  String get outfitPublic => 'Offentlig';

  @override
  String get outfitPublicBody => 'Alle med linket kan se det';

  @override
  String get outfitDeleteFromDetail =>
      'Slet dette outfit fra dens detaljeside.';

  @override
  String get outfitNewCollection => 'Ny samling';

  @override
  String get outfitNoCollectionsTitle => 'Ingen samlinger endnu';

  @override
  String get outfitNoCollectionsBody =>
      'Gruppér outfits efter rejse, sæson eller stemning.';

  @override
  String get outfitCreateCollection => 'Opret en samling';

  @override
  String get outfitAddOutfits => 'Tilføj outfits';

  @override
  String get outfitRename => 'Omdøb';

  @override
  String get outfitCollectionDeleteBody => 'Outfits beholdes.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfits indlæst ikke';

  @override
  String get outfitRenameCollection => 'Omdøb samling';

  @override
  String get outfitDescriptionOptional => 'Beskrivelse (valgfri)';

  @override
  String get outfitAllInCollection =>
      'Alle outfits er allerede i denne samling.';

  @override
  String get photoshootSubtitleUpload => 'Studieportrætter fra dine egne fotos';

  @override
  String get photoshootSubtitleConfigure => 'Vælg stil, format og antal';

  @override
  String get photoshootSubtitleGenerating => 'Det tager et par minutter';

  @override
  String get photoshootAddPhotosSemantic => 'Tilføj fotos fra din galleri';

  @override
  String get photoshootUploadTitle => 'Tilføj 1 til 4 fotos af dig selv';

  @override
  String get photoshootUploadBody => 'Tryk for at vælge fra dit galleri';

  @override
  String get photoshootAddToContinue => 'Tilføj et foto for at fortsætte';

  @override
  String get photoshootAddAnotherPhoto => 'Tilføj et andet foto';

  @override
  String get photoshootTipsTitle => 'For bedst mulig resultat';

  @override
  String get photoshootTipsBody =>
      'Brug klare, velbelyst ansigtsfotos fra flere vinkler. Undgå solbriller og hatter.';

  @override
  String get photoshootStarting => 'Starter';

  @override
  String get photoshootCancelling => 'Afvikler';

  @override
  String get photoshootFailed => 'Mistlykket';

  @override
  String get recommendTabMatches => 'Matches';

  @override
  String get recommendTabComplete => 'Komplet';

  @override
  String get recommendTabWeather => 'Vær';

  @override
  String get recommendTabColours => 'Farver';

  @override
  String get recommendTabShop => 'Butik';

  @override
  String get recommendNoMatchesTitle => 'Ingen matches endnu';

  @override
  String get recommendNoMatchesBody =>
      'Vælg et stykke, så finder vi det, der passer til det.';

  @override
  String get recommendPickPiece => 'Vælg et stykke';

  @override
  String get recommendNothingMatchesTitle => 'Ingen matcher endnu';

  @override
  String get recommendNothingMatchesBody =>
      'Prøv andre stykker, eller tilføj flere til dit skab.';

  @override
  String get recommendChangePieces => 'Skift stykker';

  @override
  String get recommendDefaultReason =>
      'Det passer til de stykker, du har valgt.';

  @override
  String get recommendCompleteTitle => 'Fuldbring et look';

  @override
  String get recommendCompleteBody => 'Vælg et stykke, så udfylder vi resten.';

  @override
  String get recommendWorking => 'Arbejder';

  @override
  String get recommendGenerate => 'Generér';

  @override
  String get recommendChooseStyleBody => 'Vælg en stil, og generér derefter.';

  @override
  String get recommendNoLooksTitle => 'Ingen looks til disse stykker';

  @override
  String get recommendNoLooksBody => 'Prøv en anden stil eller andre stykker.';

  @override
  String get recommendDefaultLook => 'Et look til dine stykker';

  @override
  String get recommendNoPiecesBody => 'Ingen stykker tilbage til dette look.';

  @override
  String get recommendCityLabel => 'By';

  @override
  String get recommendCheck => 'Tjek';

  @override
  String get recommendWeatherTitle => 'Hvad er vejret?';

  @override
  String get recommendWeatherBody => 'Indtast din by for at få bud til i dag.';

  @override
  String get recommendWearToday => 'Bær i dag';

  @override
  String get recommendWeatherNoPieces =>
      'Ingen stykker i dit skab til dette vejr endnu.';

  @override
  String get recommendBudgetLabel => 'Budget op til';

  @override
  String get recommendLooking => 'Leder';

  @override
  String get recommendFindWhatToBuy => 'Find, hvad der skal købes';

  @override
  String get recommendFillGapsTitle => 'Udfyld hullerne';

  @override
  String get recommendFillGapsBody =>
      'Sæt et budget, så foreslår vi, hvad dit skab mangler.';

  @override
  String get recommendNoGapsTitle => 'Ingen huller fundet';

  @override
  String get recommendNoGapsBody =>
      'Prøv et højere budget eller en anden kategori.';

  @override
  String get recommendMoodEveryday => 'Hverdag';

  @override
  String get recommendMoodBigMeeting => 'Mødes';

  @override
  String get recommendDayLabel => 'Dag';

  @override
  String get recommendReadingStars => 'Læser i stjernerne';

  @override
  String get recommendGetMyColours => 'Få mine farver';

  @override
  String get recommendLuckyColoursTitle => 'Dine heldige farver';

  @override
  String get recommendLuckyColoursBody =>
      'Vælg en dag, så foreslår vi farver og stykker.';

  @override
  String get recommendLuckyColoursSection => 'Heldige farver';

  @override
  String get recommendAvoidColoursSection => 'Farver du bør undgå';

  @override
  String get recommendBirthDateTitle => 'Tilføj fødselsdato';

  @override
  String get recommendBirthDateBody =>
      'Vi skal bruge din fødselsdato til at læse farver.';

  @override
  String get recommendEditProfile => 'Rediger profil';

  @override
  String get recommendNothingThisDay => 'Ingen oplysninger til denne dag.';

  @override
  String get recommendUnnamedColour => 'Upåvirket farve';

  @override
  String get recommendFromCloset => 'Fra dit garderobe';

  @override
  String get recommendNoPiecesInColours =>
      'Ingen stykker i disse farver endnu.';

  @override
  String get recommendOutfitIdeas => 'Outfit-ideer';

  @override
  String get recommendNoOutfitsInColours =>
      'Ingen komplette outfits i disse farver endnu.';

  @override
  String get recommendDefaultOutfitIdea => 'En outfit-ide';

  @override
  String get recommendPickUpToThree => 'Vælg op til tre stykker';

  @override
  String get recommendEmptyClosetBody =>
      'Tilføj et par stykker først, og kom så tilbage for at se match.';

  @override
  String get dashboardDressForDay => 'Klæd dig til dagen, som kommer.';

  @override
  String get dashboardOutfitOfDay => 'Dagens outfit';

  @override
  String get dashboardFreshLook => 'Et nyt look';

  @override
  String get subscriptionManageInStoreTitle => 'Administrer i butikken';

  @override
  String get subscriptionManageInStoreBody =>
      'Denne plan afregnes gennem butikken. Administrér den i dine kontoindstillinger i butikken.';

  @override
  String get subscriptionCancelledTitle => 'Abonnement afsluttet';

  @override
  String get subscriptionCancelledBody =>
      'Din plan forbliver aktiv indtil udgangen af denne faktureringsperiode.';

  @override
  String get subscriptionCancelFailedTitle => 'Kunne ikke annullere';

  @override
  String get subscriptionCouldNotOpenTitle => 'Kunne ikke åbne';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Kunne ikke åbne faktura-administration.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Kunne ikke åbne linket.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Kunne ikke hente dit link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Kunne ikke hente dit referencelink. Prøv igen.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopieret';

  @override
  String get subscriptionReferralCopiedBody => 'Referencelink kopieret.';

  @override
  String get subscriptionReferralShareSubject => 'Prøv FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Tilslut dig til FitCheck AI, så får vi begge en måned af Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link kopieret';

  @override
  String get subscriptionShareUnavailableBody =>
      'Deling er ikke tilgængelig, så vi kopierede linket.';

  @override
  String get subscriptionShareFailedTitle => 'Kunne ikke dele';

  @override
  String get subscriptionShareFailedBody =>
      'Kopiér linket fra referencesiden i stedet.';

  @override
  String get subscriptionStoreReadyTitle => 'Butik klar';

  @override
  String get subscriptionStoreReadyBody =>
      'Butikspriser er tilgængelige. Du kan opgradere nu.';

  @override
  String get purchaseFailedTitle => 'Køb mislykkedes';

  @override
  String get purchaseUnavailableTitle => 'Køb utilgængeligt';

  @override
  String get purchaseIapUnavailableBody =>
      'In-app-køb er ikke tilgængelige på denne enhed.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Denne pakke er ikke tilgængelig til køb endnu.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Denne pakke er ikke tilgængelig i butikken endnu. Tjek venligst tilbage snart.';

  @override
  String get purchaseStartFailedBody => 'Købet kunne ikke starte. Prøv igen.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Tjekout returnerede ikke et betalingslink.';

  @override
  String get purchasePendingTitle => 'Køb ventende';

  @override
  String get purchasePendingBody =>
      'Dit køb venter på godkendelse. Du får adgang, så snart det er godkendt.';

  @override
  String get purchaseFailedBody => 'Købet mislykkedes. Prøv igen.';

  @override
  String get purchaseRestoredTitle => 'Genskabt';

  @override
  String get purchaseRestoredBody => 'Dine køb er genskabt.';

  @override
  String get purchaseActiveTitle => 'Abonnement aktivt';

  @override
  String get purchaseActiveBody => 'Dit abonnement er aktivt. Velkommen.';

  @override
  String get purchaseSignInRequiredTitle => 'Log på for at fortsætte';

  @override
  String get purchaseSignInRequiredBody => 'Log på for at gennemføre dit køb.';

  @override
  String get purchaseErrorTitle => 'Købsfejl';

  @override
  String get purchaseInvalidTransactionBody =>
      'Købet indeholdt ikke en verificerbar transaktions-ID.';

  @override
  String get purchaseVerificationPendingTitle => 'Verifikation i gang';

  @override
  String get purchaseVerificationPendingBody =>
      'Vi kunne ikke verificere dit køb i butikken lige nu. Det bliver færdiggjort automatisk, og du bliver ikke belastet to gange.';

  @override
  String get purchaseNotAppliedTitle => 'Køb ikke registreret';

  @override
  String get purchaseNotAppliedBody =>
      'Dit køb kunne ikke registreres på din konto. Kontakt support, og køb det ikke igen.';

  @override
  String get purchaseRestoreFailedTitle => 'Gendannelse mislykkedes';

  @override
  String get purchaseRestoreFailedBody => 'Kunne ikke gendanne køb. Prøv igen.';

  @override
  String get purchaseRecoveredActiveBody => 'Din abonnements er aktiv.';

  @override
  String get purchaseCompleteTitle => 'Køb gennemført';

  @override
  String get giftCreateFailedTitle => 'Gaven kunne ikke oprettes';

  @override
  String get giftClaimFailedTitle => 'Gaven kunne ikke udbetales';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gaver til dig',
      one: 'En gave til dig',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 måned',
      '12': '1 år',
      'other': '$months måneder',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining tilbage',
      one: '1 tilbage',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration af FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender har sendt dig $duration af FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'FitCheck Pro-gave til $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Fra $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Til $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Fra $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'din modtager';

  @override
  String get giftPreviewPlaceholderSender => 'dig';

  @override
  String get settingsSavedTitle => 'Gemt';

  @override
  String get settingsNotSavedTitle => 'Ikke gemt';

  @override
  String get settingsAiChooseProviderBody => 'Vælg en udbyder.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'En tilpasset udbyder kræver en API-URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Indtast en API-nøgle.';

  @override
  String get settingsAiSavedBody => 'Dine AI-indstillinger er gemt.';

  @override
  String get settingsAiMissingDetailsTitle => 'Manglende detaljer';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Indtast en API-URL og et chatmodel for at teste.';

  @override
  String get settingsAiKeyNeededTitle => 'API-nøgle kræves';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Indsæt din API-nøgle for at teste. Din gemte nøgle forbliver privat.';

  @override
  String get settingsAiKeyToTestBody => 'Indsæt din API-nøgle for at teste.';

  @override
  String get settingsAiConnectedTitle => 'Forbundet';

  @override
  String get settingsAiConnectedBody => 'Forbindelsen virker.';

  @override
  String get settingsAiTestFailedTitle => 'Test fejlet';

  @override
  String get settingsPreferencesSavedBody => 'Dine indstillinger er gemt.';

  @override
  String get settingsPasswordNotChangedTitle => 'Kodeord ændret ikke';

  @override
  String get settingsOAuthPasswordBody =>
      'Denne konto logger ind med Google eller Apple. Brug \"Glemt kodeord\" for først at oprette et kodeord.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Nuværende kodeord er forkert.';

  @override
  String get settingsExportReadyTitle => 'Eksport klar';

  @override
  String get settingsExportReadyBody =>
      'Din dataeksport er klar til at blive downloadet.';

  @override
  String get settingsLinkCopiedTitle => 'Link kopieret';

  @override
  String get settingsExportClipboardBody =>
      'Vi kunne ikke åbne din browser, så vi kopierede downloadlinket. Indsæt det i en browser hurtigst muligt: linket udløber.';

  @override
  String get settingsExportFailedTitle => 'Eksport fejlet';

  @override
  String get settingsAccountNotDeletedTitle => 'Konto slettet ikke';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Du kan tilføje op til $max fotos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Foto-øvre grænse';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Tilføj mindst ét foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Ingen fotos';

  @override
  String get photoshootDescribeLookBody => 'Beskriv det look, du ønsker.';

  @override
  String get photoshootPromptNeededTitle => 'Beskrivelse krævet';

  @override
  String get photoshootConsentFeatureLabel => 'AI Fotoshoot';

  @override
  String get photoshootStatusPreparing => 'Forbereder dine fotos';

  @override
  String get photoshootStatusGenerating => 'Genererer';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Parti $current af $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done af $total færdige';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generering fejlet.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready klare, $failed fejlet.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Delvist færdig';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos er klare.',
      one: '1 foto er klar.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Forbindelsen gik tabt. Prøv venligst igen.';

  @override
  String get photoshootCouldNotCancelTitle => 'Kunne ikke aflyse';

  @override
  String get photoshootRetryFailedTitle => 'Prøven lykkedes ikke';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Foto $number er klar.';
  }

  @override
  String get photoshootReplacedTitle => 'Udskiftet';

  @override
  String get photoshootSavedToGalleryBody => 'Gemt til dit galleri.';

  @override
  String get photoshootSavedTitle => 'Gemt';

  @override
  String get photoshootNotSavedTitle => 'Ikke gemt';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count fotos er i dit galleri.',
      one: '1 foto er i dit galleri.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved af $total gemt.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Nogle fotos ikke gemt';

  @override
  String get tryonConsentFeatureLabel => 'Virtual Prøve';

  @override
  String get tryonAvatarUpdatedBody => 'Dit foto er opdateret.';

  @override
  String get tryonSavedTitle => 'Gemt';

  @override
  String get tryonUploadFailedTitle => 'Upload fejlet';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Vælg et billede af et plads først.';

  @override
  String get tryonNoGarmentTitle => 'Ingen plads';

  @override
  String get tryonWaitForUploadBody => 'Vent på, at dit foto er uploadet.';

  @override
  String get tryonStillUploadingTitle => 'Uploader stadig';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Tilføj et billede af dig selv først.';

  @override
  String get tryonReadyBody => 'Din prøve er klar.';

  @override
  String get tryonFailedTitle => 'Prøve fejlet';

  @override
  String get tryonSavedToGalleryBody => 'Gemt til dit galleri.';

  @override
  String get tryonNotSavedTitle => 'Ikke gemt';

  @override
  String get calendarEventAddedBody => 'Hændelse tilføjet';

  @override
  String get calendarEventPlannedTitle => 'Planlagt';

  @override
  String get calendarEventSavedBody => 'Hændelse gemt';

  @override
  String get calendarSavedTitle => 'Gemt';

  @override
  String get calendarEventNotSavedTitle => 'Hændelse ikke gemt';

  @override
  String get calendarEventRemovedBody => 'Hændelse fjernet';

  @override
  String get calendarEventDeletedTitle => 'Slettet';

  @override
  String get calendarEventNotDeletedTitle => 'Begivenheden er ikke slettet';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit er ikke linket';

  @override
  String get calendarLinkedTitle => 'Linket';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit er ikke fjernet';

  @override
  String get calendarOutfitRemovedBody => 'Outfit er fjernet';

  @override
  String get calendarDisconnectedBody => 'Kalenderen er frakoblet';

  @override
  String get calendarDisconnectedTitle => 'Frakoblet';

  @override
  String get calendarNotDisconnectedTitle => 'Kalenderen er ikke frakoblet';

  @override
  String get calendarTodayLabel => 'i dag';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count begivenheder',
      one: '1 begivenhed',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start til $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit linket';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '»$title« bliver fjernet.';
  }

  @override
  String get calendarThisAppLabel => 'Denne app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synkronisering med $provider er ikke tilgængelig endnu. Du kan stadig tilføje begivenheder her.';
  }

  @override
  String get calendarWeekdaySunShort => 'Søn';

  @override
  String get calendarWeekdayMonShort => 'Man';

  @override
  String get calendarWeekdayTueShort => 'Tir';

  @override
  String get calendarWeekdayWedShort => 'Ons';

  @override
  String get calendarWeekdayThuShort => 'Tor';

  @override
  String get calendarWeekdayFriShort => 'Fre';

  @override
  String get calendarWeekdaySatShort => 'Lør';

  @override
  String get calendarWeekdayMonday => 'Mandag';

  @override
  String get calendarWeekdayTuesday => 'Tirsdag';

  @override
  String get calendarWeekdayWednesday => 'Onsdag';

  @override
  String get calendarWeekdayThursday => 'Torsdag';

  @override
  String get calendarWeekdayFriday => 'Fredag';

  @override
  String get calendarWeekdaySaturday => 'Lørdag';

  @override
  String get calendarWeekdaySunday => 'søndag';

  @override
  String get outfitSavedToFavouritesBody => 'Gemt til favoritter';

  @override
  String get outfitRemovedFromFavouritesBody => 'Fjernet fra favoritter';

  @override
  String get outfitNotSavedTitle => 'Ikke gemt';

  @override
  String get outfitLoggedAsWornBody => 'Registreret som bundet i dag.';

  @override
  String get outfitNicePickTitle => 'Flot valg';

  @override
  String get outfitRemovedBody => 'Outfit fjernet.';

  @override
  String get outfitDeletedTitle => 'Slettet';

  @override
  String get outfitNotDeletedTitle => 'Ikke slettet';

  @override
  String get outfitDuplicatedBody => 'En kopi er i dine outfits.';

  @override
  String get outfitDuplicatedTitle => 'Duplikeret';

  @override
  String get outfitNotDuplicatedTitle => 'Ikke duplikeret';

  @override
  String get outfitNotSharedTitle => 'Ikke delt';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" er klar.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Samling ikke oprettet';

  @override
  String get outfitCollectionUpdatedBody => 'Samling opdateret.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Samling ikke opdateret';

  @override
  String get outfitCollectionDeletedBody => 'Samling slettet.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Samling ikke slettet';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits tilføjet.',
      one: '1 outfit tilføjet.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits ikke tilføjet';

  @override
  String get outfitPreviewNotCreatedTitle => 'Forhåndsvisning ikke oprettet';

  @override
  String get outfitGiveNameBody => 'Giv outfitet et navn.';

  @override
  String get outfitNameMissingTitle => 'Navn';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Vælg mindst ét stykke.';

  @override
  String outfitCreatedBody(String name) {
    return '$name er i dine outfits.';
  }

  @override
  String get outfitSavedTitle => 'Gemt';

  @override
  String get wardrobeAddedToFavouritesBody => 'Tilføjet til favoritter';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Fjernet fra favoritter';

  @override
  String get wardrobeNotSavedTitle => 'Ikke gemt';

  @override
  String get wardrobeLoggedAsWornBody => 'Logget som båret i dag.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Fjernet fra dit skab.';

  @override
  String get wardrobeDeletedTitle => 'Slettet';

  @override
  String get wardrobeNotDeletedTitle => 'Ikke slettet';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stykker fjernet fra dit skab.',
      one: '1 stykke fjernet fra dit skab.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI garderobeekstraktion';

  @override
  String get itemAddScanJobLabel => 'Scan';

  @override
  String get itemAddFoundEarlierBody => 'Fundet i et tidligere scan';

  @override
  String get itemAddLookingAtPhoto => 'Kigger på dit foto';

  @override
  String get itemAddExtractionFailedBody => 'Ekstraktion mislykkedes';

  @override
  String get itemAddJobFailedBody => 'Job fiasko';

  @override
  String get itemAddConnectionLostBody => 'Forbinderen gik tabt. Prøv igen.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Forbinderen gik tabt under behandling.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Stykke $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Stykke';

  @override
  String get itemAddNotCancelledTitle => 'Ikke annulleret';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stykker er i dit skab.',
      one: '1 stykke er i dit skab.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved ud af $total stykker gemt. Tryk gem for at prøve de resterende igen.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Nogle stykker ikke gemt';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Vælg mindst ét foto.';

  @override
  String get batchPhotoUnreadableBody => 'Dette foto kunne ikke læses.';

  @override
  String get batchNoPhotosReadableBody =>
      'Ingen af disse fotos kunne læses. Prøv andre fotos.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Vi mistede forbindelsen under arbejde. Prøv igen.';

  @override
  String get batchNotCancelledTitle => 'Ikke annulleret';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Ingen understøttelse for opslag. Indtast et profil-link.';

  @override
  String get batchLinkSpacesBody => 'Links kan ikke indeholde mellemrum.';

  @override
  String get batchEnterProfileLinkBody =>
      'Indtast et Instagram- eller Facebook-profil-link.';

  @override
  String get batchEnterProfileLinkShortBody => 'Indtast et profil-link.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Log-in-siden blev ikke åbnet. Prøv igen.';

  @override
  String get batchSignInBrowserBody =>
      'Log ind i din browser og kom derefter tilbage til FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Forbind din konto';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Indtast koden fra din autentifikatorapp.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram kræver en sikkerhedstjek. Log først ind i din browser.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Indtast dit brugernavn og din adgangskode igen.';

  @override
  String get batchSignInFailedBody =>
      'Login mislykkedes. Tjek dit brugernavn og din adgangskode.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Log ind for at fortsætte med import.';

  @override
  String get batchAccountNotConnectedBody => 'Din konto blev ikke forbundet.';

  @override
  String get batchAccountConnectedTitle => 'Konto forbundet';

  @override
  String get batchNotConnectedTitle => 'Ikke forbundet';

  @override
  String get batchImportConnectionLostBody =>
      'Forbindelsen til importen gik tabt. Genindlæs for at tjekke den.';

  @override
  String batchPickUpToBody(int max) {
    return 'Vælg op til $max fotos. Vi finder delene.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count af $total fotos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Forbereder foto $done af $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Find dele i $count fotos',
      one: 'Find dele i 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Din $platform-konto bruger totrinslogin. Indtast koden på 6 cifre fra din autentifikatorapp.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Denne $platform-profil er privat eller kræver login for at vise billeder.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Forbind med $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos fundet hidtil',
      one: '1 foto fundet hidtil',
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
    return '$processed af $total behandlet · $added tilføjet · $waiting venter · $skipped sprunget over';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Scanner foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number er næste';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Foto $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dele fundet',
      one: '1 del fundet',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos er blevet tilføjet til dit klædeskab.',
      one: '1 foto er blevet tilføjet til dit klædeskab.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count mere studiefotos er på vej. Du kan gemme det, der er klart, eller gå — vi lader dig vide det.',
      one:
          '1 mere studiefoto er på vej. Du kan gemme det, der er klart, eller gå — vi lader dig vide det.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Ikke gemt endnu: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces dele',
      one: '1 del',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotos',
      one: '1 foto',
    );
    return '$_temp0 fra $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen valgt. Tryk på en del for at springe over den.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gemmer $count dele',
      one: 'Gemmer 1 del',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gem $count dele',
      one: 'Gem 1 del',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Din kropstypeprofil er gemt.';

  @override
  String get bodyProfileSavedTitle => 'Gemt';

  @override
  String get bodyProfileNotSavedTitle => 'Ikke gemt';

  @override
  String get bodyProfileSetDefaultBody => 'Vælges som din standardprofil.';

  @override
  String get bodyProfileDeletedBody => 'Kropstypeprofil slettet.';

  @override
  String get bodyProfileDeletedTitle => 'Slettet';

  @override
  String get bodyProfileNotDeletedTitle => 'Ikke slettet';

  @override
  String get feedbackNotSentTitle => 'Ikke sendt';

  @override
  String get feedbackSentBody =>
      'Tak. Vi læser alle beskeder og svarer, hvis vi har brug for mere.';

  @override
  String get feedbackSentTitle => 'Feedback sendt';

  @override
  String get recommendUnnamedPiece => 'Udøbt tøjdele';

  @override
  String get recommendEnterCityBody =>
      'Indtast din by for at få anbefalinger baseret på vejr.';

  @override
  String get recommendWhichCityTitle => 'Hvilken by?';

  @override
  String get aiConsentSheetTitle => 'Deling af fotos med en AI-tjeneste';

  @override
  String get aiConsentSheetBody =>
      'For at oprette dine prøvet og fotoshoot-billeder sender FitCheck AI de fotos, du leverer (inklusive billeder af dit ansigt og din krop), til en betroet tredjeparts AI-udbyder (f.eks. OpenAI eller Google Gemini) til behandling. De genererer dine billeder og bruger dem ikke til at træne deres modeller under vores vilkår. Fotos sendes sikkert og deles aldrig til markedsføring.';

  @override
  String get aiConsentSheetPermission =>
      'Ved at fortsætte giver du udtrykkelig tilladelse til at dele dine fotos med disse AI-udbydere til billedgenerering.';

  @override
  String get skeletonsLoadMoreFailed => 'Kunne ikke indlæse mere.';

  @override
  String get jobsPiecesReadyTitle => 'Dine tøjdele er klar';

  @override
  String get jobsScanStoppedTitle => 'Skanningen stoppede';

  @override
  String get jobsNothingSavedBody => 'Intet blev gemt. Prøv igen.';

  @override
  String get jobsPhotoUploadFailedBody => 'Foto-upload fejlede.';

  @override
  String get authGoogleSignInStartFailed =>
      'Kunne ikke starte Google Sign-In. Prøv venligst igen.';

  @override
  String get referralAppliedTitle => 'Henvisning anvendt!';

  @override
  String get billingStoreUnavailableBody =>
      'Køb i butik er ikke tilgængelige på denne enhed.';

  @override
  String get billingPurchaseProcessingBody =>
      'Dette køb behandles stadig. Åbn appen igen om et minut for at se din plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatar-upload returnerede ingen billed-URL.';

  @override
  String get rewardsDayStreakLabel => 'dages rækkede';

  @override
  String rewardsBestStreak(int days) {
    return 'Bedste $days dage';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission-adgang kræves';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Tilladelse til $permission er for øjeblikket nægtet. Åbn Indstillinger for at tillade det, og prøv derefter igen.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Trin $step af 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Trin $step af $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Fjern billede $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Fjern billede $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Send e-mail til $email. Vi gennemgår anmeldelser inden for 24 timer.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Fjern $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Slet “$name”?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Tilføj til “$name”';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '“$name” er fjernet. Dens dele bliver i din skab.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Vis alle $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count tilbage i dag';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index fejlede';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected af $max fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape kropsbygning · $tone hud';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Slet $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Indstillinger for $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Mest brugt: $name, $count gange';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: ikke indstillet';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked af $max valgt';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Fjern $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency prioritet';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Denne plan faktureres gennem $store. Ændr eller annullér den i dine $store-kontoindstillinger.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Administrér i $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current af $max brugt';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Ca. ${seconds}s tilbage';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done af $total studie-fotos klar';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready af $total studie-fotos klar. Tryk på et stykke for at springe det over.';
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
  String get profileFieldNotSet => 'Ingen';
}
