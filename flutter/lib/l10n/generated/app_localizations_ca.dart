// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Inici';

  @override
  String get tabPhotoshoot => 'Sessió';

  @override
  String get tabCloset => 'Armari';

  @override
  String get tabOutfits => 'Conjunts';

  @override
  String get tabMore => 'Més';

  @override
  String get actionAddItem => 'Afegir peça';

  @override
  String get actionCreateOutfit => 'Crear conjunt';

  @override
  String get actionCancel => 'Cancel·lar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Desar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionDone => 'Fet';

  @override
  String get actionNext => 'Següent';

  @override
  String get actionBack => 'Enrere';

  @override
  String get actionClose => 'Tancar';

  @override
  String get actionSearch => 'Cercar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get stateLoading => 'Carregant';

  @override
  String get stateErrorTitle => 'Alguna cosa ha anat malament';

  @override
  String get stateErrorBody =>
      'Torna-ho a provar. Si l\'error persisteix, contacta amb suport.';

  @override
  String get stateOfflineTitle => 'No tens connexió';

  @override
  String get stateOfflineBody =>
      'Connecta\'t per sincronitzar l\'armari i generar conjunts.';

  @override
  String get settingsTitle => 'Configuració';

  @override
  String get settingsAccountSection => 'Compte';

  @override
  String get settingsPreferencesSection => 'Preferències';

  @override
  String get settingsPlanBilling => 'Pla i facturació';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificacions';

  @override
  String get settingsUnits => 'Unitats de mesura';

  @override
  String get settingsAppearance => 'Aparença';

  @override
  String get settingsPrivacySection => 'Privadesa i dades';

  @override
  String get settingsAboutSection => 'Quant a';

  @override
  String get settingsSignOut => 'Tanca la sessió';

  @override
  String get settingsDeleteAccount => 'Suprimeix el compte';

  @override
  String get settingsDeleteAccountTitle => 'Vols suprimir el teu compte?';

  @override
  String get settingsDeleteAccountBody =>
      'Això eliminarà el teu armari, conjunts, fotos i perfil. No es pot desfer.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Mètric (cm, kg)';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Usa l\'idioma del dispositiu';

  @override
  String get languageSystemBody =>
      'FitCheck AI segueix l\'idioma del teu telèfon.';

  @override
  String get languageSearchHint => 'Cerca idiomes';

  @override
  String get languageCurrent => 'Actual';

  @override
  String get languageReviewNote =>
      'Aquesta traducció és nova. Digues-nos si alguna cosa no sona bé.';

  @override
  String get languageChanged => 'Idioma actualitzat';

  @override
  String get paywallTitle => 'Tria el teu pla';

  @override
  String get paywallTrialBadge => '1 mes gratis';

  @override
  String get paywallTrialTitle => 'El teu primer mes de Pro és gratis';

  @override
  String get paywallTrialBody =>
      'Puja tot el teu armari de cop. Afegeix peces a mesura que avancis.';

  @override
  String get paywallFreeForeverTitle => 'Gratis per sempre';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'No cal targeta. Cada mes tens $uploads pujades d\'IA, $outfits conjunts i $images fotos de sessió al dia.';
  }

  @override
  String get paywallCtaTrial => 'Comença el meu mes gratis';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Passa a $plan';
  }

  @override
  String get paywallRestore => 'Restaura compres';

  @override
  String get paywallManage => 'Gestiona la subscripció';

  @override
  String get paywallTerms => 'Condicions d\'ús';

  @override
  String get paywallPrivacy => 'Política de privadesa';

  @override
  String get paywallPerMonth => 'al mes';

  @override
  String get paywallPerYear => 'a l\'any';

  @override
  String get paywallBestValue => 'Millor opció';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Prova gratuïta només per a nous subscriptors. Després de la prova, Pro es renova a $price tret que es cancel·li almenys 24 hores abans que finalitzi.';
  }

  @override
  String get introTitle => 'El teu armari, per fi organitzat';

  @override
  String get introBody =>
      'Fotografia la teva roba una vegada. Rep idees de conjunts, previsualitzacions de proves i fotos d\'estudi amb el que ja tens.';

  @override
  String get introStart => 'Comença';

  @override
  String get introHaveAccount => 'Ja tinc un compte';

  @override
  String get introSkip => 'Omet';

  @override
  String get authSignIn => 'Inicia sessió';

  @override
  String get authSignUp => 'Crea un compte';

  @override
  String get authEmail => 'Correu electrònic';

  @override
  String get authPassword => 'Contrasenya';

  @override
  String get authForgotPassword => 'Has oblidat la contrasenya?';

  @override
  String get authContinueApple => 'Continua amb Apple';

  @override
  String get authContinueGoogle => 'Continua amb Google';

  @override
  String get authOrDivider => 'o';

  @override
  String get wardrobeTitle => 'Armari';

  @override
  String get wardrobeEmptyTitle => 'El teu armari està buit';

  @override
  String get wardrobeEmptyBody =>
      'Afegeix la teva primera peça o puja una foto de tot el penjador alhora.';

  @override
  String get wardrobeAddFirst => 'Afegeix el primer article';

  @override
  String get wardrobeSearchHint => 'Cerca al teu armari';

  @override
  String get categoryTops => 'Part superior';

  @override
  String get categoryBottoms => 'Part inferior';

  @override
  String get categoryShoes => 'Calçat';

  @override
  String get categoryAccessories => 'Accessoris';

  @override
  String get categoryOuterwear => 'Abrics';

  @override
  String get categorySwimwear => 'Bany';

  @override
  String get categoryActivewear => 'Roba esportiva';

  @override
  String get categoryOther => 'Altres';

  @override
  String get conditionClean => 'Net';

  @override
  String get conditionDirty => 'Brut';

  @override
  String get conditionLaundry => 'A la bugada';

  @override
  String get conditionRepair => 'Per reparar';

  @override
  String get conditionDonate => 'Per donar';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Estiu';

  @override
  String get seasonFall => 'Tardor';

  @override
  String get seasonWinter => 'Hivern';

  @override
  String get seasonAll => 'Tot l\'any';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Business';

  @override
  String get styleSporty => 'Esportiu';

  @override
  String get styleBohemian => 'Bohemi';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romàntic';

  @override
  String get styleEdgy => 'Atrevit';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artístic';

  @override
  String get styleClassic => 'Clàssic';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleOther => 'Altre';

  @override
  String get occasionWork => 'Feina';

  @override
  String get occasionDateNight => 'Cita';

  @override
  String get occasionTravel => 'Viatge';

  @override
  String get occasionWedding => 'Casament';

  @override
  String get occasionGym => 'Gimnàs';

  @override
  String get occasionWeekend => 'Cap de setmana';

  @override
  String get occasionParty => 'Festa';

  @override
  String get occasionInterview => 'Entrevista';

  @override
  String get colorBlack => 'Negre';

  @override
  String get colorWhite => 'Blanc';

  @override
  String get colorGrey => 'Gris';

  @override
  String get colorNavy => 'Blau marí';

  @override
  String get colorBrown => 'Marró';

  @override
  String get colorRed => 'Vermell';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorGreen => 'Verd';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Lila';

  @override
  String get colorYellow => 'Groc';

  @override
  String get colorOrange => 'Taronja';

  @override
  String get colorBeige => 'Beix';

  @override
  String get dateToday => 'Avui';

  @override
  String get dateYesterday => 'Ahir';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fa $count dies',
      one: 'fa 1 dia',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fa $count setmanes',
      one: 'fa 1 setmana',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fa $count mesos',
      one: 'fa 1 mes',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fa $count anys',
      one: 'fa 1 any',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'T\'agrada FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Una valoració ràpida ajuda altres persones a trobar el seu estil.';

  @override
  String get ratingPromptYes => 'Valora l\'app';

  @override
  String get ratingPromptNo => 'Ara no';

  @override
  String get closetNoMatchesTitle => 'Cap peça coincideix';

  @override
  String get closetNoMatchesBody =>
      'Prova amb menys filtres o una altra cerca.';

  @override
  String get closetClearFilters => 'Neteja filtres';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peces',
      one: '1 peça',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Carregant les teves peces';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionades',
      one: '1 seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Eliminar seleccionats';

  @override
  String get closetCancelSelection => 'Cancel·lar selecció';

  @override
  String get closetCloseSearch => 'Tancar cerca';

  @override
  String get closetShowGrid => 'Veure en graella';

  @override
  String get closetShowList => 'Veure en llista';

  @override
  String get closetShowRows => 'Veure en files';

  @override
  String get closetStatsTitle => 'Estadístiques de l\'armari';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count peces?',
      one: 'Eliminar 1 peça?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Els conjunts que les utilitzen perdran aquestes peces.';

  @override
  String get closetSortBy => 'Ordenar per';

  @override
  String get closetFavourites => 'Preferits';

  @override
  String get closetFavourite => 'Preferit';

  @override
  String get closetUnfavourite => 'Treure de preferits';

  @override
  String get closetWoreToday => 'Portat avui';

  @override
  String closetWornTimes(int count) {
    return 'Portat $count×';
  }

  @override
  String get closetCategoryLabel => 'Categoria';

  @override
  String get closetUseCaseLabel => 'Ocasió';

  @override
  String get closetAnyUseCase => 'Qualsevol';

  @override
  String get closetOtherUseCase => 'Altra ocasió';

  @override
  String get closetOtherUseCaseHint => 'Per exemple, esmorzar';

  @override
  String get closetUseUseCase => 'Utilitzar';

  @override
  String get closetClearAll => 'Netejar tot';

  @override
  String get sortNewest => 'Més recents primer';

  @override
  String get sortOldest => 'Més antics primer';

  @override
  String get sortName => 'Nom (A–Z)';

  @override
  String get sortMostWorn => 'Més utilitzats';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Cita';

  @override
  String get useCaseDinner => 'Sopar';

  @override
  String get useCaseLunch => 'Dinar';

  @override
  String get actionSelect => 'Seleccionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get actionSort => 'Ordenar';

  @override
  String get actionAll => 'Totes';

  @override
  String get dashboardStartClosetTitle => 'Comença el teu armari';

  @override
  String get dashboardStartClosetBody =>
      'Fotografia algunes peces. Nosaltres les etiquetem per tu.';

  @override
  String get dashboardPieces => 'peces';

  @override
  String get dashboardOutfits => 'conjunts';

  @override
  String get dashboardDayStreak => 'dies seguits';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count aquest mes';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Millor $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favorits',
      one: '1 favorit',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conjunts desats',
      one: '1 conjunt desat',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Més posat: $name, $count vegades';
  }

  @override
  String get setupSkip => 'Ometre configuració';

  @override
  String get setupWhoTitle => 'A qui estem vestint?';

  @override
  String get setupWhoBody =>
      'Defineix el model per a les proves i fotos. Pots canviar-ho al teu perfil.';

  @override
  String get setupStyleTitle => 'Què portes més?';

  @override
  String get setupStyleBody =>
      'Tria\'n algun. Les idees de conjunts comencen aquí.';

  @override
  String get setupClosetTitle => 'Afegeix les teves primeres peces.';

  @override
  String get setupClosetBody =>
      'Fotografia algunes peces o un munt de roba. Cada peça es retalla i es desa per tu.';

  @override
  String get setupAddClothes => 'Afegir roba';

  @override
  String get setupStylesLabel => 'Estils';

  @override
  String get setupOccasionsLabel => 'Ocasions';

  @override
  String get setupSkipStep => 'Ometre';

  @override
  String get setupLater => 'Més tard';

  @override
  String get setupSaveError => 'No s\'ha pogut desar';

  @override
  String get genderWomen => 'Dona';

  @override
  String get genderMen => 'Home';

  @override
  String get genderNonBinary => 'No binari';

  @override
  String get genderPreferNotToSay => 'Prefereixo no dir-ho';

  @override
  String get outfitEmptyTitle => 'Encara no tens conjunts';

  @override
  String get outfitEmptyBody => 'Combina peces del teu armari i desa el look.';

  @override
  String get outfitNoMatchesTitle => 'Cap conjunt coincideix';

  @override
  String get outfitSearchHint => 'Cerca als teus conjunts';

  @override
  String get outfitLoading => 'Carregant els teus conjunts';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conjunts',
      one: '1 conjunt',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Estil i temporada';

  @override
  String get outfitCollections => 'Col·leccions';

  @override
  String get outfitDuplicate => 'Duplica';

  @override
  String get outfitDeleteTitle => 'Eliminar aquest conjunt?';

  @override
  String get outfitDeleteBody => 'Les peces es quedaran al teu armari.';

  @override
  String get outfitDrafts => 'Esborranys';

  @override
  String get outfitDraft => 'Esborrany';

  @override
  String get filterStyle => 'Estil';

  @override
  String get filterSeason => 'Temporada';

  @override
  String get itemDetailDeleteTitle => 'Eliminar aquesta peça?';

  @override
  String get itemDetailDeleteBody =>
      'Els conjunts que la fan servir perdran la peça.';

  @override
  String get itemAddFavourite => 'Afegeix a favorits';

  @override
  String itemSize(String size) {
    return 'Talla $size';
  }

  @override
  String get itemColours => 'Colors';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Estampat';

  @override
  String get itemUseCases => 'Usos';

  @override
  String get itemKeptIn => 'Guardat a';

  @override
  String get itemPrice => 'Preu';

  @override
  String get itemBought => 'Comprat';

  @override
  String get itemTags => 'Etiquetes';

  @override
  String get itemAdded => 'Afegit';

  @override
  String get itemTimesWornLabel => 'vegades posat';

  @override
  String get itemLastWornLabel => 'darrer cop posat';

  @override
  String get itemNeverWorn => 'Mai';

  @override
  String get authEntryBody =>
      'Totes les teves peces, combinades per IA. Planifica conjunts, prova-te\'ls i fes-te fotos.';

  @override
  String get authCreateCloset => 'Crea el teu armari';

  @override
  String get authWelcomeBack => 'Benvingut de nou';

  @override
  String get authSignInBody => 'Inicia sessió per obrir el teu armari.';

  @override
  String get authCreateAccount => 'Crea un compte';

  @override
  String get authCreateClosetBody =>
      'Es fa en un minut. Les primeres peces són gratuïtes.';

  @override
  String get authName => 'Nom';

  @override
  String get authConfirmPassword => 'Confirma la contrasenya';

  @override
  String get authReferralCode => 'Codi de referència (opcional)';

  @override
  String get authResetTitle => 'Restableix la contrasenya';

  @override
  String get authResetBody =>
      'T\'enviarem un enllaç per correu per triar-ne una de nova.';

  @override
  String get authSendResetLink => 'Envia l\'enllaç';

  @override
  String get authBackToSignIn => 'Torna a l\'inici de sessió';

  @override
  String get authEnterEmail => 'Introdueix el teu correu';

  @override
  String get authEnterValidEmail => 'Introdueix un correu vàlid';

  @override
  String get authEnterPassword => 'Introdueix la contrasenya';

  @override
  String get authPasswordTooShort => 'Com a mínim 6 caràcters';

  @override
  String get authShowPassword => 'Mostra la contrasenya';

  @override
  String get authHidePassword => 'Amaga la contrasenya';

  @override
  String get authNewHere => 'Nou aquí?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirma $email abans d\'iniciar sessió. Comprova la teva safata d\'entrada.';
  }

  @override
  String get authResendEmail => 'Torna-ho a enviar';

  @override
  String get authResendingEmail => 'S\'està enviant...';

  @override
  String get authPasswordsDoNotMatch => 'Les contrasenyes no coincideixen';

  @override
  String get authEnterName => 'Introdueix el teu nom';

  @override
  String get authChoosePassword => 'Tria una contrasenya';

  @override
  String get authHaveAccount => 'Ja tens un compte?';

  @override
  String get authCodeAccepted => 'Codi acceptat';

  @override
  String get authCodeNotFound => 'Codi no trobat';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Tots dos rebreu un mes gratuït.';
  }

  @override
  String get authReferralInvalid => 'No hem pogut trobar aquest codi.';

  @override
  String authResetSent(String email) {
    return 'Enviat a $email. Obre l\'enllaç des d\'aquest telèfon.';
  }

  @override
  String get introSlide1Title => 'Fotografia el teu armari.';

  @override
  String get introSlide1Body =>
      'Fes una foto a la roba. Cada peça es retalla i es classifica per a tu.';

  @override
  String get introSlide2Title => 'Vesteix-te més ràpid.';

  @override
  String get introSlide2Body =>
      'Conjunts amb la teva roba, adaptats als teus plans i al temps.';

  @override
  String get introSlide3Title => 'Mira-ho abans de posar-t\'ho.';

  @override
  String get introSlide3Body =>
      'Prova els looks sobre la teva foto o fes-los com en una campanya.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Clar';

  @override
  String get settingsThemeDark => 'Fosc';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Actualitzacions per correu';

  @override
  String get settingsEmailUpdatesBody => 'Notícies i consells per correu';

  @override
  String get settingsOutfitReminders => 'Recordatoris de conjunts';

  @override
  String get settingsOutfitRemindersBody =>
      'Un avís per registrar el que has portat';

  @override
  String get settingsWeeklySummary => 'Resum setmanal';

  @override
  String get settingsWeeklySummaryBody => 'La teva setmana en conjunts';

  @override
  String get settingsStyleSection => 'Estil';

  @override
  String get settingsPreferredStyles => 'Estils que t\'agraden';

  @override
  String get settingsPreferredColours => 'Colors que t\'agraden';

  @override
  String get settingsNoneChosen => 'Cap seleccionat';

  @override
  String get settingsPlanAiSection => 'Pla i IA';

  @override
  String get settingsPlanBillingBody => 'Pla, ús i millores';

  @override
  String get settingsPlanUsageBody => 'Pla i ús';

  @override
  String get settingsInviteFriends => 'Convida amics';

  @override
  String get settingsInviteFriendsBody =>
      'Un mes gratuït per cada amic que s\'uneixi';

  @override
  String get settingsAiProvider => 'Proveïdor d\'IA';

  @override
  String get settingsAiProviderBody =>
      'Utilitza el teu propi model per etiquetar i imatges';

  @override
  String get settingsAppVersion => 'Versió de l\'app';

  @override
  String get settingsPrivacyTerms => 'Privacitat i termes';

  @override
  String get settingsReportProblem => 'Informa d\'un problema';

  @override
  String get settingsChangePassword => 'Canvia la contrasenya';

  @override
  String get settingsExportData => 'Exporta les teves dades';

  @override
  String get settingsExportBody =>
      'Prepararem un fitxer amb tot el que has desat i obrirem la descàrrega.';

  @override
  String get settingsExportAction => 'Exporta';

  @override
  String get settingsCurrentPassword => 'Contrasenya actual';

  @override
  String get settingsNewPassword => 'Nova contrasenya';

  @override
  String get settingsConfirmNewPassword => 'Confirma la nova contrasenya';

  @override
  String get settingsEnterCurrentPassword =>
      'Introdueix la teva contrasenya actual';

  @override
  String get settingsEnterNewPassword => 'Introdueix una nova contrasenya';

  @override
  String get settingsPasswordMin8 => 'Utilitza almenys 8 caràcters';

  @override
  String get settingsPasswordNeedsUpper => 'Afegeix una majúscula';

  @override
  String get settingsPasswordNeedsLower => 'Afegeix una minúscula';

  @override
  String get settingsPasswordNeedsDigit => 'Afegeix un número';

  @override
  String get settingsPasswordsNoMatch => 'Les contrasenyes no coincideixen';

  @override
  String get settingsChangeAction => 'Canvia';

  @override
  String get itemAddSnapTitle => 'Captura una peça';

  @override
  String get itemAddSnapBody =>
      'Trobem cada peça a la foto i en fem una imatge d\'estudi neta.';

  @override
  String get itemAddCamera => 'Fes una foto';

  @override
  String get itemAddGallery => 'Tria de la galeria';

  @override
  String get itemAddOtherWays => 'Altres maneres d\'afegir';

  @override
  String get itemAddSeveral => 'Afegeix diverses fotos';

  @override
  String get itemAddSeveralBody => 'Fins a 50 alhora';

  @override
  String get itemAddImportProfile => 'Importa des d\'un perfil';

  @override
  String get itemAddImportProfileBody => 'Instagram o Facebook';

  @override
  String get itemAddEnterDetails => 'Introdueix detalls manualment';

  @override
  String get itemAddEnterDetailsBody => 'No cal foto';

  @override
  String get itemManualIntro =>
      'Només cal un nom. Afegeix la resta ara o més tard.';

  @override
  String get itemManualNameHint => 'Per exemple, samarreta de cotó blava';

  @override
  String get itemManualEnterName => 'Introdueix un nom';

  @override
  String get itemManualNotes => 'Notes';

  @override
  String get itemManualBrand => 'Marca';

  @override
  String get itemManualSize => 'Talla';

  @override
  String get itemManualEnterNumber => 'Introdueix un número';

  @override
  String get itemManualSavePiece => 'Desa la peça';

  @override
  String get itemManualSaving => 'Desant';

  @override
  String get itemManualSavedTitle => 'Desat';

  @override
  String itemManualSavedBody(String name) {
    return '$name és al teu armari.';
  }

  @override
  String get itemManualNotSaved => 'No s\'ha desat';

  @override
  String get itemManualAddUseCase => 'Afegeix un ús';

  @override
  String get itemManualAddUseCaseAction => 'Afegeix ús';

  @override
  String get itemPhotos => 'Fotos';

  @override
  String get itemAddPhotos => 'Afegeix fotos';

  @override
  String get itemNoPhotoYet => 'Encara no hi ha foto. Pots desar-ho sense.';

  @override
  String get itemRemovePhoto => 'Elimina la foto';

  @override
  String get itemRemovePiece => 'Elimina la peça';

  @override
  String get filterConditionLabel => 'Estat';

  @override
  String get photoshootStepPhotos => 'Fotos';

  @override
  String get photoshootStepSetup => 'Configuració';

  @override
  String get photoshootStepCreating => 'Creant';

  @override
  String get photoshootStepResults => 'Resultats';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Pas $current de $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Una foto ha fallat. Torna-ho a provar a sota.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotos han fallat. Torna-ho a provar a sota.';
  }

  @override
  String get photoshootFormat => 'Format';

  @override
  String get photoshootHowMany => 'Quantes';

  @override
  String get photoshootYourPrompt => 'El teu prompt';

  @override
  String get photoshootPromptHint => 'Hora daurada en un terrat, camisa de lli';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crear $count fotos',
      one: 'Crear 1 foto',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotos',
      one: 'foto',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'No hem pogut comprovar el límit d\'avui.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Pla $plan: $remaining de $limit restants avui';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratuït';

  @override
  String get photoshootGallery => 'Galeria';

  @override
  String get photoshootUseCamera => 'Utilitzar càmera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Eliminar foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'No s\'ha generat cap foto';

  @override
  String get photoshootNoPhotosBody =>
      'La sessió ha finalitzat sense imatges. Torna-ho a provar.';

  @override
  String get photoshootNewStyle => 'Nou estil';

  @override
  String get photoshootNewPhotos => 'Noves fotos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Obrir foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Informar d\'una foto';

  @override
  String get photoshootSaveToGallery => 'Desar a la galeria';

  @override
  String get actionUpgrade => 'Actualitzar';

  @override
  String get referralLimitTitle => 'Has esgotat les fotos d\'avui';

  @override
  String get referralLimitBody =>
      'Les teves fotos gratuïtes es renoven demà. Convida un amic i tots dos obtindreu un mes de Pro gratis.';

  @override
  String get referralLimitRefer => 'Convida un amic';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'App de cites';

  @override
  String get photoshootUsePortfolio => 'Portfoli';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estètica';

  @override
  String get photoshootUseCustom => 'El teu propi prompt';

  @override
  String get photoshootDescLinkedin => 'Fotos professionals per a la feina';

  @override
  String get photoshootDescDating => 'Relaxat, càlid i natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, looks d\'alta costura';

  @override
  String get photoshootDescInstagram => 'Lifestyle per al teu feed';

  @override
  String get photoshootDescAesthetic => 'Enquadraments artístics i moody';

  @override
  String get photoshootDescCustom => 'Descriu el look que vols';

  @override
  String get aspectSquare => 'Quadrat';

  @override
  String get aspectPortrait => 'Retrat';

  @override
  String get aspectLandscape => 'Apaïsat';

  @override
  String get aspectTall => 'Alt';

  @override
  String get aspectWide => 'Ample';

  @override
  String get tryOnAppBar => 'Emprovador virtual';

  @override
  String get tryOnYourPhoto => 'La teva foto';

  @override
  String get tryOnGarment => 'Peça de roba';

  @override
  String get tryOnUploadingPhoto => 'Pujant la teva foto';

  @override
  String get tryOnAddPhotoPrompt => 'Afegeix una foto de cos sencer';

  @override
  String get tryOnBodyPhotoHint => 'Una foto de cos sencer funciona millor';

  @override
  String get tryOnAddPhoto => 'Afegeix foto';

  @override
  String get tryOnChangePhoto => 'Canvia la foto';

  @override
  String get tryOnPhotoLoadFailed => 'No hem pogut carregar la teva foto.';

  @override
  String get tryOnChooseGarment => 'Tria una foto de la peça';

  @override
  String get tryOnChooseOneGarment => 'Tria una foto de la peça';

  @override
  String get tryOnGarmentHint => 'Una foto en pla o penjada funciona millor';

  @override
  String get tryOnChange => 'Canvia';

  @override
  String get tryOnCamera => 'Càmera';

  @override
  String get tryOnRemove => 'Elimina';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Estil';

  @override
  String get tryOnBackground => 'Fons';

  @override
  String get tryOnPose => 'Posat';

  @override
  String get tryOnDressingUp => 'Et vestim. Triga aproximadament mig minut.';

  @override
  String get tryOnEmptyResult => 'La teva prova apareixerà aquí';

  @override
  String get tryOnReportImage => 'Informa d\'una imatge';

  @override
  String get tryOnCreating => 'Creant';

  @override
  String get tryOnTryAgain => 'Torna-ho a provar';

  @override
  String get tryOnCreate => 'Crea una prova';

  @override
  String get tryOnBackgroundStudioWhite => 'Estudi blanc';

  @override
  String get tryOnBackgroundStudioGrey => 'Estudi gris';

  @override
  String get tryOnBackgroundUrban => 'Carrer urbà';

  @override
  String get tryOnBackgroundNature => 'Natura';

  @override
  String get tryOnBackgroundMinimal => 'Minimalista';

  @override
  String get tryOnPoseFront => 'Dret frontal';

  @override
  String get tryOnPoseSide => 'Dret de costat';

  @override
  String get tryOnPoseWalking => 'Caminant';

  @override
  String get dashboardGreetingMorning => 'Bon dia';

  @override
  String get dashboardGreetingAfternoon => 'Bona tarda';

  @override
  String get dashboardGreetingEvening => 'Bon vespre';

  @override
  String get dashboardWelcome => 'Benvingut';

  @override
  String get dashboardOpenProfile => 'Obre el perfil';

  @override
  String get dashboardRailToday => 'Avui';

  @override
  String get dashboardRailRecently => 'Recentment';

  @override
  String get dashboardActivityEmpty =>
      'Les noves peces i conjunts apareixeran aquí.';

  @override
  String get quickAddPiece => 'Afegeix una peça';

  @override
  String get quickAddPieceBody => 'Fotografia i etiqueta';

  @override
  String get quickBuildOutfit => 'Crea un conjunt';

  @override
  String get quickBuildOutfitBody => 'Combina les teves peces';

  @override
  String get quickForYou => 'Per a tu';

  @override
  String get quickForYouBody => 'Seleccions per avui';

  @override
  String get quickPlanWeek => 'Planifica la setmana';

  @override
  String get quickPlanWeekBody => 'Conjunts per data';

  @override
  String get referralBannerUrgent => 'Et queda poc? Convida un amic.';

  @override
  String get referralBannerTitle => 'Regala un mes, aconsegueix-ne un.';

  @override
  String get referralBannerBody => 'Tu i el teu amic rebreu un mes de Pro.';

  @override
  String get referralBannerDismiss => 'Ignora durant una setmana';

  @override
  String get referralBannerShare => 'Comparteix la invitació';

  @override
  String get referralBannerCopy => 'Copia l\'enllaç';

  @override
  String get itemEditPieceTitle => 'Edita la peça';

  @override
  String get itemEditDescriptionLabel => 'Descripció';

  @override
  String get itemEditNotSaved => 'No s\'ha desat';

  @override
  String get itemEditSavedTitle => 'Desat';

  @override
  String get itemEditSavedBody => 'Els canvis s\'han desat.';

  @override
  String get itemEditSavedStalePhotos =>
      'Desat — les fotos podrien estar desactualitzades';

  @override
  String get itemEditRemovePieceHint =>
      'Suprimeix aquesta peça de la pàgina de l\'article.';

  @override
  String get itemEditNoPhotos =>
      'Encara no hi ha fotos. Afegeix-ne una des de la galeria o la càmera.';

  @override
  String get itemEditKeepPhoto => 'Mantén la foto';

  @override
  String get itemEditRemoved => 'Suprimit';

  @override
  String get itemEditAddUseCaseAction => 'Afegeix';

  @override
  String get statsNoStatsTitle => 'Encara no hi ha estadístiques';

  @override
  String get statsNoStatsBody =>
      'Afegeix algunes peces i la teva combinació d\'armari apareixerà aquí.';

  @override
  String get statsByCategory => 'Per categoria';

  @override
  String get statsTotalValue => 'valor total';

  @override
  String get statsMostWorn => 'Més utilitzat';

  @override
  String get statsLeastWorn => 'Esperant el seu torn';

  @override
  String get statsUnnamedPiece => 'Peça sense nom';

  @override
  String get jobsTitle => 'Escanejos';

  @override
  String get jobsEmptyTitle => 'Encara no hi ha escanejos';

  @override
  String get jobsEmptyBody =>
      'Fes una foto a una peça i envia-la al segon pla; continuarà treballant aquí.';

  @override
  String get jobsNotCancelled => 'No s\'ha cancel·lat';

  @override
  String get jobsResume => 'Reprèn';

  @override
  String get jobsReview => 'Revisa';

  @override
  String get jobsStop => 'Atura';

  @override
  String get jobsDismiss => 'Ignora';

  @override
  String get reportTitle => 'Informa de contingut';

  @override
  String reportIntro(String contentType) {
    return 'Digues-nos què falla en aquest $contentType. El nostre equip revisa cada informe.';
  }

  @override
  String get reportReasonInappropriate => 'Inapropiat o ofensiu';

  @override
  String get reportReasonNudity => 'Nuesa o contingut sexual';

  @override
  String get reportReasonHarassment => 'Assetjament o abús';

  @override
  String get reportReasonImpersonation => 'Suplantació d\'identitat';

  @override
  String get reportReasonOther => 'Altres';

  @override
  String get reportDetailsLabel => 'Detalls addicionals (opcional)';

  @override
  String get reportSubmit => 'Envia l\'informe';

  @override
  String get reportSubmittedTitle => 'Informe enviat';

  @override
  String get reportSubmittedBody =>
      'Gràcies. El nostre equip revisarà aquest contingut.';

  @override
  String get reportFailedTitle => 'No s\'ha pogut enviar l\'informe';

  @override
  String get reportFailedBody => 'Torna-ho a provar.';

  @override
  String get reportContentTryOnImage => 'imatge de prova virtual';

  @override
  String get reportContentSharedOutfit => 'conjunt compartit';

  @override
  String get reportContentPhotoshootImage => 'imatge de sessió fotogràfica';

  @override
  String get sharedOutfitTitle => 'Conjunt compartit';

  @override
  String get sharedOutfitHideTooltip => 'Amaga aquest conjunt';

  @override
  String get sharedOutfitReportTooltip => 'Informa d\'aquest conjunt';

  @override
  String get sharedOutfitHideTitle => 'Amagar aquest conjunt?';

  @override
  String get sharedOutfitHideBody =>
      'Romandrà ocult en aquest dispositiu. També pots informar-ne perquè el nostre equip el revisi i l\'elimini.';

  @override
  String get sharedOutfitHideAction => 'Amaga';

  @override
  String get sharedOutfitHiddenInfo =>
      'Aquest conjunt no es tornarà a mostrar en aquest dispositiu.';

  @override
  String get sharedOutfitHiddenToast => 'Conjunt ocult';

  @override
  String get sharedOutfitMissingTitle => 'Aquest conjunt ja no és aquí';

  @override
  String get sharedOutfitMissingBody =>
      'Pot haver estat eliminat o l\'enllaç és incorrecte.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Has amagat aquest conjunt';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Si és inadequat, informa\'n des de Privadesa i condicions o envia un correu a $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'T\'agrada aquest look?';

  @override
  String get sharedOutfitCtaBody =>
      'Crea conjunts similars amb la teva pròpia roba.';

  @override
  String get sharedOutfitCtaButton => 'Obtén FitCheck AI';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnknown => 'S\'ha produït un error inesperat';

  @override
  String get errorNoConnection =>
      'No hi ha connexió a internet. Comproveu la xarxa.';

  @override
  String get errorTimeout =>
      'La sol·licitud ha excedit el temps. Intenteu-ho de nou.';

  @override
  String get errorServerError =>
      'S\'ha produït un error del nostre costat. Intenteu-ho de nou.';

  @override
  String get errorBadGateway =>
      'El servidor no està disponible breu. Intenteu-ho de nou.';

  @override
  String get errorServiceUnavailable =>
      'El servei no està disponible temporalment. Intenteu-ho més tard.';

  @override
  String get errorInternalError =>
      'S\'ha produït un error. Intenteu-ho de nou.';

  @override
  String get errorUnauthorized => 'Inicieu sessió per continuar.';

  @override
  String get errorForbidden => 'No teniu accés a això.';

  @override
  String get errorSessionExpired =>
      'La vostra sessió ha caducat. Inicieu sessió de nou.';

  @override
  String get errorInvalidCredentials =>
      'Aquest correu o contrasenya no són correctes.';

  @override
  String get errorTokenRefreshFailed =>
      'No s\'ha pogut renovar la sessió. Inicieu sessió de nou.';

  @override
  String get errorRequestCancelled => 'Sol·licitud cancel·lada.';

  @override
  String get errorInvalidFormat => 'Aquest format d\'arxiu no és compatible.';

  @override
  String get errorFileTooLarge => 'Aquest arxiu és massa gran.';

  @override
  String get errorUploadFailed => 'La càrrega ha fallat. Intenteu-ho de nou.';

  @override
  String get errorCacheCorrupted =>
      'Les dades desades s\'han malmès i s\'han restablert.';

  @override
  String get errorCacheNotFound => 'Encara no s\'ha desat res.';

  @override
  String get errorUserNotFound => 'No s\'ha pogut trobar aquest compte.';

  @override
  String get errorItemNotFound => 'Aquest article ja no existeix.';

  @override
  String get errorOutfitNotFound => 'Aquest conjunt ja no existeix.';

  @override
  String get rewardsTitle => 'Recompenses';

  @override
  String get rewardsNoAchievementsTitle => 'Encara no hi ha assoliments';

  @override
  String get rewardsNoAchievementsBody =>
      'Afegeix peces i planifica conjunts per guanyar el primer.';

  @override
  String get rewardsEmptyLeaderboardTitle =>
      'Encara no hi ha ningú a la classificació';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planifica conjunts per guanyar punts i aparèixer aquí.';

  @override
  String get legalViewPrivacyPolicy => 'Mostra la Política de Privadesa';

  @override
  String get aiConsentAgree => 'Accepto i Continuo';

  @override
  String get aiConsentNotNow => 'No ara';

  @override
  String get imageViewerCloseTooltip => 'Tanca el visor d\'imatges';

  @override
  String get updateReadyTitle => 'Actualització preparada';

  @override
  String get updateReadyBody =>
      'Reinicia FitCheck AI per aplicar les milloracions més recents.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI necessita accés a la càmera per fer fotos dels teus conjunts i articles del vestidor.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI necessita accés a la biblioteca de fotos per seleccionar imatges dels teus conjunts i articles del vestidor.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI necessita guardar les fotos de conjunts generades per IA a la teva biblioteca de fotos.';

  @override
  String get wardrobeSomePhotosSkipped => 'Algunes fotos omeses';

  @override
  String get wardrobePhotosNotAdded => 'Fotos no afegides';

  @override
  String get wardrobePhotoNotAdded => 'Foto no afegida';

  @override
  String get wardrobeNotStartedTitle => 'No començat';

  @override
  String get wardrobeNoRoomTitle => 'Sense espai';

  @override
  String get wardrobeAddPhotosSemantic => 'Afegeix fotos';

  @override
  String get batchAddTileLabel => 'Afegir';

  @override
  String get batchProfileLinkLabel => 'Enllaç al perfil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importa des d\'un perfil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Afegeix diverses fotos';

  @override
  String get wardrobeClearAction => 'Esborra';

  @override
  String get wardrobeRefreshTooltip => 'Actualitza';

  @override
  String get batchNoPhotosYetTitle => 'Encara no hi ha fotos';

  @override
  String get batchChoosePhotosAction => 'Tria fotos';

  @override
  String get batchWeFindEachPieceBody =>
      'Trobem cada peça i fem-ne una foto d\'estudi.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparant fotos';

  @override
  String get batchPhotosProcessedSemantic => 'Fotes processades';

  @override
  String get batchPasteProfileLinkTitle => 'Enganxa un enllaç de perfil';

  @override
  String get batchPasteProfileLinkBody =>
      'Un perfil públic d\'Instagram o Facebook. Escanejam les seves fotos i tu trius què va al vestidor.';

  @override
  String get batchClearLinkTooltip => 'Esborra l\'enllaç';

  @override
  String get batchStartingButton => 'Iniciant';

  @override
  String get batchStartImportAction => 'Comença la importació';

  @override
  String get batchReviewEveryPhotoTitle => 'Revises cada foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Res s\'afegeix fins que no l\'aprovis.';

  @override
  String get batchPrivateProfilesTitle => 'Perfils privats';

  @override
  String get batchPrivateProfilesBody =>
      'Connecta el teu compte. Instagram també demana un nom d\'usuari i una contrasenya.';

  @override
  String get batchUseAnotherLinkAction => 'Usa un altre enllaç';

  @override
  String get batchSignInNeededTitle => 'Cal iniciar sessió';

  @override
  String get batchEnterYourCodeTitle => 'Introdueix el teu codi';

  @override
  String get batchUseUsernamePasswordAction =>
      'Usa nom d\'usuari i contrasenya';

  @override
  String get batchAlreadyConnectedAction => 'Ja he conectat pel navegador';

  @override
  String get batchEnterCodeAction => 'Introdueix el codi';

  @override
  String get batchTryAnotherWayAction => 'Prova una altra manera';

  @override
  String get batchLiveStatus => 'En directe';

  @override
  String get batchReconnectingStatus => 'Reconnectant';

  @override
  String get batchSignInToInstagramTitle => 'Inicia sessió a Instagram';

  @override
  String get batchUsernameLabel => 'Nom d\'usuari';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Codi, si fas servir inici de sessió en dos passos';

  @override
  String get batchAuthenticatorCodeBody =>
      'Fes servir el codi de 6 xifres de la teva app autenticadora. Els codis canvien ràpidament.';

  @override
  String get batchVerifyAction => 'Verifica';

  @override
  String get batchFindingPhotosTitle => 'Cercant fotos';

  @override
  String get batchImportPausedTitle => 'Importada en pausa';

  @override
  String get batchProcessingPhotosTitle => 'Processant fotos';

  @override
  String get batchWaitingNextPhoto => 'Esperant la foto següent';

  @override
  String get batchCancelImportAction => 'Cancel·la la importació';

  @override
  String get batchNoPiecesInPhotoBody =>
      'No s\'han trobat peces en aquesta foto.';

  @override
  String get batchEditPieceColoursLabel => 'Colors, separats per comes';

  @override
  String get batchAddToClosetAction => 'Afegeix a l\'armari';

  @override
  String get batchSkipPhotoAction => 'Salta aquesta foto';

  @override
  String get batchImportCompleteTitle => 'Importada completada';

  @override
  String get batchImportFailedTitle => 'Importada fallida';

  @override
  String get batchImportCancelledTitle => 'Importada cancel·lada';

  @override
  String get batchImportErrorBody => 'Ha passat alguna cosa en importar.';

  @override
  String get batchNothingMoreImportedBody =>
      'No s\'importa res més d\'aquest perfil.';

  @override
  String get batchViewClosetAction => 'Veure armari';

  @override
  String get batchStartOverAction => 'Començar de nou';

  @override
  String get wardrobeAddPieceTitle => 'Afegir peça';

  @override
  String get wardrobeAddDetailsTitle => 'Afegir detalls';

  @override
  String get wardrobeScanningTitle => 'Escaneig';

  @override
  String get batchReviewPiecesTitle => 'Revisar peces';

  @override
  String get wardrobeGalleryAction => 'Galeria';

  @override
  String get wardrobeCameraAction => 'Càmera';

  @override
  String get wardrobeNewBadge => 'Nou';

  @override
  String get wardrobeRemovePhotoTooltip => 'Eliminar foto';

  @override
  String get batchRunInBackgroundTooltip => 'Executar en segon pla';

  @override
  String get batchStepOneOfTwo => 'Pas 1 de 2';

  @override
  String get batchStepTwoOfTwo => 'Pas 2 de 2';

  @override
  String get batchUploadingPhotosTitle => 'Carregant fotos';

  @override
  String get batchFindingPiecesTitle => 'Buscant peces';

  @override
  String get batchMakingStudioPhotosTitle => 'Fent fotos d\'estudi';

  @override
  String get batchStoppedLabel => 'Aturat';

  @override
  String get batchFindingPiecesStoppedTitle => 'La cerca de peces s\'ha aturat';

  @override
  String get batchCancelledLabel => 'Cancel·lat';

  @override
  String get batchAllDoneTitle => 'Tot fet';

  @override
  String get batchOpeningPiecesBody => 'Obrint les teves peces';

  @override
  String get batchNothingSavedBody => 'No s\'ha guardat res.';

  @override
  String get batchFindingPiecesFailedBody => 'La cerca de peces ha fallat.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'La cerca de peces s\'ha aturat abans d\'hora.';

  @override
  String get batchStopFindingPiecesTitle => 'Aturar la cerca de peces?';

  @override
  String get batchStopFindingPiecesBody =>
      'L\'escaneig s\'atura i no es guarda res. Les peces ja trobades es mantindran a la teva activitat fins que les treguis.';

  @override
  String get batchKeepGoingAction => 'Continuar';

  @override
  String get batchTryAgainAction => 'Tornar-ho a provar';

  @override
  String get batchBackToPhotosAction => 'Tornar a les fotos';

  @override
  String get batchSkipAllAction => 'Ometre-ho tot';

  @override
  String get batchIncludeAllAction => 'Inclou-ho tot';

  @override
  String get batchNoPiecesFoundTitle => 'No s\'han trobat peces';

  @override
  String get batchNoPiecesFoundBody => 'No hem trobat roba en aquestes fotos.';

  @override
  String get batchChooseOtherPhotosAction => 'Tria altres fotos';

  @override
  String get batchUseCaseHelper => 'Afegit a cada peça que guardis.';

  @override
  String get batchDiscardPiecesTitle => 'Vols descartar aquestes peces?';

  @override
  String get batchDiscardPiecesBody => 'Res d\'aquest lot es guarda.';

  @override
  String get batchKeepAction => 'Mantenir';

  @override
  String get batchDiscardAction => 'Descartar';

  @override
  String get batchRemovePieceTitle => 'Vols eliminar aquesta peça?';

  @override
  String get batchRemovePieceBody => 'No es guarda al teu armari.';

  @override
  String get batchRemoveAction => 'Elimina';

  @override
  String get batchChoosePiecesToSave => 'Tria les peces a guardar';

  @override
  String get batchDiscardAllAction => 'Descarta-ho tot';

  @override
  String get batchNothingSavedRetryBody =>
      'Res s\'ha guardat. Torna-ho a provar.';

  @override
  String get batchNotSavedTitle => 'No guardat';

  @override
  String get batchSavingLabel => 'S\'està guardant';

  @override
  String get batchSendToBackgroundAction => 'Passa a segon pla';

  @override
  String get batchStillWorkingMessage =>
      'Encara estem treballant. Et donarem avis quan les teves peces estiguin llestes.';

  @override
  String get batchRunningInBackgroundTitle => 'Espera en segon pla';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Les fotos de estudi s\'han aturat abans d\'hora. Encara pots guardar aquestes peces.';

  @override
  String get batchTapPieceToSkip => 'Toca una peça per ometre-la.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Les fotos de estudi encara van en camí. Pots anar-te\'n — et donarem avis.';

  @override
  String get batchLeaveAction => 'Surt';

  @override
  String get batchPeopleInPhotosTitle => 'Persones a les fotos';

  @override
  String get batchIncludeAction => 'Inclou';

  @override
  String get batchSkipAction => 'Omet';

  @override
  String get batchYourPhotoIsUsedLabel => 'S\'usa la teva foto';

  @override
  String get batchMakingStudioPhotoLabel => 'Es crea una foto de estudi';

  @override
  String get batchNoStudioPhotoBody => 'Sense foto de estudi. S\'usa la teva.';

  @override
  String get batchEnterDetailsYourselfAction =>
      'Introdueix les dades tu mateix';

  @override
  String get batchChooseAnotherPhotoAction => 'Tria una altra foto';

  @override
  String get batchConnectionLostTitle => 'Connexió perduda';

  @override
  String get batchConnectionLostBody =>
      'Comprova la connexió i torna-ho a provar.';

  @override
  String get batchDailyLimitTitle => 'Límit diari assolit';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Passa a Pro per fer més escanejos o introdueix les dades tu mateix.';

  @override
  String get batchDailyLimitBodyFree =>
      'Els escanejos es reinicien demà. Ara pots introduir les dades tu mateix.';

  @override
  String get batchSeePlansAction => 'Veure plans';

  @override
  String get batchAiBusyTitle => 'La nostra IA està ocupada';

  @override
  String get batchAiBusyBody =>
      'Això depèn de nosaltres. Torna-ho a provar en pocs minuts.';

  @override
  String get batchNoPiecesBody =>
      'Prova una foto més nítida o introdueix les dades tu mateix.';

  @override
  String get batchScanningUnavailableTitle => 'L\'escaneig no està disponible';

  @override
  String get batchScanningUnavailableBody =>
      'Per ara, introdueix les dades tu mateix.';

  @override
  String get batchScanDidNotFinishTitle => 'L\'escaneig no s\'ha completat';

  @override
  String get batchTryAgainBody => 'Torna-ho a provar.';

  @override
  String get billingTitle => 'Subscripció';

  @override
  String get billingUpgradeHeading => 'Amplia el teu pla';

  @override
  String get billingUpgradeOnPlusBody => 'Mateixes funcions, límits més alts.';

  @override
  String get billingUpgradeBody =>
      'Plus i Pro tenen les mateixes funcions. Tria els límits que necessitis.';

  @override
  String get billingWebUnavailableBody =>
      'Les ampliacions en línia encara no estan disponibles. Un codi de promo o referència activa Plus o Pro. Convida amics a la secció de sota per guanyar mesos gratuïts.';

  @override
  String get billingPlansStale =>
      'No s\'han pogut carregar els plans més recents. Els preus poden estar desactualitzats.';

  @override
  String get billingMonthly => 'Mensual';

  @override
  String get billingYearly => 'Anual';

  @override
  String get billingCurrentPlan => 'Pla actual';

  @override
  String get billingActive => 'Actiu';

  @override
  String get billingThisMonth => 'Aquest mes';

  @override
  String get billingItemExtractions => 'Extraccions d\'articles';

  @override
  String get billingOutfitVisualizations => 'Visualitzacions de conjunts';

  @override
  String get billingNearLimitUpgrade =>
      'Et queden pocs límits d\'aquest mes. Amplia per aconseguir-ne més.';

  @override
  String get billingNearLimitResets =>
      'Et queden pocs límits d\'aquest mes. Es reinicien a l\'inici del mes vinent.';

  @override
  String get billingStoreUnavailable =>
      'Els millores encara no estan disponibles a la botiga. Torna a consultar-lo aviat.';

  @override
  String get billingManageHeading => 'Gestiona el teu pla';

  @override
  String get billingCancelPlan => 'Cancel·la la subscripció';

  @override
  String get billingCancelKeepsAccess =>
      'Mantindràs l\'accés fins al final d\'aquest període de facturació.';

  @override
  String get billingCancelConfirmTitle => 'Vols cancel·lar la subscripció?';

  @override
  String get billingKeepPlan => 'Manté el pla';

  @override
  String get billingCancelPlanAction => 'Cancel·la el pla';

  @override
  String get billingBilledMonthly => 'Facturació mensual';

  @override
  String get billingBilledYearly => 'Facturació anual';

  @override
  String get billingVirtualTryOn => 'Prova virtual';

  @override
  String get billingPrioritySupport => 'Assistència prioritària';

  @override
  String get billingDisclosureProRenewing =>
      'Pro és una subscripció de renovació automàtica';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus i Pro són subscripcions de renovació automàtica';

  @override
  String get billingDisclosureAppleBilling =>
      'El pagament es debitarà al teu ID d\'Apple en confirmar la compra.';

  @override
  String get billingDisclosureGoogleBilling =>
      'El pagament es debitarà al teu compte de Google Play en confirmar la compra.';

  @override
  String get billingDisclosureRenewalTerms =>
      'La teva subscripció es renova automàticament pel mateix període i al mateix preu, llevat que desactivis la renovació automàtica al menys 24 hores abans que acabi el període actual.';

  @override
  String get billingDisclosureAppleManage =>
      'Gestiona o cancel·la quan vulguis a Config. › el teu ID d\'Apple › Subscripcions.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gestiona o cancel·la quan vulguis a Google Play › Pagaments i subscripcions.';

  @override
  String get billingReferFriend => 'Recomana un amic';

  @override
  String get billingHowItWorks => 'Com funciona';

  @override
  String get billingHowShareTitle => 'Comparteix el teu enllaç';

  @override
  String get billingHowShareBody => 'Envia\'l a un amic.';

  @override
  String get billingHowSignUpTitle => 'Ells es registren';

  @override
  String get billingHowSignUpBody =>
      'El teu amic hi participa a través de l\'enllaç.';

  @override
  String get billingHowBothTitle => 'Ambdós teniu Pro';

  @override
  String get billingHowBothBody =>
      'Cada un de vosaltres rep un mes de Pro gratuït.';

  @override
  String get billingYourReferrals => 'Els teus referents';

  @override
  String get billingInvited => 'Invitat';

  @override
  String get billingJoined => 'S\'ha unit';

  @override
  String get billingMonthsEarned => 'Mesos guanyats';

  @override
  String get billingInviteFriend => 'Convida un amic';

  @override
  String get billingInviteBody => 'Tu i el teu amic teniu un mes de Pro.';

  @override
  String get billingYourCode => 'El teu codi';

  @override
  String get billingCopyLink => 'Copia el enllaç';

  @override
  String get billingShareInvite => 'Comparteix la invitació';

  @override
  String get giftUnavailable =>
      'Les invitacions de regal no estan disponibles en aquesta versió.';

  @override
  String get giftPageTitle => 'Regala FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'No hi ha invitacions de regal disponibles ara mateix.';

  @override
  String get giftFormTitle => 'Envia una invitació gratuïta';

  @override
  String get giftFormBody =>
      'El destinatari reclama el regal amb aquest correu verificat. No enviem el correu per tu.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nom del destinatari';

  @override
  String get giftFieldRecipientEmail => 'Correu del destinatari';

  @override
  String get giftFieldOccasion => 'Motiu (opcional)';

  @override
  String get giftNoOccasion => 'Sense motiu';

  @override
  String get giftOccasionBirthday => 'Aniversari';

  @override
  String get giftOccasionAnniversary => 'Aniversari';

  @override
  String get giftOccasionOther => 'Altres';

  @override
  String get giftFieldCardGreeting => 'Salutació de la targeta';

  @override
  String get giftFieldCardGreetingHelper =>
      'Això apareix a la targeta tal com s\'escriu.';

  @override
  String get giftFieldPrivateNote => 'Nota privada (opcional)';

  @override
  String get giftCreateAction => 'Crea regal gratuït';

  @override
  String get giftClaimedTitle => 'Regal reclamat';

  @override
  String get giftClaimedActive => 'El teu regal de FitCheck Pro està actiu.';

  @override
  String get giftClaimedQueued =>
      'El teu regal de FitCheck Pro comença després del teu accés actual.';

  @override
  String get giftLinkCopied => 'Enllaç del regal copiat al portapapers.';

  @override
  String get giftErrorName => 'Introdueix un nom.';

  @override
  String get giftErrorEmail => 'Introdueix una adreça de correu vàlida.';

  @override
  String get giftErrorGreeting => 'Introdueix la salutació de la targeta.';

  @override
  String get giftErrorGreetingLength => 'Fes servir com a màxim 80 caràcters.';

  @override
  String get giftClaimAction => 'Reclama el regal';

  @override
  String get giftCardPreview => 'Vista prèvia de la targeta';

  @override
  String get giftGiftForYou => 'Un regal per a tu';

  @override
  String get giftGiftWaiting => 'Un regal t\'espera';

  @override
  String get giftOpenBody =>
      'Obre els regals per reclamar-los amb el correu verificat.';

  @override
  String get giftOpenGifts => 'Obre regals';

  @override
  String get giftSendInvitation => 'Envia invitació';

  @override
  String get settingsAiProviderSection => 'Proveïdor';

  @override
  String get settingsAiCustom => 'Personalitzat';

  @override
  String get settingsAiUrlHelper =>
      'Usa una URL pública que el servidor pugui arribar. L\'localhost no funciona des dels nostres servidors.';

  @override
  String get settingsAiConnectionSection => 'Connexió';

  @override
  String get settingsAiApiUrl => 'URL de l\'API';

  @override
  String get settingsAiApiKey => 'Clau de l\'API';

  @override
  String get settingsAiApiKeySaved =>
      'Desat. Deixa-ho en blanc per mantenir-lo.';

  @override
  String get settingsAiChatModel => 'Model de xat';

  @override
  String get settingsAiVisionModel => 'Model de visió (opcional)';

  @override
  String get settingsAiImageModel => 'Model d\'imatge (opcional)';

  @override
  String get settingsAiImageModelNote =>
      'La generació d\'imatges requereix completaments de xat compatibles amb OpenAI amb response_modalities.';

  @override
  String get settingsAiTestConnection => 'Prova la connexió';

  @override
  String get calendarTitle => 'Calendari';

  @override
  String get calendarGoToToday => 'Anar a avui';

  @override
  String get calendarConnectTooltip => 'Connecta un calendari';

  @override
  String get calendarAddEvent => 'Afegeix esdeveniment';

  @override
  String get calendarEmptyTitle => 'Res a punt';

  @override
  String get calendarEmptyBody =>
      'Afegeix un esdeveniment i planifica què posar-t\'hi.';

  @override
  String get calendarPreviousMonth => 'Mes anterior';

  @override
  String get calendarNextMonth => 'Mes següent';

  @override
  String get calendarAllDay => 'Tot el dia';

  @override
  String get calendarOutfitLinked => 'Look vinculat';

  @override
  String get calendarEventOptions => 'Opcions de l\'esdeveniment';

  @override
  String get calendarDeleteTitle => 'Vols eliminar aquest esdeument?';

  @override
  String get calendarChangeOutfit => 'Canvia el vestit';

  @override
  String get calendarLinkOutfit => 'Vincula un vestit';

  @override
  String get calendarRemoveOutfit => 'Suprimeix el vestit';

  @override
  String get calendarNewEvent => 'Novell esdeument';

  @override
  String get calendarEditEvent => 'Edita l\'esdeument';

  @override
  String get calendarTitleLabel => 'Títol';

  @override
  String get calendarTitleRequired => 'Afegeix un títol';

  @override
  String get calendarEndBeforeStart => 'Final després de l\'inici';

  @override
  String get calendarStarts => 'Comença';

  @override
  String get calendarEnds => 'Acaba';

  @override
  String get calendarPlaceOptional => 'Lloc (opcional)';

  @override
  String get calendarNotesOptional => 'Notes (opcional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Crea un vestit i vincula\'l a aquest esdeument.';

  @override
  String get calendarBuildOutfit => 'Crea un vestit';

  @override
  String get calendarConnectionsTitle => 'Calendaris';

  @override
  String get calendarConnectionsBody =>
      'Els esdeuaments que afegeixis aquí es conserven a FitCheck.';

  @override
  String get calendarDisconnect => 'Desconnecta';

  @override
  String get calendarNotAvailable => 'No disponible encara';

  @override
  String get profileSectionExplore => 'Explora';

  @override
  String get profileNavTryOn => 'Prova\'t';

  @override
  String get profileNavRewards => 'Recompenses';

  @override
  String get profileSupport => 'Assistència';

  @override
  String get profileHelp => 'Ajuda';

  @override
  String get profileAbout => 'Quant a nosaltres';

  @override
  String get profileAboutBody =>
      'El teu armari, vestits i plans en un sol lloc.';

  @override
  String get profileSignOutTitle => 'Vols tancar la sessió?';

  @override
  String get profileSignOutBody => 'Pots tornar a entrar sempre que vulguis.';

  @override
  String get profileEditTitle => 'Edita el perfil';

  @override
  String get profileYourProfile => 'El teu perfil';

  @override
  String get profileBodyProfiles => 'Perfils cos';

  @override
  String get profileBodyEmptyTitle => 'Encara no hi ha perfils';

  @override
  String get profileBodyEmptyBody =>
      'Afegeix l\'alçada i la constitució per a un ajust millor.';

  @override
  String get profileBodyAdd => 'Afegeix un perfil';

  @override
  String get profileBodyDefaultNote =>
      'El teu perfil predeterminat s\'utilitza per a l\'ajust i el probat.';

  @override
  String get profileBodyDefaultBadge => 'Predeterminat';

  @override
  String get profileBodyMakeDefault => 'Fes predeterminat';

  @override
  String get profileBodyDeleteBody => 'No es pot desfer.';

  @override
  String get profileBodyRequired => 'Obligatori';

  @override
  String get profileBodyCheckNumber => 'Comprova aquest número';

  @override
  String get profileBodyNew => 'Nou perfil corporal';

  @override
  String get profileBodyNameHint => 'Per exemple, Jo';

  @override
  String get profileBodyHeight => 'Alçada';

  @override
  String get profileBodyWeight => 'Pes';

  @override
  String get profileBodyBuild => 'Constitució';

  @override
  String get profileBodySkinTone => 'To de pell';

  @override
  String get profileBirthDateNeededBody =>
      'Afegeix una data de naixement per anar amb l\'hora.';

  @override
  String get profileBirthDateNeededTitle => 'Cal la data de naixement';

  @override
  String get profilePartlySavedBody =>
      'Hem desat el nom i la foto. Els detalls de naixement no s\'han desat; torna-ho a intentar més tard.';

  @override
  String get profilePartlySavedTitle => 'Desat parcialment';

  @override
  String get profileSavedBody => 'El teu perfil està desat.';

  @override
  String get profileChangePhoto => 'Canvia la foto de perfil';

  @override
  String get profilePhotoLabel => 'Foto de perfil';

  @override
  String get profilePhotoHint => 'Toca per triar-ne una nova';

  @override
  String get profileBirthDateLabel => 'Data de naixement (opcional)';

  @override
  String get profileBirthTimeLabel => 'Hora de naixement (opcional)';

  @override
  String get profileBirthTimeHelper => 'Fa les suggereixions vedes més exactes';

  @override
  String get profileBirthPlaceLabel => 'Lloc de naixement (opcional)';

  @override
  String get profileBirthPlaceHint => 'Per exemple, Nova Delhi, Índia';

  @override
  String get profileHelpContactTitle => 'T\'hi podem ajudar';

  @override
  String get profileHelpContactBody =>
      'Envia un missatge i et respondrem per correu electrònic, normalment en un dia.';

  @override
  String get profileHelpContactAction => 'Contacta amb el suport';

  @override
  String get profileHelpFaqTitle => 'Preguntes habituals';

  @override
  String get profileFaqAddPiecesTitle => 'Com afegeixo peces al meu armari?';

  @override
  String get profileFaqAddPiecesBody =>
      'Toca Afegeix article a la pestanya d\'Armari. Fes una foto o tria\'n una de la galeria; trobem cada peça i la etiquetem per tu.';

  @override
  String get profileFaqMatchingTitle =>
      'Com funciona la combinació de conjunts?';

  @override
  String get profileFaqMatchingBody =>
      'Obre Per a tu i tria les peces que tens. Suggereixim què les combina bé i creem conjunts complets a partir del teu armari.';

  @override
  String get profileFaqTryOnTitle =>
      'Puc fer servir les meves fotos per a la pròva?';

  @override
  String get profileFaqTryOnBody =>
      'Sí. Afegeix una foto de cos sencer teu i tria peces per veure-les damunt teu.';

  @override
  String get profileFaqRewardsTitle => 'Com guanyo recompenses?';

  @override
  String get profileFaqRewardsBody =>
      'Planifica i registra conjunts amb freqüència. Les ratxes i els assoliments s\'acumulen mentre prossegueixes.';

  @override
  String get profileFaqPrivacyTitle => 'El meu armari és privat?';

  @override
  String get profileFaqPrivacyBody =>
      'Sí. El teu armari i els teus conjunts són privats, llevat que comparteixis un enllaç d\'un conjunt.';

  @override
  String get profileHelpMoreTitle => 'Més ajuda';

  @override
  String get profileHelpGuides => 'Guies';

  @override
  String get profileHelpGuidesBody => 'Com funciona cada característica';

  @override
  String get feedbackCategoryBug => 'Alguna cosa s\'ha trencat';

  @override
  String get feedbackCategoryIdea => 'Una idea';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'Necessito ajuda';

  @override
  String get feedbackHintBug =>
      'Què ha passat i què esperaves? Els passos ens ajuden a corregir-ho.';

  @override
  String get feedbackHintIdea => 'Què et agradaria i per què?';

  @override
  String get feedbackHintGeneral => 'Digues-nos què penses o fes una pregunta.';

  @override
  String get feedbackAttachmentLimitBody => 'Pots afegir fins a 5 imatges.';

  @override
  String get feedbackAttachmentLimitTitle => 'Límit assolit';

  @override
  String get feedbackImageTooLargeBody => 'Tria una imatge de menys de 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imatge massa gran';

  @override
  String get feedbackTitle => 'Envia una valoració';

  @override
  String get feedbackAboutLabel => 'De què va?';

  @override
  String get feedbackSubjectLabel => 'Assumpte';

  @override
  String get feedbackSubjectRequired => 'Afegeix un assumpte';

  @override
  String get feedbackSubjectTooShort =>
      'L\'assumpte ha de tenir com a mínim 3 caràcters';

  @override
  String get feedbackDetailsLabel => 'Detalls';

  @override
  String get feedbackDetailsRequired => 'Afegeix alguns detalls';

  @override
  String get feedbackDetailsTooShort =>
      'La descripció ha de tenir com a mínim 10 caràcters';

  @override
  String get feedbackAddScreenshot => 'Afegeix una captura';

  @override
  String get feedbackAttachmentHint => 'Màxim 5, de 5 MB cadascun';

  @override
  String get feedbackSend => 'Envia';

  @override
  String get feedbackEmptyTitle => 'Res enviat encara';

  @override
  String get feedbackEmptyBody => 'El que envies apareix aquí amb l\'estat.';

  @override
  String get feedbackHistoryTitle => 'Què has enviat';

  @override
  String get feedbackStatusOpen => 'Obert';

  @override
  String get feedbackStatusInProgress => 'En curs';

  @override
  String get feedbackStatusResolved => 'Resolt';

  @override
  String get feedbackStatusClosed => 'Tancat';

  @override
  String get legalIntro =>
      'Com protegim les teves dades i les condicions d\'ús de FitCheck AI.';

  @override
  String get legalPolicies => 'Polítiques';

  @override
  String get legalPrivacySubtitle => 'Què recollim i per què';

  @override
  String get legalTermsTitle => 'Condicions d\'ús';

  @override
  String get legalTermsSubtitle => 'Les regles d\'ús de la app';

  @override
  String get legalLicences => 'Llicències de codi obert';

  @override
  String get legalSupportSubtitle =>
      'Ajuda, contacte i sol·licituds de privadesa';

  @override
  String get legalReportAbuse => 'Denuncia un problema o abús';

  @override
  String get permissionCameraTitle => 'Accés a la càmera';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI utilitza la càmera per fer fotos de la teva roba i els teus conjunts per a assaig amb IA i organització del armari.';

  @override
  String get permissionPhotoTitle => 'Accés a les fotos';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI necessita accedir a les teves fotos perquè puguis seleccionar imatges de roba i conjunts per a funcions d\'IA i el teu armari.';

  @override
  String get permissionNotNow => 'No ara';

  @override
  String get permissionOpenSettings => 'Obre la configuració';

  @override
  String authSignedInAs(String name) {
    return 'Sessió iniciada com a $name';
  }

  @override
  String get authSignedIn => 'Iniciat sessió';

  @override
  String get authWelcomeBackTitle => 'Benvingut de nou';

  @override
  String get authSignInFailed => 'L\'inici de sessió ha fallat';

  @override
  String get authWelcomeTitle => 'Benvingut';

  @override
  String get authSignUpFailed => 'El registre ha fallat';

  @override
  String get authGoogleSignInFailed => 'L\'inici amb Google ha fallat';

  @override
  String get authAppleSignInFailed => 'L\'inici amb Apple ha fallat';

  @override
  String get authConfirmEmailTitle => 'Confirma el correu electrònic';

  @override
  String get authConfirmEmailBody =>
      'Revisa la teva safata de correus per trobar el correu de confirmació i, després, inicia sessió.';

  @override
  String get authClosetReady => 'El teu armari està preparat.';

  @override
  String get authSignedOutTitle => 'Sessió tancada';

  @override
  String get authSignedOutBody => 'Has tancat la sessió.';

  @override
  String get authSignOutFailed => 'El tancament de sessió ha fallat';

  @override
  String get authEmailSentTitle => 'Correu enviat';

  @override
  String get authResetLinkSent =>
      'Revisa el teu correu per trobar l\'enllaç de reinici.';

  @override
  String get authPasswordUpdatedTitle => 'Contrasenya actualitzada';

  @override
  String get authPasswordUpdated => 'La teva contrasenya s\'ha actualitzat.';

  @override
  String get authPasswordNotUpdated => 'La contrasenya no s\'ha actualitzat';

  @override
  String get authCouldNotSendEmail => 'No s\'ha pogut enviar el correu';

  @override
  String get authEmailNotSent => 'Correu no enviat';

  @override
  String get authResendSentBody => 'Hem enviat un nou correu de confirmació.';

  @override
  String get outfitPreviewWithAi => 'Vista prèvia amb IA';

  @override
  String get outfitNewPreview => 'Crea una vista prèvia nova';

  @override
  String get outfitBuilderClosetHeading => 'El teu armari';

  @override
  String get outfitBuilderSearchHint => 'Cerca peces';

  @override
  String get outfitClearSearch => 'Esborra la cerca';

  @override
  String get outfitBuilderAddPiecesTitle => 'Afegeix peces abans';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Els conjunts es fan amb les peces del teu armari.';

  @override
  String get outfitBuilderNoMatches => 'Cap peça coincideix.';

  @override
  String get outfitNameLabel => 'Nom del conjunt';

  @override
  String get outfitNameHint => 'Per exemple, Linen de cap de setmana';

  @override
  String get outfitPreviewSemantic => 'Vista prèvia de IA del conjunt';

  @override
  String get outfitChoosePieces => 'Tria peces';

  @override
  String get outfitTapPiecesHint => 'Toca les peces de sota per afegir-les.';

  @override
  String get outfitShareTooltip => 'Comparteix';

  @override
  String get outfitSaveFavourite => 'Desa als favorits';

  @override
  String get outfitPiecesHeading => 'Peces';

  @override
  String get outfitWearHistoryEmpty =>
      'Posa’t el conjunt una vegada i les dates apareixeran aquí.';

  @override
  String get outfitWearHistoryTitle => 'Historial d’ús';

  @override
  String get outfitWearHistoryError => 'No s’han pogut carregar les dates.';

  @override
  String get outfitWornOn => 'Usat el';

  @override
  String get outfitEditTitle => 'Edita el conjunt';

  @override
  String get outfitSavedPhotosFailed => 'Detalls desats, fotos no';

  @override
  String get outfitNoPhotosBody =>
      'Encara no hi ha fotos. El conjunt mostra les peces.';

  @override
  String get outfitOccasionLabel => 'Ocasió';

  @override
  String get outfitOccasionNone => 'Cap';

  @override
  String get outfitTagsHint => 'Separa amb comes';

  @override
  String get outfitDraftBody => 'Amagat de la llista principal';

  @override
  String get outfitPublic => 'Públic';

  @override
  String get outfitPublicBody => 'Qualsevol amb l’enllaç pot veure’l';

  @override
  String get outfitDeleteFromDetail =>
      'Elimina aquest conjunt de la seva pàgina de detall.';

  @override
  String get outfitNewCollection => 'Col·lecció nova';

  @override
  String get outfitNoCollectionsTitle => 'Encara no hi ha col·leccions';

  @override
  String get outfitNoCollectionsBody =>
      'Agrupa conjunts per viatge, temporada o estat d’ànim.';

  @override
  String get outfitCreateCollection => 'Crea una col·lecció';

  @override
  String get outfitAddOutfits => 'Afegeix conjunts';

  @override
  String get outfitRename => 'Canvia el nom';

  @override
  String get outfitCollectionDeleteBody =>
      'Es mantindran els conjunts que hi ha.';

  @override
  String get outfitCollectionsNotLoaded => 'Conjunts no carregats';

  @override
  String get outfitRenameCollection => 'Canvia el nom de la col·lecció';

  @override
  String get outfitDescriptionOptional => 'Descripció (opcional)';

  @override
  String get outfitAllInCollection =>
      'Tots els look ja són en aquesta col·lecció.';

  @override
  String get photoshootSubtitleUpload =>
      'Retrats d\'estudi amb les teves fotos';

  @override
  String get photoshootSubtitleConfigure =>
      'Tria un estil, un format i una quantitat';

  @override
  String get photoshootSubtitleGenerating => 'Triga un minut o dos';

  @override
  String get photoshootAddPhotosSemantic => 'Afegeix fotos de la teva galeria';

  @override
  String get photoshootUploadTitle => 'Afegeix de 1 a 4 fotos teves';

  @override
  String get photoshootUploadBody => 'Toca per triar de la galeria';

  @override
  String get photoshootAddToContinue => 'Afegeix una foto per continuar';

  @override
  String get photoshootAddAnotherPhoto => 'Afegeix un altre foto';

  @override
  String get photoshootTipsTitle => 'Per aconseguir els millors resultats';

  @override
  String get photoshootTipsBody =>
      'Utilitza fotos clares i ben il·luminades de la cara des de diversos angles. Evita ulleres de sol i barrets.';

  @override
  String get photoshootStarting => 'Començant';

  @override
  String get photoshootCancelling => 'Cancel·lant';

  @override
  String get photoshootFailed => 'Fallida';

  @override
  String get recommendTabMatches => 'Combina';

  @override
  String get recommendTabComplete => 'Completa';

  @override
  String get recommendTabWeather => 'Clima';

  @override
  String get recommendTabColours => 'Colors';

  @override
  String get recommendTabShop => 'Botiga';

  @override
  String get recommendNoMatchesTitle => 'Encara no hi ha combinacions';

  @override
  String get recommendNoMatchesBody =>
      'Tria una peça i trobarem què va bé amb ella.';

  @override
  String get recommendPickPiece => 'Tria una peça';

  @override
  String get recommendNothingMatchesTitle =>
      'Res no combina amb aquestes encara';

  @override
  String get recommendNothingMatchesBody =>
      'Assaigeu altres peces o n\'afegeix més al vestidor.';

  @override
  String get recommendChangePieces => 'Canvia les peces';

  @override
  String get recommendDefaultReason => 'Va bé amb les peces triades.';

  @override
  String get recommendCompleteTitle => 'Completa un look';

  @override
  String get recommendCompleteBody => 'Tria una peça i omplirem la resta.';

  @override
  String get recommendWorking => 'Processant';

  @override
  String get recommendGenerate => 'Genera';

  @override
  String get recommendChooseStyleBody => 'Tria un estil i genera.';

  @override
  String get recommendNoLooksTitle =>
      'No hi ha combinacions per a aquestes peces';

  @override
  String get recommendNoLooksBody =>
      'Prova un altre estil o unes altres peces.';

  @override
  String get recommendDefaultLook => 'Una combinació per a les teves peces';

  @override
  String get recommendNoPiecesBody =>
      'No hi ha peces per a aquesta combinació.';

  @override
  String get recommendCityLabel => 'Ciutat';

  @override
  String get recommendCheck => 'Comprova';

  @override
  String get recommendWeatherTitle => 'Com és el temps?';

  @override
  String get recommendWeatherBody =>
      'Introdueix la teva ciutat per rebre opcions d\'avui.';

  @override
  String get recommendWearToday => 'Vestit per avui';

  @override
  String get recommendWeatherNoPieces =>
      'Encara no hi ha peces al teu armari per a aquest temps.';

  @override
  String get recommendBudgetLabel => 'Pressupost fins a';

  @override
  String get recommendLooking => 'Buscant';

  @override
  String get recommendFindWhatToBuy => 'Troba què comprar';

  @override
  String get recommendFillGapsTitle => 'Om els buits';

  @override
  String get recommendFillGapsBody =>
      'Estableix un pressupost i et suggerirem què falta al teu armari.';

  @override
  String get recommendNoGapsTitle => 'No s\'han trobat buits';

  @override
  String get recommendNoGapsBody =>
      'Prova un pressupost més gran o una altra categoria.';

  @override
  String get recommendMoodEveryday => 'Diari';

  @override
  String get recommendMoodBigMeeting => 'Gran reunió';

  @override
  String get recommendDayLabel => 'Dia';

  @override
  String get recommendReadingStars => 'Llegeix les estelles';

  @override
  String get recommendGetMyColours => 'Aconsegueix els meus colors';

  @override
  String get recommendLuckyColoursTitle => 'Els teus colors de bon auguri';

  @override
  String get recommendLuckyColoursBody =>
      'Tria un dia i et suggerirem colors i peces per a ell.';

  @override
  String get recommendLuckyColoursSection => 'Colors de bon auguri';

  @override
  String get recommendAvoidColoursSection => 'Colors a evitar';

  @override
  String get recommendBirthDateTitle => 'Afegeix la teva data de naixement';

  @override
  String get recommendBirthDateBody =>
      'Necessitem la teva data de naixement per llegir els teus colors.';

  @override
  String get recommendEditProfile => 'Edita el perfil';

  @override
  String get recommendNothingThisDay => 'Res per a aquest dia.';

  @override
  String get recommendUnnamedColour => 'Color sense nom';

  @override
  String get recommendFromCloset => 'De la teva roba';

  @override
  String get recommendNoPiecesInColours =>
      'Encara no hi ha peces d\'aquests colors.';

  @override
  String get recommendOutfitIdeas => 'Idees d\'equipació';

  @override
  String get recommendNoOutfitsInColours =>
      'Encara no hi ha cap outfit complet amb aquests colors.';

  @override
  String get recommendDefaultOutfitIdea => 'Una idea d\'equipació';

  @override
  String get recommendPickUpToThree => 'Tria fins a tres peces';

  @override
  String get recommendEmptyClosetBody =>
      'Afegeix algunes peces primer i torna per a les combinacions.';

  @override
  String get dashboardDressForDay => 'Vestit per al dia que ve.';

  @override
  String get dashboardOutfitOfDay => 'Equipació del dia';

  @override
  String get dashboardFreshLook => 'Un look nou';

  @override
  String get subscriptionManageInStoreTitle => 'Gestiona a la botiga';

  @override
  String get subscriptionManageInStoreBody =>
      'Aquest pla es factura a través de la botiga. Gestiona\'l als ajustos del teu compte de la botiga.';

  @override
  String get subscriptionCancelledTitle => 'Subscripció cancel·lada';

  @override
  String get subscriptionCancelledBody =>
      'El teu pla romandrà actiu fins al final d\'aquest període de facturació.';

  @override
  String get subscriptionCancelFailedTitle => 'No s\'ha pogut cancel·lar';

  @override
  String get subscriptionCouldNotOpenTitle => 'No s\'ha pogut obrir';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'No s\'ha pogut obrir la gestió de facturació.';

  @override
  String get subscriptionOpenLinkFailedBody =>
      'No s\'ha pogut obrir l\'enllaç.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'No s\'ha pogut carregar el teu enllaç';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'No s\'ha pogut carregar l\'enllaç de referència. Intenta-ho de nou.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiat';

  @override
  String get subscriptionReferralCopiedBody => 'Enllaç de referència copiat.';

  @override
  String get subscriptionReferralShareSubject => 'Prova FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Uneix-te a FitCheck AI i tots dos guanyem un mes de Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Enllaç copiat';

  @override
  String get subscriptionShareUnavailableBody =>
      'El compartiment no està disponible, així que hem copiat l\'enllaç.';

  @override
  String get subscriptionShareFailedTitle => 'No s\'ha pogut compartir';

  @override
  String get subscriptionShareFailedBody =>
      'Copia el enllaç de la pàgina de recomanació.';

  @override
  String get subscriptionStoreReadyTitle => 'Botiga preparada';

  @override
  String get subscriptionStoreReadyBody =>
      'Els preus de la botiga estan disponibles. Pots actualitzar ara.';

  @override
  String get purchaseFailedTitle => 'Compra fallida';

  @override
  String get purchaseUnavailableTitle => 'Compra no disponible';

  @override
  String get purchaseIapUnavailableBody =>
      'Les compres a l\'aplicació no estan disponibles en aquest dispositiu.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Aquest pla encara no està disponible per a la compra.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Aquest pla encara no està disponible a la botiga. Torna a verificar-lo aviat.';

  @override
  String get purchaseStartFailedBody =>
      'No s\'ha pogut iniciar la compra. Intenta-ho de nou.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'La finalització de la compra no ha retornat un enllaç de pagament.';

  @override
  String get purchasePendingTitle => 'Compra pendent';

  @override
  String get purchasePendingBody =>
      'La teva compra està pendent d\'aprovació. En tindràs accés en quant s\'aprovi.';

  @override
  String get purchaseFailedBody => 'La compra ha fallat. Intenta-ho de nou.';

  @override
  String get purchaseRestoredTitle => 'Restaurat';

  @override
  String get purchaseRestoredBody => 'S\'han restaurat les teves compres.';

  @override
  String get purchaseActiveTitle => 'Subscripció activa';

  @override
  String get purchaseActiveBody =>
      'La teva subscripció està activa. Benvingut.';

  @override
  String get purchaseSignInRequiredTitle => 'Cal iniciar sessió';

  @override
  String get purchaseSignInRequiredBody =>
      'Inicia sessió per finalitzar la teva compra.';

  @override
  String get purchaseErrorTitle => 'Error de compra';

  @override
  String get purchaseInvalidTransactionBody =>
      'La compra no incloïa un ID de transacció verificable.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificació pendent';

  @override
  String get purchaseVerificationPendingBody =>
      'No s\'ha pogut verificar la teva compra a la botiga ara mateix. Es completará automàticament i no se\'t cobrarà dues vegades.';

  @override
  String get purchaseNotAppliedTitle => 'Compra no aplicada';

  @override
  String get purchaseNotAppliedBody =>
      'La teva compra no s\'ha pogut aplicar al teu compte. Contacta amb el suport i no la compis de nou.';

  @override
  String get purchaseRestoreFailedTitle => 'Restauració fallida';

  @override
  String get purchaseRestoreFailedBody =>
      'No s\'han pogut restaurar les compres. Intenta-ho de nou.';

  @override
  String get purchaseRecoveredActiveBody => 'La teva subscripció està activa.';

  @override
  String get purchaseCompleteTitle => 'Compra completada';

  @override
  String get giftCreateFailedTitle => 'No s\'ha pogut crear el regal';

  @override
  String get giftClaimFailedTitle => 'No s\'ha pogut reclamar el regal';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regals per a tu',
      one: 'Un regal per a tu',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mes',
      '12': '1 any',
      'other': '$months mesos',
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
    return '$sender t\'ha enviat $duration de FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Un regal de FitCheck Pro per a $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'De $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Per a $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'De $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'el destinatari';

  @override
  String get giftPreviewPlaceholderSender => 'tu';

  @override
  String get settingsSavedTitle => 'Desat';

  @override
  String get settingsNotSavedTitle => 'No desat';

  @override
  String get settingsAiChooseProviderBody => 'Tria un proveïdor.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Un proveïdor personalitzat necessita una URL d\'API.';

  @override
  String get settingsAiKeyRequiredBody => 'Introdueix una clau d\'API.';

  @override
  String get settingsAiSavedBody =>
      'S\'han desat les teves configuracions d\'IA.';

  @override
  String get settingsAiMissingDetailsTitle => 'Detalls que manquen';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Introdueix una URL d\'API i un model de xat per fer la prova.';

  @override
  String get settingsAiKeyNeededTitle => 'Cal clau d\'API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Introdueix la teva clau d\'API per provar-la. La clau guardada roman privada.';

  @override
  String get settingsAiKeyToTestBody =>
      'Introdueix la teva clau d\'API per provar-la.';

  @override
  String get settingsAiConnectedTitle => 'Connectat';

  @override
  String get settingsAiConnectedBody => 'La connexió funciona.';

  @override
  String get settingsAiTestFailedTitle => 'Prova fallida';

  @override
  String get settingsPreferencesSavedBody =>
      'S\'han desat les teves preferències.';

  @override
  String get settingsPasswordNotChangedTitle => 'Contrasenya no canviada';

  @override
  String get settingsOAuthPasswordBody =>
      'Aquest compte inicia sessió amb Google o Apple. Utilitza \"Heu oblidat la contrasenya\" per establir-ne una primer.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'La contrasenya actual és incorrecta.';

  @override
  String get settingsExportReadyTitle => 'Exportació preparada';

  @override
  String get settingsExportReadyBody =>
      'L\'exportació de les teves dades està a punt per descarregar-la.';

  @override
  String get settingsLinkCopiedTitle => 'Enllaç copiat';

  @override
  String get settingsExportClipboardBody =>
      'No hem pogut obrir el navegador, així que hem copiat l\'enllaç de descàrrega. Enganxeu-lo a un navegador aviat: caduca.';

  @override
  String get settingsExportFailedTitle => 'Error en l\'exportació';

  @override
  String get settingsAccountNotDeletedTitle => 'Compte no eliminat';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Pots afegir fins a $max fotos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Límit de fotos';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Afegeix com a mínim una foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Cap foto';

  @override
  String get photoshootDescribeLookBody => 'Descriu l\'aspecte que desitgeu.';

  @override
  String get photoshootPromptNeededTitle => 'Cal una instrucció';

  @override
  String get photoshootConsentFeatureLabel => 'Fotosessió IA';

  @override
  String get photoshootStatusPreparing => 'Preparant les teves fotos';

  @override
  String get photoshootStatusGenerating => 'Generant';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lote $current de $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done de $total completat';
  }

  @override
  String get photoshootGenerationFailedBody => 'Error en la generació.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready a punt, $failed fallats.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Parcialment completat';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos estan a punt.',
      one: '1 foto està a punt.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Hem perdut la connexió. Si us plau, torna-ho a intentar.';

  @override
  String get photoshootCouldNotCancelTitle => 'No s\'ha pogut cancel·lar';

  @override
  String get photoshootRetryFailedTitle => 'Error en la reintenta';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'La foto $number està a punt.';
  }

  @override
  String get photoshootReplacedTitle => 'Substituïda';

  @override
  String get photoshootSavedToGalleryBody => 'S\'ha desat a la galeria.';

  @override
  String get photoshootSavedTitle => 'Desat';

  @override
  String get photoshootNotSavedTitle => 'No desat';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Totes les $count fotos són a la teva galeria.',
      one: '1 foto està a la teva galeria.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved de $total desats.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Algunes fotos no s\'han desat';

  @override
  String get tryonConsentFeatureLabel => 'Prova virtual';

  @override
  String get tryonAvatarUpdatedBody => 'La teva foto s\'ha actualitzat.';

  @override
  String get tryonSavedTitle => 'Desat';

  @override
  String get tryonUploadFailedTitle => 'Error en carregar';

  @override
  String get tryonChooseGarmentFirstBody => 'Tria primer una foto de la roba.';

  @override
  String get tryonNoGarmentTitle => 'Sense roba';

  @override
  String get tryonWaitForUploadBody => 'Espera que acabi de carregar la foto.';

  @override
  String get tryonStillUploadingTitle => 'S\'està carregant';

  @override
  String get tryonAddYourPhotoFirstBody => 'Afegeix primer una foto teva.';

  @override
  String get tryonReadyBody => 'La teva prova està a punt.';

  @override
  String get tryonFailedTitle => 'Error en la prova';

  @override
  String get tryonSavedToGalleryBody => 'Desat a la teva galeria.';

  @override
  String get tryonNotSavedTitle => 'No s\'ha desat';

  @override
  String get calendarEventAddedBody => 'Esdeveniment afegit';

  @override
  String get calendarEventPlannedTitle => 'Planificat';

  @override
  String get calendarEventSavedBody => 'Esdeveniment desat';

  @override
  String get calendarSavedTitle => 'Desat';

  @override
  String get calendarEventNotSavedTitle => 'Esdeveniment no desat';

  @override
  String get calendarEventRemovedBody => 'Esdeveniment eliminat';

  @override
  String get calendarEventDeletedTitle => 'Eliminat';

  @override
  String get calendarEventNotDeletedTitle => 'Esdeveniment no eliminat';

  @override
  String get calendarOutfitNotLinkedTitle => 'Look no enllaçat';

  @override
  String get calendarLinkedTitle => 'Enllaçat';

  @override
  String get calendarOutfitNotRemovedTitle => 'Look no eliminat';

  @override
  String get calendarOutfitRemovedBody => 'Look eliminat';

  @override
  String get calendarDisconnectedBody => 'Calendari desconnectat';

  @override
  String get calendarDisconnectedTitle => 'Desconnectat';

  @override
  String get calendarNotDisconnectedTitle => 'Calendari no desconnectat';

  @override
  String get calendarTodayLabel => 'avui';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esdeueniments',
      one: '1 esdeueniment',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return '$start a $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, vestit enllaçat';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" es eliminarà.';
  }

  @override
  String get calendarThisAppLabel => 'Aquesta app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'La sincronització amb $provider encara no està disponible. Encara pots afegir esdeueniments aquí.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dg';

  @override
  String get calendarWeekdayMonShort => 'Dl';

  @override
  String get calendarWeekdayTueShort => 'Dt';

  @override
  String get calendarWeekdayWedShort => 'Dc';

  @override
  String get calendarWeekdayThuShort => 'Dj';

  @override
  String get calendarWeekdayFriShort => 'Dv';

  @override
  String get calendarWeekdaySatShort => 'Ds';

  @override
  String get calendarWeekdayMonday => 'dilluns';

  @override
  String get calendarWeekdayTuesday => 'dimarts';

  @override
  String get calendarWeekdayWednesday => 'dimecres';

  @override
  String get calendarWeekdayThursday => 'dijous';

  @override
  String get calendarWeekdayFriday => 'divendres';

  @override
  String get calendarWeekdaySaturday => 'dissabte';

  @override
  String get calendarWeekdaySunday => 'diumenge';

  @override
  String get outfitSavedToFavouritesBody => 'Desat als favorits';

  @override
  String get outfitRemovedFromFavouritesBody => 'Eliminat dels favorits';

  @override
  String get outfitNotSavedTitle => 'No s\'ha desat';

  @override
  String get outfitLoggedAsWornBody => 'Registat com a vestit avui.';

  @override
  String get outfitNicePickTitle => 'Bona elecció';

  @override
  String get outfitRemovedBody => 'Vestit eliminat.';

  @override
  String get outfitDeletedTitle => 'Eliminat';

  @override
  String get outfitNotDeletedTitle => 'No s\'ha eliminat';

  @override
  String get outfitDuplicatedBody => 'Hi ha una còpia als teus looks.';

  @override
  String get outfitDuplicatedTitle => 'Duplicat';

  @override
  String get outfitNotDuplicatedTitle => 'No duplicat';

  @override
  String get outfitNotSharedTitle => 'No compartit';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" està llest.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Col·lecció no creada';

  @override
  String get outfitCollectionUpdatedBody => 'Col·lecció actualitzada.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Col·lecció no actualitzada';

  @override
  String get outfitCollectionDeletedBody => 'Col·lecció eliminada.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Col·lecció no eliminada';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'han afegit $count looks.',
      one: 'S\'ha afegit 1 look.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Looks no afegits';

  @override
  String get outfitPreviewNotCreatedTitle => 'Vista prèvia no creada';

  @override
  String get outfitGiveNameBody => 'Dona un nom al look.';

  @override
  String get outfitNameMissingTitle => 'Nom';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Tria com a mínim una peça.';

  @override
  String outfitCreatedBody(String name) {
    return '$name és als teus looks.';
  }

  @override
  String get outfitSavedTitle => 'Desat';

  @override
  String get wardrobeAddedToFavouritesBody => 'Afegit als favorits';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Eliminat dels favorits';

  @override
  String get wardrobeNotSavedTitle => 'No desat';

  @override
  String get wardrobeLoggedAsWornBody => 'Marcat com a portat avui.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Eliminat del teu armari.';

  @override
  String get wardrobeDeletedTitle => 'Eliminat';

  @override
  String get wardrobeNotDeletedTitle => 'No eliminat';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'han eliminat $count peces del teu armari.',
      one: 'S\'ha eliminat 1 peça del teu armari.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extracció d\'armari IA';

  @override
  String get itemAddScanJobLabel => 'Escaneig';

  @override
  String get itemAddFoundEarlierBody => 'Trobat en un escaneig anterior';

  @override
  String get itemAddLookingAtPhoto => 'Mirant la teva foto';

  @override
  String get itemAddExtractionFailedBody => 'L\'extracció ha fallat';

  @override
  String get itemAddJobFailedBody => 'La tasca ha fallat';

  @override
  String get itemAddConnectionLostBody =>
      'S\'ha perdut la connexió. Intenteu-ho de nou.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'S\'ha perdut la connexió mentre es processava.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Trobada $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Trobada';

  @override
  String get itemAddNotCancelledTitle => 'No s\'ha cancel·lat';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trobades estan a la vostra armari.',
      one: '1 trobada està a la vostra armari.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return 'S\'ha desat $saved de $total trobades. Toqueu desa per provar la resta de nou.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Algunes trobades no s\'han desat';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Trieu com a mínim una foto.';

  @override
  String get batchPhotoUnreadableBody => 'No s\'ha pogut llegir aquesta foto.';

  @override
  String get batchNoPhotosReadableBody =>
      'Cap d\'aquestes fotos s\'ha pogut llegir. Proveu amb altres fotos.';

  @override
  String batchJobLabelPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get batchConnectionLostWorkingBody =>
      'Hem perdut la connexió mentre treballàvem. Intenteu-ho de nou.';

  @override
  String get batchNotCancelledTitle => 'No s\'ha cancel·lat';

  @override
  String get batchPostLinkUnsupportedBody =>
      'No es suporten els enllaços de publicacions. Introduïu un enllaç de perfil.';

  @override
  String get batchLinkSpacesBody => 'Els enllaços no poden contenir espais.';

  @override
  String get batchEnterProfileLinkBody =>
      'Introduïu un enllaç de perfil d\'Instagram o Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Introduïu un enllaç de perfil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'La pàgina d\'inici de sessió no s\'ha obert. Intenteu-ho de nou.';

  @override
  String get batchSignInBrowserBody =>
      'Inicieu sessió al vostre navegador i després torneu a FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Connecteu el vostre compte';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Introduïu el codi de la vostra aplicació d\'autenticació.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram demana una verificació de seguretat. Inicieu sessió primer al vostre navegador.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Introduïu el vostre nom d\'usuari i contrasenya de nou.';

  @override
  String get batchSignInFailedBody =>
      'L\'inici de sessió ha fallat. Comproveu el vostre nom d\'usuari i contrasenya.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Inicieu sessió per continuar important.';

  @override
  String get batchAccountNotConnectedBody =>
      'El vostre compte no s\'ha connectat.';

  @override
  String get batchAccountConnectedTitle => 'Compte connectat';

  @override
  String get batchNotConnectedTitle => 'Sense connexió';

  @override
  String get batchImportConnectionLostBody =>
      'Hem perdut la connexió a la importació. Actualitza per comprovar-lo.';

  @override
  String batchPickUpToBody(int max) {
    return 'Tria fins a $max fotos. Trobem les peces.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count de $total fotos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparant la foto $done de $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Troba peces en $count fotos',
      one: 'Troba peces en 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'El teu compte de $platform utilitza inici de sessió en dos passos. Introdueix el codi de 6 dígits de la teva aplicació d\'autenticació.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Aquest perfil de $platform és privat o cal iniciar sessió per mostrar-ne les fotos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Connecta amb $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'han trobat $count fotos fins ara',
      one: 'S\'ha trobat 1 foto fins ara',
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
    return '$processed de $total processades · $added afegides · $waiting en espera · $skipped omitides';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Escanejant la foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'La foto $number és la següent';
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
      other: 'S\'han trobat $count peces',
      one: 'S\'ha trobat 1 peça',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'han afegit $count fotos al teu armari.',
      one: 'S\'ha afegit 1 foto al teu armari.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hi ha $count fotos més de l\'estudi en camí. Pots guardar el que està llest o sortir; t\'avisarem.',
      one:
          'Hi ha 1 foto més de l\'estudi en camí. Pots guardar el que està llest o sortir; t\'avisarem.',
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
      other: '$pieces peces',
      one: '1 peça',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotos',
      one: '1 foto',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen triades. Toca una peça per ometre-la.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardant $count peces',
      one: 'Guardant 1 peça',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guarda $count peces',
      one: 'Guarda 1 peça',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'El teu perfil corporal s\'ha guardat.';

  @override
  String get bodyProfileSavedTitle => 'Guardat';

  @override
  String get bodyProfileNotSavedTitle => 'No s\'ha guardat';

  @override
  String get bodyProfileSetDefaultBody =>
      'Estableix com a perfil predeterminat.';

  @override
  String get bodyProfileDeletedBody => 'Perfil corporal eliminat.';

  @override
  String get bodyProfileDeletedTitle => 'Eliminat';

  @override
  String get bodyProfileNotDeletedTitle => 'No s\'ha eliminat';

  @override
  String get feedbackNotSentTitle => 'No s\'ha enviat';

  @override
  String get feedbackSentBody =>
      'Gràcies. Llegim tots els missatges i responem si cal més informació.';

  @override
  String get feedbackSentTitle => 'Retroalimentació enviada';

  @override
  String get recommendUnnamedPiece => 'Peces sense nom';

  @override
  String get recommendEnterCityBody =>
      'Introdueix la teva ciutat per rebre propostes segons el temps.';

  @override
  String get recommendWhichCityTitle => 'Quina ciutat?';

  @override
  String get aiConsentSheetTitle => 'Compartir fotos amb un servei d\'IA';

  @override
  String get aiConsentSheetBody =>
      'Per crear les teves imatges de vestimenta i sessió de fotos, FitCheck AI envia les fotos que proporcionis (incloses imatges del teu rostre i cos) a un proveïdor d\'IA de confiança (com OpenAI o Google Gemini) per al seu processament. Generen les teves imatges i no les fan servir per entrenar els seus models segons les nostres condicions. Les fotos es transmeten de forma segura i mai es comparteixen per a publicitat.';

  @override
  String get aiConsentSheetPermission =>
      'Si continues, dónes permís explícit per compartir les teves fotos amb aquests proveïdors d\'IA per a la generació d\'imatges.';

  @override
  String get skeletonsLoadMoreFailed => 'No s\'ha pogut carregar més.';

  @override
  String get jobsPiecesReadyTitle => 'Les teves peces estan llestes';

  @override
  String get jobsScanStoppedTitle => 'L\'escaneig s\'ha aturat';

  @override
  String get jobsNothingSavedBody => 'No s\'ha desat res. Torna-ho a intentar.';

  @override
  String get jobsPhotoUploadFailedBody => 'La càrrega de la foto ha fallat.';

  @override
  String get authGoogleSignInStartFailed =>
      'No s\'ha pogut iniciar l\'Inicia sessió amb Google. Torna-ho a provar.';

  @override
  String get referralAppliedTitle => 'Referència aplicada';

  @override
  String get billingStoreUnavailableBody =>
      'Les compres de la botiga no són disponibles en aquest dispositiu.';

  @override
  String get billingPurchaseProcessingBody =>
      'Aquesta compra encara està sent processada. Torna a obrir l\'aplicació en un minut per veure el teu pla.';

  @override
  String get profileAvatarUploadNoUrl =>
      'La càrrega de l\'avatar no ha retornat una URL d\'imatge.';

  @override
  String get rewardsDayStreakLabel => 'dies seguits';

  @override
  String rewardsBestStreak(int days) {
    return 'Millor $days dies';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Cal accés a $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'L\'accés a $permission està denegat actualment. Obre Ajustos per permetre\'l, torna i torna-ho a provar.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Pas $step de 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Pas $step de $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Elimina la imatge $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Elimina la imatge $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Envia un correu a $email. Revisem les denúncies en 24 hores.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Elimina $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Vols eliminar «$name»?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Afegeix a «$name»';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '«$name» s\'ha eliminat. Les peces es mantenen al teu armari.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Mostra els $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restants avui';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'La imatge $index ha fallat';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected de $max fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape · Pello $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Vols eliminar $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opcions per a $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Més portat: $name, $count vegades';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: no establert';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% de coincidència';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked de $max seleccionats';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Elimina $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioritat $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Aquest pla es factura a través de $store. Modifica o cancel·la\'l a la configuració del teu compte de $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gestiona a $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: s\'han utilitzat $current de $max';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Queden uns ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done de $total fotos d\'estudi llestes';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready de $total fotos d\'estudi llestes. Toca una peça per ometre-la.';
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
