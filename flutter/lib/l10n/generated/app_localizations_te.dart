// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'హోమ్';

  @override
  String get tabPhotoshoot => 'ఫోటోషూట్';

  @override
  String get tabCloset => 'క్లోసెట్';

  @override
  String get tabOutfits => 'అవుట్‌ఫిట్స్';

  @override
  String get tabMore => 'మరిన్ని';

  @override
  String get actionAddItem => 'వస్తువును జోడించు';

  @override
  String get actionCreateOutfit => 'అవుట్‌ఫిట్ సృష్టించు';

  @override
  String get actionCancel => 'రద్దు';

  @override
  String get actionDelete => 'తొలగించు';

  @override
  String get actionSave => 'సేవ్';

  @override
  String get actionRetry => 'మళ్ళీ ప్రయత్నించు';

  @override
  String get actionDone => 'పూర్తయింది';

  @override
  String get actionNext => 'తర్వాత';

  @override
  String get actionBack => 'వెనుకకు';

  @override
  String get actionClose => 'మూసివేయి';

  @override
  String get actionSearch => 'వెతకండి';

  @override
  String get actionContinue => 'కొనసాగించు';

  @override
  String get stateLoading => 'లోడ్ అవుతోంది';

  @override
  String get stateErrorTitle => 'ఏదో తప్పు జరిగింది';

  @override
  String get stateErrorBody =>
      'మళ్ళీ ప్రయత్నించండి. సమస్య కొనసాగితే, సపోర్ట్‌ను సంప్రదించండి.';

  @override
  String get stateOfflineTitle => 'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు';

  @override
  String get stateOfflineBody =>
      'మీ క్లోసెట్‌ను సింక్ చేయడానికి మరియు అవుట్‌ఫిట్‌లను రూపొందించడానికి ఇంటర్నెట్‌కు కనెక్ట్ అవ్వండి.';

  @override
  String get settingsTitle => 'సెట్టింగ్‌లు';

  @override
  String get settingsAccountSection => 'ఖాతా';

  @override
  String get settingsPreferencesSection => 'ప్రాధాన్యతలు';

  @override
  String get settingsPlanBilling => 'ప్లాన్ మరియు బిల్లింగ్';

  @override
  String get settingsLanguage => 'భాష';

  @override
  String get settingsNotifications => 'నోటిఫికేషన్‌లు';

  @override
  String get settingsUnits => 'కొలత యూనిట్లు';

  @override
  String get settingsAppearance => 'రూపం';

  @override
  String get settingsPrivacySection => 'గోప్యత మరియు డేటా';

  @override
  String get settingsAboutSection => 'గురించి';

  @override
  String get settingsSignOut => 'సైన్ అవుట్';

  @override
  String get settingsDeleteAccount => 'ఖాతాను తొలగించు';

  @override
  String get settingsDeleteAccountTitle => 'మీ ఖాతాను తొలగించాలా?';

  @override
  String get settingsDeleteAccountBody =>
      'ఇది మీ క్లోసెట్, దుస్తులు, ఫోటోలు మరియు ప్రొఫైల్‌ను తొలగిస్తుంది. దీనిని తిరిగి పొందలేరు.';

  @override
  String get settingsUnitsImperial => 'ఇంపీరియల్ (in, lb)';

  @override
  String get settingsUnitsMetric => 'మెట్రిక్ (cm, kg)';

  @override
  String get languageTitle => 'భాష';

  @override
  String get languageSystem => 'పరికర భాషను ఉపయోగించు';

  @override
  String get languageSystemBody => 'FitCheck AI మీ ఫోన్ భాషను అనుసరిస్తుంది.';

  @override
  String get languageSearchHint => 'భాషల కోసం వెతకండి';

  @override
  String get languageCurrent => 'ప్రస్తుత';

  @override
  String get languageReviewNote =>
      'ఈ అనువాదం కొత్తది. ఏదైనా తప్పుగా ఉంటే మాకు తెలియజేయండి.';

  @override
  String get languageChanged => 'భాష నవీకరించబడింది';

  @override
  String get paywallTitle => 'మీ ప్లాన్‌ను ఎంచుకోండి';

  @override
  String get paywallTrialBadge => '1 నెల ఉచితం';

  @override
  String get paywallTrialTitle => 'మీ మొదటి నెల Pro ఉచితం';

  @override
  String get paywallTrialBody =>
      'మీ మొత్తం క్లోసెట్‌ను ఒకేసారి అప్‌లోడ్ చేయండి. ఆ తర్వాత కొత్తవి జోడించండి.';

  @override
  String get paywallFreeForeverTitle => 'ఎల్లప్పుడూ ఉచితం';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'కార్డ్ అవసరం లేదు. ప్రతి నెలా మీకు $uploads AI అప్‌లోడ్‌లు, $outfits దుస్తులు మరియు $images ఫోటోషూట్ చిత్రాలు లభిస్తాయి.';
  }

  @override
  String get paywallCtaTrial => 'నా ఉచిత నెలను ప్రారంభించు';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$planకి అప్‌గ్రేడ్ చేయండి';
  }

  @override
  String get paywallRestore => 'కొనుగోళ్లను పునరుద్ధరించు';

  @override
  String get paywallManage => 'సబ్‌స్క్రిప్షన్‌ను నిర్వహించు';

  @override
  String get paywallTerms => 'ఉపయోగ నిబంధనలు';

  @override
  String get paywallPrivacy => 'గోప్యతా విధానం';

  @override
  String get paywallPerMonth => 'నెలకు';

  @override
  String get paywallPerYear => 'సంవత్సరానికి';

  @override
  String get paywallBestValue => 'ఉత్తమ విలువ';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'కొత్త సబ్‌స్క్రైబర్‌లకు మాత్రమే ఉచిత ట్రయల్. ట్రయల్ ముగియడానికి కనీసం 24 గంటల ముందు రద్దు చేయకపోతే, ఆ తర్వాత Pro $priceకి పునరుద్ధరించబడుతుంది.';
  }

  @override
  String get introTitle => 'మీ వార్డ్‌రోబ్, చివరకు క్రమబద్ధీకరించబడింది';

  @override
  String get introBody =>
      'మీ బట్టలను ఒక్కసారి ఫోటో తీయండి. మీ దగ్గర ఉన్న వాటితోనే అవుట్‌ఫిట్ ఐడియాలు, ట్రై-ఆన్ ప్రివ్యూలు మరియు స్టూడియో ఫోటోలను పొందండి.';

  @override
  String get introStart => 'ప్రారంభించండి';

  @override
  String get introHaveAccount => 'నాకు ఇప్పటికే ఖాతా ఉంది';

  @override
  String get introSkip => 'దాటవేయి';

  @override
  String get authSignIn => 'సైన్ ఇన్';

  @override
  String get authSignUp => 'ఖాతాను సృష్టించండి';

  @override
  String get authEmail => 'ఈమెయిల్';

  @override
  String get authPassword => 'పాస్‌వర్డ్';

  @override
  String get authForgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get authContinueApple => 'Appleతో కొనసాగండి';

  @override
  String get authContinueGoogle => 'Googleతో కొనసాగండి';

  @override
  String get authOrDivider => 'లేదా';

  @override
  String get wardrobeTitle => 'క్లోసెట్';

  @override
  String get wardrobeEmptyTitle => 'మీ క్లోసెట్ ఖాళీగా ఉంది';

  @override
  String get wardrobeEmptyBody =>
      'మీ మొదటి వస్తువును జోడించండి లేదా మొత్తం రాక్ ఫోటోను ఒకేసారి అప్‌లోడ్ చేయండి.';

  @override
  String get wardrobeAddFirst => 'మొదటి వస్తువును జోడించండి';

  @override
  String get wardrobeSearchHint => 'మీ క్లోసెట్‌లో వెతకండి';

  @override
  String get categoryTops => 'టాప్స్';

  @override
  String get categoryBottoms => 'బాటమ్స్';

  @override
  String get categoryShoes => 'షూస్';

  @override
  String get categoryAccessories => 'యాక్సెసరీస్';

  @override
  String get categoryOuterwear => 'అవుటర్‌వేర్';

  @override
  String get categorySwimwear => 'స్విమ్‌వేర్';

  @override
  String get categoryActivewear => 'యాక్టివ్‌వేర్';

  @override
  String get categoryOther => 'ఇతర';

  @override
  String get conditionClean => 'శుభ్రంగా';

  @override
  String get conditionDirty => 'మురికిగా';

  @override
  String get conditionLaundry => 'లాండ్రీలో ఉంది';

  @override
  String get conditionRepair => 'మరమ్మత్తు అవసరం';

  @override
  String get conditionDonate => 'దానం చేయడానికి';

  @override
  String get seasonSpring => 'వసంతకాలం';

  @override
  String get seasonSummer => 'వేసవికాలం';

  @override
  String get seasonFall => 'శరదృతువు';

  @override
  String get seasonWinter => 'శీతాకాలం';

  @override
  String get seasonAll => 'అన్ని కాలాలు';

  @override
  String get styleCasual => 'క్యాజువల్';

  @override
  String get styleFormal => 'ఫార్మల్';

  @override
  String get styleBusiness => 'బిజినెస్';

  @override
  String get styleSporty => 'స్పోర్టీ';

  @override
  String get styleBohemian => 'బోహేమియన్';

  @override
  String get styleStreetwear => 'స్ట్రీట్‌వేర్';

  @override
  String get styleVintage => 'వింటేజ్';

  @override
  String get styleMinimalist => 'మినిమలిస్ట్';

  @override
  String get styleRomantic => 'రొమాంటిక్';

  @override
  String get styleEdgy => 'ఎడ్జీ';

  @override
  String get stylePreppy => 'ప్రెప్పీ';

  @override
  String get styleArtsy => 'ఆర్ట్సీ';

  @override
  String get styleClassic => 'క్లాసిక్';

  @override
  String get styleElegant => 'ఎలిగెంట్';

  @override
  String get styleOther => 'ఇతర';

  @override
  String get occasionWork => 'పని';

  @override
  String get occasionDateNight => 'డేట్ నైట్';

  @override
  String get occasionTravel => 'ప్రయాణం';

  @override
  String get occasionWedding => 'వివాహం';

  @override
  String get occasionGym => 'జిమ్';

  @override
  String get occasionWeekend => 'వీకెండ్';

  @override
  String get occasionParty => 'పార్టీ';

  @override
  String get occasionInterview => 'ఇంటర్వ్యూ';

  @override
  String get colorBlack => 'నలుపు';

  @override
  String get colorWhite => 'తెలుపు';

  @override
  String get colorGrey => 'గ్రే';

  @override
  String get colorNavy => 'నేవీ';

  @override
  String get colorBrown => 'గోధుమ';

  @override
  String get colorRed => 'ఎరుపు';

  @override
  String get colorBlue => 'నీలం';

  @override
  String get colorGreen => 'ఆకుపచ్చ';

  @override
  String get colorPink => 'పింక్';

  @override
  String get colorPurple => 'ఊదా';

  @override
  String get colorYellow => 'పసుపు';

  @override
  String get colorOrange => 'నారింజ';

  @override
  String get colorBeige => 'బీజ్';

  @override
  String get dateToday => 'ఈరోజు';

  @override
  String get dateYesterday => 'నిన్న';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజుల క్రితం',
      one: '1 రోజు క్రితం',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వారాల క్రితం',
      one: '1 వారం క్రితం',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count నెలల క్రితం',
      one: '1 నెల క్రితం',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సంవత్సరాల క్రితం',
      one: '1 సంవత్సరం క్రితం',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI నచ్చిందా?';

  @override
  String get ratingPromptBody =>
      'మీ రేటింగ్ ఇతరులకు వారి స్టైల్ కనుగొనడంలో సహాయపడుతుంది.';

  @override
  String get ratingPromptYes => 'రేట్ చేయండి';

  @override
  String get ratingPromptNo => 'ఇప్పుడు వద్దు';

  @override
  String get closetNoMatchesTitle => 'ఏవీ సరిపోలలేదు';

  @override
  String get closetNoMatchesBody =>
      'తక్కువ ఫిల్టర్లు లేదా వేరే సెర్చ్ ప్రయత్నించండి.';

  @override
  String get closetClearFilters => 'ఫిల్టర్లను తొలగించు';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పీసులు',
      one: '1 పీస్',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'మీ పీసులను లోడ్ చేస్తోంది';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఎంపిక చేయబడ్డాయి',
      one: '1 ఎంపిక చేయబడింది',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'ఎంచుకున్నవి తొలగించు';

  @override
  String get closetCancelSelection => 'ఎంపికను రద్దు చేయి';

  @override
  String get closetCloseSearch => 'శోధనను మూసివేయి';

  @override
  String get closetShowGrid => 'గ్రిడ్‌గా చూపు';

  @override
  String get closetShowList => 'జాబితాగా చూపు';

  @override
  String get closetShowRows => 'అడ్డు వరుసలుగా చూపు';

  @override
  String get closetStatsTitle => 'క్లోసెట్ గణాంకాలు';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ముక్కలను తొలగించాలా?',
      one: '1 ముక్కను తొలగించాలా?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'వీటిని ఉపయోగించే దుస్తుల నుండి ఇవి తొలగించబడతాయి.';

  @override
  String get closetSortBy => 'క్రమబద్ధీకరించు';

  @override
  String get closetFavourites => 'ఇష్టమైనవి';

  @override
  String get closetFavourite => 'ఇష్టమైనదిగా చేయి';

  @override
  String get closetUnfavourite => 'ఇష్టమైన వాటి నుండి తొలగించు';

  @override
  String get closetWoreToday => 'ఈరోజు ధరించాను';

  @override
  String closetWornTimes(int count) {
    return '$count× ధరించబడింది';
  }

  @override
  String get closetCategoryLabel => 'వర్గం';

  @override
  String get closetUseCaseLabel => 'ఉపయోగం';

  @override
  String get closetAnyUseCase => 'ఏదైనా';

  @override
  String get closetOtherUseCase => 'ఇతర ఉపయోగం';

  @override
  String get closetOtherUseCaseHint => 'ఉదాహరణకు, బ్రంచ్';

  @override
  String get closetUseUseCase => 'దీనిని ఉపయోగించు';

  @override
  String get closetClearAll => 'అన్నీ తొలగించు';

  @override
  String get sortNewest => 'కొత్తవి ముందుగా';

  @override
  String get sortOldest => 'పాతవి ముందుగా';

  @override
  String get sortName => 'పేరు (A–Z)';

  @override
  String get sortMostWorn => 'ఎక్కువగా ధరించినవి';

  @override
  String get useCaseInformal => 'సాధారణం';

  @override
  String get useCaseDate => 'డేట్';

  @override
  String get useCaseDinner => 'డిన్నర్';

  @override
  String get useCaseLunch => 'లంచ్';

  @override
  String get actionSelect => 'ఎంచుకోండి';

  @override
  String get actionEdit => 'సవరించు';

  @override
  String get actionFilter => 'ఫిల్టర్';

  @override
  String get actionSort => 'క్రమబద్ధీకరించు';

  @override
  String get actionAll => 'అన్నీ';

  @override
  String get dashboardStartClosetTitle => 'మీ క్లోసెట్‌ను ప్రారంభించండి';

  @override
  String get dashboardStartClosetBody =>
      'కొన్ని దుస్తులను ఫోటో తీయండి. మేము వాటిని ట్యాగ్ చేస్తాము.';

  @override
  String get dashboardPieces => 'దుస్తులు';

  @override
  String get dashboardOutfits => 'అవుట్‌ఫిట్లు';

  @override
  String get dashboardDayStreak => 'రోజుల స్ట్రీక్';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'ఈ నెలలో +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'ఉత్తమ $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఇష్టమైనవి',
      one: '1 ఇష్టమైనది',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సేవ్ చేసిన అవుట్‌ఫిట్లు',
      one: '1 సేవ్ చేసిన అవుట్‌ఫిట్',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'ఎక్కువగా ధరించినవి: $name, $count సార్లు';
  }

  @override
  String get setupSkip => 'సెటప్‌ను దాటవేయి';

  @override
  String get setupWhoTitle => 'ఎవరికి స్టైలింగ్ చేస్తున్నాం?';

  @override
  String get setupWhoBody =>
      'ట్రై-ఆన్ మరియు ఫోటోషూట్‌ల కోసం మోడల్‌ను సెట్ చేస్తుంది. మీరు దీన్ని ప్రొఫైల్‌లో మార్చుకోవచ్చు.';

  @override
  String get setupStyleTitle => 'మీరు ఎక్కువగా ఏమి ధరిస్తారు?';

  @override
  String get setupStyleBody =>
      'ఏదైనా ఎంచుకోండి. అవుట్‌ఫిట్ ఐడియాలు వీటి నుండే మొదలవుతాయి.';

  @override
  String get setupClosetTitle => 'మీ మొదటి దుస్తులను జోడించండి.';

  @override
  String get setupClosetBody =>
      'కొన్ని దుస్తులను లేదా వాటి కుప్పను ఫోటో తీయండి. ప్రతి దుస్తులను కట్ చేసి మీ కోసం ఫైల్ చేస్తాము.';

  @override
  String get setupAddClothes => 'దుస్తులను జోడించు';

  @override
  String get setupStylesLabel => 'స్టైల్స్';

  @override
  String get setupOccasionsLabel => 'సందర్భాలు';

  @override
  String get setupSkipStep => 'దాటవేయి';

  @override
  String get setupLater => 'తర్వాత';

  @override
  String get setupSaveError => 'సేవ్ చేయలేకపోయాము';

  @override
  String get genderWomen => 'మహిళలు';

  @override
  String get genderMen => 'పురుషులు';

  @override
  String get genderNonBinary => 'నాన్-బైనరీ';

  @override
  String get genderPreferNotToSay => 'చెప్పకూడదని అనుకుంటున్నాను';

  @override
  String get outfitEmptyTitle => 'ఇంకా అవుట్‌ఫిట్స్ లేవు';

  @override
  String get outfitEmptyBody =>
      'మీ క్లోసెట్‌లోని దుస్తులను జత చేసి లుక్‌ను సేవ్ చేయండి.';

  @override
  String get outfitNoMatchesTitle => 'ఏ అవుట్‌ఫిట్స్ సరిపోలలేదు';

  @override
  String get outfitSearchHint => 'మీ అవుట్‌ఫిట్స్‌ని వెతకండి';

  @override
  String get outfitLoading => 'మీ అవుట్‌ఫిట్స్‌ని లోడ్ చేస్తోంది';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అవుట్‌ఫిట్స్',
      one: '1 అవుట్‌ఫిట్',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'స్టైల్ మరియు సీజన్';

  @override
  String get outfitCollections => 'కలెక్షన్స్';

  @override
  String get outfitDuplicate => 'డూప్లికేట్';

  @override
  String get outfitDeleteTitle => 'ఈ అవుట్‌ఫిట్‌ని తొలగించాలా?';

  @override
  String get outfitDeleteBody => 'దీనిలోని దుస్తులు మీ క్లోసెట్‌లోనే ఉంటాయి.';

  @override
  String get outfitDrafts => 'డ్రాఫ్ట్స్';

  @override
  String get outfitDraft => 'డ్రాఫ్ట్';

  @override
  String get filterStyle => 'స్టైల్';

  @override
  String get filterSeason => 'సీజన్';

  @override
  String get itemDetailDeleteTitle => 'ఈ దుస్తులను తొలగించాలా?';

  @override
  String get itemDetailDeleteBody =>
      'దీనిని ఉపయోగించే అవుట్‌ఫిట్స్ నుండి ఇది తొలగించబడుతుంది.';

  @override
  String get itemAddFavourite => 'ఫేవరెట్స్‌కు జోడించండి';

  @override
  String itemSize(String size) {
    return 'సైజు $size';
  }

  @override
  String get itemColours => 'రంగులు';

  @override
  String get itemMaterial => 'మెటీరియల్';

  @override
  String get itemPattern => 'ప్యాటర్న్';

  @override
  String get itemUseCases => 'ఉపయోగించే సందర్భాలు';

  @override
  String get itemKeptIn => 'ఇందులో ఉంది';

  @override
  String get itemPrice => 'ధర';

  @override
  String get itemBought => 'కొన్నది';

  @override
  String get itemTags => 'ట్యాగ్స్';

  @override
  String get itemAdded => 'జోడించబడింది';

  @override
  String get itemTimesWornLabel => 'ధరించిన సార్లు';

  @override
  String get itemLastWornLabel => 'చివరిసారి ధరించింది';

  @override
  String get itemNeverWorn => 'ఎప్పుడూ లేదు';

  @override
  String get authEntryBody =>
      'మీ వద్ద ఉన్న ప్రతి వస్తువు, AI ద్వారా స్టైల్ చేయబడుతుంది. దుస్తులను ప్లాన్ చేయండి, వేసుకుని చూడండి, ఫోటోలు తీయండి.';

  @override
  String get authCreateCloset => 'మీ క్లోసెట్‌ను సృష్టించండి';

  @override
  String get authWelcomeBack => 'తిరిగి స్వాగతం';

  @override
  String get authSignInBody => 'మీ క్లోసెట్‌ను తెరవడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get authCreateAccount => 'ఖాతాను సృష్టించండి';

  @override
  String get authCreateClosetBody =>
      'ఇది ఒక నిమిషం పడుతుంది. మీ మొదటి వస్తువులు ఉచితం.';

  @override
  String get authName => 'పేరు';

  @override
  String get authConfirmPassword => 'పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get authReferralCode => 'రిఫరల్ కోడ్ (ఐచ్ఛికం)';

  @override
  String get authResetTitle => 'మీ పాస్‌వర్డ్‌ను రీసెట్ చేయండి';

  @override
  String get authResetBody =>
      'కొత్త పాస్‌వర్డ్ ఎంచుకోవడానికి మేము మీకు ఒక లింక్‌ను ఇమెయిల్ చేస్తాము.';

  @override
  String get authSendResetLink => 'రీసెట్ లింక్‌ను పంపండి';

  @override
  String get authBackToSignIn => 'సైన్ ఇన్‌కు తిరిగి వెళ్ళండి';

  @override
  String get authEnterEmail => 'మీ ఇమెయిల్‌ను నమోదు చేయండి';

  @override
  String get authEnterValidEmail => 'సరైన ఇమెయిల్‌ను నమోదు చేయండి';

  @override
  String get authEnterPassword => 'మీ పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String get authPasswordTooShort => 'కనీసం 6 అక్షరాలు';

  @override
  String get authShowPassword => 'పాస్‌వర్డ్ చూపించు';

  @override
  String get authHidePassword => 'పాస్‌వర్డ్ దాచు';

  @override
  String get authNewHere => 'కొత్తగా వచ్చారా?';

  @override
  String authConfirmEmail(String email) {
    return 'సైన్ ఇన్ చేసే ముందు $emailని నిర్ధారించండి. మీ ఇన్‌బాక్స్‌ను తనిఖీ చేయండి.';
  }

  @override
  String get authResendEmail => 'మళ్ళీ పంపండి';

  @override
  String get authResendingEmail => 'పంపుతోంది...';

  @override
  String get authPasswordsDoNotMatch => 'పాస్‌వర్డ్‌లు సరిపోలడం లేదు';

  @override
  String get authEnterName => 'మీ పేరును నమోదు చేయండి';

  @override
  String get authChoosePassword => 'పాస్‌వర్డ్‌ను ఎంచుకోండి';

  @override
  String get authHaveAccount => 'ఇప్పటికే ఖాతా ఉందా?';

  @override
  String get authCodeAccepted => 'కోడ్ ఆమోదించబడింది';

  @override
  String get authCodeNotFound => 'కోడ్ కనుగొనబడలేదు';

  @override
  String authReferralFrom(String name) {
    return '$name నుండి. మీ ఇద్దరికీ ఒక నెల ఉచితం.';
  }

  @override
  String get authReferralInvalid => 'మేము ఈ కోడ్‌ను కనుగొనలేకపోయాము.';

  @override
  String authResetSent(String email) {
    return '$emailకి పంపబడింది. ఈ ఫోన్‌లో లింక్‌ను తెరవండి.';
  }

  @override
  String get introSlide1Title => 'మీ బట్టలను ఒకసారి ఫోటో తీయండి.';

  @override
  String get introSlide1Body =>
      'దుస్తుల కుప్పను ఫోటో తీయండి. ప్రతి వస్తువు కట్ చేయబడి మీ కోసం సేవ్ చేయబడుతుంది.';

  @override
  String get introSlide2Title => 'త్వరగా సిద్ధమవ్వండి.';

  @override
  String get introSlide2Body =>
      'మీ ప్లాన్‌లు మరియు వాతావరణానికి తగినట్లుగా మీ వద్ద ఉన్న దుస్తులతో అవుట్‌ఫిట్‌లు.';

  @override
  String get introSlide3Title => 'ధరించే ముందే చూడండి.';

  @override
  String get introSlide3Body =>
      'మీ ఫోటోపై లుక్స్‌ని ప్రయత్నించండి లేదా ప్రచార చిత్రంలా షూట్ చేయండి.';

  @override
  String get settingsTheme => 'థీమ్';

  @override
  String get settingsThemeSystem => 'సిస్టమ్';

  @override
  String get settingsThemeLight => 'లైట్';

  @override
  String get settingsThemeDark => 'డార్క్';

  @override
  String get settingsTemperature => 'ఉష్ణోగ్రత';

  @override
  String get settingsEmailUpdates => 'ఈమెయిల్ అప్‌డేట్‌లు';

  @override
  String get settingsEmailUpdatesBody =>
      'ఈమెయిల్ ద్వారా వార్తలు మరియు చిట్కాలు';

  @override
  String get settingsOutfitReminders => 'అవుట్‌ఫిట్ రిమైండర్‌లు';

  @override
  String get settingsOutfitRemindersBody =>
      'మీరు ఏమి ధరించారో లాగ్ చేయడానికి రిమైండర్';

  @override
  String get settingsWeeklySummary => 'వారపు సారాంశం';

  @override
  String get settingsWeeklySummaryBody => 'మీ వారపు అవుట్‌ఫిట్‌లు';

  @override
  String get settingsStyleSection => 'స్టైల్';

  @override
  String get settingsPreferredStyles => 'మీకు నచ్చిన స్టైల్స్';

  @override
  String get settingsPreferredColours => 'మీకు నచ్చిన రంగులు';

  @override
  String get settingsNoneChosen => 'ఏవీ ఎంచుకోలేదు';

  @override
  String get settingsPlanAiSection => 'ప్లాన్ మరియు AI';

  @override
  String get settingsPlanBillingBody => 'ప్లాన్, వినియోగం మరియు అప్‌గ్రేడ్‌లు';

  @override
  String get settingsPlanUsageBody => 'ప్లాన్ మరియు వినియోగం';

  @override
  String get settingsInviteFriends => 'స్నేహితులను ఆహ్వానించండి';

  @override
  String get settingsInviteFriendsBody =>
      'చేరిన ప్రతి స్నేహితుడికి ఒక నెల ఉచితం';

  @override
  String get settingsAiProvider => 'AI ప్రొవైడర్';

  @override
  String get settingsAiProviderBody =>
      'ట్యాగింగ్ మరియు చిత్రాల కోసం మీ స్వంత మోడల్‌ను ఉపయోగించండి';

  @override
  String get settingsAppVersion => 'యాప్ వెర్షన్';

  @override
  String get settingsPrivacyTerms => 'గోప్యత మరియు నిబంధనలు';

  @override
  String get settingsReportProblem => 'సమస్యను నివేదించండి';

  @override
  String get settingsChangePassword => 'పాస్‌వర్డ్‌ను మార్చండి';

  @override
  String get settingsExportData => 'మీ డేటాను ఎగుమతి చేయండి';

  @override
  String get settingsExportBody =>
      'మీరు సేవ్ చేసిన ప్రతిదానితో మేము ఒక ఫైల్‌ను సిద్ధం చేసి డౌన్‌లోడ్ చేస్తాము.';

  @override
  String get settingsExportAction => 'ఎగుమతి';

  @override
  String get settingsCurrentPassword => 'ప్రస్తుత పాస్‌వర్డ్';

  @override
  String get settingsNewPassword => 'కొత్త పాస్‌వర్డ్';

  @override
  String get settingsConfirmNewPassword => 'కొత్త పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get settingsEnterCurrentPassword =>
      'మీ ప్రస్తుత పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String get settingsEnterNewPassword => 'కొత్త పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String get settingsPasswordMin8 => 'కనీసం 8 అక్షరాలను ఉపయోగించండి';

  @override
  String get settingsPasswordNeedsUpper => 'ఒక పెద్ద అక్షరాన్ని జోడించండి';

  @override
  String get settingsPasswordNeedsLower => 'ఒక చిన్న అక్షరాన్ని జోడించండి';

  @override
  String get settingsPasswordNeedsDigit => 'ఒక అంకెను జోడించండి';

  @override
  String get settingsPasswordsNoMatch => 'పాస్‌వర్డ్‌లు సరిపోలడం లేదు';

  @override
  String get settingsChangeAction => 'మార్చు';

  @override
  String get itemAddSnapTitle => 'ఒక వస్తువును ఫోటో తీయండి';

  @override
  String get itemAddSnapBody =>
      'మేము ఫోటోలోని ప్రతి వస్తువును గుర్తించి, స్పష్టమైన స్టూడియో షాట్‌ను రూపొందిస్తాము.';

  @override
  String get itemAddCamera => 'ఫోటో తీయండి';

  @override
  String get itemAddGallery => 'గ్యాలరీ నుండి ఎంచుకోండి';

  @override
  String get itemAddOtherWays => 'జోడించడానికి ఇతర మార్గాలు';

  @override
  String get itemAddSeveral => 'అనేక ఫోటోలను జోడించండి';

  @override
  String get itemAddSeveralBody => 'ఒకేసారి 50 వరకు';

  @override
  String get itemAddImportProfile => 'ప్రొఫైల్ నుండి దిగుమతి చేసుకోండి';

  @override
  String get itemAddImportProfileBody => 'Instagram లేదా Facebook';

  @override
  String get itemAddEnterDetails => 'వివరాలను మీరే నమోదు చేయండి';

  @override
  String get itemAddEnterDetailsBody => 'ఫోటో అవసరం లేదు';

  @override
  String get itemManualIntro =>
      'పేరు మాత్రమే అవసరం. మిగిలినవి ఇప్పుడే లేదా తర్వాత జోడించండి.';

  @override
  String get itemManualNameHint => 'ఉదాహరణకు, బ్లూ కాటన్ టీ';

  @override
  String get itemManualEnterName => 'పేరును నమోదు చేయండి';

  @override
  String get itemManualNotes => 'గమనికలు';

  @override
  String get itemManualBrand => 'బ్రాండ్';

  @override
  String get itemManualSize => 'సైజు';

  @override
  String get itemManualEnterNumber => 'సంఖ్యను నమోదు చేయండి';

  @override
  String get itemManualSavePiece => 'సేవ్ చేయండి';

  @override
  String get itemManualSaving => 'సేవ్ అవుతోంది';

  @override
  String get itemManualSavedTitle => 'సేవ్ చేయబడింది';

  @override
  String itemManualSavedBody(String name) {
    return '$name మీ క్లోసెట్‌లో ఉంది.';
  }

  @override
  String get itemManualNotSaved => 'సేవ్ కాలేదు';

  @override
  String get itemManualAddUseCase => 'ఉపయోగాన్ని జోడించండి';

  @override
  String get itemManualAddUseCaseAction => 'ఉపయోగాన్ని జోడించు';

  @override
  String get itemPhotos => 'ఫోటోలు';

  @override
  String get itemAddPhotos => 'ఫోటోలను జోడించండి';

  @override
  String get itemNoPhotoYet => 'ఇంకా ఫోటో లేదు. ఫోటో లేకుండానే సేవ్ చేయవచ్చు.';

  @override
  String get itemRemovePhoto => 'ఫోటోను తొలగించండి';

  @override
  String get itemRemovePiece => 'దీనిని తొలగించండి';

  @override
  String get filterConditionLabel => 'స్థితి';

  @override
  String get photoshootStepPhotos => 'ఫోటోలు';

  @override
  String get photoshootStepSetup => 'సెటప్';

  @override
  String get photoshootStepCreating => 'సృష్టిస్తోంది';

  @override
  String get photoshootStepResults => 'ఫలితాలు';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'దశ $current / $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'ఒక ఫోటో విఫలమైంది. కింద మళ్ళీ ప్రయత్నించండి.';

  @override
  String photoshootManyFailed(int count) {
    return '$count ఫోటోలు విఫలమయ్యాయి. కింద ఒక్కొక్కటి మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String get photoshootFormat => 'ఫార్మాట్';

  @override
  String get photoshootHowMany => 'ఎన్ని';

  @override
  String get photoshootYourPrompt => 'మీ ప్రాంప్ట్';

  @override
  String get photoshootPromptHint => 'రూఫ్‌టాప్‌పై గోల్డెన్ అవర్, లినెన్ షర్ట్';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫోటోలను సృష్టించు',
      one: '1 ఫోటోను సృష్టించు',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఫోటోలు',
      one: 'ఫోటో',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'ఈరోజు పరిమితిని మేము తనిఖీ చేయలేకపోయాము.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan ప్లాన్: ఈరోజు $remaining / $limit మిగిలి ఉన్నాయి';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'ఉచితం';

  @override
  String get photoshootGallery => 'గ్యాలరీ';

  @override
  String get photoshootUseCamera => 'కెమెరాను ఉపయోగించు';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'ఫోటో $numberని తొలగించు';
  }

  @override
  String get photoshootNoPhotosTitle => 'ఫోటోలు రాలేదు';

  @override
  String get photoshootNoPhotosBody =>
      'షూట్ పూర్తయింది కానీ చిత్రాలు రాలేదు. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get photoshootNewStyle => 'కొత్త స్టైల్';

  @override
  String get photoshootNewPhotos => 'కొత్త ఫోటోలు';

  @override
  String photoshootOpenPhoto(int number) {
    return 'ఫోటో $numberని తెరువు';
  }

  @override
  String get photoshootReportPhoto => 'ఫోటోను రిపోర్ట్ చేయి';

  @override
  String get photoshootSaveToGallery => 'గ్యాలరీలో సేవ్ చేయి';

  @override
  String get actionUpgrade => 'అప్‌గ్రేడ్';

  @override
  String get referralLimitTitle => 'మీరు ఈరోజు ఫోటోల పరిమితిని పూర్తి చేశారు';

  @override
  String get referralLimitBody =>
      'మీ ఉచిత ఫోటోలు రేపు తిరిగి వస్తాయి. స్నేహితుడిని రిఫర్ చేయండి, మీ ఇద్దరికీ ఒక నెల Pro ఉచితంగా లభిస్తుంది.';

  @override
  String get referralLimitRefer => 'స్నేహితుడిని రిఫర్ చేయి';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'డేటింగ్ యాప్';

  @override
  String get photoshootUsePortfolio => 'పోర్ట్‌ఫోలియో';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'అస్థెటిక్';

  @override
  String get photoshootUseCustom => 'మీ సొంత ప్రాంప్ట్';

  @override
  String get photoshootDescLinkedin => 'వృత్తిపరమైన హెడ్‌షాట్‌లు';

  @override
  String get photoshootDescDating => 'ప్రశాంతమైన, వెచ్చని మరియు సహజమైన';

  @override
  String get photoshootDescPortfolio => 'ఎడిటోరియల్, హై-ఫ్యాషన్ లుక్స్';

  @override
  String get photoshootDescInstagram => 'మీ ఫీడ్ కోసం లైఫ్‌స్టైల్ ఫోటోలు';

  @override
  String get photoshootDescAesthetic => 'మూడీ, కళాత్మకమైన ఫ్రేమ్‌లు';

  @override
  String get photoshootDescCustom => 'మీకు కావలసిన లుక్‌ను వివరించండి';

  @override
  String get aspectSquare => 'చతురస్రం';

  @override
  String get aspectPortrait => 'పోర్ట్రెయిట్';

  @override
  String get aspectLandscape => 'ల్యాండ్‌స్కేప్';

  @override
  String get aspectTall => 'పొడవు';

  @override
  String get aspectWide => 'వెడల్పు';

  @override
  String get tryOnAppBar => 'వర్చువల్ ట్రై-ఆన్';

  @override
  String get tryOnYourPhoto => 'మీ ఫోటో';

  @override
  String get tryOnGarment => 'దుస్తులు';

  @override
  String get tryOnUploadingPhoto => 'మీ ఫోటో అప్‌లోడ్ అవుతోంది';

  @override
  String get tryOnAddPhotoPrompt => 'మీ పూర్తి శరీర ఫోటోను జోడించండి';

  @override
  String get tryOnBodyPhotoHint => 'పూర్తి శరీర ఫోటో ఉత్తమంగా ఉంటుంది';

  @override
  String get tryOnAddPhoto => 'ఫోటోను జోడించండి';

  @override
  String get tryOnChangePhoto => 'ఫోటోను మార్చండి';

  @override
  String get tryOnPhotoLoadFailed => 'మేము మీ ఫోటోను లోడ్ చేయలేకపోయాము.';

  @override
  String get tryOnChooseGarment => 'దుస్తుల ఫోటోను ఎంచుకోండి';

  @override
  String get tryOnChooseOneGarment => 'ఒక దుస్తుల ఫోటోను ఎంచుకోండి';

  @override
  String get tryOnGarmentHint =>
      'ఫ్లాట్ లే లేదా హ్యాంగర్ షాట్ ఉత్తమంగా ఉంటుంది';

  @override
  String get tryOnChange => 'మార్చండి';

  @override
  String get tryOnCamera => 'కెమెరా';

  @override
  String get tryOnRemove => 'తొలగించు';

  @override
  String get tryOnLookTitle => 'లుక్';

  @override
  String get tryOnStyle => 'స్టైల్';

  @override
  String get tryOnBackground => 'నేపథ్యం';

  @override
  String get tryOnPose => 'పోజ్';

  @override
  String get tryOnDressingUp =>
      'మీకు దుస్తులు వేస్తున్నాము. దీనికి అర నిమిషం పడుతుంది.';

  @override
  String get tryOnEmptyResult => 'మీ ట్రై-ఆన్ ఇక్కడ కనిపిస్తుంది';

  @override
  String get tryOnReportImage => 'చిత్రాన్ని రిపోర్ట్ చేయండి';

  @override
  String get tryOnCreating => 'సృష్టిస్తోంది';

  @override
  String get tryOnTryAgain => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get tryOnCreate => 'ట్రై-ఆన్ సృష్టించండి';

  @override
  String get tryOnBackgroundStudioWhite => 'స్టూడియో వైట్';

  @override
  String get tryOnBackgroundStudioGrey => 'స్టూడియో గ్రే';

  @override
  String get tryOnBackgroundUrban => 'అర్బన్ స్ట్రీట్';

  @override
  String get tryOnBackgroundNature => 'నేచర్';

  @override
  String get tryOnBackgroundMinimal => 'మినిమల్';

  @override
  String get tryOnPoseFront => 'ముందు వైపు';

  @override
  String get tryOnPoseSide => 'పక్క వైపు';

  @override
  String get tryOnPoseWalking => 'నడుస్తున్నట్లు';

  @override
  String get dashboardGreetingMorning => 'శుభోదయం';

  @override
  String get dashboardGreetingAfternoon => 'శుభ మధ్యాహ్నం';

  @override
  String get dashboardGreetingEvening => 'శుభ సాయంత్రం';

  @override
  String get dashboardWelcome => 'స్వాగతం';

  @override
  String get dashboardOpenProfile => 'ప్రొఫైల్ తెరవండి';

  @override
  String get dashboardRailToday => 'ఈరోజు';

  @override
  String get dashboardRailRecently => 'ఇటీవల';

  @override
  String get dashboardActivityEmpty =>
      'కొత్త దుస్తులు మరియు అవుట్‌ఫిట్‌లు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get quickAddPiece => 'ఒక వస్తువును జోడించండి';

  @override
  String get quickAddPieceBody => 'ఫోటో తీసి ట్యాగ్ చేయండి';

  @override
  String get quickBuildOutfit => 'అవుట్‌ఫిట్‌ను రూపొందించండి';

  @override
  String get quickBuildOutfitBody => 'మీ దుస్తులను కలపండి';

  @override
  String get quickForYou => 'మీ కోసం';

  @override
  String get quickForYouBody => 'ఈరోజు కోసం ఎంపికలు';

  @override
  String get quickPlanWeek => 'వారాన్ని ప్లాన్ చేయండి';

  @override
  String get quickPlanWeekBody => 'తేదీల వారీగా అవుట్‌ఫిట్‌లు';

  @override
  String get referralBannerUrgent =>
      'తక్కువగా ఉందా? స్నేహితుడిని ఆహ్వానించండి.';

  @override
  String get referralBannerTitle => 'ఒక నెల ఇవ్వండి, ఒక నెల పొందండి.';

  @override
  String get referralBannerBody =>
      'మీకు మరియు మీ స్నేహితుడికి ఒక్కో నెల Pro లభిస్తుంది.';

  @override
  String get referralBannerDismiss => 'ఒక వారం పాటు వదిలేయండి';

  @override
  String get referralBannerShare => 'ఆహ్వానాన్ని పంచుకోండి';

  @override
  String get referralBannerCopy => 'లింక్‌ను కాపీ చేయండి';

  @override
  String get itemEditPieceTitle => 'పీస్‌ను సవరించండి';

  @override
  String get itemEditDescriptionLabel => 'వివరణ';

  @override
  String get itemEditNotSaved => 'సేవ్ చేయబడలేదు';

  @override
  String get itemEditSavedTitle => 'సేవ్ చేయబడింది';

  @override
  String get itemEditSavedBody => 'మీ మార్పులు సేవ్ చేయబడ్డాయి.';

  @override
  String get itemEditSavedStalePhotos =>
      'సేవ్ చేయబడింది — ఫోటోలు పాతవి కావచ్చు';

  @override
  String get itemEditRemovePieceHint => 'ఈ పీస్‌ను ఐటమ్ పేజీ నుండి తొలగించండి.';

  @override
  String get itemEditNoPhotos =>
      'ఇంకా ఫోటోలు లేవు. మీ గ్యాలరీ లేదా కెమెరా నుండి ఒకదాన్ని జోడించండి.';

  @override
  String get itemEditKeepPhoto => 'ఫోటోను ఉంచండి';

  @override
  String get itemEditRemoved => 'తొలగించబడింది';

  @override
  String get itemEditAddUseCaseAction => 'జోడించు';

  @override
  String get statsNoStatsTitle => 'ఇంకా గణాంకాలు లేవు';

  @override
  String get statsNoStatsBody =>
      'కొన్ని పీస్‌లను జోడించండి, మీ క్లోసెట్ మిశ్రమం ఇక్కడ కనిపిస్తుంది.';

  @override
  String get statsByCategory => 'వర్గం వారీగా';

  @override
  String get statsTotalValue => 'మొత్తం విలువ';

  @override
  String get statsMostWorn => 'ఎక్కువగా ధరించినవి';

  @override
  String get statsLeastWorn => 'అవకాశం కోసం వేచి ఉన్నాయి';

  @override
  String get statsUnnamedPiece => 'పేరు లేని పీస్';

  @override
  String get jobsTitle => 'స్కాన్‌లు';

  @override
  String get jobsEmptyTitle => 'ఇంకా స్కాన్‌లు లేవు';

  @override
  String get jobsEmptyBody =>
      'ఒక పీస్‌ను స్నాప్ చేసి బ్యాక్‌గ్రౌండ్‌కు పంపండి — అది ఇక్కడ పని చేస్తూనే ఉంటుంది.';

  @override
  String get jobsNotCancelled => 'రద్దు చేయబడలేదు';

  @override
  String get jobsResume => 'పునఃప్రారంభించు';

  @override
  String get jobsReview => 'సమీక్షించు';

  @override
  String get jobsStop => 'ఆపివేయి';

  @override
  String get jobsDismiss => 'వదిలేయండి';

  @override
  String get reportTitle => 'కంటెంట్‌ను రిపోర్ట్ చేయండి';

  @override
  String reportIntro(String contentType) {
    return 'ఈ $contentTypeలో ఏమి తప్పుందో మాకు చెప్పండి. మా బృందం ప్రతి రిపోర్ట్‌ను సమీక్షిస్తుంది.';
  }

  @override
  String get reportReasonInappropriate => 'అనుచితమైనది లేదా అభ్యంతరకరమైనది';

  @override
  String get reportReasonNudity => 'నగ్నత్వం లేదా లైంగిక కంటెంట్';

  @override
  String get reportReasonHarassment => 'వేధింపులు లేదా దుర్వినియోగం';

  @override
  String get reportReasonImpersonation => 'మరొకరిలా నటించడం';

  @override
  String get reportReasonOther => 'ఇతర';

  @override
  String get reportDetailsLabel => 'అదనపు వివరాలు (ఐచ్ఛికం)';

  @override
  String get reportSubmit => 'రిపోర్ట్ పంపండి';

  @override
  String get reportSubmittedTitle => 'రిపోర్ట్ పంపబడింది';

  @override
  String get reportSubmittedBody =>
      'ధన్యవాదాలు. మా బృందం ఈ కంటెంట్‌ను సమీక్షిస్తుంది.';

  @override
  String get reportFailedTitle => 'రిపోర్ట్ పంపడం సాధ్యం కాలేదు';

  @override
  String get reportFailedBody => 'దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get reportContentTryOnImage => 'AI ట్రై-ఆన్ చిత్రం';

  @override
  String get reportContentSharedOutfit => 'షేర్ చేసిన దుస్తులు';

  @override
  String get reportContentPhotoshootImage => 'AI ఫోటోషూట్ చిత్రం';

  @override
  String get sharedOutfitTitle => 'షేర్ చేసిన దుస్తులు';

  @override
  String get sharedOutfitHideTooltip => 'ఈ దుస్తులను దాచండి';

  @override
  String get sharedOutfitReportTooltip => 'ఈ దుస్తులను రిపోర్ట్ చేయండి';

  @override
  String get sharedOutfitHideTitle => 'ఈ దుస్తులను దాచాలా?';

  @override
  String get sharedOutfitHideBody =>
      'ఇది ఈ పరికరంలో దాచబడుతుంది. మా బృందం సమీక్షించి తొలగించేలా మీరు దీన్ని రిపోర్ట్ కూడా చేయవచ్చు.';

  @override
  String get sharedOutfitHideAction => 'దాచు';

  @override
  String get sharedOutfitHiddenInfo => 'ఈ దుస్తులు ఇకపై ఈ పరికరంలో కనిపించవు.';

  @override
  String get sharedOutfitHiddenToast => 'దుస్తులు దాచబడ్డాయి';

  @override
  String get sharedOutfitMissingTitle => 'ఈ దుస్తులు ఇక్కడ లేవు';

  @override
  String get sharedOutfitMissingBody =>
      'ఇది తొలగించబడి ఉండవచ్చు లేదా లింక్ తప్పుగా ఉండవచ్చు.';

  @override
  String get sharedOutfitHiddenStateTitle => 'మీరు ఈ దుస్తులను దాచారు';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'ఇది అభ్యంతరకరంగా ఉంటే, ప్రైవసీ మరియు నిబంధనల నుండి రిపోర్ట్ చేయండి లేదా $email కి ఇమెయిల్ చేయండి.';
  }

  @override
  String get sharedOutfitCtaTitle => 'ఈ లుక్ నచ్చిందా?';

  @override
  String get sharedOutfitCtaBody =>
      'మీ వార్డ్‌రోబ్‌లోని దుస్తులతో ఇలాంటి అవుట్‌ఫిట్‌లను రూపొందించుకోండి.';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'పొరపాటు';

  @override
  String get errorUnknown => 'అపేక్షించని పొరపాటు సంభవించింది';

  @override
  String get errorNoConnection =>
      'ఇంటర్నెట్ కనెక్షన్ లేదు. దయచేసి మీ నెట్‌వర్క్ చూడండి.';

  @override
  String get errorTimeout =>
      'నమోదు సమయం ముగిసింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorServerError =>
      'మా వైపు ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorBadGateway =>
      'మా సర్వర్ తాత్కాలికంగా అందుబాటులో లేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorServiceUnavailable =>
      'సేవ తాత్కాలికంగా అందుబాటులో లేదు. కొంత సేపట్లో మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorInternalError =>
      'ఏదో తప్పు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorUnauthorized => 'కొనసాగించడానికి దయచేసి సైన్ ఇన్ చేయండి.';

  @override
  String get errorForbidden => 'మీకు దానికి ప్రాప్యత లేదు.';

  @override
  String get errorSessionExpired =>
      'మీ సెషన్ పరమైనది. దయచేసి మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get errorInvalidCredentials =>
      'ఆ ఇమెయిల్ లేదా పాస్‌వర్డ్ తప్పుగా ఉంది.';

  @override
  String get errorTokenRefreshFailed =>
      'మీ సెషన్ రిఫ్రెష్ చేయలేకపోయాము. దయచేసి మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get errorRequestCancelled => 'నమోదు రద్దు చేయబడింది.';

  @override
  String get errorInvalidFormat => 'ఆ ఫైల్ ఫార్మాట్ సపోర్ట్ చేయబడదు.';

  @override
  String get errorFileTooLarge => 'ఆ ఫైల్ చాలా పెద్దది.';

  @override
  String get errorUploadFailed =>
      'అప్‌లోడ్ విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errorCacheCorrupted =>
      'సేవ్ చేసిన డేటా హాని అందింది మరియు రీసెట్ చేయబడింది.';

  @override
  String get errorCacheNotFound => 'ఇంకా ఏదీ సేవ్ చేయలేదు.';

  @override
  String get errorUserNotFound => 'ఆ ఖాతాను కనుగొనలేము.';

  @override
  String get errorItemNotFound => 'ఆ వస్తువు ఇక లేదు.';

  @override
  String get errorOutfitNotFound => 'ఆ ఔట్‌ఫిట్ ఇక లేదు.';

  @override
  String get rewardsTitle => 'అవార్డులు';

  @override
  String get rewardsNoAchievementsTitle => 'ఇంకా ఏ అవతారాలు లేవు';

  @override
  String get rewardsNoAchievementsBody =>
      'మొదటి అవార్డు పొందడానికి వస్త్రాలు జోడించి ఔట్‌ఫిట్లు ప్లాన్ చేయండి.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'ఇంకా బోర్డ్‌లో ఎవరూ లేరు';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'ప్రింట్లు మరియు పాయింట్లు సంపాదించడానికి ఔట్‌ఫిట్లు ప్లాన్ చేసి ఇక్కడ ప్రదర్శించండి.';

  @override
  String get legalViewPrivacyPolicy => 'ప్రైవసీ పాలసీని చూడండి';

  @override
  String get aiConsentAgree => 'నేను సమ్మతిస్తాను మరియు కొనసాగించాలి';

  @override
  String get aiConsentNotNow => 'ఇప్పుడు కాదు';

  @override
  String get imageViewerCloseTooltip => 'చిత్ర దర్శకీయం మూసివేయండి';

  @override
  String get updateReadyTitle => 'అప్డేట్ సిద్ధం';

  @override
  String get updateReadyBody =>
      'ఇటీవలి మెరుగుదలలను అమలు చేయడానికి FitCheck AIని రీస్టార్ట్ చేయండి.';

  @override
  String get permissionCameraUsage =>
      'మీ Outfits మరియు వార్డ్‌రోబ్ అంశాలను ఫోటోగ్రాఫ్ చేయడానికి FitCheck AIకి కెమెరా యాక్సెస్ అవసరం.';

  @override
  String get permissionPhotoLibraryUsage =>
      'మీ Outfits మరియు వార్డ్‌రోబ్ అంశాల యొక్క చిత్రాలను ఎంచుకోవడానికి FitCheck AIకి ఫోటో లైబ్రరీ యాక్సెస్ అవసరం.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'మీ AI-జనరిటెడ్ Outfits చిత్రాలను మీ ఫోటో లైబ్రరీలో సేవ్ చేయడానికి FitCheck AIకి అనుమతి అవసరం.';

  @override
  String get wardrobeSomePhotosSkipped => 'కొన్ని ఫోటోలు వదిలించబడ్డాయి';

  @override
  String get wardrobePhotosNotAdded => 'ఫోటోలు జోడించబడలేదు';

  @override
  String get wardrobePhotoNotAdded => 'ఫోటో జోడించబడలేదు';

  @override
  String get wardrobeNotStartedTitle => 'ప్రారంభించలేదు';

  @override
  String get wardrobeNoRoomTitle => 'స్థలం లేదు';

  @override
  String get wardrobeAddPhotosSemantic => 'ఫోటోలు జోడించండి';

  @override
  String get batchAddTileLabel => 'జోడించండి';

  @override
  String get batchProfileLinkLabel => 'ప్రాఫైల్ లింక్';

  @override
  String get wardrobeImportFromProfileTitle => 'ప్రాఫైల్ నుండి ఇంపార్ట్ చేయండి';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'కొన్ని ఫోటోలు జోడించండి';

  @override
  String get wardrobeClearAction => 'తొలగించండి';

  @override
  String get wardrobeRefreshTooltip => 'రిఫ్రెష్ చేయండి';

  @override
  String get batchNoPhotosYetTitle => 'ఇంకా ఫోటోలు లేవు';

  @override
  String get batchChoosePhotosAction => 'ఫోటోలు ఎంచుకోండి';

  @override
  String get batchWeFindEachPieceBody =>
      'మేము ప్రతి అంశాన్ని కనుగొని దానికి స్టూడియో ఫోటో తీస్తాము.';

  @override
  String get batchPreparingPhotosSemantic => 'ఫోటోలు సన్నాహంలో';

  @override
  String get batchPhotosProcessedSemantic => 'ఫోటోలు ప్రాసెస్ చేయబడ్డాయి';

  @override
  String get batchPasteProfileLinkTitle => 'ప్రాఫైల్ లింక్ పేస్ట్ చేయండి';

  @override
  String get batchPasteProfileLinkBody =>
      'పబ్లిక్ Instagram లేదా Facebook ప్రాఫైల్. మేము దాని ఫోటోలను స్కాన్ చేస్తాము, మీ క్లోసెట్‌కు ఏది వెళ్ళాలో మీరు ఎంచుకుంటారు.';

  @override
  String get batchClearLinkTooltip => 'లింక్ తొలగించండి';

  @override
  String get batchStartingButton => 'ప్రారంభించబడుతోంది';

  @override
  String get batchStartImportAction => 'ఇంపార్ట్ ప్రారంభించండి';

  @override
  String get batchReviewEveryPhotoTitle => 'మీరు ప్రతి ఫోటోను రివ్యూ చేస్తారు';

  @override
  String get batchReviewEveryPhotoBody =>
      'మీరు ఆమోదించేంత వరకు ఏదీ జోడించబడదు.';

  @override
  String get batchPrivateProfilesTitle => 'గోప్య ప్రొఫైల్స్';

  @override
  String get batchPrivateProfilesBody =>
      'మీ అకౌంట్‌ను కనెక్ట్ చేయండి. Instagram కూడా యూజర్‌నామ్, పాస్‌వర్డ్ తీసుకుంటుంది.';

  @override
  String get batchUseAnotherLinkAction => 'రేవలంటి లింక్ వాడండి';

  @override
  String get batchSignInNeededTitle => 'సైన్-ఇన్ అవసరం';

  @override
  String get batchEnterYourCodeTitle => 'మీ కోడ్ ఇవ్వండి';

  @override
  String get batchUseUsernamePasswordAction => 'యూజర్‌నామ్, పాస్‌వర్డ్ వాడండి';

  @override
  String get batchAlreadyConnectedAction =>
      'నేను బ్రౌజర్‌లో అల్రెడీ కనెక్ట్ చేశాను';

  @override
  String get batchEnterCodeAction => 'కోడ్ ఇవ్వండి';

  @override
  String get batchTryAnotherWayAction => 'రేవలంటి మార్గం ప్రయత్నించండి';

  @override
  String get batchLiveStatus => 'లైవ్';

  @override
  String get batchReconnectingStatus => 'రీకనెక్ట్ అవుతోంది';

  @override
  String get batchSignInToInstagramTitle => 'Instagramకి సైన్ ఇన్ చేయండి';

  @override
  String get batchUsernameLabel => 'యూజర్‌నామ్';

  @override
  String get batchCodeIfTwoStepLabel => 'మీరు ట్వో-స్టెప్ సైన్-ఇన్ వాడితే కోడ్';

  @override
  String get batchAuthenticatorCodeBody =>
      'మీ ఆథెంటిక్యాటర్ యాప్ నుండి 6-అంకెల కోడ్ వాడండి. కోడ్లు త్వరగా మారుతాయి.';

  @override
  String get batchVerifyAction => 'తనించు';

  @override
  String get batchFindingPhotosTitle => 'ఫోటోలు తిరస్సు';

  @override
  String get batchImportPausedTitle => 'ఇంపోర్ట్ ఆగింది';

  @override
  String get batchProcessingPhotosTitle => 'ఫోటోలు ప్రాసెస్ అవుతున్నాయి';

  @override
  String get batchWaitingNextPhoto => 'తదుపరి ఫోటో కోసం మేరల్చేరుతున్నాం';

  @override
  String get batchCancelImportAction => 'ఇంపోర్ట్ రద్దు చేయండి';

  @override
  String get batchNoPiecesInPhotoBody => 'ఈ ఫోటోలో ఏ పీస్లు దొరికలేదు.';

  @override
  String get batchEditPieceColoursLabel => 'రంగులు, కమాలో విడిచి';

  @override
  String get batchAddToClosetAction => 'క్లోజెట్‌లో సేర్చండి';

  @override
  String get batchSkipPhotoAction => 'ఈ ఫోటోను దాటవేయండి';

  @override
  String get batchImportCompleteTitle => 'ఇంపోర్ట్ పూర్తైంది';

  @override
  String get batchImportFailedTitle => 'ఇంపోర్ట్ తప్పించబడింది';

  @override
  String get batchImportCancelledTitle => 'ఇంపోర్ట్ రద్దు చేయబడింది';

  @override
  String get batchImportErrorBody => 'ఇంపోర్ట్ అవుతుండటంలో ఏదో చరమించబడింది.';

  @override
  String get batchNothingMoreImportedBody =>
      'ఈ ప్రొఫైల్ నుండి అదనంగా ఏమీ ఇంపోర్ట్ కాలేదు.';

  @override
  String get batchViewClosetAction => 'స్టాక్ చూడండి';

  @override
  String get batchStartOverAction => 'మళ్లీ ప్రారంభించండి';

  @override
  String get wardrobeAddPieceTitle => 'వస్త్రం జోడించండి';

  @override
  String get wardrobeAddDetailsTitle => 'వివరాలు జోడించండి';

  @override
  String get wardrobeScanningTitle => 'స్కాన్ చేస్తున్నాం';

  @override
  String get batchReviewPiecesTitle => 'వస్త్రాలను పరిశీలించండి';

  @override
  String get wardrobeGalleryAction => 'గ్యాలరీ';

  @override
  String get wardrobeCameraAction => 'కెమెరా';

  @override
  String get wardrobeNewBadge => 'కొత్తది';

  @override
  String get wardrobeRemovePhotoTooltip => 'ఫోటో తీసివేయండి';

  @override
  String get batchRunInBackgroundTooltip => 'పీచ్‌లో రన్ చేయండి';

  @override
  String get batchStepOneOfTwo => 'దశ 1 / 2';

  @override
  String get batchStepTwoOfTwo => 'దశ 2 / 2';

  @override
  String get batchUploadingPhotosTitle => 'ఫోటోలు అప్‌లోడ్ అవుతున్నాయి';

  @override
  String get batchFindingPiecesTitle => 'వస్త్రాలు కనుగొంటున్నాం';

  @override
  String get batchMakingStudioPhotosTitle => 'స్టూడియో ఫోటోలు తీస్తున్నాం';

  @override
  String get batchStoppedLabel => 'ఆపబడింది';

  @override
  String get batchFindingPiecesStoppedTitle => 'వస్త్రాల కనుకాడం ఆపబడింది';

  @override
  String get batchCancelledLabel => 'రద్దు చేయబడింది';

  @override
  String get batchAllDoneTitle => 'అన్నీ పూర్తి';

  @override
  String get batchOpeningPiecesBody => 'మీ వస్త్రాలు తెరుస్తున్నాం';

  @override
  String get batchNothingSavedBody => 'ఏదీ సేవ్ కాలేదు.';

  @override
  String get batchFindingPiecesFailedBody => 'వస్త్రాల కనుకాడం విఫలమైంది.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'వస్త్రాల కనుకాడం త్వరలో ఆపబడింది.';

  @override
  String get batchStopFindingPiecesTitle => 'వస్త్రాల కనుకాడం ఆపాలా?';

  @override
  String get batchStopFindingPiecesBody =>
      'స్కాన్ ఆగిపోతుంది, ఏదీ సేవ్ కలదు. ఇప్పటికే కనుగొన్న వస్త్రాలు మీ కార్యకలాపంలో ఉండేవరకు వాటిని తొలగించకండి.';

  @override
  String get batchKeepGoingAction => 'కొనసాగించండి';

  @override
  String get batchTryAgainAction => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get batchBackToPhotosAction => 'ఫోటోలకు తిరిగి వెళ్లండి';

  @override
  String get batchSkipAllAction => 'అన్నీ దాటవేయండి';

  @override
  String get batchIncludeAllAction => 'అన్నీ చేర్చు';

  @override
  String get batchNoPiecesFoundTitle => 'ఏదీ కనుగొనలేదు';

  @override
  String get batchNoPiecesFoundBody => 'ఈ ఫోటోలలో దుస్తులు కనబడలేదు.';

  @override
  String get batchChooseOtherPhotosAction => 'ఇతర ఫోటోలు ఎంచుకోండి';

  @override
  String get batchUseCaseHelper =>
      'మీరు భద్రపరిచే ప్రతి వస్తువుకు జోడించబడుతుంది.';

  @override
  String get batchDiscardPiecesTitle => 'ఈ వస్తువులను తీసివేయాలా?';

  @override
  String get batchDiscardPiecesBody => 'ఈ బాచ్‌ నుండి ఏమీ భద్రపరచబడదు.';

  @override
  String get batchKeepAction => 'కొనసాగించు';

  @override
  String get batchDiscardAction => 'తీసివేయి';

  @override
  String get batchRemovePieceTitle => 'ఈ వస్తువును తీసివేయాలా?';

  @override
  String get batchRemovePieceBody => 'దాన్ని మీ క్లోజెట్‌కు భద్రపరచలేదు.';

  @override
  String get batchRemoveAction => 'తీసివేయి';

  @override
  String get batchChoosePiecesToSave => 'భద్రపరచాల్సిన వస్తువులు ఎంచుకోండి';

  @override
  String get batchDiscardAllAction => 'అన్నీ తీసివేయి';

  @override
  String get batchNothingSavedRetryBody =>
      'ఏమీ భద్రపరచలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get batchNotSavedTitle => 'భద్రపరచలేదు';

  @override
  String get batchSavingLabel => 'భద్రపరుస్తున్నందు';

  @override
  String get batchSendToBackgroundAction => 'పాతర కు పంపండి';

  @override
  String get batchStillWorkingMessage =>
      'ఇంకా పని చేస్తుంది. మీ వస్తువులు సిద్ధమైనప్పుడు మేము మీకు తెలియజేస్తాము.';

  @override
  String get batchRunningInBackgroundTitle => 'పాతర కును పనిచేస్తుంది';

  @override
  String get batchStudioPhotosStoppedBody =>
      'స్టూడియో ఫోటోలు త్వరగా ఆగిపోయాయి. మీరు ఇంకా ఈ వస్తువులను భద్రపరుసుకోవచ్చు.';

  @override
  String get batchTapPieceToSkip => 'దాన్ని నిషేధించడానికి వస్తువుపై నొక్కండి.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'స్టూడియో ఫోటోలు ఇంకా వేగంగా చేరడమే. మీరు వెళ్ళవచ్చు — మేము మీకు తెలియజేస్తాము.';

  @override
  String get batchLeaveAction => 'వెళ్ళు';

  @override
  String get batchPeopleInPhotosTitle => 'ఫోటోలలో ఉన్నవారు';

  @override
  String get batchIncludeAction => 'చేర్చు';

  @override
  String get batchSkipAction => 'నిషేధించు';

  @override
  String get batchYourPhotoIsUsedLabel => 'మీ ఫోటో ఉపయోగించబడింది';

  @override
  String get batchMakingStudioPhotoLabel => 'స్టూడియో ఫోటో తయారు చేస్తున్నందు';

  @override
  String get batchNoStudioPhotoBody =>
      'స్టూడియో ఫోటో లేదు. మీ ఫోటో ఉపయోగించబడింది.';

  @override
  String get batchEnterDetailsYourselfAction => 'వివరాలు మీరే నమోదు చేయండి';

  @override
  String get batchChooseAnotherPhotoAction => 'రూపకల్పన మరొకదాన్ని ఎంచుకోండి';

  @override
  String get batchConnectionLostTitle => 'కనెక్షన్ కోల్పోయింది';

  @override
  String get batchConnectionLostBody =>
      'మీ కనెక్షన్‌ను సరిచేసి, మళ్ళీ ప్రయత్నించండి.';

  @override
  String get batchDailyLimitTitle => 'రోజువారీ పరిమితి చేరుకుంది';

  @override
  String get batchDailyLimitBodyPaywall =>
      'మరిన్ని స్కాన్‌ల కోసం ప్రొకుప్రాగ్రాం అప్‌గ్రేడ్ చేయండి, లేదా వివరాలు మీరే నమోదు చేయండి.';

  @override
  String get batchDailyLimitBodyFree =>
      'మీ స్కాన్లు రేపు రీసెట్ అవుతాయి. వివరాలు ఇప్పుడే మీరే నమోదు చేయవచ్చు.';

  @override
  String get batchSeePlansAction => 'ప్లాన్లను చూడండి';

  @override
  String get batchAiBusyTitle => 'మా AI బిజీగా ఉంది';

  @override
  String get batchAiBusyBody =>
      'దీనికి మనా వైపు సమస్య ఉంది. కొన్ని నిమిషాల తర్వాత మళ్ళీ ప్రయత్నించండి.';

  @override
  String get batchNoPiecesBody =>
      'కచ్చితంగా మోడల్ చిత్రాన్ని ప్రయత్నించండి, లేదా వివరాలు మీరే నమోదు చేయండి.';

  @override
  String get batchScanningUnavailableTitle => 'స్కానింగ్ అందుబాటులో లేదు';

  @override
  String get batchScanningUnavailableBody =>
      'ఇప్పుడు వివరాలు మీరే నమోదు చేయండి.';

  @override
  String get batchScanDidNotFinishTitle => 'స్కాన్ పూర్తి కాలేదు';

  @override
  String get batchTryAgainBody => 'మళ్ళీ ప్రయత్నించండి.';

  @override
  String get billingTitle => 'సబ్‌స్క్రిప్షన్';

  @override
  String get billingUpgradeHeading => 'మీ ప్లాన్‌ను అప్‌గ్రేడ్ చేయండి';

  @override
  String get billingUpgradeOnPlusBody => 'ఒకే ఫీచర్లు, ఎక్కువ పరిమితులు.';

  @override
  String get billingUpgradeBody =>
      'ప్లస్ మరియు ప్రొకుప్రొగ్రాం కలిగే ఫీచర్లు ఒకేలా ఉన్నాయి. మీకు అవసరమైన పరిమితులను ఎంచుకోండి.';

  @override
  String get billingWebUnavailableBody =>
      'ఆన్‌లైన్ అప్‌గ్రేడ్లు ఇంకా అందుబాటులో లేవు. ప్రొమో లేదా రెఫరల్ కోడ్ ద్వారా ప్లస్ లేదా ప్రొను విలోకనం చేయవచ్చు. క్రింది విధంగా స్నేహితులను ఆహ్వానించి ఉచిత నెలలను సంపాదించండి.';

  @override
  String get billingPlansStale =>
      'తాజా ప్లాన్లను లోడ్ చేయలేకపోయింది. ధరలు పాతవిగా ఉండవచ్చు.';

  @override
  String get billingMonthly => 'నెలవారీ';

  @override
  String get billingYearly => 'సంవత్సరానికి';

  @override
  String get billingCurrentPlan => 'ప్రస్తుత ప్లాన్';

  @override
  String get billingActive => 'చల్లుచేయబడింది';

  @override
  String get billingThisMonth => 'ఈ నెల';

  @override
  String get billingItemExtractions => 'వస్తువులను సేకరించడం';

  @override
  String get billingOutfitVisualizations => 'పనివనవీలలు';

  @override
  String get billingNearLimitUpgrade =>
      'మీరు ఈ నెల పరిమితికి దగ్గరగా ఉన్నారు. ఎక్కువ కోసం అప్‌గ్రేడ్ చేయండి.';

  @override
  String get billingNearLimitResets =>
      'మీరు ఈ నెల పరిమితికి దగ్గరగా ఉన్నారు. కింది నెల ప్రారంభంలో అది రీసెట్ అవుతుంది.';

  @override
  String get billingStoreUnavailable =>
      'ప్రెగ్రెడ్స్ ఇంకా స్టోర్‌లో అందుబాటులో లేవు. త్వరలో తనిఖీ చేయండి.';

  @override
  String get billingManageHeading => 'మీ ప్లాన్‌ను నిర్వహించండి';

  @override
  String get billingCancelPlan => 'సభ్యత్వాన్ని రద్దు చేయండి';

  @override
  String get billingCancelKeepsAccess =>
      'ఈ బిల్లింగ్ సమయం ముగిసే వరకు మీరు యాక్సెస్ ఉంచుకుంటారు.';

  @override
  String get billingCancelConfirmTitle => 'మీ సభ్యత్వాన్ని రద్దు చేయాలా?';

  @override
  String get billingKeepPlan => 'ప్లాన్ కొనసాగించండి';

  @override
  String get billingCancelPlanAction => 'ప్లాన్ రద్దు చేయండి';

  @override
  String get billingBilledMonthly => 'సెట్లుగా బిల్లు వస్తుంది';

  @override
  String get billingBilledYearly => 'సంవత్సరంకు బిల్లు వస్తుంది';

  @override
  String get billingVirtualTryOn => 'వర్చువల్ ట్రై-ఆన్';

  @override
  String get billingPrioritySupport => 'ప్రాధాన్యత మద్దతు';

  @override
  String get billingDisclosureProRenewing => 'Pro ఒక ఆటో-రిన్యూవల్ సభ్యత్వం';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus మరియు Pro ఆటో-రిన్యూవల్ సభ్యత్వాలు';

  @override
  String get billingDisclosureAppleBilling =>
      'కొనుగోలు నిర్ధారణ సమయంలో మీ Apple ID ద్వారా చెల్లంపు జరుగుతుంది.';

  @override
  String get billingDisclosureGoogleBilling =>
      'కొనుగోలు నిర్ధారణ సమయంలో మీ Google Play ఖాతరకు చెల్లంపు జరుగుతుంది.';

  @override
  String get billingDisclosureRenewalTerms =>
      'మీ సభ్యత్వం భవిష్యత్తు సమయంలో ఒకే ధరతో ఆటోమేటిక్‌గా రిన్యూ అవుతుంది, తుది ఆటో-రిన్యూవల్ ఆఫ్ చేయకపోతే.';

  @override
  String get billingDisclosureAppleManage =>
      'సెట్టింగ్‌ల › మీ Apple ID › సబ్‌స్క్రిప్షన్స్‌లో ఎప్పుడైనా నిర్వహించండి లేదా రద్దు చేయండి.';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play › పేమెంట్స్ మరియు సభ్యత్వాలలో ఎప్పుడైనా నిర్వహించండి లేదా రద్దు చేయండి.';

  @override
  String get billingReferFriend => 'ఒక స్నేహితుడిని అతీవర్తించండి';

  @override
  String get billingHowItWorks => 'ఎలా పనిచేస్తుందని';

  @override
  String get billingHowShareTitle => 'మీ లింక్‌ను షేర్ చేయండి';

  @override
  String get billingHowShareBody => 'ఒక స్నేహితునికి పంపండి.';

  @override
  String get billingHowSignUpTitle => 'వాళ్లు సైన్ అప్ చేస్తారు';

  @override
  String get billingHowSignUpBody =>
      'మీ స్నేహితుడు లింక్ ద్వారా జాయిన్ అవుతారు.';

  @override
  String get billingHowBothTitle => 'మీరు ఇద్దరికీ Pro లభిస్తుంది';

  @override
  String get billingHowBothBody =>
      'మీరు ఒక్కొక్కరు వందాన్ని Pro ఉచితంగా పొందుతారు.';

  @override
  String get billingYourReferrals => 'మీ రిఫరల్స్';

  @override
  String get billingInvited => 'ఆహ్వానించబడింది';

  @override
  String get billingJoined => 'సంధానం చేసింది';

  @override
  String get billingMonthsEarned => 'పొందిన నెలలు';

  @override
  String get billingInviteFriend => 'వీణ్సును ఆహ్వానించండి';

  @override
  String get billingInviteBody =>
      'మీరు మరియు మీ బాలాంతుల వీణ్సును ఒక్కొక్కరు ఒకనాటి Pro పొందండి.';

  @override
  String get billingYourCode => 'మీ కోడ్';

  @override
  String get billingCopyLink => 'లింక్ కాపీ చేయండి';

  @override
  String get billingShareInvite => 'ఆహ్వానం పంచుకోండి';

  @override
  String get giftUnavailable => 'ఈ వేరియంట్‌లో దండ ఆహ్వానాలు అందుబాటులో లేవు.';

  @override
  String get giftPageTitle => 'FitCheck Pro దండ';

  @override
  String get giftNoAllowances =>
      'ప్రస్తుతం cost-free దండ ఆహ్వానాలు అందుబాటులో లేవు.';

  @override
  String get giftFormTitle => 'cost-free ఆహ్వానం పంపండి';

  @override
  String get giftFormBody =>
      'మీ గ్రహీత ఈ ధృవీకరించిన ఇ-మెయిల్తో దండను ఖాతరి చేయగలరు. మేము మీ తరఫున ఇ-మెయిల్ పంపము.';

  @override
  String get giftFieldFrom => 'పంపినది';

  @override
  String get giftFieldRecipientName => 'గ్రహీత పేరు';

  @override
  String get giftFieldRecipientEmail => 'గ్రహీత ఇ-మెయిల్';

  @override
  String get giftFieldOccasion => 'ప్రమాణం (ఎంపిక)';

  @override
  String get giftNoOccasion => 'ప్రమాణం లేదు';

  @override
  String get giftOccasionBirthday => 'పుట్టినరోజు';

  @override
  String get giftOccasionAnniversary => 'వార్షికోత్సవం';

  @override
  String get giftOccasionOther => 'వేరేదో';

  @override
  String get giftFieldCardGreeting => 'కార్డ్ ఆశిరించడం';

  @override
  String get giftFieldCardGreetingHelper =>
      'ఇది కార్డ్‌పై నేరుగా రాయబడినట్లు కనిపిస్తుంది.';

  @override
  String get giftFieldPrivateNote => 'కలక్‌పెట్టిన గమనిక (ఎంపిక)';

  @override
  String get giftCreateAction => 'cost-free దండ సృష్టించండి';

  @override
  String get giftClaimedTitle => 'దండ ఖాతరి చేయబడింది';

  @override
  String get giftClaimedActive => 'మీ FitCheck Pro దండ యాక్టివ్‌గా ఉంది.';

  @override
  String get giftClaimedQueued =>
      'మీ FitCheck Pro దండ ప్రస్తుత అనుభవం తర్వాత ప్రారంభం అవుతుంది.';

  @override
  String get giftLinkCopied => 'దండ లింక్ క్లిప్బోర్డులో కాపీ చేయబడింది.';

  @override
  String get giftErrorName => 'పేరు నమోదు చేయండి.';

  @override
  String get giftErrorEmail => 'నిజమైన ఇ-మెయిల్ చిరునామా నమోదు చేయండి.';

  @override
  String get giftErrorGreeting => 'కార్డ్ ఆశిరించడం నమోదు చేయండి.';

  @override
  String get giftErrorGreetingLength => '80 అక్షరాలు గరిష్టంగా ఉపయోగించండి.';

  @override
  String get giftClaimAction => 'ఆహ్వానించండి';

  @override
  String get giftCardPreview => 'కార్డు ముందుచూపు';

  @override
  String get giftGiftForYou => 'మీ కోసం బహుమతి';

  @override
  String get giftGiftWaiting => 'మీ కోసం ఒక బహుమతి వేచి ఉంది';

  @override
  String get giftOpenBody =>
      'మీ నమూదాత్మక ఇమెయిల్‌తో మీ బహుమతులను తెరిచి ఆహ్వానించండి.';

  @override
  String get giftOpenGifts => 'బహుమతులు తెరవండి';

  @override
  String get giftSendInvitation => 'ఆహ్వానం పంపండి';

  @override
  String get settingsAiProviderSection => 'ప్రొవైడర్';

  @override
  String get settingsAiCustom => 'కస్టమ్';

  @override
  String get settingsAiUrlHelper =>
      'సర్వర్‌కు చేరుకోగలిగే పబ్లిక్ URLని ఉపయోగించండి. మా సర్వర్ల నుండి లోకల్‌హోస్ట్ పనిచేయదు.';

  @override
  String get settingsAiConnectionSection => 'కనెక్షన్';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API కీ';

  @override
  String get settingsAiApiKeySaved =>
      'సేవ్ చేయబడింది. ఉంచడానికి ఖాళీగా ఉంచండి.';

  @override
  String get settingsAiChatModel => 'చాట్ మోడల్';

  @override
  String get settingsAiVisionModel => 'విజన్ మోడల్ (ఐచ్ఛికం)';

  @override
  String get settingsAiImageModel => 'ఇమేజ్ మోడల్ (ఐచ్ఛికం)';

  @override
  String get settingsAiImageModelNote =>
      'ఇమేజ్ జనరేషన్‌కు response_modalitiesతో OpenAI-కంపాటిబిల్ చాట్ కంప్లీషన్‌లు అవసరం.';

  @override
  String get settingsAiTestConnection => 'కనెక్షన్ పరీక్షించండి';

  @override
  String get calendarTitle => 'క్యాలెండర్';

  @override
  String get calendarGoToToday => 'నేటికి వెళ్లండి';

  @override
  String get calendarConnectTooltip => 'క్యాలెండర్‌ను కనెక్ట్ చేయండి';

  @override
  String get calendarAddEvent => 'ఆయోజనం జోడించండి';

  @override
  String get calendarEmptyTitle => 'ఏదీ ప్రణాళిక చేయలేదు';

  @override
  String get calendarEmptyBody =>
      'ఆయోజనం జోడించి ధరించేది ఏమిటి అని ప్రణాళిక చేయండి.';

  @override
  String get calendarPreviousMonth => 'మునుపటి నెల';

  @override
  String get calendarNextMonth => 'తర్వాతి నెల';

  @override
  String get calendarAllDay => 'మొత్తం రోజు';

  @override
  String get calendarOutfitLinked => 'అవుట్‌ఫిట్ లింక్ చేయబడింది';

  @override
  String get calendarEventOptions => 'ఆయోజన ఎంపికలు';

  @override
  String get calendarDeleteTitle => 'ఈ ఘట్టాను తీసివేయాలి?';

  @override
  String get calendarChangeOutfit => 'అవుట్‌ఫిట్ మార్చండి';

  @override
  String get calendarLinkOutfit => 'అవుట్‌ఫిట్‌ను జోడించండి';

  @override
  String get calendarRemoveOutfit => 'అవుట్‌ఫిట్‌ను తీసివేయండి';

  @override
  String get calendarNewEvent => 'కొత్త ఘట్టం';

  @override
  String get calendarEditEvent => 'ఘటాను సవరించండి';

  @override
  String get calendarTitleLabel => 'శీర్షిక';

  @override
  String get calendarTitleRequired => 'శీర్షికను చేర్చండి';

  @override
  String get calendarEndBeforeStart => 'ప్రారంభ సమయం తర్వాత ముగించండి';

  @override
  String get calendarStarts => 'ప్రారంభం';

  @override
  String get calendarEnds => 'ముగింపు';

  @override
  String get calendarPlaceOptional => 'సంప్రదించండి (ఐచ్ఛికం)';

  @override
  String get calendarNotesOptional => 'గమనికలు (ఐచ్ఛికం)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'అవుట్‌ఫిట్‌ను రూపొందించి, దీన్ని ఈ ఘటానికి జోడించండి.';

  @override
  String get calendarBuildOutfit => 'అవుట్‌ఫిట్‌ను రూపొందించండి';

  @override
  String get calendarConnectionsTitle => 'కలండర్లు';

  @override
  String get calendarConnectionsBody =>
      'మీరు ఇక్కడ చేర్చే ఘటనలు FitCheck లోనే ఉంటాయి.';

  @override
  String get calendarDisconnect => 'అవిరిపరచండి';

  @override
  String get calendarNotAvailable => 'ఇంకా అందుబాటులో లేదు';

  @override
  String get profileSectionExplore => 'అన్వేషించండి';

  @override
  String get profileNavTryOn => 'నిజనైక్ ధరించడం';

  @override
  String get profileNavRewards => 'అనుభవాలు';

  @override
  String get profileSupport => 'సహాయం';

  @override
  String get profileHelp => 'సహాయం';

  @override
  String get profileAbout => 'గురించి';

  @override
  String get profileAboutBody =>
      'మీ క్లోసెట్, అవుట్‌ఫిట్‌లు మరియు ప్లాన్‌లు ఒకే చోట.';

  @override
  String get profileSignOutTitle => 'సైన్ ఔట్ చేయాలా?';

  @override
  String get profileSignOutBody => 'మీరు ఎప్పుడైనా మళ్లీ సైన్ ఇన్ చేయవచ్చు.';

  @override
  String get profileEditTitle => 'ప్రొఫైల్‌ను సవరించండి';

  @override
  String get profileYourProfile => 'మీ ప్రొఫైల్';

  @override
  String get profileBodyProfiles => 'బాడీ ప్రొఫైల్స్';

  @override
  String get profileBodyEmptyTitle => 'ఇంకా బాడీ ప్రొఫైల్స్ లేవు';

  @override
  String get profileBodyEmptyBody =>
      'మంచి ఫిట్ కోసం మీ ఎత్తును మరియు శరీర నిర్మాణాన్ని జోడించండి.';

  @override
  String get profileBodyAdd => 'ప్రొఫైల్ జోడించండి';

  @override
  String get profileBodyDefaultNote =>
      'మీ నిర్దిష్ట ప్రొఫైల్ ఫిట్ మరియు ట్రై-ఆన్ కోసం ఉపయోగిస్తుంది.';

  @override
  String get profileBodyDefaultBadge => 'నిర్దిష్టం';

  @override
  String get profileBodyMakeDefault => 'నిర్దిష్టం చేయండి';

  @override
  String get profileBodyDeleteBody => 'దీన్ని వెనుకకు తీసుకోలేరు.';

  @override
  String get profileBodyRequired => 'అవసరం';

  @override
  String get profileBodyCheckNumber => 'ఈ అంకెను తనిఖీ చేయండి';

  @override
  String get profileBodyNew => 'కొత్త బాడీ ప్రొఫైల్';

  @override
  String get profileBodyNameHint => 'ఉదాహరణకు, నేను';

  @override
  String get profileBodyHeight => 'ఎత్తు';

  @override
  String get profileBodyWeight => 'బరువు';

  @override
  String get profileBodyBuild => 'శరీర నిర్మాణం';

  @override
  String get profileBodySkinTone => 'చర్మ వర్ణం';

  @override
  String get profileBirthDateNeededBody =>
      'జనన సమయంతో అనుగుణంగా జనమతీధ్వం జోడించండి.';

  @override
  String get profileBirthDateNeededTitle => 'జనమతీధ్వం అవసరం';

  @override
  String get profilePartlySavedBody =>
      'మీ పేరు మరియు ఫోటో సేవ్ అయింది. జనన వివరాలు సేవ్ కాలేదు; తర్వాత ప్రయత్నించండి.';

  @override
  String get profilePartlySavedTitle => 'పాక్షికంగా సేవ్ అయింది';

  @override
  String get profileSavedBody => 'మీ ప్రొఫైల్ సేవ్ అయింది.';

  @override
  String get profileChangePhoto => 'ప్రొఫైల్ ఫోటో మార్చండి';

  @override
  String get profilePhotoLabel => 'ప్రొఫైల్ ఫోటో';

  @override
  String get profilePhotoHint => 'కొత్తదాన్ని ఎంచుకోవడానికి ట్యాప్ చేయండి';

  @override
  String get profileBirthDateLabel => 'జనమతీధ్వం (ఐచ్ఛికం)';

  @override
  String get profileBirthTimeLabel => 'జనన సమయం (ఐచ్ఛికం)';

  @override
  String get profileBirthTimeHelper => 'వేదీక సూచనలు మరింత ఖచ్చితంగా చేస్తుంది';

  @override
  String get profileBirthPlaceLabel => 'జనన ప్రదేశం (ఐచ్ఛికం)';

  @override
  String get profileBirthPlaceHint => 'ఉదాహరణకు, న్యూఢిల్లీ, భారతదేశం';

  @override
  String get profileHelpContactTitle => 'ఏదైనా అడగండి';

  @override
  String get profileHelpContactBody =>
      'మెస్సేజ్ పంపండి, మేము సాధారణంగా ఒక రోజులో ఇమెయిల్ ద్వారా సమాధానం ఇస్తాము.';

  @override
  String get profileHelpContactAction => 'సపోర్ట్‌కు సమాకరించండి';

  @override
  String get profileHelpFaqTitle => 'సాధారణ ప్రశ్నలు';

  @override
  String get profileFaqAddPiecesTitle =>
      'నేను క్లోసెట్‌కు పీసెస్‌ను ఎలా అదాగుతాను?';

  @override
  String get profileFaqAddPiecesBody =>
      'క్లోసెట్ ట్యాబ్‌లో “Add item”‌ను నొక్కండి. ఫోటో తీయండి లేదా గ్యాలరీ నుండి ఎంచుకోండి; మేము ప్రతి పీస్‌ను కనుగొని ట్యాగ్ చేస్తాము.';

  @override
  String get profileFaqMatchingTitle =>
      'అవుట్‌ఫిట్ మ్యాచింగ్ ఎలా పనిచేస్తుంది?';

  @override
  String get profileFaqMatchingBody =>
      '“For you”ని తెరిచి మీరిచ్చే పీసెస్‌ను ఎంచుకోండి. అవి ఏమేంటి అనుకొనుకుని మీ క్లోసెట్‌లోని అవుట్‌ఫిట్‌లు మేము సూచిస్తాము.';

  @override
  String get profileFaqTryOnTitle =>
      'ట్రై-ఆన్ కోసం నా స్వంత ఫోటోలను ఉపయోగించవచ్చా?';

  @override
  String get profileFaqTryOnBody =>
      'అవును. మీ పూర్తి ఎత్తు ఫోటోను అదాను, తర్వాత మీపై వాటిని చూడటానికి పీసెస్‌ను ఎంచుకోండి.';

  @override
  String get profileFaqRewardsTitle => 'నేను రివార్డ్స్‌ను ఎలా సంపాదించగలను?';

  @override
  String get profileFaqRewardsBody =>
      'గూర్చుకోండి మరియు తరచుగా అవుట్‌ఫిట్స్‌ను నమోదు చేయండి. మీరు ప్రయాణంలో స్ట్రీక్‌లు మరియు అదయాతలు పెరుగుతాయి.';

  @override
  String get profileFaqPrivacyTitle => 'నా క్లోసెట్ ప్రైవేటా?';

  @override
  String get profileFaqPrivacyBody =>
      'అవును. ఒక అవుట్‌ఫిట్‌కు లింక్‌ను పంచుకోకపోతే మీ క్లోసెట్ మరియు అవుట్‌ఫిట్స్ ప్రైవేట్‌గా ఉంటాయి.';

  @override
  String get profileHelpMoreTitle => 'మరిన్ని సహాయం';

  @override
  String get profileHelpGuides => 'గైడ్‌లు';

  @override
  String get profileHelpGuidesBody => 'ప్రతి ఫీచర్ ఎలా పనిచేస్తుంది';

  @override
  String get feedbackCategoryBug => 'ఏదైనా తప్పు జరిగింది';

  @override
  String get feedbackCategoryIdea => 'ఒక ఆలోచన';

  @override
  String get feedbackCategoryGeneral => 'సాధారణం';

  @override
  String get feedbackCategoryHelp => 'కావాలి సహాయం';

  @override
  String get feedbackHintBug =>
      'ఏమి జరిగింది, మరియు మీరు ఏమి అనుకున్నారో? స్టెప్స్ మాములుగా సహాయపడతాయి.';

  @override
  String get feedbackHintIdea => 'మీరు ఏమి కోరుకుంటున్నారు, మరియు ఎందుకు?';

  @override
  String get feedbackHintGeneral =>
      'మీరు ఏమి అనుకుంటున్నారో చెప్పండి, లేదా ప్రశ్న అడగండి.';

  @override
  String get feedbackAttachmentLimitBody =>
      'మీరు గరిష్టంగా 5 ఇమేజ్‌లను అదాగలరు.';

  @override
  String get feedbackAttachmentLimitTitle => 'పరిమితి చేరుకుంది';

  @override
  String get feedbackImageTooLargeBody =>
      '5 MB కంటే తక్కువ సైజులోని ఇమేజ్‌ను ఎంచుకోండి.';

  @override
  String get feedbackImageTooLargeTitle => 'ఇమేజ్ చాలా పెద్దది';

  @override
  String get feedbackTitle => 'ఫీడ్‌బ్యాక్ పంపండి';

  @override
  String get feedbackAboutLabel => 'దేని గురించి?';

  @override
  String get feedbackSubjectLabel => 'విషయం';

  @override
  String get feedbackSubjectRequired => 'విషయం ఇవ్వండి';

  @override
  String get feedbackSubjectTooShort => 'విషయం కనీసం 3 అక్షరాలే అయ్యే అవసరం';

  @override
  String get feedbackDetailsLabel => 'వివరాలు';

  @override
  String get feedbackDetailsRequired => 'కొంత వివరాలు ఇవ్వండి';

  @override
  String get feedbackDetailsTooShort => 'వివరణ కనీసం 10 అక్షరాలే అయ్యే అవసరం';

  @override
  String get feedbackAddScreenshot => 'స్క్రీన్‌షాట్ జోడించండి';

  @override
  String get feedbackAttachmentHint => 'గరిష్ఠంగా 5, ఐదు MB వరకు';

  @override
  String get feedbackSend => 'పంపండి';

  @override
  String get feedbackEmptyTitle => 'ఇంకా ఏదీ పంపలేదు';

  @override
  String get feedbackEmptyBody =>
      'మీరు పంపినవి దాని స్థితితో ఇక్కడ కనిపిస్తాయి.';

  @override
  String get feedbackHistoryTitle => 'మీరు పంపినవి';

  @override
  String get feedbackStatusOpen => 'ఓపెన్';

  @override
  String get feedbackStatusInProgress => 'ప్రగతిలో';

  @override
  String get feedbackStatusResolved => 'తీరుతూంది';

  @override
  String get feedbackStatusClosed => 'క్లోజ్';

  @override
  String get legalIntro =>
      'మీ డేటాను మేము ఎలా రక్షిస్తామో, FitCheck AIని వాడే నిబంధనలు ఇవి.';

  @override
  String get legalPolicies => 'పాలసీలు';

  @override
  String get legalPrivacySubtitle => 'మేము ఏమి సేకరిస్తామో ఎందుకునో';

  @override
  String get legalTermsTitle => 'సేవ నిబంధనలు';

  @override
  String get legalTermsSubtitle => 'యాప్ వాడే నిబంధనలు';

  @override
  String get legalLicences => 'ఓపెన్-సోర్స్ లైసెన్సులు';

  @override
  String get legalSupportSubtitle =>
      'సహాయం, సంప్రదించడం మరియు ప్రైవసీ అభ్యర్థనలు';

  @override
  String get legalReportAbuse => 'సమస్య లేదా వేమార్పిడిని నివేదించండి';

  @override
  String get permissionCameraTitle => 'కెమెరా యాక్సెస్';

  @override
  String get permissionCameraRationale =>
      'AI ట్రై-ఆన్ మరియు క్లోజెట్ ఆర్గనైజేషన్‌కు మీ దుకాణాలు మరియు ఔట్‌ఫిట్ల ఫోటోలు తీయడానికి FitCheck AI మీ కెమెరాను వాడుతుంది.';

  @override
  String get permissionPhotoTitle => 'ఫోటో యాక్సెస్';

  @override
  String get permissionPhotoRationale =>
      'AI ఫీచర్లు మరియు మీ క్లోజెట్ కోసం దుకాణాలు మరియు ఔట్‌ఫిట్ చిత్రాలను ఎంచుకోవడానికి FitCheck AI మీ ఫోటోలకు యాక్సెస్ అవసరం.';

  @override
  String get permissionNotNow => 'ఇప్పుడు కాదు';

  @override
  String get permissionOpenSettings => 'సెట్టింగ్‌లు తెరవండి';

  @override
  String authSignedInAs(String name) {
    return '$name గా సైన్ ఇన్ అయ్యారు';
  }

  @override
  String get authSignedIn => 'సైన్ ఇన్ అయ్యారు';

  @override
  String get authWelcomeBackTitle => 'మరొక్కసారి స్వాగతం';

  @override
  String get authSignInFailed => 'సైన్ ఇన్ విఫలమైంది';

  @override
  String get authWelcomeTitle => 'స్వాగతం';

  @override
  String get authSignUpFailed => 'సైన్ అప్ విఫలమైంది';

  @override
  String get authGoogleSignInFailed => 'గూగుల్ సైన్ ఇన్ విఫలమైంది';

  @override
  String get authAppleSignInFailed => 'ఆపిల్ సైన్ ఇన్ విఫలమైంది';

  @override
  String get authConfirmEmailTitle => 'మీ ఇమెయిల్ నిర్ధారించండి';

  @override
  String get authConfirmEmailBody =>
      'పరిశీలన ఇమెయిల్ కోసం మీ ఇన్‌బాక్స్ చూడండి, తరువాత సైన్ ఇన్ అవ్వండి.';

  @override
  String get authClosetReady => 'మీ క్లార్ట్ సిద్ధంగా ఉంది.';

  @override
  String get authSignedOutTitle => 'సైన్ అవుట్ అయ్యారు';

  @override
  String get authSignedOutBody => 'మీరు సైన్ అవుట్ అయ్యారు.';

  @override
  String get authSignOutFailed => 'సైన్ అవుట్ విఫలమైంది';

  @override
  String get authEmailSentTitle => 'ఇమెయిల్ పంపించబడింది';

  @override
  String get authResetLinkSent => 'రిసెట్ లింక్ కోసం మీ ఇమెయిల్ చూడండి.';

  @override
  String get authPasswordUpdatedTitle => 'పాస్‌వర్డ్ నవీకరించబడింది';

  @override
  String get authPasswordUpdated => 'మీ పాస్‌వర్డ్ నవీకరించబడింది.';

  @override
  String get authPasswordNotUpdated => 'పాస్‌వర్డ్ నవీకరించబడలేదు';

  @override
  String get authCouldNotSendEmail => 'ఇమెయిల్ పంపలేకపోయారు';

  @override
  String get authEmailNotSent => 'ఇమెయిల్ పంపబడలేదు';

  @override
  String get authResendSentBody => 'నవీన పరిశీలన ఇమెయిల్ పంపించాం.';

  @override
  String get outfitPreviewWithAi => 'AIతో ప్రివ్యూ';

  @override
  String get outfitNewPreview => 'కొత్త ప్రివ్యూ రూపొందించండి';

  @override
  String get outfitBuilderClosetHeading => 'మీ క్లార్ట్';

  @override
  String get outfitBuilderSearchHint => 'కబాతలు వెతకండి';

  @override
  String get outfitClearSearch => 'శోధనను తొలగించండి';

  @override
  String get outfitBuilderAddPiecesTitle => 'ముందుగా కబాతలను జోడించండి';

  @override
  String get outfitBuilderAddPiecesBody =>
      'క్లార్ట్‌లోని కబాతలతో వస్త్రాలు తయారు చేస్తారు.';

  @override
  String get outfitBuilderNoMatches => 'ఆ అనుగుణంగా ఉన్న కబాతలు లేవు.';

  @override
  String get outfitNameLabel => 'వస్త్రం పేరు';

  @override
  String get outfitNameHint => 'ఉదాహరణకు, వీకెండ్ లిన్';

  @override
  String get outfitPreviewSemantic => 'వేషం యొక్క AI ప్రీవ్యూ';

  @override
  String get outfitChoosePieces => 'పీస్‌లు ఎంచుకోండి';

  @override
  String get outfitTapPiecesHint =>
      'జోడించడానికి క్రింది పీస్‌లను ట్యాప్ చేయండి.';

  @override
  String get outfitShareTooltip => 'షేర్ చేయండి';

  @override
  String get outfitSaveFavourite => 'ఇష్టాల్లోనివ్వరికి సేవ్ చేయండి';

  @override
  String get outfitPiecesHeading => 'పీస్‌లు';

  @override
  String get outfitWearHistoryEmpty =>
      'ఒక్కసారి ధరిస్తే తేదీలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get outfitWearHistoryTitle => 'ధరించిన చరిత్ర';

  @override
  String get outfitWearHistoryError => 'తేదీలను లోడ్ చేయలేదు.';

  @override
  String get outfitWornOn => 'ధరించిన తేదీ';

  @override
  String get outfitEditTitle => 'వేషాన్ని సవరించండి';

  @override
  String get outfitSavedPhotosFailed => 'వివరాలు సేవ్ అయ్యాయి, చిత్రాలు కాదు';

  @override
  String get outfitNoPhotosBody =>
      'ఇంకా చిత్రాలు లేవు. పిచ్చేతరం దాని పీస్‌లను చూపిస్తుంది.';

  @override
  String get outfitOccasionLabel => 'అవకాశం';

  @override
  String get outfitOccasionNone => 'ఒంట';

  @override
  String get outfitTagsHint => 'కామాతో వేరు చేయండి';

  @override
  String get outfitDraftBody => 'మీ ప్రధాన జాబితా నుండి దాచబడింది';

  @override
  String get outfitPublic => 'గోప్యం';

  @override
  String get outfitPublicBody => 'లింక్ ఉన్నవారు అందరూ దానిని చూడగలరు';

  @override
  String get outfitDeleteFromDetail =>
      'దాని వివర పేజీ నుండి ఈ వేషాన్ని తొలగించండి.';

  @override
  String get outfitNewCollection => 'కొత్త సేకరణ';

  @override
  String get outfitNoCollectionsTitle => 'ఇంకా సేకరణలు లేవు';

  @override
  String get outfitNoCollectionsBody =>
      'యాత్ర, వర్షాతితీల లేదా ఊహ అనుసరించి వేషాలను సమూహపరం చేయండి.';

  @override
  String get outfitCreateCollection => 'సేకరణను సృష్టించండి';

  @override
  String get outfitAddOutfits => 'వేషాలు జోడించండి';

  @override
  String get outfitRename => 'పేరు మార్చండి';

  @override
  String get outfitCollectionDeleteBody => 'దానిలోని వేషాలు నిల్వ చేయబడతాయి.';

  @override
  String get outfitCollectionsNotLoaded => 'వేషాలు లోడ్ కాలేదు';

  @override
  String get outfitRenameCollection => 'సేకరణను పేరు మార్చండి';

  @override
  String get outfitDescriptionOptional => 'వివరణ (ఐచ్ఛికం)';

  @override
  String get outfitAllInCollection => 'ప్రతి అవుట్‌ఫిట్ ఈ కలెక్షన్‌లో ఉంది.';

  @override
  String get photoshootSubtitleUpload =>
      'మీ ఫోటోల నుండి స్టూడియో పోర్ట్‍్రెట్లు';

  @override
  String get photoshootSubtitleConfigure =>
      'ఒక శైలి, ఫార్మాట్ మరియు సంఖ్యను ఎంచుకోండి';

  @override
  String get photoshootSubtitleGenerating =>
      'దీనికి ఒక లేదా రెండు నిమిషాలు పడుతుంది';

  @override
  String get photoshootAddPhotosSemantic => 'మీ గ్యాలరీ నుండి ఫోటోలు జోడించండి';

  @override
  String get photoshootUploadTitle =>
      'మీ గ్యాలరీ నుండి 1 నుండి 4 ఫోటోలను ఎంచుకోండి';

  @override
  String get photoshootUploadBody =>
      'మీ గ్యాలరీ నుండి ఎంచుకోవడానికి ట్యాప్ చేయండి';

  @override
  String get photoshootAddToContinue => 'కొనసాగడానికి ఒక ఫోటో జోడించండి';

  @override
  String get photoshootAddAnotherPhoto => 'మరో ఫోటో జోడించండి';

  @override
  String get photoshootTipsTitle => 'ఉత్తమ ఫలితాల కోసం';

  @override
  String get photoshootTipsBody =>
      'మీ ముఖం యొక్క స్పష్టమైన, నింపిన బెల్ట్ ఫోటోలను కొన్ని కోణాల నుండి ఉపయోగించండి. సన్‌గ్లాసెస్ మరియు హ్యాట్‌లు జాగ్రత్తగా నిలకూరుకోండి.';

  @override
  String get photoshootStarting => 'ప్రారంభమవుతోంది';

  @override
  String get photoshootCancelling => 'రద్దవుతోంది';

  @override
  String get photoshootFailed => 'విఫలమైంది';

  @override
  String get recommendTabMatches => 'మ్యాచ్‌లు';

  @override
  String get recommendTabComplete => 'పూర్తి';

  @override
  String get recommendTabWeather => 'వాతావరణం';

  @override
  String get recommendTabColours => 'రంగులు';

  @override
  String get recommendTabShop => 'వెలుగు';

  @override
  String get recommendNoMatchesTitle => 'ఇంకా మ్యాచ్‌లు లేవు';

  @override
  String get recommendNoMatchesBody =>
      'ఒక భాగాన్ని ఎంచుకోండి మరియు దానికి దగ్గరగా ఉన్నదాన్ని కనుగొనుతాము.';

  @override
  String get recommendPickPiece => 'భాగాన్ని ఎంచుకోండి';

  @override
  String get recommendNothingMatchesTitle => 'ఇంకా ఏదీ దీనికి అనుకూలించదు';

  @override
  String get recommendNothingMatchesBody =>
      'మరని భాగాలను ప్రయత్నించండి లేదా మీ క్లారెట్‌కు మరిన్ని జోడించండి.';

  @override
  String get recommendChangePieces => 'భాగాలను మార్చండి';

  @override
  String get recommendDefaultReason => 'మీరు ఎంచుకున్న భాగాలకు ఇది సరిపోతుంది.';

  @override
  String get recommendCompleteTitle => 'ఒక లుక్‌ను పూర్తి చేయండి';

  @override
  String get recommendCompleteBody =>
      'ఒక భాగాన్ని ఎంచుకోండి, మనం మిగిలిన భాగాలను నింపుతాము.';

  @override
  String get recommendWorking => 'పని చేస్తోంది';

  @override
  String get recommendGenerate => 'సృష్టించండి';

  @override
  String get recommendChooseStyleBody =>
      'ఒక శైలిని ఎంచుకోండి, తర్వాత సృష్టించండి.';

  @override
  String get recommendNoLooksTitle => 'ఈ వస్త్రాల కోసం లుక్‌లు లేవు';

  @override
  String get recommendNoLooksBody =>
      'మరొక శైలి లేదా వేరే వస్త్రాలను ప్రయత్నించండి.';

  @override
  String get recommendDefaultLook => 'మీ వస్త్రాలకు ఒక లుక్';

  @override
  String get recommendNoPiecesBody => 'ఈ లుక్ కోసం ఏ వస్త్రాలు రాలేదు.';

  @override
  String get recommendCityLabel => 'పట్నం';

  @override
  String get recommendCheck => 'చూడండి';

  @override
  String get recommendWeatherTitle => 'వాతావరణం ఎలా ఉంది?';

  @override
  String get recommendWeatherBody =>
      'నేటికి సరైన వస్త్రాలు చూపించడానికి మీ పట్నాన్ని నమోదు చేయండి.';

  @override
  String get recommendWearToday => 'నేడు ధరించండి';

  @override
  String get recommendWeatherNoPieces =>
      'ఈ వాతావరణానికి మీ వార్డ్‌రోబ్‌లో ఇంకా వస్త్రాలు లేవు.';

  @override
  String get recommendBudgetLabel => 'బడ్జెట్';

  @override
  String get recommendLooking => 'తెలుసుకోండి';

  @override
  String get recommendFindWhatToBuy => 'ఎంపిక చేయండి';

  @override
  String get recommendFillGapsTitle => 'దోషాలను పూరించండి';

  @override
  String get recommendFillGapsBody =>
      'బడ్జెట్‌ను సెట్ చేయండి, మీ వార్డ్‌రోబ్‌లో లేని వస్త్రాలను అనుభవపూర్వకంగా సూచిస్తాం.';

  @override
  String get recommendNoGapsTitle => 'దోషాలు తవ్వబడలేదు';

  @override
  String get recommendNoGapsBody =>
      'మీరు పెద్ద బడ్జెట్‌ని లేదా వేరే వర్గీకరణను ప్రయత్నించండి.';

  @override
  String get recommendMoodEveryday => 'ప్రతిరోజూ';

  @override
  String get recommendMoodBigMeeting => 'పెద్ద సమావేశం';

  @override
  String get recommendDayLabel => 'రోజు';

  @override
  String get recommendReadingStars => 'గ్రహాలను చదవడం';

  @override
  String get recommendGetMyColours => 'నా రంగులను పొందండి';

  @override
  String get recommendLuckyColoursTitle => 'మీ మంచి రంగులు';

  @override
  String get recommendLuckyColoursBody =>
      'ఒక రోజును ఎంచుకోండి, మేము అందుకు అనుగుణంగా రంగులు మరియు వస్త్రాలను సూచిస్తాం.';

  @override
  String get recommendLuckyColoursSection => 'మంచి రంగులు';

  @override
  String get recommendAvoidColoursSection => 'గమనించాల్సిన రంగులు';

  @override
  String get recommendBirthDateTitle => 'మీ జన్మ తేదీని జోడించండి';

  @override
  String get recommendBirthDateBody =>
      'మీ రంగులను చదవడానికి మీ జన్మ తేదీ అవసరం.';

  @override
  String get recommendEditProfile => 'ప్రాఫైల్ ఎడిట్ చేయండి';

  @override
  String get recommendNothingThisDay => 'ఈ రోజుకు ఏమీ లేదు.';

  @override
  String get recommendUnnamedColour => 'పేరులేని రంగు';

  @override
  String get recommendFromCloset => 'మీ క్లోసెట్ నుండి';

  @override
  String get recommendNoPiecesInColours => 'ఈ రంగుల్లో ఇంకా ఏవీ లేవు.';

  @override
  String get recommendOutfitIdeas => 'ఆప్ట్రైడ్ ఆలోచనలు';

  @override
  String get recommendNoOutfitsInColours =>
      'ఈ రంగుల్లో పూర్తి ఆప్ట్రైడ్ ఇంకా లేదు.';

  @override
  String get recommendDefaultOutfitIdea => 'ఒక ఆప్ట్రైడ్ ఆలోచన';

  @override
  String get recommendPickUpToThree => 'మూడు వస్తువులను ఎంచుకోండి';

  @override
  String get recommendEmptyClosetBody =>
      'ముందుగా కొన్ని వస్తువులను జోడించండి, తర్వాత మ్యాచ్‌ల కోసం తిరిగి వచ్చేయండి.';

  @override
  String get dashboardDressForDay => 'బాక్యం రోజుకు దుస్తులు ధరించండి.';

  @override
  String get dashboardOutfitOfDay => 'రోజు ఆప్ట్రైడ్';

  @override
  String get dashboardFreshLook => 'కొత్త లూక్';

  @override
  String get subscriptionManageInStoreTitle => 'స్టోర్‌లో నిర్వహించండి';

  @override
  String get subscriptionManageInStoreBody =>
      'ఈ ప్లాన్ స్టోర్ ద్వారా బిల్లు వినియోగించబడుతుంది. దాన్ని మీ స్టోర్ ఖాతా సెట్టింగ్‌లలో నిర్వహించండి.';

  @override
  String get subscriptionCancelledTitle => 'సబ్‌స్క్రిప్షన్ రద్దు చేయబడింది';

  @override
  String get subscriptionCancelledBody =>
      'మీ ప్లాన్ ఈ బిల్లింగ్ కాలం చివరి వరకు సక్రియంగా ఉంటుంది.';

  @override
  String get subscriptionCancelFailedTitle => 'రద్దు చేయలేకపోయాము';

  @override
  String get subscriptionCouldNotOpenTitle => 'తెరవలేకపోయాము';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'బిల్లింగ్ నిర్వహణను తెరవలేకపోయాము.';

  @override
  String get subscriptionOpenLinkFailedBody => 'లింక్‌ను తెరవలేకపోయాము.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'మీ లింక్‌ను లోడ్ చేయలేకపోయాము';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'మీ రెఫరల్ లింక్‌ను లోడ్ చేయలేకపోయాము. తిరగగా ప్రయత్నించండి.';

  @override
  String get subscriptionReferralCopiedTitle => 'కాపీ చేయబడింది';

  @override
  String get subscriptionReferralCopiedBody => 'రెఫరల్ లింక్ కాపీ చేయబడింది.';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI ప్రయత్నించండి';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI కు చేరండి, మనం ఇద్దరం కూడా Proకు ఒక నెల వరకు పొందుతాము. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'లింక్ కాపీ చేయబడింది';

  @override
  String get subscriptionShareUnavailableBody =>
      'షేరింగ్ అందుబాటులో లేదు, కాబట్టి మనం లింక్‌ను కాపీ చేశాము.';

  @override
  String get subscriptionShareFailedTitle => 'షేర్ చేయలేకపోయాము';

  @override
  String get subscriptionShareFailedBody =>
      'మార్పిడి పేజీ నుండి లింక్ను కాపీ చేయండి.';

  @override
  String get subscriptionStoreReadyTitle => 'మందిరం సిద్ధం';

  @override
  String get subscriptionStoreReadyBody =>
      'మందిర ధరలు అందుబాటులో ఉన్నాయి. ఇప్పుడు అప్‌గ్రేడ్ చేయవచ్చు.';

  @override
  String get purchaseFailedTitle => 'కొనుగోలు విఫలమైంది';

  @override
  String get purchaseUnavailableTitle => 'కొనుగోలు అందుబాటులో లేదు';

  @override
  String get purchaseIapUnavailableBody =>
      'ఈ పరికరంలో యాప్‌లో కొనుగోళ్లు అందుబాటులో లేవు.';

  @override
  String get purchasePlanNotAvailableBody =>
      'ఈ ప్లాన్ ఇంకా కొనుగోలుకు అందుబాటులో లేదు.';

  @override
  String get purchasePlanNotInStoreBody =>
      'ఈ ప్లాన్ ఇంకా స్టోర్‌లో అందుబాటులో లేదు. త్వరలో పరిశీలించండి.';

  @override
  String get purchaseStartFailedBody =>
      'కొనుగోలు ప్రారంభించలేకపోయాము. మళ్లీ ప్రయత్నించండి.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'చెక్‌అవుట్ పేమెంట్ లింక్‌ను అందించలేదు.';

  @override
  String get purchasePendingTitle => 'కొనుగోలు వాయిదా';

  @override
  String get purchasePendingBody =>
      'మీ కొనుగోలు ఆమోదానికి ఎదురుచూస్తోంది. ఆమోదం వీలుగానే అనుమతి లభిస్తుంది.';

  @override
  String get purchaseFailedBody => 'కొనుగోలు విఫలమైంది. మళ్లీ ప్రయత్నించండి.';

  @override
  String get purchaseRestoredTitle => 'తిరిగి పునరుద్ధరించబడింది';

  @override
  String get purchaseRestoredBody =>
      'మీ కొనుగోళ్లు తిరిగి పునరుద్ధరించబడ్డాయి.';

  @override
  String get purchaseActiveTitle => 'సబ్‌స్క్రిప్షన్ సక్తివంతంగా యాక్టివ్';

  @override
  String get purchaseActiveBody => 'మీ సబ్‌స్క్రిప్షన్ యాక్టివ్. స్వాగతం.';

  @override
  String get purchaseSignInRequiredTitle => 'సైన్ ఇన్ అవసరం';

  @override
  String get purchaseSignInRequiredBody =>
      'మీ కొనుగోలును పూర్తి చేయడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get purchaseErrorTitle => 'కొనుగోలు దోషం';

  @override
  String get purchaseInvalidTransactionBody =>
      'కొనుగోలులో ధృవీకరించదగిన ట్రాన్స్‌లాక్షన్ ఐడి ఉంది లేదు.';

  @override
  String get purchaseVerificationPendingTitle => 'ధృవీకరణ వాయిదా';

  @override
  String get purchaseVerificationPendingBody =>
      'ప్రస్తుతం స్టోర్‌తో మీ కొనుగోలును ధృవీకరించలేకపోయాము. ఇది ఆటోమేటికల్గా పూర్తి అవుతుంది, ఇద్దరుసార్లు ఛార్జ్ చేయబడదు.';

  @override
  String get purchaseNotAppliedTitle => 'కొనుగోలు వర్తింపజేయబడలేదు';

  @override
  String get purchaseNotAppliedBody =>
      'మీ కొనుగోలు మీ అకౌంట్‌కు వర్తింపజేయలేకపోయింది. సపోర్ట్‌ను సంప్రదించండి, మళ్లీ కొనకండి.';

  @override
  String get purchaseRestoreFailedTitle => 'తిరిగి పునరుద్ధరణ విఫలమైంది';

  @override
  String get purchaseRestoreFailedBody =>
      'కొనుగోళ్లను తిరిగి పునరుద్ధరించలేకపోయాము. మళ్లీ ప్రయత్నించండి.';

  @override
  String get purchaseRecoveredActiveBody => 'మీ సబ్‌స్క్రిప్షన్ యాక్టివ్.';

  @override
  String get purchaseCompleteTitle => 'కొనుగోలు పూర్తి';

  @override
  String get giftCreateFailedTitle => 'జాతి సృష్టించలేకపోయింది';

  @override
  String get giftClaimFailedTitle => 'ఆహ్వానం పొందడం విఫలమైంది';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఆహ్వానాలు మీకు',
      one: 'మీకు ఒక ఆహ్వానం',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 నెల',
      '12': '1 సంవత్సరం',
      'other': '$months నెలలు',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining మిగిలి ఉన్నాయి',
      one: '1 మిగిలి ఉంది',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender మీకు $duration FitCheck Pro పంపారు. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient కు FitCheck Pro ఆహ్వానం';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender నుండి';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient కు';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender నుండి';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'మీ గ్రహీత';

  @override
  String get giftPreviewPlaceholderSender => 'మీరు';

  @override
  String get settingsSavedTitle => 'సేవ్ చేయబడింది';

  @override
  String get settingsNotSavedTitle => 'సేవ్ చేయలేదు';

  @override
  String get settingsAiChooseProviderBody => 'ఒక సరఫరాదారును ఎంచుకోండి.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'కస్టమ్ సరఫరాదారుకు API URL అవసరం.';

  @override
  String get settingsAiKeyRequiredBody => 'API కీని నమోదు చేయండి.';

  @override
  String get settingsAiSavedBody => 'మీ AI సెట్టింగ్‌లు సేవ్ చేయబడ్డాయి.';

  @override
  String get settingsAiMissingDetailsTitle => 'వెనుకబడిన వివరాలు';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'పరీక్షించడానికి API URL మరియు చాట్ మోడల్ నమోదు చేయండి.';

  @override
  String get settingsAiKeyNeededTitle => 'API కీ అవసరం';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'పరీక్షించడానికి మీ API కీని నమోదు చేయండి. మీ సేవ్ చేసిన కీ ప్రైవేట్‌గా ఉంటుంది.';

  @override
  String get settingsAiKeyToTestBody =>
      'పరీక్షించడానికి మీ API కీని నమోదు చేయండి.';

  @override
  String get settingsAiConnectedTitle => 'కనెక్ట్ అయ్యింది';

  @override
  String get settingsAiConnectedBody => 'కనెక్షన్ పనిచేస్తుంది.';

  @override
  String get settingsAiTestFailedTitle => 'పరీక్ష విఫలమైంది';

  @override
  String get settingsPreferencesSavedBody => 'మీ ఎంపికలు సేవ్ చేయబడ్డాయి.';

  @override
  String get settingsPasswordNotChangedTitle => 'పాస్‌వర్డ్ మార్చలేదు';

  @override
  String get settingsOAuthPasswordBody =>
      'ఈ ఖాతా Google లేదా Appleతో సైన్ ఇన్ చేస్తుంది. ముందుగా పాస్‌వర్డ్ సెట్ చేయడానికి \"పాస్‌వర్డ్ మర్చిపోయారా\" ఉపయోగించండి.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'ప్రస్తుత పాస్‌వర్డ్ సరిగ్గా లేదు.';

  @override
  String get settingsExportReadyTitle => 'ఎగుమతి సిద్ధం';

  @override
  String get settingsExportReadyBody =>
      'మీ డేటా ఎగుమతి డౌన్‌లోడ్‌కు సిద్ధంగా ఉంది.';

  @override
  String get settingsLinkCopiedTitle => 'లింక కాపీ అయింది';

  @override
  String get settingsExportClipboardBody =>
      'మీ బ్రౌజర్‌ను తెరవలేము, కాబట్టి డౌన్‌లోడ్ లింకను కాపీ చేశాము. దయచేసి త్వరగా బ్రౌజర్‌లో పేస్ట్ చేయండి: అది అయిపోతుంది.';

  @override
  String get settingsExportFailedTitle => 'ఎగుమతి విఫలం';

  @override
  String get settingsAccountNotDeletedTitle => 'ఖాతా తొలగించబడలేదు';

  @override
  String photoshootPhotoLimit(int max) {
    return 'మీరు గరిష్ఠంగా $max ఫోటోలను జోడించవచ్చు.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'ఫోటో పరిమితి';

  @override
  String get photoshootAddAtLeastOnePhoto => 'కనీసం ఒక ఫోటోను జోడించండి.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'ఫోటోలు లేవు';

  @override
  String get photoshootDescribeLookBody => 'మీకు కావాల్సిన లుక్‌ను వివరించండి.';

  @override
  String get photoshootPromptNeededTitle => 'ప్రాంప్ట్ అవసరం';

  @override
  String get photoshootConsentFeatureLabel => 'AI ఫోటోశూట్';

  @override
  String get photoshootStatusPreparing => 'మీ ఫోటోలు సిద్ధపరచుతోంది';

  @override
  String get photoshootStatusGenerating => 'సృష్టిస్తోంది';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'బ్యాచ్ $current లో $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$total లో $done పూర్తయ్యాయి';
  }

  @override
  String get photoshootGenerationFailedBody => 'సృష్టి విఫలమైంది.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready సిద్ధం, $failed విఫలం.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'పక్షంగా పూర్తి';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫోటోలు సిద్ధంగా ఉన్నాయి.',
      one: '1 ఫోటో సిద్ధంగా ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'కనెక్షన్ కోల్పోయాము. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get photoshootCouldNotCancelTitle => 'రద్దు చేయలేకపోయాము';

  @override
  String get photoshootRetryFailedTitle => 'మళ్ళీ ప్రయత్నించడం విఫలం';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'ఫోటో $number సిద్ధంగా ఉంది.';
  }

  @override
  String get photoshootReplacedTitle => 'కూల్‌బ్రేప్ చేయబడింది';

  @override
  String get photoshootSavedToGalleryBody => 'మీ గ్యాలరీలో సేవ్ చేయబడింది.';

  @override
  String get photoshootSavedTitle => 'సేవ్ అయింది';

  @override
  String get photoshootNotSavedTitle => 'సేవ్ చేయబడలేదు';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'మొత్తం $count ఫోటోలు మీ గ్యాలరీలో ఉన్నాయి.',
      one: '1 ఫోటో మీ గ్యాలరీలో ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved of $total saved.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'కొన్ని ఫోటోలు సేవ్ కాలేదు';

  @override
  String get tryonConsentFeatureLabel => 'వర్చువల్ ట్రై-ఆన్';

  @override
  String get tryonAvatarUpdatedBody => 'మీ ఫోటో ఆప్‌డేట్ అయింది.';

  @override
  String get tryonSavedTitle => 'సేవ్ అయింది';

  @override
  String get tryonUploadFailedTitle => 'అప్‌లోడ్ విఫలమైంది';

  @override
  String get tryonChooseGarmentFirstBody => 'ముందుగా దుస్తుల ఫోటోని ఎంచుకోండి.';

  @override
  String get tryonNoGarmentTitle => 'దుస్తులు లేవు';

  @override
  String get tryonWaitForUploadBody =>
      'మీ ఫోటో అప్‌లోడ్ అవ్వాలని ఎదురు చూడండి.';

  @override
  String get tryonStillUploadingTitle => 'ఇంకా అప్‌లోడ్ అవుతోంది';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'ముందుగా మీ ప్రియమైన ఫోటోను జోడించండి.';

  @override
  String get tryonReadyBody => 'మీ ట్రై-ఆన్ సిద్ధమైంది.';

  @override
  String get tryonFailedTitle => 'ట్రై-ఆన్ విఫలమైంది';

  @override
  String get tryonSavedToGalleryBody => 'మీ గ్యాలరీలో సేవ్ చేయబడింది.';

  @override
  String get tryonNotSavedTitle => 'సేవ్ కాలేదు';

  @override
  String get calendarEventAddedBody => 'ఈవెంట్ జోడించబడింది';

  @override
  String get calendarEventPlannedTitle => 'ప్లాన్ చేయబడింది';

  @override
  String get calendarEventSavedBody => 'ఈవెంట్ సేవ్ అయింది';

  @override
  String get calendarSavedTitle => 'సేవ్ అయింది';

  @override
  String get calendarEventNotSavedTitle => 'ఈవెంట్ సేవ్ కాలేదు';

  @override
  String get calendarEventRemovedBody => 'ఈవెంట్ తీసెవేయబడింది';

  @override
  String get calendarEventDeletedTitle => 'తీసెవేయబడింది';

  @override
  String get calendarEventNotDeletedTitle => 'ఈవెంట్ తీసెవేయలేదు';

  @override
  String get calendarOutfitNotLinkedTitle => 'అవుట్‌ఫిట్ లింక్ కాలేదు';

  @override
  String get calendarLinkedTitle => 'లింక్ అయింది';

  @override
  String get calendarOutfitNotRemovedTitle => 'అవుట్‌ఫిట్ తీసెవేయలేదు';

  @override
  String get calendarOutfitRemovedBody => 'అవుట్‌ఫిట్ తీసెవేయబడింది';

  @override
  String get calendarDisconnectedBody => 'క్యాలెండర్ డిస్కనెక్ట్ అయింది';

  @override
  String get calendarDisconnectedTitle => 'డిస్కనెక్ట్ అయింది';

  @override
  String get calendarNotDisconnectedTitle => 'క్యాలెండర్ డిస్కనెక్ట్ కాలేదు';

  @override
  String get calendarTodayLabel => 'నేడు';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సంఘటనలు',
      one: '1 సంఘటన',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start నుండి $end వరకు';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, అవుట్‌ఫిట్ జోడించబడింది';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" తొలగించబడుతుంది.';
  }

  @override
  String get calendarThisAppLabel => 'ఈ యాప్';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider తో సెంక్‌సింగ్ ఇంకా అందుబాటులో లేదు. ఇక్కడ మీరు సంఘటనలను జోడించవచ్చు.';
  }

  @override
  String get calendarWeekdaySunShort => 'ఆది';

  @override
  String get calendarWeekdayMonShort => 'సో';

  @override
  String get calendarWeekdayTueShort => 'మంగళ';

  @override
  String get calendarWeekdayWedShort => 'బుధ';

  @override
  String get calendarWeekdayThuShort => 'గురు';

  @override
  String get calendarWeekdayFriShort => 'శుక్ర';

  @override
  String get calendarWeekdaySatShort => 'శని';

  @override
  String get calendarWeekdayMonday => 'సోమవారం';

  @override
  String get calendarWeekdayTuesday => 'మంగళవారం';

  @override
  String get calendarWeekdayWednesday => 'బుధవారం';

  @override
  String get calendarWeekdayThursday => 'గురువారం';

  @override
  String get calendarWeekdayFriday => 'శుక్రవారం';

  @override
  String get calendarWeekdaySaturday => 'శనివారం';

  @override
  String get calendarWeekdaySunday => 'ఆదివారం';

  @override
  String get outfitSavedToFavouritesBody => 'పేజీలలో సేవ్ చేయబడింది';

  @override
  String get outfitRemovedFromFavouritesBody => 'పేజీల నుండి తొలగించబడింది';

  @override
  String get outfitNotSavedTitle => 'సేవ్ కాలేదు';

  @override
  String get outfitLoggedAsWornBody => 'నేడు ధరించినట్లు నమోదైంది.';

  @override
  String get outfitNicePickTitle => 'బాగున్న ఎంపిక';

  @override
  String get outfitRemovedBody => 'అవుట్‌ఫిట్ తొలగించబడింది.';

  @override
  String get outfitDeletedTitle => 'తొలగించబడింది';

  @override
  String get outfitNotDeletedTitle => 'తొలగించబడలేదు';

  @override
  String get outfitDuplicatedBody => 'ముద్దరం మీ అవుట్‌ఫిట్లలో ఉంది.';

  @override
  String get outfitDuplicatedTitle => 'ముద్దరైంది';

  @override
  String get outfitNotDuplicatedTitle => 'ముద్దరనిల్లదు';

  @override
  String get outfitNotSharedTitle => 'ా పంచుకోలేదు';

  @override
  String outfitCollectionReadyBody(String name) {
    return '“$name” సిద్ధం.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'కలెక్షన్ సృష్టించలేదు';

  @override
  String get outfitCollectionUpdatedBody => 'కలెక్షన్ నవీకరించబడింది.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'కలెక్షన్ నవీకరించలేదు';

  @override
  String get outfitCollectionDeletedBody => 'కలెక్షన్ తొలగించబడింది.';

  @override
  String get outfitCollectionNotDeletedTitle => 'కలెక్షన్ తొలగించలేదు';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అవుట్‌ఫిట్లు చేర్చబడ్డాయి.',
      one: '1 అవుట్‌ఫిట్ చేర్చబడింది.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'అవుట్‌ఫిట్లు చేరలేదు';

  @override
  String get outfitPreviewNotCreatedTitle => 'ప్రీవ్యూ సృష్టించలేదు';

  @override
  String get outfitGiveNameBody => 'అవుట్‌ఫిట్కు పేరు ఇవ్వండి.';

  @override
  String get outfitNameMissingTitle => 'పేరు';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'కనీసం ఒక పీస్ ఎంచుకోండి.';

  @override
  String outfitCreatedBody(String name) {
    return '$name మీ అవుట్‌ఫిట్లలో ఉంది.';
  }

  @override
  String get outfitSavedTitle => 'సేవ్ అయింది';

  @override
  String get wardrobeAddedToFavouritesBody => 'ప్రియాపెటల్లకు చేర్చబడింది';

  @override
  String get wardrobeRemovedFromFavouritesBody =>
      'ప్రియాపెటల్ల నుంచి తీసివేయబడింది';

  @override
  String get wardrobeNotSavedTitle => 'సేవ్ కాలేదు';

  @override
  String get wardrobeLoggedAsWornBody => 'నేడు ధరించినదిగా నమోదయింది.';

  @override
  String get wardrobeRemovedFromClosetBody => 'మీ క్లజెట్ నుంచి తీసివేయబడింది.';

  @override
  String get wardrobeDeletedTitle => 'తొలగించబడింది';

  @override
  String get wardrobeNotDeletedTitle => 'తొలగించలేదు';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పీస్ మీ క్లజెట్ నుంచి తీసివేయబడ్డాయి.',
      one: 'మీ క్లజెట్ నుంచి 1 పీస్ తీసివేయబడింది.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI వార్డ్రోబ్ ఎక్స్ట్రాక్షన్';

  @override
  String get itemAddScanJobLabel => 'స్కాన్';

  @override
  String get itemAddFoundEarlierBody => 'మునుపటి స్కాన్‌లో కనుగొనబడింది';

  @override
  String get itemAddLookingAtPhoto => 'మీ ఫోటో చూస్తున్నాం';

  @override
  String get itemAddExtractionFailedBody => 'వివరాలు తీసుకోవడం సాధ్యం కాలేదు';

  @override
  String get itemAddJobFailedBody => 'పని విఫలమైంది';

  @override
  String get itemAddConnectionLostBody =>
      'కనెక్షన్ కోల్పోయింది. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'ప్రాసెస్ చేయగానే కనెక్షన్ కోల్పోయింది.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'కబ్లం $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'కబ్లం';

  @override
  String get itemAddNotCancelledTitle => 'రద్దు చేయలేదు';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'మీ క్లోసెట్లో $count ఐటెమ్లు ఉన్నాయి.',
      one: 'మీ క్లోసెట్లో 1 ఐటెమ్ ఉంది.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved వాటిలో $total కబ్లం సేవ్ అయ్యాయి. మిగతా వాటిని మళ్ళీ ప్రయత్నించడానికి సేవ్ ట్యాప్ చేయండి.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'కొన్ని కబ్లం సేవ్ కాలేదు';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'కనీసం ఒక ఫోటోను ఎంచుకోండి.';

  @override
  String get batchPhotoUnreadableBody => 'ఈ ఫోటోని చదవడం సాధ్యం కాలేదు.';

  @override
  String get batchNoPhotosReadableBody =>
      'ఈ ఫోటోల్లో ఏదీ చదవడం సాధ్యం కాలేదు. వేరే ఫోటోలు ప్రయత్నించండి.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫోటోలు',
      one: '1 ఫోటో',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'పని చేస్తుండగా కనెక్షన్ కోల్పోయింది. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get batchNotCancelledTitle => 'రద్దు చేయలేదు';

  @override
  String get batchPostLinkUnsupportedBody =>
      'పోస్ట్ లింకులు నిర్వహించబడవు. ప్రొఫైల్ లింక్ నమోదు చేయండి.';

  @override
  String get batchLinkSpacesBody => 'లింకులలో స్పేసు ఉండకూడదు.';

  @override
  String get batchEnterProfileLinkBody =>
      'ఇన్స్టాగ్రామ్ లేదా ఫేస్‌బుక్ ప్రొఫైల్ లింక్ నమోదు చేయండి.';

  @override
  String get batchEnterProfileLinkShortBody => 'ప్రొఫైల్ లింక్ నమోదు చేయండి.';

  @override
  String get batchSignInPageNotOpenBody =>
      'సైన్ ఇన్ పేజీ తెరవలేదు. మళ్ళీ ప్రయత్నించండి.';

  @override
  String get batchSignInBrowserBody =>
      'మీ బ్రౌజర్‌లో సైన్ ఇన్ చేసి, తర్వాత FitCheck‌కు తిరిగి రండి.';

  @override
  String get batchConnectAccountTitle => 'మీ ఖాతాను కనెక్ట్ చేయండి';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'మీ ఆథెంటికేటర్ యాప్ నుండి కోడ్ నమోదు చేయండి.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'ఇన్స్టాగ్రామ్ సెక్యూరిటీ చాక్ కోరుతుంది. ముందుగా మీ బ్రౌజర్‌లో సైన్ ఇన్ చేయండి.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'మీ యూజర్‌నెమ్ మరియు పాస్‌వర్డ్ మళ్ళీ నమోదు చేయండి.';

  @override
  String get batchSignInFailedBody =>
      'సైన్ ఇన్ విఫలమైంది. మీ యూజర్‌నెమ్ మరియు పాస్‌వర్డ్ తనిఖీ చేయండి.';

  @override
  String get batchSignInToKeepImportingBody =>
      'ఇంపోర్ట్ కొనసాగించడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get batchAccountNotConnectedBody => 'మీ ఖాతా కనెక్ట్ కాలేదు.';

  @override
  String get batchAccountConnectedTitle => 'ఖాతా కనెక్ట్ అయింది';

  @override
  String get batchNotConnectedTitle => 'కనెక్ట్‌ కాలదు';

  @override
  String get batchImportConnectionLostBody =>
      'పరిచయమవ్వడంలో కనెక్షన్ తెరచుపాటు. తనిఖీ చేయడానికి రిఫ్రెష్ చేయండి.';

  @override
  String batchPickUpToBody(int max) {
    return 'అధికం $max ఫోటోలు ఎంచుకోండి. అన్నింటిని మేము గుర్తించతాము.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count of $total ఫోటోలు';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '$done of $count ఫోటో సిద్ధంగా చేస్తున్నాము';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫోటోలలో భాగాలను కనుగొనండి',
      one: '1 ఫోటోలో భాగాలను కనుగొనండి',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'మీ $platform ఖాతా రెండు దశల సైన్-ఇన్‌ను ఉపయోగిస్తుంది. మీ ఆథెంటికేటర్ యాప్ నుండి 6-అంకెల కోడ్ నమోదు చేయండి.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'ఈ $platform ప్రొఫైల్ ప్రైవేట్‌గా ఉంది లేదా దాని ఫోటోలను చూపించడానికి సైన్-ఇన్ అవసరం.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform తో కనెక్ట్ అవ్వండి';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఇప్పటివరకు $count ఫోటోలు కనుగొన్నారు',
      one: 'ఇప్పటివరకు 1 ఫోటో కనుగొన్నారు',
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
    return '$total లో $processed ప్రోసెస్డ్ · $added జోడించబడ్డాయి · $waiting వేచిపడుతున్నాయి · $skipped నిర్లక్ష్యం చేయబడ్డాయి';
  }

  @override
  String batchScanningPhoto(int number) {
    return '$number ఫోటో స్కాన్ చేస్తున్నాము';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '$number ఫోటో తదుపరిది';
  }

  @override
  String batchPhotoLabel(int number) {
    return '$number ఫోటో';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count భాగాలు కనుగొన్నారు',
      one: '1 భాగం కనుగొన్నారు',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫోటోలు మీ క్లాజెట్‌కు జోడించబడ్డాయి.',
      one: '1 ఫోటో మీ క్లాజెట్‌కు జోడించబడింది.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'మరిన్ని $count స్టూడియో ఫోటోలు రానున్నాయి. సిద్ధమైనవి మేము ఉంచుతాము, లేదా వెళ్లిపోండి — మేము మీకు తెలియజేస్తాము.',
      one:
          'మరో 1 స్టూడియో ఫోటో రానుంది. సిద్ధమైనవి మేము ఉంచుతాము, లేదా వెళ్లిపోండి — మేము మీకు తెలియజేస్తాము.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'ఇంకా సేవ్ కాలేదు: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos ఫోటోల',
      one: '1 ఫోటో',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces భాగాలు',
      one: '1 భాగం',
    );
    return '$_temp0 నుండి $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen ఎంచుకోబడ్డాయి. తర్లించడానికి ఒక భాగంపై ట్యాప్ చేయండి.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count భాగాలను సేవ్ చేస్తున్నాము',
      one: '1 భాగం సేవ్ చేస్తున్నాము',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count భాగాలను సేవ్ చేయండి',
      one: '1 భాగం సేవ్ చేయండి',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'మీ బాడీ ప్రొఫైల్ సేవ్ చేయబడింది.';

  @override
  String get bodyProfileSavedTitle => 'సేవ్ చేయబడింది';

  @override
  String get bodyProfileNotSavedTitle => 'సేవ్ కాలదు';

  @override
  String get bodyProfileSetDefaultBody =>
      'మీ డీఫాల్ట్ ప్రొఫైల్‌గా సెట్ చేయండి.';

  @override
  String get bodyProfileDeletedBody => 'బాడీ ప్రొఫైల్ తొలగించబడింది.';

  @override
  String get bodyProfileDeletedTitle => 'తొలగించబడింది';

  @override
  String get bodyProfileNotDeletedTitle => 'తొలగించబడలేదు';

  @override
  String get feedbackNotSentTitle => 'పంపబడలేదు';

  @override
  String get feedbackSentBody =>
      'ధన్యవాదాలు. ప్రతి సందేశం అంతరాలూ చదివి తప్పెడని అవసరం ఉంటే బదులిస్తాం.';

  @override
  String get feedbackSentTitle => 'మార్గదర్శకం పంపబడింది';

  @override
  String get recommendUnnamedPiece => 'పేరులేని వస్తువు';

  @override
  String get recommendEnterCityBody =>
      'వాతావరణానికి అనుగుణంగా ఎంపికలు పొందడానికి మీ నగరం నమోదు చేయండి.';

  @override
  String get recommendWhichCityTitle => 'ఏ నగరం?';

  @override
  String get aiConsentSheetTitle => 'AI సేవతో ఫోటోలు పంచుకోవడం';

  @override
  String get aiConsentSheetBody =>
      'మీ ట్రై-ఆన్ మరియు ఫోటోశూట్ చిత్రాలను సృష్టించడానికి, FitCheck AI మీరు అందించే ఫోటోలను (మీ ముఖం మరియు శరీర చిత్రాలు ఇస్తాయి) ప్రాసెసింగు కోసం ఒక ఆశానికూ మూడవ పక్ష AI ప్రొవైడర్ (OpenAI లేదా Google Gemini వంటివీ) క పంపిస్తుంది. ఇవి మీ చిత్రాలను జనరేట్ చేస్తాయి మరియు మా షరతుల ప్రకారం వాటిని మోడల్లను శిక్షణకు ఉపయోగించవు. ఫోటోలు సురక్షితంగా పంపబడతాయి మరియు ప్రకటనల కోసం ఎప్పుడూ పంచుకోబడవు.';

  @override
  String get aiConsentSheetPermission =>
      'కొనసాగడం ద్వారా, చిత్ర సృష్టికి ఈ AI ప్రొవైడర్లతో మీ ఫోటోలను పంచుకోవడానికి మీరు స్పష్టమైన అనుమతి ఇస్తున్నారు.';

  @override
  String get skeletonsLoadMoreFailed => 'మరిన్ని లోడ్ అవ్వలేదు.';

  @override
  String get jobsPiecesReadyTitle => 'మీ వస్తువులు సిద్ధంగా ఉన్నాయి';

  @override
  String get jobsScanStoppedTitle => 'స్కాన్ ఆగింది';

  @override
  String get jobsNothingSavedBody => 'ఏదీ సేవ్ కాలేదు. మరొకసారి ప్రయత్నించండి.';

  @override
  String get jobsPhotoUploadFailedBody => 'ఫోటో అప్‌లోడ్ విఫలమైంది.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google Sign-In క్షేమంగా ప్రారంభించలేకపోయింది. దయచేసి మరొకసారి ప్రయత్నించండి.';

  @override
  String get referralAppliedTitle => 'రిఫరల్ వర్తించబడింది!';

  @override
  String get billingStoreUnavailableBody =>
      'ఈ డివైస్‌పై స్టోర్ కొనుగోళ్లు అందుబాటులో లేవు.';

  @override
  String get billingPurchaseProcessingBody =>
      'ఈ కొనుగోలు ఇంకా ప్రాసెస్ అవుతోంది. మీ ప్లాన్ చూడటానికి మినిట్‌లో అప్‌ను మళ్లీ తెరవండి.';

  @override
  String get profileAvatarUploadNoUrl =>
      'అవటార్ అప్‌లోడ్ ఒక చిత్ర URL ఇవ్వలేదు.';

  @override
  String get rewardsDayStreakLabel => 'రోజుల శ్రేణి';

  @override
  String rewardsBestStreak(int days) {
    return 'ఉత్తమ $days రోజులు';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission అనుమతి అవసరం';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission క అనుమతి ప్రస్తుతం నిరాహారమైంది. అనుమతించడానికి సెట్టింగ్స్ తెరిచి, తర్వాత తిరిగి వచ్చి మరొకసారి ప్రయత్నించండి.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '4 లో $stepవ దశ';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '$total లో $stepవ దశ';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '$indexవ చిత్రాన్ని తీసివేయండి';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '$indexవ చిత్రాన్ని తీసివేయండి';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points పాయింట్లు';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '$email క ఇమెయిల్ చేయండి. మేము 24 గంటల అందులో నివేదికలను అధ్యయనం చేస్తాము.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece తీసివేయండి';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '\"$name\" తొలగించాలా?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '\"$name\" కి జోడించండి';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" తీసేయబడింది. దాని వస్తువులు మీ బట్టగదిలో ఉంటాయి.';
  }

  @override
  String outfitShowAllCount(int count) {
    return '$count అన్నీ చూపించు';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'ఈరోజు $count మిగిలున్నాయి';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'ఫోటో $index విఫలమైంది';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max ఫోటోలలో $selected ఎంచుకున్నవి';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape నిర్మాణం · $tone చర్మం';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name తీసివేయాలా?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name కోసం ఎంపికలు';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'చాలా ధరించినవి: $name, $count సార్లు';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: సెట్ చేయలేదు';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% సరిపోలిక';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max లో $picked ఎంచుకున్నారు';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item తీసివేయండి';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency ప్రాధాన్యత';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'ఈ ప్లాన్ $store ద్వారా బిల్లు చేయబడుతుంది. మీ $store ఖాతా సెట్టింగ్‌లలో దీనిని మార్చుడో లేదా రద్దు చేయడో ఇక్కడండి.';
  }

  @override
  String billingManageInStore(String store) {
    return '$store లో నిర్వహించండి';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max లో $current ఉపయోగించింది';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'సుమారు $seconds సెకన్లు మిగిలి ఉన్నాయి';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total స్టూడియో ఫోటోలలో $done సిద్ధం';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total స్టూడియో ఫోటోలలో $ready సిద్ధం. స్కిప్ చేయడానికి ఒక భాగాన్ని నొక్కండి.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height సెం.మీ · $weight కి.గ్రా';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$label: $value';
  }

  @override
  String get profileFieldNotSet => 'లేదు';
}
