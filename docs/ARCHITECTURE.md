# Arquitetura

## Estrutura

`main.dart` inicializa somente preferências locais. `app/app.dart` configura tema, idioma pt-BR e a raiz de navegação. Firebase não bloqueia a inicialização dos jogos.

`AppEntry` mantém a conclusão da abertura no estado da raiz. `OpeningPage` possui uma animação finita de 5 segundos, cancelamento por descarte e suspensão no segundo plano. A apresentação reduzida usa um timer cancelável de 5 segundos. Não há navegação adicional ou rota de abertura para reaparecer ao voltar de um jogo.

Comemorações de acerto são iniciadas no `GameViewModel`, com consulta à preferência de som antes da reprodução. A mesma geração que protege os callbacks de fala invalida músicas ainda pendentes ao pausar, trocar de rodada ou sair. O widget de comemoração controla somente o movimento, por 1,8 segundo, respeitando `MediaQuery.disableAnimations`. Não há efeitos colaterais de áudio em `build` nem novas dependências.

- `features/animals/domain`: catálogo imutável, caminhos dos recursos e normalização de português.
- `features/games/domain`: definições dos jogos e geração de rodadas. Não importa Flutter ou plugins. `Random` pode ser injetado para execução determinística nos testes.
- `features/games/presentation`: `GameViewModel` controla a sessão; `GamePage` possui ciclo de vida e navegação; `GameRoundView` compõe a atividade.
- `features/settings/domain`: contrato de armazenamento. `data` implementa SharedPreferencesAsync. `AppSettings` expõe estado somente para leitura e serializa gravações para evitar inversão da ordem em alterações rápidas.
- `features/account/domain`: contrato e falhas de autenticação sem dependência do SDK Firebase. `data` adapta Firebase e traduz os erros. `presentation` gerencia formulários e estados de carregamento/erro/sucesso.
- `core/theme` e `core/widgets`: tokens e componentes compartilhados.
- `core/services`: adaptadores de áudio e fala com contratos substituíveis.

## Decisões

A análise de uso tem contrato próprio em `core/analytics`, adaptador Firebase isolado e `AnalyticsController` com fila em memória. O controle de consentimento versionado faz parte da persistência de preferências. Native defaults negam a coleta; a ativação depende de escolha explícita, e a revogação invalida eventos ainda pendentes. O rastreamento de páginas e abas é manual e deduplicado, sem observer Firebase adicional. O catálogo e a política de dados estão em [ANALYTICS.md](ANALYTICS.md).

Feature-first com MVVM e domínio apenas onde existe comportamento independente. ChangeNotifier/ListenableBuilder mantém a solução no SDK Flutter, com dependências recebidas pelo construtor dos ViewModels. O projeto anterior usava estado local; não havia Riverpod, Bloc ou Provider a preservar. Não foram criados use cases triviais nem contêiner global de DI.

A navegação tem três seções principais e rotas locais de jogo/conta com `Navigator` e `MaterialPageRoute`. Não existe necessidade atual de deep links, rotas protegidas ou GoRouter. A conta não é uma barreira para o acesso infantil.

`GameSession` prepara opções imutáveis uma única vez. Uma sessão passa pelos quatro animais antes de repeti-los. O embaralhamento nunca ocorre na renderização. A quantidade de alternativas e de rodadas é capturada no começo da sessão.

`GameViewModel` aceita serviços falsos em testes, impede avanço duplicado e invalida callbacks antigos por geração quando a rodada muda, pausa ou é descartada. A preparação do microfone também verifica se houve cancelamento durante o pedido de permissão. O adaptador de fala lida com o singleton do plugin, que conserva listeners após inicialização. O adaptador de áudio serializa comandos de reprodução, parada e descarte.

O SDK `speech_to_text` continua sendo uma integração opcional: ausência de pt-BR, indisponibilidade de rede, plataforma não suportada e permissão negada oferecem resposta por toque. O reconhecimento não é instrumento de avaliação de pronúncia.

Os novos animais possuem 1254 × 1254 pixels, com fundo transparente. A decodificação usa dimensões ajustadas ao tamanho exibido e à densidade da tela, limitadas a 1024 pixels. Os recursos antigos são preservados no repositório, mas somente arquivos usados entram no bundle.

## Compatibilidade

