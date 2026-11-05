import 'dart:math';
import 'drawing_template.dart';

class DrawingAssessment {
  const DrawingAssessment({
    required this.accepted,
    required this.coverage,
    required this.precision,
    required this.features,
  });
  const DrawingAssessment.empty()
    : accepted = false,
      coverage = 0,
      precision = 0,
      features = 0;
  final bool accepted;
  final double coverage, precision, features;
  double get score => coverage * .45 + precision * .35 + features * .20;
}

/// Geometric contour matching, not a general animal/image classifier.
class DrawingEvaluator {
  const DrawingEvaluator();
  static const sampleCount = 128;
  static const contourTolerance = .075;
  static const featureTolerance = .095;

  DrawingAssessment evaluate(
    Iterable<Iterable<Point<double>>> strokes,
    DrawingTemplate template,
  ) {
    final paths = strokes
        .map((s) => s.where((p) => p.x.isFinite && p.y.isFinite).toList())
        .where((s) => s.length >= 2)
        .toList();
    final all = paths.expand((s) => s).toList();
    if (all.length < 6 || all.length > 4096) {
      return const DrawingAssessment.empty();
    }
    final bounds = _Bounds(all);
    if (bounds.width < .15 || bounds.height < .15) {
      return const DrawingAssessment.empty();
    }
    final input = _sample(paths, sampleCount).map(bounds.normalize).toList();
    final referenceBounds = _Bounds(template.contour);
    final reference = _sample([
      template.contour,
    ], sampleCount).map(referenceBounds.normalize).toList();
    final features = template.features.map(referenceBounds.normalize).toList();
    var best = const DrawingAssessment.empty();
    for (final mirror in [1.0, -1.0]) {
      for (final angle in [-pi / 18, 0.0, pi / 18]) {
        final cloud = input
            .map(
              (p) => Point<double>(
                p.x * mirror * cos(angle) - p.y * sin(angle),
                p.x * mirror * sin(angle) + p.y * cos(angle),
              ),
            )
            .toList();
        final coverage = _fractionNear(reference, cloud, contourTolerance);
        final precision = _fractionNear(cloud, reference, contourTolerance);
        final distinctive = _fractionNear(features, cloud, featureTolerance);
        final assessment = DrawingAssessment(
          accepted: coverage >= .76 && precision >= .78 && distinctive >= 2 / 3,
          coverage: coverage,
          precision: precision,
          features: distinctive,
        );
        if (assessment.accepted) return assessment;
        if (assessment.score > best.score) best = assessment;
      }
    }
    return best;
  }

  double _fractionNear(
    List<Point<double>> source,
    List<Point<double>> target,
    double tolerance,
  ) {
    if (source.isEmpty || target.isEmpty) return 0;
    final squared = tolerance * tolerance;
    return source
            .where((a) => target.any((b) => a.squaredDistanceTo(b) <= squared))
            .length /
        source.length;
  }

  List<Point<double>> _sample(List<List<Point<double>>> paths, int count) {
    final segments = <({Point<double> a, Point<double> b, double length})>[];
    var total = 0.0;
    for (final path in paths) {
      for (var i = 1; i < path.length; i++) {
        final length = path[i - 1].distanceTo(path[i]);
        if (length <= 0) continue;
        segments.add((a: path[i - 1], b: path[i], length: length));
        total += length;
      }
    }
    if (total == 0) return [];
    var segmentIndex = 0;
    var traversed = 0.0;
    return List.generate(count, (i) {
      final distance = total * i / (count - 1);
      while (segmentIndex < segments.length - 1 &&
          traversed + segments[segmentIndex].length < distance) {
        traversed += segments[segmentIndex++].length;
      }
      final segment = segments[segmentIndex];
      final t = ((distance - traversed) / segment.length).clamp(0.0, 1.0);
      return segment.a + (segment.b - segment.a) * t;
    });
  }
}

class _Bounds {
  _Bounds(List<Point<double>> points)
    : left = points.map((p) => p.x).reduce(min),
      right = points.map((p) => p.x).reduce(max),
      top = points.map((p) => p.y).reduce(min),
      bottom = points.map((p) => p.y).reduce(max);
  final double left, right, top, bottom;
  double get width => right - left;
  double get height => bottom - top;
  Point<double> normalize(Point<double> p) => Point(
    (p.x - (left + right) / 2) / max(width, height),
    (p.y - (top + bottom) / 2) / max(width, height),
  );
}
