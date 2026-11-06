import 'dart:math';

import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'package:bicho_a_bicho/features/games/domain/drawing_template.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/drawing_controller.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/progress/domain/learning_history.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_analytics.dart';
import 'support/fakes.dart';

void trace(DrawingController drawing, List<Point<double>> points) {
  drawing.begin(points.first);
  for (final point in points.skip(1)) {
    drawing.append(point);
  }
  drawing.end();
}

void main() {
  test(
    'drawing requires geometry, deduplicates checks and records only explicit submissions',
    () async {
      final settings = AppSettings(MemorySettingsRepository());
      final analytics = RecordingAnalytics();
      final audio = FakeAudio();
      final model = GameViewModel(
        session: GameSession(
          kind: GameKind.drawing,
          choiceCount: 3,
          rounds: 2,
          random: Random(2),
        ),
        audio: audio,
        speech: FakeSpeech(),
        analytics: analytics,
        onObservation: settings.recorderForActiveProfile(),
        soundEnabled: () => true,
      );
      model.answer(
        model.round.answer,
      ); // Selecting a label cannot win a drawing round.
      model.checkDrawing();
      expect(model.feedback, RoundFeedback.none);
      trace(
        model.drawing!,
        List.generate(20, (i) => Point<double>(i / 20, i / 20)),
      );
      model.checkDrawing();
      model.checkDrawing();
      expect(model.feedback, RoundFeedback.retry);
      expect(settings.learningHistory.summarize(0).errors, 1);
      model.drawing!.clear();
      model.showHint();
      model.drawing!.showGuide(true);
      trace(model.drawing!, drawingTemplates[model.round.animal.id]!.contour);
      final count = model.drawing!.paths.expand((p) => p).length;
      await model.pause();
      model.checkDrawing();
      expect(model.drawing!.paths.expand((p) => p).length, count);
      model.resume();
      model.checkDrawing();
      model.checkDrawing();
      await Future<void>.delayed(Duration.zero);
      expect(model.feedback, RoundFeedback.correct);
      expect(audio.playedAssets, [GameViewModel.celebrationAsset]);
      final stats = settings.learningHistory.summarize(
        0,
        game: GameKind.drawing,
        choices: 0,
      );
      expect(stats.answered, 1);
      expect(stats.correct, 1);
      expect(stats.errors, 1);
      expect(stats.hints, 1);
      expect(stats.firstTry, 0);
      final event = analytics.events.lastWhere(
        (e) => e.$1 == UsageEvent.answerSubmitted,
      );
      expect(event.$2[UsageParameter.inputMethod], 'drawing');
      expect(
        analytics.events.every((e) => validatedParameters(e.$2) != null),
        isTrue,
      );
      await model.next();
      expect(model.drawing!.hasInk, isFalse);
      expect(model.drawing!.guide, isFalse);
      model.dispose();
      await settings.retrySave();
      expect(
        LearningHistory.decode(
          settings.learningHistory.encode(),
        ).summarize(0, choices: 0).errors,
        1,
      );
      settings.dispose();
    },
  );

  test(
    'undo and clear remove strokes; leaving the canvas cannot connect across it',
    () {
      final drawing = DrawingController();
      trace(drawing, [const Point(.1, .1), const Point(.2, .2)]);
      trace(drawing, [const Point(.3, .3), const Point(.4, .4)]);
      drawing.undo();
      expect(drawing.paths.length, 1);
      drawing.begin(const Point(.5, .5));
      drawing.append(const Point(1.2, .5));
      drawing.append(const Point(.7, .7));
      expect(drawing.paths.last.length, 1);
      drawing.clear();
      expect(drawing.hasInk, isFalse);
      drawing.begin(const Point(double.nan, .5));
      expect(drawing.hasInk, isFalse);
      drawing.dispose();
    },
  );

  test('limits both stroke count and point count to bound memory', () {
    final drawing = DrawingController();
    for (var i = 0; i < 100; i++) {
      trace(drawing, [const Point(.1, .1), const Point(.2, .2)]);
    }
    expect(drawing.paths.length, DrawingController.maxStrokes);
    drawing.clear();
    drawing.begin(const Point(.1, .1));
    for (var i = 0; i < 5000; i++) {
      drawing.append(Point<double>(i.isEven ? .2 : .8, .5));
    }
    expect(drawing.paths.expand((p) => p).length, DrawingController.maxPoints);
    drawing.dispose();
  });
}
