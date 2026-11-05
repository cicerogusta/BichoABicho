import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../animals/domain/animal.dart';
import '../../animals/presentation/animal_explorer.dart';
import '../../games/domain/game_definition.dart';
import '../../games/presentation/game_page.dart';
import '../../settings/presentation/app_settings.dart';
import '../../settings/presentation/parent_page.dart';
import '../../../core/analytics/analytics_controller.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../progress/presentation/profile_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.settings,
    required this.accountBuilder,
    this.analytics,
  });
  final AppSettings settings;
  final WidgetBuilder accountBuilder;
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
                          'bicho a bicho',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (wide)
                          const Text(
                            'Cada descoberta, no seu tempo.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (wide) ...[
                    _NavButton(
                      label: 'Brincar',
                      icon: Icons.grid_view_rounded,
                      selected: _section == 0,
                      onTap: () => _selectSection(0),
                    ),
                    _NavButton(
                      label: 'Bichinhos',
                      icon: Icons.pets_outlined,
                      selected: _section == 1,
                      onTap: () => _selectSection(1),
                    ),
                    _NavButton(
                      label: 'Para responsáveis',
                      icon: Icons.tune_rounded,
                      selected: _section == 2,
                      onTap: () => _selectSection(2),
                    ),
                    const SizedBox(width: 24),
                  ],
                  IconButton.filledTonal(
                    tooltip: widget.settings.soundEnabled
                        ? 'Desligar sons'
                        : 'Ativar sons',
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
                  settings: widget.settings,
                  analytics: _analytics,
                ),
                2 => ParentPage(
                  settings: widget.settings,
                  accountBuilder: widget.accountBuilder,
                  analytics: widget.analytics,
                ),
                _ => _PlayHome(
                  onChangeProfile: _changeProfile,
                  settings: widget.settings,
                  analytics: _analytics,
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
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Brincar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pets_outlined),
                  label: 'Bichinhos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_rounded),
                  label: 'Responsáveis',
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
    required this.settings,
    required this.onChangeProfile,
    required this.onAnimals,
    required this.analytics,
  });
  final AppSettings settings;
  final VoidCallback onChangeProfile;
  final VoidCallback onAnimals;
  final UsageAnalytics analytics;
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
            _Welcome(onAnimals: onAnimals),
            const SizedBox(height: 32),
            Text(
              'O que vamos descobrir hoje?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Escolha uma brincadeira. Vamos juntos, sem pressa.'),
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
                          settings.profileLabel(settings.activeProfile),
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
                      label: const Text('Trocar'),
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
                        child: _GameCard(
                          game: games[i],
                          onTap: () => Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              settings: RouteSettings(
                                name: gameScreenFor(games[i].kind.name).name,
                              ),
                              builder: (_) => GamePage(
                                game: games[i],
                                settings: settings,
                                analytics: analytics,
                              ),
                            ),
                          ),
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
                      'Aqui, cada tentativa é uma descoberta. Você pode repetir, pedir uma dica ou fazer uma pausa.',
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
                    'Uma turma para conhecer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: onAnimals,
                  child: const Text('Ver bichinhos →'),
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
            const Center(
              child: Text(
                'Feito para explorar. Com espaço para ser você.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onAnimals});
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
                      const Text(
                        'QUE BOM TER VOCÊ AQUI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Vamos\nbrincar?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      const Text('Uma descoberta\nde cada vez.'),
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
                child: const Text(
                  'UM MUNDO DE PEQUENAS DESCOBERTAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Aprender é melhor\ncom novos amigos.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Bichinhos, brincadeiras e um mundo para explorar.\nTudo no seu ritmo.',
                style: TextStyle(color: AppColors.muted, height: 1.6),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAnimals,
                icon: const Icon(Icons.pets_rounded, size: 20),
                label: const Text('Conhecer a turma'),
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

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});
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
    label: 'Jogar ${game.title}',
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
                          label: 'Gato',
                          size: 80,
                          decorative: true,
                        ),
                        const Text(
                          'G',
                          style: TextStyle(
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
                            label: 'Cachorro',
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
          const Row(
            children: [
              Text(
                'Vamos brincar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Spacer(),
              Icon(
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
