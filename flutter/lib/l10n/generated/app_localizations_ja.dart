// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabPhotoshoot => '撮影';

  @override
  String get tabCloset => 'クローゼット';

  @override
  String get tabOutfits => 'コーデ';

  @override
  String get tabMore => 'その他';

  @override
  String get actionAddItem => 'アイテム追加';

  @override
  String get actionCreateOutfit => 'コーデ作成';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionDelete => '削除';

  @override
  String get actionSave => '保存';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionDone => '完了';

  @override
  String get actionNext => '次へ';

  @override
  String get actionBack => '戻る';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionSearch => '検索';

  @override
  String get actionContinue => '続ける';

  @override
  String get stateLoading => '読み込み中';

  @override
  String get stateErrorTitle => 'エラーが発生しました';

  @override
  String get stateErrorBody => '再試行してください。解決しない場合はサポートまでご連絡ください。';

  @override
  String get stateOfflineTitle => 'オフラインです';

  @override
  String get stateOfflineBody => 'ネットワークに接続して、クローゼットの同期やコーデ生成を行ってください。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAccountSection => 'アカウント';

  @override
  String get settingsPreferencesSection => '環境設定';

  @override
  String get settingsPlanBilling => 'プランと支払い';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsUnits => '単位設定';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsPrivacySection => 'プライバシーとデータ';

  @override
  String get settingsAboutSection => 'アプリについて';

  @override
  String get settingsSignOut => 'サインアウト';

  @override
  String get settingsDeleteAccount => 'アカウントを削除';

  @override
  String get settingsDeleteAccountTitle => 'アカウントを削除しますか？';

  @override
  String get settingsDeleteAccountBody =>
      'クローゼット、コーディネート、写真、プロフィールがすべて削除されます。この操作は取り消せません。';

  @override
  String get settingsUnitsImperial => 'ヤード・ポンド法 (in, lb)';

  @override
  String get settingsUnitsMetric => 'メートル法 (cm, kg)';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => '端末の設定に従う';

  @override
  String get languageSystemBody => 'FitCheck AIは端末の言語設定を使用します。';

  @override
  String get languageSearchHint => '言語を検索';

  @override
  String get languageCurrent => '現在';

  @override
  String get languageReviewNote => 'この翻訳は新規です。不自然な点があればお知らせください。';

  @override
  String get languageChanged => '言語を更新しました';

  @override
  String get paywallTitle => 'プランを選択';

  @override
  String get paywallTrialBadge => '1ヶ月無料';

  @override
  String get paywallTrialTitle => 'Proの最初の1ヶ月が無料';

  @override
  String get paywallTrialBody => 'クローゼットのアイテムを一括アップロード。その後も自由に追加できます。';

  @override
  String get paywallFreeForeverTitle => 'ずっと無料';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'カード登録不要。毎月、AIアップロード$uploads回、コーディネート作成$outfits回、フォトシュート画像$images枚まで利用可能です。';
  }

  @override
  String get paywallCtaTrial => '1ヶ月無料で始める';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$planにアップグレード';
  }

  @override
  String get paywallRestore => '購入を復元';

  @override
  String get paywallManage => 'サブスクリプションを管理';

  @override
  String get paywallTerms => '利用規約';

  @override
  String get paywallPrivacy => 'プライバシーポリシー';

  @override
  String get paywallPerMonth => '月額';

  @override
  String get paywallPerYear => '年額';

  @override
  String get paywallBestValue => '一番お得';

  @override
  String paywallTrialEligibleOnly(String price) {
    return '無料トライアルは新規登録者のみ対象です。トライアル終了の24時間前までに解約しない限り、Proは$priceで自動更新されます。';
  }

  @override
  String get introTitle => 'クローゼットを整理しよう';

  @override
  String get introBody => '服を撮影するだけで、手持ちの服を使ったコーディネート提案や試着プレビュー、スタジオ風写真が楽しめます。';

  @override
  String get introStart => '始める';

  @override
  String get introHaveAccount => 'すでにアカウントをお持ちの方';

  @override
  String get introSkip => 'スキップ';

  @override
  String get authSignIn => 'サインイン';

  @override
  String get authSignUp => 'アカウント作成';

  @override
  String get authEmail => 'メールアドレス';

  @override
  String get authPassword => 'パスワード';

  @override
  String get authForgotPassword => 'パスワードをお忘れですか？';

  @override
  String get authContinueApple => 'Appleで続ける';

  @override
  String get authContinueGoogle => 'Googleで続ける';

  @override
  String get authOrDivider => 'または';

  @override
  String get wardrobeTitle => 'クローゼット';

  @override
  String get wardrobeEmptyTitle => 'クローゼットは空です';

  @override
  String get wardrobeEmptyBody => '最初のアイテムを追加するか、まとめて写真をアップロードしましょう。';

  @override
  String get wardrobeAddFirst => 'アイテムを追加';

  @override
  String get wardrobeSearchHint => 'クローゼットを検索';

  @override
  String get categoryTops => 'トップス';

  @override
  String get categoryBottoms => 'ボトムス';

  @override
  String get categoryShoes => 'シューズ';

  @override
  String get categoryAccessories => 'アクセサリー';

  @override
  String get categoryOuterwear => 'アウター';

  @override
  String get categorySwimwear => 'スイムウェア';

  @override
  String get categoryActivewear => 'アクティブウェア';

  @override
  String get categoryOther => 'その他';

  @override
  String get conditionClean => '洗濯済み';

  @override
  String get conditionDirty => '未洗濯';

  @override
  String get conditionLaundry => '洗濯中';

  @override
  String get conditionRepair => '要修理';

  @override
  String get conditionDonate => '寄付予定';

  @override
  String get seasonSpring => '春';

  @override
  String get seasonSummer => '夏';

  @override
  String get seasonFall => '秋';

  @override
  String get seasonWinter => '冬';

  @override
  String get seasonAll => 'オールシーズン';

  @override
  String get styleCasual => 'カジュアル';

  @override
  String get styleFormal => 'フォーマル';

  @override
  String get styleBusiness => 'ビジネス';

  @override
  String get styleSporty => 'スポーティ';

  @override
  String get styleBohemian => 'ボヘミアン';

  @override
  String get styleStreetwear => 'ストリート';

  @override
  String get styleVintage => 'ヴィンテージ';

  @override
  String get styleMinimalist => 'ミニマル';

  @override
  String get styleRomantic => 'ロマンティック';

  @override
  String get styleEdgy => 'エッジィ';

  @override
  String get stylePreppy => 'プレッピー';

  @override
  String get styleArtsy => 'アーティ';

  @override
  String get styleClassic => 'クラシック';

  @override
  String get styleElegant => 'エレガント';

  @override
  String get styleOther => 'その他';

  @override
  String get occasionWork => '仕事';

  @override
  String get occasionDateNight => 'デート';

  @override
  String get occasionTravel => '旅行';

  @override
  String get occasionWedding => '結婚式';

  @override
  String get occasionGym => 'ジム';

  @override
  String get occasionWeekend => '週末';

  @override
  String get occasionParty => 'パーティー';

  @override
  String get occasionInterview => '面接';

  @override
  String get colorBlack => 'ブラック';

  @override
  String get colorWhite => 'ホワイト';

  @override
  String get colorGrey => 'グレー';

  @override
  String get colorNavy => 'ネイビー';

  @override
  String get colorBrown => 'ブラウン';

  @override
  String get colorRed => 'レッド';

  @override
  String get colorBlue => 'ブルー';

  @override
  String get colorGreen => 'グリーン';

  @override
  String get colorPink => 'ピンク';

  @override
  String get colorPurple => 'パープル';

  @override
  String get colorYellow => 'イエロー';

  @override
  String get colorOrange => 'オレンジ';

  @override
  String get colorBeige => 'ベージュ';

  @override
  String get dateToday => '今日';

  @override
  String get dateYesterday => '昨日';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日前',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count週間前',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countヶ月前',
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
  String get ratingPromptTitle => 'FitCheck AIを楽しんでいますか？';

  @override
  String get ratingPromptBody => '評価していただくと、他のユーザーがスタイルを見つけやすくなります。';

  @override
  String get ratingPromptYes => '評価する';

  @override
  String get ratingPromptNo => '今はしない';

  @override
  String get closetNoMatchesTitle => '該当なし';

  @override
  String get closetNoMatchesBody => 'フィルターを減らすか、別の検索を試してください。';

  @override
  String get closetClearFilters => 'フィルターを解除';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count点',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => '読み込み中';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count点選択中',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => '選択を削除';

  @override
  String get closetCancelSelection => '選択を解除';

  @override
  String get closetCloseSearch => '検索を閉じる';

  @override
  String get closetShowGrid => 'グリッド表示';

  @override
  String get closetShowList => 'リスト表示';

  @override
  String get closetShowRows => '行表示';

  @override
  String get closetStatsTitle => 'クローゼット統計';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count点を削除しますか？',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => '使用中のコーディネートからも削除されます';

  @override
  String get closetSortBy => '並び替え';

  @override
  String get closetFavourites => 'お気に入り';

  @override
  String get closetFavourite => 'お気に入りに追加';

  @override
  String get closetUnfavourite => 'お気に入りから削除';

  @override
  String get closetWoreToday => '今日着用';

  @override
  String closetWornTimes(int count) {
    return '着用回数 $count回';
  }

  @override
  String get closetCategoryLabel => 'カテゴリー';

  @override
  String get closetUseCaseLabel => '用途';

  @override
  String get closetAnyUseCase => 'すべて';

  @override
  String get closetOtherUseCase => 'その他の用途';

  @override
  String get closetOtherUseCaseHint => '例：ブランチ';

  @override
  String get closetUseUseCase => 'この用途を使用';

  @override
  String get closetClearAll => 'すべてクリア';

  @override
  String get sortNewest => '新しい順';

  @override
  String get sortOldest => '古い順';

  @override
  String get sortName => '名前順 (A–Z)';

  @override
  String get sortMostWorn => '着用回数が多い順';

  @override
  String get useCaseInformal => 'カジュアル';

  @override
  String get useCaseDate => 'デート';

  @override
  String get useCaseDinner => 'ディナー';

  @override
  String get useCaseLunch => 'ランチ';

  @override
  String get actionSelect => '選択';

  @override
  String get actionEdit => '編集';

  @override
  String get actionFilter => '絞り込み';

  @override
  String get actionSort => '並び替え';

  @override
  String get actionAll => 'すべて';

  @override
  String get dashboardStartClosetTitle => 'クローゼットを作成';

  @override
  String get dashboardStartClosetBody => '服を撮影するだけで、自動でタグ付けされます。';

  @override
  String get dashboardPieces => 'アイテム';

  @override
  String get dashboardOutfits => 'コーデ';

  @override
  String get dashboardDayStreak => '連続記録';

  @override
  String dashboardAddedThisMonth(int count) {
    return '今月 $count 点追加';
  }

  @override
  String dashboardBestStreak(int count) {
    return '最高 $count 日';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のお気に入り',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の保存済みコーデ',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'よく着る服: $name ($count 回)';
  }

  @override
  String get setupSkip => 'スキップ';

  @override
  String get setupWhoTitle => '誰のスタイルを作成しますか？';

  @override
  String get setupWhoBody => '試着や撮影のモデルになります。後でプロフィールから変更可能です。';

  @override
  String get setupStyleTitle => '普段どんな服を着ますか？';

  @override
  String get setupStyleBody => '選択してください。コーデ提案の参考にします。';

  @override
  String get setupClosetTitle => '最初のアイテムを追加';

  @override
  String get setupClosetBody => '服を撮影してください。自動で切り抜いて登録します。';

  @override
  String get setupAddClothes => '服を追加';

  @override
  String get setupStylesLabel => 'スタイル';

  @override
  String get setupOccasionsLabel => 'シーン';

  @override
  String get setupSkipStep => 'スキップ';

  @override
  String get setupLater => '後で';

  @override
  String get setupSaveError => '保存できませんでした';

  @override
  String get genderWomen => '女性';

  @override
  String get genderMen => '男性';

  @override
  String get genderNonBinary => 'ノンバイナリー';

  @override
  String get genderPreferNotToSay => '回答しない';

  @override
  String get outfitEmptyTitle => 'コーディネートがありません';

  @override
  String get outfitEmptyBody => 'クローゼットのアイテムを組み合わせて保存しましょう';

  @override
  String get outfitNoMatchesTitle => '該当するコーディネートなし';

  @override
  String get outfitSearchHint => 'コーディネートを検索';

  @override
  String get outfitLoading => '読み込み中';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のコーディネート',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'スタイルと季節';

  @override
  String get outfitCollections => 'コレクション';

  @override
  String get outfitDuplicate => '複製';

  @override
  String get outfitDeleteTitle => 'このコーディネートを削除しますか？';

  @override
  String get outfitDeleteBody => 'アイテムはクローゼットに残ります';

  @override
  String get outfitDrafts => '下書き';

  @override
  String get outfitDraft => '下書き';

  @override
  String get filterStyle => 'スタイル';

  @override
  String get filterSeason => '季節';

  @override
  String get itemDetailDeleteTitle => 'このアイテムを削除しますか？';

  @override
  String get itemDetailDeleteBody => '使用中のコーディネートからも削除されます';

  @override
  String get itemAddFavourite => 'お気に入りに追加';

  @override
  String itemSize(String size) {
    return 'サイズ $size';
  }

  @override
  String get itemColours => 'カラー';

  @override
  String get itemMaterial => '素材';

  @override
  String get itemPattern => '柄';

  @override
  String get itemUseCases => '用途';

  @override
  String get itemKeptIn => '保管場所';

  @override
  String get itemPrice => '価格';

  @override
  String get itemBought => '購入日';

  @override
  String get itemTags => 'タグ';

  @override
  String get itemAdded => '追加日';

  @override
  String get itemTimesWornLabel => '着用回数';

  @override
  String get itemLastWornLabel => '最終着用日';

  @override
  String get itemNeverWorn => '未着用';

  @override
  String get authEntryBody => 'FitCheck AIがあなたの服をコーディネート。計画して、試着して、撮影しよう。';

  @override
  String get authCreateCloset => 'クローゼットを作成';

  @override
  String get authWelcomeBack => 'おかえりなさい';

  @override
  String get authSignInBody => 'サインインしてクローゼットを開く';

  @override
  String get authCreateAccount => 'アカウントを作成';

  @override
  String get authCreateClosetBody => '1分で完了。最初のアイテム登録は無料です。';

  @override
  String get authName => '名前';

  @override
  String get authConfirmPassword => 'パスワードを再入力';

  @override
  String get authReferralCode => '紹介コード（任意）';

  @override
  String get authResetTitle => 'パスワードをリセット';

  @override
  String get authResetBody => '新しいパスワードを設定するためのリンクをメールで送信します。';

  @override
  String get authSendResetLink => 'リセットリンクを送信';

  @override
  String get authBackToSignIn => 'サインインに戻る';

  @override
  String get authEnterEmail => 'メールアドレスを入力';

  @override
  String get authEnterValidEmail => '有効なメールアドレスを入力してください';

  @override
  String get authEnterPassword => 'パスワードを入力';

  @override
  String get authPasswordTooShort => '6文字以上で入力してください';

  @override
  String get authShowPassword => '表示';

  @override
  String get authHidePassword => '非表示';

  @override
  String get authNewHere => '初めての方ですか？';

  @override
  String authConfirmEmail(String email) {
    return 'サインインの前に $email を確認してください。受信トレイを確認してください。';
  }

  @override
  String get authResendEmail => '再送信';

  @override
  String get authResendingEmail => '送信中…';

  @override
  String get authPasswordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get authEnterName => '名前を入力';

  @override
  String get authChoosePassword => 'パスワードを設定';

  @override
  String get authHaveAccount => 'アカウントをお持ちですか？';

  @override
  String get authCodeAccepted => 'コードが承認されました';

  @override
  String get authCodeNotFound => 'コードが見つかりません';

  @override
  String authReferralFrom(String name) {
    return '$nameさんからの招待です。両者とも1ヶ月無料になります。';
  }

  @override
  String get authReferralInvalid => 'このコードは見つかりませんでした。';

  @override
  String authResetSent(String email) {
    return '$emailに送信しました。この端末でリンクを開いてください。';
  }

  @override
  String get introSlide1Title => 'クローゼットを撮影';

  @override
  String get introSlide1Body => '服をまとめて撮影するだけ。すべてのアイテムが自動で切り抜かれ、登録されます。';

  @override
  String get introSlide2Title => '着替えをスムーズに';

  @override
  String get introSlide2Body => '手持ちの服から、予定や天気に合わせたコーディネートを提案します。';

  @override
  String get introSlide3Title => '着る前に試着';

  @override
  String get introSlide3Body => '自分の写真で試着したり、カタログのようなスタイルを撮影したりできます。';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeSystem => 'システム設定';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsTemperature => '気温';

  @override
  String get settingsEmailUpdates => 'メール通知';

  @override
  String get settingsEmailUpdatesBody => 'ニュースやヒントをメールで受け取る';

  @override
  String get settingsOutfitReminders => 'コーディネート通知';

  @override
  String get settingsOutfitRemindersBody => '着用記録の通知を受け取る';

  @override
  String get settingsWeeklySummary => '週間まとめ';

  @override
  String get settingsWeeklySummaryBody => '1週間のコーディネート振り返り';

  @override
  String get settingsStyleSection => 'スタイル';

  @override
  String get settingsPreferredStyles => '好みのスタイル';

  @override
  String get settingsPreferredColours => '好みのカラー';

  @override
  String get settingsNoneChosen => '未選択';

  @override
  String get settingsPlanAiSection => 'プランとAI';

  @override
  String get settingsPlanBillingBody => 'プラン、利用状況、アップグレード';

  @override
  String get settingsPlanUsageBody => 'プランと利用状況';

  @override
  String get settingsInviteFriends => '友達を招待';

  @override
  String get settingsInviteFriendsBody => '友達が参加するたびに1ヶ月分無料';

  @override
  String get settingsAiProvider => 'AIプロバイダー';

  @override
  String get settingsAiProviderBody => 'タグ付けや画像生成に独自のモデルを使用';

  @override
  String get settingsAppVersion => 'アプリバージョン';

  @override
  String get settingsPrivacyTerms => 'プライバシーポリシーと利用規約';

  @override
  String get settingsReportProblem => '問題を報告';

  @override
  String get settingsChangePassword => 'パスワードを変更';

  @override
  String get settingsExportData => 'データをエクスポート';

  @override
  String get settingsExportBody => '保存したすべてのデータを含むファイルを作成し、ダウンロードを開始します';

  @override
  String get settingsExportAction => 'エクスポート';

  @override
  String get settingsCurrentPassword => '現在のパスワード';

  @override
  String get settingsNewPassword => '新しいパスワード';

  @override
  String get settingsConfirmNewPassword => '新しいパスワードを確認';

  @override
  String get settingsEnterCurrentPassword => '現在のパスワードを入力';

  @override
  String get settingsEnterNewPassword => '新しいパスワードを入力';

  @override
  String get settingsPasswordMin8 => '8文字以上で入力してください';

  @override
  String get settingsPasswordNeedsUpper => '大文字を含めてください';

  @override
  String get settingsPasswordNeedsLower => '小文字を含めてください';

  @override
  String get settingsPasswordNeedsDigit => '数字を含めてください';

  @override
  String get settingsPasswordsNoMatch => 'パスワードが一致しません';

  @override
  String get settingsChangeAction => '変更';

  @override
  String get itemAddSnapTitle => 'アイテムを撮影';

  @override
  String get itemAddSnapBody => '写真からアイテムを検出し、スタジオ撮影風に切り抜きます';

  @override
  String get itemAddCamera => '写真を撮影';

  @override
  String get itemAddGallery => 'ギャラリーから選択';

  @override
  String get itemAddOtherWays => 'その他の追加方法';

  @override
  String get itemAddSeveral => '複数の写真を追加';

  @override
  String get itemAddSeveralBody => '一度に最大50枚まで';

  @override
  String get itemAddImportProfile => 'プロフィールからインポート';

  @override
  String get itemAddImportProfileBody => 'InstagramまたはFacebook';

  @override
  String get itemAddEnterDetails => '詳細を手動入力';

  @override
  String get itemAddEnterDetailsBody => '写真は不要です';

  @override
  String get itemManualIntro => '名前だけで登録可能です。詳細は後から追加できます。';

  @override
  String get itemManualNameHint => '例：青いコットンTシャツ';

  @override
  String get itemManualEnterName => '名前を入力';

  @override
  String get itemManualNotes => 'メモ';

  @override
  String get itemManualBrand => 'ブランド';

  @override
  String get itemManualSize => 'サイズ';

  @override
  String get itemManualEnterNumber => '数値を入力';

  @override
  String get itemManualSavePiece => '保存';

  @override
  String get itemManualSaving => '保存中';

  @override
  String get itemManualSavedTitle => '保存完了';

  @override
  String itemManualSavedBody(String name) {
    return '$nameをクローゼットに追加しました。';
  }

  @override
  String get itemManualNotSaved => '保存されていません';

  @override
  String get itemManualAddUseCase => '用途を追加';

  @override
  String get itemManualAddUseCaseAction => '用途を追加';

  @override
  String get itemPhotos => '写真';

  @override
  String get itemAddPhotos => '写真を追加';

  @override
  String get itemNoPhotoYet => '写真がありません。写真なしで保存できます。';

  @override
  String get itemRemovePhoto => '写真を削除';

  @override
  String get itemRemovePiece => 'アイテムを削除';

  @override
  String get filterConditionLabel => '状態';

  @override
  String get photoshootStepPhotos => '写真';

  @override
  String get photoshootStepSetup => '設定';

  @override
  String get photoshootStepCreating => '作成中';

  @override
  String get photoshootStepResults => '結果';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'ステップ $current/$total：$name';
  }

  @override
  String get photoshootOneFailed => '1枚のアップロードに失敗しました。以下から再試行してください。';

  @override
  String photoshootManyFailed(int count) {
    return '$count枚のアップロードに失敗しました。以下からそれぞれ再試行してください。';
  }

  @override
  String get photoshootFormat => 'フォーマット';

  @override
  String get photoshootHowMany => '枚数';

  @override
  String get photoshootYourPrompt => 'プロンプト';

  @override
  String get photoshootPromptHint => '屋上でゴールデンアワー、リネンシャツ';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚の写真を生成',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '枚',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => '本日の上限を確認できませんでした。';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$planプラン: 本日の残り$remaining/$limit回';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => '無料';

  @override
  String get photoshootGallery => 'ギャラリー';

  @override
  String get photoshootUseCamera => 'カメラを使う';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '写真$numberを削除';
  }

  @override
  String get photoshootNoPhotosTitle => '写真が生成されませんでした';

  @override
  String get photoshootNoPhotosBody => '生成に失敗しました。もう一度お試しください。';

  @override
  String get photoshootNewStyle => '新しいスタイル';

  @override
  String get photoshootNewPhotos => '新しい写真';

  @override
  String photoshootOpenPhoto(int number) {
    return '写真$numberを開く';
  }

  @override
  String get photoshootReportPhoto => '写真を報告';

  @override
  String get photoshootSaveToGallery => 'ギャラリーに保存';

  @override
  String get actionUpgrade => 'アップグレード';

  @override
  String get referralLimitTitle => '本日の上限に達しました';

  @override
  String get referralLimitBody => '無料枠は明日リセットされます。友達を紹介すると、お互いにProが1ヶ月無料になります。';

  @override
  String get referralLimitRefer => '友達を紹介する';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'マッチングアプリ';

  @override
  String get photoshootUsePortfolio => 'ポートフォリオ';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'エステティック';

  @override
  String get photoshootUseCustom => '独自のプロンプト';

  @override
  String get photoshootDescLinkedin => 'ビジネス用プロフィール写真';

  @override
  String get photoshootDescDating => 'リラックスした自然な雰囲気';

  @override
  String get photoshootDescPortfolio => 'エディトリアル、ハイファッション';

  @override
  String get photoshootDescInstagram => 'SNS映えするライフスタイル写真';

  @override
  String get photoshootDescAesthetic => 'ムードのある芸術的なフレーム';

  @override
  String get photoshootDescCustom => '希望のスタイルを入力';

  @override
  String get aspectSquare => 'スクエア';

  @override
  String get aspectPortrait => 'ポートレート';

  @override
  String get aspectLandscape => 'ランドスケープ';

  @override
  String get aspectTall => 'トール';

  @override
  String get aspectWide => 'ワイド';

  @override
  String get tryOnAppBar => 'バーチャル試着';

  @override
  String get tryOnYourPhoto => '自分の写真';

  @override
  String get tryOnGarment => '服の写真';

  @override
  String get tryOnUploadingPhoto => '写真をアップロード中';

  @override
  String get tryOnAddPhotoPrompt => '全身写真をアップロード';

  @override
  String get tryOnBodyPhotoHint => '全身写真が最適です';

  @override
  String get tryOnAddPhoto => '写真を追加';

  @override
  String get tryOnChangePhoto => '写真を変更';

  @override
  String get tryOnPhotoLoadFailed => '写真を読み込めませんでした';

  @override
  String get tryOnChooseGarment => '服の写真を選択';

  @override
  String get tryOnChooseOneGarment => '服の写真を1枚選択';

  @override
  String get tryOnGarmentHint => '平置きやハンガー掛けが最適です';

  @override
  String get tryOnChange => '変更';

  @override
  String get tryOnCamera => 'カメラ';

  @override
  String get tryOnRemove => '削除';

  @override
  String get tryOnLookTitle => 'ルック';

  @override
  String get tryOnStyle => 'スタイル';

  @override
  String get tryOnBackground => '背景';

  @override
  String get tryOnPose => 'ポーズ';

  @override
  String get tryOnDressingUp => '着せ替え中。30秒ほどかかります';

  @override
  String get tryOnEmptyResult => '試着結果がここに表示されます';

  @override
  String get tryOnReportImage => '画像を報告';

  @override
  String get tryOnCreating => '作成中';

  @override
  String get tryOnTryAgain => '再試行';

  @override
  String get tryOnCreate => '試着を作成';

  @override
  String get tryOnBackgroundStudioWhite => 'スタジオホワイト';

  @override
  String get tryOnBackgroundStudioGrey => 'スタジオグレー';

  @override
  String get tryOnBackgroundUrban => 'アーバンストリート';

  @override
  String get tryOnBackgroundNature => 'ネイチャー';

  @override
  String get tryOnBackgroundMinimal => 'ミニマル';

  @override
  String get tryOnPoseFront => '正面立ち';

  @override
  String get tryOnPoseSide => '横向き';

  @override
  String get tryOnPoseWalking => '歩行';

  @override
  String get dashboardGreetingMorning => 'おはようございます';

  @override
  String get dashboardGreetingAfternoon => 'こんにちは';

  @override
  String get dashboardGreetingEvening => 'こんばんは';

  @override
  String get dashboardWelcome => 'ようこそ';

  @override
  String get dashboardOpenProfile => 'プロフィールを開く';

  @override
  String get dashboardRailToday => '今日';

  @override
  String get dashboardRailRecently => '最近';

  @override
  String get dashboardActivityEmpty => '新しいアイテムやコーデがここに表示されます';

  @override
  String get quickAddPiece => 'アイテムを追加';

  @override
  String get quickAddPieceBody => '撮影してタグ付け';

  @override
  String get quickBuildOutfit => 'コーデを作成';

  @override
  String get quickBuildOutfitBody => '手持ちを組み合わせる';

  @override
  String get quickForYou => 'おすすめ';

  @override
  String get quickForYouBody => '今日のピックアップ';

  @override
  String get quickPlanWeek => '週間プラン';

  @override
  String get quickPlanWeekBody => '日付別にコーデ';

  @override
  String get referralBannerUrgent => '枠が残りわずかです。友達を招待しましょう';

  @override
  String get referralBannerTitle => '1ヶ月分をプレゼント';

  @override
  String get referralBannerBody => 'あなたと友人にProを1ヶ月分プレゼント';

  @override
  String get referralBannerDismiss => '1週間非表示';

  @override
  String get referralBannerShare => '招待をシェア';

  @override
  String get referralBannerCopy => 'リンクをコピー';

  @override
  String get itemEditPieceTitle => 'アイテムを編集';

  @override
  String get itemEditDescriptionLabel => '説明';

  @override
  String get itemEditNotSaved => '未保存';

  @override
  String get itemEditSavedTitle => '保存済み';

  @override
  String get itemEditSavedBody => '変更を保存しました';

  @override
  String get itemEditSavedStalePhotos => '保存済み — 写真が古い可能性があります';

  @override
  String get itemEditRemovePieceHint => 'アイテムページからこのピースを削除';

  @override
  String get itemEditNoPhotos => '写真がありません。ギャラリーまたはカメラから追加してください';

  @override
  String get itemEditKeepPhoto => '写真を保持';

  @override
  String get itemEditRemoved => '削除済み';

  @override
  String get itemEditAddUseCaseAction => '追加';

  @override
  String get statsNoStatsTitle => '統計データなし';

  @override
  String get statsNoStatsBody => 'アイテムを追加すると、クローゼットの構成が表示されます';

  @override
  String get statsByCategory => 'カテゴリー別';

  @override
  String get statsTotalValue => '合計金額';

  @override
  String get statsMostWorn => '着用頻度が高い';

  @override
  String get statsLeastWorn => '出番待ち';

  @override
  String get statsUnnamedPiece => '名称未設定';

  @override
  String get jobsTitle => 'スキャン';

  @override
  String get jobsEmptyTitle => 'スキャンなし';

  @override
  String get jobsEmptyBody => 'アイテムを撮影してバックグラウンドへ。ここで処理が継続されます';

  @override
  String get jobsNotCancelled => 'キャンセル不可';

  @override
  String get jobsResume => '再開';

  @override
  String get jobsReview => '確認';

  @override
  String get jobsStop => '停止';

  @override
  String get jobsDismiss => '閉じる';

  @override
  String get reportTitle => 'コンテンツを報告';

  @override
  String reportIntro(String contentType) {
    return 'この$contentTypeの問題点を教えてください。チームがすべての報告を確認します。';
  }

  @override
  String get reportReasonInappropriate => '不適切または不快なコンテンツ';

  @override
  String get reportReasonNudity => 'ヌードや性的なコンテンツ';

  @override
  String get reportReasonHarassment => '嫌がらせや誹謗中傷';

  @override
  String get reportReasonImpersonation => 'なりすまし';

  @override
  String get reportReasonOther => 'その他';

  @override
  String get reportDetailsLabel => '詳細（任意）';

  @override
  String get reportSubmit => '報告を送信';

  @override
  String get reportSubmittedTitle => '報告を送信しました';

  @override
  String get reportSubmittedBody => 'ご協力ありがとうございます。チームが内容を確認します。';

  @override
  String get reportFailedTitle => '送信できませんでした';

  @override
  String get reportFailedBody => 'もう一度お試しください。';

  @override
  String get reportContentTryOnImage => 'AI試着画像';

  @override
  String get reportContentSharedOutfit => '共有されたコーディネート';

  @override
  String get reportContentPhotoshootImage => 'AIフォトシュート画像';

  @override
  String get sharedOutfitTitle => '共有されたコーディネート';

  @override
  String get sharedOutfitHideTooltip => 'このコーディネートを非表示';

  @override
  String get sharedOutfitReportTooltip => 'このコーディネートを報告';

  @override
  String get sharedOutfitHideTitle => '非表示にしますか？';

  @override
  String get sharedOutfitHideBody =>
      'このデバイスで非表示になります。不適切な場合は報告してください。運営チームが確認し削除します。';

  @override
  String get sharedOutfitHideAction => '非表示';

  @override
  String get sharedOutfitHiddenInfo => 'このコーディネートは今後このデバイスに表示されません。';

  @override
  String get sharedOutfitHiddenToast => '非表示にしました';

  @override
  String get sharedOutfitMissingTitle => 'コーディネートが見つかりません';

  @override
  String get sharedOutfitMissingBody => '削除されたか、リンクが間違っている可能性があります。';

  @override
  String get sharedOutfitHiddenStateTitle => '非表示済みのコーディネート';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return '不適切な場合は「プライバシーと利用規約」から報告するか、$emailまでご連絡ください。';
  }

  @override
  String get sharedOutfitCtaTitle => 'このスタイルが好きですか？';

  @override
  String get sharedOutfitCtaBody => '手持ちの服で同じようなコーディネートを作りましょう。';

  @override
  String get sharedOutfitCtaButton => 'FitCheck AIを入手';

  @override
  String get errorTitle => 'エラー';

  @override
  String get errorUnknown => '予期しないエラーが発生しました';

  @override
  String get errorNoConnection => 'インターネット接続がありません。ネットワークを確認してください';

  @override
  String get errorTimeout => 'リクエストがタイムアウトしました。もう一度お試しください';

  @override
  String get errorServerError => 'サーバー側に問題が発生しました。もう一度お試しください';

  @override
  String get errorBadGateway => 'サーバーが一時的に利用できません。もう一度お試しください';

  @override
  String get errorServiceUnavailable => 'サービスが一時的に利用できません。しばらくしてから再試行してください';

  @override
  String get errorInternalError => '問題が発生しました。もう一度お試しください';

  @override
  String get errorUnauthorized => '続行するにはサインインしてください';

  @override
  String get errorForbidden => 'アクセス権がありません';

  @override
  String get errorSessionExpired => 'セッションの有効期限が切れました。再度サインインしてください';

  @override
  String get errorInvalidCredentials => 'メールアドレスまたはパスワードが正しくありません';

  @override
  String get errorTokenRefreshFailed => 'セッションを更新できませんでした。再度サインインしてください';

  @override
  String get errorRequestCancelled => 'リクエストをキャンセルしました';

  @override
  String get errorInvalidFormat => 'そのファイル形式はサポートされていません';

  @override
  String get errorFileTooLarge => 'ファイルが大きすぎます';

  @override
  String get errorUploadFailed => 'アップロードに失敗しました。もう一度お試しください';

  @override
  String get errorCacheCorrupted => '保存されたデータが破損したため、リセットしました';

  @override
  String get errorCacheNotFound => 'まだ何も保存されていません';

  @override
  String get errorUserNotFound => 'そのアカウントが見つかりません';

  @override
  String get errorItemNotFound => 'そのアイテムは存在しなくなりました';

  @override
  String get errorOutfitNotFound => 'そのコーディネートは存在しなくなりました';

  @override
  String get rewardsTitle => 'リワード';

  @override
  String get rewardsNoAchievementsTitle => '実績はまだありません';

  @override
  String get rewardsNoAchievementsBody => 'アイテムを追加し、コーディネートを組み合わせて初の実績を達成しましょう';

  @override
  String get rewardsEmptyLeaderboardTitle => 'まだランキングにいません';

  @override
  String get rewardsEmptyLeaderboardBody => 'コーディネートを組んでポイントを獲得し、ランクインしましょう';

  @override
  String get legalViewPrivacyPolicy => 'プライバシーポリシーを表示';

  @override
  String get aiConsentAgree => '同意して続行';

  @override
  String get aiConsentNotNow => '後で';

  @override
  String get imageViewerCloseTooltip => '画像ビューアーを閉じる';

  @override
  String get updateReadyTitle => '更新の準備完了';

  @override
  String get updateReadyBody => '最新の内容を適用するにはFitCheck AIを再起動してください。';

  @override
  String get permissionCameraUsage => 'アウトライトと衣類を撮影するためにカメラへのアクセスが必要です。';

  @override
  String get permissionPhotoLibraryUsage =>
      'アウトライトと衣類を選択するために写真ライブラリへのアクセスが必要です。';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'AIで生成したコーディネート写真を保存するために写真ライブラリへのアクセスが必要です。';

  @override
  String get wardrobeSomePhotosSkipped => '一部の写真をスキップしました';

  @override
  String get wardrobePhotosNotAdded => '写真を追加できません';

  @override
  String get wardrobePhotoNotAdded => '写真を追加できません';

  @override
  String get wardrobeNotStartedTitle => '未開始';

  @override
  String get wardrobeNoRoomTitle => '空きなし';

  @override
  String get wardrobeAddPhotosSemantic => '写真を追加';

  @override
  String get batchAddTileLabel => '追加';

  @override
  String get batchProfileLinkLabel => 'プロフィールリンク';

  @override
  String get wardrobeImportFromProfileTitle => 'プロフィールから読み込み';

  @override
  String get wardrobeAddSeveralPhotosTitle => '複数枚の写真を追加';

  @override
  String get wardrobeClearAction => 'クリア';

  @override
  String get wardrobeRefreshTooltip => '更新';

  @override
  String get batchNoPhotosYetTitle => '写真はまだありません';

  @override
  String get batchChoosePhotosAction => '写真を選択';

  @override
  String get batchWeFindEachPieceBody => '各アイテムを特定し、スタジオ写真風に作成します。';

  @override
  String get batchPreparingPhotosSemantic => '写真を準備中';

  @override
  String get batchPhotosProcessedSemantic => '写真の処理が完了';

  @override
  String get batchPasteProfileLinkTitle => 'プロフィールリンクを貼り付け';

  @override
  String get batchPasteProfileLinkBody =>
      '公開されたInstagramまたはFacebookプロフィールを指定します。写真をスキャンして、クローゼットに追加するアイテムを選択できます。';

  @override
  String get batchClearLinkTooltip => 'リンクをクリア';

  @override
  String get batchStartingButton => '開始中';

  @override
  String get batchStartImportAction => '読み込み開始';

  @override
  String get batchReviewEveryPhotoTitle => '全写真を確認します';

  @override
  String get batchReviewEveryPhotoBody => '承認するまで追加されません。';

  @override
  String get batchPrivateProfilesTitle => '非公開プロフィール';

  @override
  String get batchPrivateProfilesBody =>
      'アカウントを接続してください。Instagramにはユーザー名とパスワードも必要です。';

  @override
  String get batchUseAnotherLinkAction => '別のリンクを使用';

  @override
  String get batchSignInNeededTitle => 'サインインが必要です';

  @override
  String get batchEnterYourCodeTitle => 'コードを入力';

  @override
  String get batchUseUsernamePasswordAction => 'ユーザー名とパスワードで登録';

  @override
  String get batchAlreadyConnectedAction => 'ブラウザで接続済み';

  @override
  String get batchEnterCodeAction => 'コードを入力';

  @override
  String get batchTryAnotherWayAction => '別の方法で試す';

  @override
  String get batchLiveStatus => '接続中';

  @override
  String get batchReconnectingStatus => '再接続中';

  @override
  String get batchSignInToInstagramTitle => 'Instagramにサインイン';

  @override
  String get batchUsernameLabel => 'ユーザー名';

  @override
  String get batchCodeIfTwoStepLabel => '2段階認証を使用する場合のコード';

  @override
  String get batchAuthenticatorCodeBody =>
      '認証アプリの6桁のコードを使用してください。コードは頻繁に変わります。';

  @override
  String get batchVerifyAction => '確認';

  @override
  String get batchFindingPhotosTitle => '写真を検索中';

  @override
  String get batchImportPausedTitle => 'インポートを一時停止';

  @override
  String get batchProcessingPhotosTitle => '写真の処理中';

  @override
  String get batchWaitingNextPhoto => '次の写真を待機中';

  @override
  String get batchCancelImportAction => 'インポートをキャンセル';

  @override
  String get batchNoPiecesInPhotoBody => 'この写真からアイテムが見つかりませんでした。';

  @override
  String get batchEditPieceColoursLabel => '色（カンマで区切ってください）';

  @override
  String get batchAddToClosetAction => 'クローゼットに追加';

  @override
  String get batchSkipPhotoAction => 'この写真をスキップ';

  @override
  String get batchImportCompleteTitle => 'インポート完了';

  @override
  String get batchImportFailedTitle => 'インポート失敗';

  @override
  String get batchImportCancelledTitle => 'インポートをキャンセルしました';

  @override
  String get batchImportErrorBody => 'インポート中にエラーが発生しました。';

  @override
  String get batchNothingMoreImportedBody => 'このプロフィールからの追加インポートはありません。';

  @override
  String get batchViewClosetAction => 'クローゼットを見る';

  @override
  String get batchStartOverAction => '最初からやり直す';

  @override
  String get wardrobeAddPieceTitle => 'アイテムを追加';

  @override
  String get wardrobeAddDetailsTitle => '詳細を追加';

  @override
  String get wardrobeScanningTitle => 'スキャン中';

  @override
  String get batchReviewPiecesTitle => 'アイテムを確認';

  @override
  String get wardrobeGalleryAction => 'ギャラリー';

  @override
  String get wardrobeCameraAction => 'カメラ';

  @override
  String get wardrobeNewBadge => '新着';

  @override
  String get wardrobeRemovePhotoTooltip => '写真削除';

  @override
  String get batchRunInBackgroundTooltip => 'バックグラウンドで実行';

  @override
  String get batchStepOneOfTwo => '1/2 ステップ';

  @override
  String get batchStepTwoOfTwo => '2/2 ステップ';

  @override
  String get batchUploadingPhotosTitle => '写真をアップロード中';

  @override
  String get batchFindingPiecesTitle => 'アイテムを検索中';

  @override
  String get batchMakingStudioPhotosTitle => 'スタジオ写真を作成中';

  @override
  String get batchStoppedLabel => '停止';

  @override
  String get batchFindingPiecesStoppedTitle => 'アイテム検索を停止';

  @override
  String get batchCancelledLabel => 'キャンセル';

  @override
  String get batchAllDoneTitle => '完了';

  @override
  String get batchOpeningPiecesBody => 'アイテムを開いています';

  @override
  String get batchNothingSavedBody => '保存されていません';

  @override
  String get batchFindingPiecesFailedBody => 'アイテム検索に失敗しました';

  @override
  String get batchFindingPiecesStoppedEarlyBody => 'アイテム検索を途中で停止しました';

  @override
  String get batchStopFindingPiecesTitle => 'アイテム検索を停止しますか？';

  @override
  String get batchStopFindingPiecesBody =>
      'スキャンが停止し、保存されません。既に検出されたアイテムは、削除するまでアクティビティに表示されます。';

  @override
  String get batchKeepGoingAction => '続ける';

  @override
  String get batchTryAgainAction => '再試行';

  @override
  String get batchBackToPhotosAction => '写真に戻る';

  @override
  String get batchSkipAllAction => 'すべてスキップ';

  @override
  String get batchIncludeAllAction => 'すべてを含める';

  @override
  String get batchNoPiecesFoundTitle => '衣類が見つかりません';

  @override
  String get batchNoPiecesFoundBody => 'これらの写真に衣類は見つかりませんでした。';

  @override
  String get batchChooseOtherPhotosAction => '別の写真を選択';

  @override
  String get batchUseCaseHelper => '保存するすべての衣類に追加されます。';

  @override
  String get batchDiscardPiecesTitle => 'これらの衣類を破棄しますか？';

  @override
  String get batchDiscardPiecesBody => 'このバッチの内容は保存されていません。';

  @override
  String get batchKeepAction => '保持';

  @override
  String get batchDiscardAction => '破棄';

  @override
  String get batchRemovePieceTitle => 'この衣類を削除しますか？';

  @override
  String get batchRemovePieceBody => 'クローゼットには保存されません。';

  @override
  String get batchRemoveAction => '削除';

  @override
  String get batchChoosePiecesToSave => '保存する衣類を選択';

  @override
  String get batchDiscardAllAction => 'すべて破棄';

  @override
  String get batchNothingSavedRetryBody => '保存されませんでした。もう一度お試しください。';

  @override
  String get batchNotSavedTitle => '未保存';

  @override
  String get batchSavingLabel => '保存中';

  @override
  String get batchSendToBackgroundAction => 'バックグラウンドに移動';

  @override
  String get batchStillWorkingMessage => '処理中です。衣類が準備できたらお知らせします。';

  @override
  String get batchRunningInBackgroundTitle => 'バックグラウンドで実行中';

  @override
  String get batchStudioPhotosStoppedBody => 'スタジオ写真は中断されました。これらの衣類は保存できます。';

  @override
  String get batchTapPieceToSkip => '衣類をタップしてスキップ。';

  @override
  String get batchStudioPhotosOnWayBody =>
      'スタジオ写真は作成中です。离れても大丈夫です。完了次第お知らせします。';

  @override
  String get batchLeaveAction => '離れる';

  @override
  String get batchPeopleInPhotosTitle => '写真にいる人物';

  @override
  String get batchIncludeAction => '含める';

  @override
  String get batchSkipAction => 'スキップ';

  @override
  String get batchYourPhotoIsUsedLabel => 'お使いの写真を使用';

  @override
  String get batchMakingStudioPhotoLabel => 'スタジオ写真を作成中';

  @override
  String get batchNoStudioPhotoBody => 'スタジオ写真なし。お使いの写真を使用します。';

  @override
  String get batchEnterDetailsYourselfAction => '手動で情報を入力';

  @override
  String get batchChooseAnotherPhotoAction => '別の写真を選ぶ';

  @override
  String get batchConnectionLostTitle => '接続が切断されました';

  @override
  String get batchConnectionLostBody => '接続を確認して、もう一度お試しください。';

  @override
  String get batchDailyLimitTitle => '1日の上限に達しました';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Proへのアップグレードでスキャン可能数を増やせます。または手動で情報を入力してください。';

  @override
  String get batchDailyLimitBodyFree => 'スキャン回数は明日リセットされます。現在、手動で情報を入力できます。';

  @override
  String get batchSeePlansAction => 'プランを見る';

  @override
  String get batchAiBusyTitle => 'AIが混み合っています';

  @override
  String get batchAiBusyBody => 'こちら側の問題です。しばらくしてから再度お試しください。';

  @override
  String get batchNoPiecesBody => 'より鮮明な写真で試すか、手動で情報を入力してください。';

  @override
  String get batchScanningUnavailableTitle => 'スキャンが利用できません';

  @override
  String get batchScanningUnavailableBody => '手動で情報を入力してください。';

  @override
  String get batchScanDidNotFinishTitle => 'スキャンが完了しませんでした';

  @override
  String get batchTryAgainBody => 'もう一度お試しください。';

  @override
  String get billingTitle => 'サブスクリプション';

  @override
  String get billingUpgradeHeading => 'プランをアップグレード';

  @override
  String get billingUpgradeOnPlusBody => '機能は同じで、上限が高いプランです。';

  @override
  String get billingUpgradeBody => 'PlusとProの機能は同じです。必要な上限を選んでください。';

  @override
  String get billingWebUnavailableBody =>
      'オンラインでのアップグレードはまだ利用できません。プロモーションコードや招待コードでPlusまたはProを利用できます。下記の友達招待で無料期間を獲得できます。';

  @override
  String get billingPlansStale => '最新プランを読み込めませんでした。料金が最新でない可能性があります。';

  @override
  String get billingMonthly => '月額';

  @override
  String get billingYearly => '年額';

  @override
  String get billingCurrentPlan => '現在のプラン';

  @override
  String get billingActive => '有効';

  @override
  String get billingThisMonth => '今月';

  @override
  String get billingItemExtractions => 'アイテム抽出';

  @override
  String get billingOutfitVisualizations => 'コーディネート生成';

  @override
  String get billingNearLimitUpgrade => '今月の上限に近づいています。アップグレードで増量できます。';

  @override
  String get billingNearLimitResets => '今月の上限に近づいています。翌月1日にリセットされます。';

  @override
  String get billingStoreUnavailable => 'アップグレードはまだストアで利用できません。しばらくお待ちください。';

  @override
  String get billingManageHeading => 'プラン管理';

  @override
  String get billingCancelPlan => 'サブスクリプションを解約';

  @override
  String get billingCancelKeepsAccess => 'この請求期間の終わりまでアクセス可能です。';

  @override
  String get billingCancelConfirmTitle => 'サブスクリプションを解約しますか?';

  @override
  String get billingKeepPlan => 'プランを維持';

  @override
  String get billingCancelPlanAction => '解約する';

  @override
  String get billingBilledMonthly => '月次課金';

  @override
  String get billingBilledYearly => '年次課金';

  @override
  String get billingVirtualTryOn => 'バーチャル試着';

  @override
  String get billingPrioritySupport => '優先サポート';

  @override
  String get billingDisclosureProRenewing => 'Pro は自動更新のサブスクリプションです';

  @override
  String get billingDisclosureBothRenewing => 'Plus および Pro は自動更新のサブスクリプションです';

  @override
  String get billingDisclosureAppleBilling => '購入確認時に Apple ID へ請求されます。';

  @override
  String get billingDisclosureGoogleBilling =>
      '購入確認時に Google Play アカウントへ請求されます。';

  @override
  String get billingDisclosureRenewalTerms =>
      '現在の期間の終了の少なくとも24時間前に自動更新をオフにしない限り、同条件で自動的に更新されます。';

  @override
  String get billingDisclosureAppleManage =>
      '「設定」 › Apple ID › サブスクリプションでいつでも管理または解約できます。';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play › 支払いとサブスクリプションでいつでも管理または解約できます。';

  @override
  String get billingReferFriend => '友人を招待';

  @override
  String get billingHowItWorks => '仕組み';

  @override
  String get billingHowShareTitle => 'リンクを共有';

  @override
  String get billingHowShareBody => '友人に送信します。';

  @override
  String get billingHowSignUpTitle => '登録';

  @override
  String get billingHowSignUpBody => '友人がリンクから参加します。';

  @override
  String get billingHowBothTitle => '双方に Pro';

  @override
  String get billingHowBothBody => 'それぞれが1か月 Pro を無料で利用できます。';

  @override
  String get billingYourReferrals => 'あなたの招待';

  @override
  String get billingInvited => '招待済み';

  @override
  String get billingJoined => '参加済み';

  @override
  String get billingMonthsEarned => '獲得月数';

  @override
  String get billingInviteFriend => '友達を招待';

  @override
  String get billingInviteBody => 'あなたと友達がそれぞれProを1ヶ月利用できます。';

  @override
  String get billingYourCode => 'あなたのコード';

  @override
  String get billingCopyLink => 'リンクをコピー';

  @override
  String get billingShareInvite => '招待を共有';

  @override
  String get giftUnavailable => 'ギフト招待は、このビルドでは利用できません。';

  @override
  String get giftPageTitle => 'FitCheck Proをギフトで贈る';

  @override
  String get giftNoAllowances => '現在、無料ギフト招待は利用できません。';

  @override
  String get giftFormTitle => '無料招待を送信';

  @override
  String get giftFormBody => '受取人はこの認証済みメールでギフトを引き受けます。メールは送信しません。';

  @override
  String get giftFieldFrom => '送信者';

  @override
  String get giftFieldRecipientName => '受取人名前';

  @override
  String get giftFieldRecipientEmail => '受取人メール';

  @override
  String get giftFieldOccasion => '機会（省略可）';

  @override
  String get giftNoOccasion => '機会なし';

  @override
  String get giftOccasionBirthday => '誕生日';

  @override
  String get giftOccasionAnniversary => '記念日';

  @override
  String get giftOccasionOther => 'その他';

  @override
  String get giftFieldCardGreeting => 'カードのメッセージ';

  @override
  String get giftFieldCardGreetingHelper => '入力内容がそのままカードに表示されます。';

  @override
  String get giftFieldPrivateNote => '秘密のメモ（省略可）';

  @override
  String get giftCreateAction => '無料ギフトを作成';

  @override
  String get giftClaimedTitle => 'ギフトを引き受けました';

  @override
  String get giftClaimedActive => 'FitCheck Proのギフトが有効です。';

  @override
  String get giftClaimedQueued => 'FitCheck Proのギフトは現在のアクセス終了後に有効になります。';

  @override
  String get giftLinkCopied => 'ギフトリンクがクリップボードにコピーされました。';

  @override
  String get giftErrorName => '名前を入力してください。';

  @override
  String get giftErrorEmail => '有効なメールアドレスを入力してください。';

  @override
  String get giftErrorGreeting => 'カードのメッセージを入力してください。';

  @override
  String get giftErrorGreetingLength => '80文字以内で入力してください。';

  @override
  String get giftClaimAction => 'ギフトを受け取る';

  @override
  String get giftCardPreview => 'カードのプレビュー';

  @override
  String get giftGiftForYou => 'あなたへのギフト';

  @override
  String get giftGiftWaiting => 'ギフトが待っています';

  @override
  String get giftOpenBody => 'ギフトを開き、確認済みメールアドレスで受け取れます。';

  @override
  String get giftOpenGifts => 'ギフトを開く';

  @override
  String get giftSendInvitation => '招待を送る';

  @override
  String get settingsAiProviderSection => 'プロバイダー';

  @override
  String get settingsAiCustom => 'カスタム';

  @override
  String get settingsAiUrlHelper => 'サーバーから到達できる公開URLを使用してください。ローカルホストは機能しません。';

  @override
  String get settingsAiConnectionSection => '接続';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'APIキー';

  @override
  String get settingsAiApiKeySaved => '保存されました。保持するには空白のままにしてください。';

  @override
  String get settingsAiChatModel => 'チャットモデル';

  @override
  String get settingsAiVisionModel => 'ビジョンモデル（任意）';

  @override
  String get settingsAiImageModel => '画像モデル（任意）';

  @override
  String get settingsAiImageModelNote =>
      '画像生成には、response_modalities付きのOpenAI互換チャット補完が必要です。';

  @override
  String get settingsAiTestConnection => '接続テスト';

  @override
  String get calendarTitle => 'カレンダー';

  @override
  String get calendarGoToToday => '今日へ';

  @override
  String get calendarConnectTooltip => 'カレンダーを接続';

  @override
  String get calendarAddEvent => 'イベントを追加';

  @override
  String get calendarEmptyTitle => '予定なし';

  @override
  String get calendarEmptyBody => 'イベントを追加して、着るものを計画しましょう。';

  @override
  String get calendarPreviousMonth => '前の月';

  @override
  String get calendarNextMonth => '次の月';

  @override
  String get calendarAllDay => '終日';

  @override
  String get calendarOutfitLinked => 'コーディネート連携済み';

  @override
  String get calendarEventOptions => 'イベントのオプション';

  @override
  String get calendarDeleteTitle => 'このイベントを削除しますか？';

  @override
  String get calendarChangeOutfit => 'コーデを変更';

  @override
  String get calendarLinkOutfit => 'コーデを関連付け';

  @override
  String get calendarRemoveOutfit => 'コーデを削除';

  @override
  String get calendarNewEvent => '新しいイベント';

  @override
  String get calendarEditEvent => 'イベントを編集';

  @override
  String get calendarTitleLabel => 'タイトル';

  @override
  String get calendarTitleRequired => 'タイトルを入力';

  @override
  String get calendarEndBeforeStart => '開始時刻より後に終了';

  @override
  String get calendarStarts => '開始';

  @override
  String get calendarEnds => '終了';

  @override
  String get calendarPlaceOptional => '場所（任意）';

  @override
  String get calendarNotesOptional => 'メモ（任意）';

  @override
  String get calendarLinkOutfitEmptyBody => 'コーデを作成してから、このイベントにリンクしてください。';

  @override
  String get calendarBuildOutfit => 'コーデを作成';

  @override
  String get calendarConnectionsTitle => 'カレンダー';

  @override
  String get calendarConnectionsBody => 'ここに追加したイベントはFitCheckに保存されます。';

  @override
  String get calendarDisconnect => '解除';

  @override
  String get calendarNotAvailable => 'まだ利用できません';

  @override
  String get profileSectionExplore => '探索';

  @override
  String get profileNavTryOn => '試着';

  @override
  String get profileNavRewards => 'リワード';

  @override
  String get profileSupport => 'サポート';

  @override
  String get profileHelp => 'ヘルプ';

  @override
  String get profileAbout => 'について';

  @override
  String get profileAboutBody => 'クローゼット、コーデ、プランを1つの場所に。';

  @override
  String get profileSignOutTitle => 'ログアウトしますか？';

  @override
  String get profileSignOutBody => 'いつでも再ログインできます。';

  @override
  String get profileEditTitle => 'プロフィールを編集';

  @override
  String get profileYourProfile => 'あなたのプロフィール';

  @override
  String get profileBodyProfiles => '体型プロファイル';

  @override
  String get profileBodyEmptyTitle => '体型プロファイルがありません';

  @override
  String get profileBodyEmptyBody => '身長と体格を追加して、よりフィット感の高いサイズをご提案します。';

  @override
  String get profileBodyAdd => 'プロファイル追加';

  @override
  String get profileBodyDefaultNote => 'デフォルトのプロファイルは、フィット感や試着シミュレーションで使用されます。';

  @override
  String get profileBodyDefaultBadge => 'デフォルト';

  @override
  String get profileBodyMakeDefault => 'デフォルトにする';

  @override
  String get profileBodyDeleteBody => 'この操作は取り消せません。';

  @override
  String get profileBodyRequired => '必須';

  @override
  String get profileBodyCheckNumber => '数値を確認してください';

  @override
  String get profileBodyNew => '新しい体型プロファイル';

  @override
  String get profileBodyNameHint => '例：自分';

  @override
  String get profileBodyHeight => '身長';

  @override
  String get profileBodyWeight => '体重';

  @override
  String get profileBodyBuild => '体格';

  @override
  String get profileBodySkinTone => '肌色';

  @override
  String get profileBirthDateNeededBody => '生まれた時刻を選択するには、生年月日が必要です。';

  @override
  String get profileBirthDateNeededTitle => '生年月日が必要です';

  @override
  String get profilePartlySavedBody =>
      '氏名と写真は保存されました。生年月日などの詳細は保存されませんでした。後で再試行してください。';

  @override
  String get profilePartlySavedTitle => '一部のみ保存されました';

  @override
  String get profileSavedBody => 'プロファイルが保存されました。';

  @override
  String get profileChangePhoto => 'プロフィール写真を変更';

  @override
  String get profilePhotoLabel => 'プロフィール写真';

  @override
  String get profilePhotoHint => 'タップして新しい写真を選択';

  @override
  String get profileBirthDateLabel => '生年月日（任意）';

  @override
  String get profileBirthTimeLabel => '出生時刻（任意）';

  @override
  String get profileBirthTimeHelper => 'ヴェーダ占星術の予測をより正確にします';

  @override
  String get profileBirthPlaceLabel => '出生地（任意）';

  @override
  String get profileBirthPlaceHint => '例：インド、ニューデリー';

  @override
  String get profileHelpContactTitle => '何でもお聞きください';

  @override
  String get profileHelpContactBody => 'メッセージを送信すると、通常1日以内にお返事をします。';

  @override
  String get profileHelpContactAction => 'サポートに問い合わせる';

  @override
  String get profileHelpFaqTitle => 'よくある質問';

  @override
  String get profileFaqAddPiecesTitle => 'クローゼットにアイテムを追加するには';

  @override
  String get profileFaqAddPiecesBody =>
      'クローゼットタブの「アイテム追加」をタップ。写真撮影またはギャラリーから選択し、各アイテムを検出・タグ付けします。';

  @override
  String get profileFaqMatchingTitle => 'コーディネートの仕組み';

  @override
  String get profileFaqMatchingBody =>
      '「おすすめ」を開き、所有しているアイテムを選択。組み合わせ提案と、クローゼットから作るフルコーデを行います。';

  @override
  String get profileFaqTryOnTitle => '自分の写真で試着できますか';

  @override
  String get profileFaqTryOnBody => 'はい。全身写真を追加し、アイテムを選択するとあなたの試着姿を見られます。';

  @override
  String get profileFaqRewardsTitle => '報酬の獲得方法';

  @override
  String get profileFaqRewardsBody => 'コーデの計画と記録をこまめに行う。連続達成や実績で成長します。';

  @override
  String get profileFaqPrivacyTitle => 'クローゼットは非公開ですか';

  @override
  String get profileFaqPrivacyBody => 'はい。1つのコーデのリンクを共有しない限り、クローゼットとコーデは非公開です。';

  @override
  String get profileHelpMoreTitle => 'その他のヘルプ';

  @override
  String get profileHelpGuides => 'ガイド';

  @override
  String get profileHelpGuidesBody => '各機能の使い方';

  @override
  String get feedbackCategoryBug => '不具合';

  @override
  String get feedbackCategoryIdea => 'アイデア';

  @override
  String get feedbackCategoryGeneral => 'その他';

  @override
  String get feedbackCategoryHelp => 'ヘルプ';

  @override
  String get feedbackHintBug => '何が起き、何が望ましいですか？手順があるとうれしいです。';

  @override
  String get feedbackHintIdea => 'どんな機能が欲しいですか？理由は？';

  @override
  String get feedbackHintGeneral => 'ご意見や質問をお聞かせください。';

  @override
  String get feedbackAttachmentLimitBody => '画像は最大5枚まで追加できます。';

  @override
  String get feedbackAttachmentLimitTitle => '上限に達しました';

  @override
  String get feedbackImageTooLargeBody => '5MB以下の画像を選択してください。';

  @override
  String get feedbackImageTooLargeTitle => '画像が大きすぎます';

  @override
  String get feedbackTitle => 'フィードバックを送信';

  @override
  String get feedbackAboutLabel => '内容';

  @override
  String get feedbackSubjectLabel => '件名';

  @override
  String get feedbackSubjectRequired => '件名を入力';

  @override
  String get feedbackSubjectTooShort => '件名は3文字以上にしてください';

  @override
  String get feedbackDetailsLabel => '詳細';

  @override
  String get feedbackDetailsRequired => '詳細を入力';

  @override
  String get feedbackDetailsTooShort => '説明は10文字以上で入力してください';

  @override
  String get feedbackAddScreenshot => 'スクリーンショットを追加';

  @override
  String get feedbackAttachmentHint => '最大5枚、1枚5MBまで';

  @override
  String get feedbackSend => '送信';

  @override
  String get feedbackEmptyTitle => '送信はまだありません';

  @override
  String get feedbackEmptyBody => '送信したフィードバックとステータスが表示されます';

  @override
  String get feedbackHistoryTitle => '送信履歴';

  @override
  String get feedbackStatusOpen => '未対応';

  @override
  String get feedbackStatusInProgress => '処理中';

  @override
  String get feedbackStatusResolved => '解決済み';

  @override
  String get feedbackStatusClosed => 'クローズ';

  @override
  String get legalIntro => 'データの保護方針とFitCheck AI利用規約';

  @override
  String get legalPolicies => 'ポリシー';

  @override
  String get legalPrivacySubtitle => '収集データと目的';

  @override
  String get legalTermsTitle => '利用規約';

  @override
  String get legalTermsSubtitle => 'アプリの利用ルール';

  @override
  String get legalLicences => 'オープンソースライセンス';

  @override
  String get legalSupportSubtitle => 'サポート・連絡先・プライバシー依頼';

  @override
  String get legalReportAbuse => '問題や不適切な利用の報告';

  @override
  String get permissionCameraTitle => 'カメラへのアクセス';

  @override
  String get permissionCameraRationale =>
      'FitCheck AIでは、AI着せ替えやクローゼット整理のために衣類やスタイリングの写真を撮影します。';

  @override
  String get permissionPhotoTitle => '写真へのアクセス';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AIでは、AI機能やクローゼットに表示するため、衣類やスタイリングの写真を選択します。';

  @override
  String get permissionNotNow => '今はしない';

  @override
  String get permissionOpenSettings => '設定を開く';

  @override
  String authSignedInAs(String name) {
    return '$name としてログイン中';
  }

  @override
  String get authSignedIn => 'ログインしました';

  @override
  String get authWelcomeBackTitle => 'おかえりなさい';

  @override
  String get authSignInFailed => 'ログイン失敗';

  @override
  String get authWelcomeTitle => 'ようこそ';

  @override
  String get authSignUpFailed => '登録失敗';

  @override
  String get authGoogleSignInFailed => 'Googleログイン失敗';

  @override
  String get authAppleSignInFailed => 'Appleログイン失敗';

  @override
  String get authConfirmEmailTitle => 'メール確認';

  @override
  String get authConfirmEmailBody => '確認メールをご確認のうえ、ログインしてください。';

  @override
  String get authClosetReady => 'クローゼットの準備ができました。';

  @override
  String get authSignedOutTitle => 'ログアウトしました';

  @override
  String get authSignedOutBody => 'ログアウトしました。';

  @override
  String get authSignOutFailed => 'ログアウト失敗';

  @override
  String get authEmailSentTitle => 'メール送信済み';

  @override
  String get authResetLinkSent => 'リセットリンクをお送りしました。';

  @override
  String get authPasswordUpdatedTitle => 'パスワード更新';

  @override
  String get authPasswordUpdated => 'パスワードを更新しました。';

  @override
  String get authPasswordNotUpdated => 'パスワード更新なし';

  @override
  String get authCouldNotSendEmail => 'メールを送信できません';

  @override
  String get authEmailNotSent => 'メール未送信';

  @override
  String get authResendSentBody => '新しい確認メールを送信しました。';

  @override
  String get outfitPreviewWithAi => 'AIプレビュー';

  @override
  String get outfitNewPreview => 'プレビューを作成';

  @override
  String get outfitBuilderClosetHeading => 'クローゼット';

  @override
  String get outfitBuilderSearchHint => 'アイテムを検索';

  @override
  String get outfitClearSearch => '検索をクリア';

  @override
  String get outfitBuilderAddPiecesTitle => 'まずアイテムを追加';

  @override
  String get outfitBuilderAddPiecesBody => 'コーディネートはクローゼットのアイテムで作成されます。';

  @override
  String get outfitBuilderNoMatches => '該当するアイテムがありません。';

  @override
  String get outfitNameLabel => 'コーディネート名';

  @override
  String get outfitNameHint => '例:週末のリネン';

  @override
  String get outfitPreviewSemantic => 'コーディネート AIプレビュー';

  @override
  String get outfitChoosePieces => 'アイテムを選択';

  @override
  String get outfitTapPiecesHint => '下のアイテムをタップして追加してください。';

  @override
  String get outfitShareTooltip => '共有';

  @override
  String get outfitSaveFavourite => 'お気に入りに保存';

  @override
  String get outfitPiecesHeading => 'アイテム';

  @override
  String get outfitWearHistoryEmpty => '一度着ると日付がここに表示されます。';

  @override
  String get outfitWearHistoryTitle => '着用履歴';

  @override
  String get outfitWearHistoryError => '日付を読み込めませんでした。';

  @override
  String get outfitWornOn => '着用日';

  @override
  String get outfitEditTitle => 'コーディネートを編集';

  @override
  String get outfitSavedPhotosFailed => '詳細は保存されましたが、写真はありません。';

  @override
  String get outfitNoPhotosBody => '写真はまだありません。代わりにアイテムが表示されます。';

  @override
  String get outfitOccasionLabel => 'シーン';

  @override
  String get outfitOccasionNone => 'なし';

  @override
  String get outfitTagsHint => 'カンマで区切ってください';

  @override
  String get outfitDraftBody => 'メインリストでは非表示です';

  @override
  String get outfitPublic => '公開';

  @override
  String get outfitPublicBody => 'リンクを知っている誰でも見れます';

  @override
  String get outfitDeleteFromDetail => '詳細ページからこのコーディネートを削除します。';

  @override
  String get outfitNewCollection => '新しいコレクション';

  @override
  String get outfitNoCollectionsTitle => 'コレクションはまだありません';

  @override
  String get outfitNoCollectionsBody => '旅行、季節、気分などでコーディネートをグループ化します。';

  @override
  String get outfitCreateCollection => 'コレクションを作成';

  @override
  String get outfitAddOutfits => 'コーディネートを追加';

  @override
  String get outfitRename => '名前を変更';

  @override
  String get outfitCollectionDeleteBody => '中のコーディネートは保持されます。';

  @override
  String get outfitCollectionsNotLoaded => 'コーディネートを取得できません';

  @override
  String get outfitRenameCollection => 'コレクション名を変更';

  @override
  String get outfitDescriptionOptional => '説明（任意）';

  @override
  String get outfitAllInCollection => 'すべてのコーデがこのコレクションにすでにあります。';

  @override
  String get photoshootSubtitleUpload => 'お写真からスタジオポートレートを作成';

  @override
  String get photoshootSubtitleConfigure => 'スタイル・フォーマット・枚数を選択';

  @override
  String get photoshootSubtitleGenerating => '1〜2分ほどお待ちください';

  @override
  String get photoshootAddPhotosSemantic => 'ギャラリーから写真を追加';

  @override
  String get photoshootUploadTitle => '自分の写真を1〜4枚追加';

  @override
  String get photoshootUploadBody => 'タップしてギャラリーから選択';

  @override
  String get photoshootAddToContinue => '続けていくには写真を追加';

  @override
  String get photoshootAddAnotherPhoto => '追加の写真を追加';

  @override
  String get photoshootTipsTitle => 'ベストな結果のためのヒント';

  @override
  String get photoshootTipsBody => 'はっきりした明るい、複数方向からの顔写真を使用。サングラスや帽子は外してください。';

  @override
  String get photoshootStarting => '開始中';

  @override
  String get photoshootCancelling => 'キャンセル中';

  @override
  String get photoshootFailed => '失敗しました';

  @override
  String get recommendTabMatches => 'マッチ';

  @override
  String get recommendTabComplete => '完成';

  @override
  String get recommendTabWeather => '天気';

  @override
  String get recommendTabColours => 'カラー';

  @override
  String get recommendTabShop => 'ショップ';

  @override
  String get recommendNoMatchesTitle => 'まだマッチなし';

  @override
  String get recommendNoMatchesBody => 'アイテムを選択すると、相性の良いものを検索します。';

  @override
  String get recommendPickPiece => 'アイテムを選択';

  @override
  String get recommendNothingMatchesTitle => 'まだこれにマッチするものなし';

  @override
  String get recommendNothingMatchesBody => '他のアイテムを試すか、クローゼットに追加してください。';

  @override
  String get recommendChangePieces => 'アイテムを変更';

  @override
  String get recommendDefaultReason => '選択したアイテムに合います。';

  @override
  String get recommendCompleteTitle => 'ルックを完成';

  @override
  String get recommendCompleteBody => 'アイテムを選択すると、残りを補充します。';

  @override
  String get recommendWorking => '処理中';

  @override
  String get recommendGenerate => '生成';

  @override
  String get recommendChooseStyleBody => 'スタイルを選んでから生成';

  @override
  String get recommendNoLooksTitle => '該当するコーディネートなし';

  @override
  String get recommendNoLooksBody => '別のスタイルか、アイテムを変更してください。';

  @override
  String get recommendDefaultLook => 'アイテムのコーディネート';

  @override
  String get recommendNoPiecesBody => 'このコーデに該当するアイテムがありません。';

  @override
  String get recommendCityLabel => '都市';

  @override
  String get recommendCheck => '確認';

  @override
  String get recommendWeatherTitle => '今日の天気';

  @override
  String get recommendWeatherBody => '都市を入力して、今日のコーデを探そう。';

  @override
  String get recommendWearToday => '今日着る';

  @override
  String get recommendWeatherNoPieces => 'この天候に合うアイテムがクローゼットにまだありません。';

  @override
  String get recommendBudgetLabel => '予算';

  @override
  String get recommendLooking => '探索中';

  @override
  String get recommendFindWhatToBuy => '買うべきものを探す';

  @override
  String get recommendFillGapsTitle => 'ギャップを埋める';

  @override
  String get recommendFillGapsBody => '予算を設定して、クローゼットに足りないものを提案します。';

  @override
  String get recommendNoGapsTitle => 'ギャップなし';

  @override
  String get recommendNoGapsBody => '予算を上げるか、別のカテゴリを試してください。';

  @override
  String get recommendMoodEveryday => '普段使い';

  @override
  String get recommendMoodBigMeeting => '重要な会議';

  @override
  String get recommendDayLabel => '日';

  @override
  String get recommendReadingStars => '星を読む';

  @override
  String get recommendGetMyColours => 'カラートルクを確認';

  @override
  String get recommendLuckyColoursTitle => 'あなたのラッキーカラー';

  @override
  String get recommendLuckyColoursBody => '日を選んで、その日に見合うカラーとアイテムを提案します。';

  @override
  String get recommendLuckyColoursSection => 'ラッキーカラー';

  @override
  String get recommendAvoidColoursSection => '控えめにするカラー';

  @override
  String get recommendBirthDateTitle => '生年月日を追加';

  @override
  String get recommendBirthDateBody => 'カラーを読むには生年月日が必要です。';

  @override
  String get recommendEditProfile => 'プロフィール編集';

  @override
  String get recommendNothingThisDay => 'この日はありません。';

  @override
  String get recommendUnnamedColour => '無名のカラー';

  @override
  String get recommendFromCloset => 'クローゼットから';

  @override
  String get recommendNoPiecesInColours => 'これらのカラーのアイテムはまだありません。';

  @override
  String get recommendOutfitIdeas => 'コーデ案';

  @override
  String get recommendNoOutfitsInColours => 'これらのカラーの全身コーデはまだありません。';

  @override
  String get recommendDefaultOutfitIdea => 'コーデ案';

  @override
  String get recommendPickUpToThree => '3アイテムまで選択';

  @override
  String get recommendEmptyClosetBody => 'まずアイテムを追加して、マッチングをご覧ください。';

  @override
  String get dashboardDressForDay => '次の1日を彩るコーデを。';

  @override
  String get dashboardOutfitOfDay => '今日のコーデ';

  @override
  String get dashboardFreshLook => '新しいスタイル';

  @override
  String get subscriptionManageInStoreTitle => 'ストアで管理';

  @override
  String get subscriptionManageInStoreBody =>
      'このプランはストア経由で課金されます。ストアのアカウント設定で管理してください。';

  @override
  String get subscriptionCancelledTitle => 'サブスクリプション終了';

  @override
  String get subscriptionCancelledBody => 'プランは請求期間終了まで有効です。';

  @override
  String get subscriptionCancelFailedTitle => 'キャンセルできません';

  @override
  String get subscriptionCouldNotOpenTitle => '開けません';

  @override
  String get subscriptionOpenBillingFailedBody => '請求管理を開けませんでした。';

  @override
  String get subscriptionOpenLinkFailedBody => 'リンクを開けませんでした。';

  @override
  String get subscriptionReferralLoadFailedTitle => 'リンクを読み込めません';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'リファラルリンクを読み込めませんでした。再試行してください。';

  @override
  String get subscriptionReferralCopiedTitle => 'コピーしました';

  @override
  String get subscriptionReferralCopiedBody => 'リファラルリンクをコピーしました。';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AIを体験';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AIに参加して、二人ともProを1ヶ月間使えます。$link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'リンクをコピーしました';

  @override
  String get subscriptionShareUnavailableBody => '共有できません。リンクをコピーしました。';

  @override
  String get subscriptionShareFailedTitle => '共有できません';

  @override
  String get subscriptionShareFailedBody => '紹介ページからリンクをコピーしてください。';

  @override
  String get subscriptionStoreReadyTitle => 'ストア設定完了';

  @override
  String get subscriptionStoreReadyBody => 'ストア価格が利用可能になりました。今すぐアップグレードできます。';

  @override
  String get purchaseFailedTitle => '購入に失敗しました';

  @override
  String get purchaseUnavailableTitle => '購入できません';

  @override
  String get purchaseIapUnavailableBody => 'このデバイスではアプリ内購入を利用できません。';

  @override
  String get purchasePlanNotAvailableBody => 'このプランは購入できません。';

  @override
  String get purchasePlanNotInStoreBody => 'このプランはまだストアで提供されていません。しばらくお待ちください。';

  @override
  String get purchaseStartFailedBody => '購入を開始できませんでした。もう一度お試しください。';

  @override
  String get purchaseNoPaymentLinkBody => 'チェックアウトで支払いリンクが返されませんでした。';

  @override
  String get purchasePendingTitle => '購入保留中';

  @override
  String get purchasePendingBody => '購入は承認を待っています。承認後すぐ利用可能になります。';

  @override
  String get purchaseFailedBody => '購入に失敗しました。もう一度お試しください。';

  @override
  String get purchaseRestoredTitle => '復元しました';

  @override
  String get purchaseRestoredBody => '購入履歴を復元しました。';

  @override
  String get purchaseActiveTitle => 'サブスクリプション有効';

  @override
  String get purchaseActiveBody => 'サブスクリプションが有効です。ようこそ。';

  @override
  String get purchaseSignInRequiredTitle => 'ログインが必要';

  @override
  String get purchaseSignInRequiredBody => '購入を完了するにはログインしてください。';

  @override
  String get purchaseErrorTitle => '購入エラー';

  @override
  String get purchaseInvalidTransactionBody => '購入に検証可能な取引IDが含まれていませんでした。';

  @override
  String get purchaseVerificationPendingTitle => '検証保留中';

  @override
  String get purchaseVerificationPendingBody =>
      '現在ストアでの購入検証ができません。自動で完了し、二重に請求されることはありません。';

  @override
  String get purchaseNotAppliedTitle => '購入が適用されていません';

  @override
  String get purchaseNotAppliedBody =>
      'アカウントに購入を適用できませんでした。サポートにお問い合わせください。再購入しないでください。';

  @override
  String get purchaseRestoreFailedTitle => '復元に失敗しました';

  @override
  String get purchaseRestoreFailedBody => '購入を復元できませんでした。もう一度お試しください。';

  @override
  String get purchaseRecoveredActiveBody => 'サブスクリプションが有効です。';

  @override
  String get purchaseCompleteTitle => '購入完了';

  @override
  String get giftCreateFailedTitle => 'ギフトを作成できませんでした';

  @override
  String get giftClaimFailedTitle => 'ギフトの受け取りに失敗しました';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のギフトが届いています',
      one: 'ギフトが1件届いています',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1ヶ月',
      '12': '1年',
      'other': '$monthsヶ月',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '残り$remaining回',
      one: '残り1回',
    );
    return '$duration、$_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro $duration';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender から FitCheck Pro $duration を受け取れました。$link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'FitCheck Pro のギフトを$recipientへ';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender から';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient 宛';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender から';
  }

  @override
  String get giftPreviewPlaceholderRecipient => '受信者';

  @override
  String get giftPreviewPlaceholderSender => '自分';

  @override
  String get settingsSavedTitle => '保存しました';

  @override
  String get settingsNotSavedTitle => '保存されていません';

  @override
  String get settingsAiChooseProviderBody => 'プロバイダを選択してください。';

  @override
  String get settingsAiCustomUrlRequiredBody => 'カスタムプロバイダにはAPI URLが必要です。';

  @override
  String get settingsAiKeyRequiredBody => 'APIキーを入力してください。';

  @override
  String get settingsAiSavedBody => 'AI設定を保存しました。';

  @override
  String get settingsAiMissingDetailsTitle => '情報が不足しています';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'テストするにはAPI URLとチャットモデルを入力してください。';

  @override
  String get settingsAiKeyNeededTitle => 'APIキーが必要です';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'テストするにはAPIキーを入力してください。保存されたキーは非公開です。';

  @override
  String get settingsAiKeyToTestBody => 'テストするにはAPIキーを入力してください。';

  @override
  String get settingsAiConnectedTitle => '接続しました';

  @override
  String get settingsAiConnectedBody => '接続に問題はありません。';

  @override
  String get settingsAiTestFailedTitle => 'テストに失敗しました';

  @override
  String get settingsPreferencesSavedBody => '設定を保存しました。';

  @override
  String get settingsPasswordNotChangedTitle => 'パスワードは変更されていません';

  @override
  String get settingsOAuthPasswordBody =>
      'このアカウントは Google または Apple に認証代行されています。パスワードを設定するには「パスワードをお忘れですか？」を使用してください。';

  @override
  String get settingsCurrentPasswordIncorrectBody => '現在のパスワードが正しくありません。';

  @override
  String get settingsExportReadyTitle => 'エクスポート準備完了';

  @override
  String get settingsExportReadyBody => 'データのエクスポートをダウンロードできます。';

  @override
  String get settingsLinkCopiedTitle => 'リンクをコピーしました';

  @override
  String get settingsExportClipboardBody =>
      'ブラウザを開けなかったため、ダウンロードリンクをコピーしました。有効期限があるため、すぐにブラウザに貼り付けてください。';

  @override
  String get settingsExportFailedTitle => 'エクスポートに失敗しました';

  @override
  String get settingsAccountNotDeletedTitle => 'アカウントを削除できませんでした';

  @override
  String photoshootPhotoLimit(int max) {
    return '最大$max枚まで追加できます。';
  }

  @override
  String get photoshootPhotoLimitTitle => '枚数の上限';

  @override
  String get photoshootAddAtLeastOnePhoto => '少なくとも1枚追加してください。';

  @override
  String get photoshootNoPhotosSelectedTitle => '写真がありません';

  @override
  String get photoshootDescribeLookBody => '作成したいルックを説明してください。';

  @override
  String get photoshootPromptNeededTitle => 'プロンプトが必要です';

  @override
  String get photoshootConsentFeatureLabel => 'AIフォトシューティング';

  @override
  String get photoshootStatusPreparing => '写真を準備中';

  @override
  String get photoshootStatusGenerating => '生成中';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'バッチ $current / $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done / $total 完了';
  }

  @override
  String get photoshootGenerationFailedBody => '生成に失敗しました。';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready件準備完了、$failed件失敗。';
  }

  @override
  String get photoshootPartlyDoneTitle => '部分的に完了';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚の写真が準備完了です。',
      one: '1枚の写真が準備完了です。',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody => '接続が切断されました。もう一度お試しください。';

  @override
  String get photoshootCouldNotCancelTitle => 'キャンセルできませんでした';

  @override
  String get photoshootRetryFailedTitle => '再試行に失敗しました';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return '写真 $number が準備完了です。';
  }

  @override
  String get photoshootReplacedTitle => '差し替え済み';

  @override
  String get photoshootSavedToGalleryBody => 'ギャラリーに保存しました。';

  @override
  String get photoshootSavedTitle => '保存しました';

  @override
  String get photoshootNotSavedTitle => '未保存';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '全$count枚の写真がギャラリーにあります。',
      one: '1枚の写真がギャラリーにあります。',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$total枚中$saved枚保存しました。';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => '一部の写真を保存できませんでした';

  @override
  String get tryonConsentFeatureLabel => 'バーチャル試着';

  @override
  String get tryonAvatarUpdatedBody => '写真を更新しました。';

  @override
  String get tryonSavedTitle => '保存しました';

  @override
  String get tryonUploadFailedTitle => 'アップロードに失敗しました';

  @override
  String get tryonChooseGarmentFirstBody => 'まず着用アイテムを選択してください。';

  @override
  String get tryonNoGarmentTitle => '着用アイテムなし';

  @override
  String get tryonWaitForUploadBody => '写真のアップロード完了までお待ちください。';

  @override
  String get tryonStillUploadingTitle => 'アップロード中';

  @override
  String get tryonAddYourPhotoFirstBody => 'まず自分の写真を追加してください。';

  @override
  String get tryonReadyBody => '試着準備が整いました。';

  @override
  String get tryonFailedTitle => '試着に失敗しました';

  @override
  String get tryonSavedToGalleryBody => 'ギャラリーに保存しました。';

  @override
  String get tryonNotSavedTitle => '保存していません';

  @override
  String get calendarEventAddedBody => 'イベントを追加しました';

  @override
  String get calendarEventPlannedTitle => '予定済み';

  @override
  String get calendarEventSavedBody => 'イベントを保存しました';

  @override
  String get calendarSavedTitle => '保存しました';

  @override
  String get calendarEventNotSavedTitle => 'イベントを保存していません';

  @override
  String get calendarEventRemovedBody => 'イベントを削除しました';

  @override
  String get calendarEventDeletedTitle => '削除しました';

  @override
  String get calendarEventNotDeletedTitle => 'イベントを削除していません';

  @override
  String get calendarOutfitNotLinkedTitle => 'コーデが関連付けられていません';

  @override
  String get calendarLinkedTitle => '関連付けました';

  @override
  String get calendarOutfitNotRemovedTitle => 'コーデの削除に失敗しました';

  @override
  String get calendarOutfitRemovedBody => 'コーデを削除しました';

  @override
  String get calendarDisconnectedBody => 'カレンダーを解除しました';

  @override
  String get calendarDisconnectedTitle => '解除しました';

  @override
  String get calendarNotDisconnectedTitle => 'カレンダーを解除していません';

  @override
  String get calendarTodayLabel => '今日';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の予定',
      one: '1件の予定',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$startから$end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title、$time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title、$time、コーデ連携済み';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\"を削除します。';
  }

  @override
  String get calendarThisAppLabel => 'このアプリ';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$providerとの同期は現在利用できません。こちらで予定を追加できます。';
  }

  @override
  String get calendarWeekdaySunShort => '日';

  @override
  String get calendarWeekdayMonShort => '月';

  @override
  String get calendarWeekdayTueShort => '火';

  @override
  String get calendarWeekdayWedShort => '水';

  @override
  String get calendarWeekdayThuShort => '木';

  @override
  String get calendarWeekdayFriShort => '金';

  @override
  String get calendarWeekdaySatShort => '土';

  @override
  String get calendarWeekdayMonday => '月曜日';

  @override
  String get calendarWeekdayTuesday => '火曜日';

  @override
  String get calendarWeekdayWednesday => '水曜日';

  @override
  String get calendarWeekdayThursday => '木曜日';

  @override
  String get calendarWeekdayFriday => '金曜日';

  @override
  String get calendarWeekdaySaturday => '土曜日';

  @override
  String get calendarWeekdaySunday => '日曜日';

  @override
  String get outfitSavedToFavouritesBody => 'お気に入りに保存しました';

  @override
  String get outfitRemovedFromFavouritesBody => 'お気に入りから削除しました';

  @override
  String get outfitNotSavedTitle => '保存されていません';

  @override
  String get outfitLoggedAsWornBody => '今日の着用を記録しました。';

  @override
  String get outfitNicePickTitle => 'いいコーデ';

  @override
  String get outfitRemovedBody => 'コーデを削除しました。';

  @override
  String get outfitDeletedTitle => '削除しました';

  @override
  String get outfitNotDeletedTitle => '削除されていません';

  @override
  String get outfitDuplicatedBody => 'コピーがコーディネートに追加されました。';

  @override
  String get outfitDuplicatedTitle => '重複';

  @override
  String get outfitNotDuplicatedTitle => '重複なし';

  @override
  String get outfitNotSharedTitle => '未共有';

  @override
  String outfitCollectionReadyBody(String name) {
    return '「$name」の準備が完了しました。';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'コレクション未作成';

  @override
  String get outfitCollectionUpdatedBody => 'コレクションを更新しました。';

  @override
  String get outfitCollectionNotUpdatedTitle => 'コレクション未更新';

  @override
  String get outfitCollectionDeletedBody => 'コレクションを削除しました。';

  @override
  String get outfitCollectionNotDeletedTitle => 'コレクション未削除';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countつのコーデを追加しました。',
      one: '1つのコーデを追加しました。',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'コーデ未追加';

  @override
  String get outfitPreviewNotCreatedTitle => 'プレビュー未作成';

  @override
  String get outfitGiveNameBody => 'コーデに名前を付けてください。';

  @override
  String get outfitNameMissingTitle => '名前';

  @override
  String get outfitChooseAtLeastOnePieceBody => '1つ以上のアイテムを選択してください。';

  @override
  String outfitCreatedBody(String name) {
    return '$nameがコーデに追加されました。';
  }

  @override
  String get outfitSavedTitle => '保存済み';

  @override
  String get wardrobeAddedToFavouritesBody => 'お気に入りに追加しました';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'お気に入りから削除しました';

  @override
  String get wardrobeNotSavedTitle => '保存されませんでした';

  @override
  String get wardrobeLoggedAsWornBody => '本日の着用として記録しました。';

  @override
  String get wardrobeRemovedFromClosetBody => 'クローゼットから削除しました。';

  @override
  String get wardrobeDeletedTitle => '削除済み';

  @override
  String get wardrobeNotDeletedTitle => '削除されませんでした';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countつのアイテムをクローゼットから削除しました。',
      one: '1つのアイテムをクローゼットから削除しました。',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AIクローゼット抽出';

  @override
  String get itemAddScanJobLabel => 'スキャン';

  @override
  String get itemAddFoundEarlierBody => '以前のスキャンで検出されました';

  @override
  String get itemAddLookingAtPhoto => '写真を確認中';

  @override
  String get itemAddExtractionFailedBody => '抽出に失敗しました';

  @override
  String get itemAddJobFailedBody => '処理に失敗しました';

  @override
  String get itemAddConnectionLostBody => '接続が切断されました。再試行してください。';

  @override
  String get itemAddConnectionLostProcessingBody => '処理中に接続が切断されました。';

  @override
  String itemAddGeneratingPiece(int number) {
    return '$number 着目';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'アイテム';

  @override
  String get itemAddNotCancelledTitle => 'キャンセルされませんでした';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 着がクローゼットに追加されました。',
      one: '1 着がクローゼットに追加されました。',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$total 着中$saved 着を保存しました。残りも保存する場合はタップしてください。';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => '一部のアイテムが保存されませんでした';

  @override
  String get batchChooseAtLeastOnePhotoBody => '少なくとも1枚の写真を選択してください。';

  @override
  String get batchPhotoUnreadableBody => 'この写真は読み取れませんでした。';

  @override
  String get batchNoPhotosReadableBody => 'これらの写真は読み取れませんでした。他の写真を試してください。';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 枚',
      one: '1 枚',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody => '作業中に接続が切断されました。再試行してください。';

  @override
  String get batchNotCancelledTitle => 'キャンセルされませんでした';

  @override
  String get batchPostLinkUnsupportedBody =>
      '投稿リンクは対応していません。プロファイルリンクを入力してください。';

  @override
  String get batchLinkSpacesBody => 'リンクにはスペースを含めることはできません。';

  @override
  String get batchEnterProfileLinkBody =>
      'Instagram または Facebook のプロファイルリンクを入力してください。';

  @override
  String get batchEnterProfileLinkShortBody => 'プロファイルリンクを入力してください。';

  @override
  String get batchSignInPageNotOpenBody => 'サインインページが開きませんでした。再試行してください。';

  @override
  String get batchSignInBrowserBody => 'ブラウザでサインインしてから、FitCheck に戻ってください。';

  @override
  String get batchConnectAccountTitle => 'アカウントを連携';

  @override
  String get batchEnterAuthenticatorCodeBody => '認証アプリのコードを入力してください。';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram ではセキュリティチェックが必要です。先にブラウザでサインインしてください。';

  @override
  String get batchEnterCredentialsAgainBody => 'ユーザー名とパスワードをもう一度入力してください。';

  @override
  String get batchSignInFailedBody => 'サインインに失敗しました。ユーザー名とパスワードを確認してください。';

  @override
  String get batchSignInToKeepImportingBody => 'インポートを続けるにはサインインしてください。';

  @override
  String get batchAccountNotConnectedBody => 'アカウントが連携されませんでした。';

  @override
  String get batchAccountConnectedTitle => 'アカウントが連携されました';

  @override
  String get batchNotConnectedTitle => '未接続';

  @override
  String get batchImportConnectionLostBody => '接続が切断されました。更新して状態を確認してください。';

  @override
  String batchPickUpToBody(int max) {
    return '最大$max枚まで写真を選択。パーツを自動検出します。';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count / $total枚';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '写真 $done / $count 枚を準備中';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚の写真からパーツを検出',
      one: '写真1枚からパーツを検出',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return '$platformアカウントは二段階認証を使用しています。認証アプリの6桁コードを入力してください。';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'この$platformプロフィールは非公開、または写真表示にサインインが必要です。';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platformと連携';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚見つかりました',
      one: '1枚見つかりました',
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
    return '$processed / $total 件処理済み · $added件追加 · $waiting件保留 · $skipped件スキップ';
  }

  @override
  String batchScanningPhoto(int number) {
    return '写真$numberをスキャン中';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '次の写真：$number';
  }

  @override
  String batchPhotoLabel(int number) {
    return '写真$number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countつのパーツが見つかりました',
      one: '1つのパーツが見つかりました',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚の写真がワードローブに追加されました。',
      one: '1枚の写真がワードローブに追加されました。',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count枚のスタジオ写真が処理中です。完成分を保存するか、終了しても後ほどお知らせします。',
      one: 'スタジオ写真が1枚処理中です。完成分を保存するか、終了しても後ほどお知らせします。',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return '未保存：$names。';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos枚の写真から',
      one: '写真1枚から',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$piecesつのパーツ',
      one: 'パーツ1つ',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen件選択済み。タップすると除外できます。';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countつのパーツを保存中',
      one: 'パーツ1つを保存中',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countつのパーツを保存',
      one: 'パーツ1つを保存',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'ボディアプロファイルが保存されました。';

  @override
  String get bodyProfileSavedTitle => '保存済み';

  @override
  String get bodyProfileNotSavedTitle => '未保存';

  @override
  String get bodyProfileSetDefaultBody => 'デフォルトプロファイルとして設定します。';

  @override
  String get bodyProfileDeletedBody => 'ボディアプロファイルが削除されました。';

  @override
  String get bodyProfileDeletedTitle => '削除済み';

  @override
  String get bodyProfileNotDeletedTitle => '未削除';

  @override
  String get feedbackNotSentTitle => '未送信';

  @override
  String get feedbackSentBody => 'ありがとうございます。すべてのメッセージを読み返し、追加情報が必要な場合は返信します。';

  @override
  String get feedbackSentTitle => 'フィードバック送信';

  @override
  String get recommendUnnamedPiece => '未命名アイテム';

  @override
  String get recommendEnterCityBody => '天候に合わせたおすすめを提供するため、都市名を入力してください。';

  @override
  String get recommendWhichCityTitle => 'どの都市ですか？';

  @override
  String get aiConsentSheetTitle => 'AIサービスへの写真共有';

  @override
  String get aiConsentSheetBody =>
      '試着・写真撮影イメージを作成するために、FitCheck AIは、あなたが提供した写真（顔や体の画像を含む）を信頼できるサードパーティのAIプロバイダー（OpenAIやGoogle Geminiなど）に送ります。それらは、当社との契約に基づいてイメージを生成し、モデルの学習には使用しません。写真は安全に送信され、広告目的での共有は行われません。';

  @override
  String get aiConsentSheetPermission =>
      '続行すると、これらのAIプロバイダーに写真を共有してイメージ生成を行うことを明示的に許可したことになります。';

  @override
  String get skeletonsLoadMoreFailed => 'さらに読み込めませんでした。';

  @override
  String get jobsPiecesReadyTitle => 'アイテムが完成しました';

  @override
  String get jobsScanStoppedTitle => 'スキャンが停止しました';

  @override
  String get jobsNothingSavedBody => '何も保存されませんでした。再試行してください。';

  @override
  String get jobsPhotoUploadFailedBody => '写真のアップロードに失敗しました。';

  @override
  String get authGoogleSignInStartFailed => 'Googleサインインを開始できませんでした。再試行してください。';

  @override
  String get referralAppliedTitle => '紹介適用';

  @override
  String get billingStoreUnavailableBody => 'このデバイスではストアでの購入を利用できません。';

  @override
  String get billingPurchaseProcessingBody =>
      '購入は処理中です。1分後にアプリを再開くとプランが表示されます。';

  @override
  String get profileAvatarUploadNoUrl => 'アバターのアップロードで画像URLが返されませんでした。';

  @override
  String get rewardsDayStreakLabel => '日連続';

  @override
  String rewardsBestStreak(int days) {
    return '最高 $days 日';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission のアクセスが必要です';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '現在、$permission へのアクセスが拒否されています。設定で許可してから、戻ってきて再試行してください。';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'ステップ $step / 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'ステップ $step / $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '画像 $index を削除';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '画像 $index を削除';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points ポイント';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '$email へメールしてください。報告は24時間以内に確認します。';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece を削除';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String outfitAddToNamed(String name) {
    return '「$name」に追加';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '「$name」を削除しました。アイテムはクローゼットに残っています。';
  }

  @override
  String outfitShowAllCount(int count) {
    return '全$count件表示';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '本日残り$count枚';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return '写真$indexに失敗しました';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max枚中$selected枚';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shapeボディ・$tone肌';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$nameのオプション';
  }

  @override
  String profileMostWorn(String name, int count) {
    return '最多着用：$name、$count回';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label：未設定';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent%の相性';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max件中$picked件選択';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$itemを削除';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency優先';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'このプランは$storeで請求されます。$storeのアカウント設定で変更またはキャンセルしてください。';
  }

  @override
  String billingManageInStore(String store) {
    return '$storeで管理';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label：$max中$current使用';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return '約$seconds秒残り';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total枚中$done枚のスタジオ写真準備完了';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total枚中$ready枚のスタジオ写真準備完了。アイテムをタップしてスキップ。';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '${height}cm・${weight}kg';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$value$label';
  }

  @override
  String get profileFieldNotSet => 'なし';
}
