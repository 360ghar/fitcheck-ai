// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'હોમ';

  @override
  String get tabPhotoshoot => 'ફોટોશૂટ';

  @override
  String get tabCloset => 'કબાટ';

  @override
  String get tabOutfits => 'આઉટફિટ્સ';

  @override
  String get tabMore => 'વધુ';

  @override
  String get actionAddItem => 'વસ્તુ ઉમેરો';

  @override
  String get actionCreateOutfit => 'આઉટફિટ બનાવો';

  @override
  String get actionCancel => 'રદ કરો';

  @override
  String get actionDelete => 'ડિલીટ';

  @override
  String get actionSave => 'સેવ કરો';

  @override
  String get actionRetry => 'ફરી પ્રયાસ કરો';

  @override
  String get actionDone => 'પૂર્ણ';

  @override
  String get actionNext => 'આગળ';

  @override
  String get actionBack => 'પાછા';

  @override
  String get actionClose => 'બંધ કરો';

  @override
  String get actionSearch => 'શોધો';

  @override
  String get actionContinue => 'ચાલુ રાખો';

  @override
  String get stateLoading => 'લોડ થઈ રહ્યું છે';

  @override
  String get stateErrorTitle => 'કંઈક ખોટું થયું';

  @override
  String get stateErrorBody =>
      'ફરી પ્રયાસ કરો. જો સમસ્યા ચાલુ રહે, તો સપોર્ટનો સંપર્ક કરો.';

  @override
  String get stateOfflineTitle => 'તમે ઓફલાઇન છો';

  @override
  String get stateOfflineBody =>
      'તમારા કબાટને સિંક કરવા અને આઉટફિટ્સ બનાવવા માટે ફરી કનેક્ટ કરો.';

  @override
  String get settingsTitle => 'સેટિંગ્સ';

  @override
  String get settingsAccountSection => 'એકાઉન્ટ';

  @override
  String get settingsPreferencesSection => 'પસંદગીઓ';

  @override
  String get settingsPlanBilling => 'પ્લાન અને બિલિંગ';

  @override
  String get settingsLanguage => 'ભાષા';

  @override
  String get settingsNotifications => 'નોટિફિકેશન';

  @override
  String get settingsUnits => 'માપન એકમો';

  @override
  String get settingsAppearance => 'દેખાવ';

  @override
  String get settingsPrivacySection => 'ગોપનીયતા અને ડેટા';

  @override
  String get settingsAboutSection => 'અમારા વિશે';

  @override
  String get settingsSignOut => 'સાઇન આઉટ';

  @override
  String get settingsDeleteAccount => 'એકાઉન્ટ ડિલીટ કરો';

  @override
  String get settingsDeleteAccountTitle => 'તમારું એકાઉન્ટ ડિલીટ કરવું છે?';

  @override
  String get settingsDeleteAccountBody =>
      'આનાથી તમારું કબાટ, આઉટફિટ્સ, ફોટા અને પ્રોફાઇલ દૂર થઈ જશે. આ પ્રક્રિયા પાછી ખેંચી શકાતી નથી.';

  @override
  String get settingsUnitsImperial => 'ઇમ્પીરીયલ (in, lb)';

  @override
  String get settingsUnitsMetric => 'મેટ્રિક (cm, kg)';

  @override
  String get languageTitle => 'ભાષા';

  @override
  String get languageSystem => 'ડિવાઇસની ભાષા વાપરો';

  @override
  String get languageSystemBody => 'FitCheck AI તમારા ફોનની ભાષાને અનુસરે છે.';

  @override
  String get languageSearchHint => 'ભાષા શોધો';

  @override
  String get languageCurrent => 'વર્તમાન';

  @override
  String get languageReviewNote =>
      'આ અનુવાદ નવો છે. જો કંઈક ખોટું લાગે તો અમને જણાવો.';

  @override
  String get languageChanged => 'ભાષા અપડેટ થઈ ગઈ';

  @override
  String get paywallTitle => 'તમારો પ્લાન પસંદ કરો';

  @override
  String get paywallTrialBadge => '૧ મહિનો ફ્રી';

  @override
  String get paywallTrialTitle => 'તમારો Pro નો પહેલો મહિનો ફ્રી';

  @override
  String get paywallTrialBody =>
      'તમારું આખું કબાટ એકસાથે અપલોડ કરો. ત્યારબાદ જરૂર મુજબ નવા કપડાં ઉમેરો.';

  @override
  String get paywallFreeForeverTitle => 'હંમેશા ફ્રી';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'કોઈ કાર્ડની જરૂર નથી. દર મહિને તમને $uploads AI અપલોડ્સ, $outfits આઉટફિટ્સ અને $images ફોટોશૂટ ઈમેજીસ દરરોજ મળે છે.';
  }

  @override
  String get paywallCtaTrial => 'મારો ફ્રી મહિનો શરૂ કરો';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan માં અપગ્રેડ કરો';
  }

  @override
  String get paywallRestore => 'ખરીદી રિસ્ટોર કરો';

  @override
  String get paywallManage => 'સબ્સ્ક્રિપ્શન મેનેજ કરો';

  @override
  String get paywallTerms => 'ઉપયોગની શરતો';

  @override
  String get paywallPrivacy => 'ગોપનીયતા નીતિ';

  @override
  String get paywallPerMonth => 'દર મહિને';

  @override
  String get paywallPerYear => 'દર વર્ષે';

  @override
  String get paywallBestValue => 'શ્રેષ્ઠ મૂલ્ય';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'ફ્રી ટ્રાયલ ફક્ત નવા સબ્સ્ક્રાઇબર્સ માટે. ટ્રાયલ પછી, Pro $price પર રિન્યૂ થશે, સિવાય કે તે સમાપ્ત થવાના ઓછામાં ઓછા 24 કલાક પહેલાં રદ કરવામાં આવે.';
  }

  @override
  String get introTitle => 'તમારું કબાટ, આખરે વ્યવસ્થિત';

  @override
  String get introBody =>
      'તમારા કપડાંના ફોટા લો. તમારી પાસે પહેલેથી જ છે તેમાંથી આઉટફિટ આઈડિયા, ટ્રાય-ઓન પ્રિવ્યૂ અને સ્ટુડિયો ફોટા મેળવો.';

  @override
  String get introStart => 'શરૂ કરો';

  @override
  String get introHaveAccount => 'મારી પાસે પહેલેથી એકાઉન્ટ છે';

  @override
  String get introSkip => 'સ્કીપ કરો';

  @override
  String get authSignIn => 'સાઇન ઇન';

  @override
  String get authSignUp => 'એકાઉન્ટ બનાવો';

  @override
  String get authEmail => 'ઈમેલ';

  @override
  String get authPassword => 'પાસવર્ડ';

  @override
  String get authForgotPassword => 'પાસવર્ડ ભૂલી ગયા છો?';

  @override
  String get authContinueApple => 'Apple સાથે ચાલુ રાખો';

  @override
  String get authContinueGoogle => 'Google સાથે ચાલુ રાખો';

  @override
  String get authOrDivider => 'અથવા';

  @override
  String get wardrobeTitle => 'કબાટ';

  @override
  String get wardrobeEmptyTitle => 'તમારું કબાટ ખાલી છે';

  @override
  String get wardrobeEmptyBody =>
      'તમારી પ્રથમ વસ્તુ ઉમેરો, અથવા આખા રેકનો ફોટો અપલોડ કરો.';

  @override
  String get wardrobeAddFirst => 'પ્રથમ વસ્તુ ઉમેરો';

  @override
  String get wardrobeSearchHint => 'તમારા કબાટમાં શોધો';

  @override
  String get categoryTops => 'ટોપ્સ';

  @override
  String get categoryBottoms => 'બોટમ્સ';

  @override
  String get categoryShoes => 'શૂઝ';

  @override
  String get categoryAccessories => 'એસેસરીઝ';

  @override
  String get categoryOuterwear => 'આઉટરવેર';

  @override
  String get categorySwimwear => 'સ્વિમવેર';

  @override
  String get categoryActivewear => 'એક્ટિવવેર';

  @override
  String get categoryOther => 'અન્ય';

  @override
  String get conditionClean => 'સ્વચ્છ';

  @override
  String get conditionDirty => 'ગંદા';

  @override
  String get conditionLaundry => 'લોન્ડ્રીમાં';

  @override
  String get conditionRepair => 'રિપેરિંગની જરૂર';

  @override
  String get conditionDonate => 'દાન કરવા માટે';

  @override
  String get seasonSpring => 'વસંત';

  @override
  String get seasonSummer => 'ઉનાળો';

  @override
  String get seasonFall => 'પાનખર';

  @override
  String get seasonWinter => 'શિયાળો';

  @override
  String get seasonAll => 'બધી ઋતુ';

  @override
  String get styleCasual => 'કેઝ્યુઅલ';

  @override
  String get styleFormal => 'ફોર્મલ';

  @override
  String get styleBusiness => 'બિઝનેસ';

  @override
  String get styleSporty => 'સ્પોર્ટી';

  @override
  String get styleBohemian => 'બોહેમિયન';

  @override
  String get styleStreetwear => 'સ્ટ્રીટવેર';

  @override
  String get styleVintage => 'વિન્ટેજ';

  @override
  String get styleMinimalist => 'મિનિમલિસ્ટ';

  @override
  String get styleRomantic => 'રોમેન્ટિક';

  @override
  String get styleEdgy => 'એજી';

  @override
  String get stylePreppy => 'પ્રેપી';

  @override
  String get styleArtsy => 'આર્ટસી';

  @override
  String get styleClassic => 'ક્લાસિક';

  @override
  String get styleElegant => 'એલિગન્ટ';

  @override
  String get styleOther => 'અન્ય';

  @override
  String get occasionWork => 'કામ';

  @override
  String get occasionDateNight => 'ડેટ નાઈટ';

  @override
  String get occasionTravel => 'મુસાફરી';

  @override
  String get occasionWedding => 'લગ્ન';

  @override
  String get occasionGym => 'જિમ';

  @override
  String get occasionWeekend => 'વીકેન્ડ';

  @override
  String get occasionParty => 'પાર્ટી';

  @override
  String get occasionInterview => 'ઇન્ટરવ્યુ';

  @override
  String get colorBlack => 'કાળો';

  @override
  String get colorWhite => 'સફેદ';

  @override
  String get colorGrey => 'ગ્રે';

  @override
  String get colorNavy => 'નેવી';

  @override
  String get colorBrown => 'બ્રાઉન';

  @override
  String get colorRed => 'લાલ';

  @override
  String get colorBlue => 'વાદળી';

  @override
  String get colorGreen => 'લીલો';

  @override
  String get colorPink => 'ગુલાબી';

  @override
  String get colorPurple => 'જાંબલી';

  @override
  String get colorYellow => 'પીળો';

  @override
  String get colorOrange => 'નારંગી';

  @override
  String get colorBeige => 'બીજ';

  @override
  String get dateToday => 'આજે';

  @override
  String get dateYesterday => 'ગઈકાલે';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ પહેલા',
      one: '૧ દિવસ પહેલા',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count અઠવાડિયા પહેલા',
      one: '૧ અઠવાડિયું પહેલા',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count મહિના પહેલા',
      one: '૧ મહિનો પહેલા',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count વર્ષ પહેલા',
      one: '૧ વર્ષ પહેલા',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI ગમે છે?';

  @override
  String get ratingPromptBody =>
      'એક રેટિંગ અન્ય લોકોને તેમની સ્ટાઇલ શોધવામાં મદદ કરે છે.';

  @override
  String get ratingPromptYes => 'રેટ કરો';

  @override
  String get ratingPromptNo => 'અત્યારે નહીં';

  @override
  String get closetNoMatchesTitle => 'કોઈ પીસ મળ્યા નથી';

  @override
  String get closetNoMatchesBody => 'ફિલ્ટર ઘટાડો અથવા બીજું કંઈક શોધો.';

  @override
  String get closetClearFilters => 'ફિલ્ટર દૂર કરો';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પીસ',
      one: '૧ પીસ',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'તમારા પીસ લોડ થઈ રહ્યા છે';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પસંદ કર્યા',
      one: '૧ પસંદ કર્યું',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'પસંદ કરેલ ડિલીટ કરો';

  @override
  String get closetCancelSelection => 'પસંદગી રદ કરો';

  @override
  String get closetCloseSearch => 'સર્ચ બંધ કરો';

  @override
  String get closetShowGrid => 'ગ્રીડમાં જુઓ';

  @override
  String get closetShowList => 'લિસ્ટમાં જુઓ';

  @override
  String get closetShowRows => 'રોમાં જુઓ';

  @override
  String get closetStatsTitle => 'કબાટના આંકડા';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પીસ ડિલીટ કરવા છે?',
      one: '૧ પીસ ડિલીટ કરવો છે?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'જે આઉટફિટમાં આનો ઉપયોગ થયો છે તેમાંથી આ પીસ નીકળી જશે.';

  @override
  String get closetSortBy => 'ક્રમમાં ગોઠવો';

  @override
  String get closetFavourites => 'મનપસંદ';

  @override
  String get closetFavourite => 'મનપસંદમાં ઉમેરો';

  @override
  String get closetUnfavourite => 'મનપસંદમાંથી દૂર કરો';

  @override
  String get closetWoreToday => 'આજે પહેર્યું';

  @override
  String closetWornTimes(int count) {
    return '$count× પહેર્યું';
  }

  @override
  String get closetCategoryLabel => 'કેટેગરી';

  @override
  String get closetUseCaseLabel => 'ઉપયોગ';

  @override
  String get closetAnyUseCase => 'કોઈપણ';

  @override
  String get closetOtherUseCase => 'અન્ય ઉપયોગ';

  @override
  String get closetOtherUseCaseHint => 'દા.ત. બ્રંચ';

  @override
  String get closetUseUseCase => 'આ વાપરો';

  @override
  String get closetClearAll => 'બધું સાફ કરો';

  @override
  String get sortNewest => 'સૌથી નવા પહેલા';

  @override
  String get sortOldest => 'સૌથી જૂના પહેલા';

  @override
  String get sortName => 'નામ (A–Z)';

  @override
  String get sortMostWorn => 'સૌથી વધુ પહેરેલા';

  @override
  String get useCaseInformal => 'કેઝ્યુઅલ';

  @override
  String get useCaseDate => 'ડેટ';

  @override
  String get useCaseDinner => 'ડિનર';

  @override
  String get useCaseLunch => 'લંચ';

  @override
  String get actionSelect => 'પસંદ કરો';

  @override
  String get actionEdit => 'ફેરફાર કરો';

  @override
  String get actionFilter => 'ફિલ્ટર';

  @override
  String get actionSort => 'ક્રમ';

  @override
  String get actionAll => 'બધા';

  @override
  String get dashboardStartClosetTitle => 'તમારું કબાટ શરૂ કરો';

  @override
  String get dashboardStartClosetBody =>
      'થોડા કપડાંના ફોટા પાડો. અમે તેને ટેગ કરીશું.';

  @override
  String get dashboardPieces => 'પીસ';

  @override
  String get dashboardOutfits => 'આઉટફિટ્સ';

  @override
  String get dashboardDayStreak => 'દિવસની સ્ટ્રીક';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'આ મહિને +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'શ્રેષ્ઠ $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count મનપસંદ',
      one: '1 મનપસંદ',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count સેવ કરેલ આઉટફિટ્સ',
      one: '1 સેવ કરેલ આઉટફિટ',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'સૌથી વધુ પહેરેલ: $name, $count વાર';
  }

  @override
  String get setupSkip => 'સેટઅપ છોડો';

  @override
  String get setupWhoTitle => 'અમે કોને સ્ટાઇલ કરી રહ્યા છીએ?';

  @override
  String get setupWhoBody =>
      'ટ્રાય-ઓન અને ફોટોશૂટ માટે મોડેલ સેટ કરો. તમે પ્રોફાઇલમાં બદલી શકો છો.';

  @override
  String get setupStyleTitle => 'તમે શું સૌથી વધુ પહેરો છો?';

  @override
  String get setupStyleBody =>
      'કોઈપણ પસંદ કરો. આઉટફિટના વિચારો અહીંથી શરૂ થાય છે.';

  @override
  String get setupClosetTitle => 'તમારા પ્રથમ કપડાં ઉમેરો.';

  @override
  String get setupClosetBody =>
      'થોડા કપડાંના ફોટા પાડો. દરેક પીસ અલગ કરીને તમારા માટે ફાઇલ કરવામાં આવશે.';

  @override
  String get setupAddClothes => 'કપડાં ઉમેરો';

  @override
  String get setupStylesLabel => 'સ્ટાઇલ્સ';

  @override
  String get setupOccasionsLabel => 'પ્રસંગો';

  @override
  String get setupSkipStep => 'છોડો';

  @override
  String get setupLater => 'પછી';

  @override
  String get setupSaveError => 'સેવ કરી શકાયું નથી';

  @override
  String get genderWomen => 'મહિલા';

  @override
  String get genderMen => 'પુરુષ';

  @override
  String get genderNonBinary => 'નોન-બાઈનરી';

  @override
  String get genderPreferNotToSay => 'કહેવાનું પસંદ નથી';

  @override
  String get outfitEmptyTitle => 'હજુ સુધી કોઈ આઉટફિટ નથી';

  @override
  String get outfitEmptyBody => 'તમારા કબાટમાંથી કપડાં જોડો અને લુક સેવ કરો.';

  @override
  String get outfitNoMatchesTitle => 'કોઈ આઉટફિટ મળતું નથી';

  @override
  String get outfitSearchHint => 'તમારા આઉટફિટ શોધો';

  @override
  String get outfitLoading => 'તમારા આઉટફિટ લોડ થઈ રહ્યા છે';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count આઉટફિટ',
      one: '1 આઉટફિટ',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'સ્ટાઈલ અને સીઝન';

  @override
  String get outfitCollections => 'કલેક્શન';

  @override
  String get outfitDuplicate => 'ડુપ્લિકેટ';

  @override
  String get outfitDeleteTitle => 'આ આઉટફિટ ડિલીટ કરવું છે?';

  @override
  String get outfitDeleteBody => 'તેના કપડાં તમારા કબાટમાં રહેશે.';

  @override
  String get outfitDrafts => 'ડ્રાફ્ટ્સ';

  @override
  String get outfitDraft => 'ડ્રાફ્ટ';

  @override
  String get filterStyle => 'સ્ટાઈલ';

  @override
  String get filterSeason => 'સીઝન';

  @override
  String get itemDetailDeleteTitle => 'આ આઈટમ ડિલીટ કરવી છે?';

  @override
  String get itemDetailDeleteBody =>
      'જે આઉટફિટમાં આ વપરાયું છે તેમાંથી તે નીકળી જશે.';

  @override
  String get itemAddFavourite => 'ફેવરિટમાં ઉમેરો';

  @override
  String itemSize(String size) {
    return 'સાઈઝ $size';
  }

  @override
  String get itemColours => 'રંગો';

  @override
  String get itemMaterial => 'મટીરીયલ';

  @override
  String get itemPattern => 'પેટર્ન';

  @override
  String get itemUseCases => 'ઉપયોગ';

  @override
  String get itemKeptIn => 'ક્યાં રાખ્યું છે';

  @override
  String get itemPrice => 'કિંમત';

  @override
  String get itemBought => 'ખરીદેલું';

  @override
  String get itemTags => 'ટેગ્સ';

  @override
  String get itemAdded => 'ઉમેર્યું';

  @override
  String get itemTimesWornLabel => 'પહેર્યાની સંખ્યા';

  @override
  String get itemLastWornLabel => 'છેલ્લે પહેર્યું';

  @override
  String get itemNeverWorn => 'ક્યારેય નહીં';

  @override
  String get authEntryBody =>
      'તમારા દરેક કપડાં, FitCheck AI દ્વારા સ્ટાઈલ કરો. આઉટફિટ પ્લાન કરો, ટ્રાય કરો અને ફોટો લો.';

  @override
  String get authCreateCloset => 'તમારું કબાટ બનાવો';

  @override
  String get authWelcomeBack => 'ફરી સ્વાગત છે';

  @override
  String get authSignInBody => 'તમારું કબાટ ખોલવા માટે સાઇન ઇન કરો.';

  @override
  String get authCreateAccount => 'એકાઉન્ટ બનાવો';

  @override
  String get authCreateClosetBody =>
      'માત્ર એક મિનિટ લાગશે. તમારી પ્રથમ વસ્તુઓ મફત છે.';

  @override
  String get authName => 'નામ';

  @override
  String get authConfirmPassword => 'પાસવર્ડ કન્ફર્મ કરો';

  @override
  String get authReferralCode => 'રેફરલ કોડ (વૈકલ્પિક)';

  @override
  String get authResetTitle => 'પાસવર્ડ રીસેટ કરો';

  @override
  String get authResetBody =>
      'નવો પાસવર્ડ સેટ કરવા માટે અમે તમને ઇમેઇલ મોકલીશું.';

  @override
  String get authSendResetLink => 'રીસેટ લિંક મોકલો';

  @override
  String get authBackToSignIn => 'સાઇન ઇન પર પાછા જાઓ';

  @override
  String get authEnterEmail => 'તમારો ઇમેઇલ દાખલ કરો';

  @override
  String get authEnterValidEmail => 'સાચો ઇમેઇલ દાખલ કરો';

  @override
  String get authEnterPassword => 'તમારો પાસવર્ડ દાખલ કરો';

  @override
  String get authPasswordTooShort => 'ઓછામાં ઓછા 6 અક્ષરો';

  @override
  String get authShowPassword => 'પાસવર્ડ બતાવો';

  @override
  String get authHidePassword => 'પાસવર્ડ છુપાવો';

  @override
  String get authNewHere => 'નવા છો?';

  @override
  String authConfirmEmail(String email) {
    return 'સાઇન ઇન કરતા પહેલા $email કન્ફર્મ કરો. તમારું ઇનબોક્સ તપાસો.';
  }

  @override
  String get authResendEmail => 'ફરીથી મોકલો';

  @override
  String get authResendingEmail => 'મોકલી રહ્યા છીએ...';

  @override
  String get authPasswordsDoNotMatch => 'પાસવર્ડ મેળ ખાતા નથી';

  @override
  String get authEnterName => 'તમારું નામ દાખલ કરો';

  @override
  String get authChoosePassword => 'પાસવર્ડ પસંદ કરો';

  @override
  String get authHaveAccount => 'એકાઉન્ટ છે?';

  @override
  String get authCodeAccepted => 'કોડ સ્વીકારાયો';

  @override
  String get authCodeNotFound => 'કોડ મળ્યો નથી';

  @override
  String authReferralFrom(String name) {
    return '$name તરફથી. તમને બંનેને એક મહિનો મફત મળશે.';
  }

  @override
  String get authReferralInvalid => 'અમને આ કોડ મળ્યો નથી.';

  @override
  String authResetSent(String email) {
    return '$email પર મોકલી દીધું છે. આ ફોન પર લિંક ખોલો.';
  }

  @override
  String get introSlide1Title => 'તમારા કબાટનો ફોટો લો.';

  @override
  String get introSlide1Body =>
      'કપડાંના ઢગલાનો ફોટો પાડો. દરેક ટુકડો આપમેળે અલગ થઈ જશે.';

  @override
  String get introSlide2Title => 'ઝડપથી તૈયાર થાઓ.';

  @override
  String get introSlide2Body =>
      'તમારા કપડાંમાંથી આઉટફિટ્સ, જે તમારા પ્લાન અને હવામાન મુજબ હોય.';

  @override
  String get introSlide3Title => 'પહેરતા પહેલા જુઓ.';

  @override
  String get introSlide3Body =>
      'તમારા ફોટા પર લુક ટ્રાય કરો, અથવા કેમ્પેઈન જેવો ફોટો શૂટ કરો.';

  @override
  String get settingsTheme => 'થીમ';

  @override
  String get settingsThemeSystem => 'સિસ્ટમ';

  @override
  String get settingsThemeLight => 'લાઇટ';

  @override
  String get settingsThemeDark => 'ડાર્ક';

  @override
  String get settingsTemperature => 'તાપમાન';

  @override
  String get settingsEmailUpdates => 'ઈમેલ અપડેટ્સ';

  @override
  String get settingsEmailUpdatesBody => 'ઈમેલ દ્વારા સમાચાર અને ટિપ્સ';

  @override
  String get settingsOutfitReminders => 'આઉટફિટ રિમાઇન્ડર્સ';

  @override
  String get settingsOutfitRemindersBody =>
      'તમે શું પહેર્યું તે નોંધવા માટે રિમાઇન્ડર';

  @override
  String get settingsWeeklySummary => 'સાપ્તાહિક સારાંશ';

  @override
  String get settingsWeeklySummaryBody => 'તમારા અઠવાડિયાના આઉટફિટ્સ';

  @override
  String get settingsStyleSection => 'સ્ટાઇલ';

  @override
  String get settingsPreferredStyles => 'તમને ગમતી સ્ટાઇલ';

  @override
  String get settingsPreferredColours => 'તમને ગમતા રંગો';

  @override
  String get settingsNoneChosen => 'કંઈ પસંદ કર્યું નથી';

  @override
  String get settingsPlanAiSection => 'પ્લાન અને AI';

  @override
  String get settingsPlanBillingBody => 'પ્લાન, વપરાશ અને અપગ્રેડ';

  @override
  String get settingsPlanUsageBody => 'પ્લાન અને વપરાશ';

  @override
  String get settingsInviteFriends => 'મિત્રોને આમંત્રિત કરો';

  @override
  String get settingsInviteFriendsBody =>
      'દરેક જોડાનાર મિત્ર માટે એક મહિનો મફત';

  @override
  String get settingsAiProvider => 'AI પ્રોવાઈડર';

  @override
  String get settingsAiProviderBody =>
      'ટેગિંગ અને ઈમેજ માટે તમારા પોતાના મોડેલનો ઉપયોગ કરો';

  @override
  String get settingsAppVersion => 'એપ વર્ઝન';

  @override
  String get settingsPrivacyTerms => 'પ્રાઈવસી અને શરતો';

  @override
  String get settingsReportProblem => 'સમસ્યાની જાણ કરો';

  @override
  String get settingsChangePassword => 'પાસવર્ડ બદલો';

  @override
  String get settingsExportData => 'તમારો ડેટા એક્સપોર્ટ કરો';

  @override
  String get settingsExportBody =>
      'અમે તમારી સેવ કરેલી તમામ વિગતો સાથે એક ફાઈલ તૈયાર કરીશું અને ડાઉનલોડ ખોલીશું.';

  @override
  String get settingsExportAction => 'એક્સપોર્ટ';

  @override
  String get settingsCurrentPassword => 'વર્તમાન પાસવર્ડ';

  @override
  String get settingsNewPassword => 'નવો પાસવર્ડ';

  @override
  String get settingsConfirmNewPassword => 'નવો પાસવર્ડ કન્ફર્મ કરો';

  @override
  String get settingsEnterCurrentPassword => 'તમારો વર્તમાન પાસવર્ડ દાખલ કરો';

  @override
  String get settingsEnterNewPassword => 'નવો પાસવર્ડ દાખલ કરો';

  @override
  String get settingsPasswordMin8 => 'ઓછામાં ઓછા 8 અક્ષરો વાપરો';

  @override
  String get settingsPasswordNeedsUpper => 'એક કેપિટલ અક્ષર ઉમેરો';

  @override
  String get settingsPasswordNeedsLower => 'એક સ્મોલ અક્ષર ઉમેરો';

  @override
  String get settingsPasswordNeedsDigit => 'એક આંકડો ઉમેરો';

  @override
  String get settingsPasswordsNoMatch => 'પાસવર્ડ મેચ થતા નથી';

  @override
  String get settingsChangeAction => 'બદલો';

  @override
  String get itemAddSnapTitle => 'ફોટો પાડો';

  @override
  String get itemAddSnapBody =>
      'અમે ફોટામાંથી દરેક વસ્તુ શોધીશું અને દરેકનો ક્લીન સ્ટુડિયો શોટ બનાવીશું.';

  @override
  String get itemAddCamera => 'ફોટો પાડો';

  @override
  String get itemAddGallery => 'ગેલેરીમાંથી પસંદ કરો';

  @override
  String get itemAddOtherWays => 'ઉમેરવાની અન્ય રીતો';

  @override
  String get itemAddSeveral => 'ઘણા ફોટા ઉમેરો';

  @override
  String get itemAddSeveralBody => 'એકસાથે 50 સુધી';

  @override
  String get itemAddImportProfile => 'પ્રોફાઈલમાંથી ઈમ્પોર્ટ કરો';

  @override
  String get itemAddImportProfileBody => 'Instagram અથવા Facebook';

  @override
  String get itemAddEnterDetails => 'વિગતો જાતે દાખલ કરો';

  @override
  String get itemAddEnterDetailsBody => 'ફોટાની જરૂર નથી';

  @override
  String get itemManualIntro =>
      'માત્ર નામ જરૂરી છે. બાકીની વિગતો અત્યારે અથવા પછી ઉમેરો.';

  @override
  String get itemManualNameHint => 'દાખલા તરીકે, વાદળી કોટન ટી-શર્ટ';

  @override
  String get itemManualEnterName => 'નામ દાખલ કરો';

  @override
  String get itemManualNotes => 'નોંધ';

  @override
  String get itemManualBrand => 'બ્રાન્ડ';

  @override
  String get itemManualSize => 'કદ';

  @override
  String get itemManualEnterNumber => 'નંબર દાખલ કરો';

  @override
  String get itemManualSavePiece => 'પીસ સેવ કરો';

  @override
  String get itemManualSaving => 'સેવ થઈ રહ્યું છે';

  @override
  String get itemManualSavedTitle => 'સેવ કર્યું';

  @override
  String itemManualSavedBody(String name) {
    return '$name તમારા કબાટમાં છે.';
  }

  @override
  String get itemManualNotSaved => 'સેવ થયું નથી';

  @override
  String get itemManualAddUseCase => 'ઉપયોગ ઉમેરો';

  @override
  String get itemManualAddUseCaseAction => 'ઉપયોગ ઉમેરો';

  @override
  String get itemPhotos => 'ફોટા';

  @override
  String get itemAddPhotos => 'ફોટા ઉમેરો';

  @override
  String get itemNoPhotoYet =>
      'હજુ સુધી કોઈ ફોટો નથી. તમે તેના વગર પણ સેવ કરી શકો છો.';

  @override
  String get itemRemovePhoto => 'ફોટો દૂર કરો';

  @override
  String get itemRemovePiece => 'પીસ દૂર કરો';

  @override
  String get filterConditionLabel => 'સ્થિતિ';

  @override
  String get photoshootStepPhotos => 'ફોટા';

  @override
  String get photoshootStepSetup => 'સેટઅપ';

  @override
  String get photoshootStepCreating => 'બનાવી રહ્યા છીએ';

  @override
  String get photoshootStepResults => 'પરિણામો';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'સ્ટેપ $current ઓફ $total, $name';
  }

  @override
  String get photoshootOneFailed => 'એક ફોટો નિષ્ફળ ગયો. નીચે ફરી પ્રયાસ કરો.';

  @override
  String photoshootManyFailed(int count) {
    return '$count ફોટા નિષ્ફળ ગયા. દરેક માટે નીચે ફરી પ્રયાસ કરો.';
  }

  @override
  String get photoshootFormat => 'ફોર્મેટ';

  @override
  String get photoshootHowMany => 'કેટલા';

  @override
  String get photoshootYourPrompt => 'તમારી પ્રોમ્પ્ટ';

  @override
  String get photoshootPromptHint => 'રૂફટોપ પર ગોલ્ડન અવર, લિનન શર્ટ';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફોટા બનાવો',
      one: '૧ ફોટો બનાવો',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ફોટા',
      one: 'ફોટો',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'અમે આજની મર્યાદા તપાસી શક્યા નથી.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan પ્લાન: આજે $remaining માંથી $limit બાકી';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'ફ્રી';

  @override
  String get photoshootGallery => 'ગેલેરી';

  @override
  String get photoshootUseCamera => 'કેમેરા વાપરો';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'ફોટો $number દૂર કરો';
  }

  @override
  String get photoshootNoPhotosTitle => 'કોઈ ફોટા મળ્યા નથી';

  @override
  String get photoshootNoPhotosBody =>
      'શૂટ ઈમેજ વગર પૂર્ણ થયું. ફરી પ્રયાસ કરો.';

  @override
  String get photoshootNewStyle => 'નવી સ્ટાઈલ';

  @override
  String get photoshootNewPhotos => 'નવા ફોટા';

  @override
  String photoshootOpenPhoto(int number) {
    return 'ફોટો $number ખોલો';
  }

  @override
  String get photoshootReportPhoto => 'ફોટો રિપોર્ટ કરો';

  @override
  String get photoshootSaveToGallery => 'ગેલેરીમાં સેવ કરો';

  @override
  String get actionUpgrade => 'અપગ્રેડ';

  @override
  String get referralLimitTitle => 'તમે આજના ફોટા વાપરી લીધા છે';

  @override
  String get referralLimitBody =>
      'તમારા ફ્રી ફોટા આવતીકાલે પાછા આવશે. મિત્રને રેફર કરો અને બંનેને એક મહિના માટે Pro ફ્રી મળશે.';

  @override
  String get referralLimitRefer => 'મિત્રને રેફર કરો';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'ડેટિંગ એપ';

  @override
  String get photoshootUsePortfolio => 'પોર્ટફોલિયો';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'એસ્થેટિક';

  @override
  String get photoshootUseCustom => 'તમારી પોતાની પ્રોમ્પ્ટ';

  @override
  String get photoshootDescLinkedin => 'કામ માટે પ્રોફેશનલ હેડશોટ્સ';

  @override
  String get photoshootDescDating => 'રિલેક્સ્ડ, હૂંફાળું અને કુદરતી';

  @override
  String get photoshootDescPortfolio => 'એડિટોરિયલ, હાઈ-ફેશન લુક્સ';

  @override
  String get photoshootDescInstagram => 'તમારા ફીડ માટે લાઈફસ્ટાઈલ ફોટા';

  @override
  String get photoshootDescAesthetic => 'મૂડી, આર્ટિસ્ટિક ફ્રેમ્સ';

  @override
  String get photoshootDescCustom => 'તમને જોઈતો લુક વર્ણવો';

  @override
  String get aspectSquare => 'ચોરસ';

  @override
  String get aspectPortrait => 'પોર્ટ્રેટ';

  @override
  String get aspectLandscape => 'લેન્ડસ્કેપ';

  @override
  String get aspectTall => 'લાંબુ';

  @override
  String get aspectWide => 'પહોળું';

  @override
  String get tryOnAppBar => 'વર્ચ્યુઅલ ટ્રાય-ઓન';

  @override
  String get tryOnYourPhoto => 'તમારો ફોટો';

  @override
  String get tryOnGarment => 'કપડું';

  @override
  String get tryOnUploadingPhoto => 'તમારો ફોટો અપલોડ થઈ રહ્યો છે';

  @override
  String get tryOnAddPhotoPrompt => 'તમારો આખા શરીરનો ફોટો ઉમેરો';

  @override
  String get tryOnBodyPhotoHint => 'આખા શરીરનો ફોટો શ્રેષ્ઠ કામ કરે છે';

  @override
  String get tryOnAddPhoto => 'ફોટો ઉમેરો';

  @override
  String get tryOnChangePhoto => 'ફોટો બદલો';

  @override
  String get tryOnPhotoLoadFailed => 'અમે તમારો ફોટો લોડ કરી શક્યા નથી.';

  @override
  String get tryOnChooseGarment => 'કપડાનો ફોટો પસંદ કરો';

  @override
  String get tryOnChooseOneGarment => 'એક કપડાનો ફોટો પસંદ કરો';

  @override
  String get tryOnGarmentHint =>
      'ફ્લેટ લે અથવા હેંગર પરનો ફોટો શ્રેષ્ઠ કામ કરે છે';

  @override
  String get tryOnChange => 'બદલો';

  @override
  String get tryOnCamera => 'કેમેરા';

  @override
  String get tryOnRemove => 'દૂર કરો';

  @override
  String get tryOnLookTitle => 'લુક';

  @override
  String get tryOnStyle => 'સ્ટાઈલ';

  @override
  String get tryOnBackground => 'બેકગ્રાઉન્ડ';

  @override
  String get tryOnPose => 'પોઝ';

  @override
  String get tryOnDressingUp =>
      'તમને તૈયાર કરી રહ્યા છીએ. આમાં અડધી મિનિટ જેવો સમય લાગશે.';

  @override
  String get tryOnEmptyResult => 'તમારું ટ્રાય-ઓન અહીં દેખાશે';

  @override
  String get tryOnReportImage => 'ઇમેજ રિપોર્ટ કરો';

  @override
  String get tryOnCreating => 'બની રહ્યું છે';

  @override
  String get tryOnTryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get tryOnCreate => 'ટ્રાય-ઓન બનાવો';

  @override
  String get tryOnBackgroundStudioWhite => 'સ્ટુડિયો વ્હાઇટ';

  @override
  String get tryOnBackgroundStudioGrey => 'સ્ટુડિયો ગ્રે';

  @override
  String get tryOnBackgroundUrban => 'અર્બન સ્ટ્રીટ';

  @override
  String get tryOnBackgroundNature => 'નેચર';

  @override
  String get tryOnBackgroundMinimal => 'મિનિમલ';

  @override
  String get tryOnPoseFront => 'સીધા ઉભા';

  @override
  String get tryOnPoseSide => 'બાજુમાં ઉભા';

  @override
  String get tryOnPoseWalking => 'ચાલતા';

  @override
  String get dashboardGreetingMorning => 'શુભ સવાર';

  @override
  String get dashboardGreetingAfternoon => 'શુભ બપોર';

  @override
  String get dashboardGreetingEvening => 'શુભ સાંજ';

  @override
  String get dashboardWelcome => 'સ્વાગત છે';

  @override
  String get dashboardOpenProfile => 'પ્રોફાઇલ ખોલો';

  @override
  String get dashboardRailToday => 'આજે';

  @override
  String get dashboardRailRecently => 'તાજેતરમાં';

  @override
  String get dashboardActivityEmpty => 'નવા કપડાં અને આઉટફિટ્સ અહીં દેખાશે.';

  @override
  String get quickAddPiece => 'કપડું ઉમેરો';

  @override
  String get quickAddPieceBody => 'ફોટો પાડો અને ટેગ કરો';

  @override
  String get quickBuildOutfit => 'આઉટફિટ બનાવો';

  @override
  String get quickBuildOutfitBody => 'તમારા કપડાં મિક્સ કરો';

  @override
  String get quickForYou => 'તમારા માટે';

  @override
  String get quickForYouBody => 'આજના માટે ખાસ';

  @override
  String get quickPlanWeek => 'અઠવાડિયું પ્લાન કરો';

  @override
  String get quickPlanWeekBody => 'તારીખ મુજબ આઉટફિટ્સ';

  @override
  String get referralBannerUrgent => 'મર્યાદિત છે? મિત્રને આમંત્રિત કરો.';

  @override
  String get referralBannerTitle => 'એક મહિનો આપો, એક મહિનો મેળવો.';

  @override
  String get referralBannerBody =>
      'તમે અને તમારા મિત્ર બંનેને Pro નો એક મહિનો મળે છે.';

  @override
  String get referralBannerDismiss => 'એક અઠવાડિયા માટે હટાવો';

  @override
  String get referralBannerShare => 'આમંત્રણ શેર કરો';

  @override
  String get referralBannerCopy => 'લિંક કોપી કરો';

  @override
  String get itemEditPieceTitle => 'પીસ એડિટ કરો';

  @override
  String get itemEditDescriptionLabel => 'વર્ણન';

  @override
  String get itemEditNotSaved => 'સેવ થયું નથી';

  @override
  String get itemEditSavedTitle => 'સેવ થયું';

  @override
  String get itemEditSavedBody => 'તમારા ફેરફારો સેવ થઈ ગયા છે.';

  @override
  String get itemEditSavedStalePhotos => 'સેવ થયું — ફોટા જૂના હોઈ શકે છે';

  @override
  String get itemEditRemovePieceHint => 'આ પીસને આઈટમ પેજ પરથી ડિલીટ કરો.';

  @override
  String get itemEditNoPhotos =>
      'હજુ કોઈ ફોટા નથી. ગેલેરી અથવા કેમેરામાંથી ઉમેરો.';

  @override
  String get itemEditKeepPhoto => 'ફોટો રાખો';

  @override
  String get itemEditRemoved => 'દૂર કર્યું';

  @override
  String get itemEditAddUseCaseAction => 'ઉમેરો';

  @override
  String get statsNoStatsTitle => 'હજુ કોઈ આંકડા નથી';

  @override
  String get statsNoStatsBody =>
      'થોડા પીસ ઉમેરો અને તમારું કબાટ મિશ્રણ અહીં દેખાશે.';

  @override
  String get statsByCategory => 'કેટેગરી મુજબ';

  @override
  String get statsTotalValue => 'કુલ કિંમત';

  @override
  String get statsMostWorn => 'સૌથી વધુ પહેરાયેલું';

  @override
  String get statsLeastWorn => 'તકની રાહ જોતું';

  @override
  String get statsUnnamedPiece => 'અનામી પીસ';

  @override
  String get jobsTitle => 'સ્કેન';

  @override
  String get jobsEmptyTitle => 'હજુ કોઈ સ્કેન નથી';

  @override
  String get jobsEmptyBody =>
      'એક પીસનો ફોટો લો અને તેને બેકગ્રાઉન્ડમાં મોકલો — તે અહીં કામ કરવાનું ચાલુ રાખશે.';

  @override
  String get jobsNotCancelled => 'કેન્સલ થયું નથી';

  @override
  String get jobsResume => 'ફરી શરૂ કરો';

  @override
  String get jobsReview => 'રિવ્યુ કરો';

  @override
  String get jobsStop => 'બંધ કરો';

  @override
  String get jobsDismiss => 'રદ કરો';

  @override
  String get reportTitle => 'કન્ટેન્ટ રિપોર્ટ કરો';

  @override
  String reportIntro(String contentType) {
    return 'આ $contentType માં શું સમસ્યા છે તે અમને જણાવો. અમારી ટીમ દરેક રિપોર્ટની સમીક્ષા કરે છે.';
  }

  @override
  String get reportReasonInappropriate => 'અયોગ્ય અથવા અપમાનજનક';

  @override
  String get reportReasonNudity => 'નગ્નતા અથવા જાતીય સામગ્રી';

  @override
  String get reportReasonHarassment => 'હેરાનગતિ અથવા દુરુપયોગ';

  @override
  String get reportReasonImpersonation => 'ખોટી ઓળખ';

  @override
  String get reportReasonOther => 'અન્ય';

  @override
  String get reportDetailsLabel => 'વધારાની વિગતો (વૈકલ્પિક)';

  @override
  String get reportSubmit => 'રિપોર્ટ સબમિટ કરો';

  @override
  String get reportSubmittedTitle => 'રિપોર્ટ સબમિટ થયો';

  @override
  String get reportSubmittedBody =>
      'આભાર. અમારી ટીમ આ કન્ટેન્ટની સમીક્ષા કરશે.';

  @override
  String get reportFailedTitle => 'રિપોર્ટ મોકલી શકાયો નથી';

  @override
  String get reportFailedBody => 'કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get reportContentTryOnImage => 'AI ટ્રાય-ઓન ઇમેજ';

  @override
  String get reportContentSharedOutfit => 'શેર કરેલ આઉટફિટ';

  @override
  String get reportContentPhotoshootImage => 'AI ફોટોશૂટ ઇમેજ';

  @override
  String get sharedOutfitTitle => 'શેર કરેલ આઉટફિટ';

  @override
  String get sharedOutfitHideTooltip => 'આ આઉટફિટ છુપાવો';

  @override
  String get sharedOutfitReportTooltip => 'આ આઉટફિટની જાણ કરો';

  @override
  String get sharedOutfitHideTitle => 'આ આઉટફિટ છુપાવવો છે?';

  @override
  String get sharedOutfitHideBody =>
      'તે આ ઉપકરણ પર છુપાયેલ રહેશે. તમે તેની જાણ પણ કરી શકો છો જેથી અમારી ટીમ તેને તપાસીને દૂર કરી શકે.';

  @override
  String get sharedOutfitHideAction => 'છુપાવો';

  @override
  String get sharedOutfitHiddenInfo => 'આ આઉટફિટ હવે આ ઉપકરણ પર દેખાશે નહીં.';

  @override
  String get sharedOutfitHiddenToast => 'આઉટફિટ છુપાવ્યો';

  @override
  String get sharedOutfitMissingTitle => 'આ આઉટફિટ હવે ઉપલબ્ધ નથી';

  @override
  String get sharedOutfitMissingBody =>
      'કદાચ તેને દૂર કરવામાં આવ્યો છે, અથવા લિંક ખોટી છે.';

  @override
  String get sharedOutfitHiddenStateTitle => 'તમે આ આઉટફિટ છુપાવ્યો છે';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'જો તે વાંધાજનક હોય, તો પ્રાઇવસી અને શરતોમાંથી તેની જાણ કરો અથવા $email પર ઇમેઇલ કરો.';
  }

  @override
  String get sharedOutfitCtaTitle => 'આ લુક ગમ્યો?';

  @override
  String get sharedOutfitCtaBody => 'તમારા પોતાના કબાટમાંથી આવા આઉટફિટ બનાવો.';

  @override
  String get sharedOutfitCtaButton => 'FitCheck AI મેળવો';

  @override
  String get errorTitle => 'ભૂલ';

  @override
  String get errorUnknown => 'એક અનપેક્ષિત ભૂલ થઈ';

  @override
  String get errorNoConnection =>
      'ઇન્ટરનેટ કનેક્શન નથી. કૃપા કરીને તમારું નેટવર્ક તપાસો.';

  @override
  String get errorTimeout =>
      'વિનંતીનો સમય સમાપ્ત થયો. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get errorServerError =>
      'અમારી તરફથી કંઈક ખોટું થયું છે. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get errorBadGateway =>
      'અમારું સર્વર ટૂંક સમય માટે અનુપલબ્ધ છે. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get errorServiceUnavailable =>
      'સેવા અસ્થાયી રૂપે અનુપલબ્ધ છે. કૃપા કરીને થોડીવારમાં ફરી પ્રયાસ કરો.';

  @override
  String get errorInternalError =>
      'કંઈક ખોટું થયું છે. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get errorUnauthorized => 'આગળ વધવા માટે કૃપા કરીને સાઇન ઇન કરો.';

  @override
  String get errorForbidden => 'તમારી પાસે તેનીક્સેસ નથી.';

  @override
  String get errorSessionExpired =>
      'તમારું સત્ર સમાપ્ત થઈ ગયું છે. કૃપા કરીને ફરીથી સાઇન ઇન કરો.';

  @override
  String get errorInvalidCredentials => 'તે ઇમેઇલ અથવા પાસવર્ડ સાચો નથી.';

  @override
  String get errorTokenRefreshFailed =>
      'અમે તમારું સત્ર તાજું કરી શક્યા નથી. કૃપા કરીને ફરીથી સાઇન ઇન કરો.';

  @override
  String get errorRequestCancelled => 'વિનંતી રદ કરવામાં આવી.';

  @override
  String get errorInvalidFormat => 'તે ફાઇલ ફોર્મેટ સપોર્ટેડ નથી.';

  @override
  String get errorFileTooLarge => 'તે ફાઇલ ખૂબ મોટી છે.';

  @override
  String get errorUploadFailed =>
      'અપલોડ નિષ્ફળ ગયું. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get errorCacheCorrupted =>
      'સેવ કરેલો ડેટા ક્ષતિગ્રસ્ત થયો છે અને રીસેટ કરવામાં આવ્યો છે.';

  @override
  String get errorCacheNotFound => 'હજુ સુધી કંઈપણ સેવ કરવામાં આવ્યું નથી.';

  @override
  String get errorUserNotFound => 'અમને તે એકાઉન્ટ મળ્યું નથી.';

  @override
  String get errorItemNotFound => 'તે આઇટમ હવે અસ્તિત્વમાં નથી.';

  @override
  String get errorOutfitNotFound => 'તે આઉટફિટ હવે અસ્તિત્વમાં નથી.';

  @override
  String get rewardsTitle => 'રિવાર્ડ્સ';

  @override
  String get rewardsNoAchievementsTitle => 'હજુ સુધી કોઈ સિદ્ધિ નથી';

  @override
  String get rewardsNoAchievementsBody =>
      'તમારી પ્રથમ સિદ્ધિ મેળવવા માટે કપડાં ઉમેરો અને આઉટફિટ પ્લાન કરો.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'લીડરબોર્ડ પર કોઈ નથી';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'પોઇન્ટ મેળવવા અને અહીં દેખાવા માટે આઉટફિટ પ્લાન કરો.';

  @override
  String get legalViewPrivacyPolicy => 'પ્રાઇવસી પૉલિસી જુઓ';

  @override
  String get aiConsentAgree => 'હું સહમત છું અને આગળ વધો';

  @override
  String get aiConsentNotNow => 'અત્યારે નહીં';

  @override
  String get imageViewerCloseTooltip => 'છબી દર્શક બંધ કરો';

  @override
  String get updateReadyTitle => 'અપડેટ તૈયાર છે';

  @override
  String get updateReadyBody =>
      'નવા સુધારાઓ લાગુ કરવા માટે FitCheck AI ને પુનઃપ્રારંભ કરો.';

  @override
  String get permissionCameraUsage =>
      'તમારા પોશાક અને કબાટના ફોટા લેવા માટે FitCheck AI ને કેમેરાની ઍક્સેસની જરૂર છે.';

  @override
  String get permissionPhotoLibraryUsage =>
      'તમારા પોશાક અને કબાટની છબીઓ પસંદ કરવા માટે FitCheck AI ને ફોટો લાઇબ્રેરી ઍક્સેસની જરૂર છે.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI ને તમારા AI-જનરેટેડ પોશાક ફોટા તમારી ફોટો લાઇબ્રેરીમાં સાચવવાની જરૂર છે.';

  @override
  String get wardrobeSomePhotosSkipped => 'કેટલાક ફોટા છોડી દેવાયા';

  @override
  String get wardrobePhotosNotAdded => 'ફોટા ઉમેર્યા નથી';

  @override
  String get wardrobePhotoNotAdded => 'ફોટો ઉમેર્યો નથી';

  @override
  String get wardrobeNotStartedTitle => 'શરૂ કર્યું નથી';

  @override
  String get wardrobeNoRoomTitle => 'કોઈ જગ્યા નથી';

  @override
  String get wardrobeAddPhotosSemantic => 'ફોટા ઉમેરો';

  @override
  String get batchAddTileLabel => 'ઉમેરો';

  @override
  String get batchProfileLinkLabel => 'પ્રોફાઇલ લિંક';

  @override
  String get wardrobeImportFromProfileTitle => 'પ્રોફાઇલમાંથી આયાત કરો';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'ઘણા ફોટા ઉમેરો';

  @override
  String get wardrobeClearAction => 'સાફ કરો';

  @override
  String get wardrobeRefreshTooltip => 'ફ્રેશ કરો';

  @override
  String get batchNoPhotosYetTitle => 'હજી સુધી કોઈ ફોટા નથી';

  @override
  String get batchChoosePhotosAction => 'ફોટા પસંદ કરો';

  @override
  String get batchWeFindEachPieceBody =>
      'અમે દરેક પીસ શોધીએ છીએ અને તેનો સ્ટુડિયો ફોટો બનાવીએ છીએ.';

  @override
  String get batchPreparingPhotosSemantic => 'ફોટા તૈયાર કરી રહ્યા છીએ';

  @override
  String get batchPhotosProcessedSemantic => 'ફોટા પ્રક્રિયા થયા';

  @override
  String get batchPasteProfileLinkTitle => 'પ્રોફાઇલ લિંક પેસ્ટ કરો';

  @override
  String get batchPasteProfileLinkBody =>
      'જાહેર ઇન્સ્ટાગ્રામ અથવા ફેસબુક પ્રોફાઇલ. અમે તેના ફોટા સ્કેન કરીએ છીએ, અને તમે નક્કી કરો છો કે કબાટમાં શું જશે.';

  @override
  String get batchClearLinkTooltip => 'લિંક સાફ કરો';

  @override
  String get batchStartingButton => 'શરૂ કરી રહ્યા છીએ';

  @override
  String get batchStartImportAction => 'આયાત શરૂ કરો';

  @override
  String get batchReviewEveryPhotoTitle => 'તમે દરેક ફોટો તપાસો';

  @override
  String get batchReviewEveryPhotoBody =>
      'જ્યાં સુધી તમે મંજૂર ન કરો ત્યાં સુધી કંઈપણ ઉમેરાતું નથી.';

  @override
  String get batchPrivateProfilesTitle => 'પ્રાઇવેટ પ્રોફાઇલ્સ';

  @override
  String get batchPrivateProfilesBody =>
      'તમારું એકાઉન્ટ કનેક્ટ કરો. Instagram માં યુઝરનેમ અને પાસવર્ડ પણ જરૂરી છે.';

  @override
  String get batchUseAnotherLinkAction => 'બીજી લિંક વાપરો';

  @override
  String get batchSignInNeededTitle => 'સાઇન-ઇન જરૂરી છે';

  @override
  String get batchEnterYourCodeTitle => 'તમારો કોડ દાખલ કરો';

  @override
  String get batchUseUsernamePasswordAction => 'યુઝરનેમ અને પાસવર્ડ વાપરો';

  @override
  String get batchAlreadyConnectedAction =>
      'મેં બ્રાઉઝરમાં પહેલેથી કનેક્ટ કર્યું છે';

  @override
  String get batchEnterCodeAction => 'કોડ દાખલ કરો';

  @override
  String get batchTryAnotherWayAction => 'બીજી રીત અજમાવો';

  @override
  String get batchLiveStatus => 'લાઇવ';

  @override
  String get batchReconnectingStatus => 'ફરી કનેક્ટ થઈ રહ્યું છે';

  @override
  String get batchSignInToInstagramTitle => 'Instagram માં સાઇન ઇન કરો';

  @override
  String get batchUsernameLabel => 'યુઝરનેમ';

  @override
  String get batchCodeIfTwoStepLabel =>
      'કોડ, જો તમે ટુ-સ્ટેપ સાઇન-ઇન વાપરતા હોવ';

  @override
  String get batchAuthenticatorCodeBody =>
      'તમારી ઓથેન્ટિકેટર એપનો 6-અંકનો કોડ વાપરો. કોડ ઝડપથી બદલાય છે.';

  @override
  String get batchVerifyAction => 'ચકાસો';

  @override
  String get batchFindingPhotosTitle => 'ફોટા શોધી રહ્યા છીએ';

  @override
  String get batchImportPausedTitle => 'આયાત થોભાવવામાં આવી છે';

  @override
  String get batchProcessingPhotosTitle => 'ફોટા પ્રોસેસ થઈ રહ્યા છે';

  @override
  String get batchWaitingNextPhoto => 'આગલા ફોટાની રાહ જોઈ રહ્યા છીએ';

  @override
  String get batchCancelImportAction => 'આયાત રદ કરો';

  @override
  String get batchNoPiecesInPhotoBody => 'આ ફોટામાં કોઈ કપડાં મળ્યા નથી.';

  @override
  String get batchEditPieceColoursLabel => 'રંગો, અલ્પવિરામથી અલગ કરેલા';

  @override
  String get batchAddToClosetAction => 'કબાટમાં ઉમેરો';

  @override
  String get batchSkipPhotoAction => 'આ ફોટો છોડી દો';

  @override
  String get batchImportCompleteTitle => 'આયાત પૂર્ણ થઈ';

  @override
  String get batchImportFailedTitle => 'આયાત નિષ્ફળ ગઈ';

  @override
  String get batchImportCancelledTitle => 'આયાત રદ કરવામાં આવી';

  @override
  String get batchImportErrorBody => 'આયાત કરતી વખતે કંઈક ખોટું થયું.';

  @override
  String get batchNothingMoreImportedBody =>
      'આ પ્રોફાઇલમાંથી વધુ કંઈ આયાત કરવામાં આવ્યું નથી.';

  @override
  String get batchViewClosetAction => 'ક્લોઝેટ જુઓ';

  @override
  String get batchStartOverAction => 'ફરીથી શરૂ કરો';

  @override
  String get wardrobeAddPieceTitle => 'પીસ ઉમેરો';

  @override
  String get wardrobeAddDetailsTitle => 'વિગતો ઉમેરો';

  @override
  String get wardrobeScanningTitle => 'સ્કેન કરી રહ્યું છે';

  @override
  String get batchReviewPiecesTitle => 'પીસ તપાસો';

  @override
  String get wardrobeGalleryAction => 'ગેલેરી';

  @override
  String get wardrobeCameraAction => 'કેમેરા';

  @override
  String get wardrobeNewBadge => 'નવું';

  @override
  String get wardrobeRemovePhotoTooltip => 'ફોટો દૂર કરો';

  @override
  String get batchRunInBackgroundTooltip => 'બેકગ્રાઉન્ડમાં ચલાવો';

  @override
  String get batchStepOneOfTwo => 'પગલું ૧ માંથી ૨';

  @override
  String get batchStepTwoOfTwo => 'પગલું ૨ માંથી ૨';

  @override
  String get batchUploadingPhotosTitle => 'ફોટા અપલોડ થઈ રહ્યા છે';

  @override
  String get batchFindingPiecesTitle => 'પીસ શોધી રહ્યા છીએ';

  @override
  String get batchMakingStudioPhotosTitle => 'સ્ટુડિયો ફોટા બનાવી રહ્યા છીએ';

  @override
  String get batchStoppedLabel => 'બંધ કરેલ';

  @override
  String get batchFindingPiecesStoppedTitle => 'પીસ શોધવાનું અટકાવ્યું';

  @override
  String get batchCancelledLabel => 'રદ કર્યું';

  @override
  String get batchAllDoneTitle => 'બધું થઈ ગયું';

  @override
  String get batchOpeningPiecesBody => 'તમારા પીસ ખુલી રહ્યા છે';

  @override
  String get batchNothingSavedBody => 'કંઈપણ સાચવવામાં આવ્યું નથી.';

  @override
  String get batchFindingPiecesFailedBody => 'પીસ શોધવાનું નિષ્ફળ ગયું.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'પીસ શોધવાનું વહેલું અટક્યું.';

  @override
  String get batchStopFindingPiecesTitle => 'પીસ શોધવાનું બંધ કરવું છે?';

  @override
  String get batchStopFindingPiecesBody =>
      'સ્કેન અટકી જાય છે અને કંઈપણ સાચવવામાં આવતું નથી. મળી ચૂકેલા પીસ તમે કાઢી નાખો ત્યાં સુધી તમારી પ્રવૃત્તિમાં રહેશે.';

  @override
  String get batchKeepGoingAction => 'ચાલુ રાખો';

  @override
  String get batchTryAgainAction => 'ફરી પ્રયાસ કરો';

  @override
  String get batchBackToPhotosAction => 'ફોટા પર પાછા જાઓ';

  @override
  String get batchSkipAllAction => 'બધું છોડો';

  @override
  String get batchIncludeAllAction => 'બધા જ સામેલ કરો';

  @override
  String get batchNoPiecesFoundTitle => 'કોઈ પીસ મળ્યા નથી';

  @override
  String get batchNoPiecesFoundBody => 'અમને આ ફોટામાં કોઈ કપડાં મળ્યા નથી.';

  @override
  String get batchChooseOtherPhotosAction => 'બીજા ફોટા પસંદ કરો';

  @override
  String get batchUseCaseHelper => 'તમે સાચવેલા દરેક પીસમાં ઉમેરાયું.';

  @override
  String get batchDiscardPiecesTitle => 'આ પીસ રદ કરવા છે?';

  @override
  String get batchDiscardPiecesBody => 'આ બેચમાંથી કંઈપણ સાચવવામાં આવ્યું નથી.';

  @override
  String get batchKeepAction => 'રાખો';

  @override
  String get batchDiscardAction => 'રદ કરો';

  @override
  String get batchRemovePieceTitle => 'આ પીસ દૂર કરવો છે?';

  @override
  String get batchRemovePieceBody => 'તે તમારા કબાટમાં સાચવવામાં આવ્યો નથી.';

  @override
  String get batchRemoveAction => 'દૂર કરો';

  @override
  String get batchChoosePiecesToSave => 'સાચવવા માટેના પીસ પસંદ કરો';

  @override
  String get batchDiscardAllAction => 'બધું રદ કરો';

  @override
  String get batchNothingSavedRetryBody =>
      'કંઈપણ સાચવવામાં આવ્યું નથી. ફરી પ્રયાસ કરો.';

  @override
  String get batchNotSavedTitle => 'સાચવ્યું નથી';

  @override
  String get batchSavingLabel => 'સાચવી રહ્યું છે';

  @override
  String get batchSendToBackgroundAction => 'બેકગ્રાઉન્ડમાં મોકલો';

  @override
  String get batchStillWorkingMessage =>
      'કામ ચાલુ છે. તમારા પીસ તૈયાર થઈ જશે એટલે અમે તમને જણાવીશું.';

  @override
  String get batchRunningInBackgroundTitle => 'બેકગ્રાઉન્ડમાં ચાલી રહ્યું છે';

  @override
  String get batchStudioPhotosStoppedBody =>
      'સ્ટુડિયો ફોટા વહેલા અટકી ગયા. તમે હજુ પણ આ પીસ સાચવી શકો છો.';

  @override
  String get batchTapPieceToSkip => 'છોડી દેવા માટે પીસ પર ટેપ કરો.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'સ્ટુડિયો ફોટા હજુ આવી રહ્યા છે. તમે જઈ શકો છો — અમે તમને જણાવીશું.';

  @override
  String get batchLeaveAction => 'બહાર નીકળો';

  @override
  String get batchPeopleInPhotosTitle => 'ફોટામાં રહેલા લોકો';

  @override
  String get batchIncludeAction => 'સામેલ કરો';

  @override
  String get batchSkipAction => 'છોડો';

  @override
  String get batchYourPhotoIsUsedLabel => 'તમારો ફોટો વપરાયો છે';

  @override
  String get batchMakingStudioPhotoLabel => 'સ્ટુડિયો ફોટો બનાવી રહ્યા છીએ';

  @override
  String get batchNoStudioPhotoBody =>
      'કોઈ સ્ટુડિયો ફોટો નથી. તમારો ફોટો વપરાયો છે.';

  @override
  String get batchEnterDetailsYourselfAction => 'વિગતો જાતે દાખલ કરો';

  @override
  String get batchChooseAnotherPhotoAction => 'બીજો ફોટો પસંદ કરો';

  @override
  String get batchConnectionLostTitle => 'કનેક્શન તૂટી ગયું છે';

  @override
  String get batchConnectionLostBody =>
      'તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get batchDailyLimitTitle => 'દૈનિક મર્યાદા પૂરી થઈ ગઈ';

  @override
  String get batchDailyLimitBodyPaywall =>
      'વધુ સ્કેન માટે Pro પર અપગ્રેડ કરો અથવા વિગતો જાતે દાખલ કરો.';

  @override
  String get batchDailyLimitBodyFree =>
      'તમારા સ્કેન કાલથી રીસેટ થશે. તમે હવે વિગતો જાતે દાખલ કરી શકો છો.';

  @override
  String get batchSeePlansAction => 'પ્લાન જુઓ';

  @override
  String get batchAiBusyTitle => 'અમારી AI વ્યસ્ત છે';

  @override
  String get batchAiBusyBody =>
      'આ અમારી તરફથી છે. થોડી મિનિટો પછી ફરી પ્રયાસ કરો.';

  @override
  String get batchNoPiecesBody =>
      'વધુ સ્પષ્ટ ફોટો અજમાવો અથવા વિગતો જાતે દાખલ કરો.';

  @override
  String get batchScanningUnavailableTitle => 'સ્કેનિંગ ઉપલબ્ધ નથી';

  @override
  String get batchScanningUnavailableBody => 'હાલ માટે વિગતો જાતે દાખલ કરો.';

  @override
  String get batchScanDidNotFinishTitle => 'સ્કેન પૂરું થયું નથી';

  @override
  String get batchTryAgainBody => 'ફરી પ્રયાસ કરો.';

  @override
  String get billingTitle => 'સબ્સ્ક્રિપ્શન';

  @override
  String get billingUpgradeHeading => 'તમારો પ્લાન અપગ્રેડ કરો';

  @override
  String get billingUpgradeOnPlusBody => 'સમાન સુવિધાઓ, ઉચ્ચ મર્યાદાઓ.';

  @override
  String get billingUpgradeBody =>
      'Plus અને Pro માં સમાન સુવિધાઓ છે. તમને જોઈતી મર્યાદા પસંદ કરો.';

  @override
  String get billingWebUnavailableBody =>
      'ઓનલાઈન અપગ્રેડ હજુ ઉપલબ્ધ નથી. પ્રોમો અથવા રેફરલ કોડ હજુ પણ Plus કે Pro અનલોક કરે છે. મફત મહિનાઓ મેળવવા માટે મિત્રોને આમંત્રિત કરો.';

  @override
  String get billingPlansStale =>
      'નવીનતમ પ્લાન લોડ થઈ શક્યા નથી. કિંમતો જૂની હોઈ શકે છે.';

  @override
  String get billingMonthly => 'માસિક';

  @override
  String get billingYearly => 'વાર્ષિક';

  @override
  String get billingCurrentPlan => 'વર્તમાન પ્લાન';

  @override
  String get billingActive => 'સક્રિય';

  @override
  String get billingThisMonth => 'આ મહિને';

  @override
  String get billingItemExtractions => 'આઇટમ એક્સટ્રેક્શન';

  @override
  String get billingOutfitVisualizations => 'આઉટફિટ વિઝ્યુલાઇઝેશન';

  @override
  String get billingNearLimitUpgrade =>
      'તમે આ મહિનાની મર્યાદાની નજીક છો. વધુ માટે અપગ્રેડ કરો.';

  @override
  String get billingNearLimitResets =>
      'તમે આ મહિનાની મર્યાદાની નજીક છો. તે આવતા મહિનાની શરૂઆતમાં રીસેટ થશે.';

  @override
  String get billingStoreUnavailable =>
      'હમણાં સ્ટોરમાં અપગ્રેડ ઉપલબ્ધ નથી. થોડા સમય પછી પ્રયાસ કરો.';

  @override
  String get billingManageHeading => 'તમારું પ્લાન મેનેજ કરો';

  @override
  String get billingCancelPlan => 'સબ્સ્ક્રિપ્શન રદ કરો';

  @override
  String get billingCancelKeepsAccess =>
      'આ બિલિંગ અવધિના અંત સુધી તમારી પાસે એક્સેસ રહેશે.';

  @override
  String get billingCancelConfirmTitle => 'તમારું સબ્સ્ક્રિપ્શન રદ કરવું છે?';

  @override
  String get billingKeepPlan => 'પ્લાન ચાલુ રાખો';

  @override
  String get billingCancelPlanAction => 'પ્લાન રદ કરો';

  @override
  String get billingBilledMonthly => 'માસિક બિલિંગ';

  @override
  String get billingBilledYearly => 'વાર્ષિક બિલિંગ';

  @override
  String get billingVirtualTryOn => 'વર્ચ્યુઅલ ટ્રાય-ઓન';

  @override
  String get billingPrioritySupport => 'પ્રાયોરિટી સપોર્ટ';

  @override
  String get billingDisclosureProRenewing =>
      'Pro એ આપોઆપ રિન્યૂ થતું સબ્સ્ક્રિપ્શન છે';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus અને Pro આપોઆપ રિન્યૂ થતા સબ્સ્ક્રિપ્શન્સ છે';

  @override
  String get billingDisclosureAppleBilling =>
      'ખરીદીની પુષ્ટિ પર ચુકવણી તમારા Apple ID પર લેવામાં આવે છે.';

  @override
  String get billingDisclosureGoogleBilling =>
      'ખરીદીની પુષ્ટિ પર ચુકવણી તમારા Google Play એકાઉન્ટ પર લેવામાં આવે છે.';

  @override
  String get billingDisclosureRenewalTerms =>
      'વર્તમાન સમયગાળો સમાપ્ત થવાના ઓછામાં ઓછા 24 કલાક પહેલાં ઓટો-રિન્યૂ બંધ ન કરો તો તમારું સબ્સ્ક્રિપ્શન તે જ કિંમતે તે જ સમયગાળા માટે આપમેળે રિન્યૂ થાય છે.';

  @override
  String get billingDisclosureAppleManage =>
      'સેટિંગ્સ › તમારું Apple ID › સબ્સ્ક્રિપ્શન્સ માં ગમે ત્યારે મેનેજ કરો અથવા રદ કરો.';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play › ચુકવણીઓ અને સબ્સ્ક્રિપ્શન્સ માં ગમે ત્યારે મેનેજ કરો અથવા રદ કરો.';

  @override
  String get billingReferFriend => 'મિત્રને રેફર કરો';

  @override
  String get billingHowItWorks => 'તે કેવી રીતે કામ કરે છે';

  @override
  String get billingHowShareTitle => 'તમારી લિંક શેર કરો';

  @override
  String get billingHowShareBody => 'તે તમારા મિત્રને મોકલો.';

  @override
  String get billingHowSignUpTitle => 'તેઓ સાઇન અપ કરે છે';

  @override
  String get billingHowSignUpBody => 'તમારો મિત્ર લિંકથી જોડાય છે.';

  @override
  String get billingHowBothTitle => 'તમને બંનેને Pro મળે છે';

  @override
  String get billingHowBothBody => 'તમને બંનેને Pro નો એક મહિનો મફત મળે છે.';

  @override
  String get billingYourReferrals => 'તમારા રેફરલ્સ';

  @override
  String get billingInvited => 'આમંત્રિત';

  @override
  String get billingJoined => 'જોડાયા';

  @override
  String get billingMonthsEarned => 'મેળવેલા મહિનાઓ';

  @override
  String get billingInviteFriend => 'મિત્રને આમંત્રિત કરો';

  @override
  String get billingInviteBody =>
      'તમને અને તમારા મિત્ર બંનેને એક મહિનો Pro મળે છે.';

  @override
  String get billingYourCode => 'તમારો કોડ';

  @override
  String get billingCopyLink => 'લિંક કૉપી કરો';

  @override
  String get billingShareInvite => 'આમંત્રણ શેર કરો';

  @override
  String get giftUnavailable => 'આ બિલ્ડમાં ગિફ્ટ આમંત્રણો ઉપલબ્ધ નથી.';

  @override
  String get giftPageTitle => 'FitCheck Pro ભેટ આપો';

  @override
  String get giftNoAllowances => 'હમણાં કોઈ મફત ગિફ્ટ આમંત્રણ ઉપલબ્ધ નથી.';

  @override
  String get giftFormTitle => 'મફત આમંત્રણ મોકલો';

  @override
  String get giftFormBody =>
      'તમારા પ્રાપ્તકર્તા આ ચકાસાયેલ ઇમેઇલ સાથે ભેટ ક્લેમ કરે છે. અમે તમારા માટે ઇમેઇલ મોકલતા નથી.';

  @override
  String get giftFieldFrom => 'તરફથી';

  @override
  String get giftFieldRecipientName => 'પ્રાપ્તકર્તાનું નામ';

  @override
  String get giftFieldRecipientEmail => 'પ્રાપ્તકર્તાનો ઇમેઇલ';

  @override
  String get giftFieldOccasion => 'પ્રસંગ (વૈકલ્પિક)';

  @override
  String get giftNoOccasion => 'કોઈ પ્રસંગ નહીં';

  @override
  String get giftOccasionBirthday => 'જન્મદિવસ';

  @override
  String get giftOccasionAnniversary => 'વર્ષગાંઠ';

  @override
  String get giftOccasionOther => 'અન્ય';

  @override
  String get giftFieldCardGreeting => 'કાર્ડ અભિનંદન';

  @override
  String get giftFieldCardGreetingHelper =>
      'આ કાર્ડ પર બરાબર તે જ દેખાય છે જે લખેલું છે.';

  @override
  String get giftFieldPrivateNote => 'ખાનગી નોંધ (વૈકલ્પિક)';

  @override
  String get giftCreateAction => 'મફત ભેટ બનાવો';

  @override
  String get giftClaimedTitle => 'ભેટ ક્લેમ થઈ ગઈ';

  @override
  String get giftClaimedActive => 'તમારી FitCheck Pro ભેટ સક્રિય છે.';

  @override
  String get giftClaimedQueued =>
      'તમારો વર્તમાન ઍક્સેસ પૂર્ણ થયા પછી તમારી FitCheck Pro ભેટ શરૂ થશે.';

  @override
  String get giftLinkCopied => 'ગિફ્ટ લિંક ક્લિપબોર્ડ પર કૉપી થઈ ગઈ.';

  @override
  String get giftErrorName => 'નામ દાખલ કરો.';

  @override
  String get giftErrorEmail => 'માન્ય ઇમેઇલ સરનામું દાખલ કરો.';

  @override
  String get giftErrorGreeting => 'કાર્ડ અભિનંદન દાખલ કરો.';

  @override
  String get giftErrorGreetingLength => '80 થી વધુ અક્ષરોનો ઉપયોગ કરશો નહીં.';

  @override
  String get giftClaimAction => 'ગિફ્ટ ક્લેમ કરો';

  @override
  String get giftCardPreview => 'કાર્ડ પૂર્વાવલોકન';

  @override
  String get giftGiftForYou => 'તમારા માટે એક ગિફ્ટ';

  @override
  String get giftGiftWaiting => 'તમારા માટે એક ગિફ્ટ રાહ જોઈ રહી છે';

  @override
  String get giftOpenBody =>
      'તમારા ચકાસાયેલ ઇમેઇલ સાથે ક્લેમ કરવા માટે તમારી ગિફ્ટ ખોલો.';

  @override
  String get giftOpenGifts => 'ગિફ્ટ ખોલો';

  @override
  String get giftSendInvitation => 'આમંત્રણ મોકલો';

  @override
  String get settingsAiProviderSection => 'પ્રદાતા';

  @override
  String get settingsAiCustom => 'કસ્ટમ';

  @override
  String get settingsAiUrlHelper =>
      'સર્વર પહોંચી શકે તેવું સાર્વજનિક URL વાપરો. લોકલહોસ્ટ કામ કરતું નથી.';

  @override
  String get settingsAiConnectionSection => 'કનેક્શન';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API કી';

  @override
  String get settingsAiApiKeySaved => 'સેવ થઈ ગયું. ખાલી રાખો તો બદલાશે નહીં.';

  @override
  String get settingsAiChatModel => 'ચેટ મોડેલ';

  @override
  String get settingsAiVisionModel => 'વિઝન મોડેલ (વૈકલ્પિક)';

  @override
  String get settingsAiImageModel => 'ઇમેજ મોડેલ (વૈકલ્પિક)';

  @override
  String get settingsAiImageModelNote =>
      'ઇમેજ જનરેશન માટે response_modalities સાથે OpenAI-સુસંગત ચેટ કમ્પ્લીશન્સ જરૂરી છે.';

  @override
  String get settingsAiTestConnection => 'કનેક્શન ટેસ્ટ કરો';

  @override
  String get calendarTitle => 'કેલેન્ડર';

  @override
  String get calendarGoToToday => 'આજ પર જાઓ';

  @override
  String get calendarConnectTooltip => 'કેલેન્ડર કનેક્ટ કરો';

  @override
  String get calendarAddEvent => 'ઇવેન્ટ ઉમેરો';

  @override
  String get calendarEmptyTitle => 'કંઈ આયોજિત નથી';

  @override
  String get calendarEmptyBody =>
      'ઇવેન્ટ ઉમેરો અને શું પહેરવું તેનું આયોજન કરો.';

  @override
  String get calendarPreviousMonth => 'પાછલો મહિનો';

  @override
  String get calendarNextMonth => 'આગામી મહિનો';

  @override
  String get calendarAllDay => 'આખો દિવસ';

  @override
  String get calendarOutfitLinked => 'આઉટફિટ લિંક થયો';

  @override
  String get calendarEventOptions => 'ઇવેન્ટ વિકલ્પો';

  @override
  String get calendarDeleteTitle => 'આ ઇવેન્ટ કાઢી નાખવી છે?';

  @override
  String get calendarChangeOutfit => 'પોશાક બદલો';

  @override
  String get calendarLinkOutfit => 'પોશાક લિંક કરો';

  @override
  String get calendarRemoveOutfit => 'પોશાક દૂર કરો';

  @override
  String get calendarNewEvent => 'નવી ઇવેન્ટ';

  @override
  String get calendarEditEvent => 'ઇવેન્ટ સંપાદિત કરો';

  @override
  String get calendarTitleLabel => 'શીર્ષક';

  @override
  String get calendarTitleRequired => 'શીર્ષક ઉમેરો';

  @override
  String get calendarEndBeforeStart => 'શરૂઆત પછી સમાપ્ત કરો';

  @override
  String get calendarStarts => 'શરૂ થાય છે';

  @override
  String get calendarEnds => 'સમાપ્ત થાય છે';

  @override
  String get calendarPlaceOptional => 'સ્થળ (વૈકલ્પિક)';

  @override
  String get calendarNotesOptional => 'નોંધ (વૈકલ્પિક)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'પોશાક બનાવો, પછી તેને આ ઇવેન્ટ સાથે લિંક કરો.';

  @override
  String get calendarBuildOutfit => 'પોશાક બનાવો';

  @override
  String get calendarConnectionsTitle => 'કેલેન્ડર';

  @override
  String get calendarConnectionsBody =>
      'તમે અહીં ઉમેરેલી ઇવેન્ટ્સ FitCheck માં રહે છે.';

  @override
  String get calendarDisconnect => 'ડિસ્કનેક્ટ કરો';

  @override
  String get calendarNotAvailable => 'હજી ઉપલબ્ધ નથી';

  @override
  String get profileSectionExplore => 'અન્વેષણ કરો';

  @override
  String get profileNavTryOn => 'ટ્રાય-ઓન';

  @override
  String get profileNavRewards => 'રિવાર્ડ્સ';

  @override
  String get profileSupport => 'સહાય';

  @override
  String get profileHelp => 'મદદ';

  @override
  String get profileAbout => 'વિશે';

  @override
  String get profileAboutBody => 'તમારો કબાટ, પોશાક અને પ્લાન એક જ જગ્યાએ.';

  @override
  String get profileSignOutTitle => 'સાઇન આઉટ કરવું છે?';

  @override
  String get profileSignOutBody => 'તમે કોઈપણ સમયે પાછા સાઇન ઇન કરી શકો છો.';

  @override
  String get profileEditTitle => 'પ્રોફાઇલ સંપાદિત કરો';

  @override
  String get profileYourProfile => 'તમારી પ્રોફાઇલ';

  @override
  String get profileBodyProfiles => 'બોડી પ્રોફાઇલ્સ';

  @override
  String get profileBodyEmptyTitle => 'હજી કોઈ બોડી પ્રોફાઇલ નથી';

  @override
  String get profileBodyEmptyBody =>
      'વધુ સારી ફિટિંગ માટે તમારી ઊંચાઈ અને બાંધો ઉમેરો.';

  @override
  String get profileBodyAdd => 'પ્રોફાઇલ ઉમેરો';

  @override
  String get profileBodyDefaultNote =>
      'તમારી ડિફોલ્ટ પ્રોફાઇલનો ઉપયોગ ફિટ અને ટ્રાય-ઓન માટે થાય છે.';

  @override
  String get profileBodyDefaultBadge => 'ડિફોલ્ટ';

  @override
  String get profileBodyMakeDefault => 'ડિફોલ્ટ બનાવો';

  @override
  String get profileBodyDeleteBody => 'તમે આ પાછું ખેંચી શકતા નથી.';

  @override
  String get profileBodyRequired => 'જરૂરી છે';

  @override
  String get profileBodyCheckNumber => 'આ નંબર તપાસો';

  @override
  String get profileBodyNew => 'નવી બોડી પ્રોફાઇલ';

  @override
  String get profileBodyNameHint => 'ઉદાહરણ તરીકે, હું';

  @override
  String get profileBodyHeight => 'ઊંચાઈ';

  @override
  String get profileBodyWeight => 'વજન';

  @override
  String get profileBodyBuild => 'બાંધો';

  @override
  String get profileBodySkinTone => 'ત્વચાનો રંગ';

  @override
  String get profileBirthDateNeededBody => 'જન્મ સમય સાથે જન્મ તારીખ ઉમેરો.';

  @override
  String get profileBirthDateNeededTitle => 'જન્મ તારીખ જરૂરી છે';

  @override
  String get profilePartlySavedBody =>
      'અમે તમારું નામ અને ફોટો સાચવ્યા છે. જન્મ વિગતો સચવાઈ નથી; પછીથી પ્રયાસ કરો.';

  @override
  String get profilePartlySavedTitle => 'આંશિક રીતે સાચવ્યું';

  @override
  String get profileSavedBody => 'તમારી પ્રોફાઇલ સાચવાઈ ગઈ છે.';

  @override
  String get profileChangePhoto => 'પ્રોફાઇલ ફોટો બદલો';

  @override
  String get profilePhotoLabel => 'પ્રોફાઇલ ફોટો';

  @override
  String get profilePhotoHint => 'નવો પસંદ કરવા ટેપ કરો';

  @override
  String get profileBirthDateLabel => 'જન્મ તારીખ (વૈકલ્પિક)';

  @override
  String get profileBirthTimeLabel => 'જન્મ સમય (વૈકલ્પિક)';

  @override
  String get profileBirthTimeHelper => 'વૈદિક સૂચનો વધુ સચોટ બનાવે છે';

  @override
  String get profileBirthPlaceLabel => 'જન્મસ્થળ (વૈકલ્પિક)';

  @override
  String get profileBirthPlaceHint => 'ઉદાહરણ તરીકે, નવી દિલ્હી, ભારત';

  @override
  String get profileHelpContactTitle => 'અમને કંઈપણ પૂછો';

  @override
  String get profileHelpContactBody =>
      'મૂંહે મેસેજ મોકલો અને અમે ઈમેલ દ્વારા જવાબ આપીએ છીએ, સામાન્ય રીતે એક દિવસમાં.';

  @override
  String get profileHelpContactAction => 'સપોર્ટનો સંપર્ક કરો';

  @override
  String get profileHelpFaqTitle => 'સામાન્ય પ્રશ્નો';

  @override
  String get profileFaqAddPiecesTitle =>
      'હું મારા કબાટમાં કપડાં કેવી રીતે ઉમેરું?';

  @override
  String get profileFaqAddPiecesBody =>
      'કબાટ ટેબ પર આઈટમ ઉમેરો પર ટેપ કરો. ફોટો લો અથવા તમારી ગેલેરીમાંથી પસંદ કરો; અમે દરેક ટુકડો શોધીને તેને ટેગ કરીશું.';

  @override
  String get profileFaqMatchingTitle => 'આઉટફિટ મૅચિંગ કેવી રીતે કામ કરે છે?';

  @override
  String get profileFaqMatchingBody =>
      'તમારા માટે ખોલો અને તમારી પાસે હોય તેવા ટુકડાઓ પસંદ કરો. અમે સૂચવીએ છીએ કે તેની સાથે શું સારું લાગશે.';

  @override
  String get profileFaqTryOnTitle =>
      'શું હું ટ્રાફ-ઑન માટે મારા પોતાના ફોટા વાપરી શકું?';

  @override
  String get profileFaqTryOnBody =>
      'હા. તમારો આખો ફોટો ઉમેરો, પછી કપડાં પહેરીને જોવા માટે ટુકડાઓ પસંદ કરો.';

  @override
  String get profileFaqRewardsTitle => 'હું રિવોર્ડ્સ કેવી રીતે કમાઈ શકું?';

  @override
  String get profileFaqRewardsBody =>
      'નિયમિત આઉટફિટ્સ પ્લાન કરો અને લૉગ કરો. સ્ટ્રીક્સ અને સિદ્ધિઓ વધતી જશે.';

  @override
  String get profileFaqPrivacyTitle => 'શું મારી અલમારી ખાનગી છે?';

  @override
  String get profileFaqPrivacyBody =>
      'હા. તમારો કબાટ અને આઉટફિટ્સ ખાનગી છે સિવાય કે તમે લિંક શેર કરો.';

  @override
  String get profileHelpMoreTitle => 'વધુ મદદ';

  @override
  String get profileHelpGuides => 'માર્ગદર્શિકા';

  @override
  String get profileHelpGuidesBody => 'દરેક ફીચર કેવી રીતે કામ કરે છે';

  @override
  String get feedbackCategoryBug => 'કંઈક બગડ્યું છે';

  @override
  String get feedbackCategoryIdea => 'એક વિચાર';

  @override
  String get feedbackCategoryGeneral => 'સામાન્ય';

  @override
  String get feedbackCategoryHelp => 'મને મદદ જોઈએ છે';

  @override
  String get feedbackHintBug => 'શું થયું અને તમે શું અપેક્ષા રાખતા હતા?';

  @override
  String get feedbackHintIdea => 'તમને શું ગમશે અને કેમ?';

  @override
  String get feedbackHintGeneral => 'તમારા વિચારો જણાવો અથવા પ્રશ્ન પૂછો.';

  @override
  String get feedbackAttachmentLimitBody => 'તમે 5 સુધીના ચિત્રો ઉમેરી શકો છો.';

  @override
  String get feedbackAttachmentLimitTitle => 'મર્યાદા પહોંચી ગઈ';

  @override
  String get feedbackImageTooLargeBody => '5 MB થી નાની છબી પસંદ કરો.';

  @override
  String get feedbackImageTooLargeTitle => 'છબી ખૂબ મોટી છે';

  @override
  String get feedbackTitle => 'પ્રતિસાદ મોકલો';

  @override
  String get feedbackAboutLabel => 'આ શેના વિશે છે?';

  @override
  String get feedbackSubjectLabel => 'વિષય';

  @override
  String get feedbackSubjectRequired => 'વિષય ઉમેરો';

  @override
  String get feedbackSubjectTooShort => 'વિષય ઓછામાં ઓછો 3 અક્ષરનો હોવો જોઈએ';

  @override
  String get feedbackDetailsLabel => 'વિગતો';

  @override
  String get feedbackDetailsRequired => 'કેટલીક વિગતો ઉમેરો';

  @override
  String get feedbackDetailsTooShort =>
      'વર્ણન ઓછામાં ઓછું 10 અક્ષરનું હોવું જોઈએ';

  @override
  String get feedbackAddScreenshot => 'સ્ક્રીનશોટ ઉમેરો';

  @override
  String get feedbackAttachmentHint => 'વધુમાં વધુ 5, દરેક 5 MB';

  @override
  String get feedbackSend => 'મોકલો';

  @override
  String get feedbackEmptyTitle => 'હજુ સુધી કંઈ મોકલ્યું નથી';

  @override
  String get feedbackEmptyBody =>
      'તમે જે મોકલો છો તે તેની સ્થિતિ સાથે અહીં દેખાય છે.';

  @override
  String get feedbackHistoryTitle => 'તમે જે મોકલ્યું છે';

  @override
  String get feedbackStatusOpen => 'ઓપન';

  @override
  String get feedbackStatusInProgress => 'પ્રક્રિયામાં';

  @override
  String get feedbackStatusResolved => 'ઉકેલાયેલ';

  @override
  String get feedbackStatusClosed => 'બંધ';

  @override
  String get legalIntro =>
      'અમે તમારા ડેટાનું રક્ષણ કેવી રીતે કરીએ છીએ, અને FitCheck AI વાપરવાની શરતો.';

  @override
  String get legalPolicies => 'પોલિસીઓ';

  @override
  String get legalPrivacySubtitle => 'અમે શું એકત્રિત કરીએ છીએ અને શા માટે';

  @override
  String get legalTermsTitle => 'સેવાની શરતો';

  @override
  String get legalTermsSubtitle => 'એપ વાપરવાના નિયમો';

  @override
  String get legalLicences => 'ઓપન-સોર્સ લાયસન્સ';

  @override
  String get legalSupportSubtitle => 'મદદ, સંપર્ક અને પ્રાઇવસી વિનંતીઓ';

  @override
  String get legalReportAbuse => 'સમસ્યા અથવા દુરુપયોગની જાણ કરો';

  @override
  String get permissionCameraTitle => 'કેમેરાની પરવાનગી';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI તમારા કપડાં અને આઉટફિટ્સના ફોટા લેવા માટે કેમેરાનો ઉપયોગ કરે છે.';

  @override
  String get permissionPhotoTitle => 'ફોટોની પરવાનગી';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI ને તમારા ફોટાની જરૂર છે જેથી તમે કપડાં અને આઉટફિટ્સ પસંદ કરી શકો.';

  @override
  String get permissionNotNow => 'અત્યારે નહીં';

  @override
  String get permissionOpenSettings => 'સેટિંગ્સ ખોલો';

  @override
  String authSignedInAs(String name) {
    return '$name તરીકે સાઇન ઇન કર્યું છે';
  }

  @override
  String get authSignedIn => 'સાઇન ઇન કર્યું';

  @override
  String get authWelcomeBackTitle => 'પાછા સ્વાગત છે';

  @override
  String get authSignInFailed => 'સાઇન ઇન નિષ્ફળ';

  @override
  String get authWelcomeTitle => 'સ્વાગત છે';

  @override
  String get authSignUpFailed => 'સાઇન અપ નિષ્ફળ';

  @override
  String get authGoogleSignInFailed => 'ગૂગલ સાઇન ઇન નિષ્ફળ';

  @override
  String get authAppleSignInFailed => 'એપલ સાઇન ઇન નિષ્ફળ';

  @override
  String get authConfirmEmailTitle => 'તમારું ઇમેઇલ કન્ફર્મ કરો';

  @override
  String get authConfirmEmailBody =>
      'કન્ફર્મેશન ઇમેઇલ માટે તમારું ઇનબોક્સ ચેક કરો, પછી સાઇન ઇન કરો.';

  @override
  String get authClosetReady => 'તમારો કબાટ તૈયાર છે.';

  @override
  String get authSignedOutTitle => 'સાઇન આઉટ કર્યું';

  @override
  String get authSignedOutBody => 'તમે સાઇન આઉટ છો.';

  @override
  String get authSignOutFailed => 'સાઇન આઉટ નિષ્ફળ';

  @override
  String get authEmailSentTitle => 'ઇમેઇલ મોકલ્યો';

  @override
  String get authResetLinkSent => 'રીસેટ લિંક માટે તમારું ઇમેઇલ ચેક કરો.';

  @override
  String get authPasswordUpdatedTitle => 'પાસવર્ડ અપડેટ થયો';

  @override
  String get authPasswordUpdated => 'તમારો પાસવર્ડ અપડેટ થઈ ગયો છે.';

  @override
  String get authPasswordNotUpdated => 'પાસવર્ડ અપડેટ થયો નથી';

  @override
  String get authCouldNotSendEmail => 'ઇમેઇલ મોકલી શકાયો નહીં';

  @override
  String get authEmailNotSent => 'ઇમેઇલ મોકલ્યો નથી';

  @override
  String get authResendSentBody => 'અમે એક નવો કન્ફર્મેશન ઇમેઇલ મોકલ્યો છે.';

  @override
  String get outfitPreviewWithAi => 'AI સાથે પ્રિવ્યૂ કરો';

  @override
  String get outfitNewPreview => 'નવી પ્રિવ્યૂ બનાવો';

  @override
  String get outfitBuilderClosetHeading => 'તમારો કલોસેટ';

  @override
  String get outfitBuilderSearchHint => 'પીસ શોધો';

  @override
  String get outfitClearSearch => 'શોધ સાફ કરો';

  @override
  String get outfitBuilderAddPiecesTitle => 'સૌથી પહેલાં પીસ ઉમેરો';

  @override
  String get outfitBuilderAddPiecesBody =>
      'આઉટફિટ્સ તમારા કલોસેટના પીસમાંથી બનાવવામાં આવે છે.';

  @override
  String get outfitBuilderNoMatches => 'કોઈ પીસ મેળ ખાતી નથી.';

  @override
  String get outfitNameLabel => 'આઉટફિટનું નામ';

  @override
  String get outfitNameHint => 'ઉદાહરણ તરીકે, વીકેન્ડ લિનન';

  @override
  String get outfitPreviewSemantic => 'આઉટફિટનું AI પ્રિવ્યૂ';

  @override
  String get outfitChoosePieces => 'પીસ પસંદ કરો';

  @override
  String get outfitTapPiecesHint => 'ઉમેરવા માટે નીચેના પીસ પર ટેપ કરો.';

  @override
  String get outfitShareTooltip => 'શેર કરો';

  @override
  String get outfitSaveFavourite => 'ફેવરિટ્સમાં સેવ કરો';

  @override
  String get outfitPiecesHeading => 'પીસ';

  @override
  String get outfitWearHistoryEmpty => 'એકવાાર પહેરો અને તારીખો અહીં દેખાશે.';

  @override
  String get outfitWearHistoryTitle => 'પહેરવાનો ઇતિહાસ';

  @override
  String get outfitWearHistoryError => 'તારીખો લોડ કરી શકાય નહીં.';

  @override
  String get outfitWornOn => 'પહેરેલું';

  @override
  String get outfitEditTitle => 'આઉટફિટ સંપાદિત કરો';

  @override
  String get outfitSavedPhotosFailed => 'વિગ્રહ સેવ થયા, તસવીરો નહીં';

  @override
  String get outfitNoPhotosBody =>
      'હજુ કોઈ તસવીરો નથી. આઉટફિટ તેના પીસ બતાવે છે.';

  @override
  String get outfitOccasionLabel => 'અવસર';

  @override
  String get outfitOccasionNone => 'કોઈ નહીં';

  @override
  String get outfitTagsHint => 'કમા દ્વારા અલગ કરો';

  @override
  String get outfitDraftBody => 'તમારી મુખ્ય યાદીમાંથી છુપાયેલું';

  @override
  String get outfitPublic => 'સામાન્ય';

  @override
  String get outfitPublicBody => 'લિંક ધરાવતા કોઈ પણ વ્યક્તિ તેને જોઈ શકે છે';

  @override
  String get outfitDeleteFromDetail => 'આ આઉટફિટ તેની વિગત પૃષ્ઠથી કાઢો.';

  @override
  String get outfitNewCollection => 'નવી કલેક્શન';

  @override
  String get outfitNoCollectionsTitle => 'હજી કોઈ કલેક્શન નથી';

  @override
  String get outfitNoCollectionsBody =>
      'વાહણ, પ્લેન કે મૂડ પ્રમાણે આઉટફિટને જૂથબદ્ધ કરો.';

  @override
  String get outfitCreateCollection => 'કલેક્શન બનાવો';

  @override
  String get outfitAddOutfits => 'આઉટફિટ ઉમેરો';

  @override
  String get outfitRename => 'નામ બદલો';

  @override
  String get outfitCollectionDeleteBody => 'આમાંના આઉટફિટ રાખવામાં આવશે.';

  @override
  String get outfitCollectionsNotLoaded => 'આઉટફિટ લોડ થયા નથી';

  @override
  String get outfitRenameCollection => 'કલેક્શનનું નામ બદલો';

  @override
  String get outfitDescriptionOptional => 'વર્ણન (વિકલ્પ)';

  @override
  String get outfitAllInCollection => 'દરેક આઉટફિટ પહેલેથી જ આ કલેક્શનમાં છે.';

  @override
  String get photoshootSubtitleUpload =>
      'તમારા પોતાના ફોટામાંથી સ્ટુડિયો પોર્ટ્રેટ';

  @override
  String get photoshootSubtitleConfigure =>
      'એક સ્થીલ, ફોર્મેટ અને સંખ્યા પસંદ કરો';

  @override
  String get photoshootSubtitleGenerating => 'આમાં એક-બે મિનિટ લાગે';

  @override
  String get photoshootAddPhotosSemantic => 'તમારી ગેલેરીમાંથી ફોટા ઉમેરો';

  @override
  String get photoshootUploadTitle => 'તમારા સ્વ-ફોટાના 1 થી 4 ફોટા ઉમેરો';

  @override
  String get photoshootUploadBody => 'તમારી ગેલેરીમાંથી પસંદ કરવા માટે ટેપ કરો';

  @override
  String get photoshootAddToContinue => 'આગળ વધવા માટે ફોટો ઉમેરો';

  @override
  String get photoshootAddAnotherPhoto => 'હોવું';

  @override
  String get photoshootTipsTitle => 'શ્રેષ્ઠ પરિણામો માટે';

  @override
  String get photoshootTipsBody =>
      'તમારા ચહેરાના સાફ, એવલિંગીંક ફોટા, થોડા ખૂણાઓમાંથી ઉપયોગ કરો. સૂરજચશમ અને ટોપી છોડો.';

  @override
  String get photoshootStarting => 'શરૂ કરી રહ્યા છે';

  @override
  String get photoshootCancelling => 'રદ કરી રહ્યા છે';

  @override
  String get photoshootFailed => 'ફેલ';

  @override
  String get recommendTabMatches => 'મચાવો';

  @override
  String get recommendTabComplete => 'પૂર્ણ';

  @override
  String get recommendTabWeather => 'હવામાન';

  @override
  String get recommendTabColours => 'રંગ';

  @override
  String get recommendTabShop => 'ખરીદી';

  @override
  String get recommendNoMatchesTitle => 'અત્યારે કોઈ મેચ નથી';

  @override
  String get recommendNoMatchesBody =>
      'એક ટુકડો પસંદ કરો અને અમે જોઈએ કે કઈ ટુકડા સાથે ચાલે.';

  @override
  String get recommendPickPiece => 'ટુકડો પસંદ કરો';

  @override
  String get recommendNothingMatchesTitle => 'અત્યારે આ સાથે કંઈ મેચ નથી';

  @override
  String get recommendNothingMatchesBody =>
      'બીજા ટુકડા શરૂ કરો અથવા તમારા વોર્ડરોબમાં વધુ ઉમેરો.';

  @override
  String get recommendChangePieces => 'ટુકડા બદલો';

  @override
  String get recommendDefaultReason => 'તમે પસંદ કરેલા ટુકડા માટે યોગ્ય છે.';

  @override
  String get recommendCompleteTitle => 'લુક પૂર્ણ કરો';

  @override
  String get recommendCompleteBody =>
      'એક ટુકડો પસંદ કરો અને અમે બાકીનું પૂરું કરીશું.';

  @override
  String get recommendWorking => 'કાર્યરત';

  @override
  String get recommendGenerate => 'નિષ્કર્ષ કરો';

  @override
  String get recommendChooseStyleBody => 'એક શૈલી પસંદ કરો, પછી નિષ્કર્ષ કરો.';

  @override
  String get recommendNoLooksTitle => 'આ ટુકડા માટે કોઈ લુક નથી';

  @override
  String get recommendNoLooksBody => 'બીજી શૈલી અથવા બીજા ટુકડા શરૂ કરો.';

  @override
  String get recommendDefaultLook => 'તમારા ટુકડા માટે એક લુક';

  @override
  String get recommendNoPiecesBody => 'આ લુક માટે કોઈ ટુકડા મળ્યા નથી.';

  @override
  String get recommendCityLabel => 'શહેર';

  @override
  String get recommendCheck => 'ચેક કરો';

  @override
  String get recommendWeatherTitle => 'હવેવા કેવું છે?';

  @override
  String get recommendWeatherBody => 'આજની પસંદગી માટે તમારું શહેર દાખલ કરો.';

  @override
  String get recommendWearToday => 'આજે પહેરો';

  @override
  String get recommendWeatherNoPieces =>
      'આ હવામાન માટે તમારા વોર્ડરોબમાં અત્યારે કોઈ ટુકડા નથી.';

  @override
  String get recommendBudgetLabel => 'બજેટ સુધી';

  @override
  String get recommendLooking => 'ખોજી રહ્યા છીએ';

  @override
  String get recommendFindWhatToBuy => 'વેચવા માટે શું શોધો તે શોધો';

  @override
  String get recommendFillGapsTitle => 'ખાલી જગ્યા ભરો';

  @override
  String get recommendFillGapsBody =>
      'એક બજેટ નક્કી કરો અને અમે સૂચવવાનું કહીશું કે તમારા વોર્ડરોબમાં શું ટૂંકું પડે છે.';

  @override
  String get recommendNoGapsTitle => 'કોઈ ખાલી જગ્યા મળી નથી';

  @override
  String get recommendNoGapsBody => 'વધુ બજેટ અથવા બીજો કેટેગરી શરૂ કરો.';

  @override
  String get recommendMoodEveryday => 'દરરોજ';

  @override
  String get recommendMoodBigMeeting => 'મોટી મીટિંગ';

  @override
  String get recommendDayLabel => 'દિવસ';

  @override
  String get recommendReadingStars => 'તારો વાંચન';

  @override
  String get recommendGetMyColours => 'મારે રંગો જુઓ';

  @override
  String get recommendLuckyColoursTitle => 'તમારા શુભ રંગ';

  @override
  String get recommendLuckyColoursBody =>
      'એક દિવસ પસંદ કરો અને અમે તેના માટે રંગો અને પીસ સૂચવીશું.';

  @override
  String get recommendLuckyColoursSection => 'શુભ રંગો';

  @override
  String get recommendAvoidColoursSection => 'એવેડ કરવાના રંગો';

  @override
  String get recommendBirthDateTitle => 'તમારું જન્મતારીખ ઉમેરો';

  @override
  String get recommendBirthDateBody =>
      'રંગો વાંચવા માટે તમારી જન્મતારીખ જરૂર છે.';

  @override
  String get recommendEditProfile => 'પ્રોફાઇલ બદલો';

  @override
  String get recommendNothingThisDay => 'આ દિવસ માટે કંઈ નથી.';

  @override
  String get recommendUnnamedColour => 'નામનથી રંગ';

  @override
  String get recommendFromCloset => 'તમારા ક્લોઝેટમાંથી';

  @override
  String get recommendNoPiecesInColours => 'આ રંગોમાં હજી કોઈ પીસ નથી.';

  @override
  String get recommendOutfitIdeas => 'ઓઉટફિટ ઇદેયા';

  @override
  String get recommendNoOutfitsInColours => 'આ રંગોમાં હજી પૂરું ઓઉટફિટ નથી.';

  @override
  String get recommendDefaultOutfitIdea => 'એક ઓઉટફિટ ઇદેયા';

  @override
  String get recommendPickUpToThree => 'વધુમાં વધુ ત્રણ પીસ પસંદ કરો';

  @override
  String get recommendEmptyClosetBody =>
      'પહેલા થોડા પીસ ઉમેરો, પછી મેચ માટે પાછા આવો.';

  @override
  String get dashboardDressForDay => 'આગામી દિવસ માટે પહેરો.';

  @override
  String get dashboardOutfitOfDay => 'દિવસનું ઓઉટફિટ';

  @override
  String get dashboardFreshLook => 'તાજેતરનું લુક';

  @override
  String get subscriptionManageInStoreTitle => 'સ્ટોરમાં મેનેજ કરો';

  @override
  String get subscriptionManageInStoreBody =>
      'આ પ્લેન સ્ટોર દ્વારા ડેબિટ થાય છે. તેને તમારા સ્ટોર એકાઉન્ટ સેટિંગ્સમાં મેનેજ કરો.';

  @override
  String get subscriptionCancelledTitle => 'સબ્સ્ક્રિપ્શન રદ થયું';

  @override
  String get subscriptionCancelledBody =>
      'તમારો પ્લેન આ બિલિંગ પીરિયડના અંત સુધી સક્રિય રહેશે.';

  @override
  String get subscriptionCancelFailedTitle => 'રદ કરી ન શકાયું';

  @override
  String get subscriptionCouldNotOpenTitle => 'ખોલી ન શકાયું';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'બિલિંગ મેનેજમેન્ટ ખોલી ન શકાયું.';

  @override
  String get subscriptionOpenLinkFailedBody => 'લિંક ખોલી ની શકાતો નથી.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'તમારો લિંક લોડ થઈ શક્યો નથી';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'તમારો રિફરલ લિંક લોડ થઈ શક્યો નથી. ફરી પ્રયાસ કરો.';

  @override
  String get subscriptionReferralCopiedTitle => 'નકલ કરવામાં આવ્યું';

  @override
  String get subscriptionReferralCopiedBody => 'રિફરલ લિંક કોપી કરવામાં આવ્યો.';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI અજમાવો';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI ની સાથે જોડાઓ અને અમે બંનેને Pro નો એક મહિનો મળશે. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'લિંક કોપી થઈ';

  @override
  String get subscriptionShareUnavailableBody =>
      'શેરિંગ ઉપલબ્ધ નથી, તેથી અમે લિંક કોપી કરી છે.';

  @override
  String get subscriptionShareFailedTitle => 'શેર કરી ન શકાતું';

  @override
  String get subscriptionShareFailedBody => 'બદલે રિફરલ પૃષ્ઠથી લિંક કોપી કરો.';

  @override
  String get subscriptionStoreReadyTitle => 'સ્ટોર તૈયાર છે';

  @override
  String get subscriptionStoreReadyBody =>
      'સ્ટોર કિંમતો ઉપલબ્ધ છે. તમે હમણાં અપગ્રેડ કરી શકો છો.';

  @override
  String get purchaseFailedTitle => 'ખરીદી નિષ્ફળ';

  @override
  String get purchaseUnavailableTitle => 'ખરીદી ઉપલબ્ધ નથી';

  @override
  String get purchaseIapUnavailableBody =>
      'આ ડિવાઇસ પર અનુવર્ગ ખરીદીઓ ઉપલબ્ધ નથી.';

  @override
  String get purchasePlanNotAvailableBody =>
      'આ પ્લાન હાલમાં ખરીદી માટે ઉપલબ્ધ નથી.';

  @override
  String get purchasePlanNotInStoreBody =>
      'આ પ્લાન હાલ સ્ટોરમાં ઉપલબ્ધ નથી. કૃપા કરીને ટૂંક સમયમાં ફરી તપાસો.';

  @override
  String get purchaseStartFailedBody =>
      'ખરીદી શરૂ કરી શકાઈ નથી. ફરી પ્રયાસ કરો.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'ચેકઆઉટમાંથી કોઈ ચુકવણી લિંક પાછો આવ્યો નથી.';

  @override
  String get purchasePendingTitle => 'ખરીદી લઈ રહી છે';

  @override
  String get purchasePendingBody =>
      'તમારી ખરીદી મંજૂરીની રાહ જોઈ રહી છે. મંજૂરી થતા જ તમને ઍક્સેસ મળશે.';

  @override
  String get purchaseFailedBody => 'ખરીદી નિષ્ફળ થઈ. ફરી પ્રયાસ કરો.';

  @override
  String get purchaseRestoredTitle => 'પુનઃસ્થાપિત';

  @override
  String get purchaseRestoredBody => 'તમારી ખરીદીઓ પુનઃસ્થાપિત થઈ છે.';

  @override
  String get purchaseActiveTitle => 'સબ્સ્ક્રિપ્શન સક્રિય છે';

  @override
  String get purchaseActiveBody => 'તમારો સબ્સ્ક્રિપ્શન સક્રિય છે. સ્વાગતમ.';

  @override
  String get purchaseSignInRequiredTitle => 'સાઇન ઇન જરૂરી છે';

  @override
  String get purchaseSignInRequiredBody =>
      'તમારી ખરીદી પૂર્ણ કરવા માટે સાઇન ઇન કરો.';

  @override
  String get purchaseErrorTitle => 'ખરીદી ભૂલ';

  @override
  String get purchaseInvalidTransactionBody =>
      'લેવધાવમાં ચકાસી શકાય તેવા ટ્રાન્ઝેક્શન આઈડી સમાવિષ્ટ નહોતું.';

  @override
  String get purchaseVerificationPendingTitle => 'પ્રમાણીકરણ થવાનું રહ્યું છે';

  @override
  String get purchaseVerificationPendingBody =>
      'હવે સ્ટોર સાથે તમારી ખરીદી ચકાસી ન શકાઈ. તે આપમેળે પૂર્ણ થશે અને બીજી વારે ચાર્જ ન થશે.';

  @override
  String get purchaseNotAppliedTitle => 'ખરીદી લાગુ પડી નથી';

  @override
  String get purchaseNotAppliedBody =>
      'તમારી ખરીદી અકાઉન્ટ પર લાગુ પડી નથી. સપોર્ટથી સંપર્ક કરો અને ફરીથી ખરીદી કરવાની ટાળો.';

  @override
  String get purchaseRestoreFailedTitle => 'ફરી મેળવવાનું નિષ્ફળ';

  @override
  String get purchaseRestoreFailedBody =>
      'ખરીદી ફરી મેળવી ન શકાય. ફરી પ્રયાસ કરો.';

  @override
  String get purchaseRecoveredActiveBody => 'તમારો સબ્સ્ક્રિપ્શન ચાલુ છે.';

  @override
  String get purchaseCompleteTitle => 'ખરીદી પૂર્ણ થઈ';

  @override
  String get giftCreateFailedTitle => 'દીસન બનાવી ન શકાય';

  @override
  String get giftClaimFailedTitle => 'દીસન મેળવી ન શકાય';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દીસન આપને',
      one: 'આપને એક દીસન',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 મહિનો',
      '12': '1 વર્ષ',
      'other': '$months મહિના',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining બાકી',
      one: '1 બાકી',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro ના $durationનો હિસ્સો';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender તમને FitCheck Pro નો $duration મોકલ્યો. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient માટે FitCheck Pro ની દીસન';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender માંથી';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient માટે';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender માંથી';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'તમારો પ્રિસંપાદક';

  @override
  String get giftPreviewPlaceholderSender => 'તમે';

  @override
  String get settingsSavedTitle => 'સાચવ્યું';

  @override
  String get settingsNotSavedTitle => 'સાચવ્યું નથી';

  @override
  String get settingsAiChooseProviderBody => 'પ્રદાતા પસંદ કરો.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'કસ્ટમ પ્રદાતા માટે API URL જરૂરી છે.';

  @override
  String get settingsAiKeyRequiredBody => 'API કી દરો.';

  @override
  String get settingsAiSavedBody => 'તમારા AI સેટિંગ્સ સાચવ્યાં છે.';

  @override
  String get settingsAiMissingDetailsTitle => 'વિગતો અપૂર્ણ';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'પરિક્ષણ માટે API URL અને ચેટ મોડેલ દરો.';

  @override
  String get settingsAiKeyNeededTitle => 'API કી જરૂરી છે';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'ટેસ્ટ કરવા માટે તમારી API કી દાખલ કરો. તમારી સચિવાયેલી કી ગોપનીય રહે છે.';

  @override
  String get settingsAiKeyToTestBody =>
      'ટેસ્ટ કરવા માટે તમારી API કી દાખલ કરો.';

  @override
  String get settingsAiConnectedTitle => 'જોડાયેલ';

  @override
  String get settingsAiConnectedBody => 'કનેક્શન કામ કરે છે.';

  @override
  String get settingsAiTestFailedTitle => 'ટેસ્ટ નિષ્ફળ';

  @override
  String get settingsPreferencesSavedBody => 'તમારા પસંદગીઓ સચવાઈ ગઈ છે.';

  @override
  String get settingsPasswordNotChangedTitle => 'પાસવર્ડ બદલાયું નથી';

  @override
  String get settingsOAuthPasswordBody =>
      'આ એકાઉન્ટ Google અથવા Apple વડે સાઇન-ઇન કરે છે. પહેલાં પાસવર્ડ સેટ કરવા માટે \"પાસવર્ડ ભૂલી ગયા?\" વાપરો.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'વર્તમાન પાસવર્ડ ખોટું છે.';

  @override
  String get settingsExportReadyTitle => 'એક્સપોર્ટ તૈયાર છે';

  @override
  String get settingsExportReadyBody =>
      'તમારો ડેટા એક્સપોર્ટ ડાઉનલોડ કરવા માટે તૈયાર છે.';

  @override
  String get settingsLinkCopiedTitle => 'લિંક કોપી થયો';

  @override
  String get settingsExportClipboardBody =>
      'આપણે તમારો બ્રાઉઝર ખૂલી શક્યા નથી, તેથી આપણે ડાઉનલોડ લિંક કોપી કરી. તે ઝડપી કામ કરે છે, તેથી તેને અલસિયાન બ્રાઉઝરમાં પેસ્ટ કરો.';

  @override
  String get settingsExportFailedTitle => 'એક્સપોર્ટ નિષ્ફળ';

  @override
  String get settingsAccountNotDeletedTitle => 'એકાઉન્ટ ડિલીટ થયું નથી';

  @override
  String photoshootPhotoLimit(int max) {
    return 'તમે સુધારેલી $max તસવીરો ઉમેરો શકો છો.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'તસવીર સીમા';

  @override
  String get photoshootAddAtLeastOnePhoto => 'ઓછામાં ઓછી એક તસવીર ઉમેરો.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'કોઈ તસવીરો નથી';

  @override
  String get photoshootDescribeLookBody => 'તમે ઈચ્છો છો તે લુકનું વર્ણન કરો.';

  @override
  String get photoshootPromptNeededTitle => 'પ્રોમ્પ્ટ જરૂરી છે';

  @override
  String get photoshootConsentFeatureLabel => 'AI ફોટોશૂટ';

  @override
  String get photoshootStatusPreparing => 'તમારી તસવીરો તૈયાર કરવામાં આવે છે';

  @override
  String get photoshootStatusGenerating => 'જનરેટ થઈ રહ્યું છે';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'બેચ $current of $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done of $total પૂર્ણ';
  }

  @override
  String get photoshootGenerationFailedBody => 'જનરેશન નિષ્ફળ.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready તૈયાર, $failed નિષ્ફળ.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'ભાગશુદ્ધ પૂર્ણ';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફોટા તૈયાર છે.',
      one: '1 ફોટો તૈયાર છે.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'કોનેક્શન ખવાઈ ગયું છે. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get photoshootCouldNotCancelTitle => 'રદ કરી શકાય નહીં';

  @override
  String get photoshootRetryFailedTitle => 'ફરી પ્રયાસ નિષ્ફળ';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'ફોટો $number તૈયાર છે.';
  }

  @override
  String get photoshootReplacedTitle => 'બદલવામાં આવ્યું';

  @override
  String get photoshootSavedToGalleryBody =>
      'તમારી ગેલેરીમાં સેવ કરવામાં આવ્યું.';

  @override
  String get photoshootSavedTitle => 'સેવ કર્યું';

  @override
  String get photoshootNotSavedTitle => 'સેવ નથી થયું';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'બધા $count ફોટા તમારી ગેલેરીમાં છે.',
      one: '1 ફોટો તમારી ગેલેરીમાં છે.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$total માંથી $saved સેવ થયા.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'કેટલાક ફોટા સેવ નથી થયા';

  @override
  String get tryonConsentFeatureLabel => 'વર્ચ્યુઅલ ટ્રાય-ઓન';

  @override
  String get tryonAvatarUpdatedBody => 'તમારું ફોટો અપડેટ થયું છે.';

  @override
  String get tryonSavedTitle => 'સેવ કર્યું';

  @override
  String get tryonUploadFailedTitle => 'અપલોડ નિષ્ફળ';

  @override
  String get tryonChooseGarmentFirstBody => 'સૌ પ્રથમ કપડાંનું ફોટો પસંદ કરો.';

  @override
  String get tryonNoGarmentTitle => 'કપડાં ઉપલબ્ધ નથી';

  @override
  String get tryonWaitForUploadBody =>
      'તમારા ફોટાના અપલોડ પૂરા થાય એટલે રાહ જુઓ.';

  @override
  String get tryonStillUploadingTitle => 'તોર અપલોડ થઈ રહ્યું છે';

  @override
  String get tryonAddYourPhotoFirstBody => 'સૌ પ્રથમ તમારું ફોટો ઉમેરો.';

  @override
  String get tryonReadyBody => 'તમારું ટ્રાય-ઓન તૈયાર છે.';

  @override
  String get tryonFailedTitle => 'ટ્રાય-ઓન નિષ્ફળ';

  @override
  String get tryonSavedToGalleryBody => 'તમારી ગેલેરીમાં સેવ કરવામાં આવ્યું.';

  @override
  String get tryonNotSavedTitle => 'સેવ નથી થયું';

  @override
  String get calendarEventAddedBody => 'ઘટના ઉમેરાઈ';

  @override
  String get calendarEventPlannedTitle => 'પ્રમાણભૂત';

  @override
  String get calendarEventSavedBody => 'ઘટના સેવ થઈ';

  @override
  String get calendarSavedTitle => 'સેવ કર્યું';

  @override
  String get calendarEventNotSavedTitle => 'ઘટના સેવ નથી થઈ';

  @override
  String get calendarEventRemovedBody => 'ઇવેન્ટ હટાવવામાં આવ્યું';

  @override
  String get calendarEventDeletedTitle => 'ડિલિટ થયું';

  @override
  String get calendarEventNotDeletedTitle => 'ઇવેન્ટ ડિલિટ થઈ શક્યું નહીં';

  @override
  String get calendarOutfitNotLinkedTitle => 'આઉટફિટ લિંક થયું નહીં';

  @override
  String get calendarLinkedTitle => 'લિંક થયું';

  @override
  String get calendarOutfitNotRemovedTitle => 'આઉટફિટ હટાવી શકાયું નહીં';

  @override
  String get calendarOutfitRemovedBody => 'આઉટફિટ હટાવવામાં આવ્યું';

  @override
  String get calendarDisconnectedBody => 'કેલેન્ડર ડિસકનનક્ટ થયું';

  @override
  String get calendarDisconnectedTitle => 'ડિસકનનક્ટ થયું';

  @override
  String get calendarNotDisconnectedTitle =>
      'કેલેન્ડર ડિસકનનક્ટ થઈ શક્યું નહીં';

  @override
  String get calendarTodayLabel => 'આજે';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ઇવેન્ટ',
      one: '1 ઇવેન્ટ',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start થી $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, આઉટફિટ લિંક થયું';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" હટાવવામાં આવશે.';
  }

  @override
  String get calendarThisAppLabel => 'આ એપ્';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider સાથે સિંક કરવા ઉપલબ્ધ નથી. તમે અહીં ઇવેન્ટ ઉમેરો છો.';
  }

  @override
  String get calendarWeekdaySunShort => 'રવિ';

  @override
  String get calendarWeekdayMonShort => 'સોમ';

  @override
  String get calendarWeekdayTueShort => 'મંગ';

  @override
  String get calendarWeekdayWedShort => 'બુધ';

  @override
  String get calendarWeekdayThuShort => 'ગુર';

  @override
  String get calendarWeekdayFriShort => 'શુક';

  @override
  String get calendarWeekdaySatShort => 'શનિ';

  @override
  String get calendarWeekdayMonday => 'સોમવાર';

  @override
  String get calendarWeekdayTuesday => 'મંગળવાર';

  @override
  String get calendarWeekdayWednesday => 'બુધવાર';

  @override
  String get calendarWeekdayThursday => 'ગુરુવાર';

  @override
  String get calendarWeekdayFriday => 'શુક્રવાર';

  @override
  String get calendarWeekdaySaturday => 'શનિવાર';

  @override
  String get calendarWeekdaySunday => 'રવિવાર';

  @override
  String get outfitSavedToFavouritesBody => 'ફેવરિટ્સમાં સાચવ્યું';

  @override
  String get outfitRemovedFromFavouritesBody => 'ફેવરિટ્સમાંથી દૂર કર્યું';

  @override
  String get outfitNotSavedTitle => 'સાચવેલું નથી';

  @override
  String get outfitLoggedAsWornBody => 'આજે પહેર્યું તરીકે નોંધાયું.';

  @override
  String get outfitNicePickTitle => 'સરસ પસંદગી';

  @override
  String get outfitRemovedBody => 'આઉટફિટ દૂર કર્યું.';

  @override
  String get outfitDeletedTitle => 'કાઢી નખે';

  @override
  String get outfitNotDeletedTitle => 'કાઢવામાં આવ્યું નથી';

  @override
  String get outfitDuplicatedBody => 'એક કૉપી તમારા આઉટફિટ્સમાં છે.';

  @override
  String get outfitDuplicatedTitle => 'કૉપિ કર્યું';

  @override
  String get outfitNotDuplicatedTitle => 'કૉપિ થયું નથી';

  @override
  String get outfitNotSharedTitle => 'શેર થયું નથી';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" તૈયાર છે.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'કલેક્શન બન્યું નથી';

  @override
  String get outfitCollectionUpdatedBody => 'કલેક્શન અપડેટ થયું.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'કલેક્શન અપડેટ થયું નથી';

  @override
  String get outfitCollectionDeletedBody => 'કલેક્શન કાઢી નખ્યું.';

  @override
  String get outfitCollectionNotDeletedTitle => 'કલેક્શન કાઢવામાં આવ્યું નથી';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count આઉટફિટ્સ ઉમેરાયા.',
      one: '1 આઉટફિટ ઉમેરાયું.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'આઉટફિટ્સ ઉમેરાયા નથી';

  @override
  String get outfitPreviewNotCreatedTitle => 'પ્રિવ્યૂ બન્યું નથી';

  @override
  String get outfitGiveNameBody => 'આઉટફિટનું નામ આપો.';

  @override
  String get outfitNameMissingTitle => 'નામ';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'ઓછામાં ઓછું એક પીસ પસંદ કરો.';

  @override
  String outfitCreatedBody(String name) {
    return '$name તમારા આઉટફિટ્સમાં છે.';
  }

  @override
  String get outfitSavedTitle => 'સાચવ્યું';

  @override
  String get wardrobeAddedToFavouritesBody => 'ફેવરિટ્સમાં ઉમેરાયું';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'ફેવરિટ્સમાંથી દૂર કર્યું';

  @override
  String get wardrobeNotSavedTitle => 'સેવ થયું નથી';

  @override
  String get wardrobeLoggedAsWornBody => 'આજે પહેરવામાં આવી છે.';

  @override
  String get wardrobeRemovedFromClosetBody =>
      'તમારા ક્લોઝેટમાંથી કાઢી દેવામાં આવ્યું છે.';

  @override
  String get wardrobeDeletedTitle => 'કાઢી નૂકાયું';

  @override
  String get wardrobeNotDeletedTitle => 'કાઢી નૂકાયું નથી';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count આઇટમ્સ તમારા ક્લોઝેટમાંથી કાઢવામાં આવ્યાં.',
      one: '1 આઇટમ તમારા ક્લોઝેટમાંથી કાઢવામાં આવ્યું.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI વોર્ડરોબ ડ્રોર';

  @override
  String get itemAddScanJobLabel => 'સ્કેન';

  @override
  String get itemAddFoundEarlierBody => 'પહેલા સ્કેનમાં મળી';

  @override
  String get itemAddLookingAtPhoto => 'તમારી છબી જુગત કરી રહ્યા છીએ';

  @override
  String get itemAddExtractionFailedBody => 'ડ્રોર ફેલ થયું';

  @override
  String get itemAddJobFailedBody => 'જોબ નિષ્ફળ';

  @override
  String get itemAddConnectionLostBody =>
      'કનેક્શન કાઢી નૂકાયું. ફરી પ્રયાસ કરો.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'પ્રોસેસિંગ દરમિયાન કનેક્શન કાઢી નૂકાયું.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'પીસ $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'પીસ';

  @override
  String get itemAddNotCancelledTitle => 'રદ થયું નથી';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count આઇટમ્સ તમારા ક્લોઝેટમાં છે.',
      one: '1 આઇટમ તમારા ક્લોઝેટમાં છે.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved માંથી $total આઇટમ્સ સેવ થયાં. બાકી રહેલાને ફરી પ્રયાસ કરવાની અમુકિત્તા માટે સેવ અમુકો કરો.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'કેટલાક પીસ સેવ થયાં નથી';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'તેની અમુકિત્તા એક ફોટો પસંદ કરો.';

  @override
  String get batchPhotoUnreadableBody => 'આ ફોટો વાંચી શકાયો નથી.';

  @override
  String get batchNoPhotosReadableBody =>
      'આ ફોટોમાંથી એક પણ વાંચી શકાયો નથી. બીજા ફોટો પ્રયાસ કરો.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફોટો',
      one: '1 ફોટો',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'કામ કરતી વખતે કનેક્શન કાઢી નૂકાયું. ફરી પ્રયાસ કરો.';

  @override
  String get batchNotCancelledTitle => 'રદ થયું નથી';

  @override
  String get batchPostLinkUnsupportedBody =>
      'પોસ્ટ લિંક અમુકિત્તા થતા નથી. પ્રોફાઇલ લિંક દાખલ કરો.';

  @override
  String get batchLinkSpacesBody => 'લિંકમાં અમુકિત્તા રાખી શકાતી નથી.';

  @override
  String get batchEnterProfileLinkBody =>
      'Instagram કે Facebook પ્રોફાઇલ લિંક દાખલ કરો.';

  @override
  String get batchEnterProfileLinkShortBody => 'પ્રોફાઇલ લિંક દાખલ કરો.';

  @override
  String get batchSignInPageNotOpenBody =>
      'સાઇન-ઇન પૃષ્ઠ ખુલ્લો નથી. ફરી પ્રયાસ કરો.';

  @override
  String get batchSignInBrowserBody =>
      'તમારા બ્રાઉઝરમાં સાઇન ઇન કરો, પછી FitCheck પર પાછા આવો.';

  @override
  String get batchConnectAccountTitle => 'તમારું એકાઉન્ટ કોનક્ટ કરો';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'તમારા ઓથન્ટિકેટર એપમાંથી કોડ દાખલ કરો.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram સિક્યુરિટી ચેક જોઈએ છે. પહેલા બ્રાઉઝરમાં સાઇન ઇન કરો.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'તમારું યુઝરનેમ અને પાસવર્ડ ફરી દાખલ કરો.';

  @override
  String get batchSignInFailedBody =>
      'સાઇન-ઇન નિષ્ફળ થયું. તમારું યુઝરનેમ અને પાસવર્ડ ચકાસો.';

  @override
  String get batchSignInToKeepImportingBody =>
      'આમ્પોર્ટ ચાલુ રાખવા માટે સાઇન ઇન કરો.';

  @override
  String get batchAccountNotConnectedBody => 'તમારું એકાઉન્ટ કોનક્ટ થતું નથી.';

  @override
  String get batchAccountConnectedTitle => 'એકાઉન્ટ કોનક્ટ થયું';

  @override
  String get batchNotConnectedTitle => 'કોનક્ટ થયું નથી';

  @override
  String get batchImportConnectionLostBody =>
      'આમ્પોર્ટ સાથે કનેક્શન ખોવાઈ ગયું છે. ચકાસવા માટે રિફ્રેશ કરો.';

  @override
  String batchPickUpToBody(int max) {
    return '$max ફોટોસ પસંદ કરો. અમે પાર્સ શોધીએ છીએ.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count નીચેના $total ફોટોમાંથી';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'ફોટો $done of $count તૈયાર કરી રહ્યાં છીએ';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફોટોમાં પાર્સ શોધો',
      one: '1 ફોટોમાં પાર્સ શોધો',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'તમારું $platform એકાઉન્ટ ટુ-સ્ટેપ સાઇન-ઇન ઉપયોગ કરે છે. તમારા ઓથન્ટિકેટર એપમાંથી 6-અંકનો કોડ દાખલ કરો.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'આ $platform પ્રોફાઇલ ખાનગી છે અથવા તેના ફોટોના દૃશ્યની માટે સાઇન-ઇન જોઈએ છે.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform સાથે કોનક્ટ કરો';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'હાલમાં $count ફોટો મળ્યા છે',
      one: 'હાલમાં 1 ફોટો મળ્યો છે',
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
    return '$processed of $total પ્રોસેસ થયાં · $added ઉમેર્યાં · $waiting રાહ · $skipped ચૂકવ્યાં';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'ફોટો $number સ્કેન કરી રહ્યાં છીએ';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'ફોટો $number આગળ છે';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'ફોટો $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પાર્સ મળ્યાં',
      one: '1 પાર્સ મળ્યું',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ફોટો તમારા ક્લોઝેટમાં ઉમેરવામાં આવ્યાં છે.',
      one: '1 ફોટો તમારા ક્લોઝેટમાં ઉમેરવામાં આવ્યો છે.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count વધુ સ્ટુડિયો ફોટો રસ્તામાં છે. તમે જે તૈયાર છે તે સેવ કરી શકો, અથવા છોડી દો — અમે તમને જણાવીશું.',
      one:
          '1 વધુ સ્ટુડિયો ફોટો રસ્તામાં છે. તમે જે તૈયાર છે તે સેવ કરી શકો, અથવા છોડી દો — અમે તમને જણાવીશું.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'હજી સેવ થયું નથી: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces પાર્સ',
      one: '1 પાર્સ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos ફોટો',
      one: '1 ફોટો',
    );
    return '$_temp0 $_temp1 થી';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen પસંદ કર્યું છે. પાર્સને સ્કિપ કરવા માટે ટેપ કરો.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પીસ સાવંધાય છે',
      one: '1 પીસ સાવંધાય છે',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count પીસ સાવડાવો',
      one: '1 પીસ સાવડાવો',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'તમારો બોડી પ્રોફાઇલ સાવધાય છે.';

  @override
  String get bodyProfileSavedTitle => 'સાવધાયું';

  @override
  String get bodyProfileNotSavedTitle => 'સાવધાયું નથી';

  @override
  String get bodyProfileSetDefaultBody =>
      'આ તમારો ડિફૉલ્ટ પ્રોફાઇલ તરીકે સેટ કરો.';

  @override
  String get bodyProfileDeletedBody => 'બોડી પ્રોફાઇલ ડિલીટ કરવામાં આવી છે.';

  @override
  String get bodyProfileDeletedTitle => 'ડિલીટ થયું';

  @override
  String get bodyProfileNotDeletedTitle => 'ડિલીટ થયું નથી';

  @override
  String get feedbackNotSentTitle => 'મોકલ્યું નથી';

  @override
  String get feedbackSentBody =>
      'આભાર. અમે દરેક સંદેશ વાંચીએ છીએ અને જરૂર પડે તો જવાબ આપીએ છીએ.';

  @override
  String get feedbackSentTitle => 'ફિડબેક મોકલ્યું';

  @override
  String get recommendUnnamedPiece => 'નામ રહેલો પીસ';

  @override
  String get recommendEnterCityBody =>
      'હવામાન માટે પિક્સ મેળવવા તમારો શહેર દાખલ કરો.';

  @override
  String get recommendWhichCityTitle => 'કયો શહેર?';

  @override
  String get aiConsentSheetTitle => 'AI સર્વિસ સાથે ફોટો શેર કરવા';

  @override
  String get aiConsentSheetBody =>
      'તમારી try-on અને ફોટોશૂટ ઇમેજ બનાવવા માટે, FitCheck AI તમે પ્રદાન કરેલા ફોટો (તમારા મુખ અને શરીરની ઇમેજો સહિત) એક વિશ્વસનીય થર્ડ-પાર્ટી AI પ્રોવાઈડર (જેમ કે OpenAI અથવા Google Gemini) પાસે પ્રોસેસિંગ માટે મોકલે છે. તેઓ તમારી ઇમેજ બનાવે છે અને અમારા શરતો અંતર્ગત તેમના મોડેલોને ટ્રેન કરવા માટે ઉપયોગ નથી કરતા. ફોટો સુરક્ષિત રીતે ટ્રાન્સમિટ થાય છે અને જાહેરાત માટે ક્યારેય શેર થતા નથી.';

  @override
  String get aiConsentSheetPermission =>
      'ચાલુ રાખવાથી, તમે ઇમેજ જનરેશન માટે તમારા ફોટો આ AI પ્રોવાઈડર્સ સાથે શેર કરવાની સ્પષ્ટ પરવાનગી આપો છો.';

  @override
  String get skeletonsLoadMoreFailed => 'વધુ લોડ થયું નથી.';

  @override
  String get jobsPiecesReadyTitle => 'તમારા પીસ તૈયાર છે';

  @override
  String get jobsScanStoppedTitle => 'સ્કેન બંધ થઈ ગયું';

  @override
  String get jobsNothingSavedBody => 'કંઈક સાવધાયું નથી. ફરી પ્રયાસ કરો.';

  @override
  String get jobsPhotoUploadFailedBody => 'ફોટો અપલોડ નિષ્ફળ થયું.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google સિન-ઇન શરૂ કરી ન શકાયું. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get referralAppliedTitle => 'રિફરલ લાગુ પડ્યું!';

  @override
  String get billingStoreUnavailableBody =>
      'આ ડિવાઇસ પર સ્ટોર ખરીદી ઉપલબ્ધ નથી.';

  @override
  String get billingPurchaseProcessingBody =>
      'આ ખરીદી હજી પ્રોસેસ થઈ રહી છે. એક મિનિટમાં એપ ફરી ખોલો અને તમારો પ્લાન જુઓ.';

  @override
  String get profileAvatarUploadNoUrl =>
      'એવેટર અપલોડે કોઈ ઇમેજ URL પરત કર્યું નથી.';

  @override
  String get rewardsDayStreakLabel => 'દિવસ સ્ટ્રીક';

  @override
  String rewardsBestStreak(int days) {
    return 'સૌથી શ્રેષ્ઠ $days દિવસ';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission ની ઍક્સેસ જરૂરી છે';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'વર્તમાન $permission ની ઍક્સેસ નકારવામાં આવી છે. તેને સક્રિય કરવા માટે Settings ખોલો, પછી પાછા આવીને ફરી પ્રયાસ કરો.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'પગલું $step / 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'પગલું $step / $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'ચિત્ર દૂર કરો $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'ચિત્ર દૂર કરો $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points પોઇન્ટ';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '$email પર ઇમેઇલ કરો. અમે ૨૪ કલાકમાં રિપોર્ટનું વાંચન કરીએ છીએ.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece દૂર કરો';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '«$name» કાઢી નાખવું?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '«$name» માં ઉમેરો';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '«$name» દૂર કરવામાં આવ્યું છે. તેના વસ્ત્રો તમારા કલોઝેટમાં જ રહેશે.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'બધા $count બતાવો';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'આજે $count બાકી';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'ફોટો $index નિષ્ફળ';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max ફોટાઓમાંથી $selected પસંદ';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape બિલ્ડ · $tone ત્વચા';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name કાઢી નાખવું?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name માટે વિકલ્પો';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'સૌથી વધુ પહેરેલું: $name, $count વાર';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: સેટ નથી';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% મેચ';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max માંથી $picked પસંદ કર્યા';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item દૂર કરો';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency પ્રાદ્ધત્વ';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'આ પ્લાન $store દ્વારા મૂલ્યાંકિત થાય છે. તેમાં ફેરફાર કે રદ કરવા માટે તમારા $store એકાઉન્ટ સેટિંગ્સ ખોલો.';
  }

  @override
  String billingManageInStore(String store) {
    return '$store માં મેનેજ કરો';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max માંથી $current વપરાયું';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'લગભગ ${seconds}s બાકી';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$totalમાંથી $done સ્ટુડિયો ફોટાઓ તૈયાર';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready / $total સ્ટુડિયો ફોટો તૈયાર છે. બહાર રાખવા માટે કોઈ પણ ટકો.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height સેમી · $weight કિગ્રા';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'ના';
}
