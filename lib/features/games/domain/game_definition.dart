enum GameKind { matching, letters, counting, speaking, clues, stories, drawing }

class GameDefinition {
  const GameDefinition(
    this.kind,
    this.title,
    this.subtitle,
    this.instruction,
    this.skill,
  );
  final GameKind kind;
  final String title;
  final String subtitle;
  final String instruction;
  final String skill;
}

const games = [
  GameDefinition(
    GameKind.matching,
    'Encontre o bichinho',
    'Observe, descubra e associe',
    'Toque no bichinho igual ao da imagem.',
    'Associação visual',
  ),
  GameDefinition(
    GameKind.letters,
    'A letra do bicho',
    'Uma descoberta de cada vez',
    'Toque na letra que completa o nome.',
    'Letras e nomes',
  ),
  GameDefinition(
    GameKind.counting,
    'Vamos contar?',
    'Pequenos grupos, grandes descobertas',
    'Conte os bichinhos. Toque no número.',
    'Quantidades de 1 a 4',
  ),
  GameDefinition(
    GameKind.speaking,
    'Olá, bichinho!',
    'Fale ou escolha: os dois valem',
    'Diga o nome do bichinho ou toque na resposta.',
    'Expressão e reconhecimento',
  ),
  GameDefinition(
    GameKind.clues,
    'Detetive dos bichos',
    'Uma pista para uma descoberta',
    'Leia com alguém. Qual bichinho combina com a pista?',
    'Pistas e características',
  ),
  GameDefinition(
    GameKind.stories,
    'Histórias da turma',
    'Pequenas histórias para ler juntos',
    'Leia com alguém. Depois, toque na resposta.',
    'Escuta e compreensão',
  ),
  GameDefinition(
    GameKind.drawing,
    'Desenhe o bichinho',
    'Seu traço dá vida à turma',
    'Observe o modelo e desenhe o contorno com o dedo.',
    'Desenho e formas',
  ),
];
