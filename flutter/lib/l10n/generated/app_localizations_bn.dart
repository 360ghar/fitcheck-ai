// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'হোম';

  @override
  String get tabPhotoshoot => 'ফটোশুট';

  @override
  String get tabCloset => 'ক্লোজেট';

  @override
  String get tabOutfits => 'আউটফিট';

  @override
  String get tabMore => 'আরও';

  @override
  String get actionAddItem => 'আইটেম যোগ করুন';

  @override
  String get actionCreateOutfit => 'আউটফিট তৈরি করুন';

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get actionDelete => 'মুছে ফেলুন';

  @override
  String get actionSave => 'সংরক্ষণ করুন';

  @override
  String get actionRetry => 'পুনরায় চেষ্টা করুন';

  @override
  String get actionDone => 'সম্পন্ন';

  @override
  String get actionNext => 'পরবর্তী';

  @override
  String get actionBack => 'পিছনে';

  @override
  String get actionClose => 'বন্ধ করুন';

  @override
  String get actionSearch => 'অনুসন্ধান';

  @override
  String get actionContinue => 'চালিয়ে যান';

  @override
  String get stateLoading => 'লোড হচ্ছে';

  @override
  String get stateErrorTitle => 'কিছু ভুল হয়েছে';

  @override
  String get stateErrorBody =>
      'আবার চেষ্টা করুন। সমস্যা হলে সাপোর্টে যোগাযোগ করুন।';

  @override
  String get stateOfflineTitle => 'আপনি অফলাইনে আছেন';

  @override
  String get stateOfflineBody =>
      'ক্লোজেট সিঙ্ক এবং আউটফিট তৈরি করতে ইন্টারনেট সংযোগ দিন।';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsAccountSection => 'অ্যাকাউন্ট';

  @override
  String get settingsPreferencesSection => 'পছন্দ';

  @override
  String get settingsPlanBilling => 'প্ল্যান এবং বিলিং';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsNotifications => 'নোটিফিকেশন';

  @override
  String get settingsUnits => 'পরিমাপের একক';

  @override
  String get settingsAppearance => 'অ্যাপের রূপ';

  @override
  String get settingsPrivacySection => 'গোপনীয়তা ও ডেটা';

  @override
  String get settingsAboutSection => 'সম্পর্কে';

  @override
  String get settingsSignOut => 'সাইন আউট';

  @override
  String get settingsDeleteAccount => 'অ্যাকাউন্ট মুছে ফেলুন';

  @override
  String get settingsDeleteAccountTitle => 'আপনার অ্যাকাউন্ট মুছে ফেলবেন?';

  @override
  String get settingsDeleteAccountBody =>
      'এটি আপনার ক্লোজেট, আউটফিট, ছবি এবং প্রোফাইল মুছে ফেলবে। এটি আর পুনরুদ্ধার করা যাবে না।';

  @override
  String get settingsUnitsImperial => 'ইম্পেরিয়াল (ইঞ্চি, পাউন্ড)';

  @override
  String get settingsUnitsMetric => 'মেট্রিক (সেমি, কেজি)';

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get languageSystem => 'ডিভাইসের ভাষা ব্যবহার করুন';

  @override
  String get languageSystemBody => 'FitCheck AI আপনার ফোনের ভাষা অনুসরণ করে।';

  @override
  String get languageSearchHint => 'ভাষা খুঁজুন';

  @override
  String get languageCurrent => 'বর্তমান';

  @override
  String get languageReviewNote =>
      'এই অনুবাদটি নতুন। কোনো ভুল থাকলে আমাদের জানান।';

  @override
  String get languageChanged => 'ভাষা আপডেট করা হয়েছে';

  @override
  String get paywallTitle => 'আপনার প্ল্যান বেছে নিন';

  @override
  String get paywallTrialBadge => '১ মাস ফ্রি';

  @override
  String get paywallTrialTitle => 'আপনার প্রথম মাস Pro ফ্রি';

  @override
  String get paywallTrialBody =>
      'একবারে আপনার পুরো ক্লোজেট আপলোড করুন। এরপর প্রয়োজনমতো নতুন পোশাক যোগ করুন।';

  @override
  String get paywallFreeForeverTitle => 'সবসময় ফ্রি';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'কার্ডের প্রয়োজন নেই। প্রতি মাসে আপনি পাবেন $uploads টি AI আপলোড, $outfits টি আউটফিট এবং প্রতিদিন $images টি ফটোশুট ইমেজ।';
  }

  @override
  String get paywallCtaTrial => 'আমার ফ্রি মাস শুরু করুন';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan এ আপগ্রেড করুন';
  }

  @override
  String get paywallRestore => 'কেনাকাটা পুনরুদ্ধার করুন';

  @override
  String get paywallManage => 'সাবস্ক্রিপশন ম্যানেজ করুন';

  @override
  String get paywallTerms => 'ব্যবহারের শর্তাবলী';

  @override
  String get paywallPrivacy => 'গোপনীয়তা নীতি';

  @override
  String get paywallPerMonth => 'প্রতি মাসে';

  @override
  String get paywallPerYear => 'প্রতি বছর';

  @override
  String get paywallBestValue => 'সেরা মূল্য';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'শুধুমাত্র নতুন গ্রাহকদের জন্য ফ্রি ট্রায়াল। ট্রায়াল শেষ হওয়ার অন্তত ২৪ ঘণ্টা আগে বাতিল না করলে, Pro $price মূল্যে রিনিউ হবে।';
  }

  @override
  String get introTitle => 'আপনার আলমারি, অবশেষে গোছানো';

  @override
  String get introBody =>
      'আপনার পোশাকের ছবি তুলুন। আপনার কাছে থাকা পোশাক থেকেই আউটফিট আইডিয়া, ট্রাই-অন প্রিভিউ এবং স্টুডিও ফটো পান।';

  @override
  String get introStart => 'শুরু করুন';

  @override
  String get introHaveAccount => 'আমার আগে থেকেই অ্যাকাউন্ট আছে';

  @override
  String get introSkip => 'এড়িয়ে যান';

  @override
  String get authSignIn => 'সাইন ইন';

  @override
  String get authSignUp => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authEmail => 'ইমেইল';

  @override
  String get authPassword => 'পাসওয়ার্ড';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get authContinueApple => 'Apple দিয়ে চালিয়ে যান';

  @override
  String get authContinueGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get authOrDivider => 'অথবা';

  @override
  String get wardrobeTitle => 'ক্লোজেট';

  @override
  String get wardrobeEmptyTitle => 'আপনার ক্লোজেট খালি';

  @override
  String get wardrobeEmptyBody =>
      'আপনার প্রথম পোশাকটি যোগ করুন, অথবা পুরো র‍্যাকের একটি ছবি আপলোড করুন।';

  @override
  String get wardrobeAddFirst => 'প্রথম আইটেম যোগ করুন';

  @override
  String get wardrobeSearchHint => 'আপনার ক্লোজেট খুঁজুন';

  @override
  String get categoryTops => 'টপস';

  @override
  String get categoryBottoms => 'বটমস';

  @override
  String get categoryShoes => 'জুতো';

  @override
  String get categoryAccessories => 'অ্যাক্সেসরিজ';

  @override
  String get categoryOuterwear => 'আউটারওয়্যার';

  @override
  String get categorySwimwear => 'সুইমওয়্যার';

  @override
  String get categoryActivewear => 'অ্যাক্টিভওয়্যার';

  @override
  String get categoryOther => 'অন্যান্য';

  @override
  String get conditionClean => 'পরিষ্কার';

  @override
  String get conditionDirty => 'নোংরা';

  @override
  String get conditionLaundry => 'লন্ড্রিতে';

  @override
  String get conditionRepair => 'মেরামত প্রয়োজন';

  @override
  String get conditionDonate => 'দান করার জন্য';

  @override
  String get seasonSpring => 'বসন্ত';

  @override
  String get seasonSummer => 'গ্রীষ্ম';

  @override
  String get seasonFall => 'শরৎ';

  @override
  String get seasonWinter => 'শীত';

  @override
  String get seasonAll => 'সব ঋতু';

  @override
  String get styleCasual => 'ক্যাজুয়াল';

  @override
  String get styleFormal => 'ফরমাল';

  @override
  String get styleBusiness => 'বিজনেস';

  @override
  String get styleSporty => 'স্পোর্টি';

  @override
  String get styleBohemian => 'বোহেমিয়ান';

  @override
  String get styleStreetwear => 'স্ট্রিটওয়্যার';

  @override
  String get styleVintage => 'ভিনটেজ';

  @override
  String get styleMinimalist => 'মিনিমালিস্ট';

  @override
  String get styleRomantic => 'রোমান্টিক';

  @override
  String get styleEdgy => 'এজি';

  @override
  String get stylePreppy => 'প্রেপি';

  @override
  String get styleArtsy => 'আর্টসি';

  @override
  String get styleClassic => 'ক্লাসিক';

  @override
  String get styleElegant => 'এলিগ্যান্ট';

  @override
  String get styleOther => 'অন্যান্য';

  @override
  String get occasionWork => 'অফিস';

  @override
  String get occasionDateNight => 'ডেট নাইট';

  @override
  String get occasionTravel => 'ভ্রমণ';

  @override
  String get occasionWedding => 'বিয়ে';

  @override
  String get occasionGym => 'জিম';

  @override
  String get occasionWeekend => 'উইকেন্ড';

  @override
  String get occasionParty => 'পার্টি';

  @override
  String get occasionInterview => 'ইন্টারভিউ';

  @override
  String get colorBlack => 'কালো';

  @override
  String get colorWhite => 'সাদা';

  @override
  String get colorGrey => 'ধূসর';

  @override
  String get colorNavy => 'নেভি';

  @override
  String get colorBrown => 'বাদামী';

  @override
  String get colorRed => 'লাল';

  @override
  String get colorBlue => 'নীল';

  @override
  String get colorGreen => 'সবুজ';

  @override
  String get colorPink => 'গোলাপি';

  @override
  String get colorPurple => 'বেগুনি';

  @override
  String get colorYellow => 'হলুদ';

  @override
  String get colorOrange => 'কমলা';

  @override
  String get colorBeige => 'বেজ';

  @override
  String get dateToday => 'আজ';

  @override
  String get dateYesterday => 'গতকাল';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন আগে',
      one: '১ দিন আগে',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count সপ্তাহ আগে',
      one: '১ সপ্তাহ আগে',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মাস আগে',
      one: '১ মাস আগে',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count বছর আগে',
      one: '১ বছর আগে',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI ব্যবহার করে ভালো লাগছে?';

  @override
  String get ratingPromptBody =>
      'একটি রেটিং অন্যদের তাদের স্টাইল খুঁজে পেতে সাহায্য করবে।';

  @override
  String get ratingPromptYes => 'অ্যাপ রেট করুন';

  @override
  String get ratingPromptNo => 'এখন নয়';

  @override
  String get closetNoMatchesTitle => 'কোনো পোশাক মেলেনি';

  @override
  String get closetNoMatchesBody => 'ফিল্টার কমিয়ে দেখুন বা অন্য কিছু খুঁজুন।';

  @override
  String get closetClearFilters => 'ফিল্টার মুছুন';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পোশাক',
      one: '১টি পোশাক',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'পোশাক লোড হচ্ছে';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি নির্বাচিত',
      one: '১টি নির্বাচিত',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'নির্বাচিতগুলো মুছুন';

  @override
  String get closetCancelSelection => 'নির্বাচন বাতিল';

  @override
  String get closetCloseSearch => 'অনুসন্ধান বন্ধ';

  @override
  String get closetShowGrid => 'গ্রিড ভিউ';

  @override
  String get closetShowList => 'তালিকা ভিউ';

  @override
  String get closetShowRows => 'সারি ভিউ';

  @override
  String get closetStatsTitle => 'ক্লোসেট পরিসংখ্যান';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম মুছবেন?',
      one: '১টি আইটেম মুছবেন?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'এগুলো যে আউটফিটে আছে তা থেকে মুছে যাবে।';

  @override
  String get closetSortBy => 'সর্ট করুন';

  @override
  String get closetFavourites => 'প্রিয়';

  @override
  String get closetFavourite => 'প্রিয়তে যোগ করুন';

  @override
  String get closetUnfavourite => 'প্রিয় থেকে সরান';

  @override
  String get closetWoreToday => 'আজ পরেছি';

  @override
  String closetWornTimes(int count) {
    return '$count বার পরেছি';
  }

  @override
  String get closetCategoryLabel => 'বিভাগ';

  @override
  String get closetUseCaseLabel => 'ব্যবহারের উপলক্ষ';

  @override
  String get closetAnyUseCase => 'যেকোনো';

  @override
  String get closetOtherUseCase => 'অন্যান্য উপলক্ষ';

  @override
  String get closetOtherUseCaseHint => 'যেমন, ব্রাঞ্চ';

  @override
  String get closetUseUseCase => 'এটি ব্যবহার করুন';

  @override
  String get closetClearAll => 'সব মুছে ফেলুন';

  @override
  String get sortNewest => 'নতুনগুলো আগে';

  @override
  String get sortOldest => 'পুরানোগুলো আগে';

  @override
  String get sortName => 'নাম (A–Z)';

  @override
  String get sortMostWorn => 'সবচেয়ে বেশি ব্যবহৃত';

  @override
  String get useCaseInformal => 'অনানুষ্ঠানিক';

  @override
  String get useCaseDate => 'ডেট';

  @override
  String get useCaseDinner => 'ডিনার';

  @override
  String get useCaseLunch => 'লাঞ্চ';

  @override
  String get actionSelect => 'নির্বাচন করুন';

  @override
  String get actionEdit => 'সম্পাদনা';

  @override
  String get actionFilter => 'ফিল্টার';

  @override
  String get actionSort => 'সাজান';

  @override
  String get actionAll => 'সব';

  @override
  String get dashboardStartClosetTitle => 'আপনার ক্লোজেট শুরু করুন';

  @override
  String get dashboardStartClosetBody =>
      'কিছু পোশাকের ছবি তুলুন। আমরা সেগুলোকে ট্যাগ করে দেব।';

  @override
  String get dashboardPieces => 'পোশাক';

  @override
  String get dashboardOutfits => 'আউটফিট';

  @override
  String get dashboardDayStreak => 'দিনের ধারাবাহিকতা';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'এই মাসে +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'সেরা $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্রিয়',
      one: '১টি প্রিয়',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সেভ করা আউটফিট',
      one: '১টি সেভ করা আউটফিট',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'সবচেয়ে বেশি পরা: $name, $count বার';
  }

  @override
  String get setupSkip => 'সেটআপ এড়িয়ে যান';

  @override
  String get setupWhoTitle => 'আমরা কার স্টাইলিং করছি?';

  @override
  String get setupWhoBody =>
      'ট্রাই-অন এবং ফটোশুটের জন্য মডেল সেট করে। আপনি প্রোফাইল থেকে এটি পরিবর্তন করতে পারবেন।';

  @override
  String get setupStyleTitle => 'আপনি সাধারণত কী পরেন?';

  @override
  String get setupStyleBody =>
      'যেকোনো একটি বেছে নিন। এগুলো থেকে আউটফিট আইডিয়া শুরু হয়।';

  @override
  String get setupClosetTitle => 'আপনার প্রথম পোশাক যোগ করুন।';

  @override
  String get setupClosetBody =>
      'কিছু পোশাকের ছবি তুলুন। প্রতিটি পোশাক আলাদা করে সাজিয়ে রাখা হবে।';

  @override
  String get setupAddClothes => 'পোশাক যোগ করুন';

  @override
  String get setupStylesLabel => 'স্টাইল';

  @override
  String get setupOccasionsLabel => 'অনুষ্ঠান';

  @override
  String get setupSkipStep => 'এড়িয়ে যান';

  @override
  String get setupLater => 'পরে';

  @override
  String get setupSaveError => 'সেভ করা যায়নি';

  @override
  String get genderWomen => 'নারী';

  @override
  String get genderMen => 'পুরুষ';

  @override
  String get genderNonBinary => 'নন-বাইনারি';

  @override
  String get genderPreferNotToSay => 'বলতে অনিচ্ছুক';

  @override
  String get outfitEmptyTitle => 'কোনো আউটফিট নেই';

  @override
  String get outfitEmptyBody => 'আপনার ক্লোজেট থেকে পোশাক মিলিয়ে লুক সেভ করুন।';

  @override
  String get outfitNoMatchesTitle => 'কোনো আউটফিট মেলেনি';

  @override
  String get outfitSearchHint => 'আপনার আউটফিট খুঁজুন';

  @override
  String get outfitLoading => 'আউটফিট লোড হচ্ছে';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আউটফিট',
      one: '১টি আউটফিট',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'স্টাইল ও সিজন';

  @override
  String get outfitCollections => 'কালেকশন';

  @override
  String get outfitDuplicate => 'ডুপ্লিকেট';

  @override
  String get outfitDeleteTitle => 'এই আউটফিটটি মুছে ফেলবেন?';

  @override
  String get outfitDeleteBody => 'এর পোশাকগুলো আপনার ক্লোজেটেই থাকবে।';

  @override
  String get outfitDrafts => 'ড্রাফট';

  @override
  String get outfitDraft => 'ড্রাফট';

  @override
  String get filterStyle => 'স্টাইল';

  @override
  String get filterSeason => 'সিজন';

  @override
  String get itemDetailDeleteTitle => 'এই পোশাকটি মুছে ফেলবেন?';

  @override
  String get itemDetailDeleteBody =>
      'যেসব আউটফিটে এটি আছে, সেখান থেকে এটি সরে যাবে।';

  @override
  String get itemAddFavourite => 'ফেভারিটে যোগ করুন';

  @override
  String itemSize(String size) {
    return 'সাইজ $size';
  }

  @override
  String get itemColours => 'রঙ';

  @override
  String get itemMaterial => 'উপাদান';

  @override
  String get itemPattern => 'প্যাটার্ন';

  @override
  String get itemUseCases => 'ব্যবহার';

  @override
  String get itemKeptIn => 'যেখানে রাখা হয়েছে';

  @override
  String get itemPrice => 'দাম';

  @override
  String get itemBought => 'কেনার তারিখ';

  @override
  String get itemTags => 'ট্যাগ';

  @override
  String get itemAdded => 'যোগ করা হয়েছে';

  @override
  String get itemTimesWornLabel => 'কতবার পরা হয়েছে';

  @override
  String get itemLastWornLabel => 'সর্বশেষ পরা হয়েছে';

  @override
  String get itemNeverWorn => 'কখনও না';

  @override
  String get authEntryBody =>
      'আপনার সব পোশাক, AI দ্বারা স্টাইল করা। আউটফিট পরিকল্পনা করুন, ট্রাই করুন, ছবি তুলুন।';

  @override
  String get authCreateCloset => 'আপনার ক্লোজেট তৈরি করুন';

  @override
  String get authWelcomeBack => 'আবার স্বাগতম';

  @override
  String get authSignInBody => 'আপনার ক্লোজেট খুলতে সাইন ইন করুন।';

  @override
  String get authCreateAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get authCreateClosetBody =>
      'এক মিনিট সময় লাগবে। প্রথম কয়েকটি আইটেম ফ্রি।';

  @override
  String get authName => 'নাম';

  @override
  String get authConfirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get authReferralCode => 'রেফারেল কোড (ঐচ্ছিক)';

  @override
  String get authResetTitle => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get authResetBody => 'নতুন পাসওয়ার্ড সেট করার লিঙ্ক আমরা ইমেইল করব।';

  @override
  String get authSendResetLink => 'রিসেট লিঙ্ক পাঠান';

  @override
  String get authBackToSignIn => 'সাইন ইন-এ ফিরে যান';

  @override
  String get authEnterEmail => 'আপনার ইমেইল লিখুন';

  @override
  String get authEnterValidEmail => 'সঠিক ইমেইল লিখুন';

  @override
  String get authEnterPassword => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get authPasswordTooShort => 'কমপক্ষে ৬টি অক্ষর';

  @override
  String get authShowPassword => 'পাসওয়ার্ড দেখুন';

  @override
  String get authHidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get authNewHere => 'নতুন এসেছেন?';

  @override
  String authConfirmEmail(String email) {
    return 'সাইন ইন করার আগে $email নিশ্চিত করুন। আপনার ইনবক্স চেক করুন।';
  }

  @override
  String get authResendEmail => 'আবার পাঠান';

  @override
  String get authResendingEmail => 'পাঠানো হচ্ছে...';

  @override
  String get authPasswordsDoNotMatch => 'পাসওয়ার্ড মিলছে না';

  @override
  String get authEnterName => 'আপনার নাম লিখুন';

  @override
  String get authChoosePassword => 'পাসওয়ার্ড বেছে নিন';

  @override
  String get authHaveAccount => 'অ্যাকাউন্ট আছে?';

  @override
  String get authCodeAccepted => 'কোড গৃহীত হয়েছে';

  @override
  String get authCodeNotFound => 'কোডটি পাওয়া যায়নি';

  @override
  String authReferralFrom(String name) {
    return '$name-এর পক্ষ থেকে। আপনারা দুজনেই এক মাস ফ্রি পাবেন।';
  }

  @override
  String get authReferralInvalid => 'আমরা এই কোডটি খুঁজে পাইনি।';

  @override
  String authResetSent(String email) {
    return '$email-এ পাঠানো হয়েছে। এই ফোনে লিঙ্কটি খুলুন।';
  }

  @override
  String get introSlide1Title => 'আপনার আলমারির ছবি তুলুন।';

  @override
  String get introSlide1Body =>
      'পোশাকের স্তূপের ছবি তুলুন। প্রতিটি পোশাক আলাদা করে সাজিয়ে রাখা হবে।';

  @override
  String get introSlide2Title => 'দ্রুত তৈরি হন।';

  @override
  String get introSlide2Body =>
      'আপনার পোশাক থেকে আবহাওয়ার সাথে মানানসই সাজ বেছে নিন।';

  @override
  String get introSlide3Title => 'পরার আগেই দেখে নিন।';

  @override
  String get introSlide3Body =>
      'নিজের ছবিতে লুক ট্রাই করুন অথবা ক্যাম্পেইনের মতো ছবি তুলুন।';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsThemeSystem => 'সিস্টেম';

  @override
  String get settingsThemeLight => 'লাইট';

  @override
  String get settingsThemeDark => 'ডার্ক';

  @override
  String get settingsTemperature => 'তাপমাত্রা';

  @override
  String get settingsEmailUpdates => 'ইমেইল আপডেট';

  @override
  String get settingsEmailUpdatesBody => 'ইমেইলে খবর ও টিপস';

  @override
  String get settingsOutfitReminders => 'আউটফিট রিমাইন্ডার';

  @override
  String get settingsOutfitRemindersBody =>
      'কী পরেছেন তা লগ করার জন্য নোটিফিকেশন';

  @override
  String get settingsWeeklySummary => 'সাপ্তাহিক সারাংশ';

  @override
  String get settingsWeeklySummaryBody => 'আপনার সপ্তাহের আউটফিট';

  @override
  String get settingsStyleSection => 'স্টাইল';

  @override
  String get settingsPreferredStyles => 'পছন্দের স্টাইল';

  @override
  String get settingsPreferredColours => 'পছন্দের রঙ';

  @override
  String get settingsNoneChosen => 'কিছুই বাছাই করা হয়নি';

  @override
  String get settingsPlanAiSection => 'প্ল্যান এবং AI';

  @override
  String get settingsPlanBillingBody => 'প্ল্যান, ব্যবহার এবং আপগ্রেড';

  @override
  String get settingsPlanUsageBody => 'প্ল্যান এবং ব্যবহার';

  @override
  String get settingsInviteFriends => 'বন্ধুদের আমন্ত্রণ জানান';

  @override
  String get settingsInviteFriendsBody =>
      'প্রতি বন্ধু যোগদানের জন্য এক মাস ফ্রি';

  @override
  String get settingsAiProvider => 'এআই প্রোভাইডার';

  @override
  String get settingsAiProviderBody =>
      'ট্যাগিং এবং ছবির জন্য আপনার নিজস্ব মডেল ব্যবহার করুন';

  @override
  String get settingsAppVersion => 'অ্যাপ ভার্সন';

  @override
  String get settingsPrivacyTerms => 'গোপনীয়তা এবং শর্তাবলী';

  @override
  String get settingsReportProblem => 'সমস্যা রিপোর্ট করুন';

  @override
  String get settingsChangePassword => 'পাসওয়ার্ড পরিবর্তন করুন';

  @override
  String get settingsExportData => 'আপনার ডেটা এক্সপোর্ট করুন';

  @override
  String get settingsExportBody =>
      'আপনার সেভ করা সবকিছুর একটি ফাইল তৈরি করে ডাউনলোড শুরু হবে।';

  @override
  String get settingsExportAction => 'এক্সপোর্ট';

  @override
  String get settingsCurrentPassword => 'বর্তমান পাসওয়ার্ড';

  @override
  String get settingsNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get settingsConfirmNewPassword => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get settingsEnterCurrentPassword => 'আপনার বর্তমান পাসওয়ার্ড দিন';

  @override
  String get settingsEnterNewPassword => 'একটি নতুন পাসওয়ার্ড দিন';

  @override
  String get settingsPasswordMin8 => 'কমপক্ষে ৮টি অক্ষর ব্যবহার করুন';

  @override
  String get settingsPasswordNeedsUpper => 'একটি বড় হাতের অক্ষর যোগ করুন';

  @override
  String get settingsPasswordNeedsLower => 'একটি ছোট হাতের অক্ষর যোগ করুন';

  @override
  String get settingsPasswordNeedsDigit => 'একটি সংখ্যা যোগ করুন';

  @override
  String get settingsPasswordsNoMatch => 'পাসওয়ার্ড মিলছে না';

  @override
  String get settingsChangeAction => 'পরিবর্তন করুন';

  @override
  String get itemAddSnapTitle => 'পোশাকের ছবি তুলুন';

  @override
  String get itemAddSnapBody =>
      'আমরা ছবি থেকে প্রতিটি পোশাক আলাদা করে স্টুডিও শট তৈরি করব।';

  @override
  String get itemAddCamera => 'ছবি তুলুন';

  @override
  String get itemAddGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get itemAddOtherWays => 'অন্যভাবে যোগ করুন';

  @override
  String get itemAddSeveral => 'একাধিক ছবি যোগ করুন';

  @override
  String get itemAddSeveralBody => 'একবারে ৫০টি পর্যন্ত';

  @override
  String get itemAddImportProfile => 'প্রোফাইল থেকে ইম্পোর্ট করুন';

  @override
  String get itemAddImportProfileBody => 'ইনস্টাগ্রাম বা ফেসবুক';

  @override
  String get itemAddEnterDetails => 'বিস্তারিত নিজে লিখুন';

  @override
  String get itemAddEnterDetailsBody => 'ছবির প্রয়োজন নেই';

  @override
  String get itemManualIntro =>
      'শুধু একটি নাম প্রয়োজন। বাকি তথ্য এখন বা পরে যোগ করুন।';

  @override
  String get itemManualNameHint => 'যেমন, নীল সুতির টি-শার্ট';

  @override
  String get itemManualEnterName => 'নাম লিখুন';

  @override
  String get itemManualNotes => 'নোট';

  @override
  String get itemManualBrand => 'ব্র্যান্ড';

  @override
  String get itemManualSize => 'সাইজ';

  @override
  String get itemManualEnterNumber => 'সংখ্যা লিখুন';

  @override
  String get itemManualSavePiece => 'সংরক্ষণ করুন';

  @override
  String get itemManualSaving => 'সংরক্ষণ করা হচ্ছে';

  @override
  String get itemManualSavedTitle => 'সংরক্ষিত';

  @override
  String itemManualSavedBody(String name) {
    return '$name আপনার ক্লোজেটে আছে।';
  }

  @override
  String get itemManualNotSaved => 'সংরক্ষণ করা হয়নি';

  @override
  String get itemManualAddUseCase => 'ব্যবহারের ক্ষেত্র যোগ করুন';

  @override
  String get itemManualAddUseCaseAction => 'ব্যবহারের ক্ষেত্র যোগ করুন';

  @override
  String get itemPhotos => 'ছবি';

  @override
  String get itemAddPhotos => 'ছবি যোগ করুন';

  @override
  String get itemNoPhotoYet =>
      'এখনও কোনো ছবি নেই। ছবি ছাড়াই সংরক্ষণ করতে পারেন।';

  @override
  String get itemRemovePhoto => 'ছবি সরান';

  @override
  String get itemRemovePiece => 'আইটেমটি সরান';

  @override
  String get filterConditionLabel => 'অবস্থা';

  @override
  String get photoshootStepPhotos => 'ছবি';

  @override
  String get photoshootStepSetup => 'সেটআপ';

  @override
  String get photoshootStepCreating => 'তৈরি হচ্ছে';

  @override
  String get photoshootStepResults => 'ফলাফল';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'ধাপ $current এর $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'একটি ছবি আপলোড হয়নি। নিচে আবার চেষ্টা করুন।';

  @override
  String photoshootManyFailed(int count) {
    return '$count টি ছবি আপলোড হয়নি। নিচে প্রতিটি আবার চেষ্টা করুন।';
  }

  @override
  String get photoshootFormat => 'ফরম্যাট';

  @override
  String get photoshootHowMany => 'কতগুলো';

  @override
  String get photoshootYourPrompt => 'আপনার প্রম্পট';

  @override
  String get photoshootPromptHint => 'ছাদের ওপর গোধূলি বেলা, লিনেন শার্ট';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবি তৈরি করুন',
      one: '১টি ছবি তৈরি করুন',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ছবি',
      one: 'ছবি',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'আজকের সীমা যাচাই করা সম্ভব হয়নি।';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan প্ল্যান: আজ $remainingটি বাকি, মোট $limitটি';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'ফ্রি';

  @override
  String get photoshootGallery => 'গ্যালারি';

  @override
  String get photoshootUseCamera => 'ক্যামেরা ব্যবহার করুন';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '$number নম্বর ছবি সরান';
  }

  @override
  String get photoshootNoPhotosTitle => 'কোনো ছবি পাওয়া যায়নি';

  @override
  String get photoshootNoPhotosBody =>
      'ছবি ছাড়াই শুট শেষ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get photoshootNewStyle => 'নতুন স্টাইল';

  @override
  String get photoshootNewPhotos => 'নতুন ছবি';

  @override
  String photoshootOpenPhoto(int number) {
    return '$number নম্বর ছবি খুলুন';
  }

  @override
  String get photoshootReportPhoto => 'ছবি রিপোর্ট করুন';

  @override
  String get photoshootSaveToGallery => 'গ্যালারিতে সেভ করুন';

  @override
  String get actionUpgrade => 'আপগ্রেড';

  @override
  String get referralLimitTitle => 'আজকের ছবির সীমা শেষ';

  @override
  String get referralLimitBody =>
      'আপনার ফ্রি ছবি আগামীকাল আবার আসবে। বন্ধুকে রেফার করুন এবং দুজনেই এক মাসের Pro ফ্রি পান।';

  @override
  String get referralLimitRefer => 'বন্ধুকে রেফার করুন';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'ডেটিং অ্যাপ';

  @override
  String get photoshootUsePortfolio => 'পোর্টফোলিও';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'এস্থেটিক';

  @override
  String get photoshootUseCustom => 'আপনার নিজস্ব প্রম্পট';

  @override
  String get photoshootDescLinkedin => 'কাজের জন্য প্রফেশনাল ছবি';

  @override
  String get photoshootDescDating => 'সহজ, উষ্ণ এবং স্বাভাবিক';

  @override
  String get photoshootDescPortfolio => 'এডিটোরিয়াল, হাই-ফ্যাশন লুক';

  @override
  String get photoshootDescInstagram => 'আপনার ফিডের জন্য লাইফস্টাইল শট';

  @override
  String get photoshootDescAesthetic => 'মুডি, শৈল্পিক ফ্রেম';

  @override
  String get photoshootDescCustom => 'আপনার পছন্দের লুক বর্ণনা করুন';

  @override
  String get aspectSquare => 'বর্গাকার';

  @override
  String get aspectPortrait => 'পোর্ট্রেট';

  @override
  String get aspectLandscape => 'ল্যান্ডস্কেপ';

  @override
  String get aspectTall => 'লম্বা';

  @override
  String get aspectWide => 'প্রশস্ত';

  @override
  String get tryOnAppBar => 'ভার্চুয়াল ট্রাই-অন';

  @override
  String get tryOnYourPhoto => 'আপনার ছবি';

  @override
  String get tryOnGarment => 'পোশাক';

  @override
  String get tryOnUploadingPhoto => 'আপনার ছবি আপলোড হচ্ছে';

  @override
  String get tryOnAddPhotoPrompt => 'আপনার একটি ফুল-বডি ছবি যোগ করুন';

  @override
  String get tryOnBodyPhotoHint => 'ফুল-বডি ছবি সবচেয়ে ভালো কাজ করে';

  @override
  String get tryOnAddPhoto => 'ছবি যোগ করুন';

  @override
  String get tryOnChangePhoto => 'ছবি পরিবর্তন করুন';

  @override
  String get tryOnPhotoLoadFailed => 'আপনার ছবিটি লোড করা যায়নি।';

  @override
  String get tryOnChooseGarment => 'পোশাকের ছবি বেছে নিন';

  @override
  String get tryOnChooseOneGarment => 'একটি পোশাকের ছবি বেছে নিন';

  @override
  String get tryOnGarmentHint =>
      'ফ্ল্যাট লে বা হ্যাঙ্গারে রাখা ছবি সবচেয়ে ভালো';

  @override
  String get tryOnChange => 'পরিবর্তন';

  @override
  String get tryOnCamera => 'ক্যামেরা';

  @override
  String get tryOnRemove => 'সরান';

  @override
  String get tryOnLookTitle => 'লুক';

  @override
  String get tryOnStyle => 'স্টাইল';

  @override
  String get tryOnBackground => 'ব্যাকগ্রাউন্ড';

  @override
  String get tryOnPose => 'পোজ';

  @override
  String get tryOnDressingUp =>
      'আপনাকে সাজানো হচ্ছে। এতে প্রায় আধা মিনিট সময় লাগবে।';

  @override
  String get tryOnEmptyResult => 'আপনার ট্রাই-অন এখানে দেখা যাবে';

  @override
  String get tryOnReportImage => 'ছবি রিপোর্ট করুন';

  @override
  String get tryOnCreating => 'তৈরি হচ্ছে';

  @override
  String get tryOnTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get tryOnCreate => 'ট্রাই-অন তৈরি করুন';

  @override
  String get tryOnBackgroundStudioWhite => 'স্টুডিও সাদা';

  @override
  String get tryOnBackgroundStudioGrey => 'স্টুডিও ধূসর';

  @override
  String get tryOnBackgroundUrban => 'শহুরে রাস্তা';

  @override
  String get tryOnBackgroundNature => 'প্রকৃতি';

  @override
  String get tryOnBackgroundMinimal => 'মিনিমাল';

  @override
  String get tryOnPoseFront => 'সামনের দিকে দাঁড়িয়ে';

  @override
  String get tryOnPoseSide => 'পাশ ফিরে দাঁড়িয়ে';

  @override
  String get tryOnPoseWalking => 'হাঁটার ভঙ্গি';

  @override
  String get dashboardGreetingMorning => 'শুভ সকাল';

  @override
  String get dashboardGreetingAfternoon => 'শুভ দুপুর';

  @override
  String get dashboardGreetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get dashboardWelcome => 'স্বাগতম';

  @override
  String get dashboardOpenProfile => 'প্রোফাইল খুলুন';

  @override
  String get dashboardRailToday => 'আজ';

  @override
  String get dashboardRailRecently => 'সম্প্রতি';

  @override
  String get dashboardActivityEmpty => 'নতুন পোশাক এবং আউটফিট এখানে দেখা যাবে।';

  @override
  String get quickAddPiece => 'পোশাক যোগ করুন';

  @override
  String get quickAddPieceBody => 'ছবি তুলুন ও ট্যাগ করুন';

  @override
  String get quickBuildOutfit => 'আউটফিট তৈরি করুন';

  @override
  String get quickBuildOutfitBody => 'পোশাক মিলিয়ে দেখুন';

  @override
  String get quickForYou => 'আপনার জন্য';

  @override
  String get quickForYouBody => 'আজকের পছন্দ';

  @override
  String get quickPlanWeek => 'সপ্তাহের পরিকল্পনা';

  @override
  String get quickPlanWeekBody => 'তারিখ অনুযায়ী আউটফিট';

  @override
  String get referralBannerUrgent => 'সীমিত? বন্ধুকে আমন্ত্রণ জানান।';

  @override
  String get referralBannerTitle => 'এক মাস দিন, এক মাস পান';

  @override
  String get referralBannerBody =>
      'আপনি এবং আপনার বন্ধু প্রত্যেকে এক মাসের Pro পাবেন';

  @override
  String get referralBannerDismiss => 'এক সপ্তাহের জন্য বন্ধ করুন';

  @override
  String get referralBannerShare => 'আমন্ত্রণ শেয়ার করুন';

  @override
  String get referralBannerCopy => 'লিঙ্ক কপি করুন';

  @override
  String get itemEditPieceTitle => 'পিস এডিট করুন';

  @override
  String get itemEditDescriptionLabel => 'বিবরণ';

  @override
  String get itemEditNotSaved => 'সেভ হয়নি';

  @override
  String get itemEditSavedTitle => 'সেভ হয়েছে';

  @override
  String get itemEditSavedBody => 'আপনার পরিবর্তনগুলো সেভ করা হয়েছে';

  @override
  String get itemEditSavedStalePhotos => 'সেভ হয়েছে — ছবিগুলো পুরনো হতে পারে';

  @override
  String get itemEditRemovePieceHint => 'আইটেম পেজ থেকে এই পিসটি ডিলিট করুন';

  @override
  String get itemEditNoPhotos =>
      'এখনও কোনো ছবি নেই। গ্যালারি বা ক্যামেরা থেকে যোগ করুন';

  @override
  String get itemEditKeepPhoto => 'ছবি রাখুন';

  @override
  String get itemEditRemoved => 'মুছে ফেলা হয়েছে';

  @override
  String get itemEditAddUseCaseAction => 'যোগ করুন';

  @override
  String get statsNoStatsTitle => 'এখনও কোনো পরিসংখ্যান নেই';

  @override
  String get statsNoStatsBody =>
      'কিছু পিস যোগ করুন, আপনার ক্লোজেট মিক্স এখানে দেখা যাবে';

  @override
  String get statsByCategory => 'বিভাগ অনুযায়ী';

  @override
  String get statsTotalValue => 'মোট মূল্য';

  @override
  String get statsMostWorn => 'সবচেয়ে বেশি পরা';

  @override
  String get statsLeastWorn => 'পরার অপেক্ষায়';

  @override
  String get statsUnnamedPiece => 'নামহীন পিস';

  @override
  String get jobsTitle => 'স্ক্যান';

  @override
  String get jobsEmptyTitle => 'এখনও কোনো স্ক্যান নেই';

  @override
  String get jobsEmptyBody =>
      'একটি পিসের ছবি তুলুন এবং ব্যাকগ্রাউন্ডে পাঠান — এটি এখানে কাজ করতে থাকবে';

  @override
  String get jobsNotCancelled => 'বাতিল করা হয়নি';

  @override
  String get jobsResume => 'চালিয়ে যান';

  @override
  String get jobsReview => 'রিভিউ';

  @override
  String get jobsStop => 'বন্ধ করুন';

  @override
  String get jobsDismiss => 'বাতিল';

  @override
  String get reportTitle => 'কন্টেন্ট রিপোর্ট করুন';

  @override
  String reportIntro(String contentType) {
    return 'এই $contentType-এ কী সমস্যা হয়েছে তা আমাদের জানান। আমাদের টিম প্রতিটি রিপোর্ট পর্যালোচনা করে।';
  }

  @override
  String get reportReasonInappropriate => 'অনুপযুক্ত বা আপত্তিকর';

  @override
  String get reportReasonNudity => 'নগ্নতা বা যৌন কন্টেন্ট';

  @override
  String get reportReasonHarassment => 'হয়রানি বা অপব্যবহার';

  @override
  String get reportReasonImpersonation => 'পরিচয় জালিয়াতি';

  @override
  String get reportReasonOther => 'অন্যান্য';

  @override
  String get reportDetailsLabel => 'অতিরিক্ত বিবরণ (ঐচ্ছিক)';

  @override
  String get reportSubmit => 'রিপোর্ট জমা দিন';

  @override
  String get reportSubmittedTitle => 'রিপোর্ট জমা হয়েছে';

  @override
  String get reportSubmittedBody =>
      'ধন্যবাদ। আমাদের টিম এই কন্টেন্টটি পর্যালোচনা করবে।';

  @override
  String get reportFailedTitle => 'রিপোর্ট পাঠানো যায়নি';

  @override
  String get reportFailedBody => 'অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get reportContentTryOnImage => 'এআই ট্রাই-অন ইমেজ';

  @override
  String get reportContentSharedOutfit => 'শেয়ার করা আউটফিট';

  @override
  String get reportContentPhotoshootImage => 'এআই ফটোশুট ইমেজ';

  @override
  String get sharedOutfitTitle => 'শেয়ার করা আউটফিট';

  @override
  String get sharedOutfitHideTooltip => 'এই আউটফিটটি লুকান';

  @override
  String get sharedOutfitReportTooltip => 'এই আউটফিটটি রিপোর্ট করুন';

  @override
  String get sharedOutfitHideTitle => 'আউটফিটটি লুকাবেন?';

  @override
  String get sharedOutfitHideBody =>
      'এটি এই ডিভাইসে লুকানো থাকবে। আপনি এটি রিপোর্টও করতে পারেন যাতে আমাদের টিম এটি পর্যালোচনা করে সরিয়ে ফেলতে পারে।';

  @override
  String get sharedOutfitHideAction => 'লুকান';

  @override
  String get sharedOutfitHiddenInfo =>
      'এই আউটফিটটি এই ডিভাইসে আর দেখা যাবে না।';

  @override
  String get sharedOutfitHiddenToast => 'আউটফিট লুকানো হয়েছে';

  @override
  String get sharedOutfitMissingTitle => 'আউটফিটটি আর নেই';

  @override
  String get sharedOutfitMissingBody =>
      'এটি সরিয়ে ফেলা হয়ে থাকতে পারে অথবা লিঙ্কটি ভুল।';

  @override
  String get sharedOutfitHiddenStateTitle => 'আপনি আউটফিটটি লুকিয়ে রেখেছেন';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'যদি এটি আপত্তিকর হয়, তবে প্রাইভেসি অ্যান্ড টার্মস থেকে রিপোর্ট করুন অথবা $email-এ ইমেইল করুন।';
  }

  @override
  String get sharedOutfitCtaTitle => 'লুকটি পছন্দ হয়েছে?';

  @override
  String get sharedOutfitCtaBody =>
      'আপনার নিজের ক্লোজেট থেকে এমন আউটফিট তৈরি করুন।';

  @override
  String get sharedOutfitCtaButton => 'FitCheck AI নিন';

  @override
  String get errorTitle => 'ত্রুটি';

  @override
  String get errorUnknown => 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে';

  @override
  String get errorNoConnection =>
      'ইন্টারনেট সংযোগ নেই। আপনার নেটওয়ার্ক চেক করুন।';

  @override
  String get errorTimeout => 'অনুরোধের সময়সীমা শেষ। আবার চেষ্টা করুন।';

  @override
  String get errorServerError =>
      'আমাদের প্রান্তে কিছু সমস্যা হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get errorBadGateway =>
      'আমাদের সার্ভার সাময়িকভাবে অনুপলব্ধ। আবার চেষ্টা করুন।';

  @override
  String get errorServiceUnavailable =>
      'পরিষেবাটি সাময়িকভাবে অনুপলব্ধ। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get errorInternalError => 'কিছু ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get errorUnauthorized => 'চালিয়ে যেতে সাইন ইন করুন।';

  @override
  String get errorForbidden => 'আপনার এতে অ্যাক্সেস নেই।';

  @override
  String get errorSessionExpired =>
      'আপনার সেশনের মেয়াদ শেষ। আবার সাইন ইন করুন।';

  @override
  String get errorInvalidCredentials => 'ইমেল বা পাসওয়ার্ড সঠিক নয়।';

  @override
  String get errorTokenRefreshFailed =>
      'আপনার সেশন রিফ্রেশ করা যায়নি। আবার সাইন ইন করুন।';

  @override
  String get errorRequestCancelled => 'অনুরোধ বাতিল করা হয়েছে।';

  @override
  String get errorInvalidFormat => 'ফাইল ফরম্যাট সমর্থিত নয়।';

  @override
  String get errorFileTooLarge => 'ফাইলটি খুব বড়।';

  @override
  String get errorUploadFailed => 'আপলোড ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get errorCacheCorrupted =>
      'সংরক্ষিত ডেটা ক্ষতিগ্রস্ত হয়েছে এবং রিসেট করা হয়েছে।';

  @override
  String get errorCacheNotFound => 'এখনও কিছু সংরক্ষিত হয়নি।';

  @override
  String get errorUserNotFound => 'অ্যাকাউন্টটি খুঁজে পাওয়া যায়নি।';

  @override
  String get errorItemNotFound => 'আইটেমটি আর বিদ্যমান নেই।';

  @override
  String get errorOutfitNotFound => 'পোশাকটি আর বিদ্যমান নেই।';

  @override
  String get rewardsTitle => 'রিওয়ার্ড';

  @override
  String get rewardsNoAchievementsTitle => 'এখনও কোনো অর্জন নেই';

  @override
  String get rewardsNoAchievementsBody =>
      'প্রথম অর্জন পেতে পোশাক যোগ করুন এবং সাজান।';

  @override
  String get rewardsEmptyLeaderboardTitle => 'বোর্ডে কেউ নেই';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'পয়েন্ট অর্জন করতে এবং এখানে দেখাতে পোশাক সাজান।';

  @override
  String get legalViewPrivacyPolicy => 'গোপনীয়তা নীতি দেখুন';

  @override
  String get aiConsentAgree => 'সম্মত আছি এবং চালিয়ে যান';

  @override
  String get aiConsentNotNow => 'এখন নয়';

  @override
  String get imageViewerCloseTooltip => 'ছবি ভিউয়ার বন্ধ করুন';

  @override
  String get updateReadyTitle => 'আপডেট প্রস্তুত';

  @override
  String get updateReadyBody =>
      'সর্বশেষ উন্নতি প্রয়োগ করতে FitCheck AI পুনরায় চালু করুন।';

  @override
  String get permissionCameraUsage =>
      'আপনার পোশাক এবং ওয়ারড্রোবের ছবি তুলতে FitCheck AI-এর ক্যামেরা ব্যবহারের অনুমতি প্রয়োজন।';

  @override
  String get permissionPhotoLibraryUsage =>
      'আপনার পোশাক এবং ওয়ারড্রোবের ছবি বেছে নিতে FitCheck AI-এর ফটো লাইব্রেরি অ্যাক্সেস প্রয়োজন।';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI-এর এআই-জেনারেটেড পোশাকের ছবিগুলো আপনার ফটো লাইব্রেরিতে সংরক্ষণ করা প্রয়োজন।';

  @override
  String get wardrobeSomePhotosSkipped => 'কিছু ছবি বাদ দেওয়া হয়েছে';

  @override
  String get wardrobePhotosNotAdded => 'ছবি যোগ করা হয়নি';

  @override
  String get wardrobePhotoNotAdded => 'ছবি যোগ করা হয়নি';

  @override
  String get wardrobeNotStartedTitle => 'শুরু হয়নি';

  @override
  String get wardrobeNoRoomTitle => 'কোনো জায়গা নেই';

  @override
  String get wardrobeAddPhotosSemantic => 'ছবি যোগ করুন';

  @override
  String get batchAddTileLabel => 'যোগ করুন';

  @override
  String get batchProfileLinkLabel => 'প্রোফাইল লিঙ্ক';

  @override
  String get wardrobeImportFromProfileTitle => 'প্রোফাইল থেকে আমদানি করুন';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'একাধিক ছবি যোগ করুন';

  @override
  String get wardrobeClearAction => 'মুছে ফেলুন';

  @override
  String get wardrobeRefreshTooltip => 'রিফ্রেশ করুন';

  @override
  String get batchNoPhotosYetTitle => 'এখনো কোনো ছবি নেই';

  @override
  String get batchChoosePhotosAction => 'ছবি বেছে নিন';

  @override
  String get batchWeFindEachPieceBody =>
      'আমরা প্রতিটি আইটেম খুঁজে বের করি এবং এর একটি স্টুডিও ছবি তৈরি করি।';

  @override
  String get batchPreparingPhotosSemantic => 'ছবি প্রস্তুত করা হচ্ছে';

  @override
  String get batchPhotosProcessedSemantic => 'ছবি প্রক্রিয়া করা হয়েছে';

  @override
  String get batchPasteProfileLinkTitle => 'একটি প্রোফাইল লিঙ্ক পেস্ট করুন';

  @override
  String get batchPasteProfileLinkBody =>
      'একটি পাবলিক ইনস্টাগ্রাম বা ফেসবুক প্রোফাইল। আমরা এর ছবিগুলো স্ক্যান করি, এবং আপনার ক্লোজেটে কোনটি যাবে তা আপনি বেছে নেন।';

  @override
  String get batchClearLinkTooltip => 'লিঙ্ক পরিষ্কার করুন';

  @override
  String get batchStartingButton => 'শুরু হচ্ছে';

  @override
  String get batchStartImportAction => 'আমদানি শুরু করুন';

  @override
  String get batchReviewEveryPhotoTitle => 'আপনি প্রতিটি ছবি পর্যালোচনা করুন';

  @override
  String get batchReviewEveryPhotoBody =>
      'আপনার অনুমোদন না পাওয়া পর্যন্ত কিছুই যোগ করা হয় না।';

  @override
  String get batchPrivateProfilesTitle => 'প্রাইভেট প্রোফাইল';

  @override
  String get batchPrivateProfilesBody =>
      'আপনার অ্যাকাউন্ট কানেক্ট করুন। ইন্সটাগ্রামের জন্য ইউজারনেম ও পাসওয়ার্ডও প্রয়োজন হয়।';

  @override
  String get batchUseAnotherLinkAction => 'অন্য লিংক ব্যবহার করুন';

  @override
  String get batchSignInNeededTitle => 'সাইন-ইন প্রয়োজন';

  @override
  String get batchEnterYourCodeTitle => 'কোড দিন';

  @override
  String get batchUseUsernamePasswordAction =>
      'ইউজারনেম ও পাসওয়ার্ড ব্যবহার করুন';

  @override
  String get batchAlreadyConnectedAction => 'আমি ব্রাউজারে কানেক্ট করেছি';

  @override
  String get batchEnterCodeAction => 'কোড দিন';

  @override
  String get batchTryAnotherWayAction => 'অন্য উপায় চেষ্টা করুন';

  @override
  String get batchLiveStatus => 'লাইভ';

  @override
  String get batchReconnectingStatus => 'পুনরায় কানেক্ট হচ্ছে';

  @override
  String get batchSignInToInstagramTitle => 'ইন্সটাগ্রামে সাইন ইন করুন';

  @override
  String get batchUsernameLabel => 'ইউজারনেম';

  @override
  String get batchCodeIfTwoStepLabel => 'টু-স্টেপ সাইন-ইন ব্যবহার করলে কোড দিন';

  @override
  String get batchAuthenticatorCodeBody =>
      'অথেন্টিকেটর অ্যাপ থেকে ৬-সংখ্যার কোড দিন। কোড দ্রুত পরিবর্তিত হয়।';

  @override
  String get batchVerifyAction => 'যাচাই করুন';

  @override
  String get batchFindingPhotosTitle => 'ছবি খোঁজা হচ্ছে';

  @override
  String get batchImportPausedTitle => 'ইমপোর্ট স্থগিত';

  @override
  String get batchProcessingPhotosTitle => 'ছবি প্রসেস করা হচ্ছে';

  @override
  String get batchWaitingNextPhoto => 'পরবর্তী ছবির জন্য অপেক্ষা করা হচ্ছে';

  @override
  String get batchCancelImportAction => 'ইমপোর্ট বাতিল করুন';

  @override
  String get batchNoPiecesInPhotoBody => 'এই ছবিতে কোনো পোশাক পাওয়া যায়নি।';

  @override
  String get batchEditPieceColoursLabel => 'রং, কমা দিয়ে আলাদা করুন';

  @override
  String get batchAddToClosetAction => 'ক্লোজেটে যোগ করুন';

  @override
  String get batchSkipPhotoAction => 'এই ছবি বাদ দিন';

  @override
  String get batchImportCompleteTitle => 'ইমপোর্ট সম্পন্ন হয়েছে';

  @override
  String get batchImportFailedTitle => 'ইমপোর্ট ব্যর্থ হয়েছে';

  @override
  String get batchImportCancelledTitle => 'ইমপোর্ট বাতিল করা হয়েছে';

  @override
  String get batchImportErrorBody => 'ইমপোর্ট করার সময় কিছু সমস্যা হয়েছে।';

  @override
  String get batchNothingMoreImportedBody =>
      'এই প্রোফাইল থেকে আর কিছু ইমপোর্ট করা হয়নি।';

  @override
  String get batchViewClosetAction => 'ওয়ারড্রোব দেখুন';

  @override
  String get batchStartOverAction => 'আবার শুরু করুন';

  @override
  String get wardrobeAddPieceTitle => 'একটি আইটেম যোগ করুন';

  @override
  String get wardrobeAddDetailsTitle => 'বিবরণ যোগ করুন';

  @override
  String get wardrobeScanningTitle => 'স্ক্যান করা হচ্ছে';

  @override
  String get batchReviewPiecesTitle => 'আইটেমগুলো পর্যালোচনা করুন';

  @override
  String get wardrobeGalleryAction => 'গ্যালারি';

  @override
  String get wardrobeCameraAction => 'ক্যামেরা';

  @override
  String get wardrobeNewBadge => 'নতুন';

  @override
  String get wardrobeRemovePhotoTooltip => 'ছবি সরান';

  @override
  String get batchRunInBackgroundTooltip => 'ব্যাকগ্রাউন্ডে চালান';

  @override
  String get batchStepOneOfTwo => 'ধাপ ১ এর ১';

  @override
  String get batchStepTwoOfTwo => 'ধাপ ২ এর ২';

  @override
  String get batchUploadingPhotosTitle => 'ছবি আপলোড হচ্ছে';

  @override
  String get batchFindingPiecesTitle => 'আইটেম খোঁজা হচ্ছে';

  @override
  String get batchMakingStudioPhotosTitle => 'স্টুডিও ছবি তৈরি হচ্ছে';

  @override
  String get batchStoppedLabel => 'থামানো হয়েছে';

  @override
  String get batchFindingPiecesStoppedTitle => 'আইটেম খোঁজা বন্ধ হয়েছে';

  @override
  String get batchCancelledLabel => 'বাতিল করা হয়েছে';

  @override
  String get batchAllDoneTitle => 'সব শেষ';

  @override
  String get batchOpeningPiecesBody => 'আপনার আইটেমগুলো খোলা হচ্ছে';

  @override
  String get batchNothingSavedBody => 'কিছুই সেভ করা হয়নি।';

  @override
  String get batchFindingPiecesFailedBody => 'আইটেম খুঁজতে ব্যর্থ হয়েছে।';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'আইটেম খোঁজা আগেই বন্ধ করা হয়েছে।';

  @override
  String get batchStopFindingPiecesTitle => 'আইটেম খোঁজা বন্ধ করবেন?';

  @override
  String get batchStopFindingPiecesBody =>
      'স্ক্যান বন্ধ হয়ে যাবে এবং কিছু সেভ হবে না। যেসব আইটেম ইতিমধ্যে পাওয়া গেছে সেগুলো বাদ না দেওয়া পর্যন্ত আপনার অ্যাক্টিভিটিতে থাকবে।';

  @override
  String get batchKeepGoingAction => 'চালিয়ে যান';

  @override
  String get batchTryAgainAction => 'আবার চেষ্টা করুন';

  @override
  String get batchBackToPhotosAction => 'ছবিতে ফিরে যান';

  @override
  String get batchSkipAllAction => 'সব এড়িয়ে চলুন';

  @override
  String get batchIncludeAllAction => 'সব যোগ করুন';

  @override
  String get batchNoPiecesFoundTitle => 'কোনো পোশাক পাওয়া যায়নি';

  @override
  String get batchNoPiecesFoundBody => 'এই ছবিগুলোতে কোনো পোশাক পাওয়া যায়নি।';

  @override
  String get batchChooseOtherPhotosAction => 'অন্য ছবি বেছে নিন';

  @override
  String get batchUseCaseHelper =>
      'আপনার সেভ করা প্রতিটি পোশাকে যোগ করা হয়েছে।';

  @override
  String get batchDiscardPiecesTitle => 'এই পোশাকগুলো বাদ দেবেন?';

  @override
  String get batchDiscardPiecesBody => 'এই ব্যাচ থেকে কিছুই সেভ করা হয়নি।';

  @override
  String get batchKeepAction => 'রাখুন';

  @override
  String get batchDiscardAction => 'বাদ দিন';

  @override
  String get batchRemovePieceTitle => 'এই পোশাকটি সরাবেন?';

  @override
  String get batchRemovePieceBody => 'এটি আপনার ক্লোজেটে সেভ করা হয়নি।';

  @override
  String get batchRemoveAction => 'সরান';

  @override
  String get batchChoosePiecesToSave => 'সেভ করার জন্য পোশাক বেছে নিন';

  @override
  String get batchDiscardAllAction => 'সব বাদ দিন';

  @override
  String get batchNothingSavedRetryBody => 'কিছুই সেভ হয়নি। আবার চেষ্টা করুন।';

  @override
  String get batchNotSavedTitle => 'সেভ হয়নি';

  @override
  String get batchSavingLabel => 'সেভ হচ্ছে';

  @override
  String get batchSendToBackgroundAction => 'ব্যাকগ্রাউন্ডে পাঠান';

  @override
  String get batchStillWorkingMessage =>
      'কাজ চলছে। আপনার পোশাক প্রস্তুত হলে আমরা আপনাকে জানাব।';

  @override
  String get batchRunningInBackgroundTitle => 'ব্যাকগ্রাউন্ডে চলছে';

  @override
  String get batchStudioPhotosStoppedBody =>
      'স্টুডিও ফটো তৈরি আগেভাগে বন্ধ হয়ে গেছে। আপনি এখনও এই পোশাকগুলো সেভ করতে পারেন।';

  @override
  String get batchTapPieceToSkip => 'বাদ দিতে কোনো পোশাকে ট্যাপ করুন।';

  @override
  String get batchStudioPhotosOnWayBody =>
      'স্টুডিও ফটো তৈরি হচ্ছে। আপনি চলে যেতে পারেন—আমরা আপনাকে জানিয়ে দেব।';

  @override
  String get batchLeaveAction => 'প্রস্থান';

  @override
  String get batchPeopleInPhotosTitle => 'ছবির মানুষেরা';

  @override
  String get batchIncludeAction => 'যোগ করুন';

  @override
  String get batchSkipAction => 'বাদ দিন';

  @override
  String get batchYourPhotoIsUsedLabel => 'আপনার ছবিটি ব্যবহার করা হয়েছে';

  @override
  String get batchMakingStudioPhotoLabel => 'স্টুডিও ফটো তৈরি হচ্ছে';

  @override
  String get batchNoStudioPhotoBody =>
      'কোনো স্টুডিও ফটো নেই। আপনার ছবিটি ব্যবহার করা হয়েছে।';

  @override
  String get batchEnterDetailsYourselfAction => 'নিজে তথ্য দিন';

  @override
  String get batchChooseAnotherPhotoAction => 'অন্য ছবি বাছুন';

  @override
  String get batchConnectionLostTitle => 'সংযোগ বিচ্ছিন্ন';

  @override
  String get batchConnectionLostBody => 'সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get batchDailyLimitTitle => 'দৈনিক সীমা শেষ';

  @override
  String get batchDailyLimitBodyPaywall =>
      'আরও স্ক্যানের জন্য Pro-তে উন্নীত করুন বা নিজে তথ্য দিন।';

  @override
  String get batchDailyLimitBodyFree =>
      'আগামীকাল আপনার স্ক্যান রিসেট হবে। আপনি এখনই নিজে তথ্য দিতে পারেন।';

  @override
  String get batchSeePlansAction => 'প্ল্যান দেখুন';

  @override
  String get batchAiBusyTitle => 'আমাদের AI ব্যস্ত আছে';

  @override
  String get batchAiBusyBody =>
      'এটি আমাদের দিক থেকে সমস্যা। কয়েক মিনিট পর আবার চেষ্টা করুন।';

  @override
  String get batchNoPiecesBody => 'স্পষ্ট ছবি দিন বা নিজে তথ্য লিখুন।';

  @override
  String get batchScanningUnavailableTitle => 'স্ক্যান করা সম্ভব হচ্ছে না';

  @override
  String get batchScanningUnavailableBody => 'ততক্ষণ নিজে তথ্য দিন।';

  @override
  String get batchScanDidNotFinishTitle => 'স্ক্যান সম্পন্ন হয়নি';

  @override
  String get batchTryAgainBody => 'আবার চেষ্টা করুন।';

  @override
  String get billingTitle => 'সাবস্ক্রিপশন';

  @override
  String get billingUpgradeHeading => 'প্ল্যান আপগ্রেড করুন';

  @override
  String get billingUpgradeOnPlusBody => 'একই ফিচার, বেশি সীমা।';

  @override
  String get billingUpgradeBody =>
      'Plus এবং Pro-তে একই ফিচার আছে। আপনার প্রয়োজনীয় সীমা বেছে নিন।';

  @override
  String get billingWebUnavailableBody =>
      'অনলাইন আপগ্রেড এখনও উপলব্ধ নয়। প্রোমো বা রেফারেল কোড দিয়ে Plus বা Pro আনলক করা যাবে। ফ্রি মাস পেতে বন্ধুদের আমন্ত্রণ জানান।';

  @override
  String get billingPlansStale =>
      'সর্বশেষ প্ল্যান লোড করা যায়নি। দাম পুরনো হতে পারে।';

  @override
  String get billingMonthly => 'মাসিক';

  @override
  String get billingYearly => 'বার্ষিক';

  @override
  String get billingCurrentPlan => 'বর্তমান প্ল্যান';

  @override
  String get billingActive => 'সক্রিয়';

  @override
  String get billingThisMonth => 'এই মাস';

  @override
  String get billingItemExtractions => 'আইটেম এক্সট্রাকশন';

  @override
  String get billingOutfitVisualizations => 'পোশাক ভিজ্যুয়ালাইজেশন';

  @override
  String get billingNearLimitUpgrade =>
      'আপনি এই মাসের সীমার কাছাকাছি আছেন। আরও পেতে আপগ্রেড করুন।';

  @override
  String get billingNearLimitResets =>
      'আপনি এই মাসের সীমার কাছাকাছি আছেন। এটি আগামী মাসের শুরুতে রিসেট হবে।';

  @override
  String get billingStoreUnavailable =>
      'স্টোরে এই মুহূর্তে আপডেট উপলব্ধ নেই। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get billingManageHeading => 'আপনার প্ল্যান পরিচালনা করুন';

  @override
  String get billingCancelPlan => 'সাবস্ক্রিপশন বাতিল করুন';

  @override
  String get billingCancelKeepsAccess =>
      'এই বিলিং চক্রের শেষ পর্যন্ত আপনার অ্যাক্সেস থাকবে।';

  @override
  String get billingCancelConfirmTitle => 'সাবস্ক্রিপশন বাতিল করবেন?';

  @override
  String get billingKeepPlan => 'প্ল্যান রাখুন';

  @override
  String get billingCancelPlanAction => 'প্ল্যান বাতিল করুন';

  @override
  String get billingBilledMonthly => 'মাসিক বিল করা হয়';

  @override
  String get billingBilledYearly => 'বার্ষিক বিল করা হয়';

  @override
  String get billingVirtualTryOn => 'ভার্চুয়াল ট্রাই-অন';

  @override
  String get billingPrioritySupport => 'প্রায়োরিটি সাপোর্ট';

  @override
  String get billingDisclosureProRenewing =>
      'Pro একটি স্বয়ংক্রিয়ভাবে নবায়নযোগ্য সাবস্ক্রিপশন';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus এবং Pro স্বয়ংক্রিয়ভাবে নবায়নযোগ্য সাবস্ক্রিপশন';

  @override
  String get billingDisclosureAppleBilling =>
      'ক্রয় নিশ্চিত করার সময় আপনার Apple ID-তে চার্জ করা হবে।';

  @override
  String get billingDisclosureGoogleBilling =>
      'ক্রয় নিশ্চিত করার সময় আপনার Google Play অ্যাকাউন্টে চার্জ করা হবে।';

  @override
  String get billingDisclosureRenewalTerms =>
      'বর্তমান মেয়াদ শেষ হওয়ার কমপক্ষে ২৪ ঘন্টা আগে স্বয়ংক্রিয় নবায়ন বন্ধ না করলে আপনার সাবস্ক্রিপশন একই মূল্যে স্বয়ংক্রিয়ভাবে নবায়ন হবে।';

  @override
  String get billingDisclosureAppleManage =>
      'Settings › আপনার Apple ID › Subscriptions থেকে যেকোনো সময় পরিচালনা বা বাতিল করুন।';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play › Payments and subscriptions থেকে যেকোনো সময় পরিচালনা বা বাতিল করুন।';

  @override
  String get billingReferFriend => 'বন্ধুকে রেফার করুন';

  @override
  String get billingHowItWorks => 'এটি যেভাবে কাজ করে';

  @override
  String get billingHowShareTitle => 'আপনার লিঙ্ক শেয়ার করুন';

  @override
  String get billingHowShareBody => 'আপনার বন্ধুকে এটি পাঠান।';

  @override
  String get billingHowSignUpTitle => 'তারা সাইন আপ করেন';

  @override
  String get billingHowSignUpBody => 'আপনার বন্ধু লিঙ্ক থেকে যোগ দেন।';

  @override
  String get billingHowBothTitle => 'আপনারা দুজনেই Pro পান';

  @override
  String get billingHowBothBody =>
      'আপনারা প্রত্যেকে এক মাসের Pro বিনামূল্যে পান।';

  @override
  String get billingYourReferrals => 'আপনার রেফারেলসমূহ';

  @override
  String get billingInvited => 'আমন্ত্রণ জানানো হয়েছে';

  @override
  String get billingJoined => 'যুক্ত হয়েছেন';

  @override
  String get billingMonthsEarned => 'অর্জিত মাস';

  @override
  String get billingInviteFriend => 'বন্ধু আমন্ত্রণ জানান';

  @override
  String get billingInviteBody =>
      'আপনি এবং আপনার বন্ধু দুজনেই এক মাসের Pro পাবেন।';

  @override
  String get billingYourCode => 'আপনার কোড';

  @override
  String get billingCopyLink => 'লিংক কপি করুন';

  @override
  String get billingShareInvite => 'আমন্ত্রণ শেয়ার করুন';

  @override
  String get giftUnavailable => 'এই সংস্করণে উপহার আমন্ত্রণ উপলব্ধ নেই।';

  @override
  String get giftPageTitle => 'FitCheck Pro উপহার দিন';

  @override
  String get giftNoAllowances =>
      'এই মুহূর্তে কোনো ফ্রি উপহার আমন্ত্রণ উপলব্ধ নেই।';

  @override
  String get giftFormTitle => 'একটি ফ্রি আমন্ত্রণ পাঠান';

  @override
  String get giftFormBody =>
      'আপনার প্রাপক এই যাচাইকৃত ইমেলের মাধ্যমে উপহারটি দাবি করবেন। আমরা আপনার পক্ষ থেকে ইমেল পাঠাই না।';

  @override
  String get giftFieldFrom => 'প্রেরক';

  @override
  String get giftFieldRecipientName => 'প্রাপকের নাম';

  @override
  String get giftFieldRecipientEmail => 'প্রাপকের ইমেল';

  @override
  String get giftFieldOccasion => 'উপলক্ষ (ঐচ্ছিক)';

  @override
  String get giftNoOccasion => 'কোনো উপলক্ষ নেই';

  @override
  String get giftOccasionBirthday => 'জন্মদিন';

  @override
  String get giftOccasionAnniversary => 'বার্ষিকী';

  @override
  String get giftOccasionOther => 'অন্যান্য';

  @override
  String get giftFieldCardGreeting => 'কার্ডের শুভেচ্ছা';

  @override
  String get giftFieldCardGreetingHelper =>
      'এটি ঠিক যেভাবে লেখা হয়েছে কার্ডে সেভাবেই প্রদর্শিত হবে।';

  @override
  String get giftFieldPrivateNote => 'ব্যক্তিগত নোট (ঐচ্ছিক)';

  @override
  String get giftCreateAction => 'ফ্রি উপহার তৈরি করুন';

  @override
  String get giftClaimedTitle => 'উপহার দাবি করা হয়েছে';

  @override
  String get giftClaimedActive => 'আপনার FitCheck Pro উপহারটি সক্রিয় আছে।';

  @override
  String get giftClaimedQueued =>
      'আপনার বর্তমান অ্যাক্সেসের পরে আপনার FitCheck Pro উপহারটি শুরু হবে।';

  @override
  String get giftLinkCopied => 'উপহারের লিংক ক্লিপবোর্ডে কপি করা হয়েছে।';

  @override
  String get giftErrorName => 'একটি নাম লিখুন।';

  @override
  String get giftErrorEmail => 'একটি সঠিক ইমেল ঠিকানা লিখুন।';

  @override
  String get giftErrorGreeting => 'কার্ডের শুভেচ্ছা লিখুন।';

  @override
  String get giftErrorGreetingLength => '৮০ অক্ষরের বেশি ব্যবহার করবেন না।';

  @override
  String get giftClaimAction => 'উপহার নিন';

  @override
  String get giftCardPreview => 'কার্ড প্রিভিউ';

  @override
  String get giftGiftForYou => 'আপনার জন্য উপহার';

  @override
  String get giftGiftWaiting => 'আপনার জন্য একটি উপহার অপেক্ষা করছে';

  @override
  String get giftOpenBody => 'যাচাইকৃত ইমেইল দিয়ে উপহারটি খুলুন।';

  @override
  String get giftOpenGifts => 'উপহার খুলুন';

  @override
  String get giftSendInvitation => 'আমন্ত্রণ পাঠান';

  @override
  String get settingsAiProviderSection => 'প্রোভাইডার';

  @override
  String get settingsAiCustom => 'কাস্টম';

  @override
  String get settingsAiUrlHelper =>
      'সার্ভার থেকে অ্যাক্সেসযোগ্য একটি পাবলিক ইউআরএল ব্যবহার করুন। লোকালহোস্ট কাজ করবে না।';

  @override
  String get settingsAiConnectionSection => 'কানেকশন';

  @override
  String get settingsAiApiUrl => 'এপিআই ইউআরএল';

  @override
  String get settingsAiApiKey => 'এপিআই কি';

  @override
  String get settingsAiApiKeySaved =>
      'সংরক্ষিত হয়েছে। অপরিবর্তিত রাখতে খালি রাখুন।';

  @override
  String get settingsAiChatModel => 'চ্যাট মডেল';

  @override
  String get settingsAiVisionModel => 'ভিশন মডেল (ঐচ্ছিক)';

  @override
  String get settingsAiImageModel => 'ইমেজ মডেল (ঐচ্ছিক)';

  @override
  String get settingsAiImageModelNote =>
      'ইমেজ তৈরির জন্য OpenAI-সামঞ্জস্যপূর্ণ চ্যাট কমপ্লিশন প্রয়োজন।';

  @override
  String get settingsAiTestConnection => 'কানেকশন টেস্ট করুন';

  @override
  String get calendarTitle => 'ক্যালেন্ডার';

  @override
  String get calendarGoToToday => 'আজকে যান';

  @override
  String get calendarConnectTooltip => 'ক্যালেন্ডার কানেক্ট করুন';

  @override
  String get calendarAddEvent => 'ইভেন্ট যোগ করুন';

  @override
  String get calendarEmptyTitle => 'কোনো পরিকল্পনা নেই';

  @override
  String get calendarEmptyBody =>
      'একটি ইভেন্ট যোগ করুন এবং পোশাক পরিকল্পনা করুন।';

  @override
  String get calendarPreviousMonth => 'আগের মাস';

  @override
  String get calendarNextMonth => 'পরের মাস';

  @override
  String get calendarAllDay => 'সারাদিন';

  @override
  String get calendarOutfitLinked => 'আউটফিট যুক্ত হয়েছে';

  @override
  String get calendarEventOptions => 'ইভেন্ট অপশন';

  @override
  String get calendarDeleteTitle => 'এই ইভেন্টটি ডিলিট করবেন?';

  @override
  String get calendarChangeOutfit => 'পোশাক পরিবর্তন করুন';

  @override
  String get calendarLinkOutfit => 'একটি পোশাক যুক্ত করুন';

  @override
  String get calendarRemoveOutfit => 'পোশাক সরান';

  @override
  String get calendarNewEvent => 'নতুন ইভেন্ট';

  @override
  String get calendarEditEvent => 'ইভেন্ট এডিট করুন';

  @override
  String get calendarTitleLabel => 'শিরোনাম';

  @override
  String get calendarTitleRequired => 'একটি শিরোনাম যোগ করুন';

  @override
  String get calendarEndBeforeStart => 'শুরুর সময়ের পরে শেষ করুন';

  @override
  String get calendarStarts => 'শুরু';

  @override
  String get calendarEnds => 'শেষ';

  @override
  String get calendarPlaceOptional => 'স্থান (ঐচ্ছিক)';

  @override
  String get calendarNotesOptional => 'নোট (ঐচ্ছিক)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'একটি পোশাক তৈরি করুন, তারপর এই ইভেন্টের সাথে যুক্ত করুন।';

  @override
  String get calendarBuildOutfit => 'পোশাক তৈরি করুন';

  @override
  String get calendarConnectionsTitle => 'ক্যালেন্ডার';

  @override
  String get calendarConnectionsBody =>
      'এখানে যোগ করা ইভেন্টগুলো FitCheck-এই থাকবে।';

  @override
  String get calendarDisconnect => 'কানেকশন বিচ্ছিন্ন করুন';

  @override
  String get calendarNotAvailable => 'এখনও উপলব্ধ নেই';

  @override
  String get profileSectionExplore => 'অন্বেষণ করুন';

  @override
  String get profileNavTryOn => 'ট্রাই-অন';

  @override
  String get profileNavRewards => 'রিওয়ার্ড';

  @override
  String get profileSupport => 'সহায়তা';

  @override
  String get profileHelp => 'সাহায্য';

  @override
  String get profileAbout => 'সম্পর্কে';

  @override
  String get profileAboutBody => 'আপনার ক্লোজেট, পোশাক এবং প্ল্যান এক জায়গায়।';

  @override
  String get profileSignOutTitle => 'সাইন আউট করবেন?';

  @override
  String get profileSignOutBody => 'আপনি যেকোনো সময় আবার সাইন ইন করতে পারবেন।';

  @override
  String get profileEditTitle => 'প্রোফাইল এডিট করুন';

  @override
  String get profileYourProfile => 'আপনার প্রোফাইল';

  @override
  String get profileBodyProfiles => 'বডি প্রোফাইল';

  @override
  String get profileBodyEmptyTitle => 'কোনো বডি প্রোফাইল নেই';

  @override
  String get profileBodyEmptyBody =>
      'সঠিক ফিটের জন্য আপনার উচ্চতা ও গঠন যোগ করুন।';

  @override
  String get profileBodyAdd => 'প্রোফাইল যোগ করুন';

  @override
  String get profileBodyDefaultNote =>
      'ফিট এবং ট্রাই-অনের জন্য আপনার ডিফল্ট প্রোফাইল ব্যবহার করা হয়।';

  @override
  String get profileBodyDefaultBadge => 'ডিফল্ট';

  @override
  String get profileBodyMakeDefault => 'ডিফল্ট করুন';

  @override
  String get profileBodyDeleteBody => 'এটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get profileBodyRequired => 'প্রয়োজনীয়';

  @override
  String get profileBodyCheckNumber => 'এই নম্বরটি যাচাই করুন';

  @override
  String get profileBodyNew => 'নতুন বডি প্রোফাইল';

  @override
  String get profileBodyNameHint => 'উদাহরণস্বরূপ, আমি';

  @override
  String get profileBodyHeight => 'উচ্চতা';

  @override
  String get profileBodyWeight => 'ওজন';

  @override
  String get profileBodyBuild => 'গঠন';

  @override
  String get profileBodySkinTone => 'ত্বকের রঙ';

  @override
  String get profileBirthDateNeededBody =>
      'জন্ম সময়ের সাথে মিল রেখে জন্মতারিখ যোগ করুন।';

  @override
  String get profileBirthDateNeededTitle => 'জন্মতারিখ প্রয়োজন';

  @override
  String get profilePartlySavedBody =>
      'আমরা আপনার নাম এবং ছবি সেভ করেছি। জন্মসংক্রান্ত তথ্য সেভ হয়নি; পরে আবার চেষ্টা করুন।';

  @override
  String get profilePartlySavedTitle => 'আংশিক সেভ হয়েছে';

  @override
  String get profileSavedBody => 'আপনার প্রোফাইল সেভ হয়েছে।';

  @override
  String get profileChangePhoto => 'প্রোফাইল ছবি পরিবর্তন করুন';

  @override
  String get profilePhotoLabel => 'প্রোফাইল ছবি';

  @override
  String get profilePhotoHint => 'নতুন ছবি বেছে নিতে ট্যাপ করুন';

  @override
  String get profileBirthDateLabel => 'জন্মতারিখ (ঐচ্ছিক)';

  @override
  String get profileBirthTimeLabel => 'জন্মের সময় (ঐচ্ছিক)';

  @override
  String get profileBirthTimeHelper => 'বৈদিক পরামর্শ আরও নিখুঁত করে';

  @override
  String get profileBirthPlaceLabel => 'জন্মস্থান (ঐচ্ছিক)';

  @override
  String get profileBirthPlaceHint => 'উদাহরণস্বরূপ, ঢাকা, বাংলাদেশ';

  @override
  String get profileHelpContactTitle => 'আমাদের যেকোনো প্রশ্ন করুন';

  @override
  String get profileHelpContactBody =>
      'একটি বার্তা পাঠান, আমরা সাধারণত এক দিনের মধ্যে ইমেইলে উত্তর দিই।';

  @override
  String get profileHelpContactAction => 'সহায়তার সাথে যোগাযোগ করুন';

  @override
  String get profileHelpFaqTitle => 'সাধারণ প্রশ্নাবলী';

  @override
  String get profileFaqAddPiecesTitle => 'কীভাবে আমার আলমারিতে পোশাক যোগ করব?';

  @override
  String get profileFaqAddPiecesBody =>
      'ক্লোজেট ট্যাবে আইটেম যোগ করুন ট্যাপ করুন। একটি ছবি তুলুন বা গ্যালারি থেকে একটি বেছে নিন; আমরা প্রতিটি পিস খুঁজে বের করে আপনার জন্য ট্যাগ করব।';

  @override
  String get profileFaqMatchingTitle => 'আউটফিট ম্যাচিং কীভাবে কাজ করে?';

  @override
  String get profileFaqMatchingBody =>
      'আপনার জন্য খুলুন এবং আপনার নিজের পিস বেছে নিন। আমরা সেগুলির সাথে কী যায় তা প্রস্তাব করি এবং আপনার ক্লোজেট থেকে সম্পূর্ণ আউটফিট তৈরি করি।';

  @override
  String get profileFaqTryOnTitle =>
      'আমি কি ট্রাই-অনের জন্য আমার নিজের ছবি ব্যবহার করতে পারি?';

  @override
  String get profileFaqTryOnBody =>
      'হ্যাঁ। আপনার একটি পূর্ণদৈর্ঘ্যের ছবি যোগ করুন, তারপরে আপনার গায়ে সেগুলি দেখতে পিসগুলি বেছে নিন।';

  @override
  String get profileFaqRewardsTitle => 'কীভাবে পুরস্কার অর্জন করব?';

  @override
  String get profileFaqRewardsBody =>
      'ঘনঘন আউটফিট পরিকল্পনা করুন এবং লগ করুন। আপনি এগিয়ে যাওয়ার সাথে সাথে স্ট্রিক এবং অর্জনগুলি তৈরি হয়।';

  @override
  String get profileFaqPrivacyTitle => 'আমার ক্লোজেট কি গোপনীয়?';

  @override
  String get profileFaqPrivacyBody =>
      'হ্যাঁ। আপনার ক্লোজেট এবং আউটফিটগুলি ব্যক্তিগত থাকে যদি না আপনি একটি আউটফিটের লিঙ্ক শেয়ার করেন।';

  @override
  String get profileHelpMoreTitle => 'আরও সহায়তা';

  @override
  String get profileHelpGuides => 'গাইড';

  @override
  String get profileHelpGuidesBody => 'প্রতিটি বৈশিষ্ট্য যেভাবে কাজ করে';

  @override
  String get feedbackCategoryBug => 'কিছু একটা ভেঙে গেছে';

  @override
  String get feedbackCategoryIdea => 'একটি ধারণা';

  @override
  String get feedbackCategoryGeneral => 'সাধারণ';

  @override
  String get feedbackCategoryHelp => 'আমার সাহায্য দরকার';

  @override
  String get feedbackHintBug =>
      'কী ঘটেছে এবং আপনি কী আশা করেছিলেন? পদক্ষেপগুলি আমাদের এটি ঠিক করতে সাহায্য করে।';

  @override
  String get feedbackHintIdea => 'আপনি কী চান এবং কেন?';

  @override
  String get feedbackHintGeneral =>
      'আপনার মতামত জানান বা একটি প্রশ্ন জিজ্ঞাসা করুন।';

  @override
  String get feedbackAttachmentLimitBody =>
      'আপনি সর্বোচ্চ ৫টি ছবি যোগ করতে পারেন।';

  @override
  String get feedbackAttachmentLimitTitle => 'সীমা পৌঁছে গেছে';

  @override
  String get feedbackImageTooLargeBody => '৫ এমবির নিচে একটি ছবি বেছে নিন।';

  @override
  String get feedbackImageTooLargeTitle => 'ছবি খুব বড়';

  @override
  String get feedbackTitle => 'মতামত পাঠান';

  @override
  String get feedbackAboutLabel => 'এটি কী সম্পর্কে?';

  @override
  String get feedbackSubjectLabel => 'বিষয়';

  @override
  String get feedbackSubjectRequired => 'একটি বিষয় দিন';

  @override
  String get feedbackSubjectTooShort => 'বিষয়টি অন্তত ৩ অক্ষরের হতে হবে';

  @override
  String get feedbackDetailsLabel => 'বিস্তারিত';

  @override
  String get feedbackDetailsRequired => 'কিছু বিস্তারিত দিন';

  @override
  String get feedbackDetailsTooShort => 'বর্ণনা অন্তত ১০ অক্ষরের হতে হবে';

  @override
  String get feedbackAddScreenshot => 'একটি স্ক্রিনশট যোগ করুন';

  @override
  String get feedbackAttachmentHint => 'সর্বোচ্চ ৫টি, প্রতিটির আকার ৫ মোবাইট';

  @override
  String get feedbackSend => 'পাঠান';

  @override
  String get feedbackEmptyTitle => 'এখনো কিছু পাঠানো হয়নি';

  @override
  String get feedbackEmptyBody =>
      'আপনি যা পাঠাবেন তা স্ট্যাটাসসহ এখানে দেখা যাবে।';

  @override
  String get feedbackHistoryTitle => 'আপনি যা পাঠিয়েছেন';

  @override
  String get feedbackStatusOpen => 'খোলা';

  @override
  String get feedbackStatusInProgress => 'চলমান';

  @override
  String get feedbackStatusResolved => 'সমাধান করা হয়েছে';

  @override
  String get feedbackStatusClosed => 'বন্ধ';

  @override
  String get legalIntro =>
      'আমরা কীভাবে আপনার ডেটা সুরক্ষিত রাখি এবং FitCheck AI ব্যবহারের শর্তাবলী।';

  @override
  String get legalPolicies => 'নীতিমালা';

  @override
  String get legalPrivacySubtitle => 'আমরা কী সংগ্রহ করি এবং কেন';

  @override
  String get legalTermsTitle => 'ব্যবহারের শর্তাবলী';

  @override
  String get legalTermsSubtitle => 'অ্যাপ ব্যবহারের নিয়মাবলী';

  @override
  String get legalLicences => 'ওপেন-সোর্স লাইসেন্স';

  @override
  String get legalSupportSubtitle => 'সহায়তা, যোগাযোগ এবং গোপনীয়তার অনুরোধ';

  @override
  String get legalReportAbuse => 'কোনো সমস্যা বা অপব্যবহারের রিপোর্ট করুন';

  @override
  String get permissionCameraTitle => 'ক্যামেরার অ্যাক্সেস';

  @override
  String get permissionCameraRationale =>
      'AI ট্রাই-অন এবং ক্লোজেট গুছিয়ে রাখতে FitCheck AI আপনার জামাকাপড়ের ছবি তুলতে ক্যামেরা ব্যবহার করে।';

  @override
  String get permissionPhotoTitle => 'ছবির অ্যাক্সেস';

  @override
  String get permissionPhotoRationale =>
      'AI ফিচার এবং ক্লোজেটের জন্য জামাকাপড়ের ছবি বেছে নিতে FitCheck AI-এর ফটো অ্যাক্সেস প্রয়োজন।';

  @override
  String get permissionNotNow => 'এখন নয়';

  @override
  String get permissionOpenSettings => 'সেটিংস খুলুন';

  @override
  String authSignedInAs(String name) {
    return '$name হিসেবে লগ ইন করা আছে';
  }

  @override
  String get authSignedIn => 'সাইন ইন করা হয়েছে';

  @override
  String get authWelcomeBackTitle => 'স্বাগতম';

  @override
  String get authSignInFailed => 'সাইন ইন ব্যর্থ হয়েছে';

  @override
  String get authWelcomeTitle => 'স্বাগতম';

  @override
  String get authSignUpFailed => 'সাইন আপ ব্যর্থ হয়েছে';

  @override
  String get authGoogleSignInFailed => 'গুগল সাইন ইন ব্যর্থ হয়েছে';

  @override
  String get authAppleSignInFailed => 'অ্যাপল সাইন ইন ব্যর্থ হয়েছে';

  @override
  String get authConfirmEmailTitle => 'ইমেল নিশ্চিত করুন';

  @override
  String get authConfirmEmailBody =>
      'নিশ্চিতকরণ ইমেলের জন্য আপনার ইনবক্স চেক করুন, তারপর সাইন ইন করুন।';

  @override
  String get authClosetReady => 'আপনার ক্লোজেট প্রস্তুত।';

  @override
  String get authSignedOutTitle => 'সাইন আউট করা হয়েছে';

  @override
  String get authSignedOutBody => 'আপনি সাইন আউট করেছেন।';

  @override
  String get authSignOutFailed => 'সাইন আউট ব্যর্থ হয়েছে';

  @override
  String get authEmailSentTitle => 'ইমেল পাঠানো হয়েছে';

  @override
  String get authResetLinkSent => 'রিসেট লিঙ্কের জন্য আপনার ইমেল চেক করুন।';

  @override
  String get authPasswordUpdatedTitle => 'পাসওয়ার্ড আপডেট করা হয়েছে';

  @override
  String get authPasswordUpdated => 'আপনার পাসওয়ার্ড আপডেট করা হয়েছে।';

  @override
  String get authPasswordNotUpdated => 'পাসওয়ার্ড আপডেট করা হয়নি';

  @override
  String get authCouldNotSendEmail => 'ইমেল পাঠানো যায়নি';

  @override
  String get authEmailNotSent => 'ইমেল পাঠানো হয়নি';

  @override
  String get authResendSentBody => 'আমরা একটি নতুন নিশ্চিতকরণ ইমেল পাঠিয়েছি।';

  @override
  String get outfitPreviewWithAi => 'AI দিয়ে প্রিভিউ';

  @override
  String get outfitNewPreview => 'নতুন প্রিভিউ তৈরি করুন';

  @override
  String get outfitBuilderClosetHeading => 'আপনার ক্লোজেট';

  @override
  String get outfitBuilderSearchHint => 'পিস সার্চ করুন';

  @override
  String get outfitClearSearch => 'সার্চ মুছুন';

  @override
  String get outfitBuilderAddPiecesTitle => 'আগে পিস যোগ করুন';

  @override
  String get outfitBuilderAddPiecesBody =>
      'আউটফিট তৈরি হয় আপনার ক্লোজেটের পিস থেকে।';

  @override
  String get outfitBuilderNoMatches => 'কোন পিস মিলেছে না।';

  @override
  String get outfitNameLabel => 'আউটফিটের নাম';

  @override
  String get outfitNameHint => 'যেমন, উইকেন্ড লিনেন';

  @override
  String get outfitPreviewSemantic => 'আউটফিটের AI প্রিভিউ';

  @override
  String get outfitChoosePieces => 'পিস বেছে নিন';

  @override
  String get outfitTapPiecesHint => 'যোগ করতে নিচের পিসে ট্যাপ করুন।';

  @override
  String get outfitShareTooltip => 'শেয়ার করুন';

  @override
  String get outfitSaveFavourite => 'প্রিয় তালিকায় রাখুন';

  @override
  String get outfitPiecesHeading => 'পিস';

  @override
  String get outfitWearHistoryEmpty => 'একবার পরলে তারিখ এখানে দেখাবে।';

  @override
  String get outfitWearHistoryTitle => 'পড়ার ইতিহাস';

  @override
  String get outfitWearHistoryError => 'তারিখ লোড করা যায়নি।';

  @override
  String get outfitWornOn => 'পড়েছে';

  @override
  String get outfitEditTitle => 'আউটফিট সম্পাদনা';

  @override
  String get outfitSavedPhotosFailed => 'বিস্তারিত সেভ হয়েছে, ছবি নয়';

  @override
  String get outfitNoPhotosBody =>
      'এখনও কোনো ছবি নেই। আউটফিটটি তার পিস দেখাবে।';

  @override
  String get outfitOccasionLabel => 'উদ্দেশ্য';

  @override
  String get outfitOccasionNone => 'কিছুই না';

  @override
  String get outfitTagsHint => 'কমা দিয়ে আলাদা করুন';

  @override
  String get outfitDraftBody => 'আপনার মূল তালিকা থেকে লুকানো';

  @override
  String get outfitPublic => 'জনপ্রসাদ';

  @override
  String get outfitPublicBody => 'লিংক থাকলে কেউই এটি দেখতে পারবে';

  @override
  String get outfitDeleteFromDetail =>
      'বিস্তারিত পৃষ্ঠা থেকে এই আউটফিট মুছে ফেলুন';

  @override
  String get outfitNewCollection => 'নতুন সংকলন';

  @override
  String get outfitNoCollectionsTitle => 'এখনো কোনো সংকলন নেই';

  @override
  String get outfitNoCollectionsBody =>
      'যাত্রা, মৌসুম বা মেধুর অনুযায়ী আউটফিট গোষ্ঠীকৃত করুন';

  @override
  String get outfitCreateCollection => 'সংকলন তৈরি করুন';

  @override
  String get outfitAddOutfits => 'আউটফিট যোগ করুন';

  @override
  String get outfitRename => 'নাম পরিবর্তন';

  @override
  String get outfitCollectionDeleteBody => 'এতে থাকা আউটফিটগুলো সংরক্ষিত থাকবে';

  @override
  String get outfitCollectionsNotLoaded => 'আউটফিট লোড হয়নি';

  @override
  String get outfitRenameCollection => 'সংকলনের নাম পরিবর্তন করুন';

  @override
  String get outfitDescriptionOptional => 'বর্ণনা (ঐচ্ছিক)';

  @override
  String get outfitAllInCollection => 'সব আউটফিটই ইতিমধ্যে এই সংকলনে আছে';

  @override
  String get photoshootSubtitleUpload =>
      'আপনার নিজের ছবি থেকে স্টুডিও পোর্ট্রেট';

  @override
  String get photoshootSubtitleConfigure =>
      'স্টাইল, ফরম্যাট ও সংখ্যা নির্বাচন করুন';

  @override
  String get photoshootSubtitleGenerating => 'এক-দুই মিনিট সময় লাগবে';

  @override
  String get photoshootAddPhotosSemantic => 'গ্যালারি থেকে ছবি যোগ করুন';

  @override
  String get photoshootUploadTitle => 'আপনার ১ থেকে ৪টি ছবি যোগ করুন';

  @override
  String get photoshootUploadBody => 'গ্যালারি থেকে বেছে নিতে ট্যাপ করুন';

  @override
  String get photoshootAddToContinue => 'চালিয়ে যেতে একটি ছবি যোগ করুন';

  @override
  String get photoshootAddAnotherPhoto => 'আরেকটি ছবি যোগ করুন';

  @override
  String get photoshootTipsTitle => 'সেরা ফলের জন্য';

  @override
  String get photoshootTipsBody =>
      'আপনার মুখের একটি পরিষ্কার ও আলো পূর্ণ ছবির ব্যবহার করুন। শামশূক ও টুপি এড়িয়ে চলুন';

  @override
  String get photoshootStarting => 'শুরু হচ্ছে';

  @override
  String get photoshootCancelling => 'বাতিল করা হচ্ছে';

  @override
  String get photoshootFailed => 'ব্যর্থ হয়েছে';

  @override
  String get recommendTabMatches => 'মিল';

  @override
  String get recommendTabComplete => 'সম্পূর্ণ';

  @override
  String get recommendTabWeather => 'আবহাওয়া';

  @override
  String get recommendTabColours => 'রং';

  @override
  String get recommendTabShop => 'পার্কায়ত';

  @override
  String get recommendNoMatchesTitle => 'এখনো কোনো মিল নেই';

  @override
  String get recommendNoMatchesBody =>
      'একটি পছন্দ করুন, আমরা সাথে যা যায় খুঁজে বের করব।';

  @override
  String get recommendPickPiece => 'একটি পছন্দ করুন';

  @override
  String get recommendNothingMatchesTitle => 'এগুলোর সাথে এখনো কিছু মেলেনি';

  @override
  String get recommendNothingMatchesBody =>
      'অন্য পছন্দ করুন বা আলমাড়িতে আরও যোগ করুন।';

  @override
  String get recommendChangePieces => 'পরিবর্তন করুন';

  @override
  String get recommendDefaultReason => 'এটি আপনার পছন্দের সাথে মানানসই।';

  @override
  String get recommendCompleteTitle => 'লুক সম্পূর্ণ করুন';

  @override
  String get recommendCompleteBody => 'একটি পছন্দ করুন, বাকিটা আমরা পূরণ করব।';

  @override
  String get recommendWorking => 'কাজ করছি';

  @override
  String get recommendGenerate => 'তৈরি করুন';

  @override
  String get recommendChooseStyleBody =>
      'একটি স্টাইল বেছে নিন, তারপর তৈরি করুন।';

  @override
  String get recommendNoLooksTitle => 'এই পিনগুলোর জন্য কোনো লুক নেই';

  @override
  String get recommendNoLooksBody => 'অন্য স্টাইল বা পিন পরখ করুন।';

  @override
  String get recommendDefaultLook => 'আপনার পিনগুলোর একটি লুক';

  @override
  String get recommendNoPiecesBody => 'এই লুক কোনো পিন ফেরত এনেনি।';

  @override
  String get recommendCityLabel => 'শহর';

  @override
  String get recommendCheck => 'চেক করুন';

  @override
  String get recommendWeatherTitle => 'আজ আবহাওয়া কেমন?';

  @override
  String get recommendWeatherBody => 'আজকের সাজসজ্জার জন্য শহরের নাম দিন।';

  @override
  String get recommendWearToday => 'আজ পরুন';

  @override
  String get recommendWeatherNoPieces =>
      'এই আবহাওয়ার জন্য আলমাড়িতে এখনো কোনো পিন নেই।';

  @override
  String get recommendBudgetLabel => 'বাজেট';

  @override
  String get recommendLooking => 'খুঁজছেন';

  @override
  String get recommendFindWhatToBuy => 'কী কিনবেন খুঁজুন';

  @override
  String get recommendFillGapsTitle => 'খালি জায়গা পূরণ করুন';

  @override
  String get recommendFillGapsBody =>
      'বাজেট ঠিক করুন, আমরা আলমাড়িতে যা নেই তা সাজেস্ট করব।';

  @override
  String get recommendNoGapsTitle => 'কোনো খালি জায়গা পাওয়া যায়নি';

  @override
  String get recommendNoGapsBody =>
      'আরও বেশি বাজেট বা অন্য ক্যাটাগরি পরখ করুন।';

  @override
  String get recommendMoodEveryday => 'দৈনিক';

  @override
  String get recommendMoodBigMeeting => 'মহা সম্মেলন';

  @override
  String get recommendDayLabel => 'দিন';

  @override
  String get recommendReadingStars => 'নক্ষত্র পড়া';

  @override
  String get recommendGetMyColours => 'আমার রং দেখুন';

  @override
  String get recommendLuckyColoursTitle => 'আপনার ভাগ্যের রং';

  @override
  String get recommendLuckyColoursBody =>
      'একটি দিন বেছে নিন এবং আমরা এর জন্য রং এবং পোশাকের পরামর্শ দেব।';

  @override
  String get recommendLuckyColoursSection => 'ভাগ্যের রং';

  @override
  String get recommendAvoidColoursSection => 'কম ব্যবহারযোগ্য রং';

  @override
  String get recommendBirthDateTitle => 'আপনার জন্মতিথি যোগ করুন';

  @override
  String get recommendBirthDateBody =>
      'আপনার রং পড়তে আমাদের আপনার জন্মতিথি প্রয়োজন।';

  @override
  String get recommendEditProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get recommendNothingThisDay => 'এই দিনের জন্য কিছু নেই।';

  @override
  String get recommendUnnamedColour => 'নামহীন রং';

  @override
  String get recommendFromCloset => 'আপনার ক্লোজেট থেকে';

  @override
  String get recommendNoPiecesInColours => 'এই রঙে এখনো কোনো পোশাক নেই।';

  @override
  String get recommendOutfitIdeas => 'পোশাকের আইডিয়া';

  @override
  String get recommendNoOutfitsInColours => 'এই রঙে এখনো সম্পূর্ণ পোশাক নেই।';

  @override
  String get recommendDefaultOutfitIdea => 'একটি পোশাকের আইডিয়া';

  @override
  String get recommendPickUpToThree => 'সর্বোচ্চ তিনটি পোশাক বেছে নিন';

  @override
  String get recommendEmptyClosetBody =>
      'প্রথমে কিছু পোশাক যোগ করুন, তারপর মিলের জন্য ফিরে আসুন।';

  @override
  String get dashboardDressForDay => 'আগামী দিনের জন্য পোষা।';

  @override
  String get dashboardOutfitOfDay => 'দিনের পোশাক';

  @override
  String get dashboardFreshLook => 'নতুন রূপ';

  @override
  String get subscriptionManageInStoreTitle => 'স্টোরে পরিবর্তন করুন';

  @override
  String get subscriptionManageInStoreBody =>
      'এই প্ল্যানটি স্টোরের মাধ্যমে বিল হয়। এটি আপনার স্টোর অ্যাকাউন্ট সেটিংসে পরিবর্তন করুন।';

  @override
  String get subscriptionCancelledTitle => 'সাবস্ক্রিপশন বাতিল করা হয়েছে';

  @override
  String get subscriptionCancelledBody =>
      'এই বিলিং চক্রের শেষ পর্যন্ত আপনার প্ল্যান কার্যকর থাকবে।';

  @override
  String get subscriptionCancelFailedTitle => 'বাতিল করা যায়নি';

  @override
  String get subscriptionCouldNotOpenTitle => 'খোলা যায়নি';

  @override
  String get subscriptionOpenBillingFailedBody => 'বিলিং পরিবর্তন খোলা যায়নি।';

  @override
  String get subscriptionOpenLinkFailedBody => 'লিংক খোলা যায়নি।';

  @override
  String get subscriptionReferralLoadFailedTitle => 'আপনার লিংক লোড করা যায়নি';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'আপনার রেফারেল লিংক লোড করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get subscriptionReferralCopiedTitle => 'কপি করা হয়েছে';

  @override
  String get subscriptionReferralCopiedBody => 'রেফারেল লিংক কপি করা হয়েছে।';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI ট্রাই করুন';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI-তে যোগ দিন এবং আমরা দুজনেই Pro-র এক মাসের সুবিধা পাবো। $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'লিংক কপি হয়েছে';

  @override
  String get subscriptionShareUnavailableBody =>
      'শেয়ার করা সম্ভব নয়, তাই লিংকটি কপি করা হয়েছে।';

  @override
  String get subscriptionShareFailedTitle => 'শেয়ার করা যায়নি';

  @override
  String get subscriptionShareFailedBody =>
      'বদলে রেফারেল পেজ থেকে লিংকটি কপি করুন।';

  @override
  String get subscriptionStoreReadyTitle => 'স্টোর প্রস্তুত';

  @override
  String get subscriptionStoreReadyBody =>
      'স্টোরের দাম নেওয়া গেছে। এখন আপগ্রেড করা যাবে।';

  @override
  String get purchaseFailedTitle => 'পাওয়ার বিফল';

  @override
  String get purchaseUnavailableTitle => 'পাওয়ার অনুপলব্ধ';

  @override
  String get purchaseIapUnavailableBody =>
      'এই ডিভাইসে ইন-অ্যাপ পারচেজিং পাওয়া যায় না।';

  @override
  String get purchasePlanNotAvailableBody =>
      'এই প্ল্যানটি এখনো পাওয়ার জন্য পাওয়া যায় না।';

  @override
  String get purchasePlanNotInStoreBody =>
      'এই প্ল্যানটি এখনো স্টোরে পাওয়া যায় না। অনুগ্রহ করে দ্রুত চেক করুন।';

  @override
  String get purchaseStartFailedBody =>
      'পাওয়ার শুরু করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get purchaseNoPaymentLinkBody =>
      'চেকআউট থেকে কোনো পেমেন্ট লিংক প্রাপ্ত হয়নি।';

  @override
  String get purchasePendingTitle => 'পাওয়ার অপেক্ষমাণ';

  @override
  String get purchasePendingBody =>
      'আপনার পাওয়ার অনুমোদনের অপেক্ষায় আছে। অনুমোদন হতেই আপনি অ্যাক্সেস পাবেন।';

  @override
  String get purchaseFailedBody => 'পাওয়ার ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get purchaseRestoredTitle => 'পুনরুদ্ধার হয়েছে';

  @override
  String get purchaseRestoredBody => 'আপনার পাওয়ারগুলো পুনরুদ্ধার করা হয়েছে।';

  @override
  String get purchaseActiveTitle => 'সাবস্ক্রিপশন সক্রিয়';

  @override
  String get purchaseActiveBody => 'আপনার সাবস্ক্রিপশন সক্রিয়। স্বাগতম।';

  @override
  String get purchaseSignInRequiredTitle => 'সাইন ইন প্রয়োজন';

  @override
  String get purchaseSignInRequiredBody =>
      'আপনার পাওয়ার শেষ করতে সাইন ইন করুন।';

  @override
  String get purchaseErrorTitle => 'পাওয়ার ত্রুটি';

  @override
  String get purchaseInvalidTransactionBody =>
      'কেনাটিতে যাচাইযোগ্য লেনদেন আইডি ছিল না।';

  @override
  String get purchaseVerificationPendingTitle => 'যাচাই প্রক্রিয়াধীন';

  @override
  String get purchaseVerificationPendingBody =>
      'এই মুহূর্তে স্টোর থেকে আপনার কেনাটি যাচাই করা যায়নি। এটি স্বয়ংক্রিয়ভাবে সম্পন্ন হবে, এবং আপনি দ্বিগুণ দাম পরিশোধ করবেন না।';

  @override
  String get purchaseNotAppliedTitle => 'কেনাটি প্রয়োগ করা যায়নি';

  @override
  String get purchaseNotAppliedBody =>
      'আপনার কেনাটি আপনার অ্যাকাউন্টে প্রয়োগ করা যায়নি। সাপোর্টে যোগাযোগ করুন এবং আবার কেনাটি করবেন না।';

  @override
  String get purchaseRestoreFailedTitle => 'পুনরুদ্ধার ব্যর্থ';

  @override
  String get purchaseRestoreFailedBody =>
      'কেনা পুনরুদ্ধার করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get purchaseRecoveredActiveBody => 'আপনার সাবস্ক্রিপশন সক্রিয়।';

  @override
  String get purchaseCompleteTitle => 'কেনা সম্পন্ন';

  @override
  String get giftCreateFailedTitle => 'গিফট তৈরি করা যায়নি';

  @override
  String get giftClaimFailedTitle => 'গিফট গ্রহণ করা যায়নি';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি গিফট আপনার জন্য',
      one: 'আপনার জন্য একটি গিফট',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '১ মাস',
      '12': '১ বছর',
      'other': '$months মাস',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remainingটি বাকি',
      one: '১টি বাকি',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro এর $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender আপনার জন্য FitCheck Pro এর $duration পাঠিয়েছেন। $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient এর জন্য FitCheck Pro গিফট';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender থেকে';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient এর জন্য';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender থেকে';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'আপনার প্রাপক';

  @override
  String get giftPreviewPlaceholderSender => 'আপনি';

  @override
  String get settingsSavedTitle => 'সংরক্ষিত';

  @override
  String get settingsNotSavedTitle => 'সংরক্ষিত হয়নি';

  @override
  String get settingsAiChooseProviderBody => 'একজন প্রোভাইডার নির্বাচন করুন।';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'কাস্টম প্রোভাইডারের জন্য একটি API URL প্রয়োজন।';

  @override
  String get settingsAiKeyRequiredBody => 'একটি API কী দিন।';

  @override
  String get settingsAiSavedBody => 'আপনার AI সেটিংস সংরক্ষিত হয়েছে।';

  @override
  String get settingsAiMissingDetailsTitle => 'বিস্তারিত অনুপস্থিত';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'পরীক্ষার জন্য একটি API URL এবং একটি চ্যাট মডেল দিন।';

  @override
  String get settingsAiKeyNeededTitle => 'API কী প্রয়োজন';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'পরীক্ষার জন্য আপনার API কী দিন। আপনার সংরক্ষিত কী গোপনীয় থাকবে।';

  @override
  String get settingsAiKeyToTestBody => 'পরীক্ষার জন্য আপনার API কী দিন।';

  @override
  String get settingsAiConnectedTitle => 'সংযুক্ত';

  @override
  String get settingsAiConnectedBody => 'সংযোগ কাজ করছে।';

  @override
  String get settingsAiTestFailedTitle => 'পরীক্ষা ব্যর্থ';

  @override
  String get settingsPreferencesSavedBody => 'আপনার পছন্দ সংরক্ষিত হয়েছে।';

  @override
  String get settingsPasswordNotChangedTitle => 'পাসওয়ার্ড পরিবর্তন হয়নি';

  @override
  String get settingsOAuthPasswordBody =>
      'এই অ্যাকাউন্ট Google বা Apple দিয়ে সাইন ইন করে। আগে \"পাসওয়ার্ড ভুলেছেন\" ব্যবহার করে পাসওয়ার্ড সেট করুন।';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'বর্তমান পাসওয়ার্ড সঠিক নয়।';

  @override
  String get settingsExportReadyTitle => 'এক্সপোর্ট প্রস্তুত';

  @override
  String get settingsExportReadyBody =>
      'আপনার ডেটা এক্সপোর্ট ডাউনলোডের জন্য প্রস্তুত।';

  @override
  String get settingsLinkCopiedTitle => 'লিংক কপি হয়েছে';

  @override
  String get settingsExportClipboardBody =>
      'আমরা আপনার ব্রাউজার খুলতে পারিনি, তাই ডাউনলোড লিংকটি কপি করেছি। তাড়াতাড়ি একটি ব্রাউজারে পেস্ট করুন: এটি মেয়াদোত্তীর্ণ হবে।';

  @override
  String get settingsExportFailedTitle => 'এক্সপোর্ট ব্যর্থ';

  @override
  String get settingsAccountNotDeletedTitle => 'অ্যাকাউন্ট মুছে যায়নি';

  @override
  String photoshootPhotoLimit(int max) {
    return 'আপনি সর্বোচ্চ $max ফটো যুক্ত করতে পারেন।';
  }

  @override
  String get photoshootPhotoLimitTitle => 'ফটো সীমা';

  @override
  String get photoshootAddAtLeastOnePhoto => 'অন্তত একটি ফটো যোগ করুন।';

  @override
  String get photoshootNoPhotosSelectedTitle => 'কোনো ফটো নেই';

  @override
  String get photoshootDescribeLookBody => 'আপনি যে লুক চান, তা বর্ণনা করুন।';

  @override
  String get photoshootPromptNeededTitle => 'প্রম্পট প্রয়োজন';

  @override
  String get photoshootConsentFeatureLabel => 'AI ফটোশুট';

  @override
  String get photoshootStatusPreparing => 'আপনার ফটো প্রস্তুত হচ্ছে';

  @override
  String get photoshootStatusGenerating => 'তৈরি হচ্ছে';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'ব্যাচ $current / $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done / $total সম্পন্ন';
  }

  @override
  String get photoshootGenerationFailedBody => 'জেনারেশন ব্যর্থ হয়েছে।';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready প্রস্তুত, $failed ব্যর্থ।';
  }

  @override
  String get photoshootPartlyDoneTitle => 'আংশিক সম্পন্ন';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবি প্রস্তুত।',
      one: '১টি ছবি প্রস্তুত।',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'সংযোগ বন্ধ হয়ে গেছে। আবার চেষ্টা করুন।';

  @override
  String get photoshootCouldNotCancelTitle => 'বাতিল করা যায়নি';

  @override
  String get photoshootRetryFailedTitle => 'পুনরায় চেষ্টা ব্যর্থ';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'ছবি $number প্রস্তুত।';
  }

  @override
  String get photoshootReplacedTitle => 'বদলে যাওয়া হয়েছে';

  @override
  String get photoshootSavedToGalleryBody =>
      'আপনার গ্যালারিতে সংরক্ষিত হয়েছে।';

  @override
  String get photoshootSavedTitle => 'সংরক্ষিত';

  @override
  String get photoshootNotSavedTitle => 'সংরক্ষিত হয়নি';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'সব $countটি ছবি আপনার গ্যালারিতে আছে।',
      one: '১টি ছবি আপনার গ্যালারিতে আছে।',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved এর $totalটি সংরক্ষিত।';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'কিছু ছবি সংরক্ষিত হয়নি';

  @override
  String get tryonConsentFeatureLabel => 'ভার্চুয়াল ট্রাই-অন';

  @override
  String get tryonAvatarUpdatedBody => 'আপনার ছবি হালনাগাদ হয়েছে।';

  @override
  String get tryonSavedTitle => 'সংরক্ষিত';

  @override
  String get tryonUploadFailedTitle => 'আপলোড ব্যর্থ';

  @override
  String get tryonChooseGarmentFirstBody =>
      'প্রথমে একটি পোশাকের ছবি নির্বাচন করুন।';

  @override
  String get tryonNoGarmentTitle => 'কোনো পোশাক নেই';

  @override
  String get tryonWaitForUploadBody =>
      'আপনার ছবি আপলোড সম্পন্ন হওয়া পর্যন্ত অপেক্ষা করুন।';

  @override
  String get tryonStillUploadingTitle => 'এখনও আপলোড হচ্ছে';

  @override
  String get tryonAddYourPhotoFirstBody => 'প্রথমে নিজের একটি ছবি যোগ করুন।';

  @override
  String get tryonReadyBody => 'আপনার ট্রাই-অন প্রস্তুত।';

  @override
  String get tryonFailedTitle => 'ট্রাই-অন ব্যর্থ';

  @override
  String get tryonSavedToGalleryBody => 'আপনার গ্যালারিতে সংরক্ষিত হয়েছে।';

  @override
  String get tryonNotSavedTitle => 'সংরক্ষিত হয়নি';

  @override
  String get calendarEventAddedBody => 'ইভেন্ট যোগ করা হয়েছে';

  @override
  String get calendarEventPlannedTitle => 'পরিকল্পিত';

  @override
  String get calendarEventSavedBody => 'ইভেন্ট সংরক্ষিত';

  @override
  String get calendarSavedTitle => 'সংরক্ষিত';

  @override
  String get calendarEventNotSavedTitle => 'ইভেন্ট সংরক্ষিত হয়নি';

  @override
  String get calendarEventRemovedBody => 'ইভেন্ট মুছে ফেলা হয়েছে';

  @override
  String get calendarEventDeletedTitle => 'মুছে ফেলা হয়েছে';

  @override
  String get calendarEventNotDeletedTitle => 'ইভেন্ট মুছে ফেলা হয়নি';

  @override
  String get calendarOutfitNotLinkedTitle => 'আউটফিট সংযুক্ত করা হয়নি';

  @override
  String get calendarLinkedTitle => 'সংযুক্ত';

  @override
  String get calendarOutfitNotRemovedTitle => 'আউটফিট সরানো হয়নি';

  @override
  String get calendarOutfitRemovedBody => 'আউটফিট সরানো হয়েছে';

  @override
  String get calendarDisconnectedBody => 'ক্যালেন্ডার বিচ্ছিন্ন করা হয়েছে';

  @override
  String get calendarDisconnectedTitle => 'বিচ্ছিন্ন';

  @override
  String get calendarNotDisconnectedTitle => 'ক্যালেন্ডার বিচ্ছিন্ন করা হয়নি';

  @override
  String get calendarTodayLabel => 'আজ';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ইভেন্ট',
      one: '১টি ইভেন্ট',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start থেকে $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, আউটফিট সংযুক্ত';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" মুছে ফেলা হবে।';
  }

  @override
  String get calendarThisAppLabel => 'এই অ্যাপ';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider এর সাথে সিঙ্ক এখনো উপলব্ধ নয়। আপনি এখানে ইভেন্ট যোগ করতে পারেন।';
  }

  @override
  String get calendarWeekdaySunShort => 'রবি';

  @override
  String get calendarWeekdayMonShort => 'সোম';

  @override
  String get calendarWeekdayTueShort => 'মঙ্গল';

  @override
  String get calendarWeekdayWedShort => 'বুধ';

  @override
  String get calendarWeekdayThuShort => 'বৃহঃ';

  @override
  String get calendarWeekdayFriShort => 'শুক্র';

  @override
  String get calendarWeekdaySatShort => 'শনি';

  @override
  String get calendarWeekdayMonday => 'সোমবার';

  @override
  String get calendarWeekdayTuesday => 'মঙ্গলবার';

  @override
  String get calendarWeekdayWednesday => 'বুধবার';

  @override
  String get calendarWeekdayThursday => 'বৃহস্পতিবার';

  @override
  String get calendarWeekdayFriday => 'শুক্রবার';

  @override
  String get calendarWeekdaySaturday => 'শনিবার';

  @override
  String get calendarWeekdaySunday => 'রবিবার';

  @override
  String get outfitSavedToFavouritesBody => 'পছন্দে যোগ করা হয়েছে';

  @override
  String get outfitRemovedFromFavouritesBody => 'পছন্দ থেকে সরানো হয়েছে';

  @override
  String get outfitNotSavedTitle => 'সংরক্ষণ হয়নি';

  @override
  String get outfitLoggedAsWornBody => 'আজ পরা হিসেবে রেকর্ড করা হয়েছে।';

  @override
  String get outfitNicePickTitle => 'দারুণ পছন্দ';

  @override
  String get outfitRemovedBody => 'সমবায় সরানো হয়েছে।';

  @override
  String get outfitDeletedTitle => 'মুছে ফেলা হয়েছে';

  @override
  String get outfitNotDeletedTitle => 'মুছা হয়নি';

  @override
  String get outfitDuplicatedBody => 'একটি কপি আপনার সমবায়-এ রয়েছে।';

  @override
  String get outfitDuplicatedTitle => 'কপি করা হয়েছে';

  @override
  String get outfitNotDuplicatedTitle => 'কপি হয়নি';

  @override
  String get outfitNotSharedTitle => 'শেয়ার হয়নি';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" প্রস্তুত।';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'কালেকশন তৈরি হয়নি';

  @override
  String get outfitCollectionUpdatedBody => 'কালেকশন হালনাগাদ করা হয়েছে।';

  @override
  String get outfitCollectionNotUpdatedTitle => 'কালেকশন হালনাগাদ হয়নি';

  @override
  String get outfitCollectionDeletedBody => 'কালেকশন মুছে ফেলা হয়েছে।';

  @override
  String get outfitCollectionNotDeletedTitle => 'কালেকশন মুছে যায়নি';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সমবায় যোগ করা হয়েছে।',
      one: '১টি সমবায় যোগ করা হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'সমবায় যোগ করা হয়নি';

  @override
  String get outfitPreviewNotCreatedTitle => 'প্রিভিউ তৈরি হয়নি';

  @override
  String get outfitGiveNameBody => 'সমবায়ের একটি নাম দিন।';

  @override
  String get outfitNameMissingTitle => 'নাম';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'কমপক্ষে একটি পিস বেছে নিন।';

  @override
  String outfitCreatedBody(String name) {
    return '$name আপনার সমবায়-এ রয়েছে।';
  }

  @override
  String get outfitSavedTitle => 'সংরক্ষিত';

  @override
  String get wardrobeAddedToFavouritesBody => 'পছন্দে যোগ করা হয়েছে';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'পছন্দ থেকে সরানো হয়েছে';

  @override
  String get wardrobeNotSavedTitle => 'সংরক্ষণ করা হয়নি';

  @override
  String get wardrobeLoggedAsWornBody => 'আজ পরা হিসেবে লেগড করা হয়েছে।';

  @override
  String get wardrobeRemovedFromClosetBody =>
      'আপনার ক্লোজেট থেকে সরানো হয়েছে।';

  @override
  String get wardrobeDeletedTitle => 'মুছে ফেলা হয়েছে';

  @override
  String get wardrobeNotDeletedTitle => 'মুছে ফেলা হয়নি';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পোশাক আপনার ক্লোজেট থেকে সরানো হয়েছে।',
      one: '১টি পোশাক আপনার ক্লোজেট থেকে সরানো হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'এআই ওয়ারড্রোব এক্সট্রাকশন';

  @override
  String get itemAddScanJobLabel => 'স্ক্যান';

  @override
  String get itemAddFoundEarlierBody => 'আগের স্ক্যানের মধ্যে পাওয়া গেছে';

  @override
  String get itemAddLookingAtPhoto => 'আপনার ছবি দেখা হচ্ছে';

  @override
  String get itemAddExtractionFailedBody => 'এক্সট্রাকশন ব্যর্থ হয়েছে';

  @override
  String get itemAddJobFailedBody => 'কর্মকল্প ব্যর্থ হয়েছে';

  @override
  String get itemAddConnectionLostBody =>
      'কানেকশন হারিয়ে গেছে। আবার চেষ্টা করুন।';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'প্রসেসিংয়ের সময় কানেকশন হারিয়ে গেছে।';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'পোশাক $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'পোশাক';

  @override
  String get itemAddNotCancelledTitle => 'বাতিল করা হয়নি';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পোশাক আপনার ক্লোজেটে আছে।',
      one: '১টি পোশাক আপনার ক্লোজেটে আছে।',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$totalটির মধ্যে $savedটি পোশাক সংরক্ষিত হয়েছে। বাকিগুলোর জন্য সংরক্ষণে ট্যাপ করুন।';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'কিছু পোশাক সংরক্ষণ করা হয়নি';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'কমপক্ষে একটি ছবি নির্বাচন করুন।';

  @override
  String get batchPhotoUnreadableBody => 'এই ছবিটি পড়া যায়নি।';

  @override
  String get batchNoPhotosReadableBody =>
      'এই ছবিগুলো পড়া যায়নি। অন্য ছবি চেষ্টা করুন।';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবি',
      one: '১টি ছবি',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'কাজ করার সময় কানেকশন হারিয়ে গেছে। আবার চেষ্টা করুন।';

  @override
  String get batchNotCancelledTitle => 'বাতিল করা হয়নি';

  @override
  String get batchPostLinkUnsupportedBody =>
      'পোস্ট লিংক সাপোর্ট করা হয় না। একটি প্রোফাইল লিংক দিন।';

  @override
  String get batchLinkSpacesBody => 'লিংকে স্পেস থাকতে পারে না।';

  @override
  String get batchEnterProfileLinkBody =>
      'ইনস্টাগ্রাম বা ফেসবুক প্রোফাইল লিংক দিন।';

  @override
  String get batchEnterProfileLinkShortBody => 'একটি প্রোফাইল লিংক দিন।';

  @override
  String get batchSignInPageNotOpenBody => 'লগইন পেজ খুলেনি। আবার চেষ্টা করুন।';

  @override
  String get batchSignInBrowserBody => 'ব্রাউজারে লগইন করুন, তারপর ফিরে আসুন।';

  @override
  String get batchConnectAccountTitle => 'আপনার অ্যাকাউন্ট সংযুক্ত করুন';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'আপনার অথেনটিফিকেটর অ্যাপের কোডটি দিন।';

  @override
  String get batchInstagramSecurityCheckBody =>
      'ইনস্টাগ্রামে নিরাপত্তা পরীক্ষা প্রয়োজন। আগে ব্রাউজারে লগইন করুন।';

  @override
  String get batchEnterCredentialsAgainBody =>
      'আপনার ইউজারনেম ও পাসওয়ার্ড আবার দিন।';

  @override
  String get batchSignInFailedBody =>
      'লগইন ব্যর্থ। আপনার ইউজারনেম ও পাসওয়ার্ড যাচাই করুন।';

  @override
  String get batchSignInToKeepImportingBody =>
      'আনপোর্ট চালিয়ে যেতে লগইন করুন।';

  @override
  String get batchAccountNotConnectedBody => 'আপনার অ্যাকাউন্ট সংযুক্ত হয়নি।';

  @override
  String get batchAccountConnectedTitle => 'অ্যাকাউন্ট সংযুক্ত হয়েছে';

  @override
  String get batchNotConnectedTitle => 'সংযুক্ত নয়';

  @override
  String get batchImportConnectionLostBody =>
      'আনপোর্টের সংযোগ হারিয়ে গেছে। যাচাই করতে রিফ্রেশ করুন।';

  @override
  String batchPickUpToBody(int max) {
    return 'সর্বোচ্চ $maxটি ছবি নির্বাচন করুন। আমরা গয়না খুঁজে বের করব।';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count of $total ছবি';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'ছবি $done of $count প্রস্তুত হচ্ছে';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবিতে গয়না খুঁজুন',
      one: '১টি ছবিতে গয়না খুঁজুন',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'আপনার $platform অ্যাকাউন্টে দুই ধাপের লগইন ব্যবহৃত হয়। আপনার অথেনটিফিকেটর অ্যাপের ৬-আঙ্কিক কোডটি দিন।';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'এই $platform প্রোফাইলটি ব্যক্তিগত অথবা ছবি দেখাতে সাইন-ইন প্রয়োজন।';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform দিয়ে সংযুক্ত করুন';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এ পর্যন্ত $countটি ছবি পাওয়া গেছে',
      one: 'এ পর্যন্ত ১টি ছবি পাওয়া গেছে',
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
    return '$processed of $total প্রক্রিয়াজাত · $added যুক্ত হয়েছে · $waiting অপেক্ষায় · $skipped বাদ দেওয়া হয়েছে';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'ছবি $number স্ক্যান হচ্ছে';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'ছবি $number পরের বার্তা';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'ছবি $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি গয়না পাওয়া গেছে',
      one: '১টি গয়না পাওয়া গেছে',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবি আপনার ক্লোজেটে যুক্ত হয়েছে।',
      one: '১টি ছবি আপনার ক্লোজেটে যুক্ত হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'আরও $countটি স্টুডিও ছবি আসছে। আপনি প্রস্তুত যা আছে তা সংরক্ষণ করতে পারেন, অথবা চলে যান — আমরা আপনাকে জানান দেব।',
      one:
          'আরও ১টি স্টুডিও ছবি আসছে। আপনি প্রস্তুত যা আছে তা সংরক্ষণ করতে পারেন, অথবা চলে যান — আমরা আপনাকে জানান দেব।',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'এখনও সংরক্ষিত হয়নি: $names।';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$piecesটি গয়না',
      one: '১টি গয়না',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photosটি ছবি',
      one: '১টি ছবি',
    );
    return '$_temp0 from $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosenটি নির্বাচিত। বাদ দিতে একটি গয়না ট্যাপ করুন।';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পিস সঞ্চয় করা হচ্ছে',
      one: '১টি পিস সঞ্চয় করা হচ্ছে',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পিস সেভ করুন',
      one: '১টি পিস সেভ করুন',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'আপনার বডি প্রোফাইল সংরক্ষিত হয়েছে।';

  @override
  String get bodyProfileSavedTitle => 'সংরক্ষিত';

  @override
  String get bodyProfileNotSavedTitle => 'সংরক্ষিত হয়নি';

  @override
  String get bodyProfileSetDefaultBody => 'ডিফল্ট প্রোফাইল হিসেবে সেট করুন।';

  @override
  String get bodyProfileDeletedBody => 'বডি প্রোফাইল মুছে ফেলা হয়েছে।';

  @override
  String get bodyProfileDeletedTitle => 'মুছে ফেলা হয়েছে';

  @override
  String get bodyProfileNotDeletedTitle => 'মুছে ফেলা হয়নি';

  @override
  String get feedbackNotSentTitle => 'পাঠানো হয়নি';

  @override
  String get feedbackSentBody =>
      'ধন্যবাদ। আমরা প্রতিটি বার্তা পড়ি এবং প্রয়োজনে উত্তর দিই।';

  @override
  String get feedbackSentTitle => 'ফিডব্যাক পাঠানো হয়েছে';

  @override
  String get recommendUnnamedPiece => 'নামবিহীন পিস';

  @override
  String get recommendEnterCityBody =>
      'আবহবস্তু অনুযায়ী সুপারিশ পেতে আপনার শহর লিখুন।';

  @override
  String get recommendWhichCityTitle => 'কোন শহর?';

  @override
  String get aiConsentSheetTitle => 'AI সার্ভিসের সাথে ছবি শেয়ার করা';

  @override
  String get aiConsentSheetBody =>
      'আপনার ট্রাই-অন ও ফটোশুট ইমেজ তৈরির জন্য, FitCheck AI আপনার দেওয়া ছবিগুলো (চোখ এবং শরীরের ছবি সহ) প্রসেসিংয়ের জন্য একটি বিশ্বস্ত তৃতীয় পক্ষের AI প্রোভাইডারের কাছে (যেমন OpenAI বা Google Gemini) পাঠায়। আমাদের শর্তমতে, তারা আপনার ইমেজ তৈরি করে এবং মডেল ট্রেনিং-এ ব্যবহার করে না। ছবিগুলো নিরাপদে প্রেয়ারিত হয় এবং কখনো বিজ্ঞাপনের জন্য শেয়ার করা হয় না।';

  @override
  String get aiConsentSheetPermission =>
      'চালিয়ে গেলে, আপনি আপনার ছবিগুলো এই AI প্রোভাইডারদের সাথে ইমেজ তৈরির জন্য শেয়ার করার স্পষ্ট অনুমতি দিচ্ছেন।';

  @override
  String get skeletonsLoadMoreFailed => 'আরও লোড করা যায়নি।';

  @override
  String get jobsPiecesReadyTitle => 'আপনার পিসগুলো প্রস্তুত';

  @override
  String get jobsScanStoppedTitle => 'স্ক্যান বন্ধ হয়েছে';

  @override
  String get jobsNothingSavedBody => 'কিছুই সংরক্ষিত হয়নি। আবার চেষ্টা করুন।';

  @override
  String get jobsPhotoUploadFailedBody => 'ছবি আপলোড ব্যর্থ হয়েছে।';

  @override
  String get authGoogleSignInStartFailed =>
      'Google সাইন-ইন শুরু করা যাচ্ছে না। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get referralAppliedTitle => 'রেফারেল প্রয়োগ হয়েছে!';

  @override
  String get billingStoreUnavailableBody =>
      'এই ডিভাইসে স্টোর পুর্চেসিং উপলব্ধ নয়।';

  @override
  String get billingPurchaseProcessingBody =>
      'এই পুর্চেস এখনো প্রসেসিং হচ্ছে। আপনার প্ল্যান দেখতে এক মিনিট পরে অ্যাপটি খুলুন।';

  @override
  String get profileAvatarUploadNoUrl =>
      'অ্যাভাটার আপলোড থেকে কোনো ইমেজ URL পাওয়া যায়নি।';

  @override
  String get rewardsDayStreakLabel => 'দিনের স্ট্রিক';

  @override
  String rewardsBestStreak(int days) {
    return 'সেরা $days দিন';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission অ্যাক্সেস প্রয়োজন';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission-এর অনুমতি বর্তমানে নেই। সেটিংস খুলে অনুমতি দিন, তারপর আবার চেষ্টা করুন।';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'ধাপ $step of 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'ধাপ $step of $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'ছবি $index সরান';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'ছবি $index সরান';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points পয়েন্ট';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '$email-এ ইমেইল করুন। আমরা ২৪ ঘণ্টার মধ্যে রিপোর্ট দেখি।';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece সরান';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '“$name” মুছুন?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '“$name”-এ যোগ করুন';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '“$name” মুছে ফেলা হয়েছে। এর আইটেমগুলি ক্লোজেট থেকে অপরিবর্তিত থাকবে।';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'সব $count দেখুন';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'আজ $countটি বাকি';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'ছবি $index ব্যর্থ';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max টির মধ্যে $selectedটি নির্বাচিত';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape গঠন · $tone ত্বক';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name মুছুন?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name-এর বিকল্প';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'সর্বাধিক পরা: $name, $count বার';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: সেট করা হয়নি';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% মিল';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max টির মধ্যে $pickedটি নির্বাচিত';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item সরান';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency অগ্রাধিকার';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'এই প্ল্যানটি $store এর মাধ্যমে বিল করে। $store অ্যাকাউন্ট সেটিংসে পরিবর্তন বা বাতিল করুন।';
  }

  @override
  String billingManageInStore(String store) {
    return '$store-এ পরিচালনা করুন';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max এর মধ্যে $current ব্যবহৃত';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'আনুমানিক $seconds সেকেন্ড বাকি';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$totalটির মধ্যে $doneটি স্টুডিও ছবি প্রস্তুত';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total টি স্টুডিও ছবির মধ্যে $ready টি তৈরি হয়েছে। কোনো টুকরা ছাড়ার জন্য ট্যাপ করুন।';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height সেমি · $weight কেজি';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'না';
}
