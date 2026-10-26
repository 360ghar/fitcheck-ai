// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPhotoshoot => 'Photoshoot';

  @override
  String get tabCloset => 'Closet';

  @override
  String get tabOutfits => 'Outfits';

  @override
  String get tabMore => 'More';

  @override
  String get actionAddItem => 'Add item';

  @override
  String get actionCreateOutfit => 'Create outfit';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionContinue => 'Continue';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorBody =>
      'Try again. If it keeps failing, contact support.';

  @override
  String get stateOfflineTitle => 'You are offline';

  @override
  String get stateOfflineBody =>
      'Reconnect to sync your closet and generate outfits.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsPlanBilling => 'Plan and billing';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsUnits => 'Measurement units';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPrivacySection => 'Privacy and data';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountBody =>
      'This removes your closet, outfits, photos and profile. It cannot be undone.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metric (cm, kg)';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageSystemBody =>
      'FitCheck AI follows your phone\'s language.';

  @override
  String get languageSearchHint => 'Search languages';

  @override
  String get languageCurrent => 'Current';

  @override
  String get languageReviewNote =>
      'This translation is new. Tell us if something reads wrong.';

  @override
  String get languageChanged => 'Language updated';

  @override
  String get paywallTitle => 'Choose your plan';

  @override
  String get paywallTrialBadge => '1 month free';

  @override
  String get paywallTrialTitle => 'Your first month of Pro is free';

  @override
  String get paywallTrialBody =>
      'Upload your whole closet at once. Add pieces as you go after that.';

  @override
  String get paywallFreeForeverTitle => 'Free forever';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'No card needed. Every month you get $uploads AI uploads, $outfits outfits and $images photoshoot images a day.';
  }

  @override
  String get paywallCtaTrial => 'Start my free month';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Upgrade to $plan';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallManage => 'Manage subscription';

  @override
  String get paywallTerms => 'Terms of use';

  @override
  String get paywallPrivacy => 'Privacy policy';

  @override
  String get paywallPerMonth => 'per month';

  @override
  String get paywallPerYear => 'per year';

  @override
  String get paywallBestValue => 'Best value';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Free trial for new subscribers only. After the trial, Pro renews at $price unless cancelled at least 24 hours before it ends.';
  }

  @override
  String get introTitle => 'Your closet, finally organised';

  @override
  String get introBody =>
      'Photograph your clothes once. Get outfit ideas, try-on previews and studio photos from what you already own.';

  @override
  String get introStart => 'Get started';

  @override
  String get introHaveAccount => 'I already have an account';

  @override
  String get introSkip => 'Skip';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authOrDivider => 'or';

  @override
  String get wardrobeTitle => 'Closet';

  @override
  String get wardrobeEmptyTitle => 'Your closet is empty';

  @override
  String get wardrobeEmptyBody =>
      'Add your first piece, or upload a photo of the whole rail at once.';

  @override
  String get wardrobeAddFirst => 'Add your first item';

  @override
  String get wardrobeSearchHint => 'Search your closet';

  @override
  String get categoryTops => 'Tops';

  @override
  String get categoryBottoms => 'Bottoms';

  @override
  String get categoryShoes => 'Shoes';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get categoryOuterwear => 'Outerwear';

  @override
  String get categorySwimwear => 'Swimwear';

  @override
  String get categoryActivewear => 'Activewear';

  @override
  String get categoryOther => 'Other';

  @override
  String get conditionClean => 'Clean';

  @override
  String get conditionDirty => 'Dirty';

  @override
  String get conditionLaundry => 'In laundry';

  @override
  String get conditionRepair => 'Needs repair';

  @override
  String get conditionDonate => 'To donate';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonFall => 'Fall';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonAll => 'All season';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sporty';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalist';

  @override
  String get styleRomantic => 'Romantic';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Other';

  @override
  String get occasionWork => 'Work';

  @override
  String get occasionDateNight => 'Date night';

  @override
  String get occasionTravel => 'Travel';

  @override
  String get occasionWedding => 'Wedding';

  @override
  String get occasionGym => 'Gym';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Party';

  @override
  String get occasionInterview => 'Interview';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorWhite => 'White';

  @override
  String get colorGrey => 'Grey';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorRed => 'Red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Enjoying FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'A quick rating helps other people find their style.';

  @override
  String get ratingPromptYes => 'Rate the app';

  @override
  String get ratingPromptNo => 'Not now';

  @override
  String get closetNoMatchesTitle => 'No pieces match';

  @override
  String get closetNoMatchesBody => 'Try fewer filters or another search.';

  @override
  String get closetClearFilters => 'Clear filters';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Loading your pieces';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Delete selected';

  @override
  String get closetCancelSelection => 'Cancel selection';

  @override
  String get closetCloseSearch => 'Close search';

  @override
  String get closetShowGrid => 'Show as grid';

  @override
  String get closetShowList => 'Show as list';

  @override
  String get closetShowRows => 'Show as rows';

  @override
  String get closetStatsTitle => 'Closet stats';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count pieces?',
      one: 'Delete 1 piece?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Outfits that use them lose these pieces.';

  @override
  String get closetSortBy => 'Sort by';

  @override
  String get closetFavourites => 'Favourites';

  @override
  String get closetFavourite => 'Favourite';

  @override
  String get closetUnfavourite => 'Remove favourite';

  @override
  String get closetWoreToday => 'Wore it today';

  @override
  String closetWornTimes(int count) {
    return 'Worn $count×';
  }

  @override
  String get closetCategoryLabel => 'Category';

  @override
  String get closetUseCaseLabel => 'Use case';

  @override
  String get closetAnyUseCase => 'Any';

  @override
  String get closetOtherUseCase => 'Other use case';

  @override
  String get closetOtherUseCaseHint => 'For example, brunch';

  @override
  String get closetUseUseCase => 'Use this';

  @override
  String get closetClearAll => 'Clear all';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortName => 'Name (A–Z)';

  @override
  String get sortMostWorn => 'Most worn';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Dinner';

  @override
  String get useCaseLunch => 'Lunch';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sort';

  @override
  String get actionAll => 'All';

  @override
  String get dashboardStartClosetTitle => 'Start your closet';

  @override
  String get dashboardStartClosetBody =>
      'Photograph a few pieces. We tag them for you.';

  @override
  String get dashboardPieces => 'pieces';

  @override
  String get dashboardOutfits => 'outfits';

  @override
  String get dashboardDayStreak => 'day streak';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count this month';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Best $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favourites',
      one: '1 favourite',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved outfits',
      one: '1 saved outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String get setupSkip => 'Skip setup';

  @override
  String get setupWhoTitle => 'Who are we styling?';

  @override
  String get setupWhoBody =>
      'Sets the model for try-on and photoshoots. You can change it in your profile.';

  @override
  String get setupStyleTitle => 'What do you wear most?';

  @override
  String get setupStyleBody => 'Pick any. Outfit ideas start from these.';

  @override
  String get setupClosetTitle => 'Add your first pieces.';

  @override
  String get setupClosetBody =>
      'Photograph a few clothes, or a pile of them. Each piece is cut out and filed for you.';

  @override
  String get setupAddClothes => 'Add clothes';

  @override
  String get setupStylesLabel => 'Styles';

  @override
  String get setupOccasionsLabel => 'Occasions';

  @override
  String get setupSkipStep => 'Skip';

  @override
  String get setupLater => 'Later';

  @override
  String get setupSaveError => 'Could not save';

  @override
  String get genderWomen => 'Women';

  @override
  String get genderMen => 'Men';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get outfitEmptyTitle => 'No outfits yet';

  @override
  String get outfitEmptyBody =>
      'Pair pieces from your closet and save the look.';

  @override
  String get outfitNoMatchesTitle => 'No outfits match';

  @override
  String get outfitSearchHint => 'Search your outfits';

  @override
  String get outfitLoading => 'Loading your outfits';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Style and season';

  @override
  String get outfitCollections => 'Collections';

  @override
  String get outfitDuplicate => 'Duplicate';

  @override
  String get outfitDeleteTitle => 'Delete this outfit?';

  @override
  String get outfitDeleteBody => 'Its pieces stay in your closet.';

  @override
  String get outfitDrafts => 'Drafts';

  @override
  String get outfitDraft => 'Draft';

  @override
  String get filterStyle => 'Style';

  @override
  String get filterSeason => 'Season';

  @override
  String get itemDetailDeleteTitle => 'Delete this piece?';

  @override
  String get itemDetailDeleteBody => 'Outfits that use it lose this piece.';

  @override
  String get itemAddFavourite => 'Add to favourites';

  @override
  String itemSize(String size) {
    return 'Size $size';
  }

  @override
  String get itemColours => 'Colours';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Pattern';

  @override
  String get itemUseCases => 'Use cases';

  @override
  String get itemKeptIn => 'Kept in';

  @override
  String get itemPrice => 'Price';

  @override
  String get itemBought => 'Bought';

  @override
  String get itemTags => 'Tags';

  @override
  String get itemAdded => 'Added';

  @override
  String get itemTimesWornLabel => 'times worn';

  @override
  String get itemLastWornLabel => 'last worn';

  @override
  String get itemNeverWorn => 'Never';

  @override
  String get authEntryBody =>
      'Every piece you own, styled by AI. Plan outfits, try them on, shoot them.';

  @override
  String get authCreateCloset => 'Create your closet';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInBody => 'Sign in to open your closet.';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authCreateClosetBody =>
      'It takes a minute. Your first items are free.';

  @override
  String get authName => 'Name';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authReferralCode => 'Referral code (optional)';

  @override
  String get authResetTitle => 'Reset your password';

  @override
  String get authResetBody => 'We will email you a link to choose a new one.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authEnterEmail => 'Enter your email';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authEnterPassword => 'Enter your password';

  @override
  String get authPasswordTooShort => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authNewHere => 'New here?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirm $email before you sign in. Check your inbox.';
  }

  @override
  String get authResendEmail => 'Send it again';

  @override
  String get authResendingEmail => 'Sending…';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authEnterName => 'Enter your name';

  @override
  String get authChoosePassword => 'Choose a password';

  @override
  String get authHaveAccount => 'Have an account?';

  @override
  String get authCodeAccepted => 'Code accepted';

  @override
  String get authCodeNotFound => 'Code not found';

  @override
  String authReferralFrom(String name) {
    return 'From $name. You both get a month free.';
  }

  @override
  String get authReferralInvalid => 'We could not find this code.';

  @override
  String authResetSent(String email) {
    return 'Sent to $email. Open the link on this phone.';
  }

  @override
  String get introSlide1Title => 'Snap your closet once.';

  @override
  String get introSlide1Body =>
      'Photograph a pile of clothes. Every piece is cut out and filed for you.';

  @override
  String get introSlide2Title => 'Get dressed faster.';

  @override
  String get introSlide2Body =>
      'Outfits from what you own, matched to your plans and the weather.';

  @override
  String get introSlide3Title => 'See it before you wear it.';

  @override
  String get introSlide3Body =>
      'Try looks on your own photo, or shoot them like a campaign.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTemperature => 'Temperature';

  @override
  String get settingsEmailUpdates => 'Email updates';

  @override
  String get settingsEmailUpdatesBody => 'News and tips by email';

  @override
  String get settingsOutfitReminders => 'Outfit reminders';

  @override
  String get settingsOutfitRemindersBody => 'A nudge to log what you wore';

  @override
  String get settingsWeeklySummary => 'Weekly summary';

  @override
  String get settingsWeeklySummaryBody => 'Your week in outfits';

  @override
  String get settingsStyleSection => 'Style';

  @override
  String get settingsPreferredStyles => 'Styles you like';

  @override
  String get settingsPreferredColours => 'Colours you like';

  @override
  String get settingsNoneChosen => 'None chosen';

  @override
  String get settingsPlanAiSection => 'Plan and AI';

  @override
  String get settingsPlanBillingBody => 'Plan, usage and upgrades';

  @override
  String get settingsPlanUsageBody => 'Plan and usage';

  @override
  String get settingsInviteFriends => 'Invite friends';

  @override
  String get settingsInviteFriendsBody =>
      'A free month for each friend who joins';

  @override
  String get settingsAiProvider => 'AI provider';

  @override
  String get settingsAiProviderBody =>
      'Use your own model for tagging and images';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsPrivacyTerms => 'Privacy and terms';

  @override
  String get settingsReportProblem => 'Report a problem';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsExportData => 'Export your data';

  @override
  String get settingsExportBody =>
      'We prepare a file with everything you saved and open the download.';

  @override
  String get settingsExportAction => 'Export';

  @override
  String get settingsCurrentPassword => 'Current password';

  @override
  String get settingsNewPassword => 'New password';

  @override
  String get settingsConfirmNewPassword => 'Confirm new password';

  @override
  String get settingsEnterCurrentPassword => 'Enter your current password';

  @override
  String get settingsEnterNewPassword => 'Enter a new password';

  @override
  String get settingsPasswordMin8 => 'Use at least 8 characters';

  @override
  String get settingsPasswordNeedsUpper => 'Add an uppercase letter';

  @override
  String get settingsPasswordNeedsLower => 'Add a lowercase letter';

  @override
  String get settingsPasswordNeedsDigit => 'Add a number';

  @override
  String get settingsPasswordsNoMatch => 'The passwords do not match';

  @override
  String get settingsChangeAction => 'Change';

  @override
  String get itemAddSnapTitle => 'Snap a piece';

  @override
  String get itemAddSnapBody =>
      'We find every piece in the photo and make a clean studio shot of each.';

  @override
  String get itemAddCamera => 'Take a photo';

  @override
  String get itemAddGallery => 'Choose from gallery';

  @override
  String get itemAddOtherWays => 'Other ways to add';

  @override
  String get itemAddSeveral => 'Add several photos';

  @override
  String get itemAddSeveralBody => 'Up to 50 at once';

  @override
  String get itemAddImportProfile => 'Import from a profile';

  @override
  String get itemAddImportProfileBody => 'Instagram or Facebook';

  @override
  String get itemAddEnterDetails => 'Enter details yourself';

  @override
  String get itemAddEnterDetailsBody => 'No photo needed';

  @override
  String get itemManualIntro =>
      'Only a name is needed. Add the rest now or later.';

  @override
  String get itemManualNameHint => 'For example, blue cotton tee';

  @override
  String get itemManualEnterName => 'Enter a name';

  @override
  String get itemManualNotes => 'Notes';

  @override
  String get itemManualBrand => 'Brand';

  @override
  String get itemManualSize => 'Size';

  @override
  String get itemManualEnterNumber => 'Enter a number';

  @override
  String get itemManualSavePiece => 'Save piece';

  @override
  String get itemManualSaving => 'Saving';

  @override
  String get itemManualSavedTitle => 'Saved';

  @override
  String itemManualSavedBody(String name) {
    return '$name is in your closet.';
  }

  @override
  String get itemManualNotSaved => 'Not saved';

  @override
  String get itemManualAddUseCase => 'Add a use case';

  @override
  String get itemManualAddUseCaseAction => 'Add use case';

  @override
  String get itemPhotos => 'Photos';

  @override
  String get itemAddPhotos => 'Add photos';

  @override
  String get itemNoPhotoYet => 'No photo yet. You can save without one.';

  @override
  String get itemRemovePhoto => 'Remove photo';

  @override
  String get itemRemovePiece => 'Remove piece';

  @override
  String get filterConditionLabel => 'Condition';

  @override
  String get photoshootStepPhotos => 'Photos';

  @override
  String get photoshootStepSetup => 'Setup';

  @override
  String get photoshootStepCreating => 'Creating';

  @override
  String get photoshootStepResults => 'Results';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Step $current of $total, $name';
  }

  @override
  String get photoshootOneFailed => 'One photo failed. Retry it below.';

  @override
  String photoshootManyFailed(int count) {
    return '$count photos failed. Retry each one below.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'How many';

  @override
  String get photoshootYourPrompt => 'Your prompt';

  @override
  String get photoshootPromptHint => 'Golden hour on a rooftop, linen shirt';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create $count photos',
      one: 'Create 1 photo',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'photos',
      one: 'photo',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'We couldn\'t check today\'s limit.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan plan: $remaining of $limit left today';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Free';

  @override
  String get photoshootGallery => 'Gallery';

  @override
  String get photoshootUseCamera => 'Use camera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Remove photo $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'No photos came back';

  @override
  String get photoshootNoPhotosBody =>
      'The shoot finished without images. Try again.';

  @override
  String get photoshootNewStyle => 'New style';

  @override
  String get photoshootNewPhotos => 'New photos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Open photo $number';
  }

  @override
  String get photoshootReportPhoto => 'Report photo';

  @override
  String get photoshootSaveToGallery => 'Save to gallery';

  @override
  String get actionUpgrade => 'Upgrade';

  @override
  String get referralLimitTitle => 'You\'ve used today\'s photos';

  @override
  String get referralLimitBody =>
      'Your free photos come back tomorrow. Refer a friend and you both get a month of Pro free.';

  @override
  String get referralLimitRefer => 'Refer a friend';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating app';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Aesthetic';

  @override
  String get photoshootUseCustom => 'Your own prompt';

  @override
  String get photoshootDescLinkedin => 'Sharp headshots for work';

  @override
  String get photoshootDescDating => 'Relaxed, warm and natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, high-fashion looks';

  @override
  String get photoshootDescInstagram => 'Lifestyle shots for your feed';

  @override
  String get photoshootDescAesthetic => 'Moody, artistic frames';

  @override
  String get photoshootDescCustom => 'Describe the look you want';

  @override
  String get aspectSquare => 'Square';

  @override
  String get aspectPortrait => 'Portrait';

  @override
  String get aspectLandscape => 'Landscape';

  @override
  String get aspectTall => 'Tall';

  @override
  String get aspectWide => 'Wide';

  @override
  String get tryOnAppBar => 'Virtual try-on';

  @override
  String get tryOnYourPhoto => 'Your photo';

  @override
  String get tryOnGarment => 'Garment';

  @override
  String get tryOnUploadingPhoto => 'Uploading your photo';

  @override
  String get tryOnAddPhotoPrompt => 'Add a full-body photo of yourself';

  @override
  String get tryOnBodyPhotoHint => 'A full-body photo works best';

  @override
  String get tryOnAddPhoto => 'Add photo';

  @override
  String get tryOnChangePhoto => 'Change photo';

  @override
  String get tryOnPhotoLoadFailed => 'We couldn\'t load your photo.';

  @override
  String get tryOnChooseGarment => 'Choose a garment photo';

  @override
  String get tryOnChooseOneGarment => 'Choose one garment photo';

  @override
  String get tryOnGarmentHint => 'A flat lay or a hanger shot works best';

  @override
  String get tryOnChange => 'Change';

  @override
  String get tryOnCamera => 'Camera';

  @override
  String get tryOnRemove => 'Remove';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Style';

  @override
  String get tryOnBackground => 'Background';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Dressing you up. This takes about half a minute.';

  @override
  String get tryOnEmptyResult => 'Your try-on appears here';

  @override
  String get tryOnReportImage => 'Report image';

  @override
  String get tryOnCreating => 'Creating';

  @override
  String get tryOnTryAgain => 'Try again';

  @override
  String get tryOnCreate => 'Create try-on';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio white';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio grey';

  @override
  String get tryOnBackgroundUrban => 'Urban street';

  @override
  String get tryOnBackgroundNature => 'Nature';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Standing front';

  @override
  String get tryOnPoseSide => 'Standing side';

  @override
  String get tryOnPoseWalking => 'Walking';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardWelcome => 'Welcome';

  @override
  String get dashboardOpenProfile => 'Open profile';

  @override
  String get dashboardRailToday => 'Today';

  @override
  String get dashboardRailRecently => 'Recently';

  @override
  String get dashboardActivityEmpty => 'New pieces and outfits show up here.';

  @override
  String get quickAddPiece => 'Add a piece';

  @override
  String get quickAddPieceBody => 'Photograph and tag';

  @override
  String get quickBuildOutfit => 'Build an outfit';

  @override
  String get quickBuildOutfitBody => 'Mix your pieces';

  @override
  String get quickForYou => 'For you';

  @override
  String get quickForYouBody => 'Picks for today';

  @override
  String get quickPlanWeek => 'Plan the week';

  @override
  String get quickPlanWeekBody => 'Outfits by date';

  @override
  String get referralBannerUrgent => 'Running low? Invite a friend.';

  @override
  String get referralBannerTitle => 'Give a month, get a month.';

  @override
  String get referralBannerBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get referralBannerDismiss => 'Dismiss for a week';

  @override
  String get referralBannerShare => 'Share invite';

  @override
  String get referralBannerCopy => 'Copy link';

  @override
  String get itemEditPieceTitle => 'Edit piece';

  @override
  String get itemEditDescriptionLabel => 'Description';

  @override
  String get itemEditNotSaved => 'Not saved';

  @override
  String get itemEditSavedTitle => 'Saved';

  @override
  String get itemEditSavedBody => 'Your changes are saved.';

  @override
  String get itemEditSavedStalePhotos => 'Saved — photos may be out of date';

  @override
  String get itemEditRemovePieceHint => 'Delete this piece from the item page.';

  @override
  String get itemEditNoPhotos =>
      'No photos yet. Add one from your gallery or camera.';

  @override
  String get itemEditKeepPhoto => 'Keep photo';

  @override
  String get itemEditRemoved => 'Removed';

  @override
  String get itemEditAddUseCaseAction => 'Add';

  @override
  String get statsNoStatsTitle => 'No stats yet';

  @override
  String get statsNoStatsBody =>
      'Add a few pieces and your closet mix shows up here.';

  @override
  String get statsByCategory => 'By category';

  @override
  String get statsTotalValue => 'total value';

  @override
  String get statsMostWorn => 'Worn the most';

  @override
  String get statsLeastWorn => 'Waiting for a turn';

  @override
  String get statsUnnamedPiece => 'Unnamed piece';

  @override
  String get jobsTitle => 'Scans';

  @override
  String get jobsEmptyTitle => 'No scans yet';

  @override
  String get jobsEmptyBody =>
      'Snap a piece and send it to the background — it keeps working here.';

  @override
  String get jobsNotCancelled => 'Not cancelled';

  @override
  String get jobsResume => 'Resume';

  @override
  String get jobsReview => 'Review';

  @override
  String get jobsStop => 'Stop';

  @override
  String get jobsDismiss => 'Dismiss';

  @override
  String get reportTitle => 'Report content';

  @override
  String reportIntro(String contentType) {
    return 'Tell us what\'s wrong with this $contentType. Our team reviews every report.';
  }

  @override
  String get reportReasonInappropriate => 'Inappropriate or offensive';

  @override
  String get reportReasonNudity => 'Nudity or sexual content';

  @override
  String get reportReasonHarassment => 'Harassment or abuse';

  @override
  String get reportReasonImpersonation => 'Impersonation';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportDetailsLabel => 'Additional details (optional)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSubmittedTitle => 'Report submitted';

  @override
  String get reportSubmittedBody =>
      'Thank you. Our team will review this content.';

  @override
  String get reportFailedTitle => 'Couldn\'t send report';

  @override
  String get reportFailedBody => 'Please try again.';

  @override
  String get reportContentTryOnImage => 'AI try-on image';

  @override
  String get reportContentSharedOutfit => 'shared outfit';

  @override
  String get reportContentPhotoshootImage => 'AI photoshoot image';

  @override
  String get sharedOutfitTitle => 'Shared outfit';

  @override
  String get sharedOutfitHideTooltip => 'Hide this outfit';

  @override
  String get sharedOutfitReportTooltip => 'Report this outfit';

  @override
  String get sharedOutfitHideTitle => 'Hide this outfit?';

  @override
  String get sharedOutfitHideBody =>
      'It stays hidden on this device. You can also report it so our team can review and remove it.';

  @override
  String get sharedOutfitHideAction => 'Hide';

  @override
  String get sharedOutfitHiddenInfo =>
      'This outfit will not show on this device again.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit hidden';

  @override
  String get sharedOutfitMissingTitle => 'This outfit isn\'t here anymore';

  @override
  String get sharedOutfitMissingBody =>
      'It may have been removed, or the link is wrong.';

  @override
  String get sharedOutfitHiddenStateTitle => 'You hid this outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'If it was objectionable, report it from Privacy and terms or email $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Like this look?';

  @override
  String get sharedOutfitCtaBody =>
      'Build outfits like it from your own closet.';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get errorNoConnection =>
      'No internet connection. Please check your network.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorServerError =>
      'Something went wrong on our end. Please try again.';

  @override
  String get errorBadGateway =>
      'Our server is briefly unavailable. Please try again.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Please try again shortly.';

  @override
  String get errorInternalError => 'Something went wrong. Please try again.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorForbidden => 'You do not have access to that.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get errorInvalidCredentials =>
      'That email or password is not correct.';

  @override
  String get errorTokenRefreshFailed =>
      'We could not refresh your session. Please sign in again.';

  @override
  String get errorRequestCancelled => 'Request cancelled.';

  @override
  String get errorInvalidFormat => 'That file format is not supported.';

  @override
  String get errorFileTooLarge => 'That file is too large.';

  @override
  String get errorUploadFailed => 'The upload failed. Please try again.';

  @override
  String get errorCacheCorrupted =>
      'Saved data was damaged and has been reset.';

  @override
  String get errorCacheNotFound => 'Nothing was saved yet.';

  @override
  String get errorUserNotFound => 'We could not find that account.';

  @override
  String get errorItemNotFound => 'That item no longer exists.';

  @override
  String get errorOutfitNotFound => 'That outfit no longer exists.';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsNoAchievementsTitle => 'No achievements yet';

  @override
  String get rewardsNoAchievementsBody =>
      'Add pieces and plan outfits to earn your first.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'No one on the board yet';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plan outfits to earn points and show up here.';

  @override
  String get legalViewPrivacyPolicy => 'View Privacy Policy';

  @override
  String get aiConsentAgree => 'I Agree & Continue';

  @override
  String get aiConsentNotNow => 'Not Now';

  @override
  String get imageViewerCloseTooltip => 'Close image viewer';

  @override
  String get updateReadyTitle => 'Update ready';

  @override
  String get updateReadyBody =>
      'Restart FitCheck AI to apply the latest improvements.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI needs camera access to take photos of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI needs photo library access to select images of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI needs to save your AI-generated outfit photos to your photo library.';

  @override
  String get wardrobeSomePhotosSkipped => 'Some photos skipped';

  @override
  String get wardrobePhotosNotAdded => 'Photos not added';

  @override
  String get wardrobePhotoNotAdded => 'Photo not added';

  @override
  String get wardrobeNotStartedTitle => 'Not started';

  @override
  String get wardrobeNoRoomTitle => 'No room';

  @override
  String get wardrobeAddPhotosSemantic => 'Add photos';

  @override
  String get batchAddTileLabel => 'Add';

  @override
  String get batchProfileLinkLabel => 'Profile link';

  @override
  String get wardrobeImportFromProfileTitle => 'Import from a profile';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Add several photos';

  @override
  String get wardrobeClearAction => 'Clear';

  @override
  String get wardrobeRefreshTooltip => 'Refresh';

  @override
  String get batchNoPhotosYetTitle => 'No photos yet';

  @override
  String get batchChoosePhotosAction => 'Choose photos';

  @override
  String get batchWeFindEachPieceBody =>
      'We find each piece and make a studio photo of it.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparing photos';

  @override
  String get batchPhotosProcessedSemantic => 'Photos processed';

  @override
  String get batchPasteProfileLinkTitle => 'Paste a profile link';

  @override
  String get batchPasteProfileLinkBody =>
      'A public Instagram or Facebook profile. We scan its photos, and you choose what goes in your closet.';

  @override
  String get batchClearLinkTooltip => 'Clear link';

  @override
  String get batchStartingButton => 'Starting';

  @override
  String get batchStartImportAction => 'Start import';

  @override
  String get batchReviewEveryPhotoTitle => 'You review every photo';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nothing is added until you approve it.';

  @override
  String get batchPrivateProfilesTitle => 'Private profiles';

  @override
  String get batchPrivateProfilesBody =>
      'Connect your account. Instagram also takes a username and password.';

  @override
  String get batchUseAnotherLinkAction => 'Use another link';

  @override
  String get batchSignInNeededTitle => 'Sign-in needed';

  @override
  String get batchEnterYourCodeTitle => 'Enter your code';

  @override
  String get batchUseUsernamePasswordAction => 'Use username and password';

  @override
  String get batchAlreadyConnectedAction =>
      'I already connected in the browser';

  @override
  String get batchEnterCodeAction => 'Enter code';

  @override
  String get batchTryAnotherWayAction => 'Try another way';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Reconnecting';

  @override
  String get batchSignInToInstagramTitle => 'Sign in to Instagram';

  @override
  String get batchUsernameLabel => 'Username';

  @override
  String get batchCodeIfTwoStepLabel => 'Code, if you use two-step sign-in';

  @override
  String get batchAuthenticatorCodeBody =>
      'Use the 6-digit code from your authenticator app. Codes change quickly.';

  @override
  String get batchVerifyAction => 'Verify';

  @override
  String get batchFindingPhotosTitle => 'Finding photos';

  @override
  String get batchImportPausedTitle => 'Import paused';

  @override
  String get batchProcessingPhotosTitle => 'Processing photos';

  @override
  String get batchWaitingNextPhoto => 'Waiting for the next photo';

  @override
  String get batchCancelImportAction => 'Cancel import';

  @override
  String get batchNoPiecesInPhotoBody => 'No pieces found in this photo.';

  @override
  String get batchEditPieceColoursLabel => 'Colours, separated by commas';

  @override
  String get batchAddToClosetAction => 'Add to closet';

  @override
  String get batchSkipPhotoAction => 'Skip this photo';

  @override
  String get batchImportCompleteTitle => 'Import complete';

  @override
  String get batchImportFailedTitle => 'Import failed';

  @override
  String get batchImportCancelledTitle => 'Import cancelled';

  @override
  String get batchImportErrorBody => 'Something went wrong while importing.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nothing more is imported from this profile.';

  @override
  String get batchViewClosetAction => 'View closet';

  @override
  String get batchStartOverAction => 'Start over';

  @override
  String get wardrobeAddPieceTitle => 'Add a piece';

  @override
  String get wardrobeAddDetailsTitle => 'Add details';

  @override
  String get wardrobeScanningTitle => 'Scanning';

  @override
  String get batchReviewPiecesTitle => 'Review pieces';

  @override
  String get wardrobeGalleryAction => 'Gallery';

  @override
  String get wardrobeCameraAction => 'Camera';

  @override
  String get wardrobeNewBadge => 'New';

  @override
  String get wardrobeRemovePhotoTooltip => 'Remove photo';

  @override
  String get batchRunInBackgroundTooltip => 'Run in background';

  @override
  String get batchStepOneOfTwo => 'Step 1 of 2';

  @override
  String get batchStepTwoOfTwo => 'Step 2 of 2';

  @override
  String get batchUploadingPhotosTitle => 'Uploading photos';

  @override
  String get batchFindingPiecesTitle => 'Finding pieces';

  @override
  String get batchMakingStudioPhotosTitle => 'Making studio photos';

  @override
  String get batchStoppedLabel => 'Stopped';

  @override
  String get batchFindingPiecesStoppedTitle => 'Finding pieces stopped';

  @override
  String get batchCancelledLabel => 'Cancelled';

  @override
  String get batchAllDoneTitle => 'All done';

  @override
  String get batchOpeningPiecesBody => 'Opening your pieces';

  @override
  String get batchNothingSavedBody => 'Nothing was saved.';

  @override
  String get batchFindingPiecesFailedBody => 'Finding pieces failed.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Finding pieces stopped early.';

  @override
  String get batchStopFindingPiecesTitle => 'Stop finding pieces?';

  @override
  String get batchStopFindingPiecesBody =>
      'The scan stops and nothing is saved. Pieces already found stay in your activity until you dismiss them.';

  @override
  String get batchKeepGoingAction => 'Keep going';

  @override
  String get batchTryAgainAction => 'Try again';

  @override
  String get batchBackToPhotosAction => 'Back to photos';

  @override
  String get batchSkipAllAction => 'Skip all';

  @override
  String get batchIncludeAllAction => 'Include all';

  @override
  String get batchNoPiecesFoundTitle => 'No pieces found';

  @override
  String get batchNoPiecesFoundBody => 'We found no clothes in these photos.';

  @override
  String get batchChooseOtherPhotosAction => 'Choose other photos';

  @override
  String get batchUseCaseHelper => 'Added to every piece you save.';

  @override
  String get batchDiscardPiecesTitle => 'Discard these pieces?';

  @override
  String get batchDiscardPiecesBody => 'Nothing from this batch is saved.';

  @override
  String get batchKeepAction => 'Keep';

  @override
  String get batchDiscardAction => 'Discard';

  @override
  String get batchRemovePieceTitle => 'Remove this piece?';

  @override
  String get batchRemovePieceBody => 'It is not saved to your closet.';

  @override
  String get batchRemoveAction => 'Remove';

  @override
  String get batchChoosePiecesToSave => 'Choose pieces to save';

  @override
  String get batchDiscardAllAction => 'Discard all';

  @override
  String get batchNothingSavedRetryBody => 'Nothing was saved. Try again.';

  @override
  String get batchNotSavedTitle => 'Not saved';

  @override
  String get batchSavingLabel => 'Saving';

  @override
  String get batchSendToBackgroundAction => 'Send to background';

  @override
  String get batchStillWorkingMessage =>
      'Still working. We will let you know when your pieces are ready.';

  @override
  String get batchRunningInBackgroundTitle => 'Running in background';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studio photos stopped early. You can still save these pieces.';

  @override
  String get batchTapPieceToSkip => 'Tap a piece to skip it.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studio photos still on their way. You can leave — we will let you know.';

  @override
  String get batchLeaveAction => 'Leave';

  @override
  String get batchPeopleInPhotosTitle => 'People in the photos';

  @override
  String get batchIncludeAction => 'Include';

  @override
  String get batchSkipAction => 'Skip';

  @override
  String get batchYourPhotoIsUsedLabel => 'Your photo is used';

  @override
  String get batchMakingStudioPhotoLabel => 'Making studio photo';

  @override
  String get batchNoStudioPhotoBody => 'No studio photo. Your photo is used.';

  @override
  String get batchEnterDetailsYourselfAction => 'Enter details yourself';

  @override
  String get batchChooseAnotherPhotoAction => 'Choose another photo';

  @override
  String get batchConnectionLostTitle => 'Connection lost';

  @override
  String get batchConnectionLostBody =>
      'Check your connection, then try again.';

  @override
  String get batchDailyLimitTitle => 'Daily limit reached';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Upgrade to Pro for more scans, or enter the details yourself.';

  @override
  String get batchDailyLimitBodyFree =>
      'Your scans reset tomorrow. You can enter the details yourself now.';

  @override
  String get batchSeePlansAction => 'See plans';

  @override
  String get batchAiBusyTitle => 'Our AI is busy';

  @override
  String get batchAiBusyBody =>
      'This is on our side. Try again in a few minutes.';

  @override
  String get batchNoPiecesBody =>
      'Try a clearer photo, or enter the details yourself.';

  @override
  String get batchScanningUnavailableTitle => 'Scanning is unavailable';

  @override
  String get batchScanningUnavailableBody =>
      'Enter the details yourself for now.';

  @override
  String get batchScanDidNotFinishTitle => 'The scan did not finish';

  @override
  String get batchTryAgainBody => 'Try again.';

  @override
  String get billingTitle => 'Subscription';

  @override
  String get billingUpgradeHeading => 'Upgrade your plan';

  @override
  String get billingUpgradeOnPlusBody => 'Same features, higher limits.';

  @override
  String get billingUpgradeBody =>
      'Plus and Pro have the same features. Pick the limits you need.';

  @override
  String get billingWebUnavailableBody =>
      'Online upgrades aren\'t available yet. A promo or referral code still unlocks Plus or Pro. Invite friends below to earn free months.';

  @override
  String get billingPlansStale =>
      'Couldn\'t load the latest plans. Prices may be out of date.';

  @override
  String get billingMonthly => 'Monthly';

  @override
  String get billingYearly => 'Yearly';

  @override
  String get billingCurrentPlan => 'Current plan';

  @override
  String get billingActive => 'Active';

  @override
  String get billingThisMonth => 'This month';

  @override
  String get billingItemExtractions => 'Item extractions';

  @override
  String get billingOutfitVisualizations => 'Outfit visualizations';

  @override
  String get billingNearLimitUpgrade =>
      'You\'re close to this month\'s limit. Upgrade for more.';

  @override
  String get billingNearLimitResets =>
      'You\'re close to this month\'s limit. It resets at the start of next month.';

  @override
  String get billingStoreUnavailable =>
      'Upgrades aren\'t available in the store yet. Check back soon.';

  @override
  String get billingManageHeading => 'Manage your plan';

  @override
  String get billingCancelPlan => 'Cancel subscription';

  @override
  String get billingCancelKeepsAccess =>
      'You keep access until the end of this billing period.';

  @override
  String get billingCancelConfirmTitle => 'Cancel your subscription?';

  @override
  String get billingKeepPlan => 'Keep plan';

  @override
  String get billingCancelPlanAction => 'Cancel plan';

  @override
  String get billingBilledMonthly => 'Billed monthly';

  @override
  String get billingBilledYearly => 'Billed yearly';

  @override
  String get billingVirtualTryOn => 'Virtual try-on';

  @override
  String get billingPrioritySupport => 'Priority support';

  @override
  String get billingDisclosureProRenewing =>
      'Pro is an auto-renewing subscription';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus and Pro are auto-renewing subscriptions';

  @override
  String get billingDisclosureAppleBilling =>
      'Payment is charged to your Apple ID at confirmation of purchase.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Payment is charged to your Google Play account at confirmation of purchase.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Your subscription renews automatically for the same period at the same price unless you turn off auto-renew at least 24 hours before the current period ends.';

  @override
  String get billingDisclosureAppleManage =>
      'Manage or cancel any time in Settings › your Apple ID › Subscriptions.';

  @override
  String get billingDisclosureGoogleManage =>
      'Manage or cancel any time in Google Play › Payments and subscriptions.';

  @override
  String get billingReferFriend => 'Refer a friend';

  @override
  String get billingHowItWorks => 'How it works';

  @override
  String get billingHowShareTitle => 'Share your link';

  @override
  String get billingHowShareBody => 'Send it to a friend.';

  @override
  String get billingHowSignUpTitle => 'They sign up';

  @override
  String get billingHowSignUpBody => 'Your friend joins from the link.';

  @override
  String get billingHowBothTitle => 'You both get Pro';

  @override
  String get billingHowBothBody => 'Each of you gets a month of Pro free.';

  @override
  String get billingYourReferrals => 'Your referrals';

  @override
  String get billingInvited => 'Invited';

  @override
  String get billingJoined => 'Joined';

  @override
  String get billingMonthsEarned => 'Months earned';

  @override
  String get billingInviteFriend => 'Invite a friend';

  @override
  String get billingInviteBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get billingYourCode => 'Your code';

  @override
  String get billingCopyLink => 'Copy link';

  @override
  String get billingShareInvite => 'Share invite';

  @override
  String get giftUnavailable =>
      'Gift invitations are not available in this build.';

  @override
  String get giftPageTitle => 'Gift FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'No free gift invitations are available right now.';

  @override
  String get giftFormTitle => 'Send a free invitation';

  @override
  String get giftFormBody =>
      'Your recipient claims the gift with this verified email. We don\'t send the email for you.';

  @override
  String get giftFieldFrom => 'From';

  @override
  String get giftFieldRecipientName => 'Recipient name';

  @override
  String get giftFieldRecipientEmail => 'Recipient email';

  @override
  String get giftFieldOccasion => 'Occasion (optional)';

  @override
  String get giftNoOccasion => 'No occasion';

  @override
  String get giftOccasionBirthday => 'Birthday';

  @override
  String get giftOccasionAnniversary => 'Anniversary';

  @override
  String get giftOccasionOther => 'Other';

  @override
  String get giftFieldCardGreeting => 'Card greeting';

  @override
  String get giftFieldCardGreetingHelper =>
      'This appears on the card exactly as written.';

  @override
  String get giftFieldPrivateNote => 'Private note (optional)';

  @override
  String get giftCreateAction => 'Create free gift';

  @override
  String get giftClaimedTitle => 'Gift claimed';

  @override
  String get giftClaimedActive => 'Your FitCheck Pro gift is active.';

  @override
  String get giftClaimedQueued =>
      'Your FitCheck Pro gift starts after your current access.';

  @override
  String get giftLinkCopied => 'Gift link copied to the clipboard.';

  @override
  String get giftErrorName => 'Enter a name.';

  @override
  String get giftErrorEmail => 'Enter a valid email address.';

  @override
  String get giftErrorGreeting => 'Enter the card greeting.';

  @override
  String get giftErrorGreetingLength => 'Use no more than 80 characters.';

  @override
  String get giftClaimAction => 'Claim gift';

  @override
  String get giftCardPreview => 'Card preview';

  @override
  String get giftGiftForYou => 'A gift for you';

  @override
  String get giftGiftWaiting => 'A gift is waiting for you';

  @override
  String get giftOpenBody =>
      'Open your gifts to claim them with your verified email.';

  @override
  String get giftOpenGifts => 'Open gifts';

  @override
  String get giftSendInvitation => 'Send invitation';

  @override
  String get settingsAiProviderSection => 'Provider';

  @override
  String get settingsAiCustom => 'Custom';

  @override
  String get settingsAiUrlHelper =>
      'Use a public URL the server can reach. Localhost does not work from our servers.';

  @override
  String get settingsAiConnectionSection => 'Connection';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API key';

  @override
  String get settingsAiApiKeySaved => 'Saved. Leave blank to keep it.';

  @override
  String get settingsAiChatModel => 'Chat model';

  @override
  String get settingsAiVisionModel => 'Vision model (optional)';

  @override
  String get settingsAiImageModel => 'Image model (optional)';

  @override
  String get settingsAiImageModelNote =>
      'Image generation needs OpenAI-compatible chat completions with response_modalities.';

  @override
  String get settingsAiTestConnection => 'Test connection';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarGoToToday => 'Go to today';

  @override
  String get calendarConnectTooltip => 'Connect a calendar';

  @override
  String get calendarAddEvent => 'Add event';

  @override
  String get calendarEmptyTitle => 'Nothing planned';

  @override
  String get calendarEmptyBody => 'Add an event and plan what to wear.';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarAllDay => 'All day';

  @override
  String get calendarOutfitLinked => 'Outfit linked';

  @override
  String get calendarEventOptions => 'Event options';

  @override
  String get calendarDeleteTitle => 'Delete this event?';

  @override
  String get calendarChangeOutfit => 'Change outfit';

  @override
  String get calendarLinkOutfit => 'Link an outfit';

  @override
  String get calendarRemoveOutfit => 'Remove outfit';

  @override
  String get calendarNewEvent => 'New event';

  @override
  String get calendarEditEvent => 'Edit event';

  @override
  String get calendarTitleLabel => 'Title';

  @override
  String get calendarTitleRequired => 'Add a title';

  @override
  String get calendarEndBeforeStart => 'End after the start time';

  @override
  String get calendarStarts => 'Starts';

  @override
  String get calendarEnds => 'Ends';

  @override
  String get calendarPlaceOptional => 'Place (optional)';

  @override
  String get calendarNotesOptional => 'Notes (optional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Build an outfit, then link it to this event.';

  @override
  String get calendarBuildOutfit => 'Build an outfit';

  @override
  String get calendarConnectionsTitle => 'Calendars';

  @override
  String get calendarConnectionsBody => 'Events you add here stay in FitCheck.';

  @override
  String get calendarDisconnect => 'Disconnect';

  @override
  String get calendarNotAvailable => 'Not available yet';

  @override
  String get profileSectionExplore => 'Explore';

  @override
  String get profileNavTryOn => 'Try-on';

  @override
  String get profileNavRewards => 'Rewards';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutBody => 'Your closet, outfits and plans in one place.';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody => 'You can sign back in at any time.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileYourProfile => 'Your profile';

  @override
  String get profileBodyProfiles => 'Body profiles';

  @override
  String get profileBodyEmptyTitle => 'No body profiles yet';

  @override
  String get profileBodyEmptyBody =>
      'Add your height and build to get a better fit.';

  @override
  String get profileBodyAdd => 'Add a profile';

  @override
  String get profileBodyDefaultNote =>
      'Your default profile is used for fit and try-on.';

  @override
  String get profileBodyDefaultBadge => 'Default';

  @override
  String get profileBodyMakeDefault => 'Make default';

  @override
  String get profileBodyDeleteBody => 'You cannot undo this.';

  @override
  String get profileBodyRequired => 'Required';

  @override
  String get profileBodyCheckNumber => 'Check this number';

  @override
  String get profileBodyNew => 'New body profile';

  @override
  String get profileBodyNameHint => 'For example, Me';

  @override
  String get profileBodyHeight => 'Height';

  @override
  String get profileBodyWeight => 'Weight';

  @override
  String get profileBodyBuild => 'Build';

  @override
  String get profileBodySkinTone => 'Skin tone';

  @override
  String get profileBirthDateNeededBody =>
      'Add a date of birth to go with the birth time.';

  @override
  String get profileBirthDateNeededTitle => 'Date of birth needed';

  @override
  String get profilePartlySavedBody =>
      'We saved your name and photo. Birth details did not save; try again later.';

  @override
  String get profilePartlySavedTitle => 'Partly saved';

  @override
  String get profileSavedBody => 'Your profile is saved.';

  @override
  String get profileChangePhoto => 'Change profile photo';

  @override
  String get profilePhotoLabel => 'Profile photo';

  @override
  String get profilePhotoHint => 'Tap to choose a new one';

  @override
  String get profileBirthDateLabel => 'Date of birth (optional)';

  @override
  String get profileBirthTimeLabel => 'Birth time (optional)';

  @override
  String get profileBirthTimeHelper => 'Makes Vedic suggestions more exact';

  @override
  String get profileBirthPlaceLabel => 'Birth place (optional)';

  @override
  String get profileBirthPlaceHint => 'For example, New Delhi, India';

  @override
  String get profileHelpContactTitle => 'Ask us anything';

  @override
  String get profileHelpContactBody =>
      'Send a message and we reply by email, usually within a day.';

  @override
  String get profileHelpContactAction => 'Contact support';

  @override
  String get profileHelpFaqTitle => 'Common questions';

  @override
  String get profileFaqAddPiecesTitle => 'How do I add pieces to my closet?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tap Add item on the Closet tab. Take a photo or pick one from your gallery; we find each piece and tag it for you.';

  @override
  String get profileFaqMatchingTitle => 'How does outfit matching work?';

  @override
  String get profileFaqMatchingBody =>
      'Open For you and pick pieces you own. We suggest what goes with them and build full outfits from your closet.';

  @override
  String get profileFaqTryOnTitle => 'Can I use my own photos for try-on?';

  @override
  String get profileFaqTryOnBody =>
      'Yes. Add a full-length photo of yourself, then choose pieces to see them on you.';

  @override
  String get profileFaqRewardsTitle => 'How do I earn rewards?';

  @override
  String get profileFaqRewardsBody =>
      'Plan and log outfits often. Streaks and achievements build as you go.';

  @override
  String get profileFaqPrivacyTitle => 'Is my closet private?';

  @override
  String get profileFaqPrivacyBody =>
      'Yes. Your closet and outfits are private unless you share a link to one outfit.';

  @override
  String get profileHelpMoreTitle => 'More help';

  @override
  String get profileHelpGuides => 'Guides';

  @override
  String get profileHelpGuidesBody => 'How each feature works';

  @override
  String get feedbackCategoryBug => 'Something broke';

  @override
  String get feedbackCategoryIdea => 'An idea';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'I need help';

  @override
  String get feedbackHintBug =>
      'What happened, and what did you expect? Steps help us fix it.';

  @override
  String get feedbackHintIdea => 'What would you like, and why?';

  @override
  String get feedbackHintGeneral =>
      'Tell us what you think, or ask a question.';

  @override
  String get feedbackAttachmentLimitBody => 'You can add up to 5 images.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limit reached';

  @override
  String get feedbackImageTooLargeBody => 'Choose an image under 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Image too large';

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackAboutLabel => 'What is it about?';

  @override
  String get feedbackSubjectLabel => 'Subject';

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
  String get authSignedIn => 'Signed in';

  @override
  String get authWelcomeBackTitle => 'Welcome back';

  @override
  String get authSignInFailed => 'Sign-in failed';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String get authSignUpFailed => 'Sign-up failed';

  @override
  String get authGoogleSignInFailed => 'Google sign-in failed';

  @override
  String get authAppleSignInFailed => 'Apple sign-in failed';

  @override
  String get authConfirmEmailTitle => 'Confirm your email';

  @override
  String get authConfirmEmailBody =>
      'Check your inbox for a confirmation email, then sign in.';

  @override
  String get authClosetReady => 'Your closet is ready.';

  @override
  String get authSignedOutTitle => 'Signed out';

  @override
  String get authSignedOutBody => 'You are signed out.';

  @override
  String get authSignOutFailed => 'Sign-out failed';

  @override
  String get authEmailSentTitle => 'Email sent';

  @override
  String get authResetLinkSent => 'Check your email for a reset link.';

  @override
  String get authPasswordUpdatedTitle => 'Password updated';

  @override
  String get authPasswordUpdated => 'Your password is updated.';

  @override
  String get authPasswordNotUpdated => 'Password not updated';

  @override
  String get authCouldNotSendEmail => 'Could not send the email';

  @override
  String get authEmailNotSent => 'Email not sent';

  @override
  String get authResendSentBody => 'We sent a new confirmation email.';

  @override
  String get outfitPreviewWithAi => 'Preview with AI';

  @override
  String get outfitNewPreview => 'Make a new preview';

  @override
  String get outfitBuilderClosetHeading => 'Your closet';

  @override
  String get outfitBuilderSearchHint => 'Search pieces';

  @override
  String get outfitClearSearch => 'Clear search';

  @override
  String get outfitBuilderAddPiecesTitle => 'Add pieces first';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits are made from the pieces in your closet.';

  @override
  String get outfitBuilderNoMatches => 'No pieces match.';

  @override
  String get outfitNameLabel => 'Outfit name';

  @override
  String get outfitNameHint => 'For example, Weekend linen';

  @override
  String get outfitPreviewSemantic => 'AI preview of the outfit';

  @override
  String get outfitChoosePieces => 'Choose pieces';

  @override
  String get outfitTapPiecesHint => 'Tap pieces below to add them.';

  @override
  String get outfitShareTooltip => 'Share';

  @override
  String get outfitSaveFavourite => 'Save to favourites';

  @override
  String get outfitPiecesHeading => 'Pieces';

  @override
  String get outfitWearHistoryEmpty =>
      'Wear it once and the dates show up here.';

  @override
  String get outfitWearHistoryTitle => 'Wear history';

  @override
  String get outfitWearHistoryError => 'Couldn\'t load the dates.';

  @override
  String get outfitWornOn => 'Worn on';

  @override
  String get outfitEditTitle => 'Edit outfit';

  @override
  String get outfitSavedPhotosFailed => 'Details saved, photos not';

  @override
  String get outfitNoPhotosBody =>
      'No photos yet. The outfit shows its pieces instead.';

  @override
  String get outfitOccasionLabel => 'Occasion';

  @override
  String get outfitOccasionNone => 'None';

  @override
  String get outfitTagsHint => 'Separate with commas';

  @override
  String get outfitDraftBody => 'Hidden from your main list';

  @override
  String get outfitPublic => 'Public';

  @override
  String get outfitPublicBody => 'Anyone with the link can see it';

  @override
  String get outfitDeleteFromDetail =>
      'Delete this outfit from its detail page.';

  @override
  String get outfitNewCollection => 'New collection';

  @override
  String get outfitNoCollectionsTitle => 'No collections yet';

  @override
  String get outfitNoCollectionsBody =>
      'Group outfits by trip, season or mood.';

  @override
  String get outfitCreateCollection => 'Create a collection';

  @override
  String get outfitAddOutfits => 'Add outfits';

  @override
  String get outfitRename => 'Rename';

  @override
  String get outfitCollectionDeleteBody => 'The outfits in it are kept.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfits not loaded';

  @override
  String get outfitRenameCollection => 'Rename collection';

  @override
  String get outfitDescriptionOptional => 'Description (optional)';

  @override
  String get outfitAllInCollection =>
      'Every outfit is already in this collection.';

  @override
  String get photoshootSubtitleUpload =>
      'Studio portraits from your own photos';

  @override
  String get photoshootSubtitleConfigure =>
      'Pick a style, a format and a count';

  @override
  String get photoshootSubtitleGenerating => 'This takes a minute or two';

  @override
  String get photoshootAddPhotosSemantic => 'Add photos from your gallery';

  @override
  String get photoshootUploadTitle => 'Add 1 to 4 photos of yourself';

  @override
  String get photoshootUploadBody => 'Tap to choose from your gallery';

  @override
  String get photoshootAddToContinue => 'Add a photo to continue';

  @override
  String get photoshootAddAnotherPhoto => 'Add another photo';

  @override
  String get photoshootTipsTitle => 'For the best results';

  @override
  String get photoshootTipsBody =>
      'Use clear, well-lit photos of your face from a few angles. Skip sunglasses and hats.';

  @override
  String get photoshootStarting => 'Starting';

  @override
  String get photoshootCancelling => 'Cancelling';

  @override
  String get photoshootFailed => 'Failed';

  @override
  String get recommendTabMatches => 'Matches';

  @override
  String get recommendTabComplete => 'Complete';

  @override
  String get recommendTabWeather => 'Weather';

  @override
  String get recommendTabColours => 'Colours';

  @override
  String get recommendTabShop => 'Shop';

  @override
  String get recommendNoMatchesTitle => 'No matches yet';

  @override
  String get recommendNoMatchesBody =>
      'Pick a piece and we\'ll find what goes with it.';

  @override
  String get recommendPickPiece => 'Pick a piece';

  @override
  String get recommendNothingMatchesTitle => 'Nothing matches these yet';

  @override
  String get recommendNothingMatchesBody =>
      'Try other pieces, or add more to your closet.';

  @override
  String get recommendChangePieces => 'Change pieces';

  @override
  String get recommendDefaultReason => 'It suits the pieces you picked.';

  @override
  String get recommendCompleteTitle => 'Complete a look';

  @override
  String get recommendCompleteBody =>
      'Pick a piece and we\'ll fill in the rest.';

  @override
  String get recommendWorking => 'Working';

  @override
  String get recommendGenerate => 'Generate';

  @override
  String get recommendChooseStyleBody => 'Choose a style, then generate.';

  @override
  String get recommendNoLooksTitle => 'No looks for these pieces';

  @override
  String get recommendNoLooksBody => 'Try another style or other pieces.';

  @override
  String get recommendDefaultLook => 'A look for your pieces';

  @override
  String get recommendNoPiecesBody => 'No pieces came back for this look.';

  @override
  String get recommendCityLabel => 'City';

  @override
  String get recommendCheck => 'Check';

  @override
  String get recommendWeatherTitle => 'What\'s the weather?';

  @override
  String get recommendWeatherBody => 'Enter your city to get picks for today.';

  @override
  String get recommendWearToday => 'Wear today';

  @override
  String get recommendWeatherNoPieces =>
      'No pieces in your closet for this weather yet.';

  @override
  String get recommendBudgetLabel => 'Budget up to';

  @override
  String get recommendLooking => 'Looking';

  @override
  String get recommendFindWhatToBuy => 'Find what to buy';

  @override
  String get recommendFillGapsTitle => 'Fill the gaps';

  @override
  String get recommendFillGapsBody =>
      'Set a budget and we\'ll suggest what your closet is missing.';

  @override
  String get recommendNoGapsTitle => 'No gaps found';

  @override
  String get recommendNoGapsBody => 'Try a bigger budget or another category.';

  @override
  String get recommendMoodEveryday => 'Everyday';

  @override
  String get recommendMoodBigMeeting => 'Big meeting';

  @override
  String get recommendDayLabel => 'Day';

  @override
  String get recommendReadingStars => 'Reading the stars';

  @override
  String get recommendGetMyColours => 'Get my colours';

  @override
  String get recommendLuckyColoursTitle => 'Your lucky colours';

  @override
  String get recommendLuckyColoursBody =>
      'Pick a day and we\'ll suggest colours and pieces for it.';

  @override
  String get recommendLuckyColoursSection => 'Lucky colours';

  @override
  String get recommendAvoidColoursSection => 'Colours to go easy on';

  @override
  String get recommendBirthDateTitle => 'Add your birth date';

  @override
  String get recommendBirthDateBody =>
      'We need your date of birth to read your colours.';

  @override
  String get recommendEditProfile => 'Edit profile';

  @override
  String get recommendNothingThisDay => 'Nothing for this day.';

  @override
  String get recommendUnnamedColour => 'Unnamed colour';

  @override
  String get recommendFromCloset => 'From your closet';

  @override
  String get recommendNoPiecesInColours => 'No pieces in these colours yet.';

  @override
  String get recommendOutfitIdeas => 'Outfit ideas';

  @override
  String get recommendNoOutfitsInColours =>
      'No full outfit in these colours yet.';

  @override
  String get recommendDefaultOutfitIdea => 'An outfit idea';

  @override
  String get recommendPickUpToThree => 'Pick up to three pieces';

  @override
  String get recommendEmptyClosetBody =>
      'Add a few pieces first, then come back for matches.';

  @override
  String get dashboardDressForDay => 'Dress for the day ahead.';

  @override
  String get dashboardOutfitOfDay => 'Outfit of the day';

  @override
  String get dashboardFreshLook => 'A fresh look';

  @override
  String get subscriptionManageInStoreTitle => 'Manage in the store';

  @override
  String get subscriptionManageInStoreBody =>
      'This plan is billed through the store. Manage it in your store account settings.';

  @override
  String get subscriptionCancelledTitle => 'Subscription cancelled';

  @override
  String get subscriptionCancelledBody =>
      'Your plan stays active until the end of this billing period.';

  @override
  String get subscriptionCancelFailedTitle => 'Could not cancel';

  @override
  String get subscriptionCouldNotOpenTitle => 'Could not open';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Could not open billing management.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Could not open the link.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Could not load your link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Could not load your referral link. Try again.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copied';

  @override
  String get subscriptionReferralCopiedBody => 'Referral link copied.';

  @override
  String get subscriptionReferralShareSubject => 'Try FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Join FitCheck AI and we both get a month of Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copied';

  @override
  String get subscriptionShareUnavailableBody =>
      'Sharing is not available, so we copied the link.';

  @override
  String get subscriptionShareFailedTitle => 'Could not share';

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
  String get giftClaimFailedTitle => 'Could not claim the gift';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gifts for you',
      one: 'A gift for you',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 month',
      '12': '1 year',
      'other': '$months months',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining left',
      one: '1 left',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration of FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender sent you $duration of FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'A FitCheck Pro gift for $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'From $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'For $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'From $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'your recipient';

  @override
  String get giftPreviewPlaceholderSender => 'you';

  @override
  String get settingsSavedTitle => 'Saved';

  @override
  String get settingsNotSavedTitle => 'Not saved';

  @override
  String get settingsAiChooseProviderBody => 'Choose a provider.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'A custom provider needs an API URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Enter an API key.';

  @override
  String get settingsAiSavedBody => 'Your AI settings are saved.';

  @override
  String get settingsAiMissingDetailsTitle => 'Missing details';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Enter an API URL and a chat model to test.';

  @override
  String get settingsAiKeyNeededTitle => 'API key needed';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Enter your API key to test. Your saved key stays private.';

  @override
  String get settingsAiKeyToTestBody => 'Enter your API key to test.';

  @override
  String get settingsAiConnectedTitle => 'Connected';

  @override
  String get settingsAiConnectedBody => 'The connection works.';

  @override
  String get settingsAiTestFailedTitle => 'Test failed';

  @override
  String get settingsPreferencesSavedBody => 'Your preferences are saved.';

  @override
  String get settingsPasswordNotChangedTitle => 'Password not changed';

  @override
  String get settingsOAuthPasswordBody =>
      'This account signs in with Google or Apple. Use \"Forgot password\" to set a password first.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Current password is incorrect.';

  @override
  String get settingsExportReadyTitle => 'Export ready';

  @override
  String get settingsExportReadyBody =>
      'Your data export is ready to download.';

  @override
  String get settingsLinkCopiedTitle => 'Link copied';

  @override
  String get settingsExportClipboardBody =>
      'We could not open your browser, so we copied the download link. Paste it into a browser soon: it expires.';

  @override
  String get settingsExportFailedTitle => 'Export failed';

  @override
  String get settingsAccountNotDeletedTitle => 'Account not deleted';

  @override
  String photoshootPhotoLimit(int max) {
    return 'You can add up to $max photos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Photo limit';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Add at least one photo.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'No photos';

  @override
  String get photoshootDescribeLookBody => 'Describe the look you want.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt needed';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Preparing your photos';

  @override
  String get photoshootStatusGenerating => 'Generating';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current of $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generation failed.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready ready, $failed failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Partly done';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos are ready.',
      one: '1 photo is ready.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'We lost the connection. Please try again.';

  @override
  String get photoshootCouldNotCancelTitle => 'Could not cancel';

  @override
  String get photoshootRetryFailedTitle => 'Retry failed';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Photo $number is ready.';
  }

  @override
  String get photoshootReplacedTitle => 'Replaced';

  @override
  String get photoshootSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get photoshootSavedTitle => 'Saved';

  @override
  String get photoshootNotSavedTitle => 'Not saved';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count photos are in your gallery.',
      one: '1 photo is in your gallery.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved of $total saved.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Some photos not saved';

  @override
  String get tryonConsentFeatureLabel => 'Virtual Try-On';

  @override
  String get tryonAvatarUpdatedBody => 'Your photo is updated.';

  @override
  String get tryonSavedTitle => 'Saved';

  @override
  String get tryonUploadFailedTitle => 'Upload failed';

  @override
  String get tryonChooseGarmentFirstBody => 'Choose a garment photo first.';

  @override
  String get tryonNoGarmentTitle => 'No garment';

  @override
  String get tryonWaitForUploadBody =>
      'Wait for your photo to finish uploading.';

  @override
  String get tryonStillUploadingTitle => 'Still uploading';

  @override
  String get tryonAddYourPhotoFirstBody => 'Add a photo of yourself first.';

  @override
  String get tryonReadyBody => 'Your try-on is ready.';

  @override
  String get tryonFailedTitle => 'Try-on failed';

  @override
  String get tryonSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get tryonNotSavedTitle => 'Not saved';

  @override
  String get calendarEventAddedBody => 'Event added';

  @override
  String get calendarEventPlannedTitle => 'Planned';

  @override
  String get calendarEventSavedBody => 'Event saved';

  @override
  String get calendarSavedTitle => 'Saved';

  @override
  String get calendarEventNotSavedTitle => 'Event not saved';

  @override
  String get calendarEventRemovedBody => 'Event removed';

  @override
  String get calendarEventDeletedTitle => 'Deleted';

  @override
  String get calendarEventNotDeletedTitle => 'Event not deleted';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit not linked';

  @override
  String get calendarLinkedTitle => 'Linked';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit not removed';

  @override
  String get calendarOutfitRemovedBody => 'Outfit removed';

  @override
  String get calendarDisconnectedBody => 'Calendar disconnected';

  @override
  String get calendarDisconnectedTitle => 'Disconnected';

  @override
  String get calendarNotDisconnectedTitle => 'Calendar not disconnected';

  @override
  String get calendarTodayLabel => 'today';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit linked';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" will be removed.';
  }

  @override
  String get calendarThisAppLabel => 'This app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Syncing with $provider is not available yet. You can still add events here.';
  }

  @override
  String get calendarWeekdaySunShort => 'Sun';

  @override
  String get calendarWeekdayMonShort => 'Mon';

  @override
  String get calendarWeekdayTueShort => 'Tue';

  @override
  String get calendarWeekdayWedShort => 'Wed';

  @override
  String get calendarWeekdayThuShort => 'Thu';

  @override
  String get calendarWeekdayFriShort => 'Fri';

  @override
  String get calendarWeekdaySatShort => 'Sat';

  @override
  String get calendarWeekdayMonday => 'Monday';

  @override
  String get calendarWeekdayTuesday => 'Tuesday';

  @override
  String get calendarWeekdayWednesday => 'Wednesday';

  @override
  String get calendarWeekdayThursday => 'Thursday';

  @override
  String get calendarWeekdayFriday => 'Friday';

  @override
  String get calendarWeekdaySaturday => 'Saturday';

  @override
  String get calendarWeekdaySunday => 'Sunday';

  @override
  String get outfitSavedToFavouritesBody => 'Saved to favourites';

  @override
  String get outfitRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get outfitNotSavedTitle => 'Not saved';

  @override
  String get outfitLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get outfitNicePickTitle => 'Nice pick';

  @override
  String get outfitRemovedBody => 'Outfit removed.';

  @override
  String get outfitDeletedTitle => 'Deleted';

  @override
  String get outfitNotDeletedTitle => 'Not deleted';

  @override
  String get outfitDuplicatedBody => 'A copy is in your outfits.';

  @override
  String get outfitDuplicatedTitle => 'Duplicated';

  @override
  String get outfitNotDuplicatedTitle => 'Not duplicated';

  @override
  String get outfitNotSharedTitle => 'Not shared';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" is ready.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collection not created';

  @override
  String get outfitCollectionUpdatedBody => 'Collection updated.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collection not updated';

  @override
  String get outfitCollectionDeletedBody => 'Collection deleted.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collection not deleted';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits added.',
      one: '1 outfit added.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits not added';

  @override
  String get outfitPreviewNotCreatedTitle => 'Preview not created';

  @override
  String get outfitGiveNameBody => 'Give the outfit a name.';

  @override
  String get outfitNameMissingTitle => 'Name';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Choose at least one piece.';

  @override
  String outfitCreatedBody(String name) {
    return '$name is in your outfits.';
  }

  @override
  String get outfitSavedTitle => 'Saved';

  @override
  String get wardrobeAddedToFavouritesBody => 'Added to favourites';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get wardrobeNotSavedTitle => 'Not saved';

  @override
  String get wardrobeLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Removed from your closet.';

  @override
  String get wardrobeDeletedTitle => 'Deleted';

  @override
  String get wardrobeNotDeletedTitle => 'Not deleted';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces removed from your closet.',
      one: '1 piece removed from your closet.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI Wardrobe Extraction';

  @override
  String get itemAddScanJobLabel => 'Scan';

  @override
  String get itemAddFoundEarlierBody => 'Found in an earlier scan';

  @override
  String get itemAddLookingAtPhoto => 'Looking at your photo';

  @override
  String get itemAddExtractionFailedBody => 'Extraction failed';

  @override
  String get itemAddJobFailedBody => 'Job failed';

  @override
  String get itemAddConnectionLostBody => 'Connection was lost. Try again.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Connection lost while processing.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Piece $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Piece';

  @override
  String get itemAddNotCancelledTitle => 'Not cancelled';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces are in your closet.',
      one: '1 piece is in your closet.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved of $total pieces saved. Tap save to try the rest again.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Some pieces not saved';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Choose at least one photo.';

  @override
  String get batchPhotoUnreadableBody => 'This photo could not be read.';

  @override
  String get batchNoPhotosReadableBody =>
      'None of these photos could be read. Try other photos.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'We lost the connection while working. Try again.';

  @override
  String get batchNotCancelledTitle => 'Not cancelled';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Post links are not supported. Enter a profile link.';

  @override
  String get batchLinkSpacesBody => 'Links cannot contain spaces.';

  @override
  String get batchEnterProfileLinkBody =>
      'Enter an Instagram or Facebook profile link.';

  @override
  String get batchEnterProfileLinkShortBody => 'Enter a profile link.';

  @override
  String get batchSignInPageNotOpenBody =>
      'The sign-in page did not open. Try again.';

  @override
  String get batchSignInBrowserBody =>
      'Sign in in your browser, then come back to FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Connect your account';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Enter the code from your authenticator app.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram wants a security check. Sign in in your browser first.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Enter your username and password again.';

  @override
  String get batchSignInFailedBody =>
      'Sign-in failed. Check your username and password.';

  @override
  String get batchSignInToKeepImportingBody => 'Sign in to keep importing.';

  @override
  String get batchAccountNotConnectedBody => 'Your account was not connected.';

  @override
  String get batchAccountConnectedTitle => 'Account connected';

  @override
  String get batchNotConnectedTitle => 'Not connected';

  @override
  String get batchImportConnectionLostBody =>
      'We lost the connection to the import. Refresh to check it.';

  @override
  String batchPickUpToBody(int max) {
    return 'Pick up to $max photos. We find the pieces.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count of $total photos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparing photo $done of $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Find pieces in $count photos',
      one: 'Find pieces in 1 photo',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Your $platform account uses two-step sign-in. Enter the 6-digit code from your authenticator app.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'This $platform profile is private or needs a sign-in to show its photos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Connect with $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos found so far',
      one: '1 photo found so far',
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
    return '$processed of $total processed · $added added · $waiting waiting · $skipped skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Scanning photo $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Photo $number is next';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Photo $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces found',
      one: '1 piece found',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos were added to your closet.',
      one: '1 photo was added to your closet.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count more studio photos on the way. You can save what is ready, or leave — we will let you know.',
      one:
          '1 more studio photo on the way. You can save what is ready, or leave — we will let you know.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Not saved yet: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces pieces',
      one: '1 piece',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos photos',
      one: '1 photo',
    );
    return '$_temp0 from $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen chosen. Tap a piece to skip it.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saving $count pieces',
      one: 'Saving 1 piece',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count pieces',
      one: 'Save 1 piece',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Your body profile is saved.';

  @override
  String get bodyProfileSavedTitle => 'Saved';

  @override
  String get bodyProfileNotSavedTitle => 'Not saved';

  @override
  String get bodyProfileSetDefaultBody => 'Set as your default profile.';

  @override
  String get bodyProfileDeletedBody => 'Body profile deleted.';

  @override
  String get bodyProfileDeletedTitle => 'Deleted';

  @override
  String get bodyProfileNotDeletedTitle => 'Not deleted';

  @override
  String get feedbackNotSentTitle => 'Not sent';

  @override
  String get feedbackSentBody =>
      'Thanks. We read every message and reply if we need more.';

  @override
  String get feedbackSentTitle => 'Feedback sent';

  @override
  String get recommendUnnamedPiece => 'Unnamed piece';

  @override
  String get recommendEnterCityBody =>
      'Enter your city to get picks for the weather.';

  @override
  String get recommendWhichCityTitle => 'Which city?';

  @override
  String get aiConsentSheetTitle => 'Sharing photos with an AI service';

  @override
  String get aiConsentSheetBody =>
      'To create your try-on and photoshoot images, FitCheck AI sends the photos you provide (including images of your face and body) to a trusted third-party AI provider (such as OpenAI or Google Gemini) for processing. They generate your images and do not use them to train their models under our terms. Photos are transmitted securely and never shared for advertising.';

  @override
  String get aiConsentSheetPermission =>
      'By continuing, you give explicit permission to share your photos with these AI providers for image generation.';

  @override
  String get skeletonsLoadMoreFailed => 'Couldn\'t load more.';

  @override
  String get jobsPiecesReadyTitle => 'Your pieces are ready';

  @override
  String get jobsScanStoppedTitle => 'The scan stopped';

  @override
  String get jobsNothingSavedBody => 'Nothing was saved. Try again.';

  @override
  String get jobsPhotoUploadFailedBody => 'Photo upload failed.';

  @override
  String get authGoogleSignInStartFailed =>
      'Unable to start Google Sign-In. Please try again.';

  @override
  String get referralAppliedTitle => 'Referral Applied!';

  @override
  String get billingStoreUnavailableBody =>
      'Store purchases are not available on this device.';

  @override
  String get billingPurchaseProcessingBody =>
      'This purchase is still being processed. Reopen the app in a minute to see your plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatar upload did not return an image URL.';

  @override
  String get rewardsDayStreakLabel => 'day streak';

  @override
  String rewardsBestStreak(int days) {
    return 'Best $days days';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission Access Needed';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Access to $permission is currently denied. Open Settings to allow it, then come back and try again.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Step $step of 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Remove image $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Remove image $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Email $email. We review reports within 24 hours.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Remove $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Add to \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" is removed. Its pieces stay in your closet.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Show all $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count left today';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Photo $index failed';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected of $max photos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape build · $tone skin';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: not set';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked of $max picked';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Remove $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency priority';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'This plan is billed through the $store. Change or cancel it in your $store account settings.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Manage in the $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current of $max used';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'About ${seconds}s left';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done of $total studio photos ready';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready of $total studio photos ready. Tap a piece to skip it.';
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
  String get profileFieldNotSet => 'No';
}

