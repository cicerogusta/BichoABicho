import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/animal_audio.dart';
import '../../../core/services/animal_speech.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/game_definition.dart';
import '../domain/game_session.dart';
import 'game_view_model.dart';
import 'game_round_view.dart';
import 'drawing_round_view.dart';
import '../../../core/analytics/usage_analytics.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.game,
    required this.settings,
    this.viewModel,
    this.analytics = const NoopUsageAnalytics(),
  });
  final GameDefinition game;
  final AppSettings settings;
  final GameViewModel? viewModel;
  final UsageAnalytics analytics;
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  late final GameViewModel _model;
  bool _completionRecorded = false;
  @override
  void initState() {
    super.initState();
    _model =
        widget.viewModel ??
        GameViewModel(
          session: GameSession(
            kind: widget.game.kind,
            choiceCount: widget.settings.choiceCount,
            rounds: widget.settings.rounds,
          ),
          audio: AssetAnimalAudio(),
          speech: DeviceAnimalSpeech(),
          soundEnabled: () => widget.settings.soundEnabled,
          analytics: widget.analytics,
          onObservation: widget.settings.recorderForActiveProfile(),
        );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_model.pause(fromBackground: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.dispose();
    super.dispose();
  }

  Future<void> _advance() async {
    await _model.next();
    if (_model.finished && !_completionRecorded) {
      _completionRecorded = true;
      await widget.settings.recordCompletion(widget.game.kind.name);
    }
  }

  Future<void> _toggleSound() async {
    await _model.stopMedia();
    await widget.settings.update(sound: !widget.settings.soundEnabled);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([_model, widget.settings]),
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(widget.game.title),
        actions: [
          IconButton(
            tooltip: widget.settings.soundEnabled
                ? 'Desligar sons'
                : 'Ativar sons',
            onPressed: () => unawaited(_toggleSound()),
            icon: Icon(
              widget.settings.soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),
          if (!_model.finished)
            IconButton(
              tooltip: 'Fazer uma pausa',
              icon: const Icon(Icons.pause_circle_outline_rounded),
              onPressed: () => unawaited(_model.pause()),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: _model.finished
                  ? _finished(context)
                  : _model.paused
                  ? _pause(context)
                  : widget.game.kind == GameKind.drawing
                  ? DrawingRoundView(
                      model: _model,
                      onAdvance: () => unawaited(_advance()),
                    )
                  : GameRoundView(
                      model: _model,
                      game: widget.game,
                      settings: widget.settings,
                      onAdvance: () => unawaited(_advance()),
                    ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _pause(BuildContext context) => SoftCard(
    color: AppColors.sage,
    child: Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.spa_outlined, size: 64, color: AppColors.primary),
        const SizedBox(height: 20),
        Text(
          'Vamos fazer uma pausa.',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'A brincadeira espera por você.\nVolte quando quiser.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: _model.resume,
          child: const Text('Continuar brincando'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Voltar ao início'),
        ),
      ],
    ),
  );

  Widget _finished(BuildContext context) => SoftCard(
    color: AppColors.sage,
    child: Column(
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.auto_awesome_outlined,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Que bom descobrir com você!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Nossa brincadeira chegou ao fim.\nVocê pode descansar ou explorar de novo.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Escolher outra brincadeira'),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
