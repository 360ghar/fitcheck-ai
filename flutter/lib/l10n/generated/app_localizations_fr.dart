// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabPhotoshoot => 'Shooting';

  @override
  String get tabCloset => 'Dressing';

  @override
  String get tabOutfits => 'Tenues';

  @override
  String get tabMore => 'Plus';

  @override
  String get actionAddItem => 'Ajouter';

  @override
  String get actionCreateOutfit => 'Créer tenue';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get stateLoading => 'Chargement';

  @override
  String get stateErrorTitle => 'Une erreur est survenue';

  @override
  String get stateErrorBody =>
      'Réessayez. Si le problème persiste, contactez le support.';

  @override
  String get stateOfflineTitle => 'Hors ligne';

  @override
  String get stateOfflineBody =>
      'Reconnectez-vous pour synchroniser votre dressing et générer des tenues.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAccountSection => 'Compte';

  @override
  String get settingsPreferencesSection => 'Préférences';

  @override
  String get settingsPlanBilling => 'Abonnement et facturation';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsUnits => 'Unités de mesure';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsPrivacySection => 'Confidentialité et données';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountTitle => 'Supprimer votre compte ?';

  @override
  String get settingsDeleteAccountBody =>
      'Ceci supprimera votre garde-robe, vos tenues, vos photos et votre profil. Cette action est irréversible.';

  @override
  String get settingsUnitsImperial => 'Impérial (po, lb)';

  @override
  String get settingsUnitsMetric => 'Métrique (cm, kg)';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Utiliser la langue de l\'appareil';

  @override
  String get languageSystemBody =>
      'FitCheck AI utilise la langue de votre téléphone.';

  @override
  String get languageSearchHint => 'Rechercher une langue';

  @override
  String get languageCurrent => 'Actuelle';

  @override
  String get languageReviewNote =>
      'Cette traduction est nouvelle. Dites-nous si quelque chose semble incorrect.';

  @override
  String get languageChanged => 'Langue mise à jour';

  @override
  String get paywallTitle => 'Choisir votre formule';

  @override
  String get paywallTrialBadge => '1 mois gratuit';

  @override
  String get paywallTrialTitle => 'Votre premier mois Pro est gratuit';

  @override
  String get paywallTrialBody =>
      'Importez toute votre garde-robe d\'un coup. Ajoutez des pièces au fur et à mesure ensuite.';

  @override
  String get paywallFreeForeverTitle => 'Gratuit pour toujours';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Aucune carte requise. Chaque mois, vous bénéficiez de $uploads imports IA, $outfits tenues et $images photos de shooting par jour.';
  }

  @override
  String get paywallCtaTrial => 'Démarrer mon mois gratuit';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Passer à $plan';
  }

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get paywallManage => 'Gérer l\'abonnement';

  @override
  String get paywallTerms => 'Conditions d\'utilisation';

  @override
  String get paywallPrivacy => 'Politique de confidentialité';

  @override
  String get paywallPerMonth => 'par mois';

  @override
  String get paywallPerYear => 'par an';

  @override
  String get paywallBestValue => 'Meilleur rapport qualité-prix';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Essai gratuit réservé aux nouveaux abonnés. Après l\'essai, Pro se renouvelle à $price sauf annulation au moins 24 heures avant la fin.';
  }

  @override
  String get introTitle => 'Votre garde-robe, enfin organisée';

  @override
  String get introBody =>
      'Prenez vos vêtements en photo. Obtenez des idées de tenues, des essayages virtuels et des photos studio à partir de ce que vous possédez déjà.';

  @override
  String get introStart => 'Commencer';

  @override
  String get introHaveAccount => 'J\'ai déjà un compte';

  @override
  String get introSkip => 'Passer';

  @override
  String get authSignIn => 'Connexion';

  @override
  String get authSignUp => 'Créer un compte';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authContinueApple => 'Continuer avec Apple';

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authOrDivider => 'ou';

  @override
  String get wardrobeTitle => 'Garde-robe';

  @override
  String get wardrobeEmptyTitle => 'Votre garde-robe est vide';

  @override
  String get wardrobeEmptyBody =>
      'Ajoutez votre première pièce ou téléchargez une photo de toute votre penderie d\'un coup.';

  @override
  String get wardrobeAddFirst => 'Ajouter un article';

  @override
  String get wardrobeSearchHint => 'Rechercher dans votre garde-robe';

  @override
  String get categoryTops => 'Hauts';

  @override
  String get categoryBottoms => 'Bas';

  @override
  String get categoryShoes => 'Chaussures';

  @override
  String get categoryAccessories => 'Accessoires';

  @override
  String get categoryOuterwear => 'Manteaux';

  @override
  String get categorySwimwear => 'Maillots de bain';

  @override
  String get categoryActivewear => 'Sport';

  @override
  String get categoryOther => 'Autre';

  @override
  String get conditionClean => 'Propre';

  @override
  String get conditionDirty => 'Sale';

  @override
  String get conditionLaundry => 'Au lavage';

  @override
  String get conditionRepair => 'À réparer';

  @override
  String get conditionDonate => 'À donner';

  @override
  String get seasonSpring => 'Printemps';

  @override
  String get seasonSummer => 'Été';

  @override
  String get seasonFall => 'Automne';

  @override
  String get seasonWinter => 'Hiver';

  @override
  String get seasonAll => 'Toutes saisons';

  @override
  String get styleCasual => 'Décontracté';

  @override
  String get styleFormal => 'Habillé';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Sport';

  @override
  String get styleBohemian => 'Bohème';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimaliste';

  @override
  String get styleRomantic => 'Romantique';

  @override
  String get styleEdgy => 'Audacieux';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artistique';

  @override
  String get styleClassic => 'Classique';

  @override
  String get styleElegant => 'Élégant';

  @override
  String get styleOther => 'Autre';

  @override
  String get occasionWork => 'Travail';

  @override
  String get occasionDateNight => 'Rencard';

  @override
  String get occasionTravel => 'Voyage';

  @override
  String get occasionWedding => 'Mariage';

  @override
  String get occasionGym => 'Sport';

  @override
  String get occasionWeekend => 'Week-end';

  @override
  String get occasionParty => 'Soirée';

  @override
  String get occasionInterview => 'Entretien';

  @override
  String get colorBlack => 'Noir';

  @override
  String get colorWhite => 'Blanc';

  @override
  String get colorGrey => 'Gris';

  @override
  String get colorNavy => 'Marine';

  @override
  String get colorBrown => 'Marron';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorPurple => 'Violet';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count semaines',
      one: 'Il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count mois',
      one: 'Il y a 1 mois',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count ans',
      one: 'Il y a 1 an',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Vous aimez FitCheck AI ?';

  @override
  String get ratingPromptBody =>
      'Une note rapide aide les autres à trouver leur style.';

  @override
  String get ratingPromptYes => 'Noter l\'app';

  @override
  String get ratingPromptNo => 'Pas maintenant';

  @override
  String get closetNoMatchesTitle => 'Aucune pièce trouvée';

  @override
  String get closetNoMatchesBody =>
      'Essayez moins de filtres ou une autre recherche.';

  @override
  String get closetClearFilters => 'Effacer les filtres';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces',
      one: '1 pièce',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Chargement de vos pièces';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Supprimer la sélection';

  @override
  String get closetCancelSelection => 'Annuler la sélection';

  @override
  String get closetCloseSearch => 'Fermer la recherche';

  @override
  String get closetShowGrid => 'Afficher en grille';

  @override
  String get closetShowList => 'Afficher en liste';

  @override
  String get closetShowRows => 'Afficher en lignes';

  @override
  String get closetStatsTitle => 'Statistiques du dressing';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count pièces ?',
      one: 'Supprimer 1 pièce ?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Les tenues utilisant ces pièces seront modifiées.';

  @override
  String get closetSortBy => 'Trier par';

  @override
  String get closetFavourites => 'Favoris';

  @override
  String get closetFavourite => 'Ajouter aux favoris';

  @override
  String get closetUnfavourite => 'Retirer des favoris';

  @override
  String get closetWoreToday => 'Porté aujourd\'hui';

  @override
  String closetWornTimes(int count) {
    return 'Porté $count×';
  }

  @override
  String get closetCategoryLabel => 'Catégorie';

  @override
  String get closetUseCaseLabel => 'Usage';

  @override
  String get closetAnyUseCase => 'Tous';

  @override
  String get closetOtherUseCase => 'Autre usage';

  @override
  String get closetOtherUseCaseHint => 'Par exemple, brunch';

  @override
  String get closetUseUseCase => 'Utiliser';

  @override
  String get closetClearAll => 'Tout effacer';

  @override
  String get sortNewest => 'Plus récent d\'abord';

  @override
  String get sortOldest => 'Plus anciens';

  @override
  String get sortName => 'Nom (A–Z)';

  @override
  String get sortMostWorn => 'Les plus portés';

  @override
  String get useCaseInformal => 'Décontracté';

  @override
  String get useCaseDate => 'Rencard';

  @override
  String get useCaseDinner => 'Dîner';

  @override
  String get useCaseLunch => 'Déjeuner';

  @override
  String get actionSelect => 'Sélectionner';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionFilter => 'Filtrer';

  @override
  String get actionSort => 'Trier';

  @override
  String get actionAll => 'Tout';

  @override
  String get dashboardStartClosetTitle => 'Commencez votre dressing';

  @override
  String get dashboardStartClosetBody =>
      'Prenez quelques pièces en photo. Nous les taguons pour vous.';

  @override
  String get dashboardPieces => 'pièces';

  @override
  String get dashboardOutfits => 'tenues';

  @override
  String get dashboardDayStreak => 'jours d\'affilée';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count ce mois-ci';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Record $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoris',
      one: '1 favori',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenues enregistrées',
      one: '1 tenue enregistrée',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Le plus porté : $name, $count fois';
  }

  @override
  String get setupSkip => 'Passer la config';

  @override
  String get setupWhoTitle => 'Pour qui le style ?';

  @override
  String get setupWhoBody =>
      'Définit le modèle pour les essayages. Modifiable dans votre profil.';

  @override
  String get setupStyleTitle => 'Que portez-vous le plus ?';

  @override
  String get setupStyleBody =>
      'Choisissez-en. Vos idées de tenues en découlent.';

  @override
  String get setupClosetTitle => 'Ajoutez vos premières pièces.';

  @override
  String get setupClosetBody =>
      'Prenez quelques vêtements en photo, ou une pile. Chaque pièce est détourée et classée pour vous.';

  @override
  String get setupAddClothes => 'Ajouter des vêtements';

  @override
  String get setupStylesLabel => 'Styles';

  @override
  String get setupOccasionsLabel => 'Occasions';

  @override
  String get setupSkipStep => 'Passer';

  @override
  String get setupLater => 'Plus tard';

  @override
  String get setupSaveError => 'Échec de l\'enregistrement';

  @override
  String get genderWomen => 'Femme';

  @override
  String get genderMen => 'Homme';

  @override
  String get genderNonBinary => 'Non binaire';

  @override
  String get genderPreferNotToSay => 'Ne souhaite pas répondre';

  @override
  String get outfitEmptyTitle => 'Aucune tenue';

  @override
  String get outfitEmptyBody =>
      'Associez des pièces de votre dressing et enregistrez le look.';

  @override
  String get outfitNoMatchesTitle => 'Aucune tenue trouvée';

  @override
  String get outfitSearchHint => 'Rechercher dans vos tenues';

  @override
  String get outfitLoading => 'Chargement des tenues';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenues',
      one: '1 tenue',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Style et saison';

  @override
  String get outfitCollections => 'Collections';

  @override
  String get outfitDuplicate => 'Dupliquer';

  @override
  String get outfitDeleteTitle => 'Supprimer cette tenue ?';

  @override
  String get outfitDeleteBody => 'Les pièces resteront dans votre dressing.';

  @override
  String get outfitDrafts => 'Brouillons';

  @override
  String get outfitDraft => 'Brouillon';

  @override
  String get filterStyle => 'Style';

  @override
  String get filterSeason => 'Saison';

  @override
  String get itemDetailDeleteTitle => 'Supprimer cette pièce ?';

  @override
  String get itemDetailDeleteBody =>
      'Les tenues utilisant cette pièce seront modifiées.';

  @override
  String get itemAddFavourite => 'Ajouter aux favoris';

  @override
  String itemSize(String size) {
    return 'Taille $size';
  }

  @override
  String get itemColours => 'Couleurs';

  @override
  String get itemMaterial => 'Matière';

  @override
  String get itemPattern => 'Motif';

  @override
  String get itemUseCases => 'Occasions';

  @override
  String get itemKeptIn => 'Rangé dans';

  @override
  String get itemPrice => 'Prix';

  @override
  String get itemBought => 'Acheté';

  @override
  String get itemTags => 'Étiquettes';

  @override
  String get itemAdded => 'Ajouté';

  @override
  String get itemTimesWornLabel => 'porté';

  @override
  String get itemLastWornLabel => 'dernière fois';

  @override
  String get itemNeverWorn => 'Jamais';

  @override
  String get authEntryBody =>
      'Chaque pièce de votre garde-robe, stylisée par FitCheck AI. Planifiez vos tenues, essayez-les, photographiez-les.';

  @override
  String get authCreateCloset => 'Créer votre dressing';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authSignInBody => 'Connectez-vous pour ouvrir votre dressing.';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authCreateClosetBody =>
      'Cela prend une minute. Vos premiers articles sont gratuits.';

  @override
  String get authName => 'Nom';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authReferralCode => 'Code de parrainage (optionnel)';

  @override
  String get authResetTitle => 'Réinitialiser votre mot de passe';

  @override
  String get authResetBody =>
      'Nous vous enverrons un lien par e-mail pour en choisir un nouveau.';

  @override
  String get authSendResetLink => 'Envoyer le lien';

  @override
  String get authBackToSignIn => 'Retour à la connexion';

  @override
  String get authEnterEmail => 'Entrez votre e-mail';

  @override
  String get authEnterValidEmail => 'Entrez un e-mail valide';

  @override
  String get authEnterPassword => 'Entrez votre mot de passe';

  @override
  String get authPasswordTooShort => '6 caractères minimum';

  @override
  String get authShowPassword => 'Afficher';

  @override
  String get authHidePassword => 'Masquer';

  @override
  String get authNewHere => 'Nouveau ici ?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirmez $email avant de vous connecter. Vérifiez votre boîte mail.';
  }

  @override
  String get authResendEmail => 'Renvoyer';

  @override
  String get authResendingEmail => 'Envoi en cours…';

  @override
  String get authPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authEnterName => 'Entrez votre nom';

  @override
  String get authChoosePassword => 'Choisissez un mot de passe';

  @override
  String get authHaveAccount => 'Déjà un compte ?';

  @override
  String get authCodeAccepted => 'Code accepté';

  @override
  String get authCodeNotFound => 'Code introuvable';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Vous gagnez tous deux un mois gratuit.';
  }

  @override
  String get authReferralInvalid => 'Code invalide.';

  @override
  String authResetSent(String email) {
    return 'Envoyé à $email. Ouvrez le lien sur ce téléphone.';
  }

  @override
  String get introSlide1Title => 'Photographiez votre garde-robe.';

  @override
  String get introSlide1Body =>
      'Prenez une pile de vêtements en photo. Chaque pièce est détourée et classée pour vous.';

  @override
  String get introSlide2Title => 'Habillez-vous plus vite.';

  @override
  String get introSlide2Body =>
      'Des tenues créées à partir de vos vêtements, adaptées à votre emploi du temps et à la météo.';

  @override
  String get introSlide3Title => 'Visualisez avant de porter.';

  @override
  String get introSlide3Body =>
      'Essayez des looks sur votre photo ou shootez-les comme une campagne de mode.';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsTemperature => 'Température';

  @override
  String get settingsEmailUpdates => 'Mises à jour par e-mail';

  @override
  String get settingsEmailUpdatesBody => 'Actualités et conseils par e-mail';

  @override
  String get settingsOutfitReminders => 'Rappels de tenues';

  @override
  String get settingsOutfitRemindersBody =>
      'Un rappel pour noter ce que vous avez porté';

  @override
  String get settingsWeeklySummary => 'Résumé hebdomadaire';

  @override
  String get settingsWeeklySummaryBody => 'Votre semaine en tenues';

  @override
  String get settingsStyleSection => 'Style';

  @override
  String get settingsPreferredStyles => 'Styles favoris';

  @override
  String get settingsPreferredColours => 'Couleurs favorites';

  @override
  String get settingsNoneChosen => 'Aucun choix';

  @override
  String get settingsPlanAiSection => 'Abonnement et IA';

  @override
  String get settingsPlanBillingBody => 'Abonnement, usage et mises à niveau';

  @override
  String get settingsPlanUsageBody => 'Abonnement et usage';

  @override
  String get settingsInviteFriends => 'Inviter des amis';

  @override
  String get settingsInviteFriendsBody =>
      'Un mois offert pour chaque ami qui rejoint';

  @override
  String get settingsAiProvider => 'Fournisseur IA';

  @override
  String get settingsAiProviderBody =>
      'Utilisez votre propre modèle pour le taggage et les images';

  @override
  String get settingsAppVersion => 'Version de l\'app';

  @override
  String get settingsPrivacyTerms => 'Confidentialité et conditions';

  @override
  String get settingsReportProblem => 'Signaler un problème';

  @override
  String get settingsChangePassword => 'Changer le mot de passe';

  @override
  String get settingsExportData => 'Exporter vos données';

  @override
  String get settingsExportBody =>
      'Nous préparons un fichier avec tout ce que vous avez enregistré et ouvrons le téléchargement.';

  @override
  String get settingsExportAction => 'Exporter';

  @override
  String get settingsCurrentPassword => 'Mot de passe actuel';

  @override
  String get settingsNewPassword => 'Nouveau mot de passe';

  @override
  String get settingsConfirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get settingsEnterCurrentPassword =>
      'Saisissez votre mot de passe actuel';

  @override
  String get settingsEnterNewPassword => 'Saisissez un nouveau mot de passe';

  @override
  String get settingsPasswordMin8 => 'Utilisez au moins 8 caractères';

  @override
  String get settingsPasswordNeedsUpper => 'Ajoutez une majuscule';

  @override
  String get settingsPasswordNeedsLower => 'Ajoutez une minuscule';

  @override
  String get settingsPasswordNeedsDigit => 'Ajoutez un chiffre';

  @override
  String get settingsPasswordsNoMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get settingsChangeAction => 'Modifier';

  @override
  String get itemAddSnapTitle => 'Photographiez une pièce';

  @override
  String get itemAddSnapBody =>
      'Nous détectons chaque pièce sur la photo pour créer un cliché studio net.';

  @override
  String get itemAddCamera => 'Prendre une photo';

  @override
  String get itemAddGallery => 'Choisir dans la galerie';

  @override
  String get itemAddOtherWays => 'Autres méthodes d\'ajout';

  @override
  String get itemAddSeveral => 'Ajouter plusieurs photos';

  @override
  String get itemAddSeveralBody => 'Jusqu\'à 50 à la fois';

  @override
  String get itemAddImportProfile => 'Importer depuis un profil';

  @override
  String get itemAddImportProfileBody => 'Instagram ou Facebook';

  @override
  String get itemAddEnterDetails => 'Saisir les détails manuellement';

  @override
  String get itemAddEnterDetailsBody => 'Aucune photo requise';

  @override
  String get itemManualIntro =>
      'Un nom suffit. Ajoutez le reste maintenant ou plus tard.';

  @override
  String get itemManualNameHint => 'Par exemple, t-shirt bleu en coton';

  @override
  String get itemManualEnterName => 'Saisissez un nom';

  @override
  String get itemManualNotes => 'Notes';

  @override
  String get itemManualBrand => 'Marque';

  @override
  String get itemManualSize => 'Taille';

  @override
  String get itemManualEnterNumber => 'Saisissez un nombre';

  @override
  String get itemManualSavePiece => 'Enregistrer la pièce';

  @override
  String get itemManualSaving => 'Enregistrement';

  @override
  String get itemManualSavedTitle => 'Enregistré';

  @override
  String itemManualSavedBody(String name) {
    return '$name est dans votre dressing.';
  }

  @override
  String get itemManualNotSaved => 'Non enregistré';

  @override
  String get itemManualAddUseCase => 'Ajouter un usage';

  @override
  String get itemManualAddUseCaseAction => 'Ajouter usage';

  @override
  String get itemPhotos => 'Photos';

  @override
  String get itemAddPhotos => 'Ajouter des photos';

  @override
  String get itemNoPhotoYet => 'Aucune photo. Vous pouvez enregistrer sans.';

  @override
  String get itemRemovePhoto => 'Supprimer la photo';

  @override
  String get itemRemovePiece => 'Supprimer la pièce';

  @override
  String get filterConditionLabel => 'État';

  @override
  String get photoshootStepPhotos => 'Photos';

  @override
  String get photoshootStepSetup => 'Configuration';

  @override
  String get photoshootStepCreating => 'Création';

  @override
  String get photoshootStepResults => 'Résultats';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Étape $current sur $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Une photo a échoué. Réessayez ci-dessous.';

  @override
  String photoshootManyFailed(int count) {
    return '$count photos ont échoué. Réessayez chaque photo ci-dessous.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Nombre';

  @override
  String get photoshootYourPrompt => 'Votre description';

  @override
  String get photoshootPromptHint => 'Heure dorée sur un toit, chemise en lin';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Créer $count photos',
      one: 'Créer 1 photo',
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
  String get photoshootLimitUnknown =>
      'Impossible de vérifier la limite du jour.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plan $plan : $remaining sur $limit restants aujourd\'hui';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratuit';

  @override
  String get photoshootGallery => 'Galerie';

  @override
  String get photoshootUseCamera => 'Utiliser l\'appareil photo';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Supprimer la photo $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Aucune photo générée';

  @override
  String get photoshootNoPhotosBody =>
      'La séance s\'est terminée sans image. Réessayez.';

  @override
  String get photoshootNewStyle => 'Nouveau style';

  @override
  String get photoshootNewPhotos => 'Nouvelles photos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Ouvrir la photo $number';
  }

  @override
  String get photoshootReportPhoto => 'Signaler la photo';

  @override
  String get photoshootSaveToGallery => 'Enregistrer dans la galerie';

  @override
  String get actionUpgrade => 'Passer à Pro';

  @override
  String get referralLimitTitle => 'Quota de photos atteint';

  @override
  String get referralLimitBody =>
      'Vos photos gratuites reviennent demain. Parrainez un ami pour obtenir un mois de Pro offert chacun.';

  @override
  String get referralLimitRefer => 'Parrainer un ami';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Rencontres';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Esthétique';

  @override
  String get photoshootUseCustom => 'Votre propre prompt';

  @override
  String get photoshootDescLinkedin => 'Portraits professionnels';

  @override
  String get photoshootDescDating => 'Détendu, chaleureux et naturel';

  @override
  String get photoshootDescPortfolio => 'Éditorial, haute couture';

  @override
  String get photoshootDescInstagram => 'Lifestyle pour votre feed';

  @override
  String get photoshootDescAesthetic => 'Artistique et atmosphérique';

  @override
  String get photoshootDescCustom => 'Décrivez le look souhaité';

  @override
  String get aspectSquare => 'Carré';

  @override
  String get aspectPortrait => 'Portrait';

  @override
  String get aspectLandscape => 'Paysage';

  @override
  String get aspectTall => 'Vertical';

  @override
  String get aspectWide => 'Horizontal';

  @override
  String get tryOnAppBar => 'Essayage virtuel';

  @override
  String get tryOnYourPhoto => 'Votre photo';

  @override
  String get tryOnGarment => 'Vêtement';

  @override
  String get tryOnUploadingPhoto => 'Téléchargement de votre photo';

  @override
  String get tryOnAddPhotoPrompt => 'Ajoutez une photo de vous en pied';

  @override
  String get tryOnBodyPhotoHint => 'Une photo en pied fonctionne mieux';

  @override
  String get tryOnAddPhoto => 'Ajouter une photo';

  @override
  String get tryOnChangePhoto => 'Changer la photo';

  @override
  String get tryOnPhotoLoadFailed => 'Impossible de charger votre photo.';

  @override
  String get tryOnChooseGarment => 'Choisir une photo de vêtement';

  @override
  String get tryOnChooseOneGarment => 'Choisir une photo de vêtement';

  @override
  String get tryOnGarmentHint =>
      'Une photo à plat ou sur cintre fonctionne mieux';

  @override
  String get tryOnChange => 'Changer';

  @override
  String get tryOnCamera => 'Appareil photo';

  @override
  String get tryOnRemove => 'Supprimer';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Style';

  @override
  String get tryOnBackground => 'Arrière-plan';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Habillage en cours. Cela prend environ trente secondes.';

  @override
  String get tryOnEmptyResult => 'Votre essayage apparaîtra ici';

  @override
  String get tryOnReportImage => 'Signaler l\'image';

  @override
  String get tryOnCreating => 'Création';

  @override
  String get tryOnTryAgain => 'Réessayer';

  @override
  String get tryOnCreate => 'Créer l\'essayage';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio blanc';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio gris';

  @override
  String get tryOnBackgroundUrban => 'Rue urbaine';

  @override
  String get tryOnBackgroundNature => 'Nature';

  @override
  String get tryOnBackgroundMinimal => 'Minimaliste';

  @override
  String get tryOnPoseFront => 'Debout de face';

  @override
  String get tryOnPoseSide => 'Profil';

  @override
  String get tryOnPoseWalking => 'En marche';

  @override
  String get dashboardGreetingMorning => 'Bonjour';

  @override
  String get dashboardGreetingAfternoon => 'Bon après-midi';

  @override
  String get dashboardGreetingEvening => 'Bonsoir';

  @override
  String get dashboardWelcome => 'Bienvenue';

  @override
  String get dashboardOpenProfile => 'Voir profil';

  @override
  String get dashboardRailToday => 'Aujourd\'hui';

  @override
  String get dashboardRailRecently => 'Récemment';

  @override
  String get dashboardActivityEmpty =>
      'Vos pièces et tenues s\'afficheront ici.';

  @override
  String get quickAddPiece => 'Ajouter une pièce';

  @override
  String get quickAddPieceBody => 'Photographier et taguer';

  @override
  String get quickBuildOutfit => 'Créer une tenue';

  @override
  String get quickBuildOutfitBody => 'Mixez vos pièces';

  @override
  String get quickForYou => 'Pour vous';

  @override
  String get quickForYouBody => 'Sélections du jour';

  @override
  String get quickPlanWeek => 'Planifier la semaine';

  @override
  String get quickPlanWeekBody => 'Tenues par date';

  @override
  String get referralBannerUrgent => 'Besoin d\'aide ? Invitez un ami.';

  @override
  String get referralBannerTitle => 'Un mois offert pour chacun.';

  @override
  String get referralBannerBody => 'Vous et votre ami recevez un mois de Pro.';

  @override
  String get referralBannerDismiss => 'Masquer une semaine';

  @override
  String get referralBannerShare => 'Partager l\'invitation';

  @override
  String get referralBannerCopy => 'Copier le lien';

  @override
  String get itemEditPieceTitle => 'Modifier la pièce';

  @override
  String get itemEditDescriptionLabel => 'Description';

  @override
  String get itemEditNotSaved => 'Non enregistré';

  @override
  String get itemEditSavedTitle => 'Enregistré';

  @override
  String get itemEditSavedBody => 'Vos modifications sont enregistrées.';

  @override
  String get itemEditSavedStalePhotos =>
      'Enregistré — photos potentiellement obsolètes';

  @override
  String get itemEditRemovePieceHint => 'Supprimer cette pièce de la fiche.';

  @override
  String get itemEditNoPhotos =>
      'Aucune photo. Ajoutez-en une depuis votre galerie ou appareil photo.';

  @override
  String get itemEditKeepPhoto => 'Garder la photo';

  @override
  String get itemEditRemoved => 'Supprimé';

  @override
  String get itemEditAddUseCaseAction => 'Ajouter';

  @override
  String get statsNoStatsTitle => 'Aucune statistique';

  @override
  String get statsNoStatsBody =>
      'Ajoutez quelques pièces pour voir votre garde-robe ici.';

  @override
  String get statsByCategory => 'Par catégorie';

  @override
  String get statsTotalValue => 'valeur totale';

  @override
  String get statsMostWorn => 'Le plus porté';

  @override
  String get statsLeastWorn => 'En attente';

  @override
  String get statsUnnamedPiece => 'Pièce sans nom';

  @override
  String get jobsTitle => 'Analyses';

  @override
  String get jobsEmptyTitle => 'Aucune analyse';

  @override
  String get jobsEmptyBody =>
      'Prenez une photo et laissez-nous travailler en arrière-plan.';

  @override
  String get jobsNotCancelled => 'Non annulé';

  @override
  String get jobsResume => 'Reprendre';

  @override
  String get jobsReview => 'Revoir';

  @override
  String get jobsStop => 'Arrêter';

  @override
  String get jobsDismiss => 'Ignorer';

  @override
  String get reportTitle => 'Signaler un contenu';

  @override
  String reportIntro(String contentType) {
    return 'Dites-nous ce qui ne va pas avec ce $contentType. Notre équipe examine chaque signalement.';
  }

  @override
  String get reportReasonInappropriate => 'Inapproprié ou offensant';

  @override
  String get reportReasonNudity => 'Nudité ou contenu sexuel';

  @override
  String get reportReasonHarassment => 'Harcèlement ou abus';

  @override
  String get reportReasonImpersonation => 'Usurpation d\'identité';

  @override
  String get reportReasonOther => 'Autre';

  @override
  String get reportDetailsLabel => 'Détails supplémentaires (optionnel)';

  @override
  String get reportSubmit => 'Envoyer le signalement';

  @override
  String get reportSubmittedTitle => 'Signalement envoyé';

  @override
  String get reportSubmittedBody => 'Merci. Notre équipe examinera ce contenu.';

  @override
  String get reportFailedTitle => 'Échec de l\'envoi';

  @override
  String get reportFailedBody => 'Veuillez réessayer.';

  @override
  String get reportContentTryOnImage => 'image d\'essayage IA';

  @override
  String get reportContentSharedOutfit => 'tenue partagée';

  @override
  String get reportContentPhotoshootImage => 'image de shooting IA';

  @override
  String get sharedOutfitTitle => 'Tenue partagée';

  @override
  String get sharedOutfitHideTooltip => 'Masquer cette tenue';

  @override
  String get sharedOutfitReportTooltip => 'Signaler cette tenue';

  @override
  String get sharedOutfitHideTitle => 'Masquer cette tenue ?';

  @override
  String get sharedOutfitHideBody =>
      'Elle restera masquée sur cet appareil. Vous pouvez aussi la signaler pour que notre équipe l\'examine et la supprime.';

  @override
  String get sharedOutfitHideAction => 'Masquer';

  @override
  String get sharedOutfitHiddenInfo =>
      'Cette tenue ne s\'affichera plus sur cet appareil.';

  @override
  String get sharedOutfitHiddenToast => 'Tenue masquée';

  @override
  String get sharedOutfitMissingTitle => 'Cette tenue n\'est plus disponible';

  @override
  String get sharedOutfitMissingBody =>
      'Elle a peut-être été supprimée ou le lien est incorrect.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Vous avez masqué cette tenue';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Si elle est inappropriée, signalez-la via Confidentialité et conditions ou par e-mail à $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Ce look vous plaît ?';

  @override
  String get sharedOutfitCtaBody =>
      'Créez des tenues similaires avec votre propre garde-robe.';

  @override
  String get sharedOutfitCtaButton => 'Obtenir FitCheck AI';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get errorUnknown => 'Une erreur inattendue s\'est produite';

  @override
  String get errorNoConnection =>
      'Pas de connexion Internet. Veuillez vérifier votre réseau.';

  @override
  String get errorTimeout => 'Délai d\'attente dépassé. Veuillez réessayer.';

  @override
  String get errorServerError =>
      'Un problème est survenu de notre côté. Veuillez réessayer.';

  @override
  String get errorBadGateway =>
      'Notre serveur est momentanément indisponible. Veuillez réessayer.';

  @override
  String get errorServiceUnavailable =>
      'Le service est temporairement indisponible. Veuillez réessayer dans un moment.';

  @override
  String get errorInternalError =>
      'Un problème est survenu. Veuillez réessayer.';

  @override
  String get errorUnauthorized => 'Veuillez vous connecter pour continuer.';

  @override
  String get errorForbidden => 'Vous n\'avez pas accès à ceci.';

  @override
  String get errorSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get errorInvalidCredentials =>
      'Cet e-mail ou ce mot de passe est incorrect.';

  @override
  String get errorTokenRefreshFailed =>
      'Impossible d\'actualiser votre session. Veuillez vous reconnecter.';

  @override
  String get errorRequestCancelled => 'Requête annulée.';

  @override
  String get errorInvalidFormat =>
      'Ce format de fichier n\'est pas pris en charge.';

  @override
  String get errorFileTooLarge => 'Ce fichier est trop volumineux.';

  @override
  String get errorUploadFailed =>
      'Le téléchargement a échoué. Veuillez réessayer.';

  @override
  String get errorCacheCorrupted =>
      'Les données enregistrées ont été endommagées et réinitialisées.';

  @override
  String get errorCacheNotFound => 'Rien n\'a encore été enregistré.';

  @override
  String get errorUserNotFound => 'Impossible de trouver ce compte.';

  @override
  String get errorItemNotFound => 'Cet article n\'existe plus.';

  @override
  String get errorOutfitNotFound => 'Cette tenue n\'existe plus.';

  @override
  String get rewardsTitle => 'Récompenses';

  @override
  String get rewardsNoAchievementsTitle => 'Aucun succès pour l\'instant';

  @override
  String get rewardsNoAchievementsBody =>
      'Ajoutez des pièces et créez des tenues pour gagner votre premier succès.';

  @override
  String get rewardsEmptyLeaderboardTitle =>
      'Personne au classement pour l\'instant';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Créez des tenues pour gagner des points et apparaître ici.';

  @override
  String get legalViewPrivacyPolicy => 'Voir la politique de confidentialité';

  @override
  String get aiConsentAgree => 'J\'accepte et continuer';

  @override
  String get aiConsentNotNow => 'Pas maintenant';

  @override
  String get imageViewerCloseTooltip => 'Fermer la vue de l\'image';

  @override
  String get updateReadyTitle => 'Mise à jour prête';

  @override
  String get updateReadyBody =>
      'Redémarrez FitCheck AI pour appliquer les dernières améliorations.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI a besoin d\'accéder à l\'appareil photo pour prendre des photos de vos tenues et articles.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI a besoin d\'accéder à votre photothèque pour sélectionner des photos de vos tenues.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI a besoin d\'enregistrer vos photos de tenues générées dans votre photothèque.';

  @override
  String get wardrobeSomePhotosSkipped => 'Certaines photos ont été ignorées';

  @override
  String get wardrobePhotosNotAdded => 'Photos non ajoutées';

  @override
  String get wardrobePhotoNotAdded => 'Photo non ajoutée';

  @override
  String get wardrobeNotStartedTitle => 'Non commencé';

  @override
  String get wardrobeNoRoomTitle => 'Pas de place';

  @override
  String get wardrobeAddPhotosSemantic => 'Ajouter des photos';

  @override
  String get batchAddTileLabel => 'Ajouter';

  @override
  String get batchProfileLinkLabel => 'Lien du profil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importer depuis un profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Ajouter plusieurs photos';

  @override
  String get wardrobeClearAction => 'Effacer';

  @override
  String get wardrobeRefreshTooltip => 'Actualiser';

  @override
  String get batchNoPhotosYetTitle => 'Aucune photo pour l\'instant';

  @override
  String get batchChoosePhotosAction => 'Choisir des photos';

  @override
  String get batchWeFindEachPieceBody =>
      'Nous identifions chaque pièce et créons une photo studio.';

  @override
  String get batchPreparingPhotosSemantic => 'Préparation des photos';

  @override
  String get batchPhotosProcessedSemantic => 'Photos traitées';

  @override
  String get batchPasteProfileLinkTitle => 'Coller le lien d\'un profil';

  @override
  String get batchPasteProfileLinkBody =>
      'Un profil public Instagram ou Facebook. Nous scannons ses photos et vous choisissez ce qui entre dans votre dressing.';

  @override
  String get batchClearLinkTooltip => 'Effacer le lien';

  @override
  String get batchStartingButton => 'Démarrage';

  @override
  String get batchStartImportAction => 'Lancer l\'importation';

  @override
  String get batchReviewEveryPhotoTitle => 'Vous examinez chaque photo';

  @override
  String get batchReviewEveryPhotoBody =>
      'Rien n\'est ajouté tant que vous ne l\'avez pas approuvé.';

  @override
  String get batchPrivateProfilesTitle => 'Profils privés';

  @override
  String get batchPrivateProfilesBody =>
      'Connectez votre compte. Instagram demande aussi un nom d\'utilisateur et un mot de passe.';

  @override
  String get batchUseAnotherLinkAction => 'Utiliser un autre lien';

  @override
  String get batchSignInNeededTitle => 'Connexion requise';

  @override
  String get batchEnterYourCodeTitle => 'Entrez votre code';

  @override
  String get batchUseUsernamePasswordAction =>
      'Utiliser identifiant et mot de passe';

  @override
  String get batchAlreadyConnectedAction => 'Déjà connecté dans le navigateur';

  @override
  String get batchEnterCodeAction => 'Entrer le code';

  @override
  String get batchTryAnotherWayAction => 'Autre méthode';

  @override
  String get batchLiveStatus => 'En direct';

  @override
  String get batchReconnectingStatus => 'Reconnexion';

  @override
  String get batchSignInToInstagramTitle => 'Connexion à Instagram';

  @override
  String get batchUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get batchCodeIfTwoStepLabel => 'Code (si double authentification)';

  @override
  String get batchAuthenticatorCodeBody =>
      'Entrez le code à 6 chiffres de votre application d\'authentification. Les codes expirent vite.';

  @override
  String get batchVerifyAction => 'Vérifier';

  @override
  String get batchFindingPhotosTitle => 'Recherche de photos';

  @override
  String get batchImportPausedTitle => 'Import en pause';

  @override
  String get batchProcessingPhotosTitle => 'Traitement des photos';

  @override
  String get batchWaitingNextPhoto => 'En attente de la photo suivante';

  @override
  String get batchCancelImportAction => 'Annuler l\'import';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Aucune pièce détectée sur cette photo.';

  @override
  String get batchEditPieceColoursLabel => 'Couleurs séparées par des virgules';

  @override
  String get batchAddToClosetAction => 'Ajouter au dressing';

  @override
  String get batchSkipPhotoAction => 'Passer cette photo';

  @override
  String get batchImportCompleteTitle => 'Import terminé';

  @override
  String get batchImportFailedTitle => 'Échec de l\'import';

  @override
  String get batchImportCancelledTitle => 'Import annulé';

  @override
  String get batchImportErrorBody =>
      'Un problème est survenu lors de l\'import.';

  @override
  String get batchNothingMoreImportedBody =>
      'Aucun autre élément de ce profil n\'a été importé.';

  @override
  String get batchViewClosetAction => 'Voir le dressing';

  @override
  String get batchStartOverAction => 'Recommencer';

  @override
  String get wardrobeAddPieceTitle => 'Ajouter un article';

  @override
  String get wardrobeAddDetailsTitle => 'Ajouter des détails';

  @override
  String get wardrobeScanningTitle => 'Analyse en cours';

  @override
  String get batchReviewPiecesTitle => 'Vérifier les articles';

  @override
  String get wardrobeGalleryAction => 'Galerie';

  @override
  String get wardrobeCameraAction => 'Appareil photo';

  @override
  String get wardrobeNewBadge => 'Nouveau';

  @override
  String get wardrobeRemovePhotoTooltip => 'Supprimer la photo';

  @override
  String get batchRunInBackgroundTooltip => 'Exécuter en arrière-plan';

  @override
  String get batchStepOneOfTwo => 'Étape 1 sur 2';

  @override
  String get batchStepTwoOfTwo => 'Étape 2 sur 2';

  @override
  String get batchUploadingPhotosTitle => 'Téléversement des photos';

  @override
  String get batchFindingPiecesTitle => 'Recherche des articles';

  @override
  String get batchMakingStudioPhotosTitle => 'Création des photos studio';

  @override
  String get batchStoppedLabel => 'Arrêté';

  @override
  String get batchFindingPiecesStoppedTitle => 'Recherche des articles arrêtée';

  @override
  String get batchCancelledLabel => 'Annulé';

  @override
  String get batchAllDoneTitle => 'Terminé';

  @override
  String get batchOpeningPiecesBody => 'Ouverture de vos articles';

  @override
  String get batchNothingSavedBody => 'Rien n\'a été enregistré.';

  @override
  String get batchFindingPiecesFailedBody =>
      'Échec de la recherche des articles.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Recherche des articles interrompue.';

  @override
  String get batchStopFindingPiecesTitle => 'Arrêter la recherche ?';

  @override
  String get batchStopFindingPiecesBody =>
      'L\'analyse s\'arrête et rien n\'est enregistré. Les articles déjà trouvés restent dans votre activité jusqu\'à ce que vous les effaciez.';

  @override
  String get batchKeepGoingAction => 'Continuer';

  @override
  String get batchTryAgainAction => 'Réessayer';

  @override
  String get batchBackToPhotosAction => 'Retour aux photos';

  @override
  String get batchSkipAllAction => 'Tout ignorer';

  @override
  String get batchIncludeAllAction => 'Tout inclure';

  @override
  String get batchNoPiecesFoundTitle => 'Aucune pièce trouvée';

  @override
  String get batchNoPiecesFoundBody => 'Aucun vêtement détecté sur ces photos.';

  @override
  String get batchChooseOtherPhotosAction => 'Choisir d\'autres photos';

  @override
  String get batchUseCaseHelper => 'Ajouté à chaque pièce enregistrée.';

  @override
  String get batchDiscardPiecesTitle => 'Ignorer ces pièces ?';

  @override
  String get batchDiscardPiecesBody => 'Rien de ce lot n\'est enregistré.';

  @override
  String get batchKeepAction => 'Conserver';

  @override
  String get batchDiscardAction => 'Ignorer';

  @override
  String get batchRemovePieceTitle => 'Supprimer cette pièce ?';

  @override
  String get batchRemovePieceBody =>
      'Elle n\'est pas enregistrée dans votre dressing.';

  @override
  String get batchRemoveAction => 'Supprimer';

  @override
  String get batchChoosePiecesToSave => 'Choisir les pièces à enregistrer';

  @override
  String get batchDiscardAllAction => 'Tout ignorer';

  @override
  String get batchNothingSavedRetryBody =>
      'Rien n\'a été enregistré. Réessayez.';

  @override
  String get batchNotSavedTitle => 'Non enregistré';

  @override
  String get batchSavingLabel => 'Enregistrement';

  @override
  String get batchSendToBackgroundAction => 'Mettre en arrière-plan';

  @override
  String get batchStillWorkingMessage =>
      'En cours. Nous vous avertirons dès que vos pièces seront prêtes.';

  @override
  String get batchRunningInBackgroundTitle => 'En arrière-plan';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Photos studio interrompues. Vous pouvez quand même enregistrer ces pièces.';

  @override
  String get batchTapPieceToSkip => 'Touchez une pièce pour l\'ignorer.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Photos studio en cours. Vous pouvez quitter, nous vous préviendrons.';

  @override
  String get batchLeaveAction => 'Quitter';

  @override
  String get batchPeopleInPhotosTitle => 'Personnes sur les photos';

  @override
  String get batchIncludeAction => 'Inclure';

  @override
  String get batchSkipAction => 'Ignorer';

  @override
  String get batchYourPhotoIsUsedLabel => 'Votre photo est utilisée';

  @override
  String get batchMakingStudioPhotoLabel => 'Création de la photo studio';

  @override
  String get batchNoStudioPhotoBody =>
      'Pas de photo studio. Votre photo est utilisée.';

  @override
  String get batchEnterDetailsYourselfAction => 'Saisir les détails';

  @override
  String get batchChooseAnotherPhotoAction => 'Choisir une autre photo';

  @override
  String get batchConnectionLostTitle => 'Connexion perdue';

  @override
  String get batchConnectionLostBody =>
      'Vérifiez votre connexion puis réessayez.';

  @override
  String get batchDailyLimitTitle => 'Limite quotidienne atteinte';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Passez à Pro pour plus de scans ou saisissez les détails vous-même.';

  @override
  String get batchDailyLimitBodyFree =>
      'Vos scans se réinitialisent demain. Vous pouvez saisir les détails vous-même.';

  @override
  String get batchSeePlansAction => 'Voir les abonnements';

  @override
  String get batchAiBusyTitle => 'Notre IA est occupée';

  @override
  String get batchAiBusyBody =>
      'C\'est de notre faute. Réessayez dans quelques minutes.';

  @override
  String get batchNoPiecesBody =>
      'Essayez une photo plus nette ou saisissez les détails vous-même.';

  @override
  String get batchScanningUnavailableTitle => 'Scan indisponible';

  @override
  String get batchScanningUnavailableBody =>
      'Saisissez les détails vous-même pour l\'instant.';

  @override
  String get batchScanDidNotFinishTitle => 'Le scan n\'a pas abouti';

  @override
  String get batchTryAgainBody => 'Réessayez.';

  @override
  String get billingTitle => 'Abonnement';

  @override
  String get billingUpgradeHeading => 'Mettre à niveau';

  @override
  String get billingUpgradeOnPlusBody =>
      'Mêmes fonctionnalités, limites supérieures.';

  @override
  String get billingUpgradeBody =>
      'Plus et Pro partagent les mêmes fonctions. Choisissez vos limites.';

  @override
  String get billingWebUnavailableBody =>
      'Les mises à niveau en ligne ne sont pas encore disponibles. Un code promo ou de parrainage débloque toujours Plus ou Pro. Invitez des amis ci-dessous pour gagner des mois gratuits.';

  @override
  String get billingPlansStale =>
      'Impossible de charger les derniers abonnements. Les prix peuvent être obsolètes.';

  @override
  String get billingMonthly => 'Mensuel';

  @override
  String get billingYearly => 'Annuel';

  @override
  String get billingCurrentPlan => 'Abonnement actuel';

  @override
  String get billingActive => 'Actif';

  @override
  String get billingThisMonth => 'Ce mois-ci';

  @override
  String get billingItemExtractions => 'Extractions d\'articles';

  @override
  String get billingOutfitVisualizations => 'Visualisations de tenues';

  @override
  String get billingNearLimitUpgrade =>
      'Vous approchez de la limite mensuelle. Mettez à niveau pour continuer.';

  @override
  String get billingNearLimitResets =>
      'Vous approchez de la limite mensuelle. Elle est réinitialisée au début du mois prochain.';

  @override
  String get billingStoreUnavailable =>
      'Les mises à niveau ne sont pas encore disponibles. Revenez bientôt.';

  @override
  String get billingManageHeading => 'Gérer votre abonnement';

  @override
  String get billingCancelPlan => 'Résilier l\'abonnement';

  @override
  String get billingCancelKeepsAccess =>
      'Vous conservez l\'accès jusqu\'à la fin de la période en cours.';

  @override
  String get billingCancelConfirmTitle => 'Résilier votre abonnement ?';

  @override
  String get billingKeepPlan => 'Conserver l\'abonnement';

  @override
  String get billingCancelPlanAction => 'Résilier';

  @override
  String get billingBilledMonthly => 'Facturation mensuelle';

  @override
  String get billingBilledYearly => 'Facturation annuelle';

  @override
  String get billingVirtualTryOn => 'Essai virtuel';

  @override
  String get billingPrioritySupport => 'Support prioritaire';

  @override
  String get billingDisclosureProRenewing =>
      'Pro est un abonnement à renouvellement automatique';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus et Pro sont des abonnements à renouvellement automatique';

  @override
  String get billingDisclosureAppleBilling =>
      'Le paiement est prélevé sur votre identifiant Apple lors de la confirmation d\'achat.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Le paiement est prélevé sur votre compte Google Play lors de la confirmation d\'achat.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Votre abonnement se renouvelle automatiquement pour la même durée et au même prix, sauf si vous désactivez le renouvellement automatique au moins 24 heures avant la fin de la période en cours.';

  @override
  String get billingDisclosureAppleManage =>
      'Gérez ou résiliez à tout moment dans Réglages › votre identifiant Apple › Abonnements.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gérez ou résiliez à tout moment dans Google Play › Paiements et abonnements.';

  @override
  String get billingReferFriend => 'Parrainer un ami';

  @override
  String get billingHowItWorks => 'Comment ça marche';

  @override
  String get billingHowShareTitle => 'Partagez votre lien';

  @override
  String get billingHowShareBody => 'Envoyez-le à un ami.';

  @override
  String get billingHowSignUpTitle => 'Il s\'inscrit';

  @override
  String get billingHowSignUpBody => 'Votre ami s\'inscrit via le lien.';

  @override
  String get billingHowBothTitle => 'Vous obtenez tous les deux Pro';

  @override
  String get billingHowBothBody =>
      'Chacun de vous reçoit un mois de Pro gratuit.';

  @override
  String get billingYourReferrals => 'Vos parrainages';

  @override
  String get billingInvited => 'Invité';

  @override
  String get billingJoined => 'Inscrit';

  @override
  String get billingMonthsEarned => 'Mois gagnés';

  @override
  String get billingInviteFriend => 'Inviter un ami';

  @override
  String get billingInviteBody => 'Vous et votre ami gagnez un mois de Pro.';

  @override
  String get billingYourCode => 'Votre code';

  @override
  String get billingCopyLink => 'Copier le lien';

  @override
  String get billingShareInvite => 'Partager l\'invitation';

  @override
  String get giftUnavailable =>
      'Les invitations cadeaux ne sont pas disponibles dans cette version.';

  @override
  String get giftPageTitle => 'Offrir FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Aucune invitation cadeau gratuite disponible pour le moment.';

  @override
  String get giftFormTitle => 'Envoyer une invitation gratuite';

  @override
  String get giftFormBody =>
      'Le destinataire réclame le cadeau avec cet e-mail vérifié. Nous n\'envoyons pas l\'e-mail à votre place.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nom du destinataire';

  @override
  String get giftFieldRecipientEmail => 'E-mail du destinataire';

  @override
  String get giftFieldOccasion => 'Occasion (optionnel)';

  @override
  String get giftNoOccasion => 'Aucune occasion';

  @override
  String get giftOccasionBirthday => 'Anniversaire';

  @override
  String get giftOccasionAnniversary => 'Fête';

  @override
  String get giftOccasionOther => 'Autre';

  @override
  String get giftFieldCardGreeting => 'Message de la carte';

  @override
  String get giftFieldCardGreetingHelper =>
      'Ceci apparaît sur la carte tel quel.';

  @override
  String get giftFieldPrivateNote => 'Note privée (optionnel)';

  @override
  String get giftCreateAction => 'Créer le cadeau gratuit';

  @override
  String get giftClaimedTitle => 'Cadeau réclamé';

  @override
  String get giftClaimedActive => 'Votre cadeau FitCheck Pro est actif.';

  @override
  String get giftClaimedQueued =>
      'Votre cadeau FitCheck Pro commencera après votre accès actuel.';

  @override
  String get giftLinkCopied => 'Lien du cadeau copié dans le presse-papiers.';

  @override
  String get giftErrorName => 'Entrez un nom.';

  @override
  String get giftErrorEmail => 'Entrez une adresse e-mail valide.';

  @override
  String get giftErrorGreeting => 'Entrez le message de la carte.';

  @override
  String get giftErrorGreetingLength => 'Utilisez 80 caractères maximum.';

  @override
  String get giftClaimAction => 'Réclamer le cadeau';

  @override
  String get giftCardPreview => 'Aperçu de la carte';

  @override
  String get giftGiftForYou => 'Un cadeau pour vous';

  @override
  String get giftGiftWaiting => 'Un cadeau vous attend';

  @override
  String get giftOpenBody =>
      'Ouvrez vos cadeaux pour les réclamer avec votre e-mail vérifié.';

  @override
  String get giftOpenGifts => 'Ouvrir les cadeaux';

  @override
  String get giftSendInvitation => 'Envoyer l\'invitation';

  @override
  String get settingsAiProviderSection => 'Fournisseur';

  @override
  String get settingsAiCustom => 'Personnalisé';

  @override
  String get settingsAiUrlHelper =>
      'Utilisez une URL publique accessible par le serveur. Localhost ne fonctionne pas depuis nos serveurs.';

  @override
  String get settingsAiConnectionSection => 'Connexion';

  @override
  String get settingsAiApiUrl => 'URL de l\'API';

  @override
  String get settingsAiApiKey => 'Clé API';

  @override
  String get settingsAiApiKeySaved =>
      'Enregistré. Laissez vide pour conserver.';

  @override
  String get settingsAiChatModel => 'Modèle de chat';

  @override
  String get settingsAiVisionModel => 'Modèle de vision (optionnel)';

  @override
  String get settingsAiImageModel => 'Modèle d\'image (optionnel)';

  @override
  String get settingsAiImageModelNote =>
      'La génération d\'images nécessite des complations de chat compatibles OpenAI avec response_modalities.';

  @override
  String get settingsAiTestConnection => 'Tester la connexion';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarGoToToday => 'Aujourd\'hui';

  @override
  String get calendarConnectTooltip => 'Connecter un calendrier';

  @override
  String get calendarAddEvent => 'Ajouter un événement';

  @override
  String get calendarEmptyTitle => 'Rien de prévu';

  @override
  String get calendarEmptyBody =>
      'Ajoutez un événement et prévoyez votre tenue.';

  @override
  String get calendarPreviousMonth => 'Mois précédent';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarAllDay => 'Toute la journée';

  @override
  String get calendarOutfitLinked => 'Tenue associée';

  @override
  String get calendarEventOptions => 'Options de l\'événement';

  @override
  String get calendarDeleteTitle => 'Supprimer cet événement ?';

  @override
  String get calendarChangeOutfit => 'Changer de tenue';

  @override
  String get calendarLinkOutfit => 'Associer une tenue';

  @override
  String get calendarRemoveOutfit => 'Retirer la tenue';

  @override
  String get calendarNewEvent => 'Nouvel événement';

  @override
  String get calendarEditEvent => 'Modifier l\'événement';

  @override
  String get calendarTitleLabel => 'Titre';

  @override
  String get calendarTitleRequired => 'Ajouter un titre';

  @override
  String get calendarEndBeforeStart => 'Fin après le début';

  @override
  String get calendarStarts => 'Début';

  @override
  String get calendarEnds => 'Fin';

  @override
  String get calendarPlaceOptional => 'Lieu (facultatif)';

  @override
  String get calendarNotesOptional => 'Notes (facultatif)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Créez une tenue, puis associez-la à cet événement.';

  @override
  String get calendarBuildOutfit => 'Créer une tenue';

  @override
  String get calendarConnectionsTitle => 'Calendriers';

  @override
  String get calendarConnectionsBody =>
      'Les événements ajoutés ici restent dans FitCheck AI.';

  @override
  String get calendarDisconnect => 'Déconnecter';

  @override
  String get calendarNotAvailable => 'Bientôt disponible';

  @override
  String get profileSectionExplore => 'Explorer';

  @override
  String get profileNavTryOn => 'Essayage';

  @override
  String get profileNavRewards => 'Récompenses';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileAbout => 'À propos';

  @override
  String get profileAboutBody =>
      'Votre dressing, vos tenues et vos abonnements au même endroit.';

  @override
  String get profileSignOutTitle => 'Se déconnecter ?';

  @override
  String get profileSignOutBody =>
      'Vous pourrez vous reconnecter à tout moment.';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get profileYourProfile => 'Votre profil';

  @override
  String get profileBodyProfiles => 'Profils corporels';

  @override
  String get profileBodyEmptyTitle => 'Aucun profil corporel';

  @override
  String get profileBodyEmptyBody =>
      'Ajoutez votre taille et votre morphologie pour une meilleure coupe.';

  @override
  String get profileBodyAdd => 'Ajouter un profil';

  @override
  String get profileBodyDefaultNote =>
      'Votre profil par défaut est utilisé pour la coupe et l\'essayage.';

  @override
  String get profileBodyDefaultBadge => 'Par défaut';

  @override
  String get profileBodyMakeDefault => 'Définir par défaut';

  @override
  String get profileBodyDeleteBody => 'Cette action est irréversible.';

  @override
  String get profileBodyRequired => 'Obligatoire';

  @override
  String get profileBodyCheckNumber => 'Vérifiez ce nombre';

  @override
  String get profileBodyNew => 'Nouveau profil corporel';

  @override
  String get profileBodyNameHint => 'Par exemple, Moi';

  @override
  String get profileBodyHeight => 'Taille';

  @override
  String get profileBodyWeight => 'Poids';

  @override
  String get profileBodyBuild => 'Morphologie';

  @override
  String get profileBodySkinTone => 'Teint de peau';

  @override
  String get profileBirthDateNeededBody =>
      'Ajoutez une date de naissance avec l\'heure de naissance.';

  @override
  String get profileBirthDateNeededTitle => 'Date de naissance requise';

  @override
  String get profilePartlySavedBody =>
      'Votre nom et votre photo ont été enregistrés. Les détails de naissance n\'ont pas pu être enregistrés ; réessayez plus tard.';

  @override
  String get profilePartlySavedTitle => 'Enregistré partiellement';

  @override
  String get profileSavedBody => 'Votre profil est enregistré.';

  @override
  String get profileChangePhoto => 'Changer la photo de profil';

  @override
  String get profilePhotoLabel => 'Photo de profil';

  @override
  String get profilePhotoHint => 'Appuyez pour en choisir une nouvelle';

  @override
  String get profileBirthDateLabel => 'Date de naissance (optionnel)';

  @override
  String get profileBirthTimeLabel => 'Heure de naissance (optionnel)';

  @override
  String get profileBirthTimeHelper =>
      'Rend les suggestions védiques plus précises';

  @override
  String get profileBirthPlaceLabel => 'Lieu de naissance (optionnel)';

  @override
  String get profileBirthPlaceHint => 'Par exemple, Paris, France';

  @override
  String get profileHelpContactTitle => 'Posez-nous vos questions';

  @override
  String get profileHelpContactBody =>
      'Envoyez-nous un message, nous répondons par e-mail, généralement sous 24 heures.';

  @override
  String get profileHelpContactAction => 'Contacter le support';

  @override
  String get profileHelpFaqTitle => 'Questions fréquentes';

  @override
  String get profileFaqAddPiecesTitle =>
      'Comment ajouter des pièces à mon armoire ?';

  @override
  String get profileFaqAddPiecesBody =>
      'Appuyez sur Ajouter dans l\'onglet Armoire. Prenez une photo ou choisissez-en une dans votre galerie ; nous détectons chaque pièce et l\'étiquetons pour vous.';

  @override
  String get profileFaqMatchingTitle =>
      'Comment fonctionnent les associations de tenues ?';

  @override
  String get profileFaqMatchingBody =>
      'Ouvrez Pour vous et sélectionnez vos pièces. Nous vous suggérons des accords et composons des tenues complètes avec votre armoire.';

  @override
  String get profileFaqTryOnTitle =>
      'Puis-je utiliser mes propres photos pour l\'essayage ?';

  @override
  String get profileFaqTryOnBody =>
      'Oui. Ajoutez une photo de vous en pied, puis choisissez des pièces pour les voir portées.';

  @override
  String get profileFaqRewardsTitle => 'Comment gagner des récompenses ?';

  @override
  String get profileFaqRewardsBody =>
      'Planifiez et enregistrez vos tenues régulièrement. Les séries et les réussites progressent au fil du temps.';

  @override
  String get profileFaqPrivacyTitle => 'Mon armoire est-elle privée ?';

  @override
  String get profileFaqPrivacyBody =>
      'Oui. Votre armoire et vos tenues sont privées, sauf si vous partagez le lien d\'une tenue.';

  @override
  String get profileHelpMoreTitle => 'Plus d\'aide';

  @override
  String get profileHelpGuides => 'Guides';

  @override
  String get profileHelpGuidesBody => 'Fonctionnement de chaque outil';

  @override
  String get feedbackCategoryBug => 'Un problème';

  @override
  String get feedbackCategoryIdea => 'Une idée';

  @override
  String get feedbackCategoryGeneral => 'Général';

  @override
  String get feedbackCategoryHelp => 'Besoin d\'aide';

  @override
  String get feedbackHintBug =>
      'Que s\'est-il passé et qu\'attendiez-vous ? Les étapes nous aident à corriger le souci.';

  @override
  String get feedbackHintIdea => 'Que aimeriez-vous et pourquoi ?';

  @override
  String get feedbackHintGeneral =>
      'Donnez-nous votre avis ou posez une question.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Vous pouvez ajouter jusqu\'à 5 images.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limite atteinte';

  @override
  String get feedbackImageTooLargeBody =>
      'Choisissez une image de moins de 5 Mo.';

  @override
  String get feedbackImageTooLargeTitle => 'Image trop volumineuse';

  @override
  String get feedbackTitle => 'Envoyer un avis';

  @override
  String get feedbackAboutLabel => 'Quel est le sujet ?';

  @override
  String get feedbackSubjectLabel => 'Objet';

  @override
  String get feedbackSubjectRequired => 'Ajouter un objet';

  @override
  String get feedbackSubjectTooShort =>
      'L\'objet doit contenir au moins 3 caractères';

  @override
  String get feedbackDetailsLabel => 'Détails';

  @override
  String get feedbackDetailsRequired => 'Ajouter des détails';

  @override
  String get feedbackDetailsTooShort =>
      'La description doit contenir au moins 10 caractères';

  @override
  String get feedbackAddScreenshot => 'Ajouter une capture d\'écran';

  @override
  String get feedbackAttachmentHint => 'Jusqu\'à 5, 5 Mo max chacune';

  @override
  String get feedbackSend => 'Envoyer';

  @override
  String get feedbackEmptyTitle => 'Aucun envoi pour le moment';

  @override
  String get feedbackEmptyBody =>
      'Vos envois et leur statut s\'afficheront ici.';

  @override
  String get feedbackHistoryTitle => 'Vos envois';

  @override
  String get feedbackStatusOpen => 'Ouvert';

  @override
  String get feedbackStatusInProgress => 'En cours';

  @override
  String get feedbackStatusResolved => 'Résolu';

  @override
  String get feedbackStatusClosed => 'Fermé';

  @override
  String get legalIntro =>
      'Comment nous protégeons vos données et les conditions d\'utilisation de FitCheck AI.';

  @override
  String get legalPolicies => 'Politiques';

  @override
  String get legalPrivacySubtitle => 'Ce que nous collectons et pourquoi';

  @override
  String get legalTermsTitle => 'Conditions d\'utilisation';

  @override
  String get legalTermsSubtitle =>
      'Les règles d\'utilisation de l\'application';

  @override
  String get legalLicences => 'Licences open source';

  @override
  String get legalSupportSubtitle =>
      'Aide, contact et demandes relatives aux données';

  @override
  String get legalReportAbuse => 'Signaler un problème ou un abus';

  @override
  String get permissionCameraTitle => 'Accès à la caméra';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI utilise votre caméra pour prendre en photo vos vêtements et tenues pour l\'essayage virtuel et l\'organisation du dressing.';

  @override
  String get permissionPhotoTitle => 'Accès aux photos';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI a besoin d\'accéder à vos photos pour vous permettre de sélectionner des images de vêtements et de tenues.';

  @override
  String get permissionNotNow => 'Pas maintenant';

  @override
  String get permissionOpenSettings => 'Ouvrir les réglages';

  @override
  String authSignedInAs(String name) {
    return 'Connecté en tant que $name';
  }

  @override
  String get authSignedIn => 'Connecté';

  @override
  String get authWelcomeBackTitle => 'Bon retour';

  @override
  String get authSignInFailed => 'Échec de la connexion';

  @override
  String get authWelcomeTitle => 'Bienvenue';

  @override
  String get authSignUpFailed => 'Échec de l\'inscription';

  @override
  String get authGoogleSignInFailed => 'Échec de la connexion Google';

  @override
  String get authAppleSignInFailed => 'Échec de la connexion Apple';

  @override
  String get authConfirmEmailTitle => 'Confirmez votre e-mail';

  @override
  String get authConfirmEmailBody =>
      'Vérifiez votre boîte de réception pour un e-mail de confirmation, puis connectez-vous.';

  @override
  String get authClosetReady => 'Votre dressing est prêt.';

  @override
  String get authSignedOutTitle => 'Déconnecté';

  @override
  String get authSignedOutBody => 'Vous êtes déconnecté.';

  @override
  String get authSignOutFailed => 'Échec de la déconnexion';

  @override
  String get authEmailSentTitle => 'E-mail envoyé';

  @override
  String get authResetLinkSent =>
      'Vérifiez vos e-mails pour le lien de réinitialisation.';

  @override
  String get authPasswordUpdatedTitle => 'Mot de passe mis à jour';

  @override
  String get authPasswordUpdated => 'Votre mot de passe a été mis à jour.';

  @override
  String get authPasswordNotUpdated => 'Mot de passe non mis à jour';

  @override
  String get authCouldNotSendEmail => 'Impossible d\'envoyer l\'e-mail';

  @override
  String get authEmailNotSent => 'E-mail non envoyé';

  @override
  String get authResendSentBody =>
      'Nous avons envoyé un nouvel e-mail de confirmation.';

  @override
  String get outfitPreviewWithAi => 'Aperçu IA';

  @override
  String get outfitNewPreview => 'Nouvel aperçu';

  @override
  String get outfitBuilderClosetHeading => 'Votre garde-robe';

  @override
  String get outfitBuilderSearchHint => 'Chercher des pièces';

  @override
  String get outfitClearSearch => 'Effacer la recherche';

  @override
  String get outfitBuilderAddPiecesTitle => 'Ajoutez des pièces';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Les tenues sont composées des pièces de votre garde-robe.';

  @override
  String get outfitBuilderNoMatches => 'Aucune pièce correspondante.';

  @override
  String get outfitNameLabel => 'Nom de la tenue';

  @override
  String get outfitNameHint => 'Par exemple, Lin week-end';

  @override
  String get outfitPreviewSemantic => 'Aperçu IA de la tenue';

  @override
  String get outfitChoosePieces => 'Choisir des pièces';

  @override
  String get outfitTapPiecesHint =>
      'Touchez les pièces ci-dessous pour les ajouter.';

  @override
  String get outfitShareTooltip => 'Partager';

  @override
  String get outfitSaveFavourite => 'Ajouter aux favoris';

  @override
  String get outfitPiecesHeading => 'Pièces';

  @override
  String get outfitWearHistoryEmpty =>
      'Portez-la une fois et les dates apparaîtront ici.';

  @override
  String get outfitWearHistoryTitle => 'Historique de port';

  @override
  String get outfitWearHistoryError => 'Impossible de charger les dates.';

  @override
  String get outfitWornOn => 'Portée le';

  @override
  String get outfitEditTitle => 'Modifier la tenue';

  @override
  String get outfitSavedPhotosFailed => 'Détails enregistrés, pas les photos';

  @override
  String get outfitNoPhotosBody =>
      'Aucune photo. La tenue affiche ses pièces à la place.';

  @override
  String get outfitOccasionLabel => 'Occasion';

  @override
  String get outfitOccasionNone => 'Aucune';

  @override
  String get outfitTagsHint => 'Séparez par des virgules';

  @override
  String get outfitDraftBody => 'Masquée de votre liste principale';

  @override
  String get outfitPublic => 'Public';

  @override
  String get outfitPublicBody => 'Toute personne ayant le lien peut la voir';

  @override
  String get outfitDeleteFromDetail =>
      'Supprimez cette tenue de sa page de détail.';

  @override
  String get outfitNewCollection => 'Nouvelle collection';

  @override
  String get outfitNoCollectionsTitle => 'Aucune collection';

  @override
  String get outfitNoCollectionsBody =>
      'Regroupez les tenues par voyage, saison ou humeur.';

  @override
  String get outfitCreateCollection => 'Créer une collection';

  @override
  String get outfitAddOutfits => 'Ajouter des tenues';

  @override
  String get outfitRename => 'Renommer';

  @override
  String get outfitCollectionDeleteBody => 'Les tenues sont conservées.';

  @override
  String get outfitCollectionsNotLoaded => 'Tenues non chargées';

  @override
  String get outfitRenameCollection => 'Renommer la collection';

  @override
  String get outfitDescriptionOptional => 'Description (facultatif)';

  @override
  String get outfitAllInCollection =>
      'Toutes les tenues sont déjà dans cette collection.';

  @override
  String get photoshootSubtitleUpload => 'Portraits studio depuis vos photos';

  @override
  String get photoshootSubtitleConfigure =>
      'Choisissez un style, un format et un nombre';

  @override
  String get photoshootSubtitleGenerating => 'Cela prendra une ou deux minutes';

  @override
  String get photoshootAddPhotosSemantic =>
      'Ajouter des photos depuis la galerie';

  @override
  String get photoshootUploadTitle => 'Ajoutez de 1 à 4 photos de vous-même';

  @override
  String get photoshootUploadBody => 'Appuyez pour choisir dans la galerie';

  @override
  String get photoshootAddToContinue => 'Ajoutez une photo pour continuer';

  @override
  String get photoshootAddAnotherPhoto => 'Ajouter une autre photo';

  @override
  String get photoshootTipsTitle => 'Pour de meilleurs résultats';

  @override
  String get photoshootTipsBody =>
      'Utilisez des photos claires et bien éclairées de votre visage sous plusieurs angles. Évitez les lunettes de soleil et les chapeaux.';

  @override
  String get photoshootStarting => 'Démarrage';

  @override
  String get photoshootCancelling => 'Annulation';

  @override
  String get photoshootFailed => 'Échec';

  @override
  String get recommendTabMatches => 'Correspondances';

  @override
  String get recommendTabComplete => 'Compléter';

  @override
  String get recommendTabWeather => 'Météo';

  @override
  String get recommendTabColours => 'Couleurs';

  @override
  String get recommendTabShop => 'Boutique';

  @override
  String get recommendNoMatchesTitle => 'Aucune correspondance';

  @override
  String get recommendNoMatchesBody =>
      'Choisissez un article et nous trouverons ce qui va avec.';

  @override
  String get recommendPickPiece => 'Choisir un article';

  @override
  String get recommendNothingMatchesTitle => 'Rien ne correspond encore';

  @override
  String get recommendNothingMatchesBody =>
      'Essayez d\'autres articles ou ajoutez-en à votre placard.';

  @override
  String get recommendChangePieces => 'Changer d\'articles';

  @override
  String get recommendDefaultReason => 'Ça va avec les articles choisis.';

  @override
  String get recommendCompleteTitle => 'Compléter la tenue';

  @override
  String get recommendCompleteBody =>
      'Choisissez un article et nous complèterons le reste.';

  @override
  String get recommendWorking => 'Traitement';

  @override
  String get recommendGenerate => 'Générer';

  @override
  String get recommendChooseStyleBody => 'Choisissez un style, puis générez.';

  @override
  String get recommendNoLooksTitle => 'Aucune tenue pour ces articles';

  @override
  String get recommendNoLooksBody =>
      'Essayez un autre style ou d\'autres articles.';

  @override
  String get recommendDefaultLook => 'Une tenue pour vos articles';

  @override
  String get recommendNoPiecesBody => 'Aucun article trouvé pour cette tenue.';

  @override
  String get recommendCityLabel => 'Ville';

  @override
  String get recommendCheck => 'Vérifier';

  @override
  String get recommendWeatherTitle => 'Quel temps fait-il ?';

  @override
  String get recommendWeatherBody =>
      'Saisissez votre ville pour recevoir des suggestions du jour.';

  @override
  String get recommendWearToday => 'Porter aujourd\'hui';

  @override
  String get recommendWeatherNoPieces =>
      'Aucun article dans votre placard pour ce temps.';

  @override
  String get recommendBudgetLabel => 'Budget jusqu\'à';

  @override
  String get recommendLooking => 'Recherche';

  @override
  String get recommendFindWhatToBuy => 'Trouver quoi acheter';

  @override
  String get recommendFillGapsTitle => 'Combler les manques';

  @override
  String get recommendFillGapsBody =>
      'Fixez un budget et nous suggérerons ce qu\'il manque à votre placard.';

  @override
  String get recommendNoGapsTitle => 'Aucun manque trouvé';

  @override
  String get recommendNoGapsBody =>
      'Essayez un budget plus élevé ou une autre catégorie.';

  @override
  String get recommendMoodEveryday => 'Quotidien';

  @override
  String get recommendMoodBigMeeting => 'Grande réunion';

  @override
  String get recommendDayLabel => 'Journée';

  @override
  String get recommendReadingStars => 'Lecture des astres';

  @override
  String get recommendGetMyColours => 'Mes couleurs';

  @override
  String get recommendLuckyColoursTitle => 'Vos couleurs porte-bonheur';

  @override
  String get recommendLuckyColoursBody =>
      'Choisissez une journée, nous vous suggérerons des couleurs et des pièces.';

  @override
  String get recommendLuckyColoursSection => 'Couleurs porte-bonheur';

  @override
  String get recommendAvoidColoursSection => 'Couleurs à éviter';

  @override
  String get recommendBirthDateTitle => 'Ajoutez votre date de naissance';

  @override
  String get recommendBirthDateBody =>
      'Votre date de naissance est requise pour analyser vos couleurs.';

  @override
  String get recommendEditProfile => 'Modifier le profil';

  @override
  String get recommendNothingThisDay => 'Rien pour cette journée.';

  @override
  String get recommendUnnamedColour => 'Couleur sans nom';

  @override
  String get recommendFromCloset => 'Depuis votre garde-robe';

  @override
  String get recommendNoPiecesInColours => 'Aucune pièce dans ces couleurs.';

  @override
  String get recommendOutfitIdeas => 'Idées de tenues';

  @override
  String get recommendNoOutfitsInColours =>
      'Aucune tenue complète dans ces couleurs.';

  @override
  String get recommendDefaultOutfitIdea => 'Idée de tenue';

  @override
  String get recommendPickUpToThree => 'Choisissez jusqu\'à 3 pièces';

  @override
  String get recommendEmptyClosetBody =>
      'Ajoutez quelques pièces, puis revenez pour des correspondances.';

  @override
  String get dashboardDressForDay => 'S\'habiller pour la journée.';

  @override
  String get dashboardOutfitOfDay => 'Tenue du jour';

  @override
  String get dashboardFreshLook => 'Un nouveau look';

  @override
  String get subscriptionManageInStoreTitle => 'Gérer dans le magasin';

  @override
  String get subscriptionManageInStoreBody =>
      'Cet abonnement est facturé via le magasin. Gérez-le dans les paramètres de votre compte.';

  @override
  String get subscriptionCancelledTitle => 'Abonnement annulé';

  @override
  String get subscriptionCancelledBody =>
      'Votre plan reste actif jusqu\'à la fin de la période de facturation.';

  @override
  String get subscriptionCancelFailedTitle => 'Annulation impossible';

  @override
  String get subscriptionCouldNotOpenTitle => 'Ouverture impossible';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Impossible d\'ouvrir la gestion de la facturation.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Impossible d\'ouvrir le lien.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Impossible de charger votre lien';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Impossible de charger votre lien de parrainage. Réessayez.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copié';

  @override
  String get subscriptionReferralCopiedBody => 'Lien de parrainage copié.';

  @override
  String get subscriptionReferralShareSubject => 'Essayez FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Rejoignez FitCheck AI et nous recevons chacun un mois de Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Lien copié';

  @override
  String get subscriptionShareUnavailableBody =>
      'Le partage n\'est pas disponible. Le lien a donc été copié.';

  @override
  String get subscriptionShareFailedTitle => 'Impossible de partager';

  @override
  String get subscriptionShareFailedBody =>
      'Copiez le lien depuis la page de parrainage.';

  @override
  String get subscriptionStoreReadyTitle => 'Boutique prête';

  @override
  String get subscriptionStoreReadyBody =>
      'Les prix de la boutique sont disponibles. Vous pouvez mettre à niveau maintenant.';

  @override
  String get purchaseFailedTitle => 'Échec de l\'achat';

  @override
  String get purchaseUnavailableTitle => 'Achat indisponible';

  @override
  String get purchaseIapUnavailableBody =>
      'Les achats dans l\'application ne sont pas disponibles sur cet appareil.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Cette offre n\'est pas encore disponible à l\'achat.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Cette offre n\'est pas encore disponible dans la boutique. Réessayez bientôt.';

  @override
  String get purchaseStartFailedBody =>
      'L\'achat n\'a pas pu démarrer. Réessayez.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'Le paiement n\'a pas renvoyé de lien de paiement.';

  @override
  String get purchasePendingTitle => 'Achat en attente';

  @override
  String get purchasePendingBody =>
      'Votre achat est en attente d\'approbation. Vous y aurez accès dès son validation.';

  @override
  String get purchaseFailedBody => 'L\'achat a échoué. Réessayez.';

  @override
  String get purchaseRestoredTitle => 'Restauré';

  @override
  String get purchaseRestoredBody => 'Vos achats ont été restaurés.';

  @override
  String get purchaseActiveTitle => 'Abonnement actif';

  @override
  String get purchaseActiveBody => 'Votre abonnement est actif. Bienvenue.';

  @override
  String get purchaseSignInRequiredTitle => 'Connexion requise';

  @override
  String get purchaseSignInRequiredBody =>
      'Connectez-vous pour finaliser votre achat.';

  @override
  String get purchaseErrorTitle => 'Erreur d\'achat';

  @override
  String get purchaseInvalidTransactionBody =>
      'L\'achat ne contient pas d\'identifiant de transaction vérifiable.';

  @override
  String get purchaseVerificationPendingTitle => 'Vérification en attente';

  @override
  String get purchaseVerificationPendingBody =>
      'Impossible de vérifier votre achat pour l\'instant. Le processus se terminera automatiquement et vous ne serez pas facturé deux fois.';

  @override
  String get purchaseNotAppliedTitle => 'Achat non appliqué';

  @override
  String get purchaseNotAppliedBody =>
      'Votre achat n\'a pas pu être appliqué à votre compte. Contactez l\'assistance et n\'achetez pas à nouveau.';

  @override
  String get purchaseRestoreFailedTitle => 'Échec de la restauration';

  @override
  String get purchaseRestoreFailedBody =>
      'Impossible de restaurer les achats. Réessayez.';

  @override
  String get purchaseRecoveredActiveBody => 'Votre abonnement est actif.';

  @override
  String get purchaseCompleteTitle => 'Acheté terminé';

  @override
  String get giftCreateFailedTitle => 'Impossible de créer le cadeau';

  @override
  String get giftClaimFailedTitle => 'Impossible de réclamer le cadeau';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cadeaux pour vous',
      one: 'Un cadeau pour vous',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mois',
      '12': '1 an',
      'other': '$months mois',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining restants',
      one: '1 restant',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration de FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender vous a envoyé $duration de FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Un cadeau FitCheck Pro pour $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'De $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Pour $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'De $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'votre destinataire';

  @override
  String get giftPreviewPlaceholderSender => 'vous';

  @override
  String get settingsSavedTitle => 'Enregistré';

  @override
  String get settingsNotSavedTitle => 'Non enregistré';

  @override
  String get settingsAiChooseProviderBody => 'Choisissez un fournisseur.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Un fournisseur personnalisé nécessite une URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Saisissez une clé API.';

  @override
  String get settingsAiSavedBody => 'Vos paramètres IA sont enregistrés.';

  @override
  String get settingsAiMissingDetailsTitle => 'Détails manquants';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Saisissez une URL API et un modèle de discussion pour tester.';

  @override
  String get settingsAiKeyNeededTitle => 'Clé API requise';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Saisissez votre clé API pour tester. Votre clé reste privée.';

  @override
  String get settingsAiKeyToTestBody => 'Saisissez votre clé API pour tester.';

  @override
  String get settingsAiConnectedTitle => 'Connecté';

  @override
  String get settingsAiConnectedBody => 'La connexion fonctionne.';

  @override
  String get settingsAiTestFailedTitle => 'Échec du test';

  @override
  String get settingsPreferencesSavedBody =>
      'Vos préférences sont enregistrées.';

  @override
  String get settingsPasswordNotChangedTitle => 'Mot de passe non modifié';

  @override
  String get settingsOAuthPasswordBody =>
      'Ce compte se connecte via Google ou Apple. Utilisez \"Mot de passe oublié\" pour en définir un d\'abord.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Le mot de passe actuel est incorrect.';

  @override
  String get settingsExportReadyTitle => 'Export prêt';

  @override
  String get settingsExportReadyBody =>
      'Votre export de données est prêt à télécharger.';

  @override
  String get settingsLinkCopiedTitle => 'Lien copié';

  @override
  String get settingsExportClipboardBody =>
      'Impossible d\'ouvrir votre navigateur, le lien de téléchargement a été copié. Collez-le dans un navigateur rapidement : il expire.';

  @override
  String get settingsExportFailedTitle => 'Échec de l\'export';

  @override
  String get settingsAccountNotDeletedTitle => 'Compte non supprimé';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Vous pouvez ajouter jusqu\'à $max photos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limite de photos';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Ajoutez au moins une photo.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Aucune photo';

  @override
  String get photoshootDescribeLookBody => 'Décrivez le look souhaité.';

  @override
  String get photoshootPromptNeededTitle => 'Description requise';

  @override
  String get photoshootConsentFeatureLabel => 'Photoshoot IA';

  @override
  String get photoshootStatusPreparing => 'Préparation de vos photos';

  @override
  String get photoshootStatusGenerating => 'Génération';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lot $current sur $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done sur $total terminés';
  }

  @override
  String get photoshootGenerationFailedBody => 'Échec de la génération.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready prêts, $failed échoués.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Partiellement terminé';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos sont prêtes.',
      one: '1 photo est prête.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'La connexion a été perdue. Veuillez réessayer.';

  @override
  String get photoshootCouldNotCancelTitle => 'Annulation impossible';

  @override
  String get photoshootRetryFailedTitle => 'Échec de la nouvelle tentative';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'La photo $number est prête.';
  }

  @override
  String get photoshootReplacedTitle => 'Remplacée';

  @override
  String get photoshootSavedToGalleryBody => 'Enregistrée dans votre galerie.';

  @override
  String get photoshootSavedTitle => 'Enregistrée';

  @override
  String get photoshootNotSavedTitle => 'Non enregistrée';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count photos sont dans votre galerie.',
      one: '1 photo est dans votre galerie.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved sur $total enregistrées.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Certaines photos non enregistrées';

  @override
  String get tryonConsentFeatureLabel => 'Essayage virtuel';

  @override
  String get tryonAvatarUpdatedBody => 'Votre photo a été mise à jour.';

  @override
  String get tryonSavedTitle => 'Enregistré';

  @override
  String get tryonUploadFailedTitle => 'Échec de l’envoi';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Choisissez d’abord une photo de vêtement.';

  @override
  String get tryonNoGarmentTitle => 'Aucun vêtement';

  @override
  String get tryonWaitForUploadBody =>
      'Attendez la fin de l’envoi de votre photo.';

  @override
  String get tryonStillUploadingTitle => 'Envoi en cours';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Ajoutez d’abord une photo de vous-même.';

  @override
  String get tryonReadyBody => 'Votre essayage est prêt.';

  @override
  String get tryonFailedTitle => 'Échec de l’essayage';

  @override
  String get tryonSavedToGalleryBody => 'Enregistré dans votre galerie.';

  @override
  String get tryonNotSavedTitle => 'Non enregistré';

  @override
  String get calendarEventAddedBody => 'Événement ajouté';

  @override
  String get calendarEventPlannedTitle => 'Planifié';

  @override
  String get calendarEventSavedBody => 'Événement enregistré';

  @override
  String get calendarSavedTitle => 'Enregistré';

  @override
  String get calendarEventNotSavedTitle => 'Événement non enregistré';

  @override
  String get calendarEventRemovedBody => 'Événement supprimé';

  @override
  String get calendarEventDeletedTitle => 'Supprimé';

  @override
  String get calendarEventNotDeletedTitle => 'Événement non supprimé';

  @override
  String get calendarOutfitNotLinkedTitle => 'Tenue non liée';

  @override
  String get calendarLinkedTitle => 'Lié';

  @override
  String get calendarOutfitNotRemovedTitle => 'Tenue non supprimée';

  @override
  String get calendarOutfitRemovedBody => 'Tenue supprimée';

  @override
  String get calendarDisconnectedBody => 'Calendrier déconnecté';

  @override
  String get calendarDisconnectedTitle => 'Déconnecté';

  @override
  String get calendarNotDisconnectedTitle => 'Calendrier non déconnecté';

  @override
  String get calendarTodayLabel => 'aujourd\'hui';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements',
      one: '1 événement',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'de $start à $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, tenue liée';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '« $title » sera supprimé.';
  }

  @override
  String get calendarThisAppLabel => 'Cette app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'La synchronisation avec $provider n\'est pas encore disponible. Vous pouvez tout de même ajouter des événements ici.';
  }

  @override
  String get calendarWeekdaySunShort => 'dim.';

  @override
  String get calendarWeekdayMonShort => 'lun.';

  @override
  String get calendarWeekdayTueShort => 'mar.';

  @override
  String get calendarWeekdayWedShort => 'mer.';

  @override
  String get calendarWeekdayThuShort => 'jeu.';

  @override
  String get calendarWeekdayFriShort => 'ven.';

  @override
  String get calendarWeekdaySatShort => 'sam.';

  @override
  String get calendarWeekdayMonday => 'Lundi';

  @override
  String get calendarWeekdayTuesday => 'Mardi';

  @override
  String get calendarWeekdayWednesday => 'Mercredi';

  @override
  String get calendarWeekdayThursday => 'Jeudi';

  @override
  String get calendarWeekdayFriday => 'Vendredi';

  @override
  String get calendarWeekdaySaturday => 'Samedi';

  @override
  String get calendarWeekdaySunday => 'Dimanche';

  @override
  String get outfitSavedToFavouritesBody => 'Ajouté aux favoris';

  @override
  String get outfitRemovedFromFavouritesBody => 'Retiré des favoris';

  @override
  String get outfitNotSavedTitle => 'Non enregistré';

  @override
  String get outfitLoggedAsWornBody => 'Porté aujourd\'hui.';

  @override
  String get outfitNicePickTitle => 'Belle selection';

  @override
  String get outfitRemovedBody => 'Tenue supprimée.';

  @override
  String get outfitDeletedTitle => 'Supprimé';

  @override
  String get outfitNotDeletedTitle => 'Non supprimé';

  @override
  String get outfitDuplicatedBody => 'Une copie est dans vos tenues.';

  @override
  String get outfitDuplicatedTitle => 'Dupliqué';

  @override
  String get outfitNotDuplicatedTitle => 'Non dupliqué';

  @override
  String get outfitNotSharedTitle => 'Non partagé';

  @override
  String outfitCollectionReadyBody(String name) {
    return '« $name » est prête.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collection non créée';

  @override
  String get outfitCollectionUpdatedBody => 'Collection mise à jour.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collection non mise à jour';

  @override
  String get outfitCollectionDeletedBody => 'Collection supprimée.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collection non supprimée';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenues ajoutées.',
      one: '1 tenue ajoutée.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Tenues non ajoutées';

  @override
  String get outfitPreviewNotCreatedTitle => 'Aperçu non créé';

  @override
  String get outfitGiveNameBody => 'Donnez un nom à la tenue.';

  @override
  String get outfitNameMissingTitle => 'Nom';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'Choisissez au moins un article.';

  @override
  String outfitCreatedBody(String name) {
    return '$name est dans vos tenues.';
  }

  @override
  String get outfitSavedTitle => 'Enregistré';

  @override
  String get wardrobeAddedToFavouritesBody => 'Ajouté aux favoris';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Retiré des favoris';

  @override
  String get wardrobeNotSavedTitle => 'Non enregistré';

  @override
  String get wardrobeLoggedAsWornBody => 'Ajouté comme porté aujourd\'hui.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Retiré de votre garde-robe.';

  @override
  String get wardrobeDeletedTitle => 'Supprimé';

  @override
  String get wardrobeNotDeletedTitle => 'Non supprimé';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles retirés de votre garde-robe.',
      one: '1 article retiré de votre garde-robe.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extraction IA de garde-robe';

  @override
  String get itemAddScanJobLabel => 'Scanner';

  @override
  String get itemAddFoundEarlierBody => 'Trouvé lors d\'un scan précédent';

  @override
  String get itemAddLookingAtPhoto => 'Analyse de votre photo';

  @override
  String get itemAddExtractionFailedBody => 'Échec de l\'extraction';

  @override
  String get itemAddJobFailedBody => 'Échec de la tâche';

  @override
  String get itemAddConnectionLostBody => 'Connexion perdue. Réessayez.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Connexion perdue pendant le traitement.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Article $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Article';

  @override
  String get itemAddNotCancelledTitle => 'Non annulé';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles ont été ajoutés à votre garde-robe.',
      one: '1 article a été ajouté à votre garde-robe.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved articles sur $total enregistrés. Touchez Enregistrer pour réessayer avec les autres.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Certains articles non enregistrés';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Choisissez au moins une photo.';

  @override
  String get batchPhotoUnreadableBody => 'Cette photo n\'a pas pu être lue.';

  @override
  String get batchNoPhotosReadableBody =>
      'Aucune de ces photos n\'a pu être lue. Essayez avec d\'autres photos.';

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
      'Connexion perdue pendant le traitement. Réessayez.';

  @override
  String get batchNotCancelledTitle => 'Non annulé';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Les liens vers des publications ne sont pas pris en charge. Saisissez un lien de profil.';

  @override
  String get batchLinkSpacesBody =>
      'Les liens ne peuvent pas contenir d\'espaces.';

  @override
  String get batchEnterProfileLinkBody =>
      'Saisissez un lien de profil Instagram ou Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Saisissez un lien de profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'La page de connexion n\'a pas pu s\'ouvrir. Réessayez.';

  @override
  String get batchSignInBrowserBody =>
      'Connectez-vous dans votre navigateur, puis revenez à FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Connectez votre compte';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Saisissez le code de votre application d\'authentification.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram exige une vérification de sécurité. Connectez-vous d\'abord dans votre navigateur.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Resaisissez votre nom d\'utilisateur et votre mot de passe.';

  @override
  String get batchSignInFailedBody =>
      'Échec de la connexion. Vérifiez votre nom d\'utilisateur et votre mot de passe.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Connectez-vous pour poursuivre l\'importation.';

  @override
  String get batchAccountNotConnectedBody =>
      'Votre compte n\'a pas été connecté.';

  @override
  String get batchAccountConnectedTitle => 'Compte connecté';

  @override
  String get batchNotConnectedTitle => 'Non connecté';

  @override
  String get batchImportConnectionLostBody =>
      'La connexion à l\'importation a été perdue. Actualisez pour vérifier.';

  @override
  String batchPickUpToBody(int max) {
    return 'Sélectionnez jusqu\'à $max photos. Nous trouvons les pièces.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count de $total photos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Préparation de la photo $done sur $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trouver des pièces dans $count photos',
      one: 'Trouver des pièces dans 1 photo',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Votre compte $platform utilise la connexion en deux étapes. Saisissez le code à 6 chiffres de votre application d\'authentification.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Ce profil $platform est privé ou nécessite une connexion pour afficher ses photos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Connecter avec $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos trouvées pour l\'instant',
      one: '1 photo trouvée pour l\'instant',
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
    return '$processed sur $total traitées · $added ajoutées · $waiting en attente · $skipped ignorées';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Analyse de la photo $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'La photo $number est la prochaine';
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
      other: '$count pièces trouvées',
      one: '1 pièce trouvée',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos ont été ajoutées à votre armoire.',
      one: '1 photo a été ajoutée à votre armoire.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count photos de studio de plus en route. Vous pouvez enregistrer ce qui est prêt ou partir — nous vous le ferons savoir.',
      one:
          '1 photo de studio de plus en route. Vous pouvez enregistrer ce qui est prêt ou partir — nous vous le ferons savoir.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Non encore enregistré : $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces pièces',
      one: '1 pièce',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos photos',
      one: '1 photo',
    );
    return '$_temp0 à partir de $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen sélectionnées. Touchez une pièce pour l\'ignorer.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enregistrement de $count pièces',
      one: 'Enregistrement de 1 pièce',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enregistrer $count pièces',
      one: 'Enregistrer 1 pièce',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody =>
      'Votre profil de morphologie est enregistré.';

  @override
  String get bodyProfileSavedTitle => 'Enregistré';

  @override
  String get bodyProfileNotSavedTitle => 'Non enregistré';

  @override
  String get bodyProfileSetDefaultBody => 'Définir comme profil par défaut.';

  @override
  String get bodyProfileDeletedBody => 'Profil de morphologie supprimé.';

  @override
  String get bodyProfileDeletedTitle => 'Supprimé';

  @override
  String get bodyProfileNotDeletedTitle => 'Non supprimé';

  @override
  String get feedbackNotSentTitle => 'Non envoyé';

  @override
  String get feedbackSentBody =>
      'Merci. Nous lisons tous les messages et répondons si besoin.';

  @override
  String get feedbackSentTitle => 'Retour envoyé';

  @override
  String get recommendUnnamedPiece => 'Pièce sans nom';

  @override
  String get recommendEnterCityBody =>
      'Indiquez votre ville pour recevoir des suggestions adaptées à la météo.';

  @override
  String get recommendWhichCityTitle => 'Quelle ville ?';

  @override
  String get aiConsentSheetTitle => 'Partage de photos avec un service d\'IA';

  @override
  String get aiConsentSheetBody =>
      'Pour générer vos images d\'essayage et de photos, FitCheck AI envoie les photos que vous fournissez (y compris des images de votre visage et de votre corps) à un prestataire d\'IA tiers de confiance (tel qu\'OpenAI ou Google Gemini) pour traitement. Ils génèrent vos images et ne les utilisent pas pour entraîner leurs modèles selon nos conditions. Les photos sont transmises en toute sécurité et ne sont jamais partagées à des fins publicitaires.';

  @override
  String get aiConsentSheetPermission =>
      'En continuant, vous accordez une autorisation explicite à partager vos photos avec ces prestataires d\'IA pour la génération d\'images.';

  @override
  String get skeletonsLoadMoreFailed => 'Impossible de charger plus.';

  @override
  String get jobsPiecesReadyTitle => 'Vos pièces sont prêtes';

  @override
  String get jobsScanStoppedTitle => 'Le scan s\'est arrêté';

  @override
  String get jobsNothingSavedBody => 'Rien n\'a été enregistré. Réessayez.';

  @override
  String get jobsPhotoUploadFailedBody => 'Échec de l\'envoi de la photo.';

  @override
  String get authGoogleSignInStartFailed =>
      'Impossible de démarrer la connexion Google. Veuillez réessayer.';

  @override
  String get referralAppliedTitle => 'Parrainage appliqué !';

  @override
  String get billingStoreUnavailableBody =>
      'Les achats dans le magasin ne sont pas disponibles sur cet appareil.';

  @override
  String get billingPurchaseProcessingBody =>
      'Cet achat est encore en cours de traitement. Rouvrez l\'application dans une minute pour voir votre offre.';

  @override
  String get profileAvatarUploadNoUrl =>
      'L\'envoi de l\'avatar n\'a pas renvoyé d\'URL d\'image.';

  @override
  String get rewardsDayStreakLabel => 'jours d\'affilée';

  @override
  String rewardsBestStreak(int days) {
    return 'Meilleure série de $days jours';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Accès à $permission requis';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'L\'accès à $permission est actuellement refusé. Ouvrez les Paramètres pour l\'autoriser, puis réessayez.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Étape $step sur 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Supprimer l\'image $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Supprimer l\'image $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Écrivez à $email. Nous traitons les signalements sous 24 h.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Retirer $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Ajouter à « $name »';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '« $name » est supprimé(e). Ses pièces restent dans votre garde‑robe.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Tout afficher ($count)';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restantes aujourd\'hui';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Échec de la photo $index';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected sur $max photos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Corpulence $shape · Peau $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Options pour $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Le plus porté : $name, $count fois';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label : non défini';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent % d\'adéquation';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked sur $max sélectionnés';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Retirer $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Priorité $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Cet abonnement est facturé via $store. Modifiez-le ou annulez-le dans vos réglages de compte $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gérer dans $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label : $current sur $max utilisés';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Environ $seconds s restantes';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done sur $total photos de studio prêtes';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready sur $total photos de studio prêtes. Touchez une pièce pour la passer.';
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
  String get profileFieldNotSet => 'Non';
}

/// The translations for French, as used in Canada (`fr_CA`).
class AppLocalizationsFrCa extends AppLocalizationsFr {
  AppLocalizationsFrCa() : super('fr_CA');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabPhotoshoot => 'Séance photo';

  @override
  String get tabCloset => 'Garde-robe';

  @override
  String get tabOutfits => 'Tenues';

  @override
  String get tabMore => 'Plus';

  @override
  String get actionAddItem => 'Ajouter';

  @override
  String get actionCreateOutfit => 'Créer tenue';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionNext => 'Suivant';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get stateLoading => 'Chargement';

  @override
  String get stateErrorTitle => 'Une erreur est survenue';

  @override
  String get stateErrorBody =>
      'Réessayez. Si le problème persiste, contactez le soutien.';

  @override
  String get stateOfflineTitle => 'Hors ligne';

  @override
  String get stateOfflineBody =>
      'Reconnectez-vous pour synchroniser votre garde-robe et générer des tenues.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAccountSection => 'Compte';

  @override
  String get settingsPreferencesSection => 'Préférences';

  @override
  String get settingsPlanBilling => 'Forfait et facturation';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsUnits => 'Unités de mesure';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsPrivacySection => 'Confidentialité et données';

  @override
  String get settingsAboutSection => 'À propos';

  @override
  String get settingsSignOut => 'Déconnexion';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountTitle => 'Supprimer votre compte?';

  @override
  String get settingsDeleteAccountBody =>
      'Ceci supprimera votre garde-robe, vos tenues, vos photos et votre profil. Cette action est irréversible.';

  @override
  String get settingsUnitsImperial => 'Impérial (po, lb)';

  @override
  String get settingsUnitsMetric => 'Métrique (cm, kg)';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Utiliser la langue de l\'appareil';

  @override
  String get languageSystemBody =>
      'FitCheck AI utilise la langue de votre téléphone.';

  @override
  String get languageSearchHint => 'Rechercher une langue';

  @override
  String get languageCurrent => 'Actuelle';

  @override
  String get languageReviewNote =>
      'Cette traduction est nouvelle. Dites-nous si quelque chose semble incorrect.';

  @override
  String get languageChanged => 'Langue mise à jour';

  @override
  String get paywallTitle => 'Choisissez votre forfait';

  @override
  String get paywallTrialBadge => '1 mois gratuit';

  @override
  String get paywallTrialTitle => 'Votre premier mois Pro est gratuit';

  @override
  String get paywallTrialBody =>
      'Importez toute votre garde-robe d\'un coup. Ajoutez des pièces au fur et à mesure par la suite.';

  @override
  String get paywallFreeForeverTitle => 'Gratuit pour toujours';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Aucune carte requise. Chaque mois, vous obtenez $uploads importations IA, $outfits tenues et $images photos de séance par jour.';
  }

  @override
  String get paywallCtaTrial => 'Commencer mon mois gratuit';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Passer à $plan';
  }

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get paywallManage => 'Gérer l\'abonnement';

  @override
  String get paywallTerms => 'Conditions d\'utilisation';

  @override
  String get paywallPrivacy => 'Politique de confidentialité';

  @override
  String get paywallPerMonth => 'par mois';

  @override
  String get paywallPerYear => 'par an';

  @override
  String get paywallBestValue => 'Meilleure valeur';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Essai gratuit pour les nouveaux abonnés seulement. Après l\'essai, Pro se renouvelle à $price sauf si annulé au moins 24 heures avant la fin.';
  }

  @override
  String get introTitle => 'Votre garde-robe, enfin organisée';

  @override
  String get introBody =>
      'Photographiez vos vêtements une fois. Obtenez des idées de tenues, des aperçus d\'essayage et des photos studio à partir de ce que vous possédez déjà.';

  @override
  String get introStart => 'Commencer';

  @override
  String get introHaveAccount => 'J\'ai déjà un compte';

  @override
  String get introSkip => 'Passer';

  @override
  String get authSignIn => 'Connexion';

  @override
  String get authSignUp => 'Créer un compte';

  @override
  String get authEmail => 'Courriel';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié?';

  @override
  String get authContinueApple => 'Continuer avec Apple';

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authOrDivider => 'ou';

  @override
  String get wardrobeTitle => 'Garde-robe';

  @override
  String get wardrobeEmptyTitle => 'Votre garde-robe est vide';

  @override
  String get wardrobeEmptyBody =>
      'Ajoutez votre première pièce ou téléversez une photo de toute la penderie à la fois.';

  @override
  String get wardrobeAddFirst => 'Ajouter votre premier article';

  @override
  String get wardrobeSearchHint => 'Rechercher dans votre garde-robe';

  @override
  String get categoryTops => 'Hauts';

  @override
  String get categoryBottoms => 'Bas';

  @override
  String get categoryShoes => 'Chaussures';

  @override
  String get categoryAccessories => 'Accessoires';

  @override
  String get categoryOuterwear => 'Vêtements d\'extérieur';

  @override
  String get categorySwimwear => 'Maillots de bain';

  @override
  String get categoryActivewear => 'Vêtements de sport';

  @override
  String get categoryOther => 'Autre';

  @override
  String get conditionClean => 'Propre';

  @override
  String get conditionDirty => 'Sale';

  @override
  String get conditionLaundry => 'À la lessive';

  @override
  String get conditionRepair => 'À réparer';

  @override
  String get conditionDonate => 'À donner';

  @override
  String get seasonSpring => 'Printemps';

  @override
  String get seasonSummer => 'Été';

  @override
  String get seasonFall => 'Automne';

  @override
  String get seasonWinter => 'Hiver';

  @override
  String get seasonAll => 'Toutes saisons';

  @override
  String get styleCasual => 'Décontracté';

  @override
  String get styleFormal => 'Habillé';

  @override
  String get styleBusiness => 'Professionnel';

  @override
  String get styleSporty => 'Sportif';

  @override
  String get styleBohemian => 'Bohème';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimaliste';

  @override
  String get styleRomantic => 'Romantique';

  @override
  String get styleEdgy => 'Audacieux';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artistique';

  @override
  String get styleClassic => 'Classique';

  @override
  String get styleElegant => 'Élégant';

  @override
  String get styleOther => 'Autre';

  @override
  String get occasionWork => 'Travail';

  @override
  String get occasionDateNight => 'Sortie';

  @override
  String get occasionTravel => 'Voyage';

  @override
  String get occasionWedding => 'Mariage';

  @override
  String get occasionGym => 'Sport';

  @override
  String get occasionWeekend => 'Fin de semaine';

  @override
  String get occasionParty => 'Fête';

  @override
  String get occasionInterview => 'Entrevue';

  @override
  String get colorBlack => 'Noir';

  @override
  String get colorWhite => 'Blanc';

  @override
  String get colorGrey => 'Gris';

  @override
  String get colorNavy => 'Marine';

  @override
  String get colorBrown => 'Brun';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorPurple => 'Mauve';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count semaines',
      one: 'Il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count mois',
      one: 'Il y a 1 mois',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count ans',
      one: 'Il y a 1 an',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Vous aimez FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Une courte évaluation aide les autres à trouver leur style.';

  @override
  String get ratingPromptYes => 'Évaluer l\'app';

  @override
  String get ratingPromptNo => 'Pas maintenant';

  @override
  String get closetNoMatchesTitle => 'Aucune pièce trouvée';

  @override
  String get closetNoMatchesBody =>
      'Essayez moins de filtres ou une autre recherche.';

  @override
  String get closetClearFilters => 'Effacer les filtres';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces',
      one: '1 pièce',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Chargement de vos pièces';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnées',
      one: '1 sélectionnée',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Supprimer la sélection';

  @override
  String get closetCancelSelection => 'Annuler la sélection';

  @override
  String get closetCloseSearch => 'Fermer la recherche';

  @override
  String get closetShowGrid => 'Afficher en grille';

  @override
  String get closetShowList => 'Afficher en liste';

  @override
  String get closetShowRows => 'Afficher en rangées';

  @override
  String get closetStatsTitle => 'Statistiques de garde-robe';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count pièces?',
      one: 'Supprimer 1 pièce?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Les tenues utilisant ces pièces seront modifiées.';

  @override
  String get closetSortBy => 'Trier par';

  @override
  String get closetFavourites => 'Favoris';

  @override
  String get closetFavourite => 'Ajouter aux favoris';

  @override
  String get closetUnfavourite => 'Retirer des favoris';

  @override
  String get closetWoreToday => 'Porté aujourd\'hui';

  @override
  String closetWornTimes(int count) {
    return 'Porté $count×';
  }

  @override
  String get closetCategoryLabel => 'Catégorie';

  @override
  String get closetUseCaseLabel => 'Occasion';

  @override
  String get closetAnyUseCase => 'Toutes';

  @override
  String get closetOtherUseCase => 'Autre occasion';

  @override
  String get closetOtherUseCaseHint => 'Par exemple, brunch';

  @override
  String get closetUseUseCase => 'Utiliser ceci';

  @override
  String get closetClearAll => 'Tout effacer';

  @override
  String get sortNewest => 'Plus récent d\'abord';

  @override
  String get sortOldest => 'Plus anciens d\'abord';

  @override
  String get sortName => 'Nom (A–Z)';

  @override
  String get sortMostWorn => 'Les plus portés';

  @override
  String get useCaseInformal => 'Décontracté';

  @override
  String get useCaseDate => 'Rencontre';

  @override
  String get useCaseDinner => 'Souper';

  @override
  String get useCaseLunch => 'Dîner';

  @override
  String get actionSelect => 'Sélectionner';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionFilter => 'Filtrer';

  @override
  String get actionSort => 'Trier';

  @override
  String get actionAll => 'Tout';

  @override
  String get dashboardStartClosetTitle => 'Commencez votre garde-robe';

  @override
  String get dashboardStartClosetBody =>
      'Prenez quelques photos. Nous les classerons pour vous.';

  @override
  String get dashboardPieces => 'pièces';

  @override
  String get dashboardOutfits => 'tenues';

  @override
  String get dashboardDayStreak => 'jours consécutifs';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count ce mois-ci';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Record $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoris',
      one: '1 favori',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenues enregistrées',
      one: '1 tenue enregistrée',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Le plus porté : $name, $count fois';
  }

  @override
  String get setupSkip => 'Passer la configuration';

  @override
  String get setupWhoTitle => 'Qui habillons-nous?';

  @override
  String get setupWhoBody =>
      'Définit le modèle pour les essayages. Vous pourrez le modifier dans votre profil.';

  @override
  String get setupStyleTitle => 'Que portez-vous le plus?';

  @override
  String get setupStyleBody =>
      'Choisissez-en quelques-uns. Vos idées de tenues en découleront.';

  @override
  String get setupClosetTitle => 'Ajoutez vos premières pièces.';

  @override
  String get setupClosetBody =>
      'Photographiez quelques vêtements ou une pile. Chaque pièce est détourée et classée pour vous.';

  @override
  String get setupAddClothes => 'Ajouter des vêtements';

  @override
  String get setupStylesLabel => 'Styles';

  @override
  String get setupOccasionsLabel => 'Occasions';

  @override
  String get setupSkipStep => 'Passer';

  @override
  String get setupLater => 'Plus tard';

  @override
  String get setupSaveError => 'Impossible d\'enregistrer';

  @override
  String get genderWomen => 'Femmes';

  @override
  String get genderMen => 'Hommes';

  @override
  String get genderNonBinary => 'Non binaire';

  @override
  String get genderPreferNotToSay => 'Préfère ne pas répondre';

  @override
  String get outfitEmptyTitle => 'Aucune tenue';

  @override
  String get outfitEmptyBody =>
      'Combinez des pièces de votre garde-robe et enregistrez le look.';

  @override
  String get outfitNoMatchesTitle => 'Aucune tenue ne correspond';

  @override
  String get outfitSearchHint => 'Rechercher dans vos tenues';

  @override
  String get outfitLoading => 'Chargement de vos tenues';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenues',
      one: '1 tenue',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Style et saison';

  @override
  String get outfitCollections => 'Collections';

  @override
  String get outfitDuplicate => 'Dupliquer';

  @override
  String get outfitDeleteTitle => 'Supprimer cette tenue?';

  @override
  String get outfitDeleteBody => 'Les pièces resteront dans votre garde-robe.';

  @override
  String get outfitDrafts => 'Brouillons';

  @override
  String get outfitDraft => 'Brouillon';

  @override
  String get filterStyle => 'Style';

  @override
  String get filterSeason => 'Saison';

  @override
  String get itemDetailDeleteTitle => 'Supprimer cette pièce?';

  @override
  String get itemDetailDeleteBody =>
      'Les tenues utilisant cette pièce la perdront.';

  @override
  String get itemAddFavourite => 'Ajouter aux favoris';

  @override
  String itemSize(String size) {
    return 'Taille $size';
  }

  @override
  String get itemColours => 'Couleurs';

  @override
  String get itemMaterial => 'Matière';

  @override
  String get itemPattern => 'Motif';

  @override
  String get itemUseCases => 'Occasions';

  @override
  String get itemKeptIn => 'Rangé dans';

  @override
  String get itemPrice => 'Prix';

  @override
  String get itemBought => 'Acheté';

  @override
  String get itemTags => 'Étiquettes';

  @override
  String get itemAdded => 'Ajouté';

  @override
  String get itemTimesWornLabel => 'fois porté';

  @override
  String get itemLastWornLabel => 'dernière fois';

  @override
  String get itemNeverWorn => 'Jamais';

  @override
  String get authEntryBody =>
      'Chaque pièce que vous possédez, stylisée par l\'IA. Planifiez vos tenues, essayez-les, photographiez-les.';

  @override
  String get authCreateCloset => 'Créer votre garde-robe';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authSignInBody => 'Connectez-vous pour ouvrir votre garde-robe.';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authCreateClosetBody =>
      'Cela prend une minute. Vos premiers articles sont gratuits.';

  @override
  String get authName => 'Nom';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authReferralCode => 'Code de référence (facultatif)';

  @override
  String get authResetTitle => 'Réinitialiser votre mot de passe';

  @override
  String get authResetBody =>
      'Nous vous enverrons un lien par courriel pour en choisir un nouveau.';

  @override
  String get authSendResetLink => 'Envoyer le lien';

  @override
  String get authBackToSignIn => 'Retour à la connexion';

  @override
  String get authEnterEmail => 'Entrez votre courriel';

  @override
  String get authEnterValidEmail => 'Entrez un courriel valide';

  @override
  String get authEnterPassword => 'Entrez votre mot de passe';

  @override
  String get authPasswordTooShort => 'Au moins 6 caractères';

  @override
  String get authShowPassword => 'Afficher le mot de passe';

  @override
  String get authHidePassword => 'Masquer le mot de passe';

  @override
  String get authNewHere => 'Nouveau ici?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirmez $email avant de vous connecter. Vérifiez votre boîte de réception.';
  }

  @override
  String get authResendEmail => 'Renvoyer le courriel';

  @override
  String get authResendingEmail => 'Envoi en cours…';

  @override
  String get authPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authEnterName => 'Entrez votre nom';

  @override
  String get authChoosePassword => 'Choisissez un mot de passe';

  @override
  String get authHaveAccount => 'Déjà un compte?';

  @override
  String get authCodeAccepted => 'Code accepté';

  @override
  String get authCodeNotFound => 'Code introuvable';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Vous obtenez tous deux un mois gratuit.';
  }

  @override
  String get authReferralInvalid => 'Ce code est invalide.';

  @override
  String authResetSent(String email) {
    return 'Envoyé à $email. Ouvrez le lien sur cet appareil.';
  }

  @override
  String get introSlide1Title => 'Photographiez votre garde-robe.';

  @override
  String get introSlide1Body =>
      'Prenez une pile de vêtements en photo. Chaque pièce est détourée et classée pour vous.';

  @override
  String get introSlide2Title => 'Habillez-vous plus vite.';

  @override
  String get introSlide2Body =>
      'Des tenues créées à partir de vos vêtements, adaptées à vos plans et à la météo.';

  @override
  String get introSlide3Title => 'Visualisez avant de porter.';

  @override
  String get introSlide3Body =>
      'Essayez des looks sur votre photo ou photographiez-les comme une campagne.';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsTemperature => 'Température';

  @override
  String get settingsEmailUpdates => 'Mises à jour par courriel';

  @override
  String get settingsEmailUpdatesBody => 'Nouvelles et conseils par courriel';

  @override
  String get settingsOutfitReminders => 'Rappels de tenues';

  @override
  String get settingsOutfitRemindersBody =>
      'Un rappel pour noter ce que vous avez porté';

  @override
  String get settingsWeeklySummary => 'Résumé hebdomadaire';

  @override
  String get settingsWeeklySummaryBody => 'Votre semaine en tenues';

  @override
  String get settingsStyleSection => 'Style';

  @override
  String get settingsPreferredStyles => 'Styles favoris';

  @override
  String get settingsPreferredColours => 'Couleurs favorites';

  @override
  String get settingsNoneChosen => 'Aucun choix';

  @override
  String get settingsPlanAiSection => 'Forfait et IA';

  @override
  String get settingsPlanBillingBody =>
      'Forfait, utilisation et mises à niveau';

  @override
  String get settingsPlanUsageBody => 'Forfait et utilisation';

  @override
  String get settingsInviteFriends => 'Inviter des amis';

  @override
  String get settingsInviteFriendsBody =>
      'Un mois gratuit pour chaque ami qui s\'inscrit';

  @override
  String get settingsAiProvider => 'Fournisseur IA';

  @override
  String get settingsAiProviderBody =>
      'Utilisez votre propre modèle pour le marquage et les images';

  @override
  String get settingsAppVersion => 'Version de l\'app';

  @override
  String get settingsPrivacyTerms => 'Confidentialité et conditions';

  @override
  String get settingsReportProblem => 'Signaler un problème';

  @override
  String get settingsChangePassword => 'Changer le mot de passe';

  @override
  String get settingsExportData => 'Exporter vos données';

  @override
  String get settingsExportBody =>
      'Nous préparerons un fichier avec tout ce que vous avez enregistré et ouvrirons le téléchargement.';

  @override
  String get settingsExportAction => 'Exporter';

  @override
  String get settingsCurrentPassword => 'Mot de passe actuel';

  @override
  String get settingsNewPassword => 'Nouveau mot de passe';

  @override
  String get settingsConfirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get settingsEnterCurrentPassword => 'Entrez votre mot de passe actuel';

  @override
  String get settingsEnterNewPassword => 'Entrez un nouveau mot de passe';

  @override
  String get settingsPasswordMin8 => 'Utilisez au moins 8 caractères';

  @override
  String get settingsPasswordNeedsUpper => 'Ajoutez une majuscule';

  @override
  String get settingsPasswordNeedsLower => 'Ajoutez une minuscule';

  @override
  String get settingsPasswordNeedsDigit => 'Ajoutez un chiffre';

  @override
  String get settingsPasswordsNoMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get settingsChangeAction => 'Modifier';

  @override
  String get itemAddSnapTitle => 'Photographier une pièce';

  @override
  String get itemAddSnapBody =>
      'Nous détectons chaque pièce sur la photo pour en faire un cliché studio.';

  @override
  String get itemAddCamera => 'Prendre une photo';

  @override
  String get itemAddGallery => 'Choisir dans la galerie';

  @override
  String get itemAddOtherWays => 'Autres méthodes d\'ajout';

  @override
  String get itemAddSeveral => 'Ajouter plusieurs photos';

  @override
  String get itemAddSeveralBody => 'Jusqu\'à 50 à la fois';

  @override
  String get itemAddImportProfile => 'Importer d\'un profil';

  @override
  String get itemAddImportProfileBody => 'Instagram ou Facebook';

  @override
  String get itemAddEnterDetails => 'Entrer les détails manuellement';

  @override
  String get itemAddEnterDetailsBody => 'Aucune photo requise';

  @override
  String get itemManualIntro =>
      'Seul un nom est requis. Ajoutez le reste maintenant ou plus tard.';

  @override
  String get itemManualNameHint => 'Par exemple, t-shirt bleu en coton';

  @override
  String get itemManualEnterName => 'Entrez un nom';

  @override
  String get itemManualNotes => 'Notes';

  @override
  String get itemManualBrand => 'Marque';

  @override
  String get itemManualSize => 'Taille';

  @override
  String get itemManualEnterNumber => 'Entrez un nombre';

  @override
  String get itemManualSavePiece => 'Enregistrer la pièce';

  @override
  String get itemManualSaving => 'Enregistrement';

  @override
  String get itemManualSavedTitle => 'Enregistré';

  @override
  String itemManualSavedBody(String name) {
    return '$name est dans votre garde-robe.';
  }

  @override
  String get itemManualNotSaved => 'Non enregistré';

  @override
  String get itemManualAddUseCase => 'Ajouter un usage';

  @override
  String get itemManualAddUseCaseAction => 'Ajouter l\'usage';

  @override
  String get itemPhotos => 'Photos';

  @override
  String get itemAddPhotos => 'Ajouter des photos';

  @override
  String get itemNoPhotoYet =>
      'Aucune photo. Vous pouvez enregistrer sans photo.';

  @override
  String get itemRemovePhoto => 'Supprimer la photo';

  @override
  String get itemRemovePiece => 'Supprimer la pièce';

  @override
  String get filterConditionLabel => 'État';

  @override
  String get photoshootStepPhotos => 'Photos';

  @override
  String get photoshootStepSetup => 'Configuration';

  @override
  String get photoshootStepCreating => 'Création';

  @override
  String get photoshootStepResults => 'Résultats';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Étape $current sur $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Une photo a échoué. Réessayez ci-dessous.';

  @override
  String photoshootManyFailed(int count) {
    return '$count photos ont échoué. Réessayez chaque photo ci-dessous.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Quantité';

  @override
  String get photoshootYourPrompt => 'Votre description';

  @override
  String get photoshootPromptHint => 'Heure dorée sur un toit, chemise en lin';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Créer $count photos',
      one: 'Créer 1 photo',
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
  String get photoshootLimitUnknown =>
      'Impossible de vérifier la limite d\'aujourd\'hui.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Forfait $plan : $remaining sur $limit restants aujourd\'hui';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratuit';

  @override
  String get photoshootGallery => 'Galerie';

  @override
  String get photoshootUseCamera => 'Utiliser l\'appareil photo';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Supprimer la photo $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Aucune photo reçue';

  @override
  String get photoshootNoPhotosBody =>
      'La séance s\'est terminée sans images. Réessayez.';

  @override
  String get photoshootNewStyle => 'Nouveau style';

  @override
  String get photoshootNewPhotos => 'Nouvelles photos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Ouvrir la photo $number';
  }

  @override
  String get photoshootReportPhoto => 'Signaler la photo';

  @override
  String get photoshootSaveToGallery => 'Enregistrer dans la galerie';

  @override
  String get actionUpgrade => 'Mise à niveau';

  @override
  String get referralLimitTitle => 'Vous avez utilisé vos photos du jour';

  @override
  String get referralLimitBody =>
      'Vos photos gratuites seront de retour demain. Invitez un ami et obtenez tous deux un mois de Pro gratuitement.';

  @override
  String get referralLimitRefer => 'Inviter un ami';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Rencontres';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Esthétique';

  @override
  String get photoshootUseCustom => 'Votre propre consigne';

  @override
  String get photoshootDescLinkedin => 'Portraits professionnels';

  @override
  String get photoshootDescDating => 'Décontracté, chaleureux et naturel';

  @override
  String get photoshootDescPortfolio => 'Éditorial, haute couture';

  @override
  String get photoshootDescInstagram => 'Style de vie pour votre fil';

  @override
  String get photoshootDescAesthetic => 'Ambiance artistique';

  @override
  String get photoshootDescCustom => 'Décrivez le style souhaité';

  @override
  String get aspectSquare => 'Carré';

  @override
  String get aspectPortrait => 'Portrait';

  @override
  String get aspectLandscape => 'Paysage';

  @override
  String get aspectTall => 'Haut';

  @override
  String get aspectWide => 'Large';

  @override
  String get tryOnAppBar => 'Essayage virtuel';

  @override
  String get tryOnYourPhoto => 'Votre photo';

  @override
  String get tryOnGarment => 'Vêtement';

  @override
  String get tryOnUploadingPhoto => 'Téléversement de votre photo';

  @override
  String get tryOnAddPhotoPrompt => 'Ajoutez une photo de vous en pied';

  @override
  String get tryOnBodyPhotoHint => 'Une photo en pied fonctionne mieux';

  @override
  String get tryOnAddPhoto => 'Ajouter une photo';

  @override
  String get tryOnChangePhoto => 'Changer la photo';

  @override
  String get tryOnPhotoLoadFailed => 'Impossible de charger votre photo.';

  @override
  String get tryOnChooseGarment => 'Choisir une photo de vêtement';

  @override
  String get tryOnChooseOneGarment => 'Choisir une photo de vêtement';

  @override
  String get tryOnGarmentHint =>
      'Une photo à plat ou sur cintre fonctionne mieux';

  @override
  String get tryOnChange => 'Changer';

  @override
  String get tryOnCamera => 'Appareil photo';

  @override
  String get tryOnRemove => 'Supprimer';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Style';

  @override
  String get tryOnBackground => 'Arrière-plan';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Habillage en cours. Cela prend environ trente secondes.';

  @override
  String get tryOnEmptyResult => 'Votre essai apparaîtra ici';

  @override
  String get tryOnReportImage => 'Signaler l\'image';

  @override
  String get tryOnCreating => 'Création';

  @override
  String get tryOnTryAgain => 'Réessayer';

  @override
  String get tryOnCreate => 'Créer l\'essai';

  @override
  String get tryOnBackgroundStudioWhite => 'Studio blanc';

  @override
  String get tryOnBackgroundStudioGrey => 'Studio gris';

  @override
  String get tryOnBackgroundUrban => 'Rue urbaine';

  @override
  String get tryOnBackgroundNature => 'Nature';

  @override
  String get tryOnBackgroundMinimal => 'Minimaliste';

  @override
  String get tryOnPoseFront => 'Debout de face';

  @override
  String get tryOnPoseSide => 'De profil';

  @override
  String get tryOnPoseWalking => 'En marchant';

  @override
  String get dashboardGreetingMorning => 'Bonjour';

  @override
  String get dashboardGreetingAfternoon => 'Bon après-midi';

  @override
  String get dashboardGreetingEvening => 'Bonsoir';

  @override
  String get dashboardWelcome => 'Bienvenue';

  @override
  String get dashboardOpenProfile => 'Ouvrir le profil';

  @override
  String get dashboardRailToday => 'Aujourd\'hui';

  @override
  String get dashboardRailRecently => 'Récemment';

  @override
  String get dashboardActivityEmpty =>
      'Vos nouveaux morceaux et tenues apparaîtront ici.';

  @override
  String get quickAddPiece => 'Ajouter un morceau';

  @override
  String get quickAddPieceBody => 'Photographier et étiqueter';

  @override
  String get quickBuildOutfit => 'Créer une tenue';

  @override
  String get quickBuildOutfitBody => 'Agencer vos morceaux';

  @override
  String get quickForYou => 'Pour vous';

  @override
  String get quickForYouBody => 'Suggestions du jour';

  @override
  String get quickPlanWeek => 'Planifier la semaine';

  @override
  String get quickPlanWeekBody => 'Tenues par date';

  @override
  String get referralBannerUrgent => 'Besoin de plus? Invitez un ami.';

  @override
  String get referralBannerTitle => 'Offrez un mois, obtenez un mois.';

  @override
  String get referralBannerBody =>
      'Vous et votre ami obtenez chacun un mois de Pro.';

  @override
  String get referralBannerDismiss => 'Ignorer pour une semaine';

  @override
  String get referralBannerShare => 'Partager l\'invitation';

  @override
  String get referralBannerCopy => 'Copier le lien';

  @override
  String get itemEditPieceTitle => 'Modifier le morceau';

  @override
  String get itemEditDescriptionLabel => 'Description';

  @override
  String get itemEditNotSaved => 'Non enregistré';

  @override
  String get itemEditSavedTitle => 'Enregistré';

  @override
  String get itemEditSavedBody => 'Vos modifications sont enregistrées.';

  @override
  String get itemEditSavedStalePhotos =>
      'Enregistré — les photos pourraient être périmées';

  @override
  String get itemEditRemovePieceHint =>
      'Supprimer cette pièce de la page de l\'article.';

  @override
  String get itemEditNoPhotos =>
      'Aucune photo. Ajoutez-en une depuis votre galerie ou votre appareil photo.';

  @override
  String get itemEditKeepPhoto => 'Garder la photo';

  @override
  String get itemEditRemoved => 'Supprimé';

  @override
  String get itemEditAddUseCaseAction => 'Ajouter';

  @override
  String get statsNoStatsTitle => 'Aucune statistique';

  @override
  String get statsNoStatsBody =>
      'Ajoutez quelques pièces pour voir votre garde-robe ici.';

  @override
  String get statsByCategory => 'Par catégorie';

  @override
  String get statsTotalValue => 'valeur totale';

  @override
  String get statsMostWorn => 'Les plus portés';

  @override
  String get statsLeastWorn => 'En attente';

  @override
  String get statsUnnamedPiece => 'Pièce sans nom';

  @override
  String get jobsTitle => 'Analyses';

  @override
  String get jobsEmptyTitle => 'Aucune analyse';

  @override
  String get jobsEmptyBody =>
      'Prenez une photo et laissez-nous travailler en arrière-plan.';

  @override
  String get jobsNotCancelled => 'Non annulé';

  @override
  String get jobsResume => 'Reprendre';

  @override
  String get jobsReview => 'Réviser';

  @override
  String get jobsStop => 'Arrêter';

  @override
  String get jobsDismiss => 'Ignorer';

  @override
  String get reportTitle => 'Signaler le contenu';

  @override
  String reportIntro(String contentType) {
    return 'Dites-nous ce qui ne va pas avec ce $contentType. Notre équipe examine chaque signalement.';
  }

  @override
  String get reportReasonInappropriate => 'Inapproprié ou offensant';

  @override
  String get reportReasonNudity => 'Nudité ou contenu sexuel';

  @override
  String get reportReasonHarassment => 'Harcèlement ou abus';

  @override
  String get reportReasonImpersonation => 'Usurpation d\'identité';

  @override
  String get reportReasonOther => 'Autre';

  @override
  String get reportDetailsLabel => 'Détails supplémentaires (facultatif)';

  @override
  String get reportSubmit => 'Envoyer le signalement';

  @override
  String get reportSubmittedTitle => 'Signalement envoyé';

  @override
  String get reportSubmittedBody => 'Merci. Notre équipe examinera ce contenu.';

  @override
  String get reportFailedTitle => 'Échec de l\'envoi';

  @override
  String get reportFailedBody => 'Veuillez réessayer.';

  @override
  String get reportContentTryOnImage => 'image d\'essayage IA';

  @override
  String get reportContentSharedOutfit => 'tenue partagée';

  @override
  String get reportContentPhotoshootImage => 'image de séance photo IA';

  @override
  String get sharedOutfitTitle => 'Tenue partagée';

  @override
  String get sharedOutfitHideTooltip => 'Masquer cette tenue';

  @override
  String get sharedOutfitReportTooltip => 'Signaler cette tenue';

  @override
  String get sharedOutfitHideTitle => 'Masquer cette tenue?';

  @override
  String get sharedOutfitHideBody =>
      'Elle restera masquée sur cet appareil. Vous pouvez aussi la signaler pour que notre équipe l\'examine et la supprime.';

  @override
  String get sharedOutfitHideAction => 'Masquer';

  @override
  String get sharedOutfitHiddenInfo =>
      'Cette tenue ne s\'affichera plus sur cet appareil.';

  @override
  String get sharedOutfitHiddenToast => 'Tenue masquée';

  @override
  String get sharedOutfitMissingTitle => 'Cette tenue n\'est plus disponible';

  @override
  String get sharedOutfitMissingBody =>
      'Elle a peut-être été supprimée ou le lien est erroné.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Vous avez masqué cette tenue';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Si elle est inappropriée, signalez-la dans Confidentialité et conditions ou écrivez à $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Vous aimez ce look?';

  @override
  String get sharedOutfitCtaBody =>
      'Créez des tenues similaires à partir de votre garde-robe.';

  @override
  String get sharedOutfitCtaButton => 'Obtenir FitCheck AI';

  @override
  String get errorTitle => 'Erreur';

  @override
  String get errorUnknown => 'Une erreur inattendue est survenue';

  @override
  String get errorNoConnection =>
      'Pas de connexion Internet. Vérifiez votre réseau.';

  @override
  String get errorTimeout => 'Délai d\'attente dépassé. Veuillez réessayer.';

  @override
  String get errorServerError =>
      'Un problème est survenu de notre côté. Veuillez réessayer.';

  @override
  String get errorBadGateway =>
      'Notre serveur est temporairement injoignable. Veuillez réessayer.';

  @override
  String get errorServiceUnavailable =>
      'Le service est temporairement indisponible. Veuillez réessayer sous peu.';

  @override
  String get errorInternalError =>
      'Un problème est survenu. Veuillez réessayer.';

  @override
  String get errorUnauthorized => 'Connectez-vous pour continuer.';

  @override
  String get errorForbidden => 'Vous n\'avez pas accès à ceci.';

  @override
  String get errorSessionExpired => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get errorInvalidCredentials =>
      'Ce courriel ou mot de passe est incorrect.';

  @override
  String get errorTokenRefreshFailed =>
      'Impossible de rafraîchir votre session. Reconnectez-vous.';

  @override
  String get errorRequestCancelled => 'Requête annulée.';

  @override
  String get errorInvalidFormat =>
      'Ce format de fichier n\'est pas pris en charge.';

  @override
  String get errorFileTooLarge => 'Ce fichier est trop volumineux.';

  @override
  String get errorUploadFailed => 'Échec du téléversement. Veuillez réessayer.';

  @override
  String get errorCacheCorrupted =>
      'Les données enregistrées ont été corrompues et ont été réinitialisées.';

  @override
  String get errorCacheNotFound => 'Rien n\'a encore été enregistré.';

  @override
  String get errorUserNotFound => 'Impossible de trouver ce compte.';

  @override
  String get errorItemNotFound => 'Cet article n\'existe plus.';

  @override
  String get errorOutfitNotFound => 'Cette tenue n\'existe plus.';

  @override
  String get rewardsTitle => 'Récompenses';

  @override
  String get rewardsNoAchievementsTitle => 'Aucun accomplissement';

  @override
  String get rewardsNoAchievementsBody =>
      'Ajoutez des pièces et planifiez des tenues pour en débloquer.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Personne au classement';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planifiez des tenues pour accumuler des points et apparaître ici.';

  @override
  String get legalViewPrivacyPolicy => 'Voir la politique de confidentialité';

  @override
  String get aiConsentAgree => 'J\'accepte et continuer';

  @override
  String get aiConsentNotNow => 'Pas maintenant';

  @override
  String get imageViewerCloseTooltip => 'Fermer la visionneuse';

  @override
  String get updateReadyTitle => 'Mise à jour prête';

  @override
  String get updateReadyBody =>
      'Redémarrez FitCheck AI pour appliquer les dernières améliorations.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI a besoin d\'accéder à la caméra pour prendre des photos de vos tenues et articles de garde-robe.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI a besoin d\'accéder à la photothèque pour sélectionner des photos de vos tenues et articles.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI doit enregistrer vos photos de tenues générées par IA dans votre photothèque.';

  @override
  String get wardrobeSomePhotosSkipped => 'Certaines photos ont été ignorées';

  @override
  String get wardrobePhotosNotAdded => 'Photos non ajoutées';

  @override
  String get wardrobePhotoNotAdded => 'Photo non ajoutée';

  @override
  String get wardrobeNotStartedTitle => 'Non commencé';

  @override
  String get wardrobeNoRoomTitle => 'Aucun espace';

  @override
  String get wardrobeAddPhotosSemantic => 'Ajouter des photos';

  @override
  String get batchAddTileLabel => 'Ajouter';

  @override
  String get batchProfileLinkLabel => 'Lien du profil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importer d\'un profil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Ajouter plusieurs photos';

  @override
  String get wardrobeClearAction => 'Effacer';

  @override
  String get wardrobeRefreshTooltip => 'Rafraîchir';

  @override
  String get batchNoPhotosYetTitle => 'Aucune photo pour l\'instant';

  @override
  String get batchChoosePhotosAction => 'Choisir des photos';

  @override
  String get batchWeFindEachPieceBody =>
      'Nous repérons chaque pièce et créons une photo de studio.';

  @override
  String get batchPreparingPhotosSemantic => 'Préparation des photos';

  @override
  String get batchPhotosProcessedSemantic => 'Photos traitées';

  @override
  String get batchPasteProfileLinkTitle => 'Coller le lien d\'un profil';

  @override
  String get batchPasteProfileLinkBody =>
      'Un profil Instagram ou Facebook public. Nous analysons ses photos et vous choisissez ce qui entre dans votre garde-robe.';

  @override
  String get batchClearLinkTooltip => 'Effacer le lien';

  @override
  String get batchStartingButton => 'Démarrage';

  @override
  String get batchStartImportAction => 'Lancer l\'importation';

  @override
  String get batchReviewEveryPhotoTitle => 'Vous révisez chaque photo';

  @override
  String get batchReviewEveryPhotoBody =>
      'Rien n\'est ajouté tant que vous ne l\'avez pas approuvé.';

  @override
  String get batchPrivateProfilesTitle => 'Profils privés';

  @override
  String get batchPrivateProfilesBody =>
      'Connectez votre compte. Instagram demande aussi un nom d\'utilisateur et un mot de passe.';

  @override
  String get batchUseAnotherLinkAction => 'Utiliser un autre lien';

  @override
  String get batchSignInNeededTitle => 'Connexion requise';

  @override
  String get batchEnterYourCodeTitle => 'Entrez votre code';

  @override
  String get batchUseUsernamePasswordAction =>
      'Utiliser le nom d\'utilisateur et le mot de passe';

  @override
  String get batchAlreadyConnectedAction => 'Déjà connecté dans le navigateur';

  @override
  String get batchEnterCodeAction => 'Entrer le code';

  @override
  String get batchTryAnotherWayAction => 'Essayer une autre méthode';

  @override
  String get batchLiveStatus => 'En direct';

  @override
  String get batchReconnectingStatus => 'Reconnexion';

  @override
  String get batchSignInToInstagramTitle => 'Se connecter à Instagram';

  @override
  String get batchUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Code, si vous utilisez la double authentification';

  @override
  String get batchAuthenticatorCodeBody =>
      'Entrez le code à 6 chiffres de votre application d\'authentification. Les codes changent rapidement.';

  @override
  String get batchVerifyAction => 'Vérifier';

  @override
  String get batchFindingPhotosTitle => 'Recherche de photos';

  @override
  String get batchImportPausedTitle => 'Importation en pause';

  @override
  String get batchProcessingPhotosTitle => 'Traitement des photos';

  @override
  String get batchWaitingNextPhoto => 'En attente de la prochaine photo';

  @override
  String get batchCancelImportAction => 'Annuler l\'importation';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Aucun article trouvé sur cette photo.';

  @override
  String get batchEditPieceColoursLabel =>
      'Couleurs, séparées par des virgules';

  @override
  String get batchAddToClosetAction => 'Ajouter à la garde-robe';

  @override
  String get batchSkipPhotoAction => 'Passer cette photo';

  @override
  String get batchImportCompleteTitle => 'Importation terminée';

  @override
  String get batchImportFailedTitle => 'Échec de l\'importation';

  @override
  String get batchImportCancelledTitle => 'Importation annulée';

  @override
  String get batchImportErrorBody =>
      'Un problème est survenu lors de l\'importation.';

  @override
  String get batchNothingMoreImportedBody =>
      'Aucun autre élément n\'est importé de ce profil.';

  @override
  String get batchViewClosetAction => 'Voir la garde-robe';

  @override
  String get batchStartOverAction => 'Rerecommencer';

  @override
  String get wardrobeAddPieceTitle => 'Ajouter un article';

  @override
  String get wardrobeAddDetailsTitle => 'Ajouter des détails';

  @override
  String get wardrobeScanningTitle => 'Numérisation';

  @override
  String get batchReviewPiecesTitle => 'Vérifier les articles';

  @override
  String get wardrobeGalleryAction => 'Galerie';

  @override
  String get wardrobeCameraAction => 'Caméra';

  @override
  String get wardrobeNewBadge => 'Nouveau';

  @override
  String get wardrobeRemovePhotoTooltip => 'Supprimer la photo';

  @override
  String get batchRunInBackgroundTooltip => 'Exécuter en arrière-plan';

  @override
  String get batchStepOneOfTwo => 'Étape 1 sur 2';

  @override
  String get batchStepTwoOfTwo => 'Étape 2 sur 2';

  @override
  String get batchUploadingPhotosTitle => 'Téléversement des photos';

  @override
  String get batchFindingPiecesTitle => 'Recherche des articles';

  @override
  String get batchMakingStudioPhotosTitle => 'Création des photos studio';

  @override
  String get batchStoppedLabel => 'Arrêté';

  @override
  String get batchFindingPiecesStoppedTitle => 'Recherche des articles arrêtée';

  @override
  String get batchCancelledLabel => 'Annulé';

  @override
  String get batchAllDoneTitle => 'Terminé';

  @override
  String get batchOpeningPiecesBody => 'Ouverture de vos articles';

  @override
  String get batchNothingSavedBody => 'Rien n\'a été enregistré.';

  @override
  String get batchFindingPiecesFailedBody =>
      'Échec de la recherche des articles.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'Recherche des articles arrêtée prématurément.';

  @override
  String get batchStopFindingPiecesTitle => 'Arrêter la recherche ?';

  @override
  String get batchStopFindingPiecesBody =>
      'L\'analyse s\'arrête et rien n\'est enregistré. Les articles déjà trouvés restent dans votre activité jusqu\'à ce que vous les effaciez.';

  @override
  String get batchKeepGoingAction => 'Continuer';

  @override
  String get batchTryAgainAction => 'Réessayer';

  @override
  String get batchBackToPhotosAction => 'Retour aux photos';

  @override
  String get batchSkipAllAction => 'Tout ignorer';

  @override
  String get batchIncludeAllAction => 'Tout inclure';

  @override
  String get batchNoPiecesFoundTitle => 'Aucun article trouvé';

  @override
  String get batchNoPiecesFoundBody =>
      'Aucun vêtement n\'a été détecté sur ces photos.';

  @override
  String get batchChooseOtherPhotosAction => 'Choisir d\'autres photos';

  @override
  String get batchUseCaseHelper => 'Ajouté à chaque article enregistré.';

  @override
  String get batchDiscardPiecesTitle => 'Ignorer ces articles?';

  @override
  String get batchDiscardPiecesBody =>
      'Aucun élément de ce lot n\'est enregistré.';

  @override
  String get batchKeepAction => 'Conserver';

  @override
  String get batchDiscardAction => 'Ignorer';

  @override
  String get batchRemovePieceTitle => 'Retirer cet article?';

  @override
  String get batchRemovePieceBody =>
      'Il n\'est pas enregistré dans votre garde-robe.';

  @override
  String get batchRemoveAction => 'Retirer';

  @override
  String get batchChoosePiecesToSave => 'Choisir les articles à enregistrer';

  @override
  String get batchDiscardAllAction => 'Tout ignorer';

  @override
  String get batchNothingSavedRetryBody =>
      'Rien n\'a été enregistré. Réessayez.';

  @override
  String get batchNotSavedTitle => 'Non enregistré';

  @override
  String get batchSavingLabel => 'Enregistrement';

  @override
  String get batchSendToBackgroundAction => 'Envoyer en arrière-plan';

  @override
  String get batchStillWorkingMessage =>
      'En cours de traitement. Nous vous aviserons lorsque vos articles seront prêts.';

  @override
  String get batchRunningInBackgroundTitle => 'En arrière-plan';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Photos studio arrêtées. Vous pouvez tout de même enregistrer ces articles.';

  @override
  String get batchTapPieceToSkip => 'Touchez un article pour l\'ignorer.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Photos studio en préparation. Vous pouvez quitter — nous vous aviserons.';

  @override
  String get batchLeaveAction => 'Quitter';

  @override
  String get batchPeopleInPhotosTitle => 'Personnes sur les photos';

  @override
  String get batchIncludeAction => 'Inclure';

  @override
  String get batchSkipAction => 'Ignorer';

  @override
  String get batchYourPhotoIsUsedLabel => 'Votre photo est utilisée';

  @override
  String get batchMakingStudioPhotoLabel => 'Création de la photo studio';

  @override
  String get batchNoStudioPhotoBody =>
      'Aucune photo studio. Votre photo est utilisée.';

  @override
  String get batchEnterDetailsYourselfAction => 'Saisir les détails vous-même';

  @override
  String get batchChooseAnotherPhotoAction => 'Choisir une autre photo';

  @override
  String get batchConnectionLostTitle => 'Connexion perdue';

  @override
  String get batchConnectionLostBody =>
      'Vérifiez votre connexion, puis réessayez.';

  @override
  String get batchDailyLimitTitle => 'Limite quotidienne atteinte';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Passez à Pro pour plus d\'analyses ou saisissez les détails vous-même.';

  @override
  String get batchDailyLimitBodyFree =>
      'Vos analyses seront réinitialisées demain. Vous pouvez saisir les détails vous-même dès maintenant.';

  @override
  String get batchSeePlansAction => 'Voir les abonnements';

  @override
  String get batchAiBusyTitle => 'Notre IA est occupée';

  @override
  String get batchAiBusyBody =>
      'C\'est de notre côté. Réessayez dans quelques minutes.';

  @override
  String get batchNoPiecesBody =>
      'Essayez une photo plus nette ou saisissez les détails vous-même.';

  @override
  String get batchScanningUnavailableTitle => 'Analyse non disponible';

  @override
  String get batchScanningUnavailableBody =>
      'Saisissez les détails vous-même pour l\'instant.';

  @override
  String get batchScanDidNotFinishTitle => 'L\'analyse n\'a pas abouti';

  @override
  String get batchTryAgainBody => 'Réessayez.';

  @override
  String get billingTitle => 'Abonnement';

  @override
  String get billingUpgradeHeading => 'Mettre à niveau votre forfait';

  @override
  String get billingUpgradeOnPlusBody =>
      'Mêmes fonctionnalités, limites plus élevées.';

  @override
  String get billingUpgradeBody =>
      'Plus et Pro offrent les mêmes fonctionnalités. Choisissez les limites dont vous avez besoin.';

  @override
  String get billingWebUnavailableBody =>
      'Les mises à niveau en ligne ne sont pas encore disponibles. Un code promo ou de parrainage débloque toujours Plus ou Pro. Invitez des amis ci-dessous pour gagner des mois gratuits.';

  @override
  String get billingPlansStale =>
      'Impossible de charger les derniers forfaits. Les prix peuvent ne pas être à jour.';

  @override
  String get billingMonthly => 'Mensuel';

  @override
  String get billingYearly => 'Annuel';

  @override
  String get billingCurrentPlan => 'Forfait actuel';

  @override
  String get billingActive => 'Actif';

  @override
  String get billingThisMonth => 'Ce mois-ci';

  @override
  String get billingItemExtractions => 'Extractions d\'articles';

  @override
  String get billingOutfitVisualizations => 'Visualisations de tenues';

  @override
  String get billingNearLimitUpgrade =>
      'Vous vous approchez de la limite de ce mois-ci. Mettez à niveau pour en avoir plus.';

  @override
  String get billingNearLimitResets =>
      'Vous vous approchez de la limite de ce mois-ci. Elle se réinitialise au début du mois prochain.';

  @override
  String get billingStoreUnavailable =>
      'Les mises à niveau ne sont pas encore disponibles dans la boutique. Revenez bientôt.';

  @override
  String get billingManageHeading => 'Gérer votre forfait';

  @override
  String get billingCancelPlan => 'Annuler l\'abonnement';

  @override
  String get billingCancelKeepsAccess =>
      'Vous conservez l\'accès jusqu\'à la fin de cette période de facturation.';

  @override
  String get billingCancelConfirmTitle => 'Annuler votre abonnement?';

  @override
  String get billingKeepPlan => 'Conserver le forfait';

  @override
  String get billingCancelPlanAction => 'Annuler le forfait';

  @override
  String get billingBilledMonthly => 'Facturé mensuellement';

  @override
  String get billingBilledYearly => 'Facturé annuellement';

  @override
  String get billingVirtualTryOn => 'Essai virtuel';

  @override
  String get billingPrioritySupport => 'Soutien prioritaire';

  @override
  String get billingDisclosureProRenewing =>
      'Pro est un abonnement à renouvellement automatique';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus et Pro sont des abonnements à renouvellement automatique';

  @override
  String get billingDisclosureAppleBilling =>
      'Le paiement est débité de votre identifiant Apple lors de la confirmation de l\'achat.';

  @override
  String get billingDisclosureGoogleBilling =>
      'Le paiement est débité de votre compte Google Play lors de la confirmation de l\'achat.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Votre abonnement se renouvelle automatiquement pour la même période au même prix, à moins de désactiver le renouvellement automatique au moins 24 heures avant la fin de la période en cours.';

  @override
  String get billingDisclosureAppleManage =>
      'Gérez ou annulez en tout temps dans Réglages › votre identifiant Apple › Abonnements.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gérez ou annulez en tout temps dans Google Play › Paiements et abonnements.';

  @override
  String get billingReferFriend => 'Inviter un ami';

  @override
  String get billingHowItWorks => 'Comment ça marche';

  @override
  String get billingHowShareTitle => 'Partagez votre lien';

  @override
  String get billingHowShareBody => 'Envoyez-le à un ami.';

  @override
  String get billingHowSignUpTitle => 'Il s\'inscrit';

  @override
  String get billingHowSignUpBody => 'Votre ami s\'inscrit à partir du lien.';

  @override
  String get billingHowBothTitle => 'Vous obtenez tous les deux Pro';

  @override
  String get billingHowBothBody =>
      'Chacun de vous obtient un mois de Pro gratuit.';

  @override
  String get billingYourReferrals => 'Vos parrainages';

  @override
  String get billingInvited => 'Invité';

  @override
  String get billingJoined => 'Inscrit';

  @override
  String get billingMonthsEarned => 'Mois gagnés';

  @override
  String get billingInviteFriend => 'Inviter un ami';

  @override
  String get billingInviteBody =>
      'Vous et votre ami obtenez chacun un mois de Pro.';

  @override
  String get billingYourCode => 'Votre code';

  @override
  String get billingCopyLink => 'Copier le lien';

  @override
  String get billingShareInvite => 'Partager l\'invitation';

  @override
  String get giftUnavailable =>
      'Les invitations-cadeaux ne sont pas offertes dans cette version.';

  @override
  String get giftPageTitle => 'Offrir FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Aucune invitation-cadeau gratuite n\'est disponible pour le moment.';

  @override
  String get giftFormTitle => 'Envoyer une invitation gratuite';

  @override
  String get giftFormBody =>
      'Le destinataire réclame le cadeau avec ce courriel vérifié. Nous n\'envoyons pas le courriel à votre place.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nom du destinataire';

  @override
  String get giftFieldRecipientEmail => 'Courriel du destinataire';

  @override
  String get giftFieldOccasion => 'Occasion (optionnel)';

  @override
  String get giftNoOccasion => 'Aucune occasion';

  @override
  String get giftOccasionBirthday => 'Anniversaire';

  @override
  String get giftOccasionAnniversary => 'Anniversaire de mariage';

  @override
  String get giftOccasionOther => 'Autre';

  @override
  String get giftFieldCardGreeting => 'Message de la carte';

  @override
  String get giftFieldCardGreetingHelper =>
      'Ceci apparaît sur la carte exactement tel quel.';

  @override
  String get giftFieldPrivateNote => 'Note privée (optionnel)';

  @override
  String get giftCreateAction => 'Créer le cadeau gratuit';

  @override
  String get giftClaimedTitle => 'Cadeau réclamé';

  @override
  String get giftClaimedActive => 'Votre cadeau FitCheck Pro est actif.';

  @override
  String get giftClaimedQueued =>
      'Votre cadeau FitCheck Pro débutera après votre accès actuel.';

  @override
  String get giftLinkCopied => 'Lien du cadeau copié dans le presse-papiers.';

  @override
  String get giftErrorName => 'Entrez un nom.';

  @override
  String get giftErrorEmail => 'Entrez une adresse courriel valide.';

  @override
  String get giftErrorGreeting => 'Entrez le message de la carte.';

  @override
  String get giftErrorGreetingLength => 'Utilisez un maximum de 80 caractères.';

  @override
  String get giftClaimAction => 'Réclamer le cadeau';

  @override
  String get giftCardPreview => 'Aperçu de la carte';

  @override
  String get giftGiftForYou => 'Un cadeau pour vous';

  @override
  String get giftGiftWaiting => 'Un cadeau vous attend';

  @override
  String get giftOpenBody =>
      'Ouvrez vos cadeaux pour les réclamer avec votre courriel vérifié.';

  @override
  String get giftOpenGifts => 'Ouvrir les cadeaux';

  @override
  String get giftSendInvitation => 'Envoyer l\'invitation';

  @override
  String get settingsAiProviderSection => 'Fournisseur';

  @override
  String get settingsAiCustom => 'Personnalisé';

  @override
  String get settingsAiUrlHelper =>
      'Utilisez une URL publique accessible par le serveur. Localhost ne fonctionne pas depuis nos serveurs.';

  @override
  String get settingsAiConnectionSection => 'Connexion';

  @override
  String get settingsAiApiUrl => 'URL de l\'API';

  @override
  String get settingsAiApiKey => 'Clé d\'API';

  @override
  String get settingsAiApiKeySaved =>
      'Enregistré. Laissez vide pour conserver.';

  @override
  String get settingsAiChatModel => 'Modèle de clavardage';

  @override
  String get settingsAiVisionModel => 'Modèle de vision (optionnel)';

  @override
  String get settingsAiImageModel => 'Modèle d\'image (optionnel)';

  @override
  String get settingsAiImageModelNote =>
      'La génération d\'images requiert des compléments de clavardage compatibles avec OpenAI et response_modalities.';

  @override
  String get settingsAiTestConnection => 'Tester la connexion';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarGoToToday => 'Aujourd\'hui';

  @override
  String get calendarConnectTooltip => 'Connecter un calendrier';

  @override
  String get calendarAddEvent => 'Ajouter un événement';

  @override
  String get calendarEmptyTitle => 'Rien de prévu';

  @override
  String get calendarEmptyBody =>
      'Ajoutez un événement et planifiez votre tenue.';

  @override
  String get calendarPreviousMonth => 'Mois précédent';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarAllDay => 'Toute la journée';

  @override
  String get calendarOutfitLinked => 'Tenue associée';

  @override
  String get calendarEventOptions => 'Options de l\'événement';

  @override
  String get calendarDeleteTitle => 'Supprimer cet événement?';

  @override
  String get calendarChangeOutfit => 'Changer de tenue';

  @override
  String get calendarLinkOutfit => 'Associer une tenue';

  @override
  String get calendarRemoveOutfit => 'Retirer la tenue';

  @override
  String get calendarNewEvent => 'Nouvel événement';

  @override
  String get calendarEditEvent => 'Modifier l\'événement';

  @override
  String get calendarTitleLabel => 'Titre';

  @override
  String get calendarTitleRequired => 'Ajouter un titre';

  @override
  String get calendarEndBeforeStart => 'La fin doit suivre le début';

  @override
  String get calendarStarts => 'Début';

  @override
  String get calendarEnds => 'Fin';

  @override
  String get calendarPlaceOptional => 'Lieu (optionnel)';

  @override
  String get calendarNotesOptional => 'Notes (optionnelles)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Créez une tenue, puis associez-la à cet événement.';

  @override
  String get calendarBuildOutfit => 'Créer une tenue';

  @override
  String get calendarConnectionsTitle => 'Calendriers';

  @override
  String get calendarConnectionsBody =>
      'Les événements ajoutés ici restent dans FitCheck AI.';

  @override
  String get calendarDisconnect => 'Déconnecter';

  @override
  String get calendarNotAvailable => 'Non disponible pour le moment';

  @override
  String get profileSectionExplore => 'Explorer';

  @override
  String get profileNavTryOn => 'Essayage';

  @override
  String get profileNavRewards => 'Récompenses';

  @override
  String get profileSupport => 'Soutien';

  @override
  String get profileHelp => 'Aide';

  @override
  String get profileAbout => 'À propos';

  @override
  String get profileAboutBody =>
      'Votre garde-robe, vos tenues et vos abonnements au même endroit.';

  @override
  String get profileSignOutTitle => 'Se déconnecter?';

  @override
  String get profileSignOutBody =>
      'Vous pourrez vous reconnecter en tout temps.';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get profileYourProfile => 'Votre profil';

  @override
  String get profileBodyProfiles => 'Profils corporels';

  @override
  String get profileBodyEmptyTitle => 'Aucun profil corporel';

  @override
  String get profileBodyEmptyBody =>
      'Ajoutez votre taille et votre silhouette pour un meilleur ajustement.';

  @override
  String get profileBodyAdd => 'Ajouter un profil';

  @override
  String get profileBodyDefaultNote =>
      'Votre profil par défaut est utilisé pour l\'ajustement et l\'essayage.';

  @override
  String get profileBodyDefaultBadge => 'Par défaut';

  @override
  String get profileBodyMakeDefault => 'Définir par défaut';

  @override
  String get profileBodyDeleteBody => 'Cette action est irréversible.';

  @override
  String get profileBodyRequired => 'Obligatoire';

  @override
  String get profileBodyCheckNumber => 'Vérifiez ce nombre';

  @override
  String get profileBodyNew => 'Nouveau profil corporel';

  @override
  String get profileBodyNameHint => 'Par exemple, Moi';

  @override
  String get profileBodyHeight => 'Taille';

  @override
  String get profileBodyWeight => 'Poids';

  @override
  String get profileBodyBuild => 'Silhouette';

  @override
  String get profileBodySkinTone => 'Teint';

  @override
  String get profileBirthDateNeededBody =>
      'Ajoutez une date de naissance pour l\'heure de naissance.';

  @override
  String get profileBirthDateNeededTitle => 'Date de naissance requise';

  @override
  String get profilePartlySavedBody =>
      'Votre nom et photo ont été enregistrés. Les details de naissance n\'ont pas pu être enregistrés; réessayez plus tard.';

  @override
  String get profilePartlySavedTitle => 'Partiellement enregistré';

  @override
  String get profileSavedBody => 'Votre profil est enregistré.';

  @override
  String get profileChangePhoto => 'Changer la photo de profil';

  @override
  String get profilePhotoLabel => 'Photo de profil';

  @override
  String get profilePhotoHint => 'Appuyez pour en choisir une nouvelle';

  @override
  String get profileBirthDateLabel => 'Date de naissance (optionnel)';

  @override
  String get profileBirthTimeLabel => 'Heure de naissance (optionnel)';

  @override
  String get profileBirthTimeHelper =>
      'Rend les suggestions védiques plus précises';

  @override
  String get profileBirthPlaceLabel => 'Lieu de naissance (optionnel)';

  @override
  String get profileBirthPlaceHint => 'Par exemple, Montréal, Canada';

  @override
  String get profileHelpContactTitle => 'Posez-nous vos questions';

  @override
  String get profileHelpContactBody =>
      'Envoyez-nous un message et nous répondrons par courriel, généralement en moins d\'un jour.';

  @override
  String get profileHelpContactAction => 'Contacter le soutien';

  @override
  String get profileHelpFaqTitle => 'Questions fréquentes';

  @override
  String get profileFaqAddPiecesTitle =>
      'Comment ajouter des articles à ma garde-robe?';

  @override
  String get profileFaqAddPiecesBody =>
      'Touchez Ajouter un article dans l\'onglet Garde-robe. Prenez une photo ou choisissez-en une de votre galerie; nous repérons chaque article et l\'étiquetons pour vous.';

  @override
  String get profileFaqMatchingTitle =>
      'Comment fonctionne l\'association de tenues?';

  @override
  String get profileFaqMatchingBody =>
      'Ouvrez Pour vous et choisissez des articles que vous possédez. Nous suggérons des assortiments et créons des tenues complètes à partir de votre garde-robe.';

  @override
  String get profileFaqTryOnTitle =>
      'Puis-je utiliser mes propres photos pour l\'essayage?';

  @override
  String get profileFaqTryOnBody =>
      'Oui. Ajoutez une photo de vous en pied, puis choisissez des articles pour les voir sur vous.';

  @override
  String get profileFaqRewardsTitle => 'Comment gagner des récompenses?';

  @override
  String get profileFaqRewardsBody =>
      'Planifiez et enregistrez des tenues souvent. Les séries et les réussites s\'accumulent au fil du temps.';

  @override
  String get profileFaqPrivacyTitle => 'Ma garde-robe est-elle privée?';

  @override
  String get profileFaqPrivacyBody =>
      'Oui. Votre garde-robe et vos tenues sont privées, sauf si vous partagez le lien d\'une tenue.';

  @override
  String get profileHelpMoreTitle => 'Plus d\'aide';

  @override
  String get profileHelpGuides => 'Guides';

  @override
  String get profileHelpGuidesBody => 'Fonctionnement de chaque option';

  @override
  String get feedbackCategoryBug => 'Un problème technique';

  @override
  String get feedbackCategoryIdea => 'Une idée';

  @override
  String get feedbackCategoryGeneral => 'Général';

  @override
  String get feedbackCategoryHelp => 'J\'ai besoin d\'aide';

  @override
  String get feedbackHintBug =>
      'Que s\'est-il passé et qu\'attendiez-vous? Les étapes nous aident à corriger le tout.';

  @override
  String get feedbackHintIdea => 'Que souhaiteriez-vous et pourquoi?';

  @override
  String get feedbackHintGeneral =>
      'Partagez votre avis ou posez une question.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Vous pouvez ajouter jusqu\'à 5 images.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limite atteinte';

  @override
  String get feedbackImageTooLargeBody =>
      'Choisissez une image de moins de 5 Mo.';

  @override
  String get feedbackImageTooLargeTitle => 'Image trop volumineuse';

  @override
  String get feedbackTitle => 'Envoyer des commentaires';

  @override
  String get feedbackAboutLabel => 'De quoi s\'agit-il?';

  @override
  String get feedbackSubjectLabel => 'Sujet';

  @override
  String get feedbackSubjectRequired => 'Ajouter un objet';

  @override
  String get feedbackSubjectTooShort =>
      'L\'objet doit contenir au moins 3 caractères';

  @override
  String get feedbackDetailsLabel => 'Détails';

  @override
  String get feedbackDetailsRequired => 'Ajouter des détails';

  @override
  String get feedbackDetailsTooShort =>
      'La description doit contenir au moins 10 caractères';

  @override
  String get feedbackAddScreenshot => 'Ajouter une capture d\'écran';

  @override
  String get feedbackAttachmentHint => 'Jusqu\'à 5, 5 Mo max chacune';

  @override
  String get feedbackSend => 'Envoyer';

  @override
  String get feedbackEmptyTitle => 'Rien envoyé pour l\'instant';

  @override
  String get feedbackEmptyBody =>
      'Ce que vous envoyez s\'affiche ici avec son statut.';

  @override
  String get feedbackHistoryTitle => 'Vos envois';

  @override
  String get feedbackStatusOpen => 'Ouvert';

  @override
  String get feedbackStatusInProgress => 'En cours';

  @override
  String get feedbackStatusResolved => 'Résolu';

  @override
  String get feedbackStatusClosed => 'Fermé';

  @override
  String get legalIntro =>
      'Comment nous protégeons vos données et les conditions d\'utilisation de FitCheck AI.';

  @override
  String get legalPolicies => 'Politiques';

  @override
  String get legalPrivacySubtitle => 'Ce que nous recueillons et pourquoi';

  @override
  String get legalTermsTitle => 'Conditions d\'utilisation';

  @override
  String get legalTermsSubtitle => 'Les règles d\'utilisation de l\'app';

  @override
  String get legalLicences => 'Licences open-source';

  @override
  String get legalSupportSubtitle =>
      'Aide, contact et demandes de confidentialité';

  @override
  String get legalReportAbuse => 'Signaler un problème ou un abus';

  @override
  String get permissionCameraTitle => 'Accès à la caméra';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI utilise votre caméra pour prendre des photos de vos vêtements et tenues pour l\'essayage IA et l\'organisation de la garde-robe.';

  @override
  String get permissionPhotoTitle => 'Accès aux photos';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI a besoin d\'accéder à vos photos pour vous permettre de sélectionner des images de vêtements et de tenues pour les fonctionnalités IA et votre garde-robe.';

  @override
  String get permissionNotNow => 'Pas maintenant';

  @override
  String get permissionOpenSettings => 'Ouvrir les réglages';

  @override
  String authSignedInAs(String name) {
    return 'Connecté en tant que $name';
  }

  @override
  String get authSignedIn => 'Connecté';

  @override
  String get authWelcomeBackTitle => 'Bon retour';

  @override
  String get authSignInFailed => 'Échec de la connexion';

  @override
  String get authWelcomeTitle => 'Bienvenue';

  @override
  String get authSignUpFailed => 'Échec de l\'inscription';

  @override
  String get authGoogleSignInFailed => 'Échec de la connexion Google';

  @override
  String get authAppleSignInFailed => 'Échec de la connexion Apple';

  @override
  String get authConfirmEmailTitle => 'Confirmez votre courriel';

  @override
  String get authConfirmEmailBody =>
      'Vérifiez vos messages pour le courriel de confirmation, puis connectez-vous.';

  @override
  String get authClosetReady => 'Votre garde-robe est prête.';

  @override
  String get authSignedOutTitle => 'Déconnecté';

  @override
  String get authSignedOutBody => 'Vous êtes déconnecté.';

  @override
  String get authSignOutFailed => 'Échec de la déconnexion';

  @override
  String get authEmailSentTitle => 'Courriel envoyé';

  @override
  String get authResetLinkSent =>
      'Vérifiez vos messages pour le lien de réinitialisation.';

  @override
  String get authPasswordUpdatedTitle => 'Mot de passe mis à jour';

  @override
  String get authPasswordUpdated => 'Votre mot de passe est mis à jour.';

  @override
  String get authPasswordNotUpdated => 'Mot de passe non mis à jour';

  @override
  String get authCouldNotSendEmail => 'Impossible d\'envoyer le courriel';

  @override
  String get authEmailNotSent => 'Courriel non envoyé';

  @override
  String get authResendSentBody =>
      'Nous avons envoyé un nouveau courriel de confirmation.';

  @override
  String get outfitPreviewWithAi => 'Aperçu avec l’IA';

  @override
  String get outfitNewPreview => 'Créer un aperçu';

  @override
  String get outfitBuilderClosetHeading => 'Votre garde-robe';

  @override
  String get outfitBuilderSearchHint => 'Chercher des pièces';

  @override
  String get outfitClearSearch => 'Effacer la recherche';

  @override
  String get outfitBuilderAddPiecesTitle => 'Ajoutez des pièces';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Les looks sont composés des pièces de votre garde-robe.';

  @override
  String get outfitBuilderNoMatches => 'Aucune pièce trouvée.';

  @override
  String get outfitNameLabel => 'Nom du look';

  @override
  String get outfitNameHint => 'Par exemple, Lin week-end';

  @override
  String get outfitPreviewSemantic => 'Aperçu IA du look';

  @override
  String get outfitChoosePieces => 'Choisir des pièces';

  @override
  String get outfitTapPiecesHint =>
      'Touchez les pièces ci-dessous pour les ajouter.';

  @override
  String get outfitShareTooltip => 'Partager';

  @override
  String get outfitSaveFavourite => 'Ajouter aux favoris';

  @override
  String get outfitPiecesHeading => 'Pièces';

  @override
  String get outfitWearHistoryEmpty =>
      'Portez-le une fois et les dates apparaîtront ici.';

  @override
  String get outfitWearHistoryTitle => 'Historique de portage';

  @override
  String get outfitWearHistoryError => 'Impossible de charger les dates.';

  @override
  String get outfitWornOn => 'Porté le';

  @override
  String get outfitEditTitle => 'Modifier le look';

  @override
  String get outfitSavedPhotosFailed => 'Détails enregistrés, photos non';

  @override
  String get outfitNoPhotosBody =>
      'Aucune photo. Le look affiche ses pièces plutôt.';

  @override
  String get outfitOccasionLabel => 'Occasion';

  @override
  String get outfitOccasionNone => 'Aucune';

  @override
  String get outfitTagsHint => 'Séparez par des virgules';

  @override
  String get outfitDraftBody => 'Masqué de votre liste principale';

  @override
  String get outfitPublic => 'Public';

  @override
  String get outfitPublicBody => 'Toute personne ayant le lien peut le voir';

  @override
  String get outfitDeleteFromDetail =>
      'Supprimez ce look de sa page de détails.';

  @override
  String get outfitNewCollection => 'Nouvelle collection';

  @override
  String get outfitNoCollectionsTitle => 'Aucune collection';

  @override
  String get outfitNoCollectionsBody =>
      'Regroupez les tenues par voyage, saison ou humeur.';

  @override
  String get outfitCreateCollection => 'Créer une collection';

  @override
  String get outfitAddOutfits => 'Ajouter des tenues';

  @override
  String get outfitRename => 'Renommer';

  @override
  String get outfitCollectionDeleteBody =>
      'Les tenues qu\'elle contient sont conservées.';

  @override
  String get outfitCollectionsNotLoaded => 'Tenues non chargées';

  @override
  String get outfitRenameCollection => 'Renommer la collection';

  @override
  String get outfitDescriptionOptional => 'Description (facultatif)';

  @override
  String get outfitAllInCollection =>
      'Toutes les tenues sont déjà dans cette collection.';

  @override
  String get photoshootSubtitleUpload =>
      'Portraits de studio à partir de vos photos';

  @override
  String get photoshootSubtitleConfigure =>
      'Choisissez un style, un format et une quantité';

  @override
  String get photoshootSubtitleGenerating => 'Cela prend une ou deux minutes';

  @override
  String get photoshootAddPhotosSemantic =>
      'Ajouter des photos depuis votre galerie';

  @override
  String get photoshootUploadTitle => 'Ajoutez de 1 à 4 photos de vous';

  @override
  String get photoshootUploadBody => 'Appuyez pour choisir dans votre galerie';

  @override
  String get photoshootAddToContinue => 'Ajoutez une photo pour continuer';

  @override
  String get photoshootAddAnotherPhoto => 'Ajouter une autre photo';

  @override
  String get photoshootTipsTitle => 'Pour de meilleurs résultats';

  @override
  String get photoshootTipsBody =>
      'Utilisez des photos nettes et bien éclairées de votre visage sous plusieurs angles. Évitez les lunettes de soleil et les chapeaux.';

  @override
  String get photoshootStarting => 'Démarrage';

  @override
  String get photoshootCancelling => 'Annulation';

  @override
  String get photoshootFailed => 'Échec';

  @override
  String get recommendTabMatches => 'Correspondances';

  @override
  String get recommendTabComplete => 'Compléter';

  @override
  String get recommendTabWeather => 'Météo';

  @override
  String get recommendTabColours => 'Couleurs';

  @override
  String get recommendTabShop => 'Magasiner';

  @override
  String get recommendNoMatchesTitle => 'Aucune correspondance';

  @override
  String get recommendNoMatchesBody =>
      'Choisissez un article et nous trouverons ce qui va avec.';

  @override
  String get recommendPickPiece => 'Choisir un article';

  @override
  String get recommendNothingMatchesTitle =>
      'Aucun article ne correspond encore';

  @override
  String get recommendNothingMatchesBody =>
      'Essayez d\'autres articles ou ajoutez-en plus à votre garde-robe.';

  @override
  String get recommendChangePieces => 'Changer les articles';

  @override
  String get recommendDefaultReason =>
      'Il convient aux articles que vous avez choisis.';

  @override
  String get recommendCompleteTitle => 'Compléter un look';

  @override
  String get recommendCompleteBody =>
      'Choisissez un article et nous compléterons le reste.';

  @override
  String get recommendWorking => 'Traitement';

  @override
  String get recommendGenerate => 'Générer';

  @override
  String get recommendChooseStyleBody => 'Choisissez un style, puis générez.';

  @override
  String get recommendNoLooksTitle => 'Aucun look pour ces articles';

  @override
  String get recommendNoLooksBody =>
      'Essayez un autre style ou d\'autres articles.';

  @override
  String get recommendDefaultLook => 'Un look pour vos articles';

  @override
  String get recommendNoPiecesBody =>
      'Aucun article n\'a été retourné pour ce look.';

  @override
  String get recommendCityLabel => 'Ville';

  @override
  String get recommendCheck => 'Vérifier';

  @override
  String get recommendWeatherTitle => 'Quel est le temps?';

  @override
  String get recommendWeatherBody =>
      'Entrez votre ville pour obtenir des suggestions pour aujourd\'hui.';

  @override
  String get recommendWearToday => 'Porter aujourd\'hui';

  @override
  String get recommendWeatherNoPieces =>
      'Aucun article dans votre garde-robe pour ce temps encore.';

  @override
  String get recommendBudgetLabel => 'Budget jusqu\'à';

  @override
  String get recommendLooking => 'Recherche';

  @override
  String get recommendFindWhatToBuy => 'Trouver quoi acheter';

  @override
  String get recommendFillGapsTitle => 'Combler les manques';

  @override
  String get recommendFillGapsBody =>
      'Définissez un budget et nous suggérerons ce qui manque à votre garde-robe.';

  @override
  String get recommendNoGapsTitle => 'Aucun manque trouvé';

  @override
  String get recommendNoGapsBody =>
      'Essayez un budget plus élevé ou une autre catégorie.';

  @override
  String get recommendMoodEveryday => 'Quotidien';

  @override
  String get recommendMoodBigMeeting => 'Grande réunion';

  @override
  String get recommendDayLabel => 'Jour';

  @override
  String get recommendReadingStars => 'Lecture des astres';

  @override
  String get recommendGetMyColours => 'Mes couleurs';

  @override
  String get recommendLuckyColoursTitle => 'Vos couleurs porte-bonheur';

  @override
  String get recommendLuckyColoursBody =>
      'Choisissez un jour et nous vous suggérons des couleurs et des pièces.';

  @override
  String get recommendLuckyColoursSection => 'Couleurs porte-bonheur';

  @override
  String get recommendAvoidColoursSection => 'Couleurs à éviter';

  @override
  String get recommendBirthDateTitle => 'Ajoutez votre date de naissance';

  @override
  String get recommendBirthDateBody =>
      'Nous avons besoin de votre date de naissance pour analyser vos couleurs.';

  @override
  String get recommendEditProfile => 'Modifier le profil';

  @override
  String get recommendNothingThisDay => 'Rien pour ce jour.';

  @override
  String get recommendUnnamedColour => 'Couleur sans nom';

  @override
  String get recommendFromCloset => 'De votre garde-robe';

  @override
  String get recommendNoPiecesInColours =>
      'Aucune pièce de ces couleurs pour l’instant.';

  @override
  String get recommendOutfitIdeas => 'Idées de looks';

  @override
  String get recommendNoOutfitsInColours =>
      'Aucun look complet de ces couleurs pour l’instant.';

  @override
  String get recommendDefaultOutfitIdea => 'Une idée de look';

  @override
  String get recommendPickUpToThree => 'Choisissez jusqu’à trois pièces';

  @override
  String get recommendEmptyClosetBody =>
      'Ajoutez d’abord quelques pièces, puis revenez pour les combinaisons.';

  @override
  String get dashboardDressForDay => 'Vêtez-vous pour la journée.';

  @override
  String get dashboardOutfitOfDay => 'Look du jour';

  @override
  String get dashboardFreshLook => 'Un nouveau look';

  @override
  String get subscriptionManageInStoreTitle => 'Gérer dans la boutique';

  @override
  String get subscriptionManageInStoreBody =>
      'Ce plan est facturé par la boutique. Gérez-le dans les paramètres de votre compte boutique.';

  @override
  String get subscriptionCancelledTitle => 'Abonnement annulé';

  @override
  String get subscriptionCancelledBody =>
      'Votre plan reste actif jusqu’à la fin de la période de facturation.';

  @override
  String get subscriptionCancelFailedTitle => 'Impossible d’annuler';

  @override
  String get subscriptionCouldNotOpenTitle => 'Impossible d’ouvrir';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Impossible d’ouvrir la gestion de la facturation.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Impossible d’ouvrir le lien.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Impossible de charger votre lien';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Impossible de charger votre lien de parrainage. Réessayez.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copié';

  @override
  String get subscriptionReferralCopiedBody => 'Lien de parrainage copié.';

  @override
  String get subscriptionReferralShareSubject => 'Essayez FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Inscrivez-vous à FitCheck AI et nous gagnons tous les deux un mois de Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Lien copié';

  @override
  String get subscriptionShareUnavailableBody =>
      'Le partage n’est pas disponible. Le lien a donc été copié.';

  @override
  String get subscriptionShareFailedTitle => 'Échec du partage';

  @override
  String get subscriptionShareFailedBody =>
      'Copiez le lien depuis la page de parrainage plutôt.';

  @override
  String get subscriptionStoreReadyTitle => 'Boutique prête';

  @override
  String get subscriptionStoreReadyBody =>
      'Les prix de la boutique sont disponibles. Vous pouvez passer à une version supérieure maintenant.';

  @override
  String get purchaseFailedTitle => 'Échec de l\'achat';

  @override
  String get purchaseUnavailableTitle => 'Achat indisponible';

  @override
  String get purchaseIapUnavailableBody =>
      'Les achats intégrés ne sont pas disponibles sur cet appareil.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Cette formule n\'est pas encore disponible à l\'achat.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Cette formule n\'est pas encore disponible dans la boutique. Veuillez revenir bientôt.';

  @override
  String get purchaseStartFailedBody =>
      'L\'achat n\'a pas pu démarrer. Réessayez.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'La passerelle de paiement n\'a pas renvoyé de lien de paiement.';

  @override
  String get purchasePendingTitle => 'Achat en attente';

  @override
  String get purchasePendingBody =>
      'Votre achat est en attente d\'approbation. Vous aurez accès dès qu\'il sera approuvé.';

  @override
  String get purchaseFailedBody => 'L\'achat a échoué. Réessayez.';

  @override
  String get purchaseRestoredTitle => 'Restauration terminée';

  @override
  String get purchaseRestoredBody => 'Vos achats ont été restaurés.';

  @override
  String get purchaseActiveTitle => 'Abonnement actif';

  @override
  String get purchaseActiveBody => 'Votre abonnement est actif. Bienvenue.';

  @override
  String get purchaseSignInRequiredTitle => 'Connexion requise';

  @override
  String get purchaseSignInRequiredBody =>
      'Connectez-vous pour terminer votre achat.';

  @override
  String get purchaseErrorTitle => 'Erreur d\'achat';

  @override
  String get purchaseInvalidTransactionBody =>
      'L\'achat ne contient pas d\'identifiant de transaction vérifiable.';

  @override
  String get purchaseVerificationPendingTitle => 'Vérification en attente';

  @override
  String get purchaseVerificationPendingBody =>
      'Impossible de vérifier votre achat auprès de la boutique pour l’instant. Le processus se terminera automatiquement et vous ne serez pas facturé deux fois.';

  @override
  String get purchaseNotAppliedTitle => 'Achat non appliqué';

  @override
  String get purchaseNotAppliedBody =>
      'Votre achat n’a pas pu être appliqué à votre compte. Contactez le support et ne réitérez pas l’achat.';

  @override
  String get purchaseRestoreFailedTitle => 'Échec de la restauration';

  @override
  String get purchaseRestoreFailedBody =>
      'Impossible de restaurer les achats. Réessayez.';

  @override
  String get purchaseRecoveredActiveBody => 'Votre abonnement est actif.';

  @override
  String get purchaseCompleteTitle => 'Achat terminé';

  @override
  String get giftCreateFailedTitle => 'Impossible de créer le cadeau';

  @override
  String get giftClaimFailedTitle => 'Impossible de réclamer le cadeau';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cadeaux pour vous',
      one: 'Un cadeau pour vous',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mois',
      '12': '1 an',
      'other': '$months mois',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining restants',
      one: '1 restant',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration de FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender vous a envoyé $duration de FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Un cadeau FitCheck Pro pour $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'De $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Pour $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'De $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'votre destinataire';

  @override
  String get giftPreviewPlaceholderSender => 'vous';

  @override
  String get settingsSavedTitle => 'Enregistré';

  @override
  String get settingsNotSavedTitle => 'Non enregistré';

  @override
  String get settingsAiChooseProviderBody => 'Choisissez un fournisseur.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Un fournisseur personnalisé exige une URL API.';

  @override
  String get settingsAiKeyRequiredBody => 'Saisissez une clé API.';

  @override
  String get settingsAiSavedBody => 'Vos paramètres IA sont enregistrés.';

  @override
  String get settingsAiMissingDetailsTitle => 'Informations manquantes';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Saisissez une URL API et un modèle de discussion pour tester.';

  @override
  String get settingsAiKeyNeededTitle => 'Clé API requise';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Saisissez votre clé API pour tester. Votre clé conservée reste privée.';

  @override
  String get settingsAiKeyToTestBody => 'Saisissez votre clé API pour tester.';

  @override
  String get settingsAiConnectedTitle => 'Connecté';

  @override
  String get settingsAiConnectedBody => 'La connexion fonctionne.';

  @override
  String get settingsAiTestFailedTitle => 'Échec du test';

  @override
  String get settingsPreferencesSavedBody =>
      'Vos préférences sont enregistrées.';

  @override
  String get settingsPasswordNotChangedTitle => 'Mot de passe non modifié';

  @override
  String get settingsOAuthPasswordBody =>
      'Ce compte se connecte via Google ou Apple. Utilisez « Mot de passe oublié » pour définir un mot de passe d\'abord.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'Le mot de passe actuel est incorrect.';

  @override
  String get settingsExportReadyTitle => 'Export prêt';

  @override
  String get settingsExportReadyBody =>
      'L\'export de vos données est prêt à télécharger.';

  @override
  String get settingsLinkCopiedTitle => 'Lien copié';

  @override
  String get settingsExportClipboardBody =>
      'Nous n\'avons pas pu ouvrir votre navigateur, le lien de téléchargement a donc été copié. Collez-le rapidement dans un navigateur : il expire.';

  @override
  String get settingsExportFailedTitle => 'Échec de l\'export';

  @override
  String get settingsAccountNotDeletedTitle => 'Compte non supprimé';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Vous pouvez ajouter jusqu\'à $max photos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limite de photos';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Ajoutez au moins une photo.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Aucune photo';

  @override
  String get photoshootDescribeLookBody => 'Décrivez le look souhaité.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt requis';

  @override
  String get photoshootConsentFeatureLabel => 'Séance photo IA';

  @override
  String get photoshootStatusPreparing => 'Préparation de vos photos';

  @override
  String get photoshootStatusGenerating => 'Génération';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lot $current sur $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done sur $total terminées';
  }

  @override
  String get photoshootGenerationFailedBody => 'La génération a échoué.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready prêtes, $failed échecs.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Partiellement terminé';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos sont prêtes.',
      one: '1 photo est prête.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Nous avons perdu la connexion. Veuillez réessayer.';

  @override
  String get photoshootCouldNotCancelTitle => 'Annulation impossible';

  @override
  String get photoshootRetryFailedTitle => 'La nouvelle tentative a échoué';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'La photo $number est prête.';
  }

  @override
  String get photoshootReplacedTitle => 'Remplacée';

  @override
  String get photoshootSavedToGalleryBody => 'Enregistrée dans votre galerie.';

  @override
  String get photoshootSavedTitle => 'Enregistrée';

  @override
  String get photoshootNotSavedTitle => 'Non enregistrée';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes les $count photos se trouvent dans votre galerie.',
      one: '1 photo se trouve dans votre galerie.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved sur $total enregistrées.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Certaines photos non enregistrées';

  @override
  String get tryonConsentFeatureLabel => 'Essayage virtuel';

  @override
  String get tryonAvatarUpdatedBody => 'Votre photo est mise à jour.';

  @override
  String get tryonSavedTitle => 'Enregistrée';

  @override
  String get tryonUploadFailedTitle => 'Échec de l’envoi';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Choisissez d’abord une photo de vêtement.';

  @override
  String get tryonNoGarmentTitle => 'Aucun vêtement';

  @override
  String get tryonWaitForUploadBody =>
      'Attendez la fin de l’envoi de votre photo.';

  @override
  String get tryonStillUploadingTitle => 'Envoi en cours';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Ajoutez d’abord une photo de vous-même.';

  @override
  String get tryonReadyBody => 'Votre essayage est prêt.';

  @override
  String get tryonFailedTitle => 'Échec de l’essayage';

  @override
  String get tryonSavedToGalleryBody => 'Enregistrée dans votre galerie.';

  @override
  String get tryonNotSavedTitle => 'Non enregistrée';

  @override
  String get calendarEventAddedBody => 'Événement ajouté';

  @override
  String get calendarEventPlannedTitle => 'Planifié';

  @override
  String get calendarEventSavedBody => 'Événement enregistré';

  @override
  String get calendarSavedTitle => 'Enregistré';

  @override
  String get calendarEventNotSavedTitle => 'Événement non enregistré';

  @override
  String get calendarEventRemovedBody => 'Événement supprimé';

  @override
  String get calendarEventDeletedTitle => 'Supprimé';

  @override
  String get calendarEventNotDeletedTitle => 'Événement non supprimé';

  @override
  String get calendarOutfitNotLinkedTitle => 'Ensemble non lié';

  @override
  String get calendarLinkedTitle => 'Lié';

  @override
  String get calendarOutfitNotRemovedTitle => 'Ensemble non retiré';

  @override
  String get calendarOutfitRemovedBody => 'Ensemble retiré';

  @override
  String get calendarDisconnectedBody => 'Calendrier déconnecté';

  @override
  String get calendarDisconnectedTitle => 'Déconnecté';

  @override
  String get calendarNotDisconnectedTitle => 'Calendrier non déconnecté';

  @override
  String get calendarTodayLabel => 'aujourd’hui';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count événements',
      one: '1 événement',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'de $start à $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, ensemble lié';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '« $title » sera supprimé.';
  }

  @override
  String get calendarThisAppLabel => 'Cette application';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'La synchronisation avec $provider n’est pas encore disponible. Vous pouvez toujours ajouter des événements ici.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dim';

  @override
  String get calendarWeekdayMonShort => 'Lun';

  @override
  String get calendarWeekdayTueShort => 'Mar';

  @override
  String get calendarWeekdayWedShort => 'Mer';

  @override
  String get calendarWeekdayThuShort => 'Jeu';

  @override
  String get calendarWeekdayFriShort => 'Ven';

  @override
  String get calendarWeekdaySatShort => 'Sam';

  @override
  String get calendarWeekdayMonday => 'Lundi';

  @override
  String get calendarWeekdayTuesday => 'Mardi';

  @override
  String get calendarWeekdayWednesday => 'Mercredi';

  @override
  String get calendarWeekdayThursday => 'Jeudi';

  @override
  String get calendarWeekdayFriday => 'Vendredi';

  @override
  String get calendarWeekdaySaturday => 'Samedi';

  @override
  String get calendarWeekdaySunday => 'Dimanche';

  @override
  String get outfitSavedToFavouritesBody => 'Ajouté aux favoris';

  @override
  String get outfitRemovedFromFavouritesBody => 'Retiré des favoris';

  @override
  String get outfitNotSavedTitle => 'Non enregistré';

  @override
  String get outfitLoggedAsWornBody => 'Porté aujourd\'hui.';

  @override
  String get outfitNicePickTitle => 'Bon choix';

  @override
  String get outfitRemovedBody => 'Tenue supprimée.';

  @override
  String get outfitDeletedTitle => 'Supprimé';

  @override
  String get outfitNotDeletedTitle => 'Non supprimé';

  @override
  String get outfitDuplicatedBody => 'Une copie est dans vos tenues.';

  @override
  String get outfitDuplicatedTitle => 'Dupliqué';

  @override
  String get outfitNotDuplicatedTitle => 'Non dupliqué';

  @override
  String get outfitNotSharedTitle => 'Non partagé';

  @override
  String outfitCollectionReadyBody(String name) {
    return '« $name » est prête.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Collection non créée';

  @override
  String get outfitCollectionUpdatedBody => 'Collection mise à jour.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Collection non mise à jour';

  @override
  String get outfitCollectionDeletedBody => 'Collection supprimée.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Collection non supprimée';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tenues ajoutées.',
      one: '1 tenue ajoutée.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Tenues non ajoutées';

  @override
  String get outfitPreviewNotCreatedTitle => 'Aperçu non créé';

  @override
  String get outfitGiveNameBody => 'Donnez un nom à la tenue.';

  @override
  String get outfitNameMissingTitle => 'Nom';

  @override
  String get outfitChooseAtLeastOnePieceBody =>
      'Choisissez au moins un article.';

  @override
  String outfitCreatedBody(String name) {
    return '$name est dans vos tenues.';
  }

  @override
  String get outfitSavedTitle => 'Enregistré';

  @override
  String get wardrobeAddedToFavouritesBody => 'Ajouté aux favoris';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Retiré des favoris';

  @override
  String get wardrobeNotSavedTitle => 'Non enregistré';

  @override
  String get wardrobeLoggedAsWornBody => 'Ajouté au porté d\'aujourd\'hui.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Retiré de votre garde-robe.';

  @override
  String get wardrobeDeletedTitle => 'Supprimé';

  @override
  String get wardrobeNotDeletedTitle => 'Non supprimé';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces retirées de votre garde-robe.',
      one: '1 pièce retirée de votre garde-robe.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extraction de garde-robe IA';

  @override
  String get itemAddScanJobLabel => 'Analyser';

  @override
  String get itemAddFoundEarlierBody => 'Trouvé lors d\'une analyse antérieure';

  @override
  String get itemAddLookingAtPhoto => 'Analyse de votre photo';

  @override
  String get itemAddExtractionFailedBody => 'Échec de l\'extraction';

  @override
  String get itemAddJobFailedBody => 'Échec de la tâche';

  @override
  String get itemAddConnectionLostBody => 'Connexion perdue. Réessayer.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Connexion perdue pendant le traitement.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Pièce $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Pièce';

  @override
  String get itemAddNotCancelledTitle => 'Non annulé';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pièces dans votre garde-robe.',
      one: '1 pièce dans votre garde-robe.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved des $total pièces enregistrées. Appuyez sur Enregistrer pour réessayer.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Certaines pièces non enregistrées';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Choisissez au moins une photo.';

  @override
  String get batchPhotoUnreadableBody => 'Cette photo n\'a pas pu être lue.';

  @override
  String get batchNoPhotosReadableBody =>
      'Aucune de ces photos n\'a pu être lue. Essayez d\'autres photos.';

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
      'Connexion perdue pendant le traitement. Réessayer.';

  @override
  String get batchNotCancelledTitle => 'Non annulé';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Les liens de publications ne sont pas pris en charge. Entrez un lien de profil.';

  @override
  String get batchLinkSpacesBody =>
      'Les liens ne peuvent pas contenir d\'espaces.';

  @override
  String get batchEnterProfileLinkBody =>
      'Entrez un lien de profil Instagram ou Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Entrez un lien de profil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'La page de connexion n\'a pas ouvert. Réessayer.';

  @override
  String get batchSignInBrowserBody =>
      'Connectez‑vous via votre navigateur, puis revenez à FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Connecter votre compte';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Entrez le code de votre application d’authentification.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram demande une vérification de sécurité. Connectez‑vous d’abord via votre navigateur.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Entrez à nouveau votre nom d’utilisateur et votre mot de passe.';

  @override
  String get batchSignInFailedBody =>
      'Échec de la connexion. Vérifiez votre nom d’utilisateur et votre mot de passe.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Connectez‑vous pour poursuivre l’importation.';

  @override
  String get batchAccountNotConnectedBody =>
      'Votre compte n’a pas été connecté.';

  @override
  String get batchAccountConnectedTitle => 'Compte connecté';

  @override
  String get batchNotConnectedTitle => 'Non connecté';

  @override
  String get batchImportConnectionLostBody =>
      'La connexion à l’importation a été perdue. Actualisez pour vérifier.';

  @override
  String batchPickUpToBody(int max) {
    return 'Sélectionnez jusqu’à $max photos. Nous trouvons les articles.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count sur $total photos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Préparation de la photo $done sur $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trouver des articles dans $count photos',
      one: 'Trouver des articles dans 1 photo',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Votre compte $platform utilise la connexion en deux étapes. Entrez le code à 6 chiffres de votre application d’authentification.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Ce profil $platform est privé ou nécessite une connexion pour afficher ses photos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Connecter avec $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos trouvées jusqu’ici',
      one: '1 photo trouvée jusqu’ici',
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
    return '$processed sur $total traitées · $added ajoutées · $waiting en attente · $skipped ignorées';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Analyse de la photo $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'La photo $number est la prochaine';
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
      other: '$count articles trouvés',
      one: '1 article trouvé',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos ont été ajoutées à votre garde‑robe.',
      one: '1 photo a été ajoutée à votre garde‑robe.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count photos studio de plus en cours de traitement. Vous pouvez enregistrer ce qui est prêt, ou quitter — nous vous en informerons.',
      one:
          '1 photo studio de plus en cours de traitement. Vous pouvez enregistrer ce qui est prêt, ou quitter — nous vous en informerons.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Non encore enregistré : $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces articles',
      one: '1 article',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos photos',
      one: '1 photo',
    );
    return '$_temp0 issus de $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen sélectionnés. Touchez un article pour l’ignorer.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enregistrement de $count articles',
      one: 'Enregistrement de 1 article',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enregistrer $count pièces',
      one: 'Enregistrer 1 pièce',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Votre profil corporel est enregistré.';

  @override
  String get bodyProfileSavedTitle => 'Enregistré';

  @override
  String get bodyProfileNotSavedTitle => 'Non enregistré';

  @override
  String get bodyProfileSetDefaultBody => 'Défini comme profil par défaut.';

  @override
  String get bodyProfileDeletedBody => 'Profil corporel supprimé.';

  @override
  String get bodyProfileDeletedTitle => 'Supprimé';

  @override
  String get bodyProfileNotDeletedTitle => 'Non supprimé';

  @override
  String get feedbackNotSentTitle => 'Non envoyé';

  @override
  String get feedbackSentBody =>
      'Merci. Nous lisons tous les messages et répondons si nécessaire.';

  @override
  String get feedbackSentTitle => 'Retour envoyé';

  @override
  String get recommendUnnamedPiece => 'Pièce sans nom';

  @override
  String get recommendEnterCityBody =>
      'Entrez votre ville pour des suggestions météo.';

  @override
  String get recommendWhichCityTitle => 'Quelle ville ?';

  @override
  String get aiConsentSheetTitle => 'Partage de photos avec un service IA';

  @override
  String get aiConsentSheetBody =>
      'Pour créer vos images de simulation et de photos, FitCheck AI transmet les photos que vous fournissez (y compris les images de votre visage et de votre corps) à un fournisseur d\'IA tiers de confiance (tel que OpenAI ou Google Gemini) pour traitement. Ceux-ci génèrent vos images et ne les utilisent pas pour entraîner leurs modèles dans le cadre de nos conditions. Les photos sont transmises en toute sécurité et ne sont jamais partagées à des fins publicitaires.';

  @override
  String get aiConsentSheetPermission =>
      'En continuant, vous donnez une autorisation explicite pour partager vos photos avec ces fournisseurs d\'IA à des fins de génération d\'images.';

  @override
  String get skeletonsLoadMoreFailed => 'Impossible de charger davantage.';

  @override
  String get jobsPiecesReadyTitle => 'Vos pièces sont prêtes';

  @override
  String get jobsScanStoppedTitle => 'La numérisation s\'est arrêtée';

  @override
  String get jobsNothingSavedBody => 'Rien n\'a été enregistré. Réessayez.';

  @override
  String get jobsPhotoUploadFailedBody => 'L\'envoi de la photo a échoué.';

  @override
  String get authGoogleSignInStartFailed =>
      'Impossible de démarrer la connexion Google. Veuillez réessayer.';

  @override
  String get referralAppliedTitle => 'Réferré appliqué !';

  @override
  String get billingStoreUnavailableBody =>
      'Les achats dans la boutique ne sont pas disponibles sur cet appareil.';

  @override
  String get billingPurchaseProcessingBody =>
      'Cet achat est toujours en cours de traitement. Rouvrez l\'application dans une minute pour voir votre plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'L\'envoi de l\'avatar n\'a pas renvoyé d\'URL d\'image.';

  @override
  String get rewardsDayStreakLabel => 'jours d\'affilée';

  @override
  String rewardsBestStreak(int days) {
    return 'Meilleure série de $days jours';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Accès $permission requis';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'L\'accès à $permission est actuellement refusé. Ouvrir les Réglages pour l\'autoriser, puis revenir et réessayer.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Étape $step de 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Retirer l\'image $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Retirer l\'image $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Courriel à $email. Nous examinons les signalements sous 24 heures.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Retirer $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Ajouter à « $name »';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '« $name » est supprimé. Ses pièces restent dans votre garde-robe.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Voir les $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restantes aujourd\'hui';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Photo $index échouée';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected de $max photos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Morpho $shape · Teint $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Options pour $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Le plus porté : $name, $count fois';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label : non défini';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent % d\'adéquation';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked de $max sélectionnées';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Retirer $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Priorité $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Ce forfait est facturé via $store. Modifier ou annuler dans les paramètres du compte $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gérer dans $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label : $current de $max utilisé';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Env. $seconds s restantes';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done de $total photos de studio prêtes';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready de $total photos de studio prêtes. Touchez une pièce pour passer à celle-ci.';
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
  String get profileFieldNotSet => 'Non';
}
