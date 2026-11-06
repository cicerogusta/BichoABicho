import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// App title.
  ///
  /// In pt, this message translates to:
  /// **'Bicho a Bicho'**
  String get appTitle;

  /// Account not configured.
  ///
  /// In pt, this message translates to:
  /// **'Contas ainda não foram configuradas nesta plataforma. As brincadeiras continuam disponíveis.'**
  String get accountNotConfigured;

  /// Account unavailable.
  ///
  /// In pt, this message translates to:
  /// **'O serviço de contas está indisponível. Você pode continuar brincando sem conta.'**
  String get accountUnavailable;

  /// Account email in use.
  ///
  /// In pt, this message translates to:
  /// **'Este e-mail já tem uma conta. Use a opção Entrar.'**
  String get accountEmailInUse;

  /// Account invalid email.
  ///
  /// In pt, this message translates to:
  /// **'Confira o endereço de e-mail.'**
  String get accountInvalidEmail;

  /// Account weak password.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma senha mais forte, com pelo menos 8 caracteres.'**
  String get accountWeakPassword;

  /// Account connection.
  ///
  /// In pt, this message translates to:
  /// **'Confira sua conexão e tente novamente.'**
  String get accountConnection;

  /// Account rate limited.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde um pouco antes de tentar novamente.'**
  String get accountRateLimited;

  /// Account invalid credentials.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível acessar a conta. Confira os dados e tente novamente.'**
  String get accountInvalidCredentials;

  /// Account sign out failed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível sair da conta. Tente novamente.'**
  String get accountSignOutFailed;

  /// Account title.
  ///
  /// In pt, this message translates to:
  /// **'Conta do responsável'**
  String get accountTitle;

  /// Account greeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {name}!'**
  String accountGreeting(String name);

  /// Account connected.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta está conectada. O histórico de brincadeiras fica somente neste dispositivo.'**
  String get accountConnected;

  /// Back to parents.
  ///
  /// In pt, this message translates to:
  /// **'Voltar aos responsáveis'**
  String get backToParents;

  /// Sign out.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get signOut;

  /// Create account.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// Account welcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta'**
  String get accountWelcome;

  /// Account optional.
  ///
  /// In pt, this message translates to:
  /// **'A conta é opcional. Todas as brincadeiras funcionam sem cadastro.'**
  String get accountOptional;

  /// Guardian name.
  ///
  /// In pt, this message translates to:
  /// **'Nome do responsável'**
  String get guardianName;

  /// Enter guardian name.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome.'**
  String get enterGuardianName;

  /// Email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// Enter valid email.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido.'**
  String get enterValidEmail;

  /// Password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// Enter password.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua senha.'**
  String get enterPassword;

  /// Minimum password length.
  ///
  /// In pt, this message translates to:
  /// **'Use pelo menos 8 caracteres.'**
  String get minimumPasswordLength;

  /// Sign in.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signIn;

  /// Already have account.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho uma conta'**
  String get alreadyHaveAccount;

  /// Want create account.
  ///
  /// In pt, this message translates to:
  /// **'Quero criar uma conta'**
  String get wantCreateAccount;

  /// Explorer enable sound.
  ///
  /// In pt, this message translates to:
  /// **'Ative o som no botão do alto da tela para ouvir.'**
  String get explorerEnableSound;

  /// Explorer audio unavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível tocar o som. Continue explorando as imagens.'**
  String get explorerAudioUnavailable;

  /// Explorer title.
  ///
  /// In pt, this message translates to:
  /// **'Conheça a nossa turma'**
  String get explorerTitle;

  /// Explorer description.
  ///
  /// In pt, this message translates to:
  /// **'Observe os bichinhos. Se quiser, toque para ouvir o som de cada um.'**
  String get explorerDescription;

  /// Hear animal.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir o bichinho'**
  String get hearAnimal;

  /// Round progress.
  ///
  /// In pt, this message translates to:
  /// **'Descoberta {current} de {total}'**
  String roundProgress(int current, int total);

  /// Drawing prompt.
  ///
  /// In pt, this message translates to:
  /// **'Vamos desenhar {animalName}?'**
  String drawingPrompt(String animalName);

  /// Drawing instruction.
  ///
  /// In pt, this message translates to:
  /// **'Observe o modelo. Desenhe o contorno com o dedo e toque em “Conferir desenho”.'**
  String get drawingInstruction;

  /// Drawing model label.
  ///
  /// In pt, this message translates to:
  /// **'Modelo do contorno de {animalName}'**
  String drawingModelLabel(String animalName);

  /// Drawing reassurance.
  ///
  /// In pt, this message translates to:
  /// **'Um traço parecido já vale. Olhos e detalhes não são obrigatórios.'**
  String get drawingReassurance;

  /// Discovery correct.
  ///
  /// In pt, this message translates to:
  /// **'Você descobriu!'**
  String get discoveryCorrect;

  /// Drawing correct.
  ///
  /// In pt, this message translates to:
  /// **'Seu desenho ficou parecido com o modelo!'**
  String get drawingCorrect;

  /// Drawing canvas label.
  ///
  /// In pt, this message translates to:
  /// **'Área de desenho de {animalName}. Desenhe deslizando um dedo. Pode pedir ajuda ou pular.'**
  String drawingCanvasLabel(String animalName);

  /// Undo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get undo;

  /// Clear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// Hide outline.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar contorno'**
  String get hideOutline;

  /// Request hint.
  ///
  /// In pt, this message translates to:
  /// **'Quero uma dica'**
  String get requestHint;

  /// Drawing full.
  ///
  /// In pt, this message translates to:
  /// **'O quadro está cheio de traços. Você pode desfazer ou limpar.'**
  String get drawingFull;

  /// Check drawing.
  ///
  /// In pt, this message translates to:
  /// **'Conferir desenho'**
  String get checkDrawing;

  /// Drawing retry.
  ///
  /// In pt, this message translates to:
  /// **'Vamos aproximar o contorno do modelo? Acrescente ou ajuste os traços. A dica pode ajudar.'**
  String get drawingRetry;

  /// Finish game.
  ///
  /// In pt, this message translates to:
  /// **'Concluir brincadeira'**
  String get finishGame;

  /// Next round.
  ///
  /// In pt, this message translates to:
  /// **'Próxima descoberta'**
  String get nextRound;

  /// Skip round.
  ///
  /// In pt, this message translates to:
  /// **'Pular por enquanto'**
  String get skipRound;

  /// Celebration unavailable.
  ///
  /// In pt, this message translates to:
  /// **'Você acertou! A música não pôde tocar desta vez.'**
  String get celebrationUnavailable;

  /// Speech retry.
  ///
  /// In pt, this message translates to:
  /// **'Você pode falar de novo ou tocar na resposta.'**
  String get speechRetry;

  /// Sound disabled.
  ///
  /// In pt, this message translates to:
  /// **'O som está desligado. Você pode ativá-lo no botão de som.'**
  String get soundDisabled;

  /// Sound unavailable.
  ///
  /// In pt, this message translates to:
  /// **'O som não pôde tocar. Você pode continuar pela imagem.'**
  String get soundUnavailable;

  /// Speech listening.
  ///
  /// In pt, this message translates to:
  /// **'Estou ouvindo. Diga o nome do bichinho.'**
  String get speechListening;

  /// Speech unavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui ouvir agora. Você pode responder tocando na imagem.'**
  String get speechUnavailable;

  /// Speech no match.
  ///
  /// In pt, this message translates to:
  /// **'Você pode tentar falar de novo ou tocar na resposta.'**
  String get speechNoMatch;

  /// Speech finished.
  ///
  /// In pt, this message translates to:
  /// **'Pode falar de novo ou escolher uma imagem.'**
  String get speechFinished;

  /// Audio unavailable.
  ///
  /// In pt, this message translates to:
  /// **'O recurso de áudio está indisponível.'**
  String get audioUnavailable;

  /// Disable sound.
  ///
  /// In pt, this message translates to:
  /// **'Desligar sons'**
  String get disableSound;

  /// Enable sound.
  ///
  /// In pt, this message translates to:
  /// **'Ativar sons'**
  String get enableSound;

  /// Pause game.
  ///
  /// In pt, this message translates to:
  /// **'Fazer uma pausa'**
  String get pauseGame;

  /// Pause title.
  ///
  /// In pt, this message translates to:
  /// **'Vamos fazer uma pausa.'**
  String get pauseTitle;

  /// Pause description.
  ///
  /// In pt, this message translates to:
  /// **'A brincadeira espera por você.\nVolte quando quiser.'**
  String get pauseDescription;

  /// Resume game.
  ///
  /// In pt, this message translates to:
  /// **'Continuar brincando'**
  String get resumeGame;

  /// Back to home.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get backToHome;

  /// Game finished title.
  ///
  /// In pt, this message translates to:
  /// **'Que bom descobrir com você!'**
  String get gameFinishedTitle;

  /// Game finished description.
  ///
  /// In pt, this message translates to:
  /// **'Nossa brincadeira chegou ao fim.\nVocê pode descansar ou explorar de novo.'**
  String get gameFinishedDescription;

  /// Choose another game.
  ///
  /// In pt, this message translates to:
  /// **'Escolher outra brincadeira'**
  String get chooseAnotherGame;

  /// Game progress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso da brincadeira'**
  String get gameProgress;

  /// Clue heading.
  ///
  /// In pt, this message translates to:
  /// **'A pista é:'**
  String get clueHeading;

  /// Name without initial.
  ///
  /// In pt, this message translates to:
  /// **'Nome sem a primeira letra: {nameEnding}'**
  String nameWithoutInitial(String nameEnding);

  /// Stop listening.
  ///
  /// In pt, this message translates to:
  /// **'Parar de ouvir'**
  String get stopListening;

  /// Request speech.
  ///
  /// In pt, this message translates to:
  /// **'Quero falar'**
  String get requestSpeech;

  /// Choose image.
  ///
  /// In pt, this message translates to:
  /// **'Ou escolha uma imagem:'**
  String get chooseImage;

  /// Counting correct.
  ///
  /// In pt, this message translates to:
  /// **'Isso! Temos {count, plural, =0{0 bichinhos} =1{1 bichinho} other{{count} bichinhos}}.'**
  String countingCorrect(int count);

  /// Animal correct.
  ///
  /// In pt, this message translates to:
  /// **'É {animalName}!'**
  String animalCorrect(String animalName);

  /// Retry choice.
  ///
  /// In pt, this message translates to:
  /// **'Vamos observar mais um pouquinho? Tente outra opção.'**
  String get retryChoice;

  /// Letter hint.
  ///
  /// In pt, this message translates to:
  /// **'{animalName} começa com {initial}.'**
  String letterHint(String animalName, String initial);

  /// Counting hint.
  ///
  /// In pt, this message translates to:
  /// **'Conte tocando em cada bichinho: {numbers}.'**
  String countingHint(String numbers);

  /// Clue hint.
  ///
  /// In pt, this message translates to:
  /// **'A pista fala do {animalName}. Compare as imagens.'**
  String clueHint(String animalName);

  /// Matching hint.
  ///
  /// In pt, this message translates to:
  /// **'Procure o {animalName}. {clue}'**
  String matchingHint(String animalName, String clue);

  /// Animal already counted.
  ///
  /// In pt, this message translates to:
  /// **'{animalName} {number}, já contado'**
  String animalAlreadyCounted(String animalName, int number);

  /// Animal tap to count.
  ///
  /// In pt, this message translates to:
  /// **'{animalName} {number}, tocar para contar'**
  String animalTapToCount(String animalName, int number);

  /// Counting instruction.
  ///
  /// In pt, this message translates to:
  /// **'Você pode tocar em cada bichinho para contar.'**
  String get countingInstruction;

  /// Counting progress.
  ///
  /// In pt, this message translates to:
  /// **'Já contamos {count}.'**
  String countingProgress(int count);

  /// Choice correct label.
  ///
  /// In pt, this message translates to:
  /// **'{choice}, resposta descoberta'**
  String choiceCorrectLabel(String choice);

  /// Choice retry label.
  ///
  /// In pt, this message translates to:
  /// **'{choice}, tente outra opção'**
  String choiceRetryLabel(String choice);

  /// Memory preview.
  ///
  /// In pt, this message translates to:
  /// **'Observe os bichinhos. Pode olhar sem pressa!'**
  String get memoryPreview;

  /// Memory hiding.
  ///
  /// In pt, this message translates to:
  /// **'Vamos esconder os bichinhos…'**
  String get memoryHiding;

  /// Memory shuffling.
  ///
  /// In pt, this message translates to:
  /// **'Embaralhando as cartas…'**
  String get memoryShuffling;

  /// Memory mismatch.
  ///
  /// In pt, this message translates to:
  /// **'São diferentes. Vamos tentar outro par?'**
  String get memoryMismatch;

  /// Memory complete.
  ///
  /// In pt, this message translates to:
  /// **'Você encontrou todos os pares!'**
  String get memoryComplete;

  /// Memory instruction.
  ///
  /// In pt, this message translates to:
  /// **'Vire duas cartas e encontre os bichinhos iguais.'**
  String get memoryInstruction;

  /// Memory progress.
  ///
  /// In pt, this message translates to:
  /// **'Pares encontrados'**
  String get memoryProgress;

  /// Memory prompt.
  ///
  /// In pt, this message translates to:
  /// **'Encontre os pares de bichinhos iguais.'**
  String get memoryPrompt;

  /// Memory score.
  ///
  /// In pt, this message translates to:
  /// **'{found} de {total} pares • {attempts, plural, =0{0 tentativas} =1{1 tentativa} other{{attempts} tentativas}}'**
  String memoryScore(int found, int total, int attempts);

  /// Memory start.
  ///
  /// In pt, this message translates to:
  /// **'Esconder e embaralhar'**
  String get memoryStart;

  /// Memory matched card.
  ///
  /// In pt, this message translates to:
  /// **'Carta {position}: {animalName}, par encontrado'**
  String memoryMatchedCard(int position, String animalName);

  /// Memory visible card.
  ///
  /// In pt, this message translates to:
  /// **'Carta {position}: {animalName}'**
  String memoryVisibleCard(int position, String animalName);

  /// Memory hidden card.
  ///
  /// In pt, this message translates to:
  /// **'Carta {position}, escondida'**
  String memoryHiddenCard(int position);

  /// Celebrating animal.
  ///
  /// In pt, this message translates to:
  /// **'{animalName} comemorando seu acerto'**
  String celebratingAnimal(String animalName);

  /// Story shared reading.
  ///
  /// In pt, this message translates to:
  /// **'Faz de conta • leia junto'**
  String get storySharedReading;

  /// Story read again.
  ///
  /// In pt, this message translates to:
  /// **'Pode olhar a história de novo quando quiser.'**
  String get storyReadAgain;

  /// Story scene label.
  ///
  /// In pt, this message translates to:
  /// **'Cena {number}. {sentence}'**
  String storySceneLabel(int number, String sentence);

  /// Story scene number.
  ///
  /// In pt, this message translates to:
  /// **'Cena {number}'**
  String storySceneNumber(int number);

  /// App wordmark.
  ///
  /// In pt, this message translates to:
  /// **'bicho a bicho'**
  String get appWordmark;

  /// App tagline.
  ///
  /// In pt, this message translates to:
  /// **'Cada descoberta, no seu tempo.'**
  String get appTagline;

  /// Play tab.
  ///
  /// In pt, this message translates to:
  /// **'Brincar'**
  String get playTab;

  /// Animals tab.
  ///
  /// In pt, this message translates to:
  /// **'Bichinhos'**
  String get animalsTab;

  /// Parents navigation.
  ///
  /// In pt, this message translates to:
  /// **'Para responsáveis'**
  String get parentsNavigation;

  /// Parents tab.
  ///
  /// In pt, this message translates to:
  /// **'Responsáveis'**
  String get parentsTab;

  /// Home title.
  ///
  /// In pt, this message translates to:
  /// **'O que vamos descobrir hoje?'**
  String get homeTitle;

  /// Home instruction.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma brincadeira. Vamos juntos, sem pressa.'**
  String get homeInstruction;

  /// Switch profile.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get switchProfile;

  /// Home reassurance.
  ///
  /// In pt, this message translates to:
  /// **'Aqui, cada tentativa é uma descoberta. Você pode repetir, pedir uma dica ou fazer uma pausa.'**
  String get homeReassurance;

  /// Home animals title.
  ///
  /// In pt, this message translates to:
  /// **'Uma turma para conhecer'**
  String get homeAnimalsTitle;

  /// See animals.
  ///
  /// In pt, this message translates to:
  /// **'Ver bichinhos →'**
  String get seeAnimals;

  /// Home footer.
  ///
  /// In pt, this message translates to:
  /// **'Feito para explorar. Com espaço para ser você.'**
  String get homeFooter;

  /// Home welcome.
  ///
  /// In pt, this message translates to:
  /// **'QUE BOM TER VOCÊ AQUI'**
  String get homeWelcome;

  /// One discovery at time.
  ///
  /// In pt, this message translates to:
  /// **'Uma descoberta\nde cada vez.'**
  String get oneDiscoveryAtATime;

  /// Home intro label.
  ///
  /// In pt, this message translates to:
  /// **'UM MUNDO DE PEQUENAS DESCOBERTAS'**
  String get homeIntroLabel;

  /// Home intro title.
  ///
  /// In pt, this message translates to:
  /// **'Aprender é melhor\ncom novos amigos.'**
  String get homeIntroTitle;

  /// Home intro description.
  ///
  /// In pt, this message translates to:
  /// **'Bichinhos, brincadeiras e um mundo para explorar.\nTudo no seu ritmo.'**
  String get homeIntroDescription;

  /// Meet animals.
  ///
  /// In pt, this message translates to:
  /// **'Conhecer a turma'**
  String get meetAnimals;

  /// Play game label.
  ///
  /// In pt, this message translates to:
  /// **'Jogar {title}'**
  String playGameLabel(String title);

  /// Play together.
  ///
  /// In pt, this message translates to:
  /// **'Vamos brincar'**
  String get playTogether;

  /// Start now.
  ///
  /// In pt, this message translates to:
  /// **'Começar agora'**
  String get startNow;

  /// Opening welcome.
  ///
  /// In pt, this message translates to:
  /// **'A turma chegou para brincar!'**
  String get openingWelcome;

  /// Report title.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhamento das brincadeiras'**
  String get reportTitle;

  /// Report description.
  ///
  /// In pt, this message translates to:
  /// **'Disponível sem login. Escolha abaixo de quem deseja consultar os registros. Consultar outro cartão não muda quem está brincando.'**
  String get reportDescription;

  /// Report storage failure.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler ou salvar parte dos registros. Os dados desta sessão continuam disponíveis enquanto o app estiver aberto.'**
  String get reportStorageFailure;

  /// Retry save.
  ///
  /// In pt, this message translates to:
  /// **'Tentar salvar dados locais'**
  String get retrySave;

  /// Report local notice.
  ///
  /// In pt, this message translates to:
  /// **'Acumulado desde o início do registro ou a última limpeza. A conta opcional não sincroniza estes dados.'**
  String get reportLocalNotice;

  /// Report profile title.
  ///
  /// In pt, this message translates to:
  /// **'De quem é este relatório?'**
  String get reportProfileTitle;

  /// Profile identity.
  ///
  /// In pt, this message translates to:
  /// **'{name} • {cardNumber}'**
  String profileIdentity(String name, String cardNumber);

  /// Report active profile.
  ///
  /// In pt, this message translates to:
  /// **'Brincando agora: {name}. Para trocar quem brinca, use o cartão na tela inicial.'**
  String reportActiveProfile(String name);

  /// Report activity filter.
  ///
  /// In pt, this message translates to:
  /// **'Atividade do relatório'**
  String get reportActivityFilter;

  /// All activities.
  ///
  /// In pt, this message translates to:
  /// **'Todas as atividades'**
  String get allActivities;

  /// Report choices filter.
  ///
  /// In pt, this message translates to:
  /// **'Alternativas no momento da rodada'**
  String get reportChoicesFilter;

  /// All configurations.
  ///
  /// In pt, this message translates to:
  /// **'Todas as configurações'**
  String get allConfigurations;

  /// Two alternatives.
  ///
  /// In pt, this message translates to:
  /// **'2 alternativas'**
  String get twoAlternatives;

  /// Three alternatives.
  ///
  /// In pt, this message translates to:
  /// **'3 alternativas'**
  String get threeAlternatives;

  /// Drawing without choices.
  ///
  /// In pt, this message translates to:
  /// **'Desenho sem alternativas'**
  String get drawingWithoutChoices;

  /// Report empty.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há registros neste filtro. Abra uma brincadeira com este perfil para começar. O uso anterior à atualização não tinha registro de erros.'**
  String get reportEmpty;

  /// Report errors.
  ///
  /// In pt, this message translates to:
  /// **'Tentativas incorretas'**
  String get reportErrors;

  /// Report rounds with errors.
  ///
  /// In pt, this message translates to:
  /// **'Rodadas com erro'**
  String get reportRoundsWithErrors;

  /// Report answered with errors.
  ///
  /// In pt, this message translates to:
  /// **'{errors} de {answered} respondidas'**
  String reportAnsweredWithErrors(int errors, int answered);

  /// Report first try.
  ///
  /// In pt, this message translates to:
  /// **'Acertos na primeira tentativa'**
  String get reportFirstTry;

  /// Report hints.
  ///
  /// In pt, this message translates to:
  /// **'Rodadas com dica'**
  String get reportHints;

  /// Report resolved.
  ///
  /// In pt, this message translates to:
  /// **'Rodadas resolvidas'**
  String get reportResolved;

  /// Report skipped.
  ///
  /// In pt, this message translates to:
  /// **'Rodadas puladas'**
  String get reportSkipped;

  /// Report opened rounds.
  ///
  /// In pt, this message translates to:
  /// **'Rodadas abertas: {started} • Com resposta: {answered}. Rodadas interrompidas também ficam registradas.'**
  String reportOpenedRounds(int started, int answered);

  /// Report animal ranking.
  ///
  /// In pt, this message translates to:
  /// **'Animais com maior proporção de rodadas com erro'**
  String get reportAnimalRanking;

  /// Report ranking description.
  ///
  /// In pt, this message translates to:
  /// **'Ordem pela proporção de rodadas respondidas que tiveram erro, com o tamanho da amostra ao lado. O animal é o alvo da pergunta, inclusive em letras, contagem e histórias.'**
  String get reportRankingDescription;

  /// Report no errors.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tentativa incorreta registrada neste filtro.'**
  String get reportNoErrors;

  /// Report animal error rate.
  ///
  /// In pt, this message translates to:
  /// **'Rodadas respondidas com erro: {errors} de {answered} ({percentage}%).'**
  String reportAnimalErrorRate(int errors, int answered, int percentage);

  /// Report animal errors and hints.
  ///
  /// In pt, this message translates to:
  /// **'Tentativas incorretas: {errors} • Rodadas com dica: {hints}'**
  String reportAnimalErrorsAndHints(int errors, int hints);

  /// Report by activity.
  ///
  /// In pt, this message translates to:
  /// **'Por atividade'**
  String get reportByActivity;

  /// Report interpretation.
  ///
  /// In pt, this message translates to:
  /// **'Como ler: cada resposta incorreta conta como uma tentativa; uma rodada com vários erros conta uma vez em “Rodadas com erro”. Dicas não são erros. Acerto na primeira tentativa pode ter tido dica. Falhas do microfone, pausas e saltos não são erros. Uma amostra pequena ou ajuda de um adulto pode mudar a interpretação. Esses dados descrevem o uso do app e não medem desenvolvimento ou dificuldade clínica.'**
  String get reportInterpretation;

  /// Clear profile history.
  ///
  /// In pt, this message translates to:
  /// **'Apagar acompanhamento de {name}'**
  String clearProfileHistory(String name);

  /// Clear profile history title.
  ///
  /// In pt, this message translates to:
  /// **'Apagar acompanhamento de {name}?'**
  String clearProfileHistoryTitle(String name);

  /// Clear profile history description.
  ///
  /// In pt, this message translates to:
  /// **'Apaga erros, acertos, dicas e rodadas deste perfil em todas as atividades e configurações. Os outros perfis e os ajustes serão preservados.'**
  String get clearProfileHistoryDescription;

  /// Cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Clear history.
  ///
  /// In pt, this message translates to:
  /// **'Apagar acompanhamento'**
  String get clearHistory;

  /// Report no activity records.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem registros.'**
  String get reportNoActivityRecords;

  /// Report activity summary.
  ///
  /// In pt, this message translates to:
  /// **'Tentativas incorretas: {errors} • Rodadas respondidas com erro: {roundsWithErrors} de {answered} • Acertos na primeira tentativa: {firstTry}'**
  String reportActivitySummary(
    int errors,
    int roundsWithErrors,
    int answered,
    int firstTry,
  );

  /// Profile save failed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar neste aparelho. Tente novamente.'**
  String get profileSaveFailed;

  /// New profile.
  ///
  /// In pt, this message translates to:
  /// **'Novo cartão'**
  String get newProfile;

  /// Profile title.
  ///
  /// In pt, this message translates to:
  /// **'Seu cartão'**
  String get profileTitle;

  /// Profile animal title.
  ///
  /// In pt, this message translates to:
  /// **'Seu cartão do {animalName}'**
  String profileAnimalTitle(String animalName);

  /// Choose animal.
  ///
  /// In pt, this message translates to:
  /// **'Escolha seu bichinho'**
  String get chooseAnimal;

  /// Profile name question.
  ///
  /// In pt, this message translates to:
  /// **'Como vamos chamar você?'**
  String get profileNameQuestion;

  /// Profile name help.
  ///
  /// In pt, this message translates to:
  /// **'Um responsável pode ajudar a escrever. O nome aparecerá neste cartão e no acompanhamento das brincadeiras.'**
  String get profileNameHelp;

  /// Profile name label.
  ///
  /// In pt, this message translates to:
  /// **'Nome ou apelido (opcional)'**
  String get profileNameLabel;

  /// Profile name example.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Ana'**
  String get profileNameExample;

  /// Profile name hint.
  ///
  /// In pt, this message translates to:
  /// **'Pode ser só o primeiro nome.'**
  String get profileNameHint;

  /// Profile local notice.
  ///
  /// In pt, this message translates to:
  /// **'Salvo somente neste aparelho. Não é necessário criar uma conta.'**
  String get profileLocalNotice;

  /// Saving.
  ///
  /// In pt, this message translates to:
  /// **'Salvando...'**
  String get saving;

  /// Save and play.
  ///
  /// In pt, this message translates to:
  /// **'Salvar e brincar'**
  String get saveAndPlay;

  /// Save profile.
  ///
  /// In pt, this message translates to:
  /// **'Salvar cartão'**
  String get saveProfile;

  /// Continue without name.
  ///
  /// In pt, this message translates to:
  /// **'Continuar sem nome'**
  String get continueWithoutName;

  /// Use animal only.
  ///
  /// In pt, this message translates to:
  /// **'Usar só o bichinho'**
  String get useAnimalOnly;

  /// Profile search index.
  ///
  /// In pt, this message translates to:
  /// **'{name} {cardNumber} {animalName}'**
  String profileSearchIndex(String name, String cardNumber, String animalName);

  /// Profile selection title.
  ///
  /// In pt, this message translates to:
  /// **'Quem vai brincar?'**
  String get profileSelectionTitle;

  /// Select profile.
  ///
  /// In pt, this message translates to:
  /// **'Escolher cartão'**
  String get selectProfile;

  /// Profile selection prompt.
  ///
  /// In pt, this message translates to:
  /// **'Toque no seu cartão.'**
  String get profileSelectionPrompt;

  /// Select profile prompt.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um cartão.'**
  String get selectProfilePrompt;

  /// Search profile.
  ///
  /// In pt, this message translates to:
  /// **'Buscar cartão'**
  String get searchProfile;

  /// Profile search hint.
  ///
  /// In pt, this message translates to:
  /// **'Nome, animal ou número'**
  String get profileSearchHint;

  /// Profile creation description.
  ///
  /// In pt, this message translates to:
  /// **'Qualquer pessoa pode criar um cartão, com nome opcional e o bichinho que preferir.'**
  String get profileCreationDescription;

  /// Profile search empty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum cartão encontrado. Tente outro nome, animal ou número.'**
  String get profileSearchEmpty;

  /// Profile accessibility label.
  ///
  /// In pt, this message translates to:
  /// **'{name}, {cardNumber}, bichinho {animalName}'**
  String profileAccessibilityLabel(
    String name,
    String cardNumber,
    String animalName,
  );

  /// Profile history reminder.
  ///
  /// In pt, this message translates to:
  /// **'Use sempre o seu cartão para guardar suas descobertas.'**
  String get profileHistoryReminder;

  /// Profiles on device.
  ///
  /// In pt, this message translates to:
  /// **'Cartões neste aparelho'**
  String get profilesOnDevice;

  /// Profile count description.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 cartões} =1{1 cartão} other{{count} cartões}}. Qualquer pessoa pode criar outro na tela de entrada, escolher um bichinho e informar um nome se quiser.'**
  String profileCountDescription(int count);

  /// Create profile.
  ///
  /// In pt, this message translates to:
  /// **'Criar cartão'**
  String get createProfile;

  /// Edit profile.
  ///
  /// In pt, this message translates to:
  /// **'Editar cartão'**
  String get editProfile;

  /// Profile settings description.
  ///
  /// In pt, this message translates to:
  /// **'Nome e bichinho podem se repetir. Cada cartão tem seu próprio número e histórico. Editar um cartão não muda quem está brincando.'**
  String get profileSettingsDescription;

  /// Analytics title.
  ///
  /// In pt, this message translates to:
  /// **'Dados de uso opcionais'**
  String get analyticsTitle;

  /// Analytics description.
  ///
  /// In pt, this message translates to:
  /// **'Com autorização do responsável, o Google Analytics (GA4) pode receber telas visitadas, interações dos jogos e ajustes do app, junto com um identificador da instalação e informações do dispositivo. Esses dados ajudam a melhorar as brincadeiras.'**
  String get analyticsDescription;

  /// Analytics privacy.
  ///
  /// In pt, this message translates to:
  /// **'Não enviamos nome, e-mail, senha, idade, diagnóstico, gravações ou transcrições. Não vinculamos a análise à conta do responsável. Publicidade personalizada e identificadores de publicidade estão desativados.'**
  String get analyticsPrivacy;

  /// Share usage data.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar dados de uso'**
  String get shareUsageData;

  /// Analytics consent title.
  ///
  /// In pt, this message translates to:
  /// **'Autorizar dados de uso?'**
  String get analyticsConsentTitle;

  /// Analytics consent description.
  ///
  /// In pt, this message translates to:
  /// **'Esta escolha deve ser feita pelo responsável. Ao autorizar, você permite o envio dos dados de uso descritos nesta tela ao Google Analytics. A autorização é opcional e os jogos continuam funcionando se você recusar.\n\nVocê pode desativar depois. A desativação interrompe a coleta e redefine os dados locais do SDK; não apaga dados já enviados ao Google.'**
  String get analyticsConsentDescription;

  /// Decline consent.
  ///
  /// In pt, this message translates to:
  /// **'Não autorizar'**
  String get declineConsent;

  /// Grant consent.
  ///
  /// In pt, this message translates to:
  /// **'Sou responsável e autorizo'**
  String get grantConsent;

  /// Analytics applying.
  ///
  /// In pt, this message translates to:
  /// **'Aplicando sua escolha…'**
  String get analyticsApplying;

  /// Analytics not configured.
  ///
  /// In pt, this message translates to:
  /// **'A análise ainda não está configurada nesta plataforma.'**
  String get analyticsNotConfigured;

  /// Analytics failed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível aplicar ou salvar a escolha. O envio de eventos do app está suspenso. Tente novamente antes de fechar o aplicativo.'**
  String get analyticsFailed;

  /// Try again.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// Analytics enabled.
  ///
  /// In pt, this message translates to:
  /// **'Coleta autorizada neste dispositivo. Você pode desativar a qualquer momento.'**
  String get analyticsEnabled;

  /// Analytics disabled.
  ///
  /// In pt, this message translates to:
  /// **'Coleta desativada. Todas as brincadeiras continuam disponíveis.'**
  String get analyticsDisabled;

  /// Parents title.
  ///
  /// In pt, this message translates to:
  /// **'Cada criança tem seu ritmo.'**
  String get parentsTitle;

  /// Parents description.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste a experiência junto com a criança. Observe o conforto, os interesses e as formas de comunicação que ela prefere.'**
  String get parentsDescription;

  /// Sound setting.
  ///
  /// In pt, this message translates to:
  /// **'Sons e comemorações'**
  String get soundSetting;

  /// Sound setting description.
  ///
  /// In pt, this message translates to:
  /// **'Sons ao tocar e uma música curta ao acertar. Sem música de fundo.'**
  String get soundSettingDescription;

  /// Reduced motion setting.
  ///
  /// In pt, this message translates to:
  /// **'Movimento reduzido'**
  String get reducedMotionSetting;

  /// Reduced motion description.
  ///
  /// In pt, this message translates to:
  /// **'Reduz transições. A preferência do sistema também é respeitada.'**
  String get reducedMotionDescription;

  /// Choices setting.
  ///
  /// In pt, this message translates to:
  /// **'Opções por descoberta'**
  String get choicesSetting;

  /// Choice count.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 opções} =1{1 opção} other{{count} opções}}'**
  String choiceCount(int count);

  /// Rounds setting.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho da brincadeira'**
  String get roundsSetting;

  /// Session round count.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 descobertas} =1{1 descoberta} other{{count} descobertas}}'**
  String sessionRoundCount(int count);

  /// Settings next game.
  ///
  /// In pt, this message translates to:
  /// **'As mudanças valem para a próxima brincadeira.'**
  String get settingsNextGame;

  /// Settings storage failure.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar neste dispositivo. As mudanças atuais continuam disponíveis enquanto o app estiver aberto.'**
  String get settingsStorageFailure;

  /// Completed games title.
  ///
  /// In pt, this message translates to:
  /// **'Nosso caminho de descobertas'**
  String get completedGamesTitle;

  /// Completed games description.
  ///
  /// In pt, this message translates to:
  /// **'Brincadeiras concluídas neste dispositivo. Este registro não mede desenvolvimento nem desempenho.'**
  String get completedGamesDescription;

  /// Clear local history.
  ///
  /// In pt, this message translates to:
  /// **'Apagar histórico local'**
  String get clearLocalHistory;

  /// Educational purpose.
  ///
  /// In pt, this message translates to:
  /// **'Brincar com intenção'**
  String get educationalPurpose;

  /// Educational alignment.
  ///
  /// In pt, this message translates to:
  /// **'Associação, exploração de sons, expressão e pequenas quantidades dialogam com os campos de experiência da Educação Infantil na BNCC. As letras são uma exploração lúdica, sem exigir alfabetização.'**
  String get educationalAlignment;

  /// Educational reassurance.
  ///
  /// In pt, this message translates to:
  /// **'Não há cronômetro, perda de pontos ou exigência de fala. Ofereça ajuda sem pressionar. Respeite pausas e o desejo de parar.'**
  String get educationalReassurance;

  /// Shared reading guidance.
  ///
  /// In pt, this message translates to:
  /// **'Para brincar de Detetive dos bichos, leia a pista e compare as imagens junto com a criança. Em Histórias da turma, leia as duas cenas e a pergunta; a história fica disponível para consultar. A criança pode tocar ou indicar uma imagem para você selecionar. Não é preciso saber ler.'**
  String get sharedReadingGuidance;

  /// Educational sources.
  ///
  /// In pt, this message translates to:
  /// **'Essas duas propostas foram adaptadas de atividades de adivinhação e contação com figuras reunidas pela Secretaria de Educação de Santa Catarina. As narrativas e ilustrações do app são próprias. Experimente também com livros e brinquedos fora da tela, respeitando os interesses da criança.'**
  String get educationalSources;

  /// Educational disclaimer.
  ///
  /// In pt, this message translates to:
  /// **'O app é um recurso educativo complementar. A adequação das atividades deve ser avaliada com a família e a equipe pedagógica. Não faz avaliação clínica.'**
  String get educationalDisclaimer;

  /// Privacy and account.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e conta'**
  String get privacyAndAccount;

  /// Privacy description.
  ///
  /// In pt, this message translates to:
  /// **'Os jogos não precisam de conta ou internet. O histórico fica neste dispositivo. O compartilhamento opcional de eventos de uso está descrito nos ajustes de dados acima. Não é necessário informar nome ou idade da criança. Os apelidos opcionais dos cartões ficam neste aparelho.\n\nO microfone só é solicitado no botão “Quero falar”. O serviço de reconhecimento do sistema pode enviar áudio ao provedor do dispositivo e precisar de internet. O app não grava nem armazena esse áudio. Prefira responder por toque se não desejar usar o microfone.'**
  String get privacyDescription;

  /// Optional account.
  ///
  /// In pt, this message translates to:
  /// **'Conta opcional do responsável'**
  String get optionalAccount;

  /// Licenses.
  ///
  /// In pt, this message translates to:
  /// **'Licenças e créditos'**
  String get licenses;

  /// Reset history title.
  ///
  /// In pt, this message translates to:
  /// **'Apagar o histórico?'**
  String get resetHistoryTitle;

  /// Reset history description.
  ///
  /// In pt, this message translates to:
  /// **'As contagens de brincadeiras e o acompanhamento de todos os perfis deste dispositivo serão apagados. Os ajustes serão mantidos.'**
  String get resetHistoryDescription;

  /// Keep history.
  ///
  /// In pt, this message translates to:
  /// **'Manter histórico'**
  String get keepHistory;

  /// Delete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get delete;

  /// Animal sounds license.
  ///
  /// In pt, this message translates to:
  /// **'Sons dos animais'**
  String get animalSoundsLicense;

  /// Matching game title.
  ///
  /// In pt, this message translates to:
  /// **'Encontre o bichinho'**
  String get gameMatchingTitle;

  /// Matching game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Observe, descubra e associe'**
  String get gameMatchingSubtitle;

  /// Matching game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Toque no bichinho igual ao da imagem.'**
  String get gameMatchingInstruction;

  /// Matching game skill.
  ///
  /// In pt, this message translates to:
  /// **'Associação visual'**
  String get gameMatchingSkill;

  /// Letters game title.
  ///
  /// In pt, this message translates to:
  /// **'A letra do bicho'**
  String get gameLettersTitle;

  /// Letters game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma descoberta de cada vez'**
  String get gameLettersSubtitle;

  /// Letters game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Toque na letra que completa o nome.'**
  String get gameLettersInstruction;

  /// Letters game skill.
  ///
  /// In pt, this message translates to:
  /// **'Letras e nomes'**
  String get gameLettersSkill;

  /// Counting game title.
  ///
  /// In pt, this message translates to:
  /// **'Vamos contar?'**
  String get gameCountingTitle;

  /// Counting game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pequenos grupos, grandes descobertas'**
  String get gameCountingSubtitle;

  /// Counting game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Conte os bichinhos. Toque no número.'**
  String get gameCountingInstruction;

  /// Counting game skill.
  ///
  /// In pt, this message translates to:
  /// **'Quantidades de 1 a 4'**
  String get gameCountingSkill;

  /// Speaking game title.
  ///
  /// In pt, this message translates to:
  /// **'Olá, bichinho!'**
  String get gameSpeakingTitle;

  /// Speaking game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Fale ou escolha: os dois valem'**
  String get gameSpeakingSubtitle;

  /// Speaking game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Diga o nome do bichinho ou toque na resposta.'**
  String get gameSpeakingInstruction;

  /// Speaking game skill.
  ///
  /// In pt, this message translates to:
  /// **'Expressão e reconhecimento'**
  String get gameSpeakingSkill;

  /// Clues game title.
  ///
  /// In pt, this message translates to:
  /// **'Detetive dos bichos'**
  String get gameCluesTitle;

  /// Clues game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma pista para uma descoberta'**
  String get gameCluesSubtitle;

  /// Clues game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Leia com alguém. Qual bichinho combina com a pista?'**
  String get gameCluesInstruction;

  /// Clues game skill.
  ///
  /// In pt, this message translates to:
  /// **'Pistas e características'**
  String get gameCluesSkill;

  /// Stories game title.
  ///
  /// In pt, this message translates to:
  /// **'Histórias da turma'**
  String get gameStoriesTitle;

  /// Stories game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Pequenas histórias para ler juntos'**
  String get gameStoriesSubtitle;

  /// Stories game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Leia com alguém. Depois, toque na resposta.'**
  String get gameStoriesInstruction;

  /// Stories game skill.
  ///
  /// In pt, this message translates to:
  /// **'Escuta e compreensão'**
  String get gameStoriesSkill;

  /// Drawing game title.
  ///
  /// In pt, this message translates to:
  /// **'Desenhe o bichinho'**
  String get gameDrawingTitle;

  /// Drawing game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu traço dá vida à turma'**
  String get gameDrawingSubtitle;

  /// Drawing game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Observe o modelo e desenhe o contorno com o dedo.'**
  String get gameDrawingInstruction;

  /// Drawing game skill.
  ///
  /// In pt, this message translates to:
  /// **'Desenho e formas'**
  String get gameDrawingSkill;

  /// Memory game title.
  ///
  /// In pt, this message translates to:
  /// **'Memória dos bichos'**
  String get gameMemoryTitle;

  /// Memory game subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Vire as cartas e descubra os pares'**
  String get gameMemorySubtitle;

  /// Memory game instruction.
  ///
  /// In pt, this message translates to:
  /// **'Encontre os pares de bichinhos iguais.'**
  String get gameMemoryInstruction;

  /// Memory game skill.
  ///
  /// In pt, this message translates to:
  /// **'Memória e atenção'**
  String get gameMemorySkill;

  /// Default display name for an account without a name.
  ///
  /// In pt, this message translates to:
  /// **'Responsável'**
  String get guardian;

  /// Profile name when no nickname was provided.
  ///
  /// In pt, this message translates to:
  /// **'Meu {animalName}'**
  String profileDefaultName(String animalName);

  /// Stable card number shown to distinguish equal names.
  ///
  /// In pt, this message translates to:
  /// **'Cartão {number}'**
  String profileCardNumber(int number);

  /// Compact welcome title shown on mobile.
  ///
  /// In pt, this message translates to:
  /// **'Vamos\nbrincar?'**
  String get homePlayPrompt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
