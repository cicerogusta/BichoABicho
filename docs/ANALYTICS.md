# GA4 / Google Analytics for Firebase

## Estado da integração

Integração com `firebase_analytics` 13.0.1, utilizando o projeto Firebase existente `app-edu-ifpb`. O código está preparado para Android e iOS. O SDK é configurado de forma assíncrona, sem bloquear a entrada nos jogos. Os builds não comprovam entrega de eventos: a vinculação da propriedade GA4 e o DebugView precisam de validação no console e em um aparelho.

Web, Windows, Linux e macOS mantêm a análise desativada neste adaptador. Web não tem configuração Firebase/measurement ID no projeto. A configuração macOS existente referencia um bundle de testes e precisa ser corrigida antes de habilitar esse destino. Não foram inventados IDs, criadas propriedades remotas ou alteradas permissões de contas Google.

## Consentimento e dados

O padrão é **desativado**, tanto no código Dart quanto nas configurações nativas. Em **Responsáveis → Privacidade e conta → Dados de uso opcionais**, o responsável pode autorizar explicitamente o envio. Recusar mantém todas as brincadeiras disponíveis.

A autorização é salva localmente com versão de política. A ativação exige que a preferência seja persistida com sucesso. A revogação bloqueia imediatamente os novos eventos do app, invalida os que aguardam envio, solicita desativação do SDK e redefine seus dados locais. A escolha de revogar é salva mesmo se o canal nativo falhar. Falhas de armazenamento ou plataforma aparecem na interface; se a revogação não puder ser salva, é preciso tentar novamente antes de fechar o app.

Eventos de antes da autorização são descartados, sem recuperação retroativa. Em inicializações posteriores com autorização válida, eventos podem aguardar a configuração local do SDK em uma fila serial em memória. Não há uma segunda fila persistente própria ou envio via Measurement Protocol. O transporte e os lotes de rede são do SDK Firebase.

O GA4 recebe um identificador pseudônimo da instalação e dados automáticos do SDK, como dispositivo, versão do sistema/app, idioma, sessões e informações de uso. A análise não é anônima e uma instalação pode ser usada por várias crianças. “Usuários” nos relatórios não representa necessariamente crianças distintas.

Não são enviados `user_id`, UID Firebase Auth, nome, e-mail, senha, idade, diagnóstico, nome da escola, texto digitado, gravação ou transcrição. `setUserId(null)` limpa qualquer vínculo anterior de User-ID. As chaves são enumeradas e os valores de texto passam por listas de valores aceitos; parâmetros fora do contrato são descartados.

Consentimentos de publicidade permanecem negados (`ad_storage`, `ad_user_data`, `ad_personalization`). Android remove AD_ID e as permissões de AdServices do manifesto final; a coleta do Advertising ID também é desativada por configuração. Apple utiliza `FirebaseAnalytics/Core` sem suporte a IDFA e desativa IDFV. Não foi solicitada permissão ATT.

Redefinir os dados locais do SDK **não apaga** dados já recebidos pelo Google. A área de responsáveis e o diálogo não verificam identidade/idade de quem toca. A publicação exige revisão da política de privacidade, obrigações referentes a crianças, declarações das lojas e das configurações da propriedade GA4. Esta integração não certifica conformidade legal nem aprovação das lojas.

## Arquitetura

O acompanhamento local dos responsáveis é independente deste serviço. Seus perfis e contadores acumulados não são enviados como parâmetros, propriedades ou User-ID. Selecionar um perfil não identifica uma criança nos eventos opcionais existentes. O painel funciona com o GA4 desativado e não recupera dados do console. Consulte [PARENT_PROGRESS.md](PARENT_PROGRESS.md).

- `core/analytics/usage_analytics.dart`: contrato, nomes de eventos/telas e parâmetros aceitos, sem dependência de Firebase.
- `analytics_controller.dart`: consentimento, estado observável, fila serial, descarte de tarefas antigas, deduplicação de telas e tratamento de falhas.
- `firebase_analytics_backend.dart`: único adaptador que acessa o SDK Analytics. Suporta substituição por fake nos testes.
- `usage_navigator_observer.dart`: acompanha páginas nomeadas e o retorno ao início; ignora diálogos. As abas mantêm sua própria tela raiz atual.
- `AppSettings`: persistência versionada da escolha e instrumentação das mudanças de configuração.
- ViewModels dos jogos e da conta: eventos de ações e resultados com categorias limitadas, sem efeitos de telemetria em `build`.

