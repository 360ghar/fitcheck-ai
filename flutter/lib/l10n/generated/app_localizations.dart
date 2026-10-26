import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('en', 'AU'),
    Locale('en', 'CA'),
    Locale('en', 'GB'),
    Locale('es'),
    Locale('es', 'MX'),
    Locale('fi'),
    Locale('fr'),
    Locale('fr', 'CA'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('ko'),
    Locale('ml'),
    Locale('mr'),
    Locale('ms'),
    Locale('nl'),
    Locale('no'),
    Locale('or'),
    Locale('pa'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Brand name. Never translated.
  ///
  /// In en, this message translates to:
  /// **'FitCheck AI'**
  String get appName;

  /// Bottom navigation tab: the daily dashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// Bottom navigation tab: AI photoshoot generator.
  ///
  /// In en, this message translates to:
  /// **'Photoshoot'**
  String get tabPhotoshoot;

  /// Bottom navigation tab: the wardrobe.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get tabCloset;

  /// Bottom navigation tab: saved outfits.
  ///
  /// In en, this message translates to:
  /// **'Outfits'**
  String get tabOutfits;

  /// Bottom navigation tab: everything else.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// Floating action button on the closet tab.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get actionAddItem;

  /// Floating action button on the outfits tab.
  ///
  /// In en, this message translates to:
  /// **'Create outfit'**
  String get actionCreateOutfit;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get stateLoading;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// No description provided for @stateErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Try again. If it keeps failing, contact support.'**
  String get stateErrorBody;

  /// No description provided for @stateOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get stateOfflineTitle;

  /// No description provided for @stateOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to sync your closet and generate outfits.'**
  String get stateOfflineBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsPlanBilling.
  ///
  /// In en, this message translates to:
  /// **'Plan and billing'**
  String get settingsPlanBilling;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Measurement units'**
  String get settingsUnits;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get settingsPrivacySection;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get settingsDeleteAccountTitle;

  /// Delete-account dialog explanation.
  ///
  /// In en, this message translates to:
  /// **'This removes your closet, outfits, photos and profile. It cannot be undone.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsUnitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (in, lb)'**
  String get settingsUnitsImperial;

  /// No description provided for @settingsUnitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (cm, kg)'**
  String get settingsUnitsMetric;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSystem;

  /// No description provided for @languageSystemBody.
  ///
  /// In en, this message translates to:
  /// **'FitCheck AI follows your phone\'s language.'**
  String get languageSystemBody;

  /// No description provided for @languageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get languageSearchHint;

  /// No description provided for @languageCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get languageCurrent;

  /// No description provided for @languageReviewNote.
  ///
  /// In en, this message translates to:
  /// **'This translation is new. Tell us if something reads wrong.'**
  String get languageReviewNote;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageChanged;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get paywallTitle;

  /// No description provided for @paywallTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'1 month free'**
  String get paywallTrialBadge;

  /// No description provided for @paywallTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first month of Pro is free'**
  String get paywallTrialTitle;

  /// No description provided for @paywallTrialBody.
  ///
  /// In en, this message translates to:
  /// **'Upload your whole closet at once. Add pieces as you go after that.'**
  String get paywallTrialBody;

  /// No description provided for @paywallFreeForeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Free forever'**
  String get paywallFreeForeverTitle;

  /// Free plan summary on the paywall.
  ///
  /// In en, this message translates to:
  /// **'No card needed. Every month you get {uploads} AI uploads, {outfits} outfits and {images} photoshoot images a day.'**
  String paywallFreeForeverBody(int uploads, int outfits, int images);

  /// No description provided for @paywallCtaTrial.
  ///
  /// In en, this message translates to:
  /// **'Start my free month'**
  String get paywallCtaTrial;

  /// Upgrade button naming the plan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to {plan}'**
  String paywallCtaUpgrade(String plan);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get paywallManage;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get paywallTerms;

  /// No description provided for @paywallPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get paywallPrivacy;

  /// No description provided for @paywallPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get paywallPerMonth;

  /// No description provided for @paywallPerYear.
  ///
  /// In en, this message translates to:
  /// **'per year'**
  String get paywallPerYear;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get paywallBestValue;

  /// App Store-required trial disclosure.
  ///
  /// In en, this message translates to:
  /// **'Free trial for new subscribers only. After the trial, Pro renews at {price} unless cancelled at least 24 hours before it ends.'**
  String paywallTrialEligibleOnly(String price);

  /// No description provided for @introTitle.
  ///
  /// In en, this message translates to:
  /// **'Your closet, finally organised'**
  String get introTitle;

  /// No description provided for @introBody.
  ///
  /// In en, this message translates to:
  /// **'Photograph your clothes once. Get outfit ideas, try-on previews and studio photos from what you already own.'**
  String get introBody;

  /// No description provided for @introStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get introStart;

  /// No description provided for @introHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get introHaveAccount;

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUp;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueApple;

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// No description provided for @authOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDivider;

  /// No description provided for @wardrobeTitle.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get wardrobeTitle;

  /// No description provided for @wardrobeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your closet is empty'**
  String get wardrobeEmptyTitle;

  /// No description provided for @wardrobeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first piece, or upload a photo of the whole rail at once.'**
  String get wardrobeEmptyBody;

  /// No description provided for @wardrobeAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first item'**
  String get wardrobeAddFirst;

  /// No description provided for @wardrobeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your closet'**
  String get wardrobeSearchHint;

  /// No description provided for @categoryTops.
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get categoryTops;

  /// No description provided for @categoryBottoms.
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get categoryBottoms;

  /// No description provided for @categoryShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get categoryShoes;

  /// No description provided for @categoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryAccessories;

  /// No description provided for @categoryOuterwear.
  ///
  /// In en, this message translates to:
  /// **'Outerwear'**
  String get categoryOuterwear;

  /// No description provided for @categorySwimwear.
  ///
  /// In en, this message translates to:
  /// **'Swimwear'**
  String get categorySwimwear;

  /// No description provided for @categoryActivewear.
  ///
  /// In en, this message translates to:
  /// **'Activewear'**
  String get categoryActivewear;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @conditionClean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get conditionClean;

  /// No description provided for @conditionDirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get conditionDirty;

  /// No description provided for @conditionLaundry.
  ///
  /// In en, this message translates to:
  /// **'In laundry'**
  String get conditionLaundry;

  /// No description provided for @conditionRepair.
  ///
  /// In en, this message translates to:
  /// **'Needs repair'**
  String get conditionRepair;

  /// No description provided for @conditionDonate.
  ///
  /// In en, this message translates to:
  /// **'To donate'**
  String get conditionDonate;

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @seasonFall.
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get seasonFall;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// No description provided for @seasonAll.
  ///
  /// In en, this message translates to:
  /// **'All season'**
  String get seasonAll;

  /// No description provided for @styleCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get styleCasual;

  /// No description provided for @styleFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get styleFormal;

  /// No description provided for @styleBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get styleBusiness;

  /// No description provided for @styleSporty.
  ///
  /// In en, this message translates to:
  /// **'Sporty'**
  String get styleSporty;

  /// No description provided for @styleBohemian.
  ///
  /// In en, this message translates to:
  /// **'Bohemian'**
  String get styleBohemian;

  /// No description provided for @styleStreetwear.
  ///
  /// In en, this message translates to:
  /// **'Streetwear'**
  String get styleStreetwear;

  /// No description provided for @styleVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get styleVintage;

  /// No description provided for @styleMinimalist.
  ///
  /// In en, this message translates to:
  /// **'Minimalist'**
  String get styleMinimalist;

  /// No description provided for @styleRomantic.
  ///
  /// In en, this message translates to:
  /// **'Romantic'**
  String get styleRomantic;

  /// No description provided for @styleEdgy.
  ///
  /// In en, this message translates to:
  /// **'Edgy'**
  String get styleEdgy;

  /// No description provided for @stylePreppy.
  ///
  /// In en, this message translates to:
  /// **'Preppy'**
  String get stylePreppy;

  /// No description provided for @styleArtsy.
  ///
  /// In en, this message translates to:
  /// **'Artsy'**
  String get styleArtsy;

  /// No description provided for @styleClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get styleClassic;

  /// No description provided for @styleElegant.
  ///
  /// In en, this message translates to:
  /// **'Elegant'**
  String get styleElegant;

  /// No description provided for @styleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get styleOther;

  /// No description provided for @occasionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get occasionWork;

  /// No description provided for @occasionDateNight.
  ///
  /// In en, this message translates to:
  /// **'Date night'**
  String get occasionDateNight;

  /// No description provided for @occasionTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get occasionTravel;

  /// No description provided for @occasionWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get occasionWedding;

  /// No description provided for @occasionGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get occasionGym;

  /// No description provided for @occasionWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get occasionWeekend;

  /// No description provided for @occasionParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get occasionParty;

  /// No description provided for @occasionInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get occasionInterview;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorGrey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get colorGrey;

  /// No description provided for @colorNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy'**
  String get colorNavy;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorBeige.
  ///
  /// In en, this message translates to:
  /// **'Beige'**
  String get colorBeige;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Relative date in the past.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String dateDaysAgo(int count);

  /// Relative date, 1 to 4 weeks ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String dateWeeksAgo(int count);

  /// Relative date, 1 to 11 months ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String dateMonthsAgo(int count);

  /// Relative date, a year or more ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String dateYearsAgo(int count);

  /// No description provided for @ratingPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying FitCheck AI?'**
  String get ratingPromptTitle;

  /// No description provided for @ratingPromptBody.
  ///
  /// In en, this message translates to:
  /// **'A quick rating helps other people find their style.'**
  String get ratingPromptBody;

  /// No description provided for @ratingPromptYes.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get ratingPromptYes;

  /// No description provided for @ratingPromptNo.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get ratingPromptNo;

  /// Shown when filters or search return nothing.
  ///
  /// In en, this message translates to:
  /// **'No pieces match'**
  String get closetNoMatchesTitle;

  /// Hint under the no-matches title.
  ///
  /// In en, this message translates to:
  /// **'Try fewer filters or another search.'**
  String get closetNoMatchesBody;

  /// Button that resets every closet filter.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get closetClearFilters;

  /// Total pieces in the closet, under the screen title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 piece} other{{count} pieces}}'**
  String closetPieceCount(int count);

  /// Subtitle while the first page loads.
  ///
  /// In en, this message translates to:
  /// **'Loading your pieces'**
  String get closetLoading;

  /// Title while items are selected in the grid.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String closetSelectedCount(int count);

  /// Icon tooltip in selection mode.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get closetDeleteSelected;

  /// Icon tooltip that leaves selection mode.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get closetCancelSelection;

  /// Icon tooltip that closes the search field.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closetCloseSearch;

  /// View toggle tooltip.
  ///
  /// In en, this message translates to:
  /// **'Show as grid'**
  String get closetShowGrid;

  /// View toggle tooltip.
  ///
  /// In en, this message translates to:
  /// **'Show as list'**
  String get closetShowList;

  /// View toggle tooltip.
  ///
  /// In en, this message translates to:
  /// **'Show as rows'**
  String get closetShowRows;

  /// Menu item opening the closet statistics screen.
  ///
  /// In en, this message translates to:
  /// **'Closet stats'**
  String get closetStatsTitle;

  /// Confirmation dialog title for deleting closet items.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 piece?} other{Delete {count} pieces?}}'**
  String closetDeleteTitle(int count);

  /// Confirmation dialog body for deleting closet items.
  ///
  /// In en, this message translates to:
  /// **'Outfits that use them lose these pieces.'**
  String get closetDeleteBody;

  /// Title of the sort sheet.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get closetSortBy;

  /// Filter chip showing only favourite pieces.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get closetFavourites;

  /// Action that marks a piece as a favourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get closetFavourite;

  /// Action that unmarks a favourite piece.
  ///
  /// In en, this message translates to:
  /// **'Remove favourite'**
  String get closetUnfavourite;

  /// Action that logs a wear for a piece.
  ///
  /// In en, this message translates to:
  /// **'Wore it today'**
  String get closetWoreToday;

  /// Wear count in the closet list row.
  ///
  /// In en, this message translates to:
  /// **'Worn {count}×'**
  String closetWornTimes(int count);

  /// Section label in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get closetCategoryLabel;

  /// Section label in the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Use case'**
  String get closetUseCaseLabel;

  /// Filter chip that clears the use-case filter.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get closetAnyUseCase;

  /// Text field label for a custom use case.
  ///
  /// In en, this message translates to:
  /// **'Other use case'**
  String get closetOtherUseCase;

  /// Placeholder example for a custom use case.
  ///
  /// In en, this message translates to:
  /// **'For example, brunch'**
  String get closetOtherUseCaseHint;

  /// Confirms the typed custom use case.
  ///
  /// In en, this message translates to:
  /// **'Use this'**
  String get closetUseUseCase;

  /// Button that resets every filter in the sheet.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get closetClearAll;

  /// Closet sort order.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewest;

  /// Closet sort order.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldest;

  /// Closet sort order.
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get sortName;

  /// Closet sort order.
  ///
  /// In en, this message translates to:
  /// **'Most worn'**
  String get sortMostWorn;

  /// Onboarding and filter use case.
  ///
  /// In en, this message translates to:
  /// **'Informal'**
  String get useCaseInformal;

  /// Onboarding and filter use case.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get useCaseDate;

  /// Onboarding and filter use case.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get useCaseDinner;

  /// Onboarding and filter use case.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get useCaseLunch;

  /// Generic action: enter multi-select mode.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get actionSelect;

  /// Generic action: edit a record.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Generic action: open the filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// Generic action: open the sort sheet.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get actionSort;

  /// Generic chip that clears the active filter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get actionAll;

  /// Snapshot card title when the closet is empty.
  ///
  /// In en, this message translates to:
  /// **'Start your closet'**
  String get dashboardStartClosetTitle;

  /// Snapshot card body when the closet is empty.
  ///
  /// In en, this message translates to:
  /// **'Photograph a few pieces. We tag them for you.'**
  String get dashboardStartClosetBody;

  /// Figure label: number of closet pieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get dashboardPieces;

  /// Figure label: number of saved outfits.
  ///
  /// In en, this message translates to:
  /// **'outfits'**
  String get dashboardOutfits;

  /// Figure label: consecutive days of wear logging.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dashboardDayStreak;

  /// Note under a dashboard figure for this month's growth.
  ///
  /// In en, this message translates to:
  /// **'+{count} this month'**
  String dashboardAddedThisMonth(int count);

  /// Note under the streak figure: the all-time best run.
  ///
  /// In en, this message translates to:
  /// **'Best {count}'**
  String dashboardBestStreak(int count);

  /// Shortcut to favourite pieces.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 favourite} other{{count} favourites}}'**
  String dashboardFavourites(int count);

  /// Shortcut to saved outfits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved outfit} other{{count} saved outfits}}'**
  String dashboardSavedOutfits(int count);

  /// Footer line naming the most worn piece.
  ///
  /// In en, this message translates to:
  /// **'Most worn: {name}, {count} times'**
  String dashboardMostWorn(String name, int count);

  /// Skips the whole first-run setup.
  ///
  /// In en, this message translates to:
  /// **'Skip setup'**
  String get setupSkip;

  /// Setup step 1 title.
  ///
  /// In en, this message translates to:
  /// **'Who are we styling?'**
  String get setupWhoTitle;

  /// Setup step 1 body.
  ///
  /// In en, this message translates to:
  /// **'Sets the model for try-on and photoshoots. You can change it in your profile.'**
  String get setupWhoBody;

  /// Setup step 2 title.
  ///
  /// In en, this message translates to:
  /// **'What do you wear most?'**
  String get setupStyleTitle;

  /// Setup step 2 body.
  ///
  /// In en, this message translates to:
  /// **'Pick any. Outfit ideas start from these.'**
  String get setupStyleBody;

  /// Setup step 3 title.
  ///
  /// In en, this message translates to:
  /// **'Add your first pieces.'**
  String get setupClosetTitle;

  /// Setup step 3 body.
  ///
  /// In en, this message translates to:
  /// **'Photograph a few clothes, or a pile of them. Each piece is cut out and filed for you.'**
  String get setupClosetBody;

  /// Primary button that opens the camera flow.
  ///
  /// In en, this message translates to:
  /// **'Add clothes'**
  String get setupAddClothes;

  /// Chip group label: style choices.
  ///
  /// In en, this message translates to:
  /// **'Styles'**
  String get setupStylesLabel;

  /// Chip group label: occasion choices.
  ///
  /// In en, this message translates to:
  /// **'Occasions'**
  String get setupOccasionsLabel;

  /// Skips the current setup step only.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get setupSkipStep;

  /// Leaves the last setup step without adding clothes.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get setupLater;

  /// Error dialog title when a setup step fails to save.
  ///
  /// In en, this message translates to:
  /// **'Could not save'**
  String get setupSaveError;

  /// Try-on model gender option.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get genderWomen;

  /// Try-on model gender option.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get genderMen;

  /// Try-on model gender option.
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get genderNonBinary;

  /// Try-on model gender option: no answer.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// Empty outfits grid title.
  ///
  /// In en, this message translates to:
  /// **'No outfits yet'**
  String get outfitEmptyTitle;

  /// Empty outfits grid body.
  ///
  /// In en, this message translates to:
  /// **'Pair pieces from your closet and save the look.'**
  String get outfitEmptyBody;

  /// Shown when outfit filters return nothing.
  ///
  /// In en, this message translates to:
  /// **'No outfits match'**
  String get outfitNoMatchesTitle;

  /// Search field hint on the outfits tab.
  ///
  /// In en, this message translates to:
  /// **'Search your outfits'**
  String get outfitSearchHint;

  /// Subtitle while the first page of outfits loads.
  ///
  /// In en, this message translates to:
  /// **'Loading your outfits'**
  String get outfitLoading;

  /// Total saved outfits under the screen title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 outfit} other{{count} outfits}}'**
  String outfitCount(int count);

  /// Menu item and sheet title for outfit filters.
  ///
  /// In en, this message translates to:
  /// **'Style and season'**
  String get outfitFilterMenu;

  /// Menu item opening saved collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get outfitCollections;

  /// Action that copies an outfit.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get outfitDuplicate;

  /// Confirmation dialog title.
  ///
  /// In en, this message translates to:
  /// **'Delete this outfit?'**
  String get outfitDeleteTitle;

  /// Confirmation dialog body: deleting an outfit keeps the garments.
  ///
  /// In en, this message translates to:
  /// **'Its pieces stay in your closet.'**
  String get outfitDeleteBody;

  /// Filter chip showing unfinished outfits.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get outfitDrafts;

  /// Badge on an unfinished outfit card.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get outfitDraft;

  /// Section label in a filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get filterStyle;

  /// Section label in a filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get filterSeason;

  /// Confirmation dialog title on the item detail screen.
  ///
  /// In en, this message translates to:
  /// **'Delete this piece?'**
  String get itemDetailDeleteTitle;

  /// Confirmation dialog body on the item detail screen.
  ///
  /// In en, this message translates to:
  /// **'Outfits that use it lose this piece.'**
  String get itemDetailDeleteBody;

  /// Item detail action that marks the piece as a favourite.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get itemAddFavourite;

  /// Garment size in the item summary line.
  ///
  /// In en, this message translates to:
  /// **'Size {size}'**
  String itemSize(String size);

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get itemColours;

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get itemMaterial;

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get itemPattern;

  /// Detail row label: occasions the piece suits.
  ///
  /// In en, this message translates to:
  /// **'Use cases'**
  String get itemUseCases;

  /// Detail row label: where the piece is stored.
  ///
  /// In en, this message translates to:
  /// **'Kept in'**
  String get itemKeptIn;

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get itemPrice;

  /// Detail row label: purchase date.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get itemBought;

  /// Detail row label.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get itemTags;

  /// Detail row label: when the piece was added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get itemAdded;

  /// Caption under the lifetime wear count.
  ///
  /// In en, this message translates to:
  /// **'times worn'**
  String get itemTimesWornLabel;

  /// Caption under the last wear date.
  ///
  /// In en, this message translates to:
  /// **'last worn'**
  String get itemLastWornLabel;

  /// Shown instead of a date when a piece was never worn.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get itemNeverWorn;

  /// One-line pitch on the signed-out landing screen.
  ///
  /// In en, this message translates to:
  /// **'Every piece you own, styled by AI. Plan outfits, try them on, shoot them.'**
  String get authEntryBody;

  /// Primary button on the signed-out landing screen.
  ///
  /// In en, this message translates to:
  /// **'Create your closet'**
  String get authCreateCloset;

  /// Sign-in screen title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// Sign-in screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to open your closet.'**
  String get authSignInBody;

  /// Link from sign-in to sign-up.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAccount;

  /// Sign-up screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'It takes a minute. Your first items are free.'**
  String get authCreateClosetBody;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Referral code (optional)'**
  String get authReferralCode;

  /// Forgot-password screen title.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authResetTitle;

  /// Forgot-password screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'We will email you a link to choose a new one.'**
  String get authResetBody;

  /// Forgot-password primary button.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// Link back to the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// Form validation error: email field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEnterEmail;

  /// Form validation error: email is malformed.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get authEnterValidEmail;

  /// Form validation error: password field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authEnterPassword;

  /// Form validation error: password is too short.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authPasswordTooShort;

  /// Icon tooltip that reveals the password field.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Icon tooltip that hides the password field.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Prompt before the create-account link.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get authNewHere;

  /// Banner asking the user to verify their email address.
  ///
  /// In en, this message translates to:
  /// **'Confirm {email} before you sign in. Check your inbox.'**
  String authConfirmEmail(String email);

  /// Button that resends the verification email.
  ///
  /// In en, this message translates to:
  /// **'Send it again'**
  String get authResendEmail;

  /// Progress label while resending the verification email.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get authResendingEmail;

  /// Form validation error on sign-up.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// Form validation error: name field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authEnterName;

  /// Form validation error: password field is empty on sign-up.
  ///
  /// In en, this message translates to:
  /// **'Choose a password'**
  String get authChoosePassword;

  /// Prompt before the sign-in link on sign-up.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get authHaveAccount;

  /// Accessibility label: referral code is valid.
  ///
  /// In en, this message translates to:
  /// **'Code accepted'**
  String get authCodeAccepted;

  /// Accessibility label: referral code is invalid.
  ///
  /// In en, this message translates to:
  /// **'Code not found'**
  String get authCodeNotFound;

  /// Helper text naming the referrer.
  ///
  /// In en, this message translates to:
  /// **'From {name}. You both get a month free.'**
  String authReferralFrom(String name);

  /// Helper text when the referral code is unknown.
  ///
  /// In en, this message translates to:
  /// **'We could not find this code.'**
  String get authReferralInvalid;

  /// Confirmation after a reset email is sent.
  ///
  /// In en, this message translates to:
  /// **'Sent to {email}. Open the link on this phone.'**
  String authResetSent(String email);

  /// Intro sheet 1 title.
  ///
  /// In en, this message translates to:
  /// **'Snap your closet once.'**
  String get introSlide1Title;

  /// Intro sheet 1 body.
  ///
  /// In en, this message translates to:
  /// **'Photograph a pile of clothes. Every piece is cut out and filed for you.'**
  String get introSlide1Body;

  /// Intro sheet 2 title.
  ///
  /// In en, this message translates to:
  /// **'Get dressed faster.'**
  String get introSlide2Title;

  /// Intro sheet 2 body.
  ///
  /// In en, this message translates to:
  /// **'Outfits from what you own, matched to your plans and the weather.'**
  String get introSlide2Body;

  /// Intro sheet 3 title.
  ///
  /// In en, this message translates to:
  /// **'See it before you wear it.'**
  String get introSlide3Title;

  /// Intro sheet 3 body.
  ///
  /// In en, this message translates to:
  /// **'Try looks on your own photo, or shoot them like a campaign.'**
  String get introSlide3Body;

  /// Segmented control label: colour scheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme option: follow the device.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Segmented control label: weather unit.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get settingsTemperature;

  /// Notification switch title.
  ///
  /// In en, this message translates to:
  /// **'Email updates'**
  String get settingsEmailUpdates;

  /// Notification switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'News and tips by email'**
  String get settingsEmailUpdatesBody;

  /// Notification switch title.
  ///
  /// In en, this message translates to:
  /// **'Outfit reminders'**
  String get settingsOutfitReminders;

  /// Notification switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'A nudge to log what you wore'**
  String get settingsOutfitRemindersBody;

  /// Notification switch title.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get settingsWeeklySummary;

  /// Notification switch subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your week in outfits'**
  String get settingsWeeklySummaryBody;

  /// Group title for taste preferences.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get settingsStyleSection;

  /// Row that opens the styles sheet.
  ///
  /// In en, this message translates to:
  /// **'Styles you like'**
  String get settingsPreferredStyles;

  /// Row that opens the colours sheet.
  ///
  /// In en, this message translates to:
  /// **'Colours you like'**
  String get settingsPreferredColours;

  /// Subtitle when no preference is selected.
  ///
  /// In en, this message translates to:
  /// **'None chosen'**
  String get settingsNoneChosen;

  /// Group title for billing and AI rows.
  ///
  /// In en, this message translates to:
  /// **'Plan and AI'**
  String get settingsPlanAiSection;

  /// Subtitle when the paywall is enabled.
  ///
  /// In en, this message translates to:
  /// **'Plan, usage and upgrades'**
  String get settingsPlanBillingBody;

  /// Subtitle when the paywall is disabled.
  ///
  /// In en, this message translates to:
  /// **'Plan and usage'**
  String get settingsPlanUsageBody;

  /// Row that opens the referral screen.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get settingsInviteFriends;

  /// Referral row subtitle.
  ///
  /// In en, this message translates to:
  /// **'A free month for each friend who joins'**
  String get settingsInviteFriendsBody;

  /// Row that opens the bring-your-own-model screen.
  ///
  /// In en, this message translates to:
  /// **'AI provider'**
  String get settingsAiProvider;

  /// AI provider row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your own model for tagging and images'**
  String get settingsAiProviderBody;

  /// Row showing the build version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;

  /// Row that opens the legal screen.
  ///
  /// In en, this message translates to:
  /// **'Privacy and terms'**
  String get settingsPrivacyTerms;

  /// Row that opens the feedback screen.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get settingsReportProblem;

  /// Row and dialog title.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// Row and dialog title.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get settingsExportData;

  /// Export dialog explanation.
  ///
  /// In en, this message translates to:
  /// **'We prepare a file with everything you saved and open the download.'**
  String get settingsExportBody;

  /// Export dialog confirm button.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExportAction;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get settingsCurrentPassword;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settingsNewPassword;

  /// Password field label.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get settingsConfirmNewPassword;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get settingsEnterCurrentPassword;

  /// Validation error.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get settingsEnterNewPassword;

  /// Validation error: password is too short.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get settingsPasswordMin8;

  /// Validation error: missing uppercase.
  ///
  /// In en, this message translates to:
  /// **'Add an uppercase letter'**
  String get settingsPasswordNeedsUpper;

  /// Validation error: missing lowercase.
  ///
  /// In en, this message translates to:
  /// **'Add a lowercase letter'**
  String get settingsPasswordNeedsLower;

  /// Validation error: missing digit.
  ///
  /// In en, this message translates to:
  /// **'Add a number'**
  String get settingsPasswordNeedsDigit;

  /// Validation error on the confirm field.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match'**
  String get settingsPasswordsNoMatch;

  /// Change-password dialog confirm button.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get settingsChangeAction;

  /// Add-page card title above the camera buttons.
  ///
  /// In en, this message translates to:
  /// **'Snap a piece'**
  String get itemAddSnapTitle;

  /// Add-page card explanation.
  ///
  /// In en, this message translates to:
  /// **'We find every piece in the photo and make a clean studio shot of each.'**
  String get itemAddSnapBody;

  /// Button that opens the camera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get itemAddCamera;

  /// Button that opens the photo library.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get itemAddGallery;

  /// Section title above the secondary add options.
  ///
  /// In en, this message translates to:
  /// **'Other ways to add'**
  String get itemAddOtherWays;

  /// Option row: batch upload.
  ///
  /// In en, this message translates to:
  /// **'Add several photos'**
  String get itemAddSeveral;

  /// Batch upload row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 50 at once'**
  String get itemAddSeveralBody;

  /// Option row: import from a social profile.
  ///
  /// In en, this message translates to:
  /// **'Import from a profile'**
  String get itemAddImportProfile;

  /// Social import row subtitle.
  ///
  /// In en, this message translates to:
  /// **'Instagram or Facebook'**
  String get itemAddImportProfileBody;

  /// Option row: manual entry without a photo.
  ///
  /// In en, this message translates to:
  /// **'Enter details yourself'**
  String get itemAddEnterDetails;

  /// Manual entry row subtitle.
  ///
  /// In en, this message translates to:
  /// **'No photo needed'**
  String get itemAddEnterDetailsBody;

  /// Helper line at the top of the manual entry form.
  ///
  /// In en, this message translates to:
  /// **'Only a name is needed. Add the rest now or later.'**
  String get itemManualIntro;

  /// Placeholder example for the item name field.
  ///
  /// In en, this message translates to:
  /// **'For example, blue cotton tee'**
  String get itemManualNameHint;

  /// Validation error: item name is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get itemManualEnterName;

  /// Form field label: free-text description.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get itemManualNotes;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get itemManualBrand;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get itemManualSize;

  /// Validation error: price is not numeric.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get itemManualEnterNumber;

  /// Primary button that saves the item.
  ///
  /// In en, this message translates to:
  /// **'Save piece'**
  String get itemManualSavePiece;

  /// Progress label while saving an item.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get itemManualSaving;

  /// Success dialog title after saving an item.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get itemManualSavedTitle;

  /// Success dialog body naming the saved item.
  ///
  /// In en, this message translates to:
  /// **'{name} is in your closet.'**
  String itemManualSavedBody(String name);

  /// Error dialog title when saving an item fails.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get itemManualNotSaved;

  /// Text field label for a custom use case.
  ///
  /// In en, this message translates to:
  /// **'Add a use case'**
  String get itemManualAddUseCase;

  /// Icon tooltip that adds the typed use case.
  ///
  /// In en, this message translates to:
  /// **'Add use case'**
  String get itemManualAddUseCaseAction;

  /// Section title for the photo strip.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get itemPhotos;

  /// Button that adds more photos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get itemAddPhotos;

  /// Placeholder in an empty photo strip.
  ///
  /// In en, this message translates to:
  /// **'No photo yet. You can save without one.'**
  String get itemNoPhotoYet;

  /// Icon tooltip on a thumbnail.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get itemRemovePhoto;

  /// Icon tooltip that drops an extracted piece.
  ///
  /// In en, this message translates to:
  /// **'Remove piece'**
  String get itemRemovePiece;

  /// Section or field label: garment condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get filterConditionLabel;

  /// Photoshoot step 1 name.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photoshootStepPhotos;

  /// Photoshoot step 2 name.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get photoshootStepSetup;

  /// Photoshoot step 3 name.
  ///
  /// In en, this message translates to:
  /// **'Creating'**
  String get photoshootStepCreating;

  /// Photoshoot step 4 name.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get photoshootStepResults;

  /// Accessibility label for the step track.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}, {name}'**
  String photoshootStepOf(int current, int total, String name);

  /// Banner when a single generated image failed.
  ///
  /// In en, this message translates to:
  /// **'One photo failed. Retry it below.'**
  String get photoshootOneFailed;

  /// Banner when several generated images failed.
  ///
  /// In en, this message translates to:
  /// **'{count} photos failed. Retry each one below.'**
  String photoshootManyFailed(int count);

  /// Section title: aspect ratio.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get photoshootFormat;

  /// Section title: number of images.
  ///
  /// In en, this message translates to:
  /// **'How many'**
  String get photoshootHowMany;

  /// Text field label for a custom photoshoot prompt.
  ///
  /// In en, this message translates to:
  /// **'Your prompt'**
  String get photoshootYourPrompt;

  /// Placeholder example for a custom prompt.
  ///
  /// In en, this message translates to:
  /// **'Golden hour on a rooftop, linen shirt'**
  String get photoshootPromptHint;

  /// Primary button that starts a photoshoot.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Create 1 photo} other{Create {count} photos}}'**
  String photoshootCreatePhotos(int count);

  /// Unit label next to the image count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{photo} other{photos}}'**
  String photoshootCountPhoto(int count);

  /// Shown when the usage fetch fails.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t check today\'s limit.'**
  String get photoshootLimitUnknown;

  /// Remaining image allowance for the day.
  ///
  /// In en, this message translates to:
  /// **'{plan} plan: {remaining} of {limit} left today'**
  String photoshootUsagePlan(String plan, int remaining, int limit);

  /// Plan label for a paying user. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get photoshootPlanPro;

  /// Plan label for a free user.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get photoshootPlanFree;

  /// Button that opens the photo library.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get photoshootGallery;

  /// Button that opens the camera.
  ///
  /// In en, this message translates to:
  /// **'Use camera'**
  String get photoshootUseCamera;

  /// Accessibility label on a selected photo thumbnail.
  ///
  /// In en, this message translates to:
  /// **'Remove photo {number}'**
  String photoshootRemovePhotoNumber(int number);

  /// Results screen when generation returned nothing.
  ///
  /// In en, this message translates to:
  /// **'No photos came back'**
  String get photoshootNoPhotosTitle;

  /// Results screen body for an empty result.
  ///
  /// In en, this message translates to:
  /// **'The shoot finished without images. Try again.'**
  String get photoshootNoPhotosBody;

  /// Button that returns to the setup step.
  ///
  /// In en, this message translates to:
  /// **'New style'**
  String get photoshootNewStyle;

  /// Button that returns to the upload step.
  ///
  /// In en, this message translates to:
  /// **'New photos'**
  String get photoshootNewPhotos;

  /// Accessibility label on a generated image.
  ///
  /// In en, this message translates to:
  /// **'Open photo {number}'**
  String photoshootOpenPhoto(int number);

  /// Icon tooltip on a generated image.
  ///
  /// In en, this message translates to:
  /// **'Report photo'**
  String get photoshootReportPhoto;

  /// Action that downloads a generated image.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get photoshootSaveToGallery;

  /// Generic action: open the paywall.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get actionUpgrade;

  /// Dialog title when the daily photo allowance is spent.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used today\'s photos'**
  String get referralLimitTitle;

  /// Dialog body offering the referral route.
  ///
  /// In en, this message translates to:
  /// **'Your free photos come back tomorrow. Refer a friend and you both get a month of Pro free.'**
  String get referralLimitBody;

  /// Dialog action that opens the referral screen.
  ///
  /// In en, this message translates to:
  /// **'Refer a friend'**
  String get referralLimitRefer;

  /// Photoshoot style preset. Platform name, not translated.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get photoshootUseLinkedin;

  /// Photoshoot style preset.
  ///
  /// In en, this message translates to:
  /// **'Dating app'**
  String get photoshootUseDating;

  /// Photoshoot style preset.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get photoshootUsePortfolio;

  /// Photoshoot style preset. Platform name, not translated.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get photoshootUseInstagram;

  /// Photoshoot style preset.
  ///
  /// In en, this message translates to:
  /// **'Aesthetic'**
  String get photoshootUseAesthetic;

  /// Photoshoot style preset: free-text prompt.
  ///
  /// In en, this message translates to:
  /// **'Your own prompt'**
  String get photoshootUseCustom;

  /// Photoshoot preset description.
  ///
  /// In en, this message translates to:
  /// **'Sharp headshots for work'**
  String get photoshootDescLinkedin;

  /// Photoshoot preset description.
  ///
  /// In en, this message translates to:
  /// **'Relaxed, warm and natural'**
  String get photoshootDescDating;

  /// Photoshoot preset description.
  ///
  /// In en, this message translates to:
  /// **'Editorial, high-fashion looks'**
  String get photoshootDescPortfolio;

  /// Photoshoot preset description.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle shots for your feed'**
  String get photoshootDescInstagram;

  /// Photoshoot preset description.
  ///
  /// In en, this message translates to:
  /// **'Moody, artistic frames'**
  String get photoshootDescAesthetic;

  /// Photoshoot preset description.
  ///
  /// In en, this message translates to:
  /// **'Describe the look you want'**
  String get photoshootDescCustom;

  /// Aspect ratio preset 1:1.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get aspectSquare;

  /// Aspect ratio preset 9:16.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get aspectPortrait;

  /// Aspect ratio preset 16:9.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get aspectLandscape;

  /// Aspect ratio preset 3:4.
  ///
  /// In en, this message translates to:
  /// **'Tall'**
  String get aspectTall;

  /// Aspect ratio preset 4:3.
  ///
  /// In en, this message translates to:
  /// **'Wide'**
  String get aspectWide;

  /// Try-on screen app bar title.
  ///
  /// In en, this message translates to:
  /// **'Virtual try-on'**
  String get tryOnAppBar;

  /// Section title: the user's own photo.
  ///
  /// In en, this message translates to:
  /// **'Your photo'**
  String get tryOnYourPhoto;

  /// Section title: the piece to try on.
  ///
  /// In en, this message translates to:
  /// **'Garment'**
  String get tryOnGarment;

  /// Progress label while the body photo uploads.
  ///
  /// In en, this message translates to:
  /// **'Uploading your photo'**
  String get tryOnUploadingPhoto;

  /// Empty state for the body photo.
  ///
  /// In en, this message translates to:
  /// **'Add a full-body photo of yourself'**
  String get tryOnAddPhotoPrompt;

  /// Hint under the body photo.
  ///
  /// In en, this message translates to:
  /// **'A full-body photo works best'**
  String get tryOnBodyPhotoHint;

  /// Button that opens the photo picker.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get tryOnAddPhoto;

  /// Button that replaces the body photo.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get tryOnChangePhoto;

  /// Error text when the body photo fails to load.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your photo.'**
  String get tryOnPhotoLoadFailed;

  /// Accessibility label for the garment picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a garment photo'**
  String get tryOnChooseGarment;

  /// Empty state for the garment picker.
  ///
  /// In en, this message translates to:
  /// **'Choose one garment photo'**
  String get tryOnChooseOneGarment;

  /// Hint under the garment picker.
  ///
  /// In en, this message translates to:
  /// **'A flat lay or a hanger shot works best'**
  String get tryOnGarmentHint;

  /// Button that replaces the chosen garment.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get tryOnChange;

  /// Button that opens the camera for a garment.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get tryOnCamera;

  /// Button that clears the chosen garment.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get tryOnRemove;

  /// Section title for the styling options.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get tryOnLookTitle;

  /// Dropdown label.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get tryOnStyle;

  /// Dropdown label.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get tryOnBackground;

  /// Dropdown label.
  ///
  /// In en, this message translates to:
  /// **'Pose'**
  String get tryOnPose;

  /// Progress text while the try-on renders.
  ///
  /// In en, this message translates to:
  /// **'Dressing you up. This takes about half a minute.'**
  String get tryOnDressingUp;

  /// Placeholder before a try-on exists.
  ///
  /// In en, this message translates to:
  /// **'Your try-on appears here'**
  String get tryOnEmptyResult;

  /// Icon tooltip on a generated try-on.
  ///
  /// In en, this message translates to:
  /// **'Report image'**
  String get tryOnReportImage;

  /// Primary button label while generating.
  ///
  /// In en, this message translates to:
  /// **'Creating'**
  String get tryOnCreating;

  /// Primary button label when a result exists.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryOnTryAgain;

  /// Primary button label that starts generation.
  ///
  /// In en, this message translates to:
  /// **'Create try-on'**
  String get tryOnCreate;

  /// Try-on background preset.
  ///
  /// In en, this message translates to:
  /// **'Studio white'**
  String get tryOnBackgroundStudioWhite;

  /// Try-on background preset.
  ///
  /// In en, this message translates to:
  /// **'Studio grey'**
  String get tryOnBackgroundStudioGrey;

  /// Try-on background preset.
  ///
  /// In en, this message translates to:
  /// **'Urban street'**
  String get tryOnBackgroundUrban;

  /// Try-on background preset.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get tryOnBackgroundNature;

  /// Try-on background preset.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get tryOnBackgroundMinimal;

  /// Try-on pose preset.
  ///
  /// In en, this message translates to:
  /// **'Standing front'**
  String get tryOnPoseFront;

  /// Try-on pose preset.
  ///
  /// In en, this message translates to:
  /// **'Standing side'**
  String get tryOnPoseSide;

  /// Try-on pose preset.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get tryOnPoseWalking;

  /// Greeting before noon.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get dashboardGreetingMorning;

  /// Greeting between noon and 5pm.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get dashboardGreetingAfternoon;

  /// Greeting after 5pm.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get dashboardGreetingEvening;

  /// Shown in place of the name when it is unknown.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get dashboardWelcome;

  /// Accessibility label on the avatar.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get dashboardOpenProfile;

  /// Section title for today's suggestions.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardRailToday;

  /// Section title for recent activity.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get dashboardRailRecently;

  /// Empty state for the activity feed.
  ///
  /// In en, this message translates to:
  /// **'New pieces and outfits show up here.'**
  String get dashboardActivityEmpty;

  /// Quick action title: open the add flow.
  ///
  /// In en, this message translates to:
  /// **'Add a piece'**
  String get quickAddPiece;

  /// Quick action subtitle.
  ///
  /// In en, this message translates to:
  /// **'Photograph and tag'**
  String get quickAddPieceBody;

  /// Quick action title: open the outfit builder.
  ///
  /// In en, this message translates to:
  /// **'Build an outfit'**
  String get quickBuildOutfit;

  /// Quick action subtitle.
  ///
  /// In en, this message translates to:
  /// **'Mix your pieces'**
  String get quickBuildOutfitBody;

  /// Quick action title: open recommendations.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get quickForYou;

  /// Quick action subtitle.
  ///
  /// In en, this message translates to:
  /// **'Picks for today'**
  String get quickForYouBody;

  /// Quick action title: open the outfit calendar.
  ///
  /// In en, this message translates to:
  /// **'Plan the week'**
  String get quickPlanWeek;

  /// Quick action subtitle.
  ///
  /// In en, this message translates to:
  /// **'Outfits by date'**
  String get quickPlanWeekBody;

  /// Referral banner title when the free allowance is nearly spent.
  ///
  /// In en, this message translates to:
  /// **'Running low? Invite a friend.'**
  String get referralBannerUrgent;

  /// Referral banner title.
  ///
  /// In en, this message translates to:
  /// **'Give a month, get a month.'**
  String get referralBannerTitle;

  /// Referral banner explanation.
  ///
  /// In en, this message translates to:
  /// **'You and your friend each get a month of Pro.'**
  String get referralBannerBody;

  /// Icon tooltip that hides the referral banner for a week.
  ///
  /// In en, this message translates to:
  /// **'Dismiss for a week'**
  String get referralBannerDismiss;

  /// Button that opens the share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get referralBannerShare;

  /// Button that copies the invite link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get referralBannerCopy;

  /// App bar title of the item edit screen.
  ///
  /// In en, this message translates to:
  /// **'Edit piece'**
  String get itemEditPieceTitle;

  /// Form field label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get itemEditDescriptionLabel;

  /// Error dialog title when the edit fails to save.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get itemEditNotSaved;

  /// Success dialog title.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get itemEditSavedTitle;

  /// Success dialog body.
  ///
  /// In en, this message translates to:
  /// **'Your changes are saved.'**
  String get itemEditSavedBody;

  /// Success title when the images need regenerating.
  ///
  /// In en, this message translates to:
  /// **'Saved — photos may be out of date'**
  String get itemEditSavedStalePhotos;

  /// Hint pointing to the detail screen for deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete this piece from the item page.'**
  String get itemEditRemovePieceHint;

  /// Empty state in the photo strip.
  ///
  /// In en, this message translates to:
  /// **'No photos yet. Add one from your gallery or camera.'**
  String get itemEditNoPhotos;

  /// Confirmation that keeps a pending photo.
  ///
  /// In en, this message translates to:
  /// **'Keep photo'**
  String get itemEditKeepPhoto;

  /// Confirmation after a photo is removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get itemEditRemoved;

  /// Icon tooltip that adds the typed use case.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get itemEditAddUseCaseAction;

  /// Empty state title on the stats screen.
  ///
  /// In en, this message translates to:
  /// **'No stats yet'**
  String get statsNoStatsTitle;

  /// Empty state body on the stats screen.
  ///
  /// In en, this message translates to:
  /// **'Add a few pieces and your closet mix shows up here.'**
  String get statsNoStatsBody;

  /// Section title: pieces per category.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get statsByCategory;

  /// Caption under the total closet value.
  ///
  /// In en, this message translates to:
  /// **'total value'**
  String get statsTotalValue;

  /// List title: the most worn pieces.
  ///
  /// In en, this message translates to:
  /// **'Worn the most'**
  String get statsMostWorn;

  /// List title: the least worn pieces.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a turn'**
  String get statsLeastWorn;

  /// Fallback name when an item has no name.
  ///
  /// In en, this message translates to:
  /// **'Unnamed piece'**
  String get statsUnnamedPiece;

  /// App bar title of the background scans screen.
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get jobsTitle;

  /// Empty state title.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get jobsEmptyTitle;

  /// Empty state body.
  ///
  /// In en, this message translates to:
  /// **'Snap a piece and send it to the background — it keeps working here.'**
  String get jobsEmptyBody;

  /// Error title when cancelling a scan fails.
  ///
  /// In en, this message translates to:
  /// **'Not cancelled'**
  String get jobsNotCancelled;

  /// Action on a running scan.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get jobsResume;

  /// Action on a finished scan.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get jobsReview;

  /// Action that cancels a running scan.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get jobsStop;

  /// Action that hides a finished scan from the list.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get jobsDismiss;

  /// Title of the sheet a user opens to report objectionable user-generated content. Apple Guideline 1.2 requires this control, so it must be understandable in every language the app ships.
  ///
  /// In en, this message translates to:
  /// **'Report content'**
  String get reportTitle;

  /// Explains what the report form is for. {contentType} is a localized noun such as 'AI try-on image'.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s wrong with this {contentType}. Our team reviews every report.'**
  String reportIntro(String contentType);

  /// Radio option: content is objectionable but not covered by a more specific reason.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate or offensive'**
  String get reportReasonInappropriate;

  /// Radio option: sexual or nude imagery.
  ///
  /// In en, this message translates to:
  /// **'Nudity or sexual content'**
  String get reportReasonNudity;

  /// Radio option: the content targets or abuses someone.
  ///
  /// In en, this message translates to:
  /// **'Harassment or abuse'**
  String get reportReasonHarassment;

  /// Radio option: the content presents someone as another person.
  ///
  /// In en, this message translates to:
  /// **'Impersonation'**
  String get reportReasonImpersonation;

  /// Radio option: none of the listed reasons fit.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// Text field label for the user's own description of the problem.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get reportDetailsLabel;

  /// Button that files the report.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// Title of the confirmation after a report is filed.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSubmittedTitle;

  /// Confirmation body after a report is filed.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Our team will review this content.'**
  String get reportSubmittedBody;

  /// Title shown when filing the report failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send report'**
  String get reportFailedTitle;

  /// Body shown when filing the report failed.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get reportFailedBody;

  /// Name of a generated try-on render, used inside reportIntro.
  ///
  /// In en, this message translates to:
  /// **'AI try-on image'**
  String get reportContentTryOnImage;

  /// Name of a publicly shared outfit page, used inside reportIntro.
  ///
  /// In en, this message translates to:
  /// **'shared outfit'**
  String get reportContentSharedOutfit;

  /// Name of a generated photoshoot image, used inside reportIntro.
  ///
  /// In en, this message translates to:
  /// **'AI photoshoot image'**
  String get reportContentPhotoshootImage;

  /// App bar title of a public outfit page opened from a share link.
  ///
  /// In en, this message translates to:
  /// **'Shared outfit'**
  String get sharedOutfitTitle;

  /// Tooltip on the eye-slash action that hides a shared outfit on this device.
  ///
  /// In en, this message translates to:
  /// **'Hide this outfit'**
  String get sharedOutfitHideTooltip;

  /// Tooltip on the flag action that opens the report sheet for a shared outfit.
  ///
  /// In en, this message translates to:
  /// **'Report this outfit'**
  String get sharedOutfitReportTooltip;

  /// Confirmation dialog title before hiding a shared outfit.
  ///
  /// In en, this message translates to:
  /// **'Hide this outfit?'**
  String get sharedOutfitHideTitle;

  /// Explains that hiding is local only, and points the user to reporting for a global removal.
  ///
  /// In en, this message translates to:
  /// **'It stays hidden on this device. You can also report it so our team can review and remove it.'**
  String get sharedOutfitHideBody;

  /// Confirm button that hides a shared outfit on this device.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get sharedOutfitHideAction;

  /// Confirmation shown after a shared outfit is hidden.
  ///
  /// In en, this message translates to:
  /// **'This outfit will not show on this device again.'**
  String get sharedOutfitHiddenInfo;

  /// Title of the confirmation shown after a shared outfit is hidden.
  ///
  /// In en, this message translates to:
  /// **'Outfit hidden'**
  String get sharedOutfitHiddenToast;

  /// Empty state title when a share link points at removed content.
  ///
  /// In en, this message translates to:
  /// **'This outfit isn\'t here anymore'**
  String get sharedOutfitMissingTitle;

  /// Empty state body when a share link points at removed content.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed, or the link is wrong.'**
  String get sharedOutfitMissingBody;

  /// Empty state title shown in place of a shared outfit the user hid.
  ///
  /// In en, this message translates to:
  /// **'You hid this outfit'**
  String get sharedOutfitHiddenStateTitle;

  /// Tells the user how to escalate objectionable content after hiding it. {email} is the support address.
  ///
  /// In en, this message translates to:
  /// **'If it was objectionable, report it from Privacy and terms or email {email}.'**
  String sharedOutfitHiddenStateBody(String email);

  /// Heading of the sign-up prompt shown at the bottom of a public outfit page.
  ///
  /// In en, this message translates to:
  /// **'Like this look?'**
  String get sharedOutfitCtaTitle;

  /// Subtext of the sign-up prompt on a public outfit page.
  ///
  /// In en, this message translates to:
  /// **'Build outfits like it from your own closet.'**
  String get sharedOutfitCtaBody;

  /// Button on a public outfit page that sends the visitor to sign up.
  ///
  /// In en, this message translates to:
  /// **'Get FitCheck AI'**
  String get sharedOutfitCtaButton;

  /// Default title of an error snackbar.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Shown when an error has no recognizable type.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnknown;

  /// NetworkException.noConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNoConnection;

  /// NetworkException.timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get errorTimeout;

  /// ServerException.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again.'**
  String get errorServerError;

  /// BadGateway exception.
  ///
  /// In en, this message translates to:
  /// **'Our server is briefly unavailable. Please try again.'**
  String get errorBadGateway;

  /// ServiceUnavailable exception.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable. Please try again shortly.'**
  String get errorServiceUnavailable;

  /// InternalError exception.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorInternalError;

  /// Unauthorized exception.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorUnauthorized;

  /// Forbidden exception.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to that.'**
  String get errorForbidden;

  /// SessionExpired exception.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorSessionExpired;

  /// InvalidCredentials exception.
  ///
  /// In en, this message translates to:
  /// **'That email or password is not correct.'**
  String get errorInvalidCredentials;

  /// TokenRefreshFailed exception.
  ///
  /// In en, this message translates to:
  /// **'We could not refresh your session. Please sign in again.'**
  String get errorTokenRefreshFailed;

  /// RequestCancelled exception.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get errorRequestCancelled;

  /// InvalidFormat exception.
  ///
  /// In en, this message translates to:
  /// **'That file format is not supported.'**
  String get errorInvalidFormat;

  /// FileTooLarge exception.
  ///
  /// In en, this message translates to:
  /// **'That file is too large.'**
  String get errorFileTooLarge;

  /// UploadFailed exception.
  ///
  /// In en, this message translates to:
  /// **'The upload failed. Please try again.'**
  String get errorUploadFailed;

  /// CacheCorrupted exception.
  ///
  /// In en, this message translates to:
  /// **'Saved data was damaged and has been reset.'**
  String get errorCacheCorrupted;

  /// CacheNotFound exception.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved yet.'**
  String get errorCacheNotFound;

  /// UserNotFound exception.
  ///
  /// In en, this message translates to:
  /// **'We could not find that account.'**
  String get errorUserNotFound;

  /// ItemNotFound exception.
  ///
  /// In en, this message translates to:
  /// **'That item no longer exists.'**
  String get errorItemNotFound;

  /// OutfitNotFound exception.
  ///
  /// In en, this message translates to:
  /// **'That outfit no longer exists.'**
  String get errorOutfitNotFound;

  /// App bar title of the gamification screen: streaks, achievements and leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTitle;

  /// Empty state title on the achievements section.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get rewardsNoAchievementsTitle;

  /// Empty state body telling the user how to earn an achievement.
  ///
  /// In en, this message translates to:
  /// **'Add pieces and plan outfits to earn your first.'**
  String get rewardsNoAchievementsBody;

  /// Empty state title on the leaderboard.
  ///
  /// In en, this message translates to:
  /// **'No one on the board yet'**
  String get rewardsEmptyLeaderboardTitle;

  /// Empty state body telling the user how to appear on the leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Plan outfits to earn points and show up here.'**
  String get rewardsEmptyLeaderboardBody;

  /// Link in the AI consent sheet that opens the privacy policy in a browser.
  ///
  /// In en, this message translates to:
  /// **'View Privacy Policy'**
  String get legalViewPrivacyPolicy;

  /// Primary button in the AI consent sheet. Grants consent to send photos to the AI provider.
  ///
  /// In en, this message translates to:
  /// **'I Agree & Continue'**
  String get aiConsentAgree;

  /// Decline button in the AI consent sheet.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get aiConsentNotNow;

  /// Tooltip on the close button of the full-screen image viewer.
  ///
  /// In en, this message translates to:
  /// **'Close image viewer'**
  String get imageViewerCloseTooltip;

  /// Notification title when a hot-update download finished and is ready to apply.
  ///
  /// In en, this message translates to:
  /// **'Update ready'**
  String get updateReadyTitle;

  /// Body of the notification shown after a hot update has downloaded and needs a restart.
  ///
  /// In en, this message translates to:
  /// **'Restart FitCheck AI to apply the latest improvements.'**
  String get updateReadyBody;

  /// iOS permission prompt (NSCameraUsageDescription). Must match flutter/ios/Runner/Info.plist exactly; scripts/i18n/gen_infoplist_strings.py refuses to write a mismatch.
  ///
  /// In en, this message translates to:
  /// **'FitCheck AI needs camera access to take photos of your outfits and wardrobe items.'**
  String get permissionCameraUsage;

  /// iOS permission prompt (NSPhotoLibraryUsageDescription). Must match Info.plist exactly.
  ///
  /// In en, this message translates to:
  /// **'FitCheck AI needs photo library access to select images of your outfits and wardrobe items.'**
  String get permissionPhotoLibraryUsage;

  /// iOS permission prompt (NSPhotoLibraryAddUsageDescription). Must match Info.plist exactly.
  ///
  /// In en, this message translates to:
  /// **'FitCheck AI needs to save your AI-generated outfit photos to your photo library.'**
  String get permissionPhotoLibraryAddUsage;

  /// Snackbar title after adding photos when some files were rejected (too large or unsupported). The body text comes from the validation error.
  ///
  /// In en, this message translates to:
  /// **'Some photos skipped'**
  String get wardrobeSomePhotosSkipped;

  /// Snackbar title when picking photos from the gallery failed, for example after a denied permission.
  ///
  /// In en, this message translates to:
  /// **'Photos not added'**
  String get wardrobePhotosNotAdded;

  /// Snackbar title when taking a single photo with the camera failed.
  ///
  /// In en, this message translates to:
  /// **'Photo not added'**
  String get wardrobePhotoNotAdded;

  /// Snackbar title when the AI scan of the selected photos could not be started at all.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get wardrobeNotStartedTitle;

  /// Snackbar title shown when the user taps the camera button but the batch already holds the maximum number of photos.
  ///
  /// In en, this message translates to:
  /// **'No room'**
  String get wardrobeNoRoomTitle;

  /// Screen-reader label of the tile with the plus icon in the photo grid; it opens the add-photo sheet.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get wardrobeAddPhotosSemantic;

  /// Short visible label under the plus icon in that same tile. Keep it very short; it must fit a 120pt tile.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get batchAddTileLabel;

  /// Label of the segmented switch that opens social-profile import, and the label of the field where the link is pasted.
  ///
  /// In en, this message translates to:
  /// **'Profile link'**
  String get batchProfileLinkLabel;

  /// App bar title of the batch screen while the social-profile tab is selected.
  ///
  /// In en, this message translates to:
  /// **'Import from a profile'**
  String get wardrobeImportFromProfileTitle;

  /// App bar title of the screen where several photos are selected at once; also used on the progress screen for the same job.
  ///
  /// In en, this message translates to:
  /// **'Add several photos'**
  String get wardrobeAddSeveralPhotosTitle;

  /// App bar button that empties the selected photos before the scan starts.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get wardrobeClearAction;

  /// Tooltip of the refresh icon that re-checks the state of a profile import.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get wardrobeRefreshTooltip;

  /// Empty state title on the batch screen before any photo is added.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get batchNoPhotosYetTitle;

  /// Primary button of that empty state; opens the OS photo picker.
  ///
  /// In en, this message translates to:
  /// **'Choose photos'**
  String get batchChoosePhotosAction;

  /// Reassurance line directly above the button that starts the batch scan.
  ///
  /// In en, this message translates to:
  /// **'We find each piece and make a studio photo of it.'**
  String get batchWeFindEachPieceBody;

  /// Screen-reader label of the progress bar shown while the selected photos upload.
  ///
  /// In en, this message translates to:
  /// **'Preparing photos'**
  String get batchPreparingPhotosSemantic;

  /// Screen-reader label of the progress bar showing how many imported photos have been scanned.
  ///
  /// In en, this message translates to:
  /// **'Photos processed'**
  String get batchPhotosProcessedSemantic;

  /// Heading of the card where an Instagram or Facebook profile link is pasted.
  ///
  /// In en, this message translates to:
  /// **'Paste a profile link'**
  String get batchPasteProfileLinkTitle;

  /// Explanation under the paste-a-profile-link heading. Says whose photos are scanned and who decides what is kept.
  ///
  /// In en, this message translates to:
  /// **'A public Instagram or Facebook profile. We scan its photos, and you choose what goes in your closet.'**
  String get batchPasteProfileLinkBody;

  /// Tooltip of the X icon inside the profile-link field.
  ///
  /// In en, this message translates to:
  /// **'Clear link'**
  String get batchClearLinkTooltip;

  /// Import button label while the import request is in flight. States, not an action.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get batchStartingButton;

  /// Primary button that starts scanning the pasted profile.
  ///
  /// In en, this message translates to:
  /// **'Start import'**
  String get batchStartImportAction;

  /// Heading of the first explanation card on the profile import screen.
  ///
  /// In en, this message translates to:
  /// **'You review every photo'**
  String get batchReviewEveryPhotoTitle;

  /// Body of the first explanation card: the user approves every photo before it is saved.
  ///
  /// In en, this message translates to:
  /// **'Nothing is added until you approve it.'**
  String get batchReviewEveryPhotoBody;

  /// Heading of the second explanation card on the profile import screen, about private accounts.
  ///
  /// In en, this message translates to:
  /// **'Private profiles'**
  String get batchPrivateProfilesTitle;

  /// Body of the second explanation card: explains why a sign-in may be needed.
  ///
  /// In en, this message translates to:
  /// **'Connect your account. Instagram also takes a username and password.'**
  String get batchPrivateProfilesBody;

  /// Back button at the top of the sign-in step; returns to the profile-link form.
  ///
  /// In en, this message translates to:
  /// **'Use another link'**
  String get batchUseAnotherLinkAction;

  /// Heading when the pasted profile is private and the platform asks for a sign-in.
  ///
  /// In en, this message translates to:
  /// **'Sign-in needed'**
  String get batchSignInNeededTitle;

  /// Heading of the two-step verification step and title of the dialog where the 6-digit code is typed.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get batchEnterYourCodeTitle;

  /// Link that opens a manual Instagram login dialog instead of the in-browser sign-in.
  ///
  /// In en, this message translates to:
  /// **'Use username and password'**
  String get batchUseUsernamePasswordAction;

  /// Link the user taps after finishing the sign-in in their browser; it re-checks the connection.
  ///
  /// In en, this message translates to:
  /// **'I already connected in the browser'**
  String get batchAlreadyConnectedAction;

  /// Button on the two-step verification step that opens the code entry dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get batchEnterCodeAction;

  /// Link that abandons this two-step verification attempt and offers a different sign-in method.
  ///
  /// In en, this message translates to:
  /// **'Try another way'**
  String get batchTryAnotherWayAction;

  /// Small status chip meaning the connection to the social platform is working. Must stay one short word.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get batchLiveStatus;

  /// Small status chip meaning the connection dropped and is retrying. Must stay one short word.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get batchReconnectingStatus;

  /// Title of the manual sign-in dialog. The platform name is part of the copy, not a placeholder.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Instagram'**
  String get batchSignInToInstagramTitle;

  /// Field label in the manual Instagram sign-in dialog.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get batchUsernameLabel;

  /// Optional field label in the manual sign-in dialog for the 6-digit code.
  ///
  /// In en, this message translates to:
  /// **'Code, if you use two-step sign-in'**
  String get batchCodeIfTwoStepLabel;

  /// Explanation inside the two-step verification dialog.
  ///
  /// In en, this message translates to:
  /// **'Use the 6-digit code from your authenticator app. Codes change quickly.'**
  String get batchAuthenticatorCodeBody;

  /// Confirm button of the two-step verification dialog; enabled once six digits are entered.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get batchVerifyAction;

  /// Heading while the app lists the photos available on the pasted profile.
  ///
  /// In en, this message translates to:
  /// **'Finding photos'**
  String get batchFindingPhotosTitle;

  /// Heading when the platform rate-limited the import; it resumes on its own, so this is not an error.
  ///
  /// In en, this message translates to:
  /// **'Import paused'**
  String get batchImportPausedTitle;

  /// Heading while each imported photo is scanned for pieces.
  ///
  /// In en, this message translates to:
  /// **'Processing photos'**
  String get batchProcessingPhotosTitle;

  /// Status line while the import waits for the next photo to arrive.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the next photo'**
  String get batchWaitingNextPhoto;

  /// Button at the bottom of the import screens that stops the running import.
  ///
  /// In en, this message translates to:
  /// **'Cancel import'**
  String get batchCancelImportAction;

  /// Shown under a photo during review when the scan detected no clothing in it.
  ///
  /// In en, this message translates to:
  /// **'No pieces found in this photo.'**
  String get batchNoPiecesInPhotoBody;

  /// Label of the field where piece colours are typed as a comma-separated list.
  ///
  /// In en, this message translates to:
  /// **'Colours, separated by commas'**
  String get batchEditPieceColoursLabel;

  /// Primary button that approves the pieces found in the reviewed photo.
  ///
  /// In en, this message translates to:
  /// **'Add to closet'**
  String get batchAddToClosetAction;

  /// Secondary button that rejects the reviewed photo and moves to the next one.
  ///
  /// In en, this message translates to:
  /// **'Skip this photo'**
  String get batchSkipPhotoAction;

  /// Title of the end screen when the profile import finished.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get batchImportCompleteTitle;

  /// Title of the end screen when the profile import failed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get batchImportFailedTitle;

  /// Title of the end screen when the user cancelled the profile import.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled'**
  String get batchImportCancelledTitle;

  /// Fallback message on the failed end screen when the platform returned no error text.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while importing.'**
  String get batchImportErrorBody;

  /// Message on the cancelled end screen.
  ///
  /// In en, this message translates to:
  /// **'Nothing more is imported from this profile.'**
  String get batchNothingMoreImportedBody;

  /// Button on the completed end screen that opens the closet.
  ///
  /// In en, this message translates to:
  /// **'View closet'**
  String get batchViewClosetAction;

  /// Button that resets the flow, on the cancelled import screen and on the single-photo results screen.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get batchStartOverAction;

  /// App bar title of the add-item screen on its first step, where the user picks camera, gallery or another route.
  ///
  /// In en, this message translates to:
  /// **'Add a piece'**
  String get wardrobeAddPieceTitle;

  /// App bar title of the add-item screen while the manual details form is open.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get wardrobeAddDetailsTitle;

  /// App bar title of the add-item screen while the photo is being analysed.
  ///
  /// In en, this message translates to:
  /// **'Scanning'**
  String get wardrobeScanningTitle;

  /// App bar title of the batch review screen, and of the add-item screen while scan results are shown.
  ///
  /// In en, this message translates to:
  /// **'Review pieces'**
  String get batchReviewPiecesTitle;

  /// Short button label that adds more photos from the photo library in the edit-piece photo strip.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get wardrobeGalleryAction;

  /// Short button label that adds a photo from the camera in the edit-piece photo strip.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get wardrobeCameraAction;

  /// Badge on the thumbnail of a photo that was just added and is not saved yet.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get wardrobeNewBadge;

  /// Tooltip of the close button on a selected photo thumbnail, before the batch scan starts.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get wardrobeRemovePhotoTooltip;

  /// Tooltip of the close icon on the scan progress screen; keeps the scan running and returns to the photos.
  ///
  /// In en, this message translates to:
  /// **'Run in background'**
  String get batchRunInBackgroundTooltip;

  /// Step counter above the progress heading: finding pieces in each photo.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get batchStepOneOfTwo;

  /// Step counter above the progress heading: generating studio photos.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get batchStepTwoOfTwo;

  /// Progress heading while the selected photos upload.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos'**
  String get batchUploadingPhotosTitle;

  /// Progress heading while the AI looks for clothing in each photo.
  ///
  /// In en, this message translates to:
  /// **'Finding pieces'**
  String get batchFindingPiecesTitle;

  /// Progress heading while clean studio images are generated for each piece.
  ///
  /// In en, this message translates to:
  /// **'Making studio photos'**
  String get batchMakingStudioPhotosTitle;

  /// Step label on the progress screen when the job failed or was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get batchStoppedLabel;

  /// Progress heading when the scan failed part-way.
  ///
  /// In en, this message translates to:
  /// **'Finding pieces stopped'**
  String get batchFindingPiecesStoppedTitle;

  /// Progress heading when the user cancelled the batch scan.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get batchCancelledLabel;

  /// Progress heading shown momentarily when the scan completes, just before the review screen opens.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get batchAllDoneTitle;

  /// Progress detail shown for the instant before the review screen opens.
  ///
  /// In en, this message translates to:
  /// **'Opening your pieces'**
  String get batchOpeningPiecesBody;

  /// Progress detail on the cancelled screen.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved.'**
  String get batchNothingSavedBody;

  /// Error state body when the scan failed before any piece was found.
  ///
  /// In en, this message translates to:
  /// **'Finding pieces failed.'**
  String get batchFindingPiecesFailedBody;

  /// Error banner above the photo list when the scan failed after some pieces were already found.
  ///
  /// In en, this message translates to:
  /// **'Finding pieces stopped early.'**
  String get batchFindingPiecesStoppedEarlyBody;

  /// Title of the confirmation dialog before cancelling a running batch scan.
  ///
  /// In en, this message translates to:
  /// **'Stop finding pieces?'**
  String get batchStopFindingPiecesTitle;

  /// Body of the confirmation dialog: explains what cancelling the scan does with pieces already found.
  ///
  /// In en, this message translates to:
  /// **'The scan stops and nothing is saved. Pieces already found stay in your activity until you dismiss them.'**
  String get batchStopFindingPiecesBody;

  /// Dialog button that dismisses the stop-scan confirmation without cancelling.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get batchKeepGoingAction;

  /// Retry button on the scan error state and on the scan failure screens.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get batchTryAgainAction;

  /// Button on the cancelled scan screen that returns to photo selection.
  ///
  /// In en, this message translates to:
  /// **'Back to photos'**
  String get batchBackToPhotosAction;

  /// App bar button that excludes every piece found in the batch.
  ///
  /// In en, this message translates to:
  /// **'Skip all'**
  String get batchSkipAllAction;

  /// App bar button that re-includes every piece found in the batch.
  ///
  /// In en, this message translates to:
  /// **'Include all'**
  String get batchIncludeAllAction;

  /// Empty state and failure title when the scan found no clothing.
  ///
  /// In en, this message translates to:
  /// **'No pieces found'**
  String get batchNoPiecesFoundTitle;

  /// Empty state body on the batch review screen when nothing was detected.
  ///
  /// In en, this message translates to:
  /// **'We found no clothes in these photos.'**
  String get batchNoPiecesFoundBody;

  /// Button on the empty batch review state that goes back to photo selection.
  ///
  /// In en, this message translates to:
  /// **'Choose other photos'**
  String get batchChooseOtherPhotosAction;

  /// Helper line under the occasion picker on the review screens.
  ///
  /// In en, this message translates to:
  /// **'Added to every piece you save.'**
  String get batchUseCaseHelper;

  /// Confirmation dialog title before leaving the batch review and losing the pieces.
  ///
  /// In en, this message translates to:
  /// **'Discard these pieces?'**
  String get batchDiscardPiecesTitle;

  /// Body of the discard confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Nothing from this batch is saved.'**
  String get batchDiscardPiecesBody;

  /// Dialog button that keeps the pieces and stays on the review screen.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get batchKeepAction;

  /// Dialog button that throws the batch away. Rendered in the destructive colour.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get batchDiscardAction;

  /// Confirmation dialog title before removing one piece from the review grid.
  ///
  /// In en, this message translates to:
  /// **'Remove this piece?'**
  String get batchRemovePieceTitle;

  /// Body of the remove-piece confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'It is not saved to your closet.'**
  String get batchRemovePieceBody;

  /// Confirm button of the remove-piece dialog. Rendered in the destructive colour.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get batchRemoveAction;

  /// Save button label while no piece is selected on the review screen, so the button is disabled.
  ///
  /// In en, this message translates to:
  /// **'Choose pieces to save'**
  String get batchChoosePiecesToSave;

  /// Bottom bar button that discards every reviewed piece.
  ///
  /// In en, this message translates to:
  /// **'Discard all'**
  String get batchDiscardAllAction;

  /// Snackbar message when saving the reviewed pieces failed and nothing was stored.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved. Try again.'**
  String get batchNothingSavedRetryBody;

  /// Snackbar title for a failed save.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get batchNotSavedTitle;

  /// Save button label while the selected pieces are being saved. States, not an action.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get batchSavingLabel;

  /// Button on the scan progress view that keeps the scan running while the user navigates away.
  ///
  /// In en, this message translates to:
  /// **'Send to background'**
  String get batchSendToBackgroundAction;

  /// Snackbar message shown when the user leaves a scan running in the background.
  ///
  /// In en, this message translates to:
  /// **'Still working. We will let you know when your pieces are ready.'**
  String get batchStillWorkingMessage;

  /// Snackbar title for the same message.
  ///
  /// In en, this message translates to:
  /// **'Running in background'**
  String get batchRunningInBackgroundTitle;

  /// Error banner above the piece grid when studio-photo generation failed but pieces exist.
  ///
  /// In en, this message translates to:
  /// **'Studio photos stopped early. You can still save these pieces.'**
  String get batchStudioPhotosStoppedBody;

  /// Hint under the results heading explaining how to exclude a piece.
  ///
  /// In en, this message translates to:
  /// **'Tap a piece to skip it.'**
  String get batchTapPieceToSkip;

  /// Banner above the piece grid while studio photos are still generating. The em dash is intentional.
  ///
  /// In en, this message translates to:
  /// **'Studio photos still on their way. You can leave — we will let you know.'**
  String get batchStudioPhotosOnWayBody;

  /// Button in that banner that navigates away while generation continues.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get batchLeaveAction;

  /// Title of the per-person grouping block, shown when a photo contains more than one person.
  ///
  /// In en, this message translates to:
  /// **'People in the photos'**
  String get batchPeopleInPhotosTitle;

  /// Per-person button that includes every piece belonging to that person.
  ///
  /// In en, this message translates to:
  /// **'Include'**
  String get batchIncludeAction;

  /// Per-person button that excludes every piece belonging to that person.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get batchSkipAction;

  /// Caption on a piece card whose studio photo failed, so the original photo is shown instead.
  ///
  /// In en, this message translates to:
  /// **'Your photo is used'**
  String get batchYourPhotoIsUsedLabel;

  /// Caption on a piece card while its studio photo is still generating.
  ///
  /// In en, this message translates to:
  /// **'Making studio photo'**
  String get batchMakingStudioPhotoLabel;

  /// Caption on a review card whose studio photo could not be generated.
  ///
  /// In en, this message translates to:
  /// **'No studio photo. Your photo is used.'**
  String get batchNoStudioPhotoBody;

  /// Secondary action on the scan failure screens that opens the manual entry form.
  ///
  /// In en, this message translates to:
  /// **'Enter details yourself'**
  String get batchEnterDetailsYourselfAction;

  /// Secondary action that returns to the photo picker after a failed or empty scan.
  ///
  /// In en, this message translates to:
  /// **'Choose another photo'**
  String get batchChooseAnotherPhotoAction;

  /// Failure screen title when the scan could not reach the server.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get batchConnectionLostTitle;

  /// Failure screen body for a network failure.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then try again.'**
  String get batchConnectionLostBody;

  /// Failure screen title when the free daily scan allowance is used up.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached'**
  String get batchDailyLimitTitle;

  /// Daily limit body shown only when the paywall is enabled.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro for more scans, or enter the details yourself.'**
  String get batchDailyLimitBodyPaywall;

  /// Daily limit body shown when the paywall is disabled.
  ///
  /// In en, this message translates to:
  /// **'Your scans reset tomorrow. You can enter the details yourself now.'**
  String get batchDailyLimitBodyFree;

  /// Button on the daily limit screen that opens the subscription plans; paywall builds only.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get batchSeePlansAction;

  /// Failure screen title when the AI service is overloaded.
  ///
  /// In en, this message translates to:
  /// **'Our AI is busy'**
  String get batchAiBusyTitle;

  /// Failure screen body when the AI service is overloaded.
  ///
  /// In en, this message translates to:
  /// **'This is on our side. Try again in a few minutes.'**
  String get batchAiBusyBody;

  /// Failure screen body when no clothing was detected in the photo.
  ///
  /// In en, this message translates to:
  /// **'Try a clearer photo, or enter the details yourself.'**
  String get batchNoPiecesBody;

  /// Failure screen title when AI scanning is switched off or unavailable.
  ///
  /// In en, this message translates to:
  /// **'Scanning is unavailable'**
  String get batchScanningUnavailableTitle;

  /// Failure screen body when scanning is unavailable.
  ///
  /// In en, this message translates to:
  /// **'Enter the details yourself for now.'**
  String get batchScanningUnavailableBody;

  /// Failure screen title for any other scan error.
  ///
  /// In en, this message translates to:
  /// **'The scan did not finish'**
  String get batchScanDidNotFinishTitle;

  /// Generic fallback body on the unknown-error failure screen. A sentence, unlike the button label.
  ///
  /// In en, this message translates to:
  /// **'Try again.'**
  String get batchTryAgainBody;

  /// App bar title of the subscription screen (plan, usage, upgrade, referral).
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get billingTitle;

  /// Paywall headline shown to an existing Plus subscriber who can still move up to Pro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade your plan'**
  String get billingUpgradeHeading;

  /// One-line subtitle under billingUpgradeHeading for a Plus subscriber.
  ///
  /// In en, this message translates to:
  /// **'Same features, higher limits.'**
  String get billingUpgradeOnPlusBody;

  /// Subtitle under the paywall headline for a user not yet subscribed.
  ///
  /// In en, this message translates to:
  /// **'Plus and Pro have the same features. Pick the limits you need.'**
  String get billingUpgradeBody;

  /// Message replacing the paywall on web when online checkout is not configured; points at promo codes and referrals instead.
  ///
  /// In en, this message translates to:
  /// **'Online upgrades aren\'t available yet. A promo or referral code still unlocks Plus or Pro. Invite friends below to earn free months.'**
  String get billingWebUnavailableBody;

  /// Inline error banner above the plan cards when the /plans request failed and cached prices are shown.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the latest plans. Prices may be out of date.'**
  String get billingPlansStale;

  /// Left segment of the monthly/yearly billing period switch on the paywall.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get billingMonthly;

  /// Right segment of the monthly/yearly billing period switch on the paywall.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get billingYearly;

  /// Small caption above the plan name on the current-plan card of the subscription screen.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get billingCurrentPlan;

  /// Small filled label next to the plan name when the subscription is active and not cancelled.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get billingActive;

  /// Heading of the usage card that shows remaining monthly allowances.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get billingThisMonth;

  /// Usage row label for the monthly AI item-extraction allowance.
  ///
  /// In en, this message translates to:
  /// **'Item extractions'**
  String get billingItemExtractions;

  /// Usage row label for the monthly AI outfit-visualization allowance.
  ///
  /// In en, this message translates to:
  /// **'Outfit visualizations'**
  String get billingOutfitVisualizations;

  /// Warning under the usage bars, shown when the paywall is enabled and an allowance is above 80 percent.
  ///
  /// In en, this message translates to:
  /// **'You\'re close to this month\'s limit. Upgrade for more.'**
  String get billingNearLimitUpgrade;

  /// Warning under the usage bars when upgrades are disabled, so the only path is waiting for the monthly reset.
  ///
  /// In en, this message translates to:
  /// **'You\'re close to this month\'s limit. It resets at the start of next month.'**
  String get billingNearLimitResets;

  /// Banner above the plan cards when the App Store or Play Store serves no products.
  ///
  /// In en, this message translates to:
  /// **'Upgrades aren\'t available in the store yet. Check back soon.'**
  String get billingStoreUnavailable;

  /// Heading of the card explaining that a store-billed plan is changed in the store.
  ///
  /// In en, this message translates to:
  /// **'Manage your plan'**
  String get billingManageHeading;

  /// Heading of the cancel card and the destructive button inside it, for a plan billed directly (not through a store).
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get billingCancelPlan;

  /// Body of the cancel card and the confirmation dialog: access continues until the paid period ends.
  ///
  /// In en, this message translates to:
  /// **'You keep access until the end of this billing period.'**
  String get billingCancelKeepsAccess;

  /// Title of the dialog that asks the user to confirm cancelling their plan.
  ///
  /// In en, this message translates to:
  /// **'Cancel your subscription?'**
  String get billingCancelConfirmTitle;

  /// Dismiss button in the cancel-confirmation dialog; the safe choice.
  ///
  /// In en, this message translates to:
  /// **'Keep plan'**
  String get billingKeepPlan;

  /// Destructive confirm button in the cancel-confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get billingCancelPlanAction;

  /// Note under the price on a plan card when the monthly period is selected.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billingBilledMonthly;

  /// Note under the price on a plan card when the yearly period is selected and no saving can be computed.
  ///
  /// In en, this message translates to:
  /// **'Billed yearly'**
  String get billingBilledYearly;

  /// Feature line on the paid plan cards.
  ///
  /// In en, this message translates to:
  /// **'Virtual try-on'**
  String get billingVirtualTryOn;

  /// Feature line on the paid plan cards.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get billingPrioritySupport;

  /// LEGAL: opening clause of the App Review 3.1.2 subscription disclosure, shown when a Plus subscriber is only offered Pro.
  ///
  /// In en, this message translates to:
  /// **'Pro is an auto-renewing subscription'**
  String get billingDisclosureProRenewing;

  /// LEGAL: opening clause of the App Review 3.1.2 subscription disclosure when both Plus and Pro are purchasable.
  ///
  /// In en, this message translates to:
  /// **'Plus and Pro are auto-renewing subscriptions'**
  String get billingDisclosureBothRenewing;

  /// LEGAL: required iOS disclosure sentence stating when the user is charged. Do not shorten or reword.
  ///
  /// In en, this message translates to:
  /// **'Payment is charged to your Apple ID at confirmation of purchase.'**
  String get billingDisclosureAppleBilling;

  /// LEGAL: required Android disclosure sentence stating when the user is charged. Do not shorten or reword.
  ///
  /// In en, this message translates to:
  /// **'Payment is charged to your Google Play account at confirmation of purchase.'**
  String get billingDisclosureGoogleBilling;

  /// LEGAL: the auto-renewal and 24-hour cancellation sentence in the subscription disclosure. App Review rejects shortened versions.
  ///
  /// In en, this message translates to:
  /// **'Your subscription renews automatically for the same period at the same price unless you turn off auto-renew at least 24 hours before the current period ends.'**
  String get billingDisclosureRenewalTerms;

  /// LEGAL: iOS path for managing or cancelling, with the exact menu names. Keep the › separators and the Apple menu names untranslated where they are UI labels.
  ///
  /// In en, this message translates to:
  /// **'Manage or cancel any time in Settings › your Apple ID › Subscriptions.'**
  String get billingDisclosureAppleManage;

  /// LEGAL: Android path for managing or cancelling, with the exact Play menu names. Keep the › separators.
  ///
  /// In en, this message translates to:
  /// **'Manage or cancel any time in Google Play › Payments and subscriptions.'**
  String get billingDisclosureGoogleManage;

  /// App bar title of the referral screen.
  ///
  /// In en, this message translates to:
  /// **'Refer a friend'**
  String get billingReferFriend;

  /// Heading of the three-step explanation of the referral programme.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get billingHowItWorks;

  /// Referral step 1, title.
  ///
  /// In en, this message translates to:
  /// **'Share your link'**
  String get billingHowShareTitle;

  /// Referral step 1, description under billingHowShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Send it to a friend.'**
  String get billingHowShareBody;

  /// Referral step 2, title.
  ///
  /// In en, this message translates to:
  /// **'They sign up'**
  String get billingHowSignUpTitle;

  /// Referral step 2, description under billingHowSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Your friend joins from the link.'**
  String get billingHowSignUpBody;

  /// Referral step 3, title.
  ///
  /// In en, this message translates to:
  /// **'You both get Pro'**
  String get billingHowBothTitle;

  /// Referral step 3, description under billingHowBothTitle.
  ///
  /// In en, this message translates to:
  /// **'Each of you gets a month of Pro free.'**
  String get billingHowBothBody;

  /// Heading of the referral totals card.
  ///
  /// In en, this message translates to:
  /// **'Your referrals'**
  String get billingYourReferrals;

  /// Statistic label under the number of friends the user has invited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get billingInvited;

  /// Statistic label under the number of invited friends who signed up.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get billingJoined;

  /// Statistic label under the number of free Pro months earned through referrals.
  ///
  /// In en, this message translates to:
  /// **'Months earned'**
  String get billingMonthsEarned;

  /// Heading of the referral share card.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend'**
  String get billingInviteFriend;

  /// One-line explanation under billingInviteFriend on the referral share card.
  ///
  /// In en, this message translates to:
  /// **'You and your friend each get a month of Pro.'**
  String get billingInviteBody;

  /// Caption above the user's referral code inside the share card.
  ///
  /// In en, this message translates to:
  /// **'Your code'**
  String get billingYourCode;

  /// Tooltip/accessibility label of the copy icon next to the referral code.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get billingCopyLink;

  /// Button on the referral share card that opens the system share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get billingShareInvite;

  /// Full-screen message shown when gift vouchers are switched off in this build.
  ///
  /// In en, this message translates to:
  /// **'Gift invitations are not available in this build.'**
  String get giftUnavailable;

  /// App bar title of the gift vouchers screen. 'FitCheck Pro' is the product name and stays untranslated.
  ///
  /// In en, this message translates to:
  /// **'Gift FitCheck Pro'**
  String get giftPageTitle;

  /// Shown instead of the gift form when the user has no free invitations left.
  ///
  /// In en, this message translates to:
  /// **'No free gift invitations are available right now.'**
  String get giftNoAllowances;

  /// Heading of the form that creates a free gift invitation.
  ///
  /// In en, this message translates to:
  /// **'Send a free invitation'**
  String get giftFormTitle;

  /// Explains under the form heading that the app does not email the recipient.
  ///
  /// In en, this message translates to:
  /// **'Your recipient claims the gift with this verified email. We don\'t send the email for you.'**
  String get giftFormBody;

  /// Text field label for the sender's name on the gift form.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get giftFieldFrom;

  /// Text field label for the recipient's name on the gift form.
  ///
  /// In en, this message translates to:
  /// **'Recipient name'**
  String get giftFieldRecipientName;

  /// Text field label for the recipient's email address on the gift form.
  ///
  /// In en, this message translates to:
  /// **'Recipient email'**
  String get giftFieldRecipientEmail;

  /// Dropdown label for the gift card occasion on the gift form.
  ///
  /// In en, this message translates to:
  /// **'Occasion (optional)'**
  String get giftFieldOccasion;

  /// First option of the occasion dropdown: no greeting is printed on the card.
  ///
  /// In en, this message translates to:
  /// **'No occasion'**
  String get giftNoOccasion;

  /// Occasion dropdown option: birthday greeting.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get giftOccasionBirthday;

  /// Occasion dropdown option: anniversary greeting.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get giftOccasionAnniversary;

  /// Occasion dropdown option that reveals a free-text card greeting field.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get giftOccasionOther;

  /// Text field label for a custom greeting typed by the sender.
  ///
  /// In en, this message translates to:
  /// **'Card greeting'**
  String get giftFieldCardGreeting;

  /// Helper text under the card greeting field; no editing happens on our side.
  ///
  /// In en, this message translates to:
  /// **'This appears on the card exactly as written.'**
  String get giftFieldCardGreetingHelper;

  /// Label of the optional message the sender can attach to the gift.
  ///
  /// In en, this message translates to:
  /// **'Private note (optional)'**
  String get giftFieldPrivateNote;

  /// Submit button of the gift form.
  ///
  /// In en, this message translates to:
  /// **'Create free gift'**
  String get giftCreateAction;

  /// Toast title shown after the user claims an incoming gift.
  ///
  /// In en, this message translates to:
  /// **'Gift claimed'**
  String get giftClaimedTitle;

  /// Toast body after claiming a gift that starts immediately.
  ///
  /// In en, this message translates to:
  /// **'Your FitCheck Pro gift is active.'**
  String get giftClaimedActive;

  /// Toast body after claiming a gift that queues behind a paid subscription.
  ///
  /// In en, this message translates to:
  /// **'Your FitCheck Pro gift starts after your current access.'**
  String get giftClaimedQueued;

  /// Toast shown when the share sheet failed and the gift link was copied instead.
  ///
  /// In en, this message translates to:
  /// **'Gift link copied to the clipboard.'**
  String get giftLinkCopied;

  /// Validation error under the From and Recipient name fields.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get giftErrorName;

  /// Validation error under the recipient email field.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get giftErrorEmail;

  /// Validation error when the occasion is Other but the greeting is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter the card greeting.'**
  String get giftErrorGreeting;

  /// Validation error when the custom card greeting exceeds 80 characters.
  ///
  /// In en, this message translates to:
  /// **'Use no more than 80 characters.'**
  String get giftErrorGreetingLength;

  /// Button on an incoming gift row that claims the gift for the signed-in user.
  ///
  /// In en, this message translates to:
  /// **'Claim gift'**
  String get giftClaimAction;

  /// Caption above the live preview of the card the recipient will see.
  ///
  /// In en, this message translates to:
  /// **'Card preview'**
  String get giftCardPreview;

  /// Default card heading when the sender chose no occasion.
  ///
  /// In en, this message translates to:
  /// **'A gift for you'**
  String get giftGiftForYou;

  /// Home banner title when exactly one incoming gift is waiting.
  ///
  /// In en, this message translates to:
  /// **'A gift is waiting for you'**
  String get giftGiftWaiting;

  /// Home banner body when several incoming gifts are waiting.
  ///
  /// In en, this message translates to:
  /// **'Open your gifts to claim them with your verified email.'**
  String get giftOpenBody;

  /// Home banner action that opens the gifts screen when a gift is waiting.
  ///
  /// In en, this message translates to:
  /// **'Open gifts'**
  String get giftOpenGifts;

  /// Home banner action that opens the gifts screen when the user has a free invitation to give.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get giftSendInvitation;

  /// Heading of the card that picks the AI provider (Custom vs OpenAI).
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get settingsAiProviderSection;

  /// Segment selecting a user-supplied, OpenAI-compatible AI endpoint.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get settingsAiCustom;

  /// Helper note under the provider picker explaining that a local URL cannot be reached.
  ///
  /// In en, this message translates to:
  /// **'Use a public URL the server can reach. Localhost does not work from our servers.'**
  String get settingsAiUrlHelper;

  /// Heading of the card holding the endpoint, key and model fields.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsAiConnectionSection;

  /// Text field label for the AI endpoint URL.
  ///
  /// In en, this message translates to:
  /// **'API URL'**
  String get settingsAiApiUrl;

  /// Text field label for the bearer key sent to the AI endpoint.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get settingsAiApiKey;

  /// Placeholder in the API key field when a key is already stored and is never shown again.
  ///
  /// In en, this message translates to:
  /// **'Saved. Leave blank to keep it.'**
  String get settingsAiApiKeySaved;

  /// Text field label for the model used for text generation.
  ///
  /// In en, this message translates to:
  /// **'Chat model'**
  String get settingsAiChatModel;

  /// Text field label for the model used to tag photos.
  ///
  /// In en, this message translates to:
  /// **'Vision model (optional)'**
  String get settingsAiVisionModel;

  /// Text field label for the model used to generate images.
  ///
  /// In en, this message translates to:
  /// **'Image model (optional)'**
  String get settingsAiImageModel;

  /// Note under the model fields; 'response_modalities' is an API parameter name and stays untranslated.
  ///
  /// In en, this message translates to:
  /// **'Image generation needs OpenAI-compatible chat completions with response_modalities.'**
  String get settingsAiImageModelNote;

  /// Button that sends a probe request to the configured AI endpoint.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get settingsAiTestConnection;

  /// Screen title of the planner (calendar) page. Also reused as the label of the Calendar row in the More hub.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// Tooltip on the icon button in the planner app bar that jumps the grid to today's date.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get calendarGoToToday;

  /// Tooltip on the icon button in the planner app bar that opens the connected-calendars sheet.
  ///
  /// In en, this message translates to:
  /// **'Connect a calendar'**
  String get calendarConnectTooltip;

  /// Floating action button on the planner that opens the new-event dialog.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get calendarAddEvent;

  /// Empty-state title under the day heading when the selected day has no events.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get calendarEmptyTitle;

  /// One line of help under calendarEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an event and plan what to wear.'**
  String get calendarEmptyBody;

  /// Tooltip on the left chevron that shows the previous month in the month grid.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// Tooltip on the right chevron that shows the next month in the month grid.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// Used twice: the switch label in the event form that marks an event as all-day, and the time column text of an all-day event row.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get calendarAllDay;

  /// Accessibility (screen reader) label of the hanger icon on an event row that has an outfit attached.
  ///
  /// In en, this message translates to:
  /// **'Outfit linked'**
  String get calendarOutfitLinked;

  /// Tooltip on the overflow (three dots) menu of an event row.
  ///
  /// In en, this message translates to:
  /// **'Event options'**
  String get calendarEventOptions;

  /// Title of the confirmation dialog shown before deleting an event.
  ///
  /// In en, this message translates to:
  /// **'Delete this event?'**
  String get calendarDeleteTitle;

  /// Event overflow menu item shown when an outfit is already linked.
  ///
  /// In en, this message translates to:
  /// **'Change outfit'**
  String get calendarChangeOutfit;

  /// Event overflow menu item when no outfit is linked, and the heading of the outfit picker sheet it opens.
  ///
  /// In en, this message translates to:
  /// **'Link an outfit'**
  String get calendarLinkOutfit;

  /// Event overflow menu item that unlinks the outfit from the event.
  ///
  /// In en, this message translates to:
  /// **'Remove outfit'**
  String get calendarRemoveOutfit;

  /// Title of the event form dialog when creating an event.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get calendarNewEvent;

  /// Title of the event form dialog when editing an existing event.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get calendarEditEvent;

  /// Field label for the event name in the event form.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get calendarTitleLabel;

  /// Validation error shown under the event name field when it is left empty.
  ///
  /// In en, this message translates to:
  /// **'Add a title'**
  String get calendarTitleRequired;

  /// Validation error shown when the event's end time is not after its start time.
  ///
  /// In en, this message translates to:
  /// **'End after the start time'**
  String get calendarEndBeforeStart;

  /// Row label for the event start date and time picker.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get calendarStarts;

  /// Row label for the event end date and time picker.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get calendarEnds;

  /// Field label for the event location.
  ///
  /// In en, this message translates to:
  /// **'Place (optional)'**
  String get calendarPlaceOptional;

  /// Field label for the event description/notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get calendarNotesOptional;

  /// Empty-state help in the outfit picker sheet when the user has no outfits yet.
  ///
  /// In en, this message translates to:
  /// **'Build an outfit, then link it to this event.'**
  String get calendarLinkOutfitEmptyBody;

  /// Action button in that empty state that opens the outfit builder.
  ///
  /// In en, this message translates to:
  /// **'Build an outfit'**
  String get calendarBuildOutfit;

  /// Heading of the bottom sheet that lists connected and connectable calendars.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get calendarConnectionsTitle;

  /// One line of help under calendarConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events you add here stay in FitCheck.'**
  String get calendarConnectionsBody;

  /// Button on a connected calendar row that removes the connection.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get calendarDisconnect;

  /// Subtitle on calendar providers that cannot sync yet, and the toast title shown when the user taps one.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get calendarNotAvailable;

  /// Group title above the Try-on, For you, Calendar and Rewards rows in the More hub.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get profileSectionExplore;

  /// Row in the More hub that opens virtual try-on.
  ///
  /// In en, this message translates to:
  /// **'Try-on'**
  String get profileNavTryOn;

  /// Row in the More hub that opens rewards and achievements.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get profileNavRewards;

  /// Group title of the Support section in the More hub. Also reused as the group title and the row label on the Privacy and terms page.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// Row in the More hub that opens the Help page, and the Help page app bar title.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelp;

  /// Row in the More hub that opens the About dialog.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAbout;

  /// One line describing the app, under its name in the About dialog.
  ///
  /// In en, this message translates to:
  /// **'Your closet, outfits and plans in one place.'**
  String get profileAboutBody;

  /// Title of the confirmation dialog shown before signing out.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutTitle;

  /// Body text of the sign-out confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in at any time.'**
  String get profileSignOutBody;

  /// App bar title of the profile edit page, the heading of the body-profile sheet in edit mode, and the accessibility label of the identity card that opens it.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// Placeholder shown on the identity card when the account has no name.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileYourProfile;

  /// App bar title of the body profiles page, and the More hub row that opens it.
  ///
  /// In en, this message translates to:
  /// **'Body profiles'**
  String get profileBodyProfiles;

  /// Empty-state title when the user has saved no body profiles.
  ///
  /// In en, this message translates to:
  /// **'No body profiles yet'**
  String get profileBodyEmptyTitle;

  /// Empty-state help under profileBodyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your height and build to get a better fit.'**
  String get profileBodyEmptyBody;

  /// Empty-state action and the bottom button that open the new-body-profile form.
  ///
  /// In en, this message translates to:
  /// **'Add a profile'**
  String get profileBodyAdd;

  /// Explanatory line above the list of saved body profiles.
  ///
  /// In en, this message translates to:
  /// **'Your default profile is used for fit and try-on.'**
  String get profileBodyDefaultNote;

  /// Badge shown next to the name of the default body profile. The two leading spaces are added in code, not in this string.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get profileBodyDefaultBadge;

  /// Overflow menu item that makes a body profile the default.
  ///
  /// In en, this message translates to:
  /// **'Make default'**
  String get profileBodyMakeDefault;

  /// Body of the confirmation dialog for deleting a body profile.
  ///
  /// In en, this message translates to:
  /// **'You cannot undo this.'**
  String get profileBodyDeleteBody;

  /// Validation error under an empty field in the body profile form.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get profileBodyRequired;

  /// Validation error when a height or weight is empty, zero or above the allowed maximum.
  ///
  /// In en, this message translates to:
  /// **'Check this number'**
  String get profileBodyCheckNumber;

  /// Heading of the body profile sheet when creating a new profile.
  ///
  /// In en, this message translates to:
  /// **'New body profile'**
  String get profileBodyNew;

  /// Hint text in the profile name field.
  ///
  /// In en, this message translates to:
  /// **'For example, Me'**
  String get profileBodyNameHint;

  /// Field label for height in the body profile form.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileBodyHeight;

  /// Field label for weight in the body profile form.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get profileBodyWeight;

  /// Field label for body build/shape in the body profile form.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get profileBodyBuild;

  /// Field label for skin tone in the body profile form.
  ///
  /// In en, this message translates to:
  /// **'Skin tone'**
  String get profileBodySkinTone;

  /// Toast message when the user enters a birth time without a birth date.
  ///
  /// In en, this message translates to:
  /// **'Add a date of birth to go with the birth time.'**
  String get profileBirthDateNeededBody;

  /// Title of that toast message.
  ///
  /// In en, this message translates to:
  /// **'Date of birth needed'**
  String get profileBirthDateNeededTitle;

  /// Warning toast when the server saved the name and photo but skipped the birth details.
  ///
  /// In en, this message translates to:
  /// **'We saved your name and photo. Birth details did not save; try again later.'**
  String get profilePartlySavedBody;

  /// Title of that warning toast.
  ///
  /// In en, this message translates to:
  /// **'Partly saved'**
  String get profilePartlySavedTitle;

  /// Success toast shown after saving the profile.
  ///
  /// In en, this message translates to:
  /// **'Your profile is saved.'**
  String get profileSavedBody;

  /// Accessibility (screen reader) label of the tappable profile photo card.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileChangePhoto;

  /// Heading inside the profile photo card.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhotoLabel;

  /// One line of help under profilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a new one'**
  String get profilePhotoHint;

  /// Field label for the birth date picker.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (optional)'**
  String get profileBirthDateLabel;

  /// Field label for the birth time picker.
  ///
  /// In en, this message translates to:
  /// **'Birth time (optional)'**
  String get profileBirthTimeLabel;

  /// Helper text under the birth time field.
  ///
  /// In en, this message translates to:
  /// **'Makes Vedic suggestions more exact'**
  String get profileBirthTimeHelper;

  /// Field label for the birth place field.
  ///
  /// In en, this message translates to:
  /// **'Birth place (optional)'**
  String get profileBirthPlaceLabel;

  /// Hint text in the birth place field.
  ///
  /// In en, this message translates to:
  /// **'For example, New Delhi, India'**
  String get profileBirthPlaceHint;

  /// Heading of the contact card at the top of the Help page.
  ///
  /// In en, this message translates to:
  /// **'Ask us anything'**
  String get profileHelpContactTitle;

  /// One line of help under profileHelpContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a message and we reply by email, usually within a day.'**
  String get profileHelpContactBody;

  /// Button on the Help page that opens the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get profileHelpContactAction;

  /// Group title above the FAQ list on the Help page.
  ///
  /// In en, this message translates to:
  /// **'Common questions'**
  String get profileHelpFaqTitle;

  /// FAQ question on the Help page about adding closet items.
  ///
  /// In en, this message translates to:
  /// **'How do I add pieces to my closet?'**
  String get profileFaqAddPiecesTitle;

  /// FAQ answer under profileFaqAddPiecesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap Add item on the Closet tab. Take a photo or pick one from your gallery; we find each piece and tag it for you.'**
  String get profileFaqAddPiecesBody;

  /// FAQ question on the Help page about outfit suggestions.
  ///
  /// In en, this message translates to:
  /// **'How does outfit matching work?'**
  String get profileFaqMatchingTitle;

  /// FAQ answer under profileFaqMatchingTitle.
  ///
  /// In en, this message translates to:
  /// **'Open For you and pick pieces you own. We suggest what goes with them and build full outfits from your closet.'**
  String get profileFaqMatchingBody;

  /// FAQ question on the Help page about try-on photos.
  ///
  /// In en, this message translates to:
  /// **'Can I use my own photos for try-on?'**
  String get profileFaqTryOnTitle;

  /// FAQ answer under profileFaqTryOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Yes. Add a full-length photo of yourself, then choose pieces to see them on you.'**
  String get profileFaqTryOnBody;

  /// FAQ question on the Help page about streaks and rewards.
  ///
  /// In en, this message translates to:
  /// **'How do I earn rewards?'**
  String get profileFaqRewardsTitle;

  /// FAQ answer under profileFaqRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan and log outfits often. Streaks and achievements build as you go.'**
  String get profileFaqRewardsBody;

  /// FAQ question on the Help page about privacy.
  ///
  /// In en, this message translates to:
  /// **'Is my closet private?'**
  String get profileFaqPrivacyTitle;

  /// FAQ answer under profileFaqPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Yes. Your closet and outfits are private unless you share a link to one outfit.'**
  String get profileFaqPrivacyBody;

  /// Group title above the extra help links on the Help page.
  ///
  /// In en, this message translates to:
  /// **'More help'**
  String get profileHelpMoreTitle;

  /// Row on the Help page that opens the external documentation site.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get profileHelpGuides;

  /// Subtitle of the Guides row.
  ///
  /// In en, this message translates to:
  /// **'How each feature works'**
  String get profileHelpGuidesBody;

  /// Feedback category chip for bug reports.
  ///
  /// In en, this message translates to:
  /// **'Something broke'**
  String get feedbackCategoryBug;

  /// Feedback category chip for feature requests.
  ///
  /// In en, this message translates to:
  /// **'An idea'**
  String get feedbackCategoryIdea;

  /// Feedback category chip for general feedback.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get feedbackCategoryGeneral;

  /// Feedback category chip for support requests.
  ///
  /// In en, this message translates to:
  /// **'I need help'**
  String get feedbackCategoryHelp;

  /// Hint inside the details field when the bug-report category is selected.
  ///
  /// In en, this message translates to:
  /// **'What happened, and what did you expect? Steps help us fix it.'**
  String get feedbackHintBug;

  /// Hint inside the details field when the feature-request category is selected.
  ///
  /// In en, this message translates to:
  /// **'What would you like, and why?'**
  String get feedbackHintIdea;

  /// Hint inside the details field for general feedback and support categories.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think, or ask a question.'**
  String get feedbackHintGeneral;

  /// Toast message when the user tries to attach more than five screenshots.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 5 images.'**
  String get feedbackAttachmentLimitBody;

  /// Title of that toast message.
  ///
  /// In en, this message translates to:
  /// **'Limit reached'**
  String get feedbackAttachmentLimitTitle;

  /// Toast message when the picked screenshot is too large.
  ///
  /// In en, this message translates to:
  /// **'Choose an image under 5 MB.'**
  String get feedbackImageTooLargeBody;

  /// Title of that toast message.
  ///
  /// In en, this message translates to:
  /// **'Image too large'**
  String get feedbackImageTooLargeTitle;

  /// App bar title of the feedback page. Also the label of the Send feedback row in the More hub.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackTitle;

  /// Heading above the feedback category chips.
  ///
  /// In en, this message translates to:
  /// **'What is it about?'**
  String get feedbackAboutLabel;

  /// Field label for the feedback subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get feedbackSubjectLabel;

  /// Validation error when the subject field is empty.
  ///
  /// In en, this message translates to:
  /// **'Add a subject'**
  String get feedbackSubjectRequired;

  /// Validation error when the subject is shorter than 3 characters.
  ///
  /// In en, this message translates to:
  /// **'Subject must be at least 3 characters'**
  String get feedbackSubjectTooShort;

  /// Field label for the feedback description.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get feedbackDetailsLabel;

  /// Validation error when the description field is empty.
  ///
  /// In en, this message translates to:
  /// **'Add some details'**
  String get feedbackDetailsRequired;

  /// Validation error when the description is shorter than 10 characters.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters'**
  String get feedbackDetailsTooShort;

  /// Button that opens the camera/gallery picker for attachments.
  ///
  /// In en, this message translates to:
  /// **'Add a screenshot'**
  String get feedbackAddScreenshot;

  /// Small hint next to the add-screenshot button describing the attachment limits.
  ///
  /// In en, this message translates to:
  /// **'Up to 5, 5 MB each'**
  String get feedbackAttachmentHint;

  /// Submit button of the feedback form.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// Empty-state title in the list of the user's previous feedback.
  ///
  /// In en, this message translates to:
  /// **'Nothing sent yet'**
  String get feedbackEmptyTitle;

  /// Empty-state help under feedbackEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'What you send shows up here with its status.'**
  String get feedbackEmptyBody;

  /// Group title above the user's previous feedback tickets.
  ///
  /// In en, this message translates to:
  /// **'What you sent'**
  String get feedbackHistoryTitle;

  /// Status label on a feedback ticket that is open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get feedbackStatusOpen;

  /// Status label on a feedback ticket that is being worked on.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get feedbackStatusInProgress;

  /// Status label on a feedback ticket that is resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get feedbackStatusResolved;

  /// Status label on a feedback ticket that is closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get feedbackStatusClosed;

  /// Intro paragraph at the top of the Privacy and terms page.
  ///
  /// In en, this message translates to:
  /// **'How we protect your data, and the terms for using FitCheck AI.'**
  String get legalIntro;

  /// Group title above the privacy policy and terms rows.
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get legalPolicies;

  /// Subtitle of the Privacy policy row.
  ///
  /// In en, this message translates to:
  /// **'What we collect and why'**
  String get legalPrivacySubtitle;

  /// Title of the row that opens the terms of service.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get legalTermsTitle;

  /// Subtitle of the Terms of service row.
  ///
  /// In en, this message translates to:
  /// **'The rules for using the app'**
  String get legalTermsSubtitle;

  /// Title of the row that opens the licence page.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get legalLicences;

  /// Subtitle of the Support row on the Privacy and terms page.
  ///
  /// In en, this message translates to:
  /// **'Help, contact and privacy requests'**
  String get legalSupportSubtitle;

  /// Title of the row that emails support. Also used as the subject of that email when the mail app opens.
  ///
  /// In en, this message translates to:
  /// **'Report a problem or abuse'**
  String get legalReportAbuse;

  /// Title of the pre-permission dialog shown before iOS asks for camera access.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get permissionCameraTitle;

  /// Body of the pre-permission dialog for the camera.
  ///
  /// In en, this message translates to:
  /// **'FitCheck AI uses your camera to capture photos of your clothing and outfits for AI try-on and closet organization.'**
  String get permissionCameraRationale;

  /// Title of the pre-permission dialog shown before iOS asks for photo library access.
  ///
  /// In en, this message translates to:
  /// **'Photo Access'**
  String get permissionPhotoTitle;

  /// Body of the pre-permission dialog for the photo library.
  ///
  /// In en, this message translates to:
  /// **'FitCheck AI needs access to your photos so you can select clothing and outfit images for AI features and your closet.'**
  String get permissionPhotoRationale;

  /// Dismiss button in the dialog shown after a permission was denied.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get permissionNotNow;

  /// Button in the denied-permission dialog that deep-links to the system Settings app.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permissionOpenSettings;

  /// Toast body after a successful sign-in, naming the account.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String authSignedInAs(String name);

  /// Toast body after a successful sign-in when the account name is unknown.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get authSignedIn;

  /// Toast title after a successful sign-in.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBackTitle;

  /// Toast title when signing in failed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed'**
  String get authSignInFailed;

  /// Toast title after a successful sign-up.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcomeTitle;

  /// Toast title when signing up failed.
  ///
  /// In en, this message translates to:
  /// **'Sign-up failed'**
  String get authSignUpFailed;

  /// Toast title when the Google sign-in flow failed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get authGoogleSignInFailed;

  /// Toast title when the Apple sign-in flow failed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed'**
  String get authAppleSignInFailed;

  /// Toast title telling the user to open the confirmation email.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get authConfirmEmailTitle;

  /// Toast body for the confirm-your-email prompt.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for a confirmation email, then sign in.'**
  String get authConfirmEmailBody;

  /// Toast body right after sign-up completes.
  ///
  /// In en, this message translates to:
  /// **'Your closet is ready.'**
  String get authClosetReady;

  /// Toast title after signing out.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get authSignedOutTitle;

  /// Toast body after signing out.
  ///
  /// In en, this message translates to:
  /// **'You are signed out.'**
  String get authSignedOutBody;

  /// Toast title when signing out failed.
  ///
  /// In en, this message translates to:
  /// **'Sign-out failed'**
  String get authSignOutFailed;

  /// Toast title after an email (reset link or confirmation) was sent.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get authEmailSentTitle;

  /// Toast body after a password-reset email was sent.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a reset link.'**
  String get authResetLinkSent;

  /// Toast title after the password was changed.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get authPasswordUpdatedTitle;

  /// Toast body after the password was changed.
  ///
  /// In en, this message translates to:
  /// **'Your password is updated.'**
  String get authPasswordUpdated;

  /// Toast title when changing the password failed.
  ///
  /// In en, this message translates to:
  /// **'Password not updated'**
  String get authPasswordNotUpdated;

  /// Toast title when the password-reset email could not be sent.
  ///
  /// In en, this message translates to:
  /// **'Could not send the email'**
  String get authCouldNotSendEmail;

  /// Toast title when the confirmation email could not be resent.
  ///
  /// In en, this message translates to:
  /// **'Email not sent'**
  String get authEmailNotSent;

  /// Toast body after a confirmation email was resent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new confirmation email.'**
  String get authResendSentBody;

  /// Bottom-bar button in the outfit builder that asks the AI to render a preview of the chosen pieces.
  ///
  /// In en, this message translates to:
  /// **'Preview with AI'**
  String get outfitPreviewWithAi;

  /// Bottom-bar button in the outfit builder once a preview exists; regenerates the AI preview.
  ///
  /// In en, this message translates to:
  /// **'Make a new preview'**
  String get outfitNewPreview;

  /// Section heading above the piece picker in the outfit builder.
  ///
  /// In en, this message translates to:
  /// **'Your closet'**
  String get outfitBuilderClosetHeading;

  /// Placeholder of the search field that filters the closet pieces in the outfit builder.
  ///
  /// In en, this message translates to:
  /// **'Search pieces'**
  String get outfitBuilderSearchHint;

  /// Tooltip on the clear button of the outfit builder search field.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get outfitClearSearch;

  /// Empty-state title in the outfit builder when the closet has no pieces.
  ///
  /// In en, this message translates to:
  /// **'Add pieces first'**
  String get outfitBuilderAddPiecesTitle;

  /// Explanation under the empty-state title in the outfit builder.
  ///
  /// In en, this message translates to:
  /// **'Outfits are made from the pieces in your closet.'**
  String get outfitBuilderAddPiecesBody;

  /// Shown in the outfit builder when the search text or category filter returns no pieces.
  ///
  /// In en, this message translates to:
  /// **'No pieces match.'**
  String get outfitBuilderNoMatches;

  /// Label of the text field where the outfit is named in the builder.
  ///
  /// In en, this message translates to:
  /// **'Outfit name'**
  String get outfitNameLabel;

  /// Example placeholder inside the outfit name field in the builder.
  ///
  /// In en, this message translates to:
  /// **'For example, Weekend linen'**
  String get outfitNameHint;

  /// Screen-reader label for the AI-generated outfit preview image in the builder.
  ///
  /// In en, this message translates to:
  /// **'AI preview of the outfit'**
  String get outfitPreviewSemantic;

  /// Heading above the chosen-pieces row in the outfit builder when nothing is selected yet.
  ///
  /// In en, this message translates to:
  /// **'Choose pieces'**
  String get outfitChoosePieces;

  /// Hint under the chosen-pieces row when no piece is selected.
  ///
  /// In en, this message translates to:
  /// **'Tap pieces below to add them.'**
  String get outfitTapPiecesHint;

  /// Tooltip on the share icon in the outfit detail app bar.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get outfitShareTooltip;

  /// Tooltip on the heart icon when the outfit is not a favourite yet.
  ///
  /// In en, this message translates to:
  /// **'Save to favourites'**
  String get outfitSaveFavourite;

  /// Heading above the horizontal strip of pieces that make up the outfit.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get outfitPiecesHeading;

  /// Shown in the wear-history card before the outfit has been worn.
  ///
  /// In en, this message translates to:
  /// **'Wear it once and the dates show up here.'**
  String get outfitWearHistoryEmpty;

  /// Title of the dialog listing every date the outfit was worn.
  ///
  /// In en, this message translates to:
  /// **'Wear history'**
  String get outfitWearHistoryTitle;

  /// Shown when the wear-history request fails; a Retry button follows it.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the dates.'**
  String get outfitWearHistoryError;

  /// Heading of the card that lists the dates the outfit was worn.
  ///
  /// In en, this message translates to:
  /// **'Worn on'**
  String get outfitWornOn;

  /// App bar title of the edit-outfit screen, also shown on its loading scaffold.
  ///
  /// In en, this message translates to:
  /// **'Edit outfit'**
  String get outfitEditTitle;

  /// Error title when the outfit fields were saved but the photo changes failed.
  ///
  /// In en, this message translates to:
  /// **'Details saved, photos not'**
  String get outfitSavedPhotosFailed;

  /// Placeholder in the photo strip on the edit-outfit screen.
  ///
  /// In en, this message translates to:
  /// **'No photos yet. The outfit shows its pieces instead.'**
  String get outfitNoPhotosBody;

  /// Label of the occasion dropdown in the outfit edit form.
  ///
  /// In en, this message translates to:
  /// **'Occasion'**
  String get outfitOccasionLabel;

  /// Dropdown option that clears the outfit's occasion.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get outfitOccasionNone;

  /// Helper text under the tags field of the outfit edit form.
  ///
  /// In en, this message translates to:
  /// **'Separate with commas'**
  String get outfitTagsHint;

  /// Subtitle of the Draft switch in the outfit edit form.
  ///
  /// In en, this message translates to:
  /// **'Hidden from your main list'**
  String get outfitDraftBody;

  /// Title of the switch that makes an outfit shareable by link.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get outfitPublic;

  /// Subtitle of the Public switch in the outfit edit form.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the link can see it'**
  String get outfitPublicBody;

  /// Footnote on the edit screen saying deletion happens on the detail page.
  ///
  /// In en, this message translates to:
  /// **'Delete this outfit from its detail page.'**
  String get outfitDeleteFromDetail;

  /// Floating action button on the Collections page and the title of the create-collection dialog.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get outfitNewCollection;

  /// Empty-state title on the Collections page.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get outfitNoCollectionsTitle;

  /// Explanation under the Collections empty state.
  ///
  /// In en, this message translates to:
  /// **'Group outfits by trip, season or mood.'**
  String get outfitNoCollectionsBody;

  /// Action button in the Collections empty state.
  ///
  /// In en, this message translates to:
  /// **'Create a collection'**
  String get outfitCreateCollection;

  /// Button in a collection sheet that opens the outfit picker.
  ///
  /// In en, this message translates to:
  /// **'Add outfits'**
  String get outfitAddOutfits;

  /// Button in a collection sheet that opens the rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get outfitRename;

  /// Body of the confirm-delete dialog for a collection.
  ///
  /// In en, this message translates to:
  /// **'The outfits in it are kept.'**
  String get outfitCollectionDeleteBody;

  /// Error snackbar title when a collection's outfit list cannot be fetched.
  ///
  /// In en, this message translates to:
  /// **'Outfits not loaded'**
  String get outfitCollectionsNotLoaded;

  /// Title of the collection dialog when renaming an existing collection.
  ///
  /// In en, this message translates to:
  /// **'Rename collection'**
  String get outfitRenameCollection;

  /// Label of the optional description field in the collection dialog.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get outfitDescriptionOptional;

  /// Shown in the outfit picker when there is no outfit left to add.
  ///
  /// In en, this message translates to:
  /// **'Every outfit is already in this collection.'**
  String get outfitAllInCollection;

  /// Subtitle under the Photoshoot tab header on the upload step.
  ///
  /// In en, this message translates to:
  /// **'Studio portraits from your own photos'**
  String get photoshootSubtitleUpload;

  /// Subtitle under the Photoshoot tab header on the configure step.
  ///
  /// In en, this message translates to:
  /// **'Pick a style, a format and a count'**
  String get photoshootSubtitleConfigure;

  /// Subtitle under the Photoshoot tab header while images generate.
  ///
  /// In en, this message translates to:
  /// **'This takes a minute or two'**
  String get photoshootSubtitleGenerating;

  /// Screen-reader label on the empty photo upload card.
  ///
  /// In en, this message translates to:
  /// **'Add photos from your gallery'**
  String get photoshootAddPhotosSemantic;

  /// Heading on the empty photo upload card on the upload step.
  ///
  /// In en, this message translates to:
  /// **'Add 1 to 4 photos of yourself'**
  String get photoshootUploadTitle;

  /// Second line on the empty photo upload card.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose from your gallery'**
  String get photoshootUploadBody;

  /// Continue button on the upload step when no photo has been chosen yet.
  ///
  /// In en, this message translates to:
  /// **'Add a photo to continue'**
  String get photoshootAddToContinue;

  /// Screen-reader label on the plus tile that adds one more photo to the grid.
  ///
  /// In en, this message translates to:
  /// **'Add another photo'**
  String get photoshootAddAnotherPhoto;

  /// Heading of the photo tips card on the upload step.
  ///
  /// In en, this message translates to:
  /// **'For the best results'**
  String get photoshootTipsTitle;

  /// Body of the photo tips card on the upload step.
  ///
  /// In en, this message translates to:
  /// **'Use clear, well-lit photos of your face from a few angles. Skip sunglasses and hats.'**
  String get photoshootTipsBody;

  /// Fallback status line at the top of the generating step before the server sends a status.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get photoshootStarting;

  /// Cancel button label while a photoshoot is being cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelling'**
  String get photoshootCancelling;

  /// Screen-reader label on a photoshoot image slot whose generation failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get photoshootFailed;

  /// Recommendations tab label for finding pieces that match the selected ones.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get recommendTabMatches;

  /// Recommendations tab label for completing a look from selected pieces.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get recommendTabComplete;

  /// Recommendations tab label for weather-based picks.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get recommendTabWeather;

  /// Recommendations tab label for lucky colours.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get recommendTabColours;

  /// Recommendations tab label for what to buy.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get recommendTabShop;

  /// Empty state on the Matches tab before any piece has been picked.
  ///
  /// In en, this message translates to:
  /// **'No matches yet'**
  String get recommendNoMatchesTitle;

  /// Explanation under the Matches empty state.
  ///
  /// In en, this message translates to:
  /// **'Pick a piece and we\'ll find what goes with it.'**
  String get recommendNoMatchesBody;

  /// Button that opens the closet picker, used on the Matches and Complete tabs.
  ///
  /// In en, this message translates to:
  /// **'Pick a piece'**
  String get recommendPickPiece;

  /// Empty state on the Matches tab when the selected pieces have no matches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these yet'**
  String get recommendNothingMatchesTitle;

  /// Explanation under the no-matches empty state.
  ///
  /// In en, this message translates to:
  /// **'Try other pieces, or add more to your closet.'**
  String get recommendNothingMatchesBody;

  /// Action that reopens the piece picker from the no-matches empty state.
  ///
  /// In en, this message translates to:
  /// **'Change pieces'**
  String get recommendChangePieces;

  /// Fallback reason in the match detail sheet when the server sends none.
  ///
  /// In en, this message translates to:
  /// **'It suits the pieces you picked.'**
  String get recommendDefaultReason;

  /// Empty state title on the Complete tab before a piece is picked.
  ///
  /// In en, this message translates to:
  /// **'Complete a look'**
  String get recommendCompleteTitle;

  /// Explanation under the Complete tab empty state.
  ///
  /// In en, this message translates to:
  /// **'Pick a piece and we\'ll fill in the rest.'**
  String get recommendCompleteBody;

  /// Generate button label while looks are being generated.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get recommendWorking;

  /// Generate button label on the Complete tab.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get recommendGenerate;

  /// Hint shown on the Complete tab before the first look is generated.
  ///
  /// In en, this message translates to:
  /// **'Choose a style, then generate.'**
  String get recommendChooseStyleBody;

  /// Empty state when the generated request returned no looks.
  ///
  /// In en, this message translates to:
  /// **'No looks for these pieces'**
  String get recommendNoLooksTitle;

  /// Explanation under the no-looks empty state.
  ///
  /// In en, this message translates to:
  /// **'Try another style or other pieces.'**
  String get recommendNoLooksBody;

  /// Fallback title of a generated look when the server sends no description.
  ///
  /// In en, this message translates to:
  /// **'A look for your pieces'**
  String get recommendDefaultLook;

  /// Shown under a generated look that contains no pieces.
  ///
  /// In en, this message translates to:
  /// **'No pieces came back for this look.'**
  String get recommendNoPiecesBody;

  /// Label of the city text field on the Weather tab.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get recommendCityLabel;

  /// Button that fetches the weather for the entered city.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get recommendCheck;

  /// Empty state title on the Weather tab before a city is set.
  ///
  /// In en, this message translates to:
  /// **'What\'s the weather?'**
  String get recommendWeatherTitle;

  /// Explanation under the Weather tab empty state.
  ///
  /// In en, this message translates to:
  /// **'Enter your city to get picks for today.'**
  String get recommendWeatherBody;

  /// Heading above the weather-based piece picks.
  ///
  /// In en, this message translates to:
  /// **'Wear today'**
  String get recommendWearToday;

  /// Shown when the closet has no piece suited to today's weather.
  ///
  /// In en, this message translates to:
  /// **'No pieces in your closet for this weather yet.'**
  String get recommendWeatherNoPieces;

  /// Label next to the price slider on the Shop tab.
  ///
  /// In en, this message translates to:
  /// **'Budget up to'**
  String get recommendBudgetLabel;

  /// Button label while shopping suggestions are loading.
  ///
  /// In en, this message translates to:
  /// **'Looking'**
  String get recommendLooking;

  /// Button label on the Shop tab that requests purchase suggestions.
  ///
  /// In en, this message translates to:
  /// **'Find what to buy'**
  String get recommendFindWhatToBuy;

  /// Empty state title on the Shop tab before the first search.
  ///
  /// In en, this message translates to:
  /// **'Fill the gaps'**
  String get recommendFillGapsTitle;

  /// Explanation under the Shop tab empty state.
  ///
  /// In en, this message translates to:
  /// **'Set a budget and we\'ll suggest what your closet is missing.'**
  String get recommendFillGapsBody;

  /// Empty state when the Shop search returned nothing.
  ///
  /// In en, this message translates to:
  /// **'No gaps found'**
  String get recommendNoGapsTitle;

  /// Explanation under the no-gaps empty state.
  ///
  /// In en, this message translates to:
  /// **'Try a bigger budget or another category.'**
  String get recommendNoGapsBody;

  /// Segment on the Colours tab for a normal day.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get recommendMoodEveryday;

  /// Segment on the Colours tab for an important meeting day.
  ///
  /// In en, this message translates to:
  /// **'Big meeting'**
  String get recommendMoodBigMeeting;

  /// Label of the date field on the Colours tab.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get recommendDayLabel;

  /// Button label while the colour reading loads.
  ///
  /// In en, this message translates to:
  /// **'Reading the stars'**
  String get recommendReadingStars;

  /// Button label on the Colours tab that requests the reading.
  ///
  /// In en, this message translates to:
  /// **'Get my colours'**
  String get recommendGetMyColours;

  /// Empty state title on the Colours tab before a reading.
  ///
  /// In en, this message translates to:
  /// **'Your lucky colours'**
  String get recommendLuckyColoursTitle;

  /// Explanation under the Colours tab empty state.
  ///
  /// In en, this message translates to:
  /// **'Pick a day and we\'ll suggest colours and pieces for it.'**
  String get recommendLuckyColoursBody;

  /// Section heading listing the day's lucky colours.
  ///
  /// In en, this message translates to:
  /// **'Lucky colours'**
  String get recommendLuckyColoursSection;

  /// Section heading listing the colours to avoid on the chosen day.
  ///
  /// In en, this message translates to:
  /// **'Colours to go easy on'**
  String get recommendAvoidColoursSection;

  /// Section heading shown on the Colours tab when the profile has no birth date.
  ///
  /// In en, this message translates to:
  /// **'Add your birth date'**
  String get recommendBirthDateTitle;

  /// Explanation under the add-birth-date heading.
  ///
  /// In en, this message translates to:
  /// **'We need your date of birth to read your colours.'**
  String get recommendBirthDateBody;

  /// Button that opens the profile editor from the Colours tab.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get recommendEditProfile;

  /// Shown when a colour section has no entries for the chosen day.
  ///
  /// In en, this message translates to:
  /// **'Nothing for this day.'**
  String get recommendNothingThisDay;

  /// Fallback name for a colour the server returned without one.
  ///
  /// In en, this message translates to:
  /// **'Unnamed colour'**
  String get recommendUnnamedColour;

  /// Section heading listing own pieces in the lucky colours.
  ///
  /// In en, this message translates to:
  /// **'From your closet'**
  String get recommendFromCloset;

  /// Shown when no own piece matches the lucky colours.
  ///
  /// In en, this message translates to:
  /// **'No pieces in these colours yet.'**
  String get recommendNoPiecesInColours;

  /// Section heading listing outfit suggestions for the lucky colours.
  ///
  /// In en, this message translates to:
  /// **'Outfit ideas'**
  String get recommendOutfitIdeas;

  /// Shown when no outfit suggestion exists for the lucky colours.
  ///
  /// In en, this message translates to:
  /// **'No full outfit in these colours yet.'**
  String get recommendNoOutfitsInColours;

  /// Fallback description for a suggested outfit the server sent without one.
  ///
  /// In en, this message translates to:
  /// **'An outfit idea'**
  String get recommendDefaultOutfitIdea;

  /// Heading of the closet picker sheet used by the recommendations tabs.
  ///
  /// In en, this message translates to:
  /// **'Pick up to three pieces'**
  String get recommendPickUpToThree;

  /// Explanation under the empty-closet state in the recommendations piece picker.
  ///
  /// In en, this message translates to:
  /// **'Add a few pieces first, then come back for matches.'**
  String get recommendEmptyClosetBody;

  /// Fallback weather advice on the home tab when the server sends none.
  ///
  /// In en, this message translates to:
  /// **'Dress for the day ahead.'**
  String get dashboardDressForDay;

  /// Small label above today's outfit name on the home tab.
  ///
  /// In en, this message translates to:
  /// **'Outfit of the day'**
  String get dashboardOutfitOfDay;

  /// Fallback name when today's outfit has no name.
  ///
  /// In en, this message translates to:
  /// **'A fresh look'**
  String get dashboardFreshLook;

  /// Toast title shown to a subscriber who taps cancel on a plan billed by the App Store or Play Store.
  ///
  /// In en, this message translates to:
  /// **'Manage in the store'**
  String get subscriptionManageInStoreTitle;

  /// Toast body explaining that a store-billed plan must be cancelled from the store, shown after the in-app cancel is refused.
  ///
  /// In en, this message translates to:
  /// **'This plan is billed through the store. Manage it in your store account settings.'**
  String get subscriptionManageInStoreBody;

  /// Toast title confirming the cancellation of a card-billed subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled'**
  String get subscriptionCancelledTitle;

  /// Toast body after a successful cancellation, telling the subscriber when their access ends.
  ///
  /// In en, this message translates to:
  /// **'Your plan stays active until the end of this billing period.'**
  String get subscriptionCancelledBody;

  /// Toast title shown to a subscriber when the cancellation request fails.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel'**
  String get subscriptionCancelFailedTitle;

  /// Toast title shown when the app cannot open the billing portal or an external store link.
  ///
  /// In en, this message translates to:
  /// **'Could not open'**
  String get subscriptionCouldNotOpenTitle;

  /// Toast body shown on web when the billing portal session comes back empty.
  ///
  /// In en, this message translates to:
  /// **'Could not open billing management.'**
  String get subscriptionOpenBillingFailedBody;

  /// Toast body shown when an external billing or store link cannot be launched on the device.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get subscriptionOpenLinkFailedBody;

  /// Toast title shown when the signed-in user's referral code cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Could not load your link'**
  String get subscriptionReferralLoadFailedTitle;

  /// Toast body shown when the referral link fails to load before the user copies or shares it.
  ///
  /// In en, this message translates to:
  /// **'Could not load your referral link. Try again.'**
  String get subscriptionReferralLoadFailedBody;

  /// Toast title after the referral link is placed on the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get subscriptionReferralCopiedTitle;

  /// Toast body confirming the user's referral link was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Referral link copied.'**
  String get subscriptionReferralCopiedBody;

  /// Subject line of the system share sheet when the user shares their referral invite.
  ///
  /// In en, this message translates to:
  /// **'Try FitCheck AI'**
  String get subscriptionReferralShareSubject;

  /// Body of the system share sheet when the user shares their referral invite, ending with their referral link.
  ///
  /// In en, this message translates to:
  /// **'Join FitCheck AI and we both get a month of Pro. {link}'**
  String subscriptionReferralShareMessage(String link);

  /// Toast title shown when the share sheet is unavailable and the referral link is copied instead.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get subscriptionLinkCopiedTitle;

  /// Toast body telling the user their referral link was copied because the share sheet failed.
  ///
  /// In en, this message translates to:
  /// **'Sharing is not available, so we copied the link.'**
  String get subscriptionShareUnavailableBody;

  /// Toast title shown when both sharing and copying the referral link fail.
  ///
  /// In en, this message translates to:
  /// **'Could not share'**
  String get subscriptionShareFailedTitle;

  /// Toast body telling the user where else to find their referral link after share and copy both fail.
  ///
  /// In en, this message translates to:
  /// **'Copy the link from the referral page instead.'**
  String get subscriptionShareFailedBody;

  /// Toast title after the paywall's retry makes the store products available again.
  ///
  /// In en, this message translates to:
  /// **'Store ready'**
  String get subscriptionStoreReadyTitle;

  /// Toast body telling the subscriber that upgrades work again after a successful store retry.
  ///
  /// In en, this message translates to:
  /// **'Store prices are available. You can upgrade now.'**
  String get subscriptionStoreReadyBody;

  /// Toast title shown when checkout or a store purchase errors.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed'**
  String get purchaseFailedTitle;

  /// Toast title shown when checkout for a plan cannot start.
  ///
  /// In en, this message translates to:
  /// **'Purchase unavailable'**
  String get purchaseUnavailableTitle;

  /// Toast body shown when the device cannot make in-app purchases from the store.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are not available on this device.'**
  String get purchaseIapUnavailableBody;

  /// Toast body shown when the store has no product for the plan the user tapped.
  ///
  /// In en, this message translates to:
  /// **'This plan is not available for purchase yet.'**
  String get purchasePlanNotAvailableBody;

  /// Toast body shown when the store has already failed to serve this plan for the whole session.
  ///
  /// In en, this message translates to:
  /// **'This plan is not available in the store yet. Please check back soon.'**
  String get purchasePlanNotInStoreBody;

  /// Toast body shown when the store refuses to open the native purchase sheet.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not start. Try again.'**
  String get purchaseStartFailedBody;

  /// Toast body shown on web when Stripe checkout returns no payment URL.
  ///
  /// In en, this message translates to:
  /// **'Checkout did not return a payment link.'**
  String get purchaseNoPaymentLinkBody;

  /// Toast title shown while a store purchase waits for parental or bank approval.
  ///
  /// In en, this message translates to:
  /// **'Purchase pending'**
  String get purchasePendingTitle;

  /// Toast body explaining that an Ask to Buy purchase needs approval before the subscription activates.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is waiting for approval. You\'ll get access as soon as it\'s approved.'**
  String get purchasePendingBody;

  /// Toast body replacing the raw store error when a purchase reports an error status.
  ///
  /// In en, this message translates to:
  /// **'The purchase failed. Try again.'**
  String get purchaseFailedBody;

  /// Toast title shown to the user after the store restores their past purchases.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get purchaseRestoredTitle;

  /// Toast body confirming that a restored purchase was verified and applied.
  ///
  /// In en, this message translates to:
  /// **'Your purchases are restored.'**
  String get purchaseRestoredBody;

  /// Toast title shown after a purchase made on the paywall activates the subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription active'**
  String get purchaseActiveTitle;

  /// Toast body welcoming the user after their paywall purchase is verified.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active. Welcome.'**
  String get purchaseActiveBody;

  /// Toast title shown when a purchase cannot be applied because no user is signed in.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get purchaseSignInRequiredTitle;

  /// Toast body asking the signed-out user to sign in so their purchase can be verified.
  ///
  /// In en, this message translates to:
  /// **'Sign in to finish your purchase.'**
  String get purchaseSignInRequiredBody;

  /// Toast title shown when a store transaction carries no usable transaction ID.
  ///
  /// In en, this message translates to:
  /// **'Purchase error'**
  String get purchaseErrorTitle;

  /// Toast body shown when a store purchase cannot be verified because it has no transaction ID.
  ///
  /// In en, this message translates to:
  /// **'The purchase did not include a verifiable transaction ID.'**
  String get purchaseInvalidTransactionBody;

  /// Toast title shown when the backend cannot be reached to verify a purchase right away.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get purchaseVerificationPendingTitle;

  /// Toast body reassuring the user that a temporarily unverified purchase completes itself without a second charge.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your purchase with the store right now. It will finish automatically, and you won\'t be charged twice.'**
  String get purchaseVerificationPendingBody;

  /// Toast title shown when the backend permanently rejects a store transaction.
  ///
  /// In en, this message translates to:
  /// **'Purchase not applied'**
  String get purchaseNotAppliedTitle;

  /// Toast body telling a charged user that a rejected purchase needs support and must not be bought again.
  ///
  /// In en, this message translates to:
  /// **'Your purchase could not be applied to your account. Contact support, and do not buy it again.'**
  String get purchaseNotAppliedBody;

  /// Toast title shown when the store's restore request throws.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get purchaseRestoreFailedTitle;

  /// Toast body shown when restoring past purchases fails.
  ///
  /// In en, this message translates to:
  /// **'Could not restore purchases. Try again.'**
  String get purchaseRestoreFailedBody;

  /// Toast body shown when a purchase recovered in the background activates the subscription with no paywall open.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active.'**
  String get purchaseRecoveredActiveBody;

  /// Toast title shown when a purchase recovered in the background finishes outside the paywall.
  ///
  /// In en, this message translates to:
  /// **'Purchase complete'**
  String get purchaseCompleteTitle;

  /// Toast title shown when sending a free gift invitation fails.
  ///
  /// In en, this message translates to:
  /// **'Could not create the gift'**
  String get giftCreateFailedTitle;

  /// Toast title shown when claiming an incoming gift fails.
  ///
  /// In en, this message translates to:
  /// **'Could not claim the gift'**
  String get giftClaimFailedTitle;

  /// Heading over the list of incoming gifts, counting how many gifts the signed-in user has waiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{A gift for you} other{{count} gifts for you}}'**
  String giftIncomingCount(int count);

  /// Length of a gift as a duration phrase, used on allowance chips, gift cards and the share message. Selects on the month count: 1 month, 12 months reads as 1 year, anything else is a month count.
  ///
  /// In en, this message translates to:
  /// **'{months, select, 1{1 month} 12{1 year} other{{months} months}}'**
  String giftDurationTerm(String months);

  /// Choice chip for a gift allowance, naming the duration plus how many invitations are left.
  ///
  /// In en, this message translates to:
  /// **'{duration}, {remaining, plural, =1{1 left} other{{remaining} left}}'**
  String giftAllowanceChip(String duration, int remaining);

  /// Line on an incoming gift card naming how much FitCheck Pro the gift gives.
  ///
  /// In en, this message translates to:
  /// **'{duration} of FitCheck Pro'**
  String giftDurationOfPro(String duration);

  /// Body of the share sheet after creating a gift, naming the sender, the duration and the claim link.
  ///
  /// In en, this message translates to:
  /// **'{sender} sent you {duration} of FitCheck Pro. {link}'**
  String giftShareMessage(String sender, String duration, String link);

  /// Subject line of the share sheet after creating a gift, naming the recipient.
  ///
  /// In en, this message translates to:
  /// **'A FitCheck Pro gift for {recipient}'**
  String giftShareSubject(String recipient);

  /// Line on an incoming gift card naming the person who sent it.
  ///
  /// In en, this message translates to:
  /// **'From {sender}'**
  String giftFromSender(String sender);

  /// Live card preview line naming who the gift is addressed to.
  ///
  /// In en, this message translates to:
  /// **'For {recipient}'**
  String giftPreviewFor(String recipient);

  /// Live card preview line naming who the gift is from.
  ///
  /// In en, this message translates to:
  /// **'From {sender}'**
  String giftPreviewFrom(String sender);

  /// Stand-in recipient name on the live card preview while the recipient field is still empty.
  ///
  /// In en, this message translates to:
  /// **'your recipient'**
  String get giftPreviewPlaceholderRecipient;

  /// Stand-in sender name on the live card preview while the sender field is still empty.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get giftPreviewPlaceholderSender;

  /// Toast title confirming that a preference change was stored.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get settingsSavedTitle;

  /// Toast title shown when a settings change could not be stored.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get settingsNotSavedTitle;

  /// Validation toast shown when the user saves AI settings without picking a provider.
  ///
  /// In en, this message translates to:
  /// **'Choose a provider.'**
  String get settingsAiChooseProviderBody;

  /// Validation toast shown when a custom AI provider is saved without an API URL.
  ///
  /// In en, this message translates to:
  /// **'A custom provider needs an API URL.'**
  String get settingsAiCustomUrlRequiredBody;

  /// Validation toast shown when no API key was typed and none is stored for the AI provider.
  ///
  /// In en, this message translates to:
  /// **'Enter an API key.'**
  String get settingsAiKeyRequiredBody;

  /// Toast body confirming the user's AI provider settings were saved.
  ///
  /// In en, this message translates to:
  /// **'Your AI settings are saved.'**
  String get settingsAiSavedBody;

  /// Toast title shown when the AI connection test is started without a URL or model.
  ///
  /// In en, this message translates to:
  /// **'Missing details'**
  String get settingsAiMissingDetailsTitle;

  /// Toast body asking the user for the URL and chat model needed to test an AI provider.
  ///
  /// In en, this message translates to:
  /// **'Enter an API URL and a chat model to test.'**
  String get settingsAiUrlAndModelRequiredBody;

  /// Toast title shown when the AI connection test runs without an API key.
  ///
  /// In en, this message translates to:
  /// **'API key needed'**
  String get settingsAiKeyNeededTitle;

  /// Toast body asking for the API key again for a test, reassuring that the stored key is not exposed.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key to test. Your saved key stays private.'**
  String get settingsAiKeyToTestPrivateBody;

  /// Toast body asking the user to type their API key before running the AI connection test.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key to test.'**
  String get settingsAiKeyToTestBody;

  /// Toast title shown when the AI provider connection test succeeds.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get settingsAiConnectedTitle;

  /// Toast body confirming the tested AI provider answered correctly.
  ///
  /// In en, this message translates to:
  /// **'The connection works.'**
  String get settingsAiConnectedBody;

  /// Toast title shown when the AI provider connection test fails.
  ///
  /// In en, this message translates to:
  /// **'Test failed'**
  String get settingsAiTestFailedTitle;

  /// Toast body confirming the user's app preferences were saved to the backend.
  ///
  /// In en, this message translates to:
  /// **'Your preferences are saved.'**
  String get settingsPreferencesSavedBody;

  /// Toast title shown whenever the password change is refused or fails.
  ///
  /// In en, this message translates to:
  /// **'Password not changed'**
  String get settingsPasswordNotChangedTitle;

  /// Toast body shown to a Google or Apple sign-in user who tries to change a password they do not have.
  ///
  /// In en, this message translates to:
  /// **'This account signs in with Google or Apple. Use \"Forgot password\" to set a password first.'**
  String get settingsOAuthPasswordBody;

  /// Toast body shown when re-authentication with the typed current password is rejected.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get settingsCurrentPasswordIncorrectBody;

  /// Toast title shown when the user's data export download opens.
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get settingsExportReadyTitle;

  /// Toast body telling the user their data export file was opened in the browser.
  ///
  /// In en, this message translates to:
  /// **'Your data export is ready to download.'**
  String get settingsExportReadyBody;

  /// Toast title shown when a download link is copied to the clipboard instead of opened.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get settingsLinkCopiedTitle;

  /// LEGAL: Toast body telling the user their data-export download link was copied instead of opened and expires soon.
  ///
  /// In en, this message translates to:
  /// **'We could not open your browser, so we copied the download link. Paste it into a browser soon: it expires.'**
  String get settingsExportClipboardBody;

  /// Toast title shown when the data export request fails.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get settingsExportFailedTitle;

  /// LEGAL: Toast title telling the user their account-deletion request did not go through and the account still exists.
  ///
  /// In en, this message translates to:
  /// **'Account not deleted'**
  String get settingsAccountNotDeletedTitle;

  /// Validation toast when the user has already picked the maximum number of photos and tries to add more.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} photos.'**
  String photoshootPhotoLimit(int max);

  /// Bold heading of the message shown when the user already holds the maximum number of photos.
  ///
  /// In en, this message translates to:
  /// **'Photo limit'**
  String get photoshootPhotoLimitTitle;

  /// Validation toast when the user taps Continue on the setup step without any photo.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo.'**
  String get photoshootAddAtLeastOnePhoto;

  /// Bold heading of the message shown when the user tries to continue the photoshoot with no photo chosen.
  ///
  /// In en, this message translates to:
  /// **'No photos'**
  String get photoshootNoPhotosSelectedTitle;

  /// Validation toast when the user picked the custom-prompt style but left the prompt empty.
  ///
  /// In en, this message translates to:
  /// **'Describe the look you want.'**
  String get photoshootDescribeLookBody;

  /// Bold heading of the message shown when the custom photoshoot prompt is left empty.
  ///
  /// In en, this message translates to:
  /// **'Prompt needed'**
  String get photoshootPromptNeededTitle;

  /// Name of the AI features the photoshoot uses; printed in the third-party consent sheet the first time a user starts a shoot.
  ///
  /// In en, this message translates to:
  /// **'AI Photoshoot'**
  String get photoshootConsentFeatureLabel;

  /// Progress line under the bar while the chosen photos are uploaded before generation starts.
  ///
  /// In en, this message translates to:
  /// **'Preparing your photos'**
  String get photoshootStatusPreparing;

  /// Progress line under the bar once the server accepted the shoot and starts making images.
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get photoshootStatusGenerating;

  /// Progress line that counts which generation batch of the shoot is running.
  ///
  /// In en, this message translates to:
  /// **'Batch {current} of {total}'**
  String photoshootStatusBatch(int current, int total);

  /// Progress line counting how many studio images of the shoot are finished.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String photoshootStatusImagesDone(int done, int total);

  /// Banner body on the setup step when the photoshoot job failed without a server message.
  ///
  /// In en, this message translates to:
  /// **'Generation failed.'**
  String get photoshootGenerationFailedBody;

  /// Toast body when a shoot finishes with some images generated and some failed.
  ///
  /// In en, this message translates to:
  /// **'{ready} ready, {failed} failed.'**
  String photoshootPartlyDoneBody(int ready, int failed);

  /// Bold heading of the message shown when a shoot ends with some images missing.
  ///
  /// In en, this message translates to:
  /// **'Partly done'**
  String get photoshootPartlyDoneTitle;

  /// Toast body when every requested studio image was generated successfully.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo is ready.} other{{count} photos are ready.}}'**
  String photoshootPhotosReady(int count);

  /// Banner body on the setup step when polling the shoot status kept failing.
  ///
  /// In en, this message translates to:
  /// **'We lost the connection. Please try again.'**
  String get photoshootConnectionLostBody;

  /// Toast title when the server refused to cancel the running shoot.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel'**
  String get photoshootCouldNotCancelTitle;

  /// Toast title when regenerating one failed image slot did not work.
  ///
  /// In en, this message translates to:
  /// **'Retry failed'**
  String get photoshootRetryFailedTitle;

  /// Toast body after a failed image slot was regenerated successfully.
  ///
  /// In en, this message translates to:
  /// **'Photo {number} is ready.'**
  String photoshootPhotoReplacedBody(int number);

  /// Toast title for the regenerated image slot.
  ///
  /// In en, this message translates to:
  /// **'Replaced'**
  String get photoshootReplacedTitle;

  /// Toast body after one studio image was written to the device photo library.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery.'**
  String get photoshootSavedToGalleryBody;

  /// Success toast title used for photoshoot saves.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get photoshootSavedTitle;

  /// Error toast title when a studio image could not be written to the gallery.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get photoshootNotSavedTitle;

  /// Toast body after saving every studio image of the shoot in one go.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo is in your gallery.} other{All {count} photos are in your gallery.}}'**
  String photoshootAllSavedBody(int count);

  /// Start of the toast body when saving all images partly failed; the error reason is appended after it.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {total} saved.'**
  String photoshootSomeSavedBody(int saved, int total);

  /// Error toast title when only some studio images reached the gallery.
  ///
  /// In en, this message translates to:
  /// **'Some photos not saved'**
  String get photoshootSomePhotosNotSavedTitle;

  /// Name of the AI feature printed in the third-party consent sheet shown before the first virtual try-on.
  ///
  /// In en, this message translates to:
  /// **'Virtual Try-On'**
  String get tryonConsentFeatureLabel;

  /// Toast body after the user's try-on avatar photo finished uploading.
  ///
  /// In en, this message translates to:
  /// **'Your photo is updated.'**
  String get tryonAvatarUpdatedBody;

  /// Success toast title used for try-on saves.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get tryonSavedTitle;

  /// Error toast title when the avatar photo upload failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get tryonUploadFailedTitle;

  /// Validation toast when the user taps Create try-on without a garment photo.
  ///
  /// In en, this message translates to:
  /// **'Choose a garment photo first.'**
  String get tryonChooseGarmentFirstBody;

  /// Bold heading of the message shown when Create try-on is tapped with no garment photo.
  ///
  /// In en, this message translates to:
  /// **'No garment'**
  String get tryonNoGarmentTitle;

  /// Validation toast when the user creates a try-on while their own photo is still uploading.
  ///
  /// In en, this message translates to:
  /// **'Wait for your photo to finish uploading.'**
  String get tryonWaitForUploadBody;

  /// Bold heading of the message shown when a try-on starts while the avatar upload is still running.
  ///
  /// In en, this message translates to:
  /// **'Still uploading'**
  String get tryonStillUploadingTitle;

  /// Validation toast when the user creates a try-on without an avatar photo.
  ///
  /// In en, this message translates to:
  /// **'Add a photo of yourself first.'**
  String get tryonAddYourPhotoFirstBody;

  /// Toast body when the try-on image was generated successfully.
  ///
  /// In en, this message translates to:
  /// **'Your try-on is ready.'**
  String get tryonReadyBody;

  /// Error toast title when the try-on image could not be generated.
  ///
  /// In en, this message translates to:
  /// **'Try-on failed'**
  String get tryonFailedTitle;

  /// Toast body after a try-on image was written to the device photo library.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery.'**
  String get tryonSavedToGalleryBody;

  /// Error toast title when a try-on image could not be written to the gallery.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get tryonNotSavedTitle;

  /// Toast body after a new calendar event was created.
  ///
  /// In en, this message translates to:
  /// **'Event added'**
  String get calendarEventAddedBody;

  /// Success toast title for a newly created calendar event.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get calendarEventPlannedTitle;

  /// Toast body after edits to a calendar event were stored.
  ///
  /// In en, this message translates to:
  /// **'Event saved'**
  String get calendarEventSavedBody;

  /// Success toast title used when a calendar event is stored.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get calendarSavedTitle;

  /// Error toast title when creating or editing a calendar event failed.
  ///
  /// In en, this message translates to:
  /// **'Event not saved'**
  String get calendarEventNotSavedTitle;

  /// Toast body after a calendar event was deleted.
  ///
  /// In en, this message translates to:
  /// **'Event removed'**
  String get calendarEventRemovedBody;

  /// Success toast title for a deleted calendar event.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get calendarEventDeletedTitle;

  /// Error toast title when deleting a calendar event failed.
  ///
  /// In en, this message translates to:
  /// **'Event not deleted'**
  String get calendarEventNotDeletedTitle;

  /// Error toast title when an outfit could not be linked to a calendar event.
  ///
  /// In en, this message translates to:
  /// **'Outfit not linked'**
  String get calendarOutfitNotLinkedTitle;

  /// Success toast title after an outfit was linked to a calendar event.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get calendarLinkedTitle;

  /// Error toast title when the outfit linked to an event could not be removed.
  ///
  /// In en, this message translates to:
  /// **'Outfit not removed'**
  String get calendarOutfitNotRemovedTitle;

  /// Toast body after the outfit was unlinked from a calendar event.
  ///
  /// In en, this message translates to:
  /// **'Outfit removed'**
  String get calendarOutfitRemovedBody;

  /// Toast body after a connected external calendar was disconnected.
  ///
  /// In en, this message translates to:
  /// **'Calendar disconnected'**
  String get calendarDisconnectedBody;

  /// Success toast title for a disconnected external calendar.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get calendarDisconnectedTitle;

  /// Error toast title when disconnecting an external calendar failed.
  ///
  /// In en, this message translates to:
  /// **'Calendar not disconnected'**
  String get calendarNotDisconnectedTitle;

  /// Spoken as part of a day cell's screen-reader label when that day is today; lower case because it is read mid-list.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get calendarTodayLabel;

  /// Spoken as part of a day cell's screen-reader label to say how many events that day holds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event} other{{count} events}}'**
  String calendarEventCount(int count);

  /// Time span of a timed event, read inside the event row's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String calendarTimeRange(String start, String end);

  /// Screen-reader label of an event row that has no outfit linked.
  ///
  /// In en, this message translates to:
  /// **'{title}, {time}'**
  String calendarEventSemantic(String title, String time);

  /// Screen-reader label of an event row that has an outfit linked.
  ///
  /// In en, this message translates to:
  /// **'{title}, {time}, outfit linked'**
  String calendarEventSemanticWithOutfit(String title, String time);

  /// Body of the confirmation dialog before deleting one calendar event.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed.'**
  String calendarDeleteEventBody(String title);

  /// Name shown for events that live only inside FitCheck, next to the external calendar names.
  ///
  /// In en, this message translates to:
  /// **'This app'**
  String get calendarThisAppLabel;

  /// Toast body when the user taps a calendar provider that is not supported yet; the provider name is filled in.
  ///
  /// In en, this message translates to:
  /// **'Syncing with {provider} is not available yet. You can still add events here.'**
  String calendarSyncUnavailableBody(String provider);

  /// Abbreviated Sunday in the weekday header of the month grid.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get calendarWeekdaySunShort;

  /// Abbreviated Monday in the weekday header of the month grid.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get calendarWeekdayMonShort;

  /// Abbreviated Tuesday in the weekday header of the month grid.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get calendarWeekdayTueShort;

  /// Abbreviated Wednesday in the weekday header of the month grid.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get calendarWeekdayWedShort;

  /// Abbreviated Thursday in the weekday header of the month grid.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get calendarWeekdayThuShort;

  /// Abbreviated Friday in the weekday header of the month grid.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get calendarWeekdayFriShort;

  /// Abbreviated Saturday in the weekday header of the month grid.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get calendarWeekdaySatShort;

  /// Full Monday, read at the start of a day cell's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get calendarWeekdayMonday;

  /// Full Tuesday, read at the start of a day cell's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get calendarWeekdayTuesday;

  /// Full Wednesday, read at the start of a day cell's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get calendarWeekdayWednesday;

  /// Full Thursday, read at the start of a day cell's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get calendarWeekdayThursday;

  /// Full Friday, read at the start of a day cell's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get calendarWeekdayFriday;

  /// Full Saturday, read at the start of a day cell's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get calendarWeekdaySaturday;

  /// Full Sunday, read at the start of a day cell's screen-reader label.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get calendarWeekdaySunday;

  /// Toast body shown after an outfit is added to favourites from the outfit list.
  ///
  /// In en, this message translates to:
  /// **'Saved to favourites'**
  String get outfitSavedToFavouritesBody;

  /// Toast body shown after an outfit is taken out of favourites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites'**
  String get outfitRemovedFromFavouritesBody;

  /// Error toast title for any failed outfit save, favourite toggle or edit.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get outfitNotSavedTitle;

  /// Toast body after the user marks an outfit as worn today.
  ///
  /// In en, this message translates to:
  /// **'Logged as worn today.'**
  String get outfitLoggedAsWornBody;

  /// Success toast title shown with the worn-today confirmation.
  ///
  /// In en, this message translates to:
  /// **'Nice pick'**
  String get outfitNicePickTitle;

  /// Toast body after an outfit was deleted from the list.
  ///
  /// In en, this message translates to:
  /// **'Outfit removed.'**
  String get outfitRemovedBody;

  /// Success toast title for a deleted outfit.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get outfitDeletedTitle;

  /// Error toast title when deleting an outfit failed.
  ///
  /// In en, this message translates to:
  /// **'Not deleted'**
  String get outfitNotDeletedTitle;

  /// Toast body after the user duplicates an outfit.
  ///
  /// In en, this message translates to:
  /// **'A copy is in your outfits.'**
  String get outfitDuplicatedBody;

  /// Success toast title for a duplicated outfit.
  ///
  /// In en, this message translates to:
  /// **'Duplicated'**
  String get outfitDuplicatedTitle;

  /// Error toast title when duplicating an outfit failed.
  ///
  /// In en, this message translates to:
  /// **'Not duplicated'**
  String get outfitNotDuplicatedTitle;

  /// Error toast title when creating a public link for an outfit failed.
  ///
  /// In en, this message translates to:
  /// **'Not shared'**
  String get outfitNotSharedTitle;

  /// Toast body after a new outfit collection was created; the collection name is filled in.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is ready.'**
  String outfitCollectionReadyBody(String name);

  /// Error toast title when creating an outfit collection failed.
  ///
  /// In en, this message translates to:
  /// **'Collection not created'**
  String get outfitCollectionNotCreatedTitle;

  /// Toast body after a collection was renamed or its description changed.
  ///
  /// In en, this message translates to:
  /// **'Collection updated.'**
  String get outfitCollectionUpdatedBody;

  /// Error toast title when renaming or editing a collection failed.
  ///
  /// In en, this message translates to:
  /// **'Collection not updated'**
  String get outfitCollectionNotUpdatedTitle;

  /// Toast body after a collection was deleted.
  ///
  /// In en, this message translates to:
  /// **'Collection deleted.'**
  String get outfitCollectionDeletedBody;

  /// Error toast title when deleting a collection failed.
  ///
  /// In en, this message translates to:
  /// **'Collection not deleted'**
  String get outfitCollectionNotDeletedTitle;

  /// Toast body after outfits were dropped into a collection from the add picker.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 outfit added.} other{{count} outfits added.}}'**
  String outfitAddedToCollection(int count);

  /// Error toast title when adding outfits to a collection failed.
  ///
  /// In en, this message translates to:
  /// **'Outfits not added'**
  String get outfitNotAddedToCollectionTitle;

  /// Error toast title when the AI outfit preview could not be generated.
  ///
  /// In en, this message translates to:
  /// **'Preview not created'**
  String get outfitPreviewNotCreatedTitle;

  /// Validation toast when the user saves a new outfit without a name.
  ///
  /// In en, this message translates to:
  /// **'Give the outfit a name.'**
  String get outfitGiveNameBody;

  /// Bold heading of the message shown when a new outfit is saved without a name, above the line asking for one.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get outfitNameMissingTitle;

  /// Validation toast when the user saves a new outfit with no pieces.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one piece.'**
  String get outfitChooseAtLeastOnePieceBody;

  /// Toast body after a new outfit is saved; the outfit name is filled in.
  ///
  /// In en, this message translates to:
  /// **'{name} is in your outfits.'**
  String outfitCreatedBody(String name);

  /// Success toast title for a newly saved outfit.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get outfitSavedTitle;

  /// Toast body after a closet piece is added to favourites.
  ///
  /// In en, this message translates to:
  /// **'Added to favourites'**
  String get wardrobeAddedToFavouritesBody;

  /// Toast body after a closet piece is taken out of favourites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favourites'**
  String get wardrobeRemovedFromFavouritesBody;

  /// Error toast title for a failed favourite toggle or worn-today log on a closet piece.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get wardrobeNotSavedTitle;

  /// Toast body after the user marks a closet piece as worn today.
  ///
  /// In en, this message translates to:
  /// **'Logged as worn today.'**
  String get wardrobeLoggedAsWornBody;

  /// Toast body after one piece was deleted from the closet.
  ///
  /// In en, this message translates to:
  /// **'Removed from your closet.'**
  String get wardrobeRemovedFromClosetBody;

  /// Success toast title for deleted closet pieces.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get wardrobeDeletedTitle;

  /// Error toast title when deleting closet pieces failed.
  ///
  /// In en, this message translates to:
  /// **'Not deleted'**
  String get wardrobeNotDeletedTitle;

  /// Toast body after a multi-select delete in the closet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 piece removed from your closet.} other{{count} pieces removed from your closet.}}'**
  String wardrobePiecesRemovedBody(int count);

  /// Name of the AI feature printed in the third-party consent sheet before a photo is analysed.
  ///
  /// In en, this message translates to:
  /// **'AI Wardrobe Extraction'**
  String get wardrobeAiConsentLabel;

  /// Short name of a running single-photo scan, shown in the active-scan banner and the activity list.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get itemAddScanJobLabel;

  /// Status line when the scanned photo was already analysed before, so the earlier result is reused.
  ///
  /// In en, this message translates to:
  /// **'Found in an earlier scan'**
  String get itemAddFoundEarlierBody;

  /// Status line while the AI inspects the uploaded photo for clothing.
  ///
  /// In en, this message translates to:
  /// **'Looking at your photo'**
  String get itemAddLookingAtPhoto;

  /// Generic failure message on the add-piece screen when the scan stopped without a server reason.
  ///
  /// In en, this message translates to:
  /// **'Extraction failed'**
  String get itemAddExtractionFailedBody;

  /// Failure message on the add-piece screen when the scan job reported a failure with no detail.
  ///
  /// In en, this message translates to:
  /// **'Job failed'**
  String get itemAddJobFailedBody;

  /// Failure message on the add-piece screen when status polling kept failing.
  ///
  /// In en, this message translates to:
  /// **'Connection was lost. Try again.'**
  String get itemAddConnectionLostBody;

  /// Failure message on the add-piece screen when polling timed out while the scan was still running.
  ///
  /// In en, this message translates to:
  /// **'Connection lost while processing.'**
  String get itemAddConnectionLostProcessingBody;

  /// Caption naming the piece whose studio photo is being made, numbered by its place in the scan.
  ///
  /// In en, this message translates to:
  /// **'Piece {number}'**
  String itemAddGeneratingPiece(int number);

  /// Caption for the piece being rendered when its position is not known yet.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get itemAddGeneratingPieceFallback;

  /// Error toast title when the server could not cancel the running scan.
  ///
  /// In en, this message translates to:
  /// **'Not cancelled'**
  String get itemAddNotCancelledTitle;

  /// Toast body after the reviewed pieces of one photo were saved to the closet.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 piece is in your closet.} other{{count} pieces are in your closet.}}'**
  String itemAddPiecesSavedBody(int count);

  /// Warning toast body when some pieces could not be saved in a scan result.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {total} pieces saved. Tap save to try the rest again.'**
  String itemAddSomeSavedBody(int saved, int total);

  /// Warning toast title shown when only part of the reviewed pieces were stored.
  ///
  /// In en, this message translates to:
  /// **'Some pieces not saved'**
  String get itemAddSomePiecesNotSavedTitle;

  /// Inline error on the batch screen when the user starts the scan with no photo selected.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one photo.'**
  String get batchChooseAtLeastOnePhotoBody;

  /// Per-photo error in the batch grid when one file could not be prepared for upload.
  ///
  /// In en, this message translates to:
  /// **'This photo could not be read.'**
  String get batchPhotoUnreadableBody;

  /// Inline error when every selected photo failed to load, so no job was started.
  ///
  /// In en, this message translates to:
  /// **'None of these photos could be read. Try other photos.'**
  String get batchNoPhotosReadableBody;

  /// Name of the running batch job in the active-scan banner and activity list.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String batchJobLabelPhotos(int count);

  /// Inline error when polling the batch job kept failing until the retry limit.
  ///
  /// In en, this message translates to:
  /// **'We lost the connection while working. Try again.'**
  String get batchConnectionLostWorkingBody;

  /// Error toast title when the server could not cancel the batch scan.
  ///
  /// In en, this message translates to:
  /// **'Not cancelled'**
  String get batchNotCancelledTitle;

  /// Field error under the profile link input when the user pasted a link to a single post.
  ///
  /// In en, this message translates to:
  /// **'Post links are not supported. Enter a profile link.'**
  String get batchPostLinkUnsupportedBody;

  /// Field error under the profile link input when the pasted link contains a space.
  ///
  /// In en, this message translates to:
  /// **'Links cannot contain spaces.'**
  String get batchLinkSpacesBody;

  /// Field error under the profile link input when the pasted URL is from an unsupported site.
  ///
  /// In en, this message translates to:
  /// **'Enter an Instagram or Facebook profile link.'**
  String get batchEnterProfileLinkBody;

  /// Inline error when the user starts a profile import with an empty link field.
  ///
  /// In en, this message translates to:
  /// **'Enter a profile link.'**
  String get batchEnterProfileLinkShortBody;

  /// Inline error when the browser could not be opened for the social sign-in step.
  ///
  /// In en, this message translates to:
  /// **'The sign-in page did not open. Try again.'**
  String get batchSignInPageNotOpenBody;

  /// Toast body telling the user to complete the sign-in in their browser and return.
  ///
  /// In en, this message translates to:
  /// **'Sign in in your browser, then come back to FitCheck.'**
  String get batchSignInBrowserBody;

  /// Toast title for the social sign-in instructions.
  ///
  /// In en, this message translates to:
  /// **'Connect your account'**
  String get batchConnectAccountTitle;

  /// Inline error on the profile import sign-in step when the platform asks for a 2FA code.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your authenticator app.'**
  String get batchEnterAuthenticatorCodeBody;

  /// Inline error on the import sign-in step when Instagram blocks the login with a security checkpoint.
  ///
  /// In en, this message translates to:
  /// **'Instagram wants a security check. Sign in in your browser first.'**
  String get batchInstagramSecurityCheckBody;

  /// Inline error when the two-step code was submitted after the held credentials were dropped.
  ///
  /// In en, this message translates to:
  /// **'Enter your username and password again.'**
  String get batchEnterCredentialsAgainBody;

  /// Inline error on the import sign-in step when the platform rejected the credentials.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Check your username and password.'**
  String get batchSignInFailedBody;

  /// Inline error on the import screen when the platform asked for a sign-in without a known reason.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep importing.'**
  String get batchSignInToKeepImportingBody;

  /// Fallback message after returning from the browser sign-in without a server-supplied reason.
  ///
  /// In en, this message translates to:
  /// **'Your account was not connected.'**
  String get batchAccountNotConnectedBody;

  /// Toast title after the social account was linked and the import continues.
  ///
  /// In en, this message translates to:
  /// **'Account connected'**
  String get batchAccountConnectedTitle;

  /// Toast title when the social account sign-in did not complete.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get batchNotConnectedTitle;

  /// Inline error on the import progress screen when status polling kept failing.
  ///
  /// In en, this message translates to:
  /// **'We lost the connection to the import. Refresh to check it.'**
  String get batchImportConnectionLostBody;

  /// Empty-state message on the batch screen before any photo is chosen.
  ///
  /// In en, this message translates to:
  /// **'Pick up to {max} photos. We find the pieces.'**
  String batchPickUpToBody(int max);

  /// Counter above the photo grid showing how many of the allowed photos are selected.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} photos'**
  String batchPhotoCounter(int count, int total);

  /// Label on the scan button while the selected photos are being prepared for upload.
  ///
  /// In en, this message translates to:
  /// **'Preparing photo {done} of {count}'**
  String batchPreparingPhotoBody(int done, int count);

  /// Label on the button that starts the scan for the selected photos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Find pieces in 1 photo} other{Find pieces in {count} photos}}'**
  String batchFindPiecesInPhotos(int count);

  /// Explanation on the import sign-in step when the platform asked for a 2FA code.
  ///
  /// In en, this message translates to:
  /// **'Your {platform} account uses two-step sign-in. Enter the 6-digit code from your authenticator app.'**
  String batchTwoStepSignInBody(String platform);

  /// Explanation on the import sign-in step when the pasted profile needs a login.
  ///
  /// In en, this message translates to:
  /// **'This {platform} profile is private or needs a sign-in to show its photos.'**
  String batchPrivateProfileBody(String platform);

  /// Button on the import sign-in step that opens the platform's sign-in page.
  ///
  /// In en, this message translates to:
  /// **'Connect with {platform}'**
  String batchConnectWithPlatform(String platform);

  /// Running count of photos discovered on the pasted profile.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo found so far} other{{count} photos found so far}}'**
  String batchPhotosFoundSoFar(int count);

  /// Status line under the import progress bar, counting processed, kept, queued and rejected photos.
  ///
  /// In en, this message translates to:
  /// **'{processed} of {total} processed · {added} added · {waiting} waiting · {skipped} skipped'**
  String batchImportStatusLine(
    int processed,
    int total,
    int added,
    int waiting,
    int skipped,
  );

  /// Status line while one imported photo is being scanned for pieces.
  ///
  /// In en, this message translates to:
  /// **'Scanning photo {number}'**
  String batchScanningPhoto(int number);

  /// Status line naming the imported photo that is waiting to be scanned.
  ///
  /// In en, this message translates to:
  /// **'Photo {number} is next'**
  String batchPhotoIsNext(int number);

  /// Heading of the review card for one imported photo.
  ///
  /// In en, this message translates to:
  /// **'Photo {number}'**
  String batchPhotoLabel(int number);

  /// Line under the photo heading saying what the scan found in that photo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 piece found} other{{count} pieces found}}'**
  String batchPiecesFound(int count);

  /// End screen of a finished profile import, saying how many photos were kept.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo was added to your closet.} other{{count} photos were added to your closet.}}'**
  String batchPhotosAddedBody(int count);

  /// Banner on the review screen while studio photos are still being made.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more studio photo on the way. You can save what is ready, or leave — we will let you know.} other{{count} more studio photos on the way. You can save what is ready, or leave — we will let you know.}}'**
  String batchMoreStudioPhotosBody(int count);

  /// Error banner listing the pieces whose save failed; the names are joined by commas.
  ///
  /// In en, this message translates to:
  /// **'Not saved yet: {names}.'**
  String batchNotSavedYetBody(String names);

  /// Summary heading of the review screen, counting detected pieces and the photos they came from.
  ///
  /// In en, this message translates to:
  /// **'{pieces, plural, =1{1 piece} other{{pieces} pieces}} from {photos, plural, =1{1 photo} other{{photos} photos}}'**
  String batchPiecesFromPhotos(int pieces, int photos);

  /// Hint under the review summary saying how many pieces are selected.
  ///
  /// In en, this message translates to:
  /// **'{chosen} chosen. Tap a piece to skip it.'**
  String batchSelectedChosen(int chosen);

  /// Save button label while the selected pieces are being stored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saving 1 piece} other{Saving {count} pieces}}'**
  String batchSavingPiecesLabel(int count);

  /// Save button label on the review screen with the number of selected pieces.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save 1 piece} other{Save {count} pieces}}'**
  String batchSavePiecesLabel(int count);

  /// Toast body after a new body profile with measurements was created.
  ///
  /// In en, this message translates to:
  /// **'Your body profile is saved.'**
  String get bodyProfileSavedBody;

  /// Success toast title for body profile changes.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get bodyProfileSavedTitle;

  /// Error toast title when a body profile change failed.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get bodyProfileNotSavedTitle;

  /// Toast body after one body profile was made the default for fit and try-on.
  ///
  /// In en, this message translates to:
  /// **'Set as your default profile.'**
  String get bodyProfileSetDefaultBody;

  /// Toast body after a body profile was deleted.
  ///
  /// In en, this message translates to:
  /// **'Body profile deleted.'**
  String get bodyProfileDeletedBody;

  /// Success toast title for a deleted body profile.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get bodyProfileDeletedTitle;

  /// Error toast title when deleting a body profile failed.
  ///
  /// In en, this message translates to:
  /// **'Not deleted'**
  String get bodyProfileNotDeletedTitle;

  /// Error toast title when sending a feedback ticket failed.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get feedbackNotSentTitle;

  /// Toast body after the user's feedback was submitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks. We read every message and reply if we need more.'**
  String get feedbackSentBody;

  /// Success toast title for a submitted feedback ticket.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent'**
  String get feedbackSentTitle;

  /// Placeholder name for a matched closet piece the server returned without a name.
  ///
  /// In en, this message translates to:
  /// **'Unnamed piece'**
  String get recommendUnnamedPiece;

  /// Validation toast when the user asks for weather picks with an empty city.
  ///
  /// In en, this message translates to:
  /// **'Enter your city to get picks for the weather.'**
  String get recommendEnterCityBody;

  /// Bold heading of the message asking for a city before the weather picks can load.
  ///
  /// In en, this message translates to:
  /// **'Which city?'**
  String get recommendWhichCityTitle;

  /// LEGAL: Title of the consent sheet shown before a photo is sent to a third-party AI provider. App Review and GDPR both require this to be understood, not merely present.
  ///
  /// In en, this message translates to:
  /// **'Sharing photos with an AI service'**
  String get aiConsentSheetTitle;

  /// LEGAL: Body of the AI photo-sharing consent sheet. Names the data category (face and body images), the recipient class (third-party AI provider), and the no-training / no-advertising guarantee. Translate faithfully; do not soften or shorten.
  ///
  /// In en, this message translates to:
  /// **'To create your try-on and photoshoot images, FitCheck AI sends the photos you provide (including images of your face and body) to a trusted third-party AI provider (such as OpenAI or Google Gemini) for processing. They generate your images and do not use them to train their models under our terms. Photos are transmitted securely and never shared for advertising.'**
  String get aiConsentSheetBody;

  /// LEGAL: Consent grant sentence above the agree button. Must read as an explicit permission, not a notice.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you give explicit permission to share your photos with these AI providers for image generation.'**
  String get aiConsentSheetPermission;

  /// Inline error inside a paginated list when the next page failed to load. Shown next to a Retry button.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more.'**
  String get skeletonsLoadMoreFailed;

  /// Toast title when a background extraction job finished and the detected pieces can be reviewed.
  ///
  /// In en, this message translates to:
  /// **'Your pieces are ready'**
  String get jobsPiecesReadyTitle;

  /// Toast title when a background extraction job ended before finishing.
  ///
  /// In en, this message translates to:
  /// **'The scan stopped'**
  String get jobsScanStoppedTitle;

  /// Toast body when a background job produced no items.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved. Try again.'**
  String get jobsNothingSavedBody;

  /// Toast body when uploading a wardrobe photo failed.
  ///
  /// In en, this message translates to:
  /// **'Photo upload failed.'**
  String get jobsPhotoUploadFailedBody;

  /// Error shown when the Google sign-in flow could not be launched on the device.
  ///
  /// In en, this message translates to:
  /// **'Unable to start Google Sign-In. Please try again.'**
  String get authGoogleSignInStartFailed;

  /// Toast title after a referral code was accepted.
  ///
  /// In en, this message translates to:
  /// **'Referral Applied!'**
  String get referralAppliedTitle;

  /// Error when In-App Purchase is unavailable, e.g. a sideloaded build or a device without a store account.
  ///
  /// In en, this message translates to:
  /// **'Store purchases are not available on this device.'**
  String get billingStoreUnavailableBody;

  /// Error when a purchase was made but the receipt has not been confirmed yet.
  ///
  /// In en, this message translates to:
  /// **'This purchase is still being processed. Reopen the app in a minute to see your plan.'**
  String get billingPurchaseProcessingBody;

  /// Error when the server accepted an avatar upload but returned no URL.
  ///
  /// In en, this message translates to:
  /// **'Avatar upload did not return an image URL.'**
  String get profileAvatarUploadNoUrl;

  /// Caption under the current streak count on the rewards screen.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get rewardsDayStreakLabel;

  /// Caption showing the user's longest streak. {days} is a number of days.
  ///
  /// In en, this message translates to:
  /// **'Best {days} days'**
  String rewardsBestStreak(int days);

  /// Dialog title explaining a permission was denied. {permission} is a localized permission name such as Photos or Camera.
  ///
  /// In en, this message translates to:
  /// **'{permission} Access Needed'**
  String permissionAccessNeededTitle(String permission);

  /// Dialog body explaining how to recover from a denied permission. {permission} is a localized permission name.
  ///
  /// In en, this message translates to:
  /// **'Access to {permission} is currently denied. Open Settings to allow it, then come back and try again.'**
  String permissionAccessDeniedBody(String permission);

  /// Progress label at the top of the photoshoot wizard. {step} is 1-based.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 4'**
  String photoshootStepOfFour(int step);

  /// Progress label in the onboarding paper progress indicator.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String onboardingStepOf(int step, int total);

  /// Tooltip on the remove button of an attached feedback screenshot. {index} is 1-based.
  ///
  /// In en, this message translates to:
  /// **'Remove image {index}'**
  String feedbackRemoveImage(int index);

  /// Tooltip on the remove button of an attached feedback screenshot, 1-based.
  ///
  /// In en, this message translates to:
  /// **'Remove image {index}'**
  String feedbackRemoveImageIndex(int index);

  /// Points total shown on the leaderboard row.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String rewardsPointsValue(int points);

  /// Help text on the support row in the legal screen.
  ///
  /// In en, this message translates to:
  /// **'Email {email}. We review reports within 24 hours.'**
  String legalSupportEmailBody(String email);

  /// Remove button label for a piece inside the outfit builder.
  ///
  /// In en, this message translates to:
  /// **'Remove {piece}'**
  String outfitRemovePieceTooltip(String piece);

  /// Confirmation title before deleting a collection.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String outfitDeleteNamedTitle(String name);

  /// Menu item that adds an outfit to a named collection.
  ///
  /// In en, this message translates to:
  /// **'Add to \"{name}\"'**
  String outfitAddToNamed(String name);

  /// Toast after deleting an outfit, reassuring the user no clothes were deleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is removed. Its pieces stay in your closet.'**
  String outfitNamedRemoved(String name);

  /// Button that expands a truncated list of outfits.
  ///
  /// In en, this message translates to:
  /// **'Show all {count}'**
  String outfitShowAllCount(int count);

  /// Remaining daily photoshoot image allowance.
  ///
  /// In en, this message translates to:
  /// **'{count} left today'**
  String photoshootImagesLeftToday(int count);

  /// Error label under a single failed photoshoot result, 1-based.
  ///
  /// In en, this message translates to:
  /// **'Photo {index} failed'**
  String photoshootPhotoNumberFailed(int index);

  /// Counter of how many photos are selected versus the maximum.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {max} photos'**
  String photoshootSelectedOfMax(int selected, int max);

  /// Summary line on a body profile card.
  ///
  /// In en, this message translates to:
  /// **'{shape} build · {tone} skin'**
  String bodyProfileBuildSkin(String shape, String tone);

  /// Confirmation title before deleting a body profile.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String bodyProfileDeleteTitle(String name);

  /// Accessibility label on the overflow menu of a body profile card.
  ///
  /// In en, this message translates to:
  /// **'Options for {name}'**
  String bodyProfileOptionsFor(String name);

  /// Summary line naming the most-worn piece in the wardrobe.
  ///
  /// In en, this message translates to:
  /// **'Most worn: {name}, {count} times'**
  String profileMostWorn(String name, int count);

  /// Accessibility label for a profile row with no value yet.
  ///
  /// In en, this message translates to:
  /// **'{label}: not set'**
  String profileFieldUnset(String label);

  /// Match score badge on a recommended colour or outfit.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String recommendMatchPercent(int percent);

  /// Counter of how many pieces are selected for a recommendation.
  ///
  /// In en, this message translates to:
  /// **'{picked} of {max} picked'**
  String recommendPickedCount(int picked, int max);

  /// Remove button label for a selected recommendation item.
  ///
  /// In en, this message translates to:
  /// **'Remove {item}'**
  String recommendRemoveItem(String item);

  /// Shopping-gap priority badge.
  ///
  /// In en, this message translates to:
  /// **'{urgency} priority'**
  String recommendPriorityLabel(String urgency);

  /// Explains that a store-bought subscription cannot be cancelled in the app.
  ///
  /// In en, this message translates to:
  /// **'This plan is billed through the {store}. Change or cancel it in your {store} account settings.'**
  String billingBilledThroughStore(String store);

  /// Button that opens the platform subscription-management page.
  ///
  /// In en, this message translates to:
  /// **'Manage in the {store}'**
  String billingManageInStore(String store);

  /// Screen-reader label for a usage meter.
  ///
  /// In en, this message translates to:
  /// **'{label}: {current} of {max} used'**
  String usageProgressSemantics(String label, int current, int max);

  /// Rough remaining time for a photoshoot render.
  ///
  /// In en, this message translates to:
  /// **'About {seconds}s left'**
  String photoshootAboutSecondsLeft(int seconds);

  /// Progress counter while studio photos render.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} studio photos ready'**
  String photoshootStudioPhotosReadyCount(int done, int total);

  /// Progress counter with a hint to skip a piece.
  ///
  /// In en, this message translates to:
  /// **'{ready} of {total} studio photos ready. Tap a piece to skip it.'**
  String photoshootStudioPhotosReadyTap(int ready, int total);

  /// Height and weight summary on a body profile card. The units are metric and stay as symbols.
  ///
  /// In en, this message translates to:
  /// **'{height} cm · {weight} kg'**
  String bodyProfileMeasurements(String height, String weight);

  /// Screen-reader label for a profile row, combining the value (or a localized 'not set') with the field name.
  ///
  /// In en, this message translates to:
  /// **'{value} {label}'**
  String profileFieldUnsetLabel(String value, String label);

  /// Stand-in value for a profile row that has not been filled in, read by a screen reader as 'No <field>'.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get profileFieldNotSet;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'ca',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'gu',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'kn',
    'ko',
    'ml',
    'mr',
    'ms',
    'nl',
    'no',
    'or',
    'pa',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sv',
    'ta',
    'te',
    'th',
    'tr',
    'uk',
    'ur',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'AU':
            return AppLocalizationsEnAu();
          case 'CA':
            return AppLocalizationsEnCa();
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case 'MX':
            return AppLocalizationsEsMx();
        }
        break;
      }
    case 'fr':
      {
        switch (locale.countryCode) {
          case 'CA':
            return AppLocalizationsFrCa();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'ca':
      return AppLocalizationsCa();
    case 'cs':
      return AppLocalizationsCs();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'ko':
      return AppLocalizationsKo();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ms':
      return AppLocalizationsMs();
    case 'nl':
      return AppLocalizationsNl();
    case 'no':
      return AppLocalizationsNo();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'ur':
      return AppLocalizationsUr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
