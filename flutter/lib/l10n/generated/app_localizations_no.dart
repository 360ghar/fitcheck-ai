// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian (`no`).
class AppLocalizationsNo extends AppLocalizations {
  AppLocalizationsNo([String locale = 'no']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Hjem';

  @override
  String get tabPhotoshoot => 'Fotoshoot';

  @override
  String get tabCloset => 'Garderobe';

  @override
  String get tabOutfits => 'Antrekk';

  @override
  String get tabMore => 'Mer';

  @override
  String get actionAddItem => 'Legg til plagg';

  @override
  String get actionCreateOutfit => 'Lag antrekk';

  @override
  String get actionCancel => 'Avbryt';

  @override
  String get actionDelete => 'Slett';

  @override
  String get actionSave => 'Lagre';

  @override
  String get actionRetry => 'Prøv igjen';

  @override
  String get actionDone => 'Ferdig';

  @override
  String get actionNext => 'Neste';

  @override
  String get actionBack => 'Tilbake';

  @override
  String get actionClose => 'Lukk';

  @override
  String get actionSearch => 'Søk';

  @override
  String get actionContinue => 'Fortsett';

  @override
  String get stateLoading => 'Laster';

  @override
  String get stateErrorTitle => 'Noe gikk galt';

  @override
  String get stateErrorBody =>
      'Prøv igjen. Kontakt kundestøtte hvis problemet vedvarer.';

  @override
  String get stateOfflineTitle => 'Du er frakoblet';

  @override
  String get stateOfflineBody =>
      'Koble til for å synkronisere garderoben og generere antrekk.';

  @override
  String get settingsTitle => 'Innstillinger';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsPreferencesSection => 'Preferanser';

  @override
  String get settingsPlanBilling => 'Abonnement og betaling';

  @override
  String get settingsLanguage => 'Språk';

  @override
  String get settingsNotifications => 'Varsler';

  @override
  String get settingsUnits => 'Måleenheter';

  @override
  String get settingsAppearance => 'Utseende';

  @override
  String get settingsPrivacySection => 'Personvern og data';

  @override
  String get settingsAboutSection => 'Om';

  @override
  String get settingsSignOut => 'Logg ut';

  @override
  String get settingsDeleteAccount => 'Slett konto';

  @override
  String get settingsDeleteAccountTitle => 'Slette kontoen din?';

  @override
  String get settingsDeleteAccountBody =>
      'Dette fjerner klesskapet, antrekkene, bildene og profilen din. Dette kan ikke angres.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrisk (cm, kg)';

  @override
  String get languageTitle => 'Språk';

  @override
  String get languageSystem => 'Bruk enhetens språk';

  @override
  String get languageSystemBody => 'FitCheck AI følger telefonens språk.';

  @override
  String get languageSearchHint => 'Søk etter språk';

  @override
  String get languageCurrent => 'Nåværende';

  @override
  String get languageReviewNote =>
      'Denne oversettelsen er ny. Si ifra hvis noe virker feil.';

  @override
  String get languageChanged => 'Språk oppdatert';

  @override
  String get paywallTitle => 'Velg abonnement';

  @override
  String get paywallTrialBadge => '1 måned gratis';

  @override
  String get paywallTrialTitle => 'Din første måned med Pro er gratis';

  @override
  String get paywallTrialBody =>
      'Last opp hele klesskapet med en gang. Legg til plagg etter hvert.';

  @override
  String get paywallFreeForeverTitle => 'Gratis for alltid';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Ingen kort kreves. Hver måned får du $uploads AI-opplastinger, $outfits antrekk og $images fotoshoot-bilder per dag.';
  }

