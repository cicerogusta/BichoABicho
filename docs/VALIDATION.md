# Validação da refatoração

Execução em Windows, em 05/11/2026, com Flutter 3.47.9 e Dart 3.13.7.

| Verificação | Resultado |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test tool` | Arquivos formatados |
| `flutter analyze` | Nenhum problema encontrado |
| `flutter gen-l10n` | 280 recursos de interface gerados a partir do ARB |
| `flutter test --dart-define=CAPTURE_PREVIEWS=true` | 184 testes aprovados; capturas em `build/previews/` |
| `flutter test tool/generate_readme_previews.dart` | Gerador validado e 13 capturas mobile atualizadas |
| `flutter build apk --release --no-pub` | APK Android release gerado |
| `flutter build web --release` | Build web gerado; dry run de compilação Wasm também aprovado |

## Revisão de limpeza e localização

A revisão preservou as funcionalidades, o README, suas 13 capturas mobile, os 19 recursos do bundle e os créditos de licença. Foram retirados vídeos e seus geradores, arquivo `lib.rar`, logs, 17 prévias duplicadas, dez assets legados e três fontes sem uso. Capturas opcionais dos testes foram centralizadas em um helper e passaram a ser saída de build.

As strings da interface, acessibilidade, mensagens e metadados de jogos estão em `lib/l10n/app_pt.arb`. A geração usa o `gen-l10n` oficial, com parâmetros tipados e casos explícitos de zero, singular e plural. Nomes dos animais e histórias permanecem em catálogos pedagógicos Dart independentes de Flutter. A auditoria de literais não encontrou texto de linguagem natural remanescente nos arquivos de apresentação. As 59 referências locais dos documentos foram verificadas, sem referências quebradas.

Os adaptadores são compostos em `AppDependencies`. `GameMediaController` foi separado da progressão das rodadas, e `AnimalExplorerViewModel` passou a controlar reprodução e cancelamento no catálogo. Erros de conta e mídia são tipados; a apresentação faz sua tradução. O ViewModel de conta descarta resultados tardios depois do encerramento e expõe estado somente para leitura. As coleções de alternativas também são protegidas no próprio modelo de rodada.

Os 12 testes adicionais cobrem plurais, rótulos sem mutar dados persistidos, catálogo localizado, tradução de estados tipados, contratos de arquitetura, substituição de dependências, cancelamento de áudio e resultados tardios de autenticação. A suíte anterior foi mantida.

`intl` passou a ser dependência direta por ser usado pelo código gerado. A dependência transitiva `synchronized` foi atualizada para 3.6.1. `cupertino_icons` foi mantida: controles adaptativos do próprio Flutter referenciam sua fonte, mesmo sem import explícito nas telas. O build Web final incluiu essa fonte e não voltou a emitir o aviso de fonte ausente.

### Avisos externos e limites

- `flutter analyze` concluiu sem erros, warnings ou infos. Não foram adicionadas supressões para esconder diagnósticos.
- O Gradle continua emitindo um aviso de acesso nativo da JVM e o Flutter informa que os plugins `firebase_core`, `firebase_auth` e `firebase_analytics` ainda aplicam KGP. As flags de compatibilidade foram mantidas conforme a [orientação oficial do Flutter](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin); a migração completa depende de suporte dos plugins.
- Três versões transitivas mais recentes continuam limitadas pelas restrições do SDK. Não foram usados `dependency_overrides` para forçar versões incompatíveis.
- Builds iOS, macOS, Windows e Linux e testes em aparelhos físicos não foram executados nesta revisão.
- Após `flutter clean`, as dependências foram regeneradas com `FLUTTER_WINDOWS=false` e `FLUTTER_LINUX=false` somente no processo de validação, pois este Windows exige Modo de Desenvolvedor para criar os links dos plugins desktop. Nenhuma configuração global do Flutter ou do Windows foi alterada.
- Os arquivos de build e as ferramentas temporárias de migração são descartáveis e não integram o código-fonte.

## Histórico das validações anteriores

## Nome do projeto

`flutter build apk --debug` também concluiu após a mudança do pacote, gerando o APK atual em `build/app/outputs/flutter-apk/app-debug.apk`.

A atualização de nome do projeto também passou por `dart format --output=none --set-exit-if-changed lib test tool`, `flutter analyze` e pelos 162 testes. Os imports usam `bicho_a_bicho`. Os plists iOS/macOS foram verificados como XML válido e o script de renomeação passou pelo parser PowerShell. Os builds Apple e desktop não foram executados. Para regenerar dependências neste Windows sem habilitar o Modo de Desenvolvedor do sistema, `FLUTTER_WINDOWS=false` e `FLUTTER_LINUX=false` foram usados somente nos processos de validação; nenhuma configuração global do Flutter foi alterada. A pasta continua bloqueada pelo projeto aberto, conforme PROJECT_NAMING.md.

## Ampliação para oito animais

Vaca, cavalo, ovelha e pato foram incluídos com ilustrações e gravações específicas offline. Cinco testes adicionais verificam o catálogo nos jogos e GA4, alternativas sem letras duplicadas, seleção apenas de moldes existentes no desenho, WAV PCM16 mono com sinal e duração válidos, reprodução do arquivo correto em cada rodada, exploração dos oito sons, mute e descarte do player. A abertura foi verificada em 360×740: os oito animais aparecem integralmente antes do término dos cinco segundos.

Formatador sem alterações pendentes, análise estática sem problemas, 162 testes aprovados e builds Android debug e Web release concluídos em 05/11/2026. Os testes de reprodução usam fakes: a qualidade auditiva dos novos sons ainda requer conferência em aparelho. Fontes e licenças estão em ANIMAL_ASSETS.md e nos créditos acessíveis pelo aplicativo.

## Cobertura funcional

Os cartões dinâmicos foram verificados com criação concorrente e restauração de 128 cartões novos, nomes/animais repetidos, próximo ID persistido, histórico de IDs maiores que três e migração de cartões antigos identificados ou utilizados. Os widgets cobrem criação pública com nome vazio, escolha de elefante, busca entre vários usuários, distinção por número, troca de histórico, edição de nome/animal, retry sem duplicar criação e texto a 200%. Os antigos seletores de quantidade foram removidos. As contagens abaixo refletem os testes atuais, incluindo os casos substituídos pelo novo fluxo.

A identificação de cartões acrescentou um teste unitário e três de widgets: nome e opção sem nome restaurados, compatibilidade com apelidos existentes, imagem do animal selecionado, validação, cancelamento, nova entrada sem redigitação, falha/retry e formulário a 200% em 320×640. A captura `docs/previews/profile_name.png` foi inspecionada visualmente. Os testes de navegação GA4 incluem a rota genérica de identificação sem registrar nomes.

O desenho acrescentou 12 testes do comparador (quatro modelos × aproximação, rejeição de formas genéricas e distinção entre animais), três testes de controller/ViewModel e dois de widgets com texto normal e ampliado. Mais dois casos da geração de sessões verificam ausência de alternativas fictícias. A interação real do teste traça o modelo, usa dica e pausa, ignora um segundo dedo, confere e conclui com comemoração. A captura `docs/previews/game_drawing.png` foi inspecionada. Isso não substitui avaliação dos critérios com desenhos reais de crianças ou teste em aparelho físico.

O fluxo de cartões acrescentou dois testes unitários e cinco de widgets: migração dos perfis numerados, apelidos persistidos sem telemetria, escolha visual após a abertura com um ou vários cartões, nova inicialização, troca na tela inicial, toque duplicado, personalização pelos responsáveis e seleção a 200% em 320×640. A captura `docs/previews/profile_selection.png` foi inspecionada visualmente.

O acompanhamento local acrescentou sete testes unitários e cinco de widgets: erros e rodadas distintos, dicas deduplicadas, primeiro acerto, restauração após abandono, isolamento de perfis, filtros, ranking por proporção, falhas de armazenamento, dados corrompidos e texto ampliado. A captura `docs/previews/parent_report.png` foi gerada pelo renderer Flutter e inspecionada visualmente.

99 testes unitários exercitam geração de rodadas, existência de uma única alternativa correta, distratores únicos, configurações inválidas, normalização de palavras, tentativa/ajuda/avanço, prevenção de avanço duplicado, pausa, falha de áudio, fala indisponível, callbacks atrasados, cancelamento durante preparação do microfone, toque repetido na contagem, persistência, falha de armazenamento, restauração de conta, erros e submissão duplicada. A seleção de atividades acrescenta verificação de histórias com resposta explícita e personagens distintos, alternativas com os dois personagens, persistência de todos os jogos e aceitação dos eventos GA4 de `clues` e `stories`.

63 testes de widgets verificam tela inicial em 320×640, 390×844, 768×1024, 1280×900 e 844×390; navegação e ajustes; sete fluxos completos por toque e desenho; sete jogos com texto normal e a 200%; tamanho dos recursos de imagem e presença dos sons; ação semântica nos cartões; diretriz automatizada de tamanho de alvos Android; texto ampliado na tela inicial. Os novos jogos também são abertos pelo catálogo e retornam ao início por navegação.

Os testes comparam comportamento e estado; os arquivos em `docs/previews` são capturas para inspeção visual, não baselines golden. As capturas de jogos foram geradas com três alternativas para conferir o layout mais exigente. O padrão do aplicativo é duas alternativas.

## Artefatos

- APK de desenvolvimento: `build/app/outputs/flutter-apk/app-debug.apk`.
- Aplicativo web: `build/web/`.
- Capturas: `docs/previews/home_*.png`, `docs/previews/game_*.png`.
- Ícone: `docs/previews/brand_icon.png`; tamanhos de instalação nas pastas nativas de cada plataforma.

## Limites reais da execução

Nenhum aparelho Android estava conectado ao ADB. Áudio real, diálogo de permissões, reconhecimento em pt-BR, TalkBack/VoiceOver e comportamento de instalação não foram testados em dispositivo físico. A autenticação foi testada por contrato com fakes; nenhuma conta real foi criada ou acessada. Não houve leitura ou alteração de dados remotos Firebase.

Não foram executados builds iOS/macOS, pois a máquina não possui macOS/Xcode. Builds Windows/Linux e um teste manual em navegador também não foram executados. A compilação Web e as capturas pelo renderer Flutter não equivalem a esses testes de plataforma.

O Gradle emitiu avisos de compatibilidade futura dos plugins Firebase com Kotlin integrado e de acesso nativo da JVM utilizada pelo Android Studio. São avisos de dependências/toolchain; o build concluiu sem erro. Não foram desabilitadas regras de análise para esconder problemas. Três dependências transitivas têm versões mais novas fora das restrições resolvidas; não foram forçadas com overrides.

Para distribuir, ainda é necessário configurar assinatura Android de produção e validar a experiência com crianças, responsáveis e educadores. A refatoração não comprova eficácia educativa ou clínica.


Os oito novos testes de áudio verificam comemoração única, silêncio em erro ou mute, acerto por voz, cancelamento antes da reprodução, troca de rodada, mudança de preferência e WAV válido. Os nove novos testes de widgets cobrem abertura automática, versão com movimento reduzido, pausa em segundo plano, descarte, botão de pular, apresentação única por inicialização, texto ampliado e comemoração finita. Capturas adicionais: docs/previews/opening.png e docs/previews/celebration.png.

## GA4 e consentimento

A integração Analytics acrescenta testes de coleta desligada por padrão, consentimento explícito/versionado, falha de persistência, falha do SDK, revogação durante inicialização, preservação da revogação quando o SDK falha, mudanças rápidas de escolha, deduplicação de telas/diálogos, navegação entre abas e retorno de jogo, parâmetros limitados, ausência de identidade e transcrições, duração/resultado/pulos, abandono e propriedades de configuração. O diálogo foi verificado também em 320×640 com texto a 200% e conteúdo rolável.

O manifesto Android final mesclado foi inspecionado: coleta inicial, screen reporting automático, Advertising ID e consentimentos de publicidade estão desativados; permissões AD_ID e AdServices foram removidas. Configurações Apple e dependência sem IDFA foram preparadas, mas não executadas em Xcode.

Nenhum aparelho está conectado ao ADB, e não há conector administrativo Firebase/GA4 nesta sessão. Não houve criação de propriedade, dimensão, fluxo ou validação de ingestão no DebugView. Os testes usam fakes e nenhum evento de teste foi enviado a contas remotas. O roteiro de configuração e validação manual está em ANALYTICS.md.
