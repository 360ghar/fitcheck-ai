// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Αρχική';

  @override
  String get tabPhotoshoot => 'Φωτογράφιση';

  @override
  String get tabCloset => 'Ντουλάπα';

  @override
  String get tabOutfits => 'Σύνολα';

  @override
  String get tabMore => 'Περισσότερα';

  @override
  String get actionAddItem => 'Προσθήκη';

  @override
  String get actionCreateOutfit => 'Νέο σύνολο';

  @override
  String get actionCancel => 'Ακύρωση';

  @override
  String get actionDelete => 'Διαγραφή';

  @override
  String get actionSave => 'Αποθήκευση';

  @override
  String get actionRetry => 'Επαναπροσπάθεια';

  @override
  String get actionDone => 'Τέλος';

  @override
  String get actionNext => 'Επόμενο';

  @override
  String get actionBack => 'Πίσω';

  @override
  String get actionClose => 'Κλείσιμο';

  @override
  String get actionSearch => 'Αναζήτηση';

  @override
  String get actionContinue => 'Συνέχεια';

  @override
  String get stateLoading => 'Φόρτωση';

  @override
  String get stateErrorTitle => 'Κάτι πήγε στραβά';

  @override
  String get stateErrorBody =>
      'Δοκιμάστε ξανά. Αν το πρόβλημα επιμένει, επικοινωνήστε με την υποστήριξη.';

  @override
  String get stateOfflineTitle => 'Χωρίς σύνδεση';

  @override
  String get stateOfflineBody =>
      'Συνδεθείτε για συγχρονισμό της ντουλάπας και δημιουργία συνόλων.';

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get settingsAccountSection => 'Λογαριασμός';

  @override
  String get settingsPreferencesSection => 'Προτιμήσεις';

  @override
  String get settingsPlanBilling => 'Συνδρομή και χρέωση';

  @override
  String get settingsLanguage => 'Γλώσσα';

  @override
  String get settingsNotifications => 'Ειδοποιήσεις';

  @override
  String get settingsUnits => 'Μονάδες μέτρησης';

  @override
  String get settingsAppearance => 'Εμφάνιση';

  @override
  String get settingsPrivacySection => 'Απόρρητο και δεδομένα';

  @override
  String get settingsAboutSection => 'Σχετικά';

  @override
  String get settingsSignOut => 'Αποσύνδεση';

  @override
  String get settingsDeleteAccount => 'Διαγραφή λογαριασμού';

  @override
  String get settingsDeleteAccountTitle => 'Διαγραφή λογαριασμού;';

  @override
  String get settingsDeleteAccountBody =>
      'Αυτό διαγράφει τη ντουλάπα, τα σύνολα, τις φωτογραφίες και το προφίλ σας. Η ενέργεια δεν αναιρείται.';

  @override
  String get settingsUnitsImperial => 'Αγγλικό σύστημα (in, lb)';

  @override
  String get settingsUnitsMetric => 'Μετρικό σύστημα (cm, kg)';

  @override
  String get languageTitle => 'Γλώσσα';

  @override
  String get languageSystem => 'Γλώσσα συσκευής';

  @override
  String get languageSystemBody =>
      'Το FitCheck AI ακολουθεί τη γλώσσα του τηλεφώνου σας.';

  @override
  String get languageSearchHint => 'Αναζήτηση γλώσσας';

  @override
  String get languageCurrent => 'Τρέχουσα';

  @override
  String get languageReviewNote =>
      'Αυτή η μετάφραση είναι νέα. Ενημερώστε μας αν κάτι δεν ακούγεται σωστό.';

  @override
  String get languageChanged => 'Η γλώσσα ενημερώθηκε';

  @override
  String get paywallTitle => 'Επιλέξτε πλάνο';

  @override
  String get paywallTrialBadge => '1 μήνας δωρεάν';

  @override
  String get paywallTrialTitle => 'Ο πρώτος μήνας Pro είναι δωρεάν';

  @override
  String get paywallTrialBody =>
      'Ανεβάστε όλη τη ντουλάπα σας τώρα. Προσθέστε κομμάτια αργότερα.';

  @override
  String get paywallFreeForeverTitle => 'Δωρεάν για πάντα';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Χωρίς κάρτα. Κάθε μήνα παίρνετε $uploads μεταφορτώσεις AI, $outfits σύνολα και $images εικόνες φωτογράφισης την ημέρα.';
  }

  @override
  String get paywallCtaTrial => 'Δωρεάν δοκιμή 1 μήνα';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Αναβάθμιση σε $plan';
  }

  @override
  String get paywallRestore => 'Επαναφορά αγορών';

  @override
  String get paywallManage => 'Διαχείριση συνδρομής';

  @override
  String get paywallTerms => 'Όροι χρήσης';

  @override
  String get paywallPrivacy => 'Πολιτική απορρήτου';

  @override
  String get paywallPerMonth => 'το μήνα';

  @override
  String get paywallPerYear => 'το έτος';

  @override
  String get paywallBestValue => 'Καλύτερη αξία';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Δωρεάν δοκιμή μόνο για νέους συνδρομητές. Μετά τη δοκιμή, το Pro ανανεώνεται στα $price εκτός αν ακυρωθεί τουλάχιστον 24 ώρες πριν τη λήξη του.';
  }

  @override
  String get introTitle => 'Η ντουλάπα σου, επιτέλους οργανωμένη';

  @override
  String get introBody =>
      'Φωτογράφισε τα ρούχα σου μία φορά. Πάρε ιδέες για σύνολα, προεπισκοπήσεις δοκιμής και φωτογραφίες στούντιο από όσα ήδη έχεις.';

  @override
  String get introStart => 'Ξεκίνησε';

  @override
  String get introHaveAccount => 'Έχω ήδη λογαριασμό';

  @override
  String get introSkip => 'Παράλειψη';

  @override
  String get authSignIn => 'Σύνδεση';

  @override
  String get authSignUp => 'Δημιουργία λογαριασμού';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Κωδικός';

  @override
  String get authForgotPassword => 'Ξέχασες τον κωδικό σου;';

  @override
  String get authContinueApple => 'Συνέχεια με Apple';

  @override
  String get authContinueGoogle => 'Συνέχεια με Google';

  @override
  String get authOrDivider => 'ή';

  @override
  String get wardrobeTitle => 'Ντουλάπα';

  @override
  String get wardrobeEmptyTitle => 'Η ντουλάπα σου είναι άδεια';

  @override
  String get wardrobeEmptyBody =>
      'Πρόσθεσε το πρώτο σου κομμάτι ή ανέβασε μια φωτογραφία ολόκληρης της κρεμάστρας με τη μία.';

  @override
  String get wardrobeAddFirst => 'Πρόσθεσε το πρώτο σου είδος';

  @override
  String get wardrobeSearchHint => 'Αναζήτηση στη ντουλάπα';

  @override
  String get categoryTops => 'Τοπ';

  @override
  String get categoryBottoms => 'Κάτω μέρος';

  @override
  String get categoryShoes => 'Παπούτσια';

  @override
  String get categoryAccessories => 'Αξεσουάρ';

  @override
  String get categoryOuterwear => 'Πάνω ρούχα';

  @override
  String get categorySwimwear => 'Μαγιό';

  @override
  String get categoryActivewear => 'Αθλητικά';

  @override
  String get categoryOther => 'Άλλα';

  @override
  String get conditionClean => 'Καθαρό';

  @override
  String get conditionDirty => 'Βρόμικο';

  @override
  String get conditionLaundry => 'Για πλύσιμο';

  @override
  String get conditionRepair => 'Χρειάζεται επιδιορθώσεις';

  @override
  String get conditionDonate => 'Για δωρεά';

  @override
  String get seasonSpring => 'Άνοιξη';

  @override
  String get seasonSummer => 'Καλοκαίρι';

  @override
  String get seasonFall => 'Φθινόπωρο';

  @override
  String get seasonWinter => 'Χειμώνας';

  @override
  String get seasonAll => 'Όλες οι εποχές';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Επίσημο';

  @override
  String get styleBusiness => 'Επαγγελματικό';

  @override
  String get styleSporty => 'Σπορ';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalist';

  @override
  String get styleRomantic => 'Ρομαντικό';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Κλασικό';

  @override
  String get styleElegant => 'Κομψό';

  @override
  String get styleOther => 'Άλλο';

  @override
  String get occasionWork => 'Δουλειά';

  @override
  String get occasionDateNight => 'Βραδινή έξοδος';

  @override
  String get occasionTravel => 'Ταξίδι';

  @override
  String get occasionWedding => 'Γάμος';

  @override
  String get occasionGym => 'Γυμναστήριο';

  @override
  String get occasionWeekend => 'Σαββατοκύριακο';

  @override
  String get occasionParty => 'Πάρτι';

  @override
  String get occasionInterview => 'Συνέντευξη';

  @override
  String get colorBlack => 'Μαύρο';

  @override
  String get colorWhite => 'Λευκό';

  @override
  String get colorGrey => 'Γκρι';

  @override
  String get colorNavy => 'Μπλε σκούρο';

  @override
  String get colorBrown => 'Καφέ';

  @override
  String get colorRed => 'Κόκκινο';

  @override
  String get colorBlue => 'Μπλε';

  @override
  String get colorGreen => 'Πράσινο';

  @override
  String get colorPink => 'Ροζ';

  @override
  String get colorPurple => 'Μωβ';

  @override
  String get colorYellow => 'Κίτρινο';

  @override
  String get colorOrange => 'Πορτοκαλί';

  @override
  String get colorBeige => 'Μπεζ';

  @override
  String get dateToday => 'Σήμερα';

  @override
  String get dateYesterday => 'Χθες';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Πριν από $count ημέρες',
      one: 'Πριν από 1 ημέρα',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Πριν από $count εβδομάδες',
      one: 'Πριν από 1 εβδομάδα',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Πριν από $count μήνες',
      one: 'Πριν από 1 μήνα',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Πριν από $count χρόνια',
      one: 'Πριν από 1 χρόνο',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Σας αρέσει το FitCheck AI;';

  @override
  String get ratingPromptBody =>
      'Μια γρήγορη βαθμολογία βοηθά άλλους να βρουν το στυλ τους.';

  @override
  String get ratingPromptYes => 'Βαθμολόγηση';

  @override
  String get ratingPromptNo => 'Όχι τώρα';

  @override
  String get closetNoMatchesTitle => 'Κανένα ρούχο';

  @override
  String get closetNoMatchesBody =>
      'Δοκιμάστε λιγότερα φίλτρα ή άλλη αναζήτηση.';

  @override
  String get closetClearFilters => 'Καθαρισμός φίλτρων';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ρούχα',
      one: '1 ρούχο',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Φόρτωση ρούχων';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count επιλεγμένα',
      one: '1 επιλεγμένο',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Διαγραφή επιλεγμένων';

  @override
  String get closetCancelSelection => 'Ακύρωση επιλογής';

  @override
  String get closetCloseSearch => 'Κλείσιμο αναζήτησης';

  @override
  String get closetShowGrid => 'Προβολή σε πλέγμα';

  @override
  String get closetShowList => 'Προβολή σε λίστα';

  @override
  String get closetShowRows => 'Προβολή σε σειρές';

  @override
  String get closetStatsTitle => 'Στατιστικά γκαρνταρόμπας';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Διαγραφή $count ρούχων;',
      one: 'Διαγραφή 1 ρούχου;',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Τα σύνολα που τα χρησιμοποιούν θα τα χάσουν.';

  @override
  String get closetSortBy => 'Ταξινόμηση κατά';

  @override
  String get closetFavourites => 'Αγαπημένα';

  @override
  String get closetFavourite => 'Αγαπημένο';

  @override
  String get closetUnfavourite => 'Αφαίρεση από αγαπημένα';

  @override
  String get closetWoreToday => 'Φορέθηκε σήμερα';

  @override
  String closetWornTimes(int count) {
    return 'Φορέθηκε $count×';
  }

  @override
  String get closetCategoryLabel => 'Κατηγορία';

  @override
  String get closetUseCaseLabel => 'Περίσταση';

  @override
  String get closetAnyUseCase => 'Οποιαδήποτε';

  @override
  String get closetOtherUseCase => 'Άλλη περίσταση';

  @override
  String get closetOtherUseCaseHint => 'Για παράδειγμα, brunch';

  @override
  String get closetUseUseCase => 'Χρήση';

  @override
  String get closetClearAll => 'Καθαρισμός όλων';

  @override
  String get sortNewest => 'Νεότερα πρώτα';

  @override
  String get sortOldest => 'Παλαιότερα πρώτα';

  @override
  String get sortName => 'Όνομα (A–Z)';

  @override
  String get sortMostWorn => 'Περισσότερο φορεμένα';

  @override
  String get useCaseInformal => 'Casual';

  @override
  String get useCaseDate => 'Ραντεβού';

  @override
  String get useCaseDinner => 'Βραδινή έξοδος';

  @override
  String get useCaseLunch => 'Μεσημεριανό';

  @override
  String get actionSelect => 'Επιλογή';

  @override
  String get actionEdit => 'Επεξεργασία';

  @override
  String get actionFilter => 'Φίλτρο';

  @override
  String get actionSort => 'Ταξινόμηση';

  @override
  String get actionAll => 'Όλα';

  @override
  String get dashboardStartClosetTitle => 'Οργάνωσε την ντουλάπα σου';

  @override
  String get dashboardStartClosetBody =>
      'Φωτογράφισε μερικά κομμάτια. Τα ταξινομούμε για σένα.';

  @override
  String get dashboardPieces => 'κομμάτια';

  @override
  String get dashboardOutfits => 'σύνολα';

  @override
  String get dashboardDayStreak => 'μέρες σερί';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count αυτόν τον μήνα';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Καλύτερο $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αγαπημένα',
      one: '1 αγαπημένο',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αποθηκευμένα σύνολα',
      one: '1 αποθηκευμένο σύνολο',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Πιο φορεμένο: $name, $count φορές';
  }

  @override
  String get setupSkip => 'Παράλειψη ρύθμισης';

  @override
  String get setupWhoTitle => 'Ποιον κάνουμε styling;';

  @override
  String get setupWhoBody =>
      'Ορίζει το μοντέλο για δοκιμή και φωτογραφήσεις. Μπορείς να το αλλάξεις στο προφίλ σου.';

  @override
  String get setupStyleTitle => 'Τι φοράς πιο συχνά;';

  @override
  String get setupStyleBody =>
      'Επέλεξε όποιο θέλεις. Οι ιδέες για σύνολα ξεκινούν από εδώ.';

  @override
  String get setupClosetTitle => 'Πρόσθεσε τα πρώτα σου κομμάτια.';

  @override
  String get setupClosetBody =>
      'Φωτογράφισε μερικά ρούχα ή μια στοίβα από αυτά. Κάθε κομμάτι απομονώνεται και αποθηκεύεται για σένα.';

  @override
  String get setupAddClothes => 'Προσθήκη ρούχων';

  @override
  String get setupStylesLabel => 'Στυλ';

  @override
  String get setupOccasionsLabel => 'Περιστάσεις';

  @override
  String get setupSkipStep => 'Παράλειψη';

  @override
  String get setupLater => 'Αργότερα';

  @override
  String get setupSaveError => 'Αδυναμία αποθήκευσης';

  @override
  String get genderWomen => 'Γυναικεία';

  @override
  String get genderMen => 'Ανδρικά';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Χωρίς απάντηση';

  @override
  String get outfitEmptyTitle => 'Δεν υπάρχουν σύνολα ακόμη';

  @override
  String get outfitEmptyBody =>
      'Συνδύασε κομμάτια από την ντουλάπα σου και αποθήκευσε το λουκ.';

  @override
  String get outfitNoMatchesTitle => 'Κανένα σύνολο δεν ταιριάζει';

  @override
  String get outfitSearchHint => 'Αναζήτηση στα σύνολά σου';

  @override
  String get outfitLoading => 'Φόρτωση συνόλων';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count σύνολα',
      one: '1 σύνολο',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Στυλ και εποχή';

  @override
  String get outfitCollections => 'Συλλογές';

  @override
  String get outfitDuplicate => 'Αντίγραφο';

  @override
  String get outfitDeleteTitle => 'Διαγραφή αυτού του συνόλου;';

  @override
  String get outfitDeleteBody =>
      'Τα κομμάτια του παραμένουν στην ντουλάπα σου.';

  @override
  String get outfitDrafts => 'Πρόχειρα';

  @override
  String get outfitDraft => 'Πρόχειρο';

  @override
  String get filterStyle => 'Στυλ';

  @override
  String get filterSeason => 'Εποχή';

  @override
  String get itemDetailDeleteTitle => 'Διαγραφή αυτού του κομματιού;';

  @override
  String get itemDetailDeleteBody =>
      'Τα σύνολα που το χρησιμοποιούν θα το χάσουν.';

  @override
  String get itemAddFavourite => 'Προσθήκη στα αγαπημένα';

  @override
  String itemSize(String size) {
    return 'Μέγεθος $size';
  }

  @override
  String get itemColours => 'Χρώματα';

  @override
  String get itemMaterial => 'Υλικό';

  @override
  String get itemPattern => 'Μοτίβο';

  @override
  String get itemUseCases => 'Περιπτώσεις χρήσης';

  @override
  String get itemKeptIn => 'Φυλάσσεται σε';

  @override
  String get itemPrice => 'Τιμή';

  @override
  String get itemBought => 'Αγοράστηκε';

  @override
  String get itemTags => 'Ετικέτες';

  @override
  String get itemAdded => 'Προστέθηκε';

  @override
  String get itemTimesWornLabel => 'φορές';

  @override
  String get itemLastWornLabel => 'τελευταία φορά';

  @override
  String get itemNeverWorn => 'Ποτέ';

  @override
  String get authEntryBody =>
      'Κάθε ρούχο που έχεις, σε συνδυασμούς από το FitCheck AI. Οργάνωσε σύνολα, δοκίμασέ τα, φωτογράφισέ τα.';

  @override
  String get authCreateCloset => 'Δημιουργία ντουλάπας';

  @override
  String get authWelcomeBack => 'Καλώς ήρθες ξανά';

  @override
  String get authSignInBody => 'Συνδέσου για να ανοίξεις τη ντουλάπα σου.';

  @override
  String get authCreateAccount => 'Δημιουργία λογαριασμού';

  @override
  String get authCreateClosetBody =>
      'Παίρνει ένα λεπτό. Τα πρώτα σου ρούχα είναι δωρεάν.';

  @override
  String get authName => 'Όνομα';

  @override
  String get authConfirmPassword => 'Επιβεβαίωση κωδικού';

  @override
  String get authReferralCode => 'Κωδικός σύστασης (προαιρετικά)';

  @override
  String get authResetTitle => 'Επαναφορά κωδικού';

  @override
  String get authResetBody =>
      'Θα σου στείλουμε ένα link με email για να ορίσεις νέο κωδικό.';

  @override
  String get authSendResetLink => 'Αποστολή link';

  @override
  String get authBackToSignIn => 'Επιστροφή στη σύνδεση';

  @override
  String get authEnterEmail => 'Εισήγαγε το email σου';

  @override
  String get authEnterValidEmail => 'Εισήγαγε έγκυρο email';

  @override
  String get authEnterPassword => 'Εισήγαγε τον κωδικό σου';

  @override
  String get authPasswordTooShort => 'Τουλάχιστον 6 χαρακτήρες';

  @override
  String get authShowPassword => 'Εμφάνιση κωδικού';

  @override
  String get authHidePassword => 'Απόκρυψη κωδικού';

  @override
  String get authNewHere => 'Νέος χρήστης;';

  @override
  String authConfirmEmail(String email) {
    return 'Επιβεβαίωσε το $email πριν συνδεθείς. Έλεγξε τα εισερχόμενά σου.';
  }

  @override
  String get authResendEmail => 'Αποστολή ξανά';

  @override
  String get authResendingEmail => 'Αποστολή…';

  @override
  String get authPasswordsDoNotMatch => 'Οι κωδικοί δεν ταιριάζουν';

  @override
  String get authEnterName => 'Εισήγαγε το όνομά σου';

  @override
  String get authChoosePassword => 'Επέλεξε κωδικό';

  @override
  String get authHaveAccount => 'Έχεις λογαριασμό;';

  @override
  String get authCodeAccepted => 'Ο κωδικός έγινε δεκτός';

  @override
  String get authCodeNotFound => 'Ο κωδικός δεν βρέθηκε';

  @override
  String authReferralFrom(String name) {
    return 'Από τον/την $name. Κερδίζετε και οι δύο έναν μήνα δωρεάν.';
  }

  @override
  String get authReferralInvalid => 'Δεν βρέθηκε αυτός ο κωδικός.';

  @override
  String authResetSent(String email) {
    return 'Εστάλη στο $email. Άνοιξε το link σε αυτό το κινητό.';
  }

  @override
  String get introSlide1Title => 'Φωτογράφισε τη ντουλάπα σου.';

  @override
  String get introSlide1Body =>
      'Βγάλε μια στοίβα ρούχα φωτογραφία. Κάθε κομμάτι αποκόπτεται και αποθηκεύεται αυτόματα.';

  @override
  String get introSlide2Title => 'Ντύσου πιο γρήγορα.';

  @override
  String get introSlide2Body =>
      'Σύνολα από τα ρούχα σου, ταιριασμένα με το πρόγραμμα και τον καιρό.';

  @override
  String get introSlide3Title => 'Δες το πριν το φορέσεις.';

  @override
  String get introSlide3Body =>
      'Δοκίμασε σύνολα στη φωτογραφία σου ή φωτογράφισέ τα σαν καμπάνια.';

  @override
  String get settingsTheme => 'Θέμα';

  @override
  String get settingsThemeSystem => 'Συστήματος';

  @override
  String get settingsThemeLight => 'Ανοιχτό';

  @override
  String get settingsThemeDark => 'Σκοτεινό';

  @override
  String get settingsTemperature => 'Θερμοκρασία';

  @override
  String get settingsEmailUpdates => 'Ενημερώσεις μέσω email';

  @override
  String get settingsEmailUpdatesBody => 'Νέα και συμβουλές στο email σου';

  @override
  String get settingsOutfitReminders => 'Υπενθυμίσεις συνόλων';

  @override
  String get settingsOutfitRemindersBody =>
      'Μια υπενθύμιση να καταγράφεις τι φόρεσες';

  @override
  String get settingsWeeklySummary => 'Εβδομαδιαία σύνοψη';

  @override
  String get settingsWeeklySummaryBody => 'Η εβδομάδα σου σε σύνολα';

  @override
  String get settingsStyleSection => 'Στυλ';

  @override
  String get settingsPreferredStyles => 'Στυλ που προτιμάς';

  @override
  String get settingsPreferredColours => 'Χρώματα που προτιμάς';

  @override
  String get settingsNoneChosen => 'Δεν επιλέχθηκε κανένα';

  @override
  String get settingsPlanAiSection => 'Πρόγραμμα και AI';

  @override
  String get settingsPlanBillingBody => 'Πρόγραμμα, χρεώσεις και αναβάθμιση';

  @override
  String get settingsPlanUsageBody => 'Πρόγραμμα και χρήση';

  @override
  String get settingsInviteFriends => 'Πρόσκληση φίλων';

  @override
  String get settingsInviteFriendsBody =>
      'Ένας δωρεάν μήνας για κάθε φίλο που εγγράφεται';

  @override
  String get settingsAiProvider => 'Πάροχος AI';

  @override
  String get settingsAiProviderBody =>
      'Χρησιμοποιήστε το δικό σας μοντέλο για ετικέτες και εικόνες';

  @override
  String get settingsAppVersion => 'Έκδοση εφαρμογής';

  @override
  String get settingsPrivacyTerms => 'Απόρρητο και όροι';

  @override
  String get settingsReportProblem => 'Αναφορά προβλήματος';

  @override
  String get settingsChangePassword => 'Αλλαγή κωδικού πρόσβασης';

  @override
  String get settingsExportData => 'Εξαγωγή δεδομένων';

  @override
  String get settingsExportBody =>
      'Ετοιμάζουμε ένα αρχείο με όσα αποθηκεύσατε και ανοίγουμε τη λήψη.';

  @override
  String get settingsExportAction => 'Εξαγωγή';

  @override
  String get settingsCurrentPassword => 'Τρέχων κωδικός πρόσβασης';

  @override
  String get settingsNewPassword => 'Νέος κωδικός πρόσβασης';

  @override
  String get settingsConfirmNewPassword => 'Επιβεβαίωση νέου κωδικού';

  @override
  String get settingsEnterCurrentPassword =>
      'Εισαγάγετε τον τρέχοντα κωδικό σας';

  @override
  String get settingsEnterNewPassword => 'Εισαγάγετε νέο κωδικό';

  @override
  String get settingsPasswordMin8 => 'Χρησιμοποιήστε τουλάχιστον 8 χαρακτήρες';

  @override
  String get settingsPasswordNeedsUpper => 'Προσθέστε ένα κεφαλαίο γράμμα';

  @override
  String get settingsPasswordNeedsLower => 'Προσθέστε ένα πεζό γράμμα';

  @override
  String get settingsPasswordNeedsDigit => 'Προσθέστε έναν αριθμό';

  @override
  String get settingsPasswordsNoMatch => 'Οι κωδικοί πρόσβασης δεν ταιριάζουν';

  @override
  String get settingsChangeAction => 'Αλλαγή';

  @override
  String get itemAddSnapTitle => 'Φωτογραφίστε ένα ρούχο';

  @override
  String get itemAddSnapBody =>
      'Εντοπίζουμε κάθε κομμάτι στη φωτογραφία και δημιουργούμε μια καθαρή λήψη στούντιο.';

  @override
  String get itemAddCamera => 'Λήψη φωτογραφίας';

  @override
  String get itemAddGallery => 'Επιλογή από τη συλλογή';

  @override
  String get itemAddOtherWays => 'Άλλοι τρόποι προσθήκης';

  @override
  String get itemAddSeveral => 'Προσθήκη πολλών φωτογραφιών';

  @override
  String get itemAddSeveralBody => 'Έως 50 ταυτόχρονα';

  @override
  String get itemAddImportProfile => 'Εισαγωγή από προφίλ';

  @override
  String get itemAddImportProfileBody => 'Instagram ή Facebook';

  @override
  String get itemAddEnterDetails => 'Εισαγωγή λεπτομερειών μόνοι σας';

  @override
  String get itemAddEnterDetailsBody => 'Δεν απαιτείται φωτογραφία';

  @override
  String get itemManualIntro =>
      'Απαιτείται μόνο όνομα. Προσθέστε τα υπόλοιπα τώρα ή αργότερα.';

  @override
  String get itemManualNameHint => 'Για παράδειγμα, μπλε βαμβακερό t-shirt';

  @override
  String get itemManualEnterName => 'Εισαγάγετε όνομα';

  @override
  String get itemManualNotes => 'Σημειώσεις';

  @override
  String get itemManualBrand => 'Μάρκα';

  @override
  String get itemManualSize => 'Μέγεθος';

  @override
  String get itemManualEnterNumber => 'Εισαγάγετε αριθμό';

  @override
  String get itemManualSavePiece => 'Αποθήκευση κομματιού';

  @override
  String get itemManualSaving => 'Αποθήκευση';

  @override
  String get itemManualSavedTitle => 'Αποθηκεύτηκε';

  @override
  String itemManualSavedBody(String name) {
    return 'Το $name βρίσκεται στην ντουλάπα σας.';
  }

  @override
  String get itemManualNotSaved => 'Δεν αποθηκεύτηκε';

  @override
  String get itemManualAddUseCase => 'Προσθήκη περίστασης χρήσης';

  @override
  String get itemManualAddUseCaseAction => 'Προσθήκη περίστασης';

  @override
  String get itemPhotos => 'Φωτογραφίες';

  @override
  String get itemAddPhotos => 'Προσθήκη φωτογραφιών';

  @override
  String get itemNoPhotoYet =>
      'Δεν υπάρχει φωτογραφία ακόμα. Μπορείτε να αποθηκεύσετε χωρίς.';

  @override
  String get itemRemovePhoto => 'Αφαίρεση φωτογραφίας';

  @override
  String get itemRemovePiece => 'Αφαίρεση κομματιού';

  @override
  String get filterConditionLabel => 'Κατάσταση';

  @override
  String get photoshootStepPhotos => 'Φωτογραφίες';

  @override
  String get photoshootStepSetup => 'Ρύθμιση';

  @override
  String get photoshootStepCreating => 'Δημιουργία';

  @override
  String get photoshootStepResults => 'Αποτελέσματα';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Βήμα $current από $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Μία φωτογραφία απέτυχε. Δοκιμάστε ξανά παρακάτω.';

  @override
  String photoshootManyFailed(int count) {
    return '$count φωτογραφίες απέτυχαν. Δοκιμάστε ξανά κάθε μία παρακάτω.';
  }

  @override
  String get photoshootFormat => 'Μορφή';

  @override
  String get photoshootHowMany => 'Πόσες';

  @override
  String get photoshootYourPrompt => 'Η περιγραφή σας';

  @override
  String get photoshootPromptHint => 'Χρυσή ώρα σε ταράτσα, λινό πουκάμισο';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Δημιουργία $count φωτογραφιών',
      one: 'Δημιουργία 1 φωτογραφίας',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'φωτογραφίες',
      one: 'φωτογραφία',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Δεν ήταν δυνατός ο έλεγχος του σημερινού ορίου.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Πρόγραμμα $plan: απομένουν $remaining από $limit σήμερα';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Δωρεάν';

  @override
  String get photoshootGallery => 'Συλλογή';

  @override
  String get photoshootUseCamera => 'Χρήση κάμερας';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Αφαίρεση φωτογραφίας $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Δεν επέστρεψαν φωτογραφίες';

  @override
  String get photoshootNoPhotosBody =>
      'Η φωτογράφιση ολοκληρώθηκε χωρίς εικόνες. Δοκιμάστε ξανά.';

  @override
  String get photoshootNewStyle => 'Νέο στυλ';

  @override
  String get photoshootNewPhotos => 'Νέες φωτογραφίες';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Άνοιγμα φωτογραφίας $number';
  }

  @override
  String get photoshootReportPhoto => 'Αναφορά φωτογραφίας';

  @override
  String get photoshootSaveToGallery => 'Αποθήκευση στη συλλογή';

  @override
  String get actionUpgrade => 'Αναβάθμιση';

  @override
  String get referralLimitTitle => 'Εξαντλήσατε τις σημερινές φωτογραφίες';

  @override
  String get referralLimitBody =>
      'Οι δωρεάν φωτογραφίες σας ανανεώνονται αύριο. Προσκαλέστε έναν φίλο και κερδίστε και οι δύο έναν μήνα Pro δωρεάν.';

  @override
  String get referralLimitRefer => 'Πρόσκληση φίλου';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Εφαρμογή γνωριμιών';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Aesthetic';

  @override
  String get photoshootUseCustom => 'Η δική σας περιγραφή';

  @override
  String get photoshootDescLinkedin => 'Επαγγελματικά πορτραίτα';

  @override
  String get photoshootDescDating => 'Χαλαρά, ζεστά και φυσικά';

  @override
  String get photoshootDescPortfolio => 'Editorial, υψηλή ραπτική';

  @override
  String get photoshootDescInstagram => 'Lifestyle λήψεις για το feed σας';

  @override
  String get photoshootDescAesthetic => 'Moody, καλλιτεχνικά κάδρα';

  @override
  String get photoshootDescCustom => 'Περιγράψτε το στυλ που θέλετε';

  @override
  String get aspectSquare => 'Τετράγωνο';

  @override
  String get aspectPortrait => 'Πορτραίτο';

  @override
  String get aspectLandscape => 'Τοπίο';

  @override
  String get aspectTall => 'Ψηλό';

  @override
  String get aspectWide => 'Φαρδύ';

  @override
  String get tryOnAppBar => 'Εικονική δοκιμή';

  @override
  String get tryOnYourPhoto => 'Η φωτογραφία σας';

  @override
  String get tryOnGarment => 'Ρούχο';

  @override
  String get tryOnUploadingPhoto => 'Μεταφόρτωση φωτογραφίας';

  @override
  String get tryOnAddPhotoPrompt => 'Προσθέστε μια ολόσωμη φωτογραφία σας';

  @override
  String get tryOnBodyPhotoHint => 'Μια ολόσωμη φωτογραφία λειτουργεί καλύτερα';

  @override
  String get tryOnAddPhoto => 'Προσθήκη φωτογραφίας';

  @override
  String get tryOnChangePhoto => 'Αλλαγή φωτογραφίας';

  @override
  String get tryOnPhotoLoadFailed =>
      'Δεν ήταν δυνατή η φόρτωση της φωτογραφίας σας.';

  @override
  String get tryOnChooseGarment => 'Επιλέξτε φωτογραφία ρούχου';

  @override
  String get tryOnChooseOneGarment => 'Επιλέξτε μία φωτογραφία ρούχου';

  @override
  String get tryOnGarmentHint =>
      'Μια φωτογραφία σε επίπεδη επιφάνεια ή κρεμάστρα λειτουργεί καλύτερα';

  @override
  String get tryOnChange => 'Αλλαγή';

  @override
  String get tryOnCamera => 'Κάμερα';

  @override
  String get tryOnRemove => 'Αφαίρεση';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Στυλ';

  @override
  String get tryOnBackground => 'Φόντο';

  @override
  String get tryOnPose => 'Πόζα';

  @override
  String get tryOnDressingUp =>
      'Σας ντύθουμε. Αυτό διαρκεί περίπου μισό λεπτό.';

  @override
  String get tryOnEmptyResult => 'Η δοκιμή σας εμφανίζεται εδώ';

  @override
  String get tryOnReportImage => 'Αναφορά εικόνας';

  @override
  String get tryOnCreating => 'Δημιουργία';

  @override
  String get tryOnTryAgain => 'Δοκιμάστε ξανά';

  @override
  String get tryOnCreate => 'Δημιουργία δοκιμής';

  @override
  String get tryOnBackgroundStudioWhite => 'Λευκό στούντιο';

  @override
  String get tryOnBackgroundStudioGrey => 'Γκρι στούντιο';

  @override
  String get tryOnBackgroundUrban => 'Αστικός δρόμος';

  @override
  String get tryOnBackgroundNature => 'Φύση';

  @override
  String get tryOnBackgroundMinimal => 'Μίνιμαλ';

  @override
  String get tryOnPoseFront => 'Όρθιος εμπρός';

  @override
  String get tryOnPoseSide => 'Όρθιος πλάγια';

  @override
  String get tryOnPoseWalking => 'Περπάτημα';

  @override
  String get dashboardGreetingMorning => 'Καλημέρα';

  @override
  String get dashboardGreetingAfternoon => 'Καλό μεσημέρι';

  @override
  String get dashboardGreetingEvening => 'Καλησπέρα';

  @override
  String get dashboardWelcome => 'Καλώς ήρθατε';

  @override
  String get dashboardOpenProfile => 'Άνοιγμα προφίλ';

  @override
  String get dashboardRailToday => 'Σήμερα';

  @override
  String get dashboardRailRecently => 'Πρόσφατα';

  @override
  String get dashboardActivityEmpty =>
      'Τα νέα κομμάτια και σύνολα εμφανίζονται εδώ.';

  @override
  String get quickAddPiece => 'Προσθήκη κομματιού';

  @override
  String get quickAddPieceBody => 'Φωτογράφιση και ετικέτα';

  @override
  String get quickBuildOutfit => 'Δημιουργία συνόλου';

  @override
  String get quickBuildOutfitBody => 'Συνδυάστε τα ρούχα σας';

  @override
  String get quickForYou => 'Για εσάς';

  @override
  String get quickForYouBody => 'Επιλογές για σήμερα';

  @override
  String get quickPlanWeek => 'Πρόγραμμα εβδομάδας';

  @override
  String get quickPlanWeekBody => 'Σύνολα ανά ημερομηνία';

  @override
  String get referralBannerUrgent => 'Σας τελειώνουν; Προσκαλέστε έναν φίλο.';

  @override
  String get referralBannerTitle => 'Χαρίστε έναν μήνα, κερδίστε έναν μήνα.';

  @override
  String get referralBannerBody =>
      'Εσείς και ο φίλος σας κερδίζετε από έναν μήνα Pro.';

  @override
  String get referralBannerDismiss => 'Απόρριψη για μία εβδομάδα';

  @override
  String get referralBannerShare => 'Κοινοποίηση πρόσκλησης';

  @override
  String get referralBannerCopy => 'Αντιγραφή συνδέσμου';

  @override
  String get itemEditPieceTitle => 'Επεξεργασία κομματιού';

  @override
  String get itemEditDescriptionLabel => 'Περιγραφή';

  @override
  String get itemEditNotSaved => 'Δεν αποθηκεύτηκε';

  @override
  String get itemEditSavedTitle => 'Αποθηκεύτηκε';

  @override
  String get itemEditSavedBody => 'Οι αλλαγές σας αποθηκεύτηκαν.';

  @override
  String get itemEditSavedStalePhotos =>
      'Αποθηκεύτηκε — οι φωτογραφίες ίσως είναι παλιές';

  @override
  String get itemEditRemovePieceHint =>
      'Διαγραφή αυτού του κομματιού από τη σελίδα του.';

  @override
  String get itemEditNoPhotos =>
      'Δεν υπάρχουν φωτογραφίες. Προσθέστε από τη συλλογή ή την κάμερα.';

  @override
  String get itemEditKeepPhoto => 'Διατήρηση φωτογραφίας';

  @override
  String get itemEditRemoved => 'Αφαιρέθηκε';

  @override
  String get itemEditAddUseCaseAction => 'Προσθήκη';

  @override
  String get statsNoStatsTitle => 'Χωρίς στατιστικά';

  @override
  String get statsNoStatsBody =>
      'Προσθέστε μερικά κομμάτια και η ανάλυση της ντουλάπας θα εμφανιστεί εδώ.';

  @override
  String get statsByCategory => 'Ανά κατηγορία';

  @override
  String get statsTotalValue => 'συνολική αξία';

  @override
  String get statsMostWorn => 'Πιο φορεμένα';

  @override
  String get statsLeastWorn => 'Περιμένουν σειρά';

  @override
  String get statsUnnamedPiece => 'Ανώνυμο κομμάτι';

  @override
  String get jobsTitle => 'Σαρώσεις';

  @override
  String get jobsEmptyTitle => 'Χωρίς σαρώσεις';

  @override
  String get jobsEmptyBody =>
      'Τραβήξτε μια φωτογραφία και στείλτε την στο παρασκήνιο — συνεχίζει να λειτουργεί εδώ.';

  @override
  String get jobsNotCancelled => 'Δεν ακυρώθηκε';

  @override
  String get jobsResume => 'Συνέχιση';

  @override
  String get jobsReview => 'Επισκόπηση';

  @override
  String get jobsStop => 'Διακοπή';

  @override
  String get jobsDismiss => 'Απόρριψη';

  @override
  String get reportTitle => 'Αναφορά περιεχομένου';

  @override
  String reportIntro(String contentType) {
    return 'Πείτε μας τι δεν πάει καλά με αυτό το $contentType. Η ομάδα μας εξετάζει κάθε αναφορά.';
  }

  @override
  String get reportReasonInappropriate => 'Ακατάλληλο ή προσβλητικό';

  @override
  String get reportReasonNudity => 'Γυμνό ή σεξουαλικό περιεχόμενο';

  @override
  String get reportReasonHarassment => 'Παρενόχληση ή κατάχρηση';

  @override
  String get reportReasonImpersonation => 'Υποκλοπή ταυτότητας';

  @override
  String get reportReasonOther => 'Άλλο';

  @override
  String get reportDetailsLabel => 'Επιπλέον λεπτομέρειες (προαιρετικά)';

  @override
  String get reportSubmit => 'Υποβολή αναφοράς';

  @override
  String get reportSubmittedTitle => 'Η αναφορά υποβλήθηκε';

  @override
  String get reportSubmittedBody =>
      'Ευχαριστούμε. Η ομάδα μας θα εξετάσει αυτό το περιεχόμενο.';

  @override
  String get reportFailedTitle => 'Αποτυχία αποστολής αναφοράς';

  @override
  String get reportFailedBody => 'Παρακαλώ προσπαθήστε ξανά.';

  @override
  String get reportContentTryOnImage => 'εικόνα δοκιμής AI';

  @override
  String get reportContentSharedOutfit => 'κοινόχρηστο σύνολο';

  @override
  String get reportContentPhotoshootImage => 'εικόνα φωτογράφισης AI';

  @override
  String get sharedOutfitTitle => 'Κοινόχρηστο σύνολο';

  @override
  String get sharedOutfitHideTooltip => 'Απόκρυψη συνόλου';

  @override
  String get sharedOutfitReportTooltip => 'Αναφορά συνόλου';

  @override
  String get sharedOutfitHideTitle => 'Απόκρυψη συνόλου;';

  @override
  String get sharedOutfitHideBody =>
      'Θα παραμείνει κρυφό σε αυτή τη συσκευή. Μπορείτε επίσης να το αναφέρετε για έλεγχο και αφαίρεση από την ομάδα μας.';

  @override
  String get sharedOutfitHideAction => 'Απόκρυψη';

  @override
  String get sharedOutfitHiddenInfo =>
      'Αυτό το σύνολο δεν θα εμφανιστεί ξανά σε αυτή τη συσκευή.';

  @override
  String get sharedOutfitHiddenToast => 'Το σύνολο κρύφτηκε';

  @override
  String get sharedOutfitMissingTitle => 'Το σύνολο δεν είναι πλέον διαθέσιμο';

  @override
  String get sharedOutfitMissingBody =>
      'Ίσως έχει αφαιρεθεί ή ο σύνδεσμος δεν είναι έγκυρος.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Αποκρύψατε αυτό το σύνολο';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Αν είναι ακατάλληλο, αναφέρετέ το μέσω των Όρων και απορρήτου ή στείλτε email στο $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Σας αρέσει αυτό το στυλ;';

  @override
  String get sharedOutfitCtaBody =>
      'Δημιουργήστε παρόμοια σύνολα από τη δική σας ντουλάπα.';

  @override
  String get sharedOutfitCtaButton => 'Αποκτήστε το FitCheck AI';

  @override
  String get errorTitle => 'Σφάλμα';

  @override
  String get errorUnknown => 'Παρουσιάστηκε απρόσμενο σφάλμα';

  @override
  String get errorNoConnection =>
      'Χωρίς σύνδεση στο διαδίκτυο. Ελέγξτε το δίκτυό σας.';

  @override
  String get errorTimeout => 'Η αίτηση έληξε. Προσπαθήστε ξανά.';

  @override
  String get errorServerError =>
      'Κάτι πήγε στραβά από την πλευρά μας. Προσπαθήστε ξανά.';

  @override
  String get errorBadGateway =>
      'Ο διακομιστής μας δεν είναι προσωρινά διαθέσιμος. Προσπαθήστε ξανά.';

  @override
  String get errorServiceUnavailable =>
      'Η υπηρεσία δεν είναι προσωρινά διαθέσιμη. Προσπαθήστε σύντομα.';

  @override
  String get errorInternalError => 'Κάτι πήγε στραβά. Προσπαθήστε ξανά.';

  @override
  String get errorUnauthorized => 'Συνδεθείτε για να συνεχίσετε.';

  @override
  String get errorForbidden => 'Δεν έχετε πρόσβαση σε αυτό.';

  @override
  String get errorSessionExpired => 'Η συνεδρία σας έληξε. Συνδεθείτε ξανά.';

  @override
  String get errorInvalidCredentials =>
      'Το email ή ο κωδικός πρόσβασης δεν είναι σωστός.';

  @override
  String get errorTokenRefreshFailed =>
      'Δεν ήταν δυνατή η ανανέωση της συνεδρίας σας. Συνδεθείτε ξανά.';

  @override
  String get errorRequestCancelled => 'Το αίτημα ακυρώθηκε.';

  @override
  String get errorInvalidFormat => 'Αυτή η μορφή αρχείου δεν υποστηρίζεται.';

  @override
  String get errorFileTooLarge => 'Το αρχείο είναι πολύ μεγάλο.';

  @override
  String get errorUploadFailed => 'Η μεταφόρτωση απέτυχε. Προσπαθήστε ξανά.';

  @override
  String get errorCacheCorrupted =>
      'Τα αποθηκευμένα δεδομένα καταστράφηκαν και επαναφερθήκαν.';

  @override
  String get errorCacheNotFound => 'Δεν έχει αποθηκευτεί τίποτα ακόμα.';

  @override
  String get errorUserNotFound => 'Δεν βρέθηκε αυτός ο λογαριασμός.';

  @override
  String get errorItemNotFound => 'Αυτό το αντικείμενο δεν υπάρχει πλέον.';

  @override
  String get errorOutfitNotFound => 'Αυτό το σύνολο δεν υπάρχει πλέον.';

  @override
  String get rewardsTitle => 'Επιβραβεύσεις';

  @override
  String get rewardsNoAchievementsTitle => 'Χωρίς επιτεύγματα ακόμα';

  @override
  String get rewardsNoAchievementsBody =>
      'Προσθέστε κομμάτια και σχεδιάστε σύνολα για να κερδίσετε το πρώτο σας.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Κανείς στον πίνακα ακόμα';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Σχεδιάστε σύνολα για να κερδίσετε πόντους και να εμφανιστείτε εδώ.';

  @override
  String get legalViewPrivacyPolicy => 'Πολιτική Απορρήτου';

  @override
  String get aiConsentAgree => 'Συμφωνώ & Συνέχεια';

  @override
  String get aiConsentNotNow => 'Όχι Τώρα';

  @override
  String get imageViewerCloseTooltip => 'Κλείσιμο προβολής';

  @override
  String get updateReadyTitle => 'Διαθέσιμη ενημέρωση';

  @override
  String get updateReadyBody =>
      'Επανεκκινήστε το FitCheck AI για να εφαρμόσετε τις τελευταίες βελτιώσεις.';

  @override
  String get permissionCameraUsage =>
      'Το FitCheck AI χρειάζεται πρόσβαση στην κάμερα για να φωτογραφίζετε τα ρούχα σας.';

  @override
  String get permissionPhotoLibraryUsage =>
      'Το FitCheck AI χρειάζεται πρόσβαση στις φωτογραφίες για να επιλέξετε items.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'Το FitCheck AI χρειάζεται άδεια αποθήκευσης των νέων σας outfits.';

  @override
  String get wardrobeSomePhotosSkipped => 'Ορισμένες φωτογραφίες παραλείφθηκαν';

  @override
  String get wardrobePhotosNotAdded => 'Οι φωτογραφίες δεν προστέθηκαν';

  @override
  String get wardrobePhotoNotAdded => 'Η φωτογραφία δεν προστέθηκε';

  @override
  String get wardrobeNotStartedTitle => 'Δεν ξεκίνησε';

  @override
  String get wardrobeNoRoomTitle => 'Χωρίς χώρο';

  @override
  String get wardrobeAddPhotosSemantic => 'Προσθήκη φωτογραφιών';

  @override
  String get batchAddTileLabel => 'Προσθήκη';

  @override
  String get batchProfileLinkLabel => 'Σύνδεσμος προφίλ';

  @override
  String get wardrobeImportFromProfileTitle => 'Εισαγωγή από προφίλ';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Προσθήκη πολλών φωτογραφιών';

  @override
  String get wardrobeClearAction => 'Καθαρισμός';

  @override
  String get wardrobeRefreshTooltip => 'Ανανέωση';

  @override
  String get batchNoPhotosYetTitle => 'Καμία φωτογραφία ακόμη';

  @override
  String get batchChoosePhotosAction => 'Επιλογή φωτογραφιών';

  @override
  String get batchWeFindEachPieceBody =>
      'Εντοπίζουμε κάθε κομμάτι και δημιουργούμε επαγγελματική φωτογραφία.';

  @override
  String get batchPreparingPhotosSemantic => 'Προετοιμασία φωτογραφιών';

  @override
  String get batchPhotosProcessedSemantic => 'Οι φωτογραφίες επεξεργάστηκαν';

  @override
  String get batchPasteProfileLinkTitle => 'Επικόλληση συνδέσμου προφίλ';

  @override
  String get batchPasteProfileLinkBody =>
      'Ένα δημόσιο προφίλ Instagram ή Facebook. Σαρώνουμε τις φωτογραφίες και επιλέγετε τι θα μπει στην ντουλάπα.';

  @override
  String get batchClearLinkTooltip => 'Καθαρισμός συνδέσμου';

  @override
  String get batchStartingButton => 'Εκκίνηση';

  @override
  String get batchStartImportAction => 'Έναρξη εισαγωγής';

  @override
  String get batchReviewEveryPhotoTitle => 'Έλεγχος κάθε φωτογραφίας';

  @override
  String get batchReviewEveryPhotoBody =>
      'Τίποτα δεν προστίθεται αν δεν το εγκρίνετε.';

  @override
  String get batchPrivateProfilesTitle => 'Ιδιωτικά προφίλ';

  @override
  String get batchPrivateProfilesBody =>
      'Συνδέστε τον λογαριασμό σας. Το Instagram απαιτεί επίσης όνομα χρήστη και κωδικό πρόσβασης.';

  @override
  String get batchUseAnotherLinkAction => 'Χρήση άλλου συνδέσμου';

  @override
  String get batchSignInNeededTitle => 'Απαιτείται σύνδεση';

  @override
  String get batchEnterYourCodeTitle => 'Εισαγωγή κωδικού';

  @override
  String get batchUseUsernamePasswordAction =>
      'Χρήση ονόματος χρήστη και κωδικού';

  @override
  String get batchAlreadyConnectedAction =>
      'Έχω ήδη συνδεθεί στο πρόγραμμα περιήγησης';

  @override
  String get batchEnterCodeAction => 'Εισαγωγή κωδικού';

  @override
  String get batchTryAnotherWayAction => 'Δοκιμάστε άλλον τρόπο';

  @override
  String get batchLiveStatus => 'Ζωντανά';

  @override
  String get batchReconnectingStatus => 'Επανασύνδεση';

  @override
  String get batchSignInToInstagramTitle => 'Σύνδεση στο Instagram';

  @override
  String get batchUsernameLabel => 'Όνομα χρήστη';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Κωδικός, εάν χρησιμοποιείτε επαλήθευση δύο βημάτων';

  @override
  String get batchAuthenticatorCodeBody =>
      'Χρησιμοποιήστε τον 6ψήφιο κωδικό από την εφαρμογή authenticator. Οι κωδικοί αλλάζουν γρήγορα.';

  @override
  String get batchVerifyAction => 'Επαλήθευση';

  @override
  String get batchFindingPhotosTitle => 'Εύρεση φωτογραφιών';

  @override
  String get batchImportPausedTitle => 'Η εισαγωγή σε παύση';

  @override
  String get batchProcessingPhotosTitle => 'Επεξεργασία φωτογραφιών';

  @override
  String get batchWaitingNextPhoto => 'Αναμονή για την επόμενη φωτογραφία';

  @override
  String get batchCancelImportAction => 'Ακύρωση εισαγωγής';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Δεν βρέθηκαν ρούχα σε αυτή τη φωτογραφία.';

  @override
  String get batchEditPieceColoursLabel => 'Χρώματα, χωρισμένα με κόμματα';

  @override
  String get batchAddToClosetAction => 'Προσθήκη στην ντουλάπα';

  @override
  String get batchSkipPhotoAction => 'Παράλειψη φωτογραφίας';

  @override
  String get batchImportCompleteTitle => 'Η εισαγωγή ολοκληρώθηκε';

  @override
  String get batchImportFailedTitle => 'Η εισαγωγή απέτυχε';

  @override
  String get batchImportCancelledTitle => 'Η εισαγωγή ακυρώθηκε';

  @override
  String get batchImportErrorBody => 'Κάτι πήγε στραβά κατά την εισαγωγή.';

  @override
  String get batchNothingMoreImportedBody =>
      'Δεν εισάγεται τίποτα επιπλέον από αυτό το προφίλ.';

  @override
  String get batchViewClosetAction => 'Προβολή ντουλάπας';

  @override
  String get batchStartOverAction => 'Εκ νέου';

  @override
  String get wardrobeAddPieceTitle => 'Προσθήκη ρούχου';

  @override
  String get wardrobeAddDetailsTitle => 'Προσθήκη λεπτομερειών';

  @override
  String get wardrobeScanningTitle => 'Σάρωση';

  @override
  String get batchReviewPiecesTitle => 'Έλεγχος ρούχων';

  @override
  String get wardrobeGalleryAction => 'Συλλογή';

  @override
  String get wardrobeCameraAction => 'Κάμερα';

  @override
  String get wardrobeNewBadge => 'Νέο';

  @override
  String get wardrobeRemovePhotoTooltip => 'Αφαίρεση φωτογραφίας';

  @override
  String get batchRunInBackgroundTooltip => 'Εκτέλεση στο παρασκήνιο';

  @override
  String get batchStepOneOfTwo => 'Βήμα 1 από 2';

  @override
  String get batchStepTwoOfTwo => 'Βήμα 2 από 2';

  @override
  String get batchUploadingPhotosTitle => 'Μεταφόρτωση φωτογραφιών';

  @override
  String get batchFindingPiecesTitle => 'Εύρεση ρούχων';

  @override
  String get batchMakingStudioPhotosTitle => 'Δημιουργία φωτογραφιών στούντιο';

  @override
  String get batchStoppedLabel => 'Διακόπηκε';

  @override
  String get batchFindingPiecesStoppedTitle => 'Η εύρεση ρούχων διακόπηκε';

  @override
  String get batchCancelledLabel => 'Ακυρώθηκε';

  @override
  String get batchAllDoneTitle => 'Όλα έτοιμα';

  @override
  String get batchOpeningPiecesBody => 'Άνοιγμα των ρούχων σας';

  @override
  String get batchNothingSavedBody => 'Δεν αποθηκεύτηκε τίποτα.';

  @override
  String get batchFindingPiecesFailedBody => 'Η εύρεση ρούχων απέτυχε.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Η εύρεση ρούχων διακόπηκε νωρίς.';

  @override
  String get batchStopFindingPiecesTitle => 'Διακοπή εύρεσης ρούχων;';

  @override
  String get batchStopFindingPiecesBody =>
      'Η σάρωση σταματά και τίποτα δεν αποθηκεύεται. Τα ρούχα που έχουν ήδη βρεθεί παραμένουν στη δραστηριότητά σας έως ότου τα απορρίψετε.';

  @override
  String get batchKeepGoingAction => 'Συνέχεια';

  @override
  String get batchTryAgainAction => 'Δοκιμή ξανά';

  @override
  String get batchBackToPhotosAction => 'Πίσω στις φωτογραφίες';

  @override
  String get batchSkipAllAction => 'Παράλειψη όλων';

  @override
  String get batchIncludeAllAction => 'Συμπερίληψη όλων';

  @override
  String get batchNoPiecesFoundTitle => 'Δεν βρέθηκαν κομμάτια';

  @override
  String get batchNoPiecesFoundBody =>
      'Δεν βρήκαμε ρούχα σε αυτές τις φωτογραφίες.';

  @override
  String get batchChooseOtherPhotosAction => 'Επιλογή άλλων φωτογραφιών';

  @override
  String get batchUseCaseHelper =>
      'Προστίθεται σε κάθε κομμάτι που αποθηκεύετε.';

  @override
  String get batchDiscardPiecesTitle => 'Απόρριψη αυτών των κομματιών;';

  @override
  String get batchDiscardPiecesBody =>
      'Δεν έχει αποθηκευτεί τίποτα από αυτήν την παρτίδα.';

  @override
  String get batchKeepAction => 'Διατήρηση';

  @override
  String get batchDiscardAction => 'Απόρριψη';

  @override
  String get batchRemovePieceTitle => 'Αφαίρεση αυτού του κομματιού;';

  @override
  String get batchRemovePieceBody => 'Δεν έχει αποθηκευτεί στην ντουλάπα σας.';

  @override
  String get batchRemoveAction => 'Αφαίρεση';

  @override
  String get batchChoosePiecesToSave => 'Επιλέξτε κομμάτια για αποθήκευση';

  @override
  String get batchDiscardAllAction => 'Απόρριψη όλων';

  @override
  String get batchNothingSavedRetryBody =>
      'Δεν αποθηκεύτηκε τίποτα. Δοκιμάστε ξανά.';

  @override
  String get batchNotSavedTitle => 'Δεν αποθηκεύτηκε';

  @override
  String get batchSavingLabel => 'Αποθήκευση';

  @override
  String get batchSendToBackgroundAction => 'Εκτέλεση στο παρασκήνιο';

  @override
  String get batchStillWorkingMessage =>
      'Γίνεται επεξεργασία. Θα σας ειδοποιήσουμε μόλις είναι έτοιμα τα κομμάτια σας.';

  @override
  String get batchRunningInBackgroundTitle => 'Εκτέλεση στο παρασκήνιο';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Οι φωτογραφίες στούντιο σταμάτησαν νωρίς. Μπορείτε ακόμα να αποθηκεύσετε αυτά τα κομμάτια.';

  @override
  String get batchTapPieceToSkip => 'Πατήστε ένα κομμάτι για παράλειψη.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Οι φωτογραφίες στούντιο ετοιμάζονται. Μπορείτε να φύγετε — θα σας ειδοποιήσουμε.';

  @override
  String get batchLeaveAction => 'Έξοδος';

  @override
  String get batchPeopleInPhotosTitle => 'Άτομα στις φωτογραφίες';

  @override
  String get batchIncludeAction => 'Συμπερίληψη';

  @override
  String get batchSkipAction => 'Παράλειψη';

  @override
  String get batchYourPhotoIsUsedLabel => 'Χρησιμοποιείται η φωτογραφία σας';

  @override
  String get batchMakingStudioPhotoLabel => 'Δημιουργία φωτογραφίας στούντιο';

  @override
  String get batchNoStudioPhotoBody =>
      'Χωρίς φωτογραφία στούντιο. Χρησιμοποιείται η φωτογραφία σας.';

  @override
  String get batchEnterDetailsYourselfAction => 'Χειροκίνητη καταχώριση';

  @override
  String get batchChooseAnotherPhotoAction => 'Επιλογή άλλης φωτογραφίας';

  @override
  String get batchConnectionLostTitle => 'Χάθηκε η σύνδεση';

  @override
  String get batchConnectionLostBody =>
      'Ελέγξτε τη σύνδεσή σας και δοκιμάστε ξανά.';

  @override
  String get batchDailyLimitTitle => 'Συμπληρώθηκε το ημερήσιο όριο';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Αναβαθμίστε σε Pro για περισσότερες σαρώσεις ή καταχωρίστε τα στοιχεία μόνοι σας.';

  @override
  String get batchDailyLimitBodyFree =>
      'Οι σαρώσεις σας μηδενίζονται αύριο. Μπορείτε να καταχωρίσετε τα στοιχεία μόνοι σας τώρα.';

  @override
  String get batchSeePlansAction => 'Δείτε τα προγράμματα';

  @override
  String get batchAiBusyTitle => 'Η τεχνητή νοημοσύνη απασχολείται';

  @override
  String get batchAiBusyBody =>
      'Αυτό οφείλεται σε εμάς. Δοκιμάστε ξανά σε λίγα λεπτά.';

  @override
  String get batchNoPiecesBody =>
      'Δοκιμάστε μια πιο καθαρή φωτογραφία ή καταχωρίστε τα στοιχεία μόνοι σας.';

  @override
  String get batchScanningUnavailableTitle => 'Η σάρωση δεν είναι διαθέσιμη';

  @override
  String get batchScanningUnavailableBody =>
      'Καταχωρίστε τα στοιχεία μόνοι σας επί του παρόντος.';

  @override
  String get batchScanDidNotFinishTitle => 'Η σάρωση δεν ολοκληρώθηκε';

  @override
  String get batchTryAgainBody => 'Δοκιμάστε ξανά.';

  @override
  String get billingTitle => 'Συνδρομή';

  @override
  String get billingUpgradeHeading => 'Αναβάθμιση προγράμματος';

  @override
  String get billingUpgradeOnPlusBody => 'Ίδιες λειτουργίες, μεγαλύτερα όρια.';

  @override
  String get billingUpgradeBody =>
      'Τα Plus και Pro έχουν τις ίδιες λειτουργίες. Επιλέξτε τα όρια που χρειάζεστε.';

  @override
  String get billingWebUnavailableBody =>
      'Οι διαδικτυακές αναβαθμίσεις δεν είναι διαθέσιμες ακόμη. Ένας κωδικός προσφοράς ή σύστασης εξακολουθεί να ξεκλειδώνει τα Plus ή Pro. Προσκαλέστε φίλους παρακάτω για να κερδίσετε δωρεάν μήνες.';

  @override
  String get billingPlansStale =>
      'Δεν ήταν δυνατή η φόρτωση των πιο πρόσφατων προγραμμάτων. Οι τιμές ενδέχεται να μην είναι ενημερωμένες.';

  @override
  String get billingMonthly => 'Μηνιαία';

  @override
  String get billingYearly => 'Ετήσια';

  @override
  String get billingCurrentPlan => 'Τρέχον πρόγραμμα';

  @override
  String get billingActive => 'Ενεργό';

  @override
  String get billingThisMonth => 'Αυτόν τον μήνα';

  @override
  String get billingItemExtractions => 'Εξαγωγές ρούχων';

  @override
  String get billingOutfitVisualizations => 'Οπτικοποιήσεις συνόλων';

  @override
  String get billingNearLimitUpgrade =>
      'Φτάνετε στο όριο αυτού του μήνα. Αναβαθμίστε για περισσότερα.';

  @override
  String get billingNearLimitResets =>
      'Φτάνετε στο όριο αυutos του μήνα. Μηδενίζεται στην αρχή του επόμενου μήνα.';

  @override
  String get billingStoreUnavailable =>
      'Οι αναβαθμίσεις δεν είναι διαθέσιμες στο κατάστημα ακόμη. Δοκιμάστε ξανά σύντομα.';

  @override
  String get billingManageHeading => 'Διαχείριση συνδρομής';

  @override
  String get billingCancelPlan => 'Ακύρωση συνδρομής';

  @override
  String get billingCancelKeepsAccess =>
      'Διατηρείτε πρόσβαση έως το τέλος αυτής της περιόδου χρέωσης.';

  @override
  String get billingCancelConfirmTitle => 'Ακύρωση της συνδρομής σας;';

  @override
  String get billingKeepPlan => 'Διατήρηση συνδρομής';

  @override
  String get billingCancelPlanAction => 'Ακύρωση συνδρομής';

  @override
  String get billingBilledMonthly => 'Μηνιαία χρέωση';

  @override
  String get billingBilledYearly => 'Ετήσια χρέωση';

  @override
  String get billingVirtualTryOn => 'Εικονική δοκιμή';

  @override
  String get billingPrioritySupport => 'Προτεραιότητα υποστήριξης';

  @override
  String get billingDisclosureProRenewing =>
      'Το Pro είναι συνδρομή αυτόματης ανανέωσης';

  @override
  String get billingDisclosureBothRenewing =>
      'Τα Plus και Pro είναι συνδρομές αυτόματης ανανέωσης';

  @override
  String get billingDisclosureAppleBilling =>
      'Η πληρωμή χρεώνεται στο Apple ID σας κατά την επιβεβαίωση της αγοράς.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Η πληρωμή χρεώνεται στον λογαριασμό σας Google Play κατά την επιβεβαίωση της αγοράς.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Η συνδρομή σας ανανεώνεται αυτόματα για την ίδια περίοδο στην ίδια τιμή, εκτός εάν απενεργοποιήσετε την αυτόματη ανανέωση τουλάχιστον 24 ώρες πριν από τη λήξη της τρέχουσας περιόδου.';

  @override
  String get billingDisclosureAppleManage =>
      'Διαχειριστείτε ή ακυρώστε οποιαδήποτε στιγμή στις Ρυθμίσεις › το Apple ID σας › Συνδρομές.';

  @override
  String get billingDisclosureGoogleManage =>
      'Διαχειριστείτε ή ακυρώστε οποιαδήποτε στιγμή στο Google Play › Πληρωμές και συνδρομές.';

  @override
  String get billingReferFriend => 'Προτείνετε σε φίλο';

  @override
  String get billingHowItWorks => 'Πώς λειτουργεί';

  @override
  String get billingHowShareTitle => 'Μοιραστείτε τον σύνδεσμο';

  @override
  String get billingHowShareBody => 'Στείλτε τον σε έναν φίλο.';

  @override
  String get billingHowSignUpTitle => 'Εγγραφή φίλου';

  @override
  String get billingHowSignUpBody =>
      'Ο φίλος σας εγγράφεται μέσω του συνδέσμου.';

  @override
  String get billingHowBothTitle => 'Κερδίζετε και οι δύο Pro';

  @override
  String get billingHowBothBody => 'Και οι δύο κερδίζετε έναν μήνα Pro δωρεάν.';

  @override
  String get billingYourReferrals => 'Οι συστάσεις σας';

  @override
  String get billingInvited => 'Προτάθηκαν';

  @override
  String get billingJoined => 'Εγγράφηκαν';

  @override
  String get billingMonthsEarned => 'Μήνες που κερδίσατε';

  @override
  String get billingInviteFriend => 'Πρόσκληση φίλου';

  @override
  String get billingInviteBody =>
      'Εσύ και ο φίλος σου κερδίζετε από έναν μήνα Pro.';

  @override
  String get billingYourCode => 'Ο κωδικός σου';

  @override
  String get billingCopyLink => 'Αντιγραφή συνδέσμου';

  @override
  String get billingShareInvite => 'Κοινή χρήση πρόσκλησης';

  @override
  String get giftUnavailable =>
      'Οι προσσκλήσεις δώρων δεν είναι διαθέσιμες σε αυτήν την έκδοση.';

  @override
  String get giftPageTitle => 'Δώρο FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Δεν υπάρχουν διαθέσιμες δωρεάν προσσκλήσεις δώρων αυτή τη στιγμή.';

  @override
  String get giftFormTitle => 'Αποστολή δωρεάν πρόσκλησης';

  @override
  String get giftFormBody =>
      'Ο παραλήπτης διεκδικεί το δώρο με αυτό το επαληθευμένο email. Δεν στέλνουμε το email για εσάς.';

  @override
  String get giftFieldFrom => 'Από';

  @override
  String get giftFieldRecipientName => 'Όνομα παραλήπτη';

  @override
  String get giftFieldRecipientEmail => 'Email παραλήπτη';

  @override
  String get giftFieldOccasion => 'Περίσταση (προαιρετικά)';

  @override
  String get giftNoOccasion => 'Χωρίς περίσταση';

  @override
  String get giftOccasionBirthday => 'Γενέθλια';

  @override
  String get giftOccasionAnniversary => 'Επέτειος';

  @override
  String get giftOccasionOther => 'Άλλο';

  @override
  String get giftFieldCardGreeting => 'Χαιρετισμός κάρτας';

  @override
  String get giftFieldCardGreetingHelper =>
      'Αυτό εμφανίζεται στην κάρτα ακριβώς όπως γράφτηκε.';

  @override
  String get giftFieldPrivateNote => 'Ιδιωτική σημείωση (προαιρετικά)';

  @override
  String get giftCreateAction => 'Δημιουργία δωρεάν δώρου';

  @override
  String get giftClaimedTitle => 'Το δώρο εξαργυρώθηκε';

  @override
  String get giftClaimedActive => 'Το δώρο σας FitCheck Pro είναι ενεργό.';

  @override
  String get giftClaimedQueued =>
      'Το δώρο σας FitCheck Pro ξεκινά μετά την τρέχουσα πρόσβασή σας.';

  @override
  String get giftLinkCopied => 'Ο σύνδεσμος δώρου αντιγράφηκε στο πρόχειρο.';

  @override
  String get giftErrorName => 'Εισαγάγετε ένα όνομα.';

  @override
  String get giftErrorEmail => 'Εισαγάγετε μια έγκυρη διεύθυνση email.';

  @override
  String get giftErrorGreeting => 'Εισαγάγετε τον χαιρετισμό της κάρτας.';

  @override
  String get giftErrorGreetingLength => 'Χρησιμοποιήστε έως 80 χαρακτήρες.';

  @override
  String get giftClaimAction => 'Λήψη δώρου';

  @override
  String get giftCardPreview => 'Προεπισκόπηση κάρτας';

  @override
  String get giftGiftForYou => 'Ένα δώρο για εσάς';

  @override
  String get giftGiftWaiting => 'Ένα δώρο σας περιμένει';

  @override
  String get giftOpenBody =>
      'Ανοίξτε τα δώρα σας για να τα διεκδικήσετε με το επαληθευμένο email σας.';

  @override
  String get giftOpenGifts => 'Άνοιγμα δώρων';

  @override
  String get giftSendInvitation => 'Αποστολή πρόσκλησης';

  @override
  String get settingsAiProviderSection => 'Προμηθευτής';

  @override
  String get settingsAiCustom => 'Προσαρμοσμένο';

  @override
  String get settingsAiUrlHelper =>
      'Χρησιμοποιήστε μια δημόσια διεύθυνση URL που μπορεί να προσεγγίσει ο διακομιστής. Η τοπική διεύθυνση δεν λειτουργεί από τους διακομιστές μας.';

  @override
  String get settingsAiConnectionSection => 'Σύνδεση';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'Κλειδί API';

  @override
  String get settingsAiApiKeySaved =>
      'Αποθηκεύτηκε. Αφήστε το κενό για να το διατηρήσετε.';

  @override
  String get settingsAiChatModel => 'Μοντέλο συνομιλίας';

  @override
  String get settingsAiVisionModel => 'Μοντέλο όρασης (προαιρετικό)';

  @override
  String get settingsAiImageModel => 'Μοντέλο εικόνας (προαιρετικό)';

  @override
  String get settingsAiImageModelNote =>
      'Η παραγωγή εικόνας απαιτεί ολοκληρώσεις συνομιλίας συμβατές με OpenAI με response_modalities.';

  @override
  String get settingsAiTestConnection => 'Δοκιμή σύνδεσης';

  @override
  String get calendarTitle => 'Ημερολόγιο';

  @override
  String get calendarGoToToday => 'Μετάβαση στο σημερινό';

  @override
  String get calendarConnectTooltip => 'Σύνδεση ημερολογίου';

  @override
  String get calendarAddEvent => 'Προσθήκη συμβάντος';

  @override
  String get calendarEmptyTitle => 'Τίποτα προγραμματισμένο';

  @override
  String get calendarEmptyBody =>
      'Προσθέστε ένα συμβάν και προγραμματίστε τι θα φορέσετε.';

  @override
  String get calendarPreviousMonth => 'Προηγούμενος μήνας';

  @override
  String get calendarNextMonth => 'Επόμενος μήνας';

  @override
  String get calendarAllDay => 'Όλη μέρα';

  @override
  String get calendarOutfitLinked => 'Συνδεδεμένο σύνολο';

  @override
  String get calendarEventOptions => 'Επιλογές συμβάντος';

  @override
  String get calendarDeleteTitle => 'Διαγραφή αυτού του συμβάντος;';

  @override
  String get calendarChangeOutfit => 'Αλλαγή συνόλου';

  @override
  String get calendarLinkOutfit => 'Σύνδεση συνόλου';

  @override
  String get calendarRemoveOutfit => 'Αφαίρεση συνόλου';

  @override
  String get calendarNewEvent => 'Νέο συμβάν';

  @override
  String get calendarEditEvent => 'Επεξεργασία συμβάντος';

  @override
  String get calendarTitleLabel => 'Τίτλος';

  @override
  String get calendarTitleRequired => 'Προσθέστε τίτλο';

  @override
  String get calendarEndBeforeStart => 'Η λήξη μετά την έναρξη';

  @override
  String get calendarStarts => 'Έναρξη';

  @override
  String get calendarEnds => 'Λήξη';

  @override
  String get calendarPlaceOptional => 'Τοποθεσία (προαιρετικά)';

  @override
  String get calendarNotesOptional => 'Σημειώσεις (προαιρετικά)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Δημιουργήστε ένα σύνολο και συνδέστε το εδώ.';

  @override
  String get calendarBuildOutfit => 'Δημιουργία συνόλου';

  @override
  String get calendarConnectionsTitle => 'Ημερολόγια';

  @override
  String get calendarConnectionsBody =>
      'Τα συμβάντα παραμένουν στο FitCheck AI.';

  @override
  String get calendarDisconnect => 'Αποσύνδεση';

  @override
  String get calendarNotAvailable => 'Δεν είναι διαθέσιμο';

  @override
  String get profileSectionExplore => 'Εξερεύνηση';

  @override
  String get profileNavTryOn => 'Δοκιμή';

  @override
  String get profileNavRewards => 'Επιβραβεύσεις';

  @override
  String get profileSupport => 'Υποστήριξη';

  @override
  String get profileHelp => 'Βοήθεια';

  @override
  String get profileAbout => 'Σχετικά';

  @override
  String get profileAboutBody => 'Η ντουλάπα, τα σύνολα και τα πλάνα σας.';

  @override
  String get profileSignOutTitle => 'Αποσύνδεση;';

  @override
  String get profileSignOutBody =>
      'Μπορείτε να συνδεθείτε ξανά ανά πάσα στιγμή.';

  @override
  String get profileEditTitle => 'Επεξεργασία προφίλ';

  @override
  String get profileYourProfile => 'Το προφίλ σας';

  @override
  String get profileBodyProfiles => 'Σώματα';

  @override
  String get profileBodyEmptyTitle => 'Κανένα προφίλ σώματος';

  @override
  String get profileBodyEmptyBody =>
      'Προσθέστε ύψος και σωματότυπο για καλύτερη εφαρμογή.';

  @override
  String get profileBodyAdd => 'Προσθήκη';

  @override
  String get profileBodyDefaultNote =>
      'Το προεπιλεγμένο προφίλ χρησιμοποιείται για την εφαρμογή.';

  @override
  String get profileBodyDefaultBadge => 'Προεπιλογή';

  @override
  String get profileBodyMakeDefault => 'Ορισμός ως προεπιλογή';

  @override
  String get profileBodyDeleteBody => 'Αυτή η ενέργεια δεν αναιρείται.';

  @override
  String get profileBodyRequired => 'Απαιτείται';

  @override
  String get profileBodyCheckNumber => 'Ελέγξτε αυτόν τον αριθμό';

  @override
  String get profileBodyNew => 'Νέο προφίλ σώματος';

  @override
  String get profileBodyNameHint => 'Για παράδειγμα, Εγώ';

  @override
  String get profileBodyHeight => 'Ύψος';

  @override
  String get profileBodyWeight => 'Βάρος';

  @override
  String get profileBodyBuild => 'Σωματότυπος';

  @override
  String get profileBodySkinTone => 'Τόνος δέρματος';

  @override
  String get profileBirthDateNeededBody =>
      'Προσθέστε ημερομηνία γέννησης για την ώρα γέννησης.';

  @override
  String get profileBirthDateNeededTitle => 'Απαιτείται ημερομηνία';

  @override
  String get profilePartlySavedBody =>
      'Αποθηκεύτηκαν όνομα και φωτογραφία. Τα στοιχεία γέννησης απέτυχαν.';

  @override
  String get profilePartlySavedTitle => 'Μερική αποθήκευση';

  @override
  String get profileSavedBody => 'Το προφίλ αποθηκεύτηκε.';

  @override
  String get profileChangePhoto => 'Αλλαγή φωτογραφίας';

  @override
  String get profilePhotoLabel => 'Φωτογραφία προφίλ';

  @override
  String get profilePhotoHint => 'Πατήστε για επιλογή νέας';

  @override
  String get profileBirthDateLabel => 'Ημερομηνία γέννησης (προαιρετικά)';

  @override
  String get profileBirthTimeLabel => 'Ώρα γέννησης (προαιρετικά)';

  @override
  String get profileBirthTimeHelper => 'Κάνει τις προτάσεις πιο ακριβείς';

  @override
  String get profileBirthPlaceLabel => 'Τόπος γέννησης (προαιρετικά)';

  @override
  String get profileBirthPlaceHint => 'Για παράδειγμα, Αθήνα, Ελλάδα';

  @override
  String get profileHelpContactTitle => 'Ρωτήστε μας';

  @override
  String get profileHelpContactBody =>
      'Στείλτε μήνυμα και θα απαντήσουμε μέσω email, συνήθως εντός μιας ημέρας.';

  @override
  String get profileHelpContactAction => 'Επικοινωνία υποστήριξης';

  @override
  String get profileHelpFaqTitle => 'Συχνές ερωτήσεις';

  @override
  String get profileFaqAddPiecesTitle =>
      'Πώς προσθέτω ρούχα στην ντουλάπα μου;';

  @override
  String get profileFaqAddPiecesBody =>
      'Πατήστε Προσθήκη στην καρτέλα Ντουλάπα. Βγάλτε φωτογραφία ή επιλέξτε από τη συλλογή σας, και εμείς θα τα εντοπίσουμε και θα τα κατηγοριοποιήσουμε.';

  @override
  String get profileFaqMatchingTitle => 'Πώς λειτουργεί ο συνδυασμός ρούχων;';

  @override
  String get profileFaqMatchingBody =>
      'Ανοίξτε το Για εσάς και επιλέξτε ρούχα που έχετε. Σας προτείνουμε ταιριαστά κομμάτια και δημιουργούμε πλήρη σύνολα από την ντουλάπα σας.';

  @override
  String get profileFaqTryOnTitle =>
      'Μπορώ να χρησιμοποιήσω δικές μου φωτογραφίες για δοκιμή;';

  @override
  String get profileFaqTryOnBody =>
      'Ναι. Προσθέστε μια ολόσωμη φωτογραφία σας και επιλέξτε ρούχα για να τα δείτε επάνω σας.';

  @override
  String get profileFaqRewardsTitle => 'Πώς κερδίζω επιβραβεύσεις;';

  @override
  String get profileFaqRewardsBody =>
      'Σχεδιάστε και καταγράψτε σύνολα συχνά. Τα σερί και τα επιτεύγματα αυξάνονται καθώς προχωράτε.';

  @override
  String get profileFaqPrivacyTitle => 'Είναι ιδιωτική η ντουλάπα μου;';

  @override
  String get profileFaqPrivacyBody =>
      'Ναι. Η ντουλάπα και τα σύνολά σας είναι ιδιωτικά, εκτός αν μοιραστείτε τον σύνδεσμο ενός συνόλου.';

  @override
  String get profileHelpMoreTitle => 'Περισσότερη βοήθεια';

  @override
  String get profileHelpGuides => 'Οδηγοί';

  @override
  String get profileHelpGuidesBody => 'Πώς λειτουργεί κάθε δυνατότητα';

  @override
  String get feedbackCategoryBug => 'Κάτι χάλασε';

  @override
  String get feedbackCategoryIdea => 'Μια ιδέα';

  @override
  String get feedbackCategoryGeneral => 'Γενικά';

  @override
  String get feedbackCategoryHelp => 'Χρειάζομαι βοήθεια';

  @override
  String get feedbackHintBug =>
      'Τι συνέβη και τι περιμένατε; Τα βήματα μάς βοηθούν να το διορθώσουμε.';

  @override
  String get feedbackHintIdea => 'Τι θα θέλατε και γιατί;';

  @override
  String get feedbackHintGeneral =>
      'Πείτε μας τη γνώμη σας ή κάντε μια ερώτηση.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Μπορείτε να προσθέσετε έως 5 εικόνες.';

  @override
  String get feedbackAttachmentLimitTitle => 'Φτάσατε το όριο';

  @override
  String get feedbackImageTooLargeBody => 'Επιλέξτε εικόνα κάτω από 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Πολύ μεγάλη εικόνα';

  @override
  String get feedbackTitle => 'Αποστολή σχολίων';

  @override
  String get feedbackAboutLabel => 'Σχετικά με τι;';

  @override
  String get feedbackSubjectLabel => 'Θέμα';

  @override
  String get feedbackSubjectRequired => 'Προσθέστε θέμα';

  @override
  String get feedbackSubjectTooShort =>
      'Το θέμα πρέπει να έχει τουλάχιστον 3 χαρακτήρες';

  @override
  String get feedbackDetailsLabel => 'Λεπτομέρειες';

  @override
  String get feedbackDetailsRequired => 'Προσθέστε μερικές λεπτομέρειες';

  @override
  String get feedbackDetailsTooShort =>
      'Η περιγραφή πρέπει να έχει τουλάχιστον 10 χαρακτήρες';

  @override
  String get feedbackAddScreenshot => 'Προσθήκη στιγμιότυπου';

  @override
  String get feedbackAttachmentHint => 'Έως 5, 5 MB το καθένα';

  @override
  String get feedbackSend => 'Αποστολή';

  @override
  String get feedbackEmptyTitle => 'Δεν έχει σταλεί τίποτα ακόμα';

  @override
  String get feedbackEmptyBody =>
      'Όσα στέλνετε εμφανίζονται εδώ μαζί με την κατάστασή τους.';

  @override
  String get feedbackHistoryTitle => 'Αυτά που στείλατε';

  @override
  String get feedbackStatusOpen => 'Ανοιχτό';

  @override
  String get feedbackStatusInProgress => 'Σε εξέλιξη';

  @override
  String get feedbackStatusResolved => 'Επιλύθηκε';

  @override
  String get feedbackStatusClosed => 'Κλειστό';

  @override
  String get legalIntro =>
      'Πώς προστατεύουμε τα δεδομένα σας και οι όροι χρήσης του FitCheck AI.';

  @override
  String get legalPolicies => 'Πολιτικές';

  @override
  String get legalPrivacySubtitle => 'Τι συλλέγουμε και γιατί';

  @override
  String get legalTermsTitle => 'Όροι χρήσης';

  @override
  String get legalTermsSubtitle => 'Οι κανόνες χρήσης της εφαρμογής';

  @override
  String get legalLicences => 'Άδειες ανοιχτού κώδικα';

  @override
  String get legalSupportSubtitle =>
      'Βοήθεια, επικοινωνία και αιτήματα απορρήτου';

  @override
  String get legalReportAbuse => 'Αναφορά προβλήματος ή κατάχρησης';

  @override
  String get permissionCameraTitle => 'Πρόσβαση στην κάμερα';

  @override
  String get permissionCameraRationale =>
      'Το FitCheck AI χρησιμοποιεί την κάμερά σας για λήψη φωτογραφιών των ρούχων και των συνόλων σας για δοκιμή AI και οργάνωση ντουλάπας.';

  @override
  String get permissionPhotoTitle => 'Πρόσβαση στις φωτογραφίες';

  @override
  String get permissionPhotoRationale =>
      'Το FitCheck AI χρειάζεται πρόσβαση στις φωτογραφίες σας για να επιλέγετε εικόνες ρούχων και συνόλων για λειτουργίες AI και τη ντουλάπα σας.';

  @override
  String get permissionNotNow => 'Όχι τώρα';

  @override
  String get permissionOpenSettings => 'Άνοιγμα ρυθμίσεων';

  @override
  String authSignedInAs(String name) {
    return 'Συνδεδεμένος ως $name';
  }

  @override
  String get authSignedIn => 'Συνδεθήκατε';

  @override
  String get authWelcomeBackTitle => 'Καλώς ήρθατε ξανά';

  @override
  String get authSignInFailed => 'Αποτυχία σύνδεσης';

  @override
  String get authWelcomeTitle => 'Καλώς ήρθατε';

  @override
  String get authSignUpFailed => 'Αποτυχία εγγραφής';

  @override
  String get authGoogleSignInFailed => 'Αποτυχία σύνδεσης με Google';

  @override
  String get authAppleSignInFailed => 'Αποτυχία σύνδεσης με Apple';

  @override
  String get authConfirmEmailTitle => 'Επιβεβαίωση email';

  @override
  String get authConfirmEmailBody =>
      'Ελέγξτε τα εισερχόμενά σας για το email επιβεβαίωσης και συνδεθείτε.';

  @override
  String get authClosetReady => 'Η ντουλάπα σας είναι έτοιμη.';

  @override
  String get authSignedOutTitle => 'Αποσυνδεθήκατε';

  @override
  String get authSignedOutBody => 'Έχετε αποσυνδεθεί.';

  @override
  String get authSignOutFailed => 'Αποτυχία αποσύνδεσης';

  @override
  String get authEmailSentTitle => 'Το email στάλθηκε';

  @override
  String get authResetLinkSent =>
      'Ελέγξτε το email σας για τον σύνδεσμο επαναφοράς.';

  @override
  String get authPasswordUpdatedTitle => 'Ο κωδικός ενημερώθηκε';

  @override
  String get authPasswordUpdated => 'Ο κωδικός πρόσβασης ενημερώθηκε.';

  @override
  String get authPasswordNotUpdated => 'Ο κωδικός δεν ενημερώθηκε';

  @override
  String get authCouldNotSendEmail => 'Αδυναμία αποστολής email';

  @override
  String get authEmailNotSent => 'Το email δεν στάλθηκε';

  @override
  String get authResendSentBody => 'Στείλαμε νέο email επιβεβαίωσης.';

  @override
  String get outfitPreviewWithAi => 'Προεπισκόπηση με AI';

  @override
  String get outfitNewPreview => 'Δημιουργία νέας προεπισκόπησης';

  @override
  String get outfitBuilderClosetHeading => 'Η ντρουάτα σου';

  @override
  String get outfitBuilderSearchHint => 'Αναζήτηση ειδών';

  @override
  String get outfitClearSearch => 'Καθαρισμός αναζήτησης';

  @override
  String get outfitBuilderAddPiecesTitle => 'Προσθέτα πρώτα είδη';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Τα σύνεργα δημιουργούνται από τα είδη της ντρουάτας σου.';

  @override
  String get outfitBuilderNoMatches => 'Κανένα είδος δεν ταιριάζει.';

  @override
  String get outfitNameLabel => 'Όνομα στυλ';

  @override
  String get outfitNameHint => 'Π.χ. Λινένιο σαββατοκύριακο';

  @override
  String get outfitPreviewSemantic => 'Προεπισκόπηση στυλ με AI';

  @override
  String get outfitChoosePieces => 'Επίλεξε είδη';

  @override
  String get outfitTapPiecesHint => 'Πάτα τα είδη παρακάτω για προσθήκη.';

  @override
  String get outfitShareTooltip => 'Κοινοποίηση';

  @override
  String get outfitSaveFavourite => 'Αποθήκευση σε αγαπημένα';

  @override
  String get outfitPiecesHeading => 'Είδη';

  @override
  String get outfitWearHistoryEmpty =>
      'Φόρεσέ το μία φορά και οι ημερομηνίες θα εμφανιστούν εδώ.';

  @override
  String get outfitWearHistoryTitle => 'Ιστορικό χρήσης';

  @override
  String get outfitWearHistoryError =>
      'Δεν ήταν δυνατή η φόρτωση των ημερομηνιών.';

  @override
  String get outfitWornOn => 'Φορέθηκε στις';

  @override
  String get outfitEditTitle => 'Επεξεργασία στυλ';

  @override
  String get outfitSavedPhotosFailed =>
      'Αποθηκεύτηκαν οι λεπτομέρειες, όχι οι φωτογραφίες';

  @override
  String get outfitNoPhotosBody =>
      'Δεν υπάρχουν φωτογραφίες ακόμα. Το στυλ εμφανίζει τα είδη του.';

  @override
  String get outfitOccasionLabel => 'Κακοκαιρία';

  @override
  String get outfitOccasionNone => 'Κανένα';

  @override
  String get outfitTagsHint => 'Αποχωρίστε με κόμματα';

  @override
  String get outfitDraftBody => 'Απόκρυφο από την κύρια λίστα σου';

  @override
  String get outfitPublic => 'Δημόσιο';

  @override
  String get outfitPublicBody => 'Όποιος έχει το σύνδεσμο μπορεί να το δει';

  @override
  String get outfitDeleteFromDetail =>
      'Διαγράψε αυτό το στυλ από τη σελίδα λεπτομερειών.';

  @override
  String get outfitNewCollection => 'Νέα συλλογή';

  @override
  String get outfitNoCollectionsTitle => 'Δεν υπάρχουν συλλογές';

  @override
  String get outfitNoCollectionsBody =>
      'Ομαδοποιήστε τα ρούχα σας ανά ταξίδι, εποχή ή διάθεση.';

  @override
  String get outfitCreateCollection => 'Δημιουργία συλλογής';

  @override
  String get outfitAddOutfits => 'Προσθήκη κολεξιόν';

  @override
  String get outfitRename => 'Μετα ονομασία';

  @override
  String get outfitCollectionDeleteBody =>
      'Τα κολεξιόν που βρίσκονται μέσα παραμένουν.';

  @override
  String get outfitCollectionsNotLoaded => 'Τα κολεξιόν δεν φορτώθηκαν';

  @override
  String get outfitRenameCollection => 'Μετα ονομασία συλλογής';

  @override
  String get outfitDescriptionOptional => 'Περιγραφή (προαιρετικά)';

  @override
  String get outfitAllInCollection =>
      'Κάθε κολεξιόν είναι ήδη σε αυτήν τη συλλογή.';

  @override
  String get photoshootSubtitleUpload =>
      'Στούντιο πορτρέτα από τις δικές σας φωτογραφίες';

  @override
  String get photoshootSubtitleConfigure => 'Επιλέξτε στυλ, μορφή και αριθμό';

  @override
  String get photoshootSubtitleGenerating => 'Χρειάζεται ένα δύο λεπτά';

  @override
  String get photoshootAddPhotosSemantic =>
      'Προσθέστε φωτογραφίες από την γαλλERIA σας';

  @override
  String get photoshootUploadTitle => 'Προσθέστε 1 έως 4 φωτογραφίες σας';

  @override
  String get photoshootUploadBody => 'Πατήστε για επιλογή από τη γκαλερί';

  @override
  String get photoshootAddToContinue =>
      'Προσθέστε μια φωτογραφία για να συνεχίσετε';

  @override
  String get photoshootAddAnotherPhoto => 'Προσθέστε μια άλλη φωτογραφία';

  @override
  String get photoshootTipsTitle => 'Για τα καλύτερα αποτελέσματα';

  @override
  String get photoshootTipsBody =>
      'Χρησιμοποιήστε καθαρές, καλά φωτισμένες φωτογραφίες του προσώπου σας από διάφορες οπτικές γωνίες. Αποφύγετε γαλλERIA και καπέλα.';

  @override
  String get photoshootStarting => 'Έναρξη';

  @override
  String get photoshootCancelling => 'Ακύρωση';

  @override
  String get photoshootFailed => 'Απέτυχε';

  @override
  String get recommendTabMatches => 'Ανακοινώσεις';

  @override
  String get recommendTabComplete => 'Πλήρη';

  @override
  String get recommendTabWeather => 'Καιρός';

  @override
  String get recommendTabColours => 'Χρώματα';

  @override
  String get recommendTabShop => 'Πώληση';

  @override
  String get recommendNoMatchesTitle => 'Δεν υπάρχουν ακόμη ανακοινώσεις';

  @override
  String get recommendNoMatchesBody =>
      'Διάλεξε ένα ρούχο και θα βρούμε τι πάει μαζί του.';

  @override
  String get recommendPickPiece => 'Διάλεξε ένα ρούχο';

  @override
  String get recommendNothingMatchesTitle => 'Κάτι δεν ταιριάζει ακόμα';

  @override
  String get recommendNothingMatchesBody =>
      'Δοκίμασε άλλα ρούχα ή πρόσθεσε περισσότερα στο ντουλάπι σου.';

  @override
  String get recommendChangePieces => 'Άλλαξε ρούχα';

  @override
  String get recommendDefaultReason => 'Ταιριάζει στα ρούχα που διάλεξες.';

  @override
  String get recommendCompleteTitle => 'Συμπλήρωσε ένα look';

  @override
  String get recommendCompleteBody =>
      'Διάλεξε ένα ρούχο και θα συμπληρώσουμε τα υπόλοιπα.';

  @override
  String get recommendWorking => 'Διαδικασία';

  @override
  String get recommendGenerate => 'Δημιουργία';

  @override
  String get recommendChooseStyleBody => 'Διάλεξε στυλ και συνέχισε.';

  @override
  String get recommendNoLooksTitle => 'Καμία ιδέα για αυτά τα ρούχα';

  @override
  String get recommendNoLooksBody => 'Δοκίμασε άλλο στυλ ή άλλα ρούχα.';

  @override
  String get recommendDefaultLook => 'Ένα look για τα ρούχα σου';

  @override
  String get recommendNoPiecesBody => 'Δεν βρέθηκαν ρούχα για αυτό το look.';

  @override
  String get recommendCityLabel => 'Πόλη';

  @override
  String get recommendCheck => 'Έλεγχος';

  @override
  String get recommendWeatherTitle => 'Τι καιρός κάνει;';

  @override
  String get recommendWeatherBody =>
      'Συμπλήρωσε την πόλη σου για ιδέες για σήμερα.';

  @override
  String get recommendWearToday => 'Φόρα σήμερα';

  @override
  String get recommendWeatherNoPieces =>
      'Δεν υπάρχουν ρούχα στο ντουλάπι σου για αυτόν τον καιρό.';

  @override
  String get recommendBudgetLabel => 'Μέγιστο κόστος';

  @override
  String get recommendLooking => 'Αναζήτηση';

  @override
  String get recommendFindWhatToBuy => 'Βρέσε τι να αγοράσεις';

  @override
  String get recommendFillGapsTitle => 'Συμπλήρωσε τα κενά';

  @override
  String get recommendFillGapsBody =>
      'Ορίσε προϋπολογισμό και θα σου προτείνουμε τι λείπει.';

  @override
  String get recommendNoGapsTitle => 'Δεν βρέθηκαν κενά';

  @override
  String get recommendNoGapsBody =>
      'Δοκίμασε μεγαλύτερο προϋπολογισμό ή άλλη κατηγορία.';

  @override
  String get recommendMoodEveryday => 'Καθημερινό';

  @override
  String get recommendMoodBigMeeting => 'Σημαντική συνάντηση';

  @override
  String get recommendDayLabel => 'Μέρα';

  @override
  String get recommendReadingStars => 'Διαβάζω τα αστέρια';

  @override
  String get recommendGetMyColours => 'Δες τα χρώματά σου';

  @override
  String get recommendLuckyColoursTitle => 'Τα τυχερά σου χρώματα';

  @override
  String get recommendLuckyColoursBody =>
      'Επίλεξε μια ημέρα και θα σου προτείνουμε χρώματα και ρούχα.';

  @override
  String get recommendLuckyColoursSection => 'Τυχερά χρώματα';

  @override
  String get recommendAvoidColoursSection => 'Χρώματα που αποφεύγεις';

  @override
  String get recommendBirthDateTitle => 'Πρόσθεσε τη γέννησή σου';

  @override
  String get recommendBirthDateBody =>
      'Χρειαζόμαστε τη γενέθλια ημερομηνία σου για να διαβάσουμε τα χρώματά σου.';

  @override
  String get recommendEditProfile => 'Επεξεργασία προφίλ';

  @override
  String get recommendNothingThisDay => 'Καμία πρόταση για σήμερα.';

  @override
  String get recommendUnnamedColour => 'Άγνωστο χρώμα';

  @override
  String get recommendFromCloset => 'Από την γκαρνταρόμπά σου';

  @override
  String get recommendNoPiecesInColours =>
      'Δεν υπάρχουν ρούχα με αυτά τα χρώματα ακόμα.';

  @override
  String get recommendOutfitIdeas => 'Ιδέες συνδυασμών';

  @override
  String get recommendNoOutfitsInColours =>
      'Δεν υπάρχει ολοκληρωμένος συνδυασμός με αυτά τα χρώματα ακόμα.';

  @override
  String get recommendDefaultOutfitIdea => 'Μια ιδέα συνδυασμού';

  @override
  String get recommendPickUpToThree => 'Επίλεξε έως τρία ρούχα';

  @override
  String get recommendEmptyClosetBody =>
      'Πρόσθεσε πρώτα κάποια ρούχα και μετά δες τα ταιριάσματα.';

  @override
  String get dashboardDressForDay => 'Ντύσου ανάλογα με τη μέρα.';

  @override
  String get dashboardOutfitOfDay => 'Το outfit της ημέρας';

  @override
  String get dashboardFreshLook => 'Φρέσκι new look';

  @override
  String get subscriptionManageInStoreTitle => 'Διαχείριση στο κατάστημα';

  @override
  String get subscriptionManageInStoreBody =>
      'Ο σχεδιασμός χρέεται μέσω του καταστήματος. Διάλεξε τον λογαριασμό του καταστήματός σου.';

  @override
  String get subscriptionCancelledTitle => 'Η συνδρομή ακυρώθηκε';

  @override
  String get subscriptionCancelledBody =>
      'Η συνδρομή σου θα παραμείνει ενεργή μέχρι το τέλος της τρέχουσας περιόδου.';

  @override
  String get subscriptionCancelFailedTitle => 'Η ακύρωση δεν ολοκληρώθηκε';

  @override
  String get subscriptionCouldNotOpenTitle => 'Δεν ανοίχτηκε';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Δεν ήταν δυνατή η άνοιξη διαχείρισης χρεώσεων.';

  @override
  String get subscriptionOpenLinkFailedBody =>
      'Δεν ήταν δυνατή η άνοιξη του συνδέσμου.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Δεν ήταν δυνατή η φόρτωση του συνδέσμου σας';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Δεν ήταν δυνατή η φόρτωση του συνδέσμου παραπομπής σας. Δοκιμάστε ξανά.';

  @override
  String get subscriptionReferralCopiedTitle => 'Αντιγράφηκε';

  @override
  String get subscriptionReferralCopiedBody =>
      'Ο σύνδεσμος παραπομπής αντιγράφηκε.';

  @override
  String get subscriptionReferralShareSubject => 'Δοκιμάστε το FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Γίνετε μέλος του FitCheck AI και και οι δύο θα λάβετε ένα μήνα Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Ο σύνδεσμος αντιγράφηκε';

  @override
  String get subscriptionShareUnavailableBody =>
      'Η κοινή χρήση δεν είναι διαθέσιμη, οπότε αντιγράψαμε τον σύνδεσμο.';

  @override
  String get subscriptionShareFailedTitle => 'Δεν ήταν δυνατή η κοινή χρήση';

  @override
  String get subscriptionShareFailedBody =>
      'Αντιγράψτε τον σύνδεσμο από τη σελίδα παραπομπής αντί γι\' αυτό.';

  @override
  String get subscriptionStoreReadyTitle => 'Το κατάστημα είναι έτοιμο';

  @override
  String get subscriptionStoreReadyBody =>
      'Οι τιμές του καταστήματος είναι διαθέσιμες. Μπορείτε να αναβαθμίσετε τώρα.';

  @override
  String get purchaseFailedTitle => 'Η αγορά αποτυγχάνει';

  @override
  String get purchaseUnavailableTitle => 'Η αγορά δεν είναι διαθέσιμη';

  @override
  String get purchaseIapUnavailableBody =>
      'Οι εσωτερικές αγορές δεν είναι διαθέσιμες σε αυτή τη συσκευή.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Αυτός ο σχεδιασμός δεν είναι διαθέσιμος για αγορά ακόμη.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Αυτός ο σχεδιασμός δεν είναι διαθέσιμος στο κατάστημα ακόμη. Ελέγξτε ξανά σύντομα.';

  @override
  String get purchaseStartFailedBody =>
      'Η διαδικασία αγοράς δεν ξεκίνησε. Δοκιμάστε ξανά.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Η πληρωμή δεν επέστρεψε σύνδεσμο πληρωμής.';

  @override
  String get purchasePendingTitle => 'Πendente αγορά';

  @override
  String get purchasePendingBody =>
      'Η αγορά σας περιμένει έγκριση. Θα αποκτήσετε πρόσβαση μόλις εγκριθεί.';

  @override
  String get purchaseFailedBody => 'Η αγορά αποτυγχάνει. Δοκιμάστε ξανά.';

  @override
  String get purchaseRestoredTitle => 'Επαναφύγεται';

  @override
  String get purchaseRestoredBody => 'Οι αγορές σας επαναφύγηκαν.';

  @override
  String get purchaseActiveTitle => 'Ενεργή συνδρομή';

  @override
  String get purchaseActiveBody => 'Η συνδρομή σας είναι ενεργή. Καλώς ήρθατε.';

  @override
  String get purchaseSignInRequiredTitle => 'Απαιτείται είσοδος';

  @override
  String get purchaseSignInRequiredBody =>
      'Συνδεθείτε για να ολοκληρώσετε την αγορά σας.';

  @override
  String get purchaseErrorTitle => 'Σφάλμα αγοράς';

  @override
  String get purchaseInvalidTransactionBody =>
      'Η αγορά δεν περιλαμβάνει αναγνωρίσιμο διαλογισμό.';

  @override
  String get purchaseVerificationPendingTitle => 'Επείσα επαλήθευση';

  @override
  String get purchaseVerificationPendingBody =>
      'Δεν μπορέσαμε να επιβεβαιώσουμε την αγορά σας μέσω του καταστήματος τώρα. Θα ολοκληρωθεί αυτόματα και δεν θα χρεωθείτε δύο φορές.';

  @override
  String get purchaseNotAppliedTitle => 'Η αγορά δεν εφαρμόστηκε';

  @override
  String get purchaseNotAppliedBody =>
      'Η αγορά σας δεν μπόρεσε να εφαρμόστεί στον λογαριασμό σας. Επικοινωνήστε με την υποστήριξη και μην την αγοράσετε ξανά.';

  @override
  String get purchaseRestoreFailedTitle => 'Αποκατάσταση αποτυχόν';

  @override
  String get purchaseRestoreFailedBody =>
      'Δεν μπόρεσε να επαναληφθούν οι αγορές. Δοκιμάστε ξανά.';

  @override
  String get purchaseRecoveredActiveBody => 'Η συνδρομή σας είναι ενεργή.';

  @override
  String get purchaseCompleteTitle => 'Η αγορά ολοκληρώθηκε';

  @override
  String get giftCreateFailedTitle => 'Δεν δημιουργήθηκε το δώρο';

  @override
  String get giftClaimFailedTitle => 'Δεν αποκτήθηκε το δώρο';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count δώρα για εσάς',
      one: 'Ένα δώρο για εσάς',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 μήνας',
      '12': '1 έτος',
      'other': '$months μήνες',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'απομένουν $remaining',
      one: 'απομένει 1',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return 'Ο $sender σας έστειλε $duration FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Ένα δώρο FitCheck Pro για $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Από $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Για $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Από $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'ο παραλήπτης σας';

  @override
  String get giftPreviewPlaceholderSender => 'εσείς';

  @override
  String get settingsSavedTitle => 'Αποθηκεύτηκε';

  @override
  String get settingsNotSavedTitle => 'Δεν αποθηκεύτηκε';

  @override
  String get settingsAiChooseProviderBody => 'Επιλέξτε έναν πάροχο.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Ο προσαρμοσμένος πάροχος απαιτεί URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Εισάγετε έναν κλειδί API.';

  @override
  String get settingsAiSavedBody => 'Οι ρυθμίσεις AI σας αποθηκεύτηκαν.';

  @override
  String get settingsAiMissingDetailsTitle => 'Λείπουν λεπτομέρειες';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Εισάγετε URL API και ένα μοντέλο συνομιλίας για δοκιμή.';

  @override
  String get settingsAiKeyNeededTitle => 'Απαιτείται κλειδί API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Εισάγετε το κλειδί API για δοκιμή. Το αποθηκευμένο κλειδί παραμένει ιδιωτικό.';

  @override
  String get settingsAiKeyToTestBody => 'Εισάγετε το κλειδί API για δοκιμή.';

  @override
  String get settingsAiConnectedTitle => 'Συνδεδεμένο';

  @override
  String get settingsAiConnectedBody => 'Η σύνδεση λειτουργεί.';

  @override
  String get settingsAiTestFailedTitle => 'Η δοκιμή απέτυχε';

  @override
  String get settingsPreferencesSavedBody =>
      'Οι προτιμήσεις σας έχουν αποθηκευτεί.';

  @override
  String get settingsPasswordNotChangedTitle => 'Η κωδική δεν άλλαξε';

  @override
  String get settingsOAuthPasswordBody =>
      'Ο λογαριασμός συνδέεται με Google ή Apple. Χρησιμοποιήστε την «Ξέχασα κωδικό» για να ορίσετε αρχικά έναν κωδικό.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Ο τρέχων κωδικός είναι εσφαλμένος.';

  @override
  String get settingsExportReadyTitle => 'Έξοδος έτοιμη';

  @override
  String get settingsExportReadyBody =>
      'Η εξαγωγή δεδομένων σας είναι έτοιμη για λήψη.';

  @override
  String get settingsLinkCopiedTitle => 'Σύνδεσμος αντιγράφηκε';

  @override
  String get settingsExportClipboardBody =>
      'Δεν μπορούμε να ανοίξουμε τον προγραμματιστή σας, οπότε αντιγράφαμε τον σύνδεσμο. Επικόλληστε τον σε ένα πρόγραμμα πρόσβασης: λήγει σύντομα.';

  @override
  String get settingsExportFailedTitle => 'Η εξαγωγή απέτυχε';

  @override
  String get settingsAccountNotDeletedTitle => 'Ο λογαριασμός δεν διαγράφηκε';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Μπορείτε να προσθέσετε έως $max φωτογραφίες.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Όριο φωτογραφιών';

  @override
  String get photoshootAddAtLeastOnePhoto =>
      'Προσθέστε τουλάχιστον μία φωτογραφία.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Χωρίς φωτογραφίες';

  @override
  String get photoshootDescribeLookBody => 'Περιγράψτε το look που θέλετε.';

  @override
  String get photoshootPromptNeededTitle => 'Απαιτείται οδηγία';

  @override
  String get photoshootConsentFeatureLabel => 'AI Φωτογράφιση';

  @override
  String get photoshootStatusPreparing => 'Προετοιμασία φωτογραφιών σας';

  @override
  String get photoshootStatusGenerating => 'Δημιουργία';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Συνομηνή $current από $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done από $total ολοκληρώθηκαν';
  }

  @override
  String get photoshootGenerationFailedBody => 'Η δημιουργία απέτυχε.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready έτοιμα, $failed αποτυχίες.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Μερικώς ολοκληρωμένο';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φωτογραφίες είναι έτοιμες.',
      one: '1 φωτογραφία είναι έτοιμη.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Η σύνδεση διακοπεί. Παρακαλώ δοκιμάστε ξανά.';

  @override
  String get photoshootCouldNotCancelTitle => 'Δεν ήταν δυνατή η ακύρωση';

  @override
  String get photoshootRetryFailedTitle => 'Η επανάληψη απέτυχε';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Η φωτογραφία $number είναι έτοιμη.';
  }

  @override
  String get photoshootReplacedTitle => 'Αντικαταστάθηκε';

  @override
  String get photoshootSavedToGalleryBody => 'Αποθηκεύτηκε στη ρυθμιστική σας.';

  @override
  String get photoshootSavedTitle => 'Αποθηκεύτηκε';

  @override
  String get photoshootNotSavedTitle => 'Δεν αποθηκεύτηκε';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Όλες οι $count φωτογραφίες είναι στη ρυθμιστική σας.',
      one: '1 φωτογραφία είναι στη ρυθμιστική σας.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved από $total αποθηκεύτηκαν.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Κάποιες φωτογραφίες δεν αποθηκεύτηκαν';

  @override
  String get tryonConsentFeatureLabel => 'Εικονική Δοκιμή';

  @override
  String get tryonAvatarUpdatedBody => 'Η φωτογραφία σας ενημερώθηκε.';

  @override
  String get tryonSavedTitle => 'Αποθηκεύτηκε';

  @override
  String get tryonUploadFailedTitle => 'Η φόρτωση απέτυχε';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Επιλέξτε πρώτα μια φωτογραφία ρούχου.';

  @override
  String get tryonNoGarmentTitle => 'Χωρίς ρούχο';

  @override
  String get tryonWaitForUploadBody =>
      'Αναμονή για την ολοκλήρωση της φόρτωσης της φωτογραφίας σας.';

  @override
  String get tryonStillUploadingTitle => 'Στη συνέχεια φόρτωσης';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Προσθέστε πρώτα μια φωτογραφία από εσάς.';

  @override
  String get tryonReadyBody => 'Η δοκιμή σας είναι έτοιμη.';

  @override
  String get tryonFailedTitle => 'Η δοκιμή απέτυχε';

  @override
  String get tryonSavedToGalleryBody => 'Αποθηκεύτηκε στη ρυθμιστική σας.';

  @override
  String get tryonNotSavedTitle => 'Δεν αποθηκεύτηκε';

  @override
  String get calendarEventAddedBody => 'Το γεγονός προστέθηκε';

  @override
  String get calendarEventPlannedTitle => 'Προγραμματίστηκε';

  @override
  String get calendarEventSavedBody => 'Το γεγονός αποθηκεύτηκε';

  @override
  String get calendarSavedTitle => 'Αποθηκεύτηκε';

  @override
  String get calendarEventNotSavedTitle => 'Το γεγονός δεν αποθηκεύτηκε';

  @override
  String get calendarEventRemovedBody => 'Το γεγονός αφαιρέθηκε';

  @override
  String get calendarEventDeletedTitle => 'Διαγράφηκε';

  @override
  String get calendarEventNotDeletedTitle => 'Η εκδήλωση δεν διαγράφηκε';

  @override
  String get calendarOutfitNotLinkedTitle => 'Το συνδυασμός δεν συνδέθηκε';

  @override
  String get calendarLinkedTitle => 'Συνδέθηκε';

  @override
  String get calendarOutfitNotRemovedTitle => 'Το συνδυασμός δεν αφαιρέθηκε';

  @override
  String get calendarOutfitRemovedBody => 'Το συνδυασμός αφαιρέθηκε';

  @override
  String get calendarDisconnectedBody => 'Το ημερολόγιο αποσυνδέθηκε';

  @override
  String get calendarDisconnectedTitle => 'Αποσυνδέθηκε';

  @override
  String get calendarNotDisconnectedTitle => 'Το ημερολόγιο δεν αποσυνδέθηκε';

  @override
  String get calendarTodayLabel => 'σήμερα';

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
    return 'από $start έως $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, συνδυασμός συνδεδεμένος';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return 'Το \"$title\" θα αφαιρεθεί.';
  }

  @override
  String get calendarThisAppLabel => 'Αυτή η εφαρμογή';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Η συγχρονισμός με το $provider δεν είναι διαθέσιμη ακόμα. Μπορείτε να προσθέσετε γεγονότα εδώ.';
  }

  @override
  String get calendarWeekdaySunShort => 'Κυρ';

  @override
  String get calendarWeekdayMonShort => 'Δευ';

  @override
  String get calendarWeekdayTueShort => 'Τρί';

  @override
  String get calendarWeekdayWedShort => 'Τετ';

  @override
  String get calendarWeekdayThuShort => 'Πέμ';

  @override
  String get calendarWeekdayFriShort => 'Παρ';

  @override
  String get calendarWeekdaySatShort => 'Σαβ';

  @override
  String get calendarWeekdayMonday => 'Δευτέρα';

  @override
  String get calendarWeekdayTuesday => 'Τρίτη';

  @override
  String get calendarWeekdayWednesday => 'Τετάρτη';

  @override
  String get calendarWeekdayThursday => 'Πέμπτη';

  @override
  String get calendarWeekdayFriday => 'Παράσκευή';

  @override
  String get calendarWeekdaySaturday => 'Σάββατο';

  @override
  String get calendarWeekdaySunday => 'Κυριακή';

  @override
  String get outfitSavedToFavouritesBody => 'Αποθηκεύτηκε στα αγαπημένα';

  @override
  String get outfitRemovedFromFavouritesBody => 'Αφαιρέθηκε από τα αγαπημένα';

  @override
  String get outfitNotSavedTitle => 'Δεν αποθηκεύτηκε';

  @override
  String get outfitLoggedAsWornBody => 'Εγγραφή ως φορεμένο σήμερα.';

  @override
  String get outfitNicePickTitle => 'Καλή επιλογή';

  @override
  String get outfitRemovedBody => 'Το outfit αφαιρέθηκε.';

  @override
  String get outfitDeletedTitle => 'Διαγράφηκε';

  @override
  String get outfitNotDeletedTitle => 'Δεν διαγράφηκε';

  @override
  String get outfitDuplicatedBody =>
      'Ένα αντίγραφο υπάρχει στις εμφανίσεις σας.';

  @override
  String get outfitDuplicatedTitle => 'Διπλασιάστηκε';

  @override
  String get outfitNotDuplicatedTitle => 'Δεν διπλασιάστηκε';

  @override
  String get outfitNotSharedTitle => 'Δεν μοιράστηκε';

  @override
  String outfitCollectionReadyBody(String name) {
    return '«$name» είναι έτοιμη.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Η συλλογή δεν δημιουργήθηκε';

  @override
  String get outfitCollectionUpdatedBody => 'Η συλλογή ενημερώθηκε.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Η συλλογή δεν ενημερώθηκε';

  @override
  String get outfitCollectionDeletedBody => 'Η συλλογή διαγράφηκε.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Η συλλογή δεν διαγράφηκε';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits προστέθηκαν.',
      one: 'Προστέθηκε 1 outfit.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Τα outfits δεν προστέθηκαν';

  @override
  String get outfitPreviewNotCreatedTitle =>
      'Η προεπισκόπηση δεν δημιουργήθηκε';

  @override
  String get outfitGiveNameBody => 'Δώστε όνομα στο outfit.';

  @override
  String get outfitNameMissingTitle => 'Όνομα';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'Επιλέξτε τουλάχιστον ένα κομμάτι.';

  @override
  String outfitCreatedBody(String name) {
    return 'Το $name είναι στις εμφανίσεις σας.';
  }

  @override
  String get outfitSavedTitle => 'Αποθηκεύτηκε';

  @override
  String get wardrobeAddedToFavouritesBody => 'Προστέθηκε στα αγαπημένα';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Αφαιρέθηκε από τα αγαπημένα';

  @override
  String get wardrobeNotSavedTitle => 'Δεν αποθηκεύτηκε';

  @override
  String get wardrobeLoggedAsWornBody => 'Καταγράφηκε ως φορεμένο σήμερα.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Αφαίρεση από την νταριέρα σας.';

  @override
  String get wardrobeDeletedTitle => 'Διαγράφηκε';

  @override
  String get wardrobeNotDeletedTitle => 'Δεν διαγράφηκε';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ρούχα αφαιρέθηκαν από την νταριέρα σας.',
      one: '1 ρούχο αφαιρέθηκε από την νταριέρα σας.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Εξαγωγή Νταριέρας AI';

  @override
  String get itemAddScanJobLabel => 'Σάρωση';

  @override
  String get itemAddFoundEarlierBody => 'Βρέθηκε σε προηγούμενη σάρωση';

  @override
  String get itemAddLookingAtPhoto => 'Μελέτης φωτογραφίας σας';

  @override
  String get itemAddExtractionFailedBody => 'Αποτυχία εξαγωγής';

  @override
  String get itemAddJobFailedBody => 'Η εργασία απέτυχε';

  @override
  String get itemAddConnectionLostBody => 'Χάθηκε η σύνδεση. Δοκιμάστε ξανά.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Χάθηκε η σύνδεση κατά την επεξεργασία.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Ρούχο $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Ρούχο';

  @override
  String get itemAddNotCancelledTitle => 'Δεν ακυρώθηκε';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ρούχα προστέθηκαν στην νταριέρα σας.',
      one: '1 ρούχο προστέθηκε στην νταριέρα σας.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved από $total ρούχα αποθηκεύτηκαν. Πατήστε αποθήκευση για δοκιμή των υπόλοιπων ξανά.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Κάποια ρούχα δεν αποθήκευτηκαν';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'Επιλέξτε τουλάχιστον μία φωτογραφία.';

  @override
  String get batchPhotoUnreadableBody =>
      'Αυτή η φωτογραφία δεν μπορεί να αναγνωσθεί.';

  @override
  String get batchNoPhotosReadableBody =>
      'Καμία από αυτές τις φωτογραφίες δεν μπορεί να αναγνωσθεί. Δοκιμάστε άλλες.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φωτογραφίες',
      one: '1 φωτογραφία',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Χάθηκε η σύνδεση κατά την εργασία. Δοκιμάστε ξανά.';

  @override
  String get batchNotCancelledTitle => 'Δεν ακυρώθηκε';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Σύνδεσμοι δημοσιεύσεων δεν υποστηρίζονται. Εισάγετε σύνδεσμο προφίλ.';

  @override
  String get batchLinkSpacesBody =>
      'Οι σύνδεσμοι δεν μπορούν να περιέχουν κενά.';

  @override
  String get batchEnterProfileLinkBody =>
      'Εισάγετε σύνδεσμο προφίλ Instagram ή Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Εισάγετε σύνδεσμο προφίλ.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Η σελίδα σύνδεσης δεν άνοιξε. Δοκιμάστε ξανά.';

  @override
  String get batchSignInBrowserBody =>
      'Συνδέστε στο browser και επιστρέψτε στο FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Σύνδεση του λογαριασμού σας';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Εισάγετε τον κωδικό από την εφαρμογή authentication.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Το Instagram ζητά έλεγχο ασφαλείας. Συνδεθείτε πρώτα μέσω browser.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Εισάγετε ξανά το username και τον κωδικό σας.';

  @override
  String get batchSignInFailedBody =>
      'Αποτυχία σύνδεσης. Επαλημύστε το username και τον κωδικό σας.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Συνδεθείτε για να συνεχίσει η εισαγωγή.';

  @override
  String get batchAccountNotConnectedBody => 'Ο λογαριασμός δεν συνδέθηκε.';

  @override
  String get batchAccountConnectedTitle => 'Ο λογαριασμός συνδέθηκε';

  @override
  String get batchNotConnectedTitle => 'Δεν συνδέθηκε';

  @override
  String get batchImportConnectionLostBody =>
      'Χάσαμε τη σύνδεση της εισαγωγής. Ανανεώστε για να ελέγξετε.';

  @override
  String batchPickUpToBody(int max) {
    return 'Επιλέξτε έως και $max φωτογραφίες. Εμείς θα βρούμε τα ρούχα.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count από $total φωτογραφίες';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Ετοιμασία φωτογραφίας $done από $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Αναζήτηση ρούχων σε $count φωτογραφίες',
      one: 'Αναζήτηση ρούχων σε 1 φωτογραφία',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Ο λογαριασμός σας $platform χρησιμοποιεί δύο βήματα σύνδεσης. Εισάγετε τον κωδικό 6 ψηφίων από την εφαρμογή authentication.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Αυτό το $platform προφίλ είναι ιδιωτικό ή χρειάζεται σύνδεση για να εμφανίσει τις φωτογραφίες του.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Σύνδεση μέσω $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Βρέθηκαν $count φωτογραφίες finora',
      one: 'Βρέθηκε 1 φωτογραφία finora',
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
    return '$processed από $total επεξεργασμένες · $added προστέθηκαν · $waiting αναμένονται · $skipped παραλείφθηκαν';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Σάρωση φωτογραφίας $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Η φωτογραφία $number είναι στην επόμενη σειρά';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Φωτογραφία $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Βρέθηκαν $count ρούχα',
      one: 'Βρέθηκε 1 ρούχο',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φωτογραφίες προστέθηκαν στη γκαρνταρόμπα σας.',
      one: '1 φωτογραφία προστέθηκε στην γκαρνταρόμπα σας.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ακόμη φωτογραφίες στούντιο έρχονται. Μπορείτε να αποθηκεύσετε όσα είναι έτοιμα ή να φύγετε και θα σας ενημερώσουμε.',
      one:
          '1 ακόμη φωτογραφία στούντιο έρχεται. Μπορείτε να αποθηκεύσετε όσα είναι έτοιμα ή να φύγετε και θα σας ενημερώσουμε.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Δεν αποθηκεύθηκαν ακόμα: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces ρούχα',
      one: '1 ρούχο',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos φωτογραφίες',
      one: '1 φωτογραφία',
    );
    return '$_temp0 από $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen επιλέγονται. Πατήστε ένα ρούχο για να το παραλείψετε.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Αποθήκευση $count ρούχων',
      one: 'Αποθήκευση 1 ρούχου',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Αποθήκευση $count αντικειμένων',
      one: 'Αποθήκευση 1 αντικειμένου',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Η καρτέλα σώματος αποθηκεύτηκε.';

  @override
  String get bodyProfileSavedTitle => 'Αποθηκεύτηκε';

  @override
  String get bodyProfileNotSavedTitle => 'Δεν αποθηκεύτηκε';

  @override
  String get bodyProfileSetDefaultBody => 'Ορισμός ως προφίλ προεπιλογής.';

  @override
  String get bodyProfileDeletedBody => 'Η καρτέλα σώματος διαγράφηκε.';

  @override
  String get bodyProfileDeletedTitle => 'Διαγράφηκε';

  @override
  String get bodyProfileNotDeletedTitle => 'Δεν διαγράφηκε';

  @override
  String get feedbackNotSentTitle => 'Δεν στάλθηκε';

  @override
  String get feedbackSentBody =>
      'Ευχαριστούμε. Διαβάζουμε όλα τα μηνύματα και απαντάμε αν χρειαζόμαστε περισσότερα.';

  @override
  String get feedbackSentTitle => 'Η αποστολή ολοκληρώθηκε';

  @override
  String get recommendUnnamedPiece => 'Όνομα ρούχου δεν έχει οριστεί';

  @override
  String get recommendEnterCityBody =>
      'Δώσε την πόλη σου για προτάσεις που ταιριάζουν στο κλίμα.';

  @override
  String get recommendWhichCityTitle => 'Ποια πόλη;';

  @override
  String get aiConsentSheetTitle => 'Κοινοποίηση φωτογραφιών σε υπηρεσία Τ.Υ.';

  @override
  String get aiConsentSheetBody =>
      'Για να δημιουργήσουμε εικόνες δοκιμής και φωτογράφισης, το FitCheck AI στέλνει τις φωτογραφίες που δίνεις (συμπεριλαμβανομένων εικόνων προσώπου και σώματος) σε αξιόπιστο τρίτο πάροχο Τ.Υ. (όπως OpenAI ή Google Gemini) για επεξεργασία. Δημιουργούν τις εικόνες σου και δεν τις χρησιμοποιούν για εκπαίδευση μοντέλων υπό τους όρους μας. Οι φωτογραφίες μεταδίδονται με ασφάλεια και δεν κοινοποιούνται ποτέ για διαφήμιση.';

  @override
  String get aiConsentSheetPermission =>
      'Συνεχίζοντας, δίνεις ρητή άδεια για τη διαβίβαση των φωτογραφιών σου σε αυτούς τους παρόχους Τ.Υ. για δημιουργία εικόνας.';

  @override
  String get skeletonsLoadMoreFailed =>
      'Δεν ήταν δυνατός ο φόρτωση περισσότερων.';

  @override
  String get jobsPiecesReadyTitle => 'Τα ρούχα σου είναι έτοιμα';

  @override
  String get jobsScanStoppedTitle => 'Η σάρωση σταμάτησε';

  @override
  String get jobsNothingSavedBody => 'Δεν αποθηκεύτηκε τίποτα. Δοκίμασε ξανά.';

  @override
  String get jobsPhotoUploadFailedBody => 'Η αποστολή φωτογραφίας απέτυχε.';

  @override
  String get authGoogleSignInStartFailed =>
      'Δεν ήταν δυνατή η έναρξη της σύνδεσης μέσω Google. Δοκίμασε ξανά.';

  @override
  String get referralAppliedTitle => 'Η αναφορά εφαρμόστηκε!';

  @override
  String get billingStoreUnavailableBody =>
      'Οι αγορές από το κατάστημα δεν είναι διαθέσιμες σε αυτή τη συσκευή.';

  @override
  String get billingPurchaseProcessingBody =>
      'Αυτή η αγορά επεξεργάζεται ακόμα. Άνοιξε ξανά την εφαρμογή σε ένα λεπτό για να δεις το σουτ.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Η αποστολή avatar δεν επέστρεψε URL εικόνας.';

  @override
  String get rewardsDayStreakLabel => 'συνεχής σερί ημερών';

  @override
  String rewardsBestStreak(int days) {
    return 'Καλύτερο $days συνεχόμενες';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Χρειάζεται πρόσβαση $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Η πρόσβαση στο $permission απορρίφθηκε. Ανοίξτε τις Ρυθμίσεις για να το επιτρέψετε και επιστρέψτε στην εφαρμογή.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Βήμα $step από 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Βήμα $step από $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Αφαίρεση εικόνας $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Αφαίρεση εικόνας $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points π.';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Στείλτε μήλος στο $email. Οι αναφορές εξετάζονται σε 24 ώρες.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Αφαίρεση $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Διαγραφή του «$name»;';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Προσθήκη στο «$name»';
  }

  @override
  String outfitNamedRemoved(String name) {
    return 'Το «$name» αφαιρέθηκε. Τα ρούχα του παραμένουν στην ντουλάπα σας.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Εμφάνιση όλων των $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Απομένουν $count σήμερα';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Η εικόνα $index απέτυχε';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected από $max εικόνες';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Σώμα $shape · Τόνοι δέρματος $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Διαγραφή του $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Επιλογές για το $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Πιο φορεμένο: $name, $count φορές';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: μη ορισμένο';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% συμπατήριωση';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked από $max επιλεγμένα';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Αφαίρεση $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Προτεραιότητα $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Αυτό το πακέτο χρεώνεται μέσω του $store. Μεταβολές ή ακύρωση από τις ρυθμίσεις του λογαριασμού σας στο $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Διαχείριση στο $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current από $max χρησιμοποιημένα';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Απομένουν περίπου $seconds δ.';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done από $total φωτογραφίες σεναρίου έτοιμες';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready από $total φωτογραφίες σεναρίου έτοιμες. Πατήστε σε ένα ρούχο για να το παραλείψετε.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height εκ. · $weight κιλ.';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'Όχι';
}
