import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../../core/services/animal_audio.dart';
import '../../../core/services/animal_speech.dart';
import 'game_media_message.dart';

/// Owns media operations and invalidates callbacks after cancellation or disposal.
/// Game rules remain in GameViewModel; this controller only reports recognition.
class GameMediaController extends ChangeNotifier {
  GameMediaController({
    required this.audio,
    required this.speech,
    required this.soundEnabled,
    required this.isActive,
    required this.canListen,
    required this.animalSound,
    required this.matchesAnimal,
    required this.onRecognized,
    required this.onEvent,
  });
  final AnimalAudio audio;
  final AnimalSpeech speech;
  final bool Function() soundEnabled;
  final bool Function() isActive;
  final bool Function() canListen;
  final String Function() animalSound;
  final bool Function(String) matchesAnimal;
  final VoidCallback onRecognized;
  final void Function(UsageEvent, Map<UsageParameter, Object>) onEvent;
  static const celebrationAsset = 'celebration.wav';
  int _generation = 0;
  bool _disposed = false;
  bool _mediaBusy = false;
  bool _startingSpeech = false;
  bool _listening = false;
  GameMediaMessage? _mediaMessage;
  bool get mediaBusy => _mediaBusy;
  bool get listening => _listening;
  GameMediaMessage? get mediaMessage => _mediaMessage;
  void clearMessage() {
    _mediaMessage = null;
  }

  void _track(
    UsageEvent event, {
    Map<UsageParameter, Object> parameters = const {},
  }) => onEvent(event, parameters);

  Future<void> celebrate() async {
    final stopping = stopMedia();
    final generation = _generation;
    await stopping;
    if (_disposed ||
        !isActive() ||
        generation != _generation ||
        !soundEnabled()) {
      return;
    }
    try {
      await audio.play(celebrationAsset);
    } on Exception {
      if (!_disposed && generation == _generation) {
        _track(
          UsageEvent.mediaUnavailable,
          parameters: {UsageParameter.feature: 'celebration_audio'},
        );
        _mediaMessage = GameMediaMessage.celebrationUnavailable;
        notifyListeners();
      }
    }
  }

  Future<void> stopListening() async {
    if (_disposed) return;
    if (_listening) {
      _track(
        UsageEvent.speechFinished,
        parameters: {UsageParameter.result: 'cancelled'},
      );
    }
    await stopMedia();
    if (!_disposed) {
      _mediaMessage = GameMediaMessage.speechRetry;
      notifyListeners();
    }
  }

  Future<void> playSound(bool enabled) async {
    if (_disposed || _mediaBusy || _listening || !isActive()) return;
    _track(UsageEvent.animalSoundRequested);
    if (!enabled) {
      _mediaMessage = GameMediaMessage.soundDisabled;
      notifyListeners();
      return;
    }
    final generation = ++_generation;
    _mediaBusy = true;
    _mediaMessage = null;
    notifyListeners();
    try {
      await audio.play(animalSound());
    } on Exception {
      if (!_disposed && generation == _generation) {
        _track(
          UsageEvent.mediaUnavailable,
          parameters: {UsageParameter.feature: 'animal_audio'},
        );
        _mediaMessage = GameMediaMessage.soundUnavailable;
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _mediaBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> listen() async {
    if (_disposed ||
        _listening ||
        _startingSpeech ||
        _mediaBusy ||
        !canListen()) {
      return;
    }
    _startingSpeech = true;
    final pendingStop = stopMedia();
    final preparationGeneration = _generation;
    await pendingStop;
    _startingSpeech = false;
    if (_disposed || !isActive() || preparationGeneration != _generation) {
      return;
    }
    final generation = ++_generation;
    _listening = true;
    _track(UsageEvent.speechStarted);
    _mediaMessage = GameMediaMessage.listening;
    notifyListeners();
    bool active() => !_disposed && generation == _generation;
    var reported = false;
    var unavailableReported = false;
    void report(String result) {
      if (!reported) {
        reported = true;
        _track(
          UsageEvent.speechFinished,
          parameters: {UsageParameter.result: result},
        );
      }
    }

    void unavailable() {
      if (!active() || unavailableReported) return;
      unavailableReported = true;
      report('unavailable');
      _track(
        UsageEvent.mediaUnavailable,
        parameters: {UsageParameter.feature: 'speech'},
      );
      _listening = false;
      _mediaMessage = GameMediaMessage.speechUnavailable;
      notifyListeners();
    }

    try {
      final available = await speech.listen(
        onFinal: (words) {
          if (!active()) return;
          _listening = false;
          if (matchesAnimal(words)) {
            report('recognized');
            onRecognized();
          } else {
            report('no_match');
            _mediaMessage = GameMediaMessage.speechNoMatch;
            notifyListeners();
          }
        },
        onDone: () {
          if (active()) {
            report('no_match');
            _listening = false;
            _mediaMessage = GameMediaMessage.speechFinished;
            notifyListeners();
          }
        },
        onError: unavailable,
      );
      if (!available) unavailable();
      if (!active()) await speech.cancel();
    } on Exception {
      unavailable();
    }
  }

  Future<void> stopMedia() async {
    if (_disposed) return;
    _generation++;
    _listening = false;
    _mediaBusy = false;
    try {
      await Future.wait([speech.cancel(), audio.stop()]);
    } on Exception {
      if (!_disposed) _mediaMessage = GameMediaMessage.audioUnavailable;
    }
  }

  Future<void> _release() async {
    try {
      await Future.wait([speech.cancel(), audio.dispose()]);
    } on Exception {
      /* Platform may already be detached during shutdown. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_release());
    super.dispose();
  }
}
