import 'dart:async';

import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/analytics/usage_analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../games/domain/game_definition.dart';
import '../../games/presentation/game_catalog.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/learning_history.dart';
import 'profile_labels.dart';
import 'profile_selection_page.dart';

class LearningReport extends StatefulWidget {
  const LearningReport({super.key, required this.settings});
  final AppSettings settings;
  @override
  State<LearningReport> createState() => _LearningReportState();
}

class _LearningReportState extends State<LearningReport> {
  late int _reportProfile = widget.settings.activeProfile;
  GameKind? _game;
  int? _choices;

  Future<void> _chooseProfile() async {
    final profile = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        settings: RouteSettings(name: UsageScreen.reportProfileSelection.name),
        builder: (context) => ProfileSelectionPage(
          settings: widget.settings,
          allowBack: true,
          allowCreation: false,
          configureUnnamed: false,
          onSelected: (id) => Navigator.pop(context, id),
        ),
      ),
    );
    if (profile != null && mounted) setState(() => _reportProfile = profile);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: (context, _) {
      final games = gameCatalog(context.l10n);
      final settings = widget.settings;
      final history = settings.learningHistory;
      final total = history.summarize(
        _reportProfile,
        game: _game,
        choices: _choices,
      );
      final ranking = history.rankAnimals(
        _reportProfile,
        game: _game,
        choices: _choices,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.reportTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(context.l10n.reportDescription),
          const SizedBox(height: 16),
          if (settings.storageFailed) ...[
            SoftCard(
              color: AppColors.peach,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.reportStorageFailure),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => unawaited(settings.retrySave()),
                    child: Text(context.l10n.retrySave),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(context.l10n.reportLocalNotice),
          const SizedBox(height: 16),
          SoftCard(
            color: AppColors.sage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.reportProfileTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const ValueKey('report_profile_selector'),
                  onPressed: _chooseProfile,
                  icon: AnimalPicture(
                    path: settings.profile(_reportProfile).avatar.image,
                    label: '',
                    size: 32,
                    decorative: true,
                  ),
                  label: Text(
                    context.l10n.profileIdentity(
                      settings
                          .profile(_reportProfile)
                          .displayName(context.l10n),
                      settings
                          .profile(_reportProfile)
                          .displayCardNumber(context.l10n),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.reportActiveProfile(
                    settings
                        .profile(settings.activeProfile)
                        .displayName(context.l10n),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _filter(
            label: context.l10n.reportActivityFilter,
            value: _game?.name ?? 'all',
            items: {
              'all': context.l10n.allActivities,
              for (final game in games) game.kind.name: game.title,
            },
            onChanged: (value) => setState(
              () =>
                  _game = value == 'all' ? null : GameKind.values.byName(value),
            ),
          ),
          const SizedBox(height: 12),
          _filter(
            label: context.l10n.reportChoicesFilter,
            value: _choices?.toString() ?? 'all',
            items: {
              'all': context.l10n.allConfigurations,
              '2': context.l10n.twoAlternatives,
              '3': context.l10n.threeAlternatives,
              '0': context.l10n.drawingWithoutChoices,
            },
            onChanged: (value) =>
                setState(() => _choices = int.tryParse(value)),
          ),
          const SizedBox(height: 16),
          if (total.started == 0)
            SoftCard(child: Text(context.l10n.reportEmpty))
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth >= 500 &&
                        MediaQuery.textScalerOf(context).scale(16) <= 24
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 12) / columns;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final metric in [
                      (context.l10n.reportErrors, '${total.errors}'),
                      (
                        context.l10n.reportRoundsWithErrors,
                        context.l10n.reportAnsweredWithErrors(
                          total.roundsWithErrors,
                          total.answered,
                        ),
                      ),
                      (context.l10n.reportFirstTry, '${total.firstTry}'),
                      (context.l10n.reportHints, '${total.hints}'),
                      (context.l10n.reportResolved, '${total.correct}'),
                      (context.l10n.reportSkipped, '${total.skipped}'),
                    ])
                      SizedBox(
                        width: width,
                        child: SoftCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                metric.$2,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(metric.$1),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.reportOpenedRounds(total.started, total.answered),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.reportAnimalRanking,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.reportRankingDescription),
            const SizedBox(height: 12),
            if (ranking.isEmpty)
              SoftCard(child: Text(context.l10n.reportNoErrors)),
            for (final entry in ranking) ...[
              SoftCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimalPicture(
                      path: entry.animal.image,
                      label: '',
                      size: 56,
                      decorative: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.animal.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.reportAnimalErrorRate(
                              entry.stats.roundsWithErrors,
                              entry.stats.answered,
                              (entry.stats.errorRate * 100).round(),
                            ),
                          ),
                          Text(
                            context.l10n.reportAnimalErrorsAndHints(
                              entry.stats.errors,
                              entry.stats.hints,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            Text(
              context.l10n.reportByActivity,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final game in games.where(
              (g) => _game == null || g.kind == _game,
            ))
              _ActivitySummary(
                game: game,
                stats: history.summarize(
                  _reportProfile,
                  game: game.kind,
                  choices: _choices,
                ),
              ),
          ],
          const SizedBox(height: 16),
          Text(context.l10n.reportInterpretation),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _clearProfile(context),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(
                context.l10n.clearProfileHistory(
                  settings.profile(_reportProfile).displayName(context.l10n),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _filter({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        items: [
          for (final entry in items.entries)
            DropdownMenuItem(
              value: entry.key,
              child: Text(
                entry.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    ),
  );

  Future<void> _clearProfile(BuildContext context) async {
    final profile = _reportProfile;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(
          context.l10n.clearProfileHistoryTitle(
            widget.settings.profile(profile).displayName(context.l10n),
          ),
        ),
        content: Text(context.l10n.clearProfileHistoryDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.clearHistory),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted && _reportProfile == profile) {
      await widget.settings.clearProfileHistory(profile: profile);
    }
  }
}

class _ActivitySummary extends StatelessWidget {
  const _ActivitySummary({required this.game, required this.stats});
  final GameDefinition game;
  final LearningStats stats;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(game.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            stats.started == 0
                ? context.l10n.reportNoActivityRecords
                : context.l10n.reportActivitySummary(
                    stats.errors,
                    stats.roundsWithErrors,
                    stats.answered,
                    stats.firstTry,
                  ),
          ),
        ],
      ),
    ),
  );
}
