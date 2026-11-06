enum GameKind {
  matching,
  letters,
  counting,
  speaking,
  clues,
  stories,
  drawing,
  memory,
}

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
