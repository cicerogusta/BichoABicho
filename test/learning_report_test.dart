import 'dart:math';

import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/theme/app_theme.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/progress/presentation/learning_report.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/capture_preview.dart';
import 'support/fakes.dart';
import 'support/localization.dart';
import 'support/profile_fixtures.dart';
import 'support/profile_navigation.dart';

Future<void> seed(AppSettings settings) async {
  final model = GameViewModel(
    session: GameSession(
      kind: GameKind.matching,
      choiceCount: 2,
      rounds: 1,
      random: Random(1),
    ),
    audio: FakeAudio(),
    speech: FakeSpeech(),
    onObservation: settings.recorderForActiveProfile(),
  );
  model.answer(
    model.round.choices.firstWhere((c) => c.value != model.round.answer).value,
  );
  model.showHint();
  model.answer(model.round.answer);
  model.dispose();
  await settings.update();
}

Widget report(AppSettings settings) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  debugShowCheckedModeBanner: false,
  theme: AppTheme.create(),
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LearningReport(settings: settings),
    ),
  ),
);

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Nunito',
    )..addFont(rootBundle.load('fonts/Nunito.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets(
    'report needs no account, separates profiles and confirms deletion',
    (tester) async {
      tester.view.physicalSize = const Size(780, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = AppSettings(MemorySettingsRepository());
      await seed(settings);
      await ensureProfiles(settings, 2);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: key, child: report(settings)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Acompanhamento das brincadeiras'), findsOneWidget);
      expect(find.text('Tentativas incorretas'), findsOneWidget);
      expect(find.text('1 de 1 respondidas'), findsOneWidget);
      if (const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
        await capturePreview(tester, key, 'parent_report');
      }
      await chooseLearner(tester, 'Meu Gato');
      await tester.pumpAndSettle();
      expect(settings.activeProfile, 0);
      expect(find.text('Tentativas incorretas'), findsNothing);
      await chooseLearner(tester, 'Meu Cachorro');
      await tester.pumpAndSettle();
      final clear = find.text('Apagar acompanhamento de Meu Cachorro');
      await tester.ensureVisible(clear);
      await tester.tap(clear);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(settings.learningHistory.summarize(0).errors, 1);
      await tester.tap(clear);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar acompanhamento'));
      await tester.pumpAndSettle();
      expect(settings.learningHistory.summarize(0).started, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );

  testWidgets('filters by activity and number of alternatives', (tester) async {
    final settings = AppSettings(MemorySettingsRepository());
    await seed(settings);
    await tester.pumpWidget(report(settings));
    await tester.pumpAndSettle();
    final filters = find.byType(DropdownButton<String>);
    await tester.ensureVisible(filters.last);
    await tester.tap(filters.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 alternativas').last);
    await tester.pumpAndSettle();
    expect(find.text('Tentativas incorretas'), findsNothing);
    await tester.tap(filters.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('2 alternativas').last);
    await tester.pumpAndSettle();
    expect(find.text('Tentativas incorretas'), findsOneWidget);
    await tester.ensureVisible(filters.first);
    await tester.tap(filters.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vamos contar?').last);
    await tester.pumpAndSettle();
    expect(find.text('Tentativas incorretas'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('small report supports text scale $scale', (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final settings = AppSettings(MemorySettingsRepository());
      await seed(settings);
      await tester.pumpWidget(report(settings));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text('Animais com maior proporção de rodadas com erro'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    });
  }

  testWidgets('real game records an interrupted round and parents can view it', (
    tester,
  ) async {
    final settings = AppSettings(MemorySettingsRepository());
    await tester.pumpWidget(AnimalApp(settings: settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();
    await chooseLearner(tester, 'Meu Cachorro');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(games.first.title));
    await tester.tap(find.text(games.first.title));
    await tester.pumpAndSettle();
    expect(settings.learningHistory.summarize(0).started, 1);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Responsáveis'));
    await tester.pumpAndSettle();
    expect(find.text('Acompanhamento das brincadeiras'), findsOneWidget);
    expect(
      find.text(
        'Rodadas abertas: 1 • Com resposta: 0. Rodadas interrompidas também ficam registradas.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
}
