import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../core/analytics/analytics_controller.dart';
import '../core/analytics/usage_analytics.dart';
import '../core/analytics/usage_navigator_observer.dart';
import '../core/theme/app_theme.dart';
import '../features/account/presentation/account_page.dart';
import '../features/account/presentation/account_view_model.dart';
import '../features/home/presentation/home_page.dart';
import '../features/settings/presentation/app_settings.dart';
import 'app_dependencies.dart';
import 'app_entry.dart';
import 'learner_entry.dart';

class AnimalApp extends StatefulWidget {
  const AnimalApp({
    super.key,
    required this.settings,
    this.analytics,
    this.dependencies,
  });
  final AppSettings settings;
  final AnalyticsController? analytics;
  final AppDependencies? dependencies;
  @override
  State<AnimalApp> createState() => _AnimalAppState();
}

class _AnimalAppState extends State<AnimalApp> {
  late final AppDependencies _dependencies =
      widget.dependencies ?? AppDependencies.platform();
  late final UsageNavigatorObserver _observer = UsageNavigatorObserver(
    widget.analytics ?? const NoopUsageAnalytics(),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: (context, _) => MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [_observer],
      theme: AppTheme.create(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
            createGame: (game) => _dependencies.createGame(
              game,
              widget.settings,
              widget.analytics ?? const NoopUsageAnalytics(),
            ),
            createAudio: _dependencies.createAudio,
            settings: widget.settings,
            analytics: widget.analytics,
            accountBuilder: (_) => AccountPage(
              viewModel: AccountViewModel(
                _dependencies.accountRepository,
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
