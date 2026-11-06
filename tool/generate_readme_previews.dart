import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/theme/app_theme.dart';
import 'package:bicho_a_bicho/features/games/domain/drawing_template.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_page.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/games/presentation/memory_controller.dart';
import 'package:bicho_a_bicho/features/progress/presentation/learning_report.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/support/fakes.dart';
import '../test/support/localization.dart';
import '../test/support/profile_navigation.dart';

const _phoneSize = Size(430, 932);
const _outputDirectory = 'docs/previews/readme';

/// Run with: flutter test tool/generate_readme_previews.dart
void main() {
  setUpAll(() async {
    await (FontLoader(
      'Nunito',
    )..addFont(rootBundle.load('fonts/Nunito.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('export current app screens for the README', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = AppSettings(MemorySettingsRepository());
    addTearDown(settings.dispose);
    await settings.createProfile(animalId: 'cat');
    await settings.createProfile(animalId: 'elephant');
    await settings.createProfile(animalId: 'duck');

    tester.view.physicalSize = _phoneSize;
    final appKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: appKey,
        child: AnimalApp(settings: settings),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();
    await _capture(tester, appKey, 'profiles');
    await chooseLearner(tester, 'Meu Cachorro');
    await tester.pumpAndSettle();
    await _capture(tester, appKey, 'home');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bichinhos'));
    await tester.pumpAndSettle();
    await _capture(tester, appKey, 'animals');
    await tester.pumpWidget(const SizedBox());

    for (final game in games) {
      tester.view.physicalSize = _phoneSize;
      final model = GameViewModel(
        session: GameSession(
          kind: game.kind,
          choiceCount: 3,
          rounds: 4,
          random: Random(game.kind == GameKind.drawing ? 3 : 2),
        ),
        audio: FakeAudio(),
        speech: FakeSpeech(),
        onObservation: settings.recorderForActiveProfile(),
      );
      if (game.kind == GameKind.counting) {
        await model.next();
        await model.next();
      }
      if (game.kind == GameKind.drawing) {
        final contour = drawingTemplates[model.round.animal.id]!.contour;
        final drawing = model.drawing!;
        drawing.begin(contour.first);
        for (final point in contour.skip(1)) {
          drawing.append(point);
        }
        drawing.end();
        drawing.showGuide(true);
      }
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: _app(
            GamePage(game: game, settings: settings, viewModel: model),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _capture(tester, key, 'game_${game.kind.name}');
      if (game.kind == GameKind.memory) {
        model.memory.start();
        await tester.pump(MemoryController.flipDuration);
        await tester.pump(MemoryController.shuffleDuration);
        await tester.pump(MemoryController.shuffleDuration);
        await tester.pumpAndSettle();
        await _capture(tester, key, 'game_memory_hidden');
      } else if (game.kind != GameKind.drawing) {
        model.showHint();
        model.answer(model.round.answer);
      }
      await tester.pumpWidget(const SizedBox());
    }

    tester.view.physicalSize = _phoneSize;
    final reportKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: reportKey,
        child: _app(
          Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: LearningReport(settings: settings),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _capture(tester, reportKey, 'report');
    await tester.pumpWidget(const SizedBox());
  });
}

Widget _app(Widget home) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.create(),
  locale: const Locale('pt', 'BR'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: home,
);

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final pictures = tester.widgetList<Image>(find.byType(Image)).toList();
  await tester.runAsync(() async {
    for (final picture in pictures) {
      await precacheImage(picture.image, key.currentContext!);
    }
  });
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'Rendering $name');
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final screen = await boundary.toImage(pixelRatio: 2);
    final image = await _framePhone(screen);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$_outputDirectory/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
      screen.dispose();
    }
  });
}

/// Adds a device frame around an unmodified capture of the real Flutter UI.
Future<ui.Image> _framePhone(ui.Image screen) async {
  const margin = 16.0;
  const bezel = 12.0;
  const endBezel = 28.0;
  const scale = 2.0;
  final deviceSize = Size(
    _phoneSize.width + bezel * 2,
    _phoneSize.height + endBezel * 2,
  );
  final outputSize = Size(
    deviceSize.width + margin * 2,
    deviceSize.height + margin * 2,
  );
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(scale);
  final device = RRect.fromRectAndRadius(
    const Offset(margin, margin) & deviceSize,
    const Radius.circular(42),
  );
  canvas.drawShadow(Path()..addRRect(device), const Color(0x55000000), 8, true);
  canvas.drawRRect(device, Paint()..color = const Color(0xFF222A2D));
  canvas.drawRRect(
    device.deflate(2),
    Paint()
      ..color = const Color(0xFF596166)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1,
  );
  final display = RRect.fromRectAndRadius(
    const Offset(margin + bezel, margin + endBezel) & _phoneSize,
    const Radius.circular(28),
  );
  canvas.save();
  canvas.clipRRect(display);
  canvas.drawImageRect(
    screen,
    Rect.fromLTWH(0, 0, screen.width.toDouble(), screen.height.toDouble()),
    display.outerRect,
    Paint()..filterQuality = FilterQuality.high,
  );
  canvas.restore();
  final centerX = outputSize.width / 2;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 20, margin + 11, 40, 4),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFF0B1012),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - 48, margin + deviceSize.height - 15, 96, 4),
      const Radius.circular(2),
    ),
    Paint()..color = const Color(0xFFBBC1C3),
  );
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(
      (outputSize.width * scale).round(),
      (outputSize.height * scale).round(),
    );
  } finally {
    picture.dispose();
  }
}
