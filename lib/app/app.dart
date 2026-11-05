import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_page.dart';
import '../features/settings/presentation/app_settings.dart';
import '../features/account/data/firebase_account_repository.dart';
import '../features/account/presentation/account_page.dart';
import '../features/account/presentation/account_view_model.dart';
import 'app_entry.dart';
import 'learner_entry.dart';
import '../core/analytics/analytics_controller.dart';
import '../core/analytics/usage_analytics.dart';
import '../core/analytics/usage_navigator_observer.dart';

class AnimalApp extends StatefulWidget {
  const AnimalApp({super.key, required this.settings, this.analytics});
  final AppSettings settings;
  final AnalyticsController? analytics;
  @override
  State<AnimalApp> createState() => _AnimalAppState();
}

class _AnimalAppState extends State<AnimalApp> {
  late final UsageNavigatorObserver _observer = UsageNavigatorObserver(
    widget.analytics ?? const NoopUsageAnalytics(),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: (context, _) => MaterialApp(
      title: 'Bicho a Bicho',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_observer],
      theme: AppTheme.create(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations:
                media.disableAnimations || widget.settings.calmMode,
          ),
          child: child!,
        );
      },
      home: AppEntry(
        analytics: widget.analytics ?? const NoopUsageAnalytics(),
        home: LearnerEntry(
          settings: widget.settings,
          analytics: widget.analytics ?? const NoopUsageAnalytics(),
          home: HomePage(
            settings: widget.settings,
            analytics: widget.analytics,
            accountBuilder: (_) => AccountPage(
              viewModel: AccountViewModel(
                FirebaseAccountRepository(),
                analytics: widget.analytics ?? const NoopUsageAnalytics(),
              ),
              analytics: widget.analytics ?? const NoopUsageAnalytics(),
            ),
          ),
        ),
      ),
    ),
  );
}
