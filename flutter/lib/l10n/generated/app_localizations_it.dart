// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPhotoshoot => 'Scatti';

  @override
  String get tabCloset => 'Guardaroba';

  @override
  String get tabOutfits => 'Outfit';

  @override
  String get tabMore => 'Altro';

  @override
  String get actionAddItem => 'Aggiungi capo';

  @override
  String get actionCreateOutfit => 'Crea outfit';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionDone => 'Fatto';

  @override
  String get actionNext => 'Avanti';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionSearch => 'Cerca';

  @override
  String get actionContinue => 'Continua';

  @override
  String get stateLoading => 'Caricamento';

  @override
  String get stateErrorTitle => 'Qualcosa è andato storto';

  @override
  String get stateErrorBody =>
      'Riprova. Se il problema persiste, contatta l\'assistenza.';

  @override
  String get stateOfflineTitle => 'Sei offline';

  @override
  String get stateOfflineBody =>
      'Riconnettiti per sincronizzare il guardaroba e generare outfit.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'Preferenze';

  @override
  String get settingsPlanBilling => 'Piano e fatturazione';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsUnits => 'Unità di misura';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsPrivacySection => 'Privacy e dati';

  @override
  String get settingsAboutSection => 'Informazioni';

  @override
  String get settingsSignOut => 'Esci';

  @override
  String get settingsDeleteAccount => 'Elimina account';

  @override
  String get settingsDeleteAccountTitle => 'Eliminare l\'account?';

  @override
  String get settingsDeleteAccountBody =>
      'Questa azione rimuoverà il tuo guardaroba, i tuoi outfit, le foto e il profilo. Non può essere annullata.';

  @override
  String get settingsUnitsImperial => 'Imperiale (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrico (cm, kg)';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get languageSystem => 'Usa lingua dispositivo';

  @override
  String get languageSystemBody =>
      'FitCheck AI segue la lingua del tuo telefono.';

  @override
  String get languageSearchHint => 'Cerca lingua';

  @override
  String get languageCurrent => 'Attuale';

  @override
  String get languageReviewNote =>
      'Questa traduzione è nuova. Segnalaci eventuali errori.';

  @override
  String get languageChanged => 'Lingua aggiornata';

  @override
  String get paywallTitle => 'Scegli il tuo piano';

  @override
  String get paywallTrialBadge => '1 mese gratis';

  @override
  String get paywallTrialTitle => 'Il tuo primo mese di Pro è gratis';

  @override
  String get paywallTrialBody =>
      'Carica tutto il tuo guardaroba in una volta. Aggiungi capi man mano in seguito.';

  @override
  String get paywallFreeForeverTitle => 'Gratis per sempre';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Nessuna carta richiesta. Ogni mese ricevi $uploads caricamenti AI, $outfits outfit e $images immagini photoshoot al giorno.';
  }

  @override
  String get paywallCtaTrial => 'Inizia il mese gratis';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Passa a $plan';
  }

  @override
  String get paywallRestore => 'Ripristina acquisti';

  @override
  String get paywallManage => 'Gestisci abbonamento';

  @override
  String get paywallTerms => 'Termini di utilizzo';

  @override
  String get paywallPrivacy => 'Informativa sulla privacy';

  @override
  String get paywallPerMonth => 'al mese';

  @override
  String get paywallPerYear => 'all\'anno';

  @override
  String get paywallBestValue => 'Miglior valore';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Prova gratuita solo per i nuovi abbonati. Dopo la prova, Pro si rinnova a $price a meno che non venga annullato almeno 24 ore prima della scadenza.';
  }

  @override
  String get introTitle => 'Il tuo armadio, finalmente organizzato';

  @override
  String get introBody =>
      'Fotografa i tuoi vestiti una volta sola. Ricevi idee per outfit, anteprime di prova e foto in studio con ciò che già possiedi.';

  @override
  String get introStart => 'Inizia';

  @override
  String get introHaveAccount => 'Ho già un account';

  @override
  String get introSkip => 'Salta';

  @override
  String get authSignIn => 'Accedi';

  @override
  String get authSignUp => 'Crea account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Password dimenticata?';

  @override
  String get authContinueApple => 'Continua con Apple';

  @override
  String get authContinueGoogle => 'Continua con Google';

  @override
  String get authOrDivider => 'o';

  @override
  String get wardrobeTitle => 'Armadio';

  @override
  String get wardrobeEmptyTitle => 'Il tuo armadio è vuoto';

  @override
  String get wardrobeEmptyBody =>
      'Aggiungi il tuo primo capo o carica una foto dell\'intero guardaroba in una volta sola.';

  @override
  String get wardrobeAddFirst => 'Aggiungi il tuo primo capo';

  @override
  String get wardrobeSearchHint => 'Cerca nel tuo armadio';

  @override
  String get categoryTops => 'Top';

  @override
  String get categoryBottoms => 'Pantaloni';

  @override
  String get categoryShoes => 'Scarpe';

  @override
  String get categoryAccessories => 'Accessori';

  @override
  String get categoryOuterwear => 'Capispalla';

  @override
  String get categorySwimwear => 'Costumi';

  @override
  String get categoryActivewear => 'Sport';

  @override
  String get categoryOther => 'Altro';

  @override
  String get conditionClean => 'Pulito';

  @override
  String get conditionDirty => 'Sporco';

  @override
  String get conditionLaundry => 'In lavanderia';

  @override
  String get conditionRepair => 'Da riparare';

  @override
  String get conditionDonate => 'Da donare';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Estate';

  @override
  String get seasonFall => 'Autunno';

  @override
  String get seasonWinter => 'Inverno';

  @override
  String get seasonAll => 'Tutte le stagioni';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formale';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sportivo';

  @override
  String get styleBohemian => 'Bohémien';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romantico';

  @override
  String get styleEdgy => 'Grintoso';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artistico';

  @override
  String get styleClassic => 'Classico';

  @override
  String get styleElegant => 'Elegante';

  @override
  String get styleOther => 'Altro';

  @override
  String get occasionWork => 'Lavoro';

  @override
  String get occasionDateNight => 'Appuntamento';

  @override
  String get occasionTravel => 'Viaggio';

  @override
  String get occasionWedding => 'Matrimonio';

  @override
  String get occasionGym => 'Palestra';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Festa';

  @override
  String get occasionInterview => 'Colloquio';

  @override
  String get colorBlack => 'Nero';

  @override
  String get colorWhite => 'Bianco';

  @override
  String get colorGrey => 'Grigio';

  @override
  String get colorNavy => 'Blu navy';

  @override
  String get colorBrown => 'Marrone';

  @override
  String get colorRed => 'Rosso';

  @override
  String get colorBlue => 'Blu';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Viola';

  @override
  String get colorYellow => 'Giallo';

  @override
  String get colorOrange => 'Arancione';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Oggi';

  @override
  String get dateYesterday => 'Ieri';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count settimane fa',
      one: '1 settimana fa',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesi fa',
      one: '1 mese fa',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anni fa',
      one: '1 anno fa',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Ti piace FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Una valutazione rapida aiuta gli altri a trovare il proprio stile.';

  @override
  String get ratingPromptYes => 'Valuta l\'app';

  @override
  String get ratingPromptNo => 'Non ora';

  @override
  String get closetNoMatchesTitle => 'Nessun capo trovato';

  @override
  String get closetNoMatchesBody => 'Prova a rimuovere filtri o cerca altro.';

  @override
  String get closetClearFilters => 'Cancella filtri';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capi',
      one: '1 capo',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Caricamento capi';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionati',
      one: '1 selezionato',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Elimina selezionati';

  @override
  String get closetCancelSelection => 'Annulla selezione';

  @override
  String get closetCloseSearch => 'Chiudi ricerca';

  @override
  String get closetShowGrid => 'Mostra a griglia';

  @override
  String get closetShowList => 'Mostra a elenco';

  @override
  String get closetShowRows => 'Mostra a righe';

  @override
  String get closetStatsTitle => 'Statistiche guardaroba';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elimina $count capi?',
      one: 'Elimina 1 capo?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Gli outfit che li usano perderanno questi capi.';

  @override
  String get closetSortBy => 'Ordina per';

  @override
  String get closetFavourites => 'Preferiti';

  @override
  String get closetFavourite => 'Preferito';

  @override
  String get closetUnfavourite => 'Rimuovi dai preferiti';

  @override
  String get closetWoreToday => 'Indossato oggi';

  @override
  String closetWornTimes(int count) {
    return 'Indossato $count volte';
  }

  @override
  String get closetCategoryLabel => 'Categoria';

  @override
  String get closetUseCaseLabel => 'Occasione';

  @override
  String get closetAnyUseCase => 'Tutte';

  @override
  String get closetOtherUseCase => 'Altra occasione';

  @override
  String get closetOtherUseCaseHint => 'Per esempio, brunch';

  @override
  String get closetUseUseCase => 'Usa questa';

  @override
  String get closetClearAll => 'Cancella tutto';

  @override
  String get sortNewest => 'Più recenti';

  @override
  String get sortOldest => 'Meno recenti';

  @override
  String get sortName => 'Nome (A–Z)';

  @override
  String get sortMostWorn => 'Più indossati';

  @override
  String get useCaseInformal => 'Informale';

  @override
  String get useCaseDate => 'Appuntamento';

  @override
  String get useCaseDinner => 'Cena';

  @override
  String get useCaseLunch => 'Pranzo';

  @override
  String get actionSelect => 'Seleziona';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionFilter => 'Filtra';

  @override
  String get actionSort => 'Ordina';

  @override
  String get actionAll => 'Tutti';

  @override
  String get dashboardStartClosetTitle => 'Crea il tuo guardaroba';

  @override
  String get dashboardStartClosetBody =>
      'Fotografa qualche capo. Li etichettiamo noi per te.';

  @override
  String get dashboardPieces => 'capi';

  @override
  String get dashboardOutfits => 'outfit';

  @override
  String get dashboardDayStreak => 'giorni di fila';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count questo mese';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Record $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preferiti',
      one: '1 preferito',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfit salvati',
      one: '1 outfit salvato',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Più indossato: $name, $count volte';
  }

  @override
  String get setupSkip => 'Salta configurazione';

  @override
  String get setupWhoTitle => 'Chi vestiamo?';

  @override
  String get setupWhoBody =>
      'Imposta il modello per le prove e gli scatti. Puoi cambiarlo nel profilo.';

  @override
  String get setupStyleTitle => 'Cosa indossi di più?';

  @override
  String get setupStyleBody =>
      'Scegline alcuni. Le idee di outfit partono da qui.';

  @override
  String get setupClosetTitle => 'Aggiungi i tuoi primi capi.';

  @override
  String get setupClosetBody =>
      'Fotografa qualche abito o un mucchio di vestiti. Ogni capo viene ritagliato e archiviato per te.';

  @override
  String get setupAddClothes => 'Aggiungi vestiti';

  @override
  String get setupStylesLabel => 'Stili';

  @override
  String get setupOccasionsLabel => 'Occasioni';

  @override
  String get setupSkipStep => 'Salta';

  @override
  String get setupLater => 'Più tardi';

  @override
  String get setupSaveError => 'Salvataggio non riuscito';

  @override
  String get genderWomen => 'Donna';

  @override
  String get genderMen => 'Uomo';

  @override
  String get genderNonBinary => 'Non binario';

  @override
  String get genderPreferNotToSay => 'Preferisco non specificare';

  @override
  String get outfitEmptyTitle => 'Nessun outfit';

  @override
  String get outfitEmptyBody =>
      'Abbina i capi del tuo guardaroba e salva il look.';

  @override
  String get outfitNoMatchesTitle => 'Nessun outfit trovato';

  @override
  String get outfitSearchHint => 'Cerca tra i tuoi outfit';

  @override
  String get outfitLoading => 'Caricamento outfit';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfit',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Stile e stagione';

  @override
  String get outfitCollections => 'Collezioni';

  @override
  String get outfitDuplicate => 'Duplica';

  @override
  String get outfitDeleteTitle => 'Eliminare questo outfit?';

  @override
  String get outfitDeleteBody => 'I capi rimarranno nel tuo guardaroba.';

  @override
  String get outfitDrafts => 'Bozze';

  @override
  String get outfitDraft => 'Bozza';

  @override
  String get filterStyle => 'Stile';

  @override
  String get filterSeason => 'Stagione';

  @override
  String get itemDetailDeleteTitle => 'Eliminare questo capo?';

  @override
  String get itemDetailDeleteBody =>
      'Gli outfit che lo usano perderanno questo capo.';

  @override
  String get itemAddFavourite => 'Aggiungi ai preferiti';

  @override
  String itemSize(String size) {
    return 'Taglia $size';
  }

  @override
  String get itemColours => 'Colori';

  @override
  String get itemMaterial => 'Materiale';

  @override
  String get itemPattern => 'Fantasia';

  @override
  String get itemUseCases => 'Occasioni';

  @override
  String get itemKeptIn => 'Custodito in';

  @override
  String get itemPrice => 'Prezzo';

  @override
  String get itemBought => 'Acquistato';

  @override
  String get itemTags => 'Tag';

  @override
  String get itemAdded => 'Aggiunto';

  @override
  String get itemTimesWornLabel => 'volte indossato';

  @override
  String get itemLastWornLabel => 'ultimo utilizzo';

  @override
  String get itemNeverWorn => 'Mai';

  @override
  String get authEntryBody =>
      'Ogni capo che possiedi, abbinato dall\'AI. Pianifica outfit, provali, scatta.';

  @override
  String get authCreateCloset => 'Crea il tuo armadio';

  @override
  String get authWelcomeBack => 'Bentornato';

  @override
  String get authSignInBody => 'Accedi per aprire il tuo armadio.';

  @override
  String get authCreateAccount => 'Crea un account';

  @override
  String get authCreateClosetBody =>
      'Ci vuole un minuto. I tuoi primi capi sono gratis.';

  @override
  String get authName => 'Nome';

  @override
  String get authConfirmPassword => 'Conferma password';

  @override
  String get authReferralCode => 'Codice referral (opzionale)';

  @override
  String get authResetTitle => 'Reimposta password';

  @override
  String get authResetBody => 'Ti invieremo un link per sceglierne una nuova.';

  @override
  String get authSendResetLink => 'Invia link di reset';

  @override
  String get authBackToSignIn => 'Torna all\'accesso';

  @override
  String get authEnterEmail => 'Inserisci la tua email';

  @override
  String get authEnterValidEmail => 'Inserisci un\'email valida';

  @override
  String get authEnterPassword => 'Inserisci la tua password';

  @override
  String get authPasswordTooShort => 'Almeno 6 caratteri';

  @override
  String get authShowPassword => 'Mostra password';

  @override
  String get authHidePassword => 'Nascondi password';

  @override
  String get authNewHere => 'Nuovo qui?';

  @override
  String authConfirmEmail(String email) {
    return 'Conferma $email prima di accedere. Controlla la posta in arrivo.';
  }

  @override
  String get authResendEmail => 'Invia di nuovo';

  @override
  String get authResendingEmail => 'Invio in corso…';

  @override
  String get authPasswordsDoNotMatch => 'Le password non coincidono';

  @override
  String get authEnterName => 'Inserisci il tuo nome';

  @override
  String get authChoosePassword => 'Scegli una password';

  @override
  String get authHaveAccount => 'Hai già un account?';

  @override
  String get authCodeAccepted => 'Codice accettato';

  @override
  String get authCodeNotFound => 'Codice non trovato';

  @override
  String authReferralFrom(String name) {
    return 'Da $name. Ricevete entrambi un mese gratis.';
  }

  @override
  String get authReferralInvalid =>
      'Non siamo riusciti a trovare questo codice.';

  @override
  String authResetSent(String email) {
    return 'Inviato a $email. Apri il link su questo telefono.';
  }

  @override
  String get introSlide1Title => 'Fotografa il tuo armadio.';

  @override
  String get introSlide1Body =>
      'Fotografa una pila di vestiti. Ogni capo viene ritagliato e archiviato per te.';

  @override
  String get introSlide2Title => 'Vestiti più velocemente.';

  @override
  String get introSlide2Body =>
      'Outfit creati con ciò che possiedi, abbinati ai tuoi programmi e al meteo.';

  @override
  String get introSlide3Title => 'Veditelo addosso prima di indossarlo.';

  @override
  String get introSlide3Body =>
      'Prova i look sulla tua foto, o scattali come in una campagna.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Aggiornamenti email';

  @override
  String get settingsEmailUpdatesBody => 'Novità e consigli via email';

  @override
  String get settingsOutfitReminders => 'Promemoria outfit';

  @override
  String get settingsOutfitRemindersBody =>
      'Un promemoria per registrare cosa hai indossato';

  @override
  String get settingsWeeklySummary => 'Riepilogo settimanale';

  @override
  String get settingsWeeklySummaryBody => 'La tua settimana in outfit';

  @override
  String get settingsStyleSection => 'Stile';

  @override
  String get settingsPreferredStyles => 'Stili che preferisci';

  @override
  String get settingsPreferredColours => 'Colori che preferisci';

  @override
  String get settingsNoneChosen => 'Nessuno scelto';

  @override
  String get settingsPlanAiSection => 'Piano e AI';

  @override
  String get settingsPlanBillingBody => 'Piano, consumo e upgrade';

  @override
  String get settingsPlanUsageBody => 'Piano e consumo';

  @override
  String get settingsInviteFriends => 'Invita amici';

  @override
  String get settingsInviteFriendsBody =>
      'Un mese gratis per ogni amico che si unisce';

  @override
  String get settingsAiProvider => 'Provider AI';

  @override
  String get settingsAiProviderBody => 'Usa il tuo modello per tag e immagini';

  @override
  String get settingsAppVersion => 'Versione app';

  @override
  String get settingsPrivacyTerms => 'Privacy e termini';

  @override
  String get settingsReportProblem => 'Segnala un problema';

  @override
  String get settingsChangePassword => 'Cambia password';

  @override
  String get settingsExportData => 'Esporta i tuoi dati';

  @override
  String get settingsExportBody =>
      'Prepariamo un file con tutto ciò che hai salvato e avviamo il download.';

  @override
  String get settingsExportAction => 'Esporta';

  @override
  String get settingsCurrentPassword => 'Password attuale';

  @override
  String get settingsNewPassword => 'Nuova password';

  @override
  String get settingsConfirmNewPassword => 'Conferma nuova password';

  @override
  String get settingsEnterCurrentPassword => 'Inserisci la password attuale';

  @override
  String get settingsEnterNewPassword => 'Inserisci una nuova password';

  @override
  String get settingsPasswordMin8 => 'Usa almeno 8 caratteri';

  @override
  String get settingsPasswordNeedsUpper => 'Aggiungi una lettera maiuscola';

  @override
  String get settingsPasswordNeedsLower => 'Aggiungi una lettera minuscola';

  @override
  String get settingsPasswordNeedsDigit => 'Aggiungi un numero';

  @override
  String get settingsPasswordsNoMatch => 'Le password non coincidono';

  @override
  String get settingsChangeAction => 'Modifica';

  @override
  String get itemAddSnapTitle => 'Fotografa un capo';

  @override
  String get itemAddSnapBody =>
      'Troviamo ogni capo nella foto e creiamo uno scatto in studio pulito per ciascuno.';

  @override
  String get itemAddCamera => 'Scatta una foto';

  @override
  String get itemAddGallery => 'Scegli dalla galleria';

  @override
  String get itemAddOtherWays => 'Altri modi per aggiungere';

  @override
  String get itemAddSeveral => 'Aggiungi più foto';

  @override
  String get itemAddSeveralBody => 'Fino a 50 alla volta';

  @override
  String get itemAddImportProfile => 'Importa da un profilo';

  @override
  String get itemAddImportProfileBody => 'Instagram o Facebook';

  @override
  String get itemAddEnterDetails => 'Inserisci i dettagli';

  @override
  String get itemAddEnterDetailsBody => 'Nessuna foto necessaria';

  @override
  String get itemManualIntro =>
      'Serve solo un nome. Aggiungi il resto ora o dopo.';

  @override
  String get itemManualNameHint => 'Ad esempio, t-shirt in cotone blu';

  @override
  String get itemManualEnterName => 'Inserisci un nome';

  @override
  String get itemManualNotes => 'Note';

  @override
  String get itemManualBrand => 'Brand';

  @override
  String get itemManualSize => 'Taglia';

  @override
  String get itemManualEnterNumber => 'Inserisci un numero';

  @override
  String get itemManualSavePiece => 'Salva capo';

  @override
  String get itemManualSaving => 'Salvataggio';

  @override
  String get itemManualSavedTitle => 'Salvato';

  @override
  String itemManualSavedBody(String name) {
    return '$name è nel tuo armadio.';
  }

  @override
  String get itemManualNotSaved => 'Non salvato';

  @override
  String get itemManualAddUseCase => 'Aggiungi un contesto';

  @override
  String get itemManualAddUseCaseAction => 'Aggiungi contesto';

  @override
  String get itemPhotos => 'Foto';

  @override
  String get itemAddPhotos => 'Aggiungi foto';

  @override
  String get itemNoPhotoYet => 'Nessuna foto ancora. Puoi salvare senza.';

  @override
  String get itemRemovePhoto => 'Rimuovi foto';

  @override
  String get itemRemovePiece => 'Rimuovi capo';

  @override
  String get filterConditionLabel => 'Condizione';

  @override
  String get photoshootStepPhotos => 'Foto';

  @override
  String get photoshootStepSetup => 'Configurazione';

  @override
  String get photoshootStepCreating => 'Creazione';

  @override
  String get photoshootStepResults => 'Risultati';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Passaggio $current di $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Una foto non è riuscita. Riprova sotto.';

  @override
  String photoshootManyFailed(int count) {
    return '$count foto non sono riuscite. Riprova ciascuna sotto.';
  }

  @override
  String get photoshootFormat => 'Formato';

  @override
  String get photoshootHowMany => 'Quante';

  @override
  String get photoshootYourPrompt => 'Il tuo prompt';

  @override
  String get photoshootPromptHint => 'Ora d\'oro su un tetto, camicia di lino';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crea $count foto',
      one: 'Crea 1 foto',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'foto',
      one: 'foto',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Impossibile verificare il limite di oggi.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Piano $plan: $remaining di $limit rimanenti oggi';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratuito';

  @override
  String get photoshootGallery => 'Galleria';

  @override
  String get photoshootUseCamera => 'Usa fotocamera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Rimuovi foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Nessuna foto restituita';

  @override
  String get photoshootNoPhotosBody =>
      'Lo shooting è terminato senza immagini. Riprova.';

  @override
  String get photoshootNewStyle => 'Nuovo stile';

  @override
  String get photoshootNewPhotos => 'Nuove foto';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Apri foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Segnala foto';

  @override
  String get photoshootSaveToGallery => 'Salva in galleria';

  @override
  String get actionUpgrade => 'Aggiorna';

  @override
  String get referralLimitTitle => 'Hai esaurito le foto di oggi';

  @override
  String get referralLimitBody =>
      'Le tue foto gratuite tornano domani. Invita un amico e riceverete entrambi un mese di Pro gratis.';

  @override
  String get referralLimitRefer => 'Invita un amico';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating app';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Aesthetic';

  @override
  String get photoshootUseCustom => 'Prompt personalizzato';

  @override
  String get photoshootDescLinkedin => 'Ritratti professionali';

  @override
  String get photoshootDescDating => 'Rilassati e naturali';

  @override
  String get photoshootDescPortfolio => 'Look editoriali e haute couture';

  @override
  String get photoshootDescInstagram => 'Scatti lifestyle per il feed';

  @override
  String get photoshootDescAesthetic => 'Inquadrature artistiche';

  @override
  String get photoshootDescCustom => 'Descrivi il look che desideri';

  @override
  String get aspectSquare => 'Quadrato';

  @override
  String get aspectPortrait => 'Ritratto';

  @override
  String get aspectLandscape => 'Panoramica';

  @override
  String get aspectTall => 'Verticale';

  @override
  String get aspectWide => 'Orizzontale';

  @override
  String get tryOnAppBar => 'Prova virtuale';

  @override
  String get tryOnYourPhoto => 'La tua foto';

  @override
  String get tryOnGarment => 'Capo';

  @override
  String get tryOnUploadingPhoto => 'Caricamento foto in corso';

  @override
  String get tryOnAddPhotoPrompt => 'Aggiungi una tua foto a figura intera';

  @override
  String get tryOnBodyPhotoHint => 'Una foto a figura intera funziona meglio';

  @override
  String get tryOnAddPhoto => 'Aggiungi foto';

  @override
  String get tryOnChangePhoto => 'Cambia foto';

  @override
  String get tryOnPhotoLoadFailed => 'Impossibile caricare la foto.';

  @override
  String get tryOnChooseGarment => 'Scegli la foto di un capo';

  @override
  String get tryOnChooseOneGarment => 'Scegli la foto di un capo';

  @override
  String get tryOnGarmentHint => 'Uno scatto in piano o sugruccia è l\'ideale';

  @override
  String get tryOnChange => 'Modifica';

  @override
  String get tryOnCamera => 'Fotocamera';

  @override
  String get tryOnRemove => 'Rimuovi';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Stile';

  @override
  String get tryOnBackground => 'Sfondo';

  @override
  String get tryOnPose => 'Posa';

  @override
  String get tryOnDressingUp =>
      'Preparazione del look. Ci vorrà circa mezzo minuto.';

  @override
  String get tryOnEmptyResult => 'La tua prova apparirà qui';

  @override
  String get tryOnReportImage => 'Segnala immagine';

  @override
  String get tryOnCreating => 'Creazione';

  @override
  String get tryOnTryAgain => 'Riprova';

  @override
  String get tryOnCreate => 'Crea prova';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio bianco';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio grigio';

  @override
  String get tryOnBackgroundUrban => 'Strada urbana';

  @override
  String get tryOnBackgroundNature => 'Natura';

  @override
  String get tryOnBackgroundMinimal => 'Minimale';

  @override
  String get tryOnPoseFront => 'In piedi di fronte';

  @override
  String get tryOnPoseSide => 'In piedi di profilo';

  @override
  String get tryOnPoseWalking => 'In camminata';

  @override
  String get dashboardGreetingMorning => 'Buongiorno';

  @override
  String get dashboardGreetingAfternoon => 'Buon pomeriggio';

  @override
  String get dashboardGreetingEvening => 'Buonasera';

  @override
  String get dashboardWelcome => 'Benvenuto';

  @override
  String get dashboardOpenProfile => 'Apri profilo';

  @override
  String get dashboardRailToday => 'Oggi';

  @override
  String get dashboardRailRecently => 'Recenti';

  @override
  String get dashboardActivityEmpty => 'Nuovi capi e outfit compariranno qui.';

  @override
  String get quickAddPiece => 'Aggiungi capo';

  @override
  String get quickAddPieceBody => 'Fotografa e tagga';

  @override
  String get quickBuildOutfit => 'Crea outfit';

  @override
  String get quickBuildOutfitBody => 'Abbina i tuoi capi';

  @override
  String get quickForYou => 'Per te';

  @override
  String get quickForYouBody => 'Scelte per oggi';

  @override
  String get quickPlanWeek => 'Pianifica la settimana';

  @override
  String get quickPlanWeekBody => 'Outfit per data';

  @override
  String get referralBannerUrgent => 'Scorte esaurite? Invita un amico.';

  @override
  String get referralBannerTitle => 'Regala un mese, ricevi un mese.';

  @override
  String get referralBannerBody =>
      'Tu e il tuo amico ricevete un mese di Pro a testa.';

  @override
  String get referralBannerDismiss => 'Nascondi per una settimana';

  @override
  String get referralBannerShare => 'Condividi invito';

  @override
  String get referralBannerCopy => 'Copia link';

  @override
  String get itemEditPieceTitle => 'Modifica capo';

  @override
  String get itemEditDescriptionLabel => 'Descrizione';

  @override
  String get itemEditNotSaved => 'Non salvato';

  @override
  String get itemEditSavedTitle => 'Salvato';

  @override
  String get itemEditSavedBody => 'Le modifiche sono state salvate.';

  @override
  String get itemEditSavedStalePhotos =>
      'Salvato — le foto potrebbero non essere aggiornate';

  @override
  String get itemEditRemovePieceHint =>
      'Elimina questo capo dalla pagina dell\'articolo.';

  @override
  String get itemEditNoPhotos =>
      'Nessuna foto. Aggiungine una dalla galleria o dalla fotocamera.';

  @override
  String get itemEditKeepPhoto => 'Mantieni foto';

  @override
  String get itemEditRemoved => 'Rimosso';

  @override
  String get itemEditAddUseCaseAction => 'Aggiungi';

  @override
  String get statsNoStatsTitle => 'Ancora nessuna statistica';

  @override
  String get statsNoStatsBody =>
      'Aggiungi qualche capo per vedere qui il mix del tuo guardaroba.';

  @override
  String get statsByCategory => 'Per categoria';

  @override
  String get statsTotalValue => 'valore totale';

  @override
  String get statsMostWorn => 'Più indossati';

  @override
  String get statsLeastWorn => 'In attesa di turno';

  @override
  String get statsUnnamedPiece => 'Capo senza nome';

  @override
  String get jobsTitle => 'Scansioni';

  @override
  String get jobsEmptyTitle => 'Nessuna scansione';

  @override
  String get jobsEmptyBody =>
      'Fotografa un capo e lascialo elaborare: continuerà a lavorare qui.';

  @override
  String get jobsNotCancelled => 'Non annullato';

  @override
  String get jobsResume => 'Riprendi';

  @override
  String get jobsReview => 'Rivedi';

  @override
  String get jobsStop => 'Ferma';

  @override
  String get jobsDismiss => 'Ignora';

  @override
  String get reportTitle => 'Segnala contenuto';

  @override
  String reportIntro(String contentType) {
    return 'Dicci cosa non va in questo $contentType. Il nostro team esamina ogni segnalazione.';
  }

  @override
  String get reportReasonInappropriate => 'Inappropriato o offensivo';

  @override
  String get reportReasonNudity => 'Nudità o contenuti sessuali';

  @override
  String get reportReasonHarassment => 'Molestie o abusi';

  @override
  String get reportReasonImpersonation => 'Furto d\'identità';

  @override
  String get reportReasonOther => 'Altro';

  @override
  String get reportDetailsLabel => 'Dettagli aggiuntivi (opzionale)';

  @override
  String get reportSubmit => 'Invia segnalazione';

  @override
  String get reportSubmittedTitle => 'Segnalazione inviata';

  @override
  String get reportSubmittedBody =>
      'Grazie. Il nostro team esaminerà il contenuto.';

  @override
  String get reportFailedTitle => 'Invio non riuscito';

  @override
  String get reportFailedBody => 'Riprova.';

  @override
  String get reportContentTryOnImage => 'immagine prova virtuale';

  @override
  String get reportContentSharedOutfit => 'outfit condiviso';

  @override
  String get reportContentPhotoshootImage => 'immagine photoshoot AI';

  @override
  String get sharedOutfitTitle => 'Outfit condiviso';

  @override
  String get sharedOutfitHideTooltip => 'Nascondi outfit';

  @override
  String get sharedOutfitReportTooltip => 'Segnala outfit';

  @override
  String get sharedOutfitHideTitle => 'Nascondere l\'outfit?';

  @override
  String get sharedOutfitHideBody =>
      'Sarà nascosto su questo dispositivo. Puoi anche segnalarlo affinché il nostro team lo esamini e lo rimuova.';

  @override
  String get sharedOutfitHideAction => 'Nascondi';

  @override
  String get sharedOutfitHiddenInfo =>
      'Questo outfit non verrà più mostrato su questo dispositivo.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit nascosto';

  @override
  String get sharedOutfitMissingTitle => 'Outfit non più disponibile';

  @override
  String get sharedOutfitMissingBody =>
      'Potrebbe essere stato rimosso o il link non è corretto.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Hai nascosto questo outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Se è inappropriato, segnalalo in Privacy e termini o invia un\'email a $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Ti piace questo look?';

  @override
  String get sharedOutfitCtaBody =>
      'Crea outfit simili con i capi del tuo armadio.';

  @override
  String get sharedOutfitCtaButton => 'Scarica FitCheck AI';

  @override
  String get errorTitle => 'Errore';

  @override
  String get errorUnknown => 'Si è verificato un errore inatteso';

  @override
  String get errorNoConnection =>
      'Nessuna connessione a internet. Controlla la rete.';

  @override
  String get errorTimeout => 'Tempo scaduto. Riprova.';

  @override
  String get errorServerError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errorBadGateway =>
      'Server temporaneamente non disponibile. Riprova.';

  @override
  String get errorServiceUnavailable =>
      'Servizio temporaneamente non disponibile. Riprova a breve.';

  @override
  String get errorInternalError => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errorUnauthorized => 'Accedi per continuare.';

  @override
  String get errorForbidden => 'Non hai accesso a questa sezione.';

  @override
  String get errorSessionExpired =>
      'Sessione scaduta. Effettua nuovamente l\'accesso.';

  @override
  String get errorInvalidCredentials => 'Email o password non corretti.';

  @override
  String get errorTokenRefreshFailed =>
      'Impossibile aggiornare la sessione. Accedi di nuovo.';

  @override
  String get errorRequestCancelled => 'Richiesta annullata.';

  @override
  String get errorInvalidFormat => 'Formato file non supportato.';

  @override
  String get errorFileTooLarge => 'Il file è troppo grande.';

  @override
  String get errorUploadFailed => 'Caricamento fallito. Riprova.';

  @override
  String get errorCacheCorrupted =>
      'I dati salvati sono danneggiati e sono stati ripristinati.';

  @override
  String get errorCacheNotFound => 'Nessun elemento salvato.';

  @override
  String get errorUserNotFound => 'Impossibile trovare questo account.';

  @override
  String get errorItemNotFound => 'Questo capo non esiste più.';

  @override
  String get errorOutfitNotFound => 'Questo outfit non esiste più.';

  @override
  String get rewardsTitle => 'Premi';

  @override
  String get rewardsNoAchievementsTitle => 'Ancora nessun traguardo';

  @override
  String get rewardsNoAchievementsBody =>
      'Aggiungi capi e crea outfit per sbloccare il primo.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Nessun utente in classifica';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Crea outfit per guadagnare punti e comparire qui.';

  @override
  String get legalViewPrivacyPolicy => 'Leggi l\'Informativa sulla privacy';

  @override
  String get aiConsentAgree => 'Accetta e continua';

  @override
  String get aiConsentNotNow => 'Ora no';

  @override
  String get imageViewerCloseTooltip => 'Chiudi visualizzatore immagini';

  @override
  String get updateReadyTitle => 'Aggiornamento pronto';

  @override
  String get updateReadyBody =>
      'Riavvia FitCheck AI per applicare le ultime novità.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI richiede l\'accesso alla fotocamera per scattare foto dei tuoi outfit e capi.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI richiede l\'accesso alle foto per selezionare le immagini dei tuoi outfit e capi.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI deve salvare le foto dei tuoi outfit generate dall\'intelligenza artificiale nella tua libreria.';

  @override
  String get wardrobeSomePhotosSkipped => 'Alcune foto sono state saltate';

  @override
  String get wardrobePhotosNotAdded => 'Foto non aggiunte';

  @override
  String get wardrobePhotoNotAdded => 'Foto non aggiunta';

  @override
  String get wardrobeNotStartedTitle => 'Non iniziato';

  @override
  String get wardrobeNoRoomTitle => 'Spazio esaurito';

  @override
  String get wardrobeAddPhotosSemantic => 'Aggiungi foto';

  @override
  String get batchAddTileLabel => 'Aggiungi';

  @override
  String get batchProfileLinkLabel => 'Link profilo';

  @override
  String get wardrobeImportFromProfileTitle => 'Importa da un profilo';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Aggiungi più foto';

  @override
  String get wardrobeClearAction => 'Cancella';

  @override
  String get wardrobeRefreshTooltip => 'Aggiorna';

  @override
  String get batchNoPhotosYetTitle => 'Ancora nessuna foto';

  @override
  String get batchChoosePhotosAction => 'Scegli foto';

  @override
  String get batchWeFindEachPieceBody =>
      'Riconosciamo ogni capo e creiamo una foto in stile studio.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparazione foto';

  @override
  String get batchPhotosProcessedSemantic => 'Foto elaborate';

  @override
  String get batchPasteProfileLinkTitle => 'Incolla il link di un profilo';

  @override
  String get batchPasteProfileLinkBody =>
      'Un profilo pubblico Instagram o Facebook. Scansioniamo le foto e tu scegli cosa mettere nel tuo armadio.';

  @override
  String get batchClearLinkTooltip => 'Cancella link';

  @override
  String get batchStartingButton => 'Avvio in corso';

  @override
  String get batchStartImportAction => 'Inizia importazione';

  @override
  String get batchReviewEveryPhotoTitle => 'Rivedi ogni foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nulla viene aggiunto finché non lo approvi.';

  @override
  String get batchPrivateProfilesTitle => 'Profili privati';

  @override
  String get batchPrivateProfilesBody =>
      'Collega il tuo account. Instagram richiede anche nome utente e password.';

  @override
  String get batchUseAnotherLinkAction => 'Usa un altro link';

  @override
  String get batchSignInNeededTitle => 'Accesso richiesto';

  @override
  String get batchEnterYourCodeTitle => 'Inserisci il codice';

  @override
  String get batchUseUsernamePasswordAction => 'Usa nome utente e password';

  @override
  String get batchAlreadyConnectedAction =>
      'Ho già effettuato l\'accesso nel browser';

  @override
  String get batchEnterCodeAction => 'Inserisci codice';

  @override
  String get batchTryAnotherWayAction => 'Prova un altro metodo';

  @override
  String get batchLiveStatus => 'Dal vivo';

  @override
  String get batchReconnectingStatus => 'Riconnessione in corso';

  @override
  String get batchSignInToInstagramTitle => 'Accedi a Instagram';

  @override
  String get batchUsernameLabel => 'Nome utente';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Codice, se usi la verifica in due passaggi';

  @override
  String get batchAuthenticatorCodeBody =>
      'Usa il codice a 6 cifre della tua app di autenticazione. I codici cambiano rapidamente.';

  @override
  String get batchVerifyAction => 'Verifica';

  @override
  String get batchFindingPhotosTitle => 'Ricerca foto';

  @override
  String get batchImportPausedTitle => 'Importazione in pausa';

  @override
  String get batchProcessingPhotosTitle => 'Elaborazione foto';

  @override
  String get batchWaitingNextPhoto => 'In attesa della prossima foto';

  @override
  String get batchCancelImportAction => 'Annulla importazione';

  @override
  String get batchNoPiecesInPhotoBody => 'Nessun capo trovato in questa foto.';

  @override
  String get batchEditPieceColoursLabel => 'Colori, separati da virgole';

  @override
  String get batchAddToClosetAction => 'Aggiungi al guardaroba';

  @override
  String get batchSkipPhotoAction => 'Salta questa foto';

  @override
  String get batchImportCompleteTitle => 'Importazione completata';

  @override
  String get batchImportFailedTitle => 'Importazione non riuscita';

  @override
  String get batchImportCancelledTitle => 'Importazione annullata';

  @override
  String get batchImportErrorBody =>
      'Qualcosa è andato storto durante l\'importazione.';

  @override
  String get batchNothingMoreImportedBody =>
      'Non è stato importato altro da questo profilo.';

  @override
  String get batchViewClosetAction => 'Vedi guardaroba';

  @override
  String get batchStartOverAction => 'Ricomincia';

  @override
  String get wardrobeAddPieceTitle => 'Aggiungi capo';

  @override
  String get wardrobeAddDetailsTitle => 'Aggiungi dettagli';

  @override
  String get wardrobeScanningTitle => 'Scansione';

  @override
  String get batchReviewPiecesTitle => 'Rivedi capi';

  @override
  String get wardrobeGalleryAction => 'Galleria';

  @override
  String get wardrobeCameraAction => 'Fotocamera';

  @override
  String get wardrobeNewBadge => 'Nuovo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Rimuovi foto';

  @override
  String get batchRunInBackgroundTooltip => 'Esegui in background';

  @override
  String get batchStepOneOfTwo => 'Passaggio 1 di 2';

  @override
  String get batchStepTwoOfTwo => 'Passaggio 2 di 2';

  @override
  String get batchUploadingPhotosTitle => 'Caricamento foto';

  @override
  String get batchFindingPiecesTitle => 'Ricerca capi';

  @override
  String get batchMakingStudioPhotosTitle => 'Creazione foto in studio';

  @override
  String get batchStoppedLabel => 'Interrotto';

  @override
  String get batchFindingPiecesStoppedTitle => 'Ricerca capi interrotta';

  @override
  String get batchCancelledLabel => 'Annullato';

  @override
  String get batchAllDoneTitle => 'Tutto fatto';

  @override
  String get batchOpeningPiecesBody => 'Apertura capi';

  @override
  String get batchNothingSavedBody => 'Nessun elemento salvato.';

  @override
  String get batchFindingPiecesFailedBody => 'Ricerca capi non riuscita.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Ricerca capi interrotta anticipatamente.';

  @override
  String get batchStopFindingPiecesTitle => 'Interrompere la ricerca?';

  @override
  String get batchStopFindingPiecesBody =>
      'La scansione si ferma e non viene salvato nulla. I capi già trovati rimangono nella tua attività finché non li rimuovi.';

  @override
  String get batchKeepGoingAction => 'Continua';

  @override
  String get batchTryAgainAction => 'Riprova';

  @override
  String get batchBackToPhotosAction => 'Torna alle foto';

  @override
  String get batchSkipAllAction => 'Salta tutto';

  @override
  String get batchIncludeAllAction => 'Includi tutti';

  @override
  String get batchNoPiecesFoundTitle => 'Nessun capo trovato';

  @override
  String get batchNoPiecesFoundBody =>
      'Non abbiamo trovato vestiti in queste foto.';

  @override
  String get batchChooseOtherPhotosAction => 'Scegli altre foto';

  @override
  String get batchUseCaseHelper => 'Aggiunto a ogni capo che salvi.';

  @override
  String get batchDiscardPiecesTitle => 'Scartare questi capi?';

  @override
  String get batchDiscardPiecesBody => 'Nulla di questo gruppo verrà salvato.';

  @override
  String get batchKeepAction => 'Tieni';

  @override
  String get batchDiscardAction => 'Scarta';

  @override
  String get batchRemovePieceTitle => 'Rimuovere questo capo?';

  @override
  String get batchRemovePieceBody => 'Non è salvato nel tuo armadio.';

  @override
  String get batchRemoveAction => 'Rimuovi';

  @override
  String get batchChoosePiecesToSave => 'Scegli i capi da salvare';

  @override
  String get batchDiscardAllAction => 'Scarta tutti';

  @override
  String get batchNothingSavedRetryBody =>
      'Non è stato salvato nulla. Riprova.';

  @override
  String get batchNotSavedTitle => 'Non salvato';

  @override
  String get batchSavingLabel => 'Salvataggio';

  @override
  String get batchSendToBackgroundAction => 'In esecuzione in background';

  @override
  String get batchStillWorkingMessage =>
      'Elaborazione in corso. Ti avviseremo quando i tuoi capi saranno pronti.';

  @override
  String get batchRunningInBackgroundTitle => 'In esecuzione in background';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Foto in studio interrotte. Puoi comunque salvare questi capi.';

  @override
  String get batchTapPieceToSkip => 'Tocca un capo per saltarlo.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Foto in studio in arrivo. Puoi uscire: ti avviseremo noi.';

  @override
  String get batchLeaveAction => 'Esci';

  @override
  String get batchPeopleInPhotosTitle => 'Persone nelle foto';

  @override
  String get batchIncludeAction => 'Includi';

  @override
  String get batchSkipAction => 'Salta';

  @override
  String get batchYourPhotoIsUsedLabel => 'La tua foto è in uso';

  @override
  String get batchMakingStudioPhotoLabel => 'Creazione foto in studio';

  @override
  String get batchNoStudioPhotoBody =>
      'Nessuna foto in studio. Viene usata la tua.';

  @override
  String get batchEnterDetailsYourselfAction =>
      'Inserisci i dettagli manualmente';

  @override
  String get batchChooseAnotherPhotoAction => 'Scegli un\'altra foto';

  @override
  String get batchConnectionLostTitle => 'Connessione assente';

  @override
  String get batchConnectionLostBody => 'Controlla la connessione e riprova.';

  @override
  String get batchDailyLimitTitle => 'Limite giornaliero raggiunto';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Passa a Pro per altri scan o inserisci i dettagli manualmente.';

  @override
  String get batchDailyLimitBodyFree =>
      'I tuoi scan si azzerano domani. Puoi inserire i dettagli manualmente ora.';

  @override
  String get batchSeePlansAction => 'Vedi piani';

  @override
  String get batchAiBusyTitle => 'La nostra IA è occupata';

  @override
  String get batchAiBusyBody =>
      'Il problema è nostro. Riprova tra qualche minuto.';

  @override
  String get batchNoPiecesBody =>
      'Prova una foto più nitida o inserisci i dettagli manualmente.';

  @override
  String get batchScanningUnavailableTitle => 'Scansione non disponibile';

  @override
  String get batchScanningUnavailableBody =>
      'Per ora inserisci i dettagli manualmente.';

  @override
  String get batchScanDidNotFinishTitle => 'Scansione non completata';

  @override
  String get batchTryAgainBody => 'Riprova.';

  @override
  String get billingTitle => 'Abbonamento';

  @override
  String get billingUpgradeHeading => 'Aggiorna piano';

  @override
  String get billingUpgradeOnPlusBody => 'Stesse funzioni, limiti più alti.';

  @override
  String get billingUpgradeBody =>
      'Plus e Pro offrono le stesse funzioni. Scegli i limiti che ti servono.';

  @override
  String get billingWebUnavailableBody =>
      'Gli upgrade online non sono ancora disponibili. Un codice promozionale o referral sblocca comunque Plus o Pro. Invita gli amici qui sotto per mesi gratis.';

  @override
  String get billingPlansStale =>
      'Impossibile caricare i piani aggiornati. I prezzi potrebbero non essere corretti.';

  @override
  String get billingMonthly => 'Mensile';

  @override
  String get billingYearly => 'Annuale';

  @override
  String get billingCurrentPlan => 'Piano attuale';

  @override
  String get billingActive => 'Attivo';

  @override
  String get billingThisMonth => 'Questo mese';

  @override
  String get billingItemExtractions => 'Estrazioni capi';

  @override
  String get billingOutfitVisualizations => 'Visualizzazioni outfit';

  @override
  String get billingNearLimitUpgrade =>
      'Sei vicino al limite mensile. Passa a un piano superiore.';

  @override
  String get billingNearLimitResets =>
      'Sei vicino al limite mensile. Si azzera all\'inizio del prossimo mese.';

  @override
  String get billingStoreUnavailable =>
      'Gli aggiornamenti non sono ancora disponibili nello store. Torna a trovarci presto.';

  @override
  String get billingManageHeading => 'Gestisci il tuo piano';

  @override
  String get billingCancelPlan => 'Annulla abbonamento';

  @override
  String get billingCancelKeepsAccess =>
      'Mantenni l\'accesso fino alla fine di questo periodo di fatturazione.';

  @override
  String get billingCancelConfirmTitle => 'Vuoi annullare l\'abbonamento?';

  @override
  String get billingKeepPlan => 'Mantieni il piano';

  @override
  String get billingCancelPlanAction => 'Annulla piano';

  @override
  String get billingBilledMonthly => 'Fatturazione mensile';

  @override
  String get billingBilledYearly => 'Fatturazione annuale';

  @override
  String get billingVirtualTryOn => 'Prova virtuale';

  @override
  String get billingPrioritySupport => 'Supporto prioritario';

  @override
  String get billingDisclosureProRenewing =>
      'Pro è un abbonamento con rinnovo automatico';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus e Pro sono abbonamenti con rinnovo automatico';

  @override
  String get billingDisclosureAppleBilling =>
      'Il pagamento viene addebitato sul tuo ID Apple alla conferma dell\'acquisto.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Il pagamento viene addebitato sul tuo account Google Play alla conferma dell\'acquisto.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Il tuo abbonamento si rinnova automaticamente per lo stesso periodo allo stesso prezzo, a meno che tu non disattivi il rinnovo automatico almeno 24 ore prima della fine del periodo corrente.';

  @override
  String get billingDisclosureAppleManage =>
      'Gestisci o annulla in qualsiasi momento in Impostazioni › tuo ID Apple › Abbonamenti.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gestisci o annulla in qualsiasi momento in Google Play › Pagamenti e abbonamenti.';

  @override
  String get billingReferFriend => 'Invita un amico';

  @override
  String get billingHowItWorks => 'Come funziona';

  @override
  String get billingHowShareTitle => 'Condividi il tuo link';

  @override
  String get billingHowShareBody => 'Invialo a un amico.';

  @override
  String get billingHowSignUpTitle => 'Si iscrivono';

  @override
  String get billingHowSignUpBody => 'Il tuo amico si unisce tramite il link.';

  @override
  String get billingHowBothTitle => 'Avete entrambi Pro';

  @override
  String get billingHowBothBody =>
      'Ognuno di voi riceve un mese di Pro gratis.';

  @override
  String get billingYourReferrals => 'I tuoi inviti';

  @override
  String get billingInvited => 'Invitati';

  @override
  String get billingJoined => 'Iscritti';

  @override
  String get billingMonthsEarned => 'Mesi guadagnati';

  @override
  String get billingInviteFriend => 'Invita un amico';

  @override
  String get billingInviteBody => 'Tu e il tuo amico ricevete un mese di Pro.';

  @override
  String get billingYourCode => 'Il tuo codice';

  @override
  String get billingCopyLink => 'Copia link';

  @override
  String get billingShareInvite => 'Condividi invito';

  @override
  String get giftUnavailable =>
      'Gli inviti regalo non sono disponibili in questa versione.';

  @override
  String get giftPageTitle => 'Regala FitCheck Pro';

  @override
  String get giftNoAllowances => 'Nessun invito regalo disponibile al momento.';

  @override
  String get giftFormTitle => 'Invia un invito gratuito';

  @override
  String get giftFormBody =>
      'Il destinatario riscatta il regalo con questa email verificata. Non invieremo l\'email al posto tuo.';

  @override
  String get giftFieldFrom => 'Da';

  @override
  String get giftFieldRecipientName => 'Nome destinatario';

  @override
  String get giftFieldRecipientEmail => 'Email destinatario';

  @override
  String get giftFieldOccasion => 'Occasione (facoltativa)';

  @override
  String get giftNoOccasion => 'Nessuna occasione';

  @override
  String get giftOccasionBirthday => 'Compleanno';

  @override
  String get giftOccasionAnniversary => 'Anniversario';

  @override
  String get giftOccasionOther => 'Altro';

  @override
  String get giftFieldCardGreeting => 'Messaggio di auguri';

  @override
  String get giftFieldCardGreetingHelper =>
      'Questo apparirà sul biglietto esattamente come scritto.';

  @override
  String get giftFieldPrivateNote => 'Nota privata (facoltativa)';

  @override
  String get giftCreateAction => 'Crea regalo gratuito';

  @override
  String get giftClaimedTitle => 'Regalo riscosso';

  @override
  String get giftClaimedActive => 'Il tuo regalo FitCheck Pro è attivo.';

  @override
  String get giftClaimedQueued =>
      'Il tuo regalo FitCheck Pro inizierà dopo il tuo abbonamento attuale.';

  @override
  String get giftLinkCopied => 'Link regalo copiato negli appunti.';

  @override
  String get giftErrorName => 'Inserisci un nome.';

  @override
  String get giftErrorEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get giftErrorGreeting => 'Inserisci il messaggio di auguri.';

  @override
  String get giftErrorGreetingLength => 'Usa al massimo 80 caratteri.';

  @override
  String get giftClaimAction => 'Riscatta regalo';

  @override
  String get giftCardPreview => 'Anteprima carta';

  @override
  String get giftGiftForYou => 'Un regalo per te';

  @override
  String get giftGiftWaiting => 'Un regalo ti aspetta';

  @override
  String get giftOpenBody =>
      'Apri i tuoi regali per attivarli con la tua email verificata.';

  @override
  String get giftOpenGifts => 'Apri regali';

  @override
  String get giftSendInvitation => 'Invia invito';

  @override
  String get settingsAiProviderSection => 'Provider';

  @override
  String get settingsAiCustom => 'Personalizzato';

  @override
  String get settingsAiUrlHelper =>
      'Usa un URL pubblico accessibile dal server. Localhost non funziona dai nostri server.';

  @override
  String get settingsAiConnectionSection => 'Connessione';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'Chiave API';

  @override
  String get settingsAiApiKeySaved => 'Salvata. Lascia vuoto per mantenerla.';

  @override
  String get settingsAiChatModel => 'Modello chat';

  @override
  String get settingsAiVisionModel => 'Modello visione (opzionale)';

  @override
  String get settingsAiImageModel => 'Modello immagine (opzionale)';

  @override
  String get settingsAiImageModelNote =>
      'La generazione di immagini richiede chat completion compatibili con OpenAI con response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testa connessione';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarGoToToday => 'Vai a oggi';

  @override
  String get calendarConnectTooltip => 'Collega un calendario';

  @override
  String get calendarAddEvent => 'Aggiungi evento';

  @override
  String get calendarEmptyTitle => 'Nessun piano';

  @override
  String get calendarEmptyBody =>
      'Aggiungi un evento e pianifica cosa indossare.';

  @override
  String get calendarPreviousMonth => 'Mese precedente';

  @override
  String get calendarNextMonth => 'Mese successivo';

  @override
  String get calendarAllDay => 'Tutto il giorno';

  @override
  String get calendarOutfitLinked => 'Outfit collegato';

  @override
  String get calendarEventOptions => 'Opzioni evento';

  @override
  String get calendarDeleteTitle => 'Elimina evento?';

  @override
  String get calendarChangeOutfit => 'Cambia outfit';

  @override
  String get calendarLinkOutfit => 'Collega outfit';

  @override
  String get calendarRemoveOutfit => 'Rimuovi outfit';

  @override
  String get calendarNewEvent => 'Nuovo evento';

  @override
  String get calendarEditEvent => 'Modifica evento';

  @override
  String get calendarTitleLabel => 'Titolo';

  @override
  String get calendarTitleRequired => 'Aggiungi un titolo';

  @override
  String get calendarEndBeforeStart => 'Fine dopo l\'inizio';

  @override
  String get calendarStarts => 'Inizio';

  @override
  String get calendarEnds => 'Fine';

  @override
  String get calendarPlaceOptional => 'Luogo (facoltativo)';

  @override
  String get calendarNotesOptional => 'Note (facoltative)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Crea un outfit e collegalo a questo evento.';

  @override
  String get calendarBuildOutfit => 'Crea outfit';

  @override
  String get calendarConnectionsTitle => 'Calendari';

  @override
  String get calendarConnectionsBody =>
      'Gli eventi aggiunti qui restano in FitCheck AI.';

  @override
  String get calendarDisconnect => 'Disconnetti';

  @override
  String get calendarNotAvailable => 'Non ancora disponibile';

  @override
  String get profileSectionExplore => 'Esplora';

  @override
  String get profileNavTryOn => 'Prova';

  @override
  String get profileNavRewards => 'Premi';

  @override
  String get profileSupport => 'Supporto';

  @override
  String get profileHelp => 'Aiuto';

  @override
  String get profileAbout => 'Informazioni';

  @override
  String get profileAboutBody =>
      'Il tuo guardaroba, i tuoi outfit e i tuoi piani in un unico posto.';

  @override
  String get profileSignOutTitle => 'Vuoi uscire?';

  @override
  String get profileSignOutBody =>
      'Potrai accedere nuovamente in qualsiasi momento.';

  @override
  String get profileEditTitle => 'Modifica profilo';

  @override
  String get profileYourProfile => 'Il tuo profilo';

  @override
  String get profileBodyProfiles => 'Profili corporei';

  @override
  String get profileBodyEmptyTitle => 'Nessun profilo';

  @override
  String get profileBodyEmptyBody =>
      'Aggiungi altezza e corporatura per una vestibilità migliore.';

  @override
  String get profileBodyAdd => 'Aggiungi profilo';

  @override
  String get profileBodyDefaultNote =>
      'Il tuo profilo predefinito è usato per la vestibilità e le prove.';

  @override
  String get profileBodyDefaultBadge => 'Predefinito';

  @override
  String get profileBodyMakeDefault => 'Rendi predefinito';

  @override
  String get profileBodyDeleteBody => 'Questa azione non può essere annullata.';

  @override
  String get profileBodyRequired => 'Obbligatorio';

  @override
  String get profileBodyCheckNumber => 'Controlla questo numero';

  @override
  String get profileBodyNew => 'Nuovo profilo';

  @override
  String get profileBodyNameHint => 'Ad esempio, Io';

  @override
  String get profileBodyHeight => 'Altezza';

  @override
  String get profileBodyWeight => 'Peso';

  @override
  String get profileBodyBuild => 'Corporatura';

  @override
  String get profileBodySkinTone => 'Tono di pelle';

  @override
  String get profileBirthDateNeededBody =>
      'Aggiungi una data di nascita per l\'ora di nascita.';

  @override
  String get profileBirthDateNeededTitle => 'Data di nascita richiesta';

  @override
  String get profilePartlySavedBody =>
      'Nome e foto salvati. Dati di nascita non salvati; riprova più tardi.';

  @override
  String get profilePartlySavedTitle => 'Salvato parzialmente';

  @override
  String get profileSavedBody => 'Il tuo profilo è salvato.';

  @override
  String get profileChangePhoto => 'Cambia foto profilo';

  @override
  String get profilePhotoLabel => 'Foto profilo';

  @override
  String get profilePhotoHint => 'Tocca per sceglierne una nuova';

  @override
  String get profileBirthDateLabel => 'Data di nascita (opzionale)';

  @override
  String get profileBirthTimeLabel => 'Ora di nascita (opzionale)';

  @override
  String get profileBirthTimeHelper =>
      'Rende i suggerimenti vedici più precisi';

  @override
  String get profileBirthPlaceLabel => 'Luogo di nascita (opzionale)';

  @override
  String get profileBirthPlaceHint => 'Ad esempio, Milano, Italia';

  @override
  String get profileHelpContactTitle => 'Chiedici qualsiasi cosa';

  @override
  String get profileHelpContactBody =>
      'Invia un messaggio e risponderemo via email, di solito entro un giorno.';

  @override
  String get profileHelpContactAction => 'Contatta il supporto';

  @override
  String get profileHelpFaqTitle => 'Domande frequenti';

  @override
  String get profileFaqAddPiecesTitle =>
      'Come aggiungo capi al mio guardaroba?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tocca Aggiungi capo nella scheda Guardaroba. Scatta una foto o scegline una dalla galleria; troveremo ogni capo e lo eticchetteremo per te.';

  @override
  String get profileFaqMatchingTitle => 'Come funzionano gli abbinamenti?';

  @override
  String get profileFaqMatchingBody =>
      'Apri Per te e seleziona i capi che possiedi. Suggeriremo cosa abbinare e creeremo outfit completi dal tuo guardaroba.';

  @override
  String get profileFaqTryOnTitle => 'Posso usare le mie foto per la prova?';

  @override
  String get profileFaqTryOnBody =>
      'Sì. Aggiungi una tua foto a figura intera, poi scegli i capi per vederli indossati.';

  @override
  String get profileFaqRewardsTitle => 'Come guadagno premi?';

  @override
  String get profileFaqRewardsBody =>
      'Pianifica e registra regolarmente i tuoi outfit. Serie e traguardi aumenteranno man mano che procedi.';

  @override
  String get profileFaqPrivacyTitle => 'Il mio guardaroba è privato?';

  @override
  String get profileFaqPrivacyBody =>
      'Sì. Il tuo guardaroba e i tuoi outfit sono privati a meno che tu non condivida il link a un singolo outfit.';

  @override
  String get profileHelpMoreTitle => 'Altra assistenza';

  @override
  String get profileHelpGuides => 'Guide';

  @override
  String get profileHelpGuidesBody => 'Come funziona ogni funzione';

  @override
  String get feedbackCategoryBug => 'Qualcosa non funziona';

  @override
  String get feedbackCategoryIdea => 'Un\'idea';

  @override
  String get feedbackCategoryGeneral => 'Generale';

  @override
  String get feedbackCategoryHelp => 'Ho bisogno di aiuto';

  @override
  String get feedbackHintBug =>
      'Cosa è successo e cosa ti aspettavi? I passaggi ci aiutano a risolvere il problema.';

  @override
  String get feedbackHintIdea => 'Cosa vorresti e perché?';

  @override
  String get feedbackHintGeneral => 'Dicci cosa ne pensi o fai una domanda.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Puoi aggiungere fino a 5 immagini.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limite raggiunto';

  @override
  String get feedbackImageTooLargeBody =>
      'Scegli un\'immagine inferiore a 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Immagine troppo grande';

  @override
  String get feedbackTitle => 'Invia feedback';

  @override
  String get feedbackAboutLabel => 'Di cosa si tratta?';

  @override
  String get feedbackSubjectLabel => 'Oggetto';

  @override
  String get feedbackSubjectRequired => 'Aggiungi un oggetto';

  @override
  String get feedbackSubjectTooShort =>
      'L\'oggetto deve avere almeno 3 caratteri';

  @override
  String get feedbackDetailsLabel => 'Dettagli';

  @override
  String get feedbackDetailsRequired => 'Aggiungi qualche dettaglio';

  @override
  String get feedbackDetailsTooShort =>
      'La descrizione deve avere almeno 10 caratteri';

  @override
  String get feedbackAddScreenshot => 'Aggiungi uno screenshot';

  @override
  String get feedbackAttachmentHint => 'Fino a 5, max 5 MB ciascuno';

  @override
  String get feedbackSend => 'Invia';

  @override
  String get feedbackEmptyTitle => 'Ancora nessun invio';

  @override
  String get feedbackEmptyBody =>
      'Ciò che invii comparirà qui con il suo stato.';

  @override
  String get feedbackHistoryTitle => 'I tuoi invii';

  @override
  String get feedbackStatusOpen => 'Aperto';

  @override
  String get feedbackStatusInProgress => 'In corso';

  @override
  String get feedbackStatusResolved => 'Risolto';

  @override
  String get feedbackStatusClosed => 'Chiuso';

  @override
  String get legalIntro =>
      'Come proteggiamo i tuoi dati e i termini di utilizzo di FitCheck AI.';

  @override
  String get legalPolicies => 'Politiche';

  @override
  String get legalPrivacySubtitle => 'Cosa raccogliamo e perché';

  @override
  String get legalTermsTitle => 'Termini di servizio';

  @override
  String get legalTermsSubtitle => 'Le regole per l\'utilizzo dell\'app';

  @override
  String get legalLicences => 'Licenze open source';

  @override
  String get legalSupportSubtitle =>
      'Aiuto, contatti e richieste sulla privacy';

  @override
  String get legalReportAbuse => 'Segnala un problema o un abuso';

  @override
  String get permissionCameraTitle => 'Accesso alla fotocamera';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI usa la fotocamera per scattare foto dei tuoi vestiti e outfit per la prova virtuale e l\'organizzazione del guardaroba.';

  @override
  String get permissionPhotoTitle => 'Accesso alle foto';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI ha bisogno di accedere alle tue foto per selezionare immagini di vestiti e outfit per le funzioni IA e il tuo guardaroba.';

  @override
  String get permissionNotNow => 'Non ora';

  @override
  String get permissionOpenSettings => 'Apri impostazioni';

  @override
  String authSignedInAs(String name) {
    return 'Accesso effettuato come $name';
  }

  @override
  String get authSignedIn => 'Accesso effettuato';

  @override
  String get authWelcomeBackTitle => 'Bentornato';

  @override
  String get authSignInFailed => 'Accesso non riuscito';

  @override
  String get authWelcomeTitle => 'Benvenuto';

  @override
  String get authSignUpFailed => 'Registrazione non riuscita';

  @override
  String get authGoogleSignInFailed => 'Accesso con Google non riuscito';

  @override
  String get authAppleSignInFailed => 'Accesso con Apple non riuscito';

  @override
  String get authConfirmEmailTitle => 'Conferma la tua email';

  @override
  String get authConfirmEmailBody =>
      'Controlla la tua posta per l\'email di conferma, poi accedi.';

  @override
  String get authClosetReady => 'Il tuo guardaroba è pronto.';

  @override
  String get authSignedOutTitle => 'Disconnesso';

  @override
  String get authSignedOutBody => 'Hai effettuato la disconnessione.';

  @override
  String get authSignOutFailed => 'Disconnessione non riuscita';

  @override
  String get authEmailSentTitle => 'Email inviata';

  @override
  String get authResetLinkSent =>
      'Controlla la tua email per il link di reset.';

  @override
  String get authPasswordUpdatedTitle => 'Password aggiornata';

  @override
  String get authPasswordUpdated => 'La tua password è aggiornata.';

  @override
  String get authPasswordNotUpdated => 'Password non aggiornata';

  @override
  String get authCouldNotSendEmail => 'Impossibile inviare l\'email';

  @override
  String get authEmailNotSent => 'Email non inviata';

  @override
  String get authResendSentBody =>
      'Abbiamo inviato una nuova email di conferma.';

  @override
  String get outfitPreviewWithAi => 'Anteprima con AI';

  @override
  String get outfitNewPreview => 'Crea nuova anteprima';

  @override
  String get outfitBuilderClosetHeading => 'Il tuo guardaroba';

  @override
  String get outfitBuilderSearchHint => 'Cerca capi';

  @override
  String get outfitClearSearch => 'Pulisci ricerca';

  @override
  String get outfitBuilderAddPiecesTitle => 'Aggiungi prima i capi';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Gli outfit sono creati dai capi del tuo guardaroba.';

  @override
  String get outfitBuilderNoMatches => 'Nessun capo corrispondente.';

  @override
  String get outfitNameLabel => 'Nome outfit';

  @override
  String get outfitNameHint => 'Ad esempio, Lino da weekend';

  @override
  String get outfitPreviewSemantic => 'Anteprima AI dell\'outfit';

  @override
  String get outfitChoosePieces => 'Scegli i capi';

  @override
  String get outfitTapPiecesHint => 'Tocca i capi qui sotto per aggiungerli.';

  @override
  String get outfitShareTooltip => 'Condividi';

  @override
  String get outfitSaveFavourite => 'Salva nei preferiti';

  @override
  String get outfitPiecesHeading => 'Capi';

  @override
  String get outfitWearHistoryEmpty =>
      'Indossalo una volta e le date appariranno qui.';

  @override
  String get outfitWearHistoryTitle => 'Storia di utilizzo';

  @override
  String get outfitWearHistoryError => 'Impossibile caricare le date.';

  @override
  String get outfitWornOn => 'Indossato il';

  @override
  String get outfitEditTitle => 'Modifica outfit';

  @override
  String get outfitSavedPhotosFailed => 'Dettagli salvati, foto no';

  @override
  String get outfitNoPhotosBody =>
      'Nessuna foto. L\'outfit mostra i suoi capi.';

  @override
  String get outfitOccasionLabel => 'Occasione';

  @override
  String get outfitOccasionNone => 'Nessuna';

  @override
  String get outfitTagsHint => 'Separa con virgole';

  @override
  String get outfitDraftBody => 'Nascosto dalla tua lista principale';

  @override
  String get outfitPublic => 'Pubblico';

  @override
  String get outfitPublicBody => 'Chiunque con il link può vederlo';

  @override
  String get outfitDeleteFromDetail =>
      'Elimina questo outfit dalla sua pagina di dettaglio.';

  @override
  String get outfitNewCollection => 'Nuova collezione';

  @override
  String get outfitNoCollectionsTitle => 'Ancora nessuna collezione';

  @override
  String get outfitNoCollectionsBody =>
      'Raggruppa gli outfit per viaggio, stagione o umore.';

  @override
  String get outfitCreateCollection => 'Crea una collezione';

  @override
  String get outfitAddOutfits => 'Aggiungi outfit';

  @override
  String get outfitRename => 'Rinomina';

  @override
  String get outfitCollectionDeleteBody =>
      'Gli outfit contenuti al suo interno vengono mantenuti.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfit non caricati';

  @override
  String get outfitRenameCollection => 'Rinomina collezione';

  @override
  String get outfitDescriptionOptional => 'Descrizione (facoltativa)';

  @override
  String get outfitAllInCollection =>
      'Tutti gli outfit sono già in questa collezione.';

  @override
  String get photoshootSubtitleUpload => 'Ritratti in studio dalle tue foto';

  @override
  String get photoshootSubtitleConfigure => 'Scegli stile, formato e quantità';

  @override
  String get photoshootSubtitleGenerating => 'Occorre un minuto o due';

  @override
  String get photoshootAddPhotosSemantic => 'Aggiungi foto dalla tua galleria';

  @override
  String get photoshootUploadTitle => 'Aggiungi da 1 a 4 tue foto';

  @override
  String get photoshootUploadBody => 'Tocca per scegliere dalla galleria';

  @override
  String get photoshootAddToContinue => 'Aggiungi una foto per continuare';

  @override
  String get photoshootAddAnotherPhoto => 'Aggiungi un\'altra foto';

  @override
  String get photoshootTipsTitle => 'Per risultati migliori';

  @override
  String get photoshootTipsBody =>
      'Usa foto chiare e ben illuminate del tuo viso da diverse angolazioni. Evita occhiali da sole e cappelli.';

  @override
  String get photoshootStarting => 'Avvio';

  @override
  String get photoshootCancelling => 'Annullamento';

  @override
  String get photoshootFailed => 'Errore';

  @override
  String get recommendTabMatches => 'Abiti';

  @override
  String get recommendTabComplete => 'Completa';

  @override
  String get recommendTabWeather => 'Meteo';

  @override
  String get recommendTabColours => 'Colori';

  @override
  String get recommendTabShop => 'Shop';

  @override
  String get recommendNoMatchesTitle => 'Ancora nessun abbinamento';

  @override
  String get recommendNoMatchesBody =>
      'Scegli un capo e ti mostreremo cosa sta bene insieme.';

  @override
  String get recommendPickPiece => 'Scegli un capo';

  @override
  String get recommendNothingMatchesTitle => 'Nessun abbinamento';

  @override
  String get recommendNothingMatchesBody =>
      'Prova altri capi o aggiungi altro al tuo armadio.';

  @override
  String get recommendChangePieces => 'Cambia capi';

  @override
  String get recommendDefaultReason => 'Si adatta ai capi scelti.';

  @override
  String get recommendCompleteTitle => 'Completa il look';

  @override
  String get recommendCompleteBody =>
      'Scegli un capo e noi completiamo il resto.';

  @override
  String get recommendWorking => 'Elaborazione';

  @override
  String get recommendGenerate => 'Genera';

  @override
  String get recommendChooseStyleBody => 'Scegli uno stile, poi genera.';

  @override
  String get recommendNoLooksTitle => 'Nessun look per questi capi';

  @override
  String get recommendNoLooksBody => 'Prova un altro stile o altri capi.';

  @override
  String get recommendDefaultLook => 'Un look per i tuoi capi';

  @override
  String get recommendNoPiecesBody =>
      'Nessun capo disponibile per questo look.';

  @override
  String get recommendCityLabel => 'Città';

  @override
  String get recommendCheck => 'Verifica';

  @override
  String get recommendWeatherTitle => 'Che meteo fa?';

  @override
  String get recommendWeatherBody =>
      'Inserisci la tua città per consigli su cosa indossare oggi.';

  @override
  String get recommendWearToday => 'Da indossare oggi';

  @override
  String get recommendWeatherNoPieces =>
      'Nessun capo nel tuo armadio adatto a questo meteo.';

  @override
  String get recommendBudgetLabel => 'Budget fino a';

  @override
  String get recommendLooking => 'Ricerca';

  @override
  String get recommendFindWhatToBuy => 'Cosa comprare';

  @override
  String get recommendFillGapsTitle => 'Completa il guardaroba';

  @override
  String get recommendFillGapsBody =>
      'Imposta un budget e ti suggeriremo cosa manca nel tuo armadio.';

  @override
  String get recommendNoGapsTitle => 'Nessun vuoto trovato';

  @override
  String get recommendNoGapsBody =>
      'Prova un budget più alto o un\'altra categoria.';

  @override
  String get recommendMoodEveryday => 'Giornaliero';

  @override
  String get recommendMoodBigMeeting => 'Riunione importante';

  @override
  String get recommendDayLabel => 'Giorno';

  @override
  String get recommendReadingStars => 'Lettura degli astri';

  @override
  String get recommendGetMyColours => 'Scopri i miei colori';

  @override
  String get recommendLuckyColoursTitle => 'I tuoi colori fortunati';

  @override
  String get recommendLuckyColoursBody =>
      'Scegli un giorno e ti suggeriremo colori e capi adatti.';

  @override
  String get recommendLuckyColoursSection => 'Colori fortunati';

  @override
  String get recommendAvoidColoursSection => 'Colori da usare con cautela';

  @override
  String get recommendBirthDateTitle => 'Aggiungi la tua data di nascita';

  @override
  String get recommendBirthDateBody =>
      'Serve la data di nascita per analizzare i tuoi colori.';

  @override
  String get recommendEditProfile => 'Modifica profilo';

  @override
  String get recommendNothingThisDay =>
      'Nessun suggerimento per questo giorno.';

  @override
  String get recommendUnnamedColour => 'Colore senza nome';

  @override
  String get recommendFromCloset => 'Dal tuo armadio';

  @override
  String get recommendNoPiecesInColours =>
      'Nessun capo di questi colori al momento.';

  @override
  String get recommendOutfitIdeas => 'Idee per gli outfit';

  @override
  String get recommendNoOutfitsInColours =>
      'Nessun outfit completo con questi colori al momento.';

  @override
  String get recommendDefaultOutfitIdea => 'Un\'idea di outfit';

  @override
  String get recommendPickUpToThree => 'Scegli fino a tre capi';

  @override
  String get recommendEmptyClosetBody =>
      'Aggiungi alcuni capi e torna per le combinazioni.';

  @override
  String get dashboardDressForDay => 'Vestiti per la giornata che ti aspetta.';

  @override
  String get dashboardOutfitOfDay => 'Outfit del giorno';

  @override
  String get dashboardFreshLook => 'Un look fresco';

  @override
  String get subscriptionManageInStoreTitle => 'Gestisci nello store';

  @override
  String get subscriptionManageInStoreBody =>
      'Questo piano è gestito dallo store. Modificalo nelle impostazioni del tuo account.';

  @override
  String get subscriptionCancelledTitle => 'Abbonamento annullato';

  @override
  String get subscriptionCancelledBody =>
      'Il tuo piano rimarrà attivo fino alla fine del periodo di fatturazione.';

  @override
  String get subscriptionCancelFailedTitle => 'Annullamento non riuscito';

  @override
  String get subscriptionCouldNotOpenTitle => 'Impossibile aprire';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Impossibile aprire la gestione delle fatture.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Impossibile aprire il link.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Impossibile caricare il link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Impossibile caricare il link di affiliazione. Riprova.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiato';

  @override
  String get subscriptionReferralCopiedBody => 'Link di affiliazione copiato.';

  @override
  String get subscriptionReferralShareSubject => 'Prova FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Unisciti a FitCheck AI e riceviamo entrambi un mese di Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copiato';

  @override
  String get subscriptionShareUnavailableBody =>
      'Condivisione non disponibile. Link copiato.';

  @override
  String get subscriptionShareFailedTitle => 'Condivisione non riuscita';

  @override
  String get subscriptionShareFailedBody =>
      'Copia il link dalla pagina di affiliazione.';

  @override
  String get subscriptionStoreReadyTitle => 'Store pronto';

  @override
  String get subscriptionStoreReadyBody =>
      'Prezzi store disponibili. Ora puoi passare all\'upgrade.';

  @override
  String get purchaseFailedTitle => 'Acquisto non riuscito';

  @override
  String get purchaseUnavailableTitle => 'Acquisto non disponibile';

  @override
  String get purchaseIapUnavailableBody =>
      'Acquisti in-app non disponibili su questo dispositivo.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Questo piano non è ancora disponibile per l\'acquisto.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Questo piano non è ancora disponibile nello store. Riprova più tardi.';

  @override
  String get purchaseStartFailedBody =>
      'Impossibile avviare l\'acquisto. Riprova.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Il checkout non ha restituito un link di pagamento.';

  @override
  String get purchasePendingTitle => 'Acquisto in attesa';

  @override
  String get purchasePendingBody =>
      'Il tuo acquisto è in attesa di approvazione. Riceverai l\'accesso appena approvato.';

  @override
  String get purchaseFailedBody => 'Acquisto non riuscito. Riprova.';

  @override
  String get purchaseRestoredTitle => 'Ripristinato';

  @override
  String get purchaseRestoredBody => 'Acquisti ripristinati.';

  @override
  String get purchaseActiveTitle => 'Abbonamento attivo';

  @override
  String get purchaseActiveBody => 'Il tuo abbonamento è attivo. Benvenuto.';

  @override
  String get purchaseSignInRequiredTitle => 'Accesso necessario';

  @override
  String get purchaseSignInRequiredBody => 'Accedi per completare l\'acquisto.';

  @override
  String get purchaseErrorTitle => 'Errore di acquisto';

  @override
  String get purchaseInvalidTransactionBody =>
      'L\'acquisto non includeva un ID transazione verificabile.';

  @override
  String get purchaseVerificationPendingTitle => 'Verifica in attesa';

  @override
  String get purchaseVerificationPendingBody =>
      'Non è stato possibile verificare l\'acquisto presso il negozio al momento. Si completerà automaticamente e non verrai addebitato due volte.';

  @override
  String get purchaseNotAppliedTitle => 'Acquisto non applicato';

  @override
  String get purchaseNotAppliedBody =>
      'L\'acquisto non è stato applicato al tuo account. Contatta l\'assistenza e non acquistarlo di nuovo.';

  @override
  String get purchaseRestoreFailedTitle => 'Ripristino non riuscito';

  @override
  String get purchaseRestoreFailedBody =>
      'Impossibile ripristinare gli acquisti. Riprova.';

  @override
  String get purchaseRecoveredActiveBody => 'Il tuo abbonamento è attivo.';

  @override
  String get purchaseCompleteTitle => 'Acquisto completato';

  @override
  String get giftCreateFailedTitle => 'Impossibile creare il regalo';

  @override
  String get giftClaimFailedTitle => 'Impossibile riscuotere il regalo';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regali per te',
      one: 'Un regalo per te',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mese',
      '12': '1 anno',
      'other': '$months mesi',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining rimaste',
      one: '1 rimasta',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration di FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender ti ha inviato $duration di FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Un regalo FitCheck Pro per $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Da $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Per $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Da $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'il tuo destinatario';

  @override
  String get giftPreviewPlaceholderSender => 'tu';

  @override
  String get settingsSavedTitle => 'Salvato';

  @override
  String get settingsNotSavedTitle => 'Non salvato';

  @override
  String get settingsAiChooseProviderBody => 'Scegli un provider.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Un provider personalizzato richiede un URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Inserisci una chiave API.';

  @override
  String get settingsAiSavedBody =>
      'Le tue impostazioni AI sono state salvate.';

  @override
  String get settingsAiMissingDetailsTitle => 'Dettaglio mancante';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Inserisci un URL API e un modello di chat per testare.';

  @override
  String get settingsAiKeyNeededTitle => 'Chiave API necessaria';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Inserisci la tua chiave API per il test. La chiave salvata resta privata.';

  @override
  String get settingsAiKeyToTestBody =>
      'Inserisci la tua chiave API per il test.';

  @override
  String get settingsAiConnectedTitle => 'Connesso';

  @override
  String get settingsAiConnectedBody => 'La connessione funziona.';

  @override
  String get settingsAiTestFailedTitle => 'Test non riuscito';

  @override
  String get settingsPreferencesSavedBody =>
      'Le tue preferenze sono state salvate.';

  @override
  String get settingsPasswordNotChangedTitle => 'Password non modificata';

  @override
  String get settingsOAuthPasswordBody =>
      'Questo account accede con Google o Apple. Usa \"Password dimenticata\" per impostarla prima.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Password corrente non corretta.';

  @override
  String get settingsExportReadyTitle => 'Esportazione pronta';

  @override
  String get settingsExportReadyBody =>
      'L\'esportazione dei tuoi dati è pronta per il download.';

  @override
  String get settingsLinkCopiedTitle => 'Link copiato';

  @override
  String get settingsExportClipboardBody =>
      'Non abbiamo potuto aprire il browser, quindi abbiamo copiato il link di download. Incollalo in un browser presto: scade.';

  @override
  String get settingsExportFailedTitle => 'Esportazione non riuscita';

  @override
  String get settingsAccountNotDeletedTitle => 'Account non eliminato';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Puoi aggiungere fino a $max foto.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limite foto';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Aggiungi almeno una foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Nessuna foto';

  @override
  String get photoshootDescribeLookBody => 'Descrivi il look che desideri.';

  @override
  String get photoshootPromptNeededTitle => 'Richiesto prompt';

  @override
  String get photoshootConsentFeatureLabel => 'Foto con IA';

  @override
  String get photoshootStatusPreparing => 'Preparazione foto';

  @override
  String get photoshootStatusGenerating => 'Generazione';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current di $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done di $total completate';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generazione non riuscita.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready pronte, $failed non riuscite.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Completata in parte';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto pronte.',
      one: '1 foto pronta.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => 'Connessione persa. Riprova.';

  @override
  String get photoshootCouldNotCancelTitle => 'Annullamento non riuscito';

  @override
  String get photoshootRetryFailedTitle => 'Ritentativo non riuscito';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'La foto $number è pronta.';
  }

  @override
  String get photoshootReplacedTitle => 'Sostituita';

  @override
  String get photoshootSavedToGalleryBody => 'Salvata nella tua galleria.';

  @override
  String get photoshootSavedTitle => 'Salvata';

  @override
  String get photoshootNotSavedTitle => 'Non salvata';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tutte le $count foto sono nella tua galleria.',
      one: '1 foto è nella tua galleria.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved di $total salvate.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Alcune foto non salvate';

  @override
  String get tryonConsentFeatureLabel => 'Prova virtuale';

  @override
  String get tryonAvatarUpdatedBody => 'La tua foto è aggiornata.';

  @override
  String get tryonSavedTitle => 'Salvata';

  @override
  String get tryonUploadFailedTitle => 'Caricamento non riuscito';

  @override
  String get tryonChooseGarmentFirstBody => 'Scegli prima la foto dell\'abito.';

  @override
  String get tryonNoGarmentTitle => 'Nessun capo';

  @override
  String get tryonWaitForUploadBody =>
      'Aspetta che il caricamento della foto finisca.';

  @override
  String get tryonStillUploadingTitle => 'Caricamento in corso';

  @override
  String get tryonAddYourPhotoFirstBody => 'Aggiungi prima una foto di te.';

  @override
  String get tryonReadyBody => 'La prova virtuale è pronta.';

  @override
  String get tryonFailedTitle => 'Prova non riuscita';

  @override
  String get tryonSavedToGalleryBody => 'Salvata nella tua galleria.';

  @override
  String get tryonNotSavedTitle => 'Non salvata';

  @override
  String get calendarEventAddedBody => 'Evento aggiunto';

  @override
  String get calendarEventPlannedTitle => 'Pianificato';

  @override
  String get calendarEventSavedBody => 'Evento salvato';

  @override
  String get calendarSavedTitle => 'Salvato';

  @override
  String get calendarEventNotSavedTitle => 'Evento non salvato';

  @override
  String get calendarEventRemovedBody => 'Evento rimosso';

  @override
  String get calendarEventDeletedTitle => 'Eliminato';

  @override
  String get calendarEventNotDeletedTitle => 'Evento non eliminato';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit non collegato';

  @override
  String get calendarLinkedTitle => 'Collegato';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit non rimosso';

  @override
  String get calendarOutfitRemovedBody => 'Outfit rimosso';

  @override
  String get calendarDisconnectedBody => 'Calendario disconnesso';

  @override
  String get calendarDisconnectedTitle => 'Disconnesso';

  @override
  String get calendarNotDisconnectedTitle => 'Calendario non disconnesso';

  @override
  String get calendarTodayLabel => 'oggi';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventi',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'da $start a $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit collegato';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" verrà rimosso.';
  }

  @override
  String get calendarThisAppLabel => 'Questa app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'La sincronizzazione con $provider non è ancora disponibile. Puoi comunque aggiungere eventi qui.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dom';

  @override
  String get calendarWeekdayMonShort => 'Lun';

  @override
  String get calendarWeekdayTueShort => 'Mar';

  @override
  String get calendarWeekdayWedShort => 'Mer';

  @override
  String get calendarWeekdayThuShort => 'Gio';

  @override
  String get calendarWeekdayFriShort => 'Ven';

  @override
  String get calendarWeekdaySatShort => 'Sab';

  @override
  String get calendarWeekdayMonday => 'Lunedì';

  @override
  String get calendarWeekdayTuesday => 'Martedì';

  @override
  String get calendarWeekdayWednesday => 'Mercoledì';

  @override
  String get calendarWeekdayThursday => 'Giovedì';

  @override
  String get calendarWeekdayFriday => 'Venerdì';

  @override
  String get calendarWeekdaySaturday => 'Sabato';

  @override
  String get calendarWeekdaySunday => 'Domenica';

  @override
  String get outfitSavedToFavouritesBody => 'Salvato nei preferiti';

  @override
  String get outfitRemovedFromFavouritesBody => 'Rimosso dai preferiti';

  @override
  String get outfitNotSavedTitle => 'Non salvato';

  @override
  String get outfitLoggedAsWornBody => 'Registrato come indossato oggi.';

  @override
  String get outfitNicePickTitle => 'Ottima scelta';

  @override
  String get outfitRemovedBody => 'Abbinamento rimosso.';

  @override
  String get outfitDeletedTitle => 'Eliminato';

  @override
  String get outfitNotDeletedTitle => 'Non eliminato';

  @override
  String get outfitDuplicatedBody => 'Una copia è nei tuoi abbinamenti.';

  @override
  String get outfitDuplicatedTitle => 'Duplicato';

  @override
  String get outfitNotDuplicatedTitle => 'Non duplicato';

  @override
  String get outfitNotSharedTitle => 'Non condiviso';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" è pronto.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collezione non creata';

  @override
  String get outfitCollectionUpdatedBody => 'Collezione aggiornata.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collezione non aggiornata';

  @override
  String get outfitCollectionDeletedBody => 'Collezione eliminata.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collezione non eliminata';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abbinamenti aggiunti.',
      one: '1 abbinamento aggiunto.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Abbinamenti non aggiunti';

  @override
  String get outfitPreviewNotCreatedTitle => 'Anteprima non creata';

  @override
  String get outfitGiveNameBody => 'Dai un nome all\'abbinamento.';

  @override
  String get outfitNameMissingTitle => 'Nome';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Scegli almeno un capo.';

  @override
  String outfitCreatedBody(String name) {
    return '$name è nei tuoi abbinamenti.';
  }

  @override
  String get outfitSavedTitle => 'Salvato';

  @override
  String get wardrobeAddedToFavouritesBody => 'Aggiunto ai preferiti';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Rimosso dai preferiti';

  @override
  String get wardrobeNotSavedTitle => 'Non salvato';

  @override
  String get wardrobeLoggedAsWornBody => 'Registrato come indossato oggi.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Rimosso dal tuo armadio.';

  @override
  String get wardrobeDeletedTitle => 'Eliminato';

  @override
  String get wardrobeNotDeletedTitle => 'Non eliminato';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pezzi rimossi dal tuo armadio.',
      one: '1 pezzo rimosso dal tuo armadio.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Estrazione Armadio IA';

  @override
  String get itemAddScanJobLabel => 'Scansiona';

  @override
  String get itemAddFoundEarlierBody => 'Trovato in una scansione precedente';

  @override
  String get itemAddLookingAtPhoto => 'Analisi della foto';

  @override
  String get itemAddExtractionFailedBody => 'Estrazione non riuscita';

  @override
  String get itemAddJobFailedBody => 'Operazione non riuscita';

  @override
  String get itemAddConnectionLostBody => 'Connessione persa. Riprova.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Connessione persa durante l\'elaborazione.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Pezzo $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Pezzo';

  @override
  String get itemAddNotCancelledTitle => 'Non annullato';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pezzi sono nel tuo armadio.',
      one: '1 pezzo è nel tuo armadio.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved di $total pezzi salvati. Tocca salva per riprovare con il resto.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Alcuni pezzi non salvati';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Scegli almeno una foto.';

  @override
  String get batchPhotoUnreadableBody => 'Impossibile leggere questa foto.';

  @override
  String get batchNoPhotosReadableBody =>
      'Impossibile leggere nessuna di queste foto. Prova con altre foto.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Connessione persa durante l\'elaborazione. Riprova.';

  @override
  String get batchNotCancelledTitle => 'Non annullato';

  @override
  String get batchPostLinkUnsupportedBody =>
      'I link dei post non sono supportati. Inserisci un link del profilo.';

  @override
  String get batchLinkSpacesBody => 'I link non possono contenere spazi.';

  @override
  String get batchEnterProfileLinkBody =>
      'Inserisci un link di profilo Instagram o Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Inserisci un link di profilo.';

  @override
  String get batchSignInPageNotOpenBody =>
      'La pagina di accesso non si è aperta. Riprova.';

  @override
  String get batchSignInBrowserBody =>
      'Accedi nel browser, poi torna su FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Collega il tuo account';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Inserisci il codice dall\'app di autenticazione.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram richiede una verifica di sicurezza. Accedi prima nel browser.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Inserisci di nuovo nome utente e password.';

  @override
  String get batchSignInFailedBody =>
      'Accesso non riuscito. Controlla nome utente e password.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Accedi per continuare l\'importazione.';

  @override
  String get batchAccountNotConnectedBody =>
      'Il tuo account non è stato collegato.';

  @override
  String get batchAccountConnectedTitle => 'Account collegato';

  @override
  String get batchNotConnectedTitle => 'Non collegato';

  @override
  String get batchImportConnectionLostBody =>
      'La connessione di importazione è stata interrotta. Aggiorna per verificare.';

  @override
  String batchPickUpToBody(int max) {
    return 'Scegli fino a $max foto. Troviamo i capi.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count di $total foto';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparazione foto $done di $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trova capi in $count foto',
      one: 'Trova capi in 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Il tuo account $platform usa l\'accesso in due fasi. Inserisci il codice a 6 cifre dall\'app di autenticazione.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Questo profilo $platform è privato o richiede l\'accesso per mostrare le foto.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Collega con $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto trovate finora',
      one: '1 foto trovata finora',
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
    return '$processed di $total elaborate · $added aggiunte · $waiting in attesa · $skipped saltate';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Scansione foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number in seguito';
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
      other: '$count capi trovati',
      one: '1 capo trovato',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto sono state aggiunte al tuo guardaroba.',
      one: '1 foto è stata aggiunta al tuo guardaroba.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count altre foto studio in arrivo. Puoi salvare quelle pronte o uscire — ti avviseremo.',
      one:
          'Un\'altra foto studio in arrivo. Puoi salvare quella pronta o uscire — ti avviseremo.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Non salvate ancora: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces capi',
      one: '1 capo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos foto',
      one: '1 foto',
    );
    return '$_temp0 da $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen selezionati. Tocca un capo per saltarlo.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvataggio di $count capi',
      one: 'Salvataggio di 1 capo',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salva $count capi',
      one: 'Salva 1 capo',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Il tuo profilo corporeo è stato salvato.';

  @override
  String get bodyProfileSavedTitle => 'Salvato';

  @override
  String get bodyProfileNotSavedTitle => 'Non salvato';

  @override
  String get bodyProfileSetDefaultBody => 'Imposta come profilo predefinito.';

  @override
  String get bodyProfileDeletedBody => 'Profilo corporeo eliminato.';

  @override
  String get bodyProfileDeletedTitle => 'Eliminato';

  @override
  String get bodyProfileNotDeletedTitle => 'Non eliminato';

  @override
  String get feedbackNotSentTitle => 'Non inviato';

  @override
  String get feedbackSentBody =>
      'Grazie. Leggiamo ogni messaggio e rispondiamo se serve altro.';

  @override
  String get feedbackSentTitle => 'Feedback inviato';

  @override
  String get recommendUnnamedPiece => 'Capo senza nome';

  @override
  String get recommendEnterCityBody =>
      'Inserisci la tua città per ricevere proposte in base al meteo.';

  @override
  String get recommendWhichCityTitle => 'Quale città?';

  @override
  String get aiConsentSheetTitle =>
      'Condivisione delle foto con un servizio AI';

  @override
  String get aiConsentSheetBody =>
      'Per creare le tue immagini di prova e foto, FitCheck AI invia le foto che fornisci (inclusi volti e corpo) a un provider AI di terze parti fidato (come OpenAI o Google Gemini) per l\'elaborazione. Generano le tue immagini e non le usano per addestrare i loro modelli secondo i nostri termini. Le foto vengono trasmesse in modo sicuro e non condivise mai per pubblicità.';

  @override
  String get aiConsentSheetPermission =>
      'Continuando, dai autorizzazione esplicita a condividere le tue foto con questi provider AI per la generazione di immagini.';

  @override
  String get skeletonsLoadMoreFailed => 'Impossibile caricare altro.';

  @override
  String get jobsPiecesReadyTitle => 'I tuoi capi sono pronti';

  @override
  String get jobsScanStoppedTitle => 'La scansione si è interrotta';

  @override
  String get jobsNothingSavedBody => 'Niente è stato salvato. Riprova.';

  @override
  String get jobsPhotoUploadFailedBody => 'Caricamento foto non riuscito.';

  @override
  String get authGoogleSignInStartFailed =>
      'Impossibile avviare l\'accesso con Google. Riprova.';

  @override
  String get referralAppliedTitle => 'Riferimento applicato!';

  @override
  String get billingStoreUnavailableBody =>
      'Acquisti dello store non disponibili su questo dispositivo.';

  @override
  String get billingPurchaseProcessingBody =>
      'Questo acquisto è ancora in lavorazione. Riapri l\'app tra un minuto per vedere il tuo piano.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Il caricamento dell\'avatar non ha restituito un URL dell\'immagine.';

  @override
  String get rewardsDayStreakLabel => 'giorni di seguito';

  @override
  String rewardsBestStreak(int days) {
    return 'Migliore serie di $days giorni';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Accesso a $permission necessario';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'L\'accesso a $permission è attualmente negato. Apri Impostazioni per consentirlo, poi torna e riprova.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Passo $step di 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Passo $step di $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Rimuovi immagine $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Rimuovi immagine $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Invia una email a $email. Esaminiamo le segnalazioni entro 24 ore.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Rimuovi $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Aggiungi a \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" è stato rimosso. I pezzi restano nel tuo armadio.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Mostra tutti $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count rimaste oggi';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index non riuscita';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected di $max foto';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Corpo $shape · Pelle $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Eliminare $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opzioni per $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Più indossati: $name, $count volte';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: non impostato';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% di corrispondenza';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked di $max selezionati';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Rimuovi $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Priorità $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Questo piano è addebitato tramite $store. Modificalo o annullalo nelle impostazioni del tuo account $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gestisci in $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current di $max utilizzati';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Circa ${seconds}s rimanenti';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done di $total foto studio pronte';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready di $total foto studio pronte. Tocca un pezzo per saltarlo.';
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
  String get profileFieldNotSet => 'No';
}
