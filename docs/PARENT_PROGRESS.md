# Acompanhamento para responsáveis

## Acesso e perfis

O painel fica em **Responsáveis**, sem exigir login. A conta Firebase permanece opcional e não sincroniza este relatório. Após entrar na conta, “Voltar aos responsáveis” retorna à área que contém o acompanhamento. A área local pode ser vista por quem tem acesso ao app no aparelho.

Depois da abertura de 5 segundos, o app **sempre apresenta “Quem vai brincar?”**. Qualquer pessoa pode tocar em **Novo cartão**, escolher cachorro, gato, leão ou elefante e informar um nome se quiser. Não há limite fixo de cartões, nem configuração de quantidade na área dos responsáveis. O cartão inicial também pode ser personalizado. Nomes são opcionais, limitados a 24 caracteres e salvos localmente; não é necessário informar nome completo, idade ou diagnóstico.

Os cartões têm imagens grandes, cores, nome opcional e um número próprio. Nomes e animais podem se repetir; o número distingue cartões parecidos. A busca filtra por nome, animal ou número. A grade constrói os cartões sob demanda, sem renderizar todos os usuários de uma vez. A confirmação da escolha não é restaurada do disco: o app pede novamente na próxima inicialização. Voltar de jogos ou retomar a mesma execução mantém a escolha. O botão **Trocar** na tela inicial está sempre disponível para escolher outro cartão ou criar um novo; cancelar mantém o cartão atual.

### Criar e editar cartões

**Novo cartão** abre uma página com imagem, escolha entre os quatro animais e campo **Nome ou apelido (opcional)**. **Salvar e brincar** aceita o campo vazio e cria um cartão independente. **Continuar sem nome** também utiliza o nome padrão do bichinho. O cartão inicial ou um cartão antigo ainda não identificado usa a mesma página na primeira escolha. Um responsável pode ajudar, mas não é exigido login ou autorização na área de responsáveis para criar cartões.

Nas próximas entradas, tocar no cartão abre as brincadeiras sem redigitação. Na área dos responsáveis, **Editar cartão** abre uma seleção com busca e depois a mesma página de nome/animal. Alterar nome ou animal mantém o identificador e o histórico; criar outro cartão sempre gera um novo identificador, mesmo com nome e animal iguais. Nomes e apelidos não são enviados ao GA4, à conta Firebase ou a outros serviços do app.

Voltar da página antes de salvar permite escolher outro animal. Falhas de gravação mantêm a página aberta com mensagem para tentar novamente. Nomes antigos já preenchidos são tratados como configurados; o indicador de configuração também é salvo para os cartões que optaram por continuar sem nome.

O app não identifica automaticamente quem está usando: escolher o mesmo cartão soma os registros. O jogo captura o identificador ao abrir e não transfere respostas caso a seleção mude depois. Consultar outro cartão no relatório usa a seleção com busca e **não altera quem está brincando**. As preferências continuam compartilhadas. A migração preserva os IDs, nomes e históricos antigos, incluindo cartões anteriormente desabilitados com identificação ou uso. Os novos números são gerados em sequência e não dependem da posição ou do animal do cartão.

## Métricas

| Indicador | Regra |
| --- | --- |
| Rodadas abertas | Uma por entrada na rodada, mesmo se interrompida |
| Rodadas respondidas | Uma na primeira resposta válida, certa ou errada |
| Tentativas incorretas | Cada resposta diferente da esperada, inclusive repetição da mesma opção |
| Rodadas com erro | Uma por rodada com tentativa incorreta, sem duplicar novas tentativas |
| Rodadas resolvidas | Uma por resposta correta, mesmo depois de erro ou dica |
| Acertos na primeira tentativa | Resposta correta sem tentativa incorreta anterior; pode ter havido dica |
| Rodadas com dica | Uma por rodada em que a dica foi solicitada |
| Rodadas puladas | Avanço sem acertar; não acrescenta erro, mas preserva tentativas anteriores |

Pausas, falhas de mídia e reconhecimento de voz sem correspondência não são erros. A sessão não precisa terminar para suas interações serem salvas. O registro não acrescenta penalidades aos jogos.

O ranking ordena **rodadas com erro ÷ rodadas respondidas**, depois a quantidade de rodadas com erro e o nome do animal para desempates. Exibe a amostra e as tentativas incorretas. Uma única observação pode produzir 100%; não há classificação de dificuldade leve, moderada ou grave. O animal é o alvo da pergunta, não o distrator escolhido. Em letras, contagem e histórias, o erro pode estar ligado a outras habilidades, sem indicar dificuldade em reconhecer aquele animal.

