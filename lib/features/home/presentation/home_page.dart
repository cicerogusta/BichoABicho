import 'dart:async';

import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';
import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/analytics/analytics_controller.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../../core/services/animal_audio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../animals/presentation/animal_explorer.dart';
import '../../games/domain/game_definition.dart';
import '../../games/presentation/game_catalog.dart';
import '../../games/presentation/game_page.dart';
import '../../games/presentation/game_view_model.dart';
import '../../progress/presentation/profile_labels.dart';
import '../../progress/presentation/profile_selection_page.dart';
import '../../settings/presentation/app_settings.dart';
import '../../settings/presentation/parent_page.dart';
import 'widgets/game_catalog_card.dart';
import 'widgets/welcome_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.settings,
    required this.accountBuilder,
    required this.createGame,
    required this.createAudio,
    this.analytics,
  });
  final AppSettings settings;
  final WidgetBuilder accountBuilder;
  final GameViewModel Function(GameDefinition) createGame;
  final AnimalAudio Function() createAudio;
  final AnalyticsController? analytics;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _section = 0;
  UsageAnalytics get _analytics =>
      widget.analytics ?? const NoopUsageAnalytics();
  @override
  void initState() {
    super.initState();
    _analytics.rootScreen(UsageScreen.playHome);
  }

  void _selectSection(int index) {
    if (_section == index) return;
    final screen = [
      UsageScreen.playHome,
      UsageScreen.animals,
      UsageScreen.parents,
    ][index];
    _analytics.rootScreen(screen);
    _analytics.event(
      UsageEvent.navigationSelected,
      parameters: {UsageParameter.destination: screen.name},
    );
    setState(() => _section = index);
  }

  Future<void> _changeProfile() async {
    final profile = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        settings: RouteSettings(name: UsageScreen.profileSelection.name),
        builder: (context) => ProfileSelectionPage(
          settings: widget.settings,
          allowBack: true,
          onSelected: (profile) => Navigator.of(context).pop(profile),
        ),
      ),
    );
    if (profile != null && mounted) {
      await widget.settings.selectProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 40 : 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.appWordmark,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (wide)
                          Text(
                            context.l10n.appTagline,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (wide) ...[
                    _NavButton(
                      label: context.l10n.playTab,
                      icon: Icons.grid_view_rounded,
                      selected: _section == 0,
                      onTap: () => _selectSection(0),
                    ),
                    _NavButton(
                      label: context.l10n.animalsTab,
                      icon: Icons.pets_outlined,
                      selected: _section == 1,
                      onTap: () => _selectSection(1),
                    ),
                    _NavButton(
                      label: context.l10n.parentsNavigation,
                      icon: Icons.tune_rounded,
                      selected: _section == 2,
                      onTap: () => _selectSection(2),
                    ),
                    const SizedBox(width: 24),
                  ],
                  IconButton.filledTonal(
                    tooltip: widget.settings.soundEnabled
                        ? context.l10n.disableSound
                        : context.l10n.enableSound,
                    onPressed: () => unawaited(
                      widget.settings.update(
                        sound: !widget.settings.soundEnabled,
                      ),
                    ),
                    icon: Icon(
                      widget.settings.soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: switch (_section) {
                1 => AnimalExplorer(
                  createAudio: widget.createAudio,
                  settings: widget.settings,
                  analytics: _analytics,
                ),
                2 => ParentPage(
                  settings: widget.settings,
                  accountBuilder: widget.accountBuilder,
                  analytics: widget.analytics,
                ),
                _ => _PlayHome(
                  createGame: widget.createGame,
                  games: gameCatalog(context.l10n),
                  onChangeProfile: _changeProfile,
                  settings: widget.settings,
                  onAnimals: () => _selectSection(1),
                ),
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _section,
              onDestinationSelected: _selectSection,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.grid_view_rounded),
                  label: context.l10n.playTab,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.pets_outlined),
                  label: context.l10n.animalsTab,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.tune_rounded),
                  label: context.l10n.parentsTab,
                ),
              ],
            ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: selected ? AppColors.sage : null,
        minimumSize: const Size(56, 52),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
    ),
  );
}

class _PlayHome extends StatelessWidget {
  const _PlayHome({
    required this.createGame,
    required this.games,
    required this.settings,
    required this.onChangeProfile,
    required this.onAnimals,
  });
  final List<GameDefinition> games;
  final GameViewModel Function(GameDefinition) createGame;
  final AppSettings settings;
  final VoidCallback onChangeProfile;
  final VoidCallback onAnimals;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            WelcomeBanner(onAnimals: onAnimals),
            const SizedBox(height: 32),
            Text(
              context.l10n.homeTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.homeInstruction),
            const SizedBox(height: 8),
            SoftCard(
              color: AppColors.sage,
              child: Column(
                children: [
                  Row(
                    children: [
                      AnimalPicture(
                        path: settings
                            .profile(settings.activeProfile)
                            .avatar
                            .image,
                        label: '',
                        size: 48,
                        decorative: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          settings
                              .profile(settings.activeProfile)
                              .displayName(context.l10n),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onChangeProfile,
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: Text(context.l10n.switchProfile),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 980
                    ? 4
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 16) / columns;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (var i = 0; i < games.length; i++)
                      SizedBox(
                        width: width,
                        child: GameCatalogCard(
                          game: games[i],
                          onTap: () {
                            final viewModel = createGame(games[i]);
                            unawaited(
                              Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  settings: RouteSettings(
                                    name: gameScreenFor(
                                      games[i].kind.name,
                                    ).name,
                                  ),
                                  builder: (_) => GamePage(
                                    viewModel: viewModel,
                                    game: games[i],
                                    settings: settings,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            SoftCard(
              color: AppColors.sage,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_outline_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      context.l10n.homeReassurance,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.homeAnimalsTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: onAnimals,
                  child: Text(context.l10n.seeAnimals),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final animal in animals)
                  SizedBox(
                    width: 120,
                    child: SoftCard(
                      padding: const EdgeInsets.all(12),
                      onTap: onAnimals,
                      child: Column(
                        children: [
                          AnimalPicture(
                            path: animal.image,
                            label: animal.name,
                            size: 64,
                            decorative: true,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            animal.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                context.l10n.homeFooter,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}
