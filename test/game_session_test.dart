import 'dart:math';
import 'package:bicho_a_bicho/features/animals/domain/animal.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final kind in GameKind.values) {
    for (final count in [2, 3]) {
      test('$kind generates $count stable choices with exactly one answer', () {
        for (var seed = 0; seed < 100; seed++) {
          final session = GameSession(
            kind: kind,
            choiceCount: count,
            rounds: 6,
            random: Random(seed),
          );
          expect(session.rounds.length, 6);
          expect(
            session.rounds.take(4).map((r) => r.animal.id).toSet().length,
            4,
          );
          for (final round in session.rounds) {
            if (kind == GameKind.drawing) {
              expect(round.choices, isEmpty);
              expect(round.answer, round.animal.id);
              continue;
            }
            final expectedCount = kind == GameKind.memory ? 3 : count;
            expect(round.choices.length, expectedCount);
            expect(
              round.choices.map((c) => c.value).toSet().length,
              expectedCount,
            );
            expect(
              round.choices.where((c) => c.value == round.answer).length,
              1,
            );
            if (kind == GameKind.counting) {
              expect(round.answer, '${round.quantity}');
            }
          }
        }
      });
    }
  }
  test('rejects unsupported configurations', () {
    expect(
      () => GameSession(kind: GameKind.letters, choiceCount: 5, rounds: 4),
      throwsArgumentError,
    );
    expect(
      () => GameSession(kind: GameKind.letters, choiceCount: 2, rounds: 0),
      throwsArgumentError,
    );
  });
  test(
    'normalizes accents, whitespace and punctuation for Portuguese speech',
    () {
      expect(normalizeWords('  É um LEÃO!  '), 'e um leao');
      expect(normalizeWords('CACHORRO'), 'cachorro');
    },
  );
}
