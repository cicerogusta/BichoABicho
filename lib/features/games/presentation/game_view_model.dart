import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/analytics/usage_analytics.dart';
import '../../../core/services/animal_audio.dart';
import '../../../core/services/animal_speech.dart';
import '../../animals/domain/animal.dart';
import '../../progress/domain/learning_history.dart';
import '../domain/drawing_evaluator.dart';
import '../domain/drawing_template.dart';
import '../domain/game_definition.dart';
import '../domain/game_session.dart';
import '../domain/memory_board.dart';
import 'drawing_controller.dart';
import 'game_media_controller.dart';
import 'game_media_message.dart';
import 'memory_controller.dart';

enum RoundFeedback { none, retry, correct }

class GameViewModel extends ChangeNotifier {
  GameViewModel({
    required this.session,
    required AnimalAudio audio,
    required AnimalSpeech speech,
    bool Function()? soundEnabled,
    this.analytics = const NoopUsageAnalytics(),
    this.onObservation,
  }) {
    _media = GameMediaController(
      audio: audio,
      speech: speech,
      soundEnabled: () => soundEnabled?.call() ?? false,
      isActive: () => !_disposed && !_paused && !_finished && !_advancing,
      canListen: () => _acceptsAnswer && session.kind == GameKind.speaking,
      animalSound: () => round.animal.sound,
      matchesAnimal: (words) => normalizeWords(
        words,
      ).split(' ').contains(normalizeWords(round.animal.name)),
      onRecognized: () => answer(round.answer, byVoice: true),
      onEvent: (event, parameters) => _track(event, parameters: parameters),
    )..addListener(_onMediaChanged);
    _track(UsageEvent.gameStarted, round: false);
    _track(UsageEvent.roundStarted);
    _observe(LearningAction.started);
  }
  late final GameMediaController _media;
  void _onMediaChanged() {
    if (!_disposed) notifyListeners();
  }

  final GameSession session;
  final UsageAnalytics analytics;
  final void Function(LearningObservation)? onObservation;
  late final DrawingController? drawing = session.kind == GameKind.drawing
      ? DrawingController()
      : null;
  int _lastDrawingRevision = -1;
  MemoryController? _memory;
  MemoryController get memory => _memory ??= MemoryController(
    board: MemoryBoard(round.choices.map((choice) => choice.animal!).toList()),
    onResult: (correct) {
      if (_acceptsAnswer) _submitResult(correct, inputMethod: 'touch');
    },
  );

  bool get _acceptsAnswer =>
      !_disposed &&
      !_paused &&
      !_finished &&
      !_advancing &&
      _feedback != RoundFeedback.correct;

  void checkDrawing() {
    final sketch = drawing;
    if (!_acceptsAnswer ||
        sketch == null ||
        !sketch.hasInk ||
        sketch.revision == _lastDrawingRevision) {
      return;
    }
    sketch.end();
    _lastDrawingRevision = sketch.revision;
    final result = const DrawingEvaluator().evaluate(
      sketch.paths,
      drawingTemplates[round.animal.id]!,
    );
    _submitResult(result.accepted, inputMethod: 'drawing');
  }

  void _observe(LearningAction action, {bool firstAttempt = false}) {
    onObservation?.call(
      LearningObservation(
        game: session.kind,
        animalId: round.animal.id,
        choices: round.choices.length,
        action: action,
        firstAttempt: firstAttempt,
      ),
    );
  }

  final Stopwatch _sessionWatch = Stopwatch()..start();
  final Stopwatch _roundWatch = Stopwatch()..start();
  int _attempts = 0;
  int _correctRounds = 0;
  int _skippedRounds = 0;

  void _track(
    UsageEvent event, {
    Map<UsageParameter, Object> parameters = const {},
    bool round = true,
  }) {
    analytics.event(
      event,
      parameters: {
        UsageParameter.gameId: session.kind.name,
        UsageParameter.roundCount: session.rounds.length,
        UsageParameter.choiceCount: session.rounds.first.choices.length,
        if (round) ...{
          UsageParameter.roundIndex: _index + 1,
          UsageParameter.animalId: this.round.animal.id,
        },
        ...parameters,
      },
    );
  }

  static const celebrationAsset = GameMediaController.celebrationAsset;
  int _index = 0;

  bool _disposed = false;

  bool _advancing = false;

  bool _paused = false;
  bool _finished = false;
  bool _hintVisible = false;

  RoundFeedback _feedback = RoundFeedback.none;
  final Set<String> _attempted = {};
  final Set<int> _countedAnimals = {};
  Set<int> get countedAnimals => Set.unmodifiable(_countedAnimals);
  bool get listening => _media.listening;
  bool get paused => _paused;
  bool get finished => _finished;
  bool get hintVisible => _hintVisible;
  GameMediaMessage? get mediaMessage => _media.mediaMessage;
  RoundFeedback get feedback => _feedback;
  Set<String> get attempted => Set.unmodifiable(_attempted);
  int get index => _index;
  GameRound get round => session.rounds[_index];
  bool get mediaBusy => _media.mediaBusy;

