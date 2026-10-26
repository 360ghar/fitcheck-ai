// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => '首页';

  @override
  String get tabPhotoshoot => '拍摄';

  @override
  String get tabCloset => '衣橱';

  @override
  String get tabOutfits => '搭配';

  @override
  String get tabMore => '更多';

  @override
  String get actionAddItem => '添加单品';

  @override
  String get actionCreateOutfit => '创建搭配';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionSave => '保存';

  @override
  String get actionRetry => '重试';

  @override
  String get actionDone => '完成';

  @override
  String get actionNext => '下一步';

  @override
  String get actionBack => '返回';

  @override
  String get actionClose => '关闭';

  @override
  String get actionSearch => '搜索';

  @override
  String get actionContinue => '继续';

  @override
  String get stateLoading => '加载中';

  @override
  String get stateErrorTitle => '出错了';

  @override
  String get stateErrorBody => '请重试。如果问题持续，请联系客服。';

  @override
  String get stateOfflineTitle => '无网络连接';

  @override
  String get stateOfflineBody => '请重新连接以同步衣橱并生成搭配。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsPreferencesSection => '偏好设置';

  @override
  String get settingsPlanBilling => '方案与账单';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsUnits => '度量单位';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsPrivacySection => '隐私与数据';

  @override
  String get settingsAboutSection => '关于';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsDeleteAccount => '删除账户';

  @override
  String get settingsDeleteAccountTitle => '确定删除账户吗？';

  @override
  String get settingsDeleteAccountBody => '此操作将删除您的衣橱、穿搭、照片和个人资料，且无法撤销。';

  @override
  String get settingsUnitsImperial => '英制 (in, lb)';

  @override
  String get settingsUnitsMetric => '公制 (cm, kg)';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统语言';

  @override
  String get languageSystemBody => 'FitCheck AI 将使用您手机的系统语言。';

  @override
  String get languageSearchHint => '搜索语言';

  @override
  String get languageCurrent => '当前';

  @override
  String get languageReviewNote => '此翻译为新内容，如有不妥请告知我们。';

  @override
  String get languageChanged => '语言已更新';

  @override
  String get paywallTitle => '选择您的方案';

  @override
  String get paywallTrialBadge => '首月免费';

  @override
  String get paywallTrialTitle => 'Pro 首月免费';

  @override
  String get paywallTrialBody => '一次性上传整个衣橱，之后可随时添加单品。';

  @override
  String get paywallFreeForeverTitle => '永久免费';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return '无需绑定银行卡。每月可获得 $uploads 次 AI 上传、$outfits 套穿搭以及每天 $images 张拍摄图片。';
  }

  @override
  String get paywallCtaTrial => '开启免费试用';

  @override
  String paywallCtaUpgrade(String plan) {
    return '升级至 $plan';
  }

  @override
  String get paywallRestore => '恢复购买';

  @override
  String get paywallManage => '管理订阅';

  @override
  String get paywallTerms => '使用条款';

  @override
  String get paywallPrivacy => '隐私政策';

  @override
  String get paywallPerMonth => '每月';

  @override
  String get paywallPerYear => '每年';

  @override
  String get paywallBestValue => '超值推荐';

  @override
  String paywallTrialEligibleOnly(String price) {
    return '仅限新订阅用户免费试用。试用期后，Pro 将以 $price 自动续订，除非在试用期结束前至少 24 小时取消。';
  }

  @override
  String get introTitle => '让衣橱井井有条';

  @override
  String get introBody => '只需拍摄一次衣物，即可获取穿搭灵感、试穿预览以及由现有衣物生成的摄影棚级照片。';

  @override
  String get introStart => '开始使用';

  @override
  String get introHaveAccount => '已有账号';

  @override
  String get introSkip => '跳过';

  @override
  String get authSignIn => '登录';

  @override
  String get authSignUp => '创建账号';

  @override
  String get authEmail => '电子邮箱';

  @override
  String get authPassword => '密码';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authContinueApple => '通过 Apple 继续';

  @override
  String get authContinueGoogle => '通过 Google 继续';

  @override
  String get authOrDivider => '或';

  @override
  String get wardrobeTitle => '衣橱';

  @override
  String get wardrobeEmptyTitle => '衣橱空空如也';

  @override
  String get wardrobeEmptyBody => '添加您的第一件单品，或上传一张衣架全景照。';

  @override
  String get wardrobeAddFirst => '添加第一件单品';

  @override
  String get wardrobeSearchHint => '搜索衣橱';

  @override
  String get categoryTops => '上装';

  @override
  String get categoryBottoms => '下装';

  @override
  String get categoryShoes => '鞋履';

  @override
  String get categoryAccessories => '配饰';

  @override
  String get categoryOuterwear => '外套';

  @override
  String get categorySwimwear => '泳装';

  @override
  String get categoryActivewear => '运动装';

  @override
  String get categoryOther => '其他';

  @override
  String get conditionClean => '干净';

  @override
  String get conditionDirty => '待洗';

  @override
  String get conditionLaundry => '待洗';

  @override
  String get conditionRepair => '待修';

  @override
  String get conditionDonate => '待捐';

  @override
  String get seasonSpring => '春季';

  @override
  String get seasonSummer => '夏季';

  @override
  String get seasonFall => '秋季';

  @override
  String get seasonWinter => '冬季';

  @override
  String get seasonAll => '四季';

  @override
  String get styleCasual => '休闲';

  @override
  String get styleFormal => '正式';

  @override
  String get styleBusiness => '商务';

  @override
  String get styleSporty => '运动';

  @override
  String get styleBohemian => '波西米亚';

  @override
  String get styleStreetwear => '街头';

  @override
  String get styleVintage => '复古';

  @override
  String get styleMinimalist => '极简';

  @override
  String get styleRomantic => '浪漫';

  @override
  String get styleEdgy => '前卫';

  @override
  String get stylePreppy => '学院';

  @override
  String get styleArtsy => '艺术';

  @override
  String get styleClassic => '经典';

  @override
  String get styleElegant => '优雅';

  @override
  String get styleOther => '其他';

  @override
  String get occasionWork => '职场';

  @override
  String get occasionDateNight => '约会';

  @override
  String get occasionTravel => '旅行';

  @override
  String get occasionWedding => '婚礼';

  @override
  String get occasionGym => '健身';

  @override
  String get occasionWeekend => '周末';

  @override
  String get occasionParty => '派对';

  @override
  String get occasionInterview => '面试';

  @override
  String get colorBlack => '黑色';

  @override
  String get colorWhite => '白色';

  @override
  String get colorGrey => '灰色';

  @override
  String get colorNavy => '藏青色';

  @override
  String get colorBrown => '棕色';

  @override
  String get colorRed => '红色';

  @override
  String get colorBlue => '蓝色';

  @override
  String get colorGreen => '绿色';

  @override
  String get colorPink => '粉色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorYellow => '黄色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorBeige => '米色';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count天前',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count周前',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个月前',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年前',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => '喜欢 FitCheck AI 吗？';

  @override
  String get ratingPromptBody => '给个好评，帮助他人发现自己的风格。';

  @override
  String get ratingPromptYes => '去评分';

  @override
  String get ratingPromptNo => '以后再说';

  @override
  String get closetNoMatchesTitle => '没有匹配单品';

  @override
  String get closetNoMatchesBody => '尝试减少筛选条件或更换搜索词。';

  @override
  String get closetClearFilters => '清除筛选';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件单品',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => '正在加载单品';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选$count件',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => '删除选中';

  @override
  String get closetCancelSelection => '取消选择';

  @override
  String get closetCloseSearch => '关闭搜索';

  @override
  String get closetShowGrid => '网格视图';

  @override
  String get closetShowList => '列表视图';

  @override
  String get closetShowRows => '行视图';

  @override
  String get closetStatsTitle => '衣橱统计';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '删除 $count 件单品？',
      one: '删除该单品？',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => '使用这些单品的搭配将受影响。';

  @override
  String get closetSortBy => '排序方式';

  @override
  String get closetFavourites => '收藏夹';

  @override
  String get closetFavourite => '收藏';

  @override
  String get closetUnfavourite => '取消收藏';

  @override
  String get closetWoreToday => '今天穿过';

  @override
  String closetWornTimes(int count) {
    return '已穿 $count 次';
  }

  @override
  String get closetCategoryLabel => '类别';

  @override
  String get closetUseCaseLabel => '场合';

  @override
  String get closetAnyUseCase => '全部';

  @override
  String get closetOtherUseCase => '其他场合';

  @override
  String get closetOtherUseCaseHint => '例如：早午餐';

  @override
  String get closetUseUseCase => '使用此场合';

  @override
  String get closetClearAll => '全部清除';

  @override
  String get sortNewest => '最新优先';

  @override
  String get sortOldest => '最旧优先';

  @override
  String get sortName => '名称 (A–Z)';

  @override
  String get sortMostWorn => '穿着频率最高';

  @override
  String get useCaseInformal => '休闲';

  @override
  String get useCaseDate => '约会';

  @override
  String get useCaseDinner => '晚餐';

  @override
  String get useCaseLunch => '午餐';

  @override
  String get actionSelect => '选择';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionFilter => '筛选';

  @override
  String get actionSort => '排序';

  @override
  String get actionAll => '全部';

  @override
  String get dashboardStartClosetTitle => '建立衣橱';

  @override
  String get dashboardStartClosetBody => '拍摄几件单品，我们将为您自动打标。';

  @override
  String get dashboardPieces => '件单品';

  @override
  String get dashboardOutfits => '套穿搭';

  @override
  String get dashboardDayStreak => '天连续记录';

  @override
  String dashboardAddedThisMonth(int count) {
    return '本月新增 $count 件';
  }

  @override
  String dashboardBestStreak(int count) {
    return '最高纪录 $count 天';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件收藏',
      one: '1 件收藏',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 套保存穿搭',
      one: '1 套保存穿搭',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return '最常穿：$name，$count 次';
  }

  @override
  String get setupSkip => '跳过设置';

  @override
  String get setupWhoTitle => '为您打造造型';

  @override
  String get setupWhoBody => '设置试穿模特，可在个人资料中随时更改。';

  @override
  String get setupStyleTitle => '您常穿的风格？';

  @override
  String get setupStyleBody => '任选其一，我们将以此为您推荐穿搭。';

  @override
  String get setupClosetTitle => '添加首批单品';

  @override
  String get setupClosetBody => '拍摄几件衣服或一堆衣物，我们将为您自动抠图并归档。';

  @override
  String get setupAddClothes => '添加衣物';

  @override
  String get setupStylesLabel => '风格';

  @override
  String get setupOccasionsLabel => '场合';

  @override
  String get setupSkipStep => '跳过';

  @override
  String get setupLater => '稍后';

  @override
  String get setupSaveError => '保存失败';

  @override
  String get genderWomen => '女装';

  @override
  String get genderMen => '男装';

  @override
  String get genderNonBinary => '非二元性别';

  @override
  String get genderPreferNotToSay => '保密';

  @override
  String get outfitEmptyTitle => '暂无穿搭';

  @override
  String get outfitEmptyBody => '从衣橱中挑选单品并保存你的穿搭。';

  @override
  String get outfitNoMatchesTitle => '无匹配穿搭';

  @override
  String get outfitSearchHint => '搜索穿搭';

  @override
  String get outfitLoading => '正在加载穿搭';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 套穿搭',
      one: '1 套穿搭',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => '风格与季节';

  @override
  String get outfitCollections => '系列';

  @override
  String get outfitDuplicate => '复制';

  @override
  String get outfitDeleteTitle => '删除此穿搭？';

  @override
  String get outfitDeleteBody => '单品将保留在你的衣橱中。';

  @override
  String get outfitDrafts => '草稿';

  @override
  String get outfitDraft => '草稿';

  @override
  String get filterStyle => '风格';

  @override
  String get filterSeason => '季节';

  @override
  String get itemDetailDeleteTitle => '删除此单品？';

  @override
  String get itemDetailDeleteBody => '使用该单品的穿搭将不再包含它。';

  @override
  String get itemAddFavourite => '加入收藏';

  @override
  String itemSize(String size) {
    return '尺码 $size';
  }

  @override
  String get itemColours => '颜色';

  @override
  String get itemMaterial => '材质';

  @override
  String get itemPattern => '图案';

  @override
  String get itemUseCases => '适用场景';

  @override
  String get itemKeptIn => '存放位置';

  @override
  String get itemPrice => '价格';

  @override
  String get itemBought => '购买日期';

  @override
  String get itemTags => '标签';

  @override
  String get itemAdded => '添加日期';

  @override
  String get itemTimesWornLabel => '穿着次数';

  @override
  String get itemLastWornLabel => '上次穿着';

  @override
  String get itemNeverWorn => '从未穿着';

  @override
  String get authEntryBody => 'FitCheck AI 为您的每一件单品提供穿搭建议。规划造型、虚拟试穿、拍摄记录。';

  @override
  String get authCreateCloset => '创建您的衣橱';

  @override
  String get authWelcomeBack => '欢迎回来';

  @override
  String get authSignInBody => '登录以打开您的衣橱。';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authCreateClosetBody => '只需一分钟。首批单品免费添加。';

  @override
  String get authName => '姓名';

  @override
  String get authConfirmPassword => '确认密码';

  @override
  String get authReferralCode => '推荐码（选填）';

  @override
  String get authResetTitle => '重置密码';

  @override
  String get authResetBody => '我们将发送一封邮件，点击链接即可设置新密码。';

  @override
  String get authSendResetLink => '发送重置链接';

  @override
  String get authBackToSignIn => '返回登录';

  @override
  String get authEnterEmail => '输入邮箱';

  @override
  String get authEnterValidEmail => '请输入有效邮箱';

  @override
  String get authEnterPassword => '输入密码';

  @override
  String get authPasswordTooShort => '至少 6 位字符';

  @override
  String get authShowPassword => '显示密码';

  @override
  String get authHidePassword => '隐藏密码';

  @override
  String get authNewHere => '新用户？';

  @override
  String authConfirmEmail(String email) {
    return '请在登录前验证 $email。请检查您的收件箱。';
  }

  @override
  String get authResendEmail => '重新发送';

  @override
  String get authResendingEmail => '发送中…';

  @override
  String get authPasswordsDoNotMatch => '密码不匹配';

  @override
  String get authEnterName => '输入姓名';

  @override
  String get authChoosePassword => '设置密码';

  @override
  String get authHaveAccount => '已有账户？';

  @override
  String get authCodeAccepted => '验证码已接受';

  @override
  String get authCodeNotFound => '未找到验证码';

  @override
  String authReferralFrom(String name) {
    return '来自 $name。你们都将获得一个月免费会员。';
  }

  @override
  String get authReferralInvalid => '无法找到此代码。';

  @override
  String authResetSent(String email) {
    return '已发送至 $email。请在此手机上打开链接。';
  }

  @override
  String get introSlide1Title => '一键拍摄衣橱';

  @override
  String get introSlide1Body => '拍下衣物堆，每件单品都会自动抠图并归档。';

  @override
  String get introSlide2Title => '穿搭更高效';

  @override
  String get introSlide2Body => '根据您的日程和天气，从现有衣物中匹配穿搭。';

  @override
  String get introSlide3Title => '穿前先预览';

  @override
  String get introSlide3Body => '在您的照片上试穿，或像拍摄大片一样展示造型。';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsTemperature => '温度单位';

  @override
  String get settingsEmailUpdates => '邮件更新';

  @override
  String get settingsEmailUpdatesBody => '接收新闻与穿搭建议';

  @override
  String get settingsOutfitReminders => '穿搭提醒';

  @override
  String get settingsOutfitRemindersBody => '提醒您记录每日穿搭';

  @override
  String get settingsWeeklySummary => '每周总结';

  @override
  String get settingsWeeklySummaryBody => '您的每周穿搭回顾';

  @override
  String get settingsStyleSection => '风格';

  @override
  String get settingsPreferredStyles => '偏好风格';

  @override
  String get settingsPreferredColours => '偏好颜色';

  @override
  String get settingsNoneChosen => '未选择';

  @override
  String get settingsPlanAiSection => '方案与 AI';

  @override
  String get settingsPlanBillingBody => '方案、用量与升级';

  @override
  String get settingsPlanUsageBody => '方案与用量';

  @override
  String get settingsInviteFriends => '邀请好友';

  @override
  String get settingsInviteFriendsBody => '每邀请一位好友加入即可获得一个月免费会员';

  @override
  String get settingsAiProvider => 'AI 服务商';

  @override
  String get settingsAiProviderBody => '使用自定义模型进行标签识别与图像处理';

  @override
  String get settingsAppVersion => '应用版本';

  @override
  String get settingsPrivacyTerms => '隐私政策与条款';

  @override
  String get settingsReportProblem => '反馈问题';

  @override
  String get settingsChangePassword => '修改密码';

  @override
  String get settingsExportData => '导出数据';

  @override
  String get settingsExportBody => '我们将为您生成包含所有已保存内容的文件并打开下载链接。';

  @override
  String get settingsExportAction => '导出';

  @override
  String get settingsCurrentPassword => '当前密码';

  @override
  String get settingsNewPassword => '新密码';

  @override
  String get settingsConfirmNewPassword => '确认新密码';

  @override
  String get settingsEnterCurrentPassword => '请输入当前密码';

  @override
  String get settingsEnterNewPassword => '请输入新密码';

  @override
  String get settingsPasswordMin8 => '至少使用 8 个字符';

  @override
  String get settingsPasswordNeedsUpper => '包含大写字母';

  @override
  String get settingsPasswordNeedsLower => '包含小写字母';

  @override
  String get settingsPasswordNeedsDigit => '包含数字';

  @override
  String get settingsPasswordsNoMatch => '密码不匹配';

  @override
  String get settingsChangeAction => '修改';

  @override
  String get itemAddSnapTitle => '拍摄单品';

  @override
  String get itemAddSnapBody => '我们将识别照片中的每一件单品，并为您生成清晰的摄影棚级图像。';

  @override
  String get itemAddCamera => '拍照';

  @override
  String get itemAddGallery => '从相册选择';

  @override
  String get itemAddOtherWays => '其他添加方式';

  @override
  String get itemAddSeveral => '批量添加照片';

  @override
  String get itemAddSeveralBody => '一次最多 50 张';

  @override
  String get itemAddImportProfile => '从个人资料导入';

  @override
  String get itemAddImportProfileBody => 'Instagram 或 Facebook';

  @override
  String get itemAddEnterDetails => '手动输入详情';

  @override
  String get itemAddEnterDetailsBody => '无需照片';

  @override
  String get itemManualIntro => '只需输入名称，其他信息可稍后补充。';

  @override
  String get itemManualNameHint => '例如：蓝色纯棉T恤';

  @override
  String get itemManualEnterName => '输入名称';

  @override
  String get itemManualNotes => '备注';

  @override
  String get itemManualBrand => '品牌';

  @override
  String get itemManualSize => '尺码';

  @override
  String get itemManualEnterNumber => '输入数字';

  @override
  String get itemManualSavePiece => '保存单品';

  @override
  String get itemManualSaving => '保存中';

  @override
  String get itemManualSavedTitle => '已保存';

  @override
  String itemManualSavedBody(String name) {
    return '$name 已存入您的衣橱。';
  }

  @override
  String get itemManualNotSaved => '未保存';

  @override
  String get itemManualAddUseCase => '添加用途';

  @override
  String get itemManualAddUseCaseAction => '添加用途';

  @override
  String get itemPhotos => '照片';

  @override
  String get itemAddPhotos => '添加照片';

  @override
  String get itemNoPhotoYet => '暂无照片。您可以直接保存。';

  @override
  String get itemRemovePhoto => '移除照片';

  @override
  String get itemRemovePiece => '移除单品';

  @override
  String get filterConditionLabel => '成色';

  @override
  String get photoshootStepPhotos => '照片';

  @override
  String get photoshootStepSetup => '设置';

  @override
  String get photoshootStepCreating => '生成中';

  @override
  String get photoshootStepResults => '结果';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return '第 $current 步，共 $total 步：$name';
  }

  @override
  String get photoshootOneFailed => '一张照片上传失败，请在下方重试。';

  @override
  String photoshootManyFailed(int count) {
    return '$count 张照片上传失败，请在下方逐一重试。';
  }

  @override
  String get photoshootFormat => '格式';

  @override
  String get photoshootHowMany => '数量';

  @override
  String get photoshootYourPrompt => '你的提示词';

  @override
  String get photoshootPromptHint => '屋顶黄金时刻，亚麻衬衫';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '生成 $count 张照片',
      one: '生成 1 张照片',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '张照片',
      one: '张照片',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => '无法查询今日限额。';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan 计划：今日剩余 $remaining/$limit';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => '免费';

  @override
  String get photoshootGallery => '图库';

  @override
  String get photoshootUseCamera => '使用相机';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '移除照片 $number';
  }

  @override
  String get photoshootNoPhotosTitle => '未生成照片';

  @override
  String get photoshootNoPhotosBody => '拍摄未生成图像，请重试。';

  @override
  String get photoshootNewStyle => '新风格';

  @override
  String get photoshootNewPhotos => '新照片';

  @override
  String photoshootOpenPhoto(int number) {
    return '打开照片 $number';
  }

  @override
  String get photoshootReportPhoto => '举报照片';

  @override
  String get photoshootSaveToGallery => '保存到图库';

  @override
  String get actionUpgrade => '升级';

  @override
  String get referralLimitTitle => '今日额度已用尽';

  @override
  String get referralLimitBody => '免费额度将于明日重置。邀请好友，双方均可免费获得一个月 Pro 会员。';

  @override
  String get referralLimitRefer => '邀请好友';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => '交友软件';

  @override
  String get photoshootUsePortfolio => '作品集';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => '审美风格';

  @override
  String get photoshootUseCustom => '自定义提示词';

  @override
  String get photoshootDescLinkedin => '专业职场形象照';

  @override
  String get photoshootDescDating => '轻松、温暖、自然';

  @override
  String get photoshootDescPortfolio => '时尚大片，高级感';

  @override
  String get photoshootDescInstagram => '生活方式，社交分享';

  @override
  String get photoshootDescAesthetic => '情绪感，艺术风格';

  @override
  String get photoshootDescCustom => '描述你想要的风格';

  @override
  String get aspectSquare => '正方形';

  @override
  String get aspectPortrait => '竖向';

  @override
  String get aspectLandscape => '横向';

  @override
  String get aspectTall => '长条形';

  @override
  String get aspectWide => '宽幅';

  @override
  String get tryOnAppBar => '虚拟试穿';

  @override
  String get tryOnYourPhoto => '你的照片';

  @override
  String get tryOnGarment => '服装';

  @override
  String get tryOnUploadingPhoto => '正在上传照片';

  @override
  String get tryOnAddPhotoPrompt => '添加一张全身照';

  @override
  String get tryOnBodyPhotoHint => '全身照效果最佳';

  @override
  String get tryOnAddPhoto => '添加照片';

  @override
  String get tryOnChangePhoto => '更换照片';

  @override
  String get tryOnPhotoLoadFailed => '无法加载照片';

  @override
  String get tryOnChooseGarment => '选择服装照片';

  @override
  String get tryOnChooseOneGarment => '选择一张服装照片';

  @override
  String get tryOnGarmentHint => '平铺或挂拍效果最佳';

  @override
  String get tryOnChange => '更换';

  @override
  String get tryOnCamera => '相机';

  @override
  String get tryOnRemove => '移除';

  @override
  String get tryOnLookTitle => '造型';

  @override
  String get tryOnStyle => '风格';

  @override
  String get tryOnBackground => '背景';

  @override
  String get tryOnPose => '姿势';

  @override
  String get tryOnDressingUp => '正在为你试穿，大约需要半分钟。';

  @override
  String get tryOnEmptyResult => '试穿结果将显示在此';

  @override
  String get tryOnReportImage => '举报图片';

  @override
  String get tryOnCreating => '生成中';

  @override
  String get tryOnTryAgain => '重试';

  @override
  String get tryOnCreate => '生成试穿';

  @override
  String get tryOnBackgroundStudioWhite => '摄影棚白';

  @override
  String get tryOnBackgroundStudioGrey => '摄影棚灰';

  @override
  String get tryOnBackgroundUrban => '城市街头';

  @override
  String get tryOnBackgroundNature => '自然风光';

  @override
  String get tryOnBackgroundMinimal => '极简风格';

  @override
  String get tryOnPoseFront => '正面站立';

  @override
  String get tryOnPoseSide => '侧面站立';

  @override
  String get tryOnPoseWalking => '行走姿态';

  @override
  String get dashboardGreetingMorning => '早上好';

  @override
  String get dashboardGreetingAfternoon => '下午好';

  @override
  String get dashboardGreetingEvening => '晚上好';

  @override
  String get dashboardWelcome => '欢迎';

  @override
  String get dashboardOpenProfile => '打开个人资料';

  @override
  String get dashboardRailToday => '今日';

  @override
  String get dashboardRailRecently => '最近';

  @override
  String get dashboardActivityEmpty => '新单品和穿搭将显示在此。';

  @override
  String get quickAddPiece => '添加单品';

  @override
  String get quickAddPieceBody => '拍照并添加标签';

  @override
  String get quickBuildOutfit => '搭配穿搭';

  @override
  String get quickBuildOutfitBody => '混合搭配你的单品';

  @override
  String get quickForYou => '为你推荐';

  @override
  String get quickForYouBody => '今日精选';

  @override
  String get quickPlanWeek => '一周规划';

  @override
  String get quickPlanWeekBody => '按日期规划穿搭';

  @override
  String get referralBannerUrgent => '次数不足？邀请好友获取。';

  @override
  String get referralBannerTitle => '赠送一个月，获赠一个月。';

  @override
  String get referralBannerBody => '您和好友各可获得一个月 Pro 会员。';

  @override
  String get referralBannerDismiss => '一周内不再显示';

  @override
  String get referralBannerShare => '分享邀请';

  @override
  String get referralBannerCopy => '复制链接';

  @override
  String get itemEditPieceTitle => '编辑单品';

  @override
  String get itemEditDescriptionLabel => '描述';

  @override
  String get itemEditNotSaved => '未保存';

  @override
  String get itemEditSavedTitle => '已保存';

  @override
  String get itemEditSavedBody => '修改已保存。';

  @override
  String get itemEditSavedStalePhotos => '已保存 — 照片可能已过时';

  @override
  String get itemEditRemovePieceHint => '从单品页面删除此件。';

  @override
  String get itemEditNoPhotos => '暂无照片。请从相册或相机添加。';

  @override
  String get itemEditKeepPhoto => '保留照片';

  @override
  String get itemEditRemoved => '已删除';

  @override
  String get itemEditAddUseCaseAction => '添加';

  @override
  String get statsNoStatsTitle => '暂无统计';

  @override
  String get statsNoStatsBody => '添加几件单品，即可查看您的衣橱构成。';

  @override
  String get statsByCategory => '按类别';

  @override
  String get statsTotalValue => '总价值';

  @override
  String get statsMostWorn => '最常穿';

  @override
  String get statsLeastWorn => '待穿戴';

  @override
  String get statsUnnamedPiece => '未命名单品';

  @override
  String get jobsTitle => '扫描';

  @override
  String get jobsEmptyTitle => '暂无扫描';

  @override
  String get jobsEmptyBody => '拍摄单品并发送至后台，进度将在此显示。';

  @override
  String get jobsNotCancelled => '未取消';

  @override
  String get jobsResume => '继续';

  @override
  String get jobsReview => '查看';

  @override
  String get jobsStop => '停止';

  @override
  String get jobsDismiss => '忽略';

  @override
  String get reportTitle => '举报内容';

  @override
  String reportIntro(String contentType) {
    return '请告诉我们此 $contentType 有什么问题。我们的团队会审核每一份举报。';
  }

  @override
  String get reportReasonInappropriate => '不当或冒犯性内容';

  @override
  String get reportReasonNudity => '裸露或色情内容';

  @override
  String get reportReasonHarassment => '骚扰或辱骂';

  @override
  String get reportReasonImpersonation => '冒充他人';

  @override
  String get reportReasonOther => '其他';

  @override
  String get reportDetailsLabel => '补充详情（可选）';

  @override
  String get reportSubmit => '提交举报';

  @override
  String get reportSubmittedTitle => '举报已提交';

  @override
  String get reportSubmittedBody => '感谢您的反馈。我们的团队将审核此内容。';

  @override
  String get reportFailedTitle => '无法发送举报';

  @override
  String get reportFailedBody => '请重试。';

  @override
  String get reportContentTryOnImage => 'AI 试穿图';

  @override
  String get reportContentSharedOutfit => '分享的穿搭';

  @override
  String get reportContentPhotoshootImage => 'AI 摄影图';

  @override
  String get sharedOutfitTitle => '分享的穿搭';

  @override
  String get sharedOutfitHideTooltip => '隐藏此穿搭';

  @override
  String get sharedOutfitReportTooltip => '举报此穿搭';

  @override
  String get sharedOutfitHideTitle => '隐藏此穿搭？';

  @override
  String get sharedOutfitHideBody => '它将在本设备上隐藏。您也可以举报，以便我们的团队审核并移除。';

  @override
  String get sharedOutfitHideAction => '隐藏';

  @override
  String get sharedOutfitHiddenInfo => '此穿搭将不再在本设备上显示。';

  @override
  String get sharedOutfitHiddenToast => '穿搭已隐藏';

  @override
  String get sharedOutfitMissingTitle => '此穿搭已不存在';

  @override
  String get sharedOutfitMissingBody => '它可能已被移除，或者链接有误。';

  @override
  String get sharedOutfitHiddenStateTitle => '您已隐藏此穿搭';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return '如果内容不当，请通过隐私与条款进行举报，或发送邮件至 $email。';
  }

  @override
  String get sharedOutfitCtaTitle => '喜欢这个造型？';

  @override
  String get sharedOutfitCtaBody => '用您自己的衣橱打造同款穿搭。';

  @override
  String get sharedOutfitCtaButton => '获取 FitCheck AI';

  @override
  String get errorTitle => '错误';

  @override
  String get errorUnknown => '发生未知错误';

  @override
  String get errorNoConnection => '没有网络连接，请检查网络';

  @override
  String get errorTimeout => '请求超时，请重试';

  @override
  String get errorServerError => '服务器出错，请重试';

  @override
  String get errorBadGateway => '服务暂不可用，请重试';

  @override
  String get errorServiceUnavailable => '服务暂时不可用，请稍后重试';

  @override
  String get errorInternalError => '出错了，请重试';

  @override
  String get errorUnauthorized => '请先登录';

  @override
  String get errorForbidden => '你无权访问该内容';

  @override
  String get errorSessionExpired => '登录已过期，请重新登录';

  @override
  String get errorInvalidCredentials => '邮箱或密码不正确';

  @override
  String get errorTokenRefreshFailed => '无法更新登录状态，请重新登录';

  @override
  String get errorRequestCancelled => '请求已取消';

  @override
  String get errorInvalidFormat => '不支持该文件格式';

  @override
  String get errorFileTooLarge => '文件过大';

  @override
  String get errorUploadFailed => '上传失败，请重试';

  @override
  String get errorCacheCorrupted => '已保存数据损坏并重置';

  @override
  String get errorCacheNotFound => '暂无保存内容';

  @override
  String get errorUserNotFound => '找不到该账号';

  @override
  String get errorItemNotFound => '该商品已不存在';

  @override
  String get errorOutfitNotFound => '该搭配已不存在';

  @override
  String get rewardsTitle => '奖励';

  @override
  String get rewardsNoAchievementsTitle => '暂无成就';

  @override
  String get rewardsNoAchievementsBody => '添加衣物并规划搭配以解锁首个成就';

  @override
  String get rewardsEmptyLeaderboardTitle => '暂无排行榜';

  @override
  String get rewardsEmptyLeaderboardBody => '规划搭配以获取积分并登上排行榜';

  @override
  String get legalViewPrivacyPolicy => '查看隐私政策';

  @override
  String get aiConsentAgree => '同意并继续';

  @override
  String get aiConsentNotNow => '暂不';

  @override
  String get imageViewerCloseTooltip => '关闭图片查看器';

  @override
  String get updateReadyTitle => '更新就绪';

  @override
  String get updateReadyBody => '重启 FitCheck AI 以应用最新改进。';

  @override
  String get permissionCameraUsage => 'FitCheck AI 需要相机权限，以拍摄您的穿搭和衣橱物品。';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI 需要访问您的照片图库，以选择您的穿搭和衣橱物品图片。';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI 需要将 AI 生成的穿搭照片保存至您的照片图库。';

  @override
  String get wardrobeSomePhotosSkipped => '部分照片已跳过';

  @override
  String get wardrobePhotosNotAdded => '照片未添加';

  @override
  String get wardrobePhotoNotAdded => '照片未添加';

  @override
  String get wardrobeNotStartedTitle => '未开始';

  @override
  String get wardrobeNoRoomTitle => '已满';

  @override
  String get wardrobeAddPhotosSemantic => '添加照片';

  @override
  String get batchAddTileLabel => '添加';

  @override
  String get batchProfileLinkLabel => '主页链接';

  @override
  String get wardrobeImportFromProfileTitle => '从主页导入';

  @override
  String get wardrobeAddSeveralPhotosTitle => '添加多张照片';

  @override
  String get wardrobeClearAction => '清除';

  @override
  String get wardrobeRefreshTooltip => '刷新';

  @override
  String get batchNoPhotosYetTitle => '暂无照片';

  @override
  String get batchChoosePhotosAction => '选择照片';

  @override
  String get batchWeFindEachPieceBody => '我们会为每件单品生成一张精修图。';

  @override
  String get batchPreparingPhotosSemantic => '正在准备照片';

  @override
  String get batchPhotosProcessedSemantic => '已处理照片';

  @override
  String get batchPasteProfileLinkTitle => '粘贴主页链接';

  @override
  String get batchPasteProfileLinkBody =>
      '一个公开的 Instagram 或 Facebook 主页。我们将扫描其中的照片，由您选择哪些放入衣橱。';

  @override
  String get batchClearLinkTooltip => '清除链接';

  @override
  String get batchStartingButton => '即将开始';

  @override
  String get batchStartImportAction => '开始导入';

  @override
  String get batchReviewEveryPhotoTitle => '每张照片均需您确认';

  @override
  String get batchReviewEveryPhotoBody => '经您确认后方可添加。';

  @override
  String get batchPrivateProfilesTitle => '私密资料';

  @override
  String get batchPrivateProfilesBody => '连接你的账号。Instagram 还需要用户名和密码。';

  @override
  String get batchUseAnotherLinkAction => '使用其他链接';

  @override
  String get batchSignInNeededTitle => '需要登录';

  @override
  String get batchEnterYourCodeTitle => '输入验证码';

  @override
  String get batchUseUsernamePasswordAction => '使用用户名和密码';

  @override
  String get batchAlreadyConnectedAction => '我已在浏览器中连接';

  @override
  String get batchEnterCodeAction => '输入验证码';

  @override
  String get batchTryAnotherWayAction => '尝试其他方式';

  @override
  String get batchLiveStatus => '在线';

  @override
  String get batchReconnectingStatus => '正在重连';

  @override
  String get batchSignInToInstagramTitle => '登录 Instagram';

  @override
  String get batchUsernameLabel => '用户名';

  @override
  String get batchCodeIfTwoStepLabel => '如果启用了两步验证，请输入验证码';

  @override
  String get batchAuthenticatorCodeBody => '使用验证器应用中的 6 位验证码。验证码会快速更新。';

  @override
  String get batchVerifyAction => '验证';

  @override
  String get batchFindingPhotosTitle => '查找照片';

  @override
  String get batchImportPausedTitle => '导入已暂停';

  @override
  String get batchProcessingPhotosTitle => '正在处理照片';

  @override
  String get batchWaitingNextPhoto => '等待下一张照片';

  @override
  String get batchCancelImportAction => '取消导入';

  @override
  String get batchNoPiecesInPhotoBody => '未在此照片中发现衣物。';

  @override
  String get batchEditPieceColoursLabel => '颜色，用逗号分隔';

  @override
  String get batchAddToClosetAction => '加入衣橱';

  @override
  String get batchSkipPhotoAction => '跳过此照片';

  @override
  String get batchImportCompleteTitle => '导入完成';

  @override
  String get batchImportFailedTitle => '导入失败';

  @override
  String get batchImportCancelledTitle => '导入已取消';

  @override
  String get batchImportErrorBody => '导入过程中出现错误。';

  @override
  String get batchNothingMoreImportedBody => '此资料中没有更多可导入的内容。';

  @override
  String get batchViewClosetAction => '查看衣橱';

  @override
  String get batchStartOverAction => '重新开始';

  @override
  String get wardrobeAddPieceTitle => '添加单品';

  @override
  String get wardrobeAddDetailsTitle => '添加详情';

  @override
  String get wardrobeScanningTitle => '正在扫描';

  @override
  String get batchReviewPiecesTitle => '查看单品';

  @override
  String get wardrobeGalleryAction => '相册';

  @override
  String get wardrobeCameraAction => '拍照';

  @override
  String get wardrobeNewBadge => '新';

  @override
  String get wardrobeRemovePhotoTooltip => '删除照片';

  @override
  String get batchRunInBackgroundTooltip => '后台运行';

  @override
  String get batchStepOneOfTwo => '第1步，共2步';

  @override
  String get batchStepTwoOfTwo => '第2步，共2步';

  @override
  String get batchUploadingPhotosTitle => '正在上传照片';

  @override
  String get batchFindingPiecesTitle => '正在识别单品';

  @override
  String get batchMakingStudioPhotosTitle => '正在制作产品图';

  @override
  String get batchStoppedLabel => '已停止';

  @override
  String get batchFindingPiecesStoppedTitle => '识别单品已停止';

  @override
  String get batchCancelledLabel => '已取消';

  @override
  String get batchAllDoneTitle => '全部完成';

  @override
  String get batchOpeningPiecesBody => '正在打开你的单品';

  @override
  String get batchNothingSavedBody => '没有保存任何内容。';

  @override
  String get batchFindingPiecesFailedBody => '识别单品失败。';

  @override
  String get batchFindingPiecesStoppedEarlyBody => '识别单品提前停止。';

  @override
  String get batchStopFindingPiecesTitle => '停止识别单品？';

  @override
  String get batchStopFindingPiecesBody =>
      '扫描将停止且不会保存任何内容。已识别的单品会保留在“活动”中，直到你手动关闭它们。';

  @override
  String get batchKeepGoingAction => '继续';

  @override
  String get batchTryAgainAction => '重试';

  @override
  String get batchBackToPhotosAction => '返回照片';

  @override
  String get batchSkipAllAction => '全部跳过';

  @override
  String get batchIncludeAllAction => '全选';

  @override
  String get batchNoPiecesFoundTitle => '未找到衣物';

  @override
  String get batchNoPiecesFoundBody => '我们未在照片中检测到任何衣物。';

  @override
  String get batchChooseOtherPhotosAction => '选择其他照片';

  @override
  String get batchUseCaseHelper => '已添加到你保存的每件衣物。';

  @override
  String get batchDiscardPiecesTitle => '丢弃这些衣物？';

  @override
  String get batchDiscardPiecesBody => '此批次中的任何衣物都未保存。';

  @override
  String get batchKeepAction => '保留';

  @override
  String get batchDiscardAction => '丢弃';

  @override
  String get batchRemovePieceTitle => '移除这件衣物？';

  @override
  String get batchRemovePieceBody => '它未保存到你的衣橱。';

  @override
  String get batchRemoveAction => '移除';

  @override
  String get batchChoosePiecesToSave => '选择要保存的衣物';

  @override
  String get batchDiscardAllAction => '全部丢弃';

  @override
  String get batchNothingSavedRetryBody => '未保存任何内容。请重试。';

  @override
  String get batchNotSavedTitle => '未保存';

  @override
  String get batchSavingLabel => '正在保存';

  @override
  String get batchSendToBackgroundAction => '转到后台';

  @override
  String get batchStillWorkingMessage => '正在处理。衣物就绪时会通知你。';

  @override
  String get batchRunningInBackgroundTitle => '正在后台运行';

  @override
  String get batchStudioPhotosStoppedBody => '影棚照片提前停止。你仍可保存这些衣物。';

  @override
  String get batchTapPieceToSkip => '点击衣物以跳过。';

  @override
  String get batchStudioPhotosOnWayBody => '影棚照片还在路上。你可以离开——我们会通知你。';

  @override
  String get batchLeaveAction => '离开';

  @override
  String get batchPeopleInPhotosTitle => '照片中的人';

  @override
  String get batchIncludeAction => '包含';

  @override
  String get batchSkipAction => '跳过';

  @override
  String get batchYourPhotoIsUsedLabel => '使用你的照片';

  @override
  String get batchMakingStudioPhotoLabel => '正在生成影棚照片';

  @override
  String get batchNoStudioPhotoBody => '无影棚照片。使用你的照片。';

  @override
  String get batchEnterDetailsYourselfAction => '手动填写';

  @override
  String get batchChooseAnotherPhotoAction => '选择其他照片';

  @override
  String get batchConnectionLostTitle => '连接已断开';

  @override
  String get batchConnectionLostBody => '请检查网络连接，然后重试。';

  @override
  String get batchDailyLimitTitle => '已达每日上限';

  @override
  String get batchDailyLimitBodyPaywall => '升级到 Pro 以获得更多扫描次数，或手动填写详情。';

  @override
  String get batchDailyLimitBodyFree => '扫描次数将于明天重置。您现在可以手动填写详情。';

  @override
  String get batchSeePlansAction => '查看方案';

  @override
  String get batchAiBusyTitle => 'AI 正忙';

  @override
  String get batchAiBusyBody => '这是服务端的问题。请稍后重试。';

  @override
  String get batchNoPiecesBody => '请尝试使用更清晰的照片，或手动填写详情。';

  @override
  String get batchScanningUnavailableTitle => '扫描功能不可用';

  @override
  String get batchScanningUnavailableBody => '请暂时手动填写详情。';

  @override
  String get batchScanDidNotFinishTitle => '扫描未完成';

  @override
  String get batchTryAgainBody => '重试。';

  @override
  String get billingTitle => '订阅';

  @override
  String get billingUpgradeHeading => '升级您的方案';

  @override
  String get billingUpgradeOnPlusBody => '功能相同，上限更高。';

  @override
  String get billingUpgradeBody => 'Plus 和 Pro 功能相同。请根据所需上限选择。';

  @override
  String get billingWebUnavailableBody =>
      '在线升级功能尚未上线。优惠码或推荐码仍可解锁 Plus 或 Pro。在下方邀请好友可获得免费使用月。';

  @override
  String get billingPlansStale => '无法加载最新方案。价格可能已过期。';

  @override
  String get billingMonthly => '月付';

  @override
  String get billingYearly => '年付';

  @override
  String get billingCurrentPlan => '当前方案';

  @override
  String get billingActive => '生效中';

  @override
  String get billingThisMonth => '本月';

  @override
  String get billingItemExtractions => '单品识别次数';

  @override
  String get billingOutfitVisualizations => '穿搭生成次数';

  @override
  String get billingNearLimitUpgrade => '您已接近本月上限。升级可获得更多。';

  @override
  String get billingNearLimitResets => '您已接近本月上限。将在下月初重置。';

  @override
  String get billingStoreUnavailable => '升级功能暂未在商店开放，请稍后再试。';

  @override
  String get billingManageHeading => '管理您的套餐';

  @override
  String get billingCancelPlan => '取消订阅';

  @override
  String get billingCancelKeepsAccess => '您可继续使用至本计费周期结束。';

  @override
  String get billingCancelConfirmTitle => '确定取消订阅吗？';

  @override
  String get billingKeepPlan => '保留套餐';

  @override
  String get billingCancelPlanAction => '取消套餐';

  @override
  String get billingBilledMonthly => '按月计费';

  @override
  String get billingBilledYearly => '按年计费';

  @override
  String get billingVirtualTryOn => '虚拟试穿';

  @override
  String get billingPrioritySupport => '优先客服支持';

  @override
  String get billingDisclosureProRenewing => 'Pro 为自动续订订阅';

  @override
  String get billingDisclosureBothRenewing => 'Plus 和 Pro 均为自动续订订阅';

  @override
  String get billingDisclosureAppleBilling => '购买确认时，费用将计入您的 Apple ID。';

  @override
  String get billingDisclosureGoogleBilling => '购买确认时，费用将计入您的 Google Play 账户。';

  @override
  String get billingDisclosureRenewalTerms =>
      '您的订阅将按相同周期和价格自动续订，除非您在当前周期结束前至少 24 小时关闭自动续订。';

  @override
  String get billingDisclosureAppleManage =>
      '您可以随时在“设置” > “Apple ID” > “订阅”中管理或取消。';

  @override
  String get billingDisclosureGoogleManage =>
      '您可以随时在“Google Play” > “付款与订阅”中管理或取消。';

  @override
  String get billingReferFriend => '邀请好友';

  @override
  String get billingHowItWorks => '使用方式';

  @override
  String get billingHowShareTitle => '分享您的链接';

  @override
  String get billingHowShareBody => '发送给好友。';

  @override
  String get billingHowSignUpTitle => '好友注册';

  @override
  String get billingHowSignUpBody => '好友通过链接注册。';

  @override
  String get billingHowBothTitle => '你们都能获得 Pro';

  @override
  String get billingHowBothBody => '你们各获得一个月免费 Pro。';

  @override
  String get billingYourReferrals => '您的推荐记录';

  @override
  String get billingInvited => '已邀请';

  @override
  String get billingJoined => '已注册';

  @override
  String get billingMonthsEarned => '已获得月数';

  @override
  String get billingInviteFriend => '邀请好友';

  @override
  String get billingInviteBody => '你和好友各享一个月Pro版。';

  @override
  String get billingYourCode => '你的邀请码';

  @override
  String get billingCopyLink => '复制链接';

  @override
  String get billingShareInvite => '分享邀请';

  @override
  String get giftUnavailable => '此版本暂无礼品邀请。';

  @override
  String get giftPageTitle => '赠送FitCheck Pro';

  @override
  String get giftNoAllowances => '当前暂无免费礼品邀请。';

  @override
  String get giftFormTitle => '发送免费邀请';

  @override
  String get giftFormBody => '收件人需通过此验证邮箱领取礼品。我们不会替你发送邮件。';

  @override
  String get giftFieldFrom => '发送者';

  @override
  String get giftFieldRecipientName => '收件人姓名';

  @override
  String get giftFieldRecipientEmail => '收件人邮箱';

  @override
  String get giftFieldOccasion => '场合（选填）';

  @override
  String get giftNoOccasion => '无特定场合';

  @override
  String get giftOccasionBirthday => '生日';

  @override
  String get giftOccasionAnniversary => '纪念日';

  @override
  String get giftOccasionOther => '其他';

  @override
  String get giftFieldCardGreeting => '卡片祝福语';

  @override
  String get giftFieldCardGreetingHelper => '将按原文显示在卡片上。';

  @override
  String get giftFieldPrivateNote => '私密备注（选填）';

  @override
  String get giftCreateAction => '创建免费礼品';

  @override
  String get giftClaimedTitle => '礼品已领取';

  @override
  String get giftClaimedActive => '你的FitCheck Pro礼品已激活。';

  @override
  String get giftClaimedQueued => '你的FitCheck Pro礼品将在当前访问权限结束后生效。';

  @override
  String get giftLinkCopied => '礼品链接已复制到剪贴板。';

  @override
  String get giftErrorName => '请输入姓名。';

  @override
  String get giftErrorEmail => '请输入有效邮箱。';

  @override
  String get giftErrorGreeting => '请输入卡片祝福语。';

  @override
  String get giftErrorGreetingLength => '不超过80个字符。';

  @override
  String get giftClaimAction => '领取礼物';

  @override
  String get giftCardPreview => '卡片预览';

  @override
  String get giftGiftForYou => '你的礼物';

  @override
  String get giftGiftWaiting => '有一份礼物等着你';

  @override
  String get giftOpenBody => '使用已验证的邮箱打开并领取礼物。';

  @override
  String get giftOpenGifts => '打开礼物';

  @override
  String get giftSendInvitation => '发送邀请';

  @override
  String get settingsAiProviderSection => '服务商';

  @override
  String get settingsAiCustom => '自定义';

  @override
  String get settingsAiUrlHelper => '请使用服务器可访问的公共 URL，localhost 无效。';

  @override
  String get settingsAiConnectionSection => '连接';

  @override
  String get settingsAiApiUrl => 'API 地址';

  @override
  String get settingsAiApiKey => 'API 密钥';

  @override
  String get settingsAiApiKeySaved => '已保存。留空可保持当前设置。';

  @override
  String get settingsAiChatModel => '对话模型';

  @override
  String get settingsAiVisionModel => '视觉模型（可选）';

  @override
  String get settingsAiImageModel => '图像模型（可选）';

  @override
  String get settingsAiImageModelNote =>
      '图像生成需要支持 response_modalities 的 OpenAI 兼容对话接口。';

  @override
  String get settingsAiTestConnection => '测试连接';

  @override
  String get calendarTitle => '日历';

  @override
  String get calendarGoToToday => '转到今天';

  @override
  String get calendarConnectTooltip => '连接日历';

  @override
  String get calendarAddEvent => '添加活动';

  @override
  String get calendarEmptyTitle => '暂无计划';

  @override
  String get calendarEmptyBody => '添加活动并规划穿搭。';

  @override
  String get calendarPreviousMonth => '上个月';

  @override
  String get calendarNextMonth => '下个月';

  @override
  String get calendarAllDay => '全天';

  @override
  String get calendarOutfitLinked => '已关联穿搭';

  @override
  String get calendarEventOptions => '活动选项';

  @override
  String get calendarDeleteTitle => '删除此活动？';

  @override
  String get calendarChangeOutfit => '更换搭配';

  @override
  String get calendarLinkOutfit => '关联搭配';

  @override
  String get calendarRemoveOutfit => '移除搭配';

  @override
  String get calendarNewEvent => '新建活动';

  @override
  String get calendarEditEvent => '编辑活动';

  @override
  String get calendarTitleLabel => '标题';

  @override
  String get calendarTitleRequired => '请输入标题';

  @override
  String get calendarEndBeforeStart => '结束需晚于开始时间';

  @override
  String get calendarStarts => '开始';

  @override
  String get calendarEnds => '结束';

  @override
  String get calendarPlaceOptional => '地点（可选）';

  @override
  String get calendarNotesOptional => '备注（可选）';

  @override
  String get calendarLinkOutfitEmptyBody => '先创建搭配，再关联到此活动。';

  @override
  String get calendarBuildOutfit => '创建搭配';

  @override
  String get calendarConnectionsTitle => '日历';

  @override
  String get calendarConnectionsBody => '此处添加的活动仅保存在 FitCheck AI。';

  @override
  String get calendarDisconnect => '断开';

  @override
  String get calendarNotAvailable => '暂不可用';

  @override
  String get profileSectionExplore => '探索';

  @override
  String get profileNavTryOn => '试穿';

  @override
  String get profileNavRewards => '奖励';

  @override
  String get profileSupport => '支持';

  @override
  String get profileHelp => '帮助';

  @override
  String get profileAbout => '关于';

  @override
  String get profileAboutBody => '衣橱、搭配与计划，尽在一处。';

  @override
  String get profileSignOutTitle => '退出登录？';

  @override
  String get profileSignOutBody => '您可以随时重新登录。';

  @override
  String get profileEditTitle => '编辑个人资料';

  @override
  String get profileYourProfile => '我的资料';

  @override
  String get profileBodyProfiles => '身体配置';

  @override
  String get profileBodyEmptyTitle => '暂无身体配置';

  @override
  String get profileBodyEmptyBody => '添加身高和体型以获得更合身的效果。';

  @override
  String get profileBodyAdd => '新建配置';

  @override
  String get profileBodyDefaultNote => '默认配置用于试穿和合身度分析。';

  @override
  String get profileBodyDefaultBadge => '默认';

  @override
  String get profileBodyMakeDefault => '设为默认';

  @override
  String get profileBodyDeleteBody => '此操作无法撤销。';

  @override
  String get profileBodyRequired => '必填';

  @override
  String get profileBodyCheckNumber => '核对此数字';

  @override
  String get profileBodyNew => '新的身体配置';

  @override
  String get profileBodyNameHint => '例如，我自己';

  @override
  String get profileBodyHeight => '身高';

  @override
  String get profileBodyWeight => '体重';

  @override
  String get profileBodyBuild => '体型';

  @override
  String get profileBodySkinTone => '肤色';

  @override
  String get profileBirthDateNeededBody => '添加出生日期以匹配出生时间。';

  @override
  String get profileBirthDateNeededTitle => '需要出生日期';

  @override
  String get profilePartlySavedBody => '已保存姓名和照片。出生信息未保存，请稍后重试。';

  @override
  String get profilePartlySavedTitle => '部分已保存';

  @override
  String get profileSavedBody => '资料已保存。';

  @override
  String get profileChangePhoto => '更换头像';

  @override
  String get profilePhotoLabel => '头像';

  @override
  String get profilePhotoHint => '点按选择新照片';

  @override
  String get profileBirthDateLabel => '出生日期（可选）';

  @override
  String get profileBirthTimeLabel => '出生时间（可选）';

  @override
  String get profileBirthTimeHelper => '提高吠陀建议的准确性';

  @override
  String get profileBirthPlaceLabel => '出生地点（可选）';

  @override
  String get profileBirthPlaceHint => '例如，印度新德里';

  @override
  String get profileHelpContactTitle => '向我们提问';

  @override
  String get profileHelpContactBody => '发送消息，我们会通过邮件回复，通常一天内回复。';

  @override
  String get profileHelpContactAction => '联系客服';

  @override
  String get profileHelpFaqTitle => '常见问题';

  @override
  String get profileFaqAddPiecesTitle => '如何向衣橱添加单品？';

  @override
  String get profileFaqAddPiecesBody =>
      '点击衣橱标签页中的添加单品。拍照或从相册选择；我们会识别并为你标记每个单品。';

  @override
  String get profileFaqMatchingTitle => '服装搭配如何运作？';

  @override
  String get profileFaqMatchingBody => '打开为你推荐，选择你拥有的单品。我们会推荐匹配项并从你的衣橱中搭配完整穿搭。';

  @override
  String get profileFaqTryOnTitle => '我可以使用自己的照片进行试穿吗？';

  @override
  String get profileFaqTryOnBody => '可以。添加一张全身照片，然后选择单品，查看穿在你身上的效果。';

  @override
  String get profileFaqRewardsTitle => '如何赚取奖励？';

  @override
  String get profileFaqRewardsBody => '制定计划并经常记录穿搭。随着你进行，连续记录和活动会累积。';

  @override
  String get profileFaqPrivacyTitle => '我的衣橱是私密的吗？';

  @override
  String get profileFaqPrivacyBody => '是的。除非你分享一个穿搭的链接，否则你的衣橱和穿搭是私密的。';

  @override
  String get profileHelpMoreTitle => '更多帮助';

  @override
  String get profileHelpGuides => '指南';

  @override
  String get profileHelpGuidesBody => '了解每个功能如何运作';

  @override
  String get feedbackCategoryBug => '功能故障';

  @override
  String get feedbackCategoryIdea => '建议';

  @override
  String get feedbackCategoryGeneral => '一般';

  @override
  String get feedbackCategoryHelp => '需要帮助';

  @override
  String get feedbackHintBug => '发生了什么，你期望什么？步骤有助于我们修复。';

  @override
  String get feedbackHintIdea => '你想要什么，以及为什么？';

  @override
  String get feedbackHintGeneral => '告诉我们你的想法，或提出一个问题。';

  @override
  String get feedbackAttachmentLimitBody => '你最多可以添加 5 张图片。';

  @override
  String get feedbackAttachmentLimitTitle => '达到限制';

  @override
  String get feedbackImageTooLargeBody => '选择小于 5 MB 的图片。';

  @override
  String get feedbackImageTooLargeTitle => '图片过大';

  @override
  String get feedbackTitle => '发送反馈';

  @override
  String get feedbackAboutLabel => '关于什么？';

  @override
  String get feedbackSubjectLabel => '主题';

  @override
  String get feedbackSubjectRequired => '添加主题';

  @override
  String get feedbackSubjectTooShort => '主题至少 3 个字符';

  @override
  String get feedbackDetailsLabel => '详情';

  @override
  String get feedbackDetailsRequired => '添加一些详情';

  @override
  String get feedbackDetailsTooShort => '描述至少 10 个字符';

  @override
  String get feedbackAddScreenshot => '添加截图';

  @override
  String get feedbackAttachmentHint => '最多 5 个，每个 5 MB';

  @override
  String get feedbackSend => '发送';

  @override
  String get feedbackEmptyTitle => '尚未发送';

  @override
  String get feedbackEmptyBody => '你发送的内容将在此处显示状态。';

  @override
  String get feedbackHistoryTitle => '发送记录';

  @override
  String get feedbackStatusOpen => '待处理';

  @override
  String get feedbackStatusInProgress => '处理中';

  @override
  String get feedbackStatusResolved => '已解决';

  @override
  String get feedbackStatusClosed => '已关闭';

  @override
  String get legalIntro => '我们如何保护你的数据，以及使用 FitCheck AI 的条款。';

  @override
  String get legalPolicies => '政策';

  @override
  String get legalPrivacySubtitle => '我们收集的内容及原因';

  @override
  String get legalTermsTitle => '服务条款';

  @override
  String get legalTermsSubtitle => '使用应用的规则';

  @override
  String get legalLicences => '开源许可';

  @override
  String get legalSupportSubtitle => '帮助、联系和隐私请求';

  @override
  String get legalReportAbuse => '报告问题或滥用';

  @override
  String get permissionCameraTitle => '相机访问';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI 使用你的相机拍摄衣物和搭配照片，用于 AI 试穿和衣橱整理。';

  @override
  String get permissionPhotoTitle => '照片访问';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI 需要访问你的照片，以便你选择衣物和搭配图片用于 AI 功能和衣橱。';

  @override
  String get permissionNotNow => '暂不';

  @override
  String get permissionOpenSettings => '打开设置';

  @override
  String authSignedInAs(String name) {
    return '已登录为 $name';
  }

  @override
  String get authSignedIn => '已登录';

  @override
  String get authWelcomeBackTitle => '欢迎回来';

  @override
  String get authSignInFailed => '登录失败';

  @override
  String get authWelcomeTitle => '欢迎';

  @override
  String get authSignUpFailed => '注册失败';

  @override
  String get authGoogleSignInFailed => 'Google 登录失败';

  @override
  String get authAppleSignInFailed => 'Apple 登录失败';

  @override
  String get authConfirmEmailTitle => '确认您的邮箱';

  @override
  String get authConfirmEmailBody => '请查看收件箱中的确认邮件，然后登录。';

  @override
  String get authClosetReady => '您的衣柜已就绪。';

  @override
  String get authSignedOutTitle => '已退出';

  @override
  String get authSignedOutBody => '您已退出。';

  @override
  String get authSignOutFailed => '退出失败';

  @override
  String get authEmailSentTitle => '邮件已发送';

  @override
  String get authResetLinkSent => '请查看邮箱中的重置链接。';

  @override
  String get authPasswordUpdatedTitle => '密码已更新';

  @override
  String get authPasswordUpdated => '您的密码已更新。';

  @override
  String get authPasswordNotUpdated => '密码未更新';

  @override
  String get authCouldNotSendEmail => '无法发送邮件';

  @override
  String get authEmailNotSent => '邮件未发送';

  @override
  String get authResendSentBody => '我们已发送新的确认邮件。';

  @override
  String get outfitPreviewWithAi => 'AI 预览';

  @override
  String get outfitNewPreview => '创建新预览';

  @override
  String get outfitBuilderClosetHeading => '您的衣柜';

  @override
  String get outfitBuilderSearchHint => '搜索单品';

  @override
  String get outfitClearSearch => '清除搜索';

  @override
  String get outfitBuilderAddPiecesTitle => '请先添加单品';

  @override
  String get outfitBuilderAddPiecesBody => '穿搭由衣柜中的单品组成。';

  @override
  String get outfitBuilderNoMatches => '无匹配单品。';

  @override
  String get outfitNameLabel => '穿搭名称';

  @override
  String get outfitNameHint => '例如，周末亚麻';

  @override
  String get outfitPreviewSemantic => '服装 AI 预览';

  @override
  String get outfitChoosePieces => '选择单品';

  @override
  String get outfitTapPiecesHint => '轻点下方单品以添加。';

  @override
  String get outfitShareTooltip => '分享';

  @override
  String get outfitSaveFavourite => '收藏';

  @override
  String get outfitPiecesHeading => '单品';

  @override
  String get outfitWearHistoryEmpty => '穿戴一次后，日期将显示在此处。';

  @override
  String get outfitWearHistoryTitle => '穿戴记录';

  @override
  String get outfitWearHistoryError => '无法加载日期。';

  @override
  String get outfitWornOn => '穿戴日期';

  @override
  String get outfitEditTitle => '编辑穿搭';

  @override
  String get outfitSavedPhotosFailed => '详情已保存，照片未保存';

  @override
  String get outfitNoPhotosBody => '暂无照片。穿搭将显示其单品。';

  @override
  String get outfitOccasionLabel => '场合';

  @override
  String get outfitOccasionNone => '无';

  @override
  String get outfitTagsHint => '用逗号分隔';

  @override
  String get outfitDraftBody => '已隐藏在主列表中';

  @override
  String get outfitPublic => '公开';

  @override
  String get outfitPublicBody => '拥有链接的人都可以查看';

  @override
  String get outfitDeleteFromDetail => '从详情页删除此穿搭。';

  @override
  String get outfitNewCollection => '新建合集';

  @override
  String get outfitNoCollectionsTitle => '暂无合集';

  @override
  String get outfitNoCollectionsBody => '按旅行、季节或心情分组穿搭。';

  @override
  String get outfitCreateCollection => '创建合集';

  @override
  String get outfitAddOutfits => '添加穿搭';

  @override
  String get outfitRename => '重命名';

  @override
  String get outfitCollectionDeleteBody => '其中的穿搭将保留。';

  @override
  String get outfitCollectionsNotLoaded => '穿搭未加载';

  @override
  String get outfitRenameCollection => '重命名合集';

  @override
  String get outfitDescriptionOptional => '描述（可选）';

  @override
  String get outfitAllInCollection => '所有搭配已在此合集内。';

  @override
  String get photoshootSubtitleUpload => '用你的照片生成影棚人像';

  @override
  String get photoshootSubtitleConfigure => '选择风格、格式和数量';

  @override
  String get photoshootSubtitleGenerating => '需要一两分钟';

  @override
  String get photoshootAddPhotosSemantic => '从图库添加照片';

  @override
  String get photoshootUploadTitle => '添加 1 到 4 张你的照片';

  @override
  String get photoshootUploadBody => '轻点从图库选择';

  @override
  String get photoshootAddToContinue => '添加照片以继续';

  @override
  String get photoshootAddAnotherPhoto => '再添加一张照片';

  @override
  String get photoshootTipsTitle => '获得最佳效果';

  @override
  String get photoshootTipsBody => '使用光线充足、角度多样的清晰面部照片。避免戴墨镜或帽子。';

  @override
  String get photoshootStarting => '开始中';

  @override
  String get photoshootCancelling => '取消中';

  @override
  String get photoshootFailed => '失败';

  @override
  String get recommendTabMatches => '搭配';

  @override
  String get recommendTabComplete => '补全';

  @override
  String get recommendTabWeather => '天气';

  @override
  String get recommendTabColours => '色彩';

  @override
  String get recommendTabShop => '购物';

  @override
  String get recommendNoMatchesTitle => '暂无搭配';

  @override
  String get recommendNoMatchesBody => '选一件单品，我们会找到与之匹配的搭配。';

  @override
  String get recommendPickPiece => '选择单品';

  @override
  String get recommendNothingMatchesTitle => '这些单品暂无搭配';

  @override
  String get recommendNothingMatchesBody => '试试其他单品，或往衣橱里添加更多。';

  @override
  String get recommendChangePieces => '更换单品';

  @override
  String get recommendDefaultReason => '与你选的单品很搭。';

  @override
  String get recommendCompleteTitle => '补全穿搭';

  @override
  String get recommendCompleteBody => '选一件单品，我们帮你补齐其余部分。';

  @override
  String get recommendWorking => '处理中';

  @override
  String get recommendGenerate => '生成';

  @override
  String get recommendChooseStyleBody => '选择风格，然后生成。';

  @override
  String get recommendNoLooksTitle => '这些单品无搭配';

  @override
  String get recommendNoLooksBody => '试试其他风格或单品。';

  @override
  String get recommendDefaultLook => '单品搭配方案';

  @override
  String get recommendNoPiecesBody => '该搭配暂无可用单品。';

  @override
  String get recommendCityLabel => '城市';

  @override
  String get recommendCheck => '查看';

  @override
  String get recommendWeatherTitle => '今天天气如何？';

  @override
  String get recommendWeatherBody => '输入城市，获取今日推荐。';

  @override
  String get recommendWearToday => '今日穿搭';

  @override
  String get recommendWeatherNoPieces => '衣橱中暂无适合该天气的单品。';

  @override
  String get recommendBudgetLabel => '预算上限';

  @override
  String get recommendLooking => '正在查找';

  @override
  String get recommendFindWhatToBuy => '查找购买建议';

  @override
  String get recommendFillGapsTitle => '补齐缺口';

  @override
  String get recommendFillGapsBody => '设定预算，推荐衣橱缺失的单品。';

  @override
  String get recommendNoGapsTitle => '未找到缺口';

  @override
  String get recommendNoGapsBody => '尝试提高预算或更换品类。';

  @override
  String get recommendMoodEveryday => '日常';

  @override
  String get recommendMoodBigMeeting => '重要会议';

  @override
  String get recommendDayLabel => '日期';

  @override
  String get recommendReadingStars => '正在解读星象';

  @override
  String get recommendGetMyColours => '获取我的幸运色';

  @override
  String get recommendLuckyColoursTitle => '你的幸运色';

  @override
  String get recommendLuckyColoursBody => '选择日期，推荐幸运色和单品。';

  @override
  String get recommendLuckyColoursSection => '幸运色';

  @override
  String get recommendAvoidColoursSection => '建议少用的颜色';

  @override
  String get recommendBirthDateTitle => '添加出生日期';

  @override
  String get recommendBirthDateBody => '需出生日期以解读幸运色。';

  @override
  String get recommendEditProfile => '编辑资料';

  @override
  String get recommendNothingThisDay => '今日无推荐';

  @override
  String get recommendUnnamedColour => '未命名颜色';

  @override
  String get recommendFromCloset => '来自您的衣橱';

  @override
  String get recommendNoPiecesInColours => '暂无这些颜色的单品';

  @override
  String get recommendOutfitIdeas => '穿搭灵感';

  @override
  String get recommendNoOutfitsInColours => '暂无这些颜色的完整穿搭';

  @override
  String get recommendDefaultOutfitIdea => '穿搭建议';

  @override
  String get recommendPickUpToThree => '最多选三件';

  @override
  String get recommendEmptyClosetBody => '请先添加单品，再回来获取搭配。';

  @override
  String get dashboardDressForDay => '为今天搭配得体装扮。';

  @override
  String get dashboardOutfitOfDay => '今日穿搭';

  @override
  String get dashboardFreshLook => '焕新造型';

  @override
  String get subscriptionManageInStoreTitle => '在商店中管理';

  @override
  String get subscriptionManageInStoreBody => '此计划通过商店扣费。请在商店账户设置中管理。';

  @override
  String get subscriptionCancelledTitle => '已取消订阅';

  @override
  String get subscriptionCancelledBody => '您的计划将保持激活至本期结束。';

  @override
  String get subscriptionCancelFailedTitle => '无法取消';

  @override
  String get subscriptionCouldNotOpenTitle => '无法打开';

  @override
  String get subscriptionOpenBillingFailedBody => '无法打开账单管理。';

  @override
  String get subscriptionOpenLinkFailedBody => '无法打开链接。';

  @override
  String get subscriptionReferralLoadFailedTitle => '无法加载链接';

  @override
  String get subscriptionReferralLoadFailedBody => '无法加载推荐链接。请重试。';

  @override
  String get subscriptionReferralCopiedTitle => '已复制';

  @override
  String get subscriptionReferralCopiedBody => '推荐链接已复制。';

  @override
  String get subscriptionReferralShareSubject => '试试 FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return '加入 FitCheck AI，我们都可获一个月 Pro。$link';
  }

  @override
  String get subscriptionLinkCopiedTitle => '链接已复制';

  @override
  String get subscriptionShareUnavailableBody => '无法分享，已复制链接。';

  @override
  String get subscriptionShareFailedTitle => '无法分享';

  @override
  String get subscriptionShareFailedBody => '请改为复制推荐页面上的链接。';

  @override
  String get subscriptionStoreReadyTitle => '商店已就绪';

  @override
  String get subscriptionStoreReadyBody => '商店价格已可用，您可以立即升级。';

  @override
  String get purchaseFailedTitle => '购买失败';

  @override
  String get purchaseUnavailableTitle => '无法购买';

  @override
  String get purchaseIapUnavailableBody => '此设备不支持应用内购买。';

  @override
  String get purchasePlanNotAvailableBody => '该方案尚不可购买。';

  @override
  String get purchasePlanNotInStoreBody => '该方案尚未在商店上架，请稍后再试。';

  @override
  String get purchaseStartFailedBody => '无法启动购买，请重试。';

  @override
  String get purchaseNoPaymentLinkBody => '结账未返回支付链接。';

  @override
  String get purchasePendingTitle => '购买处理中';

  @override
  String get purchasePendingBody => '您的购买正在等待批准，批准后即可获得访问权限。';

  @override
  String get purchaseFailedBody => '购买失败，请重试。';

  @override
  String get purchaseRestoredTitle => '已恢复';

  @override
  String get purchaseRestoredBody => '您的购买记录已恢复。';

  @override
  String get purchaseActiveTitle => '订阅已激活';

  @override
  String get purchaseActiveBody => '您的订阅已生效，欢迎使用。';

  @override
  String get purchaseSignInRequiredTitle => '需要登录';

  @override
  String get purchaseSignInRequiredBody => '请登录以完成购买。';

  @override
  String get purchaseErrorTitle => '购买出错';

  @override
  String get purchaseInvalidTransactionBody => '该购买未包含可验证的交易 ID。';

  @override
  String get purchaseVerificationPendingTitle => '验证中';

  @override
  String get purchaseVerificationPendingBody =>
      '目前无法通过商店验证您的购买。该流程将自动完成，且不会重复扣费。';

  @override
  String get purchaseNotAppliedTitle => '购买未生效';

  @override
  String get purchaseNotAppliedBody => '无法将该购买应用至您的账户。请联系客服，且请勿再次购买。';

  @override
  String get purchaseRestoreFailedTitle => '恢复失败';

  @override
  String get purchaseRestoreFailedBody => '无法恢复购买记录，请重试。';

  @override
  String get purchaseRecoveredActiveBody => '您的订阅已生效。';

  @override
  String get purchaseCompleteTitle => '购买完成';

  @override
  String get giftCreateFailedTitle => '无法创建礼品';

  @override
  String get giftClaimFailedTitle => '无法领取礼物';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个礼物',
      one: '1 个礼物',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 个月',
      '12': '1 年',
      'other': '$months 个月',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '剩余 $remaining 次',
      one: '剩余 1 次',
    );
    return '$duration，$_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration 的 FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender 给你送了 $duration 的 FitCheck Pro。$link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '给 $recipient 的 FitCheck Pro 礼物';
  }

  @override
  String giftFromSender(String sender) {
    return '来自 $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '赠予 $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '来自 $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => '收件人';

  @override
  String get giftPreviewPlaceholderSender => '你';

  @override
  String get settingsSavedTitle => '已保存';

  @override
  String get settingsNotSavedTitle => '未保存';

  @override
  String get settingsAiChooseProviderBody => '请选择服务商。';

  @override
  String get settingsAiCustomUrlRequiredBody => '自定义服务商需要 API URL。';

  @override
  String get settingsAiKeyRequiredBody => '请输入 API 密钥。';

  @override
  String get settingsAiSavedBody => '你的 AI 设置已保存。';

  @override
  String get settingsAiMissingDetailsTitle => '缺少详细信息';

  @override
  String get settingsAiUrlAndModelRequiredBody => '请输入 API URL 和聊天模型以测试。';

  @override
  String get settingsAiKeyNeededTitle => '需要 API 密钥';

  @override
  String get settingsAiKeyToTestPrivateBody => '请输入你的 API 密钥以测试。保存的密钥不会公开。';

  @override
  String get settingsAiKeyToTestBody => '请输入你的 API 密钥以测试。';

  @override
  String get settingsAiConnectedTitle => '已连接';

  @override
  String get settingsAiConnectedBody => '连接正常。';

  @override
  String get settingsAiTestFailedTitle => '测试失败';

  @override
  String get settingsPreferencesSavedBody => '你的偏好已保存。';

  @override
  String get settingsPasswordNotChangedTitle => '密码未更改';

  @override
  String get settingsOAuthPasswordBody =>
      '此账号通过 Google 或 Apple 登录。请先使用“忘记密码”设置密码。';

  @override
  String get settingsCurrentPasswordIncorrectBody => '当前密码不正确。';

  @override
  String get settingsExportReadyTitle => '导出准备就绪';

  @override
  String get settingsExportReadyBody => '您的数据导出已准备好下载。';

  @override
  String get settingsLinkCopiedTitle => '链接已复制';

  @override
  String get settingsExportClipboardBody =>
      '无法打开您的浏览器，已复制下载链接。请尽快粘贴到浏览器中：链接会过期。';

  @override
  String get settingsExportFailedTitle => '导出失败';

  @override
  String get settingsAccountNotDeletedTitle => '账户未删除';

  @override
  String photoshootPhotoLimit(int max) {
    return '您最多可以添加 $max 张照片。';
  }

  @override
  String get photoshootPhotoLimitTitle => '照片数量限制';

  @override
  String get photoshootAddAtLeastOnePhoto => '请至少添加一张照片。';

  @override
  String get photoshootNoPhotosSelectedTitle => '未选择照片';

  @override
  String get photoshootDescribeLookBody => '描述您想要的造型。';

  @override
  String get photoshootPromptNeededTitle => '需要提示词';

  @override
  String get photoshootConsentFeatureLabel => 'AI 写真';

  @override
  String get photoshootStatusPreparing => '正在处理您的照片';

  @override
  String get photoshootStatusGenerating => '正在生成';

  @override
  String photoshootStatusBatch(int current, int total) {
    return '批次 $current / $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '已完成 $done / $total';
  }

  @override
  String get photoshootGenerationFailedBody => '生成失败。';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready 张已就绪，$failed 张失败。';
  }

  @override
  String get photoshootPartlyDoneTitle => '部分完成';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片已就绪。',
      one: '1 张照片已就绪。',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => '连接已断开。请重试。';

  @override
  String get photoshootCouldNotCancelTitle => '无法取消';

  @override
  String get photoshootRetryFailedTitle => '重试失败';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return '照片 $number 已就绪。';
  }

  @override
  String get photoshootReplacedTitle => '已替换';

  @override
  String get photoshootSavedToGalleryBody => '已保存至您的相册。';

  @override
  String get photoshootSavedTitle => '已保存';

  @override
  String get photoshootNotSavedTitle => '未保存';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '全部 $count 张照片已在您的相册中。',
      one: '1 张照片已在您的相册中。',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '已保存 $saved 张，共 $total 张。';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => '部分照片未保存';

  @override
  String get tryonConsentFeatureLabel => '虚拟试穿';

  @override
  String get tryonAvatarUpdatedBody => '照片已更新。';

  @override
  String get tryonSavedTitle => '已保存';

  @override
  String get tryonUploadFailedTitle => '上传失败';

  @override
  String get tryonChooseGarmentFirstBody => '请先选择一件服装照片。';

  @override
  String get tryonNoGarmentTitle => '无服装';

  @override
  String get tryonWaitForUploadBody => '请等待照片上传完成。';

  @override
  String get tryonStillUploadingTitle => '正在上传中';

  @override
  String get tryonAddYourPhotoFirstBody => '请先添加您的照片。';

  @override
  String get tryonReadyBody => '试穿已准备就绪。';

  @override
  String get tryonFailedTitle => '试穿失败';

  @override
  String get tryonSavedToGalleryBody => '已保存至相册。';

  @override
  String get tryonNotSavedTitle => '未保存';

  @override
  String get calendarEventAddedBody => '已添加日程';

  @override
  String get calendarEventPlannedTitle => '已计划';

  @override
  String get calendarEventSavedBody => '日程已保存';

  @override
  String get calendarSavedTitle => '已保存';

  @override
  String get calendarEventNotSavedTitle => '日程未保存';

  @override
  String get calendarEventRemovedBody => '已移除日程';

  @override
  String get calendarEventDeletedTitle => '已删除';

  @override
  String get calendarEventNotDeletedTitle => '日程未删除';

  @override
  String get calendarOutfitNotLinkedTitle => '穿搭未关联';

  @override
  String get calendarLinkedTitle => '已关联';

  @override
  String get calendarOutfitNotRemovedTitle => '穿搭未移除';

  @override
  String get calendarOutfitRemovedBody => '已移除穿搭';

  @override
  String get calendarDisconnectedBody => '日历已断开连接';

  @override
  String get calendarDisconnectedTitle => '已断开';

  @override
  String get calendarNotDisconnectedTitle => '日历未断开';

  @override
  String get calendarTodayLabel => '今天';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个活动',
      one: '1 个活动',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start 至 $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title，$time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title，$time，已关联穿搭';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '“$title”将被删除。';
  }

  @override
  String get calendarThisAppLabel => '本应用';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '与 $provider 同步暂不可用。你仍可以在这里添加活动。';
  }

  @override
  String get calendarWeekdaySunShort => '日';

  @override
  String get calendarWeekdayMonShort => '一';

  @override
  String get calendarWeekdayTueShort => '二';

  @override
  String get calendarWeekdayWedShort => '三';

  @override
  String get calendarWeekdayThuShort => '四';

  @override
  String get calendarWeekdayFriShort => '五';

  @override
  String get calendarWeekdaySatShort => '六';

  @override
  String get calendarWeekdayMonday => '周一';

  @override
  String get calendarWeekdayTuesday => '周二';

  @override
  String get calendarWeekdayWednesday => '周三';

  @override
  String get calendarWeekdayThursday => '周四';

  @override
  String get calendarWeekdayFriday => '周五';

  @override
  String get calendarWeekdaySaturday => '周六';

  @override
  String get calendarWeekdaySunday => '周日';

  @override
  String get outfitSavedToFavouritesBody => '已添加到收藏';

  @override
  String get outfitRemovedFromFavouritesBody => '已从收藏中移除';

  @override
  String get outfitNotSavedTitle => '未保存';

  @override
  String get outfitLoggedAsWornBody => '已记录为今日穿着。';

  @override
  String get outfitNicePickTitle => '不错的选择';

  @override
  String get outfitRemovedBody => '穿搭已移除。';

  @override
  String get outfitDeletedTitle => '已删除';

  @override
  String get outfitNotDeletedTitle => '未删除';

  @override
  String get outfitDuplicatedBody => '已复制至你的搭配。';

  @override
  String get outfitDuplicatedTitle => '已重复';

  @override
  String get outfitNotDuplicatedTitle => '未重复';

  @override
  String get outfitNotSharedTitle => '未分享';

  @override
  String outfitCollectionReadyBody(String name) {
    return '“$name”已准备就绪。';
  }

  @override
  String get outfitCollectionNotCreatedTitle => '集合未创建';

  @override
  String get outfitCollectionUpdatedBody => '集合已更新。';

  @override
  String get outfitCollectionNotUpdatedTitle => '集合未更新';

  @override
  String get outfitCollectionDeletedBody => '集合已删除。';

  @override
  String get outfitCollectionNotDeletedTitle => '集合未删除';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 套搭配。',
      one: '已添加 1 套搭配。',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => '搭配未添加';

  @override
  String get outfitPreviewNotCreatedTitle => '预览未创建';

  @override
  String get outfitGiveNameBody => '为搭配命名。';

  @override
  String get outfitNameMissingTitle => '名称缺失';

  @override
  String get outfitChooseAtLeastOnePieceBody => '请至少选择一件单品。';

  @override
  String outfitCreatedBody(String name) {
    return '$name 已加入你的搭配。';
  }

  @override
  String get outfitSavedTitle => '已保存';

  @override
  String get wardrobeAddedToFavouritesBody => '已添加至收藏';

  @override
  String get wardrobeRemovedFromFavouritesBody => '已移除收藏';

  @override
  String get wardrobeNotSavedTitle => '未保存';

  @override
  String get wardrobeLoggedAsWornBody => '已记录今日穿着。';

  @override
  String get wardrobeRemovedFromClosetBody => '已从衣橱移除。';

  @override
  String get wardrobeDeletedTitle => '已删除';

  @override
  String get wardrobeNotDeletedTitle => '未删除';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已从衣橱移除 $count 件单品。',
      one: '已从衣橱移除 1 件单品。',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI 衣橱识别';

  @override
  String get itemAddScanJobLabel => '扫描';

  @override
  String get itemAddFoundEarlierBody => '已在先前扫描中发现';

  @override
  String get itemAddLookingAtPhoto => '正在查看你的照片';

  @override
  String get itemAddExtractionFailedBody => '提取失败';

  @override
  String get itemAddJobFailedBody => '任务失败';

  @override
  String get itemAddConnectionLostBody => '连接已断开，请重试。';

  @override
  String get itemAddConnectionLostProcessingBody => '处理过程中连接已断开。';

  @override
  String itemAddGeneratingPiece(int number) {
    return '单品 $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => '单品';

  @override
  String get itemAddNotCancelledTitle => '未取消';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件单品已存入衣橱。',
      one: '1 件单品已存入衣橱。',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '已保存 $saved / $total 件单品。点击保存重试其余部分。';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => '部分单品未保存';

  @override
  String get batchChooseAtLeastOnePhotoBody => '请至少选择一张照片。';

  @override
  String get batchPhotoUnreadableBody => '无法读取此照片。';

  @override
  String get batchNoPhotosReadableBody => '无法读取这些照片，请尝试其他照片。';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片',
      one: '1 张照片',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody => '处理时连接已断开，请重试。';

  @override
  String get batchNotCancelledTitle => '未取消';

  @override
  String get batchPostLinkUnsupportedBody => '不支持帖子链接，请输入个人资料链接。';

  @override
  String get batchLinkSpacesBody => '链接不能包含空格。';

  @override
  String get batchEnterProfileLinkBody => '请输入 Instagram 或 Facebook 的个人资料链接。';

  @override
  String get batchEnterProfileLinkShortBody => '请输入个人资料链接。';

  @override
  String get batchSignInPageNotOpenBody => '登录页面未打开，请重试。';

  @override
  String get batchSignInBrowserBody => '请在浏览器中登录，然后返回 FitCheck AI。';

  @override
  String get batchConnectAccountTitle => '绑定账户';

  @override
  String get batchEnterAuthenticatorCodeBody => '请输入来自身份验证器应用中的代码。';

  @override
  String get batchInstagramSecurityCheckBody => 'Instagram 要求安全验证，请先在浏览器中登录。';

  @override
  String get batchEnterCredentialsAgainBody => '请重新输入用户名和密码。';

  @override
  String get batchSignInFailedBody => '登录失败，请检查用户名和密码。';

  @override
  String get batchSignInToKeepImportingBody => '请登录以继续导入。';

  @override
  String get batchAccountNotConnectedBody => '账户未绑定。';

  @override
  String get batchAccountConnectedTitle => '账户已绑定';

  @override
  String get batchNotConnectedTitle => '未连接';

  @override
  String get batchImportConnectionLostBody => '已丢失导入连接。请刷新以检查状态。';

  @override
  String batchPickUpToBody(int max) {
    return '最多选择 $max 张照片。我们会帮你找出单品。';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count/$total 张照片';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '正在准备第 $done 张照片，共 $count 张';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在 $count 张照片中查找单品',
      one: '在 1 张照片中查找单品',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return '您的 $platform 账号使用了两步验证。请输入来自验证器应用的 6 位代码。';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return '此 $platform 资料为私密，或需登录才能显示其照片。';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '通过 $platform 连接';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已找到 $count 张照片',
      one: '已找到 1 张照片',
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
    return '已处理 $processed/$total · 新增 $added · 等待 $waiting · 跳过 $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return '正在扫描第 $number 张照片';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '下一张为第 $number 张照片';
  }

  @override
  String batchPhotoLabel(int number) {
    return '第 $number 张照片';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 件单品',
      one: '找到 1 件单品',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片已添加到你的衣橱。',
      one: '1 张照片已添加到你的衣橱。',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还有 $count 张工作室照片正在处理中。你可以保存已就绪的内容，或先离开——我们会通知你。',
      one: '还有 1 张工作室照片正在处理中。你可以保存已就绪的内容，或先离开——我们会通知你。',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return '尚未保存：$names。';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces 件单品',
      one: '1 件单品',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos 张照片',
      one: '1 张照片',
    );
    return '$_temp0，来自 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '已选择 $chosen 件。点击单品可跳过。';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在保存 $count 件单品',
      one: '正在保存 1 件单品',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '保存 $count 件单品',
      one: '保存 1 件单品',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => '你的体型档案已保存。';

  @override
  String get bodyProfileSavedTitle => '已保存';

  @override
  String get bodyProfileNotSavedTitle => '未保存';

  @override
  String get bodyProfileSetDefaultBody => '设为默认档案。';

  @override
  String get bodyProfileDeletedBody => '体型档案已删除。';

  @override
  String get bodyProfileDeletedTitle => '已删除';

  @override
  String get bodyProfileNotDeletedTitle => '未删除';

  @override
  String get feedbackNotSentTitle => '未发送';

  @override
  String get feedbackSentBody => '谢谢。我们会仔细阅读每一条反馈，如有需要会回复你。';

  @override
  String get feedbackSentTitle => '反馈已发送';

  @override
  String get recommendUnnamedPiece => '未命名单品';

  @override
  String get recommendEnterCityBody => '输入你的城市，以获取适合当地天气的穿搭建议。';

  @override
  String get recommendWhichCityTitle => '选择城市';

  @override
  String get aiConsentSheetTitle => '将照片共享给 AI 服务';

  @override
  String get aiConsentSheetBody =>
      '为了生成你的试衣和拍摄图片，FitCheck AI 会将你提供的照片（包括面部和身体照片）发送给受信任的第三方 AI 提供商（如 OpenAI 或 Google Gemini）进行处理。对方生成你的图片后，不会在协议范围内使用这些图片训练其模型。照片传输安全，绝不用于广告。';

  @override
  String get aiConsentSheetPermission => '继续即表示你明确授权与这些 AI 提供商共享你的照片用于图像生成。';

  @override
  String get skeletonsLoadMoreFailed => '无法加载更多。';

  @override
  String get jobsPiecesReadyTitle => '你的单品已就绪';

  @override
  String get jobsScanStoppedTitle => '扫描已停止';

  @override
  String get jobsNothingSavedBody => '未保存任何内容。请重试。';

  @override
  String get jobsPhotoUploadFailedBody => '照片上传失败。';

  @override
  String get authGoogleSignInStartFailed => '无法启动 Google 登录。请重试。';

  @override
  String get referralAppliedTitle => '推荐已生效！';

  @override
  String get billingStoreUnavailableBody => '此设备不支持商店购买。';

  @override
  String get billingPurchaseProcessingBody => '购买仍在处理中。请稍后重新打开应用查看套餐。';

  @override
  String get profileAvatarUploadNoUrl => '头像上传未返回图片链接。';

  @override
  String get rewardsDayStreakLabel => '天连续打卡';

  @override
  String rewardsBestStreak(int days) {
    return '最佳 $days 天';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '需要 $permission 权限';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission 权限当前被拒绝。请前往设置开启权限，然后返回重试。';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '第 $step 步，共 4 步';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '移除图片 $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '移除图片 $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points 分';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '发送邮件至 $email。我们将在 24 小时内审核反馈。';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '移除 $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String outfitAddToNamed(String name) {
    return '添加到\"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\"已删除。其中的单品仍保留在你的衣橱中。';
  }

  @override
  String outfitShowAllCount(int count) {
    return '查看全部 $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '今日剩余 $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return '照片 $index 失败';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '已选 $selected/$max';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape 体型 · $tone 肤色';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '删除 $name？';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name 的选项';
  }

  @override
  String profileMostWorn(String name, int count) {
    return '最常穿：$name，$count 次';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label：未设置';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '匹配度 $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '已选 $picked/$max';
  }

  @override
  String recommendRemoveItem(String item) {
    return '移除 $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency优先级';
  }

  @override
  String billingBilledThroughStore(String store) {
    return '此套餐通过 $store 扣费。请在 $store 账户设置中更改或取消。';
  }

  @override
  String billingManageInStore(String store) {
    return '在 $store 中管理';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label：已用 $current/$max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return '约剩 $seconds 秒';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done/$total 张影棚照已就绪';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready/$total 张影棚照已就绪。点击单品可跳过。';
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
  String get profileFieldNotSet => '否';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => '首页';

  @override
  String get tabPhotoshoot => '拍摄';

  @override
  String get tabCloset => '衣橱';

  @override
  String get tabOutfits => '搭配';

  @override
  String get tabMore => '更多';

  @override
  String get actionAddItem => '添加单品';

  @override
  String get actionCreateOutfit => '创建搭配';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionSave => '保存';

  @override
  String get actionRetry => '重试';

  @override
  String get actionDone => '完成';

  @override
  String get actionNext => '下一步';

  @override
  String get actionBack => '返回';

  @override
  String get actionClose => '关闭';

  @override
  String get actionSearch => '搜索';

  @override
  String get actionContinue => '继续';

  @override
  String get stateLoading => '加载中';

  @override
  String get stateErrorTitle => '出错了';

  @override
  String get stateErrorBody => '请重试。如果问题持续，请联系客服。';

  @override
  String get stateOfflineTitle => '无网络连接';

  @override
  String get stateOfflineBody => '请重新连接以同步衣橱并生成搭配。';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsPreferencesSection => '偏好设置';

  @override
  String get settingsPlanBilling => '方案与账单';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsUnits => '度量单位';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsPrivacySection => '隐私与数据';

  @override
  String get settingsAboutSection => '关于';

  @override
  String get settingsSignOut => '退出登录';

  @override
  String get settingsDeleteAccount => '删除账户';

  @override
  String get settingsDeleteAccountTitle => '确定删除账户吗？';

  @override
  String get settingsDeleteAccountBody => '此操作将删除您的衣橱、穿搭、照片和个人资料，且无法撤销。';

  @override
  String get settingsUnitsImperial => '英制 (in, lb)';

  @override
  String get settingsUnitsMetric => '公制 (cm, kg)';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统语言';

  @override
  String get languageSystemBody => 'FitCheck AI 将使用您手机的系统语言。';

  @override
  String get languageSearchHint => '搜索语言';

  @override
  String get languageCurrent => '当前';

  @override
  String get languageReviewNote => '此翻译为新内容，如有不妥请告知我们。';

  @override
  String get languageChanged => '语言已更新';

  @override
  String get paywallTitle => '选择您的方案';

  @override
  String get paywallTrialBadge => '首月免费';

  @override
  String get paywallTrialTitle => 'Pro 首月免费';

  @override
  String get paywallTrialBody => '一次性上传整个衣橱，之后可随时添加单品。';

  @override
  String get paywallFreeForeverTitle => '永久免费';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return '无需绑定银行卡。每月可获得 $uploads 次 AI 上传、$outfits 套穿搭以及每天 $images 张拍摄图片。';
  }

  @override
  String get paywallCtaTrial => '开启免费试用';

  @override
  String paywallCtaUpgrade(String plan) {
    return '升级至 $plan';
  }

  @override
  String get paywallRestore => '恢复购买';

  @override
  String get paywallManage => '管理订阅';

  @override
  String get paywallTerms => '使用条款';

  @override
  String get paywallPrivacy => '隐私政策';

  @override
  String get paywallPerMonth => '每月';

  @override
  String get paywallPerYear => '每年';

  @override
  String get paywallBestValue => '超值推荐';

  @override
  String paywallTrialEligibleOnly(String price) {
    return '仅限新订阅用户免费试用。试用期后，Pro 将以 $price 自动续订，除非在试用期结束前至少 24 小时取消。';
  }

  @override
  String get introTitle => '让衣橱井井有条';

  @override
  String get introBody => '只需拍摄一次衣物，即可获取穿搭灵感、试穿预览以及由现有衣物生成的摄影棚级照片。';

  @override
  String get introStart => '开始使用';

  @override
  String get introHaveAccount => '已有账号';

  @override
  String get introSkip => '跳过';

  @override
  String get authSignIn => '登录';

  @override
  String get authSignUp => '创建账号';

  @override
  String get authEmail => '电子邮箱';

  @override
  String get authPassword => '密码';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authContinueApple => '通过 Apple 继续';

  @override
  String get authContinueGoogle => '通过 Google 继续';

  @override
  String get authOrDivider => '或';

  @override
  String get wardrobeTitle => '衣橱';

  @override
  String get wardrobeEmptyTitle => '衣橱空空如也';

  @override
  String get wardrobeEmptyBody => '添加您的第一件单品，或上传一张衣架全景照。';

  @override
  String get wardrobeAddFirst => '添加第一件单品';

  @override
  String get wardrobeSearchHint => '搜索衣橱';

  @override
  String get categoryTops => '上装';

  @override
  String get categoryBottoms => '下装';

  @override
  String get categoryShoes => '鞋履';

  @override
  String get categoryAccessories => '配饰';

  @override
  String get categoryOuterwear => '外套';

  @override
  String get categorySwimwear => '泳装';

  @override
  String get categoryActivewear => '运动装';

  @override
  String get categoryOther => '其他';

  @override
  String get conditionClean => '干净';

  @override
  String get conditionDirty => '待洗';

  @override
  String get conditionLaundry => '待洗';

  @override
  String get conditionRepair => '待修';

  @override
  String get conditionDonate => '待捐';

  @override
  String get seasonSpring => '春季';

  @override
  String get seasonSummer => '夏季';

  @override
  String get seasonFall => '秋季';

  @override
  String get seasonWinter => '冬季';

  @override
  String get seasonAll => '四季';

  @override
  String get styleCasual => '休闲';

  @override
  String get styleFormal => '正式';

  @override
  String get styleBusiness => '商务';

  @override
  String get styleSporty => '运动';

  @override
  String get styleBohemian => '波西米亚';

  @override
  String get styleStreetwear => '街头';

  @override
  String get styleVintage => '复古';

  @override
  String get styleMinimalist => '极简';

  @override
  String get styleRomantic => '浪漫';

  @override
  String get styleEdgy => '前卫';

  @override
  String get stylePreppy => '学院';

  @override
  String get styleArtsy => '艺术';

  @override
  String get styleClassic => '经典';

  @override
  String get styleElegant => '优雅';

  @override
  String get styleOther => '其他';

  @override
  String get occasionWork => '职场';

  @override
  String get occasionDateNight => '约会';

  @override
  String get occasionTravel => '旅行';

  @override
  String get occasionWedding => '婚礼';

  @override
  String get occasionGym => '健身';

  @override
  String get occasionWeekend => '周末';

  @override
  String get occasionParty => '派对';

  @override
  String get occasionInterview => '面试';

  @override
  String get colorBlack => '黑色';

  @override
  String get colorWhite => '白色';

  @override
  String get colorGrey => '灰色';

  @override
  String get colorNavy => '藏青色';

  @override
  String get colorBrown => '棕色';

  @override
  String get colorRed => '红色';

  @override
  String get colorBlue => '蓝色';

  @override
  String get colorGreen => '绿色';

  @override
  String get colorPink => '粉色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorYellow => '黄色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorBeige => '米色';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count天前',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count周前',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个月前',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年前',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => '喜欢 FitCheck AI 吗？';

  @override
  String get ratingPromptBody => '给个好评，帮助他人发现自己的风格。';

  @override
  String get ratingPromptYes => '去评分';

  @override
  String get ratingPromptNo => '以后再说';

  @override
  String get closetNoMatchesTitle => '没有匹配单品';

  @override
  String get closetNoMatchesBody => '尝试减少筛选条件或更换搜索词。';

  @override
  String get closetClearFilters => '清除筛选';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件单品',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => '正在加载单品';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选$count件',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => '删除选中';

  @override
  String get closetCancelSelection => '取消选择';

  @override
  String get closetCloseSearch => '关闭搜索';

  @override
  String get closetShowGrid => '网格视图';

  @override
  String get closetShowList => '列表视图';

  @override
  String get closetShowRows => '行视图';

  @override
  String get closetStatsTitle => '衣橱统计';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '删除 $count 件单品？',
      one: '删除该单品？',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => '使用这些单品的搭配将受影响。';

  @override
  String get closetSortBy => '排序方式';

  @override
  String get closetFavourites => '收藏夹';

  @override
  String get closetFavourite => '收藏';

  @override
  String get closetUnfavourite => '取消收藏';

  @override
  String get closetWoreToday => '今天穿过';

  @override
  String closetWornTimes(int count) {
    return '已穿 $count 次';
  }

  @override
  String get closetCategoryLabel => '类别';

  @override
  String get closetUseCaseLabel => '场合';

  @override
  String get closetAnyUseCase => '全部';

  @override
  String get closetOtherUseCase => '其他场合';

  @override
  String get closetOtherUseCaseHint => '例如：早午餐';

  @override
  String get closetUseUseCase => '使用此场合';

  @override
  String get closetClearAll => '全部清除';

  @override
  String get sortNewest => '最新优先';

  @override
  String get sortOldest => '最旧优先';

  @override
  String get sortName => '名称 (A–Z)';

  @override
  String get sortMostWorn => '穿着频率最高';

  @override
  String get useCaseInformal => '休闲';

  @override
  String get useCaseDate => '约会';

  @override
  String get useCaseDinner => '晚餐';

  @override
  String get useCaseLunch => '午餐';

  @override
  String get actionSelect => '选择';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionFilter => '筛选';

  @override
  String get actionSort => '排序';

  @override
  String get actionAll => '全部';

  @override
  String get dashboardStartClosetTitle => '建立衣橱';

  @override
  String get dashboardStartClosetBody => '拍摄几件单品，我们将为您自动打标。';

  @override
  String get dashboardPieces => '件单品';

  @override
  String get dashboardOutfits => '套穿搭';

  @override
  String get dashboardDayStreak => '天连续记录';

  @override
  String dashboardAddedThisMonth(int count) {
    return '本月新增 $count 件';
  }

  @override
  String dashboardBestStreak(int count) {
    return '最高纪录 $count 天';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件收藏',
      one: '1 件收藏',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 套保存穿搭',
      one: '1 套保存穿搭',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return '最常穿：$name，$count 次';
  }

  @override
  String get setupSkip => '跳过设置';

  @override
  String get setupWhoTitle => '为您打造造型';

  @override
  String get setupWhoBody => '设置试穿模特，可在个人资料中随时更改。';

  @override
  String get setupStyleTitle => '您常穿的风格？';

  @override
  String get setupStyleBody => '任选其一，我们将以此为您推荐穿搭。';

  @override
  String get setupClosetTitle => '添加首批单品';

  @override
  String get setupClosetBody => '拍摄几件衣服或一堆衣物，我们将为您自动抠图并归档。';

  @override
  String get setupAddClothes => '添加衣物';

  @override
  String get setupStylesLabel => '风格';

  @override
  String get setupOccasionsLabel => '场合';

  @override
  String get setupSkipStep => '跳过';

  @override
  String get setupLater => '稍后';

  @override
  String get setupSaveError => '保存失败';

  @override
  String get genderWomen => '女装';

  @override
  String get genderMen => '男装';

  @override
  String get genderNonBinary => '非二元性别';

  @override
  String get genderPreferNotToSay => '保密';

  @override
  String get outfitEmptyTitle => '暂无穿搭';

  @override
  String get outfitEmptyBody => '从衣橱中挑选单品并保存你的穿搭。';

  @override
  String get outfitNoMatchesTitle => '无匹配穿搭';

  @override
  String get outfitSearchHint => '搜索穿搭';

  @override
  String get outfitLoading => '正在加载穿搭';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 套穿搭',
      one: '1 套穿搭',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => '风格与季节';

  @override
  String get outfitCollections => '系列';

  @override
  String get outfitDuplicate => '复制';

  @override
  String get outfitDeleteTitle => '删除此穿搭？';

  @override
  String get outfitDeleteBody => '单品将保留在你的衣橱中。';

  @override
  String get outfitDrafts => '草稿';

  @override
  String get outfitDraft => '草稿';

  @override
  String get filterStyle => '风格';

  @override
  String get filterSeason => '季节';

  @override
  String get itemDetailDeleteTitle => '删除此单品？';

  @override
  String get itemDetailDeleteBody => '使用该单品的穿搭将不再包含它。';

  @override
  String get itemAddFavourite => '加入收藏';

  @override
  String itemSize(String size) {
    return '尺码 $size';
  }

  @override
  String get itemColours => '颜色';

  @override
  String get itemMaterial => '材质';

  @override
  String get itemPattern => '图案';

  @override
  String get itemUseCases => '适用场景';

  @override
  String get itemKeptIn => '存放位置';

  @override
  String get itemPrice => '价格';

  @override
  String get itemBought => '购买日期';

  @override
  String get itemTags => '标签';

  @override
  String get itemAdded => '添加日期';

  @override
  String get itemTimesWornLabel => '穿着次数';

  @override
  String get itemLastWornLabel => '上次穿着';

  @override
  String get itemNeverWorn => '从未穿着';

  @override
  String get authEntryBody => 'FitCheck AI 为您的每一件单品提供穿搭建议。规划造型、虚拟试穿、拍摄记录。';

  @override
  String get authCreateCloset => '创建您的衣橱';

  @override
  String get authWelcomeBack => '欢迎回来';

  @override
  String get authSignInBody => '登录以打开您的衣橱。';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authCreateClosetBody => '只需一分钟。首批单品免费添加。';

  @override
  String get authName => '姓名';

  @override
  String get authConfirmPassword => '确认密码';

  @override
  String get authReferralCode => '推荐码（选填）';

  @override
  String get authResetTitle => '重置密码';

  @override
  String get authResetBody => '我们将发送一封邮件，点击链接即可设置新密码。';

  @override
  String get authSendResetLink => '发送重置链接';

  @override
  String get authBackToSignIn => '返回登录';

  @override
  String get authEnterEmail => '输入邮箱';

  @override
  String get authEnterValidEmail => '请输入有效邮箱';

  @override
  String get authEnterPassword => '输入密码';

  @override
  String get authPasswordTooShort => '至少 6 位字符';

  @override
  String get authShowPassword => '显示密码';

  @override
  String get authHidePassword => '隐藏密码';

  @override
  String get authNewHere => '新用户？';

  @override
  String authConfirmEmail(String email) {
    return '请在登录前验证 $email。请检查您的收件箱。';
  }

  @override
  String get authResendEmail => '重新发送';

  @override
  String get authResendingEmail => '发送中…';

  @override
  String get authPasswordsDoNotMatch => '密码不匹配';

  @override
  String get authEnterName => '输入姓名';

  @override
  String get authChoosePassword => '设置密码';

  @override
  String get authHaveAccount => '已有账户？';

  @override
  String get authCodeAccepted => '验证码已接受';

  @override
  String get authCodeNotFound => '未找到验证码';

  @override
  String authReferralFrom(String name) {
    return '来自 $name。你们都将获得一个月免费会员。';
  }

  @override
  String get authReferralInvalid => '无法找到此代码。';

  @override
  String authResetSent(String email) {
    return '已发送至 $email。请在此手机上打开链接。';
  }

  @override
  String get introSlide1Title => '一键拍摄衣橱';

  @override
  String get introSlide1Body => '拍下衣物堆，每件单品都会自动抠图并归档。';

  @override
  String get introSlide2Title => '穿搭更高效';

  @override
  String get introSlide2Body => '根据您的日程和天气，从现有衣物中匹配穿搭。';

  @override
  String get introSlide3Title => '穿前先预览';

  @override
  String get introSlide3Body => '在您的照片上试穿，或像拍摄大片一样展示造型。';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsTemperature => '温度单位';

  @override
  String get settingsEmailUpdates => '邮件更新';

  @override
  String get settingsEmailUpdatesBody => '接收新闻与穿搭建议';

  @override
  String get settingsOutfitReminders => '穿搭提醒';

  @override
  String get settingsOutfitRemindersBody => '提醒您记录每日穿搭';

  @override
  String get settingsWeeklySummary => '每周总结';

  @override
  String get settingsWeeklySummaryBody => '您的每周穿搭回顾';

  @override
  String get settingsStyleSection => '风格';

  @override
  String get settingsPreferredStyles => '偏好风格';

  @override
  String get settingsPreferredColours => '偏好颜色';

  @override
  String get settingsNoneChosen => '未选择';

  @override
  String get settingsPlanAiSection => '方案与 AI';

  @override
  String get settingsPlanBillingBody => '方案、用量与升级';

  @override
  String get settingsPlanUsageBody => '方案与用量';

  @override
  String get settingsInviteFriends => '邀请好友';

  @override
  String get settingsInviteFriendsBody => '每邀请一位好友加入即可获得一个月免费会员';

  @override
  String get settingsAiProvider => 'AI 服务商';

  @override
  String get settingsAiProviderBody => '使用自定义模型进行标签识别与图像处理';

  @override
  String get settingsAppVersion => '应用版本';

  @override
  String get settingsPrivacyTerms => '隐私政策与条款';

  @override
  String get settingsReportProblem => '反馈问题';

  @override
  String get settingsChangePassword => '修改密码';

  @override
  String get settingsExportData => '导出数据';

  @override
  String get settingsExportBody => '我们将为您生成包含所有已保存内容的文件并打开下载链接。';

  @override
  String get settingsExportAction => '导出';

  @override
  String get settingsCurrentPassword => '当前密码';

  @override
  String get settingsNewPassword => '新密码';

  @override
  String get settingsConfirmNewPassword => '确认新密码';

  @override
  String get settingsEnterCurrentPassword => '请输入当前密码';

  @override
  String get settingsEnterNewPassword => '请输入新密码';

  @override
  String get settingsPasswordMin8 => '至少使用 8 个字符';

  @override
  String get settingsPasswordNeedsUpper => '包含大写字母';

  @override
  String get settingsPasswordNeedsLower => '包含小写字母';

  @override
  String get settingsPasswordNeedsDigit => '包含数字';

  @override
  String get settingsPasswordsNoMatch => '密码不匹配';

  @override
  String get settingsChangeAction => '修改';

  @override
  String get itemAddSnapTitle => '拍摄单品';

  @override
  String get itemAddSnapBody => '我们将识别照片中的每一件单品，并为您生成清晰的摄影棚级图像。';

  @override
  String get itemAddCamera => '拍照';

  @override
  String get itemAddGallery => '从相册选择';

  @override
  String get itemAddOtherWays => '其他添加方式';

  @override
  String get itemAddSeveral => '批量添加照片';

  @override
  String get itemAddSeveralBody => '一次最多 50 张';

  @override
  String get itemAddImportProfile => '从个人资料导入';

  @override
  String get itemAddImportProfileBody => 'Instagram 或 Facebook';

  @override
  String get itemAddEnterDetails => '手动输入详情';

  @override
  String get itemAddEnterDetailsBody => '无需照片';

  @override
  String get itemManualIntro => '只需输入名称，其他信息可稍后补充。';

  @override
  String get itemManualNameHint => '例如：蓝色纯棉T恤';

  @override
  String get itemManualEnterName => '输入名称';

  @override
  String get itemManualNotes => '备注';

  @override
  String get itemManualBrand => '品牌';

  @override
  String get itemManualSize => '尺码';

  @override
  String get itemManualEnterNumber => '输入数字';

  @override
  String get itemManualSavePiece => '保存单品';

  @override
  String get itemManualSaving => '保存中';

  @override
  String get itemManualSavedTitle => '已保存';

  @override
  String itemManualSavedBody(String name) {
    return '$name 已存入您的衣橱。';
  }

  @override
  String get itemManualNotSaved => '未保存';

  @override
  String get itemManualAddUseCase => '添加用途';

  @override
  String get itemManualAddUseCaseAction => '添加用途';

  @override
  String get itemPhotos => '照片';

  @override
  String get itemAddPhotos => '添加照片';

  @override
  String get itemNoPhotoYet => '暂无照片。您可以直接保存。';

  @override
  String get itemRemovePhoto => '移除照片';

  @override
  String get itemRemovePiece => '移除单品';

  @override
  String get filterConditionLabel => '成色';

  @override
  String get photoshootStepPhotos => '照片';

  @override
  String get photoshootStepSetup => '设置';

  @override
  String get photoshootStepCreating => '生成中';

  @override
  String get photoshootStepResults => '结果';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return '第 $current 步，共 $total 步：$name';
  }

  @override
  String get photoshootOneFailed => '一张照片上传失败，请在下方重试。';

  @override
  String photoshootManyFailed(int count) {
    return '$count 张照片上传失败，请在下方逐一重试。';
  }

  @override
  String get photoshootFormat => '格式';

  @override
  String get photoshootHowMany => '数量';

  @override
  String get photoshootYourPrompt => '你的提示词';

  @override
  String get photoshootPromptHint => '屋顶黄金时刻，亚麻衬衫';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '生成 $count 张照片',
      one: '生成 1 张照片',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '张照片',
      one: '张照片',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => '无法查询今日限额。';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan 计划：今日剩余 $remaining/$limit';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => '免费';

  @override
  String get photoshootGallery => '图库';

  @override
  String get photoshootUseCamera => '使用相机';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '移除照片 $number';
  }

  @override
  String get photoshootNoPhotosTitle => '未生成照片';

  @override
  String get photoshootNoPhotosBody => '拍摄未生成图像，请重试。';

  @override
  String get photoshootNewStyle => '新风格';

  @override
  String get photoshootNewPhotos => '新照片';

  @override
  String photoshootOpenPhoto(int number) {
    return '打开照片 $number';
  }

  @override
  String get photoshootReportPhoto => '举报照片';

  @override
  String get photoshootSaveToGallery => '保存到图库';

  @override
  String get actionUpgrade => '升级';

  @override
  String get referralLimitTitle => '今日额度已用尽';

  @override
  String get referralLimitBody => '免费额度将于明日重置。邀请好友，双方均可免费获得一个月 Pro 会员。';

  @override
  String get referralLimitRefer => '邀请好友';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => '交友软件';

  @override
  String get photoshootUsePortfolio => '作品集';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => '审美风格';

  @override
  String get photoshootUseCustom => '自定义提示词';

  @override
  String get photoshootDescLinkedin => '专业职场形象照';

  @override
  String get photoshootDescDating => '轻松、温暖、自然';

  @override
  String get photoshootDescPortfolio => '时尚大片，高级感';

  @override
  String get photoshootDescInstagram => '生活方式，社交分享';

  @override
  String get photoshootDescAesthetic => '情绪感，艺术风格';

  @override
  String get photoshootDescCustom => '描述你想要的风格';

  @override
  String get aspectSquare => '正方形';

  @override
  String get aspectPortrait => '竖向';

  @override
  String get aspectLandscape => '横向';

  @override
  String get aspectTall => '长条形';

  @override
  String get aspectWide => '宽幅';

  @override
  String get tryOnAppBar => '虚拟试穿';

  @override
  String get tryOnYourPhoto => '你的照片';

  @override
  String get tryOnGarment => '服装';

  @override
  String get tryOnUploadingPhoto => '正在上传照片';

  @override
  String get tryOnAddPhotoPrompt => '添加一张全身照';

  @override
  String get tryOnBodyPhotoHint => '全身照效果最佳';

  @override
  String get tryOnAddPhoto => '添加照片';

  @override
  String get tryOnChangePhoto => '更换照片';

  @override
  String get tryOnPhotoLoadFailed => '无法加载照片';

  @override
  String get tryOnChooseGarment => '选择服装照片';

  @override
  String get tryOnChooseOneGarment => '选择一张服装照片';

  @override
  String get tryOnGarmentHint => '平铺或挂拍效果最佳';

  @override
  String get tryOnChange => '更换';

  @override
  String get tryOnCamera => '相机';

  @override
  String get tryOnRemove => '移除';

  @override
  String get tryOnLookTitle => '造型';

  @override
  String get tryOnStyle => '风格';

  @override
  String get tryOnBackground => '背景';

  @override
  String get tryOnPose => '姿势';

  @override
  String get tryOnDressingUp => '正在为你试穿，大约需要半分钟。';

  @override
  String get tryOnEmptyResult => '试穿结果将显示在此';

  @override
  String get tryOnReportImage => '举报图片';

  @override
  String get tryOnCreating => '生成中';

  @override
  String get tryOnTryAgain => '重试';

  @override
  String get tryOnCreate => '生成试穿';

  @override
  String get tryOnBackgroundStudioWhite => '摄影棚白';

  @override
  String get tryOnBackgroundStudioGrey => '摄影棚灰';

  @override
  String get tryOnBackgroundUrban => '城市街头';

  @override
  String get tryOnBackgroundNature => '自然风光';

  @override
  String get tryOnBackgroundMinimal => '极简风格';

  @override
  String get tryOnPoseFront => '正面站立';

  @override
  String get tryOnPoseSide => '侧面站立';

  @override
  String get tryOnPoseWalking => '行走姿态';

  @override
  String get dashboardGreetingMorning => '早上好';

  @override
  String get dashboardGreetingAfternoon => '下午好';

  @override
  String get dashboardGreetingEvening => '晚上好';

  @override
  String get dashboardWelcome => '欢迎';

  @override
  String get dashboardOpenProfile => '打开个人资料';

  @override
  String get dashboardRailToday => '今日';

  @override
  String get dashboardRailRecently => '最近';

  @override
  String get dashboardActivityEmpty => '新单品和穿搭将显示在此。';

  @override
  String get quickAddPiece => '添加单品';

  @override
  String get quickAddPieceBody => '拍照并添加标签';

  @override
  String get quickBuildOutfit => '搭配穿搭';

  @override
  String get quickBuildOutfitBody => '混合搭配你的单品';

  @override
  String get quickForYou => '为你推荐';

  @override
  String get quickForYouBody => '今日精选';

  @override
  String get quickPlanWeek => '一周规划';

  @override
  String get quickPlanWeekBody => '按日期规划穿搭';

  @override
  String get referralBannerUrgent => '次数不足？邀请好友获取。';

  @override
  String get referralBannerTitle => '赠送一个月，获赠一个月。';

  @override
  String get referralBannerBody => '您和好友各可获得一个月 Pro 会员。';

  @override
  String get referralBannerDismiss => '一周内不再显示';

  @override
  String get referralBannerShare => '分享邀请';

  @override
  String get referralBannerCopy => '复制链接';

  @override
  String get itemEditPieceTitle => '编辑单品';

  @override
  String get itemEditDescriptionLabel => '描述';

  @override
  String get itemEditNotSaved => '未保存';

  @override
  String get itemEditSavedTitle => '已保存';

  @override
  String get itemEditSavedBody => '修改已保存。';

  @override
  String get itemEditSavedStalePhotos => '已保存 — 照片可能已过时';

  @override
  String get itemEditRemovePieceHint => '从单品页面删除此件。';

  @override
  String get itemEditNoPhotos => '暂无照片。请从相册或相机添加。';

  @override
  String get itemEditKeepPhoto => '保留照片';

  @override
  String get itemEditRemoved => '已删除';

  @override
  String get itemEditAddUseCaseAction => '添加';

  @override
  String get statsNoStatsTitle => '暂无统计';

  @override
  String get statsNoStatsBody => '添加几件单品，即可查看您的衣橱构成。';

  @override
  String get statsByCategory => '按类别';

  @override
  String get statsTotalValue => '总价值';

  @override
  String get statsMostWorn => '最常穿';

  @override
  String get statsLeastWorn => '待穿戴';

  @override
  String get statsUnnamedPiece => '未命名单品';

  @override
  String get jobsTitle => '扫描';

  @override
  String get jobsEmptyTitle => '暂无扫描';

  @override
  String get jobsEmptyBody => '拍摄单品并发送至后台，进度将在此显示。';

  @override
  String get jobsNotCancelled => '未取消';

  @override
  String get jobsResume => '继续';

  @override
  String get jobsReview => '查看';

  @override
  String get jobsStop => '停止';

  @override
  String get jobsDismiss => '忽略';

  @override
  String get reportTitle => '举报内容';

  @override
  String reportIntro(String contentType) {
    return '请告诉我们此 $contentType 有什么问题。我们的团队会审核每一份举报。';
  }

  @override
  String get reportReasonInappropriate => '不当或冒犯性内容';

  @override
  String get reportReasonNudity => '裸露或色情内容';

  @override
  String get reportReasonHarassment => '骚扰或辱骂';

  @override
  String get reportReasonImpersonation => '冒充他人';

  @override
  String get reportReasonOther => '其他';

  @override
  String get reportDetailsLabel => '补充详情（可选）';

  @override
  String get reportSubmit => '提交举报';

  @override
  String get reportSubmittedTitle => '举报已提交';

  @override
  String get reportSubmittedBody => '感谢您的反馈。我们的团队将审核此内容。';

  @override
  String get reportFailedTitle => '无法发送举报';

  @override
  String get reportFailedBody => '请重试。';

  @override
  String get reportContentTryOnImage => 'AI 试穿图';

  @override
  String get reportContentSharedOutfit => '分享的穿搭';

  @override
  String get reportContentPhotoshootImage => 'AI 摄影图';

  @override
  String get sharedOutfitTitle => '分享的穿搭';

  @override
  String get sharedOutfitHideTooltip => '隐藏此穿搭';

  @override
  String get sharedOutfitReportTooltip => '举报此穿搭';

  @override
  String get sharedOutfitHideTitle => '隐藏此穿搭？';

  @override
  String get sharedOutfitHideBody => '它将在本设备上隐藏。您也可以举报，以便我们的团队审核并移除。';

  @override
  String get sharedOutfitHideAction => '隐藏';

  @override
  String get sharedOutfitHiddenInfo => '此穿搭将不再在本设备上显示。';

  @override
  String get sharedOutfitHiddenToast => '穿搭已隐藏';

  @override
  String get sharedOutfitMissingTitle => '此穿搭已不存在';

  @override
  String get sharedOutfitMissingBody => '它可能已被移除，或者链接有误。';

  @override
  String get sharedOutfitHiddenStateTitle => '您已隐藏此穿搭';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return '如果内容不当，请通过隐私与条款进行举报，或发送邮件至 $email。';
  }

  @override
  String get sharedOutfitCtaTitle => '喜欢这个造型？';

  @override
  String get sharedOutfitCtaBody => '用您自己的衣橱打造同款穿搭。';

  @override
  String get sharedOutfitCtaButton => '获取 FitCheck AI';

  @override
  String get errorTitle => '错误';

  @override
  String get errorUnknown => '发生未知错误';

  @override
  String get errorNoConnection => '没有网络连接，请检查网络';

  @override
  String get errorTimeout => '请求超时，请重试';

  @override
  String get errorServerError => '服务器出错，请重试';

  @override
  String get errorBadGateway => '服务暂不可用，请重试';

  @override
  String get errorServiceUnavailable => '服务暂时不可用，请稍后重试';

  @override
  String get errorInternalError => '出错了，请重试';

  @override
  String get errorUnauthorized => '请先登录';

  @override
  String get errorForbidden => '你无权访问该内容';

  @override
  String get errorSessionExpired => '登录已过期，请重新登录';

  @override
  String get errorInvalidCredentials => '邮箱或密码不正确';

  @override
  String get errorTokenRefreshFailed => '无法更新登录状态，请重新登录';

  @override
  String get errorRequestCancelled => '请求已取消';

  @override
  String get errorInvalidFormat => '不支持该文件格式';

  @override
  String get errorFileTooLarge => '文件过大';

  @override
  String get errorUploadFailed => '上传失败，请重试';

  @override
  String get errorCacheCorrupted => '已保存数据损坏并重置';

  @override
  String get errorCacheNotFound => '暂无保存内容';

  @override
  String get errorUserNotFound => '找不到该账号';

  @override
  String get errorItemNotFound => '该商品已不存在';

  @override
  String get errorOutfitNotFound => '该搭配已不存在';

  @override
  String get rewardsTitle => '奖励';

  @override
  String get rewardsNoAchievementsTitle => '暂无成就';

  @override
  String get rewardsNoAchievementsBody => '添加衣物并规划搭配以解锁首个成就';

  @override
  String get rewardsEmptyLeaderboardTitle => '暂无排行榜';

  @override
  String get rewardsEmptyLeaderboardBody => '规划搭配以获取积分并登上排行榜';

  @override
  String get legalViewPrivacyPolicy => '查看隐私政策';

  @override
  String get aiConsentAgree => '同意并继续';

  @override
  String get aiConsentNotNow => '暂不';

  @override
  String get imageViewerCloseTooltip => '关闭图片查看器';

  @override
  String get updateReadyTitle => '更新就绪';

  @override
  String get updateReadyBody => '重启 FitCheck AI 以应用最新改进。';

  @override
  String get permissionCameraUsage => 'FitCheck AI 需要相机权限，以拍摄您的穿搭和衣橱物品。';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI 需要访问您的照片图库，以选择您的穿搭和衣橱物品图片。';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI 需要将 AI 生成的穿搭照片保存至您的照片图库。';

  @override
  String get wardrobeSomePhotosSkipped => '部分照片已跳过';

  @override
  String get wardrobePhotosNotAdded => '照片未添加';

  @override
  String get wardrobePhotoNotAdded => '照片未添加';

  @override
  String get wardrobeNotStartedTitle => '未开始';

  @override
  String get wardrobeNoRoomTitle => '已满';

  @override
  String get wardrobeAddPhotosSemantic => '添加照片';

  @override
  String get batchAddTileLabel => '添加';

  @override
  String get batchProfileLinkLabel => '主页链接';

  @override
  String get wardrobeImportFromProfileTitle => '从主页导入';

  @override
  String get wardrobeAddSeveralPhotosTitle => '添加多张照片';

  @override
  String get wardrobeClearAction => '清除';

  @override
  String get wardrobeRefreshTooltip => '刷新';

  @override
  String get batchNoPhotosYetTitle => '暂无照片';

  @override
  String get batchChoosePhotosAction => '选择照片';

  @override
  String get batchWeFindEachPieceBody => '我们会为每件单品生成一张精修图。';

  @override
  String get batchPreparingPhotosSemantic => '正在准备照片';

  @override
  String get batchPhotosProcessedSemantic => '已处理照片';

  @override
  String get batchPasteProfileLinkTitle => '粘贴主页链接';

  @override
  String get batchPasteProfileLinkBody =>
      '一个公开的 Instagram 或 Facebook 主页。我们将扫描其中的照片，由您选择哪些放入衣橱。';

  @override
  String get batchClearLinkTooltip => '清除链接';

  @override
  String get batchStartingButton => '即将开始';

  @override
  String get batchStartImportAction => '开始导入';

  @override
  String get batchReviewEveryPhotoTitle => '每张照片均需您确认';

  @override
  String get batchReviewEveryPhotoBody => '经您确认后方可添加。';

  @override
  String get batchPrivateProfilesTitle => '私密资料';

  @override
  String get batchPrivateProfilesBody => '连接你的账号。Instagram 还需要用户名和密码。';

  @override
  String get batchUseAnotherLinkAction => '使用其他链接';

  @override
  String get batchSignInNeededTitle => '需要登录';

  @override
  String get batchEnterYourCodeTitle => '输入验证码';

  @override
  String get batchUseUsernamePasswordAction => '使用用户名和密码';

  @override
  String get batchAlreadyConnectedAction => '我已在浏览器中连接';

  @override
  String get batchEnterCodeAction => '输入验证码';

  @override
  String get batchTryAnotherWayAction => '尝试其他方式';

  @override
  String get batchLiveStatus => '在线';

  @override
  String get batchReconnectingStatus => '正在重连';

  @override
  String get batchSignInToInstagramTitle => '登录 Instagram';

  @override
  String get batchUsernameLabel => '用户名';

  @override
  String get batchCodeIfTwoStepLabel => '如果启用了两步验证，请输入验证码';

  @override
  String get batchAuthenticatorCodeBody => '使用验证器应用中的 6 位验证码。验证码会快速更新。';

  @override
  String get batchVerifyAction => '验证';

  @override
  String get batchFindingPhotosTitle => '查找照片';

  @override
  String get batchImportPausedTitle => '导入已暂停';

  @override
  String get batchProcessingPhotosTitle => '正在处理照片';

  @override
  String get batchWaitingNextPhoto => '等待下一张照片';

  @override
  String get batchCancelImportAction => '取消导入';

  @override
  String get batchNoPiecesInPhotoBody => '未在此照片中发现衣物。';

  @override
  String get batchEditPieceColoursLabel => '颜色，用逗号分隔';

  @override
  String get batchAddToClosetAction => '加入衣橱';

  @override
  String get batchSkipPhotoAction => '跳过此照片';

  @override
  String get batchImportCompleteTitle => '导入完成';

  @override
  String get batchImportFailedTitle => '导入失败';

  @override
  String get batchImportCancelledTitle => '导入已取消';

  @override
  String get batchImportErrorBody => '导入过程中出现错误。';

  @override
  String get batchNothingMoreImportedBody => '此资料中没有更多可导入的内容。';

  @override
  String get batchViewClosetAction => '查看衣橱';

  @override
  String get batchStartOverAction => '重新开始';

  @override
  String get wardrobeAddPieceTitle => '添加单品';

  @override
  String get wardrobeAddDetailsTitle => '添加详情';

  @override
  String get wardrobeScanningTitle => '正在扫描';

  @override
  String get batchReviewPiecesTitle => '查看单品';

  @override
  String get wardrobeGalleryAction => '相册';

  @override
  String get wardrobeCameraAction => '拍照';

  @override
  String get wardrobeNewBadge => '新';

  @override
  String get wardrobeRemovePhotoTooltip => '删除照片';

  @override
  String get batchRunInBackgroundTooltip => '后台运行';

  @override
  String get batchStepOneOfTwo => '第1步，共2步';

  @override
  String get batchStepTwoOfTwo => '第2步，共2步';

  @override
  String get batchUploadingPhotosTitle => '正在上传照片';

  @override
  String get batchFindingPiecesTitle => '正在识别单品';

  @override
  String get batchMakingStudioPhotosTitle => '正在制作产品图';

  @override
  String get batchStoppedLabel => '已停止';

  @override
  String get batchFindingPiecesStoppedTitle => '识别单品已停止';

  @override
  String get batchCancelledLabel => '已取消';

  @override
  String get batchAllDoneTitle => '全部完成';

  @override
  String get batchOpeningPiecesBody => '正在打开你的单品';

  @override
  String get batchNothingSavedBody => '没有保存任何内容。';

  @override
  String get batchFindingPiecesFailedBody => '识别单品失败。';

  @override
  String get batchFindingPiecesStoppedEarlyBody => '识别单品提前停止。';

  @override
  String get batchStopFindingPiecesTitle => '停止识别单品？';

  @override
  String get batchStopFindingPiecesBody =>
      '扫描将停止且不会保存任何内容。已识别的单品会保留在“活动”中，直到你手动关闭它们。';

  @override
  String get batchKeepGoingAction => '继续';

  @override
  String get batchTryAgainAction => '重试';

  @override
  String get batchBackToPhotosAction => '返回照片';

  @override
  String get batchSkipAllAction => '全部跳过';

  @override
  String get batchIncludeAllAction => '全选';

  @override
  String get batchNoPiecesFoundTitle => '未找到衣物';

  @override
  String get batchNoPiecesFoundBody => '我们未在照片中检测到任何衣物。';

  @override
  String get batchChooseOtherPhotosAction => '选择其他照片';

  @override
  String get batchUseCaseHelper => '已添加到你保存的每件衣物。';

  @override
  String get batchDiscardPiecesTitle => '丢弃这些衣物？';

  @override
  String get batchDiscardPiecesBody => '此批次中的任何衣物都未保存。';

  @override
  String get batchKeepAction => '保留';

  @override
  String get batchDiscardAction => '丢弃';

  @override
  String get batchRemovePieceTitle => '移除这件衣物？';

  @override
  String get batchRemovePieceBody => '它未保存到你的衣橱。';

  @override
  String get batchRemoveAction => '移除';

  @override
  String get batchChoosePiecesToSave => '选择要保存的衣物';

  @override
  String get batchDiscardAllAction => '全部丢弃';

  @override
  String get batchNothingSavedRetryBody => '未保存任何内容。请重试。';

  @override
  String get batchNotSavedTitle => '未保存';

  @override
  String get batchSavingLabel => '正在保存';

  @override
  String get batchSendToBackgroundAction => '转到后台';

  @override
  String get batchStillWorkingMessage => '正在处理。衣物就绪时会通知你。';

  @override
  String get batchRunningInBackgroundTitle => '正在后台运行';

  @override
  String get batchStudioPhotosStoppedBody => '影棚照片提前停止。你仍可保存这些衣物。';

  @override
  String get batchTapPieceToSkip => '点击衣物以跳过。';

  @override
  String get batchStudioPhotosOnWayBody => '影棚照片还在路上。你可以离开——我们会通知你。';

  @override
  String get batchLeaveAction => '离开';

  @override
  String get batchPeopleInPhotosTitle => '照片中的人';

  @override
  String get batchIncludeAction => '包含';

  @override
  String get batchSkipAction => '跳过';

  @override
  String get batchYourPhotoIsUsedLabel => '使用你的照片';

  @override
  String get batchMakingStudioPhotoLabel => '正在生成影棚照片';

  @override
  String get batchNoStudioPhotoBody => '无影棚照片。使用你的照片。';

  @override
  String get batchEnterDetailsYourselfAction => '手动填写';

  @override
  String get batchChooseAnotherPhotoAction => '选择其他照片';

  @override
  String get batchConnectionLostTitle => '连接已断开';

  @override
  String get batchConnectionLostBody => '请检查网络连接，然后重试。';

  @override
  String get batchDailyLimitTitle => '已达每日上限';

  @override
  String get batchDailyLimitBodyPaywall => '升级到 Pro 以获得更多扫描次数，或手动填写详情。';

  @override
  String get batchDailyLimitBodyFree => '扫描次数将于明天重置。您现在可以手动填写详情。';

  @override
  String get batchSeePlansAction => '查看方案';

  @override
  String get batchAiBusyTitle => 'AI 正忙';

  @override
  String get batchAiBusyBody => '这是服务端的问题。请稍后重试。';

  @override
  String get batchNoPiecesBody => '请尝试使用更清晰的照片，或手动填写详情。';

  @override
  String get batchScanningUnavailableTitle => '扫描功能不可用';

  @override
  String get batchScanningUnavailableBody => '请暂时手动填写详情。';

  @override
  String get batchScanDidNotFinishTitle => '扫描未完成';

  @override
  String get batchTryAgainBody => '重试。';

  @override
  String get billingTitle => '订阅';

  @override
  String get billingUpgradeHeading => '升级您的方案';

  @override
  String get billingUpgradeOnPlusBody => '功能相同，上限更高。';

  @override
  String get billingUpgradeBody => 'Plus 和 Pro 功能相同。请根据所需上限选择。';

  @override
  String get billingWebUnavailableBody =>
      '在线升级功能尚未上线。优惠码或推荐码仍可解锁 Plus 或 Pro。在下方邀请好友可获得免费使用月。';

  @override
  String get billingPlansStale => '无法加载最新方案。价格可能已过期。';

  @override
  String get billingMonthly => '月付';

  @override
  String get billingYearly => '年付';

  @override
  String get billingCurrentPlan => '当前方案';

  @override
  String get billingActive => '生效中';

  @override
  String get billingThisMonth => '本月';

  @override
  String get billingItemExtractions => '单品识别次数';

  @override
  String get billingOutfitVisualizations => '穿搭生成次数';

  @override
  String get billingNearLimitUpgrade => '您已接近本月上限。升级可获得更多。';

  @override
  String get billingNearLimitResets => '您已接近本月上限。将在下月初重置。';

  @override
  String get billingStoreUnavailable => '升级功能暂未在商店开放，请稍后再试。';

  @override
  String get billingManageHeading => '管理您的套餐';

  @override
  String get billingCancelPlan => '取消订阅';

  @override
  String get billingCancelKeepsAccess => '您可继续使用至本计费周期结束。';

  @override
  String get billingCancelConfirmTitle => '确定取消订阅吗？';

  @override
  String get billingKeepPlan => '保留套餐';

  @override
  String get billingCancelPlanAction => '取消套餐';

  @override
  String get billingBilledMonthly => '按月计费';

  @override
  String get billingBilledYearly => '按年计费';

  @override
  String get billingVirtualTryOn => '虚拟试穿';

  @override
  String get billingPrioritySupport => '优先客服支持';

  @override
  String get billingDisclosureProRenewing => 'Pro 为自动续订订阅';

  @override
  String get billingDisclosureBothRenewing => 'Plus 和 Pro 均为自动续订订阅';

  @override
  String get billingDisclosureAppleBilling => '购买确认时，费用将计入您的 Apple ID。';

  @override
  String get billingDisclosureGoogleBilling => '购买确认时，费用将计入您的 Google Play 账户。';

  @override
  String get billingDisclosureRenewalTerms =>
      '您的订阅将按相同周期和价格自动续订，除非您在当前周期结束前至少 24 小时关闭自动续订。';

  @override
  String get billingDisclosureAppleManage =>
      '您可以随时在“设置” > “Apple ID” > “订阅”中管理或取消。';

  @override
  String get billingDisclosureGoogleManage =>
      '您可以随时在“Google Play” > “付款与订阅”中管理或取消。';

  @override
  String get billingReferFriend => '邀请好友';

  @override
  String get billingHowItWorks => '使用方式';

  @override
  String get billingHowShareTitle => '分享您的链接';

  @override
  String get billingHowShareBody => '发送给好友。';

  @override
  String get billingHowSignUpTitle => '好友注册';

  @override
  String get billingHowSignUpBody => '好友通过链接注册。';

  @override
  String get billingHowBothTitle => '你们都能获得 Pro';

  @override
  String get billingHowBothBody => '你们各获得一个月免费 Pro。';

  @override
  String get billingYourReferrals => '您的推荐记录';

  @override
  String get billingInvited => '已邀请';

  @override
  String get billingJoined => '已注册';

  @override
  String get billingMonthsEarned => '已获得月数';

  @override
  String get billingInviteFriend => '邀请好友';

  @override
  String get billingInviteBody => '你和好友各享一个月Pro版。';

  @override
  String get billingYourCode => '你的邀请码';

  @override
  String get billingCopyLink => '复制链接';

  @override
  String get billingShareInvite => '分享邀请';

  @override
  String get giftUnavailable => '此版本暂无礼品邀请。';

  @override
  String get giftPageTitle => '赠送FitCheck Pro';

  @override
  String get giftNoAllowances => '当前暂无免费礼品邀请。';

  @override
  String get giftFormTitle => '发送免费邀请';

  @override
  String get giftFormBody => '收件人需通过此验证邮箱领取礼品。我们不会替你发送邮件。';

  @override
  String get giftFieldFrom => '发送者';

  @override
  String get giftFieldRecipientName => '收件人姓名';

  @override
  String get giftFieldRecipientEmail => '收件人邮箱';

  @override
  String get giftFieldOccasion => '场合（选填）';

  @override
  String get giftNoOccasion => '无特定场合';

  @override
  String get giftOccasionBirthday => '生日';

  @override
  String get giftOccasionAnniversary => '纪念日';

  @override
  String get giftOccasionOther => '其他';

  @override
  String get giftFieldCardGreeting => '卡片祝福语';

  @override
  String get giftFieldCardGreetingHelper => '将按原文显示在卡片上。';

  @override
  String get giftFieldPrivateNote => '私密备注（选填）';

  @override
  String get giftCreateAction => '创建免费礼品';

  @override
  String get giftClaimedTitle => '礼品已领取';

  @override
  String get giftClaimedActive => '你的FitCheck Pro礼品已激活。';

  @override
  String get giftClaimedQueued => '你的FitCheck Pro礼品将在当前访问权限结束后生效。';

  @override
  String get giftLinkCopied => '礼品链接已复制到剪贴板。';

  @override
  String get giftErrorName => '请输入姓名。';

  @override
  String get giftErrorEmail => '请输入有效邮箱。';

  @override
  String get giftErrorGreeting => '请输入卡片祝福语。';

  @override
  String get giftErrorGreetingLength => '不超过80个字符。';

  @override
  String get giftClaimAction => '领取礼物';

  @override
  String get giftCardPreview => '卡片预览';

  @override
  String get giftGiftForYou => '你的礼物';

  @override
  String get giftGiftWaiting => '有一份礼物等着你';

  @override
  String get giftOpenBody => '使用已验证的邮箱打开并领取礼物。';

  @override
  String get giftOpenGifts => '打开礼物';

  @override
  String get giftSendInvitation => '发送邀请';

  @override
  String get settingsAiProviderSection => '服务商';

  @override
  String get settingsAiCustom => '自定义';

  @override
  String get settingsAiUrlHelper => '请使用服务器可访问的公共 URL，localhost 无效。';

  @override
  String get settingsAiConnectionSection => '连接';

  @override
  String get settingsAiApiUrl => 'API 地址';

  @override
  String get settingsAiApiKey => 'API 密钥';

  @override
  String get settingsAiApiKeySaved => '已保存。留空可保持当前设置。';

  @override
  String get settingsAiChatModel => '对话模型';

  @override
  String get settingsAiVisionModel => '视觉模型（可选）';

  @override
  String get settingsAiImageModel => '图像模型（可选）';

  @override
  String get settingsAiImageModelNote =>
      '图像生成需要支持 response_modalities 的 OpenAI 兼容对话接口。';

  @override
  String get settingsAiTestConnection => '测试连接';

  @override
  String get calendarTitle => '日历';

  @override
  String get calendarGoToToday => '转到今天';

  @override
  String get calendarConnectTooltip => '连接日历';

  @override
  String get calendarAddEvent => '添加活动';

  @override
  String get calendarEmptyTitle => '暂无计划';

  @override
  String get calendarEmptyBody => '添加活动并规划穿搭。';

  @override
  String get calendarPreviousMonth => '上个月';

  @override
  String get calendarNextMonth => '下个月';

  @override
  String get calendarAllDay => '全天';

  @override
  String get calendarOutfitLinked => '已关联穿搭';

  @override
  String get calendarEventOptions => '活动选项';

  @override
  String get calendarDeleteTitle => '删除此活动？';

  @override
  String get calendarChangeOutfit => '更换搭配';

  @override
  String get calendarLinkOutfit => '关联搭配';

  @override
  String get calendarRemoveOutfit => '移除搭配';

  @override
  String get calendarNewEvent => '新建活动';

  @override
  String get calendarEditEvent => '编辑活动';

  @override
  String get calendarTitleLabel => '标题';

  @override
  String get calendarTitleRequired => '请输入标题';

  @override
  String get calendarEndBeforeStart => '结束需晚于开始时间';

  @override
  String get calendarStarts => '开始';

  @override
  String get calendarEnds => '结束';

  @override
  String get calendarPlaceOptional => '地点（可选）';

  @override
  String get calendarNotesOptional => '备注（可选）';

  @override
  String get calendarLinkOutfitEmptyBody => '先创建搭配，再关联到此活动。';

  @override
  String get calendarBuildOutfit => '创建搭配';

  @override
  String get calendarConnectionsTitle => '日历';

  @override
  String get calendarConnectionsBody => '此处添加的活动仅保存在 FitCheck AI。';

  @override
  String get calendarDisconnect => '断开';

  @override
  String get calendarNotAvailable => '暂不可用';

  @override
  String get profileSectionExplore => '探索';

  @override
  String get profileNavTryOn => '试穿';

  @override
  String get profileNavRewards => '奖励';

  @override
  String get profileSupport => '支持';

  @override
  String get profileHelp => '帮助';

  @override
  String get profileAbout => '关于';

  @override
  String get profileAboutBody => '衣橱、搭配与计划，尽在一处。';

  @override
  String get profileSignOutTitle => '退出登录？';

  @override
  String get profileSignOutBody => '您可以随时重新登录。';

  @override
  String get profileEditTitle => '编辑个人资料';

  @override
  String get profileYourProfile => '我的资料';

  @override
  String get profileBodyProfiles => '身体配置';

  @override
  String get profileBodyEmptyTitle => '暂无身体配置';

  @override
  String get profileBodyEmptyBody => '添加身高和体型以获得更合身的效果。';

  @override
  String get profileBodyAdd => '新建配置';

  @override
  String get profileBodyDefaultNote => '默认配置用于试穿和合身度分析。';

  @override
  String get profileBodyDefaultBadge => '默认';

  @override
  String get profileBodyMakeDefault => '设为默认';

  @override
  String get profileBodyDeleteBody => '此操作无法撤销。';

  @override
  String get profileBodyRequired => '必填';

  @override
  String get profileBodyCheckNumber => '核对此数字';

  @override
  String get profileBodyNew => '新的身体配置';

  @override
  String get profileBodyNameHint => '例如，我自己';

  @override
  String get profileBodyHeight => '身高';

  @override
  String get profileBodyWeight => '体重';

  @override
  String get profileBodyBuild => '体型';

  @override
  String get profileBodySkinTone => '肤色';

  @override
  String get profileBirthDateNeededBody => '添加出生日期以匹配出生时间。';

  @override
  String get profileBirthDateNeededTitle => '需要出生日期';

  @override
  String get profilePartlySavedBody => '已保存姓名和照片。出生信息未保存，请稍后重试。';

  @override
  String get profilePartlySavedTitle => '部分已保存';

  @override
  String get profileSavedBody => '资料已保存。';

  @override
  String get profileChangePhoto => '更换头像';

  @override
  String get profilePhotoLabel => '头像';

  @override
  String get profilePhotoHint => '点按选择新照片';

  @override
  String get profileBirthDateLabel => '出生日期（可选）';

  @override
  String get profileBirthTimeLabel => '出生时间（可选）';

  @override
  String get profileBirthTimeHelper => '提高吠陀建议的准确性';

  @override
  String get profileBirthPlaceLabel => '出生地点（可选）';

  @override
  String get profileBirthPlaceHint => '例如，印度新德里';

  @override
  String get profileHelpContactTitle => '向我们提问';

  @override
  String get profileHelpContactBody => '发送消息，我们会通过邮件回复，通常一天内回复。';

  @override
  String get profileHelpContactAction => '联系客服';

  @override
  String get profileHelpFaqTitle => '常见问题';

  @override
  String get profileFaqAddPiecesTitle => '如何向衣橱添加单品？';

  @override
  String get profileFaqAddPiecesBody =>
      '点击衣橱标签页中的添加单品。拍照或从相册选择；我们会识别并为你标记每个单品。';

  @override
  String get profileFaqMatchingTitle => '服装搭配如何运作？';

  @override
  String get profileFaqMatchingBody => '打开为你推荐，选择你拥有的单品。我们会推荐匹配项并从你的衣橱中搭配完整穿搭。';

  @override
  String get profileFaqTryOnTitle => '我可以使用自己的照片进行试穿吗？';

  @override
  String get profileFaqTryOnBody => '可以。添加一张全身照片，然后选择单品，查看穿在你身上的效果。';

  @override
  String get profileFaqRewardsTitle => '如何赚取奖励？';

  @override
  String get profileFaqRewardsBody => '制定计划并经常记录穿搭。随着你进行，连续记录和活动会累积。';

  @override
  String get profileFaqPrivacyTitle => '我的衣橱是私密的吗？';

  @override
  String get profileFaqPrivacyBody => '是的。除非你分享一个穿搭的链接，否则你的衣橱和穿搭是私密的。';

  @override
  String get profileHelpMoreTitle => '更多帮助';

  @override
  String get profileHelpGuides => '指南';

  @override
  String get profileHelpGuidesBody => '了解每个功能如何运作';

  @override
  String get feedbackCategoryBug => '功能故障';

  @override
  String get feedbackCategoryIdea => '建议';

  @override
  String get feedbackCategoryGeneral => '一般';

  @override
  String get feedbackCategoryHelp => '需要帮助';

  @override
  String get feedbackHintBug => '发生了什么，你期望什么？步骤有助于我们修复。';

  @override
  String get feedbackHintIdea => '你想要什么，以及为什么？';

  @override
  String get feedbackHintGeneral => '告诉我们你的想法，或提出一个问题。';

  @override
  String get feedbackAttachmentLimitBody => '你最多可以添加 5 张图片。';

  @override
  String get feedbackAttachmentLimitTitle => '达到限制';

  @override
  String get feedbackImageTooLargeBody => '选择小于 5 MB 的图片。';

  @override
  String get feedbackImageTooLargeTitle => '图片过大';

  @override
  String get feedbackTitle => '发送反馈';

  @override
  String get feedbackAboutLabel => '关于什么？';

  @override
  String get feedbackSubjectLabel => '主题';

  @override
  String get feedbackSubjectRequired => '添加主题';

  @override
  String get feedbackSubjectTooShort => '主题至少 3 个字符';

  @override
  String get feedbackDetailsLabel => '详情';

  @override
  String get feedbackDetailsRequired => '添加一些详情';

  @override
  String get feedbackDetailsTooShort => '描述至少 10 个字符';

  @override
  String get feedbackAddScreenshot => '添加截图';

  @override
  String get feedbackAttachmentHint => '最多 5 个，每个 5 MB';

  @override
  String get feedbackSend => '发送';

  @override
  String get feedbackEmptyTitle => '尚未发送';

  @override
  String get feedbackEmptyBody => '你发送的内容将在此处显示状态。';

  @override
  String get feedbackHistoryTitle => '发送记录';

  @override
  String get feedbackStatusOpen => '待处理';

  @override
  String get feedbackStatusInProgress => '处理中';

  @override
  String get feedbackStatusResolved => '已解决';

  @override
  String get feedbackStatusClosed => '已关闭';

  @override
  String get legalIntro => '我们如何保护你的数据，以及使用 FitCheck AI 的条款。';

  @override
  String get legalPolicies => '政策';

  @override
  String get legalPrivacySubtitle => '我们收集的内容及原因';

  @override
  String get legalTermsTitle => '服务条款';

  @override
  String get legalTermsSubtitle => '使用应用的规则';

  @override
  String get legalLicences => '开源许可';

  @override
  String get legalSupportSubtitle => '帮助、联系和隐私请求';

  @override
  String get legalReportAbuse => '报告问题或滥用';

  @override
  String get permissionCameraTitle => '相机访问';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI 使用你的相机拍摄衣物和搭配照片，用于 AI 试穿和衣橱整理。';

  @override
  String get permissionPhotoTitle => '照片访问';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI 需要访问你的照片，以便你选择衣物和搭配图片用于 AI 功能和衣橱。';

  @override
  String get permissionNotNow => '暂不';

  @override
  String get permissionOpenSettings => '打开设置';

  @override
  String authSignedInAs(String name) {
    return '已登录为 $name';
  }

  @override
  String get authSignedIn => '已登录';

  @override
  String get authWelcomeBackTitle => '欢迎回来';

  @override
  String get authSignInFailed => '登录失败';

  @override
  String get authWelcomeTitle => '欢迎';

  @override
  String get authSignUpFailed => '注册失败';

  @override
  String get authGoogleSignInFailed => 'Google 登录失败';

  @override
  String get authAppleSignInFailed => 'Apple 登录失败';

  @override
  String get authConfirmEmailTitle => '确认您的邮箱';

  @override
  String get authConfirmEmailBody => '请查看收件箱中的确认邮件，然后登录。';

  @override
  String get authClosetReady => '您的衣柜已就绪。';

  @override
  String get authSignedOutTitle => '已退出';

  @override
  String get authSignedOutBody => '您已退出。';

  @override
  String get authSignOutFailed => '退出失败';

  @override
  String get authEmailSentTitle => '邮件已发送';

  @override
  String get authResetLinkSent => '请查看邮箱中的重置链接。';

  @override
  String get authPasswordUpdatedTitle => '密码已更新';

  @override
  String get authPasswordUpdated => '您的密码已更新。';

  @override
  String get authPasswordNotUpdated => '密码未更新';

  @override
  String get authCouldNotSendEmail => '无法发送邮件';

  @override
  String get authEmailNotSent => '邮件未发送';

  @override
  String get authResendSentBody => '我们已发送新的确认邮件。';

  @override
  String get outfitPreviewWithAi => 'AI 预览';

  @override
  String get outfitNewPreview => '创建新预览';

  @override
  String get outfitBuilderClosetHeading => '您的衣柜';

  @override
  String get outfitBuilderSearchHint => '搜索单品';

  @override
  String get outfitClearSearch => '清除搜索';

  @override
  String get outfitBuilderAddPiecesTitle => '请先添加单品';

  @override
  String get outfitBuilderAddPiecesBody => '穿搭由衣柜中的单品组成。';

  @override
  String get outfitBuilderNoMatches => '无匹配单品。';

  @override
  String get outfitNameLabel => '穿搭名称';

  @override
  String get outfitNameHint => '例如，周末亚麻';

  @override
  String get outfitPreviewSemantic => '服装 AI 预览';

  @override
  String get outfitChoosePieces => '选择单品';

  @override
  String get outfitTapPiecesHint => '轻点下方单品以添加。';

  @override
  String get outfitShareTooltip => '分享';

  @override
  String get outfitSaveFavourite => '收藏';

  @override
  String get outfitPiecesHeading => '单品';

  @override
  String get outfitWearHistoryEmpty => '穿戴一次后，日期将显示在此处。';

  @override
  String get outfitWearHistoryTitle => '穿戴记录';

  @override
  String get outfitWearHistoryError => '无法加载日期。';

  @override
  String get outfitWornOn => '穿戴日期';

  @override
  String get outfitEditTitle => '编辑穿搭';

  @override
  String get outfitSavedPhotosFailed => '详情已保存，照片未保存';

  @override
  String get outfitNoPhotosBody => '暂无照片。穿搭将显示其单品。';

  @override
  String get outfitOccasionLabel => '场合';

  @override
  String get outfitOccasionNone => '无';

  @override
  String get outfitTagsHint => '用逗号分隔';

  @override
  String get outfitDraftBody => '已隐藏在主列表中';

  @override
  String get outfitPublic => '公开';

  @override
  String get outfitPublicBody => '拥有链接的人都可以查看';

  @override
  String get outfitDeleteFromDetail => '从详情页删除此穿搭。';

  @override
  String get outfitNewCollection => '新建合集';

  @override
  String get outfitNoCollectionsTitle => '暂无合集';

  @override
  String get outfitNoCollectionsBody => '按旅行、季节或心情分组穿搭。';

  @override
  String get outfitCreateCollection => '创建合集';

  @override
  String get outfitAddOutfits => '添加穿搭';

  @override
  String get outfitRename => '重命名';

  @override
  String get outfitCollectionDeleteBody => '其中的穿搭将保留。';

  @override
  String get outfitCollectionsNotLoaded => '穿搭未加载';

  @override
  String get outfitRenameCollection => '重命名合集';

  @override
  String get outfitDescriptionOptional => '描述（可选）';

  @override
  String get outfitAllInCollection => '所有搭配已在此合集内。';

  @override
  String get photoshootSubtitleUpload => '用你的照片生成影棚人像';

  @override
  String get photoshootSubtitleConfigure => '选择风格、格式和数量';

  @override
  String get photoshootSubtitleGenerating => '需要一两分钟';

  @override
  String get photoshootAddPhotosSemantic => '从图库添加照片';

  @override
  String get photoshootUploadTitle => '添加 1 到 4 张你的照片';

  @override
  String get photoshootUploadBody => '轻点从图库选择';

  @override
  String get photoshootAddToContinue => '添加照片以继续';

  @override
  String get photoshootAddAnotherPhoto => '再添加一张照片';

  @override
  String get photoshootTipsTitle => '获得最佳效果';

  @override
  String get photoshootTipsBody => '使用光线充足、角度多样的清晰面部照片。避免戴墨镜或帽子。';

  @override
  String get photoshootStarting => '开始中';

  @override
  String get photoshootCancelling => '取消中';

  @override
  String get photoshootFailed => '失败';

  @override
  String get recommendTabMatches => '搭配';

  @override
  String get recommendTabComplete => '补全';

  @override
  String get recommendTabWeather => '天气';

  @override
  String get recommendTabColours => '色彩';

  @override
  String get recommendTabShop => '购物';

  @override
  String get recommendNoMatchesTitle => '暂无搭配';

  @override
  String get recommendNoMatchesBody => '选一件单品，我们会找到与之匹配的搭配。';

  @override
  String get recommendPickPiece => '选择单品';

  @override
  String get recommendNothingMatchesTitle => '这些单品暂无搭配';

  @override
  String get recommendNothingMatchesBody => '试试其他单品，或往衣橱里添加更多。';

  @override
  String get recommendChangePieces => '更换单品';

  @override
  String get recommendDefaultReason => '与你选的单品很搭。';

  @override
  String get recommendCompleteTitle => '补全穿搭';

  @override
  String get recommendCompleteBody => '选一件单品，我们帮你补齐其余部分。';

  @override
  String get recommendWorking => '处理中';

  @override
  String get recommendGenerate => '生成';

  @override
  String get recommendChooseStyleBody => '选择风格，然后生成。';

  @override
  String get recommendNoLooksTitle => '这些单品无搭配';

  @override
  String get recommendNoLooksBody => '试试其他风格或单品。';

  @override
  String get recommendDefaultLook => '单品搭配方案';

  @override
  String get recommendNoPiecesBody => '该搭配暂无可用单品。';

  @override
  String get recommendCityLabel => '城市';

  @override
  String get recommendCheck => '查看';

  @override
  String get recommendWeatherTitle => '今天天气如何？';

  @override
  String get recommendWeatherBody => '输入城市，获取今日推荐。';

  @override
  String get recommendWearToday => '今日穿搭';

  @override
  String get recommendWeatherNoPieces => '衣橱中暂无适合该天气的单品。';

  @override
  String get recommendBudgetLabel => '预算上限';

  @override
  String get recommendLooking => '正在查找';

  @override
  String get recommendFindWhatToBuy => '查找购买建议';

  @override
  String get recommendFillGapsTitle => '补齐缺口';

  @override
  String get recommendFillGapsBody => '设定预算，推荐衣橱缺失的单品。';

  @override
  String get recommendNoGapsTitle => '未找到缺口';

  @override
  String get recommendNoGapsBody => '尝试提高预算或更换品类。';

  @override
  String get recommendMoodEveryday => '日常';

  @override
  String get recommendMoodBigMeeting => '重要会议';

  @override
  String get recommendDayLabel => '日期';

  @override
  String get recommendReadingStars => '正在解读星象';

  @override
  String get recommendGetMyColours => '获取我的幸运色';

  @override
  String get recommendLuckyColoursTitle => '你的幸运色';

  @override
  String get recommendLuckyColoursBody => '选择日期，推荐幸运色和单品。';

  @override
  String get recommendLuckyColoursSection => '幸运色';

  @override
  String get recommendAvoidColoursSection => '建议少用的颜色';

  @override
  String get recommendBirthDateTitle => '添加出生日期';

  @override
  String get recommendBirthDateBody => '需出生日期以解读幸运色。';

  @override
  String get recommendEditProfile => '编辑资料';

  @override
  String get recommendNothingThisDay => '今日无推荐';

  @override
  String get recommendUnnamedColour => '未命名颜色';

  @override
  String get recommendFromCloset => '来自您的衣橱';

  @override
  String get recommendNoPiecesInColours => '暂无这些颜色的单品';

  @override
  String get recommendOutfitIdeas => '穿搭灵感';

  @override
  String get recommendNoOutfitsInColours => '暂无这些颜色的完整穿搭';

  @override
  String get recommendDefaultOutfitIdea => '穿搭建议';

  @override
  String get recommendPickUpToThree => '最多选三件';

  @override
  String get recommendEmptyClosetBody => '请先添加单品，再回来获取搭配。';

  @override
  String get dashboardDressForDay => '为今天搭配得体装扮。';

  @override
  String get dashboardOutfitOfDay => '今日穿搭';

  @override
  String get dashboardFreshLook => '焕新造型';

  @override
  String get subscriptionManageInStoreTitle => '在商店中管理';

  @override
  String get subscriptionManageInStoreBody => '此计划通过商店扣费。请在商店账户设置中管理。';

  @override
  String get subscriptionCancelledTitle => '已取消订阅';

  @override
  String get subscriptionCancelledBody => '您的计划将保持激活至本期结束。';

  @override
  String get subscriptionCancelFailedTitle => '无法取消';

  @override
  String get subscriptionCouldNotOpenTitle => '无法打开';

  @override
  String get subscriptionOpenBillingFailedBody => '无法打开账单管理。';

  @override
  String get subscriptionOpenLinkFailedBody => '无法打开链接。';

  @override
  String get subscriptionReferralLoadFailedTitle => '无法加载链接';

  @override
  String get subscriptionReferralLoadFailedBody => '无法加载推荐链接。请重试。';

  @override
  String get subscriptionReferralCopiedTitle => '已复制';

  @override
  String get subscriptionReferralCopiedBody => '推荐链接已复制。';

  @override
  String get subscriptionReferralShareSubject => '试试 FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return '加入 FitCheck AI，我们都可获一个月 Pro。$link';
  }

  @override
  String get subscriptionLinkCopiedTitle => '链接已复制';

  @override
  String get subscriptionShareUnavailableBody => '无法分享，已复制链接。';

  @override
  String get subscriptionShareFailedTitle => '无法分享';

  @override
  String get subscriptionShareFailedBody => '请改为复制推荐页面上的链接。';

  @override
  String get subscriptionStoreReadyTitle => '商店已就绪';

  @override
  String get subscriptionStoreReadyBody => '商店价格已可用，您可以立即升级。';

  @override
  String get purchaseFailedTitle => '购买失败';

  @override
  String get purchaseUnavailableTitle => '无法购买';

  @override
  String get purchaseIapUnavailableBody => '此设备不支持应用内购买。';

  @override
  String get purchasePlanNotAvailableBody => '该方案尚不可购买。';

  @override
  String get purchasePlanNotInStoreBody => '该方案尚未在商店上架，请稍后再试。';

  @override
  String get purchaseStartFailedBody => '无法启动购买，请重试。';

  @override
  String get purchaseNoPaymentLinkBody => '结账未返回支付链接。';

  @override
  String get purchasePendingTitle => '购买处理中';

  @override
  String get purchasePendingBody => '您的购买正在等待批准，批准后即可获得访问权限。';

  @override
  String get purchaseFailedBody => '购买失败，请重试。';

  @override
  String get purchaseRestoredTitle => '已恢复';

  @override
  String get purchaseRestoredBody => '您的购买记录已恢复。';

  @override
  String get purchaseActiveTitle => '订阅已激活';

  @override
  String get purchaseActiveBody => '您的订阅已生效，欢迎使用。';

  @override
  String get purchaseSignInRequiredTitle => '需要登录';

  @override
  String get purchaseSignInRequiredBody => '请登录以完成购买。';

  @override
  String get purchaseErrorTitle => '购买出错';

  @override
  String get purchaseInvalidTransactionBody => '该购买未包含可验证的交易 ID。';

  @override
  String get purchaseVerificationPendingTitle => '验证中';

  @override
  String get purchaseVerificationPendingBody =>
      '目前无法通过商店验证您的购买。该流程将自动完成，且不会重复扣费。';

  @override
  String get purchaseNotAppliedTitle => '购买未生效';

  @override
  String get purchaseNotAppliedBody => '无法将该购买应用至您的账户。请联系客服，且请勿再次购买。';

  @override
  String get purchaseRestoreFailedTitle => '恢复失败';

  @override
  String get purchaseRestoreFailedBody => '无法恢复购买记录，请重试。';

  @override
  String get purchaseRecoveredActiveBody => '您的订阅已生效。';

  @override
  String get purchaseCompleteTitle => '购买完成';

  @override
  String get giftCreateFailedTitle => '无法创建礼品';

  @override
  String get giftClaimFailedTitle => '无法领取礼物';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个礼物',
      one: '1 个礼物',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 个月',
      '12': '1 年',
      'other': '$months 个月',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '剩余 $remaining 次',
      one: '剩余 1 次',
    );
    return '$duration，$_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration 的 FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender 给你送了 $duration 的 FitCheck Pro。$link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '给 $recipient 的 FitCheck Pro 礼物';
  }

  @override
  String giftFromSender(String sender) {
    return '来自 $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '赠予 $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '来自 $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => '收件人';

  @override
  String get giftPreviewPlaceholderSender => '你';

  @override
  String get settingsSavedTitle => '已保存';

  @override
  String get settingsNotSavedTitle => '未保存';

  @override
  String get settingsAiChooseProviderBody => '请选择服务商。';

  @override
  String get settingsAiCustomUrlRequiredBody => '自定义服务商需要 API URL。';

  @override
  String get settingsAiKeyRequiredBody => '请输入 API 密钥。';

  @override
  String get settingsAiSavedBody => '你的 AI 设置已保存。';

  @override
  String get settingsAiMissingDetailsTitle => '缺少详细信息';

  @override
  String get settingsAiUrlAndModelRequiredBody => '请输入 API URL 和聊天模型以测试。';

  @override
  String get settingsAiKeyNeededTitle => '需要 API 密钥';

  @override
  String get settingsAiKeyToTestPrivateBody => '请输入你的 API 密钥以测试。保存的密钥不会公开。';

  @override
  String get settingsAiKeyToTestBody => '请输入你的 API 密钥以测试。';

  @override
  String get settingsAiConnectedTitle => '已连接';

  @override
  String get settingsAiConnectedBody => '连接正常。';

  @override
  String get settingsAiTestFailedTitle => '测试失败';

  @override
  String get settingsPreferencesSavedBody => '你的偏好已保存。';

  @override
  String get settingsPasswordNotChangedTitle => '密码未更改';

  @override
  String get settingsOAuthPasswordBody =>
      '此账号通过 Google 或 Apple 登录。请先使用“忘记密码”设置密码。';

  @override
  String get settingsCurrentPasswordIncorrectBody => '当前密码不正确。';

  @override
  String get settingsExportReadyTitle => '导出准备就绪';

  @override
  String get settingsExportReadyBody => '您的数据导出已准备好下载。';

  @override
  String get settingsLinkCopiedTitle => '链接已复制';

  @override
  String get settingsExportClipboardBody =>
      '无法打开您的浏览器，已复制下载链接。请尽快粘贴到浏览器中：链接会过期。';

  @override
  String get settingsExportFailedTitle => '导出失败';

  @override
  String get settingsAccountNotDeletedTitle => '账户未删除';

  @override
  String photoshootPhotoLimit(int max) {
    return '您最多可以添加 $max 张照片。';
  }

  @override
  String get photoshootPhotoLimitTitle => '照片数量限制';

  @override
  String get photoshootAddAtLeastOnePhoto => '请至少添加一张照片。';

  @override
  String get photoshootNoPhotosSelectedTitle => '未选择照片';

  @override
  String get photoshootDescribeLookBody => '描述您想要的造型。';

  @override
  String get photoshootPromptNeededTitle => '需要提示词';

  @override
  String get photoshootConsentFeatureLabel => 'AI 写真';

  @override
  String get photoshootStatusPreparing => '正在处理您的照片';

  @override
  String get photoshootStatusGenerating => '正在生成';

  @override
  String photoshootStatusBatch(int current, int total) {
    return '批次 $current / $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '已完成 $done / $total';
  }

  @override
  String get photoshootGenerationFailedBody => '生成失败。';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready 张已就绪，$failed 张失败。';
  }

  @override
  String get photoshootPartlyDoneTitle => '部分完成';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片已就绪。',
      one: '1 张照片已就绪。',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => '连接已断开。请重试。';

  @override
  String get photoshootCouldNotCancelTitle => '无法取消';

  @override
  String get photoshootRetryFailedTitle => '重试失败';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return '照片 $number 已就绪。';
  }

  @override
  String get photoshootReplacedTitle => '已替换';

  @override
  String get photoshootSavedToGalleryBody => '已保存至您的相册。';

  @override
  String get photoshootSavedTitle => '已保存';

  @override
  String get photoshootNotSavedTitle => '未保存';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '全部 $count 张照片已在您的相册中。',
      one: '1 张照片已在您的相册中。',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '已保存 $saved 张，共 $total 张。';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => '部分照片未保存';

  @override
  String get tryonConsentFeatureLabel => '虚拟试穿';

  @override
  String get tryonAvatarUpdatedBody => '照片已更新。';

  @override
  String get tryonSavedTitle => '已保存';

  @override
  String get tryonUploadFailedTitle => '上传失败';

  @override
  String get tryonChooseGarmentFirstBody => '请先选择一件服装照片。';

  @override
  String get tryonNoGarmentTitle => '无服装';

  @override
  String get tryonWaitForUploadBody => '请等待照片上传完成。';

  @override
  String get tryonStillUploadingTitle => '正在上传中';

  @override
  String get tryonAddYourPhotoFirstBody => '请先添加您的照片。';

  @override
  String get tryonReadyBody => '试穿已准备就绪。';

  @override
  String get tryonFailedTitle => '试穿失败';

  @override
  String get tryonSavedToGalleryBody => '已保存至相册。';

  @override
  String get tryonNotSavedTitle => '未保存';

  @override
  String get calendarEventAddedBody => '已添加日程';

  @override
  String get calendarEventPlannedTitle => '已计划';

  @override
  String get calendarEventSavedBody => '日程已保存';

  @override
  String get calendarSavedTitle => '已保存';

  @override
  String get calendarEventNotSavedTitle => '日程未保存';

  @override
  String get calendarEventRemovedBody => '已移除日程';

  @override
  String get calendarEventDeletedTitle => '已删除';

  @override
  String get calendarEventNotDeletedTitle => '日程未删除';

  @override
  String get calendarOutfitNotLinkedTitle => '穿搭未关联';

  @override
  String get calendarLinkedTitle => '已关联';

  @override
  String get calendarOutfitNotRemovedTitle => '穿搭未移除';

  @override
  String get calendarOutfitRemovedBody => '已移除穿搭';

  @override
  String get calendarDisconnectedBody => '日历已断开连接';

  @override
  String get calendarDisconnectedTitle => '已断开';

  @override
  String get calendarNotDisconnectedTitle => '日历未断开';

  @override
  String get calendarTodayLabel => '今天';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个活动',
      one: '1 个活动',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start 至 $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title，$time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title，$time，已关联穿搭';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '“$title”将被删除。';
  }

  @override
  String get calendarThisAppLabel => '本应用';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '与 $provider 同步暂不可用。你仍可以在这里添加活动。';
  }

  @override
  String get calendarWeekdaySunShort => '日';

  @override
  String get calendarWeekdayMonShort => '一';

  @override
  String get calendarWeekdayTueShort => '二';

  @override
  String get calendarWeekdayWedShort => '三';

  @override
  String get calendarWeekdayThuShort => '四';

  @override
  String get calendarWeekdayFriShort => '五';

  @override
  String get calendarWeekdaySatShort => '六';

  @override
  String get calendarWeekdayMonday => '周一';

  @override
  String get calendarWeekdayTuesday => '周二';

  @override
  String get calendarWeekdayWednesday => '周三';

  @override
  String get calendarWeekdayThursday => '周四';

  @override
  String get calendarWeekdayFriday => '周五';

  @override
  String get calendarWeekdaySaturday => '周六';

  @override
  String get calendarWeekdaySunday => '周日';

  @override
  String get outfitSavedToFavouritesBody => '已添加到收藏';

  @override
  String get outfitRemovedFromFavouritesBody => '已从收藏中移除';

  @override
  String get outfitNotSavedTitle => '未保存';

  @override
  String get outfitLoggedAsWornBody => '已记录为今日穿着。';

  @override
  String get outfitNicePickTitle => '不错的选择';

  @override
  String get outfitRemovedBody => '穿搭已移除。';

  @override
  String get outfitDeletedTitle => '已删除';

  @override
  String get outfitNotDeletedTitle => '未删除';

  @override
  String get outfitDuplicatedBody => '已复制至你的搭配。';

  @override
  String get outfitDuplicatedTitle => '已重复';

  @override
  String get outfitNotDuplicatedTitle => '未重复';

  @override
  String get outfitNotSharedTitle => '未分享';

  @override
  String outfitCollectionReadyBody(String name) {
    return '“$name”已准备就绪。';
  }

  @override
  String get outfitCollectionNotCreatedTitle => '集合未创建';

  @override
  String get outfitCollectionUpdatedBody => '集合已更新。';

  @override
  String get outfitCollectionNotUpdatedTitle => '集合未更新';

  @override
  String get outfitCollectionDeletedBody => '集合已删除。';

  @override
  String get outfitCollectionNotDeletedTitle => '集合未删除';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已添加 $count 套搭配。',
      one: '已添加 1 套搭配。',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => '搭配未添加';

  @override
  String get outfitPreviewNotCreatedTitle => '预览未创建';

  @override
  String get outfitGiveNameBody => '为搭配命名。';

  @override
  String get outfitNameMissingTitle => '名称缺失';

  @override
  String get outfitChooseAtLeastOnePieceBody => '请至少选择一件单品。';

  @override
  String outfitCreatedBody(String name) {
    return '$name 已加入你的搭配。';
  }

  @override
  String get outfitSavedTitle => '已保存';

  @override
  String get wardrobeAddedToFavouritesBody => '已添加至收藏';

  @override
  String get wardrobeRemovedFromFavouritesBody => '已移除收藏';

  @override
  String get wardrobeNotSavedTitle => '未保存';

  @override
  String get wardrobeLoggedAsWornBody => '已记录今日穿着。';

  @override
  String get wardrobeRemovedFromClosetBody => '已从衣橱移除。';

  @override
  String get wardrobeDeletedTitle => '已删除';

  @override
  String get wardrobeNotDeletedTitle => '未删除';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已从衣橱移除 $count 件单品。',
      one: '已从衣橱移除 1 件单品。',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI 衣橱识别';

  @override
  String get itemAddScanJobLabel => '扫描';

  @override
  String get itemAddFoundEarlierBody => '已在先前扫描中发现';

  @override
  String get itemAddLookingAtPhoto => '正在查看你的照片';

  @override
  String get itemAddExtractionFailedBody => '提取失败';

  @override
  String get itemAddJobFailedBody => '任务失败';

  @override
  String get itemAddConnectionLostBody => '连接已断开，请重试。';

  @override
  String get itemAddConnectionLostProcessingBody => '处理过程中连接已断开。';

  @override
  String itemAddGeneratingPiece(int number) {
    return '单品 $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => '单品';

  @override
  String get itemAddNotCancelledTitle => '未取消';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件单品已存入衣橱。',
      one: '1 件单品已存入衣橱。',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '已保存 $saved / $total 件单品。点击保存重试其余部分。';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => '部分单品未保存';

  @override
  String get batchChooseAtLeastOnePhotoBody => '请至少选择一张照片。';

  @override
  String get batchPhotoUnreadableBody => '无法读取此照片。';

  @override
  String get batchNoPhotosReadableBody => '无法读取这些照片，请尝试其他照片。';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片',
      one: '1 张照片',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody => '处理时连接已断开，请重试。';

  @override
  String get batchNotCancelledTitle => '未取消';

  @override
  String get batchPostLinkUnsupportedBody => '不支持帖子链接，请输入个人资料链接。';

  @override
  String get batchLinkSpacesBody => '链接不能包含空格。';

  @override
  String get batchEnterProfileLinkBody => '请输入 Instagram 或 Facebook 的个人资料链接。';

  @override
  String get batchEnterProfileLinkShortBody => '请输入个人资料链接。';

  @override
  String get batchSignInPageNotOpenBody => '登录页面未打开，请重试。';

  @override
  String get batchSignInBrowserBody => '请在浏览器中登录，然后返回 FitCheck AI。';

  @override
  String get batchConnectAccountTitle => '绑定账户';

  @override
  String get batchEnterAuthenticatorCodeBody => '请输入来自身份验证器应用中的代码。';

  @override
  String get batchInstagramSecurityCheckBody => 'Instagram 要求安全验证，请先在浏览器中登录。';

  @override
  String get batchEnterCredentialsAgainBody => '请重新输入用户名和密码。';

  @override
  String get batchSignInFailedBody => '登录失败，请检查用户名和密码。';

  @override
  String get batchSignInToKeepImportingBody => '请登录以继续导入。';

  @override
  String get batchAccountNotConnectedBody => '账户未绑定。';

  @override
  String get batchAccountConnectedTitle => '账户已绑定';

  @override
  String get batchNotConnectedTitle => '未连接';

  @override
  String get batchImportConnectionLostBody => '已丢失导入连接。请刷新以检查状态。';

  @override
  String batchPickUpToBody(int max) {
    return '最多选择 $max 张照片。我们会帮你找出单品。';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count/$total 张照片';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '正在准备第 $done 张照片，共 $count 张';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在 $count 张照片中查找单品',
      one: '在 1 张照片中查找单品',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return '您的 $platform 账号使用了两步验证。请输入来自验证器应用的 6 位代码。';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return '此 $platform 资料为私密，或需登录才能显示其照片。';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '通过 $platform 连接';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已找到 $count 张照片',
      one: '已找到 1 张照片',
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
    return '已处理 $processed/$total · 新增 $added · 等待 $waiting · 跳过 $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return '正在扫描第 $number 张照片';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '下一张为第 $number 张照片';
  }

  @override
  String batchPhotoLabel(int number) {
    return '第 $number 张照片';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 件单品',
      one: '找到 1 件单品',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片已添加到你的衣橱。',
      one: '1 张照片已添加到你的衣橱。',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还有 $count 张工作室照片正在处理中。你可以保存已就绪的内容，或先离开——我们会通知你。',
      one: '还有 1 张工作室照片正在处理中。你可以保存已就绪的内容，或先离开——我们会通知你。',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return '尚未保存：$names。';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces 件单品',
      one: '1 件单品',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos 张照片',
      one: '1 张照片',
    );
    return '$_temp0，来自 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '已选择 $chosen 件。点击单品可跳过。';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在保存 $count 件单品',
      one: '正在保存 1 件单品',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '保存 $count 件单品',
      one: '保存 1 件单品',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => '你的体型档案已保存。';

  @override
  String get bodyProfileSavedTitle => '已保存';

  @override
  String get bodyProfileNotSavedTitle => '未保存';

  @override
  String get bodyProfileSetDefaultBody => '设为默认档案。';

  @override
  String get bodyProfileDeletedBody => '体型档案已删除。';

  @override
  String get bodyProfileDeletedTitle => '已删除';

  @override
  String get bodyProfileNotDeletedTitle => '未删除';

  @override
  String get feedbackNotSentTitle => '未发送';

  @override
  String get feedbackSentBody => '谢谢。我们会仔细阅读每一条反馈，如有需要会回复你。';

  @override
  String get feedbackSentTitle => '反馈已发送';

  @override
  String get recommendUnnamedPiece => '未命名单品';

  @override
  String get recommendEnterCityBody => '输入你的城市，以获取适合当地天气的穿搭建议。';

  @override
  String get recommendWhichCityTitle => '选择城市';

  @override
  String get aiConsentSheetTitle => '将照片共享给 AI 服务';

  @override
  String get aiConsentSheetBody =>
      '为了生成你的试衣和拍摄图片，FitCheck AI 会将你提供的照片（包括面部和身体照片）发送给受信任的第三方 AI 提供商（如 OpenAI 或 Google Gemini）进行处理。对方生成你的图片后，不会在协议范围内使用这些图片训练其模型。照片传输安全，绝不用于广告。';

  @override
  String get aiConsentSheetPermission => '继续即表示你明确授权与这些 AI 提供商共享你的照片用于图像生成。';

  @override
  String get skeletonsLoadMoreFailed => '无法加载更多。';

  @override
  String get jobsPiecesReadyTitle => '你的单品已就绪';

  @override
  String get jobsScanStoppedTitle => '扫描已停止';

  @override
  String get jobsNothingSavedBody => '未保存任何内容。请重试。';

  @override
  String get jobsPhotoUploadFailedBody => '照片上传失败。';

  @override
  String get authGoogleSignInStartFailed => '无法启动 Google 登录。请重试。';

  @override
  String get referralAppliedTitle => '推荐已生效！';

  @override
  String get billingStoreUnavailableBody => '此设备不支持商店购买。';

  @override
  String get billingPurchaseProcessingBody => '购买仍在处理中。请稍后重新打开应用查看套餐。';

  @override
  String get profileAvatarUploadNoUrl => '头像上传未返回图片链接。';

  @override
  String get rewardsDayStreakLabel => '天连续打卡';

  @override
  String rewardsBestStreak(int days) {
    return '最佳 $days 天';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '需要 $permission 权限';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission 权限当前被拒绝。请前往设置开启权限，然后返回重试。';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '第 $step 步，共 4 步';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '第 $step 步，共 $total 步';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '移除图片 $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '移除图片 $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points 分';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '发送邮件至 $email。我们将在 24 小时内审核反馈。';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '移除 $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String outfitAddToNamed(String name) {
    return '添加到\"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\"已删除。其中的单品仍保留在你的衣橱中。';
  }

  @override
  String outfitShowAllCount(int count) {
    return '查看全部 $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '今日剩余 $count';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return '照片 $index 失败';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '已选 $selected/$max';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape 体型 · $tone 肤色';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '删除 $name？';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name 的选项';
  }

  @override
  String profileMostWorn(String name, int count) {
    return '最常穿：$name，$count 次';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label：未设置';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '匹配度 $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '已选 $picked/$max';
  }

  @override
  String recommendRemoveItem(String item) {
    return '移除 $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency优先级';
  }

  @override
  String billingBilledThroughStore(String store) {
    return '此套餐通过 $store 扣费。请在 $store 账户设置中更改或取消。';
  }

  @override
  String billingManageInStore(String store) {
    return '在 $store 中管理';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label：已用 $current/$max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return '约剩 $seconds 秒';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done/$total 张影棚照已就绪';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready/$total 张影棚照已就绪。点击单品可跳过。';
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
  String get profileFieldNotSet => '否';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => '首頁';

  @override
  String get tabPhotoshoot => '拍攝';

  @override
  String get tabCloset => '衣櫥';

  @override
  String get tabOutfits => '穿搭';

  @override
  String get tabMore => '更多';

  @override
  String get actionAddItem => '新增單品';

  @override
  String get actionCreateOutfit => '建立穿搭';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '刪除';

  @override
  String get actionSave => '儲存';

  @override
  String get actionRetry => '重試';

  @override
  String get actionDone => '完成';

  @override
  String get actionNext => '下一步';

  @override
  String get actionBack => '返回';

  @override
  String get actionClose => '關閉';

  @override
  String get actionSearch => '搜尋';

  @override
  String get actionContinue => '繼續';

  @override
  String get stateLoading => '載入中';

  @override
  String get stateErrorTitle => '發生錯誤';

  @override
  String get stateErrorBody => '請再試一次。若問題持續，請聯絡客服。';

  @override
  String get stateOfflineTitle => '無網路連線';

  @override
  String get stateOfflineBody => '請連線以同步衣櫥並生成穿搭。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAccountSection => '帳號';

  @override
  String get settingsPreferencesSection => '偏好設定';

  @override
  String get settingsPlanBilling => '方案與帳務';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsUnits => '度量單位';

  @override
  String get settingsAppearance => '外觀';

  @override
  String get settingsPrivacySection => '隱私與資料';

  @override
  String get settingsAboutSection => '關於';

  @override
  String get settingsSignOut => '登出';

  @override
  String get settingsDeleteAccount => '刪除帳號';

  @override
  String get settingsDeleteAccountTitle => '確定刪除帳號？';

  @override
  String get settingsDeleteAccountBody => '這將移除您的衣櫥、穿搭、照片與個人資料。此操作無法復原。';

  @override
  String get settingsUnitsImperial => '英制 (in, lb)';

  @override
  String get settingsUnitsMetric => '公制 (cm, kg)';

  @override
  String get languageTitle => '語言';

  @override
  String get languageSystem => '使用裝置語言';

  @override
  String get languageSystemBody => 'FitCheck AI 將使用您手機的語言設定。';

  @override
  String get languageSearchHint => '搜尋語言';

  @override
  String get languageCurrent => '目前語言';

  @override
  String get languageReviewNote => '此為新翻譯，若有不妥請告知我們。';

  @override
  String get languageChanged => '語言已更新';

  @override
  String get paywallTitle => '選擇您的方案';

  @override
  String get paywallTrialBadge => '首月免費';

  @override
  String get paywallTrialTitle => 'Pro 首月免費';

  @override
  String get paywallTrialBody => '一次上傳您的整個衣櫥，之後可隨時新增單品。';

  @override
  String get paywallFreeForeverTitle => '永久免費';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return '無需綁定信用卡。每月享有 $uploads 次 AI 上傳、$outfits 套穿搭以及每天 $images 張拍攝照片。';
  }

  @override
  String get paywallCtaTrial => '開始免費試用';

  @override
  String paywallCtaUpgrade(String plan) {
    return '升級至 $plan';
  }

  @override
  String get paywallRestore => '恢復購買';

  @override
  String get paywallManage => '管理訂閱';

  @override
  String get paywallTerms => '使用條款';

  @override
  String get paywallPrivacy => '隱私權政策';

  @override
  String get paywallPerMonth => '每月';

  @override
  String get paywallPerYear => '每年';

  @override
  String get paywallBestValue => '最划算';

  @override
  String paywallTrialEligibleOnly(String price) {
    return '僅限新訂閱者享免費試用。試用期後，Pro 將以 $price 自動續訂，除非在試用期結束前至少 24 小時取消。';
  }

  @override
  String get introTitle => '衣櫥，終於井然有序';

  @override
  String get introBody => '只需拍攝一次衣物，即可從現有單品中獲取穿搭靈感、試穿預覽及攝影棚級照片。';

  @override
  String get introStart => '開始使用';

  @override
  String get introHaveAccount => '我已有帳號';

  @override
  String get introSkip => '跳過';

  @override
  String get authSignIn => '登入';

  @override
  String get authSignUp => '建立帳號';

  @override
  String get authEmail => '電子郵件';

  @override
  String get authPassword => '密碼';

  @override
  String get authForgotPassword => '忘記密碼？';

  @override
  String get authContinueApple => '透過 Apple 繼續';

  @override
  String get authContinueGoogle => '透過 Google 繼續';

  @override
  String get authOrDivider => '或';

  @override
  String get wardrobeTitle => '衣櫥';

  @override
  String get wardrobeEmptyTitle => '衣櫥空空如也';

  @override
  String get wardrobeEmptyBody => '新增您的第一件單品，或一次上傳整排衣物的照片。';

  @override
  String get wardrobeAddFirst => '新增第一件單品';

  @override
  String get wardrobeSearchHint => '搜尋衣櫥';

  @override
  String get categoryTops => '上衣';

  @override
  String get categoryBottoms => '下著';

  @override
  String get categoryShoes => '鞋履';

  @override
  String get categoryAccessories => '配件';

  @override
  String get categoryOuterwear => '外套';

  @override
  String get categorySwimwear => '泳裝';

  @override
  String get categoryActivewear => '運動服';

  @override
  String get categoryOther => '其他';

  @override
  String get conditionClean => '乾淨';

  @override
  String get conditionDirty => '待洗';

  @override
  String get conditionLaundry => '待洗衣物';

  @override
  String get conditionRepair => '待修補';

  @override
  String get conditionDonate => '待捐贈';

  @override
  String get seasonSpring => '春季';

  @override
  String get seasonSummer => '夏季';

  @override
  String get seasonFall => '秋季';

  @override
  String get seasonWinter => '冬季';

  @override
  String get seasonAll => '全年';

  @override
  String get styleCasual => '休閒';

  @override
  String get styleFormal => '正式';

  @override
  String get styleBusiness => '商務';

  @override
  String get styleSporty => '運動';

  @override
  String get styleBohemian => '波西米亞';

  @override
  String get styleStreetwear => '街頭';

  @override
  String get styleVintage => '復古';

  @override
  String get styleMinimalist => '極簡';

  @override
  String get styleRomantic => '浪漫';

  @override
  String get styleEdgy => '前衛';

  @override
  String get stylePreppy => '學院';

  @override
  String get styleArtsy => '藝術';

  @override
  String get styleClassic => '經典';

  @override
  String get styleElegant => '優雅';

  @override
  String get styleOther => '其他';

  @override
  String get occasionWork => '工作';

  @override
  String get occasionDateNight => '約會';

  @override
  String get occasionTravel => '旅行';

  @override
  String get occasionWedding => '婚禮';

  @override
  String get occasionGym => '健身';

  @override
  String get occasionWeekend => '週末';

  @override
  String get occasionParty => '派對';

  @override
  String get occasionInterview => '面試';

  @override
  String get colorBlack => '黑色';

  @override
  String get colorWhite => '白色';

  @override
  String get colorGrey => '灰色';

  @override
  String get colorNavy => '海軍藍';

  @override
  String get colorBrown => '棕色';

  @override
  String get colorRed => '紅色';

  @override
  String get colorBlue => '藍色';

  @override
  String get colorGreen => '綠色';

  @override
  String get colorPink => '粉紅色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorYellow => '黃色';

  @override
  String get colorOrange => '橘色';

  @override
  String get colorBeige => '米色';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天前',
      one: '1 天前',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 週前',
      one: '1 週前',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個月前',
      one: '1 個月前',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 年前',
      one: '1 年前',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => '喜歡 FitCheck AI 嗎？';

  @override
  String get ratingPromptBody => '給予評分能幫助其他人找到適合的風格。';

  @override
  String get ratingPromptYes => '評分';

  @override
  String get ratingPromptNo => '稍後再說';

  @override
  String get closetNoMatchesTitle => '沒有符合的單品';

  @override
  String get closetNoMatchesBody => '請嘗試減少篩選條件或重新搜尋。';

  @override
  String get closetClearFilters => '清除篩選';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件單品',
      one: '1 件單品',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => '正在載入您的單品';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已選 $count 件',
      one: '已選 1 件',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => '刪除所選';

  @override
  String get closetCancelSelection => '取消選取';

  @override
  String get closetCloseSearch => '關閉搜尋';

  @override
  String get closetShowGrid => '網格檢視';

  @override
  String get closetShowList => '列表檢視';

  @override
  String get closetShowRows => '行檢視';

  @override
  String get closetStatsTitle => '衣櫥統計';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刪除 $count 件單品？',
      one: '刪除 1 件單品？',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => '使用這些單品的穿搭將會移除它們。';

  @override
  String get closetSortBy => '排序方式';

  @override
  String get closetFavourites => '最愛';

  @override
  String get closetFavourite => '加入最愛';

  @override
  String get closetUnfavourite => '移除最愛';

  @override
  String get closetWoreToday => '今天穿過';

  @override
  String closetWornTimes(int count) {
    return '已穿 $count 次';
  }

  @override
  String get closetCategoryLabel => '類別';

  @override
  String get closetUseCaseLabel => '場合';

  @override
  String get closetAnyUseCase => '不限';

  @override
  String get closetOtherUseCase => '其他場合';

  @override
  String get closetOtherUseCaseHint => '例如：早午餐';

  @override
  String get closetUseUseCase => '使用此場合';

  @override
  String get closetClearAll => '全部清除';

  @override
  String get sortNewest => '最新優先';

  @override
  String get sortOldest => '最舊優先';

  @override
  String get sortName => '名稱 (A–Z)';

  @override
  String get sortMostWorn => '穿著次數最多';

  @override
  String get useCaseInformal => '休閒';

  @override
  String get useCaseDate => '約會';

  @override
  String get useCaseDinner => '晚餐';

  @override
  String get useCaseLunch => '午餐';

  @override
  String get actionSelect => '選擇';

  @override
  String get actionEdit => '編輯';

  @override
  String get actionFilter => '篩選';

  @override
  String get actionSort => '排序';

  @override
  String get actionAll => '全部';

  @override
  String get dashboardStartClosetTitle => '建立你的衣櫥';

  @override
  String get dashboardStartClosetBody => '拍幾件衣服，我們為你標記。';

  @override
  String get dashboardPieces => '件單品';

  @override
  String get dashboardOutfits => '穿搭';

  @override
  String get dashboardDayStreak => '連續天數';

  @override
  String dashboardAddedThisMonth(int count) {
    return '本月新增 $count 件';
  }

  @override
  String dashboardBestStreak(int count) {
    return '最佳紀錄 $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個最愛',
      one: '1 個最愛',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 套儲存穿搭',
      one: '1 套儲存穿搭',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return '最常穿：$name，共 $count 次';
  }

  @override
  String get setupSkip => '跳過設定';

  @override
  String get setupWhoTitle => '為誰進行穿搭？';

  @override
  String get setupWhoBody => '設定試穿與拍攝的模特兒。你可隨時在個人檔案中更改。';

  @override
  String get setupStyleTitle => '你最常穿什麼風格？';

  @override
  String get setupStyleBody => '任選幾項，我們將據此提供穿搭靈感。';

  @override
  String get setupClosetTitle => '新增你的第一批單品';

  @override
  String get setupClosetBody => '拍攝幾件衣服或一堆衣物。每件單品都會自動剪裁並歸檔。';

  @override
  String get setupAddClothes => '新增衣物';

  @override
  String get setupStylesLabel => '風格';

  @override
  String get setupOccasionsLabel => '場合';

  @override
  String get setupSkipStep => '跳過';

  @override
  String get setupLater => '稍後';

  @override
  String get setupSaveError => '無法儲存';

  @override
  String get genderWomen => '女性';

  @override
  String get genderMen => '男性';

  @override
  String get genderNonBinary => '非二元性別';

  @override
  String get genderPreferNotToSay => '不願透露';

  @override
  String get outfitEmptyTitle => '尚無穿搭';

  @override
  String get outfitEmptyBody => '從衣櫥中挑選單品並儲存你的穿搭。';

  @override
  String get outfitNoMatchesTitle => '無符合的穿搭';

  @override
  String get outfitSearchHint => '搜尋你的穿搭';

  @override
  String get outfitLoading => '正在載入穿搭';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 套穿搭',
      one: '1 套穿搭',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => '風格與季節';

  @override
  String get outfitCollections => '收藏';

  @override
  String get outfitDuplicate => '複製';

  @override
  String get outfitDeleteTitle => '刪除此穿搭？';

  @override
  String get outfitDeleteBody => '單品將保留在你的衣櫥中。';

  @override
  String get outfitDrafts => '草稿';

  @override
  String get outfitDraft => '草稿';

  @override
  String get filterStyle => '風格';

  @override
  String get filterSeason => '季節';

  @override
  String get itemDetailDeleteTitle => '刪除此單品？';

  @override
  String get itemDetailDeleteBody => '使用此單品的穿搭將會移除它。';

  @override
  String get itemAddFavourite => '加入最愛';

  @override
  String itemSize(String size) {
    return '尺寸 $size';
  }

  @override
  String get itemColours => '顏色';

  @override
  String get itemMaterial => '材質';

  @override
  String get itemPattern => '圖案';

  @override
  String get itemUseCases => '穿著場合';

  @override
  String get itemKeptIn => '存放於';

  @override
  String get itemPrice => '價格';

  @override
  String get itemBought => '購買日期';

  @override
  String get itemTags => '標籤';

  @override
  String get itemAdded => '新增日期';

  @override
  String get itemTimesWornLabel => '穿搭次數';

  @override
  String get itemLastWornLabel => '上次穿著';

  @override
  String get itemNeverWorn => '未曾穿過';

  @override
  String get authEntryBody => 'FitCheck AI 為您打理衣櫥。規劃穿搭、虛擬試穿、拍攝造型。';

  @override
  String get authCreateCloset => '建立衣櫥';

  @override
  String get authWelcomeBack => '歡迎回來';

  @override
  String get authSignInBody => '登入以開啟您的衣櫥。';

  @override
  String get authCreateAccount => '建立帳號';

  @override
  String get authCreateClosetBody => '只需一分鐘。首批單品免費加入。';

  @override
  String get authName => '姓名';

  @override
  String get authConfirmPassword => '確認密碼';

  @override
  String get authReferralCode => '推薦碼（選填）';

  @override
  String get authResetTitle => '重設密碼';

  @override
  String get authResetBody => '我們將寄送連結至您的信箱以設定新密碼。';

  @override
  String get authSendResetLink => '寄送重設連結';

  @override
  String get authBackToSignIn => '返回登入';

  @override
  String get authEnterEmail => '輸入電子郵件';

  @override
  String get authEnterValidEmail => '請輸入有效的電子郵件';

  @override
  String get authEnterPassword => '輸入密碼';

  @override
  String get authPasswordTooShort => '至少 6 個字元';

  @override
  String get authShowPassword => '顯示密碼';

  @override
  String get authHidePassword => '隱藏密碼';

  @override
  String get authNewHere => '新用戶？';

  @override
  String authConfirmEmail(String email) {
    return '登入前請先驗證 $email。請檢查您的收件匣。';
  }

  @override
  String get authResendEmail => '重新寄送';

  @override
  String get authResendingEmail => '寄送中…';

  @override
  String get authPasswordsDoNotMatch => '密碼不符';

  @override
  String get authEnterName => '輸入姓名';

  @override
  String get authChoosePassword => '設定密碼';

  @override
  String get authHaveAccount => '已有帳號？';

  @override
  String get authCodeAccepted => '驗證碼已接受';

  @override
  String get authCodeNotFound => '找不到驗證碼';

  @override
  String authReferralFrom(String name) {
    return '來自 $name。你們雙方皆可獲得一個月免費。';
  }

  @override
  String get authReferralInvalid => '找不到此驗證碼。';

  @override
  String authResetSent(String email) {
    return '已發送至 $email。請在此手機上開啟連結。';
  }

  @override
  String get introSlide1Title => '一鍵掃描衣櫥';

  @override
  String get introSlide1Body => '拍下衣物堆，每件單品都會自動剪裁並分類。';

  @override
  String get introSlide2Title => '快速穿搭';

  @override
  String get introSlide2Body => '根據您的衣物、行程與天氣，自動生成穿搭建議。';

  @override
  String get introSlide3Title => '穿上身前先預覽';

  @override
  String get introSlide3Body => '在您的照片上試穿，或拍出時尚大片般的造型。';

  @override
  String get settingsTheme => '主題';

  @override
  String get settingsThemeSystem => '系統預設';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsTemperature => '溫度單位';

  @override
  String get settingsEmailUpdates => '電子郵件更新';

  @override
  String get settingsEmailUpdatesBody => '接收新聞與穿搭技巧';

  @override
  String get settingsOutfitReminders => '穿搭提醒';

  @override
  String get settingsOutfitRemindersBody => '提醒您記錄每日穿搭';

  @override
  String get settingsWeeklySummary => '每週總結';

  @override
  String get settingsWeeklySummaryBody => '您的每週穿搭回顧';

  @override
  String get settingsStyleSection => '風格';

  @override
  String get settingsPreferredStyles => '偏好風格';

  @override
  String get settingsPreferredColours => '偏好顏色';

  @override
  String get settingsNoneChosen => '尚未選擇';

  @override
  String get settingsPlanAiSection => '方案與 AI';

  @override
  String get settingsPlanBillingBody => '方案、用量與升級';

  @override
  String get settingsPlanUsageBody => '方案與用量';

  @override
  String get settingsInviteFriends => '邀請好友';

  @override
  String get settingsInviteFriendsBody => '每邀請一位好友加入，即可獲得一個月免費使用';

  @override
  String get settingsAiProvider => 'AI 服務提供商';

  @override
  String get settingsAiProviderBody => '使用您自己的模型進行標記與影像處理';

  @override
  String get settingsAppVersion => '應用程式版本';

  @override
  String get settingsPrivacyTerms => '隱私權與條款';

  @override
  String get settingsReportProblem => '回報問題';

  @override
  String get settingsChangePassword => '更改密碼';

  @override
  String get settingsExportData => '匯出您的資料';

  @override
  String get settingsExportBody => '我們將準備一份包含您所有儲存內容的檔案並開啟下載。';

  @override
  String get settingsExportAction => '匯出';

  @override
  String get settingsCurrentPassword => '目前密碼';

  @override
  String get settingsNewPassword => '新密碼';

  @override
  String get settingsConfirmNewPassword => '確認新密碼';

  @override
  String get settingsEnterCurrentPassword => '輸入您的目前密碼';

  @override
  String get settingsEnterNewPassword => '輸入新密碼';

  @override
  String get settingsPasswordMin8 => '至少使用 8 個字元';

  @override
  String get settingsPasswordNeedsUpper => '加入一個大寫字母';

  @override
  String get settingsPasswordNeedsLower => '加入一個小寫字母';

  @override
  String get settingsPasswordNeedsDigit => '加入一個數字';

  @override
  String get settingsPasswordsNoMatch => '密碼不相符';

  @override
  String get settingsChangeAction => '更改';

  @override
  String get itemAddSnapTitle => '拍攝單品';

  @override
  String get itemAddSnapBody => '我們將辨識照片中的每件單品，並為其製作乾淨的攝影棚風格照。';

  @override
  String get itemAddCamera => '拍照';

  @override
  String get itemAddGallery => '從相簿選擇';

  @override
  String get itemAddOtherWays => '其他新增方式';

  @override
  String get itemAddSeveral => '新增多張照片';

  @override
  String get itemAddSeveralBody => '一次最多 50 張';

  @override
  String get itemAddImportProfile => '從個人檔案匯入';

  @override
  String get itemAddImportProfileBody => 'Instagram 或 Facebook';

  @override
  String get itemAddEnterDetails => '手動輸入詳情';

  @override
  String get itemAddEnterDetailsBody => '無需照片';

  @override
  String get itemManualIntro => '只需輸入名稱，其他資訊可稍後補充。';

  @override
  String get itemManualNameHint => '例如：藍色棉質 T 恤';

  @override
  String get itemManualEnterName => '輸入名稱';

  @override
  String get itemManualNotes => '備註';

  @override
  String get itemManualBrand => '品牌';

  @override
  String get itemManualSize => '尺寸';

  @override
  String get itemManualEnterNumber => '輸入數字';

  @override
  String get itemManualSavePiece => '儲存單品';

  @override
  String get itemManualSaving => '儲存中';

  @override
  String get itemManualSavedTitle => '已儲存';

  @override
  String itemManualSavedBody(String name) {
    return '$name 已加入您的衣櫥。';
  }

  @override
  String get itemManualNotSaved => '未儲存';

  @override
  String get itemManualAddUseCase => '新增用途';

  @override
  String get itemManualAddUseCaseAction => '新增用途';

  @override
  String get itemPhotos => '照片';

  @override
  String get itemAddPhotos => '新增照片';

  @override
  String get itemNoPhotoYet => '尚未上傳照片。您可以先儲存。';

  @override
  String get itemRemovePhoto => '移除照片';

  @override
  String get itemRemovePiece => '移除單品';

  @override
  String get filterConditionLabel => '狀態';

  @override
  String get photoshootStepPhotos => '照片';

  @override
  String get photoshootStepSetup => '設定';

  @override
  String get photoshootStepCreating => '建立中';

  @override
  String get photoshootStepResults => '結果';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return '步驟 $current / $total，$name';
  }

  @override
  String get photoshootOneFailed => '一張照片上傳失敗，請在下方重試。';

  @override
  String photoshootManyFailed(int count) {
    return '$count 張照片上傳失敗，請在下方逐一重試。';
  }

  @override
  String get photoshootFormat => '格式';

  @override
  String get photoshootHowMany => '數量';

  @override
  String get photoshootYourPrompt => '您的提示詞';

  @override
  String get photoshootPromptHint => '屋頂上的黃金時刻，亞麻襯衫';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '建立 $count 張照片',
      one: '建立 1 張照片',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '張照片',
      one: '張照片',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => '無法確認今日額度。';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan 方案：今日剩餘 $remaining / $limit';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => '免費';

  @override
  String get photoshootGallery => '圖庫';

  @override
  String get photoshootUseCamera => '使用相機';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '移除照片 $number';
  }

  @override
  String get photoshootNoPhotosTitle => '未產生照片';

  @override
  String get photoshootNoPhotosBody => '拍攝未產生影像，請再試一次。';

  @override
  String get photoshootNewStyle => '新風格';

  @override
  String get photoshootNewPhotos => '新照片';

  @override
  String photoshootOpenPhoto(int number) {
    return '開啟照片 $number';
  }

  @override
  String get photoshootReportPhoto => '檢舉照片';

  @override
  String get photoshootSaveToGallery => '儲存至圖庫';

  @override
  String get actionUpgrade => '升級';

  @override
  String get referralLimitTitle => '已達今日照片上限';

  @override
  String get referralLimitBody => '免費額度將於明日重置。邀請好友，雙方皆可免費獲得一個月 Pro 會員。';

  @override
  String get referralLimitRefer => '邀請好友';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => '交友軟體';

  @override
  String get photoshootUsePortfolio => '個人作品集';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => '美學風格';

  @override
  String get photoshootUseCustom => '自訂提示詞';

  @override
  String get photoshootDescLinkedin => '專業職場形象照';

  @override
  String get photoshootDescDating => '輕鬆、溫暖且自然';

  @override
  String get photoshootDescPortfolio => '編輯風格，高級時尚感';

  @override
  String get photoshootDescInstagram => '適合社群媒體的生活風格照';

  @override
  String get photoshootDescAesthetic => '憂鬱、藝術感構圖';

  @override
  String get photoshootDescCustom => '描述您想要的風格';

  @override
  String get aspectSquare => '正方形';

  @override
  String get aspectPortrait => '直式';

  @override
  String get aspectLandscape => '橫式';

  @override
  String get aspectTall => '長直式';

  @override
  String get aspectWide => '寬橫式';

  @override
  String get tryOnAppBar => '虛擬試穿';

  @override
  String get tryOnYourPhoto => '您的照片';

  @override
  String get tryOnGarment => '服裝';

  @override
  String get tryOnUploadingPhoto => '正在上傳您的照片';

  @override
  String get tryOnAddPhotoPrompt => '新增一張您的全身照';

  @override
  String get tryOnBodyPhotoHint => '全身照效果最佳';

  @override
  String get tryOnAddPhoto => '新增照片';

  @override
  String get tryOnChangePhoto => '更換照片';

  @override
  String get tryOnPhotoLoadFailed => '無法載入您的照片。';

  @override
  String get tryOnChooseGarment => '選擇服裝照片';

  @override
  String get tryOnChooseOneGarment => '選擇一張服裝照片';

  @override
  String get tryOnGarmentHint => '平鋪或掛拍效果最佳';

  @override
  String get tryOnChange => '更換';

  @override
  String get tryOnCamera => '相機';

  @override
  String get tryOnRemove => '移除';

  @override
  String get tryOnLookTitle => '造型';

  @override
  String get tryOnStyle => '風格';

  @override
  String get tryOnBackground => '背景';

  @override
  String get tryOnPose => '姿勢';

  @override
  String get tryOnDressingUp => '正在為您換裝，大約需要半分鐘。';

  @override
  String get tryOnEmptyResult => '您的試穿結果將顯示於此';

  @override
  String get tryOnReportImage => '回報圖片';

  @override
  String get tryOnCreating => '製作中';

  @override
  String get tryOnTryAgain => '再試一次';

  @override
  String get tryOnCreate => '建立試穿';

  @override
  String get tryOnBackgroundStudioWhite => '攝影棚白';

  @override
  String get tryOnBackgroundStudioGrey => '攝影棚灰';

  @override
  String get tryOnBackgroundUrban => '城市街頭';

  @override
  String get tryOnBackgroundNature => '自然風';

  @override
  String get tryOnBackgroundMinimal => '極簡風';

  @override
  String get tryOnPoseFront => '正面站立';

  @override
  String get tryOnPoseSide => '側面站立';

  @override
  String get tryOnPoseWalking => '行走';

  @override
  String get dashboardGreetingMorning => '早安';

  @override
  String get dashboardGreetingAfternoon => '午安';

  @override
  String get dashboardGreetingEvening => '晚安';

  @override
  String get dashboardWelcome => '歡迎';

  @override
  String get dashboardOpenProfile => '開啟個人檔案';

  @override
  String get dashboardRailToday => '今日';

  @override
  String get dashboardRailRecently => '近期';

  @override
  String get dashboardActivityEmpty => '新單品與穿搭將顯示於此';

  @override
  String get quickAddPiece => '新增單品';

  @override
  String get quickAddPieceBody => '拍照並標記';

  @override
  String get quickBuildOutfit => '建立穿搭';

  @override
  String get quickBuildOutfitBody => '混搭您的單品';

  @override
  String get quickForYou => '為您推薦';

  @override
  String get quickForYouBody => '今日精選';

  @override
  String get quickPlanWeek => '一週規劃';

  @override
  String get quickPlanWeekBody => '按日期安排穿搭';

  @override
  String get referralBannerUrgent => '額度不足？邀請好友加入';

  @override
  String get referralBannerTitle => '推薦好友，各享一個月';

  @override
  String get referralBannerBody => '您與好友皆可獲得一個月 Pro 會籍。';

  @override
  String get referralBannerDismiss => '隱藏一週';

  @override
  String get referralBannerShare => '分享邀請';

  @override
  String get referralBannerCopy => '複製連結';

  @override
  String get itemEditPieceTitle => '編輯單品';

  @override
  String get itemEditDescriptionLabel => '描述';

  @override
  String get itemEditNotSaved => '未儲存';

  @override
  String get itemEditSavedTitle => '已儲存';

  @override
  String get itemEditSavedBody => '變更已儲存。';

  @override
  String get itemEditSavedStalePhotos => '已儲存 — 照片可能已過期';

  @override
  String get itemEditRemovePieceHint => '從單品頁面刪除此件物品。';

  @override
  String get itemEditNoPhotos => '尚未新增照片。請從相簿或相機新增。';

  @override
  String get itemEditKeepPhoto => '保留照片';

  @override
  String get itemEditRemoved => '已移除';

  @override
  String get itemEditAddUseCaseAction => '新增';

  @override
  String get statsNoStatsTitle => '尚無統計數據';

  @override
  String get statsNoStatsBody => '新增幾件單品，即可在此查看衣櫥組成。';

  @override
  String get statsByCategory => '按類別';

  @override
  String get statsTotalValue => '總價值';

  @override
  String get statsMostWorn => '最常穿著';

  @override
  String get statsLeastWorn => '等待穿搭';

  @override
  String get statsUnnamedPiece => '未命名單品';

  @override
  String get jobsTitle => '掃描';

  @override
  String get jobsEmptyTitle => '尚無掃描紀錄';

  @override
  String get jobsEmptyBody => '拍攝單品並在背景處理，進度會顯示於此。';

  @override
  String get jobsNotCancelled => '未取消';

  @override
  String get jobsResume => '繼續';

  @override
  String get jobsReview => '檢視';

  @override
  String get jobsStop => '停止';

  @override
  String get jobsDismiss => '關閉';

  @override
  String get reportTitle => '檢舉內容';

  @override
  String reportIntro(String contentType) {
    return '請告訴我們這則 $contentType 有什麼問題。我們的團隊會審核每一則檢舉。';
  }

  @override
  String get reportReasonInappropriate => '不當或冒犯內容';

  @override
  String get reportReasonNudity => '裸露或色情內容';

  @override
  String get reportReasonHarassment => '騷擾或霸凌';

  @override
  String get reportReasonImpersonation => '冒充他人';

  @override
  String get reportReasonOther => '其他';

  @override
  String get reportDetailsLabel => '補充說明（選填）';

  @override
  String get reportSubmit => '提交檢舉';

  @override
  String get reportSubmittedTitle => '已提交檢舉';

  @override
  String get reportSubmittedBody => '感謝您的回報。我們的團隊將會審核此內容。';

  @override
  String get reportFailedTitle => '無法發送檢舉';

  @override
  String get reportFailedBody => '請再試一次。';

  @override
  String get reportContentTryOnImage => 'AI 試穿圖片';

  @override
  String get reportContentSharedOutfit => '分享的穿搭';

  @override
  String get reportContentPhotoshootImage => 'AI 形象照';

  @override
  String get sharedOutfitTitle => '分享的穿搭';

  @override
  String get sharedOutfitHideTooltip => '隱藏此穿搭';

  @override
  String get sharedOutfitReportTooltip => '檢舉此穿搭';

  @override
  String get sharedOutfitHideTitle => '隱藏此穿搭？';

  @override
  String get sharedOutfitHideBody => '此穿搭將在本裝置隱藏。您也可以選擇檢舉，讓我們的團隊審核並移除。';

  @override
  String get sharedOutfitHideAction => '隱藏';

  @override
  String get sharedOutfitHiddenInfo => '此穿搭將不會再於本裝置顯示。';

  @override
  String get sharedOutfitHiddenToast => '穿搭已隱藏';

  @override
  String get sharedOutfitMissingTitle => '找不到此穿搭';

  @override
  String get sharedOutfitMissingBody => '該穿搭可能已被移除，或連結有誤。';

  @override
  String get sharedOutfitHiddenStateTitle => '您已隱藏此穿搭';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return '若內容不當，請透過隱私權與條款進行檢舉，或寄信至 $email。';
  }

  @override
  String get sharedOutfitCtaTitle => '喜歡這個造型？';

  @override
  String get sharedOutfitCtaBody => '使用您的衣櫥打造類似穿搭。';

  @override
  String get sharedOutfitCtaButton => '取得 FitCheck AI';

  @override
  String get errorTitle => '錯誤';

  @override
  String get errorUnknown => '發生預料外的錯誤';

  @override
  String get errorNoConnection => '無網路連線。請檢查您的網路。';

  @override
  String get errorTimeout => '請求逾時。請再試一次。';

  @override
  String get errorServerError => '伺服器端發生問題。請再試一次。';

  @override
  String get errorBadGateway => '我們的伺服器暫時無法使用。請再試一次。';

  @override
  String get errorServiceUnavailable => '服務暫時無法使用。請稍後再試。';

  @override
  String get errorInternalError => '發生問題。請再試一次。';

  @override
  String get errorUnauthorized => '請登入以繼續。';

  @override
  String get errorForbidden => '您沒有權限存取此項目。';

  @override
  String get errorSessionExpired => '您的工作階段已過期。請重新登入。';

  @override
  String get errorInvalidCredentials => '電子郵件或密碼不正確。';

  @override
  String get errorTokenRefreshFailed => '無法更新工作階段。請重新登入。';

  @override
  String get errorRequestCancelled => '請求已取消。';

  @override
  String get errorInvalidFormat => '不支援此檔案格式。';

  @override
  String get errorFileTooLarge => '檔案過大。';

  @override
  String get errorUploadFailed => '上傳失敗。請再試一次。';

  @override
  String get errorCacheCorrupted => '已儲存資料損毀並已重設。';

  @override
  String get errorCacheNotFound => '尚未儲存任何內容。';

  @override
  String get errorUserNotFound => '找不到該帳號。';

  @override
  String get errorItemNotFound => '該項目不再存在。';

  @override
  String get errorOutfitNotFound => '該穿搭不再存在。';

  @override
  String get rewardsTitle => '獎勵';

  @override
  String get rewardsNoAchievementsTitle => '尚無成就';

  @override
  String get rewardsNoAchievementsBody => '添加單品並規劃穿搭以獲得您的第一個成就。';

  @override
  String get rewardsEmptyLeaderboardTitle => '尚無上榜者';

  @override
  String get rewardsEmptyLeaderboardBody => '規劃穿搭以賺取分數並登上排行榜。';

  @override
  String get legalViewPrivacyPolicy => '檢視隱私權政策';

  @override
  String get aiConsentAgree => '我同意並繼續';

  @override
  String get aiConsentNotNow => '稍後再說';

  @override
  String get imageViewerCloseTooltip => '關閉圖片檢視器';

  @override
  String get updateReadyTitle => '更新已就緒';

  @override
  String get updateReadyBody => '重新啟動 FitCheck AI 以套用最新改進。';

  @override
  String get permissionCameraUsage => 'FitCheck AI 需要相機存取權限，以拍攝您的穿搭與衣櫃物品。';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI 需要相簿存取權限，以選擇您的穿搭與衣櫃物品圖片。';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI 需要將您的 AI 生成穿搭照片儲存至相簿。';

  @override
  String get wardrobeSomePhotosSkipped => '部分照片已略過';

  @override
  String get wardrobePhotosNotAdded => '照片未加入';

  @override
  String get wardrobePhotoNotAdded => '照片未加入';

  @override
  String get wardrobeNotStartedTitle => '尚未開始';

  @override
  String get wardrobeNoRoomTitle => '沒有空間';

  @override
  String get wardrobeAddPhotosSemantic => '加入照片';

  @override
  String get batchAddTileLabel => '新增';

  @override
  String get batchProfileLinkLabel => '個人檔案連結';

  @override
  String get wardrobeImportFromProfileTitle => '從個人檔案匯入';

  @override
  String get wardrobeAddSeveralPhotosTitle => '加入多張照片';

  @override
  String get wardrobeClearAction => '清除';

  @override
  String get wardrobeRefreshTooltip => '重新整理';

  @override
  String get batchNoPhotosYetTitle => '還沒有照片';

  @override
  String get batchChoosePhotosAction => '選擇照片';

  @override
  String get batchWeFindEachPieceBody => '我們找出每件單品並為它拍攝工作室級照片。';

  @override
  String get batchPreparingPhotosSemantic => '正在準備照片';

  @override
  String get batchPhotosProcessedSemantic => '照片已處理';

  @override
  String get batchPasteProfileLinkTitle => '貼上個人檔案連結';

  @override
  String get batchPasteProfileLinkBody =>
      '公開的 Instagram 或 Facebook 個人檔案。我們掃描其照片，並由您選擇要放進衣櫃的內容。';

  @override
  String get batchClearLinkTooltip => '清除連結';

  @override
  String get batchStartingButton => '正在啟動';

  @override
  String get batchStartImportAction => '開始匯入';

  @override
  String get batchReviewEveryPhotoTitle => '您需檢視每張照片';

  @override
  String get batchReviewEveryPhotoBody => '在您核准前，不會加入任何內容。';

  @override
  String get batchPrivateProfilesTitle => '私密個人檔案';

  @override
  String get batchPrivateProfilesBody => '請連結您的帳號。Instagram 也會要求輸入用戶名和密碼。';

  @override
  String get batchUseAnotherLinkAction => '使用其他連結';

  @override
  String get batchSignInNeededTitle => '需要登入';

  @override
  String get batchEnterYourCodeTitle => '輸入代碼';

  @override
  String get batchUseUsernamePasswordAction => '使用用戶名和密碼';

  @override
  String get batchAlreadyConnectedAction => '我已在瀏覽器中連結';

  @override
  String get batchEnterCodeAction => '輸入代碼';

  @override
  String get batchTryAnotherWayAction => '嘗試其他方式';

  @override
  String get batchLiveStatus => '實時';

  @override
  String get batchReconnectingStatus => '重新連線中';

  @override
  String get batchSignInToInstagramTitle => '登入 Instagram';

  @override
  String get batchUsernameLabel => '用戶名';

  @override
  String get batchCodeIfTwoStepLabel => '如使用雙步驟登入，請輸入代碼';

  @override
  String get batchAuthenticatorCodeBody => '請使用驗證器應用程式中的 6 位代碼。代碼會快速更換。';

  @override
  String get batchVerifyAction => '驗證';

  @override
  String get batchFindingPhotosTitle => '正在搜尋照片';

  @override
  String get batchImportPausedTitle => '匯入已暫停';

  @override
  String get batchProcessingPhotosTitle => '正在處理照片';

  @override
  String get batchWaitingNextPhoto => '等待下一張照片';

  @override
  String get batchCancelImportAction => '取消匯入';

  @override
  String get batchNoPiecesInPhotoBody => '此照片中找不到任何單品。';

  @override
  String get batchEditPieceColoursLabel => '顏色，以逗號分隔';

  @override
  String get batchAddToClosetAction => '加入衣櫃';

  @override
  String get batchSkipPhotoAction => '跳過此照片';

  @override
  String get batchImportCompleteTitle => '匯入完成';

  @override
  String get batchImportFailedTitle => '匯入失敗';

  @override
  String get batchImportCancelledTitle => '匯入已取消';

  @override
  String get batchImportErrorBody => '匯入期間發生錯誤。';

  @override
  String get batchNothingMoreImportedBody => '已不再從此個人檔案匯入任何項目。';

  @override
  String get batchViewClosetAction => '查看衣櫥';

  @override
  String get batchStartOverAction => '重新開始';

  @override
  String get wardrobeAddPieceTitle => '新增單品';

  @override
  String get wardrobeAddDetailsTitle => '新增細節';

  @override
  String get wardrobeScanningTitle => '掃描中';

  @override
  String get batchReviewPiecesTitle => '檢視單品';

  @override
  String get wardrobeGalleryAction => '相簿';

  @override
  String get wardrobeCameraAction => '相機';

  @override
  String get wardrobeNewBadge => '新';

  @override
  String get wardrobeRemovePhotoTooltip => '移除照片';

  @override
  String get batchRunInBackgroundTooltip => '背景執行';

  @override
  String get batchStepOneOfTwo => '步驟 1/2';

  @override
  String get batchStepTwoOfTwo => '步驟 2/2';

  @override
  String get batchUploadingPhotosTitle => '上傳照片';

  @override
  String get batchFindingPiecesTitle => '尋找單品';

  @override
  String get batchMakingStudioPhotosTitle => '製作精修照';

  @override
  String get batchStoppedLabel => '已停止';

  @override
  String get batchFindingPiecesStoppedTitle => '停止尋找單品';

  @override
  String get batchCancelledLabel => '已取消';

  @override
  String get batchAllDoneTitle => '全部完成';

  @override
  String get batchOpeningPiecesBody => '正在開啟單品';

  @override
  String get batchNothingSavedBody => '未儲存任何內容。';

  @override
  String get batchFindingPiecesFailedBody => '尋找單品失敗。';

  @override
  String get batchFindingPiecesStoppedEarlyBody => '尋找單品已提前停止。';

  @override
  String get batchStopFindingPiecesTitle => '停止尋找單品？';

  @override
  String get batchStopFindingPiecesBody => '掃描將停止且不會儲存。已找到的單品會保留在活動中，直到您將其關閉。';

  @override
  String get batchKeepGoingAction => '繼續';

  @override
  String get batchTryAgainAction => '再試一次';

  @override
  String get batchBackToPhotosAction => '返回照片';

  @override
  String get batchSkipAllAction => '全數略過';

  @override
  String get batchIncludeAllAction => '全數納入';

  @override
  String get batchNoPiecesFoundTitle => '未找到衣物';

  @override
  String get batchNoPiecesFoundBody => '這些照片中沒有找到任何衣物。';

  @override
  String get batchChooseOtherPhotosAction => '選擇其他照片';

  @override
  String get batchUseCaseHelper => '會套用至您儲存的每一件衣物。';

  @override
  String get batchDiscardPiecesTitle => '要捨棄這些衣物嗎？';

  @override
  String get batchDiscardPiecesBody => '此批次未儲存任何項目。';

  @override
  String get batchKeepAction => '保留';

  @override
  String get batchDiscardAction => '捨棄';

  @override
  String get batchRemovePieceTitle => '要移除這件衣物嗎？';

  @override
  String get batchRemovePieceBody => '它未被儲存到您的衣櫥。';

  @override
  String get batchRemoveAction => '移除';

  @override
  String get batchChoosePiecesToSave => '選擇要儲存的衣物';

  @override
  String get batchDiscardAllAction => '全數捨棄';

  @override
  String get batchNothingSavedRetryBody => '沒有儲存任何項目，請再試一次。';

  @override
  String get batchNotSavedTitle => '未儲存';

  @override
  String get batchSavingLabel => '儲存中';

  @override
  String get batchSendToBackgroundAction => '移至背景執行';

  @override
  String get batchStillWorkingMessage => '仍在處理中，衣物就緒後我們會通知您。';

  @override
  String get batchRunningInBackgroundTitle => '正在背景執行';

  @override
  String get batchStudioPhotosStoppedBody => '棚拍照片已提前停止，您仍可儲存這些衣物。';

  @override
  String get batchTapPieceToSkip => '輕觸衣物即可略過。';

  @override
  String get batchStudioPhotosOnWayBody => '棚拍照片仍在製作中，您可以先離開，完成後我們會通知您。';

  @override
  String get batchLeaveAction => '離開';

  @override
  String get batchPeopleInPhotosTitle => '照片中的人';

  @override
  String get batchIncludeAction => '納入';

  @override
  String get batchSkipAction => '略過';

  @override
  String get batchYourPhotoIsUsedLabel => '使用您的照片';

  @override
  String get batchMakingStudioPhotoLabel => '製作棚拍照片中';

  @override
  String get batchNoStudioPhotoBody => '無棚拍照片，將使用您的照片。';

  @override
  String get batchEnterDetailsYourselfAction => '手動輸入細節';

  @override
  String get batchChooseAnotherPhotoAction => '選擇其他照片';

  @override
  String get batchConnectionLostTitle => '連線中斷';

  @override
  String get batchConnectionLostBody => '請檢查網路連線，然後重試。';

  @override
  String get batchDailyLimitTitle => '已達每日上限';

  @override
  String get batchDailyLimitBodyPaywall => '升級至 Pro 以掃描更多項目，或手動輸入細節。';

  @override
  String get batchDailyLimitBodyFree => '您的掃描額度將在今日重置。現在可手動輸入細節。';

  @override
  String get batchSeePlansAction => '查看方案';

  @override
  String get batchAiBusyTitle => 'AI 處理中';

  @override
  String get batchAiBusyBody => '這是伺服器端問題，請幾分鐘後重試。';

  @override
  String get batchNoPiecesBody => '請使用更清晰的照片，或手動輸入細節。';

  @override
  String get batchScanningUnavailableTitle => '無法掃描';

  @override
  String get batchScanningUnavailableBody => '請暫時手動輸入細節。';

  @override
  String get batchScanDidNotFinishTitle => '掃描未完成';

  @override
  String get batchTryAgainBody => '重試';

  @override
  String get billingTitle => '訂閱方案';

  @override
  String get billingUpgradeHeading => '升級您的方案';

  @override
  String get billingUpgradeOnPlusBody => '功能相同，額度更高。';

  @override
  String get billingUpgradeBody => 'Plus 和 Pro 功能相同。請選擇所需的額度。';

  @override
  String get billingWebUnavailableBody =>
      '線上升級功能尚未開放。仍可使用優惠碼或推薦碼解鎖 Plus 或 Pro。邀請好友以獲得免費月數。';

  @override
  String get billingPlansStale => '無法載入最新方案。價格可能已過時。';

  @override
  String get billingMonthly => '月付';

  @override
  String get billingYearly => '年付';

  @override
  String get billingCurrentPlan => '目前方案';

  @override
  String get billingActive => '啟用中';

  @override
  String get billingThisMonth => '本月';

  @override
  String get billingItemExtractions => '項目識別次數';

  @override
  String get billingOutfitVisualizations => '穿搭視覺化次數';

  @override
  String get billingNearLimitUpgrade => '本月額度即將用盡。請升級以獲取更多額度。';

  @override
  String get billingNearLimitResets => '本月額度即將用盡。下月初將重置。';

  @override
  String get billingStoreUnavailable => '升級功能尚未在商店上架，請稍後再試。';

  @override
  String get billingManageHeading => '管理訂閱方案';

  @override
  String get billingCancelPlan => '取消訂閱';

  @override
  String get billingCancelKeepsAccess => '您可在本期結束前繼續使用服務。';

  @override
  String get billingCancelConfirmTitle => '確定要取消訂閱嗎？';

  @override
  String get billingKeepPlan => '保留方案';

  @override
  String get billingCancelPlanAction => '取消方案';

  @override
  String get billingBilledMonthly => '每月計費';

  @override
  String get billingBilledYearly => '每年計費';

  @override
  String get billingVirtualTryOn => '虛擬試穿';

  @override
  String get billingPrioritySupport => '優先支援';

  @override
  String get billingDisclosureProRenewing => 'Pro 為自動續訂訂閱';

  @override
  String get billingDisclosureBothRenewing => 'Plus 與 Pro 均為自動續訂訂閱';

  @override
  String get billingDisclosureAppleBilling => '付款將於您確認購買時從 Apple ID 扣除。';

  @override
  String get billingDisclosureGoogleBilling => '付款將於您確認購買時從 Google Play 帳戶扣除。';

  @override
  String get billingDisclosureRenewalTerms =>
      '除非您在目前期限結束前至少 24 小時關閉自動續訂，否則您的訂閱將以相同價格自動續訂相同期間。';

  @override
  String get billingDisclosureAppleManage => '隨時可至「設定」>「Apple ID」>「訂閱」管理或取消。';

  @override
  String get billingDisclosureGoogleManage => '隨時可至「Google Play」>「付款與訂閱」管理或取消。';

  @override
  String get billingReferFriend => '推薦好友';

  @override
  String get billingHowItWorks => '運作方式';

  @override
  String get billingHowShareTitle => '分享連結';

  @override
  String get billingHowShareBody => '寄給您的朋友。';

  @override
  String get billingHowSignUpTitle => '好友註冊';

  @override
  String get billingHowSignUpBody => '朋友透過連結加入。';

  @override
  String get billingHowBothTitle => '雙方皆獲 Pro';

  @override
  String get billingHowBothBody => '各得一個月免費 Pro。';

  @override
  String get billingYourReferrals => '您的推薦紀錄';

  @override
  String get billingInvited => '已邀請';

  @override
  String get billingJoined => '已加入';

  @override
  String get billingMonthsEarned => '獲得月數';

  @override
  String get billingInviteFriend => '邀請朋友';

  @override
  String get billingInviteBody => '您和好友各可免費使用 Pro 一個月。';

  @override
  String get billingYourCode => '您的代碼';

  @override
  String get billingCopyLink => '複製連結';

  @override
  String get billingShareInvite => '分享邀請';

  @override
  String get giftUnavailable => '此版本暫不提供禮品邀請。';

  @override
  String get giftPageTitle => '贈送 FitCheck Pro';

  @override
  String get giftNoAllowances => '目前沒有免費禮品邀請可用。';

  @override
  String get giftFormTitle => '發送免費邀請';

  @override
  String get giftFormBody => '收禮者需使用此經驗證的電子郵件地址領取禮品。我們不會代為發送郵件。';

  @override
  String get giftFieldFrom => '寄件人';

  @override
  String get giftFieldRecipientName => '收禮者姓名';

  @override
  String get giftFieldRecipientEmail => '收禮者電子郵件';

  @override
  String get giftFieldOccasion => '場合（選填）';

  @override
  String get giftNoOccasion => '無特定場合';

  @override
  String get giftOccasionBirthday => '生日';

  @override
  String get giftOccasionAnniversary => '紀念日';

  @override
  String get giftOccasionOther => '其他';

  @override
  String get giftFieldCardGreeting => '卡片問候語';

  @override
  String get giftFieldCardGreetingHelper => '內容將完全依原文顯示在卡片上。';

  @override
  String get giftFieldPrivateNote => '私人備註（選填）';

  @override
  String get giftCreateAction => '建立免費禮品';

  @override
  String get giftClaimedTitle => '禮品已領取';

  @override
  String get giftClaimedActive => '您的 FitCheck Pro 禮品已生效。';

  @override
  String get giftClaimedQueued => '您的 FitCheck Pro 禮品將於目前授權期間結束後生效。';

  @override
  String get giftLinkCopied => '禮品連結已複製到剪貼簿。';

  @override
  String get giftErrorName => '請輸入姓名。';

  @override
  String get giftErrorEmail => '請輸入有效的電子郵件地址。';

  @override
  String get giftErrorGreeting => '請輸入卡片問候語。';

  @override
  String get giftErrorGreetingLength => '請使用不超過 80 個字元。';

  @override
  String get giftClaimAction => '領取禮品';

  @override
  String get giftCardPreview => '卡片預覽';

  @override
  String get giftGiftForYou => '贈給你的禮物';

  @override
  String get giftGiftWaiting => '有一份禮物等著你';

  @override
  String get giftOpenBody => '打開禮品並透過已驗證的電子信箱領取。';

  @override
  String get giftOpenGifts => '打開禮品';

  @override
  String get giftSendInvitation => '發送邀請';

  @override
  String get settingsAiProviderSection => '供應商';

  @override
  String get settingsAiCustom => '自訂';

  @override
  String get settingsAiUrlHelper => '使用伺服器可存取的公用 URL。本機位址無法從我們的伺服器運作。';

  @override
  String get settingsAiConnectionSection => '連線';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API 金鑰';

  @override
  String get settingsAiApiKeySaved => '已儲存。留空即可保留。';

  @override
  String get settingsAiChatModel => '對話模型';

  @override
  String get settingsAiVisionModel => '視覺模型（選用）';

  @override
  String get settingsAiImageModel => '影像模型（選用）';

  @override
  String get settingsAiImageModelNote =>
      '影像生成需要相容於 OpenAI 的對話補完與 response_modalities。';

  @override
  String get settingsAiTestConnection => '測試連線';

  @override
  String get calendarTitle => '日曆';

  @override
  String get calendarGoToToday => '回到今天';

  @override
  String get calendarConnectTooltip => '串連日曆';

  @override
  String get calendarAddEvent => '新增事件';

  @override
  String get calendarEmptyTitle => '尚未規劃';

  @override
  String get calendarEmptyBody => '新增事件並規劃穿搭。';

  @override
  String get calendarPreviousMonth => '上一個月';

  @override
  String get calendarNextMonth => '下一個月';

  @override
  String get calendarAllDay => '全天';

  @override
  String get calendarOutfitLinked => '已連結穿搭';

  @override
  String get calendarEventOptions => '事件選項';

  @override
  String get calendarDeleteTitle => '刪除此活動？';

  @override
  String get calendarChangeOutfit => '更換穿搭';

  @override
  String get calendarLinkOutfit => '連結穿搭';

  @override
  String get calendarRemoveOutfit => '移除穿搭';

  @override
  String get calendarNewEvent => '新活動';

  @override
  String get calendarEditEvent => '編輯活動';

  @override
  String get calendarTitleLabel => '標題';

  @override
  String get calendarTitleRequired => '新增標題';

  @override
  String get calendarEndBeforeStart => '結束須晚於開始';

  @override
  String get calendarStarts => '開始';

  @override
  String get calendarEnds => '結束';

  @override
  String get calendarPlaceOptional => '地點（選填）';

  @override
  String get calendarNotesOptional => '備註（選填）';

  @override
  String get calendarLinkOutfitEmptyBody => '組裝穿搭後，連結至此活動。';

  @override
  String get calendarBuildOutfit => '組裝穿搭';

  @override
  String get calendarConnectionsTitle => '日曆';

  @override
  String get calendarConnectionsBody => '在此新增的活動將儲存在 FitCheck AI。';

  @override
  String get calendarDisconnect => '中斷連線';

  @override
  String get calendarNotAvailable => '尚不可用';

  @override
  String get profileSectionExplore => '探索';

  @override
  String get profileNavTryOn => '試穿';

  @override
  String get profileNavRewards => '獎勵';

  @override
  String get profileSupport => '支援';

  @override
  String get profileHelp => '說明';

  @override
  String get profileAbout => '關於';

  @override
  String get profileAboutBody => '衣櫥、穿搭與計劃盡收囊中。';

  @override
  String get profileSignOutTitle => '登出？';

  @override
  String get profileSignOutBody => '您可隨時再次登入。';

  @override
  String get profileEditTitle => '編輯個人檔案';

  @override
  String get profileYourProfile => '您的個人檔案';

  @override
  String get profileBodyProfiles => '體型設定';

  @override
  String get profileBodyEmptyTitle => '尚無體型設定';

  @override
  String get profileBodyEmptyBody => '輸入身高與體型，以獲得更合身的建議。';

  @override
  String get profileBodyAdd => '新增設定';

  @override
  String get profileBodyDefaultNote => '預設設定將用於合身與試穿功能。';

  @override
  String get profileBodyDefaultBadge => '預設';

  @override
  String get profileBodyMakeDefault => '設為預設';

  @override
  String get profileBodyDeleteBody => '此操作無法復原。';

  @override
  String get profileBodyRequired => '必填';

  @override
  String get profileBodyCheckNumber => '請確認數字';

  @override
  String get profileBodyNew => '新體型設定';

  @override
  String get profileBodyNameHint => '例如：我';

  @override
  String get profileBodyHeight => '身高';

  @override
  String get profileBodyWeight => '體重';

  @override
  String get profileBodyBuild => '體型';

  @override
  String get profileBodySkinTone => '膚色';

  @override
  String get profileBirthDateNeededBody => '請補充出生日期以搭配出生時間。';

  @override
  String get profileBirthDateNeededTitle => '需要出生日期';

  @override
  String get profilePartlySavedBody => '姓名與照片已儲存。出生資訊未儲存，請稍後再試。';

  @override
  String get profilePartlySavedTitle => '部分已儲存';

  @override
  String get profileSavedBody => '個人檔案已儲存。';

  @override
  String get profileChangePhoto => '更換個人檔案照片';

  @override
  String get profilePhotoLabel => '個人檔案照片';

  @override
  String get profilePhotoHint => '點按選取新照片';

  @override
  String get profileBirthDateLabel => '出生日期（選填）';

  @override
  String get profileBirthTimeLabel => '出生時間（選填）';

  @override
  String get profileBirthTimeHelper => '讓吠陀建議更精準';

  @override
  String get profileBirthPlaceLabel => '出生地點（選填）';

  @override
  String get profileBirthPlaceHint => '例如：印度新德里';

  @override
  String get profileHelpContactTitle => '有任何問題請問我們';

  @override
  String get profileHelpContactBody => '傳送訊息，我們通常會在一天內以電子郵件回覆。';

  @override
  String get profileHelpContactAction => '聯絡客服';

  @override
  String get profileHelpFaqTitle => '常見問題';

  @override
  String get profileFaqAddPiecesTitle => '如何為我的衣櫥添加單品？';

  @override
  String get profileFaqAddPiecesBody =>
      '點擊「衣櫥」頁籤上的「添加項目」。拍攝照片或從相簿選擇，我們會自動識別並標記每個單品。';

  @override
  String get profileFaqMatchingTitle => '服裝搭配如何運作？';

  @override
  String get profileFaqMatchingBody =>
      '開啟「推薦給你」並選擇您擁有的單品。我們會建議搭配並從您的衣櫥中生成完整造型。';

  @override
  String get profileFaqTryOnTitle => '我可以使用自己的照片進行試穿嗎？';

  @override
  String get profileFaqTryOnBody => '可以。上傳一張您的全身照，然後選擇單品即可預覽上身效果。';

  @override
  String get profileFaqRewardsTitle => '如何賺取獎勵？';

  @override
  String get profileFaqRewardsBody => '經常規劃並記錄造型。隨著時間推移，將累積連勝紀錄與成就。';

  @override
  String get profileFaqPrivacyTitle => '我的衣櫥是私密的嗎？';

  @override
  String get profileFaqPrivacyBody => '是的。除非您分享特定造型的連結，否則您的衣櫥與造型均為私人內容。';

  @override
  String get profileHelpMoreTitle => '更多幫助';

  @override
  String get profileHelpGuides => '指南';

  @override
  String get profileHelpGuidesBody => '各項功能的使用說明';

  @override
  String get feedbackCategoryBug => '出現故障';

  @override
  String get feedbackCategoryIdea => '功能建議';

  @override
  String get feedbackCategoryGeneral => '一般問題';

  @override
  String get feedbackCategoryHelp => '需要協助';

  @override
  String get feedbackHintBug => '發生了什麼事？您預期會怎樣？提供步驟有助於我們修復。';

  @override
  String get feedbackHintIdea => '您想要什麼功能，原因為何？';

  @override
  String get feedbackHintGeneral => '告訴我們您的想法，或提出問題。';

  @override
  String get feedbackAttachmentLimitBody => '最多可添加 5 張圖片。';

  @override
  String get feedbackAttachmentLimitTitle => '已達上限';

  @override
  String get feedbackImageTooLargeBody => '請選擇小於 5 MB 的圖片。';

  @override
  String get feedbackImageTooLargeTitle => '圖片過大';

  @override
  String get feedbackTitle => '傳送回饋';

  @override
  String get feedbackAboutLabel => '關於什麼？';

  @override
  String get feedbackSubjectLabel => '主旨';

  @override
  String get feedbackSubjectRequired => '請輸入主旨';

  @override
  String get feedbackSubjectTooShort => '主旨至少需 3 個字元';

  @override
  String get feedbackDetailsLabel => '詳細內容';

  @override
  String get feedbackDetailsRequired => '請輸入詳細內容';

  @override
  String get feedbackDetailsTooShort => '描述至少需 10 個字元';

  @override
  String get feedbackAddScreenshot => '新增截圖';

  @override
  String get feedbackAttachmentHint => '最多 5 張，單張不超過 5 MB';

  @override
  String get feedbackSend => '傳送';

  @override
  String get feedbackEmptyTitle => '尚未送出內容';

  @override
  String get feedbackEmptyBody => '您送出的內容將顯示在這裡，並附上處理狀態。';

  @override
  String get feedbackHistoryTitle => '已送出的內容';

  @override
  String get feedbackStatusOpen => '未處理';

  @override
  String get feedbackStatusInProgress => '處理中';

  @override
  String get feedbackStatusResolved => '已解決';

  @override
  String get feedbackStatusClosed => '已關閉';

  @override
  String get legalIntro => '說明我們如何保護您的資料，以及使用 FitCheck AI 的條款。';

  @override
  String get legalPolicies => '政策';

  @override
  String get legalPrivacySubtitle => '我們收集哪些資料及原因';

  @override
  String get legalTermsTitle => '服務條款';

  @override
  String get legalTermsSubtitle => '使用本應用程式的規則';

  @override
  String get legalLicences => '開源授權條款';

  @override
  String get legalSupportSubtitle => '支援、聯絡及隱私請求';

  @override
  String get legalReportAbuse => '回報問題或不當使用';

  @override
  String get permissionCameraTitle => '相機存取';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI 使用您的相機拍攝服裝與穿搭照片，用於 AI 試穿及衣櫓整理。';

  @override
  String get permissionPhotoTitle => '相簿存取';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI 需要存取您的照片，讓您可選取服裝與穿搭圖片，用於 AI 功能及衣櫓管理。';

  @override
  String get permissionNotNow => '稍後再說';

  @override
  String get permissionOpenSettings => '開啟設定';

  @override
  String authSignedInAs(String name) {
    return '已登入為 $name';
  }

  @override
  String get authSignedIn => '已登入';

  @override
  String get authWelcomeBackTitle => '歡迎回來';

  @override
  String get authSignInFailed => '登入失敗';

  @override
  String get authWelcomeTitle => '歡迎';

  @override
  String get authSignUpFailed => '註冊失敗';

  @override
  String get authGoogleSignInFailed => 'Google 登入失敗';

  @override
  String get authAppleSignInFailed => 'Apple 登入失敗';

  @override
  String get authConfirmEmailTitle => '確認電子郵件';

  @override
  String get authConfirmEmailBody => '請檢查收件匣中的確認郵件，然後登入。';

  @override
  String get authClosetReady => '您的衣櫃已準備好。';

  @override
  String get authSignedOutTitle => '已登出';

  @override
  String get authSignedOutBody => '您已登出。';

  @override
  String get authSignOutFailed => '登出失敗';

  @override
  String get authEmailSentTitle => '電子郵件已傳送';

  @override
  String get authResetLinkSent => '請檢查電子郵件中的重設連結。';

  @override
  String get authPasswordUpdatedTitle => '密碼已更新';

  @override
  String get authPasswordUpdated => '您的密碼已更新。';

  @override
  String get authPasswordNotUpdated => '密碼未更新';

  @override
  String get authCouldNotSendEmail => '無法傳送電子郵件';

  @override
  String get authEmailNotSent => '未傳送電子郵件';

  @override
  String get authResendSentBody => '我們已傳送新的確認郵件。';

  @override
  String get outfitPreviewWithAi => 'AI 預覽';

  @override
  String get outfitNewPreview => '建立新預覽';

  @override
  String get outfitBuilderClosetHeading => '您的衣櫃';

  @override
  String get outfitBuilderSearchHint => '搜尋單品';

  @override
  String get outfitClearSearch => '清除搜尋';

  @override
  String get outfitBuilderAddPiecesTitle => '先加入單品';

  @override
  String get outfitBuilderAddPiecesBody => '造型由衣櫃中的單品組成。';

  @override
  String get outfitBuilderNoMatches => '沒有相符單品。';

  @override
  String get outfitNameLabel => '造型名稱';

  @override
  String get outfitNameHint => '例如：週末麻布';

  @override
  String get outfitPreviewSemantic => 'AI 穿搭預覽';

  @override
  String get outfitChoosePieces => '選擇衣物';

  @override
  String get outfitTapPiecesHint => '輕點下方衣物以加入。';

  @override
  String get outfitShareTooltip => '分享';

  @override
  String get outfitSaveFavourite => '加入喜愛';

  @override
  String get outfitPiecesHeading => '衣物';

  @override
  String get outfitWearHistoryEmpty => '穿戴一次後，日期將顯示在此。';

  @override
  String get outfitWearHistoryTitle => '穿戴記錄';

  @override
  String get outfitWearHistoryError => '無法載入日期。';

  @override
  String get outfitWornOn => '穿戴日期';

  @override
  String get outfitEditTitle => '編輯穿搭';

  @override
  String get outfitSavedPhotosFailed => '詳細資料已儲存，相片未儲存';

  @override
  String get outfitNoPhotosBody => '尚未有相片，穿搭將顯示其衣物。';

  @override
  String get outfitOccasionLabel => '場合';

  @override
  String get outfitOccasionNone => '無';

  @override
  String get outfitTagsHint => '以逗號分隔';

  @override
  String get outfitDraftBody => '已從主要列表隱藏';

  @override
  String get outfitPublic => '公開';

  @override
  String get outfitPublicBody => '擁有連結者可檢視';

  @override
  String get outfitDeleteFromDetail => '從詳細頁面刪除此穿搭。';

  @override
  String get outfitNewCollection => '新增集錦';

  @override
  String get outfitNoCollectionsTitle => '尚無集錦';

  @override
  String get outfitNoCollectionsBody => '依旅行、季節或心情分組穿搭。';

  @override
  String get outfitCreateCollection => '建立集錦';

  @override
  String get outfitAddOutfits => '新增穿搭';

  @override
  String get outfitRename => '重新命名';

  @override
  String get outfitCollectionDeleteBody => '其中的穿搭將被保留。';

  @override
  String get outfitCollectionsNotLoaded => '穿搭未載入';

  @override
  String get outfitRenameCollection => '重新命名集錦';

  @override
  String get outfitDescriptionOptional => '描述（選填）';

  @override
  String get outfitAllInCollection => '所有穿搭已在此組合中。';

  @override
  String get photoshootSubtitleUpload => '由您的照片生成棚拍肖像';

  @override
  String get photoshootSubtitleConfigure => '選擇風格、格式與數量';

  @override
  String get photoshootSubtitleGenerating => '需約一分至兩分';

  @override
  String get photoshootAddPhotosSemantic => '從相簿添加照片';

  @override
  String get photoshootUploadTitle => '上傳 1 至 4 張您的照片';

  @override
  String get photoshootUploadBody => '輕觸以從相簿選擇';

  @override
  String get photoshootAddToContinue => '添加照片以繼續';

  @override
  String get photoshootAddAnotherPhoto => '添加另一張照片';

  @override
  String get photoshootTipsTitle => '取得最佳效果';

  @override
  String get photoshootTipsBody => '使用清晰、光照均勻的多角度臉部照片。避免佩戴太陽眼鏡或帽子。';

  @override
  String get photoshootStarting => '開始中';

  @override
  String get photoshootCancelling => '取消中';

  @override
  String get photoshootFailed => '失敗';

  @override
  String get recommendTabMatches => '搭配';

  @override
  String get recommendTabComplete => '完整造型';

  @override
  String get recommendTabWeather => '天氣';

  @override
  String get recommendTabColours => '色彩';

  @override
  String get recommendTabShop => '購物';

  @override
  String get recommendNoMatchesTitle => '尚無搭配';

  @override
  String get recommendNoMatchesBody => '選一件單品，我們會找尋適合的搭配。';

  @override
  String get recommendPickPiece => '選一件單品';

  @override
  String get recommendNothingMatchesTitle => '這些單品尚無適合搭配';

  @override
  String get recommendNothingMatchesBody => '嘗試其他單品，或向衣櫃添加更多衣物。';

  @override
  String get recommendChangePieces => '更換單品';

  @override
  String get recommendDefaultReason => '適合您選擇的單品。';

  @override
  String get recommendCompleteTitle => '完成造型';

  @override
  String get recommendCompleteBody => '選一件單品，我們來補齊其餘部分。';

  @override
  String get recommendWorking => '處理中';

  @override
  String get recommendGenerate => '產生';

  @override
  String get recommendChooseStyleBody => '選擇風格，再進行產生。';

  @override
  String get recommendNoLooksTitle => '這些單品沒有搭配造型';

  @override
  String get recommendNoLooksBody => '試試其他風格或單品。';

  @override
  String get recommendDefaultLook => '為你單品打造的造型';

  @override
  String get recommendNoPiecesBody => '此造型沒有搭配到任何單品。';

  @override
  String get recommendCityLabel => '城市';

  @override
  String get recommendCheck => '檢查';

  @override
  String get recommendWeatherTitle => '天氣如何？';

  @override
  String get recommendWeatherBody => '輸入城市，取得今日穿搭建議。';

  @override
  String get recommendWearToday => '今日穿搭';

  @override
  String get recommendWeatherNoPieces => '衣櫃中尚無適合此天氣的單品。';

  @override
  String get recommendBudgetLabel => '預算上限';

  @override
  String get recommendLooking => '尋找';

  @override
  String get recommendFindWhatToBuy => '找出需要添購的單品';

  @override
  String get recommendFillGapsTitle => '補齊缺漏';

  @override
  String get recommendFillGapsBody => '設定預算，我們將建議衣櫃缺少的單品。';

  @override
  String get recommendNoGapsTitle => '未找到缺漏';

  @override
  String get recommendNoGapsBody => '提高預算或換個類別試試。';

  @override
  String get recommendMoodEveryday => '日常';

  @override
  String get recommendMoodBigMeeting => '重要會議';

  @override
  String get recommendDayLabel => '日期';

  @override
  String get recommendReadingStars => '觀星中';

  @override
  String get recommendGetMyColours => '取得我的色系';

  @override
  String get recommendLuckyColoursTitle => '你的幸運色';

  @override
  String get recommendLuckyColoursBody => '選擇日期，我們將建議當天適合的色系與單品。';

  @override
  String get recommendLuckyColoursSection => '幸運色';

  @override
  String get recommendAvoidColoursSection => '較少使用的色系';

  @override
  String get recommendBirthDateTitle => '輸入生日';

  @override
  String get recommendBirthDateBody => '需要出生年月日來解讀你的專屬色系。';

  @override
  String get recommendEditProfile => '編輯個人檔案';

  @override
  String get recommendNothingThisDay => '今日沒有推薦。';

  @override
  String get recommendUnnamedColour => '未命名顏色';

  @override
  String get recommendFromCloset => '來自你的衣櫃';

  @override
  String get recommendNoPiecesInColours => '還沒有這些顏色的單品。';

  @override
  String get recommendOutfitIdeas => '穿搭靈感';

  @override
  String get recommendNoOutfitsInColours => '還沒有這些顏色的完整搭配。';

  @override
  String get recommendDefaultOutfitIdea => '一個穿搭建議';

  @override
  String get recommendPickUpToThree => '選擇最多三件單品';

  @override
  String get recommendEmptyClosetBody => '先添加幾件單品，再回來進行搭配。';

  @override
  String get dashboardDressForDay => '為接下來的日子打造穿搭。';

  @override
  String get dashboardOutfitOfDay => '今日穿搭';

  @override
  String get dashboardFreshLook => '全新造型';

  @override
  String get subscriptionManageInStoreTitle => '在商店中管理';

  @override
  String get subscriptionManageInStoreBody => '此方案透過商店計費。請在商店帳戶設定中管理。';

  @override
  String get subscriptionCancelledTitle => '訂閱已取消';

  @override
  String get subscriptionCancelledBody => '你的方案將在此計費期間結束前保持有效。';

  @override
  String get subscriptionCancelFailedTitle => '無法取消';

  @override
  String get subscriptionCouldNotOpenTitle => '無法開啟';

  @override
  String get subscriptionOpenBillingFailedBody => '無法開啟帳務管理。';

  @override
  String get subscriptionOpenLinkFailedBody => '無法開啟連結。';

  @override
  String get subscriptionReferralLoadFailedTitle => '無法載入你的連結';

  @override
  String get subscriptionReferralLoadFailedBody => '無法載入推薦連結。請再試一次。';

  @override
  String get subscriptionReferralCopiedTitle => '已複製';

  @override
  String get subscriptionReferralCopiedBody => '推薦連結已複製。';

  @override
  String get subscriptionReferralShareSubject => '試試 FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return '加入 FitCheck AI，你我都能獲得一個月 Pro。$link';
  }

  @override
  String get subscriptionLinkCopiedTitle => '連結已複製';

  @override
  String get subscriptionShareUnavailableBody => '無法分享，因此已複製連結。';

  @override
  String get subscriptionShareFailedTitle => '無法分享';

  @override
  String get subscriptionShareFailedBody => '請從推薦頁面複製連結。';

  @override
  String get subscriptionStoreReadyTitle => '商店已就緒';

  @override
  String get subscriptionStoreReadyBody => '商店價格已顯示。您現在可以升級。';

  @override
  String get purchaseFailedTitle => '購買失敗';

  @override
  String get purchaseUnavailableTitle => '無法購買';

  @override
  String get purchaseIapUnavailableBody => '此裝置不支援應用內購買。';

  @override
  String get purchasePlanNotAvailableBody => '此方案目前尚未開放購買。';

  @override
  String get purchasePlanNotInStoreBody => '此方案尚未上架商店。請稍後再試。';

  @override
  String get purchaseStartFailedBody => '無法開始購買。請再試一次。';

  @override
  String get purchaseNoPaymentLinkBody => '結帳未回傳付款連結。';

  @override
  String get purchasePendingTitle => '購買處理中';

  @override
  String get purchasePendingBody => '您的購買正在等待核准。核准後您將立即獲得權限。';

  @override
  String get purchaseFailedBody => '購買失敗。請再試一次。';

  @override
  String get purchaseRestoredTitle => '已恢復';

  @override
  String get purchaseRestoredBody => '您的購買已恢復。';

  @override
  String get purchaseActiveTitle => '訂閱已啟用';

  @override
  String get purchaseActiveBody => '您的訂閱已啟用。歡迎使用。';

  @override
  String get purchaseSignInRequiredTitle => '需要登入';

  @override
  String get purchaseSignInRequiredBody => '請登入以完成購買。';

  @override
  String get purchaseErrorTitle => '購買錯誤';

  @override
  String get purchaseInvalidTransactionBody => '購買未包含可驗證的交易 ID。';

  @override
  String get purchaseVerificationPendingTitle => '驗證中';

  @override
  String get purchaseVerificationPendingBody =>
      '目前無法向商店驗證您的購買。此過程將自動完成，您不會被重複扣款。';

  @override
  String get purchaseNotAppliedTitle => '購買未套用';

  @override
  String get purchaseNotAppliedBody => '無法將購買套用到您的帳戶。請聯絡客服，切勿重複購買。';

  @override
  String get purchaseRestoreFailedTitle => '恢復失敗';

  @override
  String get purchaseRestoreFailedBody => '無法恢復購買。請再試一次。';

  @override
  String get purchaseRecoveredActiveBody => '您的訂閱已啟用。';

  @override
  String get purchaseCompleteTitle => '購買完成';

  @override
  String get giftCreateFailedTitle => '無法建立禮物';

  @override
  String get giftClaimFailedTitle => '無法領取禮品';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 份禮品',
      one: '1 份禮品',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 個月',
      '12': '1 年',
      'other': '$months 個月',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining',
      one: '1',
    );
    return '$duration，剩餘 $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro 會員 $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender 送了你 $duration 的 FitCheck Pro 會員。$link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '送給 $recipient 的 FitCheck Pro 會員禮品';
  }

  @override
  String giftFromSender(String sender) {
    return '來自 $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '送給 $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '來自 $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => '受贈者';

  @override
  String get giftPreviewPlaceholderSender => '你';

  @override
  String get settingsSavedTitle => '已儲存';

  @override
  String get settingsNotSavedTitle => '未儲存';

  @override
  String get settingsAiChooseProviderBody => '請選擇供應商。';

  @override
  String get settingsAiCustomUrlRequiredBody => '自訂供應商需要 API URL。';

  @override
  String get settingsAiKeyRequiredBody => '請輸入 API 金鑰。';

  @override
  String get settingsAiSavedBody => '您的 AI 設定已儲存。';

  @override
  String get settingsAiMissingDetailsTitle => '缺少資訊';

  @override
  String get settingsAiUrlAndModelRequiredBody => '請輸入 API URL 和聊天模型以進行測試。';

  @override
  String get settingsAiKeyNeededTitle => '需要 API 金鑰';

  @override
  String get settingsAiKeyToTestPrivateBody => '請輸入您的 API 金鑰以進行測試。您儲存的金鑰會保持保密。';

  @override
  String get settingsAiKeyToTestBody => '請輸入您的 API 金鑰以進行測試。';

  @override
  String get settingsAiConnectedTitle => '已連接';

  @override
  String get settingsAiConnectedBody => '連接正常。';

  @override
  String get settingsAiTestFailedTitle => '測試失敗';

  @override
  String get settingsPreferencesSavedBody => '您的偏好設定已儲存。';

  @override
  String get settingsPasswordNotChangedTitle => '密碼未變更';

  @override
  String get settingsOAuthPasswordBody =>
      '此帳號使用 Google 或 Apple 登入。請先使用「忘記密碼」設定密碼。';

  @override
  String get settingsCurrentPasswordIncorrectBody => '目前密碼不正確。';

  @override
  String get settingsExportReadyTitle => '匯出就緒';

  @override
  String get settingsExportReadyBody => '您的資料匯出已準備好下載。';

  @override
  String get settingsLinkCopiedTitle => '已複製連結';

  @override
  String get settingsExportClipboardBody => '無法開啟瀏覽器，已複製下載連結。請盡快貼上瀏覽器：連結會過期。';

  @override
  String get settingsExportFailedTitle => '匯出失敗';

  @override
  String get settingsAccountNotDeletedTitle => '未刪除帳戶';

  @override
  String photoshootPhotoLimit(int max) {
    return '最多可新增 $max 張照片。';
  }

  @override
  String get photoshootPhotoLimitTitle => '照片數量上限';

  @override
  String get photoshootAddAtLeastOnePhoto => '請至少新增一張照片。';

  @override
  String get photoshootNoPhotosSelectedTitle => '未選取照片';

  @override
  String get photoshootDescribeLookBody => '請描述您想要的造型。';

  @override
  String get photoshootPromptNeededTitle => '需要提示';

  @override
  String get photoshootConsentFeatureLabel => 'AI 拍攝';

  @override
  String get photoshootStatusPreparing => '正在準備您的照片';

  @override
  String get photoshootStatusGenerating => '產生中';

  @override
  String photoshootStatusBatch(int current, int total) {
    return '批次 $current / $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done / $total 已完成';
  }

  @override
  String get photoshootGenerationFailedBody => '產生失敗。';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready 個就緒，$failed 個失敗。';
  }

  @override
  String get photoshootPartlyDoneTitle => '部分完成';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 張照片已就緒。',
      one: '1 張照片已就緒。',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => '已失去連線。請再試一次。';

  @override
  String get photoshootCouldNotCancelTitle => '無法取消';

  @override
  String get photoshootRetryFailedTitle => '重試失敗';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return '照片 $number 已就緒。';
  }

  @override
  String get photoshootReplacedTitle => '已取代';

  @override
  String get photoshootSavedToGalleryBody => '已儲存至您的相簿。';

  @override
  String get photoshootSavedTitle => '已儲存';

  @override
  String get photoshootNotSavedTitle => '未儲存';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '所有 $count 張照片已存入相簿。',
      one: '1 張照片已存入相簿。',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '已儲存 $saved / $total。';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => '部分照片未儲存';

  @override
  String get tryonConsentFeatureLabel => '虛擬試穿';

  @override
  String get tryonAvatarUpdatedBody => '您的照片已更新。';

  @override
  String get tryonSavedTitle => '已儲存';

  @override
  String get tryonUploadFailedTitle => '上傳失敗';

  @override
  String get tryonChooseGarmentFirstBody => '請先選擇服裝照片。';

  @override
  String get tryonNoGarmentTitle => '無服裝';

  @override
  String get tryonWaitForUploadBody => '請等待照片上傳完成。';

  @override
  String get tryonStillUploadingTitle => '上傳中';

  @override
  String get tryonAddYourPhotoFirstBody => '請先添加您的個人照片。';

  @override
  String get tryonReadyBody => '試穿已就緒。';

  @override
  String get tryonFailedTitle => '試穿失敗';

  @override
  String get tryonSavedToGalleryBody => '已儲存至相簿。';

  @override
  String get tryonNotSavedTitle => '未儲存';

  @override
  String get calendarEventAddedBody => '活動已新增';

  @override
  String get calendarEventPlannedTitle => '已規劃';

  @override
  String get calendarEventSavedBody => '活動已儲存';

  @override
  String get calendarSavedTitle => '已儲存';

  @override
  String get calendarEventNotSavedTitle => '活動未儲存';

  @override
  String get calendarEventRemovedBody => '活動已移除';

  @override
  String get calendarEventDeletedTitle => '已刪除';

  @override
  String get calendarEventNotDeletedTitle => '活動未刪除';

  @override
  String get calendarOutfitNotLinkedTitle => '造型未連結';

  @override
  String get calendarLinkedTitle => '已連結';

  @override
  String get calendarOutfitNotRemovedTitle => '造型未移除';

  @override
  String get calendarOutfitRemovedBody => '造型已移除';

  @override
  String get calendarDisconnectedBody => '行事曆已斷開連結';

  @override
  String get calendarDisconnectedTitle => '已斷開連結';

  @override
  String get calendarNotDisconnectedTitle => '行事曆未斷開連結';

  @override
  String get calendarTodayLabel => '今天';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個活動',
      one: '1 個活動',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start 至 $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, 已連結造型';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '「$title」將被移除。';
  }

  @override
  String get calendarThisAppLabel => '此應用程式';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '尚無法與 $provider 同步。仍可在此新增活動。';
  }

  @override
  String get calendarWeekdaySunShort => '日';

  @override
  String get calendarWeekdayMonShort => '一';

  @override
  String get calendarWeekdayTueShort => '二';

  @override
  String get calendarWeekdayWedShort => '三';

  @override
  String get calendarWeekdayThuShort => '四';

  @override
  String get calendarWeekdayFriShort => '五';

  @override
  String get calendarWeekdaySatShort => '六';

  @override
  String get calendarWeekdayMonday => '星期一';

  @override
  String get calendarWeekdayTuesday => '星期二';

  @override
  String get calendarWeekdayWednesday => '星期三';

  @override
  String get calendarWeekdayThursday => '星期四';

  @override
  String get calendarWeekdayFriday => '星期五';

  @override
  String get calendarWeekdaySaturday => '星期六';

  @override
  String get calendarWeekdaySunday => '星期日';

  @override
  String get outfitSavedToFavouritesBody => '已儲存至收藏';

  @override
  String get outfitRemovedFromFavouritesBody => '已從收藏中移除';

  @override
  String get outfitNotSavedTitle => '未儲存';

  @override
  String get outfitLoggedAsWornBody => '已記錄為今日穿著。';

  @override
  String get outfitNicePickTitle => '好眼光';

  @override
  String get outfitRemovedBody => '造型已移除。';

  @override
  String get outfitDeletedTitle => '已刪除';

  @override
  String get outfitNotDeletedTitle => '未刪除';

  @override
  String get outfitDuplicatedBody => '副本已儲存在你的搭配中。';

  @override
  String get outfitDuplicatedTitle => '重複';

  @override
  String get outfitNotDuplicatedTitle => '未重複';

  @override
  String get outfitNotSharedTitle => '未分享';

  @override
  String outfitCollectionReadyBody(String name) {
    return '「$name」已就緒。';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collection 未建立';

  @override
  String get outfitCollectionUpdatedBody => 'Collection 已更新。';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collection 未更新';

  @override
  String get outfitCollectionDeletedBody => 'Collection 已刪除。';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collection 未刪除';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '新增 $count 套搭配。',
      one: '新增 1 套搭配。',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => '搭配未新增';

  @override
  String get outfitPreviewNotCreatedTitle => '預覽未建立';

  @override
  String get outfitGiveNameBody => '為搭配命名。';

  @override
  String get outfitNameMissingTitle => '名稱';

  @override
  String get outfitChooseAtLeastOnePieceBody => '請至少選擇一件單品。';

  @override
  String outfitCreatedBody(String name) {
    return '$name 已加入你的搭配。';
  }

  @override
  String get outfitSavedTitle => '已儲存';

  @override
  String get wardrobeAddedToFavouritesBody => '已加入最愛';

  @override
  String get wardrobeRemovedFromFavouritesBody => '已從最愛移除';

  @override
  String get wardrobeNotSavedTitle => '未儲存';

  @override
  String get wardrobeLoggedAsWornBody => '已記為今日穿著。';

  @override
  String get wardrobeRemovedFromClosetBody => '已從你的衣櫃移除。';

  @override
  String get wardrobeDeletedTitle => '已刪除';

  @override
  String get wardrobeNotDeletedTitle => '未刪除';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已從你的衣櫃移除 $count 件單品。',
      one: '已從你的衣櫃移除 1 件單品。',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI 衣櫃識別';

  @override
  String get itemAddScanJobLabel => '掃描';

  @override
  String get itemAddFoundEarlierBody => '已在先前掃描中發現';

  @override
  String get itemAddLookingAtPhoto => '正在查看你的照片';

  @override
  String get itemAddExtractionFailedBody => '提取失敗';

  @override
  String get itemAddJobFailedBody => '任務失敗';

  @override
  String get itemAddConnectionLostBody => '連線已斷開。請重試。';

  @override
  String get itemAddConnectionLostProcessingBody => '處理中連線中斷。';

  @override
  String itemAddGeneratingPiece(int number) {
    return '單品 $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => '單品';

  @override
  String get itemAddNotCancelledTitle => '未取消';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件單品已進入您的衣櫃。',
      one: '1 件單品已進入您的衣櫃。',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '已儲存 $saved / $total 件單品。點擊儲存以重試其餘項目。';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => '部分單品未儲存';

  @override
  String get batchChooseAtLeastOnePhotoBody => '請至少選擇一張照片。';

  @override
  String get batchPhotoUnreadableBody => '無法讀取此照片。';

  @override
  String get batchNoPhotosReadableBody => '這些照片均無法讀取。請嘗試其他照片。';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 張照片',
      one: '1 張照片',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody => '處理時連線中斷。請重試。';

  @override
  String get batchNotCancelledTitle => '未取消';

  @override
  String get batchPostLinkUnsupportedBody => '不支援貼文連結。請輸入個人主頁連結。';

  @override
  String get batchLinkSpacesBody => '連結中不能包含空格。';

  @override
  String get batchEnterProfileLinkBody => '請輸入 Instagram 或 Facebook 個人主頁連結。';

  @override
  String get batchEnterProfileLinkShortBody => '請輸入個人主頁連結。';

  @override
  String get batchSignInPageNotOpenBody => '登入頁面未開啟。請重試。';

  @override
  String get batchSignInBrowserBody => '請在瀏覽器中登入，然後返回 FitCheck。';

  @override
  String get batchConnectAccountTitle => '連結您的帳戶';

  @override
  String get batchEnterAuthenticatorCodeBody => '請輸入驗證器應用程式中的驗證碼。';

  @override
  String get batchInstagramSecurityCheckBody => 'Instagram 要求安全驗證。請先在瀏覽器中登入。';

  @override
  String get batchEnterCredentialsAgainBody => '請重新輸入您的使用者名稱和密碼。';

  @override
  String get batchSignInFailedBody => '登入失敗。請檢查您的使用者名稱和密碼。';

  @override
  String get batchSignInToKeepImportingBody => '請登入以繼續匯入。';

  @override
  String get batchAccountNotConnectedBody => '您的帳戶未連結。';

  @override
  String get batchAccountConnectedTitle => '帳戶已連結';

  @override
  String get batchNotConnectedTitle => '未連線';

  @override
  String get batchImportConnectionLostBody => '已中斷與匯入的連線。請重新整理以檢查。';

  @override
  String batchPickUpToBody(int max) {
    return '最多選擇 $max 張照片，我們會為您找出服飾。';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count / $total 張';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '正在準備第 $done / $count 張照片';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '在 $count 張照片中尋找服飾',
      one: '在 1 張照片中尋找服飾',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return '您的 $platform 帳號使用兩階段登入。請輸入驗證器應用程式中的 6 位數代碼。';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return '此 $platform 個人檔案為私密，或需要登入才能顯示其照片。';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '透過 $platform 連線';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '目前找到 $count 張照片',
      one: '目前找到 1 張照片',
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
    return '已處理 $processed / $total · 已新增 $added · 等待中 $waiting · 已略過 $skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return '正在掃描第 $number 張照片';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '下一張為第 $number 張';
  }

  @override
  String batchPhotoLabel(int number) {
    return '第 $number 張';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 件服飾',
      one: '找到 1 件服飾',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已將 $count 張照片加入您的衣櫥。',
      one: '1 張照片已加入您的衣櫥。',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '還有 $count 張工作室照片處理中。您可以先儲存已準備好的項目，或離開——我們會通知您。',
      one: '還有 1 張工作室照片處理中。您可以先儲存已準備好的項目，或離開——我們會通知您。',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return '尚未儲存：$names。';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces 件服飾',
      one: '1 件服飾',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos 張照片',
      one: '1 張照片',
    );
    return '$_temp0 取自 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '已選擇 $chosen 項。輕点服飾以略過。';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '正在儲存 $count 件',
      one: '正在儲存 1 件',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '儲存 $count 件',
      one: '儲存 1 件',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => '您的體型檔案已儲存。';

  @override
  String get bodyProfileSavedTitle => '已儲存';

  @override
  String get bodyProfileNotSavedTitle => '未儲存';

  @override
  String get bodyProfileSetDefaultBody => '設為您的預設檔案。';

  @override
  String get bodyProfileDeletedBody => '已刪除體型檔案。';

  @override
  String get bodyProfileDeletedTitle => '已刪除';

  @override
  String get bodyProfileNotDeletedTitle => '未刪除';

  @override
  String get feedbackNotSentTitle => '未送出';

  @override
  String get feedbackSentBody => '謝謝。我們會閱讀每則訊息，必要時回覆。';

  @override
  String get feedbackSentTitle => '回饋已送出';

  @override
  String get recommendUnnamedPiece => '未命名單品';

  @override
  String get recommendEnterCityBody => '輸入您的城市，以獲得天氣建議。';

  @override
  String get recommendWhichCityTitle => '哪個城市？';

  @override
  String get aiConsentSheetTitle => '與AI服務共享照片';

  @override
  String get aiConsentSheetBody =>
      '為了建立您的試穿和攝影效果圖，FitCheck AI 會將您提供的照片（包括面部和身體影像）傳送至可信的第三方AI供應商（例如 OpenAI 或 Google Gemini）進行處理。這些供應商生成圖片，並依據我們的條款，不將其用於模型訓練。照片以安全方式傳輸，絕不會用於廣告。';

  @override
  String get aiConsentSheetPermission => '繼續即表示您明確許可將照片與這些AI供應商共享以生成圖片。';

  @override
  String get skeletonsLoadMoreFailed => '無法載入更多。';

  @override
  String get jobsPiecesReadyTitle => '您的單品已準備好';

  @override
  String get jobsScanStoppedTitle => '掃描已停止';

  @override
  String get jobsNothingSavedBody => '沒有內容儲存。請再試一次。';

  @override
  String get jobsPhotoUploadFailedBody => '照片上傳失敗。';

  @override
  String get authGoogleSignInStartFailed => '無法啟動 Google 登入。請重試。';

  @override
  String get referralAppliedTitle => '推薦已套用！';

  @override
  String get billingStoreUnavailableBody => '此裝置無法進行商店購買。';

  @override
  String get billingPurchaseProcessingBody => '此購買仍在處理中。請稍後重新開啟應用程式以查看您的方案。';

  @override
  String get profileAvatarUploadNoUrl => '頭像上傳未傳回圖片網址。';

  @override
  String get rewardsDayStreakLabel => '天連擊';

  @override
  String rewardsBestStreak(int days) {
    return '最佳 $days 天';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '需要$permission存取權限';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '目前$permission存取權限已被拒絕。請開啟設定允許，然後返回重試。';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '步驟 $step / 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '步驟 $step / $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '移除圖片 $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '移除圖片 $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points 分';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '請致電 $email。我們將在 24 小時內檢視報告。';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '移除 $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '刪除「$name」？';
  }

  @override
  String outfitAddToNamed(String name) {
    return '加入「$name」';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '「$name」已移除。該組合中的服飾仍會保留在你的衣櫃中。';
  }

  @override
  String outfitShowAllCount(int count) {
    return '顯示全部 $count 項';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '今日剩餘 $count 次';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return '第 $index 張失敗';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '已選 $selected / $max 張';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape 體型 · $tone 膚色';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '要刪除 $name 嗎？';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name 的設定';
  }

  @override
  String profileMostWorn(String name, int count) {
    return '穿過最多次：$name，$count 次';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label：未設定';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '匹配度 $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '已選 $picked / $max 項';
  }

  @override
  String recommendRemoveItem(String item) {
    return '移除 $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency 優先級';
  }

  @override
  String billingBilledThroughStore(String store) {
    return '此方案透過 $store 計費。請在你的 $store 帳戶設定中變更或取消。';
  }

  @override
  String billingManageInStore(String store) {
    return '在 $store 中管理';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label：已使用 $current / $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return '約剩 $seconds 秒';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done / $total 張工作室照片已就緒';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready / $total 張工作室照片已就緒。輕點服飾即可跳過。';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '身高 $height cm · 體重 $weight kg';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value $label';
  }

  @override
  String get profileFieldNotSet => '否';
}