O rastreamento automático de telas nativas está desligado. Não há `FirebaseAnalyticsObserver` adicional: usar ambos causaria contagens duplicadas. Pausa, ajuda e conclusão são estados da atividade medidos por eventos, não rotas artificiais. Timestamps e sessões nativas são administrados pelo SDK.

## Telas (`screen_view`)

| `screen_name` | Quando |
| --- | --- |
| `opening` | Abertura, quando já existe autorização válida |
| `playHome` | Lista de brincadeiras |
| `animals` | Exploração livre dos animais |
| `parents` | Área de responsáveis |
| `profileSelection` | Seleção visual após a abertura, inclusive com um perfil, ou troca na tela inicial; sem apelido ou perfil escolhido |
| `profileName` | Identificação ou edição do cartão; sem nome, apelido, texto digitado ou ID do perfil |
| `reportProfileSelection` | Busca/seleção de cartão para consulta ou edição; sem consulta digitada, nome ou ID do perfil |
| `gameMatching` | Jogo de associação |
| `gameLetters` | Jogo da letra inicial |
| `gameCounting` | Jogo de contagem |
| `gameSpeaking` | Jogo de nomeação por voz/toque |
| `gameClues` | Jogo de pistas e características |
| `gameStories` | Leitura compartilhada e perguntas sobre as histórias |
| `gameDrawing` | Desenho de contornos com verificação local |
| `accountLogin` | Formulário de entrada |
| `accountRegister` | Formulário de cadastro |
| `accountOverview` | Conta conectada |

O `screen_class` é `FlutterScreen`. A mesma tela não é registrada novamente por rebuild, alteração de som ou abertura de um diálogo. Voltar de uma rota registra a tela efetivamente exposta, incluindo a aba que estava selecionada.

## Eventos

Todos os eventos customizados incluem `schema_version = 1`. Eventos do jogo incluem `game_id`, `round_count` e `choice_count`. Eventos de rodada também incluem `round_index` (a partir de 1) e `animal_id`. Os IDs de jogos são `matching`, `letters`, `counting`, `speaking`, `clues`, `stories`, `drawing`; os de animais são `dog`, `cat`, `lion`, `elephant`. Os jogos reutilizam os eventos de início, resposta, dica, pausa, salto, abandono e conclusão; textos, imagens e pontos dos desenhos não são enviados. No desenho, `choice_count=0` indica ausência de alternativas e a resposta ocorre somente ao conferir a forma.

| Evento | Parâmetros específicos | Uso |
| --- | --- | --- |
| `opening_finished` | `reason`: completed/skipped | Ver conclusão ou salto da abertura |
| `navigation_selected` | `destination` | Navegação entre as três abas |
| `game_start` | Configuração do jogo | Preferências e distribuição de atividades |
| `round_start` | Rodada e animal | Início das descobertas |
| `answer_submitted` | `result`: correct/retry, `input_method`: touch/voice/drawing, `attempts`, `duration_ms` | Interações e tempo ativo até a resposta |
| `hint_used` | Rodada e animal | Uso da dica, uma vez por rodada |
| `round_skipped` | `attempts`, `duration_ms` | Rodadas puladas, separadas de acertos |
| `animal_counted` | `counted` | Marcação dos animais na contagem, sem contar toques repetidos no mesmo animal |
| `animal_sound_requested` | Animal; contexto do jogo quando aplicável | Pedidos de reprodução, inclusive quando o som está desligado |
| `speech_started` | Contexto da rodada | Solicitação de resposta por voz |
| `speech_finished` | `result`: recognized/no_match/unavailable/cancelled | Resultado categórico, sem transcrição |
| `media_unavailable` | `feature`: animal_audio/celebration_audio/speech | Indisponibilidade dos recursos |
| `game_paused` | `reason`: user/background | Pausas voluntárias ou de ciclo de vida |
| `game_resumed` | Contexto da rodada | Retomada explícita |
| `game_complete` | `correct_rounds`, `skipped_rounds`, `duration_ms` | Conclusão da sessão, distinguindo pulos |
| `game_abandoned` | Mesmos totais/duração da conclusão | Saída de sessão ainda incompleta |
| `settings_changed` | `setting`, `value` | Mudanças reais de som, movimento, alternativas ou rodadas |
| `progress_reset` | — | Limpeza do histórico local |
| `login` / `sign_up` | `method`: password | Entrada/cadastro bem-sucedidos, sem identificar a conta |
| `logout` | — | Saída da conta |
| `account_failure` | `operation`, `reason` categórico | Falhas conhecidas, sem mensagem bruta da exceção |
| `analytics_consent_granted` | Versão do schema | Ativação explícita da coleta |

