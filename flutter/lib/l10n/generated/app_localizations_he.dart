// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'בית';

  @override
  String get tabPhotoshoot => 'צילום';

  @override
  String get tabCloset => 'ארון';

  @override
  String get tabOutfits => 'מערכות לבוש';

  @override
  String get tabMore => 'עוד';

  @override
  String get actionAddItem => 'הוסף פריט';

  @override
  String get actionCreateOutfit => 'צור מערכת לבוש';

  @override
  String get actionCancel => 'ביטול';

  @override
  String get actionDelete => 'מחיקה';

  @override
  String get actionSave => 'שמירה';

  @override
  String get actionRetry => 'נסה שוב';

  @override
  String get actionDone => 'סיום';

  @override
  String get actionNext => 'הבא';

  @override
  String get actionBack => 'חזור';

  @override
  String get actionClose => 'סגירה';

  @override
  String get actionSearch => 'חיפוש';

  @override
  String get actionContinue => 'המשך';

  @override
  String get stateLoading => 'טוען';

  @override
  String get stateErrorTitle => 'משהו השתבש';

  @override
  String get stateErrorBody => 'נסה שוב. אם התקלה נמשכת, פנה לתמיכה.';

  @override
  String get stateOfflineTitle => 'אתה במצב לא מקוון';

  @override
  String get stateOfflineBody =>
      'התחבר לאינטרנט כדי לסנכרן את הארון וליצור מערכות לבוש.';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get settingsAccountSection => 'חשבון';

  @override
  String get settingsPreferencesSection => 'העדפות';

  @override
  String get settingsPlanBilling => 'תוכנית וחיוב';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsNotifications => 'התראות';

  @override
  String get settingsUnits => 'יחידות מידה';

  @override
  String get settingsAppearance => 'מראה';

  @override
  String get settingsPrivacySection => 'פרטיות ונתונים';

  @override
  String get settingsAboutSection => 'אודות';

  @override
  String get settingsSignOut => 'התנתקות';

  @override
  String get settingsDeleteAccount => 'מחיקת חשבון';

  @override
  String get settingsDeleteAccountTitle => 'למחוק את החשבון?';

  @override
  String get settingsDeleteAccountBody =>
      'פעולה זו תמחק את הארון, התלבושות, התמונות והפרופיל שלך. לא ניתן לבטל זאת.';

  @override
  String get settingsUnitsImperial => 'אימפריאלי (אינץ\', ליברות)';

  @override
  String get settingsUnitsMetric => 'מטרי (ס\"מ, ק\"ג)';

  @override
  String get languageTitle => 'שפה';

  @override
  String get languageSystem => 'השתמש בשפת המכשיר';

  @override
  String get languageSystemBody => 'FitCheck AI משתמשת בשפת הטלפון שלך.';

  @override
  String get languageSearchHint => 'חיפוש שפות';

  @override
  String get languageCurrent => 'נוכחית';

  @override
  String get languageReviewNote =>
      'תרגום זה חדש. דווח לנו אם משהו נשמע לא תקין.';

  @override
  String get languageChanged => 'השפה עודכנה';

  @override
  String get paywallTitle => 'בחירת תוכנית';

  @override
  String get paywallTrialBadge => 'חודש ראשון חינם';

  @override
  String get paywallTrialTitle => 'חודש ראשון ב-Pro בחינם';

  @override
  String get paywallTrialBody =>
      'העלה את כל הארון שלך בבת אחת. לאחר מכן, הוסף פריטים תוך כדי תנועה.';

  @override
  String get paywallFreeForeverTitle => 'חינם לתמיד';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'ללא צורך בכרטיס אשראי. בכל חודש תקבל $uploads העלאות AI, $outfits תלבושות ו-$images תמונות צילום ביום.';
  }

  @override
  String get paywallCtaTrial => 'התחל את החודש בחינם';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'שדרוג ל-$plan';
  }

  @override
  String get paywallRestore => 'שחזור רכישות';

  @override
  String get paywallManage => 'ניהול מנוי';

  @override
  String get paywallTerms => 'תנאי שימוש';

  @override
  String get paywallPrivacy => 'מדיניות פרטיות';

  @override
  String get paywallPerMonth => 'לחודש';

  @override
  String get paywallPerYear => 'לשנה';

  @override
  String get paywallBestValue => 'המשתלם ביותר';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'ניסיון חינם למנויים חדשים בלבד. לאחר תקופת הניסיון, מנוי Pro יתחדש ב-$price אלא אם יבוטל לפחות 24 שעות לפני סיומו.';
  }

  @override
  String get introTitle => 'הארון שלך, סוף סוף מאורגן';

  @override
  String get introBody =>
      'צלמו את הבגדים שלכם פעם אחת. קבלו רעיונות ללוקים, תצוגה מקדימה של מדידה ותמונות סטודיו ממה שכבר יש לכם.';

  @override
  String get introStart => 'מתחילים';

  @override
  String get introHaveAccount => 'יש לי כבר חשבון';

  @override
  String get introSkip => 'דילוג';

  @override
  String get authSignIn => 'התחברות';

  @override
  String get authSignUp => 'יצירת חשבון';

  @override
  String get authEmail => 'אימייל';

  @override
  String get authPassword => 'סיסמה';

  @override
  String get authForgotPassword => 'שכחת סיסמה?';

  @override
  String get authContinueApple => 'המשך עם Apple';

  @override
  String get authContinueGoogle => 'המשך עם Google';

  @override
  String get authOrDivider => 'או';

  @override
  String get wardrobeTitle => 'ארון';

  @override
  String get wardrobeEmptyTitle => 'הארון שלך ריק';

  @override
  String get wardrobeEmptyBody =>
      'הוסיפו את הפריט הראשון, או העלו תמונה של כל הקולב בבת אחת.';

  @override
  String get wardrobeAddFirst => 'הוספת פריט ראשון';

  @override
  String get wardrobeSearchHint => 'חיפוש בארון';

  @override
  String get categoryTops => 'חולצות';

  @override
  String get categoryBottoms => 'מכנסיים וחצאיות';

  @override
  String get categoryShoes => 'נעליים';

  @override
  String get categoryAccessories => 'אקססוריז';

  @override
  String get categoryOuterwear => 'הלבשה עליונה';

  @override
  String get categorySwimwear => 'בגדי ים';

  @override
  String get categoryActivewear => 'בגדי ספורט';

  @override
  String get categoryOther => 'אחר';

  @override
  String get conditionClean => 'נקי';

  @override
  String get conditionDirty => 'מלוכלך';

  @override
  String get conditionLaundry => 'בכביסה';

  @override
  String get conditionRepair => 'דורש תיקון';

  @override
  String get conditionDonate => 'לתרומה';

  @override
  String get seasonSpring => 'אביב';

  @override
  String get seasonSummer => 'קיץ';

  @override
  String get seasonFall => 'סתיו';

  @override
  String get seasonWinter => 'חורף';

  @override
  String get seasonAll => 'כל העונות';

  @override
  String get styleCasual => 'יומיומי';

  @override
  String get styleFormal => 'רשמי';

  @override
  String get styleBusiness => 'עסקי';

  @override
  String get styleSporty => 'ספורטיבי';

  @override
  String get styleBohemian => 'בוהו';

  @override
  String get styleStreetwear => 'סטריט';

  @override
  String get styleVintage => 'וינטג\'';

  @override
  String get styleMinimalist => 'מינימליסטי';

  @override
  String get styleRomantic => 'רומנטי';

  @override
  String get styleEdgy => 'נועז';

  @override
  String get stylePreppy => 'פרפי';

  @override
  String get styleArtsy => 'אמנותי';

  @override
  String get styleClassic => 'קלאסי';

  @override
  String get styleElegant => 'אלגנטי';

  @override
  String get styleOther => 'אחר';

  @override
  String get occasionWork => 'עבודה';

  @override
  String get occasionDateNight => 'דייט';

  @override
  String get occasionTravel => 'טיול';

  @override
  String get occasionWedding => 'חתונה';

  @override
  String get occasionGym => 'חדר כושר';

  @override
  String get occasionWeekend => 'סופ\"ש';

  @override
  String get occasionParty => 'מסיבה';

  @override
  String get occasionInterview => 'ראיון עבודה';

  @override
  String get colorBlack => 'שחור';

  @override
  String get colorWhite => 'לבן';

  @override
  String get colorGrey => 'אפור';

  @override
  String get colorNavy => 'כחול נייבי';

  @override
  String get colorBrown => 'חום';

  @override
  String get colorRed => 'אדום';

  @override
  String get colorBlue => 'כחול';

  @override
  String get colorGreen => 'ירוק';

  @override
  String get colorPink => 'ורוד';

  @override
  String get colorPurple => 'סגול';

  @override
  String get colorYellow => 'צהוב';

  @override
  String get colorOrange => 'כתום';

  @override
  String get colorBeige => 'בז\'';

  @override
  String get dateToday => 'היום';

  @override
  String get dateYesterday => 'אתמול';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count ימים',
      one: 'לפני יום אחד',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count שבועות',
      one: 'לפני שבוע אחד',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count חודשים',
      one: 'לפני חודש אחד',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'לפני $count שנים',
      one: 'לפני שנה אחת',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'נהנה מ-FitCheck AI?';

  @override
  String get ratingPromptBody => 'דירוג מהיר עוזר לאחרים למצוא את הסטייל שלהם.';

  @override
  String get ratingPromptYes => 'דרג את האפליקציה';

  @override
  String get ratingPromptNo => 'לא עכשיו';

  @override
  String get closetNoMatchesTitle => 'אין פריטים תואמים';

  @override
  String get closetNoMatchesBody => 'נסה להסיר פילטרים או לחפש שוב.';

  @override
  String get closetClearFilters => 'נקה פילטרים';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פריטים',
      one: 'פריט אחד',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'טוען את הפריטים שלך';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פריטים נבחרו',
      one: 'פריט אחד נבחר',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'מחיקת פריטים נבחרים';

  @override
  String get closetCancelSelection => 'ביטול בחירה';

  @override
  String get closetCloseSearch => 'סגירת חיפוש';

  @override
  String get closetShowGrid => 'תצוגת רשת';

  @override
  String get closetShowList => 'תצוגת רשימה';

  @override
  String get closetShowRows => 'תצוגת שורות';

  @override
  String get closetStatsTitle => 'סטטיסטיקות ארון';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'למחוק $count פריטים?',
      one: 'למחוק פריט 1?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'פריטים אלו יוסרו מהאאוטפיטים שמשתמשים בהם.';

  @override
  String get closetSortBy => 'מיון לפי';

  @override
  String get closetFavourites => 'מועדפים';

  @override
  String get closetFavourite => 'הוספה למועדפים';

  @override
  String get closetUnfavourite => 'הסרה מהמועדפים';

  @override
  String get closetWoreToday => 'נלבש היום';

  @override
  String closetWornTimes(int count) {
    return 'נלבש $count×';
  }

  @override
  String get closetCategoryLabel => 'קטגוריה';

  @override
  String get closetUseCaseLabel => 'שימוש';

  @override
  String get closetAnyUseCase => 'הכל';

  @override
  String get closetOtherUseCase => 'שימוש אחר';

  @override
  String get closetOtherUseCaseHint => 'למשל, בראנץ\'';

  @override
  String get closetUseUseCase => 'שימוש זה';

  @override
  String get closetClearAll => 'ניקוי הכל';

  @override
  String get sortNewest => 'חדש ביותר';

  @override
  String get sortOldest => 'ישן ביותר';

  @override
  String get sortName => 'שם (א-ת)';

  @override
  String get sortMostWorn => 'הכי הרבה בשימוש';

  @override
  String get useCaseInformal => 'יומיומי';

  @override
  String get useCaseDate => 'דייט';

  @override
  String get useCaseDinner => 'ארוחת ערב';

  @override
  String get useCaseLunch => 'ארוחת צהריים';

  @override
  String get actionSelect => 'בחירה';

  @override
  String get actionEdit => 'עריכה';

  @override
  String get actionFilter => 'סינון';

  @override
  String get actionSort => 'מיון';

  @override
  String get actionAll => 'הכל';

  @override
  String get dashboardStartClosetTitle => 'התחילו את המלתחה';

  @override
  String get dashboardStartClosetBody =>
      'צלמו כמה פריטים. אנחנו נתייג אותם עבורכם.';

  @override
  String get dashboardPieces => 'פריטים';

  @override
  String get dashboardOutfits => 'אאוטפיטים';

  @override
  String get dashboardDayStreak => 'רצף ימים';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count החודש';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'שיא של $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פריטים מועדפים',
      one: 'פריט מועדף 1',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count אאוטפיטים שמורים',
      one: 'אאוטפיט 1 שמור',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'הכי נלבש: $name, $count פעמים';
  }

  @override
  String get setupSkip => 'דילוג על הגדרה';

  @override
  String get setupWhoTitle => 'עבור מי הסטיילינג?';

  @override
  String get setupWhoBody =>
      'קובע את הדגם למדידה וצילומים. ניתן לשנות זאת בפרופיל.';

  @override
  String get setupStyleTitle => 'מה אתם לובשים הכי הרבה?';

  @override
  String get setupStyleBody =>
      'בחרו כל סגנון. רעיונות לאאוטפיטים יתבססו על אלו.';

  @override
  String get setupClosetTitle => 'הוסיפו את הפריטים הראשונים.';

  @override
  String get setupClosetBody =>
      'צלמו כמה בגדים, או ערימה שלהם. כל פריט יגזר ויתויק עבורכם.';

  @override
  String get setupAddClothes => 'הוספת בגדים';

  @override
  String get setupStylesLabel => 'סגנונות';

  @override
  String get setupOccasionsLabel => 'אירועים';

  @override
  String get setupSkipStep => 'דילוג';

  @override
  String get setupLater => 'אחר כך';

  @override
  String get setupSaveError => 'לא ניתן לשמור';

  @override
  String get genderWomen => 'נשים';

  @override
  String get genderMen => 'גברים';

  @override
  String get genderNonBinary => 'א-בינארי';

  @override
  String get genderPreferNotToSay => 'מעדיף לא לציין';

  @override
  String get outfitEmptyTitle => 'אין עדיין תלבושות';

  @override
  String get outfitEmptyBody => 'שלבו פריטים מהארון ושמרו את המראה.';

  @override
  String get outfitNoMatchesTitle => 'אין תלבושות תואמות';

  @override
  String get outfitSearchHint => 'חיפוש בתלבושות';

  @override
  String get outfitLoading => 'טוען תלבושות';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תלבושות',
      one: 'תלבושת אחת',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'סגנון ועונה';

  @override
  String get outfitCollections => 'אוספים';

  @override
  String get outfitDuplicate => 'שכפול';

  @override
  String get outfitDeleteTitle => 'למחוק את התלבושת?';

  @override
  String get outfitDeleteBody => 'הפריטים יישארו בארון שלך.';

  @override
  String get outfitDrafts => 'טיוטות';

  @override
  String get outfitDraft => 'טיוטה';

  @override
  String get filterStyle => 'סגנון';

  @override
  String get filterSeason => 'עונה';

  @override
  String get itemDetailDeleteTitle => 'למחוק את הפריט?';

  @override
  String get itemDetailDeleteBody => 'הפריט יוסר מכל התלבושות שבהן הוא מופיע.';

  @override
  String get itemAddFavourite => 'הוספה למועדפים';

  @override
  String itemSize(String size) {
    return 'מידה $size';
  }

  @override
  String get itemColours => 'צבעים';

  @override
  String get itemMaterial => 'חומר';

  @override
  String get itemPattern => 'דוגמה';

  @override
  String get itemUseCases => 'שימושים';

  @override
  String get itemKeptIn => 'נמצא ב';

  @override
  String get itemPrice => 'מחיר';

  @override
  String get itemBought => 'נרכש';

  @override
  String get itemTags => 'תגיות';

  @override
  String get itemAdded => 'נוסף';

  @override
  String get itemTimesWornLabel => 'פעמים בשימוש';

  @override
  String get itemLastWornLabel => 'שימוש אחרון';

  @override
  String get itemNeverWorn => 'מעולם לא';

  @override
  String get authEntryBody =>
      'כל פריט שיש לך, בעיצוב AI. תכנני אאוטפיטים, מדדי אותם, צלמי אותם.';

  @override
  String get authCreateCloset => 'יצירת ארון בגדים';

  @override
  String get authWelcomeBack => 'ברוכה הבאה';

  @override
  String get authSignInBody => 'התחברי כדי לפתוח את הארון שלך.';

  @override
  String get authCreateAccount => 'יצירת חשבון';

  @override
  String get authCreateClosetBody => 'זה לוקח דקה. הפריטים הראשונים שלך בחינם.';

  @override
  String get authName => 'שם';

  @override
  String get authConfirmPassword => 'אימות סיסמה';

  @override
  String get authReferralCode => 'קוד הפניה (אופציונלי)';

  @override
  String get authResetTitle => 'איפוס סיסמה';

  @override
  String get authResetBody => 'נשלח לך קישור למייל כדי לבחור סיסמה חדשה.';

  @override
  String get authSendResetLink => 'שליחת קישור לאיפוס';

  @override
  String get authBackToSignIn => 'חזרה להתחברות';

  @override
  String get authEnterEmail => 'הזיני אימייל';

  @override
  String get authEnterValidEmail => 'הזיני אימייל תקין';

  @override
  String get authEnterPassword => 'הזיני סיסמה';

  @override
  String get authPasswordTooShort => 'לפחות 6 תווים';

  @override
  String get authShowPassword => 'הצגת סיסמה';

  @override
  String get authHidePassword => 'הסתרת סיסמה';

  @override
  String get authNewHere => 'חדשה כאן?';

  @override
  String authConfirmEmail(String email) {
    return 'אמתי את $email לפני ההתחברות. בדקי את תיבת הדואר הנכנס.';
  }

  @override
  String get authResendEmail => 'שליחה שוב';

  @override
  String get authResendingEmail => 'שולח...';

  @override
  String get authPasswordsDoNotMatch => 'הסיסמאות אינן תואמות';

  @override
  String get authEnterName => 'הזיני את שמך';

  @override
  String get authChoosePassword => 'בחרי סיסמה';

  @override
  String get authHaveAccount => 'יש לך חשבון?';

  @override
  String get authCodeAccepted => 'הקוד התקבל';

  @override
  String get authCodeNotFound => 'הקוד לא נמצא';

  @override
  String authReferralFrom(String name) {
    return 'מאת $name. שניכם מקבלים חודש חינם.';
  }

  @override
  String get authReferralInvalid => 'לא הצלחנו למצוא את הקוד הזה.';

  @override
  String authResetSent(String email) {
    return 'נשלח ל-$email. פתחו את הקישור בטלפון זה.';
  }

  @override
  String get introSlide1Title => 'צלמו את הארון פעם אחת';

  @override
  String get introSlide1Body => 'צלמו ערימת בגדים. כל פריט יגזר ויתויג עבורכם.';

  @override
  String get introSlide2Title => 'מתלבשים מהר יותר';

  @override
  String get introSlide2Body =>
      'שילובים ממה שיש לכם, מותאמים לתוכניות ולמזג האוויר.';

  @override
  String get introSlide3Title => 'ראו את זה לפני שתלבשו';

  @override
  String get introSlide3Body =>
      'נסו מראות על תמונה שלכם, או צלמו אותם כמו קמפיין.';

  @override
  String get settingsTheme => 'ערכת נושא';

  @override
  String get settingsThemeSystem => 'מערכת';

  @override
  String get settingsThemeLight => 'בהיר';

  @override
  String get settingsThemeDark => 'כהה';

  @override
  String get settingsTemperature => 'טמפרטורה';

  @override
  String get settingsEmailUpdates => 'עדכונים במייל';

  @override
  String get settingsEmailUpdatesBody => 'חדשות וטיפים במייל';

  @override
  String get settingsOutfitReminders => 'תזכורות לבוש';

  @override
  String get settingsOutfitRemindersBody => 'תזכורת לתעד מה לבשתם';

  @override
  String get settingsWeeklySummary => 'סיכום שבועי';

  @override
  String get settingsWeeklySummaryBody => 'השבוע שלכם במראות';

  @override
  String get settingsStyleSection => 'סגנון';

  @override
  String get settingsPreferredStyles => 'סגנונות שאתם אוהבים';

  @override
  String get settingsPreferredColours => 'צבעים שאתם אוהבים';

  @override
  String get settingsNoneChosen => 'לא נבחר דבר';

  @override
  String get settingsPlanAiSection => 'תוכנית ו-AI';

  @override
  String get settingsPlanBillingBody => 'תוכנית, שימוש ושדרוגים';

  @override
  String get settingsPlanUsageBody => 'תוכנית ושימוש';

  @override
  String get settingsInviteFriends => 'הזמינו חברים';

  @override
  String get settingsInviteFriendsBody => 'חודש חינם על כל חבר שיצטרף';

  @override
  String get settingsAiProvider => 'ספק AI';

  @override
  String get settingsAiProviderBody => 'השתמש במודל משלך לתיוג ותמונות';

  @override
  String get settingsAppVersion => 'גרסת אפליקציה';

  @override
  String get settingsPrivacyTerms => 'פרטיות ותנאי שימוש';

  @override
  String get settingsReportProblem => 'דיווח על בעיה';

  @override
  String get settingsChangePassword => 'שינוי סיסמה';

  @override
  String get settingsExportData => 'ייצוא הנתונים שלך';

  @override
  String get settingsExportBody => 'נכין קובץ עם כל מה ששמרת ונפתח את ההורדה.';

  @override
  String get settingsExportAction => 'ייצוא';

  @override
  String get settingsCurrentPassword => 'סיסמה נוכחית';

  @override
  String get settingsNewPassword => 'סיסמה חדשה';

  @override
  String get settingsConfirmNewPassword => 'אימות סיסמה חדשה';

  @override
  String get settingsEnterCurrentPassword => 'הזן את הסיסמה הנוכחית';

  @override
  String get settingsEnterNewPassword => 'הזן סיסמה חדשה';

  @override
  String get settingsPasswordMin8 => 'השתמש ב-8 תווים לפחות';

  @override
  String get settingsPasswordNeedsUpper => 'הוסף אות גדולה';

  @override
  String get settingsPasswordNeedsLower => 'הוסף אות קטנה';

  @override
  String get settingsPasswordNeedsDigit => 'הוסף ספרה';

  @override
  String get settingsPasswordsNoMatch => 'הסיסמאות אינן תואמות';

  @override
  String get settingsChangeAction => 'שינוי';

  @override
  String get itemAddSnapTitle => 'צלם פריט';

  @override
  String get itemAddSnapBody =>
      'נזהה כל פריט בתמונה וניצור צילום סטודיו נקי לכל אחד.';

  @override
  String get itemAddCamera => 'צלם תמונה';

  @override
  String get itemAddGallery => 'בחר מהגלריה';

  @override
  String get itemAddOtherWays => 'דרכים נוספות להוספה';

  @override
  String get itemAddSeveral => 'הוסף מספר תמונות';

  @override
  String get itemAddSeveralBody => 'עד 50 בבת אחת';

  @override
  String get itemAddImportProfile => 'ייבוא מפרופיל';

  @override
  String get itemAddImportProfileBody => 'אינסטגרם או פייסבוק';

  @override
  String get itemAddEnterDetails => 'הזנת פרטים ידנית';

  @override
  String get itemAddEnterDetailsBody => 'אין צורך בתמונה';

  @override
  String get itemManualIntro =>
      'רק שם נדרש. ניתן להוסיף את השאר עכשיו או מאוחר יותר.';

  @override
  String get itemManualNameHint => 'למשל, טי-שירט כותנה כחולה';

  @override
  String get itemManualEnterName => 'הזן שם';

  @override
  String get itemManualNotes => 'הערות';

  @override
  String get itemManualBrand => 'מותג';

  @override
  String get itemManualSize => 'מידה';

  @override
  String get itemManualEnterNumber => 'הזן מספר';

  @override
  String get itemManualSavePiece => 'שמור פריט';

  @override
  String get itemManualSaving => 'שומר';

  @override
  String get itemManualSavedTitle => 'נשמר';

  @override
  String itemManualSavedBody(String name) {
    return '$name נמצא בארון שלך.';
  }

  @override
  String get itemManualNotSaved => 'לא נשמר';

  @override
  String get itemManualAddUseCase => 'הוסף שימוש';

  @override
  String get itemManualAddUseCaseAction => 'הוסף שימוש';

  @override
  String get itemPhotos => 'תמונות';

  @override
  String get itemAddPhotos => 'הוסף תמונות';

  @override
  String get itemNoPhotoYet => 'אין תמונה עדיין. ניתן לשמור ללא תמונה.';

  @override
  String get itemRemovePhoto => 'הסר תמונה';

  @override
  String get itemRemovePiece => 'הסר פריט';

  @override
  String get filterConditionLabel => 'מצב הפריט';

  @override
  String get photoshootStepPhotos => 'תמונות';

  @override
  String get photoshootStepSetup => 'הגדרה';

  @override
  String get photoshootStepCreating => 'יוצר';

  @override
  String get photoshootStepResults => 'תוצאות';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'שלב $current מתוך $total, $name';
  }

  @override
  String get photoshootOneFailed => 'תמונה אחת נכשלה. נסה שוב למטה.';

  @override
  String photoshootManyFailed(int count) {
    return '$count תמונות נכשלו. נסה שוב כל אחת למטה.';
  }

  @override
  String get photoshootFormat => 'פורמט';

  @override
  String get photoshootHowMany => 'כמה';

  @override
  String get photoshootYourPrompt => 'ההנחיה שלך';

  @override
  String get photoshootPromptHint => 'שעת הזהב על גג, חולצת פשתן';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'צור $count תמונות',
      one: 'צור תמונה 1',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'תמונות',
      one: 'תמונה',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'לא הצלחנו לבדוק את המכסה להיום.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'תוכנית $plan: נותרו $remaining מתוך $limit להיום';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'חינמית';

  @override
  String get photoshootGallery => 'גלריה';

  @override
  String get photoshootUseCamera => 'השתמש במצלמה';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'הסר תמונה $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'לא התקבלו תמונות';

  @override
  String get photoshootNoPhotosBody => 'הצילום הסתיים ללא תמונות. נסה שוב.';

  @override
  String get photoshootNewStyle => 'סגנון חדש';

  @override
  String get photoshootNewPhotos => 'תמונות חדשות';

  @override
  String photoshootOpenPhoto(int number) {
    return 'פתח תמונה $number';
  }

  @override
  String get photoshootReportPhoto => 'דווח על תמונה';

  @override
  String get photoshootSaveToGallery => 'שמור לגלריה';

  @override
  String get actionUpgrade => 'שדרוג';

  @override
  String get referralLimitTitle => 'ניצלת את מכסת התמונות להיום';

  @override
  String get referralLimitBody =>
      'המכסה החינמית תתחדש מחר. הזמן חבר ושניכם תקבלו חודש Pro בחינם.';

  @override
  String get referralLimitRefer => 'הזמן חבר';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'אפליקציית היכרויות';

  @override
  String get photoshootUsePortfolio => 'תיק עבודות';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'אסתטיקה';

  @override
  String get photoshootUseCustom => 'הנחיה אישית';

  @override
  String get photoshootDescLinkedin => 'תמונות פרופיל מקצועיות לעבודה';

  @override
  String get photoshootDescDating => 'נינוח, חם וטבעי';

  @override
  String get photoshootDescPortfolio => 'אופנתי, מראה מגזיני';

  @override
  String get photoshootDescInstagram => 'תמונות לייף סטייל לפיד';

  @override
  String get photoshootDescAesthetic => 'אמנותי, אווירה מיוחדת';

  @override
  String get photoshootDescCustom => 'תאר את המראה הרצוי';

  @override
  String get aspectSquare => 'ריבוע';

  @override
  String get aspectPortrait => 'פורטרט';

  @override
  String get aspectLandscape => 'נוף';

  @override
  String get aspectTall => 'גבוה';

  @override
  String get aspectWide => 'רחב';

  @override
  String get tryOnAppBar => 'מדידה וירטואלית';

  @override
  String get tryOnYourPhoto => 'התמונה שלך';

  @override
  String get tryOnGarment => 'פריט לבוש';

  @override
  String get tryOnUploadingPhoto => 'מעלה את התמונה שלך';

  @override
  String get tryOnAddPhotoPrompt => 'הוסף תמונת גוף מלאה';

  @override
  String get tryOnBodyPhotoHint => 'תמונת גוף מלא עובדת הכי טוב';

  @override
  String get tryOnAddPhoto => 'הוסף תמונה';

  @override
  String get tryOnChangePhoto => 'שנה תמונה';

  @override
  String get tryOnPhotoLoadFailed => 'לא הצלחנו לטעון את התמונה.';

  @override
  String get tryOnChooseGarment => 'בחר תמונת פריט לבוש';

  @override
  String get tryOnChooseOneGarment => 'בחר תמונת פריט אחד';

  @override
  String get tryOnGarmentHint => 'צילום על קולב או משטח עובד הכי טוב';

  @override
  String get tryOnChange => 'שנה';

  @override
  String get tryOnCamera => 'מצלמה';

  @override
  String get tryOnRemove => 'הסר';

  @override
  String get tryOnLookTitle => 'מראה';

  @override
  String get tryOnStyle => 'סגנון';

  @override
  String get tryOnBackground => 'רקע';

  @override
  String get tryOnPose => 'תנוחה';

  @override
  String get tryOnDressingUp => 'מלביש אותך. זה לוקח כחצי דקה.';

  @override
  String get tryOnEmptyResult => 'הניסיונות שלך יופיעו כאן';

  @override
  String get tryOnReportImage => 'דיווח על תמונה';

  @override
  String get tryOnCreating => 'יוצר';

  @override
  String get tryOnTryAgain => 'נסה שוב';

  @override
  String get tryOnCreate => 'צור ניסיון';

  @override
  String get tryOnBackgroundStudioWhite => 'סטודיו לבן';

  @override
  String get tryOnBackgroundStudioGrey => 'סטודיו אפור';

  @override
  String get tryOnBackgroundUrban => 'רחוב עירוני';

  @override
  String get tryOnBackgroundNature => 'טבע';

  @override
  String get tryOnBackgroundMinimal => 'מינימליסטי';

  @override
  String get tryOnPoseFront => 'עמידה חזיתית';

  @override
  String get tryOnPoseSide => 'עמידה מהצד';

  @override
  String get tryOnPoseWalking => 'הליכה';

  @override
  String get dashboardGreetingMorning => 'בוקר טוב';

  @override
  String get dashboardGreetingAfternoon => 'צהריים טובים';

  @override
  String get dashboardGreetingEvening => 'ערב טוב';

  @override
  String get dashboardWelcome => 'ברוך הבא';

  @override
  String get dashboardOpenProfile => 'פתח פרופיל';

  @override
  String get dashboardRailToday => 'היום';

  @override
  String get dashboardRailRecently => 'לאחרונה';

  @override
  String get dashboardActivityEmpty => 'פריטים ואאוטפיטים חדשים יופיעו כאן.';

  @override
  String get quickAddPiece => 'הוסף פריט';

  @override
  String get quickAddPieceBody => 'צלם ותייג';

  @override
  String get quickBuildOutfit => 'צור אאוטפיט';

  @override
  String get quickBuildOutfitBody => 'ערבב פריטים';

  @override
  String get quickForYou => 'בשבילך';

  @override
  String get quickForYouBody => 'בחירות להיום';

  @override
  String get quickPlanWeek => 'תכנן את השבוע';

  @override
  String get quickPlanWeekBody => 'אאוטפיטים לפי תאריך';

  @override
  String get referralBannerUrgent => 'נגמר לך? הזמן חבר.';

  @override
  String get referralBannerTitle => 'תנו חודש, קבלו חודש';

  @override
  String get referralBannerBody => 'אתם וחברכם תקבלו חודש של Pro';

  @override
  String get referralBannerDismiss => 'הסתר לשבוע';

  @override
  String get referralBannerShare => 'שיתוף הזמנה';

  @override
  String get referralBannerCopy => 'העתקת קישור';

  @override
  String get itemEditPieceTitle => 'עריכת פריט';

  @override
  String get itemEditDescriptionLabel => 'תיאור';

  @override
  String get itemEditNotSaved => 'לא נשמר';

  @override
  String get itemEditSavedTitle => 'נשמר';

  @override
  String get itemEditSavedBody => 'השינויים נשמרו';

  @override
  String get itemEditSavedStalePhotos => 'נשמר — ייתכן שהתמונות לא מעודכנות';

  @override
  String get itemEditRemovePieceHint => 'מחיקת פריט זה מדף הפריטים';

  @override
  String get itemEditNoPhotos => 'אין עדיין תמונות. הוסיפו מהגלריה או מהמצלמה';

  @override
  String get itemEditKeepPhoto => 'שמירת תמונה';

  @override
  String get itemEditRemoved => 'הוסר';

  @override
  String get itemEditAddUseCaseAction => 'הוספה';

  @override
  String get statsNoStatsTitle => 'אין עדיין נתונים';

  @override
  String get statsNoStatsBody =>
      'הוסיפו כמה פריטים והרכב המלתחה שלכם יופיע כאן';

  @override
  String get statsByCategory => 'לפי קטגוריה';

  @override
  String get statsTotalValue => 'ערך כולל';

  @override
  String get statsMostWorn => 'הכי בשימוש';

  @override
  String get statsLeastWorn => 'מחכה לתורו';

  @override
  String get statsUnnamedPiece => 'פריט ללא שם';

  @override
  String get jobsTitle => 'סריקות';

  @override
  String get jobsEmptyTitle => 'אין עדיין סריקות';

  @override
  String get jobsEmptyBody =>
      'צלמו פריט והשאירו את העבודה ברקע — זה ממשיך לעבוד כאן';

  @override
  String get jobsNotCancelled => 'לא בוטל';

  @override
  String get jobsResume => 'המשך';

  @override
  String get jobsReview => 'סקירה';

  @override
  String get jobsStop => 'עצירה';

  @override
  String get jobsDismiss => 'התעלם';

  @override
  String get reportTitle => 'דיווח על תוכן';

  @override
  String reportIntro(String contentType) {
    return 'ספר לנו מה לא תקין ב-$contentType. הצוות שלנו בודק כל דיווח.';
  }

  @override
  String get reportReasonInappropriate => 'תוכן לא הולם או פוגעני';

  @override
  String get reportReasonNudity => 'עירום או תוכן מיני';

  @override
  String get reportReasonHarassment => 'הטרדה או התעללות';

  @override
  String get reportReasonImpersonation => 'התחזות';

  @override
  String get reportReasonOther => 'אחר';

  @override
  String get reportDetailsLabel => 'פרטים נוספים (אופציונלי)';

  @override
  String get reportSubmit => 'שלח דיווח';

  @override
  String get reportSubmittedTitle => 'הדיווח נשלח';

  @override
  String get reportSubmittedBody => 'תודה. הצוות שלנו יבדוק את התוכן.';

  @override
  String get reportFailedTitle => 'הדיווח לא נשלח';

  @override
  String get reportFailedBody => 'אנא נסה שוב.';

  @override
  String get reportContentTryOnImage => 'תמונת מדידה וירטואלית';

  @override
  String get reportContentSharedOutfit => 'אאוטפיט משותף';

  @override
  String get reportContentPhotoshootImage => 'תמונת צילום AI';

  @override
  String get sharedOutfitTitle => 'אאוטפיט משותף';

  @override
  String get sharedOutfitHideTooltip => 'הסתר אאוטפיט זה';

  @override
  String get sharedOutfitReportTooltip => 'דווח על אאוטפיט זה';

  @override
  String get sharedOutfitHideTitle => 'להסתיר את האאוטפיט?';

  @override
  String get sharedOutfitHideBody =>
      'הוא יוסתר במכשיר זה. ניתן גם לדווח עליו כדי שהצוות שלנו יבדוק ויסיר אותו.';

  @override
  String get sharedOutfitHideAction => 'הסתר';

  @override
  String get sharedOutfitHiddenInfo => 'אאוטפיט זה לא יוצג שוב במכשיר זה.';

  @override
  String get sharedOutfitHiddenToast => 'האאוטפיט הוסתר';

  @override
  String get sharedOutfitMissingTitle => 'האאוטפיט הזה כבר לא כאן';

  @override
  String get sharedOutfitMissingBody => 'ייתכן שהוא הוסר או שהקישור שגוי.';

  @override
  String get sharedOutfitHiddenStateTitle => 'הסתרת את האאוטפיט הזה';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'אם התוכן פוגעני, דווח עליו דרך פרטיות ותנאים או שלח אימייל ל-$email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'אהבת את הלוק?';

  @override
  String get sharedOutfitCtaBody => 'צור אאוטפיטים דומים מהארון שלך.';

  @override
  String get sharedOutfitCtaButton => 'הורד את FitCheck AI';

  @override
  String get errorTitle => 'שגיאה';

  @override
  String get errorUnknown => 'אירעה שגיאה בלתי צפויה';

  @override
  String get errorNoConnection => 'אין חיבור לאינרנט. נא לבדוק את הרשת.';

  @override
  String get errorTimeout => 'פסק זמן בקשה. נא לנסות שוב.';

  @override
  String get errorServerError => 'משהו השתבש בצד שלנו. נא לנסות שוב.';

  @override
  String get errorBadGateway => 'השרת אינו זמין זמנית. נא לנסות שוב.';

  @override
  String get errorServiceUnavailable =>
      'השירות אינו זמין זמנית. נא לנסות שוב בקרוב.';

  @override
  String get errorInternalError => 'משהו השתבש. נא לנסות שוב.';

  @override
  String get errorUnauthorized => 'נא להתחבר כדי להמשיך.';

  @override
  String get errorForbidden => 'אין לך גישה לכך.';

  @override
  String get errorSessionExpired => 'הפגישה פגה. נא להתחבר מחדש.';

  @override
  String get errorInvalidCredentials => 'כתובת האימייל או הסיסמה אינם נכונים.';

  @override
  String get errorTokenRefreshFailed =>
      'לא הצלחנו לחדש את הפגישה. נא להתחבר מחדש.';

  @override
  String get errorRequestCancelled => 'הבקשה בוטלה.';

  @override
  String get errorInvalidFormat => 'פורמט הקובץ אינו נתמך.';

  @override
  String get errorFileTooLarge => 'הקובץ גדול מדי.';

  @override
  String get errorUploadFailed => 'ההעלאה נכשלה. נא לנסות שוב.';

  @override
  String get errorCacheCorrupted => 'הנתונים השמורים ניזוקו ואופסו.';

  @override
  String get errorCacheNotFound => 'עדיין לא נשמר דבר.';

  @override
  String get errorUserNotFound => 'לא הצלחנו למצוא את החשבון.';

  @override
  String get errorItemNotFound => 'הפריט אינו קיים עוד.';

  @override
  String get errorOutfitNotFound => 'המראה אינו קיים עוד.';

  @override
  String get rewardsTitle => 'הישגים';

  @override
  String get rewardsNoAchievementsTitle => 'אין הישגים עדיין';

  @override
  String get rewardsNoAchievementsBody =>
      'הוסף פריטים ותכנן מראות כדי להרוויח את הראשון שלך.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'אין אף אחד בלוח עדיין';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'תכנן מראות כדי לצבור נקודות ולהופיע כאן.';

  @override
  String get legalViewPrivacyPolicy => 'הצג מדיניות פרטיות';

  @override
  String get aiConsentAgree => 'אני מסכים והמשך';

  @override
  String get aiConsentNotNow => 'לא עכשיו';

  @override
  String get imageViewerCloseTooltip => 'סגירת מציג התמונות';

  @override
  String get updateReadyTitle => 'העדכון מוכן';

  @override
  String get updateReadyBody =>
      'הפעל מחדש את FitCheck AI כדי להחיל את השיפורים האחרונים.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI זקוק לגישה למצלמה כדי לצלם את התלבושות ופריטי המלתחה שלך.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI זקוק לגישה לספריית התמונות כדי לבחור תמונות של התלבושות ופריטי המלתחה שלך.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI זקוק לאפשרות לשמור את תמונות התלבושות שנוצרו בספריית התמונות שלך.';

  @override
  String get wardrobeSomePhotosSkipped => 'חלק מהתמונות דלגו';

  @override
  String get wardrobePhotosNotAdded => 'התמונות לא נוספו';

  @override
  String get wardrobePhotoNotAdded => 'התמונה לא נוספה';

  @override
  String get wardrobeNotStartedTitle => 'לא התחיל';

  @override
  String get wardrobeNoRoomTitle => 'אין מקום';

  @override
  String get wardrobeAddPhotosSemantic => 'הוספת תמונות';

  @override
  String get batchAddTileLabel => 'הוספה';

  @override
  String get batchProfileLinkLabel => 'קישור לפרופיל';

  @override
  String get wardrobeImportFromProfileTitle => 'ייבוא מפרופיל';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'הוספת מספר תמונות';

  @override
  String get wardrobeClearAction => 'ניקוי';

  @override
  String get wardrobeRefreshTooltip => 'רענון';

  @override
  String get batchNoPhotosYetTitle => 'אין תמונות עדיין';

  @override
  String get batchChoosePhotosAction => 'בחר תמונות';

  @override
  String get batchWeFindEachPieceBody => 'נזהה כל פריט ונפיק לו תמונת סטודיו.';

  @override
  String get batchPreparingPhotosSemantic => 'מכין תמונות';

  @override
  String get batchPhotosProcessedSemantic => 'תמונות עובדו';

  @override
  String get batchPasteProfileLinkTitle => 'הדבקת קישור לפרופיל';

  @override
  String get batchPasteProfileLinkBody =>
      'פרופיל ציבורי באינסטגרם או בפייסבוק. נסרוק את התמונות שלו ותוכל לבחור מה ייכנס לארון.';

  @override
  String get batchClearLinkTooltip => 'ניקוי קישור';

  @override
  String get batchStartingButton => 'מתחיל';

  @override
  String get batchStartImportAction => 'התחל לייבא';

  @override
  String get batchReviewEveryPhotoTitle => 'אתה בודק כל תמונה';

  @override
  String get batchReviewEveryPhotoBody => 'שום דבר לא מתווסף עד שתאשר זאת.';

  @override
  String get batchPrivateProfilesTitle => 'פרופילים פרטיים';

  @override
  String get batchPrivateProfilesBody =>
      'חבר את החשבון שלך. אינסטגרם דורשת גם שם משתמש וסיסמה.';

  @override
  String get batchUseAnotherLinkAction => 'השתמש בקישור אחר';

  @override
  String get batchSignInNeededTitle => 'נדרשת התחברות';

  @override
  String get batchEnterYourCodeTitle => 'הזן את הקוד שלך';

  @override
  String get batchUseUsernamePasswordAction => 'השתמש בשם משתמש וסיסמה';

  @override
  String get batchAlreadyConnectedAction => 'כבר התחברתי בדפדפן';

  @override
  String get batchEnterCodeAction => 'הזן קוד';

  @override
  String get batchTryAnotherWayAction => 'נסה דרך אחרת';

  @override
  String get batchLiveStatus => 'בשידור חי';

  @override
  String get batchReconnectingStatus => 'מתחבר מחדש';

  @override
  String get batchSignInToInstagramTitle => 'התחבר לאינסטגרם';

  @override
  String get batchUsernameLabel => 'שם משתמש';

  @override
  String get batchCodeIfTwoStepLabel => 'קוד, אם אתה משתמש באימות דו-שלבי';

  @override
  String get batchAuthenticatorCodeBody =>
      'השתמש בקוד בן 6 הספרות מאפליקציית האימות שלך. הקודים משתנים במהירות.';

  @override
  String get batchVerifyAction => 'אמת';

  @override
  String get batchFindingPhotosTitle => 'מחפש תמונות';

  @override
  String get batchImportPausedTitle => 'הייבוא מושהה';

  @override
  String get batchProcessingPhotosTitle => 'מעבד תמונות';

  @override
  String get batchWaitingNextPhoto => 'ממתין לתמונה הבאה';

  @override
  String get batchCancelImportAction => 'בטל ייבוא';

  @override
  String get batchNoPiecesInPhotoBody => 'לא נמצאו פריטים בתמונה זו.';

  @override
  String get batchEditPieceColoursLabel => 'צבעים, מופרדים בפסיקים';

  @override
  String get batchAddToClosetAction => 'הוסף לארון';

  @override
  String get batchSkipPhotoAction => 'דלג על תמונה זו';

  @override
  String get batchImportCompleteTitle => 'הייבוא הושלם';

  @override
  String get batchImportFailedTitle => 'הייבוא נכשל';

  @override
  String get batchImportCancelledTitle => 'הייבוא בוטל';

  @override
  String get batchImportErrorBody => 'משהו השתבש במהלך הייבוא.';

  @override
  String get batchNothingMoreImportedBody => 'שום דבר נוסף לא יובא מפרופיל זה.';

  @override
  String get batchViewClosetAction => 'הצג ארון';

  @override
  String get batchStartOverAction => 'התחל מחדש';

  @override
  String get wardrobeAddPieceTitle => 'הוסף פריט';

  @override
  String get wardrobeAddDetailsTitle => 'הוסף פרטים';

  @override
  String get wardrobeScanningTitle => 'סורק';

  @override
  String get batchReviewPiecesTitle => 'סקירת פריטים';

  @override
  String get wardrobeGalleryAction => 'גלריה';

  @override
  String get wardrobeCameraAction => 'מצלמה';

  @override
  String get wardrobeNewBadge => 'חדש';

  @override
  String get wardrobeRemovePhotoTooltip => 'הסר תמונה';

  @override
  String get batchRunInBackgroundTooltip => 'הרץ ברקע';

  @override
  String get batchStepOneOfTwo => 'שלב 1 מתוך 2';

  @override
  String get batchStepTwoOfTwo => 'שלב 2 מתוך 2';

  @override
  String get batchUploadingPhotosTitle => 'מעלה תמונות';

  @override
  String get batchFindingPiecesTitle => 'מאותר פריטים';

  @override
  String get batchMakingStudioPhotosTitle => 'יוצר תמונות סטודיו';

  @override
  String get batchStoppedLabel => 'מושהה';

  @override
  String get batchFindingPiecesStoppedTitle => 'איתור הפריטים הופסק';

  @override
  String get batchCancelledLabel => 'בוטל';

  @override
  String get batchAllDoneTitle => 'הכל מוכן';

  @override
  String get batchOpeningPiecesBody => 'פותח את הפריטים שלך';

  @override
  String get batchNothingSavedBody => 'שום דבר לא נשמר.';

  @override
  String get batchFindingPiecesFailedBody => 'איתור הפריטים נכשל.';

  @override
  String get batchFindingPiecesStoppedEarlyBody => 'איתור הפריטים הופסק מוקדם.';

  @override
  String get batchStopFindingPiecesTitle => 'להפסיק את איתור הפריטים?';

  @override
  String get batchStopFindingPiecesBody =>
      'הסריקה תעצור ודבר לא יישמר. פריטים שכבר נמצאו יישארו בפעילות שלך עד שתסגור אותם.';

  @override
  String get batchKeepGoingAction => 'המשך';

  @override
  String get batchTryAgainAction => 'נסה שוב';

  @override
  String get batchBackToPhotosAction => 'חזור לתמונות';

  @override
  String get batchSkipAllAction => 'דלג על הכל';

  @override
  String get batchIncludeAllAction => 'כלול הכל';

  @override
  String get batchNoPiecesFoundTitle => 'לא נמצאו פריטים';

  @override
  String get batchNoPiecesFoundBody => 'לא מצאנו בגדים בתמונות אלו.';

  @override
  String get batchChooseOtherPhotosAction => 'בחר תמונות אחרות';

  @override
  String get batchUseCaseHelper => 'נוסף לכל פריט שתשמור.';

  @override
  String get batchDiscardPiecesTitle => 'למחוק פריטים אלו?';

  @override
  String get batchDiscardPiecesBody => 'שום דבר מקבוצה זו לא נשמר.';

  @override
  String get batchKeepAction => 'שמור';

  @override
  String get batchDiscardAction => 'מחק';

  @override
  String get batchRemovePieceTitle => 'להסיר פריט זה?';

  @override
  String get batchRemovePieceBody => 'הוא אינו שמור בארון שלך.';

  @override
  String get batchRemoveAction => 'הסר';

  @override
  String get batchChoosePiecesToSave => 'בחר פריטים לשמירה';

  @override
  String get batchDiscardAllAction => 'מחק הכל';

  @override
  String get batchNothingSavedRetryBody => 'דבר לא נשמר. נסה שוב.';

  @override
  String get batchNotSavedTitle => 'לא נשמר';

  @override
  String get batchSavingLabel => 'שומר';

  @override
  String get batchSendToBackgroundAction => 'העבר ברקע';

  @override
  String get batchStillWorkingMessage =>
      'עדיין עובדים על זה. נעדכן אותך כשהפריטים שלך יהיו מוכנים.';

  @override
  String get batchRunningInBackgroundTitle => 'פועל ברקע';

  @override
  String get batchStudioPhotosStoppedBody =>
      'הפקת צילומי הסטודיו הופסקה מוקדם. אתה עדיין יכול לשמור פריטים אלו.';

  @override
  String get batchTapPieceToSkip => 'הקש על פריט כדי לדלג עליו.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'צילומי הסטודיו בדרך. אתה יכול לעזוב – נעדכן אותך.';

  @override
  String get batchLeaveAction => 'עזוב';

  @override
  String get batchPeopleInPhotosTitle => 'אנשים בתמונות';

  @override
  String get batchIncludeAction => 'כלול';

  @override
  String get batchSkipAction => 'דלג';

  @override
  String get batchYourPhotoIsUsedLabel => 'התמונה שלך בשימוש';

  @override
  String get batchMakingStudioPhotoLabel => 'מכין תמונת סטודיו';

  @override
  String get batchNoStudioPhotoBody => 'אין תמונת סטודיו. התמונה שלך בשימוש.';

  @override
  String get batchEnterDetailsYourselfAction => 'הזן פרטים בעצמך';

  @override
  String get batchChooseAnotherPhotoAction => 'בחר תמונה אחרת';

  @override
  String get batchConnectionLostTitle => 'החיבור אבד';

  @override
  String get batchConnectionLostBody => 'בדוק את החיבור ונסה שוב.';

  @override
  String get batchDailyLimitTitle => 'הגעת למגבלה היומית';

  @override
  String get batchDailyLimitBodyPaywall =>
      'שדרג ל-Pro לסריקות נוספות או הזן את הפרטים בעצמך.';

  @override
  String get batchDailyLimitBodyFree =>
      'הסריקות שלך יתאפסו מחר. בינתיים באפשרותך להזין את הפרטים בעצמך.';

  @override
  String get batchSeePlansAction => 'צפה בתוכניות';

  @override
  String get batchAiBusyTitle => 'הבינה המלאכותית שלנו עמוסה';

  @override
  String get batchAiBusyBody => 'הבעיה בצד שלנו. נסה שוב בעוד מספר דקות.';

  @override
  String get batchNoPiecesBody =>
      'נסה תמונה ברורה יותר או הזן את הפרטים בעצמך.';

  @override
  String get batchScanningUnavailableTitle => 'הסריקה אינה זמינה';

  @override
  String get batchScanningUnavailableBody => 'הזן את הפרטים בעצמך לעת עתה.';

  @override
  String get batchScanDidNotFinishTitle => 'הסריקה לא הסתיימה';

  @override
  String get batchTryAgainBody => 'נסה שוב.';

  @override
  String get billingTitle => 'מנוי';

  @override
  String get billingUpgradeHeading => 'שדרג את התוכנית שלך';

  @override
  String get billingUpgradeOnPlusBody => 'אותן תכונות, מגבלות גבוהות יותר.';

  @override
  String get billingUpgradeBody =>
      'ל-Plus ול-Pro יש אותן תכונות. בחר את המגבלות שאתה צריך.';

  @override
  String get billingWebUnavailableBody =>
      'שדרוגים מקוונים אינם זמינים עדיין. קוד קופון או הפניה עדיין פותחים את Plus או Pro. הזמן חברים למטה כדי להרוויח חודשים חינם.';

  @override
  String get billingPlansStale =>
      'לא ניתן לטעון את התוכניות העדכניות. המחירים עשויים להיות לא מעודכנים.';

  @override
  String get billingMonthly => 'חודשי';

  @override
  String get billingYearly => 'שנתי';

  @override
  String get billingCurrentPlan => 'תוכנית נוכחית';

  @override
  String get billingActive => 'פעיל';

  @override
  String get billingThisMonth => 'החודש';

  @override
  String get billingItemExtractions => 'חילוצי פריטים';

  @override
  String get billingOutfitVisualizations => 'הדמיות תלבושות';

  @override
  String get billingNearLimitUpgrade =>
      'אתה קרוב למגבלה של חודש זה. שדרג עבור עוד.';

  @override
  String get billingNearLimitResets =>
      'אתה קרוב למגבלה של חודש זה. היא מתאפסת בתחילת החודש הבא.';

  @override
  String get billingStoreUnavailable =>
      'השדרוגים אינם זמינים כעת בחנות. נסו שוב בקרוב.';

  @override
  String get billingManageHeading => 'ניהול המנוי';

  @override
  String get billingCancelPlan => 'ביטול מנוי';

  @override
  String get billingCancelKeepsAccess =>
      'הגישה תישמר עד סוף תקופת החיוב הנוכחית.';

  @override
  String get billingCancelConfirmTitle => 'לבטל את המנוי?';

  @override
  String get billingKeepPlan => 'שמירת המנוי';

  @override
  String get billingCancelPlanAction => 'ביטול מנוי';

  @override
  String get billingBilledMonthly => 'חיוב חודשי';

  @override
  String get billingBilledYearly => 'חיוב שנתי';

  @override
  String get billingVirtualTryOn => 'הלבשה וירטואלית';

  @override
  String get billingPrioritySupport => 'תמיכה עדיפה';

  @override
  String get billingDisclosureProRenewing => 'Pro הוא מנוי מתחדש אוטומטית';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus ו-Pro הם מנויים המתחדשים אוטומטית';

  @override
  String get billingDisclosureAppleBilling =>
      'התשלום ייגבה מחשבון ה-Apple ID שלך עם אישור הרכישה.';

  @override
  String get billingDisclosureGoogleBilling =>
      'התשלום ייגבה מחשבון ה-Google Play שלך עם אישור הרכישה.';

  @override
  String get billingDisclosureRenewalTerms =>
      'המנוי שלך מתחדש אוטומטית לאותה תקופה ובאותו מחיר אלא אם החידוש האוטומטי יושבת לפחות 24 שעות לפני תום התקופה הנוכחית.';

  @override
  String get billingDisclosureAppleManage =>
      'ניתן לנהל או לבטל בכל עת בהגדרות › ה-Apple ID שלך › מנויים.';

  @override
  String get billingDisclosureGoogleManage =>
      'ניתן לנהל או לבטל בכל עת ב-Google Play › תשלומים ומנויים.';

  @override
  String get billingReferFriend => 'הזמנת חבר';

  @override
  String get billingHowItWorks => 'איך זה עובד';

  @override
  String get billingHowShareTitle => 'שתפו את הקישור';

  @override
  String get billingHowShareBody => 'שלחו אותו לחבר.';

  @override
  String get billingHowSignUpTitle => 'הם נרשמים';

  @override
  String get billingHowSignUpBody => 'החבר שלכם מצטרף דרך הקישור.';

  @override
  String get billingHowBothTitle => 'שניכם מקבלים Pro';

  @override
  String get billingHowBothBody => 'כל אחד מכם מקבל חודש Pro חינם.';

  @override
  String get billingYourReferrals => 'ההפניות שלך';

  @override
  String get billingInvited => 'הוזמנו';

  @override
  String get billingJoined => 'הצטרפו';

  @override
  String get billingMonthsEarned => 'חודשים שהורווחו';

  @override
  String get billingInviteFriend => 'הזמן חבר';

  @override
  String get billingInviteBody => 'אתה והחבר שלך תקבלו חודש של Pro.';

  @override
  String get billingYourCode => 'הקוד שלך';

  @override
  String get billingCopyLink => 'העתק קישור';

  @override
  String get billingShareInvite => 'שתף הזמנה';

  @override
  String get giftUnavailable => 'הזמנות מתנה אינן זמינות בגרסה זו.';

  @override
  String get giftPageTitle => 'מתנה FitCheck Pro';

  @override
  String get giftNoAllowances => 'אין כרגע הזמנות מתנה חינם זמינות.';

  @override
  String get giftFormTitle => 'שלח הזמנה חינם';

  @override
  String get giftFormBody =>
      'המקבל מממש את המתנה באמצעות אימייל מאומת זה. איננו שולחים את האימייל עבורך.';

  @override
  String get giftFieldFrom => 'מאת';

  @override
  String get giftFieldRecipientName => 'שם המקבל';

  @override
  String get giftFieldRecipientEmail => 'אימייל של המקבל';

  @override
  String get giftFieldOccasion => 'אירוע (אופציונלי)';

  @override
  String get giftNoOccasion => 'ללא אירוע';

  @override
  String get giftOccasionBirthday => 'יום הולדת';

  @override
  String get giftOccasionAnniversary => 'יום נישואין';

  @override
  String get giftOccasionOther => 'אחר';

  @override
  String get giftFieldCardGreeting => 'ברכה בכרטיס';

  @override
  String get giftFieldCardGreetingHelper =>
      'זה מופיע על הכרטיס בדיוק כפי שנכתב.';

  @override
  String get giftFieldPrivateNote => 'הערה פרטית (אופציונלי)';

  @override
  String get giftCreateAction => 'צור מתנה חינם';

  @override
  String get giftClaimedTitle => 'המתנה הוענקה';

  @override
  String get giftClaimedActive => 'מתנת FitCheck Pro שלך פעילה.';

  @override
  String get giftClaimedQueued =>
      'מתנת FitCheck Pro שלך תתחיל לאחר הגישה הנוכחית שלך.';

  @override
  String get giftLinkCopied => 'קישור המתנה הועתק ללוח.';

  @override
  String get giftErrorName => 'הזן שם.';

  @override
  String get giftErrorEmail => 'הזן כתובת אימייל חוקית.';

  @override
  String get giftErrorGreeting => 'הזן את הברכה בכרטיס.';

  @override
  String get giftErrorGreetingLength => 'השתמש בעד 80 תווים.';

  @override
  String get giftClaimAction => 'קבלת מתנה';

  @override
  String get giftCardPreview => 'תצוגה מקדימה של כרטיס';

  @override
  String get giftGiftForYou => 'מתנה בשבילך';

  @override
  String get giftGiftWaiting => 'מתנה מחכה לך';

  @override
  String get giftOpenBody =>
      'פתחו את המתנות שלכם כדי לאסוף אותן באמצעות האימייל המאומת שלכם.';

  @override
  String get giftOpenGifts => 'פתיחת מתנות';

  @override
  String get giftSendInvitation => 'שליחת הזמנה';

  @override
  String get settingsAiProviderSection => 'ספק';

  @override
  String get settingsAiCustom => 'מותאם אישית';

  @override
  String get settingsAiUrlHelper =>
      'השתמשו בכתובת ציבורית שהשרת יכול לגשת אליה. Localhost לא עובד מהשרתים שלנו.';

  @override
  String get settingsAiConnectionSection => 'חיבור';

  @override
  String get settingsAiApiUrl => 'כתובת API';

  @override
  String get settingsAiApiKey => 'מפתח API';

  @override
  String get settingsAiApiKeySaved => 'נשמר. השאירו ריק כדי לשמור על הקיים.';

  @override
  String get settingsAiChatModel => 'מודל צ\'אט';

  @override
  String get settingsAiVisionModel => 'מודל ראייה (אופציונלי)';

  @override
  String get settingsAiImageModel => 'מודל תמונה (אופציונלי)';

  @override
  String get settingsAiImageModelNote =>
      'יצירת תמונות דורשת השלמות צ\'אט התואמות ל-OpenAI עם response_modalities.';

  @override
  String get settingsAiTestConnection => 'בדיקת חיבור';

  @override
  String get calendarTitle => 'לוח שנה';

  @override
  String get calendarGoToToday => 'עבור להיום';

  @override
  String get calendarConnectTooltip => 'חיבור לוח שנה';

  @override
  String get calendarAddEvent => 'הוספת אירוע';

  @override
  String get calendarEmptyTitle => 'אין תוכניות';

  @override
  String get calendarEmptyBody => 'הוסיפו אירוע ותכננו מה ללבוש.';

  @override
  String get calendarPreviousMonth => 'חודש קודם';

  @override
  String get calendarNextMonth => 'חודש הבא';

  @override
  String get calendarAllDay => 'כל היום';

  @override
  String get calendarOutfitLinked => 'המראה קושר';

  @override
  String get calendarEventOptions => 'אפשרויות אירוע';

  @override
  String get calendarDeleteTitle => 'למחוק אירוע זה?';

  @override
  String get calendarChangeOutfit => 'החלף אופטפי';

  @override
  String get calendarLinkOutfit => 'שייך אאוטפיט';

  @override
  String get calendarRemoveOutfit => 'הסר אאוטפיט';

  @override
  String get calendarNewEvent => 'אירוע חדש';

  @override
  String get calendarEditEvent => 'עריכת אירוע';

  @override
  String get calendarTitleLabel => 'כותרת';

  @override
  String get calendarTitleRequired => 'הוסף כותרת';

  @override
  String get calendarEndBeforeStart => 'סיום אחרי זמן ההתחלה';

  @override
  String get calendarStarts => 'מתחיל';

  @override
  String get calendarEnds => 'מסתיים';

  @override
  String get calendarPlaceOptional => 'מיקום (אופציונלי)';

  @override
  String get calendarNotesOptional => 'הערות (אופציונלי)';

  @override
  String get calendarLinkOutfitEmptyBody => 'צור אאוטפיט ושייך אותו לאירוע זה.';

  @override
  String get calendarBuildOutfit => 'צור אאוטפיט';

  @override
  String get calendarConnectionsTitle => 'יומנים';

  @override
  String get calendarConnectionsBody =>
      'אירועים שתוסיף לכאן יישארו ב-FitCheck.';

  @override
  String get calendarDisconnect => 'נתק';

  @override
  String get calendarNotAvailable => 'לא זמין עדיין';

  @override
  String get profileSectionExplore => 'גלה';

  @override
  String get profileNavTryOn => 'מדידה';

  @override
  String get profileNavRewards => 'הטבות';

  @override
  String get profileSupport => 'תמיכה';

  @override
  String get profileHelp => 'עזרה';

  @override
  String get profileAbout => 'אודות';

  @override
  String get profileAboutBody => 'הארון, האאוטפיטים והתוכניות שלך במקום אחד.';

  @override
  String get profileSignOutTitle => 'להתנתק?';

  @override
  String get profileSignOutBody => 'תוכל להתחבר מחדש בכל עת.';

  @override
  String get profileEditTitle => 'עריכת פרופיל';

  @override
  String get profileYourProfile => 'הפרופיל שלך';

  @override
  String get profileBodyProfiles => 'פרופילי גוף';

  @override
  String get profileBodyEmptyTitle => 'אין עדיין פרופילי גוף';

  @override
  String get profileBodyEmptyBody =>
      'הוסף את הגובה ומבנה הגוף שלך כדי לקבל התאמה טובה יותר.';

  @override
  String get profileBodyAdd => 'הוסף פרופיל';

  @override
  String get profileBodyDefaultNote =>
      'פרופיל ברירת המחדל שלך משמש להתאמה ולמדידה.';

  @override
  String get profileBodyDefaultBadge => 'ברירת מחדל';

  @override
  String get profileBodyMakeDefault => 'הגדר כברירת מחדל';

  @override
  String get profileBodyDeleteBody => 'לא ניתן לבטל פעולה זו.';

  @override
  String get profileBodyRequired => 'שדה חובה';

  @override
  String get profileBodyCheckNumber => 'בדוק מספר זה';

  @override
  String get profileBodyNew => 'פרופיל גוף חדש';

  @override
  String get profileBodyNameHint => 'לדוגמה, אני';

  @override
  String get profileBodyHeight => 'גובה';

  @override
  String get profileBodyWeight => 'משקל';

  @override
  String get profileBodyBuild => 'מבנה גוף';

  @override
  String get profileBodySkinTone => 'גון עור';

  @override
  String get profileBirthDateNeededBody => 'הוסף תאריך לידה שיתאים לשעת הלידה.';

  @override
  String get profileBirthDateNeededTitle => 'נדרש תאריך לידה';

  @override
  String get profilePartlySavedBody =>
      'שמרנו את שמך והתמונה. פרטי הלידה לא נשמרו, נסה שוב מאוחר יותר.';

  @override
  String get profilePartlySavedTitle => 'נשמר בחלקו';

  @override
  String get profileSavedBody => 'הפרופיל שלך נשמר.';

  @override
  String get profileChangePhoto => 'שנה תמונת פרופיל';

  @override
  String get profilePhotoLabel => 'תמונת פרופיל';

  @override
  String get profilePhotoHint => 'הקש כדי לבחור חדשה';

  @override
  String get profileBirthDateLabel => 'תאריך לידה (אופציונלי)';

  @override
  String get profileBirthTimeLabel => 'שעת לידה (אופציונלי)';

  @override
  String get profileBirthTimeHelper => 'הופך את ההמלצות הוודיות למדויקות יותר';

  @override
  String get profileBirthPlaceLabel => 'מקום לידה (אופציונלי)';

  @override
  String get profileBirthPlaceHint => 'לדוגמה, ניו דלהי, הודו';

  @override
  String get profileHelpContactTitle => 'שולל מאיתנו הכל';

  @override
  String get profileHelpContactBody =>
      'שלחו לנו הודעה ונענה במייל, בדרך כלל תוך יום.';

  @override
  String get profileHelpContactAction => 'צור קשר עם התמיכה';

  @override
  String get profileHelpFaqTitle => 'שאלות נפוצות';

  @override
  String get profileFaqAddPiecesTitle => 'איך מוסיפים פריטים לארון?';

  @override
  String get profileFaqAddPiecesBody =>
      'הקש על הוספת פריט בלשונית הארון. צלם תמונה או בחר מהגלריה, ואנחנו נמצא ונתגמל את הפריט עבורך.';

  @override
  String get profileFaqMatchingTitle => 'איך עובדת התאמת האופנה?';

  @override
  String get profileFaqMatchingBody =>
      'פתח את בשבילך ובחר פריטים שבבעלותך. אנו נמליץ מה הולך איתם ונרכיב אופציות מלאות מהארון שלך.';

  @override
  String get profileFaqTryOnTitle => 'האם אפשר להשתמש בתמונות שלי למדידה?';

  @override
  String get profileFaqTryOnBody =>
      'כן. הוסף תמונה מלאה של עצמך, ואז בחר פריטים כדי לראות אותם עליך.';

  @override
  String get profileFaqRewardsTitle => 'איך מרוויחים פרסים?';

  @override
  String get profileFaqRewardsBody =>
      'תכנן ותעד בגדים לעיתים קרובות. רצפים והישגים נבנים ככל שמתקדמים.';

  @override
  String get profileFaqPrivacyTitle => 'האם הארון שלי פרטי?';

  @override
  String get profileFaqPrivacyBody =>
      'כן. הארון והבגדים שלך פרטיים אלא אם כן תשתף קישור לבגד אחד.';

  @override
  String get profileHelpMoreTitle => 'עזרה נוספת';

  @override
  String get profileHelpGuides => 'מדריכים';

  @override
  String get profileHelpGuidesBody => 'איך כל תכונה עובדת';

  @override
  String get feedbackCategoryBug => 'משהו התקלקל';

  @override
  String get feedbackCategoryIdea => 'רעיון';

  @override
  String get feedbackCategoryGeneral => 'כללי';

  @override
  String get feedbackCategoryHelp => 'אני צריך עזרה';

  @override
  String get feedbackHintBug =>
      'מה קרה ומה ציפית שיקרה? שלבים עוזרים לנו לתקן זאת.';

  @override
  String get feedbackHintIdea => 'מה היית רוצה ולמה?';

  @override
  String get feedbackHintGeneral => 'ספר לנו מה אתה חושב, או שאל שאלה.';

  @override
  String get feedbackAttachmentLimitBody => 'ניתן להוסיף עד 5 תמונות.';

  @override
  String get feedbackAttachmentLimitTitle => 'הגעת למגבלה';

  @override
  String get feedbackImageTooLargeBody => 'בחר תמונה מתחת ל-5 מגה-בייט.';

  @override
  String get feedbackImageTooLargeTitle => 'התמונה גדולה מדי';

  @override
  String get feedbackTitle => 'שלח משוב';

  @override
  String get feedbackAboutLabel => 'על מה מדובר?';

  @override
  String get feedbackSubjectLabel => 'נושא';

  @override
  String get feedbackSubjectRequired => 'הוסף נושא';

  @override
  String get feedbackSubjectTooShort => 'הנושא חייב להכיל לפחות 3 תווים';

  @override
  String get feedbackDetailsLabel => 'פרטים';

  @override
  String get feedbackDetailsRequired => 'הוסף פרטים';

  @override
  String get feedbackDetailsTooShort => 'התיאור חייב להכיל לפחות 10 תווים';

  @override
  String get feedbackAddScreenshot => 'הוסף צילום מסך';

  @override
  String get feedbackAttachmentHint => 'עד 5, 5 מגה-בייט כל אחד';

  @override
  String get feedbackSend => 'שלח';

  @override
  String get feedbackEmptyTitle => 'עדיין לא נשלח דבר';

  @override
  String get feedbackEmptyBody => 'מה שתשלח יופיע כאן יחד עם הסטטוס שלו.';

  @override
  String get feedbackHistoryTitle => 'מה ששלחת';

  @override
  String get feedbackStatusOpen => 'פתוח';

  @override
  String get feedbackStatusInProgress => 'בטיפול';

  @override
  String get feedbackStatusResolved => 'נפתר';

  @override
  String get feedbackStatusClosed => 'סגור';

  @override
  String get legalIntro =>
      'כיצד אנו מגינים על הנתונים שלך והתנאים לשימוש ב-FitCheck AI.';

  @override
  String get legalPolicies => 'מדיניות';

  @override
  String get legalPrivacySubtitle => 'מה אנו אוספים ולמה';

  @override
  String get legalTermsTitle => 'תנאי שימוש';

  @override
  String get legalTermsSubtitle => 'הכללים לשימוש באפליקציה';

  @override
  String get legalLicences => 'רישיונות קוד פתוח';

  @override
  String get legalSupportSubtitle => 'עזרה, יצירת קשר ובקשות פרטיות';

  @override
  String get legalReportAbuse => 'דווח על בעיה או שימוש לרעה';

  @override
  String get permissionCameraTitle => 'גישה למצלמה';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI משתמש במצלמה שלך כדי לצלם את הבגדים והתלבושות שלך עבור מדידה מבוססת AI וארגון הארון.';

  @override
  String get permissionPhotoTitle => 'גישה לתמונות';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI זקוק לגישה לתמונות שלך כדי שתוכל לבחור תמונות בגדים ותלבושות עבור תכונות ה-AI והארון שלך.';

  @override
  String get permissionNotNow => 'לא עכשיו';

  @override
  String get permissionOpenSettings => 'פתח הגדרות';

  @override
  String authSignedInAs(String name) {
    return 'מחובר בתור $name';
  }

  @override
  String get authSignedIn => 'מחובר';

  @override
  String get authWelcomeBackTitle => 'ברוך שובך';

  @override
  String get authSignInFailed => 'ההתחברות נכשלה';

  @override
  String get authWelcomeTitle => 'ברוך הבא';

  @override
  String get authSignUpFailed => 'ההרשמה נכשלה';

  @override
  String get authGoogleSignInFailed => 'ההתחברות עם Google נכשלה';

  @override
  String get authAppleSignInFailed => 'ההתחברות עם Apple נכשלה';

  @override
  String get authConfirmEmailTitle => 'אשר את המייל שלך';

  @override
  String get authConfirmEmailBody =>
      'בדוק את תיבת הדואר הנכנס לאישור המייל, ואז התחבר.';

  @override
  String get authClosetReady => 'הארון שלך מוכן.';

  @override
  String get authSignedOutTitle => 'מנותק';

  @override
  String get authSignedOutBody => 'אתה מנותק.';

  @override
  String get authSignOutFailed => 'ההתנתקות נכשלה';

  @override
  String get authEmailSentTitle => 'המייל נשלח';

  @override
  String get authResetLinkSent => 'בדוק את המייל שלך עבור קישור לאיפוס.';

  @override
  String get authPasswordUpdatedTitle => 'הסיסמה עודכנה';

  @override
  String get authPasswordUpdated => 'הסיסמה שלך עודכנה.';

  @override
  String get authPasswordNotUpdated => 'הסיסמה לא עודכנה';

  @override
  String get authCouldNotSendEmail => 'לא ניתן לשלוח את המייל';

  @override
  String get authEmailNotSent => 'המייל לא נשלח';

  @override
  String get authResendSentBody => 'שלחנו מייל אישור חדש.';

  @override
  String get outfitPreviewWithAi => 'תצוגה מקדימה עם AI';

  @override
  String get outfitNewPreview => 'צור תצוגה מקדימה חדשה';

  @override
  String get outfitBuilderClosetHeading => 'אטלאנטי שלך';

  @override
  String get outfitBuilderSearchHint => 'חפש פריטים';

  @override
  String get outfitClearSearch => 'מחק חיפוש';

  @override
  String get outfitBuilderAddPiecesTitle => 'הוסף פריטים תחילה';

  @override
  String get outfitBuilderAddPiecesBody => 'התלבושות נבנות מפריטים באטלאנטי.';

  @override
  String get outfitBuilderNoMatches => 'אין פריטים תואמים.';

  @override
  String get outfitNameLabel => 'שם תלבושת';

  @override
  String get outfitNameHint => 'לדוגמה, שמלה לבית שותף בסוף השבוע';

  @override
  String get outfitPreviewSemantic => 'תצוגה מקדימה של AI לתלבושת';

  @override
  String get outfitChoosePieces => 'בחר פריטים';

  @override
  String get outfitTapPiecesHint => 'לחץ על פריטים למטה כדי להוסיף אותם.';

  @override
  String get outfitShareTooltip => 'שתף';

  @override
  String get outfitSaveFavourite => 'שמור למועדפים';

  @override
  String get outfitPiecesHeading => 'פריטים';

  @override
  String get outfitWearHistoryEmpty => 'לבש אותו פעם אחת והתאריכים יופיעו כאן.';

  @override
  String get outfitWearHistoryTitle => 'היסטוריית שימוש';

  @override
  String get outfitWearHistoryError => 'לא ניתן לטעון את התאריכים.';

  @override
  String get outfitWornOn => 'נערם ב';

  @override
  String get outfitEditTitle => 'ערוך תלבושת';

  @override
  String get outfitSavedPhotosFailed => 'פרטים נשמרו, תמונות לא';

  @override
  String get outfitNoPhotosBody =>
      'אין תמונות עדיין. התלבושת מציגה את הפריטים במקום.';

  @override
  String get outfitOccasionLabel => 'אירוע';

  @override
  String get outfitOccasionNone => 'אין';

  @override
  String get outfitTagsHint => 'הפרד עם פסיקים';

  @override
  String get outfitDraftBody => 'מוסתר מהרשימה הראשית שלך';

  @override
  String get outfitPublic => 'ציבורי';

  @override
  String get outfitPublicBody => 'כל אחד עם הקישור יכול לראות את זה';

  @override
  String get outfitDeleteFromDetail => 'מחק את התלבושת הזו מעמוד הפרטים.';

  @override
  String get outfitNewCollection => 'אוסף חדש';

  @override
  String get outfitNoCollectionsTitle => 'אין עדיין אוספים';

  @override
  String get outfitNoCollectionsBody =>
      'צברו לוקים לפי נסיעה, עונת שנה או מצב רוח.';

  @override
  String get outfitCreateCollection => 'יצירת אוסף';

  @override
  String get outfitAddOutfits => 'הוספת לוקים';

  @override
  String get outfitRename => 'שינוי שם';

  @override
  String get outfitCollectionDeleteBody => 'הלוקים שבו נשמרים.';

  @override
  String get outfitCollectionsNotLoaded => 'הלוקים טוענים';

  @override
  String get outfitRenameCollection => 'שינוי שם האוסף';

  @override
  String get outfitDescriptionOptional => 'תיאור (אופציונלי)';

  @override
  String get outfitAllInCollection => 'כל הלוקים כבר נכללים באוסף זה.';

  @override
  String get photoshootSubtitleUpload => 'דמויות סטודיו מהתמונות שלך';

  @override
  String get photoshootSubtitleConfigure => 'בחר סגנון, פורמט וכמות';

  @override
  String get photoshootSubtitleGenerating => 'התהליך לוקח דקה או שתיים';

  @override
  String get photoshootAddPhotosSemantic => 'הוספת תמונות מהגלריה שלך';

  @override
  String get photoshootUploadTitle => 'הוסף 1-4 תמונות שלך';

  @override
  String get photoshootUploadBody => 'לחץ כדי לבחור מהגלריה שלך';

  @override
  String get photoshootAddToContinue => 'הוסף תמונה כדי להמשיך';

  @override
  String get photoshootAddAnotherPhoto => 'הוסף תמונה נוספת';

  @override
  String get photoshootTipsTitle => 'לתוצאה מיטבית';

  @override
  String get photoshootTipsBody =>
      'השתמש בתמונות ברורות ומאופירות של הפנים שלך מזוויות שונות. הימנע ממשקפיים שמש ורופאים.';

  @override
  String get photoshootStarting => 'מתחיל';

  @override
  String get photoshootCancelling => 'מבטל';

  @override
  String get photoshootFailed => 'נכשל';

  @override
  String get recommendTabMatches => 'התאמות';

  @override
  String get recommendTabComplete => 'השלמה';

  @override
  String get recommendTabWeather => 'מזג אוויר';

  @override
  String get recommendTabColours => 'צבעים';

  @override
  String get recommendTabShop => 'קניות';

  @override
  String get recommendNoMatchesTitle => 'אין התאמות עדיין';

  @override
  String get recommendNoMatchesBody => 'בחרו פריט ונמצא מה הולך איתו.';

  @override
  String get recommendPickPiece => 'בחרו פריט';

  @override
  String get recommendNothingMatchesTitle => 'אין עדיין תיאום';

  @override
  String get recommendNothingMatchesBody =>
      'נסו פריטים אחרים, או הוסיפו עוד לארון.';

  @override
  String get recommendChangePieces => 'שנו פריטים';

  @override
  String get recommendDefaultReason => 'תאים לפריטים שבחרתם.';

  @override
  String get recommendCompleteTitle => 'השלימו את הלוק';

  @override
  String get recommendCompleteBody => 'בחרו פריט ונמלא את השאר.';

  @override
  String get recommendWorking => 'מעבד';

  @override
  String get recommendGenerate => 'ייצור';

  @override
  String get recommendChooseStyleBody => 'בחרו סגנון, ואז יצרו.';

  @override
  String get recommendNoLooksTitle => 'אין לוקים לפריטים האלה';

  @override
  String get recommendNoLooksBody => 'נסו סגנון או פריטים אחרים.';

  @override
  String get recommendDefaultLook => 'לוק לפריטים שלך';

  @override
  String get recommendNoPiecesBody => 'לא הגיעו פריטים ללוק הזה.';

  @override
  String get recommendCityLabel => 'עיר';

  @override
  String get recommendCheck => 'בדיקה';

  @override
  String get recommendWeatherTitle => 'מה המזג אוויר?';

  @override
  String get recommendWeatherBody => 'הזינו את העיר שלכם כדי לקבל הצעות ליום.';

  @override
  String get recommendWearToday => 'לבש היום';

  @override
  String get recommendWeatherNoPieces =>
      'אין עדיין פריטים בארון עבור מזג אוויר כזה.';

  @override
  String get recommendBudgetLabel => 'תקציב עד';

  @override
  String get recommendLooking => 'מחפש';

  @override
  String get recommendFindWhatToBuy => 'מצאו מה לקנות';

  @override
  String get recommendFillGapsTitle => 'מילואי חסרים';

  @override
  String get recommendFillGapsBody => 'קבעו תקציב ונציע מה חסר בארון.';

  @override
  String get recommendNoGapsTitle => 'לא נמצאו חסרים';

  @override
  String get recommendNoGapsBody => 'נסו תקציב גבוה יותר או קטגוריה אחרת.';

  @override
  String get recommendMoodEveryday => 'יומיומי';

  @override
  String get recommendMoodBigMeeting => 'ישיבה חשובה';

  @override
  String get recommendDayLabel => 'יום';

  @override
  String get recommendReadingStars => 'קריאת הקוסמוס';

  @override
  String get recommendGetMyColours => 'מצאו את הצבעים שלי';

  @override
  String get recommendLuckyColoursTitle => 'הצבעים המזליים שלך';

  @override
  String get recommendLuckyColoursBody =>
      'בחר יום ואנו נציע לו צבעים ופריטים מתאימים.';

  @override
  String get recommendLuckyColoursSection => 'צבעים מזמזלים';

  @override
  String get recommendAvoidColoursSection => 'צבעים כדאי להימנע מהם';

  @override
  String get recommendBirthDateTitle => 'הזן תאריך לידה';

  @override
  String get recommendBirthDateBody =>
      'אנחנו צריכים את תאריך הלידה שלך כדי לקרוא את הצבעים שלך.';

  @override
  String get recommendEditProfile => 'עריכת פרופיל';

  @override
  String get recommendNothingThisDay => 'אין המלצות ליום הזה.';

  @override
  String get recommendUnnamedColour => 'צבע ללא שם';

  @override
  String get recommendFromCloset => 'מקיטון שלך';

  @override
  String get recommendNoPiecesInColours => 'עדיין אין פריטים בצבעים האלה.';

  @override
  String get recommendOutfitIdeas => 'רעיונות טיפוסים';

  @override
  String get recommendNoOutfitsInColours => 'עדיין אין טיסום שלם בצבעים האלה.';

  @override
  String get recommendDefaultOutfitIdea => 'רעיון לטיסום';

  @override
  String get recommendPickUpToThree => 'בחר עד שלושה פריטים';

  @override
  String get recommendEmptyClosetBody =>
      'הוסף קודם כמה פריטים ואז חזור לחיפוש זוגות.';

  @override
  String get dashboardDressForDay => 'התלבש להצלחה בימים הבאים.';

  @override
  String get dashboardOutfitOfDay => 'טיפוסיום זה';

  @override
  String get dashboardFreshLook => 'מראה חדש';

  @override
  String get subscriptionManageInStoreTitle => 'ניהול בחנות';

  @override
  String get subscriptionManageInStoreBody =>
      'המנוי הזה נגבה דרך החנות. אפשר לנהל אותו בהגדרות החשבון שלך בחנות.';

  @override
  String get subscriptionCancelledTitle => 'המנוי בוטל';

  @override
  String get subscriptionCancelledBody =>
      'המנוי שלך נשאר פעיל עד סוף תקופת החיוב הנוכחית.';

  @override
  String get subscriptionCancelFailedTitle => 'לא ניתן לבטל';

  @override
  String get subscriptionCouldNotOpenTitle => 'לא ניתן לפתוח';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'לא ניתן לפתוח את ניהול החיוב.';

  @override
  String get subscriptionOpenLinkFailedBody => 'לא ניתן לפתוח את הקישור.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'לא ניתן לטעון את הקישור';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'לא ניתן לטעון את קישור ההמלצה. נסו שוב.';

  @override
  String get subscriptionReferralCopiedTitle => 'הועתק';

  @override
  String get subscriptionReferralCopiedBody => 'קישור ההמלצה הועתק.';

  @override
  String get subscriptionReferralShareSubject => 'נסו את FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'הצטרפו ל-FitCheck AI ונזכה שניהם לחודש של Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'הקישור הועתק';

  @override
  String get subscriptionShareUnavailableBody =>
      'שיתוף אינו זמין, לכן העתקנו את הקישור.';

  @override
  String get subscriptionShareFailedTitle => 'לא ניתן לשכרך';

  @override
  String get subscriptionShareFailedBody =>
      'העתקו את הקישור מדף ההמלצה במקום זאת.';

  @override
  String get subscriptionStoreReadyTitle => 'החנות מוכנה';

  @override
  String get subscriptionStoreReadyBody =>
      'מחירי החנות זמינים. אפשר לשדרג עכשיו.';

  @override
  String get purchaseFailedTitle => 'הרכישה נכשלה';

  @override
  String get purchaseUnavailableTitle => 'הרכישה אינה זמינה';

  @override
  String get purchaseIapUnavailableBody =>
      'רכישות בתוך האפליקציה אינן זמינות במכשיר זה.';

  @override
  String get purchasePlanNotAvailableBody =>
      'המנוי הזה אינו זמין לרכישה עדיין.';

  @override
  String get purchasePlanNotInStoreBody =>
      'המנוי הזה אינו זמין בחנות עדיין. בדקו שוב בקרוב.';

  @override
  String get purchaseStartFailedBody => 'לא ניתן להפעיל את הרכישה. נסו שוב.';

  @override
  String get purchaseNoPaymentLinkBody => 'הסליקה לא החזירה קישור לתשלום.';

  @override
  String get purchasePendingTitle => 'הרכישה בתליה';

  @override
  String get purchasePendingBody =>
      'הרכישה שלך ממתין לאישור. תקבלו גישה כשתאושר.';

  @override
  String get purchaseFailedBody => 'הרכישה נכשלה. נסו שוב.';

  @override
  String get purchaseRestoredTitle => 'שוחזר';

  @override
  String get purchaseRestoredBody => 'הרכישות שלך שוחזרו.';

  @override
  String get purchaseActiveTitle => 'המנוי פעיל';

  @override
  String get purchaseActiveBody => 'המנוי שלך פעיל. ברוכים הבאים.';

  @override
  String get purchaseSignInRequiredTitle => 'נדרש כניסה';

  @override
  String get purchaseSignInRequiredBody => 'היכנסו כדי לסיים את הרכישה.';

  @override
  String get purchaseErrorTitle => 'שגיאה ברכישה';

  @override
  String get purchaseInvalidTransactionBody =>
      'במסגרת הרכישה לא כלול מזהה עסקה שאפשר לאמת אותו.';

  @override
  String get purchaseVerificationPendingTitle => 'האמתה בתהליך';

  @override
  String get purchaseVerificationPendingBody =>
      'לא הצלחנו לאמת את הרכישה שלך בחנות כעת. הנושא יסתיים אוטומטית ולא תידרש לשלם שוב.';

  @override
  String get purchaseNotAppliedTitle => 'הרכישה לא הושקה';

  @override
  String get purchaseNotAppliedBody =>
      'לא ניתן להפעיל את הרכישה בחשבון שלך. צור קשר עם שירות הלקוחות ואל תרכוש שוב.';

  @override
  String get purchaseRestoreFailedTitle => 'שחזור נכשל';

  @override
  String get purchaseRestoreFailedBody => 'לא ניתן לשחזר את הרכישות. נסה שוב.';

  @override
  String get purchaseRecoveredActiveBody => 'המנוי שלך פעיל.';

  @override
  String get purchaseCompleteTitle => 'הרכישה הושלמה';

  @override
  String get giftCreateFailedTitle => 'לא ניתן ליצור את המתנה';

  @override
  String get giftClaimFailedTitle => 'לא ניתן לפרוע את המתנה';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count מתנות עבורך',
      one: 'מתנה עבורך',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': 'חודש אחד',
      '12': 'שנה אחת',
      'other': '$months חודשים',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining נותרו',
      one: 'נותר אחד',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration של FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender שלח לך $duration של FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'מתנת FitCheck Pro עבור $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'מאת $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'עבור $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'מאת $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'הנמען שלך';

  @override
  String get giftPreviewPlaceholderSender => 'אתה';

  @override
  String get settingsSavedTitle => 'נשמר';

  @override
  String get settingsNotSavedTitle => 'לא נשמר';

  @override
  String get settingsAiChooseProviderBody => 'בחר ספק.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'ספק מותאם אישית דורש כתובת API.';

  @override
  String get settingsAiKeyRequiredBody => 'הזן מפתח API.';

  @override
  String get settingsAiSavedBody => 'הגדרות ה-AI שלך נשמרו.';

  @override
  String get settingsAiMissingDetailsTitle => 'פרטים חסרים';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'הזן כתובת API ודגם צ\'אט לבדיקה.';

  @override
  String get settingsAiKeyNeededTitle => 'נדרש מפתח API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'הזן את מפתח ה־API שלך לביקורון. המפתח ששמרת נשאר פרטי.';

  @override
  String get settingsAiKeyToTestBody => 'הזן את מפתח ה־API שלך לביקורון.';

  @override
  String get settingsAiConnectedTitle => 'מחובר';

  @override
  String get settingsAiConnectedBody => 'החיבור עובד.';

  @override
  String get settingsAiTestFailedTitle => 'הבדיקה נכשלה';

  @override
  String get settingsPreferencesSavedBody => 'ההעדפות שלך נשמרו.';

  @override
  String get settingsPasswordNotChangedTitle => 'הסיסמה לא שונתה';

  @override
  String get settingsOAuthPasswordBody =>
      'החשבון הזה נכנס עם Google או Apple. השתמש ב־\"שכחת סיסמה\" כדי להגדיר תחילה סיסמה.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'הסיסמה הנוכחית אינה נכונה.';

  @override
  String get settingsExportReadyTitle => 'הייצוא מוכן';

  @override
  String get settingsExportReadyBody => 'ייצוא הנתונים שלך מוכן להורדה.';

  @override
  String get settingsLinkCopiedTitle => 'הקישור הועתק';

  @override
  String get settingsExportClipboardBody =>
      'לא הצלחנו לפתוח את הדפדפן שלך, ולכן העתקנו את קישור ההורדה. הדבק אותו בדפדפן בהקדם: התוקף שלו מתפוגג.';

  @override
  String get settingsExportFailedTitle => 'הייצוא נכשל';

  @override
  String get settingsAccountNotDeletedTitle => 'החשבון לא נמחק';

  @override
  String photoshootPhotoLimit(int max) {
    return 'אפשר להוסיף עד $max תמונות.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'גבול תמונות';

  @override
  String get photoshootAddAtLeastOnePhoto => 'הוסף לפחות תמונה אחת.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'אין תמונות';

  @override
  String get photoshootDescribeLookBody => 'תיאור המראה הרצוי שלך.';

  @override
  String get photoshootPromptNeededTitle => 'נדרש פרומפט';

  @override
  String get photoshootConsentFeatureLabel => 'צילומי AI';

  @override
  String get photoshootStatusPreparing => 'מכין את התמונות שלך';

  @override
  String get photoshootStatusGenerating => 'מייצר';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'צבוע $current מתוך $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done מתוך $total הושלמו';
  }

  @override
  String get photoshootGenerationFailedBody => 'היצירה נכשלה.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready מוכנות, $failed נכשלו.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'הושלם חלקית';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תמונות מוכנות.',
      one: 'תמונה אחת מוכנה.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => 'החיבור אבד. נסו שוב.';

  @override
  String get photoshootCouldNotCancelTitle => 'לא ניתן לבטל';

  @override
  String get photoshootRetryFailedTitle => 'הניסיון נכשל';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'התמונה $number מוכנה.';
  }

  @override
  String get photoshootReplacedTitle => 'הוחלף';

  @override
  String get photoshootSavedToGalleryBody => 'נשמר בספרייה שלך.';

  @override
  String get photoshootSavedTitle => 'נשמר';

  @override
  String get photoshootNotSavedTitle => 'לא נשמר';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'כל $count התמונות נשמרו בספרייה שלך.',
      one: 'תמונה אחת נשמרה בספרייה שלך.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved מתוך $total נשמרו.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'חלק מהתמונות לא נשמרו';

  @override
  String get tryonConsentFeatureLabel => 'ניסוי וירטואלי';

  @override
  String get tryonAvatarUpdatedBody => 'התמונה עודכנה.';

  @override
  String get tryonSavedTitle => 'נשמר';

  @override
  String get tryonUploadFailedTitle => 'העלאה נכשלה';

  @override
  String get tryonChooseGarmentFirstBody => 'בחרו תמונה של בגד קודם כל.';

  @override
  String get tryonNoGarmentTitle => 'אין בגד';

  @override
  String get tryonWaitForUploadBody => 'המתינו עד שהעלאת התמונה תושלם.';

  @override
  String get tryonStillUploadingTitle => 'עדיין מעלה';

  @override
  String get tryonAddYourPhotoFirstBody => 'הוסיפו תמונה שלכם קודם כל.';

  @override
  String get tryonReadyBody => 'הניסוי מוכן.';

  @override
  String get tryonFailedTitle => 'הניסוי נכשל';

  @override
  String get tryonSavedToGalleryBody => 'נשמר בספרייה שלך.';

  @override
  String get tryonNotSavedTitle => 'לא נשמר';

  @override
  String get calendarEventAddedBody => 'נשארת הוסיפה';

  @override
  String get calendarEventPlannedTitle => 'מתוכנן';

  @override
  String get calendarEventSavedBody => 'נשמר אירוע';

  @override
  String get calendarSavedTitle => 'נשמר';

  @override
  String get calendarEventNotSavedTitle => 'אירוע לא נשמר';

  @override
  String get calendarEventRemovedBody => 'נשארת הסירה';

  @override
  String get calendarEventDeletedTitle => 'נמחק';

  @override
  String get calendarEventNotDeletedTitle => 'האירוע לא נמחק';

  @override
  String get calendarOutfitNotLinkedTitle => 'הלבוש לא קושר';

  @override
  String get calendarLinkedTitle => 'קושר';

  @override
  String get calendarOutfitNotRemovedTitle => 'הלבוש לא הוסר';

  @override
  String get calendarOutfitRemovedBody => 'הלבוש הוסר';

  @override
  String get calendarDisconnectedBody => 'הלוחות ניתקו';

  @override
  String get calendarDisconnectedTitle => 'נישוק';

  @override
  String get calendarNotDisconnectedTitle => 'הלוח לא נישוק';

  @override
  String get calendarTodayLabel => 'היום';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count אירועים',
      one: '1 אירוע',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start עד $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, לבוש קושר';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '«$title» יוסר.';
  }

  @override
  String get calendarThisAppLabel => 'אפליקציה זו';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'סנכרון עם $provider אינו זמין כרגע. ניתן עדיין להוסיף אירועים כאן.';
  }

  @override
  String get calendarWeekdaySunShort => 'ראשון';

  @override
  String get calendarWeekdayMonShort => 'שני';

  @override
  String get calendarWeekdayTueShort => 'שלישי';

  @override
  String get calendarWeekdayWedShort => 'רביעי';

  @override
  String get calendarWeekdayThuShort => 'חמישי';

  @override
  String get calendarWeekdayFriShort => 'שישי';

  @override
  String get calendarWeekdaySatShort => 'שבת';

  @override
  String get calendarWeekdayMonday => 'יום שני';

  @override
  String get calendarWeekdayTuesday => 'יום שלישי';

  @override
  String get calendarWeekdayWednesday => 'יום רביעי';

  @override
  String get calendarWeekdayThursday => 'יום חמישי';

  @override
  String get calendarWeekdayFriday => 'יום שישי';

  @override
  String get calendarWeekdaySaturday => 'יום שבת';

  @override
  String get calendarWeekdaySunday => 'ראשון';

  @override
  String get outfitSavedToFavouritesBody => 'נשמר בתחומים';

  @override
  String get outfitRemovedFromFavouritesBody => 'סולח מחומים';

  @override
  String get outfitNotSavedTitle => 'לא נשמר';

  @override
  String get outfitLoggedAsWornBody => 'הוגדר כנעשה היום.';

  @override
  String get outfitNicePickTitle => 'בחירה טובה';

  @override
  String get outfitRemovedBody => 'הלבוש נמחק.';

  @override
  String get outfitDeletedTitle => 'נמחק';

  @override
  String get outfitNotDeletedTitle => 'לא נמחק';

  @override
  String get outfitDuplicatedBody => 'עותק נמצא במלתחה שלך.';

  @override
  String get outfitDuplicatedTitle => 'הוכפל';

  @override
  String get outfitNotDuplicatedTitle => 'לא הוכפל';

  @override
  String get outfitNotSharedTitle => 'לא שותף';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" מוכן.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'אוסף לא נוצר';

  @override
  String get outfitCollectionUpdatedBody => 'האוסף עודכן.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'האוסף לא עודכן';

  @override
  String get outfitCollectionDeletedBody => 'האוסף נמחק.';

  @override
  String get outfitCollectionNotDeletedTitle => 'האוסף לא נמחק';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ערכות נוספו.',
      one: 'ערכה אחת נוספה.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'ערכות לא נוספו';

  @override
  String get outfitPreviewNotCreatedTitle => 'תצוגה מקדימה לא נוצרה';

  @override
  String get outfitGiveNameBody => 'נתן שם לערכה.';

  @override
  String get outfitNameMissingTitle => 'שם';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'בחר לפחות פריט אחד.';

  @override
  String outfitCreatedBody(String name) {
    return '$name נמצא בערכות שלך.';
  }

  @override
  String get outfitSavedTitle => 'נשמר';

  @override
  String get wardrobeAddedToFavouritesBody => 'נוסף לתחומים';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'סולח מחומים';

  @override
  String get wardrobeNotSavedTitle => 'לא נשמר';

  @override
  String get wardrobeLoggedAsWornBody => 'נרשם כנלבש היום.';

  @override
  String get wardrobeRemovedFromClosetBody => 'הוסר מהאגף שלך.';

  @override
  String get wardrobeDeletedTitle => 'נמחק';

  @override
  String get wardrobeNotDeletedTitle => 'לא נמחק';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פריטים הוסרו מהאגף שלך.',
      one: 'פריט אחד הוסר מהאגף שלך.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'כיולת תלבושות באמצעות AI';

  @override
  String get itemAddScanJobLabel => 'סריקה';

  @override
  String get itemAddFoundEarlierBody => 'נמצא בסריקה קודמת';

  @override
  String get itemAddLookingAtPhoto => 'מבט על התמונה שלך';

  @override
  String get itemAddExtractionFailedBody => 'העמקה נכשלה';

  @override
  String get itemAddJobFailedBody => 'המשימה נכשלה';

  @override
  String get itemAddConnectionLostBody => 'החיבור אבד. נסה שוב.';

  @override
  String get itemAddConnectionLostProcessingBody => 'החיבור אבד בזמן עיבוד.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'פריט $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'פריט';

  @override
  String get itemAddNotCancelledTitle => 'לא בוטל';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count פריטים נמצאים באגף שלך.',
      one: 'פריט אחד נמצא באגף שלך.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved מתוך $total פריטים נשמרו. נא לשמור כדי לנסות את השאר שוב.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'חלק מהפריטים לא נשמרו';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'בחר לפחות תמונה אחת.';

  @override
  String get batchPhotoUnreadableBody => 'לא ניתן לקרוא תמונה זו.';

  @override
  String get batchNoPhotosReadableBody =>
      'אף אחת מהתמונות האלה לא ניתנה לקריאה. נסה תמונות אחרות.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תמונות',
      one: 'תמונה אחת',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'אבדנו חיבור בעת עבודה. נסה שוב.';

  @override
  String get batchNotCancelledTitle => 'לא בוטל';

  @override
  String get batchPostLinkUnsupportedBody =>
      'לעמודים אין תמיכה בקישורים. נא להזין קישור פרופיל.';

  @override
  String get batchLinkSpacesBody => 'קישורים לא יכולים להכיל רווחים.';

  @override
  String get batchEnterProfileLinkBody =>
      'הזן קישור פרופיל של אינסטגרם או פייסבוק.';

  @override
  String get batchEnterProfileLinkShortBody => 'הזן קישור פרופיל.';

  @override
  String get batchSignInPageNotOpenBody => 'עמוד הכניסה לא נפתח. נסה שוב.';

  @override
  String get batchSignInBrowserBody => 'התחבר בדפדפן, ואז חזור ל-FitCheck.';

  @override
  String get batchConnectAccountTitle => 'חבר את החשבון שלך';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'הזן את הקוד מיישומי האימות שלך.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'אינסטגרם דורש בדיקת אבטחה. התחבר בדפדפן תחילה.';

  @override
  String get batchEnterCredentialsAgainBody => 'הזן שוב את שם המשתמש והסיסמה.';

  @override
  String get batchSignInFailedBody => 'התחברות נכשלה. בדוק שם משתמש וסיסמה.';

  @override
  String get batchSignInToKeepImportingBody => 'התחבר כדי להמשיך עם ייבוא.';

  @override
  String get batchAccountNotConnectedBody => 'החשבון לא נחוץ.';

  @override
  String get batchAccountConnectedTitle => 'החשבון נחוץ';

  @override
  String get batchNotConnectedTitle => 'לא מחובר';

  @override
  String get batchImportConnectionLostBody => 'החיבור לייבוא נותק. רענן לבדוק.';

  @override
  String batchPickUpToBody(int max) {
    return 'בחר עד $max תמונות. נמצא את הפריטים.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count מתוך $total תמונות';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'מכינ תמונה $done מתוך $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'מצא פריטים ב-$count תמונות',
      one: 'מצא פריטים בתמונה אחת',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'חשבון ה-$platform שלך משתמש בהתחברות דו־שלבית. הזן את קוד ה־6 ספרות מיישומי האימות.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'פרופיל $platform זה פרטי או דורש התחברות להצגת תמונות.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'חבר עם $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נמצאו $count תמונות כעת',
      one: 'נמצאה תמונה אחת כעת',
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
    return '$processed מתוך $total התפרסמו · $added נוספו · $waiting ממתינים · $skipped דולגו';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'סורק תמונה $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'תמונה $number הבאה';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'תמונה $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נמצאו $count פריטים',
      one: 'נמצא פריט אחד',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נוספו $count תמונות לארון שלך.',
      one: 'נוסף תמונה אחת לארונך.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count תמונות סטודיו נוספות בדרך. אפשר לשמור מהמוכן, או להתנתק — נעדכן.',
      one: 'תמונת סטודיו נוספת בדרך. אפשר לשמור מהמוכן, או להתנתק — נעדכן.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'עדיין לא נשמר: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces פריטים',
      one: 'פריט אחד',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos תמונות',
      one: 'תמונה אחת',
    );
    return '$_temp0 מתוך $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen נבחרו. ליש פריט לדלג עליו.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'שומר $count פריטים',
      one: 'שומר פריט אחד',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'שמירה של $count פריטים',
      one: 'שמירה של פריט אחד',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'פרופיל הגוף שלך נשמר.';

  @override
  String get bodyProfileSavedTitle => 'נשמר';

  @override
  String get bodyProfileNotSavedTitle => 'לא נשמר';

  @override
  String get bodyProfileSetDefaultBody => 'קבע כפרופיל ברירת המחדל שלך.';

  @override
  String get bodyProfileDeletedBody => 'פרופיל הגוף נמחק.';

  @override
  String get bodyProfileDeletedTitle => 'נמחק';

  @override
  String get bodyProfileNotDeletedTitle => 'לא נמחק';

  @override
  String get feedbackNotSentTitle => 'לא נשלח';

  @override
  String get feedbackSentBody =>
      'תודה. אנו קוראים לכל הודעה ומגיבים אם נדרש עוד.';

  @override
  String get feedbackSentTitle => 'המשוב נשלח';

  @override
  String get recommendUnnamedPiece => 'פריט ללא שם';

  @override
  String get recommendEnterCityBody => 'הזן את עירך כדי לקבל המלצות לweather.';

  @override
  String get recommendWhichCityTitle => 'איזו עיר?';

  @override
  String get aiConsentSheetTitle => 'שיתוף תמונות עם שירות AI';

  @override
  String get aiConsentSheetBody =>
      'כדי ליצור תמונות ניסיון וצילום, FitCheck AI שולח את התמונות שמספקים (כולל תמונות של הפנים והגוף שלך) לספק AI של צד שלישי אמין (כגון OpenAI או Google Gemini) לעיבוד. הם יוצרים את התמונות שלך ואינם משתמשים בהן לאימון הדגמים שלהם תחת הנוהלים שלנו. התמונות מועברות באבטחה ולא משתפות לעולם עבור פרסום.';

  @override
  String get aiConsentSheetPermission =>
      'על ידי המשך, אתה נותן הרשאה מפורשת לשיתוף התמונות שלך עם ספקי AI אלה ליצירת תמונות.';

  @override
  String get skeletonsLoadMoreFailed => 'לא ניתן לטעון עוד.';

  @override
  String get jobsPiecesReadyTitle => 'הפריטים שלך מוכנים';

  @override
  String get jobsScanStoppedTitle => 'הסריקה עצרה';

  @override
  String get jobsNothingSavedBody => 'שום דבר לא נשמר. נסה שוב.';

  @override
  String get jobsPhotoUploadFailedBody => 'העלאת התמונה נכשלה.';

  @override
  String get authGoogleSignInStartFailed =>
      'לא ניתן להתחיל התחברות גוגל. נסה שוב.';

  @override
  String get referralAppliedTitle => 'הפניה הוחלה!';

  @override
  String get billingStoreUnavailableBody =>
      'רכישות בחנות אינן זמינות במכשיר זה.';

  @override
  String get billingPurchaseProcessingBody =>
      'הרכישה הזו עדיין בתהליך עיבוד. פתח מחדש את האפליקציה בעוד דקה כדי לראות את התוכנית שלך.';

  @override
  String get profileAvatarUploadNoUrl =>
      'העלאת האבטגר לא החזירה כתובת URL של תמונה.';

  @override
  String get rewardsDayStreakLabel => 'רצף ימים';

  @override
  String rewardsBestStreak(int days) {
    return 'הרצף הטוב ביותר של $days ימים';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'נדרש גישה ל$permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'הגישה ל־$permission מוגבלת כרגע. פתח את ההגדרות כדי לאפשר גישה, ואז חזור והמשיך מנסה.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'שלב $step מתוך 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'שלב $step מתוך $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'הסרת תמונה $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'הסרת תמונה $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points נקודות';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'שלח מייל ל־$email. אנו בודקים דיווחים תוך 24 שעות.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'הסרת $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'למחוק \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'הוספה ל־\"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" הוסר. הפריטים נשארים במבגד שלך.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'הצגת כל $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'נשארו $count היום';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'התמונה $index נכשלה';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected מתוך $max תמונות';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape מבנה · גוון $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'למחוק $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'אפשרויות ל־$name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'נמסה הכי הרבה: $name, $count פעמים';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: לא מוגדר';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'התאמה $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked מתוך $max נבחרו';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'הסרת $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'עדיפות $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'המנוי הזה מתבצע דרך $store. ניתן לשנות או לבטל זאת בהגדרות החשבון ב־$store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'ניהול דרך $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: בנצל $current מתוך $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'נשארו עוד כ־$seconds שניות';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done מתוך $total תמונות סטודיו מוכנות';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready מתוך $total תמונות סטודיו מוכנות. נקו על פריט כדי לדלג עליו.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height ס\"מ · $weight ק\"ג';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'לא';
}
