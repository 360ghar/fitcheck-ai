// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabPhotoshoot => 'Chụp ảnh';

  @override
  String get tabCloset => 'Tủ đồ';

  @override
  String get tabOutfits => 'Trang phục';

  @override
  String get tabMore => 'Thêm';

  @override
  String get actionAddItem => 'Thêm món đồ';

  @override
  String get actionCreateOutfit => 'Tạo trang phục';

  @override
  String get actionCancel => 'Hủy';

  @override
  String get actionDelete => 'Xóa';

  @override
  String get actionSave => 'Lưu';

  @override
  String get actionRetry => 'Thử lại';

  @override
  String get actionDone => 'Xong';

  @override
  String get actionNext => 'Tiếp theo';

  @override
  String get actionBack => 'Quay lại';

  @override
  String get actionClose => 'Đóng';

  @override
  String get actionSearch => 'Tìm kiếm';

  @override
  String get actionContinue => 'Tiếp tục';

  @override
  String get stateLoading => 'Đang tải';

  @override
  String get stateErrorTitle => 'Đã xảy ra lỗi';

  @override
  String get stateErrorBody =>
      'Vui lòng thử lại. Nếu vẫn lỗi, hãy liên hệ hỗ trợ.';

  @override
  String get stateOfflineTitle => 'Bạn đang ngoại tuyến';

  @override
  String get stateOfflineBody =>
      'Kết nối mạng để đồng bộ tủ đồ và tạo trang phục.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsAccountSection => 'Tài khoản';

  @override
  String get settingsPreferencesSection => 'Tùy chọn';

  @override
  String get settingsPlanBilling => 'Gói và thanh toán';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsNotifications => 'Thông báo';

  @override
  String get settingsUnits => 'Đơn vị đo';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsPrivacySection => 'Quyền riêng tư và dữ liệu';

  @override
  String get settingsAboutSection => 'Giới thiệu';

  @override
  String get settingsSignOut => 'Đăng xuất';

  @override
  String get settingsDeleteAccount => 'Xóa tài khoản';

  @override
  String get settingsDeleteAccountTitle => 'Xóa tài khoản của bạn?';

  @override
  String get settingsDeleteAccountBody =>
      'Thao tác này sẽ xóa tủ đồ, trang phục, ảnh và hồ sơ của bạn. Không thể hoàn tác.';

  @override
  String get settingsUnitsImperial => 'Hệ đo lường Anh (in, lb)';

  @override
  String get settingsUnitsMetric => 'Hệ mét (cm, kg)';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Sử dụng ngôn ngữ thiết bị';

  @override
  String get languageSystemBody =>
      'FitCheck AI sử dụng ngôn ngữ trên điện thoại của bạn.';

  @override
  String get languageSearchHint => 'Tìm kiếm ngôn ngữ';

  @override
  String get languageCurrent => 'Hiện tại';

  @override
  String get languageReviewNote =>
      'Bản dịch này mới. Hãy cho chúng tôi biết nếu có gì chưa chuẩn.';

  @override
  String get languageChanged => 'Đã cập nhật ngôn ngữ';

  @override
  String get paywallTitle => 'Chọn gói của bạn';

  @override
  String get paywallTrialBadge => '1 tháng miễn phí';

  @override
  String get paywallTrialTitle => 'Tháng đầu tiên dùng Pro miễn phí';

  @override
  String get paywallTrialBody =>
      'Tải lên toàn bộ tủ đồ cùng lúc. Sau đó, bạn có thể thêm từng món đồ.';

  @override
  String get paywallFreeForeverTitle => 'Miễn phí mãi mãi';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Không cần thẻ. Mỗi tháng bạn nhận được $uploads lượt tải lên AI, $outfits trang phục và $images ảnh chụp mỗi ngày.';
  }

  @override
  String get paywallCtaTrial => 'Bắt đầu tháng miễn phí';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Nâng cấp lên $plan';
  }

  @override
  String get paywallRestore => 'Khôi phục giao dịch';

  @override
  String get paywallManage => 'Quản lý đăng ký';

  @override
  String get paywallTerms => 'Điều khoản sử dụng';

  @override
  String get paywallPrivacy => 'Chính sách bảo mật';

  @override
  String get paywallPerMonth => 'mỗi tháng';

  @override
  String get paywallPerYear => 'mỗi năm';

  @override
  String get paywallBestValue => 'Giá tốt nhất';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Dùng thử miễn phí chỉ dành cho người đăng ký mới. Sau khi dùng thử, gói Pro sẽ tự động gia hạn với giá $price trừ khi hủy ít nhất 24 giờ trước khi kết thúc.';
  }

  @override
  String get introTitle => 'Tủ đồ của bạn, cuối cùng đã được sắp xếp';

  @override
  String get introBody =>
      'Chụp ảnh quần áo của bạn một lần. Nhận gợi ý phối đồ, xem trước trang phục và ảnh studio từ những gì bạn đã sở hữu.';

  @override
  String get introStart => 'Bắt đầu';

  @override
  String get introHaveAccount => 'Tôi đã có tài khoản';

  @override
  String get introSkip => 'Bỏ qua';

  @override
  String get authSignIn => 'Đăng nhập';

  @override
  String get authSignUp => 'Tạo tài khoản';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authContinueApple => 'Tiếp tục với Apple';

  @override
  String get authContinueGoogle => 'Tiếp tục với Google';

  @override
  String get authOrDivider => 'hoặc';

  @override
  String get wardrobeTitle => 'Tủ đồ';

  @override
  String get wardrobeEmptyTitle => 'Tủ đồ của bạn đang trống';

  @override
  String get wardrobeEmptyBody =>
      'Thêm món đồ đầu tiên hoặc tải lên ảnh chụp toàn bộ tủ đồ của bạn cùng lúc.';

  @override
  String get wardrobeAddFirst => 'Thêm món đồ đầu tiên';

  @override
  String get wardrobeSearchHint => 'Tìm kiếm trong tủ đồ';

  @override
  String get categoryTops => 'Áo';

  @override
  String get categoryBottoms => 'Quần/Váy';

  @override
  String get categoryShoes => 'Giày dép';

  @override
  String get categoryAccessories => 'Phụ kiện';

  @override
  String get categoryOuterwear => 'Áo khoác';

  @override
  String get categorySwimwear => 'Đồ bơi';

  @override
  String get categoryActivewear => 'Đồ thể thao';

  @override
  String get categoryOther => 'Khác';

  @override
  String get conditionClean => 'Sạch';

  @override
  String get conditionDirty => 'Bẩn';

  @override
  String get conditionLaundry => 'Đang giặt';

  @override
  String get conditionRepair => 'Cần sửa';

  @override
  String get conditionDonate => 'Cần quyên góp';

  @override
  String get seasonSpring => 'Mùa xuân';

  @override
  String get seasonSummer => 'Mùa hè';

  @override
  String get seasonFall => 'Mùa thu';

  @override
  String get seasonWinter => 'Mùa đông';

  @override
  String get seasonAll => 'Mọi mùa';

  @override
  String get styleCasual => 'Thường ngày';

  @override
  String get styleFormal => 'Trang trọng';

  @override
  String get styleBusiness => 'Công sở';

  @override
  String get styleSporty => 'Thể thao';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Cổ điển';

  @override
  String get styleMinimalist => 'Tối giản';

  @override
  String get styleRomantic => 'Lãng mạn';

  @override
  String get styleEdgy => 'Cá tính';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Nghệ thuật';

  @override
  String get styleClassic => 'Cổ điển';

  @override
  String get styleElegant => 'Thanh lịch';

  @override
  String get styleOther => 'Khác';

  @override
  String get occasionWork => 'Đi làm';

  @override
  String get occasionDateNight => 'Hẹn hò';

  @override
  String get occasionTravel => 'Du lịch';

  @override
  String get occasionWedding => 'Đám cưới';

  @override
  String get occasionGym => 'Tập gym';

  @override
  String get occasionWeekend => 'Cuối tuần';

  @override
  String get occasionParty => 'Tiệc tùng';

  @override
  String get occasionInterview => 'Phỏng vấn';

  @override
  String get colorBlack => 'Đen';

  @override
  String get colorWhite => 'Trắng';

  @override
  String get colorGrey => 'Xám';

  @override
  String get colorNavy => 'Xanh navy';

  @override
  String get colorBrown => 'Nâu';

  @override
  String get colorRed => 'Đỏ';

  @override
  String get colorBlue => 'Xanh dương';

  @override
  String get colorGreen => 'Xanh lá';

  @override
  String get colorPink => 'Hồng';

  @override
  String get colorPurple => 'Tím';

  @override
  String get colorYellow => 'Vàng';

  @override
  String get colorOrange => 'Cam';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Hôm nay';

  @override
  String get dateYesterday => 'Hôm qua';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ngày trước',
      one: '1 ngày trước',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuần trước',
      one: '1 tuần trước',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tháng trước',
      one: '1 tháng trước',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count năm trước',
      one: '1 năm trước',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Bạn thích FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Đánh giá nhanh giúp người khác tìm thấy phong cách của họ.';

  @override
  String get ratingPromptYes => 'Đánh giá ứng dụng';

  @override
  String get ratingPromptNo => 'Để sau';

  @override
  String get closetNoMatchesTitle => 'Không có kết quả';

  @override
  String get closetNoMatchesBody => 'Hãy thử bỏ bớt bộ lọc hoặc tìm kiếm khác.';

  @override
  String get closetClearFilters => 'Xóa bộ lọc';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món',
      one: '1 món',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Đang tải tủ đồ';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã chọn $count',
      one: 'Đã chọn 1',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Xóa mục đã chọn';

  @override
  String get closetCancelSelection => 'Hủy chọn';

  @override
  String get closetCloseSearch => 'Đóng tìm kiếm';

  @override
  String get closetShowGrid => 'Xem dạng lưới';

  @override
  String get closetShowList => 'Xem dạng danh sách';

  @override
  String get closetShowRows => 'Xem dạng hàng';

  @override
  String get closetStatsTitle => 'Thống kê tủ đồ';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Xóa $count món?',
      one: 'Xóa 1 món?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Các bộ đồ sử dụng món này sẽ bị ảnh hưởng.';

  @override
  String get closetSortBy => 'Sắp xếp theo';

  @override
  String get closetFavourites => 'Yêu thích';

  @override
  String get closetFavourite => 'Thêm yêu thích';

  @override
  String get closetUnfavourite => 'Bỏ yêu thích';

  @override
  String get closetWoreToday => 'Đã mặc hôm nay';

  @override
  String closetWornTimes(int count) {
    return 'Đã mặc $count×';
  }

  @override
  String get closetCategoryLabel => 'Danh mục';

  @override
  String get closetUseCaseLabel => 'Dịp sử dụng';

  @override
  String get closetAnyUseCase => 'Bất kỳ';

  @override
  String get closetOtherUseCase => 'Dịp khác';

  @override
  String get closetOtherUseCaseHint => 'Ví dụ: đi ăn trưa';

  @override
  String get closetUseUseCase => 'Sử dụng';

  @override
  String get closetClearAll => 'Xóa tất cả';

  @override
  String get sortNewest => 'Mới nhất trước';

  @override
  String get sortOldest => 'Cũ nhất trước';

  @override
  String get sortName => 'Tên (A–Z)';

  @override
  String get sortMostWorn => 'Mặc nhiều nhất';

  @override
  String get useCaseInformal => 'Thường ngày';

  @override
  String get useCaseDate => 'Hẹn hò';

  @override
  String get useCaseDinner => 'Ăn tối';

  @override
  String get useCaseLunch => 'Ăn trưa';

  @override
  String get actionSelect => 'Chọn';

  @override
  String get actionEdit => 'Sửa';

  @override
  String get actionFilter => 'Bộ lọc';

  @override
  String get actionSort => 'Sắp xếp';

  @override
  String get actionAll => 'Tất cả';

  @override
  String get dashboardStartClosetTitle => 'Bắt đầu tủ đồ';

  @override
  String get dashboardStartClosetBody =>
      'Chụp vài món đồ. Chúng tôi sẽ gắn thẻ giúp bạn.';

  @override
  String get dashboardPieces => 'món đồ';

  @override
  String get dashboardOutfits => 'bộ đồ';

  @override
  String get dashboardDayStreak => 'ngày liên tiếp';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count tháng này';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Kỷ lục $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món yêu thích',
      one: '1 món yêu thích',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bộ đồ đã lưu',
      one: '1 bộ đồ đã lưu',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Mặc nhiều nhất: $name, $count lần';
  }

  @override
  String get setupSkip => 'Bỏ qua thiết lập';

  @override
  String get setupWhoTitle => 'Bạn muốn phối đồ cho ai?';

  @override
  String get setupWhoBody =>
      'Chọn người mẫu để thử đồ và chụp ảnh. Bạn có thể thay đổi trong hồ sơ.';

  @override
  String get setupStyleTitle => 'Phong cách bạn hay mặc?';

  @override
  String get setupStyleBody =>
      'Chọn bất kỳ. Gợi ý phối đồ sẽ dựa trên lựa chọn này.';

  @override
  String get setupClosetTitle => 'Thêm món đồ đầu tiên.';

  @override
  String get setupClosetBody =>
      'Chụp ảnh quần áo của bạn. Mỗi món đồ sẽ được tách nền và lưu trữ tự động.';

  @override
  String get setupAddClothes => 'Thêm quần áo';

  @override
  String get setupStylesLabel => 'Phong cách';

  @override
  String get setupOccasionsLabel => 'Dịp';

  @override
  String get setupSkipStep => 'Bỏ qua';

  @override
  String get setupLater => 'Để sau';

  @override
  String get setupSaveError => 'Không thể lưu';

  @override
  String get genderWomen => 'Nữ';

  @override
  String get genderMen => 'Nam';

  @override
  String get genderNonBinary => 'Phi nhị nguyên';

  @override
  String get genderPreferNotToSay => 'Không muốn tiết lộ';

  @override
  String get outfitEmptyTitle => 'Chưa có trang phục';

  @override
  String get outfitEmptyBody => 'Phối đồ từ tủ quần áo của bạn và lưu lại.';

  @override
  String get outfitNoMatchesTitle => 'Không tìm thấy trang phục';

  @override
  String get outfitSearchHint => 'Tìm kiếm trang phục';

  @override
  String get outfitLoading => 'Đang tải trang phục';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trang phục',
      one: '1 trang phục',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Phong cách và mùa';

  @override
  String get outfitCollections => 'Bộ sưu tập';

  @override
  String get outfitDuplicate => 'Nhân bản';

  @override
  String get outfitDeleteTitle => 'Xóa trang phục này?';

  @override
  String get outfitDeleteBody => 'Các món đồ vẫn nằm trong tủ của bạn.';

  @override
  String get outfitDrafts => 'Bản nháp';

  @override
  String get outfitDraft => 'Bản nháp';

  @override
  String get filterStyle => 'Phong cách';

  @override
  String get filterSeason => 'Mùa';

  @override
  String get itemDetailDeleteTitle => 'Xóa món đồ này?';

  @override
  String get itemDetailDeleteBody =>
      'Các trang phục sử dụng món đồ này sẽ bị mất nó.';

  @override
  String get itemAddFavourite => 'Thêm vào yêu thích';

  @override
  String itemSize(String size) {
    return 'Kích cỡ $size';
  }

  @override
  String get itemColours => 'Màu sắc';

  @override
  String get itemMaterial => 'Chất liệu';

  @override
  String get itemPattern => 'Họa tiết';

  @override
  String get itemUseCases => 'Dịp sử dụng';

  @override
  String get itemKeptIn => 'Lưu tại';

  @override
  String get itemPrice => 'Giá';

  @override
  String get itemBought => 'Đã mua';

  @override
  String get itemTags => 'Thẻ';

  @override
  String get itemAdded => 'Đã thêm';

  @override
  String get itemTimesWornLabel => 'lần mặc';

  @override
  String get itemLastWornLabel => 'mặc lần cuối';

  @override
  String get itemNeverWorn => 'Chưa mặc';

  @override
  String get authEntryBody =>
      'Mọi món đồ bạn có, được phối bởi AI. Lên kế hoạch trang phục, thử đồ và chụp ảnh.';

  @override
  String get authCreateCloset => 'Tạo tủ đồ';

  @override
  String get authWelcomeBack => 'Chào mừng trở lại';

  @override
  String get authSignInBody => 'Đăng nhập để mở tủ đồ của bạn.';

  @override
  String get authCreateAccount => 'Tạo tài khoản';

  @override
  String get authCreateClosetBody =>
      'Chỉ mất một phút. Những món đồ đầu tiên là miễn phí.';

  @override
  String get authName => 'Tên';

  @override
  String get authConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get authReferralCode => 'Mã giới thiệu (tùy chọn)';

  @override
  String get authResetTitle => 'Đặt lại mật khẩu';

  @override
  String get authResetBody =>
      'Chúng tôi sẽ gửi email chứa liên kết để bạn đặt mật khẩu mới.';

  @override
  String get authSendResetLink => 'Gửi liên kết đặt lại';

  @override
  String get authBackToSignIn => 'Quay lại đăng nhập';

  @override
  String get authEnterEmail => 'Nhập email của bạn';

  @override
  String get authEnterValidEmail => 'Nhập email hợp lệ';

  @override
  String get authEnterPassword => 'Nhập mật khẩu của bạn';

  @override
  String get authPasswordTooShort => 'Ít nhất 6 ký tự';

  @override
  String get authShowPassword => 'Hiện mật khẩu';

  @override
  String get authHidePassword => 'Ẩn mật khẩu';

  @override
  String get authNewHere => 'Người dùng mới?';

  @override
  String authConfirmEmail(String email) {
    return 'Xác nhận $email trước khi đăng nhập. Kiểm tra hộp thư đến của bạn.';
  }

  @override
  String get authResendEmail => 'Gửi lại';

  @override
  String get authResendingEmail => 'Đang gửi...';

  @override
  String get authPasswordsDoNotMatch => 'Mật khẩu không khớp';

  @override
  String get authEnterName => 'Nhập tên của bạn';

  @override
  String get authChoosePassword => 'Chọn mật khẩu';

  @override
  String get authHaveAccount => 'Đã có tài khoản?';

  @override
  String get authCodeAccepted => 'Mã đã được chấp nhận';

  @override
  String get authCodeNotFound => 'Không tìm thấy mã';

  @override
  String authReferralFrom(String name) {
    return 'Từ $name. Cả hai bạn đều nhận được một tháng miễn phí.';
  }

  @override
  String get authReferralInvalid => 'Chúng tôi không tìm thấy mã này.';

  @override
  String authResetSent(String email) {
    return 'Đã gửi đến $email. Mở liên kết trên điện thoại này.';
  }

  @override
  String get introSlide1Title => 'Chụp ảnh tủ đồ của bạn.';

  @override
  String get introSlide1Body =>
      'Chụp ảnh đống quần áo. Mọi món đồ đều được cắt và lưu trữ cho bạn.';

  @override
  String get introSlide2Title => 'Mặc đẹp nhanh hơn.';

  @override
  String get introSlide2Body =>
      'Phối đồ từ những gì bạn có, phù hợp với kế hoạch và thời tiết.';

  @override
  String get introSlide3Title => 'Xem trước khi mặc.';

  @override
  String get introSlide3Body =>
      'Thử trang phục trên ảnh của bạn, hoặc chụp như một chiến dịch thời trang.';

  @override
  String get settingsTheme => 'Chủ đề';

  @override
  String get settingsThemeSystem => 'Hệ thống';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsTemperature => 'Nhiệt độ';

  @override
  String get settingsEmailUpdates => 'Cập nhật qua email';

  @override
  String get settingsEmailUpdatesBody => 'Tin tức và mẹo qua email';

  @override
  String get settingsOutfitReminders => 'Nhắc nhở trang phục';

  @override
  String get settingsOutfitRemindersBody => 'Nhắc bạn ghi lại những gì đã mặc';

  @override
  String get settingsWeeklySummary => 'Tóm tắt hàng tuần';

  @override
  String get settingsWeeklySummaryBody => 'Tuần của bạn qua trang phục';

  @override
  String get settingsStyleSection => 'Phong cách';

  @override
  String get settingsPreferredStyles => 'Phong cách bạn thích';

  @override
  String get settingsPreferredColours => 'Màu sắc bạn thích';

  @override
  String get settingsNoneChosen => 'Chưa chọn';

  @override
  String get settingsPlanAiSection => 'Gói và AI';

  @override
  String get settingsPlanBillingBody => 'Gói, sử dụng và nâng cấp';

  @override
  String get settingsPlanUsageBody => 'Gói và mức sử dụng';

  @override
  String get settingsInviteFriends => 'Mời bạn bè';

  @override
  String get settingsInviteFriendsBody =>
      'Tặng một tháng miễn phí cho mỗi người bạn tham gia';

  @override
  String get settingsAiProvider => 'Nhà cung cấp AI';

  @override
  String get settingsAiProviderBody =>
      'Sử dụng mô hình riêng để gắn thẻ và xử lý ảnh';

  @override
  String get settingsAppVersion => 'Phiên bản ứng dụng';

  @override
  String get settingsPrivacyTerms => 'Quyền riêng tư và điều khoản';

  @override
  String get settingsReportProblem => 'Báo cáo sự cố';

  @override
  String get settingsChangePassword => 'Đổi mật khẩu';

  @override
  String get settingsExportData => 'Xuất dữ liệu';

  @override
  String get settingsExportBody =>
      'Chúng tôi sẽ chuẩn bị tệp chứa mọi dữ liệu bạn đã lưu và mở liên kết tải xuống.';

  @override
  String get settingsExportAction => 'Xuất';

  @override
  String get settingsCurrentPassword => 'Mật khẩu hiện tại';

  @override
  String get settingsNewPassword => 'Mật khẩu mới';

  @override
  String get settingsConfirmNewPassword => 'Xác nhận mật khẩu mới';

  @override
  String get settingsEnterCurrentPassword => 'Nhập mật khẩu hiện tại';

  @override
  String get settingsEnterNewPassword => 'Nhập mật khẩu mới';

  @override
  String get settingsPasswordMin8 => 'Sử dụng ít nhất 8 ký tự';

  @override
  String get settingsPasswordNeedsUpper => 'Thêm một chữ cái viết hoa';

  @override
  String get settingsPasswordNeedsLower => 'Thêm một chữ cái viết thường';

  @override
  String get settingsPasswordNeedsDigit => 'Thêm một chữ số';

  @override
  String get settingsPasswordsNoMatch => 'Mật khẩu không khớp';

  @override
  String get settingsChangeAction => 'Thay đổi';

  @override
  String get itemAddSnapTitle => 'Chụp ảnh trang phục';

  @override
  String get itemAddSnapBody =>
      'Chúng tôi sẽ nhận diện từng món đồ trong ảnh và tách nền chuyên nghiệp.';

  @override
  String get itemAddCamera => 'Chụp ảnh';

  @override
  String get itemAddGallery => 'Chọn từ thư viện';

  @override
  String get itemAddOtherWays => 'Cách thêm khác';

  @override
  String get itemAddSeveral => 'Thêm nhiều ảnh';

  @override
  String get itemAddSeveralBody => 'Tối đa 50 ảnh cùng lúc';

  @override
  String get itemAddImportProfile => 'Nhập từ hồ sơ';

  @override
  String get itemAddImportProfileBody => 'Instagram hoặc Facebook';

  @override
  String get itemAddEnterDetails => 'Nhập chi tiết thủ công';

  @override
  String get itemAddEnterDetailsBody => 'Không cần ảnh';

  @override
  String get itemManualIntro =>
      'Chỉ cần tên. Bạn có thể thêm thông tin khác sau.';

  @override
  String get itemManualNameHint => 'Ví dụ: áo thun cotton xanh';

  @override
  String get itemManualEnterName => 'Nhập tên';

  @override
  String get itemManualNotes => 'Ghi chú';

  @override
  String get itemManualBrand => 'Thương hiệu';

  @override
  String get itemManualSize => 'Kích cỡ';

  @override
  String get itemManualEnterNumber => 'Nhập số';

  @override
  String get itemManualSavePiece => 'Lưu món đồ';

  @override
  String get itemManualSaving => 'Đang lưu';

  @override
  String get itemManualSavedTitle => 'Đã lưu';

  @override
  String itemManualSavedBody(String name) {
    return '$name đã có trong tủ đồ của bạn.';
  }

  @override
  String get itemManualNotSaved => 'Chưa lưu';

  @override
  String get itemManualAddUseCase => 'Thêm mục đích sử dụng';

  @override
  String get itemManualAddUseCaseAction => 'Thêm mục đích';

  @override
  String get itemPhotos => 'Ảnh';

  @override
  String get itemAddPhotos => 'Thêm ảnh';

  @override
  String get itemNoPhotoYet => 'Chưa có ảnh. Bạn có thể lưu mà không cần ảnh.';

  @override
  String get itemRemovePhoto => 'Xóa ảnh';

  @override
  String get itemRemovePiece => 'Xóa món đồ';

  @override
  String get filterConditionLabel => 'Tình trạng';

  @override
  String get photoshootStepPhotos => 'Ảnh';

  @override
  String get photoshootStepSetup => 'Thiết lập';

  @override
  String get photoshootStepCreating => 'Đang tạo';

  @override
  String get photoshootStepResults => 'Kết quả';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Bước $current/$total, $name';
  }

  @override
  String get photoshootOneFailed => 'Một ảnh bị lỗi. Thử lại bên dưới.';

  @override
  String photoshootManyFailed(int count) {
    return '$count ảnh bị lỗi. Thử lại từng ảnh bên dưới.';
  }

  @override
  String get photoshootFormat => 'Định dạng';

  @override
  String get photoshootHowMany => 'Số lượng';

  @override
  String get photoshootYourPrompt => 'Mô tả của bạn';

  @override
  String get photoshootPromptHint => 'Giờ vàng trên sân thượng, áo sơ mi linen';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tạo $count ảnh',
      one: 'Tạo 1 ảnh',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ảnh',
      one: 'ảnh',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Không thể kiểm tra giới hạn hôm nay.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Gói $plan: còn $remaining/$limit lượt hôm nay';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Miễn phí';

  @override
  String get photoshootGallery => 'Thư viện';

  @override
  String get photoshootUseCamera => 'Dùng máy ảnh';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Xóa ảnh $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Không có ảnh nào';

  @override
  String get photoshootNoPhotosBody =>
      'Quá trình tạo ảnh không thành công. Thử lại nhé.';

  @override
  String get photoshootNewStyle => 'Phong cách mới';

  @override
  String get photoshootNewPhotos => 'Ảnh mới';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Mở ảnh $number';
  }

  @override
  String get photoshootReportPhoto => 'Báo cáo ảnh';

  @override
  String get photoshootSaveToGallery => 'Lưu vào thư viện';

  @override
  String get actionUpgrade => 'Nâng cấp';

  @override
  String get referralLimitTitle => 'Đã hết lượt tạo ảnh hôm nay';

  @override
  String get referralLimitBody =>
      'Lượt miễn phí sẽ có lại vào ngày mai. Mời bạn bè để cả hai nhận một tháng Pro miễn phí.';

  @override
  String get referralLimitRefer => 'Mời bạn bè';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Ứng dụng hẹn hò';

  @override
  String get photoshootUsePortfolio => 'Hồ sơ năng lực';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Thẩm mỹ';

  @override
  String get photoshootUseCustom => 'Mô tả riêng';

  @override
  String get photoshootDescLinkedin => 'Ảnh chân dung chuyên nghiệp';

  @override
  String get photoshootDescDating => 'Thoải mái, ấm áp và tự nhiên';

  @override
  String get photoshootDescPortfolio =>
      'Phong cách biên tập, thời trang cao cấp';

  @override
  String get photoshootDescInstagram => 'Ảnh đời thường cho trang cá nhân';

  @override
  String get photoshootDescAesthetic => 'Khung hình nghệ thuật, tâm trạng';

  @override
  String get photoshootDescCustom => 'Mô tả phong cách bạn muốn';

  @override
  String get aspectSquare => 'Vuông';

  @override
  String get aspectPortrait => 'Chân dung';

  @override
  String get aspectLandscape => 'Phong cảnh';

  @override
  String get aspectTall => 'Dọc';

  @override
  String get aspectWide => 'Ngang';

  @override
  String get tryOnAppBar => 'Thử đồ ảo';

  @override
  String get tryOnYourPhoto => 'Ảnh của bạn';

  @override
  String get tryOnGarment => 'Trang phục';

  @override
  String get tryOnUploadingPhoto => 'Đang tải ảnh của bạn';

  @override
  String get tryOnAddPhotoPrompt => 'Thêm ảnh toàn thân của bạn';

  @override
  String get tryOnBodyPhotoHint => 'Ảnh toàn thân sẽ cho kết quả tốt nhất';

  @override
  String get tryOnAddPhoto => 'Thêm ảnh';

  @override
  String get tryOnChangePhoto => 'Thay đổi ảnh';

  @override
  String get tryOnPhotoLoadFailed => 'Không thể tải ảnh của bạn.';

  @override
  String get tryOnChooseGarment => 'Chọn ảnh trang phục';

  @override
  String get tryOnChooseOneGarment => 'Chọn một ảnh trang phục';

  @override
  String get tryOnGarmentHint => 'Ảnh chụp phẳng hoặc treo móc sẽ tốt nhất';

  @override
  String get tryOnChange => 'Thay đổi';

  @override
  String get tryOnCamera => 'Máy ảnh';

  @override
  String get tryOnRemove => 'Gỡ bỏ';

  @override
  String get tryOnLookTitle => 'Diện mạo';

  @override
  String get tryOnStyle => 'Phong cách';

  @override
  String get tryOnBackground => 'Nền';

  @override
  String get tryOnPose => 'Tư thế';

  @override
  String get tryOnDressingUp =>
      'Đang phối đồ. Quá trình này mất khoảng nửa phút.';

  @override
  String get tryOnEmptyResult => 'Kết quả thử đồ sẽ hiện ở đây';

  @override
  String get tryOnReportImage => 'Báo cáo hình ảnh';

  @override
  String get tryOnCreating => 'Đang tạo';

  @override
  String get tryOnTryAgain => 'Thử lại';

  @override
  String get tryOnCreate => 'Tạo ảnh thử đồ';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio trắng';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio xám';

  @override
  String get tryOnBackgroundUrban => 'Đường phố';

  @override
  String get tryOnBackgroundNature => 'Thiên nhiên';

  @override
  String get tryOnBackgroundMinimal => 'Tối giản';

  @override
  String get tryOnPoseFront => 'Đứng thẳng';

  @override
  String get tryOnPoseSide => 'Đứng nghiêng';

  @override
  String get tryOnPoseWalking => 'Đang đi';

  @override
  String get dashboardGreetingMorning => 'Chào buổi sáng';

  @override
  String get dashboardGreetingAfternoon => 'Chào buổi chiều';

  @override
  String get dashboardGreetingEvening => 'Chào buổi tối';

  @override
  String get dashboardWelcome => 'Chào mừng';

  @override
  String get dashboardOpenProfile => 'Mở hồ sơ';

  @override
  String get dashboardRailToday => 'Hôm nay';

  @override
  String get dashboardRailRecently => 'Gần đây';

  @override
  String get dashboardActivityEmpty =>
      'Các món đồ và trang phục mới sẽ hiện ở đây.';

  @override
  String get quickAddPiece => 'Thêm món đồ';

  @override
  String get quickAddPieceBody => 'Chụp và gắn thẻ';

  @override
  String get quickBuildOutfit => 'Phối đồ';

  @override
  String get quickBuildOutfitBody => 'Kết hợp trang phục';

  @override
  String get quickForYou => 'Dành cho bạn';

  @override
  String get quickForYouBody => 'Gợi ý hôm nay';

  @override
  String get quickPlanWeek => 'Lên lịch tuần';

  @override
  String get quickPlanWeekBody => 'Trang phục theo ngày';

  @override
  String get referralBannerUrgent => 'Sắp hết lượt? Mời bạn bè ngay.';

  @override
  String get referralBannerTitle => 'Tặng một tháng, nhận một tháng.';

  @override
  String get referralBannerBody => 'Bạn và bạn bè đều nhận được một tháng Pro.';

  @override
  String get referralBannerDismiss => 'Ẩn trong một tuần';

  @override
  String get referralBannerShare => 'Chia sẻ lời mời';

  @override
  String get referralBannerCopy => 'Sao chép liên kết';

  @override
  String get itemEditPieceTitle => 'Chỉnh sửa món đồ';

  @override
  String get itemEditDescriptionLabel => 'Mô tả';

  @override
  String get itemEditNotSaved => 'Chưa lưu';

  @override
  String get itemEditSavedTitle => 'Đã lưu';

  @override
  String get itemEditSavedBody => 'Thay đổi của bạn đã được lưu.';

  @override
  String get itemEditSavedStalePhotos => 'Đã lưu — ảnh có thể đã cũ';

  @override
  String get itemEditRemovePieceHint => 'Xóa món đồ này khỏi trang chi tiết.';

  @override
  String get itemEditNoPhotos =>
      'Chưa có ảnh. Thêm ảnh từ thư viện hoặc máy ảnh.';

  @override
  String get itemEditKeepPhoto => 'Giữ ảnh';

  @override
  String get itemEditRemoved => 'Đã xóa';

  @override
  String get itemEditAddUseCaseAction => 'Thêm';

  @override
  String get statsNoStatsTitle => 'Chưa có thống kê';

  @override
  String get statsNoStatsBody =>
      'Thêm vài món đồ để xem phân tích tủ đồ của bạn.';

  @override
  String get statsByCategory => 'Theo danh mục';

  @override
  String get statsTotalValue => 'tổng giá trị';

  @override
  String get statsMostWorn => 'Mặc nhiều nhất';

  @override
  String get statsLeastWorn => 'Chờ đến lượt';

  @override
  String get statsUnnamedPiece => 'Món đồ chưa đặt tên';

  @override
  String get jobsTitle => 'Quét';

  @override
  String get jobsEmptyTitle => 'Chưa có lượt quét';

  @override
  String get jobsEmptyBody =>
      'Chụp ảnh món đồ và để ứng dụng xử lý — tiến trình sẽ hiển thị tại đây.';

  @override
  String get jobsNotCancelled => 'Không thể hủy';

  @override
  String get jobsResume => 'Tiếp tục';

  @override
  String get jobsReview => 'Xem lại';

  @override
  String get jobsStop => 'Dừng';

  @override
  String get jobsDismiss => 'Bỏ qua';

  @override
  String get reportTitle => 'Báo cáo nội dung';

  @override
  String reportIntro(String contentType) {
    return 'Hãy cho chúng tôi biết vấn đề với $contentType này. Đội ngũ của chúng tôi sẽ xem xét mọi báo cáo.';
  }

  @override
  String get reportReasonInappropriate => 'Không phù hợp hoặc phản cảm';

  @override
  String get reportReasonNudity => 'Ảnh khỏa thân hoặc nội dung tình dục';

  @override
  String get reportReasonHarassment => 'Quấy rối hoặc lạm dụng';

  @override
  String get reportReasonImpersonation => 'Mạo danh';

  @override
  String get reportReasonOther => 'Khác';

  @override
  String get reportDetailsLabel => 'Chi tiết bổ sung (tùy chọn)';

  @override
  String get reportSubmit => 'Gửi báo cáo';

  @override
  String get reportSubmittedTitle => 'Đã gửi báo cáo';

  @override
  String get reportSubmittedBody =>
      'Cảm ơn bạn. Đội ngũ của chúng tôi sẽ xem xét nội dung này.';

  @override
  String get reportFailedTitle => 'Không thể gửi báo cáo';

  @override
  String get reportFailedBody => 'Vui lòng thử lại.';

  @override
  String get reportContentTryOnImage => 'ảnh thử đồ AI';

  @override
  String get reportContentSharedOutfit => 'trang phục đã chia sẻ';

  @override
  String get reportContentPhotoshootImage => 'ảnh chụp studio AI';

  @override
  String get sharedOutfitTitle => 'Trang phục được chia sẻ';

  @override
  String get sharedOutfitHideTooltip => 'Ẩn trang phục này';

  @override
  String get sharedOutfitReportTooltip => 'Báo cáo trang phục này';

  @override
  String get sharedOutfitHideTitle => 'Ẩn trang phục này?';

  @override
  String get sharedOutfitHideBody =>
      'Trang phục sẽ bị ẩn trên thiết bị này. Bạn cũng có thể báo cáo để đội ngũ của chúng tôi xem xét và gỡ bỏ.';

  @override
  String get sharedOutfitHideAction => 'Ẩn';

  @override
  String get sharedOutfitHiddenInfo =>
      'Trang phục này sẽ không hiển thị lại trên thiết bị này.';

  @override
  String get sharedOutfitHiddenToast => 'Đã ẩn trang phục';

  @override
  String get sharedOutfitMissingTitle => 'Trang phục này không còn tồn tại';

  @override
  String get sharedOutfitMissingBody =>
      'Có thể nó đã bị xóa hoặc liên kết không chính xác.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Bạn đã ẩn trang phục này';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Nếu nội dung không phù hợp, hãy báo cáo trong phần Quyền riêng tư và điều khoản hoặc gửi email đến $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Thích phong cách này?';

  @override
  String get sharedOutfitCtaBody =>
      'Tạo các trang phục tương tự từ tủ đồ của bạn.';

  @override
  String get sharedOutfitCtaButton => 'Tải FitCheck AI';

  @override
  String get errorTitle => 'Lỗi';

  @override
  String get errorUnknown => 'Đã xảy ra lỗi không xác định';

  @override
  String get errorNoConnection =>
      'Không có kết nối Internet. Vui lòng kiểm tra mạng của bạn.';

  @override
  String get errorTimeout => 'Yêu cầu đã hết hạn. Vui lòng thử lại.';

  @override
  String get errorServerError => 'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get errorBadGateway =>
      'Máy chủ của chúng tôi đang tạm thời không khả dụng. Vui lòng thử lại.';

  @override
  String get errorServiceUnavailable =>
      'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.';

  @override
  String get errorInternalError => 'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get errorUnauthorized => 'Vui lòng đăng nhập để tiếp tục.';

  @override
  String get errorForbidden => 'Bạn không có quyền truy cập nội dung này.';

  @override
  String get errorSessionExpired =>
      'Phiên của bạn đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get errorInvalidCredentials => 'Email hoặc mật khẩu không chính xác.';

  @override
  String get errorTokenRefreshFailed =>
      'Không thể làm mới phiên. Vui lòng đăng nhập lại.';

  @override
  String get errorRequestCancelled => 'Yêu cầu đã bị hủy.';

  @override
  String get errorInvalidFormat => 'Định dạng tệp không được hỗ trợ.';

  @override
  String get errorFileTooLarge => 'Tệp quá lớn.';

  @override
  String get errorUploadFailed => 'Tải lên thất bại. Vui lòng thử lại.';

  @override
  String get errorCacheCorrupted =>
      'Dữ liệu đã lưu bị hỏng và đã được đặt lại.';

  @override
  String get errorCacheNotFound => 'Chưa có dữ liệu được lưu.';

  @override
  String get errorUserNotFound => 'Không tìm thấy tài khoản đó.';

  @override
  String get errorItemNotFound => 'Món đồ này không còn tồn tại.';

  @override
  String get errorOutfitNotFound => 'Bộ trang phục này không còn tồn tại.';

  @override
  String get rewardsTitle => 'Phần thưởng';

  @override
  String get rewardsNoAchievementsTitle => 'Chưa có thành tựu nào';

  @override
  String get rewardsNoAchievementsBody =>
      'Thêm món đồ và lên kế hoạch phối đồ để nhận thành tựu đầu tiên.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Chưa có ai trong bảng xếp hạng';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Lên kế hoạch phối đồ để tích lũy điểm và xuất hiện tại đây.';

  @override
  String get legalViewPrivacyPolicy => 'Xem Chính sách Bảo mật';

  @override
  String get aiConsentAgree => 'Tôi Đồng ý & Tiếp tục';

  @override
  String get aiConsentNotNow => 'Để sau';

  @override
  String get imageViewerCloseTooltip => 'Đóng trình xem ảnh';

  @override
  String get updateReadyTitle => 'Cập nhật sẵn sàng';

  @override
  String get updateReadyBody =>
      'Khởi động lại FitCheck AI để áp dụng các cải tiến mới nhất.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI cần quyền truy cập camera để chụp ảnh trang phục và đồ nội y của bạn.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI cần quyền truy cập thư viện ảnh để chọn ảnh trang phục và đồ nội y của bạn.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI cần quyền lưu ảnh trang phục do AI tạo vào thư viện ảnh của bạn.';

  @override
  String get wardrobeSomePhotosSkipped => 'Bỏ qua một số ảnh';

  @override
  String get wardrobePhotosNotAdded => 'Chưa thêm ảnh';

  @override
  String get wardrobePhotoNotAdded => 'Chưa thêm ảnh';

  @override
  String get wardrobeNotStartedTitle => 'Chưa bắt đầu';

  @override
  String get wardrobeNoRoomTitle => 'Không còn chỗ';

  @override
  String get wardrobeAddPhotosSemantic => 'Thêm ảnh';

  @override
  String get batchAddTileLabel => 'Thêm';

  @override
  String get batchProfileLinkLabel => 'Liên kết hồ sơ';

  @override
  String get wardrobeImportFromProfileTitle => 'Nhập từ hồ sơ';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Thêm nhiều ảnh';

  @override
  String get wardrobeClearAction => 'Xóa';

  @override
  String get wardrobeRefreshTooltip => 'Làm mới';

  @override
  String get batchNoPhotosYetTitle => 'Chưa có ảnh';

  @override
  String get batchChoosePhotosAction => 'Chọn ảnh';

  @override
  String get batchWeFindEachPieceBody =>
      'Chúng tôi tìm từng món đồ và tạo ảnh studio cho nó.';

  @override
  String get batchPreparingPhotosSemantic => 'Đang chuẩn bị ảnh';

  @override
  String get batchPhotosProcessedSemantic => 'Đã xử lý ảnh';

  @override
  String get batchPasteProfileLinkTitle => 'Dán liên kết hồ sơ';

  @override
  String get batchPasteProfileLinkBody =>
      'Hồ sơ Instagram hoặc Facebook công khai. Chúng tôi quét ảnh, và bạn chọn thứ đặt trong tủ quần áo.';

  @override
  String get batchClearLinkTooltip => 'Xóa liên kết';

  @override
  String get batchStartingButton => 'Đang bắt đầu';

  @override
  String get batchStartImportAction => 'Bắt đầu nhập';

  @override
  String get batchReviewEveryPhotoTitle => 'Bạn xem xét mọi ảnh';

  @override
  String get batchReviewEveryPhotoBody =>
      'Không có gì được thêm trừ khi bạn phê duyệt.';

  @override
  String get batchPrivateProfilesTitle => 'Hồ sơ riêng';

  @override
  String get batchPrivateProfilesBody =>
      'Kết nối tài khoản của bạn. Instagram cũng cần tên người dùng và mật khẩu.';

  @override
  String get batchUseAnotherLinkAction => 'Dùng liên kết khác';

  @override
  String get batchSignInNeededTitle => 'Cần đăng nhập';

  @override
  String get batchEnterYourCodeTitle => 'Nhập mã của bạn';

  @override
  String get batchUseUsernamePasswordAction => 'Dùng tên và mật khẩu';

  @override
  String get batchAlreadyConnectedAction =>
      'Mình đã kết nối trên trình duyệt rồi';

  @override
  String get batchEnterCodeAction => 'Nhập mã';

  @override
  String get batchTryAnotherWayAction => 'Thử cách khác';

  @override
  String get batchLiveStatus => 'Trực tiếp';

  @override
  String get batchReconnectingStatus => 'Đang kết nối lại';

  @override
  String get batchSignInToInstagramTitle => 'Đăng nhập Instagram';

  @override
  String get batchUsernameLabel => 'Tên người dùng';

  @override
  String get batchCodeIfTwoStepLabel => 'Mã, nếu bạn dùng xác thực 2 bước';

  @override
  String get batchAuthenticatorCodeBody =>
      'Dùng mã 6 chữ số từ ứng dụng xác thực. Mã thay đổi nhanh.';

  @override
  String get batchVerifyAction => 'Xác minh';

  @override
  String get batchFindingPhotosTitle => 'Đang tìm ảnh';

  @override
  String get batchImportPausedTitle => 'Đã tạm dừng nhập';

  @override
  String get batchProcessingPhotosTitle => 'Đang xử lý ảnh';

  @override
  String get batchWaitingNextPhoto => 'Đang chờ ảnh tiếp theo';

  @override
  String get batchCancelImportAction => 'Hủy nhập';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Không tìm thấy món đồ nào trong ảnh này.';

  @override
  String get batchEditPieceColoursLabel => 'Màu sắc, phân tách bằng dấu phẩy';

  @override
  String get batchAddToClosetAction => 'Thêm vào tủ đồ';

  @override
  String get batchSkipPhotoAction => 'Bỏ qua ảnh này';

  @override
  String get batchImportCompleteTitle => 'Nhập xong';

  @override
  String get batchImportFailedTitle => 'Nhập thất bại';

  @override
  String get batchImportCancelledTitle => 'Đã hủy nhập';

  @override
  String get batchImportErrorBody => 'Có lỗi xảy ra khi nhập.';

  @override
  String get batchNothingMoreImportedBody =>
      'Không còn gì để nhập từ hồ sơ này.';

  @override
  String get batchViewClosetAction => 'Xem tủ đồ';

  @override
  String get batchStartOverAction => 'Làm lại';

  @override
  String get wardrobeAddPieceTitle => 'Thêm món đồ';

  @override
  String get wardrobeAddDetailsTitle => 'Thêm chi tiết';

  @override
  String get wardrobeScanningTitle => 'Đang quét';

  @override
  String get batchReviewPiecesTitle => 'Kiểm tra món đồ';

  @override
  String get wardrobeGalleryAction => 'Thư viện';

  @override
  String get wardrobeCameraAction => 'Máy ảnh';

  @override
  String get wardrobeNewBadge => 'Mới';

  @override
  String get wardrobeRemovePhotoTooltip => 'Xóa ảnh';

  @override
  String get batchRunInBackgroundTooltip => 'Chạy nền';

  @override
  String get batchStepOneOfTwo => 'Bước 1/2';

  @override
  String get batchStepTwoOfTwo => 'Bước 2/2';

  @override
  String get batchUploadingPhotosTitle => 'Đang tải ảnh lên';

  @override
  String get batchFindingPiecesTitle => 'Đang tìm món đồ';

  @override
  String get batchMakingStudioPhotosTitle => 'Đang tạo ảnh studio';

  @override
  String get batchStoppedLabel => 'Đã dừng';

  @override
  String get batchFindingPiecesStoppedTitle => 'Tạm dừng tìm món đồ';

  @override
  String get batchCancelledLabel => 'Đã hủy';

  @override
  String get batchAllDoneTitle => 'Hoàn tất';

  @override
  String get batchOpeningPiecesBody => 'Đang mở món đồ của bạn';

  @override
  String get batchNothingSavedBody => 'Không có gì được lưu.';

  @override
  String get batchFindingPiecesFailedBody => 'Tìm món đồ thất bại.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Tắt sớm quá trình tìm món đồ.';

  @override
  String get batchStopFindingPiecesTitle => 'Dừng tìm món đồ?';

  @override
  String get batchStopFindingPiecesBody =>
      'Quét sẽ dừng và không có gì được lưu. Món đồ đã tìm được sẽ ở lại hoạt động cho đến khi bạn xóa.';

  @override
  String get batchKeepGoingAction => 'Tiếp tục';

  @override
  String get batchTryAgainAction => 'Thử lại';

  @override
  String get batchBackToPhotosAction => 'Quay lại ảnh';

  @override
  String get batchSkipAllAction => 'Bỏ qua tất cả';

  @override
  String get batchIncludeAllAction => 'Bao gồm tất cả';

  @override
  String get batchNoPiecesFoundTitle => 'Không tìm thấy món đồ';

  @override
  String get batchNoPiecesFoundBody =>
      'Không tìm thấy quần áo trong các ảnh này.';

  @override
  String get batchChooseOtherPhotosAction => 'Chọn ảnh khác';

  @override
  String get batchUseCaseHelper => 'Thêm vào mọi món đồ bạn lưu.';

  @override
  String get batchDiscardPiecesTitle => 'Xóa các món đồ này?';

  @override
  String get batchDiscardPiecesBody => 'Không có gì từ lô này được lưu.';

  @override
  String get batchKeepAction => 'Giữ';

  @override
  String get batchDiscardAction => 'Xóa';

  @override
  String get batchRemovePieceTitle => 'Xóa món đồ này?';

  @override
  String get batchRemovePieceBody => 'Nó không được lưu vào tủ đồ của bạn.';

  @override
  String get batchRemoveAction => 'Xóa';

  @override
  String get batchChoosePiecesToSave => 'Chọn món đồ để lưu';

  @override
  String get batchDiscardAllAction => 'Xóa tất cả';

  @override
  String get batchNothingSavedRetryBody => 'Không có gì được lưu. Thử lại.';

  @override
  String get batchNotSavedTitle => 'Chưa lưu';

  @override
  String get batchSavingLabel => 'Đang lưu';

  @override
  String get batchSendToBackgroundAction => 'Chuyển sang nền';

  @override
  String get batchStillWorkingMessage =>
      'Đang xử lý. Chúng tôi sẽ báo khi món đồ sẵn sàng.';

  @override
  String get batchRunningInBackgroundTitle => 'Đang chạy nền';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Ảnh studio bị dừng sớm. Bạn vẫn có thể lưu các món đồ này.';

  @override
  String get batchTapPieceToSkip => 'Chạm vào món đồ để bỏ qua.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Ảnh studio đang xử lý. Bạn có thể rời đi — chúng tôi sẽ báo.';

  @override
  String get batchLeaveAction => 'Rời đi';

  @override
  String get batchPeopleInPhotosTitle => 'Người trong ảnh';

  @override
  String get batchIncludeAction => 'Bao gồm';

  @override
  String get batchSkipAction => 'Bỏ qua';

  @override
  String get batchYourPhotoIsUsedLabel => 'Ảnh của bạn đã được dùng';

  @override
  String get batchMakingStudioPhotoLabel => 'Đang tạo ảnh studio';

  @override
  String get batchNoStudioPhotoBody =>
      'Không có ảnh studio. Ảnh của bạn được dùng.';

  @override
  String get batchEnterDetailsYourselfAction => 'Nhập thông tin thủ công';

  @override
  String get batchChooseAnotherPhotoAction => 'Chọn ảnh khác';

  @override
  String get batchConnectionLostTitle => 'Mất kết nối';

  @override
  String get batchConnectionLostBody => 'Kiểm tra kết nối rồi thử lại.';

  @override
  String get batchDailyLimitTitle => 'Đã đạt giới hạn hằng ngày';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Nâng cấp lên Pro để quét nhiều hơn hoặc nhập thông tin thủ công.';

  @override
  String get batchDailyLimitBodyFree =>
      'Số lần quét được đặt lại vào ngày mai. Bạn có thể nhập thông tin thủ công ngay bây giờ.';

  @override
  String get batchSeePlansAction => 'Xem các gói';

  @override
  String get batchAiBusyTitle => 'AI của chúng tôi đang bận';

  @override
  String get batchAiBusyBody =>
      'Lỗi từ phía chúng tôi. Vui lòng thử lại sau vài phút.';

  @override
  String get batchNoPiecesBody =>
      'Thử ảnh rõ hơn hoặc nhập thông tin thủ công.';

  @override
  String get batchScanningUnavailableTitle => 'Không thể quét';

  @override
  String get batchScanningUnavailableBody =>
      'Vui lòng nhập thông tin thủ công cho đến khi có thể.';

  @override
  String get batchScanDidNotFinishTitle => 'Quét chưa hoàn tất';

  @override
  String get batchTryAgainBody => 'Thử lại.';

  @override
  String get billingTitle => 'Gói thuê bao';

  @override
  String get billingUpgradeHeading => 'Nâng cấp gói';

  @override
  String get billingUpgradeOnPlusBody =>
      'Tính năng giống nhau, giới hạn cao hơn.';

  @override
  String get billingUpgradeBody =>
      'Plus và Pro có cùng tính năng. Chọn giới hạn phù hợp.';

  @override
  String get billingWebUnavailableBody =>
      'Nâng cấp trực tuyến chưa khả dụng. Mã khuyến mãi hoặc giới thiệu vẫn mở khóa Plus hoặc Pro. Mời bạn bè để nhận tháng miễn phí.';

  @override
  String get billingPlansStale =>
      'Không tải được gói mới nhất. Giá có thể chưa cập nhật.';

  @override
  String get billingMonthly => 'Hằng tháng';

  @override
  String get billingYearly => 'Hằng năm';

  @override
  String get billingCurrentPlan => 'Gói hiện tại';

  @override
  String get billingActive => 'Đang hoạt động';

  @override
  String get billingThisMonth => 'Tháng này';

  @override
  String get billingItemExtractions => 'Số lần trích xuất món đồ';

  @override
  String get billingOutfitVisualizations => 'Số lần trực quan hóa bộ đồ';

  @override
  String get billingNearLimitUpgrade =>
      'Bạn sắp đạt giới hạn tháng này. Nâng cấp để có thêm.';

  @override
  String get billingNearLimitResets =>
      'Bạn sắp đạt giới hạn tháng này. Giới hạn sẽ đặt lại đầu tháng sau.';

  @override
  String get billingStoreUnavailable =>
      'Nâng cấp chưa có trên cửa hàng. Vui lòng quay lại sau.';

  @override
  String get billingManageHeading => 'Quản lý gói của bạn';

  @override
  String get billingCancelPlan => 'Hủy đăng ký';

  @override
  String get billingCancelKeepsAccess =>
      'Bạn vẫn được sử dụng cho đến hết kỳ thanh toán này.';

  @override
  String get billingCancelConfirmTitle => 'Hủy đăng ký?';

  @override
  String get billingKeepPlan => 'Giữ gói';

  @override
  String get billingCancelPlanAction => 'Hủy gói';

  @override
  String get billingBilledMonthly => 'Thanh toán hàng tháng';

  @override
  String get billingBilledYearly => 'Thanh toán hàng năm';

  @override
  String get billingVirtualTryOn => 'Thử đồ ảo';

  @override
  String get billingPrioritySupport => 'Hỗ trợ ưu tiên';

  @override
  String get billingDisclosureProRenewing =>
      'Pro là gói đăng ký tự động gia hạn';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus và Pro là các gói đăng ký tự động gia hạn';

  @override
  String get billingDisclosureAppleBilling =>
      'Số tiền được trừ vào Apple ID của bạn khi xác nhận mua hàng.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Số tiền được trừ vào tài khoản Google Play của bạn khi xác nhận mua hàng.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Gói đăng ký của bạn sẽ tự động gia hạn theo cùng kỳ và cùng giá trừ khi bạn tắt tính năng gia hạn tự động ít nhất 24 giờ trước khi kỳ hiện tại kết thúc.';

  @override
  String get billingDisclosureAppleManage =>
      'Quản lý hoặc hủy bất kỳ lúc nào trong Cài đặt › Apple ID của bạn › Đăng ký.';

  @override
  String get billingDisclosureGoogleManage =>
      'Quản lý hoặc hủy bất kỳ lúc nào trong Google Play › Thanh toán và đăng ký.';

  @override
  String get billingReferFriend => 'Giới thiệu bạn bè';

  @override
  String get billingHowItWorks => 'Cách hoạt động';

  @override
  String get billingHowShareTitle => 'Chia sẻ liên kết';

  @override
  String get billingHowShareBody => 'Gửi cho bạn bè.';

  @override
  String get billingHowSignUpTitle => 'Họ đăng ký';

  @override
  String get billingHowSignUpBody => 'Bạn bè của bạn tham gia qua liên kết.';

  @override
  String get billingHowBothTitle => 'Cả hai đều nhận Pro';

  @override
  String get billingHowBothBody =>
      'Mỗi người nhận được một tháng Pro miễn phí.';

  @override
  String get billingYourReferrals => 'Lượt giới thiệu của bạn';

  @override
  String get billingInvited => 'Đã mời';

  @override
  String get billingJoined => 'Đã tham gia';

  @override
  String get billingMonthsEarned => 'Số tháng nhận được';

  @override
  String get billingInviteFriend => 'Mời bạn bè';

  @override
  String get billingInviteBody =>
      'Bạn và bạn bè đều được dùng Pro miễn phí một tháng.';

  @override
  String get billingYourCode => 'Mã của bạn';

  @override
  String get billingCopyLink => 'Sao chép liên kết';

  @override
  String get billingShareInvite => 'Chia sẻ lời mời';

  @override
  String get giftUnavailable =>
      'Mời quà tặng không khả dụng trong phiên bản này.';

  @override
  String get giftPageTitle => 'Tặng FitCheck Pro';

  @override
  String get giftNoAllowances => 'Hiện không có lời mời tặng quà miễn phí.';

  @override
  String get giftFormTitle => 'Gửi lời mời miễn phí';

  @override
  String get giftFormBody =>
      'Người nhận xác nhận quà tặng bằng địa chỉ email đã xác minh này. Chúng tôi không gửi email thay bạn.';

  @override
  String get giftFieldFrom => 'Từ';

  @override
  String get giftFieldRecipientName => 'Tên người nhận';

  @override
  String get giftFieldRecipientEmail => 'Email người nhận';

  @override
  String get giftFieldOccasion => 'Dịp (không bắt buộc)';

  @override
  String get giftNoOccasion => 'Không có dịp';

  @override
  String get giftOccasionBirthday => 'Sinh nhật';

  @override
  String get giftOccasionAnniversary => 'Kỷ niệm';

  @override
  String get giftOccasionOther => 'Khác';

  @override
  String get giftFieldCardGreeting => 'Lời chúc trên thiệp';

  @override
  String get giftFieldCardGreetingHelper =>
      'Nội dung này hiển thị trên thiệp đúng như bạn nhập.';

  @override
  String get giftFieldPrivateNote => 'Ghi chú riêng (không bắt buộc)';

  @override
  String get giftCreateAction => 'Tạo quà tặng miễn phí';

  @override
  String get giftClaimedTitle => 'Đã nhận quà tặng';

  @override
  String get giftClaimedActive => 'Quà tặng FitCheck Pro của bạn đã kích hoạt.';

  @override
  String get giftClaimedQueued =>
      'Quà tặng FitCheck Pro của bạn sẽ bắt đầu sau khi quyền truy cập hiện tại hết hạn.';

  @override
  String get giftLinkCopied => 'Đã sao chép liên kết quà tặng vào bộ nhớ tạm.';

  @override
  String get giftErrorName => 'Nhập tên.';

  @override
  String get giftErrorEmail => 'Nhập địa chỉ email hợp lệ.';

  @override
  String get giftErrorGreeting => 'Nhập lời chúc trên thiệp.';

  @override
  String get giftErrorGreetingLength => 'Dùng tối đa 80 ký tự.';

  @override
  String get giftClaimAction => 'Nhận quà';

  @override
  String get giftCardPreview => 'Xem trước thẻ';

  @override
  String get giftGiftForYou => 'Quà dành cho bạn';

  @override
  String get giftGiftWaiting => 'Một món quà đang chờ bạn';

  @override
  String get giftOpenBody => 'Mở quà của bạn để nhận bằng email đã xác thực.';

  @override
  String get giftOpenGifts => 'Mở quà';

  @override
  String get giftSendInvitation => 'Gửi lời mời';

  @override
  String get settingsAiProviderSection => 'Nhà cung cấp';

  @override
  String get settingsAiCustom => 'Tùy chỉnh';

  @override
  String get settingsAiUrlHelper =>
      'Dùng URL công khai mà máy chủ có thể truy cập được. Localhost không hoạt động từ máy chủ của chúng tôi.';

  @override
  String get settingsAiConnectionSection => 'Kết nối';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'Chìa khóa API';

  @override
  String get settingsAiApiKeySaved => 'Đã lưu. Để trống nếu muốn giữ nguyên.';

  @override
  String get settingsAiChatModel => 'Mô hình trò chuyện';

  @override
  String get settingsAiVisionModel => 'Mô hình hình ảnh (tùy chọn)';

  @override
  String get settingsAiImageModel => 'Mô hình tạo ảnh (tùy chọn)';

  @override
  String get settingsAiImageModelNote =>
      'Tạo ảnh cần chat completions tương thích OpenAI với response_modalities.';

  @override
  String get settingsAiTestConnection => 'Kiểm tra kết nối';

  @override
  String get calendarTitle => 'Lịch';

  @override
  String get calendarGoToToday => 'Đi đến hôm nay';

  @override
  String get calendarConnectTooltip => 'Kết nối lịch';

  @override
  String get calendarAddEvent => 'Thêm sự kiện';

  @override
  String get calendarEmptyTitle => 'Chưa có kế hoạch';

  @override
  String get calendarEmptyBody => 'Thêm sự kiện và lên kế hoạch mặc gì.';

  @override
  String get calendarPreviousMonth => 'Tháng trước';

  @override
  String get calendarNextMonth => 'Tháng sau';

  @override
  String get calendarAllDay => 'Cả ngày';

  @override
  String get calendarOutfitLinked => 'Đã liên kết trang phục';

  @override
  String get calendarEventOptions => 'Tùy chọn sự kiện';

  @override
  String get calendarDeleteTitle => 'Xoá sự kiện này?';

  @override
  String get calendarChangeOutfit => 'Đổi trang phục';

  @override
  String get calendarLinkOutfit => 'Liên kết trang phục';

  @override
  String get calendarRemoveOutfit => 'Gỡ trang phục';

  @override
  String get calendarNewEvent => 'Sự kiện mới';

  @override
  String get calendarEditEvent => 'Sửa sự kiện';

  @override
  String get calendarTitleLabel => 'Tiêu đề';

  @override
  String get calendarTitleRequired => 'Thêm tiêu đề';

  @override
  String get calendarEndBeforeStart => 'Kết thúc sau giờ bắt đầu';

  @override
  String get calendarStarts => 'Bắt đầu';

  @override
  String get calendarEnds => 'Kết thúc';

  @override
  String get calendarPlaceOptional => 'Địa điểm (tuỳ chọn)';

  @override
  String get calendarNotesOptional => 'Ghi chú (tuỳ chọn)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Tạo trang phục, sau đó liên kết với sự kiện này.';

  @override
  String get calendarBuildOutfit => 'Tạo trang phục';

  @override
  String get calendarConnectionsTitle => 'Lịch';

  @override
  String get calendarConnectionsBody =>
      'Sự kiện bạn thêm sẽ nằm trong FitCheck.';

  @override
  String get calendarDisconnect => 'Ngắt kết nối';

  @override
  String get calendarNotAvailable => 'Chưa khả dụng';

  @override
  String get profileSectionExplore => 'Khám phá';

  @override
  String get profileNavTryOn => 'Thử đồ';

  @override
  String get profileNavRewards => 'Phần thưởng';

  @override
  String get profileSupport => 'Hỗ trợ';

  @override
  String get profileHelp => 'Trợ giúp';

  @override
  String get profileAbout => 'Giới thiệu';

  @override
  String get profileAboutBody =>
      'Tủ đồ, trang phục và gói của bạn tại một nơi.';

  @override
  String get profileSignOutTitle => 'Đăng xuất?';

  @override
  String get profileSignOutBody => 'Bạn có thể đăng nhập lại bất cứ lúc nào.';

  @override
  String get profileEditTitle => 'Sửa hồ sơ';

  @override
  String get profileYourProfile => 'Hồ sơ của bạn';

  @override
  String get profileBodyProfiles => 'Hồ sơ thể chất';

  @override
  String get profileBodyEmptyTitle => 'Chưa có hồ sơ thể chất';

  @override
  String get profileBodyEmptyBody =>
      'Thêm chiều cao và vóc dáng để đồ vừa vặn hơn.';

  @override
  String get profileBodyAdd => 'Thêm hồ sơ';

  @override
  String get profileBodyDefaultNote =>
      'Hồ sơ mặc định dùng để ước lượng size và thử đồ.';

  @override
  String get profileBodyDefaultBadge => 'Mặc định';

  @override
  String get profileBodyMakeDefault => 'Đặt làm mặc định';

  @override
  String get profileBodyDeleteBody => 'Bạn không thể hoàn tác thao tác này.';

  @override
  String get profileBodyRequired => 'Bắt buộc';

  @override
  String get profileBodyCheckNumber => 'Xác minh số này';

  @override
  String get profileBodyNew => 'Hồ sơ thể chất mới';

  @override
  String get profileBodyNameHint => 'Ví dụ: Tôi';

  @override
  String get profileBodyHeight => 'Chiều cao';

  @override
  String get profileBodyWeight => 'Cân nặng';

  @override
  String get profileBodyBuild => 'Vóc dáng';

  @override
  String get profileBodySkinTone => 'Màu da';

  @override
  String get profileBirthDateNeededBody =>
      'Thêm ngày sinh để kết hợp với giờ sinh.';

  @override
  String get profileBirthDateNeededTitle => 'Cần ngày sinh';

  @override
  String get profilePartlySavedBody =>
      'Chúng tôi đã lưu tên và ảnh của bạn. Thông tin ngày sinh chưa được lưu; vui lòng thử lại sau.';

  @override
  String get profilePartlySavedTitle => 'Lưu một phần';

  @override
  String get profileSavedBody => 'Hồ sơ của bạn đã được lưu.';

  @override
  String get profileChangePhoto => 'Đổi ảnh hồ sơ';

  @override
  String get profilePhotoLabel => 'Ảnh hồ sơ';

  @override
  String get profilePhotoHint => 'Chạm để chọn ảnh khác';

  @override
  String get profileBirthDateLabel => 'Ngày sinh (tùy chọn)';

  @override
  String get profileBirthTimeLabel => 'Giờ sinh (tùy chọn)';

  @override
  String get profileBirthTimeHelper => 'Giúp gợi ý Vedic chính xác hơn';

  @override
  String get profileBirthPlaceLabel => 'Nơi sinh (tùy chọn)';

  @override
  String get profileBirthPlaceHint => 'Ví dụ: New Delhi, Ấn Độ';

  @override
  String get profileHelpContactTitle => 'Hỏi chúng tôi bất cứ điều gì';

  @override
  String get profileHelpContactBody =>
      'Gửi tin nhắn và chúng tôi sẽ trả lời qua email, thường trong vòng một ngày.';

  @override
  String get profileHelpContactAction => 'Liên hệ hỗ trợ';

  @override
  String get profileHelpFaqTitle => 'Câu hỏi thường gặp';

  @override
  String get profileFaqAddPiecesTitle =>
      'Tôi thêm trang phục vào tủ đồ như thế nào?';

  @override
  String get profileFaqAddPiecesBody =>
      'Nhấn Thêm món trên tab Tủ đồ. Chụp ảnh hoặc chọn từ thư viện; hệ thống sẽ tìm và gắn nhãn từng món cho bạn.';

  @override
  String get profileFaqMatchingTitle => 'Ghép đồ hoạt động thế nào?';

  @override
  String get profileFaqMatchingBody =>
      'Mở tab Gợi ý và chọn những món bạn có. Hệ thống gợi ý những món đi kèm và tạo bộ đồ hoàn chỉnh từ tủ đồ của bạn.';

  @override
  String get profileFaqTryOnTitle =>
      'Tôi có thể dùng ảnh của mình để thử đồ không?';

  @override
  String get profileFaqTryOnBody =>
      'Có. Thêm ảnh toàn thân của bạn, sau đó chọn món muốn thử.';

  @override
  String get profileFaqRewardsTitle => 'Tôi nhận phần thưởng như thế nào?';

  @override
  String get profileFaqRewardsBody =>
      'Lên lịch và ghi lại đồ thường xuyên. Chuỗi ngày và thành tựu sẽ tăng dần khi bạn dùng.';

  @override
  String get profileFaqPrivacyTitle => 'Tủ đồ của tôi có riêng tư không?';

  @override
  String get profileFaqPrivacyBody =>
      'Có. Tủ đồ và các bộ đồ của bạn riêng tư trừ khi bạn chia sẻ đường link của một bộ.';

  @override
  String get profileHelpMoreTitle => 'Hỗ trợ thêm';

  @override
  String get profileHelpGuides => 'Hướng dẫn';

  @override
  String get profileHelpGuidesBody => 'Cách hoạt động của từng tính năng';

  @override
  String get feedbackCategoryBug => 'Lỗi';

  @override
  String get feedbackCategoryIdea => 'Gợi ý';

  @override
  String get feedbackCategoryGeneral => 'Khác';

  @override
  String get feedbackCategoryHelp => 'Cần hỗ trợ';

  @override
  String get feedbackHintBug =>
      'Đã xảy ra gì và bạn mong đợi điều gì? Các bước sẽ giúp chúng tôi sửa lỗi.';

  @override
  String get feedbackHintIdea => 'Bạn muốn gì và vì sao?';

  @override
  String get feedbackHintGeneral =>
      'Cho chúng tôi biết suy nghĩ của bạn hoặc đặt câu hỏi.';

  @override
  String get feedbackAttachmentLimitBody => 'Bạn có thể thêm tối đa 5 ảnh.';

  @override
  String get feedbackAttachmentLimitTitle => 'Đạt giới hạn';

  @override
  String get feedbackImageTooLargeBody => 'Chọn ảnh dưới 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Ảnh quá lớn';

  @override
  String get feedbackTitle => 'Gửi phản hồi';

  @override
  String get feedbackAboutLabel => 'Về vấn đề gì?';

  @override
  String get feedbackSubjectLabel => 'Chủ đề';

  @override
  String get feedbackSubjectRequired => 'Thêm tiêu đề';

  @override
  String get feedbackSubjectTooShort => 'Tiêu đề phải có ít nhất 3 ký tự';

  @override
  String get feedbackDetailsLabel => 'Chi tiết';

  @override
  String get feedbackDetailsRequired => 'Thêm thông tin chi tiết';

  @override
  String get feedbackDetailsTooShort => 'Mô tả phải có ít nhất 10 ký tự';

  @override
  String get feedbackAddScreenshot => 'Thêm ảnh chụp màn hình';

  @override
  String get feedbackAttachmentHint => 'Tối đa 5, mỗi 5 MB';

  @override
  String get feedbackSend => 'Gửi';

  @override
  String get feedbackEmptyTitle => 'Chưa gửi gì';

  @override
  String get feedbackEmptyBody =>
      'Những gì bạn gửi sẽ hiển thị ở đây cùng trạng thái.';

  @override
  String get feedbackHistoryTitle => 'Nội dung đã gửi';

  @override
  String get feedbackStatusOpen => 'Mở';

  @override
  String get feedbackStatusInProgress => 'Đang xử lý';

  @override
  String get feedbackStatusResolved => 'Đã giải quyết';

  @override
  String get feedbackStatusClosed => 'Đã đóng';

  @override
  String get legalIntro =>
      'Cách chúng tôi bảo vệ dữ liệu của bạn và các điều khoản sử dụng FitCheck AI.';

  @override
  String get legalPolicies => 'Chính sách';

  @override
  String get legalPrivacySubtitle => 'Những gì chúng tôi thu thập và lý do';

  @override
  String get legalTermsTitle => 'Điều khoản dịch vụ';

  @override
  String get legalTermsSubtitle => 'Quy tắc sử dụng ứng dụng';

  @override
  String get legalLicences => 'Giấy phép mã nguồn mở';

  @override
  String get legalSupportSubtitle =>
      'Hỗ trợ, liên hệ và yêu cầu quyền riêng tư';

  @override
  String get legalReportAbuse => 'Báo cáo sự cố hoặc lạm dụng';

  @override
  String get permissionCameraTitle => 'Truy cập máy ảnh';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI sử dụng máy ảnh của bạn để chụp ảnh quần áo và trang phục cho chức năng thử đồ AI và sắp xếp tủ đồ.';

  @override
  String get permissionPhotoTitle => 'Truy cập ảnh';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI cần quyền truy cập vào ảnh của bạn để bạn có thể chọn hình ảnh quần áo và trang phục cho các tính năng AI và tủ đồ.';

  @override
  String get permissionNotNow => 'Chưa';

  @override
  String get permissionOpenSettings => 'Mở Cài đặt';

  @override
  String authSignedInAs(String name) {
    return 'Đăng nhập với $name';
  }

  @override
  String get authSignedIn => 'Đã đăng nhập';

  @override
  String get authWelcomeBackTitle => 'Chào mừng trở lại';

  @override
  String get authSignInFailed => 'Đăng nhập thất bại';

  @override
  String get authWelcomeTitle => 'Chào mừng';

  @override
  String get authSignUpFailed => 'Đăng ký thất bại';

  @override
  String get authGoogleSignInFailed => 'Đăng nhập Google thất bại';

  @override
  String get authAppleSignInFailed => 'Đăng nhập Apple thất bại';

  @override
  String get authConfirmEmailTitle => 'Xác nhận email';

  @override
  String get authConfirmEmailBody =>
      'Kiểm tra hộp thư để tìm email xác nhận, sau đó đăng nhập.';

  @override
  String get authClosetReady => 'Tủ đồ của bạn đã sẵn sàng.';

  @override
  String get authSignedOutTitle => 'Đã đăng xuất';

  @override
  String get authSignedOutBody => 'Bạn đã đăng xuất.';

  @override
  String get authSignOutFailed => 'Đăng xuất thất bại';

  @override
  String get authEmailSentTitle => 'Đã gửi email';

  @override
  String get authResetLinkSent => 'Kiểm tra email để tìm liên kết đặt lại.';

  @override
  String get authPasswordUpdatedTitle => 'Đã cập nhật mật khẩu';

  @override
  String get authPasswordUpdated => 'Mật khẩu của bạn đã được cập nhật.';

  @override
  String get authPasswordNotUpdated => 'Chưa cập nhật mật khẩu';

  @override
  String get authCouldNotSendEmail => 'Không thể gửi email';

  @override
  String get authEmailNotSent => 'Chưa gửi email';

  @override
  String get authResendSentBody => 'Chúng tôi đã gửi email xác nhận mới.';

  @override
  String get outfitPreviewWithAi => 'Xem trước với AI';

  @override
  String get outfitNewPreview => 'Tạo xem trước mới';

  @override
  String get outfitBuilderClosetHeading => 'Tủ đồ của bạn';

  @override
  String get outfitBuilderSearchHint => 'Tìm trang phục';

  @override
  String get outfitClearSearch => 'Xóa tìm kiếm';

  @override
  String get outfitBuilderAddPiecesTitle => 'Thêm trang phục trước';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Bộ đồ được tạo từ các trang phục trong tủ đồ của bạn.';

  @override
  String get outfitBuilderNoMatches => 'Không có trang phục nào phù hợp.';

  @override
  String get outfitNameLabel => 'Tên bộ đồ';

  @override
  String get outfitNameHint => 'Ví dụ: Vải lanh cuối tuần';

  @override
  String get outfitPreviewSemantic => 'Xem trước bộ trang phục bằng AI';

  @override
  String get outfitChoosePieces => 'Chọn món đồ';

  @override
  String get outfitTapPiecesHint => 'Chạm vào các món đồ bên dưới để thêm.';

  @override
  String get outfitShareTooltip => 'Chia sẻ';

  @override
  String get outfitSaveFavourite => 'Lưu vào yêu thích';

  @override
  String get outfitPiecesHeading => 'Món đồ';

  @override
  String get outfitWearHistoryEmpty => 'Đội một lần để xem ngày ở đây.';

  @override
  String get outfitWearHistoryTitle => 'Lịch sử sử dụng';

  @override
  String get outfitWearHistoryError => 'Không thể tải ngày.';

  @override
  String get outfitWornOn => 'Sử dụng vào';

  @override
  String get outfitEditTitle => 'Chỉnh sửa bộ đồ';

  @override
  String get outfitSavedPhotosFailed => 'Đã lưu chi tiết, chưa lưu ảnh';

  @override
  String get outfitNoPhotosBody => 'Chưa có ảnh. Bộ đồ sẽ hiển thị các món đồ.';

  @override
  String get outfitOccasionLabel => 'Dịp';

  @override
  String get outfitOccasionNone => 'Không có';

  @override
  String get outfitTagsHint => 'Tách bằng dấu phẩy';

  @override
  String get outfitDraftBody => 'Ẩn khỏi danh sách chính';

  @override
  String get outfitPublic => 'Công khai';

  @override
  String get outfitPublicBody => 'Bất kỳ ai có liên kết đều có thể xem';

  @override
  String get outfitDeleteFromDetail => 'Xóa bộ đồ này khỏi trang chi tiết.';

  @override
  String get outfitNewCollection => 'Bộ sưu tập mới';

  @override
  String get outfitNoCollectionsTitle => 'Chưa có bộ sưu tập';

  @override
  String get outfitNoCollectionsBody =>
      'Gom các bộ đồ theo chuyến đi, mùa hoặc tâm trạng.';

  @override
  String get outfitCreateCollection => 'Tạo bộ sưu tập';

  @override
  String get outfitAddOutfits => 'Thêm bộ đồ';

  @override
  String get outfitRename => 'Đổi tên';

  @override
  String get outfitCollectionDeleteBody =>
      'Các bộ đồ bên trong vẫn được giữ lại.';

  @override
  String get outfitCollectionsNotLoaded => 'Chưa tải bộ đồ';

  @override
  String get outfitRenameCollection => 'Đổi tên bộ sưu tập';

  @override
  String get outfitDescriptionOptional => 'Mô tả (tùy chọn)';

  @override
  String get outfitAllInCollection =>
      'Tất cả các bộ trang phục đã có trong bộ sưu tập này.';

  @override
  String get photoshootSubtitleUpload => 'Chân dung studio từ ảnh của bạn';

  @override
  String get photoshootSubtitleConfigure =>
      'Chọn kiểu dáng, định dạng và số lượng';

  @override
  String get photoshootSubtitleGenerating =>
      'Quy trình này mất từ một đến hai phút';

  @override
  String get photoshootAddPhotosSemantic => 'Thêm ảnh từ thư viện của bạn';

  @override
  String get photoshootUploadTitle => 'Thêm từ 1 đến 4 ảnh của bạn';

  @override
  String get photoshootUploadBody => 'Chạm để chọn từ thư viện';

  @override
  String get photoshootAddToContinue => 'Thêm ảnh để tiếp tục';

  @override
  String get photoshootAddAnotherPhoto => 'Thêm ảnh khác';

  @override
  String get photoshootTipsTitle => 'Để có kết quả tốt nhất';

  @override
  String get photoshootTipsBody =>
      'Dùng ảnh khuôn mặt rõ nét, đủ sáng, chụp từ vài góc khác nhau. Tránh kính râm và mũ.';

  @override
  String get photoshootStarting => 'Đang bắt đầu';

  @override
  String get photoshootCancelling => 'Đang hủy';

  @override
  String get photoshootFailed => 'Thất bại';

  @override
  String get recommendTabMatches => 'Phù hợp';

  @override
  String get recommendTabComplete => 'Tổ hợp';

  @override
  String get recommendTabWeather => 'Thời tiết';

  @override
  String get recommendTabColours => 'Màu sắc';

  @override
  String get recommendTabShop => 'Cửa hàng';

  @override
  String get recommendNoMatchesTitle => 'Chưa có kết quả phù hợp';

  @override
  String get recommendNoMatchesBody =>
      'Chọn một món và hệ thống sẽ tìm những gì hợp với nó.';

  @override
  String get recommendPickPiece => 'Chọn món đồ';

  @override
  String get recommendNothingMatchesTitle =>
      'Chưa có món nào hợp với các món này';

  @override
  String get recommendNothingMatchesBody =>
      'Thử chọn món khác, hoặc thêm nhiều hơn vào tủ đồ.';

  @override
  String get recommendChangePieces => 'Đổi món đồ';

  @override
  String get recommendDefaultReason => 'Hợp với các món bạn đã chọn.';

  @override
  String get recommendCompleteTitle => 'Hoàn thiện phối đồ';

  @override
  String get recommendCompleteBody =>
      'Chọn một món và hệ thống sẽ gợi ý phần còn lại.';

  @override
  String get recommendWorking => 'Đang xử lý';

  @override
  String get recommendGenerate => 'Tạo';

  @override
  String get recommendChooseStyleBody => 'Chọn phong cách rồi tạo.';

  @override
  String get recommendNoLooksTitle => 'Không có mẫu nào cho các món này';

  @override
  String get recommendNoLooksBody => 'Thử phong cách hoặc món đồ khác.';

  @override
  String get recommendDefaultLook => 'Một mẫu cho các món của bạn';

  @override
  String get recommendNoPiecesBody => 'Không có món đồ nào cho mẫu này.';

  @override
  String get recommendCityLabel => 'Thành phố';

  @override
  String get recommendCheck => 'Kiểm tra';

  @override
  String get recommendWeatherTitle => 'Thời tiết thế nào?';

  @override
  String get recommendWeatherBody =>
      'Nhập thành phố để nhận gợi ý cho hôm nay.';

  @override
  String get recommendWearToday => 'Mặc hôm nay';

  @override
  String get recommendWeatherNoPieces =>
      'Tủ chưa có món nào hợp thời tiết này.';

  @override
  String get recommendBudgetLabel => 'Ngân sách tối đa';

  @override
  String get recommendLooking => 'Đang tìm';

  @override
  String get recommendFindWhatToBuy => 'Tìm thứ cần mua';

  @override
  String get recommendFillGapsTitle => 'Điền vào thiếu';

  @override
  String get recommendFillGapsBody =>
      'Đặt ngân sách và chúng tôi sẽ gợi ý thứ tủ thiếu.';

  @override
  String get recommendNoGapsTitle => 'Không phát hiện thiếu';

  @override
  String get recommendNoGapsBody => 'Thử ngân sách lớn hơn hoặc danh mục khác.';

  @override
  String get recommendMoodEveryday => 'Thường ngày';

  @override
  String get recommendMoodBigMeeting => 'Họp quan trọng';

  @override
  String get recommendDayLabel => 'Ngày';

  @override
  String get recommendReadingStars => 'Đoán sao';

  @override
  String get recommendGetMyColours => 'Nhận màu của tôi';

  @override
  String get recommendLuckyColoursTitle => 'Màu may mắn của bạn';

  @override
  String get recommendLuckyColoursBody =>
      'Chọn một ngày, chúng tôi gợi ý màu và món đồ.';

  @override
  String get recommendLuckyColoursSection => 'Màu may mắn';

  @override
  String get recommendAvoidColoursSection => 'Màu nên hạn chế';

  @override
  String get recommendBirthDateTitle => 'Thêm ngày sinh của bạn';

  @override
  String get recommendBirthDateBody =>
      'Cần ngày sinh để phân tích màu của bạn.';

  @override
  String get recommendEditProfile => 'Sửa hồ sơ';

  @override
  String get recommendNothingThisDay => 'Không có gì cho ngày này.';

  @override
  String get recommendUnnamedColour => 'Màu không tên';

  @override
  String get recommendFromCloset => 'Từ tủ đồ của bạn';

  @override
  String get recommendNoPiecesInColours =>
      'Chưa có món đồ nào với các màu này.';

  @override
  String get recommendOutfitIdeas => 'Gợi ý phối đồ';

  @override
  String get recommendNoOutfitsInColours =>
      'Chưa có set đồ hoàn chỉnh với các màu này.';

  @override
  String get recommendDefaultOutfitIdea => 'Một gợi ý phối đồ';

  @override
  String get recommendPickUpToThree => 'Chọn tối đa ba món';

  @override
  String get recommendEmptyClosetBody =>
      'Thêm vài món đồ trước, rồi quay lại để xem gợi ý phối.';

  @override
  String get dashboardDressForDay => 'Mặc đẹp cho ngày sắp tới.';

  @override
  String get dashboardOutfitOfDay => 'Set đồ trong ngày';

  @override
  String get dashboardFreshLook => 'Gương mặt mới';

  @override
  String get subscriptionManageInStoreTitle => 'Quản lý trong cửa hàng';

  @override
  String get subscriptionManageInStoreBody =>
      'Gói này được tính phí qua cửa hàng. Hãy quản lý trong cài đặt tài khoản cửa hàng của bạn.';

  @override
  String get subscriptionCancelledTitle => 'Đã hủy gói';

  @override
  String get subscriptionCancelledBody =>
      'Gói của bạn vẫn có hiệu lực đến cuối kỳ thanh toán này.';

  @override
  String get subscriptionCancelFailedTitle => 'Không thể hủy';

  @override
  String get subscriptionCouldNotOpenTitle => 'Không thể mở';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Không thể mở quản lý thanh toán.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Không thể mở liên kết.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Không tải được liên kết của bạn';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Không tải được liên kết giới thiệu. Hãy thử lại.';

  @override
  String get subscriptionReferralCopiedTitle => 'Đã sao chép';

  @override
  String get subscriptionReferralCopiedBody =>
      'Đã sao chép liên kết giới thiệu.';

  @override
  String get subscriptionReferralShareSubject => 'Thử FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Tham gia FitCheck AI và cả hai chúng ta đều nhận được một tháng Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Đã sao chép liên kết';

  @override
  String get subscriptionShareUnavailableBody =>
      'Chia sẻ không khả dụng, vì vậy chúng tôi đã sao chép liên kết.';

  @override
  String get subscriptionShareFailedTitle => 'Không thể chia sẻ';

  @override
  String get subscriptionShareFailedBody =>
      'Copy the link from the referral page instead.';

  @override
  String get subscriptionStoreReadyTitle => 'Store ready';

  @override
  String get subscriptionStoreReadyBody =>
      'Store prices are available. You can upgrade now.';

  @override
  String get purchaseFailedTitle => 'Purchase failed';

  @override
  String get purchaseUnavailableTitle => 'Purchase unavailable';

  @override
  String get purchaseIapUnavailableBody =>
      'In-app purchases are not available on this device.';

  @override
  String get purchasePlanNotAvailableBody =>
      'This plan is not available for purchase yet.';

  @override
  String get purchasePlanNotInStoreBody =>
      'This plan is not available in the store yet. Please check back soon.';

  @override
  String get purchaseStartFailedBody =>
      'The purchase could not start. Try again.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Checkout did not return a payment link.';

  @override
  String get purchasePendingTitle => 'Purchase pending';

  @override
  String get purchasePendingBody =>
      'Your purchase is waiting for approval. You\'ll get access as soon as it\'s approved.';

  @override
  String get purchaseFailedBody => 'The purchase failed. Try again.';

  @override
  String get purchaseRestoredTitle => 'Restored';

  @override
  String get purchaseRestoredBody => 'Your purchases are restored.';

  @override
  String get purchaseActiveTitle => 'Subscription active';

  @override
  String get purchaseActiveBody => 'Your subscription is active. Welcome.';

  @override
  String get purchaseSignInRequiredTitle => 'Sign in required';

  @override
  String get purchaseSignInRequiredBody => 'Sign in to finish your purchase.';

  @override
  String get purchaseErrorTitle => 'Purchase error';

  @override
  String get purchaseInvalidTransactionBody =>
      'The purchase did not include a verifiable transaction ID.';

  @override
  String get purchaseVerificationPendingTitle => 'Verification pending';

  @override
  String get purchaseVerificationPendingBody =>
      'We couldn\'t verify your purchase with the store right now. It will finish automatically, and you won\'t be charged twice.';

  @override
  String get purchaseNotAppliedTitle => 'Purchase not applied';

  @override
  String get purchaseNotAppliedBody =>
      'Your purchase could not be applied to your account. Contact support, and do not buy it again.';

  @override
  String get purchaseRestoreFailedTitle => 'Restore failed';

  @override
  String get purchaseRestoreFailedBody =>
      'Could not restore purchases. Try again.';

  @override
  String get purchaseRecoveredActiveBody => 'Your subscription is active.';

  @override
  String get purchaseCompleteTitle => 'Purchase complete';

  @override
  String get giftCreateFailedTitle => 'Could not create the gift';

  @override
  String get giftClaimFailedTitle => 'Không thể nhận quà';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món quà dành cho bạn',
      one: 'Một món quà dành cho bạn',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 tháng',
      '12': '1 năm',
      'other': '$months tháng',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'còn $remaining',
      one: 'còn 1',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration của FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender đã tặng bạn $duration của FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Quà FitCheck Pro cho $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Từ $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Dành cho $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Từ $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'người nhận';

  @override
  String get giftPreviewPlaceholderSender => 'bạn';

  @override
  String get settingsSavedTitle => 'Đã lưu';

  @override
  String get settingsNotSavedTitle => 'Chưa lưu';

  @override
  String get settingsAiChooseProviderBody => 'Chọn nhà cung cấp.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Nhà cung cấp tùy chỉnh cần URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Nhập khóa API.';

  @override
  String get settingsAiSavedBody => 'Cài đặt AI của bạn đã được lưu.';

  @override
  String get settingsAiMissingDetailsTitle => 'Thiếu thông tin';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Nhập URL API và mô hình chat để kiểm tra.';

  @override
  String get settingsAiKeyNeededTitle => 'Cần khóa API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Nhập khóa API để kiểm tra. Khóa đã lưu được bảo mật.';

  @override
  String get settingsAiKeyToTestBody => 'Nhập khóa API để kiểm tra.';

  @override
  String get settingsAiConnectedTitle => 'Đã kết nối';

  @override
  String get settingsAiConnectedBody => 'Kết nối hoạt động bình thường.';

  @override
  String get settingsAiTestFailedTitle => 'Kiểm tra thất bại';

  @override
  String get settingsPreferencesSavedBody => 'Tùy chọn của bạn đã được lưu.';

  @override
  String get settingsPasswordNotChangedTitle => 'Mật khẩu không đổi';

  @override
  String get settingsOAuthPasswordBody =>
      'Tài khoản này đăng nhập bằng Google hoặc Apple. Dùng \"Quên mật khẩu\" để đặt mật khẩu trước.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Mật khẩu hiện tại không đúng.';

  @override
  String get settingsExportReadyTitle => 'Sẵn sàng xuất';

  @override
  String get settingsExportReadyBody =>
      'Dữ liệu xuất của bạn đã sẵn sàng để tải xuống.';

  @override
  String get settingsLinkCopiedTitle => 'Đã sao chép liên kết';

  @override
  String get settingsExportClipboardBody =>
      'Không thể mở trình duyệt của bạn, nên chúng tôi đã sao chép liên kết tải xuống. Hãy dán nó vào trình duyệt ngay: liên kết sẽ hết hạn.';

  @override
  String get settingsExportFailedTitle => 'Xuất thất bại';

  @override
  String get settingsAccountNotDeletedTitle => 'Tài khoản chưa bị xóa';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Bạn có thể thêm tối đa $max ảnh.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Giới hạn ảnh';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Thêm ít nhất một ảnh.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Chưa có ảnh';

  @override
  String get photoshootDescribeLookBody => 'Mô tả kiểu dáng bạn muốn.';

  @override
  String get photoshootPromptNeededTitle => 'Cần mô tả';

  @override
  String get photoshootConsentFeatureLabel => 'Chụp ảnh bằng AI';

  @override
  String get photoshootStatusPreparing => 'Đang chuẩn bị ảnh của bạn';

  @override
  String get photoshootStatusGenerating => 'Đang tạo';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lô $current/$total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return 'Đã hoàn thành $done/$total';
  }

  @override
  String get photoshootGenerationFailedBody => 'Tạo thất bại.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready sẵn sàng, $failed thất bại.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Hoàn thành một phần';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ảnh đã sẵn sàng.',
      one: '1 ảnh đã sẵn sàng.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Đã mất kết nối. Vui lòng thử lại.';

  @override
  String get photoshootCouldNotCancelTitle => 'Không thể hủy';

  @override
  String get photoshootRetryFailedTitle => 'Thử lại thất bại';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Ảnh $number đã sẵn sàng.';
  }

  @override
  String get photoshootReplacedTitle => 'Đã thay thế';

  @override
  String get photoshootSavedToGalleryBody => 'Đã lưu vào thư viện của bạn.';

  @override
  String get photoshootSavedTitle => 'Đã lưu';

  @override
  String get photoshootNotSavedTitle => 'Chưa lưu';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tất cả $count ảnh đã trong thư viện của bạn.',
      one: '1 ảnh trong thư viện của bạn.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved/$total đã lưu.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Một số ảnh chưa được lưu';

  @override
  String get tryonConsentFeatureLabel => 'Thử đồ ảo';

  @override
  String get tryonAvatarUpdatedBody => 'Ảnh của bạn đã được cập nhật.';

  @override
  String get tryonSavedTitle => 'Đã lưu';

  @override
  String get tryonUploadFailedTitle => 'Tải lên thất bại';

  @override
  String get tryonChooseGarmentFirstBody => 'Hãy chọn ảnh trang phục trước.';

  @override
  String get tryonNoGarmentTitle => 'Chưa có trang phục';

  @override
  String get tryonWaitForUploadBody => 'Vui lòng chờ ảnh tải lên hoàn tất.';

  @override
  String get tryonStillUploadingTitle => 'Đang tải lên';

  @override
  String get tryonAddYourPhotoFirstBody => 'Hãy thêm ảnh của bạn trước.';

  @override
  String get tryonReadyBody => 'Phiên thử đồ của bạn đã sẵn sàng.';

  @override
  String get tryonFailedTitle => 'Thử đồ thất bại';

  @override
  String get tryonSavedToGalleryBody => 'Đã lưu vào thư viện.';

  @override
  String get tryonNotSavedTitle => 'Chưa lưu';

  @override
  String get calendarEventAddedBody => 'Đã thêm sự kiện';

  @override
  String get calendarEventPlannedTitle => 'Đã lên lịch';

  @override
  String get calendarEventSavedBody => 'Đã lưu sự kiện';

  @override
  String get calendarSavedTitle => 'Đã lưu';

  @override
  String get calendarEventNotSavedTitle => 'Chưa lưu sự kiện';

  @override
  String get calendarEventRemovedBody => 'Đã xóa sự kiện';

  @override
  String get calendarEventDeletedTitle => 'Đã xóa';

  @override
  String get calendarEventNotDeletedTitle => 'Chưa xóa sự kiện';

  @override
  String get calendarOutfitNotLinkedTitle => 'Chưa liên kết bộ trang phục';

  @override
  String get calendarLinkedTitle => 'Đã liên kết';

  @override
  String get calendarOutfitNotRemovedTitle => 'Chưa gỡ bộ trang phục';

  @override
  String get calendarOutfitRemovedBody => 'Đã gỡ bộ trang phục';

  @override
  String get calendarDisconnectedBody => 'Đã ngắt kết nối lịch';

  @override
  String get calendarDisconnectedTitle => 'Đã ngắt kết nối';

  @override
  String get calendarNotDisconnectedTitle => 'Chưa ngắt kết nối lịch';

  @override
  String get calendarTodayLabel => 'Hôm nay';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sự kiện',
      one: '1 sự kiện',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'Từ $start đến $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, đã liên kết bộ đồ';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" sẽ được xóa.';
  }

  @override
  String get calendarThisAppLabel => 'Ứng dụng này';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Đồng bộ hóa với $provider chưa khả dụng. Bạn vẫn có thể thêm sự kiện ở đây.';
  }

  @override
  String get calendarWeekdaySunShort => 'CN';

  @override
  String get calendarWeekdayMonShort => 'T2';

  @override
  String get calendarWeekdayTueShort => 'T3';

  @override
  String get calendarWeekdayWedShort => 'T4';

  @override
  String get calendarWeekdayThuShort => 'T5';

  @override
  String get calendarWeekdayFriShort => 'T6';

  @override
  String get calendarWeekdaySatShort => 'T7';

  @override
  String get calendarWeekdayMonday => 'Thứ Hai';

  @override
  String get calendarWeekdayTuesday => 'Thứ Ba';

  @override
  String get calendarWeekdayWednesday => 'Thứ Tư';

  @override
  String get calendarWeekdayThursday => 'Thứ Năm';

  @override
  String get calendarWeekdayFriday => 'Thứ Sáu';

  @override
  String get calendarWeekdaySaturday => 'Thứ Bảy';

  @override
  String get calendarWeekdaySunday => 'Chủ Nhật';

  @override
  String get outfitSavedToFavouritesBody => 'Đã lưu vào yêu thích';

  @override
  String get outfitRemovedFromFavouritesBody => 'Đã xóa khỏi yêu thích';

  @override
  String get outfitNotSavedTitle => 'Chưa lưu';

  @override
  String get outfitLoggedAsWornBody => 'Đã ghi nhận là mặc hôm nay.';

  @override
  String get outfitNicePickTitle => 'Gợi ý hay';

  @override
  String get outfitRemovedBody => 'Đã xóa bộ đồ.';

  @override
  String get outfitDeletedTitle => 'Đã xóa';

  @override
  String get outfitNotDeletedTitle => 'Chưa xóa';

  @override
  String get outfitDuplicatedBody =>
      'Một bản sao đã được thêm vào các bộ trang phục của bạn.';

  @override
  String get outfitDuplicatedTitle => 'Đã sao chép';

  @override
  String get outfitNotDuplicatedTitle => 'Chưa sao chép';

  @override
  String get outfitNotSharedTitle => 'Chưa chia sẻ';

  @override
  String outfitCollectionReadyBody(String name) {
    return 'Bộ sưu tập \"$name\" đã sẵn sàng.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Chưa tạo bộ sưu tập';

  @override
  String get outfitCollectionUpdatedBody => 'Đã cập nhật bộ sưu tập.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Chưa cập nhật bộ sưu tập';

  @override
  String get outfitCollectionDeletedBody => 'Đã xóa bộ sưu tập.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Chưa xóa bộ sưu tập';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bộ trang phục đã được thêm.',
      one: '1 bộ trang phục đã được thêm.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Chưa thêm bộ trang phục';

  @override
  String get outfitPreviewNotCreatedTitle => 'Chưa tạo bản xem trước';

  @override
  String get outfitGiveNameBody => 'Đặt tên cho bộ trang phục.';

  @override
  String get outfitNameMissingTitle => 'Tên';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Chọn ít nhất một món đồ.';

  @override
  String outfitCreatedBody(String name) {
    return '$name đã nằm trong các bộ trang phục của bạn.';
  }

  @override
  String get outfitSavedTitle => 'Đã lưu';

  @override
  String get wardrobeAddedToFavouritesBody => 'Đã thêm vào yêu thích';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Đã gỡ khỏi yêu thích';

  @override
  String get wardrobeNotSavedTitle => 'Chưa lưu';

  @override
  String get wardrobeLoggedAsWornBody => 'Đã ghi nhận là mặc hôm nay.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Đã xóa khỏi tủ đồ của bạn.';

  @override
  String get wardrobeDeletedTitle => 'Đã xóa';

  @override
  String get wardrobeNotDeletedTitle => 'Chưa xóa';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món đồ đã được xóa khỏi tủ đồ.',
      one: '1 món đồ đã được xóa khỏi tủ đồ.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Trích xuất tủ đồ bằng AI';

  @override
  String get itemAddScanJobLabel => 'Quét';

  @override
  String get itemAddFoundEarlierBody => 'Đã tìm thấy trong lần quét trước đó';

  @override
  String get itemAddLookingAtPhoto => 'Đang xem ảnh của bạn';

  @override
  String get itemAddExtractionFailedBody => 'Không thể trích xuất';

  @override
  String get itemAddJobFailedBody => 'Thiếu sót lỗi';

  @override
  String get itemAddConnectionLostBody => 'Mất kết nối. Thử lại.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Mất kết nối khi đang xử lý.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Món đồ $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Món đồ';

  @override
  String get itemAddNotCancelledTitle => 'Chưa hủy';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count món đồ đã nằm trong tủ đồ của bạn.',
      one: '1 món đồ đã nằm trong tủ đồ của bạn.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'Đã lưu $saved trên $total món đồ. Chạm lưu để thử phần còn lại.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Một số món đồ chưa được lưu';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Chọn ít nhất một bức ảnh.';

  @override
  String get batchPhotoUnreadableBody => 'Không thể đọc được bức ảnh này.';

  @override
  String get batchNoPhotosReadableBody =>
      'Không thể đọc được bất kỳ bức ảnh nào. Hãy thử ảnh khác.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ảnh',
      one: '1 ảnh',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Mất kết nối khi đang xử lý. Thử lại.';

  @override
  String get batchNotCancelledTitle => 'Chưa hủy';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Liên kết bài viết không được hỗ trợ. Nhập liên kết hồ sơ.';

  @override
  String get batchLinkSpacesBody => 'Liên kết không thể chứa khoảng trắng.';

  @override
  String get batchEnterProfileLinkBody =>
      'Nhập liên kết hồ sơ Instagram hoặc Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Nhập liên kết hồ sơ.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Trang đăng nhập không mở được. Thử lại.';

  @override
  String get batchSignInBrowserBody =>
      'Đăng nhập bằng trình duyệt, sau đó quay lại FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Kết nối tài khoản của bạn';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Nhập mã từ ứng dụng xác thực của bạn.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram yêu cầu kiểm tra bảo mật. Hãy đăng nhập bằng trình duyệt trước.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Nhập lại tên người dùng và mật khẩu của bạn.';

  @override
  String get batchSignInFailedBody =>
      'Đăng nhập thất bại. Kiểm tra tên người dùng và mật khẩu của bạn.';

  @override
  String get batchSignInToKeepImportingBody => 'Đăng nhập để tiếp tục nhập.';

  @override
  String get batchAccountNotConnectedBody =>
      'Tài khoản của bạn chưa được kết nối.';

  @override
  String get batchAccountConnectedTitle => 'Tài khoản đã kết nối';

  @override
  String get batchNotConnectedTitle => 'Chưa kết nối';

  @override
  String get batchImportConnectionLostBody =>
      'Mất kết nối khi nhập. Vui lòng tải lại.';

  @override
  String batchPickUpToBody(int max) {
    return 'Chọn tối đa $max ảnh. Chúng tôi sẽ tìm đồ.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count trong số $total ảnh';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Đang chuẩn bị ảnh $done / $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tìm đồ trong $count ảnh',
      one: 'Tìm đồ trong 1 ảnh',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Tài khoản $platform của bạn sử dụng đăng nhập hai bước. Nhập mã 6 chữ số từ ứng dụng xác thực.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Hồ sơ $platform này ở chế độ riêng tư hoặc cần đăng nhập để hiển thị ảnh.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Kết nối với $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã tìm thấy $count ảnh',
      one: 'Đã tìm thấy 1 ảnh',
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
    return '$processed/$total đã xử lý · $added đã thêm · $waiting đang chờ · $skipped đã bỏ qua';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Đang quét ảnh $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Ảnh $number tiếp theo';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Ảnh $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tìm thấy $count món đồ',
      one: 'Tìm thấy 1 món đồ',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ảnh đã được thêm vào tủ đồ của bạn.',
      one: '1 ảnh đã được thêm vào tủ đồ của bạn.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ảnh studio khác đang được xử lý. Bạn có thể lưu phần đã sẵn sàng hoặc rời đi — chúng tôi sẽ thông báo cho bạn.',
      one:
          '1 ảnh studio khác đang được xử lý. Bạn có thể lưu phần đã sẵn sàng hoặc rời đi — chúng tôi sẽ thông báo cho bạn.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Chưa lưu: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces món đồ',
      one: '1 món đồ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos ảnh',
      one: '1 ảnh',
    );
    return '$_temp0 từ $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return 'Đã chọn $chosen. Chạm vào món đồ để bỏ qua.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đang lưu $count món đồ',
      one: 'Đang lưu 1 món đồ',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lưu $count món đồ',
      one: 'Lưu 1 món đồ',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Hồ sơ cơ thể của bạn đã được lưu.';

  @override
  String get bodyProfileSavedTitle => 'Đã lưu';

  @override
  String get bodyProfileNotSavedTitle => 'Chưa lưu';

  @override
  String get bodyProfileSetDefaultBody => 'Đặt làm hồ sơ mặc định của bạn.';

  @override
  String get bodyProfileDeletedBody => 'Đã xóa hồ sơ cơ thể.';

  @override
  String get bodyProfileDeletedTitle => 'Đã xóa';

  @override
  String get bodyProfileNotDeletedTitle => 'Chưa xóa';

  @override
  String get feedbackNotSentTitle => 'Chưa gửi';

  @override
  String get feedbackSentBody =>
      'Cảm ơn bạn. Chúng tôi đọc mọi tin nhắn và sẽ phản hồi khi cần thêm thông tin.';

  @override
  String get feedbackSentTitle => 'Đã gửi phản hồi';

  @override
  String get recommendUnnamedPiece => 'Vật phẩm chưa có tên';

  @override
  String get recommendEnterCityBody =>
      'Nhập thành phố của bạn để nhận gợi ý theo thời tiết.';

  @override
  String get recommendWhichCityTitle => 'Thành phố nào?';

  @override
  String get aiConsentSheetTitle => 'Chia sẻ ảnh với dịch vụ AI';

  @override
  String get aiConsentSheetBody =>
      'Để tạo ảnh thử đồ và ảnh chụp của bạn, FitCheck AI sẽ gửi các ảnh bạn cung cấp (bao gồm ảnh khuôn mặt và cơ thể) đến nhà cung cấp AI bên thứ ba đáng tin cậy (như OpenAI hoặc Google Gemini) để xử lý. Họ sẽ tạo ảnh cho bạn và không sử dụng chúng để huấn luyện mô hình theo điều khoản của chúng tôi. Ảnh được truyền tải bảo mật và không bao giờ được chia sẻ vì mục đích quảng cáo.';

  @override
  String get aiConsentSheetPermission =>
      'Bằng cách tiếp tục, bạn cấp quyền rõ ràng để chia sẻ ảnh của bạn với các nhà cung cấp AI này để tạo ảnh.';

  @override
  String get skeletonsLoadMoreFailed => 'Không thể tải thêm.';

  @override
  String get jobsPiecesReadyTitle => 'Sản phẩm của bạn đã sẵn sàng';

  @override
  String get jobsScanStoppedTitle => 'Quá trình quét đã dừng';

  @override
  String get jobsNothingSavedBody => 'Không có gì được lưu. Hãy thử lại.';

  @override
  String get jobsPhotoUploadFailedBody => 'Tải ảnh lên thất bại.';

  @override
  String get authGoogleSignInStartFailed =>
      'Không thể bắt đầu Đăng nhập Google. Vui lòng thử lại.';

  @override
  String get referralAppliedTitle => 'Đã áp dụng giới thiệu!';

  @override
  String get billingStoreUnavailableBody =>
      'Không thể mua trên cửa hàng này cho thiết bị này.';

  @override
  String get billingPurchaseProcessingBody =>
      'Giao dịch này vẫn đang được xử lý. Mở lại ứng dụng sau một phút để xem gói của bạn.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Tải ảnh đại diện lên không trả về URL của ảnh.';

  @override
  String get rewardsDayStreakLabel => 'ngày liên tiếp';

  @override
  String rewardsBestStreak(int days) {
    return '$days ngày tốt nhất';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Cần quyền truy cập $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Quyền truy cập $permission hiện đang bị từ chối. Mở Cài đặt để cho phép, sau đó quay lại và thử lại.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Bước $step / 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Bước $step / $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Xóa ảnh $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Xóa ảnh $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points điểm';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Gửi email đến $email. Chúng tôi xem xét các báo cáo trong vòng 24 giờ.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Xóa $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Xóa \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Thêm vào \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return 'Đã xóa \"$name\". Các món đồ vẫn giữ trong tủ đồ của bạn.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Xem tất cả $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Còn $count ảnh hôm nay';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Ảnh $index thất bại';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected / $max ảnh';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Dáng $shape · Da $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Xóa $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Tùy chọn cho $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Mặc nhiều nhất: $name, $count lần';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: chưa cài';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% phù hợp';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return 'Đã chọn $picked / $max';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Xóa $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Ưu tiên $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Gói này được tính phí qua $store. Hãy thay đổi hoặc hủy trong cài đặt tài khoản $store của bạn.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Quản lý trong $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current / $max đã dùng';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Còn khoảng ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done / $total ảnh studio sẵn sàng';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready / $total ảnh studio sẵn sàng. Chạm vào món đồ để bỏ qua.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height cm · $weight kg';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => 'Không';
}
