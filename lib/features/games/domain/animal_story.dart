import '../../animals/domain/animal.dart';

enum StoryAction { ball, book, blocks, water, drawing, resting }

class StoryScene {
  const StoryScene(this.animal, this.action, this.sentence);
  final Animal animal;
  final StoryAction action;
  final String sentence;
}

/// Original short stories for shared reading. The answer stays in the scene,
/// so the activity does not require remembering hidden text.
class AnimalStory {
  AnimalStory({
    required this.title,
    required List<StoryScene> scenes,
    required this.question,
    required this.answerSentence,
  }) : scenes = List.unmodifiable(scenes);

  final String title;
  final List<StoryScene> scenes;
  final String question;
  final String answerSentence;

  factory AnimalStory.forRound(Animal answer, Animal companion, int index) {
    final (
      title,
      action,
      verb,
      otherAction,
      otherVerb,
      question,
    ) = switch (index % 4) {
      0 => (
        'Uma bola no parque',
        StoryAction.ball,
        'rolou a bola',
        StoryAction.resting,
        'descansou',
        'Quem rolou a bola?',
      ),
      1 => (
        'Um livro para explorar',
        StoryAction.book,
        'abriu o livro',
        StoryAction.blocks,
        'empilhou blocos',
        'Quem abriu o livro?',
      ),
      2 => (
        'Uma pausa para beber',
        StoryAction.water,
        'bebeu água',
        StoryAction.ball,
        'rolou a bola',
        'Quem bebeu água?',
      ),
      _ => (
        'Um desenho da turma',
        StoryAction.drawing,
        'fez um desenho',
        StoryAction.book,
        'abriu o livro',
        'Quem fez um desenho?',
      ),
    };
    final answerSentence = '${answer.name} $verb.';
    final main = StoryScene(answer, action, answerSentence);
    final other = StoryScene(
      companion,
      otherAction,
      '${companion.name} $otherVerb.',
    );
    return AnimalStory(
      title: title,
      scenes: index.isEven ? [main, other] : [other, main],
      question: question,
      answerSentence: answerSentence,
    );
  }
}
