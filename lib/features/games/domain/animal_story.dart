import '../../animals/domain/animal.dart';

import 'story_catalog.dart';

export 'story_catalog.dart' show StoryAction;

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
    final template = storyTemplates[index % storyTemplates.length];
    final answerSentence = '${answer.name} ${template.verb}.';
    final main = StoryScene(answer, template.action, answerSentence);
    final other = StoryScene(
      companion,
      template.companionAction,
      '${companion.name} ${template.companionVerb}.',
    );
    return AnimalStory(
      title: template.title,
      scenes: index.isEven ? [main, other] : [other, main],
      question: template.question,
      answerSentence: answerSentence,
    );
  }
}
