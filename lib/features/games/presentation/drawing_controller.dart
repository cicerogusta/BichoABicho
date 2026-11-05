import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';

class DrawingController extends ChangeNotifier {
  static const maxPoints = 4096;
  static const maxStrokes = 64;
  final List<List<Point<double>>> _paths = [];
  bool _drawing = false;
  bool _guide = false;
  int _revision = 0;
  int _points = 0;
  int get revision => _revision;
  bool get hasInk => _points > 0;
  bool get guide => _guide;
  bool get full => _points >= maxPoints || _paths.length >= maxStrokes;
  Iterable<Iterable<Point<double>>> get paths =>
      _paths.map(UnmodifiableListView.new);

  bool _inside(Point<double> point) =>
      point.x.isFinite &&
      point.y.isFinite &&
      point.x >= 0 &&
      point.x <= 1 &&
      point.y >= 0 &&
      point.y <= 1;
  void begin(Point<double> point) {
    if (!_inside(point) || full) return;
    _paths.add([point]);
    _drawing = true;
    _points++;
    _changed();
  }

  void append(Point<double> point) {
    if (!_drawing) return;
    if (!_inside(point)) {
      end();
      return;
    }
    if (_points >= maxPoints || point.distanceTo(_paths.last.last) < .003) {
      return;
    }
    _paths.last.add(point);
    _points++;
    _changed();
  }

  void end() => _drawing = false;
  void undo() {
    end();
    if (_paths.isEmpty) return;
    _points -= _paths.removeLast().length;
    _changed();
  }

  void clear() {
    end();
    if (!hasInk) return;
    _paths.clear();
    _points = 0;
    _changed();
  }

  void showGuide(bool value) {
    _guide = value;
    notifyListeners();
  }

  void reset() {
    _guide = false;
    clear();
  }

  void _changed() {
    _revision++;
    notifyListeners();
  }

  @override
  void dispose() {
    _drawing = false;
    _paths.clear();
    _points = 0;
    super.dispose();
  }
}
