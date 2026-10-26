// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'முகப்பு';

  @override
  String get tabPhotoshoot => 'புகைப்படம்';

  @override
  String get tabCloset => 'அலமாரி';

  @override
  String get tabOutfits => 'உடை தொகுப்பு';

  @override
  String get tabMore => 'மேலும்';

  @override
  String get actionAddItem => 'பொருளைச் சேர்';

  @override
  String get actionCreateOutfit => 'உடை உருவாக்கு';

  @override
  String get actionCancel => 'ரத்து செய்';

  @override
  String get actionDelete => 'நீக்கு';

  @override
  String get actionSave => 'சேமி';

  @override
  String get actionRetry => 'மீண்டும் முயற்சி';

  @override
  String get actionDone => 'முடிந்தது';

  @override
  String get actionNext => 'அடுத்து';

  @override
  String get actionBack => 'பின்';

  @override
  String get actionClose => 'மூடு';

  @override
  String get actionSearch => 'தேடு';

  @override
  String get actionContinue => 'தொடரவும்';

  @override
  String get stateLoading => 'ஏற்றப்படுகிறது';

  @override
  String get stateErrorTitle => 'ஏதோ தவறு நடந்துள்ளது';

  @override
  String get stateErrorBody =>
      'மீண்டும் முயற்சிக்கவும். தொடர்ந்து தோல்வியுற்றால், ஆதரவைத் தொடர்பு கொள்ளவும்.';

  @override
  String get stateOfflineTitle => 'இணைய இணைப்பு இல்லை';

  @override
  String get stateOfflineBody =>
      'உங்கள் அலமாரியை ஒத்திசைக்க மற்றும் உடை தொகுப்புகளை உருவாக்க மீண்டும் இணையத்தில் இணையவும்.';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get settingsAccountSection => 'கணக்கு';

  @override
  String get settingsPreferencesSection => 'விருப்பத்தேர்வுகள்';

  @override
  String get settingsPlanBilling => 'திட்டம் மற்றும் கட்டணம்';

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get settingsNotifications => 'அறிவிப்புகள்';

  @override
  String get settingsUnits => 'அளவீட்டு அலகுகள்';

  @override
  String get settingsAppearance => 'தோற்றம்';

  @override
  String get settingsPrivacySection => 'தனியுரிமை மற்றும் தரவு';

  @override
  String get settingsAboutSection => 'பற்றி';

  @override
  String get settingsSignOut => 'வெளியேறு';

  @override
  String get settingsDeleteAccount => 'கணக்கை நீக்கு';

  @override
  String get settingsDeleteAccountTitle => 'உங்கள் கணக்கை நீக்கவா?';

  @override
  String get settingsDeleteAccountBody =>
      'இது உங்கள் அலமாரி, உடைகள், புகைப்படங்கள் மற்றும் சுயவிவரத்தை நீக்கும். இதை மாற்ற முடியாது.';

  @override
  String get settingsUnitsImperial => 'இம்பீரியல் (in, lb)';

  @override
  String get settingsUnitsMetric => 'மெட்ரிக் (cm, kg)';

  @override
  String get languageTitle => 'மொழி';

  @override
  String get languageSystem => 'சாதன மொழியைப் பயன்படுத்து';

  @override
  String get languageSystemBody =>
      'FitCheck AI உங்கள் தொலைபேசியின் மொழியைப் பின்பற்றும்.';

  @override
  String get languageSearchHint => 'மொழிகளைத் தேடு';

  @override
  String get languageCurrent => 'தற்போதைய';

  @override
  String get languageReviewNote =>
      'இந்த மொழிபெயர்ப்பு புதியது. ஏதேனும் தவறாக இருந்தால் எங்களிடம் கூறுங்கள்.';

  @override
  String get languageChanged => 'மொழி புதுப்பிக்கப்பட்டது';

  @override
  String get paywallTitle => 'உங்கள் திட்டத்தைத் தேர்வு செய்யவும்';

  @override
  String get paywallTrialBadge => '1 மாதம் இலவசம்';

  @override
  String get paywallTrialTitle => 'உங்கள் முதல் மாத Pro இலவசம்';

  @override
  String get paywallTrialBody =>
      'உங்கள் முழு அலமாரியையும் ஒரே நேரத்தில் பதிவேற்றவும். அதன் பிறகு துண்டுகளைச் சேர்க்கவும்.';

  @override
  String get paywallFreeForeverTitle => 'எப்போதும் இலவசம்';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'அட்டை தேவையில்லை. ஒவ்வொரு மாதமும் உங்களுக்கு $uploads AI பதிவேற்றங்கள், $outfits உடைகள் மற்றும் $images புகைப்படங்கள் ஒரு நாளைக்குக் கிடைக்கும்.';
  }

  @override
  String get paywallCtaTrial => 'எனது இலவச மாதத்தைத் தொடங்கு';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan திட்டத்திற்கு மேம்படுத்து';
  }

  @override
  String get paywallRestore => 'கொள்முதல்களை மீட்டமை';

  @override
  String get paywallManage => 'சந்தாவை நிர்வகி';

  @override
  String get paywallTerms => 'பயன்பாட்டு விதிமுறைகள்';

  @override
  String get paywallPrivacy => 'தனியுரிமைக் கொள்கை';

  @override
  String get paywallPerMonth => 'மாதத்திற்கு';

  @override
  String get paywallPerYear => 'ஆண்டிற்கு';

  @override
  String get paywallBestValue => 'சிறந்த மதிப்பு';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'புதிய சந்தாதாரர்களுக்கு மட்டுமே இலவச சோதனை. சோதனை முடிந்ததும், $price விலையில் Pro தானாகவே புதுப்பிக்கப்படும், குறைந்தது 24 மணிநேரத்திற்கு முன் ரத்து செய்யப்படாவிட்டால்.';
  }

  @override
  String get introTitle => 'உங்கள் அலமாரி, இறுதியாக ஒழுங்கமைக்கப்பட்டது';

  @override
  String get introBody =>
      'உங்கள் ஆடைகளை ஒருமுறை புகைப்படம் எடுங்கள். உங்களிடம் உள்ளவற்றிலிருந்து ஆடை யோசனைகள், அணிந்து பார்க்கும் முன்னோட்டங்கள் மற்றும் ஸ்டுடியோ புகைப்படங்களைப் பெறுங்கள்.';

  @override
  String get introStart => 'தொடங்குங்கள்';

  @override
  String get introHaveAccount => 'ஏற்கனவே கணக்கு உள்ளது';

  @override
  String get introSkip => 'தவிர்க்கவும்';

  @override
  String get authSignIn => 'உள்நுழைய';

  @override
  String get authSignUp => 'கணக்கை உருவாக்கு';

  @override
  String get authEmail => 'மின்னஞ்சல்';

  @override
  String get authPassword => 'கடவுச்சொல்';

  @override
  String get authForgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get authContinueApple => 'Apple மூலம் தொடரவும்';

  @override
  String get authContinueGoogle => 'Google மூலம் தொடரவும்';

  @override
  String get authOrDivider => 'அல்லது';

  @override
  String get wardrobeTitle => 'அலமாரி';

  @override
  String get wardrobeEmptyTitle => 'உங்கள் அலமாரி காலியாக உள்ளது';

  @override
  String get wardrobeEmptyBody =>
      'உங்கள் முதல் ஆடையைச் சேர்க்கவும் அல்லது முழு அலமாரியின் புகைப்படத்தைப் பதிவேற்றவும்.';

  @override
  String get wardrobeAddFirst => 'முதல் பொருளைச் சேர்க்கவும்';

  @override
  String get wardrobeSearchHint => 'உங்கள் அலமாரியில் தேடுங்கள்';

  @override
  String get categoryTops => 'மேல் ஆடைகள்';

  @override
  String get categoryBottoms => 'கீழ் ஆடைகள்';

  @override
  String get categoryShoes => 'காலணிகள்';

  @override
  String get categoryAccessories => 'துணைக்கருவிகள்';

  @override
  String get categoryOuterwear => 'வெளிப்புற ஆடைகள்';

  @override
  String get categorySwimwear => 'நீச்சல் ஆடைகள்';

  @override
  String get categoryActivewear => 'விளையாட்டு ஆடைகள்';

  @override
  String get categoryOther => 'பிற';

  @override
  String get conditionClean => 'சுத்தம்';

  @override
  String get conditionDirty => 'அழுக்கு';

  @override
  String get conditionLaundry => 'துவைக்க வேண்டியவை';

  @override
  String get conditionRepair => 'பழுது தேவை';

  @override
  String get conditionDonate => 'தானம் செய்ய';

  @override
  String get seasonSpring => 'வசந்த காலம்';

  @override
  String get seasonSummer => 'கோடை காலம்';

  @override
  String get seasonFall => 'இலையுதிர் காலம்';

  @override
  String get seasonWinter => 'குளிர் காலம்';

  @override
  String get seasonAll => 'அனைத்து பருவம்';

  @override
  String get styleCasual => 'சாதாரண உடை';

  @override
  String get styleFormal => 'அலுவலக உடை';

  @override
  String get styleBusiness => 'தொழில்முறை';

  @override
  String get styleSporty => 'விளையாட்டு';

  @override
  String get styleBohemian => 'போஹேமியன்';

  @override
  String get styleStreetwear => 'தெரு உடை';

  @override
  String get styleVintage => 'பழங்கால பாணி';

  @override
  String get styleMinimalist => 'குறைந்தபட்சம்';

  @override
  String get styleRomantic => 'காதல் பாணி';

  @override
  String get styleEdgy => 'நவீன பாணி';

  @override
  String get stylePreppy => 'பிரெப்பி';

  @override
  String get styleArtsy => 'கலைநயம்';

  @override
  String get styleClassic => 'கிளாசிக்';

  @override
  String get styleElegant => 'நேர்த்தியான';

  @override
  String get styleOther => 'பிற';

  @override
  String get occasionWork => 'வேலை';

  @override
  String get occasionDateNight => 'டேட் நைட்';

  @override
  String get occasionTravel => 'பயணம்';

  @override
  String get occasionWedding => 'திருமணம்';

  @override
  String get occasionGym => 'ஜிம்';

  @override
  String get occasionWeekend => 'வார இறுதி';

  @override
  String get occasionParty => 'விருந்து';

  @override
  String get occasionInterview => 'நேர்காணல்';

  @override
  String get colorBlack => 'கருப்பு';

  @override
  String get colorWhite => 'வெள்ளை';

  @override
  String get colorGrey => 'சாம்பல்';

  @override
  String get colorNavy => 'நேவி';

  @override
  String get colorBrown => 'பழுப்பு';

  @override
  String get colorRed => 'சிவப்பு';

  @override
  String get colorBlue => 'நீலம்';

  @override
  String get colorGreen => 'பச்சை';

  @override
  String get colorPink => 'இளஞ்சிவப்பு';

  @override
  String get colorPurple => 'ஊதா';

  @override
  String get colorYellow => 'மஞ்சள்';

  @override
  String get colorOrange => 'ஆரஞ்சு';

  @override
  String get colorBeige => 'பீஜ்';

  @override
  String get dateToday => 'இன்று';

  @override
  String get dateYesterday => 'நேற்று';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்கள் முன்பு',
      one: '1 நாள் முன்பு',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count வாரங்கள் முன்பு',
      one: '1 வாரம் முன்பு',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count மாதங்கள் முன்பு',
      one: '1 மாதம் முன்பு',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count வருடங்கள் முன்பு',
      one: '1 வருடம் முன்பு',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI பிடித்துள்ளதா?';

  @override
  String get ratingPromptBody =>
      'ஒரு மதிப்பீடு மற்றவர்கள் தங்கள் ஸ்டைலைக் கண்டறிய உதவும்.';

  @override
  String get ratingPromptYes => 'மதிப்பீடு செய்க';

  @override
  String get ratingPromptNo => 'இப்போது வேண்டாம்';

  @override
  String get closetNoMatchesTitle => 'பொருத்தங்கள் இல்லை';

  @override
  String get closetNoMatchesBody =>
      'குறைவான வடிப்பான்களைப் பயன்படுத்தவும் அல்லது தேடலை மாற்றவும்.';

  @override
  String get closetClearFilters => 'வடிப்பான்களை நீக்கு';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உடைகள்',
      one: '1 உடை',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'உடைகளை ஏற்றுகிறது';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count தேர்ந்தெடுக்கப்பட்டன',
      one: '1 தேர்ந்தெடுக்கப்பட்டது',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'தேர்ந்தெடுத்ததை நீக்கு';

  @override
  String get closetCancelSelection => 'தேர்வை ரத்து செய்';

  @override
  String get closetCloseSearch => 'தேடலை மூடு';

  @override
  String get closetShowGrid => 'கட்டமாக காட்டு';

  @override
  String get closetShowList => 'பட்டியலாக காட்டு';

  @override
  String get closetShowRows => 'வரிசைகளாக காட்டு';

  @override
  String get closetStatsTitle => 'அலமாரி புள்ளிவிவரம்';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count துணிகளை நீக்கவா?',
      one: '1 துணியை நீக்கவா?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'இவற்றைப் பயன்படுத்தும் உடைகள் இந்தத் துணிகளை இழக்கும்.';

  @override
  String get closetSortBy => 'வரிசைப்படுத்து';

  @override
  String get closetFavourites => 'பிடித்தவை';

  @override
  String get closetFavourite => 'பிடித்ததாக மாற்று';

  @override
  String get closetUnfavourite => 'பிடித்தவற்றிலிருந்து நீக்கு';

  @override
  String get closetWoreToday => 'இன்று அணிந்தேன்';

  @override
  String closetWornTimes(int count) {
    return '$count முறை அணிந்தது';
  }

  @override
  String get closetCategoryLabel => 'வகை';

  @override
  String get closetUseCaseLabel => 'பயன்பாடு';

  @override
  String get closetAnyUseCase => 'எதுவும்';

  @override
  String get closetOtherUseCase => 'பிற பயன்பாடு';

  @override
  String get closetOtherUseCaseHint => 'உதாரணமாக, மதிய உணவு';

  @override
  String get closetUseUseCase => 'இதைப் பயன்படுத்து';

  @override
  String get closetClearAll => 'அனைத்தையும் நீக்கு';

  @override
  String get sortNewest => 'புதியவை முதலில்';

  @override
  String get sortOldest => 'பழையவை முதலில்';

  @override
  String get sortName => 'பெயர் (அ-ஆ)';

  @override
  String get sortMostWorn => 'அதிகம் அணிந்தது';

  @override
  String get useCaseInformal => 'சாதாரண நிகழ்வு';

  @override
  String get useCaseDate => 'தேதி';

  @override
  String get useCaseDinner => 'இரவு உணவு';

  @override
  String get useCaseLunch => 'மதிய உணவு';

  @override
  String get actionSelect => 'தேர்ந்தெடு';

  @override
  String get actionEdit => 'திருத்து';

  @override
  String get actionFilter => 'வடிகட்டி';

  @override
  String get actionSort => 'வரிசைப்படுத்து';

  @override
  String get actionAll => 'அனைத்தும்';

  @override
  String get dashboardStartClosetTitle => 'உங்கள் அலமாரியைத் தொடங்குங்கள்';

  @override
  String get dashboardStartClosetBody =>
      'சில ஆடைகளை புகைப்படம் எடுங்கள். நாங்கள் அவற்றை வகைப்படுத்துகிறோம்.';

  @override
  String get dashboardPieces => 'துணிகள்';

  @override
  String get dashboardOutfits => 'உடை அமைப்புகள்';

  @override
  String get dashboardDayStreak => 'தொடர் நாட்கள்';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'இந்த மாதம் +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'சிறந்த $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count விருப்பமான உடைகள்',
      one: '1 விருப்பமான உடை',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count சேமித்த உடைகள்',
      one: '1 சேமித்த உடை',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'அதிகம் அணிந்தது: $name, $count முறை';
  }

  @override
  String get setupSkip => 'அமைப்பைத் தவிர்க்கவும்';

  @override
  String get setupWhoTitle => 'யாருக்கு ஸ்டைல் செய்வது?';

  @override
  String get setupWhoBody =>
      'ட்ரை-ஆன் மற்றும் போட்டோஷூட்டிற்கான மாடலைத் தேர்வு செய்யவும். இதை உங்கள் சுயவிவரத்தில் மாற்றலாம்.';

  @override
  String get setupStyleTitle => 'நீங்கள் எதை அதிகம் அணிகிறீர்கள்?';

  @override
  String get setupStyleBody =>
      'ஏதேனும் ஒன்றைத் தேர்வு செய்யவும். இதிலிருந்து உடை யோசனைகள் தொடங்கும்.';

  @override
  String get setupClosetTitle => 'உங்கள் முதல் ஆடைகளைச் சேர்க்கவும்.';

  @override
  String get setupClosetBody =>
      'சில ஆடைகளை அல்லது குவியலாக புகைப்படம் எடுங்கள். ஒவ்வொரு துணியும் உங்களுக்காகத் தனியாகப் பிரிக்கப்படும்.';

  @override
  String get setupAddClothes => 'ஆடைகளைச் சேர்க்கவும்';

  @override
  String get setupStylesLabel => 'ஸ்டைல்கள்';

  @override
  String get setupOccasionsLabel => 'சந்தர்ப்பங்கள்';

  @override
  String get setupSkipStep => 'தவிர்';

  @override
  String get setupLater => 'பிறகு';

  @override
  String get setupSaveError => 'சேமிக்க முடியவில்லை';

  @override
  String get genderWomen => 'பெண்கள்';

  @override
  String get genderMen => 'ஆண்கள்';

  @override
  String get genderNonBinary => 'இருபாலினத்தவர்';

  @override
  String get genderPreferNotToSay => 'கூற விரும்பவில்லை';

  @override
  String get outfitEmptyTitle => 'ஆடைகள் இல்லை';

  @override
  String get outfitEmptyBody =>
      'உங்கள் அலமாரியில் உள்ள ஆடைகளை இணைத்து சேமிக்கவும்.';

  @override
  String get outfitNoMatchesTitle => 'பொருத்தமான ஆடைகள் இல்லை';

  @override
  String get outfitSearchHint => 'ஆடைகளைத் தேடுங்கள்';

  @override
  String get outfitLoading => 'ஆடைகள் ஏற்றப்படுகின்றன';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உடைகள்',
      one: '1 உடை',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'ஸ்டைல் மற்றும் பருவம்';

  @override
  String get outfitCollections => 'தொகுப்புகள்';

  @override
  String get outfitDuplicate => 'நகல்';

  @override
  String get outfitDeleteTitle => 'இந்த உடையை நீக்கவா?';

  @override
  String get outfitDeleteBody => 'இதன் பாகங்கள் உங்கள் அலமாரியில் இருக்கும்.';

  @override
  String get outfitDrafts => 'வரைவுகள்';

  @override
  String get outfitDraft => 'வரைவு';

  @override
  String get filterStyle => 'ஸ்டைல்';

  @override
  String get filterSeason => 'பருவம்';

  @override
  String get itemDetailDeleteTitle => 'இந்த உடையை நீக்கவா?';

  @override
  String get itemDetailDeleteBody =>
      'இதைப் பயன்படுத்தும் உடைகளில் இது நீக்கப்படும்.';

  @override
  String get itemAddFavourite => 'பிடித்தவையில் சேர்';

  @override
  String itemSize(String size) {
    return 'அளவு $size';
  }

  @override
  String get itemColours => 'நிறங்கள்';

  @override
  String get itemMaterial => 'பொருள்';

  @override
  String get itemPattern => 'வடிவம்';

  @override
  String get itemUseCases => 'பயன்பாடு';

  @override
  String get itemKeptIn => 'சேமிக்கப்பட்ட இடம்';

  @override
  String get itemPrice => 'விலை';

  @override
  String get itemBought => 'வாங்கப்பட்டது';

  @override
  String get itemTags => 'குறிச்சொற்கள்';

  @override
  String get itemAdded => 'சேர்க்கப்பட்டது';

  @override
  String get itemTimesWornLabel => 'அணிந்த முறை';

  @override
  String get itemLastWornLabel => 'கடைசியாக அணிந்தது';

  @override
  String get itemNeverWorn => 'ஒருமுறை கூட இல்லை';

  @override
  String get authEntryBody =>
      'உங்களிடம் உள்ள ஒவ்வொரு ஆடையையும் AI மூலம் வடிவமைக்கவும். ஆடைகளைத் திட்டமிடுங்கள், அணிந்து பாருங்கள், புகைப்படம் எடுங்கள்.';

  @override
  String get authCreateCloset => 'உங்கள் அலமாரியை உருவாக்குங்கள்';

  @override
  String get authWelcomeBack => 'மீண்டும் வருக';

  @override
  String get authSignInBody => 'உங்கள் அலமாரியைத் திறக்க உள்நுழையவும்.';

  @override
  String get authCreateAccount => 'கணக்கை உருவாக்குங்கள்';

  @override
  String get authCreateClosetBody =>
      'இது ஒரு நிமிடம் எடுக்கும். உங்கள் முதல் ஆடைகள் இலவசம்.';

  @override
  String get authName => 'பெயர்';

  @override
  String get authConfirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get authReferralCode => 'பரிந்துரை குறியீடு (விருப்பத்தேர்வு)';

  @override
  String get authResetTitle => 'கடவுச்சொல்லை மாற்றவும்';

  @override
  String get authResetBody =>
      'புதிய கடவுச்சொல்லை உருவாக்க மின்னஞ்சல் மூலம் இணைப்பை அனுப்புவோம்.';

  @override
  String get authSendResetLink => 'இணைப்பை அனுப்பு';

  @override
  String get authBackToSignIn => 'உள்நுழைய திரும்பு';

  @override
  String get authEnterEmail => 'மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get authEnterValidEmail => 'சரியான மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get authEnterPassword => 'கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get authPasswordTooShort => 'குறைந்தது 6 எழுத்துக்கள்';

  @override
  String get authShowPassword => 'கடவுச்சொல்லைக் காட்டு';

  @override
  String get authHidePassword => 'கடவுச்சொல்லை மறை';

  @override
  String get authNewHere => 'புதிதாக வந்தவரா?';

  @override
  String authConfirmEmail(String email) {
    return 'உள்நுழையும் முன் $email-ஐ உறுதிப்படுத்தவும். உங்கள் இன்பாக்ஸைச் சரிபார்க்கவும்.';
  }

  @override
  String get authResendEmail => 'மீண்டும் அனுப்பு';

  @override
  String get authResendingEmail => 'அனுப்பப்படுகிறது…';

  @override
  String get authPasswordsDoNotMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get authEnterName => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get authChoosePassword => 'கடவுச்சொல்லைத் தேர்வு செய்யவும்';

  @override
  String get authHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா?';

  @override
  String get authCodeAccepted => 'குறியீடு ஏற்கப்பட்டது';

  @override
  String get authCodeNotFound => 'குறியீடு கிடைக்கவில்லை';

  @override
  String authReferralFrom(String name) {
    return '$name மூலம். இருவருக்கும் ஒரு மாதம் இலவசம்.';
  }

  @override
  String get authReferralInvalid => 'இந்தக் குறியீட்டைக் கண்டறிய முடியவில்லை.';

  @override
  String authResetSent(String email) {
    return '$email-க்கு அனுப்பப்பட்டது. இந்தத் தொலைபேசியில் இணைப்பைத் திறக்கவும்.';
  }

  @override
  String get introSlide1Title => 'உங்கள் அலமாரியை ஒருமுறை புகைப்படம் எடுங்கள்.';

  @override
  String get introSlide1Body =>
      'துணிகளைப் புகைப்படம் எடுங்கள். ஒவ்வொரு துணியும் உங்களுக்காகத் தனித்தனியாகப் பிரிக்கப்படும்.';

  @override
  String get introSlide2Title => 'விரைவாகத் தயாராகுங்கள்.';

  @override
  String get introSlide2Body =>
      'உங்கள் திட்டங்கள் மற்றும் வானிலைக்கு ஏற்ப, உங்களிடம் உள்ள துணிகளைக் கொண்டு ஆடைகளைத் தேர்வு செய்யுங்கள்.';

  @override
  String get introSlide3Title => 'அணியும் முன்பே பாருங்கள்.';

  @override
  String get introSlide3Body =>
      'உங்கள் புகைப்படத்தில் ஆடைகளைப் பொருத்திப் பாருங்கள் அல்லது ஸ்டைலாகப் புகைப்படம் எடுங்கள்.';

  @override
  String get settingsTheme => 'தீம்';

  @override
  String get settingsThemeSystem => 'சிஸ்டம்';

  @override
  String get settingsThemeLight => 'லைட்';

  @override
  String get settingsThemeDark => 'டார்க்';

  @override
  String get settingsTemperature => 'வெப்பநிலை';

  @override
  String get settingsEmailUpdates => 'மின்னஞ்சல் அறிவிப்புகள்';

  @override
  String get settingsEmailUpdatesBody => 'செய்திகள் மற்றும் குறிப்புகள்';

  @override
  String get settingsOutfitReminders => 'ஆடை நினைவூட்டல்கள்';

  @override
  String get settingsOutfitRemindersBody =>
      'நீங்கள் அணிந்ததை உள்ளிட நினைவூட்டல்';

  @override
  String get settingsWeeklySummary => 'வாராந்திரச் சுருக்கம்';

  @override
  String get settingsWeeklySummaryBody => 'உங்கள் வாராந்திர ஆடைத் தொகுப்பு';

  @override
  String get settingsStyleSection => 'ஸ்டைல்';

  @override
  String get settingsPreferredStyles => 'பிடித்த ஸ்டைல்கள்';

  @override
  String get settingsPreferredColours => 'பிடித்த நிறங்கள்';

  @override
  String get settingsNoneChosen => 'எதுவும் தேர்ந்தெடுக்கப்படவில்லை';

  @override
  String get settingsPlanAiSection => 'பிளான் மற்றும் AI';

  @override
  String get settingsPlanBillingBody =>
      'பிளான், பயன்பாடு மற்றும் மேம்படுத்தல்கள்';

  @override
  String get settingsPlanUsageBody => 'பிளான் மற்றும் பயன்பாடு';

  @override
  String get settingsInviteFriends => 'நண்பர்களை அழையுங்கள்';

  @override
  String get settingsInviteFriendsBody =>
      'இணையும் ஒவ்வொரு நண்பருக்கும் ஒரு மாதம் இலவசம்';

  @override
  String get settingsAiProvider => 'AI வழங்குநர்';

  @override
  String get settingsAiProviderBody =>
      'டேக்கிங் மற்றும் படங்களுக்கு உங்கள் சொந்த மாடலைப் பயன்படுத்தவும்';

  @override
  String get settingsAppVersion => 'ஆப் பதிப்பு';

  @override
  String get settingsPrivacyTerms => 'தனியுரிமை மற்றும் விதிமுறைகள்';

  @override
  String get settingsReportProblem => 'பிரச்சினையைப் புகாரளிக்கவும்';

  @override
  String get settingsChangePassword => 'கடவுச்சொல்லை மாற்றவும்';

  @override
  String get settingsExportData => 'தரவை ஏற்றுமதி செய்யவும்';

  @override
  String get settingsExportBody =>
      'நீங்கள் சேமித்த அனைத்தையும் கொண்ட கோப்பைத் தயார் செய்து பதிவிறக்கத்தைத் திறக்கிறோம்.';

  @override
  String get settingsExportAction => 'ஏற்றுமதி';

  @override
  String get settingsCurrentPassword => 'தற்போதைய கடவுச்சொல்';

  @override
  String get settingsNewPassword => 'புதிய கடவுச்சொல்';

  @override
  String get settingsConfirmNewPassword =>
      'புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get settingsEnterCurrentPassword =>
      'உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get settingsEnterNewPassword => 'புதிய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get settingsPasswordMin8 => 'குறைந்தது 8 எழுத்துகளைப் பயன்படுத்தவும்';

  @override
  String get settingsPasswordNeedsUpper => 'பெரிய எழுத்தைச் சேர்க்கவும்';

  @override
  String get settingsPasswordNeedsLower => 'சிறிய எழுத்தைச் சேர்க்கவும்';

  @override
  String get settingsPasswordNeedsDigit => 'எண்ணைச் சேர்க்கவும்';

  @override
  String get settingsPasswordsNoMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get settingsChangeAction => 'மாற்றவும்';

  @override
  String get itemAddSnapTitle => 'ஒரு உடையைப் புகைப்படம் எடுக்கவும்';

  @override
  String get itemAddSnapBody =>
      'புகைப்படத்தில் உள்ள ஒவ்வொரு உடையையும் கண்டறிந்து தெளிவான ஸ்டுடியோ படமாக மாற்றுகிறோம்.';

  @override
  String get itemAddCamera => 'புகைப்படம் எடுக்கவும்';

  @override
  String get itemAddGallery => 'கேலரியிலிருந்து தேர்ந்தெடுக்கவும்';

  @override
  String get itemAddOtherWays => 'சேர்க்க பிற வழிகள்';

  @override
  String get itemAddSeveral => 'பல புகைப்படங்களைச் சேர்க்கவும்';

  @override
  String get itemAddSeveralBody => 'ஒரே நேரத்தில் 50 வரை';

  @override
  String get itemAddImportProfile => 'புரோஃபைலில் இருந்து இறக்குமதி செய்யவும்';

  @override
  String get itemAddImportProfileBody => 'Instagram அல்லது Facebook';

  @override
  String get itemAddEnterDetails => 'விவரங்களை உள்ளிடவும்';

  @override
  String get itemAddEnterDetailsBody => 'புகைப்படம் தேவையில்லை';

  @override
  String get itemManualIntro =>
      'பெயர் மட்டும் போதும். மற்றவற்றை இப்போதோ அல்லது பின்னரோ சேர்க்கலாம்.';

  @override
  String get itemManualNameHint => 'உதாரணமாக, நீல நிற காட்டன் டி-ஷர்ட்';

  @override
  String get itemManualEnterName => 'பெயரை உள்ளிடவும்';

  @override
  String get itemManualNotes => 'குறிப்புகள்';

  @override
  String get itemManualBrand => 'பிராண்ட்';

  @override
  String get itemManualSize => 'அளவு';

  @override
  String get itemManualEnterNumber => 'எண்ணை உள்ளிடவும்';

  @override
  String get itemManualSavePiece => 'சேமிக்கவும்';

  @override
  String get itemManualSaving => 'சேமிக்கிறது';

  @override
  String get itemManualSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String itemManualSavedBody(String name) {
    return '$name உங்கள் அலமாரியில் உள்ளது.';
  }

  @override
  String get itemManualNotSaved => 'சேமிக்கப்படவில்லை';

  @override
  String get itemManualAddUseCase => 'பயன்பாட்டைச் சேர்க்கவும்';

  @override
  String get itemManualAddUseCaseAction => 'பயன்பாட்டைச் சேர்';

  @override
  String get itemPhotos => 'புகைப்படங்கள்';

  @override
  String get itemAddPhotos => 'புகைப்படங்களைச் சேர்';

  @override
  String get itemNoPhotoYet =>
      'புகைப்படம் இல்லை. புகைப்படம் இல்லாமலும் சேமிக்கலாம்.';

  @override
  String get itemRemovePhoto => 'புகைப்படத்தை நீக்கு';

  @override
  String get itemRemovePiece => 'பொருளை நீக்கு';

  @override
  String get filterConditionLabel => 'நிலை';

  @override
  String get photoshootStepPhotos => 'புகைப்படங்கள்';

  @override
  String get photoshootStepSetup => 'அமைப்பு';

  @override
  String get photoshootStepCreating => 'உருவாக்குகிறது';

  @override
  String get photoshootStepResults => 'முடிவுகள்';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'படி $current/$total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'ஒரு புகைப்படம் தோல்வியடைந்தது. கீழே மீண்டும் முயற்சிக்கவும்.';

  @override
  String photoshootManyFailed(int count) {
    return '$count புகைப்படங்கள் தோல்வியடைந்தன. ஒவ்வொன்றையும் கீழே மீண்டும் முயற்சிக்கவும்.';
  }

  @override
  String get photoshootFormat => 'வடிவம்';

  @override
  String get photoshootHowMany => 'எத்தனை';

  @override
  String get photoshootYourPrompt => 'உங்கள் விவரணை';

  @override
  String get photoshootPromptHint =>
      'மாலை நேர வெளிச்சத்தில் மொட்டை மாடி, லினன் சட்டை';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புகைப்படங்கள் உருவாக்கு',
      one: '1 புகைப்படம் உருவாக்கு',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'புகைப்படங்கள்',
      one: 'புகைப்படம்',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'இன்றைய வரம்பைச் சரிபார்க்க முடியவில்லை.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan திட்டம்: இன்று $remaining மீதமுள்ளது (மொத்தம் $limit)';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'இலவசம்';

  @override
  String get photoshootGallery => 'கேலரி';

  @override
  String get photoshootUseCamera => 'கேமரா பயன்படுத்து';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'புகைப்படம் $number-ஐ நீக்கு';
  }

  @override
  String get photoshootNoPhotosTitle => 'புகைப்படங்கள் கிடைக்கவில்லை';

  @override
  String get photoshootNoPhotosBody =>
      'புகைப்படங்கள் உருவாக்கப்படவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get photoshootNewStyle => 'புதிய ஸ்டைல்';

  @override
  String get photoshootNewPhotos => 'புதிய புகைப்படங்கள்';

  @override
  String photoshootOpenPhoto(int number) {
    return 'புகைப்படம் $number-ஐத் திற';
  }

  @override
  String get photoshootReportPhoto => 'புகைப்படத்தைப் புகாரளி';

  @override
  String get photoshootSaveToGallery => 'கேலரியில் சேமி';

  @override
  String get actionUpgrade => 'மேம்படுத்து';

  @override
  String get referralLimitTitle => 'இன்றைய புகைப்பட வரம்பை முடித்துவிட்டீர்கள்';

  @override
  String get referralLimitBody =>
      'இலவச புகைப்படங்கள் நாளை மீண்டும் கிடைக்கும். நண்பருக்குப் பரிந்துரை செய்யுங்கள், நீங்களும் உங்கள் நண்பரும் ஒரு மாதம் Pro இலவசமாகப் பெறுங்கள்.';

  @override
  String get referralLimitRefer => 'நண்பருக்குப் பரிந்துரை';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'டேட்டிங் ஆப்';

  @override
  String get photoshootUsePortfolio => 'போர்ட்ஃபோலியோ';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'அழகியல்';

  @override
  String get photoshootUseCustom => 'உங்கள் சொந்த விவரணை';

  @override
  String get photoshootDescLinkedin => 'வேலைக்கான தெளிவான புகைப்படங்கள்';

  @override
  String get photoshootDescDating => 'நிதானமான, இதமான மற்றும் இயல்பான';

  @override
  String get photoshootDescPortfolio => 'எடிட்டோரியல், உயர் ரக ஃபேஷன்';

  @override
  String get photoshootDescInstagram =>
      'உங்கள் பதிவிற்கான வாழ்க்கைமுறை படங்கள்';

  @override
  String get photoshootDescAesthetic => 'கலைநயமிக்க, உணர்வுப்பூர்வமான படங்கள்';

  @override
  String get photoshootDescCustom =>
      'உங்களுக்குத் தேவையான தோற்றத்தை விவரியுங்கள்';

  @override
  String get aspectSquare => 'சதுரம்';

  @override
  String get aspectPortrait => 'போர்ட்ரெய்ட்';

  @override
  String get aspectLandscape => 'லேண்ட்ஸ்கேப்';

  @override
  String get aspectTall => 'நீளம்';

  @override
  String get aspectWide => 'அகலம்';

  @override
  String get tryOnAppBar => 'மெய்நிகர் ட்ரை-ஆன்';

  @override
  String get tryOnYourPhoto => 'உங்கள் புகைப்படம்';

  @override
  String get tryOnGarment => 'ஆடை';

  @override
  String get tryOnUploadingPhoto => 'புகைப்படம் பதிவேற்றப்படுகிறது';

  @override
  String get tryOnAddPhotoPrompt =>
      'உங்கள் முழு உடல் புகைப்படத்தைச் சேர்க்கவும்';

  @override
  String get tryOnBodyPhotoHint => 'முழு உடல் புகைப்படம் சிறப்பாக இருக்கும்';

  @override
  String get tryOnAddPhoto => 'புகைப்படம் சேர்';

  @override
  String get tryOnChangePhoto => 'புகைப்படத்தை மாற்று';

  @override
  String get tryOnPhotoLoadFailed => 'புகைப்படத்தை ஏற்ற முடியவில்லை.';

  @override
  String get tryOnChooseGarment => 'ஆடை புகைப்படத்தைத் தேர்வு செய்யவும்';

  @override
  String get tryOnChooseOneGarment => 'ஒரு ஆடை புகைப்படத்தைத் தேர்வு செய்யவும்';

  @override
  String get tryOnGarmentHint =>
      'தட்டையாக வைக்கப்பட்ட அல்லது ஹேங்கரில் உள்ள ஆடை சிறந்தது';

  @override
  String get tryOnChange => 'மாற்று';

  @override
  String get tryOnCamera => 'கேமரா';

  @override
  String get tryOnRemove => 'நீக்கு';

  @override
  String get tryOnLookTitle => 'தோற்றம்';

  @override
  String get tryOnStyle => 'ஸ்டைல்';

  @override
  String get tryOnBackground => 'பின்னணி';

  @override
  String get tryOnPose => 'போஸ்';

  @override
  String get tryOnDressingUp =>
      'உங்களுக்கு ஆடை அணிவிக்கப்படுகிறது. இது அரை நிமிடம் எடுக்கும்.';

  @override
  String get tryOnEmptyResult => 'உங்கள் ட்ரை-ஆன் இங்கே தோன்றும்';

  @override
  String get tryOnReportImage => 'படத்தைப் புகாரளிக்கவும்';

  @override
  String get tryOnCreating => 'உருவாக்கப்படுகிறது';

  @override
  String get tryOnTryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get tryOnCreate => 'ட்ரை-ஆன் உருவாக்கு';

  @override
  String get tryOnBackgroundStudioWhite => 'ஸ்டுடியோ வெள்ளை';

  @override
  String get tryOnBackgroundStudioGrey => 'ஸ்டுடியோ சாம்பல்';

  @override
  String get tryOnBackgroundUrban => 'நகர்ப்புற வீதி';

  @override
  String get tryOnBackgroundNature => 'இயற்கை';

  @override
  String get tryOnBackgroundMinimal => 'குறைந்தபட்சம்';

  @override
  String get tryOnPoseFront => 'முன்பக்க நிலை';

  @override
  String get tryOnPoseSide => 'பக்கவாட்டு நிலை';

  @override
  String get tryOnPoseWalking => 'நடக்கும் நிலை';

  @override
  String get dashboardGreetingMorning => 'காலை வணக்கம்';

  @override
  String get dashboardGreetingAfternoon => 'மதிய வணக்கம்';

  @override
  String get dashboardGreetingEvening => 'மாலை வணக்கம்';

  @override
  String get dashboardWelcome => 'வரவேற்கிறோம்';

  @override
  String get dashboardOpenProfile => 'சுயவிவரத்தைத் திற';

  @override
  String get dashboardRailToday => 'இன்று';

  @override
  String get dashboardRailRecently => 'சமீபத்தியவை';

  @override
  String get dashboardActivityEmpty =>
      'புதிய ஆடைகள் மற்றும் உடைகள் இங்கே தோன்றும்.';

  @override
  String get quickAddPiece => 'ஆடையைச் சேர்';

  @override
  String get quickAddPieceBody => 'புகைப்படம் எடுத்து டேக் செய்யவும்';

  @override
  String get quickBuildOutfit => 'உடையை உருவாக்கு';

  @override
  String get quickBuildOutfitBody => 'உங்கள் ஆடைகளை இணைக்கவும்';

  @override
  String get quickForYou => 'உங்களுக்காக';

  @override
  String get quickForYouBody => 'இன்றைய பரிந்துரைகள்';

  @override
  String get quickPlanWeek => 'வாரத்தைத் திட்டமிடு';

  @override
  String get quickPlanWeekBody => 'தேதி வாரியாக உடைகள்';

  @override
  String get referralBannerUrgent => 'குறைவாக உள்ளதா? நண்பரை அழையுங்கள்.';

  @override
  String get referralBannerTitle => 'ஒரு மாதம் கொடுங்கள், ஒரு மாதம் பெறுங்கள்.';

  @override
  String get referralBannerBody =>
      'நீங்களும் உங்கள் நண்பரும் தலா ஒரு மாதம் Pro பெறுவீர்கள்.';

  @override
  String get referralBannerDismiss => 'ஒரு வாரத்திற்கு மறை';

  @override
  String get referralBannerShare => 'அழைப்பைப் பகிரவும்';

  @override
  String get referralBannerCopy => 'இணைப்பை நகலெடுக்கவும்';

  @override
  String get itemEditPieceTitle => 'துண்டைத் திருத்து';

  @override
  String get itemEditDescriptionLabel => 'விளக்கம்';

  @override
  String get itemEditNotSaved => 'சேமிக்கப்படவில்லை';

  @override
  String get itemEditSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String get itemEditSavedBody => 'உங்கள் மாற்றங்கள் சேமிக்கப்பட்டன.';

  @override
  String get itemEditSavedStalePhotos =>
      'சேமிக்கப்பட்டது — புகைப்படங்கள் பழையதாக இருக்கலாம்';

  @override
  String get itemEditRemovePieceHint =>
      'இந்தத் துண்டை உருப்படி பக்கத்திலிருந்து நீக்கவும்.';

  @override
  String get itemEditNoPhotos =>
      'புகைப்படங்கள் இல்லை. கேலரி அல்லது கேமராவிலிருந்து சேர்க்கவும்.';

  @override
  String get itemEditKeepPhoto => 'புகைப்படத்தை வைத்திரு';

  @override
  String get itemEditRemoved => 'நீக்கப்பட்டது';

  @override
  String get itemEditAddUseCaseAction => 'சேர்';

  @override
  String get statsNoStatsTitle => 'புள்ளிவிவரங்கள் இல்லை';

  @override
  String get statsNoStatsBody =>
      'சில துண்டுகளைச் சேர்த்தால், உங்கள் அலமாரி கலவை இங்கே தோன்றும்.';

  @override
  String get statsByCategory => 'வகை வாரியாக';

  @override
  String get statsTotalValue => 'மொத்த மதிப்பு';

  @override
  String get statsMostWorn => 'அதிகம் அணிந்தது';

  @override
  String get statsLeastWorn => 'வாய்ப்புக்காகக் காத்திருக்கிறது';

  @override
  String get statsUnnamedPiece => 'பெயரிடப்படாத துண்டு';

  @override
  String get jobsTitle => 'ஸ்கேன்கள்';

  @override
  String get jobsEmptyTitle => 'ஸ்கேன்கள் இல்லை';

  @override
  String get jobsEmptyBody =>
      'ஒரு துண்டைப் புகைப்படம் எடுத்து பின்னணிக்கு அனுப்பவும் — அது இங்கே தொடர்ந்து செயல்படும்.';

  @override
  String get jobsNotCancelled => 'ரத்து செய்யப்படவில்லை';

  @override
  String get jobsResume => 'மீண்டும் தொடங்கு';

  @override
  String get jobsReview => 'மதிப்பாய்வு';

  @override
  String get jobsStop => 'நிறுத்து';

  @override
  String get jobsDismiss => 'நீக்கு';

  @override
  String get reportTitle => 'உள்ளடக்கத்தைப் புகாரளி';

  @override
  String reportIntro(String contentType) {
    return 'இந்த $contentType-ல் என்ன தவறு என்று எங்களிடம் கூறுங்கள். எங்கள் குழு ஒவ்வொரு புகாரையும் ஆய்வு செய்யும்.';
  }

  @override
  String get reportReasonInappropriate => 'தகுதியற்ற அல்லது ஆபாசமான';

  @override
  String get reportReasonNudity => 'நிர்வாணம் அல்லது பாலியல் உள்ளடக்கம்';

  @override
  String get reportReasonHarassment => 'துன்புறுத்தல் அல்லது வசைபாடுதல்';

  @override
  String get reportReasonImpersonation => 'ஆள்மாறாட்டம்';

  @override
  String get reportReasonOther => 'பிற';

  @override
  String get reportDetailsLabel => 'கூடுதல் விவரங்கள் (விருப்பத்தேர்வு)';

  @override
  String get reportSubmit => 'புகாரைச் சமர்ப்பி';

  @override
  String get reportSubmittedTitle => 'புகார் சமர்ப்பிக்கப்பட்டது';

  @override
  String get reportSubmittedBody =>
      'நன்றி. எங்கள் குழு இந்த உள்ளடக்கத்தை ஆய்வு செய்யும்.';

  @override
  String get reportFailedTitle => 'புகாரை அனுப்ப முடியவில்லை';

  @override
  String get reportFailedBody => 'தயவுசெய்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get reportContentTryOnImage => 'AI ட்ரை-ஆன் படம்';

  @override
  String get reportContentSharedOutfit => 'பகிரப்பட்ட உடை';

  @override
  String get reportContentPhotoshootImage => 'AI போட்டோஷூட் படம்';

  @override
  String get sharedOutfitTitle => 'பகிரப்பட்ட உடை';

  @override
  String get sharedOutfitHideTooltip => 'இந்த உடையை மறைக்கவும்';

  @override
  String get sharedOutfitReportTooltip => 'இந்த உடையைப் புகாரளிக்கவும்';

  @override
  String get sharedOutfitHideTitle => 'இந்த உடையை மறைக்கவா?';

  @override
  String get sharedOutfitHideBody =>
      'இது இந்தச் சாதனத்தில் மறைக்கப்படும். எங்கள் குழு ஆய்வு செய்து நீக்க, நீங்கள் இதைப் புகாரளிக்கலாம்.';

  @override
  String get sharedOutfitHideAction => 'மறை';

  @override
  String get sharedOutfitHiddenInfo =>
      'இந்த உடை இனி இந்தச் சாதனத்தில் காட்டப்படாது.';

  @override
  String get sharedOutfitHiddenToast => 'உடை மறைக்கப்பட்டது';

  @override
  String get sharedOutfitMissingTitle => 'இந்த உடை இப்போது இல்லை';

  @override
  String get sharedOutfitMissingBody =>
      'இது நீக்கப்பட்டிருக்கலாம் அல்லது இணைப்பு தவறாக இருக்கலாம்.';

  @override
  String get sharedOutfitHiddenStateTitle =>
      'நீங்கள் இந்த உடையை மறைத்துள்ளீர்கள்';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'இது ஆட்சேபனைக்குரியதாக இருந்தால், தனியுரிமை மற்றும் விதிமுறைகள் மூலம் புகாரளிக்கவும் அல்லது $email முகவரிக்கு மின்னஞ்சல் அனுப்பவும்.';
  }

  @override
  String get sharedOutfitCtaTitle => 'இந்தத் தோற்றம் பிடித்துள்ளதா?';

  @override
  String get sharedOutfitCtaBody =>
      'உங்கள் அலமாரியில் உள்ள ஆடைகளைக் கொண்டு இது போன்ற உடைகளை உருவாக்குங்கள்.';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'பிழை';

  @override
  String get errorUnknown => 'தெரியாத பிழை ஏற்பட்டுள்ளது';

  @override
  String get errorNoConnection =>
      'இன்டர்நெட் இணைப்பு இல்லை. உங்கள் நெட்வொர்க்-ஐ சரிபார்க்கவும்.';

  @override
  String get errorTimeout =>
      'கோரிக்கை நேரம் முடிந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorServerError =>
      'எங்கள் பக்கத்தில் சில பிரச்சினைகள். மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorBadGateway =>
      'எங்கள் சர்வர் தற்காலிகமாக பணியற்றது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorServiceUnavailable =>
      'சேவை தற்காலிகமாக கிடைக்கவில்லை. சிறிது நேரத்தில் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorInternalError =>
      'சில விஷயங்கள் தவறாக இருந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorUnauthorized => 'தொடர்வதற்கு உள்நுழையவும்.';

  @override
  String get errorForbidden => 'அதற்கு உங்களுக்கு அணுகல் இல்லை.';

  @override
  String get errorSessionExpired =>
      'உங்கள் அமர்வு முடிந்தது. மீண்டும் உள்நுழையவும்.';

  @override
  String get errorInvalidCredentials =>
      'அந்த மின்னஞ்சல் அல்லது கடவுச்சொல் சரியல்ல.';

  @override
  String get errorTokenRefreshFailed =>
      'உங்கள் அமர்வை புதுப்பிக்க முடியவில்லை. மீண்டும் உள்நுழையவும்.';

  @override
  String get errorRequestCancelled => 'கோரிக்கை ரத்து செய்யப்பட்டது.';

  @override
  String get errorInvalidFormat => 'அந்த கோப்பு வடிவம் ஆதரிக்கப்படுவதில்லை.';

  @override
  String get errorFileTooLarge => 'அந்த கோப்பு மிக பெரியது.';

  @override
  String get errorUploadFailed =>
      'பதிவேற்றம் தோல்வியடைந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorCacheCorrupted =>
      'சேமிக்கப்பட்ட தரவு சேதமடைந்து மீட்டமைக்கப்பட்டது.';

  @override
  String get errorCacheNotFound => 'இதுவரை எதுவும் சேமிக்கப்படவில்லை.';

  @override
  String get errorUserNotFound => 'அந்த கணக்கை கண்டறிய முடியவில்லை.';

  @override
  String get errorItemNotFound => 'அந்த பொருள் இப்போதில் இல்லை.';

  @override
  String get errorOutfitNotFound => 'அந்த உடையம் இப்போதில் இல்லை.';

  @override
  String get rewardsTitle => 'பரிசுகள்';

  @override
  String get rewardsNoAchievementsTitle => 'இதுவரை உருவாக்கங்கள் இல்லை';

  @override
  String get rewardsNoAchievementsBody =>
      'உங்கள் முதல் உருவாக்கத்தை பெற பகுதிகளை சேர்த்து உடையங்களை திட்டமிடவும்.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'பட்டியலில் யாரும் இல்லை';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'புள்ளிகள் பெற உடையங்களை திட்டமிட்டு இங்கே தோன்றவும்.';

  @override
  String get legalViewPrivacyPolicy => 'தனியுரிமை கொள்கைகளை காண';

  @override
  String get aiConsentAgree => 'நான் ஒப்புக்கொள்கிறேன் & தொடரவும்';

  @override
  String get aiConsentNotNow => 'இப்போது வேண்டாம்';

  @override
  String get imageViewerCloseTooltip => 'படக் காட்சியை மூடு';

  @override
  String get updateReadyTitle => 'புதுப்பிப்பு தயார்';

  @override
  String get updateReadyBody =>
      'சமீபத்திய மேம்பாடுகளைப் பயன்படுத்த FitCheck AI-ஐ மறுதொடங்கு.';

  @override
  String get permissionCameraUsage =>
      'உங்கள் ஆடைகள் மற்றும் உடை உருப்படிகளின் படங்களை எடுக்க FitCheck AI-க்கு கேமரா அணுகல் தேவை.';

  @override
  String get permissionPhotoLibraryUsage =>
      'உங்கள் ஆடைகள் மற்றும் உடை உருப்படிகளின் படங்களைத் தேர்வு செய்ய FitCheck AI-க்கு திரைப்பட நூலக அணுகல் தேவை.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'உங்கள் AI உருவாக்கிய ஆடை படங்களை உங்கள் திரைப்பட நூலகத்தில் சேமிக்க FitCheck AI-க்கு தேவை.';

  @override
  String get wardrobeSomePhotosSkipped => 'கூடிய படங்கள் தவிர்க்கப்பட்டன';

  @override
  String get wardrobePhotosNotAdded => 'படங்கள் சேர்க்கப்படவில்லை';

  @override
  String get wardrobePhotoNotAdded => 'படம் சேர்க்கப்படவில்லை';

  @override
  String get wardrobeNotStartedTitle => 'தொடங்கப்படவில்லை';

  @override
  String get wardrobeNoRoomTitle => 'இடம் இல்லை';

  @override
  String get wardrobeAddPhotosSemantic => 'படங்களை சேர்';

  @override
  String get batchAddTileLabel => 'சேர்';

  @override
  String get batchProfileLinkLabel => 'சுயவிவர லிங்க்';

  @override
  String get wardrobeImportFromProfileTitle =>
      'சுயவிவரத்திலிருந்து உள்ளே கொண்டுவர';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'பல படங்களைச் சேர்';

  @override
  String get wardrobeClearAction => 'அழி';

  @override
  String get wardrobeRefreshTooltip => 'புதுப்பி';

  @override
  String get batchNoPhotosYetTitle => 'இன்னும் படங்கள் இல்லை';

  @override
  String get batchChoosePhotosAction => 'படங்களைத் தேர்வு செய்';

  @override
  String get batchWeFindEachPieceBody =>
      'ஒவ்வொரு உடை உருப்படியையும் நாங்கள் கண்டறிந்து, அதன் ஸ்டுடியோ படத்தை உருவாக்குகிறோம்.';

  @override
  String get batchPreparingPhotosSemantic => 'படங்களை தயார் செய்கிறது';

  @override
  String get batchPhotosProcessedSemantic => 'படங்கள் செயல்முறைப்படுத்தப்பட்டன';

  @override
  String get batchPasteProfileLinkTitle => 'சுயவிவர லிங்கை ஒட்டு';

  @override
  String get batchPasteProfileLinkBody =>
      'பயனிலை உள்ள Instagram அல்லது Facebook சுயவிவரம். அதன் படங்களை நாங்கள் தணிக்கை செய்து, உங்கள் அலமாரியில் என்ன வைக்க வேண்டும் என்று நீங்கள் தேர்வு செய்கிறீர்கள்.';

  @override
  String get batchClearLinkTooltip => 'லிங்கை அழி';

  @override
  String get batchStartingButton => 'தொடக்கம்';

  @override
  String get batchStartImportAction => 'உள்ளே கொண்டு வரத் தொடங்கு';

  @override
  String get batchReviewEveryPhotoTitle =>
      'ஒவ்வொரு படத்தையும் நீங்கள் தணிக்கை செய்வீர்கள்';

  @override
  String get batchReviewEveryPhotoBody =>
      'நீங்கள் அங்கீகரிக்கும் வரை எதுவும் சேர்க்கப்படாது.';

  @override
  String get batchPrivateProfilesTitle => 'தனிப்பட்ட சுயவிவரங்கள்';

  @override
  String get batchPrivateProfilesBody =>
      'உங்கள் கணக்கை இணைக்கவும். Instagram-க்குயியும் பயனர்பெயரையும் கடவுச்சொல்லையும் கேட்கிறது.';

  @override
  String get batchUseAnotherLinkAction => 'மற்றொரு இணைப்பை பயன்படுத்தவும்';

  @override
  String get batchSignInNeededTitle => 'உள்நுழைவு தேவை';

  @override
  String get batchEnterYourCodeTitle => 'உங்கள் குறியீட்டை உள்ளிடுங்கள்';

  @override
  String get batchUseUsernamePasswordAction => 'பயனர்பெயர் மற்றும் கடவுச்சொல்';

  @override
  String get batchAlreadyConnectedAction => 'பிரவுஸரில் ஏற்கனவே இணைத்தேன்';

  @override
  String get batchEnterCodeAction => 'குறியீடு உள்ளிடவும்';

  @override
  String get batchTryAnotherWayAction => 'மற்றொரு முயற்சி செய்யவும்';

  @override
  String get batchLiveStatus => 'நேரடி';

  @override
  String get batchReconnectingStatus => 'மீண்டும் இணைக்கிறது';

  @override
  String get batchSignInToInstagramTitle => 'Instagram-இல் உள்நுழைக';

  @override
  String get batchUsernameLabel => 'பயனர்பெயர்';

  @override
  String get batchCodeIfTwoStepLabel =>
      'இரு-அடையாளப்படுத்தல் பயன்படுத்தினால், குறியீடு';

  @override
  String get batchAuthenticatorCodeBody =>
      'உங்கள் அடையாளப்படுத்தி பயன்பாட்டில் 6-இலக்க குறியீட்டைப் பயன்படுத்தவும். குறியீடுகள் விரைவாக மாறும்.';

  @override
  String get batchVerifyAction => 'சரிபார்க்கவும்';

  @override
  String get batchFindingPhotosTitle => 'புகைப்படங்களைக் கண்டறிகிறது';

  @override
  String get batchImportPausedTitle => 'இறக்குமதி இடைநீக்கம்';

  @override
  String get batchProcessingPhotosTitle => 'புகைப்படங்களை செயலாக்குகிறது';

  @override
  String get batchWaitingNextPhoto =>
      'அடுத்த புகைப்படத்திற்காக காத்திருக்கிறது';

  @override
  String get batchCancelImportAction => 'இறக்குமதியை ரத்து செய்க';

  @override
  String get batchNoPiecesInPhotoBody =>
      'இந்த புகைப்படத்தில் பொருட்கள் காணப்படவில்லை.';

  @override
  String get batchEditPieceColoursLabel => 'வண்ணங்கள், குடிசின் மூலம்';

  @override
  String get batchAddToClosetAction => 'இடுகாட்டில் சேர்';

  @override
  String get batchSkipPhotoAction => 'இந்த புகைப்படத்தை தவிர்க்கவும்';

  @override
  String get batchImportCompleteTitle => 'இறக்குமதி நிறைவு';

  @override
  String get batchImportFailedTitle => 'இறக்குமதி தோல்வி';

  @override
  String get batchImportCancelledTitle => 'இறக்குமதி ரத்து';

  @override
  String get batchImportErrorBody =>
      'இறக்குமதி செய்யும்போது சில விஷயங்கள் தவறுதல்.';

  @override
  String get batchNothingMoreImportedBody =>
      'இந்த சுயவிவரத்திலிருந்து இனிமேல் எதுவும் இறக்குமதி செய்யப்படவில்லை.';

  @override
  String get batchViewClosetAction => 'அலமாரியை பார்';

  @override
  String get batchStartOverAction => 'மீண்டும் தொடங்கு';

  @override
  String get wardrobeAddPieceTitle => 'கோர் அளையை சேர்';

  @override
  String get wardrobeAddDetailsTitle => 'விவரங்களை சேர்';

  @override
  String get wardrobeScanningTitle => 'ஸ்கேன் பண்ணுது';

  @override
  String get batchReviewPiecesTitle => 'கோர் அளைகளை சோதனை பார்';

  @override
  String get wardrobeGalleryAction => 'கலரி';

  @override
  String get wardrobeCameraAction => 'கேமரா';

  @override
  String get wardrobeNewBadge => 'புது';

  @override
  String get wardrobeRemovePhotoTooltip => 'போட்டோ நீக்கு';

  @override
  String get batchRunInBackgroundTooltip => 'பின்னணிதில் ஓடு';

  @override
  String get batchStepOneOfTwo => 'படி 1/2';

  @override
  String get batchStepTwoOfTwo => 'படி 2/2';

  @override
  String get batchUploadingPhotosTitle => 'போட்டோ பதிவேறுது';

  @override
  String get batchFindingPiecesTitle => 'கோர் அளை தேடுது';

  @override
  String get batchMakingStudioPhotosTitle => 'ஸ்டுடியோ போட்டோ உருவாக்குது';

  @override
  String get batchStoppedLabel => 'நிறுத்தம்';

  @override
  String get batchFindingPiecesStoppedTitle => 'கோர் அளை தேடல் நிறுத்தம்';

  @override
  String get batchCancelledLabel => 'ரத்து';

  @override
  String get batchAllDoneTitle => 'அனைத்தும் முடிந்தது';

  @override
  String get batchOpeningPiecesBody => 'உங்கள் கோர் அளை திறக்குது';

  @override
  String get batchNothingSavedBody => 'ஒன்றுமே சேமிக்கப்படவில்லை.';

  @override
  String get batchFindingPiecesFailedBody => 'கோர் அளை தேடல் தோல்வியடைந்தது.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'கோர் அளை தேடல் முன் விதியில் நிறுத்தம்.';

  @override
  String get batchStopFindingPiecesTitle => 'கோர் அளை தேடலை நிறுத்த?';

  @override
  String get batchStopFindingPiecesBody =>
      'ஸ்கேன் நிறுத்தி, ஒன்றுமே சேமிக்கப்படாது. ஏற்கனவே கண்ட கீரிகள், நீங்கள் அப்படியே விடும் வரை உங்கள் அக்டிவிட்டியில் இருக்கும்.';

  @override
  String get batchKeepGoingAction => 'தொடர்ச்சி';

  @override
  String get batchTryAgainAction => 'மீண்டும் முயற்சி';

  @override
  String get batchBackToPhotosAction => 'போட்டோவுக்கு பின்';

  @override
  String get batchSkipAllAction => 'அனைத்தையும் தவிர்க்க';

  @override
  String get batchIncludeAllAction => 'அனைத்தையும் சேர்';

  @override
  String get batchNoPiecesFoundTitle => 'பொருட்கள் எதுவும் இல்லை';

  @override
  String get batchNoPiecesFoundBody =>
      'இந்த படங்களில் உடைகள் எதுவும் கிடைக்கவில்லை.';

  @override
  String get batchChooseOtherPhotosAction => 'வேறு படங்களைத் தேர்வுசெய்';

  @override
  String get batchUseCaseHelper =>
      'நீங்கள் சேமிக்கும் ஒவ்வொரு உடையுக்கும் சேர்க்கப்படும்.';

  @override
  String get batchDiscardPiecesTitle => 'இந்த உடைகளை நீக்குவீர்களா?';

  @override
  String get batchDiscardPiecesBody =>
      'இந்த தொகுப்பில் இருந்து எதுவும் சேமிக்கப்படவில்லை.';

  @override
  String get batchKeepAction => 'இருக்கவும்';

  @override
  String get batchDiscardAction => 'நீக்கு';

  @override
  String get batchRemovePieceTitle => 'இந்த உடையை நீக்குவீர்களா?';

  @override
  String get batchRemovePieceBody => 'உங்கள் நெக்ரோவரிக்கு சேமிக்கப்படவில்லை.';

  @override
  String get batchRemoveAction => 'நீக்கு';

  @override
  String get batchChoosePiecesToSave => 'சேமிக்க வேண்டிய உடைகளைத் தேர்வுசெய்';

  @override
  String get batchDiscardAllAction => 'அனைத்தையும் நீக்கு';

  @override
  String get batchNothingSavedRetryBody =>
      'எதுவும் சேமிக்கப்படவில்லை. மீண்டும் முயற்சி செய்யவும்.';

  @override
  String get batchNotSavedTitle => 'சேமிக்கப்படவில்லை';

  @override
  String get batchSavingLabel => 'சேமிக்கப்படுகிறது';

  @override
  String get batchSendToBackgroundAction => 'பின்னணியில் அனுப்பு';

  @override
  String get batchStillWorkingMessage =>
      'இன்னும் இயங்கி வருகிறது. உடைகள் தயார் ஆகும்போது உங்களுக்கு அறிவிப்போம்.';

  @override
  String get batchRunningInBackgroundTitle => 'பின்னணியில் இயங்குகிறது';

  @override
  String get batchStudioPhotosStoppedBody =>
      'ஸ்டுடியோ படங்கள் முன்கூட்டியே நிறுத்தப்பட்டன. இந்த உடைகளை நீங்கள் சேமிக்கலாம்.';

  @override
  String get batchTapPieceToSkip => 'ஒரு உடையை தாவ வேண்டுமானால் அதை தட்டவும்.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'ஸ்டுடியோ படங்கள் இன்னும் என்னும்போது வருகின்றன. நீங்கள் செல்லலாம் — உங்களுக்கு அறிவிப்போம்.';

  @override
  String get batchLeaveAction => 'வெளியேறு';

  @override
  String get batchPeopleInPhotosTitle => 'படங்களில் உள்ளவர்கள்';

  @override
  String get batchIncludeAction => 'சேர்';

  @override
  String get batchSkipAction => 'தாவு';

  @override
  String get batchYourPhotoIsUsedLabel => 'உங்கள் படம் பயன்படுத்தப்படுகிறது';

  @override
  String get batchMakingStudioPhotoLabel => 'ஸ்டுடியோ படம் உருவாக்கப்படுகிறது';

  @override
  String get batchNoStudioPhotoBody =>
      'ஸ்டுடியோ படம் இல்லை. உங்கள் படம் பயன்படுத்தப்படுகிறது.';

  @override
  String get batchEnterDetailsYourselfAction => 'விவரங்களை உங்களே உள்ளிடவும்';

  @override
  String get batchChooseAnotherPhotoAction =>
      'மற்றொரு புகழைத் தேர்ந்தெடுக்கவும்';

  @override
  String get batchConnectionLostTitle => 'இணைப்பு அடைமானம்';

  @override
  String get batchConnectionLostBody =>
      'உங்கள் இணைப்பைச் சரிபார்த்து, மீண்டும் முயற்சிக்கவும்.';

  @override
  String get batchDailyLimitTitle => 'தினசரி வரம்பு அடைந்தது';

  @override
  String get batchDailyLimitBodyPaywall =>
      'மேலும் ஸ்கேன்களுக்கு Proru மேம்படுத்தவும், அல்லது விவரங்களை உங்களே உள்ளிடவும்.';

  @override
  String get batchDailyLimitBodyFree =>
      'உங்கள் ஸ்கேன்கள் நாளை மீட்டமைக்கப்படும். இப்போது விவரங்களை உங்களே உள்ளிடலாம்.';

  @override
  String get batchSeePlansAction => 'திட்டங்களைக் காண்க';

  @override
  String get batchAiBusyTitle => 'எங்கள் AI பிடிந்திருக்கிறது';

  @override
  String get batchAiBusyBody =>
      'இது எங்கள் பக்கத்தில் உள்ளது. சில நிமிடங்களில் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get batchNoPiecesBody =>
      'குறைந்த புகழை முயற்சிக்கவும், அல்லது விவரங்களை உங்களே உள்ளிடவும்.';

  @override
  String get batchScanningUnavailableTitle => 'ஸ்கேனிங் இல்லை';

  @override
  String get batchScanningUnavailableBody =>
      'இப்போதாவது விவரங்களை உங்களே உள்ளிடவும்.';

  @override
  String get batchScanDidNotFinishTitle => 'ஸ்கேன் முடிக்கப்படவில்லை';

  @override
  String get batchTryAgainBody => 'மீண்டும் முயற்சிக்கவும்.';

  @override
  String get billingTitle => 'சந்தா';

  @override
  String get billingUpgradeHeading => 'உங்கள் திட்டத்தை மேம்படுத்தவும்';

  @override
  String get billingUpgradeOnPlusBody => 'அதே சிறப்புகள், அதிக வரம்புகள்.';

  @override
  String get billingUpgradeBody =>
      'Plus மற்றும் Pro-ல் அதே சிறப்புகள் உள்ளன. உங்களுக்குத் தேவையான வரம்புகளைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get billingWebUnavailableBody =>
      'ஆன்லைன் மேம்பாடுகள் இன்னும் கிடைக்கவில்லை. ஒரு promos அல்லது பரிந்துரை கோடு Plus அல்லது Proru திறக்கும். கீழே நண்பர்களை அழைத்து இலவச மாதங்களைப் பெறுங்கள்.';

  @override
  String get billingPlansStale =>
      'சமீபத்திய திட்டங்களைஏற்ற முடியவில்லை. விலைகள் பழையதாக இருக்கலாம்.';

  @override
  String get billingMonthly => 'மாதாந்திர';

  @override
  String get billingYearly => 'வாசராந்திர';

  @override
  String get billingCurrentPlan => 'தற்போதைய திட்டம்';

  @override
  String get billingActive => 'செயலில்';

  @override
  String get billingThisMonth => 'இந்த மாதம்';

  @override
  String get billingItemExtractions => 'பொருள் பிரிவுகள்';

  @override
  String get billingOutfitVisualizations => 'ஆடை காட்சிப்படுத்தல்கள்';

  @override
  String get billingNearLimitUpgrade =>
      'இந்த மாதத்தின் வரம்பை அணுகுகிறீர்கள். மேலதிகங்களுக்கு மேம்படுத்தவும்.';

  @override
  String get billingNearLimitResets =>
      'இந்த மாதத்தின் வரம்பை அணுகுகிறீர்கள். அடுத்த மாதத்தின் தொடக்கத்தில் இது மீட்டமைக்கப்படும்.';

  @override
  String get billingStoreUnavailable =>
      'ஆப் ஸ்டோரில் மேம்பாடுகள் இன்னும் கிடைக்கவில்லை. விரைவில் பாருங்கள்.';

  @override
  String get billingManageHeading => 'உங்கள் திட்டத்தை நிர்வகிக்கவும்';

  @override
  String get billingCancelPlan => 'கொடுப்பனை முடிக்கவும்';

  @override
  String get billingCancelKeepsAccess =>
      'தற்போதைய கட்டண காலத்தின் முடிவு வரை அணுகல் நிலைத்துள்ளது.';

  @override
  String get billingCancelConfirmTitle => 'உங்கள் கட்டணத்தை முடிக்கவா?';

  @override
  String get billingKeepPlan => 'திட்டத்தைத் தொடரவும்';

  @override
  String get billingCancelPlanAction => 'திட்டத்தை முடிக்கவும்';

  @override
  String get billingBilledMonthly => 'மாதந்தோறும் கட்டணம்';

  @override
  String get billingBilledYearly => 'வருடந்தா கட்டணம்';

  @override
  String get billingVirtualTryOn => 'சொல்வழி பரோடெய்லிங்';

  @override
  String get billingPrioritySupport => 'முன்னுரிமை ஆதரவு';

  @override
  String get billingDisclosureProRenewing => 'Pro தானாகத் தொடர்கிறது';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus மற்றும் Pro தானாகத் தொடர்கின்றன';

  @override
  String get billingDisclosureAppleBilling =>
      'வாங்கல் உறுதிப்படுத்தலில், ஆப் லெட் ஐடிக்குக் கட்டணம் பகிரப்படும்.';

  @override
  String get billingDisclosureGoogleBilling =>
      'வாங்கல் உறுதிப்படுத்தலில், கூகிள் தவரில் கட்டணம் பகிரப்படும்.';

  @override
  String get billingDisclosureRenewalTerms =>
      'தற்போதைய காலம் முடிய 24 மணி நேரத்திற்கு முன்பு தானாக தொடர்வதை முடக்கினால் தவிர, மீள்வது தானாகவே தொடரும்.';

  @override
  String get billingDisclosureAppleManage =>
      'அமைப்புகளில் எப்போது வேண்டுமானாலும் நிர்வகிக்கலாம் அல்லது முடிக்கலாம்.';

  @override
  String get billingDisclosureGoogleManage =>
      'கூகிள் தவரில் எப்போது வேண்டுமானாலும் நிர்வகிக்கலாம் அல்லது முடிக்கலாம்.';

  @override
  String get billingReferFriend => 'உறவாண்மை';

  @override
  String get billingHowItWorks => 'எப்படி வேலை செய்கிறது';

  @override
  String get billingHowShareTitle => 'உங்கள் லிங்கைப் பகிருங்கள்';

  @override
  String get billingHowShareBody => 'ஒரு உறவினரிடம் அனுப்புங்கள்.';

  @override
  String get billingHowSignUpTitle => 'அவர்கள் சந்தியில்';

  @override
  String get billingHowSignUpBody =>
      'உங்கள் உறவினர் லிங்கைப் பயன்படுத்தி சேர்கிறார்.';

  @override
  String get billingHowBothTitle => 'உங்களில் இருவருக்கும் Pro';

  @override
  String get billingHowBothBody => 'ஒவ்வொருவருக்கும் இலவசமாக ஒரு மாத Pro.';

  @override
  String get billingYourReferrals => 'உங்கள் அழைப்புகள்';

  @override
  String get billingInvited => 'அழைக்கப்பட்டது';

  @override
  String get billingJoined => 'சேர்ந்தார்';

  @override
  String get billingMonthsEarned => 'வருமானம் பெற்ற மாதங்கள்';

  @override
  String get billingInviteFriend => 'வெள்ளைப்படுத்த';

  @override
  String get billingInviteBody =>
      'நீங்கள் மற்றும் உங்கள் நடிகர் தலா ஒரு மாதம் Pro இலவசம்.';

  @override
  String get billingYourCode => 'உங்கள் குறியீடு';

  @override
  String get billingCopyLink => 'இணைப்பை நகலாக்க';

  @override
  String get billingShareInvite => 'அழைப்பைப் பகிர்';

  @override
  String get giftUnavailable => 'பரிசு அழைப்புகள் இந்த கட்டமைப்பில் இல்லை.';

  @override
  String get giftPageTitle => 'FitCheck Pro பரிசு';

  @override
  String get giftNoAllowances => 'இப்போது இலவச பரிசு அழைப்புகள் இல்லை.';

  @override
  String get giftFormTitle => 'இலவச அழைப்பை அனுப்பு';

  @override
  String get giftFormBody =>
      'பெறுநர் இந்த சரிபார்க்கப்பட்ட மின்னஞ்சல் மூலம் பரிசை அறிவிக்கிறார். நாங்கள் அனுப்புவதில்லை.';

  @override
  String get giftFieldFrom => 'முதல்';

  @override
  String get giftFieldRecipientName => 'பெறுநர் பெயர்';

  @override
  String get giftFieldRecipientEmail => 'பெறுநர் மின்னஞ்சல்';

  @override
  String get giftFieldOccasion => 'விருது (விருப்பம்)';

  @override
  String get giftNoOccasion => 'விருது இல்லை';

  @override
  String get giftOccasionBirthday => 'மணுதிதி';

  @override
  String get giftOccasionAnniversary => 'வருட நோக்குதல்';

  @override
  String get giftOccasionOther => 'மற்றது';

  @override
  String get giftFieldCardGreeting => 'அட்டை வாழ்த்து';

  @override
  String get giftFieldCardGreetingHelper =>
      'இது அட்டையில் எழுதப்பட்டுள்ளபடி தோன்றும்.';

  @override
  String get giftFieldPrivateNote => 'தனிப்பட்ட குறிப்பு (விருப்பம்)';

  @override
  String get giftCreateAction => 'இலவச பரிசை உருவாக்கு';

  @override
  String get giftClaimedTitle => 'பரிசு பெறப்பட்டது';

  @override
  String get giftClaimedActive => 'உங்கள் FitCheck Pro பரிசு செயல்படுகிறது.';

  @override
  String get giftClaimedQueued =>
      'உங்கள் FitCheck Pro பரிசு தற்போதைய அணுகலுக்கு பிறகு தொடங்குகிறது.';

  @override
  String get giftLinkCopied => 'பரிசு இணைப்பு கிப் பார்டுக்கு நகலாக்கப்பட்டது.';

  @override
  String get giftErrorName => 'பெயரை உள்ளிடவும்.';

  @override
  String get giftErrorEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்.';

  @override
  String get giftErrorGreeting => 'அட்டை வாழ்த்தை உள்ளிடவும்.';

  @override
  String get giftErrorGreetingLength =>
      '80 எழுத்துக்களுக்கு மேல் பயன்படுத்த வேண்டாம்.';

  @override
  String get giftClaimAction => 'விருந்தை பெறு';

  @override
  String get giftCardPreview => 'கார்டு முன்னோட்டம்';

  @override
  String get giftGiftForYou => 'உங்களுக்கான விருது';

  @override
  String get giftGiftWaiting => 'உங்களுக்கான விருது காத்திருக்கிறது';

  @override
  String get giftOpenBody =>
      'உங்கள் விருதுகளை திறந்து அங்கீகரிக்கப்பட்ட மின்னஞ்சலில் பெறுங்கள்.';

  @override
  String get giftOpenGifts => 'விருதுகளை திற';

  @override
  String get giftSendInvitation => 'அழைப்பிதழ் அனுப்பு';

  @override
  String get settingsAiProviderSection => 'வழங்குபவர்';

  @override
  String get settingsAiCustom => 'தனிப்பயன்';

  @override
  String get settingsAiUrlHelper =>
      'சர்வர் அணுகக்கூடிய பொதுமதிப்புள்ள URL ஐ பயன்படுத்தவும். எங்கள் சர்வர்களில் லோக்கால்ஹோஸ்ட் வேலை செய்யாது.';

  @override
  String get settingsAiConnectionSection => 'இணைப்பு';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API விசை';

  @override
  String get settingsAiApiKeySaved =>
      'சேமிக்கப்பட்டது. இதை வைக்க வெறியாக விடவும்.';

  @override
  String get settingsAiChatModel => 'சேட் மோடல்';

  @override
  String get settingsAiVisionModel => 'விஷன் மோடல் (விருப்பம்)';

  @override
  String get settingsAiImageModel => 'பட மோடல் (விருப்பம்)';

  @override
  String get settingsAiImageModelNote =>
      'பட உருவாக்கத்திற்கு response_modalities ஆன OpenAI தனிப்பயன் சேட் நிறைவுகள் தேவை.';

  @override
  String get settingsAiTestConnection => 'இணைப்பை சோதி';

  @override
  String get calendarTitle => 'தேதிக்குறிப்பு';

  @override
  String get calendarGoToToday => 'இன்று செல்';

  @override
  String get calendarConnectTooltip => 'தேதிக்குறிப்பை இணை';

  @override
  String get calendarAddEvent => 'நிகழ்வை சேர்';

  @override
  String get calendarEmptyTitle => 'கோட்பட்டது ஒன்றும் இல்லை';

  @override
  String get calendarEmptyBody =>
      'ஒரு நிகழ்வை சேர்ந்து அடுத்தேற திட்டமிடுங்கள்.';

  @override
  String get calendarPreviousMonth => 'முந்தைய மாதம்';

  @override
  String get calendarNextMonth => 'அடுத்த மாதம்';

  @override
  String get calendarAllDay => 'முழுநாள்';

  @override
  String get calendarOutfitLinked => 'ஆடை இணைக்கப்பட்டது';

  @override
  String get calendarEventOptions => 'நிகழ்வு விருப்பங்கள்';

  @override
  String get calendarDeleteTitle => 'இந்த நிகழ்ச்சியை நீக்க வேண்டுமா?';

  @override
  String get calendarChangeOutfit => 'ஆடை மாற்று';

  @override
  String get calendarLinkOutfit => 'ஆடையை இணை';

  @override
  String get calendarRemoveOutfit => 'ஆடையை நீக்கு';

  @override
  String get calendarNewEvent => 'புதிய நிகழ்ச்சி';

  @override
  String get calendarEditEvent => 'நிகழ்ச்சியை திருத்து';

  @override
  String get calendarTitleLabel => 'தலைப்பு';

  @override
  String get calendarTitleRequired => 'தலைப்பு சேர்க்கவும்';

  @override
  String get calendarEndBeforeStart => 'தொடக்க நேரத்திற்குப் பிறகு முடிக்கவும்';

  @override
  String get calendarStarts => 'தொடக்கம்';

  @override
  String get calendarEnds => 'முடிவு';

  @override
  String get calendarPlaceOptional => 'இடம் (விருப்பம்)';

  @override
  String get calendarNotesOptional => 'குறிப்புகள் (விருப்பம்)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'முதலில் ஒரு ஆடையை தயார் செய்து, அதை இந்த நிகழ்ச்சியுடன் இணைக்கவும்.';

  @override
  String get calendarBuildOutfit => 'ஆடையை தயார் செய்';

  @override
  String get calendarConnectionsTitle => 'இனாட்சரிகள்';

  @override
  String get calendarConnectionsBody =>
      'இங்கே சேர்ப்பீர்களான நிகழ்ச்சிகள் FitCheck-இல் உள்ளேயே இருக்கும்.';

  @override
  String get calendarDisconnect => 'விடுபடுத்த';

  @override
  String get calendarNotAvailable => 'இன்னும் எப்போதும் இல்லை';

  @override
  String get profileSectionExplore => 'ஆராயுங்கள்';

  @override
  String get profileNavTryOn => 'வாட்டிங்';

  @override
  String get profileNavRewards => 'பரிசுகள்';

  @override
  String get profileSupport => 'ஆதரவு';

  @override
  String get profileHelp => 'உதவி';

  @override
  String get profileAbout => 'பற்றி';

  @override
  String get profileAboutBody =>
      'உங்கள் ஆடைக்கோடி, ஆடைச்சேகரம் மற்றும் திட்டங்களை ஒரு இடத்தில்.';

  @override
  String get profileSignOutTitle => 'சைன் அவுட் செய்ய வேண்டுமா?';

  @override
  String get profileSignOutBody =>
      'எப்போது வேண்டுமானாலும் மீண்டும் சைன் இன் செய்யலாம்.';

  @override
  String get profileEditTitle => 'சுயவிவரத்தை திருத்து';

  @override
  String get profileYourProfile => 'உங்கள் சுயவிவரம்';

  @override
  String get profileBodyProfiles => 'உடல் விவரங்கள்';

  @override
  String get profileBodyEmptyTitle => 'உடல் விவரங்கள் இல்லை';

  @override
  String get profileBodyEmptyBody => 'எதிர்மறை சேர்க்கவும், சரியான அளவு பெற.';

  @override
  String get profileBodyAdd => 'விவரம் சேர்';

  @override
  String get profileBodyDefaultNote =>
      'நிமிர்வு விவரம் அளவு மற்றும் முயற்சிக்கு உபயோகம்.';

  @override
  String get profileBodyDefaultBadge => 'நிமிர்வு';

  @override
  String get profileBodyMakeDefault => 'நிமிர்வாக்கு';

  @override
  String get profileBodyDeleteBody => 'இதை மீட்டெடுக்க முடியாது.';

  @override
  String get profileBodyRequired => 'தேவை';

  @override
  String get profileBodyCheckNumber => 'எண்ணைச் சரிபார்க்கவும்';

  @override
  String get profileBodyNew => 'புதிய உடல் விவரம்';

  @override
  String get profileBodyNameHint => 'உதாரணம், நான்';

  @override
  String get profileBodyHeight => 'உயரம்';

  @override
  String get profileBodyWeight => 'கோல்';

  @override
  String get profileBodyBuild => 'உடல்மை';

  @override
  String get profileBodySkinTone => 'போக்கல்';

  @override
  String get profileBirthDateNeededBody =>
      'பிறப்பு நேரத்துடன் தேதி சேர்க்கவும்.';

  @override
  String get profileBirthDateNeededTitle => 'பிறப்பு தேதி தேவை';

  @override
  String get profilePartlySavedBody =>
      'பெயரும் புகைப்படமும் சேமிக்கப்பட்டது. பிறப்பு விவரங்கள் சேமிக்கப்படவில்லை; பின்பு முயற்சிக்கவும்.';

  @override
  String get profilePartlySavedTitle => 'சிலவே சேமித்தது';

  @override
  String get profileSavedBody => 'உங்கள் விவரம் சேமிக்கப்பட்டது.';

  @override
  String get profileChangePhoto => 'புதிய புகைப்படம் மாற்று';

  @override
  String get profilePhotoLabel => 'புகைப்படம்';

  @override
  String get profilePhotoHint => 'புதியது தேர்ந்தெடுக்கத் தட்டுக்கவும்';

  @override
  String get profileBirthDateLabel => 'பிறப்பு தேதி (விருப்பம்)';

  @override
  String get profileBirthTimeLabel => 'பிறப்பு நேரம் (விருப்பம்)';

  @override
  String get profileBirthTimeHelper => 'வேதிய பரிந்துரைகள் துல்லியமாகும்';

  @override
  String get profileBirthPlaceLabel => 'பிறப்பு இடம் (விருப்பம்)';

  @override
  String get profileBirthPlaceHint => 'உதாரணம், புது டெல்லி, இந்தியா';

  @override
  String get profileHelpContactTitle => 'எதை வேண்டுமானாலும் கேளுங்கள்';

  @override
  String get profileHelpContactBody =>
      'செய்தி அனுப்பவும்; நாங்கள் பொதுவாக ஒரு நாளுக்குள் மின்னஞ்சல் மூலம் பதிலளிக்கிறோம்.';

  @override
  String get profileHelpContactAction => 'முகவரிக்கை அனுப்பு';

  @override
  String get profileHelpFaqTitle => 'பொதுவான கேள்விகள்';

  @override
  String get profileFaqAddPiecesTitle => 'எப்படி லாக்கரில் உடை சேர்க்க?';

  @override
  String get profileFaqAddPiecesBody =>
      'லாக்கர் இடுகையில் \'பொருள் சேர்\' என்பதைத் தட்டுங்கள். புகைப்படம் எடுக்கவும் அல்லது தொகுப்பிலிருந்து ஒருதைத் தேர்ந்தெடுக்கவும்; ஒவ்வொரு உடையும் தானாகக் கண்டறிந்து குறிப்பிட்டோம்.';

  @override
  String get profileFaqMatchingTitle => 'ஆடை பொருத்தம் எப்படி வேலை செய்கிறது?';

  @override
  String get profileFaqMatchingBody =>
      'உங்களுக்காக என்று திறந்து உங்களுக்குரிய உடைகளைத் தேர்வு செய்யவும். எது எவற்றுடன் பொருந்துகிறது என்று பரிந்துரைத்து, உங்கள் லாக்கரிலிருந்து முழு ஆடைகளை உருவாக்குகிறோம்.';

  @override
  String get profileFaqTryOnTitle =>
      'என் சொந்தப் புகைப்படங்களை அணிந்து பார்க்கப் பயன்படுத்தலாமா?';

  @override
  String get profileFaqTryOnBody =>
      'ஆம். முழு உடல் நீளமுள்ள ஒரு புகைப்படத்தைச் சேர்க்கவும், பிறகு உங்களைப் போலப் பார்க்க உடைகளைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get profileFaqRewardsTitle => 'பரிசுகளை எப்படி பெறலாம்?';

  @override
  String get profileFaqRewardsBody =>
      'பதிவேற்றங்கள் மற்றும் அணிந்துகளை அடிக்கடி பதிவு செய்யவும். தொடர்ச்சிகள் மற்றும் அடைவுகள் நீங்கள் செல்லும்போது உருவாகும்.';

  @override
  String get profileFaqPrivacyTitle => 'எனது லாக்கர் தனிப்பட்டதா?';

  @override
  String get profileFaqPrivacyBody =>
      'ஆம். ஒன்றைப் பகிர்ந்து கொள்ளும் லிங்க் தவிர உங்கள் லாக்கரும் ஆடைகளும் தனிப்பட்டவை.';

  @override
  String get profileHelpMoreTitle => 'மேலும் உதவி';

  @override
  String get profileHelpGuides => 'கேட்க';

  @override
  String get profileHelpGuidesBody => 'ஒவ்வொரு அம்சமும் எப்படி வேலை செய்கிறது';

  @override
  String get feedbackCategoryBug => 'ஏதாவது சிதைந்தது';

  @override
  String get feedbackCategoryIdea => 'ஒரு யோசனை';

  @override
  String get feedbackCategoryGeneral => 'பொதுவானது';

  @override
  String get feedbackCategoryHelp => 'எனக்கு உதவி தேவை';

  @override
  String get feedbackHintBug =>
      'என்ன நடந்தது, நீங்கள் எதிர்பார்த்தது என்ன? படிகள் சரிசெய்ய உதவுகின்றன.';

  @override
  String get feedbackHintIdea => 'நீங்கள் என்ன விரும்புகிறீர்கள், ஏன்?';

  @override
  String get feedbackHintGeneral =>
      'நீங்கள் என்ன நினைக்கிறீர்கள் என்று சொல்லவும், அல்லது கேள்வியைக் கேட்கவும்.';

  @override
  String get feedbackAttachmentLimitBody => '5 படங்களைச் சேர்க்கலாம்.';

  @override
  String get feedbackAttachmentLimitTitle => 'தொலைவு அடைந்தது';

  @override
  String get feedbackImageTooLargeBody =>
      '5 MB-க்கும் கீழே உள்ள படத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get feedbackImageTooLargeTitle => 'படம் மிகப் பெரியது';

  @override
  String get feedbackTitle => 'பின்னூட்டு அனுப்பு';

  @override
  String get feedbackAboutLabel => 'இது எதன் பற்றியது?';

  @override
  String get feedbackSubjectLabel => 'தலைப்பு';

  @override
  String get feedbackSubjectRequired => 'தலைப்பைச் சேரிக்கவும்';

  @override
  String get feedbackSubjectTooShort => 'தலைப்பு குறைந்தது 3 எழுத்துகள்';

  @override
  String get feedbackDetailsLabel => 'விவரங்கள்';

  @override
  String get feedbackDetailsRequired => 'உள்ளமைப்பைச் சேரிக்கவும்';

  @override
  String get feedbackDetailsTooShort => 'வழக்கமான குறைந்தது 10 எழுத்துகள்';

  @override
  String get feedbackAddScreenshot => 'திரைபொறினை சேரிக்கவும்';

  @override
  String get feedbackAttachmentHint => '5 வரை, 5 MB ஒவ்வொரு';

  @override
  String get feedbackSend => 'அனுப்பு';

  @override
  String get feedbackEmptyTitle => 'இன்னும் எதுவும் அனுப்பப்படவில்லை';

  @override
  String get feedbackEmptyBody =>
      'நீங்கள் அனுப்புவது இங்கே அதன் நிலையுடன் தோன்றும்.';

  @override
  String get feedbackHistoryTitle => 'நீங்கள் அனுப்பியவை';

  @override
  String get feedbackStatusOpen => 'கட்டுப்படுத்தப்படவில்லை';

  @override
  String get feedbackStatusInProgress => 'முன்னேற்றத்தில்';

  @override
  String get feedbackStatusResolved => 'தீர்க்கப்பட்டது';

  @override
  String get feedbackStatusClosed => 'மூடப்பட்டது';

  @override
  String get legalIntro =>
      'உங்கள் தரவுகள் பாதுகாக்கப்படுவதற்கும் FitCheck AI பயன்படுத்தும் விதிகளுமற்றும் சம்பந்தப்பட்ட விதிகள்.';

  @override
  String get legalPolicies => 'கோட்பாடுகள்';

  @override
  String get legalPrivacySubtitle => 'என்ன சேகரிக்கிறோமென்றும் ஏன்';

  @override
  String get legalTermsTitle => 'சேவை விதிமுக';

  @override
  String get legalTermsSubtitle => 'பயன்படுத்தும் விதிகள்';

  @override
  String get legalLicences => 'திறந்த-மூல உரிமங்கள்';

  @override
  String get legalSupportSubtitle => 'உதவி, தொடர்பு மற்றும் தனியுரிமை கோரல்';

  @override
  String get legalReportAbuse => 'சிக்கல் அல்லது தவறான பயன்பாடு தெரிவிக்கவும்';

  @override
  String get permissionCameraTitle => 'கேமராவை அணுக';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI உங்கள் ஆடை மற்றும் உடற்பயிற்சி போட்டோகளை பதிவு செய்யவும், AI அசம்பந்தமான கடை ஒழுங்குபடுத்தும்.';

  @override
  String get permissionPhotoTitle => 'திரைப்படங்களை அணுக';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI உங்கள் ஆடை மற்றும் உடற்பயிற்சி புகைப்படங்களைத் தேர்ந்தெடுக்க உங்களுக்காக AI அம்சங்கள் மற்றும் உங்கள் உடைக்காக அணுகல் தேவைப்படுகிறது.';

  @override
  String get permissionNotNow => 'இப்போது இல்லை';

  @override
  String get permissionOpenSettings => 'அமைப்புகளை திற';

  @override
  String authSignedInAs(String name) {
    return '$name என உள்நுழைந்துள்ளீர்கள்';
  }

  @override
  String get authSignedIn => 'உள்நுழைந்துள்ளீர்கள்';

  @override
  String get authWelcomeBackTitle => 'மீண்டும் வரவேற்கிறோம்';

  @override
  String get authSignInFailed => 'உள்நுழைதல் தோல்வி';

  @override
  String get authWelcomeTitle => 'வரவேற்கிறோம்';

  @override
  String get authSignUpFailed => 'பதிவு தோல்வி';

  @override
  String get authGoogleSignInFailed => 'Google உள்நுழைதல் தோல்வி';

  @override
  String get authAppleSignInFailed => 'Apple உள்நுழைதல் தோல்வி';

  @override
  String get authConfirmEmailTitle => 'அணுகலின் கணக்கை உறுதிப்படுத்துங்கள்';

  @override
  String get authConfirmEmailBody =>
      'உறுதிப்படுத்தல் அணுகலை உங்கள் உள்ளுங்கள் பட்டியலில் பார்த்து, உள்நுழையவும்.';

  @override
  String get authClosetReady => 'உங்கள் ஆடை அலக்கம் தயார்.';

  @override
  String get authSignedOutTitle => 'வெளியேற்றப்பட்டார்';

  @override
  String get authSignedOutBody => 'நீங்கள் வெளியேற்றப்பட்டீர்கள்.';

  @override
  String get authSignOutFailed => 'வெளியேற்றம் தோல்வி';

  @override
  String get authEmailSentTitle => 'அணுகல் அனுப்பப்பட்டது';

  @override
  String get authResetLinkSent => 'மீட்பு இணைக்களை உங்கள் அணுகலில் பார்த்து.';

  @override
  String get authPasswordUpdatedTitle => 'கடவுச்சொல் புதுப்பிக்கப்பட்டது';

  @override
  String get authPasswordUpdated => 'உங்கள் கடவுச்சொல் புதுப்பிக்கப்பட்டது.';

  @override
  String get authPasswordNotUpdated => 'கடவுச்சொல் புதுப்பிக்கப்படவில்லை';

  @override
  String get authCouldNotSendEmail => 'அணுகலை அனுப்ப முடியவில்லை';

  @override
  String get authEmailNotSent => 'அணுகல் அனுப்பப்படவில்லை';

  @override
  String get authResendSentBody =>
      'ஒரு புதிய உறுதிப்படுத்தல் அணுகலை அனுப்பியுள்ளோம்.';

  @override
  String get outfitPreviewWithAi => 'AI மூலம் பார்வையிடுங்கள்';

  @override
  String get outfitNewPreview => 'புதிய பார்வை உருவாக்குங்கள்';

  @override
  String get outfitBuilderClosetHeading => 'உங்கள் ஆடை அலக்கம்';

  @override
  String get outfitBuilderSearchHint => 'வெட்டுகளைத் தேடுங்கள்';

  @override
  String get outfitClearSearch => 'தேடலை அழிவு';

  @override
  String get outfitBuilderAddPiecesTitle => 'முதலில் வெட்டுகளை சேர்';

  @override
  String get outfitBuilderAddPiecesBody =>
      'ஆடை அலக்கங்களில் உள்ள வெட்டுகளிலிருந்து ஆடை உருவாக்கப்படுகின்றன.';

  @override
  String get outfitBuilderNoMatches => 'தக்கவைந்த வெட்டுகள் இல்லை.';

  @override
  String get outfitNameLabel => 'ஆடை பெயர்';

  @override
  String get outfitNameHint => 'உதாரணமாக, வெக்கண்ட் லினன்';

  @override
  String get outfitPreviewSemantic => 'அட்டிபுரிகளின் AI முன்னோட்டம்';

  @override
  String get outfitChoosePieces => 'சாமான்களைத் தேர்ந்தெடுக்கவும்';

  @override
  String get outfitTapPiecesHint => 'சேர்க்க கீழே உள்ள சாமான்களில் தட்டவும்.';

  @override
  String get outfitShareTooltip => 'பகிர்';

  @override
  String get outfitSaveFavourite => 'பிடித்த பட்டியலில் சேமிக்கவும்';

  @override
  String get outfitPiecesHeading => 'சாமான்கள்';

  @override
  String get outfitWearHistoryEmpty =>
      'முதலில் ஒரு முறை அணிந்தால் தேதிகள் இங்கு தோன்றும்.';

  @override
  String get outfitWearHistoryTitle => 'அணிந்த வரலாறு';

  @override
  String get outfitWearHistoryError => 'தேதிகளைப் பதிவிறக்க முடியவில்லை.';

  @override
  String get outfitWornOn => 'அணிந்த தேதி';

  @override
  String get outfitEditTitle => 'அட்டியுரையைத் திருத்து';

  @override
  String get outfitSavedPhotosFailed =>
      'விவரங்கள் சேமிக்கப்பட்டன, புகைப்படங்கள் அல்ல';

  @override
  String get outfitNoPhotosBody =>
      'புகைப்படங்கள் இல்லை. அதற்குப் பதிலாக சாமான்கள் காட்டப்படும்.';

  @override
  String get outfitOccasionLabel => 'பொருளாதாரம்';

  @override
  String get outfitOccasionNone => 'இல்லை';

  @override
  String get outfitTagsHint => 'காமாக்கொடு பிரிக்கவும்';

  @override
  String get outfitDraftBody => 'உங்கள் முக்கிய பட்டியலில் மறைக்கப்பட்டுள்ளது';

  @override
  String get outfitPublic => 'பலர்';

  @override
  String get outfitPublicBody => 'இணைப்பைப் பெற்ற யாருக்கும் தெரியும்';

  @override
  String get outfitDeleteFromDetail =>
      'இந்த அட்டியுரையை அதன் விவரப் பக்கத்திலிருந்து நீக்குக.';

  @override
  String get outfitNewCollection => 'புதிய தொகுப்பு';

  @override
  String get outfitNoCollectionsTitle => 'தொகுப்புகள் இல்லை';

  @override
  String get outfitNoCollectionsBody =>
      'பயணம், பருவம் அல்லது மனநிலைப்படி அட்டியுரையைத் தொகுப்புகளாகப் பிரிக்கவும்.';

  @override
  String get outfitCreateCollection => 'தொகுப்பை உருவாக்கு';

  @override
  String get outfitAddOutfits => 'அட்டியுரையைச் சேர்';

  @override
  String get outfitRename => 'பெயர் மாற்று';

  @override
  String get outfitCollectionDeleteBody =>
      'அதிலுள்ள அட்டியுரையுறைகள் வைக்கப்படுகின்றன.';

  @override
  String get outfitCollectionsNotLoaded =>
      'அட்டியுரையுறைகள் பதிவிறக்கப்படவில்லை';

  @override
  String get outfitRenameCollection => 'தொகுப்பின் பெயரை மாற்று';

  @override
  String get outfitDescriptionOptional => 'விளக்கம் (விருப்பம்)';

  @override
  String get outfitAllInCollection => 'அனைத்து ஆடையங்களும் இப்பதிவில் இல்லை.';

  @override
  String get photoshootSubtitleUpload =>
      'உங்கள் புகைப்படங்களிலிருந்து ஸ்டுடியோ பார்ட்ரெட்ஸ்';

  @override
  String get photoshootSubtitleConfigure =>
      'ஒரு பாணியை, வடிவத்தை எண்ணிக்கையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get photoshootSubtitleGenerating =>
      'இது ஒரேயோ இரண்டு நிமிடங்களாவது ஆகும்';

  @override
  String get photoshootAddPhotosSemantic =>
      'உங்கள் கேலரியிலிருந்து புகைப்படங்களைச் சேர்க்கவும்';

  @override
  String get photoshootUploadTitle =>
      'உங்களுக்கான புகைப்படங்களை 1 முதல் 4 வரை சேர்க்கவும்';

  @override
  String get photoshootUploadBody => 'கேலரியிலிருந்து தேர்ந்தெடுக்க தட்டுவும்';

  @override
  String get photoshootAddToContinue => 'தொடர ஒரு புகைப்படம் சேர்க்கவும்';

  @override
  String get photoshootAddAnotherPhoto => 'மற்றொரு புகைப்படம் சேர்க்கவும்';

  @override
  String get photoshootTipsTitle => 'சிறந்த முடிவுகளுக்கு';

  @override
  String get photoshootTipsBody =>
      'உங்கள் முகத்தின் தெளிவான, நல்ல ஒளியில் சில கோணங்களில் புகைப்படங்களைப் பயன்படுத்தவும். சூரியன் கண்ணாடிகள் மற்றும் டீவியை நிராகரிக்கவும்.';

  @override
  String get photoshootStarting => 'தொடங்குகிறது';

  @override
  String get photoshootCancelling => 'ரத்து செய்கிறது';

  @override
  String get photoshootFailed => 'தோல்வி';

  @override
  String get recommendTabMatches => 'சேர்ப்புகள்';

  @override
  String get recommendTabComplete => 'முழுமையானது';

  @override
  String get recommendTabWeather => 'வானிலை';

  @override
  String get recommendTabColours => 'நிறங்கள்';

  @override
  String get recommendTabShop => 'வாங்குதல்';

  @override
  String get recommendNoMatchesTitle => 'இன்னும் சேர்ப்புகள் இல்லை';

  @override
  String get recommendNoMatchesBody =>
      'ஒரு பகுதியைத் தேர்வு செய்தால், அதனுடன் பொருந்தும் காட்சியை கண்டறியும்.';

  @override
  String get recommendPickPiece => 'பகுதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get recommendNothingMatchesTitle =>
      'இன்னும் இதுகாண்டும் பொருந்தவில்லை';

  @override
  String get recommendNothingMatchesBody =>
      'மற்ற பகுதிகளை முயற்சிக்கவும், அல்லது உங்கள் களர்டை திறன் அளிக்கவும்.';

  @override
  String get recommendChangePieces => 'பகுதிகளை மாற்றவும்';

  @override
  String get recommendDefaultReason =>
      'நீங்கள் தேர்ந்தெடுத்த பகுதிகளுக்கு அது பொருந்துகிறது.';

  @override
  String get recommendCompleteTitle => 'ஒரு காட்சியை முழுமைப்படுத்து';

  @override
  String get recommendCompleteBody =>
      'ஒரு பகுதியைத் தேர்வு செய்தால், மற்றவை நிரப்பும்.';

  @override
  String get recommendWorking => 'பணிபுரிவது';

  @override
  String get recommendGenerate => 'உருவாக்கு';

  @override
  String get recommendChooseStyleBody =>
      'எதிர்கொள்ளும் பாணைத் தேர்வு செய்யவும்.';

  @override
  String get recommendNoLooksTitle => 'இந்த ஆடைகளுக்கு ஏற்பு இல்லை';

  @override
  String get recommendNoLooksBody =>
      'வேறு பாணை அல்லது வேறு ஆடைகளை முயற்சிக்கவும்.';

  @override
  String get recommendDefaultLook => 'உங்கள் ஆடைகளுக்கு ஏற்ற போர்ம';

  @override
  String get recommendNoPiecesBody => 'இந்த போர்மிக்கு ஆடைகள் திரும்பவில்லை.';

  @override
  String get recommendCityLabel => 'நகரம்';

  @override
  String get recommendCheck => 'பரிசோதி';

  @override
  String get recommendWeatherTitle => 'இன்று வானிலை என்ன?';

  @override
  String get recommendWeatherBody =>
      'இன்றைய தேர்வுகளுக்கு உங்கள் நகரத்தை உள்ளிடவும்.';

  @override
  String get recommendWearToday => 'இன்று அணிவது';

  @override
  String get recommendWeatherNoPieces =>
      'இந்த வானிலைக்கு உங்கள் அலமாரியில் ஆடைகள் இல்லை.';

  @override
  String get recommendBudgetLabel => 'மத்தியமான வரம்பு';

  @override
  String get recommendLooking => 'தேடு';

  @override
  String get recommendFindWhatToBuy => 'ஏதோ வாங்க வேண்டும்';

  @override
  String get recommendFillGapsTitle => 'தட்டுப்பாடுகளை நிரப்ப';

  @override
  String get recommendFillGapsBody =>
      'மத்திய வரம்பை அமைத்து, உங்கள் அலமாரியில் இல்லாதவற்றை பரிந்துரைக்கின்றோம்.';

  @override
  String get recommendNoGapsTitle => 'தட்டுப்பாடுகள் இல்லை';

  @override
  String get recommendNoGapsBody =>
      'மத்தியமான வரம்பை அல்லது வேறு பிரிவை முயற்சிக்கவும்.';

  @override
  String get recommendMoodEveryday => 'நிர்வரி';

  @override
  String get recommendMoodBigMeeting => 'பெரிய கண்காட்சி';

  @override
  String get recommendDayLabel => 'நாள்';

  @override
  String get recommendReadingStars => 'நட்சத்திரங்களை படிக்கிறது';

  @override
  String get recommendGetMyColours => 'என் நிறங்களை பெறு';

  @override
  String get recommendLuckyColoursTitle => 'உங்கள் வரவுள்ள நிறங்கள்';

  @override
  String get recommendLuckyColoursBody =>
      'ஒரு நாளை தேர்வு செய்தால், அதற்குரிய நிறங்களும் ஆடைகளும் பரிந்துரைக்கப்படும்.';

  @override
  String get recommendLuckyColoursSection => 'வரவுள்ள நிறங்கள்';

  @override
  String get recommendAvoidColoursSection => 'கவனமாக இருக்க வேண்டிய நிறங்கள்';

  @override
  String get recommendBirthDateTitle => 'உங்கள் பிறந்த தேதியை சேர்க்க';

  @override
  String get recommendBirthDateBody =>
      'உங்கள் நிறங்களை படிக்க பிறந்த தேதி தேவை.';

  @override
  String get recommendEditProfile => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get recommendNothingThisDay => 'இன்று எதுவும் இல்லை.';

  @override
  String get recommendUnnamedColour => 'பெயரிடப்படாத நிறம்';

  @override
  String get recommendFromCloset => 'உங்கள் ஆடை அலமாரியிலிருந்து';

  @override
  String get recommendNoPiecesInColours =>
      'இந்த நிறங்களில் ஆடைகள் இன்னும் இல்லை.';

  @override
  String get recommendOutfitIdeas => 'ஆடை இலக்கியங்கள்';

  @override
  String get recommendNoOutfitsInColours =>
      'இந்த நிறங்களில் முழு ஆடை இன்னும் இல்லை.';

  @override
  String get recommendDefaultOutfitIdea => 'ஆடை யோசனை';

  @override
  String get recommendPickUpToThree => 'மூன்று ஆடைகள் வரை தேர்ந்தெடுக்கவும்';

  @override
  String get recommendEmptyClosetBody =>
      'முதலில் சில ஆடைகளைச் சேர்்த்து, பிறகு பொருத்தங்களுக்கு மீண்டும் வருங்கள்.';

  @override
  String get dashboardDressForDay => 'வரும் நாளுக்கு ஆடை அணியுங்கள்.';

  @override
  String get dashboardOutfitOfDay => 'இன்றைய ஆடை';

  @override
  String get dashboardFreshLook => 'புதிய தோற்றம்';

  @override
  String get subscriptionManageInStoreTitle => 'கடை மூலம் நிர்வகிக்கவும்';

  @override
  String get subscriptionManageInStoreBody =>
      'இந்த பதிவினை கடை வழியாக விலை வசூலிக்கப்படும். இதை உங்கள் கடை கணக்கு அமைப்புகளில் நிர்வகிக்கவும்.';

  @override
  String get subscriptionCancelledTitle => 'பதிவு ரத்து செய்யப்பட்டது';

  @override
  String get subscriptionCancelledBody =>
      'உங்கள் திட்டம் இந்தக் கட்டணம் காலகட்டத்தின் முடிவு வரை செயலில் இருக்கும்.';

  @override
  String get subscriptionCancelFailedTitle => 'ரத்து செய்ய முடியவில்லை';

  @override
  String get subscriptionCouldNotOpenTitle => 'திறக்க முடியவில்லை';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'கட்டணம் மேலாண்மை திறக்க முடியவில்லை.';

  @override
  String get subscriptionOpenLinkFailedBody =>
      'கிண்ணத்தைத் திறக்க முடியவில்லை.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'உங்கள் லிங்க் ஏற்ற முடியவில்லை';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'உங்கள் பரிந்துரை லிங்க் ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get subscriptionReferralCopiedTitle => 'நகலெடுக்கப்பட்டது';

  @override
  String get subscriptionReferralCopiedBody =>
      'பரிந்துரை லிங்க் நகலெடுக்கப்பட்டது.';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI முயற்சிக்கவும்';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI இல் சேரவும், நாங்களும் இருவரும் Pro மாதம் பெறுவோம். $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'லிங்க் நகலெடுக்கப்பட்டது';

  @override
  String get subscriptionShareUnavailableBody =>
      'பகிர்வு கிடைக்கவில்லை, எனவே லிங்க் நகலெடுக்கப்பட்டது.';

  @override
  String get subscriptionShareFailedTitle => 'பகிர முடியவில்லை';

  @override
  String get subscriptionShareFailedBody =>
      'பிரமாண பக்கத்திலிருந்து இணைப்பை நகலெடுக்கவும்.';

  @override
  String get subscriptionStoreReadyTitle => 'கடை தயார்';

  @override
  String get subscriptionStoreReadyBody =>
      'கடை விலைகள் கிடைக்கின்றன. இப்போது மேம்படுத்தலாம்.';

  @override
  String get purchaseFailedTitle => 'கொள்முதல் தோல்வி';

  @override
  String get purchaseUnavailableTitle => 'கொள்முதல் கிடைக்கவில்லை';

  @override
  String get purchaseIapUnavailableBody =>
      'இந்த சாதனத்தில் உள்ள அப் பணமும் உடக்குகிறது.';

  @override
  String get purchasePlanNotAvailableBody =>
      'இந்த திட்டம் இன்னும் கொள்முதலுக்கு கிடைக்கவில்லை.';

  @override
  String get purchasePlanNotInStoreBody =>
      'இந்த திட்டம் கடைக்கில் இன்னும் இல்லை. விரைவில் மீண்டும் பார்க்கவும்.';

  @override
  String get purchaseStartFailedBody =>
      'கொள்முதல் தொடங்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'பயன்பாட்டுக் குறிப்பில் பணம் திரும்பவிலங்கில்லை.';

  @override
  String get purchasePendingTitle => 'கொள்முதல் நிலுவையில்';

  @override
  String get purchasePendingBody =>
      'உங்கள் கொள்முதல் ஒப்புதலுக்காக காத்திருக்கிறது. அங்கீகரிக்கப்படும்போது அணுகல் கிடைக்கும்.';

  @override
  String get purchaseFailedBody => 'கொள்முதல் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get purchaseRestoredTitle => 'மீட்கப்பட்டது';

  @override
  String get purchaseRestoredBody => 'உங்கள் கொள்முதல்கள் மீட்கப்பட்டுள்ளன.';

  @override
  String get purchaseActiveTitle => 'சந்தா செயல்பாட்டில்';

  @override
  String get purchaseActiveBody =>
      'உங்கள் சந்தா செயல்பாட்டில் உள்ளது. வாருங்கள்.';

  @override
  String get purchaseSignInRequiredTitle => 'உள்நுழைவு தேவை';

  @override
  String get purchaseSignInRequiredBody =>
      'உங்கள் கொள்முதலை முடிக்க உள்நுழையவும்.';

  @override
  String get purchaseErrorTitle => 'கொள்முதல் பிழை';

  @override
  String get purchaseInvalidTransactionBody =>
      'கொள்முதலில் சரிபார்க்கக்கூடிய பரிவர்த்தனை எண் இல்லை.';

  @override
  String get purchaseVerificationPendingTitle => 'சரிபார்ப்பு நிலுவையில்';

  @override
  String get purchaseVerificationPendingBody =>
      'இப்போது கடை உங்கள் கொள்முதலை சரிபார்க்க முடியவில்லை. அது தானாக முடியும், இரண்டு முறை பணம் பெறப்படாது.';

  @override
  String get purchaseNotAppliedTitle => 'கொள்முதல் செலுத்தப்படவில்லை';

  @override
  String get purchaseNotAppliedBody =>
      'உங்கள் கொள்முதல் உங்கள் கணக்கில் சேர்க்க முடியவில்லை. ஆதரவை தொடர்பு கொள்ளுங்கள், மீண்டும் வாங்க வேண்டாம்.';

  @override
  String get purchaseRestoreFailedTitle => 'மீட்பு தோல்வி';

  @override
  String get purchaseRestoreFailedBody =>
      'கொள்முதல்களை மீட்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get purchaseRecoveredActiveBody =>
      'உங்கள் சந்தா செயல்பாட்டில் உள்ளது.';

  @override
  String get purchaseCompleteTitle => 'கொள்முதல் முடிந்தது';

  @override
  String get giftCreateFailedTitle => 'பரிசு உருவாக்க முடியவில்லை';

  @override
  String get giftClaimFailedTitle => 'பரிசு பெற முடியவில்லை';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பரிசுகள் உங்களுக்காக',
      one: 'உங்களுக்கான ஒரு பரிசு',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 மாதம்',
      '12': '1 ஆண்டு',
      'other': '$months மாதங்கள்',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining மீதம்',
      one: '1 மீதம்',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro க்கான $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender உங்களுக்கு FitCheck Pro இன் $duration அனுப்பினார். $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient க்கு FitCheck Pro பரிசு';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender இலிருந்து';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient க்கு';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender இலிருந்து';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'உங்கள் பெறுநர்';

  @override
  String get giftPreviewPlaceholderSender => 'நீங்கள்';

  @override
  String get settingsSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String get settingsNotSavedTitle => 'சேமிக்கப்படவில்லை';

  @override
  String get settingsAiChooseProviderBody =>
      'ஒரு நிறுவனத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'தனிப்பயன் வழங்குநருக்கு API URL தேவை.';

  @override
  String get settingsAiKeyRequiredBody => 'API விடையை உள்ளிடவும்.';

  @override
  String get settingsAiSavedBody => 'உங்கள் AI அமைப்புகள் சேமிக்கப்பட்டன.';

  @override
  String get settingsAiMissingDetailsTitle => 'விவரங்கள் இல்லாது';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'சோதனைக்காக API URL மற்றும் ஒரு சாட் மாதிரியை உள்ளிடவும்.';

  @override
  String get settingsAiKeyNeededTitle => 'API விடையுக்கு தேவை';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'சோதனைக்காக உங்கள் API விடையை உள்ளிடவும். உங்கள் சேமிக்கப்பட்ட விடை தனிப்பட்டது.';

  @override
  String get settingsAiKeyToTestBody =>
      'சோதனைக்காக உங்கள் API விடையை உள்ளிடவும்.';

  @override
  String get settingsAiConnectedTitle => 'இணைக்கப்பட்டது';

  @override
  String get settingsAiConnectedBody => 'இணைப்பு வேலை செய்கிறது.';

  @override
  String get settingsAiTestFailedTitle => 'சோதனை தோல்வியடைந்தது';

  @override
  String get settingsPreferencesSavedBody =>
      'உங்கள் விருப்பங்கள் சேமிக்கப்பட்டன.';

  @override
  String get settingsPasswordNotChangedTitle => 'கடவுச்சொல் மாற்றப்படவில்லை';

  @override
  String get settingsOAuthPasswordBody =>
      'இந்த கணக்கு Google அல்லது Apple மூலம் உள்நுழைகிறது. முதலில் \"கடவுச்சொல் மறந்துவிட்டது\" மூலம் கடவுச்சொல்லை அமைக்கவும்.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'தற்போதைய கடவுச்சொல் தவறானது.';

  @override
  String get settingsExportReadyTitle => 'ஏற்றுமதி தயார்';

  @override
  String get settingsExportReadyBody =>
      'உங்கள் தரவு ஏற்றுமதி பதிவிறக்கத்திற்கு தயாராக உள்ளது.';

  @override
  String get settingsLinkCopiedTitle => 'இணைப்பு நகலெடுக்கப்பட்டது';

  @override
  String get settingsExportClipboardBody =>
      'உங்கள் உலாவியைத் திறக்க முடியவில்லை, எனவே பதிவிறக்க இணைப்பை நகலெடுத்தோம். விரைவில் அதை ஒரு உலாவியில் ஒட்டவும்: அது காலாவதியாகும்.';

  @override
  String get settingsExportFailedTitle => 'ஏற்றுமதி தோல்வி';

  @override
  String get settingsAccountNotDeletedTitle => 'கணக்கு நீக்கப்படவில்லை';

  @override
  String photoshootPhotoLimit(int max) {
    return 'அதிகபட்சம் $max புகைப்படங்களை சேர்க்க முடியும்.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'புகைப்பட வரம்பு';

  @override
  String get photoshootAddAtLeastOnePhoto =>
      'அதிகபட்சமாக ஒரு புகைப்படத்தை சேர்க்கவும்.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'புகைப்படங்கள் இல்லை';

  @override
  String get photoshootDescribeLookBody =>
      'நீங்கள் விரும்பும் தோற்றத்தை விவரிக்கவும்.';

  @override
  String get photoshootPromptNeededTitle => 'சொற்றொடர் தேவை';

  @override
  String get photoshootConsentFeatureLabel => 'AI புகைப்பட எடுத்துக்காட்டு';

  @override
  String get photoshootStatusPreparing =>
      'உங்கள் புகைப்படங்களை தயார் செய்கிறது';

  @override
  String get photoshootStatusGenerating => 'உருவாக்குகிறது';

  @override
  String photoshootStatusBatch(int current, int total) {
    return '$total இல் $current தொகுதி';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$total இல் $done முடிந்தது';
  }

  @override
  String get photoshootGenerationFailedBody => 'உருவாக்கம் தோல்வியடைந்தது.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready தயார், $failed தோல்வி.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'பகுதியாக முடிந்தது';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புகைப்படங்கள் தயாராக உள்ளன.',
      one: '1 புகைப்படம் தயாராக உள்ளது.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'இணைப்பு இழக்கப்பட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get photoshootCouldNotCancelTitle => 'ரத்து செய்ய முடியவில்லை';

  @override
  String get photoshootRetryFailedTitle => 'மீண்டும் முயற்சி தோல்வி';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'புகைப்படம் $number தயாராக உள்ளது.';
  }

  @override
  String get photoshootReplacedTitle => 'மாற்றப்பட்டது';

  @override
  String get photoshootSavedToGalleryBody =>
      'உங்கள் கலகரியில் சேமிக்கப்பட்டது.';

  @override
  String get photoshootSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String get photoshootNotSavedTitle => 'சேமிக்கப்படவில்லை';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'அனைத்து $count புகைப்படங்களும் உங்கள் கலகரியில் உள்ளன.',
      one: '1 புகைப்படம் உங்கள் கலகரியில் உள்ளது.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved/$total சேமிக்கப்பட்டது.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'சில புகைப்படங்கள் சேமிக்கப்படவில்லை';

  @override
  String get tryonConsentFeatureLabel => 'வெர்ச்சுவல் ட்ரை-ஆன்';

  @override
  String get tryonAvatarUpdatedBody => 'உங்கள் புகைப்படம் புதுப்பிக்கப்பட்டது.';

  @override
  String get tryonSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String get tryonUploadFailedTitle => 'பதிவேற்றம் தோல்வியடைந்தது';

  @override
  String get tryonChooseGarmentFirstBody =>
      'முதலில் ஒரு ஆடைப் புகைப்படத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get tryonNoGarmentTitle => 'ஆடை இல்லை';

  @override
  String get tryonWaitForUploadBody =>
      'உங்கள் புகைப்படம் முழுமையாகப் பதிவேறும் வரை காத்திருக்கவும்.';

  @override
  String get tryonStillUploadingTitle => 'இன்னும் பதிவேற்றத்தில்';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'முதலில் உங்கள் சொந்த புகைப்படத்தைச் சேர்க்கவும்.';

  @override
  String get tryonReadyBody => 'உங்கள் ட்ரை-ஆன் தயாராக உள்ளது.';

  @override
  String get tryonFailedTitle => 'ட்ரை-ஆன் தோல்வியடைந்தது';

  @override
  String get tryonSavedToGalleryBody => 'உங்கள் கேலரியில் சேமிக்கப்பட்டது.';

  @override
  String get tryonNotSavedTitle => 'சேமிக்கப்படவில்லை';

  @override
  String get calendarEventAddedBody => 'நிகழ்வு சேர்க்கப்பட்டது';

  @override
  String get calendarEventPlannedTitle => 'திட்டமிடப்பட்டது';

  @override
  String get calendarEventSavedBody => 'நிகழ்வு சேமிக்கப்பட்டது';

  @override
  String get calendarSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String get calendarEventNotSavedTitle => 'நிகழ்வு சேமிக்கப்படவில்லை';

  @override
  String get calendarEventRemovedBody => 'நிகழ்வு அகற்றப்பட்டது';

  @override
  String get calendarEventDeletedTitle => 'நீக்கப்பட்டது';

  @override
  String get calendarEventNotDeletedTitle => 'நிகழ்வு நீக்கப்படவில்லை';

  @override
  String get calendarOutfitNotLinkedTitle => 'அலங்காரம் இணைக்கப்படவில்லை';

  @override
  String get calendarLinkedTitle => 'இணைக்கப்பட்டது';

  @override
  String get calendarOutfitNotRemovedTitle => 'அலங்காரம் அகற்றப்படவில்லை';

  @override
  String get calendarOutfitRemovedBody => 'அலங்காரம் அகற்றப்பட்டது';

  @override
  String get calendarDisconnectedBody => 'நாட்காட்டி பிரிக்கப்பட்டது';

  @override
  String get calendarDisconnectedTitle => 'பிரிக்கப்பட்டது';

  @override
  String get calendarNotDisconnectedTitle => 'நாட்காட்டி பிரிக்கப்படவில்லை';

  @override
  String get calendarTodayLabel => 'இன்று';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நிகழ்வுகள்',
      one: '1 நிகழ்வு',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start முதல் $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, தோர்த்து இணைக்கப்பட்டது';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" நீக்கப்படும்.';
  }

  @override
  String get calendarThisAppLabel => 'இந்த செயலி';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider உடன் ஒத்திசைவு இன்னும் கிடைக்கவில்லை. நீங்கள் இங்கே நிகழ்வுகளை சேர்க்க முடியும்.';
  }

  @override
  String get calendarWeekdaySunShort => 'ஞா';

  @override
  String get calendarWeekdayMonShort => 'தி';

  @override
  String get calendarWeekdayTueShort => 'செ';

  @override
  String get calendarWeekdayWedShort => 'பு';

  @override
  String get calendarWeekdayThuShort => 'வீ';

  @override
  String get calendarWeekdayFriShort => 'வெ';

  @override
  String get calendarWeekdaySatShort => 'சூ';

  @override
  String get calendarWeekdayMonday => 'திங்கள்';

  @override
  String get calendarWeekdayTuesday => 'செவ்வாய்';

  @override
  String get calendarWeekdayWednesday => 'புதன்';

  @override
  String get calendarWeekdayThursday => 'வியாழன்';

  @override
  String get calendarWeekdayFriday => 'வெள்ளி';

  @override
  String get calendarWeekdaySaturday => 'சனி';

  @override
  String get calendarWeekdaySunday => 'ஞாயிறு';

  @override
  String get outfitSavedToFavouritesBody =>
      'விருப்ப பட்டியலில் சேமிக்கப்பட்டது';

  @override
  String get outfitRemovedFromFavouritesBody =>
      'விருப்ப பட்டியலில் இருந்து நீக்கப்பட்டது';

  @override
  String get outfitNotSavedTitle => 'சேமிக்கப்படவில்லை';

  @override
  String get outfitLoggedAsWornBody => 'இன்று அணிந்ததாக பதிவு செய்யப்பட்டது.';

  @override
  String get outfitNicePickTitle => 'நல்ல தேர்வு';

  @override
  String get outfitRemovedBody => 'தோர்த்து நீக்கப்பட்டது.';

  @override
  String get outfitDeletedTitle => 'நீக்கப்பட்டது';

  @override
  String get outfitNotDeletedTitle => 'நீக்கப்படவில்லை';

  @override
  String get outfitDuplicatedBody => 'ஒரு நகல் உங்கள் சேகரிப்பில் உள்ளது.';

  @override
  String get outfitDuplicatedTitle => 'நகல் ஆக்கப்பட்டது';

  @override
  String get outfitNotDuplicatedTitle => 'நகல் ஆகவில்லை';

  @override
  String get outfitNotSharedTitle => 'பகிரப்படவில்லை';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" தயார்.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'சேகரிப்பு உருவாக்கப்படவில்லை';

  @override
  String get outfitCollectionUpdatedBody => 'சேகரிப்பு புதுப்பிக்கப்பட்டது.';

  @override
  String get outfitCollectionNotUpdatedTitle =>
      'சேகரிப்பு புதுப்பிக்கப்படவில்லை';

  @override
  String get outfitCollectionDeletedBody => 'சேகரிப்பு நீக்கப்பட்டது.';

  @override
  String get outfitCollectionNotDeletedTitle => 'சேகரிப்பு நீக்கப்படவில்லை';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உடைகள் சேர்க்கப்பட்டன.',
      one: '1 உடை சேர்க்கப்பட்டது.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'உடைகள் சேர்க்கப்படவில்லை';

  @override
  String get outfitPreviewNotCreatedTitle => 'முன்னோட்டம் உருவாக்கப்படவில்லை';

  @override
  String get outfitGiveNameBody => 'உடைக்கு ஒரு பெயர் அளிக்கவும்.';

  @override
  String get outfitNameMissingTitle => 'பெயர்';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'குறைந்தது ஒரு உடையை தேர்வு செய்யவும்.';

  @override
  String outfitCreatedBody(String name) {
    return '$name உங்கள் சேகரிப்பில் உள்ளது.';
  }

  @override
  String get outfitSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String get wardrobeAddedToFavouritesBody =>
      'பிடித்தபட்டவற்றில் சேர்க்கப்பட்டது';

  @override
  String get wardrobeRemovedFromFavouritesBody =>
      'பிடித்தபட்டவற்றிலிருந்து நீக்கப்பட்டது';

  @override
  String get wardrobeNotSavedTitle => 'சேமிக்கப்படவில்லை';

  @override
  String get wardrobeLoggedAsWornBody => 'இன்று அணிந்ததாக பதிவு செய்யப்பட்டது.';

  @override
  String get wardrobeRemovedFromClosetBody =>
      'உங்கள் ஒப்பில்லிலிருந்து நீக்கப்பட்டது.';

  @override
  String get wardrobeDeletedTitle => 'நீக்கப்பட்டது';

  @override
  String get wardrobeNotDeletedTitle => 'நீக்கப்படவில்லை';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உடைகள் உங்கள் ஒப்பிலிலிருந்து நீக்கப்பட்டன.',
      one: '1 உடை உங்கள் ஒப்பிலிலிருந்து நீக்கப்பட்டது.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI ஒப்பில் விவரம்';

  @override
  String get itemAddScanJobLabel => 'எடு';

  @override
  String get itemAddFoundEarlierBody => 'முந்தைய ஸ்கேனில் கண்டறியப்பட்டது';

  @override
  String get itemAddLookingAtPhoto => 'உங்கள் படத்தைப் பார்த்து வருகிறது';

  @override
  String get itemAddExtractionFailedBody => 'எடுப்பதில் தோல்வி';

  @override
  String get itemAddJobFailedBody => 'வேலை தோல்வி';

  @override
  String get itemAddConnectionLostBody =>
      'இணைப்பு இழக்கப்பட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'செயலாக்கirken இணைப்பு இழக்கப்பட்டது.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'பொருள் $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'பொருள்';

  @override
  String get itemAddNotCancelledTitle => 'ரத்து செய்யப்படவில்லை';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பொருட்கள் உங்கள் உடைத்தொகுப்பில் உள்ளன.',
      one: 'உங்கள் உடைத்தொகுப்பில் 1 பொருள் உள்ளது.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$total பொருட்களில் $saved சேமிக்கப்பட்டன. மீதி சேமிக்க காப்பிட்டு அழுத்தவும்.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'சில பொருட்கள் சேமிக்கப்படவில்லை';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'குறைந்தது ஒரு படத்தை தேர்வுசெய்யவும்.';

  @override
  String get batchPhotoUnreadableBody => 'இந்தப் படிவத்தை படிக்க முடியவில்லை.';

  @override
  String get batchNoPhotosReadableBody =>
      'இந்தப் படங்களைப் படிக்க முடியவில்லை. வேறு படங்களை முயற்சிக்கவும்.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count படங்கள்',
      one: '1 படம்',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'வேலை நடைபெறும் போது இணைப்பு இழக்கப்பட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get batchNotCancelledTitle => 'ரத்து செய்யப்படவில்லை';

  @override
  String get batchPostLinkUnsupportedBody =>
      'பதிவு இணைப்புகள் ஆதரிக்கப்படவில்லை. சுயவிவர இணைப்பை உள்ளிடவும்.';

  @override
  String get batchLinkSpacesBody => 'இணைப்புகளில் இடைவெளிகள் இருக்கக்கூடாது.';

  @override
  String get batchEnterProfileLinkBody =>
      'இன்ஸ்டாகிராம் அல்லது ஃபேஸ்புக் சுயவிவர இணைப்பை உள்ளிடவும்.';

  @override
  String get batchEnterProfileLinkShortBody => 'சுயவிவர இணைப்பை உள்ளிடவும்.';

  @override
  String get batchSignInPageNotOpenBody =>
      'உள்நுழைவு பக்கம் திறக்கப்படவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get batchSignInBrowserBody =>
      'உங்கள் புரோஸரில் உள்நுழைந்து, பின்னர் FitCheck திரும்பவும்.';

  @override
  String get batchConnectAccountTitle => 'உங்கள் கணக்கை இணைக்கவும்';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'உங்கள் உரைநாற்பதன் செயலியிலிருந்து குறியீட்டை உள்ளிடவும்.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'இன்ஸ்டாகிராம் பாதுகாப்பு சோதனை விரும்புகிறது. முதலில் உங்கள் புரோஸரில் உள்நுழையவும்.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'உங்கள் பயன பெயரையும் கடவுச்சொலையையும் மீண்டும் உள்ளிடவும்.';

  @override
  String get batchSignInFailedBody =>
      'உள்நுழைவு தோல்வியடைந்தது. உங்கள் பயனர்பெயர் மற்றும் கடவுச்சொல்லை சரிபார்க்கவும்.';

  @override
  String get batchSignInToKeepImportingBody =>
      'நோக்குநுட்பத்தைத் தொடர உள்நுழையவும்.';

  @override
  String get batchAccountNotConnectedBody => 'உங்கள் கணக்கு இணைக்கப்படவில்லை.';

  @override
  String get batchAccountConnectedTitle => 'கணக்கு இணைக்கப்பட்டது';

  @override
  String get batchNotConnectedTitle => 'இணைக்கப்படவில்லை';

  @override
  String get batchImportConnectionLostBody =>
      'இறக்குமதிக்கு இணைப்பு இழக்கப்பட்டது. சரிபார்க்க புதுப்பிக்கவும்.';

  @override
  String batchPickUpToBody(int max) {
    return '$max புகைப்படங்களைத் தேர்வுசெய்யவும். நாங்கள் உறுப்புகளைக் கண்டறிகிறோம்.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$total புகைப்படங்களில் $count';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '$count புகைப்படங்களில் $done தயார்செய்கிறது';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புகைப்படங்களில் உறுப்புகளைக் கண்டறியவும்',
      one: '1 புகைப்படத்தில் உறுப்புகளைக் கண்டறியவும்',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'உங்கள் $platform கணக்கு இரு-படி உள்நுழைவைப் பயன்படுத்துகிறது. உங்கள் ஆதரிப்பான் ஆப்பிலிருந்து 6-இலக்க நியமிப்பை உள்ளிடவும்.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'இந்த $platform சுயவிவரம் தனியார் அல்லது அதன் புகைப்படங்களைக் காட்ட உள்நுழைப்பு தேவை.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform இல் இணைக்கவும்';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புகைப்படங்கள் இதுவரை கண்டறியப்பட்டன',
      one: 'இதுவரை 1 புகைப்படம் கண்டறியப்பட்டது',
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
    return '$total இல் $processed செயலாக்கம் · $added சேர்த்தது · $waiting காத்திருக்கிறது · $skipped விடுபட்டது';
  }

  @override
  String batchScanningPhoto(int number) {
    return '$number புகைப்படம் ஸ்கேன் செய்கிறது';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '$number புகைப்படம் அடுத்தது';
  }

  @override
  String batchPhotoLabel(int number) {
    return '$number புகைப்படம்';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உறுப்புகள் கண்டறியப்பட்டன',
      one: '1 உறுப்பு கண்டறியப்பட்டது',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count புகைப்படங்கள் உங்கள் மூலகோஷத்திற்கு சேர்க்கப்பட்டன.',
      one: '1 புகைப்படம் உங்கள் மூலகோஷத்திற்கு சேர்க்கப்பட்டது.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count மேலும் ஸ்டுடியோ புகைப்படங்கள் வரும் வழியில் உள்ளன. தயாராக உள்ளதை சேமிக்கலாம், அல்லது வெளியேறலாம் — நாங்கள் உங்களுக்குத் தெரிவிப்போம்.',
      one:
          'மேலும் 1 ஸ்டுடியோ புகைப்படம் வரும் வழியில் உள்ளது. தயாராக உள்ளதை சேமிக்கலாம், அல்லது வெளியேறலாம் — நாங்கள் உங்களுக்குத் தெரிவிப்போம்.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'இன்னும் சேமிக்கப்படவில்லை: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos புகைப்படங்களில்',
      one: '1 புகைப்படத்தில்',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces உறுப்புகள்',
      one: '1 உறுப்பு',
    );
    return '$_temp0 இருந்து $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen தேர்வுசெய்யப்பட்டது. உறையை விடுபட கிளிக் செய்யவும்.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உறுப்புகளை சேமிக்கிறது',
      one: '1 உறையை சேமிக்கிறது',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உறுப்புகளை சேமி',
      one: '1 உறையை சேமி',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'உங்கள் உடல் சுயவிவரம் சேமிக்கப்பட்டது.';

  @override
  String get bodyProfileSavedTitle => 'சேமிக்கப்பட்டது';

  @override
  String get bodyProfileNotSavedTitle => 'சேமிக்கப்படவில்லை';

  @override
  String get bodyProfileSetDefaultBody =>
      'உங்கள் உசர்வைத்த சுயவிவரமாக அமைக்கவும்.';

  @override
  String get bodyProfileDeletedBody => 'உடல் சுயவிவரம் அழிக்கப்பட்டது.';

  @override
  String get bodyProfileDeletedTitle => 'அழிக்கப்பட்டது';

  @override
  String get bodyProfileNotDeletedTitle => 'அழிக்கப்படவில்லை';

  @override
  String get feedbackNotSentTitle => 'அனுப்பப்படவில்லை';

  @override
  String get feedbackSentBody =>
      'நன்றி. அனைத்து உரைகளையும் நாங்கள் படிக்கிறோம்; தேவைப்பட்டால் பதிலளிக்கிறோம்.';

  @override
  String get feedbackSentTitle => 'விவரக்குறிப்பு அனுப்பப்பட்டது';

  @override
  String get recommendUnnamedPiece => 'பெயரிடப்படாத உடை';

  @override
  String get recommendEnterCityBody =>
      'காலநிலையுக்கு ஏற்ப சக்தி மிக்க தேர்வுகளைப் பெற உங்கள் நகரத்தை உள்ளீடு செய்யவும்.';

  @override
  String get recommendWhichCityTitle => 'எந்த நகரம்?';

  @override
  String get aiConsentSheetTitle => 'AI சேவைக்குப் புகைப்படங்களைப் பகிர்தல்';

  @override
  String get aiConsentSheetBody =>
      'உங்கள் முயற்சி-இடுதல் மற்றும் புகைப்படக் காட்சி உருவப்படங்களை உருவாக்க, FitCheck AI உங்களுக்காக வழங்கும் புகைப்படங்களை (உங்கள் முகம் மற்றும் உடலின் உருவப்படங்களை உள்ளடக்கி) நம்பகமான மூன்றாம் பக்க AI வழங்குநருக்கு (OpenAI அல்லது Google Gemini போன்றவை) செயலாக்கத்திற்காக அனுப்புகிறது. அவர்கள் உங்கள் உருவப்படங்களை உருவாக்குகிறார்கள், மேலும் எங்கள் விதிமுறைகளுக்குப் பகிரங்கமாக அவற்றைத் தங்கள் மாதிரிகளைப் பயிற்சியுடன் பயன்படுத்துவதில்லை. புகைப்படங்கள் பாதுகாப்பாக கடத்தப்படுகின்றன, விளம்பரத்திற்காக எப்போதும் பகிரப்படாது.';

  @override
  String get aiConsentSheetPermission =>
      'தொடர்கிறது போதிலவு, உங்கள் புகைப்படங்களை இந்த AI வழங்குநர்களுடன் உருவப்பட உருவாக்கத்திற்காகப் பகிர உங்களுக்குத் தெளிவான அனுமதி வழங்கப்படுகிறது.';

  @override
  String get skeletonsLoadMoreFailed => 'மேலும் ஏற்ற முடியவில்லை.';

  @override
  String get jobsPiecesReadyTitle => 'உங்கள் உடைகள் தயாராக உள்ளன';

  @override
  String get jobsScanStoppedTitle => 'ஸ்கேன் நிறுத்தப்பட்டது';

  @override
  String get jobsNothingSavedBody =>
      'சுட்பு சேமிக்கப்படவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get jobsPhotoUploadFailedBody =>
      'புகைப்படம் பதிவேற்றம் தோல்வியடைந்தது.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google சேர்க்கை தொடங்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get referralAppliedTitle => 'குறிப்பு பயன்படுத்தப்பட்டது!';

  @override
  String get billingStoreUnavailableBody =>
      'இந்த உபகரணத்தில் ஸ்டோர் கொள்முதல்கள் இருப்பில்லை.';

  @override
  String get billingPurchaseProcessingBody =>
      'இந்த கொள்முதல் இன்னும் செயலாக்கப்படுகிறது. ஒரு நிமிடத்தில் App-ஐ மீண்டும் திறந்து உங்கள் திட்டத்தை காணலாம்.';

  @override
  String get profileAvatarUploadNoUrl =>
      'ஆவத்தார் பதிவேற்றம் ஒரு உருவப்பட URL-ஐத் திரும்பத் தரவில்லை.';

  @override
  String get rewardsDayStreakLabel => 'தினம் தொடர்ச்சி';

  @override
  String rewardsBestStreak(int days) {
    return 'சிறந்த $days நாட்கள்';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission அணுகல் தேவை';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission உடைய அணுகல் தற்போது நிராகரிக்கப்பட்டுள்ளது. அனுமதிக்க Settings-ஐ திறந்து, பின்னர் மீண்டும் வந்து முயற்சிக்கவும்.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'படி $step of 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'படி $step of $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'உருவப்படம் $index அகற்று';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'உருவப்படம் $index அகற்று';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points புள்ளிகள்';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'மின்னஞ்சல் $email. சந்தேகங்களை நாங்கள் 24 மணி நேரத்தில் கருணையுடன் பார்க்கிறோம்.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece அகற்று';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '\"$name\"-ஐ அழிக்கவா?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '\"$name\" -இல் சேர்';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" நீக்கப்பட்டது. அதன் பொருட்கள் உங்கள் சேமிப்பகத்தில் நீடிக்கின்றன.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'அனைத்தையும் காட்டு $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'இன்று $count மீதி';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'படம் $index தோல்வியடைந்தது';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected / $max படங்கள்';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape உடலமைப்பு · $tone நிறம்';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name-ஐ அழிக்கவா?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name -க்கான விருப்பங்கள்';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'அதிகபட்ச பயன்பாடு: $name, $count முறை';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: அமைக்கப்படவில்லை';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% பொருத்தம்';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked / $max தேர்வு';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item-ஐ நீக்கு';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency முன்னுரிமை';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'இந்த திட்டம் $store வழியாக கணக்கு காட்டப்படுகிறது. அம்மாற்றம் அல்லது ரத்து செய்ய $store கணக்கு அமைப்புகளில் மாற்றுங்கள்.';
  }

  @override
  String billingManageInStore(String store) {
    return '$store -இல் மேலாண்மை';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max-ல் $current பயன்படுத்தப்பட்டது';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'இன்னுமே சுமார் $seconds வினாடிகள்';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total -ல் $done சூடோ படங்கள் தயார்';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total -ல் $ready சூடோ படங்கள் தயார். ஒரு பொருட்கைத் தட்டினால் அது தவிர்க்கப்படும்.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height செ.மீ · $weight கி.கி';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'இல்லை';
}
