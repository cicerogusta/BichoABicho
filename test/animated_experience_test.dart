import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/theme/app_theme.dart';
import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';
import 'package:bicho_a_bicho/features/games/presentation/widgets/animal_celebration.dart';
import 'package:bicho_a_bicho/features/opening/presentation/opening_page.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/capture_preview.dart';
import 'support/fakes.dart';
import 'support/profile_navigation.dart';

Widget shell(Widget child, {bool reduced = false}) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  debugShowCheckedModeBanner: false,
  theme: AppTheme.create(),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: child!,
  ),
  home: child,
);

void main() {
  setUpAll(() async {
    final font = FontLoader('Nunito')
      ..addFont(rootBundle.load('fonts/Nunito.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  testWidgets(
    'opening automatically completes exactly once after its animation',
    (tester) async {
      var completed = 0;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: shell(OpeningPage(onComplete: () => completed++)),
        ),
      );
      expect(find.text('A turma chegou para brincar!'), findsOneWidget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      expect(completed, 0);
      if (const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
        await capturePreview(tester, key, 'opening');
      }
      await tester.pump(const Duration(milliseconds: 3799));
      expect(completed, 0);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(completed, 1);
      await tester.pump(const Duration(seconds: 3));
      expect(completed, 1);
    },
  );
  testWidgets(
    'reduced motion shows the entire group without an active animation',
    (tester) async {
      var completed = 0;
      await tester.pumpWidget(
        shell(OpeningPage(onComplete: () => completed++), reduced: true),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(
        tester
            .widgetList<Opacity>(find.byType(Opacity))
            .every((widget) => widget.opacity == 1),
        isTrue,
      );
      await tester.pump(const Duration(seconds: 4));
      expect(completed, 0);
      await tester.pump(const Duration(seconds: 1));
      expect(completed, 1);
    },
  );
  testWidgets('opening pauses in the background and finishes after resuming', (
    tester,
  ) async {
    var completed = 0;
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    await tester.pumpWidget(shell(OpeningPage(onComplete: () => completed++)));
    await tester.pump(const Duration(milliseconds: 400));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 4));
    expect(completed, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(completed, 0);
    await tester.pump(const Duration(seconds: 2));
    expect(completed, 1);
  });
  testWidgets('disposing a reduced-motion opening cancels its timer', (
    tester,
  ) async {
    var completed = 0;
    await tester.pumpWidget(
      shell(OpeningPage(onComplete: () => completed++), reduced: true),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
    expect(completed, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('skip opens home and settings updates never replay the opening', (
    tester,
  ) async {
    final settings = AppSettings(MemorySettingsRepository());
    await tester.pumpWidget(AnimalApp(settings: settings));
    expect(find.byType(OpeningPage), findsOneWidget);
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();
    expect(find.text('Quem vai brincar?'), findsOneWidget);
    await chooseLearner(tester, 'Meu Cachorro');
    await tester.pumpAndSettle();
    expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
    await settings.update(sound: true, calm: false);
    await tester.pumpAndSettle();
    expect(find.byType(OpeningPage), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
  testWidgets(
    'animated opening transitions to profile selection without user action',
    (tester) async {
      final settings = AppSettings(MemorySettingsRepository());
      await settings.update(calm: false);
      await tester.pumpWidget(AnimalApp(settings: settings));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(OpeningPage), findsNothing);
      expect(find.text('Quem vai brincar?'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );
  testWidgets('opening fits a small phone with text at 200 percent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    var completed = false;
    await tester.pumpWidget(
      shell(OpeningPage(onComplete: () => completed = true)),
    );
    await tester.ensureVisible(find.text('Começar agora'));
    await tester.tap(find.text('Começar agora'));
    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('celebration animates once and has no infinite ticker', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: shell(
          Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: AnimalCelebration(animal: animals.first),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    if (const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
      await capturePreview(tester, key, 'celebration');
    }
    await tester.pumpAndSettle();
    expect(find.byType(AnimalCelebration), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('celebration respects system reduced motion', (tester) async {
    await tester.pumpWidget(
      shell(
        Scaffold(body: AnimalCelebration(animal: animals.first)),
        reduced: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(
      find.bySemanticsLabel('Cachorro comemorando seu acerto'),
      findsOneWidget,
    );
  });
}