Toolchain de referência: Flutter 3.47.9 e Dart 3.13.7. O pubspec exige Flutter 3.47+ e Dart 3.12+. Android usa AGP 9.1, Gradle 9.3.1, Kotlin 2.4, bytecode Java 17 e minSdk 24. As flags de migração recomendadas pelo SDK Flutter permanecem no Gradle para os plugins que ainda usam KGP.

iOS exige 15.0 e macOS 12.0. Podfiles e xcconfigs incluem o suporte aos plugins e as descrições de privacidade estão configuradas. Os builds Apple precisam ser executados em macOS com Xcode/CocoaPods. Web/Windows/Linux mantêm os jogos por toque; Firebase ainda não possui configuração Web/Windows/Linux neste repositório. A tela de conta informa essa limitação sem bloquear os jogos.

## Evolução

`ProfileCatalog` substitui os três slots fixos por uma coleção imutável sem quantidade pré-definida. O identificador numérico é persistido com o próximo número disponível e não depende de nome, posição ou animal. Os dados antigos são migrados com os mesmos IDs; o histórico aceita qualquer identificador não negativo. `ProfileNamePage` cria ou edita nome opcional e animal. A seleção usa grade sob demanda e busca local; o relatório reutiliza a seleção em modo somente consulta, preservando o cartão ativo. O cadastro fica em um JSON versionado no repositório existente, sem novas dependências ou identidade enviada ao Analytics.

`ProfileNamePage` é uma rota reutilizada na primeira identificação de um cartão e na edição pelos responsáveis. `AppSettings.profileIsConfigured` separa a confirmação de cadastro da existência de um nome: é possível continuar sem nome sem repetir o formulário. A configuração é persistida por cartão e apelidos antigos são reconhecidos na migração. A seleção só libera a entrada depois de concluir essa etapa ou escolher continuar sem nome. A rota de Analytics é genérica (`profileName`), sem registrar o conteúdo do campo.

O jogo `drawing` reutiliza a sessão e as comemorações, com `DrawingController` para traços em memória, `DrawingEvaluator` puro em Dart e modelos vetoriais próprios. A avaliação é explícita, separada da pintura; o quadro usa prioridade de gestos para não disputar a rolagem. A sessão tem zero alternativas e registra `input_method=drawing`, sem persistir ou transmitir coordenadas. Os [critérios e limitações](DRAWING_GAME.md) estão documentados.

Após a abertura, `LearnerEntry` sempre solicita que a criança toque em seu cartão, mesmo com apenas um perfil configurado. Essa confirmação não é persistida; a quantidade de cartões e seus apelidos são persistidos. `ProfileSelectionPage` é reutilizada na entrada e na troca pela tela inicial e aceita somente uma seleção por apresentação. `ProfileSettingsCard` configura o uso individual/compartilhado e os apelidos. O filtro do relatório possui estado próprio e não altera o cartão que recebe as novas observações. Os IDs do histórico anterior permanecem estáveis.

O acompanhamento local usa `features/progress/domain/learning_history.dart`, com observações tipadas e agregados imutáveis, e `presentation/learning_report.dart`. O ViewModel publica interações por callback injetado; `AppSettings` compõe e persiste os contadores, seguindo seu papel existente de histórico local. O perfil é capturado na abertura do jogo. O ranking e os filtros pertencem ao domínio, e a apresentação usa o ChangeNotifier existente. Não há dependência do relatório em Firebase Auth ou Analytics. As regras estão em [PARENT_PROGRESS.md](PARENT_PROGRESS.md).

Os jogos de pistas (`clues`) e histórias (`stories`) reutilizam a sessão e o ViewModel existentes. `AnimalStory` e `StoryScene` são modelos de domínio sem Flutter; `StoryPrompt` apenas apresenta as cenas. O catálogo `GameKind` também determina quais contagens de conclusão são carregadas e persistidas, preservando as chaves anteriores. A seleção de personagens/distratores ocorre ao criar a sessão, sem aleatoriedade em `build`. Os mapas de aparência dos cartões usam o tipo de jogo, sem depender da posição no catálogo. Novos tipos também precisam de tela nomeada e inclusão explícita no contrato de parâmetros do Analytics.

Novos animais entram no catálogo e no bundle de assets. Para novos tipos de atividade, acrescentar uma definição, implementar o comportamento de domínio e a composição de apresentação correspondente, com testes das regras. Antes de aumentar os grupos de contagem, o número de distratores ou introduzir pontuação/temporizadores, reavaliar a intenção pedagógica e a carga da interface.