/// The translations for English, as used in Australia (`en_AU`).
class AppLocalizationsEnAu extends AppLocalizationsEn {
  AppLocalizationsEnAu() : super('en_AU');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPhotoshoot => 'Photoshoot';

  @override
  String get tabCloset => 'Closet';

  @override
  String get tabOutfits => 'Outfits';

  @override
  String get tabMore => 'More';

  @override
  String get actionAddItem => 'Add item';

  @override
  String get actionCreateOutfit => 'Create outfit';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionContinue => 'Continue';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorBody =>
      'Try again. If it keeps failing, contact support.';

  @override
  String get stateOfflineTitle => 'You are offline';

  @override
  String get stateOfflineBody =>
      'Reconnect to sync your closet and generate outfits.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsPlanBilling => 'Plan and billing';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsUnits => 'Measurement units';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPrivacySection => 'Privacy and data';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountBody =>
      'This removes your closet, outfits, photos and profile. It cannot be undone.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metric (cm, kg)';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageSystemBody =>
      'FitCheck AI follows your phone\'s language.';

  @override
  String get languageSearchHint => 'Search languages';

  @override
  String get languageCurrent => 'Current';

  @override
  String get languageReviewNote =>
      'This translation is new. Tell us if something reads wrong.';

  @override
  String get languageChanged => 'Language updated';

