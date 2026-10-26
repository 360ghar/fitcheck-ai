// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Hem';

  @override
  String get tabPhotoshoot => 'Fotografering';

  @override
  String get tabCloset => 'Garderob';

  @override
  String get tabOutfits => 'Outfits';

  @override
  String get tabMore => 'Mer';

  @override
  String get actionAddItem => 'Lägg till plagg';

  @override
  String get actionCreateOutfit => 'Skapa outfit';

  @override
  String get actionCancel => 'Avbryt';

  @override
  String get actionDelete => 'Ta bort';

  @override
  String get actionSave => 'Spara';

  @override
  String get actionRetry => 'Försök igen';

  @override
  String get actionDone => 'Klar';

  @override
  String get actionNext => 'Nästa';

  @override
  String get actionBack => 'Tillbaka';

  @override
  String get actionClose => 'Stäng';

  @override
  String get actionSearch => 'Sök';

  @override
  String get actionContinue => 'Fortsätt';

  @override
  String get stateLoading => 'Laddar';

  @override
  String get stateErrorTitle => 'Något gick fel';

  @override
  String get stateErrorBody =>
      'Försök igen. Kontakta support om problemet kvarstår.';

  @override
  String get stateOfflineTitle => 'Du är offline';

  @override
  String get stateOfflineBody =>
      'Återanslut för att synka din garderob och skapa outfits.';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsPreferencesSection => 'Preferenser';

  @override
  String get settingsPlanBilling => 'Prenumeration och betalning';

  @override
  String get settingsLanguage => 'Språk';

  @override
  String get settingsNotifications => 'Notiser';

  @override
  String get settingsUnits => 'Måttenheter';

  @override
  String get settingsAppearance => 'Utseende';

  @override
  String get settingsPrivacySection => 'Integritet och data';

  @override
  String get settingsAboutSection => 'Om';

  @override
  String get settingsSignOut => 'Logga ut';

  @override
  String get settingsDeleteAccount => 'Radera konto';

  @override
  String get settingsDeleteAccountTitle => 'Radera ditt konto?';

  @override
  String get settingsDeleteAccountBody =>
      'Detta tar bort din garderob, outfits, foton och profil. Det går inte att ångra.';

  @override
  String get settingsUnitsImperial => 'Imperial (tum, lb)';

  @override
  String get settingsUnitsMetric => 'Metriskt (cm, kg)';

  @override
  String get languageTitle => 'Språk';

  @override
  String get languageSystem => 'Använd enhetens språk';

  @override
  String get languageSystemBody => 'FitCheck AI följer telefonens språk.';

  @override
  String get languageSearchHint => 'Sök språk';

  @override
  String get languageCurrent => 'Nuvarande';

  @override
  String get languageReviewNote =>
      'Denna översättning är ny. Säg till om något låter fel.';

  @override
  String get languageChanged => 'Språk uppdaterat';

  @override
  String get paywallTitle => 'Välj din plan';

  @override
  String get paywallTrialBadge => '1 månad gratis';

  @override
  String get paywallTrialTitle => 'Din första månad med Pro är gratis';

  @override
  String get paywallTrialBody =>
      'Ladda upp hela din garderob på en gång. Lägg till plagg efter hand.';

  @override
  String get paywallFreeForeverTitle => 'Gratis för alltid';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Inget kort behövs. Varje månad får du $uploads AI-uppladdningar, $outfits outfits och $images fotograferingsbilder per dag.';
  }

  @override
  String get paywallCtaTrial => 'Starta min gratis månad';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Uppgradera till $plan';
  }

  @override
  String get paywallRestore => 'Återställ köp';

  @override
  String get paywallManage => 'Hantera prenumeration';

  @override
  String get paywallTerms => 'Användarvillkor';

  @override
  String get paywallPrivacy => 'Integritetspolicy';

  @override
  String get paywallPerMonth => 'per månad';

  @override
  String get paywallPerYear => 'per år';

  @override
  String get paywallBestValue => 'Bäst värde';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Gratis provperiod endast för nya prenumeranter. Efter provperioden förnyas Pro till $price om den inte sägs upp minst 24 timmar innan den löper ut.';
  }

  @override
  String get introTitle => 'Din garderob, äntligen organiserad';

  @override
  String get introBody =>
      'Fotografera dina kläder en gång. Få outfit-idéer, virtuella provningar och studiofoton på det du redan äger.';

  @override
  String get introStart => 'Kom igång';

  @override
  String get introHaveAccount => 'Jag har redan ett konto';

  @override
  String get introSkip => 'Hoppa över';

  @override
  String get authSignIn => 'Logga in';

  @override
  String get authSignUp => 'Skapa konto';

  @override
  String get authEmail => 'E-post';

  @override
  String get authPassword => 'Lösenord';

  @override
  String get authForgotPassword => 'Glömt lösenord?';

  @override
  String get authContinueApple => 'Fortsätt med Apple';

  @override
  String get authContinueGoogle => 'Fortsätt med Google';

  @override
  String get authOrDivider => 'eller';

  @override
  String get wardrobeTitle => 'Garderob';

  @override
  String get wardrobeEmptyTitle => 'Din garderob är tom';

  @override
  String get wardrobeEmptyBody =>
      'Lägg till ditt första plagg, eller ladda upp ett foto på hela garderoben på en gång.';

  @override
  String get wardrobeAddFirst => 'Lägg till första plagget';

  @override
  String get wardrobeSearchHint => 'Sök i din garderob';

  @override
  String get categoryTops => 'Överdelar';

  @override
  String get categoryBottoms => 'Underdelar';

  @override
  String get categoryShoes => 'Skor';

  @override
  String get categoryAccessories => 'Accessoarer';

  @override
  String get categoryOuterwear => 'Ytterkläder';

  @override
  String get categorySwimwear => 'Badkläder';

  @override
  String get categoryActivewear => 'Träningskläder';

  @override
  String get categoryOther => 'Övrigt';

  @override
  String get conditionClean => 'Ren';

  @override
  String get conditionDirty => 'Smutsig';

  @override
  String get conditionLaundry => 'I tvätten';

  @override
  String get conditionRepair => 'Behöver lagas';

  @override
  String get conditionDonate => 'Att skänka';

  @override
  String get seasonSpring => 'Vår';

  @override
  String get seasonSummer => 'Sommar';

  @override
  String get seasonFall => 'Höst';

  @override
  String get seasonWinter => 'Vinter';

  @override
  String get seasonAll => 'Året om';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formell';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sportig';

  @override
  String get styleBohemian => 'Bohemisk';

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
  String get styleArtsy => 'Konstnärlig';

  @override
  String get styleClassic => 'Klassisk';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Annat';

  @override
  String get occasionWork => 'Jobb';

  @override
  String get occasionDateNight => 'Dejt';

  @override
  String get occasionTravel => 'Resa';

  @override
  String get occasionWedding => 'Bröllop';

  @override
  String get occasionGym => 'Träning';

  @override
  String get occasionWeekend => 'Helg';

  @override
  String get occasionParty => 'Fest';

  @override
  String get occasionInterview => 'Anställningsintervju';

  @override
  String get colorBlack => 'Svart';

  @override
  String get colorWhite => 'Vit';

  @override
  String get colorGrey => 'Grå';

  @override
  String get colorNavy => 'Marinblå';

  @override
  String get colorBrown => 'Brun';

  @override
  String get colorRed => 'Röd';

  @override
  String get colorBlue => 'Blå';

  @override
  String get colorGreen => 'Grön';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorYellow => 'Gul';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Idag';

  @override
  String get dateYesterday => 'Igår';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagar sedan',
      one: '1 dag sedan',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veckor sedan',
      one: '1 vecka sedan',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count månader sedan',
      one: '1 månad sedan',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count år sedan',
      one: '1 år sedan',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Gillar du FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Ett snabbt betyg hjälper andra att hitta sin stil.';

  @override
  String get ratingPromptYes => 'Betygsätt appen';

  @override
  String get ratingPromptNo => 'Inte nu';

  @override
  String get closetNoMatchesTitle => 'Inga plagg matchar';

  @override
  String get closetNoMatchesBody =>
      'Prova färre filter eller en annan sökning.';

  @override
  String get closetClearFilters => 'Rensa filter';

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
  String get closetLoading => 'Laddar dina plagg';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count markerade',
      one: '1 markerad',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Radera markerade';

  @override
  String get closetCancelSelection => 'Avbryt markering';

  @override
  String get closetCloseSearch => 'Stäng sökning';

  @override
  String get closetShowGrid => 'Visa som rutnät';

  @override
  String get closetShowList => 'Visa som lista';

  @override
  String get closetShowRows => 'Visa som rader';

  @override
  String get closetStatsTitle => 'Garderobsstatistik';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Radera $count plagg?',
      one: 'Radera 1 plagg?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Outfits som använder dem förlorar dessa plagg.';

  @override
  String get closetSortBy => 'Sortera efter';

  @override
  String get closetFavourites => 'Favoriter';

  @override
  String get closetFavourite => 'Favorit';

  @override
  String get closetUnfavourite => 'Ta bort favorit';

  @override
  String get closetWoreToday => 'Bar den idag';

  @override
  String closetWornTimes(int count) {
    return 'Använd $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategori';

  @override
  String get closetUseCaseLabel => 'Användningstillfälle';

  @override
  String get closetAnyUseCase => 'Valfri';

  @override
  String get closetOtherUseCase => 'Annat tillfälle';

  @override
  String get closetOtherUseCaseHint => 'Till exempel brunch';

  @override
  String get closetUseUseCase => 'Använd denna';

  @override
  String get closetClearAll => 'Rensa alla';

  @override
  String get sortNewest => 'Nyast först';

  @override
  String get sortOldest => 'Äldst först';

  @override
  String get sortName => 'Namn (A–Ö)';

  @override
  String get sortMostWorn => 'Mest använda';

  @override
  String get useCaseInformal => 'Ledigt';

  @override
  String get useCaseDate => 'Dejt';

  @override
  String get useCaseDinner => 'Middag';

  @override
  String get useCaseLunch => 'Lunch';

  @override
  String get actionSelect => 'Välj';

  @override
  String get actionEdit => 'Redigera';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sortera';

  @override
  String get actionAll => 'Alla';

  @override
  String get dashboardStartClosetTitle => 'Bygg din garderob';

  @override
  String get dashboardStartClosetBody =>
      'Fotografera några plagg. Vi taggar dem åt dig.';

  @override
  String get dashboardPieces => 'plagg';

  @override
  String get dashboardOutfits => 'set';

  @override
  String get dashboardDayStreak => 'dagars svit';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count denna månad';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Bästa $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoriter',
      one: '1 favorit',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sparade outfits',
      one: '1 sparad outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Mest använda: $name, $count gånger';
  }

  @override
  String get setupSkip => 'Hoppa över';

  @override
  String get setupWhoTitle => 'Vem stylar vi?';

  @override
  String get setupWhoBody =>
      'Väljer modell för provning och foton. Du kan ändra detta i profilen.';

  @override
  String get setupStyleTitle => 'Vad har du på dig oftast?';

  @override
  String get setupStyleBody => 'Välj valfria. Outfitidéer utgår från dessa.';

  @override
  String get setupClosetTitle => 'Lägg till dina första plagg.';

  @override
  String get setupClosetBody =>
      'Fotografera några kläder, eller en hög med dem. Varje plagg friläggs och sparas åt dig.';

  @override
  String get setupAddClothes => 'Lägg till kläder';

  @override
  String get setupStylesLabel => 'Stilar';

  @override
  String get setupOccasionsLabel => 'Tillfällen';

  @override
  String get setupSkipStep => 'Hoppa över';

  @override
  String get setupLater => 'Senare';

  @override
  String get setupSaveError => 'Kunde inte spara';

  @override
  String get genderWomen => 'Dam';

  @override
  String get genderMen => 'Herr';

  @override
  String get genderNonBinary => 'Icke-binär';

  @override
  String get genderPreferNotToSay => 'Vill inte uppge';

  @override
  String get outfitEmptyTitle => 'Inga outfits än';

  @override
  String get outfitEmptyBody =>
      'Kombinera plagg från garderoben och spara looken.';

  @override
  String get outfitNoMatchesTitle => 'Inga matchande outfits';

  @override
  String get outfitSearchHint => 'Sök bland dina outfits';

  @override
  String get outfitLoading => 'Laddar dina outfits';

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
  String get outfitFilterMenu => 'Stil och säsong';

  @override
  String get outfitCollections => 'Kollektioner';

  @override
  String get outfitDuplicate => 'Duplicera';

  @override
  String get outfitDeleteTitle => 'Ta bort denna outfit?';

  @override
  String get outfitDeleteBody => 'Plaggen finns kvar i din garderob.';

  @override
  String get outfitDrafts => 'Utkast';

  @override
  String get outfitDraft => 'Utkast';

  @override
  String get filterStyle => 'Stil';

  @override
  String get filterSeason => 'Säsong';

  @override
  String get itemDetailDeleteTitle => 'Ta bort plagget?';

  @override
  String get itemDetailDeleteBody =>
      'Outfits som använder detta plagg förlorar det.';

  @override
  String get itemAddFavourite => 'Lägg till i favoriter';

  @override
  String itemSize(String size) {
    return 'Storlek $size';
  }

  @override
  String get itemColours => 'Färger';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Mönster';

  @override
  String get itemUseCases => 'Användning';

  @override
  String get itemKeptIn => 'Förvaring';

  @override
  String get itemPrice => 'Pris';

  @override
  String get itemBought => 'Köpt';

  @override
  String get itemTags => 'Taggar';

  @override
  String get itemAdded => 'Tillagd';

  @override
  String get itemTimesWornLabel => 'gånger använd';

  @override
  String get itemLastWornLabel => 'senast använd';

  @override
  String get itemNeverWorn => 'Aldrig';

  @override
  String get authEntryBody =>
      'Varje plagg du äger, stylat av AI. Planera outfits, pröva dem, fota dem.';

  @override
  String get authCreateCloset => 'Skapa din garderob';

  @override
  String get authWelcomeBack => 'Välkommen tillbaka';

  @override
  String get authSignInBody => 'Logga in för att öppna din garderob.';

  @override
  String get authCreateAccount => 'Skapa ett konto';

  @override
  String get authCreateClosetBody =>
      'Det tar en minut. Dina första plagg är gratis.';

  @override
  String get authName => 'Namn';

  @override
  String get authConfirmPassword => 'Bekräfta lösenord';

  @override
  String get authReferralCode => 'Värvningskod (valfritt)';

  @override
  String get authResetTitle => 'Återställ lösenord';

  @override
  String get authResetBody => 'Vi skickar en länk för att välja ett nytt.';

  @override
  String get authSendResetLink => 'Skicka återställningslänk';

  @override
  String get authBackToSignIn => 'Tillbaka till inloggning';

  @override
  String get authEnterEmail => 'Ange din e-post';

  @override
  String get authEnterValidEmail => 'Ange en giltig e-post';

  @override
  String get authEnterPassword => 'Ange ditt lösenord';

  @override
  String get authPasswordTooShort => 'Minst 6 tecken';

  @override
  String get authShowPassword => 'Visa lösenord';

  @override
  String get authHidePassword => 'Dölj lösenord';

  @override
  String get authNewHere => 'Ny här?';

  @override
  String authConfirmEmail(String email) {
    return 'Bekräfta $email innan du loggar in. Kolla inkorgen.';
  }

  @override
  String get authResendEmail => 'Skicka igen';

  @override
  String get authResendingEmail => 'Skickar…';

  @override
  String get authPasswordsDoNotMatch => 'Lösenorden matchar inte';

  @override
  String get authEnterName => 'Ange ditt namn';

  @override
  String get authChoosePassword => 'Välj ett lösenord';

  @override
  String get authHaveAccount => 'Har du ett konto?';

  @override
  String get authCodeAccepted => 'Kod godkänd';

  @override
  String get authCodeNotFound => 'Koden hittades inte';

  @override
  String authReferralFrom(String name) {
    return 'Från $name. Ni får båda en månad gratis.';
  }

  @override
  String get authReferralInvalid => 'Vi kunde inte hitta den här koden.';

  @override
  String authResetSent(String email) {
    return 'Skickat till $email. Öppna länken på den här telefonen.';
  }

  @override
  String get introSlide1Title => 'Fota garderoben en gång.';

  @override
  String get introSlide1Body =>
      'Fotografera en klädhög. Varje plagg friläggs och sparas åt dig.';

  @override
  String get introSlide2Title => 'Klä dig snabbare.';

  @override
  String get introSlide2Body =>
      'Kombinationer av det du äger, anpassade efter planer och väder.';

  @override
  String get introSlide3Title => 'Se looken innan du tar på dig den.';

  @override
  String get introSlide3Body =>
      'Prova stilar på ditt eget foto, eller fota dem som en kampanj.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Ljust';

  @override
  String get settingsThemeDark => 'Mörkt';

  @override
  String get settingsTemperature => 'Temperatur';

  @override
  String get settingsEmailUpdates => 'E-postuppdateringar';

  @override
  String get settingsEmailUpdatesBody => 'Nyheter och tips via e-post';

  @override
  String get settingsOutfitReminders => 'Outfitpåminnelser';

  @override
  String get settingsOutfitRemindersBody =>
      'En påminnelse om att logga vad du bar';

  @override
  String get settingsWeeklySummary => 'Veckosammanfattning';

  @override
  String get settingsWeeklySummaryBody => 'Din vecka i outfits';

  @override
  String get settingsStyleSection => 'Stil';

  @override
  String get settingsPreferredStyles => 'Stilar du gillar';

  @override
  String get settingsPreferredColours => 'Färger du gillar';

  @override
  String get settingsNoneChosen => 'Inga valda';

  @override
  String get settingsPlanAiSection => 'Plan och AI';

  @override
  String get settingsPlanBillingBody => 'Plan, förbrukning och uppgraderingar';

  @override
  String get settingsPlanUsageBody => 'Plan och förbrukning';

  @override
  String get settingsInviteFriends => 'Bjud in vänner';

  @override
  String get settingsInviteFriendsBody =>
      'En gratis månad för varje vän som går med';

  @override
  String get settingsAiProvider => 'AI-leverantör';

  @override
  String get settingsAiProviderBody =>
      'Använd din egen modell för taggning och bilder';

  @override
  String get settingsAppVersion => 'Appversion';

  @override
  String get settingsPrivacyTerms => 'Integritet och villkor';

  @override
  String get settingsReportProblem => 'Rapportera ett problem';

  @override
  String get settingsChangePassword => 'Ändra lösenord';

  @override
  String get settingsExportData => 'Exportera din data';

  @override
  String get settingsExportBody =>
      'Vi förbereder en fil med allt du har sparat och öppnar nedladdningen.';

  @override
  String get settingsExportAction => 'Exportera';

  @override
  String get settingsCurrentPassword => 'Nuvarande lösenord';

  @override
  String get settingsNewPassword => 'Nytt lösenord';

  @override
  String get settingsConfirmNewPassword => 'Bekräfta nytt lösenord';

  @override
  String get settingsEnterCurrentPassword => 'Ange ditt nuvarande lösenord';

  @override
  String get settingsEnterNewPassword => 'Ange ett nytt lösenord';

  @override
  String get settingsPasswordMin8 => 'Använd minst 8 tecken';

  @override
  String get settingsPasswordNeedsUpper => 'Lägg till en stor bokstav';

  @override
  String get settingsPasswordNeedsLower => 'Lägg till en liten bokstav';

  @override
  String get settingsPasswordNeedsDigit => 'Lägg till en siffra';

  @override
  String get settingsPasswordsNoMatch => 'Lösenorden matchar inte';

  @override
  String get settingsChangeAction => 'Ändra';

  @override
  String get itemAddSnapTitle => 'Fota ett plagg';

  @override
  String get itemAddSnapBody =>
      'Vi hittar varje plagg i bilden och skapar en ren studiobild av dem.';

  @override
  String get itemAddCamera => 'Ta ett foto';

  @override
  String get itemAddGallery => 'Välj från galleri';

  @override
  String get itemAddOtherWays => 'Andra sätt att lägga till';

  @override
  String get itemAddSeveral => 'Lägg till flera foton';

  @override
  String get itemAddSeveralBody => 'Upp till 50 samtidigt';

  @override
  String get itemAddImportProfile => 'Importera från profil';

  @override
  String get itemAddImportProfileBody => 'Instagram eller Facebook';

  @override
  String get itemAddEnterDetails => 'Ange detaljer själv';

  @override
  String get itemAddEnterDetailsBody => 'Inget foto behövs';

  @override
  String get itemManualIntro =>
      'Endast ett namn behövs. Fyll i resten nu eller senare.';

  @override
  String get itemManualNameHint => 'Till exempel blå bomullströja';

  @override
  String get itemManualEnterName => 'Ange ett namn';

  @override
  String get itemManualNotes => 'Anteckningar';

  @override
  String get itemManualBrand => 'Märke';

  @override
  String get itemManualSize => 'Storlek';

  @override
  String get itemManualEnterNumber => 'Ange ett nummer';

  @override
  String get itemManualSavePiece => 'Spara plagg';

  @override
  String get itemManualSaving => 'Sparar';

  @override
  String get itemManualSavedTitle => 'Sparat';

  @override
  String itemManualSavedBody(String name) {
    return '$name finns i din garderob.';
  }

  @override
  String get itemManualNotSaved => 'Inte sparat';

  @override
  String get itemManualAddUseCase => 'Lägg till användningsområde';

  @override
  String get itemManualAddUseCaseAction => 'Lägg till';

  @override
  String get itemPhotos => 'Bilder';

  @override
  String get itemAddPhotos => 'Lägg till bilder';

  @override
  String get itemNoPhotoYet => 'Ingen bild än. Du kan spara utan.';

  @override
  String get itemRemovePhoto => 'Ta bort bild';

  @override
  String get itemRemovePiece => 'Ta bort plagg';

  @override
  String get filterConditionLabel => 'Skick';

  @override
  String get photoshootStepPhotos => 'Bilder';

  @override
  String get photoshootStepSetup => 'Inställning';

  @override
  String get photoshootStepCreating => 'Skapar';

  @override
  String get photoshootStepResults => 'Resultat';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Steg $current av $total, $name';
  }

  @override
  String get photoshootOneFailed => 'En bild misslyckades. Försök igen nedan.';

  @override
  String photoshootManyFailed(int count) {
    return '$count bilder misslyckades. Försök igen nedan.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Hur många';

  @override
  String get photoshootYourPrompt => 'Din beskrivning';

  @override
  String get photoshootPromptHint => 'Golden hour på takterrass, linneskjorta';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skapa $count bilder',
      one: 'Skapa 1 bild',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'bilder',
      one: 'bild',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Kunde inte kontrollera dagens gräns.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan-plan: $remaining av $limit kvar idag';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratis';

  @override
  String get photoshootGallery => 'Galleri';

  @override
  String get photoshootUseCamera => 'Använd kamera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Ta bort bild $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Inga bilder skapades';

  @override
  String get photoshootNoPhotosBody =>
      'Plåtningen slutfördes utan bilder. Försök igen.';

  @override
  String get photoshootNewStyle => 'Ny stil';

  @override
  String get photoshootNewPhotos => 'Nya bilder';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Öppna bild $number';
  }

  @override
  String get photoshootReportPhoto => 'Rapportera bild';

  @override
  String get photoshootSaveToGallery => 'Spara i galleri';

  @override
  String get actionUpgrade => 'Uppgradera';

  @override
  String get referralLimitTitle => 'Dagens bilder är slut';

  @override
  String get referralLimitBody =>
      'Dina gratisbilder kommer tillbaka imorgon. Tipsa en vän så får ni båda en månad Pro gratis.';

  @override
  String get referralLimitRefer => 'Tipsa en vän';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dejtingapp';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetiskt';

  @override
  String get photoshootUseCustom => 'Din egen prompt';

  @override
  String get photoshootDescLinkedin => 'Skarpa porträtt för jobbet';

  @override
  String get photoshootDescDating => 'Avspänt, varmt och naturligt';

  @override
  String get photoshootDescPortfolio => 'Redaktionella modelooker';

  @override
  String get photoshootDescInstagram => 'Livsstilsbilder för flödet';

  @override
  String get photoshootDescAesthetic => 'Stämningsfulla, konstnärliga ramar';

  @override
  String get photoshootDescCustom => 'Beskriv looken du vill ha';

  @override
  String get aspectSquare => 'Kvadratisk';

  @override
  String get aspectPortrait => 'Stående';

  @override
  String get aspectLandscape => 'Liggande';

  @override
  String get aspectTall => 'Hög';

  @override
  String get aspectWide => 'Bred';

  @override
  String get tryOnAppBar => 'Virtuell provning';

  @override
  String get tryOnYourPhoto => 'Ditt foto';

  @override
  String get tryOnGarment => 'Plagg';

  @override
  String get tryOnUploadingPhoto => 'Laddar upp ditt foto';

  @override
  String get tryOnAddPhotoPrompt => 'Lägg till ett helkroppsfoto på dig själv';

  @override
  String get tryOnBodyPhotoHint => 'Ett helkroppsfoto fungerar bäst';

  @override
  String get tryOnAddPhoto => 'Lägg till foto';

  @override
  String get tryOnChangePhoto => 'Byt foto';

  @override
  String get tryOnPhotoLoadFailed => 'Vi kunde inte ladda ditt foto.';

  @override
  String get tryOnChooseGarment => 'Välj ett plaggsfoto';

  @override
  String get tryOnChooseOneGarment => 'Välj ett plaggfoto';

  @override
  String get tryOnGarmentHint =>
      'Ett platt liggande plagg eller på galge fungerar bäst';

  @override
  String get tryOnChange => 'Ändra';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Ta bort';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Stil';

  @override
  String get tryOnBackground => 'Bakgrund';

  @override
  String get tryOnPose => 'Posing';

  @override
  String get tryOnDressingUp => 'Kläder på. Detta tar ungefär en halv minut.';

  @override
  String get tryOnEmptyResult => 'Din provning visas här';

  @override
  String get tryOnReportImage => 'Rapportera bild';

  @override
  String get tryOnCreating => 'Skapar';

  @override
  String get tryOnTryAgain => 'Försök igen';

  @override
  String get tryOnCreate => 'Skapa provning';

  @override
  String get tryOnBackgroundStudioWhite => 'Studiovit';

  @override
  String get tryOnBackgroundStudioGrey => 'Studiogrå';

  @override
  String get tryOnBackgroundUrban => 'Stadsmiljö';

  @override
  String get tryOnBackgroundNature => 'Natur';

  @override
  String get tryOnBackgroundMinimal => 'Minimalistisk';

  @override
  String get tryOnPoseFront => 'Stående framifrån';

  @override
  String get tryOnPoseSide => 'Stående från sidan';

  @override
  String get tryOnPoseWalking => 'Gående';

  @override
  String get dashboardGreetingMorning => 'God morgon';

  @override
  String get dashboardGreetingAfternoon => 'God eftermiddag';

  @override
  String get dashboardGreetingEvening => 'God kväll';

  @override
  String get dashboardWelcome => 'Välkommen';

  @override
  String get dashboardOpenProfile => 'Öppna profil';

  @override
  String get dashboardRailToday => 'Idag';

  @override
  String get dashboardRailRecently => 'Senaste';

  @override
  String get dashboardActivityEmpty => 'Nya plagg och outfits visas här.';

  @override
  String get quickAddPiece => 'Lägg till plagg';

  @override
  String get quickAddPieceBody => 'Fota och tagga';

  @override
  String get quickBuildOutfit => 'Skapa outfit';

  @override
  String get quickBuildOutfitBody => 'Kombinera dina plagg';

  @override
  String get quickForYou => 'För dig';

  @override
  String get quickForYouBody => 'Dagens val';

  @override
  String get quickPlanWeek => 'Planera veckan';

  @override
  String get quickPlanWeekBody => 'Outfits per datum';

  @override
  String get referralBannerUrgent => 'Börjar det ta slut? Bjud in en vän.';

  @override
  String get referralBannerTitle => 'Ge en månad, få en månad.';

  @override
  String get referralBannerBody => 'Du och din vän får en månad Pro var.';

  @override
  String get referralBannerDismiss => 'Dölj en vecka';

  @override
  String get referralBannerShare => 'Dela inbjudan';

  @override
  String get referralBannerCopy => 'Kopiera länk';

  @override
  String get itemEditPieceTitle => 'Redigera plagg';

  @override
  String get itemEditDescriptionLabel => 'Beskrivning';

  @override
  String get itemEditNotSaved => 'Inte sparat';

  @override
  String get itemEditSavedTitle => 'Sparat';

  @override
  String get itemEditSavedBody => 'Dina ändringar har sparats.';

  @override
  String get itemEditSavedStalePhotos => 'Sparat — bilderna kan vara gamla';

  @override
  String get itemEditRemovePieceHint => 'Ta bort detta plagg från plaggvyn.';

  @override
  String get itemEditNoPhotos =>
      'Inga bilder än. Lägg till från galleri eller kamera.';

  @override
  String get itemEditKeepPhoto => 'Behåll bild';

  @override
  String get itemEditRemoved => 'Borttagen';

  @override
  String get itemEditAddUseCaseAction => 'Lägg till';

  @override
  String get statsNoStatsTitle => 'Ingen statistik än';

  @override
  String get statsNoStatsBody =>
      'Lägg till några plagg så visas din garderobsfördelning här.';

  @override
  String get statsByCategory => 'Per kategori';

  @override
  String get statsTotalValue => 'totalt värde';

  @override
  String get statsMostWorn => 'Mest använda';

  @override
  String get statsLeastWorn => 'Väntar på sin tur';

  @override
  String get statsUnnamedPiece => 'Namnlöst plagg';

  @override
  String get jobsTitle => 'Skanningar';

  @override
  String get jobsEmptyTitle => 'Inga skanningar än';

  @override
  String get jobsEmptyBody =>
      'Fota ett plagg och skicka det till bakgrunden – det fortsätter arbeta här.';

  @override
  String get jobsNotCancelled => 'Ej avbruten';

  @override
  String get jobsResume => 'Återuppta';

  @override
  String get jobsReview => 'Granska';

  @override
  String get jobsStop => 'Stoppa';

  @override
  String get jobsDismiss => 'Avfärda';

  @override
  String get reportTitle => 'Anmäl innehåll';

  @override
  String reportIntro(String contentType) {
    return 'Berätta vad som är fel med detta $contentType. Vårt team granskar varje anmälan.';
  }

  @override
  String get reportReasonInappropriate => 'Olämpligt eller stötande';

  @override
  String get reportReasonNudity => 'Nakenhet eller sexuellt innehåll';

  @override
  String get reportReasonHarassment => 'Trakasserier eller kränkningar';

  @override
  String get reportReasonImpersonation => 'Utger sig för att vara någon annan';

  @override
  String get reportReasonOther => 'Annat';

  @override
  String get reportDetailsLabel => 'Ytterligare detaljer (valfritt)';

  @override
  String get reportSubmit => 'Skicka anmälan';

  @override
  String get reportSubmittedTitle => 'Anmälan skickad';

  @override
  String get reportSubmittedBody =>
      'Tack. Vårt team kommer att granska innehållet.';

  @override
  String get reportFailedTitle => 'Kunde inte skicka anmälan';

  @override
  String get reportFailedBody => 'Vänligen försök igen.';

  @override
  String get reportContentTryOnImage => 'AI-provningsbild';

  @override
  String get reportContentSharedOutfit => 'delad outfit';

  @override
  String get reportContentPhotoshootImage => 'AI-fotobild';

  @override
  String get sharedOutfitTitle => 'Delad outfit';

  @override
  String get sharedOutfitHideTooltip => 'Dölj denna outfit';

  @override
  String get sharedOutfitReportTooltip => 'Rapportera denna outfit';

  @override
  String get sharedOutfitHideTitle => 'Dölj denna outfit?';

  @override
  String get sharedOutfitHideBody =>
      'Den förblir dold på denna enhet. Du kan även rapportera den så att vårt team kan granska och ta bort den.';

  @override
  String get sharedOutfitHideAction => 'Dölj';

  @override
  String get sharedOutfitHiddenInfo =>
      'Denna outfit kommer inte att visas på denna enhet igen.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit dold';

  @override
  String get sharedOutfitMissingTitle => 'Denna outfit finns inte längre';

  @override
  String get sharedOutfitMissingBody =>
      'Den kan ha tagits bort eller så är länken felaktig.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Du har dolt denna outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Om den var olämplig, rapportera den via Integritet och villkor eller mejla $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Gillar du stilen?';

  @override
  String get sharedOutfitCtaBody =>
      'Skapa liknande outfits från din egen garderob.';

  @override
  String get sharedOutfitCtaButton => 'Skaffa FitCheck AI';

  @override
  String get errorTitle => 'Fel';

  @override
  String get errorUnknown => 'Ett oväntat fel uppstod';

  @override
  String get errorNoConnection =>
      'Ingen internetanslutning. Kontrollera ditt nätverk.';

  @override
  String get errorTimeout => 'Förfrågan tog för lång tid. Försök igen.';

  @override
  String get errorServerError => 'Något gick fel hos oss. Försök igen.';

  @override
  String get errorBadGateway =>
      'Vår server är tillfälligt otillgänglig. Försök igen.';

  @override
  String get errorServiceUnavailable =>
      'Tjänsten är tillfälligt otillgänglig. Försök igen snart.';

  @override
  String get errorInternalError => 'Något gick fel. Försök igen.';

  @override
  String get errorUnauthorized => 'Logga in för att fortsätta.';

  @override
  String get errorForbidden => 'Du har inte behörighet till detta.';

  @override
  String get errorSessionExpired => 'Din session har löpt ut. Logga in igen.';

  @override
  String get errorInvalidCredentials => 'Felaktig e-postadress eller lösenord.';

  @override
  String get errorTokenRefreshFailed =>
      'Kunde inte förnya din session. Logga in igen.';

  @override
  String get errorRequestCancelled => 'Förfrågan avbruten.';

  @override
  String get errorInvalidFormat => 'Filformatet stöds inte.';

  @override
  String get errorFileTooLarge => 'Filen är för stor.';

  @override
  String get errorUploadFailed => 'Uppladdningen misslyckades. Försök igen.';

  @override
  String get errorCacheCorrupted => 'Sparad data skadades och har återställts.';

  @override
  String get errorCacheNotFound => 'Inget har sparats än.';

  @override
  String get errorUserNotFound => 'Vi kunde inte hitta det kontot.';

  @override
  String get errorItemNotFound => 'Plagget finns inte längre.';

  @override
  String get errorOutfitNotFound => 'Outfitten finns inte längre.';

  @override
  String get rewardsTitle => 'Belöningar';

  @override
  String get rewardsNoAchievementsTitle => 'Inga prestationer än';

  @override
  String get rewardsNoAchievementsBody =>
      'Lägg till plagg och planera outfits för att tjäna din första.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Ingen på listan än';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planera outfits för att tjäna poäng och synas här.';

  @override
  String get legalViewPrivacyPolicy => 'Visa integritetspolicy';

  @override
  String get aiConsentAgree => 'Godkänn & fortsätt';

  @override
  String get aiConsentNotNow => 'Inte nu';

  @override
  String get imageViewerCloseTooltip => 'Stäng bildvisare';

  @override
  String get updateReadyTitle => 'Uppdatering redo';

  @override
  String get updateReadyBody =>
      'Starta om FitCheck AI för att tillämpa de senaste förbättringarna.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI behöver kameratårkomst för att ta foton av dina outfits och garderobsplagg.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI behöver åtkomst till ditt bildbibliotek för att välja bilder på dina outfits och garderobsplagg.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI behöver spara dina AI-genererade outfitbilder i ditt bildbibliotek.';

  @override
  String get wardrobeSomePhotosSkipped => 'Vissa foton hoppades över';

  @override
  String get wardrobePhotosNotAdded => 'Foton lades inte till';

  @override
  String get wardrobePhotoNotAdded => 'Foto lades inte till';

  @override
  String get wardrobeNotStartedTitle => 'Ej startad';

  @override
  String get wardrobeNoRoomTitle => 'Inget utrymme';

  @override
  String get wardrobeAddPhotosSemantic => 'Lägg till foton';

  @override
  String get batchAddTileLabel => 'Lägg till';

  @override
  String get batchProfileLinkLabel => 'Profilänk';

  @override
  String get wardrobeImportFromProfileTitle => 'Importera från en profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Lägg till flera foton';

  @override
  String get wardrobeClearAction => 'Rensa';

  @override
  String get wardrobeRefreshTooltip => 'Uppdatera';

  @override
  String get batchNoPhotosYetTitle => 'Inga foton än';

  @override
  String get batchChoosePhotosAction => 'Välj foton';

  @override
  String get batchWeFindEachPieceBody =>
      'Vi hittar varje plagg och gör ett studiofoto av det.';

  @override
  String get batchPreparingPhotosSemantic => 'Förbereder foton';

  @override
  String get batchPhotosProcessedSemantic => 'Foton bearbetade';

  @override
  String get batchPasteProfileLinkTitle => 'Klistra in en profillänk';

  @override
  String get batchPasteProfileLinkBody =>
      'En offentlig Instagram- eller Facebook-profil. Vi skannar dess foton och du väljer vad som hamnar i din garderob.';

  @override
  String get batchClearLinkTooltip => 'Rensa länk';

  @override
  String get batchStartingButton => 'Startar';

  @override
  String get batchStartImportAction => 'Starta import';

  @override
  String get batchReviewEveryPhotoTitle => 'Du granskar varje foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Inget läggs till förrän du godkänner det.';

  @override
  String get batchPrivateProfilesTitle => 'Privata profiler';

  @override
  String get batchPrivateProfilesBody =>
      'Anslut ditt konto. Instagram kräver också användarnamn och lösenord.';

  @override
  String get batchUseAnotherLinkAction => 'Använd en annan länk';

  @override
  String get batchSignInNeededTitle => 'Inloggning krävs';

  @override
  String get batchEnterYourCodeTitle => 'Ange din kod';

  @override
  String get batchUseUsernamePasswordAction =>
      'Använd användarnamn och lösenord';

  @override
  String get batchAlreadyConnectedAction =>
      'Jag har redan anslutit i webbläsaren';

  @override
  String get batchEnterCodeAction => 'Ange kod';

  @override
  String get batchTryAnotherWayAction => 'Prova på ett annat sätt';

  @override
  String get batchLiveStatus => 'Aktiv';

  @override
  String get batchReconnectingStatus => 'Återansluter';

  @override
  String get batchSignInToInstagramTitle => 'Logga in på Instagram';

  @override
  String get batchUsernameLabel => 'Användarnamn';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kod, om du använder tvåstegsverifiering';

  @override
  String get batchAuthenticatorCodeBody =>
      'Använd den 6-siffriga koden från din autentiseringsapp. Koderna ändras snabbt.';

  @override
  String get batchVerifyAction => 'Verifiera';

  @override
  String get batchFindingPhotosTitle => 'Hittar foton';

  @override
  String get batchImportPausedTitle => 'Import pausad';

  @override
  String get batchProcessingPhotosTitle => 'Behandlar foton';

  @override
  String get batchWaitingNextPhoto => 'Väntar på nästa foto';

  @override
  String get batchCancelImportAction => 'Avbryt import';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Inga plagg hittades på det här fotot.';

  @override
  String get batchEditPieceColoursLabel => 'Färger, separerade med kommatecken';

  @override
  String get batchAddToClosetAction => 'Lägg till i garderoben';

  @override
  String get batchSkipPhotoAction => 'Hoppa över foto';

  @override
  String get batchImportCompleteTitle => 'Import klar';

  @override
  String get batchImportFailedTitle => 'Import misslyckades';

  @override
  String get batchImportCancelledTitle => 'Import avbruten';

  @override
  String get batchImportErrorBody => 'Något gick fel vid importen.';

  @override
  String get batchNothingMoreImportedBody =>
      'Inget mer importeras från den här profilen.';

  @override
  String get batchViewClosetAction => 'Visa garderob';

  @override
  String get batchStartOverAction => 'Börja om';

  @override
  String get wardrobeAddPieceTitle => 'Lägg till plagg';

  @override
  String get wardrobeAddDetailsTitle => 'Lägg till detaljer';

  @override
  String get wardrobeScanningTitle => 'Skannar';

  @override
  String get batchReviewPiecesTitle => 'Granska plagg';

  @override
  String get wardrobeGalleryAction => 'Galleri';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Ny';

  @override
  String get wardrobeRemovePhotoTooltip => 'Ta bort foto';

  @override
  String get batchRunInBackgroundTooltip => 'Kör i bakgrunden';

  @override
  String get batchStepOneOfTwo => 'Steg 1 av 2';

  @override
  String get batchStepTwoOfTwo => 'Steg 2 av 2';

  @override
  String get batchUploadingPhotosTitle => 'Laddar upp foton';

  @override
  String get batchFindingPiecesTitle => 'Hittar plagg';

  @override
  String get batchMakingStudioPhotosTitle => 'Skapar studiofoton';

  @override
  String get batchStoppedLabel => 'Stoppad';

  @override
  String get batchFindingPiecesStoppedTitle => 'Sökning efter plagg stoppad';

  @override
  String get batchCancelledLabel => 'Avbruten';

  @override
  String get batchAllDoneTitle => 'Klart';

  @override
  String get batchOpeningPiecesBody => 'Öppnar dina plagg';

  @override
  String get batchNothingSavedBody => 'Inget sparades.';

  @override
  String get batchFindingPiecesFailedBody => 'Det gick inte att hitta plagg.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Sökningen efter plagg stoppades i förtid.';

  @override
  String get batchStopFindingPiecesTitle => 'Vill du avbryta sökningen?';

  @override
  String get batchStopFindingPiecesBody =>
      'Skanningen stoppas och inget sparas. Plagg som redan hittats finns kvar i din historik tills du rensar dem.';

  @override
  String get batchKeepGoingAction => 'Fortsätt';

  @override
  String get batchTryAgainAction => 'Försök igen';

  @override
  String get batchBackToPhotosAction => 'Tillbaka till foton';

  @override
  String get batchSkipAllAction => 'Hoppa över alla';

  @override
  String get batchIncludeAllAction => 'Inkludera alla';

  @override
  String get batchNoPiecesFoundTitle => 'Inga plagg hittades';

  @override
  String get batchNoPiecesFoundBody =>
      'Vi hittade inga kläder på dessa bilder.';

  @override
  String get batchChooseOtherPhotosAction => 'Välj andra bilder';

  @override
  String get batchUseCaseHelper => 'Läggs till för varje plagg du sparar.';

  @override
  String get batchDiscardPiecesTitle => 'Kasta dessa plagg?';

  @override
  String get batchDiscardPiecesBody => 'Inget från den här batchen sparas.';

  @override
  String get batchKeepAction => 'Behåll';

  @override
  String get batchDiscardAction => 'Kasta';

  @override
  String get batchRemovePieceTitle => 'Ta bort detta plagg?';

  @override
  String get batchRemovePieceBody => 'Det sparas inte i din garderob.';

  @override
  String get batchRemoveAction => 'Ta bort';

  @override
  String get batchChoosePiecesToSave => 'Välj plagg att spara';

  @override
  String get batchDiscardAllAction => 'Kasta alla';

  @override
  String get batchNothingSavedRetryBody => 'Inget sparades. Försök igen.';

  @override
  String get batchNotSavedTitle => 'Inte sparad';

  @override
  String get batchSavingLabel => 'Sparar';

  @override
  String get batchSendToBackgroundAction => 'Kör i bakgrunden';

  @override
  String get batchStillWorkingMessage =>
      'Arbetar fortfarande. Vi meddelar dig när dina plagg är klara.';

  @override
  String get batchRunningInBackgroundTitle => 'Kör i bakgrunden';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studiofotona avstannade tidigt. Du kan fortfarande spara dessa plagg.';

  @override
  String get batchTapPieceToSkip =>
      'Tryck på ett plagg för att hoppa över det.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studiofoton är på väg. Du kan lämna – vi meddelar dig.';

  @override
  String get batchLeaveAction => 'Lämna';

  @override
  String get batchPeopleInPhotosTitle => 'Personer på bilderna';

  @override
  String get batchIncludeAction => 'Inkludera';

  @override
  String get batchSkipAction => 'Hoppa över';

  @override
  String get batchYourPhotoIsUsedLabel => 'Ditt foto används';

  @override
  String get batchMakingStudioPhotoLabel => 'Skapar studiofoto';

  @override
  String get batchNoStudioPhotoBody => 'Inget studiofoto. Ditt foto används.';

  @override
  String get batchEnterDetailsYourselfAction => 'Fyll i uppgifterna själv';

  @override
  String get batchChooseAnotherPhotoAction => 'Välj ett annat foto';

  @override
  String get batchConnectionLostTitle => 'Anslutningen bröts';

  @override
  String get batchConnectionLostBody =>
      'Kontrollera anslutningen och försök igen.';

  @override
  String get batchDailyLimitTitle => 'Daglig gräns nådd';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Uppgradera till Pro för fler skanningar eller fyll i uppgifterna själv.';

  @override
  String get batchDailyLimitBodyFree =>
      'Dina skanningar nollställs imorgon. Du kan fylla i uppgifterna själv nu.';

  @override
  String get batchSeePlansAction => 'Se planer';

  @override
  String get batchAiBusyTitle => 'Vår AI är upptagen';

  @override
  String get batchAiBusyBody =>
      'Detta beror på oss. Försök igen om några minuter.';

  @override
  String get batchNoPiecesBody =>
      'Prova ett tydligare foto eller fyll i uppgifterna själv.';

  @override
  String get batchScanningUnavailableTitle => 'Skanning är inte tillgänglig';

  @override
  String get batchScanningUnavailableBody =>
      'Fyll i uppgifterna själv så länge.';

  @override
  String get batchScanDidNotFinishTitle => 'Skanningen slutfördes inte';

  @override
  String get batchTryAgainBody => 'Försök igen.';

  @override
  String get billingTitle => 'Prenumeration';

  @override
  String get billingUpgradeHeading => 'Uppgradera din plan';

  @override
  String get billingUpgradeOnPlusBody => 'Samma funktioner, högre gränser.';

  @override
  String get billingUpgradeBody =>
      'Plus och Pro har samma funktioner. Välj de gränser du behöver.';

  @override
  String get billingWebUnavailableBody =>
      'Online-uppgraderingar är inte tillgängliga än. En kampanj- eller värvningskod låser fortfarande upp Plus eller Pro. Bjud in vänner nedan för att tjäna gratis månader.';

  @override
  String get billingPlansStale =>
      'Kunde inte ladda de senaste planerna. Priserna kan vara inaktuella.';

  @override
  String get billingMonthly => 'Månadsvis';

  @override
  String get billingYearly => 'Årsvis';

  @override
  String get billingCurrentPlan => 'Nuvarande plan';

  @override
  String get billingActive => 'Aktiv';

  @override
  String get billingThisMonth => 'Denna månad';

  @override
  String get billingItemExtractions => 'Plaggtillägg';

  @override
  String get billingOutfitVisualizations => 'Outfit-visualiseringar';

  @override
  String get billingNearLimitUpgrade =>
      'Du är nära månadens gräns. Uppgradera för fler.';

  @override
  String get billingNearLimitResets =>
      'Du är nära månadens gräns. Den nollställs i början av nästa månad.';

  @override
  String get billingStoreUnavailable =>
      'Uppgraderingar är inte tillgängliga i butiken än. Försök igen snart.';

  @override
  String get billingManageHeading => 'Hantera din plan';

  @override
  String get billingCancelPlan => 'Avsluta prenumeration';

  @override
  String get billingCancelKeepsAccess =>
      'Du behåller tillgången till slutet av denna period.';

  @override
  String get billingCancelConfirmTitle => 'Vill du avsluta prenumerationen?';

  @override
  String get billingKeepPlan => 'Behåll plan';

  @override
  String get billingCancelPlanAction => 'Avsluta plan';

  @override
  String get billingBilledMonthly => 'Faktureras månadsvis';

  @override
  String get billingBilledYearly => 'Faktureras årligen';

  @override
  String get billingVirtualTryOn => 'Virtuell provning';

  @override
  String get billingPrioritySupport => 'Prioriterad support';

  @override
  String get billingDisclosureProRenewing =>
      'Pro är en prenumeration som förnyas automatiskt';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus och Pro är prenumerationer som förnyas automatiskt';

  @override
  String get billingDisclosureAppleBilling =>
      'Betalningen debiteras ditt Apple-ID vid köpbekräftelse.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Betalningen debiteras ditt Google Play-konto vid köpbekräftelse.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Din prenumeration förnyas automatiskt för samma period till samma pris om du inte stänger av automatisk förnyelse minst 24 timmar innan den aktuella perioden slutar.';

  @override
  String get billingDisclosureAppleManage =>
      'Hantera eller avsluta när som helst i Inställningar › ditt Apple-ID › Prenumerationer.';

  @override
  String get billingDisclosureGoogleManage =>
      'Hantera eller avsluta när som helst i Google Play › Betalningar och prenumerationer.';

  @override
  String get billingReferFriend => 'Tipsa en vän';

  @override
  String get billingHowItWorks => 'Så funkar det';

  @override
  String get billingHowShareTitle => 'Dela din länk';

  @override
  String get billingHowShareBody => 'Skicka den till en vän.';

  @override
  String get billingHowSignUpTitle => 'De skapar ett konto';

  @override
  String get billingHowSignUpBody => 'Din vän ansluter sig via länken.';

  @override
  String get billingHowBothTitle => 'Ni får båda Pro';

  @override
  String get billingHowBothBody => 'Ni får varsin månad med Pro gratis.';

  @override
  String get billingYourReferrals => 'Dina inbjudningar';

  @override
  String get billingInvited => 'Inbjudna';

  @override
  String get billingJoined => 'Gått med';

  @override
  String get billingMonthsEarned => 'Intjänade månader';

  @override
  String get billingInviteFriend => 'Bjud in en vän';

  @override
  String get billingInviteBody => 'Du och din vän får en månads Pro var.';

  @override
  String get billingYourCode => 'Din kod';

  @override
  String get billingCopyLink => 'Kopiera länk';

  @override
  String get billingShareInvite => 'Dela inbjudan';

  @override
  String get giftUnavailable =>
      'Gåvinbjudningar är inte tillgängliga i den här versionen.';

  @override
  String get giftPageTitle => 'Ge bort FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Inga fria gåvinbjudningar är tillgängliga just nu.';

  @override
  String get giftFormTitle => 'Skicka en fri inbjudan';

  @override
  String get giftFormBody =>
      'Mottagaren löser in gåvan med denna verifierade e-postadress. Vi skickar inte e-postmeddelandet åt dig.';

  @override
  String get giftFieldFrom => 'Från';

  @override
  String get giftFieldRecipientName => 'Mottagarens namn';

  @override
  String get giftFieldRecipientEmail => 'Mottagarens e-post';

  @override
  String get giftFieldOccasion => 'Tillfälle (valfritt)';

  @override
  String get giftNoOccasion => 'Inget tillfälle';

  @override
  String get giftOccasionBirthday => 'Födelsedag';

  @override
  String get giftOccasionAnniversary => 'Årsdag';

  @override
  String get giftOccasionOther => 'Annat';

  @override
  String get giftFieldCardGreeting => 'Hälsning på kortet';

  @override
  String get giftFieldCardGreetingHelper =>
      'Detta visas på kortet exakt som det är skrivet.';

  @override
  String get giftFieldPrivateNote => 'Privat meddelande (valfritt)';

  @override
  String get giftCreateAction => 'Skapa fri gåva';

  @override
  String get giftClaimedTitle => 'Gåva inlöst';

  @override
  String get giftClaimedActive => 'Din gåva med FitCheck Pro är aktiv.';

  @override
  String get giftClaimedQueued =>
      'Din gåva med FitCheck Pro startar efter din nuvarande åtkomst.';

  @override
  String get giftLinkCopied => 'Gåvolänken har kopierats till urklipp.';

  @override
  String get giftErrorName => 'Ange ett namn.';

  @override
  String get giftErrorEmail => 'Ange en giltig e-postadress.';

  @override
  String get giftErrorGreeting => 'Ange en hälsning på kortet.';

  @override
  String get giftErrorGreetingLength => 'Använd högst 80 tecken.';

  @override
  String get giftClaimAction => 'Hämta gåva';

  @override
  String get giftCardPreview => 'Kortförhandsvisning';

  @override
  String get giftGiftForYou => 'En gåva till dig';

  @override
  String get giftGiftWaiting => 'En gåva väntar på dig';

  @override
  String get giftOpenBody =>
      'Öppna dina gåvor och hämta dem med din verifierade e-post.';

  @override
  String get giftOpenGifts => 'Öppna gåvor';

  @override
  String get giftSendInvitation => 'Skicka inbjudan';

  @override
  String get settingsAiProviderSection => 'Leverantör';

  @override
  String get settingsAiCustom => 'Anpassad';

  @override
  String get settingsAiUrlHelper =>
      'Använd en offentlig URL som servern kan nå. Localhost fungerar inte från våra servrar.';

  @override
  String get settingsAiConnectionSection => 'Anslutning';

  @override
  String get settingsAiApiUrl => 'API-URL';

  @override
  String get settingsAiApiKey => 'API-nyckel';

  @override
  String get settingsAiApiKeySaved => 'Sparad. Lämna tom för att behålla den.';

  @override
  String get settingsAiChatModel => 'Chattmodell';

  @override
  String get settingsAiVisionModel => 'Visionmodell (valfritt)';

  @override
  String get settingsAiImageModel => 'Bildmodell (valfritt)';

  @override
  String get settingsAiImageModelNote =>
      'Bildgenerering kräver OpenAI-kompatibla chattsvar med response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testa anslutning';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarGoToToday => 'Gå till idag';

  @override
  String get calendarConnectTooltip => 'Anslut en kalender';

  @override
  String get calendarAddEvent => 'Lägg till händelse';

  @override
  String get calendarEmptyTitle => 'Inget planerat';

  @override
  String get calendarEmptyBody =>
      'Lägg till en händelse och planera vad du ska ha på dig.';

  @override
  String get calendarPreviousMonth => 'Föregående månad';

  @override
  String get calendarNextMonth => 'Nästa månad';

  @override
  String get calendarAllDay => 'Hela dagen';

  @override
  String get calendarOutfitLinked => 'Klädsel kopplad';

  @override
  String get calendarEventOptions => 'Händelsealternativ';

  @override
  String get calendarDeleteTitle => 'Ta bort denna händelse?';

  @override
  String get calendarChangeOutfit => 'Byt outfit';

  @override
  String get calendarLinkOutfit => 'Koppla en outfit';

  @override
  String get calendarRemoveOutfit => 'Ta bort outfit';

  @override
  String get calendarNewEvent => 'Ny händelse';

  @override
  String get calendarEditEvent => 'Redigera händelse';

  @override
  String get calendarTitleLabel => 'Titel';

  @override
  String get calendarTitleRequired => 'Lägg till en titel';

  @override
  String get calendarEndBeforeStart => 'Slut efter starttid';

  @override
  String get calendarStarts => 'Startar';

  @override
  String get calendarEnds => 'Slutar';

  @override
  String get calendarPlaceOptional => 'Plats (valfritt)';

  @override
  String get calendarNotesOptional => 'Anteckningar (valfritt)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Skapa en outfit och koppla den till händelsen.';

  @override
  String get calendarBuildOutfit => 'Skapa en outfit';

  @override
  String get calendarConnectionsTitle => 'Kalendrar';

  @override
  String get calendarConnectionsBody =>
      'Händelser du lägger till här stannar i FitCheck.';

  @override
  String get calendarDisconnect => 'Koppla från';

  @override
  String get calendarNotAvailable => 'Inte tillgänglig än';

  @override
  String get profileSectionExplore => 'Utforska';

  @override
  String get profileNavTryOn => 'Prova på';

  @override
  String get profileNavRewards => 'Belöningar';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Hjälp';

  @override
  String get profileAbout => 'Om';

  @override
  String get profileAboutBody =>
      'Din garderob, dina outfits och planer på ett ställe.';

  @override
  String get profileSignOutTitle => 'Logga ut?';

  @override
  String get profileSignOutBody => 'Du kan logga in igen när som helst.';

  @override
  String get profileEditTitle => 'Redigera profil';

  @override
  String get profileYourProfile => 'Din profil';

  @override
  String get profileBodyProfiles => 'Kroppsprofiler';

  @override
  String get profileBodyEmptyTitle => 'Inga kroppsprofiler än';

  @override
  String get profileBodyEmptyBody =>
      'Lägg till längd och kroppsbyggnad för bättre passform.';

  @override
  String get profileBodyAdd => 'Lägg till profil';

  @override
  String get profileBodyDefaultNote =>
      'Din standardprofil används för passform och provning.';

  @override
  String get profileBodyDefaultBadge => 'Standard';

  @override
  String get profileBodyMakeDefault => 'Gör till standard';

  @override
  String get profileBodyDeleteBody => 'Detta kan inte ångras.';

  @override
  String get profileBodyRequired => 'Obligatorisk';

  @override
  String get profileBodyCheckNumber => 'Kontrollera numret';

  @override
  String get profileBodyNew => 'Ny kroppsprofil';

  @override
  String get profileBodyNameHint => 'Till exempel Jag';

  @override
  String get profileBodyHeight => 'Längd';

  @override
  String get profileBodyWeight => 'Vikt';

  @override
  String get profileBodyBuild => 'Kroppsbyggnad';

  @override
  String get profileBodySkinTone => 'Hudton';

  @override
  String get profileBirthDateNeededBody =>
      'Lägg till ett födelsedatum för födelsetiden.';

  @override
  String get profileBirthDateNeededTitle => 'Födelsedatum krävs';

  @override
  String get profilePartlySavedBody =>
      'Namn och foto sparades. Födelseuppgifter sparades inte, försök igen senare.';

  @override
  String get profilePartlySavedTitle => 'Delvis sparad';

  @override
  String get profileSavedBody => 'Din profil är sparad.';

  @override
  String get profileChangePhoto => 'Ändra profilbild';

  @override
  String get profilePhotoLabel => 'Profilbild';

  @override
  String get profilePhotoHint => 'Tryck för att välja en ny';

  @override
  String get profileBirthDateLabel => 'Födelsedatum (valfritt)';

  @override
  String get profileBirthTimeLabel => 'Födelsedstid (valfritt)';

  @override
  String get profileBirthTimeHelper => 'Gör vediska förslag mer exakta';

  @override
  String get profileBirthPlaceLabel => 'Födelseort (valfritt)';

  @override
  String get profileBirthPlaceHint => 'Till exempel Stockholm, Sverige';

  @override
  String get profileHelpContactTitle => 'Fråga oss om vad som helst';

  @override
  String get profileHelpContactBody =>
      'Skicka ett meddelande så svarar vi per e-post, oftast inom en dag.';

  @override
  String get profileHelpContactAction => 'Kontakta support';

  @override
  String get profileHelpFaqTitle => 'Vanliga frågor';

  @override
  String get profileFaqAddPiecesTitle =>
      'Hur lägger jag till plagg i min garderob?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tryck på Lägg till plagg på fliken Garderob. Ta ett foto eller välj ett från ditt galleri; vi hittar varje plagg och taggar det åt dig.';

  @override
  String get profileFaqMatchingTitle => 'Hur fungerar outfitmatchning?';

  @override
  String get profileFaqMatchingBody =>
      'Öppna För dig och välj plagg du äger. Vi föreslår vad som passar till och bygger hela outfits från din garderob.';

  @override
  String get profileFaqTryOnTitle => 'Kan egna foton användas för provning?';

  @override
  String get profileFaqTryOnBody =>
      'Ja. Lägg till ett helkroppsfoto på dig själv och välj sedan plagg för att se dem på dig.';

  @override
  String get profileFaqRewardsTitle => 'Hur tjänar jag belöningar?';

  @override
  String get profileFaqRewardsBody =>
      'Planera och logga outfits regelbundet. Sviter och prestationer byggs upp allt eftersom.';

  @override
  String get profileFaqPrivacyTitle => 'Är min garderob privat?';

  @override
  String get profileFaqPrivacyBody =>
      'Ja. Din garderob och dina outfits är privata om du inte delar en länk till en specifik outfit.';

  @override
  String get profileHelpMoreTitle => 'Mer hjälp';

  @override
  String get profileHelpGuides => 'Guider';

  @override
  String get profileHelpGuidesBody => 'Så fungerar varje funktion';

  @override
  String get feedbackCategoryBug => 'Något gick sönder';

  @override
  String get feedbackCategoryIdea => 'En idé';

  @override
  String get feedbackCategoryGeneral => 'Allmänt';

  @override
  String get feedbackCategoryHelp => 'Jag behöver hjälp';

  @override
  String get feedbackHintBug =>
      'Vad hände och vad förväntade du dig? Steg hjälper oss att lösa det.';

  @override
  String get feedbackHintIdea => 'Vad vill du ha och varför?';

  @override
  String get feedbackHintGeneral =>
      'Berätta vad du tycker eller ställ en fråga.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Du kan lägga till upp till 5 bilder.';

  @override
  String get feedbackAttachmentLimitTitle => 'Gränsen nådd';

  @override
  String get feedbackImageTooLargeBody => 'Välj en bild som är mindre än 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Bilden är för stor';

  @override
  String get feedbackTitle => 'Skicka feedback';

  @override
  String get feedbackAboutLabel => 'Vad gäller det?';

  @override
  String get feedbackSubjectLabel => 'Ämne';

  @override
  String get feedbackSubjectRequired => 'Ange ett ämne';

  @override
  String get feedbackSubjectTooShort => 'Ämnet måste innehålla minst 3 tecken';

  @override
  String get feedbackDetailsLabel => 'Detaljer';

  @override
  String get feedbackDetailsRequired => 'Lägg till några detaljer';

  @override
  String get feedbackDetailsTooShort =>
      'Beskrivningen måste innehålla minst 10 tecken';

  @override
  String get feedbackAddScreenshot => 'Lägg till skärmdump';

  @override
  String get feedbackAttachmentHint => 'Upp till 5, max 5 MB st';

  @override
  String get feedbackSend => 'Skicka';

  @override
  String get feedbackEmptyTitle => 'Inget skickat än';

  @override
  String get feedbackEmptyBody => 'Det du skickar visas här med sin status.';

  @override
  String get feedbackHistoryTitle => 'Det du skickade';

  @override
  String get feedbackStatusOpen => 'Öppen';

  @override
  String get feedbackStatusInProgress => 'Pågår';

  @override
  String get feedbackStatusResolved => 'Löst';

  @override
  String get feedbackStatusClosed => 'Stängd';

  @override
  String get legalIntro =>
      'Hur vi skyddar dina uppgifter och villkoren för att använda FitCheck AI.';

  @override
  String get legalPolicies => 'Riktlinjer';

  @override
  String get legalPrivacySubtitle => 'Vad vi samlar in och varför';

  @override
  String get legalTermsTitle => 'Användarvillkor';

  @override
  String get legalTermsSubtitle => 'Reglerna för att använda appen';

  @override
  String get legalLicences => 'Licenser för öppen källkod';

  @override
  String get legalSupportSubtitle => 'Hjälp, kontakt och integritetsbegäranden';

  @override
  String get legalReportAbuse => 'Rapportera ett problem eller missbruk';

  @override
  String get permissionCameraTitle => 'Kameratillgång';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI använder din kamera för att ta foton av dina kläder ochoutfits för AI-provning och garderobsorganisering.';

  @override
  String get permissionPhotoTitle => 'Bildåtkomst';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI behöver tillgång till dina bilder så att du kan välja kläder ochoutfitbilder för AI-funktioner och din garderob.';

  @override
  String get permissionNotNow => 'Inte nu';

  @override
  String get permissionOpenSettings => 'Öppna inställningar';

  @override
  String authSignedInAs(String name) {
    return 'Inloggad som $name';
  }

  @override
  String get authSignedIn => 'Inloggad';

  @override
  String get authWelcomeBackTitle => 'Välkommen tillbaka';

  @override
  String get authSignInFailed => 'Inloggningen misslyckades';

  @override
  String get authWelcomeTitle => 'Välkommen';

  @override
  String get authSignUpFailed => 'Registreringen misslyckades';

  @override
  String get authGoogleSignInFailed => 'Google-inloggning misslyckades';

  @override
  String get authAppleSignInFailed => 'Apple-inloggning misslyckades';

  @override
  String get authConfirmEmailTitle => 'Bekräfta din e-post';

  @override
  String get authConfirmEmailBody =>
      'Kolla din inkorg efter ett bekräftelsemejl och logga sedan in.';

  @override
  String get authClosetReady => 'Din garderob är redo.';

  @override
  String get authSignedOutTitle => 'Utloggad';

  @override
  String get authSignedOutBody => 'Du är utloggad.';

  @override
  String get authSignOutFailed => 'Utloggningen misslyckades';

  @override
  String get authEmailSentTitle => 'Mejl skickat';

  @override
  String get authResetLinkSent =>
      'Kolla din e-post efter en återställningslänk.';

  @override
  String get authPasswordUpdatedTitle => 'Lösenord uppdaterat';

  @override
  String get authPasswordUpdated => 'Ditt lösenord har uppdaterats.';

  @override
  String get authPasswordNotUpdated => 'Lösenordet uppdaterades inte';

  @override
  String get authCouldNotSendEmail => 'Kunde inte skicka mejlet';

  @override
  String get authEmailNotSent => 'Mejlet skickades inte';

  @override
  String get authResendSentBody => 'Vi har skickat ett nytt bekräftelsemejl.';

  @override
  String get outfitPreviewWithAi => 'Förhandsgranska med AI';

  @override
  String get outfitNewPreview => 'Skapa ny förhandsvisning';

  @override
  String get outfitBuilderClosetHeading => 'Din garderob';

  @override
  String get outfitBuilderSearchHint => 'Sök kläder';

  @override
  String get outfitClearSearch => 'Rensa sökning';

  @override
  String get outfitBuilderAddPiecesTitle => 'Lägg till kläder först';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits baseras på kläderna i din garderob.';

  @override
  String get outfitBuilderNoMatches => 'Inga kläder matchar.';

  @override
  String get outfitNameLabel => 'Namn på outfit';

  @override
  String get outfitNameHint => 'Till exempel Linnedag';

  @override
  String get outfitPreviewSemantic => 'AI-förhandsvisning av outfiten';

  @override
  String get outfitChoosePieces => 'Välj kläder';

  @override
  String get outfitTapPiecesHint => 'Tryck på kläder nedan för att lägga till.';

  @override
  String get outfitShareTooltip => 'Dela';

  @override
  String get outfitSaveFavourite => 'Spara som favorit';

  @override
  String get outfitPiecesHeading => 'Kläder';

  @override
  String get outfitWearHistoryEmpty => 'Bär den en gång så visas datum här.';

  @override
  String get outfitWearHistoryTitle => 'Bärandshistorik';

  @override
  String get outfitWearHistoryError => 'Kunde inte hämta datum.';

  @override
  String get outfitWornOn => 'Bärd den';

  @override
  String get outfitEditTitle => 'Redigera outfit';

  @override
  String get outfitSavedPhotosFailed => 'Detaljer sparade, bilder inte';

  @override
  String get outfitNoPhotosBody =>
      'Inga bilder ännu. Outfiten visar sina kläder i stället.';

  @override
  String get outfitOccasionLabel => 'Tillfälle';

  @override
  String get outfitOccasionNone => 'Inget';

  @override
  String get outfitTagsHint => 'Separera med komman';

  @override
  String get outfitDraftBody => 'Döljd från din huvudlista';

  @override
  String get outfitPublic => 'Publik';

  @override
  String get outfitPublicBody => 'Alla med länken kan se den';

  @override
  String get outfitDeleteFromDetail =>
      'Ta bort denna outfit från dess detaljsida.';

  @override
  String get outfitNewCollection => 'Ny samling';

  @override
  String get outfitNoCollectionsTitle => 'Inga samlingar ännu';

  @override
  String get outfitNoCollectionsBody =>
      'Gruppera outfits efter resa, säsong eller känsla.';

  @override
  String get outfitCreateCollection => 'Skapa en samling';

  @override
  String get outfitAddOutfits => 'Lägg till outfits';

  @override
  String get outfitRename => 'Byt namn';

  @override
  String get outfitCollectionDeleteBody => 'Outfits i samlingen behålls.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfits inte inlästa';

  @override
  String get outfitRenameCollection => 'Byt namn på samling';

  @override
  String get outfitDescriptionOptional => 'Beskrivning (valfritt)';

  @override
  String get outfitAllInCollection =>
      'Alla outfits finns redan i denna samling.';

  @override
  String get photoshootSubtitleUpload => 'Studioporträtt från dina egna foton';

  @override
  String get photoshootSubtitleConfigure => 'Välj stil, format och antal';

  @override
  String get photoshootSubtitleGenerating => 'Det tar ett par minuter';

  @override
  String get photoshootAddPhotosSemantic => 'Lägg till foton från din galleri';

  @override
  String get photoshootUploadTitle => 'Lägg till 1–4 foton på dig';

  @override
  String get photoshootUploadBody => 'Tryck för att välja ur din galleri';

  @override
  String get photoshootAddToContinue => 'Lägg till ett foto för att fortsätta';

  @override
  String get photoshootAddAnotherPhoto => 'Lägg till ett till foto';

  @override
  String get photoshootTipsTitle => 'För bäst resultat';

  @override
  String get photoshootTipsBody =>
      'Använd tydliga, väl belysta foton på ditt ansikte från flera vinklar. Undvik solglasögon och mössor.';

  @override
  String get photoshootStarting => 'Startar';

  @override
  String get photoshootCancelling => 'Avbryter';

  @override
  String get photoshootFailed => 'Misslyckades';

  @override
  String get recommendTabMatches => 'Matchar';

  @override
  String get recommendTabComplete => 'Komplettera';

  @override
  String get recommendTabWeather => 'Väder';

  @override
  String get recommendTabColours => 'Färger';

  @override
  String get recommendTabShop => 'Handla';

  @override
  String get recommendNoMatchesTitle => 'Inga kombinationer än';

  @override
  String get recommendNoMatchesBody =>
      'Välj ett plagg och vi hittar passande kombos.';

  @override
  String get recommendPickPiece => 'Välj ett plagg';

  @override
  String get recommendNothingMatchesTitle => 'Inget matchar dessa än';

  @override
  String get recommendNothingMatchesBody =>
      'Prova andra plagg eller lägg till fler.';

  @override
  String get recommendChangePieces => 'Byt plagg';

  @override
  String get recommendDefaultReason => 'Passar plagg du valt.';

  @override
  String get recommendCompleteTitle => 'Klara av en look';

  @override
  String get recommendCompleteBody => 'Välj ett plagg så fyller vi i resten.';

  @override
  String get recommendWorking => 'Arbetar';

  @override
  String get recommendGenerate => 'Skapa';

  @override
  String get recommendChooseStyleBody => 'Välj stil, skapa sedan.';

  @override
  String get recommendNoLooksTitle => 'Inga looks för dessa';

  @override
  String get recommendNoLooksBody => 'Prova annan stil eller andra plagg.';

  @override
  String get recommendDefaultLook => 'En look för dina plagg';

  @override
  String get recommendNoPiecesBody => 'Inga plagg hittades för denna look.';

  @override
  String get recommendCityLabel => 'Stad';

  @override
  String get recommendCheck => 'Kolla';

  @override
  String get recommendWeatherTitle => 'Väderjust nu?';

  @override
  String get recommendWeatherBody => 'Ange stad för dagens tips.';

  @override
  String get recommendWearToday => 'För idag';

  @override
  String get recommendWeatherNoPieces => 'Inga plagg för vädret än.';

  @override
  String get recommendBudgetLabel => 'Budget upp till';

  @override
  String get recommendLooking => 'Letar';

  @override
  String get recommendFindWhatToBuy => 'Hitta vad att köpa';

  @override
  String get recommendFillGapsTitle => 'Fylla ut luckor';

  @override
  String get recommendFillGapsBody => 'Sätt budget för förslag på luckor.';

  @override
  String get recommendNoGapsTitle => 'Inga luckor hittades';

  @override
  String get recommendNoGapsBody => 'Prova högre budget eller kategori.';

  @override
  String get recommendMoodEveryday => 'Dagligdags';

  @override
  String get recommendMoodBigMeeting => 'Stort möte';

  @override
  String get recommendDayLabel => 'Dag';

  @override
  String get recommendReadingStars => 'Läser stjärnorna';

  @override
  String get recommendGetMyColours => 'Hämta mina färger';

  @override
  String get recommendLuckyColoursTitle => 'Dina turfärger';

  @override
  String get recommendLuckyColoursBody =>
      'Välj en dag och vi föreslår färger och plagg till den.';

  @override
  String get recommendLuckyColoursSection => 'Turfärger';

  @override
  String get recommendAvoidColoursSection => 'Färger att undvika';

  @override
  String get recommendBirthDateTitle => 'Lägg till födelsedatum';

  @override
  String get recommendBirthDateBody =>
      'Vi behöver ditt födelsedatum för att läsa dina färger.';

  @override
  String get recommendEditProfile => 'Redigera profil';

  @override
  String get recommendNothingThisDay => 'Ingenting denna dag.';

  @override
  String get recommendUnnamedColour => 'Okänd färg';

  @override
  String get recommendFromCloset => 'Från din garderob';

  @override
  String get recommendNoPiecesInColours => 'Inga plagg i dessa färger ännu.';

  @override
  String get recommendOutfitIdeas => 'Koordinationsförslag';

  @override
  String get recommendNoOutfitsInColours =>
      'Ingen komplett koordinerad outfit i dessa färger ännu.';

  @override
  String get recommendDefaultOutfitIdea => 'Ett förslag på outfit';

  @override
  String get recommendPickUpToThree => 'Välj upp till tre plagg';

  @override
  String get recommendEmptyClosetBody =>
      'Lägg till några plagg först, sedan återkommer du för matchningar.';

  @override
  String get dashboardDressForDay => 'Dressera dig för dagen.';

  @override
  String get dashboardOutfitOfDay => 'Dagens outfit';

  @override
  String get dashboardFreshLook => 'Ett nytt look';

  @override
  String get subscriptionManageInStoreTitle => 'Hantera i butiken';

  @override
  String get subscriptionManageInStoreBody =>
      'Detta plan faktureras via butiken. Hantera det i dina butikskontinställningar.';

  @override
  String get subscriptionCancelledTitle => 'Prenumeration avbokad';

  @override
  String get subscriptionCancelledBody =>
      'Din plan förblir aktiv till slutet av denna faktureringsperiod.';

  @override
  String get subscriptionCancelFailedTitle => 'Kunde inte avbryta';

  @override
  String get subscriptionCouldNotOpenTitle => 'Kunde inte öppna';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Kunde inte öppna hantering av fakturering.';

  @override
  String get subscriptionOpenLinkFailedBody =>
      'Det gick inte att öppna länken.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Länken kunde inte laddas';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Det gick inte att ladda din rekommendationslänk. Försök igen.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopierad';

  @override
  String get subscriptionReferralCopiedBody =>
      'Rekommendationslänken kopierades.';

  @override
  String get subscriptionReferralShareSubject => 'Testa FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Gå med i FitCheck AI så får vi båda en månad Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Länk kopierad';

  @override
  String get subscriptionShareUnavailableBody =>
      'Delning är inte tillgänglig, så vi kopierade länken.';

  @override
  String get subscriptionShareFailedTitle => 'Kunde inte dela';

  @override
  String get subscriptionShareFailedBody =>
      'Kopiera länken från rekommendationssidan istället.';

  @override
  String get subscriptionStoreReadyTitle => 'Butik klar';

  @override
  String get subscriptionStoreReadyBody =>
      'Butikspriserna är tillgängliga. Du kan uppgradera nu.';

  @override
  String get purchaseFailedTitle => 'Köpet misslyckades';

  @override
  String get purchaseUnavailableTitle => 'Köp inte tillgängligt';

  @override
  String get purchaseIapUnavailableBody =>
      'In-app-köp är inte tillgängliga på denna enhet.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Denna plan är ännu inte tillgänglig för köp.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Denna plan är ännu inte tillgänglig i butiken. Kom tillbaka snart.';

  @override
  String get purchaseStartFailedBody =>
      'Köpet kunde inte startas. Försök igen.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Kassan returnerade ingen betalningslänk.';

  @override
  String get purchasePendingTitle => 'Köp inväntar';

  @override
  String get purchasePendingBody =>
      'Ditt köp inväntar godkännande. Du får åtkomst så snart det har godkänts.';

  @override
  String get purchaseFailedBody => 'Köpet misslyckades. Försök igen.';

  @override
  String get purchaseRestoredTitle => 'Återställt';

  @override
  String get purchaseRestoredBody => 'Dina köp är återställda.';

  @override
  String get purchaseActiveTitle => 'Prenumeration aktiv';

  @override
  String get purchaseActiveBody => 'Din prenumeration är aktiv. Välkommen.';

  @override
  String get purchaseSignInRequiredTitle => 'Inloggning krävs';

  @override
  String get purchaseSignInRequiredBody => 'Logga in för att slutföra köpet.';

  @override
  String get purchaseErrorTitle => 'Köperror';

  @override
  String get purchaseInvalidTransactionBody =>
      'Köpet innehöll ingen verifierbar transaktions-ID.';

  @override
  String get purchaseVerificationPendingTitle => 'Verifiering pågår';

  @override
  String get purchaseVerificationPendingBody =>
      'Vi kunde just nu inte verifiera ditt köp mot butiken. Den kommer att slutföras automatiskt, och du dras inte för dubbelt.';

  @override
  String get purchaseNotAppliedTitle => 'Köpt inte tillämpat';

  @override
  String get purchaseNotAppliedBody =>
      'Ditt köp kunde inte tillämpas på ditt konto. Kontakta support och köp inte igen.';

  @override
  String get purchaseRestoreFailedTitle => 'Återställning misslyckades';

  @override
  String get purchaseRestoreFailedBody =>
      'Kunde inte återställa köp. Försök igen.';

  @override
  String get purchaseRecoveredActiveBody => 'Din prenumeration är aktiv.';

  @override
  String get purchaseCompleteTitle => 'Köpet slutfört';

  @override
  String get giftCreateFailedTitle => 'Gåvan kunde inte skapas';

  @override
  String get giftClaimFailedTitle => 'Gåven kunde inte hämtas';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gåvor till dig',
      one: 'En gåva till dig',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 månad',
      '12': '1 år',
      'other': '$months månader',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining kvar',
      one: '1 kvar',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration av FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender skickade dig $duration av FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'En FitCheck Pro-gåva till $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Från $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Till $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Från $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'din mottagare';

  @override
  String get giftPreviewPlaceholderSender => 'du';

  @override
  String get settingsSavedTitle => 'Sparat';

  @override
  String get settingsNotSavedTitle => 'Inte sparat';

  @override
  String get settingsAiChooseProviderBody => 'Välj en leverantör.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'En anpassad leverantör kräver en API-URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Ange en API-nyckel.';

  @override
  String get settingsAiSavedBody => 'Dina AI-inställningar är sparade.';

  @override
  String get settingsAiMissingDetailsTitle => 'Detaljer saknas';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Ange en API-URL och ett chattmodell att testa.';

  @override
  String get settingsAiKeyNeededTitle => 'API-nyckel krävs';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Ange din API-nyckel för att testa. Din sparade nyckel förblir privat.';

  @override
  String get settingsAiKeyToTestBody => 'Ange din API-nyckel för att testa.';

  @override
  String get settingsAiConnectedTitle => 'Ansluten';

  @override
  String get settingsAiConnectedBody => 'Anslutningen fungerar.';

  @override
  String get settingsAiTestFailedTitle => 'Testet misslyckades';

  @override
  String get settingsPreferencesSavedBody => 'Dina inställningar är sparade.';

  @override
  String get settingsPasswordNotChangedTitle => 'Lösenordet ändrades inte';

  @override
  String get settingsOAuthPasswordBody =>
      'Detta konto loggar in med Google eller Apple. Använd \"Glömt lösenord\" för att sätta ett lösenord först.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Nuvarande lösenord är felaktigt.';

  @override
  String get settingsExportReadyTitle => 'Export klar';

  @override
  String get settingsExportReadyBody => 'Din dataexport är klar att ladda ner.';

  @override
  String get settingsLinkCopiedTitle => 'Länk kopierad';

  @override
  String get settingsExportClipboardBody =>
      'Vi kunde inte öppna webbläsaren, så vi kopierade nerjlänken. Klistra in den i en webbläsare snart: den löper ut.';

  @override
  String get settingsExportFailedTitle => 'Export misslyckades';

  @override
  String get settingsAccountNotDeletedTitle => 'Kontot raderas inte';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Du kan lägga till upp till $max foton.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Fotogräns';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Lägg till minst ett foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Inga foton';

  @override
  String get photoshootDescribeLookBody => 'Beskriv looken du vill ha.';

  @override
  String get photoshootPromptNeededTitle => 'Fråga krävs';

  @override
  String get photoshootConsentFeatureLabel => 'AI-fotoshoot';

  @override
  String get photoshootStatusPreparing => 'Förbereder dina foton';

  @override
  String get photoshootStatusGenerating => 'Skapar';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current av $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done av $total klar';
  }

  @override
  String get photoshootGenerationFailedBody => 'Skapningen misslyckades.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready klart, $failed misslyckades.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Delvis klar';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bilder är klara.',
      one: '1 bild är klar.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Anslutningen förlorades. Försök igen.';

  @override
  String get photoshootCouldNotCancelTitle => 'Kunde inte avbryta';

  @override
  String get photoshootRetryFailedTitle => 'Återförsöket misslyckades';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Bild $number är klar.';
  }

  @override
  String get photoshootReplacedTitle => 'Bytt ut';

  @override
  String get photoshootSavedToGalleryBody => 'Sparad i din bildsamling.';

  @override
  String get photoshootSavedTitle => 'Sparad';

  @override
  String get photoshootNotSavedTitle => 'Inte sparad';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alla $count bilder är i din bildsamling.',
      one: '1 bild är i din bildsamling.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved av $total sparade.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Vissa bilder inte sparade';

  @override
  String get tryonConsentFeatureLabel => 'Virtuellt provbärning';

  @override
  String get tryonAvatarUpdatedBody => 'Din bild har uppdaterats.';

  @override
  String get tryonSavedTitle => 'Sparad';

  @override
  String get tryonUploadFailedTitle => 'Uppladdningen misslyckades';

  @override
  String get tryonChooseGarmentFirstBody => 'Välj en klädesbild först.';

  @override
  String get tryonNoGarmentTitle => 'Inget klädesplagg';

  @override
  String get tryonWaitForUploadBody => 'Vänta tills din bild är uppladdad.';

  @override
  String get tryonStillUploadingTitle => 'Upploader fortfarande';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Lägg till en bild på dig själv först.';

  @override
  String get tryonReadyBody => 'Din provbärning är klar.';

  @override
  String get tryonFailedTitle => 'Provbärningen misslyckades';

  @override
  String get tryonSavedToGalleryBody => 'Sparad i din bildsamling.';

  @override
  String get tryonNotSavedTitle => 'Inte sparad';

  @override
  String get calendarEventAddedBody => 'Händelse tillagd';

  @override
  String get calendarEventPlannedTitle => 'Planerad';

  @override
  String get calendarEventSavedBody => 'Händelse sparad';

  @override
  String get calendarSavedTitle => 'Sparad';

  @override
  String get calendarEventNotSavedTitle => 'Händelsen inte sparad';

  @override
  String get calendarEventRemovedBody => 'Händelsen borttagen';

  @override
  String get calendarEventDeletedTitle => 'Raderad';

  @override
  String get calendarEventNotDeletedTitle => 'Händelsen kunde inte raderas';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfiten kopplades inte';

  @override
  String get calendarLinkedTitle => 'Kopplad';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfiten togs inte bort';

  @override
  String get calendarOutfitRemovedBody => 'Outfiten borttagen';

  @override
  String get calendarDisconnectedBody => 'Kalendern kopplad bort';

  @override
  String get calendarDisconnectedTitle => 'Kopplad bort';

  @override
  String get calendarNotDisconnectedTitle => 'Kalendern kopplades inte bort';

  @override
  String get calendarTodayLabel => 'i dag';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count händelser',
      one: '1 händelse',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start till $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit kopplad';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" tas bort.';
  }

  @override
  String get calendarThisAppLabel => 'Denna app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synkronisering med $provider är inte tillgänglig ännu. Du kan fortfarande lägga till händelser här.';
  }

  @override
  String get calendarWeekdaySunShort => 'sön';

  @override
  String get calendarWeekdayMonShort => 'mån';

  @override
  String get calendarWeekdayTueShort => 'tis';

  @override
  String get calendarWeekdayWedShort => 'ons';

  @override
  String get calendarWeekdayThuShort => 'tors';

  @override
  String get calendarWeekdayFriShort => 'fre';

  @override
  String get calendarWeekdaySatShort => 'lör';

  @override
  String get calendarWeekdayMonday => 'måndag';

  @override
  String get calendarWeekdayTuesday => 'tisdag';

  @override
  String get calendarWeekdayWednesday => 'onsdag';

  @override
  String get calendarWeekdayThursday => 'torsdag';

  @override
  String get calendarWeekdayFriday => 'fredag';

  @override
  String get calendarWeekdaySaturday => 'Lördag';

  @override
  String get calendarWeekdaySunday => 'Söndag';

  @override
  String get outfitSavedToFavouritesBody => 'Sparad till favoriter';

  @override
  String get outfitRemovedFromFavouritesBody => 'Tog bort från favoriter';

  @override
  String get outfitNotSavedTitle => 'Inte sparat';

  @override
  String get outfitLoggedAsWornBody => 'Registrerad som ägad idag.';

  @override
  String get outfitNicePickTitle => 'Bra val';

  @override
  String get outfitRemovedBody => 'Utseendet togs bort.';

  @override
  String get outfitDeletedTitle => 'Raderad';

  @override
  String get outfitNotDeletedTitle => 'Inte raderad';

  @override
  String get outfitDuplicatedBody => 'En kopia finns i dina outfits.';

  @override
  String get outfitDuplicatedTitle => 'Dubbletterad';

  @override
  String get outfitNotDuplicatedTitle => 'Inte dubbelterad';

  @override
  String get outfitNotSharedTitle => 'Inte delad';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" är redo.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Samlingen skapades inte';

  @override
  String get outfitCollectionUpdatedBody => 'Samlingen uppdaterad.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Samlingen uppdaterades inte';

  @override
  String get outfitCollectionDeletedBody => 'Samlingen raderad.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Samlingen raderades inte';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits tillagda.',
      one: '1 outfit tillagd.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits lades inte till';

  @override
  String get outfitPreviewNotCreatedTitle => 'Förhandsvisning skapades inte';

  @override
  String get outfitGiveNameBody => 'Ge outfiten ett namn.';

  @override
  String get outfitNameMissingTitle => 'Namn';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Välj minst en del.';

  @override
  String outfitCreatedBody(String name) {
    return '$name ligger i dina outfits.';
  }

  @override
  String get outfitSavedTitle => 'Sparat';

  @override
  String get wardrobeAddedToFavouritesBody => 'Tillagd till favoriter';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Tog bort från favoriter';

  @override
  String get wardrobeNotSavedTitle => 'Ej sparad';

  @override
  String get wardrobeLoggedAsWornBody => 'Markerad som bärd idag.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Raderad ur ditt klädeskåp.';

  @override
  String get wardrobeDeletedTitle => 'Raderad';

  @override
  String get wardrobeNotDeletedTitle => 'Inte raderad';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kläder borttagna ur ditt klädeskåp.',
      one: '1 kläder borttagna ur ditt klädeskåp.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI-klädeskåpsextraktion';

  @override
  String get itemAddScanJobLabel => 'Skanera';

  @override
  String get itemAddFoundEarlierBody => 'Hittad i ett tidigare skan';

  @override
  String get itemAddLookingAtPhoto => 'Kollar ditt foto';

  @override
  String get itemAddExtractionFailedBody => 'Extraktion misslyckades';

  @override
  String get itemAddJobFailedBody => 'Uppdraget misslyckades';

  @override
  String get itemAddConnectionLostBody =>
      'Anslutningen förlorades. Försök igen.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Förlorade anslutningen under bearbetning.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Artikel $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Artikel';

  @override
  String get itemAddNotCancelledTitle => 'Inte avbrutet';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artiklar ligger i ditt klädeskåp.',
      one: '1 artikel ligger i ditt klädeskåp.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved av $total artiklar sparade. Tryck på Spara för att försöka igen på de kvarvarande.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Några artiklar sparades inte';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Välj minst ett foto.';

  @override
  String get batchPhotoUnreadableBody => 'Detta foto kunde inte läsas.';

  @override
  String get batchNoPhotosReadableBody =>
      'Inget av dessa foton kunde läsas. Prova andra foton.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foton',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Vi förlorade anslutningen under arbete. Försök igen.';

  @override
  String get batchNotCancelledTitle => 'Inte avbrutet';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Länkar till inlägg stöds inte. Använd en profil-länk.';

  @override
  String get batchLinkSpacesBody => 'Länkar får inte innehålla mellanslag.';

  @override
  String get batchEnterProfileLinkBody =>
      'Ange en profil-länk till Instagram eller Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Ange en profil-länk.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Inloggnings Sidan öppnades inte. Försök igen.';

  @override
  String get batchSignInBrowserBody =>
      'Logga in i webbläsaren och återgå sedan till FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Koppla ditt konto';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Ange koden från autentiseringsappen.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram vill ha en säkerhetskontroll. Logga in i webbläsaren först.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Ange användarnamn och lösenord igen.';

  @override
  String get batchSignInFailedBody =>
      'Inloggningen misslyckades. Kontrollera användarnamn och lösenord.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Logga in för att fortsätta importen.';

  @override
  String get batchAccountNotConnectedBody => 'Ditt konto kopplades inte.';

  @override
  String get batchAccountConnectedTitle => 'Kontot är kopplat';

  @override
  String get batchNotConnectedTitle => 'Inte kopplat';

  @override
  String get batchImportConnectionLostBody =>
      'Förlorade anslutningen till importen. Uppdatera för att kontrollera.';

  @override
  String batchPickUpToBody(int max) {
    return 'Välj upp till $max foton. Vi hittar plaggen.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count av $total foton';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Förbereder foto $done av $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hitta plagg på $count foton',
      one: 'Hitta plagg på 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Ditt $platform konto använder tvåstegsinloggning. Ange den 6-siffriga koden från autentiseringsappen.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Detta $platform profilen är privat eller kräver inloggning för att visa foton.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Koppla med $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foton hittade hittills',
      one: '1 foto hittat hittills',
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
    return '$processed av $total behandlade · $added tillagda · $waiting väntar · $skipped hoppade över';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Skannar foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number kommer som nästa';
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
      other: '$count plagg hittade',
      one: '1 plagg hittat',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foton lades till i din garderob.',
      one: '1 foto lades till i din garderob.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count studiofoton mer på ingång. Spara det som är klart eller lämnar — vi meddelar dig.',
      one:
          '1 studiofoto mer på ingång. Spara det som är klart eller lämnar — vi meddelar dig.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Inte sparat än: $names.';
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
      other: '$photos foton',
      one: '1 foto',
    );
    return '$_temp0 från $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen valda. Tryck på ett plagg för att hoppa över.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sparar $count delar',
      one: 'Sparar 1 del',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spara $count delar',
      one: 'Spara 1 del',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Din kroppsprofil är sparad.';

  @override
  String get bodyProfileSavedTitle => 'Sparad';

  @override
  String get bodyProfileNotSavedTitle => 'Inte sparad';

  @override
  String get bodyProfileSetDefaultBody => 'Ange som din standardprofil.';

  @override
  String get bodyProfileDeletedBody => 'Kroppsprofilen raderades.';

  @override
  String get bodyProfileDeletedTitle => 'Raderad';

  @override
  String get bodyProfileNotDeletedTitle => 'Inte raderad';

  @override
  String get feedbackNotSentTitle => 'Inte skickad';

  @override
  String get feedbackSentBody =>
      'Tack. Vi läser alla meddelanden och svarar om vi behöver mer info.';

  @override
  String get feedbackSentTitle => 'Feedback skickad';

  @override
  String get recommendUnnamedPiece => 'Okänd del';

  @override
  String get recommendEnterCityBody =>
      'Ange din stad för att få tips baserat på vädret.';

  @override
  String get recommendWhichCityTitle => 'Vilken stad?';

  @override
  String get aiConsentSheetTitle => 'Delning av foton med en AI-tjänst';

  @override
  String get aiConsentSheetBody =>
      'För att skapa dina prov- och bild-foton skickar FitCheck AI de foton du tillhandahåller (inklusive bilder av ditt ansikte och din kropp) till en betrodd tredje parts AI-leverantör (som t.ex. OpenAI eller Google Gemini) för bearbetning. De genererar dina bilder och använder dem inte för att träna sina modeller enligt våra villkor. Foton överförs säkert och delas aldrig för reklam.';

  @override
  String get aiConsentSheetPermission =>
      'Genom att fortsätta ger du uttryckligt tillstånd att dela dina foton med dessa AI-leverantörer för bildgenerering.';

  @override
  String get skeletonsLoadMoreFailed => 'Kunde inte ladda fler.';

  @override
  String get jobsPiecesReadyTitle => 'Dina delar är klara';

  @override
  String get jobsScanStoppedTitle => 'Skanneringen stoppades';

  @override
  String get jobsNothingSavedBody => 'Inget sparades. Försök igen.';

  @override
  String get jobsPhotoUploadFailedBody => 'Fotouppdateringen misslyckades.';

  @override
  String get authGoogleSignInStartFailed =>
      'Kunde inte starta Google-inloggning. Försök igen.';

  @override
  String get referralAppliedTitle => 'Vistelse kod tillagd!';

  @override
  String get billingStoreUnavailableBody =>
      'Köp i butik är inte tillgängligt på den här enheten.';

  @override
  String get billingPurchaseProcessingBody =>
      'Köpet bearbetas fortfarande. Öppna om appen om en minut för att se din plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Uppladdning av avatar returnerade ingen bild-URL.';

  @override
  String get rewardsDayStreakLabel => 'dagars sträck';

  @override
  String rewardsBestStreak(int days) {
    return 'Bästa $days dagar';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Åtkomst till $permission krävs';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Åtkomst till $permission är just nu nekad. Öppna Inställningar för att tillåta det, sedan gå tillbaka och försök igen.';
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
    return 'Ta bort bild $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Ta bort bild $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points p';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'E-post $email. Vi granskar rapporter inom 24 timmar.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Ta bort $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Ta bort \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Lägg till i \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" är borttagen. Desse delarna finns kvar i din garderob.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Visa alla $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count kvar idag';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Bild $index misslyckades';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected av $max bilder';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape byggyta · $tone hy';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Ta bort $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Alternativ för $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Mest burit: $name, $count gånger';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: ej angiven';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked av $max valda';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Ta bort $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency prioritet';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Den här planen faktureras via $store. Ändra eller avbryt den i dina kontoinställningar för $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Hantera i $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current av $max använt';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Cirka ${seconds}s kvar';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done av $total studiofoton klara';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready av $total studiorbilder är klara. Tryck på en del för att hoppa över den.';
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
  String get profileFieldNotSet => 'Nej';
}
