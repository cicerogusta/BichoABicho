import 'dart:math';
import 'package:bicho_a_bicho/features/games/domain/drawing_evaluator.dart';
import 'package:bicho_a_bicho/features/games/domain/drawing_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluator = DrawingEvaluator();
  for (final template in drawingTemplates.values) {
    test(
      '${template.animalId} accepts an approximate contour with translation, scale and reversed strokes',
      () {
        final random = Random(6);
        final approximate = template.contour
            .map(
              (p) => Point<double>(
                p.x * .8 + .12 + (random.nextDouble() - .5) * .03,
                p.y * .8 + .07 + (random.nextDouble() - .5) * .03,
              ),
            )
            .toList();
        for (final path in [
          template.contour,
          approximate,
          approximate.reversed.toList(),
          template.contour.map((p) => Point<double>(1 - p.x, p.y)).toList(),
        ]) {
          final result = evaluator.evaluate([path], template);
          expect(
            result.accepted,
            isTrue,
            reason:
                '${result.coverage}, ${result.precision}, ${result.features}',
          );
        }
        final middle = template.contour.length ~/ 2;
        final split = [
          template.contour.sublist(middle).reversed,
          template.contour.sublist(0, middle + 1).reversed,
        ];
        expect(evaluator.evaluate(split, template).accepted, isTrue);
      },
    );
    test(
      '${template.animalId} rejects empty, line, circle, rectangle and dense scribble',
      () {
        final circle = List.generate(
          128,
          (i) => Point<double>(
            .5 + .35 * cos(2 * pi * i / 127),
            .5 + .35 * sin(2 * pi * i / 127),
          ),
        );
        final line = List.generate(20, (i) => Point<double>(i / 20, i / 20));
        final rectangle = <Point<double>>[
          const Point(.1, .1),
          const Point(.9, .1),
          const Point(.9, .9),
          const Point(.1, .9),
          const Point(.1, .1),
          const Point(.9, .1),
        ];
        final scribble = List.generate(
          24,
          (i) => [Point<double>(.02, i / 25), Point<double>(.98, i / 25)],
        );
        for (final paths in <List<List<Point<double>>>>[
          [],
          [line],
          [circle],
          [rectangle],
          scribble,
        ]) {
          final result = evaluator.evaluate(paths, template);
          expect(
            result.accepted,
            isFalse,
            reason:
                '${template.animalId} accepted ${paths.length} paths: ${result.coverage}, ${result.precision}, ${result.features}',
          );
        }
      },
    );
    test('${template.animalId} requires its distinctive animal contour', () {
      for (final other in drawingTemplates.values.where(
        (t) => t.animalId != template.animalId,
      )) {
        final result = evaluator.evaluate([other.contour], template);
        expect(
          result.accepted,
          isFalse,
          reason:
              '${other.animalId} accepted as ${template.animalId}: ${result.coverage}, ${result.precision}, ${result.features}',
        );
      }
    });
  }
}