  @override
  String get paywallTitle => 'Choose your plan';

  @override
  String get paywallTrialBadge => '1 month free';

  @override
  String get paywallTrialTitle => 'Your first month of Pro is free';

  @override
  String get paywallTrialBody =>
      'Upload your whole closet at once. Add pieces as you go after that.';

  @override
  String get paywallFreeForeverTitle => 'Free forever';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'No card needed. Every month you get $uploads AI uploads, $outfits outfits and $images photoshoot images a day.';
  }

  @override
  String get paywallCtaTrial => 'Start my free month';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Upgrade to $plan';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallManage => 'Manage subscription';

  @override
  String get paywallTerms => 'Terms of use';

  @override
  String get paywallPrivacy => 'Privacy policy';

  @override
  String get paywallPerMonth => 'per month';

  @override
  String get paywallPerYear => 'per year';

  @override
  String get paywallBestValue => 'Best value';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Free trial for new subscribers only. After the trial, Pro renews at $price unless cancelled at least 24 hours before it ends.';
  }

  @override
  String get introTitle => 'Your closet, finally organised';

  @override
  String get introBody =>
      'Photograph your clothes once. Get outfit ideas, try-on previews and studio photos from what you already own.';

  @override
  String get introStart => 'Get started';

  @override
  String get introHaveAccount => 'I already have an account';

  @override
  String get introSkip => 'Skip';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authOrDivider => 'or';

  @override
  String get wardrobeTitle => 'Closet';

  @override
  String get wardrobeEmptyTitle => 'Your closet is empty';

  @override
  String get wardrobeEmptyBody =>
      'Add your first piece, or upload a photo of the whole rail at once.';

  @override
  String get wardrobeAddFirst => 'Add your first item';

  @override
  String get wardrobeSearchHint => 'Search your closet';

  @override
  String get categoryTops => 'Tops';

  @override
  String get categoryBottoms => 'Bottoms';

  @override
  String get categoryShoes => 'Shoes';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get categoryOuterwear => 'Outerwear';

  @override
  String get categorySwimwear => 'Swimwear';

  @override
  String get categoryActivewear => 'Activewear';

  @override
  String get categoryOther => 'Other';

  @override
  String get conditionClean => 'Clean';

  @override
  String get conditionDirty => 'Dirty';

  @override
  String get conditionLaundry => 'In laundry';

  @override
  String get conditionRepair => 'Needs repair';

  @override
  String get conditionDonate => 'To donate';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonFall => 'Fall';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonAll => 'All season';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sporty';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalist';

  @override
  String get styleRomantic => 'Romantic';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Other';

  @override
  String get occasionWork => 'Work';

  @override
  String get occasionDateNight => 'Date night';

  @override
  String get occasionTravel => 'Travel';

  @override
  String get occasionWedding => 'Wedding';

  @override
  String get occasionGym => 'Gym';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Party';

  @override
  String get occasionInterview => 'Interview';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorWhite => 'White';

  @override
  String get colorGrey => 'Grey';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorRed => 'Red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Enjoying FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'A quick rating helps other people find their style.';

  @override
  String get ratingPromptYes => 'Rate the app';

  @override
  String get ratingPromptNo => 'Not now';

  @override
  String get closetNoMatchesTitle => 'No pieces match';

  @override
  String get closetNoMatchesBody => 'Try fewer filters or another search.';

  @override
  String get closetClearFilters => 'Clear filters';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Loading your pieces';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Delete selected';

  @override
  String get closetCancelSelection => 'Cancel selection';

  @override
  String get closetCloseSearch => 'Close search';

  @override
  String get closetShowGrid => 'Show as grid';

  @override
  String get closetShowList => 'Show as list';

  @override
  String get closetShowRows => 'Show as rows';

  @override
  String get closetStatsTitle => 'Closet stats';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count pieces?',
      one: 'Delete 1 piece?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Outfits that use them lose these pieces.';

  @override
  String get closetSortBy => 'Sort by';

  @override
  String get closetFavourites => 'Favourites';

  @override
  String get closetFavourite => 'Favourite';

  @override
  String get closetUnfavourite => 'Remove favourite';

  @override
  String get closetWoreToday => 'Wore it today';

  @override
  String closetWornTimes(int count) {
    return 'Worn $count×';
  }

  @override
  String get closetCategoryLabel => 'Category';

  @override
  String get closetUseCaseLabel => 'Use case';

  @override
  String get closetAnyUseCase => 'Any';

  @override
  String get closetOtherUseCase => 'Other use case';

  @override
  String get closetOtherUseCaseHint => 'For example, brunch';

  @override
  String get closetUseUseCase => 'Use this';

  @override
  String get closetClearAll => 'Clear all';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortName => 'Name (A–Z)';

  @override
  String get sortMostWorn => 'Most worn';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Dinner';

  @override
  String get useCaseLunch => 'Lunch';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sort';

  @override
  String get actionAll => 'All';

  @override
  String get dashboardStartClosetTitle => 'Start your closet';

  @override
  String get dashboardStartClosetBody =>
      'Photograph a few pieces. We tag them for you.';

  @override
  String get dashboardPieces => 'pieces';

  @override
  String get dashboardOutfits => 'outfits';

  @override
  String get dashboardDayStreak => 'day streak';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count this month';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Best $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favourites',
      one: '1 favourite',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved outfits',
      one: '1 saved outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String get setupSkip => 'Skip setup';

  @override
  String get setupWhoTitle => 'Who are we styling?';

  @override
  String get setupWhoBody =>
      'Sets the model for try-on and photoshoots. You can change it in your profile.';

  @override
  String get setupStyleTitle => 'What do you wear most?';

  @override
  String get setupStyleBody => 'Pick any. Outfit ideas start from these.';

  @override
  String get setupClosetTitle => 'Add your first pieces.';

  @override
  String get setupClosetBody =>
      'Photograph a few clothes, or a pile of them. Each piece is cut out and filed for you.';

  @override
  String get setupAddClothes => 'Add clothes';

  @override
  String get setupStylesLabel => 'Styles';

  @override
  String get setupOccasionsLabel => 'Occasions';

  @override
  String get setupSkipStep => 'Skip';

  @override
  String get setupLater => 'Later';

  @override
  String get setupSaveError => 'Could not save';

  @override
  String get genderWomen => 'Women';

  @override
  String get genderMen => 'Men';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get outfitEmptyTitle => 'No outfits yet';

  @override
  String get outfitEmptyBody =>
      'Pair pieces from your closet and save the look.';

  @override
  String get outfitNoMatchesTitle => 'No outfits match';

  @override
  String get outfitSearchHint => 'Search your outfits';

  @override
  String get outfitLoading => 'Loading your outfits';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Style and season';

  @override
  String get outfitCollections => 'Collections';

  @override
  String get outfitDuplicate => 'Duplicate';

  @override
  String get outfitDeleteTitle => 'Delete this outfit?';

  @override
  String get outfitDeleteBody => 'Its pieces stay in your closet.';

  @override
  String get outfitDrafts => 'Drafts';

  @override
  String get outfitDraft => 'Draft';

  @override
  String get filterStyle => 'Style';

  @override
  String get filterSeason => 'Season';

  @override
  String get itemDetailDeleteTitle => 'Delete this piece?';

  @override
  String get itemDetailDeleteBody => 'Outfits that use it lose this piece.';

  @override
  String get itemAddFavourite => 'Add to favourites';

  @override
  String itemSize(String size) {
    return 'Size $size';
  }

  @override
  String get itemColours => 'Colours';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Pattern';

  @override
  String get itemUseCases => 'Use cases';

  @override
  String get itemKeptIn => 'Kept in';

  @override
  String get itemPrice => 'Price';

  @override
  String get itemBought => 'Bought';

  @override
  String get itemTags => 'Tags';

  @override
  String get itemAdded => 'Added';

  @override
  String get itemTimesWornLabel => 'times worn';

  @override
  String get itemLastWornLabel => 'last worn';

  @override
  String get itemNeverWorn => 'Never';

  @override
  String get authEntryBody =>
      'Every piece you own, styled by AI. Plan outfits, try them on, shoot them.';

  @override
  String get authCreateCloset => 'Create your closet';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInBody => 'Sign in to open your closet.';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authCreateClosetBody =>
      'It takes a minute. Your first items are free.';

  @override
  String get authName => 'Name';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authReferralCode => 'Referral code (optional)';

  @override
  String get authResetTitle => 'Reset your password';

  @override
  String get authResetBody => 'We will email you a link to choose a new one.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authEnterEmail => 'Enter your email';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authEnterPassword => 'Enter your password';

  @override
  String get authPasswordTooShort => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authNewHere => 'New here?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirm $email before you sign in. Check your inbox.';
  }

  @override
  String get authResendEmail => 'Send it again';

  @override
  String get authResendingEmail => 'Sending…';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authEnterName => 'Enter your name';

  @override
  String get authChoosePassword => 'Choose a password';

  @override
  String get authHaveAccount => 'Have an account?';

  @override
  String get authCodeAccepted => 'Code accepted';

  @override
  String get authCodeNotFound => 'Code not found';

  @override
  String authReferralFrom(String name) {
    return 'From $name. You both get a month free.';
  }

  @override
  String get authReferralInvalid => 'We could not find this code.';

  @override
  String authResetSent(String email) {
    return 'Sent to $email. Open the link on this phone.';
  }

  @override
  String get introSlide1Title => 'Snap your closet once.';

  @override
  String get introSlide1Body =>
      'Photograph a pile of clothes. Every piece is cut out and filed for you.';

  @override
  String get introSlide2Title => 'Get dressed faster.';

  @override
  String get introSlide2Body =>
      'Outfits from what you own, matched to your plans and the weather.';

  @override
  String get introSlide3Title => 'See it before you wear it.';

  @override
  String get introSlide3Body =>
      'Try looks on your own photo, or shoot them like a campaign.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTemperature => 'Temperature';

  @override
  String get settingsEmailUpdates => 'Email updates';

  @override
  String get settingsEmailUpdatesBody => 'News and tips by email';

  @override
  String get settingsOutfitReminders => 'Outfit reminders';

  @override
  String get settingsOutfitRemindersBody => 'A nudge to log what you wore';

  @override
  String get settingsWeeklySummary => 'Weekly summary';

  @override
  String get settingsWeeklySummaryBody => 'Your week in outfits';

  @override
  String get settingsStyleSection => 'Style';

  @override
  String get settingsPreferredStyles => 'Styles you like';

  @override
  String get settingsPreferredColours => 'Colours you like';

  @override
  String get settingsNoneChosen => 'None chosen';

  @override
  String get settingsPlanAiSection => 'Plan and AI';

  @override
  String get settingsPlanBillingBody => 'Plan, usage and upgrades';

  @override
  String get settingsPlanUsageBody => 'Plan and usage';

  @override
  String get settingsInviteFriends => 'Invite friends';

  @override
  String get settingsInviteFriendsBody =>
      'A free month for each friend who joins';

  @override
  String get settingsAiProvider => 'AI provider';

  @override
  String get settingsAiProviderBody =>
      'Use your own model for tagging and images';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsPrivacyTerms => 'Privacy and terms';

  @override
  String get settingsReportProblem => 'Report a problem';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsExportData => 'Export your data';

  @override
  String get settingsExportBody =>
      'We prepare a file with everything you saved and open the download.';

  @override
  String get settingsExportAction => 'Export';

  @override
  String get settingsCurrentPassword => 'Current password';

  @override
  String get settingsNewPassword => 'New password';

  @override
  String get settingsConfirmNewPassword => 'Confirm new password';

  @override
  String get settingsEnterCurrentPassword => 'Enter your current password';

  @override
  String get settingsEnterNewPassword => 'Enter a new password';

  @override
  String get settingsPasswordMin8 => 'Use at least 8 characters';

  @override
  String get settingsPasswordNeedsUpper => 'Add an uppercase letter';

  @override
  String get settingsPasswordNeedsLower => 'Add a lowercase letter';

  @override
  String get settingsPasswordNeedsDigit => 'Add a number';

  @override
  String get settingsPasswordsNoMatch => 'The passwords do not match';

  @override
  String get settingsChangeAction => 'Change';

  @override
  String get itemAddSnapTitle => 'Snap a piece';

  @override
  String get itemAddSnapBody =>
      'We find every piece in the photo and make a clean studio shot of each.';

  @override
  String get itemAddCamera => 'Take a photo';

  @override
  String get itemAddGallery => 'Choose from gallery';

  @override
  String get itemAddOtherWays => 'Other ways to add';

  @override
  String get itemAddSeveral => 'Add several photos';

  @override
  String get itemAddSeveralBody => 'Up to 50 at once';

  @override
  String get itemAddImportProfile => 'Import from a profile';

  @override
  String get itemAddImportProfileBody => 'Instagram or Facebook';

  @override
  String get itemAddEnterDetails => 'Enter details yourself';

  @override
  String get itemAddEnterDetailsBody => 'No photo needed';

  @override
  String get itemManualIntro =>
      'Only a name is needed. Add the rest now or later.';

  @override
  String get itemManualNameHint => 'For example, blue cotton tee';

  @override
  String get itemManualEnterName => 'Enter a name';

  @override
  String get itemManualNotes => 'Notes';

  @override
  String get itemManualBrand => 'Brand';

  @override
  String get itemManualSize => 'Size';

  @override
  String get itemManualEnterNumber => 'Enter a number';

  @override
  String get itemManualSavePiece => 'Save piece';

  @override
  String get itemManualSaving => 'Saving';

  @override
  String get itemManualSavedTitle => 'Saved';

  @override
  String itemManualSavedBody(String name) {
    return '$name is in your closet.';
  }

  @override
  String get itemManualNotSaved => 'Not saved';

  @override
  String get itemManualAddUseCase => 'Add a use case';

  @override
  String get itemManualAddUseCaseAction => 'Add use case';

  @override
  String get itemPhotos => 'Photos';

  @override
  String get itemAddPhotos => 'Add photos';

  @override
  String get itemNoPhotoYet => 'No photo yet. You can save without one.';

  @override
  String get itemRemovePhoto => 'Remove photo';

  @override
  String get itemRemovePiece => 'Remove piece';

  @override
  String get filterConditionLabel => 'Condition';

  @override
  String get photoshootStepPhotos => 'Photos';

  @override
  String get photoshootStepSetup => 'Setup';

  @override
  String get photoshootStepCreating => 'Creating';

  @override
  String get photoshootStepResults => 'Results';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Step $current of $total, $name';
  }

  @override
  String get photoshootOneFailed => 'One photo failed. Retry it below.';

  @override
  String photoshootManyFailed(int count) {
    return '$count photos failed. Retry each one below.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'How many';

  @override
  String get photoshootYourPrompt => 'Your prompt';

  @override
  String get photoshootPromptHint => 'Golden hour on a rooftop, linen shirt';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create $count photos',
      one: 'Create 1 photo',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'photos',
      one: 'photo',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'We couldn\'t check today\'s limit.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan plan: $remaining of $limit left today';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Free';

  @override
  String get photoshootGallery => 'Gallery';

  @override
  String get photoshootUseCamera => 'Use camera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Remove photo $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'No photos came back';

  @override
  String get photoshootNoPhotosBody =>
      'The shoot finished without images. Try again.';

  @override
  String get photoshootNewStyle => 'New style';

  @override
  String get photoshootNewPhotos => 'New photos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Open photo $number';
  }

  @override
  String get photoshootReportPhoto => 'Report photo';

  @override
  String get photoshootSaveToGallery => 'Save to gallery';

  @override
  String get actionUpgrade => 'Upgrade';

  @override
  String get referralLimitTitle => 'You\'ve used today\'s photos';

  @override
  String get referralLimitBody =>
      'Your free photos come back tomorrow. Refer a friend and you both get a month of Pro free.';

  @override
  String get referralLimitRefer => 'Refer a friend';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating app';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Aesthetic';

  @override
  String get photoshootUseCustom => 'Your own prompt';

  @override
  String get photoshootDescLinkedin => 'Sharp headshots for work';

  @override
  String get photoshootDescDating => 'Relaxed, warm and natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, high-fashion looks';

  @override
  String get photoshootDescInstagram => 'Lifestyle shots for your feed';

  @override
  String get photoshootDescAesthetic => 'Moody, artistic frames';

  @override
  String get photoshootDescCustom => 'Describe the look you want';

  @override
  String get aspectSquare => 'Square';

  @override
  String get aspectPortrait => 'Portrait';

  @override
  String get aspectLandscape => 'Landscape';

  @override
  String get aspectTall => 'Tall';

  @override
  String get aspectWide => 'Wide';

  @override
  String get tryOnAppBar => 'Virtual try-on';

  @override
  String get tryOnYourPhoto => 'Your photo';

  @override
  String get tryOnGarment => 'Garment';

  @override
  String get tryOnUploadingPhoto => 'Uploading your photo';

  @override
  String get tryOnAddPhotoPrompt => 'Add a full-body photo of yourself';

  @override
  String get tryOnBodyPhotoHint => 'A full-body photo works best';

  @override
  String get tryOnAddPhoto => 'Add photo';

  @override
  String get tryOnChangePhoto => 'Change photo';

  @override
  String get tryOnPhotoLoadFailed => 'We couldn\'t load your photo.';

  @override
  String get tryOnChooseGarment => 'Choose a garment photo';

  @override
  String get tryOnChooseOneGarment => 'Choose one garment photo';

  @override
  String get tryOnGarmentHint => 'A flat lay or a hanger shot works best';

  @override
  String get tryOnChange => 'Change';

  @override
  String get tryOnCamera => 'Camera';

  @override
  String get tryOnRemove => 'Remove';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Style';

  @override
  String get tryOnBackground => 'Background';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Dressing you up. This takes about half a minute.';

  @override
  String get tryOnEmptyResult => 'Your try-on appears here';

  @override
  String get tryOnReportImage => 'Report image';

  @override
  String get tryOnCreating => 'Creating';

  @override
  String get tryOnTryAgain => 'Try again';

  @override
  String get tryOnCreate => 'Create try-on';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio white';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio grey';

  @override
  String get tryOnBackgroundUrban => 'Urban street';

  @override
  String get tryOnBackgroundNature => 'Nature';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Standing front';

  @override
  String get tryOnPoseSide => 'Standing side';

  @override
  String get tryOnPoseWalking => 'Walking';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardWelcome => 'Welcome';

  @override
  String get dashboardOpenProfile => 'Open profile';

  @override
  String get dashboardRailToday => 'Today';

  @override
  String get dashboardRailRecently => 'Recently';

  @override
  String get dashboardActivityEmpty => 'New pieces and outfits show up here.';

  @override
  String get quickAddPiece => 'Add a piece';

  @override
  String get quickAddPieceBody => 'Photograph and tag';

  @override
  String get quickBuildOutfit => 'Build an outfit';

  @override
  String get quickBuildOutfitBody => 'Mix your pieces';

  @override
  String get quickForYou => 'For you';

  @override
  String get quickForYouBody => 'Picks for today';

  @override
  String get quickPlanWeek => 'Plan the week';

  @override
  String get quickPlanWeekBody => 'Outfits by date';

  @override
  String get referralBannerUrgent => 'Running low? Invite a friend.';

  @override
  String get referralBannerTitle => 'Give a month, get a month.';

  @override
  String get referralBannerBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get referralBannerDismiss => 'Dismiss for a week';

  @override
  String get referralBannerShare => 'Share invite';

  @override
  String get referralBannerCopy => 'Copy link';

  @override
  String get itemEditPieceTitle => 'Edit piece';

  @override
  String get itemEditDescriptionLabel => 'Description';

  @override
  String get itemEditNotSaved => 'Not saved';

  @override
  String get itemEditSavedTitle => 'Saved';

  @override
  String get itemEditSavedBody => 'Your changes are saved.';

  @override
  String get itemEditSavedStalePhotos => 'Saved — photos may be out of date';

  @override
  String get itemEditRemovePieceHint => 'Delete this piece from the item page.';

  @override
  String get itemEditNoPhotos =>
      'No photos yet. Add one from your gallery or camera.';

  @override
  String get itemEditKeepPhoto => 'Keep photo';

  @override
  String get itemEditRemoved => 'Removed';

  @override
  String get itemEditAddUseCaseAction => 'Add';

  @override
  String get statsNoStatsTitle => 'No stats yet';

  @override
  String get statsNoStatsBody =>
      'Add a few pieces and your closet mix shows up here.';

  @override
  String get statsByCategory => 'By category';

  @override
  String get statsTotalValue => 'total value';

  @override
  String get statsMostWorn => 'Worn the most';

  @override
  String get statsLeastWorn => 'Waiting for a turn';

  @override
  String get statsUnnamedPiece => 'Unnamed piece';

  @override
  String get jobsTitle => 'Scans';

  @override
  String get jobsEmptyTitle => 'No scans yet';

  @override
  String get jobsEmptyBody =>
      'Snap a piece and send it to the background — it keeps working here.';

  @override
  String get jobsNotCancelled => 'Not cancelled';

  @override
  String get jobsResume => 'Resume';

  @override
  String get jobsReview => 'Review';

  @override
  String get jobsStop => 'Stop';

  @override
  String get jobsDismiss => 'Dismiss';

  @override
  String get reportTitle => 'Report content';

  @override
  String reportIntro(String contentType) {
    return 'Tell us what\'s wrong with this $contentType. Our team reviews every report.';
  }

  @override
  String get reportReasonInappropriate => 'Inappropriate or offensive';

  @override
  String get reportReasonNudity => 'Nudity or sexual content';

  @override
  String get reportReasonHarassment => 'Harassment or abuse';

  @override
  String get reportReasonImpersonation => 'Impersonation';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportDetailsLabel => 'Additional details (optional)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSubmittedTitle => 'Report submitted';

  @override
  String get reportSubmittedBody =>
      'Thank you. Our team will review this content.';

  @override
  String get reportFailedTitle => 'Couldn\'t send report';

  @override
  String get reportFailedBody => 'Please try again.';

  @override
  String get reportContentTryOnImage => 'AI try-on image';

  @override
  String get reportContentSharedOutfit => 'shared outfit';

  @override
  String get reportContentPhotoshootImage => 'AI photoshoot image';

  @override
  String get sharedOutfitTitle => 'Shared outfit';

  @override
  String get sharedOutfitHideTooltip => 'Hide this outfit';

  @override
  String get sharedOutfitReportTooltip => 'Report this outfit';

  @override
  String get sharedOutfitHideTitle => 'Hide this outfit?';

  @override
  String get sharedOutfitHideBody =>
      'It stays hidden on this device. You can also report it so our team can review and remove it.';

  @override
  String get sharedOutfitHideAction => 'Hide';

  @override
  String get sharedOutfitHiddenInfo =>
      'This outfit will not show on this device again.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit hidden';

  @override
  String get sharedOutfitMissingTitle => 'This outfit isn\'t here anymore';

  @override
  String get sharedOutfitMissingBody =>
      'It may have been removed, or the link is wrong.';

  @override
  String get sharedOutfitHiddenStateTitle => 'You hid this outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'If it was objectionable, report it from Privacy and terms or email $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Like this look?';

  @override
  String get sharedOutfitCtaBody =>
      'Build outfits like it from your own closet.';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get errorNoConnection =>
      'No internet connection. Please check your network.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorServerError =>
      'Something went wrong on our end. Please try again.';

  @override
  String get errorBadGateway =>
      'Our server is briefly unavailable. Please try again.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Please try again shortly.';

  @override
  String get errorInternalError => 'Something went wrong. Please try again.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorForbidden => 'You do not have access to that.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get errorInvalidCredentials =>
      'That email or password is not correct.';

  @override
  String get errorTokenRefreshFailed =>
      'We could not refresh your session. Please sign in again.';

  @override
  String get errorRequestCancelled => 'Request cancelled.';

  @override
  String get errorInvalidFormat => 'That file format is not supported.';

  @override
  String get errorFileTooLarge => 'That file is too large.';

  @override
  String get errorUploadFailed => 'The upload failed. Please try again.';

  @override
  String get errorCacheCorrupted =>
      'Saved data was damaged and has been reset.';

  @override
  String get errorCacheNotFound => 'Nothing was saved yet.';

  @override
  String get errorUserNotFound => 'We could not find that account.';

  @override
  String get errorItemNotFound => 'That item no longer exists.';

  @override
  String get errorOutfitNotFound => 'That outfit no longer exists.';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsNoAchievementsTitle => 'No achievements yet';

  @override
  String get rewardsNoAchievementsBody =>
      'Add pieces and plan outfits to earn your first.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'No one on the board yet';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plan outfits to earn points and show up here.';

  @override
  String get legalViewPrivacyPolicy => 'View Privacy Policy';

  @override
  String get aiConsentAgree => 'I Agree & Continue';

  @override
  String get aiConsentNotNow => 'Not Now';

  @override
  String get imageViewerCloseTooltip => 'Close image viewer';

  @override
  String get updateReadyTitle => 'Update ready';

  @override
  String get updateReadyBody =>
      'Restart FitCheck AI to apply the latest improvements.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI needs camera access to take photos of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI needs photo library access to select images of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI needs to save your AI-generated outfit photos to your photo library.';

  @override
  String get wardrobeSomePhotosSkipped => 'Some photos skipped';

  @override
  String get wardrobePhotosNotAdded => 'Photos not added';

  @override
  String get wardrobePhotoNotAdded => 'Photo not added';

  @override
  String get wardrobeNotStartedTitle => 'Not started';

  @override
  String get wardrobeNoRoomTitle => 'No room';

  @override
  String get wardrobeAddPhotosSemantic => 'Add photos';

  @override
  String get batchAddTileLabel => 'Add';

  @override
  String get batchProfileLinkLabel => 'Profile link';

  @override
  String get wardrobeImportFromProfileTitle => 'Import from a profile';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Add several photos';

  @override
  String get wardrobeClearAction => 'Clear';

  @override
  String get wardrobeRefreshTooltip => 'Refresh';

  @override
  String get batchNoPhotosYetTitle => 'No photos yet';

  @override
  String get batchChoosePhotosAction => 'Choose photos';

  @override
  String get batchWeFindEachPieceBody =>
      'We find each piece and make a studio photo of it.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparing photos';

  @override
  String get batchPhotosProcessedSemantic => 'Photos processed';

  @override
  String get batchPasteProfileLinkTitle => 'Paste a profile link';

  @override
  String get batchPasteProfileLinkBody =>
      'A public Instagram or Facebook profile. We scan its photos, and you choose what goes in your closet.';

  @override
  String get batchClearLinkTooltip => 'Clear link';

  @override
  String get batchStartingButton => 'Starting';

  @override
  String get batchStartImportAction => 'Start import';

  @override
  String get batchReviewEveryPhotoTitle => 'You review every photo';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nothing is added until you approve it.';

  @override
  String get batchPrivateProfilesTitle => 'Private profiles';

  @override
  String get batchPrivateProfilesBody =>
      'Connect your account. Instagram also takes a username and password.';

  @override
  String get batchUseAnotherLinkAction => 'Use another link';

  @override
  String get batchSignInNeededTitle => 'Sign-in needed';

  @override
  String get batchEnterYourCodeTitle => 'Enter your code';

  @override
  String get batchUseUsernamePasswordAction => 'Use username and password';

  @override
  String get batchAlreadyConnectedAction =>
      'I already connected in the browser';

  @override
  String get batchEnterCodeAction => 'Enter code';

  @override
  String get batchTryAnotherWayAction => 'Try another way';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Reconnecting';

  @override
  String get batchSignInToInstagramTitle => 'Sign in to Instagram';

  @override
  String get batchUsernameLabel => 'Username';

  @override
  String get batchCodeIfTwoStepLabel => 'Code, if you use two-step sign-in';

  @override
  String get batchAuthenticatorCodeBody =>
      'Use the 6-digit code from your authenticator app. Codes change quickly.';

  @override
  String get batchVerifyAction => 'Verify';

  @override
  String get batchFindingPhotosTitle => 'Finding photos';

  @override
  String get batchImportPausedTitle => 'Import paused';

  @override
  String get batchProcessingPhotosTitle => 'Processing photos';

  @override
  String get batchWaitingNextPhoto => 'Waiting for the next photo';

  @override
  String get batchCancelImportAction => 'Cancel import';

  @override
  String get batchNoPiecesInPhotoBody => 'No pieces found in this photo.';

  @override
  String get batchEditPieceColoursLabel => 'Colours, separated by commas';

  @override
  String get batchAddToClosetAction => 'Add to closet';

  @override
  String get batchSkipPhotoAction => 'Skip this photo';

  @override
  String get batchImportCompleteTitle => 'Import complete';

  @override
  String get batchImportFailedTitle => 'Import failed';

  @override
  String get batchImportCancelledTitle => 'Import cancelled';

  @override
  String get batchImportErrorBody => 'Something went wrong while importing.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nothing more is imported from this profile.';

  @override
  String get batchViewClosetAction => 'View closet';

  @override
  String get batchStartOverAction => 'Start over';

  @override
  String get wardrobeAddPieceTitle => 'Add a piece';

  @override
  String get wardrobeAddDetailsTitle => 'Add details';

  @override
  String get wardrobeScanningTitle => 'Scanning';

  @override
  String get batchReviewPiecesTitle => 'Review pieces';

  @override
  String get wardrobeGalleryAction => 'Gallery';

  @override
  String get wardrobeCameraAction => 'Camera';

  @override
  String get wardrobeNewBadge => 'New';

  @override
  String get wardrobeRemovePhotoTooltip => 'Remove photo';

  @override
  String get batchRunInBackgroundTooltip => 'Run in background';

  @override
  String get batchStepOneOfTwo => 'Step 1 of 2';

  @override
  String get batchStepTwoOfTwo => 'Step 2 of 2';

  @override
  String get batchUploadingPhotosTitle => 'Uploading photos';

  @override
  String get batchFindingPiecesTitle => 'Finding pieces';

  @override
  String get batchMakingStudioPhotosTitle => 'Making studio photos';

  @override
  String get batchStoppedLabel => 'Stopped';

  @override
  String get batchFindingPiecesStoppedTitle => 'Finding pieces stopped';

  @override
  String get batchCancelledLabel => 'Cancelled';

  @override
  String get batchAllDoneTitle => 'All done';

  @override
  String get batchOpeningPiecesBody => 'Opening your pieces';

  @override
  String get batchNothingSavedBody => 'Nothing was saved.';

  @override
  String get batchFindingPiecesFailedBody => 'Finding pieces failed.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Finding pieces stopped early.';

  @override
  String get batchStopFindingPiecesTitle => 'Stop finding pieces?';

  @override
  String get batchStopFindingPiecesBody =>
      'The scan stops and nothing is saved. Pieces already found stay in your activity until you dismiss them.';

  @override
  String get batchKeepGoingAction => 'Keep going';

  @override
  String get batchTryAgainAction => 'Try again';

  @override
  String get batchBackToPhotosAction => 'Back to photos';

  @override
  String get batchSkipAllAction => 'Skip all';

  @override
  String get batchIncludeAllAction => 'Include all';

  @override
  String get batchNoPiecesFoundTitle => 'No pieces found';

  @override
  String get batchNoPiecesFoundBody => 'We found no clothes in these photos.';

  @override
  String get batchChooseOtherPhotosAction => 'Choose other photos';

  @override
  String get batchUseCaseHelper => 'Added to every piece you save.';

  @override
  String get batchDiscardPiecesTitle => 'Discard these pieces?';

  @override
  String get batchDiscardPiecesBody => 'Nothing from this batch is saved.';

  @override
  String get batchKeepAction => 'Keep';

  @override
  String get batchDiscardAction => 'Discard';

  @override
  String get batchRemovePieceTitle => 'Remove this piece?';

  @override
  String get batchRemovePieceBody => 'It is not saved to your closet.';

  @override
  String get batchRemoveAction => 'Remove';

  @override
  String get batchChoosePiecesToSave => 'Choose pieces to save';

  @override
  String get batchDiscardAllAction => 'Discard all';

  @override
  String get batchNothingSavedRetryBody => 'Nothing was saved. Try again.';

  @override
  String get batchNotSavedTitle => 'Not saved';

  @override
  String get batchSavingLabel => 'Saving';

  @override
  String get batchSendToBackgroundAction => 'Send to background';

  @override
  String get batchStillWorkingMessage =>
      'Still working. We will let you know when your pieces are ready.';

  @override
  String get batchRunningInBackgroundTitle => 'Running in background';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studio photos stopped early. You can still save these pieces.';

  @override
  String get batchTapPieceToSkip => 'Tap a piece to skip it.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studio photos still on their way. You can leave — we will let you know.';

  @override
  String get batchLeaveAction => 'Leave';

  @override
  String get batchPeopleInPhotosTitle => 'People in the photos';

  @override
  String get batchIncludeAction => 'Include';

  @override
  String get batchSkipAction => 'Skip';

  @override
  String get batchYourPhotoIsUsedLabel => 'Your photo is used';

  @override
  String get batchMakingStudioPhotoLabel => 'Making studio photo';

  @override
  String get batchNoStudioPhotoBody => 'No studio photo. Your photo is used.';

  @override
  String get batchEnterDetailsYourselfAction => 'Enter details yourself';

  @override
  String get batchChooseAnotherPhotoAction => 'Choose another photo';

  @override
  String get batchConnectionLostTitle => 'Connection lost';

  @override
  String get batchConnectionLostBody =>
      'Check your connection, then try again.';

  @override
  String get batchDailyLimitTitle => 'Daily limit reached';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Upgrade to Pro for more scans, or enter the details yourself.';

  @override
  String get batchDailyLimitBodyFree =>
      'Your scans reset tomorrow. You can enter the details yourself now.';

  @override
  String get batchSeePlansAction => 'See plans';

  @override
  String get batchAiBusyTitle => 'Our AI is busy';

  @override
  String get batchAiBusyBody =>
      'This is on our side. Try again in a few minutes.';

  @override
  String get batchNoPiecesBody =>
      'Try a clearer photo, or enter the details yourself.';

  @override
  String get batchScanningUnavailableTitle => 'Scanning is unavailable';

  @override
  String get batchScanningUnavailableBody =>
      'Enter the details yourself for now.';

  @override
  String get batchScanDidNotFinishTitle => 'The scan did not finish';

  @override
  String get batchTryAgainBody => 'Try again.';

  @override
  String get billingTitle => 'Subscription';

  @override
  String get billingUpgradeHeading => 'Upgrade your plan';

  @override
  String get billingUpgradeOnPlusBody => 'Same features, higher limits.';

  @override
  String get billingUpgradeBody =>
      'Plus and Pro have the same features. Pick the limits you need.';

  @override
  String get billingWebUnavailableBody =>
      'Online upgrades aren\'t available yet. A promo or referral code still unlocks Plus or Pro. Invite friends below to earn free months.';

  @override
  String get billingPlansStale =>
      'Couldn\'t load the latest plans. Prices may be out of date.';

  @override
  String get billingMonthly => 'Monthly';

  @override
  String get billingYearly => 'Yearly';

  @override
  String get billingCurrentPlan => 'Current plan';

  @override
  String get billingActive => 'Active';

  @override
  String get billingThisMonth => 'This month';

  @override
  String get billingItemExtractions => 'Item extractions';

  @override
  String get billingOutfitVisualizations => 'Outfit visualizations';

  @override
  String get billingNearLimitUpgrade =>
      'You\'re close to this month\'s limit. Upgrade for more.';

  @override
  String get billingNearLimitResets =>
      'You\'re close to this month\'s limit. It resets at the start of next month.';

  @override
  String get billingStoreUnavailable =>
      'Upgrades aren\'t available in the store yet. Check back soon.';

  @override
  String get billingManageHeading => 'Manage your plan';

  @override
  String get billingCancelPlan => 'Cancel subscription';

  @override
  String get billingCancelKeepsAccess =>
      'You keep access until the end of this billing period.';

  @override
  String get billingCancelConfirmTitle => 'Cancel your subscription?';

  @override
  String get billingKeepPlan => 'Keep plan';

  @override
  String get billingCancelPlanAction => 'Cancel plan';

  @override
  String get billingBilledMonthly => 'Billed monthly';

  @override
  String get billingBilledYearly => 'Billed yearly';

  @override
  String get billingVirtualTryOn => 'Virtual try-on';

  @override
  String get billingPrioritySupport => 'Priority support';

  @override
  String get billingDisclosureProRenewing =>
      'Pro is an auto-renewing subscription';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus and Pro are auto-renewing subscriptions';

  @override
  String get billingDisclosureAppleBilling =>
      'Payment is charged to your Apple ID at confirmation of purchase.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Payment is charged to your Google Play account at confirmation of purchase.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Your subscription renews automatically for the same period at the same price unless you turn off auto-renew at least 24 hours before the current period ends.';

  @override
  String get billingDisclosureAppleManage =>
      'Manage or cancel any time in Settings › your Apple ID › Subscriptions.';

  @override
  String get billingDisclosureGoogleManage =>
      'Manage or cancel any time in Google Play › Payments and subscriptions.';

  @override
  String get billingReferFriend => 'Refer a friend';

  @override
  String get billingHowItWorks => 'How it works';

  @override
  String get billingHowShareTitle => 'Share your link';

  @override
  String get billingHowShareBody => 'Send it to a friend.';

  @override
  String get billingHowSignUpTitle => 'They sign up';

  @override
  String get billingHowSignUpBody => 'Your friend joins from the link.';

  @override
  String get billingHowBothTitle => 'You both get Pro';

  @override
  String get billingHowBothBody => 'Each of you gets a month of Pro free.';

  @override
  String get billingYourReferrals => 'Your referrals';

  @override
  String get billingInvited => 'Invited';

  @override
  String get billingJoined => 'Joined';

  @override
  String get billingMonthsEarned => 'Months earned';

  @override
  String get billingInviteFriend => 'Invite a friend';

  @override
  String get billingInviteBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get billingYourCode => 'Your code';

  @override
  String get billingCopyLink => 'Copy link';

  @override
  String get billingShareInvite => 'Share invite';

  @override
  String get giftUnavailable =>
      'Gift invitations are not available in this build.';

  @override
  String get giftPageTitle => 'Gift FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'No free gift invitations are available right now.';

  @override
  String get giftFormTitle => 'Send a free invitation';

  @override
  String get giftFormBody =>
      'Your recipient claims the gift with this verified email. We don\'t send the email for you.';

  @override
  String get giftFieldFrom => 'From';

  @override
  String get giftFieldRecipientName => 'Recipient name';

  @override
  String get giftFieldRecipientEmail => 'Recipient email';

  @override
  String get giftFieldOccasion => 'Occasion (optional)';

  @override
  String get giftNoOccasion => 'No occasion';

  @override
  String get giftOccasionBirthday => 'Birthday';

  @override
  String get giftOccasionAnniversary => 'Anniversary';

  @override
  String get giftOccasionOther => 'Other';

  @override
  String get giftFieldCardGreeting => 'Card greeting';

  @override
  String get giftFieldCardGreetingHelper =>
      'This appears on the card exactly as written.';

  @override
  String get giftFieldPrivateNote => 'Private note (optional)';

  @override
  String get giftCreateAction => 'Create free gift';

  @override
  String get giftClaimedTitle => 'Gift claimed';

  @override
  String get giftClaimedActive => 'Your FitCheck Pro gift is active.';

  @override
  String get giftClaimedQueued =>
      'Your FitCheck Pro gift starts after your current access.';

  @override
  String get giftLinkCopied => 'Gift link copied to the clipboard.';

  @override
  String get giftErrorName => 'Enter a name.';

  @override
  String get giftErrorEmail => 'Enter a valid email address.';

  @override
  String get giftErrorGreeting => 'Enter the card greeting.';

  @override
  String get giftErrorGreetingLength => 'Use no more than 80 characters.';

  @override
  String get giftClaimAction => 'Claim gift';

  @override
  String get giftCardPreview => 'Card preview';

  @override
  String get giftGiftForYou => 'A gift for you';

  @override
  String get giftGiftWaiting => 'A gift is waiting for you';

  @override
  String get giftOpenBody =>
      'Open your gifts to claim them with your verified email.';

  @override
  String get giftOpenGifts => 'Open gifts';

  @override
  String get giftSendInvitation => 'Send invitation';

  @override
  String get settingsAiProviderSection => 'Provider';

  @override
  String get settingsAiCustom => 'Custom';

  @override
  String get settingsAiUrlHelper =>
      'Use a public URL the server can reach. Localhost does not work from our servers.';

  @override
  String get settingsAiConnectionSection => 'Connection';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API key';

  @override
  String get settingsAiApiKeySaved => 'Saved. Leave blank to keep it.';

  @override
  String get settingsAiChatModel => 'Chat model';

  @override
  String get settingsAiVisionModel => 'Vision model (optional)';

  @override
  String get settingsAiImageModel => 'Image model (optional)';

  @override
  String get settingsAiImageModelNote =>
      'Image generation needs OpenAI-compatible chat completions with response_modalities.';

  @override
  String get settingsAiTestConnection => 'Test connection';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarGoToToday => 'Go to today';

  @override
  String get calendarConnectTooltip => 'Connect a calendar';

  @override
  String get calendarAddEvent => 'Add event';

  @override
  String get calendarEmptyTitle => 'Nothing planned';

  @override
  String get calendarEmptyBody => 'Add an event and plan what to wear.';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarAllDay => 'All day';

  @override
  String get calendarOutfitLinked => 'Outfit linked';

  @override
  String get calendarEventOptions => 'Event options';

  @override
  String get calendarDeleteTitle => 'Delete this event?';

  @override
  String get calendarChangeOutfit => 'Change outfit';

  @override
  String get calendarLinkOutfit => 'Link an outfit';

  @override
  String get calendarRemoveOutfit => 'Remove outfit';

  @override
  String get calendarNewEvent => 'New event';

  @override
  String get calendarEditEvent => 'Edit event';

  @override
  String get calendarTitleLabel => 'Title';

  @override
  String get calendarTitleRequired => 'Add a title';

  @override
  String get calendarEndBeforeStart => 'End after the start time';

  @override
  String get calendarStarts => 'Starts';

  @override
  String get calendarEnds => 'Ends';

  @override
  String get calendarPlaceOptional => 'Place (optional)';

  @override
  String get calendarNotesOptional => 'Notes (optional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Build an outfit, then link it to this event.';

  @override
  String get calendarBuildOutfit => 'Build an outfit';

  @override
  String get calendarConnectionsTitle => 'Calendars';

  @override
  String get calendarConnectionsBody => 'Events you add here stay in FitCheck.';

  @override
  String get calendarDisconnect => 'Disconnect';

  @override
  String get calendarNotAvailable => 'Not available yet';

  @override
  String get profileSectionExplore => 'Explore';

  @override
  String get profileNavTryOn => 'Try-on';

  @override
  String get profileNavRewards => 'Rewards';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutBody => 'Your closet, outfits and plans in one place.';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody => 'You can sign back in at any time.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileYourProfile => 'Your profile';

  @override
  String get profileBodyProfiles => 'Body profiles';

  @override
  String get profileBodyEmptyTitle => 'No body profiles yet';

  @override
  String get profileBodyEmptyBody =>
      'Add your height and build to get a better fit.';

  @override
  String get profileBodyAdd => 'Add a profile';

  @override
  String get profileBodyDefaultNote =>
      'Your default profile is used for fit and try-on.';

  @override
  String get profileBodyDefaultBadge => 'Default';

  @override
  String get profileBodyMakeDefault => 'Make default';

  @override
  String get profileBodyDeleteBody => 'You cannot undo this.';

  @override
  String get profileBodyRequired => 'Required';

  @override
  String get profileBodyCheckNumber => 'Check this number';

  @override
  String get profileBodyNew => 'New body profile';

  @override
  String get profileBodyNameHint => 'For example, Me';

  @override
  String get profileBodyHeight => 'Height';

  @override
  String get profileBodyWeight => 'Weight';

  @override
  String get profileBodyBuild => 'Build';

  @override
  String get profileBodySkinTone => 'Skin tone';

  @override
  String get profileBirthDateNeededBody =>
      'Add a date of birth to go with the birth time.';

  @override
  String get profileBirthDateNeededTitle => 'Date of birth needed';

  @override
  String get profilePartlySavedBody =>
      'We saved your name and photo. Birth details did not save; try again later.';

  @override
  String get profilePartlySavedTitle => 'Partly saved';

  @override
  String get profileSavedBody => 'Your profile is saved.';

  @override
  String get profileChangePhoto => 'Change profile photo';

  @override
  String get profilePhotoLabel => 'Profile photo';

  @override
  String get profilePhotoHint => 'Tap to choose a new one';

  @override
  String get profileBirthDateLabel => 'Date of birth (optional)';

  @override
  String get profileBirthTimeLabel => 'Birth time (optional)';

  @override
  String get profileBirthTimeHelper => 'Makes Vedic suggestions more exact';

  @override
  String get profileBirthPlaceLabel => 'Birth place (optional)';

  @override
  String get profileBirthPlaceHint => 'For example, New Delhi, India';

  @override
  String get profileHelpContactTitle => 'Ask us anything';

  @override
  String get profileHelpContactBody =>
      'Send a message and we reply by email, usually within a day.';

  @override
  String get profileHelpContactAction => 'Contact support';

  @override
  String get profileHelpFaqTitle => 'Common questions';

  @override
  String get profileFaqAddPiecesTitle => 'How do I add pieces to my closet?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tap Add item on the Closet tab. Take a photo or pick one from your gallery; we find each piece and tag it for you.';

  @override
  String get profileFaqMatchingTitle => 'How does outfit matching work?';

  @override
  String get profileFaqMatchingBody =>
      'Open For you and pick pieces you own. We suggest what goes with them and build full outfits from your closet.';

  @override
  String get profileFaqTryOnTitle => 'Can I use my own photos for try-on?';

  @override
  String get profileFaqTryOnBody =>
      'Yes. Add a full-length photo of yourself, then choose pieces to see them on you.';

  @override
  String get profileFaqRewardsTitle => 'How do I earn rewards?';

  @override
  String get profileFaqRewardsBody =>
      'Plan and log outfits often. Streaks and achievements build as you go.';

  @override
  String get profileFaqPrivacyTitle => 'Is my closet private?';

  @override
  String get profileFaqPrivacyBody =>
      'Yes. Your closet and outfits are private unless you share a link to one outfit.';

  @override
  String get profileHelpMoreTitle => 'More help';

  @override
  String get profileHelpGuides => 'Guides';

  @override
  String get profileHelpGuidesBody => 'How each feature works';

  @override
  String get feedbackCategoryBug => 'Something broke';

  @override
  String get feedbackCategoryIdea => 'An idea';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'I need help';

  @override
  String get feedbackHintBug =>
      'What happened, and what did you expect? Steps help us fix it.';

  @override
  String get feedbackHintIdea => 'What would you like, and why?';

  @override
  String get feedbackHintGeneral =>
      'Tell us what you think, or ask a question.';

  @override
  String get feedbackAttachmentLimitBody => 'You can add up to 5 images.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limit reached';

  @override
  String get feedbackImageTooLargeBody => 'Choose an image under 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Image too large';

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackAboutLabel => 'What is it about?';

  @override
  String get feedbackSubjectLabel => 'Subject';

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
  String get authSignedIn => 'Signed in';

  @override
  String get authWelcomeBackTitle => 'Welcome back';

  @override
  String get authSignInFailed => 'Sign-in failed';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String get authSignUpFailed => 'Sign-up failed';

  @override
  String get authGoogleSignInFailed => 'Google sign-in failed';

  @override
  String get authAppleSignInFailed => 'Apple sign-in failed';

  @override
  String get authConfirmEmailTitle => 'Confirm your email';

  @override
  String get authConfirmEmailBody =>
      'Check your inbox for a confirmation email, then sign in.';

  @override
  String get authClosetReady => 'Your closet is ready.';

  @override
  String get authSignedOutTitle => 'Signed out';

  @override
  String get authSignedOutBody => 'You are signed out.';

  @override
  String get authSignOutFailed => 'Sign-out failed';

  @override
  String get authEmailSentTitle => 'Email sent';

  @override
  String get authResetLinkSent => 'Check your email for a reset link.';

  @override
  String get authPasswordUpdatedTitle => 'Password updated';

  @override
  String get authPasswordUpdated => 'Your password is updated.';

  @override
  String get authPasswordNotUpdated => 'Password not updated';

  @override
  String get authCouldNotSendEmail => 'Could not send the email';

  @override
  String get authEmailNotSent => 'Email not sent';

  @override
  String get authResendSentBody => 'We sent a new confirmation email.';

  @override
  String get outfitPreviewWithAi => 'Preview with AI';

  @override
  String get outfitNewPreview => 'Make a new preview';

  @override
  String get outfitBuilderClosetHeading => 'Your closet';

  @override
  String get outfitBuilderSearchHint => 'Search pieces';

  @override
  String get outfitClearSearch => 'Clear search';

  @override
  String get outfitBuilderAddPiecesTitle => 'Add pieces first';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits are made from the pieces in your closet.';

  @override
  String get outfitBuilderNoMatches => 'No pieces match.';

  @override
  String get outfitNameLabel => 'Outfit name';

  @override
  String get outfitNameHint => 'For example, Weekend linen';

  @override
  String get outfitPreviewSemantic => 'AI preview of the outfit';

  @override
  String get outfitChoosePieces => 'Choose pieces';

  @override
  String get outfitTapPiecesHint => 'Tap pieces below to add them.';

  @override
  String get outfitShareTooltip => 'Share';

  @override
  String get outfitSaveFavourite => 'Save to favourites';

  @override
  String get outfitPiecesHeading => 'Pieces';

  @override
  String get outfitWearHistoryEmpty =>
      'Wear it once and the dates show up here.';

  @override
  String get outfitWearHistoryTitle => 'Wear history';

  @override
  String get outfitWearHistoryError => 'Couldn\'t load the dates.';

  @override
  String get outfitWornOn => 'Worn on';

  @override
  String get outfitEditTitle => 'Edit outfit';

  @override
  String get outfitSavedPhotosFailed => 'Details saved, photos not';

  @override
  String get outfitNoPhotosBody =>
      'No photos yet. The outfit shows its pieces instead.';

  @override
  String get outfitOccasionLabel => 'Occasion';

  @override
  String get outfitOccasionNone => 'None';

  @override
  String get outfitTagsHint => 'Separate with commas';

  @override
  String get outfitDraftBody => 'Hidden from your main list';

  @override
  String get outfitPublic => 'Public';

  @override
  String get outfitPublicBody => 'Anyone with the link can see it';

  @override
  String get outfitDeleteFromDetail =>
      'Delete this outfit from its detail page.';

  @override
  String get outfitNewCollection => 'New collection';

  @override
  String get outfitNoCollectionsTitle => 'No collections yet';

  @override
  String get outfitNoCollectionsBody =>
      'Group outfits by trip, season or mood.';

  @override
  String get outfitCreateCollection => 'Create a collection';

  @override
  String get outfitAddOutfits => 'Add outfits';

  @override
  String get outfitRename => 'Rename';

  @override
  String get outfitCollectionDeleteBody => 'The outfits in it are kept.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfits not loaded';

  @override
  String get outfitRenameCollection => 'Rename collection';

  @override
  String get outfitDescriptionOptional => 'Description (optional)';

  @override
  String get outfitAllInCollection =>
      'Every outfit is already in this collection.';

  @override
  String get photoshootSubtitleUpload =>
      'Studio portraits from your own photos';

  @override
  String get photoshootSubtitleConfigure =>
      'Pick a style, a format and a count';

  @override
  String get photoshootSubtitleGenerating => 'This takes a minute or two';

  @override
  String get photoshootAddPhotosSemantic => 'Add photos from your gallery';

  @override
  String get photoshootUploadTitle => 'Add 1 to 4 photos of yourself';

  @override
  String get photoshootUploadBody => 'Tap to choose from your gallery';

  @override
  String get photoshootAddToContinue => 'Add a photo to continue';

  @override
  String get photoshootAddAnotherPhoto => 'Add another photo';

  @override
  String get photoshootTipsTitle => 'For the best results';

  @override
  String get photoshootTipsBody =>
      'Use clear, well-lit photos of your face from a few angles. Skip sunglasses and hats.';

  @override
  String get photoshootStarting => 'Starting';

  @override
  String get photoshootCancelling => 'Cancelling';

  @override
  String get photoshootFailed => 'Failed';

  @override
  String get recommendTabMatches => 'Matches';

  @override
  String get recommendTabComplete => 'Complete';

  @override
  String get recommendTabWeather => 'Weather';

  @override
  String get recommendTabColours => 'Colours';

  @override
  String get recommendTabShop => 'Shop';

  @override
  String get recommendNoMatchesTitle => 'No matches yet';

  @override
  String get recommendNoMatchesBody =>
      'Pick a piece and we\'ll find what goes with it.';

  @override
  String get recommendPickPiece => 'Pick a piece';

  @override
  String get recommendNothingMatchesTitle => 'Nothing matches these yet';

  @override
  String get recommendNothingMatchesBody =>
      'Try other pieces, or add more to your closet.';

  @override
  String get recommendChangePieces => 'Change pieces';

  @override
  String get recommendDefaultReason => 'It suits the pieces you picked.';

  @override
  String get recommendCompleteTitle => 'Complete a look';

  @override
  String get recommendCompleteBody =>
      'Pick a piece and we\'ll fill in the rest.';

  @override
  String get recommendWorking => 'Working';

  @override
  String get recommendGenerate => 'Generate';

  @override
  String get recommendChooseStyleBody => 'Choose a style, then generate.';

  @override
  String get recommendNoLooksTitle => 'No looks for these pieces';

  @override
  String get recommendNoLooksBody => 'Try another style or other pieces.';

  @override
  String get recommendDefaultLook => 'A look for your pieces';

  @override
  String get recommendNoPiecesBody => 'No pieces came back for this look.';

  @override
  String get recommendCityLabel => 'City';

  @override
  String get recommendCheck => 'Check';

  @override
  String get recommendWeatherTitle => 'What\'s the weather?';

  @override
  String get recommendWeatherBody => 'Enter your city to get picks for today.';

  @override
  String get recommendWearToday => 'Wear today';

  @override
  String get recommendWeatherNoPieces =>
      'No pieces in your closet for this weather yet.';

  @override
  String get recommendBudgetLabel => 'Budget up to';

  @override
  String get recommendLooking => 'Looking';

  @override
  String get recommendFindWhatToBuy => 'Find what to buy';

  @override
  String get recommendFillGapsTitle => 'Fill the gaps';

  @override
  String get recommendFillGapsBody =>
      'Set a budget and we\'ll suggest what your closet is missing.';

  @override
  String get recommendNoGapsTitle => 'No gaps found';

  @override
  String get recommendNoGapsBody => 'Try a bigger budget or another category.';

  @override
  String get recommendMoodEveryday => 'Everyday';

  @override
  String get recommendMoodBigMeeting => 'Big meeting';

  @override
  String get recommendDayLabel => 'Day';

  @override
  String get recommendReadingStars => 'Reading the stars';

  @override
  String get recommendGetMyColours => 'Get my colours';

  @override
  String get recommendLuckyColoursTitle => 'Your lucky colours';

  @override
  String get recommendLuckyColoursBody =>
      'Pick a day and we\'ll suggest colours and pieces for it.';

  @override
  String get recommendLuckyColoursSection => 'Lucky colours';

  @override
  String get recommendAvoidColoursSection => 'Colours to go easy on';

  @override
  String get recommendBirthDateTitle => 'Add your birth date';

  @override
  String get recommendBirthDateBody =>
      'We need your date of birth to read your colours.';

  @override
  String get recommendEditProfile => 'Edit profile';

  @override
  String get recommendNothingThisDay => 'Nothing for this day.';

  @override
  String get recommendUnnamedColour => 'Unnamed colour';

  @override
  String get recommendFromCloset => 'From your closet';

  @override
  String get recommendNoPiecesInColours => 'No pieces in these colours yet.';

  @override
  String get recommendOutfitIdeas => 'Outfit ideas';

  @override
  String get recommendNoOutfitsInColours =>
      'No full outfit in these colours yet.';

  @override
  String get recommendDefaultOutfitIdea => 'An outfit idea';

  @override
  String get recommendPickUpToThree => 'Pick up to three pieces';

  @override
  String get recommendEmptyClosetBody =>
      'Add a few pieces first, then come back for matches.';

  @override
  String get dashboardDressForDay => 'Dress for the day ahead.';

  @override
  String get dashboardOutfitOfDay => 'Outfit of the day';

  @override
  String get dashboardFreshLook => 'A fresh look';

  @override
  String get subscriptionManageInStoreTitle => 'Manage in the store';

  @override
  String get subscriptionManageInStoreBody =>
      'This plan is billed through the store. Manage it in your store account settings.';

  @override
  String get subscriptionCancelledTitle => 'Subscription cancelled';

  @override
  String get subscriptionCancelledBody =>
      'Your plan stays active until the end of this billing period.';

  @override
  String get subscriptionCancelFailedTitle => 'Could not cancel';

  @override
  String get subscriptionCouldNotOpenTitle => 'Could not open';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Could not open billing management.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Could not open the link.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Could not load your link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Could not load your referral link. Try again.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copied';

  @override
  String get subscriptionReferralCopiedBody => 'Referral link copied.';

  @override
  String get subscriptionReferralShareSubject => 'Try FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Join FitCheck AI and we both get a month of Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copied';

  @override
  String get subscriptionShareUnavailableBody =>
      'Sharing is not available, so we copied the link.';

  @override
  String get subscriptionShareFailedTitle => 'Could not share';

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
  String get giftClaimFailedTitle => 'Could not claim the gift';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gifts for you',
      one: 'A gift for you',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 month',
      '12': '1 year',
      'other': '$months months',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining left',
      one: '1 left',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration of FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender sent you $duration of FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'A FitCheck Pro gift for $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'From $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'For $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'From $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'your recipient';

  @override
  String get giftPreviewPlaceholderSender => 'you';

  @override
  String get settingsSavedTitle => 'Saved';

  @override
  String get settingsNotSavedTitle => 'Not saved';

  @override
  String get settingsAiChooseProviderBody => 'Choose a provider.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'A custom provider needs an API URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Enter an API key.';

  @override
  String get settingsAiSavedBody => 'Your AI settings are saved.';

  @override
  String get settingsAiMissingDetailsTitle => 'Missing details';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Enter an API URL and a chat model to test.';

  @override
  String get settingsAiKeyNeededTitle => 'API key needed';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Enter your API key to test. Your saved key stays private.';

  @override
  String get settingsAiKeyToTestBody => 'Enter your API key to test.';

  @override
  String get settingsAiConnectedTitle => 'Connected';

  @override
  String get settingsAiConnectedBody => 'The connection works.';

  @override
  String get settingsAiTestFailedTitle => 'Test failed';

  @override
  String get settingsPreferencesSavedBody => 'Your preferences are saved.';

  @override
  String get settingsPasswordNotChangedTitle => 'Password not changed';

  @override
  String get settingsOAuthPasswordBody =>
      'This account signs in with Google or Apple. Use \"Forgot password\" to set a password first.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Current password is incorrect.';

  @override
  String get settingsExportReadyTitle => 'Export ready';

  @override
  String get settingsExportReadyBody =>
      'Your data export is ready to download.';

  @override
  String get settingsLinkCopiedTitle => 'Link copied';

  @override
  String get settingsExportClipboardBody =>
      'We could not open your browser, so we copied the download link. Paste it into a browser soon: it expires.';

  @override
  String get settingsExportFailedTitle => 'Export failed';

  @override
  String get settingsAccountNotDeletedTitle => 'Account not deleted';

  @override
  String photoshootPhotoLimit(int max) {
    return 'You can add up to $max photos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Photo limit';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Add at least one photo.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'No photos';

  @override
  String get photoshootDescribeLookBody => 'Describe the look you want.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt needed';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Preparing your photos';

  @override
  String get photoshootStatusGenerating => 'Generating';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current of $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generation failed.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready ready, $failed failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Partly done';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos are ready.',
      one: '1 photo is ready.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'We lost the connection. Please try again.';

  @override
  String get photoshootCouldNotCancelTitle => 'Could not cancel';

  @override
  String get photoshootRetryFailedTitle => 'Retry failed';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Photo $number is ready.';
  }

  @override
  String get photoshootReplacedTitle => 'Replaced';

  @override
  String get photoshootSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get photoshootSavedTitle => 'Saved';

  @override
  String get photoshootNotSavedTitle => 'Not saved';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count photos are in your gallery.',
      one: '1 photo is in your gallery.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved of $total saved.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Some photos not saved';

  @override
  String get tryonConsentFeatureLabel => 'Virtual Try-On';

  @override
  String get tryonAvatarUpdatedBody => 'Your photo is updated.';

  @override
  String get tryonSavedTitle => 'Saved';

  @override
  String get tryonUploadFailedTitle => 'Upload failed';

  @override
  String get tryonChooseGarmentFirstBody => 'Choose a garment photo first.';

  @override
  String get tryonNoGarmentTitle => 'No garment';

  @override
  String get tryonWaitForUploadBody =>
      'Wait for your photo to finish uploading.';

  @override
  String get tryonStillUploadingTitle => 'Still uploading';

  @override
  String get tryonAddYourPhotoFirstBody => 'Add a photo of yourself first.';

  @override
  String get tryonReadyBody => 'Your try-on is ready.';

  @override
  String get tryonFailedTitle => 'Try-on failed';

  @override
  String get tryonSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get tryonNotSavedTitle => 'Not saved';

  @override
  String get calendarEventAddedBody => 'Event added';

  @override
  String get calendarEventPlannedTitle => 'Planned';

  @override
  String get calendarEventSavedBody => 'Event saved';

  @override
  String get calendarSavedTitle => 'Saved';

  @override
  String get calendarEventNotSavedTitle => 'Event not saved';

  @override
  String get calendarEventRemovedBody => 'Event removed';

  @override
  String get calendarEventDeletedTitle => 'Deleted';

  @override
  String get calendarEventNotDeletedTitle => 'Event not deleted';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit not linked';

  @override
  String get calendarLinkedTitle => 'Linked';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit not removed';

  @override
  String get calendarOutfitRemovedBody => 'Outfit removed';

  @override
  String get calendarDisconnectedBody => 'Calendar disconnected';

  @override
  String get calendarDisconnectedTitle => 'Disconnected';

  @override
  String get calendarNotDisconnectedTitle => 'Calendar not disconnected';

  @override
  String get calendarTodayLabel => 'today';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit linked';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" will be removed.';
  }

  @override
  String get calendarThisAppLabel => 'This app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Syncing with $provider is not available yet. You can still add events here.';
  }

  @override
  String get calendarWeekdaySunShort => 'Sun';

  @override
  String get calendarWeekdayMonShort => 'Mon';

  @override
  String get calendarWeekdayTueShort => 'Tue';

  @override
  String get calendarWeekdayWedShort => 'Wed';

  @override
  String get calendarWeekdayThuShort => 'Thu';

  @override
  String get calendarWeekdayFriShort => 'Fri';

  @override
  String get calendarWeekdaySatShort => 'Sat';

  @override
  String get calendarWeekdayMonday => 'Monday';

  @override
  String get calendarWeekdayTuesday => 'Tuesday';

  @override
  String get calendarWeekdayWednesday => 'Wednesday';

  @override
  String get calendarWeekdayThursday => 'Thursday';

  @override
  String get calendarWeekdayFriday => 'Friday';

  @override
  String get calendarWeekdaySaturday => 'Saturday';

  @override
  String get calendarWeekdaySunday => 'Sunday';

  @override
  String get outfitSavedToFavouritesBody => 'Saved to favourites';

  @override
  String get outfitRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get outfitNotSavedTitle => 'Not saved';

  @override
  String get outfitLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get outfitNicePickTitle => 'Nice pick';

  @override
  String get outfitRemovedBody => 'Outfit removed.';

  @override
  String get outfitDeletedTitle => 'Deleted';

  @override
  String get outfitNotDeletedTitle => 'Not deleted';

  @override
  String get outfitDuplicatedBody => 'A copy is in your outfits.';

  @override
  String get outfitDuplicatedTitle => 'Duplicated';

  @override
  String get outfitNotDuplicatedTitle => 'Not duplicated';

  @override
  String get outfitNotSharedTitle => 'Not shared';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" is ready.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collection not created';

  @override
  String get outfitCollectionUpdatedBody => 'Collection updated.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collection not updated';

  @override
  String get outfitCollectionDeletedBody => 'Collection deleted.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collection not deleted';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits added.',
      one: '1 outfit added.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits not added';

  @override
  String get outfitPreviewNotCreatedTitle => 'Preview not created';

  @override
  String get outfitGiveNameBody => 'Give the outfit a name.';

  @override
  String get outfitNameMissingTitle => 'Name';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Choose at least one piece.';

  @override
  String outfitCreatedBody(String name) {
    return '$name is in your outfits.';
  }

  @override
  String get outfitSavedTitle => 'Saved';

  @override
  String get wardrobeAddedToFavouritesBody => 'Added to favourites';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get wardrobeNotSavedTitle => 'Not saved';

  @override
  String get wardrobeLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Removed from your closet.';

  @override
  String get wardrobeDeletedTitle => 'Deleted';

  @override
  String get wardrobeNotDeletedTitle => 'Not deleted';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces removed from your closet.',
      one: '1 piece removed from your closet.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI Wardrobe Extraction';

  @override
  String get itemAddScanJobLabel => 'Scan';

  @override
  String get itemAddFoundEarlierBody => 'Found in an earlier scan';

  @override
  String get itemAddLookingAtPhoto => 'Looking at your photo';

  @override
  String get itemAddExtractionFailedBody => 'Extraction failed';

  @override
  String get itemAddJobFailedBody => 'Job failed';

  @override
  String get itemAddConnectionLostBody => 'Connection was lost. Try again.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Connection lost while processing.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Piece $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Piece';

  @override
  String get itemAddNotCancelledTitle => 'Not cancelled';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces are in your closet.',
      one: '1 piece is in your closet.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved of $total pieces saved. Tap save to try the rest again.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Some pieces not saved';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Choose at least one photo.';

  @override
  String get batchPhotoUnreadableBody => 'This photo could not be read.';

  @override
  String get batchNoPhotosReadableBody =>
      'None of these photos could be read. Try other photos.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'We lost the connection while working. Try again.';

  @override
  String get batchNotCancelledTitle => 'Not cancelled';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Post links are not supported. Enter a profile link.';

  @override
  String get batchLinkSpacesBody => 'Links cannot contain spaces.';

  @override
  String get batchEnterProfileLinkBody =>
      'Enter an Instagram or Facebook profile link.';

  @override
  String get batchEnterProfileLinkShortBody => 'Enter a profile link.';

  @override
  String get batchSignInPageNotOpenBody =>
      'The sign-in page did not open. Try again.';

  @override
  String get batchSignInBrowserBody =>
      'Sign in in your browser, then come back to FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Connect your account';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Enter the code from your authenticator app.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram wants a security check. Sign in in your browser first.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Enter your username and password again.';

  @override
  String get batchSignInFailedBody =>
      'Sign-in failed. Check your username and password.';

  @override
  String get batchSignInToKeepImportingBody => 'Sign in to keep importing.';

  @override
  String get batchAccountNotConnectedBody => 'Your account was not connected.';

  @override
  String get batchAccountConnectedTitle => 'Account connected';

  @override
  String get batchNotConnectedTitle => 'Not connected';

  @override
  String get batchImportConnectionLostBody =>
      'We lost the connection to the import. Refresh to check it.';

  @override
  String batchPickUpToBody(int max) {
    return 'Pick up to $max photos. We find the pieces.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count of $total photos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparing photo $done of $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Find pieces in $count photos',
      one: 'Find pieces in 1 photo',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Your $platform account uses two-step sign-in. Enter the 6-digit code from your authenticator app.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'This $platform profile is private or needs a sign-in to show its photos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Connect with $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos found so far',
      one: '1 photo found so far',
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
    return '$processed of $total processed · $added added · $waiting waiting · $skipped skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Scanning photo $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Photo $number is next';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Photo $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces found',
      one: '1 piece found',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos were added to your closet.',
      one: '1 photo was added to your closet.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count more studio photos on the way. You can save what is ready, or leave — we will let you know.',
      one:
          '1 more studio photo on the way. You can save what is ready, or leave — we will let you know.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Not saved yet: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces pieces',
      one: '1 piece',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos photos',
      one: '1 photo',
    );
    return '$_temp0 from $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen chosen. Tap a piece to skip it.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saving $count pieces',
      one: 'Saving 1 piece',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count pieces',
      one: 'Save 1 piece',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Your body profile is saved.';

  @override
  String get bodyProfileSavedTitle => 'Saved';

  @override
  String get bodyProfileNotSavedTitle => 'Not saved';

  @override
  String get bodyProfileSetDefaultBody => 'Set as your default profile.';

  @override
  String get bodyProfileDeletedBody => 'Body profile deleted.';

  @override
  String get bodyProfileDeletedTitle => 'Deleted';

  @override
  String get bodyProfileNotDeletedTitle => 'Not deleted';

  @override
  String get feedbackNotSentTitle => 'Not sent';

  @override
  String get feedbackSentBody =>
      'Thanks. We read every message and reply if we need more.';

  @override
  String get feedbackSentTitle => 'Feedback sent';

  @override
  String get recommendUnnamedPiece => 'Unnamed piece';

  @override
  String get recommendEnterCityBody =>
      'Enter your city to get picks for the weather.';

  @override
  String get recommendWhichCityTitle => 'Which city?';

  @override
  String get aiConsentSheetTitle => 'Sharing photos with an AI service';

  @override
  String get aiConsentSheetBody =>
      'To create your try-on and photoshoot images, FitCheck AI sends the photos you provide (including images of your face and body) to a trusted third-party AI provider (such as OpenAI or Google Gemini) for processing. They generate your images and do not use them to train their models under our terms. Photos are transmitted securely and never shared for advertising.';

  @override
  String get aiConsentSheetPermission =>
      'By continuing, you give explicit permission to share your photos with these AI providers for image generation.';

  @override
  String get skeletonsLoadMoreFailed => 'Couldn\'t load more.';

  @override
  String get jobsPiecesReadyTitle => 'Your pieces are ready';

  @override
  String get jobsScanStoppedTitle => 'The scan stopped';

  @override
  String get jobsNothingSavedBody => 'Nothing was saved. Try again.';

  @override
  String get jobsPhotoUploadFailedBody => 'Photo upload failed.';

  @override
  String get authGoogleSignInStartFailed =>
      'Unable to start Google Sign-In. Please try again.';

  @override
  String get referralAppliedTitle => 'Referral Applied!';

  @override
  String get billingStoreUnavailableBody =>
      'Store purchases are not available on this device.';

  @override
  String get billingPurchaseProcessingBody =>
      'This purchase is still being processed. Reopen the app in a minute to see your plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatar upload did not return an image URL.';

  @override
  String get rewardsDayStreakLabel => 'day streak';

  @override
  String rewardsBestStreak(int days) {
    return 'Best $days days';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission Access Needed';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Access to $permission is currently denied. Open Settings to allow it, then come back and try again.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Step $step of 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Remove image $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Remove image $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Email $email. We review reports within 24 hours.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Remove $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Add to \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" is removed. Its pieces stay in your closet.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Show all $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count left today';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Photo $index failed';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected of $max photos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape build · $tone skin';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: not set';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked of $max picked';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Remove $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency priority';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'This plan is billed through the $store. Change or cancel it in your $store account settings.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Manage in the $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current of $max used';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'About ${seconds}s left';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done of $total studio photos ready';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready of $total studio photos ready. Tap a piece to skip it.';
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
  String get profileFieldNotSet => 'No';
}