Não se envia um evento de revogação após revogar, pois isso contrariaria a escolha de interromper o envio. Cancelamento/saída do app pode interromper a sequência de eventos de fala. O abandono por encerramento forçado do processo não é garantido; `dispose` não é um callback de encerramento do sistema.

`duration_ms` dos jogos mede tempo ativo e exclui pausas registradas. Rodada concluída não implica objetivo pedagógico dominado. Resultados de reconhecimento não medem pronúncia. Não há identificador próprio de criança/jogador ou correlação com Firebase Auth; análises de funil seguem o escopo de sessão/instalação do GA4.

## Propriedades de configuração

| Propriedade | Valores |
| --- | --- |
| `sound_enabled` | true / false |
| `reduced_motion` | true / false |
| `choice_count` | 2 / 3 |
| `round_count` | 4 / 6 |

São preferências do aplicativo, não classificações de diagnóstico ou perfis de uma criança.

## Configuração no console

1. No Firebase Console, abra `app-edu-ifpb` e confirme acesso ao projeto correto.
2. Em Configurações do projeto → Integrações → Google Analytics, confirme ou configure a vinculação com a propriedade GA4 desejada.
3. Confirme os fluxos Android (`com.example.animal_game`) e iOS, usando os bundle IDs reais do projeto. Não use o bundle de testes macOS como fluxo principal.
4. Se for necessário atualizar os arquivos de serviço, utilize o FlutterFire CLI com os apps existentes e revise o diff: `flutterfire configure --project=app-edu-ifpb --platforms=android,ios`. Não edite IDs de medição manualmente nem coloque uma API secret no aplicativo.
5. No GA4, registre as dimensões de evento necessárias para os relatórios: por exemplo `game_id`, `animal_id`, `input_method`, `result`, `reason`, `feature`, `destination`, `setting`, `operation`. Os parâmetros numéricos podem ser registrados como métricas customizadas, conforme a análise desejada.
6. Registre as quatro propriedades de configuração como dimensões de usuário se precisar utilizá-las nas explorações. Escolha retenção e acesso aos dados adequados ao contexto infantil; mantenha integrações de publicidade/Google Signals desativadas.
7. Monte um funil `game_start → round_start → answer_submitted → game_complete`, segmentado por `game_id`, e acompanhe `round_skipped`, `hint_used` e `game_abandoned` separadamente. Esses relatórios são de uso do produto.

Não foram criados relatórios, dimensões, propriedades ou fluxos em contas remotas nesta execução, pois não há acesso administrativo ao console.

## DebugView

Em um aparelho Android conectado, habilite o modo de depuração do SDK:

```sh
adb shell setprop debug.firebase.analytics.app com.example.animal_game
```

Abra o app e, antes de autorizar, confirme que o app não transmite os eventos customizados. Autorize na área de responsáveis e confira no DebugView as telas, um jogo, uma dica, uma resposta por toque, uma resposta por voz, uma pausa e uma saída antecipada. O primeiro consentimento não envia retroativamente as telas da abertura já vistas.

Desative o compartilhamento e confirme que novas interações não geram eventos. Para sair do modo de depuração:

```sh
adb shell setprop debug.firebase.analytics.app .none.
```

No iOS, use o argumento `-FIRDebugEnabled` no esquema de execução do Xcode; remova-o ou use `-FIRDebugDisabled` ao encerrar a verificação. Mantenha esses argumentos fora de builds de distribuição.

Relatórios consolidados podem demorar; DebugView é a ferramenta de verificação de desenvolvimento. Os testes locais usam fakes e não comprovam ingestão pelo Google.

## Referências oficiais

- [Flutter: configurar Firebase](https://firebase.google.com/docs/flutter/setup).
- [Rastreamento de telas](https://firebase.google.com/docs/analytics/screenviews).
- [Coleta Android](https://firebase.google.com/docs/analytics/android/configure-data-collection).
- [Coleta Apple, IDFA e IDFV](https://firebase.google.com/docs/analytics/ios/configure-data-collection).
- [Consent Mode para apps](https://developers.google.com/tag-platform/security/guides/app-consent).
- [DebugView](https://firebase.google.com/docs/analytics/debugview).

APIs verificadas também no código instalado de `firebase_analytics` 13.0.1. Consultado em 04/11/2026.
