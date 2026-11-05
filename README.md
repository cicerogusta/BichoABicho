# Bicho a Bicho

Aplicativo Flutter de brincadeiras educativas com animais, reformulado com atenção à previsibilidade, acessibilidade cognitiva e possibilidade de personalização para crianças com TEA.

Pacote Dart: `bicho_a_bicho`. A pasta será `BichoABicho` após liberar o bloqueio do projeto aberto no Windows. Os identificadores de instalação e registros Firebase existentes foram preservados para manter atualizações e acesso aos dados locais; detalhes e instruções para concluir a renomeação em [PROJECT_NAMING.md](docs/PROJECT_NAMING.md).

![Tela inicial](docs/previews/home_1280x900.png)

## Experiência

- **Encontre o bichinho:** associação visual com duas ou três alternativas.
- **A letra do bicho:** reformulação do jogo de letra inicial, com opções estáveis e ajuda.
- **Vamos contar?:** grupos de um a quatro animais; tocar marca cada animal contado.
- **Olá, bichinho!:** reformulação da nomeação por voz, com alternativa equivalente por toque.
- **Detetive dos bichos:** escolher o animal que combina com uma pista, com leitura compartilhada.
- **Histórias da turma:** quatro narrativas originais em duas cenas, com perguntas sobre os personagens e resposta por imagem.
- **Desenhe o bichinho:** desenhar o contorno de quatro animais e conferir a forma no aparelho. Modelo, dica tracejada, desfazer e comemoração; [critérios e limites](docs/DRAWING_GAME.md).
- **Bichinhos:** oito animais com imagens e sons: cachorro, gato, leão, elefante, vaca, cavalo, ovelha e pato. Os quatro novos sons são gravações incluídas para uso offline; [fontes e licenças](docs/ANIMAL_ASSETS.md).
- **Responsáveis:** som, movimento reduzido, número de alternativas, duração em rodadas e histórico local de uso.
- **Acompanhamento sem login:** depois da abertura, cada pessoa escolhe seu cartão ou cria outro em **Novo cartão**, com nome opcional e animal à escolha. Sem limite fixo de usuários; busca e números próprios distinguem os cartões. “Trocar” fica na tela inicial. Erros por jogo, dicas e animais com mais rodadas com erro; [regras do relatório](docs/PARENT_PROGRESS.md).
- Conta Firebase opcional para responsáveis; jogos disponíveis sem cadastro.
- GA4 opcional, autorizado na área de responsáveis: visualizações de telas, funil dos jogos, dicas, pausas, saídas e ajustes, sem dados de identidade ou transcrições.

Sem música de fundo contínua, cronômetro, punição ou troca automática de rodada. A criança pode pedir dica, pular e fazer pausa. Sons começam desligados. Nenhum dado pessoal da criança é necessário.

As novas atividades foram selecionadas a partir de materiais para educadores e referências de apoio visual. Veja as [fontes e orientações de mediação](docs/EDUCATIONAL_ACTIVITIES_RESEARCH.md). Não exigem leitura independente; um adulto lê as pistas e histórias. O app não é uma avaliação clínica nem um programa pedagógico validado.

Ao abrir o app, os oito bichinhos entram em sequência em uma apresentação de 5 segundos, seguida por uma transição suave para o início. “Começar agora” permite pular a abertura e permanece acessível em telas pequenas. A apresentação ocorre uma vez por inicialização, sem repetir ao mudar ajustes ou voltar de um jogo.

Cada acerto, por toque ou voz, exibe o bichinho comemorando com estrelas e corações durante 1,8 segundo. Se os sons estiverem ativados, toca um arpejo original de 1,7 segundo, uma única vez. Pausar, avançar ou sair interrompe a mídia. A próxima rodada continua sendo uma escolha explícita da criança.

Em **Responsáveis → Sons e comemorações**, habilite a música. Para ver os movimentos completos, desative **Movimento reduzido**, que permanece ligado por padrão. A preferência de movimento reduzido do sistema também é respeitada: a abertura mostra a turma estática pelos mesmos 5 segundos e o acerto recebe uma comemoração visual estática.

## Executar

Na primeira escolha de um cartão, o app abre uma página com o animal e o campo de nome ou apelido. O responsável pode identificar os registros uma vez; nas próximas entradas a criança só toca no cartão. Também é possível continuar sem nome e editar depois na área dos responsáveis.

Toolchain usada: **Flutter 3.47.9 / Dart 3.13.7**. O projeto exige Flutter 3.47+ e Dart 3.12+.

