import 'dart:async';
import 'package:bicho_a_bicho/core/analytics/analytics_backend.dart';
import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';

class FakeAnalyticsBackend implements AnalyticsBackend {
  @override
  bool supported = true;
  bool fail = false;
  bool failDisable = false;
  final List<bool> configurations = [];
  final List<String> screens = [];
  final List<(String, Map<String, Object>)> events = [];
  final List<Map<String, String>> propertySnapshots = [];
  int resets = 0;
  Completer<void>? configureGate;
  Completer<void>? propertiesGate;
  @override
  Future<void> configure(bool enabled) async {
    configurations.add(enabled);
    if (!enabled && failDisable) throw Exception('Cannot contact platform');
    if (fail && enabled) throw Exception('Unavailable');
    if (enabled && configureGate != null) await configureGate!.future;
  }

  @override
  Future<void> event(String name, Map<String, Object> parameters) async {
    if (fail) throw Exception('Unavailable');
    events.add((name, Map.of(parameters)));
  }

  @override
  Future<void> screen(String name) async {
    screens.add(name);
  }

  @override
  Future<void> properties(Map<String, String> values) async {
    if (propertiesGate != null) await propertiesGate!.future;
    propertySnapshots.add(Map.of(values));
  }

  @override
  Future<void> reset() async {
    resets++;
  }
}

class RecordingAnalytics implements UsageAnalytics {
  final List<(UsageEvent, Map<UsageParameter, Object>)> events = [];
  final List<UsageScreen> screens = [];
  Map<String, Object> preferenceValues = {};
  @override
  void event(
    UsageEvent event, {
    Map<UsageParameter, Object> parameters = const {},
  }) {
    events.add((event, Map.of(parameters)));
  }

  @override
  void screen(UsageScreen screen) {
    screens.add(screen);
  }

  @override
  void rootScreen(UsageScreen screen) {
    this.screen(screen);
  }

  @override
  void routeScreen(UsageScreen? screen) {
    if (screen != null) this.screen(screen);
  }

  @override
  void preferences({
    required bool sound,
    required bool reducedMotion,
    required int choices,
    required int rounds,
  }) {
    preferenceValues = {
      'sound': sound,
      'reducedMotion': reducedMotion,
      'choices': choices,
      'rounds': rounds,
    };
  }
}
