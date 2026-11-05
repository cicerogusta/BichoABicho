import 'dart:math';
import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_analytics.dart';
import 'support/fakes.dart';

void main() {
  late RecordingAnalytics analytics;
  late FakeSpeech speech;
  late GameViewModel model;
  setUp(() {
    analytics = RecordingAnalytics();
    speech = FakeSpeech();
    model = GameViewModel(
      session: GameSession(
        kind: GameKind.speaking,
        choiceCount: 2,
        rounds: 4,
        random: Random(5),
      ),
      audio: FakeAudio(),
      speech: speech,
      analytics: analytics,
    );
  });
  tearDown(() => model.dispose());
  test(
    'starts a game and its first round with bounded catalog identifiers',
    () {
      expect(analytics.events.map((event) => event.$1), [
        UsageEvent.gameStarted,
        UsageEvent.roundStarted,
      ]);
      expect(analytics.events.first.$2[UsageParameter.gameId], 'speaking');
      expect(analytics.events.last.$2[UsageParameter.roundIndex], 1);
      expect(
        analytics.events.every(
          (event) => validatedParameters(event.$2) != null,
        ),
        isTrue,
      );
    },
  );
  test('hint and correct-answer retries cannot inflate event counts', () {
    model.showHint();
    model.showHint();
    model.answer(model.round.answer);
    model.answer(model.round.answer);
    expect(
      analytics.events.where((event) => event.$1 == UsageEvent.hintUsed).length,
      1,
    );
    expect(
      analytics.events
          .where((event) => event.$1 == UsageEvent.answerSubmitted)
          .length,
      1,
    );
    expect(analytics.events.last.$2[UsageParameter.inputMethod], 'touch');
    expect(analytics.events.last.$2[UsageParameter.attempts], 1);
  });
  test('completion distinguishes skipped rounds from answers', () async {
    await model.next();
    for (var i = 0; i < 3; i++) {
      model.answer(model.round.answer);
      await model.next();
    }
    final event = analytics.events.singleWhere(
      (event) => event.$1 == UsageEvent.gameCompleted,
    );
    expect(event.$2[UsageParameter.correctRounds], 3);
    expect(event.$2[UsageParameter.skippedRounds], 1);
    expect(event.$2[UsageParameter.durationMs], isNonNegative);
    expect(
      analytics.events
          .where((event) => event.$1 == UsageEvent.roundStarted)
          .length,
      4,
    );
    expect(
      analytics.events.every((event) => validatedParameters(event.$2) != null),
      isTrue,
    );
  });
  test('leaving an unfinished game records abandonment exactly once', () {
    final other = GameViewModel(
      session: model.session,
      audio: FakeAudio(),
      speech: FakeSpeech(),
      analytics: analytics,
    );
    other.dispose();
    expect(
      analytics.events
          .where((event) => event.$1 == UsageEvent.gameAbandoned)
          .length,
      1,
    );
  });
  test('background lifecycle notifications do not duplicate pauses', () async {
    await model.pause(fromBackground: true);
    await model.pause(fromBackground: true);
    model.resume();
    model.resume();
    final pauses = analytics.events
        .where((event) => event.$1 == UsageEvent.gamePaused)
        .toList();
    expect(pauses.length, 1);
    expect(pauses.single.$2[UsageParameter.reason], 'background');
    expect(
      analytics.events
          .where((event) => event.$1 == UsageEvent.gameResumed)
          .length,
      1,
    );
  });
  test('voice events never contain the recognized transcript', () async {
    await model.listen();
    speech.onFinal!('é um ${model.round.animal.name} com fala privada');
    final event = analytics.events.singleWhere(
      (event) => event.$1 == UsageEvent.answerSubmitted,
    );
    expect(event.$2[UsageParameter.inputMethod], 'voice');
    expect(analytics.events.toString(), isNot(contains('fala privada')));
    expect(
      analytics.events.every((event) => validatedParameters(event.$2) != null),
      isTrue,
    );
  });
  test(
    'speech failure is deduplicated when the SDK reports it twice',
    () async {
      speech.available = false;
      await model.listen();
      speech.onError!();
      expect(
        analytics.events
            .where((event) => event.$1 == UsageEvent.speechFinished)
            .length,
        1,
      );
      expect(
        analytics.events
            .where((event) => event.$1 == UsageEvent.mediaUnavailable)
            .length,
        1,
      );
    },
  );
  test(
    'consent is versioned and old or failed opt-ins stay disabled',
    () async {
      final repository = MemorySettingsRepository()
        ..values = {'analytics_enabled': true, 'analytics_version': 0};
      final settings = AppSettings(repository);
      await settings.load();
      expect(settings.analyticsEnabled, isFalse);
      expect(await settings.setAnalyticsConsent(true), isTrue);
      final restored = AppSettings(repository);
      await restored.load();
      expect(restored.analyticsEnabled, isTrue);
      repository.fail = true;
      expect(await settings.setAnalyticsConsent(true), isFalse);
      expect(settings.analyticsEnabled, isFalse);
      settings.dispose();
      restored.dispose();
    },
  );
  test(
    'settings only record real changes and keep property values bounded',
    () async {
      final settings = AppSettings(
        MemorySettingsRepository(),
        analytics: analytics,
      );
      await settings.update(sound: false);
      expect(
        analytics.events.where(
          (event) => event.$1 == UsageEvent.settingsChanged,
        ),
        isEmpty,
      );
      await settings.update(sound: true, choices: 3);
      expect(
        analytics.events
            .where((event) => event.$1 == UsageEvent.settingsChanged)
            .length,
        2,
      );
      expect(analytics.preferenceValues['choices'], 3);
      settings.dispose();
    },
  );
}