~~~sh
flutter pub get
flutter run
~~~

Para testar no navegador:

~~~sh
flutter run -d chrome
~~~

No ambiente desta refatoração, o SDK foi preparado em `C:/Users/pc/.cache/flutter-sdk`. Caso ele ainda não esteja no PATH, no PowerShell use, por exemplo:

~~~powershell
& "$env:USERPROFILE/.cache/flutter-sdk/bin/flutter.bat" run
~~~

Android: minSdk 24, Java 17+, Android SDK/NDK compatíveis com o Flutter. A primeira compilação pode baixar ferramentas ausentes. No Windows, builds desktop com plugins exigem suporte a links; o SDK pode solicitar Modo de Desenvolvedor. Os testes e builds desta execução usaram junctions locais nos diretórios efêmeros de plugins, sem alterar configurações globais do Windows.

iOS: 15.0+. macOS: 12.0+. Builds Apple exigem macOS, Xcode e CocoaPods. Podfiles e descrições de privacidade foram incluídos, mas precisam de validação em máquina Apple.

## Verificação

~~~sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
~~~

Para gerar capturas das telas pelo renderer Flutter em testes:

~~~sh
flutter test --dart-define=CAPTURE_PREVIEWS=true
~~~

As imagens são gravadas em `docs/previews/`. Não são comparações golden e não substituem inspeção em aparelho. Os testes usam fakes: não dependem de rede, credenciais ou microfone.

## Arquitetura e referências

Feature-first + MVVM, domínio sem Flutter para geração de sessões, ChangeNotifier/ListenableBuilder, serviços e repositories injetáveis. Preferências e contagens usam SharedPreferencesAsync.

- [Arquitetura e compatibilidade](docs/ARCHITECTURE.md).
- [Intenção pedagógica, referências oficiais e acessibilidade](docs/EDUCATION_AND_ACCESSIBILITY.md).
- [Identidade, arquivos de arte e prompts](docs/ART_ASSETS.md).
- [Resultados e limites da validação](docs/VALIDATION.md).
- [GA4: eventos, consentimento, console e DebugView](docs/ANALYTICS.md).

A relação com a BNCC é uma proposta de alinhamento de partes das atividades. O aplicativo **não foi validado oficialmente pelo MEC, nem clinicamente ou com estudo de eficácia**. A adequação deve ser avaliada com famílias, educadores e crianças antes da distribuição.

## Conta, privacidade e migração

Firebase é configurado de forma assíncrona para aplicar a preferência de coleta, sem bloquear os jogos, e também atende a conta opcional. IDs e arquivos de serviço existentes foram preservados. A coleta GA4 começa desligada e só é ativada após autorização explícita do responsável, salva com versão de política. Ao desativar, o envio de eventos do app para e os dados locais do SDK são redefinidos; isso não apaga dados já enviados.

O adaptador Analytics está habilitado para Android/iOS. Nos demais destinos, o controle informa que a análise ainda não foi configurada. A propriedade GA4, os fluxos e a ingestão real precisam ser conferidos no Firebase/GA4 Console. Nenhuma configuração remota foi modificada.

A versão anterior copiava a senha do cadastro para o Realtime Database. A nova implementação usa somente Firebase Authentication e não escreve senhas no banco. **O administrador precisa verificar e remover campos de senha legados e avaliar a redefinição das credenciais afetadas.** Nenhum registro remoto foi acessado ou apagado nesta refatoração.

O histórico do aplicativo fica no dispositivo. Se o responsável autorizar o GA4, interações futuras dos jogos e preferências de experiência também são enviadas como eventos e propriedades de configuração, junto com dados automáticos do SDK e identificador pseudônimo da instalação. Não há envio retroativo do histórico. Conclusões com rodadas puladas também contam; o histórico e as métricas representam uso, não avaliação da criança.

O reconhecimento de voz depende do provedor do sistema/navegador, da disponibilidade de pt-BR e das permissões. Pode usar internet e processamento externo. O app não persiste áudio. Responder por toque funciona sem reconhecimento de voz.

## Antes de distribuir

Validar áudio, permissões, TalkBack/VoiceOver e conforto sensorial em aparelhos reais e em sessões acompanhadas. Configurar assinatura de produção Android; a configuração local de assinatura debug foi preservada. O histórico não é sincronizado e a área de responsáveis não possui bloqueio parental.

A licença Nunito está em `fonts/OFL-Nunito.txt`. Ilustrações novas geradas por ImageGen; arquivos antigos mantidos no repositório, fora do bundle quando não utilizados.