Filtros por jogo e duas/três alternativas usam a configuração original da rodada. “Desenho sem alternativas” filtra o jogo de desenho (`choices=0`). Nesse jogo, uma tentativa ocorre ao conferir uma forma não vazia; conferir sem editar não duplica a tentativa. A dica é o contorno de ajuda. O erro indica apenas que a forma não atingiu o critério do jogo, sem medir coordenação motora ou habilidade artística. Os valores são acumulados desde o início do registro ou a última limpeza; não há comparação temporal. As contagens antigas de sessões concluídas continuam agregadas por aparelho na seção original. Erros de versões anteriores não são reconstruídos.

## Limpeza e persistência

A limpeza de um perfil exige confirmação e remove seus contadores, preservando os demais cartões e os ajustes. “Apagar histórico local” limpa as contagens antigas e o acompanhamento de todos os cartões, com confirmação; os nomes, animais e identificadores continuam disponíveis. Limpar o relatório não apaga eventos GA4 já enviados.

`ProfileCatalog` é um modelo imutável com identificadores estáveis, próximo número disponível e JSON versionado. Não limita a quantidade de usuários. `LearningHistory` guarda agregados por identificador, jogo, animal e alternativas: até 52 combinações atuais por cartão, sem um histórico crescente de cada tentativa. O volume cresce com os cartões e seus agregados, sujeito ao armazenamento do aparelho. `AppSettings` usa a fila de persistência existente; o catálogo fica em `profile_catalog`, com nomes e animais no mesmo documento. Os campos antigos são lidos somente para migração. Nenhuma nova dependência foi adicionada.

Falhas de leitura ou gravação aparecem na interface. Os contadores atuais ficam em memória e há um botão para tentar salvar novamente. O [shared_preferences 2.5.6](https://pub.dev/packages/shared_preferences) serve a estes pequenos agregados, mas não garante durabilidade diante de encerramento abrupto nem se destina a registros clínicos ou dados críticos. Desinstalar ou limpar os dados do app pode apagar o acompanhamento. Não há sincronização entre dispositivos ou criptografia adicional do relatório.

O painel funciona com GA4 desligado e não envia perfis, histórico acumulado ou ranking à conta/Firebase. Os eventos opcionais dos jogos continuam seguindo [ANALYTICS.md](ANALYTICS.md), sem vincular um perfil local ou identidade infantil.

## Arquivos e validação

`presentation/profile_name_page.dart` concentra imagem, campo validado, gravação, opção sem nome e tratamento de erro. `profile_selection_page.dart` abre essa página apenas na primeira identificação; `profile_settings_card.dart` reutiliza-a na edição. `AppSettings` e `PreferencesRepository` persistem o nome e a configuração do cartão. `test/profile_name_test.dart` verifica restauração, configuração sem nome, migração de apelidos, cancelamento, escolha de outro animal, falha/retry e texto ampliado. A captura está em `docs/previews/profile_name.png`.

O fluxo usa `lib/app/learner_entry.dart`, `lib/features/progress/domain/profile_catalog.dart`, `presentation/profile_selection_page.dart` e `presentation/profile_settings_card.dart`. `test/profile_catalog_test.dart` cobre criação concorrente/restauração de 128 cartões novos, nomes e animais repetidos, identificadores acima de três, migração e validação do catálogo. `test/profile_flow_test.dart` cobre criação pública, nome vazio, busca, troca, edição de animal e texto ampliado. Nenhum nome ou identificador é enviado ao Analytics; `profileSelection`, `profileName` e `reportProfileSelection` são nomes genéricos de telas.

- `lib/features/progress/domain/learning_history.dart`: contadores, serialização, filtros e ranking.
- `lib/features/progress/presentation/learning_report.dart`: perfis, filtros, métricas, ajuda e limpeza.
- `lib/features/games/presentation/game_view_model.dart` e `game_page.dart`: observações e proteção contra respostas durante avanço, pausa ou descarte.
- `lib/features/settings/presentation/app_settings.dart` e `data/preferences_repository.dart`: composição, persistência e restauração.
- `lib/features/settings/presentation/parent_page.dart`, `lib/features/home/presentation/home_page.dart` e `lib/features/account/presentation/account_page.dart`: acesso e indicação do perfil ativo.
- `test/learning_progress_test.dart`, `test/learning_report_test.dart` e `test/widget_test.dart`: regras, falhas, perfis, navegação, filtros e texto ampliado.

Foram acrescentados sete testes unitários e cinco de widgets, incluindo restauração após abandono, erro repetido, primeiro acerto, dicas duplicadas, falhas de voz/armazenamento, ranking proporcional, filtros e limpeza. Os números apoiam a observação por familiares e educadores; não medem desenvolvimento ou dificuldade clínica.
