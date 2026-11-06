import 'package:flutter/material.dart';

import '../core/analytics/usage_analytics.dart';
import '../features/opening/presentation/opening_page.dart';

/// Kept above the home page so settings updates and returning from a game do not replay the opening.
class AppEntry extends StatefulWidget {
  const AppEntry({
    super.key,
    required this.home,
    this.analytics = const NoopUsageAnalytics(),
  });
  final Widget home;
  final UsageAnalytics analytics;
  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _ready = false;
  bool _skipped = false;
  @override
  void initState() {
    super.initState();
    widget.analytics.rootScreen(UsageScreen.opening);
  }

  void _complete() {
    widget.analytics.event(
      UsageEvent.openingFinished,
      parameters: {UsageParameter.reason: _skipped ? 'skipped' : 'completed'},
    );
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 400),
    switchInCurve: Curves.easeOut,
    child: _ready
        ? widget.home
        : OpeningPage(onComplete: _complete, onSkipped: () => _skipped = true),
  );
}
