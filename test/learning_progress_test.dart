import 'dart:convert';
import 'dart:math';

import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/progress/domain/learning_history.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_analytics.dart';
import 'support/fakes.dart';
import 'support/profile_fixtures.dart';

GameViewModel createModel(AppSettings settings, {FakeSpeech? speech}) =>
    GameViewModel(
      session: GameSession(
        kind: GameKind.matching,
        choiceCount: 2,
        rounds: 3,
        random: Random(1),
      ),
      audio: FakeAudio(),
      speech: speech ?? FakeSpeech(),
      onObservation: settings.recorderForActiveProfile(),
    );

void main() {
  test(
    'persists errors immediately, counts error rounds once and deduplicates hints and correct answers',
    () async {
      final repository = MemorySettingsRepository();
      final settings = AppSettings(repository);
      final model = createModel(settings);
      final wrong = model.round.choices
          .firstWhere((c) => c.value != model.round.answer)
          .value;
      model.showHint();
      model.showHint();
      model.answer('invalid');
      model.answer(wrong);
      model.answer(wrong);
      model.answer(model.round.answer);
      model.answer(model.round.answer);
      model.showHint();
      model
          .dispose(); // No next/completion: interaction history must still persist.
      await settings.update();
      final restored = AppSettings(repository);
      await restored.load();
      final stats = restored.learningHistory.summarize(0);
      expect(stats.started, 1);
      expect(stats.answered, 1);
      expect(stats.errors, 2);
      expect(stats.roundsWithErrors, 1);
      expect(stats.correct, 1);
      expect(stats.firstTry, 0);
      expect(stats.hints, 1);
      expect(restored.totalCompleted, 0);
      settings.dispose();
      restored.dispose();
    },
  );

  test(
    'profile is captured at game entry and reports do not emit identity analytics',
    () async {
      final analytics = RecordingAnalytics();
      final repository = MemorySettingsRepository();
      final settings = AppSettings(repository, analytics: analytics);
      final model = createModel(settings);
      await ensureProfiles(settings, 2);
      await settings.selectProfile(1);
      model.answer(model.round.answer);
      expect(settings.learningHistory.summarize(0).firstTry, 1);
      expect(settings.learningHistory.summarize(1).answered, 0);
      final other = createModel(settings);
      other.answer(other.round.answer);
      other.dispose();
      model.dispose();
      await settings.update();
      final restored = AppSettings(repository);
      await restored.load();
      expect(restored.activeProfile, 1);
      expect(restored.learningHistory.summarize(0).correct, 1);
      expect(restored.learningHistory.summarize(1).correct, 1);
      expect(analytics.events, isEmpty);
      await restored.clearProfileHistory();
      expect(restored.learningHistory.summarize(1).started, 0);
      expect(restored.learningHistory.summarize(0).correct, 1);
      settings.dispose();
      restored.dispose();
    },
  );

  test(
    'pause, voice unavailability and skip are not errors; advance blocks late answers',
    () async {
      final settings = AppSettings(MemorySettingsRepository());
      final model = createModel(
        settings,
        speech: FakeSpeech()..available = false,
      );
      await model.listen();
      await model.pause();
      model.answer(model.round.answer);
      await model.next();
      expect(model.index, 0);
      model.resume();
      final next = model.next();
      model.answer(model.round.answer);
      model.showHint();
      await Future.wait([next, model.next()]);
      final stats = settings.learningHistory.summarize(0);
      expect(stats.started, 2);
      expect(stats.answered, 0);
      expect(stats.skipped, 1);
      expect(stats.errors, 0);
      expect(stats.hints, 0);
      model.dispose();
      await settings.update();
      expect(
        LearningHistory.decode(
          settings.learningHistory.encode(),
        ).summarize(0).skipped,
        1,
      );
      settings.dispose();
    },
  );

  test(
    'ranking uses error-round proportion and filters game and choice count',
    () {
      var history = LearningHistory.empty();
      for (var i = 0; i < 10; i++) {
        history = recordRound(history, 'dog', wrong: i < 2);
      }
      history = recordRound(history, 'cat', wrong: true);
      history = recordRound(history, 'cat', wrong: false);
      history = recordRound(
        history,
        'lion',
        wrong: true,
        choices: 3,
        game: GameKind.counting,
      );
      expect(history.rankAnimals(0).map((e) => e.animal.id), [
        'lion',
        'cat',
        'dog',
      ]);
      expect(history.rankAnimals(0, choices: 2).first.animal.id, 'cat');
      expect(
        history.rankAnimals(0, game: GameKind.counting).single.animal.id,
        'lion',
      );
      expect(history.summarize(0, choices: 2).errors, 3);
      expect(history.summarize(0, animalId: 'cat').errorRate, .5);
      final restored = LearningHistory.decode(history.encode());
      expect(restored.summarize(0).errors, 4);
      expect(restored.rankAnimals(0).first.animal.id, 'lion');
    },
  );

  test('rejects corrupt, duplicate and unsupported persistence data', () {
    final row = [
      0,
      'matching',
      'dog',
      2,
      [1, 1, 0, 0, 1, 1, 0, 0],
    ];
    for (final source in [
      '{',
      '{}',
      jsonEncode({'version': 2, 'buckets': <Object>[]}),
      jsonEncode({
        'version': 1,
        'buckets': [row, row],
      }),
      jsonEncode({
        'version': 1,
        'buckets': [
          [0, 'matching', 'dog', 2.0, row.last],
        ],
      }),
      jsonEncode({
        'version': 1,
        'buckets': [
          [
            0,
            'matching',
            'dog',
            2,
            [0, 1, 0, 0, 1, 1, 0, 0],
          ],
        ],
      }),
    ]) {
      expect(() => LearningHistory.decode(source), throwsFormatException);
    }
  });

  test(
    'old installs keep session counts and do not invent old errors',
    () async {
      final repository = MemorySettingsRepository()
        ..values = {'completed_matching': 7, 'sound': true};
      final settings = AppSettings(repository);
      await settings.load();
      expect(settings.completed('matching'), 7);
      expect(settings.learningHistory.summarize(0).started, 0);
      expect(settings.soundEnabled, isTrue);
      repository.values['learning_history'] = 'broken';
      await settings.load();
      expect(settings.storageFailed, isTrue);
      expect(settings.completed('matching'), 7);
      settings.dispose();
    },
  );

  test(
    'failed saving is visible and retry saves the full in-memory counters',
    () async {
      final repository = MemorySettingsRepository()..fail = true;
      final settings = AppSettings(repository);
      final model = createModel(settings);
      model.answer(model.round.answer);
      model.dispose();
      await settings.update();
      expect(settings.storageFailed, isTrue);
      expect(settings.learningHistory.summarize(0).firstTry, 1);
      repository.fail = false;
      await settings.update();
      expect(settings.storageFailed, isFalse);
      final restored = AppSettings(repository);
      await restored.load();
      expect(restored.learningHistory.summarize(0).firstTry, 1);
      await restored.resetProgress();
      expect(restored.learningHistory.summarize(0).started, 0);
      settings.dispose();
      restored.dispose();
    },
  );
}

LearningHistory recordRound(
  LearningHistory history,
  String animal, {
  required bool wrong,
  int choices = 2,
  GameKind game = GameKind.matching,
}) {
  LearningObservation observation(
    LearningAction action, {
    bool first = false,
  }) => LearningObservation(
    game: game,
    animalId: animal,
    choices: choices,
    action: action,
    firstAttempt: first,
  );
  history = history.record(0, observation(LearningAction.started));
  if (wrong) {
    history = history.record(
      0,
      observation(LearningAction.incorrect, first: true),
    );
  }
  return history.record(0, observation(LearningAction.correct, first: !wrong));
}
