// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Bicho a Bicho';

  @override
  String get accountNotConfigured =>
      'Contas ainda não foram configuradas nesta plataforma. As brincadeiras continuam disponíveis.';

  @override
  String get accountUnavailable =>
      'O serviço de contas está indisponível. Você pode continuar brincando sem conta.';

  @override
  String get accountEmailInUse =>
      'Este e-mail já tem uma conta. Use a opção Entrar.';

  @override
  String get accountInvalidEmail => 'Confira o endereço de e-mail.';

  @override
  String get accountWeakPassword =>
      'Escolha uma senha mais forte, com pelo menos 8 caracteres.';

  @override
  String get accountConnection => 'Confira sua conexão e tente novamente.';

  @override
  String get accountRateLimited =>
      'Aguarde um pouco antes de tentar novamente.';

  @override
  String get accountInvalidCredentials =>
      'Não foi possível acessar a conta. Confira os dados e tente novamente.';

  @override
  String get accountSignOutFailed =>
      'Não foi possível sair da conta. Tente novamente.';

  @override
  String get accountTitle => 'Conta do responsável';

  @override
  String accountGreeting(String name) {
    return 'Olá, $name!';
  }

  @override
  String get accountConnected =>
      'Sua conta está conectada. O histórico de brincadeiras fica somente neste dispositivo.';

  @override
  String get backToParents => 'Voltar aos responsáveis';

  @override
  String get signOut => 'Sair da conta';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get accountWelcome => 'Bem-vindo de volta';

  @override
  String get accountOptional =>
      'A conta é opcional. Todas as brincadeiras funcionam sem cadastro.';

  @override
  String get guardianName => 'Nome do responsável';

  @override
  String get enterGuardianName => 'Informe seu nome.';

  @override
  String get email => 'E-mail';

  @override
  String get enterValidEmail => 'Informe um e-mail válido.';

  @override
  String get password => 'Senha';

  @override
  String get enterPassword => 'Informe sua senha.';

  @override
  String get minimumPasswordLength => 'Use pelo menos 8 caracteres.';

  @override
  String get signIn => 'Entrar';

  @override
  String get alreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get wantCreateAccount => 'Quero criar uma conta';

  @override
  String get explorerEnableSound =>
      'Ative o som no botão do alto da tela para ouvir.';

  @override
  String get explorerAudioUnavailable =>
      'Não foi possível tocar o som. Continue explorando as imagens.';

  @override
  String get explorerTitle => 'Conheça a nossa turma';

  @override
  String get explorerDescription =>
      'Observe os bichinhos. Se quiser, toque para ouvir o som de cada um.';

  @override
  String get hearAnimal => 'Ouvir o bichinho';

  @override
  String roundProgress(int current, int total) {
    return 'Descoberta $current de $total';
  }

  @override
  String drawingPrompt(String animalName) {
    return 'Vamos desenhar $animalName?';
  }

  @override
  String get drawingInstruction =>
      'Observe o modelo. Desenhe o contorno com o dedo e toque em “Conferir desenho”.';

  @override
  String drawingModelLabel(String animalName) {
    return 'Modelo do contorno de $animalName';
  }

  @override
  String get drawingReassurance =>
      'Um traço parecido já vale. Olhos e detalhes não são obrigatórios.';

  @override
  String get discoveryCorrect => 'Você descobriu!';

  @override
  String get drawingCorrect => 'Seu desenho ficou parecido com o modelo!';

  @override
  String drawingCanvasLabel(String animalName) {
    return 'Área de desenho de $animalName. Desenhe deslizando um dedo. Pode pedir ajuda ou pular.';
  }

  @override
  String get undo => 'Desfazer';

  @override
  String get clear => 'Limpar';

  @override
  String get hideOutline => 'Ocultar contorno';

  @override
  String get requestHint => 'Quero uma dica';

  @override
  String get drawingFull =>
      'O quadro está cheio de traços. Você pode desfazer ou limpar.';

  @override
  String get checkDrawing => 'Conferir desenho';

  @override
  String get drawingRetry =>
      'Vamos aproximar o contorno do modelo? Acrescente ou ajuste os traços. A dica pode ajudar.';

  @override
  String get finishGame => 'Concluir brincadeira';

  @override
  String get nextRound => 'Próxima descoberta';

  @override
  String get skipRound => 'Pular por enquanto';

  @override
  String get celebrationUnavailable =>
      'Você acertou! A música não pôde tocar desta vez.';

  @override
  String get speechRetry => 'Você pode falar de novo ou tocar na resposta.';

  @override
  String get soundDisabled =>
      'O som está desligado. Você pode ativá-lo no botão de som.';

  @override
  String get soundUnavailable =>
      'O som não pôde tocar. Você pode continuar pela imagem.';

  @override
  String get speechListening => 'Estou ouvindo. Diga o nome do bichinho.';

  @override
  String get speechUnavailable =>
      'Não consegui ouvir agora. Você pode responder tocando na imagem.';

  @override
  String get speechNoMatch =>
      'Você pode tentar falar de novo ou tocar na resposta.';

  @override
  String get speechFinished => 'Pode falar de novo ou escolher uma imagem.';

  @override
  String get audioUnavailable => 'O recurso de áudio está indisponível.';

  @override
  String get disableSound => 'Desligar sons';

  @override
  String get enableSound => 'Ativar sons';

  @override
  String get pauseGame => 'Fazer uma pausa';

  @override
  String get pauseTitle => 'Vamos fazer uma pausa.';

  @override
  String get pauseDescription =>
      'A brincadeira espera por você.\nVolte quando quiser.';

  @override
  String get resumeGame => 'Continuar brincando';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get gameFinishedTitle => 'Que bom descobrir com você!';

  @override
  String get gameFinishedDescription =>
      'Nossa brincadeira chegou ao fim.\nVocê pode descansar ou explorar de novo.';

  @override
  String get chooseAnotherGame => 'Escolher outra brincadeira';

  @override
  String get gameProgress => 'Progresso da brincadeira';

  @override
  String get clueHeading => 'A pista é:';

  @override
  String nameWithoutInitial(String nameEnding) {
    return 'Nome sem a primeira letra: $nameEnding';
  }

  @override
  String get stopListening => 'Parar de ouvir';

  @override
  String get requestSpeech => 'Quero falar';

  @override
  String get chooseImage => 'Ou escolha uma imagem:';

  @override
  String countingCorrect(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bichinhos',
      one: '1 bichinho',
      zero: '0 bichinhos',
    );
    return 'Isso! Temos $_temp0.';
  }

  @override
  String animalCorrect(String animalName) {
    return 'É $animalName!';
  }

  @override
  String get retryChoice =>
      'Vamos observar mais um pouquinho? Tente outra opção.';

  @override
  String letterHint(String animalName, String initial) {
    return '$animalName começa com $initial.';
  }

  @override
  String countingHint(String numbers) {
    return 'Conte tocando em cada bichinho: $numbers.';
  }

  @override
  String clueHint(String animalName) {
    return 'A pista fala do $animalName. Compare as imagens.';
  }

  @override
  String matchingHint(String animalName, String clue) {
    return 'Procure o $animalName. $clue';
  }

  @override
  String animalAlreadyCounted(String animalName, int number) {
    return '$animalName $number, já contado';
  }

  @override
  String animalTapToCount(String animalName, int number) {
    return '$animalName $number, tocar para contar';
  }

  @override
  String get countingInstruction =>
      'Você pode tocar em cada bichinho para contar.';

  @override
  String countingProgress(int count) {
    return 'Já contamos $count.';
  }

  @override
  String choiceCorrectLabel(String choice) {
    return '$choice, resposta descoberta';
  }

  @override
  String choiceRetryLabel(String choice) {
    return '$choice, tente outra opção';
  }

  @override
  String get memoryPreview => 'Observe os bichinhos. Pode olhar sem pressa!';

  @override
  String get memoryHiding => 'Vamos esconder os bichinhos…';

  @override
  String get memoryShuffling => 'Embaralhando as cartas…';

  @override
  String get memoryMismatch => 'São diferentes. Vamos tentar outro par?';

  @override
  String get memoryComplete => 'Você encontrou todos os pares!';

  @override
  String get memoryInstruction =>
      'Vire duas cartas e encontre os bichinhos iguais.';

  @override
  String get memoryProgress => 'Pares encontrados';

  @override
  String get memoryPrompt => 'Encontre os pares de bichinhos iguais.';

  @override
  String memoryScore(int found, int total, int attempts) {
    String _temp0 = intl.Intl.pluralLogic(
      attempts,
      locale: localeName,
      other: '$attempts tentativas',
      one: '1 tentativa',
      zero: '0 tentativas',
    );
    return '$found de $total pares • $_temp0';
  }

  @override
  String get memoryStart => 'Esconder e embaralhar';

  @override
  String memoryMatchedCard(int position, String animalName) {
    return 'Carta $position: $animalName, par encontrado';
  }

  @override
  String memoryVisibleCard(int position, String animalName) {
    return 'Carta $position: $animalName';
  }

  @override
  String memoryHiddenCard(int position) {
    return 'Carta $position, escondida';
  }

  @override
  String celebratingAnimal(String animalName) {
    return '$animalName comemorando seu acerto';
  }

  @override
  String get storySharedReading => 'Faz de conta • leia junto';

  @override
  String get storyReadAgain => 'Pode olhar a história de novo quando quiser.';

  @override
  String storySceneLabel(int number, String sentence) {
    return 'Cena $number. $sentence';
  }

  @override
  String storySceneNumber(int number) {
    return 'Cena $number';
  }

  @override
  String get appWordmark => 'bicho a bicho';

  @override
  String get appTagline => 'Cada descoberta, no seu tempo.';

  @override
  String get playTab => 'Brincar';

  @override
  String get animalsTab => 'Bichinhos';

  @override
  String get parentsNavigation => 'Para responsáveis';

  @override
  String get parentsTab => 'Responsáveis';

  @override
  String get homeTitle => 'O que vamos descobrir hoje?';

  @override
  String get homeInstruction =>
      'Escolha uma brincadeira. Vamos juntos, sem pressa.';

  @override
  String get switchProfile => 'Trocar';

  @override
  String get homeReassurance =>
      'Aqui, cada tentativa é uma descoberta. Você pode repetir, pedir uma dica ou fazer uma pausa.';

  @override
  String get homeAnimalsTitle => 'Uma turma para conhecer';

  @override
  String get seeAnimals => 'Ver bichinhos →';

  @override
  String get homeFooter => 'Feito para explorar. Com espaço para ser você.';

  @override
  String get homeWelcome => 'QUE BOM TER VOCÊ AQUI';

  @override
  String get oneDiscoveryAtATime => 'Uma descoberta\nde cada vez.';

  @override
  String get homeIntroLabel => 'UM MUNDO DE PEQUENAS DESCOBERTAS';

  @override
  String get homeIntroTitle => 'Aprender é melhor\ncom novos amigos.';

  @override
  String get homeIntroDescription =>
      'Bichinhos, brincadeiras e um mundo para explorar.\nTudo no seu ritmo.';

  @override
  String get meetAnimals => 'Conhecer a turma';

  @override
  String playGameLabel(String title) {
    return 'Jogar $title';
  }

  @override
  String get playTogether => 'Vamos brincar';

  @override
  String get startNow => 'Começar agora';

  @override
  String get openingWelcome => 'A turma chegou para brincar!';

  @override
  String get reportTitle => 'Acompanhamento das brincadeiras';

  @override
  String get reportDescription =>
      'Disponível sem login. Escolha abaixo de quem deseja consultar os registros. Consultar outro cartão não muda quem está brincando.';

  @override
  String get reportStorageFailure =>
      'Não foi possível ler ou salvar parte dos registros. Os dados desta sessão continuam disponíveis enquanto o app estiver aberto.';

  @override
  String get retrySave => 'Tentar salvar dados locais';

  @override
  String get reportLocalNotice =>
      'Acumulado desde o início do registro ou a última limpeza. A conta opcional não sincroniza estes dados.';

  @override
  String get reportProfileTitle => 'De quem é este relatório?';

  @override
  String profileIdentity(String name, String cardNumber) {
    return '$name • $cardNumber';
  }

  @override
  String reportActiveProfile(String name) {
    return 'Brincando agora: $name. Para trocar quem brinca, use o cartão na tela inicial.';
  }

  @override
  String get reportActivityFilter => 'Atividade do relatório';

  @override
  String get allActivities => 'Todas as atividades';

  @override
  String get reportChoicesFilter => 'Alternativas no momento da rodada';

  @override
  String get allConfigurations => 'Todas as configurações';

  @override
  String get twoAlternatives => '2 alternativas';

  @override
  String get threeAlternatives => '3 alternativas';

  @override
  String get drawingWithoutChoices => 'Desenho sem alternativas';

  @override
  String get reportEmpty =>
      'Ainda não há registros neste filtro. Abra uma brincadeira com este perfil para começar. O uso anterior à atualização não tinha registro de erros.';

  @override
  String get reportErrors => 'Tentativas incorretas';

  @override
  String get reportRoundsWithErrors => 'Rodadas com erro';

  @override
  String reportAnsweredWithErrors(int errors, int answered) {
    return '$errors de $answered respondidas';
  }

  @override
  String get reportFirstTry => 'Acertos na primeira tentativa';

  @override
  String get reportHints => 'Rodadas com dica';

  @override
  String get reportResolved => 'Rodadas resolvidas';

  @override
  String get reportSkipped => 'Rodadas puladas';

  @override
  String reportOpenedRounds(int started, int answered) {
    return 'Rodadas abertas: $started • Com resposta: $answered. Rodadas interrompidas também ficam registradas.';
  }

  @override
  String get reportAnimalRanking =>
      'Animais com maior proporção de rodadas com erro';

  @override
  String get reportRankingDescription =>
      'Ordem pela proporção de rodadas respondidas que tiveram erro, com o tamanho da amostra ao lado. O animal é o alvo da pergunta, inclusive em letras, contagem e histórias.';

  @override
  String get reportNoErrors =>
      'Nenhuma tentativa incorreta registrada neste filtro.';

  @override
  String reportAnimalErrorRate(int errors, int answered, int percentage) {
    return 'Rodadas respondidas com erro: $errors de $answered ($percentage%).';
  }

  @override
  String reportAnimalErrorsAndHints(int errors, int hints) {
    return 'Tentativas incorretas: $errors • Rodadas com dica: $hints';
  }

  @override
  String get reportByActivity => 'Por atividade';

  @override
  String get reportInterpretation =>
      'Como ler: cada resposta incorreta conta como uma tentativa; uma rodada com vários erros conta uma vez em “Rodadas com erro”. Dicas não são erros. Acerto na primeira tentativa pode ter tido dica. Falhas do microfone, pausas e saltos não são erros. Uma amostra pequena ou ajuda de um adulto pode mudar a interpretação. Esses dados descrevem o uso do app e não medem desenvolvimento ou dificuldade clínica.';

  @override
  String clearProfileHistory(String name) {
    return 'Apagar acompanhamento de $name';
  }

  @override
  String clearProfileHistoryTitle(String name) {
    return 'Apagar acompanhamento de $name?';
  }

  @override
  String get clearProfileHistoryDescription =>
      'Apaga erros, acertos, dicas e rodadas deste perfil em todas as atividades e configurações. Os outros perfis e os ajustes serão preservados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get clearHistory => 'Apagar acompanhamento';

  @override
  String get reportNoActivityRecords => 'Ainda sem registros.';

  @override
  String reportActivitySummary(
    int errors,
    int roundsWithErrors,
    int answered,
    int firstTry,
  ) {
    return 'Tentativas incorretas: $errors • Rodadas respondidas com erro: $roundsWithErrors de $answered • Acertos na primeira tentativa: $firstTry';
  }

  @override
  String get profileSaveFailed =>
      'Não foi possível salvar neste aparelho. Tente novamente.';

  @override
  String get newProfile => 'Novo cartão';

  @override
  String get profileTitle => 'Seu cartão';

  @override
  String profileAnimalTitle(String animalName) {
    return 'Seu cartão do $animalName';
  }

  @override
  String get chooseAnimal => 'Escolha seu bichinho';

  @override
  String get profileNameQuestion => 'Como vamos chamar você?';

  @override
  String get profileNameHelp =>
      'Um responsável pode ajudar a escrever. O nome aparecerá neste cartão e no acompanhamento das brincadeiras.';

  @override
  String get profileNameLabel => 'Nome ou apelido (opcional)';

  @override
  String get profileNameExample => 'Ex.: Ana';

  @override
  String get profileNameHint => 'Pode ser só o primeiro nome.';

  @override
  String get profileLocalNotice =>
      'Salvo somente neste aparelho. Não é necessário criar uma conta.';

  @override
  String get saving => 'Salvando...';

  @override
  String get saveAndPlay => 'Salvar e brincar';

  @override
  String get saveProfile => 'Salvar cartão';

  @override
  String get continueWithoutName => 'Continuar sem nome';

  @override
  String get useAnimalOnly => 'Usar só o bichinho';

  @override
  String profileSearchIndex(String name, String cardNumber, String animalName) {
    return '$name $cardNumber $animalName';
  }

  @override
  String get profileSelectionTitle => 'Quem vai brincar?';

  @override
  String get selectProfile => 'Escolher cartão';

  @override
  String get profileSelectionPrompt => 'Toque no seu cartão.';

  @override
  String get selectProfilePrompt => 'Escolha um cartão.';

  @override
  String get searchProfile => 'Buscar cartão';

  @override
  String get profileSearchHint => 'Nome, animal ou número';

  @override
  String get profileCreationDescription =>
      'Qualquer pessoa pode criar um cartão, com nome opcional e o bichinho que preferir.';

  @override
  String get profileSearchEmpty =>
      'Nenhum cartão encontrado. Tente outro nome, animal ou número.';

  @override
  String profileAccessibilityLabel(
    String name,
    String cardNumber,
    String animalName,
  ) {
    return '$name, $cardNumber, bichinho $animalName';
  }

  @override
  String get profileHistoryReminder =>
      'Use sempre o seu cartão para guardar suas descobertas.';

  @override
  String get profilesOnDevice => 'Cartões neste aparelho';

  @override
  String profileCountDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartões',
      one: '1 cartão',
      zero: '0 cartões',
    );
    return '$_temp0. Qualquer pessoa pode criar outro na tela de entrada, escolher um bichinho e informar um nome se quiser.';
  }

  @override
  String get createProfile => 'Criar cartão';

  @override
  String get editProfile => 'Editar cartão';

  @override
  String get profileSettingsDescription =>
      'Nome e bichinho podem se repetir. Cada cartão tem seu próprio número e histórico. Editar um cartão não muda quem está brincando.';

  @override
  String get analyticsTitle => 'Dados de uso opcionais';

  @override
  String get analyticsDescription =>
      'Com autorização do responsável, o Google Analytics (GA4) pode receber telas visitadas, interações dos jogos e ajustes do app, junto com um identificador da instalação e informações do dispositivo. Esses dados ajudam a melhorar as brincadeiras.';

  @override
  String get analyticsPrivacy =>
      'Não enviamos nome, e-mail, senha, idade, diagnóstico, gravações ou transcrições. Não vinculamos a análise à conta do responsável. Publicidade personalizada e identificadores de publicidade estão desativados.';

  @override
  String get shareUsageData => 'Compartilhar dados de uso';

  @override
  String get analyticsConsentTitle => 'Autorizar dados de uso?';

  @override
  String get analyticsConsentDescription =>
      'Esta escolha deve ser feita pelo responsável. Ao autorizar, você permite o envio dos dados de uso descritos nesta tela ao Google Analytics. A autorização é opcional e os jogos continuam funcionando se você recusar.\n\nVocê pode desativar depois. A desativação interrompe a coleta e redefine os dados locais do SDK; não apaga dados já enviados ao Google.';

  @override
  String get declineConsent => 'Não autorizar';

  @override
  String get grantConsent => 'Sou responsável e autorizo';

  @override
  String get analyticsApplying => 'Aplicando sua escolha…';

  @override
  String get analyticsNotConfigured =>
      'A análise ainda não está configurada nesta plataforma.';

  @override
  String get analyticsFailed =>
      'Não foi possível aplicar ou salvar a escolha. O envio de eventos do app está suspenso. Tente novamente antes de fechar o aplicativo.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get analyticsEnabled =>
      'Coleta autorizada neste dispositivo. Você pode desativar a qualquer momento.';

  @override
  String get analyticsDisabled =>
      'Coleta desativada. Todas as brincadeiras continuam disponíveis.';

  @override
  String get parentsTitle => 'Cada criança tem seu ritmo.';

  @override
  String get parentsDescription =>
      'Ajuste a experiência junto com a criança. Observe o conforto, os interesses e as formas de comunicação que ela prefere.';

  @override
  String get soundSetting => 'Sons e comemorações';

  @override
  String get soundSettingDescription =>
      'Sons ao tocar e uma música curta ao acertar. Sem música de fundo.';

  @override
  String get reducedMotionSetting => 'Movimento reduzido';

  @override
  String get reducedMotionDescription =>
      'Reduz transições. A preferência do sistema também é respeitada.';

  @override
  String get choicesSetting => 'Opções por descoberta';

  @override
  String choiceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opções',
      one: '1 opção',
      zero: '0 opções',
    );
    return '$_temp0';
  }

  @override
  String get roundsSetting => 'Tamanho da brincadeira';

  @override
  String sessionRoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descobertas',
      one: '1 descoberta',
      zero: '0 descobertas',
    );
    return '$_temp0';
  }

  @override
  String get settingsNextGame =>
      'As mudanças valem para a próxima brincadeira.';

  @override
  String get settingsStorageFailure =>
      'Não foi possível salvar neste dispositivo. As mudanças atuais continuam disponíveis enquanto o app estiver aberto.';

  @override
  String get completedGamesTitle => 'Nosso caminho de descobertas';

  @override
  String get completedGamesDescription =>
      'Brincadeiras concluídas neste dispositivo. Este registro não mede desenvolvimento nem desempenho.';

  @override
  String get clearLocalHistory => 'Apagar histórico local';

  @override
  String get educationalPurpose => 'Brincar com intenção';

  @override
  String get educationalAlignment =>
      'Associação, exploração de sons, expressão e pequenas quantidades dialogam com os campos de experiência da Educação Infantil na BNCC. As letras são uma exploração lúdica, sem exigir alfabetização.';

  @override
  String get educationalReassurance =>
      'Não há cronômetro, perda de pontos ou exigência de fala. Ofereça ajuda sem pressionar. Respeite pausas e o desejo de parar.';

  @override
  String get sharedReadingGuidance =>
      'Para brincar de Detetive dos bichos, leia a pista e compare as imagens junto com a criança. Em Histórias da turma, leia as duas cenas e a pergunta; a história fica disponível para consultar. A criança pode tocar ou indicar uma imagem para você selecionar. Não é preciso saber ler.';

  @override
  String get educationalSources =>
      'Essas duas propostas foram adaptadas de atividades de adivinhação e contação com figuras reunidas pela Secretaria de Educação de Santa Catarina. As narrativas e ilustrações do app são próprias. Experimente também com livros e brinquedos fora da tela, respeitando os interesses da criança.';

  @override
  String get educationalDisclaimer =>
      'O app é um recurso educativo complementar. A adequação das atividades deve ser avaliada com a família e a equipe pedagógica. Não faz avaliação clínica.';

  @override
  String get privacyAndAccount => 'Privacidade e conta';

  @override
  String get privacyDescription =>
      'Os jogos não precisam de conta ou internet. O histórico fica neste dispositivo. O compartilhamento opcional de eventos de uso está descrito nos ajustes de dados acima. Não é necessário informar nome ou idade da criança. Os apelidos opcionais dos cartões ficam neste aparelho.\n\nO microfone só é solicitado no botão “Quero falar”. O serviço de reconhecimento do sistema pode enviar áudio ao provedor do dispositivo e precisar de internet. O app não grava nem armazena esse áudio. Prefira responder por toque se não desejar usar o microfone.';

  @override
  String get optionalAccount => 'Conta opcional do responsável';

  @override
  String get licenses => 'Licenças e créditos';

  @override
  String get resetHistoryTitle => 'Apagar o histórico?';

  @override
  String get resetHistoryDescription =>
      'As contagens de brincadeiras e o acompanhamento de todos os perfis deste dispositivo serão apagados. Os ajustes serão mantidos.';

  @override
  String get keepHistory => 'Manter histórico';

  @override
  String get delete => 'Apagar';

  @override
  String get animalSoundsLicense => 'Sons dos animais';

  @override
  String get gameMatchingTitle => 'Encontre o bichinho';

  @override
  String get gameMatchingSubtitle => 'Observe, descubra e associe';

  @override
  String get gameMatchingInstruction => 'Toque no bichinho igual ao da imagem.';

  @override
  String get gameMatchingSkill => 'Associação visual';

  @override
  String get gameLettersTitle => 'A letra do bicho';

  @override
  String get gameLettersSubtitle => 'Uma descoberta de cada vez';

  @override
  String get gameLettersInstruction => 'Toque na letra que completa o nome.';

  @override
  String get gameLettersSkill => 'Letras e nomes';

  @override
  String get gameCountingTitle => 'Vamos contar?';

  @override
  String get gameCountingSubtitle => 'Pequenos grupos, grandes descobertas';

  @override
  String get gameCountingInstruction => 'Conte os bichinhos. Toque no número.';

  @override
  String get gameCountingSkill => 'Quantidades de 1 a 4';

  @override
  String get gameSpeakingTitle => 'Olá, bichinho!';

  @override
  String get gameSpeakingSubtitle => 'Fale ou escolha: os dois valem';

  @override
  String get gameSpeakingInstruction =>
      'Diga o nome do bichinho ou toque na resposta.';

  @override
  String get gameSpeakingSkill => 'Expressão e reconhecimento';

  @override
  String get gameCluesTitle => 'Detetive dos bichos';

  @override
  String get gameCluesSubtitle => 'Uma pista para uma descoberta';

  @override
  String get gameCluesInstruction =>
      'Leia com alguém. Qual bichinho combina com a pista?';

  @override
  String get gameCluesSkill => 'Pistas e características';

  @override
  String get gameStoriesTitle => 'Histórias da turma';

  @override
  String get gameStoriesSubtitle => 'Pequenas histórias para ler juntos';

  @override
  String get gameStoriesInstruction =>
      'Leia com alguém. Depois, toque na resposta.';

  @override
  String get gameStoriesSkill => 'Escuta e compreensão';

  @override
  String get gameDrawingTitle => 'Desenhe o bichinho';

  @override
  String get gameDrawingSubtitle => 'Seu traço dá vida à turma';

  @override
  String get gameDrawingInstruction =>
      'Observe o modelo e desenhe o contorno com o dedo.';

  @override
  String get gameDrawingSkill => 'Desenho e formas';

  @override
  String get gameMemoryTitle => 'Memória dos bichos';

  @override
  String get gameMemorySubtitle => 'Vire as cartas e descubra os pares';

  @override
  String get gameMemoryInstruction => 'Encontre os pares de bichinhos iguais.';

  @override
  String get gameMemorySkill => 'Memória e atenção';

  @override
  String get guardian => 'Responsável';

  @override
  String profileDefaultName(String animalName) {
    return 'Meu $animalName';
  }

  @override
  String profileCardNumber(int number) {
    return 'Cartão $number';
  }

  @override
  String get homePlayPrompt => 'Vamos\nbrincar?';
}
