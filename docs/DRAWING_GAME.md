# Desenhe o bichinho

## Experiência

O sétimo jogo oferece quatro contornos originais e simplificados: cachorro, gato, leão e elefante. A criança observa um modelo e desenha seu contorno em um quadro com o dedo, mouse ou caneta. A dica exibe um contorno tracejado para acompanhar. Desfazer remove o último traço; limpar permite recomeçar. Não há limite de tempo ou avanço automático.

“Conferir desenho” verifica a forma e, se aceita, mostra a comemoração existente, com música quando o som estiver habilitado. Desenhar continua livre até conferir. Se o contorno não atender aos critérios, o quadro é preservado e a criança pode acrescentar traços, pedir ajuda, limpar ou pular. Olhos e outros detalhes não são exigidos. Pausa e retorno do segundo plano preservam o quadro; avançar ou sair descarta os traços.

## Comparação geométrica local

`DrawingEvaluator` é uma implementação própria em Dart, sem serviço remoto, modelo de IA ou novas dependências. Compara traços com os quatro modelos vetoriais do jogo; não reconhece arbitrariamente fotografias ou desenhos em estilos diferentes.

1. Desconsidera traços isolados sem comprimento para comparar o contorno e rejeita entradas insuficientes ou com largura/altura inferiores a 15% do quadro.
2. Reamostra os segmentos em 128 pontos distribuídos pelo comprimento, sem criar linhas entre traços separados.
3. Centraliza as formas e normaliza o tamanho uniformemente, preservando sua proporção.
4. Experimenta espelhamento horizontal e rotações pequenas de −10°, 0° e 10°.
5. Exige ao menos 76% dos pontos do modelo próximos ao desenho, 78% dos pontos do desenho próximos ao modelo e proximidade de pelo menos dois de três pontos característicos. A distância do contorno é de até 7,5% do maior eixo normalizado; a dos pontos característicos, 9,5%.

Essas porcentagens são critérios internos de proximidade geométrica, não porcentagem de semelhança artística, nota ou probabilidade de acerto. A interface não apresenta uma pontuação numérica à criança. Os testes incluem contornos perturbados, traduzidos, redimensionados e espelhados; rejeição de linhas, círculos, retângulos, rabiscos densos e contornos dos outros modelos. Esses testes sintéticos não demonstram desempenho com desenhos reais de crianças. A tolerância ainda precisa ser observada e ajustada em sessões acompanhadas.

A pesquisa sobre [reconhecimento de gestos por nuvens de pontos — $P](https://depts.washington.edu/acelab/proj/dollar/pdollar.html) foi consultada como referência conceitual. Nosso comparador usa distância de vizinhança e cobertura, não implementa o algoritmo $P nem utiliza seu código.

## Entrada, desempenho e privacidade

O quadro usa [RawGestureDetector](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html), [EagerGestureRecognizer](https://api.flutter.dev/flutter/gestures/EagerGestureRecognizer-class.html) e eventos de ponteiro para priorizar o desenho sobre a rolagem. A página continua rolável fora do quadro. Somente um ponteiro desenha; contatos adicionais são ignorados. Sair dos limites encerra o traço para impedir linhas artificiais na borda.

O limite de memória é de 64 traços e 4.096 pontos por rodada. O [CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html) repinta pelo controller, sem reconstruir a página inteira a cada ponto. A comparação ocorre apenas ao conferir e usa 128 amostras. Os traços ficam em memória, são descartados ao sair e não são persistidos, exportados ou enviados ao Analytics.

## Acompanhamento

O perfil escolhido na entrada continua vinculado à sessão. Tentativas contam somente ao conferir um desenho não vazio; conferir repetidamente sem alterá-lo não duplica o registro. Limpar, desfazer e pedir dica não contam como erro. O contorno de ajuda conta como dica. O sucesso e a comemoração são únicos por rodada.

O jogo utiliza `game_id=drawing`, tela `gameDrawing`, `input_method=drawing` e `choice_count=0`. Esse zero indica ausência de alternativas e está disponível no filtro “Desenho sem alternativas” do relatório. O histórico versionado permanece compatível com os jogos anteriores. Apenas agregados existentes são guardados; o gráfico ou os pontos do desenho não fazem parte do relatório nem dos eventos GA4.

Um erro aqui significa que a forma não atingiu o critério do jogo. Não mede habilidade artística, coordenação motora ou dificuldade clínica.

## Referência pedagógica e arquivos

A [BNCC, campo Traços, sons, cores e formas, EI03TS02](https://basenacionalcomum.mec.gov.br/images/BNCC_EI_EF_110518_versaofinal_site.pdf), página impressa 48, contempla expressão por desenho e outras produções. Reproduzir um modelo com critério de vitória é uma atividade dirigida e cobre apenas uma experiência limitada; não equivale à expressão livre completa do objetivo. Convém oferecer também desenho livre em papel e aceitar recusa ou outra brincadeira. Não há certificação pelo MEC ou validação clínica desta atividade.

- `lib/features/games/domain/drawing_template.dart` e `drawing_evaluator.dart`: modelos vetoriais e critérios independentes de Flutter.
- `lib/features/games/presentation/drawing_controller.dart` e `drawing_round_view.dart`: traços, controles, quadro e pintura.
- `game_view_model.dart`, `game_page.dart`, `domain/game_definition.dart` e `game_session.dart`: sessão, vitória, pausa, catálogo e ausência de alternativas fictícias.
- `lib/features/home/presentation/home_page.dart`, `lib/core/analytics/usage_analytics.dart`, `lib/features/progress/domain/learning_history.dart` e `presentation/learning_report.dart`: acesso, telemetria, persistência e filtro.
- `test/drawing_evaluator_test.dart`, `drawing_game_test.dart`, `drawing_widget_test.dart`, `game_session_test.dart` e `widget_test.dart`: comparação, limites, interações, pausa, perfil e comemoração.