/// The translations for English, as used in Canada (`en_CA`).
class AppLocalizationsEnCa extends AppLocalizationsEn {
  AppLocalizationsEnCa() : super('en_CA');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPhotoshoot => 'Photoshoot';

  @override
  String get tabCloset => 'Closet';

  @override
  String get tabOutfits => 'Outfits';

  @override
  String get tabMore => 'More';

  @override
  String get actionAddItem => 'Add item';

  @override
  String get actionCreateOutfit => 'Create outfit';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionContinue => 'Continue';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorBody =>
      'Try again. If it keeps failing, contact support.';

  @override
  String get stateOfflineTitle => 'You are offline';

  @override
  String get stateOfflineBody =>
      'Reconnect to sync your closet and generate outfits.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsPlanBilling => 'Plan and billing';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsUnits => 'Measurement units';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPrivacySection => 'Privacy and data';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountBody =>
      'This removes your closet, outfits, photos and profile. It cannot be undone.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metric (cm, kg)';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageSystemBody =>
      'FitCheck AI follows your phone\'s language.';

  @override
  String get languageSearchHint => 'Search languages';

  @override
  String get languageCurrent => 'Current';

  @override
  String get languageReviewNote =>
      'This translation is new. Tell us if something reads wrong.';

  @override
  String get languageChanged => 'Language updated';

