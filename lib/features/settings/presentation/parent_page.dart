import 'dart:async';

import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/analytics/analytics_controller.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../games/presentation/game_catalog.dart';
import '../../progress/presentation/learning_report.dart';
import '../../progress/presentation/profile_settings_card.dart';
import 'analytics_settings_card.dart';
import 'app_settings.dart';

class ParentPage extends StatelessWidget {
  const ParentPage({
    super.key,
    required this.settings,
    required this.accountBuilder,
    this.analytics,
  });
  final AppSettings settings;
  final WidgetBuilder accountBuilder;
  final AnalyticsController? analytics;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              context.l10n.parentsTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(context.l10n.parentsDescription),
            const SizedBox(height: 24),
            ProfileSettingsCard(settings: settings),
            const SizedBox(height: 24),
            LearningReport(settings: settings),
            const SizedBox(height: 24),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    value: settings.soundEnabled,
                    onChanged: (value) =>
                        unawaited(settings.update(sound: value)),
                    title: Text(context.l10n.soundSetting),
                    subtitle: Text(context.l10n.soundSettingDescription),
                  ),
                  SwitchListTile.adaptive(
                    value: settings.calmMode,
                    onChanged: (value) =>
                        unawaited(settings.update(calm: value)),
                    title: Text(context.l10n.reducedMotionSetting),
                    subtitle: Text(context.l10n.reducedMotionDescription),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.choicesSetting,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            for (final n in [2, 3])
                              ChoiceChip(
                                label: Text(context.l10n.choiceCount(n)),
                                selected: settings.choiceCount == n,
                                onSelected: (_) =>
                                    unawaited(settings.update(choices: n)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.l10n.roundsSetting,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            for (final n in [4, 6])
                              ChoiceChip(
                                label: Text(context.l10n.sessionRoundCount(n)),
                                selected: settings.rounds == n,
                                onSelected: (_) => unawaited(
                                  settings.update(sessionRounds: n),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(context.l10n.settingsNextGame),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (settings.storageFailed)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.settingsStorageFailure),
              ),
            const SizedBox(height: 24),
            Text(
              context.l10n.completedGamesTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.completedGamesDescription),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                children: [
                  for (final game in gameCatalog(context.l10n))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.pets_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(game.title)),
                          Text(
                            '${settings.completed(game.kind.name)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _reset(context),
                child: Text(context.l10n.clearLocalHistory),
              ),
            ),
            const SizedBox(height: 16),
            SoftCard(
              color: AppColors.sage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.educationalPurpose,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(context.l10n.educationalAlignment),
                  const SizedBox(height: 12),
                  Text(context.l10n.educationalReassurance),
                  const SizedBox(height: 12),
                  Text(context.l10n.sharedReadingGuidance),
                  const SizedBox(height: 12),
                  Text(context.l10n.educationalSources),
                  const SizedBox(height: 12),
                  Text(context.l10n.educationalDisclaimer),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.privacyAndAccount,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (analytics != null) ...[
              const SizedBox(height: 16),
              AnalyticsSettingsCard(analytics: analytics!),
            ],
            const SizedBox(height: 12),
            Text(context.l10n.privacyDescription),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  settings: RouteSettings(name: UsageScreen.accountLogin.name),
                  builder: accountBuilder,
                ),
              ),
              icon: const Icon(Icons.person_outline_rounded),
              label: Text(context.l10n.optionalAccount),
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: context.l10n.appTitle,
              ),
              icon: const Icon(Icons.info_outline),
              label: Text(context.l10n.licenses),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(context.l10n.resetHistoryTitle),
        content: Text(context.l10n.resetHistoryDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.keepHistory),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) await settings.resetProgress();
  }
}
