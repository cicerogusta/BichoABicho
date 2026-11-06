import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/analytics/analytics_controller.dart';
import 'package:bicho_a_bicho/features/settings/presentation/analytics_settings_card.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_analytics.dart';
import 'support/fakes.dart';
import 'support/profile_navigation.dart';

void main() {
  testWidgets(
    'SDK failure keeps consent visible and allows the parent to revoke it',
    (tester) async {
      final backend = FakeAnalyticsBackend()..fail = true;
      final saved = <bool>[];
      final analytics = AnalyticsController(
        backend,
        persistConsent: (enabled) async {
          saved.add(enabled);
          return true;
        },
      );
      await analytics.setConsent(true);
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalyticsSettingsCard(analytics: analytics),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(analytics.enabled, isFalse);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      expect(find.text('Tentar novamente'), findsOneWidget);
      await tester.tap(find.text('Compartilhar dados de uso'));
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(saved, [true, false]);
      expect(analytics.consentGranted, isFalse);
      await tester.pumpWidget(const SizedBox());
      analytics.dispose();
    },
  );
  testWidgets(
    'tabs and returning from a game report real screens without rebuild duplicates',
    (tester) async {
      final backend = FakeAnalyticsBackend();
      final analytics = AnalyticsController(
        backend,
        persistConsent: (_) async => true,
      );
      final settings = AppSettings(
        MemorySettingsRepository(),
        analytics: analytics,
      );
      await analytics.initialize(true);
      await tester.pumpWidget(
        AnimalApp(settings: settings, analytics: analytics),
      );
      await tester.tap(find.text('Começar agora'));
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(backend.screens, ['opening', 'profileSelection']);
      await chooseLearner(tester, 'Meu Cachorro');
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(backend.screens, [
        'opening',
        'profileSelection',
        'profileName',
        'profileSelection',
        'playHome',
      ]);
      await settings.update(sound: true);
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(backend.screens, [
        'opening',
        'profileSelection',
        'profileName',
        'profileSelection',
        'playHome',
      ]);
      final game = find.bySemanticsLabel('Jogar Encontre o bichinho');
      await tester.ensureVisible(game);
      await tester.tap(game);
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(backend.screens.last, 'gameMatching');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(backend.screens.last, 'playHome');
      await tester.tap(find.text('Bichinhos'));
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(backend.screens.last, 'animals');
      await tester.tap(find.text('Responsáveis'));
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(backend.screens.last, 'parents');
      await tester.pumpWidget(const SizedBox());
      await analytics.idle;
      settings.dispose();
      analytics.dispose();
    },
  );
  testWidgets(
    'sharing requires explicit confirmation and revocation stops collection',
    (tester) async {
      final backend = FakeAnalyticsBackend();
      final saved = <bool>[];
      final analytics = AnalyticsController(
        backend,
        persistConsent: (value) async {
          saved.add(value);
          return true;
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalyticsSettingsCard(analytics: analytics),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Compartilhar dados de uso'));
      await tester.pumpAndSettle();
      expect(find.text('Autorizar dados de uso?'), findsOneWidget);
      expect(backend.configurations, isEmpty);
      await tester.tap(find.text('Não autorizar'));
      await tester.pumpAndSettle();
      expect(saved, isEmpty);
      await tester.tap(find.text('Compartilhar dados de uso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sou responsável e autorizo'));
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(saved, [true]);
      expect(analytics.enabled, isTrue);
      await tester.tap(find.text('Compartilhar dados de uso'));
      await tester.pumpAndSettle();
      await analytics.idle;
      expect(saved, [true, false]);
      expect(analytics.enabled, isFalse);
      expect(backend.resets, 1);
      await tester.pumpWidget(const SizedBox());
      analytics.dispose();
    },
  );
  testWidgets('consent dialogs do not count as extra screen views', (
    tester,
  ) async {
    final backend = FakeAnalyticsBackend();
    final analytics = AnalyticsController(
      backend,
      persistConsent: (_) async => true,
    );
    final settings = AppSettings(MemorySettingsRepository());
    await analytics.initialize(true);
    await tester.pumpWidget(
      AnimalApp(settings: settings, analytics: analytics),
    );
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();
    await chooseLearner(tester, 'Meu Cachorro');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Responsáveis'));
    await tester.pumpAndSettle();
    await analytics.idle;
    final screens = List.of(backend.screens);
    await tester.ensureVisible(find.text('Apagar histórico local'));
    await tester.tap(find.text('Apagar histórico local'));
    await tester.pumpAndSettle();
    await analytics.idle;
    expect(backend.screens, screens);
    await tester.tap(find.text('Manter histórico'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    analytics.dispose();
    settings.dispose();
  });
  testWidgets('unconfigured platforms expose a disabled sharing control', (
    tester,
  ) async {
    final backend = FakeAnalyticsBackend()..supported = false;
    final analytics = AnalyticsController(
      backend,
      persistConsent: (_) async => true,
    );
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnalyticsSettingsCard(analytics: analytics),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
    expect(
      find.text('A análise ainda não está configurada nesta plataforma.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    analytics.dispose();
  });
  testWidgets('sharing controls and consent text fit a phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final analytics = AnalyticsController(
      FakeAnalyticsBackend(),
      persistConsent: (_) async => true,
    );
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnalyticsSettingsCard(analytics: analytics),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Compartilhar dados de uso'));
    await tester.tap(find.text('Compartilhar dados de uso'));
    await tester.pumpAndSettle();
    expect(find.text('Autorizar dados de uso?'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Não autorizar'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    analytics.dispose();
  });
}