  @override
  String get paywallTitle => 'Choose your plan';

  @override
  String get paywallTrialBadge => '1 month free';

  @override
  String get paywallTrialTitle => 'Your first month of Pro is free';

  @override
  String get paywallTrialBody =>
      'Upload your whole closet at once. Add pieces as you go after that.';

  @override
  String get paywallFreeForeverTitle => 'Free forever';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'No card needed. Every month you get $uploads AI uploads, $outfits outfits and $images photoshoot images a day.';
  }

  @override
  String get paywallCtaTrial => 'Start my free month';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Upgrade to $plan';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallManage => 'Manage subscription';

  @override
  String get paywallTerms => 'Terms of use';

  @override
  String get paywallPrivacy => 'Privacy policy';

  @override
  String get paywallPerMonth => 'per month';

  @override
  String get paywallPerYear => 'per year';

  @override
  String get paywallBestValue => 'Best value';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Free trial for new subscribers only. After the trial, Pro renews at $price unless cancelled at least 24 hours before it ends.';
  }

  @override
  String get introTitle => 'Your closet, finally organised';

  @override
  String get introBody =>
      'Photograph your clothes once. Get outfit ideas, try-on previews and studio photos from what you already own.';

  @override
  String get introStart => 'Get started';

  @override
  String get introHaveAccount => 'I already have an account';

  @override
  String get introSkip => 'Skip';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authOrDivider => 'or';

  @override
  String get wardrobeTitle => 'Closet';

  @override
  String get wardrobeEmptyTitle => 'Your closet is empty';

  @override
  String get wardrobeEmptyBody =>
      'Add your first piece, or upload a photo of the whole rail at once.';

  @override
  String get wardrobeAddFirst => 'Add your first item';

  @override
  String get wardrobeSearchHint => 'Search your closet';

  @override
  String get categoryTops => 'Tops';

  @override
  String get categoryBottoms => 'Bottoms';

  @override
  String get categoryShoes => 'Shoes';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get categoryOuterwear => 'Outerwear';

  @override
  String get categorySwimwear => 'Swimwear';

  @override
  String get categoryActivewear => 'Activewear';

  @override
  String get categoryOther => 'Other';

  @override
  String get conditionClean => 'Clean';

  @override
  String get conditionDirty => 'Dirty';

  @override
  String get conditionLaundry => 'In laundry';

  @override
  String get conditionRepair => 'Needs repair';

  @override
  String get conditionDonate => 'To donate';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonFall => 'Fall';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonAll => 'All season';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sporty';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalist';

  @override
  String get styleRomantic => 'Romantic';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Other';

  @override
  String get occasionWork => 'Work';

  @override
  String get occasionDateNight => 'Date night';

  @override
  String get occasionTravel => 'Travel';

  @override
  String get occasionWedding => 'Wedding';

  @override
  String get occasionGym => 'Gym';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Party';

  @override
  String get occasionInterview => 'Interview';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorWhite => 'White';

  @override
  String get colorGrey => 'Grey';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorRed => 'Red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Enjoying FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'A quick rating helps other people find their style.';

  @override
  String get ratingPromptYes => 'Rate the app';

  @override
  String get ratingPromptNo => 'Not now';

  @override
  String get closetNoMatchesTitle => 'No pieces match';

  @override
  String get closetNoMatchesBody => 'Try fewer filters or another search.';

  @override
  String get closetClearFilters => 'Clear filters';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Loading your pieces';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Delete selected';

  @override
  String get closetCancelSelection => 'Cancel selection';

  @override
  String get closetCloseSearch => 'Close search';

  @override
  String get closetShowGrid => 'Show as grid';

  @override
  String get closetShowList => 'Show as list';

  @override
  String get closetShowRows => 'Show as rows';

  @override
  String get closetStatsTitle => 'Closet stats';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count pieces?',
      one: 'Delete 1 piece?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Outfits that use them lose these pieces.';

  @override
  String get closetSortBy => 'Sort by';

  @override
  String get closetFavourites => 'Favourites';

  @override
  String get closetFavourite => 'Favourite';

  @override
  String get closetUnfavourite => 'Remove favourite';

  @override
  String get closetWoreToday => 'Wore it today';

  @override
  String closetWornTimes(int count) {
    return 'Worn $count×';
  }

  @override
  String get closetCategoryLabel => 'Category';

  @override
  String get closetUseCaseLabel => 'Use case';

  @override
  String get closetAnyUseCase => 'Any';

  @override
  String get closetOtherUseCase => 'Other use case';

  @override
  String get closetOtherUseCaseHint => 'For example, brunch';

  @override
  String get closetUseUseCase => 'Use this';

  @override
  String get closetClearAll => 'Clear all';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortName => 'Name (A–Z)';

  @override
  String get sortMostWorn => 'Most worn';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Dinner';

  @override
  String get useCaseLunch => 'Lunch';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sort';

  @override
  String get actionAll => 'All';

  @override
  String get dashboardStartClosetTitle => 'Start your closet';

  @override
  String get dashboardStartClosetBody =>
      'Photograph a few pieces. We tag them for you.';

  @override
  String get dashboardPieces => 'pieces';

  @override
  String get dashboardOutfits => 'outfits';

  @override
  String get dashboardDayStreak => 'day streak';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count this month';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Best $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favourites',
      one: '1 favourite',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved outfits',
      one: '1 saved outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String get setupSkip => 'Skip setup';

  @override
  String get setupWhoTitle => 'Who are we styling?';

  @override
  String get setupWhoBody =>
      'Sets the model for try-on and photoshoots. You can change it in your profile.';

  @override
  String get setupStyleTitle => 'What do you wear most?';

  @override
  String get setupStyleBody => 'Pick any. Outfit ideas start from these.';

  @override
  String get setupClosetTitle => 'Add your first pieces.';

  @override
  String get setupClosetBody =>
      'Photograph a few clothes, or a pile of them. Each piece is cut out and filed for you.';

  @override
  String get setupAddClothes => 'Add clothes';

  @override
  String get setupStylesLabel => 'Styles';

  @override
  String get setupOccasionsLabel => 'Occasions';

  @override
  String get setupSkipStep => 'Skip';

  @override
  String get setupLater => 'Later';

  @override
  String get setupSaveError => 'Could not save';

  @override
  String get genderWomen => 'Women';

  @override
  String get genderMen => 'Men';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get outfitEmptyTitle => 'No outfits yet';

  @override
  String get outfitEmptyBody =>
      'Pair pieces from your closet and save the look.';

  @override
  String get outfitNoMatchesTitle => 'No outfits match';

  @override
  String get outfitSearchHint => 'Search your outfits';

  @override
  String get outfitLoading => 'Loading your outfits';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Style and season';

  @override
  String get outfitCollections => 'Collections';

  @override
  String get outfitDuplicate => 'Duplicate';

  @override
  String get outfitDeleteTitle => 'Delete this outfit?';

  @override
  String get outfitDeleteBody => 'Its pieces stay in your closet.';

  @override
  String get outfitDrafts => 'Drafts';

  @override
  String get outfitDraft => 'Draft';

  @override
  String get filterStyle => 'Style';

  @override
  String get filterSeason => 'Season';

  @override
  String get itemDetailDeleteTitle => 'Delete this piece?';

  @override
  String get itemDetailDeleteBody => 'Outfits that use it lose this piece.';

  @override
  String get itemAddFavourite => 'Add to favourites';

  @override
  String itemSize(String size) {
    return 'Size $size';
  }

  @override
  String get itemColours => 'Colours';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Pattern';

  @override
  String get itemUseCases => 'Use cases';

  @override
  String get itemKeptIn => 'Kept in';

  @override
  String get itemPrice => 'Price';

  @override
  String get itemBought => 'Bought';

  @override
  String get itemTags => 'Tags';

  @override
  String get itemAdded => 'Added';

  @override
  String get itemTimesWornLabel => 'times worn';

  @override
  String get itemLastWornLabel => 'last worn';

  @override
  String get itemNeverWorn => 'Never';

  @override
  String get authEntryBody =>
      'Every piece you own, styled by AI. Plan outfits, try them on, shoot them.';

  @override
  String get authCreateCloset => 'Create your closet';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInBody => 'Sign in to open your closet.';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authCreateClosetBody =>
      'It takes a minute. Your first items are free.';

  @override
  String get authName => 'Name';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authReferralCode => 'Referral code (optional)';

  @override
  String get authResetTitle => 'Reset your password';

  @override
  String get authResetBody => 'We will email you a link to choose a new one.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authEnterEmail => 'Enter your email';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authEnterPassword => 'Enter your password';

  @override
  String get authPasswordTooShort => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authNewHere => 'New here?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirm $email before you sign in. Check your inbox.';
  }

  @override
  String get authResendEmail => 'Send it again';

  @override
  String get authResendingEmail => 'Sending…';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authEnterName => 'Enter your name';

  @override
  String get authChoosePassword => 'Choose a password';

  @override
  String get authHaveAccount => 'Have an account?';

  @override
  String get authCodeAccepted => 'Code accepted';

  @override
  String get authCodeNotFound => 'Code not found';

  @override
  String authReferralFrom(String name) {
    return 'From $name. You both get a month free.';
  }

  @override
  String get authReferralInvalid => 'We could not find this code.';

  @override
  String authResetSent(String email) {
    return 'Sent to $email. Open the link on this phone.';
  }

  @override
  String get introSlide1Title => 'Snap your closet once.';

  @override
  String get introSlide1Body =>
      'Photograph a pile of clothes. Every piece is cut out and filed for you.';

  @override
  String get introSlide2Title => 'Get dressed faster.';

  @override
  String get introSlide2Body =>
      'Outfits from what you own, matched to your plans and the weather.';

  @override
  String get introSlide3Title => 'See it before you wear it.';

  @override
  String get introSlide3Body =>
      'Try looks on your own photo, or shoot them like a campaign.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTemperature => 'Temperature';

  @override
  String get settingsEmailUpdates => 'Email updates';

  @override
  String get settingsEmailUpdatesBody => 'News and tips by email';

  @override
  String get settingsOutfitReminders => 'Outfit reminders';

  @override
  String get settingsOutfitRemindersBody => 'A nudge to log what you wore';

  @override
  String get settingsWeeklySummary => 'Weekly summary';

  @override
  String get settingsWeeklySummaryBody => 'Your week in outfits';

  @override
  String get settingsStyleSection => 'Style';

  @override
  String get settingsPreferredStyles => 'Styles you like';

  @override
  String get settingsPreferredColours => 'Colours you like';

  @override
  String get settingsNoneChosen => 'None chosen';

  @override
  String get settingsPlanAiSection => 'Plan and AI';

  @override
  String get settingsPlanBillingBody => 'Plan, usage and upgrades';

  @override
  String get settingsPlanUsageBody => 'Plan and usage';

  @override
  String get settingsInviteFriends => 'Invite friends';

  @override
  String get settingsInviteFriendsBody =>
      'A free month for each friend who joins';

  @override
  String get settingsAiProvider => 'AI provider';

  @override
  String get settingsAiProviderBody =>
      'Use your own model for tagging and images';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsPrivacyTerms => 'Privacy and terms';

  @override
  String get settingsReportProblem => 'Report a problem';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsExportData => 'Export your data';

  @override
  String get settingsExportBody =>
      'We prepare a file with everything you saved and open the download.';

  @override
  String get settingsExportAction => 'Export';

  @override
  String get settingsCurrentPassword => 'Current password';

  @override
  String get settingsNewPassword => 'New password';

  @override
  String get settingsConfirmNewPassword => 'Confirm new password';

  @override
  String get settingsEnterCurrentPassword => 'Enter your current password';

  @override
  String get settingsEnterNewPassword => 'Enter a new password';

  @override
  String get settingsPasswordMin8 => 'Use at least 8 characters';

  @override
  String get settingsPasswordNeedsUpper => 'Add an uppercase letter';

  @override
  String get settingsPasswordNeedsLower => 'Add a lowercase letter';

  @override
  String get settingsPasswordNeedsDigit => 'Add a number';

  @override
  String get settingsPasswordsNoMatch => 'The passwords do not match';

  @override
  String get settingsChangeAction => 'Change';

  @override
  String get itemAddSnapTitle => 'Snap a piece';

  @override
  String get itemAddSnapBody =>
      'We find every piece in the photo and make a clean studio shot of each.';

  @override
  String get itemAddCamera => 'Take a photo';

  @override
  String get itemAddGallery => 'Choose from gallery';

  @override
  String get itemAddOtherWays => 'Other ways to add';

  @override
  String get itemAddSeveral => 'Add several photos';

  @override
  String get itemAddSeveralBody => 'Up to 50 at once';

  @override
  String get itemAddImportProfile => 'Import from a profile';

  @override
  String get itemAddImportProfileBody => 'Instagram or Facebook';

  @override
  String get itemAddEnterDetails => 'Enter details yourself';

  @override
  String get itemAddEnterDetailsBody => 'No photo needed';

  @override
  String get itemManualIntro =>
      'Only a name is needed. Add the rest now or later.';

  @override
  String get itemManualNameHint => 'For example, blue cotton tee';

  @override
  String get itemManualEnterName => 'Enter a name';

  @override
  String get itemManualNotes => 'Notes';

  @override
  String get itemManualBrand => 'Brand';

  @override
  String get itemManualSize => 'Size';

  @override
  String get itemManualEnterNumber => 'Enter a number';

  @override
  String get itemManualSavePiece => 'Save piece';

  @override
  String get itemManualSaving => 'Saving';

  @override
  String get itemManualSavedTitle => 'Saved';

  @override
  String itemManualSavedBody(String name) {
    return '$name is in your closet.';
  }

  @override
  String get itemManualNotSaved => 'Not saved';

  @override
  String get itemManualAddUseCase => 'Add a use case';

  @override
  String get itemManualAddUseCaseAction => 'Add use case';

  @override
  String get itemPhotos => 'Photos';

  @override
  String get itemAddPhotos => 'Add photos';

  @override
  String get itemNoPhotoYet => 'No photo yet. You can save without one.';

  @override
  String get itemRemovePhoto => 'Remove photo';

  @override
  String get itemRemovePiece => 'Remove piece';

  @override
  String get filterConditionLabel => 'Condition';

  @override
  String get photoshootStepPhotos => 'Photos';

  @override
  String get photoshootStepSetup => 'Setup';

  @override
  String get photoshootStepCreating => 'Creating';

  @override
  String get photoshootStepResults => 'Results';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Step $current of $total, $name';
  }

  @override
  String get photoshootOneFailed => 'One photo failed. Retry it below.';

  @override
  String photoshootManyFailed(int count) {
    return '$count photos failed. Retry each one below.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'How many';

  @override
  String get photoshootYourPrompt => 'Your prompt';

  @override
  String get photoshootPromptHint => 'Golden hour on a rooftop, linen shirt';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create $count photos',
      one: 'Create 1 photo',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'photos',
      one: 'photo',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'We couldn\'t check today\'s limit.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan plan: $remaining of $limit left today';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Free';

  @override
  String get photoshootGallery => 'Gallery';

  @override
  String get photoshootUseCamera => 'Use camera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Remove photo $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'No photos came back';

  @override
  String get photoshootNoPhotosBody =>
      'The shoot finished without images. Try again.';

  @override
  String get photoshootNewStyle => 'New style';

  @override
  String get photoshootNewPhotos => 'New photos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Open photo $number';
  }

  @override
  String get photoshootReportPhoto => 'Report photo';

  @override
  String get photoshootSaveToGallery => 'Save to gallery';

  @override
  String get actionUpgrade => 'Upgrade';

  @override
  String get referralLimitTitle => 'You\'ve used today\'s photos';

  @override
  String get referralLimitBody =>
      'Your free photos come back tomorrow. Refer a friend and you both get a month of Pro free.';

  @override
  String get referralLimitRefer => 'Refer a friend';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating app';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Aesthetic';

  @override
  String get photoshootUseCustom => 'Your own prompt';

  @override
  String get photoshootDescLinkedin => 'Sharp headshots for work';

  @override
  String get photoshootDescDating => 'Relaxed, warm and natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, high-fashion looks';

  @override
  String get photoshootDescInstagram => 'Lifestyle shots for your feed';

  @override
  String get photoshootDescAesthetic => 'Moody, artistic frames';

  @override
  String get photoshootDescCustom => 'Describe the look you want';

  @override
  String get aspectSquare => 'Square';

  @override
  String get aspectPortrait => 'Portrait';

  @override
  String get aspectLandscape => 'Landscape';

  @override
  String get aspectTall => 'Tall';

  @override
  String get aspectWide => 'Wide';

  @override
  String get tryOnAppBar => 'Virtual try-on';

  @override
  String get tryOnYourPhoto => 'Your photo';

  @override
  String get tryOnGarment => 'Garment';

  @override
  String get tryOnUploadingPhoto => 'Uploading your photo';

  @override
  String get tryOnAddPhotoPrompt => 'Add a full-body photo of yourself';

  @override
  String get tryOnBodyPhotoHint => 'A full-body photo works best';

  @override
  String get tryOnAddPhoto => 'Add photo';

  @override
  String get tryOnChangePhoto => 'Change photo';

  @override
  String get tryOnPhotoLoadFailed => 'We couldn\'t load your photo.';

  @override
  String get tryOnChooseGarment => 'Choose a garment photo';

  @override
  String get tryOnChooseOneGarment => 'Choose one garment photo';

  @override
  String get tryOnGarmentHint => 'A flat lay or a hanger shot works best';

  @override
  String get tryOnChange => 'Change';

  @override
  String get tryOnCamera => 'Camera';

  @override
  String get tryOnRemove => 'Remove';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Style';

  @override
  String get tryOnBackground => 'Background';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Dressing you up. This takes about half a minute.';

  @override
  String get tryOnEmptyResult => 'Your try-on appears here';

  @override
  String get tryOnReportImage => 'Report image';

  @override
  String get tryOnCreating => 'Creating';

  @override
  String get tryOnTryAgain => 'Try again';

  @override
  String get tryOnCreate => 'Create try-on';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio white';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio grey';

  @override
  String get tryOnBackgroundUrban => 'Urban street';

  @override
  String get tryOnBackgroundNature => 'Nature';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Standing front';

  @override
  String get tryOnPoseSide => 'Standing side';

  @override
  String get tryOnPoseWalking => 'Walking';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardWelcome => 'Welcome';

  @override
  String get dashboardOpenProfile => 'Open profile';

  @override
  String get dashboardRailToday => 'Today';

  @override
  String get dashboardRailRecently => 'Recently';

  @override
  String get dashboardActivityEmpty => 'New pieces and outfits show up here.';

  @override
  String get quickAddPiece => 'Add a piece';

  @override
  String get quickAddPieceBody => 'Photograph and tag';

  @override
  String get quickBuildOutfit => 'Build an outfit';

  @override
  String get quickBuildOutfitBody => 'Mix your pieces';

  @override
  String get quickForYou => 'For you';

  @override
  String get quickForYouBody => 'Picks for today';

  @override
  String get quickPlanWeek => 'Plan the week';

  @override
  String get quickPlanWeekBody => 'Outfits by date';

  @override
  String get referralBannerUrgent => 'Running low? Invite a friend.';

  @override
  String get referralBannerTitle => 'Give a month, get a month.';

  @override
  String get referralBannerBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get referralBannerDismiss => 'Dismiss for a week';

  @override
  String get referralBannerShare => 'Share invite';

  @override
  String get referralBannerCopy => 'Copy link';

  @override
  String get itemEditPieceTitle => 'Edit piece';

  @override
  String get itemEditDescriptionLabel => 'Description';

  @override
  String get itemEditNotSaved => 'Not saved';

  @override
  String get itemEditSavedTitle => 'Saved';

  @override
  String get itemEditSavedBody => 'Your changes are saved.';

  @override
  String get itemEditSavedStalePhotos => 'Saved — photos may be out of date';

  @override
  String get itemEditRemovePieceHint => 'Delete this piece from the item page.';

  @override
  String get itemEditNoPhotos =>
      'No photos yet. Add one from your gallery or camera.';

  @override
  String get itemEditKeepPhoto => 'Keep photo';

  @override
  String get itemEditRemoved => 'Removed';

  @override
  String get itemEditAddUseCaseAction => 'Add';

  @override
  String get statsNoStatsTitle => 'No stats yet';

  @override
  String get statsNoStatsBody =>
      'Add a few pieces and your closet mix shows up here.';

  @override
  String get statsByCategory => 'By category';

  @override
  String get statsTotalValue => 'total value';

  @override
  String get statsMostWorn => 'Worn the most';

  @override
  String get statsLeastWorn => 'Waiting for a turn';

  @override
  String get statsUnnamedPiece => 'Unnamed piece';

  @override
  String get jobsTitle => 'Scans';

  @override
  String get jobsEmptyTitle => 'No scans yet';

  @override
  String get jobsEmptyBody =>
      'Snap a piece and send it to the background — it keeps working here.';

  @override
  String get jobsNotCancelled => 'Not cancelled';

  @override
  String get jobsResume => 'Resume';

  @override
  String get jobsReview => 'Review';

  @override
  String get jobsStop => 'Stop';

  @override
  String get jobsDismiss => 'Dismiss';

  @override
  String get reportTitle => 'Report content';

  @override
  String reportIntro(String contentType) {
    return 'Tell us what\'s wrong with this $contentType. Our team reviews every report.';
  }

  @override
  String get reportReasonInappropriate => 'Inappropriate or offensive';

  @override
  String get reportReasonNudity => 'Nudity or sexual content';

  @override
  String get reportReasonHarassment => 'Harassment or abuse';

  @override
  String get reportReasonImpersonation => 'Impersonation';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportDetailsLabel => 'Additional details (optional)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSubmittedTitle => 'Report submitted';

  @override
  String get reportSubmittedBody =>
      'Thank you. Our team will review this content.';

  @override
  String get reportFailedTitle => 'Couldn\'t send report';

  @override
  String get reportFailedBody => 'Please try again.';

  @override
  String get reportContentTryOnImage => 'AI try-on image';

  @override
  String get reportContentSharedOutfit => 'shared outfit';

  @override
  String get reportContentPhotoshootImage => 'AI photoshoot image';

  @override
  String get sharedOutfitTitle => 'Shared outfit';

  @override
  String get sharedOutfitHideTooltip => 'Hide this outfit';

  @override
  String get sharedOutfitReportTooltip => 'Report this outfit';

  @override
  String get sharedOutfitHideTitle => 'Hide this outfit?';

  @override
  String get sharedOutfitHideBody =>
      'It stays hidden on this device. You can also report it so our team can review and remove it.';

  @override
  String get sharedOutfitHideAction => 'Hide';

  @override
  String get sharedOutfitHiddenInfo =>
      'This outfit will not show on this device again.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit hidden';

  @override
  String get sharedOutfitMissingTitle => 'This outfit isn\'t here anymore';

  @override
  String get sharedOutfitMissingBody =>
      'It may have been removed, or the link is wrong.';

  @override
  String get sharedOutfitHiddenStateTitle => 'You hid this outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'If it was objectionable, report it from Privacy and terms or email $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Like this look?';

  @override
  String get sharedOutfitCtaBody =>
      'Build outfits like it from your own closet.';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get errorNoConnection =>
      'No internet connection. Please check your network.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorServerError =>
      'Something went wrong on our end. Please try again.';

  @override
  String get errorBadGateway =>
      'Our server is briefly unavailable. Please try again.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Please try again shortly.';

  @override
  String get errorInternalError => 'Something went wrong. Please try again.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorForbidden => 'You do not have access to that.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get errorInvalidCredentials =>
      'That email or password is not correct.';

  @override
  String get errorTokenRefreshFailed =>
      'We could not refresh your session. Please sign in again.';

  @override
  String get errorRequestCancelled => 'Request cancelled.';

  @override
  String get errorInvalidFormat => 'That file format is not supported.';

  @override
  String get errorFileTooLarge => 'That file is too large.';

  @override
  String get errorUploadFailed => 'The upload failed. Please try again.';

  @override
  String get errorCacheCorrupted =>
      'Saved data was damaged and has been reset.';

  @override
  String get errorCacheNotFound => 'Nothing was saved yet.';

  @override
  String get errorUserNotFound => 'We could not find that account.';

  @override
  String get errorItemNotFound => 'That item no longer exists.';

  @override
  String get errorOutfitNotFound => 'That outfit no longer exists.';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsNoAchievementsTitle => 'No achievements yet';

  @override
  String get rewardsNoAchievementsBody =>
      'Add pieces and plan outfits to earn your first.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'No one on the board yet';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plan outfits to earn points and show up here.';

  @override
  String get legalViewPrivacyPolicy => 'View Privacy Policy';

  @override
  String get aiConsentAgree => 'I Agree & Continue';

  @override
  String get aiConsentNotNow => 'Not Now';

  @override
  String get imageViewerCloseTooltip => 'Close image viewer';

  @override
  String get updateReadyTitle => 'Update ready';

  @override
  String get updateReadyBody =>
      'Restart FitCheck AI to apply the latest improvements.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI needs camera access to take photos of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI needs photo library access to select images of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI needs to save your AI-generated outfit photos to your photo library.';

  @override
  String get wardrobeSomePhotosSkipped => 'Some photos skipped';

  @override
  String get wardrobePhotosNotAdded => 'Photos not added';

  @override
  String get wardrobePhotoNotAdded => 'Photo not added';

  @override
  String get wardrobeNotStartedTitle => 'Not started';

  @override
  String get wardrobeNoRoomTitle => 'No room';

  @override
  String get wardrobeAddPhotosSemantic => 'Add photos';

  @override
  String get batchAddTileLabel => 'Add';

  @override
  String get batchProfileLinkLabel => 'Profile link';

  @override
  String get wardrobeImportFromProfileTitle => 'Import from a profile';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Add several photos';

  @override
  String get wardrobeClearAction => 'Clear';

  @override
  String get wardrobeRefreshTooltip => 'Refresh';

  @override
  String get batchNoPhotosYetTitle => 'No photos yet';

  @override
  String get batchChoosePhotosAction => 'Choose photos';

  @override
  String get batchWeFindEachPieceBody =>
      'We find each piece and make a studio photo of it.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparing photos';

  @override
  String get batchPhotosProcessedSemantic => 'Photos processed';

  @override
  String get batchPasteProfileLinkTitle => 'Paste a profile link';

  @override
  String get batchPasteProfileLinkBody =>
      'A public Instagram or Facebook profile. We scan its photos, and you choose what goes in your closet.';

  @override
  String get batchClearLinkTooltip => 'Clear link';

  @override
  String get batchStartingButton => 'Starting';

  @override
  String get batchStartImportAction => 'Start import';

  @override
  String get batchReviewEveryPhotoTitle => 'You review every photo';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nothing is added until you approve it.';

  @override
  String get batchPrivateProfilesTitle => 'Private profiles';

  @override
  String get batchPrivateProfilesBody =>
      'Connect your account. Instagram also takes a username and password.';

  @override
  String get batchUseAnotherLinkAction => 'Use another link';

  @override
  String get batchSignInNeededTitle => 'Sign-in needed';

  @override
  String get batchEnterYourCodeTitle => 'Enter your code';

  @override
  String get batchUseUsernamePasswordAction => 'Use username and password';

  @override
  String get batchAlreadyConnectedAction =>
      'I already connected in the browser';

  @override
  String get batchEnterCodeAction => 'Enter code';

  @override
  String get batchTryAnotherWayAction => 'Try another way';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Reconnecting';

  @override
  String get batchSignInToInstagramTitle => 'Sign in to Instagram';

  @override
  String get batchUsernameLabel => 'Username';

  @override
  String get batchCodeIfTwoStepLabel => 'Code, if you use two-step sign-in';

  @override
  String get batchAuthenticatorCodeBody =>
      'Use the 6-digit code from your authenticator app. Codes change quickly.';

  @override
  String get batchVerifyAction => 'Verify';

  @override
  String get batchFindingPhotosTitle => 'Finding photos';

  @override
  String get batchImportPausedTitle => 'Import paused';

  @override
  String get batchProcessingPhotosTitle => 'Processing photos';

  @override
  String get batchWaitingNextPhoto => 'Waiting for the next photo';

  @override
  String get batchCancelImportAction => 'Cancel import';

  @override
  String get batchNoPiecesInPhotoBody => 'No pieces found in this photo.';

  @override
  String get batchEditPieceColoursLabel => 'Colours, separated by commas';

  @override
  String get batchAddToClosetAction => 'Add to closet';

  @override
  String get batchSkipPhotoAction => 'Skip this photo';

  @override
  String get batchImportCompleteTitle => 'Import complete';

  @override
  String get batchImportFailedTitle => 'Import failed';

  @override
  String get batchImportCancelledTitle => 'Import cancelled';

  @override
  String get batchImportErrorBody => 'Something went wrong while importing.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nothing more is imported from this profile.';

  @override
  String get batchViewClosetAction => 'View closet';

  @override
  String get batchStartOverAction => 'Start over';

  @override
  String get wardrobeAddPieceTitle => 'Add a piece';

  @override
  String get wardrobeAddDetailsTitle => 'Add details';

  @override
  String get wardrobeScanningTitle => 'Scanning';

  @override
  String get batchReviewPiecesTitle => 'Review pieces';

  @override
  String get wardrobeGalleryAction => 'Gallery';

  @override
  String get wardrobeCameraAction => 'Camera';

  @override
  String get wardrobeNewBadge => 'New';

  @override
  String get wardrobeRemovePhotoTooltip => 'Remove photo';

  @override
  String get batchRunInBackgroundTooltip => 'Run in background';

  @override
  String get batchStepOneOfTwo => 'Step 1 of 2';

  @override
  String get batchStepTwoOfTwo => 'Step 2 of 2';

  @override
  String get batchUploadingPhotosTitle => 'Uploading photos';

  @override
  String get batchFindingPiecesTitle => 'Finding pieces';

  @override
  String get batchMakingStudioPhotosTitle => 'Making studio photos';

  @override
  String get batchStoppedLabel => 'Stopped';

  @override
  String get batchFindingPiecesStoppedTitle => 'Finding pieces stopped';

  @override
  String get batchCancelledLabel => 'Cancelled';

  @override
  String get batchAllDoneTitle => 'All done';

  @override
  String get batchOpeningPiecesBody => 'Opening your pieces';

  @override
  String get batchNothingSavedBody => 'Nothing was saved.';

  @override
  String get batchFindingPiecesFailedBody => 'Finding pieces failed.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Finding pieces stopped early.';

  @override
  String get batchStopFindingPiecesTitle => 'Stop finding pieces?';

  @override
  String get batchStopFindingPiecesBody =>
      'The scan stops and nothing is saved. Pieces already found stay in your activity until you dismiss them.';

  @override
  String get batchKeepGoingAction => 'Keep going';

  @override
  String get batchTryAgainAction => 'Try again';

  @override
  String get batchBackToPhotosAction => 'Back to photos';

  @override
  String get batchSkipAllAction => 'Skip all';

  @override
  String get batchIncludeAllAction => 'Include all';

  @override
  String get batchNoPiecesFoundTitle => 'No pieces found';

  @override
  String get batchNoPiecesFoundBody => 'We found no clothes in these photos.';

  @override
  String get batchChooseOtherPhotosAction => 'Choose other photos';

  @override
  String get batchUseCaseHelper => 'Added to every piece you save.';

  @override
  String get batchDiscardPiecesTitle => 'Discard these pieces?';

  @override
  String get batchDiscardPiecesBody => 'Nothing from this batch is saved.';

  @override
  String get batchKeepAction => 'Keep';

  @override
  String get batchDiscardAction => 'Discard';

  @override
  String get batchRemovePieceTitle => 'Remove this piece?';

  @override
  String get batchRemovePieceBody => 'It is not saved to your closet.';

  @override
  String get batchRemoveAction => 'Remove';

  @override
  String get batchChoosePiecesToSave => 'Choose pieces to save';

  @override
  String get batchDiscardAllAction => 'Discard all';

  @override
  String get batchNothingSavedRetryBody => 'Nothing was saved. Try again.';

  @override
  String get batchNotSavedTitle => 'Not saved';

  @override
  String get batchSavingLabel => 'Saving';

  @override
  String get batchSendToBackgroundAction => 'Send to background';

  @override
  String get batchStillWorkingMessage =>
      'Still working. We will let you know when your pieces are ready.';

  @override
  String get batchRunningInBackgroundTitle => 'Running in background';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studio photos stopped early. You can still save these pieces.';

  @override
  String get batchTapPieceToSkip => 'Tap a piece to skip it.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studio photos still on their way. You can leave — we will let you know.';

  @override
  String get batchLeaveAction => 'Leave';

  @override
  String get batchPeopleInPhotosTitle => 'People in the photos';

  @override
  String get batchIncludeAction => 'Include';

  @override
  String get batchSkipAction => 'Skip';

  @override
  String get batchYourPhotoIsUsedLabel => 'Your photo is used';

  @override
  String get batchMakingStudioPhotoLabel => 'Making studio photo';

  @override
  String get batchNoStudioPhotoBody => 'No studio photo. Your photo is used.';

  @override
  String get batchEnterDetailsYourselfAction => 'Enter details yourself';

  @override
  String get batchChooseAnotherPhotoAction => 'Choose another photo';

  @override
  String get batchConnectionLostTitle => 'Connection lost';

  @override
  String get batchConnectionLostBody =>
      'Check your connection, then try again.';

  @override
  String get batchDailyLimitTitle => 'Daily limit reached';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Upgrade to Pro for more scans, or enter the details yourself.';

  @override
  String get batchDailyLimitBodyFree =>
      'Your scans reset tomorrow. You can enter the details yourself now.';

  @override
  String get batchSeePlansAction => 'See plans';

  @override
  String get batchAiBusyTitle => 'Our AI is busy';

  @override
  String get batchAiBusyBody =>
      'This is on our side. Try again in a few minutes.';

  @override
  String get batchNoPiecesBody =>
      'Try a clearer photo, or enter the details yourself.';

  @override
  String get batchScanningUnavailableTitle => 'Scanning is unavailable';

  @override
  String get batchScanningUnavailableBody =>
      'Enter the details yourself for now.';

  @override
  String get batchScanDidNotFinishTitle => 'The scan did not finish';

  @override
  String get batchTryAgainBody => 'Try again.';

  @override
  String get billingTitle => 'Subscription';

  @override
  String get billingUpgradeHeading => 'Upgrade your plan';

  @override
  String get billingUpgradeOnPlusBody => 'Same features, higher limits.';

  @override
  String get billingUpgradeBody =>
      'Plus and Pro have the same features. Pick the limits you need.';

  @override
  String get billingWebUnavailableBody =>
      'Online upgrades aren\'t available yet. A promo or referral code still unlocks Plus or Pro. Invite friends below to earn free months.';

  @override
  String get billingPlansStale =>
      'Couldn\'t load the latest plans. Prices may be out of date.';

  @override
  String get billingMonthly => 'Monthly';

  @override
  String get billingYearly => 'Yearly';

  @override
  String get billingCurrentPlan => 'Current plan';

  @override
  String get billingActive => 'Active';

  @override
  String get billingThisMonth => 'This month';

  @override
  String get billingItemExtractions => 'Item extractions';

  @override
  String get billingOutfitVisualizations => 'Outfit visualizations';

  @override
  String get billingNearLimitUpgrade =>
      'You\'re close to this month\'s limit. Upgrade for more.';

  @override
  String get billingNearLimitResets =>
      'You\'re close to this month\'s limit. It resets at the start of next month.';

  @override
  String get billingStoreUnavailable =>
      'Upgrades aren\'t available in the store yet. Check back soon.';

  @override
  String get billingManageHeading => 'Manage your plan';

  @override
  String get billingCancelPlan => 'Cancel subscription';

  @override
  String get billingCancelKeepsAccess =>
      'You keep access until the end of this billing period.';

  @override
  String get billingCancelConfirmTitle => 'Cancel your subscription?';

  @override
  String get billingKeepPlan => 'Keep plan';

  @override
  String get billingCancelPlanAction => 'Cancel plan';

  @override
  String get billingBilledMonthly => 'Billed monthly';

  @override
  String get billingBilledYearly => 'Billed yearly';

  @override
  String get billingVirtualTryOn => 'Virtual try-on';

  @override
  String get billingPrioritySupport => 'Priority support';

  @override
  String get billingDisclosureProRenewing =>
      'Pro is an auto-renewing subscription';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus and Pro are auto-renewing subscriptions';

  @override
  String get billingDisclosureAppleBilling =>
      'Payment is charged to your Apple ID at confirmation of purchase.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Payment is charged to your Google Play account at confirmation of purchase.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Your subscription renews automatically for the same period at the same price unless you turn off auto-renew at least 24 hours before the current period ends.';

  @override
  String get billingDisclosureAppleManage =>
      'Manage or cancel any time in Settings › your Apple ID › Subscriptions.';

  @override
  String get billingDisclosureGoogleManage =>
      'Manage or cancel any time in Google Play › Payments and subscriptions.';

  @override
  String get billingReferFriend => 'Refer a friend';

  @override
  String get billingHowItWorks => 'How it works';

  @override
  String get billingHowShareTitle => 'Share your link';

  @override
  String get billingHowShareBody => 'Send it to a friend.';

  @override
  String get billingHowSignUpTitle => 'They sign up';

  @override
  String get billingHowSignUpBody => 'Your friend joins from the link.';

  @override
  String get billingHowBothTitle => 'You both get Pro';

  @override
  String get billingHowBothBody => 'Each of you gets a month of Pro free.';

  @override
  String get billingYourReferrals => 'Your referrals';

  @override
  String get billingInvited => 'Invited';

  @override
  String get billingJoined => 'Joined';

  @override
  String get billingMonthsEarned => 'Months earned';

  @override
  String get billingInviteFriend => 'Invite a friend';

  @override
  String get billingInviteBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get billingYourCode => 'Your code';

  @override
  String get billingCopyLink => 'Copy link';

  @override
  String get billingShareInvite => 'Share invite';

  @override
  String get giftUnavailable =>
      'Gift invitations are not available in this build.';

  @override
  String get giftPageTitle => 'Gift FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'No free gift invitations are available right now.';

  @override
  String get giftFormTitle => 'Send a free invitation';

  @override
  String get giftFormBody =>
      'Your recipient claims the gift with this verified email. We don\'t send the email for you.';

  @override
  String get giftFieldFrom => 'From';

  @override
  String get giftFieldRecipientName => 'Recipient name';

  @override
  String get giftFieldRecipientEmail => 'Recipient email';

  @override
  String get giftFieldOccasion => 'Occasion (optional)';

  @override
  String get giftNoOccasion => 'No occasion';

  @override
  String get giftOccasionBirthday => 'Birthday';

  @override
  String get giftOccasionAnniversary => 'Anniversary';

  @override
  String get giftOccasionOther => 'Other';

  @override
  String get giftFieldCardGreeting => 'Card greeting';

  @override
  String get giftFieldCardGreetingHelper =>
      'This appears on the card exactly as written.';

  @override
  String get giftFieldPrivateNote => 'Private note (optional)';

  @override
  String get giftCreateAction => 'Create free gift';

  @override
  String get giftClaimedTitle => 'Gift claimed';

  @override
  String get giftClaimedActive => 'Your FitCheck Pro gift is active.';

  @override
  String get giftClaimedQueued =>
      'Your FitCheck Pro gift starts after your current access.';

  @override
  String get giftLinkCopied => 'Gift link copied to the clipboard.';

  @override
  String get giftErrorName => 'Enter a name.';

  @override
  String get giftErrorEmail => 'Enter a valid email address.';

  @override
  String get giftErrorGreeting => 'Enter the card greeting.';

  @override
  String get giftErrorGreetingLength => 'Use no more than 80 characters.';

  @override
  String get giftClaimAction => 'Claim gift';

  @override
  String get giftCardPreview => 'Card preview';

  @override
  String get giftGiftForYou => 'A gift for you';

  @override
  String get giftGiftWaiting => 'A gift is waiting for you';

  @override
  String get giftOpenBody =>
      'Open your gifts to claim them with your verified email.';

  @override
  String get giftOpenGifts => 'Open gifts';

  @override
  String get giftSendInvitation => 'Send invitation';

  @override
  String get settingsAiProviderSection => 'Provider';

  @override
  String get settingsAiCustom => 'Custom';

  @override
  String get settingsAiUrlHelper =>
      'Use a public URL the server can reach. Localhost does not work from our servers.';

  @override
  String get settingsAiConnectionSection => 'Connection';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API key';

  @override
  String get settingsAiApiKeySaved => 'Saved. Leave blank to keep it.';

  @override
  String get settingsAiChatModel => 'Chat model';

  @override
  String get settingsAiVisionModel => 'Vision model (optional)';

  @override
  String get settingsAiImageModel => 'Image model (optional)';

  @override
  String get settingsAiImageModelNote =>
      'Image generation needs OpenAI-compatible chat completions with response_modalities.';

  @override
  String get settingsAiTestConnection => 'Test connection';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarGoToToday => 'Go to today';

  @override
  String get calendarConnectTooltip => 'Connect a calendar';

  @override
  String get calendarAddEvent => 'Add event';

  @override
  String get calendarEmptyTitle => 'Nothing planned';

  @override
  String get calendarEmptyBody => 'Add an event and plan what to wear.';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarAllDay => 'All day';

  @override
  String get calendarOutfitLinked => 'Outfit linked';

  @override
  String get calendarEventOptions => 'Event options';

  @override
  String get calendarDeleteTitle => 'Delete this event?';

  @override
  String get calendarChangeOutfit => 'Change outfit';

  @override
  String get calendarLinkOutfit => 'Link an outfit';

  @override
  String get calendarRemoveOutfit => 'Remove outfit';

  @override
  String get calendarNewEvent => 'New event';

  @override
  String get calendarEditEvent => 'Edit event';

  @override
  String get calendarTitleLabel => 'Title';

  @override
  String get calendarTitleRequired => 'Add a title';

  @override
  String get calendarEndBeforeStart => 'End after the start time';

  @override
  String get calendarStarts => 'Starts';

  @override
  String get calendarEnds => 'Ends';

  @override
  String get calendarPlaceOptional => 'Place (optional)';

  @override
  String get calendarNotesOptional => 'Notes (optional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Build an outfit, then link it to this event.';

  @override
  String get calendarBuildOutfit => 'Build an outfit';

  @override
  String get calendarConnectionsTitle => 'Calendars';

  @override
  String get calendarConnectionsBody => 'Events you add here stay in FitCheck.';

  @override
  String get calendarDisconnect => 'Disconnect';

  @override
  String get calendarNotAvailable => 'Not available yet';

  @override
  String get profileSectionExplore => 'Explore';

  @override
  String get profileNavTryOn => 'Try-on';

  @override
  String get profileNavRewards => 'Rewards';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutBody => 'Your closet, outfits and plans in one place.';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody => 'You can sign back in at any time.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileYourProfile => 'Your profile';

  @override
  String get profileBodyProfiles => 'Body profiles';

  @override
  String get profileBodyEmptyTitle => 'No body profiles yet';

  @override
  String get profileBodyEmptyBody =>
      'Add your height and build to get a better fit.';

  @override
  String get profileBodyAdd => 'Add a profile';

  @override
  String get profileBodyDefaultNote =>
      'Your default profile is used for fit and try-on.';

  @override
  String get profileBodyDefaultBadge => 'Default';

  @override
  String get profileBodyMakeDefault => 'Make default';

  @override
  String get profileBodyDeleteBody => 'You cannot undo this.';

  @override
  String get profileBodyRequired => 'Required';

  @override
  String get profileBodyCheckNumber => 'Check this number';

  @override
  String get profileBodyNew => 'New body profile';

  @override
  String get profileBodyNameHint => 'For example, Me';

  @override
  String get profileBodyHeight => 'Height';

  @override
  String get profileBodyWeight => 'Weight';

  @override
  String get profileBodyBuild => 'Build';

  @override
  String get profileBodySkinTone => 'Skin tone';

  @override
  String get profileBirthDateNeededBody =>
      'Add a date of birth to go with the birth time.';

  @override
  String get profileBirthDateNeededTitle => 'Date of birth needed';

  @override
  String get profilePartlySavedBody =>
      'We saved your name and photo. Birth details did not save; try again later.';

  @override
  String get profilePartlySavedTitle => 'Partly saved';

  @override
  String get profileSavedBody => 'Your profile is saved.';

  @override
  String get profileChangePhoto => 'Change profile photo';

  @override
  String get profilePhotoLabel => 'Profile photo';

  @override
  String get profilePhotoHint => 'Tap to choose a new one';

  @override
  String get profileBirthDateLabel => 'Date of birth (optional)';

  @override
  String get profileBirthTimeLabel => 'Birth time (optional)';

  @override
  String get profileBirthTimeHelper => 'Makes Vedic suggestions more exact';

  @override
  String get profileBirthPlaceLabel => 'Birth place (optional)';

  @override
  String get profileBirthPlaceHint => 'For example, New Delhi, India';

  @override
  String get profileHelpContactTitle => 'Ask us anything';

  @override
  String get profileHelpContactBody =>
      'Send a message and we reply by email, usually within a day.';

  @override
  String get profileHelpContactAction => 'Contact support';

  @override
  String get profileHelpFaqTitle => 'Common questions';

  @override
  String get profileFaqAddPiecesTitle => 'How do I add pieces to my closet?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tap Add item on the Closet tab. Take a photo or pick one from your gallery; we find each piece and tag it for you.';

  @override
  String get profileFaqMatchingTitle => 'How does outfit matching work?';

  @override
  String get profileFaqMatchingBody =>
      'Open For you and pick pieces you own. We suggest what goes with them and build full outfits from your closet.';

  @override
  String get profileFaqTryOnTitle => 'Can I use my own photos for try-on?';

  @override
  String get profileFaqTryOnBody =>
      'Yes. Add a full-length photo of yourself, then choose pieces to see them on you.';

  @override
  String get profileFaqRewardsTitle => 'How do I earn rewards?';

  @override
  String get profileFaqRewardsBody =>
      'Plan and log outfits often. Streaks and achievements build as you go.';

  @override
  String get profileFaqPrivacyTitle => 'Is my closet private?';

  @override
  String get profileFaqPrivacyBody =>
      'Yes. Your closet and outfits are private unless you share a link to one outfit.';

  @override
  String get profileHelpMoreTitle => 'More help';

  @override
  String get profileHelpGuides => 'Guides';

  @override
  String get profileHelpGuidesBody => 'How each feature works';

  @override
  String get feedbackCategoryBug => 'Something broke';

  @override
  String get feedbackCategoryIdea => 'An idea';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'I need help';

  @override
  String get feedbackHintBug =>
      'What happened, and what did you expect? Steps help us fix it.';

  @override
  String get feedbackHintIdea => 'What would you like, and why?';

  @override
  String get feedbackHintGeneral =>
      'Tell us what you think, or ask a question.';

  @override
  String get feedbackAttachmentLimitBody => 'You can add up to 5 images.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limit reached';

  @override
  String get feedbackImageTooLargeBody => 'Choose an image under 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Image too large';

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackAboutLabel => 'What is it about?';

  @override
  String get feedbackSubjectLabel => 'Subject';

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
  String get authSignedIn => 'Signed in';

  @override
  String get authWelcomeBackTitle => 'Welcome back';

  @override
  String get authSignInFailed => 'Sign-in failed';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String get authSignUpFailed => 'Sign-up failed';

  @override
  String get authGoogleSignInFailed => 'Google sign-in failed';

  @override
  String get authAppleSignInFailed => 'Apple sign-in failed';

  @override
  String get authConfirmEmailTitle => 'Confirm your email';

  @override
  String get authConfirmEmailBody =>
      'Check your inbox for a confirmation email, then sign in.';

  @override
  String get authClosetReady => 'Your closet is ready.';

  @override
  String get authSignedOutTitle => 'Signed out';

  @override
  String get authSignedOutBody => 'You are signed out.';

  @override
  String get authSignOutFailed => 'Sign-out failed';

  @override
  String get authEmailSentTitle => 'Email sent';

  @override
  String get authResetLinkSent => 'Check your email for a reset link.';

  @override
  String get authPasswordUpdatedTitle => 'Password updated';

  @override
  String get authPasswordUpdated => 'Your password is updated.';

  @override
  String get authPasswordNotUpdated => 'Password not updated';

  @override
  String get authCouldNotSendEmail => 'Could not send the email';

  @override
  String get authEmailNotSent => 'Email not sent';

  @override
  String get authResendSentBody => 'We sent a new confirmation email.';

  @override
  String get outfitPreviewWithAi => 'Preview with AI';

  @override
  String get outfitNewPreview => 'Make a new preview';

  @override
  String get outfitBuilderClosetHeading => 'Your closet';

  @override
  String get outfitBuilderSearchHint => 'Search pieces';

  @override
  String get outfitClearSearch => 'Clear search';

  @override
  String get outfitBuilderAddPiecesTitle => 'Add pieces first';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits are made from the pieces in your closet.';

  @override
  String get outfitBuilderNoMatches => 'No pieces match.';

  @override
  String get outfitNameLabel => 'Outfit name';

  @override
  String get outfitNameHint => 'For example, Weekend linen';

  @override
  String get outfitPreviewSemantic => 'AI preview of the outfit';

  @override
  String get outfitChoosePieces => 'Choose pieces';

  @override
  String get outfitTapPiecesHint => 'Tap pieces below to add them.';

  @override
  String get outfitShareTooltip => 'Share';

  @override
  String get outfitSaveFavourite => 'Save to favourites';

  @override
  String get outfitPiecesHeading => 'Pieces';

  @override
  String get outfitWearHistoryEmpty =>
      'Wear it once and the dates show up here.';

  @override
  String get outfitWearHistoryTitle => 'Wear history';

  @override
  String get outfitWearHistoryError => 'Couldn\'t load the dates.';

  @override
  String get outfitWornOn => 'Worn on';

  @override
  String get outfitEditTitle => 'Edit outfit';

  @override
  String get outfitSavedPhotosFailed => 'Details saved, photos not';

  @override
  String get outfitNoPhotosBody =>
      'No photos yet. The outfit shows its pieces instead.';

  @override
  String get outfitOccasionLabel => 'Occasion';

  @override
  String get outfitOccasionNone => 'None';

  @override
  String get outfitTagsHint => 'Separate with commas';

  @override
  String get outfitDraftBody => 'Hidden from your main list';

  @override
  String get outfitPublic => 'Public';

  @override
  String get outfitPublicBody => 'Anyone with the link can see it';

  @override
  String get outfitDeleteFromDetail =>
      'Delete this outfit from its detail page.';

  @override
  String get outfitNewCollection => 'New collection';

  @override
  String get outfitNoCollectionsTitle => 'No collections yet';

  @override
  String get outfitNoCollectionsBody =>
      'Group outfits by trip, season or mood.';

  @override
  String get outfitCreateCollection => 'Create a collection';

  @override
  String get outfitAddOutfits => 'Add outfits';

  @override
  String get outfitRename => 'Rename';

  @override
  String get outfitCollectionDeleteBody => 'The outfits in it are kept.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfits not loaded';

  @override
  String get outfitRenameCollection => 'Rename collection';

  @override
  String get outfitDescriptionOptional => 'Description (optional)';

  @override
  String get outfitAllInCollection =>
      'Every outfit is already in this collection.';

  @override
  String get photoshootSubtitleUpload =>
      'Studio portraits from your own photos';

  @override
  String get photoshootSubtitleConfigure =>
      'Pick a style, a format and a count';

  @override
  String get photoshootSubtitleGenerating => 'This takes a minute or two';

  @override
  String get photoshootAddPhotosSemantic => 'Add photos from your gallery';

  @override
  String get photoshootUploadTitle => 'Add 1 to 4 photos of yourself';

  @override
  String get photoshootUploadBody => 'Tap to choose from your gallery';

  @override
  String get photoshootAddToContinue => 'Add a photo to continue';

  @override
  String get photoshootAddAnotherPhoto => 'Add another photo';

  @override
  String get photoshootTipsTitle => 'For the best results';

  @override
  String get photoshootTipsBody =>
      'Use clear, well-lit photos of your face from a few angles. Skip sunglasses and hats.';

  @override
  String get photoshootStarting => 'Starting';

  @override
  String get photoshootCancelling => 'Cancelling';

  @override
  String get photoshootFailed => 'Failed';

  @override
  String get recommendTabMatches => 'Matches';

  @override
  String get recommendTabComplete => 'Complete';

  @override
  String get recommendTabWeather => 'Weather';

  @override
  String get recommendTabColours => 'Colours';

  @override
  String get recommendTabShop => 'Shop';

  @override
  String get recommendNoMatchesTitle => 'No matches yet';

  @override
  String get recommendNoMatchesBody =>
      'Pick a piece and we\'ll find what goes with it.';

  @override
  String get recommendPickPiece => 'Pick a piece';

  @override
  String get recommendNothingMatchesTitle => 'Nothing matches these yet';

  @override
  String get recommendNothingMatchesBody =>
      'Try other pieces, or add more to your closet.';

  @override
  String get recommendChangePieces => 'Change pieces';

  @override
  String get recommendDefaultReason => 'It suits the pieces you picked.';

  @override
  String get recommendCompleteTitle => 'Complete a look';

  @override
  String get recommendCompleteBody =>
      'Pick a piece and we\'ll fill in the rest.';

  @override
  String get recommendWorking => 'Working';

  @override
  String get recommendGenerate => 'Generate';

  @override
  String get recommendChooseStyleBody => 'Choose a style, then generate.';

  @override
  String get recommendNoLooksTitle => 'No looks for these pieces';

  @override
  String get recommendNoLooksBody => 'Try another style or other pieces.';

  @override
  String get recommendDefaultLook => 'A look for your pieces';

  @override
  String get recommendNoPiecesBody => 'No pieces came back for this look.';

  @override
  String get recommendCityLabel => 'City';

  @override
  String get recommendCheck => 'Check';

  @override
  String get recommendWeatherTitle => 'What\'s the weather?';

  @override
  String get recommendWeatherBody => 'Enter your city to get picks for today.';

  @override
  String get recommendWearToday => 'Wear today';

  @override
  String get recommendWeatherNoPieces =>
      'No pieces in your closet for this weather yet.';

  @override
  String get recommendBudgetLabel => 'Budget up to';

  @override
  String get recommendLooking => 'Looking';

  @override
  String get recommendFindWhatToBuy => 'Find what to buy';

  @override
  String get recommendFillGapsTitle => 'Fill the gaps';

  @override
  String get recommendFillGapsBody =>
      'Set a budget and we\'ll suggest what your closet is missing.';

  @override
  String get recommendNoGapsTitle => 'No gaps found';

  @override
  String get recommendNoGapsBody => 'Try a bigger budget or another category.';

  @override
  String get recommendMoodEveryday => 'Everyday';

  @override
  String get recommendMoodBigMeeting => 'Big meeting';

  @override
  String get recommendDayLabel => 'Day';

  @override
  String get recommendReadingStars => 'Reading the stars';

  @override
  String get recommendGetMyColours => 'Get my colours';

  @override
  String get recommendLuckyColoursTitle => 'Your lucky colours';

  @override
  String get recommendLuckyColoursBody =>
      'Pick a day and we\'ll suggest colours and pieces for it.';

  @override
  String get recommendLuckyColoursSection => 'Lucky colours';

  @override
  String get recommendAvoidColoursSection => 'Colours to go easy on';

  @override
  String get recommendBirthDateTitle => 'Add your birth date';

  @override
  String get recommendBirthDateBody =>
      'We need your date of birth to read your colours.';

  @override
  String get recommendEditProfile => 'Edit profile';

  @override
  String get recommendNothingThisDay => 'Nothing for this day.';

  @override
  String get recommendUnnamedColour => 'Unnamed colour';

  @override
  String get recommendFromCloset => 'From your closet';

  @override
  String get recommendNoPiecesInColours => 'No pieces in these colours yet.';

  @override
  String get recommendOutfitIdeas => 'Outfit ideas';

  @override
  String get recommendNoOutfitsInColours =>
      'No full outfit in these colours yet.';

  @override
  String get recommendDefaultOutfitIdea => 'An outfit idea';

  @override
  String get recommendPickUpToThree => 'Pick up to three pieces';

  @override
  String get recommendEmptyClosetBody =>
      'Add a few pieces first, then come back for matches.';

  @override
  String get dashboardDressForDay => 'Dress for the day ahead.';

  @override
  String get dashboardOutfitOfDay => 'Outfit of the day';

  @override
  String get dashboardFreshLook => 'A fresh look';

  @override
  String get subscriptionManageInStoreTitle => 'Manage in the store';

  @override
  String get subscriptionManageInStoreBody =>
      'This plan is billed through the store. Manage it in your store account settings.';

  @override
  String get subscriptionCancelledTitle => 'Subscription cancelled';

  @override
  String get subscriptionCancelledBody =>
      'Your plan stays active until the end of this billing period.';

  @override
  String get subscriptionCancelFailedTitle => 'Could not cancel';

  @override
  String get subscriptionCouldNotOpenTitle => 'Could not open';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Could not open billing management.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Could not open the link.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Could not load your link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Could not load your referral link. Try again.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copied';

  @override
  String get subscriptionReferralCopiedBody => 'Referral link copied.';

  @override
  String get subscriptionReferralShareSubject => 'Try FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Join FitCheck AI and we both get a month of Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copied';

  @override
  String get subscriptionShareUnavailableBody =>
      'Sharing is not available, so we copied the link.';

  @override
  String get subscriptionShareFailedTitle => 'Could not share';

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
  String get giftClaimFailedTitle => 'Could not claim the gift';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gifts for you',
      one: 'A gift for you',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 month',
      '12': '1 year',
      'other': '$months months',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining left',
      one: '1 left',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration of FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender sent you $duration of FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'A FitCheck Pro gift for $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'From $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'For $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'From $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'your recipient';

  @override
  String get giftPreviewPlaceholderSender => 'you';

  @override
  String get settingsSavedTitle => 'Saved';

  @override
  String get settingsNotSavedTitle => 'Not saved';

  @override
  String get settingsAiChooseProviderBody => 'Choose a provider.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'A custom provider needs an API URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Enter an API key.';

  @override
  String get settingsAiSavedBody => 'Your AI settings are saved.';

  @override
  String get settingsAiMissingDetailsTitle => 'Missing details';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Enter an API URL and a chat model to test.';

  @override
  String get settingsAiKeyNeededTitle => 'API key needed';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Enter your API key to test. Your saved key stays private.';

  @override
  String get settingsAiKeyToTestBody => 'Enter your API key to test.';

  @override
  String get settingsAiConnectedTitle => 'Connected';

  @override
  String get settingsAiConnectedBody => 'The connection works.';

  @override
  String get settingsAiTestFailedTitle => 'Test failed';

  @override
  String get settingsPreferencesSavedBody => 'Your preferences are saved.';

  @override
  String get settingsPasswordNotChangedTitle => 'Password not changed';

  @override
  String get settingsOAuthPasswordBody =>
      'This account signs in with Google or Apple. Use \"Forgot password\" to set a password first.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Current password is incorrect.';

  @override
  String get settingsExportReadyTitle => 'Export ready';

  @override
  String get settingsExportReadyBody =>
      'Your data export is ready to download.';

  @override
  String get settingsLinkCopiedTitle => 'Link copied';

  @override
  String get settingsExportClipboardBody =>
      'We could not open your browser, so we copied the download link. Paste it into a browser soon: it expires.';

  @override
  String get settingsExportFailedTitle => 'Export failed';

  @override
  String get settingsAccountNotDeletedTitle => 'Account not deleted';

  @override
  String photoshootPhotoLimit(int max) {
    return 'You can add up to $max photos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Photo limit';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Add at least one photo.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'No photos';

  @override
  String get photoshootDescribeLookBody => 'Describe the look you want.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt needed';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Preparing your photos';

  @override
  String get photoshootStatusGenerating => 'Generating';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current of $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generation failed.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready ready, $failed failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Partly done';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos are ready.',
      one: '1 photo is ready.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'We lost the connection. Please try again.';

  @override
  String get photoshootCouldNotCancelTitle => 'Could not cancel';

  @override
  String get photoshootRetryFailedTitle => 'Retry failed';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Photo $number is ready.';
  }

  @override
  String get photoshootReplacedTitle => 'Replaced';

  @override
  String get photoshootSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get photoshootSavedTitle => 'Saved';

  @override
  String get photoshootNotSavedTitle => 'Not saved';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count photos are in your gallery.',
      one: '1 photo is in your gallery.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved of $total saved.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Some photos not saved';

  @override
  String get tryonConsentFeatureLabel => 'Virtual Try-On';

  @override
  String get tryonAvatarUpdatedBody => 'Your photo is updated.';

  @override
  String get tryonSavedTitle => 'Saved';

  @override
  String get tryonUploadFailedTitle => 'Upload failed';

  @override
  String get tryonChooseGarmentFirstBody => 'Choose a garment photo first.';

  @override
  String get tryonNoGarmentTitle => 'No garment';

  @override
  String get tryonWaitForUploadBody =>
      'Wait for your photo to finish uploading.';

  @override
  String get tryonStillUploadingTitle => 'Still uploading';

  @override
  String get tryonAddYourPhotoFirstBody => 'Add a photo of yourself first.';

  @override
  String get tryonReadyBody => 'Your try-on is ready.';

  @override
  String get tryonFailedTitle => 'Try-on failed';

  @override
  String get tryonSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get tryonNotSavedTitle => 'Not saved';

  @override
  String get calendarEventAddedBody => 'Event added';

  @override
  String get calendarEventPlannedTitle => 'Planned';

  @override
  String get calendarEventSavedBody => 'Event saved';

  @override
  String get calendarSavedTitle => 'Saved';

  @override
  String get calendarEventNotSavedTitle => 'Event not saved';

  @override
  String get calendarEventRemovedBody => 'Event removed';

  @override
  String get calendarEventDeletedTitle => 'Deleted';

  @override
  String get calendarEventNotDeletedTitle => 'Event not deleted';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit not linked';

  @override
  String get calendarLinkedTitle => 'Linked';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit not removed';

  @override
  String get calendarOutfitRemovedBody => 'Outfit removed';

  @override
  String get calendarDisconnectedBody => 'Calendar disconnected';

  @override
  String get calendarDisconnectedTitle => 'Disconnected';

  @override
  String get calendarNotDisconnectedTitle => 'Calendar not disconnected';

  @override
  String get calendarTodayLabel => 'today';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit linked';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" will be removed.';
  }

  @override
  String get calendarThisAppLabel => 'This app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Syncing with $provider is not available yet. You can still add events here.';
  }

  @override
  String get calendarWeekdaySunShort => 'Sun';

  @override
  String get calendarWeekdayMonShort => 'Mon';

  @override
  String get calendarWeekdayTueShort => 'Tue';

  @override
  String get calendarWeekdayWedShort => 'Wed';

  @override
  String get calendarWeekdayThuShort => 'Thu';

  @override
  String get calendarWeekdayFriShort => 'Fri';

  @override
  String get calendarWeekdaySatShort => 'Sat';

  @override
  String get calendarWeekdayMonday => 'Monday';

  @override
  String get calendarWeekdayTuesday => 'Tuesday';

  @override
  String get calendarWeekdayWednesday => 'Wednesday';

  @override
  String get calendarWeekdayThursday => 'Thursday';

  @override
  String get calendarWeekdayFriday => 'Friday';

  @override
  String get calendarWeekdaySaturday => 'Saturday';

  @override
  String get calendarWeekdaySunday => 'Sunday';

  @override
  String get outfitSavedToFavouritesBody => 'Saved to favourites';

  @override
  String get outfitRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get outfitNotSavedTitle => 'Not saved';

  @override
  String get outfitLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get outfitNicePickTitle => 'Nice pick';

  @override
  String get outfitRemovedBody => 'Outfit removed.';

  @override
  String get outfitDeletedTitle => 'Deleted';

  @override
  String get outfitNotDeletedTitle => 'Not deleted';

  @override
  String get outfitDuplicatedBody => 'A copy is in your outfits.';

  @override
  String get outfitDuplicatedTitle => 'Duplicated';

  @override
  String get outfitNotDuplicatedTitle => 'Not duplicated';

  @override
  String get outfitNotSharedTitle => 'Not shared';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" is ready.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collection not created';

  @override
  String get outfitCollectionUpdatedBody => 'Collection updated.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collection not updated';

  @override
  String get outfitCollectionDeletedBody => 'Collection deleted.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collection not deleted';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits added.',
      one: '1 outfit added.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits not added';

  @override
  String get outfitPreviewNotCreatedTitle => 'Preview not created';

  @override
  String get outfitGiveNameBody => 'Give the outfit a name.';

  @override
  String get outfitNameMissingTitle => 'Name';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Choose at least one piece.';

  @override
  String outfitCreatedBody(String name) {
    return '$name is in your outfits.';
  }

  @override
  String get outfitSavedTitle => 'Saved';

  @override
  String get wardrobeAddedToFavouritesBody => 'Added to favourites';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get wardrobeNotSavedTitle => 'Not saved';

  @override
  String get wardrobeLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Removed from your closet.';

  @override
  String get wardrobeDeletedTitle => 'Deleted';

  @override
  String get wardrobeNotDeletedTitle => 'Not deleted';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces removed from your closet.',
      one: '1 piece removed from your closet.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI Wardrobe Extraction';

  @override
  String get itemAddScanJobLabel => 'Scan';

  @override
  String get itemAddFoundEarlierBody => 'Found in an earlier scan';

  @override
  String get itemAddLookingAtPhoto => 'Looking at your photo';

  @override
  String get itemAddExtractionFailedBody => 'Extraction failed';

  @override
  String get itemAddJobFailedBody => 'Job failed';

  @override
  String get itemAddConnectionLostBody => 'Connection was lost. Try again.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Connection lost while processing.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Piece $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Piece';

  @override
  String get itemAddNotCancelledTitle => 'Not cancelled';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces are in your closet.',
      one: '1 piece is in your closet.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved of $total pieces saved. Tap save to try the rest again.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Some pieces not saved';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Choose at least one photo.';

  @override
  String get batchPhotoUnreadableBody => 'This photo could not be read.';

  @override
  String get batchNoPhotosReadableBody =>
      'None of these photos could be read. Try other photos.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'We lost the connection while working. Try again.';

  @override
  String get batchNotCancelledTitle => 'Not cancelled';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Post links are not supported. Enter a profile link.';

  @override
  String get batchLinkSpacesBody => 'Links cannot contain spaces.';

  @override
  String get batchEnterProfileLinkBody =>
      'Enter an Instagram or Facebook profile link.';

  @override
  String get batchEnterProfileLinkShortBody => 'Enter a profile link.';

  @override
  String get batchSignInPageNotOpenBody =>
      'The sign-in page did not open. Try again.';

  @override
  String get batchSignInBrowserBody =>
      'Sign in in your browser, then come back to FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Connect your account';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Enter the code from your authenticator app.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram wants a security check. Sign in in your browser first.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Enter your username and password again.';

  @override
  String get batchSignInFailedBody =>
      'Sign-in failed. Check your username and password.';

  @override
  String get batchSignInToKeepImportingBody => 'Sign in to keep importing.';

  @override
  String get batchAccountNotConnectedBody => 'Your account was not connected.';

  @override
  String get batchAccountConnectedTitle => 'Account connected';

  @override
  String get batchNotConnectedTitle => 'Not connected';

  @override
  String get batchImportConnectionLostBody =>
      'We lost the connection to the import. Refresh to check it.';

  @override
  String batchPickUpToBody(int max) {
    return 'Pick up to $max photos. We find the pieces.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count of $total photos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparing photo $done of $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Find pieces in $count photos',
      one: 'Find pieces in 1 photo',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Your $platform account uses two-step sign-in. Enter the 6-digit code from your authenticator app.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'This $platform profile is private or needs a sign-in to show its photos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Connect with $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos found so far',
      one: '1 photo found so far',
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
    return '$processed of $total processed · $added added · $waiting waiting · $skipped skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Scanning photo $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Photo $number is next';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Photo $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces found',
      one: '1 piece found',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos were added to your closet.',
      one: '1 photo was added to your closet.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count more studio photos on the way. You can save what is ready, or leave — we will let you know.',
      one:
          '1 more studio photo on the way. You can save what is ready, or leave — we will let you know.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Not saved yet: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces pieces',
      one: '1 piece',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos photos',
      one: '1 photo',
    );
    return '$_temp0 from $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen chosen. Tap a piece to skip it.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saving $count pieces',
      one: 'Saving 1 piece',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count pieces',
      one: 'Save 1 piece',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Your body profile is saved.';

  @override
  String get bodyProfileSavedTitle => 'Saved';

  @override
  String get bodyProfileNotSavedTitle => 'Not saved';

  @override
  String get bodyProfileSetDefaultBody => 'Set as your default profile.';

  @override
  String get bodyProfileDeletedBody => 'Body profile deleted.';

  @override
  String get bodyProfileDeletedTitle => 'Deleted';

  @override
  String get bodyProfileNotDeletedTitle => 'Not deleted';

  @override
  String get feedbackNotSentTitle => 'Not sent';

  @override
  String get feedbackSentBody =>
      'Thanks. We read every message and reply if we need more.';

  @override
  String get feedbackSentTitle => 'Feedback sent';

  @override
  String get recommendUnnamedPiece => 'Unnamed piece';

  @override
  String get recommendEnterCityBody =>
      'Enter your city to get picks for the weather.';

  @override
  String get recommendWhichCityTitle => 'Which city?';

  @override
  String get aiConsentSheetTitle => 'Sharing photos with an AI service';

  @override
  String get aiConsentSheetBody =>
      'To create your try-on and photoshoot images, FitCheck AI sends the photos you provide (including images of your face and body) to a trusted third-party AI provider (such as OpenAI or Google Gemini) for processing. They generate your images and do not use them to train their models under our terms. Photos are transmitted securely and never shared for advertising.';

  @override
  String get aiConsentSheetPermission =>
      'By continuing, you give explicit permission to share your photos with these AI providers for image generation.';

  @override
  String get skeletonsLoadMoreFailed => 'Couldn\'t load more.';

  @override
  String get jobsPiecesReadyTitle => 'Your pieces are ready';

  @override
  String get jobsScanStoppedTitle => 'The scan stopped';

  @override
  String get jobsNothingSavedBody => 'Nothing was saved. Try again.';

  @override
  String get jobsPhotoUploadFailedBody => 'Photo upload failed.';

  @override
  String get authGoogleSignInStartFailed =>
      'Unable to start Google Sign-In. Please try again.';

  @override
  String get referralAppliedTitle => 'Referral Applied!';

  @override
  String get billingStoreUnavailableBody =>
      'Store purchases are not available on this device.';

  @override
  String get billingPurchaseProcessingBody =>
      'This purchase is still being processed. Reopen the app in a minute to see your plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatar upload did not return an image URL.';

  @override
  String get rewardsDayStreakLabel => 'day streak';

  @override
  String rewardsBestStreak(int days) {
    return 'Best $days days';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission Access Needed';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Access to $permission is currently denied. Open Settings to allow it, then come back and try again.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Step $step of 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Remove image $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Remove image $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Email $email. We review reports within 24 hours.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Remove $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Add to \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" is removed. Its pieces stay in your closet.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Show all $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count left today';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Photo $index failed';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected of $max photos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape build · $tone skin';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: not set';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked of $max picked';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Remove $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency priority';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'This plan is billed through the $store. Change or cancel it in your $store account settings.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Manage in the $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current of $max used';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'About ${seconds}s left';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done of $total studio photos ready';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready of $total studio photos ready. Tap a piece to skip it.';
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
  String get profileFieldNotSet => 'No';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPhotoshoot => 'Photoshoot';

  @override
  String get tabCloset => 'Closet';

  @override
  String get tabOutfits => 'Outfits';

  @override
  String get tabMore => 'More';

  @override
  String get actionAddItem => 'Add item';

  @override
  String get actionCreateOutfit => 'Create outfit';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionContinue => 'Continue';

  @override
  String get stateLoading => 'Loading';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorBody =>
      'Try again. If it keeps failing, contact support.';

  @override
  String get stateOfflineTitle => 'You are offline';

  @override
  String get stateOfflineBody =>
      'Reconnect to sync your closet and generate outfits.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsPlanBilling => 'Plan and billing';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsUnits => 'Measurement units';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPrivacySection => 'Privacy and data';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete your account?';

  @override
  String get settingsDeleteAccountBody =>
      'This removes your closet, outfits, photos and profile. It cannot be undone.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Metric (cm, kg)';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageSystemBody =>
      'FitCheck AI follows your phone\'s language.';

  @override
  String get languageSearchHint => 'Search languages';

  @override
  String get languageCurrent => 'Current';

  @override
  String get languageReviewNote =>
      'This translation is new. Tell us if something reads wrong.';

  @override
  String get languageChanged => 'Language updated';

  @override
  String get paywallTitle => 'Choose your plan';

  @override
  String get paywallTrialBadge => '1 month free';

  @override
  String get paywallTrialTitle => 'Your first month of Pro is free';

  @override
  String get paywallTrialBody =>
      'Upload your whole closet at once. Add pieces as you go after that.';

  @override
  String get paywallFreeForeverTitle => 'Free forever';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'No card needed. Every month you get $uploads AI uploads, $outfits outfits and $images photoshoot images a day.';
  }

  @override
  String get paywallCtaTrial => 'Start my free month';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Upgrade to $plan';
  }

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallManage => 'Manage subscription';

  @override
  String get paywallTerms => 'Terms of use';

  @override
  String get paywallPrivacy => 'Privacy policy';

  @override
  String get paywallPerMonth => 'per month';

  @override
  String get paywallPerYear => 'per year';

  @override
  String get paywallBestValue => 'Best value';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Free trial for new subscribers only. After the trial, Pro renews at $price unless cancelled at least 24 hours before it ends.';
  }

  @override
  String get introTitle => 'Your closet, finally organised';

  @override
  String get introBody =>
      'Photograph your clothes once. Get outfit ideas, try-on previews and studio photos from what you already own.';

  @override
  String get introStart => 'Get started';

  @override
  String get introHaveAccount => 'I already have an account';

  @override
  String get introSkip => 'Skip';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authOrDivider => 'or';

  @override
  String get wardrobeTitle => 'Closet';

  @override
  String get wardrobeEmptyTitle => 'Your closet is empty';

  @override
  String get wardrobeEmptyBody =>
      'Add your first piece, or upload a photo of the whole rail at once.';

  @override
  String get wardrobeAddFirst => 'Add your first item';

  @override
  String get wardrobeSearchHint => 'Search your closet';

  @override
  String get categoryTops => 'Tops';

  @override
  String get categoryBottoms => 'Bottoms';

  @override
  String get categoryShoes => 'Shoes';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get categoryOuterwear => 'Outerwear';

  @override
  String get categorySwimwear => 'Swimwear';

  @override
  String get categoryActivewear => 'Activewear';

  @override
  String get categoryOther => 'Other';

  @override
  String get conditionClean => 'Clean';

  @override
  String get conditionDirty => 'Dirty';

  @override
  String get conditionLaundry => 'In laundry';

  @override
  String get conditionRepair => 'Needs repair';

  @override
  String get conditionDonate => 'To donate';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonFall => 'Fall';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get seasonAll => 'All season';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sporty';

  @override
  String get styleBohemian => 'Bohemian';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalist';

  @override
  String get styleRomantic => 'Romantic';

  @override
  String get styleEdgy => 'Edgy';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artsy';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Other';

  @override
  String get occasionWork => 'Work';

  @override
  String get occasionDateNight => 'Date night';

  @override
  String get occasionTravel => 'Travel';

  @override
  String get occasionWedding => 'Wedding';

  @override
  String get occasionGym => 'Gym';

  @override
  String get occasionWeekend => 'Weekend';

  @override
  String get occasionParty => 'Party';

  @override
  String get occasionInterview => 'Interview';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorWhite => 'White';

  @override
  String get colorGrey => 'Grey';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorBrown => 'Brown';

  @override
  String get colorRed => 'Red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Enjoying FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'A quick rating helps other people find their style.';

  @override
  String get ratingPromptYes => 'Rate the app';

  @override
  String get ratingPromptNo => 'Not now';

  @override
  String get closetNoMatchesTitle => 'No pieces match';

  @override
  String get closetNoMatchesBody => 'Try fewer filters or another search.';

  @override
  String get closetClearFilters => 'Clear filters';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces',
      one: '1 piece',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Loading your pieces';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Delete selected';

  @override
  String get closetCancelSelection => 'Cancel selection';

  @override
  String get closetCloseSearch => 'Close search';

  @override
  String get closetShowGrid => 'Show as grid';

  @override
  String get closetShowList => 'Show as list';

  @override
  String get closetShowRows => 'Show as rows';

  @override
  String get closetStatsTitle => 'Closet stats';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count pieces?',
      one: 'Delete 1 piece?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Outfits that use them lose these pieces.';

  @override
  String get closetSortBy => 'Sort by';

  @override
  String get closetFavourites => 'Favourites';

  @override
  String get closetFavourite => 'Favourite';

  @override
  String get closetUnfavourite => 'Remove favourite';

  @override
  String get closetWoreToday => 'Wore it today';

  @override
  String closetWornTimes(int count) {
    return 'Worn $count×';
  }

  @override
  String get closetCategoryLabel => 'Category';

  @override
  String get closetUseCaseLabel => 'Use case';

  @override
  String get closetAnyUseCase => 'Any';

  @override
  String get closetOtherUseCase => 'Other use case';

  @override
  String get closetOtherUseCaseHint => 'For example, brunch';

  @override
  String get closetUseUseCase => 'Use this';

  @override
  String get closetClearAll => 'Clear all';

  @override
  String get sortNewest => 'Newest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortName => 'Name (A–Z)';

  @override
  String get sortMostWorn => 'Most worn';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Date';

  @override
  String get useCaseDinner => 'Dinner';

  @override
  String get useCaseLunch => 'Lunch';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionSort => 'Sort';

  @override
  String get actionAll => 'All';

  @override
  String get dashboardStartClosetTitle => 'Start your closet';

  @override
  String get dashboardStartClosetBody =>
      'Photograph a few pieces. We tag them for you.';

  @override
  String get dashboardPieces => 'pieces';

  @override
  String get dashboardOutfits => 'outfits';

  @override
  String get dashboardDayStreak => 'day streak';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count this month';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Best $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favourites',
      one: '1 favourite',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved outfits',
      one: '1 saved outfit',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String get setupSkip => 'Skip setup';

  @override
  String get setupWhoTitle => 'Who are we styling?';

  @override
  String get setupWhoBody =>
      'Sets the model for try-on and photoshoots. You can change it in your profile.';

  @override
  String get setupStyleTitle => 'What do you wear most?';

  @override
  String get setupStyleBody => 'Pick any. Outfit ideas start from these.';

  @override
  String get setupClosetTitle => 'Add your first pieces.';

  @override
  String get setupClosetBody =>
      'Photograph a few clothes, or a pile of them. Each piece is cut out and filed for you.';

  @override
  String get setupAddClothes => 'Add clothes';

  @override
  String get setupStylesLabel => 'Styles';

  @override
  String get setupOccasionsLabel => 'Occasions';

  @override
  String get setupSkipStep => 'Skip';

  @override
  String get setupLater => 'Later';

  @override
  String get setupSaveError => 'Could not save';

  @override
  String get genderWomen => 'Women';

  @override
  String get genderMen => 'Men';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get outfitEmptyTitle => 'No outfits yet';

  @override
  String get outfitEmptyBody =>
      'Pair pieces from your closet and save the look.';

  @override
  String get outfitNoMatchesTitle => 'No outfits match';

  @override
  String get outfitSearchHint => 'Search your outfits';

  @override
  String get outfitLoading => 'Loading your outfits';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits',
      one: '1 outfit',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Style and season';

  @override
  String get outfitCollections => 'Collections';

  @override
  String get outfitDuplicate => 'Duplicate';

  @override
  String get outfitDeleteTitle => 'Delete this outfit?';

  @override
  String get outfitDeleteBody => 'Its pieces stay in your closet.';

  @override
  String get outfitDrafts => 'Drafts';

  @override
  String get outfitDraft => 'Draft';

  @override
  String get filterStyle => 'Style';

  @override
  String get filterSeason => 'Season';

  @override
  String get itemDetailDeleteTitle => 'Delete this piece?';

  @override
  String get itemDetailDeleteBody => 'Outfits that use it lose this piece.';

  @override
  String get itemAddFavourite => 'Add to favourites';

  @override
  String itemSize(String size) {
    return 'Size $size';
  }

  @override
  String get itemColours => 'Colours';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Pattern';

  @override
  String get itemUseCases => 'Use cases';

  @override
  String get itemKeptIn => 'Kept in';

  @override
  String get itemPrice => 'Price';

  @override
  String get itemBought => 'Bought';

  @override
  String get itemTags => 'Tags';

  @override
  String get itemAdded => 'Added';

  @override
  String get itemTimesWornLabel => 'times worn';

  @override
  String get itemLastWornLabel => 'last worn';

  @override
  String get itemNeverWorn => 'Never';

  @override
  String get authEntryBody =>
      'Every piece you own, styled by AI. Plan outfits, try them on, shoot them.';

  @override
  String get authCreateCloset => 'Create your closet';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSignInBody => 'Sign in to open your closet.';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authCreateClosetBody =>
      'It takes a minute. Your first items are free.';

  @override
  String get authName => 'Name';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authReferralCode => 'Referral code (optional)';

  @override
  String get authResetTitle => 'Reset your password';

  @override
  String get authResetBody => 'We will email you a link to choose a new one.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authEnterEmail => 'Enter your email';

  @override
  String get authEnterValidEmail => 'Enter a valid email';

  @override
  String get authEnterPassword => 'Enter your password';

  @override
  String get authPasswordTooShort => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authNewHere => 'New here?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirm $email before you sign in. Check your inbox.';
  }

  @override
  String get authResendEmail => 'Send it again';

  @override
  String get authResendingEmail => 'Sending…';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authEnterName => 'Enter your name';

  @override
  String get authChoosePassword => 'Choose a password';

  @override
  String get authHaveAccount => 'Have an account?';

  @override
  String get authCodeAccepted => 'Code accepted';

  @override
  String get authCodeNotFound => 'Code not found';

  @override
  String authReferralFrom(String name) {
    return 'From $name. You both get a month free.';
  }

  @override
  String get authReferralInvalid => 'We could not find this code.';

  @override
  String authResetSent(String email) {
    return 'Sent to $email. Open the link on this phone.';
  }

  @override
  String get introSlide1Title => 'Snap your closet once.';

  @override
  String get introSlide1Body =>
      'Photograph a pile of clothes. Every piece is cut out and filed for you.';

  @override
  String get introSlide2Title => 'Get dressed faster.';

  @override
  String get introSlide2Body =>
      'Outfits from what you own, matched to your plans and the weather.';

  @override
  String get introSlide3Title => 'See it before you wear it.';

  @override
  String get introSlide3Body =>
      'Try looks on your own photo, or shoot them like a campaign.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsTemperature => 'Temperature';

  @override
  String get settingsEmailUpdates => 'Email updates';

  @override
  String get settingsEmailUpdatesBody => 'News and tips by email';

  @override
  String get settingsOutfitReminders => 'Outfit reminders';

  @override
  String get settingsOutfitRemindersBody => 'A nudge to log what you wore';

  @override
  String get settingsWeeklySummary => 'Weekly summary';

  @override
  String get settingsWeeklySummaryBody => 'Your week in outfits';

  @override
  String get settingsStyleSection => 'Style';

  @override
  String get settingsPreferredStyles => 'Styles you like';

  @override
  String get settingsPreferredColours => 'Colours you like';

  @override
  String get settingsNoneChosen => 'None chosen';

  @override
  String get settingsPlanAiSection => 'Plan and AI';

  @override
  String get settingsPlanBillingBody => 'Plan, usage and upgrades';

  @override
  String get settingsPlanUsageBody => 'Plan and usage';

  @override
  String get settingsInviteFriends => 'Invite friends';

  @override
  String get settingsInviteFriendsBody =>
      'A free month for each friend who joins';

  @override
  String get settingsAiProvider => 'AI provider';

  @override
  String get settingsAiProviderBody =>
      'Use your own model for tagging and images';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsPrivacyTerms => 'Privacy and terms';

  @override
  String get settingsReportProblem => 'Report a problem';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsExportData => 'Export your data';

  @override
  String get settingsExportBody =>
      'We prepare a file with everything you saved and open the download.';

  @override
  String get settingsExportAction => 'Export';

  @override
  String get settingsCurrentPassword => 'Current password';

  @override
  String get settingsNewPassword => 'New password';

  @override
  String get settingsConfirmNewPassword => 'Confirm new password';

  @override
  String get settingsEnterCurrentPassword => 'Enter your current password';

  @override
  String get settingsEnterNewPassword => 'Enter a new password';

  @override
  String get settingsPasswordMin8 => 'Use at least 8 characters';

  @override
  String get settingsPasswordNeedsUpper => 'Add an uppercase letter';

  @override
  String get settingsPasswordNeedsLower => 'Add a lowercase letter';

  @override
  String get settingsPasswordNeedsDigit => 'Add a number';

  @override
  String get settingsPasswordsNoMatch => 'The passwords do not match';

  @override
  String get settingsChangeAction => 'Change';

  @override
  String get itemAddSnapTitle => 'Snap a piece';

  @override
  String get itemAddSnapBody =>
      'We find every piece in the photo and make a clean studio shot of each.';

  @override
  String get itemAddCamera => 'Take a photo';

  @override
  String get itemAddGallery => 'Choose from gallery';

  @override
  String get itemAddOtherWays => 'Other ways to add';

  @override
  String get itemAddSeveral => 'Add several photos';

  @override
  String get itemAddSeveralBody => 'Up to 50 at once';

  @override
  String get itemAddImportProfile => 'Import from a profile';

  @override
  String get itemAddImportProfileBody => 'Instagram or Facebook';

  @override
  String get itemAddEnterDetails => 'Enter details yourself';

  @override
  String get itemAddEnterDetailsBody => 'No photo needed';

  @override
  String get itemManualIntro =>
      'Only a name is needed. Add the rest now or later.';

  @override
  String get itemManualNameHint => 'For example, blue cotton tee';

  @override
  String get itemManualEnterName => 'Enter a name';

  @override
  String get itemManualNotes => 'Notes';

  @override
  String get itemManualBrand => 'Brand';

  @override
  String get itemManualSize => 'Size';

  @override
  String get itemManualEnterNumber => 'Enter a number';

  @override
  String get itemManualSavePiece => 'Save piece';

  @override
  String get itemManualSaving => 'Saving';

  @override
  String get itemManualSavedTitle => 'Saved';

  @override
  String itemManualSavedBody(String name) {
    return '$name is in your closet.';
  }

  @override
  String get itemManualNotSaved => 'Not saved';

  @override
  String get itemManualAddUseCase => 'Add a use case';

  @override
  String get itemManualAddUseCaseAction => 'Add use case';

  @override
  String get itemPhotos => 'Photos';

  @override
  String get itemAddPhotos => 'Add photos';

  @override
  String get itemNoPhotoYet => 'No photo yet. You can save without one.';

  @override
  String get itemRemovePhoto => 'Remove photo';

  @override
  String get itemRemovePiece => 'Remove piece';

  @override
  String get filterConditionLabel => 'Condition';

  @override
  String get photoshootStepPhotos => 'Photos';

  @override
  String get photoshootStepSetup => 'Setup';

  @override
  String get photoshootStepCreating => 'Creating';

  @override
  String get photoshootStepResults => 'Results';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Step $current of $total, $name';
  }

  @override
  String get photoshootOneFailed => 'One photo failed. Retry it below.';

  @override
  String photoshootManyFailed(int count) {
    return '$count photos failed. Retry each one below.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'How many';

  @override
  String get photoshootYourPrompt => 'Your prompt';

  @override
  String get photoshootPromptHint => 'Golden hour on a rooftop, linen shirt';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Create $count photos',
      one: 'Create 1 photo',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'photos',
      one: 'photo',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown => 'We couldn\'t check today\'s limit.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return '$plan plan: $remaining of $limit left today';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Free';

  @override
  String get photoshootGallery => 'Gallery';

  @override
  String get photoshootUseCamera => 'Use camera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Remove photo $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'No photos came back';

  @override
  String get photoshootNoPhotosBody =>
      'The shoot finished without images. Try again.';

  @override
  String get photoshootNewStyle => 'New style';

  @override
  String get photoshootNewPhotos => 'New photos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Open photo $number';
  }

  @override
  String get photoshootReportPhoto => 'Report photo';

  @override
  String get photoshootSaveToGallery => 'Save to gallery';

  @override
  String get actionUpgrade => 'Upgrade';

  @override
  String get referralLimitTitle => 'You\'ve used today\'s photos';

  @override
  String get referralLimitBody =>
      'Your free photos come back tomorrow. Refer a friend and you both get a month of Pro free.';

  @override
  String get referralLimitRefer => 'Refer a friend';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Dating app';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Aesthetic';

  @override
  String get photoshootUseCustom => 'Your own prompt';

  @override
  String get photoshootDescLinkedin => 'Sharp headshots for work';

  @override
  String get photoshootDescDating => 'Relaxed, warm and natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, high-fashion looks';

  @override
  String get photoshootDescInstagram => 'Lifestyle shots for your feed';

  @override
  String get photoshootDescAesthetic => 'Moody, artistic frames';

  @override
  String get photoshootDescCustom => 'Describe the look you want';

  @override
  String get aspectSquare => 'Square';

  @override
  String get aspectPortrait => 'Portrait';

  @override
  String get aspectLandscape => 'Landscape';

  @override
  String get aspectTall => 'Tall';

  @override
  String get aspectWide => 'Wide';

  @override
  String get tryOnAppBar => 'Virtual try-on';

  @override
  String get tryOnYourPhoto => 'Your photo';

  @override
  String get tryOnGarment => 'Garment';

  @override
  String get tryOnUploadingPhoto => 'Uploading your photo';

  @override
  String get tryOnAddPhotoPrompt => 'Add a full-body photo of yourself';

  @override
  String get tryOnBodyPhotoHint => 'A full-body photo works best';

  @override
  String get tryOnAddPhoto => 'Add photo';

  @override
  String get tryOnChangePhoto => 'Change photo';

  @override
  String get tryOnPhotoLoadFailed => 'We couldn\'t load your photo.';

  @override
  String get tryOnChooseGarment => 'Choose a garment photo';

  @override
  String get tryOnChooseOneGarment => 'Choose one garment photo';

  @override
  String get tryOnGarmentHint => 'A flat lay or a hanger shot works best';

  @override
  String get tryOnChange => 'Change';

  @override
  String get tryOnCamera => 'Camera';

  @override
  String get tryOnRemove => 'Remove';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Style';

  @override
  String get tryOnBackground => 'Background';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Dressing you up. This takes about half a minute.';

  @override
  String get tryOnEmptyResult => 'Your try-on appears here';

  @override
  String get tryOnReportImage => 'Report image';

  @override
  String get tryOnCreating => 'Creating';

  @override
  String get tryOnTryAgain => 'Try again';

  @override
  String get tryOnCreate => 'Create try-on';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio white';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio grey';

  @override
  String get tryOnBackgroundUrban => 'Urban street';

  @override
  String get tryOnBackgroundNature => 'Nature';

  @override
  String get tryOnBackgroundMinimal => 'Minimal';

  @override
  String get tryOnPoseFront => 'Standing front';

  @override
  String get tryOnPoseSide => 'Standing side';

  @override
  String get tryOnPoseWalking => 'Walking';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardWelcome => 'Welcome';

  @override
  String get dashboardOpenProfile => 'Open profile';

  @override
  String get dashboardRailToday => 'Today';

  @override
  String get dashboardRailRecently => 'Recently';

  @override
  String get dashboardActivityEmpty => 'New pieces and outfits show up here.';

  @override
  String get quickAddPiece => 'Add a piece';

  @override
  String get quickAddPieceBody => 'Photograph and tag';

  @override
  String get quickBuildOutfit => 'Build an outfit';

  @override
  String get quickBuildOutfitBody => 'Mix your pieces';

  @override
  String get quickForYou => 'For you';

  @override
  String get quickForYouBody => 'Picks for today';

  @override
  String get quickPlanWeek => 'Plan the week';

  @override
  String get quickPlanWeekBody => 'Outfits by date';

  @override
  String get referralBannerUrgent => 'Running low? Invite a friend.';

  @override
  String get referralBannerTitle => 'Give a month, get a month.';

  @override
  String get referralBannerBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get referralBannerDismiss => 'Dismiss for a week';

  @override
  String get referralBannerShare => 'Share invite';

  @override
  String get referralBannerCopy => 'Copy link';

  @override
  String get itemEditPieceTitle => 'Edit piece';

  @override
  String get itemEditDescriptionLabel => 'Description';

  @override
  String get itemEditNotSaved => 'Not saved';

  @override
  String get itemEditSavedTitle => 'Saved';

  @override
  String get itemEditSavedBody => 'Your changes are saved.';

  @override
  String get itemEditSavedStalePhotos => 'Saved — photos may be out of date';

  @override
  String get itemEditRemovePieceHint => 'Delete this piece from the item page.';

  @override
  String get itemEditNoPhotos =>
      'No photos yet. Add one from your gallery or camera.';

  @override
  String get itemEditKeepPhoto => 'Keep photo';

  @override
  String get itemEditRemoved => 'Removed';

  @override
  String get itemEditAddUseCaseAction => 'Add';

  @override
  String get statsNoStatsTitle => 'No stats yet';

  @override
  String get statsNoStatsBody =>
      'Add a few pieces and your closet mix shows up here.';

  @override
  String get statsByCategory => 'By category';

  @override
  String get statsTotalValue => 'total value';

  @override
  String get statsMostWorn => 'Worn the most';

  @override
  String get statsLeastWorn => 'Waiting for a turn';

  @override
  String get statsUnnamedPiece => 'Unnamed piece';

  @override
  String get jobsTitle => 'Scans';

  @override
  String get jobsEmptyTitle => 'No scans yet';

  @override
  String get jobsEmptyBody =>
      'Snap a piece and send it to the background — it keeps working here.';

  @override
  String get jobsNotCancelled => 'Not cancelled';

  @override
  String get jobsResume => 'Resume';

  @override
  String get jobsReview => 'Review';

  @override
  String get jobsStop => 'Stop';

  @override
  String get jobsDismiss => 'Dismiss';

  @override
  String get reportTitle => 'Report content';

  @override
  String reportIntro(String contentType) {
    return 'Tell us what\'s wrong with this $contentType. Our team reviews every report.';
  }

  @override
  String get reportReasonInappropriate => 'Inappropriate or offensive';

  @override
  String get reportReasonNudity => 'Nudity or sexual content';

  @override
  String get reportReasonHarassment => 'Harassment or abuse';

  @override
  String get reportReasonImpersonation => 'Impersonation';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportDetailsLabel => 'Additional details (optional)';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSubmittedTitle => 'Report submitted';

  @override
  String get reportSubmittedBody =>
      'Thank you. Our team will review this content.';

  @override
  String get reportFailedTitle => 'Couldn\'t send report';

  @override
  String get reportFailedBody => 'Please try again.';

  @override
  String get reportContentTryOnImage => 'AI try-on image';

  @override
  String get reportContentSharedOutfit => 'shared outfit';

  @override
  String get reportContentPhotoshootImage => 'AI photoshoot image';

  @override
  String get sharedOutfitTitle => 'Shared outfit';

  @override
  String get sharedOutfitHideTooltip => 'Hide this outfit';

  @override
  String get sharedOutfitReportTooltip => 'Report this outfit';

  @override
  String get sharedOutfitHideTitle => 'Hide this outfit?';

  @override
  String get sharedOutfitHideBody =>
      'It stays hidden on this device. You can also report it so our team can review and remove it.';

  @override
  String get sharedOutfitHideAction => 'Hide';

  @override
  String get sharedOutfitHiddenInfo =>
      'This outfit will not show on this device again.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit hidden';

  @override
  String get sharedOutfitMissingTitle => 'This outfit isn\'t here anymore';

  @override
  String get sharedOutfitMissingBody =>
      'It may have been removed, or the link is wrong.';

  @override
  String get sharedOutfitHiddenStateTitle => 'You hid this outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'If it was objectionable, report it from Privacy and terms or email $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Like this look?';

  @override
  String get sharedOutfitCtaBody =>
      'Build outfits like it from your own closet.';

  @override
  String get sharedOutfitCtaButton => 'Get FitCheck AI';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnknown => 'An unexpected error occurred';

  @override
  String get errorNoConnection =>
      'No internet connection. Please check your network.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorServerError =>
      'Something went wrong on our end. Please try again.';

  @override
  String get errorBadGateway =>
      'Our server is briefly unavailable. Please try again.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Please try again shortly.';

  @override
  String get errorInternalError => 'Something went wrong. Please try again.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorForbidden => 'You do not have access to that.';

  @override
  String get errorSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get errorInvalidCredentials =>
      'That email or password is not correct.';

  @override
  String get errorTokenRefreshFailed =>
      'We could not refresh your session. Please sign in again.';

  @override
  String get errorRequestCancelled => 'Request cancelled.';

  @override
  String get errorInvalidFormat => 'That file format is not supported.';

  @override
  String get errorFileTooLarge => 'That file is too large.';

  @override
  String get errorUploadFailed => 'The upload failed. Please try again.';

  @override
  String get errorCacheCorrupted =>
      'Saved data was damaged and has been reset.';

  @override
  String get errorCacheNotFound => 'Nothing was saved yet.';

  @override
  String get errorUserNotFound => 'We could not find that account.';

  @override
  String get errorItemNotFound => 'That item no longer exists.';

  @override
  String get errorOutfitNotFound => 'That outfit no longer exists.';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get rewardsNoAchievementsTitle => 'No achievements yet';

  @override
  String get rewardsNoAchievementsBody =>
      'Add pieces and plan outfits to earn your first.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'No one on the board yet';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Plan outfits to earn points and show up here.';

  @override
  String get legalViewPrivacyPolicy => 'View Privacy Policy';

  @override
  String get aiConsentAgree => 'I Agree & Continue';

  @override
  String get aiConsentNotNow => 'Not Now';

  @override
  String get imageViewerCloseTooltip => 'Close image viewer';

  @override
  String get updateReadyTitle => 'Update ready';

  @override
  String get updateReadyBody =>
      'Restart FitCheck AI to apply the latest improvements.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI needs camera access to take photos of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI needs photo library access to select images of your outfits and wardrobe items.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI needs to save your AI-generated outfit photos to your photo library.';

  @override
  String get wardrobeSomePhotosSkipped => 'Some photos skipped';

  @override
  String get wardrobePhotosNotAdded => 'Photos not added';

  @override
  String get wardrobePhotoNotAdded => 'Photo not added';

  @override
  String get wardrobeNotStartedTitle => 'Not started';

  @override
  String get wardrobeNoRoomTitle => 'No room';

  @override
  String get wardrobeAddPhotosSemantic => 'Add photos';

  @override
  String get batchAddTileLabel => 'Add';

  @override
  String get batchProfileLinkLabel => 'Profile link';

  @override
  String get wardrobeImportFromProfileTitle => 'Import from a profile';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Add several photos';

  @override
  String get wardrobeClearAction => 'Clear';

  @override
  String get wardrobeRefreshTooltip => 'Refresh';

  @override
  String get batchNoPhotosYetTitle => 'No photos yet';

  @override
  String get batchChoosePhotosAction => 'Choose photos';

  @override
  String get batchWeFindEachPieceBody =>
      'We find each piece and make a studio photo of it.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparing photos';

  @override
  String get batchPhotosProcessedSemantic => 'Photos processed';

  @override
  String get batchPasteProfileLinkTitle => 'Paste a profile link';

  @override
  String get batchPasteProfileLinkBody =>
      'A public Instagram or Facebook profile. We scan its photos, and you choose what goes in your closet.';

  @override
  String get batchClearLinkTooltip => 'Clear link';

  @override
  String get batchStartingButton => 'Starting';

  @override
  String get batchStartImportAction => 'Start import';

  @override
  String get batchReviewEveryPhotoTitle => 'You review every photo';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nothing is added until you approve it.';

  @override
  String get batchPrivateProfilesTitle => 'Private profiles';

  @override
  String get batchPrivateProfilesBody =>
      'Connect your account. Instagram also takes a username and password.';

  @override
  String get batchUseAnotherLinkAction => 'Use another link';

  @override
  String get batchSignInNeededTitle => 'Sign-in needed';

  @override
  String get batchEnterYourCodeTitle => 'Enter your code';

  @override
  String get batchUseUsernamePasswordAction => 'Use username and password';

  @override
  String get batchAlreadyConnectedAction =>
      'I already connected in the browser';

  @override
  String get batchEnterCodeAction => 'Enter code';

  @override
  String get batchTryAnotherWayAction => 'Try another way';

  @override
  String get batchLiveStatus => 'Live';

  @override
  String get batchReconnectingStatus => 'Reconnecting';

  @override
  String get batchSignInToInstagramTitle => 'Sign in to Instagram';

  @override
  String get batchUsernameLabel => 'Username';

  @override
  String get batchCodeIfTwoStepLabel => 'Code, if you use two-step sign-in';

  @override
  String get batchAuthenticatorCodeBody =>
      'Use the 6-digit code from your authenticator app. Codes change quickly.';

  @override
  String get batchVerifyAction => 'Verify';

  @override
  String get batchFindingPhotosTitle => 'Finding photos';

  @override
  String get batchImportPausedTitle => 'Import paused';

  @override
  String get batchProcessingPhotosTitle => 'Processing photos';

  @override
  String get batchWaitingNextPhoto => 'Waiting for the next photo';

  @override
  String get batchCancelImportAction => 'Cancel import';

  @override
  String get batchNoPiecesInPhotoBody => 'No pieces found in this photo.';

  @override
  String get batchEditPieceColoursLabel => 'Colours, separated by commas';

  @override
  String get batchAddToClosetAction => 'Add to closet';

  @override
  String get batchSkipPhotoAction => 'Skip this photo';

  @override
  String get batchImportCompleteTitle => 'Import complete';

  @override
  String get batchImportFailedTitle => 'Import failed';

  @override
  String get batchImportCancelledTitle => 'Import cancelled';

  @override
  String get batchImportErrorBody => 'Something went wrong while importing.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nothing more is imported from this profile.';

  @override
  String get batchViewClosetAction => 'View closet';

  @override
  String get batchStartOverAction => 'Start over';

  @override
  String get wardrobeAddPieceTitle => 'Add a piece';

  @override
  String get wardrobeAddDetailsTitle => 'Add details';

  @override
  String get wardrobeScanningTitle => 'Scanning';

  @override
  String get batchReviewPiecesTitle => 'Review pieces';

  @override
  String get wardrobeGalleryAction => 'Gallery';

  @override
  String get wardrobeCameraAction => 'Camera';

  @override
  String get wardrobeNewBadge => 'New';

  @override
  String get wardrobeRemovePhotoTooltip => 'Remove photo';

  @override
  String get batchRunInBackgroundTooltip => 'Run in background';

  @override
  String get batchStepOneOfTwo => 'Step 1 of 2';

  @override
  String get batchStepTwoOfTwo => 'Step 2 of 2';

  @override
  String get batchUploadingPhotosTitle => 'Uploading photos';

  @override
  String get batchFindingPiecesTitle => 'Finding pieces';

  @override
  String get batchMakingStudioPhotosTitle => 'Making studio photos';

  @override
  String get batchStoppedLabel => 'Stopped';

  @override
  String get batchFindingPiecesStoppedTitle => 'Finding pieces stopped';

  @override
  String get batchCancelledLabel => 'Cancelled';

  @override
  String get batchAllDoneTitle => 'All done';

  @override
  String get batchOpeningPiecesBody => 'Opening your pieces';

  @override
  String get batchNothingSavedBody => 'Nothing was saved.';

  @override
  String get batchFindingPiecesFailedBody => 'Finding pieces failed.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Finding pieces stopped early.';

  @override
  String get batchStopFindingPiecesTitle => 'Stop finding pieces?';

  @override
  String get batchStopFindingPiecesBody =>
      'The scan stops and nothing is saved. Pieces already found stay in your activity until you dismiss them.';

  @override
  String get batchKeepGoingAction => 'Keep going';

  @override
  String get batchTryAgainAction => 'Try again';

  @override
  String get batchBackToPhotosAction => 'Back to photos';

  @override
  String get batchSkipAllAction => 'Skip all';

  @override
  String get batchIncludeAllAction => 'Include all';

  @override
  String get batchNoPiecesFoundTitle => 'No pieces found';

  @override
  String get batchNoPiecesFoundBody => 'We found no clothes in these photos.';

  @override
  String get batchChooseOtherPhotosAction => 'Choose other photos';

  @override
  String get batchUseCaseHelper => 'Added to every piece you save.';

  @override
  String get batchDiscardPiecesTitle => 'Discard these pieces?';

  @override
  String get batchDiscardPiecesBody => 'Nothing from this batch is saved.';

  @override
  String get batchKeepAction => 'Keep';

  @override
  String get batchDiscardAction => 'Discard';

  @override
  String get batchRemovePieceTitle => 'Remove this piece?';

  @override
  String get batchRemovePieceBody => 'It is not saved to your closet.';

  @override
  String get batchRemoveAction => 'Remove';

  @override
  String get batchChoosePiecesToSave => 'Choose pieces to save';

  @override
  String get batchDiscardAllAction => 'Discard all';

  @override
  String get batchNothingSavedRetryBody => 'Nothing was saved. Try again.';

  @override
  String get batchNotSavedTitle => 'Not saved';

  @override
  String get batchSavingLabel => 'Saving';

  @override
  String get batchSendToBackgroundAction => 'Send to background';

  @override
  String get batchStillWorkingMessage =>
      'Still working. We will let you know when your pieces are ready.';

  @override
  String get batchRunningInBackgroundTitle => 'Running in background';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Studio photos stopped early. You can still save these pieces.';

  @override
  String get batchTapPieceToSkip => 'Tap a piece to skip it.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Studio photos still on their way. You can leave — we will let you know.';

  @override
  String get batchLeaveAction => 'Leave';

  @override
  String get batchPeopleInPhotosTitle => 'People in the photos';

  @override
  String get batchIncludeAction => 'Include';

  @override
  String get batchSkipAction => 'Skip';

  @override
  String get batchYourPhotoIsUsedLabel => 'Your photo is used';

  @override
  String get batchMakingStudioPhotoLabel => 'Making studio photo';

  @override
  String get batchNoStudioPhotoBody => 'No studio photo. Your photo is used.';

  @override
  String get batchEnterDetailsYourselfAction => 'Enter details yourself';

  @override
  String get batchChooseAnotherPhotoAction => 'Choose another photo';

  @override
  String get batchConnectionLostTitle => 'Connection lost';

  @override
  String get batchConnectionLostBody =>
      'Check your connection, then try again.';

  @override
  String get batchDailyLimitTitle => 'Daily limit reached';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Upgrade to Pro for more scans, or enter the details yourself.';

  @override
  String get batchDailyLimitBodyFree =>
      'Your scans reset tomorrow. You can enter the details yourself now.';

  @override
  String get batchSeePlansAction => 'See plans';

  @override
  String get batchAiBusyTitle => 'Our AI is busy';

  @override
  String get batchAiBusyBody =>
      'This is on our side. Try again in a few minutes.';

  @override
  String get batchNoPiecesBody =>
      'Try a clearer photo, or enter the details yourself.';

  @override
  String get batchScanningUnavailableTitle => 'Scanning is unavailable';

  @override
  String get batchScanningUnavailableBody =>
      'Enter the details yourself for now.';

  @override
  String get batchScanDidNotFinishTitle => 'The scan did not finish';

  @override
  String get batchTryAgainBody => 'Try again.';

  @override
  String get billingTitle => 'Subscription';

  @override
  String get billingUpgradeHeading => 'Upgrade your plan';

  @override
  String get billingUpgradeOnPlusBody => 'Same features, higher limits.';

  @override
  String get billingUpgradeBody =>
      'Plus and Pro have the same features. Pick the limits you need.';

  @override
  String get billingWebUnavailableBody =>
      'Online upgrades aren\'t available yet. A promo or referral code still unlocks Plus or Pro. Invite friends below to earn free months.';

  @override
  String get billingPlansStale =>
      'Couldn\'t load the latest plans. Prices may be out of date.';

  @override
  String get billingMonthly => 'Monthly';

  @override
  String get billingYearly => 'Yearly';

  @override
  String get billingCurrentPlan => 'Current plan';

  @override
  String get billingActive => 'Active';

  @override
  String get billingThisMonth => 'This month';

  @override
  String get billingItemExtractions => 'Item extractions';

  @override
  String get billingOutfitVisualizations => 'Outfit visualizations';

  @override
  String get billingNearLimitUpgrade =>
      'You\'re close to this month\'s limit. Upgrade for more.';

  @override
  String get billingNearLimitResets =>
      'You\'re close to this month\'s limit. It resets at the start of next month.';

  @override
  String get billingStoreUnavailable =>
      'Upgrades aren\'t available in the store yet. Check back soon.';

  @override
  String get billingManageHeading => 'Manage your plan';

  @override
  String get billingCancelPlan => 'Cancel subscription';

  @override
  String get billingCancelKeepsAccess =>
      'You keep access until the end of this billing period.';

  @override
  String get billingCancelConfirmTitle => 'Cancel your subscription?';

  @override
  String get billingKeepPlan => 'Keep plan';

  @override
  String get billingCancelPlanAction => 'Cancel plan';

  @override
  String get billingBilledMonthly => 'Billed monthly';

  @override
  String get billingBilledYearly => 'Billed yearly';

  @override
  String get billingVirtualTryOn => 'Virtual try-on';

  @override
  String get billingPrioritySupport => 'Priority support';

  @override
  String get billingDisclosureProRenewing =>
      'Pro is an auto-renewing subscription';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus and Pro are auto-renewing subscriptions';

  @override
  String get billingDisclosureAppleBilling =>
      'Payment is charged to your Apple ID at confirmation of purchase.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Payment is charged to your Google Play account at confirmation of purchase.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Your subscription renews automatically for the same period at the same price unless you turn off auto-renew at least 24 hours before the current period ends.';

  @override
  String get billingDisclosureAppleManage =>
      'Manage or cancel any time in Settings › your Apple ID › Subscriptions.';

  @override
  String get billingDisclosureGoogleManage =>
      'Manage or cancel any time in Google Play › Payments and subscriptions.';

  @override
  String get billingReferFriend => 'Refer a friend';

  @override
  String get billingHowItWorks => 'How it works';

  @override
  String get billingHowShareTitle => 'Share your link';

  @override
  String get billingHowShareBody => 'Send it to a friend.';

  @override
  String get billingHowSignUpTitle => 'They sign up';

  @override
  String get billingHowSignUpBody => 'Your friend joins from the link.';

  @override
  String get billingHowBothTitle => 'You both get Pro';

  @override
  String get billingHowBothBody => 'Each of you gets a month of Pro free.';

  @override
  String get billingYourReferrals => 'Your referrals';

  @override
  String get billingInvited => 'Invited';

  @override
  String get billingJoined => 'Joined';

  @override
  String get billingMonthsEarned => 'Months earned';

  @override
  String get billingInviteFriend => 'Invite a friend';

  @override
  String get billingInviteBody =>
      'You and your friend each get a month of Pro.';

  @override
  String get billingYourCode => 'Your code';

  @override
  String get billingCopyLink => 'Copy link';

  @override
  String get billingShareInvite => 'Share invite';

  @override
  String get giftUnavailable =>
      'Gift invitations are not available in this build.';

  @override
  String get giftPageTitle => 'Gift FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'No free gift invitations are available right now.';

  @override
  String get giftFormTitle => 'Send a free invitation';

  @override
  String get giftFormBody =>
      'Your recipient claims the gift with this verified email. We don\'t send the email for you.';

  @override
  String get giftFieldFrom => 'From';

  @override
  String get giftFieldRecipientName => 'Recipient name';

  @override
  String get giftFieldRecipientEmail => 'Recipient email';

  @override
  String get giftFieldOccasion => 'Occasion (optional)';

  @override
  String get giftNoOccasion => 'No occasion';

  @override
  String get giftOccasionBirthday => 'Birthday';

  @override
  String get giftOccasionAnniversary => 'Anniversary';

  @override
  String get giftOccasionOther => 'Other';

  @override
  String get giftFieldCardGreeting => 'Card greeting';

  @override
  String get giftFieldCardGreetingHelper =>
      'This appears on the card exactly as written.';

  @override
  String get giftFieldPrivateNote => 'Private note (optional)';

  @override
  String get giftCreateAction => 'Create free gift';

  @override
  String get giftClaimedTitle => 'Gift claimed';

  @override
  String get giftClaimedActive => 'Your FitCheck Pro gift is active.';

  @override
  String get giftClaimedQueued =>
      'Your FitCheck Pro gift starts after your current access.';

  @override
  String get giftLinkCopied => 'Gift link copied to the clipboard.';

  @override
  String get giftErrorName => 'Enter a name.';

  @override
  String get giftErrorEmail => 'Enter a valid email address.';

  @override
  String get giftErrorGreeting => 'Enter the card greeting.';

  @override
  String get giftErrorGreetingLength => 'Use no more than 80 characters.';

  @override
  String get giftClaimAction => 'Claim gift';

  @override
  String get giftCardPreview => 'Card preview';

  @override
  String get giftGiftForYou => 'A gift for you';

  @override
  String get giftGiftWaiting => 'A gift is waiting for you';

  @override
  String get giftOpenBody =>
      'Open your gifts to claim them with your verified email.';

  @override
  String get giftOpenGifts => 'Open gifts';

  @override
  String get giftSendInvitation => 'Send invitation';

  @override
  String get settingsAiProviderSection => 'Provider';

  @override
  String get settingsAiCustom => 'Custom';

  @override
  String get settingsAiUrlHelper =>
      'Use a public URL the server can reach. Localhost does not work from our servers.';

  @override
  String get settingsAiConnectionSection => 'Connection';

  @override
  String get settingsAiApiUrl => 'API URL';

  @override
  String get settingsAiApiKey => 'API key';

  @override
  String get settingsAiApiKeySaved => 'Saved. Leave blank to keep it.';

  @override
  String get settingsAiChatModel => 'Chat model';

  @override
  String get settingsAiVisionModel => 'Vision model (optional)';

  @override
  String get settingsAiImageModel => 'Image model (optional)';

  @override
  String get settingsAiImageModelNote =>
      'Image generation needs OpenAI-compatible chat completions with response_modalities.';

  @override
  String get settingsAiTestConnection => 'Test connection';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarGoToToday => 'Go to today';

  @override
  String get calendarConnectTooltip => 'Connect a calendar';

  @override
  String get calendarAddEvent => 'Add event';

  @override
  String get calendarEmptyTitle => 'Nothing planned';

  @override
  String get calendarEmptyBody => 'Add an event and plan what to wear.';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarAllDay => 'All day';

  @override
  String get calendarOutfitLinked => 'Outfit linked';

  @override
  String get calendarEventOptions => 'Event options';

  @override
  String get calendarDeleteTitle => 'Delete this event?';

  @override
  String get calendarChangeOutfit => 'Change outfit';

  @override
  String get calendarLinkOutfit => 'Link an outfit';

  @override
  String get calendarRemoveOutfit => 'Remove outfit';

  @override
  String get calendarNewEvent => 'New event';

  @override
  String get calendarEditEvent => 'Edit event';

  @override
  String get calendarTitleLabel => 'Title';

  @override
  String get calendarTitleRequired => 'Add a title';

  @override
  String get calendarEndBeforeStart => 'End after the start time';

  @override
  String get calendarStarts => 'Starts';

  @override
  String get calendarEnds => 'Ends';

  @override
  String get calendarPlaceOptional => 'Place (optional)';

  @override
  String get calendarNotesOptional => 'Notes (optional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Build an outfit, then link it to this event.';

  @override
  String get calendarBuildOutfit => 'Build an outfit';

  @override
  String get calendarConnectionsTitle => 'Calendars';

  @override
  String get calendarConnectionsBody => 'Events you add here stay in FitCheck.';

  @override
  String get calendarDisconnect => 'Disconnect';

  @override
  String get calendarNotAvailable => 'Not available yet';

  @override
  String get profileSectionExplore => 'Explore';

  @override
  String get profileNavTryOn => 'Try-on';

  @override
  String get profileNavRewards => 'Rewards';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Help';

  @override
  String get profileAbout => 'About';

  @override
  String get profileAboutBody => 'Your closet, outfits and plans in one place.';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody => 'You can sign back in at any time.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileYourProfile => 'Your profile';

  @override
  String get profileBodyProfiles => 'Body profiles';

  @override
  String get profileBodyEmptyTitle => 'No body profiles yet';

  @override
  String get profileBodyEmptyBody =>
      'Add your height and build to get a better fit.';

  @override
  String get profileBodyAdd => 'Add a profile';

  @override
  String get profileBodyDefaultNote =>
      'Your default profile is used for fit and try-on.';

  @override
  String get profileBodyDefaultBadge => 'Default';

  @override
  String get profileBodyMakeDefault => 'Make default';

  @override
  String get profileBodyDeleteBody => 'You cannot undo this.';

  @override
  String get profileBodyRequired => 'Required';

  @override
  String get profileBodyCheckNumber => 'Check this number';

  @override
  String get profileBodyNew => 'New body profile';

  @override
  String get profileBodyNameHint => 'For example, Me';

  @override
  String get profileBodyHeight => 'Height';

  @override
  String get profileBodyWeight => 'Weight';

  @override
  String get profileBodyBuild => 'Build';

  @override
  String get profileBodySkinTone => 'Skin tone';

  @override
  String get profileBirthDateNeededBody =>
      'Add a date of birth to go with the birth time.';

  @override
  String get profileBirthDateNeededTitle => 'Date of birth needed';

  @override
  String get profilePartlySavedBody =>
      'We saved your name and photo. Birth details did not save; try again later.';

  @override
  String get profilePartlySavedTitle => 'Partly saved';

  @override
  String get profileSavedBody => 'Your profile is saved.';

  @override
  String get profileChangePhoto => 'Change profile photo';

  @override
  String get profilePhotoLabel => 'Profile photo';

  @override
  String get profilePhotoHint => 'Tap to choose a new one';

  @override
  String get profileBirthDateLabel => 'Date of birth (optional)';

  @override
  String get profileBirthTimeLabel => 'Birth time (optional)';

  @override
  String get profileBirthTimeHelper => 'Makes Vedic suggestions more exact';

  @override
  String get profileBirthPlaceLabel => 'Birth place (optional)';

  @override
  String get profileBirthPlaceHint => 'For example, New Delhi, India';

  @override
  String get profileHelpContactTitle => 'Ask us anything';

  @override
  String get profileHelpContactBody =>
      'Send a message and we reply by email, usually within a day.';

  @override
  String get profileHelpContactAction => 'Contact support';

  @override
  String get profileHelpFaqTitle => 'Common questions';

  @override
  String get profileFaqAddPiecesTitle => 'How do I add pieces to my closet?';

  @override
  String get profileFaqAddPiecesBody =>
      'Tap Add item on the Closet tab. Take a photo or pick one from your gallery; we find each piece and tag it for you.';

  @override
  String get profileFaqMatchingTitle => 'How does outfit matching work?';

  @override
  String get profileFaqMatchingBody =>
      'Open For you and pick pieces you own. We suggest what goes with them and build full outfits from your closet.';

  @override
  String get profileFaqTryOnTitle => 'Can I use my own photos for try-on?';

  @override
  String get profileFaqTryOnBody =>
      'Yes. Add a full-length photo of yourself, then choose pieces to see them on you.';

  @override
  String get profileFaqRewardsTitle => 'How do I earn rewards?';

  @override
  String get profileFaqRewardsBody =>
      'Plan and log outfits often. Streaks and achievements build as you go.';

  @override
  String get profileFaqPrivacyTitle => 'Is my closet private?';

  @override
  String get profileFaqPrivacyBody =>
      'Yes. Your closet and outfits are private unless you share a link to one outfit.';

  @override
  String get profileHelpMoreTitle => 'More help';

  @override
  String get profileHelpGuides => 'Guides';

  @override
  String get profileHelpGuidesBody => 'How each feature works';

  @override
  String get feedbackCategoryBug => 'Something broke';

  @override
  String get feedbackCategoryIdea => 'An idea';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'I need help';

  @override
  String get feedbackHintBug =>
      'What happened, and what did you expect? Steps help us fix it.';

  @override
  String get feedbackHintIdea => 'What would you like, and why?';

  @override
  String get feedbackHintGeneral =>
      'Tell us what you think, or ask a question.';

  @override
  String get feedbackAttachmentLimitBody => 'You can add up to 5 images.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limit reached';

  @override
  String get feedbackImageTooLargeBody => 'Choose an image under 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Image too large';

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackAboutLabel => 'What is it about?';

  @override
  String get feedbackSubjectLabel => 'Subject';

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
  String get authSignedIn => 'Signed in';

  @override
  String get authWelcomeBackTitle => 'Welcome back';

  @override
  String get authSignInFailed => 'Sign-in failed';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String get authSignUpFailed => 'Sign-up failed';

  @override
  String get authGoogleSignInFailed => 'Google sign-in failed';

  @override
  String get authAppleSignInFailed => 'Apple sign-in failed';

  @override
  String get authConfirmEmailTitle => 'Confirm your email';

  @override
  String get authConfirmEmailBody =>
      'Check your inbox for a confirmation email, then sign in.';

  @override
  String get authClosetReady => 'Your closet is ready.';

  @override
  String get authSignedOutTitle => 'Signed out';

  @override
  String get authSignedOutBody => 'You are signed out.';

  @override
  String get authSignOutFailed => 'Sign-out failed';

  @override
  String get authEmailSentTitle => 'Email sent';

  @override
  String get authResetLinkSent => 'Check your email for a reset link.';

  @override
  String get authPasswordUpdatedTitle => 'Password updated';

  @override
  String get authPasswordUpdated => 'Your password is updated.';

  @override
  String get authPasswordNotUpdated => 'Password not updated';

  @override
  String get authCouldNotSendEmail => 'Could not send the email';

  @override
  String get authEmailNotSent => 'Email not sent';

  @override
  String get authResendSentBody => 'We sent a new confirmation email.';

  @override
  String get outfitPreviewWithAi => 'Preview with AI';

  @override
  String get outfitNewPreview => 'Make a new preview';

  @override
  String get outfitBuilderClosetHeading => 'Your closet';

  @override
  String get outfitBuilderSearchHint => 'Search pieces';

  @override
  String get outfitClearSearch => 'Clear search';

  @override
  String get outfitBuilderAddPiecesTitle => 'Add pieces first';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Outfits are made from the pieces in your closet.';

  @override
  String get outfitBuilderNoMatches => 'No pieces match.';

  @override
  String get outfitNameLabel => 'Outfit name';

  @override
  String get outfitNameHint => 'For example, Weekend linen';

  @override
  String get outfitPreviewSemantic => 'AI preview of the outfit';

  @override
  String get outfitChoosePieces => 'Choose pieces';

  @override
  String get outfitTapPiecesHint => 'Tap pieces below to add them.';

  @override
  String get outfitShareTooltip => 'Share';

  @override
  String get outfitSaveFavourite => 'Save to favourites';

  @override
  String get outfitPiecesHeading => 'Pieces';

  @override
  String get outfitWearHistoryEmpty =>
      'Wear it once and the dates show up here.';

  @override
  String get outfitWearHistoryTitle => 'Wear history';

  @override
  String get outfitWearHistoryError => 'Couldn\'t load the dates.';

  @override
  String get outfitWornOn => 'Worn on';

  @override
  String get outfitEditTitle => 'Edit outfit';

  @override
  String get outfitSavedPhotosFailed => 'Details saved, photos not';

  @override
  String get outfitNoPhotosBody =>
      'No photos yet. The outfit shows its pieces instead.';

  @override
  String get outfitOccasionLabel => 'Occasion';

  @override
  String get outfitOccasionNone => 'None';

  @override
  String get outfitTagsHint => 'Separate with commas';

  @override
  String get outfitDraftBody => 'Hidden from your main list';

  @override
  String get outfitPublic => 'Public';

  @override
  String get outfitPublicBody => 'Anyone with the link can see it';

  @override
  String get outfitDeleteFromDetail =>
      'Delete this outfit from its detail page.';

  @override
  String get outfitNewCollection => 'New collection';

  @override
  String get outfitNoCollectionsTitle => 'No collections yet';

  @override
  String get outfitNoCollectionsBody =>
      'Group outfits by trip, season or mood.';

  @override
  String get outfitCreateCollection => 'Create a collection';

  @override
  String get outfitAddOutfits => 'Add outfits';

  @override
  String get outfitRename => 'Rename';

  @override
  String get outfitCollectionDeleteBody => 'The outfits in it are kept.';

  @override
  String get outfitCollectionsNotLoaded => 'Outfits not loaded';

  @override
  String get outfitRenameCollection => 'Rename collection';

  @override
  String get outfitDescriptionOptional => 'Description (optional)';

  @override
  String get outfitAllInCollection =>
      'Every outfit is already in this collection.';

  @override
  String get photoshootSubtitleUpload =>
      'Studio portraits from your own photos';

  @override
  String get photoshootSubtitleConfigure =>
      'Pick a style, a format and a count';

  @override
  String get photoshootSubtitleGenerating => 'This takes a minute or two';

  @override
  String get photoshootAddPhotosSemantic => 'Add photos from your gallery';

  @override
  String get photoshootUploadTitle => 'Add 1 to 4 photos of yourself';

  @override
  String get photoshootUploadBody => 'Tap to choose from your gallery';

  @override
  String get photoshootAddToContinue => 'Add a photo to continue';

  @override
  String get photoshootAddAnotherPhoto => 'Add another photo';

  @override
  String get photoshootTipsTitle => 'For the best results';

  @override
  String get photoshootTipsBody =>
      'Use clear, well-lit photos of your face from a few angles. Skip sunglasses and hats.';

  @override
  String get photoshootStarting => 'Starting';

  @override
  String get photoshootCancelling => 'Cancelling';

  @override
  String get photoshootFailed => 'Failed';

  @override
  String get recommendTabMatches => 'Matches';

  @override
  String get recommendTabComplete => 'Complete';

  @override
  String get recommendTabWeather => 'Weather';

  @override
  String get recommendTabColours => 'Colours';

  @override
  String get recommendTabShop => 'Shop';

  @override
  String get recommendNoMatchesTitle => 'No matches yet';

  @override
  String get recommendNoMatchesBody =>
      'Pick a piece and we\'ll find what goes with it.';

  @override
  String get recommendPickPiece => 'Pick a piece';

  @override
  String get recommendNothingMatchesTitle => 'Nothing matches these yet';

  @override
  String get recommendNothingMatchesBody =>
      'Try other pieces, or add more to your closet.';

  @override
  String get recommendChangePieces => 'Change pieces';

  @override
  String get recommendDefaultReason => 'It suits the pieces you picked.';

  @override
  String get recommendCompleteTitle => 'Complete a look';

  @override
  String get recommendCompleteBody =>
      'Pick a piece and we\'ll fill in the rest.';

  @override
  String get recommendWorking => 'Working';

  @override
  String get recommendGenerate => 'Generate';

  @override
  String get recommendChooseStyleBody => 'Choose a style, then generate.';

  @override
  String get recommendNoLooksTitle => 'No looks for these pieces';

  @override
  String get recommendNoLooksBody => 'Try another style or other pieces.';

  @override
  String get recommendDefaultLook => 'A look for your pieces';

  @override
  String get recommendNoPiecesBody => 'No pieces came back for this look.';

  @override
  String get recommendCityLabel => 'City';

  @override
  String get recommendCheck => 'Check';

  @override
  String get recommendWeatherTitle => 'What\'s the weather?';

  @override
  String get recommendWeatherBody => 'Enter your city to get picks for today.';

  @override
  String get recommendWearToday => 'Wear today';

  @override
  String get recommendWeatherNoPieces =>
      'No pieces in your closet for this weather yet.';

  @override
  String get recommendBudgetLabel => 'Budget up to';

  @override
  String get recommendLooking => 'Looking';

  @override
  String get recommendFindWhatToBuy => 'Find what to buy';

  @override
  String get recommendFillGapsTitle => 'Fill the gaps';

  @override
  String get recommendFillGapsBody =>
      'Set a budget and we\'ll suggest what your closet is missing.';

  @override
  String get recommendNoGapsTitle => 'No gaps found';

  @override
  String get recommendNoGapsBody => 'Try a bigger budget or another category.';

  @override
  String get recommendMoodEveryday => 'Everyday';

  @override
  String get recommendMoodBigMeeting => 'Big meeting';

  @override
  String get recommendDayLabel => 'Day';

  @override
  String get recommendReadingStars => 'Reading the stars';

  @override
  String get recommendGetMyColours => 'Get my colours';

  @override
  String get recommendLuckyColoursTitle => 'Your lucky colours';

  @override
  String get recommendLuckyColoursBody =>
      'Pick a day and we\'ll suggest colours and pieces for it.';

  @override
  String get recommendLuckyColoursSection => 'Lucky colours';

  @override
  String get recommendAvoidColoursSection => 'Colours to go easy on';

  @override
  String get recommendBirthDateTitle => 'Add your birth date';

  @override
  String get recommendBirthDateBody =>
      'We need your date of birth to read your colours.';

  @override
  String get recommendEditProfile => 'Edit profile';

  @override
  String get recommendNothingThisDay => 'Nothing for this day.';

  @override
  String get recommendUnnamedColour => 'Unnamed colour';

  @override
  String get recommendFromCloset => 'From your closet';

  @override
  String get recommendNoPiecesInColours => 'No pieces in these colours yet.';

  @override
  String get recommendOutfitIdeas => 'Outfit ideas';

  @override
  String get recommendNoOutfitsInColours =>
      'No full outfit in these colours yet.';

  @override
  String get recommendDefaultOutfitIdea => 'An outfit idea';

  @override
  String get recommendPickUpToThree => 'Pick up to three pieces';

  @override
  String get recommendEmptyClosetBody =>
      'Add a few pieces first, then come back for matches.';

  @override
  String get dashboardDressForDay => 'Dress for the day ahead.';

  @override
  String get dashboardOutfitOfDay => 'Outfit of the day';

  @override
  String get dashboardFreshLook => 'A fresh look';

  @override
  String get subscriptionManageInStoreTitle => 'Manage in the store';

  @override
  String get subscriptionManageInStoreBody =>
      'This plan is billed through the store. Manage it in your store account settings.';

  @override
  String get subscriptionCancelledTitle => 'Subscription cancelled';

  @override
  String get subscriptionCancelledBody =>
      'Your plan stays active until the end of this billing period.';

  @override
  String get subscriptionCancelFailedTitle => 'Could not cancel';

  @override
  String get subscriptionCouldNotOpenTitle => 'Could not open';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Could not open billing management.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Could not open the link.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Could not load your link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Could not load your referral link. Try again.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copied';

  @override
  String get subscriptionReferralCopiedBody => 'Referral link copied.';

  @override
  String get subscriptionReferralShareSubject => 'Try FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Join FitCheck AI and we both get a month of Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copied';

  @override
  String get subscriptionShareUnavailableBody =>
      'Sharing is not available, so we copied the link.';

  @override
  String get subscriptionShareFailedTitle => 'Could not share';

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
  String get giftClaimFailedTitle => 'Could not claim the gift';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gifts for you',
      one: 'A gift for you',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 month',
      '12': '1 year',
      'other': '$months months',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining left',
      one: '1 left',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration of FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender sent you $duration of FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'A FitCheck Pro gift for $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'From $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'For $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'From $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'your recipient';

  @override
  String get giftPreviewPlaceholderSender => 'you';

  @override
  String get settingsSavedTitle => 'Saved';

  @override
  String get settingsNotSavedTitle => 'Not saved';

  @override
  String get settingsAiChooseProviderBody => 'Choose a provider.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'A custom provider needs an API URL.';

  @override
  String get settingsAiKeyRequiredBody => 'Enter an API key.';

  @override
  String get settingsAiSavedBody => 'Your AI settings are saved.';

  @override
  String get settingsAiMissingDetailsTitle => 'Missing details';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Enter an API URL and a chat model to test.';

  @override
  String get settingsAiKeyNeededTitle => 'API key needed';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Enter your API key to test. Your saved key stays private.';

  @override
  String get settingsAiKeyToTestBody => 'Enter your API key to test.';

  @override
  String get settingsAiConnectedTitle => 'Connected';

  @override
  String get settingsAiConnectedBody => 'The connection works.';

  @override
  String get settingsAiTestFailedTitle => 'Test failed';

  @override
  String get settingsPreferencesSavedBody => 'Your preferences are saved.';

  @override
  String get settingsPasswordNotChangedTitle => 'Password not changed';

  @override
  String get settingsOAuthPasswordBody =>
      'This account signs in with Google or Apple. Use \"Forgot password\" to set a password first.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Current password is incorrect.';

  @override
  String get settingsExportReadyTitle => 'Export ready';

  @override
  String get settingsExportReadyBody =>
      'Your data export is ready to download.';

  @override
  String get settingsLinkCopiedTitle => 'Link copied';

  @override
  String get settingsExportClipboardBody =>
      'We could not open your browser, so we copied the download link. Paste it into a browser soon: it expires.';

  @override
  String get settingsExportFailedTitle => 'Export failed';

  @override
  String get settingsAccountNotDeletedTitle => 'Account not deleted';

  @override
  String photoshootPhotoLimit(int max) {
    return 'You can add up to $max photos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Photo limit';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Add at least one photo.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'No photos';

  @override
  String get photoshootDescribeLookBody => 'Describe the look you want.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt needed';

  @override
  String get photoshootConsentFeatureLabel => 'AI Photoshoot';

  @override
  String get photoshootStatusPreparing => 'Preparing your photos';

  @override
  String get photoshootStatusGenerating => 'Generating';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Batch $current of $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get photoshootGenerationFailedBody => 'Generation failed.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready ready, $failed failed.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Partly done';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos are ready.',
      one: '1 photo is ready.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'We lost the connection. Please try again.';

  @override
  String get photoshootCouldNotCancelTitle => 'Could not cancel';

  @override
  String get photoshootRetryFailedTitle => 'Retry failed';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'Photo $number is ready.';
  }

  @override
  String get photoshootReplacedTitle => 'Replaced';

  @override
  String get photoshootSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get photoshootSavedTitle => 'Saved';

  @override
  String get photoshootNotSavedTitle => 'Not saved';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count photos are in your gallery.',
      one: '1 photo is in your gallery.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved of $total saved.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Some photos not saved';

  @override
  String get tryonConsentFeatureLabel => 'Virtual Try-On';

  @override
  String get tryonAvatarUpdatedBody => 'Your photo is updated.';

  @override
  String get tryonSavedTitle => 'Saved';

  @override
  String get tryonUploadFailedTitle => 'Upload failed';

  @override
  String get tryonChooseGarmentFirstBody => 'Choose a garment photo first.';

  @override
  String get tryonNoGarmentTitle => 'No garment';

  @override
  String get tryonWaitForUploadBody =>
      'Wait for your photo to finish uploading.';

  @override
  String get tryonStillUploadingTitle => 'Still uploading';

  @override
  String get tryonAddYourPhotoFirstBody => 'Add a photo of yourself first.';

  @override
  String get tryonReadyBody => 'Your try-on is ready.';

  @override
  String get tryonFailedTitle => 'Try-on failed';

  @override
  String get tryonSavedToGalleryBody => 'Saved to your gallery.';

  @override
  String get tryonNotSavedTitle => 'Not saved';

  @override
  String get calendarEventAddedBody => 'Event added';

  @override
  String get calendarEventPlannedTitle => 'Planned';

  @override
  String get calendarEventSavedBody => 'Event saved';

  @override
  String get calendarSavedTitle => 'Saved';

  @override
  String get calendarEventNotSavedTitle => 'Event not saved';

  @override
  String get calendarEventRemovedBody => 'Event removed';

  @override
  String get calendarEventDeletedTitle => 'Deleted';

  @override
  String get calendarEventNotDeletedTitle => 'Event not deleted';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit not linked';

  @override
  String get calendarLinkedTitle => 'Linked';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit not removed';

  @override
  String get calendarOutfitRemovedBody => 'Outfit removed';

  @override
  String get calendarDisconnectedBody => 'Calendar disconnected';

  @override
  String get calendarDisconnectedTitle => 'Disconnected';

  @override
  String get calendarNotDisconnectedTitle => 'Calendar not disconnected';

  @override
  String get calendarTodayLabel => 'today';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit linked';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" will be removed.';
  }

  @override
  String get calendarThisAppLabel => 'This app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Syncing with $provider is not available yet. You can still add events here.';
  }

  @override
  String get calendarWeekdaySunShort => 'Sun';

  @override
  String get calendarWeekdayMonShort => 'Mon';

  @override
  String get calendarWeekdayTueShort => 'Tue';

  @override
  String get calendarWeekdayWedShort => 'Wed';

  @override
  String get calendarWeekdayThuShort => 'Thu';

  @override
  String get calendarWeekdayFriShort => 'Fri';

  @override
  String get calendarWeekdaySatShort => 'Sat';

  @override
  String get calendarWeekdayMonday => 'Monday';

  @override
  String get calendarWeekdayTuesday => 'Tuesday';

  @override
  String get calendarWeekdayWednesday => 'Wednesday';

  @override
  String get calendarWeekdayThursday => 'Thursday';

  @override
  String get calendarWeekdayFriday => 'Friday';

  @override
  String get calendarWeekdaySaturday => 'Saturday';

  @override
  String get calendarWeekdaySunday => 'Sunday';

  @override
  String get outfitSavedToFavouritesBody => 'Saved to favourites';

  @override
  String get outfitRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get outfitNotSavedTitle => 'Not saved';

  @override
  String get outfitLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get outfitNicePickTitle => 'Nice pick';

  @override
  String get outfitRemovedBody => 'Outfit removed.';

  @override
  String get outfitDeletedTitle => 'Deleted';

  @override
  String get outfitNotDeletedTitle => 'Not deleted';

  @override
  String get outfitDuplicatedBody => 'A copy is in your outfits.';

  @override
  String get outfitDuplicatedTitle => 'Duplicated';

  @override
  String get outfitNotDuplicatedTitle => 'Not duplicated';

  @override
  String get outfitNotSharedTitle => 'Not shared';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" is ready.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collection not created';

  @override
  String get outfitCollectionUpdatedBody => 'Collection updated.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collection not updated';

  @override
  String get outfitCollectionDeletedBody => 'Collection deleted.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collection not deleted';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outfits added.',
      one: '1 outfit added.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Outfits not added';

  @override
  String get outfitPreviewNotCreatedTitle => 'Preview not created';

  @override
  String get outfitGiveNameBody => 'Give the outfit a name.';

  @override
  String get outfitNameMissingTitle => 'Name';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Choose at least one piece.';

  @override
  String outfitCreatedBody(String name) {
    return '$name is in your outfits.';
  }

  @override
  String get outfitSavedTitle => 'Saved';

  @override
  String get wardrobeAddedToFavouritesBody => 'Added to favourites';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Removed from favourites';

  @override
  String get wardrobeNotSavedTitle => 'Not saved';

  @override
  String get wardrobeLoggedAsWornBody => 'Logged as worn today.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Removed from your closet.';

  @override
  String get wardrobeDeletedTitle => 'Deleted';

  @override
  String get wardrobeNotDeletedTitle => 'Not deleted';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces removed from your closet.',
      one: '1 piece removed from your closet.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'AI Wardrobe Extraction';

  @override
  String get itemAddScanJobLabel => 'Scan';

  @override
  String get itemAddFoundEarlierBody => 'Found in an earlier scan';

  @override
  String get itemAddLookingAtPhoto => 'Looking at your photo';

  @override
  String get itemAddExtractionFailedBody => 'Extraction failed';

  @override
  String get itemAddJobFailedBody => 'Job failed';

  @override
  String get itemAddConnectionLostBody => 'Connection was lost. Try again.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Connection lost while processing.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Piece $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Piece';

  @override
  String get itemAddNotCancelledTitle => 'Not cancelled';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces are in your closet.',
      one: '1 piece is in your closet.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved of $total pieces saved. Tap save to try the rest again.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Some pieces not saved';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Choose at least one photo.';

  @override
  String get batchPhotoUnreadableBody => 'This photo could not be read.';

  @override
  String get batchNoPhotosReadableBody =>
      'None of these photos could be read. Try other photos.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'We lost the connection while working. Try again.';

  @override
  String get batchNotCancelledTitle => 'Not cancelled';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Post links are not supported. Enter a profile link.';

  @override
  String get batchLinkSpacesBody => 'Links cannot contain spaces.';

  @override
  String get batchEnterProfileLinkBody =>
      'Enter an Instagram or Facebook profile link.';

  @override
  String get batchEnterProfileLinkShortBody => 'Enter a profile link.';

  @override
  String get batchSignInPageNotOpenBody =>
      'The sign-in page did not open. Try again.';

  @override
  String get batchSignInBrowserBody =>
      'Sign in in your browser, then come back to FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Connect your account';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Enter the code from your authenticator app.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram wants a security check. Sign in in your browser first.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Enter your username and password again.';

  @override
  String get batchSignInFailedBody =>
      'Sign-in failed. Check your username and password.';

  @override
  String get batchSignInToKeepImportingBody => 'Sign in to keep importing.';

  @override
  String get batchAccountNotConnectedBody => 'Your account was not connected.';

  @override
  String get batchAccountConnectedTitle => 'Account connected';

  @override
  String get batchNotConnectedTitle => 'Not connected';

  @override
  String get batchImportConnectionLostBody =>
      'We lost the connection to the import. Refresh to check it.';

  @override
  String batchPickUpToBody(int max) {
    return 'Pick up to $max photos. We find the pieces.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count of $total photos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparing photo $done of $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Find pieces in $count photos',
      one: 'Find pieces in 1 photo',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Your $platform account uses two-step sign-in. Enter the 6-digit code from your authenticator app.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'This $platform profile is private or needs a sign-in to show its photos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Connect with $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos found so far',
      one: '1 photo found so far',
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
    return '$processed of $total processed · $added added · $waiting waiting · $skipped skipped';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Scanning photo $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Photo $number is next';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Photo $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pieces found',
      one: '1 piece found',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos were added to your closet.',
      one: '1 photo was added to your closet.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count more studio photos on the way. You can save what is ready, or leave — we will let you know.',
      one:
          '1 more studio photo on the way. You can save what is ready, or leave — we will let you know.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Not saved yet: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces pieces',
      one: '1 piece',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos photos',
      one: '1 photo',
    );
    return '$_temp0 from $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen chosen. Tap a piece to skip it.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saving $count pieces',
      one: 'Saving 1 piece',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count pieces',
      one: 'Save 1 piece',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Your body profile is saved.';

  @override
  String get bodyProfileSavedTitle => 'Saved';

  @override
  String get bodyProfileNotSavedTitle => 'Not saved';

  @override
  String get bodyProfileSetDefaultBody => 'Set as your default profile.';

  @override
  String get bodyProfileDeletedBody => 'Body profile deleted.';

  @override
  String get bodyProfileDeletedTitle => 'Deleted';

  @override
  String get bodyProfileNotDeletedTitle => 'Not deleted';

  @override
  String get feedbackNotSentTitle => 'Not sent';

  @override
  String get feedbackSentBody =>
      'Thanks. We read every message and reply if we need more.';

  @override
  String get feedbackSentTitle => 'Feedback sent';

  @override
  String get recommendUnnamedPiece => 'Unnamed piece';

  @override
  String get recommendEnterCityBody =>
      'Enter your city to get picks for the weather.';

  @override
  String get recommendWhichCityTitle => 'Which city?';

  @override
  String get aiConsentSheetTitle => 'Sharing photos with an AI service';

  @override
  String get aiConsentSheetBody =>
      'To create your try-on and photoshoot images, FitCheck AI sends the photos you provide (including images of your face and body) to a trusted third-party AI provider (such as OpenAI or Google Gemini) for processing. They generate your images and do not use them to train their models under our terms. Photos are transmitted securely and never shared for advertising.';

  @override
  String get aiConsentSheetPermission =>
      'By continuing, you give explicit permission to share your photos with these AI providers for image generation.';

  @override
  String get skeletonsLoadMoreFailed => 'Couldn\'t load more.';

  @override
  String get jobsPiecesReadyTitle => 'Your pieces are ready';

  @override
  String get jobsScanStoppedTitle => 'The scan stopped';

  @override
  String get jobsNothingSavedBody => 'Nothing was saved. Try again.';

  @override
  String get jobsPhotoUploadFailedBody => 'Photo upload failed.';

  @override
  String get authGoogleSignInStartFailed =>
      'Unable to start Google Sign-In. Please try again.';

  @override
  String get referralAppliedTitle => 'Referral Applied!';

  @override
  String get billingStoreUnavailableBody =>
      'Store purchases are not available on this device.';

  @override
  String get billingPurchaseProcessingBody =>
      'This purchase is still being processed. Reopen the app in a minute to see your plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'Avatar upload did not return an image URL.';

  @override
  String get rewardsDayStreakLabel => 'day streak';

  @override
  String rewardsBestStreak(int days) {
    return 'Best $days days';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return '$permission Access Needed';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Access to $permission is currently denied. Open Settings to allow it, then come back and try again.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Step $step of 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Remove image $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Remove image $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Email $email. We review reports within 24 hours.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Remove $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Add to \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" is removed. Its pieces stay in your closet.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Show all $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count left today';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Photo $index failed';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected of $max photos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape build · $tone skin';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Options for $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Most worn: $name, $count times';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: not set';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% match';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked of $max picked';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Remove $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return '$urgency priority';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'This plan is billed through the $store. Change or cancel it in your $store account settings.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Manage in the $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current of $max used';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'About ${seconds}s left';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done of $total studio photos ready';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready of $total studio photos ready. Tap a piece to skip it.';
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
  String get profileFieldNotSet => 'No';
}
