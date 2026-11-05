import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../domain/memory_board.dart';
import 'game_view_model.dart';
import 'memory_controller.dart';
import 'widgets/animal_celebration.dart';

class MemoryRoundView extends StatelessWidget {
  const MemoryRoundView({
    super.key,
    required this.model,
    required this.onAdvance,
  });

  final GameViewModel model;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final controller = model.memory;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final board = controller.board;
        final complete = controller.phase == MemoryPhase.complete;
        final preview = controller.phase == MemoryPhase.preview;
        final message = switch (controller.phase) {
          MemoryPhase.preview => 'Observe os bichinhos. Pode olhar sem pressa!',
          MemoryPhase.hiding => 'Vamos esconder os bichinhos…',
          MemoryPhase.gathering ||
          MemoryPhase.shuffling => 'Embaralhando as cartas…',
          MemoryPhase.comparing => 'São diferentes. Vamos tentar outro par?',
          MemoryPhase.complete => 'Você encontrou todos os pares!',
          MemoryPhase.playing =>
            'Vire duas cartas e encontre os bichinhos iguais.',
        };
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Descoberta ${model.index + 1} de ${model.session.rounds.length}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: board.pairsFound / (board.cards.length ~/ 2),
              minHeight: 8,
              semanticsLabel: 'Pares encontrados',
              backgroundColor: AppColors.sage,
            ),
            const SizedBox(height: 24),
            Text(
              'Encontre os pares de bichinhos iguais.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, semanticsLabel: message),
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                '${board.pairsFound} de ${board.cards.length ~/ 2} pares • ${controller.attempts} tentativas',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final columns = constraints.maxWidth < 460 ? 2 : 3;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                final height = math.min(width * 1.05, 174.0);
                final rows = (board.cards.length / columns).ceil();
                final boardHeight = rows * height + (rows - 1) * gap;
                final gathered = controller.phase == MemoryPhase.gathering;
                return SizedBox(
                  height: boardHeight,
                  child: Stack(
                    children: [
                      for (var i = 0; i < board.cards.length; i++)
                        AnimatedPositioned(
                          key: ValueKey(board.cards[i].id),
                          duration: reduced
                              ? Duration.zero
                              : MemoryController.shuffleDuration,
                          curve: Curves.easeInOutCubic,
                          left: gathered
                              ? (constraints.maxWidth - width) / 2
                              : (i % columns) * (width + gap),
                          top: gathered
                              ? (boardHeight - height) / 2
                              : (i ~/ columns) * (height + gap),
                          width: width,
                          height: height,
                          child: _MemoryTile(
                            card: board.cards[i],
                            position: i + 1,
                            visible: controller.visible(board.cards[i].id),
                            matched: board.isMatched(board.cards[i].id),
                            enabled:
                                controller.canSelect &&
                                !board.isRevealed(board.cards[i].id),
                            reduced: reduced,
                            onTap: () => controller.select(board.cards[i].id),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            if (preview)
              FilledButton.icon(
                onPressed: controller.start,
                icon: const Icon(Icons.shuffle_rounded),
                label: const Text('Esconder e embaralhar'),
              ),
            if (complete) ...[
              SoftCard(
                color: AppColors.sage,
                child: Column(
                  children: [
                    AnimalCelebration(animal: model.round.animal),
                    const SizedBox(height: 12),
                    Text(
                      'Você encontrou todos os pares!',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAdvance,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  model.index == model.session.rounds.length - 1
                      ? 'Concluir brincadeira'
                      : 'Próxima descoberta',
                ),
              ),
            ] else
              TextButton(
                onPressed: onAdvance,
                child: const Text('Pular por enquanto'),
              ),
            if (model.mediaMessage != null)
              Text(model.mediaMessage!, textAlign: TextAlign.center),
          ],
        );
      },
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({
    required this.card,
    required this.position,
    required this.visible,
    required this.matched,
    required this.enabled,
    required this.reduced,
    required this.onTap,
  });

  final MemoryCard card;
  final int position;
  final bool visible, matched, enabled, reduced;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: enabled,
    label: visible
        ? 'Carta $position: ${card.animal.name}${matched ? ', par encontrado' : ''}'
        : 'Carta $position, escondida',
    onTap: enabled ? onTap : null,
    excludeSemantics: true,
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: visible ? 0 : math.pi),
      duration: reduced ? Duration.zero : MemoryController.flipDuration,
      curve: Curves.easeInOutCubic,
      builder: (context, angle, _) {
        final front = angle < math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(front ? angle : angle - math.pi),
          child: Material(
            color: front
                ? (matched ? AppColors.sage : Colors.white)
                : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: matched ? AppColors.primary : AppColors.border,
                width: matched ? 3 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Center(
                child: front
                    ? LayoutBuilder(
                        builder: (context, constraints) => Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimalPicture(
                              path: card.animal.image,
                              label: '',
                              size: math.min(
                                constraints.maxHeight - 20,
                                constraints.maxWidth - 20,
                              ),
                              decorative: true,
                            ),
                            if (matched)
                              const Positioned(
                                right: 8,
                                top: 8,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      )
                    : const Icon(
                        Icons.pets_rounded,
                        size: 44,
                        color: AppColors.sage,
                      ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
