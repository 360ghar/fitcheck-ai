// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabPhotoshoot => 'Sesión';

  @override
  String get tabCloset => 'Armario';

  @override
  String get tabOutfits => 'Conjuntos';

  @override
  String get tabMore => 'Más';

  @override
  String get actionAddItem => 'Añadir prenda';

  @override
  String get actionCreateOutfit => 'Crear conjunto';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionDone => 'Hecho';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get stateLoading => 'Cargando';

  @override
  String get stateErrorTitle => 'Algo salió mal';

  @override
  String get stateErrorBody =>
      'Inténtalo de nuevo. Si el error persiste, contacta con soporte.';

  @override
  String get stateOfflineTitle => 'Sin conexión';

  @override
  String get stateOfflineBody =>
      'Conéctate para sincronizar tu armario y generar conjuntos.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAccountSection => 'Cuenta';

  @override
  String get settingsPreferencesSection => 'Preferencias';

  @override
  String get settingsPlanBilling => 'Plan y facturación';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsUnits => 'Unidades de medida';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsPrivacySection => 'Privacidad y datos';

  @override
  String get settingsAboutSection => 'Sobre la app';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountTitle => '¿Eliminar tu cuenta?';

  @override
  String get settingsDeleteAccountBody =>
      'Esto borrará tu armario, conjuntos, fotos y perfil. No se puede deshacer.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Métrico (cm, kg)';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Usar idioma del dispositivo';

  @override
  String get languageSystemBody =>
      'FitCheck AI sigue el idioma de tu teléfono.';

  @override
  String get languageSearchHint => 'Buscar idiomas';

  @override
  String get languageCurrent => 'Actual';

  @override
  String get languageReviewNote =>
      'Esta traducción es nueva. Dinos si algo no suena bien.';

  @override
  String get languageChanged => 'Idioma actualizado';

  @override
  String get paywallTitle => 'Elige tu plan';

  @override
  String get paywallTrialBadge => '1 mes gratis';

  @override
  String get paywallTrialTitle => 'Tu primer mes de Pro es gratis';

  @override
  String get paywallTrialBody =>
      'Sube todo tu armario de una vez. Añade prendas poco a poco después.';

  @override
  String get paywallFreeForeverTitle => 'Gratis para siempre';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Sin tarjeta. Cada mes obtienes $uploads subidas IA, $outfits conjuntos y $images fotos de sesión al día.';
  }

  @override
  String get paywallCtaTrial => 'Empezar mi mes gratis';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Pasar a $plan';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallManage => 'Gestionar suscripción';

  @override
  String get paywallTerms => 'Condiciones de uso';

  @override
  String get paywallPrivacy => 'Política de privacidad';

  @override
  String get paywallPerMonth => 'al mes';

  @override
  String get paywallPerYear => 'al año';

  @override
  String get paywallBestValue => 'Mejor opción';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Prueba gratuita solo para nuevos suscriptores. Tras la prueba, Pro se renovará a $price a menos que se cancele al menos 24 horas antes de que finalice.';
  }

  @override
  String get introTitle => 'Tu armario, por fin organizado';

  @override
  String get introBody =>
      'Fotografía tu ropa una vez. Obtén ideas de conjuntos, vistas previas de prueba y fotos de estudio con lo que ya tienes.';

  @override
  String get introStart => 'Empezar';

  @override
  String get introHaveAccount => 'Ya tengo cuenta';

  @override
  String get introSkip => 'Omitir';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authSignUp => 'Crear cuenta';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authForgotPassword => '¿Has olvidado tu contraseña?';

  @override
  String get authContinueApple => 'Continuar con Apple';

  @override
  String get authContinueGoogle => 'Continuar con Google';

  @override
  String get authOrDivider => 'o';

  @override
  String get wardrobeTitle => 'Armario';

  @override
  String get wardrobeEmptyTitle => 'Tu armario está vacío';

  @override
  String get wardrobeEmptyBody =>
      'Añade tu primera prenda o sube una foto de todo el perchero a la vez.';

  @override
  String get wardrobeAddFirst => 'Añadir primer artículo';

  @override
  String get wardrobeSearchHint => 'Buscar en tu armario';

  @override
  String get categoryTops => 'Partes de arriba';

  @override
  String get categoryBottoms => 'Partes de abajo';

  @override
  String get categoryShoes => 'Calzado';

  @override
  String get categoryAccessories => 'Accesorios';

  @override
  String get categoryOuterwear => 'Abrigos';

  @override
  String get categorySwimwear => 'Baño';

  @override
  String get categoryActivewear => 'Deporte';

  @override
  String get categoryOther => 'Otros';

  @override
  String get conditionClean => 'Limpio';

  @override
  String get conditionDirty => 'Sucio';

  @override
  String get conditionLaundry => 'En la lavandería';

  @override
  String get conditionRepair => 'Necesita arreglo';

  @override
  String get conditionDonate => 'Para donar';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Verano';

  @override
  String get seasonFall => 'Otoño';

  @override
  String get seasonWinter => 'Invierno';

  @override
  String get seasonAll => 'Todo el año';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Ejecutivo';

  @override
  String get styleSporty => 'Deportivo';

  @override
  String get styleBohemian => 'Bohemio';

  @override
  String get styleStreetwear => 'Urbano';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romántico';

  @override
  String get styleEdgy => 'Atrevido';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artístico';

  @override
  String get styleClassic => 'Clásico';

  @override
  String get styleElegant => 'Elegante';

  @override
  String get styleOther => 'Otro';

  @override
  String get occasionWork => 'Trabajo';

  @override
  String get occasionDateNight => 'Cita';

  @override
  String get occasionTravel => 'Viaje';

  @override
  String get occasionWedding => 'Boda';

  @override
  String get occasionGym => 'Gimnasio';

  @override
  String get occasionWeekend => 'Fin de semana';

  @override
  String get occasionParty => 'Fiesta';

  @override
  String get occasionInterview => 'Entrevista';

  @override
  String get colorBlack => 'Negro';

  @override
  String get colorWhite => 'Blanco';

  @override
  String get colorGrey => 'Gris';

  @override
  String get colorNavy => 'Azul marino';

  @override
  String get colorBrown => 'Marrón';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count semanas',
      one: 'Hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count meses',
      one: 'Hace 1 mes',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count años',
      one: 'Hace 1 año',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => '¿Te gusta FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Tu valoración ayuda a otros a encontrar su estilo.';

  @override
  String get ratingPromptYes => 'Valorar app';

  @override
  String get ratingPromptNo => 'Ahora no';

  @override
  String get closetNoMatchesTitle => 'Sin resultados';

  @override
  String get closetNoMatchesBody =>
      'Prueba con menos filtros o cambia la búsqueda.';

  @override
  String get closetClearFilters => 'Borrar filtros';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prendas',
      one: '1 prenda',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Cargando tus prendas';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionadas',
      one: '1 seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Eliminar seleccionadas';

  @override
  String get closetCancelSelection => 'Cancelar selección';

  @override
  String get closetCloseSearch => 'Cerrar búsqueda';

  @override
  String get closetShowGrid => 'Ver en cuadrícula';

  @override
  String get closetShowList => 'Ver en lista';

  @override
  String get closetShowRows => 'Ver en filas';

  @override
  String get closetStatsTitle => 'Estadísticas del armario';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count prendas?',
      one: '¿Eliminar 1 prenda?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Los conjuntos que las usan perderán estas prendas.';

  @override
  String get closetSortBy => 'Ordenar por';

  @override
  String get closetFavourites => 'Favoritos';

  @override
  String get closetFavourite => 'Añadir a favoritos';

  @override
  String get closetUnfavourite => 'Quitar de favoritos';

  @override
  String get closetWoreToday => 'Puesta hoy';

  @override
  String closetWornTimes(int count) {
    return 'Usada $count×';
  }

  @override
  String get closetCategoryLabel => 'Categoría';

  @override
  String get closetUseCaseLabel => 'Ocasión';

  @override
  String get closetAnyUseCase => 'Cualquiera';

  @override
  String get closetOtherUseCase => 'Otra ocasión';

  @override
  String get closetOtherUseCaseHint => 'Por ejemplo, brunch';

  @override
  String get closetUseUseCase => 'Usar esta';

  @override
  String get closetClearAll => 'Borrar todo';

  @override
  String get sortNewest => 'Más recientes primero';

  @override
  String get sortOldest => 'Más antiguos primero';

  @override
  String get sortName => 'Nombre (A–Z)';

  @override
  String get sortMostWorn => 'Más usadas';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Cita';

  @override
  String get useCaseDinner => 'Cena';

  @override
  String get useCaseLunch => 'Comida';

  @override
  String get actionSelect => 'Seleccionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get actionSort => 'Ordenar';

  @override
  String get actionAll => 'Todo';

  @override
  String get dashboardStartClosetTitle => 'Empieza tu armario';

  @override
  String get dashboardStartClosetBody =>
      'Fotografía algunas prendas. Nosotros las etiquetamos por ti.';

  @override
  String get dashboardPieces => 'prendas';

  @override
  String get dashboardOutfits => 'conjuntos';

  @override
  String get dashboardDayStreak => 'días seguidos';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count este mes';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Mejor racha: $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritos',
      one: '1 favorito',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conjuntos guardados',
      one: '1 conjunto guardado',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Más usada: $name, $count veces';
  }

  @override
  String get setupSkip => 'Omitir configuración';

  @override
  String get setupWhoTitle => '¿A quién vestimos?';

  @override
  String get setupWhoBody =>
      'Define el modelo para pruebas y fotos. Puedes cambiarlo en tu perfil.';

  @override
  String get setupStyleTitle => '¿Qué sueles llevar?';

  @override
  String get setupStyleBody =>
      'Elige cualquiera. Las ideas de conjuntos parten de aquí.';

  @override
  String get setupClosetTitle => 'Añade tus primeras prendas.';

  @override
  String get setupClosetBody =>
      'Fotografía algunas prendas o un montón de ellas. Cada pieza se recortará y guardará por ti.';

  @override
  String get setupAddClothes => 'Añadir ropa';

  @override
  String get setupStylesLabel => 'Estilos';

  @override
  String get setupOccasionsLabel => 'Ocasiones';

  @override
  String get setupSkipStep => 'Omitir';

  @override
  String get setupLater => 'Más tarde';

  @override
  String get setupSaveError => 'No se pudo guardar';

  @override
  String get genderWomen => 'Mujer';

  @override
  String get genderMen => 'Hombre';

  @override
  String get genderNonBinary => 'No binario';

  @override
  String get genderPreferNotToSay => 'Prefiero no decirlo';

  @override
  String get outfitEmptyTitle => 'Aún sin conjuntos';

  @override
  String get outfitEmptyBody =>
      'Combina prendas de tu armario y guarda el look.';

  @override
  String get outfitNoMatchesTitle => 'No hay conjuntos';

  @override
  String get outfitSearchHint => 'Busca en tus conjuntos';

  @override
  String get outfitLoading => 'Cargando tus conjuntos';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conjuntos',
      one: '1 conjunto',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Estilo y temporada';

  @override
  String get outfitCollections => 'Colecciones';

  @override
  String get outfitDuplicate => 'Duplicar';

  @override
  String get outfitDeleteTitle => '¿Eliminar este conjunto?';

  @override
  String get outfitDeleteBody => 'Las prendas permanecerán en tu armario.';

  @override
  String get outfitDrafts => 'Borradores';

  @override
  String get outfitDraft => 'Borrador';

  @override
  String get filterStyle => 'Estilo';

  @override
  String get filterSeason => 'Temporada';

  @override
  String get itemDetailDeleteTitle => '¿Eliminar esta prenda?';

  @override
  String get itemDetailDeleteBody =>
      'Los conjuntos que la usan perderán esta prenda.';

  @override
  String get itemAddFavourite => 'Añadir a favoritos';

  @override
  String itemSize(String size) {
    return 'Talla $size';
  }

  @override
  String get itemColours => 'Colores';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Estampado';

  @override
  String get itemUseCases => 'Ocasiones';

  @override
  String get itemKeptIn => 'Guardado en';

  @override
  String get itemPrice => 'Precio';

  @override
  String get itemBought => 'Comprado';

  @override
  String get itemTags => 'Etiquetas';

  @override
  String get itemAdded => 'Añadido';

  @override
  String get itemTimesWornLabel => 'veces usado';

  @override
  String get itemLastWornLabel => 'última vez';

  @override
  String get itemNeverWorn => 'Nunca';

  @override
  String get authEntryBody =>
      'Cada prenda que tienes, combinada por IA. Planifica conjuntos, pruébatelos y fotografíalos.';

  @override
  String get authCreateCloset => 'Crea tu armario';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authSignInBody => 'Inicia sesión para abrir tu armario.';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authCreateClosetBody =>
      'Solo lleva un minuto. Tus primeras prendas son gratis.';

  @override
  String get authName => 'Nombre';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authReferralCode => 'Código de invitación (opcional)';

  @override
  String get authResetTitle => 'Restablecer contraseña';

  @override
  String get authResetBody =>
      'Te enviaremos un enlace por correo para elegir una nueva.';

  @override
  String get authSendResetLink => 'Enviar enlace';

  @override
  String get authBackToSignIn => 'Volver a iniciar sesión';

  @override
  String get authEnterEmail => 'Introduce tu email';

  @override
  String get authEnterValidEmail => 'Introduce un email válido';

  @override
  String get authEnterPassword => 'Introduce tu contraseña';

  @override
  String get authPasswordTooShort => 'Mínimo 6 caracteres';

  @override
  String get authShowPassword => 'Mostrar';

  @override
  String get authHidePassword => 'Ocultar';

  @override
  String get authNewHere => '¿Eres nuevo?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirma $email antes de iniciar sesión. Revisa tu bandeja de entrada.';
  }

  @override
  String get authResendEmail => 'Reenviar';

  @override
  String get authResendingEmail => 'Enviando…';

  @override
  String get authPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get authEnterName => 'Introduce tu nombre';

  @override
  String get authChoosePassword => 'Elige una contraseña';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authCodeAccepted => 'Código aceptado';

  @override
  String get authCodeNotFound => 'Código no encontrado';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Ambos recibís un mes gratis.';
  }

  @override
  String get authReferralInvalid => 'No hemos encontrado este código.';

  @override
  String authResetSent(String email) {
    return 'Enviado a $email. Abre el enlace en este teléfono.';
  }

  @override
  String get introSlide1Title => 'Fotografía tu armario una vez.';

  @override
  String get introSlide1Body =>
      'Haz una foto a tu ropa. Cada prenda se recorta y guarda automáticamente.';

  @override
  String get introSlide2Title => 'Vístete más rápido.';

  @override
  String get introSlide2Body =>
      'Conjuntos con tu ropa, adaptados a tus planes y al tiempo.';

  @override
  String get introSlide3Title => 'Pruébatelo antes de salir.';

  @override
  String get introSlide3Body =>
      'Prueba looks sobre tu foto o crea imágenes como en una campaña.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Actualizaciones por email';

  @override
  String get settingsEmailUpdatesBody => 'Noticias y consejos por email';

  @override
  String get settingsOutfitReminders => 'Recordatorios de outfits';

  @override
  String get settingsOutfitRemindersBody =>
      'Un aviso para registrar lo que llevas puesto';

  @override
  String get settingsWeeklySummary => 'Resumen semanal';

  @override
  String get settingsWeeklySummaryBody => 'Tu semana en outfits';

  @override
  String get settingsStyleSection => 'Estilo';

  @override
  String get settingsPreferredStyles => 'Estilos que te gustan';

  @override
  String get settingsPreferredColours => 'Colores que te gustan';

  @override
  String get settingsNoneChosen => 'Ninguno seleccionado';

  @override
  String get settingsPlanAiSection => 'Plan e IA';

  @override
  String get settingsPlanBillingBody => 'Plan, uso y mejoras';

  @override
  String get settingsPlanUsageBody => 'Plan y uso';

  @override
  String get settingsInviteFriends => 'Invitar amigos';

  @override
  String get settingsInviteFriendsBody =>
      'Un mes gratis por cada amigo que se una';

  @override
  String get settingsAiProvider => 'Proveedor de IA';

  @override
  String get settingsAiProviderBody =>
      'Usa tu propio modelo para etiquetas e imágenes';

  @override
  String get settingsAppVersion => 'Versión de la app';

  @override
  String get settingsPrivacyTerms => 'Privacidad y términos';

  @override
  String get settingsReportProblem => 'Informar de un problema';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsExportData => 'Exportar tus datos';

  @override
  String get settingsExportBody =>
      'Preparamos un archivo con todo lo que has guardado y abrimos la descarga.';

  @override
  String get settingsExportAction => 'Exportar';

  @override
  String get settingsCurrentPassword => 'Contraseña actual';

  @override
  String get settingsNewPassword => 'Nueva contraseña';

  @override
  String get settingsConfirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get settingsEnterCurrentPassword => 'Introduce tu contraseña actual';

  @override
  String get settingsEnterNewPassword => 'Introduce una nueva contraseña';

  @override
  String get settingsPasswordMin8 => 'Usa al menos 8 caracteres';

  @override
  String get settingsPasswordNeedsUpper => 'Añade una letra mayúscula';

  @override
  String get settingsPasswordNeedsLower => 'Añade una letra minúscula';

  @override
  String get settingsPasswordNeedsDigit => 'Añade un número';

  @override
  String get settingsPasswordsNoMatch => 'Las contraseñas no coinciden';

  @override
  String get settingsChangeAction => 'Cambiar';

  @override
  String get itemAddSnapTitle => 'Fotografía una prenda';

  @override
  String get itemAddSnapBody =>
      'Detectamos cada prenda en la foto y creamos una imagen de estudio limpia.';

  @override
  String get itemAddCamera => 'Hacer una foto';

  @override
  String get itemAddGallery => 'Elegir de la galería';

  @override
  String get itemAddOtherWays => 'Otras formas de añadir';

  @override
  String get itemAddSeveral => 'Añadir varias fotos';

  @override
  String get itemAddSeveralBody => 'Hasta 50 a la vez';

  @override
  String get itemAddImportProfile => 'Importar desde un perfil';

  @override
  String get itemAddImportProfileBody => 'Instagram o Facebook';

  @override
  String get itemAddEnterDetails => 'Introducir detalles manualmente';

  @override
  String get itemAddEnterDetailsBody => 'No necesitas foto';

  @override
  String get itemManualIntro =>
      'Solo necesitas un nombre. Añade el resto ahora o después.';

  @override
  String get itemManualNameHint => 'Por ejemplo, camiseta azul de algodón';

  @override
  String get itemManualEnterName => 'Introduce un nombre';

  @override
  String get itemManualNotes => 'Notas';

  @override
  String get itemManualBrand => 'Marca';

  @override
  String get itemManualSize => 'Talla';

  @override
  String get itemManualEnterNumber => 'Introduce un número';

  @override
  String get itemManualSavePiece => 'Guardar prenda';

  @override
  String get itemManualSaving => 'Guardando';

  @override
  String get itemManualSavedTitle => 'Guardado';

  @override
  String itemManualSavedBody(String name) {
    return '$name está en tu armario.';
  }

  @override
  String get itemManualNotSaved => 'No guardado';

  @override
  String get itemManualAddUseCase => 'Añadir uso';

  @override
  String get itemManualAddUseCaseAction => 'Añadir uso';

  @override
  String get itemPhotos => 'Fotos';

  @override
  String get itemAddPhotos => 'Añadir fotos';

  @override
  String get itemNoPhotoYet => 'Sin foto. Puedes guardar sin ella.';

  @override
  String get itemRemovePhoto => 'Eliminar foto';

  @override
  String get itemRemovePiece => 'Eliminar prenda';

  @override
  String get filterConditionLabel => 'Estado';

  @override
  String get photoshootStepPhotos => 'Fotos';

  @override
  String get photoshootStepSetup => 'Configuración';

  @override
  String get photoshootStepCreating => 'Creando';

  @override
  String get photoshootStepResults => 'Resultados';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Paso $current de $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Una foto falló. Reinténtalo abajo.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotos fallaron. Reinténtalas abajo.';
  }

  @override
  String get photoshootFormat => 'Formato';

  @override
  String get photoshootHowMany => 'Cantidad';

  @override
  String get photoshootYourPrompt => 'Tu descripción';

  @override
  String get photoshootPromptHint =>
      'Hora dorada en una azotea, camisa de lino';

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
  String get photoshootLimitUnknown => 'No pudimos comprobar el límite de hoy.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plan $plan: $remaining de $limit hoy';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratis';

  @override
  String get photoshootGallery => 'Galería';

  @override
  String get photoshootUseCamera => 'Usar cámara';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Eliminar foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'No se han recibido fotos';

  @override
  String get photoshootNoPhotosBody =>
      'La sesión terminó sin imágenes. Inténtalo de nuevo.';

  @override
  String get photoshootNewStyle => 'Nuevo estilo';

  @override
  String get photoshootNewPhotos => 'Nuevas fotos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Abrir foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Denunciar foto';

  @override
  String get photoshootSaveToGallery => 'Guardar en galería';

  @override
  String get actionUpgrade => 'Actualizar';

  @override
  String get referralLimitTitle => 'Has usado tus fotos de hoy';

  @override
  String get referralLimitBody =>
      'Tus fotos gratuitas vuelven mañana. Invita a un amigo y ambos obtendréis un mes de Pro gratis.';

  @override
  String get referralLimitRefer => 'Invitar a un amigo';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Apps de citas';

  @override
  String get photoshootUsePortfolio => 'Portfolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estético';

  @override
  String get photoshootUseCustom => 'Tu propio prompt';

  @override
  String get photoshootDescLinkedin => 'Fotos profesionales para el trabajo';

  @override
  String get photoshootDescDating => 'Relajado, cálido y natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, looks de alta moda';

  @override
  String get photoshootDescInstagram => 'Fotos de estilo de vida para tu feed';

  @override
  String get photoshootDescAesthetic => 'Encuadres artísticos y sugerentes';

  @override
  String get photoshootDescCustom => 'Describe el look que buscas';

  @override
  String get aspectSquare => 'Cuadrado';

  @override
  String get aspectPortrait => 'Retrato';

  @override
  String get aspectLandscape => 'Paisaje';

  @override
  String get aspectTall => 'Vertical';

  @override
  String get aspectWide => 'Horizontal';

  @override
  String get tryOnAppBar => 'Probador virtual';

  @override
  String get tryOnYourPhoto => 'Tu foto';

  @override
  String get tryOnGarment => 'Prenda';

  @override
  String get tryOnUploadingPhoto => 'Subiendo tu foto';

  @override
  String get tryOnAddPhotoPrompt => 'Añade una foto tuya de cuerpo entero';

  @override
  String get tryOnBodyPhotoHint => 'Una foto de cuerpo entero funciona mejor';

  @override
  String get tryOnAddPhoto => 'Añadir foto';

  @override
  String get tryOnChangePhoto => 'Cambiar foto';

  @override
  String get tryOnPhotoLoadFailed => 'No hemos podido cargar tu foto.';

  @override
  String get tryOnChooseGarment => 'Elige la foto de una prenda';

  @override
  String get tryOnChooseOneGarment => 'Elige una foto de prenda';

  @override
  String get tryOnGarmentHint =>
      'Una foto de la prenda extendida o en percha funciona mejor';

  @override
  String get tryOnChange => 'Cambiar';

  @override
  String get tryOnCamera => 'Cámara';

  @override
  String get tryOnRemove => 'Eliminar';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Estilo';

  @override
  String get tryOnBackground => 'Fondo';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Vistiéndote. Tardará medio minuto aproximadamente.';

  @override
  String get tryOnEmptyResult => 'Tu prueba aparecerá aquí';

  @override
  String get tryOnReportImage => 'Denunciar imagen';

  @override
  String get tryOnCreating => 'Creando';

  @override
  String get tryOnTryAgain => 'Intentar de nuevo';

  @override
  String get tryOnCreate => 'Crear prueba';

  @override
  String get tryOnBackgroundStudioWhite => 'Estudio blanco';

  @override
  String get tryOnBackgroundStudioGrey => 'Estudio gris';

  @override
  String get tryOnBackgroundUrban => 'Calle urbana';

  @override
  String get tryOnBackgroundNature => 'Naturaleza';

  @override
  String get tryOnBackgroundMinimal => 'Minimalista';

  @override
  String get tryOnPoseFront => 'De frente';

  @override
  String get tryOnPoseSide => 'De lado';

  @override
  String get tryOnPoseWalking => 'Caminando';

  @override
  String get dashboardGreetingMorning => 'Buenos días';

  @override
  String get dashboardGreetingAfternoon => 'Buenas tardes';

  @override
  String get dashboardGreetingEvening => 'Buenas noches';

  @override
  String get dashboardWelcome => 'Bienvenido';

  @override
  String get dashboardOpenProfile => 'Abrir perfil';

  @override
  String get dashboardRailToday => 'Hoy';

  @override
  String get dashboardRailRecently => 'Reciente';

  @override
  String get dashboardActivityEmpty =>
      'Aquí verás tus nuevas prendas y conjuntos.';

  @override
  String get quickAddPiece => 'Añadir prenda';

  @override
  String get quickAddPieceBody => 'Fotografía y etiqueta';

  @override
  String get quickBuildOutfit => 'Crear conjunto';

  @override
  String get quickBuildOutfitBody => 'Combina tus prendas';

  @override
  String get quickForYou => 'Para ti';

  @override
  String get quickForYouBody => 'Sugerencias de hoy';

  @override
  String get quickPlanWeek => 'Planificar semana';

  @override
  String get quickPlanWeekBody => 'Conjuntos por fecha';

  @override
  String get referralBannerUrgent => '¿Te queda poco? Invita a un amigo.';

  @override
  String get referralBannerTitle => 'Regala un mes, gana un mes.';

  @override
  String get referralBannerBody => 'Tú y tu amigo obtendréis un mes de Pro.';

  @override
  String get referralBannerDismiss => 'Ocultar una semana';

  @override
  String get referralBannerShare => 'Compartir invitación';

  @override
  String get referralBannerCopy => 'Copiar enlace';

  @override
  String get itemEditPieceTitle => 'Editar prenda';

  @override
  String get itemEditDescriptionLabel => 'Descripción';

  @override
  String get itemEditNotSaved => 'No guardado';

  @override
  String get itemEditSavedTitle => 'Guardado';

  @override
  String get itemEditSavedBody => 'Cambios guardados.';

  @override
  String get itemEditSavedStalePhotos =>
      'Guardado: las fotos podrían estar desactualizadas';

  @override
  String get itemEditRemovePieceHint =>
      'Elimina esta pieza de la página de la prenda.';

  @override
  String get itemEditNoPhotos =>
      'Aún no hay fotos. Añade una desde tu galería o cámara.';

  @override
  String get itemEditKeepPhoto => 'Mantener foto';

  @override
  String get itemEditRemoved => 'Eliminado';

  @override
  String get itemEditAddUseCaseAction => 'Añadir';

  @override
  String get statsNoStatsTitle => 'Aún sin estadísticas';

  @override
  String get statsNoStatsBody =>
      'Añade algunas prendas y tu resumen de armario aparecerá aquí.';

  @override
  String get statsByCategory => 'Por categoría';

  @override
  String get statsTotalValue => 'valor total';

  @override
  String get statsMostWorn => 'Más usadas';

  @override
  String get statsLeastWorn => 'Esperando su turno';

  @override
  String get statsUnnamedPiece => 'Prenda sin nombre';

  @override
  String get jobsTitle => 'Análisis';

  @override
  String get jobsEmptyTitle => 'Aún sin análisis';

  @override
  String get jobsEmptyBody =>
      'Fotografía una prenda y envíala a segundo plano; seguirá procesándose aquí.';

  @override
  String get jobsNotCancelled => 'No cancelado';

  @override
  String get jobsResume => 'Reanudar';

  @override
  String get jobsReview => 'Revisar';

  @override
  String get jobsStop => 'Detener';

  @override
  String get jobsDismiss => 'Descartar';

  @override
  String get reportTitle => 'Denunciar contenido';

  @override
  String reportIntro(String contentType) {
    return 'Dinos qué ocurre con este $contentType. Nuestro equipo revisa cada denuncia.';
  }

  @override
  String get reportReasonInappropriate => 'Inapropiado u ofensivo';

  @override
  String get reportReasonNudity => 'Desnudez o contenido sexual';

  @override
  String get reportReasonHarassment => 'Acoso o abuso';

  @override
  String get reportReasonImpersonation => 'Suplantación de identidad';

  @override
  String get reportReasonOther => 'Otro';

  @override
  String get reportDetailsLabel => 'Detalles adicionales (opcional)';

  @override
  String get reportSubmit => 'Enviar denuncia';

  @override
  String get reportSubmittedTitle => 'Denuncia enviada';

  @override
  String get reportSubmittedBody =>
      'Gracias. Nuestro equipo revisará este contenido.';

  @override
  String get reportFailedTitle => 'No se pudo enviar';

  @override
  String get reportFailedBody => 'Inténtalo de nuevo.';

  @override
  String get reportContentTryOnImage => 'imagen de prueba virtual';

  @override
  String get reportContentSharedOutfit => 'conjunto compartido';

  @override
  String get reportContentPhotoshootImage => 'imagen de sesión de fotos IA';

  @override
  String get sharedOutfitTitle => 'Conjunto compartido';

  @override
  String get sharedOutfitHideTooltip => 'Ocultar este conjunto';

  @override
  String get sharedOutfitReportTooltip => 'Denunciar este conjunto';

  @override
  String get sharedOutfitHideTitle => '¿Ocultar este conjunto?';

  @override
  String get sharedOutfitHideBody =>
      'Permanecerá oculto en este dispositivo. También puedes denunciarlo para que nuestro equipo lo revise y elimine.';

  @override
  String get sharedOutfitHideAction => 'Ocultar';

  @override
  String get sharedOutfitHiddenInfo =>
      'Este conjunto no volverá a aparecer en este dispositivo.';

  @override
  String get sharedOutfitHiddenToast => 'Conjunto oculto';

  @override
  String get sharedOutfitMissingTitle => 'Este conjunto ya no está disponible';

  @override
  String get sharedOutfitMissingBody =>
      'Puede que se haya eliminado o que el enlace sea incorrecto.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Has ocultado este conjunto';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Si es inapropiado, denúncialo desde Privacidad y términos o envía un correo a $email.';
  }

  @override
  String get sharedOutfitCtaTitle => '¿Te gusta este look?';

  @override
  String get sharedOutfitCtaBody =>
      'Crea conjuntos similares con tu propia ropa.';

  @override
  String get sharedOutfitCtaButton => 'Obtén FitCheck AI';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnknown => 'Ha ocurrido un error inesperado';

  @override
  String get errorNoConnection => 'Sin conexión a internet. Comprueba tu red.';

  @override
  String get errorTimeout => 'La solicitud ha caducado. Inténtalo de nuevo.';

  @override
  String get errorServerError =>
      'Algo ha salido mal por nuestra parte. Inténtalo de nuevo.';

  @override
  String get errorBadGateway =>
      'Nuestro servidor no está disponible. Inténtalo de nuevo.';

  @override
  String get errorServiceUnavailable =>
      'El servicio no está disponible temporalmente. Inténtalo en breve.';

  @override
  String get errorInternalError => 'Algo ha salido mal. Inténtalo de nuevo.';

  @override
  String get errorUnauthorized => 'Inicia sesión para continuar.';

  @override
  String get errorForbidden => 'No tienes acceso a esto.';

  @override
  String get errorSessionExpired =>
      'Tu sesión ha caducado. Inicia sesión de nuevo.';

  @override
  String get errorInvalidCredentials =>
      'El correo o la contraseña no son correctos.';

  @override
  String get errorTokenRefreshFailed =>
      'No hemos podido renovar tu sesión. Inicia sesión de nuevo.';

  @override
  String get errorRequestCancelled => 'Solicitud cancelada.';

  @override
  String get errorInvalidFormat => 'Formato de archivo no compatible.';

  @override
  String get errorFileTooLarge => 'El archivo es demasiado grande.';

  @override
  String get errorUploadFailed => 'Error en la carga. Inténtalo de nuevo.';

  @override
  String get errorCacheCorrupted =>
      'Los datos guardados estaban dañados y se han restablecido.';

  @override
  String get errorCacheNotFound => 'Aún no hay nada guardado.';

  @override
  String get errorUserNotFound => 'No hemos encontrado esa cuenta.';

  @override
  String get errorItemNotFound => 'Esa prenda ya no existe.';

  @override
  String get errorOutfitNotFound => 'Ese conjunto ya no existe.';

  @override
  String get rewardsTitle => 'Recompensas';

  @override
  String get rewardsNoAchievementsTitle => 'Aún sin logros';

  @override
  String get rewardsNoAchievementsBody =>
      'Añade prendas y planifica conjuntos para conseguir el primero.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Aún no hay nadie en la lista';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planifica conjuntos para ganar puntos y aparecer aquí.';

  @override
  String get legalViewPrivacyPolicy => 'Ver política de privacidad';

  @override
  String get aiConsentAgree => 'Acepto y continuar';

  @override
  String get aiConsentNotNow => 'Ahora no';

  @override
  String get imageViewerCloseTooltip => 'Cerrar visor de imágenes';

  @override
  String get updateReadyTitle => 'Actualización lista';

  @override
  String get updateReadyBody =>
      'Reinicia FitCheck AI para aplicar las últimas mejoras.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI necesita acceso a la cámara para hacer fotos de tus conjuntos y prendas.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI necesita acceso a la fototeca para seleccionar imágenes de tus conjuntos y prendas.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI necesita guardar las fotos de tus conjuntos generadas por IA en tu fototeca.';

  @override
  String get wardrobeSomePhotosSkipped => 'Algunas fotos omitidas';

  @override
  String get wardrobePhotosNotAdded => 'Fotos no añadidas';

  @override
  String get wardrobePhotoNotAdded => 'Foto no añadida';

  @override
  String get wardrobeNotStartedTitle => 'No iniciado';

  @override
  String get wardrobeNoRoomTitle => 'Sin espacio';

  @override
  String get wardrobeAddPhotosSemantic => 'Añadir fotos';

  @override
  String get batchAddTileLabel => 'Añadir';

  @override
  String get batchProfileLinkLabel => 'Enlace de perfil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importar desde un perfil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Añadir varias fotos';

  @override
  String get wardrobeClearAction => 'Borrar';

  @override
  String get wardrobeRefreshTooltip => 'Actualizar';

  @override
  String get batchNoPhotosYetTitle => 'Aún no hay fotos';

  @override
  String get batchChoosePhotosAction => 'Elegir fotos';

  @override
  String get batchWeFindEachPieceBody =>
      'Encontramos cada prenda y creamos una foto de estudio de ella.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparando fotos';

  @override
  String get batchPhotosProcessedSemantic => 'Fotos procesadas';

  @override
  String get batchPasteProfileLinkTitle => 'Pega un enlace de perfil';

  @override
  String get batchPasteProfileLinkBody =>
      'Un perfil público de Instagram o Facebook. Escaneamos sus fotos y tú eliges qué añadir a tu armario.';

  @override
  String get batchClearLinkTooltip => 'Borrar enlace';

  @override
  String get batchStartingButton => 'Iniciando';

  @override
  String get batchStartImportAction => 'Iniciar importación';

  @override
  String get batchReviewEveryPhotoTitle => 'Revisas cada foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'No se añade nada hasta que lo apruebes.';

  @override
  String get batchPrivateProfilesTitle => 'Perfiles privados';

  @override
  String get batchPrivateProfilesBody =>
      'Conecta tu cuenta. Instagram también requiere un nombre de usuario y contraseña.';

  @override
  String get batchUseAnotherLinkAction => 'Usar otro enlace';

  @override
  String get batchSignInNeededTitle => 'Inicio de sesión necesario';

  @override
  String get batchEnterYourCodeTitle => 'Introduce tu código';

  @override
  String get batchUseUsernamePasswordAction => 'Usar usuario y contraseña';

  @override
  String get batchAlreadyConnectedAction =>
      'Ya me he conectado en el navegador';

  @override
  String get batchEnterCodeAction => 'Introducir código';

  @override
  String get batchTryAnotherWayAction => 'Probar de otra forma';

  @override
  String get batchLiveStatus => 'En directo';

  @override
  String get batchReconnectingStatus => 'Reconectando';

  @override
  String get batchSignInToInstagramTitle => 'Iniciar sesión en Instagram';

  @override
  String get batchUsernameLabel => 'Nombre de usuario';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Código, si usas verificación en dos pasos';

  @override
  String get batchAuthenticatorCodeBody =>
      'Usa el código de 6 dígitos de tu app de autenticación. Los códigos cambian rápidamente.';

  @override
  String get batchVerifyAction => 'Verificar';

  @override
  String get batchFindingPhotosTitle => 'Buscando fotos';

  @override
  String get batchImportPausedTitle => 'Importación pausada';

  @override
  String get batchProcessingPhotosTitle => 'Procesando fotos';

  @override
  String get batchWaitingNextPhoto => 'Esperando la siguiente foto';

  @override
  String get batchCancelImportAction => 'Cancelar importación';

  @override
  String get batchNoPiecesInPhotoBody =>
      'No se encontraron prendas en esta foto.';

  @override
  String get batchEditPieceColoursLabel => 'Colores, separados por comas';

  @override
  String get batchAddToClosetAction => 'Añadir al armario';

  @override
  String get batchSkipPhotoAction => 'Omitir esta foto';

  @override
  String get batchImportCompleteTitle => 'Importación completada';

  @override
  String get batchImportFailedTitle => 'Error en la importación';

  @override
  String get batchImportCancelledTitle => 'Importación cancelada';

  @override
  String get batchImportErrorBody => 'Algo salió mal durante la importación.';

  @override
  String get batchNothingMoreImportedBody =>
      'No se ha importado nada más de este perfil.';

  @override
  String get batchViewClosetAction => 'Ver armario';

  @override
  String get batchStartOverAction => 'Empezar de nuevo';

  @override
  String get wardrobeAddPieceTitle => 'Añadir prenda';

  @override
  String get wardrobeAddDetailsTitle => 'Añadir detalles';

  @override
  String get wardrobeScanningTitle => 'Escaneando';

  @override
  String get batchReviewPiecesTitle => 'Revisar prendas';

  @override
  String get wardrobeGalleryAction => 'Galería';

  @override
  String get wardrobeCameraAction => 'Cámara';

  @override
  String get wardrobeNewBadge => 'Nuevo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Eliminar foto';

  @override
  String get batchRunInBackgroundTooltip => 'Ejecutar en segundo plano';

  @override
  String get batchStepOneOfTwo => 'Paso 1 de 2';

  @override
  String get batchStepTwoOfTwo => 'Paso 2 de 2';

  @override
  String get batchUploadingPhotosTitle => 'Subiendo fotos';

  @override
  String get batchFindingPiecesTitle => 'Buscando prendas';

  @override
  String get batchMakingStudioPhotosTitle => 'Creando fotos de estudio';

  @override
  String get batchStoppedLabel => 'Detenido';

  @override
  String get batchFindingPiecesStoppedTitle => 'Búsqueda de prendas detenida';

  @override
  String get batchCancelledLabel => 'Cancelado';

  @override
  String get batchAllDoneTitle => 'Listo';

  @override
  String get batchOpeningPiecesBody => 'Abriendo tus prendas';

  @override
  String get batchNothingSavedBody => 'No se ha guardado nada.';

  @override
  String get batchFindingPiecesFailedBody => 'Error al buscar prendas.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'La búsqueda de prendas se detuvo antes de tiempo.';

  @override
  String get batchStopFindingPiecesTitle => '¿Detener la búsqueda?';

  @override
  String get batchStopFindingPiecesBody =>
      'El escaneo se detendrá y no se guardará nada. Las prendas ya encontradas permanecerán en tu actividad hasta que las descartes.';

  @override
  String get batchKeepGoingAction => 'Continuar';

  @override
  String get batchTryAgainAction => 'Reintentar';

  @override
  String get batchBackToPhotosAction => 'Volver a las fotos';

  @override
  String get batchSkipAllAction => 'Omitir todo';

  @override
  String get batchIncludeAllAction => 'Incluir todas';

  @override
  String get batchNoPiecesFoundTitle => 'No se encontraron prendas';

  @override
  String get batchNoPiecesFoundBody =>
      'No hemos encontrado ropa en estas fotos.';

  @override
  String get batchChooseOtherPhotosAction => 'Elegir otras fotos';

  @override
  String get batchUseCaseHelper => 'Se añade a cada prenda que guardes.';

  @override
  String get batchDiscardPiecesTitle => '¿Descartar estas prendas?';

  @override
  String get batchDiscardPiecesBody => 'No se guardará nada de este lote.';

  @override
  String get batchKeepAction => 'Mantener';

  @override
  String get batchDiscardAction => 'Descartar';

  @override
  String get batchRemovePieceTitle => '¿Eliminar esta prenda?';

  @override
  String get batchRemovePieceBody => 'No se guardará en tu armario.';

  @override
  String get batchRemoveAction => 'Eliminar';

  @override
  String get batchChoosePiecesToSave => 'Elige prendas para guardar';

  @override
  String get batchDiscardAllAction => 'Descartar todas';

  @override
  String get batchNothingSavedRetryBody =>
      'No se guardó nada. Inténtalo de nuevo.';

  @override
  String get batchNotSavedTitle => 'No guardado';

  @override
  String get batchSavingLabel => 'Guardando';

  @override
  String get batchSendToBackgroundAction => 'Enviar a segundo plano';

  @override
  String get batchStillWorkingMessage =>
      'Seguimos trabajando. Te avisaremos cuando tus prendas estén listas.';

  @override
  String get batchRunningInBackgroundTitle => 'Ejecutándose en segundo plano';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Las fotos de estudio se detuvieron antes de tiempo. Aún puedes guardar estas prendas.';

  @override
  String get batchTapPieceToSkip => 'Toca una prenda para omitirla.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Las fotos de estudio están en camino. Puedes salir; te avisaremos.';

  @override
  String get batchLeaveAction => 'Salir';

  @override
  String get batchPeopleInPhotosTitle => 'Personas en las fotos';

  @override
  String get batchIncludeAction => 'Incluir';

  @override
  String get batchSkipAction => 'Omitir';

  @override
  String get batchYourPhotoIsUsedLabel => 'Se usa tu foto';

  @override
  String get batchMakingStudioPhotoLabel => 'Creando foto de estudio';

  @override
  String get batchNoStudioPhotoBody => 'Sin foto de estudio. Se usa tu foto.';

  @override
  String get batchEnterDetailsYourselfAction =>
      'Introducir detalles manualmente';

  @override
  String get batchChooseAnotherPhotoAction => 'Elegir otra foto';

  @override
  String get batchConnectionLostTitle => 'Conexión perdida';

  @override
  String get batchConnectionLostBody =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get batchDailyLimitTitle => 'Límite diario alcanzado';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Mejora a Pro para más escaneos o introduce los detalles manualmente.';

  @override
  String get batchDailyLimitBodyFree =>
      'Tus escaneos se reinician mañana. Puedes introducir los detalles manualmente ahora.';

  @override
  String get batchSeePlansAction => 'Ver planes';

  @override
  String get batchAiBusyTitle => 'Nuestra IA está ocupada';

  @override
  String get batchAiBusyBody =>
      'Es un problema nuestro. Inténtalo de nuevo en unos minutos.';

  @override
  String get batchNoPiecesBody =>
      'Prueba con una foto más clara o introduce los detalles manualmente.';

  @override
  String get batchScanningUnavailableTitle => 'Escaneo no disponible';

  @override
  String get batchScanningUnavailableBody =>
      'Introduce los detalles manualmente por ahora.';

  @override
  String get batchScanDidNotFinishTitle => 'El escaneo no terminó';

  @override
  String get batchTryAgainBody => 'Inténtalo de nuevo.';

  @override
  String get billingTitle => 'Suscripción';

  @override
  String get billingUpgradeHeading => 'Mejora tu plan';

  @override
  String get billingUpgradeOnPlusBody => 'Mismas funciones, límites más altos.';

  @override
  String get billingUpgradeBody =>
      'Plus y Pro tienen las mismas funciones. Elige los límites que necesites.';

  @override
  String get billingWebUnavailableBody =>
      'Las mejoras online aún no están disponibles. Un código promocional o de referido desbloquea Plus o Pro. Invita a amigos abajo para ganar meses gratis.';

  @override
  String get billingPlansStale =>
      'No se pudieron cargar los planes. Los precios podrían no estar actualizados.';

  @override
  String get billingMonthly => 'Mensual';

  @override
  String get billingYearly => 'Anual';

  @override
  String get billingCurrentPlan => 'Plan actual';

  @override
  String get billingActive => 'Activo';

  @override
  String get billingThisMonth => 'Este mes';

  @override
  String get billingItemExtractions => 'Extracciones de prendas';

  @override
  String get billingOutfitVisualizations => 'Visualizaciones de conjuntos';

  @override
  String get billingNearLimitUpgrade =>
      'Te acercas al límite de este mes. Mejora tu plan para más.';

  @override
  String get billingNearLimitResets =>
      'Te acercas al límite de este mes. Se reinicia a principios del próximo mes.';

  @override
  String get billingStoreUnavailable =>
      'Las mejoras no están disponibles en la tienda aún. Vuelve pronto.';

  @override
  String get billingManageHeading => 'Gestionar tu plan';

  @override
  String get billingCancelPlan => 'Cancelar suscripción';

  @override
  String get billingCancelKeepsAccess =>
      'Mantendrás el acceso hasta el final del periodo de facturación.';

  @override
  String get billingCancelConfirmTitle => '¿Cancelar tu suscripción?';

  @override
  String get billingKeepPlan => 'Mantener plan';

  @override
  String get billingCancelPlanAction => 'Cancelar plan';

  @override
  String get billingBilledMonthly => 'Facturación mensual';

  @override
  String get billingBilledYearly => 'Facturación anual';

  @override
  String get billingVirtualTryOn => 'Probador virtual';

  @override
  String get billingPrioritySupport => 'Soporte prioritario';

  @override
  String get billingDisclosureProRenewing =>
      'Pro es una suscripción de renovación automática';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus y Pro son suscripciones de renovación automática';

  @override
  String get billingDisclosureAppleBilling =>
      'El pago se cargará a tu Apple ID al confirmar la compra.';

  @override
  String get billingDisclosureGoogleBilling =>
      'El pago se cargará a tu cuenta de Google Play al confirmar la compra.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Tu suscripción se renueva automáticamente por el mismo periodo y precio, a menos que desactives la renovación automática al menos 24 horas antes de que finalice el periodo actual.';

  @override
  String get billingDisclosureAppleManage =>
      'Gestiona o cancela en cualquier momento en Ajustes › tu ID de Apple › Suscripciones.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gestiona o cancela en cualquier momento en Google Play › Pagos y suscripciones.';

  @override
  String get billingReferFriend => 'Invita a un amigo';

  @override
  String get billingHowItWorks => 'Cómo funciona';

  @override
  String get billingHowShareTitle => 'Comparte tu enlace';

  @override
  String get billingHowShareBody => 'Envíalo a un amigo.';

  @override
  String get billingHowSignUpTitle => 'Se registra';

  @override
  String get billingHowSignUpBody => 'Tu amigo se une a través del enlace.';

  @override
  String get billingHowBothTitle => 'Ambos obtenéis Pro';

  @override
  String get billingHowBothBody => 'Cada uno recibe un mes de Pro gratis.';

  @override
  String get billingYourReferrals => 'Tus referidos';

  @override
  String get billingInvited => 'Invitado';

  @override
  String get billingJoined => 'Se ha unido';

  @override
  String get billingMonthsEarned => 'Meses ganados';

  @override
  String get billingInviteFriend => 'Invitar a un amigo';

  @override
  String get billingInviteBody => 'Tú y tu amigo recibiréis un mes de Pro.';

  @override
  String get billingYourCode => 'Tu código';

  @override
  String get billingCopyLink => 'Copiar enlace';

  @override
  String get billingShareInvite => 'Compartir invitación';

  @override
  String get giftUnavailable =>
      'Las invitaciones de regalo no están disponibles en esta versión.';

  @override
  String get giftPageTitle => 'Regalar FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'No hay invitaciones de regalo disponibles en este momento.';

  @override
  String get giftFormTitle => 'Enviar una invitación gratuita';

  @override
  String get giftFormBody =>
      'El destinatario reclamará el regalo con este correo verificado. Nosotros no enviamos el correo por ti.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nombre del destinatario';

  @override
  String get giftFieldRecipientEmail => 'Correo del destinatario';

  @override
  String get giftFieldOccasion => 'Ocasión (opcional)';

  @override
  String get giftNoOccasion => 'Sin ocasión';

  @override
  String get giftOccasionBirthday => 'Cumpleaños';

  @override
  String get giftOccasionAnniversary => 'Aniversario';

  @override
  String get giftOccasionOther => 'Otro';

  @override
  String get giftFieldCardGreeting => 'Mensaje de la tarjeta';

  @override
  String get giftFieldCardGreetingHelper =>
      'Aparecerá en la tarjeta tal cual lo escribas.';

  @override
  String get giftFieldPrivateNote => 'Nota privada (opcional)';

  @override
  String get giftCreateAction => 'Crear regalo gratis';

  @override
  String get giftClaimedTitle => 'Regalo canjeado';

  @override
  String get giftClaimedActive => 'Tu regalo FitCheck Pro está activo.';

  @override
  String get giftClaimedQueued =>
      'Tu regalo FitCheck Pro empezará tras tu acceso actual.';

  @override
  String get giftLinkCopied => 'Enlace de regalo copiado al portapapeles.';

  @override
  String get giftErrorName => 'Introduce un nombre.';

  @override
  String get giftErrorEmail => 'Introduce un email válido.';

  @override
  String get giftErrorGreeting => 'Introduce el mensaje de la tarjeta.';

  @override
  String get giftErrorGreetingLength => 'No uses más de 80 caracteres.';

  @override
  String get giftClaimAction => 'Canjear regalo';

  @override
  String get giftCardPreview => 'Vista previa de la tarjeta';

  @override
  String get giftGiftForYou => 'Un regalo para ti';

  @override
  String get giftGiftWaiting => 'Tienes un regalo esperándote';

  @override
  String get giftOpenBody =>
      'Abre tus regalos para canjearlos con tu email verificado.';

  @override
  String get giftOpenGifts => 'Abrir regalos';

  @override
  String get giftSendInvitation => 'Enviar invitación';

  @override
  String get settingsAiProviderSection => 'Proveedor';

  @override
  String get settingsAiCustom => 'Personalizado';

  @override
  String get settingsAiUrlHelper =>
      'Usa una URL pública accesible por el servidor. Localhost no funciona desde nuestros servidores.';

  @override
  String get settingsAiConnectionSection => 'Conexión';

  @override
  String get settingsAiApiUrl => 'URL de la API';

  @override
  String get settingsAiApiKey => 'Clave de la API';

  @override
  String get settingsAiApiKeySaved =>
      'Guardada. Déjalo en blanco para mantenerla.';

  @override
  String get settingsAiChatModel => 'Modelo de chat';

  @override
  String get settingsAiVisionModel => 'Modelo de visión (opcional)';

  @override
  String get settingsAiImageModel => 'Modelo de imagen (opcional)';

  @override
  String get settingsAiImageModelNote =>
      'La generación de imágenes requiere chat completions compatibles con OpenAI con response_modalities.';

  @override
  String get settingsAiTestConnection => 'Probar conexión';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarGoToToday => 'Ir a hoy';

  @override
  String get calendarConnectTooltip => 'Conectar un calendario';

  @override
  String get calendarAddEvent => 'Añadir evento';

  @override
  String get calendarEmptyTitle => 'Sin planes';

  @override
  String get calendarEmptyBody => 'Añade un evento y planifica qué ponerte.';

  @override
  String get calendarPreviousMonth => 'Mes anterior';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get calendarAllDay => 'Todo el día';

  @override
  String get calendarOutfitLinked => 'Conjunto vinculado';

  @override
  String get calendarEventOptions => 'Opciones de evento';

  @override
  String get calendarDeleteTitle => 'Eliminar este evento?';

  @override
  String get calendarChangeOutfit => 'Cambiar conjunto';

  @override
  String get calendarLinkOutfit => 'Vincular conjunto';

  @override
  String get calendarRemoveOutfit => 'Eliminar conjunto';

  @override
  String get calendarNewEvent => 'Nuevo evento';

  @override
  String get calendarEditEvent => 'Editar evento';

  @override
  String get calendarTitleLabel => 'Título';

  @override
  String get calendarTitleRequired => 'Añade un título';

  @override
  String get calendarEndBeforeStart => 'Finalizar después de la hora de inicio';

  @override
  String get calendarStarts => 'Empieza';

  @override
  String get calendarEnds => 'Termina';

  @override
  String get calendarPlaceOptional => 'Lugar (opcional)';

  @override
  String get calendarNotesOptional => 'Notas (opcional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Crea un conjunto y vincúlalo a este evento.';

  @override
  String get calendarBuildOutfit => 'Crear conjunto';

  @override
  String get calendarConnectionsTitle => 'Calendarios';

  @override
  String get calendarConnectionsBody =>
      'Los eventos que añadas aquí se quedan en FitCheck.';

  @override
  String get calendarDisconnect => 'Desconectar';

  @override
  String get calendarNotAvailable => 'Aún no disponible';

  @override
  String get profileSectionExplore => 'Explorar';

  @override
  String get profileNavTryOn => 'Probador';

  @override
  String get profileNavRewards => 'Recompensas';

  @override
  String get profileSupport => 'Soporte';

  @override
  String get profileHelp => 'Ayuda';

  @override
  String get profileAbout => 'Sobre nosotros';

  @override
  String get profileAboutBody =>
      'Tu armario, conjuntos y planes en un solo lugar.';

  @override
  String get profileSignOutTitle => '¿Cerrar sesión?';

  @override
  String get profileSignOutBody =>
      'Puedes volver a iniciar sesión en cualquier momento.';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileYourProfile => 'Tu perfil';

  @override
  String get profileBodyProfiles => 'Perfiles corporales';

  @override
  String get profileBodyEmptyTitle => 'Aún no hay perfiles';

  @override
  String get profileBodyEmptyBody =>
      'Añade tu altura y complexión para un mejor ajuste.';

  @override
  String get profileBodyAdd => 'Añadir perfil';

  @override
  String get profileBodyDefaultNote =>
      'Tu perfil predeterminado se usa para el ajuste y el probador.';

  @override
  String get profileBodyDefaultBadge => 'Predeterminado';

  @override
  String get profileBodyMakeDefault => 'Establecer como predeterminado';

  @override
  String get profileBodyDeleteBody => 'No podrás deshacer esta acción.';

  @override
  String get profileBodyRequired => 'Obligatorio';

  @override
  String get profileBodyCheckNumber => 'Revisa este número';

  @override
  String get profileBodyNew => 'Nuevo perfil corporal';

  @override
  String get profileBodyNameHint => 'Por ejemplo, Yo';

  @override
  String get profileBodyHeight => 'Altura';

  @override
  String get profileBodyWeight => 'Peso';

  @override
  String get profileBodyBuild => 'Complexión';

  @override
  String get profileBodySkinTone => 'Tono de piel';

  @override
  String get profileBirthDateNeededBody =>
      'Añade una fecha de nacimiento para completar la hora de nacimiento.';

  @override
  String get profileBirthDateNeededTitle => 'Fecha de nacimiento necesaria';

  @override
  String get profilePartlySavedBody =>
      'Hemos guardado tu nombre y foto. Los datos de nacimiento no se guardaron; inténtalo más tarde.';

  @override
  String get profilePartlySavedTitle => 'Guardado parcialmente';

  @override
  String get profileSavedBody => 'Tu perfil se ha guardado.';

  @override
  String get profileChangePhoto => 'Cambiar foto de perfil';

  @override
  String get profilePhotoLabel => 'Foto de perfil';

  @override
  String get profilePhotoHint => 'Toca para elegir una nueva';

  @override
  String get profileBirthDateLabel => 'Fecha de nacimiento (opcional)';

  @override
  String get profileBirthTimeLabel => 'Hora de nacimiento (opcional)';

  @override
  String get profileBirthTimeHelper =>
      'Mejora la precisión de las sugerencias védicas';

  @override
  String get profileBirthPlaceLabel => 'Lugar de nacimiento (opcional)';

  @override
  String get profileBirthPlaceHint => 'Por ejemplo, Madrid, España';

  @override
  String get profileHelpContactTitle => 'Pregúntanos lo que quieras';

  @override
  String get profileHelpContactBody =>
      'Envíanos un mensaje y te responderemos por correo, normalmente en un día.';

  @override
  String get profileHelpContactAction => 'Contactar con soporte';

  @override
  String get profileHelpFaqTitle => 'Preguntas frecuentes';

  @override
  String get profileFaqAddPiecesTitle => '¿Cómo añado prendas a mi armario?';

  @override
  String get profileFaqAddPiecesBody =>
      'Toca Añadir prenda en la pestaña Armario. Haz una foto o elige una de tu galería; nosotros identificaremos y etiquetaremos cada prenda por ti.';

  @override
  String get profileFaqMatchingTitle => '¿Cómo funcionan las combinaciones?';

  @override
  String get profileFaqMatchingBody =>
      'Abre Para ti y elige prendas que ya tengas. Te sugeriremos qué combina con ellas y crearemos conjuntos completos con tu armario.';

  @override
  String get profileFaqTryOnTitle => '¿Puedo usar mis fotos para el probador?';

  @override
  String get profileFaqTryOnBody =>
      'Sí. Añade una foto tuya de cuerpo entero y elige prendas para probártelas virtualmente.';

  @override
  String get profileFaqRewardsTitle => '¿Cómo consigo recompensas?';

  @override
  String get profileFaqRewardsBody =>
      'Planifica y registra tus conjuntos a menudo. Ganarás rachas y logros a medida que avances.';

  @override
  String get profileFaqPrivacyTitle => '¿Es privado mi armario?';

  @override
  String get profileFaqPrivacyBody =>
      'Sí. Tu armario y tus conjuntos son privados, a menos que compartas el enlace a un conjunto específico.';

  @override
  String get profileHelpMoreTitle => 'Más ayuda';

  @override
  String get profileHelpGuides => 'Guías';

  @override
  String get profileHelpGuidesBody => 'Cómo funciona cada función';

  @override
  String get feedbackCategoryBug => 'Algo no funciona';

  @override
  String get feedbackCategoryIdea => 'Una idea';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'Necesito ayuda';

  @override
  String get feedbackHintBug =>
      'Qué ha pasado y qué esperabas. Los pasos nos ayudan a solucionarlo.';

  @override
  String get feedbackHintIdea => '¿Qué te gustaría y por qué?';

  @override
  String get feedbackHintGeneral => 'Dinos qué piensas o haznos una pregunta.';

  @override
  String get feedbackAttachmentLimitBody => 'Puedes añadir hasta 5 imágenes.';

  @override
  String get feedbackAttachmentLimitTitle => 'Límite alcanzado';

  @override
  String get feedbackImageTooLargeBody => 'Elige una imagen de menos de 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imagen demasiado grande';

  @override
  String get feedbackTitle => 'Enviar comentarios';

  @override
  String get feedbackAboutLabel => '¿Sobre qué trata?';

  @override
  String get feedbackSubjectLabel => 'Asunto';

  @override
  String get feedbackSubjectRequired => 'Añade un asunto';

  @override
  String get feedbackSubjectTooShort =>
      'El asunto debe tener al menos 3 caracteres';

  @override
  String get feedbackDetailsLabel => 'Detalles';

  @override
  String get feedbackDetailsRequired => 'Añade algunos detalles';

  @override
  String get feedbackDetailsTooShort =>
      'La descripción debe tener al menos 10 caracteres';

  @override
  String get feedbackAddScreenshot => 'Añadir captura';

  @override
  String get feedbackAttachmentHint => 'Hasta 5, 5 MB cada una';

  @override
  String get feedbackSend => 'Enviar';

  @override
  String get feedbackEmptyTitle => 'Aún no has enviado nada';

  @override
  String get feedbackEmptyBody => 'Lo que envíes aparecerá aquí con su estado.';

  @override
  String get feedbackHistoryTitle => 'Lo que has enviado';

  @override
  String get feedbackStatusOpen => 'Abierto';

  @override
  String get feedbackStatusInProgress => 'En curso';

  @override
  String get feedbackStatusResolved => 'Resuelto';

  @override
  String get feedbackStatusClosed => 'Cerrado';

  @override
  String get legalIntro =>
      'Cómo protegemos tus datos y los términos de uso de FitCheck AI.';

  @override
  String get legalPolicies => 'Políticas';

  @override
  String get legalPrivacySubtitle => 'Qué recopilamos y por qué';

  @override
  String get legalTermsTitle => 'Términos de servicio';

  @override
  String get legalTermsSubtitle => 'Las normas de uso de la aplicación';

  @override
  String get legalLicences => 'Licencias de código abierto';

  @override
  String get legalSupportSubtitle => 'Ayuda, contacto y privacidad';

  @override
  String get legalReportAbuse => 'Informar de un problema o abuso';

  @override
  String get permissionCameraTitle => 'Acceso a la cámara';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI usa tu cámara para capturar fotos de tu ropa y conjuntos para el probador virtual y organizar tu armario.';

  @override
  String get permissionPhotoTitle => 'Acceso a fotos';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI necesita acceso a tus fotos para que puedas seleccionar imágenes de ropa y conjuntos para las funciones de IA y tu armario.';

  @override
  String get permissionNotNow => 'Ahora no';

  @override
  String get permissionOpenSettings => 'Abrir ajustes';

  @override
  String authSignedInAs(String name) {
    return 'Sesión iniciada como $name';
  }

  @override
  String get authSignedIn => 'Sesión iniciada';

  @override
  String get authWelcomeBackTitle => 'Bienvenido de nuevo';

  @override
  String get authSignInFailed => 'Error al iniciar sesión';

  @override
  String get authWelcomeTitle => 'Bienvenido';

  @override
  String get authSignUpFailed => 'Error al registrarse';

  @override
  String get authGoogleSignInFailed => 'Error al iniciar sesión con Google';

  @override
  String get authAppleSignInFailed => 'Error al iniciar sesión con Apple';

  @override
  String get authConfirmEmailTitle => 'Confirma tu correo';

  @override
  String get authConfirmEmailBody =>
      'Revisa tu bandeja de entrada para confirmar tu correo y luego inicia sesión.';

  @override
  String get authClosetReady => 'Tu armario está listo.';

  @override
  String get authSignedOutTitle => 'Sesión cerrada';

  @override
  String get authSignedOutBody => 'Has cerrado sesión.';

  @override
  String get authSignOutFailed => 'Error al cerrar sesión';

  @override
  String get authEmailSentTitle => 'Correo enviado';

  @override
  String get authResetLinkSent =>
      'Revisa tu correo para obtener el enlace de restablecimiento.';

  @override
  String get authPasswordUpdatedTitle => 'Contraseña actualizada';

  @override
  String get authPasswordUpdated => 'Tu contraseña se ha actualizado.';

  @override
  String get authPasswordNotUpdated => 'Contraseña no actualizada';

  @override
  String get authCouldNotSendEmail => 'No se pudo enviar el correo';

  @override
  String get authEmailNotSent => 'Correo no enviado';

  @override
  String get authResendSentBody =>
      'Hemos enviado un nuevo correo de confirmación.';

  @override
  String get outfitPreviewWithAi => 'Previsualizar con IA';

  @override
  String get outfitNewPreview => 'Nueva previsualización';

  @override
  String get outfitBuilderClosetHeading => 'Tu armario';

  @override
  String get outfitBuilderSearchHint => 'Buscar prendas';

  @override
  String get outfitClearSearch => 'Limpiar búsqueda';

  @override
  String get outfitBuilderAddPiecesTitle => 'Añade prendas primero';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Los conjuntos se forman con las prendas de tu armario.';

  @override
  String get outfitBuilderNoMatches => 'No hay prendas que coincidan.';

  @override
  String get outfitNameLabel => 'Nombre del conjunto';

  @override
  String get outfitNameHint => 'Por ejemplo, Lino de fin de semana';

  @override
  String get outfitPreviewSemantic => 'Previsualización del conjunto con IA';

  @override
  String get outfitChoosePieces => 'Elegir prendas';

  @override
  String get outfitTapPiecesHint => 'Toca las prendas abajo para añadirlas.';

  @override
  String get outfitShareTooltip => 'Compartir';

  @override
  String get outfitSaveFavourite => 'Guardar en favoritos';

  @override
  String get outfitPiecesHeading => 'Prendas';

  @override
  String get outfitWearHistoryEmpty =>
      'Llévalo una vez y las fechas aparecerán aquí.';

  @override
  String get outfitWearHistoryTitle => 'Historial de uso';

  @override
  String get outfitWearHistoryError => 'No se pudieron cargar las fechas.';

  @override
  String get outfitWornOn => 'Usado el';

  @override
  String get outfitEditTitle => 'Editar conjunto';

  @override
  String get outfitSavedPhotosFailed => 'Detalles guardados, fotos no';

  @override
  String get outfitNoPhotosBody =>
      'Aún no hay fotos. El conjunto muestra sus prendas en su lugar.';

  @override
  String get outfitOccasionLabel => 'Ocasión';

  @override
  String get outfitOccasionNone => 'Ninguna';

  @override
  String get outfitTagsHint => 'Separar con comas';

  @override
  String get outfitDraftBody => 'Oculto de tu lista principal';

  @override
  String get outfitPublic => 'Público';

  @override
  String get outfitPublicBody => 'Cualquiera con el enlace puede verlo';

  @override
  String get outfitDeleteFromDetail =>
      'Elimina este conjunto desde su página de detalles.';

  @override
  String get outfitNewCollection => 'Nueva colección';

  @override
  String get outfitNoCollectionsTitle => 'Sin colecciones aún';

  @override
  String get outfitNoCollectionsBody =>
      'Agrupa conjuntos por viaje, temporada o estilo.';

  @override
  String get outfitCreateCollection => 'Crear colección';

  @override
  String get outfitAddOutfits => 'Añadir conjuntos';

  @override
  String get outfitRename => 'Renombrar';

  @override
  String get outfitCollectionDeleteBody => 'Los conjuntos se conservarán.';

  @override
  String get outfitCollectionsNotLoaded => 'Conjuntos no cargados';

  @override
  String get outfitRenameCollection => 'Renombrar colección';

  @override
  String get outfitDescriptionOptional => 'Descripción (opcional)';

  @override
  String get outfitAllInCollection =>
      'Todos los conjuntos ya están en esta colección.';

  @override
  String get photoshootSubtitleUpload => 'Retratos de estudio con tus fotos';

  @override
  String get photoshootSubtitleConfigure =>
      'Elige un estilo, un formato y una cantidad';

  @override
  String get photoshootSubtitleGenerating => 'Esto tomará uno o dos minutos';

  @override
  String get photoshootAddPhotosSemantic => 'Añadir fotos de tu galería';

  @override
  String get photoshootUploadTitle => 'Añade de 1 a 4 fotos tuyas';

  @override
  String get photoshootUploadBody => 'Pulsa para elegir de tu galería';

  @override
  String get photoshootAddToContinue => 'Añade una foto para continuar';

  @override
  String get photoshootAddAnotherPhoto => 'Añadir otra foto';

  @override
  String get photoshootTipsTitle => 'Para obtener los mejores resultados';

  @override
  String get photoshootTipsBody =>
      'Usa fotos claras y bien iluminadas de tu rostro desde varios ángulos. Evita gafas de sol y sombreros.';

  @override
  String get photoshootStarting => 'Iniciando';

  @override
  String get photoshootCancelling => 'Cancelando';

  @override
  String get photoshootFailed => 'Error';

  @override
  String get recommendTabMatches => 'Combinaciones';

  @override
  String get recommendTabComplete => 'Completar';

  @override
  String get recommendTabWeather => 'Clima';

  @override
  String get recommendTabColours => 'Colores';

  @override
  String get recommendTabShop => 'Comprar';

  @override
  String get recommendNoMatchesTitle => 'Sin combinaciones aún';

  @override
  String get recommendNoMatchesBody =>
      'Elige una prenda y buscaremos combinaciones.';

  @override
  String get recommendPickPiece => 'Elige una prenda';

  @override
  String get recommendNothingMatchesTitle => 'Sin combinaciones aún';

  @override
  String get recommendNothingMatchesBody =>
      'Prueba otras prendas o añade más a tu armario.';

  @override
  String get recommendChangePieces => 'Cambiar prendas';

  @override
  String get recommendDefaultReason => 'Combina con las prendas elegidas.';

  @override
  String get recommendCompleteTitle => 'Completa el look';

  @override
  String get recommendCompleteBody =>
      'Elige una prenda y completaremos el resto.';

  @override
  String get recommendWorking => 'Procesando';

  @override
  String get recommendGenerate => 'Generar';

  @override
  String get recommendChooseStyleBody => 'Elige un estilo y genera.';

  @override
  String get recommendNoLooksTitle => 'Sin looks disponibles';

  @override
  String get recommendNoLooksBody => 'Prueba otro estilo u otras prendas.';

  @override
  String get recommendDefaultLook => 'Un look para tus prendas';

  @override
  String get recommendNoPiecesBody =>
      'No se han encontrado prendas para este look.';

  @override
  String get recommendCityLabel => 'Ciudad';

  @override
  String get recommendCheck => 'Consultar';

  @override
  String get recommendWeatherTitle => '¿Qué tiempo hace?';

  @override
  String get recommendWeatherBody =>
      'Introduce tu ciudad para ver sugerencias de hoy.';

  @override
  String get recommendWearToday => 'Para hoy';

  @override
  String get recommendWeatherNoPieces =>
      'Aún no hay prendas en tu armario para este tiempo.';

  @override
  String get recommendBudgetLabel => 'Presupuesto hasta';

  @override
  String get recommendLooking => 'Buscando';

  @override
  String get recommendFindWhatToBuy => 'Qué comprar';

  @override
  String get recommendFillGapsTitle => 'Completa tu armario';

  @override
  String get recommendFillGapsBody =>
      'Define un presupuesto y te sugeriremos qué le falta a tu armario.';

  @override
  String get recommendNoGapsTitle => 'Sin faltas';

  @override
  String get recommendNoGapsBody =>
      'Prueba con un presupuesto mayor u otra categoría.';

  @override
  String get recommendMoodEveryday => 'Diario';

  @override
  String get recommendMoodBigMeeting => 'Reunión importante';

  @override
  String get recommendDayLabel => 'Día';

  @override
  String get recommendReadingStars => 'Consultando los astros';

  @override
  String get recommendGetMyColours => 'Ver mis colores';

  @override
  String get recommendLuckyColoursTitle => 'Tus colores de la suerte';

  @override
  String get recommendLuckyColoursBody =>
      'Elige un día y te sugeriremos colores y prendas.';

  @override
  String get recommendLuckyColoursSection => 'Colores de la suerte';

  @override
  String get recommendAvoidColoursSection => 'Colores a evitar';

  @override
  String get recommendBirthDateTitle => 'Añade tu fecha de nacimiento';

  @override
  String get recommendBirthDateBody =>
      'Necesitamos tu fecha de nacimiento para analizar tus colores.';

  @override
  String get recommendEditProfile => 'Editar perfil';

  @override
  String get recommendNothingThisDay => 'Nada para este día.';

  @override
  String get recommendUnnamedColour => 'Color sin nombre';

  @override
  String get recommendFromCloset => 'De tu armario';

  @override
  String get recommendNoPiecesInColours =>
      'Aún no hay prendas en estos colores.';

  @override
  String get recommendOutfitIdeas => 'Ideas de looks';

  @override
  String get recommendNoOutfitsInColours =>
      'Aún no hay looks completos en estos colores.';

  @override
  String get recommendDefaultOutfitIdea => 'Una idea de look';

  @override
  String get recommendPickUpToThree => 'Elige hasta tres prendas';

  @override
  String get recommendEmptyClosetBody =>
      'Añade algunas prendas primero para ver combinaciones.';

  @override
  String get dashboardDressForDay => 'Vístete para el día de hoy.';

  @override
  String get dashboardOutfitOfDay => 'Look del día';

  @override
  String get dashboardFreshLook => 'Un look renovado';

  @override
  String get subscriptionManageInStoreTitle => 'Gestionar en la tienda';

  @override
  String get subscriptionManageInStoreBody =>
      'Este plan se factura a través de la tienda. Gestiónalo en los ajustes de tu cuenta.';

  @override
  String get subscriptionCancelledTitle => 'Suscripción cancelada';

  @override
  String get subscriptionCancelledBody =>
      'Tu plan seguirá activo hasta el final del periodo de facturación.';

  @override
  String get subscriptionCancelFailedTitle => 'No se pudo cancelar';

  @override
  String get subscriptionCouldNotOpenTitle => 'No se pudo abrir';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'No se pudo abrir la gestión de facturación.';

  @override
  String get subscriptionOpenLinkFailedBody => 'No se pudo abrir el enlace.';

  @override
  String get subscriptionReferralLoadFailedTitle => 'Error al cargar el enlace';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'No se pudo cargar tu enlace de invitación. Inténtalo de nuevo.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiado';

  @override
  String get subscriptionReferralCopiedBody => 'Enlace de invitación copiado.';

  @override
  String get subscriptionReferralShareSubject => 'Prueba FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Únete a FitCheck AI y ambos recibiremos un mes de Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Enlace copiado';

  @override
  String get subscriptionShareUnavailableBody =>
      'No se puede compartir, así que hemos copiado el enlace.';

  @override
  String get subscriptionShareFailedTitle => 'Error al compartir';

  @override
  String get subscriptionShareFailedBody =>
      'Copia el enlace desde la página de invitaciones.';

  @override
  String get subscriptionStoreReadyTitle => 'Tienda lista';

  @override
  String get subscriptionStoreReadyBody =>
      'Precios disponibles. Ya puedes mejorar tu plan.';

  @override
  String get purchaseFailedTitle => 'Error en la compra';

  @override
  String get purchaseUnavailableTitle => 'Compra no disponible';

  @override
  String get purchaseIapUnavailableBody =>
      'Las compras integradas no están disponibles en este dispositivo.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Este plan aún no está disponible para su compra.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Este plan aún no está en la tienda. Vuelve pronto.';

  @override
  String get purchaseStartFailedBody =>
      'No se pudo iniciar la compra. Inténtalo de nuevo.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'El proceso de pago no devolvió un enlace de pago.';

  @override
  String get purchasePendingTitle => 'Compra pendiente';

  @override
  String get purchasePendingBody =>
      'Tu compra espera aprobación. Tendrás acceso en cuanto se apruebe.';

  @override
  String get purchaseFailedBody => 'La compra ha fallado. Inténtalo de nuevo.';

  @override
  String get purchaseRestoredTitle => 'Restaurada';

  @override
  String get purchaseRestoredBody => 'Tus compras han sido restauradas.';

  @override
  String get purchaseActiveTitle => 'Suscripción activa';

  @override
  String get purchaseActiveBody =>
      'Tu suscripción está activa. Te damos la bienvenida.';

  @override
  String get purchaseSignInRequiredTitle => 'Inicia sesión';

  @override
  String get purchaseSignInRequiredBody =>
      'Inicia sesión para finalizar tu compra.';

  @override
  String get purchaseErrorTitle => 'Error de compra';

  @override
  String get purchaseInvalidTransactionBody =>
      'La compra no incluyó un ID de transacción verificable.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificación pendiente';

  @override
  String get purchaseVerificationPendingBody =>
      'No hemos podido verificar tu compra con la tienda en este momento. Se completará automáticamente y no se te cobrará dos veces.';

  @override
  String get purchaseNotAppliedTitle => 'Compra no aplicada';

  @override
  String get purchaseNotAppliedBody =>
      'No se ha podido aplicar la compra a tu cuenta. Contacta con soporte y no vuelvas a comprarlo.';

  @override
  String get purchaseRestoreFailedTitle => 'Error al restaurar';

  @override
  String get purchaseRestoreFailedBody =>
      'No se han podido restaurar las compras. Inténtalo de nuevo.';

  @override
  String get purchaseRecoveredActiveBody => 'Tu suscripción está activa.';

  @override
  String get purchaseCompleteTitle => 'Compra completada';

  @override
  String get giftCreateFailedTitle => 'No se pudo crear el regalo';

  @override
  String get giftClaimFailedTitle => 'No se pudo canjear el regalo';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regalos para ti',
      one: 'Un regalo para ti',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mes',
      '12': '1 año',
      'other': '$months meses',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'quedan $remaining',
      one: 'queda 1',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration de FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender te ha enviado $duration de FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Un regalo de FitCheck Pro para $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'De $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Para $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'De $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'el destinatario';

  @override
  String get giftPreviewPlaceholderSender => 'ti';

  @override
  String get settingsSavedTitle => 'Guardado';

  @override
  String get settingsNotSavedTitle => 'No guardado';

  @override
  String get settingsAiChooseProviderBody => 'Elige un proveedor.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Un proveedor personalizado requiere una URL de API.';

  @override
  String get settingsAiKeyRequiredBody => 'Introduce una clave de API.';

  @override
  String get settingsAiSavedBody => 'Ajustes de IA guardados.';

  @override
  String get settingsAiMissingDetailsTitle => 'Faltan datos';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Introduce una URL de API y un modelo de chat para probar.';

  @override
  String get settingsAiKeyNeededTitle => 'Clave de API necesaria';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Introduce tu clave API para probar. Tu clave guardada es privada.';

  @override
  String get settingsAiKeyToTestBody => 'Introduce tu clave API para probar.';

  @override
  String get settingsAiConnectedTitle => 'Conectado';

  @override
  String get settingsAiConnectedBody => 'La conexión funciona.';

  @override
  String get settingsAiTestFailedTitle => 'Error en la prueba';

  @override
  String get settingsPreferencesSavedBody => 'Preferencias guardadas.';

  @override
  String get settingsPasswordNotChangedTitle => 'Contraseña no cambiada';

  @override
  String get settingsOAuthPasswordBody =>
      'Esta cuenta usa Google o Apple. Usa \"He olvidado mi contraseña\" para crear una primero.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'La contraseña actual es incorrecta.';

  @override
  String get settingsExportReadyTitle => 'Exportación lista';

  @override
  String get settingsExportReadyBody =>
      'Tu exportación de datos está lista para descargar.';

  @override
  String get settingsLinkCopiedTitle => 'Enlace copiado';

  @override
  String get settingsExportClipboardBody =>
      'No pudimos abrir el navegador, así que copiamos el enlace. Pégalo pronto: caduca.';

  @override
  String get settingsExportFailedTitle => 'Error al exportar';

  @override
  String get settingsAccountNotDeletedTitle => 'Cuenta no eliminada';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Puedes añadir hasta $max fotos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Límite de fotos';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Añade al menos una foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Sin fotos';

  @override
  String get photoshootDescribeLookBody => 'Describe el look que quieres.';

  @override
  String get photoshootPromptNeededTitle => 'Descripción necesaria';

  @override
  String get photoshootConsentFeatureLabel => 'Sesión de fotos IA';

  @override
  String get photoshootStatusPreparing => 'Preparando tus fotos';

  @override
  String get photoshootStatusGenerating => 'Generando';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lote $current de $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done de $total listas';
  }

  @override
  String get photoshootGenerationFailedBody => 'Error al generar.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready listas, $failed fallidas.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Parcialmente completado';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos están listas.',
      one: '1 foto está lista.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Se ha perdido la conexión. Inténtalo de nuevo.';

  @override
  String get photoshootCouldNotCancelTitle => 'No se pudo cancelar';

  @override
  String get photoshootRetryFailedTitle => 'Error al reintentar';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'La foto $number está lista.';
  }

  @override
  String get photoshootReplacedTitle => 'Sustituida';

  @override
  String get photoshootSavedToGalleryBody => 'Guardada en tu galería.';

  @override
  String get photoshootSavedTitle => 'Guardada';

  @override
  String get photoshootNotSavedTitle => 'No guardada';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Las $count fotos están en tu galería.',
      one: '1 foto guardada en tu galería.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved de $total guardadas.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Algunas fotos no se guardaron';

  @override
  String get tryonConsentFeatureLabel => 'Probador virtual';

  @override
  String get tryonAvatarUpdatedBody => 'Tu foto se ha actualizado.';

  @override
  String get tryonSavedTitle => 'Guardado';

  @override
  String get tryonUploadFailedTitle => 'Error al subir';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Elige primero una foto de la prenda.';

  @override
  String get tryonNoGarmentTitle => 'Sin prenda';

  @override
  String get tryonWaitForUploadBody =>
      'Espera a que termine de subirse tu foto.';

  @override
  String get tryonStillUploadingTitle => 'Subiendo...';

  @override
  String get tryonAddYourPhotoFirstBody => 'Añade primero una foto tuya.';

  @override
  String get tryonReadyBody => 'Tu prueba está lista.';

  @override
  String get tryonFailedTitle => 'Error en la prueba';

  @override
  String get tryonSavedToGalleryBody => 'Guardado en tu galería.';

  @override
  String get tryonNotSavedTitle => 'No guardado';

  @override
  String get calendarEventAddedBody => 'Evento añadido';

  @override
  String get calendarEventPlannedTitle => 'Planificado';

  @override
  String get calendarEventSavedBody => 'Evento guardado';

  @override
  String get calendarSavedTitle => 'Guardado';

  @override
  String get calendarEventNotSavedTitle => 'Evento no guardado';

  @override
  String get calendarEventRemovedBody => 'Evento eliminado';

  @override
  String get calendarEventDeletedTitle => 'Eliminado';

  @override
  String get calendarEventNotDeletedTitle => 'Evento no eliminado';

  @override
  String get calendarOutfitNotLinkedTitle => 'Conjunto no vinculado';

  @override
  String get calendarLinkedTitle => 'Vinculado';

  @override
  String get calendarOutfitNotRemovedTitle => 'Conjunto no quitado';

  @override
  String get calendarOutfitRemovedBody => 'Conjunto quitado';

  @override
  String get calendarDisconnectedBody => 'Calendario desconectado';

  @override
  String get calendarDisconnectedTitle => 'Desconectado';

  @override
  String get calendarNotDisconnectedTitle => 'Calendario no desconectado';

  @override
  String get calendarTodayLabel => 'hoy';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
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
    return '$title, $time, conjunto vinculado';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" se eliminará.';
  }

  @override
  String get calendarThisAppLabel => 'Esta app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'La sincronización con $provider aún no está disponible. Puedes añadir eventos aquí.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dom';

  @override
  String get calendarWeekdayMonShort => 'Lun';

  @override
  String get calendarWeekdayTueShort => 'Mar';

  @override
  String get calendarWeekdayWedShort => 'Mié';

  @override
  String get calendarWeekdayThuShort => 'Jue';

  @override
  String get calendarWeekdayFriShort => 'Vie';

  @override
  String get calendarWeekdaySatShort => 'Sáb';

  @override
  String get calendarWeekdayMonday => 'Lunes';

  @override
  String get calendarWeekdayTuesday => 'Martes';

  @override
  String get calendarWeekdayWednesday => 'Miércoles';

  @override
  String get calendarWeekdayThursday => 'Jueves';

  @override
  String get calendarWeekdayFriday => 'Viernes';

  @override
  String get calendarWeekdaySaturday => 'Sábado';

  @override
  String get calendarWeekdaySunday => 'Domingo';

  @override
  String get outfitSavedToFavouritesBody => 'Guardado en favoritos';

  @override
  String get outfitRemovedFromFavouritesBody => 'Eliminado de favoritos';

  @override
  String get outfitNotSavedTitle => 'No guardado';

  @override
  String get outfitLoggedAsWornBody => 'Registrado como usado hoy.';

  @override
  String get outfitNicePickTitle => 'Buena elección';

  @override
  String get outfitRemovedBody => 'Conjunto eliminado.';

  @override
  String get outfitDeletedTitle => 'Eliminado';

  @override
  String get outfitNotDeletedTitle => 'No eliminado';

  @override
  String get outfitDuplicatedBody => 'Copia añadida a tus conjuntos.';

  @override
  String get outfitDuplicatedTitle => 'Duplicado';

  @override
  String get outfitNotDuplicatedTitle => 'No duplicado';

  @override
  String get outfitNotSharedTitle => 'No compartido';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" está lista.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Colección no creada';

  @override
  String get outfitCollectionUpdatedBody => 'Colección actualizada.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Colección no actualizada';

  @override
  String get outfitCollectionDeletedBody => 'Colección eliminada.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Colección no eliminada';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conjuntos añadidos.',
      one: '1 conjunto añadido.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Conjuntos no añadidos';

  @override
  String get outfitPreviewNotCreatedTitle => 'Vista previa no creada';

  @override
  String get outfitGiveNameBody => 'Ponle un nombre al conjunto.';

  @override
  String get outfitNameMissingTitle => 'Nombre';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Elige al menos una prenda.';

  @override
  String outfitCreatedBody(String name) {
    return '$name está en tus conjuntos.';
  }

  @override
  String get outfitSavedTitle => 'Guardado';

  @override
  String get wardrobeAddedToFavouritesBody => 'Añadido a favoritos';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Eliminado de favoritos';

  @override
  String get wardrobeNotSavedTitle => 'No guardado';

  @override
  String get wardrobeLoggedAsWornBody => 'Registrado como usado hoy.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Eliminado de tu armario.';

  @override
  String get wardrobeDeletedTitle => 'Eliminado';

  @override
  String get wardrobeNotDeletedTitle => 'No eliminado';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prendas eliminadas de tu armario.',
      one: '1 prenda eliminada de tu armario.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extracción de armario por IA';

  @override
  String get itemAddScanJobLabel => 'Escanear';

  @override
  String get itemAddFoundEarlierBody => 'Encontrado en un escaneo anterior';

  @override
  String get itemAddLookingAtPhoto => 'Analizando tu foto';

  @override
  String get itemAddExtractionFailedBody => 'Error en la extracción';

  @override
  String get itemAddJobFailedBody => 'Error en la tarea';

  @override
  String get itemAddConnectionLostBody =>
      'Se perdió la conexión. Inténtalo de nuevo.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Conexión perdida durante el procesamiento.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Prenda $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Prenda';

  @override
  String get itemAddNotCancelledTitle => 'No cancelado';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prendas están en tu armario.',
      one: '1 prenda está en tu armario.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved de $total prendas guardadas. Pulsa guardar para reintentar el resto.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Algunas prendas no se guardaron';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Elige al menos una foto.';

  @override
  String get batchPhotoUnreadableBody => 'No se pudo leer esta foto.';

  @override
  String get batchNoPhotosReadableBody =>
      'No se pudo leer ninguna foto. Prueba con otras.';

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
      'Se perdió la conexión durante el proceso. Inténtalo de nuevo.';

  @override
  String get batchNotCancelledTitle => 'No cancelado';

  @override
  String get batchPostLinkUnsupportedBody =>
      'No se admiten enlaces a publicaciones. Introduce un enlace de perfil.';

  @override
  String get batchLinkSpacesBody => 'Los enlaces no pueden contener espacios.';

  @override
  String get batchEnterProfileLinkBody =>
      'Introduce un enlace de perfil de Instagram o Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Introduce un enlace de perfil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'La página de inicio de sesión no se abrió. Inténtalo de nuevo.';

  @override
  String get batchSignInBrowserBody =>
      'Inicia sesión en tu navegador y vuelve a FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Conecta tu cuenta';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Introduce el código de tu app de autenticación.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram requiere una comprobación de seguridad. Inicia sesión primero en tu navegador.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Vuelve a introducir tu usuario y contraseña.';

  @override
  String get batchSignInFailedBody =>
      'Error al iniciar sesión. Revisa tu usuario y contraseña.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Inicia sesión para seguir importando.';

  @override
  String get batchAccountNotConnectedBody => 'Tu cuenta no se ha conectado.';

  @override
  String get batchAccountConnectedTitle => 'Cuenta conectada';

  @override
  String get batchNotConnectedTitle => 'No conectada';

  @override
  String get batchImportConnectionLostBody =>
      'Se ha perdido la conexión con la importación. Actualiza para comprobarlo.';

  @override
  String batchPickUpToBody(int max) {
    return 'Elige hasta $max fotos. Nosotros buscamos las prendas.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count de $total fotos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparando foto $done de $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buscar prendas en $count fotos',
      one: 'Buscar prendas en 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Tu cuenta de $platform usa verificación en dos pasos. Introduce el código de 6 dígitos de tu app de autenticación.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Este perfil de $platform es privado o requiere iniciar sesión para ver sus fotos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Conectar con $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos encontradas hasta ahora',
      one: '1 foto encontrada hasta ahora',
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
    return '$processed de $total procesadas · $added añadidas · $waiting en espera · $skipped omitidas';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Escaneando foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'La siguiente es la foto $number';
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
      other: '$count prendas encontradas',
      one: '1 prenda encontrada',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se han añadido $count fotos a tu armario.',
      one: 'Se ha añadido 1 foto a tu armario.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos de estudio más en camino. Puedes guardar lo que esté listo o salir; te avisaremos.',
      one:
          '1 foto de estudio más en camino. Puedes guardar lo que esté listo o salir; te avisaremos.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Aún no guardado: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces prendas',
      one: '1 prenda',
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
    return '$chosen seleccionadas. Toca una prenda para omitirla.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardando $count prendas',
      one: 'Guardando 1 prenda',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count prendas',
      one: 'Guardar 1 prenda',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Tu perfil corporal se ha guardado.';

  @override
  String get bodyProfileSavedTitle => 'Guardado';

  @override
  String get bodyProfileNotSavedTitle => 'No guardado';

  @override
  String get bodyProfileSetDefaultBody =>
      'Establecer como perfil predeterminado.';

  @override
  String get bodyProfileDeletedBody => 'Perfil corporal eliminado.';

  @override
  String get bodyProfileDeletedTitle => 'Eliminado';

  @override
  String get bodyProfileNotDeletedTitle => 'No eliminado';

  @override
  String get feedbackNotSentTitle => 'No enviado';

  @override
  String get feedbackSentBody =>
      'Gracias. Leemos todos los mensajes y respondemos si necesitamos más información.';

  @override
  String get feedbackSentTitle => 'Comentarios enviados';

  @override
  String get recommendUnnamedPiece => 'Prenda sin nombre';

  @override
  String get recommendEnterCityBody =>
      'Introduce tu ciudad para ver recomendaciones según el clima.';

  @override
  String get recommendWhichCityTitle => '¿Qué ciudad?';

  @override
  String get aiConsentSheetTitle => 'Compartir fotos con un servicio de IA';

  @override
  String get aiConsentSheetBody =>
      'Para crear tus imágenes de prueba y sesión de fotos, FitCheck AI envía las fotos que proporcionas (incluidas imágenes de tu cara y cuerpo) a un proveedor de IA externo de confianza (como OpenAI o Google Gemini) para su procesamiento. Generan tus imágenes y no las utilizan para entrenar sus modelos según nuestros términos. Las fotos se transmiten de forma segura y nunca se comparten con fines publicitarios.';

  @override
  String get aiConsentSheetPermission =>
      'Al continuar, das permiso explícito para compartir tus fotos con estos proveedores de IA para la generación de imágenes.';

  @override
  String get skeletonsLoadMoreFailed => 'No se pudo cargar más.';

  @override
  String get jobsPiecesReadyTitle => 'Tus prendas están listas';

  @override
  String get jobsScanStoppedTitle => 'Escaneo detenido';

  @override
  String get jobsNothingSavedBody =>
      'No se ha guardado nada. Inténtalo de nuevo.';

  @override
  String get jobsPhotoUploadFailedBody => 'Error al subir la foto.';

  @override
  String get authGoogleSignInStartFailed =>
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get referralAppliedTitle => '¡Referido aplicado!';

  @override
  String get billingStoreUnavailableBody =>
      'Las compras no están disponibles en este dispositivo.';

  @override
  String get billingPurchaseProcessingBody =>
      'La compra aún se está procesando. Vuelve a abrir la app en un minuto para ver tu plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'La subida del avatar no devolvió una URL de imagen.';

  @override
  String get rewardsDayStreakLabel => 'días de racha';

  @override
  String rewardsBestStreak(int days) {
    return 'Mejor racha de $days días';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Acceso a $permission necesario';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'El acceso a $permission está denegado. Abre Ajustes para permitirlo y vuelve a intentarlo.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Paso $step de 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Eliminar imagen $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Eliminar imagen $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Escribe a $email. Revisamos los informes en 24 horas.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Eliminar $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Añadir a «$name»';
  }

  @override
  String outfitNamedRemoved(String name) {
    return 'Se ha eliminado «$name». Sus prendas siguen en tu armario.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Ver las $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restantes hoy';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Falló la foto $index';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected de $max fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape complexión · $tone piel';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opciones para $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Más usado: $name, $count veces';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: sin definir';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% de coincidencia';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked de $max seleccionadas';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Eliminar $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioridad $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Esta suscripción se factura a través de $store. Cambia o cancela en la configuración de tu cuenta de $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gestionar en $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current de $max usado';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Quedan ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done de $total fotos de estudio listas';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready de $total fotos de estudio listas. Toca una prenda para omitirla.';
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

/// The translations for Spanish Castilian, as used in Mexico (`es_MX`).
class AppLocalizationsEsMx extends AppLocalizationsEs {
  AppLocalizationsEsMx() : super('es_MX');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabPhotoshoot => 'Sesión';

  @override
  String get tabCloset => 'Armario';

  @override
  String get tabOutfits => 'Atuendos';

  @override
  String get tabMore => 'Más';

  @override
  String get actionAddItem => 'Agregar prenda';

  @override
  String get actionCreateOutfit => 'Crear atuendo';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get stateLoading => 'Cargando';

  @override
  String get stateErrorTitle => 'Algo salió mal';

  @override
  String get stateErrorBody =>
      'Intenta de nuevo. Si el error persiste, contacta a soporte.';

  @override
  String get stateOfflineTitle => 'Sin conexión';

  @override
  String get stateOfflineBody =>
      'Conéctate para sincronizar tu armario y generar atuendos.';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAccountSection => 'Cuenta';

  @override
  String get settingsPreferencesSection => 'Preferencias';

  @override
  String get settingsPlanBilling => 'Plan y facturación';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsUnits => 'Unidades de medida';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsPrivacySection => 'Privacidad y datos';

  @override
  String get settingsAboutSection => 'Acerca de';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountTitle => '¿Eliminar tu cuenta?';

  @override
  String get settingsDeleteAccountBody =>
      'Esto eliminará tu armario, outfits, fotos y perfil. No se puede deshacer.';

  @override
  String get settingsUnitsImperial => 'Imperial (in, lb)';

  @override
  String get settingsUnitsMetric => 'Métrico (cm, kg)';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Usar idioma del dispositivo';

  @override
  String get languageSystemBody =>
      'FitCheck AI sigue el idioma de tu teléfono.';

  @override
  String get languageSearchHint => 'Buscar idiomas';

  @override
  String get languageCurrent => 'Actual';

  @override
  String get languageReviewNote =>
      'Esta traducción es nueva. Dinos si algo suena mal.';

  @override
  String get languageChanged => 'Idioma actualizado';

  @override
  String get paywallTitle => 'Elige tu plan';

  @override
  String get paywallTrialBadge => '1 mes gratis';

  @override
  String get paywallTrialTitle => 'Tu primer mes de Pro es gratis';

  @override
  String get paywallTrialBody =>
      'Sube todo tu armario de una vez. Agrega piezas conforme avances después.';

  @override
  String get paywallFreeForeverTitle => 'Gratis siempre';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'No necesitas tarjeta. Cada mes obtienes $uploads subidas por IA, $outfits outfits y $images imágenes de sesión de fotos al día.';
  }

  @override
  String get paywallCtaTrial => 'Iniciar mi mes gratis';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Cambiar a $plan';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallManage => 'Gestionar suscripción';

  @override
  String get paywallTerms => 'Términos de uso';

  @override
  String get paywallPrivacy => 'Política de privacidad';

  @override
  String get paywallPerMonth => 'al mes';

  @override
  String get paywallPerYear => 'al año';

  @override
  String get paywallBestValue => 'Mejor opción';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Prueba gratuita solo para nuevos suscriptores. Después de la prueba, Pro se renueva a $price a menos que se cancele al menos 24 horas antes de que termine.';
  }

  @override
  String get introTitle => 'Tu clóset, finalmente organizado';

  @override
  String get introBody =>
      'Fotografía tu ropa una vez. Obtén ideas de outfits, vistas previas de prueba y fotos de estudio con lo que ya tienes.';

  @override
  String get introStart => 'Comenzar';

  @override
  String get introHaveAccount => 'Ya tengo una cuenta';

  @override
  String get introSkip => 'Omitir';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authSignUp => 'Crear cuenta';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authContinueApple => 'Continuar con Apple';

  @override
  String get authContinueGoogle => 'Continuar con Google';

  @override
  String get authOrDivider => 'o';

  @override
  String get wardrobeTitle => 'Clóset';

  @override
  String get wardrobeEmptyTitle => 'Tu clóset está vacío';

  @override
  String get wardrobeEmptyBody =>
      'Agrega tu primera prenda o sube una foto de todo tu perchero a la vez.';

  @override
  String get wardrobeAddFirst => 'Agregar primer artículo';

  @override
  String get wardrobeSearchHint => 'Busca en tu clóset';

  @override
  String get categoryTops => 'Tops';

  @override
  String get categoryBottoms => 'Pantalones';

  @override
  String get categoryShoes => 'Zapatos';

  @override
  String get categoryAccessories => 'Accesorios';

  @override
  String get categoryOuterwear => 'Abrigos';

  @override
  String get categorySwimwear => 'Trajes de baño';

  @override
  String get categoryActivewear => 'Ropa deportiva';

  @override
  String get categoryOther => 'Otro';

  @override
  String get conditionClean => 'Limpio';

  @override
  String get conditionDirty => 'Sucio';

  @override
  String get conditionLaundry => 'En lavandería';

  @override
  String get conditionRepair => 'Requiere reparación';

  @override
  String get conditionDonate => 'Para donar';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Verano';

  @override
  String get seasonFall => 'Otoño';

  @override
  String get seasonWinter => 'Invierno';

  @override
  String get seasonAll => 'Todo el año';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Ejecutivo';

  @override
  String get styleSporty => 'Deportivo';

  @override
  String get styleBohemian => 'Bohemio';

  @override
  String get styleStreetwear => 'Urbano';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romántico';

  @override
  String get styleEdgy => 'Atrevido';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artístico';

  @override
  String get styleClassic => 'Clásico';

  @override
  String get styleElegant => 'Elegante';

  @override
  String get styleOther => 'Otro';

  @override
  String get occasionWork => 'Trabajo';

  @override
  String get occasionDateNight => 'Cita';

  @override
  String get occasionTravel => 'Viaje';

  @override
  String get occasionWedding => 'Boda';

  @override
  String get occasionGym => 'Gimnasio';

  @override
  String get occasionWeekend => 'Fin de semana';

  @override
  String get occasionParty => 'Fiesta';

  @override
  String get occasionInterview => 'Entrevista';

  @override
  String get colorBlack => 'Negro';

  @override
  String get colorWhite => 'Blanco';

  @override
  String get colorGrey => 'Gris';

  @override
  String get colorNavy => 'Azul marino';

  @override
  String get colorBrown => 'Café';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorBeige => 'Beige';

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count semanas',
      one: 'Hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count meses',
      one: 'Hace 1 mes',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count años',
      one: 'Hace 1 año',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => '¿Te gusta FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Una calificación rápida ayuda a otros a encontrar su estilo.';

  @override
  String get ratingPromptYes => 'Calificar app';

  @override
  String get ratingPromptNo => 'Ahora no';

  @override
  String get closetNoMatchesTitle => 'Sin coincidencias';

  @override
  String get closetNoMatchesBody =>
      'Prueba con menos filtros o una búsqueda distinta.';

  @override
  String get closetClearFilters => 'Limpiar filtros';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prendas',
      one: '1 prenda',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Cargando tus prendas';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionadas',
      one: '1 seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Eliminar seleccionadas';

  @override
  String get closetCancelSelection => 'Cancelar selección';

  @override
  String get closetCloseSearch => 'Cerrar búsqueda';

  @override
  String get closetShowGrid => 'Ver en cuadrícula';

  @override
  String get closetShowList => 'Ver en lista';

  @override
  String get closetShowRows => 'Ver en filas';

  @override
  String get closetStatsTitle => 'Estadísticas del clóset';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count prendas?',
      one: '¿Eliminar 1 prenda?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Los outfits que las usan perderán estas prendas.';

  @override
  String get closetSortBy => 'Ordenar por';

  @override
  String get closetFavourites => 'Favoritos';

  @override
  String get closetFavourite => 'Favorito';

  @override
  String get closetUnfavourite => 'Quitar de favoritos';

  @override
  String get closetWoreToday => 'Usada hoy';

  @override
  String closetWornTimes(int count) {
    return 'Usada $count×';
  }

  @override
  String get closetCategoryLabel => 'Categoría';

  @override
  String get closetUseCaseLabel => 'Ocasión';

  @override
  String get closetAnyUseCase => 'Cualquiera';

  @override
  String get closetOtherUseCase => 'Otra ocasión';

  @override
  String get closetOtherUseCaseHint => 'Por ejemplo, brunch';

  @override
  String get closetUseUseCase => 'Usar esta';

  @override
  String get closetClearAll => 'Limpiar todo';

  @override
  String get sortNewest => 'Más recientes primero';

  @override
  String get sortOldest => 'Más antiguos primero';

  @override
  String get sortName => 'Nombre (A–Z)';

  @override
  String get sortMostWorn => 'Más usados';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Cita';

  @override
  String get useCaseDinner => 'Cena';

  @override
  String get useCaseLunch => 'Comida';

  @override
  String get actionSelect => 'Seleccionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get actionSort => 'Ordenar';

  @override
  String get actionAll => 'Todo';

  @override
  String get dashboardStartClosetTitle => 'Empieza tu clóset';

  @override
  String get dashboardStartClosetBody =>
      'Fotografía algunas prendas. Nosotros las etiquetamos por ti.';

  @override
  String get dashboardPieces => 'prendas';

  @override
  String get dashboardOutfits => 'atuendos';

  @override
  String get dashboardDayStreak => 'días seguidos';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count este mes';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Mejor racha $count';
  }

  @override
  String dashboardFavourites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritos',
      one: '1 favorito',
    );
    return '$_temp0';
  }

  @override
  String dashboardSavedOutfits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atuendos guardados',
      one: '1 atuendo guardado',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Más usado: $name, $count veces';
  }

  @override
  String get setupSkip => 'Omitir configuración';

  @override
  String get setupWhoTitle => '¿A quién vestimos?';

  @override
  String get setupWhoBody =>
      'Define el modelo para pruebas y fotos. Puedes cambiarlo en tu perfil.';

  @override
  String get setupStyleTitle => '¿Qué usas más?';

  @override
  String get setupStyleBody =>
      'Elige cualquiera. Las ideas de atuendos parten de aquí.';

  @override
  String get setupClosetTitle => 'Agrega tus primeras prendas.';

  @override
  String get setupClosetBody =>
      'Toma fotos de tu ropa, individual o en grupo. Cada prenda se recorta y organiza por ti.';

  @override
  String get setupAddClothes => 'Agregar ropa';

  @override
  String get setupStylesLabel => 'Estilos';

  @override
  String get setupOccasionsLabel => 'Ocasiones';

  @override
  String get setupSkipStep => 'Omitir';

  @override
  String get setupLater => 'Después';

  @override
  String get setupSaveError => 'No se pudo guardar';

  @override
  String get genderWomen => 'Mujer';

  @override
  String get genderMen => 'Hombre';

  @override
  String get genderNonBinary => 'No binario';

  @override
  String get genderPreferNotToSay => 'Prefiero no decirlo';

  @override
  String get outfitEmptyTitle => 'Aún no hay conjuntos';

  @override
  String get outfitEmptyBody =>
      'Combina prendas de tu clóset y guarda el look.';

  @override
  String get outfitNoMatchesTitle => 'No hay conjuntos que coincidan';

  @override
  String get outfitSearchHint => 'Buscar en tus conjuntos';

  @override
  String get outfitLoading => 'Cargando tus conjuntos';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conjuntos',
      one: '1 conjunto',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Estilo y temporada';

  @override
  String get outfitCollections => 'Colecciones';

  @override
  String get outfitDuplicate => 'Duplicar';

  @override
  String get outfitDeleteTitle => '¿Eliminar este conjunto?';

  @override
  String get outfitDeleteBody => 'Las prendas seguirán en tu clóset.';

  @override
  String get outfitDrafts => 'Borradores';

  @override
  String get outfitDraft => 'Borrador';

  @override
  String get filterStyle => 'Estilo';

  @override
  String get filterSeason => 'Temporada';

  @override
  String get itemDetailDeleteTitle => '¿Eliminar esta prenda?';

  @override
  String get itemDetailDeleteBody =>
      'Los outfits que la usan perderán esta prenda.';

  @override
  String get itemAddFavourite => 'Añadir a favoritos';

  @override
  String itemSize(String size) {
    return 'Talla $size';
  }

  @override
  String get itemColours => 'Colores';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Estampado';

  @override
  String get itemUseCases => 'Ocasiones';

  @override
  String get itemKeptIn => 'Guardado en';

  @override
  String get itemPrice => 'Precio';

  @override
  String get itemBought => 'Comprado';

  @override
  String get itemTags => 'Etiquetas';

  @override
  String get itemAdded => 'Añadido';

  @override
  String get itemTimesWornLabel => 'veces usado';

  @override
  String get itemLastWornLabel => 'última vez';

  @override
  String get itemNeverWorn => 'Nunca';

  @override
  String get authEntryBody =>
      'Cada prenda que tienes, estilizada por IA. Planea outfits, pruébatelos y fotografíalos.';

  @override
  String get authCreateCloset => 'Crea tu clóset';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authSignInBody => 'Inicia sesión para abrir tu clóset.';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authCreateClosetBody =>
      'Toma un minuto. Tus primeras prendas son gratis.';

  @override
  String get authName => 'Nombre';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authReferralCode => 'Código de referido (opcional)';

  @override
  String get authResetTitle => 'Restablece tu contraseña';

  @override
  String get authResetBody =>
      'Te enviaremos un enlace por correo para elegir una nueva.';

  @override
  String get authSendResetLink => 'Enviar enlace';

  @override
  String get authBackToSignIn => 'Volver a iniciar sesión';

  @override
  String get authEnterEmail => 'Ingresa tu correo';

  @override
  String get authEnterValidEmail => 'Ingresa un correo válido';

  @override
  String get authEnterPassword => 'Ingresa tu contraseña';

  @override
  String get authPasswordTooShort => 'Al menos 6 caracteres';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authNewHere => '¿Eres nuevo?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirma $email antes de iniciar sesión. Revisa tu bandeja de entrada.';
  }

  @override
  String get authResendEmail => 'Enviar de nuevo';

  @override
  String get authResendingEmail => 'Enviando…';

  @override
  String get authPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get authEnterName => 'Ingresa tu nombre';

  @override
  String get authChoosePassword => 'Elige una contraseña';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authCodeAccepted => 'Código aceptado';

  @override
  String get authCodeNotFound => 'Código no encontrado';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Ambos obtienen un mes gratis.';
  }

  @override
  String get authReferralInvalid => 'No pudimos encontrar este código.';

  @override
  String authResetSent(String email) {
    return 'Enviado a $email. Abre el enlace en este teléfono.';
  }

  @override
  String get introSlide1Title => 'Fotografía tu clóset una vez.';

  @override
  String get introSlide1Body =>
      'Toma una foto de tu ropa. Cada prenda se recorta y organiza por ti.';

  @override
  String get introSlide2Title => 'Vístete más rápido.';

  @override
  String get introSlide2Body =>
      'Atuendos con lo que ya tienes, adaptados a tus planes y al clima.';

  @override
  String get introSlide3Title => 'Pruébatelo antes de usarlo.';

  @override
  String get introSlide3Body =>
      'Prueba looks en tu propia foto o crea imágenes como de revista.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Actualizaciones por correo';

  @override
  String get settingsEmailUpdatesBody => 'Noticias y consejos por correo';

  @override
  String get settingsOutfitReminders => 'Recordatorios de outfits';

  @override
  String get settingsOutfitRemindersBody =>
      'Un aviso para registrar lo que usaste';

  @override
  String get settingsWeeklySummary => 'Resumen semanal';

  @override
  String get settingsWeeklySummaryBody => 'Tu semana en outfits';

  @override
  String get settingsStyleSection => 'Estilo';

  @override
  String get settingsPreferredStyles => 'Estilos que te gustan';

  @override
  String get settingsPreferredColours => 'Colores que te gustan';

  @override
  String get settingsNoneChosen => 'Ninguno seleccionado';

  @override
  String get settingsPlanAiSection => 'Plan e IA';

  @override
  String get settingsPlanBillingBody => 'Plan, uso y mejoras';

  @override
  String get settingsPlanUsageBody => 'Plan y uso';

  @override
  String get settingsInviteFriends => 'Invitar amigos';

  @override
  String get settingsInviteFriendsBody =>
      'Un mes gratis por cada amigo que se una';

  @override
  String get settingsAiProvider => 'Proveedor de IA';

  @override
  String get settingsAiProviderBody =>
      'Usa tu propio modelo para etiquetas e imágenes';

  @override
  String get settingsAppVersion => 'Versión de la app';

  @override
  String get settingsPrivacyTerms => 'Privacidad y términos';

  @override
  String get settingsReportProblem => 'Reportar un problema';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsExportData => 'Exportar tus datos';

  @override
  String get settingsExportBody =>
      'Preparamos un archivo con todo lo que guardaste y abrimos la descarga.';

  @override
  String get settingsExportAction => 'Exportar';

  @override
  String get settingsCurrentPassword => 'Contraseña actual';

  @override
  String get settingsNewPassword => 'Nueva contraseña';

  @override
  String get settingsConfirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get settingsEnterCurrentPassword => 'Ingresa tu contraseña actual';

  @override
  String get settingsEnterNewPassword => 'Ingresa una nueva contraseña';

  @override
  String get settingsPasswordMin8 => 'Usa al menos 8 caracteres';

  @override
  String get settingsPasswordNeedsUpper => 'Agrega una letra mayúscula';

  @override
  String get settingsPasswordNeedsLower => 'Agrega una letra minúscula';

  @override
  String get settingsPasswordNeedsDigit => 'Agrega un número';

  @override
  String get settingsPasswordsNoMatch => 'Las contraseñas no coinciden';

  @override
  String get settingsChangeAction => 'Cambiar';

  @override
  String get itemAddSnapTitle => 'Captura una prenda';

  @override
  String get itemAddSnapBody =>
      'Detectamos cada prenda en la foto y creamos una imagen de estudio limpia.';

  @override
  String get itemAddCamera => 'Tomar foto';

  @override
  String get itemAddGallery => 'Elegir de la galería';

  @override
  String get itemAddOtherWays => 'Otras formas de agregar';

  @override
  String get itemAddSeveral => 'Agregar varias fotos';

  @override
  String get itemAddSeveralBody => 'Hasta 50 a la vez';

  @override
  String get itemAddImportProfile => 'Importar de un perfil';

  @override
  String get itemAddImportProfileBody => 'Instagram o Facebook';

  @override
  String get itemAddEnterDetails => 'Ingresar detalles manualmente';

  @override
  String get itemAddEnterDetailsBody => 'No se requiere foto';

  @override
  String get itemManualIntro =>
      'Solo necesitas un nombre. Agrega el resto ahora o después.';

  @override
  String get itemManualNameHint => 'Por ejemplo, playera azul de algodón';

  @override
  String get itemManualEnterName => 'Ingresa un nombre';

  @override
  String get itemManualNotes => 'Notas';

  @override
  String get itemManualBrand => 'Marca';

  @override
  String get itemManualSize => 'Talla';

  @override
  String get itemManualEnterNumber => 'Ingresa un número';

  @override
  String get itemManualSavePiece => 'Guardar prenda';

  @override
  String get itemManualSaving => 'Guardando';

  @override
  String get itemManualSavedTitle => 'Guardado';

  @override
  String itemManualSavedBody(String name) {
    return '$name está en tu clóset.';
  }

  @override
  String get itemManualNotSaved => 'No guardado';

  @override
  String get itemManualAddUseCase => 'Agregar uso';

  @override
  String get itemManualAddUseCaseAction => 'Agregar uso';

  @override
  String get itemPhotos => 'Fotos';

  @override
  String get itemAddPhotos => 'Agregar fotos';

  @override
  String get itemNoPhotoYet => 'Sin foto aún. Puedes guardar sin ella.';

  @override
  String get itemRemovePhoto => 'Eliminar foto';

  @override
  String get itemRemovePiece => 'Eliminar prenda';

  @override
  String get filterConditionLabel => 'Condición';

  @override
  String get photoshootStepPhotos => 'Fotos';

  @override
  String get photoshootStepSetup => 'Configuración';

  @override
  String get photoshootStepCreating => 'Creando';

  @override
  String get photoshootStepResults => 'Resultados';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Paso $current de $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Una foto falló. Inténtalo de nuevo abajo.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotos fallaron. Intenta cada una abajo.';
  }

  @override
  String get photoshootFormat => 'Formato';

  @override
  String get photoshootHowMany => 'Cantidad';

  @override
  String get photoshootYourPrompt => 'Tu descripción';

  @override
  String get photoshootPromptHint =>
      'Hora dorada en una azotea, camisa de lino';

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
  String get photoshootLimitUnknown => 'No pudimos verificar el límite de hoy.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plan $plan: $remaining de $limit restantes hoy';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratis';

  @override
  String get photoshootGallery => 'Galería';

  @override
  String get photoshootUseCamera => 'Usar cámara';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Eliminar foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'No se obtuvieron fotos';

  @override
  String get photoshootNoPhotosBody =>
      'La sesión terminó sin imágenes. Inténtalo de nuevo.';

  @override
  String get photoshootNewStyle => 'Nuevo estilo';

  @override
  String get photoshootNewPhotos => 'Nuevas fotos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Abrir foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Reportar foto';

  @override
  String get photoshootSaveToGallery => 'Guardar en galería';

  @override
  String get actionUpgrade => 'Actualizar';

  @override
  String get referralLimitTitle => 'Usaste tus fotos de hoy';

  @override
  String get referralLimitBody =>
      'Tus fotos gratis regresan mañana. Invita a un amigo y ambos obtendrán un mes de Pro gratis.';

  @override
  String get referralLimitRefer => 'Invitar a un amigo';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'App de citas';

  @override
  String get photoshootUsePortfolio => 'Portafolio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estético';

  @override
  String get photoshootUseCustom => 'Tu propio prompt';

  @override
  String get photoshootDescLinkedin => 'Fotos profesionales para el trabajo';

  @override
  String get photoshootDescDating => 'Relajado, cálido y natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, looks de alta moda';

  @override
  String get photoshootDescInstagram => 'Fotos de estilo de vida para tu feed';

  @override
  String get photoshootDescAesthetic => 'Tomas artísticas y con estilo';

  @override
  String get photoshootDescCustom => 'Describe el look que deseas';

  @override
  String get aspectSquare => 'Cuadrado';

  @override
  String get aspectPortrait => 'Retrato';

  @override
  String get aspectLandscape => 'Paisaje';

  @override
  String get aspectTall => 'Alto';

  @override
  String get aspectWide => 'Ancho';

  @override
  String get tryOnAppBar => 'Probador virtual';

  @override
  String get tryOnYourPhoto => 'Tu foto';

  @override
  String get tryOnGarment => 'Prenda';

  @override
  String get tryOnUploadingPhoto => 'Subiendo tu foto';

  @override
  String get tryOnAddPhotoPrompt => 'Agrega una foto de cuerpo completo';

  @override
  String get tryOnBodyPhotoHint => 'Una foto de cuerpo completo funciona mejor';

  @override
  String get tryOnAddPhoto => 'Agregar foto';

  @override
  String get tryOnChangePhoto => 'Cambiar foto';

  @override
  String get tryOnPhotoLoadFailed => 'No pudimos cargar tu foto.';

  @override
  String get tryOnChooseGarment => 'Elige la foto de una prenda';

  @override
  String get tryOnChooseOneGarment => 'Elige una foto de prenda';

  @override
  String get tryOnGarmentHint => 'Una foto en plano o colgada funciona mejor';

  @override
  String get tryOnChange => 'Cambiar';

  @override
  String get tryOnCamera => 'Cámara';

  @override
  String get tryOnRemove => 'Eliminar';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Estilo';

  @override
  String get tryOnBackground => 'Fondo';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Vistiéndote. Esto toma medio minuto aproximadamente.';

  @override
  String get tryOnEmptyResult => 'Tu prueba aparecerá aquí';

  @override
  String get tryOnReportImage => 'Reportar imagen';

  @override
  String get tryOnCreating => 'Creando';

  @override
  String get tryOnTryAgain => 'Intentar de nuevo';

  @override
  String get tryOnCreate => 'Crear prueba';

  @override
  String get tryOnBackgroundStudioWhite => 'Estudio blanco';

  @override
  String get tryOnBackgroundStudioGrey => 'Estudio gris';

  @override
  String get tryOnBackgroundUrban => 'Calle urbana';

  @override
  String get tryOnBackgroundNature => 'Naturaleza';

  @override
  String get tryOnBackgroundMinimal => 'Minimalista';

  @override
  String get tryOnPoseFront => 'De frente';

  @override
  String get tryOnPoseSide => 'De lado';

  @override
  String get tryOnPoseWalking => 'Caminando';

  @override
  String get dashboardGreetingMorning => 'Buenos días';

  @override
  String get dashboardGreetingAfternoon => 'Buenas tardes';

  @override
  String get dashboardGreetingEvening => 'Buenas noches';

  @override
  String get dashboardWelcome => 'Bienvenido';

  @override
  String get dashboardOpenProfile => 'Abrir perfil';

  @override
  String get dashboardRailToday => 'Hoy';

  @override
  String get dashboardRailRecently => 'Reciente';

  @override
  String get dashboardActivityEmpty =>
      'Aquí verás tus prendas y conjuntos nuevos.';

  @override
  String get quickAddPiece => 'Agregar prenda';

  @override
  String get quickAddPieceBody => 'Fotografía y etiqueta';

  @override
  String get quickBuildOutfit => 'Crear conjunto';

  @override
  String get quickBuildOutfitBody => 'Combina tus prendas';

  @override
  String get quickForYou => 'Para ti';

  @override
  String get quickForYouBody => 'Sugerencias de hoy';

  @override
  String get quickPlanWeek => 'Planear semana';

  @override
  String get quickPlanWeekBody => 'Conjuntos por fecha';

  @override
  String get referralBannerUrgent => '¿Te queda poco? Invita a un amigo.';

  @override
  String get referralBannerTitle => 'Regala un mes, recibe un mes.';

  @override
  String get referralBannerBody => 'Tú y tu amigo obtienen un mes de Pro.';

  @override
  String get referralBannerDismiss => 'Ocultar por una semana';

  @override
  String get referralBannerShare => 'Compartir invitación';

  @override
  String get referralBannerCopy => 'Copiar enlace';

  @override
  String get itemEditPieceTitle => 'Editar prenda';

  @override
  String get itemEditDescriptionLabel => 'Descripción';

  @override
  String get itemEditNotSaved => 'No guardado';

  @override
  String get itemEditSavedTitle => 'Guardado';

  @override
  String get itemEditSavedBody => 'Tus cambios se guardaron.';

  @override
  String get itemEditSavedStalePhotos =>
      'Guardado — las fotos podrían estar desactualizadas';

  @override
  String get itemEditRemovePieceHint =>
      'Elimina esta pieza de la página del artículo.';

  @override
  String get itemEditNoPhotos =>
      'Aún no hay fotos. Agrega una desde tu galería o cámara.';

  @override
  String get itemEditKeepPhoto => 'Mantener foto';

  @override
  String get itemEditRemoved => 'Eliminado';

  @override
  String get itemEditAddUseCaseAction => 'Agregar';

  @override
  String get statsNoStatsTitle => 'Aún no hay estadísticas';

  @override
  String get statsNoStatsBody =>
      'Agrega algunas piezas y tu mezcla de clóset aparecerá aquí.';

  @override
  String get statsByCategory => 'Por categoría';

  @override
  String get statsTotalValue => 'valor total';

  @override
  String get statsMostWorn => 'Más usada';

  @override
  String get statsLeastWorn => 'Esperando su turno';

  @override
  String get statsUnnamedPiece => 'Pieza sin nombre';

  @override
  String get jobsTitle => 'Escaneos';

  @override
  String get jobsEmptyTitle => 'Aún no hay escaneos';

  @override
  String get jobsEmptyBody =>
      'Toma una foto de una pieza y envíala a segundo plano; seguirá trabajando aquí.';

  @override
  String get jobsNotCancelled => 'No cancelado';

  @override
  String get jobsResume => 'Reanudar';

  @override
  String get jobsReview => 'Revisar';

  @override
  String get jobsStop => 'Detener';

  @override
  String get jobsDismiss => 'Descartar';

  @override
  String get reportTitle => 'Reportar contenido';

  @override
  String reportIntro(String contentType) {
    return 'Dinos qué está mal con este $contentType. Nuestro equipo revisa cada reporte.';
  }

  @override
  String get reportReasonInappropriate => 'Inapropiado u ofensivo';

  @override
  String get reportReasonNudity => 'Desnudez o contenido sexual';

  @override
  String get reportReasonHarassment => 'Acoso o abuso';

  @override
  String get reportReasonImpersonation => 'Suplantación de identidad';

  @override
  String get reportReasonOther => 'Otro';

  @override
  String get reportDetailsLabel => 'Detalles adicionales (opcional)';

  @override
  String get reportSubmit => 'Enviar reporte';

  @override
  String get reportSubmittedTitle => 'Reporte enviado';

  @override
  String get reportSubmittedBody =>
      'Gracias. Nuestro equipo revisará este contenido.';

  @override
  String get reportFailedTitle => 'No se pudo enviar el reporte';

  @override
  String get reportFailedBody => 'Por favor, intenta de nuevo.';

  @override
  String get reportContentTryOnImage => 'imagen de prueba virtual';

  @override
  String get reportContentSharedOutfit => 'atuendo compartido';

  @override
  String get reportContentPhotoshootImage => 'imagen de sesión de fotos IA';

  @override
  String get sharedOutfitTitle => 'Atuendo compartido';

  @override
  String get sharedOutfitHideTooltip => 'Ocultar este atuendo';

  @override
  String get sharedOutfitReportTooltip => 'Reportar este atuendo';

  @override
  String get sharedOutfitHideTitle => '¿Ocultar este atuendo?';

  @override
  String get sharedOutfitHideBody =>
      'Se ocultará en este dispositivo. También puedes reportarlo para que nuestro equipo lo revise y elimine.';

  @override
  String get sharedOutfitHideAction => 'Ocultar';

  @override
  String get sharedOutfitHiddenInfo =>
      'Este atuendo no volverá a aparecer en este dispositivo.';

  @override
  String get sharedOutfitHiddenToast => 'Atuendo oculto';

  @override
  String get sharedOutfitMissingTitle => 'Este atuendo ya no está disponible';

  @override
  String get sharedOutfitMissingBody =>
      'Es posible que se haya eliminado o que el enlace sea incorrecto.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Ocultaste este atuendo';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Si es inapropiado, repórtalo en Privacidad y términos o envía un correo a $email.';
  }

  @override
  String get sharedOutfitCtaTitle => '¿Te gusta este look?';

  @override
  String get sharedOutfitCtaBody =>
      'Crea atuendos similares con tu propio clóset.';

  @override
  String get sharedOutfitCtaButton => 'Obtén FitCheck AI';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorUnknown => 'Ocurrió un error inesperado';

  @override
  String get errorNoConnection => 'Sin conexión a internet. Revisa tu red.';

  @override
  String get errorTimeout => 'La solicitud expiró. Intenta de nuevo.';

  @override
  String get errorServerError =>
      'Algo salió mal de nuestro lado. Intenta de nuevo.';

  @override
  String get errorBadGateway =>
      'Nuestro servidor no está disponible. Intenta de nuevo.';

  @override
  String get errorServiceUnavailable =>
      'El servicio no está disponible. Intenta en un momento.';

  @override
  String get errorInternalError => 'Algo salió mal. Intenta de nuevo.';

  @override
  String get errorUnauthorized => 'Inicia sesión para continuar.';

  @override
  String get errorForbidden => 'No tienes acceso a esto.';

  @override
  String get errorSessionExpired => 'Tu sesión expiró. Inicia sesión de nuevo.';

  @override
  String get errorInvalidCredentials =>
      'El correo o la contraseña son incorrectos.';

  @override
  String get errorTokenRefreshFailed =>
      'No pudimos refrescar tu sesión. Inicia sesión de nuevo.';

  @override
  String get errorRequestCancelled => 'Solicitud cancelada.';

  @override
  String get errorInvalidFormat => 'Formato de archivo no compatible.';

  @override
  String get errorFileTooLarge => 'El archivo es demasiado grande.';

  @override
  String get errorUploadFailed => 'Error al subir. Intenta de nuevo.';

  @override
  String get errorCacheCorrupted =>
      'Los datos guardados se dañaron y fueron reiniciados.';

  @override
  String get errorCacheNotFound => 'Aún no hay nada guardado.';

  @override
  String get errorUserNotFound => 'No pudimos encontrar esa cuenta.';

  @override
  String get errorItemNotFound => 'Esa prenda ya no existe.';

  @override
  String get errorOutfitNotFound => 'Ese outfit ya no existe.';

  @override
  String get rewardsTitle => 'Recompensas';

  @override
  String get rewardsNoAchievementsTitle => 'Aún sin logros';

  @override
  String get rewardsNoAchievementsBody =>
      'Agrega prendas y planea outfits para ganar el primero.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Aún no hay nadie en la tabla';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Planea outfits para ganar puntos y aparecer aquí.';

  @override
  String get legalViewPrivacyPolicy => 'Ver Política de Privacidad';

  @override
  String get aiConsentAgree => 'Acepto y continuar';

  @override
  String get aiConsentNotNow => 'Ahora no';

  @override
  String get imageViewerCloseTooltip => 'Cerrar visor de imágenes';

  @override
  String get updateReadyTitle => 'Actualización lista';

  @override
  String get updateReadyBody =>
      'Reinicia FitCheck AI para aplicar las mejoras más recientes.';

  @override
  String get permissionCameraUsage =>
      'FitCheck AI necesita acceso a la cámara para tomar fotos de tus atuendos y prendas.';

  @override
  String get permissionPhotoLibraryUsage =>
      'FitCheck AI necesita acceso a tu fototeca para seleccionar fotos de tus atuendos y prendas.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'FitCheck AI necesita guardar las fotos de tus atuendos generadas por IA en tu fototeca.';

  @override
  String get wardrobeSomePhotosSkipped => 'Se omitieron algunas fotos';

  @override
  String get wardrobePhotosNotAdded => 'Fotos no añadidas';

  @override
  String get wardrobePhotoNotAdded => 'Foto no añadida';

  @override
  String get wardrobeNotStartedTitle => 'Sin iniciar';

  @override
  String get wardrobeNoRoomTitle => 'Sin espacio';

  @override
  String get wardrobeAddPhotosSemantic => 'Añadir fotos';

  @override
  String get batchAddTileLabel => 'Añadir';

  @override
  String get batchProfileLinkLabel => 'Enlace de perfil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importar desde un perfil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Añadir varias fotos';

  @override
  String get wardrobeClearAction => 'Limpiar';

  @override
  String get wardrobeRefreshTooltip => 'Actualizar';

  @override
  String get batchNoPhotosYetTitle => 'Aún no hay fotos';

  @override
  String get batchChoosePhotosAction => 'Elegir fotos';

  @override
  String get batchWeFindEachPieceBody =>
      'Identificamos cada prenda y creamos una foto de estudio.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparando fotos';

  @override
  String get batchPhotosProcessedSemantic => 'Fotos procesadas';

  @override
  String get batchPasteProfileLinkTitle => 'Pega un enlace de perfil';

  @override
  String get batchPasteProfileLinkBody =>
      'Un perfil público de Instagram o Facebook. Escaneamos sus fotos y tú eliges qué añadir a tu clóset.';

  @override
  String get batchClearLinkTooltip => 'Limpiar enlace';

  @override
  String get batchStartingButton => 'Iniciando';

  @override
  String get batchStartImportAction => 'Iniciar importación';

  @override
  String get batchReviewEveryPhotoTitle => 'Tú revisas cada foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nada se añade hasta que tú lo apruebes.';

  @override
  String get batchPrivateProfilesTitle => 'Perfiles privados';

  @override
  String get batchPrivateProfilesBody =>
      'Conecta tu cuenta. Instagram también pide usuario y contraseña.';

  @override
  String get batchUseAnotherLinkAction => 'Usar otro enlace';

  @override
  String get batchSignInNeededTitle => 'Inicio de sesión necesario';

  @override
  String get batchEnterYourCodeTitle => 'Ingresa tu código';

  @override
  String get batchUseUsernamePasswordAction => 'Usar usuario y contraseña';

  @override
  String get batchAlreadyConnectedAction => 'Ya me conecté en el navegador';

  @override
  String get batchEnterCodeAction => 'Ingresar código';

  @override
  String get batchTryAnotherWayAction => 'Probar de otro modo';

  @override
  String get batchLiveStatus => 'En vivo';

  @override
  String get batchReconnectingStatus => 'Reconectando';

  @override
  String get batchSignInToInstagramTitle => 'Inicia sesión en Instagram';

  @override
  String get batchUsernameLabel => 'Usuario';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Código, si usas verificación en dos pasos';

  @override
  String get batchAuthenticatorCodeBody =>
      'Usa el código de 6 dígitos de tu app de autenticación. Los códigos cambian rápido.';

  @override
  String get batchVerifyAction => 'Verificar';

  @override
  String get batchFindingPhotosTitle => 'Buscando fotos';

  @override
  String get batchImportPausedTitle => 'Importación pausada';

  @override
  String get batchProcessingPhotosTitle => 'Procesando fotos';

  @override
  String get batchWaitingNextPhoto => 'Esperando la siguiente foto';

  @override
  String get batchCancelImportAction => 'Cancelar importación';

  @override
  String get batchNoPiecesInPhotoBody =>
      'No se encontraron prendas en esta foto.';

  @override
  String get batchEditPieceColoursLabel => 'Colores separados por comas';

  @override
  String get batchAddToClosetAction => 'Agregar al clóset';

  @override
  String get batchSkipPhotoAction => 'Omitir foto';

  @override
  String get batchImportCompleteTitle => 'Importación completa';

  @override
  String get batchImportFailedTitle => 'Error en la importación';

  @override
  String get batchImportCancelledTitle => 'Importación cancelada';

  @override
  String get batchImportErrorBody => 'Algo salió mal durante la importación.';

  @override
  String get batchNothingMoreImportedBody =>
      'No se importó nada más de este perfil.';

  @override
  String get batchViewClosetAction => 'Ver clóset';

  @override
  String get batchStartOverAction => 'Empezar de nuevo';

  @override
  String get wardrobeAddPieceTitle => 'Agregar prenda';

  @override
  String get wardrobeAddDetailsTitle => 'Agregar detalles';

  @override
  String get wardrobeScanningTitle => 'Escaneando';

  @override
  String get batchReviewPiecesTitle => 'Revisar prendas';

  @override
  String get wardrobeGalleryAction => 'Galería';

  @override
  String get wardrobeCameraAction => 'Cámara';

  @override
  String get wardrobeNewBadge => 'Nuevo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Eliminar foto';

  @override
  String get batchRunInBackgroundTooltip => 'Ejecutar en segundo plano';

  @override
  String get batchStepOneOfTwo => 'Paso 1 de 2';

  @override
  String get batchStepTwoOfTwo => 'Paso 2 de 2';

  @override
  String get batchUploadingPhotosTitle => 'Subiendo fotos';

  @override
  String get batchFindingPiecesTitle => 'Buscando prendas';

  @override
  String get batchMakingStudioPhotosTitle => 'Creando fotos de estudio';

  @override
  String get batchStoppedLabel => 'Detenido';

  @override
  String get batchFindingPiecesStoppedTitle => 'Búsqueda de prendas detenida';

  @override
  String get batchCancelledLabel => 'Cancelado';

  @override
  String get batchAllDoneTitle => 'Todo listo';

  @override
  String get batchOpeningPiecesBody => 'Abriendo tus prendas';

  @override
  String get batchNothingSavedBody => 'No se guardó nada.';

  @override
  String get batchFindingPiecesFailedBody => 'Error al buscar prendas.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'La búsqueda de prendas se detuvo antes de tiempo.';

  @override
  String get batchStopFindingPiecesTitle => '¿Detener búsqueda?';

  @override
  String get batchStopFindingPiecesBody =>
      'El escaneo se detiene y no se guarda nada. Las prendas ya encontradas permanecen en tu actividad hasta que las descartes.';

  @override
  String get batchKeepGoingAction => 'Continuar';

  @override
  String get batchTryAgainAction => 'Intentar de nuevo';

  @override
  String get batchBackToPhotosAction => 'Volver a las fotos';

  @override
  String get batchSkipAllAction => 'Omitir todo';

  @override
  String get batchIncludeAllAction => 'Incluir todas';

  @override
  String get batchNoPiecesFoundTitle => 'No se encontraron prendas';

  @override
  String get batchNoPiecesFoundBody => 'No encontramos ropa en estas fotos.';

  @override
  String get batchChooseOtherPhotosAction => 'Elegir otras fotos';

  @override
  String get batchUseCaseHelper => 'Se agrega a cada prenda que guardes.';

  @override
  String get batchDiscardPiecesTitle => '¿Descartar estas prendas?';

  @override
  String get batchDiscardPiecesBody => 'No se guardó nada de este lote.';

  @override
  String get batchKeepAction => 'Conservar';

  @override
  String get batchDiscardAction => 'Descartar';

  @override
  String get batchRemovePieceTitle => '¿Eliminar esta prenda?';

  @override
  String get batchRemovePieceBody => 'No está guardada en tu clóset.';

  @override
  String get batchRemoveAction => 'Eliminar';

  @override
  String get batchChoosePiecesToSave => 'Elige prendas para guardar';

  @override
  String get batchDiscardAllAction => 'Descartar todo';

  @override
  String get batchNothingSavedRetryBody =>
      'No se guardó nada. Inténtalo de nuevo.';

  @override
  String get batchNotSavedTitle => 'No guardado';

  @override
  String get batchSavingLabel => 'Guardando';

  @override
  String get batchSendToBackgroundAction => 'Enviar a segundo plano';

  @override
  String get batchStillWorkingMessage =>
      'Seguimos trabajando. Te avisaremos cuando tus prendas estén listas.';

  @override
  String get batchRunningInBackgroundTitle => 'Ejecutándose en segundo plano';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Las fotos de estudio se detuvieron antes de tiempo. Aún puedes guardar estas prendas.';

  @override
  String get batchTapPieceToSkip => 'Toca una prenda para omitirla.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Las fotos de estudio vienen en camino. Puedes salir; te avisaremos.';

  @override
  String get batchLeaveAction => 'Salir';

  @override
  String get batchPeopleInPhotosTitle => 'Personas en las fotos';

  @override
  String get batchIncludeAction => 'Incluir';

  @override
  String get batchSkipAction => 'Omitir';

  @override
  String get batchYourPhotoIsUsedLabel => 'Se usa tu foto';

  @override
  String get batchMakingStudioPhotoLabel => 'Creando foto de estudio';

  @override
  String get batchNoStudioPhotoBody => 'Sin foto de estudio. Se usa tu foto.';

  @override
  String get batchEnterDetailsYourselfAction => 'Ingresar datos manualmente';

  @override
  String get batchChooseAnotherPhotoAction => 'Elegir otra foto';

  @override
  String get batchConnectionLostTitle => 'Sin conexión';

  @override
  String get batchConnectionLostBody =>
      'Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get batchDailyLimitTitle => 'Límite diario alcanzado';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Actualiza a Pro para más escaneos o ingresa los datos tú mismo.';

  @override
  String get batchDailyLimitBodyFree =>
      'Tus escaneos se reinician mañana. Puedes ingresar los datos tú mismo ahora.';

  @override
  String get batchSeePlansAction => 'Ver planes';

  @override
  String get batchAiBusyTitle => 'Nuestra IA está ocupada';

  @override
  String get batchAiBusyBody =>
      'Esto es de nuestro lado. Inténtalo de nuevo en unos minutos.';

  @override
  String get batchNoPiecesBody =>
      'Prueba con una foto más clara o ingresa los datos tú mismo.';

  @override
  String get batchScanningUnavailableTitle => 'El escaneo no está disponible';

  @override
  String get batchScanningUnavailableBody =>
      'Ingresa los datos tú mismo por ahora.';

  @override
  String get batchScanDidNotFinishTitle => 'El escaneo no terminó';

  @override
  String get batchTryAgainBody => 'Inténtalo de nuevo.';

  @override
  String get billingTitle => 'Suscripción';

  @override
  String get billingUpgradeHeading => 'Mejora tu plan';

  @override
  String get billingUpgradeOnPlusBody => 'Mismas funciones, mayores límites.';

  @override
  String get billingUpgradeBody =>
      'Plus y Pro tienen las mismas funciones. Elige los límites que necesitas.';

  @override
  String get billingWebUnavailableBody =>
      'Las actualizaciones en línea no están disponibles aún. Un código promocional o de referido desbloquea Plus o Pro. Invita amigos abajo para ganar meses gratis.';

  @override
  String get billingPlansStale =>
      'No se pudieron cargar los planes recientes. Los precios pueden estar desactualizados.';

  @override
  String get billingMonthly => 'Mensual';

  @override
  String get billingYearly => 'Anual';

  @override
  String get billingCurrentPlan => 'Plan actual';

  @override
  String get billingActive => 'Activo';

  @override
  String get billingThisMonth => 'Este mes';

  @override
  String get billingItemExtractions => 'Extracciones de prendas';

  @override
  String get billingOutfitVisualizations => 'Visualizaciones de outfits';

  @override
  String get billingNearLimitUpgrade =>
      'Estás cerca del límite de este mes. Actualiza para obtener más.';

  @override
  String get billingNearLimitResets =>
      'Estás cerca del límite de este mes. Se reinicia al inicio del próximo mes.';

  @override
  String get billingStoreUnavailable =>
      'Las actualizaciones aún no están disponibles en la tienda. Vuelve pronto.';

  @override
  String get billingManageHeading => 'Administra tu plan';

  @override
  String get billingCancelPlan => 'Cancelar suscripción';

  @override
  String get billingCancelKeepsAccess =>
      'Conservas el acceso hasta el final de este periodo de facturación.';

  @override
  String get billingCancelConfirmTitle => '¿Cancelar tu suscripción?';

  @override
  String get billingKeepPlan => 'Mantener plan';

  @override
  String get billingCancelPlanAction => 'Cancelar plan';

  @override
  String get billingBilledMonthly => 'Facturación mensual';

  @override
  String get billingBilledYearly => 'Facturación anual';

  @override
  String get billingVirtualTryOn => 'Probador virtual';

  @override
  String get billingPrioritySupport => 'Soporte prioritario';

  @override
  String get billingDisclosureProRenewing =>
      'Pro es una suscripción de renovación automática';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus y Pro son suscripciones de renovación automática';

  @override
  String get billingDisclosureAppleBilling =>
      'El pago se carga a tu Apple ID al confirmar la compra.';

  @override
  String get billingDisclosureGoogleBilling =>
      'El pago se carga a tu cuenta de Google Play al confirmar la compra.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Tu suscripción se renueva automáticamente por el mismo periodo al mismo precio a menos que desactives la renovación automática al menos 24 horas antes de que finalice el periodo actual.';

  @override
  String get billingDisclosureAppleManage =>
      'Administra o cancela cuando quieras en Configuración › tu Apple ID › Suscripciones.';

  @override
  String get billingDisclosureGoogleManage =>
      'Administra o cancela cuando quieras en Google Play › Pagos y suscripciones.';

  @override
  String get billingReferFriend => 'Invita a un amigo';

  @override
  String get billingHowItWorks => 'Cómo funciona';

  @override
  String get billingHowShareTitle => 'Comparte tu enlace';

  @override
  String get billingHowShareBody => 'Envíaselo a un amigo.';

  @override
  String get billingHowSignUpTitle => 'Se registra';

  @override
  String get billingHowSignUpBody => 'Tu amigo se une desde el enlace.';

  @override
  String get billingHowBothTitle => 'Ambos obtienen Pro';

  @override
  String get billingHowBothBody => 'Cada uno recibe un mes de Pro gratis.';

  @override
  String get billingYourReferrals => 'Tus referidos';

  @override
  String get billingInvited => 'Invitados';

  @override
  String get billingJoined => 'Unidos';

  @override
  String get billingMonthsEarned => 'Meses ganados';

  @override
  String get billingInviteFriend => 'Invitar a un amigo';

  @override
  String get billingInviteBody => 'Tú y tu amigo obtienen un mes de Pro.';

  @override
  String get billingYourCode => 'Tu código';

  @override
  String get billingCopyLink => 'Copiar enlace';

  @override
  String get billingShareInvite => 'Compartir invitación';

  @override
  String get giftUnavailable =>
      'Las invitaciones de regalo no están disponibles en esta versión.';

  @override
  String get giftPageTitle => 'Regalar FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'No hay invitaciones de regalo gratis disponibles en este momento.';

  @override
  String get giftFormTitle => 'Enviar una invitación gratis';

  @override
  String get giftFormBody =>
      'El destinatario reclama el regalo con este correo verificado. Nosotros no enviamos el correo por ti.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nombre del destinatario';

  @override
  String get giftFieldRecipientEmail => 'Correo del destinatario';

  @override
  String get giftFieldOccasion => 'Ocasión (opcional)';

  @override
  String get giftNoOccasion => 'Sin ocasión';

  @override
  String get giftOccasionBirthday => 'Cumpleaños';

  @override
  String get giftOccasionAnniversary => 'Aniversario';

  @override
  String get giftOccasionOther => 'Otro';

  @override
  String get giftFieldCardGreeting => 'Mensaje de la tarjeta';

  @override
  String get giftFieldCardGreetingHelper =>
      'Aparece en la tarjeta exactamente como lo escribas.';

  @override
  String get giftFieldPrivateNote => 'Nota privada (opcional)';

  @override
  String get giftCreateAction => 'Crear regalo gratis';

  @override
  String get giftClaimedTitle => 'Regalo reclamado';

  @override
  String get giftClaimedActive => 'Tu regalo de FitCheck Pro está activo.';

  @override
  String get giftClaimedQueued =>
      'Tu regalo de FitCheck Pro comienza al terminar tu acceso actual.';

  @override
  String get giftLinkCopied => 'Enlace de regalo copiado al portapapeles.';

  @override
  String get giftErrorName => 'Ingresa un nombre.';

  @override
  String get giftErrorEmail => 'Ingresa un correo electrónico válido.';

  @override
  String get giftErrorGreeting => 'Ingresa el mensaje de la tarjeta.';

  @override
  String get giftErrorGreetingLength => 'Usa un máximo de 80 caracteres.';

  @override
  String get giftClaimAction => 'Reclamar regalo';

  @override
  String get giftCardPreview => 'Vista previa';

  @override
  String get giftGiftForYou => 'Un regalo para ti';

  @override
  String get giftGiftWaiting => 'Tienes un regalo esperando';

  @override
  String get giftOpenBody =>
      'Abre tus regalos para reclamarlos con tu correo verificado.';

  @override
  String get giftOpenGifts => 'Abrir regalos';

  @override
  String get giftSendInvitation => 'Enviar invitación';

  @override
  String get settingsAiProviderSection => 'Proveedor';

  @override
  String get settingsAiCustom => 'Personalizado';

  @override
  String get settingsAiUrlHelper =>
      'Usa una URL pública accesible para el servidor. Localhost no funciona desde nuestros servidores.';

  @override
  String get settingsAiConnectionSection => 'Conexión';

  @override
  String get settingsAiApiUrl => 'URL de API';

  @override
  String get settingsAiApiKey => 'Clave de API';

  @override
  String get settingsAiApiKeySaved =>
      'Guardada. Déjala en blanco para conservarla.';

  @override
  String get settingsAiChatModel => 'Modelo de chat';

  @override
  String get settingsAiVisionModel => 'Modelo de visión (opcional)';

  @override
  String get settingsAiImageModel => 'Modelo de imagen (opcional)';

  @override
  String get settingsAiImageModelNote =>
      'La generación de imágenes requiere completados de chat compatibles con OpenAI y response_modalities.';

  @override
  String get settingsAiTestConnection => 'Probar conexión';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarGoToToday => 'Ir a hoy';

  @override
  String get calendarConnectTooltip => 'Conectar un calendario';

  @override
  String get calendarAddEvent => 'Agregar evento';

  @override
  String get calendarEmptyTitle => 'Sin planes';

  @override
  String get calendarEmptyBody => 'Agrega un evento y planifica qué ponerte.';

  @override
  String get calendarPreviousMonth => 'Mes anterior';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get calendarAllDay => 'Todo el día';

  @override
  String get calendarOutfitLinked => 'Conjunto vinculado';

  @override
  String get calendarEventOptions => 'Opciones de evento';

  @override
  String get calendarDeleteTitle => '¿Eliminar este evento?';

  @override
  String get calendarChangeOutfit => 'Cambiar conjunto';

  @override
  String get calendarLinkOutfit => 'Vincular un conjunto';

  @override
  String get calendarRemoveOutfit => 'Quitar conjunto';

  @override
  String get calendarNewEvent => 'Nuevo evento';

  @override
  String get calendarEditEvent => 'Editar evento';

  @override
  String get calendarTitleLabel => 'Título';

  @override
  String get calendarTitleRequired => 'Agrega un título';

  @override
  String get calendarEndBeforeStart => 'Finaliza después del inicio';

  @override
  String get calendarStarts => 'Inicia';

  @override
  String get calendarEnds => 'Finaliza';

  @override
  String get calendarPlaceOptional => 'Lugar (opcional)';

  @override
  String get calendarNotesOptional => 'Notas (opcional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Crea un conjunto y vincúlalo a este evento.';

  @override
  String get calendarBuildOutfit => 'Crear conjunto';

  @override
  String get calendarConnectionsTitle => 'Calendarios';

  @override
  String get calendarConnectionsBody =>
      'Los eventos que agregues aquí se quedan en FitCheck AI.';

  @override
  String get calendarDisconnect => 'Desconectar';

  @override
  String get calendarNotAvailable => 'Aún no disponible';

  @override
  String get profileSectionExplore => 'Explorar';

  @override
  String get profileNavTryOn => 'Probador';

  @override
  String get profileNavRewards => 'Recompensas';

  @override
  String get profileSupport => 'Soporte';

  @override
  String get profileHelp => 'Ayuda';

  @override
  String get profileAbout => 'Acerca de';

  @override
  String get profileAboutBody =>
      'Tu clóset, conjuntos y planes en un solo lugar.';

  @override
  String get profileSignOutTitle => '¿Cerrar sesión?';

  @override
  String get profileSignOutBody =>
      'Puedes iniciar sesión de nuevo cuando quieras.';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileYourProfile => 'Tu perfil';

  @override
  String get profileBodyProfiles => 'Perfiles corporales';

  @override
  String get profileBodyEmptyTitle => 'Aún no hay perfiles';

  @override
  String get profileBodyEmptyBody =>
      'Agrega tu altura y complexión para un mejor ajuste.';

  @override
  String get profileBodyAdd => 'Agregar perfil';

  @override
  String get profileBodyDefaultNote =>
      'Tu perfil predeterminado se usa para ajuste y prueba.';

  @override
  String get profileBodyDefaultBadge => 'Predeterminado';

  @override
  String get profileBodyMakeDefault => 'Hacer predeterminado';

  @override
  String get profileBodyDeleteBody => 'No puedes deshacer esto.';

  @override
  String get profileBodyRequired => 'Obligatorio';

  @override
  String get profileBodyCheckNumber => 'Revisa este número';

  @override
  String get profileBodyNew => 'Nuevo perfil corporal';

  @override
  String get profileBodyNameHint => 'Por ejemplo, Yo';

  @override
  String get profileBodyHeight => 'Altura';

  @override
  String get profileBodyWeight => 'Peso';

  @override
  String get profileBodyBuild => 'Complexión';

  @override
  String get profileBodySkinTone => 'Tono de piel';

  @override
  String get profileBirthDateNeededBody =>
      'Agrega una fecha de nacimiento junto con la hora.';

  @override
  String get profileBirthDateNeededTitle => 'Fecha de nacimiento necesaria';

  @override
  String get profilePartlySavedBody =>
      'Guardamos tu nombre y foto. Los datos de nacimiento no se guardaron; intenta más tarde.';

  @override
  String get profilePartlySavedTitle => 'Guardado parcial';

  @override
  String get profileSavedBody => 'Tu perfil está guardado.';

  @override
  String get profileChangePhoto => 'Cambiar foto de perfil';

  @override
  String get profilePhotoLabel => 'Foto de perfil';

  @override
  String get profilePhotoHint => 'Toca para elegir una nueva';

  @override
  String get profileBirthDateLabel => 'Fecha de nacimiento (opcional)';

  @override
  String get profileBirthTimeLabel => 'Hora de nacimiento (opcional)';

  @override
  String get profileBirthTimeHelper =>
      'Hace que las sugerencias védicas sean más exactas';

  @override
  String get profileBirthPlaceLabel => 'Lugar de nacimiento (opcional)';

  @override
  String get profileBirthPlaceHint => 'Por ejemplo, Ciudad de México';

  @override
  String get profileHelpContactTitle => 'Pregúntanos lo que quieras';

  @override
  String get profileHelpContactBody =>
      'Envíanos un mensaje y te responderemos por correo, por lo general en un día.';

  @override
  String get profileHelpContactAction => 'Contactar soporte';

  @override
  String get profileHelpFaqTitle => 'Preguntas frecuentes';

  @override
  String get profileFaqAddPiecesTitle => '¿Cómo agrego prendas a mi clóset?';

  @override
  String get profileFaqAddPiecesBody =>
      'Toca Agregar prenda en la pestaña Clóset. Toma una foto o elige una de tu galería; nosotros detectamos cada prenda y la etiquetamos por ti.';

  @override
  String get profileFaqMatchingTitle =>
      '¿Cómo funciona la combinación de outfits?';

  @override
  String get profileFaqMatchingBody =>
      'Abre Para ti y elige prendas que tengas. Te sugerimos con qué combinarlas y armamos outfits completos de tu clóset.';

  @override
  String get profileFaqTryOnTitle =>
      '¿Puedo usar mis propias fotos para probarme ropa?';

  @override
  String get profileFaqTryOnBody =>
      'Sí. Agrega una foto tuya de cuerpo entero y luego elige prendas para vérselas puestas.';

  @override
  String get profileFaqRewardsTitle => '¿Cómo gano recompensas?';

  @override
  String get profileFaqRewardsBody =>
      'Planifica y registra outfits con frecuencia. Las rachas y logros se acumulan conforme avanzas.';

  @override
  String get profileFaqPrivacyTitle => '¿Mi clóset es privado?';

  @override
  String get profileFaqPrivacyBody =>
      'Sí. Tu clóset y tus outfits son privados a menos que compartas el enlace de un outfit.';

  @override
  String get profileHelpMoreTitle => 'Más ayuda';

  @override
  String get profileHelpGuides => 'Guías';

  @override
  String get profileHelpGuidesBody => 'Cómo funciona cada función';

  @override
  String get feedbackCategoryBug => 'Algo falló';

  @override
  String get feedbackCategoryIdea => 'Una idea';

  @override
  String get feedbackCategoryGeneral => 'General';

  @override
  String get feedbackCategoryHelp => 'Necesito ayuda';

  @override
  String get feedbackHintBug =>
      '¿Qué pasó y qué esperabas? Los pasos nos ayudan a solucionarlo.';

  @override
  String get feedbackHintIdea => '¿Qué te gustaría y por qué?';

  @override
  String get feedbackHintGeneral => 'Cuéntanos qué piensas o haz una pregunta.';

  @override
  String get feedbackAttachmentLimitBody => 'Puedes agregar hasta 5 imágenes.';

  @override
  String get feedbackAttachmentLimitTitle => 'Límite alcanzado';

  @override
  String get feedbackImageTooLargeBody => 'Elige una imagen de menos de 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imagen muy grande';

  @override
  String get feedbackTitle => 'Enviar comentarios';

  @override
  String get feedbackAboutLabel => '¿De qué trata?';

  @override
  String get feedbackSubjectLabel => 'Asunto';

  @override
  String get feedbackSubjectRequired => 'Agrega un asunto';

  @override
  String get feedbackSubjectTooShort =>
      'El asunto debe tener al menos 3 caracteres';

  @override
  String get feedbackDetailsLabel => 'Detalles';

  @override
  String get feedbackDetailsRequired => 'Agrega algunos detalles';

  @override
  String get feedbackDetailsTooShort =>
      'La descripción debe tener al menos 10 caracteres';

  @override
  String get feedbackAddScreenshot => 'Agregar captura';

  @override
  String get feedbackAttachmentHint => 'Hasta 5, de 5 MB cada una';

  @override
  String get feedbackSend => 'Enviar';

  @override
  String get feedbackEmptyTitle => 'Aún no has enviado nada';

  @override
  String get feedbackEmptyBody => 'Lo que envíes aparecerá aquí con su estado.';

  @override
  String get feedbackHistoryTitle => 'Lo que enviaste';

  @override
  String get feedbackStatusOpen => 'Abierto';

  @override
  String get feedbackStatusInProgress => 'En progreso';

  @override
  String get feedbackStatusResolved => 'Resuelto';

  @override
  String get feedbackStatusClosed => 'Cerrado';

  @override
  String get legalIntro =>
      'Cómo protegemos tus datos y los términos para usar FitCheck AI.';

  @override
  String get legalPolicies => 'Políticas';

  @override
  String get legalPrivacySubtitle => 'Qué recopilamos y por qué';

  @override
  String get legalTermsTitle => 'Términos de servicio';

  @override
  String get legalTermsSubtitle => 'Las reglas para usar la app';

  @override
  String get legalLicences => 'Licencias de código abierto';

  @override
  String get legalSupportSubtitle =>
      'Ayuda, contacto y solicitudes de privacidad';

  @override
  String get legalReportAbuse => 'Reportar un problema o abuso';

  @override
  String get permissionCameraTitle => 'Acceso a la cámara';

  @override
  String get permissionCameraRationale =>
      'FitCheck AI usa tu cámara para tomar fotos de tu ropa y conjuntos para el probador virtual y organizar tu clóset.';

  @override
  String get permissionPhotoTitle => 'Acceso a fotos';

  @override
  String get permissionPhotoRationale =>
      'FitCheck AI necesita acceso a tus fotos para que puedas seleccionar imágenes de ropa para las funciones de IA y tu clóset.';

  @override
  String get permissionNotNow => 'Ahora no';

  @override
  String get permissionOpenSettings => 'Abrir configuración';

  @override
  String authSignedInAs(String name) {
    return 'Iniciado sesión como $name';
  }

  @override
  String get authSignedIn => 'Sesión iniciada';

  @override
  String get authWelcomeBackTitle => 'Te damos la bienvenida';

  @override
  String get authSignInFailed => 'Error al iniciar sesión';

  @override
  String get authWelcomeTitle => 'Bienvenida';

  @override
  String get authSignUpFailed => 'Error al registrarse';

  @override
  String get authGoogleSignInFailed => 'Error al iniciar sesión con Google';

  @override
  String get authAppleSignInFailed => 'Error al iniciar sesión con Apple';

  @override
  String get authConfirmEmailTitle => 'Confirma tu correo';

  @override
  String get authConfirmEmailBody =>
      'Revisa tu bandeja de entrada para confirmar tu correo y luego inicia sesión.';

  @override
  String get authClosetReady => 'Tu clóset está listo.';

  @override
  String get authSignedOutTitle => 'Sesión cerrada';

  @override
  String get authSignedOutBody => 'Has cerrado sesión.';

  @override
  String get authSignOutFailed => 'Error al cerrar sesión';

  @override
  String get authEmailSentTitle => 'Correo enviado';

  @override
  String get authResetLinkSent =>
      'Revisa tu correo para ver el enlace de recuperación.';

  @override
  String get authPasswordUpdatedTitle => 'Contraseña actualizada';

  @override
  String get authPasswordUpdated => 'Tu contraseña ha sido actualizada.';

  @override
  String get authPasswordNotUpdated => 'Contraseña no actualizada';

  @override
  String get authCouldNotSendEmail => 'No se pudo enviar el correo';

  @override
  String get authEmailNotSent => 'Correo no enviado';

  @override
  String get authResendSentBody => 'Enviamos un nuevo correo de confirmación.';

  @override
  String get outfitPreviewWithAi => 'Vista previa con IA';

  @override
  String get outfitNewPreview => 'Nueva vista previa';

  @override
  String get outfitBuilderClosetHeading => 'Tu clóset';

  @override
  String get outfitBuilderSearchHint => 'Buscar prendas';

  @override
  String get outfitClearSearch => 'Borrar búsqueda';

  @override
  String get outfitBuilderAddPiecesTitle => 'Agrega prendas primero';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Los looks se crean con las prendas de tu clóset.';

  @override
  String get outfitBuilderNoMatches => 'No hay prendas que coincidan.';

  @override
  String get outfitNameLabel => 'Nombre del look';

  @override
  String get outfitNameHint => 'Por ejemplo, Lino de fin de semana';

  @override
  String get outfitPreviewSemantic => 'Vista previa del look con IA';

  @override
  String get outfitChoosePieces => 'Elige prendas';

  @override
  String get outfitTapPiecesHint =>
      'Toca las prendas de abajo para agregarlas.';

  @override
  String get outfitShareTooltip => 'Compartir';

  @override
  String get outfitSaveFavourite => 'Guardar en favoritos';

  @override
  String get outfitPiecesHeading => 'Prendas';

  @override
  String get outfitWearHistoryEmpty => 'Úsalo una vez y verás las fechas aquí.';

  @override
  String get outfitWearHistoryTitle => 'Historial de uso';

  @override
  String get outfitWearHistoryError => 'No se pudieron cargar las fechas.';

  @override
  String get outfitWornOn => 'Usado el';

  @override
  String get outfitEditTitle => 'Editar look';

  @override
  String get outfitSavedPhotosFailed => 'Detalles guardados, fotos no';

  @override
  String get outfitNoPhotosBody =>
      'Aún no hay fotos. El look mostrará sus prendas.';

  @override
  String get outfitOccasionLabel => 'Ocasión';

  @override
  String get outfitOccasionNone => 'Ninguna';

  @override
  String get outfitTagsHint => 'Separa con comas';

  @override
  String get outfitDraftBody => 'Oculto de tu lista principal';

  @override
  String get outfitPublic => 'Público';

  @override
  String get outfitPublicBody => 'Cualquiera con el enlace puede verlo';

  @override
  String get outfitDeleteFromDetail =>
      'Eliminar este look de su página de detalle.';

  @override
  String get outfitNewCollection => 'Nueva colección';

  @override
  String get outfitNoCollectionsTitle => 'Aún no hay colecciones';

  @override
  String get outfitNoCollectionsBody =>
      'Agrupa atuendos por viaje, estación o estado de ánimo.';

  @override
  String get outfitCreateCollection => 'Crear colección';

  @override
  String get outfitAddOutfits => 'Agregar atuendos';

  @override
  String get outfitRename => 'Renombrar';

  @override
  String get outfitCollectionDeleteBody => 'Los atuendos se conservan.';

  @override
  String get outfitCollectionsNotLoaded => 'Atuendos no cargados';

  @override
  String get outfitRenameCollection => 'Renombrar colección';

  @override
  String get outfitDescriptionOptional => 'Descripción (opcional)';

  @override
  String get outfitAllInCollection =>
      'Todos los atuendos ya están en esta colección.';

  @override
  String get photoshootSubtitleUpload =>
      'Retratos de estudio a partir de tus fotos';

  @override
  String get photoshootSubtitleConfigure => 'Elige estilo, formato y cantidad';

  @override
  String get photoshootSubtitleGenerating => 'Esto toma de un a dos minutos';

  @override
  String get photoshootAddPhotosSemantic => 'Agregar fotos desde tu galería';

  @override
  String get photoshootUploadTitle => 'Agrega de 1 a 4 fotos tuyas';

  @override
  String get photoshootUploadBody => 'Toca para elegir de tu galería';

  @override
  String get photoshootAddToContinue => 'Agrega una foto para continuar';

  @override
  String get photoshootAddAnotherPhoto => 'Agregar otra foto';

  @override
  String get photoshootTipsTitle => 'Para mejores resultados';

  @override
  String get photoshootTipsBody =>
      'Usa fotos claras, con buena iluminación y de tu rostro desde varios ángulos. Evita lentes de sol y sombreros.';

  @override
  String get photoshootStarting => 'Iniciando';

  @override
  String get photoshootCancelling => 'Cancelando';

  @override
  String get photoshootFailed => 'Fallido';

  @override
  String get recommendTabMatches => 'Combinaciones';

  @override
  String get recommendTabComplete => 'Completo';

  @override
  String get recommendTabWeather => 'Clima';

  @override
  String get recommendTabColours => 'Colores';

  @override
  String get recommendTabShop => 'Tienda';

  @override
  String get recommendNoMatchesTitle => 'Aún no hay combinaciones';

  @override
  String get recommendNoMatchesBody =>
      'Elige una prenda y te diremos qué combina.';

  @override
  String get recommendPickPiece => 'Elige una prenda';

  @override
  String get recommendNothingMatchesTitle => 'Nada combina aún';

  @override
  String get recommendNothingMatchesBody =>
      'Prueba con otras prendas o agrega más a tu clóset.';

  @override
  String get recommendChangePieces => 'Cambiar prendas';

  @override
  String get recommendDefaultReason => 'Le va bien a las prendas que elegiste.';

  @override
  String get recommendCompleteTitle => 'Completa el look';

  @override
  String get recommendCompleteBody =>
      'Elige una prenda y completaremos el resto.';

  @override
  String get recommendWorking => 'Procesando';

  @override
  String get recommendGenerate => 'Generar';

  @override
  String get recommendChooseStyleBody => 'Elige un estilo y genera.';

  @override
  String get recommendNoLooksTitle => 'Sin looks para estas prendas';

  @override
  String get recommendNoLooksBody => 'Prueba otro estilo u otras prendas.';

  @override
  String get recommendDefaultLook => 'Un look para tus prendas';

  @override
  String get recommendNoPiecesBody => 'No hay prendas para este look.';

  @override
  String get recommendCityLabel => 'Ciudad';

  @override
  String get recommendCheck => 'Verificar';

  @override
  String get recommendWeatherTitle => '¿Qué tiempo hace?';

  @override
  String get recommendWeatherBody =>
      'Ingresa tu ciudad para sugerencias de hoy.';

  @override
  String get recommendWearToday => 'Usa hoy';

  @override
  String get recommendWeatherNoPieces =>
      'Aún no hay prendas en tu clóset para este clima.';

  @override
  String get recommendBudgetLabel => 'Presupuesto de hasta';

  @override
  String get recommendLooking => 'Buscando';

  @override
  String get recommendFindWhatToBuy => 'Encuentra qué comprar';

  @override
  String get recommendFillGapsTitle => 'Completa lo que falta';

  @override
  String get recommendFillGapsBody =>
      'Define un presupuesto y te sugeriremos qué le falta a tu clóset.';

  @override
  String get recommendNoGapsTitle => 'Sin faltantes';

  @override
  String get recommendNoGapsBody =>
      'Prueba con un presupuesto mayor u otra categoría.';

  @override
  String get recommendMoodEveryday => 'Diario';

  @override
  String get recommendMoodBigMeeting => 'Reunión importante';

  @override
  String get recommendDayLabel => 'Día';

  @override
  String get recommendReadingStars => 'Leyendo las estrellas';

  @override
  String get recommendGetMyColours => 'Descubre mis colores';

  @override
  String get recommendLuckyColoursTitle => 'Tus colores de la suerte';

  @override
  String get recommendLuckyColoursBody =>
      'Elige un día y te sugeriremos colores y prendas.';

  @override
  String get recommendLuckyColoursSection => 'Colores de la suerte';

  @override
  String get recommendAvoidColoursSection => 'Colores a moderar';

  @override
  String get recommendBirthDateTitle => 'Agrega tu fecha de nacimiento';

  @override
  String get recommendBirthDateBody =>
      'Necesitamos tu fecha de nacimiento para analizar tus colores.';

  @override
  String get recommendEditProfile => 'Editar perfil';

  @override
  String get recommendNothingThisDay => 'No hay nada para hoy.';

  @override
  String get recommendUnnamedColour => 'Color sin nombre';

  @override
  String get recommendFromCloset => 'De tu clóset';

  @override
  String get recommendNoPiecesInColours =>
      'Aún no hay prendas en estos colores.';

  @override
  String get recommendOutfitIdeas => 'Ideas de outfits';

  @override
  String get recommendNoOutfitsInColours =>
      'Aún no hay un outfit completo en estos colores.';

  @override
  String get recommendDefaultOutfitIdea => 'Idea de outfit';

  @override
  String get recommendPickUpToThree => 'Elige hasta tres prendas';

  @override
  String get recommendEmptyClosetBody =>
      'Agrega algunas prendas primero, luego vuelve a combinar.';

  @override
  String get dashboardDressForDay => 'Vístete para el día.';

  @override
  String get dashboardOutfitOfDay => 'Outfit del día';

  @override
  String get dashboardFreshLook => 'Un look nuevo';

  @override
  String get subscriptionManageInStoreTitle => 'Gestionar en la tienda';

  @override
  String get subscriptionManageInStoreBody =>
      'Este plan se cobra a través de la tienda. Gestiona tu cuenta en la configuración de la tienda.';

  @override
  String get subscriptionCancelledTitle => 'Suscripción cancelada';

  @override
  String get subscriptionCancelledBody =>
      'Tu plan sigue activo hasta el final del periodo de facturación.';

  @override
  String get subscriptionCancelFailedTitle => 'No se pudo cancelar';

  @override
  String get subscriptionCouldNotOpenTitle => 'No se pudo abrir';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'No se pudo abrir la gestión de facturación.';

  @override
  String get subscriptionOpenLinkFailedBody => 'No se pudo abrir el enlace.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'No se pudo cargar tu enlace';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'No se pudo cargar tu enlace de referencia. Intenta de nuevo.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiado';

  @override
  String get subscriptionReferralCopiedBody => 'Enlace de referencia copiado.';

  @override
  String get subscriptionReferralShareSubject => 'Prueba FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Únete a FitCheck AI y ambos recibimos un mes de Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Enlace copiado';

  @override
  String get subscriptionShareUnavailableBody =>
      'No está disponible compartir, así que copiamos el enlace.';

  @override
  String get subscriptionShareFailedTitle => 'No se pudo compartir';

  @override
  String get subscriptionShareFailedBody =>
      'Copia el enlace desde la página de referencia.';

  @override
  String get subscriptionStoreReadyTitle => 'Tienda lista';

  @override
  String get subscriptionStoreReadyBody =>
      'Precios de la tienda disponibles. Ya puedes mejorar tu plan.';

  @override
  String get purchaseFailedTitle => 'Compravión fallida';

  @override
  String get purchaseUnavailableTitle => 'Compra no disponible';

  @override
  String get purchaseIapUnavailableBody =>
      'Las compras dentro de la app no están disponibles en este dispositivo.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Este plan aún no está disponible para su compra.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Este plan aún no está disponible en la tienda. Vuelve a intentarlo pronto.';

  @override
  String get purchaseStartFailedBody =>
      'No se pudo iniciar la compra. Intenta de nuevo.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'El pago no devolvió un enlace de pago.';

  @override
  String get purchasePendingTitle => 'Compra pendiente';

  @override
  String get purchasePendingBody =>
      'Tu compra espera aprobación. Tendrás acceso en cuanto se apruebe.';

  @override
  String get purchaseFailedBody => 'La compra falló. Intenta de nuevo.';

  @override
  String get purchaseRestoredTitle => 'Restaurado';

  @override
  String get purchaseRestoredBody => 'Tus compras fueron restauradas.';

  @override
  String get purchaseActiveTitle => 'Suscripción activa';

  @override
  String get purchaseActiveBody => 'Tu suscripción está activa. Bienvenido.';

  @override
  String get purchaseSignInRequiredTitle => 'Inicia sesión';

  @override
  String get purchaseSignInRequiredBody =>
      'Inicia sesión para completar tu compra.';

  @override
  String get purchaseErrorTitle => 'Error en compra';

  @override
  String get purchaseInvalidTransactionBody =>
      'La compra no incluyó un ID de transacción verificable.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificación pendiente';

  @override
  String get purchaseVerificationPendingBody =>
      'No pudimos verificar tu compra en la tienda en este momento. Se completará automáticamente y no te cobraremos dos veces.';

  @override
  String get purchaseNotAppliedTitle => 'Compra no aplicada';

  @override
  String get purchaseNotAppliedBody =>
      'No fue posible aplicar tu compra a tu cuenta. Contacta a soporte y no la compres de nuevo.';

  @override
  String get purchaseRestoreFailedTitle => 'Restauración fallida';

  @override
  String get purchaseRestoreFailedBody =>
      'No se pudieron restaurar las compras. Inténtalo de nuevo.';

  @override
  String get purchaseRecoveredActiveBody => 'Tu suscripción está activa.';

  @override
  String get purchaseCompleteTitle => 'Compra completa';

  @override
  String get giftCreateFailedTitle => 'No se pudo crear el regalo';

  @override
  String get giftClaimFailedTitle => 'No se pudo reclamar el regalo';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count regalos para ti',
      one: 'Un regalo para ti',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mes',
      '12': '1 año',
      'other': '$months meses',
    });
    return '$_temp0';
  }

  @override
  String giftAllowanceChip(String duration, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining restantes',
      one: '1 restante',
    );
    return '$duration, $_temp0';
  }

  @override
  String giftDurationOfPro(String duration) {
    return '$duration de FitCheck Pro';
  }

  @override
  String giftShareMessage(String sender, String duration, String link) {
    return '$sender te envió $duration de FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Un regalo de FitCheck Pro para $recipient';
  }

  @override
  String giftFromSender(String sender) {
    return 'De $sender';
  }

  @override
  String giftPreviewFor(String recipient) {
    return 'Para $recipient';
  }

  @override
  String giftPreviewFrom(String sender) {
    return 'De $sender';
  }

  @override
  String get giftPreviewPlaceholderRecipient => 'tu destinatario';

  @override
  String get giftPreviewPlaceholderSender => 'tú';

  @override
  String get settingsSavedTitle => 'Guardado';

  @override
  String get settingsNotSavedTitle => 'No guardado';

  @override
  String get settingsAiChooseProviderBody => 'Elige un proveedor.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Un proveedor personalizado requiere una URL de API.';

  @override
  String get settingsAiKeyRequiredBody => 'Ingresa una clave de API.';

  @override
  String get settingsAiSavedBody => 'Tu configuración de IA se guardó.';

  @override
  String get settingsAiMissingDetailsTitle => 'Faltan detalles';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Ingresa una URL de API y un modelo de chat para probar.';

  @override
  String get settingsAiKeyNeededTitle => 'Se requiere clave de API';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Ingresa tu clave API para probar. Tu clave guardada permanece privada.';

  @override
  String get settingsAiKeyToTestBody => 'Ingresa tu clave API para probar.';

  @override
  String get settingsAiConnectedTitle => 'Conectado';

  @override
  String get settingsAiConnectedBody => 'La conexión funciona.';

  @override
  String get settingsAiTestFailedTitle => 'Prueba fallida';

  @override
  String get settingsPreferencesSavedBody => 'Tus preferencias se guardaron.';

  @override
  String get settingsPasswordNotChangedTitle => 'Contraseña no cambiada';

  @override
  String get settingsOAuthPasswordBody =>
      'Esta cuenta inicia sesión con Google o Apple. Usa \"Olvidé mi contraseña\" para establecer una contraseña primero.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'La contraseña actual es incorrecta.';

  @override
  String get settingsExportReadyTitle => 'Exportación lista';

  @override
  String get settingsExportReadyBody =>
      'Tu exportación de datos está lista para descargar.';

  @override
  String get settingsLinkCopiedTitle => 'Enlace copiado';

  @override
  String get settingsExportClipboardBody =>
      'No pudimos abrir tu navegador, copiamos el enlace de descarga. Pégalo en un navegador pronto: caduca.';

  @override
  String get settingsExportFailedTitle => 'Exportación fallida';

  @override
  String get settingsAccountNotDeletedTitle => 'Cuenta no eliminada';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Puedes agregar hasta $max fotos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Límite de fotos';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Agrega al menos una foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Sin fotos';

  @override
  String get photoshootDescribeLookBody => 'Describe el look que deseas.';

  @override
  String get photoshootPromptNeededTitle => 'Se necesita indicación';

  @override
  String get photoshootConsentFeatureLabel => 'Sesión de fotos IA';

  @override
  String get photoshootStatusPreparing => 'Preparando tus fotos';

  @override
  String get photoshootStatusGenerating => 'Generando';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lote $current de $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done de $total listas';
  }

  @override
  String get photoshootGenerationFailedBody => 'La generación falló.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready listas, $failed fallidas.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Parcialmente listo';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos están listas.',
      one: '1 foto está lista.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Perdimos la conexión. Inténtalo de nuevo.';

  @override
  String get photoshootCouldNotCancelTitle => 'No se pudo cancelar';

  @override
  String get photoshootRetryFailedTitle => 'Reintento fallido';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'La foto $number está lista.';
  }

  @override
  String get photoshootReplacedTitle => 'Reemplazada';

  @override
  String get photoshootSavedToGalleryBody => 'Guardada en tu galería.';

  @override
  String get photoshootSavedTitle => 'Guardado';

  @override
  String get photoshootNotSavedTitle => 'No guardado';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Las $count fotos están en tu galería.',
      one: '1 foto está en tu galería.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved de $total guardadas.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Algunas fotos no guardadas';

  @override
  String get tryonConsentFeatureLabel => 'Prueba virtual';

  @override
  String get tryonAvatarUpdatedBody => 'Tu foto está actualizada.';

  @override
  String get tryonSavedTitle => 'Guardado';

  @override
  String get tryonUploadFailedTitle => 'Carga fallida';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Elige primero la foto de la prenda.';

  @override
  String get tryonNoGarmentTitle => 'Sin prenda';

  @override
  String get tryonWaitForUploadBody =>
      'Espera a que termine de cargarse tu foto.';

  @override
  String get tryonStillUploadingTitle => 'Sigue cargando';

  @override
  String get tryonAddYourPhotoFirstBody => 'Añade primero una foto tuya.';

  @override
  String get tryonReadyBody => 'Tu prueba virtual está lista.';

  @override
  String get tryonFailedTitle => 'La prueba falló';

  @override
  String get tryonSavedToGalleryBody => 'Guardada en tu galería.';

  @override
  String get tryonNotSavedTitle => 'No guardado';

  @override
  String get calendarEventAddedBody => 'Evento añadido';

  @override
  String get calendarEventPlannedTitle => 'Planificado';

  @override
  String get calendarEventSavedBody => 'Evento guardado';

  @override
  String get calendarSavedTitle => 'Guardado';

  @override
  String get calendarEventNotSavedTitle => 'Evento no guardado';

  @override
  String get calendarEventRemovedBody => 'Evento eliminado';

  @override
  String get calendarEventDeletedTitle => 'Eliminado';

  @override
  String get calendarEventNotDeletedTitle => 'Evento no eliminado';

  @override
  String get calendarOutfitNotLinkedTitle => 'Outfit no vinculado';

  @override
  String get calendarLinkedTitle => 'Vinculado';

  @override
  String get calendarOutfitNotRemovedTitle => 'Outfit no eliminado';

  @override
  String get calendarOutfitRemovedBody => 'Outfit eliminado';

  @override
  String get calendarDisconnectedBody => 'Calendario desvinculado';

  @override
  String get calendarDisconnectedTitle => 'Desvinculado';

  @override
  String get calendarNotDisconnectedTitle => 'Calendario no desvinculado';

  @override
  String get calendarTodayLabel => 'hoy';

  @override
  String calendarEventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos',
      one: '1 evento',
    );
    return '$_temp0';
  }

  @override
  String calendarTimeRange(String start, String end) {
    return 'de $start a $end';
  }

  @override
  String calendarEventSemantic(String title, String time) {
    return '$title, $time';
  }

  @override
  String calendarEventSemanticWithOutfit(String title, String time) {
    return '$title, $time, outfit vinculado';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '\"$title\" se eliminará.';
  }

  @override
  String get calendarThisAppLabel => 'Esta app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'La sincronización con $provider aún no está disponible. Puedes seguir agregando eventos aquí.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dom';

  @override
  String get calendarWeekdayMonShort => 'Lun';

  @override
  String get calendarWeekdayTueShort => 'Mar';

  @override
  String get calendarWeekdayWedShort => 'Mié';

  @override
  String get calendarWeekdayThuShort => 'Jue';

  @override
  String get calendarWeekdayFriShort => 'Vie';

  @override
  String get calendarWeekdaySatShort => 'Sáb';

  @override
  String get calendarWeekdayMonday => 'Lunes';

  @override
  String get calendarWeekdayTuesday => 'Martes';

  @override
  String get calendarWeekdayWednesday => 'Miércoles';

  @override
  String get calendarWeekdayThursday => 'Jueves';

  @override
  String get calendarWeekdayFriday => 'Viernes';

  @override
  String get calendarWeekdaySaturday => 'Sábado';

  @override
  String get calendarWeekdaySunday => 'Domingo';

  @override
  String get outfitSavedToFavouritesBody => 'Guardado en favoritos';

  @override
  String get outfitRemovedFromFavouritesBody => 'Eliminado de favoritos';

  @override
  String get outfitNotSavedTitle => 'No guardado';

  @override
  String get outfitLoggedAsWornBody => 'Registrado como usado hoy.';

  @override
  String get outfitNicePickTitle => 'Buen gusto';

  @override
  String get outfitRemovedBody => 'Look eliminado.';

  @override
  String get outfitDeletedTitle => 'Eliminado';

  @override
  String get outfitNotDeletedTitle => 'No eliminado';

  @override
  String get outfitDuplicatedBody => 'Una copia está en tus looks.';

  @override
  String get outfitDuplicatedTitle => 'Duplicado';

  @override
  String get outfitNotDuplicatedTitle => 'No duplicado';

  @override
  String get outfitNotSharedTitle => 'No compartido';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" está listo.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Colección no creada';

  @override
  String get outfitCollectionUpdatedBody => 'Colección actualizada.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Colección no actualizada';

  @override
  String get outfitCollectionDeletedBody => 'Colección eliminada.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Colección no eliminada';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count looks agregados.',
      one: '1 look agregado.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Looks no agregados';

  @override
  String get outfitPreviewNotCreatedTitle => 'Vista previa no creada';

  @override
  String get outfitGiveNameBody => 'Dale un nombre al look.';

  @override
  String get outfitNameMissingTitle => 'Nombre';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Elige al menos una prenda.';

  @override
  String outfitCreatedBody(String name) {
    return '$name está en tus looks.';
  }

  @override
  String get outfitSavedTitle => 'Guardado';

  @override
  String get wardrobeAddedToFavouritesBody => 'Agregado a favoritos';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Eliminado de favoritos';

  @override
  String get wardrobeNotSavedTitle => 'No guardado';

  @override
  String get wardrobeLoggedAsWornBody => 'Registrado como usado hoy.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Se eliminó de tu clóset.';

  @override
  String get wardrobeDeletedTitle => 'Eliminado';

  @override
  String get wardrobeNotDeletedTitle => 'No se eliminó';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prendas eliminadas de tu clóset.',
      one: '1 prenda eliminada de tu clóset.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extracción de clóset con IA';

  @override
  String get itemAddScanJobLabel => 'Escanear';

  @override
  String get itemAddFoundEarlierBody => 'Encontrado en un escaneo anterior';

  @override
  String get itemAddLookingAtPhoto => 'Analizando tu foto';

  @override
  String get itemAddExtractionFailedBody => 'Error de extracción';

  @override
  String get itemAddJobFailedBody => 'Error en el proceso';

  @override
  String get itemAddConnectionLostBody =>
      'Se perdió la conexión. Inténtalo de nuevo.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Conexión perdida durante el procesamiento.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Prenda $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Prenda';

  @override
  String get itemAddNotCancelledTitle => 'No se canceló';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prendas en tu clóset.',
      one: '1 prenda en tu clóset.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved de $total prendas guardadas. Toca guardar para intentar el resto.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle =>
      'Algunas prendas no se guardaron';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Elige al menos una foto.';

  @override
  String get batchPhotoUnreadableBody => 'No se pudo leer esta foto.';

  @override
  String get batchNoPhotosReadableBody =>
      'No se pudieron leer estas fotos. Prueba con otras.';

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
      'Perdimos la conexión mientras trabajaba. Inténtalo de nuevo.';

  @override
  String get batchNotCancelledTitle => 'No se canceló';

  @override
  String get batchPostLinkUnsupportedBody =>
      'No se admiten enlaces de publicaciones. Escribe un enlace de perfil.';

  @override
  String get batchLinkSpacesBody => 'Los enlaces no pueden contener espacios.';

  @override
  String get batchEnterProfileLinkBody =>
      'Escribe un enlace de perfil de Instagram o Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Escribe un enlace de perfil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'No se abrió la página de inicio de sesión. Inténtalo de nuevo.';

  @override
  String get batchSignInBrowserBody =>
      'Inicia sesión en tu navegador y luego regresa a FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Conecta tu cuenta';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Ingresa el código de tu app de autenticación.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'Instagram requiere una verificación de seguridad. Primero inicia sesión en tu navegador.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Ingresa tu nombre de usuario y contraseña de nuevo.';

  @override
  String get batchSignInFailedBody =>
      'No se inició la sesión. Revisa tu nombre de usuario y contraseña.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Inicia sesión para continuar importando.';

  @override
  String get batchAccountNotConnectedBody => 'Tu cuenta no se conectó.';

  @override
  String get batchAccountConnectedTitle => 'Cuenta conectada';

  @override
  String get batchNotConnectedTitle => 'No conectado';

  @override
  String get batchImportConnectionLostBody =>
      'Perdimos la conexión con la importación. Actualiza para verificarla.';

  @override
  String batchPickUpToBody(int max) {
    return 'Elige hasta $max fotos. Encontramos las prendas.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count de $total fotos';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'Preparando la foto $done de $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encontrar prendas en $count fotos',
      one: 'Encontrar prendas en 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Tu cuenta de $platform usa verificación en dos pasos. Ingresa el código de 6 dígitos de tu app de autenticación.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Este perfil de $platform es privado o requiere inicio de sesión para mostrar sus fotos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Conectar con $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos encontradas hasta ahora',
      one: '1 foto encontrada hasta ahora',
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
    return '$processed de $total procesadas · $added agregadas · $waiting en espera · $skipped omitidas';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Analizando la foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'La foto $number es la siguiente';
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
      other: '$count prendas encontradas',
      one: '1 prenda encontrada',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos se agregaron a tu clóset.',
      one: '1 foto se agregó a tu clóset.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos de estudio más en camino. Puedes guardar lo que esté listo o salir: te avisaremos.',
      one:
          '1 foto de estudio más en camino. Puedes guardar lo que esté listo o salir: te avisaremos.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Aún no guardado: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces prendas',
      one: '1 prenda',
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
    return '$chosen elegidas. Toca una prenda para omitirla.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardando $count prendas',
      one: 'Guardando 1 prenda',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count prendas',
      one: 'Guardar 1 prenda',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Tu perfil de cuerpo se guardó.';

  @override
  String get bodyProfileSavedTitle => 'Guardado';

  @override
  String get bodyProfileNotSavedTitle => 'No se guardó';

  @override
  String get bodyProfileSetDefaultBody =>
      'Configurar como tu perfil predeterminado.';

  @override
  String get bodyProfileDeletedBody => 'Perfil de cuerpo eliminado.';

  @override
  String get bodyProfileDeletedTitle => 'Eliminado';

  @override
  String get bodyProfileNotDeletedTitle => 'No se eliminó';

  @override
  String get feedbackNotSentTitle => 'No enviado';

  @override
  String get feedbackSentBody =>
      'Gracias. Leemos cada mensaje y respondemos si necesitamos más detalles.';

  @override
  String get feedbackSentTitle => 'Comentario enviado';

  @override
  String get recommendUnnamedPiece => 'Prenda sin nombre';

  @override
  String get recommendEnterCityBody =>
      'Ingresa tu ciudad para obtener recomendaciones según el clima.';

  @override
  String get recommendWhichCityTitle => '¿Qué ciudad?';

  @override
  String get aiConsentSheetTitle => 'Compartir fotos con un servicio de IA';

  @override
  String get aiConsentSheetBody =>
      'Para crear tus imágenes de prueba de vestimenta y sesión de fotos, FitCheck AI envía las fotos que proporcionas (incluyendo imágenes de tu rostro y cuerpo) a un proveedor de IA de confianza (como OpenAI o Google Gemini) para su procesamiento. Ellos generan tus imágenes y no las usan para entrenar sus modelos bajo nuestros términos. Las fotos se transmiten de forma segura y nunca se comparten para publicidad.';

  @override
  String get aiConsentSheetPermission =>
      'Al continuar, otorgas permiso explícito para compartir tus fotos con estos proveedores de IA para generación de imágenes.';

  @override
  String get skeletonsLoadMoreFailed => 'No se pudo cargar más.';

  @override
  String get jobsPiecesReadyTitle => 'Tus prendas están listas';

  @override
  String get jobsScanStoppedTitle => 'El escaneo se detuvo';

  @override
  String get jobsNothingSavedBody => 'No se guardó nada. Inténtalo de nuevo.';

  @override
  String get jobsPhotoUploadFailedBody => 'Fallo al subir la foto.';

  @override
  String get authGoogleSignInStartFailed =>
      'No se pudo iniciar la entrada con Google. Inténtalo de nuevo.';

  @override
  String get referralAppliedTitle => 'Referencia aplicada';

  @override
  String get billingStoreUnavailableBody =>
      'Las compras en la tienda no están disponibles en este dispositivo.';

  @override
  String get billingPurchaseProcessingBody =>
      'Esta compra aún está en proceso. Reabre la app en un minuto para ver tu plan.';

  @override
  String get profileAvatarUploadNoUrl =>
      'La subida de avatar no devolvió una URL de imagen.';

  @override
  String get rewardsDayStreakLabel => 'días seguidos';

  @override
  String rewardsBestStreak(int days) {
    return 'Mejor racha de $days días';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Se requiere acceso a $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'El acceso a $permission está denegado. Abre Ajustes para permitirlo y luego vuelve a intentarlo.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Paso $step de 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Quitar imagen $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Quitar imagen $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Escribe a $email. Revisamos reportes en 24 horas.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Quitar $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Agregar a \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" se eliminó. Sus piezas permanecen en tu clóset.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Ver los $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restantes hoy';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Fallo la foto $index';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected de $max fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Complexión $shape · Piel $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opciones para $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Más usado: $name, $count veces';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: no definido';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% de coincidencia';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked de $max seleccionados';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Quitar $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioridad $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Este plan se factura a través de $store. Modifícalo o cancela en la configuración de tu cuenta de $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gestionar en $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current de $max usado';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Faltan ${seconds}s aprox.';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done de $total fotos de estudio listas';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready de $total fotos de estudio listas. Toca una prenda para omitirla.';
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