  @override
  String get paywallCtaTrial => 'Start min gratis måned';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Oppgrader til $plan';
  }

  @override
  String get paywallRestore => 'Gjenopprett kjøp';

  @override
  String get paywallManage => 'Administrer abonnement';

  @override
  String get paywallTerms => 'Vilkår for bruk';

  @override
  String get paywallPrivacy => 'Personvernerklæring';

  @override
  String get paywallPerMonth => 'per måned';

  @override
  String get paywallPerYear => 'per år';

  @override
  String get paywallBestValue => 'Beste verdi';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Gratis prøveperiode kun for nye abonnenter. Etter prøveperioden fornyes Pro til $price med mindre den sies opp minst 24 timer før den utløper.';
  }

  @override
  String get introTitle => 'Garderoben din, endelig organisert';

  @override
  String get introBody =>
      'Fotografer klærne dine én gang. Få antrekksideer, prøveroms-forhåndsvisninger og studiobilder av det du allerede eier.';

  @override
  String get introStart => 'Kom i gang';

  @override
  String get introHaveAccount => 'Jeg har allerede en konto';

  @override
  String get introSkip => 'Hopp over';

  @override
  String get authSignIn => 'Logg inn';

  @override
  String get authSignUp => 'Opprett konto';

  @override
  String get authEmail => 'E-post';

  @override
  String get authPassword => 'Passord';

  @override
  String get authForgotPassword => 'Glemt passord?';

  @override
  String get authContinueApple => 'Fortsett med Apple';

  @override
  String get authContinueGoogle => 'Fortsett med Google';

  @override
  String get authOrDivider => 'eller';

  @override
  String get wardrobeTitle => 'Garderobe';

  @override
  String get wardrobeEmptyTitle => 'Garderoben din er tom';

  @override
  String get wardrobeEmptyBody =>
      'Legg til ditt første plagg, eller last opp et bilde av hele klesstativet samtidig.';

  @override
  String get wardrobeAddFirst => 'Legg til første plagg';

  @override
  String get wardrobeSearchHint => 'Søk i garderoben';

  @override
  String get categoryTops => 'Overdeler';

  @override
  String get categoryBottoms => 'Underdeler';

  @override
  String get categoryShoes => 'Sko';

  @override
  String get categoryAccessories => 'Tilbehør';

  @override
  String get categoryOuterwear => 'Yttertøy';

  @override
  String get categorySwimwear => 'Badetøy';

  @override
  String get categoryActivewear => 'Treningsklær';

  @override
  String get categoryOther => 'Annet';

  @override
  String get conditionClean => 'Ren';

  @override
  String get conditionDirty => 'Skitten';

  @override
  String get conditionLaundry => 'Til vask';

  @override
  String get conditionRepair => 'Trenger reparasjon';

  @override
  String get conditionDonate => 'Til donasjon';

  @override
  String get seasonSpring => 'Vår';

  @override
  String get seasonSummer => 'Sommer';

  @override
  String get seasonFall => 'Høst';

  @override
  String get seasonWinter => 'Vinter';

  @override
  String get seasonAll => 'Hele året';

  @override
  String get styleCasual => 'Avslappet';

  @override
  String get styleFormal => 'Formell';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sporty';

  @override
  String get styleBohemian => 'Bohemsk';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistisk';

  @override
  String get styleRomantic => 'Romantisk';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Kunstnerisk';

  @override
  String get styleClassic => 'Klassisk';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Annet';

  @override
  String get occasionWork => 'Jobb';

  @override
  String get occasionDateNight => 'Date';

  @override
  String get occasionTravel => 'Reise';

  @override
  String get occasionWedding => 'Bryllup';

  @override
  String get occasionGym => 'Trening';

  @override
  String get occasionWeekend => 'Helg';

  @override
  String get occasionParty => 'Fest';

  @override
  String get occasionInterview => 'Intervju';

  @override
  String get colorBlack => 'Sort';

  @override
  String get colorWhite => 'Hvit';

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
  String get colorGreen => 'Grønn';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Lilla';

  @override
  String get colorYellow => 'Gul';

  @override
  String get colorOrange => 'Oransje';

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
      other: '$count dager siden',
      one: '1 dag siden',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uker siden',
      one: '1 uke siden',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count måneder siden',
      one: '1 måned siden',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count år siden',
      one: '1 år siden',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Liker du FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'En rask vurdering hjelper andre å finne sin stil.';

  @override
  String get ratingPromptYes => 'Vurder appen';

  @override
  String get ratingPromptNo => 'Ikke nå';

  @override
  String get closetNoMatchesTitle => 'Ingen plagg matcher';

  @override
  String get closetNoMatchesBody => 'Prøv færre filtre eller et annet søk.';

  @override
  String get closetClearFilters => 'Nullstill filtre';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plagg',
      one: '1 plagg',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Laster inn plaggene dine';

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
  String get closetDeleteSelected => 'Slett valgte';

  @override
  String get closetCancelSelection => 'Avbryt valg';

  @override
  String get closetCloseSearch => 'Lukk søk';

  @override
  String get closetShowGrid => 'Vis som rutenett';

  @override
  String get closetShowList => 'Vis som liste';

  @override
  String get closetShowRows => 'Vis som rader';

  @override
  String get closetStatsTitle => 'Garderobestatistikk';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Slette $count plagg?',
      one: 'Slette 1 plagg?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Antrekk som bruker dem, vil miste disse plaggene.';

  @override
  String get closetSortBy => 'Sorter etter';

  @override
  String get closetFavourites => 'Favoritter';

  @override
  String get closetFavourite => 'Favoritt';

  @override
  String get closetUnfavourite => 'Fjern favoritt';

  @override
  String get closetWoreToday => 'Brukt i dag';

  @override
  String closetWornTimes(int count) {
    return 'Brukt $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategori';

  @override
  String get closetUseCaseLabel => 'Bruksområde';

  @override
  String get closetAnyUseCase => 'Alle';

  @override
  String get closetOtherUseCase => 'Annet bruksområde';

  @override
  String get closetOtherUseCaseHint => 'For eksempel lunsj';

  @override
  String get closetUseUseCase => 'Bruk denne';

  @override
  String get closetClearAll => 'Fjern alt';

  @override
  String get sortNewest => 'Nyeste først';

  @override
  String get sortOldest => 'Eldste først';

  @override
  String get sortName => 'Navn (A–Å)';

  @override
  String get sortMostWorn => 'Mest brukt';

  @override
  String get useCaseInformal => 'Uformelt';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Middag';

  @override
  String get useCaseLunch => 'Lunsj';

  @override
  String get actionSelect => 'Velg';

  @override
  String get actionEdit => 'Rediger';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sorter';

  @override
  String get actionAll => 'Alle';

  @override
  String get dashboardStartClosetTitle => 'Start garderoben din';

  @override
  String get dashboardStartClosetBody =>
      'Fotografer noen plagg. Vi tagger dem for deg.';

  @override
  String get dashboardPieces => 'plagg';

  @override
  String get dashboardOutfits => 'antrekk';

  @override
  String get dashboardDayStreak => 'dagers rekke';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count denne måneden';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Beste $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritter',
      one: '1 favoritt',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lagrede antrekk',
      one: '1 lagret antrekk',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Mest brukt: $name, $count ganger';
  }

  @override
  String get setupSkip => 'Hopp over oppsett';

  @override
  String get setupWhoTitle => 'Hvem styler vi?';

  @override
  String get setupWhoBody =>
      'Setter modellen for prøving og fotoshooter. Du kan endre dette i profilen din.';

  @override
  String get setupStyleTitle => 'Hva bruker du mest?';

  @override
  String get setupStyleBody =>
      'Velg hvilken som helst. Antrekksideer tar utgangspunkt i disse.';

  @override
  String get setupClosetTitle => 'Legg til dine første plagg.';

  @override
  String get setupClosetBody =>
      'Fotografer noen klær, eller en haug av dem. Hvert plagg klippes ut og lagres for deg.';

  @override
  String get setupAddClothes => 'Legg til klær';

  @override
  String get setupStylesLabel => 'Stiler';

  @override
  String get setupOccasionsLabel => 'Anledninger';

  @override
  String get setupSkipStep => 'Hopp over';

  @override
  String get setupLater => 'Senere';

  @override
  String get setupSaveError => 'Kunne ikke lagre';

  @override
  String get genderWomen => 'Kvinner';

  @override
  String get genderMen => 'Menn';

  @override
  String get genderNonBinary => 'Ikke-binær';

  @override
  String get genderPreferNotToSay => 'Vil ikke oppgi';

  @override
  String get outfitEmptyTitle => 'Ingen antrekk ennå';

  @override
  String get outfitEmptyBody =>
      'Kombiner plagg fra garderoben din og lagre looken.';

  @override
  String get outfitNoMatchesTitle => 'Ingen antrekk matcher';

  @override
  String get outfitSearchHint => 'Søk i antrekkene dine';

  @override
  String get outfitLoading => 'Laster antrekkene dine';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count antrekk',
      one: '1 antrekk',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Stil og sesong';

  @override
  String get outfitCollections => 'Samlinger';

  @override
  String get outfitDuplicate => 'Dupliser';

  @override
  String get outfitDeleteTitle => 'Slette dette antrekket?';

  @override
  String get outfitDeleteBody => 'Plaggene forblir i garderoben din.';

  @override
  String get outfitDrafts => 'Utkast';

  @override
  String get outfitDraft => 'Utkast';

  @override
  String get filterStyle => 'Stil';

  @override
  String get filterSeason => 'Sesong';

  @override
  String get itemDetailDeleteTitle => 'Slett dette plagget?';

  @override
  String get itemDetailDeleteBody =>
      'Antrekk som bruker det, vil miste dette plagget.';

  @override
  String get itemAddFavourite => 'Legg til i favoritter';

  @override
  String itemSize(String size) {
    return 'Størrelse $size';
  }

  @override
  String get itemColours => 'Farger';

  @override
  String get itemMaterial => 'Materiale';

  @override
  String get itemPattern => 'Mønster';

  @override
  String get itemUseCases => 'Bruksområder';

  @override
  String get itemKeptIn => 'Oppbevart i';

  @override
  String get itemPrice => 'Pris';

  @override
  String get itemBought => 'Kjøpt';

  @override
  String get itemTags => 'Etiketter';

  @override
  String get itemAdded => 'Lagt til';

  @override
  String get itemTimesWornLabel => 'ganger brukt';

  @override
  String get itemLastWornLabel => 'sist brukt';

  @override
  String get itemNeverWorn => 'Aldri';

  @override
  String get authEntryBody =>
      'Hvert eneste plagg du eier, satt sammen av AI. Planlegg antrekk, prøv dem på, ta bilder.';

  @override
  String get authCreateCloset => 'Opprett garderoben din';

  @override
  String get authWelcomeBack => 'Velkommen tilbake';

  @override
  String get authSignInBody => 'Logg inn for å åpne garderoben din.';

  @override
  String get authCreateAccount => 'Opprett en konto';

  @override
  String get authCreateClosetBody =>
      'Det tar ett minutt. Dine første plagg er gratis.';

  @override
  String get authName => 'Navn';

  @override
  String get authConfirmPassword => 'Bekreft passord';

  @override
  String get authReferralCode => 'Vervekode (valgfritt)';

  @override
  String get authResetTitle => 'Tilbakestill passordet ditt';

  @override
  String get authResetBody =>
      'Vi sender deg en lenke på e-post for å velge et nytt.';

  @override
  String get authSendResetLink => 'Send tilbakestillingslenke';

  @override
  String get authBackToSignIn => 'Tilbake til innlogging';

  @override
  String get authEnterEmail => 'Skriv inn e-posten din';

  @override
  String get authEnterValidEmail => 'Skriv inn en gyldig e-post';

  @override
  String get authEnterPassword => 'Skriv inn passordet ditt';

  @override
  String get authPasswordTooShort => 'Minst 6 tegn';

  @override
  String get authShowPassword => 'Vis passord';

  @override
  String get authHidePassword => 'Skjul passord';

  @override
  String get authNewHere => 'Ny her?';

  @override
  String authConfirmEmail(String email) {
    return 'Bekreft $email før du logger inn. Sjekk innboksen din.';
  }

  @override
  String get authResendEmail => 'Send den igjen';

  @override
  String get authResendingEmail => 'Sender…';

  @override
  String get authPasswordsDoNotMatch => 'Passordene er ikke like';

  @override
  String get authEnterName => 'Skriv inn navnet ditt';

  @override
  String get authChoosePassword => 'Velg et passord';

  @override
  String get authHaveAccount => 'Har du en konto?';

  @override
  String get authCodeAccepted => 'Kode godkjent';

  @override
  String get authCodeNotFound => 'Fant ikke koden';

  @override
  String authReferralFrom(String name) {
    return 'Fra $name. Dere får en måned gratis hver.';
  }

  @override
  String get authReferralInvalid => 'Vi fant ikke denne koden.';

  @override
  String authResetSent(String email) {
    return 'Sendt til $email. Åpne lenken på denne telefonen.';
  }

  @override
  String get introSlide1Title => 'Knips garderoben din én gang.';

  @override
  String get introSlide1Body =>
      'Ta bilde av en haug med klær. Plaggene blir kuttet ut og arkivert for deg.';

  @override
  String get introSlide2Title => 'Kle på deg raskere.';

  @override
  String get introSlide2Body =>
      'Antrekk fra det du eier, tilpasset planene dine og været.';

  @override
  String get introSlide3Title => 'Se det før du har det på.';

  @override
  String get introSlide3Body =>
      'Prøv stiler på ditt eget bilde, eller ta bilder som en kampanje.';

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
  String get settingsEmailUpdates => 'E-postoppdateringer';

  @override
  String get settingsEmailUpdatesBody => 'Nyheter og tips på e-post';

  @override
  String get settingsOutfitReminders => 'Antrekksminnelser';

  @override
  String get settingsOutfitRemindersBody =>
      'En påminnelse om å logge hva du hadde på deg';

  @override
  String get settingsWeeklySummary => 'Ukessammendrag';

  @override
  String get settingsWeeklySummaryBody => 'Uken din i antrekk';

  @override
  String get settingsStyleSection => 'Stil';

  @override
  String get settingsPreferredStyles => 'Stiler du liker';

  @override
  String get settingsPreferredColours => 'Farger du liker';

  @override
  String get settingsNoneChosen => 'Ingen valgt';

  @override
  String get settingsPlanAiSection => 'Abonnement og KI';

  @override
  String get settingsPlanBillingBody => 'Abonnement, bruk og oppgraderinger';

  @override
  String get settingsPlanUsageBody => 'Abonnement og bruk';

  @override
  String get settingsInviteFriends => 'Inviter venner';

  @override
  String get settingsInviteFriendsBody =>
      'En gratis måned for hver venn som blir med';

  @override
  String get settingsAiProvider => 'KI-leverandør';

  @override
  String get settingsAiProviderBody =>
      'Bruk din egen modell for merking og bilder';

  @override
  String get settingsAppVersion => 'Appversjon';

  @override
  String get settingsPrivacyTerms => 'Personvern og vilkår';

  @override
  String get settingsReportProblem => 'Rapporter et problem';

  @override
  String get settingsChangePassword => 'Endre passord';

  @override
  String get settingsExportData => 'Eksporter dataene dine';

  @override
  String get settingsExportBody =>
      'Vi klargjør en fil med alt du har lagret, og åpner nedlastingen.';

  @override
  String get settingsExportAction => 'Eksporter';

  @override
  String get settingsCurrentPassword => 'Nåværende passord';

  @override
  String get settingsNewPassword => 'Nytt passord';

  @override
  String get settingsConfirmNewPassword => 'Bekreft nytt passord';

  @override
  String get settingsEnterCurrentPassword => 'Skriv inn ditt nåværende passord';

  @override
  String get settingsEnterNewPassword => 'Skriv inn et nytt passord';

  @override
  String get settingsPasswordMin8 => 'Bruk minst 8 tegn';

  @override
  String get settingsPasswordNeedsUpper => 'Legg til en stor bokstav';

  @override
  String get settingsPasswordNeedsLower => 'Legg til en liten bokstav';

  @override
  String get settingsPasswordNeedsDigit => 'Legg til et tall';

  @override
  String get settingsPasswordsNoMatch => 'Passordene er ikke like';

  @override
  String get settingsChangeAction => 'Endre';

  @override
  String get itemAddSnapTitle => 'Ta bilde av et plagg';

  @override
  String get itemAddSnapBody =>
      'Vi finner alle plaggene på bildet og lager et rent studiobilde av hvert enkelt.';

  @override
  String get itemAddCamera => 'Ta et bilde';

  @override
  String get itemAddGallery => 'Velg fra galleri';

  @override
  String get itemAddOtherWays => 'Andre måter å legge til på';

  @override
  String get itemAddSeveral => 'Legg til flere bilder';

  @override
  String get itemAddSeveralBody => 'Opptil 50 samtidig';

  @override
  String get itemAddImportProfile => 'Importer fra en profil';

  @override
  String get itemAddImportProfileBody => 'Instagram eller Facebook';

  @override
  String get itemAddEnterDetails => 'Skriv inn detaljer selv';

  @override
  String get itemAddEnterDetailsBody => 'Ingen bilde nødvendig';

  @override
  String get itemManualIntro =>
      'Bare et navn er nødvendig. Legg til resten nå eller senere.';

  @override
  String get itemManualNameHint => 'For eksempel blå bomulls-T-skjorte';

  @override
  String get itemManualEnterName => 'Skriv inn et navn';

  @override
  String get itemManualNotes => 'Notater';

  @override
  String get itemManualBrand => 'Merke';

  @override
  String get itemManualSize => 'Størrelse';

  @override
  String get itemManualEnterNumber => 'Skriv inn et tall';

  @override
  String get itemManualSavePiece => 'Lagre plagg';

  @override
  String get itemManualSaving => 'Lagrer';

  @override
  String get itemManualSavedTitle => 'Lagret';

  @override
  String itemManualSavedBody(String name) {
    return '$name er i skapet ditt.';
  }

  @override
  String get itemManualNotSaved => 'Ikke lagret';

  @override
  String get itemManualAddUseCase => 'Legg til bruksområde';

  @override
  String get itemManualAddUseCaseAction => 'Legg til bruksområde';

  @override
  String get itemPhotos => 'Bilder';

  @override
  String get itemAddPhotos => 'Legg til bilder';

  @override
  String get itemNoPhotoYet => 'Ingen bilder ennå. Du kan lagre uten.';

  @override
  String get itemRemovePhoto => 'Fjern bilde';

  @override
  String get itemRemovePiece => 'Fjernplagg';

  @override
  String get filterConditionLabel => 'Tilstand';

  @override
  String get photoshootStepPhotos => 'Bilder';

  @override
  String get photoshootStepSetup => 'Oppsett';

  @override
  String get photoshootStepCreating => 'Oppretter';

  @override
  String get photoshootStepResults => 'Resultater';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Steg $current av $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Et bilde feilet. Prøv igjen under.';

  @override
  String photoshootManyFailed(int count) {
    return '$count bilder feilet. Prøv igjen under.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Hvor mange';

  @override
  String get photoshootYourPrompt => 'Din beskrivelse';

  @override
  String get photoshootPromptHint => 'Gylne time på et tak, linskjorte';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lag $count bilder',
      one: 'Lag 1 bilde',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bilder',
      one: 'bilde',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Vi kunne ikke sjekke dagens grense.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan-abonnement: $remaining av $limit igjen i dag';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratis';

  @override
  String get photoshootGallery => 'Galleri';

  @override
  String get photoshootUseCamera => 'Bruk kamera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Fjern bilde $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Ingen bilder returnerte';

  @override
  String get photoshootNoPhotosBody =>
      'Fotograferingen ble ferdig uten bilder. Prøv igjen.';

  @override
  String get photoshootNewStyle => 'Ny stil';

  @override
  String get photoshootNewPhotos => 'Nye bilder';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Åpne bilde $number';
  }

  @override
  String get photoshootReportPhoto => 'Rapporter bilde';

  @override
  String get photoshootSaveToGallery => 'Lagre i galleri';

  @override
  String get actionUpgrade => 'Oppgrader';

  @override
  String get referralLimitTitle => 'Du har brukt dagens bilder';

  @override
  String get referralLimitBody =>
      'Gratisbildene dine kommer tilbake i morgen. Verv en venn og få en måned Pro gratis begge to.';

  @override
  String get referralLimitRefer => 'Verv en venn';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating-app';

  @override
  String get photoshootUsePortfolio => 'Portefølje';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetisk';

  @override
  String get photoshootUseCustom => 'Din egen ledetekst';

  @override
  String get photoshootDescLinkedin => 'Skarpe portrettbilder for jobb';

  @override
  String get photoshootDescDating => 'Avslappet, varmt og naturlig';

  @override
  String get photoshootDescPortfolio => 'Redaksjonelle motebilder';

  @override
  String get photoshootDescInstagram => 'Livsstilbilder for feeden din';

  @override
  String get photoshootDescAesthetic => 'Stemningsfulle, kunstneriske rammer';

  @override
  String get photoshootDescCustom => 'Beskriv stilen du vil ha';

  @override
  String get aspectSquare => 'Kvadratisk';

  @override
  String get aspectPortrait => 'Portrett';

  @override
  String get aspectLandscape => 'Landskap';

  @override
  String get aspectTall => 'Høy';

  @override
  String get aspectWide => 'Bred';

  @override
  String get tryOnAppBar => 'Virtuell prøving';

  @override
  String get tryOnYourPhoto => 'Bildet ditt';

  @override
  String get tryOnGarment => 'Plagg';

  @override
  String get tryOnUploadingPhoto => 'Laster opp bildet ditt';

  @override
  String get tryOnAddPhotoPrompt => 'Legg til et helfigursbilde av deg selv';

  @override
  String get tryOnBodyPhotoHint => 'Et helfigursbilde fungerer best';

  @override
  String get tryOnAddPhoto => 'Legg til bilde';

  @override
  String get tryOnChangePhoto => 'Endre bilde';

  @override
  String get tryOnPhotoLoadFailed => 'Vi kunne ikke laste inn bildet ditt.';

  @override
  String get tryOnChooseGarment => 'Velg et plaggbilde';

  @override
  String get tryOnChooseOneGarment => 'Velg ett plaggbilde';

  @override
  String get tryOnGarmentHint =>
      'Et flatt bilde eller på hengeklesheng fungerer best';

  @override
  String get tryOnChange => 'Endre';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Fjern';

  @override
  String get tryOnLookTitle => 'Stil';

  @override
  String get tryOnStyle => 'Stil';

  @override
  String get tryOnBackground => 'Bakgrunn';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp => 'Kler på deg. Dette tar ca. et halvt minutt.';

  @override
  String get tryOnEmptyResult => 'Prøvingen din dukker opp her';

  @override
  String get tryOnReportImage => 'Rapporter bilde';

  @override
  String get tryOnCreating => 'Lager';

  @override
  String get tryOnTryAgain => 'Prøv igjen';

  @override
  String get tryOnCreate => 'Lag prøving';

  @override
  String get tryOnBackgroundStudioWhite => 'Studiohvit';

  @override
  String get tryOnBackgroundStudioGrey => 'Studiogrå';

  @override
  String get tryOnBackgroundUrban => 'Bygate';

  @override
  String get tryOnBackgroundNature => 'Natur';

  @override
  String get tryOnBackgroundMinimal => 'Minimalistisk';

  @override
  String get tryOnPoseFront => 'Stående forfra';

  @override
  String get tryOnPoseSide => 'Stående fra siden';

  @override
  String get tryOnPoseWalking => 'Gående';

  @override
  String get dashboardGreetingMorning => 'God morgen';

  @override
  String get dashboardGreetingAfternoon => 'God ettermiddag';

  @override
  String get dashboardGreetingEvening => 'God kveld';

  @override
  String get dashboardWelcome => 'Velkommen';

  @override
  String get dashboardOpenProfile => 'Åpne profil';

  @override
  String get dashboardRailToday => 'I dag';

  @override
  String get dashboardRailRecently => 'Nylige';

  @override
  String get dashboardActivityEmpty => 'Nye plagg og antrekk vises her.';

  @override
  String get quickAddPiece => 'Legg til plagg';

  @override
  String get quickAddPieceBody => 'Ta bilde og merk';

  @override
  String get quickBuildOutfit => 'Sett sammen antrekk';

  @override
  String get quickBuildOutfitBody => 'Kombiner plaggene dine';

  @override
  String get quickForYou => 'For deg';

  @override
  String get quickForYouBody => 'Dagens utvalg';

  @override
  String get quickPlanWeek => 'Planlegg uken';

  @override
  String get quickPlanWeekBody => 'Antrekk etter dato';

  @override
  String get referralBannerUrgent => 'Lite igjen? Inviter en venn.';

  @override
  String get referralBannerTitle => 'Gi en måned, få en måned.';

  @override
  String get referralBannerBody =>
      'Du og vennen din får en måned med Pro hver.';

  @override
  String get referralBannerDismiss => 'Skjul i en uke';

  @override
  String get referralBannerShare => 'Del invitasjon';

  @override
  String get referralBannerCopy => 'Kopier lenke';

  @override
  String get itemEditPieceTitle => 'Rediger plagg';

  @override
  String get itemEditDescriptionLabel => 'Beskrivelse';

  @override
  String get itemEditNotSaved => 'Ikke lagret';

  @override
  String get itemEditSavedTitle => 'Lagret';

  @override
  String get itemEditSavedBody => 'Endringene dine er lagret.';

  @override
  String get itemEditSavedStalePhotos => 'Lagret – bildene kan være utdaterte';

  @override
  String get itemEditRemovePieceHint => 'Slett dette plagget fra produktsiden.';

  @override
  String get itemEditNoPhotos =>
      'Ingen bilder ennå. Legg til et fra galleriet eller kameraet.';

  @override
  String get itemEditKeepPhoto => 'Behold bilde';

  @override
  String get itemEditRemoved => 'Fjernet';

  @override
  String get itemEditAddUseCaseAction => 'Legg til';

  @override
  String get statsNoStatsTitle => 'Ingen statistikk ennå';

  @override
  String get statsNoStatsBody =>
      'Legg til noen plagg, så vises garderobesammensetningen her.';

  @override
  String get statsByCategory => 'Etter kategori';

  @override
  String get statsTotalValue => 'totalverdi';

  @override
  String get statsMostWorn => 'Mest brukt';

  @override
  String get statsLeastWorn => 'Venter på tur';

  @override
  String get statsUnnamedPiece => 'Uten navn';

  @override
  String get jobsTitle => 'Skanninger';

  @override
  String get jobsEmptyTitle => 'Ingen skanninger ennå';

  @override
  String get jobsEmptyBody =>
      'Ta bilde av et plagg og send det til bakgrunnen – det fortsetter å jobbe her.';

  @override
  String get jobsNotCancelled => 'Ikke avbrutt';

  @override
  String get jobsResume => 'Fortsett';

  @override
  String get jobsReview => 'Gjennomgå';

  @override
  String get jobsStop => 'Stopp';

  @override
  String get jobsDismiss => 'Lukk';

  @override
  String get reportTitle => 'Rapporter innhold';

  @override
  String reportIntro(String contentType) {
    return 'Fortell oss hva som er galt med dette $contentType. Teamet vårt går gjennom alle rapporter.';
  }

  @override
  String get reportReasonInappropriate => 'Upassende eller støtende';

  @override
  String get reportReasonNudity => 'Nakenhet eller seksuelt innhold';

  @override
  String get reportReasonHarassment => 'Trakassering eller misbruk';

  @override
  String get reportReasonImpersonation => 'Utgir seg for å være andre';

  @override
  String get reportReasonOther => 'Annet';

  @override
  String get reportDetailsLabel => 'Flere detaljer (valgfritt)';

  @override
  String get reportSubmit => 'Send rapport';

  @override
  String get reportSubmittedTitle => 'Rapport sendt';

  @override
  String get reportSubmittedBody =>
      'Takk. Teamet vårt vil gå gjennom innholdet.';

  @override
  String get reportFailedTitle => 'Kunne ikke sende rapport';

  @override
  String get reportFailedBody => 'Vennligst prøv igjen.';

  @override
  String get reportContentTryOnImage => 'AI-prøvebilde';

  @override
  String get reportContentSharedOutfit => 'delt antrekk';

  @override
  String get reportContentPhotoshootImage => 'AI-fotoshootbilde';

  @override
  String get sharedOutfitTitle => 'Delt antrekk';

  @override
  String get sharedOutfitHideTooltip => 'Skjul dette antrekket';

  @override
  String get sharedOutfitReportTooltip => 'Rapporter dette antrekket';

  @override
  String get sharedOutfitHideTitle => 'Skjul dette antrekket?';

  @override
  String get sharedOutfitHideBody =>
      'Det forblir skjult på denne enheten. Du kan også rapportere det slik at teamet vårt kan vurdere og fjerne det.';

  @override
  String get sharedOutfitHideAction => 'Skjul';

  @override
  String get sharedOutfitHiddenInfo =>
      'Dette antrekket vil ikke vises på denne enheten igjen.';

  @override
  String get sharedOutfitHiddenToast => 'Antrekk skjult';

  @override
  String get sharedOutfitMissingTitle =>
      'Dette antrekket er ikke lenger tilgjengelig';

  @override
  String get sharedOutfitMissingBody =>
      'Det kan ha blitt fjernet, eller lenken er feil.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Du har skjult dette antrekket';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Hvis det var upassende, rapporter det under Personvern og vilkår eller send e-post til $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Liker du stilen?';

  @override
  String get sharedOutfitCtaBody =>
      'Lag lignende antrekk fra din egen garderobe.';

  @override
  String get sharedOutfitCtaButton => 'Skaff FitCheck AI';

  @override
  String get errorTitle => 'Feil';

  @override
  String get errorUnknown => 'Det oppstod en uventet feil';

  @override
  String get errorNoConnection =>
      'Ingen internettforbindelse. Sjekk nettverket ditt.';

  @override
  String get errorTimeout => 'Tidsavbrudd for forespørsel. Prøv igjen.';

  @override
  String get errorServerError => 'Noen gikk galt i vår ende. Prøv igjen.';

  @override
  String get errorBadGateway =>
      'Serveren vår er utilgjengelig et øyeblikk. Prøv igjen.';

  @override
  String get errorServiceUnavailable =>
      'Tjenesten er midlertidig utilgjengelig. Prøv igjen snart.';

  @override
  String get errorInternalError => 'Noe gikk galt. Prøv igjen.';

  @override
  String get errorUnauthorized => 'Logg inn for å fortsette.';

  @override
  String get errorForbidden => 'Du har ikke tilgang til dette.';

  @override
  String get errorSessionExpired => 'Økten din har utløpt. Logg inn igjen.';

  @override
  String get errorInvalidCredentials => 'E-posten eller passordet er feil.';

  @override
  String get errorTokenRefreshFailed =>
      'Kunne ikke fornye økten. Logg inn igjen.';

  @override
  String get errorRequestCancelled => 'Forespørsel avbrutt.';

  @override
  String get errorInvalidFormat => 'Filformatet støttes ikke.';

  @override
  String get errorFileTooLarge => 'Filen er for stor.';

  @override
  String get errorUploadFailed => 'Opplasting feilet. Prøv igjen.';

  @override
  String get errorCacheCorrupted =>
      'Lagrede data ble skadet og har blitt tilbakestilt.';

  @override
  String get errorCacheNotFound => 'Ingenting er lagret ennå.';

  @override
  String get errorUserNotFound => 'Vi fant ikke den kontoen.';

  @override
  String get errorItemNotFound => 'Dette plagget finnes ikke lenger.';

  @override
  String get errorOutfitNotFound => 'Dette antrekket finnes ikke lenger.';

  @override
  String get rewardsTitle => 'Belønninger';

  @override
  String get rewardsNoAchievementsTitle => 'Ingen prestasjoner ennå';

  @override
  String get rewardsNoAchievementsBody =>
      'Legg til plagg og planlegg antrekk for å få din første.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Ingen på tavlen ennå';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planlegg antrekk for å samle poeng og vises her.';

  @override
  String get legalViewPrivacyPolicy => 'Vis personvernerklæring';

  @override
  String get aiConsentAgree => 'Godta og fortsett';

  @override
  String get aiConsentNotNow => 'Ikke nå';

  @override
  String get imageViewerCloseTooltip => 'Lukk bildevisning';

  @override
  String get updateReadyTitle => 'Oppdatering klar';

  @override
  String get updateReadyBody =>
      'Start FitCheck AI på nytt for å bruke de siste forbedringene.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI trenger kameratilgang for å ta bilder av antrekkene dine og plaggene i garderoben.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI trenger tilgang til bildebiblioteket for å velge bilder av antrekkene dine og plaggene i garderoben.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI må lagre de KI-genererte antrekksbildene dine i bildebiblioteket.';

  @override
  String get wardrobeSomePhotosSkipped => 'Noen bilder ble hoppet over';

  @override
  String get wardrobePhotosNotAdded => 'Bilder ikke lagt til';

  @override
  String get wardrobePhotoNotAdded => 'Bilde ikke lagt til';

  @override
  String get wardrobeNotStartedTitle => 'Ikke startet';

  @override
  String get wardrobeNoRoomTitle => 'Ingen plass';

  @override
  String get wardrobeAddPhotosSemantic => 'Legg til bilder';

  @override
  String get batchAddTileLabel => 'Legg til';

  @override
  String get batchProfileLinkLabel => 'Profil-lenke';

  @override
  String get wardrobeImportFromProfileTitle => 'Importer fra en profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Legg til flere bilder';

  @override
  String get wardrobeClearAction => 'Fjern';

  @override
  String get wardrobeRefreshTooltip => 'Oppdater';

  @override
  String get batchNoPhotosYetTitle => 'Ingen bilder ennå';

  @override
  String get batchChoosePhotosAction => 'Velg bilder';

  @override
  String get batchWeFindEachPieceBody =>
      'Vi finner hvert enkelt plagg og lager et studiobilde av det.';

  @override
  String get batchPreparingPhotosSemantic => 'Forbereder bilder';

  @override
  String get batchPhotosProcessedSemantic => 'Bilder behandlet';

  @override
  String get batchPasteProfileLinkTitle => 'Lim inn en profil-lenke';

  @override
  String get batchPasteProfileLinkBody =>
      'En offentlig Instagram- eller Facebook-profil. Vi skanner bildene, og du velger hva som skal i skapet.';

  @override
  String get batchClearLinkTooltip => 'Fjern lenke';

  @override
  String get batchStartingButton => 'Starter';

  @override
  String get batchStartImportAction => 'Start import';

  @override
  String get batchReviewEveryPhotoTitle => 'Du ser gjennom hvert bilde';

  @override
  String get batchReviewEveryPhotoBody =>
      'Ingenting legges til før du godkjenner det.';

  @override
  String get batchPrivateProfilesTitle => 'Private profiler';

  @override
  String get batchPrivateProfilesBody =>
      'Koble til kontoen din. Instagram krever også brukernavn og passord.';

  @override
  String get batchUseAnotherLinkAction => 'Bruk en annen lenke';

  @override
  String get batchSignInNeededTitle => 'Innlogging kreves';

  @override
  String get batchEnterYourCodeTitle => 'Skriv inn koden din';

  @override
  String get batchUseUsernamePasswordAction => 'Bruk brukernavn og passord';

  @override
  String get batchAlreadyConnectedAction =>
      'Jeg har allerede koblet til i nettleseren';

  @override
  String get batchEnterCodeAction => 'Skriv inn kode';

  @override
  String get batchTryAnotherWayAction => 'Prøv en annen måte';

  @override
  String get batchLiveStatus => 'Direkte';

  @override
  String get batchReconnectingStatus => 'Kobler til på nytt';

  @override
  String get batchSignInToInstagramTitle => 'Logg på Instagram';

  @override
  String get batchUsernameLabel => 'Brukernavn';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kode, hvis du bruker totrinnsbekreftelse';

  @override
  String get batchAuthenticatorCodeBody =>
      'Bruk den 6-sifrede koden fra autentiseringsappen din. Koder endres raskt.';

  @override
  String get batchVerifyAction => 'Bekreft';

  @override
  String get batchFindingPhotosTitle => 'Finner bilder';

  @override
  String get batchImportPausedTitle => 'Import satt på pause';

  @override
  String get batchProcessingPhotosTitle => 'Behandler bilder';

  @override
  String get batchWaitingNextPhoto => 'Venter på neste bilde';

  @override
  String get batchCancelImportAction => 'Avbryt import';

  @override
  String get batchNoPiecesInPhotoBody => 'Ingen plagg funnet på dette bildet.';

  @override
  String get batchEditPieceColoursLabel => 'Farger, adskilt med komma';

  @override
  String get batchAddToClosetAction => 'Legg til i garderoben';

  @override
  String get batchSkipPhotoAction => 'Hopp over dette bildet';

  @override
  String get batchImportCompleteTitle => 'Import fullført';

  @override
  String get batchImportFailedTitle => 'Import mislyktes';

  @override
  String get batchImportCancelledTitle => 'Import avbrutt';

  @override
  String get batchImportErrorBody => 'Noe gikk galt under importen.';

  @override
  String get batchNothingMoreImportedBody =>
      'Ingenting mer importeres fra denne profilen.';

  @override
  String get batchViewClosetAction => 'Vis garderobe';

  @override
  String get batchStartOverAction => 'Start på nytt';

  @override
  String get wardrobeAddPieceTitle => 'Legg til plagg';

  @override
  String get wardrobeAddDetailsTitle => 'Legg til detaljer';

  @override
  String get wardrobeScanningTitle => 'Skanner';

  @override
  String get batchReviewPiecesTitle => 'Se over plagg';

  @override
  String get wardrobeGalleryAction => 'Galleri';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Ny';

  @override
  String get wardrobeRemovePhotoTooltip => 'Fjern bilde';

  @override
  String get batchRunInBackgroundTooltip => 'Kjør i bakgrunnen';

  @override
  String get batchStepOneOfTwo => 'Steg 1 av 2';

  @override
  String get batchStepTwoOfTwo => 'Steg 2 av 2';

  @override
  String get batchUploadingPhotosTitle => 'Laster opp bilder';

  @override
  String get batchFindingPiecesTitle => 'Finder plagg';

  @override
  String get batchMakingStudioPhotosTitle => 'Lager studiobilder';

  @override
  String get batchStoppedLabel => 'Stanset';

  @override
  String get batchFindingPiecesStoppedTitle => 'Plaggsøk stanset';

  @override
  String get batchCancelledLabel => 'Avbrutt';

  @override
  String get batchAllDoneTitle => 'Alt ferdig';

  @override
  String get batchOpeningPiecesBody => 'Åpner plaggene dine';

  @override
  String get batchNothingSavedBody => 'Ingenting ble lagret.';

  @override
  String get batchFindingPiecesFailedBody => 'Kunne ikke finne plagg.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Plaggsøk ble avsluttet tidlig.';

  @override
  String get batchStopFindingPiecesTitle => 'Vil du stoppe plaggsøk?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skanningen stopper og ingenting lagres. Plagg som allerede er funnet, forblir i aktiviteten din til du lukker dem.';

  @override
  String get batchKeepGoingAction => 'Fortsett';

  @override
  String get batchTryAgainAction => 'Prøv igjen';

  @override
  String get batchBackToPhotosAction => 'Tilbake til bilder';

  @override
  String get batchSkipAllAction => 'Hopp over alle';

  @override
  String get batchIncludeAllAction => 'Inkluder alle';

  @override
  String get batchNoPiecesFoundTitle => 'Ingen plagg funnet';

  @override
  String get batchNoPiecesFoundBody => 'Vi fant ingen klær på disse bildene.';

  @override
  String get batchChooseOtherPhotosAction => 'Velg andre bilder';

  @override
  String get batchUseCaseHelper => 'Lagt til hvert plagg du lagrer.';

  @override
  String get batchDiscardPiecesTitle => 'Forkaste disse plaggene?';

  @override
  String get batchDiscardPiecesBody =>
      'Ingenting fra denne batchen blir lagret.';

  @override
  String get batchKeepAction => 'Behold';

  @override
  String get batchDiscardAction => 'Forkast';

  @override
  String get batchRemovePieceTitle => 'Fjerne dette plagget?';

  @override
  String get batchRemovePieceBody => 'Det er ikke lagret i garderoben din.';

  @override
  String get batchRemoveAction => 'Fjern';

  @override
  String get batchChoosePiecesToSave => 'Velg plagg å lagre';

  @override
  String get batchDiscardAllAction => 'Forkast alle';

  @override
  String get batchNothingSavedRetryBody => 'Ingenting ble lagret. Prøv igjen.';

  @override
  String get batchNotSavedTitle => 'Ikke lagret';

  @override
  String get batchSavingLabel => 'Lagrer';

  @override
  String get batchSendToBackgroundAction => 'Kjør i bakgrunnen';

  @override
  String get batchStillWorkingMessage =>
      'Jobber fremdeles. Vi sier ifra når plaggene dine er klare.';

  @override
  String get batchRunningInBackgroundTitle => 'Kjører i bakgrunnen';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studiobilder stoppet for tidlig. Du kan fortsatt lagre disse plaggene.';

  @override
  String get batchTapPieceToSkip => 'Trykk på et plagg for å hoppe over det.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studiobilder er på vei. Du kan gå ut – vi gir deg beskjed.';

  @override
  String get batchLeaveAction => 'Forlat';

  @override
  String get batchPeopleInPhotosTitle => 'Personer på bildene';

  @override
  String get batchIncludeAction => 'Inkluder';

  @override
  String get batchSkipAction => 'Hopp over';

  @override
  String get batchYourPhotoIsUsedLabel => 'Bildet ditt brukes';

  @override
  String get batchMakingStudioPhotoLabel => 'Lager studiobilde';

  @override
  String get batchNoStudioPhotoBody => 'Ingen studiobilde. Bildet ditt brukes.';

  @override
  String get batchEnterDetailsYourselfAction => 'Legg inn detaljer selv';

  @override
  String get batchChooseAnotherPhotoAction => 'Velg et annet bilde';

  @override
  String get batchConnectionLostTitle => 'Tilkoblingen brutt';

  @override
  String get batchConnectionLostBody => 'Sjekk tilkoblingen og prøv igjen.';

  @override
  String get batchDailyLimitTitle => 'Daglig grense nådd';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Oppgrader til Pro for flere skanninger, eller legg inn detaljene selv.';

  @override
  String get batchDailyLimitBodyFree =>
      'Skanningene dine tilbakestilles i morgen. Du kan legge inn detaljene selv nå.';

  @override
  String get batchSeePlansAction => 'Se abonnementer';

  @override
  String get batchAiBusyTitle => 'Kunstig intelligens har mye å gjøre';

  @override
  String get batchAiBusyBody =>
      'Dette skyldes oss. Prøv igjen om noen minutter.';

  @override
  String get batchNoPiecesBody =>
      'Prøv et tydeligere bilde, eller legg inn detaljene selv.';

  @override
  String get batchScanningUnavailableTitle => 'Skanning er utilgjengelig';

  @override
  String get batchScanningUnavailableBody =>
      'Legg inn detaljene selv så lenge.';

  @override
  String get batchScanDidNotFinishTitle => 'Skanningen ble ikke fullført';

  @override
  String get batchTryAgainBody => 'Prøv igjen.';

  @override
  String get billingTitle => 'Abonnement';

  @override
  String get billingUpgradeHeading => 'Oppgrader abonnementet ditt';

  @override
  String get billingUpgradeOnPlusBody => 'Samme funksjoner, høyere grenser.';

  @override
  String get billingUpgradeBody =>
      'Plus og Pro har de samme funksjonene. Velg grensene du trenger.';

  @override
  String get billingWebUnavailableBody =>
      'Nettbaserte oppgraderinger er ikke tilgjengelige ennå. En kampanje- eller vervekode låser fremdeles opp Plus eller Pro. Inviter venner nedenfor for å få gratis måneder.';

  @override
  String get billingPlansStale =>
      'Kunne ikke laste inn de nyeste planene. Prisene kan være utdaterte.';

  @override
  String get billingMonthly => 'Månedlig';

  @override
  String get billingYearly => 'Årlig';

  @override
  String get billingCurrentPlan => 'Nåværende abonnement';

  @override
  String get billingActive => 'Aktiv';

  @override
  String get billingThisMonth => 'Denne måneden';

  @override
  String get billingItemExtractions => 'Plaggtrekking';

  @override
  String get billingOutfitVisualizations => 'Antrekksvisualiseringer';

  @override
  String get billingNearLimitUpgrade =>
      'Du er nær månedens grense. Oppgrader for mer.';

  @override
  String get billingNearLimitResets =>
      'Du er nær månedens grense. Den tilbakestilles ved starten av neste måned.';

  @override
  String get billingStoreUnavailable =>
      'Oppgraderinger er ikke tilgjengelige i butikken ennå. Sjekk igjen snart.';

  @override
  String get billingManageHeading => 'Administrer abonnementet';

  @override
  String get billingCancelPlan => 'Avbryt abonnement';

  @override
  String get billingCancelKeepsAccess =>
      'Du beholder tilgangen til slutten av denne abonnementsperioden.';

  @override
  String get billingCancelConfirmTitle => 'Vil du avbryte abonnementet?';

  @override
  String get billingKeepPlan => 'Behold abonnement';

  @override
  String get billingCancelPlanAction => 'Avbryt abonnement';

  @override
  String get billingBilledMonthly => 'Faktureres månedlig';

  @override
  String get billingBilledYearly => 'Faktureres årlig';

  @override
  String get billingVirtualTryOn => 'Virtuell prøving';

  @override
  String get billingPrioritySupport => 'Prioritert støtte';

  @override
  String get billingDisclosureProRenewing =>
      'Pro er et automatisk fornyende abonnement';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus og Pro er automatisk fornyende abonnementer';

  @override
  String get billingDisclosureAppleBilling =>
      'Betalingen belastes din Apple ID ved kjøpsbekreftelse.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Betalingen belastes din Google Play-konto ved kjøpsbekreftelse.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Abonnementet fornyes automatisk for samme periode til samme pris med mindre du slår av automatisk fornyelse minst 24 timer før gjeldende periode utløper.';

  @override
  String get billingDisclosureAppleManage =>
      'Administrer eller avbryt når som helst i Innstillinger › din Apple ID › Abonnementer.';

  @override
  String get billingDisclosureGoogleManage =>
      'Administrer eller avbryt når som helst i Google Play › Betalinger og abonnementer.';

  @override
  String get billingReferFriend => 'Verv en venn';

  @override
  String get billingHowItWorks => 'Slik fungerer det';

  @override
  String get billingHowShareTitle => 'Del lenken din';

  @override
  String get billingHowShareBody => 'Send den til en venn.';

  @override
  String get billingHowSignUpTitle => 'De registrerer seg';

  @override
  String get billingHowSignUpBody => 'Vennen din blir med via lenken.';

  @override
  String get billingHowBothTitle => 'Dere får begge Pro';

  @override
  String get billingHowBothBody => 'Hver av dere får en måned med Pro gratis.';

  @override
  String get billingYourReferrals => 'Dine vervinger';

  @override
  String get billingInvited => 'Invitert';

  @override
  String get billingJoined => 'Blet med';

  @override
  String get billingMonthsEarned => 'Opptjente måneder';

  @override
  String get billingInviteFriend => 'Inviter en venn';

  @override
  String get billingInviteBody =>
      'Du og venninnen din får en måned med Pro hver.';

  @override
  String get billingYourCode => 'Din kode';

  @override
  String get billingCopyLink => 'Kopier lenke';

  @override
  String get billingShareInvite => 'Del invitasjon';

  @override
  String get giftUnavailable =>
      'Gaveinvitasjoner er ikke tilgjengelige i denne versjonen.';

  @override
  String get giftPageTitle => 'Gi bort FitCheck Pro';

  @override
  String get giftNoAllowances => 'Ingen gratis gaver tilgjengelig akkurat nå.';

  @override
  String get giftFormTitle => 'Send en gratis invitasjon';

  @override
  String get giftFormBody =>
      'Mottakeren løser inn gaven med denne verifiserte e-posten. Vi sender ikke e-posten for deg.';

  @override
  String get giftFieldFrom => 'Fra';

  @override
  String get giftFieldRecipientName => 'Mottakers navn';

  @override
  String get giftFieldRecipientEmail => 'Mottakers e-post';

  @override
  String get giftFieldOccasion => 'Anledning (valgfritt)';

  @override
  String get giftNoOccasion => 'Ingen anledning';

  @override
  String get giftOccasionBirthday => 'Bursdag';

  @override
  String get giftOccasionAnniversary => 'Jubileum';

  @override
  String get giftOccasionOther => 'Annet';

  @override
  String get giftFieldCardGreeting => 'Hilsen';

  @override
  String get giftFieldCardGreetingHelper =>
      'Dette vises på kortet nøyaktig slik det er skrevet.';

  @override
  String get giftFieldPrivateNote => 'Privat notat (valgfritt)';

  @override
  String get giftCreateAction => 'Lag gratis gave';

  @override
  String get giftClaimedTitle => 'Gave innløst';

  @override
  String get giftClaimedActive => 'Din FitCheck Pro-gave er aktiv.';

  @override
  String get giftClaimedQueued =>
      'Din FitCheck Pro-gave starter etter din nåværende tilgang.';

  @override
  String get giftLinkCopied => 'Gavelenke kopiert til utklipstavlen.';

  @override
  String get giftErrorName => 'Skriv inn et navn.';

  @override
  String get giftErrorEmail => 'Skriv inn en gyldig e-postadresse.';

  @override
  String get giftErrorGreeting => 'Skriv inn kortets hilsen.';

  @override
  String get giftErrorGreetingLength => 'Bruk maks 80 tegn.';

  @override
  String get giftClaimAction => 'Hent gave';

  @override
  String get giftCardPreview => 'Forhåndsvisning';

  @override
  String get giftGiftForYou => 'En gave til deg';

  @override
  String get giftGiftWaiting => 'En gave venter på deg';

  @override
  String get giftOpenBody =>
      'Åpne gavene dine for å kreve dem med din verifiserte e-post.';

  @override
  String get giftOpenGifts => 'Åpne gaver';

  @override
  String get giftSendInvitation => 'Send invitasjon';

  @override
  String get settingsAiProviderSection => 'Leverandør';

  @override
  String get settingsAiCustom => 'Tilpasset';

  @override
  String get settingsAiUrlHelper =>
      'Bruk en offentlig URL som serveren kan nå. Lokalhost fungerer ikke fra våre servere.';

  @override
  String get settingsAiConnectionSection => 'Tilkobling';

  @override
  String get settingsAiApiUrl => 'API-URL';

  @override
  String get settingsAiApiKey => 'API-nøkkel';

  @override
  String get settingsAiApiKeySaved => 'Lagret. La stå tom for å beholde den.';

  @override
  String get settingsAiChatModel => 'Chatmodell';

  @override
  String get settingsAiVisionModel => 'Visjonsmodell (valgfritt)';

  @override
  String get settingsAiImageModel => 'Bildemodell (valgfritt)';

  @override
  String get settingsAiImageModelNote =>
      'Bildegenerering krever OpenAI-kompatible chat-fullføringer med response_modalities.';

  @override
  String get settingsAiTestConnection => 'Test tilkobling';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarGoToToday => 'Gå til i dag';

  @override
  String get calendarConnectTooltip => 'Koble til en kalender';

  @override
  String get calendarAddEvent => 'Legg til hendelse';

  @override
  String get calendarEmptyTitle => 'Ingenting planlagt';

  @override
  String get calendarEmptyBody => 'Legg til en hendelse og planlegg antrekket.';

  @override
  String get calendarPreviousMonth => 'Forrige måned';

  @override
  String get calendarNextMonth => 'Neste måned';

  @override
  String get calendarAllDay => 'Hele dagen';

  @override
  String get calendarOutfitLinked => 'Antrekk koblet til';

  @override
  String get calendarEventOptions => 'Hendelsesalternativer';

  @override
  String get calendarDeleteTitle => 'Slett denne hendelsen?';

  @override
  String get calendarChangeOutfit => 'Bytt antrekk';

  @override
  String get calendarLinkOutfit => 'Koble til et antrekk';

  @override
  String get calendarRemoveOutfit => 'Fjern antrekk';

  @override
  String get calendarNewEvent => 'Ny hendelse';

  @override
  String get calendarEditEvent => 'Rediger hendelse';

  @override
  String get calendarTitleLabel => 'Tittel';

  @override
  String get calendarTitleRequired => 'Legg til en tittel';

  @override
  String get calendarEndBeforeStart => 'Slutt etter starttidspunktet';

  @override
  String get calendarStarts => 'Starter';

  @override
  String get calendarEnds => 'Slutter';

  @override
  String get calendarPlaceOptional => 'Sted (valgfritt)';

  @override
  String get calendarNotesOptional => 'Notater (valgfritt)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Lag et antrekk og koble det til denne hendelsen.';

  @override
  String get calendarBuildOutfit => 'Lag et antrekk';

  @override
  String get calendarConnectionsTitle => 'Kalendere';

  @override
  String get calendarConnectionsBody =>
      'Hendelser du legger til her, forblir i FitCheck.';

  @override
  String get calendarDisconnect => 'Koble fra';

  @override
  String get calendarNotAvailable => 'Ikke tilgjengelig ennå';

  @override
  String get profileSectionExplore => 'Utforsk';

  @override
  String get profileNavTryOn => 'Prøv på';

  @override
  String get profileNavRewards => 'Belønninger';

  @override
  String get profileSupport => 'Støtte';

  @override
  String get profileHelp => 'Hjelp';

  @override
  String get profileAbout => 'Om';

  @override
  String get profileAboutBody =>
      'Garderoben, antrekkene og planene dine på ett sted.';

  @override
  String get profileSignOutTitle => 'Logg ut?';

  @override
  String get profileSignOutBody => 'Du kan logge på igjen når som helst.';

  @override
  String get profileEditTitle => 'Rediger profil';

  @override
  String get profileYourProfile => 'Din profil';

  @override
  String get profileBodyProfiles => 'Kroppsprofiler';

  @override
  String get profileBodyEmptyTitle => 'Ingen kroppsprofiler ennå';

  @override
  String get profileBodyEmptyBody =>
      'Legg til høyde og bygning for bedre passform.';

  @override
  String get profileBodyAdd => 'Legg til profil';

  @override
  String get profileBodyDefaultNote =>
      'Standardprofilen din brukes til passform og prøving.';

  @override
  String get profileBodyDefaultBadge => 'Standard';

  @override
  String get profileBodyMakeDefault => 'Bruk som standard';

  @override
  String get profileBodyDeleteBody => 'Dette kan ikke angres.';

  @override
  String get profileBodyRequired => 'Påkrevd';

  @override
  String get profileBodyCheckNumber => 'Sjekk dette tallet';

  @override
  String get profileBodyNew => 'Ny kroppsprofil';

  @override
  String get profileBodyNameHint => 'For eksempel Meg';

  @override
  String get profileBodyHeight => 'Høyde';

  @override
  String get profileBodyWeight => 'Vekt';

  @override
  String get profileBodyBuild => 'Bygning';

  @override
  String get profileBodySkinTone => 'Hudtone';

  @override
  String get profileBirthDateNeededBody =>
      'Legg til fødselsdato som hører til fødselstiden.';

  @override
  String get profileBirthDateNeededTitle => 'Fødselsdato mangler';

  @override
  String get profilePartlySavedBody =>
      'Vi lagret navn og bilde. Fødselsdetaljer ble ikke lagret, prøv igjen senere.';

  @override
  String get profilePartlySavedTitle => 'Delvis lagret';

  @override
  String get profileSavedBody => 'Profilen din er lagret.';

  @override
  String get profileChangePhoto => 'Endre profilbilde';

  @override
  String get profilePhotoLabel => 'Profilbilde';

  @override
  String get profilePhotoHint => 'Trykk for å velge et nytt';

  @override
  String get profileBirthDateLabel => 'Fødselsdato (valgfritt)';

  @override
  String get profileBirthTimeLabel => 'Fødselstid (valgfritt)';

  @override
  String get profileBirthTimeHelper => 'Gjør vediske forslag mer nøyaktige';

  @override
  String get profileBirthPlaceLabel => 'Fødested (valgfritt)';

  @override
  String get profileBirthPlaceHint => 'For eksempel Oslo, Norge';

  @override
  String get profileHelpContactTitle => 'Spør oss om hva som helst';

  @override
  String get profileHelpContactBody =>
      'Send oss en melding, så svarer vi på e-post, vanligvis innen en dag.';

  @override
  String get profileHelpContactAction => 'Kontakt kundestøtte';

  @override
  String get profileHelpFaqTitle => 'Vanlige spørsmål';

  @override
  String get profileFaqAddPiecesTitle =>
      'Hvordan legger jeg til plagg i garderoben?';

  @override
  String get profileFaqAddPiecesBody =>
      'Trykk på Legg til plagg i garderoben. Ta et bilde eller velg fra galleriet; vi finner plagget og merker det for deg.';

  @override
  String get profileFaqMatchingTitle => 'Hvordan fungerer antrekksforslag?';

  @override
  String get profileFaqMatchingBody =>
      'Åpne For deg og velg plagg du eier. Vi foreslår hva som passer til og setter sammen komplette antrekk.';

  @override
  String get profileFaqTryOnTitle => 'Kan jeg bruke egne bilder til prøving?';

  @override
  String get profileFaqTryOnBody =>
      'Ja. Legg til et helfigursbilde av deg selv, og velg deretter plagg for å se dem på deg.';

  @override
  String get profileFaqRewardsTitle => 'Hvordan tjener jeg belønninger?';

  @override
  String get profileFaqRewardsBody =>
      'Planlegg og loggfør antrekk ofte. Du bygger opp serier og prestasjoner underveis.';

  @override
  String get profileFaqPrivacyTitle => 'Er garderoben min privat?';

  @override
  String get profileFaqPrivacyBody =>
      'Ja. Garderoben og antrekkene dine er private med mindre du deler en lenke til et antrekk.';

  @override
  String get profileHelpMoreTitle => 'Mer hjelp';

  @override
  String get profileHelpGuides => 'Guider';

  @override
  String get profileHelpGuidesBody => 'Slik fungerer hver funksjon';

  @override
  String get feedbackCategoryBug => 'Noe fungerer ikke';

  @override
  String get feedbackCategoryIdea => 'En idé';

  @override
  String get feedbackCategoryGeneral => 'Generelt';

  @override
  String get feedbackCategoryHelp => 'Jeg trenger hjelp';

  @override
  String get feedbackHintBug =>
      'Hva skjedde, og hva forventet du? Trinn hjelper oss å retde det opp.';

  @override
  String get feedbackHintIdea => 'Hva vil du ha, og hvorfor?';

  @override
  String get feedbackHintGeneral =>
      'Fortell oss hva du mener, eller still et spørsmål.';

  @override
  String get feedbackAttachmentLimitBody => 'Du kan legge til opptil 5 bilder.';

  @override
  String get feedbackAttachmentLimitTitle => 'Grensen er nådd';

  @override
  String get feedbackImageTooLargeBody => 'Velg et bilde på under 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Bildet er for stort';

  @override
  String get feedbackTitle => 'Send tilbakemelding';

  @override
  String get feedbackAboutLabel => 'Hva gjelder det?';

  @override
  String get feedbackSubjectLabel => 'Emne';

  @override
  String get feedbackSubjectRequired => 'Legg til et emne';

  @override
  String get feedbackSubjectTooShort => 'Emnet må være minst 3 tegn';

  @override
  String get feedbackDetailsLabel => 'Detaljer';

  @override
  String get feedbackDetailsRequired => 'Legg til litt detaljer';

  @override
  String get feedbackDetailsTooShort => 'Beskrivelsen må være minst 10 tegn';

  @override
  String get feedbackAddScreenshot => 'Legg til skjermbilde';

  @override
  String get feedbackAttachmentHint => 'Opptil 5, maks 5 MB hver';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackEmptyTitle => 'Ingenting sendt ennå';

  @override
  String get feedbackEmptyBody => 'Det du sender dukker opp her med status.';

  @override
  String get feedbackHistoryTitle => 'Det du sendte';

  @override
  String get feedbackStatusOpen => 'Åpen';

  @override
  String get feedbackStatusInProgress => 'Under behandling';

  @override
  String get feedbackStatusResolved => 'Løst';

  @override
  String get feedbackStatusClosed => 'Lukket';

  @override
  String get legalIntro =>
      'Hvordan vi beskytter dine data, og vilkårene for å bruke FitCheck AI.';

  @override
  String get legalPolicies => 'Retningslinjer';

  @override
  String get legalPrivacySubtitle => 'Hva vi samler inn og hvorfor';

  @override
  String get legalTermsTitle => 'Vilkår for bruk';

  @override
  String get legalTermsSubtitle => 'Reglene for bruk av appen';

  @override
  String get legalLicences => 'Lisenser for åpen kildekode';

  @override
  String get legalSupportSubtitle => 'Hjelp, kontakt og personvernforespørsler';

  @override
  String get legalReportAbuse => 'Rapporter et problem eller misbruk';

  @override
  String get permissionCameraTitle => 'Kameratilgang';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI bruker kameraet til å ta bilder av klærne og antrekkene dine for KI-prøving og garderobeorganisering.';

  @override
  String get permissionPhotoTitle => 'Bildetilgang';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI trenger tilgang til bildene dine slik at du kan velge bilder av klær og antrekk for KI-funksjoner og garderoben din.';

  @override
  String get permissionNotNow => 'Ikke nå';

  @override
  String get permissionOpenSettings => 'Åpne innstillinger';

  @override
  String authSignedInAs(String name) {
    return 'Logget inn som $name';
  }

  @override
  String get authSignedIn => 'Logget inn';

  @override
  String get authWelcomeBackTitle => 'Velkommen tilbake';

  @override
  String get authSignInFailed => 'Innlogging mislyktes';

  @override
  String get authWelcomeTitle => 'Velkommen';

  @override
  String get authSignUpFailed => 'Registrering mislyktes';

  @override
  String get authGoogleSignInFailed => 'Google-innlogging mislyktes';

  @override
  String get authAppleSignInFailed => 'Apple-innlogging mislyktes';

  @override
  String get authConfirmEmailTitle => 'Bekreft e-posten din';

  @override
  String get authConfirmEmailBody =>
      'Sjekk innboksen din for en bekreftelsesmelding, og logg deretter inn.';

  @override
  String get authClosetReady => 'Garderoben din er klar.';

  @override
  String get authSignedOutTitle => 'Logget ut';

  @override
  String get authSignedOutBody => 'Du er logget ut.';

  @override
  String get authSignOutFailed => 'Utlogging mislyktes';

  @override
  String get authEmailSentTitle => 'E-post sendt';

  @override
  String get authResetLinkSent =>
      'Sjekk e-posten din for en tilbakestillingslenke.';

  @override
  String get authPasswordUpdatedTitle => 'Passord oppdatert';

  @override
  String get authPasswordUpdated => 'Passordet ditt er oppdatert.';

  @override
  String get authPasswordNotUpdated => 'Passordet ble ikke oppdatert';

  @override
  String get authCouldNotSendEmail => 'Kunne ikke sende e-posten';

  @override
  String get authEmailNotSent => 'E-post ikke sendt';

  @override
  String get authResendSentBody => 'Vi har sendt en ny bekreftelsesmelding.';

  @override
  String get outfitPreviewWithAi => 'Forhåndsvis med AI';

  @override
  String get outfitNewPreview => 'Lag ny forhåndsvisning';

  @override
  String get outfitBuilderClosetHeading => 'Klesskapet ditt';

  @override
  String get outfitBuilderSearchHint => 'Søk etter plagg';

  @override
  String get outfitClearSearch => 'Tøm søk';

  @override
  String get outfitBuilderAddPiecesTitle => 'Legg til plagg først';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Antrekk lagres med plagg fra klesskapet ditt.';

  @override
  String get outfitBuilderNoMatches => 'Ingen plagg samsvarer.';

  @override
  String get outfitNameLabel => 'Antrekknavn';

  @override
  String get outfitNameHint => 'For eksempel, Frelvs helg';

  @override
  String get outfitPreviewSemantic => 'AI-forhåndsvisning av antrekket';

  @override
  String get outfitChoosePieces => 'Velg plagg';

  @override
  String get outfitTapPiecesHint =>
      'Trykk på plaggene under for å legge dem til.';

  @override
  String get outfitShareTooltip => 'Del';

  @override
  String get outfitSaveFavourite => 'Lagre som favoritt';

  @override
  String get outfitPiecesHeading => 'Plagg';

  @override
  String get outfitWearHistoryEmpty => 'Bruk det en gang, så vises datoen her.';

  @override
  String get outfitWearHistoryTitle => 'Brukshistorikk';

  @override
  String get outfitWearHistoryError => 'Kunne ikke laste datoen.';

  @override
  String get outfitWornOn => 'Brukt på';

  @override
  String get outfitEditTitle => 'Rediger antrekk';

  @override
  String get outfitSavedPhotosFailed => 'Detaljer lagret, ikke bilder';

  @override
  String get outfitNoPhotosBody =>
      'Ingen bilder ennå. Antrekket viser plaggene isteden.';

  @override
  String get outfitOccasionLabel => 'Anledning';

  @override
  String get outfitOccasionNone => 'Ingen';

  @override
  String get outfitTagsHint => 'Skiller med komma';

  @override
  String get outfitDraftBody => 'Skjul i hovedlisten';

  @override
  String get outfitPublic => 'Offentlig';

  @override
  String get outfitPublicBody => 'Alle med linken kan se det';

  @override
  String get outfitDeleteFromDetail => 'Slett dette antrekket fra detaljsiden.';

  @override
  String get outfitNewCollection => 'Ny samling';

  @override
  String get outfitNoCollectionsTitle => 'Ingen samlinger ennå';

  @override
  String get outfitNoCollectionsBody =>
      'Grupper utstykker etter reise, sesong eller stemning.';

  @override
  String get outfitCreateCollection => 'Lag en samling';

  @override
  String get outfitAddOutfits => 'Legg til antrekk';

  @override
  String get outfitRename => 'Gi nytt navn';

  @override
  String get outfitCollectionDeleteBody => 'Antrekkene i samlingen beholdes.';

  @override
  String get outfitCollectionsNotLoaded => 'Antrekk ikke lastet';

  @override
  String get outfitRenameCollection => 'Gi samlingen nytt navn';

  @override
  String get outfitDescriptionOptional => 'Beskrivelse (valgfritt)';

  @override
  String get outfitAllInCollection =>
      'Alle antrekk er allerede i denne samlingen.';

  @override
  String get photoshootSubtitleUpload => 'Studioporsjoner fra dine egne bilder';

  @override
  String get photoshootSubtitleConfigure => 'Velg stil, format og antall';

  @override
  String get photoshootSubtitleGenerating => 'Dette tar et par minutter';

  @override
  String get photoshootAddPhotosSemantic =>
      'Legg til bilder fra galleriet ditt';

  @override
  String get photoshootUploadTitle => 'Legg til 1–4 bilder av deg selv';

  @override
  String get photoshootUploadBody => 'Trykk for å velge fra galleriet';

  @override
  String get photoshootAddToContinue => 'Legg til et bilde for å fortsette';

  @override
  String get photoshootAddAnotherPhoto => 'Legg til et annet bilde';

  @override
  String get photoshootTipsTitle => 'For best resultat';

  @override
  String get photoshootTipsBody =>
      'Bruk klare og godt lysede bilder av ansiktet fra flere vinkler. Ikke bruk solbriller eller hatter.';

  @override
  String get photoshootStarting => 'Starter';

  @override
  String get photoshootCancelling => 'Avbryter';

  @override
  String get photoshootFailed => 'Feilet';

  @override
  String get recommendTabMatches => 'Match';

  @override
  String get recommendTabComplete => 'Komplett';

  @override
  String get recommendTabWeather => 'Vær';

  @override
  String get recommendTabColours => 'Farger';

  @override
  String get recommendTabShop => 'Butikk';

  @override
  String get recommendNoMatchesTitle => 'Ingen matches ennå';

  @override
  String get recommendNoMatchesBody =>
      'Velg et plagg og vi finner hva som passer sammen med det.';

  @override
  String get recommendPickPiece => 'Velg et plagg';

  @override
  String get recommendNothingMatchesTitle => 'Ingenting samsvarer enda';

  @override
  String get recommendNothingMatchesBody =>
      'Prøv andre plagg eller legg til flere i skapet.';

  @override
  String get recommendChangePieces => 'Endre plagg';

  @override
  String get recommendDefaultReason => 'Det passer med plaggene du valgte.';

  @override
  String get recommendCompleteTitle => 'Fullfør look';

  @override
  String get recommendCompleteBody => 'Velg et plagg og vi fyller resten.';

  @override
  String get recommendWorking => 'Jobber';

  @override
  String get recommendGenerate => 'Generer';

  @override
  String get recommendChooseStyleBody => 'Velg en stil og generer.';

  @override
  String get recommendNoLooksTitle => 'Ingen looks for disse plaggene';

  @override
  String get recommendNoLooksBody => 'Prøv en annen stil eller andre plagg.';

  @override
  String get recommendDefaultLook => 'En look for dine plagg';

  @override
  String get recommendNoPiecesBody =>
      'Ingen plagg dukket opp for denne looken.';

  @override
  String get recommendCityLabel => 'By';

  @override
  String get recommendCheck => 'Sjekk';

  @override
  String get recommendWeatherTitle => 'Hva er været?';

  @override
  String get recommendWeatherBody =>
      'Skriv inn byen din for å få tips for i dag.';

  @override
  String get recommendWearToday => 'Bær i dag';

  @override
  String get recommendWeatherNoPieces =>
      'Ingen plagg i skapet for dette været enda.';

  @override
  String get recommendBudgetLabel => 'Budsjett opptil';

  @override
  String get recommendLooking => 'Ser';

  @override
  String get recommendFindWhatToBuy => 'Finn hva du skal kjøpe';

  @override
  String get recommendFillGapsTitle => 'Fyll hullene';

  @override
  String get recommendFillGapsBody =>
      'Sett et budsjett og vi foreslår hva skapet mangler.';

  @override
  String get recommendNoGapsTitle => 'Ingen hull funnet';

  @override
  String get recommendNoGapsBody =>
      'Prøv et større budsjett eller en annen kategori.';

  @override
  String get recommendMoodEveryday => 'Hverdags';

  @override
  String get recommendMoodBigMeeting => 'Stort møte';

  @override
  String get recommendDayLabel => 'Dag';

  @override
  String get recommendReadingStars => 'Leser stjernene';

  @override
  String get recommendGetMyColours => 'Få mine farger';

  @override
  String get recommendLuckyColoursTitle => 'Dine lykkekjærlige farger';

  @override
  String get recommendLuckyColoursBody =>
      'Velg en dag, så foreslår vi farger og plagg til den.';

  @override
  String get recommendLuckyColoursSection => 'Lykkefarger';

  @override
  String get recommendAvoidColoursSection => 'Farger å unngå';

  @override
  String get recommendBirthDateTitle => 'Legg til fødselsdato';

  @override
  String get recommendBirthDateBody =>
      'Vi trenger fødselsdatoen din for å lese fargene dine.';

  @override
  String get recommendEditProfile => 'Rediger profil';

  @override
  String get recommendNothingThisDay => 'Ingenting denne dagen.';

  @override
  String get recommendUnnamedColour => 'Uten navngitt farge';

  @override
  String get recommendFromCloset => 'Fra ditt skap';

  @override
  String get recommendNoPiecesInColours => 'Ingen plagg i disse fargene ennå.';

  @override
  String get recommendOutfitIdeas => 'Outfit-ideer';

  @override
  String get recommendNoOutfitsInColours =>
      'Ingen komplett outfit i disse fargene ennå.';

  @override
  String get recommendDefaultOutfitIdea => 'En outfit-ide';

  @override
  String get recommendPickUpToThree => 'Velg inntil tre plagg';

  @override
  String get recommendEmptyClosetBody =>
      'Legg til noen plagg først, før du kommer tilbake for matches.';

  @override
  String get dashboardDressForDay => 'Klær deg for dagen foran deg.';

  @override
  String get dashboardOutfitOfDay => 'Dagens outfit';

  @override
  String get dashboardFreshLook => 'Et nytt look';

  @override
  String get subscriptionManageInStoreTitle => 'Administrer i butikken';

  @override
  String get subscriptionManageInStoreBody =>
      'Denne planen belastes gjennom butikken. Administrer den i butikkkontoens innstillinger.';

  @override
  String get subscriptionCancelledTitle => 'Abonnement kansellert';

  @override
  String get subscriptionCancelledBody =>
      'Din plan forblir aktiv til slutten av denne beløpningsperioden.';

  @override
  String get subscriptionCancelFailedTitle => 'Kunne ikke kansellere';

  @override
  String get subscriptionCouldNotOpenTitle => 'Kunne ikke åpne';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Kunne ikke åpne fakturastyring.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Kunne ikke åpne lenken.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Kunne ikke laste lenken din';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Kunne ikke laste henvisningslenken din. Prøv igjen.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopiert';

  @override
  String get subscriptionReferralCopiedBody => 'Henvisningslenke kopiert.';

  @override
  String get subscriptionReferralShareSubject => 'Prøv FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Bli med i FitCheck AI og vi får begge en måned med Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Lenke kopiert';

  @override
  String get subscriptionShareUnavailableBody =>
      'Deling er ikke tilgjengelig, så vi kopierte lenken.';

  @override
  String get subscriptionShareFailedTitle => 'Kunne ikke dele';

  @override
  String get subscriptionShareFailedBody =>
      'Kopier lenken fra henvisningssiden i stedet.';

  @override
  String get subscriptionStoreReadyTitle => 'Butikk klar';

  @override
  String get subscriptionStoreReadyBody =>
      'Butikkspriser er tilgjengelige. Du kan oppgradere nå.';

  @override
  String get purchaseFailedTitle => 'Kjøp mislyktes';

  @override
  String get purchaseUnavailableTitle => 'Kjøp utilgjengelig';

  @override
  String get purchaseIapUnavailableBody =>
      'In-app-kjøp er ikke tilgjengelig på denne enheten.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Denne planen er ikke tilgjengelig for kjøp enda.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Denne planen er ikke tilgjengelig i butikken ennå. Sjekke tilbake snart.';

  @override
  String get purchaseStartFailedBody => 'Kjøpet kunne ikke starte. Prøv igjen.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Kassen ga ikke tilbake en betalingslenke.';

  @override
  String get purchasePendingTitle => 'Kjøp ventende';

  @override
  String get purchasePendingBody =>
      'Kjøpet ditt venter på godkjennelse. Du får tilgang så snart det er godkjent.';

  @override
  String get purchaseFailedBody => 'Kjøpet mislyktes. Prøv igjen.';

  @override
  String get purchaseRestoredTitle => 'Gjenopprettet';

  @override
  String get purchaseRestoredBody => 'Kjøpene dine er gjenopprettet.';

  @override
  String get purchaseActiveTitle => 'Abonnement aktivt';

  @override
  String get purchaseActiveBody => 'Abonnementet ditt er aktivt. Velkommen.';

  @override
  String get purchaseSignInRequiredTitle => 'Pålogging kreves';

  @override
  String get purchaseSignInRequiredBody => 'Logg inn for å fullføre kjøpet.';

  @override
  String get purchaseErrorTitle => 'Kjøpsfeil';

  @override
  String get purchaseInvalidTransactionBody =>
      'Kjøpet inkluderte ikke en verificerbar transaksjons-ID.';

  @override
  String get purchaseVerificationPendingTitle => 'Verifisering pågår';

  @override
  String get purchaseVerificationPendingBody =>
      'Vi kunne ikke verifisere kjøpet ditt i butikken akkurat nå. Det fullføres automatisk, og du blir ikke belastet to ganger.';

  @override
  String get purchaseNotAppliedTitle => 'Kjøp ikke lagt til';

  @override
  String get purchaseNotAppliedBody =>
      'Kjøpet ditt kunne ikke legges til kontoh din. Kontakt support og kjøp det ikke på nytt.';

  @override
  String get purchaseRestoreFailedTitle => 'Gjenopprettelse feilet';

  @override
  String get purchaseRestoreFailedBody =>
      'Kunne ikke gjenopprette kjøp. Prøv igjen.';

  @override
  String get purchaseRecoveredActiveBody => 'Abonnementet ditt er aktivt.';

  @override
  String get purchaseCompleteTitle => 'Kjøp fullført';

  @override
  String get giftCreateFailedTitle => 'Kunne ikke opprette gaven';

  @override
  String get giftClaimFailedTitle => 'Kunne ikke hente gaven';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gaver til deg',
      one: 'En gave til deg',
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
      other: '$remaining igjen',
      one: '1 igjen',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration av FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender har sendt deg $duration av FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'En FitCheck Pro-gave til $recipient';
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
  String get giftPreviewPlaceholderRecipient => 'mottakeren din';

  @override
  String get giftPreviewPlaceholderSender => 'du';

  @override
  String get settingsSavedTitle => 'Lagret';

  @override
  String get settingsNotSavedTitle => 'Ikke lagret';

  @override
  String get settingsAiChooseProviderBody => 'Velg en leverandør.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'En tilpasset leverandør krever en API-URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Skriv inn en API-nøkkel.';

  @override
  String get settingsAiSavedBody => 'AI-innstillingene dine er lagret.';

  @override
  String get settingsAiMissingDetailsTitle => 'Manglende detaljer';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Skriv inn en API-URL og en chattmodell for å teste.';

  @override
  String get settingsAiKeyNeededTitle => 'API-nøkkel kreves';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Skriv inn API-nøgelen for å teste. Nøkkelen din beholdes privat.';

  @override
  String get settingsAiKeyToTestBody => 'Skriv inn API-nøgelen for å teste.';

  @override
  String get settingsAiConnectedTitle => 'Tilkoblet';

  @override
  String get settingsAiConnectedBody => 'Tilkoblingen fungerer.';

  @override
  String get settingsAiTestFailedTitle => 'Test mislyktes';

  @override
  String get settingsPreferencesSavedBody => 'Preferansene dine er lagret.';

  @override
  String get settingsPasswordNotChangedTitle => 'Passordet ble ikke endret';

  @override
  String get settingsOAuthPasswordBody =>
      'Denne kontoen logger inn med Google eller Apple. Bruk «Glemt passord» for å sette et passord først.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Gjeldende passord er feil.';

  @override
  String get settingsExportReadyTitle => 'Eksport klar';

  @override
  String get settingsExportReadyBody => 'Dataeksporten er klar til nedlasting.';

  @override
  String get settingsLinkCopiedTitle => 'Lenke kopiert';

  @override
  String get settingsExportClipboardBody =>
      'Vi klarte ikke åpne nettleseren din, så vi kopierte nedlastingslenken. Lim den inn i en nettleser snart: den utløper.';

  @override
  String get settingsExportFailedTitle => 'Eksport mislyktes';

  @override
  String get settingsAccountNotDeletedTitle => 'Kontoen ble ikke slettet';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Du kan legge til opptil $max bilder.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Bildegrense';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Legg til minst ett bilde.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Ingen bilder';

  @override
  String get photoshootDescribeLookBody => 'Beskriv stilen du ønsker.';

  @override
  String get photoshootPromptNeededTitle => 'Beskrivelse nødvendig';

  @override
  String get photoshootConsentFeatureLabel => 'AI Fotohoot';

  @override
  String get photoshootStatusPreparing => 'Forbereder bildene dine';

  @override
  String get photoshootStatusGenerating => 'Genererer';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Båtj $current av $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done av $total ferdige';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generering mislyktes.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready klare, $failed mislyktes.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Delvis fullført';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bilder er klare.',
      one: '1 bilde er klar.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Vi mistet tilkoblingen. Prøv igjen.';

  @override
  String get photoshootCouldNotCancelTitle => 'Kunne ikke avbryte';

  @override
  String get photoshootRetryFailedTitle => 'Prøve igjen feilet';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Foto $number er klart.';
  }

  @override
  String get photoshootReplacedTitle => 'Erstattet';

  @override
  String get photoshootSavedToGalleryBody => 'Lagret i galleriet ditt.';

  @override
  String get photoshootSavedTitle => 'Lagret';

  @override
  String get photoshootNotSavedTitle => 'Ikke lagret';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count fotoer er i galleriet ditt.',
      one: '1 foto er i galleriet ditt.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved av $total lagret.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Noen fotoer er ikke lagret';

  @override
  String get tryonConsentFeatureLabel => 'Virtuell prøving';

  @override
  String get tryonAvatarUpdatedBody => 'Fotoet ditt er oppdatert.';

  @override
  String get tryonSavedTitle => 'Lagret';

  @override
  String get tryonUploadFailedTitle => 'Opplastingen feilet';

  @override
  String get tryonChooseGarmentFirstBody => 'Velg et plaggbilde først.';

  @override
  String get tryonNoGarmentTitle => 'Ingen plagg';

  @override
  String get tryonWaitForUploadBody =>
      'Vent til fotoet ditt er ferdig lastet opp.';

  @override
  String get tryonStillUploadingTitle => 'Laster fortsatt opp';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Legg til et bilde av deg selv først.';

  @override
  String get tryonReadyBody => 'Prøvingen din er klar.';

  @override
  String get tryonFailedTitle => 'Prøvingen feilet';

  @override
  String get tryonSavedToGalleryBody => 'Lagret i galleriet ditt.';

  @override
  String get tryonNotSavedTitle => 'Ikke lagret';

  @override
  String get calendarEventAddedBody => 'Hendelsen er lagt til';

  @override
  String get calendarEventPlannedTitle => 'Planlagt';

  @override
  String get calendarEventSavedBody => 'Hendelsen er lagret';

  @override
  String get calendarSavedTitle => 'Lagret';

  @override
  String get calendarEventNotSavedTitle => 'Hendelsen er ikke lagret';

  @override
  String get calendarEventRemovedBody => 'Hendelsen er fjernet';

  @override
  String get calendarEventDeletedTitle => 'Slettet';

  @override
  String get calendarEventNotDeletedTitle => 'Begivenheten ble ikke slettet';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit ble ikke koblet';

  @override
  String get calendarLinkedTitle => 'Koblet';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit ble ikke fjernet';

  @override
  String get calendarOutfitRemovedBody => 'Outfit fjernet';

  @override
  String get calendarDisconnectedBody => 'Kalender koblet fra';

  @override
  String get calendarDisconnectedTitle => 'Koblet fra';

  @override
  String get calendarNotDisconnectedTitle => 'Kalender ble ikke koblet fra';

  @override
  String get calendarTodayLabel => 'i dag';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count begivenheter',
      one: '1 begivenhet',
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
    return '$title, $time, outfit koblet';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '«$title» vil bli fjernet.';
  }

  @override
  String get calendarThisAppLabel => 'Denne appen';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synkronisering med $provider er ikke tilgjengelig ennå. Du kan fortsatt legge til begivenheter her.';
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
  String get calendarWeekdaySunday => 'Søndag';

  @override
  String get outfitSavedToFavouritesBody => 'Lagret i favoritter';

  @override
  String get outfitRemovedFromFavouritesBody => 'Fjernet fra favoritter';

  @override
  String get outfitNotSavedTitle => 'Ikke lagret';

  @override
  String get outfitLoggedAsWornBody => 'Logget som brukt i dag.';

  @override
  String get outfitNicePickTitle => 'Godt valg';

  @override
  String get outfitRemovedBody => 'Antrekk fjernet.';

  @override
  String get outfitDeletedTitle => 'Slettet';

  @override
  String get outfitNotDeletedTitle => 'Ikke slettet';

  @override
  String get outfitDuplicatedBody => 'En kopi er i dine antrekk.';

  @override
  String get outfitDuplicatedTitle => 'Duplisert';

  @override
  String get outfitNotDuplicatedTitle => 'Ikke duplisert';

  @override
  String get outfitNotSharedTitle => 'Ikke delt';

  @override
  String outfitCollectionReadyBody(String name) {
    return '«$name» er klar.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Kolleksjon ikke opprettet';

  @override
  String get outfitCollectionUpdatedBody => 'Kolleksjon oppdatert.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Kolleksjon ikke oppdatert';

  @override
  String get outfitCollectionDeletedBody => 'Kolleksjon slettet.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Kolleksjon ikke slettet';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count antrekk lagt til.',
      one: '1 antrekk lagt til.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Antrekk ikke lagt til';

  @override
  String get outfitPreviewNotCreatedTitle => 'Forhåndsvisning ikke opprettet';

  @override
  String get outfitGiveNameBody => 'Gi antrekket et navn.';

  @override
  String get outfitNameMissingTitle => 'Navn';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Velg minst ett plagg.';

  @override
  String outfitCreatedBody(String name) {
    return '$name er i dine antrekk.';
  }

  @override
  String get outfitSavedTitle => 'Lagret';

  @override
  String get wardrobeAddedToFavouritesBody => 'Lagt til i favoritter';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Fjernet fra favoritter';

  @override
  String get wardrobeNotSavedTitle => 'Ikke lagret';

  @override
  String get wardrobeLoggedAsWornBody => 'Registrert som brukt i dag.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Fjernet fra skapet ditt.';

  @override
  String get wardrobeDeletedTitle => 'Slettet';

  @override
  String get wardrobeNotDeletedTitle => 'Ikke slettet';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deler fjernet fra skapet ditt.',
      one: '1 del fjernet fra skapet ditt.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI-skaputtrekking';

  @override
  String get itemAddScanJobLabel => 'Skann';

  @override
  String get itemAddFoundEarlierBody => 'Funnet i en tidligere skanning';

  @override
  String get itemAddLookingAtPhoto => 'Ser på bildet ditt';

  @override
  String get itemAddExtractionFailedBody => 'Uttrekket mislyktes';

  @override
  String get itemAddJobFailedBody => 'Oppgaven mislyktes';

  @override
  String get itemAddConnectionLostBody => 'Tilkoblinga ble brutt. Prøv igjen.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Tilkoblinga ble brutt under bearbeiding.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Del $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Del';

  @override
  String get itemAddNotCancelledTitle => 'Ikke avbrutt';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deler er i skapet ditt.',
      one: '1 del er i skapet ditt.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved av $total deler lagret. Trykk lagre for å prøve resten igjen.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Noen deler er ikke lagret';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Velg minst ett bilde.';

  @override
  String get batchPhotoUnreadableBody => 'Dette bildet kunne ikke leses.';

  @override
  String get batchNoPhotosReadableBody =>
      'Ingen av disse bildene kunne leses. Prøv andre bilder.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bilder',
      one: '1 bilde',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Vi mistet tilkoblinga under jobbing. Prøv igjen.';

  @override
  String get batchNotCancelledTitle => 'Ikke avbrutt';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Innleggslenker støttes ikke. Skriv inn en profil-lenke.';

  @override
  String get batchLinkSpacesBody => 'Lenker kan ikke inneholde mellomrom.';

  @override
  String get batchEnterProfileLinkBody =>
      'Skriv inn en profil-lenke fra Instagram eller Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Skriv inn en profil-lenke.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Innloggingssiden åpnet ikke. Prøv igjen.';

  @override
  String get batchSignInBrowserBody =>
      'Logg inn i nettleseren din, og gå deretter tilbake til FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Koble til kontoen din';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Skriv inn koden fra autentisikasjonapp-en din.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram krever en sikkerhetskontroll. Logg inn i nettleseren din først.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Skriv inn brukernavnet og passordet ditt på nytt.';

  @override
  String get batchSignInFailedBody =>
      'Innlogging feilet. Sjekk brukernavn og passord.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Logg inn for å fortsette importen.';

  @override
  String get batchAccountNotConnectedBody => 'Kontoen din ble ikke koblet til.';

  @override
  String get batchAccountConnectedTitle => 'Kontoen er koblet';

  @override
  String get batchNotConnectedTitle => 'Ikke koblet';

  @override
  String get batchImportConnectionLostBody =>
      'Koblingen til importen ble borte. Oppdater for å sjekke den.';

  @override
  String batchPickUpToBody(int max) {
    return 'Velg opptil $max bilder. Vi finner plaggene for deg.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count av $total bilder';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Forbereder bilde $done av $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Find plagg i $count bilder',
      one: 'Find pla gg i 1 bilde',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Kontoen din på $platform bruker totråinlogging. Skriv inn 6-sifret kode fra autentisikasjonapp-en din.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Dette $platform-profilen er privat, eller krever innlogging for å vise bildene.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Koble til $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bilder hittil',
      one: '1 bilde hittil',
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
    return '$processed av $total behandlet · $added lagt til · $waiting ventende · $skipped hoppet over';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Skanner bilde $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Bilde $number er neste';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Bilde $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plagg funnet',
      one: '1 plagg funnet',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bilder ble lagt til i skapet ditt.',
      one: '1 bilde ble lagt til i skapet ditt.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count flere studiofotografier på vei. Du kan lagre det som er klart, eller gå – vi gir deg beskjed.',
      one:
          '1 mer studiofotografier på vei. Du kan lagre det som er klart, eller gå – vi gir deg beskjed.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Ikke lagret ennå: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces plagg',
      one: '1 plagg',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos bilder',
      one: '1 bilde',
    );
    return '$_temp0 fra $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen valgt. Trykk på et plagg for å hoppe over det.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lagrer $count plagg',
      one: 'Lagrer 1 plagg',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lagre $count klær',
      one: 'Lagre 1 klær',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Kroppprofilen din er lagret.';

  @override
  String get bodyProfileSavedTitle => 'Lagret';

  @override
  String get bodyProfileNotSavedTitle => 'Ikke lagret';

  @override
  String get bodyProfileSetDefaultBody => 'Sett som standardprofilen din.';

  @override
  String get bodyProfileDeletedBody => 'Kroppprofil slettet.';

  @override
  String get bodyProfileDeletedTitle => 'Slettet';

  @override
  String get bodyProfileNotDeletedTitle => 'Ikke slettet';

  @override
  String get feedbackNotSentTitle => 'Ikke sendt';

  @override
  String get feedbackSentBody =>
      'Takk. Vi leser alle meldinger og svarer om vi trenger mer.';

  @override
  String get feedbackSentTitle => 'Tilbakemelding sendt';

  @override
  String get recommendUnnamedPiece => 'Uoppgitt plagg';

  @override
  String get recommendEnterCityBody =>
      'Skriv inn byen din for å få forslag basert på været.';

  @override
  String get recommendWhichCityTitle => 'Hvilken by?';

  @override
  String get aiConsentSheetTitle => 'Deling av bilder med en AI-tjeneste';

  @override
  String get aiConsentSheetBody =>
      'For å lage dine prøvesøk- og fotostudio-bilder, sender FitCheck AI bildene du leverer (inklusive bilder av ansikt og kropp) til en pålitelig tredjepart AI-leverandør (som OpenAI eller Google Gemini) for bearbeiding. De genererer bildene dine og bruker dem ikke til å trene modellene sine i tråd med vilkårene våre. Bildene overføres trygt og deles aldri for annonsering.';

  @override
  String get aiConsentSheetPermission =>
      'Ved å fortsette, gir du eksplisitt tillatelse til å dele bildene dine med disse AI-leverandørene for billedgenerering.';

  @override
  String get skeletonsLoadMoreFailed => 'Kunne ikke laste mer.';

  @override
  String get jobsPiecesReadyTitle => 'Plaggene dine er klare';

  @override
  String get jobsScanStoppedTitle => 'Skanningen ble stoppet';

  @override
  String get jobsNothingSavedBody => 'Ingenting ble lagret. Prøv igjen.';

  @override
  String get jobsPhotoUploadFailedBody => 'Bildelastingen feilet.';

  @override
  String get authGoogleSignInStartFailed =>
      'Kunne ikke starte Google-innlogging. Prøv igjen.';

  @override
  String get referralAppliedTitle => 'Videodeling brukt!';

  @override
  String get billingStoreUnavailableBody =>
      'Kjøp i butikken er ikke tilgjengelig på denne enheten.';

  @override
  String get billingPurchaseProcessingBody =>
      'Kjøpet behandles fortsatt. Åpne appen igjen om et minutt for å se planen din.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Profilbilde-lastingen returnerte ikke en bilde-URL.';

  @override
  String get rewardsDayStreakLabel => 'dagers rekke';

  @override
  String rewardsBestStreak(int days) {
    return 'Beste $days dager';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Tilgang til $permission nødvendig';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Tilgang til $permission er akkurat nå nektet. Åpne Innstillinger for å tillate det, og prøv deretter på nytt.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Steg $step av 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Steg $step av $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Fjern bilde $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Fjern bilde $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points poeng';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Skriv en e-post til $email. Vi gransker rapporter innen 24 timer.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Fjern $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Slette «$name»?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Legg til i «$name»';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '«$name» er fjernet. Elementene forblir i skapet ditt.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Vis alle $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count igjen i dag';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index mislyktes';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected av $max bilder';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape kroppsbygge · $tone hud';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Slette $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Alternativer for $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Mest brukt: $name, $count ganger';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: ikke satt';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% samsvar';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked av $max valgt';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Fjern $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency-prioritering';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Denne planen faktureres gjennom $store. Endre eller si den opp i $store-kontoen din.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Administrer i $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current av $max brukt';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Ca. ${seconds}s igjen';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done av $total studiofotografier klare';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready av $total studiofotografier klare. Trykk på et element for å utelate det.';
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
  String get profileFieldNotSet => 'Nei';
}
