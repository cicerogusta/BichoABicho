import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/memory_board.dart';

enum MemoryPhase {
  preview,
  hiding,
  gathering,
  shuffling,
  playing,
  comparing,
  complete,
}

class MemoryController extends ChangeNotifier {
  MemoryController({
    required this.board,
    required this.onResult,
    Random? random,
  }) : _random = random ?? Random();

  static const flipDuration = Duration(milliseconds: 450);
  static const shuffleDuration = Duration(milliseconds: 650);
  static const comparisonDuration = Duration(milliseconds: 1400);

  final MemoryBoard board;
  final ValueChanged<bool> onResult;
  final Random _random;
  MemoryPhase _phase = MemoryPhase.preview;
  MemoryPhase get phase => _phase;
  Timer? _timer;
  bool _paused = false;
  bool _disposed = false;
  int _attempts = 0;
  int get attempts => _attempts;

  bool get canSelect => !_paused && _phase == MemoryPhase.playing;
  bool visible(int id) => _phase == MemoryPhase.preview || board.isRevealed(id);

  void start() {
    if (_paused || _disposed || _phase != MemoryPhase.preview) return;
    _phase = MemoryPhase.hiding;
    _schedule();
    notifyListeners();
  }

  void _schedule() {
    _timer?.cancel();
    final duration = switch (_phase) {
      MemoryPhase.hiding => flipDuration,
      MemoryPhase.gathering || MemoryPhase.shuffling => shuffleDuration,
      MemoryPhase.comparing => comparisonDuration,
      _ => null,
    };
    if (duration == null) return;
    _timer = Timer(duration, () {
      if (_paused || _disposed) return;
      _phase = switch (_phase) {
        MemoryPhase.hiding => MemoryPhase.gathering,
        MemoryPhase.gathering => MemoryPhase.shuffling,
        _ => MemoryPhase.playing,
      };
      if (_phase == MemoryPhase.shuffling) board.shuffle(_random);
      if (_phase == MemoryPhase.playing) board.hideSelection();
      _schedule();
      notifyListeners();
    });
  }

  void select(int id) {
    if (!canSelect || _disposed) return;
    final result = board.select(id);
    if (result == MemorySelection.ignored) return;
    if (result == MemorySelection.mismatch || result == MemorySelection.match) {
      _attempts++;
    }
    if (result == MemorySelection.mismatch) {
      _phase = MemoryPhase.comparing;
      _schedule();
      onResult(false);
    } else if (board.complete) {
      _phase = MemoryPhase.complete;
      onResult(true);
    }
    notifyListeners();
  }

  void pause() {
    _paused = true;
    _timer?.cancel();
  }

  void resume() {
    if (!_paused || _disposed) return;
    _paused = false;
    _schedule();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
