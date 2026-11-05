# Pesquisa e seleção de brincadeiras

Consulta em 04/11/2026. Foram selecionadas duas adaptações para o catálogo existente, com os mesmos ajustes de alternativas, duração da sessão, pausa, dicas e comemorações. O foco é oferecer oportunidades de brincar e conversar com mediação, sem avaliar desenvolvimento ou atribuir uma habilidade a toda criança com TEA.

## Referências consultadas

- [SED/SC — Recursos Digitais de Aprendizagem: Educação Especial](https://www.sed.sc.gov.br/programas-e-projetos/recursos-digitais-de-aprendizagem/recursos-digitais-de-aprendizagem-educacao-especial/). A seção destinada ao TEA reúne sugestões de adivinhação por descrição e narrativas curtas apoiadas em figuras. É uma curadoria de propostas, incluindo material do Instituto Itard, não um estudo de eficácia.
- [Instituto Itard — Contação de histórias para alunos com autismo](https://institutoitard.com.br/contacao-de-historias-7-dicas-para-incluir-alunos-com-autismo/), origem indicada pela SED/SC: interesses da criança, cartões ilustrados e histórias breves orientaram nossa adaptação. Não reproduzimos sua história de exemplo.
- [Department of Education, Queensland — Visual supports](https://autismhub.education.qld.gov.au/resource/fba-tool/Pages/visual-supports.aspx). Referência para combinar figuras e linguagem simples e escolher apoios conforme a compreensão individual. Ilustrações não são necessariamente compreendidas por todas as crianças; pode ser preciso começar com objetos ou fotos.
- [BNCC — MEC](https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf), página impressa 49, campo “Escuta, fala, pensamento e imaginação”. Responder sobre personagens e acontecimentos se aproxima de um aspecto de EI02EF04; não é equivalência integral nem classificação da criança por idade. Para EI03EF04, reconto e planejamento coletivo precisam de experiências adicionais fora do jogo.

## Atividades implementadas

| Jogo | Proposta e adaptação | Mediação sugerida |
| --- | --- | --- |
| Detetive dos bichos | Uma pista textual sobre som ou característica e duas/três imagens. A referência com a resposta não é exibida antes do acerto. | Leia a pista, compare as imagens e aceite indicação por gesto; selecione a opção indicada se necessário. Com brinquedos, experimente a mesma brincadeira fora da tela. |
| Histórias da turma | Quatro situações originais de faz de conta: bola, livro, água e desenho. Cada rodada mostra duas cenas com animal, símbolo da ação e frase; pergunta quem realizou uma ação explícita. | Leia as cenas e a pergunta. Permita consultar tudo novamente e responder por imagem. Depois, convide a criança a brincar ou recontar do jeito que preferir, se desejar. |

As narrativas foram escritas para o app, sem trechos ou personagens de livros comerciais. Os animais atuam como personagens de faz de conta; suas ações não ensinam hábitos zoológicos. As figuras dos animais já existentes são reutilizadas, acompanhadas por ícones de objetos. Os símbolos são apoios à leitura compartilhada, não substitutos garantidos de uma cena concreta nem um sistema de comunicação alternativa validado.

## Critérios de implementação

- Uma pergunta por rodada, sem limite de tempo, competição ou punição.
- Leitura compartilhada explicitada na instrução; não há narração automática. Som desligado não impede a atividade.
- Alternativas definidas no início da rodada e mantidas após erros e dicas.
- Nas histórias, os dois personagens sempre constam das opções, inclusive com apenas duas alternativas. A posição do personagem da resposta varia entre as cenas; os botões são embaralhados na criação da sessão.
- História disponível antes e depois do acerto; não é um teste de memorização de texto oculto.
- Resposta por toque, sem exigência de microfone, fala, contato visual ou interpretação de emoções.
- Histórico de sessões e eventos opcionais de uso seguem os contratos existentes. Não representam aprendizagem, diagnóstico ou eficácia terapêutica.

Pareamento, contagem, letras e exploração de sons foram preservados. Quebra-cabeças e jogos de memória também aparecem na curadoria consultada, mas não foram adicionados nesta seleção: leitura compartilhada e pistas trazem duas experiências diferentes com o conjunto de animais atual.

## Avaliação pedagógica posterior

Antes de distribuir para escolas, acompanhar sessões com educadores, familiares e crianças, permitindo recusa e pausa. Observar se os símbolos e as pistas fazem sentido para cada criança, se as duas cenas são suficientes e se é necessário usar fotografias, objetos concretos ou menos texto. O app não foi validado clinicamente nem certificado pelo MEC; as referências fundamentam escolhas de design e não demonstram resultados desta implementação.

## Arquivos e decisões técnicas

- `lib/features/games/domain/game_definition.dart`, `game_session.dart` e o novo `animal_story.dart`: catálogo, geração de alternativas e conteúdo independente de Flutter.
- `lib/features/games/presentation/game_round_view.dart` e o novo `widgets/story_prompt.dart`: pistas, cenas adaptáveis, pergunta, dicas e manutenção da história após o acerto.
- `lib/features/home/presentation/home_page.dart`: acesso aos novos jogos e aparência associada ao tipo da atividade.
- `lib/features/settings/data/preferences_repository.dart`, `presentation/app_settings.dart` e `presentation/parent_page.dart`: persistência das novas contagens sem trocar as chaves existentes e orientações para adultos.
- `lib/core/analytics/usage_analytics.dart`: telas e IDs permitidos dos novos jogos. O consentimento e a coleta mínima existentes são preservados.
- Novo `test/educational_games_test.dart` e `test/widget_test.dart`: coerência das histórias, navegação, persistência, eventos e fluxos dos seis jogos.
- `README.md`, `docs/ARCHITECTURE.md`, `docs/ANALYTICS.md`, `docs/EDUCATION_AND_ACCESSIBILITY.md`, `docs/VALIDATION.md` e este documento: experiência, fontes, contratos e resultados. Capturas novas em `docs/previews/game_clues.png` e `game_stories.png`.

Sem novas dependências. O gerenciamento de estado continua com ChangeNotifier e injeção por construtor; os jogos reutilizam as regras de sessão, pausa e comemoração. Validação desta entrega: 112 testes aprovados, formatação e análise sem problemas, APK debug e build web release gerados. As capturas foram inspecionadas visualmente; não houve teste em aparelho físico ou com crianças nesta execução.
