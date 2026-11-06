import 'dart:math';

import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';

import '../../animals/domain/animal.dart';
import 'animal_story.dart';
import 'drawing_template.dart';
import 'game_definition.dart';
import 'memory_board.dart';

class GameChoice {
  const GameChoice(this.value, this.label, {this.animal});
  final String value;
  final String label;
  final Animal? animal;
}

class GameRound {
  GameRound({
    required this.animal,
    required this.answer,
    required List<GameChoice> choices,
    required this.quantity,
    this.story,
  }) : choices = List.unmodifiable(choices);
  final Animal animal;
  final String answer;
  final List<GameChoice> choices;
  final int quantity;
  final AnimalStory? story;
}

class GameSession {
  GameSession({
    required this.kind,
    required int choiceCount,
    required int rounds,
    Random? random,
  }) {
    if (choiceCount < 2 || choiceCount > 3 || rounds < 1) {
      throw ArgumentError('Expected 2–3 choices and at least one round.');
    }
    final generator = random ?? Random();
    // Drawing requires a validated outline; other games use the full catalog.
    final order =
        animals
            .where(
              (animal) =>
                  kind != GameKind.drawing ||
                  drawingTemplates.containsKey(animal.id),
            )
            .toList()
          ..shuffle(generator);
    this.rounds = List.unmodifiable(
      List.generate(rounds, (index) {
        final animal = order[index % order.length];
        final companion = order[(index + 1) % order.length];
        final quantity = index % 4 + 1;
        final answer = switch (kind) {
          GameKind.letters => animal.initial,
          GameKind.counting => '$quantity',
          _ => animal.id,
        };
        final pool = switch (kind) {
          GameKind.letters =>
            animals
                .map((a) => a.initial)
                .toSet()
                .map((initial) => GameChoice(initial, initial))
                .toList(),
          GameKind.counting => List.generate(
            4,
            (i) => GameChoice('${i + 1}', '${i + 1}'),
          ),
          _ => animals.map((a) => GameChoice(a.id, a.name, animal: a)).toList(),
        };
        final correct = pool.firstWhere((choice) => choice.value == answer);
        final distractors =
            pool.where((choice) => choice.value != answer).toList()
              ..shuffle(generator);
        // Keep both story characters among the options, even with two choices.
        if (kind == GameKind.stories) {
          final companionChoice = distractors.firstWhere(
            (choice) => choice.value == companion.id,
          );
          distractors.remove(companionChoice);
          distractors.insert(0, companionChoice);
        }
        final roundChoiceCount = kind == GameKind.memory
            ? MemoryBoard.pairCount
            : choiceCount;
        final choices = [correct, ...distractors.take(roundChoiceCount - 1)]
          ..shuffle(generator);
        return GameRound(
          animal: animal,
          answer: answer,
          choices: kind == GameKind.drawing ? const [] : choices,
          quantity: quantity,
          story: kind == GameKind.stories
              ? AnimalStory.forRound(animal, companion, index)
              : null,
        );
      }),
    );
  }
  final GameKind kind;
  late final List<GameRound> rounds;
}
