import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../l10n/localization.dart';
import '../../../animals/domain/animal_catalog.dart';
import '../../../games/domain/game_definition.dart';

class GameCatalogCard extends StatelessWidget {
  const GameCatalogCard({super.key, required this.game, required this.onTap});
  final GameDefinition game;
  final VoidCallback onTap;
  Color get _color => switch (game.kind) {
    GameKind.memory => AppColors.blue,
    GameKind.matching => AppColors.peach,
    GameKind.letters => AppColors.lavender,
    GameKind.counting => AppColors.blue,
    GameKind.speaking => AppColors.yellow,
    GameKind.clues => AppColors.sage,
    GameKind.stories => AppColors.peach,
    GameKind.drawing => AppColors.lavender,
  };
  IconData get _icon => switch (game.kind) {
    GameKind.memory => Icons.style_rounded,
    GameKind.matching => Icons.extension_rounded,
    GameKind.letters => Icons.abc_rounded,
    GameKind.counting => Icons.looks_3_outlined,
    GameKind.speaking => Icons.record_voice_over_rounded,
    GameKind.clues => Icons.search_rounded,
    GameKind.stories => Icons.menu_book_rounded,
    GameKind.drawing => Icons.draw_outlined,
  };
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.playGameLabel(game.title),
    onTap: onTap,
    excludeSemantics: true,
    child: SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 132,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child:
                  game.kind == GameKind.memory ||
                      game.kind == GameKind.clues ||
                      game.kind == GameKind.stories ||
                      game.kind == GameKind.drawing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimalPicture(
                          path: animals[1].image,
                          label: '',
                          size: 76,
                          decorative: true,
                        ),
                        Icon(_icon, size: 42, color: AppColors.primary),
                      ],
                    )
                  : game.kind == GameKind.letters
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimalPicture(
                          path: animals[1].image,
                          label: animals[1].name,
                          size: 80,
                          decorative: true,
                        ),
                        Text(
                          animals[1].initial,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    )
                  : game.kind == GameKind.counting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var n = 0; n < 3; n++)
                          AnimalPicture(
                            path: animals[0].image,
                            label: animals[0].name,
                            size: 52,
                            decorative: true,
                          ),
                      ],
                    )
                  : AnimalPicture(
                      path:
                          animals[game.kind == GameKind.matching ? 2 : 3].image,
                      label: '',
                      size: 112,
                      decorative: true,
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(_icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  game.skill,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(game.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(game.subtitle),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                context.l10n.playTogether,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
