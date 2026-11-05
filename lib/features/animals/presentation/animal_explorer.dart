import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/animal_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/animal.dart';
import '../../../core/analytics/usage_analytics.dart';

class AnimalExplorer extends StatefulWidget {
  const AnimalExplorer({
    super.key,
    required this.settings,
    this.analytics = const NoopUsageAnalytics(),
    this.audio,
  });
  final AppSettings settings;
  final UsageAnalytics analytics;
  final AnimalAudio? audio;
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
  late final AnimalAudio _audio;
  String? _message;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _audio = widget.audio ?? AssetAnimalAudio();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(AnimalExplorer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.settings.soundEnabled) unawaited(_stop());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_stop());
  }

  Future<void> _stop() async {
    try {
      await _audio.stop();
    } on Exception {
      /* No audio is needed to explore images. */
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_audio.dispose());
    super.dispose();
  }

  Future<void> _play(Animal animal) async {
    if (_busy) return;
    widget.analytics.event(
      UsageEvent.animalSoundRequested,
      parameters: {UsageParameter.animalId: animal.id},
    );
    if (!widget.settings.soundEnabled) {
      setState(
        () => _message = 'Ative o som no botão do alto da tela para ouvir.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _audio.play(animal.sound);
    } on Exception {
      widget.analytics.event(
        UsageEvent.mediaUnavailable,
        parameters: {UsageParameter.feature: 'animal_audio'},
      );
      if (mounted) {
        setState(
          () => _message =
              'Não foi possível tocar o som. Continue explorando as imagens.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Conheça a nossa turma',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Observe os bichinhos. Se quiser, toque para ouvir o som de cada um.',
            ),
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
                                onPressed: _busy
                                    ? null
                                    : () => unawaited(_play(animals[i])),
                                icon: const Icon(Icons.volume_up_outlined),
                                label: const Text('Ouvir o bichinho'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(liveRegion: true, child: Text(_message!)),
              ),
          ],
        ),
      ),
    ),
  );
}
