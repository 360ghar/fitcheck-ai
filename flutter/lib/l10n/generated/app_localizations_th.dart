// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'หน้าหลัก';

  @override
  String get tabPhotoshoot => 'ถ่ายรูป';

  @override
  String get tabCloset => 'ตู้เสื้อผ้า';

  @override
  String get tabOutfits => 'ชุดที่จัดไว้';

  @override
  String get tabMore => 'เพิ่มเติม';

  @override
  String get actionAddItem => 'เพิ่มไอเทม';

  @override
  String get actionCreateOutfit => 'จัดชุด';

  @override
  String get actionCancel => 'ยกเลิก';

  @override
  String get actionDelete => 'ลบ';

  @override
  String get actionSave => 'บันทึก';

  @override
  String get actionRetry => 'ลองใหม่';

  @override
  String get actionDone => 'เสร็จสิ้น';

  @override
  String get actionNext => 'ถัดไป';

  @override
  String get actionBack => 'ย้อนกลับ';

  @override
  String get actionClose => 'ปิด';

  @override
  String get actionSearch => 'ค้นหา';

  @override
  String get actionContinue => 'ดำเนินการต่อ';

  @override
  String get stateLoading => 'กำลังโหลด';

  @override
  String get stateErrorTitle => 'เกิดข้อผิดพลาด';

  @override
  String get stateErrorBody =>
      'ลองใหม่อีกครั้ง หากยังพบปัญหา โปรดติดต่อฝ่ายสนับสนุน';

  @override
  String get stateOfflineTitle => 'คุณไม่ได้เชื่อมต่ออินเทอร์เน็ต';

  @override
  String get stateOfflineBody =>
      'เชื่อมต่ออินเทอร์เน็ตเพื่อซิงค์ตู้เสื้อผ้าและจัดชุด';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get settingsAccountSection => 'บัญชี';

  @override
  String get settingsPreferencesSection => 'การตั้งค่าส่วนตัว';

  @override
  String get settingsPlanBilling => 'แพ็กเกจและการชำระเงิน';

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get settingsNotifications => 'การแจ้งเตือน';

  @override
  String get settingsUnits => 'หน่วยวัด';

  @override
  String get settingsAppearance => 'ลักษณะที่ปรากฏ';

  @override
  String get settingsPrivacySection => 'ความเป็นส่วนตัวและข้อมูล';

  @override
  String get settingsAboutSection => 'เกี่ยวกับ';

  @override
  String get settingsSignOut => 'ลงชื่อออก';

  @override
  String get settingsDeleteAccount => 'ลบบัญชี';

  @override
  String get settingsDeleteAccountTitle => 'ลบบัญชีของคุณ?';

  @override
  String get settingsDeleteAccountBody =>
      'การดำเนินการนี้จะลบตู้เสื้อผ้า ชุดที่จัดไว้ รูปภาพ และโปรไฟล์ของคุณ ซึ่งไม่สามารถกู้คืนได้';

  @override
  String get settingsUnitsImperial => 'อิมพีเรียล (นิ้ว, ปอนด์)';

  @override
  String get settingsUnitsMetric => 'เมตริก (ซม., กก.)';

  @override
  String get languageTitle => 'ภาษา';

  @override
  String get languageSystem => 'ใช้ภาษาตามอุปกรณ์';

  @override
  String get languageSystemBody =>
      'FitCheck AI จะใช้ภาษาเดียวกับโทรศัพท์ของคุณ';

  @override
  String get languageSearchHint => 'ค้นหาภาษา';

  @override
  String get languageCurrent => 'ปัจจุบัน';

  @override
  String get languageReviewNote =>
      'คำแปลนี้เป็นคำแปลใหม่ โปรดแจ้งให้เราทราบหากพบข้อผิดพลาด';

  @override
  String get languageChanged => 'อัปเดตภาษาแล้ว';

  @override
  String get paywallTitle => 'เลือกแผนของคุณ';

  @override
  String get paywallTrialBadge => 'ฟรี 1 เดือน';

  @override
  String get paywallTrialTitle => 'ทดลองใช้ Pro ฟรีเดือนแรก';

  @override
  String get paywallTrialBody =>
      'อัปโหลดตู้เสื้อผ้าทั้งหมดของคุณได้ในครั้งเดียว และเพิ่มไอเทมใหม่ได้เรื่อยๆ หลังจากนั้น';

  @override
  String get paywallFreeForeverTitle => 'ฟรีตลอดไป';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'ไม่ต้องใช้บัตรเครดิต รับสิทธิ์อัปโหลดด้วย AI $uploads ครั้ง, จัดชุด $outfits ชุด และรูปภาพจาก photoshoot $images รูปต่อวัน';
  }

  @override
  String get paywallCtaTrial => 'เริ่มทดลองใช้ฟรี';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'อัปเกรดเป็น $plan';
  }

  @override
  String get paywallRestore => 'กู้คืนการซื้อ';

  @override
  String get paywallManage => 'จัดการการสมัครสมาชิก';

  @override
  String get paywallTerms => 'ข้อกำหนดการใช้งาน';

  @override
  String get paywallPrivacy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get paywallPerMonth => 'ต่อเดือน';

  @override
  String get paywallPerYear => 'ต่อปี';

  @override
  String get paywallBestValue => 'คุ้มค่าที่สุด';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'ทดลองใช้ฟรีสำหรับสมาชิกใหม่เท่านั้น หลังจากหมดช่วงทดลองใช้ Pro จะต่ออายุในราคา $price เว้นแต่จะยกเลิกอย่างน้อย 24 ชั่วโมงก่อนสิ้นสุด';
  }

  @override
  String get introTitle => 'จัดระเบียบตู้เสื้อผ้าของคุณ';

  @override
  String get introBody =>
      'ถ่ายรูปเสื้อผ้าของคุณเพียงครั้งเดียว รับไอเดียการแต่งตัว พรีวิวการลองชุด และภาพถ่ายสตูดิโอจากเสื้อผ้าที่คุณมีอยู่แล้ว';

  @override
  String get introStart => 'เริ่มต้นใช้งาน';

  @override
  String get introHaveAccount => 'ฉันมีบัญชีแล้ว';

  @override
  String get introSkip => 'ข้าม';

  @override
  String get authSignIn => 'ลงชื่อเข้าใช้';

  @override
  String get authSignUp => 'สร้างบัญชี';

  @override
  String get authEmail => 'อีเมล';

  @override
  String get authPassword => 'รหัสผ่าน';

  @override
  String get authForgotPassword => 'ลืมรหัสผ่าน?';

  @override
  String get authContinueApple => 'ดำเนินการต่อด้วย Apple';

  @override
  String get authContinueGoogle => 'ดำเนินการต่อด้วย Google';

  @override
  String get authOrDivider => 'หรือ';

  @override
  String get wardrobeTitle => 'ตู้เสื้อผ้า';

  @override
  String get wardrobeEmptyTitle => 'ตู้เสื้อผ้าของคุณว่างเปล่า';

  @override
  String get wardrobeEmptyBody =>
      'เพิ่มชิ้นแรกของคุณ หรืออัปโหลดรูปถ่ายราวแขวนผ้าทั้งหมดในครั้งเดียว';

  @override
  String get wardrobeAddFirst => 'เพิ่มไอเทมชิ้นแรก';

  @override
  String get wardrobeSearchHint => 'ค้นหาในตู้เสื้อผ้า';

  @override
  String get categoryTops => 'เสื้อ';

  @override
  String get categoryBottoms => 'กางเกงและกระโปรง';

  @override
  String get categoryShoes => 'รองเท้า';

  @override
  String get categoryAccessories => 'เครื่องประดับ';

  @override
  String get categoryOuterwear => 'เสื้อคลุม';

  @override
  String get categorySwimwear => 'ชุดว่ายน้ำ';

  @override
  String get categoryActivewear => 'ชุดออกกำลังกาย';

  @override
  String get categoryOther => 'อื่นๆ';

  @override
  String get conditionClean => 'สะอาด';

  @override
  String get conditionDirty => 'ใช้แล้ว';

  @override
  String get conditionLaundry => 'กำลังซัก';

  @override
  String get conditionRepair => 'ต้องซ่อม';

  @override
  String get conditionDonate => 'บริจาค';

  @override
  String get seasonSpring => 'ฤดูใบไม้ผลิ';

  @override
  String get seasonSummer => 'ฤดูร้อน';

  @override
  String get seasonFall => 'ฤดูใบไม้ร่วง';

  @override
  String get seasonWinter => 'ฤดูหนาว';

  @override
  String get seasonAll => 'ทุกฤดู';

  @override
  String get styleCasual => 'ลำลอง';

  @override
  String get styleFormal => 'ทางการ';

  @override
  String get styleBusiness => 'ธุรกิจ';

  @override
  String get styleSporty => 'สปอร์ต';

  @override
  String get styleBohemian => 'โบฮีเมียน';

  @override
  String get styleStreetwear => 'สตรีทแวร์';

  @override
  String get styleVintage => 'วินเทจ';

  @override
  String get styleMinimalist => 'มินิมอล';

  @override
  String get styleRomantic => 'โรแมนติก';

  @override
  String get styleEdgy => 'โฉบเฉี่ยว';

  @override
  String get stylePreppy => 'เพรพพี';

  @override
  String get styleArtsy => 'อาร์ต';

  @override
  String get styleClassic => 'คลาสสิก';

  @override
  String get styleElegant => 'หรูหรา';

  @override
  String get styleOther => 'อื่นๆ';

  @override
  String get occasionWork => 'ทำงาน';

  @override
  String get occasionDateNight => 'ออกเดท';

  @override
  String get occasionTravel => 'ท่องเที่ยว';

  @override
  String get occasionWedding => 'งานแต่งงาน';

  @override
  String get occasionGym => 'ออกกำลังกาย';

  @override
  String get occasionWeekend => 'วันหยุด';

  @override
  String get occasionParty => 'ปาร์ตี้';

  @override
  String get occasionInterview => 'สัมภาษณ์งาน';

  @override
  String get colorBlack => 'ดำ';

  @override
  String get colorWhite => 'ขาว';

  @override
  String get colorGrey => 'เทา';

  @override
  String get colorNavy => 'กรมท่า';

  @override
  String get colorBrown => 'น้ำตาล';

  @override
  String get colorRed => 'แดง';

  @override
  String get colorBlue => 'น้ำเงิน';

  @override
  String get colorGreen => 'เขียว';

  @override
  String get colorPink => 'ชมพู';

  @override
  String get colorPurple => 'ม่วง';

  @override
  String get colorYellow => 'เหลือง';

  @override
  String get colorOrange => 'ส้ม';

  @override
  String get colorBeige => 'เบจ';

  @override
  String get dateToday => 'วันนี้';

  @override
  String get dateYesterday => 'เมื่อวาน';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count วันที่แล้ว',
      one: '1 วันที่แล้ว',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count สัปดาห์ที่แล้ว',
      one: '1 สัปดาห์ที่แล้ว',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count เดือนที่แล้ว',
      one: '1 เดือนที่แล้ว',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ปีที่แล้ว',
      one: '1 ปีที่แล้ว',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'ชอบ FitCheck AI ไหม?';

  @override
  String get ratingPromptBody =>
      'ให้คะแนนเพื่อช่วยให้ผู้อื่นค้นพบสไตล์ของตัวเอง';

  @override
  String get ratingPromptYes => 'ให้คะแนนแอป';

  @override
  String get ratingPromptNo => 'ไว้คราวหน้า';

  @override
  String get closetNoMatchesTitle => 'ไม่พบชิ้นที่ตรงกัน';

  @override
  String get closetNoMatchesBody => 'ลองลดตัวกรองหรือค้นหาใหม่';

  @override
  String get closetClearFilters => 'ล้างตัวกรอง';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ชิ้น',
      one: '1 ชิ้น',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'กำลังโหลดเสื้อผ้าของคุณ';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เลือกแล้ว $count ชิ้น',
      one: 'เลือกแล้ว 1 ชิ้น',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'ลบที่เลือก';

  @override
  String get closetCancelSelection => 'ยกเลิกการเลือก';

  @override
  String get closetCloseSearch => 'ปิดการค้นหา';

  @override
  String get closetShowGrid => 'แสดงแบบตาราง';

  @override
  String get closetShowList => 'แสดงแบบรายการ';

  @override
  String get closetShowRows => 'แสดงแบบแถว';

  @override
  String get closetStatsTitle => 'สถิติตู้เสื้อผ้า';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ลบ $count ชิ้น?',
      one: 'ลบ 1 ชิ้น?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'ชุดที่ใช้ไอเทมเหล่านี้จะไม่มีไอเทมนี้อีกต่อไป';

  @override
  String get closetSortBy => 'เรียงลำดับตาม';

  @override
  String get closetFavourites => 'รายการโปรด';

  @override
  String get closetFavourite => 'เพิ่มเป็นรายการโปรด';

  @override
  String get closetUnfavourite => 'นำออกจากรายการโปรด';

  @override
  String get closetWoreToday => 'ใส่แล้ววันนี้';

  @override
  String closetWornTimes(int count) {
    return 'ใส่ไป $count ครั้ง';
  }

  @override
  String get closetCategoryLabel => 'หมวดหมู่';

  @override
  String get closetUseCaseLabel => 'โอกาสในการสวมใส่';

  @override
  String get closetAnyUseCase => 'ทั้งหมด';

  @override
  String get closetOtherUseCase => 'โอกาสอื่นๆ';

  @override
  String get closetOtherUseCaseHint => 'เช่น มื้อสาย';

  @override
  String get closetUseUseCase => 'ใช้โอกาสนี้';

  @override
  String get closetClearAll => 'ล้างทั้งหมด';

  @override
  String get sortNewest => 'ใหม่ล่าสุด';

  @override
  String get sortOldest => 'เก่าที่สุด';

  @override
  String get sortName => 'ชื่อ (ก-ฮ)';

  @override
  String get sortMostWorn => 'ใส่บ่อยที่สุด';

  @override
  String get useCaseInformal => 'ลำลอง';

  @override
  String get useCaseDate => 'ออกเดท';

  @override
  String get useCaseDinner => 'มื้อค่ำ';

  @override
  String get useCaseLunch => 'มื้อเที่ยง';

  @override
  String get actionSelect => 'เลือก';

  @override
  String get actionEdit => 'แก้ไข';

  @override
  String get actionFilter => 'ตัวกรอง';

  @override
  String get actionSort => 'เรียงลำดับ';

  @override
  String get actionAll => 'ทั้งหมด';

  @override
  String get dashboardStartClosetTitle => 'เริ่มสร้างตู้เสื้อผ้า';

  @override
  String get dashboardStartClosetBody =>
      'ถ่ายรูปเสื้อผ้าของคุณ เราจะช่วยแท็กให้';

  @override
  String get dashboardPieces => 'ชิ้น';

  @override
  String get dashboardOutfits => 'ชุด';

  @override
  String get dashboardDayStreak => 'วันติดต่อกัน';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count เดือนนี้';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'สถิติสูงสุด $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count รายการโปรด',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ชุดที่บันทึก',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'ใส่บ่อยที่สุด: $name, $count ครั้ง';
  }

  @override
  String get setupSkip => 'ข้ามการตั้งค่า';

  @override
  String get setupWhoTitle => 'คุณกำลังแต่งตัวให้ใคร';

  @override
  String get setupWhoBody =>
      'กำหนดหุ่นสำหรับลองชุดและถ่ายภาพ คุณเปลี่ยนได้ในโปรไฟล์';

  @override
  String get setupStyleTitle => 'คุณใส่สไตล์ไหนบ่อยที่สุด';

  @override
  String get setupStyleBody => 'เลือกได้เลย ไอเดียชุดจะเริ่มจากสไตล์เหล่านี้';

  @override
  String get setupClosetTitle => 'เพิ่มเสื้อผ้าชิ้นแรก';

  @override
  String get setupClosetBody =>
      'ถ่ายรูปเสื้อผ้าหรือกองเสื้อผ้าของคุณ เราจะตัดแยกและจัดเก็บให้';

  @override
  String get setupAddClothes => 'เพิ่มเสื้อผ้า';

  @override
  String get setupStylesLabel => 'สไตล์';

  @override
  String get setupOccasionsLabel => 'โอกาส';

  @override
  String get setupSkipStep => 'ข้าม';

  @override
  String get setupLater => 'ไว้ทีหลัง';

  @override
  String get setupSaveError => 'บันทึกไม่ได้';

  @override
  String get genderWomen => 'ผู้หญิง';

  @override
  String get genderMen => 'ผู้ชาย';

  @override
  String get genderNonBinary => 'ไม่ระบุเพศ';

  @override
  String get genderPreferNotToSay => 'ไม่ต้องการระบุ';

  @override
  String get outfitEmptyTitle => 'ยังไม่มีชุด';

  @override
  String get outfitEmptyBody => 'จับคู่เสื้อผ้าในตู้ของคุณแล้วบันทึกลุคไว้';

  @override
  String get outfitNoMatchesTitle => 'ไม่พบชุดที่ตรงกัน';

  @override
  String get outfitSearchHint => 'ค้นหาชุดของคุณ';

  @override
  String get outfitLoading => 'กำลังโหลดชุดของคุณ';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ชุด',
      one: '1 ชุด',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'สไตล์และฤดูกาล';

  @override
  String get outfitCollections => 'คอลเลกชัน';

  @override
  String get outfitDuplicate => 'ทำซ้ำ';

  @override
  String get outfitDeleteTitle => 'ลบชุดนี้?';

  @override
  String get outfitDeleteBody => 'เสื้อผ้าชิ้นต่างๆ จะยังคงอยู่ในตู้ของคุณ';

  @override
  String get outfitDrafts => 'ฉบับร่าง';

  @override
  String get outfitDraft => 'ฉบับร่าง';

  @override
  String get filterStyle => 'สไตล์';

  @override
  String get filterSeason => 'ฤดูกาล';

  @override
  String get itemDetailDeleteTitle => 'ลบชิ้นนี้?';

  @override
  String get itemDetailDeleteBody => 'ชุดที่ใช้ชิ้นนี้จะไม่มีไอเทมนี้อีกต่อไป';

  @override
  String get itemAddFavourite => 'เพิ่มในรายการโปรด';

  @override
  String itemSize(String size) {
    return 'ไซส์ $size';
  }

  @override
  String get itemColours => 'สี';

  @override
  String get itemMaterial => 'วัสดุ';

  @override
  String get itemPattern => 'ลวดลาย';

  @override
  String get itemUseCases => 'โอกาสในการสวมใส่';

  @override
  String get itemKeptIn => 'เก็บไว้ใน';

  @override
  String get itemPrice => 'ราคา';

  @override
  String get itemBought => 'ซื้อเมื่อ';

  @override
  String get itemTags => 'แท็ก';

  @override
  String get itemAdded => 'เพิ่มเมื่อ';

  @override
  String get itemTimesWornLabel => 'ครั้งที่ใส่';

  @override
  String get itemLastWornLabel => 'ใส่ล่าสุด';

  @override
  String get itemNeverWorn => 'ไม่เคยใส่';

  @override
  String get authEntryBody =>
      'ทุกชิ้นที่คุณมี จัดสไตล์โดย AI วางแผนชุด ลองสวมใส่ และถ่ายภาพ';

  @override
  String get authCreateCloset => 'สร้างตู้เสื้อผ้าของคุณ';

  @override
  String get authWelcomeBack => 'ยินดีต้อนรับกลับมา';

  @override
  String get authSignInBody => 'ลงชื่อเข้าใช้เพื่อเปิดตู้เสื้อผ้าของคุณ';

  @override
  String get authCreateAccount => 'สร้างบัญชี';

  @override
  String get authCreateClosetBody =>
      'ใช้เวลาเพียงครู่เดียว เพิ่มไอเทมแรกของคุณได้ฟรี';

  @override
  String get authName => 'ชื่อ';

  @override
  String get authConfirmPassword => 'ยืนยันรหัสผ่าน';

  @override
  String get authReferralCode => 'รหัสแนะนำ (ไม่บังคับ)';

  @override
  String get authResetTitle => 'รีเซ็ตรหัสผ่านของคุณ';

  @override
  String get authResetBody =>
      'เราจะส่งลิงก์ไปทางอีเมลเพื่อให้คุณตั้งรหัสผ่านใหม่';

  @override
  String get authSendResetLink => 'ส่งลิงก์รีเซ็ต';

  @override
  String get authBackToSignIn => 'กลับไปลงชื่อเข้าใช้';

  @override
  String get authEnterEmail => 'กรอกอีเมลของคุณ';

  @override
  String get authEnterValidEmail => 'กรอกอีเมลให้ถูกต้อง';

  @override
  String get authEnterPassword => 'กรอกรหัสผ่านของคุณ';

  @override
  String get authPasswordTooShort => 'อย่างน้อย 6 ตัวอักษร';

  @override
  String get authShowPassword => 'แสดงรหัสผ่าน';

  @override
  String get authHidePassword => 'ซ่อนรหัสผ่าน';

  @override
  String get authNewHere => 'เพิ่งเคยมาใช่ไหม';

  @override
  String authConfirmEmail(String email) {
    return 'ยืนยัน $email ก่อนลงชื่อเข้าใช้ ตรวจสอบกล่องจดหมายของคุณ';
  }

  @override
  String get authResendEmail => 'ส่งอีกครั้ง';

  @override
  String get authResendingEmail => 'กำลังส่ง...';

  @override
  String get authPasswordsDoNotMatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get authEnterName => 'กรอกชื่อของคุณ';

  @override
  String get authChoosePassword => 'ตั้งรหัสผ่าน';

  @override
  String get authHaveAccount => 'มีบัญชีอยู่แล้วใช่ไหม';

  @override
  String get authCodeAccepted => 'ยอมรับรหัสแล้ว';

  @override
  String get authCodeNotFound => 'ไม่พบรหัส';

  @override
  String authReferralFrom(String name) {
    return 'จาก $name คุณทั้งคู่จะได้รับฟรีหนึ่งเดือน';
  }

  @override
  String get authReferralInvalid => 'เราไม่พบรหัสนี้';

  @override
  String authResetSent(String email) {
    return 'ส่งไปที่ $email แล้ว เปิดลิงก์บนโทรศัพท์เครื่องนี้';
  }

  @override
  String get introSlide1Title => 'ถ่ายรูปตู้เสื้อผ้าของคุณ';

  @override
  String get introSlide1Body =>
      'ถ่ายรูปกองเสื้อผ้า แล้วระบบจะแยกชิ้นและจัดเก็บให้คุณโดยอัตโนมัติ';

  @override
  String get introSlide2Title => 'แต่งตัวได้รวดเร็วขึ้น';

  @override
  String get introSlide2Body =>
      'จัดชุดจากเสื้อผ้าที่คุณมี ให้เข้ากับแผนงานและสภาพอากาศ';

  @override
  String get introSlide3Title => 'ลองชุดก่อนสวมใส่จริง';

  @override
  String get introSlide3Body =>
      'ลองชุดบนรูปถ่ายของคุณ หรือถ่ายภาพให้เหมือนแคมเปญแฟชั่น';

  @override
  String get settingsTheme => 'ธีม';

  @override
  String get settingsThemeSystem => 'ตามระบบ';

  @override
  String get settingsThemeLight => 'สว่าง';

  @override
  String get settingsThemeDark => 'มืด';

  @override
  String get settingsTemperature => 'อุณหภูมิ';

  @override
  String get settingsEmailUpdates => 'อัปเดตทางอีเมล';

  @override
  String get settingsEmailUpdatesBody => 'ข่าวสารและเคล็ดลับทางอีเมล';

  @override
  String get settingsOutfitReminders => 'แจ้งเตือนการแต่งตัว';

  @override
  String get settingsOutfitRemindersBody => 'เตือนให้บันทึกชุดที่คุณสวมใส่';

  @override
  String get settingsWeeklySummary => 'สรุปรายสัปดาห์';

  @override
  String get settingsWeeklySummaryBody => 'สรุปชุดที่คุณใส่ในแต่ละสัปดาห์';

  @override
  String get settingsStyleSection => 'สไตล์';

  @override
  String get settingsPreferredStyles => 'สไตล์ที่คุณชอบ';

  @override
  String get settingsPreferredColours => 'สีที่คุณชอบ';

  @override
  String get settingsNoneChosen => 'ยังไม่ได้เลือก';

  @override
  String get settingsPlanAiSection => 'แผนและ AI';

  @override
  String get settingsPlanBillingBody => 'แผน การใช้งาน และการอัปเกรด';

  @override
  String get settingsPlanUsageBody => 'แผนและการใช้งาน';

  @override
  String get settingsInviteFriends => 'ชวนเพื่อน';

  @override
  String get settingsInviteFriendsBody =>
      'รับฟรีหนึ่งเดือนสำหรับเพื่อนแต่ละคนที่เข้าร่วม';

  @override
  String get settingsAiProvider => 'ผู้ให้บริการ AI';

  @override
  String get settingsAiProviderBody =>
      'ใช้โมเดลของคุณเองสำหรับการแท็กและรูปภาพ';

  @override
  String get settingsAppVersion => 'เวอร์ชันแอป';

  @override
  String get settingsPrivacyTerms => 'ความเป็นส่วนตัวและข้อกำหนด';

  @override
  String get settingsReportProblem => 'รายงานปัญหา';

  @override
  String get settingsChangePassword => 'เปลี่ยนรหัสผ่าน';

  @override
  String get settingsExportData => 'ส่งออกข้อมูลของคุณ';

  @override
  String get settingsExportBody =>
      'เราจะเตรียมไฟล์ข้อมูลทั้งหมดที่คุณบันทึกไว้และเปิดให้ดาวน์โหลด';

  @override
  String get settingsExportAction => 'ส่งออก';

  @override
  String get settingsCurrentPassword => 'รหัสผ่านปัจจุบัน';

  @override
  String get settingsNewPassword => 'รหัสผ่านใหม่';

  @override
  String get settingsConfirmNewPassword => 'ยืนยันรหัสผ่านใหม่';

  @override
  String get settingsEnterCurrentPassword => 'ป้อนรหัสผ่านปัจจุบันของคุณ';

  @override
  String get settingsEnterNewPassword => 'ป้อนรหัสผ่านใหม่';

  @override
  String get settingsPasswordMin8 => 'ใช้ตัวอักษรอย่างน้อย 8 ตัว';

  @override
  String get settingsPasswordNeedsUpper => 'เพิ่มตัวพิมพ์ใหญ่';

  @override
  String get settingsPasswordNeedsLower => 'เพิ่มตัวพิมพ์เล็ก';

  @override
  String get settingsPasswordNeedsDigit => 'เพิ่มตัวเลข';

  @override
  String get settingsPasswordsNoMatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get settingsChangeAction => 'เปลี่ยน';

  @override
  String get itemAddSnapTitle => 'ถ่ายรูปเสื้อผ้า';

  @override
  String get itemAddSnapBody =>
      'เราจะตรวจหาเสื้อผ้าทุกชิ้นในรูปและตัดภาพให้เป็นภาพสตูดิโอที่สะอาดตา';

  @override
  String get itemAddCamera => 'ถ่ายรูป';

  @override
  String get itemAddGallery => 'เลือกจากคลังรูปภาพ';

  @override
  String get itemAddOtherWays => 'วิธีเพิ่มอื่นๆ';

  @override
  String get itemAddSeveral => 'เพิ่มหลายรูป';

  @override
  String get itemAddSeveralBody => 'สูงสุด 50 รูปในครั้งเดียว';

  @override
  String get itemAddImportProfile => 'นำเข้าจากโปรไฟล์';

  @override
  String get itemAddImportProfileBody => 'Instagram หรือ Facebook';

  @override
  String get itemAddEnterDetails => 'กรอกรายละเอียดเอง';

  @override
  String get itemAddEnterDetailsBody => 'ไม่ต้องใช้รูปภาพ';

  @override
  String get itemManualIntro => 'ระบุชื่อก็พอ เพิ่มข้อมูลอื่นได้ภายหลัง';

  @override
  String get itemManualNameHint => 'เช่น เสื้อยืดผ้าฝ้ายสีน้ำเงิน';

  @override
  String get itemManualEnterName => 'ระบุชื่อ';

  @override
  String get itemManualNotes => 'หมายเหตุ';

  @override
  String get itemManualBrand => 'แบรนด์';

  @override
  String get itemManualSize => 'ขนาด';

  @override
  String get itemManualEnterNumber => 'ระบุตัวเลข';

  @override
  String get itemManualSavePiece => 'บันทึกไอเทม';

  @override
  String get itemManualSaving => 'กำลังบันทึก';

  @override
  String get itemManualSavedTitle => 'บันทึกแล้ว';

  @override
  String itemManualSavedBody(String name) {
    return '$name อยู่ในตู้เสื้อผ้าของคุณแล้ว';
  }

  @override
  String get itemManualNotSaved => 'ยังไม่ได้บันทึก';

  @override
  String get itemManualAddUseCase => 'เพิ่มการใช้งาน';

  @override
  String get itemManualAddUseCaseAction => 'เพิ่มการใช้งาน';

  @override
  String get itemPhotos => 'รูปภาพ';

  @override
  String get itemAddPhotos => 'เพิ่มรูปภาพ';

  @override
  String get itemNoPhotoYet => 'ยังไม่มีรูปภาพ คุณสามารถบันทึกโดยไม่ใช้รูปได้';

  @override
  String get itemRemovePhoto => 'ลบรูปภาพ';

  @override
  String get itemRemovePiece => 'ลบไอเทม';

  @override
  String get filterConditionLabel => 'สภาพสินค้า';

  @override
  String get photoshootStepPhotos => 'รูปภาพ';

  @override
  String get photoshootStepSetup => 'ตั้งค่า';

  @override
  String get photoshootStepCreating => 'กำลังสร้าง';

  @override
  String get photoshootStepResults => 'ผลลัพธ์';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'ขั้นตอนที่ $current จาก $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'รูปภาพหนึ่งรูปไม่สำเร็จ ลองใหม่อีกครั้งด้านล่าง';

  @override
  String photoshootManyFailed(int count) {
    return '$count รูปภาพไม่สำเร็จ ลองใหม่แต่ละรูปด้านล่าง';
  }

  @override
  String get photoshootFormat => 'รูปแบบ';

  @override
  String get photoshootHowMany => 'จำนวน';

  @override
  String get photoshootYourPrompt => 'คำสั่งของคุณ';

  @override
  String get photoshootPromptHint => 'แสงเย็นบนดาดฟ้า, เสื้อเชิ้ตลินิน';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'สร้าง $count รูป',
      one: 'สร้าง 1 รูป',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'รูป',
      one: 'รูป',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'ไม่สามารถตรวจสอบขีดจำกัดวันนี้ได้';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'แผน $plan: เหลือ $remaining จาก $limit วันนี้';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'ฟรี';

  @override
  String get photoshootGallery => 'คลังรูปภาพ';

  @override
  String get photoshootUseCamera => 'ใช้กล้อง';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'ลบรูปที่ $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'ไม่พบรูปภาพ';

  @override
  String get photoshootNoPhotosBody =>
      'การถ่ายภาพเสร็จสิ้นโดยไม่มีรูปภาพ ลองใหม่อีกครั้ง';

  @override
  String get photoshootNewStyle => 'สไตล์ใหม่';

  @override
  String get photoshootNewPhotos => 'รูปภาพใหม่';

  @override
  String photoshootOpenPhoto(int number) {
    return 'เปิดรูปที่ $number';
  }

  @override
  String get photoshootReportPhoto => 'รายงานรูปภาพ';

  @override
  String get photoshootSaveToGallery => 'บันทึกลงคลัง';

  @override
  String get actionUpgrade => 'อัปเกรด';

  @override
  String get referralLimitTitle => 'คุณใช้โควตาภาพถ่ายวันนี้หมดแล้ว';

  @override
  String get referralLimitBody =>
      'โควตาภาพถ่ายฟรีจะรีเซ็ตในวันพรุ่งนี้ แนะนำเพื่อนเพื่อรับสิทธิ์ใช้งาน Pro ฟรีหนึ่งเดือนทั้งคู่';

  @override
  String get referralLimitRefer => 'แนะนำเพื่อน';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'แอปหาคู่';

  @override
  String get photoshootUsePortfolio => 'พอร์ตโฟลิโอ';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'สุนทรียภาพ';

  @override
  String get photoshootUseCustom => 'คำสั่งของคุณเอง';

  @override
  String get photoshootDescLinkedin => 'รูปโปรไฟล์ดูเป็นมืออาชีพ';

  @override
  String get photoshootDescDating => 'ผ่อนคลาย อบอุ่น และเป็นธรรมชาติ';

  @override
  String get photoshootDescPortfolio => 'ลุคแฟชั่นชั้นสูงแบบนิตยสาร';

  @override
  String get photoshootDescInstagram => 'ภาพไลฟ์สไตล์สำหรับฟีดของคุณ';

  @override
  String get photoshootDescAesthetic => 'ภาพแนวอาร์ตและมู้ดโทน';

  @override
  String get photoshootDescCustom => 'ระบุลุคที่คุณต้องการ';

  @override
  String get aspectSquare => 'จัตุรัส';

  @override
  String get aspectPortrait => 'แนวตั้ง';

  @override
  String get aspectLandscape => 'แนวนอน';

  @override
  String get aspectTall => 'สูง';

  @override
  String get aspectWide => 'กว้าง';

  @override
  String get tryOnAppBar => 'ลองชุดเสมือนจริง';

  @override
  String get tryOnYourPhoto => 'รูปของคุณ';

  @override
  String get tryOnGarment => 'เสื้อผ้า';

  @override
  String get tryOnUploadingPhoto => 'กำลังอัปโหลดรูปของคุณ';

  @override
  String get tryOnAddPhotoPrompt => 'เพิ่มรูปถ่ายเต็มตัวของคุณ';

  @override
  String get tryOnBodyPhotoHint => 'รูปถ่ายเต็มตัวจะได้ผลดีที่สุด';

  @override
  String get tryOnAddPhoto => 'เพิ่มรูป';

  @override
  String get tryOnChangePhoto => 'เปลี่ยนรูป';

  @override
  String get tryOnPhotoLoadFailed => 'ไม่สามารถโหลดรูปของคุณได้';

  @override
  String get tryOnChooseGarment => 'เลือกรูปเสื้อผ้า';

  @override
  String get tryOnChooseOneGarment => 'เลือกรูปเสื้อผ้าหนึ่งชิ้น';

  @override
  String get tryOnGarmentHint => 'รูปวางราบหรือแขวนไม้แขวนจะได้ผลดีที่สุด';

  @override
  String get tryOnChange => 'เปลี่ยน';

  @override
  String get tryOnCamera => 'กล้อง';

  @override
  String get tryOnRemove => 'ลบ';

  @override
  String get tryOnLookTitle => 'ลุค';

  @override
  String get tryOnStyle => 'สไตล์';

  @override
  String get tryOnBackground => 'พื้นหลัง';

  @override
  String get tryOnPose => 'ท่าโพส';

  @override
  String get tryOnDressingUp => 'กำลังแต่งตัวให้คุณ รอสักครู่ประมาณครึ่งนาที';

  @override
  String get tryOnEmptyResult => 'ผลลัพธ์การลองชุดจะปรากฏที่นี่';

  @override
  String get tryOnReportImage => 'รายงานรูปภาพ';

  @override
  String get tryOnCreating => 'กำลังสร้าง';

  @override
  String get tryOnTryAgain => 'ลองใหม่อีกครั้ง';

  @override
  String get tryOnCreate => 'สร้างการลองชุด';

  @override
  String get tryOnBackgroundStudioWhite => 'สตูดิโอสีขาว';

  @override
  String get tryOnBackgroundStudioGrey => 'สตูดิโอสีเทา';

  @override
  String get tryOnBackgroundUrban => 'ถนนในเมือง';

  @override
  String get tryOnBackgroundNature => 'ธรรมชาติ';

  @override
  String get tryOnBackgroundMinimal => 'มินิมอล';

  @override
  String get tryOnPoseFront => 'ยืนตรง';

  @override
  String get tryOnPoseSide => 'ยืนด้านข้าง';

  @override
  String get tryOnPoseWalking => 'กำลังเดิน';

  @override
  String get dashboardGreetingMorning => 'สวัสดีตอนเช้า';

  @override
  String get dashboardGreetingAfternoon => 'สวัสดีตอนบ่าย';

  @override
  String get dashboardGreetingEvening => 'สวัสดีตอนเย็น';

  @override
  String get dashboardWelcome => 'ยินดีต้อนรับ';

  @override
  String get dashboardOpenProfile => 'เปิดโปรไฟล์';

  @override
  String get dashboardRailToday => 'วันนี้';

  @override
  String get dashboardRailRecently => 'ล่าสุด';

  @override
  String get dashboardActivityEmpty => 'เสื้อผ้าและชุดใหม่จะแสดงที่นี่';

  @override
  String get quickAddPiece => 'เพิ่มเสื้อผ้า';

  @override
  String get quickAddPieceBody => 'ถ่ายรูปและติดแท็ก';

  @override
  String get quickBuildOutfit => 'สร้างชุด';

  @override
  String get quickBuildOutfitBody => 'มิกซ์แอนด์แมตช์';

  @override
  String get quickForYou => 'สำหรับคุณ';

  @override
  String get quickForYouBody => 'แนะนำสำหรับวันนี้';

  @override
  String get quickPlanWeek => 'วางแผนรายสัปดาห์';

  @override
  String get quickPlanWeekBody => 'จัดชุดตามวันที่';

  @override
  String get referralBannerUrgent => 'สิทธิ์ใกล้หมด? ชวนเพื่อนเลย';

  @override
  String get referralBannerTitle => 'ให้เพื่อนหนึ่งเดือน รับฟรีหนึ่งเดือน';

  @override
  String get referralBannerBody => 'คุณและเพื่อนจะได้รับ Pro ฟรีคนละหนึ่งเดือน';

  @override
  String get referralBannerDismiss => 'ปิดไว้หนึ่งสัปดาห์';

  @override
  String get referralBannerShare => 'แชร์คำเชิญ';

  @override
  String get referralBannerCopy => 'คัดลอกลิงก์';

  @override
  String get itemEditPieceTitle => 'แก้ไขชิ้นงาน';

  @override
  String get itemEditDescriptionLabel => 'คำอธิบาย';

  @override
  String get itemEditNotSaved => 'ยังไม่ได้บันทึก';

  @override
  String get itemEditSavedTitle => 'บันทึกแล้ว';

  @override
  String get itemEditSavedBody => 'บันทึกการเปลี่ยนแปลงของคุณเรียบร้อยแล้ว';

  @override
  String get itemEditSavedStalePhotos => 'บันทึกแล้ว — รูปภาพอาจไม่อัปเดต';

  @override
  String get itemEditRemovePieceHint => 'ลบชิ้นงานนี้ออกจากหน้ารายการ';

  @override
  String get itemEditNoPhotos =>
      'ยังไม่มีรูปภาพ เพิ่มรูปจากคลังภาพหรือกล้องของคุณ';

  @override
  String get itemEditKeepPhoto => 'เก็บรูปภาพไว้';

  @override
  String get itemEditRemoved => 'ลบแล้ว';

  @override
  String get itemEditAddUseCaseAction => 'เพิ่ม';

  @override
  String get statsNoStatsTitle => 'ยังไม่มีสถิติ';

  @override
  String get statsNoStatsBody =>
      'เพิ่มเสื้อผ้าสักสองสามชิ้น แล้วสถิติตู้เสื้อผ้าของคุณจะปรากฏที่นี่';

  @override
  String get statsByCategory => 'ตามหมวดหมู่';

  @override
  String get statsTotalValue => 'มูลค่ารวม';

  @override
  String get statsMostWorn => 'ใส่บ่อยที่สุด';

  @override
  String get statsLeastWorn => 'รอคิวใช้งาน';

  @override
  String get statsUnnamedPiece => 'ชิ้นงานที่ไม่มีชื่อ';

  @override
  String get jobsTitle => 'การสแกน';

  @override
  String get jobsEmptyTitle => 'ยังไม่มีการสแกน';

  @override
  String get jobsEmptyBody =>
      'ถ่ายรูปเสื้อผ้าแล้วปล่อยให้ระบบทำงานเบื้องหลัง คุณสามารถตรวจสอบสถานะได้ที่นี่';

  @override
  String get jobsNotCancelled => 'ไม่ได้ยกเลิก';

  @override
  String get jobsResume => 'ทำต่อ';

  @override
  String get jobsReview => 'ตรวจสอบ';

  @override
  String get jobsStop => 'หยุด';

  @override
  String get jobsDismiss => 'ปิด';

  @override
  String get reportTitle => 'รายงานเนื้อหา';

  @override
  String reportIntro(String contentType) {
    return 'แจ้งให้เราทราบว่า $contentType นี้มีปัญหาอย่างไร ทีมงานของเราจะตรวจสอบทุกรายงาน';
  }

  @override
  String get reportReasonInappropriate => 'ไม่เหมาะสมหรือหยาบคาย';

  @override
  String get reportReasonNudity => 'ภาพเปลือยหรือเนื้อหาทางเพศ';

  @override
  String get reportReasonHarassment => 'การคุกคามหรือล่วงละเมิด';

  @override
  String get reportReasonImpersonation => 'การแอบอ้างบุคคลอื่น';

  @override
  String get reportReasonOther => 'อื่นๆ';

  @override
  String get reportDetailsLabel => 'รายละเอียดเพิ่มเติม (ไม่บังคับ)';

  @override
  String get reportSubmit => 'ส่งรายงาน';

  @override
  String get reportSubmittedTitle => 'ส่งรายงานแล้ว';

  @override
  String get reportSubmittedBody => 'ขอบคุณ ทีมงานของเราจะตรวจสอบเนื้อหานี้';

  @override
  String get reportFailedTitle => 'ไม่สามารถส่งรายงานได้';

  @override
  String get reportFailedBody => 'โปรดลองใหม่อีกครั้ง';

  @override
  String get reportContentTryOnImage => 'รูปภาพลองชุด AI';

  @override
  String get reportContentSharedOutfit => 'ชุดที่แชร์';

  @override
  String get reportContentPhotoshootImage => 'รูปภาพถ่ายแบบ AI';

  @override
  String get sharedOutfitTitle => 'ชุดที่แชร์';

  @override
  String get sharedOutfitHideTooltip => 'ซ่อนชุดนี้';

  @override
  String get sharedOutfitReportTooltip => 'รายงานชุดนี้';

  @override
  String get sharedOutfitHideTitle => 'ซ่อนชุดนี้หรือไม่';

  @override
  String get sharedOutfitHideBody =>
      'ชุดจะถูกซ่อนบนอุปกรณ์นี้ คุณสามารถรายงานเพื่อให้ทีมงานตรวจสอบและลบออกได้';

  @override
  String get sharedOutfitHideAction => 'ซ่อน';

  @override
  String get sharedOutfitHiddenInfo => 'ชุดนี้จะไม่แสดงบนอุปกรณ์นี้อีก';

  @override
  String get sharedOutfitHiddenToast => 'ซ่อนชุดแล้ว';

  @override
  String get sharedOutfitMissingTitle => 'ไม่พบชุดนี้แล้ว';

  @override
  String get sharedOutfitMissingBody => 'ชุดอาจถูกลบออกหรือลิงก์ไม่ถูกต้อง';

  @override
  String get sharedOutfitHiddenStateTitle => 'คุณซ่อนชุดนี้แล้ว';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'หากเนื้อหาไม่เหมาะสม โปรดรายงานผ่านความเป็นส่วนตัวและข้อกำหนด หรืออีเมล $email';
  }

  @override
  String get sharedOutfitCtaTitle => 'ชอบลุคนี้ไหม';

  @override
  String get sharedOutfitCtaBody => 'สร้างลุคแบบนี้จากตู้เสื้อผ้าของคุณเอง';

  @override
  String get sharedOutfitCtaButton => 'ใช้ FitCheck AI';

  @override
  String get errorTitle => 'ข้อผิดพลาด';

  @override
  String get errorUnknown => 'เกิดข้อผิดพลาดที่ไม่คาดคิด';

  @override
  String get errorNoConnection => 'ไม่มีอินเทอร์เน็ต ตรวจสอบเครือข่ายของคุณ';

  @override
  String get errorTimeout => 'หมดเวลาในการส่งคำขอ ลองใหม่อีกครั้ง';

  @override
  String get errorServerError =>
      'เกิดความขัดข้องบนเซิร์ฟเวอร์ของเรา ลองใหม่อีกครั้ง';

  @override
  String get errorBadGateway =>
      'เซิร์ฟเวอร์ของเราใช้งานชั่วคราวไม่ได้ ลองใหม่อีกครั้ง';

  @override
  String get errorServiceUnavailable =>
      'บริการใช้งานชั่วคราวไม่ได้ ลองใหม่อีกครั้งในภายหลัง';

  @override
  String get errorInternalError => 'เกิดความขัดข้อง ลองใหม่อีกครั้ง';

  @override
  String get errorUnauthorized => 'กรุณาเข้าสู่ระบบเพื่อต่อ';

  @override
  String get errorForbidden => 'คุณไม่มีสิทธิ์เข้าถึงรายการนี้';

  @override
  String get errorSessionExpired => 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบอีกครั้ง';

  @override
  String get errorInvalidCredentials => 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';

  @override
  String get errorTokenRefreshFailed =>
      'ไม่สามารถรีเฟรชเซสชันได้ กรุณาเข้าสู่ระบบอีกครั้ง';

  @override
  String get errorRequestCancelled => 'ยกเลิกคำขอแล้ว';

  @override
  String get errorInvalidFormat => 'รูปแบบไฟล์นี้ไม่รองรับ';

  @override
  String get errorFileTooLarge => 'ไฟล์นี้ใหญ่เกินกำหนด';

  @override
  String get errorUploadFailed => 'อัปโหลดไม่สำเร็จ ลองใหม่อีกครั้ง';

  @override
  String get errorCacheCorrupted => 'ข้อมูลที่ถูกบันทึกเสียหายและถูกรเซ็ตแล้ว';

  @override
  String get errorCacheNotFound => 'ยังไม่มีข้อมูลที่ถูกบันทึก';

  @override
  String get errorUserNotFound => 'ไม่พบบัญชีนี้';

  @override
  String get errorItemNotFound => 'รายการนี้ไม่ได้อีกแล้ว';

  @override
  String get errorOutfitNotFound => 'ลุคนี้อาจไม่ได้อีกแล้ว';

  @override
  String get rewardsTitle => 'รางวัล';

  @override
  String get rewardsNoAchievementsTitle => 'ยังไม่มีการบรรลุเป้าหมาย';

  @override
  String get rewardsNoAchievementsBody =>
      'เพิ่มชุดและวางแผนลุคเพื่อรับรางวัลแรกของคุณ';

  @override
  String get rewardsEmptyLeaderboardTitle => 'ยังไม่มีใครอยู่ในกระดาน';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'วางแผนลุคเพื่อรับคะแนนและขึ้นติดบอร์ด';

  @override
  String get legalViewPrivacyPolicy => 'ดูนโยบายความเป็นส่วนตัว';

  @override
  String get aiConsentAgree => 'ฉันตกลงและดำเนินการต่อ';

  @override
  String get aiConsentNotNow => 'ภายหลัง';

  @override
  String get imageViewerCloseTooltip => 'ปิดดูรูปภาพ';

  @override
  String get updateReadyTitle => 'พร้อมอัปเดต';

  @override
  String get updateReadyBody => 'รีสตาร์ท FitCheck AI เพื่อใช้อัปเดตล่าสุด';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI ต้องเข้าถึงกล้องเพื่อถ่ายภาพชุดของคุณ';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI ต้องเข้าถึงคลังรูปภาพเพื่อเลือกรูปชุดของคุณ';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI ต้องบันทึกภาพชุดจาก AI ของคุณลงในคลังรูปภาพ';

  @override
  String get wardrobeSomePhotosSkipped => 'ข้ามรูปบางส่วน';

  @override
  String get wardrobePhotosNotAdded => 'ยังไม่ได้เพิ่มรูป';

  @override
  String get wardrobePhotoNotAdded => 'ยังไม่ได้เพิ่มรูป';

  @override
  String get wardrobeNotStartedTitle => 'ไม่ได้เริ่ม';

  @override
  String get wardrobeNoRoomTitle => 'ไม่มีพื้นที่';

  @override
  String get wardrobeAddPhotosSemantic => 'เพิ่มรูปภาพ';

  @override
  String get batchAddTileLabel => 'เพิ่ม';

  @override
  String get batchProfileLinkLabel => 'ลิงก์โปรไฟล์';

  @override
  String get wardrobeImportFromProfileTitle => 'นำเข้าจากโปรไฟล์';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'เพิ่มหลายรูป';

  @override
  String get wardrobeClearAction => 'ล้าง';

  @override
  String get wardrobeRefreshTooltip => 'รีเฟรช';

  @override
  String get batchNoPhotosYetTitle => 'ยังไม่มีรูปภาพ';

  @override
  String get batchChoosePhotosAction => 'เลือกรูปภาพ';

  @override
  String get batchWeFindEachPieceBody =>
      'เราค้นหาชิ้นส่วนแต่ละชิ้นและทำสตูดิโอโฟโตให้';

  @override
  String get batchPreparingPhotosSemantic => 'กำลังเตรียมรูปภาพ';

  @override
  String get batchPhotosProcessedSemantic => 'ประมวลผลรูปแล้ว';

  @override
  String get batchPasteProfileLinkTitle => 'วางลิงก์โปรไฟล์';

  @override
  String get batchPasteProfileLinkBody =>
      'โปรไฟล์ Instagram หรือ Facebook แบบสาธารณะ เราสแกนรูปและคุณเลือกสิ่งที่เข้าไปในตู้เสื้อผ้าของคุณ';

  @override
  String get batchClearLinkTooltip => 'ล้างลิงก์';

  @override
  String get batchStartingButton => 'กำลังเริ่ม';

  @override
  String get batchStartImportAction => 'เริ่มนำเข้า';

  @override
  String get batchReviewEveryPhotoTitle => 'คุณตรวจสอบทุกรูป';

  @override
  String get batchReviewEveryPhotoBody => 'ไม่มีอะไรถูกเพิ่มจนกว่าคุณจะอนุมัติ';

  @override
  String get batchPrivateProfilesTitle => 'โปรไฟล์ส่วนตัว';

  @override
  String get batchPrivateProfilesBody =>
      'เชื่อมต่อบัญชีของคุณ Instagram จำชื่อผู้ใช้และรหัสผ่านด้วยเช่นกัน';

  @override
  String get batchUseAnotherLinkAction => 'ใช้ลิงก์อื่น';

  @override
  String get batchSignInNeededTitle => 'ต้องเข้าสู่ระบบ';

  @override
  String get batchEnterYourCodeTitle => 'กรอกรหัสของคุณ';

  @override
  String get batchUseUsernamePasswordAction => 'ใช้ชื่อผู้ใช้และรหัสผ่าน';

  @override
  String get batchAlreadyConnectedAction => 'เชื่อมต่อผ่านเบราว์เซอร์แล้ว';

  @override
  String get batchEnterCodeAction => 'กรอกรหัส';

  @override
  String get batchTryAnotherWayAction => 'ลองวิธีอื่น';

  @override
  String get batchLiveStatus => 'สด';

  @override
  String get batchReconnectingStatus => 'กำลังเชื่อมต่อใหม่';

  @override
  String get batchSignInToInstagramTitle => 'เข้าสู่ระบบ Instagram';

  @override
  String get batchUsernameLabel => 'ชื่อผู้ใช้';

  @override
  String get batchCodeIfTwoStepLabel => 'รหัส หากใช้การยืนยันตัวตนสองขั้นตอน';

  @override
  String get batchAuthenticatorCodeBody =>
      'ใช้รหัส 6 หลักจากแอป authenticator รหัสเปลี่ยนบ่อย';

  @override
  String get batchVerifyAction => 'ตรวจสอบ';

  @override
  String get batchFindingPhotosTitle => 'กำลังค้นหาภาพ';

  @override
  String get batchImportPausedTitle => 'ระงับการนำเข้า';

  @override
  String get batchProcessingPhotosTitle => 'กำลังประมวลผลภาพ';

  @override
  String get batchWaitingNextPhoto => 'กำลังรอภาพถัดไป';

  @override
  String get batchCancelImportAction => 'ยกเลิกการนำเข้า';

  @override
  String get batchNoPiecesInPhotoBody => 'ไม่พบชิ้นใด ๆ ในภาพนี้';

  @override
  String get batchEditPieceColoursLabel => 'สี คั่นด้วยเครื่องหมายจุลภาค';

  @override
  String get batchAddToClosetAction => 'เพิ่มในตู้เสื้อผ้า';

  @override
  String get batchSkipPhotoAction => 'ข้ามภาพนี้';

  @override
  String get batchImportCompleteTitle => 'นำเข้าเสร็จสิ้น';

  @override
  String get batchImportFailedTitle => 'นำเข้าล้มเหลว';

  @override
  String get batchImportCancelledTitle => 'ยกเลิกการนำเข้าแล้ว';

  @override
  String get batchImportErrorBody => 'เกิดข้อผิดพลาดระหว่างการนำเข้า';

  @override
  String get batchNothingMoreImportedBody =>
      'ไม่มีอะไรเพิ่มเติมที่ถูกนำเข้าจากโปรไฟล์นี้แล้ว';

  @override
  String get batchViewClosetAction => 'ดูตู้เสื้อผ้า';

  @override
  String get batchStartOverAction => 'เริ่มใหม่';

  @override
  String get wardrobeAddPieceTitle => 'เพิ่มไอเทม';

  @override
  String get wardrobeAddDetailsTitle => 'เพิ่มรายละเอียด';

  @override
  String get wardrobeScanningTitle => 'กำลังสแกน';

  @override
  String get batchReviewPiecesTitle => 'ตรวจสอบไอเทม';

  @override
  String get wardrobeGalleryAction => 'แกลเลอรี';

  @override
  String get wardrobeCameraAction => 'กล้อง';

  @override
  String get wardrobeNewBadge => 'ใหม่';

  @override
  String get wardrobeRemovePhotoTooltip => 'ลบรูปภาพ';

  @override
  String get batchRunInBackgroundTooltip => 'ทำงานเบื้องหลัง';

  @override
  String get batchStepOneOfTwo => 'ขั้นตอนที่ 1 จาก 2';

  @override
  String get batchStepTwoOfTwo => 'ขั้นตอนที่ 2 จาก 2';

  @override
  String get batchUploadingPhotosTitle => 'กำลังอัปโหลดรูปภาพ';

  @override
  String get batchFindingPiecesTitle => 'กำลังค้นหาไอเทม';

  @override
  String get batchMakingStudioPhotosTitle => 'กำลังสร้างภาพสตูดิโอ';

  @override
  String get batchStoppedLabel => 'หยุดแล้ว';

  @override
  String get batchFindingPiecesStoppedTitle => 'หยุดค้นหาไอเทมแล้ว';

  @override
  String get batchCancelledLabel => 'ยกเลิกแล้ว';

  @override
  String get batchAllDoneTitle => 'เสร็จเรียบร้อย';

  @override
  String get batchOpeningPiecesBody => 'กำลังเปิดไอเทมของคุณ';

  @override
  String get batchNothingSavedBody => 'ไม่ได้บันทึกข้อมูลใด ๆ';

  @override
  String get batchFindingPiecesFailedBody => 'การหาไอเทมล้มเหลว';

  @override
  String get batchFindingPiecesStoppedEarlyBody => 'การหาไอเทมหยุดก่อนเวลา';

  @override
  String get batchStopFindingPiecesTitle => 'หยุดค้นหาไอเทมหรือไม่';

  @override
  String get batchStopFindingPiecesBody =>
      'การสแกนจะหยุดและไม่มีการบันทึก ไอเทมที่หาได้จะยังคงอยู่ในกิจกรรมจนกว่าคุณจะปิด';

  @override
  String get batchKeepGoingAction => 'ดำเนินการต่อ';

  @override
  String get batchTryAgainAction => 'ลองใหม่';

  @override
  String get batchBackToPhotosAction => 'กลับไปที่รูปภาพ';

  @override
  String get batchSkipAllAction => 'ข้ามทั้งหมด';

  @override
  String get batchIncludeAllAction => 'รวมทั้งหมด';

  @override
  String get batchNoPiecesFoundTitle => 'ไม่พบเสื้อผ้า';

  @override
  String get batchNoPiecesFoundBody => 'ไม่พบเสื้อผ้าในรูปเหล่านี้';

  @override
  String get batchChooseOtherPhotosAction => 'เลือกรูปอื่น';

  @override
  String get batchUseCaseHelper => 'เพิ่มให้กับทุกชิ้นที่คุณบันทึก';

  @override
  String get batchDiscardPiecesTitle => 'ทิ้งชิ้นเหล่านี้หรือไม่';

  @override
  String get batchDiscardPiecesBody => 'ยังไม่ได้บันทึกชิ้นใด ๆ จากชุดนี้';

  @override
  String get batchKeepAction => 'เก็บไว้';

  @override
  String get batchDiscardAction => 'ทิ้ง';

  @override
  String get batchRemovePieceTitle => 'นำชิ้นนี้ออกหรือไม่';

  @override
  String get batchRemovePieceBody => 'ชิ้นนี้ไม่ถูกบันทึกในตู้เสื้อผ้า';

  @override
  String get batchRemoveAction => 'นำออก';

  @override
  String get batchChoosePiecesToSave => 'เลือกชิ้นที่ต้องการบันทึก';

  @override
  String get batchDiscardAllAction => 'ทิ้งทั้งหมด';

  @override
  String get batchNothingSavedRetryBody => 'ไม่ได้บันทึกใด ๆ ลองใหม่อีกครั้ง';

  @override
  String get batchNotSavedTitle => 'ไม่ได้บันทึก';

  @override
  String get batchSavingLabel => 'กำลังบันทึก';

  @override
  String get batchSendToBackgroundAction => 'ส่งไปทำงานเบื้องหลัง';

  @override
  String get batchStillWorkingMessage =>
      'กำลังทำงานอยู่ เราจะแจ้งให้ทราบเมื่อพร้อม';

  @override
  String get batchRunningInBackgroundTitle => 'กำลังทำงานเบื้องหลัง';

  @override
  String get batchStudioPhotosStoppedBody =>
      'การถ่ายภาพสตูดอยกเลิกก่อน คุณยังบันทึกชิ้นเหล่านี้ได้';

  @override
  String get batchTapPieceToSkip => 'แตะชิ้นใดเพื่อข้าม';

  @override
  String get batchStudioPhotosOnWayBody =>
      'ภาพสตูดอยังอยู่ในระหว่างทำงาน คุณออกได้ เราจะแจ้งให้ทราบ';

  @override
  String get batchLeaveAction => 'ออก';

  @override
  String get batchPeopleInPhotosTitle => 'คนในรูป';

  @override
  String get batchIncludeAction => 'รวม';

  @override
  String get batchSkipAction => 'ข้าม';

  @override
  String get batchYourPhotoIsUsedLabel => 'ใช้รูปของคุณแล้ว';

  @override
  String get batchMakingStudioPhotoLabel => 'กำลังทำรูปสตูดิโอ';

  @override
  String get batchNoStudioPhotoBody => 'ไม่มีรูปสตูดิโอ ใช้รูปของคุณแทน';

  @override
  String get batchEnterDetailsYourselfAction => 'กรอกข้อมูลด้วยตนเอง';

  @override
  String get batchChooseAnotherPhotoAction => 'เลือกภาพอื่น';

  @override
  String get batchConnectionLostTitle => 'การเชื่อมต่อขาดหาย';

  @override
  String get batchConnectionLostBody => 'ตรวจสอบการเชื่อมต่อแล้วลองใหม่';

  @override
  String get batchDailyLimitTitle => 'เข้าถึงขีดจำกัดรายวัน';

  @override
  String get batchDailyLimitBodyPaywall =>
      'อัปเกรดเป็น Pro เพื่อสแกนมากขึ้น หรือกรอกข้อมูลด้วยตนเอง';

  @override
  String get batchDailyLimitBodyFree =>
      'การสแกนของคุณจะรีเซ็ตพรุ่งนี้ คุณสามารถกรอกข้อมูลด้วยตนเองได้ตอนนี้';

  @override
  String get batchSeePlansAction => 'ดูแพ็กเกจ';

  @override
  String get batchAiBusyTitle => 'AI ของเราไม่ว่าง';

  @override
  String get batchAiBusyBody =>
      'ปัญหาเกิดจากฝั่งเรา โปรดลองใหม่ในอีกไม่กี่นาที';

  @override
  String get batchNoPiecesBody =>
      'ลองใช้ภาพที่ชัดเจนขึ้น หรือกรอกข้อมูลด้วยตนเอง';

  @override
  String get batchScanningUnavailableTitle => 'ไม่สามารถสแกนได้';

  @override
  String get batchScanningUnavailableBody =>
      'กรุณากรอกข้อมูลด้วยตนเองในช่วงนี้';

  @override
  String get batchScanDidNotFinishTitle => 'การสแกนไม่เสร็จสิ้น';

  @override
  String get batchTryAgainBody => 'ลองใหม่';

  @override
  String get billingTitle => 'การสมัครสมาชิกรายเดือน';

  @override
  String get billingUpgradeHeading => 'อัปเกรดแพ็กเกจของคุณ';

  @override
  String get billingUpgradeOnPlusBody => 'ฟีเจอร์เดิมขีดจำกัดสูงขึ้น';

  @override
  String get billingUpgradeBody =>
      'Plus และ Pro มีฟีเจอร์เหมือนกัน เลือกขีดจำกัดที่คุณต้องการ';

  @override
  String get billingWebUnavailableBody =>
      'การอัปเกรดออนไลน์ยังไม่พร้อมใช้งาน รหัสโปรโมชันหรือรหัสแนะนำยังคงปลดล็อก Plus หรือ Pro ได้ เชิญเพื่อนด้านล่างเพื่อรับเดือนฟรี';

  @override
  String get billingPlansStale =>
      'โหลดแพ็กเกจล่าสุดไม่สำเร็จ ราคาอาจไม่ถูกต้อง';

  @override
  String get billingMonthly => 'รายเดือน';

  @override
  String get billingYearly => 'รายปี';

  @override
  String get billingCurrentPlan => 'แพ็กเกจปัจจุบัน';

  @override
  String get billingActive => 'ใช้งานอยู่';

  @override
  String get billingThisMonth => 'เดือนนี้';

  @override
  String get billingItemExtractions => 'การดึงข้อมูลสิ่งของ';

  @override
  String get billingOutfitVisualizations => 'การสร้างภาพชุดเสื้อผ้า';

  @override
  String get billingNearLimitUpgrade =>
      'คุณใกล้ถึงขีดจำกัดของเดือนนี้ อัปเกรดเพื่อรับเพิ่มเติม';

  @override
  String get billingNearLimitResets =>
      'คุณใกล้ถึงขีดจำกัดของเดือนนี้ จะรีเซ็ตเมื่อเข้าเดือนถัดไป';

  @override
  String get billingStoreUnavailable =>
      'การอัปเกรดยังไม่มีในสโตร์ กรุณากลับมาตรวจสอบอีกครั้ง';

  @override
  String get billingManageHeading => 'จัดการแผนของคุณ';

  @override
  String get billingCancelPlan => 'ยกเลิกการสมัคร';

  @override
  String get billingCancelKeepsAccess =>
      'คุณยังคงเข้าถึงได้จนถึงสิ้นรอบการเรียกเก็บเงินนี้';

  @override
  String get billingCancelConfirmTitle => 'ยกเลิกการสมัครของคุณหรือไม่';

  @override
  String get billingKeepPlan => 'รักษาแผนเดิม';

  @override
  String get billingCancelPlanAction => 'ยกเลิกแผน';

  @override
  String get billingBilledMonthly => 'เรียกเก็บเงินรายเดือน';

  @override
  String get billingBilledYearly => 'เรียกเก็บเงินรายปี';

  @override
  String get billingVirtualTryOn => 'ลองสวมใส่เสมือนจริง';

  @override
  String get billingPrioritySupport => 'การสนับสนุนด่วน';

  @override
  String get billingDisclosureProRenewing =>
      'Pro เป็นการสมัครสมาชิกแบบต่ออายุอัตโนมัติ';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus และ Pro เป็นการสมัครสมาชิกแบบต่ออายุอัตโนมัติ';

  @override
  String get billingDisclosureAppleBilling =>
      'ยอดชำระจะถูกคิดจาก Apple ID ของคุณเมื่อยืนยันการซื้อ';

  @override
  String get billingDisclosureGoogleBilling =>
      'ยอดชำระจะถูกคิดจากบัญชี Google Play ของคุณเมื่อยืนยันการซื้อ';

  @override
  String get billingDisclosureRenewalTerms =>
      'การสมัครสมาชิกของคุณจะต่ออายุอัตโนมัติในระยะเวลาและราคาเดิม เว้นแต่คุณจะปิดการต่ออายุอัตโนมัติอย่างน้อย 24 ชั่วโมงก่อนสิ้นสุดรอบปัจจุบัน';

  @override
  String get billingDisclosureAppleManage =>
      'จัดการหรือยกเลิกได้ทุกเมื่อใน การตั้งค่า › Apple ID ของคุณ › การสมัครสมาชิก';

  @override
  String get billingDisclosureGoogleManage =>
      'จัดการหรือยกเลิกได้ทุกเมื่อใน Google Play › การชำระเงินและการสมัครสมาชิก';

  @override
  String get billingReferFriend => 'แนะนำเพื่อน';

  @override
  String get billingHowItWorks => 'วิธีใช้งาน';

  @override
  String get billingHowShareTitle => 'แชร์ลิงก์ของคุณ';

  @override
  String get billingHowShareBody => 'ส่งต่อให้เพื่อนของคุณ';

  @override
  String get billingHowSignUpTitle => 'พวกเขาสมัครสมาชิก';

  @override
  String get billingHowSignUpBody => 'เพื่อนของคุณเข้าร่วมจากลิงก์';

  @override
  String get billingHowBothTitle => 'คุณทั้งสองได้ Pro';

  @override
  String get billingHowBothBody => 'คุณแต่ละคนจะได้รับ Pro ฟรี 1 เดือน';

  @override
  String get billingYourReferrals => 'การแนะนำของคุณ';

  @override
  String get billingInvited => 'เชิญแล้ว';

  @override
  String get billingJoined => 'เข้าร่วมแล้ว';

  @override
  String get billingMonthsEarned => 'จำนวนเดือนที่ได้รับ';

  @override
  String get billingInviteFriend => 'ชวนเพื่อน';

  @override
  String get billingInviteBody => 'คุณและเพื่อนได้ใช้ Pro 1 เดือนคนละครั้ง';

  @override
  String get billingYourCode => 'โค้ดของคุณ';

  @override
  String get billingCopyLink => 'คัดลอกลิงก์';

  @override
  String get billingShareInvite => 'แบ่งปันคำเชิญ';

  @override
  String get giftUnavailable => 'ไม่สามารถส่งคำเชิญของขวัญได้ในเวอร์ชันนี้';

  @override
  String get giftPageTitle => 'มอบ FitCheck Pro เป็นของขวัญ';

  @override
  String get giftNoAllowances => 'ไม่มีคำเชิญของขวัญแบบฟรีในขณะนี้';

  @override
  String get giftFormTitle => 'ส่งคำเชิญฟรี';

  @override
  String get giftFormBody =>
      'ผู้รับต้องยืนยันอีเมลเพื่อรับของขวัญ คุณไม่ต้องส่งอีเมลให้พวกเขาเอง';

  @override
  String get giftFieldFrom => 'จาก';

  @override
  String get giftFieldRecipientName => 'ชื่อผู้รับ';

  @override
  String get giftFieldRecipientEmail => 'อีเมลผู้รับ';

  @override
  String get giftFieldOccasion => 'วาระ (ไม่บังคับ)';

  @override
  String get giftNoOccasion => 'ไม่มีวาระ';

  @override
  String get giftOccasionBirthday => 'วันเกิด';

  @override
  String get giftOccasionAnniversary => 'ครบรอบ';

  @override
  String get giftOccasionOther => 'อื่น ๆ';

  @override
  String get giftFieldCardGreeting => 'ข้อความในบัตรอวยพร';

  @override
  String get giftFieldCardGreetingHelper => 'ข้อความนี้จะแสดงในบัตรตามที่ระบุ';

  @override
  String get giftFieldPrivateNote => 'ข้อความส่วนตัว (ไม่บังคับ)';

  @override
  String get giftCreateAction => 'สร้างของขวัญฟรี';

  @override
  String get giftClaimedTitle => 'รับของขวัญแล้ว';

  @override
  String get giftClaimedActive => 'ของขวัญ FitCheck Pro ของคุณพร้อมใช้งานแล้ว';

  @override
  String get giftClaimedQueued =>
      'ของขวัญ FitCheck Pro ของคุณจะเริ่มหลังสิทธิ์ปัจจุบันหมดอายุ';

  @override
  String get giftLinkCopied => 'คัดลอกลิงก์ของขวัญลงคลิปบอร์ดแล้ว';

  @override
  String get giftErrorName => 'กรุณากรอกชื่อ';

  @override
  String get giftErrorEmail => 'กรุณากรอกอีเมลที่ถูกต้อง';

  @override
  String get giftErrorGreeting => 'กรุณากรอกข้อความในบัตรอวยพร';

  @override
  String get giftErrorGreetingLength => 'ใช้ไม่เกิน 80 ตัวอักษร';

  @override
  String get giftClaimAction => 'รับของขวัญ';

  @override
  String get giftCardPreview => 'ตัวอย่างบัตร';

  @override
  String get giftGiftForYou => 'ของขวัญสำหรับคุณ';

  @override
  String get giftGiftWaiting => 'มีของขวัญรอคุณอยู่';

  @override
  String get giftOpenBody => 'เปิดของขวัญเพื่อรับสิทธิ์ผ่านอีเมลที่ยืนยันแล้ว';

  @override
  String get giftOpenGifts => 'เปิดของขวัญ';

  @override
  String get giftSendInvitation => 'ส่งคำเชิญ';

  @override
  String get settingsAiProviderSection => 'ผู้ให้บริการ';

  @override
  String get settingsAiCustom => 'กำหนดเอง';

  @override
  String get settingsAiUrlHelper =>
      'ใช้ URL สาธารณะที่เซิร์ฟเวอร์เข้าถึงได้ localhost ไม่ทำงานจากเซิร์ฟเวอร์ของเรา';

  @override
  String get settingsAiConnectionSection => 'การเชื่อมต่อ';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'คีย์ API';

  @override
  String get settingsAiApiKeySaved => 'บันทึกแล้ว ทิ้งว่างเพื่อรักษาไว้';

  @override
  String get settingsAiChatModel => 'โมเดลแชท';

  @override
  String get settingsAiVisionModel => 'โมเดลวิชชั่น (ไม่บังคับ)';

  @override
  String get settingsAiImageModel => 'โมเดลรูปภาพ (ไม่บังคับ)';

  @override
  String get settingsAiImageModelNote =>
      'การสร้างรูปภาพต้องใช้ chat completions ที่เข้ากันได้กับ OpenAI พร้อม response_modalities';

  @override
  String get settingsAiTestConnection => 'ทดสอบการเชื่อมต่อ';

  @override
  String get calendarTitle => 'ปฏิทิน';

  @override
  String get calendarGoToToday => 'ไปยังวันนี้';

  @override
  String get calendarConnectTooltip => 'เชื่อมต่อปฏิทิน';

  @override
  String get calendarAddEvent => 'เพิ่มเหตุการณ์';

  @override
  String get calendarEmptyTitle => 'ไม่มีแผนใดๆ';

  @override
  String get calendarEmptyBody => 'เพิ่มเหตุการณ์และวางแผนว่าใส่ชุดอะไรดี';

  @override
  String get calendarPreviousMonth => 'เดือนก่อน';

  @override
  String get calendarNextMonth => 'เดือนถัดไป';

  @override
  String get calendarAllDay => 'ตลอดวัน';

  @override
  String get calendarOutfitLinked => 'ชุดที่เชื่อมโยงแล้ว';

  @override
  String get calendarEventOptions => 'ตัวเลือกเหตุการณ์';

  @override
  String get calendarDeleteTitle => 'ลบอีเวนต์นี้?';

  @override
  String get calendarChangeOutfit => 'เปลี่ยนชุด';

  @override
  String get calendarLinkOutfit => 'ลิงก์ชุด';

  @override
  String get calendarRemoveOutfit => 'ลบชุด';

  @override
  String get calendarNewEvent => 'อีเวนต์ใหม่';

  @override
  String get calendarEditEvent => 'แก้ไขอีเวนต์';

  @override
  String get calendarTitleLabel => 'ชื่อ';

  @override
  String get calendarTitleRequired => 'เพิ่มชื่อ';

  @override
  String get calendarEndBeforeStart => 'เวลาสิ้นสุดต้องหลังเวลาเริ่ม';

  @override
  String get calendarStarts => 'เริ่ม';

  @override
  String get calendarEnds => 'สิ้นสุด';

  @override
  String get calendarPlaceOptional => 'สถานที่ (ไม่บังคับ)';

  @override
  String get calendarNotesOptional => 'หมายเหตุ (ไม่บังคับ)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'สร้างชุดก่อน แล้วจึงลิงก์เข้ากับอีเวนต์นี้';

  @override
  String get calendarBuildOutfit => 'สร้างชุด';

  @override
  String get calendarConnectionsTitle => 'ปฏิทิน';

  @override
  String get calendarConnectionsBody =>
      'อีเวนต์ที่คุณเพิ่มจะอยู่ใน FitCheck เท่านั้น';

  @override
  String get calendarDisconnect => 'ตัดการเชื่อมต่อ';

  @override
  String get calendarNotAvailable => 'ยังไม่มีให้';

  @override
  String get profileSectionExplore => 'สำรวจ';

  @override
  String get profileNavTryOn => 'ลองใส่';

  @override
  String get profileNavRewards => 'รางวัล';

  @override
  String get profileSupport => 'ติดต่อฝ่ายสนับสนุน';

  @override
  String get profileHelp => 'ความช่วยเหลือ';

  @override
  String get profileAbout => 'เกี่ยวกับ';

  @override
  String get profileAboutBody => 'ตู้เสื้อผ้า ชุด และแผนของคุณในที่เดียว';

  @override
  String get profileSignOutTitle => 'ออกจากระบบ?';

  @override
  String get profileSignOutBody => 'คุณสามารถเข้าสู่ระบบใหม่ได้ทุกเมื่อ';

  @override
  String get profileEditTitle => 'แก้ไขโปรไฟล์';

  @override
  String get profileYourProfile => 'โปรไฟล์ของคุณ';

  @override
  String get profileBodyProfiles => 'โปรไฟล์ร่างกาย';

  @override
  String get profileBodyEmptyTitle => 'ยังไม่มีโปรไฟล์ร่างกาย';

  @override
  String get profileBodyEmptyBody =>
      'เพิ่มส่วนสูงและรูปร่างเพื่อขนาดที่พอดีขึ้น';

  @override
  String get profileBodyAdd => 'เพิ่มโปรไฟล์';

  @override
  String get profileBodyDefaultNote =>
      'โปรไฟล์เริ่มต้นของคุณจะถูกใช้สำหรับการปรับขนาดและการลองสวมใส่';

  @override
  String get profileBodyDefaultBadge => 'เริ่มต้น';

  @override
  String get profileBodyMakeDefault => 'ตั้งเป็นเริ่มต้น';

  @override
  String get profileBodyDeleteBody => 'ไม่สามารถเลิกทำขั้นตอนนี้ได้';

  @override
  String get profileBodyRequired => 'จำเป็น';

  @override
  String get profileBodyCheckNumber => 'ตรวจสอบตัวเลขนี้';

  @override
  String get profileBodyNew => 'โปรไฟล์ร่างกายใหม่';

  @override
  String get profileBodyNameHint => 'เช่น ฉัน';

  @override
  String get profileBodyHeight => 'ส่วนสูง';

  @override
  String get profileBodyWeight => 'น้ำหนัก';

  @override
  String get profileBodyBuild => 'รูปร่าง';

  @override
  String get profileBodySkinTone => 'สีผิว';

  @override
  String get profileBirthDateNeededBody =>
      'เพิ่มวันเกิดเพื่อใช้ร่วมกับเวลาเกิด';

  @override
  String get profileBirthDateNeededTitle => 'ต้องระบุวันเกิด';

  @override
  String get profilePartlySavedBody =>
      'บันทึกชื่อและรูปของคุณแล้ว รายละเอียดวันเกิดไม่ได้บันทึก ลองใหม่ภายหลัง';

  @override
  String get profilePartlySavedTitle => 'บันทึกบางส่วน';

  @override
  String get profileSavedBody => 'โปรไฟล์ของคุณถูกบันทึกแล้ว';

  @override
  String get profileChangePhoto => 'เปลี่ยนรูปโปรไฟล์';

  @override
  String get profilePhotoLabel => 'รูปโปรไฟล์';

  @override
  String get profilePhotoHint => 'แตะเพื่อเลือกใหม่';

  @override
  String get profileBirthDateLabel => 'วันเกิด (ไม่บังคับ)';

  @override
  String get profileBirthTimeLabel => 'เวลาเกิด (ไม่บังคับ)';

  @override
  String get profileBirthTimeHelper => 'ทำให้น้ำเสนอแบบเวดีคแม่นยำขึ้น';

  @override
  String get profileBirthPlaceLabel => 'สถานที่เกิด (ไม่บังคับ)';

  @override
  String get profileBirthPlaceHint => 'เช่น นิวเดลี อินเดีย';

  @override
  String get profileHelpContactTitle => 'ถามเราได้ทุกเรื่อง';

  @override
  String get profileHelpContactBody =>
      'ส่งข้อความแล้วเราจะตอบกลับทางอีเมลภายใน 1 วัน';

  @override
  String get profileHelpContactAction => 'ติดต่อฝ่ายบริการ';

  @override
  String get profileHelpFaqTitle => 'คำถามที่พบบ่อย';

  @override
  String get profileFaqAddPiecesTitle => 'วิธีเพิ่มชิ้นงานในตู้เสื้อผ้า';

  @override
  String get profileFaqAddPiecesBody =>
      'แตะ เพิ่มรายการ ในแท็บ ตู้เสื้อผ้า ถ่ายภาพหรือเลือกจากคลังของเรา ระบบจะค้นหาและติดแท็กชิ้นงานให้';

  @override
  String get profileFaqMatchingTitle => 'การจัดชุดทำงานอย่างไร';

  @override
  String get profileFaqMatchingBody =>
      'เปิด แนะนำสำหรับคุณ แล้วเลือกชิ้นงานที่คุณมี ระบบแนะนำชิ้นที่เข้ากันแล้วจัดเต็มชุดจากตู้เสื้อผ้าของคุณ';

  @override
  String get profileFaqTryOnTitle => 'ใช้รูปตัวเองลองชุดได้ไหม';

  @override
  String get profileFaqTryOnBody =>
      'ได้ เพิ่มภาพเต็มตัวแล้วเลือกชิ้นงานเพื่อดูบนตัวคุณ';

  @override
  String get profileFaqRewardsTitle => 'วิธีรับรางวัล';

  @override
  String get profileFaqRewardsBody =>
      'วางแผนและบันทึกชุดบ่อย ๆ รางวัลสะสมและความสำเร็จจะเพิ่มขึ้นเมื่อใช้งาน';

  @override
  String get profileFaqPrivacyTitle => 'ตู้เสื้อผ้าของฉันเป็นส่วนตัวหรือไม่';

  @override
  String get profileFaqPrivacyBody =>
      'ใช่ ตู้เสื้อผ้าและชุดจะส่วนตัว เว้นแต่จะแชร์ลิงก์ของชุดใดชุดหนึ่ง';

  @override
  String get profileHelpMoreTitle => 'ความช่วยเหลือเพิ่มเติม';

  @override
  String get profileHelpGuides => 'คู่มือ';

  @override
  String get profileHelpGuidesBody => 'วิธีการทำงานของฟีเจอร์ต่าง ๆ';

  @override
  String get feedbackCategoryBug => 'เจอปัญหา';

  @override
  String get feedbackCategoryIdea => 'ไอเดีย';

  @override
  String get feedbackCategoryGeneral => 'ทั่วไป';

  @override
  String get feedbackCategoryHelp => 'ต้องการความช่วยเหลือ';

  @override
  String get feedbackHintBug =>
      'เกิดอะไรขึ้น และคาดหวังอย่างไร ขั้นตอนช่วยให้เราแก้ไข';

  @override
  String get feedbackHintIdea => 'ต้องการอะไร และเพราะเหตุใด';

  @override
  String get feedbackHintGeneral => 'บอกเราว่าคุณคิดอย่างไร หรือตั้งคำถาม';

  @override
  String get feedbackAttachmentLimitBody => 'แนบภาพได้สูงสุด 5 รูป';

  @override
  String get feedbackAttachmentLimitTitle => 'ถึงขีดจำกัด';

  @override
  String get feedbackImageTooLargeBody => 'เลือกภาพขนาดเล็กกว่า 5 MB';

  @override
  String get feedbackImageTooLargeTitle => 'ภาพมีขนาดใหญ่เกินไป';

  @override
  String get feedbackTitle => 'ส่งข้อเสนอแนะ';

  @override
  String get feedbackAboutLabel => 'เกี่ยวกับอะไร';

  @override
  String get feedbackSubjectLabel => 'หัวข้อ';

  @override
  String get feedbackSubjectRequired => 'Add a subject';

  @override
  String get feedbackSubjectTooShort => 'Subject must be at least 3 characters';

  @override
  String get feedbackDetailsLabel => 'Details';

  @override
  String get feedbackDetailsRequired => 'Add some details';

  @override
  String get feedbackDetailsTooShort =>
      'Description must be at least 10 characters';

  @override
  String get feedbackAddScreenshot => 'Add a screenshot';

  @override
  String get feedbackAttachmentHint => 'Up to 5, 5 MB each';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackEmptyTitle => 'Nothing sent yet';

  @override
  String get feedbackEmptyBody =>
      'What you send shows up here with its status.';

  @override
  String get feedbackHistoryTitle => 'What you sent';

  @override
  String get feedbackStatusOpen => 'Open';

  @override
  String get feedbackStatusInProgress => 'In progress';

  @override
  String get feedbackStatusResolved => 'Resolved';

  @override
  String get feedbackStatusClosed => 'Closed';

  @override
  String get legalIntro =>
      'How we protect your data, and the terms for using FitCheck AI.';

  @override
  String get legalPolicies => 'Policies';

  @override
  String get legalPrivacySubtitle => 'What we collect and why';

  @override
  String get legalTermsTitle => 'Terms of service';

  @override
  String get legalTermsSubtitle => 'The rules for using the app';

  @override
  String get legalLicences => 'Open-source licences';

  @override
  String get legalSupportSubtitle => 'Help, contact and privacy requests';

  @override
  String get legalReportAbuse => 'Report a problem or abuse';

  @override
  String get permissionCameraTitle => 'Camera Access';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI uses your camera to capture photos of your clothing and outfits for AI try-on and closet organization.';

  @override
  String get permissionPhotoTitle => 'Photo Access';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI needs access to your photos so you can select clothing and outfit images for AI features and your closet.';

  @override
  String get permissionNotNow => 'Not Now';

  @override
  String get permissionOpenSettings => 'Open Settings';

  @override
  String authSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get authSignedIn => 'เข้าสู่ระบบแล้ว';

  @override
  String get authWelcomeBackTitle => 'ยินดีต้อนรับกลับ';

  @override
  String get authSignInFailed => 'เข้าสู่ระบบล้มเหลว';

  @override
  String get authWelcomeTitle => 'ยินดีต้อนรับ';

  @override
  String get authSignUpFailed => 'สมัครสมาชิกล้มเหลว';

  @override
  String get authGoogleSignInFailed => 'เข้าสู่ระบบด้วย Google ล้มเหลว';

  @override
  String get authAppleSignInFailed => 'เข้าสู่ระบบด้วย Apple ล้มเหลว';

  @override
  String get authConfirmEmailTitle => 'ยืนยันอีเมลของคุณ';

  @override
  String get authConfirmEmailBody =>
      'ตรวจสอบอีเมลในกล่องจดหมายของคุณเพื่อรับอีเมลยืนยัน จากนั้นเข้าสู่ระบบ';

  @override
  String get authClosetReady => 'ตู้เสื้อผ้าของคุณพร้อมแล้ว';

  @override
  String get authSignedOutTitle => 'ออกจากระบบแล้ว';

  @override
  String get authSignedOutBody => 'คุณออกจากระบบแล้ว';

  @override
  String get authSignOutFailed => 'การออกจากระบบล้มเหลว';

  @override
  String get authEmailSentTitle => 'ส่งอีเมลแล้ว';

  @override
  String get authResetLinkSent => 'ตรวจสอบลิงก์รีเซ็ตในอีเมลของคุณ';

  @override
  String get authPasswordUpdatedTitle => 'อัปเดตรหัสผ่านแล้ว';

  @override
  String get authPasswordUpdated => 'อัปเดตรหัสผ่านของคุณแล้ว';

  @override
  String get authPasswordNotUpdated => 'ไม่ได้อัปเดตรหัสผ่าน';

  @override
  String get authCouldNotSendEmail => 'ไม่สามารถส่งอีเมลได้';

  @override
  String get authEmailNotSent => 'ไม่ได้ออกไปอีเมล';

  @override
  String get authResendSentBody => 'เราส่งอีเมลยืนยันใหม่ให้แล้ว';

  @override
  String get outfitPreviewWithAi => 'ตัวอย่างกับ AI';

  @override
  String get outfitNewPreview => 'สร้างตัวอย่างใหม่';

  @override
  String get outfitBuilderClosetHeading => 'ตู้เสื้อผ้าของคุณ';

  @override
  String get outfitBuilderSearchHint => 'ค้นหาชิ้นส่วน';

  @override
  String get outfitClearSearch => 'ล้างการค้นหา';

  @override
  String get outfitBuilderAddPiecesTitle => 'เพิ่มชิ้นส่วนก่อน';

  @override
  String get outfitBuilderAddPiecesBody =>
      'ลุคชุดสร้างจากชิ้นส่วนในตู้เสื้อผ้าของคุณ';

  @override
  String get outfitBuilderNoMatches => 'ไม่มีชิ้นส่วนที่ตรงกัน';

  @override
  String get outfitNameLabel => 'ชื่อชุด';

  @override
  String get outfitNameHint => 'เช่น ลินินสุดวิคเอนด์';

  @override
  String get outfitPreviewSemantic => 'พรีวิวชุดจาก AI';

  @override
  String get outfitChoosePieces => 'เลือกรายการ';

  @override
  String get outfitTapPiecesHint => 'แตะรายการด้านล่างเพื่อเพิ่ม';

  @override
  String get outfitShareTooltip => 'แชร์';

  @override
  String get outfitSaveFavourite => 'บันทึกในรายการโปรด';

  @override
  String get outfitPiecesHeading => 'รายการ';

  @override
  String get outfitWearHistoryEmpty => 'ใส่สักครั้ง แล้ววันที่จะแสดงที่นี่';

  @override
  String get outfitWearHistoryTitle => 'ประวัติการใส่';

  @override
  String get outfitWearHistoryError => 'โหลดวันที่ไม่สำเร็จ';

  @override
  String get outfitWornOn => 'ใส่เมื่อ';

  @override
  String get outfitEditTitle => 'แก้ไขชุด';

  @override
  String get outfitSavedPhotosFailed => 'บันทึกข้อมูลแล้ว แต่รูปไม่สำเร็จ';

  @override
  String get outfitNoPhotosBody => 'ยังไม่มีรูป ระบบจะแสดงรายการแทน';

  @override
  String get outfitOccasionLabel => 'โอกาส';

  @override
  String get outfitOccasionNone => 'ไม่มี';

  @override
  String get outfitTagsHint => 'คั่นด้วยเครื่องหมายจุลภาค';

  @override
  String get outfitDraftBody => 'ซ่อนจากรายการหลักของคุณ';

  @override
  String get outfitPublic => 'สาธารณะ';

  @override
  String get outfitPublicBody => 'ทุกคนที่มีลิงก์สามารถดูได้';

  @override
  String get outfitDeleteFromDetail => 'ลบชุดนี้จากหน้ารายละเอียด';

  @override
  String get outfitNewCollection => 'คอลเลกชันใหม่';

  @override
  String get outfitNoCollectionsTitle => 'ยังไม่มีคอลเลกชัน';

  @override
  String get outfitNoCollectionsBody => 'จัดกลุ่มชุดตามทริป ฤดู หรืออารมณ์';

  @override
  String get outfitCreateCollection => 'สร้างคอลเลกชัน';

  @override
  String get outfitAddOutfits => 'เพิ่มชุด';

  @override
  String get outfitRename => 'เปลี่ยนชื่อ';

  @override
  String get outfitCollectionDeleteBody => 'ชุดในนี้จะยังคงอยู่';

  @override
  String get outfitCollectionsNotLoaded => 'โหลดชุดไม่สำเร็จ';

  @override
  String get outfitRenameCollection => 'เปลี่ยนชื่อคอลเลกชัน';

  @override
  String get outfitDescriptionOptional => 'คำอธิบาย (ไม่บังคับ)';

  @override
  String get outfitAllInCollection => 'ชุดทั้งหมดอยู่ในคอลเล็กชันนี้อยู่แล้ว';

  @override
  String get photoshootSubtitleUpload =>
      'ภาพบุคลิกจากสตูดิโอโดยใช้ภาพของคุณเอง';

  @override
  String get photoshootSubtitleConfigure => 'เลือกสไตล์ รูปแบบ และจำนวน';

  @override
  String get photoshootSubtitleGenerating => 'ขั้นตอนนี้อาจใช้เวลา 1-2 นาที';

  @override
  String get photoshootAddPhotosSemantic => 'เพิ่มรูปภาพจากคลังภาพของคุณ';

  @override
  String get photoshootUploadTitle => 'เพิ่มรูปของคุณ 1-4 ภาพ';

  @override
  String get photoshootUploadBody => 'แตะเพื่อเลือกจากคลังภาพของคุณ';

  @override
  String get photoshootAddToContinue => 'เพิ่มรูปภาพเพื่อดำเนินการต่อ';

  @override
  String get photoshootAddAnotherPhoto => 'เพิ่มรูปภาพอีก';

  @override
  String get photoshootTipsTitle => 'เพื่อผลลัพธ์ที่ดีที่สุด';

  @override
  String get photoshootTipsBody =>
      'ใช้ภาพใบหน้าของคุณที่ชัดเจนและสว่างเพียงพอจากหลายมุม หลีกเลี่ยงการใส่แว่นกันแดดและหมวก';

  @override
  String get photoshootStarting => 'กำลังเริ่มต้น';

  @override
  String get photoshootCancelling => 'กำลังยกเลิก';

  @override
  String get photoshootFailed => 'ล้มเหลว';

  @override
  String get recommendTabMatches => 'ที่เข้ากัน';

  @override
  String get recommendTabComplete => 'ให้ครบชุด';

  @override
  String get recommendTabWeather => 'สภาพอากาศ';

  @override
  String get recommendTabColours => 'สี';

  @override
  String get recommendTabShop => 'ช้อปปิ้ง';

  @override
  String get recommendNoMatchesTitle => 'ยังไม่มีรายการที่เข้ากัน';

  @override
  String get recommendNoMatchesBody =>
      'เลือกชิ้นไหนก็ได้ แล้วเราจะหาของที่เข้ากันให้';

  @override
  String get recommendPickPiece => 'เลือกชิ้น';

  @override
  String get recommendNothingMatchesTitle =>
      'ยังไม่มีรายการที่เข้ากับรายการนี้';

  @override
  String get recommendNothingMatchesBody =>
      'ลองเลือกชิ้นอื่น หรือเพิ่มชิ้นใหม่ในตู้เสื้อผ้าของคุณ';

  @override
  String get recommendChangePieces => 'เปลี่ยนชิ้น';

  @override
  String get recommendDefaultReason => 'เข้ากับชิ้นที่คุณเลือก';

  @override
  String get recommendCompleteTitle => 'ให้ลุคนี้ครบ';

  @override
  String get recommendCompleteBody =>
      'เลือกชิ้นใดก็ได้ แล้วเราจะเติมส่วนที่เหลือให้';

  @override
  String get recommendWorking => 'กำลังประมวลผล';

  @override
  String get recommendGenerate => 'สร้าง';

  @override
  String get recommendChooseStyleBody => 'เลือกสไตล์ แล้วสร้างลุค';

  @override
  String get recommendNoLooksTitle => 'ไม่มีลุคสำหรับชิ้นเหล่านี้';

  @override
  String get recommendNoLooksBody => 'ลองสไตล์อื่นหรือชิ้นอื่นดู';

  @override
  String get recommendDefaultLook => 'ลุคสำหรับชิ้นที่มี';

  @override
  String get recommendNoPiecesBody => 'ไม่มีชิ้นในลุคนี้';

  @override
  String get recommendCityLabel => 'เมือง';

  @override
  String get recommendCheck => 'ตรวจสอบ';

  @override
  String get recommendWeatherTitle => 'อากาศเป็นยังไง';

  @override
  String get recommendWeatherBody => 'ระบุเมืองเพื่อรับคำแนะนำสำหรับวันนี้';

  @override
  String get recommendWearToday => 'ใส่ในวันนี้';

  @override
  String get recommendWeatherNoPieces => 'ยังไม่มีชิ้นที่เข้ากับอากาศนี้';

  @override
  String get recommendBudgetLabel => 'งบประมาณไม่เกิน';

  @override
  String get recommendLooking => 'กำลังค้นหา';

  @override
  String get recommendFindWhatToBuy => 'หาสิ่งที่ควรซื้อ';

  @override
  String get recommendFillGapsTitle => 'เติมเต็มช่องว่าง';

  @override
  String get recommendFillGapsBody =>
      'ตั้งงบประมาณ เรายินดีแนะนำสิ่งที่ชุดของคุณขาด';

  @override
  String get recommendNoGapsTitle => 'ไม่พบช่องว่าง';

  @override
  String get recommendNoGapsBody => 'เพิ่มงบประมาณหรือเลือกหมวดอื่น';

  @override
  String get recommendMoodEveryday => 'ทุกวัน';

  @override
  String get recommendMoodBigMeeting => 'ประชุมสำคัญ';

  @override
  String get recommendDayLabel => 'วัน';

  @override
  String get recommendReadingStars => 'อ่านดวงดาว';

  @override
  String get recommendGetMyColours => 'หาสีมงคลของฉัน';

  @override
  String get recommendLuckyColoursTitle => 'สีมงคลของคุณ';

  @override
  String get recommendLuckyColoursBody =>
      'เลือกวัน เรายินดีแนะนำสีและชิ้นที่เข้ากัน';

  @override
  String get recommendLuckyColoursSection => 'สีมงคล';

  @override
  String get recommendAvoidColoursSection => 'สีที่ควรหลีกเลี่ยง';

  @override
  String get recommendBirthDateTitle => 'เพิ่มวันเกิดของคุณ';

  @override
  String get recommendBirthDateBody => 'ต้องระบุวันเกิดเพื่ออ่านสีมงคล';

  @override
  String get recommendEditProfile => 'แก้ไขโปรไฟล์';

  @override
  String get recommendNothingThisDay => 'ไม่มีอะไรในวันนี้';

  @override
  String get recommendUnnamedColour => 'สีไม่มีชื่อ';

  @override
  String get recommendFromCloset => 'จากตู้เสื้อผ้าของคุณ';

  @override
  String get recommendNoPiecesInColours => 'ยังไม่มีชิ้นส่วนในสีเหล่านี้';

  @override
  String get recommendOutfitIdeas => 'ไอเดียชุด';

  @override
  String get recommendNoOutfitsInColours => 'ยังไม่มีชุดเต็มในสีเหล่านี้';

  @override
  String get recommendDefaultOutfitIdea => 'ไอเดียชุด';

  @override
  String get recommendPickUpToThree => 'เลือกได้ไม่เกิน 3 ชิ้น';

  @override
  String get recommendEmptyClosetBody =>
      'เพิ่มเสื้อผ้าสักชิ้นสองชิ้นก่อน แล้วกลับมาจับคู่ต่อ';

  @override
  String get dashboardDressForDay => 'แต่งตัวให้เข้ากับวันข้างหน้า';

  @override
  String get dashboardOutfitOfDay => 'ชุดของวัน';

  @override
  String get dashboardFreshLook => 'ลุคใหม่ ๆ';

  @override
  String get subscriptionManageInStoreTitle => 'จัดการในร้านค้า';

  @override
  String get subscriptionManageInStoreBody =>
      'แผนนี้เรียกเก็บเงินผ่านร้านค้า จัดการได้ใน càiการบัญชีร้านค้าของคุณ';

  @override
  String get subscriptionCancelledTitle => 'ยกเลิกการสมัครแล้ว';

  @override
  String get subscriptionCancelledBody => 'แผนของคุณจะใช้งานต่อจนครบรอบบิลนี';

  @override
  String get subscriptionCancelFailedTitle => 'ยกเลิกไม่สำเร็จ';

  @override
  String get subscriptionCouldNotOpenTitle => 'เปิดไม่ได้';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'เปิดหน้าจัดการการเรียกเก็บเงินไม่สำเร็จ';

  @override
  String get subscriptionOpenLinkFailedBody => 'เปิดลิงก์ไม่ได้';

  @override
  String get subscriptionReferralLoadFailedTitle => 'โหลดลิงก์ไม่สำเร็จ';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'โหลดลิงก์แนะนำไม่สำเร็จ ลองใหม่อีกครั้ง';

  @override
  String get subscriptionReferralCopiedTitle => 'คัดลอกแล้ว';

  @override
  String get subscriptionReferralCopiedBody => 'คัดลอกลิงก์แนะนำแล้ว';

  @override
  String get subscriptionReferralShareSubject => 'ลองใช้ FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'เข้าร่วม FitCheck AI แล้วพวกเราจะได้รับ Pro ฟรีเป็นเวลานาน 1 เดือน $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'คัดลอกลิงก์แล้ว';

  @override
  String get subscriptionShareUnavailableBody =>
      'แชร์ไม่ได้ จึงคัดลอกลิงก์ไว้ให้แทน';

  @override
  String get subscriptionShareFailedTitle => 'แชร์ไม่สำเร็จ';

  @override
  String get subscriptionShareFailedBody => 'คัดลอกลิงก์จากหน้าชวนเพื่อนแทน';

  @override
  String get subscriptionStoreReadyTitle => 'ร้านค้าพร้อมใช้งาน';

  @override
  String get subscriptionStoreReadyBody =>
      'ราคาสินค้าพร้อมใช้งานแล้ว อัปเกรดตอนนี้ได้เลย';

  @override
  String get purchaseFailedTitle => 'การซื้อล้มเหลว';

  @override
  String get purchaseUnavailableTitle => 'ไม่สามารถซื้อได้';

  @override
  String get purchaseIapUnavailableBody =>
      'การซื้อในแอปไม่พร้อมใช้งานบนอุปกรณ์นี้';

  @override
  String get purchasePlanNotAvailableBody => 'แผนนี้ยังไม่เปิดขาย';

  @override
  String get purchasePlanNotInStoreBody =>
      'แผนนี้ยังไม่มีในร้านค้า โปรดกลับมาตรวจสอบอีกครั้งภายหลัง';

  @override
  String get purchaseStartFailedBody => 'เริ่มต้นซื้อไม่ได้ ลองใหม่อีกครั้ง';

  @override
  String get purchaseNoPaymentLinkBody =>
      'หน้าชำระเงินไม่ส่งลิงก์การชำระเงินกลับมา';

  @override
  String get purchasePendingTitle => 'กำลังตรวจสอบการซื้อ';

  @override
  String get purchasePendingBody =>
      'รอการอนุมัติการซื้อ คุณจะได้รับสิทธิ์ทันทีที่อนุมัติแล้ว';

  @override
  String get purchaseFailedBody => 'การซื้อล้มเหลว ลองใหม่อีกครั้ง';

  @override
  String get purchaseRestoredTitle => 'กู้คืนแล้ว';

  @override
  String get purchaseRestoredBody => 'กู้คืนรายการซื้อของคุณแล้ว';

  @override
  String get purchaseActiveTitle => 'สมัครสมาชิกรอดำเนินการ';

  @override
  String get purchaseActiveBody => 'การสมัครสมาชิกของคุณอยู่สถานะใช้งานต้อนรับ';

  @override
  String get purchaseSignInRequiredTitle => 'ต้องเข้าสู่ระบบ';

  @override
  String get purchaseSignInRequiredBody => 'เข้าสู่ระบบเพื่อจบกระบวนการซื้อ';

  @override
  String get purchaseErrorTitle => 'ข้อผิดพลาดในการซื้อ';

  @override
  String get purchaseInvalidTransactionBody =>
      'รายการซื้อไม่มี ID รายการที่ตรวจสอบได้';

  @override
  String get purchaseVerificationPendingTitle => 'กำลังยืนยันการซื้อ';

  @override
  String get purchaseVerificationPendingBody =>
      'ไม่สามารถยืนยันการซื้อกับร้านค้าได้ในตอนนี้ ระบบจะดำเนินการให้เสร็จโดยอัตโนมัติ และคุณจะไม่ถูกเรียกเก็บเงินซ้ำ';

  @override
  String get purchaseNotAppliedTitle => 'ยังไม่ประยุกต์ใช้การซื้อ';

  @override
  String get purchaseNotAppliedBody =>
      'ไม่สามารถนำการซื้อมาใช้ในการบัญชีของคุณ ติดต่อฝ่ายสนับสนุนและอย่าซื้อซ้ำ';

  @override
  String get purchaseRestoreFailedTitle => 'กู้คืนล้มเหลว';

  @override
  String get purchaseRestoreFailedBody =>
      'กู้คืนรายการซื้อไม่ได้ ลองใหม่อีกครั้ง';

  @override
  String get purchaseRecoveredActiveBody =>
      'การสมัครสมาชิกของคุณอยู่สถานะใช้งาน';

  @override
  String get purchaseCompleteTitle => 'ซื้อเสร็จแล้ว';

  @override
  String get giftCreateFailedTitle => 'ไม่สามารถสร้างของขวัญได้';

  @override
  String get giftClaimFailedTitle => 'รับของขวัญไม่ได้';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ของขวัญสำหรับคุณ $count ชิ้น',
      one: 'ของขวัญสำหรับคุณ 1 ชิ้น',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 เดือน',
      '12': '1 ปี',
      'other': '$months เดือน',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'เหลือ $remaining',
      one: 'เหลือ 1',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration ของ FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender ส่ง $duration ของ FitCheck Pro ให้คุณ $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'ของขวัญ FitCheck Pro สำหรับ $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'จาก $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'สำหรับ $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'จาก $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'ผู้รับของคุณ';

  @override
  String get giftPreviewPlaceholderSender => 'คุณ';

  @override
  String get settingsSavedTitle => 'บันทึกแล้ว';

  @override
  String get settingsNotSavedTitle => 'ยังไม่บันทึก';

  @override
  String get settingsAiChooseProviderBody => 'เลือกผู้ให้บริการ';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'ผู้ให้บริการแบบกำหนดเองต้องมี URL API';

  @override
  String get settingsAiKeyRequiredBody => 'ป้อน API key';

  @override
  String get settingsAiSavedBody => 'บันทึกค่า AI ของคุณแล้ว';

  @override
  String get settingsAiMissingDetailsTitle => 'ข้อมูลไม่ครบ';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'ป้อน URL API และโมเดลแชทเพื่อทดสอบ';

  @override
  String get settingsAiKeyNeededTitle => 'ต้องใช้ API key';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'ป้อน API key ของคุณเพื่อทดสอบ API key ที่บันทึกไว้จะไม่ถูกเปิดเผย';

  @override
  String get settingsAiKeyToTestBody => 'ป้อน API key ของคุณเพื่อทดสอบ';

  @override
  String get settingsAiConnectedTitle => 'เชื่อมต่อแล้ว';

  @override
  String get settingsAiConnectedBody => 'การเชื่อมต่อทำงานปกติ';

  @override
  String get settingsAiTestFailedTitle => 'ทดสอบล้มเหลว';

  @override
  String get settingsPreferencesSavedBody => 'บันทึกการตั้งค่าของคุณแล้ว';

  @override
  String get settingsPasswordNotChangedTitle => 'ไม่ได้เปลี่ยนรหัสผ่าน';

  @override
  String get settingsOAuthPasswordBody =>
      'บัญชีนี้เข้าระบบด้วย Google หรือ Apple ใช้ \"ลืมรหัสผ่าน\" เพื่อกำหนดรหัสผ่านก่อน';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'รหัสผ่านปัจจุบันไม่ถูกต้อง';

  @override
  String get settingsExportReadyTitle => 'พร้อมส่งออกแล้ว';

  @override
  String get settingsExportReadyBody =>
      'ข้อมูลการส่งออกของคุณพร้อมให้ดาวน์โหลดแล้ว';

  @override
  String get settingsLinkCopiedTitle => 'คัดลอกลิงก์แล้ว';

  @override
  String get settingsExportClipboardBody =>
      'ไม่สามารถเปิดเบราว์เซอร์ของคุณได้ จึงคัดลอกลิงก์ดาวน์โหลดแล้ว กรุณาวางลิงก์ในเบราว์เซอร์โดยเร็วที่สุด เนื่องจากลิงก์จะหมดอายุ';

  @override
  String get settingsExportFailedTitle => 'การส่งออกล้มเหลว';

  @override
  String get settingsAccountNotDeletedTitle => 'ไม่ได้ออกบัญชี';

  @override
  String photoshootPhotoLimit(int max) {
    return 'คุณสามารถเพิ่มรูปภาพได้สูงสุด $max รูป';
  }

  @override
  String get photoshootPhotoLimitTitle => 'ขีดจำกัดรูปภาพ';

  @override
  String get photoshootAddAtLeastOnePhoto => 'เพิ่มรูปภาพอย่างน้อยหนึ่งรูป';

  @override
  String get photoshootNoPhotosSelectedTitle => 'ไม่มีรูปภาพ';

  @override
  String get photoshootDescribeLookBody => 'อธิบายลุคที่คุณต้องการ';

  @override
  String get photoshootPromptNeededTitle => 'ต้องระบุคำสั่ง';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'กำลังเตรียมรูปภาพของคุณ';

  @override
  String get photoshootStatusGenerating => 'กำลังสร้าง';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'ชุดที่ $current จาก $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'เสร็จแล้ว $done จาก $total';
  }

  @override
  String get photoshootGenerationFailedBody => 'การสร้างล้มเหลว';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return 'พร้อมแล้ว $ready ล้มเหลว $failed';
  }

  @override
  String get photoshootPartlyDoneTitle => 'เสร็จบางส่วน';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'พร้อมแล้ว $count รูป',
      one: 'พร้อมแล้ว 1 รูป',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => 'การเชื่อมต่อสูญหาย กรุณาลองใหม่';

  @override
  String get photoshootCouldNotCancelTitle => 'ไม่ สามารถยกเลิกได้';

  @override
  String get photoshootRetryFailedTitle => 'ลองใหม่อีกครั้งไม่สำเร็จ';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'รูปภาพที่ $number พร้อมแล้ว';
  }

  @override
  String get photoshootReplacedTitle => 'เปลี่ยนแล้ว';

  @override
  String get photoshootSavedToGalleryBody => 'บันทึกเข้าแกลเลอรีของคุณแล้ว';

  @override
  String get photoshootSavedTitle => 'บันทึกแล้ว';

  @override
  String get photoshootNotSavedTitle => 'ไม่ได้บันทึก';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'มี $count รูปทั้งหมดในแกลเลอรีของคุณแล้ว',
      one: 'มี 1 รูปในแกลเลอรีของคุณแล้ว',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return 'บันทึก $saved จาก $total รูป';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'บางรูปภาพไม่ได้รับการบันทึก';

  @override
  String get tryonConsentFeatureLabel => 'ลองเสื้อผ้าเสมือนจริง';

  @override
  String get tryonAvatarUpdatedBody => 'อัปเดตรูปภาพของคุณแล้ว';

  @override
  String get tryonSavedTitle => 'บันทึกแล้ว';

  @override
  String get tryonUploadFailedTitle => 'อัปโหลดล้มเหลว';

  @override
  String get tryonChooseGarmentFirstBody => 'เลือกรูปเสื้อผ้าก่อน';

  @override
  String get tryonNoGarmentTitle => 'ไม่มีเสื้อผ้า';

  @override
  String get tryonWaitForUploadBody => 'รอให้อัปโหลดรูปภาพเสร็จสิ้น';

  @override
  String get tryonStillUploadingTitle => 'กำลังอัปโหลดอยู่';

  @override
  String get tryonAddYourPhotoFirstBody => 'เพิ่มรูปภาพของคุณก่อน';

  @override
  String get tryonReadyBody => 'พร้อมสำหรับชุดลองของคุณแล้ว';

  @override
  String get tryonFailedTitle => 'ชุดลองล้มเหลว';

  @override
  String get tryonSavedToGalleryBody => 'บันทึกลงในแกลเลอรีของคุณแล้ว';

  @override
  String get tryonNotSavedTitle => 'ไม่ได้บันทึก';

  @override
  String get calendarEventAddedBody => 'เพิ่มเหตุการณ์แล้ว';

  @override
  String get calendarEventPlannedTitle => 'วางแผนแล้ว';

  @override
  String get calendarEventSavedBody => 'บันทึกเหตุการณ์แล้ว';

  @override
  String get calendarSavedTitle => 'บันทึกแล้ว';

  @override
  String get calendarEventNotSavedTitle => 'ไม่ได้บันทึกเหตุการณ์';

  @override
  String get calendarEventRemovedBody => 'ลบเหตุการณ์แล้ว';

  @override
  String get calendarEventDeletedTitle => 'ลบแล้ว';

  @override
  String get calendarEventNotDeletedTitle => 'ไม่ได้ลบเหตุการณ์';

  @override
  String get calendarOutfitNotLinkedTitle => 'ไม่ได้ลิงก์ชุด';

  @override
  String get calendarLinkedTitle => 'ลิงก์แล้ว';

  @override
  String get calendarOutfitNotRemovedTitle => 'ไม่ได้ลบชุด';

  @override
  String get calendarOutfitRemovedBody => 'ลบชุดแล้ว';

  @override
  String get calendarDisconnectedBody => 'ยกเลิกการเชื่อมต่อปฏิทินแล้ว';

  @override
  String get calendarDisconnectedTitle => 'ยกเลิกการเชื่อมต่อแล้ว';

  @override
  String get calendarNotDisconnectedTitle => 'ไม่ได้ยกเลิกการเชื่อมต่อปฏิทิน';

  @override
  String get calendarTodayLabel => 'วันนี้';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count รายการ',
      one: '1 รายการ',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'จาก $start ถึง $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, ผูกกับชุดแล้ว';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return 'จะลบ \"$title\"';
  }

  @override
  String get calendarThisAppLabel => 'แอปนี้';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'การซิงค์กับ $provider ยังไม่พร้อม คุณสามารถเพิ่มรายการได้ที่นี่ได้';
  }

  @override
  String get calendarWeekdaySunShort => 'อา';

  @override
  String get calendarWeekdayMonShort => 'จ';

  @override
  String get calendarWeekdayTueShort => 'อ';

  @override
  String get calendarWeekdayWedShort => 'พ';

  @override
  String get calendarWeekdayThuShort => 'พฤ';

  @override
  String get calendarWeekdayFriShort => 'ศ';

  @override
  String get calendarWeekdaySatShort => 'ส';

  @override
  String get calendarWeekdayMonday => 'จันทร์';

  @override
  String get calendarWeekdayTuesday => 'อังคาร';

  @override
  String get calendarWeekdayWednesday => 'พุธ';

  @override
  String get calendarWeekdayThursday => 'พฤหัสบดี';

  @override
  String get calendarWeekdayFriday => 'ศุกร์';

  @override
  String get calendarWeekdaySaturday => 'เสาร์';

  @override
  String get calendarWeekdaySunday => 'อาทิตย์';

  @override
  String get outfitSavedToFavouritesBody => 'บันทึกในรายการโปรดแล้ว';

  @override
  String get outfitRemovedFromFavouritesBody => 'ลบจากรายการโปรดแล้ว';

  @override
  String get outfitNotSavedTitle => 'ไม่ได้บันทึก';

  @override
  String get outfitLoggedAsWornBody => 'บันทึกว่าใส่ไปเมื่อวันนี้';

  @override
  String get outfitNicePickTitle => 'เลือกดีเลย';

  @override
  String get outfitRemovedBody => 'ลบชุดแล้ว';

  @override
  String get outfitDeletedTitle => 'ลบแล้ว';

  @override
  String get outfitNotDeletedTitle => 'ไม่ได้ลบ';

  @override
  String get outfitDuplicatedBody => 'มีสำเนาอยู่ในชุดของคุณแล้ว';

  @override
  String get outfitDuplicatedTitle => 'คัดลอกแล้ว';

  @override
  String get outfitNotDuplicatedTitle => 'ไม่ได้คัดลอก';

  @override
  String get outfitNotSharedTitle => 'ไม่มีการแชร์';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" พร้อมแล้ว';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'ยังไม่ได้สร้างคอลเลกชัน';

  @override
  String get outfitCollectionUpdatedBody => 'อัปเดตคอลเลกชันแล้ว';

  @override
  String get outfitCollectionNotUpdatedTitle => 'ไม่ได้อัปเดตคอลเลกชัน';

  @override
  String get outfitCollectionDeletedBody => 'ลบคอลเลกชันแล้ว';

  @override
  String get outfitCollectionNotDeletedTitle => 'ไม่ได้ลบคอลเลกชัน';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เพิ่มชุด $count รายการแล้ว',
      one: 'เพิ่มชุด 1 รายการแล้ว',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'ไม่ได้เพิ่มชุด';

  @override
  String get outfitPreviewNotCreatedTitle => 'ยังไม่ได้สร้างตัวอย่าง';

  @override
  String get outfitGiveNameBody => 'ตั้งชื่อให้ชุดนี้';

  @override
  String get outfitNameMissingTitle => 'ชื่อ';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'เลือกอย่างน้อยหนึ่งรายการ';

  @override
  String outfitCreatedBody(String name) {
    return '$name อยู่ในชุดของคุณแล้ว';
  }

  @override
  String get outfitSavedTitle => 'บันทึกแล้ว';

  @override
  String get wardrobeAddedToFavouritesBody => 'เพิ่มลงในรายการโปรดแล้ว';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'ลบออกจากรายการโปรดแล้ว';

  @override
  String get wardrobeNotSavedTitle => 'ไม่มีการบันทึก';

  @override
  String get wardrobeLoggedAsWornBody => 'บันทึกว่าสวมใส่ในวันนี้แล้ว';

  @override
  String get wardrobeRemovedFromClosetBody => 'ลบออกจากตู้เสื้อผ้าของคุณแล้ว';

  @override
  String get wardrobeDeletedTitle => 'ลบแล้ว';

  @override
  String get wardrobeNotDeletedTitle => 'ไม่ได้ลบ';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ลบชิ้นส่วน $count รายการออกจากตู้เสื้อผ้าของคุณแล้ว',
      one: 'ลบชิ้นส่วน 1 รายการออกจากตู้เสื้อผ้าของคุณแล้ว',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'วิเคราะห์ตู้เสื้อผ้าด้วย AI';

  @override
  String get itemAddScanJobLabel => 'สแกน';

  @override
  String get itemAddFoundEarlierBody => 'พบจากการสแกนก่อนหน้า';

  @override
  String get itemAddLookingAtPhoto => 'กำลังดูรูปภาพของคุณ';

  @override
  String get itemAddExtractionFailedBody => 'การสกัดข้อมูลล้มเหลว';

  @override
  String get itemAddJobFailedBody => 'งานล้มเหลว';

  @override
  String get itemAddConnectionLostBody => 'การเชื่อมต่อหลุด ลองใหม่';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'การเชื่อมต่อหลุดระหว่างประมวลผล';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'ชิ้นที่ $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'ชิ้น';

  @override
  String get itemAddNotCancelledTitle => 'ยกเลิกไม่สำเร็จ';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'มี $count ชิ้นในตู้เสื้อผ้าของคุณแล้ว',
      one: 'มี 1 ชิ้นในตู้เสื้อผ้าของคุณแล้ว',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'บันทึกแล้ว $saved จาก $total ชิ้น แตะบันทึกเพื่อลองอีกครั้ง';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'มีบางชิ้นที่บันทึกไม่สำเร็จ';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'เลือกอย่างน้อย 1 ภาพ';

  @override
  String get batchPhotoUnreadableBody => 'ไม่สามารถอ่านภาพนี้';

  @override
  String get batchNoPhotosReadableBody => 'อ่านภาพเหล่านี้ไม่ได้ ลองใช้ภาพอื่น';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ภาพ',
      one: '1 ภาพ',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'การเชื่อมต่อหลุดระหว่างทำงาน ลองใหม่';

  @override
  String get batchNotCancelledTitle => 'ยกเลิกไม่สำเร็จ';

  @override
  String get batchPostLinkUnsupportedBody =>
      'ไม่รองรับลิงก์โพสต์ กรุณากรอกลิงก์โปรไฟล์';

  @override
  String get batchLinkSpacesBody => 'ลิงก์ต้องไม่มีช่องว่าง';

  @override
  String get batchEnterProfileLinkBody =>
      'กรอกลิงก์โปรไฟล์ Instagram หรือ Facebook';

  @override
  String get batchEnterProfileLinkShortBody => 'กรอกลิงก์โปรไฟล์';

  @override
  String get batchSignInPageNotOpenBody => 'หน้าเข้าสู่ระบบไม่เปิด ลองใหม่';

  @override
  String get batchSignInBrowserBody =>
      'เข้าสู่ระบบในเบราว์เซอร์แล้วกลับมายัง FitCheck';

  @override
  String get batchConnectAccountTitle => 'เชื่อมต่อบัญชีของคุณ';

  @override
  String get batchEnterAuthenticatorCodeBody => 'กรอกรหัสจากแอปยืนยันตัวตน';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram ต้องการตรวจสอบความปลอดภัย กรุณาเข้าสู่ระบบในเบราว์เซอร์ก่อน';

  @override
  String get batchEnterCredentialsAgainBody =>
      'กรอกชื่อผู้ใช้และรหัสผ่านอีกครั้ง';

  @override
  String get batchSignInFailedBody =>
      'เข้าสู่ระบบล้มเหลว ตรวจสอบชื่อผู้ใช้และรหัสผ่าน';

  @override
  String get batchSignInToKeepImportingBody =>
      'เข้าสู่ระบบเพื่อใช้การนำเข้าต่อ';

  @override
  String get batchAccountNotConnectedBody => 'ไม่ได้เชื่อมต่อบัญชี';

  @override
  String get batchAccountConnectedTitle => 'เชื่อมต่อบัญชีสำเร็จ';

  @override
  String get batchNotConnectedTitle => 'ยังไม่ได้เชื่อมต่อ';

  @override
  String get batchImportConnectionLostBody =>
      'การเชื่อมต่อระหว่างการนำเข้าหายไป กรุณากดโหลดใหม่เพื่อตรวจสอบ';

  @override
  String batchPickUpToBody(int max) {
    return 'เลือกภาพได้ถึง $max รูป เราช่วยค้นหาชิ้นส่วนให้';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return 'ภาพที่ $count จาก $total';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'กำลังเตรียมรูป $done จาก $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ค้นหาชิ้นส่วนใน $count รูป',
      one: 'ค้นหาชิ้นส่วนใน 1 รูป',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'บัญชี $platform ของคุณใช้การเข้าสู่ระบบสองขั้นตอน กรุณากรอกลำดับเลข 6 หลักจากแอปยืนยันตัวตนของคุณ';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'โปรไฟล์ $platform นี้เป็นส่วนตัวหรือต้องเข้าสู่ระบบจึงจะแสดงรูปภาพได้';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'เชื่อมต่อด้วย $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'พบ $count รูปจนถึงตอนนี้',
      one: 'พบ 1 รูปจนถึงตอนนี้',
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
    return 'ประมวลผล $processed จาก $total · เพิ่ม $added · รออยู่ $waiting · ข้าม $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'กำลังสแกนรูป $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'รูป $number ถัดไป';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'รูป $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'พบ $count ชิ้น',
      one: 'พบ 1 ชิ้น',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เพิ่ม $count รูปลงในตู้เสื้อผ้าของคุณแล้ว',
      one: 'เพิ่ม 1 รูปลงในตู้เสื้อผ้าของคุณแล้ว',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'มีรูปสตูดิโออีก $count รูป กำลังจะเสร็จ คุณบันทึกสิ่งที่พร้อมได้แล้ว หรือออกก่อน เดี๋ยวเราจะแจ้งให้ทราบ',
      one:
          'มีรูปสตูดิโออีก 1 รูป กำลังจะเสร็จ คุณบันทึกสิ่งที่พร้อมได้แล้ว หรือออกก่อน เดี๋ยวเราจะแจ้งให้ทราบ',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'ยังไม่ได้บันทึก: $names';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces ชิ้น',
      one: '1 ชิ้น',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos รูป',
      one: '1 รูป',
    );
    return '$_temp0 จาก $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return 'เลือก $chosen รายการ แตะชิ้นส่วนเพื่อข้าม';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'กำลังบันทึก $count ชิ้น',
      one: 'กำลังบันทึก 1 ชิ้น',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'บันทึก $count ชิ้น',
      one: 'บันทึก 1 ชิ้น',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'บันทึกโปรไฟล์ร่างกายของคุณแล้ว';

  @override
  String get bodyProfileSavedTitle => 'บันทึกแล้ว';

  @override
  String get bodyProfileNotSavedTitle => 'ไม่ได้บันทึก';

  @override
  String get bodyProfileSetDefaultBody => 'ตั้งให้เป็นโปรไฟล์เริ่มต้นของคุณ';

  @override
  String get bodyProfileDeletedBody => 'ลบโปรไฟล์ร่างกายแล้ว';

  @override
  String get bodyProfileDeletedTitle => 'ลบแล้ว';

  @override
  String get bodyProfileNotDeletedTitle => 'ไม่ได้ลบ';

  @override
  String get feedbackNotSentTitle => 'ไม่ได้รับการส่ง';

  @override
  String get feedbackSentBody =>
      'ขอบคุณ เราอ่านทุกข้อความและจะตอบกลับหากต้องการข้อมูลเพิ่มเติม';

  @override
  String get feedbackSentTitle => 'ส่งข้อเสนอแนะแล้ว';

  @override
  String get recommendUnnamedPiece => 'เสื้อผ้าที่ชื่อว่างเปล่า';

  @override
  String get recommendEnterCityBody =>
      'ระบุเมืองของคุณเพื่อรับลุคที่เหมาะกับสภาพอากาศ';

  @override
  String get recommendWhichCityTitle => 'เมืองของคุณคือ?';

  @override
  String get aiConsentSheetTitle => 'การแชร์ภาพกับบริการ AI';

  @override
  String get aiConsentSheetBody =>
      'ในการสร้างภาพทดลองสวมใส่และภาพถ่าย FitCheck AI จะส่งรูปถ่ายที่คุณให้มา (รวมถึงภาพใบหน้าและร่างกาย) ให้ผู้ให้บริการ AI จากบุคคลที่สามที่เชื่อถือได้ (เช่น OpenAI หรือ Google Gemini) เพื่อประมวลผล พวกเขาสร้างภาพของคุณและไม่ใช้ในการฝึกโมเดลตามข้อกำหนดของเรา รูปถ่ายจะถูกส่งอย่างปลอดภัยและไม่มีการแชร์เพื่อโฆษณา';

  @override
  String get aiConsentSheetPermission =>
      'การดำเนินการต่อไปหมายถึงคุณอนุญาตให้แชร์รูปถ่ายของคุณกับผู้ให้บริการ AI เหล่านี้เพื่อสร้างภาพ';

  @override
  String get skeletonsLoadMoreFailed => 'โหลดเพิ่มเติมไม่ได้';

  @override
  String get jobsPiecesReadyTitle => 'เสื้อผ้าของคุณพร้อมแล้ว';

  @override
  String get jobsScanStoppedTitle => 'การสแกนหยุด';

  @override
  String get jobsNothingSavedBody => 'ไม่ได้บันทึกข้อมูล ลองอีกครั้ง';

  @override
  String get jobsPhotoUploadFailedBody => 'อัปโหลดรูปถ่ายไม่สำเร็จ';

  @override
  String get authGoogleSignInStartFailed =>
      'เริ่มเข้าสู่ระบบ Google ไม่สำเร็จ กรุณาลองใหม่';

  @override
  String get referralAppliedTitle => 'คูปองแนะนำถูกใช้แล้ว!';

  @override
  String get billingStoreUnavailableBody =>
      'การซื้อจากสโตร์ไม่พร้อมใช้งานบนอุปกรณ์นี้';

  @override
  String get billingPurchaseProcessingBody =>
      'กำลังประมวลผลการซื้อนี้ เปิดแอปใหม่ในอีก 1 นาทีเพื่อดูแผนของคุณ';

  @override
  String get profileAvatarUploadNoUrl =>
      'การอัปโหลดอวตาร์ไม่คืนค่า URL ของรูปถ่าย';

  @override
  String get rewardsDayStreakLabel => 'ลำดับติดกันวัน';

  @override
  String rewardsBestStreak(int days) {
    return 'ดีที่สุดใน $days วัน';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'ต้องเข้าถึง $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'การเข้าถึง $permission ถูกปฏิเสธอยู่ตอนนี้ เปิดการตั้งค่าเพื่ออนุญาต จากนั้นกลับมาลองอีกครั้ง';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'ขั้นตอนที่ $step จาก 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'ขั้นตอนที่ $step จาก $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'ลบรูปถ่ายที่ $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'ลบรูปถ่ายที่ $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points คะแนน';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'ส่งอีเมลไปที่ $email เรายืนยันรายงานภายใน 24 ชั่วโมง';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'ลบ $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'ต้องการลบ \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'เพิ่มใน \"​$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return 'ลบ \"$name\" แล้ว ส่วนประกอบยังอยู่ในตู้เสื้อผ้าของคุณ';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'แสดงทั้งหมด $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'คงเหลือวันนี้ $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'รูปภาพที่ $index ล้มเหลว';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return 'เลือก $selected จาก $max รูปภาพ';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'สรีระ $shape · ผิว $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'ลบ $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'ตัวเลือกสำหรับ $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'ใส่บ่อยที่สุด: $name, $count ครั้ง';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: ยังไม่ได้ตั้ง';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'ตรงกัน $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'เลือก $picked จาก $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'ลบ $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'ความสำคัญ $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'แผนนี้เรียกเก็บเงินผ่าน $store เปลี่ยนแปลงหรือยกเลิกในตั้งค่าบัญชี $store ของคุณ';
  }

  @override
  String billingManageInStore(String store) {
    return 'จัดการใน $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: ใช้แล้ว $current จาก $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'เหลือเวลาประมาณ $seconds วินาที';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return 'สตูดิโอพร้อมแล้ว $done จาก $total';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return 'สตูดิโอพร้อมแล้ว $ready จาก $total แตะที่ชิ้นเพื่อข้าม';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height ซม. · $weight กก.';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'ไม่มี';
}
