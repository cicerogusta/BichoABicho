import 'dart:async';
import 'package:bicho_a_bicho/core/analytics/analytics_controller.dart';
import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fake_analytics.dart';

void main() {
  late FakeAnalyticsBackend backend;
  late AnalyticsController analytics;
  late List<bool> saved;
  setUp(() {
    backend = FakeAnalyticsBackend();
    saved = [];
    analytics = AnalyticsController(
      backend,
      persistConsent: (enabled) async {
        saved.add(enabled);
        return true;
      },
    );
  });
  tearDown(() => analytics.dispose());
  test(
    'revocation is saved even when the native SDK cannot be contacted',
    () async {
      await analytics.setConsent(true);
      backend.failDisable = true;
      await analytics.setConsent(false);
      expect(saved, [true, false]);
      expect(analytics.enabled, isFalse);
      expect(analytics.status, AnalyticsStatus.failed);
    },
  );
  test(
    'rapid enable-disable-enable preserves the most recent choice',
    () async {
      backend.configureGate = Completer<void>();
      final first = analytics.setConsent(true);
      await Future<void>.delayed(Duration.zero);
      final second = analytics.setConsent(false);
      final last = analytics.setConsent(true);
      backend.configureGate!.complete();
      await Future.wait([first, second, last]);
      expect(analytics.enabled, isTrue);
      expect(analytics.status, AnalyticsStatus.active);
      expect(backend.configurations.last, isTrue);
      expect(
        backend.events
            .where((event) => event.$1 == 'analytics_consent_granted')
            .length,
        1,
      );
    },
  );
  test('default and denied consent never transmit events or screens', () async {
    analytics.event(UsageEvent.gameStarted);
    analytics.screen(UsageScreen.parents);
    await analytics.initialize(false);
    analytics.event(UsageEvent.gameStarted);
    await analytics.idle;
    expect(backend.events, isEmpty);
    expect(backend.screens, isEmpty);
    expect(backend.configurations.every((enabled) => !enabled), isTrue);
    expect(saved, isEmpty);
  });
  test(
    'consent is persisted before collection is enabled and current screen is reported',
    () async {
      analytics.rootScreen(UsageScreen.parents);
      await analytics.setConsent(true);
      expect(saved, [true]);
      expect(analytics.status, AnalyticsStatus.active);
      expect(backend.screens, ['parents']);
      expect(backend.events.single.$1, 'analytics_consent_granted');
      analytics.event(
        UsageEvent.hintUsed,
        parameters: {UsageParameter.gameId: 'matching'},
      );
      await analytics.idle;
      expect(backend.events.last.$2, {
        'schema_version': 1,
        'game_id': 'matching',
      });
    },
  );
  test(
    'revoke immediately suppresses queued events and resets local SDK data',
    () async {
      await analytics.setConsent(true);
      analytics.event(UsageEvent.gameStarted);
      final revoke = analytics.setConsent(false);
      analytics.event(UsageEvent.gameCompleted);
      await revoke;
      await analytics.idle;
      expect(analytics.enabled, isFalse);
      expect(backend.events.map((event) => event.$1), [
        'analytics_consent_granted',
      ]);
      expect(backend.configurations.last, isFalse);
      expect(backend.resets, 1);
      expect(saved, [true, false]);
    },
  );
  test('revoke during native initialization cannot send late events', () async {
    backend.configureGate = Completer<void>();
    final enable = analytics.setConsent(true);
    await Future<void>.delayed(Duration.zero);
    final revoke = analytics.setConsent(false);
    backend.configureGate!.complete();
    await enable;
    await revoke;
    expect(backend.events, isEmpty);
    expect(backend.screens, isEmpty);
    expect(backend.configurations.last, isFalse);
  });
  test(
    'revoke during user-property initialization cannot emit consent or a screen',
    () async {
      backend.propertiesGate = Completer<void>();
      final enable = analytics.setConsent(true);
      await Future<void>.delayed(Duration.zero);
      final revoke = analytics.setConsent(false);
      backend.propertiesGate!.complete();
      await enable;
      await revoke;
      expect(backend.events, isEmpty);
      expect(backend.screens, isEmpty);
      expect(analytics.enabled, isFalse);
    },
  );
  test('storage failure prevents activation', () async {
    final other = AnalyticsController(
      backend,
      persistConsent: (_) async => false,
    );
    await other.setConsent(true);
    expect(other.enabled, isFalse);
    expect(other.status, AnalyticsStatus.failed);
    expect(backend.configurations, [false]);
    expect(backend.events, isEmpty);
    other.dispose();
  });
  test('platform failure fails closed and a later retry can recover', () async {
    backend.fail = true;
    await analytics.setConsent(true);
    expect(analytics.status, AnalyticsStatus.failed);
    expect(backend.configurations.last, isFalse);
    expect(analytics.consentGranted, isTrue);
    backend.fail = false;
    await analytics.setConsent(true);
    expect(analytics.status, AnalyticsStatus.active);
  });
  test(
    'unsupported platforms never initialize the SDK or save an opt-in',
    () async {
      backend.supported = false;
      await analytics.setConsent(true);
      analytics.event(UsageEvent.gameStarted);
      await analytics.idle;
      expect(analytics.status, AnalyticsStatus.unavailable);
      expect(backend.configurations, isEmpty);
      expect(saved, [false]);
    },
  );
  test(
    'screen views deduplicate rebuilds but count returning to a previous screen',
    () async {
      await analytics.initialize(true);
      analytics.rootScreen(UsageScreen.playHome);
      analytics.rootScreen(UsageScreen.playHome);
      analytics.routeScreen(UsageScreen.gameMatching);
      analytics.rootScreen(
        UsageScreen.parents,
      ); // hidden home must not claim the foreground
      analytics.routeScreen(null);
      await analytics.idle;
      expect(backend.screens, [
        'opening',
        'playHome',
        'gameMatching',
        'parents',
      ]);
    },
  );
  test(
    'events collected while initializing preserve the screen sequence without duplication',
    () async {
      backend.configureGate = Completer<void>();
      final initialize = analytics.initialize(true);
      analytics.rootScreen(UsageScreen.playHome);
      analytics.routeScreen(UsageScreen.gameLetters);
      analytics.event(
        UsageEvent.gameStarted,
        parameters: {UsageParameter.gameId: 'letters'},
      );
      backend.configureGate!.complete();
      await initialize;
      await analytics.idle;
      expect(backend.screens, ['opening', 'playHome', 'gameLetters']);
      expect(backend.events.single.$1, 'game_start');
    },
  );
  test('unknown free-text payloads are rejected rather than leaked', () async {
    await analytics.initialize(true);
    analytics.event(
      UsageEvent.accountFailure,
      parameters: {UsageParameter.reason: 'name@example.com'},
    );
    analytics.event(
      UsageEvent.gameStarted,
      parameters: {UsageParameter.gameId: 'child-name'},
    );
    analytics.event(
      UsageEvent.answerSubmitted,
      parameters: {UsageParameter.attempts: 'spoken words'},
    );
    analytics.event(
      UsageEvent.gameCompleted,
      parameters: {UsageParameter.durationMs: -1},
    );
    await analytics.idle;
    expect(backend.events, isEmpty);
  });
  test(
    'pre-consent settings are only sent after opt-in as bounded properties',
    () async {
      analytics.preferences(
        sound: true,
        reducedMotion: false,
        choices: 3,
        rounds: 6,
      );
      expect(backend.propertySnapshots, isEmpty);
      await analytics.initialize(true);
      expect(backend.propertySnapshots.single, {
        'sound_enabled': 'true',
        'reduced_motion': 'false',
        'choice_count': '3',
        'round_count': '6',
      });
    },
  );
}
