import 'dart:math';

import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/domain/memory_board.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_page.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/games/presentation/memory_controller.dart';
import 'package:bicho_a_bicho/features/progress/domain/learning_history.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_analytics.dart';
import 'support/fakes.dart';
import 'support/localization.dart';
import 'support/profile_navigation.dart';

Future<void> deal(WidgetTester tester, MemoryController controller) async {
  controller.start();
  await tester.pump(MemoryController.flipDuration);
  await tester.pump(MemoryController.shuffleDuration);
  await tester.pump(MemoryController.shuffleDuration);
  await tester.pumpAndSettle();
}

void main() {
  test('boards contain distinct pairs and shuffle stable card identities', () {
    for (var seed = 0; seed < 200; seed++) {
      final board = MemoryBoard(animals.take(3).toList(), random: Random(seed));
      expect(board.cards, hasLength(6));
      for (var index = 1; index < board.cards.length; index++) {
        expect(
          board.cards[index].animal.id,
          isNot(board.cards[index - 1].animal.id),
        );
      }
      final original = board.cards.map((card) => card.id).toList();
      board.shuffle(Random(seed));
      expect(
        board.cards.map((card) => card.id),
        isNot(orderedEquals(original)),
      );
      expect(board.cards.map((card) => card.id).toSet(), original.toSet());
      for (var index = 0; index < board.cards.length; index++) {
        expect(board.cards[index].id, isNot(original[index]));
        if (index > 0) {
          expect(
            board.cards[index].animal.id,
            isNot(board.cards[index - 1].animal.id),
          );
        }
      }
      for (final animal in animals.take(3)) {
        expect(
          board.cards.where((card) => card.animal == animal),
          hasLength(2),
        );
      }
    }
    expect(() => MemoryBoard([animals.first]), throwsArgumentError);
    expect(() => MemoryBoard(animals.take(2).toList()), throwsArgumentError);
    expect(
      () => MemoryBoard([animals.first, animals.first]),
      throwsArgumentError,
    );
  });

  test('mismatches block a third card; matched cards cannot be reused', () {
    final board = MemoryBoard(animals.take(3).toList());
    expect(board.select(-1), MemorySelection.ignored);
    expect(board.select(0), MemorySelection.revealed);
    expect(board.select(0), MemorySelection.ignored);
    expect(board.select(2), MemorySelection.mismatch);
    expect(board.select(4), MemorySelection.ignored);
    board.hideSelection();
    expect(board.isRevealed(0), isFalse);
    expect(board.select(0), MemorySelection.revealed);
    expect(board.select(1), MemorySelection.match);
    expect(board.pairsFound, 1);
    expect(board.select(0), MemorySelection.ignored);
    expect(board.complete, isFalse);
  });

  testWidgets(
    'controller locks animation, pauses comparison and cancels timers',
    (tester) async {
      final results = <bool>[];
      final board = MemoryBoard(animals.take(3).toList());
      final controller = MemoryController(
        board: board,
        onResult: results.add,
        random: Random(4),
      );
      controller.select(0);
      expect(board.isRevealed(0), isFalse);
      controller.start();
      controller.select(0);
      expect(board.isRevealed(0), isFalse);
      controller.pause();
      await tester.pump(const Duration(seconds: 10));
      expect(controller.phase, MemoryPhase.hiding);
      controller.resume();
      await tester.pump(MemoryController.flipDuration);
      await tester.pump(MemoryController.shuffleDuration);
      await tester.pump(MemoryController.shuffleDuration);
      expect(controller.phase, MemoryPhase.playing);
      controller.select(0);
      controller.select(2);
      controller.select(4);
      expect(board.isRevealed(4), isFalse);
      expect(results, [false]);
      controller.pause();
      await tester.pump(const Duration(seconds: 10));
      expect(controller.phase, MemoryPhase.comparing);
      controller.resume();
      await tester.pump(MemoryController.comparisonDuration);
      expect(board.isRevealed(0), isFalse);
      for (var id = 0; id < 6; id += 2) {
        controller.select(id);
        controller.select(id + 1);
      }
      expect(controller.phase, MemoryPhase.complete);
      expect(controller.attempts, 4);
      expect(results, [false, true]);
      controller.dispose();

      final abandoned = MemoryController(
        board: MemoryBoard(animals.take(3).toList()),
        onResult: results.add,
      );
      abandoned.start();
      abandoned.dispose();
      await tester.pump(const Duration(seconds: 5));
      expect(results, [false, true]);
    },
  );

  for (final reduced in [false, true]) {
    testWidgets(
      'memory page completes, persists progress and respects reduced motion: $reduced',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final settings = AppSettings(MemorySettingsRepository());
        final analytics = RecordingAnalytics();
        var history = LearningHistory.empty();
        final model = GameViewModel(
          session: GameSession(
            kind: GameKind.memory,
            choiceCount: 2,
            rounds: 2,
            random: Random(3),
          ),
          audio: FakeAudio(),
          speech: FakeSpeech(),
          analytics: analytics,
          onObservation: (observation) =>
              history = history.record(0, observation),
        );
        await tester.pumpWidget(
          MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: reduced,
                textScaler: const TextScaler.linear(1.5),
              ),
              child: child!,
            ),
            home: GamePage(
              game: games.singleWhere((game) => game.kind == GameKind.memory),
              settings: settings,
              viewModel: model,
            ),
          ),
        );
        await tester.pumpAndSettle();
        model.answer(model.round.answer);
        expect(model.feedback, RoundFeedback.none);
        for (var round = 0; round < 2; round++) {
          final controller = model.memory;
          expect(controller.board.cards, hasLength(6));
          expect(model.round.choices, hasLength(3));
          await deal(tester, controller);
          expect(find.bySemanticsLabel('Carta 1, escondida'), findsOneWidget);
          controller.select(0);
          controller.select(2);
          await tester.pump(MemoryController.comparisonDuration);
          await tester.pumpAndSettle();
          for (var id = 0; id < 6; id += 2) {
            for (final cardId in [id, id + 1]) {
              final card = find.byKey(ValueKey(cardId));
              await tester.ensureVisible(card);
              await tester.tap(card);
              await tester.pumpAndSettle();
            }
            if (id == 0) {
              await tester.tap(find.byTooltip('Fazer uma pausa'));
              await tester.pumpAndSettle();
              expect(find.text('Vamos fazer uma pausa.'), findsOneWidget);
              await tester.tap(find.text('Continuar brincando'));
              await tester.pumpAndSettle();
              expect(identical(model.memory, controller), isTrue);
              expect(controller.board.pairsFound, 1);
            }
          }
          await tester.pumpAndSettle();
          expect(model.feedback, RoundFeedback.correct);
          final advance = find.text(
            round == 0 ? 'Próxima descoberta' : 'Concluir brincadeira',
          );
          await tester.ensureVisible(advance);
          await tester.tap(advance);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(model.finished, isTrue);
        expect(settings.completed('memory'), 1);
        expect(history.summarize(0, game: GameKind.memory).correct, 2);
        expect(history.summarize(0, game: GameKind.memory).errors, 2);
        expect(
          LearningHistory.decode(history.encode()).summarize(0).correct,
          2,
        );
        for (final event in analytics.events) {
          expect(validatedParameters(event.$2), isNotNull);
        }
        expect(gameScreenFor('memory'), UsageScreen.gameMemory);
        await tester.pumpWidget(const SizedBox());
        settings.dispose();
      },
    );
  }

  testWidgets(
    'memory is reachable from the catalog and leaves safely while shuffling',
    (tester) async {
      final settings = AppSettings(MemorySettingsRepository());
      await tester.pumpWidget(AnimalApp(settings: settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar agora'));
      await tester.pumpAndSettle();
      await chooseLearner(tester, 'Meu Cachorro');
      await tester.pumpAndSettle();
      final game = games.singleWhere((game) => game.kind == GameKind.memory);
      await tester.ensureVisible(find.text(game.title));
      await tester.tap(find.text(game.title));
      await tester.pumpAndSettle();
      expect(find.text(game.instruction), findsOneWidget);
      final start = find.text('Esconder e embaralhar');
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text('Escolha uma brincadeira. Vamos juntos, sem pressa.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );
}
