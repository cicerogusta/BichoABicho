import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'core/analytics/analytics_controller.dart';
import 'core/analytics/firebase_analytics_backend.dart';
import 'app/app.dart';
import 'features/settings/data/preferences_repository.dart';
import 'features/settings/presentation/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Sons dos animais',
    ], await rootBundle.loadString('assets/audio_credits.txt'));
  });
  late final AppSettings settings;
  final analytics = AnalyticsController(
    FirebaseAnalyticsBackend(),
    persistConsent: (enabled) => settings.setAnalyticsConsent(enabled),
  );
  settings = AppSettings(PreferencesRepository(), analytics: analytics);
  await settings.load();
  runApp(AnimalApp(settings: settings, analytics: analytics));
  unawaited(analytics.initialize(settings.analyticsEnabled));
}
