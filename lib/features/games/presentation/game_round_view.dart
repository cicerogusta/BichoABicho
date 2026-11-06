import 'dart:async';

import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../settings/presentation/app_settings.dart';
import '../domain/game_definition.dart';
import '../domain/game_session.dart';
import 'game_media_message_text.dart';
import 'game_view_model.dart';
import 'widgets/animal_celebration.dart';
import 'widgets/story_prompt.dart';

class GameRoundView extends StatelessWidget {
  const GameRoundView({
    super.key,
    required this.model,
    required this.game,
    required this.settings,
    required this.onAdvance,
  });
  final GameViewModel model;
  final GameDefinition game;
  final AppSettings settings;
  final VoidCallback onAdvance;
  @override
  Widget build(BuildContext context) {
    final round = model.round;
    final correct = model.feedback == RoundFeedback.correct;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.explore_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.roundProgress(
                  model.index + 1,
                  model.session.rounds.length,
                ),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value:
                (model.index + (correct ? 1 : 0)) / model.session.rounds.length,
            minHeight: 8,
            semanticsLabel: context.l10n.gameProgress,
            backgroundColor: AppColors.sage,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          game.instruction,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        SoftCard(
          color: AppColors.sage,
          child: Column(
            children: [
              if (correct)
                AnimalCelebration(
                  key: ValueKey(model.index),
                  animal: round.animal,
                )
              else if (game.kind == GameKind.counting)
                _CountingGroup(model: model)
              else if (game.kind == GameKind.stories)
                StoryPrompt(story: round.story!)
              else if (game.kind == GameKind.clues)
                Column(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.clueHeading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      round.animal.clue,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                )
              else
                AnimalPicture(
                  path: round.animal.image,
                  label: round.animal.name,
                  size: 172,
                ),
              if (correct && round.story != null) ...[
                const SizedBox(height: 16),
                StoryPrompt(story: round.story!),
              ],
              if (game.kind == GameKind.letters) ...[
                const SizedBox(height: 12),
                Text(
                  correct
                      ? round.animal.name.toUpperCase()
                      : '_${round.animal.name.substring(1).toUpperCase()}',
                  semanticsLabel: correct
                      ? round.animal.name
                      : context.l10n.nameWithoutInitial(
                          round.animal.name.substring(1),
                        ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: AppColors.ink,
                  ),
                ),
              ],
              if (game.kind != GameKind.clues &&
                  game.kind != GameKind.stories) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: model.mediaBusy || model.listening
                      ? null
                      : () => unawaited(model.playSound(settings.soundEnabled)),
                  icon: const Icon(Icons.volume_up_outlined),
                  label: Text(context.l10n.hearAnimal),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (game.kind == GameKind.speaking) ...[
          FilledButton.icon(
            onPressed: correct
                ? null
                : model.listening
                ? () => unawaited(model.stopListening())
                : () => unawaited(model.listen()),
            icon: Icon(
              model.listening ? Icons.stop_rounded : Icons.mic_none_rounded,
            ),
            label: Text(
              model.listening
                  ? context.l10n.stopListening
                  : context.l10n.requestSpeech,
            ),
          ),
          const SizedBox(height: 12),
          Text(context.l10n.chooseImage, textAlign: TextAlign.center),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final minimumWidth =
                150 * MediaQuery.textScalerOf(context).scale(18) / 18;
            final columns = (constraints.maxWidth / minimumWidth).floor().clamp(
              1,
              round.choices.length,
            );
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final choice in round.choices)
                  SizedBox(
                    width: width,
                    child: _ChoiceTile(
                      choice: choice,
                      correct: correct && choice.value == round.answer,
                      tried: model.attempted.contains(choice.value),
                      disabled: correct,
                      onTap: () => model.answer(choice.value),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        Semantics(
          liveRegion: true,
          child: Column(
            children: [
              if (model.mediaMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    model.mediaMessage!.resolve(context),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (correct)
                SoftCard(
                  color: AppColors.sage,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.discoveryCorrect,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        round.story?.answerSentence ??
                            (game.kind == GameKind.counting
                                ? context.l10n.countingCorrect(round.quantity)
                                : context.l10n.animalCorrect(
                                    round.animal.name.toLowerCase(),
                                  )),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (model.feedback == RoundFeedback.retry)
                Text(context.l10n.retryChoice, textAlign: TextAlign.center),
              if (model.hintVisible && !correct)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    switch (game.kind) {
                      GameKind.letters => context.l10n.letterHint(
                        round.animal.name,
                        round.animal.initial,
                      ),
                      GameKind.counting => context.l10n.countingHint(
                        List.generate(round.quantity, (i) => i + 1).join(', '),
                      ),
                      GameKind.stories => round.story!.answerSentence,
                      GameKind.clues => context.l10n.clueHint(
                        round.animal.name.toLowerCase(),
                      ),
                      _ => context.l10n.matchingHint(
                        round.animal.name.toLowerCase(),
                        round.animal.clue,
                      ),
                    },
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (correct)
          FilledButton.icon(
            onPressed: onAdvance,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              model.index == model.session.rounds.length - 1
                  ? context.l10n.finishGame
                  : context.l10n.nextRound,
            ),
          )
        else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: model.showHint,
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: Text(context.l10n.requestHint),
              ),
              TextButton(
                onPressed: onAdvance,
                child: Text(context.l10n.skipRound),
              ),
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _CountingGroup extends StatelessWidget {
  const _CountingGroup({required this.model});
  final GameViewModel model;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var i = 0; i < model.round.quantity; i++)
            Semantics(
              button: true,
              label: model.countedAnimals.contains(i)
                  ? context.l10n.animalAlreadyCounted(
                      model.round.animal.name,
                      i + 1,
                    )
                  : context.l10n.animalTapToCount(
                      model.round.animal.name,
                      i + 1,
                    ),
              excludeSemantics: true,
              onTap: () => model.countAnimal(i),
              child: SoftCard(
                padding: const EdgeInsets.all(8),
                onTap: () => model.countAnimal(i),
                child: Stack(
                  children: [
                    AnimalPicture(
                      path: model.round.animal.image,
                      label: '',
                      size: 86,
                      decorative: true,
                    ),
                    if (model.countedAnimals.contains(i))
                      const Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Semantics(
        liveRegion: true,
        child: Text(
          model.countedAnimals.isEmpty
              ? context.l10n.countingInstruction
              : context.l10n.countingProgress(model.countedAnimals.length),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.choice,
    required this.correct,
    required this.tried,
    required this.disabled,
    required this.onTap,
  });
  final GameChoice choice;
  final bool correct;
  final bool tried;
  final bool disabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: !disabled,
    onTap: disabled ? null : onTap,
    label: correct
        ? context.l10n.choiceCorrectLabel(choice.label)
        : tried
        ? context.l10n.choiceRetryLabel(choice.label)
        : choice.label,
    excludeSemantics: true,
    child: SoftCard(
      color: correct ? AppColors.sage : Colors.white,
      onTap: disabled ? null : onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (choice.animal != null)
            AnimalPicture(
              path: choice.animal!.image,
              label: choice.label,
              size: 96,
              decorative: true,
            ),
          Text(
            choice.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: choice.animal == null ? 34 : 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          if (correct)
            const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          else if (tried)
            const Icon(Icons.refresh_rounded, color: AppColors.muted),
        ],
      ),
    ),
  );
}
