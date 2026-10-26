// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPhotoshoot => 'Fotoshooting';

  @override
  String get tabCloset => 'Kleiderschrank';

  @override
  String get tabOutfits => 'Outfits';

  @override
  String get tabMore => 'Mehr';

  @override
  String get actionAddItem => 'Teil hinzufügen';

  @override
  String get actionCreateOutfit => 'Outfit erstellen';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionRetry => 'Wiederholen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionSearch => 'Suchen';

  @override
  String get actionContinue => 'Fortfahren';

  @override
  String get stateLoading => 'Wird geladen';

  @override
  String get stateErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get stateErrorBody =>
      'Versuche es erneut. Wenn der Fehler bleibt, kontaktiere den Support.';

  @override
  String get stateOfflineTitle => 'Du bist offline';

  @override
  String get stateOfflineBody =>
      'Verbinde dich erneut, um deinen Kleiderschrank zu synchronisieren und Outfits zu generieren.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsPreferencesSection => 'Präferenzen';

  @override
  String get settingsPlanBilling => 'Plan und Abrechnung';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsUnits => 'Maßeinheiten';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsPrivacySection => 'Datenschutz';

  @override
  String get settingsAboutSection => 'Über uns';

  @override
  String get settingsSignOut => 'Abmelden';

  @override
  String get settingsDeleteAccount => 'Konto löschen';

  @override
  String get settingsDeleteAccountTitle => 'Konto wirklich löschen?';

  @override
  String get settingsDeleteAccountBody =>
      'Dies entfernt deinen Kleiderschrank, Outfits, Fotos und dein Profil. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrisch (cm, kg)';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Gerätesprache verwenden';

  @override
  String get languageSystemBody =>
      'FitCheck AI folgt der Sprache deines Handys.';

  @override
  String get languageSearchHint => 'Sprachen suchen';

  @override
  String get languageCurrent => 'Aktuell';

  @override
  String get languageReviewNote =>
      'Diese Übersetzung ist neu. Sag uns, falls etwas nicht stimmt.';

  @override
  String get languageChanged => 'Sprache aktualisiert';

  @override
  String get paywallTitle => 'Wähle deinen Plan';

  @override
  String get paywallTrialBadge => '1 Monat kostenlos';

  @override
  String get paywallTrialTitle => 'Dein erster Monat Pro ist kostenlos';

  @override
  String get paywallTrialBody =>
      'Lade deinen gesamten Kleiderschrank auf einmal hoch. Füge danach jederzeit neue Teile hinzu.';

  @override
  String get paywallFreeForeverTitle => 'Für immer kostenlos';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Keine Karte nötig. Jeden Monat erhältst du $uploads KI-Uploads, $outfits Outfits und $images Fotoshoot-Bilder pro Tag.';
  }

  @override
  String get paywallCtaTrial => 'Gratismonat starten';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Upgrade auf $plan';
  }

  @override
  String get paywallRestore => 'Käufe wiederherstellen';

  @override
  String get paywallManage => 'Abo verwalten';

  @override
  String get paywallTerms => 'Nutzungsbedingungen';

  @override
  String get paywallPrivacy => 'Datenschutzrichtlinie';

  @override
  String get paywallPerMonth => 'pro Monat';

  @override
  String get paywallPerYear => 'pro Jahr';

  @override
  String get paywallBestValue => 'Bestes Angebot';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Kostenlose Testphase nur für neue Abonnenten. Nach der Testphase verlängert sich Pro automatisch zum Preis von $price, sofern nicht mindestens 24 Stunden vor Ablauf gekündigt wird.';
  }

  @override
  String get introTitle => 'Dein Kleiderschrank, endlich organisiert';

  @override
  String get introBody =>
      'Fotografiere deine Kleidung einmal. Erhalte Outfit-Ideen, Anprobe-Vorschauen und Studiofotos von dem, was du bereits besitzt.';

  @override
  String get introStart => 'Loslegen';

  @override
  String get introHaveAccount => 'Ich habe bereits ein Konto';

  @override
  String get introSkip => 'Überspringen';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authSignUp => 'Konto erstellen';

  @override
  String get authEmail => 'E-Mail';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authContinueApple => 'Mit Apple fortfahren';

  @override
  String get authContinueGoogle => 'Mit Google fortfahren';

  @override
  String get authOrDivider => 'oder';

  @override
  String get wardrobeTitle => 'Kleiderschrank';

  @override
  String get wardrobeEmptyTitle => 'Dein Kleiderschrank ist leer';

  @override
  String get wardrobeEmptyBody =>
      'Füge dein erstes Kleidungsstück hinzu oder lade ein Foto deiner gesamten Garderobe auf einmal hoch.';

  @override
  String get wardrobeAddFirst => 'Erstes Teil hinzufügen';

  @override
  String get wardrobeSearchHint => 'Kleiderschrank durchsuchen';

  @override
  String get categoryTops => 'Oberteile';

  @override
  String get categoryBottoms => 'Unterteile';

  @override
  String get categoryShoes => 'Schuhe';

  @override
  String get categoryAccessories => 'Accessoires';

  @override
  String get categoryOuterwear => 'Jacken & Mäntel';

  @override
  String get categorySwimwear => 'Bademode';

  @override
  String get categoryActivewear => 'Sportbekleidung';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get conditionClean => 'Sauber';

  @override
  String get conditionDirty => 'Schmutzig';

  @override
  String get conditionLaundry => 'In der Wäsche';

  @override
  String get conditionRepair => 'Reparaturbedürftig';

  @override
  String get conditionDonate => 'Zum Spenden';

  @override
  String get seasonSpring => 'Frühling';

  @override
  String get seasonSummer => 'Sommer';

  @override
  String get seasonFall => 'Herbst';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonAll => 'Ganzjährig';

  @override
  String get styleCasual => 'Lässig';

  @override
  String get styleFormal => 'Formell';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sportlich';

  @override
  String get styleBohemian => 'Boho';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistisch';

  @override
  String get styleRomantic => 'Romantisch';

  @override
  String get styleEdgy => 'Ausgefallen';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Künstlerisch';

  @override
  String get styleClassic => 'Klassisch';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Sonstiges';

  @override
  String get occasionWork => 'Arbeit';

  @override
  String get occasionDateNight => 'Date';

  @override
  String get occasionTravel => 'Reisen';

  @override
  String get occasionWedding => 'Hochzeit';

  @override
  String get occasionGym => 'Sport';

  @override
  String get occasionWeekend => 'Wochenende';

  @override
  String get occasionParty => 'Party';

  @override
  String get occasionInterview => 'Vorstellungsgespräch';

  @override
  String get colorBlack => 'Schwarz';

  @override
  String get colorWhite => 'Weiß';

  @override
  String get colorGrey => 'Grau';

  @override
  String get colorNavy => 'Marineblau';

  @override
  String get colorBrown => 'Braun';

  @override
  String get colorRed => 'Rot';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorYellow => 'Gelb';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Heute';

  @override
  String get dateYesterday => 'Gestern';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Wochen',
      one: 'vor 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Monaten',
      one: 'vor 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Jahren',
      one: 'vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Gefällt dir FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Eine kurze Bewertung hilft anderen, ihren Stil zu finden.';

  @override
  String get ratingPromptYes => 'App bewerten';

  @override
  String get ratingPromptNo => 'Später';

  @override
  String get closetNoMatchesTitle => 'Keine Treffer';

  @override
  String get closetNoMatchesBody => 'Filter anpassen oder Suche ändern.';

  @override
  String get closetClearFilters => 'Filter löschen';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile',
      one: '1 Teil',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Teile werden geladen';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Auswahl löschen';

  @override
  String get closetCancelSelection => 'Auswahl abbrechen';

  @override
  String get closetCloseSearch => 'Suche schließen';

  @override
  String get closetShowGrid => 'Als Raster anzeigen';

  @override
  String get closetShowList => 'Als Liste anzeigen';

  @override
  String get closetShowRows => 'Als Zeilen anzeigen';

  @override
  String get closetStatsTitle => 'Kleiderschrank-Statistik';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile löschen?',
      one: '1 Teil löschen?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Outfits, die diese Teile enthalten, verlieren sie.';

  @override
  String get closetSortBy => 'Sortieren nach';

  @override
  String get closetFavourites => 'Favoriten';

  @override
  String get closetFavourite => 'Favorisieren';

  @override
  String get closetUnfavourite => 'Favorit entfernen';

  @override
  String get closetWoreToday => 'Heute getragen';

  @override
  String closetWornTimes(int count) {
    return '$count× getragen';
  }

  @override
  String get closetCategoryLabel => 'Kategorie';

  @override
  String get closetUseCaseLabel => 'Anlass';

  @override
  String get closetAnyUseCase => 'Alle';

  @override
  String get closetOtherUseCase => 'Anderer Anlass';

  @override
  String get closetOtherUseCaseHint => 'Zum Beispiel Brunch';

  @override
  String get closetUseUseCase => 'Diesen Anlass nutzen';

  @override
  String get closetClearAll => 'Alles löschen';

  @override
  String get sortNewest => 'Neueste zuerst';

  @override
  String get sortOldest => 'Älteste zuerst';

  @override
  String get sortName => 'Name (A–Z)';

  @override
  String get sortMostWorn => 'Am häufigsten getragen';

  @override
  String get useCaseInformal => 'Freizeit';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Abendessen';

  @override
  String get useCaseLunch => 'Mittagessen';

  @override
  String get actionSelect => 'Auswählen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionFilter => 'Filtern';

  @override
  String get actionSort => 'Sortieren';

  @override
  String get actionAll => 'Alle';

  @override
  String get dashboardStartClosetTitle => 'Kleiderschrank starten';

  @override
  String get dashboardStartClosetBody =>
      'Fotografiere ein paar Teile. Wir taggen sie für dich.';

  @override
  String get dashboardPieces => 'Teile';

  @override
  String get dashboardOutfits => 'Outfits';

  @override
  String get dashboardDayStreak => 'Tage in Folge';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count diesen Monat';
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
      other: '$count Favoriten',
      one: '1 Favorit',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gespeicherte Outfits',
      one: '1 gespeichertes Outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Meist getragen: $name, $count Mal';
  }

  @override
  String get setupSkip => 'Einrichtung überspringen';

  @override
  String get setupWhoTitle => 'Wen stylen wir?';

  @override
  String get setupWhoBody =>
      'Legt das Modell für Anproben fest. Kann im Profil geändert werden.';

  @override
  String get setupStyleTitle => 'Was trägst du am liebsten?';

  @override
  String get setupStyleBody => 'Wähle aus. Outfit-Ideen basieren darauf.';

  @override
  String get setupClosetTitle => 'Erste Teile hinzufügen.';

  @override
  String get setupClosetBody =>
      'Fotografiere Kleidung. Jedes Teil wird automatisch freigestellt und sortiert.';

  @override
  String get setupAddClothes => 'Kleidung hinzufügen';

  @override
  String get setupStylesLabel => 'Stile';

  @override
  String get setupOccasionsLabel => 'Anlässe';

  @override
  String get setupSkipStep => 'Überspringen';

  @override
  String get setupLater => 'Später';

  @override
  String get setupSaveError => 'Speichern fehlgeschlagen';

  @override
  String get genderWomen => 'Damen';

  @override
  String get genderMen => 'Herren';

  @override
  String get genderNonBinary => 'Nicht-binär';

  @override
  String get genderPreferNotToSay => 'Keine Angabe';

  @override
  String get outfitEmptyTitle => 'Noch keine Outfits';

  @override
  String get outfitEmptyBody =>
      'Kombiniere Teile aus deinem Kleiderschrank und speichere den Look.';

  @override
  String get outfitNoMatchesTitle => 'Keine passenden Outfits';

  @override
  String get outfitSearchHint => 'Outfits durchsuchen';

  @override
  String get outfitLoading => 'Outfits werden geladen';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Outfits',
      one: '1 Outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Stil und Saison';

  @override
  String get outfitCollections => 'Kollektionen';

  @override
  String get outfitDuplicate => 'Duplizieren';

  @override
  String get outfitDeleteTitle => 'Outfit löschen?';

  @override
  String get outfitDeleteBody =>
      'Die Kleidungsstücke bleiben in deinem Schrank.';

  @override
  String get outfitDrafts => 'Entwürfe';

  @override
  String get outfitDraft => 'Entwurf';

  @override
  String get filterStyle => 'Stil';

  @override
  String get filterSeason => 'Saison';

  @override
  String get itemDetailDeleteTitle => 'Teil löschen?';

  @override
  String get itemDetailDeleteBody =>
      'Outfits, die dieses Teil enthalten, verlieren es.';

  @override
  String get itemAddFavourite => 'Zu Favoriten hinzufügen';

  @override
  String itemSize(String size) {
    return 'Größe $size';
  }

  @override
  String get itemColours => 'Farben';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Muster';

  @override
  String get itemUseCases => 'Anlässe';

  @override
  String get itemKeptIn => 'Aufbewahrungsort';

  @override
  String get itemPrice => 'Preis';

  @override
  String get itemBought => 'Gekauft';

  @override
  String get itemTags => 'Tags';

  @override
  String get itemAdded => 'Hinzugefügt';

  @override
  String get itemTimesWornLabel => 'mal getragen';

  @override
  String get itemLastWornLabel => 'zuletzt getragen';

  @override
  String get itemNeverWorn => 'Nie';

  @override
  String get authEntryBody =>
      'Jedes Teil in deinem Schrank, gestylt von KI. Outfits planen, anprobieren, fotografieren.';

  @override
  String get authCreateCloset => 'Kleiderschrank erstellen';

  @override
  String get authWelcomeBack => 'Willkommen zurück';

  @override
  String get authSignInBody =>
      'Melde dich an, um deinen Kleiderschrank zu öffnen.';

  @override
  String get authCreateAccount => 'Konto erstellen';

  @override
  String get authCreateClosetBody =>
      'Dauert nur eine Minute. Deine ersten Teile sind kostenlos.';

  @override
  String get authName => 'Name';

  @override
  String get authConfirmPassword => 'Passwort bestätigen';

  @override
  String get authReferralCode => 'Empfehlungscode (optional)';

  @override
  String get authResetTitle => 'Passwort zurücksetzen';

  @override
  String get authResetBody =>
      'Wir senden dir einen Link, um ein neues Passwort zu wählen.';

  @override
  String get authSendResetLink => 'Link senden';

  @override
  String get authBackToSignIn => 'Zurück zur Anmeldung';

  @override
  String get authEnterEmail => 'E-Mail eingeben';

  @override
  String get authEnterValidEmail => 'Gültige E-Mail eingeben';

  @override
  String get authEnterPassword => 'Passwort eingeben';

  @override
  String get authPasswordTooShort => 'Mindestens 6 Zeichen';

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authHidePassword => 'Passwort verbergen';

  @override
  String get authNewHere => 'Neu hier?';

  @override
  String authConfirmEmail(String email) {
    return 'Bestätige $email vor der Anmeldung. Prüfe deinen Posteingang.';
  }

  @override
  String get authResendEmail => 'Erneut senden';

  @override
  String get authResendingEmail => 'Wird gesendet…';

  @override
  String get authPasswordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get authEnterName => 'Name eingeben';

  @override
  String get authChoosePassword => 'Passwort wählen';

  @override
  String get authHaveAccount => 'Bereits ein Konto?';

  @override
  String get authCodeAccepted => 'Code akzeptiert';

  @override
  String get authCodeNotFound => 'Code nicht gefunden';

  @override
  String authReferralFrom(String name) {
    return 'Von $name. Ihr erhaltet beide einen Monat gratis.';
  }

  @override
  String get authReferralInvalid => 'Dieser Code wurde nicht gefunden.';

  @override
  String authResetSent(String email) {
    return 'An $email gesendet. Link auf diesem Gerät öffnen.';
  }

  @override
  String get introSlide1Title => 'Kleiderschrank scannen';

  @override
  String get introSlide1Body =>
      'Kleidung fotografieren. Jedes Teil wird automatisch freigestellt und sortiert.';

  @override
  String get introSlide2Title => 'Schneller anziehen';

  @override
  String get introSlide2Body =>
      'Outfits aus deinem Bestand, passend zu Anlass und Wetter.';

  @override
  String get introSlide3Title => 'Vorher sehen';

  @override
  String get introSlide3Body =>
      'Looks virtuell anprobieren oder wie ein Profi fotografieren.';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsTemperature => 'Temperatur';

  @override
  String get settingsEmailUpdates => 'E-Mail-Updates';

  @override
  String get settingsEmailUpdatesBody => 'Neuigkeiten und Tipps per E-Mail';

  @override
  String get settingsOutfitReminders => 'Outfit-Erinnerungen';

  @override
  String get settingsOutfitRemindersBody => 'Hinweis zum Loggen deiner Outfits';

  @override
  String get settingsWeeklySummary => 'Wochenrückblick';

  @override
  String get settingsWeeklySummaryBody => 'Deine Woche in Outfits';

  @override
  String get settingsStyleSection => 'Stil';

  @override
  String get settingsPreferredStyles => 'Deine bevorzugten Stile';

  @override
  String get settingsPreferredColours => 'Bevorzugte Farben';

  @override
  String get settingsNoneChosen => 'Keine ausgewählt';

  @override
  String get settingsPlanAiSection => 'Abo und KI';

  @override
  String get settingsPlanBillingBody => 'Abo, Nutzung und Upgrades';

  @override
  String get settingsPlanUsageBody => 'Abo und Nutzung';

  @override
  String get settingsInviteFriends => 'Freunde einladen';

  @override
  String get settingsInviteFriendsBody =>
      'Ein Gratismonat für jeden geworbenen Freund';

  @override
  String get settingsAiProvider => 'KI-Anbieter';

  @override
  String get settingsAiProviderBody =>
      'Eigenes Modell für Tags und Bilder nutzen';

  @override
  String get settingsAppVersion => 'App-Version';

  @override
  String get settingsPrivacyTerms => 'Datenschutz und AGB';

  @override
  String get settingsReportProblem => 'Problem melden';

  @override
  String get settingsChangePassword => 'Passwort ändern';

  @override
  String get settingsExportData => 'Daten exportieren';

  @override
  String get settingsExportBody =>
      'Wir erstellen eine Datei mit all deinen Daten und öffnen den Download.';

  @override
  String get settingsExportAction => 'Exportieren';

  @override
  String get settingsCurrentPassword => 'Aktuelles Passwort';

  @override
  String get settingsNewPassword => 'Neues Passwort';

  @override
  String get settingsConfirmNewPassword => 'Neues Passwort bestätigen';

  @override
  String get settingsEnterCurrentPassword => 'Gib dein aktuelles Passwort ein';

  @override
  String get settingsEnterNewPassword => 'Gib ein neues Passwort ein';

  @override
  String get settingsPasswordMin8 => 'Mindestens 8 Zeichen verwenden';

  @override
  String get settingsPasswordNeedsUpper => 'Großbuchstaben hinzufügen';

  @override
  String get settingsPasswordNeedsLower => 'Kleinbuchstaben hinzufügen';

  @override
  String get settingsPasswordNeedsDigit => 'Zahl hinzufügen';

  @override
  String get settingsPasswordsNoMatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get settingsChangeAction => 'Ändern';

  @override
  String get itemAddSnapTitle => 'Kleidungsstück fotografieren';

  @override
  String get itemAddSnapBody =>
      'Wir erkennen jedes Teil auf dem Foto und erstellen saubere Studioaufnahmen.';

  @override
  String get itemAddCamera => 'Foto aufnehmen';

  @override
  String get itemAddGallery => 'Aus Galerie wählen';

  @override
  String get itemAddOtherWays => 'Weitere Optionen';

  @override
  String get itemAddSeveral => 'Mehrere Fotos hinzufügen';

  @override
  String get itemAddSeveralBody => 'Bis zu 50 gleichzeitig';

  @override
  String get itemAddImportProfile => 'Aus Profil importieren';

  @override
  String get itemAddImportProfileBody => 'Instagram oder Facebook';

  @override
  String get itemAddEnterDetails => 'Details manuell eingeben';

  @override
  String get itemAddEnterDetailsBody => 'Kein Foto erforderlich';

  @override
  String get itemManualIntro =>
      'Nur ein Name wird benötigt. Den Rest kannst du später ergänzen.';

  @override
  String get itemManualNameHint => 'Zum Beispiel: blaues Baumwollshirt';

  @override
  String get itemManualEnterName => 'Name eingeben';

  @override
  String get itemManualNotes => 'Notizen';

  @override
  String get itemManualBrand => 'Marke';

  @override
  String get itemManualSize => 'Größe';

  @override
  String get itemManualEnterNumber => 'Nummer eingeben';

  @override
  String get itemManualSavePiece => 'Teil speichern';

  @override
  String get itemManualSaving => 'Speichere';

  @override
  String get itemManualSavedTitle => 'Gespeichert';

  @override
  String itemManualSavedBody(String name) {
    return '$name ist in deinem Kleiderschrank.';
  }

  @override
  String get itemManualNotSaved => 'Nicht gespeichert';

  @override
  String get itemManualAddUseCase => 'Anlass hinzufügen';

  @override
  String get itemManualAddUseCaseAction => 'Anlass hinzufügen';

  @override
  String get itemPhotos => 'Fotos';

  @override
  String get itemAddPhotos => 'Fotos hinzufügen';

  @override
  String get itemNoPhotoYet =>
      'Noch kein Foto. Du kannst es auch ohne speichern.';

  @override
  String get itemRemovePhoto => 'Foto entfernen';

  @override
  String get itemRemovePiece => 'Teil entfernen';

  @override
  String get filterConditionLabel => 'Zustand';

  @override
  String get photoshootStepPhotos => 'Fotos';

  @override
  String get photoshootStepSetup => 'Einrichtung';

  @override
  String get photoshootStepCreating => 'Erstellung';

  @override
  String get photoshootStepResults => 'Ergebnisse';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Schritt $current von $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Ein Foto fehlgeschlagen. Unten erneut versuchen.';

  @override
  String photoshootManyFailed(int count) {
    return '$count Fotos fehlgeschlagen. Jedes unten erneut versuchen.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Anzahl';

  @override
  String get photoshootYourPrompt => 'Dein Prompt';

  @override
  String get photoshootPromptHint => 'Goldene Stunde auf dem Dach, Leinenhemd';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos erstellen',
      one: '1 Foto erstellen',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fotos',
      one: 'Foto',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Tageslimit konnte nicht geprüft werden.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan-Plan: $remaining von $limit heute übrig';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Kostenlos';

  @override
  String get photoshootGallery => 'Galerie';

  @override
  String get photoshootUseCamera => 'Kamera nutzen';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Foto $number entfernen';
  }

  @override
  String get photoshootNoPhotosTitle => 'Keine Fotos erhalten';

  @override
  String get photoshootNoPhotosBody =>
      'Das Shooting endete ohne Bilder. Erneut versuchen.';

  @override
  String get photoshootNewStyle => 'Neuer Stil';

  @override
  String get photoshootNewPhotos => 'Neue Fotos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Foto $number öffnen';
  }

  @override
  String get photoshootReportPhoto => 'Foto melden';

  @override
  String get photoshootSaveToGallery => 'In Galerie speichern';

  @override
  String get actionUpgrade => 'Upgrade';

  @override
  String get referralLimitTitle => 'Tageslimit erreicht';

  @override
  String get referralLimitBody =>
      'Deine kostenlosen Fotos sind morgen wieder verfügbar. Lade einen Freund ein und ihr erhaltet beide einen Monat Pro gratis.';

  @override
  String get referralLimitRefer => 'Freund einladen';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating-App';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Ästhetik';

  @override
  String get photoshootUseCustom => 'Eigener Prompt';

  @override
  String get photoshootDescLinkedin => 'Professionelle Business-Porträts';

  @override
  String get photoshootDescDating => 'Entspannt, warm und natürlich';

  @override
  String get photoshootDescPortfolio => 'Editorial, High-Fashion-Looks';

  @override
  String get photoshootDescInstagram => 'Lifestyle-Bilder für deinen Feed';

  @override
  String get photoshootDescAesthetic =>
      'Stimmungsvolle, künstlerische Aufnahmen';

  @override
  String get photoshootDescCustom => 'Beschreibe deinen Wunsch-Look';

  @override
  String get aspectSquare => 'Quadratisch';

  @override
  String get aspectPortrait => 'Hochformat';

  @override
  String get aspectLandscape => 'Querformat';

  @override
  String get aspectTall => 'Lang';

  @override
  String get aspectWide => 'Breit';

  @override
  String get tryOnAppBar => 'Virtuelle Anprobe';

  @override
  String get tryOnYourPhoto => 'Dein Foto';

  @override
  String get tryOnGarment => 'Kleidungsstück';

  @override
  String get tryOnUploadingPhoto => 'Foto wird hochgeladen';

  @override
  String get tryOnAddPhotoPrompt => 'Füge ein Ganzkörperfoto von dir hinzu';

  @override
  String get tryOnBodyPhotoHint => 'Ein Ganzkörperfoto funktioniert am besten';

  @override
  String get tryOnAddPhoto => 'Foto hinzufügen';

  @override
  String get tryOnChangePhoto => 'Foto ändern';

  @override
  String get tryOnPhotoLoadFailed => 'Dein Foto konnte nicht geladen werden.';

  @override
  String get tryOnChooseGarment => 'Wähle ein Kleidungsstück-Foto';

  @override
  String get tryOnChooseOneGarment => 'Wähle ein Kleidungsstück-Foto';

  @override
  String get tryOnGarmentHint =>
      'Ein flach liegendes Kleidungsstück oder auf einem Bügel funktioniert am besten';

  @override
  String get tryOnChange => 'Ändern';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Entfernen';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Stil';

  @override
  String get tryOnBackground => 'Hintergrund';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Dein Outfit wird erstellt. Das dauert etwa eine halbe Minute.';

  @override
  String get tryOnEmptyResult => 'Deine Anprobe erscheint hier';

  @override
  String get tryOnReportImage => 'Bild melden';

  @override
  String get tryOnCreating => 'Wird erstellt';

  @override
  String get tryOnTryAgain => 'Erneut versuchen';

  @override
  String get tryOnCreate => 'Anprobe erstellen';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio weiß';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio grau';

  @override
  String get tryOnBackgroundUrban => 'Urban';

  @override
  String get tryOnBackgroundNature => 'Natur';

  @override
  String get tryOnBackgroundMinimal => 'Minimalistisch';

  @override
  String get tryOnPoseFront => 'Frontal';

  @override
  String get tryOnPoseSide => 'Seitlich';

  @override
  String get tryOnPoseWalking => 'Gehend';

  @override
  String get dashboardGreetingMorning => 'Guten Morgen';

  @override
  String get dashboardGreetingAfternoon => 'Guten Tag';

  @override
  String get dashboardGreetingEvening => 'Guten Abend';

  @override
  String get dashboardWelcome => 'Willkommen';

  @override
  String get dashboardOpenProfile => 'Profil öffnen';

  @override
  String get dashboardRailToday => 'Heute';

  @override
  String get dashboardRailRecently => 'Kürzlich';

  @override
  String get dashboardActivityEmpty =>
      'Neue Teile und Outfits erscheinen hier.';

  @override
  String get quickAddPiece => 'Teil hinzufügen';

  @override
  String get quickAddPieceBody => 'Fotografieren und taggen';

  @override
  String get quickBuildOutfit => 'Outfit zusammenstellen';

  @override
  String get quickBuildOutfitBody => 'Teile kombinieren';

  @override
  String get quickForYou => 'Für dich';

  @override
  String get quickForYouBody => 'Empfehlungen für heute';

  @override
  String get quickPlanWeek => 'Woche planen';

  @override
  String get quickPlanWeekBody => 'Outfits nach Datum';

  @override
  String get referralBannerUrgent => 'Knapp bei Kasse? Lade Freunde ein.';

  @override
  String get referralBannerTitle =>
      'Einen Monat schenken, einen Monat erhalten.';

  @override
  String get referralBannerBody =>
      'Du und dein Freund erhalten jeweils einen Monat Pro.';

  @override
  String get referralBannerDismiss => 'Für eine Woche ausblenden';

  @override
  String get referralBannerShare => 'Einladung teilen';

  @override
  String get referralBannerCopy => 'Link kopieren';

  @override
  String get itemEditPieceTitle => 'Teil bearbeiten';

  @override
  String get itemEditDescriptionLabel => 'Beschreibung';

  @override
  String get itemEditNotSaved => 'Nicht gespeichert';

  @override
  String get itemEditSavedTitle => 'Gespeichert';

  @override
  String get itemEditSavedBody => 'Deine Änderungen wurden gespeichert.';

  @override
  String get itemEditSavedStalePhotos =>
      'Gespeichert – Fotos könnten veraltet sein';

  @override
  String get itemEditRemovePieceHint =>
      'Dieses Teil von der Artikelseite löschen.';

  @override
  String get itemEditNoPhotos =>
      'Noch keine Fotos. Füge eines aus der Galerie oder Kamera hinzu.';

  @override
  String get itemEditKeepPhoto => 'Foto behalten';

  @override
  String get itemEditRemoved => 'Entfernt';

  @override
  String get itemEditAddUseCaseAction => 'Hinzufügen';

  @override
  String get statsNoStatsTitle => 'Noch keine Statistiken';

  @override
  String get statsNoStatsBody =>
      'Füge ein paar Teile hinzu, damit dein Kleiderschrank-Mix hier erscheint.';

  @override
  String get statsByCategory => 'Nach Kategorie';

  @override
  String get statsTotalValue => 'Gesamtwert';

  @override
  String get statsMostWorn => 'Am häufigsten getragen';

  @override
  String get statsLeastWorn => 'Wartet auf Einsatz';

  @override
  String get statsUnnamedPiece => 'Unbenanntes Teil';

  @override
  String get jobsTitle => 'Scans';

  @override
  String get jobsEmptyTitle => 'Noch keine Scans';

  @override
  String get jobsEmptyBody =>
      'Fotografiere ein Kleidungsstück und lass es im Hintergrund bearbeiten — es läuft hier weiter.';

  @override
  String get jobsNotCancelled => 'Nicht abgebrochen';

  @override
  String get jobsResume => 'Fortsetzen';

  @override
  String get jobsReview => 'Überprüfen';

  @override
  String get jobsStop => 'Stoppen';

  @override
  String get jobsDismiss => 'Schließen';

  @override
  String get reportTitle => 'Inhalt melden';

  @override
  String reportIntro(String contentType) {
    return 'Sag uns, was mit diesem $contentType nicht stimmt. Unser Team prüft jede Meldung.';
  }

  @override
  String get reportReasonInappropriate => 'Unangemessen oder beleidigend';

  @override
  String get reportReasonNudity => 'Nacktheit oder sexuelle Inhalte';

  @override
  String get reportReasonHarassment => 'Belästigung oder Missbrauch';

  @override
  String get reportReasonImpersonation => 'Identitätsdiebstahl';

  @override
  String get reportReasonOther => 'Sonstiges';

  @override
  String get reportDetailsLabel => 'Zusätzliche Details (optional)';

  @override
  String get reportSubmit => 'Meldung senden';

  @override
  String get reportSubmittedTitle => 'Meldung gesendet';

  @override
  String get reportSubmittedBody =>
      'Danke. Unser Team wird diesen Inhalt prüfen.';

  @override
  String get reportFailedTitle => 'Meldung konnte nicht gesendet werden';

  @override
  String get reportFailedBody => 'Bitte versuche es erneut.';

  @override
  String get reportContentTryOnImage => 'KI-Anprobebild';

  @override
  String get reportContentSharedOutfit => 'geteiltes Outfit';

  @override
  String get reportContentPhotoshootImage => 'KI-Fotoshooting-Bild';

  @override
  String get sharedOutfitTitle => 'Geteiltes Outfit';

  @override
  String get sharedOutfitHideTooltip => 'Outfit ausblenden';

  @override
  String get sharedOutfitReportTooltip => 'Outfit melden';

  @override
  String get sharedOutfitHideTitle => 'Outfit ausblenden?';

  @override
  String get sharedOutfitHideBody =>
      'Es bleibt auf diesem Gerät ausgeblendet. Du kannst es auch melden, damit unser Team es prüfen und entfernen kann.';

  @override
  String get sharedOutfitHideAction => 'Ausblenden';

  @override
  String get sharedOutfitHiddenInfo =>
      'Dieses Outfit wird auf diesem Gerät nicht mehr angezeigt.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit ausgeblendet';

  @override
  String get sharedOutfitMissingTitle =>
      'Dieses Outfit ist nicht mehr verfügbar';

  @override
  String get sharedOutfitMissingBody =>
      'Es wurde möglicherweise entfernt oder der Link ist fehlerhaft.';

  @override
  String get sharedOutfitHiddenStateTitle =>
      'Du hast dieses Outfit ausgeblendet';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Falls es anstößig war, melde es unter Datenschutz und Bedingungen oder per E-Mail an $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Gefällt dir dieser Look?';

  @override
  String get sharedOutfitCtaBody =>
      'Erstelle ähnliche Outfits mit deinem eigenen Kleiderschrank.';

  @override
  String get sharedOutfitCtaButton => 'FitCheck AI holen';

  @override
  String get errorTitle => 'Fehler';

  @override
  String get errorUnknown => 'Ein unerwarteter Fehler ist aufgetreten';

  @override
  String get errorNoConnection =>
      'Keine Internetverbindung. Bitte Netzwerk prüfen.';

  @override
  String get errorTimeout => 'Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String get errorServerError =>
      'Etwas ist schiefgelaufen. Bitte erneut versuchen.';

  @override
  String get errorBadGateway =>
      'Server kurzzeitig nicht verfügbar. Bitte erneut versuchen.';

  @override
  String get errorServiceUnavailable =>
      'Dienst vorübergehend nicht verfügbar. Bitte gleich noch einmal versuchen.';

  @override
  String get errorInternalError =>
      'Etwas ist schiefgelaufen. Bitte erneut versuchen.';

  @override
  String get errorUnauthorized => 'Bitte anmelden, um fortzufahren.';

  @override
  String get errorForbidden => 'Dazu hast du keinen Zugriff.';

  @override
  String get errorSessionExpired =>
      'Sitzung abgelaufen. Bitte erneut anmelden.';

  @override
  String get errorInvalidCredentials =>
      'E-Mail-Adresse oder Passwort ist falsch.';

  @override
  String get errorTokenRefreshFailed =>
      'Sitzung konnte nicht erneuert werden. Bitte erneut anmelden.';

  @override
  String get errorRequestCancelled => 'Anfrage abgebrochen.';

  @override
  String get errorInvalidFormat => 'Dieses Dateiformat wird nicht unterstützt.';

  @override
  String get errorFileTooLarge => 'Die Datei ist zu groß.';

  @override
  String get errorUploadFailed =>
      'Upload fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get errorCacheCorrupted =>
      'Gespeicherte Daten waren beschädigt und wurden zurückgesetzt.';

  @override
  String get errorCacheNotFound => 'Noch nichts gespeichert.';

  @override
  String get errorUserNotFound => 'Konto wurde nicht gefunden.';

  @override
  String get errorItemNotFound => 'Dieses Teil existiert nicht mehr.';

  @override
  String get errorOutfitNotFound => 'Dieses Outfit existiert nicht mehr.';

  @override
  String get rewardsTitle => 'Prämien';

  @override
  String get rewardsNoAchievementsTitle => 'Noch keine Erfolge';

  @override
  String get rewardsNoAchievementsBody =>
      'Füge Teile hinzu und plane Outfits, um deinen ersten zu verdienen.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Noch niemand in der Bestenliste';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plane Outfits, um Punkte zu sammeln und hier aufzutauchen.';

  @override
  String get legalViewPrivacyPolicy => 'Datenschutzerklärung anzeigen';

  @override
  String get aiConsentAgree => 'Zustimmen & Weiter';

  @override
  String get aiConsentNotNow => 'Jetzt nicht';

  @override
  String get imageViewerCloseTooltip => 'Bildbetrachter schließen';

  @override
  String get updateReadyTitle => 'Update bereit';

  @override
  String get updateReadyBody =>
      'Starte FitCheck AI neu, um die neuesten Verbesserungen anzuwenden.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI benötigt Zugriff auf die Kamera, um Fotos von deinen Outfits und Kleidungsstücken aufzunehmen.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI benötigt Zugriff auf die Mediathek, um Bilder deiner Outfits und Kleidungsstücke auszuwählen.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI muss deine KI-generierten Outfit-Fotos in deiner Mediathek speichern.';

  @override
  String get wardrobeSomePhotosSkipped => 'Einige Fotos übersprungen';

  @override
  String get wardrobePhotosNotAdded => 'Fotos nicht hinzugefügt';

  @override
  String get wardrobePhotoNotAdded => 'Foto nicht hinzugefügt';

  @override
  String get wardrobeNotStartedTitle => 'Nicht begonnen';

  @override
  String get wardrobeNoRoomTitle => 'Kein Platz';

  @override
  String get wardrobeAddPhotosSemantic => 'Fotos hinzufügen';

  @override
  String get batchAddTileLabel => 'Hinzufügen';

  @override
  String get batchProfileLinkLabel => 'Profil-Link';

  @override
  String get wardrobeImportFromProfileTitle => 'Aus Profil importieren';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Mehrere Fotos hinzufügen';

  @override
  String get wardrobeClearAction => 'Zurücksetzen';

  @override
  String get wardrobeRefreshTooltip => 'Aktualisieren';

  @override
  String get batchNoPhotosYetTitle => 'Noch keine Fotos';

  @override
  String get batchChoosePhotosAction => 'Fotos auswählen';

  @override
  String get batchWeFindEachPieceBody =>
      'Wir erkennen jedes Teil und erstellen ein Studiofoto davon.';

  @override
  String get batchPreparingPhotosSemantic => 'Fotos werden vorbereitet';

  @override
  String get batchPhotosProcessedSemantic => 'Fotos verarbeitet';

  @override
  String get batchPasteProfileLinkTitle => 'Profil-Link einfügen';

  @override
  String get batchPasteProfileLinkBody =>
      'Ein öffentliches Instagram- oder Facebook-Profil. Wir scannen die Fotos und du wählst aus, was in deinen Schrank kommt.';

  @override
  String get batchClearLinkTooltip => 'Link löschen';

  @override
  String get batchStartingButton => 'Startet';

  @override
  String get batchStartImportAction => 'Import starten';

  @override
  String get batchReviewEveryPhotoTitle => 'Du prüfst jedes Foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Es wird erst etwas hinzugefügt, wenn du es genehmigst.';

  @override
  String get batchPrivateProfilesTitle => 'Private Profile';

  @override
  String get batchPrivateProfilesBody =>
      'Verknüpfe dein Konto. Instagram benötigt zudem einen Benutzernamen und ein Passwort.';

  @override
  String get batchUseAnotherLinkAction => 'Anderen Link verwenden';

  @override
  String get batchSignInNeededTitle => 'Anmeldung erforderlich';

  @override
  String get batchEnterYourCodeTitle => 'Code eingeben';

  @override
  String get batchUseUsernamePasswordAction => 'Mit Benutzername und Passwort';

  @override
  String get batchAlreadyConnectedAction =>
      'Ich habe mich im Browser verbunden';

  @override
  String get batchEnterCodeAction => 'Code eingeben';

  @override
  String get batchTryAnotherWayAction => 'Andere Methode';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Verbindung wird wiederhergestellt';

  @override
  String get batchSignInToInstagramTitle => 'Bei Instagram anmelden';

  @override
  String get batchUsernameLabel => 'Benutzername';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Code bei aktivierter Bestätigung in zwei Schritten';

  @override
  String get batchAuthenticatorCodeBody =>
      'Verwende den 6-stelligen Code deiner Authenticator-App. Codes wechseln schnell.';

  @override
  String get batchVerifyAction => 'Bestätigen';

  @override
  String get batchFindingPhotosTitle => 'Fotos suchen';

  @override
  String get batchImportPausedTitle => 'Import pausiert';

  @override
  String get batchProcessingPhotosTitle => 'Fotos verarbeiten';

  @override
  String get batchWaitingNextPhoto => 'Warten auf das nächste Foto';

  @override
  String get batchCancelImportAction => 'Import abbrechen';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Keine Kleidungsstücke auf diesem Foto gefunden.';

  @override
  String get batchEditPieceColoursLabel => 'Farben, durch Kommas getrennt';

  @override
  String get batchAddToClosetAction => 'Zum Kleiderschrank hinzufügen';

  @override
  String get batchSkipPhotoAction => 'Foto überspringen';

  @override
  String get batchImportCompleteTitle => 'Import abgeschlossen';

  @override
  String get batchImportFailedTitle => 'Import fehlgeschlagen';

  @override
  String get batchImportCancelledTitle => 'Import abgebrochen';

  @override
  String get batchImportErrorBody => 'Beim Import ist ein Fehler aufgetreten.';

  @override
  String get batchNothingMoreImportedBody =>
      'Es wird nichts mehr von diesem Profil importiert.';

  @override
  String get batchViewClosetAction => 'Garderobe ansehen';

  @override
  String get batchStartOverAction => 'Neu starten';

  @override
  String get wardrobeAddPieceTitle => 'Teil hinzufügen';

  @override
  String get wardrobeAddDetailsTitle => 'Details hinzufügen';

  @override
  String get wardrobeScanningTitle => 'Scannen';

  @override
  String get batchReviewPiecesTitle => 'Teile überprüfen';

  @override
  String get wardrobeGalleryAction => 'Galerie';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Neu';

  @override
  String get wardrobeRemovePhotoTooltip => 'Foto entfernen';

  @override
  String get batchRunInBackgroundTooltip => 'Im Hintergrund ausführen';

  @override
  String get batchStepOneOfTwo => 'Schritt 1 von 2';

  @override
  String get batchStepTwoOfTwo => 'Schritt 2 von 2';

  @override
  String get batchUploadingPhotosTitle => 'Fotos hochladen';

  @override
  String get batchFindingPiecesTitle => 'Teile finden';

  @override
  String get batchMakingStudioPhotosTitle => 'Studiografiken erstellen';

  @override
  String get batchStoppedLabel => 'Angehalten';

  @override
  String get batchFindingPiecesStoppedTitle => 'Suche angehalten';

  @override
  String get batchCancelledLabel => 'Abgebrochen';

  @override
  String get batchAllDoneTitle => 'Fertig';

  @override
  String get batchOpeningPiecesBody => 'Teile werden geöffnet';

  @override
  String get batchNothingSavedBody => 'Nichts wurde gespeichert.';

  @override
  String get batchFindingPiecesFailedBody => 'Teilesuche fehlgeschlagen.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Teilesuche vorzeitig gestoppt.';

  @override
  String get batchStopFindingPiecesTitle => 'Suche abbrechen?';

  @override
  String get batchStopFindingPiecesBody =>
      'Der Scan wird gestoppt und nichts wird gespeichert. Bereits gefundene Teile bleiben in deiner Aktivität, bis du sie schließt.';

  @override
  String get batchKeepGoingAction => 'Fortfahren';

  @override
  String get batchTryAgainAction => 'Erneut versuchen';

  @override
  String get batchBackToPhotosAction => 'Zurück zu Fotos';

  @override
  String get batchSkipAllAction => 'Alle überspringen';

  @override
  String get batchIncludeAllAction => 'Alle einschließen';

  @override
  String get batchNoPiecesFoundTitle => 'Keine Teile gefunden';

  @override
  String get batchNoPiecesFoundBody =>
      'Wir haben keine Kleidung auf diesen Fotos gefunden.';

  @override
  String get batchChooseOtherPhotosAction => 'Andere Fotos wählen';

  @override
  String get batchUseCaseHelper =>
      'Wird für jedes gespeicherte Teil übernommen.';

  @override
  String get batchDiscardPiecesTitle => 'Diese Teile verwerfen?';

  @override
  String get batchDiscardPiecesBody =>
      'Nichts aus diesem Stapel wird gespeichert.';

  @override
  String get batchKeepAction => 'Behalten';

  @override
  String get batchDiscardAction => 'Verwerfen';

  @override
  String get batchRemovePieceTitle => 'Dieses Teil entfernen?';

  @override
  String get batchRemovePieceBody =>
      'Es wird nicht in deinem Kleiderschrank gespeichert.';

  @override
  String get batchRemoveAction => 'Entfernen';

  @override
  String get batchChoosePiecesToSave => 'Teile zum Speichern wählen';

  @override
  String get batchDiscardAllAction => 'Alle verwerfen';

  @override
  String get batchNothingSavedRetryBody =>
      'Nichts wurde gespeichert. Versuche es erneut.';

  @override
  String get batchNotSavedTitle => 'Nicht gespeichert';

  @override
  String get batchSavingLabel => 'Wird gespeichert';

  @override
  String get batchSendToBackgroundAction => 'In den Hintergrund';

  @override
  String get batchStillWorkingMessage =>
      'Arbeite noch daran. Wir benachrichtigen dich, wenn deine Teile bereit sind.';

  @override
  String get batchRunningInBackgroundTitle => 'Läuft im Hintergrund';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studiofotos vorzeitig gestoppt. Du kannst diese Teile trotzdem speichern.';

  @override
  String get batchTapPieceToSkip =>
      'Tippe auf ein Teil, um es zu überspringen.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studiofotos unterwegs. Du kannst die App verlassen – wir geben dir Bescheid.';

  @override
  String get batchLeaveAction => 'Verlassen';

  @override
  String get batchPeopleInPhotosTitle => 'Personen auf den Fotos';

  @override
  String get batchIncludeAction => 'Einschließen';

  @override
  String get batchSkipAction => 'Überspringen';

  @override
  String get batchYourPhotoIsUsedLabel => 'Dein Foto wird verwendet';

  @override
  String get batchMakingStudioPhotoLabel => 'Studiofoto wird erstellt';

  @override
  String get batchNoStudioPhotoBody =>
      'Kein Studiofoto. Dein Foto wird verwendet.';

  @override
  String get batchEnterDetailsYourselfAction => 'Details selbst eingeben';

  @override
  String get batchChooseAnotherPhotoAction => 'Anderes Foto wählen';

  @override
  String get batchConnectionLostTitle => 'Verbindung unterbrochen';

  @override
  String get batchConnectionLostBody =>
      'Überprüfe deine Verbindung und versuche es erneut.';

  @override
  String get batchDailyLimitTitle => 'Tägliches Limit erreicht';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Upgrade auf Pro für mehr Scans oder gib die Details selbst ein.';

  @override
  String get batchDailyLimitBodyFree =>
      'Deine Scans werden morgen zurückgesetzt. Du kannst die Details jetzt selbst eingeben.';

  @override
  String get batchSeePlansAction => 'Pläne ansehen';

  @override
  String get batchAiBusyTitle => 'Unsere KI ist beschäftigt';

  @override
  String get batchAiBusyBody =>
      'Das liegt an uns. Versuche es in wenigen Minuten noch einmal.';

  @override
  String get batchNoPiecesBody =>
      'Versuche ein klareres Foto oder gib die Details selbst ein.';

  @override
  String get batchScanningUnavailableTitle => 'Scannen ist nicht verfügbar';

  @override
  String get batchScanningUnavailableBody =>
      'Gib die Details vorerst selbst ein.';

  @override
  String get batchScanDidNotFinishTitle => 'Der Scan wurde nicht beendet';

  @override
  String get batchTryAgainBody => 'Erneut versuchen.';

  @override
  String get billingTitle => 'Abonnement';

  @override
  String get billingUpgradeHeading => 'Plan upgraden';

  @override
  String get billingUpgradeOnPlusBody => 'Dieselbe Funktionen, höhere Limits.';

  @override
  String get billingUpgradeBody =>
      'Plus und Pro haben dieselben Funktionen. Wähle die Limits, die du brauchst.';

  @override
  String get billingWebUnavailableBody =>
      'Online-Upgrades sind noch nicht verfügbar. Ein Promo- oder Empfängercode schaltet Plus oder Pro weiterhin frei. Lade unten Freunde ein, um Gratis Monate zu verdienen.';

  @override
  String get billingPlansStale =>
      'Neueste Pläne konnten nicht geladen werden. Die Preise sind möglicherweise veraltet.';

  @override
  String get billingMonthly => 'Monatlich';

  @override
  String get billingYearly => 'Jährlich';

  @override
  String get billingCurrentPlan => 'Aktueller Plan';

  @override
  String get billingActive => 'Aktiv';

  @override
  String get billingThisMonth => 'Diesen Monat';

  @override
  String get billingItemExtractions => 'Teile-Erfassungen';

  @override
  String get billingOutfitVisualizations => 'Outfit-Visualisierungen';

  @override
  String get billingNearLimitUpgrade =>
      'Du bist nahe am Monatslimit. Upgrade für mehr.';

  @override
  String get billingNearLimitResets =>
      'Du bist nahe am Monatslimit. Es wird zu Beginn des nächsten Monats zurückgesetzt.';

  @override
  String get billingStoreUnavailable =>
      'Upgrades sind im Store noch nicht verfügbar. Schau bald wieder vorbei.';

  @override
  String get billingManageHeading => 'Abo verwalten';

  @override
  String get billingCancelPlan => 'Abo kündigen';

  @override
  String get billingCancelKeepsAccess =>
      'Du behältst den Zugriff bis zum Ende dieses Abrechnungszeitraums.';

  @override
  String get billingCancelConfirmTitle => 'Abo wirklich kündigen?';

  @override
  String get billingKeepPlan => 'Abo behalten';

  @override
  String get billingCancelPlanAction => 'Abo kündigen';

  @override
  String get billingBilledMonthly => 'Monatliche Abrechnung';

  @override
  String get billingBilledYearly => 'Jährliche Abrechnung';

  @override
  String get billingVirtualTryOn => 'Virtuelle Anprobe';

  @override
  String get billingPrioritySupport => 'Bevorzugter Support';

  @override
  String get billingDisclosureProRenewing =>
      'Pro ist ein sich automatisch verlängerndes Abo';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus und Pro sind sich automatisch verlängernde Abos';

  @override
  String get billingDisclosureAppleBilling =>
      'Die Zahlung wird bei Kaufbestätigung über deine Apple ID abgerechnet.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Die Zahlung wird bei Kaufbestätigung über dein Google Play-Konto abgerechnet.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Dein Abo verlängert sich automatisch um denselben Zeitraum zum selben Preis, es sei denn, du schaltest die Verlängerung mindestens 24 Stunden vor Ablauf des aktuellen Zeitraums aus.';

  @override
  String get billingDisclosureAppleManage =>
      'Verwaltung oder Kündigung jederzeit in den Einstellungen › deine Apple ID › Abonnements.';

  @override
  String get billingDisclosureGoogleManage =>
      'Verwaltung oder Kündigung jederzeit in Google Play › Zahlungen und Abonnements.';

  @override
  String get billingReferFriend => 'Freunde einladen';

  @override
  String get billingHowItWorks => 'So funktioniert es';

  @override
  String get billingHowShareTitle => 'Link teilen';

  @override
  String get billingHowShareBody =>
      'Sende ihn an eine Freundin oder einen Freund.';

  @override
  String get billingHowSignUpTitle => 'Anmeldung';

  @override
  String get billingHowSignUpBody =>
      'Dein Gegenüber registriert sich über den Link.';

  @override
  String get billingHowBothTitle => 'Ihr beide erhaltet Pro';

  @override
  String get billingHowBothBody =>
      'Jeder von euch bekommt einen Monat Pro geschenkt.';

  @override
  String get billingYourReferrals => 'Deine Empfehlungen';

  @override
  String get billingInvited => 'Eingeladen';

  @override
  String get billingJoined => 'Beigetreten';

  @override
  String get billingMonthsEarned => 'Verdiente Monate';

  @override
  String get billingInviteFriend => 'Freund einladen';

  @override
  String get billingInviteBody =>
      'Du und dein Freund erhalten jeweils einen Monat Pro.';

  @override
  String get billingYourCode => 'Dein Code';

  @override
  String get billingCopyLink => 'Link kopieren';

  @override
  String get billingShareInvite => 'Einladung teilen';

  @override
  String get giftUnavailable =>
      'Geschenkeinladungen sind in dieser Version nicht verfügbar.';

  @override
  String get giftPageTitle => 'FitCheck Pro verschenken';

  @override
  String get giftNoAllowances =>
      'Derzeit sind keine kostenlosen Geschenkeinladungen verfügbar.';

  @override
  String get giftFormTitle => 'Kostenlose Einladung senden';

  @override
  String get giftFormBody =>
      'Der Empfänger löst das Geschenk mit dieser bestätigten E-Mail ein. Wir versenden die E-Mail nicht für dich.';

  @override
  String get giftFieldFrom => 'Von';

  @override
  String get giftFieldRecipientName => 'Name des Empfängers';

  @override
  String get giftFieldRecipientEmail => 'E-Mail des Empfängers';

  @override
  String get giftFieldOccasion => 'Anlass (optional)';

  @override
  String get giftNoOccasion => 'Kein Anlass';

  @override
  String get giftOccasionBirthday => 'Geburtstag';

  @override
  String get giftOccasionAnniversary => 'Jahrestag';

  @override
  String get giftOccasionOther => 'Sonstiges';

  @override
  String get giftFieldCardGreeting => 'Grußkarten-Text';

  @override
  String get giftFieldCardGreetingHelper =>
      'Dies erscheint genau wie geschrieben auf der Karte.';

  @override
  String get giftFieldPrivateNote => 'Private Notiz (optional)';

  @override
  String get giftCreateAction => 'Kostenloses Geschenk erstellen';

  @override
  String get giftClaimedTitle => 'Geschenk eingelöst';

  @override
  String get giftClaimedActive => 'Dein FitCheck Pro-Geschenk ist aktiv.';

  @override
  String get giftClaimedQueued =>
      'Dein FitCheck Pro-Geschenk beginnt nach Ablauf deines aktuellen Zugriffs.';

  @override
  String get giftLinkCopied => 'Geschenklink in die Zwischenablage kopiert.';

  @override
  String get giftErrorName => 'Gib einen Namen ein.';

  @override
  String get giftErrorEmail => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get giftErrorGreeting => 'Gib den Grußkarten-Text ein.';

  @override
  String get giftErrorGreetingLength => 'Verwende maximal 80 Zeichen.';

  @override
  String get giftClaimAction => 'Geschenk einlösen';

  @override
  String get giftCardPreview => 'Kartenansicht';

  @override
  String get giftGiftForYou => 'Ein Geschenk für dich';

  @override
  String get giftGiftWaiting => 'Ein Geschenk wartet auf dich';

  @override
  String get giftOpenBody =>
      'Öffne deine Geschenke und löse sie mit deiner verifizierten E-Mail ein.';

  @override
  String get giftOpenGifts => 'Geschenke öffnen';

  @override
  String get giftSendInvitation => 'Einladung senden';

  @override
  String get settingsAiProviderSection => 'Anbieter';

  @override
  String get settingsAiCustom => 'Benutzerdefiniert';

  @override
  String get settingsAiUrlHelper =>
      'Verwende eine öffentliche URL, die der Server erreichen kann. Localhost funktioniert von unseren Servern aus nicht.';

  @override
  String get settingsAiConnectionSection => 'Verbindung';

  @override
  String get settingsAiApiUrl => 'API-URL';

  @override
  String get settingsAiApiKey => 'API-Schlüssel';

  @override
  String get settingsAiApiKeySaved =>
      'Gespeichert. Leer lassen, um ihn beizubehalten.';

  @override
  String get settingsAiChatModel => 'Chat-Modell';

  @override
  String get settingsAiVisionModel => 'Vision-Modell (optional)';

  @override
  String get settingsAiImageModel => 'Bildmodell (optional)';

  @override
  String get settingsAiImageModelNote =>
      'Die Bilderstellung erfordert OpenAI-kompatible Chat-Completions mit response_modalities.';

  @override
  String get settingsAiTestConnection => 'Verbindung testen';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarGoToToday => 'Heute';

  @override
  String get calendarConnectTooltip => 'Kalender verbinden';

  @override
  String get calendarAddEvent => 'Ereignis hinzufügen';

  @override
  String get calendarEmptyTitle => 'Nichts geplant';

  @override
  String get calendarEmptyBody =>
      'Füge ein Ereignis hinzu und plane dein Outfit.';

  @override
  String get calendarPreviousMonth => 'Vorheriger Monat';

  @override
  String get calendarNextMonth => 'Nächster Monat';

  @override
  String get calendarAllDay => 'Ganztägig';

  @override
  String get calendarOutfitLinked => 'Outfit verknüpft';

  @override
  String get calendarEventOptions => 'Ereignisoptionen';

  @override
  String get calendarDeleteTitle => 'Diesen Termin löschen?';

  @override
  String get calendarChangeOutfit => 'Outfit ändern';

  @override
  String get calendarLinkOutfit => 'Outfit verknüpfen';

  @override
  String get calendarRemoveOutfit => 'Outfit entfernen';

  @override
  String get calendarNewEvent => 'Neuer Termin';

  @override
  String get calendarEditEvent => 'Termin bearbeiten';

  @override
  String get calendarTitleLabel => 'Titel';

  @override
  String get calendarTitleRequired => 'Titel eingeben';

  @override
  String get calendarEndBeforeStart => 'Ende nach der Startzeit';

  @override
  String get calendarStarts => 'Beginn';

  @override
  String get calendarEnds => 'Ende';

  @override
  String get calendarPlaceOptional => 'Ort (optional)';

  @override
  String get calendarNotesOptional => 'Notizen (optional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Erstelle ein Outfit und verknüpfe es mit diesem Termin.';

  @override
  String get calendarBuildOutfit => 'Outfit erstellen';

  @override
  String get calendarConnectionsTitle => 'Kalender';

  @override
  String get calendarConnectionsBody =>
      'Hier hinzugefügte Termine bleiben in FitCheck.';

  @override
  String get calendarDisconnect => 'Trennen';

  @override
  String get calendarNotAvailable => 'Noch nicht verfügbar';

  @override
  String get profileSectionExplore => 'Entdecken';

  @override
  String get profileNavTryOn => 'Anprobe';

  @override
  String get profileNavRewards => 'Prämien';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Hilfe';

  @override
  String get profileAbout => 'Über';

  @override
  String get profileAboutBody =>
      'Dein Kleiderschrank, Outfits und Pläne an einem Ort.';

  @override
  String get profileSignOutTitle => 'Abmelden?';

  @override
  String get profileSignOutBody => 'Du kannst dich jederzeit wieder anmelden.';

  @override
  String get profileEditTitle => 'Profil bearbeiten';

  @override
  String get profileYourProfile => 'Dein Profil';

  @override
  String get profileBodyProfiles => 'Körpprofile';

  @override
  String get profileBodyEmptyTitle => 'Noch keine Körpprofile';

  @override
  String get profileBodyEmptyBody =>
      'Füge Größe und Statur hinzu, um eine bessere Passform zu erhalten.';

  @override
  String get profileBodyAdd => 'Profil hinzufügen';

  @override
  String get profileBodyDefaultNote =>
      'Dein Standardprofil wird für Passform und Anprobe verwendet.';

  @override
  String get profileBodyDefaultBadge => 'Standard';

  @override
  String get profileBodyMakeDefault => 'Als Standard festlegen';

  @override
  String get profileBodyDeleteBody =>
      'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get profileBodyRequired => 'Erforderlich';

  @override
  String get profileBodyCheckNumber => 'Überprüfe diese Zahl';

  @override
  String get profileBodyNew => 'Neues Körpprofil';

  @override
  String get profileBodyNameHint => 'Zum Beispiel: Ich';

  @override
  String get profileBodyHeight => 'Größe';

  @override
  String get profileBodyWeight => 'Gewicht';

  @override
  String get profileBodyBuild => 'Statur';

  @override
  String get profileBodySkinTone => 'Hautton';

  @override
  String get profileBirthDateNeededBody =>
      'Füge ein Geburtsdatum passend zur Geburtszeit hinzu.';

  @override
  String get profileBirthDateNeededTitle => 'Geburtsdatum erforderlich';

  @override
  String get profilePartlySavedBody =>
      'Dein Name und Foto wurden gespeichert. Geburtsdaten konnten nicht gespeichert werden; versuche es später erneut.';

  @override
  String get profilePartlySavedTitle => 'Teilweise gespeichert';

  @override
  String get profileSavedBody => 'Dein Profil wurde gespeichert.';

  @override
  String get profileChangePhoto => 'Profilfoto ändern';

  @override
  String get profilePhotoLabel => 'Profilfoto';

  @override
  String get profilePhotoHint => 'Tippen, um ein neues auszuwählen';

  @override
  String get profileBirthDateLabel => 'Geburtsdatum (optional)';

  @override
  String get profileBirthTimeLabel => 'Geburtszeit (optional)';

  @override
  String get profileBirthTimeHelper => 'Macht vedische Vorschläge präziser';

  @override
  String get profileBirthPlaceLabel => 'Geburtsort (optional)';

  @override
  String get profileBirthPlaceHint => 'Zum Beispiel: Berlin, Deutschland';

  @override
  String get profileHelpContactTitle => 'Frag uns alles';

  @override
  String get profileHelpContactBody =>
      'Sende uns eine Nachricht und wir antworten per E-Mail, meist innerhalb eines Tages.';

  @override
  String get profileHelpContactAction => 'Support kontaktieren';

  @override
  String get profileHelpFaqTitle => 'Häufige Fragen';

  @override
  String get profileFaqAddPiecesTitle =>
      'Wie füge ich Stücke zu meinem Kleiderschrank hinzu?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tippe im Reiter Kleiderschrank auf Teil hinzufügen. Mach ein Foto oder wähle eines aus deiner Mediathek; wir erkennen jedes Teil und verschlagworten es für dich.';

  @override
  String get profileFaqMatchingTitle => 'Wie funktioniert das Outfit-Matching?';

  @override
  String get profileFaqMatchingBody =>
      'Öffne Für dich und wähle deine Kleidungsstücke aus. Wir schlagen passende Partner vor und stellen komplette Outfits aus deinem Kleiderschrank zusammen.';

  @override
  String get profileFaqTryOnTitle =>
      'Kann ich eigene Fotos für die Anprobe nutzen?';

  @override
  String get profileFaqTryOnBody =>
      'Ja. Füge ein Ganzkörperfoto von dir hinzu und wähle dann Stücke aus, um sie an dir zu sehen.';

  @override
  String get profileFaqRewardsTitle => 'Wie verdiene ich Belohnungen?';

  @override
  String get profileFaqRewardsBody =>
      'Plane und trage Outfits regelmäßig. Serien und Erfolge wachsen mit der Zeit.';

  @override
  String get profileFaqPrivacyTitle => 'Ist mein Kleiderschrank privat?';

  @override
  String get profileFaqPrivacyBody =>
      'Ja. Dein Kleiderschrank und deine Outfits sind privat, es sei denn, du teilst den Link zu einem Outfit.';

  @override
  String get profileHelpMoreTitle => 'Weitere Hilfe';

  @override
  String get profileHelpGuides => 'Anleitungen';

  @override
  String get profileHelpGuidesBody => 'Wie die einzelnen Funktionen arbeiten';

  @override
  String get feedbackCategoryBug => 'Etwas ist kaputt';

  @override
  String get feedbackCategoryIdea => 'Eine Idee';

  @override
  String get feedbackCategoryGeneral => 'Allgemein';

  @override
  String get feedbackCategoryHelp => 'Ich brauche Hilfe';

  @override
  String get feedbackHintBug =>
      'Was ist passiert und was hast du erwartet? Schritte helfen uns bei der Fehlerbehebung.';

  @override
  String get feedbackHintIdea => 'Was wünschst du dir und warum?';

  @override
  String get feedbackHintGeneral =>
      'Teile uns deine Meinung mit oder stelle eine Frage.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Du kannst bis zu 5 Bilder hinzufügen.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limit erreicht';

  @override
  String get feedbackImageTooLargeBody => 'Wähle ein Bild unter 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Bild zu groß';

  @override
  String get feedbackTitle => 'Feedback senden';

  @override
  String get feedbackAboutLabel => 'Worum geht es?';

  @override
  String get feedbackSubjectLabel => 'Betreff';

  @override
  String get feedbackSubjectRequired => 'Betreff eingeben';

  @override
  String get feedbackSubjectTooShort =>
      'Betreff muss mindestens 3 Zeichen lang sein';

  @override
  String get feedbackDetailsLabel => 'Details';

  @override
  String get feedbackDetailsRequired => 'Details eingeben';

  @override
  String get feedbackDetailsTooShort =>
      'Beschreibung muss mindestens 10 Zeichen lang sein';

  @override
  String get feedbackAddScreenshot => 'Screenshot hinzufügen';

  @override
  String get feedbackAttachmentHint => 'Bis zu 5, je max. 5 MB';

  @override
  String get feedbackSend => 'Senden';

  @override
  String get feedbackEmptyTitle => 'Noch nichts gesendet';

  @override
  String get feedbackEmptyBody =>
      'Hier siehst du deine gesendeten Anfragen und ihren Status.';

  @override
  String get feedbackHistoryTitle => 'Deine Nachrichten';

  @override
  String get feedbackStatusOpen => 'Offen';

  @override
  String get feedbackStatusInProgress => 'In Bearbeitung';

  @override
  String get feedbackStatusResolved => 'Gelöst';

  @override
  String get feedbackStatusClosed => 'Geschlossen';

  @override
  String get legalIntro =>
      'Wie wir deine Daten schützen und die Nutzungsbedingungen für FitCheck AI.';

  @override
  String get legalPolicies => 'Richtlinien';

  @override
  String get legalPrivacySubtitle => 'Was wir erfassen und warum';

  @override
  String get legalTermsTitle => 'Nutzungsbedingungen';

  @override
  String get legalTermsSubtitle => 'Regeln für die App-Nutzung';

  @override
  String get legalLicences => 'Open-Source-Lizenzen';

  @override
  String get legalSupportSubtitle => 'Hilfe, Kontakt und Datenschutz';

  @override
  String get legalReportAbuse => 'Problem oder Missbrauch melden';

  @override
  String get permissionCameraTitle => 'Kamerazugriff';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI nutzt deine Kamera, um Kleidung und Outfits für KI-Anproben und deinen Kleiderschrank zu fotografieren.';

  @override
  String get permissionPhotoTitle => 'Fotozugriff';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI benötigt Zugriff auf deine Fotos, damit du Kleidung und Outfit-Bilder für KI-Funktionen auswählen kannst.';

  @override
  String get permissionNotNow => 'Nicht jetzt';

  @override
  String get permissionOpenSettings => 'Einstellungen öffnen';

  @override
  String authSignedInAs(String name) {
    return 'Angemeldet als $name';
  }

  @override
  String get authSignedIn => 'Angemeldet';

  @override
  String get authWelcomeBackTitle => 'Willkommen zurück';

  @override
  String get authSignInFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get authWelcomeTitle => 'Willkommen';

  @override
  String get authSignUpFailed => 'Registrierung fehlgeschlagen';

  @override
  String get authGoogleSignInFailed => 'Google-Anmeldung fehlgeschlagen';

  @override
  String get authAppleSignInFailed => 'Apple-Anmeldung fehlgeschlagen';

  @override
  String get authConfirmEmailTitle => 'E-Mail bestätigen';

  @override
  String get authConfirmEmailBody =>
      'Prüfen Sie Ihr Postfach auf eine Bestätigungs-E-Mail und melden Sie sich dann an.';

  @override
  String get authClosetReady => 'Dein Kleiderschrank ist bereit.';

  @override
  String get authSignedOutTitle => 'Abgemeldet';

  @override
  String get authSignedOutBody => 'Sie sind abgemeldet.';

  @override
  String get authSignOutFailed => 'Abmeldung fehlgeschlagen';

  @override
  String get authEmailSentTitle => 'E-Mail gesendet';

  @override
  String get authResetLinkSent =>
      'Prüfen Sie Ihre E-Mails auf einen Link zum Zurücksetzen.';

  @override
  String get authPasswordUpdatedTitle => 'Passwort aktualisiert';

  @override
  String get authPasswordUpdated => 'Ihr Passwort wurde aktualisiert.';

  @override
  String get authPasswordNotUpdated => 'Passwort nicht aktualisiert';

  @override
  String get authCouldNotSendEmail => 'E-Mail konnte nicht gesendet werden';

  @override
  String get authEmailNotSent => 'E-Mail nicht gesendet';

  @override
  String get authResendSentBody =>
      'Wir haben eine neue Bestätigungs-E-Mail gesendet.';

  @override
  String get outfitPreviewWithAi => 'Vorschau mit KI';

  @override
  String get outfitNewPreview => 'Neue Vorschau erstellen';

  @override
  String get outfitBuilderClosetHeading => 'Dein Schrank';

  @override
  String get outfitBuilderSearchHint => 'Stücke suchen';

  @override
  String get outfitClearSearch => 'Suche leeren';

  @override
  String get outfitBuilderAddPiecesTitle => 'Erst Stücke hinzufügen';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits werden aus den Stücken in deinem Schrank zusammengestellt.';

  @override
  String get outfitBuilderNoMatches => 'Keine passenden Stücke.';

  @override
  String get outfitNameLabel => 'Outfit-Name';

  @override
  String get outfitNameHint => 'Z. B. Wochenend-Leinen';

  @override
  String get outfitPreviewSemantic => 'KI-Vorschau des Outfits';

  @override
  String get outfitChoosePieces => 'Stücke auswählen';

  @override
  String get outfitTapPiecesHint =>
      'Tippe unten auf Stücke, um sie hinzuzufügen.';

  @override
  String get outfitShareTooltip => 'Teilen';

  @override
  String get outfitSaveFavourite => 'Als Favorit speichern';

  @override
  String get outfitPiecesHeading => 'Stücke';

  @override
  String get outfitWearHistoryEmpty =>
      'Trage es einmal und die Daten erscheinen hier.';

  @override
  String get outfitWearHistoryTitle => 'Tragehistorie';

  @override
  String get outfitWearHistoryError => 'Daten konnten nicht geladen werden.';

  @override
  String get outfitWornOn => 'Getragen am';

  @override
  String get outfitEditTitle => 'Outfit bearbeiten';

  @override
  String get outfitSavedPhotosFailed => 'Details gespeichert, Fotos nicht';

  @override
  String get outfitNoPhotosBody =>
      'Noch keine Fotos. Das Outfit zeigt stattdessen seine Stücke.';

  @override
  String get outfitOccasionLabel => 'Anlass';

  @override
  String get outfitOccasionNone => 'Keine';

  @override
  String get outfitTagsHint => 'Mit Komma trennen';

  @override
  String get outfitDraftBody => 'Aus deiner Hauptliste ausgeblendet';

  @override
  String get outfitPublic => 'Öffentlich';

  @override
  String get outfitPublicBody => 'Jeder mit dem Link kann es sehen';

  @override
  String get outfitDeleteFromDetail =>
      'Dieses Outfit von seiner Detailseite löschen.';

  @override
  String get outfitNewCollection => 'Neue Kollektion';

  @override
  String get outfitNoCollectionsTitle => 'Noch keine Kollektionen';

  @override
  String get outfitNoCollectionsBody =>
      'Gruppier Outfits nach Reise, Jahreszeit oder Stimmung.';

  @override
  String get outfitCreateCollection => 'Kollektion erstellen';

  @override
  String get outfitAddOutfits => 'Outfits hinzufügen';

  @override
  String get outfitRename => 'Umbenennen';

  @override
  String get outfitCollectionDeleteBody => 'Die Outfits bleiben erhalten.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfits nicht geladen';

  @override
  String get outfitRenameCollection => 'Kollektion umbenennen';

  @override
  String get outfitDescriptionOptional => 'Beschreibung (optional)';

  @override
  String get outfitAllInCollection =>
      'Jedes Outfit ist bereits in dieser Kollektion.';

  @override
  String get photoshootSubtitleUpload =>
      'Studioporträts aus deinen eigenen Fotos';

  @override
  String get photoshootSubtitleConfigure => 'Wähle Stil, Format und Anzahl';

  @override
  String get photoshootSubtitleGenerating => 'Das dauert ein oder zwei Minuten';

  @override
  String get photoshootAddPhotosSemantic =>
      'Fotos aus deiner Galerie hinzufügen';

  @override
  String get photoshootUploadTitle => 'Füge 1–4 Fotos von dir selbst hinzu';

  @override
  String get photoshootUploadBody => 'Tippe, um aus deiner Galerie zu wählen';

  @override
  String get photoshootAddToContinue => 'Füge ein Foto hinzu, um fortzufahren';

  @override
  String get photoshootAddAnotherPhoto => 'Weitere Foto hinzufügen';

  @override
  String get photoshootTipsTitle => 'Für die besten Ergebnisse';

  @override
  String get photoshootTipsBody =>
      'Nutze klare, gut beleuchtete Gesichtsphotos aus verschiedenen Blickwinkeln. Vermeide Sonnenbrillen und Hüte.';

  @override
  String get photoshootStarting => 'Wird gestartet';

  @override
  String get photoshootCancelling => 'Wird abgebrochen';

  @override
  String get photoshootFailed => 'Fehlgeschlagen';

  @override
  String get recommendTabMatches => 'Passende';

  @override
  String get recommendTabComplete => 'Komplettieren';

  @override
  String get recommendTabWeather => 'Wetter';

  @override
  String get recommendTabColours => 'Farben';

  @override
  String get recommendTabShop => 'Shop';

  @override
  String get recommendNoMatchesTitle => 'Noch keine passenden Outfits';

  @override
  String get recommendNoMatchesBody =>
      'Wähle ein Teil und wir finden passende Kombinationen.';

  @override
  String get recommendPickPiece => 'Teil wählen';

  @override
  String get recommendNothingMatchesTitle => 'Noch keine passenden Teile';

  @override
  String get recommendNothingMatchesBody =>
      'Versuche andere Teile oder füge mehr hinzu.';

  @override
  String get recommendChangePieces => 'Teile ändern';

  @override
  String get recommendDefaultReason => 'Passt zu deinen Auswahl.';

  @override
  String get recommendCompleteTitle => 'Look vervollständigen';

  @override
  String get recommendCompleteBody =>
      'Wähle ein Teil und wir ergänzen den Rest.';

  @override
  String get recommendWorking => 'Arbeite...';

  @override
  String get recommendGenerate => 'Generieren';

  @override
  String get recommendChooseStyleBody => 'Wähle einen Stil und generiere.';

  @override
  String get recommendNoLooksTitle => 'Keine Looks für diese Teile';

  @override
  String get recommendNoLooksBody =>
      'Versuche einen anderen Stil oder andere Teile.';

  @override
  String get recommendDefaultLook => 'Ein Look für deine Teile';

  @override
  String get recommendNoPiecesBody => 'Keine Teile für diesen Look gefunden.';

  @override
  String get recommendCityLabel => 'Stadt';

  @override
  String get recommendCheck => 'Prüfen';

  @override
  String get recommendWeatherTitle => 'Wie ist das Wetter?';

  @override
  String get recommendWeatherBody => 'Gib deine Stadt an für Tipps für heute.';

  @override
  String get recommendWearToday => 'Heute tragen';

  @override
  String get recommendWeatherNoPieces =>
      'Noch keine passenden Teile im Kleiderschrank.';

  @override
  String get recommendBudgetLabel => 'Budget bis';

  @override
  String get recommendLooking => 'Suche';

  @override
  String get recommendFindWhatToBuy => 'Einkaufsliste';

  @override
  String get recommendFillGapsTitle => 'Lücken füllen';

  @override
  String get recommendFillGapsBody =>
      'Setze ein Budget und wir schlagen fehlende Teile vor.';

  @override
  String get recommendNoGapsTitle => 'Keine Lücken gefunden';

  @override
  String get recommendNoGapsBody =>
      'Versuche ein größeres Budget oder eine andere Kategorie.';

  @override
  String get recommendMoodEveryday => 'Alltag';

  @override
  String get recommendMoodBigMeeting => 'Wichtiges Meeting';

  @override
  String get recommendDayLabel => 'Tag';

  @override
  String get recommendReadingStars => 'Sternzeichen lesen';

  @override
  String get recommendGetMyColours => 'Meine Farben';

  @override
  String get recommendLuckyColoursTitle => 'Deine Glücksfarben';

  @override
  String get recommendLuckyColoursBody =>
      'Wähle einen Tag und wir schlagen Farben und Stücke vor.';

  @override
  String get recommendLuckyColoursSection => 'Glücksfarben';

  @override
  String get recommendAvoidColoursSection => 'Farben einschränken';

  @override
  String get recommendBirthDateTitle => 'Geburtsdatum hinzufügen';

  @override
  String get recommendBirthDateBody =>
      'Wir benötigen dein Geburtsdatum für die Farbenanalyse.';

  @override
  String get recommendEditProfile => 'Profil bearbeiten';

  @override
  String get recommendNothingThisDay => 'Nichts für diesen Tag.';

  @override
  String get recommendUnnamedColour => 'Namenlose Farbe';

  @override
  String get recommendFromCloset => 'Aus deinem Schrank';

  @override
  String get recommendNoPiecesInColours =>
      'Noch keine Stücke in diesen Farben.';

  @override
  String get recommendOutfitIdeas => 'Styling-Ideen';

  @override
  String get recommendNoOutfitsInColours =>
      'Noch kein komplettes Outfit in diesen Farben.';

  @override
  String get recommendDefaultOutfitIdea => 'Eine Outfit-Idee';

  @override
  String get recommendPickUpToThree => 'Maximal drei Stücke wählen';

  @override
  String get recommendEmptyClosetBody => 'Füge zuerst ein paar Stücke hinzu.';

  @override
  String get dashboardDressForDay => 'Kleide dich für den Tag.';

  @override
  String get dashboardOutfitOfDay => 'Outfit des Tages';

  @override
  String get dashboardFreshLook => 'Ein neuer Look';

  @override
  String get subscriptionManageInStoreTitle => 'Im Store verwalten';

  @override
  String get subscriptionManageInStoreBody =>
      'Diese Abrechnung läuft über den Store. Verwalte sie in deinen Store-Kontoeinstellungen.';

  @override
  String get subscriptionCancelledTitle => 'Abonnement gekündigt';

  @override
  String get subscriptionCancelledBody =>
      'Dein Tarif bleibt bis zum Ende des Abrechnungszeitraums aktiv.';

  @override
  String get subscriptionCancelFailedTitle => 'Kündigung nicht möglich';

  @override
  String get subscriptionCouldNotOpenTitle => 'Konnte nicht geöffnet werden';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Abrechnungsverwaltung konnte nicht geöffnet werden.';

  @override
  String get subscriptionOpenLinkFailedBody =>
      'Link konnte nicht geöffnet werden.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Link konnte nicht geladen werden';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Dein Empfehlungslink konnte nicht geladen werden. Versuche es erneut.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopiert';

  @override
  String get subscriptionReferralCopiedBody => 'Empfehlungslink kopiert.';

  @override
  String get subscriptionReferralShareSubject => 'Probiere FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Tritt FitCheck AI bei und wir erhalten beide einen Monat Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link kopiert';

  @override
  String get subscriptionShareUnavailableBody =>
      'Teilen ist nicht verfügbar. Der Link wurde kopiert.';

  @override
  String get subscriptionShareFailedTitle => 'Teilen nicht möglich';

  @override
  String get subscriptionShareFailedBody =>
      'Kopiere den Link stattdessen von der Empfehlungsseite.';

  @override
  String get subscriptionStoreReadyTitle => 'Store bereit';

  @override
  String get subscriptionStoreReadyBody =>
      'Store-Preise verfügbar. Du kannst jetzt upgraden.';

  @override
  String get purchaseFailedTitle => 'Kauf fehlgeschlagen';

  @override
  String get purchaseUnavailableTitle => 'Kauf nicht verfügbar';

  @override
  String get purchaseIapUnavailableBody =>
      'In-App-Käufe sind auf diesem Gerät nicht verfügbar.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Dieses Abo ist noch nicht kaufbar.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Dieses Abo ist im Store noch nicht verfügbar. Schau später wieder vorbei.';

  @override
  String get purchaseStartFailedBody =>
      'Der Kauf konnte nicht gestartet werden. Versuche es erneut.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Die Kasse hat keinen Zahlungslink zurückgegeben.';

  @override
  String get purchasePendingTitle => 'Kauf ausstehend';

  @override
  String get purchasePendingBody =>
      'Dein Kauf wird auf Genehmigung geprüft. Sobald genehmigt, erhältst du Zugriff.';

  @override
  String get purchaseFailedBody =>
      'Der Kauf ist fehlgeschlagen. Versuche es erneut.';

  @override
  String get purchaseRestoredTitle => 'Wiederhergestellt';

  @override
  String get purchaseRestoredBody => 'Deine Käufe wurden wiederhergestellt.';

  @override
  String get purchaseActiveTitle => 'Abonnement aktiv';

  @override
  String get purchaseActiveBody => 'Dein Abonnement ist aktiv. Willkommen.';

  @override
  String get purchaseSignInRequiredTitle => 'Anmeldung erforderlich';

  @override
  String get purchaseSignInRequiredBody =>
      'Melde dich an, um den Kauf abzuschließen.';

  @override
  String get purchaseErrorTitle => 'Kauffehler';

  @override
  String get purchaseInvalidTransactionBody =>
      'Der Kauf enthielt keine überprüfbare Transaktions-ID.';

  @override
  String get purchaseVerificationPendingTitle => 'Verifizierung ausstehend';

  @override
  String get purchaseVerificationPendingBody =>
      'Dein Kauf kann gerade nicht beim Store verifiziert werden. Die Abwicklung erfolgt automatisch und du zahlst nicht doppelt.';

  @override
  String get purchaseNotAppliedTitle => 'Kauf nicht bearbeitet';

  @override
  String get purchaseNotAppliedBody =>
      'Dein Kauf konnte deinem Konto nicht zugeordnet werden. Wende dich an den Support und kaufe nicht erneut.';

  @override
  String get purchaseRestoreFailedTitle => 'Wiederherstellung fehlgeschlagen';

  @override
  String get purchaseRestoreFailedBody =>
      'Käufe konnten nicht wiederhergestellt werden. Versuche es erneut.';

  @override
  String get purchaseRecoveredActiveBody => 'Dein Abo ist aktiv.';

  @override
  String get purchaseCompleteTitle => 'Kauf abgeschlossen';

  @override
  String get giftCreateFailedTitle => 'Geschenk konnte nicht erstellt werden';

  @override
  String get giftClaimFailedTitle => 'Geschenk konnte nicht eingelöst werden';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geschenke für dich',
      one: 'Ein Geschenk für dich',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 Monat',
      '12': '1 Jahr',
      'other': '$months Monate',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining übrig',
      one: '1 übrig',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender hat dir $duration FitCheck Pro gesendet. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Ein FitCheck-Pro-Geschenk für $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Von $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Für $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Von $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'dein Empfänger';

  @override
  String get giftPreviewPlaceholderSender => 'du';

  @override
  String get settingsSavedTitle => 'Gespeichert';

  @override
  String get settingsNotSavedTitle => 'Nicht gespeichert';

  @override
  String get settingsAiChooseProviderBody => 'Wähle einen Anbieter.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Ein eigener Anbieter benötigt eine API-URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Gib einen API-Key ein.';

  @override
  String get settingsAiSavedBody =>
      'Deine KI-Einstellungen wurden gespeichert.';

  @override
  String get settingsAiMissingDetailsTitle => 'Fehlende Angaben';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Gib eine API-URL und ein Chatmodell ein, um es zu testen.';

  @override
  String get settingsAiKeyNeededTitle => 'API-Key erforderlich';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Gib deinen API-Key ein, um zu testen. Dein gespeicherter Key bleibt privat.';

  @override
  String get settingsAiKeyToTestBody => 'Gib deinen API-Key ein, um zu testen.';

  @override
  String get settingsAiConnectedTitle => 'Verbunden';

  @override
  String get settingsAiConnectedBody => 'Die Verbindung funktioniert.';

  @override
  String get settingsAiTestFailedTitle => 'Test fehlgeschlagen';

  @override
  String get settingsPreferencesSavedBody =>
      'Deine Einstellungen wurden gespeichert.';

  @override
  String get settingsPasswordNotChangedTitle => 'Passwort nicht geändert';

  @override
  String get settingsOAuthPasswordBody =>
      'Dieses Konto meldet sich mit Google oder Apple an. Verwende „Passwort vergessen“, um zuerst ein Passwort zu vergeben.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Das aktuelle Passwort ist falsch.';

  @override
  String get settingsExportReadyTitle => 'Export bereit';

  @override
  String get settingsExportReadyBody =>
      'Dein Datenexport ist zum Herunterladen bereit.';

  @override
  String get settingsLinkCopiedTitle => 'Link kopiert';

  @override
  String get settingsExportClipboardBody =>
      'Wir konnten deinen Browser nicht öffnen, daher haben wir den Download-Link kopiert. Füge ihn bald in einen Browser ein: Er läuft ab.';

  @override
  String get settingsExportFailedTitle => 'Export fehlgeschlagen';

  @override
  String get settingsAccountNotDeletedTitle => 'Konto nicht gelöscht';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Du kannst bis zu $max Fotos hinzufügen.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Fotolimit';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Füge mindestens ein Foto hinzu.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Keine Fotos';

  @override
  String get photoshootDescribeLookBody =>
      'Beschreibe den Look, den du möchtest.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt erforderlich';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Deine Fotos werden vorbereitet';

  @override
  String get photoshootStatusGenerating => 'Wird generiert';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current von $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done von $total fertig';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generierung fehlgeschlagen.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready bereit, $failed fehlgeschlagen.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Teilweise fertig';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos sind bereit.',
      one: '1 Foto ist bereit.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Verbindung getrennt. Bitte erneut versuchen.';

  @override
  String get photoshootCouldNotCancelTitle => 'Absagen nicht möglich';

  @override
  String get photoshootRetryFailedTitle => 'Neue Versuche fehlgeschlagen';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Foto $number ist bereit.';
  }

  @override
  String get photoshootReplacedTitle => 'Ersetzt';

  @override
  String get photoshootSavedToGalleryBody => 'In deiner Galerie gespeichert.';

  @override
  String get photoshootSavedTitle => 'Gespeichert';

  @override
  String get photoshootNotSavedTitle => 'Nicht gespeichert';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count Fotos sind in deiner Galerie.',
      one: '1 Foto ist in deiner Galerie.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved von $total gespeichert.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Einige Fotos nicht gespeichert';

  @override
  String get tryonConsentFeatureLabel => 'Virtueller Anprobe';

  @override
  String get tryonAvatarUpdatedBody => 'Dein Foto wurde aktualisiert.';

  @override
  String get tryonSavedTitle => 'Gespeichert';

  @override
  String get tryonUploadFailedTitle => 'Upload fehlgeschlagen';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Wähle zuerst ein Kleidungsstück aus.';

  @override
  String get tryonNoGarmentTitle => 'Kein Kleidungsstück';

  @override
  String get tryonWaitForUploadBody => 'Warte, bis dein Foto hochgeladen ist.';

  @override
  String get tryonStillUploadingTitle => 'Lädt noch hoch';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Füge zuerst ein Foto von dir hinzu.';

  @override
  String get tryonReadyBody => 'Deine Anprobe ist bereit.';

  @override
  String get tryonFailedTitle => 'Anprobe fehlgeschlagen';

  @override
  String get tryonSavedToGalleryBody => 'In deiner Galerie gespeichert.';

  @override
  String get tryonNotSavedTitle => 'Nicht gespeichert';

  @override
  String get calendarEventAddedBody => 'Termin hinzugefügt';

  @override
  String get calendarEventPlannedTitle => 'Geplant';

  @override
  String get calendarEventSavedBody => 'Termin gespeichert';

  @override
  String get calendarSavedTitle => 'Gespeichert';

  @override
  String get calendarEventNotSavedTitle => 'Termin nicht gespeichert';

  @override
  String get calendarEventRemovedBody => 'Termin entfernt';

  @override
  String get calendarEventDeletedTitle => 'Gelöscht';

  @override
  String get calendarEventNotDeletedTitle => 'Ereignis nicht gelöscht';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit nicht verknüpft';

  @override
  String get calendarLinkedTitle => 'Verknüpft';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit nicht entfernt';

  @override
  String get calendarOutfitRemovedBody => 'Outfit entfernt';

  @override
  String get calendarDisconnectedBody => 'Kalender getrennt';

  @override
  String get calendarDisconnectedTitle => 'Getrennt';

  @override
  String get calendarNotDisconnectedTitle => 'Kalender nicht getrennt';

  @override
  String get calendarTodayLabel => 'heute';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ereignisse',
      one: '1 Ereignis',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start bis $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, Outfit verknüpft';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" wird entfernt.';
  }

  @override
  String get calendarThisAppLabel => 'Diese App';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synchronisation mit $provider ist noch nicht verfügbar. Du kannst hier weiterhin Ereignisse hinzufügen.';
  }

  @override
  String get calendarWeekdaySunShort => 'So';

  @override
  String get calendarWeekdayMonShort => 'Mo';

  @override
  String get calendarWeekdayTueShort => 'Di';

  @override
  String get calendarWeekdayWedShort => 'Mi';

  @override
  String get calendarWeekdayThuShort => 'Do';

  @override
  String get calendarWeekdayFriShort => 'Fr';

  @override
  String get calendarWeekdaySatShort => 'Sa';

  @override
  String get calendarWeekdayMonday => 'Montag';

  @override
  String get calendarWeekdayTuesday => 'Dienstag';

  @override
  String get calendarWeekdayWednesday => 'Mittwoch';

  @override
  String get calendarWeekdayThursday => 'Donnerstag';

  @override
  String get calendarWeekdayFriday => 'Freitag';

  @override
  String get calendarWeekdaySaturday => 'Samstag';

  @override
  String get calendarWeekdaySunday => 'Sonntag';

  @override
  String get outfitSavedToFavouritesBody => 'Zu Favoriten hinzugefügt';

  @override
  String get outfitRemovedFromFavouritesBody => 'Aus Favoriten entfernt';

  @override
  String get outfitNotSavedTitle => 'Nicht gespeichert';

  @override
  String get outfitLoggedAsWornBody => 'Als heute getragen erfasst.';

  @override
  String get outfitNicePickTitle => 'Gute Auswahl';

  @override
  String get outfitRemovedBody => 'Outfit entfernt.';

  @override
  String get outfitDeletedTitle => 'Gelöscht';

  @override
  String get outfitNotDeletedTitle => 'Nicht gelöscht';

  @override
  String get outfitDuplicatedBody => 'Eine Kopie ist in deinen Outfits.';

  @override
  String get outfitDuplicatedTitle => 'Dupliziert';

  @override
  String get outfitNotDuplicatedTitle => 'Nicht dupliziert';

  @override
  String get outfitNotSharedTitle => 'Nicht geteilt';

  @override
  String outfitCollectionReadyBody(String name) {
    return '„$name“ ist bereit.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Kollektion nicht erstellt';

  @override
  String get outfitCollectionUpdatedBody => 'Kollektion aktualisiert.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Kollektion nicht aktualisiert';

  @override
  String get outfitCollectionDeletedBody => 'Kollektion gelöscht.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Kollektion nicht gelöscht';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Outfits hinzugefügt.',
      one: '1 Outfit hinzugefügt.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits nicht hinzugefügt';

  @override
  String get outfitPreviewNotCreatedTitle => 'Vorschau nicht erstellt';

  @override
  String get outfitGiveNameBody => 'Gib dem Outfit einen Namen.';

  @override
  String get outfitNameMissingTitle => 'Name';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'Wähle mindestens ein Stück aus.';

  @override
  String outfitCreatedBody(String name) {
    return '$name ist in deinen Outfits.';
  }

  @override
  String get outfitSavedTitle => 'Gespeichert';

  @override
  String get wardrobeAddedToFavouritesBody => 'Zu Favoriten hinzugefügt';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Aus Favoriten entfernt';

  @override
  String get wardrobeNotSavedTitle => 'Nicht gespeichert';

  @override
  String get wardrobeLoggedAsWornBody => 'Als heute getragen markiert.';

  @override
  String get wardrobeRemovedFromClosetBody =>
      'Aus deinem Kleiderschrank entfernt.';

  @override
  String get wardrobeDeletedTitle => 'Gelöscht';

  @override
  String get wardrobeNotDeletedTitle => 'Nicht gelöscht';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile aus deinem Kleiderschrank entfernt.',
      one: '1 Teil aus deinem Kleiderschrank entfernt.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'KI-Kleiderschrank-Erkennung';

  @override
  String get itemAddScanJobLabel => 'Scannen';

  @override
  String get itemAddFoundEarlierBody => 'Bei früherem Scan gefunden';

  @override
  String get itemAddLookingAtPhoto => 'Analysiere dein Foto';

  @override
  String get itemAddExtractionFailedBody => 'Erkennung fehlgeschlagen';

  @override
  String get itemAddJobFailedBody => 'Aufgabe fehlgeschlagen';

  @override
  String get itemAddConnectionLostBody =>
      'Verbindung unterbrochen. Bitte erneut versuchen.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Verbindung während der Verarbeitung unterbrochen.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Teil $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Teil';

  @override
  String get itemAddNotCancelledTitle => 'Nicht abgebrochen';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile sind in deinem Kleiderschrank.',
      one: '1 Teil ist in deinem Kleiderschrank.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved von $total Teilen gespeichert. Tippe auf Speichern, um den Rest erneut zu versuchen.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Manche Teile nicht gespeichert';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Wähle mindestens ein Foto aus.';

  @override
  String get batchPhotoUnreadableBody =>
      'Dieses Foto konnte nicht gelesen werden.';

  @override
  String get batchNoPhotosReadableBody =>
      'Keines dieser Fotos konnte gelesen werden. Probiere andere Fotos aus.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '1 Foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Die Verbindung wurde während der Arbeit unterbrochen. Bitte erneut versuchen.';

  @override
  String get batchNotCancelledTitle => 'Nicht abgebrochen';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Beitragslinks werden nicht unterstützt. Gib einen Profil-Link ein.';

  @override
  String get batchLinkSpacesBody => 'Links dürfen keine Leerzeichen enthalten.';

  @override
  String get batchEnterProfileLinkBody =>
      'Gib einen Instagram- oder Facebook-Profil-Link ein.';

  @override
  String get batchEnterProfileLinkShortBody => 'Gib einen Profil-Link ein.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Die Anmeldeseite wurde nicht geöffnet. Bitte erneut versuchen.';

  @override
  String get batchSignInBrowserBody =>
      'Melde dich in deinem Browser an und kehre dann zu FitCheck zurück.';

  @override
  String get batchConnectAccountTitle => 'Konto verknüpfen';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Gib den Code aus deiner Authenticator-App ein.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram verlangt eine Sicherheitsprüfung. Melde dich zuerst in deinem Browser an.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Gib deinen Benutzernamen und dein Passwort erneut ein.';

  @override
  String get batchSignInFailedBody =>
      'Anmeldung fehlgeschlagen. Prüfe Benutzernamen und Passwort.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Melde dich an, um den Import fortzusetzen.';

  @override
  String get batchAccountNotConnectedBody =>
      'Dein Konto wurde nicht verknüpft.';

  @override
  String get batchAccountConnectedTitle => 'Konto verknüpft';

  @override
  String get batchNotConnectedTitle => 'Nicht verknüpft';

  @override
  String get batchImportConnectionLostBody =>
      'Die Verbindung zum Import wurde unterbrochen. Aktualisiere die Ansicht, um zu prüfen.';

  @override
  String batchPickUpToBody(int max) {
    return 'Wähle bis zu $max Fotos aus. Wir finden die Teile.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count von $total Fotos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Foto $done von $count wird vorbereitet';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Teile in $count Fotos finden',
      one: 'Teile in 1 Foto finden',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Dein $platform-Konto verwendet die Zwei-Faktor-Anmeldung. Gib den 6-stelligen Code aus deiner Authenticator-App ein.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Dieses $platform-Profil ist privat oder benötigt eine Anmeldung, um Fotos anzuzeigen.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Verknüpfen mit $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos bisher gefunden',
      one: '1 Foto bisher gefunden',
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
    return '$processed von $total verarbeitet · $added hinzugefügt · $waiting warten · $skipped übersprungen';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Foto $number wird gescannt';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number ist als Nächstes';
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
      other: '$count Teile gefunden',
      one: '1 Teil gefunden',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos wurden in deinen Kleiderschrank hinzugefügt.',
      one: '1 Foto wurde in deinen Kleiderschrank hinzugefügt.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Studio-Fotos sind unterwegs. Du kannst Fertigstellungen speichern oder gehen – wir lassen dich wissen.',
      one:
          '1 Studio-Foto ist unterwegs. Du kannst Fertigstellungen speichern oder gehen – wir lassen dich wissen.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Noch nicht gespeichert: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces Teile',
      one: '1 Teil',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos Fotos',
      one: '1 Foto',
    );
    return '$_temp0 aus $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen ausgewählt. Tippe auf ein Teil, um es zu überspringen.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile werden gespeichert',
      one: '1 Teil wird gespeichert',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teile speichern',
      one: '1 Teil speichern',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Dein Körperprofil ist gespeichert.';

  @override
  String get bodyProfileSavedTitle => 'Gespeichert';

  @override
  String get bodyProfileNotSavedTitle => 'Nicht gespeichert';

  @override
  String get bodyProfileSetDefaultBody => 'Als dein Standardprofil festlegen.';

  @override
  String get bodyProfileDeletedBody => 'Körperprofil gelöscht.';

  @override
  String get bodyProfileDeletedTitle => 'Gelöscht';

  @override
  String get bodyProfileNotDeletedTitle => 'Nicht gelöscht';

  @override
  String get feedbackNotSentTitle => 'Nicht gesendet';

  @override
  String get feedbackSentBody =>
      'Danke. Wir lesen jede Nachricht und antworten, wenn wir mehr brauchen.';

  @override
  String get feedbackSentTitle => 'Feedback gesendet';

  @override
  String get recommendUnnamedPiece => 'Unbenanntes Teil';

  @override
  String get recommendEnterCityBody =>
      'Gib deine Stadt ein, um Vorschläge für das Wetter zu erhalten.';

  @override
  String get recommendWhichCityTitle => 'Welche Stadt?';

  @override
  String get aiConsentSheetTitle => 'Fotos an einen KI-Dienst senden';

  @override
  String get aiConsentSheetBody =>
      'Damit wir deine Anprobe- und Shootings erstellen können, sendet FitCheck AI die von dir bereitgestellten Fotos (einschließlich Bilder deines Gesichts und Körpers) an einen vertrauenswürdigen Drittanbieter für KI (wie OpenAI oder Google Gemini) zur Verarbeitung. Sie generieren deine Bilder und nutzen sie gemäß unseren Bedingungen nicht für das Training ihrer Modelle. Fotos werden sicher übertragen und niemals für Werbung verwendet.';

  @override
  String get aiConsentSheetPermission =>
      'Mit dem Fortfahren erteilst du explizit die Erlaubnis, deine Fotos an diese KI-Anbieter zur Bildgenerierung zu übermitteln.';

  @override
  String get skeletonsLoadMoreFailed => 'Weitere konnten nicht geladen werden.';

  @override
  String get jobsPiecesReadyTitle => 'Deine Teile sind bereit';

  @override
  String get jobsScanStoppedTitle => 'Der Scan wurde gestoppt';

  @override
  String get jobsNothingSavedBody =>
      'Nichts wurde gespeichert. Versuche es erneut.';

  @override
  String get jobsPhotoUploadFailedBody => 'Foto-Upload fehlgeschlagen.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google-Anmeldung konnte nicht gestartet werden. Bitte versuche es erneut.';

  @override
  String get referralAppliedTitle => 'Empfehlung aktiviert!';

  @override
  String get billingStoreUnavailableBody =>
      'Store-Käufe sind auf diesem Gerät nicht verfügbar.';

  @override
  String get billingPurchaseProcessingBody =>
      'Dieser Kauf wird noch verarbeitet. Öffne die App in einer Minute erneut, um deinen Plan zu sehen.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatar-Upload lieferte keine Bild-URL zurück.';

  @override
  String get rewardsDayStreakLabel => 'Tage-Serie';

  @override
  String rewardsBestStreak(int days) {
    return 'Beste $days Tage';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Zugriff auf $permission benötigt';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Der Zugriff auf $permission ist derzeit blockiert. Öffne die Einstellungen, um ihn zu erlauben, und versuche es erneut.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Schritt $step von 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Bild $index entfernen';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Bild $index entfernen';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points Pkt.';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'E-Mail an $email. Wir prüfen Meldungen innerhalb von 24 Stunden.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece entfernen';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '„$name';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'In „$name“ hinzufügen';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '„$name“ wurde entfernt. Die Teile bleiben in deinem Schrank.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Alle $count anzeigen';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count heute übrig';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index fehlgeschlagen';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected von $max Fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape Figur · $tone Hautton';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Optionen für $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Meist getragen: $name, $count mal';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: nicht festgelegt';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% Übereinstimmung';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked von $max ausgewählt';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item entfernen';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency Priorität';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Dieser Plan wird über $store abgerechnet. Verwalte oder kündige ihn in den Konto-Einstellungen von $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'In $store verwalten';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current von $max verwendet';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Noch ca. $seconds Sek.';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done von $total Studiofotos bereit';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready von $total Studiofotos bereit. Tippe auf ein Teil, um es zu überspringen.';
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
  String get profileFieldNotSet => 'Nein';
}
