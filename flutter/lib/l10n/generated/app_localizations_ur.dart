// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'ہوم';

  @override
  String get tabPhotoshoot => 'فوٹو شوٹ';

  @override
  String get tabCloset => 'الماری';

  @override
  String get tabOutfits => 'آؤٹ فٹس';

  @override
  String get tabMore => 'مزید';

  @override
  String get actionAddItem => 'آئٹم شامل کریں';

  @override
  String get actionCreateOutfit => 'آؤٹ فٹ بنائیں';

  @override
  String get actionCancel => 'منسوخ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionSave => 'محفوظ';

  @override
  String get actionRetry => 'دوبارہ کوشش';

  @override
  String get actionDone => 'مکمل';

  @override
  String get actionNext => 'اگلا';

  @override
  String get actionBack => 'پیچھے';

  @override
  String get actionClose => 'بند کریں';

  @override
  String get actionSearch => 'تلاش';

  @override
  String get actionContinue => 'جاری رکھیں';

  @override
  String get stateLoading => 'لوڈ ہو رہا ہے';

  @override
  String get stateErrorTitle => 'کچھ غلط ہو گیا';

  @override
  String get stateErrorBody =>
      'دوبارہ کوشش کریں۔ اگر مسئلہ برقرار رہے تو سپورٹ سے رابطہ کریں۔';

  @override
  String get stateOfflineTitle => 'آپ آف لائن ہیں';

  @override
  String get stateOfflineBody =>
      'الماری کو سنک کرنے اور آؤٹ فٹس بنانے کے لیے دوبارہ کنیکٹ کریں۔';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get settingsAccountSection => 'اکاؤنٹ';

  @override
  String get settingsPreferencesSection => 'ترجیحات';

  @override
  String get settingsPlanBilling => 'پلان اور بلنگ';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsNotifications => 'اطلاعات';

  @override
  String get settingsUnits => 'پیمائش کی اکائیاں';

  @override
  String get settingsAppearance => 'ظاہری شکل';

  @override
  String get settingsPrivacySection => 'رازداری اور ڈیٹا';

  @override
  String get settingsAboutSection => 'ہمارے بارے میں';

  @override
  String get settingsSignOut => 'سائن آؤٹ';

  @override
  String get settingsDeleteAccount => 'اکاؤنٹ حذف کریں';

  @override
  String get settingsDeleteAccountTitle =>
      'کیا آپ اپنا اکاؤنٹ حذف کرنا چاہتے ہیں؟';

  @override
  String get settingsDeleteAccountBody =>
      'یہ آپ کی الماری، لباس، تصاویر اور پروفائل کو ہٹا دے گا۔ اسے واپس نہیں کیا جا سکتا۔';

  @override
  String get settingsUnitsImperial => 'امپیریل (انچ، پاؤنڈ)';

  @override
  String get settingsUnitsMetric => 'میٹرک (سینٹی میٹر، کلوگرام)';

  @override
  String get languageTitle => 'زبان';

  @override
  String get languageSystem => 'ڈیوائس کی زبان استعمال کریں';

  @override
  String get languageSystemBody =>
      'FitCheck AI آپ کے فون کی زبان کی پیروی کرتا ہے۔';

  @override
  String get languageSearchHint => 'زبانیں تلاش کریں';

  @override
  String get languageCurrent => 'موجودہ';

  @override
  String get languageReviewNote =>
      'یہ ترجمہ نیا ہے۔ اگر کچھ غلط لگے تو ہمیں بتائیں۔';

  @override
  String get languageChanged => 'زبان اپ ڈیٹ ہو گئی';

  @override
  String get paywallTitle => 'اپنا پلان منتخب کریں';

  @override
  String get paywallTrialBadge => '1 مہینہ مفت';

  @override
  String get paywallTrialTitle => 'آپ کا Pro کا پہلا مہینہ مفت ہے';

  @override
  String get paywallTrialBody =>
      'اپنی پوری الماری ایک ساتھ اپ لوڈ کریں۔ اس کے بعد جیسے جیسے ضرورت ہو چیزیں شامل کریں۔';

  @override
  String get paywallFreeForeverTitle => 'ہمیشہ مفت';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'کارڈ کی ضرورت نہیں۔ ہر مہینے آپ کو $uploads AI اپ لوڈز، $outfits آؤٹ فٹس اور $images فوٹوشوٹ تصاویر روزانہ ملتی ہیں۔';
  }

  @override
  String get paywallCtaTrial => 'میرا مفت مہینہ شروع کریں';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan میں اپ گریڈ کریں';
  }

  @override
  String get paywallRestore => 'خریداری بحال کریں';

  @override
  String get paywallManage => 'سبسکرپشن کا نظم کریں';

  @override
  String get paywallTerms => 'استعمال کی شرائط';

  @override
  String get paywallPrivacy => 'رازداری کی پالیسی';

  @override
  String get paywallPerMonth => 'فی مہینہ';

  @override
  String get paywallPerYear => 'فی سال';

  @override
  String get paywallBestValue => 'بہترین قیمت';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'مفت ٹرائل صرف نئے سبسکرائبرز کے لیے ہے۔ ٹرائل کے بعد، Pro $price پر تجدید ہوگا جب تک کہ ختم ہونے سے کم از کم 24 گھنٹے پہلے منسوخ نہ کیا جائے۔';
  }

  @override
  String get introTitle => 'آپ کی الماری، بالآخر منظم';

  @override
  String get introBody =>
      'اپنے کپڑوں کی ایک بار تصویر لیں۔ اپنے موجودہ کپڑوں سے آؤٹ فٹ آئیڈیاز، ٹرائی آن پریویوز اور اسٹوڈیو فوٹوز حاصل کریں۔';

  @override
  String get introStart => 'شروع کریں';

  @override
  String get introHaveAccount => 'میرا اکاؤنٹ پہلے سے موجود ہے';

  @override
  String get introSkip => 'چھوڑیں';

  @override
  String get authSignIn => 'سائن ان کریں';

  @override
  String get authSignUp => 'اکاؤنٹ بنائیں';

  @override
  String get authEmail => 'ای میل';

  @override
  String get authPassword => 'پاس ورڈ';

  @override
  String get authForgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get authContinueApple => 'Apple کے ساتھ جاری رکھیں';

  @override
  String get authContinueGoogle => 'Google کے ساتھ جاری رکھیں';

  @override
  String get authOrDivider => 'یا';

  @override
  String get wardrobeTitle => 'الماری';

  @override
  String get wardrobeEmptyTitle => 'آپ کی الماری خالی ہے';

  @override
  String get wardrobeEmptyBody =>
      'اپنی پہلی چیز شامل کریں، یا پوری الماری کی ایک ساتھ تصویر اپ لوڈ کریں۔';

  @override
  String get wardrobeAddFirst => 'پہلی آئٹم شامل کریں';

  @override
  String get wardrobeSearchHint => 'اپنی الماری میں تلاش کریں';

  @override
  String get categoryTops => 'اوپری لباس';

  @override
  String get categoryBottoms => 'نچلے لباس';

  @override
  String get categoryShoes => 'جوتے';

  @override
  String get categoryAccessories => 'لوازمات';

  @override
  String get categoryOuterwear => 'بیرونی لباس';

  @override
  String get categorySwimwear => 'تیراکی کے لباس';

  @override
  String get categoryActivewear => 'ورزشی لباس';

  @override
  String get categoryOther => 'دیگر';

  @override
  String get conditionClean => 'صاف';

  @override
  String get conditionDirty => 'گندے';

  @override
  String get conditionLaundry => 'دھلائی میں';

  @override
  String get conditionRepair => 'مرمت درکار';

  @override
  String get conditionDonate => 'عطیہ کے لیے';

  @override
  String get seasonSpring => 'بہار';

  @override
  String get seasonSummer => 'گرما';

  @override
  String get seasonFall => 'خزاں';

  @override
  String get seasonWinter => 'سرما';

  @override
  String get seasonAll => 'ہر موسم';

  @override
  String get styleCasual => 'آرام دہ';

  @override
  String get styleFormal => 'باضابطہ';

  @override
  String get styleBusiness => 'کاروباری';

  @override
  String get styleSporty => 'کھیلوں کا';

  @override
  String get styleBohemian => 'بوہیمین';

  @override
  String get styleStreetwear => 'اسٹریٹ ویئر';

  @override
  String get styleVintage => 'ونٹیج';

  @override
  String get styleMinimalist => 'سادہ';

  @override
  String get styleRomantic => 'رومانوی';

  @override
  String get styleEdgy => 'جدید';

  @override
  String get stylePreppy => 'پریپی';

  @override
  String get styleArtsy => 'فنکارانہ';

  @override
  String get styleClassic => 'کلاسک';

  @override
  String get styleElegant => 'نفیس';

  @override
  String get styleOther => 'دیگر';

  @override
  String get occasionWork => 'کام';

  @override
  String get occasionDateNight => 'ڈیٹ نائٹ';

  @override
  String get occasionTravel => 'سفر';

  @override
  String get occasionWedding => 'شادی';

  @override
  String get occasionGym => 'جم';

  @override
  String get occasionWeekend => 'ویک اینڈ';

  @override
  String get occasionParty => 'پارٹی';

  @override
  String get occasionInterview => 'انٹرویو';

  @override
  String get colorBlack => 'سیاہ';

  @override
  String get colorWhite => 'سفید';

  @override
  String get colorGrey => 'گرے';

  @override
  String get colorNavy => 'نیوی';

  @override
  String get colorBrown => 'بھورا';

  @override
  String get colorRed => 'سرخ';

  @override
  String get colorBlue => 'نیلا';

  @override
  String get colorGreen => 'سبز';

  @override
  String get colorPink => 'گلابی';

  @override
  String get colorPurple => 'جامنی';

  @override
  String get colorYellow => 'پیلا';

  @override
  String get colorOrange => 'نارنجی';

  @override
  String get colorBeige => 'بیج';

  @override
  String get dateToday => 'آج';

  @override
  String get dateYesterday => 'کل';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دن پہلے',
      one: '1 دن پہلے',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ہفتے پہلے',
      one: '1 ہفتہ پہلے',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ماہ پہلے',
      one: '1 ماہ پہلے',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سال پہلے',
      one: '1 سال پہلے',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI پسند آیا؟';

  @override
  String get ratingPromptBody =>
      'ایک چھوٹی سی ریٹنگ دوسروں کو اپنا اسٹائل تلاش کرنے میں مدد کرتی ہے۔';

  @override
  String get ratingPromptYes => 'ایپ ریٹ کریں';

  @override
  String get ratingPromptNo => 'ابھی نہیں';

  @override
  String get closetNoMatchesTitle => 'کوئی چیز نہیں ملی';

  @override
  String get closetNoMatchesBody => 'فلٹرز کم کریں یا کوئی اور تلاش کریں۔';

  @override
  String get closetClearFilters => 'فلٹرز ہٹائیں';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پیس',
      one: '1 پیس',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'آپ کے پیس لوڈ ہو رہے ہیں';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتخب',
      one: '1 منتخب',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'منتخب کردہ حذف کریں';

  @override
  String get closetCancelSelection => 'انتخاب منسوخ کریں';

  @override
  String get closetCloseSearch => 'تلاش بند کریں';

  @override
  String get closetShowGrid => 'گرڈ دکھائیں';

  @override
  String get closetShowList => 'فہرست دکھائیں';

  @override
  String get closetShowRows => 'قطاریں دکھائیں';

  @override
  String get closetStatsTitle => 'الماری کے اعدادوشمار';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آئٹمز حذف کریں؟',
      one: '1 آئٹم حذف کریں؟',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'جن آؤٹ فٹس میں یہ استعمال ہوئے ہیں وہ انہیں کھو دیں گے۔';

  @override
  String get closetSortBy => 'ترتیب دیں';

  @override
  String get closetFavourites => 'پسندیدہ';

  @override
  String get closetFavourite => 'پسندیدہ بنائیں';

  @override
  String get closetUnfavourite => 'پسندیدہ سے ہٹائیں';

  @override
  String get closetWoreToday => 'آج پہنا';

  @override
  String closetWornTimes(int count) {
    return '$count× پہنا گیا';
  }

  @override
  String get closetCategoryLabel => 'زمرہ';

  @override
  String get closetUseCaseLabel => 'استعمال';

  @override
  String get closetAnyUseCase => 'کوئی بھی';

  @override
  String get closetOtherUseCase => 'دیگر استعمال';

  @override
  String get closetOtherUseCaseHint => 'مثال کے طور پر، برنچ';

  @override
  String get closetUseUseCase => 'یہ استعمال کریں';

  @override
  String get closetClearAll => 'سب صاف کریں';

  @override
  String get sortNewest => 'نئے پہلے';

  @override
  String get sortOldest => 'پرانے پہلے';

  @override
  String get sortName => 'نام (A–Z)';

  @override
  String get sortMostWorn => 'سب سے زیادہ پہنا گیا';

  @override
  String get useCaseInformal => 'غیر رسمی';

  @override
  String get useCaseDate => 'ڈیٹ';

  @override
  String get useCaseDinner => 'رات کا کھانا';

  @override
  String get useCaseLunch => 'دوپہر کا کھانا';

  @override
  String get actionSelect => 'منتخب کریں';

  @override
  String get actionEdit => 'ترمیم';

  @override
  String get actionFilter => 'فلٹر';

  @override
  String get actionSort => 'ترتیب';

  @override
  String get actionAll => 'سب';

  @override
  String get dashboardStartClosetTitle => 'اپنی الماری شروع کریں';

  @override
  String get dashboardStartClosetBody =>
      'چند کپڑوں کی تصویر لیں۔ ہم انہیں آپ کے لیے ٹیگ کریں گے۔';

  @override
  String get dashboardPieces => 'کپڑے';

  @override
  String get dashboardOutfits => 'آؤٹ فٹس';

  @override
  String get dashboardDayStreak => 'دن کا تسلسل';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'اس ماہ +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'بہترین $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پسندیدہ',
      one: '1 پسندیدہ',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محفوظ آؤٹ فٹس',
      one: '1 محفوظ آؤٹ فٹ',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'سب سے زیادہ پہنا گیا: $name، $count بار';
  }

  @override
  String get setupSkip => 'سیٹ اپ چھوڑیں';

  @override
  String get setupWhoTitle => 'ہم کس کی اسٹائلنگ کر رہے ہیں؟';

  @override
  String get setupWhoBody =>
      'ٹرائی آن اور فوٹو شوٹ کے لیے ماڈل سیٹ کریں۔ آپ اسے اپنی پروفائل میں تبدیل کر سکتے ہیں۔';

  @override
  String get setupStyleTitle => 'آپ سب سے زیادہ کیا پہنتے ہیں؟';

  @override
  String get setupStyleBody =>
      'کوئی بھی منتخب کریں۔ آؤٹ فٹ آئیڈیاز یہیں سے شروع ہوتے ہیں۔';

  @override
  String get setupClosetTitle => 'اپنے پہلے کپڑے شامل کریں۔';

  @override
  String get setupClosetBody =>
      'چند کپڑوں یا ان کے ڈھیر کی تصویر لیں۔ ہر ٹکڑا کٹ کر آپ کے لیے فائل کر دیا جائے گا۔';

  @override
  String get setupAddClothes => 'کپڑے شامل کریں';

  @override
  String get setupStylesLabel => 'اسٹائلز';

  @override
  String get setupOccasionsLabel => 'مواقع';

  @override
  String get setupSkipStep => 'چھوڑیں';

  @override
  String get setupLater => 'بعد میں';

  @override
  String get setupSaveError => 'محفوظ نہیں ہو سکا';

  @override
  String get genderWomen => 'خواتین';

  @override
  String get genderMen => 'مرد';

  @override
  String get genderNonBinary => 'نان بائنری';

  @override
  String get genderPreferNotToSay => 'بتانا پسند نہیں';

  @override
  String get outfitEmptyTitle => 'ابھی کوئی لباس نہیں';

  @override
  String get outfitEmptyBody => 'اپنی الماری سے کپڑے جوڑیں اور لُک محفوظ کریں۔';

  @override
  String get outfitNoMatchesTitle => 'کوئی لباس نہیں ملا';

  @override
  String get outfitSearchHint => 'اپنے لباس تلاش کریں';

  @override
  String get outfitLoading => 'لباس لوڈ ہو رہے ہیں';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لباس',
      one: '1 لباس',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'اسٹائل اور موسم';

  @override
  String get outfitCollections => 'کلیکشنز';

  @override
  String get outfitDuplicate => 'ڈپلیکیٹ';

  @override
  String get outfitDeleteTitle => 'یہ لباس حذف کریں؟';

  @override
  String get outfitDeleteBody => 'اس کے کپڑے آپ کی الماری میں رہیں گے۔';

  @override
  String get outfitDrafts => 'ڈرافٹس';

  @override
  String get outfitDraft => 'ڈرافٹ';

  @override
  String get filterStyle => 'اسٹائل';

  @override
  String get filterSeason => 'موسم';

  @override
  String get itemDetailDeleteTitle => 'یہ آئٹم حذف کریں؟';

  @override
  String get itemDetailDeleteBody =>
      'اسے استعمال کرنے والے لباس سے یہ آئٹم ہٹ جائے گا۔';

  @override
  String get itemAddFavourite => 'پسندیدہ میں شامل کریں';

  @override
  String itemSize(String size) {
    return 'سائز $size';
  }

  @override
  String get itemColours => 'رنگ';

  @override
  String get itemMaterial => 'مٹیریل';

  @override
  String get itemPattern => 'پیٹرن';

  @override
  String get itemUseCases => 'استعمال';

  @override
  String get itemKeptIn => 'موجود ہے';

  @override
  String get itemPrice => 'قیمت';

  @override
  String get itemBought => 'خریدا گیا';

  @override
  String get itemTags => 'ٹیگز';

  @override
  String get itemAdded => 'شامل کیا گیا';

  @override
  String get itemTimesWornLabel => 'کتنی بار پہنا';

  @override
  String get itemLastWornLabel => 'آخری بار پہنا';

  @override
  String get itemNeverWorn => 'کبھی نہیں';

  @override
  String get authEntryBody =>
      'آپ کے ہر لباس کو AI اسٹائل کرے۔ آؤٹ فٹ پلان کریں، پہن کر دیکھیں اور تصویر بنائیں۔';

  @override
  String get authCreateCloset => 'اپنی الماری بنائیں';

  @override
  String get authWelcomeBack => 'خوش آمدید';

  @override
  String get authSignInBody => 'اپنی الماری کھولنے کے لیے سائن ان کریں۔';

  @override
  String get authCreateAccount => 'اکاؤنٹ بنائیں';

  @override
  String get authCreateClosetBody =>
      'صرف ایک منٹ لگے گا۔ پہلے چند آئٹمز مفت ہیں۔';

  @override
  String get authName => 'نام';

  @override
  String get authConfirmPassword => 'پاس ورڈ کی تصدیق کریں';

  @override
  String get authReferralCode => 'ریفرل کوڈ (اختیاری)';

  @override
  String get authResetTitle => 'پاس ورڈ ری سیٹ کریں';

  @override
  String get authResetBody =>
      'ہم آپ کو نیا پاس ورڈ منتخب کرنے کے لیے ای میل بھیجیں گے۔';

  @override
  String get authSendResetLink => 'لنک بھیجیں';

  @override
  String get authBackToSignIn => 'سائن ان پر واپس جائیں';

  @override
  String get authEnterEmail => 'ای میل درج کریں';

  @override
  String get authEnterValidEmail => 'درست ای میل درج کریں';

  @override
  String get authEnterPassword => 'پاس ورڈ درج کریں';

  @override
  String get authPasswordTooShort => 'کم از کم 6 حروف';

  @override
  String get authShowPassword => 'پاس ورڈ دکھائیں';

  @override
  String get authHidePassword => 'پاس ورڈ چھپائیں';

  @override
  String get authNewHere => 'یہاں نئے ہیں؟';

  @override
  String authConfirmEmail(String email) {
    return 'سائن ان کرنے سے پہلے $email کی تصدیق کریں۔ اپنا ان باکس چیک کریں۔';
  }

  @override
  String get authResendEmail => 'دوبارہ بھیجیں';

  @override
  String get authResendingEmail => 'بھیجا جا رہا ہے...';

  @override
  String get authPasswordsDoNotMatch => 'پاس ورڈز مماثل نہیں ہیں';

  @override
  String get authEnterName => 'اپنا نام درج کریں';

  @override
  String get authChoosePassword => 'پاس ورڈ منتخب کریں';

  @override
  String get authHaveAccount => 'اکاؤنٹ موجود ہے؟';

  @override
  String get authCodeAccepted => 'کوڈ قبول کر لیا گیا';

  @override
  String get authCodeNotFound => 'کوڈ نہیں ملا';

  @override
  String authReferralFrom(String name) {
    return '$name کی طرف سے۔ آپ دونوں کو ایک ماہ مفت ملے گا۔';
  }

  @override
  String get authReferralInvalid => 'ہمیں یہ کوڈ نہیں ملا۔';

  @override
  String authResetSent(String email) {
    return '$email پر بھیج دیا گیا۔ اس فون پر لنک کھولیں۔';
  }

  @override
  String get introSlide1Title => 'اپنی الماری کی تصویر لیں۔';

  @override
  String get introSlide1Body =>
      'کپڑوں کے ڈھیر کی تصویر لیں۔ ہر ٹکڑا خود بخود الگ اور محفوظ ہو جائے گا۔';

  @override
  String get introSlide2Title => 'جلدی تیار ہوں۔';

  @override
  String get introSlide2Body =>
      'آپ کے اپنے کپڑوں سے ملبوسات، جو آپ کے منصوبوں اور موسم کے مطابق ہوں۔';

  @override
  String get introSlide3Title => 'پہننے سے پہلے دیکھیں۔';

  @override
  String get introSlide3Body =>
      'اپنی تصویر پر لُکس آزمائیں، یا انہیں کسی مہم کی طرح شوٹ کریں۔';

  @override
  String get settingsTheme => 'تھیم';

  @override
  String get settingsThemeSystem => 'سسٹم';

  @override
  String get settingsThemeLight => 'لائٹ';

  @override
  String get settingsThemeDark => 'ڈارک';

  @override
  String get settingsTemperature => 'درجہ حرارت';

  @override
  String get settingsEmailUpdates => 'ای میل اپ ڈیٹس';

  @override
  String get settingsEmailUpdatesBody => 'ای میل کے ذریعے خبریں اور ٹپس';

  @override
  String get settingsOutfitReminders => 'آؤٹ فٹ ریمائنڈرز';

  @override
  String get settingsOutfitRemindersBody =>
      'آپ نے کیا پہنا، اسے لاگ کرنے کے لیے یاد دہانی';

  @override
  String get settingsWeeklySummary => 'ہفتہ وار خلاصہ';

  @override
  String get settingsWeeklySummaryBody => 'آپ کے ہفتے کے ملبوسات';

  @override
  String get settingsStyleSection => 'اسٹائل';

  @override
  String get settingsPreferredStyles => 'پسندیدہ اسٹائلز';

  @override
  String get settingsPreferredColours => 'پسندیدہ رنگ';

  @override
  String get settingsNoneChosen => 'کچھ منتخب نہیں کیا';

  @override
  String get settingsPlanAiSection => 'پلان اور AI';

  @override
  String get settingsPlanBillingBody => 'پلان، استعمال اور اپ گریڈز';

  @override
  String get settingsPlanUsageBody => 'پلان اور استعمال';

  @override
  String get settingsInviteFriends => 'دوستوں کو مدعو کریں';

  @override
  String get settingsInviteFriendsBody =>
      'ہر شامل ہونے والے دوست کے لیے ایک ماہ مفت';

  @override
  String get settingsAiProvider => 'AI فراہم کنندہ';

  @override
  String get settingsAiProviderBody =>
      'ٹیگنگ اور تصاویر کے لیے اپنا ماڈل استعمال کریں';

  @override
  String get settingsAppVersion => 'ایپ ورژن';

  @override
  String get settingsPrivacyTerms => 'پرائیویسی اور شرائط';

  @override
  String get settingsReportProblem => 'مسئلہ رپورٹ کریں';

  @override
  String get settingsChangePassword => 'پاس ورڈ تبدیل کریں';

  @override
  String get settingsExportData => 'اپنا ڈیٹا ایکسپورٹ کریں';

  @override
  String get settingsExportBody =>
      'ہم آپ کے محفوظ کردہ تمام ڈیٹا کی فائل تیار کریں گے اور ڈاؤن لوڈ کھولیں گے۔';

  @override
  String get settingsExportAction => 'ایکسپورٹ';

  @override
  String get settingsCurrentPassword => 'موجودہ پاس ورڈ';

  @override
  String get settingsNewPassword => 'نیا پاس ورڈ';

  @override
  String get settingsConfirmNewPassword => 'نیا پاس ورڈ کنفرم کریں';

  @override
  String get settingsEnterCurrentPassword => 'اپنا موجودہ پاس ورڈ درج کریں';

  @override
  String get settingsEnterNewPassword => 'نیا پاس ورڈ درج کریں';

  @override
  String get settingsPasswordMin8 => 'کم از کم 8 حروف استعمال کریں';

  @override
  String get settingsPasswordNeedsUpper => 'ایک بڑا حرف شامل کریں';

  @override
  String get settingsPasswordNeedsLower => 'ایک چھوٹا حرف شامل کریں';

  @override
  String get settingsPasswordNeedsDigit => 'ایک عدد شامل کریں';

  @override
  String get settingsPasswordsNoMatch => 'پاس ورڈز آپس میں نہیں ملتے';

  @override
  String get settingsChangeAction => 'تبدیل کریں';

  @override
  String get itemAddSnapTitle => 'تصویر لیں';

  @override
  String get itemAddSnapBody =>
      'ہم تصویر میں موجود ہر چیز کو تلاش کر کے اسے صاف ستھرا بنائیں گے۔';

  @override
  String get itemAddCamera => 'تصویر لیں';

  @override
  String get itemAddGallery => 'گیلری سے منتخب کریں';

  @override
  String get itemAddOtherWays => 'شامل کرنے کے دیگر طریقے';

  @override
  String get itemAddSeveral => 'کئی تصاویر شامل کریں';

  @override
  String get itemAddSeveralBody => 'ایک ساتھ 50 تک';

  @override
  String get itemAddImportProfile => 'پروفائل سے امپورٹ کریں';

  @override
  String get itemAddImportProfileBody => 'انسٹاگرام یا فیس بک';

  @override
  String get itemAddEnterDetails => 'تفصیلات خود درج کریں';

  @override
  String get itemAddEnterDetailsBody => 'تصویر کی ضرورت نہیں';

  @override
  String get itemManualIntro =>
      'صرف نام درکار ہے۔ باقی تفصیلات ابھی یا بعد میں شامل کریں۔';

  @override
  String get itemManualNameHint => 'مثال کے طور پر، نیلی کاٹن ٹی شرٹ';

  @override
  String get itemManualEnterName => 'نام درج کریں';

  @override
  String get itemManualNotes => 'نوٹس';

  @override
  String get itemManualBrand => 'برانڈ';

  @override
  String get itemManualSize => 'سائز';

  @override
  String get itemManualEnterNumber => 'نمبر درج کریں';

  @override
  String get itemManualSavePiece => 'محفوظ کریں';

  @override
  String get itemManualSaving => 'محفوظ ہو رہا ہے';

  @override
  String get itemManualSavedTitle => 'محفوظ ہو گیا';

  @override
  String itemManualSavedBody(String name) {
    return '$name آپ کی الماری میں شامل ہو گیا ہے۔';
  }

  @override
  String get itemManualNotSaved => 'محفوظ نہیں ہوا';

  @override
  String get itemManualAddUseCase => 'استعمال کا مقصد شامل کریں';

  @override
  String get itemManualAddUseCaseAction => 'مقصد شامل کریں';

  @override
  String get itemPhotos => 'تصاویر';

  @override
  String get itemAddPhotos => 'تصاویر شامل کریں';

  @override
  String get itemNoPhotoYet =>
      'ابھی کوئی تصویر نہیں۔ آپ بغیر تصویر کے بھی محفوظ کر سکتے ہیں۔';

  @override
  String get itemRemovePhoto => 'تصویر ہٹائیں';

  @override
  String get itemRemovePiece => 'آئٹم ہٹائیں';

  @override
  String get filterConditionLabel => 'حالت';

  @override
  String get photoshootStepPhotos => 'تصاویر';

  @override
  String get photoshootStepSetup => 'سیٹ اپ';

  @override
  String get photoshootStepCreating => 'تخلیق';

  @override
  String get photoshootStepResults => 'نتائج';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'مرحلہ $current از $total، $name';
  }

  @override
  String get photoshootOneFailed =>
      'ایک تصویر ناکام ہو گئی۔ نیچے دوبارہ کوشش کریں۔';

  @override
  String photoshootManyFailed(int count) {
    return '$count تصاویر ناکام ہو گئیں۔ نیچے ہر ایک کے لیے دوبارہ کوشش کریں۔';
  }

  @override
  String get photoshootFormat => 'فارمیٹ';

  @override
  String get photoshootHowMany => 'کتنی';

  @override
  String get photoshootYourPrompt => 'آپ کا پرامپٹ';

  @override
  String get photoshootPromptHint => 'چھت پر سنہری گھنٹہ، لینن کی قمیض';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصاویر بنائیں',
      one: '1 تصویر بنائیں',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تصاویر',
      one: 'تصویر',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'ہم آج کی حد چیک نہیں کر سکے۔';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan پلان: آج $remaining میں سے $limit باقی';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'مفت';

  @override
  String get photoshootGallery => 'گیلری';

  @override
  String get photoshootUseCamera => 'کیمرہ استعمال کریں';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'تصویر $number ہٹائیں';
  }

  @override
  String get photoshootNoPhotosTitle => 'کوئی تصویر نہیں ملی';

  @override
  String get photoshootNoPhotosBody =>
      'شوٹ بغیر تصاویر کے ختم ہوا۔ دوبارہ کوشش کریں۔';

  @override
  String get photoshootNewStyle => 'نیا انداز';

  @override
  String get photoshootNewPhotos => 'نئی تصاویر';

  @override
  String photoshootOpenPhoto(int number) {
    return 'تصویر $number کھولیں';
  }

  @override
  String get photoshootReportPhoto => 'تصویر رپورٹ کریں';

  @override
  String get photoshootSaveToGallery => 'گیلری میں محفوظ کریں';

  @override
  String get actionUpgrade => 'اپ گریڈ';

  @override
  String get referralLimitTitle => 'آپ نے آج کی تصاویر استعمال کر لی ہیں';

  @override
  String get referralLimitBody =>
      'آپ کی مفت تصاویر کل واپس آئیں گی۔ ایک دوست کو ریفر کریں اور آپ دونوں کو ایک ماہ کا Pro مفت ملے۔';

  @override
  String get referralLimitRefer => 'دوست کو ریفر کریں';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'ڈیٹنگ ایپ';

  @override
  String get photoshootUsePortfolio => 'پورٹ فولیو';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'جمالیاتی';

  @override
  String get photoshootUseCustom => 'آپ کا اپنا پرامپٹ';

  @override
  String get photoshootDescLinkedin => 'کام کے لیے پروفیشنل ہیڈ شاٹس';

  @override
  String get photoshootDescDating => 'پرسکون، گرم اور قدرتی';

  @override
  String get photoshootDescPortfolio => 'ایڈیٹوریل، ہائی فیشن لُکس';

  @override
  String get photoshootDescInstagram => 'آپ کی فیڈ کے لیے لائف اسٹائل شاٹس';

  @override
  String get photoshootDescAesthetic => 'موڈی، فنکارانہ فریمز';

  @override
  String get photoshootDescCustom => 'اپنی پسند کا لُک بیان کریں';

  @override
  String get aspectSquare => 'مربع';

  @override
  String get aspectPortrait => 'پورٹریٹ';

  @override
  String get aspectLandscape => 'لینڈ اسکیپ';

  @override
  String get aspectTall => 'لمبا';

  @override
  String get aspectWide => 'چوڑا';

  @override
  String get tryOnAppBar => 'ورچوئل ٹرائی آن';

  @override
  String get tryOnYourPhoto => 'آپ کی تصویر';

  @override
  String get tryOnGarment => 'لباس';

  @override
  String get tryOnUploadingPhoto => 'آپ کی تصویر اپ لوڈ ہو رہی ہے';

  @override
  String get tryOnAddPhotoPrompt => 'اپنی مکمل جسم کی تصویر شامل کریں';

  @override
  String get tryOnBodyPhotoHint => 'مکمل جسم کی تصویر بہترین رہتی ہے';

  @override
  String get tryOnAddPhoto => 'تصویر شامل کریں';

  @override
  String get tryOnChangePhoto => 'تصویر تبدیل کریں';

  @override
  String get tryOnPhotoLoadFailed => 'ہم آپ کی تصویر لوڈ نہیں کر سکے۔';

  @override
  String get tryOnChooseGarment => 'لباس کی تصویر منتخب کریں';

  @override
  String get tryOnChooseOneGarment => 'لباس کی ایک تصویر منتخب کریں';

  @override
  String get tryOnGarmentHint => 'فلیٹ لے یا ہینگر شاٹ بہترین رہتا ہے';

  @override
  String get tryOnChange => 'تبدیل کریں';

  @override
  String get tryOnCamera => 'کیمرہ';

  @override
  String get tryOnRemove => 'ہٹائیں';

  @override
  String get tryOnLookTitle => 'لُک';

  @override
  String get tryOnStyle => 'اسٹائل';

  @override
  String get tryOnBackground => 'پس منظر';

  @override
  String get tryOnPose => 'پوز';

  @override
  String get tryOnDressingUp =>
      'آپ کو تیار کر رہے ہیں۔ اس میں تقریباً آدھا منٹ لگے گا۔';

  @override
  String get tryOnEmptyResult => 'آپ کی ٹرائی آن یہاں نظر آئے گی';

  @override
  String get tryOnReportImage => 'تصویر رپورٹ کریں';

  @override
  String get tryOnCreating => 'تخلیق ہو رہی ہے';

  @override
  String get tryOnTryAgain => 'دوبارہ کوشش کریں';

  @override
  String get tryOnCreate => 'ٹرائی آن بنائیں';

  @override
  String get tryOnBackgroundStudioWhite => 'اسٹوڈیو وائٹ';

  @override
  String get tryOnBackgroundStudioGrey => 'اسٹوڈیو گرے';

  @override
  String get tryOnBackgroundUrban => 'اربن اسٹریٹ';

  @override
  String get tryOnBackgroundNature => 'نیچر';

  @override
  String get tryOnBackgroundMinimal => 'منیملسٹ';

  @override
  String get tryOnPoseFront => 'سامنے کھڑے ہونا';

  @override
  String get tryOnPoseSide => 'سائیڈ پر کھڑے ہونا';

  @override
  String get tryOnPoseWalking => 'چلنا';

  @override
  String get dashboardGreetingMorning => 'صبح بخیر';

  @override
  String get dashboardGreetingAfternoon => 'سہ پہر بخیر';

  @override
  String get dashboardGreetingEvening => 'شام بخیر';

  @override
  String get dashboardWelcome => 'خوش آمدید';

  @override
  String get dashboardOpenProfile => 'پروفائل کھولیں';

  @override
  String get dashboardRailToday => 'آج';

  @override
  String get dashboardRailRecently => 'حال ہی میں';

  @override
  String get dashboardActivityEmpty => 'نئے کپڑے اور آؤٹ فٹس یہاں نظر آئیں گے۔';

  @override
  String get quickAddPiece => 'کپڑا شامل کریں';

  @override
  String get quickAddPieceBody => 'تصویر لیں اور ٹیگ کریں';

  @override
  String get quickBuildOutfit => 'آؤٹ فٹ بنائیں';

  @override
  String get quickBuildOutfitBody => 'اپنے کپڑے مکس کریں';

  @override
  String get quickForYou => 'آپ کے لیے';

  @override
  String get quickForYouBody => 'آج کے لیے انتخاب';

  @override
  String get quickPlanWeek => 'ہفتے کا پلان';

  @override
  String get quickPlanWeekBody => 'تاریخ کے مطابق آؤٹ فٹس';

  @override
  String get referralBannerUrgent => 'کمی ہے؟ کسی دوست کو مدعو کریں۔';

  @override
  String get referralBannerTitle => 'ایک ماہ دیں، ایک ماہ پائیں۔';

  @override
  String get referralBannerBody =>
      'آپ اور آپ کے دوست دونوں کو ایک ماہ کا Pro ملتا ہے۔';

  @override
  String get referralBannerDismiss => 'ایک ہفتے کے لیے ہٹائیں';

  @override
  String get referralBannerShare => 'دعوت نامہ شیئر کریں';

  @override
  String get referralBannerCopy => 'لنک کاپی کریں';

  @override
  String get itemEditPieceTitle => 'پیس میں ترمیم کریں';

  @override
  String get itemEditDescriptionLabel => 'تفصیل';

  @override
  String get itemEditNotSaved => 'محفوظ نہیں ہوا';

  @override
  String get itemEditSavedTitle => 'محفوظ ہو گیا';

  @override
  String get itemEditSavedBody => 'آپ کی تبدیلیاں محفوظ کر لی گئی ہیں۔';

  @override
  String get itemEditSavedStalePhotos =>
      'محفوظ ہو گیا — تصاویر پرانی ہو سکتی ہیں';

  @override
  String get itemEditRemovePieceHint => 'اس پیس کو آئٹم کے صفحے سے حذف کریں۔';

  @override
  String get itemEditNoPhotos =>
      'ابھی کوئی تصویر نہیں۔ گیلری یا کیمرے سے شامل کریں۔';

  @override
  String get itemEditKeepPhoto => 'تصویر رکھیں';

  @override
  String get itemEditRemoved => 'حذف کر دیا گیا';

  @override
  String get itemEditAddUseCaseAction => 'شامل کریں';

  @override
  String get statsNoStatsTitle => 'ابھی کوئی اعداد و شمار نہیں';

  @override
  String get statsNoStatsBody =>
      'کچھ پیس شامل کریں اور آپ کی الماری کا مکس یہاں نظر آئے گا۔';

  @override
  String get statsByCategory => 'زمرہ کے لحاظ سے';

  @override
  String get statsTotalValue => 'کل مالیت';

  @override
  String get statsMostWorn => 'سب سے زیادہ پہنا گیا';

  @override
  String get statsLeastWorn => 'باری کا انتظار';

  @override
  String get statsUnnamedPiece => 'بغیر نام کا پیس';

  @override
  String get jobsTitle => 'اسکینز';

  @override
  String get jobsEmptyTitle => 'ابھی کوئی اسکین نہیں';

  @override
  String get jobsEmptyBody =>
      'ایک پیس کی تصویر لیں اور اسے بیک گراؤنڈ میں بھیج دیں — یہ یہاں کام کرتا رہے گا۔';

  @override
  String get jobsNotCancelled => 'منسوخ نہیں ہوا';

  @override
  String get jobsResume => 'دوبارہ شروع کریں';

  @override
  String get jobsReview => 'جائزہ لیں';

  @override
  String get jobsStop => 'روکیں';

  @override
  String get jobsDismiss => 'خارج کریں';

  @override
  String get reportTitle => 'مواد کی رپورٹ کریں';

  @override
  String reportIntro(String contentType) {
    return 'ہمیں بتائیں کہ اس $contentType میں کیا غلط ہے۔ ہماری ٹیم ہر رپورٹ کا جائزہ لیتی ہے۔';
  }

  @override
  String get reportReasonInappropriate => 'نامناسب یا توہین آمیز';

  @override
  String get reportReasonNudity => 'عریانی یا جنسی مواد';

  @override
  String get reportReasonHarassment => 'ہراساں کرنا یا بدسلوکی';

  @override
  String get reportReasonImpersonation => 'جعلی شناخت';

  @override
  String get reportReasonOther => 'دیگر';

  @override
  String get reportDetailsLabel => 'اضافی تفصیلات (اختیاری)';

  @override
  String get reportSubmit => 'رپورٹ جمع کریں';

  @override
  String get reportSubmittedTitle => 'رپورٹ موصول ہوئی';

  @override
  String get reportSubmittedBody => 'شکریہ۔ ہماری ٹیم اس مواد کا جائزہ لے گی۔';

  @override
  String get reportFailedTitle => 'رپورٹ نہیں بھیجی جا سکی';

  @override
  String get reportFailedBody => 'براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get reportContentTryOnImage => 'AI ٹرائی آن تصویر';

  @override
  String get reportContentSharedOutfit => 'شیئر کردہ لباس';

  @override
  String get reportContentPhotoshootImage => 'AI فوٹو شوٹ تصویر';

  @override
  String get sharedOutfitTitle => 'شیئر کردہ لباس';

  @override
  String get sharedOutfitHideTooltip => 'یہ لباس چھپائیں';

  @override
  String get sharedOutfitReportTooltip => 'اس لباس کی رپورٹ کریں';

  @override
  String get sharedOutfitHideTitle => 'یہ لباس چھپائیں؟';

  @override
  String get sharedOutfitHideBody =>
      'یہ اس ڈیوائس پر چھپا رہے گا۔ آپ اس کی رپورٹ بھی کر سکتے ہیں تاکہ ہماری ٹیم اسے دیکھ کر ہٹا سکے۔';

  @override
  String get sharedOutfitHideAction => 'چھپائیں';

  @override
  String get sharedOutfitHiddenInfo =>
      'یہ لباس اب اس ڈیوائس پر دوبارہ نظر نہیں آئے گا۔';

  @override
  String get sharedOutfitHiddenToast => 'لباس چھپا دیا گیا';

  @override
  String get sharedOutfitMissingTitle => 'یہ لباس اب یہاں موجود نہیں ہے';

  @override
  String get sharedOutfitMissingBody =>
      'ہو سکتا ہے اسے ہٹا دیا گیا ہو، یا لنک غلط ہو۔';

  @override
  String get sharedOutfitHiddenStateTitle => 'آپ نے یہ لباس چھپا دیا ہے';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'اگر یہ نامناسب تھا، تو پرائیویسی اور شرائط سے رپورٹ کریں یا $email پر ای میل کریں۔';
  }

  @override
  String get sharedOutfitCtaTitle => 'یہ لک پسند آئی؟';

  @override
  String get sharedOutfitCtaBody => 'اپنی الماری سے ایسے ہی لباس بنائیں۔';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI حاصل کریں';

  @override
  String get errorTitle => 'خرابی';

  @override
  String get errorUnknown => 'ایک غیر متوقع خرابی پیش آگئی';

  @override
  String get errorNoConnection =>
      'انٹرنیٹ کنکشن موجود نہیں۔ براہ کرم اپنا نیٹ ورک چیک کریں۔';

  @override
  String get errorTimeout =>
      'درخواست کا وقت ختم ہوگیا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get errorServerError =>
      'ہمارے سرور میں کچھ گڑبڑ ہے۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get errorBadGateway =>
      'ہمارا سرور وقتی طور پر دستیاب نہیں۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get errorServiceUnavailable =>
      'سروس وقتی طور پر دستیاب نہیں۔ براہ کرم کچھ دیر میں کوشش کریں۔';

  @override
  String get errorInternalError => 'کچھ غلط ہوگیا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get errorUnauthorized => 'جاری رکھنے کے لیے براہ کرم سائن ان کریں۔';

  @override
  String get errorForbidden => 'آپ کو اس تک رسائی حاصل نہیں۔';

  @override
  String get errorSessionExpired =>
      'آپ کا سیشن ختم ہوگیا۔ براہ کرم دوبارہ سائن ان کریں۔';

  @override
  String get errorInvalidCredentials => 'وہ ای میل یا پاس ورڈ درست نہیں۔';

  @override
  String get errorTokenRefreshFailed =>
      'آپ کا سیشن تازہ نہیں کیا جاسکا۔ براہ کرم دوبارہ سائن ان کریں۔';

  @override
  String get errorRequestCancelled => 'درخواست منسوخ کردی گئی۔';

  @override
  String get errorInvalidFormat => 'فائل کا یہ فارمیٹ تعاون یافتہ نہیں۔';

  @override
  String get errorFileTooLarge => 'یہ فائل بہت بڑی ہے۔';

  @override
  String get errorUploadFailed =>
      'اپ لوڈ ناکام ہوگئی۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get errorCacheCorrupted =>
      'محفوظ شدہ ڈیٹا خراب ہوگیا تھا اور اسے ری سیٹ کردیا گیا ہے۔';

  @override
  String get errorCacheNotFound => 'ابھی تک کچھ محفوظ نہیں کیا گیا۔';

  @override
  String get errorUserNotFound => 'وہ اکاؤنٹ نہیں مل سکا۔';

  @override
  String get errorItemNotFound => 'یہ آئٹم اب موجود نہیں۔';

  @override
  String get errorOutfitNotFound => 'یہ لباس اب موجود نہیں۔';

  @override
  String get rewardsTitle => 'انعامات';

  @override
  String get rewardsNoAchievementsTitle => 'ابھی تک کوئی کارنامہ نہیں';

  @override
  String get rewardsNoAchievementsBody =>
      'اپنا پہلا انعام حاصل کرنے کے لیے کپڑے شامل کریں اور لباس کی منصوبہ بندی کریں۔';

  @override
  String get rewardsEmptyLeaderboardTitle => 'لیڈر بورڈ پر کوئی موجود نہیں';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'پوائنٹس حاصل کرنے اور یہاں ظاہر ہونے کے لیے لباس کی منصوبہ بندی کریں۔';

  @override
  String get legalViewPrivacyPolicy => 'رازداری کی پالیسی دیکھیں';

  @override
  String get aiConsentAgree => 'میں اتفاق کرتا ہوں اور جاری رکھیں';

  @override
  String get aiConsentNotNow => 'ابھی نہیں';

  @override
  String get imageViewerCloseTooltip => 'تصویر بند کریں';

  @override
  String get updateReadyTitle => 'اپ ڈیٹ تیار ہے';

  @override
  String get updateReadyBody =>
      'نئی بہتریوں کے لیے FitCheck AI دوبارہ شروع کریں۔';

  @override
  String get permissionCameraUsage =>
      'اپنے لباس اور وارڈروب کی تصاویر لینے کے لیے FitCheck AI کو کیمرے تک رسائی کی ضرورت ہے۔';

  @override
  String get permissionPhotoLibraryUsage =>
      'اپنے لباس اور وارڈروب کی تصاویر منتخب کرنے کے لیے FitCheck AI کو فوٹو لائبریری تک رسائی کی ضرورت ہے۔';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI کو آپ کی تیار کردہ لباس کی تصاویر آپ کی فوٹو لائبریری میں محفوظ کرنے کی ضرورت ہے۔';

  @override
  String get wardrobeSomePhotosSkipped => 'کچھ تصاویر چھوڑ دی گئیں';

  @override
  String get wardrobePhotosNotAdded => 'تصاویر شامل نہیں کی گئیں';

  @override
  String get wardrobePhotoNotAdded => 'تصویر شامل نہیں کی گئی';

  @override
  String get wardrobeNotStartedTitle => 'شروع نہیں ہوا';

  @override
  String get wardrobeNoRoomTitle => 'جگہ نہیں ہے';

  @override
  String get wardrobeAddPhotosSemantic => 'تصاویر شامل کریں';

  @override
  String get batchAddTileLabel => 'شامل کریں';

  @override
  String get batchProfileLinkLabel => 'پروفائل لنک';

  @override
  String get wardrobeImportFromProfileTitle => 'پروفائل سے درآمد کریں';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'چند تصاویر شامل کریں';

  @override
  String get wardrobeClearAction => 'صاف کریں';

  @override
  String get wardrobeRefreshTooltip => 'ریش فریش کریں';

  @override
  String get batchNoPhotosYetTitle => 'ابھی تک کوئی تصویر نہیں';

  @override
  String get batchChoosePhotosAction => 'تصاویر منتخب کریں';

  @override
  String get batchWeFindEachPieceBody =>
      'ہم ہر ایک چیز تلاش کرتے ہیں اور اس کی اسٹوڈیو تصویر بناتے ہیں۔';

  @override
  String get batchPreparingPhotosSemantic => 'تصاویر تیار کی جا رہی ہیں';

  @override
  String get batchPhotosProcessedSemantic => 'تصاویر پروسیس ہو گئیں';

  @override
  String get batchPasteProfileLinkTitle => 'پروفائل لنک پیسٹ کریں';

  @override
  String get batchPasteProfileLinkBody =>
      'کوئی عوامی انسٹاگرام یا فیس بک پروفائل۔ ہم اس کی تصاویر اسکین کرتے ہیں، اور آپ منتخب کرتے ہیں کہ آپ کی الماری میں کیا جائے گا۔';

  @override
  String get batchClearLinkTooltip => 'لنک صاف کریں';

  @override
  String get batchStartingButton => 'شروع ہو رہا ہے';

  @override
  String get batchStartImportAction => 'درآمد شروع کریں';

  @override
  String get batchReviewEveryPhotoTitle => 'آپ ہر تصویر کا جائزہ لیتے ہیں';

  @override
  String get batchReviewEveryPhotoBody =>
      'جب تک آپ منظوری نہیں دیتے کچھ شامل نہیں ہوتا۔';

  @override
  String get batchPrivateProfilesTitle => 'نجی پروفائلز';

  @override
  String get batchPrivateProfilesBody =>
      'اپنا اکاؤنٹ منسلک کریں۔ انسٹاگرام کے لیے یوزر نیم اور پاس ورڈ بھی درکار ہوتا ہے۔';

  @override
  String get batchUseAnotherLinkAction => 'دوسرا لنک استعمال کریں';

  @override
  String get batchSignInNeededTitle => 'سائن ان درکار ہے';

  @override
  String get batchEnterYourCodeTitle => 'اپنا کوڈ درج کریں';

  @override
  String get batchUseUsernamePasswordAction =>
      'یوزر نیم اور پاس ورڈ استعمال کریں';

  @override
  String get batchAlreadyConnectedAction =>
      'میں نے براؤزر میں پہلے ہی کنیکٹ کر لیا ہے';

  @override
  String get batchEnterCodeAction => 'کوڈ درج کریں';

  @override
  String get batchTryAnotherWayAction => 'دوسرا طریقہ آزمائیں';

  @override
  String get batchLiveStatus => 'لائیو';

  @override
  String get batchReconnectingStatus => 'دوبارہ جڑ رہا ہے';

  @override
  String get batchSignInToInstagramTitle => 'انسٹاگرام میں سائن ان کریں';

  @override
  String get batchUsernameLabel => 'یوزر نیم';

  @override
  String get batchCodeIfTwoStepLabel =>
      'کوڈ، اگر آپ ٹو سٹیپ سائن ان استعمال کرتے ہیں';

  @override
  String get batchAuthenticatorCodeBody =>
      'اپنی تصدیقی ایپ کا 6 ہندسوں کا کوڈ استعمال کریں۔ کوڈ تیزی سے بدلتے ہیں۔';

  @override
  String get batchVerifyAction => 'تصدیق کریں';

  @override
  String get batchFindingPhotosTitle => 'تصاویر تلاش کی جا رہی ہیں';

  @override
  String get batchImportPausedTitle => 'امپورٹ روک دی گئی';

  @override
  String get batchProcessingPhotosTitle => 'تصاویر پر کام جاری ہے';

  @override
  String get batchWaitingNextPhoto => 'اگلی تصویر کا انتظار ہے';

  @override
  String get batchCancelImportAction => 'امپورٹ منسوخ کریں';

  @override
  String get batchNoPiecesInPhotoBody => 'اس تصویر میں کوئی لباس نہیں ملا۔';

  @override
  String get batchEditPieceColoursLabel => 'رنگ، کوما سے الگ کیے گئے';

  @override
  String get batchAddToClosetAction => 'الماری میں شامل کریں';

  @override
  String get batchSkipPhotoAction => 'یہ تصویر چھوڑ دیں';

  @override
  String get batchImportCompleteTitle => 'امپورٹ مکمل ہو گئی';

  @override
  String get batchImportFailedTitle => 'امپورٹ ناکام ہو گئی';

  @override
  String get batchImportCancelledTitle => 'امپورٹ منسوخ کر دی گئی';

  @override
  String get batchImportErrorBody => 'امپورٹ کرتے وقت کچھ خرابی پیش آ گئی۔';

  @override
  String get batchNothingMoreImportedBody =>
      'اس پروفائل سے مزید کچھ امپورٹ نہیں کیا گیا۔';

  @override
  String get batchViewClosetAction => 'وارڈروب دیکھیں';

  @override
  String get batchStartOverAction => 'دوبارہ شروع کریں';

  @override
  String get wardrobeAddPieceTitle => 'آئٹم شامل کریں';

  @override
  String get wardrobeAddDetailsTitle => 'تفصیلات شامل کریں';

  @override
  String get wardrobeScanningTitle => 'اسکیننگ جاری ہے';

  @override
  String get batchReviewPiecesTitle => 'آئٹمز کا جائزہ لیں';

  @override
  String get wardrobeGalleryAction => 'گیلری';

  @override
  String get wardrobeCameraAction => 'کیمرہ';

  @override
  String get wardrobeNewBadge => 'نیا';

  @override
  String get wardrobeRemovePhotoTooltip => 'تصویر ہٹائیں';

  @override
  String get batchRunInBackgroundTooltip => 'پس منظر میں چلائیں';

  @override
  String get batchStepOneOfTwo => 'مرحلہ 1 از 2';

  @override
  String get batchStepTwoOfTwo => 'مرحلہ 2 از 2';

  @override
  String get batchUploadingPhotosTitle => 'تصاویر اپ لوڈ ہو رہی ہیں';

  @override
  String get batchFindingPiecesTitle => 'آئٹمز تلاش کیے جا رہے ہیں';

  @override
  String get batchMakingStudioPhotosTitle => 'اسٹوڈیو فوٹوز بنائی جا رہی ہیں';

  @override
  String get batchStoppedLabel => 'روک دیا گیا';

  @override
  String get batchFindingPiecesStoppedTitle => 'آئٹمز کی تلاش روک دی گئی';

  @override
  String get batchCancelledLabel => 'منسوخ';

  @override
  String get batchAllDoneTitle => 'سب ہو گیا';

  @override
  String get batchOpeningPiecesBody => 'آپ کے آئٹمز کھولے جا رہے ہیں';

  @override
  String get batchNothingSavedBody => 'کچھ بھی محفوظ نہیں ہوا۔';

  @override
  String get batchFindingPiecesFailedBody => 'آئٹمز کی تلاش ناکام ہو گئی۔';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'آئٹمز کی تلاش جلدی روک دی گئی۔';

  @override
  String get batchStopFindingPiecesTitle => 'آئٹمز تلاش کرنا بند کریں؟';

  @override
  String get batchStopFindingPiecesBody =>
      'اسکین رک جائے گا اور کچھ بھی محفوظ نہیں ہوگا۔ جو آئٹمز پہلے مل چکے ہیں وہ آپ کی سرگرمی میں رہیں گے جب تک آپ انہیں ہٹانہ دیں۔';

  @override
  String get batchKeepGoingAction => 'جاری رکھیں';

  @override
  String get batchTryAgainAction => 'دوبارہ کوشش کریں';

  @override
  String get batchBackToPhotosAction => 'تصاویر پر واپس جائیں';

  @override
  String get batchSkipAllAction => 'سب چھوڑیں';

  @override
  String get batchIncludeAllAction => 'سب شامل کریں';

  @override
  String get batchNoPiecesFoundTitle => 'کوئی لباس نہیں ملا';

  @override
  String get batchNoPiecesFoundBody => 'ہمیں ان تصاویر میں کوئی لباس نہیں ملا۔';

  @override
  String get batchChooseOtherPhotosAction => 'دوسری تصاویر منتخب کریں';

  @override
  String get batchUseCaseHelper => 'آپ کے محفوظ کردہ ہر لباس میں شامل۔';

  @override
  String get batchDiscardPiecesTitle => 'یہ لباس ہٹائیں؟';

  @override
  String get batchDiscardPiecesBody => 'اس بیچ سے کچھ بھی محفوظ نہیں کیا گیا۔';

  @override
  String get batchKeepAction => 'رکھیں';

  @override
  String get batchDiscardAction => 'ہٹائیں';

  @override
  String get batchRemovePieceTitle => 'یہ لباس ہٹائیں؟';

  @override
  String get batchRemovePieceBody => 'یہ آپ کی الماری میں محفوظ نہیں ہے۔';

  @override
  String get batchRemoveAction => 'ہٹائیں';

  @override
  String get batchChoosePiecesToSave => 'محفوظ کرنے کے لیے لباس منتخب کریں';

  @override
  String get batchDiscardAllAction => 'سب ہٹائیں';

  @override
  String get batchNothingSavedRetryBody =>
      'کچھ محفوظ نہیں ہوا۔ دوبارہ کوشش کریں۔';

  @override
  String get batchNotSavedTitle => 'محفوظ نہیں ہوا';

  @override
  String get batchSavingLabel => 'محفوظ ہو رہا ہے';

  @override
  String get batchSendToBackgroundAction => 'پس منظر میں بھیجیں';

  @override
  String get batchStillWorkingMessage =>
      'کام جاری ہے۔ لباس تیار ہونے پر ہم آپ کو مطلع کریں گے۔';

  @override
  String get batchRunningInBackgroundTitle => 'پس منظر میں کام جاری ہے';

  @override
  String get batchStudioPhotosStoppedBody =>
      'اسٹوڈیو تصاویر کا عمل جلد رک گیا۔ آپ اب بھی یہ لباس محفوظ کر سکتے ہیں۔';

  @override
  String get batchTapPieceToSkip => 'چھوڑنے کے لیے کسی لباس پر ٹیپ کریں۔';

  @override
  String get batchStudioPhotosOnWayBody =>
      'اسٹوڈیو تصاویر تیار ہو رہی ہیں۔ آپ جا سکتے ہیں، ہم آپ کو مطلع کر دیں گے۔';

  @override
  String get batchLeaveAction => 'چھوڑیں';

  @override
  String get batchPeopleInPhotosTitle => 'تصاویر میں افراد';

  @override
  String get batchIncludeAction => 'شامل کریں';

  @override
  String get batchSkipAction => 'چھوڑیں';

  @override
  String get batchYourPhotoIsUsedLabel => 'آپ کی تصویر استعمال کی گئی ہے';

  @override
  String get batchMakingStudioPhotoLabel => 'اسٹوڈیو تصویر بنائی جا رہی ہے';

  @override
  String get batchNoStudioPhotoBody =>
      'اسٹوڈیو تصویر نہیں۔ آپ کی تصویر استعمال کی گئی ہے۔';

  @override
  String get batchEnterDetailsYourselfAction => 'تفصیلات خود درج کریں';

  @override
  String get batchChooseAnotherPhotoAction => 'دوسری تصویر منتخب کریں';

  @override
  String get batchConnectionLostTitle => 'کنکشن منقطع ہوگیا';

  @override
  String get batchConnectionLostBody =>
      'اپنا کنکشن چیک کریں اور دوبارہ کوشش کریں۔';

  @override
  String get batchDailyLimitTitle => 'روزانہ کی حد پوری ہو گئی';

  @override
  String get batchDailyLimitBodyPaywall =>
      'مزید اسکینز کے لیے Pro پر اپ گریڈ کریں یا تفصیلات خود درج کریں۔';

  @override
  String get batchDailyLimitBodyFree =>
      'آپ کے اسکینز کل ری سیٹ ہو جائیں گے۔ آپ اب تفصیلات خود درج کر سکتے ہیں۔';

  @override
  String get batchSeePlansAction => 'پلانز دیکھیں';

  @override
  String get batchAiBusyTitle => 'ہمارا AI مصروف ہے';

  @override
  String get batchAiBusyBody =>
      'یہ ہماری طرف سے مسئلہ ہے۔ چند منٹ بعد دوبارہ کوشش کریں۔';

  @override
  String get batchNoPiecesBody => 'صاف تصویر آزمائیں یا تفصیلات خود درج کریں۔';

  @override
  String get batchScanningUnavailableTitle => 'اسکیننگ دستیاب نہیں ہے';

  @override
  String get batchScanningUnavailableBody => 'فی الحال تفصیلات خود درج کریں۔';

  @override
  String get batchScanDidNotFinishTitle => 'اسکین مکمل نہیں ہوا';

  @override
  String get batchTryAgainBody => 'دوبارہ کوشش کریں۔';

  @override
  String get billingTitle => 'سبسکرپشن';

  @override
  String get billingUpgradeHeading => 'اپنا پلان اپ گریڈ کریں';

  @override
  String get billingUpgradeOnPlusBody => 'وہی فیچرز، زیادہ حدیں۔';

  @override
  String get billingUpgradeBody =>
      'Plus اور Pro میں ایک جیسے فیچرز ہیں۔ اپنی ضرورت کے مطابق حد منتخب کریں۔';

  @override
  String get billingWebUnavailableBody =>
      'آن لائن اپ گریڈز فی الحال دستیاب نہیں۔ پرومو یا ریفرل کوڈ سے Plus یا Pro انلاک ہو جاتا ہے۔ مفت ماہ حاصل کرنے کے لیے دوستوں کو مدعو کریں۔';

  @override
  String get billingPlansStale =>
      'تازہ ترین پلان لوڈ نہیں ہو سکے۔ قیمتیں پرانی ہو سکتی ہیں۔';

  @override
  String get billingMonthly => 'ماہانہ';

  @override
  String get billingYearly => 'سالانہ';

  @override
  String get billingCurrentPlan => 'موجودہ پلان';

  @override
  String get billingActive => 'فعال';

  @override
  String get billingThisMonth => 'اس ماہ';

  @override
  String get billingItemExtractions => 'آئٹم نکالنا';

  @override
  String get billingOutfitVisualizations => 'آؤٹ فٹ ویژولائزیشن';

  @override
  String get billingNearLimitUpgrade =>
      'آپ اس ماہ کی حد کے قریب ہیں۔ مزید کے لیے اپ گریڈ کریں۔';

  @override
  String get billingNearLimitResets =>
      'آپ اس ماہ کی حد کے قریب ہیں۔ یہ اگلے ماہ کے شروع میں ری سیٹ ہو جائے گی۔';

  @override
  String get billingStoreUnavailable =>
      'اسٹور پر اپ گریڈز فی الحال دستیاب نہیں۔ جلد دوبارہ کوشش کریں۔';

  @override
  String get billingManageHeading => 'اپنا پلان منظم کریں';

  @override
  String get billingCancelPlan => 'سبسکرپشن منسوخ کریں';

  @override
  String get billingCancelKeepsAccess =>
      'اس بلنگ پیریڈ کے اختتام تک آپ کی رسائی برقرار رہے گی۔';

  @override
  String get billingCancelConfirmTitle => 'سبسکرپشن منسوخ کریں؟';

  @override
  String get billingKeepPlan => 'پلان برقرار رکھیں';

  @override
  String get billingCancelPlanAction => 'پلان منسوخ کریں';

  @override
  String get billingBilledMonthly => 'ماہانہ بلنگ';

  @override
  String get billingBilledYearly => 'سالانہ بلنگ';

  @override
  String get billingVirtualTryOn => 'ورچوئل ٹرائی آن';

  @override
  String get billingPrioritySupport => 'ترجیحی سپورٹ';

  @override
  String get billingDisclosureProRenewing =>
      'Pro ایک خودکار تجدید ہونے والی سبسکرپشن ہے';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus اور Pro خودکار تجدید ہونے والی سبسکرپشنز ہیں';

  @override
  String get billingDisclosureAppleBilling =>
      'خریداری کی تصدیق پر ادائیگی آپ کے Apple ID سے کی جائے گی۔';

  @override
  String get billingDisclosureGoogleBilling =>
      'خریداری کی تصدیق پر ادائیگی آپ کے Google Play اکاؤنٹ سے کی جائے گی۔';

  @override
  String get billingDisclosureRenewalTerms =>
      'آپ کی سبسکرپشن خود بخود اسی قیمت پر اسی مدت کے لیے تجدید ہو جاتی ہے جب تک کہ آپ موجودہ مدت ختم ہونے سے کم از کم 24 گھنٹے پہلے آٹو رینیو بند نہ کر دیں۔';

  @override
  String get billingDisclosureAppleManage =>
      'ترتیبات › اپنی Apple ID › سبسکرپشنز میں جا کر کسی بھی وقت منظم یا منسوخ کریں۔';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play › ادائگی اور سبسکرپشنز میں جا کر کسی بھی وقت منظم یا منسوخ کریں۔';

  @override
  String get billingReferFriend => 'کسی دوست کو ریفر کریں';

  @override
  String get billingHowItWorks => 'یہ کیسے کام کرتا ہے';

  @override
  String get billingHowShareTitle => 'اپنا لنک شیئر کریں';

  @override
  String get billingHowShareBody => 'اسے کسی دوست کو بھیجیں۔';

  @override
  String get billingHowSignUpTitle => 'وہ سائن اپ کرتے ہیں';

  @override
  String get billingHowSignUpBody => 'آپ کا دوست لنک سے جوائن کرتا ہے۔';

  @override
  String get billingHowBothTitle => 'آپ دونوں کو Pro ملتا ہے';

  @override
  String get billingHowBothBody => 'آپ دونوں کو ایک ماہ کا Pro مفت ملتا ہے۔';

  @override
  String get billingYourReferrals => 'آپ کے ریفرلز';

  @override
  String get billingInvited => 'مدعو کیا گیا';

  @override
  String get billingJoined => 'جوائن کیا';

  @override
  String get billingMonthsEarned => 'حاصل کردہ ماہ';

  @override
  String get billingInviteFriend => 'دوست کو مدعو کریں';

  @override
  String get billingInviteBody =>
      'آپ اور آپ کے دوست کو Pro کا ایک مہینہ ملتا ہے۔';

  @override
  String get billingYourCode => 'آپ کا کوڈ';

  @override
  String get billingCopyLink => 'لنک کاپی کریں';

  @override
  String get billingShareInvite => 'دعوت شیئر کریں';

  @override
  String get giftUnavailable => 'اس بلڈ میں گفٹ دعوتیں دستیاب نہیں۔';

  @override
  String get giftPageTitle => 'FitCheck Pro تحفہ دیں';

  @override
  String get giftNoAllowances => 'اس وقت کوئی مفت گفٹ دعوت دستیاب نہیں۔';

  @override
  String get giftFormTitle => 'مفت دعوت بھیجیں';

  @override
  String get giftFormBody =>
      'آپ کا وصول کنندہ اس تصدیق شدہ ای میل سے تحفہ حاصل کرتا ہے۔ ہم آپ کی طرف سے ای میل نہیں بھیجتے۔';

  @override
  String get giftFieldFrom => 'جانب سے';

  @override
  String get giftFieldRecipientName => 'وصول کنندہ کا نام';

  @override
  String get giftFieldRecipientEmail => 'وصول کنندہ کا ای میل';

  @override
  String get giftFieldOccasion => 'موقع (اختیاری)';

  @override
  String get giftNoOccasion => 'کوئی موقع نہیں';

  @override
  String get giftOccasionBirthday => 'سالگرہ';

  @override
  String get giftOccasionAnniversary => 'سالگرہ (شادی)';

  @override
  String get giftOccasionOther => 'دیگر';

  @override
  String get giftFieldCardGreeting => 'کارڈ کا پیغام';

  @override
  String get giftFieldCardGreetingHelper =>
      'یہ کارڈ پر بالکل ویسا ہی ظاہر ہوتا ہے جیسا لکھا گیا ہے۔';

  @override
  String get giftFieldPrivateNote => 'نجی نوٹ (اختیاری)';

  @override
  String get giftCreateAction => 'مفت تحفہ بنائیں';

  @override
  String get giftClaimedTitle => 'تحفہ حاصل کر لیا گیا';

  @override
  String get giftClaimedActive => 'آپ کا FitCheck Pro تحفہ فعال ہے۔';

  @override
  String get giftClaimedQueued =>
      'آپ کا FitCheck Pro تحفہ آپ کی موجودہ رسائی کے بعد شروع ہوتا ہے۔';

  @override
  String get giftLinkCopied => 'تحفہ کا لنک کلپ بورڈ پر کاپی ہو گیا۔';

  @override
  String get giftErrorName => 'نام درج کریں۔';

  @override
  String get giftErrorEmail => 'ایک درست ای میل پتہ درج کریں۔';

  @override
  String get giftErrorGreeting => 'کارڈ کا پیغام درج کریں۔';

  @override
  String get giftErrorGreetingLength => '80 سے زیادہ حروف استعمال نہ کریں۔';

  @override
  String get giftClaimAction => 'تحفہ حاصل کریں';

  @override
  String get giftCardPreview => 'کارڈ کا پیش منظر';

  @override
  String get giftGiftForYou => 'آپ کے لیے ایک تحفہ';

  @override
  String get giftGiftWaiting => 'ایک تحفہ آپ کا منتظر ہے';

  @override
  String get giftOpenBody =>
      'اپنے تصدیق شدہ ای میل کے ساتھ تحفے حاصل کرنے کے لیے انہیں کھولیں۔';

  @override
  String get giftOpenGifts => 'تحفے کھولیں';

  @override
  String get giftSendInvitation => 'دعوت نامہ بھیجیں';

  @override
  String get settingsAiProviderSection => 'فراہم کنندہ';

  @override
  String get settingsAiCustom => 'اپنی مرضی کا';

  @override
  String get settingsAiUrlHelper =>
      'کوئی عوامی یو آر ایل استعمال کریں جو سرور تک پہنچ سکے۔ مقامی ہوسٹ ہمارے سرورز سے کام نہیں کرتا۔';

  @override
  String get settingsAiConnectionSection => 'رابطہ';

  @override
  String get settingsAiApiUrl => 'اے پی آئی یو آر ایل';

  @override
  String get settingsAiApiKey => 'اے پی آئی کی';

  @override
  String get settingsAiApiKeySaved =>
      'محفوظ ہو گیا۔ اسے برقرار رکھنے کے لیے خالی چھوڑ دیں۔';

  @override
  String get settingsAiChatModel => 'چیٹ ماڈل';

  @override
  String get settingsAiVisionModel => 'ویژن ماڈل (اختیاری)';

  @override
  String get settingsAiImageModel => 'تصویر کا ماڈل (اختیاری)';

  @override
  String get settingsAiImageModelNote =>
      'تصویر بنانے کے لیے response_modalities کے ساتھ OpenAI سے مطابقت رکھنے والی چیٹ کی تکمیل درکار ہے۔';

  @override
  String get settingsAiTestConnection => 'کنکشن ٹیسٹ کریں';

  @override
  String get calendarTitle => 'کیلنڈر';

  @override
  String get calendarGoToToday => 'آج پر جائیں';

  @override
  String get calendarConnectTooltip => 'کیلنڈر جوڑیں';

  @override
  String get calendarAddEvent => 'ایونٹ شامل کریں';

  @override
  String get calendarEmptyTitle => 'کچھ طے شدہ نہیں';

  @override
  String get calendarEmptyBody =>
      'کوئی ایونٹ شامل کریں اور لباس کی منصوبہ بندی کریں۔';

  @override
  String get calendarPreviousMonth => 'پچھلا مہینہ';

  @override
  String get calendarNextMonth => 'اگلا مہینہ';

  @override
  String get calendarAllDay => 'سارا دن';

  @override
  String get calendarOutfitLinked => 'لباس منسلک ہے';

  @override
  String get calendarEventOptions => 'ایونٹ کے اختیارات';

  @override
  String get calendarDeleteTitle => 'کیا آپ اس ایونٹ کو حذف کرنا چاہتے ہیں؟';

  @override
  String get calendarChangeOutfit => 'لباس تبدیل کریں';

  @override
  String get calendarLinkOutfit => 'لباس منسلک کریں';

  @override
  String get calendarRemoveOutfit => 'لباس ہٹائیں';

  @override
  String get calendarNewEvent => 'نیا ایونٹ';

  @override
  String get calendarEditEvent => 'ایونٹ میں ترمیم کریں';

  @override
  String get calendarTitleLabel => 'عنوان';

  @override
  String get calendarTitleRequired => 'عنوان شامل کریں';

  @override
  String get calendarEndBeforeStart => 'اختتامی وقت آغاز کے بعد ہونا چاہیے';

  @override
  String get calendarStarts => 'شروع';

  @override
  String get calendarEnds => 'ختم';

  @override
  String get calendarPlaceOptional => 'مقام (اختیاری)';

  @override
  String get calendarNotesOptional => 'نوٹس (اختیاری)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'ایک لباس تیار کریں اور پھر اسے اس ایونٹ سے جوڑیں۔';

  @override
  String get calendarBuildOutfit => 'لباس تیار کریں';

  @override
  String get calendarConnectionsTitle => 'کیلنڈرز';

  @override
  String get calendarConnectionsBody =>
      'یہاں شامل کردہ ایونٹس FitCheck میں محفوظ رہتے ہیں۔';

  @override
  String get calendarDisconnect => 'منقطع کریں';

  @override
  String get calendarNotAvailable => 'ابھی دستیاب نہیں';

  @override
  String get profileSectionExplore => 'دریافت کریں';

  @override
  String get profileNavTryOn => 'ٹرائی آن';

  @override
  String get profileNavRewards => 'انعامات';

  @override
  String get profileSupport => 'سپورٹ';

  @override
  String get profileHelp => 'مدد';

  @override
  String get profileAbout => 'تعارف';

  @override
  String get profileAboutBody => 'آپ کی الماری، ملبوسات اور منصوبے ایک جگہ۔';

  @override
  String get profileSignOutTitle => 'سائن آؤٹ کریں؟';

  @override
  String get profileSignOutBody => 'آپ جب چاہیں دوبارہ سائن ان کر سکتے ہیں۔';

  @override
  String get profileEditTitle => 'پروفائل میں ترمیم کریں';

  @override
  String get profileYourProfile => 'آپ کا پروفائل';

  @override
  String get profileBodyProfiles => 'جسمانی پروفائلز';

  @override
  String get profileBodyEmptyTitle => 'ابھی تک کوئی باڈی پروفائل نہیں ہے';

  @override
  String get profileBodyEmptyBody =>
      'بہترین فٹ کے لیے اپنی لمبائی اور ساخت شامل کریں۔';

  @override
  String get profileBodyAdd => 'پروفائل شامل کریں';

  @override
  String get profileBodyDefaultNote =>
      'آپ کی ڈیفالٹ پروفائل فٹ اور ٹرائے آن کے لیے استعمال ہوتی ہے۔';

  @override
  String get profileBodyDefaultBadge => 'ڈیفالٹ';

  @override
  String get profileBodyMakeDefault => 'ڈیفالٹ بنائیں';

  @override
  String get profileBodyDeleteBody => 'آپ اسے واپس نہیں کر سکتے۔';

  @override
  String get profileBodyRequired => 'لازمی';

  @override
  String get profileBodyCheckNumber => 'اس نمبر کو چیک کریں';

  @override
  String get profileBodyNew => 'نئی باڈی پروفائل';

  @override
  String get profileBodyNameHint => 'مثال کے طور پر، میں';

  @override
  String get profileBodyHeight => 'اونچائی';

  @override
  String get profileBodyWeight => 'وزن';

  @override
  String get profileBodyBuild => 'ساخت';

  @override
  String get profileBodySkinTone => 'رنگت';

  @override
  String get profileBirthDateNeededBody =>
      'پیدائش کے وقت کے ساتھ تاریخ پیدائش بھی شامل کریں۔';

  @override
  String get profileBirthDateNeededTitle => 'تاریخ پیدائش درکار ہے';

  @override
  String get profilePartlySavedBody =>
      'نام اور تصویر محفوظ ہو گئے۔ پیدائش کی تفصیلات محفوظ نہیں ہوئیں، بعد میں کوشش کریں۔';

  @override
  String get profilePartlySavedTitle => 'جزوی طور پر محفوظ';

  @override
  String get profileSavedBody => 'آپ کی پروفائل محفوظ ہو گئی ہے۔';

  @override
  String get profileChangePhoto => 'پروفائل تصویر تبدیل کریں';

  @override
  String get profilePhotoLabel => 'پروفائل تصویر';

  @override
  String get profilePhotoHint => 'نئی تصویر کے لیے ٹیپ کریں';

  @override
  String get profileBirthDateLabel => 'تاریخ پیدائش (اختیاری)';

  @override
  String get profileBirthTimeLabel => 'پیدائش کا وقت (اختیاری)';

  @override
  String get profileBirthTimeHelper => 'ویدک مشوروں کو زیادہ درست بناتا ہے';

  @override
  String get profileBirthPlaceLabel => 'جائے پیدائش (اختیاری)';

  @override
  String get profileBirthPlaceHint => 'مثال کے طور پر، نئی دہلی، بھارت';

  @override
  String get profileHelpContactTitle => 'ہم سے کچھ بھی پوچھیں';

  @override
  String get profileHelpContactBody =>
      'پیغام بھیجیں اور ہم عام طور پر ایک دن میں ای میل کے ذریعے جواب دیتے ہیں۔';

  @override
  String get profileHelpContactAction => 'سپورٹ سے رابطہ کریں';

  @override
  String get profileHelpFaqTitle => 'عام سوالات';

  @override
  String get profileFaqAddPiecesTitle =>
      'میں اپنی وارڈڈروب میں کپڑے کیسے شامل کروں؟';

  @override
  String get profileFaqAddPiecesBody =>
      'کلوچیٹ ٹیب پر آئیں شامل کریں پر ٹیپ کریں۔ تصویر لیں یا گیلری سے منتخب کریں؛ ہم ہر چیز تلاش کرتے ہیں اور آپ کے لیے ٹیگ کرتے ہیں۔';

  @override
  String get profileFaqMatchingTitle => 'آؤٹ فٹ میچنگ کیسے کام کرتی ہے؟';

  @override
  String get profileFaqMatchingBody =>
      'آپ کے لیے کھولیں اور اپنی ملکیت کے ٹکڑے چنیں۔ ہم تجویز کرتے ہیں کہ ان کے ساتھ کیا جاتا ہے اور آپ کی الماری سے مکمل لباس تیار کرتے ہیں۔';

  @override
  String get profileFaqTryOnTitle =>
      'کیا میں ٹرائی آن کے لیے اپنی تصاویر استعمال کر سکتا ہوں؟';

  @override
  String get profileFaqTryOnBody =>
      'ہاں۔ اپنی پوری لمبائی کی تصویر شامل کریں، پھر انہیں اپنے اوپر دیکھنے کے لیے ٹکڑے منتخب کریں۔';

  @override
  String get profileFaqRewardsTitle => 'میں انعامات کیسے کما سکتا ہوں؟';

  @override
  String get profileFaqRewardsBody =>
      'اکثر آؤٹ فٹ کی منصوبہ بندی کریں اور لاگ ان کریں۔ جیسے جیسے آپ آگے بڑھتے ہیں سلسلہ اور کامیابیاں بنتی ہیں۔';

  @override
  String get profileFaqPrivacyTitle => 'کیا میری الماری نجی ہے؟';

  @override
  String get profileFaqPrivacyBody =>
      'ہاں۔ آپ کی الماری اور لباس نجی ہیں جب تک کہ آپ ایک لباس کا لنک شیئر نہ کریں۔';

  @override
  String get profileHelpMoreTitle => 'مزید مدد';

  @override
  String get profileHelpGuides => 'گائیڈز';

  @override
  String get profileHelpGuidesBody => 'ہر خصوصیت کیسے کام کرتی ہے';

  @override
  String get feedbackCategoryBug => 'کچھ خراب ہو گیا';

  @override
  String get feedbackCategoryIdea => 'ایک خیال';

  @override
  String get feedbackCategoryGeneral => 'عمومی';

  @override
  String get feedbackCategoryHelp => 'مجھے مدد کی ضرورت ہے';

  @override
  String get feedbackHintBug =>
      'کیا ہوا، اور آپ کو کیا توقع تھی؟ اقدامات سے ہمیں اسے ٹھیک کرنے میں مدد ملتی ہے۔';

  @override
  String get feedbackHintIdea => 'آپ کیا چاہتے ہیں، اور کیوں؟';

  @override
  String get feedbackHintGeneral =>
      'ہمیں بتائیں کہ آپ کیا سوچتے ہیں، یا کوئی سوال پوچھیں۔';

  @override
  String get feedbackAttachmentLimitBody => 'آپ 5 تک تصاویر شامل کر سکتے ہیں۔';

  @override
  String get feedbackAttachmentLimitTitle => 'حد تک پہنچ گئے';

  @override
  String get feedbackImageTooLargeBody => '5 ایم بی سے کم کی تصویر منتخب کریں۔';

  @override
  String get feedbackImageTooLargeTitle => 'تصویر بہت بڑی ہے';

  @override
  String get feedbackTitle => 'آراء بھیجیں';

  @override
  String get feedbackAboutLabel => 'یہ کس کے بارے میں ہے؟';

  @override
  String get feedbackSubjectLabel => 'موضوع';

  @override
  String get feedbackSubjectRequired => 'موضوع شامل کریں';

  @override
  String get feedbackSubjectTooShort => 'موضوع کم از کم 3 حروف کا ہونا چاہیے';

  @override
  String get feedbackDetailsLabel => 'تفصیلات';

  @override
  String get feedbackDetailsRequired => 'کچھ تفصیلات شامل کریں';

  @override
  String get feedbackDetailsTooShort => 'تفصیل کم از کم 10 حروف کی ہونی چاہیے';

  @override
  String get feedbackAddScreenshot => 'اسکرین شاٹ شامل کریں';

  @override
  String get feedbackAttachmentHint => 'زیادہ سے زیادہ 5، ہر ایک 5 ایم بی';

  @override
  String get feedbackSend => 'بھیجیں';

  @override
  String get feedbackEmptyTitle => 'ابھی تک کچھ نہیں بھیجا گیا';

  @override
  String get feedbackEmptyBody =>
      'آپ جو بھیجیں گے وہ یہاں اس کی حیثیت کے ساتھ ظاہر ہوگا۔';

  @override
  String get feedbackHistoryTitle => 'آپ کا بھیجا ہوا';

  @override
  String get feedbackStatusOpen => 'کھلا ہے';

  @override
  String get feedbackStatusInProgress => 'جاری ہے';

  @override
  String get feedbackStatusResolved => 'حل ہو گیا';

  @override
  String get feedbackStatusClosed => 'بند ہے';

  @override
  String get legalIntro =>
      'ہم آپ کے ڈیٹا کی حفاظت کیسے کرتے ہیں، اور FitCheck AI استعمال کرنے کی شرائط۔';

  @override
  String get legalPolicies => 'پالیسیاں';

  @override
  String get legalPrivacySubtitle => 'ہم کیا جمع کرتے ہیں اور کیوں';

  @override
  String get legalTermsTitle => 'استعمال کی شرائط';

  @override
  String get legalTermsSubtitle => 'ایپ استعمال کرنے کے اصول';

  @override
  String get legalLicences => 'اوپن سورس لائسنس';

  @override
  String get legalSupportSubtitle => 'مدد، رابطہ اور رازداری کی درخواستیں';

  @override
  String get legalReportAbuse => 'کوئی مسئلہ یا خرابی رپورٹ کریں';

  @override
  String get permissionCameraTitle => 'کیمرے تک رسائی';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI آپ کے کپڑوں اور لباس کی تصاویر لینے کے لیے آپ کا کیمرہ استعمال کرتا ہے۔';

  @override
  String get permissionPhotoTitle => 'تصاویر تک رسائی';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI کو آپ کی تصاویر تک رسائی کی ضرورت ہے تاکہ آپ لباس منتخب کر سکیں۔';

  @override
  String get permissionNotNow => 'ابھی نہیں';

  @override
  String get permissionOpenSettings => 'سیٹنگز کھولیں';

  @override
  String authSignedInAs(String name) {
    return 'بطور $name سائن ان ہیں';
  }

  @override
  String get authSignedIn => 'سائن ان ہو گیا';

  @override
  String get authWelcomeBackTitle => 'خوش آمدید';

  @override
  String get authSignInFailed => 'سائن ان ناکام ہو گیا';

  @override
  String get authWelcomeTitle => 'خوش آمدید';

  @override
  String get authSignUpFailed => 'سائن اپ ناکام ہو گیا';

  @override
  String get authGoogleSignInFailed => 'گوگل سائن ان ناکام ہو گیا';

  @override
  String get authAppleSignInFailed => 'ایپل سائن ان ناکام ہو گیا';

  @override
  String get authConfirmEmailTitle => 'اپنا ای میل تصدیق کریں';

  @override
  String get authConfirmEmailBody =>
      'تصدیقی ای میل کے لیے اپنا ان باکس چیک کریں، پھر سائن ان کریں۔';

  @override
  String get authClosetReady => 'آپ کی الماری تیار ہے۔';

  @override
  String get authSignedOutTitle => 'سائن آؤٹ ہو گیا';

  @override
  String get authSignedOutBody => 'آپ سائن آؤٹ ہیں۔';

  @override
  String get authSignOutFailed => 'سائن آؤٹ ناکام ہو گیا';

  @override
  String get authEmailSentTitle => 'ای میل بھیج دیا گیا';

  @override
  String get authResetLinkSent => 'ری سیٹ لنک کے لیے اپنا ای میل چیک کریں۔';

  @override
  String get authPasswordUpdatedTitle => 'پاس ورڈ اپ ڈیٹ ہو گیا';

  @override
  String get authPasswordUpdated => 'آپ کا پاس ورڈ اپ ڈیٹ ہو گیا ہے۔';

  @override
  String get authPasswordNotUpdated => 'پاس ورڈ اپ ڈیٹ نہیں ہوا';

  @override
  String get authCouldNotSendEmail => 'ای میل نہیں بھیجا جا سکا';

  @override
  String get authEmailNotSent => 'ای میل نہیں بھیجا گیا';

  @override
  String get authResendSentBody => 'ہم نے نیا تصدیقی ای میل بھیج دیا ہے۔';

  @override
  String get outfitPreviewWithAi => 'AI سے دیکھیں';

  @override
  String get outfitNewPreview => 'نیا پیش منظر بنائیں';

  @override
  String get outfitBuilderClosetHeading => 'آپ کا کمرہ';

  @override
  String get outfitBuilderSearchHint => 'شئیں تلاش کریں';

  @override
  String get outfitClearSearch => 'تلاش صاف کریں';

  @override
  String get outfitBuilderAddPiecesTitle => 'پہلے شئیں شامل کریں';

  @override
  String get outfitBuilderAddPiecesBody =>
      'دستار آپ کے کمرے کی اشیاء سے بنتے ہیں۔';

  @override
  String get outfitBuilderNoMatches => 'کوئی شے مداخل نہیں ہوئی۔';

  @override
  String get outfitNameLabel => 'دستار کا نام';

  @override
  String get outfitNameHint => 'مثلاً، ہفتہ وار لینن';

  @override
  String get outfitPreviewSemantic => 'دستار کا AI پیش منظر';

  @override
  String get outfitChoosePieces => 'شئیں منتخب کریں';

  @override
  String get outfitTapPiecesHint =>
      'شامل کرنے کے لیے نیچے کی اشیاء پر کلک کریں۔';

  @override
  String get outfitShareTooltip => 'شیئر کریں';

  @override
  String get outfitSaveFavourite => 'پسندیدہ میں محفوظ کریں';

  @override
  String get outfitPiecesHeading => 'شئیں';

  @override
  String get outfitWearHistoryEmpty =>
      'ایک بار پہنیں اور تاریخیں یہاں نظر آئیں گی۔';

  @override
  String get outfitWearHistoryTitle => 'پہننے کا تاریخی رکورد';

  @override
  String get outfitWearHistoryError => 'تاریخیں لوڈ نہیں ہو سکیں۔';

  @override
  String get outfitWornOn => 'پہنی گئی تاریخ';

  @override
  String get outfitEditTitle => 'دستار میں ترمیم';

  @override
  String get outfitSavedPhotosFailed => 'تفصیلات محفوظ، تصاویر نہیں';

  @override
  String get outfitNoPhotosBody =>
      'ابھی کوئی تصاویر نہیں۔ دستار اپنی اشیاء دکھاتا ہے۔';

  @override
  String get outfitOccasionLabel => 'موزوں موقع';

  @override
  String get outfitOccasionNone => 'کوئی نہیں';

  @override
  String get outfitTagsHint => 'کوما سے علیحدہ کریں';

  @override
  String get outfitDraftBody => 'آپ کی بنیادی فہرست سے چھپا ہوا';

  @override
  String get outfitPublic => 'عام';

  @override
  String get outfitPublicBody => 'لنک والے کوئی بھی دیکھ سکتا ہے';

  @override
  String get outfitDeleteFromDetail => 'دستار کو تفصیلی صفحے سے حذف کریں۔';

  @override
  String get outfitNewCollection => 'نئی کالیجن';

  @override
  String get outfitNoCollectionsTitle => 'ابھی کوئی کالیجن نہیں';

  @override
  String get outfitNoCollectionsBody =>
      'آؤٹ فٹس کو سفر، موسم یا محسوس کے لحاظ سے گروپ کریں۔';

  @override
  String get outfitCreateCollection => 'کالیجن بنائیں';

  @override
  String get outfitAddOutfits => 'آؤٹ فٹس شامل کریں';

  @override
  String get outfitRename => 'نام تبدیل کریں';

  @override
  String get outfitCollectionDeleteBody =>
      'اس میں موجود آؤٹ فٹس محفوظ رہیں گے۔';

  @override
  String get outfitCollectionsNotLoaded => 'آؤٹ فٹس لوڈ نہیں ہوئے';

  @override
  String get outfitRenameCollection => 'کالیجن کا نام تبدیل کریں';

  @override
  String get outfitDescriptionOptional => 'تفصیل (اختیاری)';

  @override
  String get outfitAllInCollection =>
      'ہر آؤٹ فٹ اس کالیجن میں پہلے سے موجود ہے۔';

  @override
  String get photoshootSubtitleUpload => 'اپنی تصاویر سے اسٹوڈیو پورٹریٹس';

  @override
  String get photoshootSubtitleConfigure =>
      'اسٹائل، فارمیٹ اور تعداد کا انتخاب کریں';

  @override
  String get photoshootSubtitleGenerating => 'اس میں ایک دو منٹ لگیں گے';

  @override
  String get photoshootAddPhotosSemantic => 'اپنی گیلری سے تصاویر شامل کریں';

  @override
  String get photoshootUploadTitle => 'اپنے بارے میں 1 سے 4 تصاویر شامل کریں';

  @override
  String get photoshootUploadBody =>
      'اپنی گیلری سے انتخاب کرنے کے لیے ٹیپ کریں';

  @override
  String get photoshootAddToContinue => 'آگے بڑھنے کے لیے تصویر شامل کریں';

  @override
  String get photoshootAddAnotherPhoto => 'ایک اور تصویر شامل کریں';

  @override
  String get photoshootTipsTitle => 'بہتر نتائج کے لیے';

  @override
  String get photoshootTipsBody =>
      'اپنے چہرے کی واضح اور اچھی روشنی میں والی تصاویر استعمال کریں جو مختلف زاویوں سے ہوں۔ ڈانگی اور ٹوپی سے پرہیز کریں۔';

  @override
  String get photoshootStarting => 'شروع ہو رہا ہے';

  @override
  String get photoshootCancelling => 'منسوخ ہو رہا ہے';

  @override
  String get photoshootFailed => 'ناکام';

  @override
  String get recommendTabMatches => 'میچ';

  @override
  String get recommendTabComplete => 'مکمل';

  @override
  String get recommendTabWeather => 'ماہواری';

  @override
  String get recommendTabColours => 'رنگ';

  @override
  String get recommendTabShop => 'دکان';

  @override
  String get recommendNoMatchesTitle => 'ابھی کوئی میچ نہیں';

  @override
  String get recommendNoMatchesBody =>
      'ایک چیز چنیں اور ہم دیکھیں گے کہ اس کے ساتھ کیا چلتا ہے۔';

  @override
  String get recommendPickPiece => 'ایک چیز چنیں';

  @override
  String get recommendNothingMatchesTitle => 'ابھی کوئی مماثلت نہیں';

  @override
  String get recommendNothingMatchesBody =>
      'دیگر چیزوں کی کوشش کریں یا اپنی کمرہ میں مزید شامل کریں۔';

  @override
  String get recommendChangePieces => 'چیزیں تبدیل کریں';

  @override
  String get recommendDefaultReason => 'یہ آپ کی چنی ہوئی چیزوں سے متعارف ہے۔';

  @override
  String get recommendCompleteTitle => 'دیک کو مکمل کریں';

  @override
  String get recommendCompleteBody => 'ایک چیز چنیں اور ہم باقی پُر کریں گے۔';

  @override
  String get recommendWorking => 'کام کر رہا ہے';

  @override
  String get recommendGenerate => 'جنریٹ کریں';

  @override
  String get recommendChooseStyleBody => 'ایک اسٹائل چنیں، پھر جنریٹ کریں۔';

  @override
  String get recommendNoLooksTitle => 'ان چیزوں کے لیے کوئی دیک نہیں';

  @override
  String get recommendNoLooksBody => 'دوسرا اسٹائل یا دوسری چیزیں چنیں۔';

  @override
  String get recommendDefaultLook => 'آپ کی چیزوں کا دیک';

  @override
  String get recommendNoPiecesBody => 'اس دیک کے لیے کوئی چیز نہیں ملی۔';

  @override
  String get recommendCityLabel => 'شہر';

  @override
  String get recommendCheck => 'چیک کریں';

  @override
  String get recommendWeatherTitle => 'موسم کیسا ہے؟';

  @override
  String get recommendWeatherBody =>
      'آج کے لیے چنسیوں کے لیے اپنا شہر درج کریں۔';

  @override
  String get recommendWearToday => 'آج پہنیں';

  @override
  String get recommendWeatherNoPieces =>
      'اس موسم کے لیے آپ کی کمرہ میں ابھی کوئی چیز نہیں۔';

  @override
  String get recommendBudgetLabel => 'بجٹ تک';

  @override
  String get recommendLooking => 'دیکھ رہا ہے';

  @override
  String get recommendFindWhatToBuy => 'خریدنے والی چیزیں تلاش کریں';

  @override
  String get recommendFillGapsTitle => 'خالی جگہیں پُر کریں';

  @override
  String get recommendFillGapsBody =>
      'بجٹ طے کریں اور ہم تجویز کریں گے کہ کمرہ میں کس کی کمی ہے۔';

  @override
  String get recommendNoGapsTitle => 'کوئی کمی نہیں ملی';

  @override
  String get recommendNoGapsBody => 'بڑا بجٹ یا دوسرا شعبہ آزمائیں۔';

  @override
  String get recommendMoodEveryday => 'ہر روز';

  @override
  String get recommendMoodBigMeeting => 'بڑی ملاقات';

  @override
  String get recommendDayLabel => 'دن';

  @override
  String get recommendReadingStars => 'ستاروں کو پڑھ رہے ہیں';

  @override
  String get recommendGetMyColours => 'میرے رنگ معلوم کریں';

  @override
  String get recommendLuckyColoursTitle => 'آپ کے خوش قسمتی والے رنگ';

  @override
  String get recommendLuckyColoursBody =>
      'ایک دن منتخب کریں اور ہم اس کے لیے رنگ اور کپڑے تجویز کریں گے۔';

  @override
  String get recommendLuckyColoursSection => 'خوش قسمتی والے رنگ';

  @override
  String get recommendAvoidColoursSection => 'جن رنگوں سے ہاتھ رکھیں';

  @override
  String get recommendBirthDateTitle => 'اپنا تاریخِ پیدائش شامل کریں';

  @override
  String get recommendBirthDateBody =>
      'آپ کے رنگوں کو پڑھنے کے لیے ہمیں آپ کی تاریخِ پیدائش درکار ہے۔';

  @override
  String get recommendEditProfile => 'پروفائل میں ترمیم کریں';

  @override
  String get recommendNothingThisDay => 'اس دن کے لیے کچھ نہیں۔';

  @override
  String get recommendUnnamedColour => 'نامعلوم رنگ';

  @override
  String get recommendFromCloset => 'آپ کے کمرے سے';

  @override
  String get recommendNoPiecesInColours => 'ان رنگوں میں ابھی کوئی چیز نہیں۔';

  @override
  String get recommendOutfitIdeas => 'آؤٹ فٹ کے خیالات';

  @override
  String get recommendNoOutfitsInColours =>
      'ان رنگوں میں ابھی مکمل آؤٹ فٹ نہیں۔';

  @override
  String get recommendDefaultOutfitIdea => 'ایک آؤٹ فٹ کا خیال';

  @override
  String get recommendPickUpToThree => 'تین کپڑے منتخب کریں';

  @override
  String get recommendEmptyClosetBody =>
      'پہلے چند کپڑے شامل کریں، پھر میچوں کے لیے واپس آئیں۔';

  @override
  String get dashboardDressForDay => 'آنے والے دن کے لیے لباس پہنیں۔';

  @override
  String get dashboardOutfitOfDay => 'دن کا آؤٹ فٹ';

  @override
  String get dashboardFreshLook => 'نیا لوک';

  @override
  String get subscriptionManageInStoreTitle => 'اسٹور میں انتظام کریں';

  @override
  String get subscriptionManageInStoreBody =>
      'یہ پلان اسٹور کے ذریعے بل کیا جاتا ہے۔ اسے اپنے اسٹور اکاؤنٹ کی سیٹنگز میں انتظام کریں۔';

  @override
  String get subscriptionCancelledTitle => 'سبسکرپشن منسوخ';

  @override
  String get subscriptionCancelledBody =>
      'آپ کا پلان بلنگ کے عرصے کے اختتام تک فعال رہے گا۔';

  @override
  String get subscriptionCancelFailedTitle => 'منسوخی ناموفق';

  @override
  String get subscriptionCouldNotOpenTitle => 'کھولنا ناممکن';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'بلنگ کے انتظام کو کھولا نہیں جا سکا۔';

  @override
  String get subscriptionOpenLinkFailedBody => 'لنک کھولا نہیں جا سکا۔';

  @override
  String get subscriptionReferralLoadFailedTitle => 'آپ کی لنک لوڈ نہیں ہو سکی';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'آپ کی رفرنل لنک لوڈ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get subscriptionReferralCopiedTitle => 'کاپی ہوگیا';

  @override
  String get subscriptionReferralCopiedBody => 'ریفرنل لنک کاپی ہوگئی۔';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI آزمائیں';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI شامل ہوں اور ہم دونوں کو Pro کا ایک ماہ ملے گا۔ $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'لنک کاپی ہوئی';

  @override
  String get subscriptionShareUnavailableBody =>
      'شیئرنگ دستیاب نہیں ہے، اس لیے ہم نے لنک کاپی کی۔';

  @override
  String get subscriptionShareFailedTitle => 'شیئر نہیں ہو سکا';

  @override
  String get subscriptionShareFailedBody => 'ریفرنل پیج سے لنک کاپی کریں۔';

  @override
  String get subscriptionStoreReadyTitle => 'اسٹور تیار ہے';

  @override
  String get subscriptionStoreReadyBody =>
      'اسٹور کے قیمتیں دستیاب ہیں۔ آپ اب اپ گریڈ کر سکتے ہیں۔';

  @override
  String get purchaseFailedTitle => 'خریداری ناکام';

  @override
  String get purchaseUnavailableTitle => 'خریداری دستیاب نہیں';

  @override
  String get purchaseIapUnavailableBody =>
      'اس ڈیوائس پر ان اپ پیچز دستیاب نہیں ہیں۔';

  @override
  String get purchasePlanNotAvailableBody =>
      'یہ پلان ابھی خریداری کے لیے دستیاب نہیں ہے۔';

  @override
  String get purchasePlanNotInStoreBody =>
      'یہ پلان اسٹور میں ابھی دستیاب نہیں ہے۔ براہ کرم جلد واپس آئیں۔';

  @override
  String get purchaseStartFailedBody =>
      'خریداری شروع نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get purchaseNoPaymentLinkBody => 'چیک آؤٹ نے پیمنٹ لنک واپس نہیں دیا۔';

  @override
  String get purchasePendingTitle => 'خریداری برقرار';

  @override
  String get purchasePendingBody =>
      'آپ کی خریداری منظور کے منتظر ہے۔ جیسے ہی منظور ہو جائے گا آپ کو رسائی ملے گی۔';

  @override
  String get purchaseFailedBody => 'خریداری ناکام ہوئی۔ دوبارہ کوشش کریں۔';

  @override
  String get purchaseRestoredTitle => 'بحال';

  @override
  String get purchaseRestoredBody => 'آپ کی خریداریاں بحال کر دی گئیں۔';

  @override
  String get purchaseActiveTitle => 'سبسکرپشن فعال';

  @override
  String get purchaseActiveBody => 'آپ کی سبسکرپشن فعال ہے۔ خوش آمدید۔';

  @override
  String get purchaseSignInRequiredTitle => 'سائن ان درکار';

  @override
  String get purchaseSignInRequiredBody =>
      'اپنی خریداری مکمل کرنے کے لیے سائن ان کریں۔';

  @override
  String get purchaseErrorTitle => 'خریداری کی خرابی';

  @override
  String get purchaseInvalidTransactionBody =>
      'خریداری میں مستند ٹرانزیکشن آئی ڈی شامل تھی نہیں۔';

  @override
  String get purchaseVerificationPendingTitle => 'تصدیق زیرِ عمل ہے';

  @override
  String get purchaseVerificationPendingBody =>
      'فی الحال اسٹور سے آپ کی خریداری کی تصدیق نہیں ہو سکی۔ یہ خودبخود مکمل ہو جائے گی اور آپ کو دوبارہ فیس نہ لی جائے گی۔';

  @override
  String get purchaseNotAppliedTitle => 'خریداری لاگو نہیں ہوئی';

  @override
  String get purchaseNotAppliedBody =>
      'آپ کی خریداری آپ کے اکاؤنٹ پر لاگو نہیں ہو سکی۔ سپورٹ سے رابطہ کریں اور دوبارہ خریداری نہ کریں۔';

  @override
  String get purchaseRestoreFailedTitle => 'بحال کرنے میں ناکامی';

  @override
  String get purchaseRestoreFailedBody =>
      'خریداریاں بحال نہیں کی جا سکتیں۔ دوبارہ کوشش کریں۔';

  @override
  String get purchaseRecoveredActiveBody => 'آپ کی سبسکرپشن فعال ہے۔';

  @override
  String get purchaseCompleteTitle => 'خریداری مکمل';

  @override
  String get giftCreateFailedTitle => 'تحفہ بنانے میں ناکام';

  @override
  String get giftClaimFailedTitle => 'تحفہ حاصل کرنے میں ناکام';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تحائف آپ کے لیے',
      one: 'آپ کے لیے ایک تحفہ',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 مہینہ',
      '12': '1 سال',
      'other': '$months مہینے',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining باقی',
      one: '1 باقی',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro کی $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender نے آپ کو FitCheck Pro کی $duration بھیجی ہے۔ $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient کے لیے FitCheck Pro کا تحفہ';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender سے';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient کے لیے';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender سے';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'آپ کا موصول کنندہ';

  @override
  String get giftPreviewPlaceholderSender => 'آپ';

  @override
  String get settingsSavedTitle => 'محفوظ';

  @override
  String get settingsNotSavedTitle => 'محفوظ نہیں';

  @override
  String get settingsAiChooseProviderBody => 'ایک فراہم کنندہ منتخب کریں۔';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'کسٹم فراہم کنندہ کو API URL درکار ہے۔';

  @override
  String get settingsAiKeyRequiredBody => 'API مفتاح درج کریں۔';

  @override
  String get settingsAiSavedBody => 'آپ کے AI سیٹنگز محفوظ ہو گئی ہیں۔';

  @override
  String get settingsAiMissingDetailsTitle => 'تفصیلات غائب ہیں';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'ٹیسٹ کے لیے اے پی آئی یو آر ایل اور چیٹ ماڈل درج کریں۔';

  @override
  String get settingsAiKeyNeededTitle => 'API مفتاح درکار';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'ٹیسٹ کے لیے اپنا API مفت داخل کریں۔ آپ کا محفوظ مفت نجی رہتا ہے۔';

  @override
  String get settingsAiKeyToTestBody => 'ٹیسٹ کے لیے اپنا API مفت داخل کریں۔';

  @override
  String get settingsAiConnectedTitle => 'منسلک';

  @override
  String get settingsAiConnectedBody => 'کنیکشن کام کر رہا ہے۔';

  @override
  String get settingsAiTestFailedTitle => 'ٹیسٹ ناکام';

  @override
  String get settingsPreferencesSavedBody => 'آپ کی ترجیحات محفوظ ہیں۔';

  @override
  String get settingsPasswordNotChangedTitle => 'پاس ورڈ تبدیل نہیں ہوا';

  @override
  String get settingsOAuthPasswordBody =>
      'یہ اکاؤنٹ گوگل یا اےپل کے ساتھ سائن ان کرتا ہے۔ پہلے پاس ورڈ سیٹ کرنے کے لیے \"پاس ورڈ بھول گئے\" استعمال کریں۔';

  @override
  String get settingsCurrentPasswordIncorrectBody => 'موجودہ پاس ورڈ غلط ہے۔';

  @override
  String get settingsExportReadyTitle => 'ایکسپورٹ تیار';

  @override
  String get settingsExportReadyBody =>
      'آپ کے ڈیٹا کا ایکسپورٹ ڈاؤن لوڈ کے لیے تیار ہے۔';

  @override
  String get settingsLinkCopiedTitle => 'لنک کاپی ہو گیا';

  @override
  String get settingsExportClipboardBody =>
      'ہم آپ کا براؤزر کھول نہیں سکے، اس لیے ہم نے ڈاؤن لوڈ لنک کاپی کیا ہے۔ اسے فوری طور پر براؤزر میں پیسٹ کریں: یہ ختم ہو جائے گا۔';

  @override
  String get settingsExportFailedTitle => 'ایکسپورٹ ناکام';

  @override
  String get settingsAccountNotDeletedTitle => 'اکاؤنٹ حذف نہیں ہوا';

  @override
  String photoshootPhotoLimit(int max) {
    return 'آپ $max تصاویر شامل کر سکتے ہیں۔';
  }

  @override
  String get photoshootPhotoLimitTitle => 'تصویر کی حد';

  @override
  String get photoshootAddAtLeastOnePhoto => 'کم از کم ایک تصویر شامل کریں۔';

  @override
  String get photoshootNoPhotosSelectedTitle => 'کوئی تصویر نہیں';

  @override
  String get photoshootDescribeLookBody =>
      'اس.look کو بیان کریں جس کی آپ چاہتے ہیں۔';

  @override
  String get photoshootPromptNeededTitle => 'پرامپٹ درکار';

  @override
  String get photoshootConsentFeatureLabel => 'AI فوٹوشوٹ';

  @override
  String get photoshootStatusPreparing => 'آپ کی تصاویر تیاری میں';

  @override
  String get photoshootStatusGenerating => 'تیار ہو رہا ہے';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'بچ $current میں سے $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done میں سے $total مکمل';
  }

  @override
  String get photoshootGenerationFailedBody => 'پیداوار ناکام ہوئی۔';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready تیار، $failed ناکام۔';
  }

  @override
  String get photoshootPartlyDoneTitle => 'ذاتی طور پر مکمل';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصاویر تیار ہیں۔',
      one: '1 تصویر تیار ہے۔',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'کنکشن کٹ گیا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get photoshootCouldNotCancelTitle => 'منسوخ نہیں ہو سکا';

  @override
  String get photoshootRetryFailedTitle => 'دوبارہ کوشش ناکام';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'تصویر $number تیار ہے۔';
  }

  @override
  String get photoshootReplacedTitle => 'بدلا گیا';

  @override
  String get photoshootSavedToGalleryBody => 'آپ کے گیلری میں محفوظ کیا گیا۔';

  @override
  String get photoshootSavedTitle => 'محفوظ';

  @override
  String get photoshootNotSavedTitle => 'محفوظ نہیں';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمام $count تصاویر آپ کی گیلری میں ہیں۔',
      one: '1 تصویر آپ کی گیلری میں ہے۔',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$total میں سے $saved محفوظ۔';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'کچھ تصاویر محفوظ نہیں ہوئیں';

  @override
  String get tryonConsentFeatureLabel => 'وچول ٹرائی آؤن';

  @override
  String get tryonAvatarUpdatedBody => 'آپ کی تصویر اپ ڈیٹ ہو گئی۔';

  @override
  String get tryonSavedTitle => 'محفوظ';

  @override
  String get tryonUploadFailedTitle => 'اپ لوڈ ناکام';

  @override
  String get tryonChooseGarmentFirstBody =>
      'پہلے کسی کپڑے کی تصویر منتخب کریں۔';

  @override
  String get tryonNoGarmentTitle => 'کپڑا دستیاب نہیں';

  @override
  String get tryonWaitForUploadBody =>
      'اپنی تصویر کے اپ لوڈ مکمل ہونے کا انتظار کریں۔';

  @override
  String get tryonStillUploadingTitle => 'ابھی اپ لوڈ ہو رہا ہے';

  @override
  String get tryonAddYourPhotoFirstBody => 'پہلے اپنی کسی تصویر کو شامل کریں۔';

  @override
  String get tryonReadyBody => 'آپ کا ٹرائی آؤن تیار ہے۔';

  @override
  String get tryonFailedTitle => 'ٹرائی آؤن ناکام';

  @override
  String get tryonSavedToGalleryBody => 'آپ کے گیلری میں محفوظ کیا گیا۔';

  @override
  String get tryonNotSavedTitle => 'محفوظ نہیں';

  @override
  String get calendarEventAddedBody => 'ایونٹ شامل کر دیا گیا';

  @override
  String get calendarEventPlannedTitle => 'پلان کیا گیا';

  @override
  String get calendarEventSavedBody => 'ایونٹ محفوظ کر دیا گیا';

  @override
  String get calendarSavedTitle => 'محفوظ';

  @override
  String get calendarEventNotSavedTitle => 'ایونٹ محفوظ نہیں ہوا';

  @override
  String get calendarEventRemovedBody => 'ایونٹ ہٹا دیا گیا';

  @override
  String get calendarEventDeletedTitle => 'حذف کردہ';

  @override
  String get calendarEventNotDeletedTitle => 'یونٹ ہٹایا نہیں گیا';

  @override
  String get calendarOutfitNotLinkedTitle => 'آؤٹ فٹ جڑا نہیں گیا';

  @override
  String get calendarLinkedTitle => 'جڑا ہوا';

  @override
  String get calendarOutfitNotRemovedTitle => 'آؤٹ فٹ ہٹایا نہیں گیا';

  @override
  String get calendarOutfitRemovedBody => 'آؤٹ فٹ ہٹا دیا گیا';

  @override
  String get calendarDisconnectedBody => 'کیلنڈر کو الگ کر دیا گیا';

  @override
  String get calendarDisconnectedTitle => 'الگ کیا گیا';

  @override
  String get calendarNotDisconnectedTitle => 'کیلنڈر کو الگ نہیں کیا گیا';

  @override
  String get calendarTodayLabel => 'آج';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count یونٹس',
      one: '1 یونٹ',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start سے $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, آؤٹ فٹ جڑا ہوا';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" کو ختم کر دیا جائے گا۔';
  }

  @override
  String get calendarThisAppLabel => 'یہ ایپ';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider کے ساتھ سنک نہیں دستیاب ہے۔ آپ اس میں ایونٹس شامل کر سکتے ہیں۔';
  }

  @override
  String get calendarWeekdaySunShort => 'اتوار';

  @override
  String get calendarWeekdayMonShort => 'پیر';

  @override
  String get calendarWeekdayTueShort => 'منگل';

  @override
  String get calendarWeekdayWedShort => 'بدھ';

  @override
  String get calendarWeekdayThuShort => 'جمعرات';

  @override
  String get calendarWeekdayFriShort => 'جمعہ';

  @override
  String get calendarWeekdaySatShort => 'ہفتہ';

  @override
  String get calendarWeekdayMonday => 'پیر';

  @override
  String get calendarWeekdayTuesday => 'منگل';

  @override
  String get calendarWeekdayWednesday => 'بدھ';

  @override
  String get calendarWeekdayThursday => 'جمعرات';

  @override
  String get calendarWeekdayFriday => 'جمعہ';

  @override
  String get calendarWeekdaySaturday => 'ہفتہ';

  @override
  String get calendarWeekdaySunday => 'اتوار';

  @override
  String get outfitSavedToFavouritesBody => 'پسندیدوں میں محفوظ کردیا گیا';

  @override
  String get outfitRemovedFromFavouritesBody => 'پسندیدوں سے ہٹا دیا گیا';

  @override
  String get outfitNotSavedTitle => 'محفوظ نہیں ہوا';

  @override
  String get outfitLoggedAsWornBody => 'آج پہنے جانے کے طور پر رجسٹر کیا گیا۔';

  @override
  String get outfitNicePickTitle => 'اچھی پسند';

  @override
  String get outfitRemovedBody => 'آؤٹ فٹ ہٹا دیا گیا۔';

  @override
  String get outfitDeletedTitle => 'حذف کیا گیا';

  @override
  String get outfitNotDeletedTitle => 'حذف نہیں ہوا';

  @override
  String get outfitDuplicatedBody => 'آپ کے آؤٹ فٹ میں کاپی موجود ہے۔';

  @override
  String get outfitDuplicatedTitle => 'ڈپلیکیٹ کیا گیا';

  @override
  String get outfitNotDuplicatedTitle => 'ڈپلیکیٹ نہیں ہوا';

  @override
  String get outfitNotSharedTitle => 'شیئر نہیں ہوا';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" تیار ہے۔';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'کلیکشن نہیں بنی';

  @override
  String get outfitCollectionUpdatedBody => 'کلیکشن اپڈیٹ ہو گئی۔';

  @override
  String get outfitCollectionNotUpdatedTitle => 'کلیکشن اپڈیٹ نہیں ہوئی';

  @override
  String get outfitCollectionDeletedBody => 'کلیکشن حذف کر دی گئی۔';

  @override
  String get outfitCollectionNotDeletedTitle => 'کلیکشن حذف نہیں ہوئی';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آؤٹ فٹ شامل کیے گئے۔',
      one: '1 آؤٹ فٹ شامل کیا گیا۔',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'آؤٹ فٹ شامل نہیں ہوئے';

  @override
  String get outfitPreviewNotCreatedTitle => 'پریویو نہیں بنی';

  @override
  String get outfitGiveNameBody => 'آؤٹ فٹ کو ایک نام دیں۔';

  @override
  String get outfitNameMissingTitle => 'نام';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'کم از کم ایک پیس منتخب کریں۔';

  @override
  String outfitCreatedBody(String name) {
    return '$name آپ کے آؤٹ فٹ میں شامل ہے۔';
  }

  @override
  String get outfitSavedTitle => 'محفوظ ہوا';

  @override
  String get wardrobeAddedToFavouritesBody => 'پسندیدوں میں شامل کر دیا گیا';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'پسندیدوں سے ہٹا دیا گیا';

  @override
  String get wardrobeNotSavedTitle => 'محفوظ نہیں ہوا';

  @override
  String get wardrobeLoggedAsWornBody => 'آج پہننے کے طور پر جمع ہو گیا۔';

  @override
  String get wardrobeRemovedFromClosetBody =>
      'آپ کے کپڑوں کے خانے سے حذف کر دیا گیا۔';

  @override
  String get wardrobeDeletedTitle => 'حذف کر دیا گیا';

  @override
  String get wardrobeNotDeletedTitle => 'حذف نہیں کیا گیا';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کپڑے آپ کے کپڑوں کے خانے سے حذف کر دیے گئے۔',
      one: '1 کپڑا آپ کے کپڑوں کے خانے سے حذف کر دیا گیا۔',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI کپڑوں کے خانے کی شناخت';

  @override
  String get itemAddScanJobLabel => 'اسکن کریں';

  @override
  String get itemAddFoundEarlierBody => 'پچھلی اسکن میں پایا گیا';

  @override
  String get itemAddLookingAtPhoto => 'آپ کی تصویر پر نظر ڈال رہے ہیں';

  @override
  String get itemAddExtractionFailedBody => 'تشخیص ناکام رہی';

  @override
  String get itemAddJobFailedBody => 'کام ناکام رہا';

  @override
  String get itemAddConnectionLostBody => 'کنکشن کٹ گیا۔ دوبارہ کوشش کریں۔';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'پروسیسنگ کے دوران کنکشن کٹ گیا۔';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'کپڑا نمبر $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'کپڑا';

  @override
  String get itemAddNotCancelledTitle => 'منسوخ نہیں کیا گیا';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کپڑے آپ کے کپڑوں کے خانے میں محفوظ ہیں۔',
      one: '1 کپڑا آپ کے کپڑوں کے خانے میں محفوظ ہے۔',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$total میں سے $saved کپڑے محفوظ کیے گئے۔ باقی کے لیے محفوظ بٹن دبائیں۔';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'کچھ کپڑے محفوظ نہیں ہوئے';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'کم از کم ایک تصویر منتخب کریں۔';

  @override
  String get batchPhotoUnreadableBody => 'یہ تصویر پڑھی نہیں جا سکی۔';

  @override
  String get batchNoPhotosReadableBody =>
      'ان میں سے کوئی تصویر پڑھی نہیں جا سکی۔ دوسری تصویروں کی کوشش کریں۔';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصاویر',
      one: '1 تصویر',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'کام کرتے ہوئے کنکشن کٹ گیا۔ دوبارہ کوشش کریں۔';

  @override
  String get batchNotCancelledTitle => 'منسوخ نہیں کیا گیا';

  @override
  String get batchPostLinkUnsupportedBody =>
      'پوسٹ لنکس کے قابلِ قبول نہیں ہیں۔ پروفائل لنک درج کریں۔';

  @override
  String get batchLinkSpacesBody => 'لنک میں خالی جگہیں نہیں ہو سکتیں۔';

  @override
  String get batchEnterProfileLinkBody =>
      'انسٹاگرام یا فیس بک پروفائل لنک درج کریں۔';

  @override
  String get batchEnterProfileLinkShortBody => 'پروفائل لنک درج کریں۔';

  @override
  String get batchSignInPageNotOpenBody =>
      'سائن ان صفحہ کھلا نہیں۔ دوبارہ کوشش کریں۔';

  @override
  String get batchSignInBrowserBody =>
      'اپنے براؤزر میں سائن ان کریں، پھر FitCheck پر واپس آئیں۔';

  @override
  String get batchConnectAccountTitle => 'اپنا اکاؤنٹ کنیکٹ کریں';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'اپنے اُتھنٹکیٹر ایپ کا کوڈ درج کریں۔';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram سکیورٹی چیک چاہتا ہے۔ پہلے اپنے براؤزر میں سائن ان کریں۔';

  @override
  String get batchEnterCredentialsAgainBody =>
      'اپنا یوزر نیم اور پاس ورڈ دوبارہ درج کریں۔';

  @override
  String get batchSignInFailedBody =>
      'سائن ان ناکام ہوا۔ اپنا یوزر نیم اور پاس ورڈ چیک کریں۔';

  @override
  String get batchSignInToKeepImportingBody =>
      'امپورٹ جاری رکھنے کے لیے سائن ان کریں۔';

  @override
  String get batchAccountNotConnectedBody => 'آپکا اکاؤنٹ کنیکٹ نہیں ہوا۔';

  @override
  String get batchAccountConnectedTitle => 'اکاؤنٹ کنیکٹ ہو گیا';

  @override
  String get batchNotConnectedTitle => 'کنیکٹ نہیں ہوا';

  @override
  String get batchImportConnectionLostBody =>
      'امپورٹ سے کنکشن کمزور پڑ گیا۔ چیک کرنے کے لیے ریفریش کریں۔';

  @override
  String batchPickUpToBody(int max) {
    return '$max تصاویر منتخب کریں۔ ہم اجزا خود ڈھونڈیں گے۔';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$total میں سے $count تصاویر';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'تصویر $done / $count تیار ہو رہی ہے';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصاویر میں اجزا ڈھونڈیں',
      one: '1 تصویر میں اجزا ڈھونڈیں',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'آپکا $platform اکاؤنٹ دو قدمی سائن ان استعمال کرتا ہے۔ اپنے اُتھنٹکیٹر ایپ کا 6 عددی کوڈ درج کریں۔';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'یہ $platform پروفائل پرسیکشنل ہے یا تصاویر دکھانے کے لیے سائن ان درکار ہے۔';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform سے کنیکٹ کریں';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اب تک $count تصاویر ملی ہیں',
      one: 'اب تک 1 تصویر ملی ہے',
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
    return '$total میں سے $processed پروسیس ہوئیں · $added شامل · $waiting انتظار میں · $skipped چھوڑ دی گئی';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'تصویر $number اسکین ہو رہی ہے';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'تصویر $number اگلے نمبر میں ہے';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'تصویر $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اجزاء ملے',
      one: '1 جزو ملا',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تصاویر آپ کی کمرے میں شامل ہو گئیں۔',
      one: '1 تصویر آپ کی کمرے میں شامل ہو گئی۔',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count اسٹوڈو تصاویر آ رہی ہیں۔ آپ تیار شدہ مواد محفوظ کر سکتے ہیں یا چھوڑ جائیں — ہم آپ کو مطلع کریں گے۔',
      one:
          '1 اسٹوڈو تصویر آ رہی ہے۔ آپ تیار شدہ مواد محفوظ کر سکتے ہیں یا چھوڑ جائیں — ہم آپ کو مطلع کریں گے۔',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'ابھی محفوظ نہیں: $names۔';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos تصاویر',
      one: '1 تصویر',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces اجزاء',
      one: '1 جزو',
    );
    return '$_temp0 سے $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen منتخب۔ جزو کو چھوڑنے کے لیے پر تپ کریں۔';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اجزاء محفوظ ہو رہے ہیں',
      one: '1 جزو محفوظ ہو رہا ہے',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ٹکڑے محفوظ کریں',
      one: '1 ٹکڑا محفوظ کریں',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'آپ کا باڈی پروفائل محفوظ کر دیا گیا ہے۔';

  @override
  String get bodyProfileSavedTitle => 'محفوظ شدہ';

  @override
  String get bodyProfileNotSavedTitle => 'محفوظ نہیں ہو سکا';

  @override
  String get bodyProfileSetDefaultBody => 'اپنا ڈیفالٹ پروفائل مقرر کریں۔';

  @override
  String get bodyProfileDeletedBody => 'باڈی پروفائل حذف کر دیا گیا۔';

  @override
  String get bodyProfileDeletedTitle => 'حذف شدہ';

  @override
  String get bodyProfileNotDeletedTitle => 'حذف نہیں ہو سکا';

  @override
  String get feedbackNotSentTitle => 'موصول نہیں ہو سکا';

  @override
  String get feedbackSentBody =>
      'شکریہ۔ ہم ہر پیغام پڑھتے ہیں اور ضرورت پڑنے پر جواب دیتے ہیں۔';

  @override
  String get feedbackSentTitle => 'فیڈبیک موصول ہو گیا';

  @override
  String get recommendUnnamedPiece => 'غیر نامزد ٹکڑا';

  @override
  String get recommendEnterCityBody =>
      'موسم کی بنیاد پر تجاویز کے لیے اپنا شہر درج کریں۔';

  @override
  String get recommendWhichCityTitle => 'کون سا شہر؟';

  @override
  String get aiConsentSheetTitle => 'ای آئی سروس کے ساتھ تصاویر کا اشتراک';

  @override
  String get aiConsentSheetBody =>
      'آپ کے ٹرائی اوَن اور فوٹو شوٹ تصاویر بنانے کے لیے، FitCheck AI آپ کی فراہم کردہ تصاویر (جواپ کے چہرے اور جسم کی تصاویر شامل ہیں) کے سیف پروسیسرنگ کے لیے کسی معتبر تیسرے فریق ای آئی فراہم کنندہ (جیسے OpenAI یا Google Gemini) کو بھیجتا ہے۔ وہ آپ کی تصاویر جنریشن کرتے ہیں اور ہمارے شرائط کے تحت ان کا ماڈل ٹریننگ کے لیے استعمال نہیں کرتے۔ تصاویر محفوظ طریقے سے منتقل ہوتی ہیں اور اشتہارات کے لیے کبھی شراکت نہیں کی جاتی۔';

  @override
  String get aiConsentSheetPermission =>
      'آگے بڑھنے سے آپ ان ای آئی فراہم کنندوں کے ساتھ اپنے تصاویر کے اشتراک کے لیے واضح اجازت دیتے ہیں۔';

  @override
  String get skeletonsLoadMoreFailed => 'مزید لوڈ نہیں ہو سکا۔';

  @override
  String get jobsPiecesReadyTitle => 'آپ کے ٹکڑے تیار ہیں';

  @override
  String get jobsScanStoppedTitle => 'اسکن بند ہو گیا';

  @override
  String get jobsNothingSavedBody =>
      'کچھ بھی محفوظ نہیں ہوا۔ دوبارہ کوشش کریں۔';

  @override
  String get jobsPhotoUploadFailedBody => 'تصویر اپ لوڈ ناکام ہوئی۔';

  @override
  String get authGoogleSignInStartFailed =>
      'گوگل سائن ان شروع نہیں ہو سکا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get referralAppliedTitle => 'حوالہ لاگو!';

  @override
  String get billingStoreUnavailableBody =>
      'اس ڈیوائس پر اسٹور خریداری دستیاب نہیں ہے۔';

  @override
  String get billingPurchaseProcessingBody =>
      'یہ خریداری ابھی پروسیس ہو رہی ہے۔ اپنا پلان دیکھنے کے لیے ایک منٹ بعد ایپ دوبارہ کھولیں۔';

  @override
  String get profileAvatarUploadNoUrl =>
      'اویٹر اپ لوڈ نے تصویر یو آر ایل واپس نہیں کیا۔';

  @override
  String get rewardsDayStreakLabel => 'دن کا سلسلہ';

  @override
  String rewardsBestStreak(int days) {
    return 'بہترین $days دن';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission رسائی درکار';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission تک رسائی فی الحال رد کر دی گئی ہے۔ اس کی اجازت دینے کے لیے ترتیبات کھولیں، پھر واپس آ کر دوبارہ کوشش کریں۔';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '4 میں سے قدم $step';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '$total میں سے قدم $step';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'تصویر $index حذف کریں';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'تصویر $index حذف کریں';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points پوائنٹس';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'ای میل $email بھیجیں۔ ہم رپورٹس کا جائزہ 24 گھنٹوں کے اندر لیتے ہیں۔';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece حذف کریں';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'کیا \"$name\" کو حذف کیا جائے؟';
  }

  @override
  String outfitAddToNamed(String name) {
    return '\"$name\" میں شامل کریں';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" حذف کر دیا گیا۔ اس کے اجزا آپ کے کمرے میں موجود رہیں گے۔';
  }

  @override
  String outfitShowAllCount(int count) {
    return '$count میں سے سب دیکھیں';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'آج $count باقی ہیں';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'تصویر $index ناکام';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max میں سے $selected تصاویر';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape بلڈ · $tone جلد';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'کیا $name کو حذف کیا جائے؟';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name کے اختیارات';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'سب سے زیادہ پہننے والا: $name، $count بار';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: مقرر نہیں';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% میچ';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max میں سے $picked منتخب';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item حذف کریں';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency ترجیح';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'یہ پلان $store کے ذریعے بل کیا جاتا ہے۔ اس کی تبدیلی یا منسوخی اپنے $store اکاؤنٹ ترتیبات میں کریں۔';
  }

  @override
  String billingManageInStore(String store) {
    return '$store میں مینیج کریں';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max میں سے $current استعمال ہوئے';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'تقریباً $seconds سیکنڈ باقی';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total میں سے $done اسٹوڈو تصاویر تیار';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total میں سے $ready اسٹوڈو تصاویر تیار۔ اس کو چھوٹے کرنے کے لیے ایک جزو پر ٹیپ کریں۔';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height سینٹی میٹر · $weight کلوگرام';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'نہیں';
}
