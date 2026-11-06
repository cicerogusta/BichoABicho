import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/widgets/soft_card.dart';

class AnalyticsSettingsCard extends StatelessWidget {
  const AnalyticsSettingsCard({super.key, required this.analytics});
  final AnalyticsController analytics;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: analytics,
    builder: (context, _) => SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.analyticsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(context.l10n.analyticsDescription),
          const SizedBox(height: 12),
          Text(context.l10n.analyticsPrivacy),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.shareUsageData),
            value: analytics.consentGranted,
            onChanged: !analytics.supported || analytics.busy
                ? null
                : (enabled) async {
                    if (enabled) {
                      final agreed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          scrollable: true,
                          title: Text(context.l10n.analyticsConsentTitle),
                          content: Text(
                            context.l10n.analyticsConsentDescription,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.l10n.declineConsent),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.l10n.grantConsent),
                            ),
                          ],
                        ),
                      );
                      if (agreed != true) return;
                    }
                    await analytics.setConsent(enabled);
                  },
          ),
          if (analytics.busy)
            Text(context.l10n.analyticsApplying)
          else if (!analytics.supported)
            Text(context.l10n.analyticsNotConfigured)
          else if (analytics.status == AnalyticsStatus.failed)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.analyticsFailed),
                TextButton(
                  onPressed: () =>
                      analytics.setConsent(analytics.consentGranted),
                  child: Text(context.l10n.tryAgain),
                ),
              ],
            )
          else
            Text(
              analytics.enabled
                  ? context.l10n.analyticsEnabled
                  : context.l10n.analyticsDisabled,
            ),
        ],
      ),
    ),
  );
}
