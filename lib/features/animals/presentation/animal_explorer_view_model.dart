import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/analytics/usage_analytics.dart';
import '../../../core/services/animal_audio.dart';
import '../domain/animal.dart';

enum ExplorerMessage { soundDisabled, soundUnavailable }

class AnimalExplorerViewModel extends ChangeNotifier {
  AnimalExplorerViewModel(
    this._audio, {
    required this.soundEnabled,
    this.analytics = const NoopUsageAnalytics(),
  });

  final AnimalAudio _audio;
  final bool Function() soundEnabled;
  final UsageAnalytics analytics;
  bool _disposed = false;
  bool _busy = false;
  int _generation = 0;
  ExplorerMessage? _message;
  bool get busy => _busy;
  ExplorerMessage? get message => _message;

  Future<void> play(Animal animal) async {
    if (_disposed || _busy) return;
    analytics.event(
      UsageEvent.animalSoundRequested,
      parameters: {UsageParameter.animalId: animal.id},
    );
    if (!soundEnabled()) {
      _message = ExplorerMessage.soundDisabled;
      notifyListeners();
      return;
    }
    final generation = ++_generation;
    _busy = true;
    _message = null;
    notifyListeners();
    try {
      await _audio.play(animal.sound);
    } on Exception {
      if (!_disposed && generation == _generation) {
        analytics.event(
          UsageEvent.mediaUnavailable,
          parameters: {UsageParameter.feature: 'animal_audio'},
        );
        _message = ExplorerMessage.soundUnavailable;
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    _generation++;
    if (_busy) {
      _busy = false;
      notifyListeners();
    }
    try {
      await _audio.stop();
    } on Exception {
      if (!_disposed) {
        _message = ExplorerMessage.soundUnavailable;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_release());
    super.dispose();
  }

  Future<void> _release() async {
    try {
      await _audio.dispose();
    } on Exception {
      // The platform may have detached while the feature was closing.
    }
  }
}
