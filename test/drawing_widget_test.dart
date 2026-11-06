import 'dart:math';

import 'package:bicho_a_bicho/core/theme/app_theme.dart';
import 'package:bicho_a_bicho/features/games/domain/drawing_template.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_page.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/games/presentation/widgets/animal_celebration.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/capture_preview.dart';
import 'support/fakes.dart';
import 'support/localization.dart';

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Nunito',
    )..addFont(rootBundle.load('fonts/Nunito.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'drawing canvas, undo, retry, pause and successful trace at scale $scale',
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
            kind: GameKind.drawing,
            choiceCount: 2,
            rounds: 1,
            random: Random(3),
          ),
          audio: FakeAudio(),
          speech: FakeSpeech(),
          onObservation: settings.recorderForActiveProfile(),
        );
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.create(),
              home: GamePage(
                game: games.singleWhere((g) => g.kind == GameKind.drawing),
                settings: settings,
                viewModel: model,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final board = find.byKey(const ValueKey('drawing_board'));
        await tester.ensureVisible(board);
        await tester.pumpAndSettle();
        final rect = tester.getRect(board);
        final gesture = await tester.startGesture(
          rect.topLeft + Offset(rect.width * .1, rect.height * .1),
        );
        for (var i = 2; i < 9; i++) {
          await gesture.moveTo(
            rect.topLeft + Offset(rect.width * i / 10, rect.height * i / 10),
          );
        }
        await gesture.up();
        await tester.pumpAndSettle();
        expect(model.drawing!.hasInk, isTrue);
        await tester.ensureVisible(find.text('Conferir desenho'));
        await tester.tap(find.text('Conferir desenho'));
        await tester.pumpAndSettle();
        expect(model.feedback, RoundFeedback.retry);
        await tester.ensureVisible(find.text('Limpar'));
        await tester.tap(find.text('Limpar'));
        await tester.pumpAndSettle();
        expect(model.drawing!.hasInk, isFalse);
        await tester.tap(find.text('Quero uma dica'));
        await tester.pumpAndSettle();
        expect(model.drawing!.guide, isTrue);
        await tester.tap(find.byTooltip('Fazer uma pausa'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continuar brincando'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(board);
        await tester.pumpAndSettle();
        final canvas = tester.getRect(board);
        final outline = drawingTemplates[model.round.animal.id]!.contour;
        final pen = await tester.startGesture(
          canvas.topLeft +
              Offset(
                outline.first.x * canvas.width,
                outline.first.y * canvas.height,
              ),
        );
        final otherFinger = await tester.startGesture(
          canvas.bottomRight - const Offset(12, 12),
          pointer: 99,
        );
        for (var i = 1; i < outline.length; i++) {
          final a = outline[i - 1];
          final b = outline[i];
          for (var j = 1; j <= 4; j++) {
            final p = a + (b - a) * (j / 4);
            await pen.moveTo(
              canvas.topLeft + Offset(p.x * canvas.width, p.y * canvas.height),
            );
            await tester.pump(const Duration(milliseconds: 16));
          }
        }
        await pen.up();
        await otherFinger.up();
        await tester.pumpAndSettle();
        expect(model.drawing!.paths.length, 1);
        expect(
          model.drawing!.hasInk,
          isTrue,
          reason: 'Canvas before $canvas; after ${tester.getRect(board)}',
        );
        if (scale == 1 && const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
          await capturePreview(tester, key, 'game_drawing');
        }
        await tester.ensureVisible(find.text('Conferir desenho'));
        await tester.tap(find.text('Conferir desenho'));
        await tester.pumpAndSettle();
        expect(model.feedback, RoundFeedback.correct);
        expect(find.byType(AnimalCelebration), findsOneWidget);
        await tester.ensureVisible(find.text('Concluir brincadeira'));
        await tester.tap(find.text('Concluir brincadeira'));
        await tester.pumpAndSettle();
        expect(settings.completed('drawing'), 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        settings.dispose();
      },
    );
  }
}
