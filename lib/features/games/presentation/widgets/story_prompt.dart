import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/animal_story.dart';

class StoryPrompt extends StatelessWidget {
  const StoryPrompt({super.key, required this.story});
  final AnimalStory story;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('Faz de conta • leia junto', textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(
        story.title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
          final columns = constraints.maxWidth >= 270 * scale ? 2 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < story.scenes.length; i++)
                SizedBox(
                  width: width,
                  child: _SceneCard(scene: story.scenes[i], index: i),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 20),
      Text(
        story.question,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      const Text(
        'Pode olhar a história de novo quando quiser.',
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({required this.scene, required this.index});
  final StoryScene scene;
  final int index;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cena ${index + 1}. ${scene.sentence}',
    excludeSemantics: true,
    child: SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'Cena ${index + 1}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: AnimalPicture(
                  path: scene.animal.image,
                  label: '',
                  size: 72,
                  decorative: true,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                switch (scene.action) {
                  StoryAction.ball => Icons.sports_baseball_outlined,
                  StoryAction.book => Icons.menu_book_rounded,
                  StoryAction.blocks => Icons.view_in_ar_rounded,
                  StoryAction.water => Icons.water_drop_outlined,
                  StoryAction.drawing => Icons.draw_outlined,
                  StoryAction.resting => Icons.chair_outlined,
                },
                color: AppColors.primary,
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(scene.sentence, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
