import 'dart:async';
import 'package:flutter/material.dart';
import '../core/analytics/usage_analytics.dart';
import '../features/progress/presentation/profile_selection_page.dart';
import '../features/settings/presentation/app_settings.dart';

/// Session confirmation is deliberately not restored from disk on shared devices.
class LearnerEntry extends StatefulWidget {
  const LearnerEntry({
    super.key,
    required this.settings,
    required this.home,
    required this.analytics,
  });
  final AppSettings settings;
  final Widget home;
  final UsageAnalytics analytics;
  @override
  State<LearnerEntry> createState() => _LearnerEntryState();
}

class _LearnerEntryState extends State<LearnerEntry> {
  bool _needsSelection = true;
  @override
  void initState() {
    super.initState();
    widget.analytics.rootScreen(UsageScreen.profileSelection);
  }

  void _select(int profile) {
    if (!_needsSelection) return;
    unawaited(widget.settings.selectProfile(profile));
    setState(() => _needsSelection = false);
  }

  @override
  Widget build(BuildContext context) => _needsSelection
      ? ProfileSelectionPage(settings: widget.settings, onSelected: _select)
      : widget.home;
}
