# Educação, acessibilidade e decisões de produto

## Público e limites

Bicho a Bicho é um recurso lúdico complementar para explorar animais. A referência curricular inicial é a Educação Infantil, especialmente a faixa de 4 a 5 anos e 11 meses da BNCC. A escolha de atividades deve considerar os interesses, a comunicação e o contexto de cada criança; a faixa curricular não é uma avaliação de desenvolvimento.

O app foi projetado com atenção a crianças com TEA, mas ainda não passou por estudo de usabilidade com esse público, validação pedagógica independente ou ensaio de eficácia. Não realiza diagnóstico, terapia ou avaliação de fala. Não se presume que crianças com TEA tenham as mesmas preferências sensoriais.

## Relação com referências oficiais

As correspondências abaixo são propostas de design pedagógico, não certificação pelo MEC nem evidência de aprendizagem produzida pelo aplicativo. A atividade digital cobre somente aspectos dos objetivos e não substitui experiências concretas, brincadeiras e mediação.

| Atividade | Intenção | Relação proposta com a BNCC | Limite |
| --- | --- | --- | --- |
| Encontre o bichinho | Comparar uma referência visual com alternativas | EI03ET05: exploração de semelhanças e diferenças entre figuras | O jogo faz pareamento, não cobre todo o objetivo de classificação |
| Vamos contar? | Contar grupos de 1 a 4 e associar a um numeral; o toque marca objetos já contados | Aspecto de correspondência número–quantidade de EI03ET07 | Não trabalha antes/depois/entre nem comprova domínio do objetivo |
| Olá, bichinho! | Oferecer nomeação oral ou seleção por imagem em uma situação compartilhada | Diálogo parcial com EI03EF01 e suas múltiplas formas de expressão | Nomeação isolada não equivale à expressão de ideias e sentimentos prevista no objetivo |
| A letra do bicho | Explorar a letra inicial e o nome de animais familiares | Campo “Escuta, fala, pensamento e imaginação” | Não é um programa de alfabetização nem avaliação fonológica; não recebe código de equivalência integral |
| Bichinhos | Explorar imagens e sons com um adulto | Campo “Traços, sons, cores e formas” | Ouvir sons isolados não cobre as produções e qualidades sonoras de todos os objetivos do campo |

Fonte primária: [BNCC — MEC](https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf), Educação Infantil, páginas impressas 35–53. Consultada em 04/11/2026.

## Novas atividades pesquisadas

**Desenhe o bichinho** oferece desenho de contornos com dica visual opcional. A verificação compara formas locais e não avalia coordenação motora ou habilidade artística. O desenho dirigido é uma exploração parcial do campo “Traços, sons, cores e formas”; não substitui expressão livre. Os [critérios, limitações e relação com a BNCC](DRAWING_GAME.md) estão documentados. Quem preferir pode pedir ajuda ou escolher outra atividade.

**Detetive dos bichos** adapta a escolha por descrição. **Histórias da turma** oferece quatro narrativas originais com duas cenas e uma pergunta sobre quem realizou uma ação. As duas atividades têm instruções de leitura compartilhada e resposta por imagem. As histórias permanecem disponíveis para consulta, inclusive após acertar. A relação curricular é parcial: responder sobre personagens e fatos se aproxima de um aspecto de EI02EF04, sem equivalência a todos os objetivos ou inferência sobre desenvolvimento. As [fontes, critérios de seleção e propostas de mediação](EDUCATIONAL_ACTIVITIES_RESEARCH.md) estão documentados.

## Acessibilidade aplicada nos jogos

