// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'होम';

  @override
  String get tabPhotoshoot => 'फोटोशूट';

  @override
  String get tabCloset => 'कपाट';

  @override
  String get tabOutfits => 'आउटफिट्स';

  @override
  String get tabMore => 'अधिक';

  @override
  String get actionAddItem => 'आयटम जोडा';

  @override
  String get actionCreateOutfit => 'आउटफिट बनवा';

  @override
  String get actionCancel => 'रद्द करा';

  @override
  String get actionDelete => 'डिलीट करा';

  @override
  String get actionSave => 'सेव्ह करा';

  @override
  String get actionRetry => 'पुन्हा प्रयत्न करा';

  @override
  String get actionDone => 'पूर्ण';

  @override
  String get actionNext => 'पुढे';

  @override
  String get actionBack => 'मागे';

  @override
  String get actionClose => 'बंद करा';

  @override
  String get actionSearch => 'शोधा';

  @override
  String get actionContinue => 'सुरू ठेवा';

  @override
  String get stateLoading => 'लोड होत आहे';

  @override
  String get stateErrorTitle => 'काहीतरी चूक झाली';

  @override
  String get stateErrorBody =>
      'पुन्हा प्रयत्न करा. समस्या कायम राहिल्यास सपोर्टशी संपर्क साधा.';

  @override
  String get stateOfflineTitle => 'तुम्ही ऑफलाइन आहात';

  @override
  String get stateOfflineBody =>
      'कपाट सिंक करण्यासाठी आणि आउटफिट्स तयार करण्यासाठी इंटरनेटशी कनेक्ट करा.';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get settingsAccountSection => 'अकाउंट';

  @override
  String get settingsPreferencesSection => 'प्राधान्ये';

  @override
  String get settingsPlanBilling => 'प्लॅन आणि बिलिंग';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsNotifications => 'नोटिफिकेशन्स';

  @override
  String get settingsUnits => 'मापन युनिट्स';

  @override
  String get settingsAppearance => 'स्वरूप';

  @override
  String get settingsPrivacySection => 'गोपनीयता आणि डेटा';

  @override
  String get settingsAboutSection => 'आमच्याबद्दल';

  @override
  String get settingsSignOut => 'साइन आउट करा';

  @override
  String get settingsDeleteAccount => 'खाते हटवा';

  @override
  String get settingsDeleteAccountTitle => 'तुमचे खाते हटवायचे आहे का?';

  @override
  String get settingsDeleteAccountBody =>
      'यामुळे तुमचे कपाट, पोशाख, फोटो आणि प्रोफाइल हटवले जाईल. हे पूर्ववत करता येणार नाही.';

  @override
  String get settingsUnitsImperial => 'इम्पीरियल (in, lb)';

  @override
  String get settingsUnitsMetric => 'मेट्रिक (cm, kg)';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSystem => 'डिव्हाइसची भाषा वापरा';

  @override
  String get languageSystemBody => 'FitCheck AI तुमच्या फोनची भाषा वापरते.';

  @override
  String get languageSearchHint => 'भाषा शोधा';

  @override
  String get languageCurrent => 'सध्याची';

  @override
  String get languageReviewNote =>
      'हे भाषांतर नवीन आहे. काही चुकीचे वाटल्यास आम्हाला कळवा.';

  @override
  String get languageChanged => 'भाषा अपडेट केली';

  @override
  String get paywallTitle => 'तुमचा प्लॅन निवडा';

  @override
  String get paywallTrialBadge => '१ महिना मोफत';

  @override
  String get paywallTrialTitle => 'तुमचा Pro चा पहिला महिना मोफत';

  @override
  String get paywallTrialBody =>
      'तुमचे संपूर्ण कपाट एकदाच अपलोड करा. त्यानंतर नवीन कपडे जोडत राहा.';

  @override
  String get paywallFreeForeverTitle => 'नेहमी मोफत';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'कार्डची गरज नाही. दरमहा तुम्हाला $uploads AI अपलोड्स, $outfits पोशाख आणि दररोज $images फोटोशूट इमेजेस मिळतात.';
  }

  @override
  String get paywallCtaTrial => 'माझा मोफत महिना सुरू करा';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan वर अपग्रेड करा';
  }

  @override
  String get paywallRestore => 'खरेदी रिस्टोअर करा';

  @override
  String get paywallManage => 'सबस्क्रिप्शन व्यवस्थापित करा';

  @override
  String get paywallTerms => 'वापराच्या अटी';

  @override
  String get paywallPrivacy => 'गोपनीयता धोरण';

  @override
  String get paywallPerMonth => 'दरमहा';

  @override
  String get paywallPerYear => 'दरवर्षी';

  @override
  String get paywallBestValue => 'सर्वोत्तम मूल्य';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'फक्त नवीन सदस्यांसाठी मोफत चाचणी. चाचणीनंतर, $price वर Pro नूतनीकरण होईल, जोपर्यंत ते संपण्यापूर्वी किमान २४ तास आधी रद्द केले जात नाही.';
  }

  @override
  String get introTitle => 'तुमचे कपाट, शेवटी व्यवस्थित';

  @override
  String get introBody =>
      'तुमच्या कपड्यांचे एकदा फोटो काढा. तुमच्याकडे असलेल्या कपड्यांमधून आउटफिट कल्पना, ट्राय-ऑन प्रिव्ह्यू आणि स्टुडिओ फोटो मिळवा.';

  @override
  String get introStart => 'सुरुवात करा';

  @override
  String get introHaveAccount => 'माझ्याकडे आधीच खाते आहे';

  @override
  String get introSkip => 'वगळा';

  @override
  String get authSignIn => 'साइन इन करा';

  @override
  String get authSignUp => 'खाते तयार करा';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authForgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get authContinueApple => 'Apple सह सुरू ठेवा';

  @override
  String get authContinueGoogle => 'Google सह सुरू ठेवा';

  @override
  String get authOrDivider => 'किंवा';

  @override
  String get wardrobeTitle => 'कपाट';

  @override
  String get wardrobeEmptyTitle => 'तुमचे कपाट रिकामे आहे';

  @override
  String get wardrobeEmptyBody =>
      'तुमचा पहिला कपडा जोडा, किंवा संपूर्ण रॅकचा फोटो एकदाच अपलोड करा.';

  @override
  String get wardrobeAddFirst => 'पहिली वस्तू जोडा';

  @override
  String get wardrobeSearchHint => 'तुमच्या कपाटात शोधा';

  @override
  String get categoryTops => 'टॉप्स';

  @override
  String get categoryBottoms => 'बॉटम्स';

  @override
  String get categoryShoes => 'पादत्राणे';

  @override
  String get categoryAccessories => 'ॲक्सेसरीज';

  @override
  String get categoryOuterwear => 'आउटरवेअर';

  @override
  String get categorySwimwear => 'स्विमवेअर';

  @override
  String get categoryActivewear => 'ॲक्टिव्हवेअर';

  @override
  String get categoryOther => 'इतर';

  @override
  String get conditionClean => 'स्वच्छ';

  @override
  String get conditionDirty => 'अस्वच्छ';

  @override
  String get conditionLaundry => 'धुलाईसाठी';

  @override
  String get conditionRepair => 'दुरुस्ती हवी';

  @override
  String get conditionDonate => 'दान करण्यासाठी';

  @override
  String get seasonSpring => 'वसंत';

  @override
  String get seasonSummer => 'उन्हाळा';

  @override
  String get seasonFall => 'शरद';

  @override
  String get seasonWinter => 'हिवाळा';

  @override
  String get seasonAll => 'सर्व ऋतू';

  @override
  String get styleCasual => 'कॅज्युअल';

  @override
  String get styleFormal => 'फॉर्मल';

  @override
  String get styleBusiness => 'बिझनेस';

  @override
  String get styleSporty => 'स्पोर्टी';

  @override
  String get styleBohemian => 'बोहेमियन';

  @override
  String get styleStreetwear => 'स्ट्रीटवेअर';

  @override
  String get styleVintage => 'व्हिंटेज';

  @override
  String get styleMinimalist => 'मिनिमलिस्ट';

  @override
  String get styleRomantic => 'रोमँटिक';

  @override
  String get styleEdgy => 'एजी';

  @override
  String get stylePreppy => 'प्रेपी';

  @override
  String get styleArtsy => 'आर्टसी';

  @override
  String get styleClassic => 'क्लासिक';

  @override
  String get styleElegant => 'एलिगंट';

  @override
  String get styleOther => 'इतर';

  @override
  String get occasionWork => 'काम';

  @override
  String get occasionDateNight => 'डेट नाईट';

  @override
  String get occasionTravel => 'प्रवास';

  @override
  String get occasionWedding => 'लग्न';

  @override
  String get occasionGym => 'जिम';

  @override
  String get occasionWeekend => 'विकेंड';

  @override
  String get occasionParty => 'पार्टी';

  @override
  String get occasionInterview => 'मुलाखत';

  @override
  String get colorBlack => 'काळा';

  @override
  String get colorWhite => 'पांढरा';

  @override
  String get colorGrey => 'राखाडी';

  @override
  String get colorNavy => 'नेव्ही';

  @override
  String get colorBrown => 'तपकिरी';

  @override
  String get colorRed => 'लाल';

  @override
  String get colorBlue => 'निळा';

  @override
  String get colorGreen => 'हिरवा';

  @override
  String get colorPink => 'गुलाबी';

  @override
  String get colorPurple => 'जांभळा';

  @override
  String get colorYellow => 'पिवळा';

  @override
  String get colorOrange => 'केशरी';

  @override
  String get colorBeige => 'बेज';

  @override
  String get dateToday => 'आज';

  @override
  String get dateYesterday => 'काल';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिवस पूर्वी',
      one: '१ दिवस पूर्वी',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आठवडे पूर्वी',
      one: '१ आठवडा पूर्वी',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महिने पूर्वी',
      one: '१ महिना पूर्वी',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वर्षे पूर्वी',
      one: '१ वर्ष पूर्वी',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI आवडले का?';

  @override
  String get ratingPromptBody =>
      'एक छोटी रेटिंग इतरांना त्यांची स्टाईल शोधण्यात मदत करते.';

  @override
  String get ratingPromptYes => 'रेट करा';

  @override
  String get ratingPromptNo => 'आता नको';

  @override
  String get closetNoMatchesTitle => 'काहीही सापडले नाही';

  @override
  String get closetNoMatchesBody => 'फिल्टर्स कमी करा किंवा पुन्हा शोधा.';

  @override
  String get closetClearFilters => 'फिल्टर्स काढा';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पीस',
      one: '१ पीस',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'तुमचे कपडे लोड होत आहेत';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count निवडले',
      one: '१ निवडले',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'निवडलेले हटवा';

  @override
  String get closetCancelSelection => 'निवड रद्द करा';

  @override
  String get closetCloseSearch => 'शोध बंद करा';

  @override
  String get closetShowGrid => 'ग्रिडमध्ये पहा';

  @override
  String get closetShowList => 'यादीत पहा';

  @override
  String get closetShowRows => 'ओळींमध्ये पहा';

  @override
  String get closetStatsTitle => 'कपाटाची आकडेवारी';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वस्तू हटवू?',
      one: '१ वस्तू हटवू?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'या वस्तू वापरणारे आऊटफिट्स बदलले जातील.';

  @override
  String get closetSortBy => 'क्रमानुसार लावा';

  @override
  String get closetFavourites => 'आवडते';

  @override
  String get closetFavourite => 'आवडते करा';

  @override
  String get closetUnfavourite => 'आवडत्यातून काढा';

  @override
  String get closetWoreToday => 'आज घातले';

  @override
  String closetWornTimes(int count) {
    return '$count वेळा घातले';
  }

  @override
  String get closetCategoryLabel => 'वर्ग';

  @override
  String get closetUseCaseLabel => 'वापराचा प्रकार';

  @override
  String get closetAnyUseCase => 'कोणताही';

  @override
  String get closetOtherUseCase => 'इतर वापर';

  @override
  String get closetOtherUseCaseHint => 'उदाहरणार्थ, ब्रंच';

  @override
  String get closetUseUseCase => 'हे वापरा';

  @override
  String get closetClearAll => 'सर्व साफ करा';

  @override
  String get sortNewest => 'सर्वात नवीन';

  @override
  String get sortOldest => 'सर्वात जुने';

  @override
  String get sortName => 'नाव (अ-ज्ञ)';

  @override
  String get sortMostWorn => 'सर्वात जास्त घातलेले';

  @override
  String get useCaseInformal => 'अनौपचारिक';

  @override
  String get useCaseDate => 'डेट';

  @override
  String get useCaseDinner => 'रात्रीचे जेवण';

  @override
  String get useCaseLunch => 'दुपारचे जेवण';

  @override
  String get actionSelect => 'निवडा';

  @override
  String get actionEdit => 'संपादित करा';

  @override
  String get actionFilter => 'फिल्टर';

  @override
  String get actionSort => 'क्रमवारी';

  @override
  String get actionAll => 'सर्व';

  @override
  String get dashboardStartClosetTitle => 'तुमचे कपाट सुरू करा';

  @override
  String get dashboardStartClosetBody =>
      'काही कपड्यांचे फोटो काढा. आम्ही त्यांना टॅग करू.';

  @override
  String get dashboardPieces => 'कपडे';

  @override
  String get dashboardOutfits => 'आउटफिट्स';

  @override
  String get dashboardDayStreak => 'दिवसांचा सिलसिला';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'या महिन्यात +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'सर्वोत्तम $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आवडते',
      one: '१ आवडते',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेव्ह केलेले आउटफिट्स',
      one: '१ सेव्ह केलेला आउटफिट',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'सर्वात जास्त वापरलेले: $name, $count वेळा';
  }

  @override
  String get setupSkip => 'सेटअप वगळा';

  @override
  String get setupWhoTitle => 'आम्ही कोणाला स्टाईल करत आहोत?';

  @override
  String get setupWhoBody =>
      'ट्राय-ऑन आणि फोटोशूटसाठी मॉडेल सेट करा. तुम्ही ते प्रोफाइलमध्ये बदलू शकता.';

  @override
  String get setupStyleTitle => 'तुम्ही काय जास्त घालता?';

  @override
  String get setupStyleBody => 'कोणतेही निवडा. आउटफिट कल्पना येथून सुरू होतात.';

  @override
  String get setupClosetTitle => 'तुमचे पहिले कपडे जोडा.';

  @override
  String get setupClosetBody =>
      'काही कपड्यांचे किंवा ढिगाऱ्याचे फोटो काढा. प्रत्येक पीस कापून फाइल केला जाईल.';

  @override
  String get setupAddClothes => 'कपडे जोडा';

  @override
  String get setupStylesLabel => 'स्टाईल्स';

  @override
  String get setupOccasionsLabel => 'प्रसंग';

  @override
  String get setupSkipStep => 'वगळा';

  @override
  String get setupLater => 'नंतर';

  @override
  String get setupSaveError => 'सेव्ह करता आले नाही';

  @override
  String get genderWomen => 'महिला';

  @override
  String get genderMen => 'पुरुष';

  @override
  String get genderNonBinary => 'नॉन-बायनरी';

  @override
  String get genderPreferNotToSay => 'सांगणे टाळतो';

  @override
  String get outfitEmptyTitle => 'आणखी कोणतेही आऊटफिट नाहीत';

  @override
  String get outfitEmptyBody =>
      'तुमच्या कपाटातील कपड्यांच्या जोड्या बनवा आणि लूक सेव्ह करा.';

  @override
  String get outfitNoMatchesTitle => 'कोणतेही आऊटफिट जुळत नाहीत';

  @override
  String get outfitSearchHint => 'तुमचे आऊटफिट शोधा';

  @override
  String get outfitLoading => 'तुमचे आऊटफिट लोड होत आहेत';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आऊटफिट्स',
      one: '१ आऊटफिट',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'स्टाईल आणि सीझन';

  @override
  String get outfitCollections => 'कलेक्शन्स';

  @override
  String get outfitDuplicate => 'डुप्लिकेट';

  @override
  String get outfitDeleteTitle => 'हे आऊटफिट डिलीट करायचे?';

  @override
  String get outfitDeleteBody => 'यातील कपडे तुमच्या कपाटात राहतील.';

  @override
  String get outfitDrafts => 'ड्राफ्ट्स';

  @override
  String get outfitDraft => 'ड्राफ्ट';

  @override
  String get filterStyle => 'स्टाईल';

  @override
  String get filterSeason => 'सीझन';

  @override
  String get itemDetailDeleteTitle => 'हा कपडा डिलीट करायचा?';

  @override
  String get itemDetailDeleteBody =>
      'ज्या आऊटफिटमध्ये हा वापरला आहे, त्यातून तो निघून जाईल.';

  @override
  String get itemAddFavourite => 'फेव्हरेटमध्ये जोडा';

  @override
  String itemSize(String size) {
    return 'साईज $size';
  }

  @override
  String get itemColours => 'रंग';

  @override
  String get itemMaterial => 'मटेरियल';

  @override
  String get itemPattern => 'पॅटर्न';

  @override
  String get itemUseCases => 'वापराचे प्रकार';

  @override
  String get itemKeptIn => 'येथे ठेवले आहे';

  @override
  String get itemPrice => 'किंमत';

  @override
  String get itemBought => 'खरेदी केले';

  @override
  String get itemTags => 'टॅग्स';

  @override
  String get itemAdded => 'जोडले';

  @override
  String get itemTimesWornLabel => 'वापरल्याची संख्या';

  @override
  String get itemLastWornLabel => 'शेवटचे वापरले';

  @override
  String get itemNeverWorn => 'कधीही नाही';

  @override
  String get authEntryBody =>
      'तुमच्या मालकीचे प्रत्येक कपडे, FitCheck AI द्वारे स्टाईल करा. आउटफिट्स प्लॅन करा, ट्राय करा आणि फोटो काढा.';

  @override
  String get authCreateCloset => 'तुमचे कपाट तयार करा';

  @override
  String get authWelcomeBack => 'पुन्हा स्वागत आहे';

  @override
  String get authSignInBody => 'तुमचे कपाट उघडण्यासाठी साइन इन करा.';

  @override
  String get authCreateAccount => 'खाते तयार करा';

  @override
  String get authCreateClosetBody =>
      'फक्त एक मिनिट लागेल. तुमचे पहिले काही आयटम मोफत आहेत.';

  @override
  String get authName => 'नाव';

  @override
  String get authConfirmPassword => 'पासवर्डची खात्री करा';

  @override
  String get authReferralCode => 'रेफरल कोड (पर्यायी)';

  @override
  String get authResetTitle => 'पासवर्ड रिसेट करा';

  @override
  String get authResetBody =>
      'आम्ही तुम्हाला नवीन पासवर्ड निवडण्यासाठी ईमेलवर लिंक पाठवू.';

  @override
  String get authSendResetLink => 'रिसेट लिंक पाठवा';

  @override
  String get authBackToSignIn => 'साइन इन वर परत जा';

  @override
  String get authEnterEmail => 'तुमचा ईमेल टाका';

  @override
  String get authEnterValidEmail => 'वैध ईमेल टाका';

  @override
  String get authEnterPassword => 'तुमचा पासवर्ड टाका';

  @override
  String get authPasswordTooShort => 'किमान ६ अक्षरे';

  @override
  String get authShowPassword => 'पासवर्ड दाखवा';

  @override
  String get authHidePassword => 'पासवर्ड लपवा';

  @override
  String get authNewHere => 'नवीन आहात?';

  @override
  String authConfirmEmail(String email) {
    return 'साइन इन करण्यापूर्वी $email ची खात्री करा. तुमचा इनबॉक्स तपासा.';
  }

  @override
  String get authResendEmail => 'पुन्हा पाठवा';

  @override
  String get authResendingEmail => 'पाठवत आहे...';

  @override
  String get authPasswordsDoNotMatch => 'पासवर्ड जुळत नाहीत';

  @override
  String get authEnterName => 'तुमचे नाव टाका';

  @override
  String get authChoosePassword => 'पासवर्ड निवडा';

  @override
  String get authHaveAccount => 'खाते आहे का?';

  @override
  String get authCodeAccepted => 'कोड स्वीकारला';

  @override
  String get authCodeNotFound => 'कोड सापडला नाही';

  @override
  String authReferralFrom(String name) {
    return '$name कडून. तुम्हा दोघांना एक महिना मोफत मिळेल.';
  }

  @override
  String get authReferralInvalid => 'आम्हाला हा कोड सापडला नाही.';

  @override
  String authResetSent(String email) {
    return '$email वर पाठवले आहे. या फोनवर लिंक उघडा.';
  }

  @override
  String get introSlide1Title => 'तुमच्या कपाटाचे फोटो काढा.';

  @override
  String get introSlide1Body =>
      'कपड्यांच्या ढिगाऱ्याचे फोटो काढा. प्रत्येक कपडा आपोआप वेगळा करून जतन केला जाईल.';

  @override
  String get introSlide2Title => 'लवकर तयार व्हा.';

  @override
  String get introSlide2Body =>
      'तुमच्या कपड्यांमधून, तुमच्या नियोजनानुसार आणि हवामानानुसार कपडे निवडा.';

  @override
  String get introSlide3Title => 'घालण्यापूर्वी तपासा.';

  @override
  String get introSlide3Body =>
      'तुमच्या फोटोवर कपडे घालून पहा किंवा फॅशन शूटप्रमाणे फोटो काढा.';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsThemeLight => 'लाईट';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsTemperature => 'तापमान';

  @override
  String get settingsEmailUpdates => 'ईमेल अपडेट्स';

  @override
  String get settingsEmailUpdatesBody => 'ईमेलद्वारे बातम्या आणि टिप्स';

  @override
  String get settingsOutfitReminders => 'आउटफिट रिमाइंडर्स';

  @override
  String get settingsOutfitRemindersBody =>
      'तुम्ही काय घातले होते हे नोंदवण्यासाठी सूचना';

  @override
  String get settingsWeeklySummary => 'साप्ताहिक सारांश';

  @override
  String get settingsWeeklySummaryBody => 'तुमच्या आठवड्यातील कपड्यांचा सारांश';

  @override
  String get settingsStyleSection => 'स्टाईल';

  @override
  String get settingsPreferredStyles => 'आवडत्या स्टाईल्स';

  @override
  String get settingsPreferredColours => 'आवडते रंग';

  @override
  String get settingsNoneChosen => 'काहीही निवडलेले नाही';

  @override
  String get settingsPlanAiSection => 'प्लॅन आणि AI';

  @override
  String get settingsPlanBillingBody => 'प्लॅन, वापर आणि अपग्रेड्स';

  @override
  String get settingsPlanUsageBody => 'प्लॅन आणि वापर';

  @override
  String get settingsInviteFriends => 'मित्रांना आमंत्रित करा';

  @override
  String get settingsInviteFriendsBody => 'प्रत्येक मित्रासाठी एक महिना मोफत';

  @override
  String get settingsAiProvider => 'AI प्रदाता';

  @override
  String get settingsAiProviderBody =>
      'टॅगिंग आणि प्रतिमांसाठी स्वतःचे मॉडेल वापरा';

  @override
  String get settingsAppVersion => 'ॲप आवृत्ती';

  @override
  String get settingsPrivacyTerms => 'गोपनीयता आणि अटी';

  @override
  String get settingsReportProblem => 'समस्या कळवा';

  @override
  String get settingsChangePassword => 'पासवर्ड बदला';

  @override
  String get settingsExportData => 'डेटा एक्सपोर्ट करा';

  @override
  String get settingsExportBody =>
      'आम्ही तुमच्या सर्व सेव्ह केलेल्या डेटाची फाईल तयार करू आणि डाउनलोड उघडू.';

  @override
  String get settingsExportAction => 'एक्सपोर्ट';

  @override
  String get settingsCurrentPassword => 'सध्याचा पासवर्ड';

  @override
  String get settingsNewPassword => 'नवीन पासवर्ड';

  @override
  String get settingsConfirmNewPassword => 'नवीन पासवर्डची खात्री करा';

  @override
  String get settingsEnterCurrentPassword => 'सध्याचा पासवर्ड टाका';

  @override
  String get settingsEnterNewPassword => 'नवीन पासवर्ड टाका';

  @override
  String get settingsPasswordMin8 => 'किमान ८ अक्षरे वापरा';

  @override
  String get settingsPasswordNeedsUpper => 'एक कॅपिटल अक्षर जोडा';

  @override
  String get settingsPasswordNeedsLower => 'एक स्मॉल अक्षर जोडा';

  @override
  String get settingsPasswordNeedsDigit => 'एक अंक जोडा';

  @override
  String get settingsPasswordsNoMatch => 'पासवर्ड जुळत नाहीत';

  @override
  String get settingsChangeAction => 'बदला';

  @override
  String get itemAddSnapTitle => 'फोटो काढा';

  @override
  String get itemAddSnapBody =>
      'आम्ही फोटोतील प्रत्येक वस्तू शोधून तिचे स्पष्ट चित्र तयार करू.';

  @override
  String get itemAddCamera => 'फोटो काढा';

  @override
  String get itemAddGallery => 'गॅलरीतून निवडा';

  @override
  String get itemAddOtherWays => 'इतर मार्ग';

  @override
  String get itemAddSeveral => 'अनेक फोटो जोडा';

  @override
  String get itemAddSeveralBody => 'एकावेळी ५० पर्यंत';

  @override
  String get itemAddImportProfile => 'प्रोफाइलवरून इम्पोर्ट करा';

  @override
  String get itemAddImportProfileBody => 'Instagram किंवा Facebook';

  @override
  String get itemAddEnterDetails => 'स्वतः तपशील भरा';

  @override
  String get itemAddEnterDetailsBody => 'फोटोची गरज नाही';

  @override
  String get itemManualIntro =>
      'फक्त नावाचा वापर करा. बाकी माहिती आता किंवा नंतर जोडा.';

  @override
  String get itemManualNameHint => 'उदाहरणार्थ, निळा सुती टी-शर्ट';

  @override
  String get itemManualEnterName => 'नाव प्रविष्ट करा';

  @override
  String get itemManualNotes => 'नोंदी';

  @override
  String get itemManualBrand => 'ब्रँड';

  @override
  String get itemManualSize => 'आकार';

  @override
  String get itemManualEnterNumber => 'क्रमांक प्रविष्ट करा';

  @override
  String get itemManualSavePiece => 'पीस जतन करा';

  @override
  String get itemManualSaving => 'जतन करत आहे';

  @override
  String get itemManualSavedTitle => 'जतन केले';

  @override
  String itemManualSavedBody(String name) {
    return '$name तुमच्या कपाटात आहे.';
  }

  @override
  String get itemManualNotSaved => 'जतन केले नाही';

  @override
  String get itemManualAddUseCase => 'वापराचे ठिकाण जोडा';

  @override
  String get itemManualAddUseCaseAction => 'वापराचे ठिकाण जोडा';

  @override
  String get itemPhotos => 'फोटो';

  @override
  String get itemAddPhotos => 'फोटो जोडा';

  @override
  String get itemNoPhotoYet =>
      'अद्याप फोटो नाही. तुम्ही फोटोशिवाय जतन करू शकता.';

  @override
  String get itemRemovePhoto => 'फोटो काढा';

  @override
  String get itemRemovePiece => 'पीस काढा';

  @override
  String get filterConditionLabel => 'स्थिती';

  @override
  String get photoshootStepPhotos => 'फोटो';

  @override
  String get photoshootStepSetup => 'सेटअप';

  @override
  String get photoshootStepCreating => 'तयार करत आहे';

  @override
  String get photoshootStepResults => 'निकाल';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'पायरी $current पैकी $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'एक फोटो अयशस्वी झाला. खाली पुन्हा प्रयत्न करा.';

  @override
  String photoshootManyFailed(int count) {
    return '$count फोटो अयशस्वी झाले. खाली प्रत्येकासाठी पुन्हा प्रयत्न करा.';
  }

  @override
  String get photoshootFormat => 'स्वरूप';

  @override
  String get photoshootHowMany => 'किती';

  @override
  String get photoshootYourPrompt => 'तुमची सूचना';

  @override
  String get photoshootPromptHint => 'रुपटॉपवर सोनेरी तास, लिनन शर्ट';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो तयार करा',
      one: '१ फोटो तयार करा',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'फोटो',
      one: 'फोटो',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'आम्ही आजची मर्यादा तपासू शकलो नाही.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan प्लॅन: आजचे $remaining पैकी $limit बाकी';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'मोफत';

  @override
  String get photoshootGallery => 'गॅलरी';

  @override
  String get photoshootUseCamera => 'कॅमेरा वापरा';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'फोटो $number काढा';
  }

  @override
  String get photoshootNoPhotosTitle => 'फोटो मिळाले नाहीत';

  @override
  String get photoshootNoPhotosBody =>
      'शूट प्रतिमांशिवाय पूर्ण झाले. पुन्हा प्रयत्न करा.';

  @override
  String get photoshootNewStyle => 'नवीन शैली';

  @override
  String get photoshootNewPhotos => 'नवीन फोटो';

  @override
  String photoshootOpenPhoto(int number) {
    return 'फोटो $number उघडा';
  }

  @override
  String get photoshootReportPhoto => 'फोटो रिपोर्ट करा';

  @override
  String get photoshootSaveToGallery => 'गॅलरीत सेव्ह करा';

  @override
  String get actionUpgrade => 'अपग्रेड करा';

  @override
  String get referralLimitTitle => 'तुम्ही आजचे फोटो वापरले आहेत';

  @override
  String get referralLimitBody =>
      'तुमचे मोफत फोटो उद्या पुन्हा मिळतील. मित्राला रेफर करा आणि दोघांनाही एक महिना Pro मोफत मिळेल.';

  @override
  String get referralLimitRefer => 'मित्राला रेफर करा';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'डेटिंग ॲप';

  @override
  String get photoshootUsePortfolio => 'पोर्टफोलिओ';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'सौंदर्यशास्त्र';

  @override
  String get photoshootUseCustom => 'तुमची स्वतःची सूचना';

  @override
  String get photoshootDescLinkedin => 'कामासाठी प्रोफेशनल हेडशॉट्स';

  @override
  String get photoshootDescDating => 'शांत, उबदार आणि नैसर्गिक';

  @override
  String get photoshootDescPortfolio => 'संपादकीय, हाय-फॅशन लूक';

  @override
  String get photoshootDescInstagram => 'तुमच्या फीडसाठी लाइफस्टाइल फोटो';

  @override
  String get photoshootDescAesthetic => 'मूडी, कलात्मक फ्रेम्स';

  @override
  String get photoshootDescCustom => 'तुम्हाला हवा असलेला लूक सांगा';

  @override
  String get aspectSquare => 'चौकोनी';

  @override
  String get aspectPortrait => 'पोर्ट्रेट';

  @override
  String get aspectLandscape => 'लँडस्केप';

  @override
  String get aspectTall => 'उभा';

  @override
  String get aspectWide => 'आडवा';

  @override
  String get tryOnAppBar => 'व्हर्च्युअल ट्राय-ऑन';

  @override
  String get tryOnYourPhoto => 'तुमचा फोटो';

  @override
  String get tryOnGarment => 'कपडा';

  @override
  String get tryOnUploadingPhoto => 'फोटो अपलोड होत आहे';

  @override
  String get tryOnAddPhotoPrompt => 'तुमचा पूर्ण शरीराचा फोटो जोडा';

  @override
  String get tryOnBodyPhotoHint => 'पूर्ण शरीराचा फोटो सर्वोत्तम काम करतो';

  @override
  String get tryOnAddPhoto => 'फोटो जोडा';

  @override
  String get tryOnChangePhoto => 'फोटो बदला';

  @override
  String get tryOnPhotoLoadFailed => 'आम्ही तुमचा फोटो लोड करू शकलो नाही.';

  @override
  String get tryOnChooseGarment => 'कपड्याचा फोटो निवडा';

  @override
  String get tryOnChooseOneGarment => 'एक कपड्याचा फोटो निवडा';

  @override
  String get tryOnGarmentHint => 'फ्लॅट ले किंवा हँगरवरील फोटो सर्वोत्तम असतो';

  @override
  String get tryOnChange => 'बदला';

  @override
  String get tryOnCamera => 'कॅमेरा';

  @override
  String get tryOnRemove => 'काढून टाका';

  @override
  String get tryOnLookTitle => 'लूक';

  @override
  String get tryOnStyle => 'स्टाईल';

  @override
  String get tryOnBackground => 'पार्श्वभूमी';

  @override
  String get tryOnPose => 'पोझ';

  @override
  String get tryOnDressingUp =>
      'तुम्हाला तयार करत आहोत. याला अर्धा मिनिट लागेल.';

  @override
  String get tryOnEmptyResult => 'तुमचे ट्राय-ऑन येथे दिसेल';

  @override
  String get tryOnReportImage => 'प्रतिमा रिपोर्ट करा';

  @override
  String get tryOnCreating => 'तयार होत आहे';

  @override
  String get tryOnTryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get tryOnCreate => 'ट्राय-ऑन तयार करा';

  @override
  String get tryOnBackgroundStudioWhite => 'स्टुडिओ व्हाईट';

  @override
  String get tryOnBackgroundStudioGrey => 'स्टुडिओ ग्रे';

  @override
  String get tryOnBackgroundUrban => 'अर्बन स्ट्रीट';

  @override
  String get tryOnBackgroundNature => 'निसर्ग';

  @override
  String get tryOnBackgroundMinimal => 'मिनिमल';

  @override
  String get tryOnPoseFront => 'समोर उभे';

  @override
  String get tryOnPoseSide => 'बाजूला उभे';

  @override
  String get tryOnPoseWalking => 'चालताना';

  @override
  String get dashboardGreetingMorning => 'शुभ सकाळ';

  @override
  String get dashboardGreetingAfternoon => 'शुभ दुपार';

  @override
  String get dashboardGreetingEvening => 'शुभ संध्याकाळ';

  @override
  String get dashboardWelcome => 'स्वागत आहे';

  @override
  String get dashboardOpenProfile => 'प्रोफाइल उघडा';

  @override
  String get dashboardRailToday => 'आज';

  @override
  String get dashboardRailRecently => 'अलीकडे';

  @override
  String get dashboardActivityEmpty => 'नवीन कपडे आणि आऊटफिट्स येथे दिसतील.';

  @override
  String get quickAddPiece => 'कपडा जोडा';

  @override
  String get quickAddPieceBody => 'फोटो काढा आणि टॅग करा';

  @override
  String get quickBuildOutfit => 'आऊटफिट बनवा';

  @override
  String get quickBuildOutfitBody => 'तुमचे कपडे मिक्स करा';

  @override
  String get quickForYou => 'तुमच्यासाठी';

  @override
  String get quickForYouBody => 'आजची निवड';

  @override
  String get quickPlanWeek => 'आठवड्याचे नियोजन';

  @override
  String get quickPlanWeekBody => 'तारखेनुसार आऊटफिट्स';

  @override
  String get referralBannerUrgent =>
      'मर्यादा संपत आली आहे? मित्राला आमंत्रित करा.';

  @override
  String get referralBannerTitle => 'एक महिना द्या, एक महिना मिळवा.';

  @override
  String get referralBannerBody =>
      'तुम्हाला आणि तुमच्या मित्राला प्रत्येकी एक महिन्याचे Pro मिळेल.';

  @override
  String get referralBannerDismiss => 'आठवड्याभरासाठी काढून टाका';

  @override
  String get referralBannerShare => 'आमंत्रण शेअर करा';

  @override
  String get referralBannerCopy => 'लिंक कॉपी करा';

  @override
  String get itemEditPieceTitle => 'तुकडा संपादित करा';

  @override
  String get itemEditDescriptionLabel => 'वर्णन';

  @override
  String get itemEditNotSaved => 'सेव्ह केलेले नाही';

  @override
  String get itemEditSavedTitle => 'सेव्ह केले';

  @override
  String get itemEditSavedBody => 'तुमचे बदल सेव्ह केले आहेत.';

  @override
  String get itemEditSavedStalePhotos => 'सेव्ह केले — फोटो जुने असू शकतात';

  @override
  String get itemEditRemovePieceHint => 'हा तुकडा आयटम पेजवरून काढून टाका.';

  @override
  String get itemEditNoPhotos =>
      'अजून फोटो नाहीत. गॅलरी किंवा कॅमेऱ्यातून एक जोडा.';

  @override
  String get itemEditKeepPhoto => 'फोटो ठेवा';

  @override
  String get itemEditRemoved => 'काढून टाकले';

  @override
  String get itemEditAddUseCaseAction => 'जोडा';

  @override
  String get statsNoStatsTitle => 'अजून आकडेवारी नाही';

  @override
  String get statsNoStatsBody =>
      'काही तुकडे जोडा आणि तुमचे कपाट मिश्रण येथे दिसेल.';

  @override
  String get statsByCategory => 'श्रेणीनुसार';

  @override
  String get statsTotalValue => 'एकूण मूल्य';

  @override
  String get statsMostWorn => 'सर्वात जास्त वापरलेले';

  @override
  String get statsLeastWorn => 'वापराच्या प्रतीक्षेत';

  @override
  String get statsUnnamedPiece => 'नाव नसलेला तुकडा';

  @override
  String get jobsTitle => 'स्कॅन';

  @override
  String get jobsEmptyTitle => 'अजून स्कॅन नाहीत';

  @override
  String get jobsEmptyBody =>
      'एखाद्या तुकड्याचा फोटो काढा आणि बॅकग्राउंडला पाठवा — ते येथे काम करत राहील.';

  @override
  String get jobsNotCancelled => 'रद्द केलेले नाही';

  @override
  String get jobsResume => 'पुन्हा सुरू करा';

  @override
  String get jobsReview => 'पुनरावलोकन';

  @override
  String get jobsStop => 'थांबवा';

  @override
  String get jobsDismiss => 'काढून टाका';

  @override
  String get reportTitle => 'कंटेंट रिपोर्ट करा';

  @override
  String reportIntro(String contentType) {
    return 'या $contentType मध्ये काय चूक आहे ते आम्हाला सांगा. आमची टीम प्रत्येक रिपोर्ट तपासते.';
  }

  @override
  String get reportReasonInappropriate => 'अयोग्य किंवा आक्षेपार्ह';

  @override
  String get reportReasonNudity => 'नग्नता किंवा लैंगिक आशय';

  @override
  String get reportReasonHarassment => 'छळ किंवा गैरवर्तन';

  @override
  String get reportReasonImpersonation => 'दुसऱ्याचे रूप धारण करणे';

  @override
  String get reportReasonOther => 'इतर';

  @override
  String get reportDetailsLabel => 'अधिक तपशील (ऐच्छिक)';

  @override
  String get reportSubmit => 'रिपोर्ट सबमिट करा';

  @override
  String get reportSubmittedTitle => 'रिपोर्ट सबमिट केला';

  @override
  String get reportSubmittedBody => 'धन्यवाद. आमची टीम या आशयाची तपासणी करेल.';

  @override
  String get reportFailedTitle => 'रिपोर्ट पाठवता आला नाही';

  @override
  String get reportFailedBody => 'कृपया पुन्हा प्रयत्न करा.';

  @override
  String get reportContentTryOnImage => 'AI ट्राय-ऑन इमेज';

  @override
  String get reportContentSharedOutfit => 'शेअर केलेला आऊटफिट';

  @override
  String get reportContentPhotoshootImage => 'AI फोटोशूट इमेज';

  @override
  String get sharedOutfitTitle => 'शेअर केलेला पोशाख';

  @override
  String get sharedOutfitHideTooltip => 'हा पोशाख लपवा';

  @override
  String get sharedOutfitReportTooltip => 'या पोशाखाची तक्रार करा';

  @override
  String get sharedOutfitHideTitle => 'हा पोशाख लपवायचा?';

  @override
  String get sharedOutfitHideBody =>
      'हा या डिव्हाइसवर लपलेला राहील. तुम्ही याची तक्रार देखील करू शकता जेणेकरून आमची टीम ते तपासेल आणि काढून टाकेल.';

  @override
  String get sharedOutfitHideAction => 'लपवा';

  @override
  String get sharedOutfitHiddenInfo =>
      'हा पोशाख या डिव्हाइसवर पुन्हा दिसणार नाही.';

  @override
  String get sharedOutfitHiddenToast => 'पोशाख लपवला';

  @override
  String get sharedOutfitMissingTitle => 'हा पोशाख आता उपलब्ध नाही';

  @override
  String get sharedOutfitMissingBody =>
      'तो कदाचित काढून टाकला असावा किंवा लिंक चुकीची असू शकते.';

  @override
  String get sharedOutfitHiddenStateTitle => 'तुम्ही हा पोशाख लपवला आहे';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'जर तो आक्षेपार्ह असेल, तर प्रायव्हसी आणि अटींमधून तक्रार करा किंवा $email वर ईमेल करा.';
  }

  @override
  String get sharedOutfitCtaTitle => 'हा लूक आवडला?';

  @override
  String get sharedOutfitCtaBody =>
      'तुमच्या कपाटातील कपड्यांपासून असेच पोशाख तयार करा.';

  @override
  String get sharedOutfitCtaButton => 'FitCheck AI मिळवा';

  @override
  String get errorTitle => 'त्रुटी';

  @override
  String get errorUnknown => 'अप्रतीक्षित त्रुटी झाली';

  @override
  String get errorNoConnection =>
      'इंटरनेट कनेक्शन नाही. कृपया तुमचे नेटवर्क तपासा.';

  @override
  String get errorTimeout => 'निवेदन मुद्दाम झाले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorServerError =>
      'आमच्याकडुन काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorBadGateway =>
      'आमचा सर्व्हर लहान वेळासाठी उपलब्ध नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorServiceUnavailable =>
      'सेवा तात्पुरती उपलब्ध नाही. कृपया लगेच पुन्हा प्रयत्न करा.';

  @override
  String get errorInternalError =>
      'काहीतरी चूक झाली. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorUnauthorized => 'जारी ठेवण्यासाठी कृपया साइन इन करा.';

  @override
  String get errorForbidden => 'तुम्हाला त्याचे प्रवेशाधिकार नाहीत.';

  @override
  String get errorSessionExpired =>
      'तुमची सत्र संपून गेली. कृपया पुन्हा साइन इन करा.';

  @override
  String get errorInvalidCredentials => 'सोदर किंवा पालवर्ड योग्य नाही.';

  @override
  String get errorTokenRefreshFailed =>
      'आम्ही तुमचे सत्र नवीन करू शकलो नाही. कृपया पुन्हा साइन इन करा.';

  @override
  String get errorRequestCancelled => 'निवेदन रद्द केले.';

  @override
  String get errorInvalidFormat => 'तो फाइल प्रकार समर्थित नाही.';

  @override
  String get errorFileTooLarge => 'तही फाईल खूप मोठे आहे.';

  @override
  String get errorUploadFailed =>
      'अपलोड अयशस्वी झाले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get errorCacheCorrupted =>
      'जतन केलेले डेटा नुकसान झाले आणि पुनर्स्थापित केले गेले.';

  @override
  String get errorCacheNotFound => 'अजून काहीही जतन केले नाही.';

  @override
  String get errorUserNotFound => 'आम्हाला त्या खाती सापडली नाही.';

  @override
  String get errorItemNotFound => 'तो वस्तू आता मौजूद नाही.';

  @override
  String get errorOutfitNotFound => 'तो सजावट आता मौजूद नाही.';

  @override
  String get rewardsTitle => 'बक्ष्ये';

  @override
  String get rewardsNoAchievementsTitle => 'अजून साध्य नाहीत';

  @override
  String get rewardsNoAchievementsBody =>
      'पहिले साध्य मिळण्यासाठी ड्रप जोडा आणि सजावट योजना कर.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'अजून बोर्डवर कोणीही नाही';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'बिंदू मिळवण्यासाठी सजावट योजना कर आणि येथे दिसून येत हो.';

  @override
  String get legalViewPrivacyPolicy => 'गोपनीयता धोरण पहा';

  @override
  String get aiConsentAgree => 'मी मान्य करतो आणि पुढे जातो';

  @override
  String get aiConsentNotNow => 'आता नाही';

  @override
  String get imageViewerCloseTooltip => 'इमेज व्यूअर बंद करा';

  @override
  String get updateReadyTitle => 'अपडेट तयार आहे';

  @override
  String get updateReadyBody =>
      'नवीन सुधारणा लागू करण्यासाठी FitCheck AI पुन्हा सुरू करा.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI ला तुमच्या आउटफिट आणि वॉर्डरोब वस्तूंचे फोटो घेण्यासाठी कॅमेराचा प्रवेश हवा आहे.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI ला तुमच्या आउटफिट आणि वॉर्डरोब वस्तूंच्या इमेज निवडण्यासाठी फोटो लायब्ररीचा प्रवेश हवा आहे.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI ला तुमच्या AI-निर्मित आउटफिट फोटो तुमच्या फोटो लायब्ररीमध्ये साठवण्याची आवश्यकता आहे.';

  @override
  String get wardrobeSomePhotosSkipped => 'काही फोटो वरून सोडले';

  @override
  String get wardrobePhotosNotAdded => 'फोटो जुळवले नाहीत';

  @override
  String get wardrobePhotoNotAdded => 'फोटो जुळवला नाही';

  @override
  String get wardrobeNotStartedTitle => 'सुरू नाही';

  @override
  String get wardrobeNoRoomTitle => 'जागा नाही';

  @override
  String get wardrobeAddPhotosSemantic => 'फोटो जोडा';

  @override
  String get batchAddTileLabel => 'जोडा';

  @override
  String get batchProfileLinkLabel => 'प्रोफाइल लिंक';

  @override
  String get wardrobeImportFromProfileTitle => 'प्रोफाइलवरून इम्पोर्ट करा';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'काही फोटो जोडा';

  @override
  String get wardrobeClearAction => 'कधीकाळाकडे साफ करा';

  @override
  String get wardrobeRefreshTooltip => 'रिव्ह्रेस करा';

  @override
  String get batchNoPhotosYetTitle => 'अजून फोटो नाहीत';

  @override
  String get batchChoosePhotosAction => 'फोटो निवडा';

  @override
  String get batchWeFindEachPieceBody =>
      'आम्ही प्रत्येक कपडा शोधतो आणि त्याचा स्टुडिओ फोटो तयार करतो.';

  @override
  String get batchPreparingPhotosSemantic => 'फोटो तयार होत आहेत';

  @override
  String get batchPhotosProcessedSemantic => 'फोटो प्रक्रिया झाले';

  @override
  String get batchPasteProfileLinkTitle => 'प्रोफाइल लिंक पेस्ट करा';

  @override
  String get batchPasteProfileLinkBody =>
      'सार्वजनिक Instagram किंवा Facebook प्रोफाइल. आम्hi त्याचे फोटो स्कॅन करतो आणि तुम्hi कोणते वस्तू तुमच्या वॉर्डरोबमध्ये घ्यायच्या निवडता.';

  @override
  String get batchClearLinkTooltip => 'लिंक साफ करा';

  @override
  String get batchStartingButton => 'सुरू होत आहे';

  @override
  String get batchStartImportAction => 'इम्पोर्ट सुरू करा';

  @override
  String get batchReviewEveryPhotoTitle => 'तुम्hi प्रत्येक फोटो तपासता';

  @override
  String get batchReviewEveryPhotoBody =>
      'तुम्hi मंजूर केल्याशिवाय काहीही जोडले जात नाही.';

  @override
  String get batchPrivateProfilesTitle => 'निवासी प्रोफाइल';

  @override
  String get batchPrivateProfilesBody =>
      'तुमचा खाता जोडा. Instagram शिवाय वापरकर्तानाव आणि पासवर्डही घेते.';

  @override
  String get batchUseAnotherLinkAction => 'दुसरा लिंक वापरा';

  @override
  String get batchSignInNeededTitle => 'साइन-इन आवश्यक आहे';

  @override
  String get batchEnterYourCodeTitle => 'तुमचा कोड टाका';

  @override
  String get batchUseUsernamePasswordAction => 'वापरकर्तानाव आणि पासवर्ड वापरा';

  @override
  String get batchAlreadyConnectedAction => 'मी ब्राउझरमध्ये जोडले आहे';

  @override
  String get batchEnterCodeAction => 'कोड टाका';

  @override
  String get batchTryAnotherWayAction => 'दुसरी मार्ग प्रयत्न करा';

  @override
  String get batchLiveStatus => 'समजा';

  @override
  String get batchReconnectingStatus => 'पुनरजोडवत आहे';

  @override
  String get batchSignInToInstagramTitle => 'Instagram कडे साइन इन करा';

  @override
  String get batchUsernameLabel => 'वापरकर्तानाव';

  @override
  String get batchCodeIfTwoStepLabel =>
      'कोड, जो तुम्ही द्वि-पायरी साइन-इन वापरता';

  @override
  String get batchAuthenticatorCodeBody =>
      'तुमच्या ऑथेंटिकेटर अप्लिकेशनमधून ६-अंकी कोड वापरा. कोड जलद बदलतात.';

  @override
  String get batchVerifyAction => 'पाठव';

  @override
  String get batchFindingPhotosTitle => 'फोटो शोधत आहे';

  @override
  String get batchImportPausedTitle => 'आयात सुरू ठेवली';

  @override
  String get batchProcessingPhotosTitle => 'फोटो प्रक्रिया करते आहे';

  @override
  String get batchWaitingNextPhoto => 'पुढील फोटोची वाट पाहत आहे';

  @override
  String get batchCancelImportAction => 'आयात रद्द करा';

  @override
  String get batchNoPiecesInPhotoBody => 'या फोटोमध्ये काहीही सापडले नाही.';

  @override
  String get batchEditPieceColoursLabel => 'रंग, कमांनी विभाजित';

  @override
  String get batchAddToClosetAction => 'लॉकेटमध्ये जोडा';

  @override
  String get batchSkipPhotoAction => 'हा फोटो वगळा';

  @override
  String get batchImportCompleteTitle => 'आयात पूर्ण झाली';

  @override
  String get batchImportFailedTitle => 'आयात अयशस्वी';

  @override
  String get batchImportCancelledTitle => 'आयात रद्द';

  @override
  String get batchImportErrorBody => 'आयात करताना काहीतरी चूक झाली.';

  @override
  String get batchNothingMoreImportedBody =>
      'या प्रोफाइलमधून पुढे काहीही आयात होत नाही.';

  @override
  String get batchViewClosetAction => 'कलॉलेट पहा';

  @override
  String get batchStartOverAction => 'पुन्हा सुरू करा';

  @override
  String get wardrobeAddPieceTitle => 'वस्तू जोडा';

  @override
  String get wardrobeAddDetailsTitle => 'तपशील जोडा';

  @override
  String get wardrobeScanningTitle => 'स्कॅनिंग';

  @override
  String get batchReviewPiecesTitle => 'वस्तू तपासा';

  @override
  String get wardrobeGalleryAction => 'गॅलरी';

  @override
  String get wardrobeCameraAction => 'कॅमेरा';

  @override
  String get wardrobeNewBadge => 'नवीन';

  @override
  String get wardrobeRemovePhotoTooltip => 'फोटो काढा';

  @override
  String get batchRunInBackgroundTooltip => 'पार्श्वभूमीवर चालू ठेवा';

  @override
  String get batchStepOneOfTwo => 'पायरी 1, एकूण 2 पैकी';

  @override
  String get batchStepTwoOfTwo => 'पायरी 2, एकूण 2 पैकी';

  @override
  String get batchUploadingPhotosTitle => 'फोटो अपलोड होत आहेत';

  @override
  String get batchFindingPiecesTitle => 'वस्तू शोधल्या जात आहेत';

  @override
  String get batchMakingStudioPhotosTitle => 'स्टुडिओ फोटो तयार होत आहेत';

  @override
  String get batchStoppedLabel => 'थांबवले';

  @override
  String get batchFindingPiecesStoppedTitle => 'वस्तू शोधणे थांबले';

  @override
  String get batchCancelledLabel => 'रद्द';

  @override
  String get batchAllDoneTitle => 'सर्व पूर्ण';

  @override
  String get batchOpeningPiecesBody => 'तुमच्या वस्तू उघडल्या जात आहेत';

  @override
  String get batchNothingSavedBody => 'काहीही जतन झाले नाही.';

  @override
  String get batchFindingPiecesFailedBody => 'वस्तू शोधण्यास अपयशी.';

  @override
  String get batchFindingPiecesStoppedEarlyBody => 'वस्तू शोधणे लवकर थांबवले.';

  @override
  String get batchStopFindingPiecesTitle => 'वस्तू शोधणे थांबवायचे आहे?';

  @override
  String get batchStopFindingPiecesBody =>
      'स्कॅन थांबतो आणि काहीही जतन केले जात नाही. आधी सापडलेल्या वस्तू तुमच्या कार्यक्रमात राहतात, जे तुम्ही टाकून देत नाहीत. (Note: This text is quite long, here is a tighter version):\nस्कॅन थांबतो आणि काहीही जतन होत नाही. सापडलेल्या वस्तू तुमच्या इतिहासात राहतात.';

  @override
  String get batchKeepGoingAction => 'पुढे चालू ठेवा';

  @override
  String get batchTryAgainAction => 'पुन्हा प्रयत्न करा';

  @override
  String get batchBackToPhotosAction => 'फोटोंकडे परत';

  @override
  String get batchSkipAllAction => 'सर्व वगळा';

  @override
  String get batchIncludeAllAction => 'सर्व समाविष्ट करा';

  @override
  String get batchNoPiecesFoundTitle => 'कोणतेही वस्तू सापडल्या नाहीत';

  @override
  String get batchNoPiecesFoundBody => 'या फोटोमध्ये कपडे सापडले नाहीत.';

  @override
  String get batchChooseOtherPhotosAction => 'दुसरे फोटो निवडा';

  @override
  String get batchUseCaseHelper =>
      'तुम्ही जतन करताना प्रत्येक वस्तूला जोडले जाते.';

  @override
  String get batchDiscardPiecesTitle => 'ही वस्तू टाकून द्यावी?';

  @override
  String get batchDiscardPiecesBody => 'या बॅचमधून काहीही जतन केलेले नाही.';

  @override
  String get batchKeepAction => 'ठेवा';

  @override
  String get batchDiscardAction => 'टाकून द्या';

  @override
  String get batchRemovePieceTitle => 'ही वस्तू काढायची?';

  @override
  String get batchRemovePieceBody =>
      'ती तुमच्या क्लोसेटमध्ये जतन केली गेलेली नाही.';

  @override
  String get batchRemoveAction => 'काढा';

  @override
  String get batchChoosePiecesToSave => 'जतन करायच्या वस्तू निवडा';

  @override
  String get batchDiscardAllAction => 'सर्व टाकून द्या';

  @override
  String get batchNothingSavedRetryBody =>
      'काहीही जतन केले गेले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get batchNotSavedTitle => 'जतन केले नाही';

  @override
  String get batchSavingLabel => 'जतन होत आहे';

  @override
  String get batchSendToBackgroundAction => 'बॅकग्राउंडमध्ये पाठवा';

  @override
  String get batchStillWorkingMessage =>
      'अजून काम सुरू आहे. तुमच्या वस्तू तयार झाल्यावर आम्ही तुम्हाला कळवू.';

  @override
  String get batchRunningInBackgroundTitle => 'बॅकग्राउंडमध्ये सुरू आहे';

  @override
  String get batchStudioPhotosStoppedBody =>
      'स्टुडिओ फोटो लवकरच थांबले. तुम्ही या वस्तू जतन करू शकता.';

  @override
  String get batchTapPieceToSkip => 'सकाळी करण्यासाठी एखाद्या वस्तूवर टॅप करा.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'स्टुडिओ फोटो आणखी येत आहेत. तुम्ही जाऊ शकता — आम्ही तुम्हाला कळवू.';

  @override
  String get batchLeaveAction => 'जा';

  @override
  String get batchPeopleInPhotosTitle => 'फोटोमध्ये लोक';

  @override
  String get batchIncludeAction => 'समाविष्ट करा';

  @override
  String get batchSkipAction => 'सकाळी जा';

  @override
  String get batchYourPhotoIsUsedLabel => 'तुमचा फोटो वापरला जातो';

  @override
  String get batchMakingStudioPhotoLabel => 'स्टुडिओ फोटो बनवत आहे';

  @override
  String get batchNoStudioPhotoBody =>
      'स्टुडिओ फोटो नाही. तुमचा फोटो वापरला जातो.';

  @override
  String get batchEnterDetailsYourselfAction => 'तपशील स्वतः भरा';

  @override
  String get batchChooseAnotherPhotoAction => 'दुसरी फोटो निवडा';

  @override
  String get batchConnectionLostTitle => 'कनेक्शन गमावले';

  @override
  String get batchConnectionLostBody => 'कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get batchDailyLimitTitle => 'दैनिक मर्यादा गाठली';

  @override
  String get batchDailyLimitBodyPaywall =>
      'अधिक स्कॅन्ससाठी Pro वर अपग्रेड करा किंवा तपशील स्वतः भरा.';

  @override
  String get batchDailyLimitBodyFree =>
      'तुमचे स्कॅन्स उद्या रीसेट होतात. आता तुम्ही तपशील स्वतः भरणे शकता.';

  @override
  String get batchSeePlansAction => 'प्लॅन्स पाहा';

  @override
  String get batchAiBusyTitle => 'आमची AI व्यस्त आहे';

  @override
  String get batchAiBusyBody =>
      'हे आमच्याकडून येत आहे. काही मिनिटांत पुन्हा प्रयत्न करा.';

  @override
  String get batchNoPiecesBody => 'स्पष्ट फोटो वापरा किंवा तपशील स्वतः भरा.';

  @override
  String get batchScanningUnavailableTitle => 'स्कॅनिंग उपलब्ध नाही';

  @override
  String get batchScanningUnavailableBody => 'सध्या तपशील स्वतः भरा.';

  @override
  String get batchScanDidNotFinishTitle => 'स्कॅन पूर्ण झाले नाही';

  @override
  String get batchTryAgainBody => 'पुन्हा प्रयत्न करा.';

  @override
  String get billingTitle => 'सबस्क्रिप्शन';

  @override
  String get billingUpgradeHeading => 'तुमचा प्लॅन अपग्रेड करा';

  @override
  String get billingUpgradeOnPlusBody => 'एकासारखे फिचर्स, जास्त मर्यादा.';

  @override
  String get billingUpgradeBody =>
      'Plus आणि Pro मध्ये समान फिचर्स आहेत. तुम्हाला आवश्यक असलेल्या मर्यादा निवडा.';

  @override
  String get billingWebUnavailableBody =>
      'ऑनलाइन अपग्रेड अद्याप उपलब्ध नाहीत. प्रोमो किंवा रेफरल कोड आजही Plus किंवा Pro उघडू शकतो. खाली मित्रांना निमंत्रण द्या आणि मोफत महिने मिळवा.';

  @override
  String get billingPlansStale =>
      'नवीन प्लॅन्स लोड करता आले नाहीत. किंमे जुनere असू शकतात.';

  @override
  String get billingMonthly => 'मासिक';

  @override
  String get billingYearly => 'वार्षिक';

  @override
  String get billingCurrentPlan => 'सध्याचा प्लॅन';

  @override
  String get billingActive => 'सक्रिय';

  @override
  String get billingThisMonth => 'या महिन्यात';

  @override
  String get billingItemExtractions => 'आयटम एक्सट्रॅक्शन';

  @override
  String get billingOutfitVisualizations => 'आउटफिट विज्युअलायझेशन';

  @override
  String get billingNearLimitUpgrade =>
      'तुम्ही या महिन्याच्या मर्यादेच्या जवळ आहात. अधिकसाठी अपग्रेड करा.';

  @override
  String get billingNearLimitResets =>
      'तुम्ही या महिन्याच्या मर्यादेच्या जवळ आहात. हा रीसेट पुढच्या महिन्याच्या सुरुवातीला होतो.';

  @override
  String get billingStoreUnavailable =>
      'अपग्रेड आजही स्टोअरमध्ये उपलब्ध नाहीत. लवकरच परत आहात.';

  @override
  String get billingManageHeading => 'तुमचे प्लॅन व्यवस्थाव्या करा';

  @override
  String get billingCancelPlan => 'सब्सक्रिप्शन रद्द करा';

  @override
  String get billingCancelKeepsAccess =>
      'या बिलिंग कीद्वारेपर्यंत तुम्हाला प्रवेश राहणार आहे.';

  @override
  String get billingCancelConfirmTitle =>
      'तुमचे सब्सक्रिप्शन रद्द करायचे आहे का?';

  @override
  String get billingKeepPlan => 'प्लॅन राखा';

  @override
  String get billingCancelPlanAction => 'प्लॅन रद्द करा';

  @override
  String get billingBilledMonthly => 'मासिक बिलिंग';

  @override
  String get billingBilledYearly => 'वार्षिक बिलिंग';

  @override
  String get billingVirtualTryOn => 'व्हर्च्युअल ट्राय-ऑन';

  @override
  String get billingPrioritySupport => 'प्रायोरिटी सपोर्ट';

  @override
  String get billingDisclosureProRenewing =>
      'Pro स्वयं-नूकरणीय सब्सक्रिप्शन आहे';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus आणि Pro स्वयं-नूकरणीय सब्सक्रिप्शन्स आहेत';

  @override
  String get billingDisclosureAppleBilling =>
      'खरेदीची पुष्टी होताना तुमच्या Apple ID वर भुगतान कलेकट केले जाते.';

  @override
  String get billingDisclosureGoogleBilling =>
      'खरेदीची पुष्टी होताना तुमच्या Google Play खात्यावर भुगतान कलेकट केले जाते.';

  @override
  String get billingDisclosureRenewalTerms =>
      'तुमचे सब्सक्रिप्शन स्वयंने त्याच कितीतीसाठी त्याच किमतीवर नूकरण होतो, जेव्हा तुम्ही सध्याच्या कीद्वारे संपण्यापूर्वी किमान २४ तास आधी स्वयं-नूकरण बंद करत नाही तो पर्यंत.';

  @override
  String get billingDisclosureAppleManage =>
      'कितीही वेळ सेटिंग्समध्ये तुमचा Apple ID › सब्सक्रिप्शन्स मध्ये व्यवस्थाव्या किंवा रद्द करा.';

  @override
  String get billingDisclosureGoogleManage =>
      'कितीही वेळ Google Play › भुगतान आणि सब्सक्रिप्शन्स मध्ये व्यवस्थाव्या किंवा रद्द करा.';

  @override
  String get billingReferFriend => 'मित्रांना मोजा';

  @override
  String get billingHowItWorks => 'हे कसे काम करते';

  @override
  String get billingHowShareTitle => 'तुमची लिंक शेअर करा';

  @override
  String get billingHowShareBody => 'तिला मित्राला पाठवा.';

  @override
  String get billingHowSignUpTitle => 'तय जॉइन करतात';

  @override
  String get billingHowSignUpBody => 'तुमच्या मित्र लिंकवरून जॉइन करतात.';

  @override
  String get billingHowBothTitle => 'दोघांनाही Pro मिळतो';

  @override
  String get billingHowBothBody => 'प्रत्येकाला Pro चा एक महिना मोफत मिळतो.';

  @override
  String get billingYourReferrals => 'तुमचे रेफरल';

  @override
  String get billingInvited => 'निमंत्रित';

  @override
  String get billingJoined => 'जोडले';

  @override
  String get billingMonthsEarned => 'कमावलेले महिने';

  @override
  String get billingInviteFriend => 'मित्राचे आमंत्रित';

  @override
  String get billingInviteBody =>
      'तुम्हाला आणि तुमच्या मित्राला प्रत्येकी Pro चा एक महिना मिळतो.';

  @override
  String get billingYourCode => 'तुमचा कोड';

  @override
  String get billingCopyLink => 'लिंक कॉपी करा';

  @override
  String get billingShareInvite => 'आमंत्रण सामायिक करा';

  @override
  String get giftUnavailable => 'या आवृत्तीत वस्तुदानी आमंत्रणे उपलब्ध नाहीत.';

  @override
  String get giftPageTitle => 'FitCheck Pro वस्तुदानी';

  @override
  String get giftNoAllowances => 'सध्या फुकट वस्तुदानी आमंत्रणे उपलब्ध नाहीत.';

  @override
  String get giftFormTitle => 'फुकट आमंत्रण पाठवा';

  @override
  String get giftFormBody =>
      'तुमचा ग्राहक ही पुष्टीकृत ई-मेलद्वारे उपहार घेऊ शकतो. आपण ई-मेल पाठवत नाही.';

  @override
  String get giftFieldFrom => 'पाठवणारा';

  @override
  String get giftFieldRecipientName => 'प्राप्तकर्त्याचे नाव';

  @override
  String get giftFieldRecipientEmail => 'प्राप्तकर्त्याचा ईमेल';

  @override
  String get giftFieldOccasion => 'संधी (ऐच्छिक)';

  @override
  String get giftNoOccasion => 'कोणतीही संधी नाही';

  @override
  String get giftOccasionBirthday => 'जन्मदिवस';

  @override
  String get giftOccasionAnniversary => 'वर्षदिन';

  @override
  String get giftOccasionOther => 'इतर';

  @override
  String get giftFieldCardGreeting => 'कार्ड शुभेच्छा';

  @override
  String get giftFieldCardGreetingHelper => 'ही शुभेच्छा कार्डवर तसेच दिसेल.';

  @override
  String get giftFieldPrivateNote => 'खाजगी टिप (ऐच्छिक)';

  @override
  String get giftCreateAction => 'फुकट उपहार तयार करा';

  @override
  String get giftClaimedTitle => 'उपहार स्वीकारले';

  @override
  String get giftClaimedActive => 'तुमचा FitCheck Pro उपहार सक्रिय आहे.';

  @override
  String get giftClaimedQueued =>
      'तुमचा FitCheck Pro उपहार तुमच्या सध्याच्या नोंदीनंतर सुरू होतो.';

  @override
  String get giftLinkCopied => 'उपहार लिंक क्लिपबोर्डवर कॉपी केली.';

  @override
  String get giftErrorName => 'नाव नोंदवा.';

  @override
  String get giftErrorEmail => 'योग्य ई-मेल पत्ता नोंदवा.';

  @override
  String get giftErrorGreeting => 'कार्ड शुभेच्छा नोंदवा.';

  @override
  String get giftErrorGreetingLength =>
      'किमान ८० अक्षरांपेक्षा जास्त वापरू नका.';

  @override
  String get giftClaimAction => 'भेटी मिळवा';

  @override
  String get giftCardPreview => 'कार्ड पाहिल';

  @override
  String get giftGiftForYou => 'तुमच्यासाठी भेटी';

  @override
  String get giftGiftWaiting => 'तुम्हाला भेट मिळवण्यासाठी वाटली जात आहे';

  @override
  String get giftOpenBody => 'विश्वासार्ह ईमेलसह भेटी मिळवण्यासाठी उघडा.';

  @override
  String get giftOpenGifts => 'भेटी उघडा';

  @override
  String get giftSendInvitation => 'निमंत्रण पाठवा';

  @override
  String get settingsAiProviderSection => 'प्रदाता';

  @override
  String get settingsAiCustom => 'निर्दिष्ट';

  @override
  String get settingsAiUrlHelper =>
      'सर्व्हर पोहोचू शकते असे सार्वजनिक्स URL वापरा. लोकलहोस्ट आमच्या सर्व्हरवरून काम करत नाही.';

  @override
  String get settingsAiConnectionSection => 'जोडणी';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API की';

  @override
  String get settingsAiApiKeySaved => 'संग्रहीत. जपण्यासाठी रिकामे सोडा.';

  @override
  String get settingsAiChatModel => 'चॅट मॉडेल';

  @override
  String get settingsAiVisionModel => 'दृश्य मॉडेल (ऐच्छिक)';

  @override
  String get settingsAiImageModel => 'छायाचित्र मॉडेल (ऐच्छिक)';

  @override
  String get settingsAiImageModelNote =>
      'छायाचित्र निर्मितीसाठी response_modalities सह ओपनएआई समानता चॅट पूराण आवश्यक आहे.';

  @override
  String get settingsAiTestConnection => 'जोडणी चाचवी';

  @override
  String get calendarTitle => 'कॅलंडर';

  @override
  String get calendarGoToToday => 'आजकडे जा';

  @override
  String get calendarConnectTooltip => 'कॅलंडर जोडा';

  @override
  String get calendarAddEvent => 'वेळ घाला';

  @override
  String get calendarEmptyTitle => 'काहीही नियोजित नाही';

  @override
  String get calendarEmptyBody => 'वेळ घाला आणि काय घालायचे ते नियोजन करा.';

  @override
  String get calendarPreviousMonth => 'मागील महिना';

  @override
  String get calendarNextMonth => 'पुढील महिना';

  @override
  String get calendarAllDay => 'सर्व दिवस';

  @override
  String get calendarOutfitLinked => 'मुबलक जोडले';

  @override
  String get calendarEventOptions => 'वेळापर्यंत पर्याय';

  @override
  String get calendarDeleteTitle => 'हा evenट डिलीट करायचा?';

  @override
  String get calendarChangeOutfit => 'आउटफिट बदला';

  @override
  String get calendarLinkOutfit => 'आउटफिट जोडा';

  @override
  String get calendarRemoveOutfit => 'आउटफिट काढा';

  @override
  String get calendarNewEvent => 'नवीन evenट';

  @override
  String get calendarEditEvent => 'evenट संपादित करा';

  @override
  String get calendarTitleLabel => 'शीर्षक';

  @override
  String get calendarTitleRequired => 'शीर्षक जोडा';

  @override
  String get calendarEndBeforeStart => 'सुरुवातीच्या वेळेनंतर संपवा';

  @override
  String get calendarStarts => 'सुरुवात';

  @override
  String get calendarEnds => 'समाप्ती';

  @override
  String get calendarPlaceOptional => 'ठिकाण (ऐच्छिक)';

  @override
  String get calendarNotesOptional => 'टीप (ऐच्छिक)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'आउटफिट तयार करा, मग या evenटशी जोडा.';

  @override
  String get calendarBuildOutfit => 'आउटफिट तयार करा';

  @override
  String get calendarConnectionsTitle => 'कॅलेंडर्स';

  @override
  String get calendarConnectionsBody =>
      'येथे जोडलेले evenट फक्त FitCheck मध्ये ठेवले जातात.';

  @override
  String get calendarDisconnect => 'डिस्कनेक्ट करा';

  @override
  String get calendarNotAvailable => 'अभी उपलब्ध नाही';

  @override
  String get profileSectionExplore => 'ओळखा';

  @override
  String get profileNavTryOn => 'पुर्णवण';

  @override
  String get profileNavRewards => 'बक्षीस';

  @override
  String get profileSupport => 'सहाय्य';

  @override
  String get profileHelp => 'मदत';

  @override
  String get profileAbout => 'बद्दल';

  @override
  String get profileAboutBody => 'तुमची अलमारी, आउटफिट आणि योजना एका ठिकाणी.';

  @override
  String get profileSignOutTitle => 'साइन आऊट करायचे?';

  @override
  String get profileSignOutBody => 'तुम्ही कधीही पुन्हा साइन इन करू शकता.';

  @override
  String get profileEditTitle => 'प्रोफाइल संपादित करा';

  @override
  String get profileYourProfile => 'तुमचे प्रोफाइल';

  @override
  String get profileBodyProfiles => 'शारीरिक प्रोफाइल्स';

  @override
  String get profileBodyEmptyTitle => 'अजून शारीरिक प्रोफाइल नाही';

  @override
  String get profileBodyEmptyBody =>
      'पूर्णतः बसण्यासाठी तुमची उंची आणि रचना जोडा.';

  @override
  String get profileBodyAdd => 'प्रोफाइल जोडा';

  @override
  String get profileBodyDefaultNote =>
      'तुमची खालावली प्रोफाइल बस आणि ट्राय-ऑनसाठी वापरली जाते.';

  @override
  String get profileBodyDefaultBadge => 'खालावली';

  @override
  String get profileBodyMakeDefault => 'खालावली करा';

  @override
  String get profileBodyDeleteBody => 'हे परत करता येत नाही.';

  @override
  String get profileBodyRequired => 'आवश्यक';

  @override
  String get profileBodyCheckNumber => 'हा क्रम नंबर तपासा';

  @override
  String get profileBodyNew => 'नवीन शारीरिक प्रोफाइल';

  @override
  String get profileBodyNameHint => 'उदा. मी';

  @override
  String get profileBodyHeight => 'उंची';

  @override
  String get profileBodyWeight => 'वजन';

  @override
  String get profileBodyBuild => 'शारीरिक रचना';

  @override
  String get profileBodySkinTone => 'त्वचेचा टोन';

  @override
  String get profileBirthDateNeededBody =>
      'जन्म वेळेसोबत गेंदा जन्म तारीख जोडा.';

  @override
  String get profileBirthDateNeededTitle => 'जन्म तारीख आवश्यक';

  @override
  String get profilePartlySavedBody =>
      'तुमचे नाव आणि फोटो जतन केले. जन्म तपशील जतन झाले नाही; नंतर पुन्हा प्रयत्न करा.';

  @override
  String get profilePartlySavedTitle => 'अंशत: जतन केले';

  @override
  String get profileSavedBody => 'तुमची प्रोफाइल जतन केली.';

  @override
  String get profileChangePhoto => 'प्रोफाइल फोटो बदला';

  @override
  String get profilePhotoLabel => 'प्रोफाइल फोटो';

  @override
  String get profilePhotoHint => 'नवीन निवडण्यासाठी टॅप करा';

  @override
  String get profileBirthDateLabel => 'जन्म तारीख (ऐच्छिक)';

  @override
  String get profileBirthTimeLabel => 'जन्म वेळ (ऐच्छिक)';

  @override
  String get profileBirthTimeHelper => 'वेदिक सुचवण्या अधिक अचूक करते';

  @override
  String get profileBirthPlaceLabel => 'जन्मस्थळ (ऐच्छिक)';

  @override
  String get profileBirthPlaceHint => 'उदा. नवीन दिल्ली, भारत';

  @override
  String get profileHelpContactTitle => 'आम्हाला काहीही विचारा';

  @override
  String get profileHelpContactBody =>
      'संदेश पाठवा आणि आपण ईमेलद्वारे उत्तर देतो, साधारणपणे एका दिवसात.';

  @override
  String get profileHelpContactAction => 'सहाय्याशी संपर्क';

  @override
  String get profileHelpFaqTitle => 'वारंवार विचारले जाणारे प्रश्न';

  @override
  String get profileFaqAddPiecesTitle => 'क्लॉजेटमध्ये कपडे कसे जोडावेत?';

  @override
  String get profileFaqAddPiecesBody =>
      'Closet टॅबवर Add item वर टिपोट करा. फोटो काढा किंवा गॅलरीमधून निवडा; आपण प्रत्येक कपडा शोधून टॅग करतो.';

  @override
  String get profileFaqMatchingTitle => 'आउटफिट मॅचिंग कशी कार्य करते?';

  @override
  String get profileFaqMatchingBody =>
      'For you उघडा आणि तुमचे कपडे निवडा. आपण त्यांच्याबरोबर काय जुळेल ते सुचवतो आणि तुमच्या कलोजेटमधून संपूर्ण आउटफिट तयार करतो.';

  @override
  String get profileFaqTryOnTitle =>
      'तुमच्या स्वतःच्या फोटोद्वारे try-on वापरू शकतो का?';

  @override
  String get profileFaqTryOnBody =>
      'हो. तुमचे पूर्ण लांबीचे फोटो जोडा, मग कपडे निवडा आणि तुमच्यावर कसे दिसतात ते पाहा.';

  @override
  String get profileFaqRewardsTitle => 'बक्षीस कसे मिळवू?';

  @override
  String get profileFaqRewardsBody =>
      'आउटफिट नियोजित करा आणि नोंदवा. तुमच्या वापरासह स्ट्रीक्स आणि कायदेशीर उपलब्धी वाढत जातात.';

  @override
  String get profileFaqPrivacyTitle => 'माझे कलोजेट गोपनीय आहे का?';

  @override
  String get profileFaqPrivacyBody =>
      'हो. तुम्ही एक आउटफिटसाठी लिंक शेअर करत नाही तोपर्यंत तुमचे कलोजेट आणि आउटफिट गोपनीय राहतात.';

  @override
  String get profileHelpMoreTitle => 'आणखी मदत';

  @override
  String get profileHelpGuides => 'सोपे मार्गदर्शन';

  @override
  String get profileHelpGuidesBody => 'प्रत्येक फीचर कसे काम करतो';

  @override
  String get feedbackCategoryBug => 'काही चुकले';

  @override
  String get feedbackCategoryIdea => 'एक कल्पना';

  @override
  String get feedbackCategoryGeneral => 'सामान्य';

  @override
  String get feedbackCategoryHelp => 'मला मदत हवी आहे';

  @override
  String get feedbackHintBug =>
      'काय घडले, आणि तुम्हाला काय अपेक्षा होती? पायरी आपल्याला दुरुस्ती करण्यास मदत करतात.';

  @override
  String get feedbackHintIdea => 'तुम्हाला काय हवे आहे आणि का?';

  @override
  String get feedbackHintGeneral =>
      'तुम्हाला काय वाटते ते सांगा, किंवा प्रश्न विचारा.';

  @override
  String get feedbackAttachmentLimitBody =>
      'तुम्ही जास्तीत जास्त 5 चित्रे जोडू शकता.';

  @override
  String get feedbackAttachmentLimitTitle => 'मर्यादा गाठली';

  @override
  String get feedbackImageTooLargeBody =>
      '5 MB पेक्षा कमी आकाराचे चित्र निवडा.';

  @override
  String get feedbackImageTooLargeTitle => 'चित्र खूप मोठे आहे';

  @override
  String get feedbackTitle => 'प्रतिक्रिया पाठवा';

  @override
  String get feedbackAboutLabel => 'कायबद्दल आहे?';

  @override
  String get feedbackSubjectLabel => 'विषय';

  @override
  String get feedbackSubjectRequired => 'विषय जोडा';

  @override
  String get feedbackSubjectTooShort => 'विषयात किमान ३ अक्षरे होंत';

  @override
  String get feedbackDetailsLabel => 'तपशील';

  @override
  String get feedbackDetailsRequired => 'काही तपशील जोडा';

  @override
  String get feedbackDetailsTooShort => 'वर्णनात किमान १० अक्षरे होंत';

  @override
  String get feedbackAddScreenshot => 'स्क्रीनशॉट जोडा';

  @override
  String get feedbackAttachmentHint => 'कमाल ५ फाइल्स, प्रत्येकी ५ MB';

  @override
  String get feedbackSend => 'पाठवा';

  @override
  String get feedbackEmptyTitle => 'अजून काही पाठवले नाही';

  @override
  String get feedbackEmptyBody =>
      'तुम्ही पाठवले ते इथे त्याच्या स्थितीसह दिसते.';

  @override
  String get feedbackHistoryTitle => 'तुम्ही काय पाठवले';

  @override
  String get feedbackStatusOpen => 'खुले';

  @override
  String get feedbackStatusInProgress => 'प्रक्रियेत';

  @override
  String get feedbackStatusResolved => 'निरावळ';

  @override
  String get feedbackStatusClosed => 'बंद';

  @override
  String get legalIntro =>
      'आम्ही तुमचे डेटा कसे सुरक्षित ठेवतो आणि FitCheck AI वापराचे नियम.';

  @override
  String get legalPolicies => 'पॉलिसी';

  @override
  String get legalPrivacySubtitle => 'आम्ी काय गोळा करतो आणि का';

  @override
  String get legalTermsTitle => 'सेवा शर्ती';

  @override
  String get legalTermsSubtitle => 'ॲप वापरण्याचे नियम';

  @override
  String get legalLicences => 'ओपन-सोर्स परवाने';

  @override
  String get legalSupportSubtitle => 'मदत, संपर्क आणि पिव्हसी विनंती';

  @override
  String get legalReportAbuse => 'समस्येचा किंवा दुरुपयोगाचा समाचार द्या';

  @override
  String get permissionCameraTitle => 'कॅमेरा प्रवेश';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI तुमच्या वस्तू आणि आउटफिट्सच्या फोटो काढण्यासाठी कॅमेरा वापरते, AI ट्राय-ऑन आणि क्लोझेट व्यवस्थापनासाठी.';

  @override
  String get permissionPhotoTitle => 'फोटो प्रवेश';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI च्या AI सुविधा आणि तुमच्या क्लोझेटसाठी वस्त्रे आणि आउटफिट इमेज निवडण्यासाठी तुमच्या फोटोंप्रमाणे प्रवेश हवा आहे.';

  @override
  String get permissionNotNow => 'आता नाही';

  @override
  String get permissionOpenSettings => 'सेटिंग्ज उघडा';

  @override
  String authSignedInAs(String name) {
    return '$name म्हणून साइन इन';
  }

  @override
  String get authSignedIn => 'साइन इन झाले';

  @override
  String get authWelcomeBackTitle => 'पुन्हा स्वागत आहे';

  @override
  String get authSignInFailed => 'साइन इन अयशस्वी झाले';

  @override
  String get authWelcomeTitle => 'स्वागत आहे';

  @override
  String get authSignUpFailed => 'नोंदी अयशस्वी झाली';

  @override
  String get authGoogleSignInFailed => 'गूगल साइन इन अयशस्वी झाले';

  @override
  String get authAppleSignInFailed => 'Apple साइन इन अयशस्वी झाले';

  @override
  String get authConfirmEmailTitle => 'तुमचा ईमेल पडताळा';

  @override
  String get authConfirmEmailBody =>
      'पडताळणीसाठी तुमच्या इनबॉक्समध्ये ईमेल तपासा, नंतर साइन इन करा.';

  @override
  String get authClosetReady => 'तुमची कुलदी सजली आहे.';

  @override
  String get authSignedOutTitle => 'साइन आउट झाले';

  @override
  String get authSignedOutBody => 'तुम्ही साइन आउट आहात.';

  @override
  String get authSignOutFailed => 'साइन आउट अयशस्वी झाले';

  @override
  String get authEmailSentTitle => 'ईमेल पाठवला';

  @override
  String get authResetLinkSent => 'रिसेट लिंकसाठी तुमच्या ईमेलचा तपासणी करा.';

  @override
  String get authPasswordUpdatedTitle => 'पासवर्ड अपडेटेड';

  @override
  String get authPasswordUpdated => 'तुमचा पासवर्ड अपडेट झाला आहे.';

  @override
  String get authPasswordNotUpdated => 'पासवर्ड अपडेट केलेला नाही';

  @override
  String get authCouldNotSendEmail => 'ईमेल पाठवता आला नाही';

  @override
  String get authEmailNotSent => 'ईमेल पाठवलेला नाही';

  @override
  String get authResendSentBody => 'आम्ही नवीन पडताळणी ईमेल पाठवला आहे.';

  @override
  String get outfitPreviewWithAi => 'AI ने प्रीव्ह्यू पाहा';

  @override
  String get outfitNewPreview => 'नवीन प्रीव्हियो तयार करा';

  @override
  String get outfitBuilderClosetHeading => 'तुमची कुलदी';

  @override
  String get outfitBuilderSearchHint => 'वस्त्र शोधा';

  @override
  String get outfitClearSearch => 'शोध पुसा';

  @override
  String get outfitBuilderAddPiecesTitle => 'आधी वस्त्रे टाका';

  @override
  String get outfitBuilderAddPiecesBody =>
      'आउटफिट ही तुमच्या कुलदीमधील वस्त्रांमधून बनवली जातात.';

  @override
  String get outfitBuilderNoMatches => 'समान वस्त्रे सापडली नाहीत.';

  @override
  String get outfitNameLabel => 'आउटफिटचे नाव';

  @override
  String get outfitNameHint => 'उदा. वीकेंड लिनन';

  @override
  String get outfitPreviewSemantic => 'आउटफिटचा AI प्रीव्ह्यू';

  @override
  String get outfitChoosePieces => 'कपडे निवडा';

  @override
  String get outfitTapPiecesHint => 'जोडण्यासाठी खालील कपडे टॅप करा.';

  @override
  String get outfitShareTooltip => 'शेअर करा';

  @override
  String get outfitSaveFavourite => 'कमंदात सावधे';

  @override
  String get outfitPiecesHeading => 'कपडे';

  @override
  String get outfitWearHistoryEmpty => 'एकदा घाया आणि तारीख येथे दिखेल.';

  @override
  String get outfitWearHistoryTitle => 'वापर इतिहास';

  @override
  String get outfitWearHistoryError => 'तारखे लोड करता आल्या नाहीत.';

  @override
  String get outfitWornOn => 'लावले';

  @override
  String get outfitEditTitle => 'आउटफिट सुधारित करा';

  @override
  String get outfitSavedPhotosFailed => 'विवरण जतन झाले, फोटो नाही';

  @override
  String get outfitNoPhotosBody =>
      'अजून फोटो नाहीत. त्याऐवजी आउटफिटचे कपडे दिसतात.';

  @override
  String get outfitOccasionLabel => 'प्रसंग';

  @override
  String get outfitOccasionNone => 'नसले';

  @override
  String get outfitTagsHint => 'कमांनी वेगळे करा';

  @override
  String get outfitDraftBody => 'ते तुमच्या मुख्य यादीतून लपवले आहे';

  @override
  String get outfitPublic => 'सार्वजनिक';

  @override
  String get outfitPublicBody => 'लिंक असलेला कोणीही पाहू शकतो';

  @override
  String get outfitDeleteFromDetail =>
      'याआउटफिटला त्याच्या तपशील पानावरून काढा.';

  @override
  String get outfitNewCollection => 'नवीन संग्रह';

  @override
  String get outfitNoCollectionsTitle => 'अजून संग्रह नाही';

  @override
  String get outfitNoCollectionsBody =>
      'यात्रेनुसार, हंगामानुसार किंवा वातावरणानुसार आउटफिट समूभांडात ठेवा.';

  @override
  String get outfitCreateCollection => 'संग्रह तयार करा';

  @override
  String get outfitAddOutfits => 'आउटफिट जोडा';

  @override
  String get outfitRename => 'नाव बदला';

  @override
  String get outfitCollectionDeleteBody => 'त्यातील आउटफिट जतन केले जातात.';

  @override
  String get outfitCollectionsNotLoaded => 'आउटफिट लोड केले नाहीत';

  @override
  String get outfitRenameCollection => 'संग्रहाचे नाव बदला';

  @override
  String get outfitDescriptionOptional => 'विवरण (ऐच्छिक)';

  @override
  String get outfitAllInCollection => 'प्रत्येक आउटफिट या संग्रहात आहे.';

  @override
  String get photoshootSubtitleUpload =>
      'तुमच्या स्वतःच्या फोटोतून स्टूडियो चित्रे';

  @override
  String get photoshootSubtitleConfigure => 'शैली, स्वरूप आणि संख्या निवडा';

  @override
  String get photoshootSubtitleGenerating => 'यासाठी एक-दोन मिनिटे लागतात';

  @override
  String get photoshootAddPhotosSemantic => 'तुमच्या गॅलरीतून फोटो जोडा';

  @override
  String get photoshootUploadTitle => 'तुमच्या १ ते ४ फोटो जोडा';

  @override
  String get photoshootUploadBody => 'तुमच्या गॅलरीतून निवडण्यासाठी टॅप करा';

  @override
  String get photoshootAddToContinue => 'तसे चालू ठेवण्यासाठी फोटो जोडा';

  @override
  String get photoshootAddAnotherPhoto => 'एक अधिक फोटो जोडा';

  @override
  String get photoshootTipsTitle => 'सर्वोत्तम निकasha साठी';

  @override
  String get photoshootTipsBody =>
      'तुमच्या चेहऱ्याच्या स्पष्ट, सूर्याच्या प्रकाशातून घेतलेल्या फोटो वापरा. चष्मे आणि टोप्या टाळ.';

  @override
  String get photoshootStarting => 'सुरू';

  @override
  String get photoshootCancelling => 'रद्द';

  @override
  String get photoshootFailed => 'अस्वीकार';

  @override
  String get recommendTabMatches => 'मैच';

  @override
  String get recommendTabComplete => 'पूर्ण';

  @override
  String get recommendTabWeather => 'हवामान';

  @override
  String get recommendTabColours => 'रंग';

  @override
  String get recommendTabShop => 'दुकान';

  @override
  String get recommendNoMatchesTitle => 'अजून कोणतेही मैच नाही';

  @override
  String get recommendNoMatchesBody =>
      'एक खण्ड निवडा आणि आम्ही त्याशी जुळणारे शोधू.';

  @override
  String get recommendPickPiece => 'खण्ड निवडा';

  @override
  String get recommendNothingMatchesTitle => 'याशी अजून काही जुळत नाही';

  @override
  String get recommendNothingMatchesBody =>
      'इतर खण्ड प्रयत्न करा किंवा तुमच्या क्लॉसेटमध्ये अधिक जोडा.';

  @override
  String get recommendChangePieces => 'खण्ड बदला';

  @override
  String get recommendDefaultReason => 'ती तुमच्या निवडलेल्या खंडांशी जुळते.';

  @override
  String get recommendCompleteTitle => 'लुक पूर्ण करा';

  @override
  String get recommendCompleteBody =>
      'एक खण्ड निवडा आणि आम्ही उरलेले पूर्ण करू.';

  @override
  String get recommendWorking => 'कार्यरत';

  @override
  String get recommendGenerate => 'जन्हा';

  @override
  String get recommendChooseStyleBody => 'शैली निवडा, मग जनरेट करा.';

  @override
  String get recommendNoLooksTitle => 'या अवघड्यांसाठी कोणताही लूक नाही';

  @override
  String get recommendNoLooksBody => 'दुसरी शैली किंवा दुसरे अवघडे आणून पाहा.';

  @override
  String get recommendDefaultLook => 'तुमच्या अवघड्यांसाठी एक लूक';

  @override
  String get recommendNoPiecesBody => 'या लूकसाठी कोणतेही अवघडे परत आले नाहीत.';

  @override
  String get recommendCityLabel => 'शहर';

  @override
  String get recommendCheck => 'तपासा';

  @override
  String get recommendWeatherTitle => 'हवामान कसे आहे?';

  @override
  String get recommendWeatherBody => 'आजच्या निवडींसाठी तुमचे शहर टाका.';

  @override
  String get recommendWearToday => 'आज घाला';

  @override
  String get recommendWeatherNoPieces =>
      'या हवामानासाठी तुमच्या वेशभुषेत कोणतेही अवघडे नाहीत.';

  @override
  String get recommendBudgetLabel => 'खर्च मर्यादा';

  @override
  String get recommendLooking => 'लागतेय';

  @override
  String get recommendFindWhatToBuy => 'खरेदी काय करायची ते शोधा';

  @override
  String get recommendFillGapsTitle => 'लांबी पातळ करा';

  @override
  String get recommendFillGapsBody =>
      'अनुदान ठेवा आणि आम्ही तुमच्या वेशभुषेत काय गहाळ आहे ते सूचवू.';

  @override
  String get recommendNoGapsTitle => 'लांबी आढळल्या नाहीत';

  @override
  String get recommendNoGapsBody => 'अधिक अनुदान किंवा दुसरी श्रेणी ठेवा.';

  @override
  String get recommendMoodEveryday => 'रोजचे';

  @override
  String get recommendMoodBigMeeting => 'मोठ्या बैठकीसाठी';

  @override
  String get recommendDayLabel => 'दिवस';

  @override
  String get recommendReadingStars => 'नक्षत्रे वाचत आहोत';

  @override
  String get recommendGetMyColours => 'माझे रंग मिळवा';

  @override
  String get recommendLuckyColoursTitle => 'तुमचे भागीरथी रंग';

  @override
  String get recommendLuckyColoursBody =>
      'दिवस निवडा आणि आम्ही त्यासाठी रंग आणि अवघडे सुचवू.';

  @override
  String get recommendLuckyColoursSection => 'भागीरथी रंग';

  @override
  String get recommendAvoidColoursSection => 'कमी वापरावेत असे रंग';

  @override
  String get recommendBirthDateTitle => 'तुमचा जन्मदिन टाका';

  @override
  String get recommendBirthDateBody =>
      'तुमचे रंग वाचण्यासाठी तुमचा जन्मदिन लागेल.';

  @override
  String get recommendEditProfile => 'प्रोफाइल संपादित करा';

  @override
  String get recommendNothingThisDay => 'या दिवसासाठी काहीही नाही.';

  @override
  String get recommendUnnamedColour => 'नाविरहित रंग';

  @override
  String get recommendFromCloset => 'तुमच्या कलर्डरमधून';

  @override
  String get recommendNoPiecesInColours => 'या रंगांमध्ये अद्याप आकडे नाहीत.';

  @override
  String get recommendOutfitIdeas => 'आउटफिट आयडिया';

  @override
  String get recommendNoOutfitsInColours =>
      'या रंगांमध्ये संपूर्ण आउटफिट अजून नाही.';

  @override
  String get recommendDefaultOutfitIdea => 'एक आउटफिट आयडिया';

  @override
  String get recommendPickUpToThree => 'सध्या तीन आकडे निवडा';

  @override
  String get recommendEmptyClosetBody =>
      'आधी काही आकडे जोडा, मग जुळवाण्यासाठी परत या.';

  @override
  String get dashboardDressForDay => 'आधीच्या दिवसाला काय घालायचे ते ठरवा.';

  @override
  String get dashboardOutfitOfDay => 'दिवसाचा आउटफिट';

  @override
  String get dashboardFreshLook => 'नवीन लुक';

  @override
  String get subscriptionManageInStoreTitle => 'स्टोर्ड मध्ये व्यवस्थापित करा';

  @override
  String get subscriptionManageInStoreBody =>
      'हा प्लॅन स्टोर्डमार्गाने बिलिंग होतो. तुमच्या स्टोर्ड खाते सेटिंगमध्ये त्याचे व्यवस्थापन करा.';

  @override
  String get subscriptionCancelledTitle => 'सब्स्क्रिप्शन रद्द झाले';

  @override
  String get subscriptionCancelledBody =>
      'हा प्लॅन या बिलिंग कालावधीच्या शेवपर्यंत सक्रिय राहणार आहे.';

  @override
  String get subscriptionCancelFailedTitle => 'रद्द करू शकले नाही';

  @override
  String get subscriptionCouldNotOpenTitle => 'उघडू शकले नाही';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'बिलिंग व्यवस्थापन उघडू शकले नाही.';

  @override
  String get subscriptionOpenLinkFailedBody => 'लिंक उघडू शकले नाही.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'तुमची लिंक लोड होऊ शकली नाही';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'रिफरल लिंक लोड होऊ शकली नाही. पुन्हा प्रयत्न करा.';

  @override
  String get subscriptionReferralCopiedTitle => 'कॉपी झाले';

  @override
  String get subscriptionReferralCopiedBody => 'रिफरल लिंक कॉपी झाली.';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI ट्राय करा';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI मध्ये सामील व्हा आणि आपोआप दोघांनाही Pro चा एक महिना मिळतो. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'लिंक कॉपी झाली';

  @override
  String get subscriptionShareUnavailableBody =>
      'शेअरिंग उपलब्ध नाही, त्यामुळे लिंक कॉपी केली.';

  @override
  String get subscriptionShareFailedTitle => 'शेअर करू शकले नाही';

  @override
  String get subscriptionShareFailedBody => 'संदर्भ पृष्ठावून लिंक कॉपी करा.';

  @override
  String get subscriptionStoreReadyTitle => 'स्टोर्ड तयार आहे';

  @override
  String get subscriptionStoreReadyBody =>
      'स्टोर्ड किंमती उपलब्ध आहेत. तुम्ही आत्ता अपग्रेड करू शकता.';

  @override
  String get purchaseFailedTitle => 'खरेदी अयशस्वी';

  @override
  String get purchaseUnavailableTitle => 'खरेदी उपलब्ध नाही';

  @override
  String get purchaseIapUnavailableBody =>
      'हा डिवाइसवर इन-अॅप खरेदी उपलब्ध नाहीत.';

  @override
  String get purchasePlanNotAvailableBody =>
      'हा योजना आत्ता खरेदीसाठी उपलब्ध नाही.';

  @override
  String get purchasePlanNotInStoreBody =>
      'हा योजना आत्ता स्टोर्डमध्ये उपलब्ध नाही. कृपया लवकरच तपासा.';

  @override
  String get purchaseStartFailedBody =>
      'खरेदी सुरू करता आली नाही. पुन्हा प्रयत्न करा.';

  @override
  String get purchaseNoPaymentLinkBody => 'चेकआउटने देय लिंक परत केले नाही.';

  @override
  String get purchasePendingTitle => 'खरेदी प्रतीक्षास्थितीत';

  @override
  String get purchasePendingBody =>
      'तुमची खरेदी मंजुरीच्या प्रतीक्षेत आहे. मंजूर झेत की तुम्हाला लवकरच प्रवेश मिळेल.';

  @override
  String get purchaseFailedBody => 'खरेदी अयशस्वी झाली. पुन्हा प्रयत्न करा.';

  @override
  String get purchaseRestoredTitle => 'पुनर्स्थापित';

  @override
  String get purchaseRestoredBody => 'तुमच्या खरेदी पुनर्स्थापित झाल्या आहेत.';

  @override
  String get purchaseActiveTitle => 'सभस्मक्रिया सक्रिय';

  @override
  String get purchaseActiveBody => 'तुमची सभस्मक्रिया सक्रिय आहे. स्वागत आहे.';

  @override
  String get purchaseSignInRequiredTitle => 'लॉगिन आवश्यक';

  @override
  String get purchaseSignInRequiredBody =>
      'तुमची खरेदी पूर्ण करण्यासाठी लॉगिन करा.';

  @override
  String get purchaseErrorTitle => 'खरेदी त्रुटी';

  @override
  String get purchaseInvalidTransactionBody =>
      'खरेदीमध्ये पडताळले जाणारे व्यवहार आइडी समाविष्ट नव्हते.';

  @override
  String get purchaseVerificationPendingTitle => 'प्रमाणीकरण प्रतीक्षास्थितीत';

  @override
  String get purchaseVerificationPendingBody =>
      'आम्हाला आत्ता स्टोर्डशी तुमची खरेदी पडताळता आली नाही. ही प्रक्रिया आपोआप पूर्ण होईल आणि तुमचे दुहेरी नमुलन केले जाणार नाही.';

  @override
  String get purchaseNotAppliedTitle => 'खरेदी लागू झाली नाही';

  @override
  String get purchaseNotAppliedBody =>
      'तुमची खरेदी तुमच्या खात्यावर लागू करता आली नाही. सहाय्याशी संपर्क साधा आणि पुन्हा खरेदी करू नका.';

  @override
  String get purchaseRestoreFailedTitle => 'पुनर्स्थापना अयशस्वी';

  @override
  String get purchaseRestoreFailedBody =>
      'खरेदी पुनर्स्थापित करता आल्या नाहीत. पुन्हा प्रयत्न करा.';

  @override
  String get purchaseRecoveredActiveBody => 'तुमची सभस्मक्रिया सक्रिय आहे.';

  @override
  String get purchaseCompleteTitle => 'खरेदी पूर्ण';

  @override
  String get giftCreateFailedTitle => 'उपहार तयार करता आला नाही';

  @override
  String get giftClaimFailedTitle => 'उपहार मिळवता आला नाही';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count उपहार तुमच्यासाठी',
      one: 'तुमचा एका उपहार',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 महिना',
      '12': '1 वर्ष',
      'other': '$months महिने',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining बाकी',
      one: '1 बाकी',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro च्या $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender ने तुम्हाला FitCheck Pro च्या $duration ची ऑफर केली आहे. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient साठी FitCheck Pro उपहार';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender पासून';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient साठी';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender पासून';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'तुमचा घेते';

  @override
  String get giftPreviewPlaceholderSender => 'तुम्ही';

  @override
  String get settingsSavedTitle => 'जतन झाले';

  @override
  String get settingsNotSavedTitle => 'जतन झाले नाही';

  @override
  String get settingsAiChooseProviderBody => 'प्रदायक निवडा.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'कस्टम प्रदायकाला API URL आवश्यक आहे.';

  @override
  String get settingsAiKeyRequiredBody => 'API की टाका.';

  @override
  String get settingsAiSavedBody => 'तुमच्या AI सेटिंग्ज जतन झाल्या आहेत.';

  @override
  String get settingsAiMissingDetailsTitle => 'तपशील चुकले';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'टेस्ट करण्यासाठी API URL आणि चॅट मोडेल टाका.';

  @override
  String get settingsAiKeyNeededTitle => 'API की आवश्यक';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'टेस्ट करण्यासाठी तुमची API की टाका. तुमची जतन केलेली की खासगी राहते.';

  @override
  String get settingsAiKeyToTestBody => 'टेस्ट करण्यासाठी तुमची API की टाका.';

  @override
  String get settingsAiConnectedTitle => 'जोडले';

  @override
  String get settingsAiConnectedBody => 'कनेक्शन काम करते आहे.';

  @override
  String get settingsAiTestFailedTitle => 'टेस्ट अपयशी';

  @override
  String get settingsPreferencesSavedBody => 'तुमचे प्राधान्ये जतन झाली आहेत.';

  @override
  String get settingsPasswordNotChangedTitle => 'पासवर्ड बदलला नाही';

  @override
  String get settingsOAuthPasswordBody =>
      'हा खाते Google किंवा Apple द्वारे साइन इन करते. आधी पासवर्ड सेट करण्यासाठी \"पासवर्ड विसरला\" वापरा.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'वर्तमान पासवर्ड चुकीचा आहे.';

  @override
  String get settingsExportReadyTitle => 'एक्सपोर्ट तयार आहे';

  @override
  String get settingsExportReadyBody =>
      'तुमचा डेटा एक्सपोर्ट डाउनलोड करण्यासाठी तयार आहे.';

  @override
  String get settingsLinkCopiedTitle => 'लिंक कॉपी केली';

  @override
  String get settingsExportClipboardBody =>
      'आम्ही तुमचा ब्राउझर उघडू शकले नाही, म्हणून आम्ही डाउनलोड लिंक कॉपी केली आहे. ती लवकर ब्राउझरमध्ये पेस्ट करा: ती माझवते.';

  @override
  String get settingsExportFailedTitle => 'एक्सपोर्टच अपयश';

  @override
  String get settingsAccountNotDeletedTitle => 'खाते मोजले गेले नाही';

  @override
  String photoshootPhotoLimit(int max) {
    return 'तुम्ही जास्तीत जास्त $max फोटो जोडू शकता.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'फोटो मर्यादा';

  @override
  String get photoshootAddAtLeastOnePhoto => 'कमीत कमी एक फोटो जोडा.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'फोटो नाही';

  @override
  String get photoshootDescribeLookBody => 'तुम्हाला हवा असलेला लुक वर्णन करा.';

  @override
  String get photoshootPromptNeededTitle => 'प्रॉम्प्ट आवश्यक';

  @override
  String get photoshootConsentFeatureLabel => 'AI फोटोशूट';

  @override
  String get photoshootStatusPreparing => 'तुमचे फोटो तयार होत आहेत';

  @override
  String get photoshootStatusGenerating => 'जनरेटिंग';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'बॅच $current/$total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$total पैकी $done पूर्ण झाले';
  }

  @override
  String get photoshootGenerationFailedBody => 'जनरेशन अपयशी ठरले.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready तयार, $failed अपयशी.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'अर्धा पूर्ण';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो तयार आहेत.',
      one: '1 फोटो तयार आहे.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'कनेक्शन तोडले गेले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get photoshootCouldNotCancelTitle => 'रद्द केले जाऊ शकले नाही';

  @override
  String get photoshootRetryFailedTitle => 'पुन्हा प्रयत्न अपयशी';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'फोटो $number तयार आहे.';
  }

  @override
  String get photoshootReplacedTitle => 'बदलले';

  @override
  String get photoshootSavedToGalleryBody => 'तुमच्या गॅलरीमध्ये जतन केले.';

  @override
  String get photoshootSavedTitle => 'जतन केले';

  @override
  String get photoshootNotSavedTitle => 'जतन केले नाही';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सर्व $count फोटो तुमच्या गॅलरीमध्ये आहेत.',
      one: '1 फोटो तुमच्या गॅलरीमध्ये आहे.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved पैकी $total जतन केले आहेत.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'काही फोटो जतन झाले नाहीत';

  @override
  String get tryonConsentFeatureLabel => 'व्हर्चुअल ट्राय-ऑन';

  @override
  String get tryonAvatarUpdatedBody => 'तुमचा फोटो अपडेट झाला आहे.';

  @override
  String get tryonSavedTitle => 'जतन केले';

  @override
  String get tryonUploadFailedTitle => 'अपलोड अपयशी झाले';

  @override
  String get tryonChooseGarmentFirstBody => 'प्रथम वेशभांडवलाचा फोटो निवडा.';

  @override
  String get tryonNoGarmentTitle => 'वेषभांडवल नाही';

  @override
  String get tryonWaitForUploadBody => 'तुमचा फोटो अपलोड होईपर्यंत थांबा.';

  @override
  String get tryonStillUploadingTitle => 'अपलोड होत आहे';

  @override
  String get tryonAddYourPhotoFirstBody => 'प्रथम तुमचा फोटो जोडा.';

  @override
  String get tryonReadyBody => 'तुमचे ट्राय-ऑन संपूर्ण झाले आहे.';

  @override
  String get tryonFailedTitle => 'ट्राय-ऑन अपयशी झाले';

  @override
  String get tryonSavedToGalleryBody => 'तुमच्या गॅलरीमध्ये जतन केले.';

  @override
  String get tryonNotSavedTitle => 'जतन केले नाही';

  @override
  String get calendarEventAddedBody => 'घटना जोडली';

  @override
  String get calendarEventPlannedTitle => 'आयोजित';

  @override
  String get calendarEventSavedBody => 'घटना जतन केली';

  @override
  String get calendarSavedTitle => 'जतन केले';

  @override
  String get calendarEventNotSavedTitle => 'घटना जतन केली नाही';

  @override
  String get calendarEventRemovedBody => 'घटना काढून टाकली';

  @override
  String get calendarEventDeletedTitle => 'मागवले';

  @override
  String get calendarEventNotDeletedTitle => 'घटना माघारू शकली नाही';

  @override
  String get calendarOutfitNotLinkedTitle => 'आउटफिट जोडले नाही';

  @override
  String get calendarLinkedTitle => 'जोडले';

  @override
  String get calendarOutfitNotRemovedTitle => 'आउटफिट काढले नाही';

  @override
  String get calendarOutfitRemovedBody => 'आउटफिट काढले';

  @override
  String get calendarDisconnectedBody => 'कॅलंडर तुटवणी करुन टाकले';

  @override
  String get calendarDisconnectedTitle => 'तुटवणी केली';

  @override
  String get calendarNotDisconnectedTitle => 'कॅलंडर तुटवणी करू शकले नाही';

  @override
  String get calendarTodayLabel => 'आज';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count even',
      one: '१ even',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start ते $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit जोडले';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" काढून टाकले जाईल.';
  }

  @override
  String get calendarThisAppLabel => 'हा अॅप';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider शी sync सध्या उपलब्ध नाही. तुम्ही इथे even टाकू शकता.';
  }

  @override
  String get calendarWeekdaySunShort => 'रवि';

  @override
  String get calendarWeekdayMonShort => 'सोम';

  @override
  String get calendarWeekdayTueShort => 'मंगळ';

  @override
  String get calendarWeekdayWedShort => 'बुध';

  @override
  String get calendarWeekdayThuShort => 'गुरु';

  @override
  String get calendarWeekdayFriShort => 'शुक्र';

  @override
  String get calendarWeekdaySatShort => 'शनि';

  @override
  String get calendarWeekdayMonday => 'सोमवार';

  @override
  String get calendarWeekdayTuesday => 'मंगळवार';

  @override
  String get calendarWeekdayWednesday => 'बुधवार';

  @override
  String get calendarWeekdayThursday => 'गुरुवार';

  @override
  String get calendarWeekdayFriday => 'शुक्रवार';

  @override
  String get calendarWeekdaySaturday => 'शनिवार';

  @override
  String get calendarWeekdaySunday => 'रविवार';

  @override
  String get outfitSavedToFavouritesBody => 'फेव्हरिटेजमध्ये ठेवले';

  @override
  String get outfitRemovedFromFavouritesBody => 'फेव्हरिटेजमधून काढले';

  @override
  String get outfitNotSavedTitle => 'सर्व्हे झाले नाही';

  @override
  String get outfitLoggedAsWornBody => 'आज घातले म्हणून नोंदवले.';

  @override
  String get outfitNicePickTitle => 'उत्तम निवड';

  @override
  String get outfitRemovedBody => 'आउटफिट काढून टाकला.';

  @override
  String get outfitDeletedTitle => 'दिले वगळले';

  @override
  String get outfitNotDeletedTitle => 'वगळले नाही';

  @override
  String get outfitDuplicatedBody => 'एक प्रतिलिपि तुमच्या आउटफिटमध्ये आहे.';

  @override
  String get outfitDuplicatedTitle => 'प्रतित्व';

  @override
  String get outfitNotDuplicatedTitle => 'प्रतित्व नाही';

  @override
  String get outfitNotSharedTitle => 'शेअर केलेले नाही';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" सज्ज आहे.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'संग्रह तयार केला गेला नाही';

  @override
  String get outfitCollectionUpdatedBody => 'संग्रह अपडेट केला.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'संग्रह अपडेट केला गेला नाही';

  @override
  String get outfitCollectionDeletedBody => 'संग्रह हटवला.';

  @override
  String get outfitCollectionNotDeletedTitle => 'संग्रह हटवला गेला नाही';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आउटफिट जोडले.',
      one: '1 आउटफिट जोडला.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'आउटफिट जोडले गेले नाहीत';

  @override
  String get outfitPreviewNotCreatedTitle => 'प्रिव्ह्यू तयार केला गेला नाही';

  @override
  String get outfitGiveNameBody => 'आउटफिटला नाव द्या.';

  @override
  String get outfitNameMissingTitle => 'नाव';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'किमान एक तुकडा निवडा.';

  @override
  String outfitCreatedBody(String name) {
    return '$name तुमच्या आउटफिटमध्ये आहे.';
  }

  @override
  String get outfitSavedTitle => 'जुंपवले';

  @override
  String get wardrobeAddedToFavouritesBody => 'पसंतींमध्ये जोडले';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'पसंतींमधून काढले';

  @override
  String get wardrobeNotSavedTitle => 'जुंपले नाही';

  @override
  String get wardrobeLoggedAsWornBody => 'आज घातल्या म्हणून नोंदवले.';

  @override
  String get wardrobeRemovedFromClosetBody => 'तुमच्या क्लोसेटमधून काढले.';

  @override
  String get wardrobeDeletedTitle => 'हटवले';

  @override
  String get wardrobeNotDeletedTitle => 'हटवले नाही';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count तुकडे तुमच्या क्लोझेटमधून काढले.',
      one: '1 तुकडा तुमच्या क्लोझेटमधून काढला.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI वॉर्डरोब एक्सट्रॅक्शन';

  @override
  String get itemAddScanJobLabel => 'स्कॅन';

  @override
  String get itemAddFoundEarlierBody => 'काहीतरी पूर्वीच्या स्कॅनमध्ये सापडले';

  @override
  String get itemAddLookingAtPhoto => 'तुमची फोटो पाहत आहे';

  @override
  String get itemAddExtractionFailedBody => 'एक्सट्रॅक्शन अपयशी ठरले';

  @override
  String get itemAddJobFailedBody => 'कार्य अपयशी ठरले';

  @override
  String get itemAddConnectionLostBody =>
      'कनेक्शन खाला गेले. पुन्हा प्रयत्न करा.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'प्रोसेस करत असताना कनेक्शन खाला गेले.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'टुकला $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'टुकला';

  @override
  String get itemAddNotCancelledTitle => 'रद्द झाले नाही';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टुके तुमच्या क्लोसेटमध्ये आहेत.',
      one: '1 टुकला तुमच्या क्लोसेटमध्ये आहे.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$total पैकी $saved टुके जतन झाले. बाकीचे जतन करण्यासाठी टॅप करा.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'काही टुके जतन झाले नाहीत';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'किमान एक फोटो निवडा.';

  @override
  String get batchPhotoUnreadableBody => 'हा फोटो वाचता आला नाही.';

  @override
  String get batchNoPhotosReadableBody =>
      'यापैकी एकही फोटो वाचता आला नाही. इतर फोटो वापरून पहा.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो',
      one: '1 फोटो',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'कार्यरत असताना कनेक्शन खाला गेले. पुन्हा प्रयत्न करा.';

  @override
  String get batchNotCancelledTitle => 'रद्द झाले नाही';

  @override
  String get batchPostLinkUnsupportedBody =>
      'पोस्ट लिंक सपोर्ट केल्या जात नाहीत. प्रोफाइल लिंक टाका.';

  @override
  String get batchLinkSpacesBody => 'लिंक्समध्ये स्पीस नसाव्यात.';

  @override
  String get batchEnterProfileLinkBody =>
      'Instagram किंवा Facebook प्रोफाइल लिंक टाका.';

  @override
  String get batchEnterProfileLinkShortBody => 'प्रोफाइल लिंक टाका.';

  @override
  String get batchSignInPageNotOpenBody =>
      'साइन-इन पेज उघडले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get batchSignInBrowserBody =>
      'ब्राउझरमध्ये साइन-इन करा आणि मग FitCheck कडे परत फिरा.';

  @override
  String get batchConnectAccountTitle => 'तुमचा अकाउंट कनेक्ट करा';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'तुमच्या ऑथेंटिकेटर अ‍ॅपमधील कोड टाका.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram ला सुरक्षा तपासणी करायची आहे. प्रथम ब्राउझरमध्ये साइन-इन करा.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'तुमचा username आणि password पुन्हा टाका.';

  @override
  String get batchSignInFailedBody =>
      'साइन-इन अपयशी ठरले. तुमचे वापरकर्तानाव आणि पासवर्ड तपासा.';

  @override
  String get batchSignInToKeepImportingBody =>
      'इंपोर्ट सुरू ठेवण्यासाठी साइन-इन करा.';

  @override
  String get batchAccountNotConnectedBody => 'तुमचा अकाउंट कनेक्ट झाला नाही.';

  @override
  String get batchAccountConnectedTitle => 'अकाउंट कनेक्ट झाले';

  @override
  String get batchNotConnectedTitle => 'कनेक्शन नाही';

  @override
  String get batchImportConnectionLostBody =>
      'import कडे कनेक्शन गेले. तपासण्यासाठी refresh करा.';

  @override
  String batchPickUpToBody(int max) {
    return '$max फोटो निवडा. आम्ही तुकडे शोधू.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$total पैकी $count फोटो';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'फोटो $count पैकी $done तयार होत आहे';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटोत तुकडे शोधा',
      one: '1 फोटोत तुकडे शोधा',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'तुमचा $platform खाते two-step sign-in वापरतो. तुमच्या authenticator app मधील 6-अंकी कोड टाका.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'हा $platform प्रोफाइल खासगी आहे किंवा फोटो दाखवण्यासाठी sign-in आवश्यक आहे.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platformशी कनेक्ट करा';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आता पर्यंत $count फोटो आढळले',
      one: 'आता पर्यंत 1 फोटो आढळला',
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
    return '$total पैकी $processed प्रोसेस · $added जोडले · $waiting प्रतीक्षा · $skipped वगळले';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'फोटो $number स्कॅन करत आहे';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'फोटो $number पुढे आहे';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'फोटो $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count तुकडे आढळले',
      one: '1 तुकडा आढळला',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो तुमच्या क्लोसेटमध्ये जोडले गेले.',
      one: '१ फोटो तुमच्या क्लोसेटमध्ये जोडला गेला.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count studio फोटो येत आहेत. तुम्ही तयार असलेले save करू शकता, किंवा बाहेर जाऊ शकता — आम्ही तुम्हाला सांगू.',
      one:
          '1 studio फोटो येत आहे. तुम्ही तयार असलेले save करू शकता, किंवा बाहेर जाऊ शकता — आम्ही तुम्हाला सांगू.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'अजून save केलले नाही: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos फोटो',
      one: '1 फोटो',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces तुकडे',
      one: '1 तुकडा',
    );
    return '$_temp0 मधील $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen निवडले. तुकडा वगळण्यासाठी टॅप करा.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count तुकडे save होत आहेत',
      one: '1 तुकडा save होत आहे',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count तुकडे save करा',
      one: '1 तुकडा save करा',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'तुमचा body profile save झाला आहे.';

  @override
  String get bodyProfileSavedTitle => 'save झाले';

  @override
  String get bodyProfileNotSavedTitle => 'save झाले नाही';

  @override
  String get bodyProfileSetDefaultBody =>
      'तुमचा default profile म्हणून सेट करा.';

  @override
  String get bodyProfileDeletedBody => 'body profile कढवला गेला.';

  @override
  String get bodyProfileDeletedTitle => 'काढले';

  @override
  String get bodyProfileNotDeletedTitle => 'काढले नाही';

  @override
  String get feedbackNotSentTitle => 'पाठवले नाही';

  @override
  String get feedbackSentBody =>
      'धन्यवाद. आम्ही प्रत्येक संदेश वाचतो आणि आवश्यक असल्यास उत्तर देतो.';

  @override
  String get feedbackSentTitle => 'प्रतिक्रिया पाठवली';

  @override
  String get recommendUnnamedPiece => 'नावनिर्देशित वस्तू';

  @override
  String get recommendEnterCityBody =>
      'हवामानानुसार निवडी मिळण्यासाठी तुमचा शहर नोंदवा.';

  @override
  String get recommendWhichCityTitle => 'कोणते शहर?';

  @override
  String get aiConsentSheetTitle => 'AI सेव्हशी फोटो शेअरिंग';

  @override
  String get aiConsentSheetBody =>
      'तुमचे try-on आणि फोटोशूट इमेज तयार करण्यासाठी, FitCheck AI तुमचे दिलेले फोटो (तुमच्या चेहर्या आणि शरिराच्या इमेजसह) प्रक्रिया करण्यासाठी विश्वासार्ह तृतीय-पक्षीय AI प्रदात्याकडे (जसे की OpenAI किंवा Google Gemini) पाठवते. ते तुमच्या इमेज तयार करतात आणि आमच्या अटींनुसार त्यांचे मॉडेल्स प्रशिक्षणासाठी वापरत नाहीत. फोटो सुरक्षितपणे प्रसारित केले जातात आणि जाहिरातींसाठी कधीही सामायिक केले जात नाहीत.';

  @override
  String get aiConsentSheetPermission =>
      'सुरू ठेवून, तुम्ही या AI प्रदात्यांसोबत इमेज निर्मितीसाठी तुमचे फोटो शेअर करण्यास स्पष्ट परवानगी देता.';

  @override
  String get skeletonsLoadMoreFailed => 'अधिक आणू शकले नाही.';

  @override
  String get jobsPiecesReadyTitle => 'तुमच्या वस्तू तयार आहेत';

  @override
  String get jobsScanStoppedTitle => 'स्कॅन थांबला';

  @override
  String get jobsNothingSavedBody =>
      'काहीही जतन केले गेल नाही. पुन्हा प्रयत्न करा.';

  @override
  String get jobsPhotoUploadFailedBody => 'फोटो अपलोड अयशस्वी झाला.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google Sign-In सुरू करण्यास शक्य नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get referralAppliedTitle => 'मिलान लागू झाले!';

  @override
  String get billingStoreUnavailableBody =>
      'या डिव्हाइसवर स्टोअर खरेदी उपलब्ध नाही.';

  @override
  String get billingPurchaseProcessingBody =>
      'ही खरेदी अजून प्रक्रियेत आहे. तुमचे प्लॅन पाहण्यासाठी एक मिनिटानंतर अॅप पुन्हा उघडा.';

  @override
  String get profileAvatarUploadNoUrl =>
      'अवतार अपलोडने इमेज URL परत केले नाही.';

  @override
  String get rewardsDayStreakLabel => 'दिवस शृंखला';

  @override
  String rewardsBestStreak(int days) {
    return 'सर्वोत्तम $days दिवस';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission प्रवेश आवश्यक';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission प्रवेश सध्या नाकारला आहे. परवानगी देण्यासाठी सेटिंग्ज उघडा, नंतर परतून पुन्हा प्रयत्न करा.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'पैकी $step पायरी 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'पैकी $step पायरी $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'इमेज काढा $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'इमेज काढा $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points पॉइंट्स';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'ईमेल पाठवा $email. आम्ही २४ तासांत रिपोर्ट्स तपासतो.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'काढा $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '\"$name\" विहिती काढायचे?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '\"$name\" मध्ये जोडा';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" काढून टाकले आहे. त्याचे प्रत्येक भाग तुमच्या वॉर्डरोबमध्ये राहतील.';
  }

  @override
  String outfitShowAllCount(int count) {
    return '$count सर्व दाखवा';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'आज $count शिल्लक';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'फोटो $index अपयशी झाला';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max पैकी $selected फोटो';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape बिल्ड · $tone त्वचा';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name हटवायचे का?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name साठी पर्याय';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'सर्वाधिक वापरले: $name, $count वेळा';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: निश्चित नाही';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% जुळते';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max पैकी $picked निवडले';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item काढा';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency प्राधान्य';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'हा प्लॅन $store द्वारे बिल केला जातो. तुमच्या $store खाते सेटिंग्समध्ये ते बदला किंवा रद्द करा.';
  }

  @override
  String billingManageInStore(String store) {
    return '$store मध्ये व्यवस्थापित करा';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max पैकी $current वापरले';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'आणदोंड ${seconds}s शिल्लक';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total पैकी $done स्टुडिओ फोटो तयार';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total पैकी $ready स्टुडिओ फोटो तयार. एकक भाग वर टॅप करून ते वगळा.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height सेमी · $weight किलो';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'नाही';
}
