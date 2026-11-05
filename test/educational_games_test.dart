import 'support/profile_navigation.dart';
import 'dart:math';
import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_analytics.dart';
import 'support/fakes.dart';

void main() {
  test('stories ask about one explicit action and include both characters', () {
    for (var seed = 0; seed < 100; seed++) {
      for (final count in [2, 3]) {
        final session = GameSession(
          kind: GameKind.stories,
          choiceCount: count,
          rounds: 6,
          random: Random(seed),
        );
        expect(session.rounds.map((r) => r.story!.title).toSet(), hasLength(4));
        for (var i = 0; i < session.rounds.length; i++) {
          final round = session.rounds[i];
          final story = round.story!;
          expect(story.scenes, hasLength(2));
          expect(story.scenes.map((s) => s.animal.id).toSet(), hasLength(2));
          expect(
            story.scenes.where((s) => s.sentence == story.answerSentence),
            hasLength(1),
          );
          final answer = story.scenes.singleWhere(
            (s) => s.sentence == story.answerSentence,
          );
          expect(answer.animal.id, round.answer);
          expect(story.scenes[i.isEven ? 0 : 1], same(answer));
          expect(story.scenes[0].action, isNot(story.scenes[1].action));
          for (final scene in story.scenes) {
            expect(
              round.choices.any((c) => c.value == scene.animal.id),
              isTrue,
            );
          }
          expect(() => story.scenes.clear(), throwsUnsupportedError);
        }
      }
    }
  });

  test(
    'all catalog games restore and reset progress without losing old games',
    () async {
      final repository = MemorySettingsRepository();
      final settings = AppSettings(repository);
      for (final kind in GameKind.values) {
        await settings.recordCompletion(kind.name);
      }
      final restored = AppSettings(repository);
      await restored.load();
      for (final kind in GameKind.values) {
        expect(restored.completed(kind.name), 1);
      }
      await restored.resetProgress();
      final cleared = AppSettings(repository);
      await cleared.load();
      expect(cleared.totalCompleted, 0);
      settings.dispose();
      restored.dispose();
      cleared.dispose();
    },
  );

  test(
    'new games emit accepted events and have dedicated screen names',
    () async {
      for (final kind in [GameKind.clues, GameKind.stories]) {
        final analytics = RecordingAnalytics();
        final model = GameViewModel(
          session: GameSession(
            kind: kind,
            choiceCount: 2,
            rounds: 1,
            random: Random(1),
          ),
          audio: FakeAudio(),
          speech: FakeSpeech(),
          analytics: analytics,
        );
        model.showHint();
        model.answer(model.round.answer);
        await model.next();
        expect(
          analytics.events.any((e) => e.$1 == UsageEvent.gameCompleted),
          isTrue,
        );
        for (final event in analytics.events) {
          expect(validatedParameters(event.$2), isNotNull);
          expect(event.$2[UsageParameter.gameId], kind.name);
        }
        expect(
          gameScreenFor(kind.name),
          kind == GameKind.clues
              ? UsageScreen.gameClues
              : UsageScreen.gameStories,
        );
        model.dispose();
      }
    },
  );

  for (final kind in [GameKind.clues, GameKind.stories]) {
    testWidgets('$kind is reachable from the home catalog and returns safely', (
      tester,
    ) async {
      final settings = AppSettings(MemorySettingsRepository());
      await tester.pumpWidget(AnimalApp(settings: settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar agora'));
      await tester.pumpAndSettle();
      await chooseLearner(tester, 'Meu Cachorro');
      await tester.pumpAndSettle();
      final game = games.singleWhere((game) => game.kind == kind);
      await tester.ensureVisible(find.text(game.title));
      await tester.tap(find.text(game.title));
      await tester.pumpAndSettle();
      expect(find.text(game.instruction), findsOneWidget);
      if (kind == GameKind.clues) {
        expect(find.text('A pista é:'), findsOneWidget);
        expect(find.text('Ouvir o bichinho'), findsNothing);
      } else {
        expect(find.text('Cena 1'), findsOneWidget);
        expect(find.text('Cena 2'), findsOneWidget);
        expect(
          find.text('Pode olhar a história de novo quando quiser.'),
          findsOneWidget,
        );
      }
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text('Escolha uma brincadeira. Vamos juntos, sem pressa.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    });
  }
}
