// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Beranda';

  @override
  String get tabPhotoshoot => 'Pemotretan';

  @override
  String get tabCloset => 'Lemari';

  @override
  String get tabOutfits => 'Pakaian';

  @override
  String get tabMore => 'Lainnya';

  @override
  String get actionAddItem => 'Tambah item';

  @override
  String get actionCreateOutfit => 'Buat outfit';

  @override
  String get actionCancel => 'Batal';

  @override
  String get actionDelete => 'Hapus';

  @override
  String get actionSave => 'Simpan';

  @override
  String get actionRetry => 'Coba lagi';

  @override
  String get actionDone => 'Selesai';

  @override
  String get actionNext => 'Lanjut';

  @override
  String get actionBack => 'Kembali';

  @override
  String get actionClose => 'Tutup';

  @override
  String get actionSearch => 'Cari';

  @override
  String get actionContinue => 'Lanjutkan';

  @override
  String get stateLoading => 'Memuat';

  @override
  String get stateErrorTitle => 'Terjadi kesalahan';

  @override
  String get stateErrorBody => 'Coba lagi. Jika masih gagal, hubungi dukungan.';

  @override
  String get stateOfflineTitle => 'Anda offline';

  @override
  String get stateOfflineBody =>
      'Sambungkan kembali untuk sinkronisasi lemari dan buat outfit.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsAccountSection => 'Akun';

  @override
  String get settingsPreferencesSection => 'Preferensi';

  @override
  String get settingsPlanBilling => 'Paket dan tagihan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsNotifications => 'Notifikasi';

  @override
  String get settingsUnits => 'Satuan ukuran';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get settingsPrivacySection => 'Privasi dan data';

  @override
  String get settingsAboutSection => 'Tentang';

  @override
  String get settingsSignOut => 'Keluar';

  @override
  String get settingsDeleteAccount => 'Hapus akun';

  @override
  String get settingsDeleteAccountTitle => 'Hapus akun Anda?';

  @override
  String get settingsDeleteAccountBody =>
      'Tindakan ini akan menghapus lemari, pakaian, foto, dan profil Anda. Tidak dapat dibatalkan.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metrik (cm, kg)';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageSystem => 'Gunakan bahasa perangkat';

  @override
  String get languageSystemBody => 'FitCheck AI mengikuti bahasa ponsel Anda.';

  @override
  String get languageSearchHint => 'Cari bahasa';

  @override
  String get languageCurrent => 'Saat ini';

  @override
  String get languageReviewNote =>
      'Terjemahan ini baru. Beri tahu kami jika ada yang kurang tepat.';

  @override
  String get languageChanged => 'Bahasa diperbarui';

  @override
  String get paywallTitle => 'Pilih paket Anda';

  @override
  String get paywallTrialBadge => '1 bulan gratis';

  @override
  String get paywallTrialTitle => 'Bulan pertama Pro Anda gratis';

  @override
  String get paywallTrialBody =>
      'Unggah seluruh lemari Anda sekaligus. Tambahkan pakaian seiring waktu setelahnya.';

  @override
  String get paywallFreeForeverTitle => 'Gratis selamanya';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Tanpa kartu. Setiap bulan Anda mendapatkan $uploads unggahan AI, $outfits pakaian, dan $images foto photoshoot per hari.';
  }

  @override
  String get paywallCtaTrial => 'Mulai bulan gratis saya';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Tingkatkan ke $plan';
  }

  @override
  String get paywallRestore => 'Pulihkan pembelian';

  @override
  String get paywallManage => 'Kelola langganan';

  @override
  String get paywallTerms => 'Ketentuan penggunaan';

  @override
  String get paywallPrivacy => 'Kebijakan privasi';

  @override
  String get paywallPerMonth => 'per bulan';

  @override
  String get paywallPerYear => 'per tahun';

  @override
  String get paywallBestValue => 'Nilai terbaik';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Uji coba gratis hanya untuk pelanggan baru. Setelah uji coba, Pro akan diperpanjang seharga $price kecuali dibatalkan setidaknya 24 jam sebelum berakhir.';
  }

  @override
  String get introTitle => 'Lemari Anda, akhirnya rapi';

  @override
  String get introBody =>
      'Foto pakaian Anda sekali saja. Dapatkan ide padu padan, pratinjau coba pakai, dan foto studio dari koleksi yang sudah Anda miliki.';

  @override
  String get introStart => 'Mulai';

  @override
  String get introHaveAccount => 'Saya sudah punya akun';

  @override
  String get introSkip => 'Lewati';

  @override
  String get authSignIn => 'Masuk';

  @override
  String get authSignUp => 'Buat akun';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Kata sandi';

  @override
  String get authForgotPassword => 'Lupa kata sandi?';

  @override
  String get authContinueApple => 'Lanjutkan dengan Apple';

  @override
  String get authContinueGoogle => 'Lanjutkan dengan Google';

  @override
  String get authOrDivider => 'atau';

  @override
  String get wardrobeTitle => 'Lemari';

  @override
  String get wardrobeEmptyTitle => 'Lemari Anda kosong';

  @override
  String get wardrobeEmptyBody =>
      'Tambahkan pakaian pertama Anda, atau unggah foto seluruh koleksi sekaligus.';

  @override
  String get wardrobeAddFirst => 'Tambah item pertama';

  @override
  String get wardrobeSearchHint => 'Cari di lemari Anda';

  @override
  String get categoryTops => 'Atasan';

  @override
  String get categoryBottoms => 'Bawahan';

  @override
  String get categoryShoes => 'Sepatu';

  @override
  String get categoryAccessories => 'Aksesori';

  @override
  String get categoryOuterwear => 'Luaran';

  @override
  String get categorySwimwear => 'Baju renang';

  @override
  String get categoryActivewear => 'Pakaian olahraga';

  @override
  String get categoryOther => 'Lainnya';

  @override
  String get conditionClean => 'Bersih';

  @override
  String get conditionDirty => 'Kotor';

  @override
  String get conditionLaundry => 'Sedang dicuci';

  @override
  String get conditionRepair => 'Perlu diperbaiki';

  @override
  String get conditionDonate => 'Untuk disumbangkan';

  @override
  String get seasonSpring => 'Musim semi';

  @override
  String get seasonSummer => 'Musim panas';

  @override
  String get seasonFall => 'Musim gugur';

  @override
  String get seasonWinter => 'Musim dingin';

  @override
  String get seasonAll => 'Semua musim';

  @override
  String get styleCasual => 'Kasual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Bisnis';

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
  String get styleRomantic => 'Romantis';

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
  String get styleOther => 'Lainnya';

  @override
  String get occasionWork => 'Kerja';

  @override
  String get occasionDateNight => 'Kencan';

  @override
  String get occasionTravel => 'Bepergian';

  @override
  String get occasionWedding => 'Pernikahan';

  @override
  String get occasionGym => 'Gym';

  @override
  String get occasionWeekend => 'Akhir pekan';

  @override
  String get occasionParty => 'Pesta';

  @override
  String get occasionInterview => 'Wawancara';

  @override
  String get colorBlack => 'Hitam';

  @override
  String get colorWhite => 'Putih';

  @override
  String get colorGrey => 'Abu-abu';

  @override
  String get colorNavy => 'Biru Dongker';

  @override
  String get colorBrown => 'Cokelat';

  @override
  String get colorRed => 'Merah';

  @override
  String get colorBlue => 'Biru';

  @override
  String get colorGreen => 'Hijau';

  @override
  String get colorPink => 'Merah Muda';

  @override
  String get colorPurple => 'Ungu';

  @override
  String get colorYellow => 'Kuning';

  @override
  String get colorOrange => 'Oranye';

  @override
  String get colorBeige => 'Krem';

  @override
  String get dateToday => 'Hari ini';

  @override
  String get dateYesterday => 'Kemarin';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari lalu',
      one: '1 hari lalu',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minggu lalu',
      one: '1 minggu lalu',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bulan lalu',
      one: '1 bulan lalu',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tahun lalu',
      one: '1 tahun lalu',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Suka dengan FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Beri penilaian untuk membantu orang lain menemukan gaya mereka.';

  @override
  String get ratingPromptYes => 'Beri nilai';

  @override
  String get ratingPromptNo => 'Nanti saja';

  @override
  String get closetNoMatchesTitle => 'Tidak ada kecocokan';

  @override
  String get closetNoMatchesBody =>
      'Coba kurangi filter atau cari kata kunci lain.';

  @override
  String get closetClearFilters => 'Hapus filter';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Memuat item Anda';

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
  String get closetDeleteSelected => 'Hapus yang dipilih';

  @override
  String get closetCancelSelection => 'Batal pilih';

  @override
  String get closetCloseSearch => 'Tutup pencarian';

  @override
  String get closetShowGrid => 'Tampilkan kisi';

  @override
  String get closetShowList => 'Tampilkan daftar';

  @override
  String get closetShowRows => 'Tampilkan baris';

  @override
  String get closetStatsTitle => 'Statistik lemari';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count item?',
      one: 'Hapus 1 item?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Outfit yang menggunakannya akan kehilangan item ini.';

  @override
  String get closetSortBy => 'Urutkan berdasarkan';

  @override
  String get closetFavourites => 'Favorit';

  @override
  String get closetFavourite => 'Favoritkan';

  @override
  String get closetUnfavourite => 'Hapus favorit';

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
  String get closetOtherUseCaseHint => 'Contoh: brunch';

  @override
  String get closetUseUseCase => 'Gunakan ini';

  @override
  String get closetClearAll => 'Hapus semua';

  @override
  String get sortNewest => 'Terbaru';

  @override
  String get sortOldest => 'Terlama';

  @override
  String get sortName => 'Nama (A–Z)';

  @override
  String get sortMostWorn => 'Paling sering dipakai';

  @override
  String get useCaseInformal => 'Santai';

  @override
  String get useCaseDate => 'Kencan';

  @override
  String get useCaseDinner => 'Makan malam';

  @override
  String get useCaseLunch => 'Makan siang';

  @override
  String get actionSelect => 'Pilih';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Urutkan';

  @override
  String get actionAll => 'Semua';

  @override
  String get dashboardStartClosetTitle => 'Mulai lemari Anda';

  @override
  String get dashboardStartClosetBody =>
      'Foto beberapa pakaian. Kami akan melabelinya untuk Anda.';

  @override
  String get dashboardPieces => 'pakaian';

  @override
  String get dashboardOutfits => 'setelan';

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
      other: '$count favorit',
      one: '1 favorit',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count setelan disimpan',
      one: '1 setelan disimpan',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Paling sering dipakai: $name, $count kali';
  }

  @override
  String get setupSkip => 'Lewati pengaturan';

  @override
  String get setupWhoTitle => 'Siapa yang akan kami tata gayanya?';

  @override
  String get setupWhoBody =>
      'Menentukan model untuk coba pakai dan pemotretan. Anda bisa mengubahnya di profil.';

  @override
  String get setupStyleTitle => 'Apa yang paling sering Anda pakai?';

  @override
  String get setupStyleBody =>
      'Pilih mana saja. Ide setelan dimulai dari sini.';

  @override
  String get setupClosetTitle => 'Tambahkan pakaian pertama Anda.';

  @override
  String get setupClosetBody =>
      'Foto beberapa pakaian, atau tumpukan pakaian. Setiap potong akan dipotong dan disimpan untuk Anda.';

  @override
  String get setupAddClothes => 'Tambah pakaian';

  @override
  String get setupStylesLabel => 'Gaya';

  @override
  String get setupOccasionsLabel => 'Acara';

  @override
  String get setupSkipStep => 'Lewati';

  @override
  String get setupLater => 'Nanti';

  @override
  String get setupSaveError => 'Gagal menyimpan';

  @override
  String get genderWomen => 'Wanita';

  @override
  String get genderMen => 'Pria';

  @override
  String get genderNonBinary => 'Non-biner';

  @override
  String get genderPreferNotToSay => 'Lebih suka tidak menyebutkan';

  @override
  String get outfitEmptyTitle => 'Belum ada outfit';

  @override
  String get outfitEmptyBody =>
      'Padukan pakaian dari lemari Anda dan simpan tampilannya.';

  @override
  String get outfitNoMatchesTitle => 'Tidak ada outfit yang cocok';

  @override
  String get outfitSearchHint => 'Cari outfit Anda';

  @override
  String get outfitLoading => 'Memuat outfit Anda';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfit',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Gaya dan musim';

  @override
  String get outfitCollections => 'Koleksi';

  @override
  String get outfitDuplicate => 'Duplikat';

  @override
  String get outfitDeleteTitle => 'Hapus outfit ini?';

  @override
  String get outfitDeleteBody => 'Pakaiannya tetap ada di lemari Anda.';

  @override
  String get outfitDrafts => 'Draf';

  @override
  String get outfitDraft => 'Draf';

  @override
  String get filterStyle => 'Gaya';

  @override
  String get filterSeason => 'Musim';

  @override
  String get itemDetailDeleteTitle => 'Hapus pakaian ini?';

  @override
  String get itemDetailDeleteBody =>
      'Outfit yang menggunakannya akan kehilangan pakaian ini.';

  @override
  String get itemAddFavourite => 'Tambahkan ke favorit';

  @override
  String itemSize(String size) {
    return 'Ukuran $size';
  }

  @override
  String get itemColours => 'Warna';

  @override
  String get itemMaterial => 'Bahan';

  @override
  String get itemPattern => 'Pola';

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
  String get itemAdded => 'Ditambahkan';

  @override
  String get itemTimesWornLabel => 'kali dipakai';

  @override
  String get itemLastWornLabel => 'terakhir dipakai';

  @override
  String get itemNeverWorn => 'Belum pernah';

  @override
  String get authEntryBody =>
      'Setiap potong pakaianmu, ditata oleh AI. Rencanakan outfit, coba, dan potret.';

  @override
  String get authCreateCloset => 'Buat lemari pakaianmu';

  @override
  String get authWelcomeBack => 'Selamat datang kembali';

  @override
  String get authSignInBody => 'Masuk untuk membuka lemari pakaianmu.';

  @override
  String get authCreateAccount => 'Buat akun';

  @override
  String get authCreateClosetBody =>
      'Hanya butuh semenit. Item pertamamu gratis.';

  @override
  String get authName => 'Nama';

  @override
  String get authConfirmPassword => 'Konfirmasi kata sandi';

  @override
  String get authReferralCode => 'Kode referral (opsional)';

  @override
  String get authResetTitle => 'Atur ulang kata sandi';

  @override
  String get authResetBody =>
      'Kami akan mengirim tautan untuk membuat kata sandi baru.';

  @override
  String get authSendResetLink => 'Kirim tautan reset';

  @override
  String get authBackToSignIn => 'Kembali ke masuk';

  @override
  String get authEnterEmail => 'Masukkan emailmu';

  @override
  String get authEnterValidEmail => 'Masukkan email yang valid';

  @override
  String get authEnterPassword => 'Masukkan kata sandi';

  @override
  String get authPasswordTooShort => 'Minimal 6 karakter';

  @override
  String get authShowPassword => 'Tampilkan kata sandi';

  @override
  String get authHidePassword => 'Sembunyikan kata sandi';

  @override
  String get authNewHere => 'Pengguna baru?';

  @override
  String authConfirmEmail(String email) {
    return 'Konfirmasi $email sebelum masuk. Cek kotak masukmu.';
  }

  @override
  String get authResendEmail => 'Kirim ulang';

  @override
  String get authResendingEmail => 'Mengirim…';

  @override
  String get authPasswordsDoNotMatch => 'Kata sandi tidak cocok';

  @override
  String get authEnterName => 'Masukkan namamu';

  @override
  String get authChoosePassword => 'Pilih kata sandi';

  @override
  String get authHaveAccount => 'Sudah punya akun?';

  @override
  String get authCodeAccepted => 'Kode diterima';

  @override
  String get authCodeNotFound => 'Kode tidak ditemukan';

  @override
  String authReferralFrom(String name) {
    return 'Dari $name. Kalian berdua dapat sebulan gratis.';
  }

  @override
  String get authReferralInvalid => 'Kami tidak dapat menemukan kode ini.';

  @override
  String authResetSent(String email) {
    return 'Terkirim ke $email. Buka tautan di ponsel ini.';
  }

  @override
  String get introSlide1Title => 'Foto lemari Anda sekali.';

  @override
  String get introSlide1Body =>
      'Foto tumpukan pakaian. Setiap potong akan dipotong dan disimpan untuk Anda.';

  @override
  String get introSlide2Title => 'Berpakaian lebih cepat.';

  @override
  String get introSlide2Body =>
      'Padu padan dari koleksi Anda, disesuaikan dengan rencana dan cuaca.';

  @override
  String get introSlide3Title => 'Lihat sebelum dipakai.';

  @override
  String get introSlide3Body =>
      'Coba tampilan di foto Anda, atau potret seperti kampanye.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsTemperature => 'Suhu';

  @override
  String get settingsEmailUpdates => 'Pembaruan email';

  @override
  String get settingsEmailUpdatesBody => 'Berita dan tips via email';

  @override
  String get settingsOutfitReminders => 'Pengingat pakaian';

  @override
  String get settingsOutfitRemindersBody =>
      'Notifikasi untuk mencatat pakaian Anda';

  @override
  String get settingsWeeklySummary => 'Ringkasan mingguan';

  @override
  String get settingsWeeklySummaryBody => 'Minggu Anda dalam pakaian';

  @override
  String get settingsStyleSection => 'Gaya';

  @override
  String get settingsPreferredStyles => 'Gaya pilihan';

  @override
  String get settingsPreferredColours => 'Warna pilihan';

  @override
  String get settingsNoneChosen => 'Belum dipilih';

  @override
  String get settingsPlanAiSection => 'Paket dan AI';

  @override
  String get settingsPlanBillingBody => 'Paket, penggunaan, dan peningkatan';

  @override
  String get settingsPlanUsageBody => 'Paket dan penggunaan';

  @override
  String get settingsInviteFriends => 'Undang teman';

  @override
  String get settingsInviteFriendsBody =>
      'Satu bulan gratis untuk setiap teman yang bergabung';

  @override
  String get settingsAiProvider => 'Penyedia AI';

  @override
  String get settingsAiProviderBody =>
      'Gunakan model Anda sendiri untuk penandaan dan gambar';

  @override
  String get settingsAppVersion => 'Versi aplikasi';

  @override
  String get settingsPrivacyTerms => 'Privasi dan ketentuan';

  @override
  String get settingsReportProblem => 'Laporkan masalah';

  @override
  String get settingsChangePassword => 'Ubah kata sandi';

  @override
  String get settingsExportData => 'Ekspor data Anda';

  @override
  String get settingsExportBody =>
      'Kami menyiapkan file berisi semua yang Anda simpan dan membuka unduhan.';

  @override
  String get settingsExportAction => 'Ekspor';

  @override
  String get settingsCurrentPassword => 'Kata sandi saat ini';

  @override
  String get settingsNewPassword => 'Kata sandi baru';

  @override
  String get settingsConfirmNewPassword => 'Konfirmasi kata sandi baru';

  @override
  String get settingsEnterCurrentPassword =>
      'Masukkan kata sandi Anda saat ini';

  @override
  String get settingsEnterNewPassword => 'Masukkan kata sandi baru';

  @override
  String get settingsPasswordMin8 => 'Gunakan minimal 8 karakter';

  @override
  String get settingsPasswordNeedsUpper => 'Tambahkan huruf besar';

  @override
  String get settingsPasswordNeedsLower => 'Tambahkan huruf kecil';

  @override
  String get settingsPasswordNeedsDigit => 'Tambahkan angka';

  @override
  String get settingsPasswordsNoMatch => 'Kata sandi tidak cocok';

  @override
  String get settingsChangeAction => 'Ubah';

  @override
  String get itemAddSnapTitle => 'Foto pakaian';

  @override
  String get itemAddSnapBody =>
      'Kami menemukan setiap potong pakaian di foto dan membuat tampilan studio yang bersih.';

  @override
  String get itemAddCamera => 'Ambil foto';

  @override
  String get itemAddGallery => 'Pilih dari galeri';

  @override
  String get itemAddOtherWays => 'Cara lain untuk menambah';

  @override
  String get itemAddSeveral => 'Tambah beberapa foto';

  @override
  String get itemAddSeveralBody => 'Hingga 50 sekaligus';

  @override
  String get itemAddImportProfile => 'Impor dari profil';

  @override
  String get itemAddImportProfileBody => 'Instagram atau Facebook';

  @override
  String get itemAddEnterDetails => 'Masukkan detail sendiri';

  @override
  String get itemAddEnterDetailsBody => 'Tidak perlu foto';

  @override
  String get itemManualIntro =>
      'Hanya butuh nama. Tambahkan sisanya sekarang atau nanti.';

  @override
  String get itemManualNameHint => 'Contoh: kaus katun biru';

  @override
  String get itemManualEnterName => 'Masukkan nama';

  @override
  String get itemManualNotes => 'Catatan';

  @override
  String get itemManualBrand => 'Merek';

  @override
  String get itemManualSize => 'Ukuran';

  @override
  String get itemManualEnterNumber => 'Masukkan angka';

  @override
  String get itemManualSavePiece => 'Simpan item';

  @override
  String get itemManualSaving => 'Menyimpan';

  @override
  String get itemManualSavedTitle => 'Tersimpan';

  @override
  String itemManualSavedBody(String name) {
    return '$name ada di lemari Anda.';
  }

  @override
  String get itemManualNotSaved => 'Tidak tersimpan';

  @override
  String get itemManualAddUseCase => 'Tambahkan kegunaan';

  @override
  String get itemManualAddUseCaseAction => 'Tambah kegunaan';

  @override
  String get itemPhotos => 'Foto';

  @override
  String get itemAddPhotos => 'Tambah foto';

  @override
  String get itemNoPhotoYet =>
      'Belum ada foto. Anda bisa menyimpan tanpa foto.';

  @override
  String get itemRemovePhoto => 'Hapus foto';

  @override
  String get itemRemovePiece => 'Hapus item';

  @override
  String get filterConditionLabel => 'Kondisi';

  @override
  String get photoshootStepPhotos => 'Foto';

  @override
  String get photoshootStepSetup => 'Pengaturan';

  @override
  String get photoshootStepCreating => 'Membuat';

  @override
  String get photoshootStepResults => 'Hasil';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Langkah $current dari $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Satu foto gagal. Coba lagi di bawah.';

  @override
  String photoshootManyFailed(int count) {
    return '$count foto gagal. Coba lagi masing-masing di bawah.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Jumlah';

  @override
  String get photoshootYourPrompt => 'Prompt Anda';

  @override
  String get photoshootPromptHint => 'Golden hour di atap, kemeja linen';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buat $count foto',
      one: 'Buat 1 foto',
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
  String get photoshootLimitUnknown => 'Gagal memeriksa batas hari ini.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Paket $plan: $remaining dari $limit tersisa hari ini';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratis';

  @override
  String get photoshootGallery => 'Galeri';

  @override
  String get photoshootUseCamera => 'Gunakan kamera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Hapus foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Tidak ada foto';

  @override
  String get photoshootNoPhotosBody => 'Sesi selesai tanpa gambar. Coba lagi.';

  @override
  String get photoshootNewStyle => 'Gaya baru';

  @override
  String get photoshootNewPhotos => 'Foto baru';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Buka foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Laporkan foto';

  @override
  String get photoshootSaveToGallery => 'Simpan ke galeri';

  @override
  String get actionUpgrade => 'Upgrade';

  @override
  String get referralLimitTitle => 'Batas foto hari ini habis';

  @override
  String get referralLimitBody =>
      'Foto gratis Anda kembali besok. Ajak teman dan kalian berdua dapat Pro gratis sebulan.';

  @override
  String get referralLimitRefer => 'Ajak teman';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Aplikasi kencan';

  @override
  String get photoshootUsePortfolio => 'Portofolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estetik';

  @override
  String get photoshootUseCustom => 'Prompt sendiri';

  @override
  String get photoshootDescLinkedin => 'Foto profil profesional untuk kerja';

  @override
  String get photoshootDescDating => 'Santai, hangat, dan natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, gaya high-fashion';

  @override
  String get photoshootDescInstagram => 'Foto gaya hidup untuk feed Anda';

  @override
  String get photoshootDescAesthetic => 'Moody, artistik';

  @override
  String get photoshootDescCustom => 'Deskripsikan gaya yang Anda inginkan';

  @override
  String get aspectSquare => 'Kotak';

  @override
  String get aspectPortrait => 'Potret';

  @override
  String get aspectLandscape => 'Lanskap';

  @override
  String get aspectTall => 'Tinggi';

  @override
  String get aspectWide => 'Lebar';

  @override
  String get tryOnAppBar => 'Coba virtual';

  @override
  String get tryOnYourPhoto => 'Foto Anda';

  @override
  String get tryOnGarment => 'Pakaian';

  @override
  String get tryOnUploadingPhoto => 'Mengunggah foto Anda';

  @override
  String get tryOnAddPhotoPrompt => 'Tambahkan foto seluruh tubuh Anda';

  @override
  String get tryOnBodyPhotoHint =>
      'Foto seluruh tubuh memberikan hasil terbaik';

  @override
  String get tryOnAddPhoto => 'Tambah foto';

  @override
  String get tryOnChangePhoto => 'Ganti foto';

  @override
  String get tryOnPhotoLoadFailed => 'Kami tidak dapat memuat foto Anda.';

  @override
  String get tryOnChooseGarment => 'Pilih foto pakaian';

  @override
  String get tryOnChooseOneGarment => 'Pilih satu foto pakaian';

  @override
  String get tryOnGarmentHint =>
      'Foto pakaian terbentang atau digantung paling baik';

  @override
  String get tryOnChange => 'Ganti';

  @override
  String get tryOnCamera => 'Kamera';

  @override
  String get tryOnRemove => 'Hapus';

  @override
  String get tryOnLookTitle => 'Tampilan';

  @override
  String get tryOnStyle => 'Gaya';

  @override
  String get tryOnBackground => 'Latar belakang';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Sedang memproses. Ini memakan waktu sekitar setengah menit.';

  @override
  String get tryOnEmptyResult => 'Hasil coba-pakai Anda muncul di sini';

  @override
  String get tryOnReportImage => 'Laporkan gambar';

  @override
  String get tryOnCreating => 'Membuat';

  @override
  String get tryOnTryAgain => 'Coba lagi';

  @override
  String get tryOnCreate => 'Buat coba-pakai';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio putih';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio abu-abu';

  @override
  String get tryOnBackgroundUrban => 'Jalanan kota';

  @override
  String get tryOnBackgroundNature => 'Alam';

  @override
  String get tryOnBackgroundMinimal => 'Minimalis';

  @override
  String get tryOnPoseFront => 'Berdiri depan';

  @override
  String get tryOnPoseSide => 'Berdiri samping';

  @override
  String get tryOnPoseWalking => 'Berjalan';

  @override
  String get dashboardGreetingMorning => 'Selamat pagi';

  @override
  String get dashboardGreetingAfternoon => 'Selamat siang';

  @override
  String get dashboardGreetingEvening => 'Selamat malam';

  @override
  String get dashboardWelcome => 'Selamat datang';

  @override
  String get dashboardOpenProfile => 'Buka profil';

  @override
  String get dashboardRailToday => 'Hari ini';

  @override
  String get dashboardRailRecently => 'Terbaru';

  @override
  String get dashboardActivityEmpty =>
      'Pakaian dan outfit baru muncul di sini.';

  @override
  String get quickAddPiece => 'Tambah pakaian';

  @override
  String get quickAddPieceBody => 'Foto dan beri tag';

  @override
  String get quickBuildOutfit => 'Buat outfit';

  @override
  String get quickBuildOutfitBody => 'Padu padan koleksi';

  @override
  String get quickForYou => 'Untuk Anda';

  @override
  String get quickForYouBody => 'Pilihan hari ini';

  @override
  String get quickPlanWeek => 'Rencanakan minggu';

  @override
  String get quickPlanWeekBody => 'Outfit per tanggal';

  @override
  String get referralBannerUrgent => 'Kuota habis? Undang teman.';

  @override
  String get referralBannerTitle => 'Beri sebulan, dapat sebulan.';

  @override
  String get referralBannerBody =>
      'Anda dan teman Anda masing-masing mendapat satu bulan Pro.';

  @override
  String get referralBannerDismiss => 'Tutup selama seminggu';

  @override
  String get referralBannerShare => 'Bagikan undangan';

  @override
  String get referralBannerCopy => 'Salin tautan';

  @override
  String get itemEditPieceTitle => 'Edit pakaian';

  @override
  String get itemEditDescriptionLabel => 'Deskripsi';

  @override
  String get itemEditNotSaved => 'Belum disimpan';

  @override
  String get itemEditSavedTitle => 'Tersimpan';

  @override
  String get itemEditSavedBody => 'Perubahan Anda telah disimpan.';

  @override
  String get itemEditSavedStalePhotos => 'Tersimpan — foto mungkin sudah usang';

  @override
  String get itemEditRemovePieceHint => 'Hapus pakaian ini dari halaman item.';

  @override
  String get itemEditNoPhotos =>
      'Belum ada foto. Tambahkan dari galeri atau kamera.';

  @override
  String get itemEditKeepPhoto => 'Simpan foto';

  @override
  String get itemEditRemoved => 'Dihapus';

  @override
  String get itemEditAddUseCaseAction => 'Tambah';

  @override
  String get statsNoStatsTitle => 'Belum ada statistik';

  @override
  String get statsNoStatsBody =>
      'Tambahkan beberapa pakaian dan koleksi lemari Anda akan muncul di sini.';

  @override
  String get statsByCategory => 'Berdasarkan kategori';

  @override
  String get statsTotalValue => 'total nilai';

  @override
  String get statsMostWorn => 'Paling sering dipakai';

  @override
  String get statsLeastWorn => 'Menunggu giliran';

  @override
  String get statsUnnamedPiece => 'Pakaian tanpa nama';

  @override
  String get jobsTitle => 'Pemindaian';

  @override
  String get jobsEmptyTitle => 'Belum ada pemindaian';

  @override
  String get jobsEmptyBody =>
      'Foto pakaian dan biarkan diproses di latar belakang — tetap berjalan di sini.';

  @override
  String get jobsNotCancelled => 'Tidak dibatalkan';

  @override
  String get jobsResume => 'Lanjutkan';

  @override
  String get jobsReview => 'Tinjau';

  @override
  String get jobsStop => 'Berhenti';

  @override
  String get jobsDismiss => 'Abaikan';

  @override
  String get reportTitle => 'Laporkan konten';

  @override
  String reportIntro(String contentType) {
    return 'Beri tahu kami apa yang salah dengan $contentType ini. Tim kami meninjau setiap laporan.';
  }

  @override
  String get reportReasonInappropriate => 'Tidak pantas atau menyinggung';

  @override
  String get reportReasonNudity => 'Ketelanjangan atau konten seksual';

  @override
  String get reportReasonHarassment => 'Pelecehan atau kekerasan';

  @override
  String get reportReasonImpersonation => 'Peniruan identitas';

  @override
  String get reportReasonOther => 'Lainnya';

  @override
  String get reportDetailsLabel => 'Detail tambahan (opsional)';

  @override
  String get reportSubmit => 'Kirim laporan';

  @override
  String get reportSubmittedTitle => 'Laporan dikirim';

  @override
  String get reportSubmittedBody =>
      'Terima kasih. Tim kami akan meninjau konten ini.';

  @override
  String get reportFailedTitle => 'Gagal mengirim laporan';

  @override
  String get reportFailedBody => 'Silakan coba lagi.';

  @override
  String get reportContentTryOnImage => 'gambar coba baju AI';

  @override
  String get reportContentSharedOutfit => 'pakaian yang dibagikan';

  @override
  String get reportContentPhotoshootImage => 'gambar pemotretan AI';

  @override
  String get sharedOutfitTitle => 'Pakaian dibagikan';

  @override
  String get sharedOutfitHideTooltip => 'Sembunyikan pakaian ini';

  @override
  String get sharedOutfitReportTooltip => 'Laporkan pakaian ini';

  @override
  String get sharedOutfitHideTitle => 'Sembunyikan pakaian ini?';

  @override
  String get sharedOutfitHideBody =>
      'Pakaian ini akan disembunyikan di perangkat ini. Anda juga bisa melaporkannya agar tim kami dapat meninjau dan menghapusnya.';

  @override
  String get sharedOutfitHideAction => 'Sembunyikan';

  @override
  String get sharedOutfitHiddenInfo =>
      'Pakaian ini tidak akan muncul lagi di perangkat ini.';

  @override
  String get sharedOutfitHiddenToast => 'Pakaian disembunyikan';

  @override
  String get sharedOutfitMissingTitle => 'Pakaian ini sudah tidak ada';

  @override
  String get sharedOutfitMissingBody =>
      'Mungkin telah dihapus atau tautan salah.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Anda menyembunyikan pakaian ini';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Jika konten tidak pantas, laporkan melalui Privasi dan ketentuan atau email ke $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Suka gaya ini?';

  @override
  String get sharedOutfitCtaBody =>
      'Buat gaya serupa dari lemari Anda sendiri.';

  @override
  String get sharedOutfitCtaButton => 'Dapatkan FitCheck AI';

  @override
  String get errorTitle => 'Kesalahan';

  @override
  String get errorUnknown => 'Terjadi kesalahan tak terduga';

  @override
  String get errorNoConnection =>
      'Tidak ada koneksi internet. Periksa jaringan Anda.';

  @override
  String get errorTimeout => 'Permintaan melebihi waktu. Silakan coba lagi.';

  @override
  String get errorServerError =>
      'Terjadi kesalahan di sisi kami. Silakan coba lagi.';

  @override
  String get errorBadGateway =>
      'Server kami sementara tidak tersedia. Silakan coba lagi.';

  @override
  String get errorServiceUnavailable =>
      'Layanan sementara tidak tersedia. Silakan coba lagi sebentar lagi.';

  @override
  String get errorInternalError => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get errorUnauthorized => 'Silakan masuk untuk melanjutkan.';

  @override
  String get errorForbidden => 'Anda tidak memiliki akses ke hal itu.';

  @override
  String get errorSessionExpired =>
      'Sesi Anda kedaluwarsa. Silakan masuk kembali.';

  @override
  String get errorInvalidCredentials => 'Email atau kata sandi salah.';

  @override
  String get errorTokenRefreshFailed =>
      'Kami tidak dapat memperbarui sesi Anda. Silakan masuk kembali.';

  @override
  String get errorRequestCancelled => 'Permintaan dibatalkan.';

  @override
  String get errorInvalidFormat => 'Format file tersebut tidak didukung.';

  @override
  String get errorFileTooLarge => 'File tersebut terlalu besar.';

  @override
  String get errorUploadFailed => 'Unggahan gagal. Silakan coba lagi.';

  @override
  String get errorCacheCorrupted =>
      'Data yang disimpan rusak dan telah direset.';

  @override
  String get errorCacheNotFound => 'Belum ada data yang disimpan.';

  @override
  String get errorUserNotFound => 'Kami tidak dapat menemukan akun tersebut.';

  @override
  String get errorItemNotFound => 'Item tersebut tidak ada lagi.';

  @override
  String get errorOutfitNotFound => 'Outfit tersebut tidak ada lagi.';

  @override
  String get rewardsTitle => 'Hadiah';

  @override
  String get rewardsNoAchievementsTitle => 'Belum ada pencapaian';

  @override
  String get rewardsNoAchievementsBody =>
      'Tambahkan pakaian dan rancang outfit untuk mendapat poin pertama.';

  @override
  String get rewardsEmptyLeaderboardTitle =>
      'Belum ada pemain di papan peringkat';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Rancang outfit untuk mengumpulkan poin dan muncul di sini.';

  @override
  String get legalViewPrivacyPolicy => 'Lihat Kebijakan Privasi';

  @override
  String get aiConsentAgree => 'Saya Setuju & Lanjutkan';

  @override
  String get aiConsentNotNow => 'Belum';

  @override
  String get imageViewerCloseTooltip => 'Tutup penampil gambar';

  @override
  String get updateReadyTitle => 'Pembaruan siap';

  @override
  String get updateReadyBody =>
      'Mulai ulang FitCheck AI untuk menerapkan peningkatan terbaru.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI membutuhkan akses kamera untuk memotret gaya busana dan item lemari kamu.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI membutuhkan akses galeri foto untuk memilih gambar gaya busana dan item lemari kamu.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI perlu menyimpan foto busana hasil AI ke galeri foto kamu.';

  @override
  String get wardrobeSomePhotosSkipped => 'Beberapa foto dilewati';

  @override
  String get wardrobePhotosNotAdded => 'Foto tidak ditambahkan';

  @override
  String get wardrobePhotoNotAdded => 'Foto tidak ditambahkan';

  @override
  String get wardrobeNotStartedTitle => 'Belum dimulai';

  @override
  String get wardrobeNoRoomTitle => 'Tidak ada ruang';

  @override
  String get wardrobeAddPhotosSemantic => 'Tambah foto';

  @override
  String get batchAddTileLabel => 'Tambah';

  @override
  String get batchProfileLinkLabel => 'Tautan profil';

  @override
  String get wardrobeImportFromProfileTitle => 'Impor dari profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Tambah beberapa foto';

  @override
  String get wardrobeClearAction => 'Hapus';

  @override
  String get wardrobeRefreshTooltip => 'Segarkan';

  @override
  String get batchNoPhotosYetTitle => 'Belum ada foto';

  @override
  String get batchChoosePhotosAction => 'Pilih foto';

  @override
  String get batchWeFindEachPieceBody =>
      'Kami menemukan setiap item dan membuatnya menjadi foto studio.';

  @override
  String get batchPreparingPhotosSemantic => 'Menyiapkan foto';

  @override
  String get batchPhotosProcessedSemantic => 'Foto diproses';

  @override
  String get batchPasteProfileLinkTitle => 'Tempel tautan profil';

  @override
  String get batchPasteProfileLinkBody =>
      'Profil Instagram atau Facebook publik. Kami memindai fotonya, dan kamu memilih apa yang masuk ke lemari.';

  @override
  String get batchClearLinkTooltip => 'Hapus tautan';

  @override
  String get batchStartingButton => 'Memulai';

  @override
  String get batchStartImportAction => 'Mulai impor';

  @override
  String get batchReviewEveryPhotoTitle => 'Kamu meninjau setiap foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Tidak ada yang ditambahkan sampai kamu menyetujuinya.';

  @override
  String get batchPrivateProfilesTitle => 'Profil privat';

  @override
  String get batchPrivateProfilesBody =>
      'Hubungkan akunmu. Instagram juga meminta nama pengguna dan kata sandi.';

  @override
  String get batchUseAnotherLinkAction => 'Gunakan tautan lain';

  @override
  String get batchSignInNeededTitle => 'Perlu masuk';

  @override
  String get batchEnterYourCodeTitle => 'Masukkan kode';

  @override
  String get batchUseUsernamePasswordAction =>
      'Gunakan nama pengguna dan kata sandi';

  @override
  String get batchAlreadyConnectedAction => 'Saya sudah terhubung di browser';

  @override
  String get batchEnterCodeAction => 'Masukkan kode';

  @override
  String get batchTryAnotherWayAction => 'Coba cara lain';

  @override
  String get batchLiveStatus => 'Langsung';

  @override
  String get batchReconnectingStatus => 'Menghubungkan ulang';

  @override
  String get batchSignInToInstagramTitle => 'Masuk ke Instagram';

  @override
  String get batchUsernameLabel => 'Nama pengguna';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Kode, jika kamu pakai verifikasi dua langkah';

  @override
  String get batchAuthenticatorCodeBody =>
      'Gunakan kode 6 digit dari aplikasi authenticator. Kode sering berubah.';

  @override
  String get batchVerifyAction => 'Verifikasi';

  @override
  String get batchFindingPhotosTitle => 'Mencari foto';

  @override
  String get batchImportPausedTitle => 'Impor dijeda';

  @override
  String get batchProcessingPhotosTitle => 'Memproses foto';

  @override
  String get batchWaitingNextPhoto => 'Menunggu foto berikutnya';

  @override
  String get batchCancelImportAction => 'Batalkan impor';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Tidak ada item ditemukan di foto ini.';

  @override
  String get batchEditPieceColoursLabel => 'Warna, dipisahkan koma';

  @override
  String get batchAddToClosetAction => 'Tambahkan ke lemari';

  @override
  String get batchSkipPhotoAction => 'Lewati foto ini';

  @override
  String get batchImportCompleteTitle => 'Impor selesai';

  @override
  String get batchImportFailedTitle => 'Impor gagal';

  @override
  String get batchImportCancelledTitle => 'Impor dibatalkan';

  @override
  String get batchImportErrorBody => 'Terjadi kesalahan saat mengimpor.';

  @override
  String get batchNothingMoreImportedBody =>
      'Tidak ada lagi yang diimpor dari profil ini.';

  @override
  String get batchViewClosetAction => 'Lihat lemari';

  @override
  String get batchStartOverAction => 'Mulai ulang';

  @override
  String get wardrobeAddPieceTitle => 'Tambahkan item';

  @override
  String get wardrobeAddDetailsTitle => 'Tambahkan detail';

  @override
  String get wardrobeScanningTitle => 'Pemindaian';

  @override
  String get batchReviewPiecesTitle => 'Periksa item';

  @override
  String get wardrobeGalleryAction => 'Galeri';

  @override
  String get wardrobeCameraAction => 'Kamera';

  @override
  String get wardrobeNewBadge => 'Baru';

  @override
  String get wardrobeRemovePhotoTooltip => 'Hapus foto';

  @override
  String get batchRunInBackgroundTooltip => 'Jalankan di latar belakang';

  @override
  String get batchStepOneOfTwo => 'Langkah 1 dari 2';

  @override
  String get batchStepTwoOfTwo => 'Langkah 2 dari 2';

  @override
  String get batchUploadingPhotosTitle => 'Mengunggah foto';

  @override
  String get batchFindingPiecesTitle => 'Mencari item';

  @override
  String get batchMakingStudioPhotosTitle => 'Membuat foto studio';

  @override
  String get batchStoppedLabel => 'Berhenti';

  @override
  String get batchFindingPiecesStoppedTitle => 'Pencarian item berhenti';

  @override
  String get batchCancelledLabel => 'Dibatalkan';

  @override
  String get batchAllDoneTitle => 'Selesai';

  @override
  String get batchOpeningPiecesBody => 'Membuka item Anda';

  @override
  String get batchNothingSavedBody => 'Tidak ada yang disimpan.';

  @override
  String get batchFindingPiecesFailedBody => 'Pencarian item gagal.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Pencarian item berhenti lebih awal.';

  @override
  String get batchStopFindingPiecesTitle => 'Hentikan pencarian item?';

  @override
  String get batchStopFindingPiecesBody =>
      'Pemindaian akan berhenti dan tidak ada yang disimpan. Item yang sudah ditemukan akan tetap ada di aktivitas Anda hingga Anda menutupnya.';

  @override
  String get batchKeepGoingAction => 'Lanjutkan';

  @override
  String get batchTryAgainAction => 'Coba lagi';

  @override
  String get batchBackToPhotosAction => 'Kembali ke foto';

  @override
  String get batchSkipAllAction => 'Lewati semua';

  @override
  String get batchIncludeAllAction => 'Sertakan semua';

  @override
  String get batchNoPiecesFoundTitle => 'Tidak ada ditemukan';

  @override
  String get batchNoPiecesFoundBody =>
      'Tidak ada pakaian yang ditemukan di foto ini.';

  @override
  String get batchChooseOtherPhotosAction => 'Pilih foto lain';

  @override
  String get batchUseCaseHelper =>
      'Ditambahkan ke setiap barang yang disimpan.';

  @override
  String get batchDiscardPiecesTitle => 'Buang barang ini?';

  @override
  String get batchDiscardPiecesBody =>
      'Tidak ada yang disimpan dari batch ini.';

  @override
  String get batchKeepAction => 'Simpan';

  @override
  String get batchDiscardAction => 'Buang';

  @override
  String get batchRemovePieceTitle => 'Hapus barang ini?';

  @override
  String get batchRemovePieceBody => 'Tidak disimpan ke lemari kamu.';

  @override
  String get batchRemoveAction => 'Hapus';

  @override
  String get batchChoosePiecesToSave => 'Pilih barang untuk disimpan';

  @override
  String get batchDiscardAllAction => 'Buang semua';

  @override
  String get batchNothingSavedRetryBody =>
      'Tidak ada yang disimpan. Coba lagi.';

  @override
  String get batchNotSavedTitle => 'Tidak disimpan';

  @override
  String get batchSavingLabel => 'Menyimpan';

  @override
  String get batchSendToBackgroundAction => 'Kirim ke latar belakang';

  @override
  String get batchStillWorkingMessage =>
      'Masih diproses. Kami akan beri tahu saat barangmu siap.';

  @override
  String get batchRunningInBackgroundTitle => 'Berjalan di latar belakang';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Foto studio terhenti di awal. Kamu tetap bisa menyimpan barang ini.';

  @override
  String get batchTapPieceToSkip => 'Ketuk barang untuk melewati.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Foto studio masih dalam proses. Kamu bisa keluar — kami akan beri tahu.';

  @override
  String get batchLeaveAction => 'Keluar';

  @override
  String get batchPeopleInPhotosTitle => 'Orang di foto';

  @override
  String get batchIncludeAction => 'Sertakan';

  @override
  String get batchSkipAction => 'Lewati';

  @override
  String get batchYourPhotoIsUsedLabel => 'Foto kamu digunakan';

  @override
  String get batchMakingStudioPhotoLabel => 'Membuat foto studio';

  @override
  String get batchNoStudioPhotoBody =>
      'Tidak ada foto studio. Foto kamu digunakan.';

  @override
  String get batchEnterDetailsYourselfAction => 'Isi detail sendiri';

  @override
  String get batchChooseAnotherPhotoAction => 'Pilih foto lain';

  @override
  String get batchConnectionLostTitle => 'Koneksi terputus';

  @override
  String get batchConnectionLostBody => 'Periksa koneksi Anda, lalu coba lagi.';

  @override
  String get batchDailyLimitTitle => 'Batas harian tercapai';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Upgrade ke Pro untuk lebih banyak scan, atau isi detail sendiri.';

  @override
  String get batchDailyLimitBodyFree =>
      'Pindai Anda akan direset besok. Anda dapat mengisi detail sendiri sekarang.';

  @override
  String get batchSeePlansAction => 'Lihat paket';

  @override
  String get batchAiBusyTitle => 'AI kami sedang sibuk';

  @override
  String get batchAiBusyBody =>
      'Ini dari sisi kami. Coba lagi dalam beberapa menit.';

  @override
  String get batchNoPiecesBody =>
      'Coba foto yang lebih jelas, atau isi detail sendiri.';

  @override
  String get batchScanningUnavailableTitle => 'Pindai tidak tersedia';

  @override
  String get batchScanningUnavailableBody =>
      'Isi detail sendiri untuk saat ini.';

  @override
  String get batchScanDidNotFinishTitle => 'Pindai tidak selesai';

  @override
  String get batchTryAgainBody => 'Coba lagi.';

  @override
  String get billingTitle => 'Langganan';

  @override
  String get billingUpgradeHeading => 'Upgrade paket Anda';

  @override
  String get billingUpgradeOnPlusBody => 'Fitur sama, batas lebih tinggi.';

  @override
  String get billingUpgradeBody =>
      'Plus dan Pro memiliki fitur yang sama. Pilih batas yang Anda butuhkan.';

  @override
  String get billingWebUnavailableBody =>
      'Upgrade online belum tersedia. Kode promo atau rujukan masih dapat membuka Plus atau Pro. Undah teman di bawah untuk mendapatkan bulan gratis.';

  @override
  String get billingPlansStale =>
      'Paket terbaru tidak dapat dimuat. Harga mungkin tidak terkini.';

  @override
  String get billingMonthly => 'Bulanan';

  @override
  String get billingYearly => 'Tahunan';

  @override
  String get billingCurrentPlan => 'Paket saat ini';

  @override
  String get billingActive => 'Aktif';

  @override
  String get billingThisMonth => 'Bulan ini';

  @override
  String get billingItemExtractions => 'Ekstraksi item';

  @override
  String get billingOutfitVisualizations => 'Visualisasi outfit';

  @override
  String get billingNearLimitUpgrade =>
      'Anda mendekati batas bulan ini. Upgrade untuk lebih banyak.';

  @override
  String get billingNearLimitResets =>
      'Anda mendekati batas bulan ini. Akan direset di awal bulan depan.';

  @override
  String get billingStoreUnavailable =>
      'Upgrade belum tersedia di toko. Coba lagi nanti.';

  @override
  String get billingManageHeading => 'Kelola paket Anda';

  @override
  String get billingCancelPlan => 'Batalkan langganan';

  @override
  String get billingCancelKeepsAccess =>
      'Akses Anda tetap aktif sampai akhir periode penagihan ini.';

  @override
  String get billingCancelConfirmTitle => 'Batalkan langganan Anda?';

  @override
  String get billingKeepPlan => 'Pertahankan paket';

  @override
  String get billingCancelPlanAction => 'Batalkan paket';

  @override
  String get billingBilledMonthly => 'Penagihan bulanan';

  @override
  String get billingBilledYearly => 'Penagihan tahunan';

  @override
  String get billingVirtualTryOn => 'Coba virtual';

  @override
  String get billingPrioritySupport => 'Dukungan prioritas';

  @override
  String get billingDisclosureProRenewing =>
      'Pro adalah langganan perpanjangan otomatis';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus dan Pro adalah langganan perpanjangan otomatis';

  @override
  String get billingDisclosureAppleBilling =>
      'Pembayaran ditagihkan ke Apple ID Anda saat konfirmasi pembelian.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Pembayaran ditagihkan ke akun Google Play Anda saat konfirmasi pembelian.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Langganan Anda diperpanjang otomatis dengan periode dan harga yang sama kecuali Anda menonaktifkan perpanjangan otomatis setidaknya 24 jam sebelum periode saat ini berakhir.';

  @override
  String get billingDisclosureAppleManage =>
      'Kelola atau batalkan kapan saja di Pengaturan › Apple ID Anda › Langganan.';

  @override
  String get billingDisclosureGoogleManage =>
      'Kelola atau batalkan kapan saja di Google Play › Pembayaran dan langganan.';

  @override
  String get billingReferFriend => 'Ajak teman';

  @override
  String get billingHowItWorks => 'Cara kerjanya';

  @override
  String get billingHowShareTitle => 'Bagikan tautan Anda';

  @override
  String get billingHowShareBody => 'Kirimkan ke teman Anda.';

  @override
  String get billingHowSignUpTitle => 'Mereka mendaftar';

  @override
  String get billingHowSignUpBody =>
      'Teman Anda bergabung melalui tautan tersebut.';

  @override
  String get billingHowBothTitle => 'Kamu berdua dapat Pro';

  @override
  String get billingHowBothBody =>
      'Setiap orang mendapatkan satu bulan Pro gratis.';

  @override
  String get billingYourReferrals => 'Referral Anda';

  @override
  String get billingInvited => 'Diundang';

  @override
  String get billingJoined => 'Bergabung';

  @override
  String get billingMonthsEarned => 'Bulan yang diperoleh';

  @override
  String get billingInviteFriend => 'Undang teman';

  @override
  String get billingInviteBody =>
      'Kamu dan temanmu masing-masing mendapat satu bulan Pro.';

  @override
  String get billingYourCode => 'Kode kamu';

  @override
  String get billingCopyLink => 'Salin tautan';

  @override
  String get billingShareInvite => 'Bagikan undangan';

  @override
  String get giftUnavailable =>
      'Undangan hadiah tidak tersedia pada versi ini.';

  @override
  String get giftPageTitle => 'Kirimkan FitCheck Pro sebagai Hadiah';

  @override
  String get giftNoAllowances =>
      'Tidak ada undangan hadiah gratis yang tersedia saat ini.';

  @override
  String get giftFormTitle => 'Kirimkan undangan gratis';

  @override
  String get giftFormBody =>
      'Penerima akan mengklaim hadiah ini dengan email yang terverifikasi. Kami tidak mengirim email untukmu.';

  @override
  String get giftFieldFrom => 'Dari';

  @override
  String get giftFieldRecipientName => 'Nama penerima';

  @override
  String get giftFieldRecipientEmail => 'Email penerima';

  @override
  String get giftFieldOccasion => 'Kesempatan (opsional)';

  @override
  String get giftNoOccasion => 'Tanpa kesempatan';

  @override
  String get giftOccasionBirthday => 'Ulang tahun';

  @override
  String get giftOccasionAnniversary => 'Ulang tahun pernikahan';

  @override
  String get giftOccasionOther => 'Lainnya';

  @override
  String get giftFieldCardGreeting => 'Salam kartu';

  @override
  String get giftFieldCardGreetingHelper =>
      'Teks ini akan tampil di kartu persis seperti yang ditulis.';

  @override
  String get giftFieldPrivateNote => 'Catatan pribadi (opsional)';

  @override
  String get giftCreateAction => 'Buat hadiah gratis';

  @override
  String get giftClaimedTitle => 'Hadiah sudah diklaim';

  @override
  String get giftClaimedActive => 'Hadiah FitCheck Pro kamu sudah aktif.';

  @override
  String get giftClaimedQueued =>
      'Hadiah FitCheck Pro kamu akan aktif setelah akses saat ini berakhir.';

  @override
  String get giftLinkCopied => 'Tautan hadiah disalin ke clipboard.';

  @override
  String get giftErrorName => 'Masukkan nama.';

  @override
  String get giftErrorEmail => 'Masukkan alamat email yang valid.';

  @override
  String get giftErrorGreeting => 'Masukkan salam kartu.';

  @override
  String get giftErrorGreetingLength => 'Gunakan maksimal 80 karakter.';

  @override
  String get giftClaimAction => 'Klaim hadiah';

  @override
  String get giftCardPreview => 'Pratinjau kartu';

  @override
  String get giftGiftForYou => 'Hadiah untukmu';

  @override
  String get giftGiftWaiting => 'Sebuah hadiah menantimu';

  @override
  String get giftOpenBody =>
      'Buka hadiahmu untuk mengklaimnya dengan email yang diverifikasi.';

  @override
  String get giftOpenGifts => 'Buka hadiah';

  @override
  String get giftSendInvitation => 'Kirim undangan';

  @override
  String get settingsAiProviderSection => 'Penyedia';

  @override
  String get settingsAiCustom => 'Kustom';

  @override
  String get settingsAiUrlHelper =>
      'Gunakan URL publik yang bisa dicapai server. Localhost tidak berfungsi dari server kami.';

  @override
  String get settingsAiConnectionSection => 'Koneksi';

  @override
  String get settingsAiApiUrl => 'URL API';

  @override
  String get settingsAiApiKey => 'Kunci API';

  @override
  String get settingsAiApiKeySaved =>
      'Tersimpan. Kosongkan untuk mempertahankan.';

  @override
  String get settingsAiChatModel => 'Model chat';

  @override
  String get settingsAiVisionModel => 'Model vision (opsional)';

  @override
  String get settingsAiImageModel => 'Model gambar (opsional)';

  @override
  String get settingsAiImageModelNote =>
      'Generasi gambar memerlukan chat completions yang kompatibel OpenAI dengan response_modalities.';

  @override
  String get settingsAiTestConnection => 'Uji koneksi';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarGoToToday => 'Ke hari ini';

  @override
  String get calendarConnectTooltip => 'Hubungkan kalender';

  @override
  String get calendarAddEvent => 'Tambahkan acara';

  @override
  String get calendarEmptyTitle => 'Tidak ada rencana';

  @override
  String get calendarEmptyBody => 'Tambahkan acara dan rencanakan pakaian.';

  @override
  String get calendarPreviousMonth => 'Bulan sebelumnya';

  @override
  String get calendarNextMonth => 'Bulan berikutnya';

  @override
  String get calendarAllDay => 'Sepanjang hari';

  @override
  String get calendarOutfitLinked => 'Outfit terhubungi';

  @override
  String get calendarEventOptions => 'Opsi acara';

  @override
  String get calendarDeleteTitle => 'Hapus acara ini?';

  @override
  String get calendarChangeOutfit => 'Ganti outfit';

  @override
  String get calendarLinkOutfit => 'Hubungkan outfit';

  @override
  String get calendarRemoveOutfit => 'Hapus outfit';

  @override
  String get calendarNewEvent => 'Acara baru';

  @override
  String get calendarEditEvent => 'Edit acara';

  @override
  String get calendarTitleLabel => 'Judul';

  @override
  String get calendarTitleRequired => 'Tambahkan judul';

  @override
  String get calendarEndBeforeStart => 'Akhir setelah waktu mulai';

  @override
  String get calendarStarts => 'Mulai';

  @override
  String get calendarEnds => 'Berakhir';

  @override
  String get calendarPlaceOptional => 'Lokasi (opsional)';

  @override
  String get calendarNotesOptional => 'Catatan (opsional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Buat outfit, lalu hubungkan ke acara ini.';

  @override
  String get calendarBuildOutfit => 'Buat outfit';

  @override
  String get calendarConnectionsTitle => 'Kalender';

  @override
  String get calendarConnectionsBody =>
      'Acara yang kamu tambahkan di sini tetap di FitCheck.';

  @override
  String get calendarDisconnect => 'Putuskan';

  @override
  String get calendarNotAvailable => 'Belum tersedia';

  @override
  String get profileSectionExplore => 'Jelajahi';

  @override
  String get profileNavTryOn => 'Try-on';

  @override
  String get profileNavRewards => 'Hadiah';

  @override
  String get profileSupport => 'Dukungan';

  @override
  String get profileHelp => 'Bantuan';

  @override
  String get profileAbout => 'Tentang';

  @override
  String get profileAboutBody =>
      'Lemari, outfit, dan rencanamu di satu tempat.';

  @override
  String get profileSignOutTitle => 'Keluar?';

  @override
  String get profileSignOutBody => 'Kamu bisa masuk kembali kapan saja.';

  @override
  String get profileEditTitle => 'Edit profil';

  @override
  String get profileYourProfile => 'Profil kamu';

  @override
  String get profileBodyProfiles => 'Profil Tubuh';

  @override
  String get profileBodyEmptyTitle => 'Belum ada profil tubuh';

  @override
  String get profileBodyEmptyBody =>
      'Tambah tinggi dan bentuk tubuhmu untuk kecocokan yang lebih baik.';

  @override
  String get profileBodyAdd => 'Tambah profil';

  @override
  String get profileBodyDefaultNote =>
      'Profil default digunakan untuk kecocokan dan try-on.';

  @override
  String get profileBodyDefaultBadge => 'Default';

  @override
  String get profileBodyMakeDefault => 'Jadikan default';

  @override
  String get profileBodyDeleteBody => 'Ini tidak dapat dibatalkan.';

  @override
  String get profileBodyRequired => 'Wajib diisi';

  @override
  String get profileBodyCheckNumber => 'Periksa angka ini';

  @override
  String get profileBodyNew => 'Profil tubuh baru';

  @override
  String get profileBodyNameHint => 'Contoh, Aku';

  @override
  String get profileBodyHeight => 'Tinggi';

  @override
  String get profileBodyWeight => 'Berat';

  @override
  String get profileBodyBuild => 'Bentuk tubuh';

  @override
  String get profileBodySkinTone => 'Nada kulit';

  @override
  String get profileBirthDateNeededBody =>
      'Tambah tanggal lahir untuk melengkapi jam lahir.';

  @override
  String get profileBirthDateNeededTitle => 'Tanggal lahir diperlukan';

  @override
  String get profilePartlySavedBody =>
      'Nama dan foto tersimpan. Detail lahir gagal; coba lagi nanti.';

  @override
  String get profilePartlySavedTitle => 'Tersimpan sebagian';

  @override
  String get profileSavedBody => 'Profilmu tersimpan.';

  @override
  String get profileChangePhoto => 'Ubah foto profil';

  @override
  String get profilePhotoLabel => 'Foto profil';

  @override
  String get profilePhotoHint => 'Ketuk untuk pilih yang baru';

  @override
  String get profileBirthDateLabel => 'Tanggal lahir (opsional)';

  @override
  String get profileBirthTimeLabel => 'Jam lahir (opsional)';

  @override
  String get profileBirthTimeHelper => 'Membuat saran Veda lebih akurat';

  @override
  String get profileBirthPlaceLabel => 'Tempat lahir (opsional)';

  @override
  String get profileBirthPlaceHint => 'Contoh, New Delhi, India';

  @override
  String get profileHelpContactTitle => 'Tanyakan kami apa saja';

  @override
  String get profileHelpContactBody =>
      'Kirim pesan dan kami balas lewat email, biasanya dalam satu hari.';

  @override
  String get profileHelpContactAction => 'Hubungi bantuan';

  @override
  String get profileHelpFaqTitle => 'Pertanyaan umum';

  @override
  String get profileFaqAddPiecesTitle => 'Cara menambah item ke lemari?';

  @override
  String get profileFaqAddPiecesBody =>
      'Ketuk Tambah item di tab Lemari. Foto atau pilih dari galeri; kami akan menemukan dan memberi label itemnya.';

  @override
  String get profileFaqMatchingTitle =>
      'Bagaimana cara kerja pencocokan busana?';

  @override
  String get profileFaqMatchingBody =>
      'Buka Untukmu dan pilih item yang kamu miliki. Kami sarankan padanan dan menyusun busana lengkap dari lemari Anda.';

  @override
  String get profileFaqTryOnTitle =>
      'Bisakah pakai foto sendiri untuk coba pakai?';

  @override
  String get profileFaqTryOnBody =>
      'Ya. Tambah foto full-body, lalu pilih item untuk melihat tampil di tubuh Anda.';

  @override
  String get profileFaqRewardsTitle => 'Cara mendapat reward?';

  @override
  String get profileFaqRewardsBody =>
      'Rencanakan dan catat busana secara rutin. Streak dan pencapaian akan bertambah.';

  @override
  String get profileFaqPrivacyTitle => 'Apakah lemari saya privat?';

  @override
  String get profileFaqPrivacyBody =>
      'Ya. Lemari dan busana Anda privat kecuali membagikan tautan untuk satu busana.';

  @override
  String get profileHelpMoreTitle => 'Bantuan lainnya';

  @override
  String get profileHelpGuides => 'Panduan';

  @override
  String get profileHelpGuidesBody => 'Cara kerja tiap fitur';

  @override
  String get feedbackCategoryBug => 'Ada yang rusak';

  @override
  String get feedbackCategoryIdea => 'Ide';

  @override
  String get feedbackCategoryGeneral => 'Umum';

  @override
  String get feedbackCategoryHelp => 'Saya butuh bantuan';

  @override
  String get feedbackHintBug =>
      'Apa yang terjadi dan apa harapan Anda? Langkah detail membantu kami perbaiki.';

  @override
  String get feedbackHintIdea => 'Apa yang Anda inginkan dan mengapa?';

  @override
  String get feedbackHintGeneral =>
      'Beritahu kami pendapat Anda atau ajukan pertanyaan.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Kamu bisa menambah sampai 5 gambar.';

  @override
  String get feedbackAttachmentLimitTitle => 'Batas tercapai';

  @override
  String get feedbackImageTooLargeBody => 'Pilih gambar di bawah 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Gambar terlalu besar';

  @override
  String get feedbackTitle => 'Kirim masukan';

  @override
  String get feedbackAboutLabel => 'Tentang apa?';

  @override
  String get feedbackSubjectLabel => 'Subjek';

  @override
  String get feedbackSubjectRequired => 'Tambahkan subjek';

  @override
  String get feedbackSubjectTooShort => 'Subjek minimal 3 karakter';

  @override
  String get feedbackDetailsLabel => 'Detail';

  @override
  String get feedbackDetailsRequired => 'Tambahkan detail';

  @override
  String get feedbackDetailsTooShort => 'Deskripsi minimal 10 karakter';

  @override
  String get feedbackAddScreenshot => 'Tambahkan tangkapan layar';

  @override
  String get feedbackAttachmentHint => 'Maks 5, masing-masing 5 MB';

  @override
  String get feedbackSend => 'Kirim';

  @override
  String get feedbackEmptyTitle => 'Belum ada yang dikirim';

  @override
  String get feedbackEmptyBody =>
      'Yang Anda kirimkan akan tampil di sini beserta statusnya.';

  @override
  String get feedbackHistoryTitle => 'Yang Anda kirimkan';

  @override
  String get feedbackStatusOpen => 'Dibuka';

  @override
  String get feedbackStatusInProgress => 'Sedang diproses';

  @override
  String get feedbackStatusResolved => 'Selesai';

  @override
  String get feedbackStatusClosed => 'Ditutup';

  @override
  String get legalIntro =>
      'Cara kami melindungi data Anda, serta ketentuan penggunaan FitCheck AI.';

  @override
  String get legalPolicies => 'Kebijakan';

  @override
  String get legalPrivacySubtitle => 'Apa yang kami kumpulkan dan mengapa';

  @override
  String get legalTermsTitle => 'Ketentuan layanan';

  @override
  String get legalTermsSubtitle => 'Aturan penggunaan aplikasi';

  @override
  String get legalLicences => 'Lisensi sumber terbuka';

  @override
  String get legalSupportSubtitle => 'Bantuan, kontak, dan permintaan privasi';

  @override
  String get legalReportAbuse => 'Laporkan masalah atau penyalahgunaan';

  @override
  String get permissionCameraTitle => 'Akses Kamera';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI menggunakan kamera Anda untuk memotret pakaian dan outfit Anda guna coba pakai AI dan penataan lemari.';

  @override
  String get permissionPhotoTitle => 'Akses Foto';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI memerlukan akses ke foto Anda agar Anda dapat memilih gambar pakaian dan outfit untuk fitur AI dan lemari Anda.';

  @override
  String get permissionNotNow => 'Nanti Saja';

  @override
  String get permissionOpenSettings => 'Buka Pengaturan';

  @override
  String authSignedInAs(String name) {
    return 'Masuk sebagai $name';
  }

  @override
  String get authSignedIn => 'Sudah masuk';

  @override
  String get authWelcomeBackTitle => 'Selamat datang kembali';

  @override
  String get authSignInFailed => 'Gagal masuk';

  @override
  String get authWelcomeTitle => 'Selamat datang';

  @override
  String get authSignUpFailed => 'Gagal mendaftar';

  @override
  String get authGoogleSignInFailed => 'Gagal masuk Google';

  @override
  String get authAppleSignInFailed => 'Gagal masuk Apple';

  @override
  String get authConfirmEmailTitle => 'Konfirmasi email Anda';

  @override
  String get authConfirmEmailBody =>
      'Cek kotak masuk untuk email konfirmasi, lalu masuk.';

  @override
  String get authClosetReady => 'Lemari Anda siap.';

  @override
  String get authSignedOutTitle => 'Sudah keluar';

  @override
  String get authSignedOutBody => 'Anda telah keluar.';

  @override
  String get authSignOutFailed => 'Gagal keluar';

  @override
  String get authEmailSentTitle => 'Email terkirim';

  @override
  String get authResetLinkSent => 'Cek email Anda untuk tautan reset.';

  @override
  String get authPasswordUpdatedTitle => 'Kata sandi diperbarui';

  @override
  String get authPasswordUpdated => 'Kata sandi Anda diperbarui.';

  @override
  String get authPasswordNotUpdated => 'Kata sandi tidak diperbarui';

  @override
  String get authCouldNotSendEmail => 'Gagal mengirim email';

  @override
  String get authEmailNotSent => 'Email tidak terkirim';

  @override
  String get authResendSentBody => 'Kami telah mengirim email konfirmasi baru.';

  @override
  String get outfitPreviewWithAi => 'Pratinjau dengan AI';

  @override
  String get outfitNewPreview => 'Buat pratinjau baru';

  @override
  String get outfitBuilderClosetHeading => 'Lemari Anda';

  @override
  String get outfitBuilderSearchHint => 'Cari item';

  @override
  String get outfitClearSearch => 'Hapus pencarian';

  @override
  String get outfitBuilderAddPiecesTitle => 'Tambahkan item dulu';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfit dibuat dari item di lemari Anda.';

  @override
  String get outfitBuilderNoMatches => 'Tidak ada item yang cocok.';

  @override
  String get outfitNameLabel => 'Nama outfit';

  @override
  String get outfitNameHint => 'Contoh: Linen akhir pekan';

  @override
  String get outfitPreviewSemantic => 'Pratinjau outfit oleh AI';

  @override
  String get outfitChoosePieces => 'Pilih bagian';

  @override
  String get outfitTapPiecesHint => 'Ketuk bagian di bawah untuk menambahkan.';

  @override
  String get outfitShareTooltip => 'Berbagi';

  @override
  String get outfitSaveFavourite => 'Simpan ke favorit';

  @override
  String get outfitPiecesHeading => 'Bagian';

  @override
  String get outfitWearHistoryEmpty =>
      'Pakai sekali dan tanggal muncul di sini.';

  @override
  String get outfitWearHistoryTitle => 'Riwayat pemakaian';

  @override
  String get outfitWearHistoryError => 'Gagal memuat tanggal.';

  @override
  String get outfitWornOn => 'Dipakai pada';

  @override
  String get outfitEditTitle => 'Ubah outfit';

  @override
  String get outfitSavedPhotosFailed => 'Detail tersimpan, foto tidak';

  @override
  String get outfitNoPhotosBody =>
      'Belum ada foto. Outfit menampilkan bagian-bagiannya.';

  @override
  String get outfitOccasionLabel => 'Kasus';

  @override
  String get outfitOccasionNone => 'Tidak ada';

  @override
  String get outfitTagsHint => 'Pisahkan dengan koma';

  @override
  String get outfitDraftBody => 'Tersembunyi dari daftar utama';

  @override
  String get outfitPublic => 'Publik';

  @override
  String get outfitPublicBody => 'Siapa pun dengan tautan bisa melihat';

  @override
  String get outfitDeleteFromDetail =>
      'Hapus outfit ini dari halaman detailnya.';

  @override
  String get outfitNewCollection => 'Koleksi baru';

  @override
  String get outfitNoCollectionsTitle => 'Belum ada koleksi';

  @override
  String get outfitNoCollectionsBody =>
      'Kelompokkan outfit berdasarkan perjalanan, musim, atau suasana.';

  @override
  String get outfitCreateCollection => 'Buat koleksi';

  @override
  String get outfitAddOutfits => 'Tambahkan outfit';

  @override
  String get outfitRename => 'Ubah nama';

  @override
  String get outfitCollectionDeleteBody =>
      'Outfit di dalamnya tetap dipertahankan.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfit belum dimuat';

  @override
  String get outfitRenameCollection => 'Ubah nama koleksi';

  @override
  String get outfitDescriptionOptional => 'Deskripsi (opsional)';

  @override
  String get outfitAllInCollection => 'Semua outfit sudah ada di koleksi ini.';

  @override
  String get photoshootSubtitleUpload => 'Potret studio dari foto Anda';

  @override
  String get photoshootSubtitleConfigure => 'Pilih gaya, format, dan jumlah';

  @override
  String get photoshootSubtitleGenerating => 'Butuh 1-2 menit';

  @override
  String get photoshootAddPhotosSemantic => 'Tambah foto dari galeri';

  @override
  String get photoshootUploadTitle => 'Tambah 1–4 foto diri Anda';

  @override
  String get photoshootUploadBody => 'Ketuk untuk pilih dari galeri';

  @override
  String get photoshootAddToContinue => 'Tambah foto untuk lanjut';

  @override
  String get photoshootAddAnotherPhoto => 'Tambah foto lagi';

  @override
  String get photoshootTipsTitle => 'Untuk hasil terbaik';

  @override
  String get photoshootTipsBody =>
      'Gunakan foto wajah yang jelas, terang, dari beberapa sudut. Hindari kacamata hitam dan topi.';

  @override
  String get photoshootStarting => 'Memulai';

  @override
  String get photoshootCancelling => 'Membatalkan';

  @override
  String get photoshootFailed => 'Gagal';

  @override
  String get recommendTabMatches => 'Cocok';

  @override
  String get recommendTabComplete => 'Lengkapi';

  @override
  String get recommendTabWeather => 'Cuaca';

  @override
  String get recommendTabColours => 'Warna';

  @override
  String get recommendTabShop => 'Belanja';

  @override
  String get recommendNoMatchesTitle => 'Belum ada yang cocok';

  @override
  String get recommendNoMatchesBody =>
      'Pilih item, kami akan cari yang serasi.';

  @override
  String get recommendPickPiece => 'Pilih item';

  @override
  String get recommendNothingMatchesTitle => 'Belum ada yang cocok';

  @override
  String get recommendNothingMatchesBody =>
      'Coba item lain, atau tambahkan ke lemari.';

  @override
  String get recommendChangePieces => 'Ganti item';

  @override
  String get recommendDefaultReason => 'Cocok dengan item pilihanmu.';

  @override
  String get recommendCompleteTitle => 'Lengkapi tampilan';

  @override
  String get recommendCompleteBody => 'Pilih item, kami lengkapi sisanya.';

  @override
  String get recommendWorking => 'Memproses';

  @override
  String get recommendGenerate => 'Buat';

  @override
  String get recommendChooseStyleBody => 'Pilih gaya, lalu buat.';

  @override
  String get recommendNoLooksTitle => 'Tidak ada looks untuk item ini';

  @override
  String get recommendNoLooksBody => 'Coba gaya atau item lain.';

  @override
  String get recommendDefaultLook => 'Look untuk itemmu';

  @override
  String get recommendNoPiecesBody =>
      'Tidak ada item yang cocok untuk look ini.';

  @override
  String get recommendCityLabel => 'Kota';

  @override
  String get recommendCheck => 'Cek';

  @override
  String get recommendWeatherTitle => 'Ceramanya seperti apa?';

  @override
  String get recommendWeatherBody => 'Isi kotamu untuk dapat saran hari ini.';

  @override
  String get recommendWearToday => 'Pakai hari ini';

  @override
  String get recommendWeatherNoPieces =>
      'Belum ada item di lemari untuk cuaca ini.';

  @override
  String get recommendBudgetLabel => 'Anggaran sampai';

  @override
  String get recommendLooking => 'Mencari';

  @override
  String get recommendFindWhatToBuy => 'Temukan apa yang harus dibeli';

  @override
  String get recommendFillGapsTitle => 'Isi kekuranganmu';

  @override
  String get recommendFillGapsBody =>
      'Tetapkan anggaran dan kami sarankan apa yang kurang di lemari.';

  @override
  String get recommendNoGapsTitle => 'Tidak ada kekurangan';

  @override
  String get recommendNoGapsBody =>
      'Coba anggaran lebih besar atau kategori lain.';

  @override
  String get recommendMoodEveryday => 'Sehari-hari';

  @override
  String get recommendMoodBigMeeting => 'Rapat besar';

  @override
  String get recommendDayLabel => 'Hari';

  @override
  String get recommendReadingStars => 'Membaca bintang';

  @override
  String get recommendGetMyColours => 'Dapatkan warna saya';

  @override
  String get recommendLuckyColoursTitle => 'Warna harismu';

  @override
  String get recommendLuckyColoursBody =>
      'Pilih hari dan kami sarankan warna serta itemnya.';

  @override
  String get recommendLuckyColoursSection => 'Warna hoki';

  @override
  String get recommendAvoidColoursSection => 'Warna yang sebaiknya dihindari';

  @override
  String get recommendBirthDateTitle => 'Tambahkan tanggal lahir';

  @override
  String get recommendBirthDateBody =>
      'Tanggal lahir diperlukan untuk membaca warna.';

  @override
  String get recommendEditProfile => 'Ubah profil';

  @override
  String get recommendNothingThisDay => 'Tidak ada untuk hari ini.';

  @override
  String get recommendUnnamedColour => 'Warna tanpa nama';

  @override
  String get recommendFromCloset => 'Dari lemarimu';

  @override
  String get recommendNoPiecesInColours => 'Belum ada item dengan warna ini.';

  @override
  String get recommendOutfitIdeas => 'Ide busana';

  @override
  String get recommendNoOutfitsInColours =>
      'Belum ada busana lengkap dengan warna ini.';

  @override
  String get recommendDefaultOutfitIdea => 'Ide busana';

  @override
  String get recommendPickUpToThree => 'Pilih hingga 3 item';

  @override
  String get recommendEmptyClosetBody =>
      'Tambahkan beberapa item dulu, lalu kembali untuk jodohan.';

  @override
  String get dashboardDressForDay => 'Berbusana untuk hari di depan.';

  @override
  String get dashboardOutfitOfDay => 'Busana hari ini';

  @override
  String get dashboardFreshLook => 'Tampilan segar';

  @override
  String get subscriptionManageInStoreTitle => 'Kelola di toko';

  @override
  String get subscriptionManageInStoreBody =>
      'Paket ini ditagih melalui toko. Kelola di pengaturan akun toko Anda.';

  @override
  String get subscriptionCancelledTitle => 'Langganan dibatalkan';

  @override
  String get subscriptionCancelledBody =>
      'Paket Anda tetap aktif hingga akhir periode penagihan ini.';

  @override
  String get subscriptionCancelFailedTitle => 'Gagal membatalkan';

  @override
  String get subscriptionCouldNotOpenTitle => 'Gagal dibuka';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Gagal membuka manajemen penagihan.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Gagal membuka tautan.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Gagal memuat tautan Anda';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Gagal memuat tautan rujukan. Coba lagi.';

  @override
  String get subscriptionReferralCopiedTitle => 'Tersalin';

  @override
  String get subscriptionReferralCopiedBody => 'Tautan rujukan disalin.';

  @override
  String get subscriptionReferralShareSubject => 'Coba FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Gabung dengan FitCheck AI dan kami berdua dapat Pro selama sebulan. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Tautan tersalin';

  @override
  String get subscriptionShareUnavailableBody =>
      'Berbagi tidak tersedia, jadi tautan telah disalin.';

  @override
  String get subscriptionShareFailedTitle => 'Gagal berbagi';

  @override
  String get subscriptionShareFailedBody =>
      'Salin tautan dari halaman rujukan.';

  @override
  String get subscriptionStoreReadyTitle => 'Toko siap';

  @override
  String get subscriptionStoreReadyBody =>
      'Harga toko tersedia. Kamu bisa upgrade sekarang.';

  @override
  String get purchaseFailedTitle => 'Pembayaran gagal';

  @override
  String get purchaseUnavailableTitle => 'Pembayaran tidak tersedia';

  @override
  String get purchaseIapUnavailableBody =>
      'Pembelian in-app tidak tersedia di perangkat ini.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Paket ini belum tersedia untuk pembelian.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Paket ini belum tersedia di toko. Cek lagi nanti.';

  @override
  String get purchaseStartFailedBody =>
      'Pembayaran tidak dapat dimulai. Coba lagi.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Checkout tidak mengembalikan tautan pembayaran.';

  @override
  String get purchasePendingTitle => 'Pembayaran tertunda';

  @override
  String get purchasePendingBody =>
      'Pembayaranmu menunggu persetujuan. Kamu akan mendapat akses segera setelah disetujui.';

  @override
  String get purchaseFailedBody => 'Pembayaran gagal. Coba lagi.';

  @override
  String get purchaseRestoredTitle => 'Dipulihkan';

  @override
  String get purchaseRestoredBody => 'Pembelianmu sudah dipulihkan.';

  @override
  String get purchaseActiveTitle => 'Langganan aktif';

  @override
  String get purchaseActiveBody => 'Langgananmu aktif. Selamat datang.';

  @override
  String get purchaseSignInRequiredTitle => 'Perlu masuk';

  @override
  String get purchaseSignInRequiredBody =>
      'Masuk untuk menyelesaikan pembayaran.';

  @override
  String get purchaseErrorTitle => 'Kesalahan pembayaran';

  @override
  String get purchaseInvalidTransactionBody =>
      'Pembayaran tidak menyertakan ID transaksi yang dapat diverifikasi.';

  @override
  String get purchaseVerificationPendingTitle => 'Verifikasi tertunda';

  @override
  String get purchaseVerificationPendingBody =>
      'Kami tidak dapat memverifikasi pembayaranmu dengan toko sekarang. Proses akan selesai otomatis, dan kamu tidak akan dipotong dua kali.';

  @override
  String get purchaseNotAppliedTitle => 'Pembayaran tidak diterapkan';

  @override
  String get purchaseNotAppliedBody =>
      'Pembelianmu tidak dapat diterapkan ke akunmu. Hubungi dukungan, dan jangan beli lagi.';

  @override
  String get purchaseRestoreFailedTitle => 'Pemulihan gagal';

  @override
  String get purchaseRestoreFailedBody =>
      'Pembayaran tidak dapat dipulihkan. Coba lagi.';

  @override
  String get purchaseRecoveredActiveBody => 'Langgananmu aktif.';

  @override
  String get purchaseCompleteTitle => 'Pembayaran selesai';

  @override
  String get giftCreateFailedTitle => 'Kado tidak dapat dibuat';

  @override
  String get giftClaimFailedTitle => 'Tidak dapat menerima hadiah';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hadiah untukmu',
      one: '1 hadiah untukmu',
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
      other: '$remaining sisa',
      one: '1 sisa',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender mengirimkan $duration FitCheck Pro. $link';
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
  String get giftPreviewPlaceholderRecipient => 'penerima kamu';

  @override
  String get giftPreviewPlaceholderSender => 'kamu';

  @override
  String get settingsSavedTitle => 'Tersimpan';

  @override
  String get settingsNotSavedTitle => 'Tidak tersimpan';

  @override
  String get settingsAiChooseProviderBody => 'Pilih penyedia.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Penyedia kustom memerlukan URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Masukkan kunci API.';

  @override
  String get settingsAiSavedBody => 'Pengaturan AI kamu tersimpan.';

  @override
  String get settingsAiMissingDetailsTitle => 'Detail tidak lengkap';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Masukkan URL API dan model chat untuk menguji.';

  @override
  String get settingsAiKeyNeededTitle => 'Kunci API diperlukan';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Masukkan kunci API kamu untuk menguji. Kunci tersimpan tetap rahasia.';

  @override
  String get settingsAiKeyToTestBody =>
      'Masukkan kunci API kamu untuk menguji.';

  @override
  String get settingsAiConnectedTitle => 'Terhubung';

  @override
  String get settingsAiConnectedBody => 'Koneksi berfungsi.';

  @override
  String get settingsAiTestFailedTitle => 'Tes gagal';

  @override
  String get settingsPreferencesSavedBody => 'Preferensi kamu tersimpan.';

  @override
  String get settingsPasswordNotChangedTitle => 'Kata sandi tidak diubah';

  @override
  String get settingsOAuthPasswordBody =>
      'Akun ini masuk menggunakan Google atau Apple. Gunakan \"Lupa kata sandi\" untuk mengatur kata sandi terlebih dahulu.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Kata sandi saat ini salah.';

  @override
  String get settingsExportReadyTitle => 'Ekspor siap';

  @override
  String get settingsExportReadyBody => 'Ekspor data Anda siap diunduh.';

  @override
  String get settingsLinkCopiedTitle => 'Tautan disalin';

  @override
  String get settingsExportClipboardBody =>
      'Kami tidak dapat membuka browser Anda, jadi kami menyalin tautan unduhan. Tempelkan di browser segera: tautan ini akan kedaluwarsa.';

  @override
  String get settingsExportFailedTitle => 'Ekspor gagal';

  @override
  String get settingsAccountNotDeletedTitle => 'Akun tidak dihapus';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Anda dapat menambahkan hingga $max foto.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Batas foto';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Tambahkan minimal satu foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Tidak ada foto';

  @override
  String get photoshootDescribeLookBody =>
      'Jelaskan tampilan yang Anda inginkan.';

  @override
  String get photoshootPromptNeededTitle => 'Butuh prompt';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Menyiapkan foto Anda';

  @override
  String get photoshootStatusGenerating => 'Sedang menghasilkan';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current dari $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done dari $total selesai';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generasi gagal.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready siap, $failed gagal.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Sebagian selesai';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto siap.',
      one: '1 foto siap.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Koneksi terputus. Silakan coba lagi.';

  @override
  String get photoshootCouldNotCancelTitle => 'Tidak dapat dibatalkan';

  @override
  String get photoshootRetryFailedTitle => 'Percobaan ulang gagal';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Foto $number siap.';
  }

  @override
  String get photoshootReplacedTitle => 'Diganti';

  @override
  String get photoshootSavedToGalleryBody => 'Tersimpan ke galeri Anda.';

  @override
  String get photoshootSavedTitle => 'Tersimpan';

  @override
  String get photoshootNotSavedTitle => 'Tidak tersimpan';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Semua $count foto ada di galeri Anda.',
      one: '1 foto ada di galeri Anda.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved dari $total disimpan.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Beberapa foto tidak tersimpan';

  @override
  String get tryonConsentFeatureLabel => 'Pecaya Coba Virtual';

  @override
  String get tryonAvatarUpdatedBody => 'Fotonya sudah diperbarui.';

  @override
  String get tryonSavedTitle => 'Tersimpan';

  @override
  String get tryonUploadFailedTitle => 'Upload gagal';

  @override
  String get tryonChooseGarmentFirstBody => 'Pilih foto pakaian dulu.';

  @override
  String get tryonNoGarmentTitle => 'Belum ada pakaian';

  @override
  String get tryonWaitForUploadBody => 'Tunggu sampai foto selesai diupload.';

  @override
  String get tryonStillUploadingTitle => 'Masih mengupload';

  @override
  String get tryonAddYourPhotoFirstBody => 'Tambahkan foto kamu dulu.';

  @override
  String get tryonReadyBody => 'Pecaya coba siap.';

  @override
  String get tryonFailedTitle => 'Pecaya coba gagal';

  @override
  String get tryonSavedToGalleryBody => 'Tersimpan ke galeri.';

  @override
  String get tryonNotSavedTitle => 'Tidak tersimpan';

  @override
  String get calendarEventAddedBody => 'Acara ditambahkan';

  @override
  String get calendarEventPlannedTitle => 'Direncanakan';

  @override
  String get calendarEventSavedBody => 'Acara disimpan';

  @override
  String get calendarSavedTitle => 'Tersimpan';

  @override
  String get calendarEventNotSavedTitle => 'Acara tidak tersimpan';

  @override
  String get calendarEventRemovedBody => 'Acara dihapus';

  @override
  String get calendarEventDeletedTitle => 'Terhapus';

  @override
  String get calendarEventNotDeletedTitle => 'Acara tidak terhapus';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit tidak terkait';

  @override
  String get calendarLinkedTitle => 'Terkait';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit tidak dihapus';

  @override
  String get calendarOutfitRemovedBody => 'Outfit dihapus';

  @override
  String get calendarDisconnectedBody => 'Kalender tidak terhubung';

  @override
  String get calendarDisconnectedTitle => 'Terputus';

  @override
  String get calendarNotDisconnectedTitle => 'Kalender masih terhubung';

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
    return '$start hingga $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit terkait';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" akan dihapus.';
  }

  @override
  String get calendarThisAppLabel => 'Aplikasi ini';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Sinkronisasi dengan $provider belum tersedia. Kamu masih bisa menambahkan acara di sini.';
  }

  @override
  String get calendarWeekdaySunShort => 'Min';

  @override
  String get calendarWeekdayMonShort => 'Sen';

  @override
  String get calendarWeekdayTueShort => 'Sel';

  @override
  String get calendarWeekdayWedShort => 'Rab';

  @override
  String get calendarWeekdayThuShort => 'Kam';

  @override
  String get calendarWeekdayFriShort => 'Jum';

  @override
  String get calendarWeekdaySatShort => 'Sab';

  @override
  String get calendarWeekdayMonday => 'Senin';

  @override
  String get calendarWeekdayTuesday => 'Selasa';

  @override
  String get calendarWeekdayWednesday => 'Rabu';

  @override
  String get calendarWeekdayThursday => 'Kamis';

  @override
  String get calendarWeekdayFriday => 'Jumat';

  @override
  String get calendarWeekdaySaturday => 'Sabtu';

  @override
  String get calendarWeekdaySunday => 'Minggu';

  @override
  String get outfitSavedToFavouritesBody => 'Disimpan ke favorit';

  @override
  String get outfitRemovedFromFavouritesBody => 'Dihapus dari favorit';

  @override
  String get outfitNotSavedTitle => 'Tidak tersimpan';

  @override
  String get outfitLoggedAsWornBody => 'Dicatat digunakan hari ini.';

  @override
  String get outfitNicePickTitle => 'Pilihan bagus';

  @override
  String get outfitRemovedBody => 'Outfit dihapus.';

  @override
  String get outfitDeletedTitle => 'Dihapus';

  @override
  String get outfitNotDeletedTitle => 'Tidak terhapus';

  @override
  String get outfitDuplicatedBody => 'Salinan ada di koleksi outfit-mu.';

  @override
  String get outfitDuplicatedTitle => 'Terduplikasi';

  @override
  String get outfitNotDuplicatedTitle => 'Tidak terduplikasi';

  @override
  String get outfitNotSharedTitle => 'Tidak dibagikan';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" siap.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Koleksi tidak dibuat';

  @override
  String get outfitCollectionUpdatedBody => 'Koleksi diperbarui.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Koleksi tidak diperbarui';

  @override
  String get outfitCollectionDeletedBody => 'Koleksi dihapus.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Koleksi tidak dihapus';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfit ditambahkan.',
      one: '1 outfit ditambahkan.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfit tidak ditambahkan';

  @override
  String get outfitPreviewNotCreatedTitle => 'Pratinjau tidak dibuat';

  @override
  String get outfitGiveNameBody => 'Beri nama pada outfit.';

  @override
  String get outfitNameMissingTitle => 'Nama';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Pilih minimal satu item.';

  @override
  String outfitCreatedBody(String name) {
    return '$name ada di koleksi outfit-mu.';
  }

  @override
  String get outfitSavedTitle => 'Tersimpan';

  @override
  String get wardrobeAddedToFavouritesBody => 'Ditambahkan ke favorit';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Dihapus dari favorit';

  @override
  String get wardrobeNotSavedTitle => 'Tidak tersimpan';

  @override
  String get wardrobeLoggedAsWornBody => 'Dicatat dipakai hari ini.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Dihapus dari lemari-mu.';

  @override
  String get wardrobeDeletedTitle => 'Dihapus';

  @override
  String get wardrobeNotDeletedTitle => 'Tidak dihapus';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item dihapus dari lemari-mu.',
      one: '1 item dihapus dari lemari-mu.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Ekstraksi Lemari AI';

  @override
  String get itemAddScanJobLabel => 'Pindai';

  @override
  String get itemAddFoundEarlierBody => 'Ditemukan pada pindai sebelumnya';

  @override
  String get itemAddLookingAtPhoto => 'Melihat foto-mu';

  @override
  String get itemAddExtractionFailedBody => 'Ekstraksi gagal';

  @override
  String get itemAddJobFailedBody => 'Tugas gagal';

  @override
  String get itemAddConnectionLostBody => 'Koneksi terputus. Coba lagi.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Koneksi terputus saat pemrosesan.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Item $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Item';

  @override
  String get itemAddNotCancelledTitle => 'Tidak dibatalkan';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count item ada di lemarimu.',
      one: '1 item ada di lemarimu.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved dari $total item disimpan. Ketuk simpan untuk mencoba lagi.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Beberapa item tidak tersimpan';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Pilih minimal satu foto.';

  @override
  String get batchPhotoUnreadableBody => 'Foto ini tidak dapat dibaca.';

  @override
  String get batchNoPhotosReadableBody =>
      'Tidak ada foto yang dapat dibaca. Coba foto lain.';

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
      'Koneksi terputus saat pemrosesan. Coba lagi.';

  @override
  String get batchNotCancelledTitle => 'Tidak dibatalkan';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Tautan unggahan tidak didukung. Masukkan tautan profil.';

  @override
  String get batchLinkSpacesBody => 'Tautan tidak boleh mengandung spasi.';

  @override
  String get batchEnterProfileLinkBody =>
      'Masukkan tautan profil Instagram atau Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Masukkan tautan profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'Halaman masuk tidak terbuka. Coba lagi.';

  @override
  String get batchSignInBrowserBody =>
      'Masuk lewat browser, lalu kembali ke FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Hubungkan akunmu';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Masukkan kode dari aplikasi autentikatormu.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram memerlukan pemeriksaan keamanan. Masuk lewat browser terlebih dahulu.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Masukkan nama pengguna dan kata sandimu lagi.';

  @override
  String get batchSignInFailedBody =>
      'Gagal masuk. Periksa nama pengguna dan kata sandimu.';

  @override
  String get batchSignInToKeepImportingBody => 'Masuk untuk melanjutkan impor.';

  @override
  String get batchAccountNotConnectedBody => 'Akunmu tidak terhubung.';

  @override
  String get batchAccountConnectedTitle => 'Akun terhubung';

  @override
  String get batchNotConnectedTitle => 'Tidak terkoneksi';

  @override
  String get batchImportConnectionLostBody =>
      'Koneksi ke import hilang. Muat ulang untuk memeriksa.';

  @override
  String batchPickUpToBody(int max) {
    return 'Pilih hingga $max foto. Kami menemukan itemnya.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count dari $total foto';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Menyiapkan foto $done dari $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Temukan item di $count foto',
      one: 'Temukan item di 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Akun $platform Anda menggunakan masuk dua langkah. Masukkan kode 6 digit dari aplikasi autentikator Anda.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Profil $platform ini bersifat privat atau memerlukan masuk untuk menampilkan fotonya.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Koneksi dengan $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto ditemukan sejauh ini',
      one: '1 foto ditemukan sejauh ini',
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
    return '$processed dari $total diproses · $added ditambahkan · $waiting menunggu · $skipped dilewati';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Pindai foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number berikutnya';
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
      other: '$count item ditemukan',
      one: '1 item ditemukan',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto ditambahkan ke lemari Anda.',
      one: '1 foto ditambahkan ke lemari Anda.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count foto studio lagi sedang diproses. Anda bisa menyimpan yang siap, atau pergi — kami akan memberi tahu Anda.',
      one:
          '1 foto studio lagi sedang diproses. Anda bisa menyimpan yang siap, atau pergi — kami akan memberi tahu Anda.',
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
      other: '$pieces item',
      one: '1 item',
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
    return '$chosen dipilih. Ketuk item untuk melewatinya.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Menyimpan $count item',
      one: 'Menyimpan 1 item',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Simpan $count item',
      one: 'Simpan 1 item',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Profil tubuh Anda tersimpan.';

  @override
  String get bodyProfileSavedTitle => 'Tersimpan';

  @override
  String get bodyProfileNotSavedTitle => 'Tidak tersimpan';

  @override
  String get bodyProfileSetDefaultBody => 'Atur sebagai profil default Anda.';

  @override
  String get bodyProfileDeletedBody => 'Profil tubuh dihapus.';

  @override
  String get bodyProfileDeletedTitle => 'Dihapus';

  @override
  String get bodyProfileNotDeletedTitle => 'Tidak dihapus';

  @override
  String get feedbackNotSentTitle => 'Tidak terkirim';

  @override
  String get feedbackSentBody =>
      'Terima kasih. Kami membaca setiap pesan dan membalas jika butuh info tambahan.';

  @override
  String get feedbackSentTitle => 'Umpan balik terkirim';

  @override
  String get recommendUnnamedPiece => 'Pakaian tanpa nama';

  @override
  String get recommendEnterCityBody =>
      'Masukkan kota Anda untuk rekomendasi sesuai cuaca.';

  @override
  String get recommendWhichCityTitle => 'Kota mana?';

  @override
  String get aiConsentSheetTitle => 'Berbagi foto dengan layanan AI';

  @override
  String get aiConsentSheetBody =>
      'Untuk membuat gambar try-on dan photoshoot, FitCheck AI mengirim foto yang Anda berikan (termasuk gambar wajah dan tubuh) ke penyedia AI pihak ketiga yang terpercaya (seperti OpenAI atau Google Gemini) untuk diproses. Mereka menghasilkan gambar Anda dan tidak menggunakannya untuk melatih model mereka berdasarkan ketentuan kami. Foto dikirim dengan aman dan tidak pernah dibagikan untuk iklan.';

  @override
  String get aiConsentSheetPermission =>
      'Dengan melanjutkan, Anda memberikan izin eksplisit untuk membagikan foto Anda ke penyedia AI ini untuk pembuatan gambar.';

  @override
  String get skeletonsLoadMoreFailed => 'Gagal memuat lebih banyak.';

  @override
  String get jobsPiecesReadyTitle => 'Pakaian Anda siap';

  @override
  String get jobsScanStoppedTitle => 'Pemindaian berhenti';

  @override
  String get jobsNothingSavedBody => 'Tidak ada yang disimpan. Coba lagi.';

  @override
  String get jobsPhotoUploadFailedBody => 'Gagal mengunggah foto.';

  @override
  String get authGoogleSignInStartFailed =>
      'Gagal memulai Google Sign-In. Silakan coba lagi.';

  @override
  String get referralAppliedTitle => 'Referral Diterapkan!';

  @override
  String get billingStoreUnavailableBody =>
      'Pembelian toko tidak tersedia di perangkat ini.';

  @override
  String get billingPurchaseProcessingBody =>
      'Pembelian ini masih diproses. Buka ulang aplikasi dalam satu menit untuk melihat paket Anda.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Unggah avatar tidak mengembalikan URL gambar.';

  @override
  String get rewardsDayStreakLabel => 'hari beruntun';

  @override
  String rewardsBestStreak(int days) {
    return '$days hari terbaik';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Akses $permission Dibutuhkan';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Akses ke $permission ditolak. Buka Pengaturan untuk mengizinkannya, lalu kembali dan coba lagi.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Langkah $step dari 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Langkah $step dari $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Hapus gambar $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Hapus gambar $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points poin';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Email $email. Kami meninjau laporan dalam 24 jam.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Hapus $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Hapus \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Tambah ke \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" dihapus. Pakaian tetap di lemari.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Tampilkan semua $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return 'Tersisa $count hari ini';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index gagal';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected dari $max foto';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Tubuh $shape · Kulit $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opsi untuk $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Paling sering dipakai: $name, $count kali';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: belum diatur';
  }

  @override
  String recommendMatchPercent(int percent) {
    return 'Cocok $percent%';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked dari $max dipilih';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Hapus $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioritas $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Paket ini ditagih melalui $store. Ubah atau batalkan di pengaturan akun $store Anda.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Kelola di $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current dari $max terpakai';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Sisa sekitar $seconds detik';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done dari $total foto studio siap';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready dari $total foto studio siap. Ketuk item untuk dilewati.';
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
