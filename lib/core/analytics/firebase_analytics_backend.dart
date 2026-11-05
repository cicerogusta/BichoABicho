import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'analytics_backend.dart';

class FirebaseAnalyticsBackend implements AnalyticsBackend {
  FirebaseAnalytics? _analytics;
  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<FirebaseAnalytics> _instance() async {
    if (_analytics != null) return _analytics!;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return _analytics = FirebaseAnalytics.instance;
  }

  @override
  Future<void> configure(bool enabled) async {
    if (!supported) return;
    // The native defaults are also denied, including when Authentication starts Firebase.
    final analytics = await _instance();
    if (!enabled) await analytics.setAnalyticsCollectionEnabled(false);
    await analytics.setConsent(
      analyticsStorageConsentGranted: enabled,
      adStorageConsentGranted: false,
      adUserDataConsentGranted: false,
      adPersonalizationSignalsConsentGranted: false,
    );
    await analytics.setUserId(id: null);
    if (enabled) await analytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> event(String name, Map<String, Object> parameters) async =>
      (await _instance()).logEvent(name: name, parameters: parameters);
  @override
  Future<void> screen(String name) async => (await _instance()).logScreenView(
    screenName: name,
    screenClass: 'FlutterScreen',
  );
  @override
  Future<void> properties(Map<String, String> values) async {
    final analytics = await _instance();
    for (final entry in values.entries) {
      await analytics.setUserProperty(name: entry.key, value: entry.value);
    }
  }

  @override
  Future<void> reset() async {
    if (_analytics != null) await _analytics!.resetAnalyticsData();
  }
}
