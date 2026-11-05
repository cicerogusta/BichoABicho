# Ampliação do catálogo

Vaca, cavalo, ovelha e pato ampliam o catálogo de quatro para oito animais. As ilustrações transparentes foram geradas com imagegen usando o cachorro existente como referência de estilo. Os sons são gravações de animais, incluídas no aplicativo para reprodução offline. Autoria, fontes, alterações e licenças estão em [audio_credits.txt](../assets/audio_credits.txt), também acessíveis em Responsáveis → Licenças e créditos → Sons dos animais.

Os oito animais participam da exploração, abertura, cartões e jogos de associação, letras, contagem, fala, pistas e histórias. O desenho continua com os quatro contornos existentes: acrescentar uma ilustração não fornece um contorno validado para o avaliador geométrico. As rodadas desse jogo filtram os animais com molde disponível. A letra C é uma única alternativa mesmo com Cachorro e Cavalo no catálogo.

## Preparação dos sons

Baixar os originais para `build/animal_audio_sources/`:

| Arquivo local | Original |
| --- | --- |
| cow.ogg | https://upload.wikimedia.org/wikipedia/commons/4/48/Mudchute_cow_1.ogg |
| horse.ogg | https://upload.wikimedia.org/wikipedia/commons/d/db/Wiehern.ogg |
| sheep.ogg | https://upload.wikimedia.org/wikipedia/commons/2/28/Sheep_bleat.ogg |
| duck.wav | https://www.mediacollege.com/downloads/sound-effects/animals/bird/duck/duck-01.wav |

Executar `python tool/prepare_animal_audio.py` com numpy e soundfile disponíveis. Essas são ferramentas de preparação, sem dependências novas no app. A conversão mantém a duração, usa WAV PCM16 mono a 22050 Hz, limita pico a 0,65 e ganho a 8, aplica fade de 12 ms e padding de 80 ms. O volume de reprodução do aplicativo continua em 0,35, respeitando a preferência de som. A adaptação cow.wav é distribuída em CC BY-SA 3.0; preservar seus créditos e licença ao redistribuir.