  void answer(String value, {bool byVoice = false}) {
    if (!_acceptsAnswer ||
        session.kind == GameKind.drawing ||
        session.kind == GameKind.memory) {
      return;
    }
    if (!round.choices.any((choice) => choice.value == value)) return;
    _submitResult(
      value == round.answer,
      inputMethod: byVoice ? 'voice' : 'touch',
      attemptedValue: value,
    );
  }

  void _submitResult(
    bool correct, {
    required String inputMethod,
    String? attemptedValue,
  }) {
    _feedback = correct ? RoundFeedback.correct : RoundFeedback.retry;
    _attempts++;
    _observe(
      _feedback == RoundFeedback.correct
          ? LearningAction.correct
          : LearningAction.incorrect,
      firstAttempt: _attempts == 1,
    );
    if (_feedback == RoundFeedback.correct) {
      _correctRounds++;
      _roundWatch.stop();
    }
    _track(
      UsageEvent.answerSubmitted,
      parameters: {
        UsageParameter.result: _feedback == RoundFeedback.correct
            ? 'correct'
            : 'retry',
        UsageParameter.inputMethod: inputMethod,
        UsageParameter.attempts: _attempts,
        UsageParameter.durationMs: _roundWatch.elapsedMilliseconds.clamp(
          0,
          86400000,
        ),
      },
    );
    if (_feedback == RoundFeedback.retry && attemptedValue != null) {
      _attempted.add(attemptedValue);
    }
    _media.clearMessage();
    unawaited(
      _feedback == RoundFeedback.correct ? _media.celebrate() : stopMedia(),
    );
    notifyListeners();
  }

  void showHint() {
    if (_disposed ||
        _paused ||
        _finished ||
        _advancing ||
        _hintVisible ||
        _feedback == RoundFeedback.correct) {
      return;
    }
    _track(UsageEvent.hintUsed);
    _observe(LearningAction.hint);
    _hintVisible = true;
    notifyListeners();
  }

  void countAnimal(int index) {
    if (_paused ||
        _finished ||
        _feedback == RoundFeedback.correct ||
        index < 0 ||
        index >= round.quantity) {
      return;
    }
    if (_countedAnimals.add(index)) {
      _track(
        UsageEvent.animalCounted,
        parameters: {UsageParameter.counted: _countedAnimals.length},
      );
      notifyListeners();
    }
  }

  Future<void> stopListening() => _media.stopListening();

  Future<void> next() async {
    if (_disposed || _paused || _finished || _advancing) return;
    _advancing = true;
    if (_feedback != RoundFeedback.correct) {
      _skippedRounds++;
      _observe(LearningAction.skipped);
      _track(
        UsageEvent.roundSkipped,
        parameters: {
          UsageParameter.attempts: _attempts,
          UsageParameter.durationMs: _roundWatch.elapsedMilliseconds.clamp(
            0,
            86400000,
          ),
        },
      );
    }
    await stopMedia();
    if (_disposed) return;
    _memory?.dispose();
    _memory = null;
    if (_index == session.rounds.length - 1) {
      _finished = true;
      _sessionWatch.stop();
      _roundWatch.stop();
      _track(
        UsageEvent.gameCompleted,
        round: false,
        parameters: {
          UsageParameter.correctRounds: _correctRounds,
          UsageParameter.skippedRounds: _skippedRounds,
          UsageParameter.durationMs: _sessionWatch.elapsedMilliseconds.clamp(
            0,
            86400000,
          ),
        },
      );
    } else {
      _index++;
      drawing?.reset();
      _lastDrawingRevision = -1;
      _feedback = RoundFeedback.none;
      _attempted.clear();
      _countedAnimals.clear();
      _hintVisible = false;
      _media.clearMessage();
      _attempts = 0;
      _roundWatch
        ..reset()
        ..start();
      _track(UsageEvent.roundStarted);
      _observe(LearningAction.started);
    }
    _advancing = false;
    notifyListeners();
  }

  Future<void> playSound(bool enabled) => _media.playSound(enabled);

  Future<void> listen() => _media.listen();

  Future<void> stopMedia() => _media.stopMedia();

  Future<void> pause({bool fromBackground = false}) async {
    drawing?.end();
    if (_disposed || _paused || _finished) return;
    _sessionWatch.stop();
    _roundWatch.stop();
    _track(
      UsageEvent.gamePaused,
      parameters: {
        UsageParameter.reason: fromBackground ? 'background' : 'user',
      },
    );
    _paused = true;
    _memory?.pause();
    notifyListeners();
    await stopMedia();
  }

  void resume() {
    if (_disposed || !_paused) return;
    _sessionWatch.start();
    if (_feedback != RoundFeedback.correct) _roundWatch.start();
    _track(UsageEvent.gameResumed);
    _paused = false;
    _memory?.resume();
    _media.clearMessage();
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionWatch.stop();
    _roundWatch.stop();
    if (!_finished) {
      _track(
        UsageEvent.gameAbandoned,
        round: false,
        parameters: {
          UsageParameter.correctRounds: _correctRounds,
          UsageParameter.skippedRounds: _skippedRounds,
          UsageParameter.durationMs: _sessionWatch.elapsedMilliseconds.clamp(
            0,
            86400000,
          ),
        },
      );
    }
    _disposed = true;
    drawing?.dispose();
    _memory?.dispose();
    _media.removeListener(_onMediaChanged);
    _media.dispose();
    super.dispose();
  }
}
