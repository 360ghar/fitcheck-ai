// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Utama';

  @override
  String get tabPhotoshoot => 'Foto';

  @override
  String get tabCloset => 'Almari';

  @override
  String get tabOutfits => 'Gaya';

  @override
  String get tabMore => 'Lagi';

  @override
  String get actionAddItem => 'Tambah item';

  @override
  String get actionCreateOutfit => 'Cipta gaya';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionDelete => 'Padam';

  @override
  String get actionSave => 'Simpan';

  @override
  String get actionRetry => 'Cuba lagi';

  @override
  String get actionDone => 'Selesai';

  @override
  String get actionNext => 'Seterusnya';

  @override
  String get actionBack => 'Kembali';

  @override
  String get actionClose => 'Tutup';

  @override
  String get actionSearch => 'Cari';

  @override
  String get actionContinue => 'Teruskan';

  @override
  String get stateLoading => 'Memuatkan';

  @override
  String get stateErrorTitle => 'Ada yang tidak kena';

  @override
  String get stateErrorBody => 'Cuba lagi. Jika masih gagal, hubungi sokongan.';

  @override
  String get stateOfflineTitle => 'Anda di luar talian';

  @override
  String get stateOfflineBody =>
      'Sambung semula untuk menyegerakkan almari dan menjana gaya.';

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String get settingsAccountSection => 'Akaun';

  @override
  String get settingsPreferencesSection => 'Keutamaan';

  @override
  String get settingsPlanBilling => 'Pelan dan bil';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsNotifications => 'Pemberitahuan';

  @override
  String get settingsUnits => 'Unit ukuran';

  @override
  String get settingsAppearance => 'Penampilan';

  @override
  String get settingsPrivacySection => 'Privasi dan data';

  @override
  String get settingsAboutSection => 'Tentang';

  @override
  String get settingsSignOut => 'Log keluar';

  @override
  String get settingsDeleteAccount => 'Padam akaun';

  @override
  String get settingsDeleteAccountTitle => 'Padam akaun anda?';

  @override
  String get settingsDeleteAccountBody =>
      'Ini akan memadamkan almari, pakaian, foto dan profil anda. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrik (cm, kg)';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageSystem => 'Guna bahasa peranti';

  @override
  String get languageSystemBody => 'FitCheck AI mengikut bahasa telefon anda.';

  @override
  String get languageSearchHint => 'Cari bahasa';

  @override
  String get languageCurrent => 'Semasa';

  @override
  String get languageReviewNote =>
      'Terjemahan ini baharu. Beritahu kami jika ada yang kurang tepat.';

  @override
  String get languageChanged => 'Bahasa dikemas kini';

  @override
  String get paywallTitle => 'Pilih pelan anda';

  @override
  String get paywallTrialBadge => '1 bulan percuma';

  @override
  String get paywallTrialTitle => 'Bulan pertama Pro anda percuma';

  @override
  String get paywallTrialBody =>
      'Muat naik seluruh almari anda sekaligus. Tambah pakaian selepas itu.';

  @override
  String get paywallFreeForeverTitle => 'Percuma selamanya';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Tiada kad diperlukan. Setiap bulan anda mendapat $uploads muat naik AI, $outfits pakaian dan $images imej penggambaran sehari.';
  }

  @override
  String get paywallCtaTrial => 'Mulakan bulan percuma saya';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Naik taraf ke $plan';
  }

  @override
  String get paywallRestore => 'Pulihkan pembelian';

  @override
  String get paywallManage => 'Urus langganan';

  @override
  String get paywallTerms => 'Syarat penggunaan';

  @override
  String get paywallPrivacy => 'Dasar privasi';

  @override
  String get paywallPerMonth => 'sebulan';

  @override
  String get paywallPerYear => 'setahun';

  @override
  String get paywallBestValue => 'Nilai terbaik';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Percubaan percuma untuk pelanggan baharu sahaja. Selepas percubaan, Pro diperbaharui pada $price kecuali dibatalkan sekurang-kurangnya 24 jam sebelum tamat.';
  }

  @override
  String get introTitle => 'Almari anda, akhirnya tersusun';

  @override
  String get introBody =>
      'Gambar pakaian anda sekali. Dapatkan idea pakaian, pratonton cuba pakai dan foto studio daripada apa yang anda miliki.';

  @override
  String get introStart => 'Mulakan';

  @override
  String get introHaveAccount => 'Saya sudah mempunyai akaun';

  @override
  String get introSkip => 'Langkau';

  @override
  String get authSignIn => 'Log masuk';

  @override
  String get authSignUp => 'Daftar akaun';

  @override
  String get authEmail => 'E-mel';

  @override
  String get authPassword => 'Kata laluan';

  @override
  String get authForgotPassword => 'Lupa kata laluan?';

  @override
  String get authContinueApple => 'Teruskan dengan Apple';

  @override
  String get authContinueGoogle => 'Teruskan dengan Google';

  @override
  String get authOrDivider => 'atau';

  @override
  String get wardrobeTitle => 'Almari';

  @override
  String get wardrobeEmptyTitle => 'Almari anda kosong';

  @override
  String get wardrobeEmptyBody =>
      'Tambah pakaian pertama anda, atau muat naik foto keseluruhan rak sekaligus.';

  @override
  String get wardrobeAddFirst => 'Tambah item pertama';

  @override
  String get wardrobeSearchHint => 'Cari almari anda';

  @override
  String get categoryTops => 'Atasan';

  @override
  String get categoryBottoms => 'Bawahan';

  @override
  String get categoryShoes => 'Kasut';

  @override
  String get categoryAccessories => 'Aksesori';

  @override
  String get categoryOuterwear => 'Pakaian Luar';

  @override
  String get categorySwimwear => 'Pakaian Renang';

  @override
  String get categoryActivewear => 'Pakaian Sukan';

  @override
  String get categoryOther => 'Lain-lain';

  @override
  String get conditionClean => 'Bersih';

  @override
  String get conditionDirty => 'Kotor';

  @override
  String get conditionLaundry => 'Dalam cucian';

  @override
  String get conditionRepair => 'Perlu dibaiki';

  @override
  String get conditionDonate => 'Untuk didermakan';

  @override
  String get seasonSpring => 'Musim bunga';

  @override
  String get seasonSummer => 'Musim panas';

  @override
  String get seasonFall => 'Musim luruh';

  @override
  String get seasonWinter => 'Musim sejuk';

  @override
  String get seasonAll => 'Semua musim';

  @override
  String get styleCasual => 'Kasual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Perniagaan';

  @override
  String get styleSporty => 'Sporty';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalis';

  @override
  String get styleRomantic => 'Romantik';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Klasik';

  @override
  String get styleElegant => 'Elegan';

  @override
  String get styleOther => 'Lain-lain';

  @override
  String get occasionWork => 'Kerja';

  @override
  String get occasionDateNight => 'Temu janji';

  @override
  String get occasionTravel => 'Perjalanan';

  @override
  String get occasionWedding => 'Perkahwinan';

  @override
  String get occasionGym => 'Gim';

  @override
  String get occasionWeekend => 'Hujung minggu';

  @override
  String get occasionParty => 'Parti';

  @override
  String get occasionInterview => 'Temuduga';

  @override
  String get colorBlack => 'Hitam';

  @override
  String get colorWhite => 'Putih';

  @override
  String get colorGrey => 'Kelabu';

  @override
  String get colorNavy => 'Biru Gelap';

  @override
  String get colorBrown => 'Coklat';

  @override
  String get colorRed => 'Merah';

  @override
  String get colorBlue => 'Biru';

  @override
  String get colorGreen => 'Hijau';

  @override
  String get colorPink => 'Merah Jambu';

  @override
  String get colorPurple => 'Ungu';

  @override
  String get colorYellow => 'Kuning';

  @override
  String get colorOrange => 'Oren';

  @override
  String get colorBeige => 'Krem';

  @override
  String get dateToday => 'Hari ini';

  @override
  String get dateYesterday => 'Semalam';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari lepas',
      one: '1 hari lepas',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minggu lepas',
      one: '1 minggu lepas',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bulan lepas',
      one: '1 bulan lepas',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tahun lepas',
      one: '1 tahun lepas',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Suka FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Penilaian ringkas membantu orang lain mencari gaya mereka.';

  @override
  String get ratingPromptYes => 'Nilai aplikasi';

  @override
  String get ratingPromptNo => 'Bukan sekarang';

  @override
  String get closetNoMatchesTitle => 'Tiada padanan';

  @override
  String get closetNoMatchesBody =>
      'Cuba kurangkan penapis atau cari yang lain.';

  @override
  String get closetClearFilters => 'Padam penapis';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count helai',
      one: '1 helai',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Memuatkan pakaian anda';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      one: '1 dipilih',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Padam pilihan';

  @override
  String get closetCancelSelection => 'Batal pilihan';

  @override
  String get closetCloseSearch => 'Tutup carian';

  @override
  String get closetShowGrid => 'Papar grid';

  @override
  String get closetShowList => 'Papar senarai';

  @override
  String get closetShowRows => 'Papar baris';

  @override
  String get closetStatsTitle => 'Statistik almari';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Padam $count item?',
      one: 'Padam 1 item?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Pakaian yang menggunakannya akan kehilangan item ini.';

  @override
  String get closetSortBy => 'Isih mengikut';

  @override
  String get closetFavourites => 'Kegemaran';

  @override
  String get closetFavourite => 'Kegemaran';

  @override
  String get closetUnfavourite => 'Buang kegemaran';

  @override
  String get closetWoreToday => 'Dipakai hari ini';

  @override
  String closetWornTimes(int count) {
    return 'Dipakai $count×';
  }

  @override
  String get closetCategoryLabel => 'Kategori';

  @override
  String get closetUseCaseLabel => 'Kegunaan';

  @override
  String get closetAnyUseCase => 'Semua';

  @override
  String get closetOtherUseCase => 'Kegunaan lain';

  @override
  String get closetOtherUseCaseHint => 'Contohnya, makan tengah hari';

  @override
  String get closetUseUseCase => 'Gunakan ini';

  @override
  String get closetClearAll => 'Kosongkan semua';

  @override
  String get sortNewest => 'Terbaharu dahulu';

  @override
  String get sortOldest => 'Terlama dahulu';

  @override
  String get sortName => 'Nama (A–Z)';

  @override
  String get sortMostWorn => 'Paling kerap dipakai';

  @override
  String get useCaseInformal => 'Santai';

  @override
  String get useCaseDate => 'Temu janji';

  @override
  String get useCaseDinner => 'Makan malam';

  @override
  String get useCaseLunch => 'Makan tengah hari';

  @override
  String get actionSelect => 'Pilih';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionFilter => 'Tapis';

  @override
  String get actionSort => 'Isih';

  @override
  String get actionAll => 'Semua';

  @override
  String get dashboardStartClosetTitle => 'Mulakan almari anda';

  @override
  String get dashboardStartClosetBody =>
      'Ambil gambar beberapa helai pakaian. Kami akan tag untuk anda.';

  @override
  String get dashboardPieces => 'helai';

  @override
  String get dashboardOutfits => 'pakaian';

  @override
  String get dashboardDayStreak => 'hari berturut-turut';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count bulan ini';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Terbaik $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kegemaran',
      one: '1 kegemaran',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pakaian disimpan',
      one: '1 pakaian disimpan',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Paling kerap dipakai: $name, $count kali';
  }

  @override
  String get setupSkip => 'Langkau tetapan';

  @override
  String get setupWhoTitle => 'Siapa yang kami gayakan?';

  @override
  String get setupWhoBody =>
      'Menetapkan model untuk cuba-pakai dan sesi foto. Anda boleh menukarnya dalam profil anda.';

  @override
  String get setupStyleTitle => 'Apa yang anda paling kerap pakai?';

  @override
  String get setupStyleBody =>
      'Pilih mana-mana. Idea pakaian bermula dari sini.';

  @override
  String get setupClosetTitle => 'Tambah pakaian pertama anda.';

  @override
  String get setupClosetBody =>
      'Ambil gambar beberapa helai pakaian, atau timbunan pakaian. Setiap helai akan dipotong dan difailkan untuk anda.';

  @override
  String get setupAddClothes => 'Tambah pakaian';

  @override
  String get setupStylesLabel => 'Gaya';

  @override
  String get setupOccasionsLabel => 'Majlis';

  @override
  String get setupSkipStep => 'Langkau';

  @override
  String get setupLater => 'Nanti';

  @override
  String get setupSaveError => 'Gagal menyimpan';

  @override
  String get genderWomen => 'Wanita';

  @override
  String get genderMen => 'Lelaki';

  @override
  String get genderNonBinary => 'Non-binari';

  @override
  String get genderPreferNotToSay => 'Tidak mahu menyatakan';

  @override
  String get outfitEmptyTitle => 'Tiada pakaian lagi';

  @override
  String get outfitEmptyBody =>
      'Padankan pakaian dari almari anda dan simpan gaya tersebut.';

  @override
  String get outfitNoMatchesTitle => 'Tiada pakaian sepadan';

  @override
  String get outfitSearchHint => 'Cari pakaian anda';

  @override
  String get outfitLoading => 'Memuatkan pakaian anda';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pakaian',
      one: '1 pakaian',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Gaya dan musim';

  @override
  String get outfitCollections => 'Koleksi';

  @override
  String get outfitDuplicate => 'Salin';

  @override
  String get outfitDeleteTitle => 'Padam pakaian ini?';

  @override
  String get outfitDeleteBody => 'Barang-barangnya kekal di dalam almari anda.';

  @override
  String get outfitDrafts => 'Draf';

  @override
  String get outfitDraft => 'Draf';

  @override
  String get filterStyle => 'Gaya';

  @override
  String get filterSeason => 'Musim';

  @override
  String get itemDetailDeleteTitle => 'Padam barang ini?';

  @override
  String get itemDetailDeleteBody =>
      'Pakaian yang menggunakannya akan kehilangan barang ini.';

  @override
  String get itemAddFavourite => 'Tambah ke kegemaran';

  @override
  String itemSize(String size) {
    return 'Saiz $size';
  }

  @override
  String get itemColours => 'Warna';

  @override
  String get itemMaterial => 'Bahan';

  @override
  String get itemPattern => 'Corak';

  @override
  String get itemUseCases => 'Kegunaan';

  @override
  String get itemKeptIn => 'Disimpan di';

  @override
  String get itemPrice => 'Harga';

  @override
  String get itemBought => 'Dibeli';

  @override
  String get itemTags => 'Tag';

  @override
  String get itemAdded => 'Ditambah';

  @override
  String get itemTimesWornLabel => 'kali dipakai';

  @override
  String get itemLastWornLabel => 'terakhir dipakai';

  @override
  String get itemNeverWorn => 'Tidak pernah';

  @override
  String get authEntryBody =>
      'Setiap helai pakaian anda, digayakan oleh AI. Rancang pakaian, cuba, dan ambil gambar.';

  @override
  String get authCreateCloset => 'Bina almari anda';

  @override
  String get authWelcomeBack => 'Selamat kembali';

  @override
  String get authSignInBody => 'Log masuk untuk buka almari anda.';

  @override
  String get authCreateAccount => 'Daftar akaun';

  @override
  String get authCreateClosetBody =>
      'Hanya seminit. Item pertama anda percuma.';

  @override
  String get authName => 'Nama';

  @override
  String get authConfirmPassword => 'Sahkan kata laluan';

  @override
  String get authReferralCode => 'Kod rujukan (pilihan)';

  @override
  String get authResetTitle => 'Tetapkan semula kata laluan';

  @override
  String get authResetBody =>
      'Kami akan e-mel pautan untuk menetapkan kata laluan baharu.';

  @override
  String get authSendResetLink => 'Hantar pautan';

  @override
  String get authBackToSignIn => 'Kembali ke log masuk';

  @override
  String get authEnterEmail => 'Masukkan e-mel anda';

  @override
  String get authEnterValidEmail => 'Masukkan e-mel yang sah';

  @override
  String get authEnterPassword => 'Masukkan kata laluan';

  @override
  String get authPasswordTooShort => 'Sekurang-kurangnya 6 aksara';

  @override
  String get authShowPassword => 'Tunjuk kata laluan';

  @override
  String get authHidePassword => 'Sembunyi kata laluan';

  @override
  String get authNewHere => 'Pengguna baharu?';

  @override
  String authConfirmEmail(String email) {
    return 'Sahkan $email sebelum log masuk. Semak peti masuk anda.';
  }

  @override
  String get authResendEmail => 'Hantar semula';

  @override
  String get authResendingEmail => 'Menghantar...';

  @override
  String get authPasswordsDoNotMatch => 'Kata laluan tidak sepadan';

  @override
  String get authEnterName => 'Masukkan nama anda';

  @override
  String get authChoosePassword => 'Pilih kata laluan';

  @override
  String get authHaveAccount => 'Sudah mempunyai akaun?';

  @override
  String get authCodeAccepted => 'Kod diterima';

  @override
  String get authCodeNotFound => 'Kod tidak ditemui';

  @override
  String authReferralFrom(String name) {
    return 'Daripada $name. Anda berdua dapat sebulan percuma.';
  }

  @override
  String get authReferralInvalid => 'Kami tidak menemui kod ini.';

  @override
  String authResetSent(String email) {
    return 'Dihantar ke $email. Buka pautan pada telefon ini.';
  }

  @override
  String get introSlide1Title => 'Gambar almari anda sekali.';

  @override
  String get introSlide1Body =>
      'Ambil gambar timbunan baju. Setiap helai akan dipotong dan disusun untuk anda.';

  @override
  String get introSlide2Title => 'Bersiap lebih pantas.';

  @override
  String get introSlide2Body =>
      'Padanan pakaian daripada koleksi anda, mengikut rancangan dan cuaca.';

  @override
  String get introSlide3Title => 'Lihat sebelum anda pakai.';

  @override
  String get introSlide3Body =>
      'Cuba gaya pada foto anda sendiri, atau ambil gambar seperti kempen fesyen.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Cerah';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsTemperature => 'Suhu';

  @override
  String get settingsEmailUpdates => 'Kemas kini e-mel';

  @override
  String get settingsEmailUpdatesBody => 'Berita dan tips melalui e-mel';

  @override
  String get settingsOutfitReminders => 'Peringatan pakaian';

  @override
  String get settingsOutfitRemindersBody =>
      'Peringatan untuk merekod pakaian anda';

  @override
  String get settingsWeeklySummary => 'Ringkasan mingguan';

  @override
  String get settingsWeeklySummaryBody => 'Minggu anda dalam pakaian';

  @override
  String get settingsStyleSection => 'Gaya';

  @override
  String get settingsPreferredStyles => 'Gaya pilihan';

  @override
  String get settingsPreferredColours => 'Warna pilihan';

  @override
  String get settingsNoneChosen => 'Tiada pilihan';

  @override
  String get settingsPlanAiSection => 'Pelan dan AI';

  @override
  String get settingsPlanBillingBody => 'Pelan, penggunaan dan naik taraf';

  @override
  String get settingsPlanUsageBody => 'Pelan dan penggunaan';

  @override
  String get settingsInviteFriends => 'Jemput rakan';

  @override
  String get settingsInviteFriendsBody =>
      'Satu bulan percuma bagi setiap rakan yang menyertai';

  @override
  String get settingsAiProvider => 'Penyedia AI';

  @override
  String get settingsAiProviderBody =>
      'Gunakan model anda sendiri untuk tag dan imej';

  @override
  String get settingsAppVersion => 'Versi aplikasi';

  @override
  String get settingsPrivacyTerms => 'Privasi dan terma';

  @override
  String get settingsReportProblem => 'Laporkan masalah';

  @override
  String get settingsChangePassword => 'Tukar kata laluan';

  @override
  String get settingsExportData => 'Eksport data anda';

  @override
  String get settingsExportBody =>
      'Kami akan sediakan fail dengan semua simpanan anda dan buka muat turun.';

  @override
  String get settingsExportAction => 'Eksport';

  @override
  String get settingsCurrentPassword => 'Kata laluan semasa';

  @override
  String get settingsNewPassword => 'Kata laluan baharu';

  @override
  String get settingsConfirmNewPassword => 'Sahkan kata laluan baharu';

  @override
  String get settingsEnterCurrentPassword => 'Masukkan kata laluan semasa anda';

  @override
  String get settingsEnterNewPassword => 'Masukkan kata laluan baharu';

  @override
  String get settingsPasswordMin8 => 'Gunakan sekurang-kurangnya 8 aksara';

  @override
  String get settingsPasswordNeedsUpper => 'Tambah huruf besar';

  @override
  String get settingsPasswordNeedsLower => 'Tambah huruf kecil';

  @override
  String get settingsPasswordNeedsDigit => 'Tambah nombor';

  @override
  String get settingsPasswordsNoMatch => 'Kata laluan tidak sepadan';

  @override
  String get settingsChangeAction => 'Tukar';

  @override
  String get itemAddSnapTitle => 'Tangkap gambar pakaian';

  @override
  String get itemAddSnapBody =>
      'Kami akan kesan setiap pakaian dalam foto dan hasilkan imej studio yang bersih.';

  @override
  String get itemAddCamera => 'Ambil foto';

  @override
  String get itemAddGallery => 'Pilih dari galeri';

  @override
  String get itemAddOtherWays => 'Cara lain untuk menambah';

  @override
  String get itemAddSeveral => 'Tambah beberapa foto';

  @override
  String get itemAddSeveralBody => 'Sehingga 50 sekaligus';

  @override
  String get itemAddImportProfile => 'Import dari profil';

  @override
  String get itemAddImportProfileBody => 'Instagram atau Facebook';

  @override
  String get itemAddEnterDetails => 'Masukkan butiran sendiri';

  @override
  String get itemAddEnterDetailsBody => 'Tiada foto diperlukan';

  @override
  String get itemManualIntro =>
      'Hanya nama diperlukan. Tambah yang lain sekarang atau kemudian.';

  @override
  String get itemManualNameHint => 'Contohnya, baju kapas biru';

  @override
  String get itemManualEnterName => 'Masukkan nama';

  @override
  String get itemManualNotes => 'Nota';

  @override
  String get itemManualBrand => 'Jenama';

  @override
  String get itemManualSize => 'Saiz';

  @override
  String get itemManualEnterNumber => 'Masukkan nombor';

  @override
  String get itemManualSavePiece => 'Simpan pakaian';

  @override
  String get itemManualSaving => 'Menyimpan';

  @override
  String get itemManualSavedTitle => 'Disimpan';

  @override
  String itemManualSavedBody(String name) {
    return '$name ada dalam almari anda.';
  }

  @override
  String get itemManualNotSaved => 'Tidak disimpan';

  @override
  String get itemManualAddUseCase => 'Tambah kegunaan';

  @override
  String get itemManualAddUseCaseAction => 'Tambah kegunaan';

  @override
  String get itemPhotos => 'Foto';

  @override
  String get itemAddPhotos => 'Tambah foto';

  @override
  String get itemNoPhotoYet => 'Tiada foto lagi. Anda boleh simpan tanpa foto.';

  @override
  String get itemRemovePhoto => 'Buang foto';

  @override
  String get itemRemovePiece => 'Buang pakaian';

  @override
  String get filterConditionLabel => 'Keadaan';

  @override
  String get photoshootStepPhotos => 'Foto';

  @override
  String get photoshootStepSetup => 'Tetapan';

  @override
  String get photoshootStepCreating => 'Mencipta';

  @override
  String get photoshootStepResults => 'Hasil';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Langkah $current daripada $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Satu foto gagal. Cuba semula di bawah.';

  @override
  String photoshootManyFailed(int count) {
    return '$count foto gagal. Cuba semula setiap satu di bawah.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Berapa banyak';

  @override
  String get photoshootYourPrompt => 'Arahan anda';

  @override
  String get photoshootPromptHint =>
      'Waktu keemasan di atas bumbung, baju linen';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cipta $count foto',
      one: 'Cipta 1 foto',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'foto',
      one: 'foto',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Kami tidak dapat menyemak had hari ini.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Pelan $plan: $remaining daripada $limit baki hari ini';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Percuma';

  @override
  String get photoshootGallery => 'Galeri';

  @override
  String get photoshootUseCamera => 'Guna kamera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Buang foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Tiada foto ditemui';

  @override
  String get photoshootNoPhotosBody => 'Sesi tamat tanpa imej. Cuba lagi.';

  @override
  String get photoshootNewStyle => 'Gaya baharu';

  @override
  String get photoshootNewPhotos => 'Foto baharu';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Buka foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Laporkan foto';

  @override
  String get photoshootSaveToGallery => 'Simpan ke galeri';

  @override
  String get actionUpgrade => 'Naik taraf';

  @override
  String get referralLimitTitle => 'Anda telah menggunakan had foto hari ini';

  @override
  String get referralLimitBody =>
      'Foto percuma anda akan kembali esok. Rujuk rakan dan anda berdua dapat sebulan Pro percuma.';

  @override
  String get referralLimitRefer => 'Rujuk rakan';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Aplikasi temu janji';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetik';

  @override
  String get photoshootUseCustom => 'Arahan anda sendiri';

  @override
  String get photoshootDescLinkedin => 'Gambar profil profesional untuk kerja';

  @override
  String get photoshootDescDating => 'Santai, mesra dan semula jadi';

  @override
  String get photoshootDescPortfolio => 'Editorial, gaya fesyen tinggi';

  @override
  String get photoshootDescInstagram => 'Foto gaya hidup untuk suapan anda';

  @override
  String get photoshootDescAesthetic => 'Moody, bingkai artistik';

  @override
  String get photoshootDescCustom => 'Terangkan gaya yang anda mahu';

  @override
  String get aspectSquare => 'Segi empat sama';

  @override
  String get aspectPortrait => 'Potret';

  @override
  String get aspectLandscape => 'Landskap';

  @override
  String get aspectTall => 'Tinggi';

  @override
  String get aspectWide => 'Lebar';

  @override
  String get tryOnAppBar => 'Cuba maya';

  @override
  String get tryOnYourPhoto => 'Foto anda';

  @override
  String get tryOnGarment => 'Pakaian';

  @override
  String get tryOnUploadingPhoto => 'Memuat naik foto anda';

  @override
  String get tryOnAddPhotoPrompt => 'Tambah foto seluruh badan anda';

  @override
  String get tryOnBodyPhotoHint => 'Foto seluruh badan adalah yang terbaik';

  @override
  String get tryOnAddPhoto => 'Tambah foto';

  @override
  String get tryOnChangePhoto => 'Tukar foto';

  @override
  String get tryOnPhotoLoadFailed => 'Kami tidak dapat memuatkan foto anda.';

  @override
  String get tryOnChooseGarment => 'Pilih foto pakaian';

  @override
  String get tryOnChooseOneGarment => 'Pilih satu foto pakaian';

  @override
  String get tryOnGarmentHint =>
      'Foto pakaian rata atau pada penyangkut adalah yang terbaik';

  @override
  String get tryOnChange => 'Tukar';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Buang';

  @override
  String get tryOnLookTitle => 'Gaya';

  @override
  String get tryOnStyle => 'Stail';

  @override
  String get tryOnBackground => 'Latar belakang';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Sedang menggayakan anda. Ini mengambil masa kira-kira setengah minit.';

  @override
  String get tryOnEmptyResult => 'Cuba-padan anda muncul di sini';

  @override
  String get tryOnReportImage => 'Laporkan imej';

  @override
  String get tryOnCreating => 'Sedang mencipta';

  @override
  String get tryOnTryAgain => 'Cuba lagi';

  @override
  String get tryOnCreate => 'Cipta cuba-padan';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio putih';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio kelabu';

  @override
  String get tryOnBackgroundUrban => 'Jalanan bandar';

  @override
  String get tryOnBackgroundNature => 'Alam semula jadi';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Berdiri depan';

  @override
  String get tryOnPoseSide => 'Berdiri sisi';

  @override
  String get tryOnPoseWalking => 'Berjalan';

  @override
  String get dashboardGreetingMorning => 'Selamat pagi';

  @override
  String get dashboardGreetingAfternoon => 'Selamat tengah hari';

  @override
  String get dashboardGreetingEvening => 'Selamat malam';

  @override
  String get dashboardWelcome => 'Selamat datang';

  @override
  String get dashboardOpenProfile => 'Buka profil';

  @override
  String get dashboardRailToday => 'Hari ini';

  @override
  String get dashboardRailRecently => 'Terbaharu';

  @override
  String get dashboardActivityEmpty =>
      'Pakaian dan gaya baharu muncul di sini.';

  @override
  String get quickAddPiece => 'Tambah pakaian';

  @override
  String get quickAddPieceBody => 'Gambar dan tag';

  @override
  String get quickBuildOutfit => 'Bina gaya';

  @override
  String get quickBuildOutfitBody => 'Padankan pakaian anda';

  @override
  String get quickForYou => 'Untuk anda';

  @override
  String get quickForYouBody => 'Pilihan hari ini';

  @override
  String get quickPlanWeek => 'Rancang minggu';

  @override
  String get quickPlanWeekBody => 'Gaya mengikut tarikh';

  @override
  String get referralBannerUrgent => 'Kehabisan? Jemput rakan.';

  @override
  String get referralBannerTitle => 'Beri sebulan, dapat sebulan.';

  @override
  String get referralBannerBody =>
      'Anda dan rakan anda masing-masing mendapat sebulan Pro.';

  @override
  String get referralBannerDismiss => 'Tutup selama seminggu';

  @override
  String get referralBannerShare => 'Kongsi jemputan';

  @override
  String get referralBannerCopy => 'Salin pautan';

  @override
  String get itemEditPieceTitle => 'Edit helaian';

  @override
  String get itemEditDescriptionLabel => 'Penerangan';

  @override
  String get itemEditNotSaved => 'Tidak disimpan';

  @override
  String get itemEditSavedTitle => 'Disimpan';

  @override
  String get itemEditSavedBody => 'Perubahan anda telah disimpan.';

  @override
  String get itemEditSavedStalePhotos => 'Disimpan — foto mungkin sudah lama';

  @override
  String get itemEditRemovePieceHint => 'Padam helaian ini dari halaman item.';

  @override
  String get itemEditNoPhotos =>
      'Tiada foto lagi. Tambah satu dari galeri atau kamera anda.';

  @override
  String get itemEditKeepPhoto => 'Kekalkan foto';

  @override
  String get itemEditRemoved => 'Dibuang';

  @override
  String get itemEditAddUseCaseAction => 'Tambah';

  @override
  String get statsNoStatsTitle => 'Tiada statistik lagi';

  @override
  String get statsNoStatsBody =>
      'Tambah beberapa helaian dan campuran almari anda akan muncul di sini.';

  @override
  String get statsByCategory => 'Mengikut kategori';

  @override
  String get statsTotalValue => 'jumlah nilai';

  @override
  String get statsMostWorn => 'Paling kerap dipakai';

  @override
  String get statsLeastWorn => 'Menunggu giliran';

  @override
  String get statsUnnamedPiece => 'Helaian tanpa nama';

  @override
  String get jobsTitle => 'Imbasan';

  @override
  String get jobsEmptyTitle => 'Tiada imbasan lagi';

  @override
  String get jobsEmptyBody =>
      'Ambil gambar helaian dan biarkan di latar belakang — ia terus berfungsi di sini.';

  @override
  String get jobsNotCancelled => 'Tidak dibatalkan';

  @override
  String get jobsResume => 'Sambung';

  @override
  String get jobsReview => 'Semak';

  @override
  String get jobsStop => 'Henti';

  @override
  String get jobsDismiss => 'Tutup';

  @override
  String get reportTitle => 'Laporkan kandungan';

  @override
  String reportIntro(String contentType) {
    return 'Beritahu kami apa yang tidak kena dengan $contentType ini. Pasukan kami menyemak setiap laporan.';
  }

  @override
  String get reportReasonInappropriate =>
      'Tidak sesuai atau menyinggung perasaan';

  @override
  String get reportReasonNudity => 'Kebogelan atau kandungan seksual';

  @override
  String get reportReasonHarassment => 'Gangguan atau penderaan';

  @override
  String get reportReasonImpersonation => 'Penyamaran';

  @override
  String get reportReasonOther => 'Lain-lain';

  @override
  String get reportDetailsLabel => 'Butiran tambahan (pilihan)';

  @override
  String get reportSubmit => 'Hantar laporan';

  @override
  String get reportSubmittedTitle => 'Laporan dihantar';

  @override
  String get reportSubmittedBody =>
      'Terima kasih. Pasukan kami akan menyemak kandungan ini.';

  @override
  String get reportFailedTitle => 'Gagal menghantar laporan';

  @override
  String get reportFailedBody => 'Sila cuba lagi.';

  @override
  String get reportContentTryOnImage => 'imej cuba pakai AI';

  @override
  String get reportContentSharedOutfit => 'pakaian dikongsi';

  @override
  String get reportContentPhotoshootImage => 'imej sesi fotografi AI';

  @override
  String get sharedOutfitTitle => 'Pakaian dikongsi';

  @override
  String get sharedOutfitHideTooltip => 'Sembunyikan pakaian ini';

  @override
  String get sharedOutfitReportTooltip => 'Laporkan pakaian ini';

  @override
  String get sharedOutfitHideTitle => 'Sembunyikan pakaian ini?';

  @override
  String get sharedOutfitHideBody =>
      'Ia akan kekal tersembunyi pada peranti ini. Anda juga boleh melaporkannya supaya pasukan kami boleh menyemak dan memadamnya.';

  @override
  String get sharedOutfitHideAction => 'Sembunyi';

  @override
  String get sharedOutfitHiddenInfo =>
      'Pakaian ini tidak akan dipaparkan lagi pada peranti ini.';

  @override
  String get sharedOutfitHiddenToast => 'Pakaian disembunyikan';

  @override
  String get sharedOutfitMissingTitle => 'Pakaian ini tiada lagi';

  @override
  String get sharedOutfitMissingBody =>
      'Ia mungkin telah dipadamkan, atau pautan tidak tepat.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Anda menyembunyikan pakaian ini';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Jika ia tidak sesuai, laporkan melalui Privasi dan terma atau e-mel $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Suka gaya ini?';

  @override
  String get sharedOutfitCtaBody =>
      'Bina gaya sebegini daripada almari anda sendiri.';

  @override
  String get sharedOutfitCtaButton => 'Dapatkan FitCheck AI';

  @override
  String get errorTitle => 'Ralat';

  @override
  String get errorUnknown => 'Ralat tidak dijangka berlaku';

  @override
  String get errorNoConnection =>
      'Tiada sambungan internet. Sila semak rangkaian anda.';

  @override
  String get errorTimeout => 'Masa permohonan tamat. Sila cuba lagi.';

  @override
  String get errorServerError => 'Ada masalah di pihak kami. Sila cuba lagi.';

  @override
  String get errorBadGateway =>
      'Pelayan kami tidak tersedia sebentar. Sila cuba lagi.';

  @override
  String get errorServiceUnavailable =>
      'Perkhidmatan tidak tersedia buat sementara waktu. Sila cuba lagi nanti.';

  @override
  String get errorInternalError => 'Ada masalah. Sila cuba lagi.';

  @override
  String get errorUnauthorized => 'Sila log masuk untuk meneruskan.';

  @override
  String get errorForbidden => 'Anda tidak mempunyai akses ke itu.';

  @override
  String get errorSessionExpired =>
      'Sesi anda telah tamat. Sila log masuk semula.';

  @override
  String get errorInvalidCredentials =>
      'E-mel atau kata laluan itu tidak betul.';

  @override
  String get errorTokenRefreshFailed =>
      'Kami gagal menyegarkan sesi anda. Sila log masuk semula.';

  @override
  String get errorRequestCancelled => 'Permohonan dibatalkan.';

  @override
  String get errorInvalidFormat => 'Format fail itu tidak disokong.';

  @override
  String get errorFileTooLarge => 'Fail itu terlalu besar.';

  @override
  String get errorUploadFailed => 'Muat naik gagal. Sila cuba lagi.';

  @override
  String get errorCacheCorrupted =>
      'Data yang disimpan telah rosak dan ditetapkan semula.';

  @override
  String get errorCacheNotFound => 'Tiada data disimpan lagi.';

  @override
  String get errorUserNotFound => 'Kami tidak dapat menemui akaun itu.';

  @override
  String get errorItemNotFound => 'Item itu tidak wujud lagi.';

  @override
  String get errorOutfitNotFound => 'Outfit itu tidak wujud lagi.';

  @override
  String get rewardsTitle => 'Ganjaran';

  @override
  String get rewardsNoAchievementsTitle => 'Tiada pencapaian lagi';

  @override
  String get rewardsNoAchievementsBody =>
      'Tambah barang dan rancang outfit untuk dapatkan yang pertama.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Tiada siapa di papan skor lagi';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Rancang outfit untuk kumpul mata dan muncul di sini.';

  @override
  String get legalViewPrivacyPolicy => 'Lihat Dasar Privasi';

  @override
  String get aiConsentAgree => 'Saya Bersetuju & Teruskan';

  @override
  String get aiConsentNotNow => 'Tidak Sekarang';

  @override
  String get imageViewerCloseTooltip => 'Tutup paparan imej';

  @override
  String get updateReadyTitle => 'Kemas kini sedia';

  @override
  String get updateReadyBody =>
      'Mulakan semula FitCheck AI untuk gertakan penambahbaikan terkini.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI perlu akses kamera untuk merakamkan gambar set gaya dan item almari anda.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI perlu akses galeri foto untuk memilih gambar set gaya dan item almari anda.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI perlu menyimpan gambar set gaya yang dijana AI anda ke dalam galeri foto.';

  @override
  String get wardrobeSomePhotosSkipped => 'Beberapa foto dilewatkan';

  @override
  String get wardrobePhotosNotAdded => 'Foto tidak ditambah';

  @override
  String get wardrobePhotoNotAdded => 'Foto tidak ditambah';

  @override
  String get wardrobeNotStartedTitle => 'Belum dimulakan';

  @override
  String get wardrobeNoRoomTitle => 'Tiada ruang';

  @override
  String get wardrobeAddPhotosSemantic => 'Tambah foto';

  @override
  String get batchAddTileLabel => 'Tambah';

  @override
  String get batchProfileLinkLabel => 'Pautan profil';

  @override
  String get wardrobeImportFromProfileTitle => 'Import dari profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Tambah beberapa foto';

  @override
  String get wardrobeClearAction => 'Kosongkan';

  @override
  String get wardrobeRefreshTooltip => 'Muat semula';

  @override
  String get batchNoPhotosYetTitle => 'Tiada foto lagi';

  @override
  String get batchChoosePhotosAction => 'Pilih foto';

  @override
  String get batchWeFindEachPieceBody =>
      'Kami cari setiap bahagian dan membuat foto studio untuknya.';

  @override
  String get batchPreparingPhotosSemantic => 'Menyediakan foto';

  @override
  String get batchPhotosProcessedSemantic => 'Foto diproses';

  @override
  String get batchPasteProfileLinkTitle => 'Tampal pautan profil';

  @override
  String get batchPasteProfileLinkBody =>
      'Profil Instagram atau Facebook awam. Kami pindai fotonya, dan anda pilih apa yang masuk ke almari anda.';

  @override
  String get batchClearLinkTooltip => 'Kosongkan pautan';

  @override
  String get batchStartingButton => 'Memulakan';

  @override
  String get batchStartImportAction => 'Mulakan import';

  @override
  String get batchReviewEveryPhotoTitle => 'Anda semak setiap foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Tiada yang ditambah sehingga anda menyetujuinya.';

  @override
  String get batchPrivateProfilesTitle => 'Profil rahsia';

  @override
  String get batchPrivateProfilesBody =>
      'Sambungkan akaun anda. Instagram juga memerlukan nama pengguna dan kata laluan.';

  @override
  String get batchUseAnotherLinkAction => 'Guna pautan lain';

  @override
  String get batchSignInNeededTitle => 'Semburan diperlukan';

  @override
  String get batchEnterYourCodeTitle => 'Masukkan kod anda';

  @override
  String get batchUseUsernamePasswordAction =>
      'Guna nama pengguna dan kata laluan';

  @override
  String get batchAlreadyConnectedAction => 'Saya sudah sambung dalam pelayar';

  @override
  String get batchEnterCodeAction => 'Masukkan kod';

  @override
  String get batchTryAnotherWayAction => 'Cuba cara lain';

  @override
  String get batchLiveStatus => 'Laporan langsung';

  @override
  String get batchReconnectingStatus => 'Menyambung semula';

  @override
  String get batchSignInToInstagramTitle => 'Log masuk ke Instagram';

  @override
  String get batchUsernameLabel => 'Nama pengguna';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kod, jika anda guna log masuk dua langkah';

  @override
  String get batchAuthenticatorCodeBody =>
      'Guna kod 6 digit dari aplikasi pengesahan anda. Kod berubah dengan cepat.';

  @override
  String get batchVerifyAction => 'Sahkan';

  @override
  String get batchFindingPhotosTitle => 'Mencari gambar';

  @override
  String get batchImportPausedTitle => 'Import dihentikan sementara';

  @override
  String get batchProcessingPhotosTitle => 'Memproses gambar';

  @override
  String get batchWaitingNextPhoto => 'Menunggu gambar seterusnya';

  @override
  String get batchCancelImportAction => 'Batalkan import';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Tiada barang ditemui dalam gambar ini.';

  @override
  String get batchEditPieceColoursLabel => 'Warna, dipisahkan dengan koma';

  @override
  String get batchAddToClosetAction => 'Tambah ke almari';

  @override
  String get batchSkipPhotoAction => 'Langkau gambar ini';

  @override
  String get batchImportCompleteTitle => 'Import selesai';

  @override
  String get batchImportFailedTitle => 'Import gagal';

  @override
  String get batchImportCancelledTitle => 'Import dibatalkan';

  @override
  String get batchImportErrorBody => 'Sesuatu tidak kena semasa import.';

  @override
  String get batchNothingMoreImportedBody =>
      'Tiada lagi import dari profil ini.';

  @override
  String get batchViewClosetAction => 'Lihat almari';

  @override
  String get batchStartOverAction => 'Mula semula';

  @override
  String get wardrobeAddPieceTitle => 'Tambah barang';

  @override
  String get wardrobeAddDetailsTitle => 'Tambah butiran';

  @override
  String get wardrobeScanningTitle => 'Memindai';

  @override
  String get batchReviewPiecesTitle => 'Semak barang';

  @override
  String get wardrobeGalleryAction => 'Galeri';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Baharu';

  @override
  String get wardrobeRemovePhotoTooltip => 'Buang gambar';

  @override
  String get batchRunInBackgroundTooltip => 'Jalankan di latar belakang';

  @override
  String get batchStepOneOfTwo => 'Langkah 1 daripada 2';

  @override
  String get batchStepTwoOfTwo => 'Langkah 2 daripada 2';

  @override
  String get batchUploadingPhotosTitle => 'Memuat naik gambar';

  @override
  String get batchFindingPiecesTitle => 'Mencari barang';

  @override
  String get batchMakingStudioPhotosTitle => 'Membuat gambar studio';

  @override
  String get batchStoppedLabel => 'Dihentikan';

  @override
  String get batchFindingPiecesStoppedTitle => 'Pencarian barang dihentikan';

  @override
  String get batchCancelledLabel => 'Dibatalkan';

  @override
  String get batchAllDoneTitle => 'Selesai';

  @override
  String get batchOpeningPiecesBody => 'Membuka barang anda';

  @override
  String get batchNothingSavedBody => 'Tiada yang disimpan.';

  @override
  String get batchFindingPiecesFailedBody => 'Pencarian barang gagal.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Pencarian barang dihenti lebih awal.';

  @override
  String get batchStopFindingPiecesTitle => 'Hentikan pencarian barang?';

  @override
  String get batchStopFindingPiecesBody =>
      'Pemindai berhenti dan tiada yang disimpan. Barang yang ditemui kekal dalam aktiviti anda sehingga dibuang.';

  @override
  String get batchKeepGoingAction => 'Teruskan';

  @override
  String get batchTryAgainAction => 'Cuba lagi';

  @override
  String get batchBackToPhotosAction => 'Kembali ke gambar';

  @override
  String get batchSkipAllAction => 'Lewati semua';

  @override
  String get batchIncludeAllAction => 'Sertakan semua';

  @override
  String get batchNoPiecesFoundTitle => 'Tiada item ditemui';

  @override
  String get batchNoPiecesFoundBody =>
      'Tiada pakaian ditemui dalam foto-foto ini.';

  @override
  String get batchChooseOtherPhotosAction => 'Pilih foto lain';

  @override
  String get batchUseCaseHelper => 'Ditambah ke setiap item yang disimpan.';

  @override
  String get batchDiscardPiecesTitle => 'Buang item ini?';

  @override
  String get batchDiscardPiecesBody => 'Tiada apa-apa dari batch ini disimpan.';

  @override
  String get batchKeepAction => 'Simpan';

  @override
  String get batchDiscardAction => 'Buang';

  @override
  String get batchRemovePieceTitle => 'Buang item ini?';

  @override
  String get batchRemovePieceBody => 'Ia tidak disimpan ke almari anda.';

  @override
  String get batchRemoveAction => 'Buang';

  @override
  String get batchChoosePiecesToSave => 'Pilih item untuk disimpan';

  @override
  String get batchDiscardAllAction => 'Buang semua';

  @override
  String get batchNothingSavedRetryBody => 'Tiada apa-apa disimpan. Cuba lagi.';

  @override
  String get batchNotSavedTitle => 'Tidak disimpan';

  @override
  String get batchSavingLabel => 'Sedang menyimpan';

  @override
  String get batchSendToBackgroundAction => 'Hantar ke latar belakang';

  @override
  String get batchStillWorkingMessage =>
      'Masih dalam proses. Kami akan maklumkan anda apabila item anda siap.';

  @override
  String get batchRunningInBackgroundTitle => 'Berjalan di latar belakang';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Foto studio dihenti awal. Anda masih boleh menyimpan item ini.';

  @override
  String get batchTapPieceToSkip => 'Ketik item untuk skit.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Foto studio masih dalam perjalanan. Anda boleh pergi — kami akan maklumkan anda.';

  @override
  String get batchLeaveAction => 'Keluar';

  @override
  String get batchPeopleInPhotosTitle => 'Orang dalam foto';

  @override
  String get batchIncludeAction => 'Sertakan';

  @override
  String get batchSkipAction => 'Skit';

  @override
  String get batchYourPhotoIsUsedLabel => 'Foto anda digunakan';

  @override
  String get batchMakingStudioPhotoLabel => 'Sedang buat foto studio';

  @override
  String get batchNoStudioPhotoBody =>
      'Tiada foto studio. Foto anda digunakan.';

  @override
  String get batchEnterDetailsYourselfAction => 'Isikan terperinci sendiri';

  @override
  String get batchChooseAnotherPhotoAction => 'Pilih foto lain';

  @override
  String get batchConnectionLostTitle => 'Sambungan terputus';

  @override
  String get batchConnectionLostBody => 'Semak sambungan anda, cuba lagi.';

  @override
  String get batchDailyLimitTitle => 'Had harian dicapai';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Naik taraf kepada Pro untuk lebih banyak imbasan, atau isikan terperinci sendiri.';

  @override
  String get batchDailyLimitBodyFree =>
      'Imbasan anda direset esok. Anda boleh isikan terperinci sendiri sekarang.';

  @override
  String get batchSeePlansAction => 'Lihat pakej';

  @override
  String get batchAiBusyTitle => 'AI kami sibuk';

  @override
  String get batchAiBusyBody =>
      'Ini di pihak kami. Cuba lagi dalam beberapa minit.';

  @override
  String get batchNoPiecesBody =>
      'Cuba foto yang lebih jelas, atau isikan terperinci sendiri.';

  @override
  String get batchScanningUnavailableTitle => 'Imbasan tidak tersedia';

  @override
  String get batchScanningUnavailableBody =>
      'Isikan terperinci sendiri buat masa ini.';

  @override
  String get batchScanDidNotFinishTitle => 'Imbasan tidak selesai';

  @override
  String get batchTryAgainBody => 'Cuba lagi.';

  @override
  String get billingTitle => 'Langganan';

  @override
  String get billingUpgradeHeading => 'Naik taraf pakej anda';

  @override
  String get billingUpgradeOnPlusBody => 'Ciri sama, had lebih tinggi.';

  @override
  String get billingUpgradeBody =>
      'Plus dan Pro mempunyai ciri yang sama. Pilih had yang anda perlukan.';

  @override
  String get billingWebUnavailableBody =>
      'Naik taraf dalam talian belum tersedia. Kod promosi atau rujukan masih membuka Plus atau Pro. Jemput rakan di bawah untuk dapatkan bulan percuma.';

  @override
  String get billingPlansStale =>
      'Gagal memuatkan pakej terkini. Harga mungkin tidak terkini.';

  @override
  String get billingMonthly => 'Bulanan';

  @override
  String get billingYearly => 'Tahunan';

  @override
  String get billingCurrentPlan => 'Pakej semasa';

  @override
  String get billingActive => 'Aktif';

  @override
  String get billingThisMonth => 'Bulan ini';

  @override
  String get billingItemExtractions => 'Ekstraksi item';

  @override
  String get billingOutfitVisualizations => 'Pvisualisasian set baju';

  @override
  String get billingNearLimitUpgrade =>
      'Anda hampir mencecah had bulan ini. Naik taraf untuk lebih banyak.';

  @override
  String get billingNearLimitResets =>
      'Anda hampir mencecah had bulan ini. Ia direset pada awal bulan hadapan.';

  @override
  String get billingStoreUnavailable =>
      'Naik taraf belum tersedia di kedai. Sila semak nanti.';

  @override
  String get billingManageHeading => 'Uruskan pakej anda';

  @override
  String get billingCancelPlan => 'Batalkan langganan';

  @override
  String get billingCancelKeepsAccess =>
      'Anda terus mendapat akses sehingga akhir tempoh penagihan ini.';

  @override
  String get billingCancelConfirmTitle => 'Batalkan langganan anda?';

  @override
  String get billingKeepPlan => 'Pertahankan pakej';

  @override
  String get billingCancelPlanAction => 'Batalkan pakej';

  @override
  String get billingBilledMonthly => 'Ditagih sebulan';

  @override
  String get billingBilledYearly => 'Ditagih setahun';

  @override
  String get billingVirtualTryOn => 'Cuba pakai maya';

  @override
  String get billingPrioritySupport => 'Sokongan keutamaan';

  @override
  String get billingDisclosureProRenewing =>
      'Pro ialah langganan auto-sambungan';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus dan Pro ialah langganan auto-sambungan';

  @override
  String get billingDisclosureAppleBilling =>
      'Pembayaran ditolak dari Apple ID anda semasa pengesahan pembelian.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Pembayaran ditolak dari akaun Google Play anda semasa pengesahan pembelian.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Langganan anda sambung automatik untuk tempoh yang sama pada harga yang sama kecuali anda matikan auto-sambungan sekurang-kurangnya 24 jam sebelum tempoh sekarang tamat.';

  @override
  String get billingDisclosureAppleManage =>
      'Urus atau batalkan pada bila-bila masa dalam Tetapan › Apple ID anda › Langganan.';

  @override
  String get billingDisclosureGoogleManage =>
      'Urus atau batalkan pada bila-bila masa dalam Google Play › Pembayaran dan langganan.';

  @override
  String get billingReferFriend => 'Rujuk rakan';

  @override
  String get billingHowItWorks => 'Bagaimana ia berfungsi';

  @override
  String get billingHowShareTitle => 'Kongsi pautan anda';

  @override
  String get billingHowShareBody => 'Hantar kepada rakan anda.';

  @override
  String get billingHowSignUpTitle => 'Mereka daftar';

  @override
  String get billingHowSignUpBody =>
      'Rakan anda menyertai melalui pautan tersebut.';

  @override
  String get billingHowBothTitle => 'Kedua-dua kamu dapat Pro';

  @override
  String get billingHowBothBody => 'Setiap kamu dapat bulan Pro percuma.';

  @override
  String get billingYourReferrals => 'Rujukan anda';

  @override
  String get billingInvited => 'Dijemput';

  @override
  String get billingJoined => 'Bergabung';

  @override
  String get billingMonthsEarned => 'Bulan diperoleh';

  @override
  String get billingInviteFriend => 'Jemput rakan';

  @override
  String get billingInviteBody =>
      'Anda dan rakan anda masing-masing dapat bulan Pro.';

  @override
  String get billingYourCode => 'Kod anda';

  @override
  String get billingCopyLink => 'Salin pautan';

  @override
  String get billingShareInvite => 'Kongsi jemputan';

  @override
  String get giftUnavailable =>
      'Jemputan hadiah tidak tersedia dalam binaan ini.';

  @override
  String get giftPageTitle => 'Hadiah FitCheck Pro';

  @override
  String get giftNoAllowances => 'Tiada jemputan hadiah percuma sekarang.';

  @override
  String get giftFormTitle => 'Hantar jemputan percuma';

  @override
  String get giftFormBody =>
      'Penerima anda menuntut hadiah dengan e-mel berpenyemakan ini. Kami tidak hantar e-mel untuk anda.';

  @override
  String get giftFieldFrom => 'Dari';

  @override
  String get giftFieldRecipientName => 'Nama penerima';

  @override
  String get giftFieldRecipientEmail => 'E-mel penerima';

  @override
  String get giftFieldOccasion => 'Masa (pilihan)';

  @override
  String get giftNoOccasion => 'Tiada masa';

  @override
  String get giftOccasionBirthday => 'Hari jadi';

  @override
  String get giftOccasionAnniversary => 'Ulang tahun';

  @override
  String get giftOccasionOther => 'Lain';

  @override
  String get giftFieldCardGreeting => 'Salam kad';

  @override
  String get giftFieldCardGreetingHelper =>
      'Ini muncul pada kad tepat seperti ditulis.';

  @override
  String get giftFieldPrivateNote => 'Nota peribadi (pilihan)';

  @override
  String get giftCreateAction => 'Cipta hadiah percuma';

  @override
  String get giftClaimedTitle => 'Hadiah telah dituntut';

  @override
  String get giftClaimedActive => 'Hadiah FitCheck Pro anda aktif.';

  @override
  String get giftClaimedQueued =>
      'Hadiah FitCheck Pro anda bermula selepas akses semasa anda.';

  @override
  String get giftLinkCopied => 'Pautan hadiah disalin ke papan kerat.';

  @override
  String get giftErrorName => 'Masukkan nama.';

  @override
  String get giftErrorEmail => 'Masukkan alamat e-mel yang sah.';

  @override
  String get giftErrorGreeting => 'Masukkan salam kad.';

  @override
  String get giftErrorGreetingLength => 'Guna tidak melebihi 80 aksara.';

  @override
  String get giftClaimAction => 'Ambil hadiah';

  @override
  String get giftCardPreview => 'Pratonton kad';

  @override
  String get giftGiftForYou => 'Hadiah untuk anda';

  @override
  String get giftGiftWaiting => 'Terdapat hadiah untuk anda';

  @override
  String get giftOpenBody =>
      'Buka hadiah untuk mengemukakannya dengan e-mel berlesen anda.';

  @override
  String get giftOpenGifts => 'Buka hadiah';

  @override
  String get giftSendInvitation => 'Hantar jemputan';

  @override
  String get settingsAiProviderSection => 'Pembekal';

  @override
  String get settingsAiCustom => 'Kustom';

  @override
  String get settingsAiUrlHelper =>
      'Guna URL awam yang dapat dicapai oleh pelayan. Localhost tidak berfungsi dari pelayan kami.';

  @override
  String get settingsAiConnectionSection => 'Sambungan';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'Kunci API';

  @override
  String get settingsAiApiKeySaved =>
      'Disimpan. Biarkan kosong untuk kekalkannya.';

  @override
  String get settingsAiChatModel => 'Model perbualan';

  @override
  String get settingsAiVisionModel => 'Model penglihatan (pilihan)';

  @override
  String get settingsAiImageModel => 'Model imej (pilihan)';

  @override
  String get settingsAiImageModelNote =>
      'Janaan imej memerlukan pelengkap perbualan seragam OpenAI dengan response_modalities.';

  @override
  String get settingsAiTestConnection => 'Uji sambungan';

  @override
  String get calendarTitle => 'Kalendar';

  @override
  String get calendarGoToToday => 'Pergi ke hari ini';

  @override
  String get calendarConnectTooltip => 'Sambung kalendar';

  @override
  String get calendarAddEvent => 'Tambah acara';

  @override
  String get calendarEmptyTitle => 'Tiada perancangan';

  @override
  String get calendarEmptyBody =>
      'Tambah acara dan rancang apa yang hendak dipakai.';

  @override
  String get calendarPreviousMonth => 'Bulan lalu';

  @override
  String get calendarNextMonth => 'Bulan hadapan';

  @override
  String get calendarAllDay => 'Sepanjang hari';

  @override
  String get calendarOutfitLinked => 'Pakaian dikaitkan';

  @override
  String get calendarEventOptions => 'Pilihan acara';

  @override
  String get calendarDeleteTitle => 'Hapus acara ini?';

  @override
  String get calendarChangeOutfit => 'Ganti busana';

  @override
  String get calendarLinkOutfit => 'Pautkan busana';

  @override
  String get calendarRemoveOutfit => 'Tanggalkan busana';

  @override
  String get calendarNewEvent => 'Acara baharu';

  @override
  String get calendarEditEvent => 'Ubah acara';

  @override
  String get calendarTitleLabel => 'Tajuk';

  @override
  String get calendarTitleRequired => 'Tajuk diperlukan';

  @override
  String get calendarEndBeforeStart => 'Akhiri selepas waktu mula';

  @override
  String get calendarStarts => 'Mula';

  @override
  String get calendarEnds => 'Akhir';

  @override
  String get calendarPlaceOptional => 'Lokasi (pilihan)';

  @override
  String get calendarNotesOptional => 'Nota (pilihan)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Susun busana, kemudian pautkan dengan acara ini.';

  @override
  String get calendarBuildOutfit => 'Susun busana';

  @override
  String get calendarConnectionsTitle => 'Kalendar';

  @override
  String get calendarConnectionsBody =>
      'Acara yang ditambah kekal dalam FitCheck.';

  @override
  String get calendarDisconnect => 'Putuskan';

  @override
  String get calendarNotAvailable => 'Belum tersedia';

  @override
  String get profileSectionExplore => 'Terokai';

  @override
  String get profileNavTryOn => 'Cuba';

  @override
  String get profileNavRewards => 'Baucar';

  @override
  String get profileSupport => 'Sokongan';

  @override
  String get profileHelp => 'Bantuan';

  @override
  String get profileAbout => 'Mengenai';

  @override
  String get profileAboutBody =>
      'Pakaian, busana dan rancangan anda dalam satu tempat.';

  @override
  String get profileSignOutTitle => 'Log keluar?';

  @override
  String get profileSignOutBody =>
      'Anda boleh log masuk semula bila-bila masa.';

  @override
  String get profileEditTitle => 'Ubah profil';

  @override
  String get profileYourProfile => 'Profil anda';

  @override
  String get profileBodyProfiles => 'Profil badan';

  @override
  String get profileBodyEmptyTitle => 'Belum ada profil badan';

  @override
  String get profileBodyEmptyBody =>
      'Tambah ketinggian dan bentuk badan untuk padanan yang lebih tepat.';

  @override
  String get profileBodyAdd => 'Tambah profil';

  @override
  String get profileBodyDefaultNote =>
      'Profil default digunakan untuk padanan dan cubaan baju.';

  @override
  String get profileBodyDefaultBadge => 'Lalai';

  @override
  String get profileBodyMakeDefault => 'Jadikan lalai';

  @override
  String get profileBodyDeleteBody => 'Anda tidak boleh membuat asal.';

  @override
  String get profileBodyRequired => 'Wajib';

  @override
  String get profileBodyCheckNumber => 'Semak nombor ini';

  @override
  String get profileBodyNew => 'Profil badan baharu';

  @override
  String get profileBodyNameHint => 'Contohnya, Saya';

  @override
  String get profileBodyHeight => 'Ketinggian';

  @override
  String get profileBodyWeight => 'Berat';

  @override
  String get profileBodyBuild => 'Bentuk badan';

  @override
  String get profileBodySkinTone => 'Nada kulit';

  @override
  String get profileBirthDateNeededBody =>
      'Tambah tarikh lahir untuk dipadankan dengan waktu lahir.';

  @override
  String get profileBirthDateNeededTitle => 'Tarikh lahir diperlukan';

  @override
  String get profilePartlySavedBody =>
      'Kami menyimpan nama dan foto anda. Butiran lahir tidak disimpan; cuba kemudian.';

  @override
  String get profilePartlySavedTitle => 'Sebahagian disimpan';

  @override
  String get profileSavedBody => 'Profil anda disimpan.';

  @override
  String get profileChangePhoto => 'Tukar foto profil';

  @override
  String get profilePhotoLabel => 'Foto profil';

  @override
  String get profilePhotoHint => 'Ketuk untuk memilih yang baharu';

  @override
  String get profileBirthDateLabel => 'Tarikh lahir (pilihan)';

  @override
  String get profileBirthTimeLabel => 'Waktu lahir (pilihan)';

  @override
  String get profileBirthTimeHelper => 'Menjadikan cadangan Vedik lebih tepat';

  @override
  String get profileBirthPlaceLabel => 'Tempat lahir (pilihan)';

  @override
  String get profileBirthPlaceHint => 'Contohnya, New Delhi, India';

  @override
  String get profileHelpContactTitle => 'Tanya kami apa sahaja';

  @override
  String get profileHelpContactBody =>
      'Hantar mesej dan kami akan membalas melalui e-mel, biasanya dalam masa sehari.';

  @override
  String get profileHelpContactAction => 'Hubungi sokongan';

  @override
  String get profileHelpFaqTitle => 'Soalan lazim';

  @override
  String get profileFaqAddPiecesTitle =>
      'Bagaimanakah saya boleh menambah barang ke almari saya?';

  @override
  String get profileFaqAddPiecesBody =>
      'Ketik Tambah item pada tab Almari. Ambil foto atau pilih dari galeri anda; kami akan mencari setiap barang dan menandakannya untuk anda.';

  @override
  String get profileFaqMatchingTitle =>
      'Bagaimanakah padanan busana berfungsi?';

  @override
  String get profileFaqMatchingBody =>
      'Buka Untuk anda dan pilih barang yang anda miliki. Kami mencadangkan apa yang sesuai dan membina busana lengkap daripada almari anda.';

  @override
  String get profileFaqTryOnTitle =>
      'Bolehkah saya menggunakan foto saya sendiri untuk cuba pakai?';

  @override
  String get profileFaqTryOnBody =>
      'Ya. Tambah foto badan penuh diri anda, kemudian pilih barang untuk melihatnya pada diri anda.';

  @override
  String get profileFaqRewardsTitle =>
      'Bagaimanakah saya boleh mendapatkan ganjaran?';

  @override
  String get profileFaqRewardsBody =>
      'Rancang dan log busana kerap kali. Rekod dan pencapaian akan terkumpul seiring masa.';

  @override
  String get profileFaqPrivacyTitle => 'Adakah almari saya sulit?';

  @override
  String get profileFaqPrivacyBody =>
      'Ya. Almari dan busana anda adalah sulit melainkan anda berkongsi pautan untuk satu busana.';

  @override
  String get profileHelpMoreTitle => 'Lagi bantuan';

  @override
  String get profileHelpGuides => 'Panduan';

  @override
  String get profileHelpGuidesBody => 'Bagaimana setiap ciri berfungsi';

  @override
  String get feedbackCategoryBug => 'Sesuatu rosak';

  @override
  String get feedbackCategoryIdea => 'Sebuah idea';

  @override
  String get feedbackCategoryGeneral => 'Am';

  @override
  String get feedbackCategoryHelp => 'Saya perlukan bantuan';

  @override
  String get feedbackHintBug =>
      'Apa yang berlaku, dan apa yang anda jangkakan? Langkah-langkah membantu kami membaikinya.';

  @override
  String get feedbackHintIdea => 'Apa yang anda mahukan, dan mengapa?';

  @override
  String get feedbackHintGeneral =>
      'Katakan kepada kami apa pendapat anda, atau ajukan soalan.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Anda boleh menambah sehingga 5 imej.';

  @override
  String get feedbackAttachmentLimitTitle => 'Had dicapai';

  @override
  String get feedbackImageTooLargeBody => 'Pilih imej di bawah 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imej terlalu besar';

  @override
  String get feedbackTitle => 'Hantar maklumbalasan';

  @override
  String get feedbackAboutLabel => 'Tentang apa?';

  @override
  String get feedbackSubjectLabel => 'Subjek';

  @override
  String get feedbackSubjectRequired => 'Tambah subjek';

  @override
  String get feedbackSubjectTooShort =>
      'Subjek mesti sekurang-kurangnya 3 aksara';

  @override
  String get feedbackDetailsLabel => 'Butiran';

  @override
  String get feedbackDetailsRequired => 'Tambah beberapa butiran';

  @override
  String get feedbackDetailsTooShort =>
      'Penerangan mesti sekurang-kurangnya 10 aksara';

  @override
  String get feedbackAddScreenshot => 'Tambah tangkap skrin';

  @override
  String get feedbackAttachmentHint => 'Maks 5, 5 MB setiap satu';

  @override
  String get feedbackSend => 'Hantar';

  @override
  String get feedbackEmptyTitle => 'Belum ada yang dihantar';

  @override
  String get feedbackEmptyBody =>
      'Apa yang dihantar kelihatan di sini beserta statusnya.';

  @override
  String get feedbackHistoryTitle => 'Apa yang dihantar';

  @override
  String get feedbackStatusOpen => 'Dibuka';

  @override
  String get feedbackStatusInProgress => 'Sedang diproses';

  @override
  String get feedbackStatusResolved => 'Diselesaikan';

  @override
  String get feedbackStatusClosed => 'Ditutup';

  @override
  String get legalIntro =>
      'Cara kami melindungi data anda dan terma penggunaan FitCheck AI.';

  @override
  String get legalPolicies => 'Dasar';

  @override
  String get legalPrivacySubtitle => 'Apa yang dikumpul dan mengapa';

  @override
  String get legalTermsTitle => 'Terma perkhidmatan';

  @override
  String get legalTermsSubtitle => 'Aturan penggunaan aplikasi';

  @override
  String get legalLicences => 'Lesen sumber terbuka';

  @override
  String get legalSupportSubtitle => 'Bantuan, kontak dan permintaan privasi';

  @override
  String get legalReportAbuse => 'Laporkan masalah atau penyalahgunaan';

  @override
  String get permissionCameraTitle => 'Akses Kamera';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI menggunakan kamera anda untuk merakam foto pakaian dan gaya untuk cubaan AI dan pengurusan almari.';

  @override
  String get permissionPhotoTitle => 'Akses Foto';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI perlu akses kepada foto anda supaya anda boleh memilih imej pakaian dan gaya untuk ciri AI dan almari anda.';

  @override
  String get permissionNotNow => 'Belum';

  @override
  String get permissionOpenSettings => 'Buka Tetapan';

  @override
  String authSignedInAs(String name) {
    return 'Didaftarkan sebagai $name';
  }

  @override
  String get authSignedIn => 'Telah log masuk';

  @override
  String get authWelcomeBackTitle => 'Selamat kembali';

  @override
  String get authSignInFailed => 'Log masuk gagal';

  @override
  String get authWelcomeTitle => 'Selamat datang';

  @override
  String get authSignUpFailed => 'Daftar akaun gagal';

  @override
  String get authGoogleSignInFailed => 'Log masuk Google gagal';

  @override
  String get authAppleSignInFailed => 'Log masuk Apple gagal';

  @override
  String get authConfirmEmailTitle => 'Sahkan e-mel anda';

  @override
  String get authConfirmEmailBody =>
      'Semak peti masuk anda untuk e-mel pengesahan, kemudian log masuk.';

  @override
  String get authClosetReady => 'Pawagam anda sedia.';

  @override
  String get authSignedOutTitle => 'Telah log keluar';

  @override
  String get authSignedOutBody => 'Anda telah log keluar.';

  @override
  String get authSignOutFailed => 'Log keluar gagal';

  @override
  String get authEmailSentTitle => 'E-mel dihantar';

  @override
  String get authResetLinkSent =>
      'Semak e-mel anda untuk pautan tetapan semula.';

  @override
  String get authPasswordUpdatedTitle => 'Kata laluan dikemas kini';

  @override
  String get authPasswordUpdated => 'Kata laluan anda telah dikemas kini.';

  @override
  String get authPasswordNotUpdated => 'Kata laluan tidak dikemas kini';

  @override
  String get authCouldNotSendEmail => 'Tidak dapat hantar e-mel';

  @override
  String get authEmailNotSent => 'E-mel tidak dihantar';

  @override
  String get authResendSentBody =>
      'Kami telah menghantar e-mel pengesahan baharu.';

  @override
  String get outfitPreviewWithAi => 'Pratonton dengan AI';

  @override
  String get outfitNewPreview => 'Buat pratonton baharu';

  @override
  String get outfitBuilderClosetHeading => 'Pawagam anda';

  @override
  String get outfitBuilderSearchHint => 'Cari barang';

  @override
  String get outfitClearSearch => 'Kosongkan carian';

  @override
  String get outfitBuilderAddPiecesTitle => 'Tambah barang dahulu';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfit dijana daripada barang dalam pawagam anda.';

  @override
  String get outfitBuilderNoMatches => 'Tiada barang sepadan.';

  @override
  String get outfitNameLabel => 'Nama outfit';

  @override
  String get outfitNameHint => 'Contoh: Weekend linen';

  @override
  String get outfitPreviewSemantic => 'Pratonton AI bagi busana';

  @override
  String get outfitChoosePieces => 'Pilih item';

  @override
  String get outfitTapPiecesHint => 'Ketik item di bawah untuk menambahkannya.';

  @override
  String get outfitShareTooltip => 'Kongsi';

  @override
  String get outfitSaveFavourite => 'Simpan ke kegemaran';

  @override
  String get outfitPiecesHeading => 'Item';

  @override
  String get outfitWearHistoryEmpty =>
      'Pakainya sekali dan tarikh akan muncul di sini.';

  @override
  String get outfitWearHistoryTitle => 'Sejarah pemakaian';

  @override
  String get outfitWearHistoryError => 'Tidak dapat memuatkan tarikh.';

  @override
  String get outfitWornOn => 'Dipakai pada';

  @override
  String get outfitEditTitle => 'Sunting busana';

  @override
  String get outfitSavedPhotosFailed => 'Butiran disimpan, gambar tidak';

  @override
  String get outfitNoPhotosBody =>
      'Belum ada gambar. Busana ini akan memaparkan itemnya.';

  @override
  String get outfitOccasionLabel => 'Peluang';

  @override
  String get outfitOccasionNone => 'Tiada';

  @override
  String get outfitTagsHint => 'Pisahkan dengan koma';

  @override
  String get outfitDraftBody => 'Disembunyikan daripada senarai utama';

  @override
  String get outfitPublic => 'Awam';

  @override
  String get outfitPublicBody => 'Siapa sahaja dengan pautan boleh melihatnya';

  @override
  String get outfitDeleteFromDetail =>
      'Padam busana ini daripada halaman butiran.';

  @override
  String get outfitNewCollection => 'Koleksi baharu';

  @override
  String get outfitNoCollectionsTitle => 'Belum ada koleksi';

  @override
  String get outfitNoCollectionsBody =>
      'Kumpulan busana mengikut perjalanan, musim atau suasana.';

  @override
  String get outfitCreateCollection => 'Cipta koleksi';

  @override
  String get outfitAddOutfits => 'Tambah busana';

  @override
  String get outfitRename => 'Ganti nama';

  @override
  String get outfitCollectionDeleteBody => 'Busana di dalamnya akan disimpan.';

  @override
  String get outfitCollectionsNotLoaded => 'Busana tidak dimuatkan';

  @override
  String get outfitRenameCollection => 'Ganti nama koleksi';

  @override
  String get outfitDescriptionOptional => 'Penerangan (pilihan)';

  @override
  String get outfitAllInCollection => 'Setiap gaya sudah dalam koleksi ini.';

  @override
  String get photoshootSubtitleUpload => 'Potret studio daripada foto anda';

  @override
  String get photoshootSubtitleConfigure => 'Pilih gaya, format dan bilangan';

  @override
  String get photoshootSubtitleGenerating =>
      'Ini mengambil masa satu dua minit';

  @override
  String get photoshootAddPhotosSemantic => 'Tambah foto dari galeri anda';

  @override
  String get photoshootUploadTitle => 'Tambah 1 hingga 4 foto anda';

  @override
  String get photoshootUploadBody => 'Ketik untuk pilih dari galeri anda';

  @override
  String get photoshootAddToContinue => 'Tambah foto untuk teruskan';

  @override
  String get photoshootAddAnotherPhoto => 'Tambah foto lain';

  @override
  String get photoshootTipsTitle => 'Untuk hasil terbaik';

  @override
  String get photoshootTipsBody =>
      'Gunakan foto wajah yang jelas, terang dan dari beberapa sudut. Elak cermin mata dan topi.';

  @override
  String get photoshootStarting => 'Mula';

  @override
  String get photoshootCancelling => 'Membatalkan';

  @override
  String get photoshootFailed => 'Gagal';

  @override
  String get recommendTabMatches => 'Padanan';

  @override
  String get recommendTabComplete => 'Lengkap';

  @override
  String get recommendTabWeather => 'Cuaca';

  @override
  String get recommendTabColours => 'Warna';

  @override
  String get recommendTabShop => 'Beli-belah';

  @override
  String get recommendNoMatchesTitle => 'Belum ada padanan';

  @override
  String get recommendNoMatchesBody =>
      'Pilih satu item dan kami akan cari yang serasi.';

  @override
  String get recommendPickPiece => 'Pilih item';

  @override
  String get recommendNothingMatchesTitle => 'Tiada yang serasi lagi';

  @override
  String get recommendNothingMatchesBody =>
      'Cuba item lain, atau tambah lagi ke almari anda.';

  @override
  String get recommendChangePieces => 'Tukar item';

  @override
  String get recommendDefaultReason => 'Ia sesuai dengan item yang dipilih.';

  @override
  String get recommendCompleteTitle => 'Lengkapi gaya';

  @override
  String get recommendCompleteBody =>
      'Pilih satu item dan kami akan melengkapkan baki.';

  @override
  String get recommendWorking => 'Sedang memproses';

  @override
  String get recommendGenerate => 'Jana';

  @override
  String get recommendChooseStyleBody => 'Pilih gaya, kemudian jana.';

  @override
  String get recommendNoLooksTitle => 'Tiada look untuk item ini';

  @override
  String get recommendNoLooksBody => 'Cuba gaya atau item lain.';

  @override
  String get recommendDefaultLook => 'Look untuk item anda';

  @override
  String get recommendNoPiecesBody =>
      'Tiada item yang diperoleh untuk look ini.';

  @override
  String get recommendCityLabel => 'Bandar';

  @override
  String get recommendCheck => 'Semak';

  @override
  String get recommendWeatherTitle => 'Cuaca macam mana?';

  @override
  String get recommendWeatherBody =>
      'Isih bandar anda untuk dapatkan pilihan hari ini.';

  @override
  String get recommendWearToday => 'Pakai hari ini';

  @override
  String get recommendWeatherNoPieces =>
      'Tiada item dalam almari anda untuk cuaca ini lagi.';

  @override
  String get recommendBudgetLabel => 'Bajet sehingga';

  @override
  String get recommendLooking => 'Mencari';

  @override
  String get recommendFindWhatToBuy => 'Cari apa untuk dibeli';

  @override
  String get recommendFillGapsTitle => 'Isi celah';

  @override
  String get recommendFillGapsBody =>
      'Tetapkan bajet dan kami akan cadangkan apa yang tiada dalam almari anda.';

  @override
  String get recommendNoGapsTitle => 'Tiada celah ditemui';

  @override
  String get recommendNoGapsBody =>
      'Cuba bajet lebih besar atau kategori lain.';

  @override
  String get recommendMoodEveryday => 'Seharian';

  @override
  String get recommendMoodBigMeeting => 'Mesyuarat besar';

  @override
  String get recommendDayLabel => 'Hari';

  @override
  String get recommendReadingStars => 'Baca bintang';

  @override
  String get recommendGetMyColours => 'Dapatkan warna saya';

  @override
  String get recommendLuckyColoursTitle => 'Warna hoki anda';

  @override
  String get recommendLuckyColoursBody =>
      'Pilih hari dan kami akan cadangkan warna serta item untuk hari itu.';

  @override
  String get recommendLuckyColoursSection => 'Warna hoki';

  @override
  String get recommendAvoidColoursSection => 'Warna perlu elak';

  @override
  String get recommendBirthDateTitle => 'Tambah tarikh lahir anda';

  @override
  String get recommendBirthDateBody =>
      'Kami perlukan tarikh lahir anda untuk baca warna anda.';

  @override
  String get recommendEditProfile => 'Edit profil';

  @override
  String get recommendNothingThisDay => 'Tiada untuk hari ini.';

  @override
  String get recommendUnnamedColour => 'Warna tanpa nama';

  @override
  String get recommendFromCloset => 'Dari almari anda';

  @override
  String get recommendNoPiecesInColours => 'Tiada item dalam warna ini lagi.';

  @override
  String get recommendOutfitIdeas => 'Cadangan fesyen';

  @override
  String get recommendNoOutfitsInColours =>
      'Tiada fesyen lengkap dalam warna ini lagi.';

  @override
  String get recommendDefaultOutfitIdea => 'Satu idea fesyen';

  @override
  String get recommendPickUpToThree => 'Pilih sehingga tiga item';

  @override
  String get recommendEmptyClosetBody =>
      'Tambah beberapa item dahulu, kemudian kembali untuk padanan.';

  @override
  String get dashboardDressForDay => 'Berasa untuk hari seterusnya.';

  @override
  String get dashboardOutfitOfDay => 'Fesyen hari ini';

  @override
  String get dashboardFreshLook => 'Penampilan baru';

  @override
  String get subscriptionManageInStoreTitle => 'Urus dalam kedai';

  @override
  String get subscriptionManageInStoreBody =>
      'Pelan ini dibebankan melalui kedai. Uruskan dalam tetapan akaun kedai anda.';

  @override
  String get subscriptionCancelledTitle => 'Langganan dibatalkan';

  @override
  String get subscriptionCancelledBody =>
      'Pelan anda kekal aktif sehingga akhir tempoh penagihan ini.';

  @override
  String get subscriptionCancelFailedTitle => 'Tidak dapat membatalkan';

  @override
  String get subscriptionCouldNotOpenTitle => 'Tidak dapat membuka';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Tidak dapat membuka pengurusan penagihan.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Tidak dapat membuka pautan.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Tidak dapat memuatkan pautan anda';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Tidak dapat memuatkan pautan rujukan anda. Cuba lagi.';

  @override
  String get subscriptionReferralCopiedTitle => 'Disalin';

  @override
  String get subscriptionReferralCopiedBody => 'Pautan rujukan disalin.';

  @override
  String get subscriptionReferralShareSubject => 'Cuba FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Sertai FitCheck AI dan kami berdua dapat bulan Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Pautan disalin';

  @override
  String get subscriptionShareUnavailableBody =>
      'Penyongsangan tidak tersedia, maka pautan telah disalin.';

  @override
  String get subscriptionShareFailedTitle => 'Tidak dapat berkongsi';

  @override
  String get subscriptionShareFailedBody =>
      'Salin pautan daripada halaman rujukan.';

  @override
  String get subscriptionStoreReadyTitle => 'Toko sedia';

  @override
  String get subscriptionStoreReadyBody =>
      'Harga toko tersedia. Anda boleh naik taraf sekarang.';

  @override
  String get purchaseFailedTitle => 'Pembayaran gagal';

  @override
  String get purchaseUnavailableTitle => 'Pembayaran tidak tersedia';

  @override
  String get purchaseIapUnavailableBody =>
      'Pembelian dalam aplikasi tidak tersedia pada peranti ini.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Pelan ini belum tersedia untuk pembelian.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Pelan ini belum tersedia di toko. Sila semak sebentar lagi.';

  @override
  String get purchaseStartFailedBody =>
      'Pembayaran tidak dapat dimulakan. Cuba lagi.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Rakan niaga tidak mengembalikan pautan pembayaran.';

  @override
  String get purchasePendingTitle => 'Pembayaran tertangguh';

  @override
  String get purchasePendingBody =>
      'Pembayaran anda sedang menunggu kelulusan. Anda akan mendapat akses sebaik sahaja diluluskan.';

  @override
  String get purchaseFailedBody => 'Pembayaran gagal. Cuba lagi.';

  @override
  String get purchaseRestoredTitle => 'Dipulihkan';

  @override
  String get purchaseRestoredBody => 'Pembelian anda telah dipulihkan.';

  @override
  String get purchaseActiveTitle => 'Langganan aktif';

  @override
  String get purchaseActiveBody => 'Langganan anda aktif. Selamat datang.';

  @override
  String get purchaseSignInRequiredTitle => 'Sila masuk diperlukan';

  @override
  String get purchaseSignInRequiredBody =>
      'Sila masuk untuk melengkapkan pembayaran anda.';

  @override
  String get purchaseErrorTitle => 'Ralat pembayaran';

  @override
  String get purchaseInvalidTransactionBody =>
      'Pembayaran tidak termasuk ID transaksi yang boleh disahkan.';

  @override
  String get purchaseVerificationPendingTitle => 'Pengesahan tertangguh';

  @override
  String get purchaseVerificationPendingBody =>
      'Kami tidak dapat mengesahkan pembayaran anda dengan toko buat masa ini. Ia akan selesai secara automatik, dan anda tidak akan dikenakan bayaran dua kali.';

  @override
  String get purchaseNotAppliedTitle => 'Pembayaran tidak digunakan';

  @override
  String get purchaseNotAppliedBody =>
      'Pembayaran anda tidak dapat digunakan ke akaun anda. Hubungi sokongan, dan jangan belinya sekali lagi.';

  @override
  String get purchaseRestoreFailedTitle => 'Pemulihan gagal';

  @override
  String get purchaseRestoreFailedBody =>
      'Tidak dapat memulihkan pembelian. Cuba lagi.';

  @override
  String get purchaseRecoveredActiveBody => 'Langganan anda aktif.';

  @override
  String get purchaseCompleteTitle => 'Pembayaran selesai';

  @override
  String get giftCreateFailedTitle => 'Tidak dapat membuat hadiah';

  @override
  String get giftClaimFailedTitle => 'Gagal menuntut hadiah';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hadiah untuk anda',
      one: '1 hadiah untuk anda',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 bulan',
      '12': '1 tahun',
      'other': '$months bulan',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining baki',
      one: '1 baki',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender menghantar $duration FitCheck Pro kepada anda. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Hadiah FitCheck Pro untuk $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'Dari $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Untuk $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'Dari $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'penerima anda';

  @override
  String get giftPreviewPlaceholderSender => 'anda';

  @override
  String get settingsSavedTitle => 'Disimpan';

  @override
  String get settingsNotSavedTitle => 'Tidak disimpan';

  @override
  String get settingsAiChooseProviderBody => 'Pilih pembekal.';

  @override
  String get settingsAiCustomUrlRequiredBody => 'Pembekal suka perlu URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Masukkan kunci API.';

  @override
  String get settingsAiSavedBody => 'Tetapan AI anda disimpan.';

  @override
  String get settingsAiMissingDetailsTitle => 'Maklumat belum lengkap';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Masukkan URL API dan model sembang untuk menguji.';

  @override
  String get settingsAiKeyNeededTitle => 'Kunci API diperlukan';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Masukkan kunci API anda untuk menguji. Kunci yang disimpan kekal peribadi.';

  @override
  String get settingsAiKeyToTestBody =>
      'Masukkan kunci API anda untuk menguji.';

  @override
  String get settingsAiConnectedTitle => 'Disambungkan';

  @override
  String get settingsAiConnectedBody => 'Sambungan berfungsi.';

  @override
  String get settingsAiTestFailedTitle => 'Ujian gagal';

  @override
  String get settingsPreferencesSavedBody => 'Keutamaan anda disimpan.';

  @override
  String get settingsPasswordNotChangedTitle => 'Kata laluan tidak ditukar';

  @override
  String get settingsOAuthPasswordBody =>
      'Akaun ini log masuk dengan Google atau Apple. Gunakan \"Lupakan kata laluan\" untuk menetapkan kata laluan dahulu.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Kata laluan semasa salah.';

  @override
  String get settingsExportReadyTitle => 'Eksport siap';

  @override
  String get settingsExportReadyBody =>
      'Eksport data anda telah siap untuk dimuat turun.';

  @override
  String get settingsLinkCopiedTitle => 'Pautan disalin';

  @override
  String get settingsExportClipboardBody =>
      'Kami tidak dapat membuka pelayar anda, jadi kami menyalin pautan muat turun. Tampal dalam pelayar dengan segera: ia akan tamat tempoh.';

  @override
  String get settingsExportFailedTitle => 'Eksport gagal';

  @override
  String get settingsAccountNotDeletedTitle => 'Akaun tidak dipadam';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Anda boleh menambah sehingga $max foto.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Had foto';

  @override
  String get photoshootAddAtLeastOnePhoto =>
      'Tambah sekurang-kurangnya satu foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Tiada foto';

  @override
  String get photoshootDescribeLookBody =>
      'Tahunkan penampilan yang anda mahukan.';

  @override
  String get photoshootPromptNeededTitle => 'Perluan arah';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Menyiapkan foto anda';

  @override
  String get photoshootStatusGenerating => 'Menghasilkan';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Berkumpulan $current daripada $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done daripada $total selesai';
  }

  @override
  String get photoshootGenerationFailedBody => 'Penghasilan gagal.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready sedia, $failed gagal.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Sebahagian selesai';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto telah sedia.',
      one: '1 foto telah sedia.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Kami kehilangan sambungan. Sila cuba lagi.';

  @override
  String get photoshootCouldNotCancelTitle => 'Tidak dapat dibatalkan';

  @override
  String get photoshootRetryFailedTitle => 'Cuba lagi gagal';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Foto $number telah sedia.';
  }

  @override
  String get photoshootReplacedTitle => 'Digantikan';

  @override
  String get photoshootSavedToGalleryBody => 'Disimpan dalam galeri anda.';

  @override
  String get photoshootSavedTitle => 'Disimpan';

  @override
  String get photoshootNotSavedTitle => 'Tidak disimpan';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Semua $count foto dalam galeri anda.',
      one: '1 foto dalam galeri anda.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved daripada $total disimpan.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Sesetengah foto tidak disimpan';

  @override
  String get tryonConsentFeatureLabel => 'Cuba Virtual';

  @override
  String get tryonAvatarUpdatedBody => 'Foto anda dikemaskini.';

  @override
  String get tryonSavedTitle => 'Disimpan';

  @override
  String get tryonUploadFailedTitle => 'Muat naik gagal';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Pilih foto pakaian terlebih dahulu.';

  @override
  String get tryonNoGarmentTitle => 'Tiada pakaian';

  @override
  String get tryonWaitForUploadBody =>
      'Tunggu hingga foto selesai dimuat naik.';

  @override
  String get tryonStillUploadingTitle => 'Sedang memuat naik';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Tambahkan foto anda terlebih dahulu.';

  @override
  String get tryonReadyBody => 'Cuba virtual anda sedia.';

  @override
  String get tryonFailedTitle => 'Cuba virtual gagal';

  @override
  String get tryonSavedToGalleryBody => 'Disimpan ke galeri anda.';

  @override
  String get tryonNotSavedTitle => 'Tidak disimpan';

  @override
  String get calendarEventAddedBody => 'Acara ditambah';

  @override
  String get calendarEventPlannedTitle => 'Diberi perancangan';

  @override
  String get calendarEventSavedBody => 'Acara disimpan';

  @override
  String get calendarSavedTitle => 'Disimpan';

  @override
  String get calendarEventNotSavedTitle => 'Acara tidak disimpan';

  @override
  String get calendarEventRemovedBody => 'Acara dibuang';

  @override
  String get calendarEventDeletedTitle => 'Dihapus';

  @override
  String get calendarEventNotDeletedTitle => 'Acara tidak dihapus';

  @override
  String get calendarOutfitNotLinkedTitle => 'Padanan tidak dipautkan';

  @override
  String get calendarLinkedTitle => 'Dipautkan';

  @override
  String get calendarOutfitNotRemovedTitle => 'Padanan tidak dibuang';

  @override
  String get calendarOutfitRemovedBody => 'Padanan dibuang';

  @override
  String get calendarDisconnectedBody => 'Kalendar diputuskan';

  @override
  String get calendarDisconnectedTitle => 'Diputuskan';

  @override
  String get calendarNotDisconnectedTitle => 'Kalendar tidak diputuskan';

  @override
  String get calendarTodayLabel => 'hari ini';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count acara',
      one: '1 acara',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start ke $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, set berkaitan';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" akan dibuang.';
  }

  @override
  String get calendarThisAppLabel => 'Aplikasi ini';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Sinkron dengan $provider belum tersedia. Anda masih boleh menambah acara di sini.';
  }

  @override
  String get calendarWeekdaySunShort => 'Ahd';

  @override
  String get calendarWeekdayMonShort => 'Isn';

  @override
  String get calendarWeekdayTueShort => 'Sel';

  @override
  String get calendarWeekdayWedShort => 'Rab';

  @override
  String get calendarWeekdayThuShort => 'Kha';

  @override
  String get calendarWeekdayFriShort => 'Jum';

  @override
  String get calendarWeekdaySatShort => 'Sab';

  @override
  String get calendarWeekdayMonday => 'Isnin';

  @override
  String get calendarWeekdayTuesday => 'Selasa';

  @override
  String get calendarWeekdayWednesday => 'Rabu';

  @override
  String get calendarWeekdayThursday => 'Khamis';

  @override
  String get calendarWeekdayFriday => 'Jumaat';

  @override
  String get calendarWeekdaySaturday => 'Sabtu';

  @override
  String get calendarWeekdaySunday => 'Ahad';

  @override
  String get outfitSavedToFavouritesBody => 'Disimpan dalam kegemaran';

  @override
  String get outfitRemovedFromFavouritesBody => 'Dibuang daripada kegemaran';

  @override
  String get outfitNotSavedTitle => 'Tidak disimpan';

  @override
  String get outfitLoggedAsWornBody => 'Direkodkan dipakai hari ini.';

  @override
  String get outfitNicePickTitle => 'Pilihan hebat';

  @override
  String get outfitRemovedBody => 'Set dibuang.';

  @override
  String get outfitDeletedTitle => 'Dihapus';

  @override
  String get outfitNotDeletedTitle => 'Tidak dihapus';

  @override
  String get outfitDuplicatedBody => 'Salinan ada dalam set pakai anda.';

  @override
  String get outfitDuplicatedTitle => 'Duplikat';

  @override
  String get outfitNotDuplicatedTitle => 'Tidak duplikat';

  @override
  String get outfitNotSharedTitle => 'Tidak dikongsi';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" sedia.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Koleksi tidak dicipta';

  @override
  String get outfitCollectionUpdatedBody => 'Koleksi dikemas kini.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Koleksi tidak dikemas kini';

  @override
  String get outfitCollectionDeletedBody => 'Koleksi telah dipadam.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Koleksi tidak dipadam';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count set pakai ditambah.',
      one: '1 set pakai ditambah.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Set pakai tidak ditambah';

  @override
  String get outfitPreviewNotCreatedTitle => 'Pratonton tidak dicipta';

  @override
  String get outfitGiveNameBody => 'Beri nama set pakai ini.';

  @override
  String get outfitNameMissingTitle => 'Nama';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'Pilih sekurang-kurangnya satu item.';

  @override
  String outfitCreatedBody(String name) {
    return '$name ada dalam set pakai anda.';
  }

  @override
  String get outfitSavedTitle => 'Disimpan';

  @override
  String get wardrobeAddedToFavouritesBody => 'Ditambah ke kegemaran';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Dibuang daripada kegemaran';

  @override
  String get wardrobeNotSavedTitle => 'Tidak disimpan';

  @override
  String get wardrobeLoggedAsWornBody => 'Direkodkan sebagai dipakai hari ini.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Dibuang dari almari anda.';

  @override
  String get wardrobeDeletedTitle => 'Dipadam';

  @override
  String get wardrobeNotDeletedTitle => 'Tidak dipadam';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dibuang dari almari anda.',
      one: '1 item dibuang dari almari anda.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Eksstrak Almari AI';

  @override
  String get itemAddScanJobLabel => 'Imbas';

  @override
  String get itemAddFoundEarlierBody => 'Dijumpai dalam imbasan sebelumnya';

  @override
  String get itemAddLookingAtPhoto => 'Memandangkan foto anda';

  @override
  String get itemAddExtractionFailedBody => 'Pengambilan gagal';

  @override
  String get itemAddJobFailedBody => 'Tugasan gagal';

  @override
  String get itemAddConnectionLostBody => 'Sambungan terputus. Cuba lagi.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Sambungan terputus semasa memproses.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Pret $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Pret';

  @override
  String get itemAddNotCancelledTitle => 'Tidak dibatalkan';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pret dalam almari anda.',
      one: '1 pret dalam almari anda.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved daripada $total pret disimpan. Ketik simpan untuk cuba yang lain.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Sesetengah pret tidak disimpan';

  @override
  String get batchChooseAtLeastOnePhotoBody =>
      'Pilih sekurang-kurangnya satu foto.';

  @override
  String get batchPhotoUnreadableBody => 'Foto ini tidak boleh dibaca.';

  @override
  String get batchNoPhotosReadableBody =>
      'Tiada foto yang boleh dibaca. Cuba foto lain.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Sambungan terputus semasa memproses. Cuba lagi.';

  @override
  String get batchNotCancelledTitle => 'Tidak dibatalkan';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Pautan pos tidak disokong. Masukkan pautan profil.';

  @override
  String get batchLinkSpacesBody => 'Pautan tidak boleh mengandungi ruang.';

  @override
  String get batchEnterProfileLinkBody =>
      'Masukkan pautan profil Instagram atau Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Masukkan pautan profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Halaman daftar masuk tidak dibuka. Cuba lagi.';

  @override
  String get batchSignInBrowserBody =>
      'Daftar masuk dalam pelayar anda, kemudian kembali ke FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Hubungkan akaun anda';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Masukkan kod daripada aplikasi pengesah anda.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram perlukan semakan keselamatan. Daftar masuk dalam pelayar dahulu.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Masukkan nama pengguna dan kata laluan anda semula.';

  @override
  String get batchSignInFailedBody =>
      'Daftar masuk gagal. Semak nama pengguna dan kata laluan anda.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Daftar masuk untuk terus mengimport.';

  @override
  String get batchAccountNotConnectedBody => 'Akaun anda tidak dihubungkan.';

  @override
  String get batchAccountConnectedTitle => 'Akaun dihubungkan';

  @override
  String get batchNotConnectedTitle => 'Tidak disambung';

  @override
  String get batchImportConnectionLostBody =>
      'Sambungan pengimportan terputus. Muat semula untuk semak.';

  @override
  String batchPickUpToBody(int max) {
    return 'Pilih sehingga $max foto. Kami cari barang.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count dari $total foto';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Menyediakan foto $done dari $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cari barang dalam $count foto',
      one: 'Cari barang dalam 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Akaun $platform anda menggunakan log masuk dua langkah. Masukkan kod 6 digit daripada aplikasi pengesah anda.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Profil $platform ini adalah sulit atau memerlukan log masuk untuk memaparkan fotonya.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Sambungkan dengan $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto ditemukan setakat ini',
      one: '1 foto ditemukan setakat ini',
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
    return '$processed dari $total diproses · $added ditambah · $waiting menunggu · $skipped dilepaskan';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Menempekkan foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number seterusnya';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Foto $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count barang ditemukan',
      one: '1 barang ditemukan',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto telah ditambah ke almari anda.',
      one: '1 foto telah ditambah ke almari anda.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count lagi foto studio sedang dihantar. Anda boleh simpan apa yang siap, atau keluar — kami akan memaklumkan.',
      one:
          '1 lagi foto studio sedang dihantar. Anda boleh simpan apa yang siap, atau keluar — kami akan memaklumkan.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Belum disimpan: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces barang',
      one: '1 barang',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos foto',
      one: '1 foto',
    );
    return '$_temp0 dari $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen dipilih. Ketuk barang untuk lepaskan.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Menyimpan $count barang',
      one: 'Menyimpan 1 barang',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Simpan $count barang',
      one: 'Simpan 1 barang',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Profil badan anda disimpan.';

  @override
  String get bodyProfileSavedTitle => 'Disimpan';

  @override
  String get bodyProfileNotSavedTitle => 'Tidak disimpan';

  @override
  String get bodyProfileSetDefaultBody => 'Tetapkan sebagai profil lalai anda.';

  @override
  String get bodyProfileDeletedBody => 'Profil badan telah dipadam.';

  @override
  String get bodyProfileDeletedTitle => 'Dipadam';

  @override
  String get bodyProfileNotDeletedTitle => 'Tidak dipadam';

  @override
  String get feedbackNotSentTitle => 'Tidak dihantar';

  @override
  String get feedbackSentBody =>
      'Terima kasih. Kami membaca setiap mesej dan membalas jika perlu.';

  @override
  String get feedbackSentTitle => 'Maklum balas dihantar';

  @override
  String get recommendUnnamedPiece => 'Butiran tanpa nama';

  @override
  String get recommendEnterCityBody =>
      'Isikan bandar anda untuk pilihan mengikut cuaca.';

  @override
  String get recommendWhichCityTitle => 'Bandar mana?';

  @override
  String get aiConsentSheetTitle => 'Membahagi foto dengan perkhidmatan AI';

  @override
  String get aiConsentSheetBody =>
      'Untuk mewujudkan imej try-on dan sesi foto anda, FitCheck AI menghantar foto yang anda berikan (termasuk imej wajah dan badan anda) kepada pembekal AI pihak ketiga yang dipercayai (seperti OpenAI atau Google Gemini) untuk pemprosesan. Mereka menjana imej anda dan tidak menggunakannya untuk melatih model mereka di bawah terma kami. Foto dihantar secara selamat dan tidak pernah dibahagi untuk pengiklanan.';

  @override
  String get aiConsentSheetPermission =>
      'Dengan terus, anda memberikan kebenaran eksplisit untuk membahagikan foto anda dengan pembekal AI ini untuk penjanaan imej.';

  @override
  String get skeletonsLoadMoreFailed => 'Gagal memuatkan lagi.';

  @override
  String get jobsPiecesReadyTitle => 'Butiran anda siap';

  @override
  String get jobsScanStoppedTitle => 'Imbasan dihentikan';

  @override
  String get jobsNothingSavedBody => 'Tiada yang disimpan. Cuba lagi.';

  @override
  String get jobsPhotoUploadFailedBody => 'Muat naik foto gagal.';

  @override
  String get authGoogleSignInStartFailed =>
      'Gagal memulakan Google Sign-In. Sila cuba lagi.';

  @override
  String get referralAppliedTitle => 'Rujukan Diterapkan!';

  @override
  String get billingStoreUnavailableBody =>
      'Pembelian kedai tidak tersedia pada peranti ini.';

  @override
  String get billingPurchaseProcessingBody =>
      'Pembelian ini masih diproses. Buka semula aplikasi dalam beberapa minit untuk melihat rancangan anda.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Muat naik avatar tidak mengembalikan URL imej.';

  @override
  String get rewardsDayStreakLabel => 'sambungan hari';

  @override
  String rewardsBestStreak(int days) {
    return 'Terbaik $days hari';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Akses $permission Diperlukan';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Akses kepada $permission ditolak buat masa ini. Buka Tetapan untuk membenarkannya, kemudian kembali dan cuba lagi.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Langkah $step daripada 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Langkah $step daripada $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Buang imej $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Buang imej $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points mata';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'E-mel $email. Kami meneliti laporan dalam 24 jam.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Buang $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Padam \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Tambah ke \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" telah dibuang. Itemnya kekal dalam almari anda.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Tunjuk semua $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count lagi hari ini';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Gagal foto $index';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected dari $max foto';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Jasad $shape · Kulit $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Buang $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Pilihan untuk $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Paling kerap dipakai: $name, $count kali';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: tidak ditetapkan';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'Padanan $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked dari $max dipilih';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Buang $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Keutamaan $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Pelan ini dibayar melalui $store. Ubah atau batalkan dalam tetapan akaun $store anda.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Urus dalam $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current dari $max digunakan';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Lagi kira-kira ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done dari $total foto studio sedia';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready dari $total foto studio sedia. Ketik item untuk skip.';
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
  String get profileFieldNotSet => 'Tidak';
}
