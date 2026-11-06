enum StoryAction { ball, book, blocks, water, drawing, resting }

/// Portuguese curriculum content, independent of application interface locale.
class StoryTemplate {
  const StoryTemplate({
    required this.title,
    required this.action,
    required this.verb,
    required this.companionAction,
    required this.companionVerb,
    required this.question,
  });

  final String title;
  final StoryAction action;
  final String verb;
  final StoryAction companionAction;
  final String companionVerb;
  final String question;
}

const storyTemplates = [
  StoryTemplate(
    title: 'Uma bola no parque',
    action: StoryAction.ball,
    verb: 'rolou a bola',
    companionAction: StoryAction.resting,
    companionVerb: 'descansou',
    question: 'Quem rolou a bola?',
  ),
  StoryTemplate(
    title: 'Um livro para explorar',
    action: StoryAction.book,
    verb: 'abriu o livro',
    companionAction: StoryAction.blocks,
    companionVerb: 'empilhou blocos',
    question: 'Quem abriu o livro?',
  ),
  StoryTemplate(
    title: 'Uma pausa para beber',
    action: StoryAction.water,
    verb: 'bebeu água',
    companionAction: StoryAction.ball,
    companionVerb: 'rolou a bola',
    question: 'Quem bebeu água?',
  ),
  StoryTemplate(
    title: 'Um desenho da turma',
    action: StoryAction.drawing,
    verb: 'fez um desenho',
    companionAction: StoryAction.book,
    companionVerb: 'abriu o livro',
    question: 'Quem fez um desenho?',
  ),
];
