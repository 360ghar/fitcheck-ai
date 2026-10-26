// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabPhotoshoot => 'تصوير';

  @override
  String get tabCloset => 'خزانتي';

  @override
  String get tabOutfits => 'أطقمي';

  @override
  String get tabMore => 'المزيد';

  @override
  String get actionAddItem => 'إضافة قطعة';

  @override
  String get actionCreateOutfit => 'إنشاء طقم';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionDone => 'تم';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionContinue => 'متابعة';

  @override
  String get stateLoading => 'جاري التحميل';

  @override
  String get stateErrorTitle => 'حدث خطأ ما';

  @override
  String get stateErrorBody =>
      'حاول مجدداً. إذا استمرت المشكلة، تواصل مع الدعم.';

  @override
  String get stateOfflineTitle => 'أنت غير متصل';

  @override
  String get stateOfflineBody => 'اتصل بالإنترنت لمزامنة خزانتك وإنشاء الأطقم.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAccountSection => 'الحساب';

  @override
  String get settingsPreferencesSection => 'التفضيلات';

  @override
  String get settingsPlanBilling => 'الخطة والفواتير';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsUnits => 'وحدات القياس';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsPrivacySection => 'الخصوصية والبيانات';

  @override
  String get settingsAboutSection => 'حول التطبيق';

  @override
  String get settingsSignOut => 'تسجيل الخروج';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

  @override
  String get settingsDeleteAccountTitle => 'هل تريد حذف حسابك؟';

  @override
  String get settingsDeleteAccountBody =>
      'سيؤدي هذا إلى إزالة خزانة ملابسك، وأطقمك، وصورك، وملفك الشخصي. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get settingsUnitsImperial => 'نظام إمبراطوري (بوصة، رطل)';

  @override
  String get settingsUnitsMetric => 'نظام متري (سم، كجم)';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageSystem => 'استخدام لغة الجهاز';

  @override
  String get languageSystemBody => 'يتبع FitCheck AI لغة هاتفك.';

  @override
  String get languageSearchHint => 'البحث عن لغات';

  @override
  String get languageCurrent => 'الحالية';

  @override
  String get languageReviewNote =>
      'هذه الترجمة جديدة. أخبرنا إذا كان هناك ما يبدو غير صحيح.';

  @override
  String get languageChanged => 'تم تحديث اللغة';

  @override
  String get paywallTitle => 'اختر خطتك';

  @override
  String get paywallTrialBadge => 'شهر مجاني';

  @override
  String get paywallTrialTitle => 'أول شهر لك في Pro مجاني';

  @override
  String get paywallTrialBody =>
      'ارفع خزانة ملابسك بالكامل دفعة واحدة. أضف القطع لاحقاً كما تشاء.';

  @override
  String get paywallFreeForeverTitle => 'مجاني للأبد';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'لا حاجة لبطاقة. تحصل كل شهر على $uploads رفع بالذكاء الاصطناعي، و$outfits أطقم، و$images صور جلسة تصوير يومياً.';
  }

  @override
  String get paywallCtaTrial => 'ابدأ شهري المجاني';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'الترقية إلى $plan';
  }

  @override
  String get paywallRestore => 'استعادة المشتريات';

  @override
  String get paywallManage => 'إدارة الاشتراك';

  @override
  String get paywallTerms => 'شروط الاستخدام';

  @override
  String get paywallPrivacy => 'سياسة الخصوصية';

  @override
  String get paywallPerMonth => 'شهرياً';

  @override
  String get paywallPerYear => 'سنوياً';

  @override
  String get paywallBestValue => 'القيمة الأفضل';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'تجربة مجانية للمشتركين الجدد فقط. بعد التجربة، يتجدد اشتراك Pro بسعر $price ما لم يتم الإلغاء قبل 24 ساعة على الأقل من نهايته.';
  }

  @override
  String get introTitle => 'خزانتك، منظمة أخيراً';

  @override
  String get introBody =>
      'صوّر ملابسك مرة واحدة. احصل على أفكار للأطقم، ومعاينات للقياس، وصور احترافية مما تملكه بالفعل.';

  @override
  String get introStart => 'ابدأ الآن';

  @override
  String get introHaveAccount => 'لدي حساب بالفعل';

  @override
  String get introSkip => 'تخطي';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authContinueApple => 'المتابعة باستخدام Apple';

  @override
  String get authContinueGoogle => 'المتابعة باستخدام Google';

  @override
  String get authOrDivider => 'أو';

  @override
  String get wardrobeTitle => 'الخزانة';

  @override
  String get wardrobeEmptyTitle => 'خزانتك فارغة';

  @override
  String get wardrobeEmptyBody =>
      'أضف قطعتك الأولى، أو ارفع صورة لمجموعة ملابسك دفعة واحدة.';

  @override
  String get wardrobeAddFirst => 'أضف قطعتك الأولى';

  @override
  String get wardrobeSearchHint => 'ابحث في خزانتك';

  @override
  String get categoryTops => 'القمصان والبلوزات';

  @override
  String get categoryBottoms => 'البناطيل والتنانير';

  @override
  String get categoryShoes => 'الأحذية';

  @override
  String get categoryAccessories => 'الإكسسوارات';

  @override
  String get categoryOuterwear => 'الملابس الخارجية';

  @override
  String get categorySwimwear => 'ملابس السباحة';

  @override
  String get categoryActivewear => 'الملابس الرياضية';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get conditionClean => 'نظيفة';

  @override
  String get conditionDirty => 'متسخة';

  @override
  String get conditionLaundry => 'في الغسيل';

  @override
  String get conditionRepair => 'يحتاج إصلاح';

  @override
  String get conditionDonate => 'للتبرع';

  @override
  String get seasonSpring => 'الربيع';

  @override
  String get seasonSummer => 'الصيف';

  @override
  String get seasonFall => 'الخريف';

  @override
  String get seasonWinter => 'الشتاء';

  @override
  String get seasonAll => 'كل المواسم';

  @override
  String get styleCasual => 'كاجوال';

  @override
  String get styleFormal => 'رسمي';

  @override
  String get styleBusiness => 'عملي';

  @override
  String get styleSporty => 'رياضي';

  @override
  String get styleBohemian => 'بوهيمي';

  @override
  String get styleStreetwear => 'ستريت وير';

  @override
  String get styleVintage => 'كلاسيكي قديم';

  @override
  String get styleMinimalist => 'بسيط';

  @override
  String get styleRomantic => 'رومانسي';

  @override
  String get styleEdgy => 'جريء';

  @override
  String get stylePreppy => 'بريبي';

  @override
  String get styleArtsy => 'فني';

  @override
  String get styleClassic => 'كلاسيكي';

  @override
  String get styleElegant => 'أنيق';

  @override
  String get styleOther => 'أخرى';

  @override
  String get occasionWork => 'عمل';

  @override
  String get occasionDateNight => 'موعد غرامي';

  @override
  String get occasionTravel => 'سفر';

  @override
  String get occasionWedding => 'زفاف';

  @override
  String get occasionGym => 'نادي رياضي';

  @override
  String get occasionWeekend => 'عطلة نهاية الأسبوع';

  @override
  String get occasionParty => 'حفلة';

  @override
  String get occasionInterview => 'مقابلة عمل';

  @override
  String get colorBlack => 'أسود';

  @override
  String get colorWhite => 'أبيض';

  @override
  String get colorGrey => 'رمادي';

  @override
  String get colorNavy => 'كحلي';

  @override
  String get colorBrown => 'بني';

  @override
  String get colorRed => 'أحمر';

  @override
  String get colorBlue => 'أزرق';

  @override
  String get colorGreen => 'أخضر';

  @override
  String get colorPink => 'وردي';

  @override
  String get colorPurple => 'بنفسجي';

  @override
  String get colorYellow => 'أصفر';

  @override
  String get colorOrange => 'برتقالي';

  @override
  String get colorBeige => 'بيج';

  @override
  String get dateToday => 'اليوم';

  @override
  String get dateYesterday => 'أمس';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count أيام',
      one: 'قبل يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count أسابيع',
      one: 'قبل أسبوع واحد',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count أشهر',
      one: 'قبل شهر واحد',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $count سنوات',
      one: 'قبل سنة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'هل تستمتع بـ FitCheck AI؟';

  @override
  String get ratingPromptBody =>
      'تقييمك السريع يساعد الآخرين في العثور على أسلوبهم.';

  @override
  String get ratingPromptYes => 'قيّم التطبيق';

  @override
  String get ratingPromptNo => 'ليس الآن';

  @override
  String get closetNoMatchesTitle => 'لا توجد قطع مطابقة';

  @override
  String get closetNoMatchesBody => 'جرب تقليل الفلاتر أو بحث آخر.';

  @override
  String get closetClearFilters => 'مسح الفلاتر';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطع',
      one: 'قطعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'جاري تحميل قطعك';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اختيار $count قطع',
      one: 'تم اختيار قطعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'حذف المحدد';

  @override
  String get closetCancelSelection => 'إلغاء التحديد';

  @override
  String get closetCloseSearch => 'إغلاق البحث';

  @override
  String get closetShowGrid => 'عرض كشبكة';

  @override
  String get closetShowList => 'عرض كقائمة';

  @override
  String get closetShowRows => 'عرض كصفوف';

  @override
  String get closetStatsTitle => 'إحصائيات الخزانة';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حذف $count قطع؟',
      one: 'حذف قطعة واحدة؟',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'ستفقد الأطقم التي تستخدم هذه القطع.';

  @override
  String get closetSortBy => 'ترتيب حسب';

  @override
  String get closetFavourites => 'المفضلة';

  @override
  String get closetFavourite => 'إضافة للمفضلة';

  @override
  String get closetUnfavourite => 'إزالة من المفضلة';

  @override
  String get closetWoreToday => 'ارتديتها اليوم';

  @override
  String closetWornTimes(int count) {
    return 'ارتديتها $count×';
  }

  @override
  String get closetCategoryLabel => 'الفئة';

  @override
  String get closetUseCaseLabel => 'المناسبة';

  @override
  String get closetAnyUseCase => 'أي مناسبة';

  @override
  String get closetOtherUseCase => 'مناسبة أخرى';

  @override
  String get closetOtherUseCaseHint => 'مثلاً: غداء';

  @override
  String get closetUseUseCase => 'استخدام';

  @override
  String get closetClearAll => 'مسح الكل';

  @override
  String get sortNewest => 'الأحدث أولاً';

  @override
  String get sortOldest => 'الأقدم أولاً';

  @override
  String get sortName => 'الاسم (أ-ي)';

  @override
  String get sortMostWorn => 'الأكثر ارتداءً';

  @override
  String get useCaseInformal => 'غير رسمي';

  @override
  String get useCaseDate => 'موعد';

  @override
  String get useCaseDinner => 'عشاء';

  @override
  String get useCaseLunch => 'غداء';

  @override
  String get actionSelect => 'اختيار';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionFilter => 'تصفية';

  @override
  String get actionSort => 'فرز';

  @override
  String get actionAll => 'الكل';

  @override
  String get dashboardStartClosetTitle => 'ابدأ خزانة ملابسك';

  @override
  String get dashboardStartClosetBody => 'صور بعض القطع وسنقوم بتصنيفها لك.';

  @override
  String get dashboardPieces => 'قطعة';

  @override
  String get dashboardOutfits => 'أطقم';

  @override
  String get dashboardDayStreak => 'يوم متتالي';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count هذا الشهر';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'أفضل $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مفضلة',
      one: 'مفضلة واحدة',
      zero: 'لا توجد مفضلة',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طقم محفوظ',
      one: 'طقم واحد محفوظ',
      zero: 'لا توجد أطقم محفوظة',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'الأكثر ارتداءً: $name، $count مرات';
  }

  @override
  String get setupSkip => 'تخطي الإعداد';

  @override
  String get setupWhoTitle => 'من ننسق له؟';

  @override
  String get setupWhoBody =>
      'يحدد النموذج لتجربة الملابس. يمكنك تغييره في ملفك الشخصي.';

  @override
  String get setupStyleTitle => 'ماذا ترتدي غالباً؟';

  @override
  String get setupStyleBody => 'اختر ما تشاء. سنقترح أطقم بناءً على اختياراتك.';

  @override
  String get setupClosetTitle => 'أضف قطعك الأولى.';

  @override
  String get setupClosetBody =>
      'صور بعض الملابس أو كومة منها. سنقوم بقص كل قطعة وتصنيفها لك.';

  @override
  String get setupAddClothes => 'إضافة ملابس';

  @override
  String get setupStylesLabel => 'الأنماط';

  @override
  String get setupOccasionsLabel => 'المناسبات';

  @override
  String get setupSkipStep => 'تخطي';

  @override
  String get setupLater => 'لاحقاً';

  @override
  String get setupSaveError => 'تعذر الحفظ';

  @override
  String get genderWomen => 'نساء';

  @override
  String get genderMen => 'رجال';

  @override
  String get genderNonBinary => 'غير ثنائي';

  @override
  String get genderPreferNotToSay => 'أفضل عدم الإجابة';

  @override
  String get outfitEmptyTitle => 'لا توجد أطقم بعد';

  @override
  String get outfitEmptyBody => 'نسّق قطع ملابسك واحفظ الإطلالة.';

  @override
  String get outfitNoMatchesTitle => 'لا توجد أطقم مطابقة';

  @override
  String get outfitSearchHint => 'ابحث في أطقمك';

  @override
  String get outfitLoading => 'جاري تحميل الأطقم';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طقم',
      many: '$count طقماً',
      few: '$count أطقم',
      two: 'طقمان',
      one: 'طقم واحد',
      zero: 'لا توجد أطقم',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'النمط والموسم';

  @override
  String get outfitCollections => 'المجموعات';

  @override
  String get outfitDuplicate => 'تكرار';

  @override
  String get outfitDeleteTitle => 'حذف هذا الطقم؟';

  @override
  String get outfitDeleteBody => 'ستبقى القطع في خزانتك.';

  @override
  String get outfitDrafts => 'المسودات';

  @override
  String get outfitDraft => 'مسودة';

  @override
  String get filterStyle => 'النمط';

  @override
  String get filterSeason => 'الموسم';

  @override
  String get itemDetailDeleteTitle => 'حذف هذه القطعة؟';

  @override
  String get itemDetailDeleteBody => 'ستفقد الأطقم التي تستخدمها هذه القطعة.';

  @override
  String get itemAddFavourite => 'إضافة للمفضلة';

  @override
  String itemSize(String size) {
    return 'المقاس $size';
  }

  @override
  String get itemColours => 'الألوان';

  @override
  String get itemMaterial => 'الخامة';

  @override
  String get itemPattern => 'النقشة';

  @override
  String get itemUseCases => 'الاستخدامات';

  @override
  String get itemKeptIn => 'محفوظة في';

  @override
  String get itemPrice => 'السعر';

  @override
  String get itemBought => 'تاريخ الشراء';

  @override
  String get itemTags => 'الوسوم';

  @override
  String get itemAdded => 'تاريخ الإضافة';

  @override
  String get itemTimesWornLabel => 'مرات الارتداء';

  @override
  String get itemLastWornLabel => 'آخر ارتداء';

  @override
  String get itemNeverWorn => 'لم يُرتدَ';

  @override
  String get authEntryBody =>
      'كل قطعة تملكها، بتنسيق ذكاء اصطناعي. خطط لأزيائك، جربها، والتقط صوراً لها.';

  @override
  String get authCreateCloset => 'أنشئ خزانتك';

  @override
  String get authWelcomeBack => 'أهلاً بعودتك';

  @override
  String get authSignInBody => 'سجل الدخول لفتح خزانتك.';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authCreateClosetBody => 'يستغرق الأمر دقيقة. أول قطعك مجانية.';

  @override
  String get authName => 'الاسم';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authReferralCode => 'رمز الإحالة (اختياري)';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetBody =>
      'سنرسل لك رابطاً عبر البريد الإلكتروني لاختيار كلمة مرور جديدة.';

  @override
  String get authSendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get authBackToSignIn => 'العودة لتسجيل الدخول';

  @override
  String get authEnterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get authEnterValidEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get authEnterPassword => 'أدخل كلمة المرور';

  @override
  String get authPasswordTooShort => '6 أحرف على الأقل';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authNewHere => 'جديد هنا؟';

  @override
  String authConfirmEmail(String email) {
    return 'أكد $email قبل تسجيل الدخول. تحقق من بريدك الوارد.';
  }

  @override
  String get authResendEmail => 'إرسال مرة أخرى';

  @override
  String get authResendingEmail => 'جاري الإرسال...';

  @override
  String get authPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authEnterName => 'أدخل اسمك';

  @override
  String get authChoosePassword => 'اختر كلمة مرور';

  @override
  String get authHaveAccount => 'لديك حساب؟';

  @override
  String get authCodeAccepted => 'تم قبول الرمز';

  @override
  String get authCodeNotFound => 'الرمز غير موجود';

  @override
  String authReferralFrom(String name) {
    return 'من $name. ستحصلان على شهر مجاني.';
  }

  @override
  String get authReferralInvalid => 'لم نتمكن من العثور على هذا الرمز.';

  @override
  String authResetSent(String email) {
    return 'تم الإرسال إلى $email. افتح الرابط على هذا الهاتف.';
  }

  @override
  String get introSlide1Title => 'صوّر خزانتك مرة واحدة';

  @override
  String get introSlide1Body =>
      'صوّر كومة ملابسك. سيتم قص كل قطعة وتصنيفها لك.';

  @override
  String get introSlide2Title => 'ارتدِ ملابسك بشكل أسرع';

  @override
  String get introSlide2Body =>
      'تنسيقات من ملابسك، متوافقة مع خططك وحالة الطقس.';

  @override
  String get introSlide3Title => 'جربها قبل ارتدائها';

  @override
  String get introSlide3Body =>
      'جرب الإطلالات على صورتك، أو صوّرها كجلسة تصوير احترافية.';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsThemeLight => 'فاتحة';

  @override
  String get settingsThemeDark => 'داكنة';

  @override
  String get settingsTemperature => 'درجة الحرارة';

  @override
  String get settingsEmailUpdates => 'تحديثات البريد الإلكتروني';

  @override
  String get settingsEmailUpdatesBody => 'أخبار ونصائح عبر البريد';

  @override
  String get settingsOutfitReminders => 'تذكيرات التنسيقات';

  @override
  String get settingsOutfitRemindersBody => 'تنبيه لتسجيل ما ارتديته';

  @override
  String get settingsWeeklySummary => 'الملخص الأسبوعي';

  @override
  String get settingsWeeklySummaryBody => 'أسبوعك في تنسيقات';

  @override
  String get settingsStyleSection => 'النمط';

  @override
  String get settingsPreferredStyles => 'الأنماط المفضلة';

  @override
  String get settingsPreferredColours => 'الألوان المفضلة';

  @override
  String get settingsNoneChosen => 'لم يتم الاختيار';

  @override
  String get settingsPlanAiSection => 'الخطة والذكاء الاصطناعي';

  @override
  String get settingsPlanBillingBody => 'الخطة، الاستخدام، والترقيات';

  @override
  String get settingsPlanUsageBody => 'الخطة والاستخدام';

  @override
  String get settingsInviteFriends => 'دعوة الأصدقاء';

  @override
  String get settingsInviteFriendsBody => 'شهر مجاني لكل صديق ينضم';

  @override
  String get settingsAiProvider => 'مزود الذكاء الاصطناعي';

  @override
  String get settingsAiProviderBody => 'استخدم نموذجك الخاص للوسوم والصور';

  @override
  String get settingsAppVersion => 'إصدار التطبيق';

  @override
  String get settingsPrivacyTerms => 'الخصوصية والشروط';

  @override
  String get settingsReportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsExportData => 'تصدير بياناتك';

  @override
  String get settingsExportBody =>
      'سنقوم بإعداد ملف بكل ما قمت بحفظه وفتح رابط التحميل.';

  @override
  String get settingsExportAction => 'تصدير';

  @override
  String get settingsCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get settingsNewPassword => 'كلمة المرور الجديدة';

  @override
  String get settingsConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get settingsEnterCurrentPassword => 'أدخل كلمة المرور الحالية';

  @override
  String get settingsEnterNewPassword => 'أدخل كلمة مرور جديدة';

  @override
  String get settingsPasswordMin8 => 'استخدم 8 أحرف على الأقل';

  @override
  String get settingsPasswordNeedsUpper => 'أضف حرفاً كبيراً';

  @override
  String get settingsPasswordNeedsLower => 'أضف حرفاً صغيراً';

  @override
  String get settingsPasswordNeedsDigit => 'أضف رقماً';

  @override
  String get settingsPasswordsNoMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get settingsChangeAction => 'تغيير';

  @override
  String get itemAddSnapTitle => 'صور قطعة ملابس';

  @override
  String get itemAddSnapBody =>
      'سنحدد كل قطعة في الصورة وننشئ لها لقطة استوديو نظيفة.';

  @override
  String get itemAddCamera => 'التقاط صورة';

  @override
  String get itemAddGallery => 'اختر من المعرض';

  @override
  String get itemAddOtherWays => 'طرق أخرى للإضافة';

  @override
  String get itemAddSeveral => 'إضافة عدة صور';

  @override
  String get itemAddSeveralBody => 'حتى 50 صورة دفعة واحدة';

  @override
  String get itemAddImportProfile => 'استيراد من ملف شخصي';

  @override
  String get itemAddImportProfileBody => 'إنستغرام أو فيسبوك';

  @override
  String get itemAddEnterDetails => 'أدخل التفاصيل يدوياً';

  @override
  String get itemAddEnterDetailsBody => 'لا حاجة لصورة';

  @override
  String get itemManualIntro =>
      'يكفي إدخال الاسم فقط. يمكنك إضافة الباقي الآن أو لاحقاً.';

  @override
  String get itemManualNameHint => 'مثال: قميص قطني أزرق';

  @override
  String get itemManualEnterName => 'أدخل الاسم';

  @override
  String get itemManualNotes => 'ملاحظات';

  @override
  String get itemManualBrand => 'العلامة التجارية';

  @override
  String get itemManualSize => 'المقاس';

  @override
  String get itemManualEnterNumber => 'أدخل رقماً';

  @override
  String get itemManualSavePiece => 'حفظ القطعة';

  @override
  String get itemManualSaving => 'جاري الحفظ';

  @override
  String get itemManualSavedTitle => 'تم الحفظ';

  @override
  String itemManualSavedBody(String name) {
    return 'تمت إضافة $name إلى خزانتك.';
  }

  @override
  String get itemManualNotSaved => 'لم يتم الحفظ';

  @override
  String get itemManualAddUseCase => 'إضافة حالة استخدام';

  @override
  String get itemManualAddUseCaseAction => 'إضافة حالة استخدام';

  @override
  String get itemPhotos => 'الصور';

  @override
  String get itemAddPhotos => 'إضافة صور';

  @override
  String get itemNoPhotoYet => 'لا توجد صورة بعد. يمكنك الحفظ بدونها.';

  @override
  String get itemRemovePhoto => 'إزالة الصورة';

  @override
  String get itemRemovePiece => 'إزالة القطعة';

  @override
  String get filterConditionLabel => 'الحالة';

  @override
  String get photoshootStepPhotos => 'الصور';

  @override
  String get photoshootStepSetup => 'الإعداد';

  @override
  String get photoshootStepCreating => 'جاري الإنشاء';

  @override
  String get photoshootStepResults => 'النتائج';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'الخطوة $current من $total، $name';
  }

  @override
  String get photoshootOneFailed => 'فشلت صورة واحدة. أعد المحاولة أدناه.';

  @override
  String photoshootManyFailed(int count) {
    return 'فشلت $count صور. أعد المحاولة لكل منها أدناه.';
  }

  @override
  String get photoshootFormat => 'التنسيق';

  @override
  String get photoshootHowMany => 'العدد';

  @override
  String get photoshootYourPrompt => 'وصفك';

  @override
  String get photoshootPromptHint => 'ساعة الغروب على سطح مبنى، قميص كتان';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إنشاء $count صور',
      one: 'إنشاء صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'صور',
      one: 'صورة',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'تعذر التحقق من حد اليوم.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'باقة $plan: تبقى $remaining من $limit اليوم';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'مجانية';

  @override
  String get photoshootGallery => 'المعرض';

  @override
  String get photoshootUseCamera => 'استخدام الكاميرا';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'إزالة الصورة $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'لم يتم العثور على صور';

  @override
  String get photoshootNoPhotosBody => 'انتهت الجلسة بدون صور. حاول مجدداً.';

  @override
  String get photoshootNewStyle => 'نمط جديد';

  @override
  String get photoshootNewPhotos => 'صور جديدة';

  @override
  String photoshootOpenPhoto(int number) {
    return 'فتح الصورة $number';
  }

  @override
  String get photoshootReportPhoto => 'الإبلاغ عن صورة';

  @override
  String get photoshootSaveToGallery => 'حفظ في المعرض';

  @override
  String get actionUpgrade => 'ترقية';

  @override
  String get referralLimitTitle => 'استنفدت صور اليوم';

  @override
  String get referralLimitBody =>
      'تتجدد صورك المجانية غداً. ادعُ صديقاً واحصل أنت وهو على شهر Pro مجاناً.';

  @override
  String get referralLimitRefer => 'دعوة صديق';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'تطبيقات المواعدة';

  @override
  String get photoshootUsePortfolio => 'ملف أعمال';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'جمالي';

  @override
  String get photoshootUseCustom => 'وصف خاص';

  @override
  String get photoshootDescLinkedin => 'صور احترافية للعمل';

  @override
  String get photoshootDescDating => 'مريحة، دافئة وطبيعية';

  @override
  String get photoshootDescPortfolio => 'تحريرية، إطلالات عصرية';

  @override
  String get photoshootDescInstagram => 'لقطات عفوية لحسابك';

  @override
  String get photoshootDescAesthetic => 'إطارات فنية غامضة';

  @override
  String get photoshootDescCustom => 'صف المظهر الذي تريده';

  @override
  String get aspectSquare => 'مربع';

  @override
  String get aspectPortrait => 'طولي';

  @override
  String get aspectLandscape => 'عرضي';

  @override
  String get aspectTall => 'طويل';

  @override
  String get aspectWide => 'عريض';

  @override
  String get tryOnAppBar => 'قياس افتراضي';

  @override
  String get tryOnYourPhoto => 'صورتك';

  @override
  String get tryOnGarment => 'قطعة الملابس';

  @override
  String get tryOnUploadingPhoto => 'جاري رفع صورتك';

  @override
  String get tryOnAddPhotoPrompt => 'أضف صورة كاملة للجسم';

  @override
  String get tryOnBodyPhotoHint => 'صورة كاملة للجسم تعطي أفضل نتيجة';

  @override
  String get tryOnAddPhoto => 'إضافة صورة';

  @override
  String get tryOnChangePhoto => 'تغيير الصورة';

  @override
  String get tryOnPhotoLoadFailed => 'تعذر تحميل صورتك.';

  @override
  String get tryOnChooseGarment => 'اختر صورة قطعة الملابس';

  @override
  String get tryOnChooseOneGarment => 'اختر صورة واحدة للملابس';

  @override
  String get tryOnGarmentHint => 'صورة مسطحة أو على علاقة تعطي أفضل نتيجة';

  @override
  String get tryOnChange => 'تغيير';

  @override
  String get tryOnCamera => 'الكاميرا';

  @override
  String get tryOnRemove => 'إزالة';

  @override
  String get tryOnLookTitle => 'المظهر';

  @override
  String get tryOnStyle => 'النمط';

  @override
  String get tryOnBackground => 'الخلفية';

  @override
  String get tryOnPose => 'الوضعية';

  @override
  String get tryOnDressingUp =>
      'جاري تنسيق ملابسك. يستغرق هذا حوالي نصف دقيقة.';

  @override
  String get tryOnEmptyResult => 'ستظهر تجاربك هنا';

  @override
  String get tryOnReportImage => 'الإبلاغ عن الصورة';

  @override
  String get tryOnCreating => 'جاري الإنشاء';

  @override
  String get tryOnTryAgain => 'حاول مجدداً';

  @override
  String get tryOnCreate => 'إنشاء تجربة';

  @override
  String get tryOnBackgroundStudioWhite => 'استوديو أبيض';

  @override
  String get tryOnBackgroundStudioGrey => 'استوديو رمادي';

  @override
  String get tryOnBackgroundUrban => 'شارع حضري';

  @override
  String get tryOnBackgroundNature => 'طبيعة';

  @override
  String get tryOnBackgroundMinimal => 'بسيط';

  @override
  String get tryOnPoseFront => 'وقوف أمامي';

  @override
  String get tryOnPoseSide => 'وقوف جانبي';

  @override
  String get tryOnPoseWalking => 'المشي';

  @override
  String get dashboardGreetingMorning => 'صباح الخير';

  @override
  String get dashboardGreetingAfternoon => 'مساء الخير';

  @override
  String get dashboardGreetingEvening => 'مساء الخير';

  @override
  String get dashboardWelcome => 'أهلاً بك';

  @override
  String get dashboardOpenProfile => 'فتح الملف الشخصي';

  @override
  String get dashboardRailToday => 'اليوم';

  @override
  String get dashboardRailRecently => 'مؤخراً';

  @override
  String get dashboardActivityEmpty => 'ستظهر القطع والأطقم الجديدة هنا.';

  @override
  String get quickAddPiece => 'إضافة قطعة';

  @override
  String get quickAddPieceBody => 'صورها وصنفها';

  @override
  String get quickBuildOutfit => 'تنسيق طقم';

  @override
  String get quickBuildOutfitBody => 'امزج قطعك';

  @override
  String get quickForYou => 'لك';

  @override
  String get quickForYouBody => 'اختيارات اليوم';

  @override
  String get quickPlanWeek => 'تخطيط الأسبوع';

  @override
  String get quickPlanWeekBody => 'أطقم حسب التاريخ';

  @override
  String get referralBannerUrgent => 'هل نفذ رصيدك؟ ادعُ صديقاً.';

  @override
  String get referralBannerTitle => 'أهدِ شهراً، واحصل على شهر.';

  @override
  String get referralBannerBody => 'ستحصل أنت وصديقك على شهر مجاني في Pro.';

  @override
  String get referralBannerDismiss => 'تجاهل لمدة أسبوع';

  @override
  String get referralBannerShare => 'مشاركة الدعوة';

  @override
  String get referralBannerCopy => 'نسخ الرابط';

  @override
  String get itemEditPieceTitle => 'تعديل القطعة';

  @override
  String get itemEditDescriptionLabel => 'الوصف';

  @override
  String get itemEditNotSaved => 'لم يتم الحفظ';

  @override
  String get itemEditSavedTitle => 'تم الحفظ';

  @override
  String get itemEditSavedBody => 'تم حفظ تغييراتك.';

  @override
  String get itemEditSavedStalePhotos => 'تم الحفظ — قد تكون الصور قديمة';

  @override
  String get itemEditRemovePieceHint => 'احذف هذه القطعة من صفحة العناصر.';

  @override
  String get itemEditNoPhotos =>
      'لا توجد صور بعد. أضف واحدة من معرض الصور أو الكاميرا.';

  @override
  String get itemEditKeepPhoto => 'احتفظ بالصورة';

  @override
  String get itemEditRemoved => 'تمت الإزالة';

  @override
  String get itemEditAddUseCaseAction => 'إضافة';

  @override
  String get statsNoStatsTitle => 'لا توجد إحصائيات بعد';

  @override
  String get statsNoStatsBody => 'أضف بعض القطع وستظهر تشكيلة خزانتك هنا.';

  @override
  String get statsByCategory => 'حسب الفئة';

  @override
  String get statsTotalValue => 'القيمة الإجمالية';

  @override
  String get statsMostWorn => 'الأكثر ارتداءً';

  @override
  String get statsLeastWorn => 'بانتظار دورها';

  @override
  String get statsUnnamedPiece => 'قطعة غير مسماة';

  @override
  String get jobsTitle => 'عمليات المسح';

  @override
  String get jobsEmptyTitle => 'لا توجد عمليات مسح بعد';

  @override
  String get jobsEmptyBody => 'صور قطعة وأرسلها للخلفية — ستستمر في العمل هنا.';

  @override
  String get jobsNotCancelled => 'لم يتم الإلغاء';

  @override
  String get jobsResume => 'استئناف';

  @override
  String get jobsReview => 'مراجعة';

  @override
  String get jobsStop => 'إيقاف';

  @override
  String get jobsDismiss => 'إلغاء';

  @override
  String get reportTitle => 'إبلاغ عن محتوى';

  @override
  String reportIntro(String contentType) {
    return 'أخبرنا ما الخطأ في $contentType. فريقنا يراجع كل البلاغات.';
  }

  @override
  String get reportReasonInappropriate => 'غير لائق أو مسيء';

  @override
  String get reportReasonNudity => 'عري أو محتوى جنسي';

  @override
  String get reportReasonHarassment => 'مضايقة أو إساءة';

  @override
  String get reportReasonImpersonation => 'انتحال شخصية';

  @override
  String get reportReasonOther => 'أخرى';

  @override
  String get reportDetailsLabel => 'تفاصيل إضافية (اختياري)';

  @override
  String get reportSubmit => 'إرسال البلاغ';

  @override
  String get reportSubmittedTitle => 'تم إرسال البلاغ';

  @override
  String get reportSubmittedBody =>
      'شكراً لك. سيقوم فريقنا بمراجعة هذا المحتوى.';

  @override
  String get reportFailedTitle => 'تعذر إرسال البلاغ';

  @override
  String get reportFailedBody => 'يرجى المحاولة مرة أخرى.';

  @override
  String get reportContentTryOnImage => 'صورة تجربة الملابس بالذكاء الاصطناعي';

  @override
  String get reportContentSharedOutfit => 'زي مشترك';

  @override
  String get reportContentPhotoshootImage =>
      'صورة جلسة تصوير بالذكاء الاصطناعي';

  @override
  String get sharedOutfitTitle => 'زي مشترك';

  @override
  String get sharedOutfitHideTooltip => 'إخفاء هذا الزي';

  @override
  String get sharedOutfitReportTooltip => 'الإبلاغ عن هذا الزي';

  @override
  String get sharedOutfitHideTitle => 'إخفاء هذا الزي؟';

  @override
  String get sharedOutfitHideBody =>
      'سيظل مخفياً على هذا الجهاز. يمكنك أيضاً الإبلاغ عنه ليقوم فريقنا بمراجعته وإزالته.';

  @override
  String get sharedOutfitHideAction => 'إخفاء';

  @override
  String get sharedOutfitHiddenInfo =>
      'لن يظهر هذا الزي على هذا الجهاز مجدداً.';

  @override
  String get sharedOutfitHiddenToast => 'تم إخفاء الزي';

  @override
  String get sharedOutfitMissingTitle => 'هذا الزي لم يعد موجوداً';

  @override
  String get sharedOutfitMissingBody =>
      'ربما تمت إزالته أو أن الرابط غير صحيح.';

  @override
  String get sharedOutfitHiddenStateTitle => 'لقد أخفيت هذا الزي';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'إذا كان غير لائق، أبلغ عنه من الخصوصية والشروط أو عبر البريد الإلكتروني $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'أعجبك هذا المظهر؟';

  @override
  String get sharedOutfitCtaBody => 'نسق أزياء مشابهة من خزانتك الخاصة.';

  @override
  String get sharedOutfitCtaButton => 'احصل على FitCheck AI';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع';

  @override
  String get errorNoConnection =>
      'لا توجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';

  @override
  String get errorTimeout => 'انانتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get errorServerError => 'حدث خطأ من جانبنا. يرجى المحاولة مرة أخرى.';

  @override
  String get errorBadGateway =>
      'خادمنا غير متوفر مؤقتاً. يرجى المحاولة مرة أخرى.';

  @override
  String get errorServiceUnavailable =>
      'الخدمة غير متوفرة مؤقتاً. يرجى المحاولة قريباً.';

  @override
  String get errorInternalError => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorUnauthorized => 'يرجى تسجيل الدخول للمتابعة.';

  @override
  String get errorForbidden => 'ليس لديك صلاحية للوصول إلى ذلك.';

  @override
  String get errorSessionExpired =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get errorTokenRefreshFailed =>
      'تعذر تحديث جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get errorRequestCancelled => 'تم إلغاء الطلب.';

  @override
  String get errorInvalidFormat => 'صيغة الملف غير مدعومة.';

  @override
  String get errorFileTooLarge => 'الملف كبير جداً.';

  @override
  String get errorUploadFailed => 'فشل التحميل. يرجى المحاولة مرة أخرى.';

  @override
  String get errorCacheCorrupted => 'تضررت البيانات المحفوظة وتمت إعادتها.';

  @override
  String get errorCacheNotFound => 'لم يتم حفظ أي شيء بعد.';

  @override
  String get errorUserNotFound => 'تعذر العثور على هذا الحساب.';

  @override
  String get errorItemNotFound => 'هذه القطعة لم تعد موجودة.';

  @override
  String get errorOutfitNotFound => 'هذا التنسيق لم يعد موجوداً.';

  @override
  String get rewardsTitle => 'المكافآت';

  @override
  String get rewardsNoAchievementsTitle => 'لا إنجازات بعد';

  @override
  String get rewardsNoAchievementsBody =>
      'أضف قطعاً ونسق إطلالات لكسب أول إنجاز.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'لا يوجد أحد في القائمة بعد';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'نسق إطلالات لكسب النقاط والظهور هنا.';

  @override
  String get legalViewPrivacyPolicy => 'عرض سياسة الخصوصية';

  @override
  String get aiConsentAgree => 'أوافق والمتابعة';

  @override
  String get aiConsentNotNow => 'ليس الآن';

  @override
  String get imageViewerCloseTooltip => 'إغلاق عارض الصور';

  @override
  String get updateReadyTitle => 'التحديث جاهز';

  @override
  String get updateReadyBody => 'أعد تشغيل FitCheck AI لتطبيق أحدث التحسينات.';

  @override
  String get permissionCameraUsage =>
      'يحتاج FitCheck AI إلى الوصول إلى الكاميرا لالتقاط صور لملابسك وتنسيقاتك.';

  @override
  String get permissionPhotoLibraryUsage =>
      'يحتاج FitCheck AI إلى الوصول إلى مكتبة الصور لاختيار صور لملابسك وتنسيقاتك.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'يحتاج FitCheck AI إلى حفظ صور التنسيقات المولدة بالذكاء الاصطناعي في مكتبة الصور الخاصة بك.';

  @override
  String get wardrobeSomePhotosSkipped => 'تم تخطي بعض الصور';

  @override
  String get wardrobePhotosNotAdded => 'لم تتم إضافة الصور';

  @override
  String get wardrobePhotoNotAdded => 'لم تتم إضافة الصورة';

  @override
  String get wardrobeNotStartedTitle => 'لم يبدأ';

  @override
  String get wardrobeNoRoomTitle => 'لا توجد مساحة';

  @override
  String get wardrobeAddPhotosSemantic => 'إضافة صور';

  @override
  String get batchAddTileLabel => 'إضافة';

  @override
  String get batchProfileLinkLabel => 'رابط الملف الشخصي';

  @override
  String get wardrobeImportFromProfileTitle => 'استيراد من ملف شخصي';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'إضافة عدة صور';

  @override
  String get wardrobeClearAction => 'مسح';

  @override
  String get wardrobeRefreshTooltip => 'تحديث';

  @override
  String get batchNoPhotosYetTitle => 'لا توجد صور بعد';

  @override
  String get batchChoosePhotosAction => 'اختيار الصور';

  @override
  String get batchWeFindEachPieceBody =>
      'نكتشف كل قطعة وننشئ لها صورة استوديو احترافية.';

  @override
  String get batchPreparingPhotosSemantic => 'جاري تجهيز الصور';

  @override
  String get batchPhotosProcessedSemantic => 'تمت معالجة الصور';

  @override
  String get batchPasteProfileLinkTitle => 'لصق رابط الملف الشخصي';

  @override
  String get batchPasteProfileLinkBody =>
      'ملف عام على إنستغرام أو فيسبوك. نقوم بمسح صوره، وتختار ما تريد إضافته إلى خزانتك.';

  @override
  String get batchClearLinkTooltip => 'مسح الرابط';

  @override
  String get batchStartingButton => 'جاري البدء';

  @override
  String get batchStartImportAction => 'بدء الاستيراد';

  @override
  String get batchReviewEveryPhotoTitle => 'أنت تراجع كل صورة';

  @override
  String get batchReviewEveryPhotoBody =>
      'لن يتم إتمام أي إضافة حتى توافق عليها.';

  @override
  String get batchPrivateProfilesTitle => 'الملفات الشخصية الخاصة';

  @override
  String get batchPrivateProfilesBody =>
      'اربط حسابك. يطلب انستغرام اسم المستخدم وكلمة المرور أيضاً.';

  @override
  String get batchUseAnotherLinkAction => 'استخدام رابط آخر';

  @override
  String get batchSignInNeededTitle => 'تسجيل الدخول مطلوب';

  @override
  String get batchEnterYourCodeTitle => 'أدخل الرمز الخاص بك';

  @override
  String get batchUseUsernamePasswordAction =>
      'استخدام اسم المستخدم وكلمة المرور';

  @override
  String get batchAlreadyConnectedAction =>
      'لقد قمت بالاتصال مسبقاً في المتصفح';

  @override
  String get batchEnterCodeAction => 'أدخل الرمز';

  @override
  String get batchTryAnotherWayAction => 'جرب طريقة أخرى';

  @override
  String get batchLiveStatus => 'مباشر';

  @override
  String get batchReconnectingStatus => 'جارٍ إعادة الاتصال';

  @override
  String get batchSignInToInstagramTitle => 'تسجيل الدخول إلى انستغرام';

  @override
  String get batchUsernameLabel => 'اسم المستخدم';

  @override
  String get batchCodeIfTwoStepLabel => 'الرمز، إذا كنت تستخدم التحقق بخطوتين';

  @override
  String get batchAuthenticatorCodeBody =>
      'استخدم الرمز المكون من 6 أرقام من تطبيق المصادقة. تتغير الرموز بسرعة.';

  @override
  String get batchVerifyAction => 'تحقق';

  @override
  String get batchFindingPhotosTitle => 'جارٍ العثور على الصور';

  @override
  String get batchImportPausedTitle => 'تم إيقاف الاستيراد مؤقتاً';

  @override
  String get batchProcessingPhotosTitle => 'جارٍ معالجة الصور';

  @override
  String get batchWaitingNextPhoto => 'جارٍ انتظار الصورة التالية';

  @override
  String get batchCancelImportAction => 'إلغاء الاستيراد';

  @override
  String get batchNoPiecesInPhotoBody => 'لم يتم العثور على قطع في هذه الصورة.';

  @override
  String get batchEditPieceColoursLabel => 'الألوان، مفصولة بفواصل';

  @override
  String get batchAddToClosetAction => 'إضافة إلى الخزانة';

  @override
  String get batchSkipPhotoAction => 'تخطي هذه الصورة';

  @override
  String get batchImportCompleteTitle => 'اكتمل الاستيراد';

  @override
  String get batchImportFailedTitle => 'فشل الاستيراد';

  @override
  String get batchImportCancelledTitle => 'تم إلغاء الاستيراد';

  @override
  String get batchImportErrorBody => 'حدث خطأ ما أثناء الاستيراد.';

  @override
  String get batchNothingMoreImportedBody =>
      'لن يتم استيراد أي شيء آخر من هذا الملف الشخصي.';

  @override
  String get batchViewClosetAction => 'عرض الخزانة';

  @override
  String get batchStartOverAction => 'البدء من جديد';

  @override
  String get wardrobeAddPieceTitle => 'إضافة قطعة';

  @override
  String get wardrobeAddDetailsTitle => 'إضافة التفاصيل';

  @override
  String get wardrobeScanningTitle => 'جاري المسح';

  @override
  String get batchReviewPiecesTitle => 'مراجعة القطع';

  @override
  String get wardrobeGalleryAction => 'المعرض';

  @override
  String get wardrobeCameraAction => 'الكاميرا';

  @override
  String get wardrobeNewBadge => 'جديد';

  @override
  String get wardrobeRemovePhotoTooltip => 'إزالة الصورة';

  @override
  String get batchRunInBackgroundTooltip => 'تشغيل في الخلفية';

  @override
  String get batchStepOneOfTwo => 'الخطوة ١ من ٢';

  @override
  String get batchStepTwoOfTwo => 'الخطوة ٢ من ٢';

  @override
  String get batchUploadingPhotosTitle => 'جاري رفع الصور';

  @override
  String get batchFindingPiecesTitle => 'جاري العثور على القطع';

  @override
  String get batchMakingStudioPhotosTitle => 'جاري إنشاء صور الاستوديو';

  @override
  String get batchStoppedLabel => 'متوقف';

  @override
  String get batchFindingPiecesStoppedTitle => 'توقف البحث عن القطع';

  @override
  String get batchCancelledLabel => 'ملغي';

  @override
  String get batchAllDoneTitle => 'تم بنجاح';

  @override
  String get batchOpeningPiecesBody => 'جاري فتح قطعك';

  @override
  String get batchNothingSavedBody => 'لم يتم حفظ أي شيء.';

  @override
  String get batchFindingPiecesFailedBody => 'فشل العثور على القطع.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'توقف البحث عن القطع مبكراً.';

  @override
  String get batchStopFindingPiecesTitle => 'إيقاف البحث عن القطع؟';

  @override
  String get batchStopFindingPiecesBody =>
      'سيتوقف المسح ولا يتم حفظ شيء. القطع التي تم العثور عليها تبقى في نشاطك حتى تتجاهلها.';

  @override
  String get batchKeepGoingAction => 'متابعة';

  @override
  String get batchTryAgainAction => 'حاول مجدداً';

  @override
  String get batchBackToPhotosAction => 'العودة إلى الصور';

  @override
  String get batchSkipAllAction => 'تخطي الكل';

  @override
  String get batchIncludeAllAction => 'تضمين الكل';

  @override
  String get batchNoPiecesFoundTitle => 'لم يتم العثور على قطع';

  @override
  String get batchNoPiecesFoundBody => 'لم نعثر على أي ملابس في هذه الصور.';

  @override
  String get batchChooseOtherPhotosAction => 'اختيار صور أخرى';

  @override
  String get batchUseCaseHelper => 'تتم إضافتها إلى كل قطعة تحفظها.';

  @override
  String get batchDiscardPiecesTitle => 'تجاهل هذه القطع؟';

  @override
  String get batchDiscardPiecesBody => 'لن يتم حفظ أي شيء من هذه المجموعة.';

  @override
  String get batchKeepAction => 'احتفاظ';

  @override
  String get batchDiscardAction => 'تجاهل';

  @override
  String get batchRemovePieceTitle => 'إزالة هذه القطعة؟';

  @override
  String get batchRemovePieceBody => 'لن يتم حفظها في خزانة ملابسك.';

  @override
  String get batchRemoveAction => 'إزالة';

  @override
  String get batchChoosePiecesToSave => 'اختر القطع للحفظ';

  @override
  String get batchDiscardAllAction => 'تجاهل الكل';

  @override
  String get batchNothingSavedRetryBody => 'لم يتم حفظ أي شيء. حاول مرة أخرى.';

  @override
  String get batchNotSavedTitle => 'لم يتم الحفظ';

  @override
  String get batchSavingLabel => 'جاري الحفظ';

  @override
  String get batchSendToBackgroundAction => 'تشغيل في الخلفية';

  @override
  String get batchStillWorkingMessage =>
      'لا نزال نعمل. سنخبرك عندما تصبح قطعك جاهزة.';

  @override
  String get batchRunningInBackgroundTitle => 'يعمل في الخلفية';

  @override
  String get batchStudioPhotosStoppedBody =>
      'توقفت صور الاستوديو مبكراً. لا يمكنك حفظ هذه القطع.';

  @override
  String get batchTapPieceToSkip => 'اضغط على قطعة لتخطيها.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'صور الاستوديو في الطريق. يمكنك المغادرة، وسنخبرك.';

  @override
  String get batchLeaveAction => 'مغادرة';

  @override
  String get batchPeopleInPhotosTitle => 'أشخاص في الصور';

  @override
  String get batchIncludeAction => 'تضمين';

  @override
  String get batchSkipAction => 'تخطي';

  @override
  String get batchYourPhotoIsUsedLabel => 'صورتك مستخدمة';

  @override
  String get batchMakingStudioPhotoLabel => 'جاري إنشاء صورة الاستوديو';

  @override
  String get batchNoStudioPhotoBody => 'لا توجد صورة استوديو. صورتك مستخدمة.';

  @override
  String get batchEnterDetailsYourselfAction => 'إدخال التفاصيل بنفسك';

  @override
  String get batchChooseAnotherPhotoAction => 'اختيار صورة أخرى';

  @override
  String get batchConnectionLostTitle => 'انقطع الاتصال';

  @override
  String get batchConnectionLostBody => 'تحقق من اتصالك ثم حاول مرة أخرى.';

  @override
  String get batchDailyLimitTitle => 'تم بلوغ الحد اليومي';

  @override
  String get batchDailyLimitBodyPaywall =>
      'ترقية إلى Pro لمزيد من عمليات الفحص، أو أدخل التفاصيل بنفسك.';

  @override
  String get batchDailyLimitBodyFree =>
      'تتم إعادة تعيين عمليات الفحص غداً. يمكنك إدخال التفاصيل بنفسك الآن.';

  @override
  String get batchSeePlansAction => 'عرض الخطط';

  @override
  String get batchAiBusyTitle => 'الذكاء الاصطناعي مشغول';

  @override
  String get batchAiBusyBody => 'المشكلة من طرفنا. حاول مرة أخرى بعد قليل.';

  @override
  String get batchNoPiecesBody => 'جرب صورة أوضح، أو أدخل التفاصيل بنفسك.';

  @override
  String get batchScanningUnavailableTitle => 'الفحص غير متوفر';

  @override
  String get batchScanningUnavailableBody =>
      'أدخل التفاصيل بنفسك في الوقت الحالي.';

  @override
  String get batchScanDidNotFinishTitle => 'لم ينته الفحص';

  @override
  String get batchTryAgainBody => 'حاول مرة أخرى.';

  @override
  String get billingTitle => 'الاشتراك';

  @override
  String get billingUpgradeHeading => 'ترقية خطتك';

  @override
  String get billingUpgradeOnPlusBody => 'نفس الميزات، حدود أعلى.';

  @override
  String get billingUpgradeBody =>
      'تتمتع Plus و Pro بنفس الميزات. اختر الحدود التي تحتاجها.';

  @override
  String get billingWebUnavailableBody =>
      'الترقيات عبر الإنترنت غير متوفرة بعد. يتيح لك رمز الدعوة أو العرض فتح Plus أو Pro. ادعُ أصدقاءك أدناه لكسب أشهر مجانية.';

  @override
  String get billingPlansStale =>
      'تعذر تحميل أحدث الخطط. قد تكون الأسعار غير مقدّرة بدقة.';

  @override
  String get billingMonthly => 'شهري';

  @override
  String get billingYearly => 'سنوي';

  @override
  String get billingCurrentPlan => 'الخطة الحالية';

  @override
  String get billingActive => 'نشط';

  @override
  String get billingThisMonth => 'هذا الشهر';

  @override
  String get billingItemExtractions => 'استخراج القطع';

  @override
  String get billingOutfitVisualizations => 'تصورات الإطلالات';

  @override
  String get billingNearLimitUpgrade =>
      'أنت قريب من حد هذا الشهر. قم بالترقية للمزيد.';

  @override
  String get billingNearLimitResets =>
      'أنت قريب من حد هذا الشهر. تتم إعادته مع بداية الشهر القادم.';

  @override
  String get billingStoreUnavailable =>
      'الترقيات غير متوفرة في المتجر حالياً. تحقق مرة أخرى قريباً.';

  @override
  String get billingManageHeading => 'إدارة خطتك';

  @override
  String get billingCancelPlan => 'إلغاء الاشتراك';

  @override
  String get billingCancelKeepsAccess =>
      'ستحتفظ بالوصول حتى نهاية فترة الفوترة الحالية.';

  @override
  String get billingCancelConfirmTitle => 'هل تريد إلغاء اشتراكك؟';

  @override
  String get billingKeepPlan => 'الاحتفاظ بالخطة';

  @override
  String get billingCancelPlanAction => 'إلغاء الخطة';

  @override
  String get billingBilledMonthly => 'فوترة شهرية';

  @override
  String get billingBilledYearly => 'فوترة سنوية';

  @override
  String get billingVirtualTryOn => 'القياس الافتراضي';

  @override
  String get billingPrioritySupport => 'دعم ذو أولوية';

  @override
  String get billingDisclosureProRenewing => 'Pro هو اشتراك يتجدد تلقائياً';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus و Pro هما اشتراكان يتجددان تلقائياً';

  @override
  String get billingDisclosureAppleBilling =>
      'يتم خصم الدفع من حساب Apple ID الخاص بك عند تأكيد الشراء.';

  @override
  String get billingDisclosureGoogleBilling =>
      'يتم خصم الدفع من حساب Google Play الخاص بك عند تأكيد الشراء.';

  @override
  String get billingDisclosureRenewalTerms =>
      'يتجدد اشتراكك تلقائياً لنفس الفترة وبنفس السعر ما لم تقم بإيقاف التجديد التلقائي قبل 24 ساعة على الأقل من نهاية الفترة الحالية.';

  @override
  String get billingDisclosureAppleManage =>
      'قم بالإدارة أو الإلغاء في أي وقت عبر الإعدادات › معرف Apple › الاشتراكات.';

  @override
  String get billingDisclosureGoogleManage =>
      'قم بالإدارة أو الإلغاء في أي وقت عبر Google Play › المدفوعات والاشتراكات.';

  @override
  String get billingReferFriend => 'دعوة صديق';

  @override
  String get billingHowItWorks => 'كيف تعمل';

  @override
  String get billingHowShareTitle => 'شارك رابطك';

  @override
  String get billingHowShareBody => 'أرسله إلى صديق.';

  @override
  String get billingHowSignUpTitle => 'يسجل صديقك';

  @override
  String get billingHowSignUpBody => 'ينضم صديقك عبر الرابط.';

  @override
  String get billingHowBothTitle => 'تكسبان معاً Pro';

  @override
  String get billingHowBothBody => 'يحصل كل منكم على شهر مجاني من Pro.';

  @override
  String get billingYourReferrals => 'إحالاتك';

  @override
  String get billingInvited => 'تمت دعوتهم';

  @override
  String get billingJoined => 'انضموا';

  @override
  String get billingMonthsEarned => 'الأشهر المكتسبة';

  @override
  String get billingInviteFriend => 'دعوة صديق';

  @override
  String get billingInviteBody => 'تحصل أنت وصديقك على شهر من Pro.';

  @override
  String get billingYourCode => 'رمزك';

  @override
  String get billingCopyLink => 'نسخ الرابط';

  @override
  String get billingShareInvite => 'مشاركة الدعوة';

  @override
  String get giftUnavailable => 'دعوات الهدايا غير متوفرة في هذا الإصدار.';

  @override
  String get giftPageTitle => 'إهداء FitCheck Pro';

  @override
  String get giftNoAllowances => 'لا توجد دعوات هدايا مجانية متاحة الآن.';

  @override
  String get giftFormTitle => 'إرسال دعوة مجانية';

  @override
  String get giftFormBody =>
      'يستلم المرتسل الهدية عبر هذا البريد الإلكتروني المتحقق منه. لن نرسل البريد نيابة عنك.';

  @override
  String get giftFieldFrom => 'من';

  @override
  String get giftFieldRecipientName => 'اسم المستلم';

  @override
  String get giftFieldRecipientEmail => 'البريد الإلكتروني للمستلم';

  @override
  String get giftFieldOccasion => 'المناسبة (اختياري)';

  @override
  String get giftNoOccasion => 'بدون مناسبة';

  @override
  String get giftOccasionBirthday => 'عيد ميلاد';

  @override
  String get giftOccasionAnniversary => 'ذكرى سنوية';

  @override
  String get giftOccasionOther => 'أخرى';

  @override
  String get giftFieldCardGreeting => 'تحية البطاقة';

  @override
  String get giftFieldCardGreetingHelper =>
      'تظهر على البطاقة تماماً كما تم كتابتها.';

  @override
  String get giftFieldPrivateNote => 'ملاحظة خاصة (اختياري)';

  @override
  String get giftCreateAction => 'إنشاء هدية مجانية';

  @override
  String get giftClaimedTitle => 'تم استلام الهدية';

  @override
  String get giftClaimedActive => 'هدية FitCheck Pro الخاصة بك مفعلة.';

  @override
  String get giftClaimedQueued =>
      'تبدأ هدية FitCheck Pro بعد انتهاء اشتراكك الحالي.';

  @override
  String get giftLinkCopied => 'تم نسخ رابط الهدية إلى الحافظة.';

  @override
  String get giftErrorName => 'أدخل الاسم.';

  @override
  String get giftErrorEmail => 'أدخل بريداً إلكترونياً صحيحاً.';

  @override
  String get giftErrorGreeting => 'أدخل تحية البطاقة.';

  @override
  String get giftErrorGreetingLength => 'استخدم ما لا يزيد عن 80 حرفاً.';

  @override
  String get giftClaimAction => 'استلام الهدية';

  @override
  String get giftCardPreview => 'معاينة البطاقة';

  @override
  String get giftGiftForYou => 'هدية لك';

  @override
  String get giftGiftWaiting => 'هناك هدية بانتظارك';

  @override
  String get giftOpenBody =>
      'افتح هداياك لاستلامها باستخدام بريدك الإلكتروني المُتحقق منه.';

  @override
  String get giftOpenGifts => 'فتح الهدايا';

  @override
  String get giftSendInvitation => 'إرسال دعوة';

  @override
  String get settingsAiProviderSection => 'المزود';

  @override
  String get settingsAiCustom => 'مخصص';

  @override
  String get settingsAiUrlHelper =>
      'استخدم رابطاً عاماً يمكن للخادم الوصول إليه. لا يعمل المضيف المحلي من خوادمنا.';

  @override
  String get settingsAiConnectionSection => 'الأتصال';

  @override
  String get settingsAiApiUrl => 'رابط API';

  @override
  String get settingsAiApiKey => 'مفتاح API';

  @override
  String get settingsAiApiKeySaved =>
      'تم الحفظ. اترك الحقل فارغاً للاحتفاظ به.';

  @override
  String get settingsAiChatModel => 'نموذج الدردشة';

  @override
  String get settingsAiVisionModel => 'نموذج الرؤية (اختياري)';

  @override
  String get settingsAiImageModel => 'نموذج الصور (اختياري)';

  @override
  String get settingsAiImageModelNote =>
      'تتطلب توليد الصور إكمال دردشة متوافقاً مع OpenAI مع خصائص الاستجابة.';

  @override
  String get settingsAiTestConnection => 'اختبار الاتصال';

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get calendarGoToToday => 'الانتقال إلى اليوم';

  @override
  String get calendarConnectTooltip => 'ربط تقويم';

  @override
  String get calendarAddEvent => 'إضافة حدث';

  @override
  String get calendarEmptyTitle => 'لا توجد خطط';

  @override
  String get calendarEmptyBody => 'أضف حدثاً وخطط لما ستارتديه.';

  @override
  String get calendarPreviousMonth => 'الشهر السابق';

  @override
  String get calendarNextMonth => 'الشهر القادم';

  @override
  String get calendarAllDay => 'طوال اليوم';

  @override
  String get calendarOutfitLinked => 'تم ربط الزي';

  @override
  String get calendarEventOptions => 'خيارات الحدث';

  @override
  String get calendarDeleteTitle => 'حذف هذا الحدث؟';

  @override
  String get calendarChangeOutfit => 'تغيير الطقم';

  @override
  String get calendarLinkOutfit => 'ربط طقم';

  @override
  String get calendarRemoveOutfit => 'إزالة الطقم';

  @override
  String get calendarNewEvent => 'حدث جديد';

  @override
  String get calendarEditEvent => 'تعديل الحدث';

  @override
  String get calendarTitleLabel => 'العنوان';

  @override
  String get calendarTitleRequired => 'أضف عنواناً';

  @override
  String get calendarEndBeforeStart => 'النهاية بعد وقت البدء';

  @override
  String get calendarStarts => 'يبدأ';

  @override
  String get calendarEnds => 'ينتهي';

  @override
  String get calendarPlaceOptional => 'المكان (اختياري)';

  @override
  String get calendarNotesOptional => 'ملاحظات (اختيارية)';

  @override
  String get calendarLinkOutfitEmptyBody => 'أنشئ طقماً ثم اربطه بهذا الحدث.';

  @override
  String get calendarBuildOutfit => 'إنشاء طقم';

  @override
  String get calendarConnectionsTitle => 'التقويمات';

  @override
  String get calendarConnectionsBody =>
      'الحدث الذي تضيفه هنا يبقى في FitCheck.';

  @override
  String get calendarDisconnect => 'قطع الاتصال';

  @override
  String get calendarNotAvailable => 'غير متوفر حالياً';

  @override
  String get profileSectionExplore => 'استكشف';

  @override
  String get profileNavTryOn => 'القياس';

  @override
  String get profileNavRewards => 'المكافآت';

  @override
  String get profileSupport => 'الدعم';

  @override
  String get profileHelp => 'المساعدة';

  @override
  String get profileAbout => 'حول';

  @override
  String get profileAboutBody => 'خزانتك وأطقمك وخططك في مكان واحد.';

  @override
  String get profileSignOutTitle => 'تسجيل الخروج؟';

  @override
  String get profileSignOutBody => 'يمكنك تسجيل الدخول مرة أخرى في أي وقت.';

  @override
  String get profileEditTitle => 'تعديل الملف الشخصي';

  @override
  String get profileYourProfile => 'ملفك الشخصي';

  @override
  String get profileBodyProfiles => 'ملفات الجسم';

  @override
  String get profileBodyEmptyTitle => 'لا توجد ملفات جسم بعد';

  @override
  String get profileBodyEmptyBody => 'أضف طولوك وبنيتك للحصول على مقاس أفضل.';

  @override
  String get profileBodyAdd => 'إضافة ملف شخصي';

  @override
  String get profileBodyDefaultNote =>
      'يُستخدم ملفك الافتراضي للمقاس والقياس التجريبي.';

  @override
  String get profileBodyDefaultBadge => 'الافتراضي';

  @override
  String get profileBodyMakeDefault => 'تعيين كافتراضي';

  @override
  String get profileBodyDeleteBody => 'لا يمكنك التراجع عن هذا الإجراء.';

  @override
  String get profileBodyRequired => 'مطلوب';

  @override
  String get profileBodyCheckNumber => 'تحقق من هذا الرقم';

  @override
  String get profileBodyNew => 'ملف جسم جديد';

  @override
  String get profileBodyNameHint => 'على سبيل المثال: أنا';

  @override
  String get profileBodyHeight => 'الطول';

  @override
  String get profileBodyWeight => 'الوزن';

  @override
  String get profileBodyBuild => 'البنية';

  @override
  String get profileBodySkinTone => 'لون البشرة';

  @override
  String get profileBirthDateNeededBody =>
      'أضف تاريخ الميلاد ليتوافق مع وقت الولادة.';

  @override
  String get profileBirthDateNeededTitle => 'تاريخ الميلاد مطلوب';

  @override
  String get profilePartlySavedBody =>
      'حفظنا اسمك وصورتك. لم تُحفظ تفاصيل الميلاد؛ حاول مرة أخرى لاحقاً.';

  @override
  String get profilePartlySavedTitle => 'حفظ جزئي';

  @override
  String get profileSavedBody => 'تم حفظ ملفك الشخصي.';

  @override
  String get profileChangePhoto => 'تغيير صورة الملف الشخصي';

  @override
  String get profilePhotoLabel => 'صورة الملف الشخصي';

  @override
  String get profilePhotoHint => 'اضغط لاختيار صورة جديدة';

  @override
  String get profileBirthDateLabel => 'تاريخ الميلاد (اختياري)';

  @override
  String get profileBirthTimeLabel => 'وقت الولادة (اختياري)';

  @override
  String get profileBirthTimeHelper => 'يجعل الاقتراحات أكثر دقة';

  @override
  String get profileBirthPlaceLabel => 'مكان الولادة (اختياري)';

  @override
  String get profileBirthPlaceHint => 'على سبيل المثال: الرياض، السعودية';

  @override
  String get profileHelpContactTitle => 'اسألنا عما تريد';

  @override
  String get profileHelpContactBody =>
      'أرسل رسالة وسنرد عليك عبر البريد الإلكتروني خلال يوم عادة.';

  @override
  String get profileHelpContactAction => 'اتصل بالدعم';

  @override
  String get profileHelpFaqTitle => 'الأسئلة الشائعة';

  @override
  String get profileFaqAddPiecesTitle => 'كيف أضيف قطعاً إلى خزانتي؟';

  @override
  String get profileFaqAddPiecesBody =>
      'اضغط على إضافة عنصر في علامة تبويب الخزانة. التقط صورة أو اختر واحدة من معرض الصور الخاص بك، وسنقوم بالعثور على كل قطعة وتصنيفها لك.';

  @override
  String get profileFaqMatchingTitle => 'كيف يعمل تنسيق الملابس؟';

  @override
  String get profileFaqMatchingBody =>
      'افتَح قسم لك واختر القطع التي تمتلكها. نقترح عليك ما يناسبها وننشئ أزياء كاملة من خزانة ملابسك.';

  @override
  String get profileFaqTryOnTitle =>
      'هل يمكنني استخدام صوري الخاصة للقياس الافتراضي؟';

  @override
  String get profileFaqTryOnBody =>
      'نعم. أضف صورة كاملة الطول لنفسك، ثم اختر القطع لرؤيتها عليك.';

  @override
  String get profileFaqRewardsTitle => 'كيف أربح المكافآت؟';

  @override
  String get profileFaqRewardsBody =>
      'خطط وسجل الملابس بانتظام. تتراكم السلسلة والإنجازات كلما تقدمت.';

  @override
  String get profileFaqPrivacyTitle => 'هل خزانتي الخاصة سرية؟';

  @override
  String get profileFaqPrivacyBody =>
      'نعم. خزانة ملابسك وأزياؤك خاصة ما لم تشارك رابطاً لزي واحد.';

  @override
  String get profileHelpMoreTitle => 'مزيد من المساعدة';

  @override
  String get profileHelpGuides => 'الأدلة';

  @override
  String get profileHelpGuidesBody => 'كيف تعمل كل ميزة';

  @override
  String get feedbackCategoryBug => 'حدث خطأ ما';

  @override
  String get feedbackCategoryIdea => 'فكرة';

  @override
  String get feedbackCategoryGeneral => 'عام';

  @override
  String get feedbackCategoryHelp => 'أحتاج إلى مساعدة';

  @override
  String get feedbackHintBug =>
      'ماذا حدث، وماذا كنت تتوقع؟ تساعدنا الخطوات في إبصلاح المشكلة.';

  @override
  String get feedbackHintIdea => 'ماذا تفضل أن تراه، ولماذا؟';

  @override
  String get feedbackHintGeneral => 'أخبرنا برأيك، أو اطرح سؤالاً.';

  @override
  String get feedbackAttachmentLimitBody => 'يمكنك إضافة ما يصل إلى 5 صور.';

  @override
  String get feedbackAttachmentLimitTitle => 'تم بلوغ الحد الأقصى';

  @override
  String get feedbackImageTooLargeBody => 'اختر صورة بحجم أقل من 5 ميجابايت.';

  @override
  String get feedbackImageTooLargeTitle => 'الصورة كبيرة جداً';

  @override
  String get feedbackTitle => 'إرسال التعليقات';

  @override
  String get feedbackAboutLabel => 'ما هو موضوعه؟';

  @override
  String get feedbackSubjectLabel => 'الموضوع';

  @override
  String get feedbackSubjectRequired => 'أضف موضوعاً';

  @override
  String get feedbackSubjectTooShort => 'يجب ألا يقل الموضوع عن 3 أحرف';

  @override
  String get feedbackDetailsLabel => 'التفاصيل';

  @override
  String get feedbackDetailsRequired => 'أضف بعض التفاصيل';

  @override
  String get feedbackDetailsTooShort => 'يجب ألا تقل الوصف عن 10 أحرف';

  @override
  String get feedbackAddScreenshot => 'أضف لقطة شاشة';

  @override
  String get feedbackAttachmentHint => 'حتى 5، 5 ميغابايت لكل منها';

  @override
  String get feedbackSend => 'إرسال';

  @override
  String get feedbackEmptyTitle => 'لم يتم إرسال شيء بعد';

  @override
  String get feedbackEmptyBody => 'ما ترسله يظهر هنا مع حالته.';

  @override
  String get feedbackHistoryTitle => 'ما أرسلته';

  @override
  String get feedbackStatusOpen => 'مفتوح';

  @override
  String get feedbackStatusInProgress => 'قيد المعالجة';

  @override
  String get feedbackStatusResolved => 'تم الحل';

  @override
  String get feedbackStatusClosed => 'مغلق';

  @override
  String get legalIntro => 'كيف نحمي بياناتك وشروط استخدام FitCheck AI.';

  @override
  String get legalPolicies => 'السياسات';

  @override
  String get legalPrivacySubtitle => 'ما نجمع ولماذا';

  @override
  String get legalTermsTitle => 'شروط الخدمة';

  @override
  String get legalTermsSubtitle => 'قواعد استخدام التطبيق';

  @override
  String get legalLicences => 'تراخيص المصدر المفتوح';

  @override
  String get legalSupportSubtitle => 'المساعدة والاتصال وطلبات الخصوصية';

  @override
  String get legalReportAbuse => 'الإبلاغ عن مشكلة أو إساءة';

  @override
  String get permissionCameraTitle => 'الوصول إلى الكاميرا';

  @override
  String get permissionCameraRationale =>
      'يستخدم FitCheck AI كاميرتك لالتقاط صور لملابسك وإطلالاتك للتجربة بالذكاء الاصطناعي وتنظيم خزانة الملابس.';

  @override
  String get permissionPhotoTitle => 'الوصول إلى الصور';

  @override
  String get permissionPhotoRationale =>
      'يحتاج FitCheck AI إلى الوصول إلى صورك لتتمكن من تحديد صور الملابس للإطلالات ولمميزات الذكاء الاصطناعي وخزانتك.';

  @override
  String get permissionNotNow => 'ليس الآن';

  @override
  String get permissionOpenSettings => 'فتح الإعدادات';

  @override
  String authSignedInAs(String name) {
    return 'مسجل الدخول باسم $name';
  }

  @override
  String get authSignedIn => 'تم تسجيل الدخول';

  @override
  String get authWelcomeBackTitle => 'أهلاً بك مجدداً';

  @override
  String get authSignInFailed => 'فشل تسجيل الدخول';

  @override
  String get authWelcomeTitle => 'مرحباً';

  @override
  String get authSignUpFailed => 'فشل إنشاء Account';

  @override
  String get authGoogleSignInFailed => 'فشل تسجيل الدخول بواسطة Google';

  @override
  String get authAppleSignInFailed => 'فشل تسجيل الدخول بواسطة Apple';

  @override
  String get authConfirmEmailTitle => 'تأكيد بريدك الإلكتروني';

  @override
  String get authConfirmEmailBody =>
      'تحقق من بريدك الوارد للحصول على رسالة التأكيد، ثم سجل الدخول.';

  @override
  String get authClosetReady => 'خزانتك جاهزة.';

  @override
  String get authSignedOutTitle => 'تم تسجيل الخروج';

  @override
  String get authSignedOutBody => 'تم تسجيل خروجك.';

  @override
  String get authSignOutFailed => 'فشل تسجيل الخروج';

  @override
  String get authEmailSentTitle => 'تم إرسال البريد';

  @override
  String get authResetLinkSent =>
      'تحقق من بريدك للحصول على رابط إعادة التعيين.';

  @override
  String get authPasswordUpdatedTitle => 'تم تحديث كلمة المرور';

  @override
  String get authPasswordUpdated => 'تم تحديث كلمة المرور الخاصة بك.';

  @override
  String get authPasswordNotUpdated => 'لم يتم تحديث كلمة المرور';

  @override
  String get authCouldNotSendEmail => 'تعذر إرسال البريد الإلكتروني';

  @override
  String get authEmailNotSent => 'لم يتم إرسال البريد الإلكتروني';

  @override
  String get authResendSentBody => 'أرسلنا بريد تأكيد جديد.';

  @override
  String get outfitPreviewWithAi => 'معاينة بالذكاء الاصطناعي';

  @override
  String get outfitNewPreview => 'إنشاء معاينة جديدة';

  @override
  String get outfitBuilderClosetHeading => 'خزانة ملابسك';

  @override
  String get outfitBuilderSearchHint => 'ابحث عن القطع';

  @override
  String get outfitClearSearch => 'مسح البحث';

  @override
  String get outfitBuilderAddPiecesTitle => 'أضف قطعاً أولاً';

  @override
  String get outfitBuilderAddPiecesBody =>
      'تُصنع الإطلالات من القطع في خزانتك.';

  @override
  String get outfitBuilderNoMatches => 'لا توجد قطع متطابقة.';

  @override
  String get outfitNameLabel => 'اسم الإطلالة';

  @override
  String get outfitNameHint => 'على سبيل المثال، كتان نهاية الأسبوع';

  @override
  String get outfitPreviewSemantic => 'معاينة ذكية للإطلالة';

  @override
  String get outfitChoosePieces => 'اختر القطع';

  @override
  String get outfitTapPiecesHint => 'انقر على القطع أدناه لإضافتها.';

  @override
  String get outfitShareTooltip => 'مشاركة';

  @override
  String get outfitSaveFavourite => 'حفظ في المفضلة';

  @override
  String get outfitPiecesHeading => 'القطع';

  @override
  String get outfitWearHistoryEmpty => 'ارتدِها مرة واحدة وستظهر التواريخ هنا.';

  @override
  String get outfitWearHistoryTitle => 'سجل الارتداء';

  @override
  String get outfitWearHistoryError => 'تعذّر تحميل التواريخ.';

  @override
  String get outfitWornOn => 'تم ارتداؤها في';

  @override
  String get outfitEditTitle => 'تحرير الإطلالة';

  @override
  String get outfitSavedPhotosFailed => 'تم حفظ التفاصيل، لكن لا الصور';

  @override
  String get outfitNoPhotosBody =>
      'لا توجد صور بعد. ستُعرض القطع بدلاً من ذلك.';

  @override
  String get outfitOccasionLabel => 'المناسبة';

  @override
  String get outfitOccasionNone => 'لا شيء';

  @override
  String get outfitTagsHint => 'افصل بفاصل';

  @override
  String get outfitDraftBody => 'مخفي من قائمتك الرئيسية';

  @override
  String get outfitPublic => 'عام';

  @override
  String get outfitPublicBody => 'أي شخص يملك الرابط يمكنه رؤيتها';

  @override
  String get outfitDeleteFromDetail => 'حذف هذه الإطلالة من صفحة التفاصيل.';

  @override
  String get outfitNewCollection => 'مجموعة جديدة';

  @override
  String get outfitNoCollectionsTitle => 'لا توجد مجموعات بعد';

  @override
  String get outfitNoCollectionsBody =>
      'تجميع outfits حسب السفر أو الفصل أو المزاج';

  @override
  String get outfitCreateCollection => 'إنشاء مجموعة';

  @override
  String get outfitAddOutfits => 'إضافة outfits';

  @override
  String get outfitRename => 'إعادة تسمية';

  @override
  String get outfitCollectionDeleteBody => 'سيتم الاحتفاظ بال outfits فيها';

  @override
  String get outfitCollectionsNotLoaded => 'لم يتم تحميل outfits';

  @override
  String get outfitRenameCollection => 'إعادة تسمية المجموعة';

  @override
  String get outfitDescriptionOptional => 'الوصف (اختياري)';

  @override
  String get outfitAllInCollection => 'كل outfit موجود في هذه المجموعة';

  @override
  String get photoshootSubtitleUpload => 'بورتريهات استوديو من صورك الخاصة';

  @override
  String get photoshootSubtitleConfigure => 'اختر نمطًا وصيغة وعددًا';

  @override
  String get photoshootSubtitleGenerating => 'يستغرق هذا دقيقة أو دقيقتين';

  @override
  String get photoshootAddPhotosSemantic => 'إضافة صور من معرضك';

  @override
  String get photoshootUploadTitle => 'أضف من صورة إلى أربع صور لك';

  @override
  String get photoshootUploadBody => 'انقر لاختيار من معرضك';

  @override
  String get photoshootAddToContinue => 'أضف صورة للمتابعة';

  @override
  String get photoshootAddAnotherPhoto => 'أضف صورة أخرى';

  @override
  String get photoshootTipsTitle => 'للحصول على أفضل النتائج';

  @override
  String get photoshootTipsBody =>
      'استخدم صورًا واضحة ومضيئة لوجهك من زوايا مختلفة. تجنب النظارات الشمسية والقبعات.';

  @override
  String get photoshootStarting => 'جارٍ البدء';

  @override
  String get photoshootCancelling => 'إلغاء';

  @override
  String get photoshootFailed => 'فشل';

  @override
  String get recommendTabMatches => 'مطابقات';

  @override
  String get recommendTabComplete => 'اكتمال';

  @override
  String get recommendTabWeather => 'الطقس';

  @override
  String get recommendTabColours => 'الألوان';

  @override
  String get recommendTabShop => 'تسوق';

  @override
  String get recommendNoMatchesTitle => 'لا توجد مطابقات بعد';

  @override
  String get recommendNoMatchesBody => 'اختر قطعة وسنجد ما يناسبها.';

  @override
  String get recommendPickPiece => 'اختر قطعة';

  @override
  String get recommendNothingMatchesTitle => 'لا توجد مطابقات بعد';

  @override
  String get recommendNothingMatchesBody =>
      'جرب قطعاً أخرى أو أضف المزيد إلى خزانتك.';

  @override
  String get recommendChangePieces => 'غيّر القطع';

  @override
  String get recommendDefaultReason => 'تناسب القطع التي اخترتها.';

  @override
  String get recommendCompleteTitle => 'أكمل الإطلالة';

  @override
  String get recommendCompleteBody => 'اختر قطعة وسنملأ الباقي.';

  @override
  String get recommendWorking => 'جارٍ العمل';

  @override
  String get recommendGenerate => 'إنشاء';

  @override
  String get recommendChooseStyleBody => 'اختر اسلوباً ثم أنشئ.';

  @override
  String get recommendNoLooksTitle => 'لا إطلالات لهذه القطع';

  @override
  String get recommendNoLooksBody => 'جرب اسلوباً أو قطعاً أخرى.';

  @override
  String get recommendDefaultLook => 'إطلالة لقطعك';

  @override
  String get recommendNoPiecesBody => 'لم تعود أي قطع لهذه الإطلالة.';

  @override
  String get recommendCityLabel => 'المدينة';

  @override
  String get recommendCheck => 'فحص';

  @override
  String get recommendWeatherTitle => 'كيف الطقس؟';

  @override
  String get recommendWeatherBody => 'أدخل مدينتك للحصول على اقتراحات لليوم.';

  @override
  String get recommendWearToday => 'ارتدِ اليوم';

  @override
  String get recommendWeatherNoPieces =>
      'لا توجد قطع في خزانتك تناسب هذا الطقس بعد.';

  @override
  String get recommendBudgetLabel => 'الميزانية حتى';

  @override
  String get recommendLooking => 'بحث';

  @override
  String get recommendFindWhatToBuy => 'اعثر على ما تشتريه';

  @override
  String get recommendFillGapsTitle => 'أكمل النواقص';

  @override
  String get recommendFillGapsBody => 'حدد ميزانية وسنقترح ما ينقص خزانتك.';

  @override
  String get recommendNoGapsTitle => 'لم تُكتشف نواقص';

  @override
  String get recommendNoGapsBody => 'جرب ميزانية أكبر أو فئة أخرى.';

  @override
  String get recommendMoodEveryday => 'يومي';

  @override
  String get recommendMoodBigMeeting => 'اجتماع كبير';

  @override
  String get recommendDayLabel => 'يوم';

  @override
  String get recommendReadingStars => 'قراءة النجوم';

  @override
  String get recommendGetMyColours => 'احصل على ألواني';

  @override
  String get recommendLuckyColoursTitle => 'ألوان حظك';

  @override
  String get recommendLuckyColoursBody =>
      'اختر يوماً وسنقترح ألواناً وقطعاً تناسبه.';

  @override
  String get recommendLuckyColoursSection => 'ألوان حظ';

  @override
  String get recommendAvoidColoursSection => 'ألوان يُنصح بالاعتدال فيها';

  @override
  String get recommendBirthDateTitle => 'أضف تاريخ ميلادك';

  @override
  String get recommendBirthDateBody => 'نحتاج تاريخ ميلادك لقراءة ألوانك.';

  @override
  String get recommendEditProfile => 'تعديل الملف';

  @override
  String get recommendNothingThisDay => 'لا يوجد لهذا اليوم.';

  @override
  String get recommendUnnamedColour => 'لون بدون اسم';

  @override
  String get recommendFromCloset => 'من خزانتك';

  @override
  String get recommendNoPiecesInColours => 'لا توجد قطع بهذه الألوان بعد.';

  @override
  String get recommendOutfitIdeas => 'أفكار إطلالات';

  @override
  String get recommendNoOutfitsInColours =>
      'لا توجد إطلالة كاملة بهذه الألوان بعد.';

  @override
  String get recommendDefaultOutfitIdea => 'فكرة إطلالة';

  @override
  String get recommendPickUpToThree => 'اختر حتى ثلاث قطع';

  @override
  String get recommendEmptyClosetBody =>
      'أضف بعض القطع أولاً ثم عدّ لإيجاد التطابقات.';

  @override
  String get dashboardDressForDay => 'ارتدي بما يناسب يومك القادم.';

  @override
  String get dashboardOutfitOfDay => 'إطلالة اليوم';

  @override
  String get dashboardFreshLook => 'مظهر جديد';

  @override
  String get subscriptionManageInStoreTitle => 'إدارة في المتجر';

  @override
  String get subscriptionManageInStoreBody =>
      'يتم فوترة هذا الخطة عبر المتجر. أضبطها في إعدادات حساب المتجر.';

  @override
  String get subscriptionCancelledTitle => 'تم إلغاء الاشتراك';

  @override
  String get subscriptionCancelledBody =>
      'تبقى خطتك نشطة حتى نهاية هذه الفترة الفوترية.';

  @override
  String get subscriptionCancelFailedTitle => 'تعذر الإلغاء';

  @override
  String get subscriptionCouldNotOpenTitle => 'تعذر الفتح';

  @override
  String get subscriptionOpenBillingFailedBody => 'تعذر فتح إدارة الفوترة.';

  @override
  String get subscriptionOpenLinkFailedBody => 'تعذر فتح الرابط.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'تعذر تحميل رابطك';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'تعذر تحميل رابط إحالتك. حاول مرة أخرى.';

  @override
  String get subscriptionReferralCopiedTitle => 'تم النسخ';

  @override
  String get subscriptionReferralCopiedBody => 'تم نسخ رابط الإحالة.';

  @override
  String get subscriptionReferralShareSubject => 'جرّب FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'انضم إلى FitCheck AI لنحصل كلا منا على شهر من Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'تم نسخ الرابط';

  @override
  String get subscriptionShareUnavailableBody =>
      'المشاركة غير متاحة، لذا تم نسخ الرابط.';

  @override
  String get subscriptionShareFailedTitle => 'تعذر المشاركة';

  @override
  String get subscriptionShareFailedBody =>
      'انسخ الرابط من صفحة الإحالة بدلاً من ذلك.';

  @override
  String get subscriptionStoreReadyTitle => 'المتجر جاهز';

  @override
  String get subscriptionStoreReadyBody =>
      'أسعار المتجر متاحة. يمكنك الترقية الآن.';

  @override
  String get purchaseFailedTitle => 'فشل الشراء';

  @override
  String get purchaseUnavailableTitle => 'الشراء غير متاح';

  @override
  String get purchaseIapUnavailableBody =>
      'المشتريات داخل التطبيق غير متاحة على هذا الجهاز.';

  @override
  String get purchasePlanNotAvailableBody => 'هذا الخطة غير متاح للشراء بعد.';

  @override
  String get purchasePlanNotInStoreBody =>
      'هذه الخطة غير متاحة في المتجر بعد. يرجى العودة قريباً.';

  @override
  String get purchaseStartFailedBody => 'تعذر بدء الشراء. حاول مرة أخرى.';

  @override
  String get purchaseNoPaymentLinkBody => 'لم يُرجِع إتمام الدفع رابط دفع.';

  @override
  String get purchasePendingTitle => 'الشراء قيد المعالجة';

  @override
  String get purchasePendingBody =>
      'شراؤك بانتظار الموافقة. ستحصل على الوصول فور اعتماده.';

  @override
  String get purchaseFailedBody => 'فشل الشراء. حاول مرة أخرى.';

  @override
  String get purchaseRestoredTitle => 'تم الاستعادة';

  @override
  String get purchaseRestoredBody => 'تمت استعادة مشترياتك.';

  @override
  String get purchaseActiveTitle => 'الاشتراك نشط';

  @override
  String get purchaseActiveBody => 'اشتراكك نشط. مرحباً بك.';

  @override
  String get purchaseSignInRequiredTitle => 'تسجيل الدخول مطلوب';

  @override
  String get purchaseSignInRequiredBody => 'سجّل الدخول لإتمام الشراء.';

  @override
  String get purchaseErrorTitle => 'خطأ في الشراء';

  @override
  String get purchaseInvalidTransactionBody =>
      'لم يتضمن الشراء معرّف عملية قابل للتحقق.';

  @override
  String get purchaseVerificationPendingTitle => 'التحقق قيد الانتظار';

  @override
  String get purchaseVerificationPendingBody =>
      'لم نتمكن من التحقق من عملية الشراء مع المتجر الآن. ستُكمل تلقائياً ولن يتم تحصيل المبلغ مرتين.';

  @override
  String get purchaseNotAppliedTitle => 'لم يُسّر الشراء';

  @override
  String get purchaseNotAppliedBody =>
      'لم يمكن تطبيق عملية الشراء على حسابك. تواصل مع الدعم ولا تشرِها مرة أخرى.';

  @override
  String get purchaseRestoreFailedTitle => 'فشل الاستعادة';

  @override
  String get purchaseRestoreFailedBody =>
      'تعذّر استعادة عمليات الشراء. حاول مجدداً.';

  @override
  String get purchaseRecoveredActiveBody => 'اشتراكك نشط.';

  @override
  String get purchaseCompleteTitle => 'اكتمل الشراء';

  @override
  String get giftCreateFailedTitle => 'تعذّر إنشاء الهدية';

  @override
  String get giftClaimFailedTitle => 'تعذّر المطالبة بالهدية';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count هدايا لك',
      one: 'هدية لك',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': 'شهر واحد',
      '12': 'سنة واحدة',
      'other': '$months أشهر',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining متبقية',
      one: 'متبقي واحد',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration من FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return 'أرسل لك $sender $duration من FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'هدية FitCheck Pro لـ $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'من $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'إلى $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'من $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'المستلم';

  @override
  String get giftPreviewPlaceholderSender => 'أنت';

  @override
  String get settingsSavedTitle => 'تم الحفظ';

  @override
  String get settingsNotSavedTitle => 'لم يُحفظ';

  @override
  String get settingsAiChooseProviderBody => 'اختر مزوّداً.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'يتطلب المزوّد المخصص عنوان API.';

  @override
  String get settingsAiKeyRequiredBody => 'أدخل مفتاح API.';

  @override
  String get settingsAiSavedBody => 'تم حفظ إعدادات الذكاء الاصطناعي.';

  @override
  String get settingsAiMissingDetailsTitle => 'تفاصيل ناقصة';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'أدخل عنوان API ونموذج محادثة للاختبار.';

  @override
  String get settingsAiKeyNeededTitle => 'مفتاح API مطلوب';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'أدخل مفتاح API للاختبار. يبقى المفتاح الخاص بك سريًا.';

  @override
  String get settingsAiKeyToTestBody => 'أدخل مفتاح API للاختبار.';

  @override
  String get settingsAiConnectedTitle => 'متصل';

  @override
  String get settingsAiConnectedBody => 'الاتصال يعمل.';

  @override
  String get settingsAiTestFailedTitle => 'فشل الاختبار';

  @override
  String get settingsPreferencesSavedBody => 'تم حفظ تفضيلاتك.';

  @override
  String get settingsPasswordNotChangedTitle => 'كلمة المرور لم تغيّر';

  @override
  String get settingsOAuthPasswordBody =>
      'هذا الحساب يستخدم تسجيل الدخول عبر Google أو Apple. استخدم \"نسيت كلمة المرور\" لضبط كلمة مرور أولًا.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'كلمة المرور الحالية غير صحيحة.';

  @override
  String get settingsExportReadyTitle => 'التصدير جاهز';

  @override
  String get settingsExportReadyBody => 'صدّار بياناتك جاهز للتنزيل.';

  @override
  String get settingsLinkCopiedTitle => 'تم نسخ الرابط';

  @override
  String get settingsExportClipboardBody =>
      'تعذّر فتح متصفحك، لذا نسخنا رابط التنزيل. الصقه في متصفح قريبًا: إنه قابل للمهلة.';

  @override
  String get settingsExportFailedTitle => 'فشل التصدير';

  @override
  String get settingsAccountNotDeletedTitle => 'الحساب لم يحذف';

  @override
  String photoshootPhotoLimit(int max) {
    return 'يمكنك إضافة حتى $max صور.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'حد الصور';

  @override
  String get photoshootAddAtLeastOnePhoto => 'أضف صورة واحدة على الأقل.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'لا توجد صور';

  @override
  String get photoshootDescribeLookBody => 'صف المظهر الذي تريده.';

  @override
  String get photoshootPromptNeededTitle => 'لازم وصف';

  @override
  String get photoshootConsentFeatureLabel => 'جلسة تصوير بالذكاء الاصطناعي';

  @override
  String get photoshootStatusPreparing => 'تحضير صورك';

  @override
  String get photoshootStatusGenerating => 'جارٍ الإنشاء';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'دفعة $current من $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done من $total اكتملت';
  }

  @override
  String get photoshootGenerationFailedBody => 'فشل الإنشاء.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready جاهزة، $failed فشلت.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'اكتمل جزئيًا';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صور جاهزة.',
      one: 'صورتان جاهزتان.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'انقطع الاتصال. يُرجى المحاولة مرة أخرى.';

  @override
  String get photoshootCouldNotCancelTitle => 'تعذّر الإلغاء';

  @override
  String get photoshootRetryFailedTitle => 'فشلت إعادة المحاولة';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'الصورة $number جاهزة.';
  }

  @override
  String get photoshootReplacedTitle => 'تم الاستبدال';

  @override
  String get photoshootSavedToGalleryBody => 'تم الحفظ في معرضك.';

  @override
  String get photoshootSavedTitle => 'تم الحفظ';

  @override
  String get photoshootNotSavedTitle => 'لم يتم الحفظ';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جميع الصور $count في معرضك.',
      one: 'صورة واحدة في معرضك.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'تم حفظ $saved من أصل $total.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'بعض الصور لم تُحفظ';

  @override
  String get tryonConsentFeatureLabel => 'التجربة الافتراضية';

  @override
  String get tryonAvatarUpdatedBody => 'تم تحديث صورتك.';

  @override
  String get tryonSavedTitle => 'تم الحفظ';

  @override
  String get tryonUploadFailedTitle => 'فشل التحميل';

  @override
  String get tryonChooseGarmentFirstBody => 'اختر صورة لقطعة الملابس أولاً.';

  @override
  String get tryonNoGarmentTitle => 'لا توجد قطعة';

  @override
  String get tryonWaitForUploadBody => 'انتظر حتى يتم رفع صورتك بالكامل.';

  @override
  String get tryonStillUploadingTitle => 'جارٍ التحميل';

  @override
  String get tryonAddYourPhotoFirstBody => 'أضف صورة لنفسك أولاً.';

  @override
  String get tryonReadyBody => 'تجربتك جاهزة.';

  @override
  String get tryonFailedTitle => 'فشلت التجربة';

  @override
  String get tryonSavedToGalleryBody => 'تم الحفظ في معرضك.';

  @override
  String get tryonNotSavedTitle => 'لم يتم الحفظ';

  @override
  String get calendarEventAddedBody => 'تمت إضافة الحدث';

  @override
  String get calendarEventPlannedTitle => 'تمت الخطة';

  @override
  String get calendarEventSavedBody => 'تم حفظ الحدث';

  @override
  String get calendarSavedTitle => 'تم الحفظ';

  @override
  String get calendarEventNotSavedTitle => 'لم يتم حفظ الحدث';

  @override
  String get calendarEventRemovedBody => 'تمت إزالة الحدث';

  @override
  String get calendarEventDeletedTitle => 'تم الحذف';

  @override
  String get calendarEventNotDeletedTitle => 'لم يتم حذف الحدث';

  @override
  String get calendarOutfitNotLinkedTitle => 'لم يتم ربط الإطلالة';

  @override
  String get calendarLinkedTitle => 'تم الربط';

  @override
  String get calendarOutfitNotRemovedTitle => 'لم يتم إزالة الإطلالة';

  @override
  String get calendarOutfitRemovedBody => 'تمت إزالة الإطلالة';

  @override
  String get calendarDisconnectedBody => 'تم فصل التقويم';

  @override
  String get calendarDisconnectedTitle => 'تم الفصل';

  @override
  String get calendarNotDisconnectedTitle => 'لم يتم فصل التقويم';

  @override
  String get calendarTodayLabel => 'اليوم';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أحداث',
      one: 'حدث واحد',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'من $start إلى $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, إطلالة مربوطة';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return 'سيتم إزالة \"$title\".';
  }

  @override
  String get calendarThisAppLabel => 'هذه التطبيق';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'مزامنة مع $provider غير متاحة بعد. يمكنك إضافة الأحداث هنا.';
  }

  @override
  String get calendarWeekdaySunShort => 'أحد';

  @override
  String get calendarWeekdayMonShort => 'اثنين';

  @override
  String get calendarWeekdayTueShort => 'ثلاثاء';

  @override
  String get calendarWeekdayWedShort => 'أربعاء';

  @override
  String get calendarWeekdayThuShort => 'خميس';

  @override
  String get calendarWeekdayFriShort => 'جمعة';

  @override
  String get calendarWeekdaySatShort => 'سبت';

  @override
  String get calendarWeekdayMonday => 'الإثنين';

  @override
  String get calendarWeekdayTuesday => 'الثلاثاء';

  @override
  String get calendarWeekdayWednesday => 'الأربعاء';

  @override
  String get calendarWeekdayThursday => 'الخميس';

  @override
  String get calendarWeekdayFriday => 'الجمعة';

  @override
  String get calendarWeekdaySaturday => 'السبت';

  @override
  String get calendarWeekdaySunday => 'الأحد';

  @override
  String get outfitSavedToFavouritesBody => 'تم الحفظ في المفضلة';

  @override
  String get outfitRemovedFromFavouritesBody => 'تمت الإزالة من المفضلة';

  @override
  String get outfitNotSavedTitle => 'لم يتم الحفظ';

  @override
  String get outfitLoggedAsWornBody => 'تم تسجيله كمرتد اليوم.';

  @override
  String get outfitNicePickTitle => 'اختيار ممتاز';

  @override
  String get outfitRemovedBody => 'تمت إزالة الإطلالة.';

  @override
  String get outfitDeletedTitle => 'تم الحذف';

  @override
  String get outfitNotDeletedTitle => 'لم يتم الحذف';

  @override
  String get outfitDuplicatedBody => 'نسخة موجودة في إطلالاتك.';

  @override
  String get outfitDuplicatedTitle => 'تم التكرار';

  @override
  String get outfitNotDuplicatedTitle => 'لم يتم التكرار';

  @override
  String get outfitNotSharedTitle => 'لم تتم المشاركة';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" جاهزة.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'لم يتم إنشاء المجموعة';

  @override
  String get outfitCollectionUpdatedBody => 'تم تحديث المجموعة.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'لم يتم تحديث المجموعة';

  @override
  String get outfitCollectionDeletedBody => 'تم حذف المجموعة.';

  @override
  String get outfitCollectionNotDeletedTitle => 'لم يتم حذف المجموعة';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count إطلالات.',
      one: 'تمت إضافة إطلالة واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'لم تتم إضافة الإطلالات';

  @override
  String get outfitPreviewNotCreatedTitle => 'لم يتم إنشاء المعاينة';

  @override
  String get outfitGiveNameBody => 'امنح الإطلالة اسماً.';

  @override
  String get outfitNameMissingTitle => 'الاسم';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'اختر قطعة واحدة على الأقل.';

  @override
  String outfitCreatedBody(String name) {
    return '$name في إطلالاتك.';
  }

  @override
  String get outfitSavedTitle => 'تم الحفظ';

  @override
  String get wardrobeAddedToFavouritesBody => 'تمت الإضافة إلى المفضلة';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'تمت الإزالة من المفضلة';

  @override
  String get wardrobeNotSavedTitle => 'لم يتم الحفظ';

  @override
  String get wardrobeLoggedAsWornBody => 'سُجّلت كقُطعة مُرتادة اليوم.';

  @override
  String get wardrobeRemovedFromClosetBody => 'أُزيلت من خزانة الملابس.';

  @override
  String get wardrobeDeletedTitle => 'حُذفت';

  @override
  String get wardrobeNotDeletedTitle => 'لم تُحذف';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُزيلت $count قطع من خزانة الملابس.',
      one: 'أُزيلت قطعة واحدة من خزانة الملابس.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'استخراج الخزانة بالذكاء الاصطناعي';

  @override
  String get itemAddScanJobLabel => 'مسح';

  @override
  String get itemAddFoundEarlierBody => 'وُجد في مسح سابق';

  @override
  String get itemAddLookingAtPhoto => 'يُحلّل صورتك';

  @override
  String get itemAddExtractionFailedBody => 'فشل الاستخراج';

  @override
  String get itemAddJobFailedBody => 'فشل الإجراء';

  @override
  String get itemAddConnectionLostBody => 'انقطع الاتصال. حاول مرة أخرى.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'انقطع الاتصال أثناء المعالجة.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'القطعة $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'قطعة';

  @override
  String get itemAddNotCancelledTitle => 'لم تُلغَ';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قطع موجودة في خزانة الملابس.',
      one: 'قطعة واحدة موجودة في خزانة الملابس.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'حُفظت $saved من $total قطع. اضغط على حفظ لإعادة محاولة البقية.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'بعض القطع لم تُحفظ';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'اختر صورة واحدة على الأقل.';

  @override
  String get batchPhotoUnreadableBody => 'تعذّرت قراءة هذه الصورة.';

  @override
  String get batchNoPhotosReadableBody =>
      'تعذّرت قراءة أي من هذه الصور. جرّب صوراً أخرى.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صور',
      one: 'صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'انقطع الاتصال أثناء العمل. حاول مرة أخرى.';

  @override
  String get batchNotCancelledTitle => 'لم تُلغَ';

  @override
  String get batchPostLinkUnsupportedBody =>
      'روابط المنشورات غير مدعومة. أدخل رابط ملف شخصي.';

  @override
  String get batchLinkSpacesBody => 'لا يمكن أن تحتوي الروابط على مسافات.';

  @override
  String get batchEnterProfileLinkBody =>
      'أدخل رابط ملف شخصي على إنستغرام أو فيسبوك.';

  @override
  String get batchEnterProfileLinkShortBody => 'أدخل رابط ملف شخصي.';

  @override
  String get batchSignInPageNotOpenBody =>
      'لم تُفتح صفحة تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get batchSignInBrowserBody =>
      'سجّل الدخول في متصفحك ثم عد إلى FitCheck.';

  @override
  String get batchConnectAccountTitle => 'اربط حسابك';

  @override
  String get batchEnterAuthenticatorCodeBody => 'أدخل الرمز من تطبيق المصادقة.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram يريد فحص أمان. سجّل الدخول في متصفحك أولاً.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'أدخل اسم المستخدم وكلمة المرور مرة أخرى.';

  @override
  String get batchSignInFailedBody =>
      'فشل تسجيل الدخول. تحقق من اسم المستخدم وكلمة المرور.';

  @override
  String get batchSignInToKeepImportingBody => 'سجّل الدخول لمواصلة الاستيراد.';

  @override
  String get batchAccountNotConnectedBody => 'لم يتم ربط حسابك.';

  @override
  String get batchAccountConnectedTitle => 'تم ربط الحساب';

  @override
  String get batchNotConnectedTitle => 'غير مربوط';

  @override
  String get batchImportConnectionLostBody =>
      'فقدنا الاتصال بالاستيراد. حدّث للتحقق.';

  @override
  String batchPickUpToBody(int max) {
    return 'اختر حتى $max صورة. سنجد القطع.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count من $total صور';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'تجهيز الصورة $done من $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'البحث عن قطع في $count صور',
      one: 'البحث عن قطع في صورة واحدة',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'حساب $platform الخاص بك يستخدم تسجيل دخول بخطوتين. أدخل الرمز المكون من 6 أرقام من تطبيق المصادقة.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'هذه الملفات الشخصية لـ $platform خاصة أو تحتاج إلى تسجيل دخول لعرض الصور.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'اربط بواسطة $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count صور حتى الآن',
      one: 'تم العثور على صورة واحدة حتى الآن',
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
    return '$processed من $total تمت معالجتها · تمت إضافة $added · $waiting قيد الانتظار · تم تخطي $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'مسح الصورة $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'الصورة $number التالية';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'الصورة $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count قطع',
      one: 'تم العثور على قطعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count صور إلى خزانتك.',
      one: 'تمت إضافة صورة واحدة إلى خزانتك.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count صور استوديو إضافية في الطريق. يمكنك حفظ ما هو جاهز، أو المغادرة — سنبلغك.',
      one:
          'صورة استوديو أخرى في الطريق. يمكنك حفظ ما هو جاهز، أو المغادرة — سنبلغك.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'لم يُحفظ بعد: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces قطع',
      one: 'قطعة واحدة',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos صور',
      one: 'صورة واحدة',
    );
    return '$_temp0 من $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return 'تم اختيار $chosen. اضغط على قطعة لتخطيها.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حفظ $count قطع',
      one: 'حفظ قطعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حفظ $count قطع',
      one: 'حفظ قطعة',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'تم حفظ ملف جسمك.';

  @override
  String get bodyProfileSavedTitle => 'تم الحفظ';

  @override
  String get bodyProfileNotSavedTitle => 'لم يُحفظ';

  @override
  String get bodyProfileSetDefaultBody => 'اضبطه كملفك الافتراضي.';

  @override
  String get bodyProfileDeletedBody => 'تم حذف ملف الجسم.';

  @override
  String get bodyProfileDeletedTitle => 'تم الحذف';

  @override
  String get bodyProfileNotDeletedTitle => 'لم يُحذف';

  @override
  String get feedbackNotSentTitle => 'لم يُرسل';

  @override
  String get feedbackSentBody =>
      'شكراً لك. نقرأ كل رسالة ونرد إذا احتجنا تفاصيل أكثر.';

  @override
  String get feedbackSentTitle => 'تم إرسال الملاحظات';

  @override
  String get recommendUnnamedPiece => 'قطعة بدون اسم';

  @override
  String get recommendEnterCityBody =>
      'أدخل مدينتك للحصول على توصيات تناسب الطقس.';

  @override
  String get recommendWhichCityTitle => 'ما مدينتك؟';

  @override
  String get aiConsentSheetTitle => 'مشاركة الصور مع خدمة ذكاء اصطناعي';

  @override
  String get aiConsentSheetBody =>
      'لإنشاء صور تجريبية وتصوير، تُرسل FitCheck AI الصور التي تقدمها (بما فيها صور وجهك وجسمك) لمزود ذكاء اصطناعي موثوق (مثل OpenAI أو Google Gemini) لمعالجتها. يتم إنشاء صورك ولا تُستخدم لتدريب نماذجهم بموجب شروطنا. تُنقل الصور بأمان ولا تُشارك لأغراض إعلانية أبداً.';

  @override
  String get aiConsentSheetPermission =>
      'بالمتابعة، تمنح إذنًا صريحًا لمشاركة صورك مع مزودي الذكاء الاصطناعي هؤلاء لتوليد الصور.';

  @override
  String get skeletonsLoadMoreFailed => 'تعذر تحميل المزيد.';

  @override
  String get jobsPiecesReadyTitle => 'قطعك جاهزة';

  @override
  String get jobsScanStoppedTitle => 'تم إيقاف المسح';

  @override
  String get jobsNothingSavedBody => 'لم يتم حفظ أي شيء. حاول مرة أخرى.';

  @override
  String get jobsPhotoUploadFailedBody => 'فشل رفع الصورة.';

  @override
  String get authGoogleSignInStartFailed =>
      'تعذر بدء تسجيل الدخول عبر Google. حاول مرة أخرى.';

  @override
  String get referralAppliedTitle => 'تم تطبيق الإحالة!';

  @override
  String get billingStoreUnavailableBody =>
      'المشترات عبر المتجر غير متاحة على هذا الجهاز.';

  @override
  String get billingPurchaseProcessingBody =>
      'لا يزال هذا الشراء قيد المعالجة. أعد فتح التطبيق بعد دقيقة لرؤية خطتك.';

  @override
  String get profileAvatarUploadNoUrl =>
      'لم يُرجِع رفع الصورة الرمزية عنوان URL.';

  @override
  String get rewardsDayStreakLabel => 'يوم متتالٍ';

  @override
  String rewardsBestStreak(int days) {
    return 'أفضل $days أيام';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'مطلوب إذن الوصول إلى $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'الوصول إلى $permission مرفوض حالياً. افتح الإعدادات للسماح به، ثم عد وكرر المحاولة.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'الخطوة $step من 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'إزالة الصورة $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'إزالة الصورة $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points نقطة';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'راسلنا عبر $email. نراجع البلاغات خلال 24 ساعة.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'إزالة $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'إضافة إلى \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return 'تمت إزالة \"$name\". تبقى القطع في خزانتك.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'عرض الكل $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count متبقٍ اليوم';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'فشل التقاط صورة $index';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected من أصل $max صورة';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'بنية $shape · لون بشرة $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'خيارات $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'الأكثر ارتداءً: $name، $count مرات';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: غير مضبوط';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'توافق $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked من أصل $max مختار';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'إزالة $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'أولوية $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'يُستحصل على ثمن هذا الخطة عبر $store. قم بتعديلها أو إلغائها من إعدادات حساب $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'إدارة عبر $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: استخدام $current من $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'تبقّى حوالي $seconds ث';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return 'تم تجهيز $done من أصل $total صور الاستوديو';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return 'تم تجهيز $ready من أصل $total صور الاستوديو. المس قطعة لتجاوزها.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height سم · $weight كجم';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$label $value';
  }

  @override
  String get profileFieldNotSet => 'لا';
}
