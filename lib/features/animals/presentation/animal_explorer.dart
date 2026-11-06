import 'dart:async';

import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';
import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/analytics/usage_analytics.dart';
import '../../../core/services/animal_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../settings/presentation/app_settings.dart';
import 'animal_explorer_view_model.dart';

class AnimalExplorer extends StatefulWidget {
  const AnimalExplorer({
    super.key,
    required this.settings,
    this.analytics = const NoopUsageAnalytics(),
    required this.createAudio,
  });
  final AppSettings settings;
  final UsageAnalytics analytics;
  final AnimalAudio Function() createAudio;
  @override
  State<AnimalExplorer> createState() => _AnimalExplorerState();
}

class _AnimalExplorerState extends State<AnimalExplorer>
    with WidgetsBindingObserver {
  static const _cardColors = [
    AppColors.peach,
    AppColors.lavender,
    AppColors.yellow,
    AppColors.blue,
  ];
  late final AnimalExplorerViewModel _model;
  @override
  void initState() {
    super.initState();
    _model = AnimalExplorerViewModel(
      widget.createAudio(),
      soundEnabled: () => widget.settings.soundEnabled,
      analytics: widget.analytics,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(AnimalExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.settings.soundEnabled) unawaited(_model.stop());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_model.stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _model,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                context.l10n.explorerTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(context.l10n.explorerDescription),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 650 ? 2 : 1;
                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (var i = 0; i < animals.length; i++)
                        SizedBox(
                          width:
                              (constraints.maxWidth - (columns - 1) * 20) /
                              columns,
                          child: SoftCard(
                            color: _cardColors[i % _cardColors.length],
                            child: Column(
                              children: [
                                AnimalPicture(
                                  path: animals[i].image,
                                  label: animals[i].name,
                                  size: 148,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  animals[i].name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  animals[i].clue,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: _model.busy
                                      ? null
                                      : () =>
                                            unawaited(_model.play(animals[i])),
                                  icon: const Icon(Icons.volume_up_outlined),
                                  label: Text(context.l10n.hearAnimal),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (_model.message != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(switch (_model.message!) {
                      ExplorerMessage.soundDisabled =>
                        context.l10n.explorerEnableSound,
                      ExplorerMessage.soundUnavailable =>
                        context.l10n.explorerAudioUnavailable,
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
