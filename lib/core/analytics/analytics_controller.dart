import 'dart:async';
import 'package:flutter/foundation.dart';
import 'analytics_backend.dart';
import 'usage_analytics.dart';

enum AnalyticsStatus { disabled, initializing, active, unavailable, failed }

class AnalyticsController extends ChangeNotifier implements UsageAnalytics {
  AnalyticsController(this._backend, {required this.persistConsent});
  final AnalyticsBackend _backend;
  final Future<bool> Function(bool) persistConsent;
  Future<void> _queue = Future<void>.value();
  int _generation = 0;
  bool _enabled = false;
  bool _consentGranted = false;
  bool _disposed = false;
  bool _rootActive = true;
  UsageScreen _root = UsageScreen.opening;
  UsageScreen _current = UsageScreen.opening;
  AnalyticsStatus _status = AnalyticsStatus.disabled;
  Map<String, String> _properties = {};
  UsageScreen? _reportedScreen;
  bool get enabled => _enabled;
  bool get consentGranted => _consentGranted;
  bool get supported => _backend.supported;
  bool get busy => _status == AnalyticsStatus.initializing;
  AnalyticsStatus get status => _status;
  Future<void> get idle => _queue;

  Future<void> initialize(bool enabled) =>
      _applyConsent(enabled, persist: false);
  Future<void> setConsent(bool enabled) =>
      _applyConsent(enabled, persist: true);

  Future<void> _applyConsent(bool enabled, {required bool persist}) {
    if (_disposed) return Future<void>.value();
    final generation = ++_generation;
    final initialScreen = _current;
    final initialProperties = Map<String, String>.unmodifiable(_properties);
    _enabled = enabled && supported;
    _consentGranted = enabled && supported;
    _status = supported
        ? AnalyticsStatus.initializing
        : AnalyticsStatus.unavailable;
    notifyListeners();
    return _enqueue(() async {
      if (generation != _generation || _disposed) return;
      if (!supported) {
        if (persist) await persistConsent(false);
        return;
      }
      if (!enabled) {
        var saved = true;
        try {
          await _backend.configure(false);
          await _backend.reset();
          await _backend.configure(false);
        } finally {
          // A platform failure must not prevent saving a withdrawal locally.
          if (persist) saved = await persistConsent(false);
        }
        if (generation == _generation && !_disposed) {
          _status = saved ? AnalyticsStatus.disabled : AnalyticsStatus.failed;
          notifyListeners();
        }
        return;
      }
      if (persist && !await persistConsent(true)) {
        await _backend.configure(false);
        if (generation == _generation && !_disposed) {
          _enabled = false;
          _consentGranted = false;
          _status = AnalyticsStatus.failed;
          notifyListeners();
        }
        return;
      }
      if (generation != _generation || _disposed) return;
      await _backend.configure(true);
      if (generation != _generation || _disposed) {
        await _backend.configure(false);
        return;
      }
      await _backend.properties(initialProperties);
      if (generation != _generation || _disposed || !_enabled) return;
      if (persist) {
        await _backend.event(UsageEvent.consentGranted.wireName, {
          'schema_version': 1,
        });
      }
      if (generation != _generation || _disposed || !_enabled) return;
      _reportedScreen = null;
      await _reportScreen(initialScreen);
      if (generation != _generation || _disposed || !_enabled) return;
      _status = AnalyticsStatus.active;
      notifyListeners();
    });
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final operationGeneration = _generation;
    _queue = _queue.then((_) async {
      try {
        await operation();
      } on Exception {
        try {
          if (supported) await _backend.configure(false);
        } on Exception {
          /* Keep the app usable if the platform is unavailable. */
        }
        if (!_disposed && operationGeneration == _generation) {
          _enabled = false;
          _status = AnalyticsStatus.failed;
          notifyListeners();
        }
      }
    });
    return _queue;
  }

  void _send(Future<void> Function() operation) {
    if (!_enabled || _disposed) return;
    final generation = _generation;
    unawaited(
      _enqueue(() async {
        if (_enabled &&
            !_disposed &&
            generation == _generation &&
            _status == AnalyticsStatus.active) {
          await operation();
        }
      }),
    );
  }

  @override
  void event(
    UsageEvent event, {
    Map<UsageParameter, Object> parameters = const {},
  }) {
    final safe = validatedParameters(parameters);
    if (safe == null) return;
    _send(() => _backend.event(event.wireName, {'schema_version': 1, ...safe}));
  }

  @override
  void screen(UsageScreen screen) {
    if (_current == screen) return;
    _current = screen;
    _send(() => _reportScreen(screen));
  }

  Future<void> _reportScreen(UsageScreen screen) async {
    if (_reportedScreen == screen) return;
    await _backend.screen(screen.name);
    _reportedScreen = screen;
  }

  @override
  void rootScreen(UsageScreen screen) {
    _root = screen;
    if (_rootActive) this.screen(screen);
  }

  @override
  void routeScreen(UsageScreen? screen) {
    _rootActive = screen == null;
    this.screen(screen ?? _root);
  }

  @override
  void preferences({
    required bool sound,
    required bool reducedMotion,
    required int choices,
    required int rounds,
  }) {
    if (![2, 3].contains(choices) || ![4, 6].contains(rounds)) return;
    _properties = {
      'sound_enabled': '$sound',
      'reduced_motion': '$reducedMotion',
      'choice_count': '$choices',
      'round_count': '$rounds',
    };
    final snapshot = Map<String, String>.unmodifiable(_properties);
    _send(() => _backend.properties(snapshot));
  }

  @override
  void dispose() {
    _disposed = true;
    _enabled = false;
    _generation++;
    super.dispose();
  }
}
