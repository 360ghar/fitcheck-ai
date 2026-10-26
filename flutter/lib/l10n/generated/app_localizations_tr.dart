// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Ana Sayfa';

  @override
  String get tabPhotoshoot => 'Çekim';

  @override
  String get tabCloset => 'Dolap';

  @override
  String get tabOutfits => 'Kombinler';

  @override
  String get tabMore => 'Daha Fazla';

  @override
  String get actionAddItem => 'Öğe ekle';

  @override
  String get actionCreateOutfit => 'Kombin oluştur';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionRetry => 'Tekrar dene';

  @override
  String get actionDone => 'Bitti';

  @override
  String get actionNext => 'İleri';

  @override
  String get actionBack => 'Geri';

  @override
  String get actionClose => 'Kapat';

  @override
  String get actionSearch => 'Ara';

  @override
  String get actionContinue => 'Devam et';

  @override
  String get stateLoading => 'Yükleniyor';

  @override
  String get stateErrorTitle => 'Bir şeyler ters gitti';

  @override
  String get stateErrorBody =>
      'Tekrar deneyin. Sorun devam ederse destekle iletişime geçin.';

  @override
  String get stateOfflineTitle => 'Çevrimdışısınız';

  @override
  String get stateOfflineBody =>
      'Dolabınızı eşitlemek ve kombin oluşturmak için yeniden bağlanın.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsAccountSection => 'Hesap';

  @override
  String get settingsPreferencesSection => 'Tercihler';

  @override
  String get settingsPlanBilling => 'Plan ve faturalandırma';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsUnits => 'Ölçü birimleri';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsPrivacySection => 'Gizlilik ve veri';

  @override
  String get settingsAboutSection => 'Hakkında';

  @override
  String get settingsSignOut => 'Çıkış yap';

  @override
  String get settingsDeleteAccount => 'Hesabı sil';

  @override
  String get settingsDeleteAccountTitle => 'Hesabınız silinsin mi?';

  @override
  String get settingsDeleteAccountBody =>
      'Bu işlem dolabınızı, kombinlerinizi, fotoğraflarınızı ve profilinizi kaldırır. Geri alınamaz.';

  @override
  String get settingsUnitsImperial => 'İngiliz (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrik (cm, kg)';

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageSystem => 'Cihaz dilini kullan';

  @override
  String get languageSystemBody =>
      'FitCheck AI telefonunuzun dilini takip eder.';

  @override
  String get languageSearchHint => 'Dil ara';

  @override
  String get languageCurrent => 'Mevcut';

  @override
  String get languageReviewNote =>
      'Bu çeviri yeni. Yanlış gelen bir yer varsa bize bildirin.';

  @override
  String get languageChanged => 'Dil güncellendi';

  @override
  String get paywallTitle => 'Planınızı seçin';

  @override
  String get paywallTrialBadge => '1 ay ücretsiz';

  @override
  String get paywallTrialTitle => 'Pro\'nun ilk ayı ücretsiz';

  @override
  String get paywallTrialBody =>
      'Tüm dolabınızı tek seferde yükleyin. Ardından parçaları eklemeye devam edin.';

  @override
  String get paywallFreeForeverTitle => 'Her zaman ücretsiz';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Kart gerekmez. Her ay $uploads AI yüklemesi, $outfits kombin ve günde $images çekim görseli kazanın.';
  }

  @override
  String get paywallCtaTrial => 'Ücretsiz ayımı başlat';

  @override
  String paywallCtaUpgrade(String plan) {
    return '$plan planına geç';
  }

  @override
  String get paywallRestore => 'Satın alımları geri yükle';

  @override
  String get paywallManage => 'Aboneliği yönet';

  @override
  String get paywallTerms => 'Kullanım koşulları';

  @override
  String get paywallPrivacy => 'Gizlilik politikası';

  @override
  String get paywallPerMonth => 'aylık';

  @override
  String get paywallPerYear => 'yıllık';

  @override
  String get paywallBestValue => 'En iyi fiyat';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Ücretsiz deneme yalnızca yeni aboneler içindir. Deneme sonrasında Pro, bitimine en az 24 saat kala iptal edilmediği sürece $price fiyatla yenilenir.';
  }

  @override
  String get introTitle => 'Dolabın nihayet düzenli';

  @override
  String get introBody =>
      'Kıyafetlerini bir kez fotoğrafla. Sahip olduklarından kombin önerileri, deneme önizlemeleri ve stüdyo fotoğrafları al.';

  @override
  String get introStart => 'Başla';

  @override
  String get introHaveAccount => 'Zaten bir hesabım var';

  @override
  String get introSkip => 'Atla';

  @override
  String get authSignIn => 'Giriş yap';

  @override
  String get authSignUp => 'Hesap oluştur';

  @override
  String get authEmail => 'E-posta';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authForgotPassword => 'Şifremi unuttum';

  @override
  String get authContinueApple => 'Apple ile devam et';

  @override
  String get authContinueGoogle => 'Google ile devam et';

  @override
  String get authOrDivider => 'veya';

  @override
  String get wardrobeTitle => 'Dolap';

  @override
  String get wardrobeEmptyTitle => 'Dolabın boş';

  @override
  String get wardrobeEmptyBody =>
      'İlk parçanı ekle veya tüm gardırobun fotoğrafını tek seferde yükle.';

  @override
  String get wardrobeAddFirst => 'İlk parça ekle';

  @override
  String get wardrobeSearchHint => 'Dolabında ara';

  @override
  String get categoryTops => 'Üst giyim';

  @override
  String get categoryBottoms => 'Alt giyim';

  @override
  String get categoryShoes => 'Ayakkabı';

  @override
  String get categoryAccessories => 'Aksesuar';

  @override
  String get categoryOuterwear => 'Dış giyim';

  @override
  String get categorySwimwear => 'Mayo';

  @override
  String get categoryActivewear => 'Spor giyim';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get conditionClean => 'Temiz';

  @override
  String get conditionDirty => 'Kirli';

  @override
  String get conditionLaundry => 'Yıkamada';

  @override
  String get conditionRepair => 'Tamir gerek';

  @override
  String get conditionDonate => 'Bağış';

  @override
  String get seasonSpring => 'İlkbahar';

  @override
  String get seasonSummer => 'Yaz';

  @override
  String get seasonFall => 'Sonbahar';

  @override
  String get seasonWinter => 'Kış';

  @override
  String get seasonAll => 'Tüm mevsim';

  @override
  String get styleCasual => 'Günlük';

  @override
  String get styleFormal => 'Resmi';

  @override
  String get styleBusiness => 'İş';

  @override
  String get styleSporty => 'Sportif';

  @override
  String get styleBohemian => 'Bohem';

  @override
  String get styleStreetwear => 'Sokak modası';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalist';

  @override
  String get styleRomantic => 'Romantik';

  @override
  String get styleEdgy => 'Iddialı';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Sanatsal';

  @override
  String get styleClassic => 'Klasik';

  @override
  String get styleElegant => 'Zarif';

  @override
  String get styleOther => 'Diğer';

  @override
  String get occasionWork => 'İş';

  @override
  String get occasionDateNight => 'Akşam randevusu';

  @override
  String get occasionTravel => 'Seyahat';

  @override
  String get occasionWedding => 'Düğün';

  @override
  String get occasionGym => 'Spor salonu';

  @override
  String get occasionWeekend => 'Hafta sonu';

  @override
  String get occasionParty => 'Parti';

  @override
  String get occasionInterview => 'Mülakat';

  @override
  String get colorBlack => 'Siyah';

  @override
  String get colorWhite => 'Beyaz';

  @override
  String get colorGrey => 'Gri';

  @override
  String get colorNavy => 'Lacivert';

  @override
  String get colorBrown => 'Kahverengi';

  @override
  String get colorRed => 'Kırmızı';

  @override
  String get colorBlue => 'Mavi';

  @override
  String get colorGreen => 'Yeşil';

  @override
  String get colorPink => 'Pembe';

  @override
  String get colorPurple => 'Mor';

  @override
  String get colorYellow => 'Sarı';

  @override
  String get colorOrange => 'Turuncu';

  @override
  String get colorBeige => 'Bej';

  @override
  String get dateToday => 'Bugün';

  @override
  String get dateYesterday => 'Dün';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün önce',
      one: '1 gün önce',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hafta önce',
      one: '1 hafta önce',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ay önce',
      one: '1 ay önce',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yıl önce',
      one: '1 yıl önce',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'FitCheck AI uygulamasını beğendiniz mi?';

  @override
  String get ratingPromptBody =>
      'Hızlı bir puanlama başkalarının tarzını bulmasına yardımcı olur.';

  @override
  String get ratingPromptYes => 'Uygulamayı değerlendir';

  @override
  String get ratingPromptNo => 'Şimdi değil';

  @override
  String get closetNoMatchesTitle => 'Eşleşen parça yok';

  @override
  String get closetNoMatchesBody =>
      'Daha az filtre deneyin veya başka bir arama yapın.';

  @override
  String get closetClearFilters => 'Filtreleri temizle';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça',
      one: '1 parça',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Parçalarınız yükleniyor';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seçildi',
      one: '1 seçildi',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Seçilenleri sil';

  @override
  String get closetCancelSelection => 'Seçimi iptal et';

  @override
  String get closetCloseSearch => 'Aramayı kapat';

  @override
  String get closetShowGrid => 'Izgara olarak göster';

  @override
  String get closetShowList => 'Liste olarak göster';

  @override
  String get closetShowRows => 'Satır olarak göster';

  @override
  String get closetStatsTitle => 'Gardırop istatistikleri';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça silinsin mi?',
      one: '1 parça silinsin mi?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Bu parçaları kullanan kombinler etkilenecektir.';

  @override
  String get closetSortBy => 'Sıralama';

  @override
  String get closetFavourites => 'Favoriler';

  @override
  String get closetFavourite => 'Favori';

  @override
  String get closetUnfavourite => 'Favorilerden çıkar';

  @override
  String get closetWoreToday => 'Bugün giydim';

  @override
  String closetWornTimes(int count) {
    return '$count kez giyildi';
  }

  @override
  String get closetCategoryLabel => 'Kategori';

  @override
  String get closetUseCaseLabel => 'Kullanım yeri';

  @override
  String get closetAnyUseCase => 'Tümü';

  @override
  String get closetOtherUseCase => 'Diğer kullanım yeri';

  @override
  String get closetOtherUseCaseHint => 'Örneğin, kahvaltı';

  @override
  String get closetUseUseCase => 'Bunu kullan';

  @override
  String get closetClearAll => 'Tümünü temizle';

  @override
  String get sortNewest => 'Önce en yeni';

  @override
  String get sortOldest => 'Önce en eski';

  @override
  String get sortName => 'İsim (A–Z)';

  @override
  String get sortMostWorn => 'En çok giyilen';

  @override
  String get useCaseInformal => 'Günlük';

  @override
  String get useCaseDate => 'Buluşma';

  @override
  String get useCaseDinner => 'Akşam yemeği';

  @override
  String get useCaseLunch => 'Öğle yemeği';

  @override
  String get actionSelect => 'Seç';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionFilter => 'Filtrele';

  @override
  String get actionSort => 'Sırala';

  @override
  String get actionAll => 'Tümü';

  @override
  String get dashboardStartClosetTitle => 'Dolabını oluştur';

  @override
  String get dashboardStartClosetBody =>
      'Birkaç parça fotoğrafla. Senin için etiketleyelim.';

  @override
  String get dashboardPieces => 'parça';

  @override
  String get dashboardOutfits => 'kombin';

  @override
  String get dashboardDayStreak => 'günlük seri';

  @override
  String dashboardAddedThisMonth(int count) {
    return 'bu ay +$count';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'En iyi $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favori',
      one: '1 favori',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kayıtlı kombin',
      one: '1 kayıtlı kombin',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'En çok giyilen: $name, $count kez';
  }

  @override
  String get setupSkip => 'Kurulumu atla';

  @override
  String get setupWhoTitle => 'Kimi giydiriyoruz?';

  @override
  String get setupWhoBody =>
      'Denenen modelleri ve çekimleri belirler. Profilinden değiştirebilirsin.';

  @override
  String get setupStyleTitle => 'En çok ne giyersin?';

  @override
  String get setupStyleBody =>
      'İstediğini seç. Kombin fikirleri bunlardan başlar.';

  @override
  String get setupClosetTitle => 'İlk parçalarını ekle.';

  @override
  String get setupClosetBody =>
      'Birkaç kıyafet veya bir yığın fotoğrafla. Her parça kesilip senin için kaydedilir.';

  @override
  String get setupAddClothes => 'Kıyafet ekle';

  @override
  String get setupStylesLabel => 'Tarzlar';

  @override
  String get setupOccasionsLabel => 'Ortamlar';

  @override
  String get setupSkipStep => 'Atla';

  @override
  String get setupLater => 'Sonra';

  @override
  String get setupSaveError => 'Kaydedilemedi';

  @override
  String get genderWomen => 'Kadın';

  @override
  String get genderMen => 'Erkek';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Belirtmek istemiyorum';

  @override
  String get outfitEmptyTitle => 'Henüz kombin yok';

  @override
  String get outfitEmptyBody =>
      'Dolabındaki parçaları eşleştir ve görünümü kaydet.';

  @override
  String get outfitNoMatchesTitle => 'Eşleşen kombin yok';

  @override
  String get outfitSearchHint => 'Kombinlerinde ara';

  @override
  String get outfitLoading => 'Kombinlerin yükleniyor';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kombin',
      one: '1 kombin',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Tarz ve sezon';

  @override
  String get outfitCollections => 'Koleksiyonlar';

  @override
  String get outfitDuplicate => 'Kopyala';

  @override
  String get outfitDeleteTitle => 'Bu kombin silinsin mi?';

  @override
  String get outfitDeleteBody => 'Parçaları dolabında kalır.';

  @override
  String get outfitDrafts => 'Taslaklar';

  @override
  String get outfitDraft => 'Taslak';

  @override
  String get filterStyle => 'Tarz';

  @override
  String get filterSeason => 'Sezon';

  @override
  String get itemDetailDeleteTitle => 'Bu parça silinsin mi?';

  @override
  String get itemDetailDeleteBody =>
      'Bunu kullanan kombinler bu parçayı kaybeder.';

  @override
  String get itemAddFavourite => 'Favorilere ekle';

  @override
  String itemSize(String size) {
    return 'Beden $size';
  }

  @override
  String get itemColours => 'Renkler';

  @override
  String get itemMaterial => 'Materyal';

  @override
  String get itemPattern => 'Desen';

  @override
  String get itemUseCases => 'Kullanım yeri';

  @override
  String get itemKeptIn => 'Saklandığı yer';

  @override
  String get itemPrice => 'Fiyat';

  @override
  String get itemBought => 'Satın alım';

  @override
  String get itemTags => 'Etiketler';

  @override
  String get itemAdded => 'Eklendi';

  @override
  String get itemTimesWornLabel => 'giyinilme';

  @override
  String get itemLastWornLabel => 'son giyilen';

  @override
  String get itemNeverWorn => 'Hiç';

  @override
  String get authEntryBody =>
      'Gardırobunuzdaki her parça AI ile kombinlenir. Kombin yapın, üzerinizde deneyin.';

  @override
  String get authCreateCloset => 'Gardırobunu oluştur';

  @override
  String get authWelcomeBack => 'Tekrar hoş geldin';

  @override
  String get authSignInBody => 'Gardırobunu açmak için giriş yap.';

  @override
  String get authCreateAccount => 'Hesap oluştur';

  @override
  String get authCreateClosetBody =>
      'Bir dakikanı alır. İlk parçaların ücretsiz.';

  @override
  String get authName => 'İsim';

  @override
  String get authConfirmPassword => 'Şifreyi onayla';

  @override
  String get authReferralCode => 'Davet kodu (isteğe bağlı)';

  @override
  String get authResetTitle => 'Şifreni sıfırla';

  @override
  String get authResetBody =>
      'Yeni bir şifre seçmen için sana e-posta göndereceğiz.';

  @override
  String get authSendResetLink => 'Sıfırlama bağlantısı gönder';

  @override
  String get authBackToSignIn => 'Giriş sayfasına dön';

  @override
  String get authEnterEmail => 'E-postanı gir';

  @override
  String get authEnterValidEmail => 'Geçerli bir e-posta gir';

  @override
  String get authEnterPassword => 'Şifreni gir';

  @override
  String get authPasswordTooShort => 'En az 6 karakter';

  @override
  String get authShowPassword => 'Şifreyi göster';

  @override
  String get authHidePassword => 'Şifreyi gizle';

  @override
  String get authNewHere => 'Yeni misin?';

  @override
  String authConfirmEmail(String email) {
    return 'Giriş yapmadan önce $email adresini onayla. Gelen kutunu kontrol et.';
  }

  @override
  String get authResendEmail => 'Tekrar gönder';

  @override
  String get authResendingEmail => 'Gönderiliyor…';

  @override
  String get authPasswordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get authEnterName => 'Adını gir';

  @override
  String get authChoosePassword => 'Bir şifre seç';

  @override
  String get authHaveAccount => 'Hesabın var mı?';

  @override
  String get authCodeAccepted => 'Kod kabul edildi';

  @override
  String get authCodeNotFound => 'Kod bulunamadı';

  @override
  String authReferralFrom(String name) {
    return '$name tarafından. İkiniz de bir ay ücretsiz kazanırsınız.';
  }

  @override
  String get authReferralInvalid => 'Bu kodu bulamadık.';

  @override
  String authResetSent(String email) {
    return '$email adresine gönderildi. Bağlantıyı bu telefonda aç.';
  }

  @override
  String get introSlide1Title => 'Gardırobunu tek tıkla çek.';

  @override
  String get introSlide1Body =>
      'Kıyafetlerini fotoğrafla. Her parça senin için kesilip kaydedilsin.';

  @override
  String get introSlide2Title => 'Daha hızlı giyin.';

  @override
  String get introSlide2Body =>
      'Planlarına ve havaya uygun, sahip olduğun parçalardan kombinler.';

  @override
  String get introSlide3Title => 'Giymeden önce gör.';

  @override
  String get introSlide3Body =>
      'Kombinleri kendi fotoğrafında dene veya bir çekim gibi yarat.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsTemperature => 'Sıcaklık';

  @override
  String get settingsEmailUpdates => 'E-posta güncellemeleri';

  @override
  String get settingsEmailUpdatesBody => 'E-posta ile haberler ve ipuçları';

  @override
  String get settingsOutfitReminders => 'Kombin hatırlatıcıları';

  @override
  String get settingsOutfitRemindersBody =>
      'Ne giydiğini kaydetmen için bir hatırlatma';

  @override
  String get settingsWeeklySummary => 'Haftalık özet';

  @override
  String get settingsWeeklySummaryBody => 'Kombinlerle geçen haftan';

  @override
  String get settingsStyleSection => 'Stil';

  @override
  String get settingsPreferredStyles => 'Sevdiğin stiller';

  @override
  String get settingsPreferredColours => 'Sevdiğin renkler';

  @override
  String get settingsNoneChosen => 'Seçilmedi';

  @override
  String get settingsPlanAiSection => 'Plan ve AI';

  @override
  String get settingsPlanBillingBody => 'Plan, kullanım ve yükseltmeler';

  @override
  String get settingsPlanUsageBody => 'Plan ve kullanım';

  @override
  String get settingsInviteFriends => 'Arkadaşlarını davet et';

  @override
  String get settingsInviteFriendsBody =>
      'Katılan her arkadaşına bir ay ücretsiz';

  @override
  String get settingsAiProvider => 'Yapay zeka sağlayıcısı';

  @override
  String get settingsAiProviderBody =>
      'Etiketleme ve görseller için kendi modelini kullan';

  @override
  String get settingsAppVersion => 'Uygulama sürümü';

  @override
  String get settingsPrivacyTerms => 'Gizlilik ve koşullar';

  @override
  String get settingsReportProblem => 'Sorun bildir';

  @override
  String get settingsChangePassword => 'Şifreyi değiştir';

  @override
  String get settingsExportData => 'Verilerini dışa aktar';

  @override
  String get settingsExportBody =>
      'Kaydettiğin her şeyi içeren bir dosya hazırlayıp indirmeyi başlatıyoruz.';

  @override
  String get settingsExportAction => 'Dışa aktar';

  @override
  String get settingsCurrentPassword => 'Mevcut şifre';

  @override
  String get settingsNewPassword => 'Yeni şifre';

  @override
  String get settingsConfirmNewPassword => 'Yeni şifreyi onayla';

  @override
  String get settingsEnterCurrentPassword => 'Mevcut şifreni gir';

  @override
  String get settingsEnterNewPassword => 'Yeni bir şifre gir';

  @override
  String get settingsPasswordMin8 => 'En az 8 karakter kullan';

  @override
  String get settingsPasswordNeedsUpper => 'Bir büyük harf ekle';

  @override
  String get settingsPasswordNeedsLower => 'Bir küçük harf ekle';

  @override
  String get settingsPasswordNeedsDigit => 'Bir rakam ekle';

  @override
  String get settingsPasswordsNoMatch => 'Şifreler eşleşmiyor';

  @override
  String get settingsChangeAction => 'Değiştir';

  @override
  String get itemAddSnapTitle => 'Parçayı çek';

  @override
  String get itemAddSnapBody =>
      'Fotoğraftaki her parçayı bulup her biri için net bir stüdyo çekimi oluşturuyoruz.';

  @override
  String get itemAddCamera => 'Fotoğraf çek';

  @override
  String get itemAddGallery => 'Galeriden seç';

  @override
  String get itemAddOtherWays => 'Diğer ekleme yolları';

  @override
  String get itemAddSeveral => 'Birden fazla fotoğraf ekle';

  @override
  String get itemAddSeveralBody => 'Tek seferde 50\'ye kadar';

  @override
  String get itemAddImportProfile => 'Bir profilden aktar';

  @override
  String get itemAddImportProfileBody => 'Instagram veya Facebook';

  @override
  String get itemAddEnterDetails => 'Detayları kendin gir';

  @override
  String get itemAddEnterDetailsBody => 'Fotoğraf gerekmez';

  @override
  String get itemManualIntro =>
      'Yalnızca bir isim gerekli. Gerisini şimdi veya sonra ekle.';

  @override
  String get itemManualNameHint => 'Örneğin mavi pamuklu tişört';

  @override
  String get itemManualEnterName => 'Bir isim gir';

  @override
  String get itemManualNotes => 'Notlar';

  @override
  String get itemManualBrand => 'Marka';

  @override
  String get itemManualSize => 'Beden';

  @override
  String get itemManualEnterNumber => 'Bir numara gir';

  @override
  String get itemManualSavePiece => 'Parçayı kaydet';

  @override
  String get itemManualSaving => 'Kaydediliyor';

  @override
  String get itemManualSavedTitle => 'Kaydedildi';

  @override
  String itemManualSavedBody(String name) {
    return '$name gardırobunda.';
  }

  @override
  String get itemManualNotSaved => 'Kaydedilmedi';

  @override
  String get itemManualAddUseCase => 'Kullanım alanı ekle';

  @override
  String get itemManualAddUseCaseAction => 'Kullanım alanı ekle';

  @override
  String get itemPhotos => 'Fotoğraflar';

  @override
  String get itemAddPhotos => 'Fotoğraf ekle';

  @override
  String get itemNoPhotoYet =>
      'Henüz fotoğraf yok. Fotoğrafsız da kaydedebilirsin.';

  @override
  String get itemRemovePhoto => 'Fotoğrafı kaldır';

  @override
  String get itemRemovePiece => 'Parçayı kaldır';

  @override
  String get filterConditionLabel => 'Durum';

  @override
  String get photoshootStepPhotos => 'Fotoğraflar';

  @override
  String get photoshootStepSetup => 'Kurulum';

  @override
  String get photoshootStepCreating => 'Oluşturuluyor';

  @override
  String get photoshootStepResults => 'Sonuçlar';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Adım $current / $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Bir fotoğraf başarısız oldu. Aşağıdan tekrar dene.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotoğraf başarısız oldu. Aşağıdakileri ayrı ayrı tekrar dene.';
  }

  @override
  String get photoshootFormat => 'Biçim';

  @override
  String get photoshootHowMany => 'Kaç tane';

  @override
  String get photoshootYourPrompt => 'Tarifin';

  @override
  String get photoshootPromptHint => 'Çatıda gün batımı, keten gömlek';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotoğır oluştur',
      one: '1 fotoğır oluştur',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotoğraf',
      one: 'fotoğraf',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'Bugünkü limit kontrol edilemedi.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan plan: Bugün $limit hakkından $remaining kaldı';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Ücretsiz';

  @override
  String get photoshootGallery => 'Galeri';

  @override
  String get photoshootUseCamera => 'Kamera kullan';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return '$number. fotoğrafı kaldır';
  }

  @override
  String get photoshootNoPhotosTitle => 'Fotoğraf dönmedi';

  @override
  String get photoshootNoPhotosBody =>
      'Çekim görsel olmadan tamamlandı. Tekrar dene.';

  @override
  String get photoshootNewStyle => 'Yeni tarz';

  @override
  String get photoshootNewPhotos => 'Yeni fotoğraflar';

  @override
  String photoshootOpenPhoto(int number) {
    return '$number. fotoğrafı aç';
  }

  @override
  String get photoshootReportPhoto => 'Fotoğrafı bildir';

  @override
  String get photoshootSaveToGallery => 'Galeriye kaydet';

  @override
  String get actionUpgrade => 'Yükselt';

  @override
  String get referralLimitTitle => 'Bugünkü fotoğraflarını kullandın';

  @override
  String get referralLimitBody =>
      'Ücretsiz fotoğrafların yarın yenilenir. Bir arkadaşını davet et, ikiniz de bir ay Pro kazanın.';

  @override
  String get referralLimitRefer => 'Arkadaşını davet et';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Flört uygulaması';

  @override
  String get photoshootUsePortfolio => 'Portfolyo';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetik';

  @override
  String get photoshootUseCustom => 'Kendi tarifin';

  @override
  String get photoshootDescLinkedin => 'İş için net portreler';

  @override
  String get photoshootDescDating => 'Rahat, sıcak ve doğal';

  @override
  String get photoshootDescPortfolio => 'Editöryal, yüksek moda';

  @override
  String get photoshootDescInstagram => 'Akışın için yaşam tarzı';

  @override
  String get photoshootDescAesthetic => 'Gotik, sanatsal kareler';

  @override
  String get photoshootDescCustom => 'İstediğin görünümü tanımla';

  @override
  String get aspectSquare => 'Kare';

  @override
  String get aspectPortrait => 'Dikey';

  @override
  String get aspectLandscape => 'Yatay';

  @override
  String get aspectTall => 'Uzun';

  @override
  String get aspectWide => 'Geniş';

  @override
  String get tryOnAppBar => 'Sanal deneme';

  @override
  String get tryOnYourPhoto => 'Fotoğrafın';

  @override
  String get tryOnGarment => 'Kıyafet';

  @override
  String get tryOnUploadingPhoto => 'Fotoğrafın yükleniyor';

  @override
  String get tryOnAddPhotoPrompt => 'Boydan bir fotoğrafını ekle';

  @override
  String get tryOnBodyPhotoHint => 'Boydan bir fotoğraf en iyisidir';

  @override
  String get tryOnAddPhoto => 'Fotoğraf ekle';

  @override
  String get tryOnChangePhoto => 'Fotoğrafı değiştir';

  @override
  String get tryOnPhotoLoadFailed => 'Fotoğrafın yüklenemedi.';

  @override
  String get tryOnChooseGarment => 'Bir kıyafet fotoğrafı seç';

  @override
  String get tryOnChooseOneGarment => 'Bir kıyafet fotoğrafı seç';

  @override
  String get tryOnGarmentHint => 'Düz zemin veya askı çekimi en iyisidir';

  @override
  String get tryOnChange => 'Değiştir';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Kaldır';

  @override
  String get tryOnLookTitle => 'Görünüm';

  @override
  String get tryOnStyle => 'Tarz';

  @override
  String get tryOnBackground => 'Arka plan';

  @override
  String get tryOnPose => 'Poz';

  @override
  String get tryOnDressingUp =>
      'Giydiriliyorsun. Bu yaklaşık yarım dakika sürer.';

  @override
  String get tryOnEmptyResult => 'Kombininiz burada görünecek';

  @override
  String get tryOnReportImage => 'Görseli bildir';

  @override
  String get tryOnCreating => 'Oluşturuluyor';

  @override
  String get tryOnTryAgain => 'Tekrar dene';

  @override
  String get tryOnCreate => 'Kombin oluştur';

  @override
  String get tryOnBackgroundStudioWhite => 'Stüdyo beyazı';

  @override
  String get tryOnBackgroundStudioGrey => 'Stüdyo grisi';

  @override
  String get tryOnBackgroundUrban => 'Şehir sokağı';

  @override
  String get tryOnBackgroundNature => 'Doğa';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Öne dönük';

  @override
  String get tryOnPoseSide => 'Yana dönük';

  @override
  String get tryOnPoseWalking => 'Yürürken';

  @override
  String get dashboardGreetingMorning => 'Günaydın';

  @override
  String get dashboardGreetingAfternoon => 'İyi günler';

  @override
  String get dashboardGreetingEvening => 'İyi akşamlar';

  @override
  String get dashboardWelcome => 'Hoş geldin';

  @override
  String get dashboardOpenProfile => 'Profili aç';

  @override
  String get dashboardRailToday => 'Bugün';

  @override
  String get dashboardRailRecently => 'Son';

  @override
  String get dashboardActivityEmpty =>
      'Yeni parçalar ve kombinler burada görünür.';

  @override
  String get quickAddPiece => 'Parça ekle';

  @override
  String get quickAddPieceBody => 'Fotoğrafla ve etiketle';

  @override
  String get quickBuildOutfit => 'Kombin yap';

  @override
  String get quickBuildOutfitBody => 'Parçalarını karıştır';

  @override
  String get quickForYou => 'Sana özel';

  @override
  String get quickForYouBody => 'Bugün için seçimler';

  @override
  String get quickPlanWeek => 'Haftayı planla';

  @override
  String get quickPlanWeekBody => 'Tarihe göre kombinler';

  @override
  String get referralBannerUrgent => 'Az mı kaldı? Bir arkadaşını davet et.';

  @override
  String get referralBannerTitle => 'Bir ay ver, bir ay al.';

  @override
  String get referralBannerBody => 'Sen ve arkadaşın birer ay Pro kazanın.';

  @override
  String get referralBannerDismiss => 'Bir hafta yoksay';

  @override
  String get referralBannerShare => 'Daveti paylaş';

  @override
  String get referralBannerCopy => 'Bağlantıyı kopyala';

  @override
  String get itemEditPieceTitle => 'Parçayı düzenle';

  @override
  String get itemEditDescriptionLabel => 'Açıklama';

  @override
  String get itemEditNotSaved => 'Kaydedilmedi';

  @override
  String get itemEditSavedTitle => 'Kaydedildi';

  @override
  String get itemEditSavedBody => 'Değişiklikler kaydedildi.';

  @override
  String get itemEditSavedStalePhotos =>
      'Kaydedildi — fotoğraflar güncel olmayabilir';

  @override
  String get itemEditRemovePieceHint => 'Bu parçayı ürün sayfasından sil.';

  @override
  String get itemEditNoPhotos =>
      'Henüz fotoğraf yok. Galeriden veya kameradan ekle.';

  @override
  String get itemEditKeepPhoto => 'Fotoğrafı tut';

  @override
  String get itemEditRemoved => 'Kaldırıldı';

  @override
  String get itemEditAddUseCaseAction => 'Ekle';

  @override
  String get statsNoStatsTitle => 'Henüz istatistik yok';

  @override
  String get statsNoStatsBody =>
      'Birkaç parça ekle, gardırop dağılımın burada görünsün.';

  @override
  String get statsByCategory => 'Kategoriye göre';

  @override
  String get statsTotalValue => 'toplam değer';

  @override
  String get statsMostWorn => 'En çok giyilen';

  @override
  String get statsLeastWorn => 'Sırasını bekleyen';

  @override
  String get statsUnnamedPiece => 'İsimsiz parça';

  @override
  String get jobsTitle => 'Taramalar';

  @override
  String get jobsEmptyTitle => 'Henüz tarama yok';

  @override
  String get jobsEmptyBody =>
      'Bir parça çek ve arka plana gönder; arkada çalışmaya devam eder.';

  @override
  String get jobsNotCancelled => 'İptal edilmedi';

  @override
  String get jobsResume => 'Devam et';

  @override
  String get jobsReview => 'İncele';

  @override
  String get jobsStop => 'Durdur';

  @override
  String get jobsDismiss => 'Kapat';

  @override
  String get reportTitle => 'İçeriği bildir';

  @override
  String reportIntro(String contentType) {
    return 'Bu $contentType ile ilgili sorunun ne olduğunu bize söyle. Ekibimiz her bildirimi inceler.';
  }

  @override
  String get reportReasonInappropriate => 'Uygunsuz veya saldırgan';

  @override
  String get reportReasonNudity => 'Çıplaklık veya cinsel içerik';

  @override
  String get reportReasonHarassment => 'Taciz veya istismar';

  @override
  String get reportReasonImpersonation => 'Taklit';

  @override
  String get reportReasonOther => 'Diğer';

  @override
  String get reportDetailsLabel => 'Ek detaylar (isteğe bağlı)';

  @override
  String get reportSubmit => 'Bildirimi gönder';

  @override
  String get reportSubmittedTitle => 'Bildirim gönderildi';

  @override
  String get reportSubmittedBody =>
      'Teşekkürler. Ekibimiz bu içeriği inceleyecektir.';

  @override
  String get reportFailedTitle => 'Bildirim gönderilemedi';

  @override
  String get reportFailedBody => 'Lütfen tekrar dene.';

  @override
  String get reportContentTryOnImage => 'AI deneme görseli';

  @override
  String get reportContentSharedOutfit => 'paylaşılan kombin';

  @override
  String get reportContentPhotoshootImage => 'AI çekim görseli';

  @override
  String get sharedOutfitTitle => 'Paylaşılan kombin';

  @override
  String get sharedOutfitHideTooltip => 'Bu kombini gizle';

  @override
  String get sharedOutfitReportTooltip => 'Bu kombini bildir';

  @override
  String get sharedOutfitHideTitle => 'Bu kombin gizlensin mi?';

  @override
  String get sharedOutfitHideBody =>
      'Bu cihazda gizli kalacaktır. Ayrıca ekibimizin inceleyip kaldırması için bildirebilirsiniz.';

  @override
  String get sharedOutfitHideAction => 'Gizle';

  @override
  String get sharedOutfitHiddenInfo =>
      'Bu kombin bu cihazda bir daha gösterilmeyecek.';

  @override
  String get sharedOutfitHiddenToast => 'Kombin gizlendi';

  @override
  String get sharedOutfitMissingTitle => 'Bu kombin artık burada değil';

  @override
  String get sharedOutfitMissingBody =>
      'Kaldırılmış olabilir veya bağlantı hatalı.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Bu kombini gizlediniz';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Uygunsuz ise Gizlilik ve koşullar kısmından bildirin veya $email adresine e-posta gönderin.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Bu tarzı beğendin mi?';

  @override
  String get sharedOutfitCtaBody => 'Kendi dolabınla benzer kombinler oluştur.';

  @override
  String get sharedOutfitCtaButton => 'FitCheck AI edin';

  @override
  String get errorTitle => 'Hata';

  @override
  String get errorUnknown => 'Beklenmeyen bir hata oluştu';

  @override
  String get errorNoConnection =>
      'İnternet bağlantısı yok. Lütfen ağınızı kontrol edin.';

  @override
  String get errorTimeout =>
      'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';

  @override
  String get errorServerError =>
      'Sunucumuzda bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorBadGateway =>
      'Sunucumuz geçici olarak hizmet veremiyor. Lütfen tekrar deneyin.';

  @override
  String get errorServiceUnavailable =>
      'Servis geçici olarak kullanılamıyor. Lütfen kısa süre içinde tekrar deneyin.';

  @override
  String get errorInternalError =>
      'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  @override
  String get errorUnauthorized => 'Devam etmek için lütfen giriş yapın.';

  @override
  String get errorForbidden => 'Buna erişim izniniz yok.';

  @override
  String get errorSessionExpired =>
      'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.';

  @override
  String get errorInvalidCredentials => 'E-posta veya şifre yanlış.';

  @override
  String get errorTokenRefreshFailed =>
      'Oturumunuz yenilenemedi. Lütfen tekrar giriş yapın.';

  @override
  String get errorRequestCancelled => 'İstek iptal edildi.';

  @override
  String get errorInvalidFormat => 'Bu dosya biçimi desteklenmiyor.';

  @override
  String get errorFileTooLarge => 'Dosya boyutu çok büyük.';

  @override
  String get errorUploadFailed => 'Yükleme başarısız. Lütfen tekrar deneyin.';

  @override
  String get errorCacheCorrupted =>
      'Kaydedilen veriler hasar görmüş ve sıfırlanmıştır.';

  @override
  String get errorCacheNotFound => 'Henüz bir şey kaydedilmedi.';

  @override
  String get errorUserNotFound => 'Bu hesap bulunamadı.';

  @override
  String get errorItemNotFound => 'Bu parça artık mevcut değil.';

  @override
  String get errorOutfitNotFound => 'Bu kombin artık mevcut değil.';

  @override
  String get rewardsTitle => 'Ödüller';

  @override
  String get rewardsNoAchievementsTitle => 'Henüz başarı yok';

  @override
  String get rewardsNoAchievementsBody =>
      'İlk rozetinizi kazanmak için parça ekleyin ve kombin planlayın.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Liderlik tablosunda kimse yok';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Puan kazanmak ve burada görünmek için kombin planlayın.';

  @override
  String get legalViewPrivacyPolicy => 'Gizlilik Politikasını Görüntüle';

  @override
  String get aiConsentAgree => 'Kabul Et ve Devam Et';

  @override
  String get aiConsentNotNow => 'Şimdi Değil';

  @override
  String get imageViewerCloseTooltip => 'Resim görüntüleyiciyi kapat';

  @override
  String get updateReadyTitle => 'Güncelleme hazır';

  @override
  String get updateReadyBody =>
      'En son iyileştirmeleri uygulamak için FitCheck AI uygulamasını yeniden başlat.';

  @override
  String get permissionCameraUsage =>
      'Kıyafetlerinin ve gardırobunun fotoğraflarını çekmek için FitCheck AI kamera erişimine ihtiyaç duyar.';

  @override
  String get permissionPhotoLibraryUsage =>
      'Kıyafetlerinin ve gardırop ürünlerinin fotoğraflarını seçmek için FitCheck AI fotoğraf arşivine erişmelidir.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'Yapay zeka tarafından oluşturulan kıyafet fotoğraflarını fotoğraf arşivine kaydetmek için FitCheck AI izne ihtiyaç duyar.';

  @override
  String get wardrobeSomePhotosSkipped => 'Bazı fotoğraflar atlandı';

  @override
  String get wardrobePhotosNotAdded => 'Fotoğraflar eklenmedi';

  @override
  String get wardrobePhotoNotAdded => 'Fotoğraf eklenmedi';

  @override
  String get wardrobeNotStartedTitle => 'Başlatılmadı';

  @override
  String get wardrobeNoRoomTitle => 'Yer yok';

  @override
  String get wardrobeAddPhotosSemantic => 'Fotoğraf ekle';

  @override
  String get batchAddTileLabel => 'Ekle';

  @override
  String get batchProfileLinkLabel => 'Profil bağlantısı';

  @override
  String get wardrobeImportFromProfileTitle => 'Profilden içe aktar';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Birkaç fotoğraf ekle';

  @override
  String get wardrobeClearAction => 'Temizle';

  @override
  String get wardrobeRefreshTooltip => 'Yenile';

  @override
  String get batchNoPhotosYetTitle => 'Henüz fotoğraf yok';

  @override
  String get batchChoosePhotosAction => 'Fotoğraf seç';

  @override
  String get batchWeFindEachPieceBody =>
      'Her parçayı bulup stüdyo fotoğrafını çekiyoruz.';

  @override
  String get batchPreparingPhotosSemantic => 'Fotoğraflar hazırlanıyor';

  @override
  String get batchPhotosProcessedSemantic => 'Fotoğraflar işlendi';

  @override
  String get batchPasteProfileLinkTitle => 'Bir profil bağlantısı yapıştır';

  @override
  String get batchPasteProfileLinkBody =>
      'Herkese açık bir Instagram veya Facebook profili. Fotoğraflarını tarıyoruz ve dolabına ne gireceğini sen seçiyorsun.';

  @override
  String get batchClearLinkTooltip => 'Bağlantıyı temizle';

  @override
  String get batchStartingButton => 'Başlatılıyor';

  @override
  String get batchStartImportAction => 'İçe aktarmayı başlat';

  @override
  String get batchReviewEveryPhotoTitle => 'Her fotoğrafı sen incelersin';

  @override
  String get batchReviewEveryPhotoBody =>
      'Sen onaylamadan hiçbir şey eklenmez.';

  @override
  String get batchPrivateProfilesTitle => 'Gizli profiller';

  @override
  String get batchPrivateProfilesBody =>
      'Hesabınızı bağlayın. Instagram ayrıca kullanıcı adı ve şifre ister.';

  @override
  String get batchUseAnotherLinkAction => 'Başka bağlantı kullan';

  @override
  String get batchSignInNeededTitle => 'Giriş yapılması gerekiyor';

  @override
  String get batchEnterYourCodeTitle => 'Kodunuzu girin';

  @override
  String get batchUseUsernamePasswordAction => 'Kullanıcı adı ve şifre kullan';

  @override
  String get batchAlreadyConnectedAction => 'Tarayıcıda zaten bağlandım';

  @override
  String get batchEnterCodeAction => 'Kod gir';

  @override
  String get batchTryAnotherWayAction => 'Başka bir yol dene';

  @override
  String get batchLiveStatus => 'Canlı';

  @override
  String get batchReconnectingStatus => 'Yeniden bağlanılıyor';

  @override
  String get batchSignInToInstagramTitle => 'Instagram\'a giriş yap';

  @override
  String get batchUsernameLabel => 'Kullanıcı adı';

  @override
  String get batchCodeIfTwoStepLabel =>
      'İki adımlı doğrulama kullanıyorsanız kod';

  @override
  String get batchAuthenticatorCodeBody =>
      'Kimlik doğrulama uygulamanızdaki 6 haneli kodu kullanın. Kodlar hızlıca değişir.';

  @override
  String get batchVerifyAction => 'Doğrula';

  @override
  String get batchFindingPhotosTitle => 'Fotoğraflar bulunuyor';

  @override
  String get batchImportPausedTitle => 'İçe aktarma duraklatıldı';

  @override
  String get batchProcessingPhotosTitle => 'Fotoğraflar işleniyor';

  @override
  String get batchWaitingNextPhoto => 'Sonraki fotoğraf bekleniyor';

  @override
  String get batchCancelImportAction => 'İçe aktarmayı iptal et';

  @override
  String get batchNoPiecesInPhotoBody => 'Bu fotoğrafta parça bulunamadı.';

  @override
  String get batchEditPieceColoursLabel => 'Virgülle ayrılmış renkler';

  @override
  String get batchAddToClosetAction => 'Dolaba ekle';

  @override
  String get batchSkipPhotoAction => 'Bu fotoğrafı atla';

  @override
  String get batchImportCompleteTitle => 'İçe aktarma tamamlandı';

  @override
  String get batchImportFailedTitle => 'İçe aktarma başarısız';

  @override
  String get batchImportCancelledTitle => 'İçe aktarma iptal edildi';

  @override
  String get batchImportErrorBody => 'İçe aktarılırken bir hata oluştu.';

  @override
  String get batchNothingMoreImportedBody =>
      'Bu profilden başka bir şey içe aktarılmadı.';

  @override
  String get batchViewClosetAction => 'Dolabı gör';

  @override
  String get batchStartOverAction => 'Baştan başla';

  @override
  String get wardrobeAddPieceTitle => 'Parça ekle';

  @override
  String get wardrobeAddDetailsTitle => 'Detay ekle';

  @override
  String get wardrobeScanningTitle => 'Taranıyor';

  @override
  String get batchReviewPiecesTitle => 'Parçaları incele';

  @override
  String get wardrobeGalleryAction => 'Galeri';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Yeni';

  @override
  String get wardrobeRemovePhotoTooltip => 'Fotoğrafı kaldır';

  @override
  String get batchRunInBackgroundTooltip => 'Arka planda çalıştır';

  @override
  String get batchStepOneOfTwo => '1 / 2. Adım';

  @override
  String get batchStepTwoOfTwo => '2 / 2. Adım';

  @override
  String get batchUploadingPhotosTitle => 'Fotoğraflar yükleniyor';

  @override
  String get batchFindingPiecesTitle => 'Parçalar bulunuyor';

  @override
  String get batchMakingStudioPhotosTitle => 'Stüdyo fotoğrafları yapılıyor';

  @override
  String get batchStoppedLabel => 'Durduruldu';

  @override
  String get batchFindingPiecesStoppedTitle => 'Parça bulma durduruldu';

  @override
  String get batchCancelledLabel => 'İptal edildi';

  @override
  String get batchAllDoneTitle => 'Tamamlandı';

  @override
  String get batchOpeningPiecesBody => 'Parçalarınız açılıyor';

  @override
  String get batchNothingSavedBody => 'Hiçbir şey kaydedilmedi.';

  @override
  String get batchFindingPiecesFailedBody => 'Parçalar bulunamadı.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Parça bulma erken durduruldu.';

  @override
  String get batchStopFindingPiecesTitle => 'Parça bulma durdurulsun mu?';

  @override
  String get batchStopFindingPiecesBody =>
      'Tarama durur ve hiçbir şey kaydedilmez. Bulunan parçalar siz kapatana kadar etkinliğinizde kalır.';

  @override
  String get batchKeepGoingAction => 'Devam et';

  @override
  String get batchTryAgainAction => 'Tekrar dene';

  @override
  String get batchBackToPhotosAction => 'Fotoğraflara dön';

  @override
  String get batchSkipAllAction => 'Tümünü atla';

  @override
  String get batchIncludeAllAction => 'Tümünü dahil et';

  @override
  String get batchNoPiecesFoundTitle => 'Parça bulunamadı';

  @override
  String get batchNoPiecesFoundBody =>
      'Bu fotoğraflarda hiç kıyafet bulamadık.';

  @override
  String get batchChooseOtherPhotosAction => 'Başka fotoğraf seç';

  @override
  String get batchUseCaseHelper => 'Kaydettiğiniz her parçaya eklenir.';

  @override
  String get batchDiscardPiecesTitle => 'Bu parçalar atılsın mı?';

  @override
  String get batchDiscardPiecesBody => 'Bu gruptan hiçbir şey kaydedilmedi.';

  @override
  String get batchKeepAction => 'Sakla';

  @override
  String get batchDiscardAction => 'At';

  @override
  String get batchRemovePieceTitle => 'Bu parça kaldırrılsın mı?';

  @override
  String get batchRemovePieceBody => 'Dolabınıza kaydedilmedi.';

  @override
  String get batchRemoveAction => 'Kaldır';

  @override
  String get batchChoosePiecesToSave => 'Kaydedilecek parçaları seçin';

  @override
  String get batchDiscardAllAction => 'Tümünü at';

  @override
  String get batchNothingSavedRetryBody =>
      'Hiçbir şey kaydedilmedi. Tekrar deneyin.';

  @override
  String get batchNotSavedTitle => 'Kaydedilmedi';

  @override
  String get batchSavingLabel => 'Kaydediliyor';

  @override
  String get batchSendToBackgroundAction => 'Arka plana gönder';

  @override
  String get batchStillWorkingMessage =>
      'Hâlâ çalışıyoruz. Parçalarınız hazır olduğunda size haber vereceğiz.';

  @override
  String get batchRunningInBackgroundTitle => 'Arka planda çalışıyor';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Stüdyo fotoğrafları erken durduruldu. Bu parçaları yine de kaydedebilirsiniz.';

  @override
  String get batchTapPieceToSkip => 'Atlamak için bir parçaya dokunun.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Stüdyo fotoğrafları hazırlanıyor. Ayrılabilirsiniz, bittiğinde haber vereceğiz.';

  @override
  String get batchLeaveAction => 'Ayrıl';

  @override
  String get batchPeopleInPhotosTitle => 'Fotoğraflardaki kişiler';

  @override
  String get batchIncludeAction => 'Dahil et';

  @override
  String get batchSkipAction => 'Atla';

  @override
  String get batchYourPhotoIsUsedLabel => 'Fotoğrafınız kullanılıyor';

  @override
  String get batchMakingStudioPhotoLabel => 'Stüdyo fotoğrafı oluşturuluyor';

  @override
  String get batchNoStudioPhotoBody =>
      'Stüdyo fotoğrafı yok. Fotoğrafınız kullanılıyor.';

  @override
  String get batchEnterDetailsYourselfAction => 'Detayları kendin gir';

  @override
  String get batchChooseAnotherPhotoAction => 'Başka bir fotoğraf seç';

  @override
  String get batchConnectionLostTitle => 'Bağlantı koptu';

  @override
  String get batchConnectionLostBody => 'Bağlantını kontrol edip tekrar dene.';

  @override
  String get batchDailyLimitTitle => 'Günlük limite ulaşıldı';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Daha fazla tarama için Pro sürümüne geç veya detayları kendin gir.';

  @override
  String get batchDailyLimitBodyFree =>
      'Taramaların yarın sıfırlanacak. Şimdi detayları kendin girebilirsin.';

  @override
  String get batchSeePlansAction => 'Planları gör';

  @override
  String get batchAiBusyTitle => 'Yapay zekamız şu an yoğun';

  @override
  String get batchAiBusyBody =>
      'Bu bizim tarafımızdan kaynaklanıyor. Birkaç dakika sonra tekrar dene.';

  @override
  String get batchNoPiecesBody =>
      'Daha net bir fotoğraf dene veya detayları kendin gir.';

  @override
  String get batchScanningUnavailableTitle => 'Tarama kullanılamıyor';

  @override
  String get batchScanningUnavailableBody => 'Şimdilik detayları kendin gir.';

  @override
  String get batchScanDidNotFinishTitle => 'Tarama tamamlanamadı';

  @override
  String get batchTryAgainBody => 'Tekrar dene.';

  @override
  String get billingTitle => 'Abonelik';

  @override
  String get billingUpgradeHeading => 'Planını yükselt';

  @override
  String get billingUpgradeOnPlusBody =>
      'Aynı özellikler, daha yüksek limitler.';

  @override
  String get billingUpgradeBody =>
      'Plus ve Pro aynı özelliklere sahiptir. İhtiyacın olan limitleri seç.';

  @override
  String get billingWebUnavailableBody =>
      'İnternet üzerinden yükseltme henüz yapılamıyor. Bir promosyon veya referans kodu Plus veya Pro kilidini açar. Ücretsiz ay kazanmak için aşağıdaki arkadaşlarınızı davet edin.';

  @override
  String get billingPlansStale =>
      'En son planlar yüklenemedi. Fiyatlar güncel olmayabilir.';

  @override
  String get billingMonthly => 'Aylık';

  @override
  String get billingYearly => 'Yıllık';

  @override
  String get billingCurrentPlan => 'Mevcut plan';

  @override
  String get billingActive => 'Aktif';

  @override
  String get billingThisMonth => 'Bu ay';

  @override
  String get billingItemExtractions => 'Parça çıkarımları';

  @override
  String get billingOutfitVisualizations => 'Kombin görselleştirmeleri';

  @override
  String get billingNearLimitUpgrade =>
      'Bu ayki limite yaklaştın. Daha fazlası için yükselt.';

  @override
  String get billingNearLimitResets =>
      'Bu ayki limite yaklaştın. Gelecek ayın başında sıfırlanacak.';

  @override
  String get billingStoreUnavailable =>
      'Yükseltmeler mağazada henüz kullanılamıyor. Yakında tekrar kontrol edin.';

  @override
  String get billingManageHeading => 'Planınızı yönetin';

  @override
  String get billingCancelPlan => 'Aboneliği iptal et';

  @override
  String get billingCancelKeepsAccess =>
      'Bu faturalandırma dönemi sonuna kadar erişmeye devam edersiniz.';

  @override
  String get billingCancelConfirmTitle => 'Aboneliğinizi iptal edilsin mi?';

  @override
  String get billingKeepPlan => 'Planı koru';

  @override
  String get billingCancelPlanAction => 'Planı iptal et';

  @override
  String get billingBilledMonthly => 'Aylık faturalandırılır';

  @override
  String get billingBilledYearly => 'Yıllık faturalandırılır';

  @override
  String get billingVirtualTryOn => 'Sanal deneme';

  @override
  String get billingPrioritySupport => 'Öncelikli destek';

  @override
  String get billingDisclosureProRenewing =>
      'Pro otomatik yenilenen bir aboneliktir';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus ve Pro otomatik yenilenen aboneliklerdir';

  @override
  String get billingDisclosureAppleBilling =>
      'Ödeme, satın alma onayının ardından Apple ID hesabınızdan tahsil edilir.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Ödeme, satın alma onayının ardından Google Play hesabınızdan tahsil edilir.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Mevcut dönem bitiminden en az 24 saat önce otomatik yenilemeyi kapatmadığınız sürece aboneliğiniz aynı süre ve fiyatta otomatik olarak yenilenir.';

  @override
  String get billingDisclosureAppleManage =>
      'Ayarlar › Apple ID › Abonelikler bölümünden istediğiniz zaman yönetebilir veya iptal edebilirsiniz.';

  @override
  String get billingDisclosureGoogleManage =>
      'Google Play › Ödemeler ve abonelikler bölümünden istediğiniz zaman yönetebilir veya iptal edebilirsiniz.';

  @override
  String get billingReferFriend => 'Bir arkadaşını davet et';

  @override
  String get billingHowItWorks => 'Nasıl çalışır';

  @override
  String get billingHowShareTitle => 'Bağlantınızı paylaşın';

  @override
  String get billingHowShareBody => 'Bir arkadaşınıza gönderin.';

  @override
  String get billingHowSignUpTitle => 'Kayıt olsunlar';

  @override
  String get billingHowSignUpBody => 'Arkadaşınız bağlantı üzerinden katılsın.';

  @override
  String get billingHowBothTitle => 'İkiniz de Pro kazanın';

  @override
  String get billingHowBothBody => 'İkiniz de bir ay ücretsiz Pro kazanın.';

  @override
  String get billingYourReferrals => 'Davetleriniz';

  @override
  String get billingInvited => 'Davet edilen';

  @override
  String get billingJoined => 'Katılan';

  @override
  String get billingMonthsEarned => 'Kazanılan aylar';

  @override
  String get billingInviteFriend => 'Arkadaşını davet et';

  @override
  String get billingInviteBody => 'Sen ve arkadaşınız birer ay Pro kazanın.';

  @override
  String get billingYourCode => 'Kodun';

  @override
  String get billingCopyLink => 'Bağlantıyı kopyala';

  @override
  String get billingShareInvite => 'Davet paylaş';

  @override
  String get giftUnavailable => 'Bu sürümde hediye davetler kullanılamıyor.';

  @override
  String get giftPageTitle => 'FitCheck Pro Hediye Et';

  @override
  String get giftNoAllowances =>
      'Şu anda ücretsiz hediye davet hakkı bulunmuyor.';

  @override
  String get giftFormTitle => 'Ücretsiz davet gönder';

  @override
  String get giftFormBody =>
      'Alıcı, bu onaylanmış e-posta ile hediyeyi alır. E-postayı senin adına biz göndermeyiz.';

  @override
  String get giftFieldFrom => 'Gönderen';

  @override
  String get giftFieldRecipientName => 'Alıcının adı';

  @override
  String get giftFieldRecipientEmail => 'Alıcının e-postası';

  @override
  String get giftFieldOccasion => 'Özel gün (isteğe bağlı)';

  @override
  String get giftNoOccasion => 'Özel gün yok';

  @override
  String get giftOccasionBirthday => 'Doğum günü';

  @override
  String get giftOccasionAnniversary => 'Yıldönümü';

  @override
  String get giftOccasionOther => 'Diğer';

  @override
  String get giftFieldCardGreeting => 'Kart mesajı';

  @override
  String get giftFieldCardGreetingHelper =>
      'Bu, kartta yazıldığı gibi görünür.';

  @override
  String get giftFieldPrivateNote => 'Özel not (isteğe bağlı)';

  @override
  String get giftCreateAction => 'Ücretsiz hediye oluştur';

  @override
  String get giftClaimedTitle => 'Hediye alındı';

  @override
  String get giftClaimedActive => 'FitCheck Pro hediyen etkin.';

  @override
  String get giftClaimedQueued =>
      'FitCheck Pro hediyen mevcut süren bitince başlar.';

  @override
  String get giftLinkCopied => 'Hediye bağlantısı panoya kopyalandı.';

  @override
  String get giftErrorName => 'Bir ad gir.';

  @override
  String get giftErrorEmail => 'Geçerli bir e-posta adresi gir.';

  @override
  String get giftErrorGreeting => 'Kart mesajını gir.';

  @override
  String get giftErrorGreetingLength => 'En fazla 80 karakter kullan.';

  @override
  String get giftClaimAction => 'Hediyeyi al';

  @override
  String get giftCardPreview => 'Kart önizleme';

  @override
  String get giftGiftForYou => 'Sana bir hediye';

  @override
  String get giftGiftWaiting => 'Seni bekleyen bir hediye var';

  @override
  String get giftOpenBody => 'Doğrulanmış e-postanla hediyelerini aç ve al.';

  @override
  String get giftOpenGifts => 'Hediyeleri aç';

  @override
  String get giftSendInvitation => 'Davet gönder';

  @override
  String get settingsAiProviderSection => 'Sağlayıcı';

  @override
  String get settingsAiCustom => 'Özel';

  @override
  String get settingsAiUrlHelper =>
      'Sunucunun erişebileceği genel bir URL kullanın. Yerel sunucu (localhost) çalışmaz.';

  @override
  String get settingsAiConnectionSection => 'Bağlantı';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API anahtarı';

  @override
  String get settingsAiApiKeySaved => 'Kaydedildi. Korumak için boş bırakın.';

  @override
  String get settingsAiChatModel => 'Sohbet modeli';

  @override
  String get settingsAiVisionModel => 'Görsel modeli (isteğe bağlı)';

  @override
  String get settingsAiImageModel => 'Görsel modeli (isteğe bağlı)';

  @override
  String get settingsAiImageModelNote =>
      'Görsel oluşturma, response_modalities içeren OpenAI uyumlu sohbet tamamlama özellikleri gerektirir.';

  @override
  String get settingsAiTestConnection => 'Bağlantıyı test et';

  @override
  String get calendarTitle => 'Takvim';

  @override
  String get calendarGoToToday => 'Bugüne git';

  @override
  String get calendarConnectTooltip => 'Takvim bağla';

  @override
  String get calendarAddEvent => 'Etkinlik ekle';

  @override
  String get calendarEmptyTitle => 'Plan yok';

  @override
  String get calendarEmptyBody => 'Bir etkinlik ekle ve ne giyeceğini planla.';

  @override
  String get calendarPreviousMonth => 'Önceki ay';

  @override
  String get calendarNextMonth => 'Sonraki ay';

  @override
  String get calendarAllDay => 'Tüm gün';

  @override
  String get calendarOutfitLinked => 'Kombin bağlandı';

  @override
  String get calendarEventOptions => 'Etkinlik seçenekleri';

  @override
  String get calendarDeleteTitle => 'Bu etkinlik silinsin mi?';

  @override
  String get calendarChangeOutfit => 'Kombini değiştir';

  @override
  String get calendarLinkOutfit => 'Kombin bağla';

  @override
  String get calendarRemoveOutfit => 'Kombini kaldır';

  @override
  String get calendarNewEvent => 'Yeni etkinlik';

  @override
  String get calendarEditEvent => 'Etkinliği düzenle';

  @override
  String get calendarTitleLabel => 'Başlık';

  @override
  String get calendarTitleRequired => 'Bir başlık ekle';

  @override
  String get calendarEndBeforeStart => 'Bitiş başlangıçtan sonra olmalı';

  @override
  String get calendarStarts => 'Başlangıç';

  @override
  String get calendarEnds => 'Bitiş';

  @override
  String get calendarPlaceOptional => 'Yer (isteğe bağlı)';

  @override
  String get calendarNotesOptional => 'Notlar (isteğe bağlı)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Önce bir kombin oluştur, ardından bu etkinliğe bağla.';

  @override
  String get calendarBuildOutfit => 'Kombin oluştur';

  @override
  String get calendarConnectionsTitle => 'Takvimler';

  @override
  String get calendarConnectionsBody =>
      'Buraya eklediğin etkinlikler FitCheck içinde kalır.';

  @override
  String get calendarDisconnect => 'Bağlantıyı kes';

  @override
  String get calendarNotAvailable => 'Henüz kullanılmıyor';

  @override
  String get profileSectionExplore => 'Keşfet';

  @override
  String get profileNavTryOn => 'Dene';

  @override
  String get profileNavRewards => 'Ödüller';

  @override
  String get profileSupport => 'Destek';

  @override
  String get profileHelp => 'Yardım';

  @override
  String get profileAbout => 'Hakkında';

  @override
  String get profileAboutBody => 'Dolabın, kombinlerin ve planların tek yerde.';

  @override
  String get profileSignOutTitle => 'Çıkış yapılsın mı?';

  @override
  String get profileSignOutBody => 'İstediğin zaman tekrar giriş yapabilirsin.';

  @override
  String get profileEditTitle => 'Profili düzenle';

  @override
  String get profileYourProfile => 'Profilin';

  @override
  String get profileBodyProfiles => 'Vücut profilleri';

  @override
  String get profileBodyEmptyTitle => 'Henüz vücut profili yok';

  @override
  String get profileBodyEmptyBody =>
      'Daha iyi bir kalıp için boyunu ve vücut tipini ekle.';

  @override
  String get profileBodyAdd => 'Profil ekle';

  @override
  String get profileBodyDefaultNote =>
      'Varsayılan profilin beden ve deneme için kullanılır.';

  @override
  String get profileBodyDefaultBadge => 'Varsayılan';

  @override
  String get profileBodyMakeDefault => 'Varsayılan yap';

  @override
  String get profileBodyDeleteBody => 'Bu işlem geri alınamaz.';

  @override
  String get profileBodyRequired => 'Zorunlu';

  @override
  String get profileBodyCheckNumber => 'Bu sayıyı kontrol et';

  @override
  String get profileBodyNew => 'Yeni vücut profili';

  @override
  String get profileBodyNameHint => 'Örneğin, Ben';

  @override
  String get profileBodyHeight => 'Boy';

  @override
  String get profileBodyWeight => 'Kilo';

  @override
  String get profileBodyBuild => 'Vücut tipi';

  @override
  String get profileBodySkinTone => 'Ten rengi';

  @override
  String get profileBirthDateNeededBody =>
      'Doğum saatiyle birlikte doğum tarihi de ekle.';

  @override
  String get profileBirthDateNeededTitle => 'Doğum tarihi gerekli';

  @override
  String get profilePartlySavedBody =>
      'Adın ve fotoğrafın kaydedildi. Doğum bilgileri kaydedilemedi; daha sonra tekrar dene.';

  @override
  String get profilePartlySavedTitle => 'Kısmen kaydedildi';

  @override
  String get profileSavedBody => 'Profilin kaydedildi.';

  @override
  String get profileChangePhoto => 'Profil fotoğrafını değiştir';

  @override
  String get profilePhotoLabel => 'Profil fotoğrafı';

  @override
  String get profilePhotoHint => 'Yeni bir tane seçmek için dokun';

  @override
  String get profileBirthDateLabel => 'Doğum tarihi (isteğe bağlı)';

  @override
  String get profileBirthTimeLabel => 'Doğum saati (isteğe bağlı)';

  @override
  String get profileBirthTimeHelper =>
      'Vedik önerileri daha kesin hale getirir';

  @override
  String get profileBirthPlaceLabel => 'Doğum yeri (isteğe bağlı)';

  @override
  String get profileBirthPlaceHint => 'Örneğin, İstanbul, Türkiye';

  @override
  String get profileHelpContactTitle => 'Bize her şeyi sor';

  @override
  String get profileHelpContactBody =>
      'Bir mesaj gönderin, genellikle bir gün içinde e-posta ile yanıt verelim.';

  @override
  String get profileHelpContactAction => 'Destek ekibiyle iletişime geçin';

  @override
  String get profileHelpFaqTitle => 'Sık sorulan sorular';

  @override
  String get profileFaqAddPiecesTitle => 'Gardırobuma nasıl parça eklerim?';

  @override
  String get profileFaqAddPiecesBody =>
      'Gardırop sekmesinde Öğe ekle\'ye dokunun. Fotoğraf çekin veya galerinizden seçin; her parçayı bulup sizin için etiketleyelim.';

  @override
  String get profileFaqMatchingTitle => 'Kombin eşleştirme nasıl çalışır?';

  @override
  String get profileFaqMatchingBody =>
      'Sizin için\'i açın ve sahip olduğunuz parçaları seçin. Bunlarla neyin uyumlu olacağını önerip gardırobunuzdan tam kombinler oluşturalım.';

  @override
  String get profileFaqTryOnTitle =>
      'Deneme için kendi fotoğraflarımı kullanabilir miyim?';

  @override
  String get profileFaqTryOnBody =>
      'Evet. Boydan bir fotoğraflğinizi ekleyin, ardından parçaları seçerek üzerinizde görün.';

  @override
  String get profileFaqRewardsTitle => 'Nasıl ödül kazanırım?';

  @override
  String get profileFaqRewardsBody =>
      'Düzenli olarak kombin planlayın ve kaydedin. Siz ilerledikçe seriler ve başarılar birikir.';

  @override
  String get profileFaqPrivacyTitle => 'Gardırobum gizli mi?';

  @override
  String get profileFaqPrivacyBody =>
      'Evet. Tek bir kombin bağlantısı paylaşmadığınız sürece gardırobunuz ve kombinleriniz gizlidir.';

  @override
  String get profileHelpMoreTitle => 'Daha fazla yardım';

  @override
  String get profileHelpGuides => 'Kılavuzlar';

  @override
  String get profileHelpGuidesBody => 'Her özelliğin çalışma şekli';

  @override
  String get feedbackCategoryBug => 'Bir hata oluştu';

  @override
  String get feedbackCategoryIdea => 'Bir fikir';

  @override
  String get feedbackCategoryGeneral => 'Genel';

  @override
  String get feedbackCategoryHelp => 'Yardıma ihtiyacım var';

  @override
  String get feedbackHintBug =>
      'Ne oldu ve ne bekliyordunuz? Adımlar sorunu çözmemize yardımcı olur.';

  @override
  String get feedbackHintIdea => 'Ne istersiniz ve neden?';

  @override
  String get feedbackHintGeneral =>
      'Düşüncelerinizi paylaşın veya bir soru sorun.';

  @override
  String get feedbackAttachmentLimitBody =>
      'En fazla 5 görsel ekleyebilirsiniz.';

  @override
  String get feedbackAttachmentLimitTitle => 'Sınıra ulaşıldı';

  @override
  String get feedbackImageTooLargeBody => '5 MB\'tan küçük bir görsel seçin.';

  @override
  String get feedbackImageTooLargeTitle => 'Görsel çok büyük';

  @override
  String get feedbackTitle => 'Geri bildirim gönder';

  @override
  String get feedbackAboutLabel => 'Ne hakkında?';

  @override
  String get feedbackSubjectLabel => 'Konu';

  @override
  String get feedbackSubjectRequired => 'Bir konu ekle';

  @override
  String get feedbackSubjectTooShort => 'Konu en az 3 karakter olmalı';

  @override
  String get feedbackDetailsLabel => 'Detaylar';

  @override
  String get feedbackDetailsRequired => 'Birkaç detay ekle';

  @override
  String get feedbackDetailsTooShort => 'Açıklama en az 10 karakter olmalı';

  @override
  String get feedbackAddScreenshot => 'Ekran görüntüsü ekle';

  @override
  String get feedbackAttachmentHint => 'En fazla 5, her biri en fazla 5 MB';

  @override
  String get feedbackSend => 'Gönder';

  @override
  String get feedbackEmptyTitle => 'Henüz bir şey gönderilmedi';

  @override
  String get feedbackEmptyBody =>
      'Gönderdiklerin durumlarıyla birlikte burada görünür.';

  @override
  String get feedbackHistoryTitle => 'Gönderdiklerin';

  @override
  String get feedbackStatusOpen => 'Açık';

  @override
  String get feedbackStatusInProgress => 'Devam ediyor';

  @override
  String get feedbackStatusResolved => 'Çözüldü';

  @override
  String get feedbackStatusClosed => 'Kapalı';

  @override
  String get legalIntro =>
      'Verilerinizi nasıl koruduğumuz ve FitCheck AI kullanım koşulları.';

  @override
  String get legalPolicies => 'Politikalar';

  @override
  String get legalPrivacySubtitle => 'Ne topluyoruz ve neden';

  @override
  String get legalTermsTitle => 'Kullanım koşulları';

  @override
  String get legalTermsSubtitle => 'Uygulamayı kullanım kuralları';

  @override
  String get legalLicences => 'Açık kaynak lisansları';

  @override
  String get legalSupportSubtitle => 'Yardım, iletişim ve gizlilik talepleri';

  @override
  String get legalReportAbuse => 'Sorun veya suiistimal bildir';

  @override
  String get permissionCameraTitle => 'Kamera Erişimi';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI, yapay zeka ile kıyafet deneme ve gardırop düzenleme için kıyafetlerinin fotoğraflarını çekmek üzere kameranı kullanır.';

  @override
  String get permissionPhotoTitle => 'Fotoğraf Erişimi';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI, yapay zeka özellikleri ve gardırobun için kıyafet görselleri seçebilmen amacıyla fotoğraflarına erişime ihtiyaç duyar.';

  @override
  String get permissionNotNow => 'Şimdi Değil';

  @override
  String get permissionOpenSettings => 'Ayarları Aç';

  @override
  String authSignedInAs(String name) {
    return '$name olarak giriş yapıldı';
  }

  @override
  String get authSignedIn => 'Oturum açıldı';

  @override
  String get authWelcomeBackTitle => 'Tekrar hoş geldiniz';

  @override
  String get authSignInFailed => 'Oturum açılamadı';

  @override
  String get authWelcomeTitle => 'Hoş geldiniz';

  @override
  String get authSignUpFailed => 'Kayıt olunamadı';

  @override
  String get authGoogleSignInFailed => 'Google ile oturum açma başarısız';

  @override
  String get authAppleSignInFailed => 'Apple ile oturum açma başarısız';

  @override
  String get authConfirmEmailTitle => 'E-postanızı doğrulayın';

  @override
  String get authConfirmEmailBody =>
      'Doğrulama e-postası için gelen kutunuzu kontrol edin, ardından oturum açın.';

  @override
  String get authClosetReady => 'Gardrobunuz hazır.';

  @override
  String get authSignedOutTitle => 'Oturum kapatıldı';

  @override
  String get authSignedOutBody => 'Oturumunuz kapatıldı.';

  @override
  String get authSignOutFailed => 'Oturum kapatılamadı';

  @override
  String get authEmailSentTitle => 'E-posta gönderildi';

  @override
  String get authResetLinkSent =>
      'Sıfırlama bağlantısı için e-postanızı kontrol edin.';

  @override
  String get authPasswordUpdatedTitle => 'Şifre güncellendi';

  @override
  String get authPasswordUpdated => 'Şifreniz güncellendi.';

  @override
  String get authPasswordNotUpdated => 'Şifre güncellenemedi';

  @override
  String get authCouldNotSendEmail => 'E-posta gönderilemedi';

  @override
  String get authEmailNotSent => 'E-posta gönderilmedi';

  @override
  String get authResendSentBody => 'Yeni bir doğrulama e-postası gönderdik.';

  @override
  String get outfitPreviewWithAi => 'AI ile önizle';

  @override
  String get outfitNewPreview => 'Yeni önizleme oluştur';

  @override
  String get outfitBuilderClosetHeading => 'Dolabın';

  @override
  String get outfitBuilderSearchHint => 'Parça ara';

  @override
  String get outfitClearSearch => 'Aramayı temizle';

  @override
  String get outfitBuilderAddPiecesTitle => 'Önce parçaları ekle';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Kıyafetler, dolabındaki parçalardan oluşturulur.';

  @override
  String get outfitBuilderNoMatches => 'Eşleşen parça yok.';

  @override
  String get outfitNameLabel => 'Kıyafet adı';

  @override
  String get outfitNameHint => 'Örneğin, Hafta Sonu Keten';

  @override
  String get outfitPreviewSemantic => 'Kıyafetin AI önizlemesi';

  @override
  String get outfitChoosePieces => 'Parça seç';

  @override
  String get outfitTapPiecesHint => 'Eklemek için alttaki parçalara dokun.';

  @override
  String get outfitShareTooltip => 'Paylaş';

  @override
  String get outfitSaveFavourite => 'Favorilere ekle';

  @override
  String get outfitPiecesHeading => 'Parçalar';

  @override
  String get outfitWearHistoryEmpty =>
      'Bir kez giyince tarihler burada görünür.';

  @override
  String get outfitWearHistoryTitle => 'Giyim geçmişi';

  @override
  String get outfitWearHistoryError => 'Tarihler yüklenemedi.';

  @override
  String get outfitWornOn => 'Giyim tarihi';

  @override
  String get outfitEditTitle => 'Kıyafeti düzenle';

  @override
  String get outfitSavedPhotosFailed =>
      'Detaylar kaydedildi, fotoğraflar kaydedilmedi';

  @override
  String get outfitNoPhotosBody =>
      'Henüz fotoğraf yok. Kıyafet parçalarını gösterir.';

  @override
  String get outfitOccasionLabel => 'Olası';

  @override
  String get outfitOccasionNone => 'Yok';

  @override
  String get outfitTagsHint => 'Virgülle ayır';

  @override
  String get outfitDraftBody => 'Ana listeden gizli';

  @override
  String get outfitPublic => 'Herkese açık';

  @override
  String get outfitPublicBody => 'Bağlantıya sahip herkes görebilir';

  @override
  String get outfitDeleteFromDetail => 'Bu kıyafeti detay sayfasından sil.';

  @override
  String get outfitNewCollection => 'Yeni koleksiyon';

  @override
  String get outfitNoCollectionsTitle => 'Henüz koleksiyon yok';

  @override
  String get outfitNoCollectionsBody =>
      'Kıyafetleri seyahat, mevsim veya ruh halinize göre gruplandırın.';

  @override
  String get outfitCreateCollection => 'Koleksiyon oluştur';

  @override
  String get outfitAddOutfits => 'Kıyafet ekle';

  @override
  String get outfitRename => 'Yeniden adlandır';

  @override
  String get outfitCollectionDeleteBody => 'İçindeki kıyafetler korunur.';

  @override
  String get outfitCollectionsNotLoaded => 'Kıyafetler yüklenemedi';

  @override
  String get outfitRenameCollection => 'Koleksiyonu yeniden adlandır';

  @override
  String get outfitDescriptionOptional => 'Açıklama (isteğe bağlı)';

  @override
  String get outfitAllInCollection => 'Tüm kıyafetler zaten bu koleksiyonda.';

  @override
  String get photoshootSubtitleUpload =>
      'Kendi fotoğraflarınızdan stüdyo portreleri';

  @override
  String get photoshootSubtitleConfigure => 'Stil, format ve sayı seçin';

  @override
  String get photoshootSubtitleGenerating => 'Bu bir iki dakika sürüyor';

  @override
  String get photoshootAddPhotosSemantic => 'Galerinizden fotoğraf ekle';

  @override
  String get photoshootUploadTitle => 'Kendinize ait 1 ile 4 fotoğraf ekleyin';

  @override
  String get photoshootUploadBody => 'Galerinizden seçmek için dokunun';

  @override
  String get photoshootAddToContinue => 'Devam etmek için fotoğraf ekleyin';

  @override
  String get photoshootAddAnotherPhoto => 'Başka bir fotoğraf ekle';

  @override
  String get photoshootTipsTitle => 'En iyi sonuçlar için';

  @override
  String get photoshootTipsBody =>
      'Yüzünüzün birkaç açıdan, net ve iyi ışıklı fotoğraflarını kullanın. Güneş gözlüğü ve şapka kullanmayın.';

  @override
  String get photoshootStarting => 'Başlatılıyor';

  @override
  String get photoshootCancelling => 'İptal ediliyor';

  @override
  String get photoshootFailed => 'Başarısız';

  @override
  String get recommendTabMatches => 'Eşleşenler';

  @override
  String get recommendTabComplete => 'Tamamlayanlar';

  @override
  String get recommendTabWeather => 'Hava';

  @override
  String get recommendTabColours => 'Renkler';

  @override
  String get recommendTabShop => 'Alışveriş';

  @override
  String get recommendNoMatchesTitle => 'Henüz eşleşme yok';

  @override
  String get recommendNoMatchesBody =>
      'Bir parça seçin, onunla uyanları bulalım.';

  @override
  String get recommendPickPiece => 'Parça seç';

  @override
  String get recommendNothingMatchesTitle => 'Bunlara henüz uyumlu yok';

  @override
  String get recommendNothingMatchesBody =>
      'Diğer parçaları dene veya gardırobuna ekle.';

  @override
  String get recommendChangePieces => 'Parçaları değiştir';

  @override
  String get recommendDefaultReason => 'Seçtiğin parçalara uyuyor.';

  @override
  String get recommendCompleteTitle => 'Görünümü tamamla';

  @override
  String get recommendCompleteBody =>
      'Bir parça seç, gerisini biz tamamlayalım.';

  @override
  String get recommendWorking => 'İşleniyor';

  @override
  String get recommendGenerate => 'Oluştur';

  @override
  String get recommendChooseStyleBody => 'Stil seç, sonra oluştur.';

  @override
  String get recommendNoLooksTitle => 'Bu parçalar için görünüm yok';

  @override
  String get recommendNoLooksBody => 'Farklı bir stil veya parça dene.';

  @override
  String get recommendDefaultLook => 'Parçaların için bir görünüm';

  @override
  String get recommendNoPiecesBody => 'Bu görünüm için parça bulunamadı.';

  @override
  String get recommendCityLabel => 'Şehir';

  @override
  String get recommendCheck => 'Kontrol et';

  @override
  String get recommendWeatherTitle => 'Hava nasıl?';

  @override
  String get recommendWeatherBody =>
      'Bugün için öneriler almak için şehri gir.';

  @override
  String get recommendWearToday => 'Bugün giy';

  @override
  String get recommendWeatherNoPieces =>
      'Bu hava için gardırobunda henüz parça yok.';

  @override
  String get recommendBudgetLabel => 'Bütçe en fazla';

  @override
  String get recommendLooking => 'Aranıyor';

  @override
  String get recommendFindWhatToBuy => 'Alınacakları bul';

  @override
  String get recommendFillGapsTitle => 'Eksikleri tamamla';

  @override
  String get recommendFillGapsBody =>
      'Bütçe belirle, gardırobunda nelerin eksik olduğunu önerelim.';

  @override
  String get recommendNoGapsTitle => 'Eksik bulunamadı';

  @override
  String get recommendNoGapsBody =>
      'Daha yüksek bütçe veya başka kategori dene.';

  @override
  String get recommendMoodEveryday => 'Günlük';

  @override
  String get recommendMoodBigMeeting => 'Önemli toplantı';

  @override
  String get recommendDayLabel => 'Gün';

  @override
  String get recommendReadingStars => 'Yıldızları okuyor';

  @override
  String get recommendGetMyColours => 'Renklerimi keşfet';

  @override
  String get recommendLuckyColoursTitle => 'Şanslı renklerin';

  @override
  String get recommendLuckyColoursBody =>
      'Bir gün seç, o güne uygun renkler ve parçalar önerelim.';

  @override
  String get recommendLuckyColoursSection => 'Şanslı renkler';

  @override
  String get recommendAvoidColoursSection => 'Dikkatli kullan';

  @override
  String get recommendBirthDateTitle => 'Doğum tarihini ekle';

  @override
  String get recommendBirthDateBody =>
      'Renklerini okumak için doğum tarihine ihtiyacımız var.';

  @override
  String get recommendEditProfile => 'Profili düzenle';

  @override
  String get recommendNothingThisDay => 'Bu gün için öneri yok.';

  @override
  String get recommendUnnamedColour => 'İsimsiz renk';

  @override
  String get recommendFromCloset => 'Dolabından';

  @override
  String get recommendNoPiecesInColours => 'Bu renklerde henüz parça yok.';

  @override
  String get recommendOutfitIdeas => 'Kıyafet önerileri';

  @override
  String get recommendNoOutfitsInColours =>
      'Bu renklerde henüz tam bir kombin yok.';

  @override
  String get recommendDefaultOutfitIdea => 'Bir kombin önerisi';

  @override
  String get recommendPickUpToThree => 'En fazla üç parça seç';

  @override
  String get recommendEmptyClosetBody =>
      'Önce birkaç parça ekle, sonra eşleşmeler için geri dön.';

  @override
  String get dashboardDressForDay => 'Yarını giyin.';

  @override
  String get dashboardOutfitOfDay => 'Günün kombini';

  @override
  String get dashboardFreshLook => 'Yeni bir görünüm';

  @override
  String get subscriptionManageInStoreTitle => 'Mağazada yönet';

  @override
  String get subscriptionManageInStoreBody =>
      'Bu plan mağaza üzerinden faturalandırılır. Mağaza hesabı ayarlarından yönet.';

  @override
  String get subscriptionCancelledTitle => 'Abonelik iptal edildi';

  @override
  String get subscriptionCancelledBody =>
      'Planın, bu faturalandırma döneminin sonuna kadar aktif kalacak.';

  @override
  String get subscriptionCancelFailedTitle => 'İptal edilemedi';

  @override
  String get subscriptionCouldNotOpenTitle => 'Açılamadı';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Faturalama yönetimi açılamadı.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Bağlantı açılamadı.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Bağlantınız yüklenemedi';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Davet bağlantınız yüklenemedi. Tekrar deneyin.';

  @override
  String get subscriptionReferralCopiedTitle => 'Kopyalandı';

  @override
  String get subscriptionReferralCopiedBody => 'Davet bağlantısı kopyalandı.';

  @override
  String get subscriptionReferralShareSubject => 'FitCheck AI\'yı dene';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'FitCheck AI\'a katıl, ikimize bir aylık Pro hediye. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Bağlantı kopyalandı';

  @override
  String get subscriptionShareUnavailableBody =>
      'Paylaşım kullanılamadığı için bağlantıyı kopyaladık.';

  @override
  String get subscriptionShareFailedTitle => 'Paylaşım başarısız';

  @override
  String get subscriptionShareFailedBody =>
      'Bunun yerine davet sayfasındaki bağlantıyı kopyalayın.';

  @override
  String get subscriptionStoreReadyTitle => 'Mağaza hazır';

  @override
  String get subscriptionStoreReadyBody =>
      'Mağaza fiyatları mevcut. Şimdi yükseltebilirsiniz.';

  @override
  String get purchaseFailedTitle => 'Satın alma başarısız';

  @override
  String get purchaseUnavailableTitle => 'Satın alma kullanılamıyor';

  @override
  String get purchaseIapUnavailableBody =>
      'Uygulama içi satın alımlar bu cihazda kullanılamıyor.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Bu plan henüz satın alınabilir durumda değil.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Bu plan henüz mağazada mevcut değil. Lütfen kısa süre sonra tekrar kontrol edin.';

  @override
  String get purchaseStartFailedBody =>
      'Satın alma başlatılamadı. Tekrar deneyin.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Ödeme sayfası bir ödeme bağlantısı döndürmedi.';

  @override
  String get purchasePendingTitle => 'Satın alma bekleniyor';

  @override
  String get purchasePendingBody =>
      'Satın almanız onay bekliyor. Onaylandığında erişiminiz olacak.';

  @override
  String get purchaseFailedBody => 'Satın alma başarısız oldu. Tekrar deneyin.';

  @override
  String get purchaseRestoredTitle => 'Geri yüklendi';

  @override
  String get purchaseRestoredBody => 'Satın alımlarınız geri yüklendi.';

  @override
  String get purchaseActiveTitle => 'Abonelik aktif';

  @override
  String get purchaseActiveBody => 'Aboneliğiniz aktif. Hoş geldiniz.';

  @override
  String get purchaseSignInRequiredTitle => 'Giriş yapın';

  @override
  String get purchaseSignInRequiredBody =>
      'Satın almanızı tamamlamak için giriş yapın.';

  @override
  String get purchaseErrorTitle => 'Satın alma hatası';

  @override
  String get purchaseInvalidTransactionBody =>
      'Satın almada doğrulanabilir bir işlem kimliği bulunmuyordu.';

  @override
  String get purchaseVerificationPendingTitle => 'Doğrulama bekleniyor';

  @override
  String get purchaseVerificationPendingBody =>
      'Satın alman şu anda mağazadan doğrulanamadı. İşlem otomatik olarak tamamlanacak ve çift ücretlendirilme olmayacak.';

  @override
  String get purchaseNotAppliedTitle => 'Satın alma uygulanamadı';

  @override
  String get purchaseNotAppliedBody =>
      'Satın alman hesabına uygulanamadı. Destek ekibiyle iletişime geç ve tekrar satın alma.';

  @override
  String get purchaseRestoreFailedTitle => 'İade başarısız';

  @override
  String get purchaseRestoreFailedBody =>
      'Satın alımlar geri yüklenemedi. Tekrar dene.';

  @override
  String get purchaseRecoveredActiveBody => 'Aboneliğin aktif.';

  @override
  String get purchaseCompleteTitle => 'Satın alma tamamlandı';

  @override
  String get giftCreateFailedTitle => 'Hediye oluşturulamadı';

  @override
  String get giftClaimFailedTitle => 'Hediye alınamadı';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hediye sana',
      one: 'Sana bir hediye',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 ay',
      '12': '1 yıl',
      'other': '$months ay',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining kaldı',
      one: '1 kaldı',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return 'FitCheck Pro\'nun $durationı';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender sana $duration FitCheck Pro gönderdi. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return '$recipient için FitCheck Pro hediyesi';
  }

  @override
  String giftFromSender(String sender) {
    return '$sender tarafından';
  }

  @override
  String giftPreviewFor(String recipient) {
    return '$recipient için';
  }

  @override
  String giftPreviewFrom(String sender) {
    return '$sender tarafından';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'alıcın';

  @override
  String get giftPreviewPlaceholderSender => 'sen';

  @override
  String get settingsSavedTitle => 'Kaydedildi';

  @override
  String get settingsNotSavedTitle => 'Kaydedilmedi';

  @override
  String get settingsAiChooseProviderBody => 'Bir sağlayıcı seç.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Özel sağlayıcı için bir API URL\'si gerekir.';

  @override
  String get settingsAiKeyRequiredBody => 'Bir API anahtarı gir.';

  @override
  String get settingsAiSavedBody => 'AI ayarların kaydedildi.';

  @override
  String get settingsAiMissingDetailsTitle => 'Eksik bilgiler';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Test etmek için bir API URL\'si ve sohbet modeli gir.';

  @override
  String get settingsAiKeyNeededTitle => 'API anahtarı gerekli';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Test için API anahtarınızı girin. Kaydedilen anahtarınız gizli kalır.';

  @override
  String get settingsAiKeyToTestBody => 'Test için API anahtarınızı girin.';

  @override
  String get settingsAiConnectedTitle => 'Bağlandı';

  @override
  String get settingsAiConnectedBody => 'Bağlantı çalışıyor.';

  @override
  String get settingsAiTestFailedTitle => 'Test başarısız';

  @override
  String get settingsPreferencesSavedBody => 'Tercihleriniz kaydedildi.';

  @override
  String get settingsPasswordNotChangedTitle => 'Şifre değiştirilmedi';

  @override
  String get settingsOAuthPasswordBody =>
      'Bu hesap Google veya Apple ile oturum açıyor. Önce şifre belirlemek için \"Şifremi unuttum\" seçeneğini kullanın.';

  @override
  String get settingsCurrentPasswordIncorrectBody => 'Geçerli şifre hatalı.';

  @override
  String get settingsExportReadyTitle => 'Dışa aktarma hazır';

  @override
  String get settingsExportReadyBody => 'Veri dışa aktarmanız indirmeye hazır.';

  @override
  String get settingsLinkCopiedTitle => 'Bağlantı kopyalandı';

  @override
  String get settingsExportClipboardBody =>
      'Tarayıcınızı açamadık, indirme bağlantısını kopyaladık. Yakında bir tarayıcıya yapıştırın: süresi doluyor.';

  @override
  String get settingsExportFailedTitle => 'Dışa aktarma başarısız';

  @override
  String get settingsAccountNotDeletedTitle => 'Hesap silinmedi';

  @override
  String photoshootPhotoLimit(int max) {
    return 'En fazla $max fotoğraf ekleyebilirsiniz.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Fotoğraf sınırı';

  @override
  String get photoshootAddAtLeastOnePhoto => 'En az bir fotoğraf ekleyin.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Fotoğraf yok';

  @override
  String get photoshootDescribeLookBody => 'İstediğiniz görünümü anlatın.';

  @override
  String get photoshootPromptNeededTitle => 'İstek gerekli';

  @override
  String get photoshootConsentFeatureLabel => 'AI Fotoğraf Çekimi';

  @override
  String get photoshootStatusPreparing => 'Fotoğraflar hazırlanıyor';

  @override
  String get photoshootStatusGenerating => 'Oluşturuluyor';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Toplam $total içinde $current parti';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$total içinde $done tamamlandı';
  }

  @override
  String get photoshootGenerationFailedBody => 'Oluşturma başarısız.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready hazır, $failed başarısız.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Kısmen tamamlandı';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotoğraf hazır.',
      one: '1 fotoğraf hazır.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Bağlantı koptu. Lütfen tekrar deneyin.';

  @override
  String get photoshootCouldNotCancelTitle => 'İptal edilemedi';

  @override
  String get photoshootRetryFailedTitle => 'Yeniden deneme başarısız';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return '$number. fotoğraf hazır.';
  }

  @override
  String get photoshootReplacedTitle => 'Değiştirildi';

  @override
  String get photoshootSavedToGalleryBody => 'Galerinize kaydedildi.';

  @override
  String get photoshootSavedTitle => 'Kaydedildi';

  @override
  String get photoshootNotSavedTitle => 'Kaydedilmedi';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tüm $count fotoğraf galerinizde.',
      one: '1 fotoğraf galerinizde.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$total fotoğraftan $saved tanesi kaydedildi.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Bazı fotoğraflar kaydedilmedi';

  @override
  String get tryonConsentFeatureLabel => 'Sanal Prova';

  @override
  String get tryonAvatarUpdatedBody => 'Fotoğrafınız güncellendi.';

  @override
  String get tryonSavedTitle => 'Kaydedildi';

  @override
  String get tryonUploadFailedTitle => 'Yükleme başarısız';

  @override
  String get tryonChooseGarmentFirstBody => 'Önce bir giysi fotoğrafı seçin.';

  @override
  String get tryonNoGarmentTitle => 'Giysi yok';

  @override
  String get tryonWaitForUploadBody => 'Fotoğrafınızın yüklenmesini bekleyin.';

  @override
  String get tryonStillUploadingTitle => 'Hâlâ yükleniyor';

  @override
  String get tryonAddYourPhotoFirstBody => 'Önce kendi fotoğrafınızı ekleyin.';

  @override
  String get tryonReadyBody => 'Provmanız hazır.';

  @override
  String get tryonFailedTitle => 'Prova başarısız';

  @override
  String get tryonSavedToGalleryBody => 'Galerinize kaydedildi.';

  @override
  String get tryonNotSavedTitle => 'Kaydedilmedi';

  @override
  String get calendarEventAddedBody => 'Etkinlik eklendi';

  @override
  String get calendarEventPlannedTitle => 'Planlandı';

  @override
  String get calendarEventSavedBody => 'Etkinlik kaydedildi';

  @override
  String get calendarSavedTitle => 'Kaydedildi';

  @override
  String get calendarEventNotSavedTitle => 'Etkinlik kaydedilmedi';

  @override
  String get calendarEventRemovedBody => 'Etkinlik kaldırıldı';

  @override
  String get calendarEventDeletedTitle => 'Silindi';

  @override
  String get calendarEventNotDeletedTitle => 'Etkinlik silinemedi';

  @override
  String get calendarOutfitNotLinkedTitle => 'Kıyafet ilişkilendirilemedi';

  @override
  String get calendarLinkedTitle => 'İlişkilendirildi';

  @override
  String get calendarOutfitNotRemovedTitle => 'Kıyafet kaldırılamadı';

  @override
  String get calendarOutfitRemovedBody => 'Kıyafet kaldırıldı';

  @override
  String get calendarDisconnectedBody => 'Takvim bağlantısı kesildi';

  @override
  String get calendarDisconnectedTitle => 'Bağlantı kesildi';

  @override
  String get calendarNotDisconnectedTitle => 'Takvim bağlantısı kesilemedi';

  @override
  String get calendarTodayLabel => 'bugün';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etkinlik',
      one: '1 etkinlik',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, kıyafet ilişkili';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" kaldırılacak.';
  }

  @override
  String get calendarThisAppLabel => 'Bu uygulama';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return '$provider ile senkronizasyon henüz mevcut değil. Etkinlikleri buraya eklemeye devam edebilirsiniz.';
  }

  @override
  String get calendarWeekdaySunShort => 'Paz';

  @override
  String get calendarWeekdayMonShort => 'Pzt';

  @override
  String get calendarWeekdayTueShort => 'Sal';

  @override
  String get calendarWeekdayWedShort => 'Çar';

  @override
  String get calendarWeekdayThuShort => 'Per';

  @override
  String get calendarWeekdayFriShort => 'Cum';

  @override
  String get calendarWeekdaySatShort => 'Cmt';

  @override
  String get calendarWeekdayMonday => 'Pazartesi';

  @override
  String get calendarWeekdayTuesday => 'Salı';

  @override
  String get calendarWeekdayWednesday => 'Çarşamba';

  @override
  String get calendarWeekdayThursday => 'Perşembe';

  @override
  String get calendarWeekdayFriday => 'Cuma';

  @override
  String get calendarWeekdaySaturday => 'Cumartesi';

  @override
  String get calendarWeekdaySunday => 'Pazar';

  @override
  String get outfitSavedToFavouritesBody => 'Favorilere kaydedildi';

  @override
  String get outfitRemovedFromFavouritesBody => 'Favorilerden çıkarıldı';

  @override
  String get outfitNotSavedTitle => 'Kaydedilmedi';

  @override
  String get outfitLoggedAsWornBody => 'Bugün giyilmiş olarak işaretlendi.';

  @override
  String get outfitNicePickTitle => 'Güzel seçim';

  @override
  String get outfitRemovedBody => 'Kıyafet kaldırıldı.';

  @override
  String get outfitDeletedTitle => 'Silindi';

  @override
  String get outfitNotDeletedTitle => 'Silinmedi';

  @override
  String get outfitDuplicatedBody => 'Bir kopyası kıyafetlerinde.';

  @override
  String get outfitDuplicatedTitle => 'Kopyalandı';

  @override
  String get outfitNotDuplicatedTitle => 'Kopyalanmadı';

  @override
  String get outfitNotSharedTitle => 'Paylaşılmedi';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" hazır.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Koleksiyon oluşturulamadı';

  @override
  String get outfitCollectionUpdatedBody => 'Koleksiyon güncellendi.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Koleksiyon güncellenmedi';

  @override
  String get outfitCollectionDeletedBody => 'Koleksiyon silindi.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Koleksiyon silinmedi';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kıyafet eklendi.',
      one: '1 kıyafet eklendi.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Kıyafetler eklenemedi';

  @override
  String get outfitPreviewNotCreatedTitle => 'Önizleme oluşturulamadı';

  @override
  String get outfitGiveNameBody => 'Kıyafete bir ad ver.';

  @override
  String get outfitNameMissingTitle => 'İsim';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'En az bir parça seç.';

  @override
  String outfitCreatedBody(String name) {
    return '$name kıyafetlerinde.';
  }

  @override
  String get outfitSavedTitle => 'Kaydedildi';

  @override
  String get wardrobeAddedToFavouritesBody => 'Favorilere eklendi';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Favorilerden kaldırıldı';

  @override
  String get wardrobeNotSavedTitle => 'Kaydedilmedi';

  @override
  String get wardrobeLoggedAsWornBody => 'Bugün giyildi olarak kaydedildi.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Külbeden çıkarıldı.';

  @override
  String get wardrobeDeletedTitle => 'Silindi';

  @override
  String get wardrobeNotDeletedTitle => 'Silinmedi';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça kulbeden çıkarıldı.',
      one: '1 parça kulbeden çıkarıldı.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI Dolap Çıkarımı';

  @override
  String get itemAddScanJobLabel => 'Tara';

  @override
  String get itemAddFoundEarlierBody => 'Önceki bir taramada bulundu';

  @override
  String get itemAddLookingAtPhoto => 'Fotoğrafınız inceleniyor';

  @override
  String get itemAddExtractionFailedBody => 'Çıkarım başarısız oldu';

  @override
  String get itemAddJobFailedBody => 'İş başarısız oldu';

  @override
  String get itemAddConnectionLostBody => 'Bağlantı koptu. Tekrar deneyin.';

  @override
  String get itemAddConnectionLostProcessingBody => 'İşlerken bağlantı koptu.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Parça $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Parça';

  @override
  String get itemAddNotCancelledTitle => 'İptal edilmedi';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça kulbenizdedir.',
      one: '1 parça kulbenizdedir.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$total parçanın $saved tanesi kaydedildi. Kalanları denemek için kaydetmeye dokunun.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Bazı parçalar kaydedilmedi';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'En az bir fotoğraf seçin.';

  @override
  String get batchPhotoUnreadableBody => 'Bu fotoğraf okunamadı.';

  @override
  String get batchNoPhotosReadableBody =>
      'Bu fotoğrafların hiçbiri okunamadı. Diğer fotoğrafları deneyin.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotoğraf',
      one: '1 fotoğraf',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Çalışırken bağlantı koptu. Tekrar deneyin.';

  @override
  String get batchNotCancelledTitle => 'İptal edilmedi';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Gönderi bağlantıları desteklenmez. Bir profil bağlantısı girin.';

  @override
  String get batchLinkSpacesBody => 'Bağlantılar boşluk içeremez.';

  @override
  String get batchEnterProfileLinkBody =>
      'Bir Instagram veya Facebook profil bağlantısı girin.';

  @override
  String get batchEnterProfileLinkShortBody => 'Bir profil bağlantısı girin.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Giriş sayfası açılmadı. Tekrar deneyin.';

  @override
  String get batchSignInBrowserBody =>
      'Tarayıcınızda oturum açın, sonra FitCheck\'e dönün.';

  @override
  String get batchConnectAccountTitle => 'Hesabınızı bağlayın';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Doğrulayıcı uygulamalarındaki kodu girin.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram güvenlik kontrolü yapıyor. Önce tarayıcınızda oturum açın.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Kullanıcı adınızı ve şifrenizi tekrar girin.';

  @override
  String get batchSignInFailedBody =>
      'Oturum açma başarısız oldu. Kullanıcı adınızı ve şifrenizi kontrol edin.';

  @override
  String get batchSignInToKeepImportingBody =>
      'İçe aktarmaya devam etmek için oturum açın.';

  @override
  String get batchAccountNotConnectedBody => 'Hesabınız bağlanmadı.';

  @override
  String get batchAccountConnectedTitle => 'Hesap bağlandı';

  @override
  String get batchNotConnectedTitle => 'Bağlı değil';

  @override
  String get batchImportConnectionLostBody =>
      'İçe aktarma bağlantısı kesildi. Kontrol etmek için yenileyin.';

  @override
  String batchPickUpToBody(int max) {
    return 'En fazla $max fotoğraf seçin. Parçaları biz buluruz.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$total fotoğraftan $count';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return '$count fotoğraftan $done hazırlanıyor';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotoğrafta parçaları bul',
      one: '1 fotoğrafta parçaları bul',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Bu $platform hesabı iki aşamalı oturum açma kullanıyor. Doğrulayıcı uygulamalarındaki 6 haneli kodu girin.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Bu $platform profili gizlidir veya fotoğrafları göstermek için oturum açma gerektirir.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return '$platform ile bağlan';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotoğraf bulundu',
      one: '1 fotoğraf bulundu',
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
    return '$total fotoğraftan $processed işlendi · $added eklendi · $waiting bekleniyor · $skipped atlandı';
  }

  @override
  String batchScanningPhoto(int number) {
    return '$number. fotoğraf taranıyor';
  }

  @override
  String batchPhotoIsNext(int number) {
    return '$number. fotoğraf sırada';
  }

  @override
  String batchPhotoLabel(int number) {
    return '$number. fotoğraf';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça bulundu',
      one: '1 parça bulundu',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotoğraf dolabınıza eklendi.',
      one: '1 fotoğraf dolabınıza eklendi.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count stüdyo fotoğrafı daha geliyor. Hazır olanı kaydedebilir veya ayrılabilirsiniz — sizi bilgilendireceğiz.',
      one:
          '1 stüdyo fotoğrafı daha geliyor. Hazır olanı kaydedebilir veya ayrılabilirsiniz — sizi bilgilendireceğiz.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Henüz kaydedilmeyenler: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotoğrafta',
      one: '1 fotoğrafta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces parça',
      one: '1 parça',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen seçildi. Atlamak için bir parçaya dokunun.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça kaydediliyor',
      one: '1 parça kaydediliyor',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parça kaydet',
      one: '1 parça kaydet',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Vücut profilin kaydedildi.';

  @override
  String get bodyProfileSavedTitle => 'Kaydedildi';

  @override
  String get bodyProfileNotSavedTitle => 'Kaydedilmedi';

  @override
  String get bodyProfileSetDefaultBody => 'Varsayılan profilin olarak ayarla.';

  @override
  String get bodyProfileDeletedBody => 'Vücut profili silindi.';

  @override
  String get bodyProfileDeletedTitle => 'Silindi';

  @override
  String get bodyProfileNotDeletedTitle => 'Silinmedi';

  @override
  String get feedbackNotSentTitle => 'Gönderilmedi';

  @override
  String get feedbackSentBody =>
      'Teşekkürler. Her mesajı okuyoruz, gerekiyorsa geri dönüş yapıyoruz.';

  @override
  String get feedbackSentTitle => 'Geri bildirim gönderildi';

  @override
  String get recommendUnnamedPiece => 'İsimsiz parça';

  @override
  String get recommendEnterCityBody =>
      'Havaya uygun öneriler için şehrinizi girin.';

  @override
  String get recommendWhichCityTitle => 'Hangi şehir?';

  @override
  String get aiConsentSheetTitle =>
      'Fotoğrafları bir yapay zekâ hizmetiyle paylaşma';

  @override
  String get aiConsentSheetBody =>
      'Deneme ve fotoğraflı çekim görsellerini oluşturmak için FitCheck AI, sağladığın fotoğrafları (yüz ve vücudunu içeren görseller dahil) işleme için güvenilir üçüncü taraf bir yapay zekâ sağlayıcıya (ör. OpenAI veya Google Gemini) gönderir. Görsellerini üretir, koşullarımıza göre bunları model eğitimi için kullanmaz. Fotoğraflar güvenli iletilir ve asla reklam amacıyla paylaşılmaz.';

  @override
  String get aiConsentSheetPermission =>
      'Devam ederek fotoğraflarının bu yapay zekâ sağlayıcılarla görsel üretimi için paylaşılmasına açıkça izin veriyorsun.';

  @override
  String get skeletonsLoadMoreFailed => 'Daha fazla yüklenemedi.';

  @override
  String get jobsPiecesReadyTitle => 'Parçaların hazır';

  @override
  String get jobsScanStoppedTitle => 'Tarama durduruldu';

  @override
  String get jobsNothingSavedBody => 'Hiçbir şey kaydedilmedi. Tekrar dene.';

  @override
  String get jobsPhotoUploadFailedBody => 'Fotoğraf yükleme başarısız oldu.';

  @override
  String get authGoogleSignInStartFailed =>
      'Google Oturum Açma başlatılamadı. Lütfen tekrar dene.';

  @override
  String get referralAppliedTitle => 'Yönlendirme uygulandı!';

  @override
  String get billingStoreUnavailableBody =>
      'Bu cihazda mağaza satın alma işlemleri kullanılamıyor.';

  @override
  String get billingPurchaseProcessingBody =>
      'Bu satın alma hâlâ işleniyor. Planını görmek için bir dakika içinde uygulamayı yeniden açın.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatar yükleme bir görsel URL döndürmedi.';

  @override
  String get rewardsDayStreakLabel => 'günlük seri';

  @override
  String rewardsBestStreak(int days) {
    return 'En iyi $days gün';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission Erişimi Gerekli';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return '$permission erişimi şu an reddediliyor. İzin vermek için Ayarlar\'ı açın, ardından tekrar deneyin.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return '4 adımın $step. adımı';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return '$total adımın $step. adımı';
  }

  @override
  String feedbackRemoveImage(int index) {
    return '$index. görseli kaldır';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return '$index. görseli kaldır';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points P';
  }

  @override
  String legalSupportEmailBody(String email) {
    return '$email adresine e-posta gönderin. Bildirimler 24 saat içinde incelenir.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return '$piece parçasını kaldır';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String outfitAddToNamed(String name) {
    return '\"$name\" içine ekle';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" silindi. Parçalar dolabında kalacak.';
  }

  @override
  String outfitShowAllCount(int count) {
    return '$count tümünü göster';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Bugün $count kaldı';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return '$index. fotoğraf başarısız oldu';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$max fotoğraftan $selected seçildi';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape vücut · $tone ten';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return '$name için seçenekler';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'En çok giyilen: $name, $count kez';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: tanımlı değil';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '%$percent uyum';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$max ögeden $picked seçildi';
  }

  @override
  String recommendRemoveItem(String item) {
    return '$item ögesini kaldır';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency öncelik';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Bu plan $store üzerinden faturalandırılır. Değiştirmek veya iptal etmek için $store hesap ayarlarınızı kullanın.';
  }

  @override
  String billingManageInStore(String store) {
    return '$store içinde yönet';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $max içinde $current kullanıldı';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Yaklaşık $seconds sn kaldı';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$total stüdyo fotoğraftan $done hazır';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$total stüdyo fotoğraftan $ready hazır. Atlamak için bir parçaya dokunun.';
  }

  @override
  String bodyProfileMeasurements(String height, String weight) {
    return '$height cm · $weight kg';
  }

  @override
  String profileFieldUnsetLabel(String value, String label) {
    return '$label $value';
  }

  @override
  String get profileFieldNotSet => 'Hayır';
}
