// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Início';

  @override
  String get tabPhotoshoot => 'Fotos';

  @override
  String get tabCloset => 'Closet';

  @override
  String get tabOutfits => 'Looks';

  @override
  String get tabMore => 'Mais';

  @override
  String get actionAddItem => 'Adicionar item';

  @override
  String get actionCreateOutfit => 'Criar look';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionNext => 'Próximo';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get stateLoading => 'Carregando';

  @override
  String get stateErrorTitle => 'Algo deu errado';

  @override
  String get stateErrorBody =>
      'Tente novamente. Se o erro persistir, contate o suporte.';

  @override
  String get stateOfflineTitle => 'Você está offline';

  @override
  String get stateOfflineBody =>
      'Conecte-se para sincronizar seu closet e gerar looks.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAccountSection => 'Conta';

  @override
  String get settingsPreferencesSection => 'Preferências';

  @override
  String get settingsPlanBilling => 'Plano e pagamento';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsUnits => 'Unidades de medida';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsPrivacySection => 'Privacidade e dados';

  @override
  String get settingsAboutSection => 'Sobre';

  @override
  String get settingsSignOut => 'Sair';

  @override
  String get settingsDeleteAccount => 'Excluir conta';

  @override
  String get settingsDeleteAccountTitle => 'Excluir sua conta?';

  @override
  String get settingsDeleteAccountBody =>
      'Isso removerá seu guarda-roupa, looks, fotos e perfil. Esta ação não pode ser desfeita.';

  @override
  String get settingsUnitsImperial => 'Imperial (pol, lb)';

  @override
  String get settingsUnitsMetric => 'Métrico (cm, kg)';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Usar idioma do dispositivo';

  @override
  String get languageSystemBody =>
      'O FitCheck AI segue o idioma do seu celular.';

  @override
  String get languageSearchHint => 'Buscar idiomas';

  @override
  String get languageCurrent => 'Atual';

  @override
  String get languageReviewNote =>
      'Esta tradução é nova. Avise-nos se algo parecer incorreto.';

  @override
  String get languageChanged => 'Idioma atualizado';

  @override
  String get paywallTitle => 'Escolha seu plano';

  @override
  String get paywallTrialBadge => '1 mês grátis';

  @override
  String get paywallTrialTitle => 'Seu primeiro mês de Pro é grátis';

  @override
  String get paywallTrialBody =>
      'Envie todo o seu guarda-roupa de uma vez. Adicione peças conforme necessário depois.';

  @override
  String get paywallFreeForeverTitle => 'Grátis para sempre';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Sem cartão. Todo mês você recebe $uploads envios por IA, $outfits looks e $images fotos de ensaio por dia.';
  }

  @override
  String get paywallCtaTrial => 'Iniciar meu mês grátis';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Assinar $plan';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallManage => 'Gerenciar assinatura';

  @override
  String get paywallTerms => 'Termos de uso';

  @override
  String get paywallPrivacy => 'Política de privacidade';

  @override
  String get paywallPerMonth => 'por mês';

  @override
  String get paywallPerYear => 'por ano';

  @override
  String get paywallBestValue => 'Melhor custo-benefício';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Teste grátis apenas para novos assinantes. Após o período de teste, o Pro renova por $price, a menos que seja cancelado com pelo menos 24 horas de antecedência.';
  }

  @override
  String get introTitle => 'Seu guarda-roupa, finalmente organizado';

  @override
  String get introBody =>
      'Fotografe suas roupas uma vez. Receba ideias de looks, prévias de prova e fotos de estúdio com o que você já tem.';

  @override
  String get introStart => 'Começar';

  @override
  String get introHaveAccount => 'Já tenho uma conta';

  @override
  String get introSkip => 'Pular';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authSignUp => 'Criar conta';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Senha';

  @override
  String get authForgotPassword => 'Esqueceu a senha?';

  @override
  String get authContinueApple => 'Continuar com Apple';

  @override
  String get authContinueGoogle => 'Continuar com Google';

  @override
  String get authOrDivider => 'ou';

  @override
  String get wardrobeTitle => 'Closet';

  @override
  String get wardrobeEmptyTitle => 'Seu closet está vazio';

  @override
  String get wardrobeEmptyBody =>
      'Adicione sua primeira peça ou envie uma foto de todo o cabideiro de uma vez.';

  @override
  String get wardrobeAddFirst => 'Adicionar primeiro item';

  @override
  String get wardrobeSearchHint => 'Buscar no closet';

  @override
  String get categoryTops => 'Blusas';

  @override
  String get categoryBottoms => 'Calças e Saias';

  @override
  String get categoryShoes => 'Calçados';

  @override
  String get categoryAccessories => 'Acessórios';

  @override
  String get categoryOuterwear => 'Casacos';

  @override
  String get categorySwimwear => 'Moda Praia';

  @override
  String get categoryActivewear => 'Moda Esportiva';

  @override
  String get categoryOther => 'Outros';

  @override
  String get conditionClean => 'Limpo';

  @override
  String get conditionDirty => 'Sujo';

  @override
  String get conditionLaundry => 'Na lavanderia';

  @override
  String get conditionRepair => 'Precisa de reparo';

  @override
  String get conditionDonate => 'Para doar';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Verão';

  @override
  String get seasonFall => 'Outono';

  @override
  String get seasonWinter => 'Inverno';

  @override
  String get seasonAll => 'Todas as estações';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Executivo';

  @override
  String get styleSporty => 'Esportivo';

  @override
  String get styleBohemian => 'Boho';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romântico';

  @override
  String get styleEdgy => 'Ousado';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artístico';

  @override
  String get styleClassic => 'Clássico';

  @override
  String get styleElegant => 'Elegante';

  @override
  String get styleOther => 'Outro';

  @override
  String get occasionWork => 'Trabalho';

  @override
  String get occasionDateNight => 'Encontro';

  @override
  String get occasionTravel => 'Viagem';

  @override
  String get occasionWedding => 'Casamento';

  @override
  String get occasionGym => 'Academia';

  @override
  String get occasionWeekend => 'Fim de semana';

  @override
  String get occasionParty => 'Festa';

  @override
  String get occasionInterview => 'Entrevista';

  @override
  String get colorBlack => 'Preto';

  @override
  String get colorWhite => 'Branco';

  @override
  String get colorGrey => 'Cinza';

  @override
  String get colorNavy => 'Azul-marinho';

  @override
  String get colorBrown => 'Marrom';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorBeige => 'Bege';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count semanas',
      one: 'há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count meses',
      one: 'há 1 mês',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count anos',
      one: 'há 1 ano',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Gostando do FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Uma avaliação rápida ajuda outras pessoas a encontrarem seu estilo.';

  @override
  String get ratingPromptYes => 'Avaliar o app';

  @override
  String get ratingPromptNo => 'Agora não';

  @override
  String get closetNoMatchesTitle => 'Nenhuma peça encontrada';

  @override
  String get closetNoMatchesBody => 'Tente menos filtros ou outra busca.';

  @override
  String get closetClearFilters => 'Limpar filtros';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças',
      one: '1 peça',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Carregando suas peças';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionadas',
      one: '1 selecionada',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Excluir selecionadas';

  @override
  String get closetCancelSelection => 'Cancelar seleção';

  @override
  String get closetCloseSearch => 'Fechar busca';

  @override
  String get closetShowGrid => 'Ver em grade';

  @override
  String get closetShowList => 'Ver em lista';

  @override
  String get closetShowRows => 'Ver em linhas';

  @override
  String get closetStatsTitle => 'Estatísticas do closet';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count peças?',
      one: 'Excluir 1 peça?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Looks que as utilizam perderão essas peças.';

  @override
  String get closetSortBy => 'Ordenar por';

  @override
  String get closetFavourites => 'Favoritos';

  @override
  String get closetFavourite => 'Favoritar';

  @override
  String get closetUnfavourite => 'Remover favorito';

  @override
  String get closetWoreToday => 'Usei hoje';

  @override
  String closetWornTimes(int count) {
    return 'Usado $count×';
  }

  @override
  String get closetCategoryLabel => 'Categoria';

  @override
  String get closetUseCaseLabel => 'Ocasião';

  @override
  String get closetAnyUseCase => 'Qualquer';

  @override
  String get closetOtherUseCase => 'Outra ocasião';

  @override
  String get closetOtherUseCaseHint => 'Por exemplo, brunch';

  @override
  String get closetUseUseCase => 'Usar esta';

  @override
  String get closetClearAll => 'Limpar tudo';

  @override
  String get sortNewest => 'Mais recentes primeiro';

  @override
  String get sortOldest => 'Mais antigos';

  @override
  String get sortName => 'Nome (A–Z)';

  @override
  String get sortMostWorn => 'Mais usados';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Encontro';

  @override
  String get useCaseDinner => 'Jantar';

  @override
  String get useCaseLunch => 'Almoço';

  @override
  String get actionSelect => 'Selecionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get actionSort => 'Ordenar';

  @override
  String get actionAll => 'Todos';

  @override
  String get dashboardStartClosetTitle => 'Comece seu closet';

  @override
  String get dashboardStartClosetBody =>
      'Fotografe algumas peças. Nós as etiquetamos para você.';

  @override
  String get dashboardPieces => 'peças';

  @override
  String get dashboardOutfits => 'looks';

  @override
  String get dashboardDayStreak => 'dias seguidos';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count este mês';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Melhor $count';
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
      other: '$count looks salvos',
      one: '1 look salvo',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Mais usado: $name, $count vezes';
  }

  @override
  String get setupSkip => 'Pular configuração';

  @override
  String get setupWhoTitle => 'Quem vamos vestir?';

  @override
  String get setupWhoBody =>
      'Define o modelo para provador e fotos. Você pode alterar no seu perfil.';

  @override
  String get setupStyleTitle => 'O que você mais usa?';

  @override
  String get setupStyleBody =>
      'Escolha qualquer um. Ideias de looks começam por aqui.';

  @override
  String get setupClosetTitle => 'Adicione suas primeiras peças.';

  @override
  String get setupClosetBody =>
      'Fotografe algumas roupas, ou uma pilha delas. Cada peça é recortada e organizada para você.';

  @override
  String get setupAddClothes => 'Adicionar roupas';

  @override
  String get setupStylesLabel => 'Estilos';

  @override
  String get setupOccasionsLabel => 'Ocasiões';

  @override
  String get setupSkipStep => 'Pular';

  @override
  String get setupLater => 'Depois';

  @override
  String get setupSaveError => 'Não foi possível salvar';

  @override
  String get genderWomen => 'Feminino';

  @override
  String get genderMen => 'Masculino';

  @override
  String get genderNonBinary => 'Não binário';

  @override
  String get genderPreferNotToSay => 'Prefiro não dizer';

  @override
  String get outfitEmptyTitle => 'Nenhum look ainda';

  @override
  String get outfitEmptyBody =>
      'Combine peças do seu guarda-roupa e salve o look.';

  @override
  String get outfitNoMatchesTitle => 'Nenhum look encontrado';

  @override
  String get outfitSearchHint => 'Buscar looks';

  @override
  String get outfitLoading => 'Carregando seus looks';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count looks',
      one: '1 look',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Estilo e estação';

  @override
  String get outfitCollections => 'Coleções';

  @override
  String get outfitDuplicate => 'Duplicar';

  @override
  String get outfitDeleteTitle => 'Excluir este look?';

  @override
  String get outfitDeleteBody => 'As peças continuarão no seu guarda-roupa.';

  @override
  String get outfitDrafts => 'Rascunhos';

  @override
  String get outfitDraft => 'Rascunho';

  @override
  String get filterStyle => 'Estilo';

  @override
  String get filterSeason => 'Estação';

  @override
  String get itemDetailDeleteTitle => 'Excluir esta peça?';

  @override
  String get itemDetailDeleteBody => 'Looks que usam esta peça serão afetados.';

  @override
  String get itemAddFavourite => 'Adicionar aos favoritos';

  @override
  String itemSize(String size) {
    return 'Tamanho $size';
  }

  @override
  String get itemColours => 'Cores';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Estampa';

  @override
  String get itemUseCases => 'Ocasiões';

  @override
  String get itemKeptIn => 'Guardado em';

  @override
  String get itemPrice => 'Preço';

  @override
  String get itemBought => 'Comprado';

  @override
  String get itemTags => 'Etiquetas';

  @override
  String get itemAdded => 'Adicionado';

  @override
  String get itemTimesWornLabel => 'vezes usado';

  @override
  String get itemLastWornLabel => 'último uso';

  @override
  String get itemNeverWorn => 'Nunca';

  @override
  String get authEntryBody =>
      'Cada peça que você possui, estilizada por IA. Planeje looks, prove-os e fotografe.';

  @override
  String get authCreateCloset => 'Criar seu closet';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta';

  @override
  String get authSignInBody => 'Entre para abrir seu closet.';

  @override
  String get authCreateAccount => 'Criar uma conta';

  @override
  String get authCreateClosetBody =>
      'Leva um minuto. Seus primeiros itens são gratuitos.';

  @override
  String get authName => 'Nome';

  @override
  String get authConfirmPassword => 'Confirmar senha';

  @override
  String get authReferralCode => 'Código de indicação (opcional)';

  @override
  String get authResetTitle => 'Redefinir sua senha';

  @override
  String get authResetBody =>
      'Enviaremos um link por e-mail para criar uma nova.';

  @override
  String get authSendResetLink => 'Enviar link de redefinição';

  @override
  String get authBackToSignIn => 'Voltar para entrar';

  @override
  String get authEnterEmail => 'Insira seu e-mail';

  @override
  String get authEnterValidEmail => 'Insira um e-mail válido';

  @override
  String get authEnterPassword => 'Insira sua senha';

  @override
  String get authPasswordTooShort => 'Pelo menos 6 caracteres';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String get authNewHere => 'Novo por aqui?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirme $email antes de entrar. Verifique sua caixa de entrada.';
  }

  @override
  String get authResendEmail => 'Enviar novamente';

  @override
  String get authResendingEmail => 'Enviando…';

  @override
  String get authPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get authEnterName => 'Insira seu nome';

  @override
  String get authChoosePassword => 'Escolha uma senha';

  @override
  String get authHaveAccount => 'Já tem uma conta?';

  @override
  String get authCodeAccepted => 'Código aceito';

  @override
  String get authCodeNotFound => 'Código não encontrado';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Ambos ganham um mês grátis.';
  }

  @override
  String get authReferralInvalid => 'Não foi possível encontrar este código.';

  @override
  String authResetSent(String email) {
    return 'Enviado para $email. Abra o link neste celular.';
  }

  @override
  String get introSlide1Title => 'Fotografe seu guarda-roupa.';

  @override
  String get introSlide1Body =>
      'Tire uma foto de uma pilha de roupas. Cada peça é recortada e organizada para você.';

  @override
  String get introSlide2Title => 'Vista-se mais rápido.';

  @override
  String get introSlide2Body =>
      'Looks com o que você já tem, combinados com seus planos e o clima.';

  @override
  String get introSlide3Title => 'Veja antes de vestir.';

  @override
  String get introSlide3Body =>
      'Experimente looks na sua própria foto ou fotografe como uma campanha.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Atualizações por e-mail';

  @override
  String get settingsEmailUpdatesBody => 'Novidades e dicas por e-mail';

  @override
  String get settingsOutfitReminders => 'Lembretes de looks';

  @override
  String get settingsOutfitRemindersBody =>
      'Um aviso para registrar o que você vestiu';

  @override
  String get settingsWeeklySummary => 'Resumo semanal';

  @override
  String get settingsWeeklySummaryBody => 'Sua semana em looks';

  @override
  String get settingsStyleSection => 'Estilo';

  @override
  String get settingsPreferredStyles => 'Estilos que você gosta';

  @override
  String get settingsPreferredColours => 'Cores que você gosta';

  @override
  String get settingsNoneChosen => 'Nenhum escolhido';

  @override
  String get settingsPlanAiSection => 'Plano e IA';

  @override
  String get settingsPlanBillingBody => 'Plano, uso e upgrades';

  @override
  String get settingsPlanUsageBody => 'Plano e uso';

  @override
  String get settingsInviteFriends => 'Convidar amigos';

  @override
  String get settingsInviteFriendsBody =>
      'Um mês grátis para cada amigo que entrar';

  @override
  String get settingsAiProvider => 'Provedor de IA';

  @override
  String get settingsAiProviderBody =>
      'Use seu próprio modelo para etiquetas e imagens';

  @override
  String get settingsAppVersion => 'Versão do app';

  @override
  String get settingsPrivacyTerms => 'Privacidade e termos';

  @override
  String get settingsReportProblem => 'Relatar um problema';

  @override
  String get settingsChangePassword => 'Alterar senha';

  @override
  String get settingsExportData => 'Exportar seus dados';

  @override
  String get settingsExportBody =>
      'Preparamos um arquivo com tudo o que você salvou e abrimos o download.';

  @override
  String get settingsExportAction => 'Exportar';

  @override
  String get settingsCurrentPassword => 'Senha atual';

  @override
  String get settingsNewPassword => 'Nova senha';

  @override
  String get settingsConfirmNewPassword => 'Confirmar nova senha';

  @override
  String get settingsEnterCurrentPassword => 'Digite sua senha atual';

  @override
  String get settingsEnterNewPassword => 'Digite uma nova senha';

  @override
  String get settingsPasswordMin8 => 'Use pelo menos 8 caracteres';

  @override
  String get settingsPasswordNeedsUpper => 'Adicione uma letra maiúscula';

  @override
  String get settingsPasswordNeedsLower => 'Adicione uma letra minúscula';

  @override
  String get settingsPasswordNeedsDigit => 'Adicione um número';

  @override
  String get settingsPasswordsNoMatch => 'As senhas não coincidem';

  @override
  String get settingsChangeAction => 'Alterar';

  @override
  String get itemAddSnapTitle => 'Fotografe uma peça';

  @override
  String get itemAddSnapBody =>
      'Identificamos cada peça na foto e criamos uma imagem de estúdio limpa.';

  @override
  String get itemAddCamera => 'Tirar foto';

  @override
  String get itemAddGallery => 'Escolher da galeria';

  @override
  String get itemAddOtherWays => 'Outras formas de adicionar';

  @override
  String get itemAddSeveral => 'Adicionar várias fotos';

  @override
  String get itemAddSeveralBody => 'Até 50 de uma vez';

  @override
  String get itemAddImportProfile => 'Importar de um perfil';

  @override
  String get itemAddImportProfileBody => 'Instagram ou Facebook';

  @override
  String get itemAddEnterDetails => 'Inserir detalhes manualmente';

  @override
  String get itemAddEnterDetailsBody => 'Não é necessária foto';

  @override
  String get itemManualIntro =>
      'Apenas um nome é necessário. Adicione o restante agora ou depois.';

  @override
  String get itemManualNameHint => 'Exemplo: camiseta azul de algodão';

  @override
  String get itemManualEnterName => 'Digite um nome';

  @override
  String get itemManualNotes => 'Notas';

  @override
  String get itemManualBrand => 'Marca';

  @override
  String get itemManualSize => 'Tamanho';

  @override
  String get itemManualEnterNumber => 'Digite um número';

  @override
  String get itemManualSavePiece => 'Salvar peça';

  @override
  String get itemManualSaving => 'Salvando';

  @override
  String get itemManualSavedTitle => 'Salvo';

  @override
  String itemManualSavedBody(String name) {
    return '$name está no seu closet.';
  }

  @override
  String get itemManualNotSaved => 'Não salvo';

  @override
  String get itemManualAddUseCase => 'Adicionar ocasião';

  @override
  String get itemManualAddUseCaseAction => 'Adicionar ocasião';

  @override
  String get itemPhotos => 'Fotos';

  @override
  String get itemAddPhotos => 'Adicionar fotos';

  @override
  String get itemNoPhotoYet => 'Sem foto ainda. Você pode salvar sem uma.';

  @override
  String get itemRemovePhoto => 'Remover foto';

  @override
  String get itemRemovePiece => 'Remover peça';

  @override
  String get filterConditionLabel => 'Condição';

  @override
  String get photoshootStepPhotos => 'Fotos';

  @override
  String get photoshootStepSetup => 'Configuração';

  @override
  String get photoshootStepCreating => 'Criando';

  @override
  String get photoshootStepResults => 'Resultados';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Passo $current de $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Uma foto falhou. Tente novamente abaixo.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotos falharam. Tente cada uma abaixo.';
  }

  @override
  String get photoshootFormat => 'Formato';

  @override
  String get photoshootHowMany => 'Quantidade';

  @override
  String get photoshootYourPrompt => 'Seu prompt';

  @override
  String get photoshootPromptHint => 'Golden hour no terraço, camisa de linho';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Criar $count fotos',
      one: 'Criar 1 foto',
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
      'Não foi possível verificar o limite de hoje.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plano $plan: $remaining de $limit restantes hoje';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Grátis';

  @override
  String get photoshootGallery => 'Galeria';

  @override
  String get photoshootUseCamera => 'Usar câmera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Remover foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Nenhuma foto retornou';

  @override
  String get photoshootNoPhotosBody =>
      'A sessão terminou sem imagens. Tente novamente.';

  @override
  String get photoshootNewStyle => 'Novo estilo';

  @override
  String get photoshootNewPhotos => 'Novas fotos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Abrir foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Denunciar foto';

  @override
  String get photoshootSaveToGallery => 'Salvar na galeria';

  @override
  String get actionUpgrade => 'Fazer upgrade';

  @override
  String get referralLimitTitle => 'Você usou as fotos de hoje';

  @override
  String get referralLimitBody =>
      'Suas fotos gratuitas retornam amanhã. Indique um amigo e ambos ganham um mês de Pro grátis.';

  @override
  String get referralLimitRefer => 'Indicar um amigo';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'App de namoro';

  @override
  String get photoshootUsePortfolio => 'Portfólio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estético';

  @override
  String get photoshootUseCustom => 'Seu próprio prompt';

  @override
  String get photoshootDescLinkedin => 'Fotos profissionais para o trabalho';

  @override
  String get photoshootDescDating => 'Descontraído, caloroso e natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, looks de alta moda';

  @override
  String get photoshootDescInstagram => 'Fotos de estilo de vida para seu feed';

  @override
  String get photoshootDescAesthetic => 'Quadros artísticos e conceituais';

  @override
  String get photoshootDescCustom => 'Descreva o visual que você deseja';

  @override
  String get aspectSquare => 'Quadrado';

  @override
  String get aspectPortrait => 'Retrato';

  @override
  String get aspectLandscape => 'Paisagem';

  @override
  String get aspectTall => 'Alto';

  @override
  String get aspectWide => 'Largo';

  @override
  String get tryOnAppBar => 'Provador virtual';

  @override
  String get tryOnYourPhoto => 'Sua foto';

  @override
  String get tryOnGarment => 'Peça';

  @override
  String get tryOnUploadingPhoto => 'Enviando sua foto';

  @override
  String get tryOnAddPhotoPrompt => 'Adicione uma foto de corpo inteiro';

  @override
  String get tryOnBodyPhotoHint => 'Uma foto de corpo inteiro funciona melhor';

  @override
  String get tryOnAddPhoto => 'Adicionar foto';

  @override
  String get tryOnChangePhoto => 'Alterar foto';

  @override
  String get tryOnPhotoLoadFailed => 'Não foi possível carregar sua foto.';

  @override
  String get tryOnChooseGarment => 'Escolha a foto da peça';

  @override
  String get tryOnChooseOneGarment => 'Escolha uma foto da peça';

  @override
  String get tryOnGarmentHint =>
      'Uma foto da peça esticada ou no cabide funciona melhor';

  @override
  String get tryOnChange => 'Alterar';

  @override
  String get tryOnCamera => 'Câmera';

  @override
  String get tryOnRemove => 'Remover';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Estilo';

  @override
  String get tryOnBackground => 'Fundo';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Montando seu look. Isso leva cerca de meio minuto.';

  @override
  String get tryOnEmptyResult => 'Sua prova aparecerá aqui';

  @override
  String get tryOnReportImage => 'Denunciar imagem';

  @override
  String get tryOnCreating => 'Criando';

  @override
  String get tryOnTryAgain => 'Tentar novamente';

  @override
  String get tryOnCreate => 'Criar prova';

  @override
  String get tryOnBackgroundStudioWhite => 'Estúdio branco';

  @override
  String get tryOnBackgroundStudioGrey => 'Estúdio cinza';

  @override
  String get tryOnBackgroundUrban => 'Urbano';

  @override
  String get tryOnBackgroundNature => 'Natureza';

  @override
  String get tryOnBackgroundMinimal => 'Minimalista';

  @override
  String get tryOnPoseFront => 'De frente';

  @override
  String get tryOnPoseSide => 'De lado';

  @override
  String get tryOnPoseWalking => 'Caminhando';

  @override
  String get dashboardGreetingMorning => 'Bom dia';

  @override
  String get dashboardGreetingAfternoon => 'Boa tarde';

  @override
  String get dashboardGreetingEvening => 'Boa noite';

  @override
  String get dashboardWelcome => 'Bem-vindo';

  @override
  String get dashboardOpenProfile => 'Abrir perfil';

  @override
  String get dashboardRailToday => 'Hoje';

  @override
  String get dashboardRailRecently => 'Recentes';

  @override
  String get dashboardActivityEmpty => 'Novas peças e looks aparecem aqui.';

  @override
  String get quickAddPiece => 'Adicionar peça';

  @override
  String get quickAddPieceBody => 'Fotografe e marque';

  @override
  String get quickBuildOutfit => 'Montar look';

  @override
  String get quickBuildOutfitBody => 'Combine suas peças';

  @override
  String get quickForYou => 'Para você';

  @override
  String get quickForYouBody => 'Sugestões de hoje';

  @override
  String get quickPlanWeek => 'Planejar semana';

  @override
  String get quickPlanWeekBody => 'Looks por data';

  @override
  String get referralBannerUrgent => 'Acabando? Convide um amigo.';

  @override
  String get referralBannerTitle => 'Dê um mês, ganhe um mês.';

  @override
  String get referralBannerBody => 'Você e seu amigo ganham um mês de Pro.';

  @override
  String get referralBannerDismiss => 'Dispensar por uma semana';

  @override
  String get referralBannerShare => 'Compartilhar convite';

  @override
  String get referralBannerCopy => 'Copiar link';

  @override
  String get itemEditPieceTitle => 'Editar peça';

  @override
  String get itemEditDescriptionLabel => 'Descrição';

  @override
  String get itemEditNotSaved => 'Não salvo';

  @override
  String get itemEditSavedTitle => 'Salvo';

  @override
  String get itemEditSavedBody => 'Suas alterações foram salvas.';

  @override
  String get itemEditSavedStalePhotos =>
      'Salvo — fotos podem estar desatualizadas';

  @override
  String get itemEditRemovePieceHint => 'Excluir esta peça da página do item.';

  @override
  String get itemEditNoPhotos =>
      'Sem fotos ainda. Adicione uma da galeria ou câmera.';

  @override
  String get itemEditKeepPhoto => 'Manter foto';

  @override
  String get itemEditRemoved => 'Removido';

  @override
  String get itemEditAddUseCaseAction => 'Adicionar';

  @override
  String get statsNoStatsTitle => 'Sem estatísticas ainda';

  @override
  String get statsNoStatsBody =>
      'Adicione algumas peças e o mix do seu guarda-roupa aparecerá aqui.';

  @override
  String get statsByCategory => 'Por categoria';

  @override
  String get statsTotalValue => 'valor total';

  @override
  String get statsMostWorn => 'Mais usadas';

  @override
  String get statsLeastWorn => 'Aguardando vez';

  @override
  String get statsUnnamedPiece => 'Peça sem nome';

  @override
  String get jobsTitle => 'Análises';

  @override
  String get jobsEmptyTitle => 'Sem análises ainda';

  @override
  String get jobsEmptyBody =>
      'Fotografe uma peça e envie para o processamento — ele continuará trabalhando aqui.';

  @override
  String get jobsNotCancelled => 'Não cancelado';

  @override
  String get jobsResume => 'Retomar';

  @override
  String get jobsReview => 'Revisar';

  @override
  String get jobsStop => 'Parar';

  @override
  String get jobsDismiss => 'Dispensar';

  @override
  String get reportTitle => 'Denunciar conteúdo';

  @override
  String reportIntro(String contentType) {
    return 'Diga-nos o que há de errado com este $contentType. Nossa equipe analisa todas as denúncias.';
  }

  @override
  String get reportReasonInappropriate => 'Inapropriado ou ofensivo';

  @override
  String get reportReasonNudity => 'Nudez ou conteúdo sexual';

  @override
  String get reportReasonHarassment => 'Assédio ou abuso';

  @override
  String get reportReasonImpersonation => 'Imitação de identidade';

  @override
  String get reportReasonOther => 'Outro';

  @override
  String get reportDetailsLabel => 'Detalhes adicionais (opcional)';

  @override
  String get reportSubmit => 'Enviar denúncia';

  @override
  String get reportSubmittedTitle => 'Denúncia enviada';

  @override
  String get reportSubmittedBody =>
      'Obrigado. Nossa equipe analisará este conteúdo.';

  @override
  String get reportFailedTitle => 'Não foi possível enviar';

  @override
  String get reportFailedBody => 'Por favor, tente novamente.';

  @override
  String get reportContentTryOnImage => 'imagem de provador virtual';

  @override
  String get reportContentSharedOutfit => 'look compartilhado';

  @override
  String get reportContentPhotoshootImage => 'imagem de ensaio fotográfico';

  @override
  String get sharedOutfitTitle => 'Look compartilhado';

  @override
  String get sharedOutfitHideTooltip => 'Ocultar este look';

  @override
  String get sharedOutfitReportTooltip => 'Denunciar este look';

  @override
  String get sharedOutfitHideTitle => 'Ocultar este look?';

  @override
  String get sharedOutfitHideBody =>
      'Ele ficará oculto neste dispositivo. Você também pode denunciá-lo para que nossa equipe analise e remova.';

  @override
  String get sharedOutfitHideAction => 'Ocultar';

  @override
  String get sharedOutfitHiddenInfo =>
      'Este look não aparecerá mais neste dispositivo.';

  @override
  String get sharedOutfitHiddenToast => 'Look oculto';

  @override
  String get sharedOutfitMissingTitle => 'Este look não está mais aqui';

  @override
  String get sharedOutfitMissingBody =>
      'Ele pode ter sido removido ou o link está incorreto.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Você ocultou este look';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Se for impróprio, denuncie em Privacidade e termos ou envie um e-mail para $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Gostou deste look?';

  @override
  String get sharedOutfitCtaBody =>
      'Crie looks parecidos com as peças do seu guarda-roupa.';

  @override
  String get sharedOutfitCtaButton => 'Baixar FitCheck AI';

  @override
  String get errorTitle => 'Erro';

  @override
  String get errorUnknown => 'Ocorreu um erro inesperado';

  @override
  String get errorNoConnection =>
      'Sem conexão com a internet. Verifique sua rede.';

  @override
  String get errorTimeout => 'Tempo limite excedido. Tente novamente.';

  @override
  String get errorServerError =>
      'Algo deu errado do nosso lado. Tente novamente.';

  @override
  String get errorBadGateway =>
      'Nosso servidor está indisponível brevemente. Tente novamente.';

  @override
  String get errorServiceUnavailable =>
      'Serviço temporariamente indisponível. Tente em breve.';

  @override
  String get errorInternalError => 'Algo deu errado. Tente novamente.';

  @override
  String get errorUnauthorized => 'Entre para continuar.';

  @override
  String get errorForbidden => 'Você não tem acesso a isso.';

  @override
  String get errorSessionExpired => 'Sua sessão expirou. Entre novamente.';

  @override
  String get errorInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get errorTokenRefreshFailed =>
      'Não foi possível atualizar sua sessão. Entre novamente.';

  @override
  String get errorRequestCancelled => 'Solicitação cancelada.';

  @override
  String get errorInvalidFormat => 'Formato de arquivo não suportado.';

  @override
  String get errorFileTooLarge => 'Arquivo muito grande.';

  @override
  String get errorUploadFailed => 'Falha no envio. Tente novamente.';

  @override
  String get errorCacheCorrupted => 'Dados salvos corrompidos e redefinidos.';

  @override
  String get errorCacheNotFound => 'Nada salvo ainda.';

  @override
  String get errorUserNotFound => 'Conta não encontrada.';

  @override
  String get errorItemNotFound => 'Esta peça não existe mais.';

  @override
  String get errorOutfitNotFound => 'Este look não existe mais.';

  @override
  String get rewardsTitle => 'Conquistas';

  @override
  String get rewardsNoAchievementsTitle => 'Nenhuma conquista ainda';

  @override
  String get rewardsNoAchievementsBody =>
      'Adicione peças e monte looks para ganhar a primeira.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Ninguém no ranking ainda';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Monte looks para ganhar pontos e aparecer aqui.';

  @override
  String get legalViewPrivacyPolicy => 'Ver Política de Privacidade';

  @override
  String get aiConsentAgree => 'Concordar e Continuar';

  @override
  String get aiConsentNotNow => 'Agora Não';

  @override
  String get imageViewerCloseTooltip => 'Fechar visualizador de imagem';

  @override
  String get updateReadyTitle => 'Atualização pronta';

  @override
  String get updateReadyBody =>
      'Reinicie o FitCheck AI para aplicar as melhorias mais recentes.';

  @override
  String get permissionCameraUsage =>
      'O FitCheck AI precisa de acesso à câmera para tirar fotos dos seus looks e peças do guarda-roupa.';

  @override
  String get permissionPhotoLibraryUsage =>
      'O FitCheck AI precisa de acesso à galeria de fotos para selecionar imagens dos seus looks e peças.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'O FitCheck AI precisa salvar as fotos de looks geradas por IA na sua galeria.';

  @override
  String get wardrobeSomePhotosSkipped => 'Algumas fotos foram ignoradas';

  @override
  String get wardrobePhotosNotAdded => 'Fotos não adicionadas';

  @override
  String get wardrobePhotoNotAdded => 'Foto não adicionada';

  @override
  String get wardrobeNotStartedTitle => 'Não iniciado';

  @override
  String get wardrobeNoRoomTitle => 'Sem espaço';

  @override
  String get wardrobeAddPhotosSemantic => 'Adicionar fotos';

  @override
  String get batchAddTileLabel => 'Adicionar';

  @override
  String get batchProfileLinkLabel => 'Link do perfil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importar de um perfil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Adicionar várias fotos';

  @override
  String get wardrobeClearAction => 'Limpar';

  @override
  String get wardrobeRefreshTooltip => 'Atualizar';

  @override
  String get batchNoPhotosYetTitle => 'Nenhuma foto ainda';

  @override
  String get batchChoosePhotosAction => 'Escolher fotos';

  @override
  String get batchWeFindEachPieceBody =>
      'Identificamos cada peça e criamos uma foto de estúdio dela.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparando fotos';

  @override
  String get batchPhotosProcessedSemantic => 'Fotos processadas';

  @override
  String get batchPasteProfileLinkTitle => 'Colar link do perfil';

  @override
  String get batchPasteProfileLinkBody =>
      'Um perfil público do Instagram ou Facebook. Escaneamos as fotos e você escolhe o que vai para o seu closet.';

  @override
  String get batchClearLinkTooltip => 'Limpar link';

  @override
  String get batchStartingButton => 'Iniciando';

  @override
  String get batchStartImportAction => 'Iniciar importação';

  @override
  String get batchReviewEveryPhotoTitle => 'Você revisa cada foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nada é adicionado até que você aprove.';

  @override
  String get batchPrivateProfilesTitle => 'Perfis privados';

  @override
  String get batchPrivateProfilesBody =>
      'Conecte sua conta. O Instagram também solicita usuário e senha.';

  @override
  String get batchUseAnotherLinkAction => 'Usar outro link';

  @override
  String get batchSignInNeededTitle => 'Login necessário';

  @override
  String get batchEnterYourCodeTitle => 'Insira seu código';

  @override
  String get batchUseUsernamePasswordAction => 'Usar usuário e senha';

  @override
  String get batchAlreadyConnectedAction => 'Já me conectei no navegador';

  @override
  String get batchEnterCodeAction => 'Inserir código';

  @override
  String get batchTryAnotherWayAction => 'Tentar outro modo';

  @override
  String get batchLiveStatus => 'Ao vivo';

  @override
  String get batchReconnectingStatus => 'Reconectando';

  @override
  String get batchSignInToInstagramTitle => 'Entrar no Instagram';

  @override
  String get batchUsernameLabel => 'Usuário';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Código, se usa verificação em duas etapas';

  @override
  String get batchAuthenticatorCodeBody =>
      'Use o código de 6 dígitos do seu app autenticador. Os códigos mudam rápido.';

  @override
  String get batchVerifyAction => 'Verificar';

  @override
  String get batchFindingPhotosTitle => 'Buscando fotos';

  @override
  String get batchImportPausedTitle => 'Importação pausada';

  @override
  String get batchProcessingPhotosTitle => 'Processando fotos';

  @override
  String get batchWaitingNextPhoto => 'Aguardando próxima foto';

  @override
  String get batchCancelImportAction => 'Cancelar importação';

  @override
  String get batchNoPiecesInPhotoBody => 'Nenhuma peça encontrada nesta foto.';

  @override
  String get batchEditPieceColoursLabel => 'Cores, separadas por vírgula';

  @override
  String get batchAddToClosetAction => 'Adicionar ao closet';

  @override
  String get batchSkipPhotoAction => 'Pular esta foto';

  @override
  String get batchImportCompleteTitle => 'Importação concluída';

  @override
  String get batchImportFailedTitle => 'Falha na importação';

  @override
  String get batchImportCancelledTitle => 'Importação cancelada';

  @override
  String get batchImportErrorBody => 'Algo deu errado durante a importação.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nada mais será importado deste perfil.';

  @override
  String get batchViewClosetAction => 'Ver guarda-roupa';

  @override
  String get batchStartOverAction => 'Recomeçar';

  @override
  String get wardrobeAddPieceTitle => 'Adicionar peça';

  @override
  String get wardrobeAddDetailsTitle => 'Adicionar detalhes';

  @override
  String get wardrobeScanningTitle => 'Escaneando';

  @override
  String get batchReviewPiecesTitle => 'Revisar peças';

  @override
  String get wardrobeGalleryAction => 'Galeria';

  @override
  String get wardrobeCameraAction => 'Câmera';

  @override
  String get wardrobeNewBadge => 'Novo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Remover foto';

  @override
  String get batchRunInBackgroundTooltip => 'Executar em segundo plano';

  @override
  String get batchStepOneOfTwo => 'Passo 1 de 2';

  @override
  String get batchStepTwoOfTwo => 'Passo 2 de 2';

  @override
  String get batchUploadingPhotosTitle => 'Enviando fotos';

  @override
  String get batchFindingPiecesTitle => 'Encontrando peças';

  @override
  String get batchMakingStudioPhotosTitle => 'Criando fotos de estúdio';

  @override
  String get batchStoppedLabel => 'Parado';

  @override
  String get batchFindingPiecesStoppedTitle => 'Busca de peças interrompida';

  @override
  String get batchCancelledLabel => 'Cancelado';

  @override
  String get batchAllDoneTitle => 'Tudo pronto';

  @override
  String get batchOpeningPiecesBody => 'Abrindo suas peças';

  @override
  String get batchNothingSavedBody => 'Nada foi salvo.';

  @override
  String get batchFindingPiecesFailedBody => 'Falha ao encontrar peças.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'A busca de peças parou mais cedo.';

  @override
  String get batchStopFindingPiecesTitle => 'Parar busca de peças?';

  @override
  String get batchStopFindingPiecesBody =>
      'O escaneamento para e nada é salvo. As peças já encontradas ficam na sua atividade até você dispensá-las.';

  @override
  String get batchKeepGoingAction => 'Continuar';

  @override
  String get batchTryAgainAction => 'Tentar novamente';

  @override
  String get batchBackToPhotosAction => 'Voltar às fotos';

  @override
  String get batchSkipAllAction => 'Pular tudo';

  @override
  String get batchIncludeAllAction => 'Incluir tudo';

  @override
  String get batchNoPiecesFoundTitle => 'Nenhuma peça encontrada';

  @override
  String get batchNoPiecesFoundBody => 'Não encontramos roupas nestas fotos.';

  @override
  String get batchChooseOtherPhotosAction => 'Escolher outras fotos';

  @override
  String get batchUseCaseHelper => 'Adicionado a cada peça que você salvar.';

  @override
  String get batchDiscardPiecesTitle => 'Descartar estas peças?';

  @override
  String get batchDiscardPiecesBody => 'Nada deste lote será salvo.';

  @override
  String get batchKeepAction => 'Manter';

  @override
  String get batchDiscardAction => 'Descartar';

  @override
  String get batchRemovePieceTitle => 'Remover esta peça?';

  @override
  String get batchRemovePieceBody => 'Ela não foi salva no seu armário.';

  @override
  String get batchRemoveAction => 'Remover';

  @override
  String get batchChoosePiecesToSave => 'Escolher peças para salvar';

  @override
  String get batchDiscardAllAction => 'Descartar tudo';

  @override
  String get batchNothingSavedRetryBody => 'Nada foi salvo. Tente novamente.';

  @override
  String get batchNotSavedTitle => 'Não salvo';

  @override
  String get batchSavingLabel => 'Salvando';

  @override
  String get batchSendToBackgroundAction => 'Enviar para segundo plano';

  @override
  String get batchStillWorkingMessage =>
      'Trabalhando nisso. Avisaremos quando suas peças estiverem prontas.';

  @override
  String get batchRunningInBackgroundTitle => 'Executando em segundo plano';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Fotos de estúdio pararam mais cedo. Você ainda pode salvar estas peças.';

  @override
  String get batchTapPieceToSkip => 'Toque em uma peça para ignorá-la.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Fotos de estúdio a caminho. Você pode sair — avisaremos quando terminar.';

  @override
  String get batchLeaveAction => 'Sair';

  @override
  String get batchPeopleInPhotosTitle => 'Pessoas nas fotos';

  @override
  String get batchIncludeAction => 'Incluir';

  @override
  String get batchSkipAction => 'Ignorar';

  @override
  String get batchYourPhotoIsUsedLabel => 'Sua foto está sendo usada';

  @override
  String get batchMakingStudioPhotoLabel => 'Criando foto de estúdio';

  @override
  String get batchNoStudioPhotoBody =>
      'Sem foto de estúdio. Sua foto será usada.';

  @override
  String get batchEnterDetailsYourselfAction => 'Preencher dados manualmente';

  @override
  String get batchChooseAnotherPhotoAction => 'Escolher outra foto';

  @override
  String get batchConnectionLostTitle => 'Conexão perdida';

  @override
  String get batchConnectionLostBody =>
      'Verifique sua conexão e tente novamente.';

  @override
  String get batchDailyLimitTitle => 'Limite diário atingido';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Faça upgrade para o Pro para mais escaneamentos ou preencha os dados manualmente.';

  @override
  String get batchDailyLimitBodyFree =>
      'Seus escaneamentos serão renovados amanhã. Você pode preencher os dados manualmente agora.';

  @override
  String get batchSeePlansAction => 'Ver planos';

  @override
  String get batchAiBusyTitle => 'Nosso IA está ocupado';

  @override
  String get batchAiBusyBody =>
      'O problema está do nosso lado. Tente novamente em alguns minutos.';

  @override
  String get batchNoPiecesBody =>
      'Tente uma foto mais clara ou preencha os dados manualmente.';

  @override
  String get batchScanningUnavailableTitle => 'Escaneamento indisponível';

  @override
  String get batchScanningUnavailableBody =>
      'Preencha os dados manualmente por enquanto.';

  @override
  String get batchScanDidNotFinishTitle => 'O escaneamento não foi concluído';

  @override
  String get batchTryAgainBody => 'Tente novamente.';

  @override
  String get billingTitle => 'Assinatura';

  @override
  String get billingUpgradeHeading => 'Faça upgrade do seu plano';

  @override
  String get billingUpgradeOnPlusBody => 'Mesmos recursos, limites maiores.';

  @override
  String get billingUpgradeBody =>
      'Plus e Pro têm os mesmos recursos. Escolha os limites de que você precisa.';

  @override
  String get billingWebUnavailableBody =>
      'Upgrades online ainda não estão disponíveis. Um código de promoção ou indicação libera Plus ou Pro. Convide amigos abaixo para ganhar meses grátis.';

  @override
  String get billingPlansStale =>
      'Não foi possível carregar os planos mais recentes. Os preços podem estar desatualizados.';

  @override
  String get billingMonthly => 'Mensal';

  @override
  String get billingYearly => 'Anual';

  @override
  String get billingCurrentPlan => 'Plano atual';

  @override
  String get billingActive => 'Ativo';

  @override
  String get billingThisMonth => 'Este mês';

  @override
  String get billingItemExtractions => 'Extrações de itens';

  @override
  String get billingOutfitVisualizations => 'Visualizações de looks';

  @override
  String get billingNearLimitUpgrade =>
      'Você está próximo do limite deste mês. Faça upgrade para mais.';

  @override
  String get billingNearLimitResets =>
      'Você está próximo do limite deste mês. Ele será renovado no início do próximo mês.';

  @override
  String get billingStoreUnavailable =>
      'As atualizações não estão disponíveis na loja no momento. Volte em breve.';

  @override
  String get billingManageHeading => 'Gerenciar plano';

  @override
  String get billingCancelPlan => 'Cancelar assinatura';

  @override
  String get billingCancelKeepsAccess =>
      'Você mantém o acesso até o fim do período de cobrança atual.';

  @override
  String get billingCancelConfirmTitle => 'Cancelar sua assinatura?';

  @override
  String get billingKeepPlan => 'Manter plano';

  @override
  String get billingCancelPlanAction => 'Cancelar plano';

  @override
  String get billingBilledMonthly => 'Cobrança mensal';

  @override
  String get billingBilledYearly => 'Cobrança anual';

  @override
  String get billingVirtualTryOn => 'Provador virtual';

  @override
  String get billingPrioritySupport => 'Suporte prioritário';

  @override
  String get billingDisclosureProRenewing =>
      'Pro é uma assinatura com renovação automática';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus e Pro são assinaturas com renovação automática';

  @override
  String get billingDisclosureAppleBilling =>
      'O pagamento será cobrado no seu ID Apple na confirmação da compra.';

  @override
  String get billingDisclosureGoogleBilling =>
      'O pagamento será cobrado na sua conta do Google Play na confirmação da compra.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Sua assinatura é renovada automaticamente pelo mesmo período e preço, a menos que você desative a renovação automática pelo menos 24 horas antes do fim do período atual.';

  @override
  String get billingDisclosureAppleManage =>
      'Gerencie ou cancele a qualquer momento em Ajustes › seu ID Apple › Assinaturas.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gerencie ou cancele a qualquer momento em Google Play › Pagamentos e assinaturas.';

  @override
  String get billingReferFriend => 'Indicar um amigo';

  @override
  String get billingHowItWorks => 'Como funciona';

  @override
  String get billingHowShareTitle => 'Compartilhe seu link';

  @override
  String get billingHowShareBody => 'Envie para um amigo.';

  @override
  String get billingHowSignUpTitle => 'Eles se cadastram';

  @override
  String get billingHowSignUpBody => 'Seu amigo entra pelo link.';

  @override
  String get billingHowBothTitle => 'Vocês ganham Pro';

  @override
  String get billingHowBothBody => 'Cada um ganha um mês de Pro grátis.';

  @override
  String get billingYourReferrals => 'Suas indicações';

  @override
  String get billingInvited => 'Convidados';

  @override
  String get billingJoined => 'Entraram';

  @override
  String get billingMonthsEarned => 'Meses ganhos';

  @override
  String get billingInviteFriend => 'Convidar um amigo';

  @override
  String get billingInviteBody => 'Você e seu amigo ganham um mês de Pro.';

  @override
  String get billingYourCode => 'Seu código';

  @override
  String get billingCopyLink => 'Copiar link';

  @override
  String get billingShareInvite => 'Compartilhar convite';

  @override
  String get giftUnavailable =>
      'Convites de presente indisponíveis nesta versão.';

  @override
  String get giftPageTitle => 'Oferecer FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Nenhum convite de presente gratuito disponível no momento.';

  @override
  String get giftFormTitle => 'Enviar um convite gratuito';

  @override
  String get giftFormBody =>
      'O destinatário resgata o presente com este e-mail verificado. Nós não enviamos o e-mail por você.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nome do destinatário';

  @override
  String get giftFieldRecipientEmail => 'E-mail do destinatário';

  @override
  String get giftFieldOccasion => 'Ocasião (opcional)';

  @override
  String get giftNoOccasion => 'Sem ocasião';

  @override
  String get giftOccasionBirthday => 'Aniversário';

  @override
  String get giftOccasionAnniversary => 'Bodas';

  @override
  String get giftOccasionOther => 'Outro';

  @override
  String get giftFieldCardGreeting => 'Mensagem do cartão';

  @override
  String get giftFieldCardGreetingHelper =>
      'Isso aparece no cartão exatamente como escrito.';

  @override
  String get giftFieldPrivateNote => 'Nota privada (opcional)';

  @override
  String get giftCreateAction => 'Criar presente gratuito';

  @override
  String get giftClaimedTitle => 'Presente resgatado';

  @override
  String get giftClaimedActive => 'Seu presente do FitCheck Pro está ativo.';

  @override
  String get giftClaimedQueued =>
      'Seu presente do FitCheck Pro começa após o acesso atual.';

  @override
  String get giftLinkCopied =>
      'Link do presente copiado para a área de transferência.';

  @override
  String get giftErrorName => 'Insira um nome.';

  @override
  String get giftErrorEmail => 'Insira um endereço de e-mail válido.';

  @override
  String get giftErrorGreeting => 'Insira a mensagem do cartão.';

  @override
  String get giftErrorGreetingLength => 'Use no máximo 80 caracteres.';

  @override
  String get giftClaimAction => 'Resgatar presente';

  @override
  String get giftCardPreview => 'Visualizar cartão';

  @override
  String get giftGiftForYou => 'Um presente para você';

  @override
  String get giftGiftWaiting => 'Há um presente esperando por você';

  @override
  String get giftOpenBody =>
      'Abra seus presentes para resgatá-los com seu e-mail verificado.';

  @override
  String get giftOpenGifts => 'Abrir presentes';

  @override
  String get giftSendInvitation => 'Enviar convite';

  @override
  String get settingsAiProviderSection => 'Provedor';

  @override
  String get settingsAiCustom => 'Personalizado';

  @override
  String get settingsAiUrlHelper =>
      'Use uma URL pública acessível pelo servidor. O localhost não funciona a partir dos nossos servidores.';

  @override
  String get settingsAiConnectionSection => 'Conexão';

  @override
  String get settingsAiApiUrl => 'URL da API';

  @override
  String get settingsAiApiKey => 'Chave de API';

  @override
  String get settingsAiApiKeySaved => 'Salvo. Deixe em branco para manter.';

  @override
  String get settingsAiChatModel => 'Modelo de chat';

  @override
  String get settingsAiVisionModel => 'Modelo de visão (opcional)';

  @override
  String get settingsAiImageModel => 'Modelo de imagem (opcional)';

  @override
  String get settingsAiImageModelNote =>
      'A geração de imagens requer conclusões de chat compatíveis com a OpenAI com response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testar conexão';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get calendarGoToToday => 'Ir para hoje';

  @override
  String get calendarConnectTooltip => 'Conectar um calendário';

  @override
  String get calendarAddEvent => 'Adicionar evento';

  @override
  String get calendarEmptyTitle => 'Nada planejado';

  @override
  String get calendarEmptyBody => 'Adicione um evento e planeje o que vestir.';

  @override
  String get calendarPreviousMonth => 'Mês anterior';

  @override
  String get calendarNextMonth => 'Próximo mês';

  @override
  String get calendarAllDay => 'Dia todo';

  @override
  String get calendarOutfitLinked => 'Look vinculado';

  @override
  String get calendarEventOptions => 'Opções do evento';

  @override
  String get calendarDeleteTitle => 'Excluir este evento?';

  @override
  String get calendarChangeOutfit => 'Trocar look';

  @override
  String get calendarLinkOutfit => 'Vincular um look';

  @override
  String get calendarRemoveOutfit => 'Remover look';

  @override
  String get calendarNewEvent => 'Novo evento';

  @override
  String get calendarEditEvent => 'Editar evento';

  @override
  String get calendarTitleLabel => 'Título';

  @override
  String get calendarTitleRequired => 'Adicione um título';

  @override
  String get calendarEndBeforeStart => 'O término deve ser após o início';

  @override
  String get calendarStarts => 'Início';

  @override
  String get calendarEnds => 'Término';

  @override
  String get calendarPlaceOptional => 'Local (opcional)';

  @override
  String get calendarNotesOptional => 'Notas (opcionais)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Monte um look e depois vincule-o a este evento.';

  @override
  String get calendarBuildOutfit => 'Montar um look';

  @override
  String get calendarConnectionsTitle => 'Calendários';

  @override
  String get calendarConnectionsBody =>
      'Os eventos que você adicionar aqui ficam no FitCheck AI.';

  @override
  String get calendarDisconnect => 'Desconectar';

  @override
  String get calendarNotAvailable => 'Indisponível ainda';

  @override
  String get profileSectionExplore => 'Explorar';

  @override
  String get profileNavTryOn => 'Provador';

  @override
  String get profileNavRewards => 'Recompensas';

  @override
  String get profileSupport => 'Suporte';

  @override
  String get profileHelp => 'Ajuda';

  @override
  String get profileAbout => 'Sobre';

  @override
  String get profileAboutBody =>
      'Seu closet, seus looks e seus planos em um só lugar.';

  @override
  String get profileSignOutTitle => 'Sair da conta?';

  @override
  String get profileSignOutBody => 'Você pode entrar novamente quando quiser.';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileYourProfile => 'Seu perfil';

  @override
  String get profileBodyProfiles => 'Perfis corporais';

  @override
  String get profileBodyEmptyTitle => 'Nenhum perfil corporal ainda';

  @override
  String get profileBodyEmptyBody =>
      'Adicione sua altura e compleição para um melhor caimento.';

  @override
  String get profileBodyAdd => 'Adicionar perfil';

  @override
  String get profileBodyDefaultNote =>
      'Seu perfil padrão é usado para caimento e provador.';

  @override
  String get profileBodyDefaultBadge => 'Padrão';

  @override
  String get profileBodyMakeDefault => 'Definir como padrão';

  @override
  String get profileBodyDeleteBody => 'Esta ação não pode ser desfeita.';

  @override
  String get profileBodyRequired => 'Obrigatório';

  @override
  String get profileBodyCheckNumber => 'Verifique este número';

  @override
  String get profileBodyNew => 'Novo perfil corporal';

  @override
  String get profileBodyNameHint => 'Por exemplo, Eu';

  @override
  String get profileBodyHeight => 'Altura';

  @override
  String get profileBodyWeight => 'Peso';

  @override
  String get profileBodyBuild => 'Compleição';

  @override
  String get profileBodySkinTone => 'Tom de pele';

  @override
  String get profileBirthDateNeededBody =>
      'Adicione uma data de nascimento para acompanhar a hora.';

  @override
  String get profileBirthDateNeededTitle => 'Data de nascimento necessária';

  @override
  String get profilePartlySavedBody =>
      'Salvamento parcial de nome e foto. Os dados de nascimento não foram salvos; tente novamente.';

  @override
  String get profilePartlySavedTitle => 'Salvo parcialmente';

  @override
  String get profileSavedBody => 'Seu perfil foi salvo.';

  @override
  String get profileChangePhoto => 'Alterar foto do perfil';

  @override
  String get profilePhotoLabel => 'Foto do perfil';

  @override
  String get profilePhotoHint => 'Toque para escolher uma nova';

  @override
  String get profileBirthDateLabel => 'Data de nascimento (opcional)';

  @override
  String get profileBirthTimeLabel => 'Hora de nascimento (opcional)';

  @override
  String get profileBirthTimeHelper => 'Deixa as sugestões védicas mais exatas';

  @override
  String get profileBirthPlaceLabel => 'Local de nascimento (opcional)';

  @override
  String get profileBirthPlaceHint => 'Por exemplo, São Paulo, Brasil';

  @override
  String get profileHelpContactTitle => 'Fale conosco';

  @override
  String get profileHelpContactBody =>
      'Envie uma mensagem e responderemos por e-mail, geralmente em até um dia.';

  @override
  String get profileHelpContactAction => 'Contatar suporte';

  @override
  String get profileHelpFaqTitle => 'Perguntas frequentes';

  @override
  String get profileFaqAddPiecesTitle => 'Como adiciono peças ao meu armário?';

  @override
  String get profileFaqAddPiecesBody =>
      'Toque em Adicionar peça na aba Armário. Tire uma foto ou escolha uma da galeria; nós encontramos cada peça e a tagueamos para você.';

  @override
  String get profileFaqMatchingTitle => 'Como funciona a combinação de looks?';

  @override
  String get profileFaqMatchingBody =>
      'Abra Para você e escolha peças que você tem. Sugerimos o que combina com elas e criamos looks completos com o seu armário.';

  @override
  String get profileFaqTryOnTitle =>
      'Posso usar minhas próprias fotos para provar?';

  @override
  String get profileFaqTryOnBody =>
      'Sim. Adicione uma foto de corpo inteiro e escolha peças para vê-las em você.';

  @override
  String get profileFaqRewardsTitle => 'Como ganho recompensas?';

  @override
  String get profileFaqRewardsBody =>
      'Planeje e registre looks com frequência. Sequências e conquistas aumentam conforme você usa.';

  @override
  String get profileFaqPrivacyTitle => 'Meu armário é privado?';

  @override
  String get profileFaqPrivacyBody =>
      'Sim. Seu armário e seus looks são privados, a menos que você compartilhe o link de um look.';

  @override
  String get profileHelpMoreTitle => 'Mais ajuda';

  @override
  String get profileHelpGuides => 'Guias';

  @override
  String get profileHelpGuidesBody => 'Como cada recurso funciona';

  @override
  String get feedbackCategoryBug => 'Algo quebrou';

  @override
  String get feedbackCategoryIdea => 'Uma ideia';

  @override
  String get feedbackCategoryGeneral => 'Geral';

  @override
  String get feedbackCategoryHelp => 'Preciso de ajuda';

  @override
  String get feedbackHintBug =>
      'O que aconteceu e o que você esperava? Passos nos ajudam a corrigir.';

  @override
  String get feedbackHintIdea => 'O que você gostaria e por quê?';

  @override
  String get feedbackHintGeneral => 'Conte o que achou ou faça uma pergunta.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Você pode adicionar até 5 imagens.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limite atingido';

  @override
  String get feedbackImageTooLargeBody =>
      'Escolha uma imagem com menos de 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imagem muito grande';

  @override
  String get feedbackTitle => 'Enviar feedback';

  @override
  String get feedbackAboutLabel => 'Sobre o que é?';

  @override
  String get feedbackSubjectLabel => 'Assunto';

  @override
  String get feedbackSubjectRequired => 'Adicione um assunto';

  @override
  String get feedbackSubjectTooShort =>
      'O assunto deve ter pelo menos 3 caracteres';

  @override
  String get feedbackDetailsLabel => 'Detalhes';

  @override
  String get feedbackDetailsRequired => 'Adicione alguns detalhes';

  @override
  String get feedbackDetailsTooShort =>
      'A descrição deve ter pelo menos 10 caracteres';

  @override
  String get feedbackAddScreenshot => 'Adicionar captura de tela';

  @override
  String get feedbackAttachmentHint => 'Até 5, 5 MB cada';

  @override
  String get feedbackSend => 'Enviar';

  @override
  String get feedbackEmptyTitle => 'Nenhum envio ainda';

  @override
  String get feedbackEmptyBody =>
      'O que você enviar aparece aqui com o status.';

  @override
  String get feedbackHistoryTitle => 'O que você enviou';

  @override
  String get feedbackStatusOpen => 'Aberto';

  @override
  String get feedbackStatusInProgress => 'Em andamento';

  @override
  String get feedbackStatusResolved => 'Resolvido';

  @override
  String get feedbackStatusClosed => 'Fechado';

  @override
  String get legalIntro =>
      'Como protegemos seus dados e os termos para usar o FitCheck AI.';

  @override
  String get legalPolicies => 'Políticas';

  @override
  String get legalPrivacySubtitle => 'O que coletamos e por quê';

  @override
  String get legalTermsTitle => 'Termos de serviço';

  @override
  String get legalTermsSubtitle => 'As regras para usar o app';

  @override
  String get legalLicences => 'Licenças de código aberto';

  @override
  String get legalSupportSubtitle =>
      'Ajuda, contato e solicitações de privacidade';

  @override
  String get legalReportAbuse => 'Denunciar um problema ou abuso';

  @override
  String get permissionCameraTitle => 'Acesso à Câmera';

  @override
  String get permissionCameraRationale =>
      'O FitCheck AI usa sua câmera para tirar fotos de suas roupas e looks para provador virtual e organização do armário.';

  @override
  String get permissionPhotoTitle => 'Acesso às Fotos';

  @override
  String get permissionPhotoRationale =>
      'O FitCheck AI precisa acessar suas fotos para você selecionar imagens de roupas e looks para os recursos de IA e seu armário.';

  @override
  String get permissionNotNow => 'Agora Não';

  @override
  String get permissionOpenSettings => 'Abrir Ajustes';

  @override
  String authSignedInAs(String name) {
    return 'Conectado como $name';
  }

  @override
  String get authSignedIn => 'Conectado';

  @override
  String get authWelcomeBackTitle => 'Bem-vindo de volta';

  @override
  String get authSignInFailed => 'Falha ao entrar';

  @override
  String get authWelcomeTitle => 'Bem-vindo';

  @override
  String get authSignUpFailed => 'Falha ao cadastrar';

  @override
  String get authGoogleSignInFailed => 'Falha ao entrar com Google';

  @override
  String get authAppleSignInFailed => 'Falha ao entrar com Apple';

  @override
  String get authConfirmEmailTitle => 'Confirme seu e-mail';

  @override
  String get authConfirmEmailBody =>
      'Verifique sua caixa de entrada para confirmar o e-mail e entre.';

  @override
  String get authClosetReady => 'Seu closet está pronto.';

  @override
  String get authSignedOutTitle => 'Desconectado';

  @override
  String get authSignedOutBody => 'Você saiu da conta.';

  @override
  String get authSignOutFailed => 'Falha ao sair';

  @override
  String get authEmailSentTitle => 'E-mail enviado';

  @override
  String get authResetLinkSent =>
      'Verifique seu e-mail para obter o link de redefinição.';

  @override
  String get authPasswordUpdatedTitle => 'Senha atualizada';

  @override
  String get authPasswordUpdated => 'Sua senha foi atualizada.';

  @override
  String get authPasswordNotUpdated => 'Senha não atualizada';

  @override
  String get authCouldNotSendEmail => 'Não foi possível enviar o e-mail';

  @override
  String get authEmailNotSent => 'E-mail não enviado';

  @override
  String get authResendSentBody => 'Enviamos um novo e-mail de confirmação.';

  @override
  String get outfitPreviewWithAi => 'Pré-visualizar com IA';

  @override
  String get outfitNewPreview => 'Criar nova pré-visualização';

  @override
  String get outfitBuilderClosetHeading => 'Seu armário';

  @override
  String get outfitBuilderSearchHint => 'Buscar peças';

  @override
  String get outfitClearSearch => 'Limpar busca';

  @override
  String get outfitBuilderAddPiecesTitle => 'Adicione peças';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Looks são feitos com as peças do seu armário.';

  @override
  String get outfitBuilderNoMatches => 'Nenhuma peça encontrada.';

  @override
  String get outfitNameLabel => 'Nome do look';

  @override
  String get outfitNameHint => 'Ex.: Linho de fim de semana';

  @override
  String get outfitPreviewSemantic => 'Pré-visualização do look com IA';

  @override
  String get outfitChoosePieces => 'Escolher peças';

  @override
  String get outfitTapPiecesHint => 'Toque nas peças para adicionar.';

  @override
  String get outfitShareTooltip => 'Compartilhar';

  @override
  String get outfitSaveFavourite => 'Salvar nos favoritos';

  @override
  String get outfitPiecesHeading => 'Peças';

  @override
  String get outfitWearHistoryEmpty =>
      'Use uma vez e as datas aparecerão aqui.';

  @override
  String get outfitWearHistoryTitle => 'Histórico de uso';

  @override
  String get outfitWearHistoryError => 'Não foi possível carregar as datas.';

  @override
  String get outfitWornOn => 'Usado em';

  @override
  String get outfitEditTitle => 'Editar look';

  @override
  String get outfitSavedPhotosFailed => 'Dados salvos, fotos não';

  @override
  String get outfitNoPhotosBody => 'Sem fotos. O look exibe as peças.';

  @override
  String get outfitOccasionLabel => 'Ocasião';

  @override
  String get outfitOccasionNone => 'Nenhuma';

  @override
  String get outfitTagsHint => 'Separe por vírgulas';

  @override
  String get outfitDraftBody => 'Oculto da sua lista principal';

  @override
  String get outfitPublic => 'Público';

  @override
  String get outfitPublicBody => 'Qualquer um com o link pode ver';

  @override
  String get outfitDeleteFromDetail =>
      'Excluir este look da página de detalhes.';

  @override
  String get outfitNewCollection => 'Nova coleção';

  @override
  String get outfitNoCollectionsTitle => 'Nenhuma coleção ainda';

  @override
  String get outfitNoCollectionsBody =>
      'Agrupar looks por viagem, estação ou humor.';

  @override
  String get outfitCreateCollection => 'Criar coleção';

  @override
  String get outfitAddOutfits => 'Adicionar looks';

  @override
  String get outfitRename => 'Renomear';

  @override
  String get outfitCollectionDeleteBody => 'Os looks são mantidos.';

  @override
  String get outfitCollectionsNotLoaded => 'Looks não carregados';

  @override
  String get outfitRenameCollection => 'Renomear coleção';

  @override
  String get outfitDescriptionOptional => 'Descrição (opcional)';

  @override
  String get outfitAllInCollection => 'Todos os looks já estão nesta coleção.';

  @override
  String get photoshootSubtitleUpload =>
      'Retratos de estúdio a partir de suas fotos';

  @override
  String get photoshootSubtitleConfigure =>
      'Escolha um estilo, formato e quantidade';

  @override
  String get photoshootSubtitleGenerating => 'Isso leva um ou dois minutos';

  @override
  String get photoshootAddPhotosSemantic => 'Adicionar fotos da sua galeria';

  @override
  String get photoshootUploadTitle => 'Adicione de 1 a 4 fotos suas';

  @override
  String get photoshootUploadBody => 'Toque para escolher da sua galeria';

  @override
  String get photoshootAddToContinue => 'Adicione uma foto para continuar';

  @override
  String get photoshootAddAnotherPhoto => 'Adicionar outra foto';

  @override
  String get photoshootTipsTitle => 'Para os melhores resultados';

  @override
  String get photoshootTipsBody =>
      'Use fotos claras e bem iluminadas do seu rosto de vários ângulos. Evite óculos de sol e chapéus.';

  @override
  String get photoshootStarting => 'Iniciando';

  @override
  String get photoshootCancelling => 'Cancelando';

  @override
  String get photoshootFailed => 'Falhou';

  @override
  String get recommendTabMatches => 'Combinações';

  @override
  String get recommendTabComplete => 'Completo';

  @override
  String get recommendTabWeather => 'Clima';

  @override
  String get recommendTabColours => 'Cores';

  @override
  String get recommendTabShop => 'Loja';

  @override
  String get recommendNoMatchesTitle => 'Nenhuma combinação ainda';

  @override
  String get recommendNoMatchesBody =>
      'Escolha uma peça e mostraremos o que combina.';

  @override
  String get recommendPickPiece => 'Escolha uma peça';

  @override
  String get recommendNothingMatchesTitle =>
      'Nada combina com estas por enquanto';

  @override
  String get recommendNothingMatchesBody =>
      'Tente outras peças ou adicione mais ao seu guarda-roupa.';

  @override
  String get recommendChangePieces => 'Trocar peças';

  @override
  String get recommendDefaultReason =>
      'Combina com as peças que você escolheu.';

  @override
  String get recommendCompleteTitle => 'Complete o look';

  @override
  String get recommendCompleteBody =>
      'Escolha uma peça e completaremos o resto.';

  @override
  String get recommendWorking => 'Processando';

  @override
  String get recommendGenerate => 'Gerar';

  @override
  String get recommendChooseStyleBody => 'Escolha um estilo e gere.';

  @override
  String get recommendNoLooksTitle => 'Nenhum look para estas peças';

  @override
  String get recommendNoLooksBody => 'Tente outro estilo ou outras peças.';

  @override
  String get recommendDefaultLook => 'Um look para suas peças';

  @override
  String get recommendNoPiecesBody => 'Nenhuma peça voltou para este look.';

  @override
  String get recommendCityLabel => 'Cidade';

  @override
  String get recommendCheck => 'Verificar';

  @override
  String get recommendWeatherTitle => 'Qual o tempo?';

  @override
  String get recommendWeatherBody =>
      'Informe sua cidade para ver as sugestões de hoje.';

  @override
  String get recommendWearToday => 'Usar hoje';

  @override
  String get recommendWeatherNoPieces =>
      'Ainda não há peças no seu guarda-roupa para este tempo.';

  @override
  String get recommendBudgetLabel => 'Orçamento até';

  @override
  String get recommendLooking => 'Procurando';

  @override
  String get recommendFindWhatToBuy => 'Encontrar o que comprar';

  @override
  String get recommendFillGapsTitle => 'Preencha as lacunas';

  @override
  String get recommendFillGapsBody =>
      'Defina um orçamento e sugeriremos o que falta no seu guarda-roupa.';

  @override
  String get recommendNoGapsTitle => 'Nenhuma lacuna encontrada';

  @override
  String get recommendNoGapsBody =>
      'Tente um orçamento maior ou outra categoria.';

  @override
  String get recommendMoodEveryday => 'Dia a dia';

  @override
  String get recommendMoodBigMeeting => 'Reunião importante';

  @override
  String get recommendDayLabel => 'Dia';

  @override
  String get recommendReadingStars => 'Lendo as estrelas';

  @override
  String get recommendGetMyColours => 'Receber minhas cores';

  @override
  String get recommendLuckyColoursTitle => 'Suas cores da sorte';

  @override
  String get recommendLuckyColoursBody =>
      'Escolha um dia e sugerimos cores e peças para ele.';

  @override
  String get recommendLuckyColoursSection => 'Cores da sorte';

  @override
  String get recommendAvoidColoursSection => 'Cores para evitar';

  @override
  String get recommendBirthDateTitle => 'Adicione sua data de nascimento';

  @override
  String get recommendBirthDateBody =>
      'Precisamos da sua data de nascimento para analisar suas cores.';

  @override
  String get recommendEditProfile => 'Editar perfil';

  @override
  String get recommendNothingThisDay => 'Nada para este dia.';

  @override
  String get recommendUnnamedColour => 'Cor sem nome';

  @override
  String get recommendFromCloset => 'Do seu armário';

  @override
  String get recommendNoPiecesInColours => 'Ainda não há peças nessas cores.';

  @override
  String get recommendOutfitIdeas => 'Ideias de visual';

  @override
  String get recommendNoOutfitsInColours =>
      'Ainda não há um visual completo nessas cores.';

  @override
  String get recommendDefaultOutfitIdea => 'Uma ideia de visual';

  @override
  String get recommendPickUpToThree => 'Escolha até três peças';

  @override
  String get recommendEmptyClosetBody =>
      'Adicione algumas peças primeiro e volte para ver as combinações.';

  @override
  String get dashboardDressForDay => 'Vista-se para o dia seguinte.';

  @override
  String get dashboardOutfitOfDay => 'Visual do dia';

  @override
  String get dashboardFreshLook => 'Um visual novo';

  @override
  String get subscriptionManageInStoreTitle => 'Gerenciar na loja';

  @override
  String get subscriptionManageInStoreBody =>
      'Este plano é cobrado pela loja. Gerencie-o nas configurações da sua conta na loja.';

  @override
  String get subscriptionCancelledTitle => 'Assinatura cancelada';

  @override
  String get subscriptionCancelledBody =>
      'Seu plano permanece ativo até o final deste período de cobrança.';

  @override
  String get subscriptionCancelFailedTitle => 'Não foi possível cancelar';

  @override
  String get subscriptionCouldNotOpenTitle => 'Não foi possível abrir';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Não foi possível abrir o gerenciamento de cobranças.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Não foi possível abrir o link.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Não foi possível carregar seu link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Não foi possível carregar seu link de indicação. Tente novamente.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiado';

  @override
  String get subscriptionReferralCopiedBody => 'Link de indicação copiado.';

  @override
  String get subscriptionReferralShareSubject => 'Experimente o FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Entre no FitCheck AI e ganhe um mês de Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copiado';

  @override
  String get subscriptionShareUnavailableBody =>
      'O compartilhamento não está disponível, então copiamos o link.';

  @override
  String get subscriptionShareFailedTitle => 'Falha ao compartilhar';

  @override
  String get subscriptionShareFailedBody =>
      'Copie o link da página de indicação.';

  @override
  String get subscriptionStoreReadyTitle => 'Loja pronta';

  @override
  String get subscriptionStoreReadyBody =>
      'Os preços da loja estão disponíveis. Você já pode fazer o upgrade.';

  @override
  String get purchaseFailedTitle => 'Falha na compra';

  @override
  String get purchaseUnavailableTitle => 'Compra indisponível';

  @override
  String get purchaseIapUnavailableBody =>
      'Compras no app não estão disponíveis neste dispositivo.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Este plano ainda não está disponível para compra.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Este plano ainda não está disponível na loja. Volte em breve.';

  @override
  String get purchaseStartFailedBody =>
      'Não foi possível iniciar a compra. Tente novamente.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'O checkout não retornou um link de pagamento.';

  @override
  String get purchasePendingTitle => 'Compra pendente';

  @override
  String get purchasePendingBody =>
      'Sua compra está aguardando aprovação. Você terá acesso assim que for aprovada.';

  @override
  String get purchaseFailedBody => 'A compra falhou. Tente novamente.';

  @override
  String get purchaseRestoredTitle => 'Restaurado';

  @override
  String get purchaseRestoredBody => 'Suas compras foram restauradas.';

  @override
  String get purchaseActiveTitle => 'Assinatura ativa';

  @override
  String get purchaseActiveBody => 'Sua assinatura está ativa. Bem-vindo.';

  @override
  String get purchaseSignInRequiredTitle => 'Login necessário';

  @override
  String get purchaseSignInRequiredBody => 'Entre para concluir sua compra.';

  @override
  String get purchaseErrorTitle => 'Erro na compra';

  @override
  String get purchaseInvalidTransactionBody =>
      'A compra não incluiu um ID de transação verificável.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificação pendente';

  @override
  String get purchaseVerificationPendingBody =>
      'Não foi possível verificar sua compra agora. O processo será concluído automaticamente e você não será cobrado duas vezes.';

  @override
  String get purchaseNotAppliedTitle => 'Compra não aplicada';

  @override
  String get purchaseNotAppliedBody =>
      'Sua compra não pôde ser aplicada à sua conta. Entre em contato com o suporte e não compre novamente.';

  @override
  String get purchaseRestoreFailedTitle => 'Falha na restauração';

  @override
  String get purchaseRestoreFailedBody =>
      'Não foi possível restaurar as compras. Tente novamente.';

  @override
  String get purchaseRecoveredActiveBody => 'Sua assinatura está ativa.';

  @override
  String get purchaseCompleteTitle => 'Compra concluída';

  @override
  String get giftCreateFailedTitle => 'Não foi possível criar o presente';

  @override
  String get giftClaimFailedTitle => 'Não foi possível resgatar o presente';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presentes para você',
      one: 'Um presente para você',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mês',
      '12': '1 ano',
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
    return '$sender enviou $duration de FitCheck Pro para você. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Um presente FitCheck Pro para $recipient';
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
  String get giftPreviewPlaceholderRecipient => 'seu destinatário';

  @override
  String get giftPreviewPlaceholderSender => 'você';

  @override
  String get settingsSavedTitle => 'Salvo';

  @override
  String get settingsNotSavedTitle => 'Não salvo';

  @override
  String get settingsAiChooseProviderBody => 'Escolha um provedor.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Um provedor personalizado requer uma URL de API.';

  @override
  String get settingsAiKeyRequiredBody => 'Insira uma chave de API.';

  @override
  String get settingsAiSavedBody => 'Suas configurações de IA foram salvas.';

  @override
  String get settingsAiMissingDetailsTitle => 'Dados faltando';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Insira uma URL de API e um modelo de chat para testar.';

  @override
  String get settingsAiKeyNeededTitle => 'Chave de API necessária';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Digite sua chave de API para testar. Sua chave salva permanece privada.';

  @override
  String get settingsAiKeyToTestBody => 'Digite sua chave de API para testar.';

  @override
  String get settingsAiConnectedTitle => 'Conectado';

  @override
  String get settingsAiConnectedBody => 'A conexão funciona.';

  @override
  String get settingsAiTestFailedTitle => 'Falha no teste';

  @override
  String get settingsPreferencesSavedBody => 'Suas preferências foram salvas.';

  @override
  String get settingsPasswordNotChangedTitle => 'Senha não alterada';

  @override
  String get settingsOAuthPasswordBody =>
      'Esta conta faz login com Google ou Apple. Use \"Esqueci a senha\" para definir uma senha primeiro.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'A senha atual está incorreta.';

  @override
  String get settingsExportReadyTitle => 'Exportação pronta';

  @override
  String get settingsExportReadyBody =>
      'Sua exportação de dados está pronta para download.';

  @override
  String get settingsLinkCopiedTitle => 'Link copiado';

  @override
  String get settingsExportClipboardBody =>
      'Não conseguimos abrir seu navegador, então copiamos o link de download. Cole-o em um navegador em breve: ele expira.';

  @override
  String get settingsExportFailedTitle => 'Falha na exportação';

  @override
  String get settingsAccountNotDeletedTitle => 'Conta não excluída';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Você pode adicionar até $max fotos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limite de fotos';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Adicione pelo menos uma foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Nenhuma foto';

  @override
  String get photoshootDescribeLookBody => 'Descreva o visual que você deseja.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt necessário';

  @override
  String get photoshootConsentFeatureLabel => 'Sessão de Fotos IA';

  @override
  String get photoshootStatusPreparing => 'Preparando suas fotos';

  @override
  String get photoshootStatusGenerating => 'Gerando';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lote $current de $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done de $total concluídas';
  }

  @override
  String get photoshootGenerationFailedBody => 'Falha na geração.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready prontas, $failed falharam.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Parcialmente concluído';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos prontas.',
      one: '1 foto pronta.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Perdemos a conexão. Tente novamente.';

  @override
  String get photoshootCouldNotCancelTitle => 'Não foi possível cancelar';

  @override
  String get photoshootRetryFailedTitle => 'Falha ao tentar novamente';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'A foto $number está pronta.';
  }

  @override
  String get photoshootReplacedTitle => 'Substituída';

  @override
  String get photoshootSavedToGalleryBody => 'Salva na sua galeria.';

  @override
  String get photoshootSavedTitle => 'Salvo';

  @override
  String get photoshootNotSavedTitle => 'Não salvo';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todas as $count fotos estão na sua galeria.',
      one: '1 foto está na sua galeria.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved de $total salvas.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Algumas fotos não salvas';

  @override
  String get tryonConsentFeatureLabel => 'Provador Virtual';

  @override
  String get tryonAvatarUpdatedBody => 'Sua foto foi atualizada.';

  @override
  String get tryonSavedTitle => 'Salvo';

  @override
  String get tryonUploadFailedTitle => 'Falha no envio';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Escolha uma foto de uma peça de roupa primeiro.';

  @override
  String get tryonNoGarmentTitle => 'Sem peça de roupa';

  @override
  String get tryonWaitForUploadBody => 'Aguarde seu upload terminar.';

  @override
  String get tryonStillUploadingTitle => 'Ainda enviando';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Adicione uma foto de você primeiro.';

  @override
  String get tryonReadyBody => 'Seu provador virtual está pronto.';

  @override
  String get tryonFailedTitle => 'Falha no provador virtual';

  @override
  String get tryonSavedToGalleryBody => 'Salvo na sua galeria.';

  @override
  String get tryonNotSavedTitle => 'Não salvo';

  @override
  String get calendarEventAddedBody => 'Evento adicionado';

  @override
  String get calendarEventPlannedTitle => 'Planejado';

  @override
  String get calendarEventSavedBody => 'Evento salvo';

  @override
  String get calendarSavedTitle => 'Salvo';

  @override
  String get calendarEventNotSavedTitle => 'Evento não salvo';

  @override
  String get calendarEventRemovedBody => 'Evento removido';

  @override
  String get calendarEventDeletedTitle => 'Removido';

  @override
  String get calendarEventNotDeletedTitle => 'Evento não removido';

  @override
  String get calendarOutfitNotLinkedTitle => 'Conjunto não vinculado';

  @override
  String get calendarLinkedTitle => 'Vinculado';

  @override
  String get calendarOutfitNotRemovedTitle => 'Conjunto não removido';

  @override
  String get calendarOutfitRemovedBody => 'Conjunto removido';

  @override
  String get calendarDisconnectedBody => 'Calendário desconectado';

  @override
  String get calendarDisconnectedTitle => 'Desconectado';

  @override
  String get calendarNotDisconnectedTitle => 'Calendário não desconectado';

  @override
  String get calendarTodayLabel => 'hoje';

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
    return '\"$title\" será removido.';
  }

  @override
  String get calendarThisAppLabel => 'Este app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Sincronizar com $provider ainda não está disponível. Você ainda pode adicionar eventos aqui.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dom';

  @override
  String get calendarWeekdayMonShort => 'Seg';

  @override
  String get calendarWeekdayTueShort => 'Ter';

  @override
  String get calendarWeekdayWedShort => 'Qua';

  @override
  String get calendarWeekdayThuShort => 'Qui';

  @override
  String get calendarWeekdayFriShort => 'Sex';

  @override
  String get calendarWeekdaySatShort => 'Sáb';

  @override
  String get calendarWeekdayMonday => 'Segunda-feira';

  @override
  String get calendarWeekdayTuesday => 'Terça-feira';

  @override
  String get calendarWeekdayWednesday => 'Quarta-feira';

  @override
  String get calendarWeekdayThursday => 'Quinta-feira';

  @override
  String get calendarWeekdayFriday => 'Sexta-feira';

  @override
  String get calendarWeekdaySaturday => 'Sábado';

  @override
  String get calendarWeekdaySunday => 'Domingo';

  @override
  String get outfitSavedToFavouritesBody => 'Salvo nos favoritos';

  @override
  String get outfitRemovedFromFavouritesBody => 'Removido dos favoritos';

  @override
  String get outfitNotSavedTitle => 'Não salvo';

  @override
  String get outfitLoggedAsWornBody => 'Registrado como usado hoje.';

  @override
  String get outfitNicePickTitle => 'Ótima escolha';

  @override
  String get outfitRemovedBody => 'Look removido.';

  @override
  String get outfitDeletedTitle => 'Excluído';

  @override
  String get outfitNotDeletedTitle => 'Não excluído';

  @override
  String get outfitDuplicatedBody => 'Uma cópia está nos seus looks.';

  @override
  String get outfitDuplicatedTitle => 'Duplicado';

  @override
  String get outfitNotDuplicatedTitle => 'Não duplicado';

  @override
  String get outfitNotSharedTitle => 'Não compartilhado';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" está pronto.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Coleção não criada';

  @override
  String get outfitCollectionUpdatedBody => 'Coleção atualizada.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Coleção não atualizada';

  @override
  String get outfitCollectionDeletedBody => 'Coleção excluída.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Coleção não excluída';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count looks adicionados.',
      one: '1 look adicionado.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Looks não adicionados';

  @override
  String get outfitPreviewNotCreatedTitle => 'Pré-visualização não criada';

  @override
  String get outfitGiveNameBody => 'Dê um nome ao look.';

  @override
  String get outfitNameMissingTitle => 'Nome';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Escolha pelo menos uma peça.';

  @override
  String outfitCreatedBody(String name) {
    return '$name está nos seus looks.';
  }

  @override
  String get outfitSavedTitle => 'Salvo';

  @override
  String get wardrobeAddedToFavouritesBody => 'Adicionado aos favoritos';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Removido dos favoritos';

  @override
  String get wardrobeNotSavedTitle => 'Não salvo';

  @override
  String get wardrobeLoggedAsWornBody => 'Registrado como usado hoje.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Removido do seu guarda-roupa.';

  @override
  String get wardrobeDeletedTitle => 'Excluído';

  @override
  String get wardrobeNotDeletedTitle => 'Não excluído';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças removidas do seu guarda-roupa.',
      one: '1 peça removida do seu guarda-roupa.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extração de Guarda-Roupa por IA';

  @override
  String get itemAddScanJobLabel => 'Escaneiar';

  @override
  String get itemAddFoundEarlierBody =>
      'Encontrado em um escaneamento anterior';

  @override
  String get itemAddLookingAtPhoto => 'Analisando sua foto';

  @override
  String get itemAddExtractionFailedBody => 'Falha na extração';

  @override
  String get itemAddJobFailedBody => 'Falha na tarefa';

  @override
  String get itemAddConnectionLostBody =>
      'A conexão foi perdida. Tente novamente.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Conexão perdida durante o processamento.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Peça $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Peça';

  @override
  String get itemAddNotCancelledTitle => 'Não cancelado';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças estão no seu guarda-roupa.',
      one: '1 peça está no seu guarda-roupa.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved de $total peças salvas. Toque em salvar para tentar o restante.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Algumas peças não salvas';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Escolha pelo menos uma foto.';

  @override
  String get batchPhotoUnreadableBody => 'Esta foto não pôde ser lida.';

  @override
  String get batchNoPhotosReadableBody =>
      'Nenhuma destas fotos pôde ser lida. Tente outras.';

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
      'Perdemos a conexão durante o processamento. Tente novamente.';

  @override
  String get batchNotCancelledTitle => 'Não cancelado';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Links de post não são suportados. Insira um link de perfil.';

  @override
  String get batchLinkSpacesBody => 'Links não podem conter espaços.';

  @override
  String get batchEnterProfileLinkBody =>
      'Insira um link de perfil do Instagram ou Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Insira um link de perfil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'A página de login não abriu. Tente novamente.';

  @override
  String get batchSignInBrowserBody =>
      'Entre na sua conta pelo navegador e depois volte para o FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Conectar sua conta';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Digite o código do seu app de autenticação.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'O Instagram pede uma verificação de segurança. Entre pelo navegador primeiro.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Digite seu usuário e senha novamente.';

  @override
  String get batchSignInFailedBody =>
      'Falha ao entrar. Verifique seu usuário e senha.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Entre para continuar importando.';

  @override
  String get batchAccountNotConnectedBody => 'Sua conta não foi conectada.';

  @override
  String get batchAccountConnectedTitle => 'Conta conectada';

  @override
  String get batchNotConnectedTitle => 'Não conectado';

  @override
  String get batchImportConnectionLostBody =>
      'Perdemos a conexão com a importação. Atualize para verificar.';

  @override
  String batchPickUpToBody(int max) {
    return 'Escolha até $max fotos. Nós encontramos as peças.';
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
      other: 'Encontrar peças em $count fotos',
      one: 'Encontrar peças em 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Sua conta $platform usa verificação em duas etapas. Digite o código de 6 dígitos do seu app de autenticação.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Este perfil $platform é privado ou precisa de login para exibir fotos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Conectar com $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos encontradas até agora',
      one: '1 foto encontrada até agora',
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
    return '$processed de $total processadas · $added adicionadas · $waiting aguardando · $skipped puladas';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Escaneando foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number é a próxima';
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
      other: '$count peças encontradas',
      one: '1 peça encontrada',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos foram adicionadas ao seu armário.',
      one: '1 foto foi adicionada ao seu armário.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos do estúdio a mais no caminho. Você pode salvar o que está pronto, ou sair — avisaremos.',
      one:
          '1 foto do estúdio a mais no caminho. Você pode salvar o que está pronto, ou sair — avisaremos.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Ainda não salvos: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces peças',
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
    return '$chosen escolhidas. Toque em uma peça para pular.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvando $count peças',
      one: 'Salvando 1 peça',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvar $count peças',
      one: 'Salvar 1 peça',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Seu perfil corporal foi salvo.';

  @override
  String get bodyProfileSavedTitle => 'Salvo';

  @override
  String get bodyProfileNotSavedTitle => 'Não salvo';

  @override
  String get bodyProfileSetDefaultBody => 'Defina como seu perfil padrão.';

  @override
  String get bodyProfileDeletedBody => 'Perfil corporal excluído.';

  @override
  String get bodyProfileDeletedTitle => 'Excluído';

  @override
  String get bodyProfileNotDeletedTitle => 'Não excluído';

  @override
  String get feedbackNotSentTitle => 'Não enviado';

  @override
  String get feedbackSentBody =>
      'Obrigado. Lê todas as mensagens e responde se precisar de mais informações.';

  @override
  String get feedbackSentTitle => 'Feedback enviado';

  @override
  String get recommendUnnamedPiece => 'Peça sem nome';

  @override
  String get recommendEnterCityBody =>
      'Digite sua cidade para receber sugestões do clima.';

  @override
  String get recommendWhichCityTitle => 'Qual cidade?';

  @override
  String get aiConsentSheetTitle => 'Compartilhar fotos com um serviço de IA';

  @override
  String get aiConsentSheetBody =>
      'Para criar suas imagens de provador virtual e ensaio, o FitCheck AI envia as fotos que você fornece (incluindo imagens do seu rosto e corpo) para um provedor de IA de terceiros confiável (como OpenAI ou Google Gemini) para processamento. Eles geram suas imagens e não as usam para treinar seus modelos sob nossos termos. As fotos são transmitidas com segurança e nunca são compartilhadas para fins de publicidade.';

  @override
  String get aiConsentSheetPermission =>
      'Ao continuar, você dá permissão explícita para compartilhar suas fotos com esses provedores de IA para geração de imagens.';

  @override
  String get skeletonsLoadMoreFailed => 'Não foi possível carregar mais.';

  @override
  String get jobsPiecesReadyTitle => 'Suas peças estão prontas';

  @override
  String get jobsScanStoppedTitle => 'A varredura foi interrompida';

  @override
  String get jobsNothingSavedBody => 'Nada foi salvo. Tente novamente.';

  @override
  String get jobsPhotoUploadFailedBody => 'Falha no envio da foto.';

  @override
  String get authGoogleSignInStartFailed =>
      'Não foi possível iniciar o login com o Google. Tente novamente.';

  @override
  String get referralAppliedTitle => 'Indicação aplicada!';

  @override
  String get billingStoreUnavailableBody =>
      'Compras na loja não estão disponíveis neste dispositivo.';

  @override
  String get billingPurchaseProcessingBody =>
      'Esta compra ainda está em processamento. Reabra o app em um minuto para ver seu plano.';

  @override
  String get profileAvatarUploadNoUrl =>
      'O upload do avatar não retornou uma URL de imagem.';

  @override
  String get rewardsDayStreakLabel => 'sequência de dias';

  @override
  String rewardsBestStreak(int days) {
    return 'Melhor sequência de $days dias';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Acesso a $permission necessário';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Acesso a $permission está negado. Abra Configurações para permitir e tente novamente.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Etapa $step de 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Etapa $step de $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Remover imagem $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Remover imagem $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'E-mail $email. Avaliamos relatórios em 24 horas.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Remover $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Adicionar a \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" foi removido. As peças continuam no seu closet.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Mostrar os $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restantes hoje';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index falhou';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected de $max fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape físico · pele $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opções para $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Mais usado: $name, $count vezes';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: não definido';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% compatível';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked de $max selecionados';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Remover $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioridade $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Este plano é faturado pelo $store. Altere ou cancele nas configurações da sua conta no $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gerenciar no $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current de $max usados';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Faltam cerca de ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done de $total fotos do estúdio prontas';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready de $total fotos do estúdio prontas. Toque em uma peça para pular.';
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
  String get profileFieldNotSet => 'Não';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Início';

  @override
  String get tabPhotoshoot => 'Fotos';

  @override
  String get tabCloset => 'Closet';

  @override
  String get tabOutfits => 'Looks';

  @override
  String get tabMore => 'Mais';

  @override
  String get actionAddItem => 'Adicionar item';

  @override
  String get actionCreateOutfit => 'Criar look';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionNext => 'Próximo';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get stateLoading => 'Carregando';

  @override
  String get stateErrorTitle => 'Algo deu errado';

  @override
  String get stateErrorBody =>
      'Tente novamente. Se o erro persistir, contate o suporte.';

  @override
  String get stateOfflineTitle => 'Você está offline';

  @override
  String get stateOfflineBody =>
      'Conecte-se para sincronizar seu closet e gerar looks.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAccountSection => 'Conta';

  @override
  String get settingsPreferencesSection => 'Preferências';

  @override
  String get settingsPlanBilling => 'Plano e pagamento';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsUnits => 'Unidades de medida';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsPrivacySection => 'Privacidade e dados';

  @override
  String get settingsAboutSection => 'Sobre';

  @override
  String get settingsSignOut => 'Sair';

  @override
  String get settingsDeleteAccount => 'Excluir conta';

  @override
  String get settingsDeleteAccountTitle => 'Excluir sua conta?';

  @override
  String get settingsDeleteAccountBody =>
      'Isso removerá seu guarda-roupa, looks, fotos e perfil. Esta ação não pode ser desfeita.';

  @override
  String get settingsUnitsImperial => 'Imperial (pol, lb)';

  @override
  String get settingsUnitsMetric => 'Métrico (cm, kg)';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Usar idioma do dispositivo';

  @override
  String get languageSystemBody =>
      'O FitCheck AI segue o idioma do seu celular.';

  @override
  String get languageSearchHint => 'Buscar idiomas';

  @override
  String get languageCurrent => 'Atual';

  @override
  String get languageReviewNote =>
      'Esta tradução é nova. Avise-nos se algo parecer incorreto.';

  @override
  String get languageChanged => 'Idioma atualizado';

  @override
  String get paywallTitle => 'Escolha seu plano';

  @override
  String get paywallTrialBadge => '1 mês grátis';

  @override
  String get paywallTrialTitle => 'Seu primeiro mês de Pro é grátis';

  @override
  String get paywallTrialBody =>
      'Envie todo o seu guarda-roupa de uma vez. Adicione peças conforme necessário depois.';

  @override
  String get paywallFreeForeverTitle => 'Grátis para sempre';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Sem cartão. Todo mês você recebe $uploads envios por IA, $outfits looks e $images fotos de ensaio por dia.';
  }

  @override
  String get paywallCtaTrial => 'Iniciar meu mês grátis';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Assinar $plan';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallManage => 'Gerenciar assinatura';

  @override
  String get paywallTerms => 'Termos de uso';

  @override
  String get paywallPrivacy => 'Política de privacidade';

  @override
  String get paywallPerMonth => 'por mês';

  @override
  String get paywallPerYear => 'por ano';

  @override
  String get paywallBestValue => 'Melhor custo-benefício';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Teste grátis apenas para novos assinantes. Após o período de teste, o Pro renova por $price, a menos que seja cancelado com pelo menos 24 horas de antecedência.';
  }

  @override
  String get introTitle => 'Seu guarda-roupa, finalmente organizado';

  @override
  String get introBody =>
      'Fotografe suas roupas uma vez. Receba ideias de looks, prévias de prova e fotos de estúdio com o que você já tem.';

  @override
  String get introStart => 'Começar';

  @override
  String get introHaveAccount => 'Já tenho uma conta';

  @override
  String get introSkip => 'Pular';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authSignUp => 'Criar conta';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Senha';

  @override
  String get authForgotPassword => 'Esqueceu a senha?';

  @override
  String get authContinueApple => 'Continuar com Apple';

  @override
  String get authContinueGoogle => 'Continuar com Google';

  @override
  String get authOrDivider => 'ou';

  @override
  String get wardrobeTitle => 'Closet';

  @override
  String get wardrobeEmptyTitle => 'Seu closet está vazio';

  @override
  String get wardrobeEmptyBody =>
      'Adicione sua primeira peça ou envie uma foto de todo o cabideiro de uma vez.';

  @override
  String get wardrobeAddFirst => 'Adicionar primeiro item';

  @override
  String get wardrobeSearchHint => 'Buscar no closet';

  @override
  String get categoryTops => 'Blusas';

  @override
  String get categoryBottoms => 'Calças e Saias';

  @override
  String get categoryShoes => 'Calçados';

  @override
  String get categoryAccessories => 'Acessórios';

  @override
  String get categoryOuterwear => 'Casacos';

  @override
  String get categorySwimwear => 'Moda Praia';

  @override
  String get categoryActivewear => 'Moda Esportiva';

  @override
  String get categoryOther => 'Outros';

  @override
  String get conditionClean => 'Limpo';

  @override
  String get conditionDirty => 'Sujo';

  @override
  String get conditionLaundry => 'Na lavanderia';

  @override
  String get conditionRepair => 'Precisa de reparo';

  @override
  String get conditionDonate => 'Para doar';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Verão';

  @override
  String get seasonFall => 'Outono';

  @override
  String get seasonWinter => 'Inverno';

  @override
  String get seasonAll => 'Todas as estações';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Executivo';

  @override
  String get styleSporty => 'Esportivo';

  @override
  String get styleBohemian => 'Boho';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romântico';

  @override
  String get styleEdgy => 'Ousado';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artístico';

  @override
  String get styleClassic => 'Clássico';

  @override
  String get styleElegant => 'Elegante';

  @override
  String get styleOther => 'Outro';

  @override
  String get occasionWork => 'Trabalho';

  @override
  String get occasionDateNight => 'Encontro';

  @override
  String get occasionTravel => 'Viagem';

  @override
  String get occasionWedding => 'Casamento';

  @override
  String get occasionGym => 'Academia';

  @override
  String get occasionWeekend => 'Fim de semana';

  @override
  String get occasionParty => 'Festa';

  @override
  String get occasionInterview => 'Entrevista';

  @override
  String get colorBlack => 'Preto';

  @override
  String get colorWhite => 'Branco';

  @override
  String get colorGrey => 'Cinza';

  @override
  String get colorNavy => 'Azul-marinho';

  @override
  String get colorBrown => 'Marrom';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorBeige => 'Bege';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count semanas',
      one: 'há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count meses',
      one: 'há 1 mês',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count anos',
      one: 'há 1 ano',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Gostando do FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Uma avaliação rápida ajuda outras pessoas a encontrarem seu estilo.';

  @override
  String get ratingPromptYes => 'Avaliar o app';

  @override
  String get ratingPromptNo => 'Agora não';

  @override
  String get closetNoMatchesTitle => 'Nenhuma peça encontrada';

  @override
  String get closetNoMatchesBody => 'Tente menos filtros ou outra busca.';

  @override
  String get closetClearFilters => 'Limpar filtros';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças',
      one: '1 peça',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'Carregando suas peças';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionadas',
      one: '1 selecionada',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Excluir selecionadas';

  @override
  String get closetCancelSelection => 'Cancelar seleção';

  @override
  String get closetCloseSearch => 'Fechar busca';

  @override
  String get closetShowGrid => 'Ver em grade';

  @override
  String get closetShowList => 'Ver em lista';

  @override
  String get closetShowRows => 'Ver em linhas';

  @override
  String get closetStatsTitle => 'Estatísticas do closet';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count peças?',
      one: 'Excluir 1 peça?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody => 'Looks que as utilizam perderão essas peças.';

  @override
  String get closetSortBy => 'Ordenar por';

  @override
  String get closetFavourites => 'Favoritos';

  @override
  String get closetFavourite => 'Favoritar';

  @override
  String get closetUnfavourite => 'Remover favorito';

  @override
  String get closetWoreToday => 'Usei hoje';

  @override
  String closetWornTimes(int count) {
    return 'Usado $count×';
  }

  @override
  String get closetCategoryLabel => 'Categoria';

  @override
  String get closetUseCaseLabel => 'Ocasião';

  @override
  String get closetAnyUseCase => 'Qualquer';

  @override
  String get closetOtherUseCase => 'Outra ocasião';

  @override
  String get closetOtherUseCaseHint => 'Por exemplo, brunch';

  @override
  String get closetUseUseCase => 'Usar esta';

  @override
  String get closetClearAll => 'Limpar tudo';

  @override
  String get sortNewest => 'Mais recentes primeiro';

  @override
  String get sortOldest => 'Mais antigos';

  @override
  String get sortName => 'Nome (A–Z)';

  @override
  String get sortMostWorn => 'Mais usados';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Encontro';

  @override
  String get useCaseDinner => 'Jantar';

  @override
  String get useCaseLunch => 'Almoço';

  @override
  String get actionSelect => 'Selecionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get actionSort => 'Ordenar';

  @override
  String get actionAll => 'Todos';

  @override
  String get dashboardStartClosetTitle => 'Comece seu closet';

  @override
  String get dashboardStartClosetBody =>
      'Fotografe algumas peças. Nós as etiquetamos para você.';

  @override
  String get dashboardPieces => 'peças';

  @override
  String get dashboardOutfits => 'looks';

  @override
  String get dashboardDayStreak => 'dias seguidos';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count este mês';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Melhor $count';
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
      other: '$count looks salvos',
      one: '1 look salvo',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Mais usado: $name, $count vezes';
  }

  @override
  String get setupSkip => 'Pular configuração';

  @override
  String get setupWhoTitle => 'Quem vamos vestir?';

  @override
  String get setupWhoBody =>
      'Define o modelo para provador e fotos. Você pode alterar no seu perfil.';

  @override
  String get setupStyleTitle => 'O que você mais usa?';

  @override
  String get setupStyleBody =>
      'Escolha qualquer um. Ideias de looks começam por aqui.';

  @override
  String get setupClosetTitle => 'Adicione suas primeiras peças.';

  @override
  String get setupClosetBody =>
      'Fotografe algumas roupas, ou uma pilha delas. Cada peça é recortada e organizada para você.';

  @override
  String get setupAddClothes => 'Adicionar roupas';

  @override
  String get setupStylesLabel => 'Estilos';

  @override
  String get setupOccasionsLabel => 'Ocasiões';

  @override
  String get setupSkipStep => 'Pular';

  @override
  String get setupLater => 'Depois';

  @override
  String get setupSaveError => 'Não foi possível salvar';

  @override
  String get genderWomen => 'Feminino';

  @override
  String get genderMen => 'Masculino';

  @override
  String get genderNonBinary => 'Não binário';

  @override
  String get genderPreferNotToSay => 'Prefiro não dizer';

  @override
  String get outfitEmptyTitle => 'Nenhum look ainda';

  @override
  String get outfitEmptyBody =>
      'Combine peças do seu guarda-roupa e salve o look.';

  @override
  String get outfitNoMatchesTitle => 'Nenhum look encontrado';

  @override
  String get outfitSearchHint => 'Buscar looks';

  @override
  String get outfitLoading => 'Carregando seus looks';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count looks',
      one: '1 look',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Estilo e estação';

  @override
  String get outfitCollections => 'Coleções';

  @override
  String get outfitDuplicate => 'Duplicar';

  @override
  String get outfitDeleteTitle => 'Excluir este look?';

  @override
  String get outfitDeleteBody => 'As peças continuarão no seu guarda-roupa.';

  @override
  String get outfitDrafts => 'Rascunhos';

  @override
  String get outfitDraft => 'Rascunho';

  @override
  String get filterStyle => 'Estilo';

  @override
  String get filterSeason => 'Estação';

  @override
  String get itemDetailDeleteTitle => 'Excluir esta peça?';

  @override
  String get itemDetailDeleteBody => 'Looks que usam esta peça serão afetados.';

  @override
  String get itemAddFavourite => 'Adicionar aos favoritos';

  @override
  String itemSize(String size) {
    return 'Tamanho $size';
  }

  @override
  String get itemColours => 'Cores';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Estampa';

  @override
  String get itemUseCases => 'Ocasiões';

  @override
  String get itemKeptIn => 'Guardado em';

  @override
  String get itemPrice => 'Preço';

  @override
  String get itemBought => 'Comprado';

  @override
  String get itemTags => 'Etiquetas';

  @override
  String get itemAdded => 'Adicionado';

  @override
  String get itemTimesWornLabel => 'vezes usado';

  @override
  String get itemLastWornLabel => 'último uso';

  @override
  String get itemNeverWorn => 'Nunca';

  @override
  String get authEntryBody =>
      'Cada peça que você possui, estilizada por IA. Planeje looks, prove-os e fotografe.';

  @override
  String get authCreateCloset => 'Criar seu closet';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta';

  @override
  String get authSignInBody => 'Entre para abrir seu closet.';

  @override
  String get authCreateAccount => 'Criar uma conta';

  @override
  String get authCreateClosetBody =>
      'Leva um minuto. Seus primeiros itens são gratuitos.';

  @override
  String get authName => 'Nome';

  @override
  String get authConfirmPassword => 'Confirmar senha';

  @override
  String get authReferralCode => 'Código de indicação (opcional)';

  @override
  String get authResetTitle => 'Redefinir sua senha';

  @override
  String get authResetBody =>
      'Enviaremos um link por e-mail para criar uma nova.';

  @override
  String get authSendResetLink => 'Enviar link de redefinição';

  @override
  String get authBackToSignIn => 'Voltar para entrar';

  @override
  String get authEnterEmail => 'Insira seu e-mail';

  @override
  String get authEnterValidEmail => 'Insira um e-mail válido';

  @override
  String get authEnterPassword => 'Insira sua senha';

  @override
  String get authPasswordTooShort => 'Pelo menos 6 caracteres';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String get authNewHere => 'Novo por aqui?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirme $email antes de entrar. Verifique sua caixa de entrada.';
  }

  @override
  String get authResendEmail => 'Enviar novamente';

  @override
  String get authResendingEmail => 'Enviando…';

  @override
  String get authPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get authEnterName => 'Insira seu nome';

  @override
  String get authChoosePassword => 'Escolha uma senha';

  @override
  String get authHaveAccount => 'Já tem uma conta?';

  @override
  String get authCodeAccepted => 'Código aceito';

  @override
  String get authCodeNotFound => 'Código não encontrado';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Ambos ganham um mês grátis.';
  }

  @override
  String get authReferralInvalid => 'Não foi possível encontrar este código.';

  @override
  String authResetSent(String email) {
    return 'Enviado para $email. Abra o link neste celular.';
  }

  @override
  String get introSlide1Title => 'Fotografe seu guarda-roupa.';

  @override
  String get introSlide1Body =>
      'Tire uma foto de uma pilha de roupas. Cada peça é recortada e organizada para você.';

  @override
  String get introSlide2Title => 'Vista-se mais rápido.';

  @override
  String get introSlide2Body =>
      'Looks com o que você já tem, combinados com seus planos e o clima.';

  @override
  String get introSlide3Title => 'Veja antes de vestir.';

  @override
  String get introSlide3Body =>
      'Experimente looks na sua própria foto ou fotografe como uma campanha.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Atualizações por e-mail';

  @override
  String get settingsEmailUpdatesBody => 'Novidades e dicas por e-mail';

  @override
  String get settingsOutfitReminders => 'Lembretes de looks';

  @override
  String get settingsOutfitRemindersBody =>
      'Um aviso para registrar o que você vestiu';

  @override
  String get settingsWeeklySummary => 'Resumo semanal';

  @override
  String get settingsWeeklySummaryBody => 'Sua semana em looks';

  @override
  String get settingsStyleSection => 'Estilo';

  @override
  String get settingsPreferredStyles => 'Estilos que você gosta';

  @override
  String get settingsPreferredColours => 'Cores que você gosta';

  @override
  String get settingsNoneChosen => 'Nenhum escolhido';

  @override
  String get settingsPlanAiSection => 'Plano e IA';

  @override
  String get settingsPlanBillingBody => 'Plano, uso e upgrades';

  @override
  String get settingsPlanUsageBody => 'Plano e uso';

  @override
  String get settingsInviteFriends => 'Convidar amigos';

  @override
  String get settingsInviteFriendsBody =>
      'Um mês grátis para cada amigo que entrar';

  @override
  String get settingsAiProvider => 'Provedor de IA';

  @override
  String get settingsAiProviderBody =>
      'Use seu próprio modelo para etiquetas e imagens';

  @override
  String get settingsAppVersion => 'Versão do app';

  @override
  String get settingsPrivacyTerms => 'Privacidade e termos';

  @override
  String get settingsReportProblem => 'Relatar um problema';

  @override
  String get settingsChangePassword => 'Alterar senha';

  @override
  String get settingsExportData => 'Exportar seus dados';

  @override
  String get settingsExportBody =>
      'Preparamos um arquivo com tudo o que você salvou e abrimos o download.';

  @override
  String get settingsExportAction => 'Exportar';

  @override
  String get settingsCurrentPassword => 'Senha atual';

  @override
  String get settingsNewPassword => 'Nova senha';

  @override
  String get settingsConfirmNewPassword => 'Confirmar nova senha';

  @override
  String get settingsEnterCurrentPassword => 'Digite sua senha atual';

  @override
  String get settingsEnterNewPassword => 'Digite uma nova senha';

  @override
  String get settingsPasswordMin8 => 'Use pelo menos 8 caracteres';

  @override
  String get settingsPasswordNeedsUpper => 'Adicione uma letra maiúscula';

  @override
  String get settingsPasswordNeedsLower => 'Adicione uma letra minúscula';

  @override
  String get settingsPasswordNeedsDigit => 'Adicione um número';

  @override
  String get settingsPasswordsNoMatch => 'As senhas não coincidem';

  @override
  String get settingsChangeAction => 'Alterar';

  @override
  String get itemAddSnapTitle => 'Fotografe uma peça';

  @override
  String get itemAddSnapBody =>
      'Identificamos cada peça na foto e criamos uma imagem de estúdio limpa.';

  @override
  String get itemAddCamera => 'Tirar foto';

  @override
  String get itemAddGallery => 'Escolher da galeria';

  @override
  String get itemAddOtherWays => 'Outras formas de adicionar';

  @override
  String get itemAddSeveral => 'Adicionar várias fotos';

  @override
  String get itemAddSeveralBody => 'Até 50 de uma vez';

  @override
  String get itemAddImportProfile => 'Importar de um perfil';

  @override
  String get itemAddImportProfileBody => 'Instagram ou Facebook';

  @override
  String get itemAddEnterDetails => 'Inserir detalhes manualmente';

  @override
  String get itemAddEnterDetailsBody => 'Não é necessária foto';

  @override
  String get itemManualIntro =>
      'Apenas um nome é necessário. Adicione o restante agora ou depois.';

  @override
  String get itemManualNameHint => 'Exemplo: camiseta azul de algodão';

  @override
  String get itemManualEnterName => 'Digite um nome';

  @override
  String get itemManualNotes => 'Notas';

  @override
  String get itemManualBrand => 'Marca';

  @override
  String get itemManualSize => 'Tamanho';

  @override
  String get itemManualEnterNumber => 'Digite um número';

  @override
  String get itemManualSavePiece => 'Salvar peça';

  @override
  String get itemManualSaving => 'Salvando';

  @override
  String get itemManualSavedTitle => 'Salvo';

  @override
  String itemManualSavedBody(String name) {
    return '$name está no seu closet.';
  }

  @override
  String get itemManualNotSaved => 'Não salvo';

  @override
  String get itemManualAddUseCase => 'Adicionar ocasião';

  @override
  String get itemManualAddUseCaseAction => 'Adicionar ocasião';

  @override
  String get itemPhotos => 'Fotos';

  @override
  String get itemAddPhotos => 'Adicionar fotos';

  @override
  String get itemNoPhotoYet => 'Sem foto ainda. Você pode salvar sem uma.';

  @override
  String get itemRemovePhoto => 'Remover foto';

  @override
  String get itemRemovePiece => 'Remover peça';

  @override
  String get filterConditionLabel => 'Condição';

  @override
  String get photoshootStepPhotos => 'Fotos';

  @override
  String get photoshootStepSetup => 'Configuração';

  @override
  String get photoshootStepCreating => 'Criando';

  @override
  String get photoshootStepResults => 'Resultados';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Passo $current de $total, $name';
  }

  @override
  String get photoshootOneFailed => 'Uma foto falhou. Tente novamente abaixo.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotos falharam. Tente cada uma abaixo.';
  }

  @override
  String get photoshootFormat => 'Formato';

  @override
  String get photoshootHowMany => 'Quantidade';

  @override
  String get photoshootYourPrompt => 'Seu prompt';

  @override
  String get photoshootPromptHint => 'Golden hour no terraço, camisa de linho';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Criar $count fotos',
      one: 'Criar 1 foto',
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
      'Não foi possível verificar o limite de hoje.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plano $plan: $remaining de $limit restantes hoje';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Grátis';

  @override
  String get photoshootGallery => 'Galeria';

  @override
  String get photoshootUseCamera => 'Usar câmera';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Remover foto $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Nenhuma foto retornou';

  @override
  String get photoshootNoPhotosBody =>
      'A sessão terminou sem imagens. Tente novamente.';

  @override
  String get photoshootNewStyle => 'Novo estilo';

  @override
  String get photoshootNewPhotos => 'Novas fotos';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Abrir foto $number';
  }

  @override
  String get photoshootReportPhoto => 'Denunciar foto';

  @override
  String get photoshootSaveToGallery => 'Salvar na galeria';

  @override
  String get actionUpgrade => 'Fazer upgrade';

  @override
  String get referralLimitTitle => 'Você usou as fotos de hoje';

  @override
  String get referralLimitBody =>
      'Suas fotos gratuitas retornam amanhã. Indique um amigo e ambos ganham um mês de Pro grátis.';

  @override
  String get referralLimitRefer => 'Indicar um amigo';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'App de namoro';

  @override
  String get photoshootUsePortfolio => 'Portfólio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estético';

  @override
  String get photoshootUseCustom => 'Seu próprio prompt';

  @override
  String get photoshootDescLinkedin => 'Fotos profissionais para o trabalho';

  @override
  String get photoshootDescDating => 'Descontraído, caloroso e natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, looks de alta moda';

  @override
  String get photoshootDescInstagram => 'Fotos de estilo de vida para seu feed';

  @override
  String get photoshootDescAesthetic => 'Quadros artísticos e conceituais';

  @override
  String get photoshootDescCustom => 'Descreva o visual que você deseja';

  @override
  String get aspectSquare => 'Quadrado';

  @override
  String get aspectPortrait => 'Retrato';

  @override
  String get aspectLandscape => 'Paisagem';

  @override
  String get aspectTall => 'Alto';

  @override
  String get aspectWide => 'Largo';

  @override
  String get tryOnAppBar => 'Provador virtual';

  @override
  String get tryOnYourPhoto => 'Sua foto';

  @override
  String get tryOnGarment => 'Peça';

  @override
  String get tryOnUploadingPhoto => 'Enviando sua foto';

  @override
  String get tryOnAddPhotoPrompt => 'Adicione uma foto de corpo inteiro';

  @override
  String get tryOnBodyPhotoHint => 'Uma foto de corpo inteiro funciona melhor';

  @override
  String get tryOnAddPhoto => 'Adicionar foto';

  @override
  String get tryOnChangePhoto => 'Alterar foto';

  @override
  String get tryOnPhotoLoadFailed => 'Não foi possível carregar sua foto.';

  @override
  String get tryOnChooseGarment => 'Escolha a foto da peça';

  @override
  String get tryOnChooseOneGarment => 'Escolha uma foto da peça';

  @override
  String get tryOnGarmentHint =>
      'Uma foto da peça esticada ou no cabide funciona melhor';

  @override
  String get tryOnChange => 'Alterar';

  @override
  String get tryOnCamera => 'Câmera';

  @override
  String get tryOnRemove => 'Remover';

  @override
  String get tryOnLookTitle => 'Look';

  @override
  String get tryOnStyle => 'Estilo';

  @override
  String get tryOnBackground => 'Fundo';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp =>
      'Montando seu look. Isso leva cerca de meio minuto.';

  @override
  String get tryOnEmptyResult => 'Sua prova aparecerá aqui';

  @override
  String get tryOnReportImage => 'Denunciar imagem';

  @override
  String get tryOnCreating => 'Criando';

  @override
  String get tryOnTryAgain => 'Tentar novamente';

  @override
  String get tryOnCreate => 'Criar prova';

  @override
  String get tryOnBackgroundStudioWhite => 'Estúdio branco';

  @override
  String get tryOnBackgroundStudioGrey => 'Estúdio cinza';

  @override
  String get tryOnBackgroundUrban => 'Urbano';

  @override
  String get tryOnBackgroundNature => 'Natureza';

  @override
  String get tryOnBackgroundMinimal => 'Minimalista';

  @override
  String get tryOnPoseFront => 'De frente';

  @override
  String get tryOnPoseSide => 'De lado';

  @override
  String get tryOnPoseWalking => 'Caminhando';

  @override
  String get dashboardGreetingMorning => 'Bom dia';

  @override
  String get dashboardGreetingAfternoon => 'Boa tarde';

  @override
  String get dashboardGreetingEvening => 'Boa noite';

  @override
  String get dashboardWelcome => 'Bem-vindo';

  @override
  String get dashboardOpenProfile => 'Abrir perfil';

  @override
  String get dashboardRailToday => 'Hoje';

  @override
  String get dashboardRailRecently => 'Recentes';

  @override
  String get dashboardActivityEmpty => 'Novas peças e looks aparecem aqui.';

  @override
  String get quickAddPiece => 'Adicionar peça';

  @override
  String get quickAddPieceBody => 'Fotografe e marque';

  @override
  String get quickBuildOutfit => 'Montar look';

  @override
  String get quickBuildOutfitBody => 'Combine suas peças';

  @override
  String get quickForYou => 'Para você';

  @override
  String get quickForYouBody => 'Sugestões de hoje';

  @override
  String get quickPlanWeek => 'Planejar semana';

  @override
  String get quickPlanWeekBody => 'Looks por data';

  @override
  String get referralBannerUrgent => 'Acabando? Convide um amigo.';

  @override
  String get referralBannerTitle => 'Dê um mês, ganhe um mês.';

  @override
  String get referralBannerBody => 'Você e seu amigo ganham um mês de Pro.';

  @override
  String get referralBannerDismiss => 'Dispensar por uma semana';

  @override
  String get referralBannerShare => 'Compartilhar convite';

  @override
  String get referralBannerCopy => 'Copiar link';

  @override
  String get itemEditPieceTitle => 'Editar peça';

  @override
  String get itemEditDescriptionLabel => 'Descrição';

  @override
  String get itemEditNotSaved => 'Não salvo';

  @override
  String get itemEditSavedTitle => 'Salvo';

  @override
  String get itemEditSavedBody => 'Suas alterações foram salvas.';

  @override
  String get itemEditSavedStalePhotos =>
      'Salvo — fotos podem estar desatualizadas';

  @override
  String get itemEditRemovePieceHint => 'Excluir esta peça da página do item.';

  @override
  String get itemEditNoPhotos =>
      'Sem fotos ainda. Adicione uma da galeria ou câmera.';

  @override
  String get itemEditKeepPhoto => 'Manter foto';

  @override
  String get itemEditRemoved => 'Removido';

  @override
  String get itemEditAddUseCaseAction => 'Adicionar';

  @override
  String get statsNoStatsTitle => 'Sem estatísticas ainda';

  @override
  String get statsNoStatsBody =>
      'Adicione algumas peças e o mix do seu guarda-roupa aparecerá aqui.';

  @override
  String get statsByCategory => 'Por categoria';

  @override
  String get statsTotalValue => 'valor total';

  @override
  String get statsMostWorn => 'Mais usadas';

  @override
  String get statsLeastWorn => 'Aguardando vez';

  @override
  String get statsUnnamedPiece => 'Peça sem nome';

  @override
  String get jobsTitle => 'Análises';

  @override
  String get jobsEmptyTitle => 'Sem análises ainda';

  @override
  String get jobsEmptyBody =>
      'Fotografe uma peça e envie para o processamento — ele continuará trabalhando aqui.';

  @override
  String get jobsNotCancelled => 'Não cancelado';

  @override
  String get jobsResume => 'Retomar';

  @override
  String get jobsReview => 'Revisar';

  @override
  String get jobsStop => 'Parar';

  @override
  String get jobsDismiss => 'Dispensar';

  @override
  String get reportTitle => 'Denunciar conteúdo';

  @override
  String reportIntro(String contentType) {
    return 'Diga-nos o que há de errado com este $contentType. Nossa equipe analisa todas as denúncias.';
  }

  @override
  String get reportReasonInappropriate => 'Inapropriado ou ofensivo';

  @override
  String get reportReasonNudity => 'Nudez ou conteúdo sexual';

  @override
  String get reportReasonHarassment => 'Assédio ou abuso';

  @override
  String get reportReasonImpersonation => 'Imitação de identidade';

  @override
  String get reportReasonOther => 'Outro';

  @override
  String get reportDetailsLabel => 'Detalhes adicionais (opcional)';

  @override
  String get reportSubmit => 'Enviar denúncia';

  @override
  String get reportSubmittedTitle => 'Denúncia enviada';

  @override
  String get reportSubmittedBody =>
      'Obrigado. Nossa equipe analisará este conteúdo.';

  @override
  String get reportFailedTitle => 'Não foi possível enviar';

  @override
  String get reportFailedBody => 'Por favor, tente novamente.';

  @override
  String get reportContentTryOnImage => 'imagem de provador virtual';

  @override
  String get reportContentSharedOutfit => 'look compartilhado';

  @override
  String get reportContentPhotoshootImage => 'imagem de ensaio fotográfico';

  @override
  String get sharedOutfitTitle => 'Look compartilhado';

  @override
  String get sharedOutfitHideTooltip => 'Ocultar este look';

  @override
  String get sharedOutfitReportTooltip => 'Denunciar este look';

  @override
  String get sharedOutfitHideTitle => 'Ocultar este look?';

  @override
  String get sharedOutfitHideBody =>
      'Ele ficará oculto neste dispositivo. Você também pode denunciá-lo para que nossa equipe analise e remova.';

  @override
  String get sharedOutfitHideAction => 'Ocultar';

  @override
  String get sharedOutfitHiddenInfo =>
      'Este look não aparecerá mais neste dispositivo.';

  @override
  String get sharedOutfitHiddenToast => 'Look oculto';

  @override
  String get sharedOutfitMissingTitle => 'Este look não está mais aqui';

  @override
  String get sharedOutfitMissingBody =>
      'Ele pode ter sido removido ou o link está incorreto.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Você ocultou este look';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Se for impróprio, denuncie em Privacidade e termos ou envie um e-mail para $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Gostou deste look?';

  @override
  String get sharedOutfitCtaBody =>
      'Crie looks parecidos com as peças do seu guarda-roupa.';

  @override
  String get sharedOutfitCtaButton => 'Baixar FitCheck AI';

  @override
  String get errorTitle => 'Erro';

  @override
  String get errorUnknown => 'Ocorreu um erro inesperado';

  @override
  String get errorNoConnection =>
      'Sem conexão com a internet. Verifique sua rede.';

  @override
  String get errorTimeout => 'Tempo limite excedido. Tente novamente.';

  @override
  String get errorServerError =>
      'Algo deu errado do nosso lado. Tente novamente.';

  @override
  String get errorBadGateway =>
      'Nosso servidor está indisponível brevemente. Tente novamente.';

  @override
  String get errorServiceUnavailable =>
      'Serviço temporariamente indisponível. Tente em breve.';

  @override
  String get errorInternalError => 'Algo deu errado. Tente novamente.';

  @override
  String get errorUnauthorized => 'Entre para continuar.';

  @override
  String get errorForbidden => 'Você não tem acesso a isso.';

  @override
  String get errorSessionExpired => 'Sua sessão expirou. Entre novamente.';

  @override
  String get errorInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get errorTokenRefreshFailed =>
      'Não foi possível atualizar sua sessão. Entre novamente.';

  @override
  String get errorRequestCancelled => 'Solicitação cancelada.';

  @override
  String get errorInvalidFormat => 'Formato de arquivo não suportado.';

  @override
  String get errorFileTooLarge => 'Arquivo muito grande.';

  @override
  String get errorUploadFailed => 'Falha no envio. Tente novamente.';

  @override
  String get errorCacheCorrupted => 'Dados salvos corrompidos e redefinidos.';

  @override
  String get errorCacheNotFound => 'Nada salvo ainda.';

  @override
  String get errorUserNotFound => 'Conta não encontrada.';

  @override
  String get errorItemNotFound => 'Esta peça não existe mais.';

  @override
  String get errorOutfitNotFound => 'Este look não existe mais.';

  @override
  String get rewardsTitle => 'Conquistas';

  @override
  String get rewardsNoAchievementsTitle => 'Nenhuma conquista ainda';

  @override
  String get rewardsNoAchievementsBody =>
      'Adicione peças e monte looks para ganhar a primeira.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Ninguém no ranking ainda';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Monte looks para ganhar pontos e aparecer aqui.';

  @override
  String get legalViewPrivacyPolicy => 'Ver Política de Privacidade';

  @override
  String get aiConsentAgree => 'Concordar e Continuar';

  @override
  String get aiConsentNotNow => 'Agora Não';

  @override
  String get imageViewerCloseTooltip => 'Fechar visualizador de imagem';

  @override
  String get updateReadyTitle => 'Atualização pronta';

  @override
  String get updateReadyBody =>
      'Reinicie o FitCheck AI para aplicar as melhorias mais recentes.';

  @override
  String get permissionCameraUsage =>
      'O FitCheck AI precisa de acesso à câmera para tirar fotos dos seus looks e peças do guarda-roupa.';

  @override
  String get permissionPhotoLibraryUsage =>
      'O FitCheck AI precisa de acesso à galeria de fotos para selecionar imagens dos seus looks e peças.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'O FitCheck AI precisa salvar as fotos de looks geradas por IA na sua galeria.';

  @override
  String get wardrobeSomePhotosSkipped => 'Algumas fotos foram ignoradas';

  @override
  String get wardrobePhotosNotAdded => 'Fotos não adicionadas';

  @override
  String get wardrobePhotoNotAdded => 'Foto não adicionada';

  @override
  String get wardrobeNotStartedTitle => 'Não iniciado';

  @override
  String get wardrobeNoRoomTitle => 'Sem espaço';

  @override
  String get wardrobeAddPhotosSemantic => 'Adicionar fotos';

  @override
  String get batchAddTileLabel => 'Adicionar';

  @override
  String get batchProfileLinkLabel => 'Link do perfil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importar de um perfil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Adicionar várias fotos';

  @override
  String get wardrobeClearAction => 'Limpar';

  @override
  String get wardrobeRefreshTooltip => 'Atualizar';

  @override
  String get batchNoPhotosYetTitle => 'Nenhuma foto ainda';

  @override
  String get batchChoosePhotosAction => 'Escolher fotos';

  @override
  String get batchWeFindEachPieceBody =>
      'Identificamos cada peça e criamos uma foto de estúdio dela.';

  @override
  String get batchPreparingPhotosSemantic => 'Preparando fotos';

  @override
  String get batchPhotosProcessedSemantic => 'Fotos processadas';

  @override
  String get batchPasteProfileLinkTitle => 'Colar link do perfil';

  @override
  String get batchPasteProfileLinkBody =>
      'Um perfil público do Instagram ou Facebook. Escaneamos as fotos e você escolhe o que vai para o seu closet.';

  @override
  String get batchClearLinkTooltip => 'Limpar link';

  @override
  String get batchStartingButton => 'Iniciando';

  @override
  String get batchStartImportAction => 'Iniciar importação';

  @override
  String get batchReviewEveryPhotoTitle => 'Você revisa cada foto';

  @override
  String get batchReviewEveryPhotoBody =>
      'Nada é adicionado até que você aprove.';

  @override
  String get batchPrivateProfilesTitle => 'Perfis privados';

  @override
  String get batchPrivateProfilesBody =>
      'Conecte sua conta. O Instagram também solicita usuário e senha.';

  @override
  String get batchUseAnotherLinkAction => 'Usar outro link';

  @override
  String get batchSignInNeededTitle => 'Login necessário';

  @override
  String get batchEnterYourCodeTitle => 'Insira seu código';

  @override
  String get batchUseUsernamePasswordAction => 'Usar usuário e senha';

  @override
  String get batchAlreadyConnectedAction => 'Já me conectei no navegador';

  @override
  String get batchEnterCodeAction => 'Inserir código';

  @override
  String get batchTryAnotherWayAction => 'Tentar outro modo';

  @override
  String get batchLiveStatus => 'Ao vivo';

  @override
  String get batchReconnectingStatus => 'Reconectando';

  @override
  String get batchSignInToInstagramTitle => 'Entrar no Instagram';

  @override
  String get batchUsernameLabel => 'Usuário';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Código, se usa verificação em duas etapas';

  @override
  String get batchAuthenticatorCodeBody =>
      'Use o código de 6 dígitos do seu app autenticador. Os códigos mudam rápido.';

  @override
  String get batchVerifyAction => 'Verificar';

  @override
  String get batchFindingPhotosTitle => 'Buscando fotos';

  @override
  String get batchImportPausedTitle => 'Importação pausada';

  @override
  String get batchProcessingPhotosTitle => 'Processando fotos';

  @override
  String get batchWaitingNextPhoto => 'Aguardando próxima foto';

  @override
  String get batchCancelImportAction => 'Cancelar importação';

  @override
  String get batchNoPiecesInPhotoBody => 'Nenhuma peça encontrada nesta foto.';

  @override
  String get batchEditPieceColoursLabel => 'Cores, separadas por vírgula';

  @override
  String get batchAddToClosetAction => 'Adicionar ao closet';

  @override
  String get batchSkipPhotoAction => 'Pular esta foto';

  @override
  String get batchImportCompleteTitle => 'Importação concluída';

  @override
  String get batchImportFailedTitle => 'Falha na importação';

  @override
  String get batchImportCancelledTitle => 'Importação cancelada';

  @override
  String get batchImportErrorBody => 'Algo deu errado durante a importação.';

  @override
  String get batchNothingMoreImportedBody =>
      'Nada mais será importado deste perfil.';

  @override
  String get batchViewClosetAction => 'Ver guarda-roupa';

  @override
  String get batchStartOverAction => 'Recomeçar';

  @override
  String get wardrobeAddPieceTitle => 'Adicionar peça';

  @override
  String get wardrobeAddDetailsTitle => 'Adicionar detalhes';

  @override
  String get wardrobeScanningTitle => 'Escaneando';

  @override
  String get batchReviewPiecesTitle => 'Revisar peças';

  @override
  String get wardrobeGalleryAction => 'Galeria';

  @override
  String get wardrobeCameraAction => 'Câmera';

  @override
  String get wardrobeNewBadge => 'Novo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Remover foto';

  @override
  String get batchRunInBackgroundTooltip => 'Executar em segundo plano';

  @override
  String get batchStepOneOfTwo => 'Passo 1 de 2';

  @override
  String get batchStepTwoOfTwo => 'Passo 2 de 2';

  @override
  String get batchUploadingPhotosTitle => 'Enviando fotos';

  @override
  String get batchFindingPiecesTitle => 'Encontrando peças';

  @override
  String get batchMakingStudioPhotosTitle => 'Criando fotos de estúdio';

  @override
  String get batchStoppedLabel => 'Parado';

  @override
  String get batchFindingPiecesStoppedTitle => 'Busca de peças interrompida';

  @override
  String get batchCancelledLabel => 'Cancelado';

  @override
  String get batchAllDoneTitle => 'Tudo pronto';

  @override
  String get batchOpeningPiecesBody => 'Abrindo suas peças';

  @override
  String get batchNothingSavedBody => 'Nada foi salvo.';

  @override
  String get batchFindingPiecesFailedBody => 'Falha ao encontrar peças.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'A busca de peças parou mais cedo.';

  @override
  String get batchStopFindingPiecesTitle => 'Parar busca de peças?';

  @override
  String get batchStopFindingPiecesBody =>
      'O escaneamento para e nada é salvo. As peças já encontradas ficam na sua atividade até você dispensá-las.';

  @override
  String get batchKeepGoingAction => 'Continuar';

  @override
  String get batchTryAgainAction => 'Tentar novamente';

  @override
  String get batchBackToPhotosAction => 'Voltar às fotos';

  @override
  String get batchSkipAllAction => 'Pular tudo';

  @override
  String get batchIncludeAllAction => 'Incluir tudo';

  @override
  String get batchNoPiecesFoundTitle => 'Nenhuma peça encontrada';

  @override
  String get batchNoPiecesFoundBody => 'Não encontramos roupas nestas fotos.';

  @override
  String get batchChooseOtherPhotosAction => 'Escolher outras fotos';

  @override
  String get batchUseCaseHelper => 'Adicionado a cada peça que você salvar.';

  @override
  String get batchDiscardPiecesTitle => 'Descartar estas peças?';

  @override
  String get batchDiscardPiecesBody => 'Nada deste lote será salvo.';

  @override
  String get batchKeepAction => 'Manter';

  @override
  String get batchDiscardAction => 'Descartar';

  @override
  String get batchRemovePieceTitle => 'Remover esta peça?';

  @override
  String get batchRemovePieceBody => 'Ela não foi salva no seu armário.';

  @override
  String get batchRemoveAction => 'Remover';

  @override
  String get batchChoosePiecesToSave => 'Escolher peças para salvar';

  @override
  String get batchDiscardAllAction => 'Descartar tudo';

  @override
  String get batchNothingSavedRetryBody => 'Nada foi salvo. Tente novamente.';

  @override
  String get batchNotSavedTitle => 'Não salvo';

  @override
  String get batchSavingLabel => 'Salvando';

  @override
  String get batchSendToBackgroundAction => 'Enviar para segundo plano';

  @override
  String get batchStillWorkingMessage =>
      'Trabalhando nisso. Avisaremos quando suas peças estiverem prontas.';

  @override
  String get batchRunningInBackgroundTitle => 'Executando em segundo plano';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Fotos de estúdio pararam mais cedo. Você ainda pode salvar estas peças.';

  @override
  String get batchTapPieceToSkip => 'Toque em uma peça para ignorá-la.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Fotos de estúdio a caminho. Você pode sair — avisaremos quando terminar.';

  @override
  String get batchLeaveAction => 'Sair';

  @override
  String get batchPeopleInPhotosTitle => 'Pessoas nas fotos';

  @override
  String get batchIncludeAction => 'Incluir';

  @override
  String get batchSkipAction => 'Ignorar';

  @override
  String get batchYourPhotoIsUsedLabel => 'Sua foto está sendo usada';

  @override
  String get batchMakingStudioPhotoLabel => 'Criando foto de estúdio';

  @override
  String get batchNoStudioPhotoBody =>
      'Sem foto de estúdio. Sua foto será usada.';

  @override
  String get batchEnterDetailsYourselfAction => 'Preencher dados manualmente';

  @override
  String get batchChooseAnotherPhotoAction => 'Escolher outra foto';

  @override
  String get batchConnectionLostTitle => 'Conexão perdida';

  @override
  String get batchConnectionLostBody =>
      'Verifique sua conexão e tente novamente.';

  @override
  String get batchDailyLimitTitle => 'Limite diário atingido';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Faça upgrade para o Pro para mais escaneamentos ou preencha os dados manualmente.';

  @override
  String get batchDailyLimitBodyFree =>
      'Seus escaneamentos serão renovados amanhã. Você pode preencher os dados manualmente agora.';

  @override
  String get batchSeePlansAction => 'Ver planos';

  @override
  String get batchAiBusyTitle => 'Nosso IA está ocupado';

  @override
  String get batchAiBusyBody =>
      'O problema está do nosso lado. Tente novamente em alguns minutos.';

  @override
  String get batchNoPiecesBody =>
      'Tente uma foto mais clara ou preencha os dados manualmente.';

  @override
  String get batchScanningUnavailableTitle => 'Escaneamento indisponível';

  @override
  String get batchScanningUnavailableBody =>
      'Preencha os dados manualmente por enquanto.';

  @override
  String get batchScanDidNotFinishTitle => 'O escaneamento não foi concluído';

  @override
  String get batchTryAgainBody => 'Tente novamente.';

  @override
  String get billingTitle => 'Assinatura';

  @override
  String get billingUpgradeHeading => 'Faça upgrade do seu plano';

  @override
  String get billingUpgradeOnPlusBody => 'Mesmos recursos, limites maiores.';

  @override
  String get billingUpgradeBody =>
      'Plus e Pro têm os mesmos recursos. Escolha os limites de que você precisa.';

  @override
  String get billingWebUnavailableBody =>
      'Upgrades online ainda não estão disponíveis. Um código de promoção ou indicação libera Plus ou Pro. Convide amigos abaixo para ganhar meses grátis.';

  @override
  String get billingPlansStale =>
      'Não foi possível carregar os planos mais recentes. Os preços podem estar desatualizados.';

  @override
  String get billingMonthly => 'Mensal';

  @override
  String get billingYearly => 'Anual';

  @override
  String get billingCurrentPlan => 'Plano atual';

  @override
  String get billingActive => 'Ativo';

  @override
  String get billingThisMonth => 'Este mês';

  @override
  String get billingItemExtractions => 'Extrações de itens';

  @override
  String get billingOutfitVisualizations => 'Visualizações de looks';

  @override
  String get billingNearLimitUpgrade =>
      'Você está próximo do limite deste mês. Faça upgrade para mais.';

  @override
  String get billingNearLimitResets =>
      'Você está próximo do limite deste mês. Ele será renovado no início do próximo mês.';

  @override
  String get billingStoreUnavailable =>
      'As atualizações não estão disponíveis na loja no momento. Volte em breve.';

  @override
  String get billingManageHeading => 'Gerenciar plano';

  @override
  String get billingCancelPlan => 'Cancelar assinatura';

  @override
  String get billingCancelKeepsAccess =>
      'Você mantém o acesso até o fim do período de cobrança atual.';

  @override
  String get billingCancelConfirmTitle => 'Cancelar sua assinatura?';

  @override
  String get billingKeepPlan => 'Manter plano';

  @override
  String get billingCancelPlanAction => 'Cancelar plano';

  @override
  String get billingBilledMonthly => 'Cobrança mensal';

  @override
  String get billingBilledYearly => 'Cobrança anual';

  @override
  String get billingVirtualTryOn => 'Provador virtual';

  @override
  String get billingPrioritySupport => 'Suporte prioritário';

  @override
  String get billingDisclosureProRenewing =>
      'Pro é uma assinatura com renovação automática';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus e Pro são assinaturas com renovação automática';

  @override
  String get billingDisclosureAppleBilling =>
      'O pagamento será cobrado no seu ID Apple na confirmação da compra.';

  @override
  String get billingDisclosureGoogleBilling =>
      'O pagamento será cobrado na sua conta do Google Play na confirmação da compra.';

  @override
  String get billingDisclosureRenewalTerms =>
      'Sua assinatura é renovada automaticamente pelo mesmo período e preço, a menos que você desative a renovação automática pelo menos 24 horas antes do fim do período atual.';

  @override
  String get billingDisclosureAppleManage =>
      'Gerencie ou cancele a qualquer momento em Ajustes › seu ID Apple › Assinaturas.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gerencie ou cancele a qualquer momento em Google Play › Pagamentos e assinaturas.';

  @override
  String get billingReferFriend => 'Indicar um amigo';

  @override
  String get billingHowItWorks => 'Como funciona';

  @override
  String get billingHowShareTitle => 'Compartilhe seu link';

  @override
  String get billingHowShareBody => 'Envie para um amigo.';

  @override
  String get billingHowSignUpTitle => 'Eles se cadastram';

  @override
  String get billingHowSignUpBody => 'Seu amigo entra pelo link.';

  @override
  String get billingHowBothTitle => 'Vocês ganham Pro';

  @override
  String get billingHowBothBody => 'Cada um ganha um mês de Pro grátis.';

  @override
  String get billingYourReferrals => 'Suas indicações';

  @override
  String get billingInvited => 'Convidados';

  @override
  String get billingJoined => 'Entraram';

  @override
  String get billingMonthsEarned => 'Meses ganhos';

  @override
  String get billingInviteFriend => 'Convidar um amigo';

  @override
  String get billingInviteBody => 'Você e seu amigo ganham um mês de Pro.';

  @override
  String get billingYourCode => 'Seu código';

  @override
  String get billingCopyLink => 'Copiar link';

  @override
  String get billingShareInvite => 'Compartilhar convite';

  @override
  String get giftUnavailable =>
      'Convites de presente indisponíveis nesta versão.';

  @override
  String get giftPageTitle => 'Oferecer FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'Nenhum convite de presente gratuito disponível no momento.';

  @override
  String get giftFormTitle => 'Enviar um convite gratuito';

  @override
  String get giftFormBody =>
      'O destinatário resgata o presente com este e-mail verificado. Nós não enviamos o e-mail por você.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nome do destinatário';

  @override
  String get giftFieldRecipientEmail => 'E-mail do destinatário';

  @override
  String get giftFieldOccasion => 'Ocasião (opcional)';

  @override
  String get giftNoOccasion => 'Sem ocasião';

  @override
  String get giftOccasionBirthday => 'Aniversário';

  @override
  String get giftOccasionAnniversary => 'Bodas';

  @override
  String get giftOccasionOther => 'Outro';

  @override
  String get giftFieldCardGreeting => 'Mensagem do cartão';

  @override
  String get giftFieldCardGreetingHelper =>
      'Isso aparece no cartão exatamente como escrito.';

  @override
  String get giftFieldPrivateNote => 'Nota privada (opcional)';

  @override
  String get giftCreateAction => 'Criar presente gratuito';

  @override
  String get giftClaimedTitle => 'Presente resgatado';

  @override
  String get giftClaimedActive => 'Seu presente do FitCheck Pro está ativo.';

  @override
  String get giftClaimedQueued =>
      'Seu presente do FitCheck Pro começa após o acesso atual.';

  @override
  String get giftLinkCopied =>
      'Link do presente copiado para a área de transferência.';

  @override
  String get giftErrorName => 'Insira um nome.';

  @override
  String get giftErrorEmail => 'Insira um endereço de e-mail válido.';

  @override
  String get giftErrorGreeting => 'Insira a mensagem do cartão.';

  @override
  String get giftErrorGreetingLength => 'Use no máximo 80 caracteres.';

  @override
  String get giftClaimAction => 'Resgatar presente';

  @override
  String get giftCardPreview => 'Visualizar cartão';

  @override
  String get giftGiftForYou => 'Um presente para você';

  @override
  String get giftGiftWaiting => 'Há um presente esperando por você';

  @override
  String get giftOpenBody =>
      'Abra seus presentes para resgatá-los com seu e-mail verificado.';

  @override
  String get giftOpenGifts => 'Abrir presentes';

  @override
  String get giftSendInvitation => 'Enviar convite';

  @override
  String get settingsAiProviderSection => 'Provedor';

  @override
  String get settingsAiCustom => 'Personalizado';

  @override
  String get settingsAiUrlHelper =>
      'Use uma URL pública acessível pelo servidor. O localhost não funciona a partir dos nossos servidores.';

  @override
  String get settingsAiConnectionSection => 'Conexão';

  @override
  String get settingsAiApiUrl => 'URL da API';

  @override
  String get settingsAiApiKey => 'Chave de API';

  @override
  String get settingsAiApiKeySaved => 'Salvo. Deixe em branco para manter.';

  @override
  String get settingsAiChatModel => 'Modelo de chat';

  @override
  String get settingsAiVisionModel => 'Modelo de visão (opcional)';

  @override
  String get settingsAiImageModel => 'Modelo de imagem (opcional)';

  @override
  String get settingsAiImageModelNote =>
      'A geração de imagens requer conclusões de chat compatíveis com a OpenAI com response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testar conexão';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get calendarGoToToday => 'Ir para hoje';

  @override
  String get calendarConnectTooltip => 'Conectar um calendário';

  @override
  String get calendarAddEvent => 'Adicionar evento';

  @override
  String get calendarEmptyTitle => 'Nada planejado';

  @override
  String get calendarEmptyBody => 'Adicione um evento e planeje o que vestir.';

  @override
  String get calendarPreviousMonth => 'Mês anterior';

  @override
  String get calendarNextMonth => 'Próximo mês';

  @override
  String get calendarAllDay => 'Dia todo';

  @override
  String get calendarOutfitLinked => 'Look vinculado';

  @override
  String get calendarEventOptions => 'Opções do evento';

  @override
  String get calendarDeleteTitle => 'Excluir este evento?';

  @override
  String get calendarChangeOutfit => 'Trocar look';

  @override
  String get calendarLinkOutfit => 'Vincular um look';

  @override
  String get calendarRemoveOutfit => 'Remover look';

  @override
  String get calendarNewEvent => 'Novo evento';

  @override
  String get calendarEditEvent => 'Editar evento';

  @override
  String get calendarTitleLabel => 'Título';

  @override
  String get calendarTitleRequired => 'Adicione um título';

  @override
  String get calendarEndBeforeStart => 'O término deve ser após o início';

  @override
  String get calendarStarts => 'Início';

  @override
  String get calendarEnds => 'Término';

  @override
  String get calendarPlaceOptional => 'Local (opcional)';

  @override
  String get calendarNotesOptional => 'Notas (opcionais)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Monte um look e depois vincule-o a este evento.';

  @override
  String get calendarBuildOutfit => 'Montar um look';

  @override
  String get calendarConnectionsTitle => 'Calendários';

  @override
  String get calendarConnectionsBody =>
      'Os eventos que você adicionar aqui ficam no FitCheck AI.';

  @override
  String get calendarDisconnect => 'Desconectar';

  @override
  String get calendarNotAvailable => 'Indisponível ainda';

  @override
  String get profileSectionExplore => 'Explorar';

  @override
  String get profileNavTryOn => 'Provador';

  @override
  String get profileNavRewards => 'Recompensas';

  @override
  String get profileSupport => 'Suporte';

  @override
  String get profileHelp => 'Ajuda';

  @override
  String get profileAbout => 'Sobre';

  @override
  String get profileAboutBody =>
      'Seu closet, seus looks e seus planos em um só lugar.';

  @override
  String get profileSignOutTitle => 'Sair da conta?';

  @override
  String get profileSignOutBody => 'Você pode entrar novamente quando quiser.';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileYourProfile => 'Seu perfil';

  @override
  String get profileBodyProfiles => 'Perfis corporais';

  @override
  String get profileBodyEmptyTitle => 'Nenhum perfil corporal ainda';

  @override
  String get profileBodyEmptyBody =>
      'Adicione sua altura e compleição para um melhor caimento.';

  @override
  String get profileBodyAdd => 'Adicionar perfil';

  @override
  String get profileBodyDefaultNote =>
      'Seu perfil padrão é usado para caimento e provador.';

  @override
  String get profileBodyDefaultBadge => 'Padrão';

  @override
  String get profileBodyMakeDefault => 'Definir como padrão';

  @override
  String get profileBodyDeleteBody => 'Esta ação não pode ser desfeita.';

  @override
  String get profileBodyRequired => 'Obrigatório';

  @override
  String get profileBodyCheckNumber => 'Verifique este número';

  @override
  String get profileBodyNew => 'Novo perfil corporal';

  @override
  String get profileBodyNameHint => 'Por exemplo, Eu';

  @override
  String get profileBodyHeight => 'Altura';

  @override
  String get profileBodyWeight => 'Peso';

  @override
  String get profileBodyBuild => 'Compleição';

  @override
  String get profileBodySkinTone => 'Tom de pele';

  @override
  String get profileBirthDateNeededBody =>
      'Adicione uma data de nascimento para acompanhar a hora.';

  @override
  String get profileBirthDateNeededTitle => 'Data de nascimento necessária';

  @override
  String get profilePartlySavedBody =>
      'Salvamento parcial de nome e foto. Os dados de nascimento não foram salvos; tente novamente.';

  @override
  String get profilePartlySavedTitle => 'Salvo parcialmente';

  @override
  String get profileSavedBody => 'Seu perfil foi salvo.';

  @override
  String get profileChangePhoto => 'Alterar foto do perfil';

  @override
  String get profilePhotoLabel => 'Foto do perfil';

  @override
  String get profilePhotoHint => 'Toque para escolher uma nova';

  @override
  String get profileBirthDateLabel => 'Data de nascimento (opcional)';

  @override
  String get profileBirthTimeLabel => 'Hora de nascimento (opcional)';

  @override
  String get profileBirthTimeHelper => 'Deixa as sugestões védicas mais exatas';

  @override
  String get profileBirthPlaceLabel => 'Local de nascimento (opcional)';

  @override
  String get profileBirthPlaceHint => 'Por exemplo, São Paulo, Brasil';

  @override
  String get profileHelpContactTitle => 'Fale conosco';

  @override
  String get profileHelpContactBody =>
      'Envie uma mensagem e responderemos por e-mail, geralmente em até um dia.';

  @override
  String get profileHelpContactAction => 'Contatar suporte';

  @override
  String get profileHelpFaqTitle => 'Perguntas frequentes';

  @override
  String get profileFaqAddPiecesTitle => 'Como adiciono peças ao meu armário?';

  @override
  String get profileFaqAddPiecesBody =>
      'Toque em Adicionar peça na aba Armário. Tire uma foto ou escolha uma da galeria; nós encontramos cada peça e a tagueamos para você.';

  @override
  String get profileFaqMatchingTitle => 'Como funciona a combinação de looks?';

  @override
  String get profileFaqMatchingBody =>
      'Abra Para você e escolha peças que você tem. Sugerimos o que combina com elas e criamos looks completos com o seu armário.';

  @override
  String get profileFaqTryOnTitle =>
      'Posso usar minhas próprias fotos para provar?';

  @override
  String get profileFaqTryOnBody =>
      'Sim. Adicione uma foto de corpo inteiro e escolha peças para vê-las em você.';

  @override
  String get profileFaqRewardsTitle => 'Como ganho recompensas?';

  @override
  String get profileFaqRewardsBody =>
      'Planeje e registre looks com frequência. Sequências e conquistas aumentam conforme você usa.';

  @override
  String get profileFaqPrivacyTitle => 'Meu armário é privado?';

  @override
  String get profileFaqPrivacyBody =>
      'Sim. Seu armário e seus looks são privados, a menos que você compartilhe o link de um look.';

  @override
  String get profileHelpMoreTitle => 'Mais ajuda';

  @override
  String get profileHelpGuides => 'Guias';

  @override
  String get profileHelpGuidesBody => 'Como cada recurso funciona';

  @override
  String get feedbackCategoryBug => 'Algo quebrou';

  @override
  String get feedbackCategoryIdea => 'Uma ideia';

  @override
  String get feedbackCategoryGeneral => 'Geral';

  @override
  String get feedbackCategoryHelp => 'Preciso de ajuda';

  @override
  String get feedbackHintBug =>
      'O que aconteceu e o que você esperava? Passos nos ajudam a corrigir.';

  @override
  String get feedbackHintIdea => 'O que você gostaria e por quê?';

  @override
  String get feedbackHintGeneral => 'Conte o que achou ou faça uma pergunta.';

  @override
  String get feedbackAttachmentLimitBody =>
      'Você pode adicionar até 5 imagens.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limite atingido';

  @override
  String get feedbackImageTooLargeBody =>
      'Escolha uma imagem com menos de 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imagem muito grande';

  @override
  String get feedbackTitle => 'Enviar feedback';

  @override
  String get feedbackAboutLabel => 'Sobre o que é?';

  @override
  String get feedbackSubjectLabel => 'Assunto';

  @override
  String get feedbackSubjectRequired => 'Adicione um assunto';

  @override
  String get feedbackSubjectTooShort =>
      'O assunto deve ter pelo menos 3 caracteres';

  @override
  String get feedbackDetailsLabel => 'Detalhes';

  @override
  String get feedbackDetailsRequired => 'Adicione alguns detalhes';

  @override
  String get feedbackDetailsTooShort =>
      'A descrição deve ter pelo menos 10 caracteres';

  @override
  String get feedbackAddScreenshot => 'Adicionar captura de tela';

  @override
  String get feedbackAttachmentHint => 'Até 5, 5 MB cada';

  @override
  String get feedbackSend => 'Enviar';

  @override
  String get feedbackEmptyTitle => 'Nenhum envio ainda';

  @override
  String get feedbackEmptyBody =>
      'O que você enviar aparece aqui com o status.';

  @override
  String get feedbackHistoryTitle => 'O que você enviou';

  @override
  String get feedbackStatusOpen => 'Aberto';

  @override
  String get feedbackStatusInProgress => 'Em andamento';

  @override
  String get feedbackStatusResolved => 'Resolvido';

  @override
  String get feedbackStatusClosed => 'Fechado';

  @override
  String get legalIntro =>
      'Como protegemos seus dados e os termos para usar o FitCheck AI.';

  @override
  String get legalPolicies => 'Políticas';

  @override
  String get legalPrivacySubtitle => 'O que coletamos e por quê';

  @override
  String get legalTermsTitle => 'Termos de serviço';

  @override
  String get legalTermsSubtitle => 'As regras para usar o app';

  @override
  String get legalLicences => 'Licenças de código aberto';

  @override
  String get legalSupportSubtitle =>
      'Ajuda, contato e solicitações de privacidade';

  @override
  String get legalReportAbuse => 'Denunciar um problema ou abuso';

  @override
  String get permissionCameraTitle => 'Acesso à Câmera';

  @override
  String get permissionCameraRationale =>
      'O FitCheck AI usa sua câmera para tirar fotos de suas roupas e looks para provador virtual e organização do armário.';

  @override
  String get permissionPhotoTitle => 'Acesso às Fotos';

  @override
  String get permissionPhotoRationale =>
      'O FitCheck AI precisa acessar suas fotos para você selecionar imagens de roupas e looks para os recursos de IA e seu armário.';

  @override
  String get permissionNotNow => 'Agora Não';

  @override
  String get permissionOpenSettings => 'Abrir Ajustes';

  @override
  String authSignedInAs(String name) {
    return 'Conectado como $name';
  }

  @override
  String get authSignedIn => 'Conectado';

  @override
  String get authWelcomeBackTitle => 'Bem-vindo de volta';

  @override
  String get authSignInFailed => 'Falha ao entrar';

  @override
  String get authWelcomeTitle => 'Bem-vindo';

  @override
  String get authSignUpFailed => 'Falha ao cadastrar';

  @override
  String get authGoogleSignInFailed => 'Falha ao entrar com Google';

  @override
  String get authAppleSignInFailed => 'Falha ao entrar com Apple';

  @override
  String get authConfirmEmailTitle => 'Confirme seu e-mail';

  @override
  String get authConfirmEmailBody =>
      'Verifique sua caixa de entrada para confirmar o e-mail e entre.';

  @override
  String get authClosetReady => 'Seu closet está pronto.';

  @override
  String get authSignedOutTitle => 'Desconectado';

  @override
  String get authSignedOutBody => 'Você saiu da conta.';

  @override
  String get authSignOutFailed => 'Falha ao sair';

  @override
  String get authEmailSentTitle => 'E-mail enviado';

  @override
  String get authResetLinkSent =>
      'Verifique seu e-mail para obter o link de redefinição.';

  @override
  String get authPasswordUpdatedTitle => 'Senha atualizada';

  @override
  String get authPasswordUpdated => 'Sua senha foi atualizada.';

  @override
  String get authPasswordNotUpdated => 'Senha não atualizada';

  @override
  String get authCouldNotSendEmail => 'Não foi possível enviar o e-mail';

  @override
  String get authEmailNotSent => 'E-mail não enviado';

  @override
  String get authResendSentBody => 'Enviamos um novo e-mail de confirmação.';

  @override
  String get outfitPreviewWithAi => 'Pré-visualizar com IA';

  @override
  String get outfitNewPreview => 'Criar nova pré-visualização';

  @override
  String get outfitBuilderClosetHeading => 'Seu armário';

  @override
  String get outfitBuilderSearchHint => 'Buscar peças';

  @override
  String get outfitClearSearch => 'Limpar busca';

  @override
  String get outfitBuilderAddPiecesTitle => 'Adicione peças';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Looks são feitos com as peças do seu armário.';

  @override
  String get outfitBuilderNoMatches => 'Nenhuma peça encontrada.';

  @override
  String get outfitNameLabel => 'Nome do look';

  @override
  String get outfitNameHint => 'Ex.: Linho de fim de semana';

  @override
  String get outfitPreviewSemantic => 'Pré-visualização do look com IA';

  @override
  String get outfitChoosePieces => 'Escolher peças';

  @override
  String get outfitTapPiecesHint => 'Toque nas peças para adicionar.';

  @override
  String get outfitShareTooltip => 'Compartilhar';

  @override
  String get outfitSaveFavourite => 'Salvar nos favoritos';

  @override
  String get outfitPiecesHeading => 'Peças';

  @override
  String get outfitWearHistoryEmpty =>
      'Use uma vez e as datas aparecerão aqui.';

  @override
  String get outfitWearHistoryTitle => 'Histórico de uso';

  @override
  String get outfitWearHistoryError => 'Não foi possível carregar as datas.';

  @override
  String get outfitWornOn => 'Usado em';

  @override
  String get outfitEditTitle => 'Editar look';

  @override
  String get outfitSavedPhotosFailed => 'Dados salvos, fotos não';

  @override
  String get outfitNoPhotosBody => 'Sem fotos. O look exibe as peças.';

  @override
  String get outfitOccasionLabel => 'Ocasião';

  @override
  String get outfitOccasionNone => 'Nenhuma';

  @override
  String get outfitTagsHint => 'Separe por vírgulas';

  @override
  String get outfitDraftBody => 'Oculto da sua lista principal';

  @override
  String get outfitPublic => 'Público';

  @override
  String get outfitPublicBody => 'Qualquer um com o link pode ver';

  @override
  String get outfitDeleteFromDetail =>
      'Excluir este look da página de detalhes.';

  @override
  String get outfitNewCollection => 'Nova coleção';

  @override
  String get outfitNoCollectionsTitle => 'Nenhuma coleção ainda';

  @override
  String get outfitNoCollectionsBody =>
      'Agrupar looks por viagem, estação ou humor.';

  @override
  String get outfitCreateCollection => 'Criar coleção';

  @override
  String get outfitAddOutfits => 'Adicionar looks';

  @override
  String get outfitRename => 'Renomear';

  @override
  String get outfitCollectionDeleteBody => 'Os looks são mantidos.';

  @override
  String get outfitCollectionsNotLoaded => 'Looks não carregados';

  @override
  String get outfitRenameCollection => 'Renomear coleção';

  @override
  String get outfitDescriptionOptional => 'Descrição (opcional)';

  @override
  String get outfitAllInCollection => 'Todos os looks já estão nesta coleção.';

  @override
  String get photoshootSubtitleUpload =>
      'Retratos de estúdio a partir de suas fotos';

  @override
  String get photoshootSubtitleConfigure =>
      'Escolha um estilo, formato e quantidade';

  @override
  String get photoshootSubtitleGenerating => 'Isso leva um ou dois minutos';

  @override
  String get photoshootAddPhotosSemantic => 'Adicionar fotos da sua galeria';

  @override
  String get photoshootUploadTitle => 'Adicione de 1 a 4 fotos suas';

  @override
  String get photoshootUploadBody => 'Toque para escolher da sua galeria';

  @override
  String get photoshootAddToContinue => 'Adicione uma foto para continuar';

  @override
  String get photoshootAddAnotherPhoto => 'Adicionar outra foto';

  @override
  String get photoshootTipsTitle => 'Para os melhores resultados';

  @override
  String get photoshootTipsBody =>
      'Use fotos claras e bem iluminadas do seu rosto de vários ângulos. Evite óculos de sol e chapéus.';

  @override
  String get photoshootStarting => 'Iniciando';

  @override
  String get photoshootCancelling => 'Cancelando';

  @override
  String get photoshootFailed => 'Falhou';

  @override
  String get recommendTabMatches => 'Combinações';

  @override
  String get recommendTabComplete => 'Completo';

  @override
  String get recommendTabWeather => 'Clima';

  @override
  String get recommendTabColours => 'Cores';

  @override
  String get recommendTabShop => 'Loja';

  @override
  String get recommendNoMatchesTitle => 'Nenhuma combinação ainda';

  @override
  String get recommendNoMatchesBody =>
      'Escolha uma peça e mostraremos o que combina.';

  @override
  String get recommendPickPiece => 'Escolha uma peça';

  @override
  String get recommendNothingMatchesTitle =>
      'Nada combina com estas por enquanto';

  @override
  String get recommendNothingMatchesBody =>
      'Tente outras peças ou adicione mais ao seu guarda-roupa.';

  @override
  String get recommendChangePieces => 'Trocar peças';

  @override
  String get recommendDefaultReason =>
      'Combina com as peças que você escolheu.';

  @override
  String get recommendCompleteTitle => 'Complete o look';

  @override
  String get recommendCompleteBody =>
      'Escolha uma peça e completaremos o resto.';

  @override
  String get recommendWorking => 'Processando';

  @override
  String get recommendGenerate => 'Gerar';

  @override
  String get recommendChooseStyleBody => 'Escolha um estilo e gere.';

  @override
  String get recommendNoLooksTitle => 'Nenhum look para estas peças';

  @override
  String get recommendNoLooksBody => 'Tente outro estilo ou outras peças.';

  @override
  String get recommendDefaultLook => 'Um look para suas peças';

  @override
  String get recommendNoPiecesBody => 'Nenhuma peça voltou para este look.';

  @override
  String get recommendCityLabel => 'Cidade';

  @override
  String get recommendCheck => 'Verificar';

  @override
  String get recommendWeatherTitle => 'Qual o tempo?';

  @override
  String get recommendWeatherBody =>
      'Informe sua cidade para ver as sugestões de hoje.';

  @override
  String get recommendWearToday => 'Usar hoje';

  @override
  String get recommendWeatherNoPieces =>
      'Ainda não há peças no seu guarda-roupa para este tempo.';

  @override
  String get recommendBudgetLabel => 'Orçamento até';

  @override
  String get recommendLooking => 'Procurando';

  @override
  String get recommendFindWhatToBuy => 'Encontrar o que comprar';

  @override
  String get recommendFillGapsTitle => 'Preencha as lacunas';

  @override
  String get recommendFillGapsBody =>
      'Defina um orçamento e sugeriremos o que falta no seu guarda-roupa.';

  @override
  String get recommendNoGapsTitle => 'Nenhuma lacuna encontrada';

  @override
  String get recommendNoGapsBody =>
      'Tente um orçamento maior ou outra categoria.';

  @override
  String get recommendMoodEveryday => 'Dia a dia';

  @override
  String get recommendMoodBigMeeting => 'Reunião importante';

  @override
  String get recommendDayLabel => 'Dia';

  @override
  String get recommendReadingStars => 'Lendo as estrelas';

  @override
  String get recommendGetMyColours => 'Receber minhas cores';

  @override
  String get recommendLuckyColoursTitle => 'Suas cores da sorte';

  @override
  String get recommendLuckyColoursBody =>
      'Escolha um dia e sugerimos cores e peças para ele.';

  @override
  String get recommendLuckyColoursSection => 'Cores da sorte';

  @override
  String get recommendAvoidColoursSection => 'Cores para evitar';

  @override
  String get recommendBirthDateTitle => 'Adicione sua data de nascimento';

  @override
  String get recommendBirthDateBody =>
      'Precisamos da sua data de nascimento para analisar suas cores.';

  @override
  String get recommendEditProfile => 'Editar perfil';

  @override
  String get recommendNothingThisDay => 'Nada para este dia.';

  @override
  String get recommendUnnamedColour => 'Cor sem nome';

  @override
  String get recommendFromCloset => 'Do seu armário';

  @override
  String get recommendNoPiecesInColours => 'Ainda não há peças nessas cores.';

  @override
  String get recommendOutfitIdeas => 'Ideias de visual';

  @override
  String get recommendNoOutfitsInColours =>
      'Ainda não há um visual completo nessas cores.';

  @override
  String get recommendDefaultOutfitIdea => 'Uma ideia de visual';

  @override
  String get recommendPickUpToThree => 'Escolha até três peças';

  @override
  String get recommendEmptyClosetBody =>
      'Adicione algumas peças primeiro e volte para ver as combinações.';

  @override
  String get dashboardDressForDay => 'Vista-se para o dia seguinte.';

  @override
  String get dashboardOutfitOfDay => 'Visual do dia';

  @override
  String get dashboardFreshLook => 'Um visual novo';

  @override
  String get subscriptionManageInStoreTitle => 'Gerenciar na loja';

  @override
  String get subscriptionManageInStoreBody =>
      'Este plano é cobrado pela loja. Gerencie-o nas configurações da sua conta na loja.';

  @override
  String get subscriptionCancelledTitle => 'Assinatura cancelada';

  @override
  String get subscriptionCancelledBody =>
      'Seu plano permanece ativo até o final deste período de cobrança.';

  @override
  String get subscriptionCancelFailedTitle => 'Não foi possível cancelar';

  @override
  String get subscriptionCouldNotOpenTitle => 'Não foi possível abrir';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Não foi possível abrir o gerenciamento de cobranças.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Não foi possível abrir o link.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Não foi possível carregar seu link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Não foi possível carregar seu link de indicação. Tente novamente.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiado';

  @override
  String get subscriptionReferralCopiedBody => 'Link de indicação copiado.';

  @override
  String get subscriptionReferralShareSubject => 'Experimente o FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Entre no FitCheck AI e ganhe um mês de Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copiado';

  @override
  String get subscriptionShareUnavailableBody =>
      'O compartilhamento não está disponível, então copiamos o link.';

  @override
  String get subscriptionShareFailedTitle => 'Falha ao compartilhar';

  @override
  String get subscriptionShareFailedBody =>
      'Copie o link da página de indicação.';

  @override
  String get subscriptionStoreReadyTitle => 'Loja pronta';

  @override
  String get subscriptionStoreReadyBody =>
      'Os preços da loja estão disponíveis. Você já pode fazer o upgrade.';

  @override
  String get purchaseFailedTitle => 'Falha na compra';

  @override
  String get purchaseUnavailableTitle => 'Compra indisponível';

  @override
  String get purchaseIapUnavailableBody =>
      'Compras no app não estão disponíveis neste dispositivo.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Este plano ainda não está disponível para compra.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Este plano ainda não está disponível na loja. Volte em breve.';

  @override
  String get purchaseStartFailedBody =>
      'Não foi possível iniciar a compra. Tente novamente.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'O checkout não retornou um link de pagamento.';

  @override
  String get purchasePendingTitle => 'Compra pendente';

  @override
  String get purchasePendingBody =>
      'Sua compra está aguardando aprovação. Você terá acesso assim que for aprovada.';

  @override
  String get purchaseFailedBody => 'A compra falhou. Tente novamente.';

  @override
  String get purchaseRestoredTitle => 'Restaurado';

  @override
  String get purchaseRestoredBody => 'Suas compras foram restauradas.';

  @override
  String get purchaseActiveTitle => 'Assinatura ativa';

  @override
  String get purchaseActiveBody => 'Sua assinatura está ativa. Bem-vindo.';

  @override
  String get purchaseSignInRequiredTitle => 'Login necessário';

  @override
  String get purchaseSignInRequiredBody => 'Entre para concluir sua compra.';

  @override
  String get purchaseErrorTitle => 'Erro na compra';

  @override
  String get purchaseInvalidTransactionBody =>
      'A compra não incluiu um ID de transação verificável.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificação pendente';

  @override
  String get purchaseVerificationPendingBody =>
      'Não foi possível verificar sua compra agora. O processo será concluído automaticamente e você não será cobrado duas vezes.';

  @override
  String get purchaseNotAppliedTitle => 'Compra não aplicada';

  @override
  String get purchaseNotAppliedBody =>
      'Sua compra não pôde ser aplicada à sua conta. Entre em contato com o suporte e não compre novamente.';

  @override
  String get purchaseRestoreFailedTitle => 'Falha na restauração';

  @override
  String get purchaseRestoreFailedBody =>
      'Não foi possível restaurar as compras. Tente novamente.';

  @override
  String get purchaseRecoveredActiveBody => 'Sua assinatura está ativa.';

  @override
  String get purchaseCompleteTitle => 'Compra concluída';

  @override
  String get giftCreateFailedTitle => 'Não foi possível criar o presente';

  @override
  String get giftClaimFailedTitle => 'Não foi possível resgatar o presente';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presentes para você',
      one: 'Um presente para você',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mês',
      '12': '1 ano',
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
    return '$sender enviou $duration de FitCheck Pro para você. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Um presente FitCheck Pro para $recipient';
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
  String get giftPreviewPlaceholderRecipient => 'seu destinatário';

  @override
  String get giftPreviewPlaceholderSender => 'você';

  @override
  String get settingsSavedTitle => 'Salvo';

  @override
  String get settingsNotSavedTitle => 'Não salvo';

  @override
  String get settingsAiChooseProviderBody => 'Escolha um provedor.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Um provedor personalizado requer uma URL de API.';

  @override
  String get settingsAiKeyRequiredBody => 'Insira uma chave de API.';

  @override
  String get settingsAiSavedBody => 'Suas configurações de IA foram salvas.';

  @override
  String get settingsAiMissingDetailsTitle => 'Dados faltando';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Insira uma URL de API e um modelo de chat para testar.';

  @override
  String get settingsAiKeyNeededTitle => 'Chave de API necessária';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Digite sua chave de API para testar. Sua chave salva permanece privada.';

  @override
  String get settingsAiKeyToTestBody => 'Digite sua chave de API para testar.';

  @override
  String get settingsAiConnectedTitle => 'Conectado';

  @override
  String get settingsAiConnectedBody => 'A conexão funciona.';

  @override
  String get settingsAiTestFailedTitle => 'Falha no teste';

  @override
  String get settingsPreferencesSavedBody => 'Suas preferências foram salvas.';

  @override
  String get settingsPasswordNotChangedTitle => 'Senha não alterada';

  @override
  String get settingsOAuthPasswordBody =>
      'Esta conta faz login com Google ou Apple. Use \"Esqueci a senha\" para definir uma senha primeiro.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'A senha atual está incorreta.';

  @override
  String get settingsExportReadyTitle => 'Exportação pronta';

  @override
  String get settingsExportReadyBody =>
      'Sua exportação de dados está pronta para download.';

  @override
  String get settingsLinkCopiedTitle => 'Link copiado';

  @override
  String get settingsExportClipboardBody =>
      'Não conseguimos abrir seu navegador, então copiamos o link de download. Cole-o em um navegador em breve: ele expira.';

  @override
  String get settingsExportFailedTitle => 'Falha na exportação';

  @override
  String get settingsAccountNotDeletedTitle => 'Conta não excluída';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Você pode adicionar até $max fotos.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limite de fotos';

  @override
  String get photoshootAddAtLeastOnePhoto => 'Adicione pelo menos uma foto.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Nenhuma foto';

  @override
  String get photoshootDescribeLookBody => 'Descreva o visual que você deseja.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt necessário';

  @override
  String get photoshootConsentFeatureLabel => 'Sessão de Fotos IA';

  @override
  String get photoshootStatusPreparing => 'Preparando suas fotos';

  @override
  String get photoshootStatusGenerating => 'Gerando';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lote $current de $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done de $total concluídas';
  }

  @override
  String get photoshootGenerationFailedBody => 'Falha na geração.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready prontas, $failed falharam.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Parcialmente concluído';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos prontas.',
      one: '1 foto pronta.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Perdemos a conexão. Tente novamente.';

  @override
  String get photoshootCouldNotCancelTitle => 'Não foi possível cancelar';

  @override
  String get photoshootRetryFailedTitle => 'Falha ao tentar novamente';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'A foto $number está pronta.';
  }

  @override
  String get photoshootReplacedTitle => 'Substituída';

  @override
  String get photoshootSavedToGalleryBody => 'Salva na sua galeria.';

  @override
  String get photoshootSavedTitle => 'Salvo';

  @override
  String get photoshootNotSavedTitle => 'Não salvo';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todas as $count fotos estão na sua galeria.',
      one: '1 foto está na sua galeria.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved de $total salvas.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle => 'Algumas fotos não salvas';

  @override
  String get tryonConsentFeatureLabel => 'Provador Virtual';

  @override
  String get tryonAvatarUpdatedBody => 'Sua foto foi atualizada.';

  @override
  String get tryonSavedTitle => 'Salvo';

  @override
  String get tryonUploadFailedTitle => 'Falha no envio';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Escolha uma foto de uma peça de roupa primeiro.';

  @override
  String get tryonNoGarmentTitle => 'Sem peça de roupa';

  @override
  String get tryonWaitForUploadBody => 'Aguarde seu upload terminar.';

  @override
  String get tryonStillUploadingTitle => 'Ainda enviando';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Adicione uma foto de você primeiro.';

  @override
  String get tryonReadyBody => 'Seu provador virtual está pronto.';

  @override
  String get tryonFailedTitle => 'Falha no provador virtual';

  @override
  String get tryonSavedToGalleryBody => 'Salvo na sua galeria.';

  @override
  String get tryonNotSavedTitle => 'Não salvo';

  @override
  String get calendarEventAddedBody => 'Evento adicionado';

  @override
  String get calendarEventPlannedTitle => 'Planejado';

  @override
  String get calendarEventSavedBody => 'Evento salvo';

  @override
  String get calendarSavedTitle => 'Salvo';

  @override
  String get calendarEventNotSavedTitle => 'Evento não salvo';

  @override
  String get calendarEventRemovedBody => 'Evento removido';

  @override
  String get calendarEventDeletedTitle => 'Removido';

  @override
  String get calendarEventNotDeletedTitle => 'Evento não removido';

  @override
  String get calendarOutfitNotLinkedTitle => 'Conjunto não vinculado';

  @override
  String get calendarLinkedTitle => 'Vinculado';

  @override
  String get calendarOutfitNotRemovedTitle => 'Conjunto não removido';

  @override
  String get calendarOutfitRemovedBody => 'Conjunto removido';

  @override
  String get calendarDisconnectedBody => 'Calendário desconectado';

  @override
  String get calendarDisconnectedTitle => 'Desconectado';

  @override
  String get calendarNotDisconnectedTitle => 'Calendário não desconectado';

  @override
  String get calendarTodayLabel => 'hoje';

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
    return '\"$title\" será removido.';
  }

  @override
  String get calendarThisAppLabel => 'Este app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'Sincronizar com $provider ainda não está disponível. Você ainda pode adicionar eventos aqui.';
  }

  @override
  String get calendarWeekdaySunShort => 'Dom';

  @override
  String get calendarWeekdayMonShort => 'Seg';

  @override
  String get calendarWeekdayTueShort => 'Ter';

  @override
  String get calendarWeekdayWedShort => 'Qua';

  @override
  String get calendarWeekdayThuShort => 'Qui';

  @override
  String get calendarWeekdayFriShort => 'Sex';

  @override
  String get calendarWeekdaySatShort => 'Sáb';

  @override
  String get calendarWeekdayMonday => 'Segunda-feira';

  @override
  String get calendarWeekdayTuesday => 'Terça-feira';

  @override
  String get calendarWeekdayWednesday => 'Quarta-feira';

  @override
  String get calendarWeekdayThursday => 'Quinta-feira';

  @override
  String get calendarWeekdayFriday => 'Sexta-feira';

  @override
  String get calendarWeekdaySaturday => 'Sábado';

  @override
  String get calendarWeekdaySunday => 'Domingo';

  @override
  String get outfitSavedToFavouritesBody => 'Salvo nos favoritos';

  @override
  String get outfitRemovedFromFavouritesBody => 'Removido dos favoritos';

  @override
  String get outfitNotSavedTitle => 'Não salvo';

  @override
  String get outfitLoggedAsWornBody => 'Registrado como usado hoje.';

  @override
  String get outfitNicePickTitle => 'Ótima escolha';

  @override
  String get outfitRemovedBody => 'Look removido.';

  @override
  String get outfitDeletedTitle => 'Excluído';

  @override
  String get outfitNotDeletedTitle => 'Não excluído';

  @override
  String get outfitDuplicatedBody => 'Uma cópia está nos seus looks.';

  @override
  String get outfitDuplicatedTitle => 'Duplicado';

  @override
  String get outfitNotDuplicatedTitle => 'Não duplicado';

  @override
  String get outfitNotSharedTitle => 'Não compartilhado';

  @override
  String outfitCollectionReadyBody(String name) {
    return '\"$name\" está pronto.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Coleção não criada';

  @override
  String get outfitCollectionUpdatedBody => 'Coleção atualizada.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Coleção não atualizada';

  @override
  String get outfitCollectionDeletedBody => 'Coleção excluída.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Coleção não excluída';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count looks adicionados.',
      one: '1 look adicionado.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Looks não adicionados';

  @override
  String get outfitPreviewNotCreatedTitle => 'Pré-visualização não criada';

  @override
  String get outfitGiveNameBody => 'Dê um nome ao look.';

  @override
  String get outfitNameMissingTitle => 'Nome';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Escolha pelo menos uma peça.';

  @override
  String outfitCreatedBody(String name) {
    return '$name está nos seus looks.';
  }

  @override
  String get outfitSavedTitle => 'Salvo';

  @override
  String get wardrobeAddedToFavouritesBody => 'Adicionado aos favoritos';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Removido dos favoritos';

  @override
  String get wardrobeNotSavedTitle => 'Não salvo';

  @override
  String get wardrobeLoggedAsWornBody => 'Registrado como usado hoje.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Removido do seu guarda-roupa.';

  @override
  String get wardrobeDeletedTitle => 'Excluído';

  @override
  String get wardrobeNotDeletedTitle => 'Não excluído';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças removidas do seu guarda-roupa.',
      one: '1 peça removida do seu guarda-roupa.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extração de Guarda-Roupa por IA';

  @override
  String get itemAddScanJobLabel => 'Escaneiar';

  @override
  String get itemAddFoundEarlierBody =>
      'Encontrado em um escaneamento anterior';

  @override
  String get itemAddLookingAtPhoto => 'Analisando sua foto';

  @override
  String get itemAddExtractionFailedBody => 'Falha na extração';

  @override
  String get itemAddJobFailedBody => 'Falha na tarefa';

  @override
  String get itemAddConnectionLostBody =>
      'A conexão foi perdida. Tente novamente.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Conexão perdida durante o processamento.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Peça $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Peça';

  @override
  String get itemAddNotCancelledTitle => 'Não cancelado';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças estão no seu guarda-roupa.',
      one: '1 peça está no seu guarda-roupa.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved de $total peças salvas. Toque em salvar para tentar o restante.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Algumas peças não salvas';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Escolha pelo menos uma foto.';

  @override
  String get batchPhotoUnreadableBody => 'Esta foto não pôde ser lida.';

  @override
  String get batchNoPhotosReadableBody =>
      'Nenhuma destas fotos pôde ser lida. Tente outras.';

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
      'Perdemos a conexão durante o processamento. Tente novamente.';

  @override
  String get batchNotCancelledTitle => 'Não cancelado';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Links de post não são suportados. Insira um link de perfil.';

  @override
  String get batchLinkSpacesBody => 'Links não podem conter espaços.';

  @override
  String get batchEnterProfileLinkBody =>
      'Insira um link de perfil do Instagram ou Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Insira um link de perfil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'A página de login não abriu. Tente novamente.';

  @override
  String get batchSignInBrowserBody =>
      'Entre na sua conta pelo navegador e depois volte para o FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Conectar sua conta';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Digite o código do seu app de autenticação.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'O Instagram pede uma verificação de segurança. Entre pelo navegador primeiro.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Digite seu usuário e senha novamente.';

  @override
  String get batchSignInFailedBody =>
      'Falha ao entrar. Verifique seu usuário e senha.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Entre para continuar importando.';

  @override
  String get batchAccountNotConnectedBody => 'Sua conta não foi conectada.';

  @override
  String get batchAccountConnectedTitle => 'Conta conectada';

  @override
  String get batchNotConnectedTitle => 'Não conectado';

  @override
  String get batchImportConnectionLostBody =>
      'Perdemos a conexão com a importação. Atualize para verificar.';

  @override
  String batchPickUpToBody(int max) {
    return 'Escolha até $max fotos. Nós encontramos as peças.';
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
      other: 'Encontrar peças em $count fotos',
      one: 'Encontrar peças em 1 foto',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'Sua conta $platform usa verificação em duas etapas. Digite o código de 6 dígitos do seu app de autenticação.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Este perfil $platform é privado ou precisa de login para exibir fotos.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Conectar com $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos encontradas até agora',
      one: '1 foto encontrada até agora',
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
    return '$processed de $total processadas · $added adicionadas · $waiting aguardando · $skipped puladas';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'Escaneando foto $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'Foto $number é a próxima';
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
      other: '$count peças encontradas',
      one: '1 peça encontrada',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos foram adicionadas ao seu armário.',
      one: '1 foto foi adicionada ao seu armário.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count fotos do estúdio a mais no caminho. Você pode salvar o que está pronto, ou sair — avisaremos.',
      one:
          '1 foto do estúdio a mais no caminho. Você pode salvar o que está pronto, ou sair — avisaremos.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Ainda não salvos: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces peças',
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
    return '$chosen escolhidas. Toque em uma peça para pular.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvando $count peças',
      one: 'Salvando 1 peça',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvar $count peças',
      one: 'Salvar 1 peça',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'Seu perfil corporal foi salvo.';

  @override
  String get bodyProfileSavedTitle => 'Salvo';

  @override
  String get bodyProfileNotSavedTitle => 'Não salvo';

  @override
  String get bodyProfileSetDefaultBody => 'Defina como seu perfil padrão.';

  @override
  String get bodyProfileDeletedBody => 'Perfil corporal excluído.';

  @override
  String get bodyProfileDeletedTitle => 'Excluído';

  @override
  String get bodyProfileNotDeletedTitle => 'Não excluído';

  @override
  String get feedbackNotSentTitle => 'Não enviado';

  @override
  String get feedbackSentBody =>
      'Obrigado. Lê todas as mensagens e responde se precisar de mais informações.';

  @override
  String get feedbackSentTitle => 'Feedback enviado';

  @override
  String get recommendUnnamedPiece => 'Peça sem nome';

  @override
  String get recommendEnterCityBody =>
      'Digite sua cidade para receber sugestões do clima.';

  @override
  String get recommendWhichCityTitle => 'Qual cidade?';

  @override
  String get aiConsentSheetTitle => 'Compartilhar fotos com um serviço de IA';

  @override
  String get aiConsentSheetBody =>
      'Para criar suas imagens de provador virtual e ensaio, o FitCheck AI envia as fotos que você fornece (incluindo imagens do seu rosto e corpo) para um provedor de IA de terceiros confiável (como OpenAI ou Google Gemini) para processamento. Eles geram suas imagens e não as usam para treinar seus modelos sob nossos termos. As fotos são transmitidas com segurança e nunca são compartilhadas para fins de publicidade.';

  @override
  String get aiConsentSheetPermission =>
      'Ao continuar, você dá permissão explícita para compartilhar suas fotos com esses provedores de IA para geração de imagens.';

  @override
  String get skeletonsLoadMoreFailed => 'Não foi possível carregar mais.';

  @override
  String get jobsPiecesReadyTitle => 'Suas peças estão prontas';

  @override
  String get jobsScanStoppedTitle => 'A varredura foi interrompida';

  @override
  String get jobsNothingSavedBody => 'Nada foi salvo. Tente novamente.';

  @override
  String get jobsPhotoUploadFailedBody => 'Falha no envio da foto.';

  @override
  String get authGoogleSignInStartFailed =>
      'Não foi possível iniciar o login com o Google. Tente novamente.';

  @override
  String get referralAppliedTitle => 'Indicação aplicada!';

  @override
  String get billingStoreUnavailableBody =>
      'Compras na loja não estão disponíveis neste dispositivo.';

  @override
  String get billingPurchaseProcessingBody =>
      'Esta compra ainda está em processamento. Reabra o app em um minuto para ver seu plano.';

  @override
  String get profileAvatarUploadNoUrl =>
      'O upload do avatar não retornou uma URL de imagem.';

  @override
  String get rewardsDayStreakLabel => 'sequência de dias';

  @override
  String rewardsBestStreak(int days) {
    return 'Melhor sequência de $days dias';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Acesso a $permission necessário';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'Acesso a $permission está negado. Abra Configurações para permitir e tente novamente.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Etapa $step de 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Etapa $step de $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Remover imagem $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Remover imagem $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'E-mail $email. Avaliamos relatórios em 24 horas.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Remover $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Adicionar a \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" foi removido. As peças continuam no seu closet.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Mostrar os $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restantes hoje';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Foto $index falhou';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected de $max fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return '$shape físico · pele $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opções para $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Mais usado: $name, $count vezes';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: não definido';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% compatível';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked de $max selecionados';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Remover $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioridade $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Este plano é faturado pelo $store. Altere ou cancele nas configurações da sua conta no $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gerenciar no $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current de $max usados';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Faltam cerca de ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done de $total fotos do estúdio prontas';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready de $total fotos do estúdio prontas. Toque em uma peça para pular.';
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
  String get profileFieldNotSet => 'Não';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get appName => 'FitCheck AI';

  @override
  String get tabHome => 'Início';

  @override
  String get tabPhotoshoot => 'Sessão';

  @override
  String get tabCloset => 'Roupeiro';

  @override
  String get tabOutfits => 'Looks';

  @override
  String get tabMore => 'Mais';

  @override
  String get actionAddItem => 'Adicionar peça';

  @override
  String get actionCreateOutfit => 'Criar look';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionNext => 'Seguinte';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionSearch => 'Pesquisar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get stateLoading => 'A carregar';

  @override
  String get stateErrorTitle => 'Algo correu mal';

  @override
  String get stateErrorBody =>
      'Tente novamente. Se o erro persistir, contacte o apoio ao cliente.';

  @override
  String get stateOfflineTitle => 'Sem ligação';

  @override
  String get stateOfflineBody =>
      'Ligue-se à internet para sincronizar o seu roupeiro e gerar looks.';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsAccountSection => 'Conta';

  @override
  String get settingsPreferencesSection => 'Preferências';

  @override
  String get settingsPlanBilling => 'Plano e faturação';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsUnits => 'Unidades de medida';

  @override
  String get settingsAppearance => 'Aspeto';

  @override
  String get settingsPrivacySection => 'Privacidade e dados';

  @override
  String get settingsAboutSection => 'Sobre';

  @override
  String get settingsSignOut => 'Terminar sessão';

  @override
  String get settingsDeleteAccount => 'Eliminar conta';

  @override
  String get settingsDeleteAccountTitle => 'Eliminar a sua conta?';

  @override
  String get settingsDeleteAccountBody =>
      'Isto remove o seu guarda-roupa, conjuntos, fotos e perfil. Não pode ser anulado.';

  @override
  String get settingsUnitsImperial => 'Imperial (pol, lb)';

  @override
  String get settingsUnitsMetric => 'Métrico (cm, kg)';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Usar idioma do dispositivo';

  @override
  String get languageSystemBody =>
      'O FitCheck AI segue o idioma do seu telemóvel.';

  @override
  String get languageSearchHint => 'Pesquisar idiomas';

  @override
  String get languageCurrent => 'Atual';

  @override
  String get languageReviewNote =>
      'Esta tradução é nova. Diga-nos se algo parece incorreto.';

  @override
  String get languageChanged => 'Idioma atualizado';

  @override
  String get paywallTitle => 'Escolha o seu plano';

  @override
  String get paywallTrialBadge => '1 mês grátis';

  @override
  String get paywallTrialTitle => 'O seu primeiro mês de Pro é grátis';

  @override
  String get paywallTrialBody =>
      'Carregue todo o seu guarda-roupa de uma vez. Adicione peças à medida que avança.';

  @override
  String get paywallFreeForeverTitle => 'Grátis para sempre';

  @override
  String paywallFreeForeverBody(int uploads, int outfits, int images) {
    return 'Sem cartão. Todos os meses recebe $uploads carregamentos IA, $outfits conjuntos e $images fotos de sessão por dia.';
  }

  @override
  String get paywallCtaTrial => 'Iniciar o meu mês grátis';

  @override
  String paywallCtaUpgrade(String plan) {
    return 'Atualizar para $plan';
  }

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallManage => 'Gerir subscrição';

  @override
  String get paywallTerms => 'Termos de utilização';

  @override
  String get paywallPrivacy => 'Política de privacidade';

  @override
  String get paywallPerMonth => 'por mês';

  @override
  String get paywallPerYear => 'por ano';

  @override
  String get paywallBestValue => 'Melhor opção';

  @override
  String paywallTrialEligibleOnly(String price) {
    return 'Avaliação gratuita apenas para novos subscritores. Após o período experimental, o Pro renova-se por $price, a menos que seja cancelado pelo menos 24 horas antes do fim.';
  }

  @override
  String get introTitle => 'O seu armário, finalmente organizado';

  @override
  String get introBody =>
      'Fotografe as suas roupas uma vez. Obtenha sugestões de looks, pré-visualizações de prova e fotos de estúdio com o que já possui.';

  @override
  String get introStart => 'Começar';

  @override
  String get introHaveAccount => 'Já tenho conta';

  @override
  String get introSkip => 'Ignorar';

  @override
  String get authSignIn => 'Iniciar sessão';

  @override
  String get authSignUp => 'Criar conta';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Palavra-passe';

  @override
  String get authForgotPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get authContinueApple => 'Continuar com Apple';

  @override
  String get authContinueGoogle => 'Continuar com Google';

  @override
  String get authOrDivider => 'ou';

  @override
  String get wardrobeTitle => 'Armário';

  @override
  String get wardrobeEmptyTitle => 'O seu armário está vazio';

  @override
  String get wardrobeEmptyBody =>
      'Adicione a sua primeira peça ou carregue uma foto de todo o cabide de uma só vez.';

  @override
  String get wardrobeAddFirst => 'Adicionar primeiro item';

  @override
  String get wardrobeSearchHint => 'Pesquisar no armário';

  @override
  String get categoryTops => 'Partes de cima';

  @override
  String get categoryBottoms => 'Partes de baixo';

  @override
  String get categoryShoes => 'Calçado';

  @override
  String get categoryAccessories => 'Acessórios';

  @override
  String get categoryOuterwear => 'Casacos';

  @override
  String get categorySwimwear => 'Roupa de banho';

  @override
  String get categoryActivewear => 'Roupa desportiva';

  @override
  String get categoryOther => 'Outros';

  @override
  String get conditionClean => 'Limpo';

  @override
  String get conditionDirty => 'Sujo';

  @override
  String get conditionLaundry => 'Na lavandaria';

  @override
  String get conditionRepair => 'Precisa de arranjo';

  @override
  String get conditionDonate => 'Para doar';

  @override
  String get seasonSpring => 'Primavera';

  @override
  String get seasonSummer => 'Verão';

  @override
  String get seasonFall => 'Outono';

  @override
  String get seasonWinter => 'Inverno';

  @override
  String get seasonAll => 'Todas as estações';

  @override
  String get styleCasual => 'Casual';

  @override
  String get styleFormal => 'Formal';

  @override
  String get styleBusiness => 'Executivo';

  @override
  String get styleSporty => 'Desportivo';

  @override
  String get styleBohemian => 'Boémio';

  @override
  String get styleStreetwear => 'Streetwear';

  @override
  String get styleVintage => 'Vintage';

  @override
  String get styleMinimalist => 'Minimalista';

  @override
  String get styleRomantic => 'Romântico';

  @override
  String get styleEdgy => 'Arrojado';

  @override
  String get stylePreppy => 'Preppy';

  @override
  String get styleArtsy => 'Artístico';

  @override
  String get styleClassic => 'Clássico';

  @override
  String get styleElegant => 'Elegante';

  @override
  String get styleOther => 'Outro';

  @override
  String get occasionWork => 'Trabalho';

  @override
  String get occasionDateNight => 'Encontro';

  @override
  String get occasionTravel => 'Viagem';

  @override
  String get occasionWedding => 'Casamento';

  @override
  String get occasionGym => 'Ginásio';

  @override
  String get occasionWeekend => 'Fim de semana';

  @override
  String get occasionParty => 'Festa';

  @override
  String get occasionInterview => 'Entrevista';

  @override
  String get colorBlack => 'Preto';

  @override
  String get colorWhite => 'Branco';

  @override
  String get colorGrey => 'Cinzento';

  @override
  String get colorNavy => 'Azul-marinho';

  @override
  String get colorBrown => 'Castanho';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorBeige => 'Bege';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String dateDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String dateWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count semanas',
      one: 'há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dateMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count meses',
      one: 'há 1 mês',
    );
    return '$_temp0';
  }

  @override
  String dateYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count anos',
      one: 'há 1 ano',
    );
    return '$_temp0';
  }

  @override
  String get ratingPromptTitle => 'Gosta do FitCheck AI?';

  @override
  String get ratingPromptBody =>
      'Uma avaliação rápida ajuda outros a encontrar o seu estilo.';

  @override
  String get ratingPromptYes => 'Avaliar a app';

  @override
  String get ratingPromptNo => 'Agora não';

  @override
  String get closetNoMatchesTitle => 'Sem peças correspondentes';

  @override
  String get closetNoMatchesBody => 'Tente menos filtros ou outra pesquisa.';

  @override
  String get closetClearFilters => 'Limpar filtros';

  @override
  String closetPieceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças',
      one: '1 peça',
    );
    return '$_temp0';
  }

  @override
  String get closetLoading => 'A carregar as suas peças';

  @override
  String closetSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionadas',
      one: '1 selecionada',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteSelected => 'Eliminar selecionadas';

  @override
  String get closetCancelSelection => 'Cancelar seleção';

  @override
  String get closetCloseSearch => 'Fechar pesquisa';

  @override
  String get closetShowGrid => 'Ver em grelha';

  @override
  String get closetShowList => 'Ver em lista';

  @override
  String get closetShowRows => 'Ver em linhas';

  @override
  String get closetStatsTitle => 'Estatísticas do armário';

  @override
  String closetDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminar $count peças?',
      one: 'Eliminar 1 peça?',
    );
    return '$_temp0';
  }

  @override
  String get closetDeleteBody =>
      'Os coordenados que as utilizam perderão estas peças.';

  @override
  String get closetSortBy => 'Ordenar por';

  @override
  String get closetFavourites => 'Favoritos';

  @override
  String get closetFavourite => 'Favorito';

  @override
  String get closetUnfavourite => 'Remover favorito';

  @override
  String get closetWoreToday => 'Usei hoje';

  @override
  String closetWornTimes(int count) {
    return 'Usado $count×';
  }

  @override
  String get closetCategoryLabel => 'Categoria';

  @override
  String get closetUseCaseLabel => 'Ocasião';

  @override
  String get closetAnyUseCase => 'Qualquer';

  @override
  String get closetOtherUseCase => 'Outra ocasião';

  @override
  String get closetOtherUseCaseHint => 'Por exemplo, brunch';

  @override
  String get closetUseUseCase => 'Usar esta';

  @override
  String get closetClearAll => 'Limpar tudo';

  @override
  String get sortNewest => 'Mais recentes primeiro';

  @override
  String get sortOldest => 'Mais antigos primeiro';

  @override
  String get sortName => 'Nome (A–Z)';

  @override
  String get sortMostWorn => 'Mais usados';

  @override
  String get useCaseInformal => 'Informal';

  @override
  String get useCaseDate => 'Encontro';

  @override
  String get useCaseDinner => 'Jantar';

  @override
  String get useCaseLunch => 'Almoço';

  @override
  String get actionSelect => 'Selecionar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get actionSort => 'Ordenar';

  @override
  String get actionAll => 'Tudo';

  @override
  String get dashboardStartClosetTitle => 'Comece o seu armário';

  @override
  String get dashboardStartClosetBody =>
      'Fotografe algumas peças. Nós etiquetamo-las por si.';

  @override
  String get dashboardPieces => 'peças';

  @override
  String get dashboardOutfits => 'looks';

  @override
  String get dashboardDayStreak => 'dias seguidos';

  @override
  String dashboardAddedThisMonth(int count) {
    return '+$count este mês';
  }

  @override
  String dashboardBestStreak(int count) {
    return 'Máximo $count';
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
      other: '$count looks guardados',
      one: '1 look guardado',
    );
    return '$_temp0';
  }

  @override
  String dashboardMostWorn(String name, int count) {
    return 'Mais usado: $name, $count vezes';
  }

  @override
  String get setupSkip => 'Ignorar configuração';

  @override
  String get setupWhoTitle => 'Quem vamos vestir?';

  @override
  String get setupWhoBody =>
      'Define o modelo para provas e fotos. Pode alterar no seu perfil.';

  @override
  String get setupStyleTitle => 'O que usa mais?';

  @override
  String get setupStyleBody =>
      'Escolha qualquer um. As sugestões de looks partem daqui.';

  @override
  String get setupClosetTitle => 'Adicione as suas primeiras peças.';

  @override
  String get setupClosetBody =>
      'Fotografe algumas peças ou um monte delas. Cada peça é recortada e organizada para si.';

  @override
  String get setupAddClothes => 'Adicionar peças';

  @override
  String get setupStylesLabel => 'Estilos';

  @override
  String get setupOccasionsLabel => 'Ocasiões';

  @override
  String get setupSkipStep => 'Ignorar';

  @override
  String get setupLater => 'Mais tarde';

  @override
  String get setupSaveError => 'Não foi possível guardar';

  @override
  String get genderWomen => 'Mulher';

  @override
  String get genderMen => 'Homem';

  @override
  String get genderNonBinary => 'Não binário';

  @override
  String get genderPreferNotToSay => 'Prefiro não dizer';

  @override
  String get outfitEmptyTitle => 'Ainda sem coordenados';

  @override
  String get outfitEmptyBody => 'Combine peças do seu armário e guarde o look.';

  @override
  String get outfitNoMatchesTitle => 'Sem coordenados correspondentes';

  @override
  String get outfitSearchHint => 'Pesquisar coordenados';

  @override
  String get outfitLoading => 'A carregar coordenados';

  @override
  String outfitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coordenados',
      one: '1 coordenado',
    );
    return '$_temp0';
  }

  @override
  String get outfitFilterMenu => 'Estilo e estação';

  @override
  String get outfitCollections => 'Coleções';

  @override
  String get outfitDuplicate => 'Duplicar';

  @override
  String get outfitDeleteTitle => 'Eliminar este coordenado?';

  @override
  String get outfitDeleteBody => 'As peças permanecem no seu armário.';

  @override
  String get outfitDrafts => 'Rascunhos';

  @override
  String get outfitDraft => 'Rascunho';

  @override
  String get filterStyle => 'Estilo';

  @override
  String get filterSeason => 'Estação';

  @override
  String get itemDetailDeleteTitle => 'Eliminar esta peça?';

  @override
  String get itemDetailDeleteBody =>
      'Os coordenados que usam esta peça serão afetados.';

  @override
  String get itemAddFavourite => 'Adicionar aos favoritos';

  @override
  String itemSize(String size) {
    return 'Tamanho $size';
  }

  @override
  String get itemColours => 'Cores';

  @override
  String get itemMaterial => 'Material';

  @override
  String get itemPattern => 'Padrão';

  @override
  String get itemUseCases => 'Ocasiões';

  @override
  String get itemKeptIn => 'Guardado em';

  @override
  String get itemPrice => 'Preço';

  @override
  String get itemBought => 'Data de compra';

  @override
  String get itemTags => 'Etiquetas';

  @override
  String get itemAdded => 'Adicionado';

  @override
  String get itemTimesWornLabel => 'vezes usado';

  @override
  String get itemLastWornLabel => 'última vez usado';

  @override
  String get itemNeverWorn => 'Nunca';

  @override
  String get authEntryBody =>
      'Todas as suas peças, coordenadas por IA. Planeie coordenados, experimente-os e fotografe-os.';

  @override
  String get authCreateCloset => 'Criar o seu armário';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta';

  @override
  String get authSignInBody => 'Inicie sessão para abrir o seu armário.';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authCreateClosetBody =>
      'Demora um minuto. As suas primeiras peças são gratuitas.';

  @override
  String get authName => 'Nome';

  @override
  String get authConfirmPassword => 'Confirmar palavra-passe';

  @override
  String get authReferralCode => 'Código de referência (opcional)';

  @override
  String get authResetTitle => 'Redefinir palavra-passe';

  @override
  String get authResetBody =>
      'Enviaremos um link por e-mail para definir uma nova.';

  @override
  String get authSendResetLink => 'Enviar link de redefinição';

  @override
  String get authBackToSignIn => 'Voltar ao início de sessão';

  @override
  String get authEnterEmail => 'Introduza o seu email';

  @override
  String get authEnterValidEmail => 'Introduza um email válido';

  @override
  String get authEnterPassword => 'Introduza a sua palavra-passe';

  @override
  String get authPasswordTooShort => 'Pelo menos 6 caracteres';

  @override
  String get authShowPassword => 'Mostrar palavra-passe';

  @override
  String get authHidePassword => 'Ocultar palavra-passe';

  @override
  String get authNewHere => 'Novo por aqui?';

  @override
  String authConfirmEmail(String email) {
    return 'Confirme $email antes de iniciar sessão. Verifique a sua caixa de entrada.';
  }

  @override
  String get authResendEmail => 'Enviar novamente';

  @override
  String get authResendingEmail => 'A enviar…';

  @override
  String get authPasswordsDoNotMatch => 'As palavras-passe não coincidem';

  @override
  String get authEnterName => 'Introduza o seu nome';

  @override
  String get authChoosePassword => 'Escolha uma palavra-passe';

  @override
  String get authHaveAccount => 'Já tem conta?';

  @override
  String get authCodeAccepted => 'Código aceite';

  @override
  String get authCodeNotFound => 'Código não encontrado';

  @override
  String authReferralFrom(String name) {
    return 'De $name. Ambos ganham um mês grátis.';
  }

  @override
  String get authReferralInvalid => 'Não foi possível encontrar este código.';

  @override
  String authResetSent(String email) {
    return 'Enviado para $email. Abra a ligação neste telemóvel.';
  }

  @override
  String get introSlide1Title => 'Fotografe o seu armário uma vez.';

  @override
  String get introSlide1Body =>
      'Fotografe uma pilha de roupa. Cada peça é recortada e organizada para si.';

  @override
  String get introSlide2Title => 'Vista-se mais depressa.';

  @override
  String get introSlide2Body =>
      'Looks com o que já tem, adaptados aos seus planos e ao tempo.';

  @override
  String get introSlide3Title => 'Veja antes de vestir.';

  @override
  String get introSlide3Body =>
      'Experimente visuais na sua própria foto ou fotografe-os como uma campanha.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsTemperature => 'Temperatura';

  @override
  String get settingsEmailUpdates => 'Atualizações por e-mail';

  @override
  String get settingsEmailUpdatesBody => 'Notícias e dicas por e-mail';

  @override
  String get settingsOutfitReminders => 'Lembretes de looks';

  @override
  String get settingsOutfitRemindersBody =>
      'Um aviso para registar o que vestiu';

  @override
  String get settingsWeeklySummary => 'Resumo semanal';

  @override
  String get settingsWeeklySummaryBody => 'A sua semana em looks';

  @override
  String get settingsStyleSection => 'Estilo';

  @override
  String get settingsPreferredStyles => 'Estilos que gosta';

  @override
  String get settingsPreferredColours => 'Cores que gosta';

  @override
  String get settingsNoneChosen => 'Nenhum escolhido';

  @override
  String get settingsPlanAiSection => 'Plano e IA';

  @override
  String get settingsPlanBillingBody => 'Plano, utilização e upgrades';

  @override
  String get settingsPlanUsageBody => 'Plano e utilização';

  @override
  String get settingsInviteFriends => 'Convidar amigos';

  @override
  String get settingsInviteFriendsBody =>
      'Um mês grátis por cada amigo que se juntar';

  @override
  String get settingsAiProvider => 'Fornecedor de IA';

  @override
  String get settingsAiProviderBody =>
      'Use o seu próprio modelo para etiquetas e imagens';

  @override
  String get settingsAppVersion => 'Versão da aplicação';

  @override
  String get settingsPrivacyTerms => 'Privacidade e termos';

  @override
  String get settingsReportProblem => 'Reportar um problema';

  @override
  String get settingsChangePassword => 'Alterar palavra-passe';

  @override
  String get settingsExportData => 'Exportar os seus dados';

  @override
  String get settingsExportBody =>
      'Preparamos um ficheiro com tudo o que guardou e abrimos a transferência.';

  @override
  String get settingsExportAction => 'Exportar';

  @override
  String get settingsCurrentPassword => 'Palavra-passe atual';

  @override
  String get settingsNewPassword => 'Nova palavra-passe';

  @override
  String get settingsConfirmNewPassword => 'Confirmar nova palavra-passe';

  @override
  String get settingsEnterCurrentPassword =>
      'Introduza a sua palavra-passe atual';

  @override
  String get settingsEnterNewPassword => 'Introduza uma nova palavra-passe';

  @override
  String get settingsPasswordMin8 => 'Use pelo menos 8 caracteres';

  @override
  String get settingsPasswordNeedsUpper => 'Adicione uma letra maiúscula';

  @override
  String get settingsPasswordNeedsLower => 'Adicione uma letra minúscula';

  @override
  String get settingsPasswordNeedsDigit => 'Adicione um número';

  @override
  String get settingsPasswordsNoMatch => 'As palavras-passe não coincidem';

  @override
  String get settingsChangeAction => 'Alterar';

  @override
  String get itemAddSnapTitle => 'Fotografe uma peça';

  @override
  String get itemAddSnapBody =>
      'Detetamos cada peça na fotografia e criamos uma imagem de estúdio limpa.';

  @override
  String get itemAddCamera => 'Tirar uma fotografia';

  @override
  String get itemAddGallery => 'Escolher da galeria';

  @override
  String get itemAddOtherWays => 'Outras formas de adicionar';

  @override
  String get itemAddSeveral => 'Adicionar várias fotografias';

  @override
  String get itemAddSeveralBody => 'Até 50 de uma vez';

  @override
  String get itemAddImportProfile => 'Importar de um perfil';

  @override
  String get itemAddImportProfileBody => 'Instagram ou Facebook';

  @override
  String get itemAddEnterDetails => 'Inserir detalhes manualmente';

  @override
  String get itemAddEnterDetailsBody => 'Não é necessária fotografia';

  @override
  String get itemManualIntro =>
      'Apenas o nome é necessário. Adicione o resto agora ou mais tarde.';

  @override
  String get itemManualNameHint => 'Por exemplo, t-shirt de algodão azul';

  @override
  String get itemManualEnterName => 'Introduza um nome';

  @override
  String get itemManualNotes => 'Notas';

  @override
  String get itemManualBrand => 'Marca';

  @override
  String get itemManualSize => 'Tamanho';

  @override
  String get itemManualEnterNumber => 'Introduza um número';

  @override
  String get itemManualSavePiece => 'Guardar peça';

  @override
  String get itemManualSaving => 'A guardar';

  @override
  String get itemManualSavedTitle => 'Guardado';

  @override
  String itemManualSavedBody(String name) {
    return '$name está no seu armário.';
  }

  @override
  String get itemManualNotSaved => 'Não guardado';

  @override
  String get itemManualAddUseCase => 'Adicionar ocasião';

  @override
  String get itemManualAddUseCaseAction => 'Adicionar ocasião';

  @override
  String get itemPhotos => 'Fotografias';

  @override
  String get itemAddPhotos => 'Adicionar fotografias';

  @override
  String get itemNoPhotoYet => 'Sem fotografia. Pode guardar sem uma.';

  @override
  String get itemRemovePhoto => 'Remover fotografia';

  @override
  String get itemRemovePiece => 'Remover peça';

  @override
  String get filterConditionLabel => 'Estado';

  @override
  String get photoshootStepPhotos => 'Fotografias';

  @override
  String get photoshootStepSetup => 'Configuração';

  @override
  String get photoshootStepCreating => 'A criar';

  @override
  String get photoshootStepResults => 'Resultados';

  @override
  String photoshootStepOf(int current, int total, String name) {
    return 'Passo $current de $total, $name';
  }

  @override
  String get photoshootOneFailed =>
      'Uma fotografia falhou. Tente novamente abaixo.';

  @override
  String photoshootManyFailed(int count) {
    return '$count fotografias falharam. Tente cada uma abaixo.';
  }

  @override
  String get photoshootFormat => 'Formato';

  @override
  String get photoshootHowMany => 'Quantidade';

  @override
  String get photoshootYourPrompt => 'O seu prompt';

  @override
  String get photoshootPromptHint => 'Golden hour num terraço, camisa de linho';

  @override
  String photoshootCreatePhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Criar $count fotografias',
      one: 'Criar 1 fotografia',
    );
    return '$_temp0';
  }

  @override
  String photoshootCountPhoto(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fotografias',
      one: 'fotografia',
    );
    return '$_temp0';
  }

  @override
  String get photoshootLimitUnknown =>
      'Não foi possível verificar o limite de hoje.';

  @override
  String photoshootUsagePlan(String plan, int remaining, int limit) {
    return 'Plano $plan: $remaining de $limit restantes hoje';
  }

  @override
  String get photoshootPlanPro => 'Pro';

  @override
  String get photoshootPlanFree => 'Gratuito';

  @override
  String get photoshootGallery => 'Galeria';

  @override
  String get photoshootUseCamera => 'Usar câmara';

  @override
  String photoshootRemovePhotoNumber(int number) {
    return 'Remover fotografia $number';
  }

  @override
  String get photoshootNoPhotosTitle => 'Nenhuma fotografia recebida';

  @override
  String get photoshootNoPhotosBody =>
      'A sessão terminou sem imagens. Tente novamente.';

  @override
  String get photoshootNewStyle => 'Novo estilo';

  @override
  String get photoshootNewPhotos => 'Novas fotografias';

  @override
  String photoshootOpenPhoto(int number) {
    return 'Abrir fotografia $number';
  }

  @override
  String get photoshootReportPhoto => 'Reportar fotografia';

  @override
  String get photoshootSaveToGallery => 'Guardar na galeria';

  @override
  String get actionUpgrade => 'Atualizar';

  @override
  String get referralLimitTitle => 'Esgotou as fotografias de hoje';

  @override
  String get referralLimitBody =>
      'As suas fotografias gratuitas regressam amanhã. Convide um amigo e ambos recebem um mês de Pro grátis.';

  @override
  String get referralLimitRefer => 'Convidar um amigo';

  @override
  String get photoshootUseLinkedin => 'LinkedIn';

  @override
  String get photoshootUseDating => 'Aplicação de encontros';

  @override
  String get photoshootUsePortfolio => 'Portefólio';

  @override
  String get photoshootUseInstagram => 'Instagram';

  @override
  String get photoshootUseAesthetic => 'Estético';

  @override
  String get photoshootUseCustom => 'O seu próprio prompt';

  @override
  String get photoshootDescLinkedin => 'Retratos profissionais para trabalho';

  @override
  String get photoshootDescDating => 'Descontraído, caloroso e natural';

  @override
  String get photoshootDescPortfolio => 'Editorial, visuais de alta moda';

  @override
  String get photoshootDescInstagram => 'Imagens de estilo de vida para o feed';

  @override
  String get photoshootDescAesthetic => 'Enquadramentos artísticos e moody';

  @override
  String get photoshootDescCustom => 'Descreva o visual que pretende';

  @override
  String get aspectSquare => 'Quadrado';

  @override
  String get aspectPortrait => 'Retrato';

  @override
  String get aspectLandscape => 'Paisagem';

  @override
  String get aspectTall => 'Alto';

  @override
  String get aspectWide => 'Largo';

  @override
  String get tryOnAppBar => 'Prova virtual';

  @override
  String get tryOnYourPhoto => 'A sua fotografia';

  @override
  String get tryOnGarment => 'Peça de roupa';

  @override
  String get tryOnUploadingPhoto => 'A carregar a sua fotografia';

  @override
  String get tryOnAddPhotoPrompt => 'Adicione uma fotografia de corpo inteiro';

  @override
  String get tryOnBodyPhotoHint =>
      'Uma fotografia de corpo inteiro funciona melhor';

  @override
  String get tryOnAddPhoto => 'Adicionar foto';

  @override
  String get tryOnChangePhoto => 'Alterar foto';

  @override
  String get tryOnPhotoLoadFailed =>
      'Não foi possível carregar a sua fotografia.';

  @override
  String get tryOnChooseGarment => 'Escolha a foto de uma peça';

  @override
  String get tryOnChooseOneGarment => 'Escolha a foto de uma peça';

  @override
  String get tryOnGarmentHint =>
      'Uma peça estendida ou num cabide funciona melhor';

  @override
  String get tryOnChange => 'Alterar';

  @override
  String get tryOnCamera => 'Câmara';

  @override
  String get tryOnRemove => 'Remover';

  @override
  String get tryOnLookTitle => 'Visual';

  @override
  String get tryOnStyle => 'Estilo';

  @override
  String get tryOnBackground => 'Fundo';

  @override
  String get tryOnPose => 'Pose';

  @override
  String get tryOnDressingUp => 'A vestir. Demora cerca de meio minuto.';

  @override
  String get tryOnEmptyResult => 'A sua prova aparece aqui';

  @override
  String get tryOnReportImage => 'Reportar imagem';

  @override
  String get tryOnCreating => 'A criar';

  @override
  String get tryOnTryAgain => 'Tentar novamente';

  @override
  String get tryOnCreate => 'Criar prova';

  @override
  String get tryOnBackgroundStudioWhite => 'Estúdio branco';

  @override
  String get tryOnBackgroundStudioGrey => 'Estúdio cinzento';

  @override
  String get tryOnBackgroundUrban => 'Rua urbana';

  @override
  String get tryOnBackgroundNature => 'Natureza';

  @override
  String get tryOnBackgroundMinimal => 'Minimalista';

  @override
  String get tryOnPoseFront => 'De frente';

  @override
  String get tryOnPoseSide => 'De lado';

  @override
  String get tryOnPoseWalking => 'A caminhar';

  @override
  String get dashboardGreetingMorning => 'Bom dia';

  @override
  String get dashboardGreetingAfternoon => 'Boa tarde';

  @override
  String get dashboardGreetingEvening => 'Boa noite';

  @override
  String get dashboardWelcome => 'Bem-vindo';

  @override
  String get dashboardOpenProfile => 'Abrir perfil';

  @override
  String get dashboardRailToday => 'Hoje';

  @override
  String get dashboardRailRecently => 'Recentemente';

  @override
  String get dashboardActivityEmpty => 'Novas peças e conjuntos aparecem aqui.';

  @override
  String get quickAddPiece => 'Adicionar peça';

  @override
  String get quickAddPieceBody => 'Fotografar e etiquetar';

  @override
  String get quickBuildOutfit => 'Criar conjunto';

  @override
  String get quickBuildOutfitBody => 'Misturar as suas peças';

  @override
  String get quickForYou => 'Para si';

  @override
  String get quickForYouBody => 'Sugestões para hoje';

  @override
  String get quickPlanWeek => 'Planear a semana';

  @override
  String get quickPlanWeekBody => 'Conjuntos por data';

  @override
  String get referralBannerUrgent => 'Com pouco espaço? Convide um amigo.';

  @override
  String get referralBannerTitle => 'Ofereça um mês, ganhe um mês.';

  @override
  String get referralBannerBody => 'Você e o seu amigo ganham um mês de Pro.';

  @override
  String get referralBannerDismiss => 'Dispensar por uma semana';

  @override
  String get referralBannerShare => 'Partilhar convite';

  @override
  String get referralBannerCopy => 'Copiar link';

  @override
  String get itemEditPieceTitle => 'Editar peça';

  @override
  String get itemEditDescriptionLabel => 'Descrição';

  @override
  String get itemEditNotSaved => 'Não guardado';

  @override
  String get itemEditSavedTitle => 'Guardado';

  @override
  String get itemEditSavedBody => 'As suas alterações foram guardadas.';

  @override
  String get itemEditSavedStalePhotos =>
      'Guardado — as fotos podem estar desatualizadas';

  @override
  String get itemEditRemovePieceHint =>
      'Eliminar esta peça da página do artigo.';

  @override
  String get itemEditNoPhotos =>
      'Sem fotos. Adicione uma da galeria ou câmara.';

  @override
  String get itemEditKeepPhoto => 'Manter foto';

  @override
  String get itemEditRemoved => 'Eliminado';

  @override
  String get itemEditAddUseCaseAction => 'Adicionar';

  @override
  String get statsNoStatsTitle => 'Sem estatísticas';

  @override
  String get statsNoStatsBody =>
      'Adicione algumas peças e a análise do seu armário aparecerá aqui.';

  @override
  String get statsByCategory => 'Por categoria';

  @override
  String get statsTotalValue => 'valor total';

  @override
  String get statsMostWorn => 'Mais usadas';

  @override
  String get statsLeastWorn => 'À espera da sua vez';

  @override
  String get statsUnnamedPiece => 'Peça sem nome';

  @override
  String get jobsTitle => 'Análises';

  @override
  String get jobsEmptyTitle => 'Sem análises';

  @override
  String get jobsEmptyBody =>
      'Fotografe uma peça e envie para segundo plano; continuará a processar aqui.';

  @override
  String get jobsNotCancelled => 'Não cancelado';

  @override
  String get jobsResume => 'Retomar';

  @override
  String get jobsReview => 'Rever';

  @override
  String get jobsStop => 'Parar';

  @override
  String get jobsDismiss => 'Dispensar';

  @override
  String get reportTitle => 'Denunciar conteúdo';

  @override
  String reportIntro(String contentType) {
    return 'Diga-nos o que está errado com este $contentType. A nossa equipa analisa todas as denúncias.';
  }

  @override
  String get reportReasonInappropriate => 'Inapropriado ou ofensivo';

  @override
  String get reportReasonNudity => 'Nudez ou conteúdo sexual';

  @override
  String get reportReasonHarassment => 'Assédio ou abuso';

  @override
  String get reportReasonImpersonation => 'Imitação de identidade';

  @override
  String get reportReasonOther => 'Outro';

  @override
  String get reportDetailsLabel => 'Detalhes adicionais (opcional)';

  @override
  String get reportSubmit => 'Enviar denúncia';

  @override
  String get reportSubmittedTitle => 'Denúncia enviada';

  @override
  String get reportSubmittedBody =>
      'Obrigado. A nossa equipa irá analisar este conteúdo.';

  @override
  String get reportFailedTitle => 'Não foi possível enviar';

  @override
  String get reportFailedBody => 'Por favor, tente novamente.';

  @override
  String get reportContentTryOnImage => 'imagem de prova virtual';

  @override
  String get reportContentSharedOutfit => 'conjunto partilhado';

  @override
  String get reportContentPhotoshootImage => 'imagem de sessão fotográfica IA';

  @override
  String get sharedOutfitTitle => 'Outfit partilhado';

  @override
  String get sharedOutfitHideTooltip => 'Ocultar este outfit';

  @override
  String get sharedOutfitReportTooltip => 'Denunciar este outfit';

  @override
  String get sharedOutfitHideTitle => 'Ocultar este outfit?';

  @override
  String get sharedOutfitHideBody =>
      'Ficará oculto neste dispositivo. Também pode denunciá-lo para que a nossa equipa o analise e remova.';

  @override
  String get sharedOutfitHideAction => 'Ocultar';

  @override
  String get sharedOutfitHiddenInfo =>
      'Este outfit não voltará a aparecer neste dispositivo.';

  @override
  String get sharedOutfitHiddenToast => 'Outfit oculto';

  @override
  String get sharedOutfitMissingTitle => 'Este outfit já não está disponível';

  @override
  String get sharedOutfitMissingBody =>
      'Pode ter sido removido ou o link está incorreto.';

  @override
  String get sharedOutfitHiddenStateTitle => 'Ocultou este outfit';

  @override
  String sharedOutfitHiddenStateBody(String email) {
    return 'Se for impróprio, denuncie em Privacidade e termos ou envie um email para $email.';
  }

  @override
  String get sharedOutfitCtaTitle => 'Gosta deste look?';

  @override
  String get sharedOutfitCtaBody =>
      'Crie outfits semelhantes com o seu próprio guarda-roupa.';

  @override
  String get sharedOutfitCtaButton => 'Obter FitCheck AI';

  @override
  String get errorTitle => 'Erro';

  @override
  String get errorUnknown => 'Ocorreu um erro inesperado';

  @override
  String get errorNoConnection => 'Sem ligação à internet. Verifique a rede.';

  @override
  String get errorTimeout => 'O pedido demorou demasiado. Tente novamente.';

  @override
  String get errorServerError =>
      'Algo correu mal do nosso lado. Tente novamente.';

  @override
  String get errorBadGateway =>
      'O servidor está temporariamente indisponível. Tente novamente.';

  @override
  String get errorServiceUnavailable =>
      'O serviço está temporariamente indisponível. Tente em breve.';

  @override
  String get errorInternalError => 'Algo correu mal. Tente novamente.';

  @override
  String get errorUnauthorized => 'Inicie sessão para continuar.';

  @override
  String get errorForbidden => 'Não tem acesso a isso.';

  @override
  String get errorSessionExpired =>
      'A sessão expirou. Inicie sessão novamente.';

  @override
  String get errorInvalidCredentials =>
      'O e-mail ou a palavra-passe não estão corretos.';

  @override
  String get errorTokenRefreshFailed =>
      'Não foi possível atualizar a sessão. Inicie sessão novamente.';

  @override
  String get errorRequestCancelled => 'Pedido cancelado.';

  @override
  String get errorInvalidFormat => 'Formato de ficheiro não suportado.';

  @override
  String get errorFileTooLarge => 'O ficheiro é demasiado grande.';

  @override
  String get errorUploadFailed => 'O carregamento falhou. Tente novamente.';

  @override
  String get errorCacheCorrupted =>
      'Os dados guardados foram danificados e repostos.';

  @override
  String get errorCacheNotFound => 'Ainda nada guardado.';

  @override
  String get errorUserNotFound => 'Não encontrámos essa conta.';

  @override
  String get errorItemNotFound => 'Essa peça já não existe.';

  @override
  String get errorOutfitNotFound => 'Esse conjunto já não existe.';

  @override
  String get rewardsTitle => 'Recompensas';

  @override
  String get rewardsNoAchievementsTitle => 'Sem conquistas';

  @override
  String get rewardsNoAchievementsBody =>
      'Adicione peças e crie conjuntos para ganhar a primeira.';

  @override
  String get rewardsEmptyLeaderboardTitle => 'Sem participantes';

  @override
  String get rewardsEmptyLeaderboardBody =>
      'Crie conjuntos para ganhar pontos e aparecer aqui.';

  @override
  String get legalViewPrivacyPolicy => 'Ver Política de Privacidade';

  @override
  String get aiConsentAgree => 'Concordo e Continuar';

  @override
  String get aiConsentNotNow => 'Agora Não';

  @override
  String get imageViewerCloseTooltip => 'Fechar visualizador de imagem';

  @override
  String get updateReadyTitle => 'Atualização pronta';

  @override
  String get updateReadyBody =>
      'Reinicie o FitCheck AI para aplicar as melhorias mais recentes.';

  @override
  String get permissionCameraUsage =>
      'O FitCheck AI precisa de acesso à câmara para tirar fotografias dos seus conjuntos e peças de vestuário.';

  @override
  String get permissionPhotoLibraryUsage =>
      'O FitCheck AI precisa de acesso à galeria de fotos para selecionar imagens dos seus conjuntos e peças de vestuário.';

  @override
  String get permissionPhotoLibraryAddUsage =>
      'O FitCheck AI precisa de guardar as suas fotos de conjuntos geradas por IA na sua galeria de fotos.';

  @override
  String get wardrobeSomePhotosSkipped => 'Algumas fotos ignoradas';

  @override
  String get wardrobePhotosNotAdded => 'Fotos não adicionadas';

  @override
  String get wardrobePhotoNotAdded => 'Foto não adicionada';

  @override
  String get wardrobeNotStartedTitle => 'Não iniciado';

  @override
  String get wardrobeNoRoomTitle => 'Sem espaço';

  @override
  String get wardrobeAddPhotosSemantic => 'Adicionar fotos';

  @override
  String get batchAddTileLabel => 'Adicionar';

  @override
  String get batchProfileLinkLabel => 'Link do perfil';

  @override
  String get wardrobeImportFromProfileTitle => 'Importar de um perfil';

  @override
  String get wardrobeAddSeveralPhotosTitle => 'Adicionar várias fotos';

  @override
  String get wardrobeClearAction => 'Limpar';

  @override
  String get wardrobeRefreshTooltip => 'Atualizar';

  @override
  String get batchNoPhotosYetTitle => 'Ainda sem fotos';

  @override
  String get batchChoosePhotosAction => 'Escolher fotos';

  @override
  String get batchWeFindEachPieceBody =>
      'Encontramos cada peça e criamos uma foto de estúdio da mesma.';

  @override
  String get batchPreparingPhotosSemantic => 'A preparar fotos';

  @override
  String get batchPhotosProcessedSemantic => 'Fotos processadas';

  @override
  String get batchPasteProfileLinkTitle => 'Colar link de perfil';

  @override
  String get batchPasteProfileLinkBody =>
      'Um perfil público do Instagram ou Facebook. Analisamos as fotos e escolhe o que entra no seu armário.';

  @override
  String get batchClearLinkTooltip => 'Limpar link';

  @override
  String get batchStartingButton => 'A iniciar';

  @override
  String get batchStartImportAction => 'Iniciar importação';

  @override
  String get batchReviewEveryPhotoTitle => 'Analisa cada foto';

  @override
  String get batchReviewEveryPhotoBody => 'Nada é adicionado até o aprovar.';

  @override
  String get batchPrivateProfilesTitle => 'Perfis privados';

  @override
  String get batchPrivateProfilesBody =>
      'Ligue a sua conta. O Instagram também pede um nome de utilizador e palavra-passe.';

  @override
  String get batchUseAnotherLinkAction => 'Usar outra ligação';

  @override
  String get batchSignInNeededTitle => 'Início de sessão necessário';

  @override
  String get batchEnterYourCodeTitle => 'Introduza o seu código';

  @override
  String get batchUseUsernamePasswordAction =>
      'Usar nome de utilizador e palavra-passe';

  @override
  String get batchAlreadyConnectedAction => 'Já me liguei no navegador';

  @override
  String get batchEnterCodeAction => 'Introduzir código';

  @override
  String get batchTryAnotherWayAction => 'Tentar outra forma';

  @override
  String get batchLiveStatus => 'Em direto';

  @override
  String get batchReconnectingStatus => 'A voltar a ligar';

  @override
  String get batchSignInToInstagramTitle => 'Iniciar sessão no Instagram';

  @override
  String get batchUsernameLabel => 'Nome de utilizador';

  @override
  String get batchCodeIfTwoStepLabel =>
      'Código, se utilizar autenticação em dois passos';

  @override
  String get batchAuthenticatorCodeBody =>
      'Utilize o código de 6 dígitos da sua aplicação de autenticação. Os códigos mudam rapidamente.';

  @override
  String get batchVerifyAction => 'Verificar';

  @override
  String get batchFindingPhotosTitle => 'A procurar fotografias';

  @override
  String get batchImportPausedTitle => 'Importação em pausa';

  @override
  String get batchProcessingPhotosTitle => 'A processar fotografias';

  @override
  String get batchWaitingNextPhoto => 'À espera da fotografia seguinte';

  @override
  String get batchCancelImportAction => 'Cancelar importação';

  @override
  String get batchNoPiecesInPhotoBody =>
      'Nenhuma peça encontrada nesta fotografia.';

  @override
  String get batchEditPieceColoursLabel => 'Cores, separadas por vírgulas';

  @override
  String get batchAddToClosetAction => 'Adicionar ao roupeiro';

  @override
  String get batchSkipPhotoAction => 'Saltar fotografia';

  @override
  String get batchImportCompleteTitle => 'Importação concluída';

  @override
  String get batchImportFailedTitle => 'Falha na importação';

  @override
  String get batchImportCancelledTitle => 'Importação cancelada';

  @override
  String get batchImportErrorBody => 'Ocorreu um erro durante a importação.';

  @override
  String get batchNothingMoreImportedBody =>
      'Não há mais nada para importar deste perfil.';

  @override
  String get batchViewClosetAction => 'Ver roupeiro';

  @override
  String get batchStartOverAction => 'Recomeçar';

  @override
  String get wardrobeAddPieceTitle => 'Adicionar peça';

  @override
  String get wardrobeAddDetailsTitle => 'Adicionar detalhes';

  @override
  String get wardrobeScanningTitle => 'A analisar';

  @override
  String get batchReviewPiecesTitle => 'Rever peças';

  @override
  String get wardrobeGalleryAction => 'Galeria';

  @override
  String get wardrobeCameraAction => 'Câmara';

  @override
  String get wardrobeNewBadge => 'Novo';

  @override
  String get wardrobeRemovePhotoTooltip => 'Remover foto';

  @override
  String get batchRunInBackgroundTooltip => 'Executar em segundo plano';

  @override
  String get batchStepOneOfTwo => 'Passo 1 de 2';

  @override
  String get batchStepTwoOfTwo => 'Passo 2 de 2';

  @override
  String get batchUploadingPhotosTitle => 'A carregar fotos';

  @override
  String get batchFindingPiecesTitle => 'A procurar peças';

  @override
  String get batchMakingStudioPhotosTitle => 'A criar fotos de estúdio';

  @override
  String get batchStoppedLabel => 'Parado';

  @override
  String get batchFindingPiecesStoppedTitle => 'Procura de peças parada';

  @override
  String get batchCancelledLabel => 'Cancelado';

  @override
  String get batchAllDoneTitle => 'Tudo pronto';

  @override
  String get batchOpeningPiecesBody => 'A abrir as suas peças';

  @override
  String get batchNothingSavedBody => 'Nada foi guardado.';

  @override
  String get batchFindingPiecesFailedBody => 'A procura de peças falhou.';

  @override
  String get batchFindingPiecesStoppedEarlyBody =>
      'A procura de peças parou mais cedo.';

  @override
  String get batchStopFindingPiecesTitle => 'Parar a procura de peças?';

  @override
  String get batchStopFindingPiecesBody =>
      'A análise para e nada é guardado. As peças já encontradas ficam na sua atividade até as dispensar.';

  @override
  String get batchKeepGoingAction => 'Continuar';

  @override
  String get batchTryAgainAction => 'Tentar novamente';

  @override
  String get batchBackToPhotosAction => 'Voltar às fotos';

  @override
  String get batchSkipAllAction => 'Ignorar tudo';

  @override
  String get batchIncludeAllAction => 'Incluir tudo';

  @override
  String get batchNoPiecesFoundTitle => 'Nenhuma peça encontrada';

  @override
  String get batchNoPiecesFoundBody => 'Não encontrámos roupas nestas fotos.';

  @override
  String get batchChooseOtherPhotosAction => 'Escolher outras fotos';

  @override
  String get batchUseCaseHelper => 'Adicionado a cada peça que guardas.';

  @override
  String get batchDiscardPiecesTitle => 'Descartar estas peças?';

  @override
  String get batchDiscardPiecesBody => 'Nada deste lote será guardado.';

  @override
  String get batchKeepAction => 'Guardar';

  @override
  String get batchDiscardAction => 'Descartar';

  @override
  String get batchRemovePieceTitle => 'Remover esta peça?';

  @override
  String get batchRemovePieceBody => 'Não fica guardada no teu armário.';

  @override
  String get batchRemoveAction => 'Remover';

  @override
  String get batchChoosePiecesToSave => 'Escolhe as peças a guardar';

  @override
  String get batchDiscardAllAction => 'Descartar tudo';

  @override
  String get batchNothingSavedRetryBody =>
      'Nada foi guardado. Tenta novamente.';

  @override
  String get batchNotSavedTitle => 'Não guardado';

  @override
  String get batchSavingLabel => 'A guardar';

  @override
  String get batchSendToBackgroundAction => 'Enviar para segundo plano';

  @override
  String get batchStillWorkingMessage =>
      'Ainda a processar. Avisamos-te quando as tuas peças estiverem prontas.';

  @override
  String get batchRunningInBackgroundTitle => 'A correr em segundo plano';

  @override
  String get batchStudioPhotosStoppedBody =>
      'Fotos de estúdio interrompidas. Podes continuar a guardar estas peças.';

  @override
  String get batchTapPieceToSkip => 'Toca numa peça para ignorar.';

  @override
  String get batchStudioPhotosOnWayBody =>
      'Fotos de estúdio a caminho. Podes sair — avisamos-te.';

  @override
  String get batchLeaveAction => 'Sair';

  @override
  String get batchPeopleInPhotosTitle => 'Pessoas nas fotos';

  @override
  String get batchIncludeAction => 'Incluir';

  @override
  String get batchSkipAction => 'Ignorar';

  @override
  String get batchYourPhotoIsUsedLabel => 'A tua foto é usada';

  @override
  String get batchMakingStudioPhotoLabel => 'A criar foto de estúdio';

  @override
  String get batchNoStudioPhotoBody =>
      'Sem foto de estúdio. A tua foto é usada.';

  @override
  String get batchEnterDetailsYourselfAction => 'Inserir detalhes manualmente';

  @override
  String get batchChooseAnotherPhotoAction => 'Escolher outra foto';

  @override
  String get batchConnectionLostTitle => 'Ligação perdida';

  @override
  String get batchConnectionLostBody =>
      'Verifique a ligação e tente novamente.';

  @override
  String get batchDailyLimitTitle => 'Limite diário atingido';

  @override
  String get batchDailyLimitBodyPaywall =>
      'Atualize para Pro para mais análises ou insira os detalhes manualmente.';

  @override
  String get batchDailyLimitBodyFree =>
      'As análises são repostas amanhã. Pode inserir os detalhes manualmente.';

  @override
  String get batchSeePlansAction => 'Ver planos';

  @override
  String get batchAiBusyTitle => 'A nossa IA está ocupada';

  @override
  String get batchAiBusyBody =>
      'O problema é do nosso lado. Tente novamente daqui a pouco.';

  @override
  String get batchNoPiecesBody =>
      'Experimente uma foto mais nítida ou insira os detalhes manualmente.';

  @override
  String get batchScanningUnavailableTitle => 'Análise indisponível';

  @override
  String get batchScanningUnavailableBody =>
      'Insira os detalhes manualmente por enquanto.';

  @override
  String get batchScanDidNotFinishTitle => 'A análise não terminou';

  @override
  String get batchTryAgainBody => 'Tentar novamente.';

  @override
  String get billingTitle => 'Subscrição';

  @override
  String get billingUpgradeHeading => 'Atualizar plano';

  @override
  String get billingUpgradeOnPlusBody => 'Mesmas funções, limites maiores.';

  @override
  String get billingUpgradeBody =>
      'Plus e Pro têm as mesmas funções. Escolha os limites de que precisa.';

  @override
  String get billingWebUnavailableBody =>
      'As atualizações online ainda não estão disponíveis. Um código promocional ou de referência desbloqueia o Plus ou Pro. Convide amigos abaixo para ganhar meses gratuitos.';

  @override
  String get billingPlansStale =>
      'Não foi possível carregar os planos mais recentes. Os preços podem estar desatualizados.';

  @override
  String get billingMonthly => 'Mensal';

  @override
  String get billingYearly => 'Anual';

  @override
  String get billingCurrentPlan => 'Plano atual';

  @override
  String get billingActive => 'Ativo';

  @override
  String get billingThisMonth => 'Este mês';

  @override
  String get billingItemExtractions => 'Extrações de peças';

  @override
  String get billingOutfitVisualizations => 'Visualizações de conjuntos';

  @override
  String get billingNearLimitUpgrade =>
      'Está perto do limite deste mês. Atualize para ter mais.';

  @override
  String get billingNearLimitResets =>
      'Está perto do limite deste mês. É reposto no início do próximo mês.';

  @override
  String get billingStoreUnavailable =>
      'As atualizações ainda não estão disponíveis na loja. Tente novamente em breve.';

  @override
  String get billingManageHeading => 'Gerir o seu plano';

  @override
  String get billingCancelPlan => 'Cancelar subscrição';

  @override
  String get billingCancelKeepsAccess =>
      'Mantém o acesso até ao fim deste período de faturação.';

  @override
  String get billingCancelConfirmTitle => 'Cancelar a sua subscrição?';

  @override
  String get billingKeepPlan => 'Manter plano';

  @override
  String get billingCancelPlanAction => 'Cancelar plano';

  @override
  String get billingBilledMonthly => 'Faturação mensal';

  @override
  String get billingBilledYearly => 'Faturação anual';

  @override
  String get billingVirtualTryOn => 'Experimentar virtualmente';

  @override
  String get billingPrioritySupport => 'Apoio prioritário';

  @override
  String get billingDisclosureProRenewing =>
      'Pro é uma subscrição com renovação automática';

  @override
  String get billingDisclosureBothRenewing =>
      'Plus e Pro são subscrições com renovação automática';

  @override
  String get billingDisclosureAppleBilling =>
      'O pagamento é cobrado ao seu ID Apple na confirmação da compra.';

  @override
  String get billingDisclosureGoogleBilling =>
      'O pagamento é cobrado à sua conta do Google Play na confirmação da compra.';

  @override
  String get billingDisclosureRenewalTerms =>
      'A sua subscrição renova-se automaticamente pelo mesmo período e ao mesmo preço, a menos que desative a renovação automática pelo menos 24 horas antes do fim do período atual.';

  @override
  String get billingDisclosureAppleManage =>
      'Gira ou cancele a qualquer momento em Definições › o seu ID Apple › Subscrições.';

  @override
  String get billingDisclosureGoogleManage =>
      'Gira ou cancele a qualquer momento no Google Play › Pagamentos e subscrições.';

  @override
  String get billingReferFriend => 'Convidar um amigo';

  @override
  String get billingHowItWorks => 'Como funciona';

  @override
  String get billingHowShareTitle => 'Partilhe o seu link';

  @override
  String get billingHowShareBody => 'Envie-o a um amigo.';

  @override
  String get billingHowSignUpTitle => 'Eles registam-se';

  @override
  String get billingHowSignUpBody => 'O seu amigo entra através do link.';

  @override
  String get billingHowBothTitle => 'Ambos recebem o Pro';

  @override
  String get billingHowBothBody =>
      'Cada um de vocês recebe um mês de Pro grátis.';

  @override
  String get billingYourReferrals => 'As suas referências';

  @override
  String get billingInvited => 'Convidados';

  @override
  String get billingJoined => 'Registados';

  @override
  String get billingMonthsEarned => 'Meses ganhos';

  @override
  String get billingInviteFriend => 'Convidar amigo';

  @override
  String get billingInviteBody => 'Tu e o teu amigo recebem um mês de Pro.';

  @override
  String get billingYourCode => 'O teu código';

  @override
  String get billingCopyLink => 'Copiar link';

  @override
  String get billingShareInvite => 'Partilhar convite';

  @override
  String get giftUnavailable =>
      'Os convites de oferta não estão disponíveis nesta versão.';

  @override
  String get giftPageTitle => 'Oferecer FitCheck Pro';

  @override
  String get giftNoAllowances =>
      'De momento, não há convites de oferta gratuitos disponíveis.';

  @override
  String get giftFormTitle => 'Enviar um convite gratuito';

  @override
  String get giftFormBody =>
      'O destinatário resgata a oferta com este e-mail verificado. Nós não enviamos o e-mail por ti.';

  @override
  String get giftFieldFrom => 'De';

  @override
  String get giftFieldRecipientName => 'Nome do destinatário';

  @override
  String get giftFieldRecipientEmail => 'E-mail do destinatário';

  @override
  String get giftFieldOccasion => 'Ocasião (opcional)';

  @override
  String get giftNoOccasion => 'Sem ocasião';

  @override
  String get giftOccasionBirthday => 'Aniversário';

  @override
  String get giftOccasionAnniversary => 'Aniversário de namoro/casamento';

  @override
  String get giftOccasionOther => 'Outro';

  @override
  String get giftFieldCardGreeting => 'Mensagem do cartão';

  @override
  String get giftFieldCardGreetingHelper =>
      'Isto aparece no cartão exatamente como escrito.';

  @override
  String get giftFieldPrivateNote => 'Nota privada (opcional)';

  @override
  String get giftCreateAction => 'Criar oferta gratuita';

  @override
  String get giftClaimedTitle => 'Oferta resgatada';

  @override
  String get giftClaimedActive => 'A tua oferta FitCheck Pro está ativa.';

  @override
  String get giftClaimedQueued =>
      'A tua oferta FitCheck Pro começa após o teu acesso atual.';

  @override
  String get giftLinkCopied =>
      'Link da oferta copiado para a área de transferência.';

  @override
  String get giftErrorName => 'Introduz um nome.';

  @override
  String get giftErrorEmail => 'Introduz um endereço de e-mail válido.';

  @override
  String get giftErrorGreeting => 'Introduz a mensagem do cartão.';

  @override
  String get giftErrorGreetingLength => 'Usa no máximo 80 caracteres.';

  @override
  String get giftClaimAction => 'Reclamar oferta';

  @override
  String get giftCardPreview => 'Pré-visualização do cartão';

  @override
  String get giftGiftForYou => 'Um presente para ti';

  @override
  String get giftGiftWaiting => 'Tens um presente à tua espera';

  @override
  String get giftOpenBody =>
      'Abre os teus presentes para os reclamar com o teu e-mail verificado.';

  @override
  String get giftOpenGifts => 'Abrir presentes';

  @override
  String get giftSendInvitation => 'Enviar convite';

  @override
  String get settingsAiProviderSection => 'Fornecedor';

  @override
  String get settingsAiCustom => 'Personalizado';

  @override
  String get settingsAiUrlHelper =>
      'Usa um URL público acessível pelo servidor. O Localhost não funciona a partir dos nossos servidores.';

  @override
  String get settingsAiConnectionSection => 'Ligação';

  @override
  String get settingsAiApiUrl => 'URL da API';

  @override
  String get settingsAiApiKey => 'Chave da API';

  @override
  String get settingsAiApiKeySaved => 'Guardado. Deixa em branco para manter.';

  @override
  String get settingsAiChatModel => 'Modelo de chat';

  @override
  String get settingsAiVisionModel => 'Modelo de visão (opcional)';

  @override
  String get settingsAiImageModel => 'Modelo de imagem (opcional)';

  @override
  String get settingsAiImageModelNote =>
      'A geração de imagens requer chat completions compatíveis com OpenAI com response_modalities.';

  @override
  String get settingsAiTestConnection => 'Testar ligação';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get calendarGoToToday => 'Ir para hoje';

  @override
  String get calendarConnectTooltip => 'Ligar um calendário';

  @override
  String get calendarAddEvent => 'Adicionar evento';

  @override
  String get calendarEmptyTitle => 'Sem planos';

  @override
  String get calendarEmptyBody => 'Adiciona um evento e planeia o que vestir.';

  @override
  String get calendarPreviousMonth => 'Mês anterior';

  @override
  String get calendarNextMonth => 'Mês seguinte';

  @override
  String get calendarAllDay => 'Todo o dia';

  @override
  String get calendarOutfitLinked => 'Conjunto associado';

  @override
  String get calendarEventOptions => 'Opções do evento';

  @override
  String get calendarDeleteTitle => 'Eliminar este evento?';

  @override
  String get calendarChangeOutfit => 'Mudar conjunto';

  @override
  String get calendarLinkOutfit => 'Associar conjunto';

  @override
  String get calendarRemoveOutfit => 'Remover conjunto';

  @override
  String get calendarNewEvent => 'Novo evento';

  @override
  String get calendarEditEvent => 'Editar evento';

  @override
  String get calendarTitleLabel => 'Título';

  @override
  String get calendarTitleRequired => 'Adicionar um título';

  @override
  String get calendarEndBeforeStart => 'O fim deve ser após o início';

  @override
  String get calendarStarts => 'Início';

  @override
  String get calendarEnds => 'Fim';

  @override
  String get calendarPlaceOptional => 'Local (opcional)';

  @override
  String get calendarNotesOptional => 'Notas (opcional)';

  @override
  String get calendarLinkOutfitEmptyBody =>
      'Crie um conjunto para o associar a este evento.';

  @override
  String get calendarBuildOutfit => 'Criar conjunto';

  @override
  String get calendarConnectionsTitle => 'Calendários';

  @override
  String get calendarConnectionsBody =>
      'Os eventos adicionados aqui ficam no FitCheck.';

  @override
  String get calendarDisconnect => 'Desligar';

  @override
  String get calendarNotAvailable => 'Ainda não disponível';

  @override
  String get profileSectionExplore => 'Explorar';

  @override
  String get profileNavTryOn => 'Experimentar';

  @override
  String get profileNavRewards => 'Recompensas';

  @override
  String get profileSupport => 'Suporte';

  @override
  String get profileHelp => 'Ajuda';

  @override
  String get profileAbout => 'Sobre';

  @override
  String get profileAboutBody =>
      'O seu armário, conjuntos e planos num só lugar.';

  @override
  String get profileSignOutTitle => 'Terminar sessão?';

  @override
  String get profileSignOutBody =>
      'Pode iniciar sessão novamente a qualquer momento.';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileYourProfile => 'O seu perfil';

  @override
  String get profileBodyProfiles => 'Perfis corporais';

  @override
  String get profileBodyEmptyTitle => 'Ainda sem perfis corporais';

  @override
  String get profileBodyEmptyBody =>
      'Adicione a sua altura e compleição para um melhor ajuste.';

  @override
  String get profileBodyAdd => 'Adicionar perfil';

  @override
  String get profileBodyDefaultNote =>
      'O seu perfil predefinido é usado para ajuste e teste.';

  @override
  String get profileBodyDefaultBadge => 'Predefinido';

  @override
  String get profileBodyMakeDefault => 'Tornar predefinido';

  @override
  String get profileBodyDeleteBody => 'Não pode anular esta ação.';

  @override
  String get profileBodyRequired => 'Obrigatório';

  @override
  String get profileBodyCheckNumber => 'Verifique este número';

  @override
  String get profileBodyNew => 'Novo perfil corporal';

  @override
  String get profileBodyNameHint => 'Por exemplo, Eu';

  @override
  String get profileBodyHeight => 'Altura';

  @override
  String get profileBodyWeight => 'Peso';

  @override
  String get profileBodyBuild => 'Compleição';

  @override
  String get profileBodySkinTone => 'Tom de pele';

  @override
  String get profileBirthDateNeededBody =>
      'Adicione uma data de nascimento para acompanhar a hora de nascimento.';

  @override
  String get profileBirthDateNeededTitle => 'Data de nascimento necessária';

  @override
  String get profilePartlySavedBody =>
      'Guardámos o seu nome e foto. Os dados de nascimento não foram guardados; tente novamente mais tarde.';

  @override
  String get profilePartlySavedTitle => 'Parcialmente guardado';

  @override
  String get profileSavedBody => 'O seu perfil foi guardado.';

  @override
  String get profileChangePhoto => 'Alterar foto de perfil';

  @override
  String get profilePhotoLabel => 'Foto de perfil';

  @override
  String get profilePhotoHint => 'Toque para escolher uma nova';

  @override
  String get profileBirthDateLabel => 'Data de nascimento (opcional)';

  @override
  String get profileBirthTimeLabel => 'Hora de nascimento (opcional)';

  @override
  String get profileBirthTimeHelper => 'Torna as sugestões védicas mais exatas';

  @override
  String get profileBirthPlaceLabel => 'Local de nascimento (opcional)';

  @override
  String get profileBirthPlaceHint => 'Por exemplo, Lisboa, Portugal';

  @override
  String get profileHelpContactTitle => 'Pergunte-nos o que quiser';

  @override
  String get profileHelpContactBody =>
      'Envie uma mensagem e respondemos por email, normalmente em menos de um dia.';

  @override
  String get profileHelpContactAction => 'Contactar suporte';

  @override
  String get profileHelpFaqTitle => 'Perguntas frequentes';

  @override
  String get profileFaqAddPiecesTitle => 'Como adiciono peças ao meu roupeiro?';

  @override
  String get profileFaqAddPiecesBody =>
      'Toque em Adicionar peça no separador Roupeiro. Tire uma foto ou escolha uma da galeria; detetamos cada peça e etiquetamos por si.';

  @override
  String get profileFaqMatchingTitle =>
      'Como funciona a combinação de conjuntos?';

  @override
  String get profileFaqMatchingBody =>
      'Abra Para si e escolha peças que tem. Sugerimos o que combina e criamos conjuntos completos a partir do seu roupeiro.';

  @override
  String get profileFaqTryOnTitle =>
      'Posso usar as minhas próprias fotos para a prova?';

  @override
  String get profileFaqTryOnBody =>
      'Sim. Adicione uma foto de corpo inteiro e escolha peças para as ver vestidas.';

  @override
  String get profileFaqRewardsTitle => 'Como ganho recompensas?';

  @override
  String get profileFaqRewardsBody =>
      'Planeie e registe conjuntos com frequência. Sequências e conquistas acumulam-se à medida que avança.';

  @override
  String get profileFaqPrivacyTitle => 'O meu roupeiro é privado?';

  @override
  String get profileFaqPrivacyBody =>
      'Sim. O seu roupeiro e conjuntos são privados, exceto se partilhar a hiperligação para um conjunto.';

  @override
  String get profileHelpMoreTitle => 'Mais ajuda';

  @override
  String get profileHelpGuides => 'Guia';

  @override
  String get profileHelpGuidesBody => 'Como funciona cada funcionalidade';

  @override
  String get feedbackCategoryBug => 'Erro técnico';

  @override
  String get feedbackCategoryIdea => 'Uma ideia';

  @override
  String get feedbackCategoryGeneral => 'Geral';

  @override
  String get feedbackCategoryHelp => 'Preciso de ajuda';

  @override
  String get feedbackHintBug =>
      'O que aconteceu e o que esperava? Os passos ajudam-nos a corrigir.';

  @override
  String get feedbackHintIdea => 'O que gostaria de ver e porquê?';

  @override
  String get feedbackHintGeneral =>
      'Diga-nos o que acha ou coloque uma questão.';

  @override
  String get feedbackAttachmentLimitBody => 'Pode adicionar até 5 imagens.';

  @override
  String get feedbackAttachmentLimitTitle => 'Limite atingido';

  @override
  String get feedbackImageTooLargeBody =>
      'Escolha uma imagem com menos de 5 MB.';

  @override
  String get feedbackImageTooLargeTitle => 'Imagem demasiado grande';

  @override
  String get feedbackTitle => 'Enviar opinião';

  @override
  String get feedbackAboutLabel => 'Sobre o quê?';

  @override
  String get feedbackSubjectLabel => 'Assunto';

  @override
  String get feedbackSubjectRequired => 'Adicione um assunto';

  @override
  String get feedbackSubjectTooShort =>
      'O assunto deve ter pelo menos 3 caracteres';

  @override
  String get feedbackDetailsLabel => 'Detalhes';

  @override
  String get feedbackDetailsRequired => 'Adicione alguns detalhes';

  @override
  String get feedbackDetailsTooShort =>
      'A descrição deve ter pelo menos 10 caracteres';

  @override
  String get feedbackAddScreenshot => 'Adicionar captura de ecrã';

  @override
  String get feedbackAttachmentHint => 'Até 5, 5 MB cada';

  @override
  String get feedbackSend => 'Enviar';

  @override
  String get feedbackEmptyTitle => 'Ainda nada enviado';

  @override
  String get feedbackEmptyBody =>
      'O que envia aparece aqui com o respetivo estado.';

  @override
  String get feedbackHistoryTitle => 'O que enviou';

  @override
  String get feedbackStatusOpen => 'Aberto';

  @override
  String get feedbackStatusInProgress => 'Em curso';

  @override
  String get feedbackStatusResolved => 'Resolvido';

  @override
  String get feedbackStatusClosed => 'Fechado';

  @override
  String get legalIntro =>
      'Como protegemos os seus dados e os termos de utilização do FitCheck AI.';

  @override
  String get legalPolicies => 'Políticas';

  @override
  String get legalPrivacySubtitle => 'O que recolhemos e porquê';

  @override
  String get legalTermsTitle => 'Termos de serviço';

  @override
  String get legalTermsSubtitle => 'As regras de utilização da aplicação';

  @override
  String get legalLicences => 'Licenças de código aberto';

  @override
  String get legalSupportSubtitle => 'Ajuda, contacto e pedidos de privacidade';

  @override
  String get legalReportAbuse => 'Comunicar um problema ou abuso';

  @override
  String get permissionCameraTitle => 'Acesso à Câmara';

  @override
  String get permissionCameraRationale =>
      'O FitCheck AI utiliza a sua câmara para tirar fotografias das suas roupas e conjuntos para a provagem por IA e organização do armário.';

  @override
  String get permissionPhotoTitle => 'Acesso às Fotografias';

  @override
  String get permissionPhotoRationale =>
      'O FitCheck AI precisa de acesso às suas fotos para poder selecionar imagens de roupa para as funcionalidades de IA e o seu armário.';

  @override
  String get permissionNotNow => 'Agora Não';

  @override
  String get permissionOpenSettings => 'Abrir Definições';

  @override
  String authSignedInAs(String name) {
    return 'Sessão iniciada como $name';
  }

  @override
  String get authSignedIn => 'Sessão iniciada';

  @override
  String get authWelcomeBackTitle => 'Bem-vindo de volta';

  @override
  String get authSignInFailed => 'Erro ao iniciar sessão';

  @override
  String get authWelcomeTitle => 'Bem-vindo';

  @override
  String get authSignUpFailed => 'Erro ao criar conta';

  @override
  String get authGoogleSignInFailed => 'Erro no início de sessão Google';

  @override
  String get authAppleSignInFailed => 'Erro no início de sessão Apple';

  @override
  String get authConfirmEmailTitle => 'Confirme o seu email';

  @override
  String get authConfirmEmailBody =>
      'Verifique a sua caixa de entrada para confirmar o email e inicie sessão.';

  @override
  String get authClosetReady => 'O seu roupeiro está pronto.';

  @override
  String get authSignedOutTitle => 'Sessão terminada';

  @override
  String get authSignedOutBody => 'A sua sessão foi terminada.';

  @override
  String get authSignOutFailed => 'Erro ao terminar sessão';

  @override
  String get authEmailSentTitle => 'Email enviado';

  @override
  String get authResetLinkSent =>
      'Verifique o seu email para obter o link de recuperação.';

  @override
  String get authPasswordUpdatedTitle => 'Palavra-passe atualizada';

  @override
  String get authPasswordUpdated => 'A sua palavra-passe foi atualizada.';

  @override
  String get authPasswordNotUpdated => 'Palavra-passe não atualizada';

  @override
  String get authCouldNotSendEmail => 'Não foi possível enviar o email';

  @override
  String get authEmailNotSent => 'Email não enviado';

  @override
  String get authResendSentBody => 'Enviámos um novo email de confirmação.';

  @override
  String get outfitPreviewWithAi => 'Pré-visualizar com IA';

  @override
  String get outfitNewPreview => 'Criar nova pré-visualização';

  @override
  String get outfitBuilderClosetHeading => 'O teu roupeiro';

  @override
  String get outfitBuilderSearchHint => 'Procurar peças';

  @override
  String get outfitClearSearch => 'Limpar pesquisa';

  @override
  String get outfitBuilderAddPiecesTitle => 'Adiciona peças primeiro';

  @override
  String get outfitBuilderAddPiecesBody =>
      'Os fatos são feitos com as peças do teu roupeiro.';

  @override
  String get outfitBuilderNoMatches => 'Nenhuma peça corresponde.';

  @override
  String get outfitNameLabel => 'Nome do fato';

  @override
  String get outfitNameHint => 'Por exemplo, Linho de fim de semana';

  @override
  String get outfitPreviewSemantic => 'Pré-visualização IA do fato';

  @override
  String get outfitChoosePieces => 'Escolher peças';

  @override
  String get outfitTapPiecesHint => 'Toca nas peças abaixo para as adicionar.';

  @override
  String get outfitShareTooltip => 'Partilhar';

  @override
  String get outfitSaveFavourite => 'Guardar nos favoritos';

  @override
  String get outfitPiecesHeading => 'Peças';

  @override
  String get outfitWearHistoryEmpty =>
      'Usa-o uma vez e as datas aparecem aqui.';

  @override
  String get outfitWearHistoryTitle => 'Histórico de uso';

  @override
  String get outfitWearHistoryError => 'Não foi possível carregar as datas.';

  @override
  String get outfitWornOn => 'Usado em';

  @override
  String get outfitEditTitle => 'Editar fato';

  @override
  String get outfitSavedPhotosFailed => 'Detalhes guardados, fotos não';

  @override
  String get outfitNoPhotosBody =>
      'Sem fotos ainda. O fato mostra as suas peças.';

  @override
  String get outfitOccasionLabel => 'Ocasião';

  @override
  String get outfitOccasionNone => 'Nenhuma';

  @override
  String get outfitTagsHint => 'Separa com vírgulas';

  @override
  String get outfitDraftBody => 'Oculto da tua lista principal';

  @override
  String get outfitPublic => 'Público';

  @override
  String get outfitPublicBody => 'Qualquer pessoa com o link pode ver';

  @override
  String get outfitDeleteFromDetail =>
      'Eliminar este fato da página de detalhes.';

  @override
  String get outfitNewCollection => 'Nova coleção';

  @override
  String get outfitNoCollectionsTitle => 'Sem coleções';

  @override
  String get outfitNoCollectionsBody =>
      'Agrupa looks por viagem, estação ou estado de espírito.';

  @override
  String get outfitCreateCollection => 'Criar coleção';

  @override
  String get outfitAddOutfits => 'Adicionar looks';

  @override
  String get outfitRename => 'Renomear';

  @override
  String get outfitCollectionDeleteBody => 'Os looks serão mantidos.';

  @override
  String get outfitCollectionsNotLoaded => 'Looks não carregados';

  @override
  String get outfitRenameCollection => 'Renomear coleção';

  @override
  String get outfitDescriptionOptional => 'Descrição (opcional)';

  @override
  String get outfitAllInCollection => 'Todos os looks já estão nesta coleção.';

  @override
  String get photoshootSubtitleUpload =>
      'Retratos de estúdio a partir das suas fotos';

  @override
  String get photoshootSubtitleConfigure =>
      'Escolha estilo, formato e quantidade';

  @override
  String get photoshootSubtitleGenerating => 'Isto leva um ou dois minutos';

  @override
  String get photoshootAddPhotosSemantic => 'Adicionar fotos da sua galeria';

  @override
  String get photoshootUploadTitle => 'Adicione 1 a 4 fotos suas';

  @override
  String get photoshootUploadBody => 'Toque para escolher da sua galeria';

  @override
  String get photoshootAddToContinue => 'Adicione uma foto para continuar';

  @override
  String get photoshootAddAnotherPhoto => 'Adicionar outra foto';

  @override
  String get photoshootTipsTitle => 'Para melhores resultados';

  @override
  String get photoshootTipsBody =>
      'Use fotos nítidas e bem iluminadas do seu rosto em vários ângulos. Evite óculos de sol e chapéus.';

  @override
  String get photoshootStarting => 'A iniciar';

  @override
  String get photoshootCancelling => 'A cancelar';

  @override
  String get photoshootFailed => 'Falhou';

  @override
  String get recommendTabMatches => 'Compatíveis';

  @override
  String get recommendTabComplete => 'Completo';

  @override
  String get recommendTabWeather => 'Tempo';

  @override
  String get recommendTabColours => 'Cores';

  @override
  String get recommendTabShop => 'Loja';

  @override
  String get recommendNoMatchesTitle => 'Sem compatíveis';

  @override
  String get recommendNoMatchesBody =>
      'Escolha uma peça e encontraremos combinações.';

  @override
  String get recommendPickPiece => 'Escolher peça';

  @override
  String get recommendNothingMatchesTitle => 'Nada corresponde por agora';

  @override
  String get recommendNothingMatchesBody =>
      'Experimente outras peças ou adicione mais ao seu armário.';

  @override
  String get recommendChangePieces => 'Mudar peças';

  @override
  String get recommendDefaultReason => 'Combina com as peças que escolheu.';

  @override
  String get recommendCompleteTitle => 'Completar look';

  @override
  String get recommendCompleteBody => 'Escolha uma peça e preenchemos o resto.';

  @override
  String get recommendWorking => 'A processar';

  @override
  String get recommendGenerate => 'Gerar';

  @override
  String get recommendChooseStyleBody => 'Escolha um estilo e gere.';

  @override
  String get recommendNoLooksTitle => 'Sem looks para estas peças';

  @override
  String get recommendNoLooksBody => 'Experimente outro estilo ou peças.';

  @override
  String get recommendDefaultLook => 'Um look para as suas peças';

  @override
  String get recommendNoPiecesBody => 'Nenhuma peça devolvida para este look.';

  @override
  String get recommendCityLabel => 'Cidade';

  @override
  String get recommendCheck => 'Verificar';

  @override
  String get recommendWeatherTitle => 'Qual é o tempo?';

  @override
  String get recommendWeatherBody => 'Indique a cidade para sugestões de hoje.';

  @override
  String get recommendWearToday => 'Usar hoje';

  @override
  String get recommendWeatherNoPieces => 'Ainda não há peças para este tempo.';

  @override
  String get recommendBudgetLabel => 'Orçamento até';

  @override
  String get recommendLooking => 'À procura';

  @override
  String get recommendFindWhatToBuy => 'Encontrar para comprar';

  @override
  String get recommendFillGapsTitle => 'Preencher lacunas';

  @override
  String get recommendFillGapsBody =>
      'Defina um orçamento e sugerimos o que falta no seu armário.';

  @override
  String get recommendNoGapsTitle => 'Sem lacunas';

  @override
  String get recommendNoGapsBody =>
      'Experimente um orçamento maior ou outra categoria.';

  @override
  String get recommendMoodEveryday => 'Dia a dia';

  @override
  String get recommendMoodBigMeeting => 'Reunião importante';

  @override
  String get recommendDayLabel => 'Dia';

  @override
  String get recommendReadingStars => 'A ler as estrelas';

  @override
  String get recommendGetMyColours => 'Ver as minhas cores';

  @override
  String get recommendLuckyColoursTitle => 'Cores de sorte';

  @override
  String get recommendLuckyColoursBody =>
      'Escolha um dia e sugerimos cores e peças.';

  @override
  String get recommendLuckyColoursSection => 'Cores de sorte';

  @override
  String get recommendAvoidColoursSection => 'Cores a evitar';

  @override
  String get recommendBirthDateTitle => 'Adicionar data de nascimento';

  @override
  String get recommendBirthDateBody =>
      'Precisamos da sua data de nascimento para ler as cores.';

  @override
  String get recommendEditProfile => 'Editar perfil';

  @override
  String get recommendNothingThisDay => 'Nada para este dia.';

  @override
  String get recommendUnnamedColour => 'Cor sem nome';

  @override
  String get recommendFromCloset => 'Da sua guarda-roupa';

  @override
  String get recommendNoPiecesInColours => 'Ainda sem peças nestas cores.';

  @override
  String get recommendOutfitIdeas => 'Ideias de looks';

  @override
  String get recommendNoOutfitsInColours =>
      'Ainda sem look completo nestas cores.';

  @override
  String get recommendDefaultOutfitIdea => 'Uma ideia de look';

  @override
  String get recommendPickUpToThree => 'Escolher até 3 peças';

  @override
  String get recommendEmptyClosetBody =>
      'Adicione algumas peças primeiro e volte para matches.';

  @override
  String get dashboardDressForDay => 'Vista-se para o dia.';

  @override
  String get dashboardOutfitOfDay => 'Look do dia';

  @override
  String get dashboardFreshLook => 'Um look novo';

  @override
  String get subscriptionManageInStoreTitle => 'Gerir na loja';

  @override
  String get subscriptionManageInStoreBody =>
      'Este plano é cobrado pela loja. Gerir no seu perfil de conta.';

  @override
  String get subscriptionCancelledTitle => 'Subscrição cancelada';

  @override
  String get subscriptionCancelledBody =>
      'O plano fica ativo até ao fim deste período de faturação.';

  @override
  String get subscriptionCancelFailedTitle => 'Não foi possível cancelar';

  @override
  String get subscriptionCouldNotOpenTitle => 'Não foi possível abrir';

  @override
  String get subscriptionOpenBillingFailedBody =>
      'Não foi possível abrir a gestão de faturação.';

  @override
  String get subscriptionOpenLinkFailedBody => 'Não foi possível abrir o link.';

  @override
  String get subscriptionReferralLoadFailedTitle =>
      'Não foi possível carregar o seu link';

  @override
  String get subscriptionReferralLoadFailedBody =>
      'Não foi possível carregar o seu link de recomendação. Tente novamente.';

  @override
  String get subscriptionReferralCopiedTitle => 'Copiado';

  @override
  String get subscriptionReferralCopiedBody => 'Link de recomendação copiado.';

  @override
  String get subscriptionReferralShareSubject => 'Experimente o FitCheck AI';

  @override
  String subscriptionReferralShareMessage(String link) {
    return 'Junte-se ao FitCheck AI e ambos ganhamos um mês do Pro. $link';
  }

  @override
  String get subscriptionLinkCopiedTitle => 'Link copiado';

  @override
  String get subscriptionShareUnavailableBody =>
      'O partilha não está disponível, por isso copiamos o link.';

  @override
  String get subscriptionShareFailedTitle => 'Não foi possível partilhar';

  @override
  String get subscriptionShareFailedBody =>
      'Copie o link a partir da página de recomendação.';

  @override
  String get subscriptionStoreReadyTitle => 'Loja preparada';

  @override
  String get subscriptionStoreReadyBody =>
      'Os preços da loja estão disponíveis. Pode fazer upgrade agora.';

  @override
  String get purchaseFailedTitle => 'Compra falhada';

  @override
  String get purchaseUnavailableTitle => 'Compra não disponível';

  @override
  String get purchaseIapUnavailableBody =>
      'As compras dentro da aplicação não estão disponíveis neste dispositivo.';

  @override
  String get purchasePlanNotAvailableBody =>
      'Este plano ainda não está disponível para compra.';

  @override
  String get purchasePlanNotInStoreBody =>
      'Este plano ainda não está disponível na loja. Volte mais tarde.';

  @override
  String get purchaseStartFailedBody =>
      'Não foi possível iniciar a compra. Tente novamente.';

  @override
  String get purchaseNoPaymentLinkBody =>
      'O checkout não devolveu um link de pagamento.';

  @override
  String get purchasePendingTitle => 'Compra pendente';

  @override
  String get purchasePendingBody =>
      'A sua compra está à espera de aprovação. Terá acesso assim que for aprovada.';

  @override
  String get purchaseFailedBody => 'A compra falhou. Tente novamente.';

  @override
  String get purchaseRestoredTitle => 'Restaurado';

  @override
  String get purchaseRestoredBody => 'As suas compras foram restauradas.';

  @override
  String get purchaseActiveTitle => 'Assinatura ativa';

  @override
  String get purchaseActiveBody => 'A sua assinatura está ativa. Bem-vindo.';

  @override
  String get purchaseSignInRequiredTitle => 'É necessário iniciar sessão';

  @override
  String get purchaseSignInRequiredBody =>
      'Inicie sessão para terminar a sua compra.';

  @override
  String get purchaseErrorTitle => 'Erro na compra';

  @override
  String get purchaseInvalidTransactionBody =>
      'A compra não incluiu um ID de transação verificável.';

  @override
  String get purchaseVerificationPendingTitle => 'Verificação pendente';

  @override
  String get purchaseVerificationPendingBody =>
      'Não foi possível verificar a sua compra na loja neste momento. Será concluída automaticamente e não será cobrado duas vezes.';

  @override
  String get purchaseNotAppliedTitle => 'Compra não aplicada';

  @override
  String get purchaseNotAppliedBody =>
      'A sua compra não pôde ser aplicada à sua conta. Contacte o apoio e não a compre novamente.';

  @override
  String get purchaseRestoreFailedTitle => 'Falha na recuperação';

  @override
  String get purchaseRestoreFailedBody =>
      'Não foi possível recuperar as compras. Tente novamente.';

  @override
  String get purchaseRecoveredActiveBody => 'A sua subscrição está ativa.';

  @override
  String get purchaseCompleteTitle => 'Compra concluída';

  @override
  String get giftCreateFailedTitle => 'Não foi possível criar a oferta';

  @override
  String get giftClaimFailedTitle => 'Não foi possível resgatar a oferta';

  @override
  String giftIncomingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ofertas para si',
      one: 'Uma oferta para si',
    );
    return '$_temp0';
  }

  @override
  String giftDurationTerm(String months) {
    String _temp0 = intl.Intl.selectLogic(months, {
      '1': '1 mês',
      '12': '1 ano',
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
    return '$sender enviou-lhe $duration de FitCheck Pro. $link';
  }

  @override
  String giftShareSubject(String recipient) {
    return 'Oferta de FitCheck Pro para $recipient';
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
  String get giftPreviewPlaceholderRecipient => 'o seu destinatário';

  @override
  String get giftPreviewPlaceholderSender => 'si';

  @override
  String get settingsSavedTitle => 'Guardado';

  @override
  String get settingsNotSavedTitle => 'Não guardado';

  @override
  String get settingsAiChooseProviderBody => 'Escolha um fornecedor.';

  @override
  String get settingsAiCustomUrlRequiredBody =>
      'Um fornecedor personalizado precisa de um URL de API.';

  @override
  String get settingsAiKeyRequiredBody => 'Introduza uma chave de API.';

  @override
  String get settingsAiSavedBody => 'As suas definições de IA foram guardadas.';

  @override
  String get settingsAiMissingDetailsTitle => 'Faltam detalhes';

  @override
  String get settingsAiUrlAndModelRequiredBody =>
      'Introduza um URL de API e um modelo de chat para testar.';

  @override
  String get settingsAiKeyNeededTitle => 'Chave de API necessária';

  @override
  String get settingsAiKeyToTestPrivateBody =>
      'Insere a tua chave da API para testar. A tua chave fica privada.';

  @override
  String get settingsAiKeyToTestBody =>
      'Insere a tua chave da API para testar.';

  @override
  String get settingsAiConnectedTitle => 'Ligado';

  @override
  String get settingsAiConnectedBody => 'A ligação funciona.';

  @override
  String get settingsAiTestFailedTitle => 'Teste falhou';

  @override
  String get settingsPreferencesSavedBody =>
      'As tuas preferências foram guardadas.';

  @override
  String get settingsPasswordNotChangedTitle => 'Palavra-passe não alterada';

  @override
  String get settingsOAuthPasswordBody =>
      'Esta conta inicia sessão com Google ou Apple. Usa \"Esqueci a palavra-passe\" para definir primeiro uma palavra-passe.';

  @override
  String get settingsCurrentPasswordIncorrectBody =>
      'A palavra-passe atual está incorreta.';

  @override
  String get settingsExportReadyTitle => 'Exportação pronta';

  @override
  String get settingsExportReadyBody =>
      'A tua exportação de dados está pronta para descarregar.';

  @override
  String get settingsLinkCopiedTitle => 'Ligação copiada';

  @override
  String get settingsExportClipboardBody =>
      'Não foi possível abrir o teu navegador, por isso copiamos a ligação de descarga. Cola-a num navegador em breve: expira.';

  @override
  String get settingsExportFailedTitle => 'Exportação falhou';

  @override
  String get settingsAccountNotDeletedTitle => 'Conta não apagada';

  @override
  String photoshootPhotoLimit(int max) {
    return 'Podes adicionar até $max fotografias.';
  }

  @override
  String get photoshootPhotoLimitTitle => 'Limite de fotografias';

  @override
  String get photoshootAddAtLeastOnePhoto =>
      'Adiciona pelo menos uma fotografia.';

  @override
  String get photoshootNoPhotosSelectedTitle => 'Sem fotografias';

  @override
  String get photoshootDescribeLookBody => 'Descreve o look que queres.';

  @override
  String get photoshootPromptNeededTitle => 'Prompt necessário';

  @override
  String get photoshootConsentFeatureLabel => 'Sessão Fotográfica IA';

  @override
  String get photoshootStatusPreparing => 'A preparar as tuas fotografias';

  @override
  String get photoshootStatusGenerating => 'A gerar';

  @override
  String photoshootStatusBatch(int current, int total) {
    return 'Lote $current de $total';
  }

  @override
  String photoshootStatusImagesDone(int done, int total) {
    return '$done de $total concluídas';
  }

  @override
  String get photoshootGenerationFailedBody => 'A geração falhou.';

  @override
  String photoshootPartlyDoneBody(int ready, int failed) {
    return '$ready prontas, $failed falharam.';
  }

  @override
  String get photoshootPartlyDoneTitle => 'Parcialmente concluído';

  @override
  String photoshootPhotosReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografias estão prontas.',
      one: '1 fotografia está pronta.',
    );
    return '$_temp0';
  }

  @override
  String get photoshootConnectionLostBody =>
      'Perdemos a ligação. Tente novamente.';

  @override
  String get photoshootCouldNotCancelTitle => 'Não foi possível cancelar';

  @override
  String get photoshootRetryFailedTitle => 'Tentativa falhou';

  @override
  String photoshootPhotoReplacedBody(int number) {
    return 'A fotografia $number está pronta.';
  }

  @override
  String get photoshootReplacedTitle => 'Substituída';

  @override
  String get photoshootSavedToGalleryBody => 'Guardada na sua galeria.';

  @override
  String get photoshootSavedTitle => 'Guardada';

  @override
  String get photoshootNotSavedTitle => 'Não guardada';

  @override
  String photoshootAllSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todas as $count fotografias estão na sua galeria.',
      one: '1 fotografia está na sua galeria.',
    );
    return '$_temp0';
  }

  @override
  String photoshootSomeSavedBody(int saved, int total) {
    return '$saved de $total guardadas.';
  }

  @override
  String get photoshootSomePhotosNotSavedTitle =>
      'Algumas fotografias não guardadas';

  @override
  String get tryonConsentFeatureLabel => 'Prova Virtual';

  @override
  String get tryonAvatarUpdatedBody => 'A sua fotografia foi atualizada.';

  @override
  String get tryonSavedTitle => 'Guardada';

  @override
  String get tryonUploadFailedTitle => 'Carga falhou';

  @override
  String get tryonChooseGarmentFirstBody =>
      'Escolha primeiro uma fotografia da peça.';

  @override
  String get tryonNoGarmentTitle => 'Sem peça';

  @override
  String get tryonWaitForUploadBody =>
      'Aguarde o fim da carga da sua fotografia.';

  @override
  String get tryonStillUploadingTitle => 'A carregar';

  @override
  String get tryonAddYourPhotoFirstBody =>
      'Adicione primeiro uma fotografia sua.';

  @override
  String get tryonReadyBody => 'A sua prova está pronta.';

  @override
  String get tryonFailedTitle => 'Prova falhou';

  @override
  String get tryonSavedToGalleryBody => 'Guardada na sua galeria.';

  @override
  String get tryonNotSavedTitle => 'Não guardada';

  @override
  String get calendarEventAddedBody => 'Evento adicionado';

  @override
  String get calendarEventPlannedTitle => 'Planeado';

  @override
  String get calendarEventSavedBody => 'Evento guardado';

  @override
  String get calendarSavedTitle => 'Guardado';

  @override
  String get calendarEventNotSavedTitle => 'Evento não guardado';

  @override
  String get calendarEventRemovedBody => 'Evento removido';

  @override
  String get calendarEventDeletedTitle => 'Eliminado';

  @override
  String get calendarEventNotDeletedTitle => 'Evento não eliminado';

  @override
  String get calendarOutfitNotLinkedTitle => 'Look não associado';

  @override
  String get calendarLinkedTitle => 'Associado';

  @override
  String get calendarOutfitNotRemovedTitle => 'Look não removido';

  @override
  String get calendarOutfitRemovedBody => 'Look removido';

  @override
  String get calendarDisconnectedBody => 'Calendário desligado';

  @override
  String get calendarDisconnectedTitle => 'Desligado';

  @override
  String get calendarNotDisconnectedTitle => 'Calendário não desligado';

  @override
  String get calendarTodayLabel => 'hoje';

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
    return '$title, $time, look associado';
  }

  @override
  String calendarDeleteEventBody(String title) {
    return '«$title» será removido.';
  }

  @override
  String get calendarThisAppLabel => 'Esta app';

  @override
  String calendarSyncUnavailableBody(String provider) {
    return 'A sincronização com $provider ainda não está disponível. Podes continuar a adicionar eventos aqui.';
  }

  @override
  String get calendarWeekdaySunShort => 'dom';

  @override
  String get calendarWeekdayMonShort => 'seg';

  @override
  String get calendarWeekdayTueShort => 'ter';

  @override
  String get calendarWeekdayWedShort => 'qua';

  @override
  String get calendarWeekdayThuShort => 'qui';

  @override
  String get calendarWeekdayFriShort => 'sex';

  @override
  String get calendarWeekdaySatShort => 'sáb';

  @override
  String get calendarWeekdayMonday => 'Segunda-feira';

  @override
  String get calendarWeekdayTuesday => 'Terça-feira';

  @override
  String get calendarWeekdayWednesday => 'Quarta-feira';

  @override
  String get calendarWeekdayThursday => 'Quinta-feira';

  @override
  String get calendarWeekdayFriday => 'Sexta-feira';

  @override
  String get calendarWeekdaySaturday => 'Sábado';

  @override
  String get calendarWeekdaySunday => 'Domingo';

  @override
  String get outfitSavedToFavouritesBody => 'Guardado nos favoritos';

  @override
  String get outfitRemovedFromFavouritesBody => 'Removido dos favoritos';

  @override
  String get outfitNotSavedTitle => 'Não guardado';

  @override
  String get outfitLoggedAsWornBody => 'Registado como usado hoje.';

  @override
  String get outfitNicePickTitle => 'Boa escolha';

  @override
  String get outfitRemovedBody => 'Look removido.';

  @override
  String get outfitDeletedTitle => 'Eliminado';

  @override
  String get outfitNotDeletedTitle => 'Não eliminado';

  @override
  String get outfitDuplicatedBody => 'Uma cópia está nos teus looks.';

  @override
  String get outfitDuplicatedTitle => 'Duplicado';

  @override
  String get outfitNotDuplicatedTitle => 'Não duplicado';

  @override
  String get outfitNotSharedTitle => 'Não partilhado';

  @override
  String outfitCollectionReadyBody(String name) {
    return '«$name» está pronto.';
  }

  @override
  String get outfitCollectionNotCreatedTitle => 'Coleção não criada';

  @override
  String get outfitCollectionUpdatedBody => 'Coleção atualizada.';

  @override
  String get outfitCollectionNotUpdatedTitle => 'Coleção não atualizada';

  @override
  String get outfitCollectionDeletedBody => 'Coleção eliminada.';

  @override
  String get outfitCollectionNotDeletedTitle => 'Coleção não eliminada';

  @override
  String outfitAddedToCollection(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count looks adicionados.',
      one: '1 look adicionado.',
    );
    return '$_temp0';
  }

  @override
  String get outfitNotAddedToCollectionTitle => 'Looks não adicionados';

  @override
  String get outfitPreviewNotCreatedTitle => 'Pré-visualização não criada';

  @override
  String get outfitGiveNameBody => 'Dá um nome ao look.';

  @override
  String get outfitNameMissingTitle => 'Nome';

  @override
  String get outfitChooseAtLeastOnePieceBody => 'Escolhe pelo menos uma peça.';

  @override
  String outfitCreatedBody(String name) {
    return '$name está nos teus looks.';
  }

  @override
  String get outfitSavedTitle => 'Guardado';

  @override
  String get wardrobeAddedToFavouritesBody => 'Adicionado aos favoritos';

  @override
  String get wardrobeRemovedFromFavouritesBody => 'Removido dos favoritos';

  @override
  String get wardrobeNotSavedTitle => 'Não guardado';

  @override
  String get wardrobeLoggedAsWornBody => 'Registado como usado hoje.';

  @override
  String get wardrobeRemovedFromClosetBody => 'Removido do seu guarda-roupa.';

  @override
  String get wardrobeDeletedTitle => 'Eliminado';

  @override
  String get wardrobeNotDeletedTitle => 'Não eliminado';

  @override
  String wardrobePiecesRemovedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças removidas do seu guarda-roupa.',
      one: '1 peça removida do seu guarda-roupa.',
    );
    return '$_temp0';
  }

  @override
  String get wardrobeAiConsentLabel => 'Extração de Armário por IA';

  @override
  String get itemAddScanJobLabel => 'Digitalizar';

  @override
  String get itemAddFoundEarlierBody => 'Encontrado num digitalização anterior';

  @override
  String get itemAddLookingAtPhoto => 'A analisar a sua foto';

  @override
  String get itemAddExtractionFailedBody => 'Falha na extração';

  @override
  String get itemAddJobFailedBody => 'Falha na tarefa';

  @override
  String get itemAddConnectionLostBody =>
      'A ligação foi perdida. Tente novamente.';

  @override
  String get itemAddConnectionLostProcessingBody =>
      'Ligação perdida durante o processamento.';

  @override
  String itemAddGeneratingPiece(int number) {
    return 'Peça $number';
  }

  @override
  String get itemAddGeneratingPieceFallback => 'Peça';

  @override
  String get itemAddNotCancelledTitle => 'Não cancelado';

  @override
  String itemAddPiecesSavedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças no seu guarda-roupa.',
      one: '1 peça no seu guarda-roupa.',
    );
    return '$_temp0';
  }

  @override
  String itemAddSomeSavedBody(int saved, int total) {
    return '$saved de $total peças guardadas. Toque em guardar para tentar as restantes.';
  }

  @override
  String get itemAddSomePiecesNotSavedTitle => 'Algumas peças não guardadas';

  @override
  String get batchChooseAtLeastOnePhotoBody => 'Escolha pelo menos uma foto.';

  @override
  String get batchPhotoUnreadableBody => 'Esta foto não pôde ser lida.';

  @override
  String get batchNoPhotosReadableBody =>
      'Nenhuma destas fotos pôde ser lida. Tente outras fotos.';

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
      'Perdemos a ligação durante o processamento. Tente novamente.';

  @override
  String get batchNotCancelledTitle => 'Não cancelado';

  @override
  String get batchPostLinkUnsupportedBody =>
      'Links de publicações não são suportados. Introduza um link de perfil.';

  @override
  String get batchLinkSpacesBody => 'Os links não podem conter espaços.';

  @override
  String get batchEnterProfileLinkBody =>
      'Introduza um link de perfil do Instagram ou Facebook.';

  @override
  String get batchEnterProfileLinkShortBody => 'Introduza um link de perfil.';

  @override
  String get batchSignInPageNotOpenBody =>
      'A página de iniciação de sessão não abriu. Tente novamente.';

  @override
  String get batchSignInBrowserBody =>
      'Inicie sessão no navegador e volte ao FitCheck.';

  @override
  String get batchConnectAccountTitle => 'Ligar conta';

  @override
  String get batchEnterAuthenticatorCodeBody =>
      'Introduza o código da aplicação autenticadora.';

  @override
  String get batchInstagramSecurityCheckBody =>
      'O Instagram requer uma verificação de segurança. Inicie sessão no navegador.';

  @override
  String get batchEnterCredentialsAgainBody =>
      'Insira o utilizador e a palavra-passe novamente.';

  @override
  String get batchSignInFailedBody =>
      'Falha ao iniciar sessão. Verifique os dados de acesso.';

  @override
  String get batchSignInToKeepImportingBody =>
      'Inicie sessão para continuar a importar.';

  @override
  String get batchAccountNotConnectedBody => 'A conta não foi ligada.';

  @override
  String get batchAccountConnectedTitle => 'Conta ligada';

  @override
  String get batchNotConnectedTitle => 'Sem ligação';

  @override
  String get batchImportConnectionLostBody =>
      'Perdemos a ligação à importação. Atualize para verificar.';

  @override
  String batchPickUpToBody(int max) {
    return 'Escolha até $max fotografias. Encontramos as peças.';
  }

  @override
  String batchPhotoCounter(int count, int total) {
    return '$count de $total fotografias';
  }

  @override
  String batchPreparingPhotoBody(int done, int count) {
    return 'A preparar a fotografia $done de $count';
  }

  @override
  String batchFindPiecesInPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encontrar peças em $count fotografias',
      one: 'Encontrar peças em 1 fotografia',
    );
    return '$_temp0';
  }

  @override
  String batchTwoStepSignInBody(String platform) {
    return 'A conta do $platform usa início de sessão em duas etapas. Introduza o código de 6 dígitos da aplicação autenticadora.';
  }

  @override
  String batchPrivateProfileBody(String platform) {
    return 'Este perfil do $platform é privado ou requer sessão para mostrar as fotografias.';
  }

  @override
  String batchConnectWithPlatform(String platform) {
    return 'Ligar ao $platform';
  }

  @override
  String batchPhotosFoundSoFar(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografias encontradas até agora',
      one: '1 fotografia encontrada até agora',
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
    return '$processed de $total processados · $added adicionados · $waiting em espera · $skipped ignorados';
  }

  @override
  String batchScanningPhoto(int number) {
    return 'A analisar a fotografia $number';
  }

  @override
  String batchPhotoIsNext(int number) {
    return 'A fotografia $number é a seguir';
  }

  @override
  String batchPhotoLabel(int number) {
    return 'Fotografia $number';
  }

  @override
  String batchPiecesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças encontradas',
      one: '1 peça encontrada',
    );
    return '$_temp0';
  }

  @override
  String batchPhotosAddedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografias foram adicionadas ao seu guarda-roupa.',
      one: '1 fotografia foi adicionada ao seu guarda-roupa.',
    );
    return '$_temp0';
  }

  @override
  String batchMoreStudioPhotosBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Mais $count fotografias de estúdio a chegar. Pode guardar o que está pronto ou sair — avisamos.',
      one:
          'Mais 1 fotografia de estúdio a chegar. Pode guardar o que está pronto ou sair — avisamos.',
    );
    return '$_temp0';
  }

  @override
  String batchNotSavedYetBody(String names) {
    return 'Ainda não guardado: $names.';
  }

  @override
  String batchPiecesFromPhotos(int pieces, int photos) {
    String _temp0 = intl.Intl.pluralLogic(
      pieces,
      locale: localeName,
      other: '$pieces peças',
      one: '1 peça',
    );
    String _temp1 = intl.Intl.pluralLogic(
      photos,
      locale: localeName,
      other: '$photos fotografias',
      one: '1 fotografia',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String batchSelectedChosen(int chosen) {
    return '$chosen selecionadas. Toque numa peça para a ignorar.';
  }

  @override
  String batchSavingPiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'A guardar $count peças',
      one: 'A guardar 1 peça',
    );
    return '$_temp0';
  }

  @override
  String batchSavePiecesLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count peças',
      one: 'Guardar 1 peça',
    );
    return '$_temp0';
  }

  @override
  String get bodyProfileSavedBody => 'O teu perfil corporal está guardado.';

  @override
  String get bodyProfileSavedTitle => 'Guardado';

  @override
  String get bodyProfileNotSavedTitle => 'Não guardado';

  @override
  String get bodyProfileSetDefaultBody => 'Definir como perfil predefinido.';

  @override
  String get bodyProfileDeletedBody => 'Perfil corporal eliminado.';

  @override
  String get bodyProfileDeletedTitle => 'Eliminado';

  @override
  String get bodyProfileNotDeletedTitle => 'Não eliminado';

  @override
  String get feedbackNotSentTitle => 'Não enviado';

  @override
  String get feedbackSentBody =>
      'Obrigado. Lemmos cada mensagem e respondemos se precisar mais.';

  @override
  String get feedbackSentTitle => 'Feedback enviado';

  @override
  String get recommendUnnamedPiece => 'Peça sem nome';

  @override
  String get recommendEnterCityBody =>
      'Indica a tua cidade para teres sugestões de clima.';

  @override
  String get recommendWhichCityTitle => 'Que cidade?';

  @override
  String get aiConsentSheetTitle => 'Partilha de fotos com um serviço de IA';

  @override
  String get aiConsentSheetBody =>
      'Para criar as tuas imagens de provador e sessão de fotos, o FitCheck AI envia as fotos que fornece (incluindo imagens da cara e do corpo) a um fornecedor de IA de confiança (como OpenAI ou Google Gemini) para processamento. Geram as tuas imagens e não as usam para treinar os modelos, nos nossos termos. As fotos são transmitidas com segurança e nunca partilhadas para publicidade.';

  @override
  String get aiConsentSheetPermission =>
      'Ao continuar, dás permissão explícita para partilhar as tuas fotos com estes fornecedores de IA para geração de imagens.';

  @override
  String get skeletonsLoadMoreFailed => 'Não foi possível carregar mais.';

  @override
  String get jobsPiecesReadyTitle => 'As tuas peças estão prontas';

  @override
  String get jobsScanStoppedTitle => 'A varrragem parou';

  @override
  String get jobsNothingSavedBody => 'Nada foi guardado. Tenta novamente.';

  @override
  String get jobsPhotoUploadFailedBody => 'O carregamento da foto falhou.';

  @override
  String get authGoogleSignInStartFailed =>
      'Não foi possível iniciar o início de sessão do Google. Tenta novamente.';

  @override
  String get referralAppliedTitle => 'Indicação aplicada!';

  @override
  String get billingStoreUnavailableBody =>
      'As compras na loja não estão disponíveis neste dispositivo.';

  @override
  String get billingPurchaseProcessingBody =>
      'Esta compra ainda está a ser processada. Reabre a app dentro de um minuto para veres o teu plano.';

  @override
  String get profileAvatarUploadNoUrl =>
      'O carregamento do avatar não devolveu um URL de imagem.';

  @override
  String get rewardsDayStreakLabel => 'dias seguidos';

  @override
  String rewardsBestStreak(int days) {
    return 'Melhores $days dias';
  }

  @override
  String permissionAccessNeededTitle(String permission) {
    return 'Necessária permissão de $permission';
  }

  @override
  String permissionAccessDeniedBody(String permission) {
    return 'O acesso a $permission está atualmente negado. Abre Ajustes para o permitir e volta a tentar.';
  }

  @override
  String photoshootStepOfFour(int step) {
    return 'Passo $step de 4';
  }

  @override
  String onboardingStepOf(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String feedbackRemoveImage(int index) {
    return 'Remover imagem $index';
  }

  @override
  String feedbackRemoveImageIndex(int index) {
    return 'Remover imagem $index';
  }

  @override
  String rewardsPointsValue(int points) {
    return '$points pts';
  }

  @override
  String legalSupportEmailBody(String email) {
    return 'Email para $email. Analisamos as denúncias em 24 horas.';
  }

  @override
  String outfitRemovePieceTooltip(String piece) {
    return 'Remover $piece';
  }

  @override
  String outfitDeleteNamedTitle(String name) {
    return 'Eliminar \"$name\"?';
  }

  @override
  String outfitAddToNamed(String name) {
    return 'Adicionar a \"$name\"';
  }

  @override
  String outfitNamedRemoved(String name) {
    return '\"$name\" foi removida. As peças continuam no teu guarda-roupa.';
  }

  @override
  String outfitShowAllCount(int count) {
    return 'Mostrar os $count';
  }

  @override
  String photoshootImagesLeftToday(int count) {
    return '$count restantes hoje';
  }

  @override
  String photoshootPhotoNumberFailed(int index) {
    return 'Falha na foto $index';
  }

  @override
  String photoshootSelectedOfMax(int selected, int max) {
    return '$selected de $max fotos';
  }

  @override
  String bodyProfileBuildSkin(String shape, String tone) {
    return 'Físico $shape · Pele $tone';
  }

  @override
  String bodyProfileDeleteTitle(String name) {
    return 'Eliminar $name?';
  }

  @override
  String bodyProfileOptionsFor(String name) {
    return 'Opções para $name';
  }

  @override
  String profileMostWorn(String name, int count) {
    return 'Mais usado: $name, $count vezes';
  }

  @override
  String profileFieldUnset(String label) {
    return '$label: não definido';
  }

  @override
  String recommendMatchPercent(int percent) {
    return '$percent% compatível';
  }

  @override
  String recommendPickedCount(int picked, int max) {
    return '$picked de $max escolhidos';
  }

  @override
  String recommendRemoveItem(String item) {
    return 'Remover $item';
  }

  @override
  String recommendPriorityLabel(String urgency) {
    return 'Prioridade $urgency';
  }

  @override
  String billingBilledThroughStore(String store) {
    return 'Este plano é faturado através da $store. Altera ou cancela-o nas definições da tua conta na $store.';
  }

  @override
  String billingManageInStore(String store) {
    return 'Gerir na $store';
  }

  @override
  String usageProgressSemantics(String label, int current, int max) {
    return '$label: $current de $max usados';
  }

  @override
  String photoshootAboutSecondsLeft(int seconds) {
    return 'Faltam cerca de ${seconds}s';
  }

  @override
  String photoshootStudioPhotosReadyCount(int done, int total) {
    return '$done de $total fotos de estúdio prontas';
  }

  @override
  String photoshootStudioPhotosReadyTap(int ready, int total) {
    return '$ready de $total fotos de estúdio prontas. Toca numa peça para a saltar.';
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
  String get profileFieldNotSet => 'Não';
}
