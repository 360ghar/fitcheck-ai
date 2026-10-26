// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPhotoshoot => 'Fotoshoot';

  @override
  String get tabCloset => 'Kledingkast';

  @override
  String get tabOutfits => 'Outfits';

  @override
  String get tabMore => 'Meer';

  @override
  String get actionAddItem => 'Item toevoegen';

  @override
  String get actionCreateOutfit => 'Outfit maken';

  @override
  String get actionCancel => 'Annuleren';

  @override
  String get actionDelete => 'Verwijderen';

  @override
  String get actionSave => 'Opslaan';

  @override
  String get actionRetry => 'Opnieuw';

  @override
  String get actionDone => 'Klaar';

  @override
  String get actionNext => 'Volgende';

  @override
  String get actionBack => 'Terug';

  @override
  String get actionClose => 'Sluiten';

  @override
  String get actionSearch => 'Zoeken';

  @override
  String get actionContinue => 'Doorgaan';

  @override
  String get stateLoading => 'Laden';

  @override
  String get stateErrorTitle => 'Er ging iets mis';

  @override
  String get stateErrorBody =>
      'Probeer het opnieuw. Neem contact op met support als het blijft mislukken.';

  @override
  String get stateOfflineTitle => 'Je bent offline';

  @override
  String get stateOfflineBody =>
      'Maak verbinding om je kledingkast te synchroniseren en outfits te genereren.';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'Voorkeuren';

  @override
  String get settingsPlanBilling => 'Abonnement en betaling';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsNotifications => 'Meldingen';

  @override
  String get settingsUnits => 'Meeteenheden';

  @override
  String get settingsAppearance => 'Weergave';

  @override
  String get settingsPrivacySection => 'Privacy en gegevens';

  @override
  String get settingsAboutSection => 'Over';

  @override
  String get settingsSignOut => 'Uitloggen';

  @override
  String get settingsDeleteAccount => 'Account verwijderen';

  @override
  String get settingsDeleteAccountTitle => 'Je account verwijderen?';

  @override
  String get settingsDeleteAccountBody =>
      'Dit verwijdert je kledingkast, outfits, foto\'s en profiel. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get settingsUnitsImperial => 'Imperiaal (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrisch (cm, kg)';

  @override
  String get languageTitle => 'Taal';

  @override
  String get languageSystem => 'Gebruik taal van apparaat';

  @override
  String get languageSystemBody => 'FitCheck AI volgt de taal van je telefoon.';

  @override
  String get languageSearchHint => 'Zoek talen';

  @override
  String get languageCurrent => 'Huidig';

  @override
  String get languageReviewNote =>
      'Deze vertaling is nieuw. Laat het ons weten als er iets niet klopt.';

  @override
  String get languageChanged => 'Taal bijgewerkt';

  @override
  String get paywallTitle => 'Kies je abonnement';

  @override
  String get paywallTrialBadge => '1 maand gratis';

  @override
  String get paywallTrialTitle => 'Je eerste maand Pro is gratis';

  @override
  String get paywallTrialBody =>
      'Upload je hele kledingkast in één keer. Voeg daarna gaandeweg items toe.';

  @override
  String get paywallFreeForeverTitle => 'Altijd gratis';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Geen creditcard nodig. Elke maand krijg je $uploads AI-uploads, $outfits outfits en $images fotoshoot-afbeeldingen per dag.';
  }

  @override
  String get paywallCtaTrial => 'Start mijn gratis maand';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Upgrade naar $plan';
  }

  @override
  String get paywallRestore => 'Aankopen herstellen';

  @override
  String get paywallManage => 'Abonnement beheren';

  @override
  String get paywallTerms => 'Gebruiksvoorwaarden';

  @override
  String get paywallPrivacy => 'Privacybeleid';

  @override
  String get paywallPerMonth => 'per maand';

  @override
  String get paywallPerYear => 'per jaar';

  @override
  String get paywallBestValue => 'Beste waarde';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Gratis proefperiode alleen voor nieuwe abonnees. Na de proefperiode wordt Pro verlengd voor $price, tenzij ten minste 24 uur voor afloop geannuleerd.';
  }

  @override
  String get introTitle => 'Je kledingkast, eindelijk georganiseerd';

  @override
  String get introBody =>
      'Fotografeer je kleding één keer. Krijg outfitideeën, pasvoorbeelden en studiofoto\'s van wat je al bezit.';

  @override
  String get introStart => 'Aan de slag';

  @override
  String get introHaveAccount => 'Ik heb al een account';

  @override
  String get introSkip => 'Overslaan';

  @override
  String get authSignIn => 'Inloggen';

  @override
  String get authSignUp => 'Account aanmaken';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Wachtwoord';

  @override
  String get authForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get authContinueApple => 'Ga verder met Apple';

  @override
  String get authContinueGoogle => 'Ga verder met Google';

  @override
  String get authOrDivider => 'of';

  @override
  String get wardrobeTitle => 'Kledingkast';

  @override
  String get wardrobeEmptyTitle => 'Je kledingkast is leeg';

  @override
  String get wardrobeEmptyBody =>
      'Voeg je eerste kledingstuk toe of upload in één keer een foto van je hele kledingrek.';

  @override
  String get wardrobeAddFirst => 'Voeg je eerste item toe';

  @override
  String get wardrobeSearchHint => 'Doorzoek je kledingkast';

  @override
  String get categoryTops => 'Tops';

  @override
  String get categoryBottoms => 'Broeken en rokken';

  @override
  String get categoryShoes => 'Schoenen';

  @override
  String get categoryAccessories => 'Accessoires';

  @override
  String get categoryOuterwear => 'Jassen';

  @override
  String get categorySwimwear => 'Badkleding';

  @override
  String get categoryActivewear => 'Sportkleding';

  @override
  String get categoryOther => 'Overig';

  @override
  String get conditionClean => 'Schoon';

  @override
  String get conditionDirty => 'Vies';

  @override
  String get conditionLaundry => 'In de was';

  @override
  String get conditionRepair => 'Moet gerepareerd';

  @override
  String get conditionDonate => 'Om te doneren';

  @override
  String get seasonSpring => 'Lente';

  @override
  String get seasonSummer => 'Zomer';

  @override
  String get seasonFall => 'Herfst';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonAll => 'Alle seizoenen';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formeel';

  @override
  String get styleBusiness => 'Zakelijk';

  @override
  String get styleSporty => 'Sportief';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalistisch';

  @override
  String get styleRomantic => 'Romantisch';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Klassiek';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Overig';

  @override
  String get occasionWork => 'Werk';

  @override
  String get occasionDateNight => 'Date night';

  @override
  String get occasionTravel => 'Reizen';

  @override
  String get occasionWedding => 'Bruiloft';

  @override
  String get occasionGym => 'Sporten';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Feest';

  @override
  String get occasionInterview => 'Sollicitatie';

  @override
  String get colorBlack => 'Zwart';

  @override
  String get colorWhite => 'Wit';

  @override
  String get colorGrey => 'Grijs';

  @override
  String get colorNavy => 'Marineblauw';

  @override
  String get colorBrown => 'Bruin';

  @override
  String get colorRed => 'Rood';

  @override
  String get colorBlue => 'Blauw';

  @override
  String get colorGreen => 'Groen';

  @override
  String get colorPink => 'Roze';

  @override
  String get colorPurple => 'Paars';

  @override
  String get colorYellow => 'Geel';

  @override
  String get colorOrange => 'Oranje';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Vandaag';

  @override
  String get dateYesterday => 'Gisteren';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen geleden',
      one: '1 dag geleden',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weken geleden',
      one: '1 week geleden',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maanden geleden',
      one: '1 maand geleden',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jaar geleden',
      one: '1 jaar geleden',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Blij met FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Een snelle beoordeling helpt anderen hun stijl te vinden.';

  @override
  String get ratingPromptYes => 'Beoordeel de app';

  @override
  String get ratingPromptNo => 'Niet nu';

  @override
  String get closetNoMatchesTitle => 'Geen items gevonden';

  @override
  String get closetNoMatchesBody =>
      'Probeer minder filters of een andere zoekopdracht.';

  @override
  String get closetClearFilters => 'Wis filters';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Je items laden';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geselecteerd',
      one: '1 geselecteerd',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Verwijder selectie';

  @override
  String get closetCancelSelection => 'Annuleer selectie';

  @override
  String get closetCloseSearch => 'Sluit zoekopdracht';

  @override
  String get closetShowGrid => 'Toon als raster';

  @override
  String get closetShowList => 'Toon als lijst';

  @override
  String get closetShowRows => 'Toon als rij';

  @override
  String get closetStatsTitle => 'Kledingkaststatistieken';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items verwijderen?',
      one: '1 item verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Outfits die deze gebruiken raken deze items kwijt.';

  @override
  String get closetSortBy => 'Sorteer op';

  @override
  String get closetFavourites => 'Favorieten';

  @override
  String get closetFavourite => 'Favoriet';

  @override
  String get closetUnfavourite => 'Verwijder favoriet';

  @override
  String get closetWoreToday => 'Vandaag gedragen';

  @override
  String closetWornTimes(int count) {
    return '$count× gedragen';
  }

  @override
  String get closetCategoryLabel => 'Categorie';

  @override
  String get closetUseCaseLabel => 'Gelegenheid';

  @override
  String get closetAnyUseCase => 'Elke';

  @override
  String get closetOtherUseCase => 'Andere gelegenheid';

  @override
  String get closetOtherUseCaseHint => 'Bijvoorbeeld brunch';

  @override
  String get closetUseUseCase => 'Gebruik deze';

  @override
  String get closetClearAll => 'Wis alles';

  @override
  String get sortNewest => 'Nieuwste eerst';

  @override
  String get sortOldest => 'Oudste eerst';

  @override
  String get sortName => 'Naam (A–Z)';

  @override
  String get sortMostWorn => 'Meest gedragen';

  @override
  String get useCaseInformal => 'Informeel';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Diner';

  @override
  String get useCaseLunch => 'Lunch';

  @override
  String get actionSelect => 'Selecteer';

  @override
  String get actionEdit => 'Bewerk';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sorteer';

  @override
  String get actionAll => 'Alle';

  @override
  String get dashboardStartClosetTitle => 'Begin je garderobe';

  @override
  String get dashboardStartClosetBody =>
      'Fotograaf een paar kledingstukken. Wij taggen ze voor je.';

  @override
  String get dashboardPieces => 'stuks';

  @override
  String get dashboardOutfits => 'outfits';

  @override
  String get dashboardDayStreak => 'dagen op rij';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count deze maand';
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
      other: '$count favorieten',
      one: '1 favoriet',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opgeslagen outfits',
      one: '1 opgeslagen outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Meest gedragen: $name, $count keer';
  }

  @override
  String get setupSkip => 'Setup overslaan';

  @override
  String get setupWhoTitle => 'Wie stylen we?';

  @override
  String get setupWhoBody =>
      'Bepaalt het model voor passessies en fotoshoots. Je kunt dit wijzigen in je profiel.';

  @override
  String get setupStyleTitle => 'Wat draag je het meest?';

  @override
  String get setupStyleBody =>
      'Kies er een paar. Outfit-ideeën beginnen hiermee.';

  @override
  String get setupClosetTitle => 'Voeg je eerste kledingstukken toe.';

  @override
  String get setupClosetBody =>
      'Fotograaf een paar kledingstukken of een stapel. Elk stuk wordt automatisch vrijstaand gemaakt en opgeborgen.';

  @override
  String get setupAddClothes => 'Kleding toevoegen';

  @override
  String get setupStylesLabel => 'Stijlen';

  @override
  String get setupOccasionsLabel => 'Gelegenheden';

  @override
  String get setupSkipStep => 'Overslaan';

  @override
  String get setupLater => 'Later';

  @override
  String get setupSaveError => 'Kon niet worden opgeslagen';

  @override
  String get genderWomen => 'Vrouwen';

  @override
  String get genderMen => 'Mannen';

  @override
  String get genderNonBinary => 'Non-binair';

  @override
  String get genderPreferNotToSay => 'Zeg ik liever niet';

  @override
  String get outfitEmptyTitle => 'Nog geen outfits';

  @override
  String get outfitEmptyBody =>
      'Combineer items uit je garderobe en sla de look op.';

  @override
  String get outfitNoMatchesTitle => 'Geen matching outfits';

  @override
  String get outfitSearchHint => 'Doorzoek je outfits';

  @override
  String get outfitLoading => 'Je outfits laden';

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
  String get outfitFilterMenu => 'Stijl en seizoen';

  @override
  String get outfitCollections => 'Collecties';

  @override
  String get outfitDuplicate => 'Dupliceren';

  @override
  String get outfitDeleteTitle => 'Deze outfit verwijderen?';

  @override
  String get outfitDeleteBody => 'De kledingstukken blijven in je garderobe.';

  @override
  String get outfitDrafts => 'Concepten';

  @override
  String get outfitDraft => 'Concept';

  @override
  String get filterStyle => 'Stijl';

  @override
  String get filterSeason => 'Seizoen';

  @override
  String get itemDetailDeleteTitle => 'Verwijder dit kledingstuk?';

  @override
  String get itemDetailDeleteBody =>
      'Outfits die dit gebruiken raken dit stuk kwijt.';

  @override
  String get itemAddFavourite => 'Voeg toe aan favorieten';

  @override
  String itemSize(String size) {
    return 'Maat $size';
  }

  @override
  String get itemColours => 'Kleuren';

  @override
  String get itemMaterial => 'Materiaal';

  @override
  String get itemPattern => 'Patroon';

  @override
  String get itemUseCases => 'Gelegenheden';

  @override
  String get itemKeptIn => 'Opgeslagen in';

  @override
  String get itemPrice => 'Prijs';

  @override
  String get itemBought => 'Gekocht';

  @override
  String get itemTags => 'Labels';

  @override
  String get itemAdded => 'Toegevoegd';

  @override
  String get itemTimesWornLabel => 'keer gedragen';

  @override
  String get itemLastWornLabel => 'laatst gedragen';

  @override
  String get itemNeverWorn => 'Nooit';

  @override
  String get authEntryBody =>
      'Elk kledingstuk dat je bezit, gestyled door AI. Plan outfits, pas ze aan, fotografeer ze.';

  @override
  String get authCreateCloset => 'Maak je kledingkast';

  @override
  String get authWelcomeBack => 'Welkom terug';

  @override
  String get authSignInBody => 'Log in om je kledingkast te openen.';

  @override
  String get authCreateAccount => 'Maak een account';

  @override
  String get authCreateClosetBody =>
      'Dit kost een minuut. Je eerste items zijn gratis.';

  @override
  String get authName => 'Naam';

  @override
  String get authConfirmPassword => 'Bevestig wachtwoord';

  @override
  String get authReferralCode => 'Verwijzingscode (optioneel)';

  @override
  String get authResetTitle => 'Reset je wachtwoord';

  @override
  String get authResetBody =>
      'We e-mailen je een link om een nieuwe te kiezen.';

  @override
  String get authSendResetLink => 'Stuur resetlink';

  @override
  String get authBackToSignIn => 'Terug naar inloggen';

  @override
  String get authEnterEmail => 'Voer je e-mailadres in';

  @override
  String get authEnterValidEmail => 'Voer een geldig e-mailadres in';

  @override
  String get authEnterPassword => 'Voer je wachtwoord in';

  @override
  String get authPasswordTooShort => 'Minimaal 6 tekens';

  @override
  String get authShowPassword => 'Toon wachtwoord';

  @override
  String get authHidePassword => 'Verberg wachtwoord';

  @override
  String get authNewHere => 'Nieuw hier?';

  @override
  String authConfirmEmail(String email) {
    return 'Bevestig $email voordat je inlogt. Controleer je inbox.';
  }

  @override
  String get authResendEmail => 'Opnieuw verzenden';

  @override
  String get authResendingEmail => 'Verzenden…';

  @override
  String get authPasswordsDoNotMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get authEnterName => 'Vul je naam in';

  @override
  String get authChoosePassword => 'Kies een wachtwoord';

  @override
  String get authHaveAccount => 'Heb je al een account?';

  @override
  String get authCodeAccepted => 'Code geaccepteerd';

  @override
  String get authCodeNotFound => 'Code niet gevonden';

  @override
  String authReferralFrom(String name) {
    return 'Van $name. Jullie krijgen beiden een maand gratis.';
  }

  @override
  String get authReferralInvalid => 'We konden deze code niet vinden.';

  @override
  String authResetSent(String email) {
    return 'Verzonden naar $email. Open de link op deze telefoon.';
  }

  @override
  String get introSlide1Title => 'Fotografeer je kast in één keer.';

  @override
  String get introSlide1Body =>
      'Fotografeer een stapel kleding. Elk item wordt automatisch vrijstaand gemaakt en opgeslagen.';

  @override
  String get introSlide2Title => 'Sneller aangekleed.';

  @override
  String get introSlide2Body =>
      'Outfits gemaakt van je eigen kleding, afgestemd op je plannen en het weer.';

  @override
  String get introSlide3Title => 'Zie het voor je het draagt.';

  @override
  String get introSlide3Body =>
      'Pas looks op je eigen foto of schiet ze als een campagne.';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get settingsThemeSystem => 'Systeem';

  @override
  String get settingsThemeLight => 'Licht';

  @override
  String get settingsThemeDark => 'Donker';

  @override
  String get settingsTemperature => 'Temperatuur';

  @override
  String get settingsEmailUpdates => 'E-mailupdates';

  @override
  String get settingsEmailUpdatesBody => 'Nieuws en tips per e-mail';

  @override
  String get settingsOutfitReminders => 'Outfitmeldingen';

  @override
  String get settingsOutfitRemindersBody =>
      'Een herinnering om je outfit te loggen';

  @override
  String get settingsWeeklySummary => 'Wekelijks overzicht';

  @override
  String get settingsWeeklySummaryBody => 'Jouw week in outfits';

  @override
  String get settingsStyleSection => 'Stijl';

  @override
  String get settingsPreferredStyles => 'Stijlen die je leuk vindt';

  @override
  String get settingsPreferredColours => 'Kleuren die je leuk vindt';

  @override
  String get settingsNoneChosen => 'Geen gekozen';

  @override
  String get settingsPlanAiSection => 'Abonnement en AI';

  @override
  String get settingsPlanBillingBody => 'Abonnement, verbruik en upgrades';

  @override
  String get settingsPlanUsageBody => 'Abonnement en verbruik';

  @override
  String get settingsInviteFriends => 'Nodig vrienden uit';

  @override
  String get settingsInviteFriendsBody =>
      'Een gratis maand voor elke vriend die meedoet';

  @override
  String get settingsAiProvider => 'AI-provider';

  @override
  String get settingsAiProviderBody =>
      'Gebruik je eigen model voor labels en afbeeldingen';

  @override
  String get settingsAppVersion => 'App-versie';

  @override
  String get settingsPrivacyTerms => 'Privacy en voorwaarden';

  @override
  String get settingsReportProblem => 'Meld een probleem';

  @override
  String get settingsChangePassword => 'Wachtwoord wijzigen';

  @override
  String get settingsExportData => 'Exporteer je gegevens';

  @override
  String get settingsExportBody =>
      'We maken een bestand klaar met alles wat je hebt opgeslagen en starten de download.';

  @override
  String get settingsExportAction => 'Exporteren';

  @override
  String get settingsCurrentPassword => 'Huidig wachtwoord';

  @override
  String get settingsNewPassword => 'Nieuw wachtwoord';

  @override
  String get settingsConfirmNewPassword => 'Bevestig nieuw wachtwoord';

  @override
  String get settingsEnterCurrentPassword => 'Voer je huidige wachtwoord in';

  @override
  String get settingsEnterNewPassword => 'Voer een nieuw wachtwoord in';

  @override
  String get settingsPasswordMin8 => 'Gebruik minimaal 8 tekens';

  @override
  String get settingsPasswordNeedsUpper => 'Voeg een hoofdletter toe';

  @override
  String get settingsPasswordNeedsLower => 'Voeg een kleine letter toe';

  @override
  String get settingsPasswordNeedsDigit => 'Voeg een cijfer toe';

  @override
  String get settingsPasswordsNoMatch => 'De wachtwoorden komen niet overeen';

  @override
  String get settingsChangeAction => 'Wijzigen';

  @override
  String get itemAddSnapTitle => 'Fotografeer een item';

  @override
  String get itemAddSnapBody =>
      'We herkennen elk item op de foto en maken er een strakke studiocuoto van.';

  @override
  String get itemAddCamera => 'Maak een foto';

  @override
  String get itemAddGallery => 'Kies uit galerij';

  @override
  String get itemAddOtherWays => 'Andere toevoegmethodes';

  @override
  String get itemAddSeveral => 'Meerdere foto\'s toevoegen';

  @override
  String get itemAddSeveralBody => 'Maximaal 50 tegelijk';

  @override
  String get itemAddImportProfile => 'Importeer van een profiel';

  @override
  String get itemAddImportProfileBody => 'Instagram of Facebook';

  @override
  String get itemAddEnterDetails => 'Zelf details invoeren';

  @override
  String get itemAddEnterDetailsBody => 'Geen foto nodig';

  @override
  String get itemManualIntro =>
      'Alleen een naam is vereist. Vul de rest nu of later aan.';

  @override
  String get itemManualNameHint => 'Bijvoorbeeld blauw katoenen t-shirt';

  @override
  String get itemManualEnterName => 'Voer een naam in';

  @override
  String get itemManualNotes => 'Notities';

  @override
  String get itemManualBrand => 'Merk';

  @override
  String get itemManualSize => 'Maat';

  @override
  String get itemManualEnterNumber => 'Voer een getal in';

  @override
  String get itemManualSavePiece => 'Item opslaan';

  @override
  String get itemManualSaving => 'Opslaan';

  @override
  String get itemManualSavedTitle => 'Opgeslagen';

  @override
  String itemManualSavedBody(String name) {
    return '$name staat in je garderobe.';
  }

  @override
  String get itemManualNotSaved => 'Niet opgeslagen';

  @override
  String get itemManualAddUseCase => 'Voeg gebruikssituatie toe';

  @override
  String get itemManualAddUseCaseAction => 'Gebruikssituatie toevoegen';

  @override
  String get itemPhotos => 'Foto\'s';

  @override
  String get itemAddPhotos => 'Foto\'s toevoegen';

  @override
  String get itemNoPhotoYet => 'Nog geen foto. Je kunt opslaan zonder foto.';

  @override
  String get itemRemovePhoto => 'Verwijder foto';

  @override
  String get itemRemovePiece => 'Verwijder item';

  @override
  String get filterConditionLabel => 'Staat';

  @override
  String get photoshootStepPhotos => 'Foto\'s';

  @override
  String get photoshootStepSetup => 'Instellingen';

  @override
  String get photoshootStepCreating => 'Genereren';

  @override
  String get photoshootStepResults => 'Resultaten';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Stap $current van $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Één foto mislukt. Probeer het hieronder opnieuw.';

  @override
  String photoshootManyFailed(int count) {
    return '$count foto\'s mislukt. Probeer ze hieronder opnieuw.';
  }

  @override
  String get photoshootFormat => 'Formaat';

  @override
  String get photoshootHowMany => 'Hoeveel';

  @override
  String get photoshootYourPrompt => 'Je prompt';

  @override
  String get photoshootPromptHint => 'Gouden uur op een dak, linnen shirt';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Maak $count foto\'s',
      one: 'Maak 1 foto',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'foto\'s',
      one: 'foto',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'We konden de limiet van vandaag niet controleren.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan plan: $remaining van $limit over vandaag';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratis';

  @override
  String get photoshootGallery => 'Galerij';

  @override
  String get photoshootUseCamera => 'Gebruik camera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Verwijder foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Geen foto\'s ontvangen';

  @override
  String get photoshootNoPhotosBody =>
      'De fotoshoot is voltooid zonder afbeeldingen. Probeer het opnieuw.';

  @override
  String get photoshootNewStyle => 'Nieuwe stijl';

  @override
  String get photoshootNewPhotos => 'Nieuwe foto\'s';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Open foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Rapporteer foto';

  @override
  String get photoshootSaveToGallery => 'Opslaan in galerij';

  @override
  String get actionUpgrade => 'Upgrade';

  @override
  String get referralLimitTitle => 'Je hebt de foto\'s van vandaag op';

  @override
  String get referralLimitBody =>
      'Je gratis foto\'s zijn morgen weer terug. Nodig een vriend uit en jullie krijgen beiden een maand Pro gratis.';

  @override
  String get referralLimitRefer => 'Nodig een vriend uit';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating-app';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Aesthetic';

  @override
  String get photoshootUseCustom => 'Eigen prompt';

  @override
  String get photoshootDescLinkedin => 'Strakke portretten voor werk';

  @override
  String get photoshootDescDating => 'Ontspannen, warm en natuurlijk';

  @override
  String get photoshootDescPortfolio => 'Editorial, high-fashion looks';

  @override
  String get photoshootDescInstagram => 'Lifestyle-foto\'s voor je feed';

  @override
  String get photoshootDescAesthetic => 'Sfeervolle, artistieke frames';

  @override
  String get photoshootDescCustom => 'Beschrijf de look die je wilt';

  @override
  String get aspectSquare => 'Vierkant';

  @override
  String get aspectPortrait => 'Portret';

  @override
  String get aspectLandscape => 'Landschap';

  @override
  String get aspectTall => 'Lang';

  @override
  String get aspectWide => 'Breed';

  @override
  String get tryOnAppBar => 'Virtueel passen';

  @override
  String get tryOnYourPhoto => 'Jouw foto';

  @override
  String get tryOnGarment => 'Kledingstuk';

  @override
  String get tryOnUploadingPhoto => 'Je foto uploaden';

  @override
  String get tryOnAddPhotoPrompt => 'Voeg een foto van je hele lichaam toe';

  @override
  String get tryOnBodyPhotoHint =>
      'Een foto van je hele lichaam werkt het best';

  @override
  String get tryOnAddPhoto => 'Foto toevoegen';

  @override
  String get tryOnChangePhoto => 'Foto wijzigen';

  @override
  String get tryOnPhotoLoadFailed => 'We konden je foto niet laden.';

  @override
  String get tryOnChooseGarment => 'Kies een kledingfoto';

  @override
  String get tryOnChooseOneGarment => 'Kies één kledingfoto';

  @override
  String get tryOnGarmentHint =>
      'Een platgelegde foto of op een hanger werkt het best';

  @override
  String get tryOnChange => 'Wijzigen';

  @override
  String get tryOnCamera => 'Camera';

  @override
  String get tryOnRemove => 'Verwijderen';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Stijl';

  @override
  String get tryOnBackground => 'Achtergrond';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Je wordt aangekleed. Dit duurt ongeveer een halve minuut.';

  @override
  String get tryOnEmptyResult => 'Je pasresultaat verschijnt hier';

  @override
  String get tryOnReportImage => 'Afbeelding melden';

  @override
  String get tryOnCreating => 'Bezig met maken';

  @override
  String get tryOnTryAgain => 'Opnieuw proberen';

  @override
  String get tryOnCreate => 'Pasvorm maken';

  @override
  String get tryOnBackgroundStudioWhite => 'Studiowit';

  @override
  String get tryOnBackgroundStudioGrey => 'Studiogrijs';

  @override
  String get tryOnBackgroundUrban => 'Stedelijke straat';

  @override
  String get tryOnBackgroundNature => 'Natuur';

  @override
  String get tryOnBackgroundMinimal => 'Minimaal';

  @override
  String get tryOnPoseFront => 'Rechtop voor';

  @override
  String get tryOnPoseSide => 'Rechtop zij';

  @override
  String get tryOnPoseWalking => 'Lopend';

  @override
  String get dashboardGreetingMorning => 'Goedemorgen';

  @override
  String get dashboardGreetingAfternoon => 'Goedemiddag';

  @override
  String get dashboardGreetingEvening => 'Goedenavond';

  @override
  String get dashboardWelcome => 'Welkom';

  @override
  String get dashboardOpenProfile => 'Open profiel';

  @override
  String get dashboardRailToday => 'Vandaag';

  @override
  String get dashboardRailRecently => 'Recent';

  @override
  String get dashboardActivityEmpty =>
      'Nieuwe items en outfits verschijnen hier.';

  @override
  String get quickAddPiece => 'Voeg item toe';

  @override
  String get quickAddPieceBody => 'Fotografeer en tag';

  @override
  String get quickBuildOutfit => 'Stel outfit samen';

  @override
  String get quickBuildOutfitBody => 'Mix je items';

  @override
  String get quickForYou => 'Voor jou';

  @override
  String get quickForYouBody => 'Keuzes voor vandaag';

  @override
  String get quickPlanWeek => 'Plan de week';

  @override
  String get quickPlanWeekBody => 'Outfits per datum';

  @override
  String get referralBannerUrgent => 'Bijna op? Nodig een vriend uit.';

  @override
  String get referralBannerTitle => 'Geef een maand, krijg een maand.';

  @override
  String get referralBannerBody =>
      'Jij en je vriend krijgen beiden een maand Pro.';

  @override
  String get referralBannerDismiss => 'Een week verbergen';

  @override
  String get referralBannerShare => 'Deel uitnodiging';

  @override
  String get referralBannerCopy => 'Kopieer link';

  @override
  String get itemEditPieceTitle => 'Bewerk item';

  @override
  String get itemEditDescriptionLabel => 'Beschrijving';

  @override
  String get itemEditNotSaved => 'Niet opgeslagen';

  @override
  String get itemEditSavedTitle => 'Opgeslagen';

  @override
  String get itemEditSavedBody => 'Je wijzigingen zijn opgeslagen.';

  @override
  String get itemEditSavedStalePhotos =>
      'Opgeslagen — foto\'s zijn mogelijk verouderd';

  @override
  String get itemEditRemovePieceHint => 'Verwijder dit item van de itempagina.';

  @override
  String get itemEditNoPhotos =>
      'Nog geen foto\'s. Voeg er een toe uit je galerij of camera.';

  @override
  String get itemEditKeepPhoto => 'Foto behouden';

  @override
  String get itemEditRemoved => 'Verwijderd';

  @override
  String get itemEditAddUseCaseAction => 'Toevoegen';

  @override
  String get statsNoStatsTitle => 'Nog geen statistieken';

  @override
  String get statsNoStatsBody =>
      'Voeg wat items toe om je kledingmix hier te zien.';

  @override
  String get statsByCategory => 'Per categorie';

  @override
  String get statsTotalValue => 'totale waarde';

  @override
  String get statsMostWorn => 'Meest gedragen';

  @override
  String get statsLeastWorn => 'Wacht op een beurt';

  @override
  String get statsUnnamedPiece => 'Naamloos item';

  @override
  String get jobsTitle => 'Scans';

  @override
  String get jobsEmptyTitle => 'Nog geen scans';

  @override
  String get jobsEmptyBody =>
      'Fotografeer een item en laat het op de achtergrond verwerken — het werkt hier gewoon door.';

  @override
  String get jobsNotCancelled => 'Niet geannuleerd';

  @override
  String get jobsResume => 'Hervatten';

  @override
  String get jobsReview => 'Bekijken';

  @override
  String get jobsStop => 'Stop';

  @override
  String get jobsDismiss => 'Sluiten';

  @override
  String get reportTitle => 'Inhoud rapporteren';

  @override
  String reportIntro(String contentType) {
    return 'Vertel ons wat er mis is met deze $contentType. Ons team beoordeelt elke melding.';
  }

  @override
  String get reportReasonInappropriate => 'Ongepast of aanstootgevend';

  @override
  String get reportReasonNudity => 'Naaktheid of seksuele inhoud';

  @override
  String get reportReasonHarassment => 'Intimidatie of misbruik';

  @override
  String get reportReasonImpersonation => 'Identiteitsfraude';

  @override
  String get reportReasonOther => 'Anders';

  @override
  String get reportDetailsLabel => 'Aanvullende details (optioneel)';

  @override
  String get reportSubmit => 'Melding versturen';

  @override
  String get reportSubmittedTitle => 'Melding verstuurd';

  @override
  String get reportSubmittedBody =>
      'Bedankt. Ons team zal deze inhoud beoordelen.';

  @override
  String get reportFailedTitle => 'Kon melding niet versturen';

  @override
  String get reportFailedBody => 'Probeer het opnieuw.';

  @override
  String get reportContentTryOnImage => 'AI-pasfoto';

  @override
  String get reportContentSharedOutfit => 'gedeelde outfit';

  @override
  String get reportContentPhotoshootImage => 'AI-fotoshoot';

  @override
  String get sharedOutfitTitle => 'Gedeelde outfit';

  @override
  String get sharedOutfitHideTooltip => 'Verberg deze outfit';

  @override
  String get sharedOutfitReportTooltip => 'Rapporteer deze outfit';

  @override
  String get sharedOutfitHideTitle => 'Deze outfit verbergen?';

  @override
  String get sharedOutfitHideBody =>
      'Deze blijft verborgen op dit apparaat. Je kunt hem ook rapporteren zodat ons team hem kan beoordelen en verwijderen.';

  @override
  String get sharedOutfitHideAction => 'Verbergen';

  @override
  String get sharedOutfitHiddenInfo =>
      'Deze outfit wordt niet meer getoond op dit apparaat.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit verborgen';

  @override
  String get sharedOutfitMissingTitle => 'Deze outfit is niet meer beschikbaar';

  @override
  String get sharedOutfitMissingBody =>
      'Mogelijk is deze verwijderd of is de link onjuist.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Je hebt deze outfit verborgen';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Als de inhoud ongepast is, rapporteer dit dan via Privacy en voorwaarden of mail naar $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Deze look leuk?';

  @override
  String get sharedOutfitCtaBody =>
      'Stel soortgelijke outfits samen uit je eigen kledingkast.';

  @override
  String get sharedOutfitCtaButton => 'Download FitCheck AI';

  @override
  String get errorTitle => 'Fout';

  @override
  String get errorUnknown => 'Er is een onverwachte fout opgetreden';

  @override
  String get errorNoConnection =>
      'Geen internetverbinding. Controleer je netwerk.';

  @override
  String get errorTimeout => 'Verzoek verlopen. Probeer het opnieuw.';

  @override
  String get errorServerError =>
      'Er ging iets mis aan onze kant. Probeer het opnieuw.';

  @override
  String get errorBadGateway =>
      'Onze server is tijdelijk onbereikbaar. Probeer het opnieuw.';

  @override
  String get errorServiceUnavailable =>
      'De service is tijdelijk onbereikbaar. Probeer het zo meteen opnieuw.';

  @override
  String get errorInternalError => 'Er is iets misgegaan. Probeer het opnieuw.';

  @override
  String get errorUnauthorized => 'Log in om door te gaan.';

  @override
  String get errorForbidden => 'Je hebt hier geen toegang toe.';

  @override
  String get errorSessionExpired => 'Je sessie is verlopen. Log opnieuw in.';

  @override
  String get errorInvalidCredentials =>
      'Dit e-mailadres of wachtwoord is onjuist.';

  @override
  String get errorTokenRefreshFailed =>
      'We konden je sessie niet vernieuwen. Log opnieuw in.';

  @override
  String get errorRequestCancelled => 'Verzoek geannuleerd.';

  @override
  String get errorInvalidFormat =>
      'Dit bestandsformaat wordt niet ondersteund.';

  @override
  String get errorFileTooLarge => 'Dit bestand is te groot.';

  @override
  String get errorUploadFailed =>
      'Het uploaden is mislukt. Probeer het opnieuw.';

  @override
  String get errorCacheCorrupted =>
      'Opgeslagen gegevens zijn beschadigd en gereset.';

  @override
  String get errorCacheNotFound => 'Er is nog niets opgeslagen.';

  @override
  String get errorUserNotFound => 'We konden dat account niet vinden.';

  @override
  String get errorItemNotFound => 'Dit item bestaat niet meer.';

  @override
  String get errorOutfitNotFound => 'Deze outfit bestaat niet meer.';

  @override
  String get rewardsTitle => 'Beloningen';

  @override
  String get rewardsNoAchievementsTitle => 'Nog geen prestaties';

  @override
  String get rewardsNoAchievementsBody =>
      'Voeg kledingstukken toe en plan outfits om je eerste te verdienen.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Nog niemand op het bord';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plan outfits om punten te verdienen en hier te verschijnen.';

  @override
  String get legalViewPrivacyPolicy => 'Bekijk privacybeleid';

  @override
  String get aiConsentAgree => 'Ga akkoord & ga door';

  @override
  String get aiConsentNotNow => 'Niet nu';

  @override
  String get imageViewerCloseTooltip => 'Afbeelding sluiten';

  @override
  String get updateReadyTitle => 'Update gereed';

  @override
  String get updateReadyBody =>
      'Start FitCheck AI opnieuw op om de nieuwste verbeteringen toe te passen.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI heeft toegang tot de camera nodig om foto\'s van je outfits en kledingstukken te maken.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI heeft toegang tot je fotobibliotheek nodig om foto\'s van je outfits en kledingstukken te selecteren.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI moet door AI gegenereerde outfitfoto\'s kunnen opslaan in je fotobibliotheek.';

  @override
  String get wardrobeSomePhotosSkipped => 'Sommige foto\'s overgeslagen';

  @override
  String get wardrobePhotosNotAdded => 'Foto\'s niet toegevoegd';

  @override
  String get wardrobePhotoNotAdded => 'Foto niet toegevoegd';

  @override
  String get wardrobeNotStartedTitle => 'Niet gestart';

  @override
  String get wardrobeNoRoomTitle => 'Geen ruimte';

  @override
  String get wardrobeAddPhotosSemantic => 'Foto\'s toevoegen';

  @override
  String get batchAddTileLabel => 'Toevoegen';

  @override
  String get batchProfileLinkLabel => 'Profielink';

  @override
  String get wardrobeImportFromProfileTitle => 'Importeren van profiel';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Meerdere foto\'s toevoegen';

  @override
  String get wardrobeClearAction => 'Wis';

  @override
  String get wardrobeRefreshTooltip => 'Vernieuwen';

  @override
  String get batchNoPhotosYetTitle => 'Nog geen foto\'s';

  @override
  String get batchChoosePhotosAction => 'Kies foto\'s';

  @override
  String get batchWeFindEachPieceBody =>
      'We vinden elk kledingstuk en maken er een studiofoto van.';

  @override
  String get batchPreparingPhotosSemantic => 'Foto\'s voorbereiden';

  @override
  String get batchPhotosProcessedSemantic => 'Foto\'s verwerkt';

  @override
  String get batchPasteProfileLinkTitle => 'Plak een profiellink';

  @override
  String get batchPasteProfileLinkBody =>
      'Een openbaar Instagram- of Facebook-profiel. We scannen de foto\'s en jij kiest wat er in je kast komt.';

  @override
  String get batchClearLinkTooltip => 'Link wissen';

  @override
  String get batchStartingButton => 'Starten';

  @override
  String get batchStartImportAction => 'Start import';

  @override
  String get batchReviewEveryPhotoTitle => 'Je beoordeelt elke foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Er wordt niets toegevoegd voordat je het goedkeurt.';

  @override
  String get batchPrivateProfilesTitle => 'Privéprofielen';

  @override
  String get batchPrivateProfilesBody =>
      'Koppel je account. Instagram vraagt ook om een gebruikersnaam en wachtwoord.';

  @override
  String get batchUseAnotherLinkAction => 'Gebruik andere link';

  @override
  String get batchSignInNeededTitle => 'Inloggen vereist';

  @override
  String get batchEnterYourCodeTitle => 'Voer je code in';

  @override
  String get batchUseUsernamePasswordAction =>
      'Gebruik gebruikersnaam en wachtwoord';

  @override
  String get batchAlreadyConnectedAction => 'Ik ben al ingelogd in de browser';

  @override
  String get batchEnterCodeAction => 'Voer code in';

  @override
  String get batchTryAnotherWayAction => 'Probeer een andere manier';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Verbinden opnieuw';

  @override
  String get batchSignInToInstagramTitle => 'Log in bij Instagram';

  @override
  String get batchUsernameLabel => 'Gebruikersnaam';

  @override
  String get batchCodeIfTwoStepLabel => 'Code, bij tweestapsverificatie';

  @override
  String get batchAuthenticatorCodeBody =>
      'Gebruik de 6-cijferige code van je authenticator-app. Codes wisselen snel.';

  @override
  String get batchVerifyAction => 'Verifiëren';

  @override
  String get batchFindingPhotosTitle => 'Foto\'s zoeken';

  @override
  String get batchImportPausedTitle => 'Import gepauzeerd';

  @override
  String get batchProcessingPhotosTitle => 'Foto\'s verwerken';

  @override
  String get batchWaitingNextPhoto => 'Wachten op volgende foto';

  @override
  String get batchCancelImportAction => 'Annuleer import';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Geen kledingstukken gevonden op deze foto.';

  @override
  String get batchEditPieceColoursLabel => 'Kleuren, gescheiden door komma\'s';

  @override
  String get batchAddToClosetAction => 'Voeg toe aan kledingkast';

  @override
  String get batchSkipPhotoAction => 'Sla deze foto over';

  @override
  String get batchImportCompleteTitle => 'Import voltooid';

  @override
  String get batchImportFailedTitle => 'Import mislukt';

  @override
  String get batchImportCancelledTitle => 'Import geannuleerd';

  @override
  String get batchImportErrorBody =>
      'Er is iets misgegaan tijdens het importeren.';

  @override
  String get batchNothingMoreImportedBody =>
      'Er wordt niets meer geïmporteerd van dit profiel.';

  @override
  String get batchViewClosetAction => 'Bekijk kast';

  @override
  String get batchStartOverAction => 'Opnieuw beginnen';

  @override
  String get wardrobeAddPieceTitle => 'Item toevoegen';

  @override
  String get wardrobeAddDetailsTitle => 'Details toevoegen';

  @override
  String get wardrobeScanningTitle => 'Scannen';

  @override
  String get batchReviewPiecesTitle => 'Items beoordelen';

  @override
  String get wardrobeGalleryAction => 'Galerij';

  @override
  String get wardrobeCameraAction => 'Camera';

  @override
  String get wardrobeNewBadge => 'Nieuw';

  @override
  String get wardrobeRemovePhotoTooltip => 'Foto verwijderen';

  @override
  String get batchRunInBackgroundTooltip => 'Op achtergrond uitvoeren';

  @override
  String get batchStepOneOfTwo => 'Stap 1 van 2';

  @override
  String get batchStepTwoOfTwo => 'Stap 2 van 2';

  @override
  String get batchUploadingPhotosTitle => 'Foto\'s uploaden';

  @override
  String get batchFindingPiecesTitle => 'Items zoeken';

  @override
  String get batchMakingStudioPhotosTitle => 'Studiofoto\'s maken';

  @override
  String get batchStoppedLabel => 'Gestopt';

  @override
  String get batchFindingPiecesStoppedTitle => 'Zoeken naar items gestopt';

  @override
  String get batchCancelledLabel => 'Geannuleerd';

  @override
  String get batchAllDoneTitle => 'Klaar';

  @override
  String get batchOpeningPiecesBody => 'Je items worden geopend';

  @override
  String get batchNothingSavedBody => 'Er is niets opgeslagen.';

  @override
  String get batchFindingPiecesFailedBody => 'Zoeken naar items mislukt.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Zoeken naar items vroegtijdig gestopt.';

  @override
  String get batchStopFindingPiecesTitle => 'Zoeken stoppen?';

  @override
  String get batchStopFindingPiecesBody =>
      'De scan stopt en er wordt niets opgeslagen. Al gevonden items blijven in je activiteit staan totdat je ze wegwerkt.';

  @override
  String get batchKeepGoingAction => 'Doorgaan';

  @override
  String get batchTryAgainAction => 'Opnieuw proberen';

  @override
  String get batchBackToPhotosAction => 'Terug naar foto\'s';

  @override
  String get batchSkipAllAction => 'Alles overslaan';

  @override
  String get batchIncludeAllAction => 'Alles opnemen';

  @override
  String get batchNoPiecesFoundTitle => 'Geen kledingstukken gevonden';

  @override
  String get batchNoPiecesFoundBody =>
      'We hebben geen kleding gevonden op deze foto\'s.';

  @override
  String get batchChooseOtherPhotosAction => 'Kies andere foto\'s';

  @override
  String get batchUseCaseHelper =>
      'Toegevoegd aan elk kledingstuk dat je opslaat.';

  @override
  String get batchDiscardPiecesTitle => 'Deze kledingstukken weggooien?';

  @override
  String get batchDiscardPiecesBody => 'Er is niets uit deze batch opgeslagen.';

  @override
  String get batchKeepAction => 'Behouden';

  @override
  String get batchDiscardAction => 'Weggooien';

  @override
  String get batchRemovePieceTitle => 'Dit kledingstuk verwijderen?';

  @override
  String get batchRemovePieceBody => 'Het is niet opgeslagen in je garderobe.';

  @override
  String get batchRemoveAction => 'Verwijderen';

  @override
  String get batchChoosePiecesToSave => 'Kies te bewaren kledingstukken';

  @override
  String get batchDiscardAllAction => 'Alles weggooien';

  @override
  String get batchNothingSavedRetryBody =>
      'Er is niets opgeslagen. Probeer het opnieuw.';

  @override
  String get batchNotSavedTitle => 'Niet opgeslagen';

  @override
  String get batchSavingLabel => 'Opslaan';

  @override
  String get batchSendToBackgroundAction => 'Naar achtergrond';

  @override
  String get batchStillWorkingMessage =>
      'Bezig met verwerken. We laten je weten wanneer je kleding klaar is.';

  @override
  String get batchRunningInBackgroundTitle => 'Bezig op achtergrond';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studiofoto\'s vroegtijdig gestopt. Je kunt deze kledingstukken nog steeds opslaan.';

  @override
  String get batchTapPieceToSkip => 'Tik op een kledingstuk om over te slaan.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studiofoto\'s zijn onderweg. Je kunt weggaan — we geven een seintje.';

  @override
  String get batchLeaveAction => 'Verlaten';

  @override
  String get batchPeopleInPhotosTitle => 'Personen op de foto\'s';

  @override
  String get batchIncludeAction => 'Opnemen';

  @override
  String get batchSkipAction => 'Overslaan';

  @override
  String get batchYourPhotoIsUsedLabel => 'Je foto wordt gebruikt';

  @override
  String get batchMakingStudioPhotoLabel => 'Studiofoto maken';

  @override
  String get batchNoStudioPhotoBody =>
      'Geen studiofoto. Je foto wordt gebruikt.';

  @override
  String get batchEnterDetailsYourselfAction => 'Zelf gegevens invoeren';

  @override
  String get batchChooseAnotherPhotoAction => 'Kies andere foto';

  @override
  String get batchConnectionLostTitle => 'Verbinding verbroken';

  @override
  String get batchConnectionLostBody =>
      'Controleer je verbinding en probeer opnieuw.';

  @override
  String get batchDailyLimitTitle => 'Dagelijkse limiet bereikt';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Upgrade naar Pro voor meer scans of voer de gegevens zelf in.';

  @override
  String get batchDailyLimitBodyFree =>
      'Je scans worden morgen gereset. Je kunt de gegevens nu zelf invoeren.';

  @override
  String get batchSeePlansAction => 'Bekijk abonnementen';

  @override
  String get batchAiBusyTitle => 'Onze AI is het druk';

  @override
  String get batchAiBusyBody =>
      'Dit ligt aan onze kant. Probeer het over een paar minuten opnieuw.';

  @override
  String get batchNoPiecesBody =>
      'Probeer een duidelijkere foto of voer de gegevens zelf in.';

  @override
  String get batchScanningUnavailableTitle => 'Scannen is niet beschikbaar';

  @override
  String get batchScanningUnavailableBody =>
      'Voer de gegevens voorlopig zelf in.';

  @override
  String get batchScanDidNotFinishTitle => 'De scan is niet voltooid';

  @override
  String get batchTryAgainBody => 'Probeer opnieuw.';

  @override
  String get billingTitle => 'Abonnement';

  @override
  String get billingUpgradeHeading => 'Upgrade je abonnement';

  @override
  String get billingUpgradeOnPlusBody => 'Zelfde functies, hogere limieten.';

  @override
  String get billingUpgradeBody =>
      'Plus en Pro hebben dezelfde functies. Kies de limieten die je nodig hebt.';

  @override
  String get billingWebUnavailableBody =>
      'Online updaten is nog niet beschikbaar. Een promo- of verwijzingscode ontgrendelt nog steeds Plus of Pro. Nodig hieronder vrienden uit om gratis maanden te verdienen.';

  @override
  String get billingPlansStale =>
      'Kon de laatste abonnementen niet laden. Prijzen kunnen verouderd zijn.';

  @override
  String get billingMonthly => 'Maandelijks';

  @override
  String get billingYearly => 'Jaarlijks';

  @override
  String get billingCurrentPlan => 'Huidig abonnement';

  @override
  String get billingActive => 'Actief';

  @override
  String get billingThisMonth => 'Deze maand';

  @override
  String get billingItemExtractions => 'Item-extracties';

  @override
  String get billingOutfitVisualizations => 'Outfitvisualisaties';

  @override
  String get billingNearLimitUpgrade =>
      'Je zit bijna aan de limiet van deze maand. Upgrade voor meer.';

  @override
  String get billingNearLimitResets =>
      'Je zit bijna aan de limiet van deze maand. Deze wordt gereset aan het begin van volgende maand.';

  @override
  String get billingStoreUnavailable =>
      'Upgrades zijn nog niet beschikbaar in de winkel. Probeer het later opnieuw.';

  @override
  String get billingManageHeading => 'Beheer je abonnement';

  @override
  String get billingCancelPlan => 'Abonnement opzeggen';

  @override
  String get billingCancelKeepsAccess =>
      'Je houdt toegang tot het einde van deze abonnementsperiode.';

  @override
  String get billingCancelConfirmTitle => 'Abonnement opzeggen?';

  @override
  String get billingKeepPlan => 'Abonnement behouden';

  @override
  String get billingCancelPlanAction => 'Opzeggen';

  @override
  String get billingBilledMonthly => 'Maandelijks gefactureerd';

  @override
  String get billingBilledYearly => 'Jaarlijks gefactureerd';

  @override
  String get billingVirtualTryOn => 'Virtueel passen';

  @override
  String get billingPrioritySupport => 'Prioriteitssupport';

  @override
  String get billingDisclosureProRenewing =>
      'Pro is een automatisch verlopend abonnement';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus en Pro zijn automatisch verlopende abonnementen';

  @override
  String get billingDisclosureAppleBilling =>
      'De betaling wordt bij bevestiging van aankoop in rekening gebracht op je Apple ID.';

  @override
  String get billingDisclosureGoogleBilling =>
      'De betaling wordt bij bevestiging van aankoop in rekening gebracht op je Google Play-account.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Je abonnement wordt automatisch verlengd voor dezelfde periode tegen dezelfde prijs, tenzij je automatische verlenging uiterlijk 24 uur voor het einde van de huidige periode uitschakelt.';

  @override
  String get billingDisclosureAppleManage =>
      'Beheer of zeg op elk moment op via Instellingen › je Apple ID › Abonnementen.';

  @override
  String get billingDisclosureGoogleManage =>
      'Beheer of zeg op elk moment op via Google Play › Betalingen en abonnementen.';

  @override
  String get billingReferFriend => 'Nodig een vriend uit';

  @override
  String get billingHowItWorks => 'Hoe het werkt';

  @override
  String get billingHowShareTitle => 'Deel je link';

  @override
  String get billingHowShareBody => 'Stuur hem naar een vriend.';

  @override
  String get billingHowSignUpTitle => 'Ze registreren zich';

  @override
  String get billingHowSignUpBody => 'Je vriend meldt zich aan via de link.';

  @override
  String get billingHowBothTitle => 'Jullie krijgen allebei Pro';

  @override
  String get billingHowBothBody =>
      'Jullie krijgen beiden een gratis maand Pro.';

  @override
  String get billingYourReferrals => 'Jouw uitnodigingen';

  @override
  String get billingInvited => 'Uitgenodigd';

  @override
  String get billingJoined => 'Deelgenomen';

  @override
  String get billingMonthsEarned => 'Verdiende maanden';

  @override
  String get billingInviteFriend => 'Nodig een vriend uit';

  @override
  String get billingInviteBody =>
      'Jij en je vriend krijgen beiden een maand Pro.';

  @override
  String get billingYourCode => 'Jouw code';

  @override
  String get billingCopyLink => 'Kopieer link';

  @override
  String get billingShareInvite => 'Deel uitnodiging';

  @override
  String get giftUnavailable =>
      'Cadeau-uitnodigingen zijn niet beschikbaar in deze versie.';

  @override
  String get giftPageTitle => 'Geef FitCheck Pro cadeau';

  @override
  String get giftNoAllowances =>
      'Er zijn momenteel geen gratis cadeau-uitnodigingen beschikbaar.';

  @override
  String get giftFormTitle => 'Stuur een gratis uitnodiging';

  @override
  String get giftFormBody =>
      'De ontvanger claimt het cadeau met dit geverifieerde e-mailadres. Wij sturen de e-mail niet voor je.';

  @override
  String get giftFieldFrom => 'Van';

  @override
  String get giftFieldRecipientName => 'Naam ontvanger';

  @override
  String get giftFieldRecipientEmail => 'E-mailadres ontvanger';

  @override
  String get giftFieldOccasion => 'Gelegenheid (optioneel)';

  @override
  String get giftNoOccasion => 'Geen gelegenheid';

  @override
  String get giftOccasionBirthday => 'Verjaardag';

  @override
  String get giftOccasionAnniversary => 'Jubileum';

  @override
  String get giftOccasionOther => 'Anders';

  @override
  String get giftFieldCardGreeting => 'Kaarttekst';

  @override
  String get giftFieldCardGreetingHelper =>
      'Dit verschijnt precies zoals geschreven op de kaart.';

  @override
  String get giftFieldPrivateNote => 'Privénotitie (optioneel)';

  @override
  String get giftCreateAction => 'Maak gratis cadeau';

  @override
  String get giftClaimedTitle => 'Cadeau geclaimd';

  @override
  String get giftClaimedActive => 'Je FitCheck Pro-cadeau is actief.';

  @override
  String get giftClaimedQueued =>
      'Je FitCheck Pro-cadeau start na je huidige toegang.';

  @override
  String get giftLinkCopied => 'Cadeaulink gekopieerd naar klembord.';

  @override
  String get giftErrorName => 'Vul een naam in.';

  @override
  String get giftErrorEmail => 'Vul een geldig e-mailadres in.';

  @override
  String get giftErrorGreeting => 'Vul de kaarttekst in.';

  @override
  String get giftErrorGreetingLength => 'Gebruik maximaal 80 tekens.';

  @override
  String get giftClaimAction => 'Claim cadeau';

  @override
  String get giftCardPreview => 'Kaartvoorbeeld';

  @override
  String get giftGiftForYou => 'Een cadeau voor jou';

  @override
  String get giftGiftWaiting => 'Er wacht een cadeau op jou';

  @override
  String get giftOpenBody =>
      'Open je cadeaus om ze te claimen met je geverifieerde e-mailadres.';

  @override
  String get giftOpenGifts => 'Cadeaus openen';

  @override
  String get giftSendInvitation => 'Verstuur uitnodiging';

  @override
  String get settingsAiProviderSection => 'Provider';

  @override
  String get settingsAiCustom => 'Aangepast';

  @override
  String get settingsAiUrlHelper =>
      'Gebruik een openbare URL die de server kan bereiken. Localhost werkt niet vanaf onze servers.';

  @override
  String get settingsAiConnectionSection => 'Verbinding';

  @override
  String get settingsAiApiUrl => 'API-URL';

  @override
  String get settingsAiApiKey => 'API-sleutel';

  @override
  String get settingsAiApiKeySaved => 'Opgeslagen. Laat leeg om te behouden.';

  @override
  String get settingsAiChatModel => 'Chatmodel';

  @override
  String get settingsAiVisionModel => 'Visueel model (optioneel)';

  @override
  String get settingsAiImageModel => 'Afbeeldingsmodel (optioneel)';

  @override
  String get settingsAiImageModelNote =>
      'Afbeeldingen genereren vereist OpenAI-compatibele chat-completions met response_modalities.';

  @override
  String get settingsAiTestConnection => 'Verbinding testen';

  @override
  String get calendarTitle => 'Agenda';

  @override
  String get calendarGoToToday => 'Naar vandaag';

  @override
  String get calendarConnectTooltip => 'Agenda koppelen';

  @override
  String get calendarAddEvent => 'Evenement toevoegen';

  @override
  String get calendarEmptyTitle => 'Geen plannen';

  @override
  String get calendarEmptyBody =>
      'Voeg een evenement toe en plan wat je aantrekt.';

  @override
  String get calendarPreviousMonth => 'Vorige maand';

  @override
  String get calendarNextMonth => 'Volgende maand';

  @override
  String get calendarAllDay => 'Hele dag';

  @override
  String get calendarOutfitLinked => 'Outfit gekoppeld';

  @override
  String get calendarEventOptions => 'Evenementopties';

  @override
  String get calendarDeleteTitle => 'Verwijder dit evenement?';

  @override
  String get calendarChangeOutfit => 'Outfit wijzigen';

  @override
  String get calendarLinkOutfit => 'Outfit koppelen';

  @override
  String get calendarRemoveOutfit => 'Outfit verwijderen';

  @override
  String get calendarNewEvent => 'Nieuw evenement';

  @override
  String get calendarEditEvent => 'Evenement bewerken';

  @override
  String get calendarTitleLabel => 'Titel';

  @override
  String get calendarTitleRequired => 'Voeg een titel toe';

  @override
  String get calendarEndBeforeStart => 'Eindigt na de starttijd';

  @override
  String get calendarStarts => 'Start';

  @override
  String get calendarEnds => 'Eindigt';

  @override
  String get calendarPlaceOptional => 'Locatie (optioneel)';

  @override
  String get calendarNotesOptional => 'Notities (optioneel)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Stel een outfit samen en koppel deze aan dit evenement.';

  @override
  String get calendarBuildOutfit => 'Outfit samenstellen';

  @override
  String get calendarConnectionsTitle => 'Agenda\'s';

  @override
  String get calendarConnectionsBody =>
      'Evenementen die je hier toevoegt blijven in FitCheck.';

  @override
  String get calendarDisconnect => 'Verbinding verbreken';

  @override
  String get calendarNotAvailable => 'Nog niet beschikbaar';

  @override
  String get profileSectionExplore => 'Ontdekken';

  @override
  String get profileNavTryOn => 'Passen';

  @override
  String get profileNavRewards => 'Beloningen';

  @override
  String get profileSupport => 'Ondersteuning';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileAbout => 'Over';

  @override
  String get profileAboutBody =>
      'Je garderobe, outfits en plannen op één plek.';

  @override
  String get profileSignOutTitle => 'Uitloggen?';

  @override
  String get profileSignOutBody => 'Je kunt op elk moment weer inloggen.';

  @override
  String get profileEditTitle => 'Profiel bewerken';

  @override
  String get profileYourProfile => 'Jouw profiel';

  @override
  String get profileBodyProfiles => 'Lichaamsprofielen';

  @override
  String get profileBodyEmptyTitle => 'Nog geen lichaamsprofielen';

  @override
  String get profileBodyEmptyBody =>
      'Voeg je lengte en bouw toe voor een betere pasvorm.';

  @override
  String get profileBodyAdd => 'Profiel toevoegen';

  @override
  String get profileBodyDefaultNote =>
      'Je standaardprofiel wordt gebruikt voor pasvorm en virtueel passen.';

  @override
  String get profileBodyDefaultBadge => 'Standaard';

  @override
  String get profileBodyMakeDefault => 'Als standaard instellen';

  @override
  String get profileBodyDeleteBody => 'Dit kan niet ongedaan worden gemaakt.';

  @override
  String get profileBodyRequired => 'Verplicht';

  @override
  String get profileBodyCheckNumber => 'Controleer dit getal';

  @override
  String get profileBodyNew => 'Nieuw lichaamsprofiel';

  @override
  String get profileBodyNameHint => 'Bijvoorbeeld: Ik';

  @override
  String get profileBodyHeight => 'Lengte';

  @override
  String get profileBodyWeight => 'Gewicht';

  @override
  String get profileBodyBuild => 'Lichaamsbouw';

  @override
  String get profileBodySkinTone => 'Huidtint';

  @override
  String get profileBirthDateNeededBody =>
      'Voeg een geboortedatum toe bij de geboortetijd.';

  @override
  String get profileBirthDateNeededTitle => 'Geboortedatum vereist';

  @override
  String get profilePartlySavedBody =>
      'We hebben je naam en foto opgeslagen. Geboortegegevens konden niet worden opgeslagen; probeer het later opnieuw.';

  @override
  String get profilePartlySavedTitle => 'Gedeeltelijk opgeslagen';

  @override
  String get profileSavedBody => 'Je profiel is opgeslagen.';

  @override
  String get profileChangePhoto => 'Profielfoto wijzigen';

  @override
  String get profilePhotoLabel => 'Profielfoto';

  @override
  String get profilePhotoHint => 'Tik om een nieuwe te kiezen';

  @override
  String get profileBirthDateLabel => 'Geboortedatum (optioneel)';

  @override
  String get profileBirthTimeLabel => 'Geboortetijd (optioneel)';

  @override
  String get profileBirthTimeHelper => 'Maakt Vedische suggesties nauwkeuriger';

  @override
  String get profileBirthPlaceLabel => 'Geboorteplaats (optioneel)';

  @override
  String get profileBirthPlaceHint => 'Bijvoorbeeld: Amsterdam, Nederland';

  @override
  String get profileHelpContactTitle => 'Stel ons een vraag';

  @override
  String get profileHelpContactBody =>
      'Stuur een bericht en we reageren per e-mail, meestal binnen een dag.';

  @override
  String get profileHelpContactAction => 'Neem contact op';

  @override
  String get profileHelpFaqTitle => 'Veelgestelde vragen';

  @override
  String get profileFaqAddPiecesTitle =>
      'Hoe voeg ik kleding toe aan mijn kast?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tik op Voeg toe in het tabblad Kast. Maak een foto of kies er een uit je galerij; wij herkennen elk item en taggen het voor je.';

  @override
  String get profileFaqMatchingTitle => 'Hoe werkt het combineren van outfits?';

  @override
  String get profileFaqMatchingBody =>
      'Open Voor jou en kies items die je hebt. Wij suggereren wat erbij past en stellen complete outfits samen uit je kast.';

  @override
  String get profileFaqTryOnTitle =>
      'Kan ik mijn eigen foto\'s gebruiken om te passen?';

  @override
  String get profileFaqTryOnBody =>
      'Ja. Voeg een foto van je hele lichaam toe en kies daarna items om te zien hoe ze je staan.';

  @override
  String get profileFaqRewardsTitle => 'Hoe verdien ik beloningen?';

  @override
  String get profileFaqRewardsBody =>
      'Plan en leg outfits regelmatig vast. Je reeks en prestaties groeien vanzelf.';

  @override
  String get profileFaqPrivacyTitle => 'Is mijn kast privé?';

  @override
  String get profileFaqPrivacyBody =>
      'Ja. Je kast en outfits zijn privé, tenzij je een link naar één outfit deelt.';

  @override
  String get profileHelpMoreTitle => 'Meer hulp';

  @override
  String get profileHelpGuides => 'Gidsen';

  @override
  String get profileHelpGuidesBody => 'Hoe elke functie werkt';

  @override
  String get feedbackCategoryBug => 'Er is iets kapot';

  @override
  String get feedbackCategoryIdea => 'Een idee';

  @override
  String get feedbackCategoryGeneral => 'Algemeen';

  @override
  String get feedbackCategoryHelp => 'Ik heb hulp nodig';

  @override
  String get feedbackHintBug =>
      'Wat is er gebeurd en wat verwachtte je? Stappen helpen ons dit op te lossen.';

  @override
  String get feedbackHintIdea => 'Wat zou je willen en waarom?';

  @override
  String get feedbackHintGeneral =>
      'Laat ons je mening weten of stel een vraag.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Je kunt maximaal 5 afbeeldingen toevoegen.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limiet bereikt';

  @override
  String get feedbackImageTooLargeBody =>
      'Kies een afbeelding kleiner dan 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Afbeelding te groot';

  @override
  String get feedbackTitle => 'Stuur feedback';

  @override
  String get feedbackAboutLabel => 'Waar gaat het over?';

  @override
  String get feedbackSubjectLabel => 'Onderwerp';

  @override
  String get feedbackSubjectRequired => 'Voeg een onderwerp toe';

  @override
  String get feedbackSubjectTooShort => 'Onderwerp moet minimaal 3 tekens zijn';

  @override
  String get feedbackDetailsLabel => 'Details';

  @override
  String get feedbackDetailsRequired => 'Voeg wat details toe';

  @override
  String get feedbackDetailsTooShort =>
      'Beschrijving moet minimaal 10 tekens zijn';

  @override
  String get feedbackAddScreenshot => 'Voeg een screenshot toe';

  @override
  String get feedbackAttachmentHint => 'Maximaal 5, elk 5 MB';

  @override
  String get feedbackSend => 'Verstuur';

  @override
  String get feedbackEmptyTitle => 'Nog niets verzonden';

  @override
  String get feedbackEmptyBody =>
      'Wat je verzendt verschijnt hier met de status.';

  @override
  String get feedbackHistoryTitle => 'Wat je hebt verzonden';

  @override
  String get feedbackStatusOpen => 'Open';

  @override
  String get feedbackStatusInProgress => 'In behandeling';

  @override
  String get feedbackStatusResolved => 'Opgelost';

  @override
  String get feedbackStatusClosed => 'Gesloten';

  @override
  String get legalIntro =>
      'Hoe we je gegevens beschermen en de voorwaarden voor het gebruik van FitCheck AI.';

  @override
  String get legalPolicies => 'Beleid';

  @override
  String get legalPrivacySubtitle => 'Wat we verzamelen en waarom';

  @override
  String get legalTermsTitle => 'Servicevoorwaarden';

  @override
  String get legalTermsSubtitle => 'De regels voor het gebruik van de app';

  @override
  String get legalLicences => 'Open-source licenties';

  @override
  String get legalSupportSubtitle => 'Hulp, contact en privacyverzoeken';

  @override
  String get legalReportAbuse => 'Meld een probleem of misbruik';

  @override
  String get permissionCameraTitle => 'Cameratoegang';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI gebruikt je camera om foto\'s van je kleding en outfits te maken voor AI-passen en je garderobe.';

  @override
  String get permissionPhotoTitle => 'Toegang tot foto\'s';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI heeft toegang tot je foto\'s nodig zodat je kleding- en outfitafbeeldingen kunt selecteren voor AI-functies en je garderobe.';

  @override
  String get permissionNotNow => 'Niet nu';

  @override
  String get permissionOpenSettings => 'Open instellingen';

  @override
  String authSignedInAs(String name) {
    return 'Ingelogd als $name';
  }

  @override
  String get authSignedIn => 'Ingelogd';

  @override
  String get authWelcomeBackTitle => 'Welkom terug';

  @override
  String get authSignInFailed => 'Inloggen mislukt';

  @override
  String get authWelcomeTitle => 'Welkom';

  @override
  String get authSignUpFailed => 'Registreren mislukt';

  @override
  String get authGoogleSignInFailed => 'Inloggen met Google mislukt';

  @override
  String get authAppleSignInFailed => 'Inloggen met Apple mislukt';

  @override
  String get authConfirmEmailTitle => 'Bevestig je e-mailadres';

  @override
  String get authConfirmEmailBody =>
      'Controleer je inbox voor een bevestigingsmail en log daarna in.';

  @override
  String get authClosetReady => 'Je garderobe is klaar.';

  @override
  String get authSignedOutTitle => 'Uitgelogd';

  @override
  String get authSignedOutBody => 'Je bent uitgelogd.';

  @override
  String get authSignOutFailed => 'Uitloggen mislukt';

  @override
  String get authEmailSentTitle => 'E-mail verzonden';

  @override
  String get authResetLinkSent => 'Controleer je e-mail voor een herstellink.';

  @override
  String get authPasswordUpdatedTitle => 'Wachtwoord bijgewerkt';

  @override
  String get authPasswordUpdated => 'Je wachtwoord is bijgewerkt.';

  @override
  String get authPasswordNotUpdated => 'Wachtwoord niet bijgewerkt';

  @override
  String get authCouldNotSendEmail => 'Kan e-mail niet verzenden';

  @override
  String get authEmailNotSent => 'E-mail niet verzonden';

  @override
  String get authResendSentBody =>
      'We hebben een nieuwe bevestigingsmail verzonden.';

  @override
  String get outfitPreviewWithAi => 'Voorbeeld met AI';

  @override
  String get outfitNewPreview => 'Nieuw voorbeeld maken';

  @override
  String get outfitBuilderClosetHeading => 'Je kledingkast';

  @override
  String get outfitBuilderSearchHint => 'Zoek kledingstukken';

  @override
  String get outfitClearSearch => 'Zoekopdracht wissen';

  @override
  String get outfitBuilderAddPiecesTitle => 'Voeg eerst kledingstukken toe';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits worden gemaakt van de stukken in je kledingkast.';

  @override
  String get outfitBuilderNoMatches => 'Geen overeenkomende stukken.';

  @override
  String get outfitNameLabel => 'Naam outfit';

  @override
  String get outfitNameHint => 'Bijv. Weekend linen';

  @override
  String get outfitPreviewSemantic => 'AI-voorbeeld van het outfit';

  @override
  String get outfitChoosePieces => 'Kies kledingstukken';

  @override
  String get outfitTapPiecesHint =>
      'Tik op de stukken hieronder om ze toe te voegen.';

  @override
  String get outfitShareTooltip => 'Deel';

  @override
  String get outfitSaveFavourite => 'Sla op in favorieten';

  @override
  String get outfitPiecesHeading => 'Kledingstukken';

  @override
  String get outfitWearHistoryEmpty =>
      'Draag het een keer en de datums verschijnen hier.';

  @override
  String get outfitWearHistoryTitle => 'Draging';

  @override
  String get outfitWearHistoryError => 'Datums konden niet worden geladen.';

  @override
  String get outfitWornOn => 'Gedragen op';

  @override
  String get outfitEditTitle => 'Outfit bewerken';

  @override
  String get outfitSavedPhotosFailed => 'Details opgeslagen, geen foto\'s';

  @override
  String get outfitNoPhotosBody =>
      'Nog geen foto\'s. Het outfit toont in plaats daarvan de kledingstukken.';

  @override
  String get outfitOccasionLabel => 'Gelegenheid';

  @override
  String get outfitOccasionNone => 'Geen';

  @override
  String get outfitTagsHint => 'Scheiding met komma\'s';

  @override
  String get outfitDraftBody => 'Verborgen voor je hoofdlIJst';

  @override
  String get outfitPublic => 'Openbaar';

  @override
  String get outfitPublicBody => 'Iedereen met de link kan het zien';

  @override
  String get outfitDeleteFromDetail =>
      'Verwijder dit outfit van de detailpagina.';

  @override
  String get outfitNewCollection => 'Nieuwe collectie';

  @override
  String get outfitNoCollectionsTitle => 'Nog geen collecties';

  @override
  String get outfitNoCollectionsBody =>
      'Gropeer looks op reis, seizoen of mood.';

  @override
  String get outfitCreateCollection => 'Collectie maken';

  @override
  String get outfitAddOutfits => 'Looks toevoegen';

  @override
  String get outfitRename => 'Hernoemen';

  @override
  String get outfitCollectionDeleteBody => 'De looks worden behouden.';

  @override
  String get outfitCollectionsNotLoaded => 'Looks niet geladen';

  @override
  String get outfitRenameCollection => 'Collectie hernoemen';

  @override
  String get outfitDescriptionOptional => 'Omschrijving (optioneel)';

  @override
  String get outfitAllInCollection => 'Alle looks staan al in deze collectie.';

  @override
  String get photoshootSubtitleUpload => 'Studiobronzen uit eigen foto\'s';

  @override
  String get photoshootSubtitleConfigure => 'Kies stijl, formaat en aantal';

  @override
  String get photoshootSubtitleGenerating => 'Dit duurt een paar minuten';

  @override
  String get photoshootAddPhotosSemantic => 'Foto\'s toevoegen uit je galerij';

  @override
  String get photoshootUploadTitle => 'Voeg 1 tot 4 foto\'s van jezelf toe';

  @override
  String get photoshootUploadBody => 'Tik om te kiezen uit je galerij';

  @override
  String get photoshootAddToContinue => 'Voeg een foto toe om door te gaan';

  @override
  String get photoshootAddAnotherPhoto => 'Nog een foto toevoegen';

  @override
  String get photoshootTipsTitle => 'Voor de beste resultaten';

  @override
  String get photoshootTipsBody =>
      'Gebruik heldere, goed belichte foto\'s van je gezicht vanuit een paar hoeken. Geen zonnebril of hoeden.';

  @override
  String get photoshootStarting => 'Bezig met starten';

  @override
  String get photoshootCancelling => 'Bezig met annuleren';

  @override
  String get photoshootFailed => 'Mislukt';

  @override
  String get recommendTabMatches => 'Match';

  @override
  String get recommendTabComplete => 'Vervolledig';

  @override
  String get recommendTabWeather => 'Weer';

  @override
  String get recommendTabColours => 'Kleuren';

  @override
  String get recommendTabShop => 'Shop';

  @override
  String get recommendNoMatchesTitle => 'Nog geen matches';

  @override
  String get recommendNoMatchesBody =>
      'Kies een item en we vinden wat goed past.';

  @override
  String get recommendPickPiece => 'Kies een item';

  @override
  String get recommendNothingMatchesTitle => 'Nog niets past hierbij';

  @override
  String get recommendNothingMatchesBody =>
      'Probeer andere items of voeg meer toe aan je kledingkast.';

  @override
  String get recommendChangePieces => 'Wissel items';

  @override
  String get recommendDefaultReason => 'Het past bij de gekozen items.';

  @override
  String get recommendCompleteTitle => 'Maak een look compleet';

  @override
  String get recommendCompleteBody =>
      'Kies een item en wij vullen de rest aan.';

  @override
  String get recommendWorking => 'Bezig';

  @override
  String get recommendGenerate => 'Genereer';

  @override
  String get recommendChooseStyleBody => 'Kies een stijl en genereer dan.';

  @override
  String get recommendNoLooksTitle => 'Geen looks voor deze items';

  @override
  String get recommendNoLooksBody =>
      'Probeer een andere stijl of andere items.';

  @override
  String get recommendDefaultLook => 'Een look voor je items';

  @override
  String get recommendNoPiecesBody => 'Geen items voor deze look gevonden.';

  @override
  String get recommendCityLabel => 'Stad';

  @override
  String get recommendCheck => 'Check';

  @override
  String get recommendWeatherTitle => 'Wat is het weer?';

  @override
  String get recommendWeatherBody =>
      'Geef je stad op voor ideeën voor vandaag.';

  @override
  String get recommendWearToday => 'Wear vandaag';

  @override
  String get recommendWeatherNoPieces =>
      'Nog geen items in je kledingkast voor dit weer.';

  @override
  String get recommendBudgetLabel => 'Budget tot';

  @override
  String get recommendLooking => 'Kijkend';

  @override
  String get recommendFindWhatToBuy => 'Vind wat om te kopen';

  @override
  String get recommendFillGapsTitle => 'Vul de gaten';

  @override
  String get recommendFillGapsBody =>
      'Stel een budget in en wij suggereerden wat je kast mist.';

  @override
  String get recommendNoGapsTitle => 'Geen gaten gevonden';

  @override
  String get recommendNoGapsBody =>
      'Probeer een hoger budget of een andere categorie.';

  @override
  String get recommendMoodEveryday => 'Dagelijks';

  @override
  String get recommendMoodBigMeeting => 'Grootse vergadering';

  @override
  String get recommendDayLabel => 'Dag';

  @override
  String get recommendReadingStars => 'Sterren lezen';

  @override
  String get recommendGetMyColours => 'Mijn kleuren';

  @override
  String get recommendLuckyColoursTitle => 'Je gelukskleuren';

  @override
  String get recommendLuckyColoursBody =>
      'Kies een dag en wij adviseren kleuren en kledingstukken.';

  @override
  String get recommendLuckyColoursSection => 'Gelukskleuren';

  @override
  String get recommendAvoidColoursSection => 'Kleuren om te vermijden';

  @override
  String get recommendBirthDateTitle => 'Vul geboortedatum in';

  @override
  String get recommendBirthDateBody =>
      'We hebben je geboortedatum nodig voor kleuranalyse.';

  @override
  String get recommendEditProfile => 'Profiel bewerken';

  @override
  String get recommendNothingThisDay => 'Niets voor deze dag.';

  @override
  String get recommendUnnamedColour => 'Onbekende kleur';

  @override
  String get recommendFromCloset => 'Uit je kledingkast';

  @override
  String get recommendNoPiecesInColours => 'Nog geen items in deze kleuren.';

  @override
  String get recommendOutfitIdeas => 'Outfit-ideeën';

  @override
  String get recommendNoOutfitsInColours =>
      'Nog geen complete outfit in deze kleuren.';

  @override
  String get recommendDefaultOutfitIdea => 'Een outfitidee';

  @override
  String get recommendPickUpToThree => 'Kies tot drie items';

  @override
  String get recommendEmptyClosetBody =>
      'Voeg eerst wat items toe voor combinaties.';

  @override
  String get dashboardDressForDay => 'Kleed je voor de dag van morgen.';

  @override
  String get dashboardOutfitOfDay => 'Outfit van de dag';

  @override
  String get dashboardFreshLook => 'Frisse look';

  @override
  String get subscriptionManageInStoreTitle => 'Beheer in de winkel';

  @override
  String get subscriptionManageInStoreBody =>
      'Dit abonnement loopt via de winkel. Beheer het in je winkelaccount.';

  @override
  String get subscriptionCancelledTitle => 'Abonnement opgezegd';

  @override
  String get subscriptionCancelledBody =>
      'Je plan blijft geldig tot het einde van de betaalcycli.';

  @override
  String get subscriptionCancelFailedTitle => 'Opzeggen gelukt niet';

  @override
  String get subscriptionCouldNotOpenTitle => 'Kan niet openen';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Beheer van betalingen kan niet geopend worden.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Link kan niet geopend worden.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Kort niet geladen';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Kort niet geladen. Probeer opnieuw.';

  @override
  String get subscriptionReferralCopiedTitle => 'Gekopieerd';

  @override
  String get subscriptionReferralCopiedBody => 'Kort gekopieerd.';

  @override
  String get subscriptionReferralShareSubject => 'Probeer FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Word lid van FitCheck AI, dan krijgen we beide een maand Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link gekopieerd';

  @override
  String get subscriptionShareUnavailableBody =>
      'Delen is niet beschikbaar, dus we hebben de link gekopieerd.';

  @override
  String get subscriptionShareFailedTitle => 'Knik niet gedeeld';

  @override
  String get subscriptionShareFailedBody =>
      'Kopieer de link van de kortingspagina.';

  @override
  String get subscriptionStoreReadyTitle => 'Winkel klaar';

  @override
  String get subscriptionStoreReadyBody =>
      'Winkelkosten beschikbaar. Upgraden kan nu.';

  @override
  String get purchaseFailedTitle => 'Aankoop mislukt';

  @override
  String get purchaseUnavailableTitle => 'Aankoop onbeschikbaar';

  @override
  String get purchaseIapUnavailableBody =>
      'In-app aankopen niet beschikbaar op dit apparaat.';

  @override
  String get purchasePlanNotAvailableBody => 'Dit plan is nog niet te koop.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Dit plan is nog niet in de winkel. Kijk straks weer.';

  @override
  String get purchaseStartFailedBody =>
      'Aankoop niet gestart. Probeer opnieuw.';

  @override
  String get purchaseNoPaymentLinkBody => 'Niet betaallink teruggegeven.';

  @override
  String get purchasePendingTitle => 'Aankoop wachtende';

  @override
  String get purchasePendingBody =>
      'Aankoop wacht goedkeuring. Toegang volgt spoedig.';

  @override
  String get purchaseFailedBody => 'Aankoop mislukt. Probeer opnieuw.';

  @override
  String get purchaseRestoredTitle => 'Hersteld';

  @override
  String get purchaseRestoredBody => 'Aankopen hersteld.';

  @override
  String get purchaseActiveTitle => 'Abonnement actief';

  @override
  String get purchaseActiveBody => 'Abonnement actief. Welkom.';

  @override
  String get purchaseSignInRequiredTitle => 'Inloggen vereist';

  @override
  String get purchaseSignInRequiredBody => 'Log in om aankoop te voltooien.';

  @override
  String get purchaseErrorTitle => 'Aankoopfout';

  @override
  String get purchaseInvalidTransactionBody =>
      'Geen controleerbaar transactie-ID.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificatie hangt';

  @override
  String get purchaseVerificationPendingBody =>
      'We kunnen je aankoop nu niet met de winkel verifiëren. Dit gebeurt automatisch en je wordt niet twee keer in rekening gebracht.';

  @override
  String get purchaseNotAppliedTitle => 'Aankoop niet verwerkt';

  @override
  String get purchaseNotAppliedBody =>
      'Je aankoop kon niet aan je account worden gekoppeld. Neem contact op met ondersteuning en koop het niet opnieuw.';

  @override
  String get purchaseRestoreFailedTitle => 'Herstel mislukt';

  @override
  String get purchaseRestoreFailedBody =>
      'Aankopen konden niet worden hersteld. Probeer het opnieuw.';

  @override
  String get purchaseRecoveredActiveBody => 'Je abonnement is actief.';

  @override
  String get purchaseCompleteTitle => 'Aankoop voltooid';

  @override
  String get giftCreateFailedTitle => 'Cadeau niet aangemaakt';

  @override
  String get giftClaimFailedTitle => 'Cadeau niet afgeroepen';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cadeaus voor jou',
      one: 'Een cadeau voor jou',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 maand',
      '12': '1 jaar',
      'other': '$months maanden',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining over',
      one: '1 over',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration van FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender stuurde je $duration van FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Een FitCheck Pro cadeau voor $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Van $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Voor $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Van $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'ontvanger';

  @override
  String get giftPreviewPlaceholderSender => 'je';

  @override
  String get settingsSavedTitle => 'Opgeslagen';

  @override
  String get settingsNotSavedTitle => 'Niet opgeslagen';

  @override
  String get settingsAiChooseProviderBody => 'Kies een aanbieder.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Een eigen aanbieder heeft een API-URL nodig.';

  @override
  String get settingsAiKeyRequiredBody => 'Voer een API-sleutel in.';

  @override
  String get settingsAiSavedBody => 'Jouw AI-instellingen zijn opgeslagen.';

  @override
  String get settingsAiMissingDetailsTitle => 'Ontbrekende gegevens';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Voer een API-URL en een chatmodel in om te testen.';

  @override
  String get settingsAiKeyNeededTitle => 'API-sleutel nodig';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Voer je API-sleutel in om te testen. Je opgeslagen sleutel blijft privé.';

  @override
  String get settingsAiKeyToTestBody => 'Voer je API-sleutel in om te testen.';

  @override
  String get settingsAiConnectedTitle => 'Verbonden';

  @override
  String get settingsAiConnectedBody => 'De verbinding werkt.';

  @override
  String get settingsAiTestFailedTitle => 'Test mislukt';

  @override
  String get settingsPreferencesSavedBody => 'Jouw voorkeuren zijn opgeslagen.';

  @override
  String get settingsPasswordNotChangedTitle => 'Wachtwoord niet gewijzigd';

  @override
  String get settingsOAuthPasswordBody =>
      'Dit account meldt zich aan met Google of Apple. Gebruik \'Wachtwoord vergeten\' om eerst een wachtwoord in te stellen.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Huidig wachtwoord is onjuist.';

  @override
  String get settingsExportReadyTitle => 'Export gereed';

  @override
  String get settingsExportReadyBody =>
      'Jouw data-export is klaar om te downloaden.';

  @override
  String get settingsLinkCopiedTitle => 'Link gekopieerd';

  @override
  String get settingsExportClipboardBody =>
      'We konden je browser niet openen, dus we hebben de downloadlink gekopieerd. Plak hem zo snel mogelijk in een browser: hij verloopt.';

  @override
  String get settingsExportFailedTitle => 'Export mislukt';

  @override
  String get settingsAccountNotDeletedTitle => 'Account niet verwijderd';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Je kunt tot $max foto\'s toevoegen.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Foto limiet';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Voeg minimaal één foto toe.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Geen foto\'s';

  @override
  String get photoshootDescribeLookBody => 'Beschrijf de look die je wilt.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt nodig';

  @override
  String get photoshootConsentFeatureLabel => 'AI fotoshoot';

  @override
  String get photoshootStatusPreparing => 'Je foto\'s voorbereiden';

  @override
  String get photoshootStatusGenerating => 'Genereren';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current van $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done van $total afgerond';
  }

  @override
  String get photoshootGenerationFailedBody => 'Genereren mislukt.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready gereed, $failed mislukt.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Deels afgerond';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto\'s zijn gereed.',
      one: '1 foto is gereed.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Verbinding verloren. Probeer het opnieuw.';

  @override
  String get photoshootCouldNotCancelTitle => 'Annuleren mislukt';

  @override
  String get photoshootRetryFailedTitle => 'Opnieuw proberen mislukt';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Foto $number is gereed.';
  }

  @override
  String get photoshootReplacedTitle => 'Vervangen';

  @override
  String get photoshootSavedToGalleryBody => 'Opgeslagen in je galerij.';

  @override
  String get photoshootSavedTitle => 'Opgeslagen';

  @override
  String get photoshootNotSavedTitle => 'Niet opgeslagen';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alle $count foto\'s staan in je galerij.',
      one: '1 foto staat in je galerij.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved van $total opgeslagen.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Enkele foto\'s niet opgeslagen';

  @override
  String get tryonConsentFeatureLabel => 'Virtuele Proefdraag';

  @override
  String get tryonAvatarUpdatedBody => 'Je foto is bijgewerkt.';

  @override
  String get tryonSavedTitle => 'Opgeslagen';

  @override
  String get tryonUploadFailedTitle => 'Upload mislukt';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Kies eerst een foto van een kledingstuk.';

  @override
  String get tryonNoGarmentTitle => 'Geen kledingstuk';

  @override
  String get tryonWaitForUploadBody => 'Wacht tot je foto is geüpload.';

  @override
  String get tryonStillUploadingTitle => 'Nog aan het uploaden';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Voeg eerst een foto van jezelf toe.';

  @override
  String get tryonReadyBody => 'Je proefdraag is gereed.';

  @override
  String get tryonFailedTitle => 'Proefdraag mislukt';

  @override
  String get tryonSavedToGalleryBody => 'Opgeslagen in je galerij.';

  @override
  String get tryonNotSavedTitle => 'Niet opgeslagen';

  @override
  String get calendarEventAddedBody => 'Agendapunt toegevoegd';

  @override
  String get calendarEventPlannedTitle => 'Gepland';

  @override
  String get calendarEventSavedBody => 'Agendapunt opgeslagen';

  @override
  String get calendarSavedTitle => 'Opgeslagen';

  @override
  String get calendarEventNotSavedTitle => 'Agendapunt niet opgeslagen';

  @override
  String get calendarEventRemovedBody => 'Agendapunt verwijderd';

  @override
  String get calendarEventDeletedTitle => 'Verwijderd';

  @override
  String get calendarEventNotDeletedTitle => 'Agenda-item niet verwijderd';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit niet gekoppeld';

  @override
  String get calendarLinkedTitle => 'Gekoppeld';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit niet verwijderd';

  @override
  String get calendarOutfitRemovedBody => 'Outfit verwijderd';

  @override
  String get calendarDisconnectedBody => 'Agenda niet losgekoppeld';

  @override
  String get calendarDisconnectedTitle => 'Losgekoppeld';

  @override
  String get calendarNotDisconnectedTitle => 'Agenda niet losgekoppeld';

  @override
  String get calendarTodayLabel => 'vandaag';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count agenda-items',
      one: '1 agenda-item',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start tot $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit gekoppeld';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" wordt verwijderd.';
  }

  @override
  String get calendarThisAppLabel => 'Deze app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Synchroniseren met $provider is nog niet mogelijk. Je kunt hier nog steeds agenda-items toevoegen.';
  }

  @override
  String get calendarWeekdaySunShort => 'zo';

  @override
  String get calendarWeekdayMonShort => 'ma';

  @override
  String get calendarWeekdayTueShort => 'di';

  @override
  String get calendarWeekdayWedShort => 'wo';

  @override
  String get calendarWeekdayThuShort => 'do';

  @override
  String get calendarWeekdayFriShort => 'vr';

  @override
  String get calendarWeekdaySatShort => 'za';

  @override
  String get calendarWeekdayMonday => 'Maandag';

  @override
  String get calendarWeekdayTuesday => 'Dinsdag';

  @override
  String get calendarWeekdayWednesday => 'Woensdag';

  @override
  String get calendarWeekdayThursday => 'Donderdag';

  @override
  String get calendarWeekdayFriday => 'Vrijdag';

  @override
  String get calendarWeekdaySaturday => 'Zaterdag';

  @override
  String get calendarWeekdaySunday => 'zondag';

  @override
  String get outfitSavedToFavouritesBody => 'Opgeslagen in favorieten';

  @override
  String get outfitRemovedFromFavouritesBody => 'Verwijderd uit favorieten';

  @override
  String get outfitNotSavedTitle => 'Niet opgeslagen';

  @override
  String get outfitLoggedAsWornBody => 'Geregistreerd als gedragen vandaag.';

  @override
  String get outfitNicePickTitle => 'Mooie keuze';

  @override
  String get outfitRemovedBody => 'Outfit verwijderd.';

  @override
  String get outfitDeletedTitle => 'Verwijderd';

  @override
  String get outfitNotDeletedTitle => 'Niet verwijderd';

  @override
  String get outfitDuplicatedBody => 'Een kopie staat in je outfits.';

  @override
  String get outfitDuplicatedTitle => 'Gekopieerd';

  @override
  String get outfitNotDuplicatedTitle => 'Niet gekopieerd';

  @override
  String get outfitNotSharedTitle => 'Niet gedeeld';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" is klaar.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collectie niet aangemaakt';

  @override
  String get outfitCollectionUpdatedBody => 'Collectie bijgewerkt.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collectie niet bijgewerkt';

  @override
  String get outfitCollectionDeletedBody => 'Collectie verwijderd.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collectie niet verwijderd';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits toegevoegd.',
      one: '1 outfit toegevoegd.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits niet toegevoegd';

  @override
  String get outfitPreviewNotCreatedTitle => 'Voorbeeld niet aangemaakt';

  @override
  String get outfitGiveNameBody => 'Geef de outfit een naam.';

  @override
  String get outfitNameMissingTitle => 'Naam';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Kies minstens één item.';

  @override
  String outfitCreatedBody(String name) {
    return '$name staat in je outfits.';
  }

  @override
  String get outfitSavedTitle => 'Opgeslagen';

  @override
  String get wardrobeAddedToFavouritesBody => 'Toegevoegd aan favorieten';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Verwijderd uit favorieten';

  @override
  String get wardrobeNotSavedTitle => 'Niet opgeslagen';

  @override
  String get wardrobeLoggedAsWornBody => 'Vandaag gedragen.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Verwijderd uit je kledingkast.';

  @override
  String get wardrobeDeletedTitle => 'Verwijderd';

  @override
  String get wardrobeNotDeletedTitle => 'Niet verwijderd';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stukken uit je kledingkast verwijderd.',
      one: '1 stuk uit je kledingkast verwijderd.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI-wardrobe-extractie';

  @override
  String get itemAddScanJobLabel => 'Scannen';

  @override
  String get itemAddFoundEarlierBody => 'Vindt in een eerdere scan';

  @override
  String get itemAddLookingAtPhoto => 'Bezig met je foto';

  @override
  String get itemAddExtractionFailedBody => 'Extractie mislukt';

  @override
  String get itemAddJobFailedBody => 'Taak mislukt';

  @override
  String get itemAddConnectionLostBody =>
      'Verbinding verbroken. Probeer het opnieuw.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Verbinding verbroken tijdens verwerking.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Stuk $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Stuk';

  @override
  String get itemAddNotCancelledTitle => 'Niet geannuleerd';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stukken in je kledingkast.',
      one: '1 stuk in je kledingkast.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved van $total stukken opgeslagen. Tik op opslaan om de rest opnieuw te proberen.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Sommige stukken niet opgeslagen';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Kies minstens één foto.';

  @override
  String get batchPhotoUnreadableBody => 'Deze foto kon niet worden gelezen.';

  @override
  String get batchNoPhotosReadableBody =>
      'Geen van deze foto\'s kon worden gelezen. Probeer andere foto\'s.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto\'s',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'De verbinding is verloren tijdens het werk. Probeer het opnieuw.';

  @override
  String get batchNotCancelledTitle => 'Niet geannuleerd';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Postlinks worden niet ondersteund. Voer een profielink in.';

  @override
  String get batchLinkSpacesBody => 'Links mogen geen spaties bevatten.';

  @override
  String get batchEnterProfileLinkBody =>
      'Voer een Instagram- of Facebook profielink in.';

  @override
  String get batchEnterProfileLinkShortBody => 'Voer een profielink in.';

  @override
  String get batchSignInPageNotOpenBody =>
      'De inlogpagina is niet geopend. Probeer het opnieuw.';

  @override
  String get batchSignInBrowserBody =>
      'Log in via je browser, ga daarna terug naar FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Koppel je account';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Voer de code uit je authenticator-app in.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram vraagt een beveiligingscheck. Log eerst in via je browser.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Voer je gebruikersnaam en wachtwoord opnieuw in.';

  @override
  String get batchSignInFailedBody =>
      'Inloggen mislukt. Controleer je gebruikersnaam en wachtwoord.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Log in om te blijven importeren.';

  @override
  String get batchAccountNotConnectedBody => 'Je account is niet gekoppeld.';

  @override
  String get batchAccountConnectedTitle => 'Account gekoppeld';

  @override
  String get batchNotConnectedTitle => 'Niet gekoppeld';

  @override
  String get batchImportConnectionLostBody =>
      'De verbinding met de import is verbroken. Vernieuw om dit te controleren.';

  @override
  String batchPickUpToBody(int max) {
    return 'Kies tot $max foto\'s. Wij vinden de items.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count van $total foto\'s';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Foto $done van $count wordt voorbereid';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Items vinden in $count foto\'s',
      one: 'Items vinden in 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Je $platform-account gebruikt tweestaps inloggen. Voer de 6-cijferige code uit je authenticator-app in.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Dit $platform-profiel is privé of vereist inloggen om foto\'s te tonen.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Koppel met $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto\'s gevonden',
      one: '1 foto gevonden',
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
    return '$processed van $total verwerkt · $added toegevoegd · $waiting wachtrij · $skipped overgeslagen';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Foto $number wordt gescand';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number is de volgende';
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
      other: '$count items gevonden',
      one: '1 item gevonden',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto\'s zijn toegevoegd aan je kledingkast.',
      one: '1 foto is toegevoegd aan je kledingkast.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Er komen nog $count studiofoto\'s bij. Je kunt wat klaar is opslaan, of vertrekken — we laten het je weten.',
      one:
          'Er komt nog 1 studiofoto bij. Je kunt wat klaar is opslaan, of vertrekken — we laten het je weten.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Nog niet opgeslagen: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces items',
      one: '1 item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos foto\'s',
      one: '1 foto',
    );
    return '$_temp0 van $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen geselecteerd. Tik op een item om het over te slaan.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items worden opgeslagen',
      one: '1 item wordt opgeslagen',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bewaar $count items',
      one: 'Bewaar 1 item',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Je lichaamsprofiel is bewaard.';

  @override
  String get bodyProfileSavedTitle => 'Bewaard';

  @override
  String get bodyProfileNotSavedTitle => 'Niet bewaard';

  @override
  String get bodyProfileSetDefaultBody => 'Stel in als je profiel.';

  @override
  String get bodyProfileDeletedBody => 'Lichaamsprofiel verwijderd.';

  @override
  String get bodyProfileDeletedTitle => 'Verwijderd';

  @override
  String get bodyProfileNotDeletedTitle => 'Niet verwijderd';

  @override
  String get feedbackNotSentTitle => 'Niet verzonden';

  @override
  String get feedbackSentBody =>
      'Bedankt. Wij lezen elk bericht en antwoorden als nodig.';

  @override
  String get feedbackSentTitle => 'Feedback verzonden';

  @override
  String get recommendUnnamedPiece => 'Onbenoemd item';

  @override
  String get recommendEnterCityBody =>
      'Voer je stad in voor tips bij het weer.';

  @override
  String get recommendWhichCityTitle => 'Welke stad?';

  @override
  String get aiConsentSheetTitle => 'Foto\'s delen met een AI-service';

  @override
  String get aiConsentSheetBody =>
      'Voor je try-on- en photoshootafbeeldingen stuurt FitCheck AI de foto\'s die je provides (met inbegrip van afbeeldingen van je gezicht en lichaam) naar een betrouwbare derde AI-aanbieder (zoals OpenAI of Google Gemini) voor verwerking. Zij genereren je afbeeldingen en gebruiken ze niet voor training van hun modellen onder onze voorwaarden. Foto\'s worden veilig verstuurd en nooit gedeeld voor advertenties.';

  @override
  String get aiConsentSheetPermission =>
      'Door door te gaan geef je expliciete toestemming om je foto\'s met deze AI-aanbieders te delen voor beeldgeneratie.';

  @override
  String get skeletonsLoadMoreFailed => 'Kon niet meer laden.';

  @override
  String get jobsPiecesReadyTitle => 'Je items zijn klaar';

  @override
  String get jobsScanStoppedTitle => 'De scan is gestopt';

  @override
  String get jobsNothingSavedBody => 'Niets is bewaard. Probeer het opnieuw.';

  @override
  String get jobsPhotoUploadFailedBody => 'Upload van foto mislukt.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google-aanmelding kan niet starten. Probeer het opnieuw.';

  @override
  String get referralAppliedTitle => 'Verruiming toegepast!';

  @override
  String get billingStoreUnavailableBody =>
      'Aankopen in de winkel zijn niet beschikbaar op dit apparaat.';

  @override
  String get billingPurchaseProcessingBody =>
      'Deze aankoop wordt nog verwerkt. Heropen de app over een minuut om je plan te zien.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Upload avatar gaf geen afbeeldings-URL terug.';

  @override
  String get rewardsDayStreakLabel => 'dagreeks';

  @override
  String rewardsBestStreak(int days) {
    return 'Beste $days dagen';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission Toegang nodig';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Toegang tot $permission is momenteel geweigerd. Open Instellingen om dit toe te staan, kom daarna terug en probeer het opnieuw.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Stap $step van 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Stap $step van $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Verwijder afbeelding $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Verwijder afbeelding $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points ptn';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Verstuur een e-mail naar $email. We beoordelen meldingen binnen 24 uur.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Verwijder $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Wil je \"$name\" verwijderen?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Toevoegen aan \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" is verwijderd. De items blijven in je kledingkast.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Toon alle $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Nog $count vandaag';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index mislukt';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected van $max foto\'s';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape bouw · $tone huid';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Wil je $name verwijderen?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opties voor $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Meest gedragen: $name, $count keer';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: niet ingesteld';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked van $max geselecteerd';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Verwijder $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioriteit: $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Dit abonnement wordt afgeschreven via $store. Wijzig of annuleer het in de accountinstellingen van $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Beheren in $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current van $max gebruikt';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Nog ca. ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done van $total studiofoto\'s gereed';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready van $total studiofoto\'s gereed. Tik op een item om het over te slaan.';
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
  String get profileFieldNotSet => 'Nee';
}
