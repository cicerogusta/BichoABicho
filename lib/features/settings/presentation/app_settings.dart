import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/settings_repository.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../games/domain/game_definition.dart';
import '../../progress/domain/learning_history.dart';
import '../../progress/domain/profile_catalog.dart';

class AppSettings extends ChangeNotifier {
  AppSettings(this._repository, {this.analytics = const NoopUsageAnalytics()});
  final SettingsRepository _repository;
  final UsageAnalytics analytics;
  static const analyticsConsentVersion = 1;
  bool _analyticsEnabled = false;
  bool get analyticsEnabled => _analyticsEnabled;
  bool _soundEnabled = false;
  bool _calmMode = true;
  int _choiceCount = 2;
  int _rounds = 4;
  bool _storageFailed = false;
  bool get soundEnabled => _soundEnabled;
  bool get calmMode => _calmMode;
  int get choiceCount => _choiceCount;
  int get rounds => _rounds;
  bool get storageFailed => _storageFailed;
  final Map<String, int> _completed = {};
  Future<void> _pendingSave = Future<void>.value();
  LearningHistory _learningHistory = LearningHistory.empty();
  LearningHistory get learningHistory => _learningHistory;
  int _activeProfile = 0;
  int get activeProfile => _activeProfile;
  ProfileCatalog _catalog = ProfileCatalog.initial();
  List<LearnerProfile> get profiles => _catalog.profiles;
  LearnerProfile profile(int id) => _catalog.profile(id);
  bool profileIsConfigured(int id) => profile(id).configured;
  String profileLabel(int id) => profile(id).label;
  bool _disposed = false;

  Future<int> createProfile({
    required String animalId,
    String name = '',
  }) async {
    final id = _catalog.nextId;
    _catalog = _catalog.create(animalId: animalId, name: name);
    notifyListeners();
    await _save();
    return id;
  }

  Future<void> updateProfile(int id, {String? name, String? animalId}) {
    _catalog = _catalog.update(id, name: name, animalId: animalId);
    notifyListeners();
    return _save();
  }

  Future<void> selectProfile(int profile) {
    if (!_catalog.contains(profile)) {
      throw ArgumentError.value(profile, 'profile');
    }
    _activeProfile = profile;
    notifyListeners();
    return _save();
  }

  /// Captures the profile when the game opens, so later changes cannot reassign it.
  void Function(LearningObservation) recorderForActiveProfile() {
    final profile = _activeProfile;
    return (observation) {
      if (_disposed) return;
      _learningHistory = _learningHistory.record(profile, observation);
      unawaited(_save());
    };
  }

  Future<void> clearProfileHistory({int? profile}) {
    _learningHistory = _learningHistory.clear(profile ?? _activeProfile);
    notifyListeners();
    return _save();
  }

  Future<void> retrySave() => _save();

  int completed(String game) => _completed[game] ?? 0;
  int get totalCompleted =>
      _completed.values.fold(0, (sum, count) => sum + count);

  Future<void> load() async {
    try {
      final values = await _repository.load();
      _soundEnabled = values['sound'] == true;
      _calmMode = values['calm'] != false;
      _choiceCount = values['choices'] == 3 ? 3 : 2;
      _rounds = values['rounds'] == 6 ? 6 : 4;
      _analyticsEnabled =
          values['analytics_enabled'] == true &&
          values['analytics_version'] == analyticsConsentVersion;
      for (final game in GameKind.values) {
        _completed[game.name] =
            ((values['completed_${game.name}'] as int?) ?? 0).clamp(0, 1000000);
      }
      final history = values['learning_history'];
      if (history is String && history.isNotEmpty) {
        _learningHistory = LearningHistory.decode(history);
      }
      final catalog = values['profile_catalog'];
      _catalog = catalog is String && catalog.isNotEmpty
          ? ProfileCatalog.decode(catalog)
          : ProfileCatalog.migrate(values, _learningHistory.profileIds);
      final active = values['active_profile'];
      _activeProfile = active is int && _catalog.contains(active)
          ? active
          : profiles.first.id;
      _storageFailed = false;
    } on Exception {
      _storageFailed = true;
    }
    _updateAnalyticsPreferences();
    notifyListeners();
  }

  Future<bool> setAnalyticsConsent(bool enabled) async {
    _analyticsEnabled = enabled;
    notifyListeners();
    await _save();
    if (_storageFailed && enabled) {
      _analyticsEnabled = false;
      notifyListeners();
    }
    return !_storageFailed;
  }

  void _updateAnalyticsPreferences() => analytics.preferences(
    sound: _soundEnabled,
    reducedMotion: _calmMode,
    choices: _choiceCount,
    rounds: _rounds,
  );

  Future<void> update({
    bool? sound,
    bool? calm,
    int? choices,
    int? sessionRounds,
  }) {
    final previous = {
      'sound_enabled': '$_soundEnabled',
      'reduced_motion': '$_calmMode',
      'choice_count': '$_choiceCount',
      'round_count': '$_rounds',
    };
    if (sound != null) _soundEnabled = sound;
    if (calm != null) _calmMode = calm;
    if (choices != null) _choiceCount = choices == 3 ? 3 : 2;
    if (sessionRounds != null) _rounds = sessionRounds == 6 ? 6 : 4;
    final current = {
      'sound_enabled': '$_soundEnabled',
      'reduced_motion': '$_calmMode',
      'choice_count': '$_choiceCount',
      'round_count': '$_rounds',
    };
    for (final entry in current.entries) {
      if (previous[entry.key] != entry.value) {
        analytics.event(
          UsageEvent.settingsChanged,
          parameters: {
            UsageParameter.setting: entry.key,
            UsageParameter.value: entry.value,
          },
        );
      }
    }
    _updateAnalyticsPreferences();
    notifyListeners();
    return _save();
  }

  Future<void> recordCompletion(String game) {
    _completed[game] = completed(game) + 1;
    notifyListeners();
    return _save();
  }

  Future<void> resetProgress() {
    _completed.clear();
    _learningHistory = LearningHistory.empty();
    analytics.event(UsageEvent.progressReset);
    notifyListeners();
    return _save();
  }

  Future<void> _save() {
    final snapshot = <String, Object>{
      'sound': _soundEnabled,
      'calm': _calmMode,
      'choices': _choiceCount,
      'rounds': _rounds,
      'analytics_enabled': _analyticsEnabled,
      'analytics_version': analyticsConsentVersion,
      'active_profile': _activeProfile,
      'profile_catalog': _catalog.encode(),
      'learning_history': _learningHistory.encode(),
      for (final game in GameKind.values)
        'completed_${game.name}': completed(game.name),
    };
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _repository.save(snapshot);
        _storageFailed = false;
      } on Exception {
        _storageFailed = true;
      }
      if (!_disposed) notifyListeners();
    });
    return _pendingSave;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
