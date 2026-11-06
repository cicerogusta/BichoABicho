import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../l10n/localization.dart';
import '../../../animals/domain/animal_catalog.dart';

class WelcomeBanner extends StatelessWidget {
  const WelcomeBanner({super.key, required this.onAnimals});
  final VoidCallback onAnimals;
  @override
  Widget build(BuildContext context) => SoftCard(
    color: AppColors.sage,
    padding: EdgeInsets.zero,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 650;
        if (!wide) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.homeWelcome,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.homePlayPrompt,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(context.l10n.oneDiscoveryAtATime),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Image.asset(
                    'assets/welcome.png',
                    height: 150,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ],
            ),
          );
        }
        final copy = Padding(
          padding: EdgeInsets.all(wide ? 36 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  context.l10n.homeIntroLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                context.l10n.homeIntroTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.homeIntroDescription,
                style: const TextStyle(color: AppColors.muted, height: 1.6),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAnimals,
                icon: const Icon(Icons.pets_rounded, size: 20),
                label: Text(context.l10n.meetAnimals),
              ),
            ],
          ),
        );
        final art = Image.asset(
          'assets/welcome.png',
          fit: BoxFit.cover,
          height: wide ? 340 : 210,
          width: double.infinity,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => SizedBox(
            height: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final a in animals.take(3))
                  Flexible(
                    child: AnimalPicture(
                      path: a.image,
                      label: a.name,
                      size: 110,
                      decorative: true,
                    ),
                  ),
              ],
            ),
          ),
        );
        return wide
            ? Row(
                children: [
                  Expanded(flex: 6, child: copy),
                  Expanded(flex: 5, child: art),
                ],
              )
            : Column(children: [copy, art]);
      },
    ),
  );
}
