import 'dart:async';

import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/game_definition.dart';
import 'drawing_round_view.dart';
import 'game_round_view.dart';
import 'game_view_model.dart';
import 'memory_round_view.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.game,
    required this.settings,
    required this.viewModel,
  });
  final GameDefinition game;
  final AppSettings settings;
  final GameViewModel viewModel;
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  late final GameViewModel _model;
  bool _completionRecorded = false;
  @override
  void initState() {
    super.initState();
    _model = widget.viewModel;
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
                ? context.l10n.disableSound
                : context.l10n.enableSound,
            onPressed: () => unawaited(_toggleSound()),
            icon: Icon(
              widget.settings.soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),
          if (!_model.finished)
            IconButton(
              tooltip: context.l10n.pauseGame,
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
                  : widget.game.kind == GameKind.memory
                  ? MemoryRoundView(
                      model: _model,
                      onAdvance: () => unawaited(_advance()),
                    )
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
          context.l10n.pauseTitle,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(context.l10n.pauseDescription, textAlign: TextAlign.center),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: _model.resume,
          child: Text(context.l10n.resumeGame),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.backToHome),
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
          context.l10n.gameFinishedTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(context.l10n.gameFinishedDescription, textAlign: TextAlign.center),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.chooseAnotherGame),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
