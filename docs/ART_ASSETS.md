# Identidade e arte

Nome: **Bicho a Bicho**. Proposta: descobertas pequenas, previsíveis e compartilhadas. Marca em texto e símbolo de pata Material; tipografia Nunito distribuída localmente sob SIL Open Font License, com licença em `fonts/OFL-Nunito.txt`.

As cinco ilustrações foram criadas com a ferramenta integrada ImageGen, sem CLI ou chave de API fornecida pelo usuário. Os arquivos originais anteriores foram preservados. A imagem de boas-vindas é decorativa; os animais das atividades possuem rótulos semânticos.

## Arquivos utilizados

- `assets/welcome.png`: turma de boas-vindas.
- `assets/animal_dog.png`: cachorro.
- `assets/animal_cat.png`: gato.
- `assets/animal_lion.png`: leão.
- `assets/animal_elephant.png`: elefante.

O áudio `assets/celebration.wav` é uma composição original curta, um arpejo maior sintetizado localmente em PCM mono de 44,1 kHz e 16 bits. Possui ataque e final suaves, sem sample externo ou gravação de terceiros. Pode ser regenerado com `dart run tool/generate_celebration_sound.dart`. Os animais existentes são animados por transformações nativas do Flutter; não foram necessárias novas imagens ou GIFs.

## Prompt de boas-vindas

> Use case: illustration-story. Asset type: landscape welcome illustration inside a children's educational animal game. Create a beautifully art-directed, gentle children's picture-book illustration. A friendly baby golden lion with rounded mane, a small warm brown puppy, a soft gray-blue baby elephant, and a ginger kitten sit together on a simple pale sage green meadow, a few rounded leaves, cream sky. Soft gouache and matte paper texture, simplified rounded silhouettes, expressive kind eyes, muted terracotta, butter yellow, sage, teal. Welcoming and playful yet calm, generous negative space, no busy patterns, no glaring colors. Wide landscape composition approximately 3:2, all animals fully visible, recognizable, non-overlapping faces. No text, lettering, logos, watermarks, or UI.

## Prompts dos animais

Referência de estilo: `assets/welcome.png`. Fundo transparente habilitado. Uma chamada independente por animal, com o seguinte prompt e as substituições da tabela:

> Use case: illustration-story. Asset type: standalone animal cutout for a children's educational game. Reference image role: style reference only, not an edit target. Create ONE {subject}, full body seated facing the viewer, clearly recognizable, gentle friendly smile, expressive kind eyes. Match the reference's soft gouache, matte paper texture and warm muted palette. Simple rounded silhouette, generous empty padding, entire animal visible, no overlap. No other animals, no hearts, speech bubbles, text, props, scenery, ground, logos, or watermark. Actual transparent background. The animal must remain recognizable at 80 pixels. Square composition.

| Arquivo | Valor de `{subject}` |
| --- | --- |
| animal_dog.png | a small warm brown baby puppy with floppy ears |
| animal_cat.png | a ginger baby kitten with tiny whiskers and pointed ears |
| animal_lion.png | a golden baby lion with a soft rounded terracotta mane |
| animal_elephant.png | a gray-blue baby elephant with large round ears and a recognizable trunk |

Os ícones de instalação Android, iOS, macOS, Windows e Web foram exportados a partir do mesmo símbolo de pata Material usado no aplicativo. O utilitário `tool/generate_brand_icons.dart` renderiza o ícone em cada resolução exigida pelas plataformas, com fundo opaco e margem para máscaras de instalação. Essa parte da identidade é nativa em código, sem editar as ilustrações raster.
