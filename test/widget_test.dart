import 'support/profile_navigation.dart';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/theme/app_theme.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_page.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/games/presentation/widgets/animal_celebration.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/features/animals/domain/animal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fakes.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('Nunito')
      ..addFont(rootBundle.load('fonts/Nunito.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1280, 900),
    const Size(844, 390),
  ]) {
    testWidgets('home renders without overflow at ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = AppSettings(MemorySettingsRepository());
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: AnimalApp(settings: settings),
        ),
      );
      await _settleHome(tester);
      expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'docs/previews/home_${size.width.toInt()}x${size.height.toInt()}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    });
  }
  testWidgets('navigation and parent preferences work without Firebase', (
    tester,
  ) async {
    final settings = AppSettings(MemorySettingsRepository());
    await tester.pumpWidget(AnimalApp(settings: settings));
    await _settleHome(tester);
    await tester.tap(find.text('Bichinhos'));
    await _settleHome(tester);
    expect(find.text('Conheça a nossa turma'), findsOneWidget);
    await tester.tap(find.text('Responsáveis'));
    await _settleHome(tester);
    await tester.ensureVisible(find.text('3 opções'));
    await tester.tap(find.text('3 opções'));
    await _settleHome(tester);
    expect(settings.choiceCount, 3);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
  for (final game in games.where((game) => game.kind != GameKind.drawing)) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        '${game.kind} renders at phone width with text scale $scale',
        (tester) async {
          tester.view.physicalSize = Size(scale == 1 ? 390 : 320, 844);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final settings = AppSettings(MemorySettingsRepository());
          final model = GameViewModel(
            session: GameSession(
              kind: game.kind,
              choiceCount: 3,
              rounds: 4,
              random: Random(2),
            ),
            audio: FakeAudio(),
            speech: FakeSpeech(),
          );
          if (game.kind == GameKind.counting) {
            await model.next();
            await model.next();
          }
          final key = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: key,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.create(),
                home: GamePage(
                  game: game,
                  settings: settings,
                  viewModel: model,
                ),
              ),
            ),
          );
          await _settleHome(tester);
          expect(tester.takeException(), isNull);
          if (scale == 1 && const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
            await _capture(tester, key, 'game_${game.kind.name}');
          }
          await tester.pumpWidget(const SizedBox());
          settings.dispose();
        },
      );
    }
    testWidgets(
      '${game.kind} supports retry, hint, pause and a completed session by touch',
      (tester) async {
        final settings = AppSettings(MemorySettingsRepository());
        final model = GameViewModel(
          session: GameSession(
            kind: game.kind,
            choiceCount: 2,
            rounds: 1,
            random: Random(1),
          ),
          audio: FakeAudio(),
          speech: FakeSpeech(),
        );
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.create(),
            home: GamePage(game: game, settings: settings, viewModel: model),
          ),
        );
        await _settleHome(tester);
        final wrong = model.round.choices.firstWhere(
          (c) => c.value != model.round.answer,
        );
        await tester.ensureVisible(find.text(wrong.label));
        await tester.tap(find.text(wrong.label));
        await _settleHome(tester);
        expect(
          find.text('Vamos observar mais um pouquinho? Tente outra opção.'),
          findsOneWidget,
        );
        if (game.kind == GameKind.stories) {
          expect(find.text(model.round.story!.question), findsOneWidget);
          expect(find.text('Cena 1'), findsOneWidget);
          expect(find.text('Cena 2'), findsOneWidget);
        }
        await tester.ensureVisible(find.text('Quero uma dica'));
        await tester.tap(find.text('Quero uma dica'));
        await _settleHome(tester);
        expect(model.hintVisible, isTrue);
        await tester.tap(find.byTooltip('Fazer uma pausa'));
        await _settleHome(tester);
        expect(find.text('Vamos fazer uma pausa.'), findsOneWidget);
        await tester.tap(find.text('Continuar brincando'));
        await _settleHome(tester);
        final correct = model.round.choices.firstWhere(
          (c) => c.value == model.round.answer,
        );
        await tester.ensureVisible(find.text(correct.label));
        await tester.tap(find.text(correct.label));
        await _settleHome(tester);
        expect(find.text('Você descobriu!'), findsOneWidget);
        expect(find.byType(AnimalCelebration), findsOneWidget);
        if (game.kind == GameKind.stories) {
          expect(find.text(model.round.story!.question), findsOneWidget);
          expect(find.text('Cena 1'), findsOneWidget);
          expect(find.text('Cena 2'), findsOneWidget);
        }
        await tester.ensureVisible(find.text('Concluir brincadeira'));
        await tester.tap(find.text('Concluir brincadeira'));
        await _settleHome(tester);
        expect(find.text('Que bom descobrir com você!'), findsOneWidget);
        expect(settings.completed(game.kind.name), 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        settings.dispose();
      },
    );
  }
  testWidgets('catalog references valid bundled images and sounds', (
    tester,
  ) async {
    for (final animal in animals) {
      final image = await rootBundle.load(animal.image);
      expect(image.getUint32(16), lessThanOrEqualTo(1600));
      expect(image.getUint32(20), lessThanOrEqualTo(1600));
      expect(
        (await rootBundle.load('assets/${animal.sound}')).lengthInBytes,
        greaterThan(0),
      );
    }
  });
  testWidgets('home exposes labeled actions with accessible touch targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final settings = AppSettings(MemorySettingsRepository());
    await tester.pumpWidget(AnimalApp(settings: settings));
    await _settleHome(tester);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Jogar Encontre o bichinho'))
          .getSemanticsData()
          .hasAction(ui.SemanticsAction.tap),
      isTrue,
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
  testWidgets('large text keeps the home accessible on a small phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final settings = AppSettings(MemorySettingsRepository());
    await tester.pumpWidget(AnimalApp(settings: settings));
    await _settleHome(tester);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final pictures = tester.widgetList<Image>(find.byType(Image)).toList();
  await tester.runAsync(() async {
    for (final picture in pictures) {
      await precacheImage(picture.image, key.currentContext!);
    }
  });
  await _settleHome(tester);
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('docs/previews/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

// Home tests skip the opening; its timing and lifecycle are covered separately.
Future<void> _settleHome(WidgetTester tester) async {
  await tester.pumpAndSettle();
  if (find.text('Começar agora').evaluate().isNotEmpty) {
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();
  }
  if (find.text('Quem vai brincar?').evaluate().isNotEmpty) {
    await chooseLearner(tester, 'Meu Cachorro');
    await tester.pumpAndSettle();
  }
}