- Instrução curta antes da ação; uma tarefa por rodada.
- Duas alternativas por padrão, três quando selecionado pelo responsável.
- Alternativas estáveis durante a rodada; ordem e distratores são definidos no início, fora de `build`.
- Próxima rodada por ação explícita. Nenhum cronômetro, perda de pontos, penalidade ou avanço automático.
- Dica e opção de pular sempre disponíveis antes de acertar.
- Pausa sem pressão; ao sair do primeiro plano, recursos de mídia são interrompidos e a atividade espera uma retomada explícita.
- Fala opcional, com resposta por toque equivalente. Resultados intermediários não são julgados. Falha no reconhecimento não é tratada como erro da criança.
- Som inicialmente desligado, volume do player limitado a 35%, reprodução somente sob ação explícita. O volume do aparelho também influencia a intensidade percebida.
- Sem música de fundo, flashes ou GIFs de comemoração. Transições reduzidas por padrão, respeitando também a preferência do sistema.
- Comemoração finita por acerto: movimento leve do animal, estrelas/corações e um arpejo original de 1,7 segundo quando o som está ligado. Com movimento reduzido, a composição permanece estática. O efeito não bloqueia o botão de continuar nem altera a rodada automaticamente.
- Abertura com entrada sequencial dos quatro animais, sem áudio automático. Pode ser pulada e mostra uma composição estática pelo mesmo tempo quando há movimento reduzido. Pausar o app suspende a apresentação.
- Botões identificados, ações semânticas nos cartões, feedback anunciado por região acessível e layouts roláveis para texto ampliado.
- Paleta de fundo creme, verde e cores de apoio suaves; ícones e texto acompanham o feedback para não depender apenas de cor.

Referências de design: [W3C — instruções claras](https://www.w3.org/WAI/WCAG2/supplemental/patterns/o4p07-step-instructions/), [etapas reconhecíveis](https://www.w3.org/WAI/WCAG2/supplemental/patterns/o1p04-clear-steps/), [redução de distrações](https://www.w3.org/WAI/WCAG2/supplemental/objectives/o5-user-focus/) e [personalização](https://www.w3.org/WAI/WCAG2/supplemental/patterns/o8p04-interface/). São orientações suplementares de acessibilidade cognitiva; sua aplicação não constitui certificação WCAG.

## Registro e privacidade

O [acompanhamento dos responsáveis](PARENT_PROGRESS.md) registra erros, acertos e dicas em cartões locais sem quantidade fixa, sem exigir conta. Os números são observações das brincadeiras, não uma escala de desenvolvimento. Os filtros preservam a configuração da rodada e o ranking exibe sua amostra. O animal é o alvo da pergunta, inclusive quando a habilidade envolve números, letras ou histórias. A escolha do cartão acontece na entrada, com ajuda de um adulto quando necessário; o app não identifica automaticamente a criança. Os perfis e seus relatórios não são vinculados à conta ou ao GA4.

Há uma integração GA4 opcional, desligada por padrão, descrita em [ANALYTICS.md](ANALYTICS.md). Com autorização do responsável, eventos futuros de uso, configurações e dados automáticos do SDK são enviados ao Google com identificador pseudônimo da instalação. Não se vinculam à conta ou a uma criança identificada. Os parágrafos abaixo descrevem o histórico persistido pelo aplicativo, que não é enviado retroativamente ao Analytics.

Preferências e quantidade de sessões concluídas ficam no dispositivo, sem nome ou idade da criança. Conclusão inclui rodadas puladas: o histórico representa uso do recurso, não acertos, evolução clínica ou domínio pedagógico. Sessões abandonadas não são registradas. Não há sincronização entre dispositivos.

O reconhecimento de fala é fornecido pelo sistema operacional/navegador, solicitado somente após tocar em “Quero falar”. Pode usar rede e processamento do provedor. O aplicativo não grava nem persiste o áudio. A alternativa por toque evita a necessidade do microfone.

O cadastro é opcional e destinado ao responsável. Firebase Authentication gerencia a credencial; o app não escreve senha no Realtime Database. Registros legados criados pela versão anterior não foram acessados nem apagados. O administrador do projeto deve verificar e remover campos de senha legados e avaliar a redefinição das credenciais afetadas antes de distribuir a nova versão.

## Validação com pessoas antes da distribuição

Conduzir sessões acompanhadas por responsáveis e profissionais de educação, observando compreensão das instruções, seleção dos botões, interesse pelos animais, conforto com os sons e facilidade para pausar. Começar com os ajustes padrão, permitir recusa e escolher as adaptações com a criança. Testar TalkBack e VoiceOver em aparelhos reais, incluindo permissão negada, interrupções do app e texto ampliado.

As verificações automatizadas não substituem essa avaliação de adequação individual.
