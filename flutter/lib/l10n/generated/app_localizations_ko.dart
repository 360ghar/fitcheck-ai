// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => '홈';

  @override
  String get tabPhotoshoot => '촬영';

  @override
  String get tabCloset => '옷장';

  @override
  String get tabOutfits => '코디';

  @override
  String get tabMore => '더보기';

  @override
  String get actionAddItem => '아이템 추가';

  @override
  String get actionCreateOutfit => '코디 만들기';

  @override
  String get actionCancel => '취소';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionSave => '저장';

  @override
  String get actionRetry => '재시도';

  @override
  String get actionDone => '완료';

  @override
  String get actionNext => '다음';

  @override
  String get actionBack => '뒤로';

  @override
  String get actionClose => '닫기';

  @override
  String get actionSearch => '검색';

  @override
  String get actionContinue => '계속';

  @override
  String get stateLoading => '불러오는 중';

  @override
  String get stateErrorTitle => '오류가 발생했습니다';

  @override
  String get stateErrorBody => '다시 시도해주세요. 문제가 지속되면 고객센터로 문의하세요.';

  @override
  String get stateOfflineTitle => '오프라인 상태입니다';

  @override
  String get stateOfflineBody => '네트워크에 연결하여 옷장을 동기화하고 코디를 생성하세요.';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsAccountSection => '계정';

  @override
  String get settingsPreferencesSection => '환경설정';

  @override
  String get settingsPlanBilling => '플랜 및 결제';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsUnits => '단위 설정';

  @override
  String get settingsAppearance => '테마';

  @override
  String get settingsPrivacySection => '개인정보 및 데이터';

  @override
  String get settingsAboutSection => '앱 정보';

  @override
  String get settingsSignOut => '로그아웃';

  @override
  String get settingsDeleteAccount => '계정 삭제';

  @override
  String get settingsDeleteAccountTitle => '계정을 삭제하시겠습니까?';

  @override
  String get settingsDeleteAccountBody =>
      '옷장, 코디, 사진 및 프로필 정보가 모두 삭제되며 복구할 수 없습니다.';

  @override
  String get settingsUnitsImperial => '야드파운드법 (in, lb)';

  @override
  String get settingsUnitsMetric => '미터법 (cm, kg)';

  @override
  String get languageTitle => '언어';

  @override
  String get languageSystem => '기기 언어 사용';

  @override
  String get languageSystemBody => 'FitCheck AI가 휴대폰 설정 언어를 따릅니다.';

  @override
  String get languageSearchHint => '언어 검색';

  @override
  String get languageCurrent => '현재';

  @override
  String get languageReviewNote => '새로 번역된 언어입니다. 어색한 부분이 있으면 알려주세요.';

  @override
  String get languageChanged => '언어 변경 완료';

  @override
  String get paywallTitle => '플랜 선택';

  @override
  String get paywallTrialBadge => '1개월 무료';

  @override
  String get paywallTrialTitle => 'Pro 첫 달 무료 이용';

  @override
  String get paywallTrialBody => '옷장 전체를 한 번에 업로드하세요. 이후에도 아이템을 계속 추가할 수 있습니다.';

  @override
  String get paywallFreeForeverTitle => '평생 무료';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return '카드 등록이 필요 없습니다. 매달 $uploads개의 AI 업로드, $outfits개의 코디, $images개의 화보 사진을 제공합니다.';
  }

  @override
  String get paywallCtaTrial => '무료 체험 시작';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan 업그레이드';
  }

  @override
  String get paywallRestore => '구매 복원';

  @override
  String get paywallManage => '구독 관리';

  @override
  String get paywallTerms => '이용 약관';

  @override
  String get paywallPrivacy => '개인정보 처리방침';

  @override
  String get paywallPerMonth => '/월';

  @override
  String get paywallPerYear => '/년';

  @override
  String get paywallBestValue => '최고의 가성비';

  @override
  String paywallTrialEligibleOnly(String price) {
    return '신규 구독자 전용 무료 체험입니다. 체험 종료 24시간 전까지 취소하지 않으면 Pro 플랜이 $price에 자동 갱신됩니다.';
  }

  @override
  String get introTitle => '드디어 정리되는 나만의 옷장';

  @override
  String get introBody =>
      '옷을 한 번만 촬영하세요. 이미 가진 옷으로 코디 제안, 가상 착장, 스튜디오 사진을 만들어 드립니다.';

  @override
  String get introStart => '시작하기';

  @override
  String get introHaveAccount => '이미 계정이 있어요';

  @override
  String get introSkip => '건너뛰기';

  @override
  String get authSignIn => '로그인';

  @override
  String get authSignUp => '계정 만들기';

  @override
  String get authEmail => '이메일';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get authContinueApple => 'Apple로 계속하기';

  @override
  String get authContinueGoogle => 'Google로 계속하기';

  @override
  String get authOrDivider => '또는';

  @override
  String get wardrobeTitle => '옷장';

  @override
  String get wardrobeEmptyTitle => '옷장이 비어있어요';

  @override
  String get wardrobeEmptyBody => '첫 번째 아이템을 추가하거나 옷걸이 전체 사진을 한 번에 업로드하세요.';

  @override
  String get wardrobeAddFirst => '첫 아이템 추가';

  @override
  String get wardrobeSearchHint => '옷장 검색';

  @override
  String get categoryTops => '상의';

  @override
  String get categoryBottoms => '하의';

  @override
  String get categoryShoes => '신발';

  @override
  String get categoryAccessories => '액세서리';

  @override
  String get categoryOuterwear => '아우터';

  @override
  String get categorySwimwear => '수영복';

  @override
  String get categoryActivewear => '운동복';

  @override
  String get categoryOther => '기타';

  @override
  String get conditionClean => '세탁 완료';

  @override
  String get conditionDirty => '세탁 필요';

  @override
  String get conditionLaundry => '세탁 중';

  @override
  String get conditionRepair => '수선 필요';

  @override
  String get conditionDonate => '기부 예정';

  @override
  String get seasonSpring => '봄';

  @override
  String get seasonSummer => '여름';

  @override
  String get seasonFall => '가을';

  @override
  String get seasonWinter => '겨울';

  @override
  String get seasonAll => '사계절';

  @override
  String get styleCasual => '캐주얼';

  @override
  String get styleFormal => '포멀';

  @override
  String get styleBusiness => '비즈니스';

  @override
  String get styleSporty => '스포티';

  @override
  String get styleBohemian => '보헤미안';

  @override
  String get styleStreetwear => '스트릿';

  @override
  String get styleVintage => '빈티지';

  @override
  String get styleMinimalist => '미니멀';

  @override
  String get styleRomantic => '로맨틱';

  @override
  String get styleEdgy => '엣지';

  @override
  String get stylePreppy => '프레피';

  @override
  String get styleArtsy => '아티스틱';

  @override
  String get styleClassic => '클래식';

  @override
  String get styleElegant => '엘레강스';

  @override
  String get styleOther => '기타';

  @override
  String get occasionWork => '출근';

  @override
  String get occasionDateNight => '데이트';

  @override
  String get occasionTravel => '여행';

  @override
  String get occasionWedding => '결혼식';

  @override
  String get occasionGym => '운동';

  @override
  String get occasionWeekend => '주말';

  @override
  String get occasionParty => '파티';

  @override
  String get occasionInterview => '면접';

  @override
  String get colorBlack => '블랙';

  @override
  String get colorWhite => '화이트';

  @override
  String get colorGrey => '그레이';

  @override
  String get colorNavy => '네이비';

  @override
  String get colorBrown => '브라운';

  @override
  String get colorRed => '레드';

  @override
  String get colorBlue => '블루';

  @override
  String get colorGreen => '그린';

  @override
  String get colorPink => '핑크';

  @override
  String get colorPurple => '퍼플';

  @override
  String get colorYellow => '옐로우';

  @override
  String get colorOrange => '오렌지';

  @override
  String get colorBeige => '베이지';

  @override
  String get dateToday => '오늘';

  @override
  String get dateYesterday => '어제';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 전',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count주 전',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개월 전',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count년 전',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI가 마음에 드시나요?';

  @override
  String get ratingPromptBody => '평점을 남겨주시면 다른 분들의 스타일 찾기에 큰 도움이 됩니다.';

  @override
  String get ratingPromptYes => '평가하기';

  @override
  String get ratingPromptNo => '나중에';

  @override
  String get closetNoMatchesTitle => '일치하는 아이템 없음';

  @override
  String get closetNoMatchesBody => '필터를 줄이거나 다른 검색어를 입력해보세요.';

  @override
  String get closetClearFilters => '필터 초기화';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '아이템 $count개',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => '아이템 불러오는 중';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 선택됨',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => '선택 삭제';

  @override
  String get closetCancelSelection => '선택 취소';

  @override
  String get closetCloseSearch => '검색 닫기';

  @override
  String get closetShowGrid => '그리드로 보기';

  @override
  String get closetShowList => '리스트로 보기';

  @override
  String get closetShowRows => '행으로 보기';

  @override
  String get closetStatsTitle => '옷장 통계';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 아이템을 삭제할까요?',
      one: '1개의 아이템을 삭제할까요?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => '해당 아이템을 포함한 코디에서 삭제됩니다.';

  @override
  String get closetSortBy => '정렬 기준';

  @override
  String get closetFavourites => '즐겨찾기';

  @override
  String get closetFavourite => '즐겨찾기 추가';

  @override
  String get closetUnfavourite => '즐겨찾기 해제';

  @override
  String get closetWoreToday => '오늘 입음';

  @override
  String closetWornTimes(int count) {
    return '$count회 착용';
  }

  @override
  String get closetCategoryLabel => '카테고리';

  @override
  String get closetUseCaseLabel => '용도';

  @override
  String get closetAnyUseCase => '전체';

  @override
  String get closetOtherUseCase => '기타 용도';

  @override
  String get closetOtherUseCaseHint => '예: 브런치';

  @override
  String get closetUseUseCase => '적용';

  @override
  String get closetClearAll => '전체 초기화';

  @override
  String get sortNewest => '최신순';

  @override
  String get sortOldest => '오래된순';

  @override
  String get sortName => '이름순 (가나다)';

  @override
  String get sortMostWorn => '많이 입은순';

  @override
  String get useCaseInformal => '일상';

  @override
  String get useCaseDate => '데이트';

  @override
  String get useCaseDinner => '저녁 식사';

  @override
  String get useCaseLunch => '점심 식사';

  @override
  String get actionSelect => '선택';

  @override
  String get actionEdit => '편집';

  @override
  String get actionFilter => '필터';

  @override
  String get actionSort => '정렬';

  @override
  String get actionAll => '전체';

  @override
  String get dashboardStartClosetTitle => '옷장 시작하기';

  @override
  String get dashboardStartClosetBody => '옷을 촬영하세요. FitCheck AI가 태그를 달아드립니다.';

  @override
  String get dashboardPieces => '아이템';

  @override
  String get dashboardOutfits => '코디';

  @override
  String get dashboardDayStreak => '일 연속';

  @override
  String dashboardAddedThisMonth(int count) {
    return '이번 달 +$count개';
  }

  @override
  String dashboardBestStreak(int count) {
    return '최고 $count일';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '즐겨찾기 $count개',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '저장된 코디 $count개',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return '가장 많이 입은 옷: $name, $count회';
  }

  @override
  String get setupSkip => '설정 건너뛰기';

  @override
  String get setupWhoTitle => '누구를 위한 스타일링인가요?';

  @override
  String get setupWhoBody => '가상 착용 및 화보용 모델을 설정합니다. 프로필에서 변경 가능합니다.';

  @override
  String get setupStyleTitle => '어떤 스타일을 즐겨 입으시나요?';

  @override
  String get setupStyleBody => '원하는 스타일을 선택하세요. 코디 아이디어를 제안해 드립니다.';

  @override
  String get setupClosetTitle => '첫 아이템을 추가하세요.';

  @override
  String get setupClosetBody => '옷을 한두 벌 또는 여러 벌 촬영하세요. 각 아이템을 자동으로 분류해 드립니다.';

  @override
  String get setupAddClothes => '옷 추가하기';

  @override
  String get setupStylesLabel => '스타일';

  @override
  String get setupOccasionsLabel => '상황';

  @override
  String get setupSkipStep => '건너뛰기';

  @override
  String get setupLater => '나중에';

  @override
  String get setupSaveError => '저장 실패';

  @override
  String get genderWomen => '여성';

  @override
  String get genderMen => '남성';

  @override
  String get genderNonBinary => '논바이너리';

  @override
  String get genderPreferNotToSay => '밝히지 않음';

  @override
  String get outfitEmptyTitle => '저장된 코디 없음';

  @override
  String get outfitEmptyBody => '옷장 속 아이템으로 코디를 완성해보세요.';

  @override
  String get outfitNoMatchesTitle => '일치하는 코디 없음';

  @override
  String get outfitSearchHint => '코디 검색';

  @override
  String get outfitLoading => '코디 불러오는 중';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '코디 $count개',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => '스타일 및 계절';

  @override
  String get outfitCollections => '컬렉션';

  @override
  String get outfitDuplicate => '복제';

  @override
  String get outfitDeleteTitle => '이 코디를 삭제할까요?';

  @override
  String get outfitDeleteBody => '옷장 속 아이템은 그대로 유지됩니다.';

  @override
  String get outfitDrafts => '임시 보관함';

  @override
  String get outfitDraft => '임시 보관';

  @override
  String get filterStyle => '스타일';

  @override
  String get filterSeason => '계절';

  @override
  String get itemDetailDeleteTitle => '이 아이템을 삭제할까요?';

  @override
  String get itemDetailDeleteBody => '이 아이템을 포함한 코디에서 삭제됩니다.';

  @override
  String get itemAddFavourite => '즐겨찾기 추가';

  @override
  String itemSize(String size) {
    return '$size 사이즈';
  }

  @override
  String get itemColours => '색상';

  @override
  String get itemMaterial => '소재';

  @override
  String get itemPattern => '패턴';

  @override
  String get itemUseCases => '용도';

  @override
  String get itemKeptIn => '보관 위치';

  @override
  String get itemPrice => '가격';

  @override
  String get itemBought => '구매일';

  @override
  String get itemTags => '태그';

  @override
  String get itemAdded => '추가일';

  @override
  String get itemTimesWornLabel => '착용 횟수';

  @override
  String get itemLastWornLabel => '마지막 착용';

  @override
  String get itemNeverWorn => '착용 안 함';

  @override
  String get authEntryBody => 'FitCheck AI가 제안하는 나만의 스타일. 코디를 계획하고 입어보고 촬영하세요.';

  @override
  String get authCreateCloset => '옷장 만들기';

  @override
  String get authWelcomeBack => '다시 오신 것을 환영합니다';

  @override
  String get authSignInBody => '로그인하여 옷장을 확인하세요.';

  @override
  String get authCreateAccount => '계정 만들기';

  @override
  String get authCreateClosetBody => '1분이면 충분합니다. 첫 아이템은 무료입니다.';

  @override
  String get authName => '이름';

  @override
  String get authConfirmPassword => '비밀번호 확인';

  @override
  String get authReferralCode => '추천 코드 (선택 사항)';

  @override
  String get authResetTitle => '비밀번호 재설정';

  @override
  String get authResetBody => '새 비밀번호를 설정할 수 있는 링크를 이메일로 보내드립니다.';

  @override
  String get authSendResetLink => '재설정 링크 보내기';

  @override
  String get authBackToSignIn => '로그인으로 돌아가기';

  @override
  String get authEnterEmail => '이메일 입력';

  @override
  String get authEnterValidEmail => '유효한 이메일을 입력하세요';

  @override
  String get authEnterPassword => '비밀번호 입력';

  @override
  String get authPasswordTooShort => '6자 이상 입력하세요';

  @override
  String get authShowPassword => '비밀번호 표시';

  @override
  String get authHidePassword => '비밀번호 숨기기';

  @override
  String get authNewHere => '처음이신가요?';

  @override
  String authConfirmEmail(String email) {
    return '로그인 전 $email 인증이 필요합니다. 받은 편지함을 확인하세요.';
  }

  @override
  String get authResendEmail => '다시 보내기';

  @override
  String get authResendingEmail => '전송 중…';

  @override
  String get authPasswordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get authEnterName => '이름을 입력하세요';

  @override
  String get authChoosePassword => '비밀번호 설정';

  @override
  String get authHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get authCodeAccepted => '코드가 확인되었습니다';

  @override
  String get authCodeNotFound => '코드를 찾을 수 없습니다';

  @override
  String authReferralFrom(String name) {
    return '$name님의 초대. 한 달 무료 혜택을 드립니다.';
  }

  @override
  String get authReferralInvalid => '유효하지 않은 코드입니다.';

  @override
  String authResetSent(String email) {
    return '$email로 링크를 보냈습니다. 이 기기에서 링크를 열어주세요.';
  }

  @override
  String get introSlide1Title => '옷장을 한 번에 스캔하세요.';

  @override
  String get introSlide1Body => '옷 무더기를 촬영하면 모든 아이템이 자동으로 분류되어 저장됩니다.';

  @override
  String get introSlide2Title => '더 빠르게 준비하세요.';

  @override
  String get introSlide2Body => '일정과 날씨에 맞춰 내 옷으로 코디를 제안합니다.';

  @override
  String get introSlide3Title => '입기 전에 미리 확인하세요.';

  @override
  String get introSlide3Body => '내 사진에 옷을 입혀보거나 화보처럼 스타일링해 보세요.';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsThemeSystem => '시스템 설정';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsTemperature => '온도 단위';

  @override
  String get settingsEmailUpdates => '이메일 알림';

  @override
  String get settingsEmailUpdatesBody => '뉴스 및 스타일 팁 수신';

  @override
  String get settingsOutfitReminders => '코디 알림';

  @override
  String get settingsOutfitRemindersBody => '오늘의 착장 기록 알림';

  @override
  String get settingsWeeklySummary => '주간 요약';

  @override
  String get settingsWeeklySummaryBody => '이번 주 스타일 리포트';

  @override
  String get settingsStyleSection => '스타일';

  @override
  String get settingsPreferredStyles => '선호 스타일';

  @override
  String get settingsPreferredColours => '선호 색상';

  @override
  String get settingsNoneChosen => '선택 안 함';

  @override
  String get settingsPlanAiSection => '플랜 및 AI';

  @override
  String get settingsPlanBillingBody => '플랜, 사용량 및 업그레이드';

  @override
  String get settingsPlanUsageBody => '플랜 및 사용량';

  @override
  String get settingsInviteFriends => '친구 초대';

  @override
  String get settingsInviteFriendsBody => '친구 초대 시 1개월 무료 이용';

  @override
  String get settingsAiProvider => 'AI 제공업체';

  @override
  String get settingsAiProviderBody => '태깅 및 이미지 생성에 사용할 모델 설정';

  @override
  String get settingsAppVersion => '앱 버전';

  @override
  String get settingsPrivacyTerms => '개인정보 처리방침 및 약관';

  @override
  String get settingsReportProblem => '문제 신고';

  @override
  String get settingsChangePassword => '비밀번호 변경';

  @override
  String get settingsExportData => '데이터 내보내기';

  @override
  String get settingsExportBody => '저장된 모든 데이터를 파일로 준비하여 다운로드합니다.';

  @override
  String get settingsExportAction => '내보내기';

  @override
  String get settingsCurrentPassword => '현재 비밀번호';

  @override
  String get settingsNewPassword => '새 비밀번호';

  @override
  String get settingsConfirmNewPassword => '새 비밀번호 확인';

  @override
  String get settingsEnterCurrentPassword => '현재 비밀번호를 입력하세요';

  @override
  String get settingsEnterNewPassword => '새 비밀번호를 입력하세요';

  @override
  String get settingsPasswordMin8 => '8자 이상 입력하세요';

  @override
  String get settingsPasswordNeedsUpper => '대문자를 포함하세요';

  @override
  String get settingsPasswordNeedsLower => '소문자를 포함하세요';

  @override
  String get settingsPasswordNeedsDigit => '숫자를 포함하세요';

  @override
  String get settingsPasswordsNoMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get settingsChangeAction => '변경';

  @override
  String get itemAddSnapTitle => '아이템 촬영';

  @override
  String get itemAddSnapBody => '사진 속 아이템을 감지하여 깔끔한 스튜디오 컷으로 변환합니다.';

  @override
  String get itemAddCamera => '사진 촬영';

  @override
  String get itemAddGallery => '갤러리에서 선택';

  @override
  String get itemAddOtherWays => '다른 추가 방법';

  @override
  String get itemAddSeveral => '여러 장 추가';

  @override
  String get itemAddSeveralBody => '한 번에 최대 50장';

  @override
  String get itemAddImportProfile => '프로필에서 가져오기';

  @override
  String get itemAddImportProfileBody => 'Instagram 또는 Facebook';

  @override
  String get itemAddEnterDetails => '직접 입력하기';

  @override
  String get itemAddEnterDetailsBody => '사진 없이 등록';

  @override
  String get itemManualIntro => '이름만 입력하면 됩니다. 나머지는 나중에 추가하세요.';

  @override
  String get itemManualNameHint => '예: 파란색 면 티셔츠';

  @override
  String get itemManualEnterName => '이름 입력';

  @override
  String get itemManualNotes => '메모';

  @override
  String get itemManualBrand => '브랜드';

  @override
  String get itemManualSize => '사이즈';

  @override
  String get itemManualEnterNumber => '숫자 입력';

  @override
  String get itemManualSavePiece => '저장하기';

  @override
  String get itemManualSaving => '저장 중';

  @override
  String get itemManualSavedTitle => '저장 완료';

  @override
  String itemManualSavedBody(String name) {
    return '$name이(가) 옷장에 추가되었습니다.';
  }

  @override
  String get itemManualNotSaved => '저장되지 않음';

  @override
  String get itemManualAddUseCase => '용도 추가';

  @override
  String get itemManualAddUseCaseAction => '용도 추가하기';

  @override
  String get itemPhotos => '사진';

  @override
  String get itemAddPhotos => '사진 추가';

  @override
  String get itemNoPhotoYet => '사진이 없습니다. 사진 없이 저장할 수 있습니다.';

  @override
  String get itemRemovePhoto => '사진 삭제';

  @override
  String get itemRemovePiece => '아이템 삭제';

  @override
  String get filterConditionLabel => '상태';

  @override
  String get photoshootStepPhotos => '사진';

  @override
  String get photoshootStepSetup => '설정';

  @override
  String get photoshootStepCreating => '생성 중';

  @override
  String get photoshootStepResults => '결과';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return '$current/$total 단계, $name';
  }

  @override
  String get photoshootOneFailed => '사진 한 장을 불러오지 못했습니다. 아래에서 다시 시도하세요.';

  @override
  String photoshootManyFailed(int count) {
    return '$count장의 사진을 불러오지 못했습니다. 아래에서 각각 다시 시도하세요.';
  }

  @override
  String get photoshootFormat => '형식';

  @override
  String get photoshootHowMany => '개수';

  @override
  String get photoshootYourPrompt => '프롬프트';

  @override
  String get photoshootPromptHint => '루프탑에서의 골든 아워, 린넨 셔츠';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진 $count장 생성',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => '오늘의 제한 횟수를 확인할 수 없습니다.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan 플랜: 오늘 $remaining/$limit회 남음';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => '무료';

  @override
  String get photoshootGallery => '갤러리';

  @override
  String get photoshootUseCamera => '카메라 사용';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '사진 $number 삭제';
  }

  @override
  String get photoshootNoPhotosTitle => '생성된 사진이 없습니다';

  @override
  String get photoshootNoPhotosBody => '이미지가 생성되지 않았습니다. 다시 시도해주세요.';

  @override
  String get photoshootNewStyle => '새로운 스타일';

  @override
  String get photoshootNewPhotos => '새로운 사진';

  @override
  String photoshootOpenPhoto(int number) {
    return '사진 $number 열기';
  }

  @override
  String get photoshootReportPhoto => '사진 신고';

  @override
  String get photoshootSaveToGallery => '갤러리에 저장';

  @override
  String get actionUpgrade => '업그레이드';

  @override
  String get referralLimitTitle => '오늘의 사진 생성 횟수를 모두 사용했습니다';

  @override
  String get referralLimitBody =>
      '무료 사진 생성은 내일 초기화됩니다. 친구를 초대하고 Pro 1개월 무료 혜택을 받으세요.';

  @override
  String get referralLimitRefer => '친구 초대하기';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => '데이팅 앱';

  @override
  String get photoshootUsePortfolio => '포트폴리오';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => '감성 사진';

  @override
  String get photoshootUseCustom => '직접 입력';

  @override
  String get photoshootDescLinkedin => '전문적인 프로필 사진';

  @override
  String get photoshootDescDating => '편안하고 따뜻한 자연스러운 느낌';

  @override
  String get photoshootDescPortfolio => '편집 화보 스타일의 하이패션';

  @override
  String get photoshootDescInstagram => '피드를 위한 라이프스타일 샷';

  @override
  String get photoshootDescAesthetic => '분위기 있는 예술적 프레임';

  @override
  String get photoshootDescCustom => '원하는 스타일을 설명하세요';

  @override
  String get aspectSquare => '정사각형';

  @override
  String get aspectPortrait => '세로형';

  @override
  String get aspectLandscape => '가로형';

  @override
  String get aspectTall => '긴 세로형';

  @override
  String get aspectWide => '넓은 가로형';

  @override
  String get tryOnAppBar => '가상 착용';

  @override
  String get tryOnYourPhoto => '내 사진';

  @override
  String get tryOnGarment => '의류';

  @override
  String get tryOnUploadingPhoto => '사진 업로드 중';

  @override
  String get tryOnAddPhotoPrompt => '전신 사진을 추가하세요';

  @override
  String get tryOnBodyPhotoHint => '전신 사진이 가장 좋습니다';

  @override
  String get tryOnAddPhoto => '사진 추가';

  @override
  String get tryOnChangePhoto => '사진 변경';

  @override
  String get tryOnPhotoLoadFailed => '사진을 불러올 수 없습니다.';

  @override
  String get tryOnChooseGarment => '의류 사진 선택';

  @override
  String get tryOnChooseOneGarment => '의류 사진 하나를 선택하세요';

  @override
  String get tryOnGarmentHint => '바닥에 펼치거나 옷걸이에 건 사진이 좋습니다';

  @override
  String get tryOnChange => '변경';

  @override
  String get tryOnCamera => '카메라';

  @override
  String get tryOnRemove => '삭제';

  @override
  String get tryOnLookTitle => '룩';

  @override
  String get tryOnStyle => '스타일';

  @override
  String get tryOnBackground => '배경';

  @override
  String get tryOnPose => '포즈';

  @override
  String get tryOnDressingUp => '착용 중입니다. 약 30초 정도 소요됩니다.';

  @override
  String get tryOnEmptyResult => '가상 착용 결과가 여기에 표시됩니다';

  @override
  String get tryOnReportImage => '이미지 신고';

  @override
  String get tryOnCreating => '생성 중';

  @override
  String get tryOnTryAgain => '다시 시도';

  @override
  String get tryOnCreate => '가상 착용 생성';

  @override
  String get tryOnBackgroundStudioWhite => '스튜디오 화이트';

  @override
  String get tryOnBackgroundStudioGrey => '스튜디오 그레이';

  @override
  String get tryOnBackgroundUrban => '어반 스트릿';

  @override
  String get tryOnBackgroundNature => '자연';

  @override
  String get tryOnBackgroundMinimal => '미니멀';

  @override
  String get tryOnPoseFront => '정면';

  @override
  String get tryOnPoseSide => '측면';

  @override
  String get tryOnPoseWalking => '걷는 모습';

  @override
  String get dashboardGreetingMorning => '좋은 아침입니다';

  @override
  String get dashboardGreetingAfternoon => '좋은 오후입니다';

  @override
  String get dashboardGreetingEvening => '좋은 저녁입니다';

  @override
  String get dashboardWelcome => '환영합니다';

  @override
  String get dashboardOpenProfile => '프로필 열기';

  @override
  String get dashboardRailToday => '오늘';

  @override
  String get dashboardRailRecently => '최근';

  @override
  String get dashboardActivityEmpty => '새로운 아이템과 코디가 여기에 표시됩니다.';

  @override
  String get quickAddPiece => '아이템 추가';

  @override
  String get quickAddPieceBody => '촬영 및 태그';

  @override
  String get quickBuildOutfit => '코디 만들기';

  @override
  String get quickBuildOutfitBody => '아이템 조합';

  @override
  String get quickForYou => '추천';

  @override
  String get quickForYouBody => '오늘의 추천';

  @override
  String get quickPlanWeek => '주간 계획';

  @override
  String get quickPlanWeekBody => '날짜별 코디';

  @override
  String get referralBannerUrgent => '부족하신가요? 친구를 초대하세요.';

  @override
  String get referralBannerTitle => '한 달 선물하고, 한 달 받으세요.';

  @override
  String get referralBannerBody => '친구와 함께 Pro 한 달 무료 혜택을 받으세요.';

  @override
  String get referralBannerDismiss => '일주일간 숨기기';

  @override
  String get referralBannerShare => '초대 공유';

  @override
  String get referralBannerCopy => '링크 복사';

  @override
  String get itemEditPieceTitle => '아이템 수정';

  @override
  String get itemEditDescriptionLabel => '설명';

  @override
  String get itemEditNotSaved => '저장되지 않음';

  @override
  String get itemEditSavedTitle => '저장됨';

  @override
  String get itemEditSavedBody => '변경 사항이 저장되었습니다.';

  @override
  String get itemEditSavedStalePhotos => '저장됨 — 사진이 최신이 아닐 수 있습니다';

  @override
  String get itemEditRemovePieceHint => '아이템 페이지에서 이 조각을 삭제합니다.';

  @override
  String get itemEditNoPhotos => '사진이 없습니다. 갤러리나 카메라에서 추가하세요.';

  @override
  String get itemEditKeepPhoto => '사진 유지';

  @override
  String get itemEditRemoved => '삭제됨';

  @override
  String get itemEditAddUseCaseAction => '추가';

  @override
  String get statsNoStatsTitle => '통계 없음';

  @override
  String get statsNoStatsBody => '아이템을 추가하면 옷장 구성이 여기에 표시됩니다.';

  @override
  String get statsByCategory => '카테고리별';

  @override
  String get statsTotalValue => '총 가치';

  @override
  String get statsMostWorn => '가장 많이 입음';

  @override
  String get statsLeastWorn => '입을 차례를 기다리는 중';

  @override
  String get statsUnnamedPiece => '이름 없는 아이템';

  @override
  String get jobsTitle => '스캔';

  @override
  String get jobsEmptyTitle => '스캔 기록 없음';

  @override
  String get jobsEmptyBody => '아이템을 촬영하고 백그라운드로 보내세요. 여기서 계속 작업이 진행됩니다.';

  @override
  String get jobsNotCancelled => '취소되지 않음';

  @override
  String get jobsResume => '재개';

  @override
  String get jobsReview => '검토';

  @override
  String get jobsStop => '중단';

  @override
  String get jobsDismiss => '닫기';

  @override
  String get reportTitle => '콘텐츠 신고';

  @override
  String reportIntro(String contentType) {
    return '이 $contentType의 문제점을 알려주세요. 저희 팀이 모든 신고를 검토합니다.';
  }

  @override
  String get reportReasonInappropriate => '부적절하거나 불쾌함';

  @override
  String get reportReasonNudity => '나체 또는 성적 콘텐츠';

  @override
  String get reportReasonHarassment => '괴롭힘 또는 욕설';

  @override
  String get reportReasonImpersonation => '사칭';

  @override
  String get reportReasonOther => '기타';

  @override
  String get reportDetailsLabel => '추가 상세 정보 (선택 사항)';

  @override
  String get reportSubmit => '신고 제출';

  @override
  String get reportSubmittedTitle => '신고 완료';

  @override
  String get reportSubmittedBody => '감사합니다. 저희 팀이 해당 콘텐츠를 검토하겠습니다.';

  @override
  String get reportFailedTitle => '신고 전송 실패';

  @override
  String get reportFailedBody => '다시 시도해 주세요.';

  @override
  String get reportContentTryOnImage => 'AI 착용 이미지';

  @override
  String get reportContentSharedOutfit => '공유된 코디';

  @override
  String get reportContentPhotoshootImage => 'AI 화보 이미지';

  @override
  String get sharedOutfitTitle => '공유된 코디';

  @override
  String get sharedOutfitHideTooltip => '이 코디 숨기기';

  @override
  String get sharedOutfitReportTooltip => '이 코디 신고하기';

  @override
  String get sharedOutfitHideTitle => '이 코디를 숨길까요?';

  @override
  String get sharedOutfitHideBody =>
      '이 기기에서 숨겨집니다. 부적절한 경우 신고해 주시면 검토 후 삭제하겠습니다.';

  @override
  String get sharedOutfitHideAction => '숨기기';

  @override
  String get sharedOutfitHiddenInfo => '이 기기에서 더 이상 표시되지 않습니다.';

  @override
  String get sharedOutfitHiddenToast => '코디가 숨겨졌습니다';

  @override
  String get sharedOutfitMissingTitle => '존재하지 않는 코디입니다';

  @override
  String get sharedOutfitMissingBody => '삭제되었거나 잘못된 링크일 수 있습니다.';

  @override
  String get sharedOutfitHiddenStateTitle => '숨긴 코디입니다';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return '부적절한 경우 개인정보 및 약관에서 신고하거나 $email로 문의해 주세요.';
  }

  @override
  String get sharedOutfitCtaTitle => '이 스타일이 마음에 드시나요?';

  @override
  String get sharedOutfitCtaBody => '내 옷장으로 비슷한 코디를 만들어 보세요.';

  @override
  String get sharedOutfitCtaButton => 'FitCheck AI 시작하기';

  @override
  String get errorTitle => '오류';

  @override
  String get errorUnknown => '예기치 않은 오류가 발생했습니다';

  @override
  String get errorNoConnection => '인터넷 연결이 없습니다. 네트워크를 확인해 주세요.';

  @override
  String get errorTimeout => '요청 시간이 초과되었습니다. 다시 시도해 주세요.';

  @override
  String get errorServerError => '서버 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorBadGateway => '서버가 일시적으로 사용 불가합니다. 다시 시도해 주세요.';

  @override
  String get errorServiceUnavailable => '서비스가 일시적으로 사용 불가합니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get errorInternalError => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorUnauthorized => '계속하려면 로그인해 주세요.';

  @override
  String get errorForbidden => '접근 권한이 없습니다.';

  @override
  String get errorSessionExpired => '세션이 만료되었습니다. 다시 로그인해 주세요.';

  @override
  String get errorInvalidCredentials => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get errorTokenRefreshFailed => '세션을 갱신할 수 없습니다. 다시 로그인해 주세요.';

  @override
  String get errorRequestCancelled => '요청이 취소되었습니다.';

  @override
  String get errorInvalidFormat => '해당 파일 형식은 지원하지 않습니다.';

  @override
  String get errorFileTooLarge => '파일이 너무 큽니다.';

  @override
  String get errorUploadFailed => '업로드에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get errorCacheCorrupted => '저장된 데이터가 손상되어 초기화되었습니다.';

  @override
  String get errorCacheNotFound => '아직 저장된 데이터가 없습니다.';

  @override
  String get errorUserNotFound => '해당 계정을 찾을 수 없습니다.';

  @override
  String get errorItemNotFound => '해당 아이템이 더 이상 존재하지 않습니다.';

  @override
  String get errorOutfitNotFound => '해당 코디가 더 이상 존재하지 않습니다.';

  @override
  String get rewardsTitle => '보상';

  @override
  String get rewardsNoAchievementsTitle => '아직 성취가 없습니다';

  @override
  String get rewardsNoAchievementsBody => '아이템을 추가하고 코디를 계획하여 첫 번째 보상을 받으세요.';

  @override
  String get rewardsEmptyLeaderboardTitle => '아직 랭킹에 아무도 없습니다';

  @override
  String get rewardsEmptyLeaderboardBody => '코디를 계획하여 포인트를 얻고 랭킹에 도전하세요.';

  @override
  String get legalViewPrivacyPolicy => '개인정보 처리방침 보기';

  @override
  String get aiConsentAgree => '동의하고 계속하기';

  @override
  String get aiConsentNotNow => '다음에 하기';

  @override
  String get imageViewerCloseTooltip => '이미지 뷰어 닫기';

  @override
  String get updateReadyTitle => '업데이트 준비됨';

  @override
  String get updateReadyBody => '최신 개선 사항을 적용하려면 FitCheck AI를 재시작하세요.';

  @override
  String get permissionCameraUsage => '오울프와 의류 아이템 사진을 촬영하려면 카메라 권한이 필요합니다.';

  @override
  String get permissionPhotoLibraryUsage =>
      '오울프와 의류 아이템 이미지를 선택하려면 사진 자료 권한이 필요합니다.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'AI가 생성한 오울프 사진을 사진 자료에 저장하려면 권한이 필요합니다.';

  @override
  String get wardrobeSomePhotosSkipped => '일부 사진 건너뜀';

  @override
  String get wardrobePhotosNotAdded => '사진이 추가되지 않음';

  @override
  String get wardrobePhotoNotAdded => '사진이 추가되지 않음';

  @override
  String get wardrobeNotStartedTitle => '시작 안 함';

  @override
  String get wardrobeNoRoomTitle => '공간 부족';

  @override
  String get wardrobeAddPhotosSemantic => '사진 추가';

  @override
  String get batchAddTileLabel => '추가';

  @override
  String get batchProfileLinkLabel => '프로필 링크';

  @override
  String get wardrobeImportFromProfileTitle => '프로필에서 가져오기';

  @override
  String get wardrobeAddSeveralPhotosTitle => '여러 사진 추가';

  @override
  String get wardrobeClearAction => '지우기';

  @override
  String get wardrobeRefreshTooltip => '새로고침';

  @override
  String get batchNoPhotosYetTitle => '아직 사진 없음';

  @override
  String get batchChoosePhotosAction => '사진 선택';

  @override
  String get batchWeFindEachPieceBody => '각 아이템을 찾아 스튜디오 사진으로 만듭니다.';

  @override
  String get batchPreparingPhotosSemantic => '사진 준비 중';

  @override
  String get batchPhotosProcessedSemantic => '사진 처리됨';

  @override
  String get batchPasteProfileLinkTitle => '프로필 링크 붙여넣기';

  @override
  String get batchPasteProfileLinkBody =>
      '공개 인스타그램 또는 페이스북 프로필입니다. 사진을 스캔한 후 붙이고 싶은 오울프를 선택하세요.';

  @override
  String get batchClearLinkTooltip => '링크 지우기';

  @override
  String get batchStartingButton => '시작 중';

  @override
  String get batchStartImportAction => '가져오기 시작';

  @override
  String get batchReviewEveryPhotoTitle => '모든 사진 검토';

  @override
  String get batchReviewEveryPhotoBody => '승인하기 전까지는 추가되지 않습니다.';

  @override
  String get batchPrivateProfilesTitle => '비공개 프로필';

  @override
  String get batchPrivateProfilesBody =>
      '계정을 연결하세요. 인스타그램은 사용자 이름과 비밀번호도 요구합니다.';

  @override
  String get batchUseAnotherLinkAction => '다른 링크 사용';

  @override
  String get batchSignInNeededTitle => '로그인 필요';

  @override
  String get batchEnterYourCodeTitle => '코드 입력';

  @override
  String get batchUseUsernamePasswordAction => '사용자 이름과 비밀번호 사용';

  @override
  String get batchAlreadyConnectedAction => '브라우저에서 연결 완료';

  @override
  String get batchEnterCodeAction => '코드 입력';

  @override
  String get batchTryAnotherWayAction => '다른 방법 시도';

  @override
  String get batchLiveStatus => '활성';

  @override
  String get batchReconnectingStatus => '재연결 중';

  @override
  String get batchSignInToInstagramTitle => '인스타그램 로그인';

  @override
  String get batchUsernameLabel => '사용자 이름';

  @override
  String get batchCodeIfTwoStepLabel => '2단계 로그인 사용 시 코드';

  @override
  String get batchAuthenticatorCodeBody => '인증 앱의 6자리 코드를 사용하세요. 코드는 자주 변경됩니다.';

  @override
  String get batchVerifyAction => '확인';

  @override
  String get batchFindingPhotosTitle => '사진 검색 중';

  @override
  String get batchImportPausedTitle => '가져오기 일시중';

  @override
  String get batchProcessingPhotosTitle => '사진 처리 중';

  @override
  String get batchWaitingNextPhoto => '다음 사진 대기 중';

  @override
  String get batchCancelImportAction => '가져오기 취소';

  @override
  String get batchNoPiecesInPhotoBody => '이 사진에서 의류를 찾지 못했습니다.';

  @override
  String get batchEditPieceColoursLabel => '색상, 쉼표로 구분';

  @override
  String get batchAddToClosetAction => '옷장 추가';

  @override
  String get batchSkipPhotoAction => '이 사진 건너뛰기';

  @override
  String get batchImportCompleteTitle => '가져오기 완료';

  @override
  String get batchImportFailedTitle => '가져오기 실패';

  @override
  String get batchImportCancelledTitle => '가져오기 취소됨';

  @override
  String get batchImportErrorBody => '가져오는 동안 문제가 발생했습니다.';

  @override
  String get batchNothingMoreImportedBody => '이 프로필에서 더 이상 가져오지 않습니다.';

  @override
  String get batchViewClosetAction => '클로젯 보기';

  @override
  String get batchStartOverAction => '처음부터';

  @override
  String get wardrobeAddPieceTitle => '의류 추가';

  @override
  String get wardrobeAddDetailsTitle => '상세 정보 추가';

  @override
  String get wardrobeScanningTitle => '스캔 중';

  @override
  String get batchReviewPiecesTitle => '의류 확인';

  @override
  String get wardrobeGalleryAction => '갤러리';

  @override
  String get wardrobeCameraAction => '카메라';

  @override
  String get wardrobeNewBadge => '새로운';

  @override
  String get wardrobeRemovePhotoTooltip => '사진 삭제';

  @override
  String get batchRunInBackgroundTooltip => '백그라운드 실행';

  @override
  String get batchStepOneOfTwo => '1단계/2단계';

  @override
  String get batchStepTwoOfTwo => '2단계/2단계';

  @override
  String get batchUploadingPhotosTitle => '사진 업로드 중';

  @override
  String get batchFindingPiecesTitle => '의류 찾는 중';

  @override
  String get batchMakingStudioPhotosTitle => '스튜디오 사진 생성 중';

  @override
  String get batchStoppedLabel => '정지됨';

  @override
  String get batchFindingPiecesStoppedTitle => '의류 검색 정지됨';

  @override
  String get batchCancelledLabel => '취소됨';

  @override
  String get batchAllDoneTitle => '모두 완료';

  @override
  String get batchOpeningPiecesBody => '당신의 의류를 열어봅니다.';

  @override
  String get batchNothingSavedBody => '저장된 항목이 없습니다.';

  @override
  String get batchFindingPiecesFailedBody => '의류 검색에 실패했습니다.';

  @override
  String get batchFindingPiecesStoppedEarlyBody => '의류 검색이 중간에 중단되었습니다.';

  @override
  String get batchStopFindingPiecesTitle => '의류 검색을 중단할까요?';

  @override
  String get batchStopFindingPiecesBody =>
      '스캔이 중단되고 아무것도 저장되지 않습니다. 이미 찾은 의류는 닫을 때까지 활동에 유지됩니다.';

  @override
  String get batchKeepGoingAction => '계속하기';

  @override
  String get batchTryAgainAction => '다시 시도';

  @override
  String get batchBackToPhotosAction => '사진으로 돌아가기';

  @override
  String get batchSkipAllAction => '모두 건너뛰기';

  @override
  String get batchIncludeAllAction => '모두 포함';

  @override
  String get batchNoPiecesFoundTitle => '찾은 아이템 없음';

  @override
  String get batchNoPiecesFoundBody => '해당 사진에서 옷이 발견되지 않았습니다.';

  @override
  String get batchChooseOtherPhotosAction => '다른 사진 선택';

  @override
  String get batchUseCaseHelper => '저장한 모든 아이템에 추가됩니다.';

  @override
  String get batchDiscardPiecesTitle => '이 아이템을 폐기할까요?';

  @override
  String get batchDiscardPiecesBody => '이 배치의 항목이 저장되지 않습니다.';

  @override
  String get batchKeepAction => '보관';

  @override
  String get batchDiscardAction => '폐기';

  @override
  String get batchRemovePieceTitle => '이 아이템을 제거할까요?';

  @override
  String get batchRemovePieceBody => '클로set에 저장되지 않습니다.';

  @override
  String get batchRemoveAction => '제거';

  @override
  String get batchChoosePiecesToSave => '저장할 아이템 선택';

  @override
  String get batchDiscardAllAction => '모두 폐기';

  @override
  String get batchNothingSavedRetryBody => '저장된 항목이 없습니다. 다시 시도해 주세요.';

  @override
  String get batchNotSavedTitle => '저장 안 됨';

  @override
  String get batchSavingLabel => '저장 중';

  @override
  String get batchSendToBackgroundAction => '배경으로 이동';

  @override
  String get batchStillWorkingMessage => '작업 중입니다. 아이템이 준비되면 알려드리겠습니다.';

  @override
  String get batchRunningInBackgroundTitle => '백그라운드로 실행 중';

  @override
  String get batchStudioPhotosStoppedBody =>
      '스튜디오 촬영이 중단되었습니다. 이 아이템을 저장할 수 있습니다.';

  @override
  String get batchTapPieceToSkip => '아이템을 탭하여 건너뜁니다.';

  @override
  String get batchStudioPhotosOnWayBody =>
      '스튜디오 촬영을 진행 중입니다. 떠날 수 있으며, 준비되면 알려드리겠습니다.';

  @override
  String get batchLeaveAction => '나가기';

  @override
  String get batchPeopleInPhotosTitle => '사진 속 인물';

  @override
  String get batchIncludeAction => '포함';

  @override
  String get batchSkipAction => '건너뛰기';

  @override
  String get batchYourPhotoIsUsedLabel => '사용된 사진';

  @override
  String get batchMakingStudioPhotoLabel => '스튜디오 촬영 중';

  @override
  String get batchNoStudioPhotoBody => '스튜디오 촬영 없음. 원본 사진 사용';

  @override
  String get batchEnterDetailsYourselfAction => '직접 입력하기';

  @override
  String get batchChooseAnotherPhotoAction => '다른 사진 선택';

  @override
  String get batchConnectionLostTitle => '연결 끊김';

  @override
  String get batchConnectionLostBody => '연결 상태를 확인한 후 다시 시도하세요.';

  @override
  String get batchDailyLimitTitle => '하한 도달';

  @override
  String get batchDailyLimitBodyPaywall =>
      '더 많은 스캔을 위해 Pro로 업그레이드하거나, 직접 입력하세요.';

  @override
  String get batchDailyLimitBodyFree => '내일 스캔 횟수가 초기화됩니다. 지금 직접 입력할 수 있습니다.';

  @override
  String get batchSeePlansAction => '플랜 보기';

  @override
  String get batchAiBusyTitle => 'AI가 비빕니다';

  @override
  String get batchAiBusyBody => '시스템 측 문제입니다. 몇 분 후 다시 시도하세요.';

  @override
  String get batchNoPiecesBody => '더 선명한 사진이나 직접 입력을 시도하세요.';

  @override
  String get batchScanningUnavailableTitle => '스캔 불가';

  @override
  String get batchScanningUnavailableBody => '지금은 직접 입력해 주세요.';

  @override
  String get batchScanDidNotFinishTitle => '스캔 미완료';

  @override
  String get batchTryAgainBody => '다시 시도';

  @override
  String get billingTitle => '구독';

  @override
  String get billingUpgradeHeading => '플랜 업그레이드';

  @override
  String get billingUpgradeOnPlusBody => '기능은 동일하고 한도가 더 높습니다.';

  @override
  String get billingUpgradeBody => 'Plus와 Pro는 기능이 동일합니다. 필요한 한도를 선택하세요.';

  @override
  String get billingWebUnavailableBody =>
      '온라인 업그레이드는 아직 제공되지 않습니다. 프로모션이나 추천 코드로 Plus 또는 Pro를 활성화할 수 있습니다. 아래에서 친구를 초대하여 무료 월간 이용권을 받으세요.';

  @override
  String get billingPlansStale => '최신 플랜을 불러오지 못했습니다. 가격이 정지일 수 있습니다.';

  @override
  String get billingMonthly => '월간';

  @override
  String get billingYearly => '연간';

  @override
  String get billingCurrentPlan => '현재 플랜';

  @override
  String get billingActive => '활성';

  @override
  String get billingThisMonth => '이번 달';

  @override
  String get billingItemExtractions => '상품 추출';

  @override
  String get billingOutfitVisualizations => '코디 시각화';

  @override
  String get billingNearLimitUpgrade =>
      '이번 달 한도에 근접했습니다. 더 많은 혜택을 위해 업그레이드하세요.';

  @override
  String get billingNearLimitResets => '이번 달 한도에 근접했습니다. 다음 달 초에 초기화됩니다.';

  @override
  String get billingStoreUnavailable => '업그레이드가 아직 스토어에 없습니다. 잠시 후 다시 확인해 주세요.';

  @override
  String get billingManageHeading => '플랜 관리';

  @override
  String get billingCancelPlan => '구독 취소';

  @override
  String get billingCancelKeepsAccess => '해지하는 시점까지 이용 가능합니다.';

  @override
  String get billingCancelConfirmTitle => '구독을 취소하시겠습니까?';

  @override
  String get billingKeepPlan => '플랜 유지';

  @override
  String get billingCancelPlanAction => '플랜 취소';

  @override
  String get billingBilledMonthly => '월별 결제';

  @override
  String get billingBilledYearly => '연별 결제';

  @override
  String get billingVirtualTryOn => '가상 착용';

  @override
  String get billingPrioritySupport => '우선 지원';

  @override
  String get billingDisclosureProRenewing => 'Pro는 자동 갱신되는 구독입니다';

  @override
  String get billingDisclosureBothRenewing => 'Plus와 Pro는 자동 갱신되는 구독입니다';

  @override
  String get billingDisclosureAppleBilling => '결제는 Apple ID에 구매 확인 시 청구됩니다.';

  @override
  String get billingDisclosureGoogleBilling =>
      '결제는 Google Play 계정에 구매 확인 시 청구됩니다.';

  @override
  String get billingDisclosureRenewalTerms =>
      '자동 갱신을 설정하면 동일한 기간과 가격으로 갱신됩니다. 현행 기간 종료 24시간 전에 자동 갱신을 해제해야 합니다.';

  @override
  String get billingDisclosureAppleManage =>
      '설정 > Apple ID > 구독에서 언제든지 관리하거나 취소할 수 있습니다.';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play > 결제 및 구독에서 언제든지 관리하거나 취소할 수 있습니다.';

  @override
  String get billingReferFriend => '친구 추천';

  @override
  String get billingHowItWorks => '이용 방법';

  @override
  String get billingHowShareTitle => '링크 공유';

  @override
  String get billingHowShareBody => '친구에게 보내세요.';

  @override
  String get billingHowSignUpTitle => '가입하기';

  @override
  String get billingHowSignUpBody => '친구가 링크로 가입합니다.';

  @override
  String get billingHowBothTitle => '모두 Pro 혜택';

  @override
  String get billingHowBothBody => '서로 한 달 동안 Pro를 무료로 이용할 수 있습니다.';

  @override
  String get billingYourReferrals => '내 추천 기록';

  @override
  String get billingInvited => '초대됨';

  @override
  String get billingJoined => '가입됨';

  @override
  String get billingMonthsEarned => '수령한 월 수';

  @override
  String get billingInviteFriend => '친구 초대';

  @override
  String get billingInviteBody => '당신과 친구 모두 1개월 Pro를 받으세요.';

  @override
  String get billingYourCode => '내 코드';

  @override
  String get billingCopyLink => '링크 복사';

  @override
  String get billingShareInvite => '초대하기';

  @override
  String get giftUnavailable => '이 빌드에서는 선물 초대가 제공되지 않습니다.';

  @override
  String get giftPageTitle => 'FitCheck Pro 선물하기';

  @override
  String get giftNoAllowances => '현재 무료 선물 초대가 없습니다.';

  @override
  String get giftFormTitle => '무료 초대장 보내기';

  @override
  String get giftFormBody => '수신자가 이 인증된 이메일로 선물을 활성화합니다. 이메일은 대신 보내지 않습니다.';

  @override
  String get giftFieldFrom => '보내는 사람';

  @override
  String get giftFieldRecipientName => '수신자 이름';

  @override
  String get giftFieldRecipientEmail => '수신자 이메일';

  @override
  String get giftFieldOccasion => '용도(선택)';

  @override
  String get giftNoOccasion => '용도 없음';

  @override
  String get giftOccasionBirthday => '생일';

  @override
  String get giftOccasionAnniversary => '기념일';

  @override
  String get giftOccasionOther => '기타';

  @override
  String get giftFieldCardGreeting => '카드 인사말';

  @override
  String get giftFieldCardGreetingHelper => '이 내용이 카드에 그대로 표시됩니다.';

  @override
  String get giftFieldPrivateNote => '비공개 메모(선택)';

  @override
  String get giftCreateAction => '무료 선물 만들기';

  @override
  String get giftClaimedTitle => '선물 수락 완료';

  @override
  String get giftClaimedActive => 'FitCheck Pro 선물이 활성화되었습니다.';

  @override
  String get giftClaimedQueued => 'FitCheck Pro 선물은 현재 사용 기간이 끝나면 시작됩니다.';

  @override
  String get giftLinkCopied => '선물 링크가 클립보드에 복사되었습니다.';

  @override
  String get giftErrorName => '이름을 입력하세요.';

  @override
  String get giftErrorEmail => '올바른 이메일 주소를 입력하세요.';

  @override
  String get giftErrorGreeting => '카드 인사말을 입력하세요.';

  @override
  String get giftErrorGreetingLength => '80자 이하로 입력하세요.';

  @override
  String get giftClaimAction => '선물 받기';

  @override
  String get giftCardPreview => '카드 미리보기';

  @override
  String get giftGiftForYou => '당신의 선물';

  @override
  String get giftGiftWaiting => '선물이 기다리고 있어요';

  @override
  String get giftOpenBody => '검증된 이메일로 선물을 열어 적용하세요.';

  @override
  String get giftOpenGifts => '선물 열기';

  @override
  String get giftSendInvitation => '초대하기';

  @override
  String get settingsAiProviderSection => '제공자';

  @override
  String get settingsAiCustom => '직접 지정';

  @override
  String get settingsAiUrlHelper =>
      '서버에서 접근할 수 있는 공용 URL을 사용하세요. 로컬호스트는 서버에서 작동하지 않습니다.';

  @override
  String get settingsAiConnectionSection => '연결';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API 키';

  @override
  String get settingsAiApiKeySaved => '저장됨. 변경하지 않으려면 비워 두세요.';

  @override
  String get settingsAiChatModel => '채팅 모델';

  @override
  String get settingsAiVisionModel => '비전 모델 (선택)';

  @override
  String get settingsAiImageModel => '이미지 모델 (선택)';

  @override
  String get settingsAiImageModelNote =>
      '이미지 생성에는 response_modalities가 있는 OpenAI 호환 채팅补완성이 필요합니다.';

  @override
  String get settingsAiTestConnection => '연결 테스트';

  @override
  String get calendarTitle => '캘린더';

  @override
  String get calendarGoToToday => '오늘로';

  @override
  String get calendarConnectTooltip => '캘린더 연결';

  @override
  String get calendarAddEvent => '이벤트 추가';

  @override
  String get calendarEmptyTitle => '예약된 일정 없음';

  @override
  String get calendarEmptyBody => '이벤트를 추가하고 입을 옷을 계획하세요.';

  @override
  String get calendarPreviousMonth => '이전 달';

  @override
  String get calendarNextMonth => '다음 달';

  @override
  String get calendarAllDay => '하루 종일';

  @override
  String get calendarOutfitLinked => '코디 연결됨';

  @override
  String get calendarEventOptions => '이벤트 옵션';

  @override
  String get calendarDeleteTitle => '이 이벤트를 삭제할까요?';

  @override
  String get calendarChangeOutfit => '좌변지 변경';

  @override
  String get calendarLinkOutfit => '좌변지 연결';

  @override
  String get calendarRemoveOutfit => '좌변지 제거';

  @override
  String get calendarNewEvent => '새 이벤트';

  @override
  String get calendarEditEvent => '이벤트 수정';

  @override
  String get calendarTitleLabel => '제목';

  @override
  String get calendarTitleRequired => '제목 입력';

  @override
  String get calendarEndBeforeStart => '종료 시간을 시작 시간 이후로 설정하세요';

  @override
  String get calendarStarts => '시작';

  @override
  String get calendarEnds => '종료';

  @override
  String get calendarPlaceOptional => '장소 (선택)';

  @override
  String get calendarNotesOptional => '메모 (선택)';

  @override
  String get calendarLinkOutfitEmptyBody => '좌변지를 구성한 후 이 이벤트에 연결하세요.';

  @override
  String get calendarBuildOutfit => '좌변지 구성';

  @override
  String get calendarConnectionsTitle => '캘린더';

  @override
  String get calendarConnectionsBody => '여기에 추가한 이벤트는 FitCheck에 남아 있습니다.';

  @override
  String get calendarDisconnect => '연결 해제';

  @override
  String get calendarNotAvailable => '아직 사용할 수 없음';

  @override
  String get profileSectionExplore => '더보기';

  @override
  String get profileNavTryOn => '착용';

  @override
  String get profileNavRewards => '리워드';

  @override
  String get profileSupport => '지원';

  @override
  String get profileHelp => '도움말';

  @override
  String get profileAbout => '정보';

  @override
  String get profileAboutBody => '옷장, 좌변지, 계획 정보를 한 곳에서 관리하세요.';

  @override
  String get profileSignOutTitle => '로그아웃할까요?';

  @override
  String get profileSignOutBody => '언제든지 다시 로그인할 수 있습니다.';

  @override
  String get profileEditTitle => '프로필 수정';

  @override
  String get profileYourProfile => '내 프로필';

  @override
  String get profileBodyProfiles => '체형 프로필';

  @override
  String get profileBodyEmptyTitle => '체형 프로필이 없습니다';

  @override
  String get profileBodyEmptyBody => '키와 체형을 추가하여 더 잘 맞는 옷을 확인하세요.';

  @override
  String get profileBodyAdd => '프로필 추가';

  @override
  String get profileBodyDefaultNote => '기본 프로필이 핏 및 가상 착용에 사용됩니다.';

  @override
  String get profileBodyDefaultBadge => '기본';

  @override
  String get profileBodyMakeDefault => '기본으로 설정';

  @override
  String get profileBodyDeleteBody => '이 작업은 되돌릴 수 없습니다.';

  @override
  String get profileBodyRequired => '필수';

  @override
  String get profileBodyCheckNumber => '번호 확인';

  @override
  String get profileBodyNew => '새 체형 프로필';

  @override
  String get profileBodyNameHint => '예: 나';

  @override
  String get profileBodyHeight => '키';

  @override
  String get profileBodyWeight => '체중';

  @override
  String get profileBodyBuild => '체형';

  @override
  String get profileBodySkinTone => '피부색';

  @override
  String get profileBirthDateNeededBody => '태어난 시간을 함께 사용하려면 생일을 추가하세요.';

  @override
  String get profileBirthDateNeededTitle => '생일 추가 필요';

  @override
  String get profilePartlySavedBody =>
      '이름과 사진은 저장되었지만, 태어난 시간 정보는 저장되지 않았습니다. 나중에 다시 시도해 보세요.';

  @override
  String get profilePartlySavedTitle => '일부 저장됨';

  @override
  String get profileSavedBody => '프로필이 저장되었습니다.';

  @override
  String get profileChangePhoto => '프로필 사진 변경';

  @override
  String get profilePhotoLabel => '프로필 사진';

  @override
  String get profilePhotoHint => '새 사진을 선택하려면 탭하세요';

  @override
  String get profileBirthDateLabel => '생일 (선택)';

  @override
  String get profileBirthTimeLabel => '태어난 시간 (선택)';

  @override
  String get profileBirthTimeHelper => '베딥 추천 정확도를 높여줍니다';

  @override
  String get profileBirthPlaceLabel => '태어난 곳 (선택)';

  @override
  String get profileBirthPlaceHint => '예: 인디아, 뉴델리';

  @override
  String get profileHelpContactTitle => '궁금한 점은 무엇이든 질문하세요';

  @override
  String get profileHelpContactBody => '메시지를 보내주시면 보통 하루 이내에 이메일로 답변 드립니다.';

  @override
  String get profileHelpContactAction => '고객센터 상담';

  @override
  String get profileHelpFaqTitle => '자주 묻는 질문';

  @override
  String get profileFaqAddPiecesTitle => '옷장에 아이템을 추가하는 방법은?';

  @override
  String get profileFaqAddPiecesBody =>
      '옷장 탭에서 아이템 추가를 누르세요. 사진을 찍거나 갤러리에서 선택하면 아이템을 자동으로 인식하고 태그해 드립니다.';

  @override
  String get profileFaqMatchingTitle => '코디 매칭은 어떻게 되나요?';

  @override
  String get profileFaqMatchingBody =>
      '나에게 추천 탭을 열고 소유 중인 아이템을 선택하세요. 어울리는 아이템을 제안하고 옷장을 기반으로 전체 코디를 완성해 드립니다.';

  @override
  String get profileFaqTryOnTitle => '개인 사진으로 가상 입기를 사용할 수 있나요?';

  @override
  String get profileFaqTryOnBody =>
      '네. 본인 전신 사진을 추가한 후 원하는 아이템을 선택하면 착용한 모습을 확인할 수 있습니다.';

  @override
  String get profileFaqRewardsTitle => '리워드는 어떻게 획득하나요?';

  @override
  String get profileFaqRewardsBody =>
      '코디를 계획하고 자주 기록하세요. 매일 이어진 기록과 성취도가 쌓입니다.';

  @override
  String get profileFaqPrivacyTitle => '옷장은 비공개인가요?';

  @override
  String get profileFaqPrivacyBody =>
      '네. 특정 코디 링크를 공유하는 경우를 제외하고 옷장과 코디는 비공개입니다.';

  @override
  String get profileHelpMoreTitle => '추가 도움말';

  @override
  String get profileHelpGuides => '이용 가이드';

  @override
  String get profileHelpGuidesBody => '각 기능의 사용법';

  @override
  String get feedbackCategoryBug => '버그 발생';

  @override
  String get feedbackCategoryIdea => '개선 아이디어';

  @override
  String get feedbackCategoryGeneral => '일반';

  @override
  String get feedbackCategoryHelp => '도움이 필요해요';

  @override
  String get feedbackHintBug =>
      '어떤 문제가 발생했는지, 그리고 예상했던 동작이 무엇인지 알려주세요. 조치 단계를 함께 알려주시면 수정에 도움이 됩니다.';

  @override
  String get feedbackHintIdea => '원하는 기능이나 개선 사항과 그 이유를 알려주세요.';

  @override
  String get feedbackHintGeneral => '소중한 의견이나 궁금한 사항을 알려주세요.';

  @override
  String get feedbackAttachmentLimitBody => '이미지를 최대 5장까지 추가할 수 있습니다.';

  @override
  String get feedbackAttachmentLimitTitle => '허용 한도 초과';

  @override
  String get feedbackImageTooLargeBody => '5MB 이하의 이미지를 선택해 주세요.';

  @override
  String get feedbackImageTooLargeTitle => '이미지가 너무 큽니다';

  @override
  String get feedbackTitle => '피드백 보내기';

  @override
  String get feedbackAboutLabel => '어떤 건에 대한 건가요?';

  @override
  String get feedbackSubjectLabel => '제목';

  @override
  String get feedbackSubjectRequired => '제목 추가';

  @override
  String get feedbackSubjectTooShort => '제목은 3자 이상이어야 합니다';

  @override
  String get feedbackDetailsLabel => '상세 내용';

  @override
  String get feedbackDetailsRequired => '상세 내용 추가';

  @override
  String get feedbackDetailsTooShort => '설명은 10자 이상이어야 합니다';

  @override
  String get feedbackAddScreenshot => '스크린샷 추가';

  @override
  String get feedbackAttachmentHint => '최대 5개, 파일당 5MB';

  @override
  String get feedbackSend => '보내기';

  @override
  String get feedbackEmptyTitle => '보낸 항목 없음';

  @override
  String get feedbackEmptyBody => '보낸 항목과 상태가 여기에 표시됩니다.';

  @override
  String get feedbackHistoryTitle => '보낸 내역';

  @override
  String get feedbackStatusOpen => '열려 있음';

  @override
  String get feedbackStatusInProgress => '진행 중';

  @override
  String get feedbackStatusResolved => '해결됨';

  @override
  String get feedbackStatusClosed => '닫힘';

  @override
  String get legalIntro => '데이터 보호 방법 및 FitCheck AI 사용 약관';

  @override
  String get legalPolicies => '정책';

  @override
  String get legalPrivacySubtitle => '수집 내용 및 목적';

  @override
  String get legalTermsTitle => '이용약관';

  @override
  String get legalTermsSubtitle => '앱 사용 규칙';

  @override
  String get legalLicences => '오픈소스 라이선스';

  @override
  String get legalSupportSubtitle => '도움말, 문의 및 개인정보 요청';

  @override
  String get legalReportAbuse => '문제 또는 남용 신고';

  @override
  String get permissionCameraTitle => '카메라 접근';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI는 의류와 코디 사진을 촬영하여 AI 가상 착용 및 옷장 관리를 위해 카메라를 사용합니다.';

  @override
  String get permissionPhotoTitle => '사진 접근';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI는 AI 기능과 옷장을 위해 의류 및 코디 이미지를 선택할 수 있도록 사진에 대한 접근 권한이 필요합니다.';

  @override
  String get permissionNotNow => '아직 안 함';

  @override
  String get permissionOpenSettings => '설정 열기';

  @override
  String authSignedInAs(String name) {
    return '$name(으)로 로그인됨';
  }

  @override
  String get authSignedIn => '로그인됨';

  @override
  String get authWelcomeBackTitle => '다시 오신 것을 환영합니다';

  @override
  String get authSignInFailed => '로그인 실패';

  @override
  String get authWelcomeTitle => '환영합니다';

  @override
  String get authSignUpFailed => '회원가입 실패';

  @override
  String get authGoogleSignInFailed => 'Google 로그인 실패';

  @override
  String get authAppleSignInFailed => 'Apple 로그인 실패';

  @override
  String get authConfirmEmailTitle => '이메일 확인';

  @override
  String get authConfirmEmailBody => '확인 메일을 받은 후 로그인하세요.';

  @override
  String get authClosetReady => '클로sets 준비 완료';

  @override
  String get authSignedOutTitle => '로그아웃됨';

  @override
  String get authSignedOutBody => '로그아웃되었습니다.';

  @override
  String get authSignOutFailed => '로그아웃 실패';

  @override
  String get authEmailSentTitle => '메일 전송됨';

  @override
  String get authResetLinkSent => '메일을 확인하여 재설정 링크를 받으세요.';

  @override
  String get authPasswordUpdatedTitle => '비밀번호 변경됨';

  @override
  String get authPasswordUpdated => '비밀번호가 변경되었습니다.';

  @override
  String get authPasswordNotUpdated => '비밀번호가 변경되지 않음';

  @override
  String get authCouldNotSendEmail => '메일을 보낼 수 없음';

  @override
  String get authEmailNotSent => '메일이 전송되지 않음';

  @override
  String get authResendSentBody => '새 확인 메일을 보냈습니다.';

  @override
  String get outfitPreviewWithAi => 'AI 미리보기';

  @override
  String get outfitNewPreview => '새 미리보기 만들기';

  @override
  String get outfitBuilderClosetHeading => '나의 옷장';

  @override
  String get outfitBuilderSearchHint => '의류 검색';

  @override
  String get outfitClearSearch => '검색 지우기';

  @override
  String get outfitBuilderAddPiecesTitle => '의류 먼저 추가';

  @override
  String get outfitBuilderAddPiecesBody => '코디는 옷장의 의류로 만들립니다.';

  @override
  String get outfitBuilderNoMatches => '일하는 의류 없음';

  @override
  String get outfitNameLabel => '코디 이름';

  @override
  String get outfitNameHint => '예: 주말 린';

  @override
  String get outfitPreviewSemantic => '의상 AI 미리보기';

  @override
  String get outfitChoosePieces => '아이템 선택';

  @override
  String get outfitTapPiecesHint => '아래의 아이템을 탭하세요.';

  @override
  String get outfitShareTooltip => '공유';

  @override
  String get outfitSaveFavourite => '좋아요 추가';

  @override
  String get outfitPiecesHeading => '아이템';

  @override
  String get outfitWearHistoryEmpty => '한 번 입고 나면 날짜가 여기 표시됩니다.';

  @override
  String get outfitWearHistoryTitle => '코디링';

  @override
  String get outfitWearHistoryError => '날짜를 불러올 수 없습니다.';

  @override
  String get outfitWornOn => '코디한 날';

  @override
  String get outfitEditTitle => '코디 수정';

  @override
  String get outfitSavedPhotosFailed => '상세정보는 저장되었으나 사진은 저장되지 않았습니다.';

  @override
  String get outfitNoPhotosBody => '아직 사진이 없습니다. 대신 아이템이 표시됩니다.';

  @override
  String get outfitOccasionLabel => '기회';

  @override
  String get outfitOccasionNone => '없음';

  @override
  String get outfitTagsHint => '쉼표로 구분하세요';

  @override
  String get outfitDraftBody => '메인 목록에서 숨겨져 있습니다.';

  @override
  String get outfitPublic => '공개';

  @override
  String get outfitPublicBody => '링크를 가진 모든 사람이 볼 수 있습니다';

  @override
  String get outfitDeleteFromDetail => '이 코디를 상세 페이지에서 삭제합니다.';

  @override
  String get outfitNewCollection => '새 컬렉션';

  @override
  String get outfitNoCollectionsTitle => '아직 컬렉션이 없습니다';

  @override
  String get outfitNoCollectionsBody => '여행, 계절, 무드별로 코디를 묶으세요.';

  @override
  String get outfitCreateCollection => '컬렉션 만들기';

  @override
  String get outfitAddOutfits => '코디 추가';

  @override
  String get outfitRename => '이름 변경';

  @override
  String get outfitCollectionDeleteBody => '안의 코디는 유지됩니다.';

  @override
  String get outfitCollectionsNotLoaded => '코디 불러오지 못함';

  @override
  String get outfitRenameCollection => '컬렉션 이름 변경';

  @override
  String get outfitDescriptionOptional => '설명 (선택)';

  @override
  String get outfitAllInCollection => '모든 코디가 이 컬렉션에 이미 포함되어 있습니다.';

  @override
  String get photoshootSubtitleUpload => '내 사진으로 스튜디오 포레이트 촬영';

  @override
  String get photoshootSubtitleConfigure => '스타일, 포맷, 개수 선택';

  @override
  String get photoshootSubtitleGenerating => '1~2분 정도 소요됩니다';

  @override
  String get photoshootAddPhotosSemantic => '갤러리에서 사진 추가';

  @override
  String get photoshootUploadTitle => '본인 사진 1~4개 추가';

  @override
  String get photoshootUploadBody => '탭하여 갤러리에서 선택';

  @override
  String get photoshootAddToContinue => '사진을 추가하여 계속하기';

  @override
  String get photoshootAddAnotherPhoto => '사진 추가';

  @override
  String get photoshootTipsTitle => '최고의 결과를 위해';

  @override
  String get photoshootTipsBody =>
      '여러 각도의 선명하고 잘 밝힌 얼굴 사진을 사용하세요. 선글라스와 모자는 피하세요.';

  @override
  String get photoshootStarting => '시작 중';

  @override
  String get photoshootCancelling => '취소 중';

  @override
  String get photoshootFailed => '실패';

  @override
  String get recommendTabMatches => '조화';

  @override
  String get recommendTabComplete => '보완';

  @override
  String get recommendTabWeather => '날씨';

  @override
  String get recommendTabColours => '색상';

  @override
  String get recommendTabShop => '쇼핑';

  @override
  String get recommendNoMatchesTitle => '아직 일치하는 항목 없음';

  @override
  String get recommendNoMatchesBody => '아이템을 선택하면 어울리는 제품을 찾아드립니다.';

  @override
  String get recommendPickPiece => '아이템 선택';

  @override
  String get recommendNothingMatchesTitle => '아직 이 항목과 일치하는 제품 없음';

  @override
  String get recommendNothingMatchesBody => '다른 아이템을 선택하거나, 옷장을 더 추가하세요.';

  @override
  String get recommendChangePieces => '아이템 변경';

  @override
  String get recommendDefaultReason => '선택한 아이템과 잘 어울립니다.';

  @override
  String get recommendCompleteTitle => '스타일 완성';

  @override
  String get recommendCompleteBody => '아이템을 선택하면 나머지를 채워드립니다.';

  @override
  String get recommendWorking => '처리 중';

  @override
  String get recommendGenerate => '생성';

  @override
  String get recommendChooseStyleBody => '스타일 선택 후 생성하세요.';

  @override
  String get recommendNoLooksTitle => '이 아이템에 어울리는 코디 없음';

  @override
  String get recommendNoLooksBody => '다른 스타일이나 아이템을 시도해 보세요.';

  @override
  String get recommendDefaultLook => '내 아이템용 코디';

  @override
  String get recommendNoPiecesBody => '이 코디에 사용할 아이템이 없습니다.';

  @override
  String get recommendCityLabel => '도시';

  @override
  String get recommendCheck => '확인';

  @override
  String get recommendWeatherTitle => '오늘 날씨';

  @override
  String get recommendWeatherBody => '도시를 입력하면 오늘 추천 코디를 받아보세요.';

  @override
  String get recommendWearToday => '오늘은 이걸 입으세요';

  @override
  String get recommendWeatherNoPieces => '이 날씨에 입을 아이템이 아직 없습니다.';

  @override
  String get recommendBudgetLabel => '예산까지';

  @override
  String get recommendLooking => '찾는 중';

  @override
  String get recommendFindWhatToBuy => '살 아이템 찾기';

  @override
  String get recommendFillGapsTitle => '비워진 자리 채우기';

  @override
  String get recommendFillGapsBody => '예산을 정하면 필요한 아이템을 추천해 드려요.';

  @override
  String get recommendNoGapsTitle => '추천할 아이템 없음';

  @override
  String get recommendNoGapsBody => '예산을 더 높이거나 다른 카테고리를 선택해 보세요.';

  @override
  String get recommendMoodEveryday => '데일리';

  @override
  String get recommendMoodBigMeeting => '중요한 회의';

  @override
  String get recommendDayLabel => '날짜';

  @override
  String get recommendReadingStars => '별을 읽는 중';

  @override
  String get recommendGetMyColours => '내 색 찾기';

  @override
  String get recommendLuckyColoursTitle => '오늘의 행운의 색';

  @override
  String get recommendLuckyColoursBody => '날짜를 선택하면 어울리는 색과 아이템을 추천해 드려요.';

  @override
  String get recommendLuckyColoursSection => '행운의 색';

  @override
  String get recommendAvoidColoursSection => '지양할 색';

  @override
  String get recommendBirthDateTitle => '생년월일 입력';

  @override
  String get recommendBirthDateBody => '색을 분석하려면 생년월일이 필요합니다.';

  @override
  String get recommendEditProfile => '프로필 수정';

  @override
  String get recommendNothingThisDay => '오늘은 없음';

  @override
  String get recommendUnnamedColour => '이름 없는 색상';

  @override
  String get recommendFromCloset => '내 옷장';

  @override
  String get recommendNoPiecesInColours => '이 색상의 아이템이 없습니다.';

  @override
  String get recommendOutfitIdeas => '코디 아이디어';

  @override
  String get recommendNoOutfitsInColours => '이 색상으로 완성된 코디가 없습니다.';

  @override
  String get recommendDefaultOutfitIdea => '코디 아이디어';

  @override
  String get recommendPickUpToThree => '최대 3개 선택';

  @override
  String get recommendEmptyClosetBody => '아이템을 먼저 추가한 뒤 매칭을 확인하세요.';

  @override
  String get dashboardDressForDay => '오늘의 스타일링';

  @override
  String get dashboardOutfitOfDay => '오늘의 코디';

  @override
  String get dashboardFreshLook => '새로운 룩';

  @override
  String get subscriptionManageInStoreTitle => '스토어에서 관리';

  @override
  String get subscriptionManageInStoreBody =>
      '이 플랜은 스토어에서 결제됩니다. 스토어 계정 설정에서 관리하세요.';

  @override
  String get subscriptionCancelledTitle => '구독 취소됨';

  @override
  String get subscriptionCancelledBody => '플랜은 현재 청구 기간까지 계속 유지됩니다.';

  @override
  String get subscriptionCancelFailedTitle => '취소하지 못했습니다';

  @override
  String get subscriptionCouldNotOpenTitle => '열리지 않았습니다';

  @override
  String get subscriptionOpenBillingFailedBody => '청구 관리를 열지 못했습니다.';

  @override
  String get subscriptionOpenLinkFailedBody => '링크를 열지 못했습니다.';

  @override
  String get subscriptionReferralLoadFailedTitle => '링크를 불러오지 못했습니다';

  @override
  String get subscriptionReferralLoadFailedBody =>
      '추천 링크를 불러오지 못했습니다. 다시 시도해 주세요.';

  @override
  String get subscriptionReferralCopiedTitle => '복사됨';

  @override
  String get subscriptionReferralCopiedBody => '추천 링크가 복사되었습니다.';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI 사용해 보기';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI에 가입하면 우리 둘 다 1개월 Pro를 받습니다. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => '링크 복사됨';

  @override
  String get subscriptionShareUnavailableBody => '공유가 사용할 수 없어 링크를 복사했습니다.';

  @override
  String get subscriptionShareFailedTitle => '공유하지 못했습니다';

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
  String get giftClaimFailedTitle => '기프트 사용 실패';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '기프트 $count개',
      one: '기프트 1개',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1개월',
      '12': '1년',
      'other': '$months개월',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining회 남음',
      one: '1회 남음',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender님이 FitCheck Pro $duration을(를) 선물했습니다. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient님의 FitCheck Pro 기프트';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender님 선물';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient에게';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender에게서';
  }

  @override
  String get giftPreviewPlaceholderRecipient => '받는 분';

  @override
  String get giftPreviewPlaceholderSender => '나';

  @override
  String get settingsSavedTitle => '저장됨';

  @override
  String get settingsNotSavedTitle => '저장되지 않음';

  @override
  String get settingsAiChooseProviderBody => '제공자를 선택하세요.';

  @override
  String get settingsAiCustomUrlRequiredBody => '사용자 지정 제공자는 API URL이 필요합니다.';

  @override
  String get settingsAiKeyRequiredBody => 'API 키를 입력하세요.';

  @override
  String get settingsAiSavedBody => 'AI 설정이 저장되었습니다.';

  @override
  String get settingsAiMissingDetailsTitle => '정보 누락';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      '테스트를 위해 API URL과 채팅 모델을 입력하세요.';

  @override
  String get settingsAiKeyNeededTitle => 'API 키 필요';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      '테스트하려면 API 키를 입력하세요. 저장된 키는 비공개입니다.';

  @override
  String get settingsAiKeyToTestBody => '테스트하려면 API 키를 입력하세요.';

  @override
  String get settingsAiConnectedTitle => '연결됨';

  @override
  String get settingsAiConnectedBody => '연결이 정상적으로 작동합니다.';

  @override
  String get settingsAiTestFailedTitle => '테스트 실패';

  @override
  String get settingsPreferencesSavedBody => '기본 설정이 저장되었습니다.';

  @override
  String get settingsPasswordNotChangedTitle => '비밀번호가 변경되지 않았습니다';

  @override
  String get settingsOAuthPasswordBody =>
      '이 계정은 Google 또는 Apple로 로그인합니다. 비밀번호를 설정하려면 \'비밀번호를 잊으셨나요?\'를 사용하세요.';

  @override
  String get settingsCurrentPasswordIncorrectBody => '현재 비밀번호가 올바르지 않습니다.';

  @override
  String get settingsExportReadyTitle => '내보내기 준비 완료';

  @override
  String get settingsExportReadyBody => '데이터 내보내기를 다운로드할 수 있습니다.';

  @override
  String get settingsLinkCopiedTitle => '링크 복사됨';

  @override
  String get settingsExportClipboardBody =>
      '브라우저를 열지 못하여 다운로드 링크를 복사했습니다. 금방 유효기간이 지나므로 브라우저에 붙여넣으세요.';

  @override
  String get settingsExportFailedTitle => '내보내기 실패';

  @override
  String get settingsAccountNotDeletedTitle => '계정이 삭제되지 않았습니다';

  @override
  String photoshootPhotoLimit(int max) {
    return '$max장까지 추가할 수 있습니다.';
  }

  @override
  String get photoshootPhotoLimitTitle => '사진 한도';

  @override
  String get photoshootAddAtLeastOnePhoto => '사진을 최소 한 장 추가하세요.';

  @override
  String get photoshootNoPhotosSelectedTitle => '사진 없음';

  @override
  String get photoshootDescribeLookBody => '원하는 스타일을 설명하세요.';

  @override
  String get photoshootPromptNeededTitle => '프롬프트 필요';

  @override
  String get photoshootConsentFeatureLabel => 'AI 포토슈트';

  @override
  String get photoshootStatusPreparing => '사진 준비 중';

  @override
  String get photoshootStatusGenerating => '생성 중';

  @override
  String photoshootStatusBatch(int current, int total) {
    return '$total 중 $current 배치';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$total 중 $done 완료';
  }

  @override
  String get photoshootGenerationFailedBody => '생성에 실패했습니다.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready개 준비됨, $failed개 실패했습니다.';
  }

  @override
  String get photoshootPartlyDoneTitle => '일부 완료';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count장이 준비되었습니다.',
      one: '1장이 준비되었습니다.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => '연결이 끊겼습니다. 다시 시도해 주세요.';

  @override
  String get photoshootCouldNotCancelTitle => '취소하지 못했습니다';

  @override
  String get photoshootRetryFailedTitle => '재시도 실패';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return '$number번 사진이 준비되었습니다.';
  }

  @override
  String get photoshootReplacedTitle => '교체됨';

  @override
  String get photoshootSavedToGalleryBody => '갤러리에 저장되었습니다.';

  @override
  String get photoshootSavedTitle => '저장됨';

  @override
  String get photoshootNotSavedTitle => '저장되지 않음';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '전체 $count장이 갤러리에 있습니다.',
      one: '1장이 갤러리에 있습니다.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved/$total 저장됨';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => '일부 사진 저장 안 됨';

  @override
  String get tryonConsentFeatureLabel => '가상 피팅';

  @override
  String get tryonAvatarUpdatedBody => '사진이 업데이트되었습니다.';

  @override
  String get tryonSavedTitle => '저장됨';

  @override
  String get tryonUploadFailedTitle => '업로드 실패';

  @override
  String get tryonChooseGarmentFirstBody => '의류 사진을 먼저 선택해 주세요.';

  @override
  String get tryonNoGarmentTitle => '의류 없음';

  @override
  String get tryonWaitForUploadBody => '사진 업로드가 완료될 때까지 기다려 주세요.';

  @override
  String get tryonStillUploadingTitle => '업로드 중';

  @override
  String get tryonAddYourPhotoFirstBody => '먼저 본인의 사진을 추가해 주세요.';

  @override
  String get tryonReadyBody => '피팅 준비가 완료되었습니다.';

  @override
  String get tryonFailedTitle => '피팅 실패';

  @override
  String get tryonSavedToGalleryBody => '앨범에 저장되었습니다.';

  @override
  String get tryonNotSavedTitle => '저장되지 않음';

  @override
  String get calendarEventAddedBody => '일정이 추가되었습니다';

  @override
  String get calendarEventPlannedTitle => '예약됨';

  @override
  String get calendarEventSavedBody => '일정이 저장되었습니다';

  @override
  String get calendarSavedTitle => '저장됨';

  @override
  String get calendarEventNotSavedTitle => '일정이 저장되지 않음';

  @override
  String get calendarEventRemovedBody => '일정이 삭제되었습니다';

  @override
  String get calendarEventDeletedTitle => '삭제됨';

  @override
  String get calendarEventNotDeletedTitle => '일정이 삭제되지 않음';

  @override
  String get calendarOutfitNotLinkedTitle => '코디가 연결되지 않음';

  @override
  String get calendarLinkedTitle => '연결됨';

  @override
  String get calendarOutfitNotRemovedTitle => '코디가 삭제되지 않음';

  @override
  String get calendarOutfitRemovedBody => '코디가 삭제되었습니다';

  @override
  String get calendarDisconnectedBody => '캘린더가 연결 해제되었습니다';

  @override
  String get calendarDisconnectedTitle => '연결 해제됨';

  @override
  String get calendarNotDisconnectedTitle => '캘린더가 연결 해제되지 않음';

  @override
  String get calendarTodayLabel => '오늘';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이벤트 $count개',
      one: '이벤트 1개',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start~$end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, 의상 연결됨';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\"이(가) 삭제됩니다.';
  }

  @override
  String get calendarThisAppLabel => '이 앱';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider와(과)의 동기화는 아직 사용할 수 없습니다. 여기에서 이벤트를 추가할 수 있습니다.';
  }

  @override
  String get calendarWeekdaySunShort => '일';

  @override
  String get calendarWeekdayMonShort => '월';

  @override
  String get calendarWeekdayTueShort => '화';

  @override
  String get calendarWeekdayWedShort => '수';

  @override
  String get calendarWeekdayThuShort => '목';

  @override
  String get calendarWeekdayFriShort => '금';

  @override
  String get calendarWeekdaySatShort => '토';

  @override
  String get calendarWeekdayMonday => '월요일';

  @override
  String get calendarWeekdayTuesday => '화요일';

  @override
  String get calendarWeekdayWednesday => '수요일';

  @override
  String get calendarWeekdayThursday => '목요일';

  @override
  String get calendarWeekdayFriday => '금요일';

  @override
  String get calendarWeekdaySaturday => '토요일';

  @override
  String get calendarWeekdaySunday => '일요일';

  @override
  String get outfitSavedToFavouritesBody => '즐겨찾기에 저장됨';

  @override
  String get outfitRemovedFromFavouritesBody => '즐겨찾기에서 삭제됨';

  @override
  String get outfitNotSavedTitle => '저장되지 않음';

  @override
  String get outfitLoggedAsWornBody => '오늘 착용으로 기록됨.';

  @override
  String get outfitNicePickTitle => '좋아요';

  @override
  String get outfitRemovedBody => '코디가 제거되었습니다.';

  @override
  String get outfitDeletedTitle => '삭제됨';

  @override
  String get outfitNotDeletedTitle => '삭제되지 않음';

  @override
  String get outfitDuplicatedBody => '복제품이 코디에 있습니다.';

  @override
  String get outfitDuplicatedTitle => '중복';

  @override
  String get outfitNotDuplicatedTitle => '중복 아님';

  @override
  String get outfitNotSharedTitle => '공유되지 않음';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" 준비가 되었습니다.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => '컬렉션 미생성';

  @override
  String get outfitCollectionUpdatedBody => '컬렉션이 업데이트되었습니다.';

  @override
  String get outfitCollectionNotUpdatedTitle => '컬렉션 업데이트 실패';

  @override
  String get outfitCollectionDeletedBody => '컬렉션이 삭제되었습니다.';

  @override
  String get outfitCollectionNotDeletedTitle => '컬렉션 삭제 실패';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 코디가 추가되었습니다.',
      one: '코디 1개가 추가되었습니다.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => '코디 추가 실패';

  @override
  String get outfitPreviewNotCreatedTitle => '미리보기 미생성';

  @override
  String get outfitGiveNameBody => '코디에 이름을 지정하세요.';

  @override
  String get outfitNameMissingTitle => '이름';

  @override
  String get outfitChooseAtLeastOnePieceBody => '의류 최소 1개를 선택하세요.';

  @override
  String outfitCreatedBody(String name) {
    return '$name이/가 코디에 추가되었습니다.';
  }

  @override
  String get outfitSavedTitle => '저장됨';

  @override
  String get wardrobeAddedToFavouritesBody => '즐겨찾기에 추가됨';

  @override
  String get wardrobeRemovedFromFavouritesBody => '즐겨찾기에서 제거됨';

  @override
  String get wardrobeNotSavedTitle => '저장되지 않음';

  @override
  String get wardrobeLoggedAsWornBody => '오늘 착용으로 기록되었습니다.';

  @override
  String get wardrobeRemovedFromClosetBody => '클로젯에서 제거되었습니다.';

  @override
  String get wardrobeDeletedTitle => '삭제됨';

  @override
  String get wardrobeNotDeletedTitle => '삭제되지 않음';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 의류가 클로젯에서 제거되었습니다.',
      one: '의류 1개가 클로젯에서 제거되었습니다.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI 옷장 추출';

  @override
  String get itemAddScanJobLabel => '스캔';

  @override
  String get itemAddFoundEarlierBody => '이전 스캔에서 감지됨';

  @override
  String get itemAddLookingAtPhoto => '사진 확인 중';

  @override
  String get itemAddExtractionFailedBody => '추출 실패';

  @override
  String get itemAddJobFailedBody => '작업 실패';

  @override
  String get itemAddConnectionLostBody => '연결이 끊겼습니다. 다시 시도해 주세요.';

  @override
  String get itemAddConnectionLostProcessingBody => '처리 중 연결이 끊겼습니다.';

  @override
  String itemAddGeneratingPiece(int number) {
    return '의류 $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => '의류';

  @override
  String get itemAddNotCancelledTitle => '취소되지 않음';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '의류 $count점이 드레스룸에 추가되었습니다.',
      one: '의류 1점이 드레스룸에 추가되었습니다.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '총 $total개 중 $saved개를 저장했습니다. 나머지는 저장 버튼을 눌러 다시 시도해 주세요.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => '일부 의류 미저장';

  @override
  String get batchChooseAtLeastOnePhotoBody => '사진을 한 장 이상 선택해 주세요.';

  @override
  String get batchPhotoUnreadableBody => '이 사진은 읽을 수 없습니다.';

  @override
  String get batchNoPhotosReadableBody => '선택한 사진은 읽을 수 없습니다. 다른 사진을 시도해 보세요.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진 $count장',
      one: '사진 1장',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody => '처리 중 연결이 끊겼습니다. 다시 시도해 주세요.';

  @override
  String get batchNotCancelledTitle => '취소되지 않음';

  @override
  String get batchPostLinkUnsupportedBody =>
      '게시물 링크는 지원되지 않습니다. 프로필 링크를 입력해 주세요.';

  @override
  String get batchLinkSpacesBody => '링크에는 공백을 포함할 수 없습니다.';

  @override
  String get batchEnterProfileLinkBody =>
      'Instagram 또는 Facebook 프로필 링크를 입력해 주세요.';

  @override
  String get batchEnterProfileLinkShortBody => '프로필 링크를 입력해 주세요.';

  @override
  String get batchSignInPageNotOpenBody => '로그인 페이지가 열리지 않았습니다. 다시 시도해 주세요.';

  @override
  String get batchSignInBrowserBody => '브라우저에서 로그인한 뒤 FitCheck으로 돌아오세요.';

  @override
  String get batchConnectAccountTitle => '계정 연결';

  @override
  String get batchEnterAuthenticatorCodeBody => '인증 앱의 코드를 입력해 주세요.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram 보안 확인이 필요합니다. 먼저 브라우저에서 로그인하세요.';

  @override
  String get batchEnterCredentialsAgainBody => '사용자 이름과 비밀번호를 다시 입력해 주세요.';

  @override
  String get batchSignInFailedBody => '로그인에 실패했습니다. 사용자 이름과 비밀번호를 확인하세요.';

  @override
  String get batchSignInToKeepImportingBody => '수입을 계속하려면 로그인하세요.';

  @override
  String get batchAccountNotConnectedBody => '계정이 연결되지 않았습니다.';

  @override
  String get batchAccountConnectedTitle => '계정 연결됨';

  @override
  String get batchNotConnectedTitle => '연결되지 않음';

  @override
  String get batchImportConnectionLostBody => '수입 연결이 끊겼습니다. 새로고침하여 확인해 주세요.';

  @override
  String batchPickUpToBody(int max) {
    return '사진 최대 $max개 선택하세요. 아이템을 찾아드립니다.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '사진 $count/$total개';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '$count개 중 $done번째 사진 준비 중';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진 $count개에서 아이템 찾기',
      one: '사진 1개에서 아이템 찾기',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return '$platform 계정은 2단계 로그인 사용 중입니다. 인증 앱의 6자리 코드를 입력하세요.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return '이 $platform 프로필은 비공개이거나 사진 확인을 위해 로그인이 필요합니다.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform와 연결';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진 $count개 발견됨',
      one: '사진 1개 발견됨',
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
    return '$processed/$total 처리됨 · $added 추가됨 · $waiting 대기 · $skipped 건너뜀';
  }

  @override
  String batchScanningPhoto(int number) {
    return '$number번 사진 스캔 중';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '$number번 사진이 다음입니다';
  }

  @override
  String batchPhotoLabel(int number) {
    return '$number번 사진';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '아이템 $count개 발견됨',
      one: '아이템 1개 발견됨',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진 $count개가 드레스룸에 추가되었습니다.',
      one: '사진 1개가 드레스룸에 추가되었습니다.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '스튜디오 사진 $count개가 진행 중입니다. 준비된 것을 저장하거나 나갈 수 있으며, 알려드리겠습니다.',
      one: '스튜디오 사진 1개가 진행 중입니다. 준비된 것을 저장하거나 나갈 수 있으며, 알려드리겠습니다.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return '아직 저장되지 않음: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '사진 $photos개',
      one: '사진 1개',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '아이템 $pieces개',
      one: '아이템 1개',
    );
    return '$_temp0에서 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen개 선택됨. 건너뜬다면 아이템을 탭하세요.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '아이템 $count개 저장 중',
      one: '아이템 1개 저장 중',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '아이템 $count개 저장',
      one: '아이템 1개 저장',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => '바디 프로필이 저장되었습니다.';

  @override
  String get bodyProfileSavedTitle => '저장됨';

  @override
  String get bodyProfileNotSavedTitle => '저장되지 않음';

  @override
  String get bodyProfileSetDefaultBody => '기본 프로필로 설정하세요.';

  @override
  String get bodyProfileDeletedBody => '바디 프로필이 삭제되었습니다.';

  @override
  String get bodyProfileDeletedTitle => '삭제됨';

  @override
  String get bodyProfileNotDeletedTitle => '삭제되지 않음';

  @override
  String get feedbackNotSentTitle => '전송되지 않음';

  @override
  String get feedbackSentBody => '감사합니다. 모든 메시지를 확인하며 추가 정보가 필요하면 답변드립니다.';

  @override
  String get feedbackSentTitle => '피드백 전송 완료';

  @override
  String get recommendUnnamedPiece => '이름 없는 아이템';

  @override
  String get recommendEnterCityBody => '날씨에 맞는 추천을 받기 위해 도시를 입력하세요.';

  @override
  String get recommendWhichCityTitle => '어떤 도시인가요?';

  @override
  String get aiConsentSheetTitle => 'AI 서비스에 사진 공유';

  @override
  String get aiConsentSheetBody =>
      '트라이온 및 슈팅 이미지 생성을 위해 FitCheck AI는 제공된 사진(얼굴과 몸 이미지 포함)을 신뢰할 수 있는 제3자 AI 공급업체(예: OpenAI 또는 Google Gemini)로 전송합니다. 해당 공급업체는 이미 생성된 이미지를 모델 학습에 사용하지 않으며, 사진은 안전하게 전송되며 광고 목적으로 절대 공유되지 않습니다.';

  @override
  String get aiConsentSheetPermission =>
      '계속하면 이미지 생성을 위해 AI 공급업체와 사진을 공유하는 데 명시적으로 동의하게 됩니다.';

  @override
  String get skeletonsLoadMoreFailed => '더 불러오지 못했습니다.';

  @override
  String get jobsPiecesReadyTitle => '아이템 준비 완료';

  @override
  String get jobsScanStoppedTitle => '스캔이 중단되었습니다';

  @override
  String get jobsNothingSavedBody => '저장된 항목이 없습니다. 다시 시도하세요.';

  @override
  String get jobsPhotoUploadFailedBody => '사진 업로드에 실패했습니다.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google 로그인 시작에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get referralAppliedTitle => '추천 적용 완료';

  @override
  String get billingStoreUnavailableBody => '이 기기에서는 스토어 구매가 지원되지 않습니다.';

  @override
  String get billingPurchaseProcessingBody =>
      '구매 처리 중입니다. 잠시 후 앱을 다시 열면 요금제를 볼 수 있습니다.';

  @override
  String get profileAvatarUploadNoUrl => '아바타 업로드에서 이미지 URL이 반환되지 않았습니다.';

  @override
  String get rewardsDayStreakLabel => '일 연속';

  @override
  String rewardsBestStreak(int days) {
    return '최고 $days일 연속';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission 권한 필요';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '현재 $permission 접근이 거부되어 있습니다. 설정에서 허용한 후 다시 시도하세요.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '4단계 중 $step단계';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '$total단계 중 $step단계';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '이미지 $index 삭제';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '이미지 $index 삭제';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points 포인트';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '$email(으)로 이메일을 보내주세요. 24시간 이내에 보고서를 검토합니다.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece 제거';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '\"$name\"(으)를 삭제할까요?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '\"$name(으)로 추가';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\"이(가) 삭제되었습니다. 의류는 클로제트에 유지됩니다.';
  }

  @override
  String outfitShowAllCount(int count) {
    return '$count개 모두 보기';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '오늘 $count회 남음';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return '사진 $index 실패';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected/$max 사진 선택';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape 체형 · $tone 피부색';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name을(를) 삭제할까요?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name 설정';
  }

  @override
  String profileMostWorn(String name, int count) {
    return '가장 많이 입은: $name, $count회';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: 미설정';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% 일치';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked/$max 선택됨';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item 제거';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency 우선순위';
  }

  @override
  String billingBilledThroughStore(String store) {
    return '이 플랜은 $store에서 청구됩니다. $store 계정 설정에서 변경하거나 취소하세요.';
  }

  @override
  String billingManageInStore(String store) {
    return '$store에서 관리';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max 중 $current 사용';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return '약 $seconds초 남음';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total 중 $done 스튜디오 사진 준비 완료';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total 중 $ready 스튜디오 사진 준비 완료. 항목을 탭하여 건너뛰기.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '${height}cm · ${weight}kg';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => '아니오';
}
