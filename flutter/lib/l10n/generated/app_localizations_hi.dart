// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'होम';

  @override
  String get tabPhotoshoot => 'फोटोशूट';

  @override
  String get tabCloset => 'क्लोसेट';

  @override
  String get tabOutfits => 'आउटफिट्स';

  @override
  String get tabMore => 'अधिक';

  @override
  String get actionAddItem => 'आइटम जोड़ें';

  @override
  String get actionCreateOutfit => 'आउटफिट बनाएं';

  @override
  String get actionCancel => 'रद्द करें';

  @override
  String get actionDelete => 'हटाएं';

  @override
  String get actionSave => 'सेव करें';

  @override
  String get actionRetry => 'पुनः प्रयास';

  @override
  String get actionDone => 'हो गया';

  @override
  String get actionNext => 'अगला';

  @override
  String get actionBack => 'पीछे';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get actionSearch => 'खोजें';

  @override
  String get actionContinue => 'जारी रखें';

  @override
  String get stateLoading => 'लोड हो रहा है';

  @override
  String get stateErrorTitle => 'कुछ गलत हो गया';

  @override
  String get stateErrorBody =>
      'फिर से प्रयास करें। यदि समस्या बनी रहती है, तो सपोर्ट से संपर्क करें।';

  @override
  String get stateOfflineTitle => 'आप ऑफलाइन हैं';

  @override
  String get stateOfflineBody =>
      'क्लोसेट सिंक करने और आउटफिट बनाने के लिए इंटरनेट से जुड़ें।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsAccountSection => 'अकाउंट';

  @override
  String get settingsPreferencesSection => 'प्राथमिकताएं';

  @override
  String get settingsPlanBilling => 'प्लान और बिलिंग';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsNotifications => 'नोटिफिकेशन';

  @override
  String get settingsUnits => 'माप की इकाइयां';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsPrivacySection => 'गोपनीयता और डेटा';

  @override
  String get settingsAboutSection => 'हमारे बारे में';

  @override
  String get settingsSignOut => 'साइन आउट करें';

  @override
  String get settingsDeleteAccount => 'खाता हटाएं';

  @override
  String get settingsDeleteAccountTitle => 'अपना खाता हटाएं?';

  @override
  String get settingsDeleteAccountBody =>
      'यह आपकी अलमारी, आउटफिट, फोटो और प्रोफाइल को हटा देगा। इसे पूर्ववत नहीं किया जा सकता।';

  @override
  String get settingsUnitsImperial => 'इंपीरियल (in, lb)';

  @override
  String get settingsUnitsMetric => 'मीट्रिक (cm, kg)';

  @override
  String get languageTitle => 'भाषा';

  @override
  String get languageSystem => 'डिवाइस की भाषा का उपयोग करें';

  @override
  String get languageSystemBody =>
      'FitCheck AI आपके फोन की भाषा का पालन करता है।';

  @override
  String get languageSearchHint => 'भाषाएं खोजें';

  @override
  String get languageCurrent => 'वर्तमान';

  @override
  String get languageReviewNote =>
      'यह अनुवाद नया है। यदि कुछ गलत लगे तो हमें बताएं।';

  @override
  String get languageChanged => 'भाषा अपडेट की गई';

  @override
  String get paywallTitle => 'अपना प्लान चुनें';

  @override
  String get paywallTrialBadge => '1 महीना मुफ्त';

  @override
  String get paywallTrialTitle => 'आपका पहला महीना Pro मुफ्त है';

  @override
  String get paywallTrialBody =>
      'अपनी पूरी अलमारी एक बार में अपलोड करें। उसके बाद नए कपड़े जोड़ते रहें।';

  @override
  String get paywallFreeForeverTitle => 'हमेशा मुफ्त';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'कार्ड की आवश्यकता नहीं है। हर महीने आपको $uploads AI अपलोड, $outfits आउटफिट और $images फोटोशूट इमेज प्रतिदिन मिलती हैं।';
  }

  @override
  String get paywallCtaTrial => 'मेरा मुफ्त महीना शुरू करें';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan में अपग्रेड करें';
  }

  @override
  String get paywallRestore => 'खरीदें रिस्टोर करें';

  @override
  String get paywallManage => 'सदस्यता प्रबंधित करें';

  @override
  String get paywallTerms => 'उपयोग की शर्तें';

  @override
  String get paywallPrivacy => 'गोपनीयता नीति';

  @override
  String get paywallPerMonth => 'प्रति माह';

  @override
  String get paywallPerYear => 'प्रति वर्ष';

  @override
  String get paywallBestValue => 'सबसे किफायती';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'फ्री ट्रायल केवल नए सब्सक्राइबर्स के लिए। ट्रायल के बाद, Pro $price पर रिन्यू होगा, जब तक कि इसे समाप्त होने से कम से कम 24 घंटे पहले रद्द न किया जाए।';
  }

  @override
  String get introTitle => 'आपकी अलमारी, अब व्यवस्थित';

  @override
  String get introBody =>
      'अपने कपड़ों की एक बार फोटो लें। अपने मौजूदा कपड़ों से आउटफिट आइडिया, ट्राई-ऑन प्रीव्यू और स्टूडियो फोटो पाएं।';

  @override
  String get introStart => 'शुरू करें';

  @override
  String get introHaveAccount => 'मेरा पहले से अकाउंट है';

  @override
  String get introSkip => 'छोड़ें';

  @override
  String get authSignIn => 'साइन इन करें';

  @override
  String get authSignUp => 'अकाउंट बनाएं';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get authContinueApple => 'Apple के साथ जारी रखें';

  @override
  String get authContinueGoogle => 'Google के साथ जारी रखें';

  @override
  String get authOrDivider => 'या';

  @override
  String get wardrobeTitle => 'Closet';

  @override
  String get wardrobeEmptyTitle => 'आपकी अलमारी खाली है';

  @override
  String get wardrobeEmptyBody =>
      'अपना पहला कपड़ा जोड़ें, या पूरे रैक की एक फोटो अपलोड करें।';

  @override
  String get wardrobeAddFirst => 'पहला आइटम जोड़ें';

  @override
  String get wardrobeSearchHint => 'अपनी अलमारी में खोजें';

  @override
  String get categoryTops => 'टॉप्स';

  @override
  String get categoryBottoms => 'बॉटम्स';

  @override
  String get categoryShoes => 'जूते';

  @override
  String get categoryAccessories => 'एक्सेसरीज';

  @override
  String get categoryOuterwear => 'आउटरवियर';

  @override
  String get categorySwimwear => 'स्विमवियर';

  @override
  String get categoryActivewear => 'एक्टिववियर';

  @override
  String get categoryOther => 'अन्य';

  @override
  String get conditionClean => 'साफ';

  @override
  String get conditionDirty => 'गंदे';

  @override
  String get conditionLaundry => 'धुलाई में';

  @override
  String get conditionRepair => 'मरम्मत चाहिए';

  @override
  String get conditionDonate => 'दान के लिए';

  @override
  String get seasonSpring => 'वसंत';

  @override
  String get seasonSummer => 'गर्मी';

  @override
  String get seasonFall => 'पतझड़';

  @override
  String get seasonWinter => 'सर्दी';

  @override
  String get seasonAll => 'सभी मौसम';

  @override
  String get styleCasual => 'कैज़ुअल';

  @override
  String get styleFormal => 'फॉर्मल';

  @override
  String get styleBusiness => 'बिज़नेस';

  @override
  String get styleSporty => 'स्पोर्टी';

  @override
  String get styleBohemian => 'बोहेमियन';

  @override
  String get styleStreetwear => 'स्ट्रीटवियर';

  @override
  String get styleVintage => 'विंटेज';

  @override
  String get styleMinimalist => 'मिनिमलिस्ट';

  @override
  String get styleRomantic => 'रोमांटिक';

  @override
  String get styleEdgy => 'एजी';

  @override
  String get stylePreppy => 'प्रेपी';

  @override
  String get styleArtsy => 'आर्टसी';

  @override
  String get styleClassic => 'क्लासिक';

  @override
  String get styleElegant => 'एलिगेंट';

  @override
  String get styleOther => 'अन्य';

  @override
  String get occasionWork => 'काम';

  @override
  String get occasionDateNight => 'डेट नाइट';

  @override
  String get occasionTravel => 'यात्रा';

  @override
  String get occasionWedding => 'शादी';

  @override
  String get occasionGym => 'जिम';

  @override
  String get occasionWeekend => 'वीकेंड';

  @override
  String get occasionParty => 'पार्टी';

  @override
  String get occasionInterview => 'इंटरव्यू';

  @override
  String get colorBlack => 'काला';

  @override
  String get colorWhite => 'सफेद';

  @override
  String get colorGrey => 'ग्रे';

  @override
  String get colorNavy => 'नेवी';

  @override
  String get colorBrown => 'भूरा';

  @override
  String get colorRed => 'लाल';

  @override
  String get colorBlue => 'नीला';

  @override
  String get colorGreen => 'हरा';

  @override
  String get colorPink => 'गुलाबी';

  @override
  String get colorPurple => 'बैंगनी';

  @override
  String get colorYellow => 'पीला';

  @override
  String get colorOrange => 'नारंगी';

  @override
  String get colorBeige => 'बेज';

  @override
  String get dateToday => 'आज';

  @override
  String get dateYesterday => 'कल';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: '1 दिन पहले',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सप्ताह पहले',
      one: '1 सप्ताह पहले',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महीने पहले',
      one: '1 महीने पहले',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count साल पहले',
      one: '1 साल पहले',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI पसंद आया?';

  @override
  String get ratingPromptBody =>
      'एक छोटी सी रेटिंग दूसरों को उनका स्टाइल खोजने में मदद करती है।';

  @override
  String get ratingPromptYes => 'रेट करें';

  @override
  String get ratingPromptNo => 'अभी नहीं';

  @override
  String get closetNoMatchesTitle => 'कोई मेल नहीं मिला';

  @override
  String get closetNoMatchesBody => 'कम फ़िल्टर या कोई और सर्च आज़माएं।';

  @override
  String get closetClearFilters => 'फ़िल्टर हटाएं';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पीस',
      one: '1 पीस',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'आपके पीस लोड हो रहे हैं';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चुने गए',
      one: '1 चुना गया',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'चुने हुए हटाएं';

  @override
  String get closetCancelSelection => 'चयन रद्द करें';

  @override
  String get closetCloseSearch => 'सर्च बंद करें';

  @override
  String get closetShowGrid => 'ग्रिड में देखें';

  @override
  String get closetShowList => 'लिस्ट में देखें';

  @override
  String get closetShowRows => 'पंक्तियों में देखें';

  @override
  String get closetStatsTitle => 'क्लोसेट आँकड़े';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पीस हटाएं?',
      one: '1 पीस हटाएं?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'इनका उपयोग करने वाले आउटफिट्स से ये पीस हट जाएंगे।';

  @override
  String get closetSortBy => 'क्रमबद्ध करें';

  @override
  String get closetFavourites => 'पसंदीदा';

  @override
  String get closetFavourite => 'पसंदीदा बनाएं';

  @override
  String get closetUnfavourite => 'पसंदीदा से हटाएं';

  @override
  String get closetWoreToday => 'आज पहना';

  @override
  String closetWornTimes(int count) {
    return '$count× पहना गया';
  }

  @override
  String get closetCategoryLabel => 'श्रेणी';

  @override
  String get closetUseCaseLabel => 'उपयोग';

  @override
  String get closetAnyUseCase => 'कोई भी';

  @override
  String get closetOtherUseCase => 'अन्य उपयोग';

  @override
  String get closetOtherUseCaseHint => 'उदाहरण के लिए, ब्रंच';

  @override
  String get closetUseUseCase => 'इसका उपयोग करें';

  @override
  String get closetClearAll => 'सब हटाएं';

  @override
  String get sortNewest => 'सबसे नया पहले';

  @override
  String get sortOldest => 'सबसे पुराना पहले';

  @override
  String get sortName => 'नाम (A–Z)';

  @override
  String get sortMostWorn => 'सबसे ज्यादा पहने गए';

  @override
  String get useCaseInformal => 'अनौपचारिक';

  @override
  String get useCaseDate => 'डेट';

  @override
  String get useCaseDinner => 'डिनर';

  @override
  String get useCaseLunch => 'लंच';

  @override
  String get actionSelect => 'चुनें';

  @override
  String get actionEdit => 'संपादित करें';

  @override
  String get actionFilter => 'फ़िल्टर';

  @override
  String get actionSort => 'सॉर्ट';

  @override
  String get actionAll => 'सभी';

  @override
  String get dashboardStartClosetTitle => 'अपनी अलमारी शुरू करें';

  @override
  String get dashboardStartClosetBody =>
      'कुछ कपड़ों की तस्वीरें लें। हम उन्हें आपके लिए टैग कर देंगे।';

  @override
  String get dashboardPieces => 'कपड़े';

  @override
  String get dashboardOutfits => 'आउटफ़िट';

  @override
  String get dashboardDayStreak => 'दिन का सिलसिला';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'इस महीने +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'सर्वश्रेष्ठ $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पसंदीदा',
      one: '1 पसंदीदा',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेव किए गए आउटफ़िट',
      one: '1 सेव किया गया आउटफ़िट',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'सबसे ज्यादा पहना गया: $name, $count बार';
  }

  @override
  String get setupSkip => 'सेटअप छोड़ें';

  @override
  String get setupWhoTitle => 'हम किसे स्टाइल कर रहे हैं?';

  @override
  String get setupWhoBody =>
      'यह ट्राई-ऑन और फोटोशूट के लिए मॉडल सेट करता है। आप इसे अपनी प्रोफ़ाइल में बदल सकते हैं।';

  @override
  String get setupStyleTitle => 'आप सबसे ज्यादा क्या पहनते हैं?';

  @override
  String get setupStyleBody =>
      'कोई भी चुनें। आउटफ़िट के विचार यहीं से शुरू होते हैं।';

  @override
  String get setupClosetTitle => 'अपने पहले कपड़े जोड़ें।';

  @override
  String get setupClosetBody =>
      'कुछ कपड़ों या उनके ढेर की तस्वीर लें। हर कपड़े को काटकर आपके लिए फाइल कर दिया जाएगा।';

  @override
  String get setupAddClothes => 'कपड़े जोड़ें';

  @override
  String get setupStylesLabel => 'स्टाइल';

  @override
  String get setupOccasionsLabel => 'अवसर';

  @override
  String get setupSkipStep => 'छोड़ें';

  @override
  String get setupLater => 'बाद में';

  @override
  String get setupSaveError => 'सेव नहीं हो सका';

  @override
  String get genderWomen => 'महिला';

  @override
  String get genderMen => 'पुरुष';

  @override
  String get genderNonBinary => 'नॉन-बाइनरी';

  @override
  String get genderPreferNotToSay => 'बताना नहीं चाहते';

  @override
  String get outfitEmptyTitle => 'कोई आउटफिट नहीं';

  @override
  String get outfitEmptyBody => 'अपने क्लोसेट से पीस चुनें और लुक सेव करें।';

  @override
  String get outfitNoMatchesTitle => 'कोई मैच नहीं मिला';

  @override
  String get outfitSearchHint => 'आउटफिट खोजें';

  @override
  String get outfitLoading => 'आउटफिट लोड हो रहे हैं';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आउटफिट',
      one: '1 आउटफिट',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'स्टाइल और सीजन';

  @override
  String get outfitCollections => 'कलेक्शन';

  @override
  String get outfitDuplicate => 'डुप्लिकेट';

  @override
  String get outfitDeleteTitle => 'आउटफिट हटाएं?';

  @override
  String get outfitDeleteBody => 'इसके पीस आपके क्लोसेट में रहेंगे।';

  @override
  String get outfitDrafts => 'ड्राफ्ट्स';

  @override
  String get outfitDraft => 'ड्राफ्ट';

  @override
  String get filterStyle => 'स्टाइल';

  @override
  String get filterSeason => 'सीजन';

  @override
  String get itemDetailDeleteTitle => 'यह पीस हटाएं?';

  @override
  String get itemDetailDeleteBody =>
      'जिन आउटफिट्स में यह है, उनसे यह हट जाएगा।';

  @override
  String get itemAddFavourite => 'पसंदीदा में जोड़ें';

  @override
  String itemSize(String size) {
    return 'साइज $size';
  }

  @override
  String get itemColours => 'रंग';

  @override
  String get itemMaterial => 'मटेरियल';

  @override
  String get itemPattern => 'पैटर्न';

  @override
  String get itemUseCases => 'उपयोग';

  @override
  String get itemKeptIn => 'यहाँ रखा गया';

  @override
  String get itemPrice => 'कीमत';

  @override
  String get itemBought => 'खरीदा गया';

  @override
  String get itemTags => 'टैग';

  @override
  String get itemAdded => 'जोड़ा गया';

  @override
  String get itemTimesWornLabel => 'बार पहना गया';

  @override
  String get itemLastWornLabel => 'आखिरी बार पहना';

  @override
  String get itemNeverWorn => 'कभी नहीं';

  @override
  String get authEntryBody =>
      'आपके पास मौजूद हर कपड़े, FitCheck AI द्वारा स्टाइल किए गए। आउटफिट प्लान करें, पहनकर देखें, फोटो लें।';

  @override
  String get authCreateCloset => 'अपनी अलमारी बनाएं';

  @override
  String get authWelcomeBack => 'वापसी पर स्वागत है';

  @override
  String get authSignInBody => 'अपनी अलमारी खोलने के लिए साइन इन करें।';

  @override
  String get authCreateAccount => 'खाता बनाएं';

  @override
  String get authCreateClosetBody =>
      'इसमें एक मिनट लगेगा। आपके पहले कुछ आइटम मुफ्त हैं।';

  @override
  String get authName => 'नाम';

  @override
  String get authConfirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get authReferralCode => 'रेफरल कोड (वैकल्पिक)';

  @override
  String get authResetTitle => 'पासवर्ड रीसेट करें';

  @override
  String get authResetBody =>
      'हम आपको नया पासवर्ड चुनने के लिए एक लिंक ईमेल करेंगे।';

  @override
  String get authSendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get authBackToSignIn => 'साइन इन पर वापस जाएं';

  @override
  String get authEnterEmail => 'अपना ईमेल दर्ज करें';

  @override
  String get authEnterValidEmail => 'वैध ईमेल दर्ज करें';

  @override
  String get authEnterPassword => 'अपना पासवर्ड दर्ज करें';

  @override
  String get authPasswordTooShort => 'कम से कम 6 अक्षर';

  @override
  String get authShowPassword => 'पासवर्ड दिखाएं';

  @override
  String get authHidePassword => 'पासवर्ड छिपाएं';

  @override
  String get authNewHere => 'यहाँ नए हैं?';

  @override
  String authConfirmEmail(String email) {
    return 'साइन इन करने से पहले $email की पुष्टि करें। अपना इनबॉक्स देखें।';
  }

  @override
  String get authResendEmail => 'पुनः भेजें';

  @override
  String get authResendingEmail => 'भेज रहे हैं...';

  @override
  String get authPasswordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get authEnterName => 'अपना नाम दर्ज करें';

  @override
  String get authChoosePassword => 'पासवर्ड चुनें';

  @override
  String get authHaveAccount => 'क्या खाता है?';

  @override
  String get authCodeAccepted => 'कोड स्वीकार किया गया';

  @override
  String get authCodeNotFound => 'कोड नहीं मिला';

  @override
  String authReferralFrom(String name) {
    return '$name की ओर से। आप दोनों को एक महीना मुफ्त मिलेगा।';
  }

  @override
  String get authReferralInvalid => 'हमें यह कोड नहीं मिला।';

  @override
  String authResetSent(String email) {
    return '$email पर भेजा गया। इस फोन पर लिंक खोलें।';
  }

  @override
  String get introSlide1Title => 'अपनी अलमारी की फोटो लें।';

  @override
  String get introSlide1Body =>
      'कपड़ों के ढेर की तस्वीर लें। हर कपड़ा अपने आप अलग और व्यवस्थित हो जाएगा।';

  @override
  String get introSlide2Title => 'जल्दी तैयार हों।';

  @override
  String get introSlide2Body =>
      'आपके कपड़ों से बने आउटफिट्स, जो आपके प्लान और मौसम के अनुसार हों।';

  @override
  String get introSlide3Title => 'पहनने से पहले देखें।';

  @override
  String get introSlide3Body =>
      'अपनी फोटो पर लुक आज़माएं, या उन्हें किसी विज्ञापन की तरह शूट करें।';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsThemeLight => 'लाइट';

  @override
  String get settingsThemeDark => 'डार्क';

  @override
  String get settingsTemperature => 'तापमान';

  @override
  String get settingsEmailUpdates => 'ईमेल अपडेट';

  @override
  String get settingsEmailUpdatesBody => 'ईमेल द्वारा समाचार और टिप्स';

  @override
  String get settingsOutfitReminders => 'आउटफिट रिमाइंडर';

  @override
  String get settingsOutfitRemindersBody =>
      'आपने क्या पहना, यह लॉग करने के लिए याद दिलाना';

  @override
  String get settingsWeeklySummary => 'साप्ताहिक सारांश';

  @override
  String get settingsWeeklySummaryBody => 'आपके सप्ताह के आउटफिट्स';

  @override
  String get settingsStyleSection => 'स्टाइल';

  @override
  String get settingsPreferredStyles => 'पसंदीदा स्टाइल्स';

  @override
  String get settingsPreferredColours => 'पसंदीदा रंग';

  @override
  String get settingsNoneChosen => 'कोई नहीं चुना गया';

  @override
  String get settingsPlanAiSection => 'प्लान और AI';

  @override
  String get settingsPlanBillingBody => 'प्लान, उपयोग और अपग्रेड';

  @override
  String get settingsPlanUsageBody => 'प्लान और उपयोग';

  @override
  String get settingsInviteFriends => 'दोस्तों को आमंत्रित करें';

  @override
  String get settingsInviteFriendsBody =>
      'जुड़ने वाले प्रत्येक मित्र के लिए एक महीना मुफ्त';

  @override
  String get settingsAiProvider => 'AI प्रदाता';

  @override
  String get settingsAiProviderBody =>
      'टैगिंग और इमेज के लिए अपना मॉडल उपयोग करें';

  @override
  String get settingsAppVersion => 'ऐप वर्ज़न';

  @override
  String get settingsPrivacyTerms => 'गोपनीयता और शर्तें';

  @override
  String get settingsReportProblem => 'समस्या की रिपोर्ट करें';

  @override
  String get settingsChangePassword => 'पासवर्ड बदलें';

  @override
  String get settingsExportData => 'अपना डेटा एक्सपोर्ट करें';

  @override
  String get settingsExportBody =>
      'हम आपके द्वारा सहेजी गई हर चीज़ के साथ एक फ़ाइल तैयार करेंगे और डाउनलोड खोलेंगे।';

  @override
  String get settingsExportAction => 'एक्सपोर्ट करें';

  @override
  String get settingsCurrentPassword => 'वर्तमान पासवर्ड';

  @override
  String get settingsNewPassword => 'नया पासवर्ड';

  @override
  String get settingsConfirmNewPassword => 'नया पासवर्ड कन्फर्म करें';

  @override
  String get settingsEnterCurrentPassword => 'अपना वर्तमान पासवर्ड दर्ज करें';

  @override
  String get settingsEnterNewPassword => 'नया पासवर्ड दर्ज करें';

  @override
  String get settingsPasswordMin8 => 'कम से कम 8 अक्षर उपयोग करें';

  @override
  String get settingsPasswordNeedsUpper => 'एक बड़ा अक्षर जोड़ें';

  @override
  String get settingsPasswordNeedsLower => 'एक छोटा अक्षर जोड़ें';

  @override
  String get settingsPasswordNeedsDigit => 'एक अंक जोड़ें';

  @override
  String get settingsPasswordsNoMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get settingsChangeAction => 'बदलें';

  @override
  String get itemAddSnapTitle => 'फोटो लें';

  @override
  String get itemAddSnapBody =>
      'हम फोटो में मौजूद हर पीस को ढूंढकर उसकी साफ स्टूडियो फोटो बना देंगे।';

  @override
  String get itemAddCamera => 'फोटो खींचें';

  @override
  String get itemAddGallery => 'गैलरी से चुनें';

  @override
  String get itemAddOtherWays => 'जोड़ने के अन्य तरीके';

  @override
  String get itemAddSeveral => 'कई फोटो जोड़ें';

  @override
  String get itemAddSeveralBody => 'एक बार में 50 तक';

  @override
  String get itemAddImportProfile => 'प्रोफ़ाइल से इम्पोर्ट करें';

  @override
  String get itemAddImportProfileBody => 'Instagram या Facebook';

  @override
  String get itemAddEnterDetails => 'विवरण खुद दर्ज करें';

  @override
  String get itemAddEnterDetailsBody => 'फोटो की आवश्यकता नहीं';

  @override
  String get itemManualIntro =>
      'केवल नाम की आवश्यकता है। बाकी जानकारी अभी या बाद में जोड़ें।';

  @override
  String get itemManualNameHint => 'उदाहरण के लिए, नीली कॉटन टी-शर्ट';

  @override
  String get itemManualEnterName => 'नाम दर्ज करें';

  @override
  String get itemManualNotes => 'नोट्स';

  @override
  String get itemManualBrand => 'ब्रांड';

  @override
  String get itemManualSize => 'साइज';

  @override
  String get itemManualEnterNumber => 'संख्या दर्ज करें';

  @override
  String get itemManualSavePiece => 'पीस सेव करें';

  @override
  String get itemManualSaving => 'सेव हो रहा है';

  @override
  String get itemManualSavedTitle => 'सेव किया गया';

  @override
  String itemManualSavedBody(String name) {
    return '$name आपके क्लोसेट में है।';
  }

  @override
  String get itemManualNotSaved => 'सेव नहीं हुआ';

  @override
  String get itemManualAddUseCase => 'उपयोग का मामला जोड़ें';

  @override
  String get itemManualAddUseCaseAction => 'उपयोग जोड़ें';

  @override
  String get itemPhotos => 'फोटो';

  @override
  String get itemAddPhotos => 'फोटो जोड़ें';

  @override
  String get itemNoPhotoYet =>
      'अभी कोई फोटो नहीं। आप बिना फोटो के भी सेव कर सकते हैं।';

  @override
  String get itemRemovePhoto => 'फोटो हटाएं';

  @override
  String get itemRemovePiece => 'पीस हटाएं';

  @override
  String get filterConditionLabel => 'स्थिति';

  @override
  String get photoshootStepPhotos => 'फोटो';

  @override
  String get photoshootStepSetup => 'सेटअप';

  @override
  String get photoshootStepCreating => 'बनाया जा रहा है';

  @override
  String get photoshootStepResults => 'परिणाम';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'चरण $current का $total, $name';
  }

  @override
  String get photoshootOneFailed => 'एक फोटो विफल रही। नीचे पुनः प्रयास करें।';

  @override
  String photoshootManyFailed(int count) {
    return '$count फोटो विफल रहीं। नीचे प्रत्येक का पुनः प्रयास करें।';
  }

  @override
  String get photoshootFormat => 'प्रारूप';

  @override
  String get photoshootHowMany => 'कितनी';

  @override
  String get photoshootYourPrompt => 'आपका प्रॉम्प्ट';

  @override
  String get photoshootPromptHint => 'छत पर गोल्डन आवर, लिनन शर्ट';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो बनाएं',
      one: '1 फोटो बनाएं',
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
  String get photoshootLimitUnknown => 'हम आज की सीमा की जांच नहीं कर सके।';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan प्लान: आज $remaining में से $limit शेष';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'फ्री';

  @override
  String get photoshootGallery => 'गैलरी';

  @override
  String get photoshootUseCamera => 'कैमरा उपयोग करें';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'फोटो $number हटाएं';
  }

  @override
  String get photoshootNoPhotosTitle => 'कोई फोटो नहीं मिली';

  @override
  String get photoshootNoPhotosBody =>
      'शूट बिना किसी इमेज के समाप्त हुआ। पुनः प्रयास करें।';

  @override
  String get photoshootNewStyle => 'नई स्टाइल';

  @override
  String get photoshootNewPhotos => 'नई फोटो';

  @override
  String photoshootOpenPhoto(int number) {
    return 'फोटो $number खोलें';
  }

  @override
  String get photoshootReportPhoto => 'फोटो रिपोर्ट करें';

  @override
  String get photoshootSaveToGallery => 'गैलरी में सहेजें';

  @override
  String get actionUpgrade => 'अपग्रेड';

  @override
  String get referralLimitTitle => 'आपने आज की फोटो का उपयोग कर लिया है';

  @override
  String get referralLimitBody =>
      'आपकी फ्री फोटो कल वापस आ जाएंगी। किसी मित्र को रेफर करें और आप दोनों को एक महीने का Pro फ्री मिलेगा।';

  @override
  String get referralLimitRefer => 'मित्र को रेफर करें';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'डेटिंग ऐप';

  @override
  String get photoshootUsePortfolio => 'पोर्टफोलियो';

  @override
  String get photoshootUseInstagram => 'इंस्टाग्राम';

  @override
  String get photoshootUseAesthetic => 'एस्थेटिक';

  @override
  String get photoshootUseCustom => 'अपना प्रॉम्प्ट';

  @override
  String get photoshootDescLinkedin => 'काम के लिए प्रोफेशनल फोटो';

  @override
  String get photoshootDescDating => 'रिलैक्स्ड और नेचुरल लुक';

  @override
  String get photoshootDescPortfolio => 'एडिटोरियल, हाई-फैशन लुक';

  @override
  String get photoshootDescInstagram => 'सोशल मीडिया के लिए लाइफस्टाइल';

  @override
  String get photoshootDescAesthetic => 'मूडी, आर्टिस्टिक फ्रेम';

  @override
  String get photoshootDescCustom => 'अपना मनचाहा लुक बताएं';

  @override
  String get aspectSquare => 'वर्गाकार';

  @override
  String get aspectPortrait => 'पोर्ट्रेट';

  @override
  String get aspectLandscape => 'लैंडस्केप';

  @override
  String get aspectTall => 'लंबा';

  @override
  String get aspectWide => 'चौड़ा';

  @override
  String get tryOnAppBar => 'वर्चुअल ट्राई-ऑन';

  @override
  String get tryOnYourPhoto => 'आपकी फोटो';

  @override
  String get tryOnGarment => 'कपड़ा';

  @override
  String get tryOnUploadingPhoto => 'फोटो अपलोड हो रही है';

  @override
  String get tryOnAddPhotoPrompt => 'अपनी फुल-बॉडी फोटो जोड़ें';

  @override
  String get tryOnBodyPhotoHint => 'फुल-बॉडी फोटो सबसे अच्छी रहती है';

  @override
  String get tryOnAddPhoto => 'फोटो जोड़ें';

  @override
  String get tryOnChangePhoto => 'फोटो बदलें';

  @override
  String get tryOnPhotoLoadFailed => 'हम आपकी फोटो लोड नहीं कर सके';

  @override
  String get tryOnChooseGarment => 'कपड़े की फोटो चुनें';

  @override
  String get tryOnChooseOneGarment => 'कपड़े की एक फोटो चुनें';

  @override
  String get tryOnGarmentHint => 'फ्लैट ले या हैंगर शॉट सबसे अच्छा रहता है';

  @override
  String get tryOnChange => 'बदलें';

  @override
  String get tryOnCamera => 'कैमरा';

  @override
  String get tryOnRemove => 'हटाएं';

  @override
  String get tryOnLookTitle => 'लुक';

  @override
  String get tryOnStyle => 'स्टाइल';

  @override
  String get tryOnBackground => 'बैकग्राउंड';

  @override
  String get tryOnPose => 'पोज़';

  @override
  String get tryOnDressingUp => 'तैयार कर रहे हैं। इसमें लगभग आधा मिनट लगेगा।';

  @override
  String get tryOnEmptyResult => 'आपका ट्राई-ऑन यहाँ दिखेगा';

  @override
  String get tryOnReportImage => 'इमेज रिपोर्ट करें';

  @override
  String get tryOnCreating => 'बना रहे हैं';

  @override
  String get tryOnTryAgain => 'फिर से कोशिश करें';

  @override
  String get tryOnCreate => 'ट्राई-ऑन बनाएं';

  @override
  String get tryOnBackgroundStudioWhite => 'स्टूडियो व्हाइट';

  @override
  String get tryOnBackgroundStudioGrey => 'स्टूडियो ग्रे';

  @override
  String get tryOnBackgroundUrban => 'अर्बन स्ट्रीट';

  @override
  String get tryOnBackgroundNature => 'नेचर';

  @override
  String get tryOnBackgroundMinimal => 'मिनिमल';

  @override
  String get tryOnPoseFront => 'सामने खड़े होना';

  @override
  String get tryOnPoseSide => 'साइड में खड़े होना';

  @override
  String get tryOnPoseWalking => 'चलना';

  @override
  String get dashboardGreetingMorning => 'सुप्रभात';

  @override
  String get dashboardGreetingAfternoon => 'शुभ दोपहर';

  @override
  String get dashboardGreetingEvening => 'शुभ संध्या';

  @override
  String get dashboardWelcome => 'स्वागत है';

  @override
  String get dashboardOpenProfile => 'प्रोफ़ाइल खोलें';

  @override
  String get dashboardRailToday => 'आज';

  @override
  String get dashboardRailRecently => 'हाल ही में';

  @override
  String get dashboardActivityEmpty => 'नए कपड़े और आउटफिट यहाँ दिखेंगे।';

  @override
  String get quickAddPiece => 'कपड़ा जोड़ें';

  @override
  String get quickAddPieceBody => 'फोटो लें और टैग करें';

  @override
  String get quickBuildOutfit => 'आउटफिट बनाएं';

  @override
  String get quickBuildOutfitBody => 'अपने कपड़े मिलाएं';

  @override
  String get quickForYou => 'आपके लिए';

  @override
  String get quickForYouBody => 'आज के सुझाव';

  @override
  String get quickPlanWeek => 'हफ़्ते की योजना';

  @override
  String get quickPlanWeekBody => 'तारीख के अनुसार ऑउटफिट';

  @override
  String get referralBannerUrgent =>
      'क्रेडिट खत्म हो रहे हैं? दोस्त को आमंत्रित करें।';

  @override
  String get referralBannerTitle => 'एक महीना दें, एक महीना पाएं।';

  @override
  String get referralBannerBody =>
      'आपको और आपके दोस्त को Pro का एक महीना मिलेगा।';

  @override
  String get referralBannerDismiss => 'एक हफ़्ते के लिए हटाएं';

  @override
  String get referralBannerShare => 'आमंत्रण साझा करें';

  @override
  String get referralBannerCopy => 'लिंक कॉपी करें';

  @override
  String get itemEditPieceTitle => 'पीस एडिट करें';

  @override
  String get itemEditDescriptionLabel => 'विवरण';

  @override
  String get itemEditNotSaved => 'सेव नहीं हुआ';

  @override
  String get itemEditSavedTitle => 'सेव हो गया';

  @override
  String get itemEditSavedBody => 'आपके बदलाव सेव कर लिए गए हैं।';

  @override
  String get itemEditSavedStalePhotos =>
      'सेव किया गया — फोटो पुरानी हो सकती हैं';

  @override
  String get itemEditRemovePieceHint => 'इस पीस को आइटम पेज से हटाएं।';

  @override
  String get itemEditNoPhotos =>
      'अभी कोई फोटो नहीं है। गैलरी या कैमरे से जोड़ें।';

  @override
  String get itemEditKeepPhoto => 'फोटो रखें';

  @override
  String get itemEditRemoved => 'हटा दिया गया';

  @override
  String get itemEditAddUseCaseAction => 'जोड़ें';

  @override
  String get statsNoStatsTitle => 'अभी कोई आँकड़े नहीं';

  @override
  String get statsNoStatsBody =>
      'कुछ पीस जोड़ें और आपका क्लोसेट मिक्स यहाँ दिखेगा।';

  @override
  String get statsByCategory => 'श्रेणी के अनुसार';

  @override
  String get statsTotalValue => 'कुल मूल्य';

  @override
  String get statsMostWorn => 'सबसे ज़्यादा पहने गए';

  @override
  String get statsLeastWorn => 'बारी का इंतज़ार';

  @override
  String get statsUnnamedPiece => 'बिना नाम का पीस';

  @override
  String get jobsTitle => 'स्कैन';

  @override
  String get jobsEmptyTitle => 'अभी तक कोई स्कैन नहीं';

  @override
  String get jobsEmptyBody =>
      'एक फोटो लें और उसे बैकग्राउंड में भेजें — यह यहाँ काम करता रहेगा।';

  @override
  String get jobsNotCancelled => 'रद्द नहीं किया गया';

  @override
  String get jobsResume => 'फिर से शुरू करें';

  @override
  String get jobsReview => 'समीक्षा करें';

  @override
  String get jobsStop => 'रोकें';

  @override
  String get jobsDismiss => 'हटाएं';

  @override
  String get reportTitle => 'कंटेंट रिपोर्ट करें';

  @override
  String reportIntro(String contentType) {
    return 'हमें बताएं कि इस $contentType में क्या गलत है। हमारी टीम हर रिपोर्ट की समीक्षा करती है।';
  }

  @override
  String get reportReasonInappropriate => 'अनुचित या आपत्तिजनक';

  @override
  String get reportReasonNudity => 'नग्नता या यौन सामग्री';

  @override
  String get reportReasonHarassment => 'उत्पीड़न या दुर्व्यवहार';

  @override
  String get reportReasonImpersonation => 'किसी और का रूप धारण करना';

  @override
  String get reportReasonOther => 'अन्य';

  @override
  String get reportDetailsLabel => 'अतिरिक्त विवरण (वैकल्पिक)';

  @override
  String get reportSubmit => 'रिपोर्ट सबमिट करें';

  @override
  String get reportSubmittedTitle => 'रिपोर्ट सबमिट की गई';

  @override
  String get reportSubmittedBody =>
      'धन्यवाद। हमारी टीम इस कंटेंट की समीक्षा करेगी।';

  @override
  String get reportFailedTitle => 'रिपोर्ट नहीं भेजी जा सकी';

  @override
  String get reportFailedBody => 'कृपया पुनः प्रयास करें।';

  @override
  String get reportContentTryOnImage => 'AI ट्राई-ऑन इमेज';

  @override
  String get reportContentSharedOutfit => 'शेयर की गई आउटफिट';

  @override
  String get reportContentPhotoshootImage => 'AI फोटोशूट इमेज';

  @override
  String get sharedOutfitTitle => 'साझा की गई पोशाक';

  @override
  String get sharedOutfitHideTooltip => 'इस पोशाक को छिपाएं';

  @override
  String get sharedOutfitReportTooltip => 'इस पोशाक की रिपोर्ट करें';

  @override
  String get sharedOutfitHideTitle => 'इस पोशाक को छिपाएं?';

  @override
  String get sharedOutfitHideBody =>
      'यह इस डिवाइस पर छिपी रहेगी। आप इसकी रिपोर्ट भी कर सकते हैं ताकि हमारी टीम इसकी समीक्षा कर इसे हटा सके।';

  @override
  String get sharedOutfitHideAction => 'छिपाएं';

  @override
  String get sharedOutfitHiddenInfo => 'यह पोशाक अब इस डिवाइस पर नहीं दिखेगी।';

  @override
  String get sharedOutfitHiddenToast => 'पोशाक छिपाई गई';

  @override
  String get sharedOutfitMissingTitle => 'यह पोशाक अब यहाँ नहीं है';

  @override
  String get sharedOutfitMissingBody =>
      'हो सकता है इसे हटा दिया गया हो, या लिंक गलत हो।';

  @override
  String get sharedOutfitHiddenStateTitle => 'आपने इस पोशाक को छिपाया है';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'यदि यह आपत्तिजनक थी, तो गोपनीयता और शर्तों से इसकी रिपोर्ट करें या $email पर ईमेल करें।';
  }

  @override
  String get sharedOutfitCtaTitle => 'यह लुक पसंद आया?';

  @override
  String get sharedOutfitCtaBody => 'अपनी अलमारी से ऐसे ही आउटफिट बनाएं।';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'त्रुटि';

  @override
  String get errorUnknown => 'एक अज्ञात त्रुटि आई';

  @override
  String get errorNoConnection =>
      'कोई इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें।';

  @override
  String get errorTimeout =>
      'अनुरोध का समय समाप्त हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get errorServerError =>
      'हमारे सर्वर पर कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get errorBadGateway =>
      'हमारा सर्वर कुछ समय के लिए अनुपलब्ध है। कृपया पुनः प्रयास करें।';

  @override
  String get errorServiceUnavailable =>
      'सेवा अस्थायी रूप से अनुपलब्ध है। कृपया थोड़ी देर में पुनः प्रयास करें।';

  @override
  String get errorInternalError => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get errorUnauthorized => 'जारी रखने के लिए कृपया साइन इन करें।';

  @override
  String get errorForbidden => 'आपको इसकी अनुमति नहीं है।';

  @override
  String get errorSessionExpired =>
      'आपका सत्र समाप्त हो गया है। कृपया फिर से साइन इन करें।';

  @override
  String get errorInvalidCredentials => 'वह ईमेल या पासवर्ड सही नहीं है।';

  @override
  String get errorTokenRefreshFailed =>
      'हम आपका सत्र रीफ्रेश नहीं कर सके। कृपया फिर से साइन इन करें।';

  @override
  String get errorRequestCancelled => 'अनुरोध रद्द कर दिया गया।';

  @override
  String get errorInvalidFormat => 'फ़ाइल का वह प्रारूप समर्थित नहीं है।';

  @override
  String get errorFileTooLarge => 'वह फ़ाइल बहुत बड़ी है।';

  @override
  String get errorUploadFailed => 'अपलोड विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get errorCacheCorrupted =>
      'सहेजा गया डेटा क्षतिग्रस्त हो गया था और रीसेट कर दिया गया है।';

  @override
  String get errorCacheNotFound => 'अभी तक कुछ भी सहेजा नहीं गया है।';

  @override
  String get errorUserNotFound => 'हमें वह खाता नहीं मिला।';

  @override
  String get errorItemNotFound => 'वह आइटम अब मौजूद नहीं है।';

  @override
  String get errorOutfitNotFound => 'वह आउटफिट अब मौजूद नहीं है।';

  @override
  String get rewardsTitle => 'रिवार्ड्स';

  @override
  String get rewardsNoAchievementsTitle => 'अभी तक कोई उपलब्धि नहीं';

  @override
  String get rewardsNoAchievementsBody =>
      'अपनी पहली उपलब्धि पाने के लिए पीस जोड़ें और आउटफिट प्लान करें।';

  @override
  String get rewardsEmptyLeaderboardTitle => 'बोर्ड पर अभी कोई नहीं है';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'अंक अर्जित करने और यहाँ दिखने के लिए आउटफिट प्लान करें।';

  @override
  String get legalViewPrivacyPolicy => 'गोपनीयता नीति देखें';

  @override
  String get aiConsentAgree => 'मैं सहमत हूँ और जारी रखें';

  @override
  String get aiConsentNotNow => 'अभी नहीं';

  @override
  String get imageViewerCloseTooltip => 'इमेज व्यूअर बंद करें';

  @override
  String get updateReadyTitle => 'अपडेट तैयार है';

  @override
  String get updateReadyBody =>
      'नवीनतम सुधार लागू करने के लिए FitCheck AI को रीस्टार्ट करें।';

  @override
  String get permissionCameraUsage =>
      'आपके आउटफ़िट और वॉर्डरोब की तस्वीरें लेने के लिए FitCheck AI को कैमरा एक्सेस चाहिए।';

  @override
  String get permissionPhotoLibraryUsage =>
      'आपके आउटफ़िट और वॉर्डरोब की तस्वीरें चुनने के लिए FitCheck AI को फोटो लाइब्रेरी एक्सेस चाहिए।';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI को आपकी AI-जनरेटेड आउटफ़िट तस्वीरें आपकी फोटो लाइब्रेरी में सहेजनी होंगी।';

  @override
  String get wardrobeSomePhotosSkipped => 'कुछ तस्वीरें छोड़ दी गईं';

  @override
  String get wardrobePhotosNotAdded => 'तस्वीरें नहीं जोड़ी गईं';

  @override
  String get wardrobePhotoNotAdded => 'तस्वीर नहीं जोड़ी गई';

  @override
  String get wardrobeNotStartedTitle => 'शुरू नहीं हुआ';

  @override
  String get wardrobeNoRoomTitle => 'जगह नहीं है';

  @override
  String get wardrobeAddPhotosSemantic => 'तस्वीरें जोड़ें';

  @override
  String get batchAddTileLabel => 'जोड़ें';

  @override
  String get batchProfileLinkLabel => 'प्रोफाइल लिंक';

  @override
  String get wardrobeImportFromProfileTitle => 'प्रोफाइल से इंपोर्ट करें';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'कई तस्वीरें जोड़ें';

  @override
  String get wardrobeClearAction => 'साफ़ करें';

  @override
  String get wardrobeRefreshTooltip => 'रिफ्रेश करें';

  @override
  String get batchNoPhotosYetTitle => 'अभी कोई तस्वीर नहीं है';

  @override
  String get batchChoosePhotosAction => 'तस्वीरें चुनें';

  @override
  String get batchWeFindEachPieceBody =>
      'हम हर पीस को खोजते हैं और उसकी स्टूडियो फोटो बनाते हैं।';

  @override
  String get batchPreparingPhotosSemantic => 'तस्वीरें तैयार की जा रही हैं';

  @override
  String get batchPhotosProcessedSemantic => 'तस्वीरें प्रोसेस हो चुकी हैं';

  @override
  String get batchPasteProfileLinkTitle => 'प्रोफाइल लिंक पेस्ट करें';

  @override
  String get batchPasteProfileLinkBody =>
      'एक पब्लिक Instagram या Facebook प्रोफाइल। हम इसकी तस्वीरें स्कैन करते हैं, और आप चुनते हैं कि आपकी क्लोसेट में क्या जाएगा।';

  @override
  String get batchClearLinkTooltip => 'लिंक साफ़ करें';

  @override
  String get batchStartingButton => 'शुरू हो रहा है';

  @override
  String get batchStartImportAction => 'इंपोर्ट शुरू करें';

  @override
  String get batchReviewEveryPhotoTitle => 'आप हर तस्वीर की समीक्षा करते हैं';

  @override
  String get batchReviewEveryPhotoBody =>
      'आपके द्वारा स्वीकृत किए बिना कुछ भी नहीं जोड़ा जाता है।';

  @override
  String get batchPrivateProfilesTitle => 'प्राइवेट प्रोफ़ाइल';

  @override
  String get batchPrivateProfilesBody =>
      'अपना अकाउंट कनेक्ट करें। Instagram के लिए यूज़रनेम और पासवर्ड भी चाहिए।';

  @override
  String get batchUseAnotherLinkAction => 'दूसरा लिंक इस्तेमाल करें';

  @override
  String get batchSignInNeededTitle => 'साइन-इन ज़रूरी है';

  @override
  String get batchEnterYourCodeTitle => 'अपना कोड दर्ज करें';

  @override
  String get batchUseUsernamePasswordAction =>
      'यूज़रनेम और पासवर्ड इस्तेमाल करें';

  @override
  String get batchAlreadyConnectedAction =>
      'मैंने ब्राउज़र में कनेक्ट कर लिया है';

  @override
  String get batchEnterCodeAction => 'कोड दर्ज करें';

  @override
  String get batchTryAnotherWayAction => 'दूसरा तरीका आज़माएं';

  @override
  String get batchLiveStatus => 'लाइव';

  @override
  String get batchReconnectingStatus => 'दुबारा कनेक्ट हो रहा है';

  @override
  String get batchSignInToInstagramTitle => 'Instagram में साइन इन करें';

  @override
  String get batchUsernameLabel => 'यूज़रनेम';

  @override
  String get batchCodeIfTwoStepLabel =>
      'कोड, यदि आप टू-स्टेप साइन-इन का उपयोग करते हैं';

  @override
  String get batchAuthenticatorCodeBody =>
      'अपने ऑथेंटिकेटर ऐप से 6-अंकों का कोड इस्तेमाल करें। कोड तेज़ी से बदलते हैं।';

  @override
  String get batchVerifyAction => 'सत्यापित करें';

  @override
  String get batchFindingPhotosTitle => 'फ़ोटो खोजी जा रही हैं';

  @override
  String get batchImportPausedTitle => 'आयात रोक दिया गया है';

  @override
  String get batchProcessingPhotosTitle => 'फ़ोटो प्रोसेस हो रही हैं';

  @override
  String get batchWaitingNextPhoto => 'अगली फ़ोटो का इंतज़ार है';

  @override
  String get batchCancelImportAction => 'आयात रद्द करें';

  @override
  String get batchNoPiecesInPhotoBody => 'इस फ़ोटो में कोई पीस नहीं मिला।';

  @override
  String get batchEditPieceColoursLabel => 'रंग, अल्पविराम से अलग किए गए';

  @override
  String get batchAddToClosetAction => 'क्लोसेट में जोड़ें';

  @override
  String get batchSkipPhotoAction => 'यह फ़ोटो छोड़ें';

  @override
  String get batchImportCompleteTitle => 'आयात पूरा हुआ';

  @override
  String get batchImportFailedTitle => 'आयात विफल';

  @override
  String get batchImportCancelledTitle => 'आयात रद्द कर दिया गया';

  @override
  String get batchImportErrorBody => 'आयात करते समय कुछ गलत हो गया।';

  @override
  String get batchNothingMoreImportedBody =>
      'इस प्रोफ़ाइल से और कुछ आयात नहीं किया गया है।';

  @override
  String get batchViewClosetAction => 'क्लोसेट देखें';

  @override
  String get batchStartOverAction => 'फिर से शुरू करें';

  @override
  String get wardrobeAddPieceTitle => 'आइटम जोड़ें';

  @override
  String get wardrobeAddDetailsTitle => 'विवरण जोड़ें';

  @override
  String get wardrobeScanningTitle => 'स्कैन हो रहा है';

  @override
  String get batchReviewPiecesTitle => 'आइटम देखें';

  @override
  String get wardrobeGalleryAction => 'गैलरी';

  @override
  String get wardrobeCameraAction => 'कैमरा';

  @override
  String get wardrobeNewBadge => 'नया';

  @override
  String get wardrobeRemovePhotoTooltip => 'फोटो हटाएं';

  @override
  String get batchRunInBackgroundTooltip => 'बैकग्राउंड में चलाएं';

  @override
  String get batchStepOneOfTwo => 'चरण 1 का 2';

  @override
  String get batchStepTwoOfTwo => 'चरण 2 का 2';

  @override
  String get batchUploadingPhotosTitle => 'फोटो अपलोड हो रही हैं';

  @override
  String get batchFindingPiecesTitle => 'आइटम खोजे जा रहे हैं';

  @override
  String get batchMakingStudioPhotosTitle => 'स्टूडियो फोटो बन रही हैं';

  @override
  String get batchStoppedLabel => 'रुका हुआ';

  @override
  String get batchFindingPiecesStoppedTitle => 'आइटम खोजना रुक गया';

  @override
  String get batchCancelledLabel => 'रद्द किया गया';

  @override
  String get batchAllDoneTitle => 'हो गया';

  @override
  String get batchOpeningPiecesBody => 'आपके आइटम खुल रहे हैं';

  @override
  String get batchNothingSavedBody => 'कुछ भी सेव नहीं हुआ।';

  @override
  String get batchFindingPiecesFailedBody => 'आइटम खोजना असफल रहा।';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'आइटम खोजना पहले ही रुक गया।';

  @override
  String get batchStopFindingPiecesTitle => 'आइटम खोजना बंद करें?';

  @override
  String get batchStopFindingPiecesBody =>
      'स्कैन रुक जाएगा और कुछ भी सेव नहीं होगा। जो आइटम मिल चुके हैं वे हटाने तक गतिविधि में रहेंगे।';

  @override
  String get batchKeepGoingAction => 'जारी रखें';

  @override
  String get batchTryAgainAction => 'फिर कोशिश करें';

  @override
  String get batchBackToPhotosAction => 'फोटो पर वापस जाएं';

  @override
  String get batchSkipAllAction => 'सभी छोड़ें';

  @override
  String get batchIncludeAllAction => 'सभी शामिल करें';

  @override
  String get batchNoPiecesFoundTitle => 'कोई कपड़े नहीं मिले';

  @override
  String get batchNoPiecesFoundBody =>
      'हमें इन तस्वीरों में कोई कपड़े नहीं मिले।';

  @override
  String get batchChooseOtherPhotosAction => 'दूसरी तस्वीरें चुनें';

  @override
  String get batchUseCaseHelper =>
      'आपके द्वारा सहेजे गए हर कपड़े में जोड़ा गया।';

  @override
  String get batchDiscardPiecesTitle => 'ये कपड़े हटाएं?';

  @override
  String get batchDiscardPiecesBody => 'इस बैच से कुछ भी सहेजा नहीं गया है।';

  @override
  String get batchKeepAction => 'रखें';

  @override
  String get batchDiscardAction => 'हटाएं';

  @override
  String get batchRemovePieceTitle => 'इस कपड़े को हटाएं?';

  @override
  String get batchRemovePieceBody => 'यह आपकी अलमारी में सहेजा नहीं गया है।';

  @override
  String get batchRemoveAction => 'हटाएं';

  @override
  String get batchChoosePiecesToSave => 'सहेजने के लिए कपड़े चुनें';

  @override
  String get batchDiscardAllAction => 'सभी हटाएं';

  @override
  String get batchNothingSavedRetryBody =>
      'कुछ भी सहेजा नहीं गया। पुनः प्रयास करें।';

  @override
  String get batchNotSavedTitle => 'सहेजा नहीं गया';

  @override
  String get batchSavingLabel => 'सहेजा जा रहा है';

  @override
  String get batchSendToBackgroundAction => 'बैकग्राउंड में भेजें';

  @override
  String get batchStillWorkingMessage =>
      'काम जारी है। कपड़े तैयार होने पर हम आपको बता देंगे।';

  @override
  String get batchRunningInBackgroundTitle => 'बैकग्राउंड में चल रहा है';

  @override
  String get batchStudioPhotosStoppedBody =>
      'स्टूडियो तस्वीरें समय से पहले रुक गईं। आप अभी भी इन्हें सहेज सकते हैं।';

  @override
  String get batchTapPieceToSkip => 'छोड़ने के लिए किसी कपड़े पर टैप करें।';

  @override
  String get batchStudioPhotosOnWayBody =>
      'स्टूडियो तस्वीरें आ रही हैं। आप जा सकते हैं—हम आपको बता देंगे।';

  @override
  String get batchLeaveAction => 'छोड़ें';

  @override
  String get batchPeopleInPhotosTitle => 'तस्वीरों में लोग';

  @override
  String get batchIncludeAction => 'शामिल करें';

  @override
  String get batchSkipAction => 'छोड़ें';

  @override
  String get batchYourPhotoIsUsedLabel => 'आपकी तस्वीर का उपयोग किया गया है';

  @override
  String get batchMakingStudioPhotoLabel => 'स्टूडियो फोटो बन रही है';

  @override
  String get batchNoStudioPhotoBody =>
      'कोई स्टूडियो फोटो नहीं। आपकी फोटो का उपयोग किया गया है।';

  @override
  String get batchEnterDetailsYourselfAction => 'विवरण खुद दर्ज करें';

  @override
  String get batchChooseAnotherPhotoAction => 'दूसरी फोटो चुनें';

  @override
  String get batchConnectionLostTitle => 'कनेक्शन टूट गया';

  @override
  String get batchConnectionLostBody =>
      'अपना कनेक्शन जांचें और फिर से कोशिश करें।';

  @override
  String get batchDailyLimitTitle => 'दैनिक सीमा समाप्त';

  @override
  String get batchDailyLimitBodyPaywall =>
      'अधिक स्कैन के लिए Pro पर अपग्रेड करें या विवरण खुद दर्ज करें।';

  @override
  String get batchDailyLimitBodyFree =>
      'आपके स्कैन कल रीसेट होंगे। आप अभी विवरण खुद दर्ज कर सकते हैं।';

  @override
  String get batchSeePlansAction => 'प्लान देखें';

  @override
  String get batchAiBusyTitle => 'हमारा AI व्यस्त है';

  @override
  String get batchAiBusyBody =>
      'यह हमारी ओर से है। कुछ मिनट बाद फिर कोशिश करें।';

  @override
  String get batchNoPiecesBody => 'साफ फोटो आज़माएं या विवरण खुद दर्ज करें।';

  @override
  String get batchScanningUnavailableTitle => 'स्कैनिंग उपलब्ध नहीं है';

  @override
  String get batchScanningUnavailableBody => 'फिलहाल विवरण खुद दर्ज करें।';

  @override
  String get batchScanDidNotFinishTitle => 'स्कैन पूरा नहीं हुआ';

  @override
  String get batchTryAgainBody => 'फिर से कोशिश करें।';

  @override
  String get billingTitle => 'सदस्यता';

  @override
  String get billingUpgradeHeading => 'अपना प्लान अपग्रेड करें';

  @override
  String get billingUpgradeOnPlusBody => 'वही फीचर्स, उच्च सीमाएं।';

  @override
  String get billingUpgradeBody =>
      'Plus और Pro में एक जैसे फीचर्स हैं। अपनी जरूरत की सीमा चुनें।';

  @override
  String get billingWebUnavailableBody =>
      'ऑनलाइन अपग्रेड अभी उपलब्ध नहीं है। प्रोमो या रेफरल कोड से Plus या Pro अनलॉक हो जाता है। मुफ्त महीने पाने के लिए दोस्तों को आमंत्रित करें।';

  @override
  String get billingPlansStale =>
      'नवीनतम प्लान लोड नहीं हो सके। कीमतें पुरानी हो सकती हैं।';

  @override
  String get billingMonthly => 'मासिक';

  @override
  String get billingYearly => 'वार्षिक';

  @override
  String get billingCurrentPlan => 'वर्तमान प्लान';

  @override
  String get billingActive => 'सक्रिय';

  @override
  String get billingThisMonth => 'इस महीने';

  @override
  String get billingItemExtractions => 'आइटम निष्कर्षण';

  @override
  String get billingOutfitVisualizations => 'आउटफिट विजुअलाइजेशन';

  @override
  String get billingNearLimitUpgrade =>
      'आप इस महीने की सीमा के करीब हैं। अधिक के लिए अपग्रेड करें।';

  @override
  String get billingNearLimitResets =>
      'आप इस महीने की सीमा के करीब हैं। यह अगले महीने की शुरुआत में रीसेट होगी।';

  @override
  String get billingStoreUnavailable =>
      'अपग्रेड अभी स्टोर पर उपलब्ध नहीं हैं। जल्द ही दोबारा देखें।';

  @override
  String get billingManageHeading => 'अपना प्लान मैनेज करें';

  @override
  String get billingCancelPlan => 'सदस्यता रद्द करें';

  @override
  String get billingCancelKeepsAccess =>
      'इस बिलिंग अवधि के अंत तक आपकी पहुँच बनी रहेगी।';

  @override
  String get billingCancelConfirmTitle => 'अपनी सदस्यता रद्द करें?';

  @override
  String get billingKeepPlan => 'प्लान जारी रखें';

  @override
  String get billingCancelPlanAction => 'प्लान रद्द करें';

  @override
  String get billingBilledMonthly => 'मासिक बिल';

  @override
  String get billingBilledYearly => 'वार्षिक बिल';

  @override
  String get billingVirtualTryOn => 'वर्चुअल ट्राई-ऑन';

  @override
  String get billingPrioritySupport => 'प्राथमिकता सहायता';

  @override
  String get billingDisclosureProRenewing => 'Pro एक स्वतः-नवीनीकरण सदस्यता है';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus और Pro स्वतः-नवीनीकरण सदस्यताएँ हैं';

  @override
  String get billingDisclosureAppleBilling =>
      'खरीद की पुष्टि होने पर भुगतान आपके Apple ID से लिया जाता है।';

  @override
  String get billingDisclosureGoogleBilling =>
      'खरीद की पुष्टि होने पर भुगतान आपके Google Play खाते से लिया जाता है।';

  @override
  String get billingDisclosureRenewalTerms =>
      'आपकी सदस्यता वर्तमान अवधि समाप्त होने से कम से कम 24 घंटे पहले स्वतः-नवीनीकरण बंद न करने पर उसी कीमत पर उसी अवधि के लिए स्वतः नवीनीकृत हो जाती है।';

  @override
  String get billingDisclosureAppleManage =>
      'Settings › your Apple ID › Subscriptions में किसी भी समय मैनेज या रद्द करें।';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play › Payments and subscriptions में किसी भी समय मैनेज या रद्द करें।';

  @override
  String get billingReferFriend => 'किसी मित्र को रेफर करें';

  @override
  String get billingHowItWorks => 'यह कैसे काम करता है';

  @override
  String get billingHowShareTitle => 'अपना लिंक शेयर करें';

  @override
  String get billingHowShareBody => 'इसे किसी मित्र को भेजें।';

  @override
  String get billingHowSignUpTitle => 'वे साइन अप करते हैं';

  @override
  String get billingHowSignUpBody => 'आपका मित्र लिंक से जुड़ता है।';

  @override
  String get billingHowBothTitle => 'आप दोनों को Pro मिलता है';

  @override
  String get billingHowBothBody =>
      'आप में से प्रत्येक को Pro का एक महीना मुफ्त मिलता है।';

  @override
  String get billingYourReferrals => 'आपके रेफरल';

  @override
  String get billingInvited => 'आमंत्रित';

  @override
  String get billingJoined => 'शामिल हुए';

  @override
  String get billingMonthsEarned => 'अर्जित महीने';

  @override
  String get billingInviteFriend => 'मित्र को आमंत्रित करें';

  @override
  String get billingInviteBody =>
      'आपको और आपके मित्र दोनों को Pro का एक महीना मिलता है।';

  @override
  String get billingYourCode => 'आपका कोड';

  @override
  String get billingCopyLink => 'लिंक कॉपी करें';

  @override
  String get billingShareInvite => 'आमंत्रण शेयर करें';

  @override
  String get giftUnavailable => 'इस बिल्ड में गिफ्ट आमंत्रण उपलब्ध नहीं हैं।';

  @override
  String get giftPageTitle => 'FitCheck Pro गिफ्ट करें';

  @override
  String get giftNoAllowances => 'अभी कोई मुफ्त गिफ्ट आमंत्रण उपलब्ध नहीं है।';

  @override
  String get giftFormTitle => 'मुफ्त आमंत्रण भेजें';

  @override
  String get giftFormBody =>
      'प्राप्तकर्ता इस सत्यापित ईमेल से गिफ्ट प्राप्त करता है। हम आपकी ओर से ईमेल नहीं भेजते।';

  @override
  String get giftFieldFrom => 'प्रेषक';

  @override
  String get giftFieldRecipientName => 'प्राप्तकर्ता का नाम';

  @override
  String get giftFieldRecipientEmail => 'प्राप्तकर्ता का ईमेल';

  @override
  String get giftFieldOccasion => 'अवसर (वैकल्पिक)';

  @override
  String get giftNoOccasion => 'कोई अवसर नहीं';

  @override
  String get giftOccasionBirthday => 'जन्मदिन';

  @override
  String get giftOccasionAnniversary => 'सालगिरह';

  @override
  String get giftOccasionOther => 'अन्य';

  @override
  String get giftFieldCardGreeting => 'कार्ड संदेश';

  @override
  String get giftFieldCardGreetingHelper =>
      'यह कार्ड पर बिल्कुल वैसे ही दिखाई देता है जैसे लिखा गया है।';

  @override
  String get giftFieldPrivateNote => 'निजी नोट (वैकल्पिक)';

  @override
  String get giftCreateAction => 'मुफ्त गिफ्ट बनाएं';

  @override
  String get giftClaimedTitle => 'गिफ्ट प्राप्त हो गया';

  @override
  String get giftClaimedActive => 'आपका FitCheck Pro गिफ्ट सक्रिय है।';

  @override
  String get giftClaimedQueued =>
      'आपका FitCheck Pro गिफ्ट आपकी वर्तमान एक्सेस के बाद शुरू होगा।';

  @override
  String get giftLinkCopied => 'गिफ्ट लिंक क्लिपबोर्ड पर कॉपी हो गया।';

  @override
  String get giftErrorName => 'नाम दर्ज करें।';

  @override
  String get giftErrorEmail => 'मान्य ईमेल पता दर्ज करें।';

  @override
  String get giftErrorGreeting => 'कार्ड संदेश दर्ज करें।';

  @override
  String get giftErrorGreetingLength => '80 से अधिक वर्णों का उपयोग न करें।';

  @override
  String get giftClaimAction => 'गिफ्ट क्लेम करें';

  @override
  String get giftCardPreview => 'कार्ड पूर्वावलोकन';

  @override
  String get giftGiftForYou => 'आपके लिए एक गिफ्ट';

  @override
  String get giftGiftWaiting => 'एक गिफ्ट आपका इंतज़ार कर रहा है';

  @override
  String get giftOpenBody =>
      'अपने सत्यापित ईमेल से क्लेम करने के लिए अपने गिफ्ट खोलें।';

  @override
  String get giftOpenGifts => 'गिफ्ट खोलें';

  @override
  String get giftSendInvitation => 'निमंत्रण भेजें';

  @override
  String get settingsAiProviderSection => 'प्रदाता';

  @override
  String get settingsAiCustom => 'कस्टम';

  @override
  String get settingsAiUrlHelper =>
      'एक सार्वजनिक URL उपयोग करें जिसे सर्वर एक्सेस कर सके। लोकलहोस्ट हमारे सर्वर से काम नहीं करता।';

  @override
  String get settingsAiConnectionSection => 'कनेक्शन';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API कुंजी';

  @override
  String get settingsAiApiKeySaved =>
      'सहेजा गया। इसे वैसा ही रखने के लिए खाली छोड़ें।';

  @override
  String get settingsAiChatModel => 'चैट मॉडल';

  @override
  String get settingsAiVisionModel => 'विज़न मॉडल (वैकल्पिक)';

  @override
  String get settingsAiImageModel => 'इमेज मॉडल (वैकल्पिक)';

  @override
  String get settingsAiImageModelNote =>
      'इमेज जनरेशन के लिए response_modalities के साथ OpenAI-संगत चैट कम्प्लीशन चाहिए।';

  @override
  String get settingsAiTestConnection => 'कनेक्शन टेस्ट करें';

  @override
  String get calendarTitle => 'कैलेंडर';

  @override
  String get calendarGoToToday => 'आज पर जाएं';

  @override
  String get calendarConnectTooltip => 'कैलेंडर कनेक्ट करें';

  @override
  String get calendarAddEvent => 'इवेंट जोड़ें';

  @override
  String get calendarEmptyTitle => 'कुछ प्लांट नहीं है';

  @override
  String get calendarEmptyBody => 'एक इवेंट जोड़ें और तय करें क्या पहनना है।';

  @override
  String get calendarPreviousMonth => 'पिछला महीना';

  @override
  String get calendarNextMonth => 'अगला महीना';

  @override
  String get calendarAllDay => 'पूरा दिन';

  @override
  String get calendarOutfitLinked => 'आउटफिट लिंक किया गया';

  @override
  String get calendarEventOptions => 'इवेंट विकल्प';

  @override
  String get calendarDeleteTitle => 'क्या इस इवेंट को हटाएं?';

  @override
  String get calendarChangeOutfit => 'ऑउटफिट बदलें';

  @override
  String get calendarLinkOutfit => 'ऑउटफिट जोड़ें';

  @override
  String get calendarRemoveOutfit => 'ऑउटफिट हटाएं';

  @override
  String get calendarNewEvent => 'नया इवेंट';

  @override
  String get calendarEditEvent => 'इवेंट एडिट करें';

  @override
  String get calendarTitleLabel => 'शीर्षक';

  @override
  String get calendarTitleRequired => 'शीर्षक जोड़ें';

  @override
  String get calendarEndBeforeStart => 'शुरू होने के बाद समाप्त हो';

  @override
  String get calendarStarts => 'शुरू होता है';

  @override
  String get calendarEnds => 'समाप्त होता है';

  @override
  String get calendarPlaceOptional => 'स्थान (वैकल्पिक)';

  @override
  String get calendarNotesOptional => 'नोट्स (वैकल्पिक)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'एक ऑउटफिट बनाएं, फिर उसे इस इवेंट से जोड़ें।';

  @override
  String get calendarBuildOutfit => 'ऑउटफिट बनाएं';

  @override
  String get calendarConnectionsTitle => 'कैलेंडर';

  @override
  String get calendarConnectionsBody =>
      'आपके द्वारा जोड़े गए इवेंट FitCheck में रहते हैं।';

  @override
  String get calendarDisconnect => 'डिस्कनेक्ट करें';

  @override
  String get calendarNotAvailable => 'अभी उपलब्ध नहीं है';

  @override
  String get profileSectionExplore => 'एक्सप्लोर करें';

  @override
  String get profileNavTryOn => 'ट्राई-ऑन';

  @override
  String get profileNavRewards => 'रिवार्ड्स';

  @override
  String get profileSupport => 'सहायता';

  @override
  String get profileHelp => 'मदद';

  @override
  String get profileAbout => 'के बारे में';

  @override
  String get profileAboutBody => 'आपकी क्लोसेट, ऑउटफिट और प्लान एक ही जगह पर।';

  @override
  String get profileSignOutTitle => 'साइन आउट करें?';

  @override
  String get profileSignOutBody => 'आप किसी भी समय दोबारा साइन इन कर सकते हैं।';

  @override
  String get profileEditTitle => 'प्रोफ़ाइल एडिट करें';

  @override
  String get profileYourProfile => 'आपकी प्रोफ़ाइल';

  @override
  String get profileBodyProfiles => 'बॉडी प्रोफाइल';

  @override
  String get profileBodyEmptyTitle => 'अभी कोई बॉडी प्रोफाइल नहीं है';

  @override
  String get profileBodyEmptyBody =>
      'बेहतर फिट के लिए अपनी लंबाई और बनावट जोड़ें।';

  @override
  String get profileBodyAdd => 'प्रोफाइल जोड़ें';

  @override
  String get profileBodyDefaultNote =>
      'फिट और ट्राई-ऑन के लिए आपकी डिफ़ॉल्ट प्रोफाइल का उपयोग किया जाता है।';

  @override
  String get profileBodyDefaultBadge => 'डिफ़ॉल्ट';

  @override
  String get profileBodyMakeDefault => 'डिफ़ॉल्ट बनाएं';

  @override
  String get profileBodyDeleteBody => 'आप इसे पूर्ववत् नहीं कर सकते।';

  @override
  String get profileBodyRequired => 'आवश्यक';

  @override
  String get profileBodyCheckNumber => 'इस नंबर की जाँच करें';

  @override
  String get profileBodyNew => 'नई बॉडी प्रोफाइल';

  @override
  String get profileBodyNameHint => 'उदाहरण के लिए, मैं';

  @override
  String get profileBodyHeight => 'लंबाई';

  @override
  String get profileBodyWeight => 'वजन';

  @override
  String get profileBodyBuild => 'बनावट';

  @override
  String get profileBodySkinTone => 'त्वचा का रंग';

  @override
  String get profileBirthDateNeededBody =>
      'जन्म समय के साथ जन्म तिथि भी जोड़ें।';

  @override
  String get profileBirthDateNeededTitle => 'जन्म तिथि आवश्यक है';

  @override
  String get profilePartlySavedBody =>
      'हमने आपका नाम और फोटो सहेज लिया है। जन्म विवरण सहेजा नहीं गया; बाद में पुनः प्रयास करें।';

  @override
  String get profilePartlySavedTitle => 'आंशिक रूप से सहेजा गया';

  @override
  String get profileSavedBody => 'आपकी प्रोफाइल सहेज ली गई है।';

  @override
  String get profileChangePhoto => 'प्रोफाइल फोटो बदलें';

  @override
  String get profilePhotoLabel => 'प्रोफाइल फोटो';

  @override
  String get profilePhotoHint => 'नया चुनने के लिए टैप करें';

  @override
  String get profileBirthDateLabel => 'जन्म तिथि (वैकल्पिक)';

  @override
  String get profileBirthTimeLabel => 'जन्म समय (वैकल्पिक)';

  @override
  String get profileBirthTimeHelper => 'वैदिक सुझावों को अधिक सटीक बनाता है';

  @override
  String get profileBirthPlaceLabel => 'जन्म स्थान (वैकल्पिक)';

  @override
  String get profileBirthPlaceHint => 'उदाहरण के लिए, नई दिल्ली, भारत';

  @override
  String get profileHelpContactTitle => 'हमसे कुछ भी पूछें';

  @override
  String get profileHelpContactBody =>
      'हमें संदेश भेजें, हम आमतौर पर एक दिन के भीतर ईमेल से जवाब देते हैं।';

  @override
  String get profileHelpContactAction => 'सहायता से संपर्क करें';

  @override
  String get profileHelpFaqTitle => 'सामान्य प्रश्न';

  @override
  String get profileFaqAddPiecesTitle =>
      'मैं अपनी वॉर्डरोब में कपड़े कैसे जोड़ूँ?';

  @override
  String get profileFaqAddPiecesBody =>
      'Closet टैब पर Add item पर टैप करें। फ़ोटो लें या गैलरी से चुनें; हम हर पीस को ढूंढकर आपके लिए टैग कर देते हैं।';

  @override
  String get profileFaqMatchingTitle => 'ऑउटफिट मैचिंग कैसे काम करती है?';

  @override
  String get profileFaqMatchingBody =>
      'For you खोलें और अपने पास मौजूद कपड़े चुनें। हम सुझाव देते हैं कि उनके साथ क्या जचेगा और आपकी वॉर्डरोब से पूरे ऑउटफिट बनाते हैं।';

  @override
  String get profileFaqTryOnTitle =>
      'क्या मैं ट्राई-ऑन के लिए अपनी फ़ोटो इस्तेमाल कर सकता हूँ?';

  @override
  String get profileFaqTryOnBody =>
      'हाँ। अपनी पूरी लंबाई की फ़ोटो जोड़ें, फिर खुद पर देखने के लिए कपड़े चुनें।';

  @override
  String get profileFaqRewardsTitle => 'मैं रिवार्ड्स कैसे अर्जित करूँ?';

  @override
  String get profileFaqRewardsBody =>
      'ऑउटफिट की योजना बनाएं और उन्हें अक्सर लॉग करें। आगे बढ़ने पर स्ट्रीक और उपलब्धियाँ जुड़ती जाती हैं।';

  @override
  String get profileFaqPrivacyTitle => 'क्या मेरी वॉर्डरोब प्राइवेट है?';

  @override
  String get profileFaqPrivacyBody =>
      'हाँ। आपकी वॉर्डरोब और ऑउटफिट प्राइवेट हैं, जब तक कि आप किसी एक ऑउटफिट का लिंक शेयर न करें।';

  @override
  String get profileHelpMoreTitle => 'और मदद';

  @override
  String get profileHelpGuides => 'गाइड';

  @override
  String get profileHelpGuidesBody => 'हर फ़ीचर कैसे काम करता है';

  @override
  String get feedbackCategoryBug => 'कुछ ख़राब हो गया है';

  @override
  String get feedbackCategoryIdea => 'एक विचार';

  @override
  String get feedbackCategoryGeneral => 'सामान्य';

  @override
  String get feedbackCategoryHelp => 'मुझे मदद चाहिए';

  @override
  String get feedbackHintBug =>
      'क्या हुआ, और आप क्या उम्मीद कर रहे थे? स्टेप्स से हमें इसे ठीक करने में मदद मिलती है।';

  @override
  String get feedbackHintIdea => 'आप क्या चाहते हैं, और क्यों?';

  @override
  String get feedbackHintGeneral => 'हमें अपनी राय बताएं, या कोई सवाल पूछें।';

  @override
  String get feedbackAttachmentLimitBody => 'आप अधिकतम 5 इमेज जोड़ सकते हैं।';

  @override
  String get feedbackAttachmentLimitTitle => 'सीमा समाप्त';

  @override
  String get feedbackImageTooLargeBody => '5 MB से छोटी इमेज चुनें।';

  @override
  String get feedbackImageTooLargeTitle => 'इमेज बहुत बड़ी है';

  @override
  String get feedbackTitle => 'फ़ीडबैक भेजें';

  @override
  String get feedbackAboutLabel => 'यह किस बारे में है?';

  @override
  String get feedbackSubjectLabel => 'विषय';

  @override
  String get feedbackSubjectRequired => 'विषय जोड़ें';

  @override
  String get feedbackSubjectTooShort => 'विषय कम से कम 3 वर्णों का होना चाहिए';

  @override
  String get feedbackDetailsLabel => 'विवरण';

  @override
  String get feedbackDetailsRequired => 'कुछ विवरण जोड़ें';

  @override
  String get feedbackDetailsTooShort =>
      'वर्णन कम से कम 10 वर्णों का होना चाहिए';

  @override
  String get feedbackAddScreenshot => 'स्क्रीनशॉट जोड़ें';

  @override
  String get feedbackAttachmentHint => 'अधिकतम 5, प्रत्येक 5 MB';

  @override
  String get feedbackSend => 'भेजें';

  @override
  String get feedbackEmptyTitle => 'अभी तक कुछ नहीं भेजा गया';

  @override
  String get feedbackEmptyBody =>
      'आप जो भेजेंगे वह अपनी स्थिति के साथ यहाँ दिखाई देगा।';

  @override
  String get feedbackHistoryTitle => 'आपने जो भेजा';

  @override
  String get feedbackStatusOpen => 'खुला है';

  @override
  String get feedbackStatusInProgress => 'प्रगति पर है';

  @override
  String get feedbackStatusResolved => 'हल हो गया';

  @override
  String get feedbackStatusClosed => 'बंद है';

  @override
  String get legalIntro =>
      'हम आपके डेटा की सुरक्षा कैसे करते हैं, और FitCheck AI का उपयोग करने की शर्तें।';

  @override
  String get legalPolicies => 'नीतियां';

  @override
  String get legalPrivacySubtitle => 'हम क्या एकत्र करते हैं और क्यों';

  @override
  String get legalTermsTitle => 'सेवा की शर्तें';

  @override
  String get legalTermsSubtitle => 'ऐप का उपयोग करने के नियम';

  @override
  String get legalLicences => 'ओपन-सोर्स लाइसेंस';

  @override
  String get legalSupportSubtitle => 'सहायता, संपर्क और गोपनीयता अनुरोध';

  @override
  String get legalReportAbuse => 'समस्या या दुरुपयोग की रिपोर्ट करें';

  @override
  String get permissionCameraTitle => 'कैमरा एक्सेस';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI आपके कपड़ों की तस्वीरें लेने के लिए कैमरे का उपयोग करता है।';

  @override
  String get permissionPhotoTitle => 'फोटो एक्सेस';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI को आपकी तस्वीरों तक पहुंच चाहिए ताकि आप कपड़े चुन सकें।';

  @override
  String get permissionNotNow => 'अभी नहीं';

  @override
  String get permissionOpenSettings => 'सेटिंग्स खोलें';

  @override
  String authSignedInAs(String name) {
    return '$name के रूप में साइन इन हैं';
  }

  @override
  String get authSignedIn => 'लॉग इन है';

  @override
  String get authWelcomeBackTitle => 'वापसी पर स्वागत है';

  @override
  String get authSignInFailed => 'लॉग इन विफल';

  @override
  String get authWelcomeTitle => 'स्वागत है';

  @override
  String get authSignUpFailed => 'साइन अप विफल';

  @override
  String get authGoogleSignInFailed => 'Google साइन-इन विफल';

  @override
  String get authAppleSignInFailed => 'Apple साइन-इन विफल';

  @override
  String get authConfirmEmailTitle => 'अपना ईमेल कन्फर्म करें';

  @override
  String get authConfirmEmailBody =>
      'कन्फर्मेशन ईमेल के लिए अपना इनबॉक्स चेक करें और फिर साइन इन करें।';

  @override
  String get authClosetReady => 'आपकी कोठरी तैयार है।';

  @override
  String get authSignedOutTitle => 'लॉग आउट हैं';

  @override
  String get authSignedOutBody => 'आप लॉग आउट हैं।';

  @override
  String get authSignOutFailed => 'लॉग आउट विफल';

  @override
  String get authEmailSentTitle => 'ईमेल भेजा गया';

  @override
  String get authResetLinkSent => 'रीसेट लिंक के लिए अपना ईमेल चेक करें।';

  @override
  String get authPasswordUpdatedTitle => 'पासवर्ड अपडेट हो गया';

  @override
  String get authPasswordUpdated => 'आपका पासवर्ड अपडेट हो गया है।';

  @override
  String get authPasswordNotUpdated => 'पासवर्ड अपडेट नहीं हुआ';

  @override
  String get authCouldNotSendEmail => 'ईमेल नहीं भेजा जा सका';

  @override
  String get authEmailNotSent => 'ईमेल नहीं भेजा गया';

  @override
  String get authResendSentBody => 'हमने एक नया कन्फर्मेशन ईमेल भेज दिया है।';

  @override
  String get outfitPreviewWithAi => 'AI से प्रीव्यू करें';

  @override
  String get outfitNewPreview => 'नया प्रीव्यू बनाएं';

  @override
  String get outfitBuilderClosetHeading => 'आपका क्लोसेट';

  @override
  String get outfitBuilderSearchHint => 'पेशे खोजें';

  @override
  String get outfitClearSearch => 'खोज साफ करें';

  @override
  String get outfitBuilderAddPiecesTitle => 'पहले पेशे जोड़ें';

  @override
  String get outfitBuilderAddPiecesBody =>
      'आउटफिट आपके क्लोसेट के पेशों से बनते हैं।';

  @override
  String get outfitBuilderNoMatches => 'कोई पेशा मेल नहीं खाता।';

  @override
  String get outfitNameLabel => 'आउटफिट का नाम';

  @override
  String get outfitNameHint => 'उदाहरण के लिए, वीकेंड लिनन';

  @override
  String get outfitPreviewSemantic => 'आउटफिट का AI प्रीव्यू';

  @override
  String get outfitChoosePieces => 'पेशे चुनें';

  @override
  String get outfitTapPiecesHint => 'जोड़ने के लिए नीचे के पेशों पर टैप करें।';

  @override
  String get outfitShareTooltip => 'साझा करें';

  @override
  String get outfitSaveFavourite => 'पसंदीदा में सेव करें';

  @override
  String get outfitPiecesHeading => 'पेशे';

  @override
  String get outfitWearHistoryEmpty =>
      'इसे एक बार पहनें और तारीखें यहां दिखेंगी।';

  @override
  String get outfitWearHistoryTitle => 'पहने का इतिहास';

  @override
  String get outfitWearHistoryError => 'तारीखें लोड नहीं हो सकीं।';

  @override
  String get outfitWornOn => 'पहनने की तारीख';

  @override
  String get outfitEditTitle => 'आउटफिट संपादित करें';

  @override
  String get outfitSavedPhotosFailed => 'विवरण सेव हुए, फोटो नहीं';

  @override
  String get outfitNoPhotosBody =>
      'अभी कोई फोटो नहीं। आउटफिट अपने पेशे दिखाएगा।';

  @override
  String get outfitOccasionLabel => 'अवसर';

  @override
  String get outfitOccasionNone => 'कोई नहीं';

  @override
  String get outfitTagsHint => 'कॉमा से अलग करें';

  @override
  String get outfitDraftBody => 'आपकी मुख्य सूची से छुपा हुआ';

  @override
  String get outfitPublic => 'सार्वजनिक';

  @override
  String get outfitPublicBody => 'लिंक के साथ किसी को भी दिखेगा';

  @override
  String get outfitDeleteFromDetail => 'इस आउटफिट को विवरण पेज से हटाएं।';

  @override
  String get outfitNewCollection => 'नया संग्रह';

  @override
  String get outfitNoCollectionsTitle => 'अभी कोई संग्रह नहीं';

  @override
  String get outfitNoCollectionsBody =>
      'यात्रा, मौसम या मूड के हिसाब से outfits समूह बनाएं।';

  @override
  String get outfitCreateCollection => 'संग्रह बनाएं';

  @override
  String get outfitAddOutfits => 'outfits जोड़ें';

  @override
  String get outfitRename => 'नाम बदलें';

  @override
  String get outfitCollectionDeleteBody => 'इसमें मौजूद outfits बरकरार रहेंगे।';

  @override
  String get outfitCollectionsNotLoaded => 'outfits लोड नहीं हुए';

  @override
  String get outfitRenameCollection => 'संग्रह का नाम बदलें';

  @override
  String get outfitDescriptionOptional => 'विवरण (वैकल्पिक)';

  @override
  String get outfitAllInCollection => 'सभी outfits पहले से इस संग्रह में हैं।';

  @override
  String get photoshootSubtitleUpload => 'आपकी अपनी फोटो से स्टूडियो पोर्ट्रेट';

  @override
  String get photoshootSubtitleConfigure =>
      'एक स्टाइल, फॉर्मेट और संख्या चुनें';

  @override
  String get photoshootSubtitleGenerating => 'इसमें एक-दो मिनट लगेंगे';

  @override
  String get photoshootAddPhotosSemantic => 'अपनी गैलरी से फोटो जोड़ें';

  @override
  String get photoshootUploadTitle => 'अपनी 1 से 4 फोटो जोड़ें';

  @override
  String get photoshootUploadBody => 'अपनी गैलरी से चुनने के लिए टैप करें';

  @override
  String get photoshootAddToContinue => 'आगे बढ़ने के लिए एक फोटो जोड़ें';

  @override
  String get photoshootAddAnotherPhoto => 'एक और फोटो जोड़ें';

  @override
  String get photoshootTipsTitle => 'बेहतर नतीजे के लिए';

  @override
  String get photoshootTipsBody =>
      'अपने चेहरे की साफ और अच्छी रोशनी वाली फोटो का उपयोग करें, कुछ कोणों से। सनग्लास और टोपियां छोड़ें।';

  @override
  String get photoshootStarting => 'शुरू हो रहा है';

  @override
  String get photoshootCancelling => 'रद्द हो रहा है';

  @override
  String get photoshootFailed => 'विरती';

  @override
  String get recommendTabMatches => 'मेच';

  @override
  String get recommendTabComplete => 'संपूर्ण';

  @override
  String get recommendTabWeather => 'मौसम';

  @override
  String get recommendTabColours => 'रंग';

  @override
  String get recommendTabShop => 'स्टोर';

  @override
  String get recommendNoMatchesTitle => 'अभी कोई मेच नहीं';

  @override
  String get recommendNoMatchesBody =>
      'कोई चीज़ चुनें, हम दिखाएंगे कि क्या इसके साथ मेल खाता है।';

  @override
  String get recommendPickPiece => 'चीज़ चुनें';

  @override
  String get recommendNothingMatchesTitle => 'अभी इनसे कुछ नहीं मिला';

  @override
  String get recommendNothingMatchesBody =>
      'दूसरी चीज़ें आज़माएँ या अपने कलोज़ में और जोड़ें।';

  @override
  String get recommendChangePieces => 'चीज़ें बदलें';

  @override
  String get recommendDefaultReason => 'यह आपकी चुनी चीज़ों के साथ आता है।';

  @override
  String get recommendCompleteTitle => 'लुक पूरा करें';

  @override
  String get recommendCompleteBody => 'एक चीज़ चुनें, बाकी हम पूरा करेंगे।';

  @override
  String get recommendWorking => 'काम हो रहा है';

  @override
  String get recommendGenerate => 'बनाएँ';

  @override
  String get recommendChooseStyleBody => 'एक स्टाइल चुनें, फिर बनाएँ।';

  @override
  String get recommendNoLooksTitle => 'इन चीज़ों के लिए कोई लुक नहीं';

  @override
  String get recommendNoLooksBody => 'दूसरी स्टाइल या चीज़ें आज़माएँ।';

  @override
  String get recommendDefaultLook => 'आपकी चीज़ों के लिए एक लुक';

  @override
  String get recommendNoPiecesBody => 'इस लुक के लिए कुछ चीज़ नहीं मिलीं।';

  @override
  String get recommendCityLabel => 'शहर';

  @override
  String get recommendCheck => 'जाँचें';

  @override
  String get recommendWeatherTitle => 'मौसम कैसा है?';

  @override
  String get recommendWeatherBody =>
      'आज के लिए सुझावों के लिए अपना शहर दर्ज करें।';

  @override
  String get recommendWearToday => 'आज पहनें';

  @override
  String get recommendWeatherNoPieces =>
      'इस मौसम के लिए आपके कलोज़ में कुछ नहीं है।';

  @override
  String get recommendBudgetLabel => 'बजट तक';

  @override
  String get recommendLooking => 'ढूँढ रहे हैं';

  @override
  String get recommendFindWhatToBuy => 'खरीदने के लिए ढूँढें';

  @override
  String get recommendFillGapsTitle => 'खाली जगह भरें';

  @override
  String get recommendFillGapsBody =>
      'बजट सेट करें, हम बताएंगे कि आपके कलोज़ में क्या कम है।';

  @override
  String get recommendNoGapsTitle => 'कोई कमी नहीं मिली';

  @override
  String get recommendNoGapsBody => 'बड़ा बजट या दूसरा कैटेगरी आज़माएँ।';

  @override
  String get recommendMoodEveryday => 'रोज़ाना';

  @override
  String get recommendMoodBigMeeting => 'बड़ी मीटिंग';

  @override
  String get recommendDayLabel => 'दिन';

  @override
  String get recommendReadingStars => 'तारे पढ़ रहे हैं';

  @override
  String get recommendGetMyColours => 'मेरे रंग लें';

  @override
  String get recommendLuckyColoursTitle => 'आपके शुभ रंग';

  @override
  String get recommendLuckyColoursBody =>
      'एक दिन चुनें, हम उसके लिए रंग और कपड़े सुझाएंगे।';

  @override
  String get recommendLuckyColoursSection => 'शुभ रंग';

  @override
  String get recommendAvoidColoursSection => 'बचने वाले रंग';

  @override
  String get recommendBirthDateTitle => 'जन्म तिथि जोड़ें';

  @override
  String get recommendBirthDateBody => 'रंग पढ़ने के लिए आपकी जन्म तिथि चाहिए।';

  @override
  String get recommendEditProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get recommendNothingThisDay => 'इस दिन के लिए कुछ नहीं।';

  @override
  String get recommendUnnamedColour => 'अनैम रंग';

  @override
  String get recommendFromCloset => 'आपके क्लोज़ट से';

  @override
  String get recommendNoPiecesInColours => 'इन रंगों में अभी कोई कपड़ा नहीं।';

  @override
  String get recommendOutfitIdeas => 'आउटफिट आइडिया';

  @override
  String get recommendNoOutfitsInColours =>
      'इन रंगों में अभी पूरा आउटफिट नहीं।';

  @override
  String get recommendDefaultOutfitIdea => 'एक आउटफिट आइडिया';

  @override
  String get recommendPickUpToThree => 'तीन कपड़े चुनें';

  @override
  String get recommendEmptyClosetBody =>
      'पहले कुछ कपड़े जोड़ें, फिर मैचिंग कीजिए।';

  @override
  String get dashboardDressForDay => 'आज के दिन के लिए सजीए।';

  @override
  String get dashboardOutfitOfDay => 'आज का आउटफिट';

  @override
  String get dashboardFreshLook => 'एक नज़ाकत';

  @override
  String get subscriptionManageInStoreTitle => 'स्टोर में मैनेज करें';

  @override
  String get subscriptionManageInStoreBody =>
      'यह प्लान स्टोर के जरिए बिल होता है। स्टोर में सेटिंग से मैनेज करें।';

  @override
  String get subscriptionCancelledTitle => 'सब्सक्रिप्शन रद्द';

  @override
  String get subscriptionCancelledBody =>
      'आपका प्लान इस बिलिंग अवधि के अंत तक चल रहा रहेगा।';

  @override
  String get subscriptionCancelFailedTitle => 'रद्द नहीं कर सका';

  @override
  String get subscriptionCouldNotOpenTitle => 'खोल नहीं सका';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'बिलिंग मैनेजमेंट खोल नहीं सका।';

  @override
  String get subscriptionOpenLinkFailedBody => 'लिंक खोल नहीं सका।';

  @override
  String get subscriptionReferralLoadFailedTitle => 'आपका लिंक लोड नहीं हो सका';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'आपका रेफ़रल लिंक लोड नहीं हो सका। दोबारा प्रयास करें।';

  @override
  String get subscriptionReferralCopiedTitle => 'कॉपी किया गया';

  @override
  String get subscriptionReferralCopiedBody => 'रेफ़रल लिंक कॉपी किया गया।';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI आज़माएँ';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI से जुड़ें और हम दोनों को एक महीने की Pro मिलेगी। $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'लिंक कॉपी किया गया';

  @override
  String get subscriptionShareUnavailableBody =>
      'शेयरिंग उपलब्ध नहीं है, इसलिए लिंक कॉपी कर दिया गया।';

  @override
  String get subscriptionShareFailedTitle => 'शेयर नहीं हो सका';

  @override
  String get subscriptionShareFailedBody =>
      'बजाय इसके, रेफ़रल पेज से लिंक कॉपी करें।';

  @override
  String get subscriptionStoreReadyTitle => 'स्टोर तैयार है';

  @override
  String get subscriptionStoreReadyBody =>
      'स्टोर कीमतें उपलब्ध हैं। आप अभी अपग्रेड कर सकते हैं।';

  @override
  String get purchaseFailedTitle => 'खरीदारी विफल रही';

  @override
  String get purchaseUnavailableTitle => 'खरीदारी उपलब्ध नहीं है';

  @override
  String get purchaseIapUnavailableBody =>
      'इस डिवाइस पर इन-ऐप खरीदारी उपलब्ध नहीं हैं।';

  @override
  String get purchasePlanNotAvailableBody =>
      'यह प्लान अभी खरीदने के लिए उपलब्ध नहीं है।';

  @override
  String get purchasePlanNotInStoreBody =>
      'यह प्लान अभी स्टोर में उपलब्ध नहीं है। कृपया जल्द ही जाँचें।';

  @override
  String get purchaseStartFailedBody =>
      'खरीदारी शुरू नहीं हो सकी। दोबारा प्रयास करें।';

  @override
  String get purchaseNoPaymentLinkBody => 'चेकआउट ने भुगतान लिंक नहीं लौटाया।';

  @override
  String get purchasePendingTitle => 'खरीदारी लंबित है';

  @override
  String get purchasePendingBody =>
      'आपकी खरीदारी की मंजूरी का इंतज़ार है। मंजूरी मिलते ही आपको एक्सेस मिलेगा।';

  @override
  String get purchaseFailedBody => 'खरीदारी विफल रही। दोबारा प्रयास करें।';

  @override
  String get purchaseRestoredTitle => 'बहाल किया गया';

  @override
  String get purchaseRestoredBody => 'आपकी खरीदारियाँ बहाल कर दी गईं।';

  @override
  String get purchaseActiveTitle => 'सब्सक्रिप्शन सक्रिय';

  @override
  String get purchaseActiveBody => 'आपका सब्सक्रिप्शन सक्रिय है। स्वागत है।';

  @override
  String get purchaseSignInRequiredTitle => 'साइन इन आवश्यक है';

  @override
  String get purchaseSignInRequiredBody =>
      'अपनी खरीदारी पूरी करने के लिए साइन इन करें।';

  @override
  String get purchaseErrorTitle => 'खरीदारी में त्रुटि';

  @override
  String get purchaseInvalidTransactionBody =>
      'खरीदारी में सत्यापन योग्य लेनदेन ID शामिल नहीं थी।';

  @override
  String get purchaseVerificationPendingTitle => 'सत्यापन लंबित';

  @override
  String get purchaseVerificationPendingBody =>
      'हम अभी स्टर से आपकी खरीदारी का सत्यापन नहीं कर सके। यह स्वतः पूरा होगा, और आपको दो बार बिल नहीं लगेगा।';

  @override
  String get purchaseNotAppliedTitle => 'खरीदारी लागू नहीं हुई';

  @override
  String get purchaseNotAppliedBody =>
      'आपकी खरीदारी आपके खाते में नहीं जोड़ी जा सकी। सपोर्ट से संपर्क करें, और इसे दोबारा खरीदें नहीं।';

  @override
  String get purchaseRestoreFailedTitle => 'पुनर्स्थापना विफल';

  @override
  String get purchaseRestoreFailedBody =>
      'खरीदारी पुनर्स्थापित नहीं की जा सकी। पुनः प्रयास करें।';

  @override
  String get purchaseRecoveredActiveBody => 'आपकी सदस्यता सक्रिय है।';

  @override
  String get purchaseCompleteTitle => 'खरीदारी पूर्ण';

  @override
  String get giftCreateFailedTitle => 'उपहार बनाना संभव नहीं रहा';

  @override
  String get giftClaimFailedTitle => 'उपहार लाना संभव नहीं रहा';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आपके लिए उपहार',
      one: 'आपके लिए एक उपहार',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 महीना',
      '12': '1 वर्ष',
      'other': '$months महीने',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining शेष',
      one: '1 शेष',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro का $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender ने आपको FitCheck Pro का $duration भेजा है। $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient के लिए FitCheck Pro का उपहार';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender से';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient के लिए';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender से';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'आपका प्राप्तकर्ता';

  @override
  String get giftPreviewPlaceholderSender => 'आप';

  @override
  String get settingsSavedTitle => 'सेव किया गया';

  @override
  String get settingsNotSavedTitle => 'सेव नहीं हुआ';

  @override
  String get settingsAiChooseProviderBody => 'एक प्रदाता चुनें।';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'कस्टम प्रदाता के लिए API URL आवश्यक है।';

  @override
  String get settingsAiKeyRequiredBody => 'API कुंजी दर्ज करें।';

  @override
  String get settingsAiSavedBody => 'आपकी AI सेटिंग्स सेव हो गई हैं।';

  @override
  String get settingsAiMissingDetailsTitle => 'विवरण अदृश्य';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'टेस्ट करने के लिए API URL और चैट मॉडल दर्ज करें।';

  @override
  String get settingsAiKeyNeededTitle => 'API कुंजी आवश्यक';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'परीक्षण करने के लिए अपनी API कुंजी दर्ज करें। आपकी सहेजी गई कुंजी निजी रहती है।';

  @override
  String get settingsAiKeyToTestBody =>
      'परीक्षण करने के लिए अपनी API कुंजी दर्ज करें।';

  @override
  String get settingsAiConnectedTitle => 'जुड़ा हुआ';

  @override
  String get settingsAiConnectedBody => 'कनेक्शन सही काम कर रहा है।';

  @override
  String get settingsAiTestFailedTitle => 'परीक्षण विफल';

  @override
  String get settingsPreferencesSavedBody => 'आपकी पसंद सहेजी गई हैं।';

  @override
  String get settingsPasswordNotChangedTitle => 'पासवर्ड नहीं बदला गया';

  @override
  String get settingsOAuthPasswordBody =>
      'यह खाता Google या Apple से साइन इन करता है। पहले पासवर्ड सेट करने के लिए \"पासवर्ड भूल गए\" का उपयोग करें।';

  @override
  String get settingsCurrentPasswordIncorrectBody => 'वर्तमान पासवर्ड गलत है।';

  @override
  String get settingsExportReadyTitle => 'एक्सपोर्ट तैयार';

  @override
  String get settingsExportReadyBody =>
      'आपके डेटा का निर्यात डाउनलोड के लिए तैयार है।';

  @override
  String get settingsLinkCopiedTitle => 'लिंक कॉपी हुआ';

  @override
  String get settingsExportClipboardBody =>
      'हम आपका ब्राउज़र खोल नहीं पाए, इसलिए हमने डाउनलोड लिंक कॉपी किया है। इसे ब्राउज़र में तुरंत पेस्ट करें: यह समाप्त हो जाता है।';

  @override
  String get settingsExportFailedTitle => 'एक्सपोर्ट विफल';

  @override
  String get settingsAccountNotDeletedTitle => 'खाता हटाया नहीं गया';

  @override
  String photoshootPhotoLimit(int max) {
    return 'आप $max तक के फोटो जोड़ सकते हैं।';
  }

  @override
  String get photoshootPhotoLimitTitle => 'फोटो सीमा';

  @override
  String get photoshootAddAtLeastOnePhoto => 'कम से कम एक फोटो जोड़ें।';

  @override
  String get photoshootNoPhotosSelectedTitle => 'कोई फोटो नहीं';

  @override
  String get photoshootDescribeLookBody => 'वह लुक बताएं जिसे आप चाहते हैं।';

  @override
  String get photoshootPromptNeededTitle => 'प्रॉम्पट आवश्यक';

  @override
  String get photoshootConsentFeatureLabel => 'AI फोटोशूट';

  @override
  String get photoshootStatusPreparing => 'आपके फोटो तैयार किए जा रहे हैं';

  @override
  String get photoshootStatusGenerating => 'जनरेट हो रहा है';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'बैच $current / $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$total में से $done पूरे';
  }

  @override
  String get photoshootGenerationFailedBody => 'जनरेशन विफल हुआ।';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready तैयार, $failed विफल।';
  }

  @override
  String get photoshootPartlyDoneTitle => 'कुछ हद तक पूरा';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फोटो तैयार हैं।',
      one: '1 फोटो तैयार है।',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'कनेक्शन ख़तम हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get photoshootCouldNotCancelTitle => 'रद्द नहीं कर पाए';

  @override
  String get photoshootRetryFailedTitle => 'पुनः प्रयास विफल';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'फ़ोटो $number तैयार है।';
  }

  @override
  String get photoshootReplacedTitle => 'बदल दिया गया';

  @override
  String get photoshootSavedToGalleryBody => 'आपकी गैलरी में सेव किया गया।';

  @override
  String get photoshootSavedTitle => 'सेव किया गया';

  @override
  String get photoshootNotSavedTitle => 'सेव नहीं किया गया';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सभी $count फ़ोटो आपकी गैलरी में हैं।',
      one: '1 फ़ोटो आपकी गैलरी में है।',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$total में से $saved सेव हो गए।';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'कुछ फ़ोटो सेव नहीं हुईं';

  @override
  String get tryonConsentFeatureLabel => 'वर्चुअल ट्राई-ऑन';

  @override
  String get tryonAvatarUpdatedBody => 'आपकी फ़ोटो अपडेट हो गई है।';

  @override
  String get tryonSavedTitle => 'सेव किया गया';

  @override
  String get tryonUploadFailedTitle => 'अपलोड विफल';

  @override
  String get tryonChooseGarmentFirstBody => 'पहले एक वस्त्र की फ़ोटो चुनें।';

  @override
  String get tryonNoGarmentTitle => 'वस्त्र नहीं';

  @override
  String get tryonWaitForUploadBody =>
      'अपना फ़ोटो अपलोड होने की प्रतीक्षा करें।';

  @override
  String get tryonStillUploadingTitle => 'अपलोड जारी है';

  @override
  String get tryonAddYourPhotoFirstBody => 'पहले अपनी फ़ोटो जोड़ें।';

  @override
  String get tryonReadyBody => 'आपका ट्राई-ऑन तैयार है।';

  @override
  String get tryonFailedTitle => 'ट्राई-ऑन विफल';

  @override
  String get tryonSavedToGalleryBody => 'आपकी गैलरी में सेव किया गया।';

  @override
  String get tryonNotSavedTitle => 'सेव नहीं किया गया';

  @override
  String get calendarEventAddedBody => 'इवेंट जुड़ गया';

  @override
  String get calendarEventPlannedTitle => 'प्लान किया गया';

  @override
  String get calendarEventSavedBody => 'इवेंट सेव हो गया';

  @override
  String get calendarSavedTitle => 'सेव किया गया';

  @override
  String get calendarEventNotSavedTitle => 'इवेंट सेव नहीं हुआ';

  @override
  String get calendarEventRemovedBody => 'इवेंट हटा दिया गया';

  @override
  String get calendarEventDeletedTitle => 'हटा दिया गया';

  @override
  String get calendarEventNotDeletedTitle => 'इवेंट नहीं हटाया गया';

  @override
  String get calendarOutfitNotLinkedTitle => 'आउटफिट जोड़ा नहीं गया';

  @override
  String get calendarLinkedTitle => 'जोड़ा गया';

  @override
  String get calendarOutfitNotRemovedTitle => 'आउटफिट नहीं हटाया गया';

  @override
  String get calendarOutfitRemovedBody => 'आउटफिट हटा दिया गया';

  @override
  String get calendarDisconnectedBody => 'कैलेंडर विच्छिन्न किया गया';

  @override
  String get calendarDisconnectedTitle => 'विच्छिन्न';

  @override
  String get calendarNotDisconnectedTitle => 'कैलेंडर नहीं विच्छिन्न किया गया';

  @override
  String get calendarTodayLabel => 'आज';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count इवेंट',
      one: '1 इवेंट',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start से $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, आउटफिट जोड़ा गया';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '“$title” को हटा दिया जाएगा।';
  }

  @override
  String get calendarThisAppLabel => 'यह ऐप';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider के साथ सिंक अभी उपलब्ध नहीं है। आप यहाँ अभी भी इवेंट जोड़ सकते हैं।';
  }

  @override
  String get calendarWeekdaySunShort => 'रवि';

  @override
  String get calendarWeekdayMonShort => 'सोम';

  @override
  String get calendarWeekdayTueShort => 'मंगल';

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
  String get calendarWeekdayTuesday => 'मंगलवार';

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
  String get outfitSavedToFavouritesBody => 'पसंदीदा में जोड़ा गया';

  @override
  String get outfitRemovedFromFavouritesBody => 'पसंदीदा से हटाया गया';

  @override
  String get outfitNotSavedTitle => 'सहेजा नहीं गया';

  @override
  String get outfitLoggedAsWornBody => 'आज पहने के रूप में दर्ज किया गया।';

  @override
  String get outfitNicePickTitle => 'बढ़िया चयन';

  @override
  String get outfitRemovedBody => 'आउटफिट हटाया गया।';

  @override
  String get outfitDeletedTitle => 'हटाया गया';

  @override
  String get outfitNotDeletedTitle => 'हटाया नहीं गया';

  @override
  String get outfitDuplicatedBody => 'एक प्रतिलिपि आपके आउटफिट में है।';

  @override
  String get outfitDuplicatedTitle => 'डुप्लिकेट किया गया';

  @override
  String get outfitNotDuplicatedTitle => 'डुप्लिकेट नहीं किया गया';

  @override
  String get outfitNotSharedTitle => 'शेयर नहीं किया गया';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" तैयार है।';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'कॉलेक्शन नहीं बना';

  @override
  String get outfitCollectionUpdatedBody => 'कॉलेक्शन अपडेट किया गया।';

  @override
  String get outfitCollectionNotUpdatedTitle => 'कॉलेक्शन अपडेट नहीं किया गया';

  @override
  String get outfitCollectionDeletedBody => 'कॉलेक्शन हटाया गया।';

  @override
  String get outfitCollectionNotDeletedTitle => 'कॉलेक्शन हटाया नहीं गया';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आउटफिट जुड़े।',
      one: '1 आउटफिट जोड़ा गया।',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'आउटफिट नहीं जोड़े गए';

  @override
  String get outfitPreviewNotCreatedTitle => 'प्रीव्यू नहीं बना';

  @override
  String get outfitGiveNameBody => 'आउटफिट का नाम दें।';

  @override
  String get outfitNameMissingTitle => 'नाम';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'कम से कम एक आइटम चुनें।';

  @override
  String outfitCreatedBody(String name) {
    return '$name आपके आउटफिट में है।';
  }

  @override
  String get outfitSavedTitle => 'सहेजा गया';

  @override
  String get wardrobeAddedToFavouritesBody => 'पसंदीदा में जोड़ा गया';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'पसंदीदा से हटाया गया';

  @override
  String get wardrobeNotSavedTitle => 'सहेजा नहीं गया';

  @override
  String get wardrobeLoggedAsWornBody => 'आज पहनने के रूप में दर्ज किया गया।';

  @override
  String get wardrobeRemovedFromClosetBody => 'आपके क्लोसेट से हटाया गया।';

  @override
  String get wardrobeDeletedTitle => 'हटाया गया';

  @override
  String get wardrobeNotDeletedTitle => 'हटाया नहीं गया';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम हटाए गए।',
      one: '1 आइटम हटाया गया।',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI क्लोसेट एक्सट्रैक्शन';

  @override
  String get itemAddScanJobLabel => 'स्कैन';

  @override
  String get itemAddFoundEarlierBody => 'पिछले स्कैन में मिला';

  @override
  String get itemAddLookingAtPhoto => 'आपकी फ़ोटो देखी जा रही है';

  @override
  String get itemAddExtractionFailedBody => 'एक्सट्रैक्शन विफल रहा';

  @override
  String get itemAddJobFailedBody => 'कार्य विफल रहा';

  @override
  String get itemAddConnectionLostBody => 'संयोजन खो दिया गया। फिर कोशिश करें।';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'प्रोसेसिंग के दौरान संयोजन खो गया।';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'आइटम $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'आइटम';

  @override
  String get itemAddNotCancelledTitle => 'रद्द नहीं हुआ';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम आपके क्लोसेट में हैं।',
      one: '1 आइटम आपके क्लोसेट में है।',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$total में से $saved आइटम सहेजे गए। शेष को फिर से कोशिश करने के लिए सहेजें पर टैप करें।';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'कुछ आइटम सहेजे नहीं गए';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'कम से कम एक फ़ोटो चुनें।';

  @override
  String get batchPhotoUnreadableBody => 'यह फ़ोटो पढ़ी नहीं जा सकी।';

  @override
  String get batchNoPhotosReadableBody =>
      'इनमें से कोई फ़ोटो नहीं पढ़ी जा सकी। अन्य फ़ोटो आज़माएं।';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो',
      one: '1 फ़ोटो',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'काम करते समय संयोजन खो गया। फिर कोशिश करें।';

  @override
  String get batchNotCancelledTitle => 'रद्द नहीं हुआ';

  @override
  String get batchPostLinkUnsupportedBody =>
      'पोस्ट लिंक का समर्थन नहीं है। प्रोफ़ाइल लिंक दर्ज करें।';

  @override
  String get batchLinkSpacesBody => 'लिंक में जगह नहीं हो सकतीं।';

  @override
  String get batchEnterProfileLinkBody =>
      'Instagram या Facebook प्रोफ़ाइल लिंक दर्ज करें।';

  @override
  String get batchEnterProfileLinkShortBody => 'प्रोफ़ाइल लिंक दर्ज करें।';

  @override
  String get batchSignInPageNotOpenBody =>
      'साइन-इन पेज खुला नहीं। फिर कोशिश करें।';

  @override
  String get batchSignInBrowserBody =>
      'ब्राउज़र में साइन इन करें, फिर FitCheck पर वापस आएँ।';

  @override
  String get batchConnectAccountTitle => 'अपना खाता जोड़ें';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'अपने ऑथेंटिकेटर ऐप का कोड दर्ज करें।';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram को सुरक्षा जाँच की आवश्यकता है। पहले ब्राउज़र में साइन इन करें।';

  @override
  String get batchEnterCredentialsAgainBody =>
      'पुनः अपना यूज़रनेम और पासवर्ड दर्ज करें।';

  @override
  String get batchSignInFailedBody =>
      'साइन-इन विफल रहा है। अपने यूज़रनेम और पासवर्ड की जाँच करें।';

  @override
  String get batchSignInToKeepImportingBody =>
      'आयात जारी रखने के लिए साइन इन करें।';

  @override
  String get batchAccountNotConnectedBody => 'आपका खाता नहीं जोड़ा गया।';

  @override
  String get batchAccountConnectedTitle => 'खाता जोड़ा गया';

  @override
  String get batchNotConnectedTitle => 'नहीं जुड़ा';

  @override
  String get batchImportConnectionLostBody =>
      'आयात के साथ कनेक्शन खो गया है। जाँचने के लिए रीफ्रेश करें।';

  @override
  String batchPickUpToBody(int max) {
    return 'अधिकतम $max फ़ोटो चुनें। हम आइटम ढूँढते हैं।';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count of $total फ़ोटो';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'फ़ोटो $done of $count तैयार हो रही है';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो में आइटम खोजें',
      one: '1 फ़ोटो में आइटम खोजें',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'आपका $platform खाता टू-स्टेप साइन-इन का उपयोग करता है। अपने ऑथेंटिकेटर ऐप से 6-अंकों का कोड दर्ज करें।';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'यह $platform प्रोफ़ाइल प्राइवेट है या इसके फ़ोटो दिखाने के लिए साइन-इन आवश्यक है।';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform से जुड़ें';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'अभी तक $count फ़ोटो मिलीं',
      one: 'अभी तक 1 फ़ोटो मिली',
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
    return '$processed of $total प्रोसेस · $added जोड़े गए · $waiting प्रतीक्षा में · $skipped छोड़े गए';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'फ़ोटो $number स्कैन हो रही है';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'फ़ोटो $number अगली है';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'फ़ोटो $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम मिले',
      one: '1 आइटम मिला',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोटो आपके वॉर्डरोब में जोड़ी गईं।',
      one: '1 फ़ोटो आपके वॉर्डरोब में जोड़ी गई।',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count और स्टूडियो फ़ोटो आ रही हैं। आप तैयार चीज़ें सहेज सकते हैं, या चले जाएँ — हम आपको बताएँगे।',
      one:
          '1 और स्टूडियो फ़ोटो आ रही है। आप तैयार चीज़ें सहेज सकते हैं, या चले जाएँ — हम आपको बताएँगे।',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'अभी सहेजे नहीं गए: $names।';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces आइटम',
      one: '1 आइटम',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos फ़ोटो से',
      one: '1 फ़ोटो से',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen चुने गए। आइटम छोड़ने के लिए टैप करें।';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम सहेजे जा रहे हैं',
      one: '1 आइटम सहेजा जा रहा है',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आईटम सेव करें',
      one: '1 आईटम सेव करें',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'आपका बॉडी प्रोफ़ाइल सेव हो गया।';

  @override
  String get bodyProfileSavedTitle => 'सेव हो गया';

  @override
  String get bodyProfileNotSavedTitle => 'सेव नहीं हुआ';

  @override
  String get bodyProfileSetDefaultBody =>
      'कोई डिफ़ॉल्ट प्रोफ़ाइल रूप में सेट करें।';

  @override
  String get bodyProfileDeletedBody => 'बॉडी प्रोफ़ाइल हटाई गई।';

  @override
  String get bodyProfileDeletedTitle => 'हटाया गया';

  @override
  String get bodyProfileNotDeletedTitle => 'हटाया नहीं गया';

  @override
  String get feedbackNotSentTitle => 'भेजा नहीं गया';

  @override
  String get feedbackSentBody =>
      'धन्यवाद। हम हर संदेश पढ़ते हैं और ज़रूरत हो तो जवाब देते हैं।';

  @override
  String get feedbackSentTitle => 'फ़ीडबैक भेजा गया';

  @override
  String get recommendUnnamedPiece => 'बेनाम आईटम';

  @override
  String get recommendEnterCityBody =>
      'मौसम के अनुसार चुनें अपनी शहर दर्ज करें।';

  @override
  String get recommendWhichCityTitle => 'कौन सा शहर?';

  @override
  String get aiConsentSheetTitle => 'एआई सर्विस के साथ फ़ोटो शेयर करना';

  @override
  String get aiConsentSheetBody =>
      'आपके ट्राई-ऑन और फोटोशूट इमेज बनाने के लिए, FitCheck AI आपके द्वारा दिए गए फ़ोटो (आपके चेहरे और शरीर की इमेज समेत) प्रोसेसिंग के लिए एक विश्वसनीय तीन pihak एआई प्रदाता (जैसे OpenAI या Google Gemini) को भेजता है। वे आपकी इमेज बनाते हैं और हमारे शर्तों के तहत उन्हें मॉडल ट्रेनिंग के लिए उपयोग नहीं करते। फ़ोटो सुरक्षित रूप से ट्रांसमिट होते हैं और विज्ञापन के लिए कभी भी साझा नहीं किए जाते।';

  @override
  String get aiConsentSheetPermission =>
      'आगे बढ़ने पर, आप इन एआई प्रदाताओं के साथ इमेज जनरेशन के लिए अपने फ़ोटो साझा करने की स्पष्ट अनुमति देते हैं।';

  @override
  String get skeletonsLoadMoreFailed => 'और लोड नहीं कर सका।';

  @override
  String get jobsPiecesReadyTitle => 'आपके आईटम तैयार हैं';

  @override
  String get jobsScanStoppedTitle => 'स्कैन रुक गया';

  @override
  String get jobsNothingSavedBody => 'कुछ भी सेव नहीं हुआ। पुनः प्रयास करें।';

  @override
  String get jobsPhotoUploadFailedBody => 'फ़ोटो अपलोड विफल रहा।';

  @override
  String get authGoogleSignInStartFailed =>
      'Google साइन-इन शुरू नहीं हो पाया। कृपया पुनः प्रयास करें।';

  @override
  String get referralAppliedTitle => 'रेफ़रल लागू हुआ!';

  @override
  String get billingStoreUnavailableBody =>
      'इस डिवाइस पर स्टोर खरीदारी उपलब्ध नहीं है।';

  @override
  String get billingPurchaseProcessingBody =>
      'यह खरीदारी अभी प्रोसेस हो रही है। एक मिनट में ऐप दोबारा खोलकर अपना प्लान देखें।';

  @override
  String get profileAvatarUploadNoUrl =>
      'एवटर अपलोड ने कोई इमेज URL नहीं लौटाया।';

  @override
  String get rewardsDayStreakLabel => 'दिन स्ट्रीक';

  @override
  String rewardsBestStreak(int days) {
    return 'श्रेष्ठ $days दिन';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission एक्सेस आवश्यक';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission का एक्सेस वर्तमान में अस्वीकार है। इसे अनुमति देने के लिए सेटिंग खोलें, फिर वापस आकर पुनः प्रयास करें।';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'चरण $step / 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'चरण $step / $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'छवि $index हटाएं';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'छवि $index हटाएं';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points पॉइंट';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'ईमेल करें: $email। हम रिपोर्ट्स का समीक्षा 24 घंटों में करते हैं।';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece हटाएं';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '\"$name\" हटाएं?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '\"$name\" में जोड़ें';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" हटा दिया गया है। इसके आइटम आपके क्लोज़ेट में ही रहेंगे।';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'सभी $count दिखाएं';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'आज $count शेष';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'फोटो $index विफल रही';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max में से $selected फोटो चुनी गईं';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape बिल्ड, $tone त्वचा';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name हटाएं?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name के विकल्प';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'सबसे ज़्यादा पहना: $name, $count बार';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: सेट नहीं किया';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% मेल';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max में से $picked चुनी गईं';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item हटाएं';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency प्राथमिकता';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'यह प्लान $store के माध्यम से बिल किया जाता है। इसे बदलने या रद्द करने के लिए $store खाते की सेटिंग्स खोलें।';
  }

  @override
  String billingManageInStore(String store) {
    return '$store में प्रबंधन करें';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max में से $current उपयोग हुआ';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'लगभग $seconds सेकंड शेष';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total में से $done स्टूडियो फोटो तैयार';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total में से $ready स्टूडियो फोटो तैयार। छोड़ने के लिए आइटम को टैप करें।';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height सेमी · $weight किग्रा';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'नहीं';
}
