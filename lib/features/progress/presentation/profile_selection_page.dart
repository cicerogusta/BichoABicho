import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../animals/domain/animal.dart';
import '../../settings/presentation/app_settings.dart';
import 'profile_appearance.dart';
import 'profile_name_page.dart';

class ProfileSelectionPage extends StatefulWidget {
  const ProfileSelectionPage({
    super.key,
    required this.settings,
    required this.onSelected,
    this.allowBack = false,
    this.allowCreation = true,
    this.configureUnnamed = true,
  });
  final AppSettings settings;
  final ValueChanged<int> onSelected;
  final bool allowBack;
  final bool allowCreation;
  final bool configureUnnamed;
  @override
  State<ProfileSelectionPage> createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  bool _selected = false;
  String _query = '';

  Future<int?> _edit({int? profile}) => Navigator.of(context).push<int>(
    MaterialPageRoute(
      settings: RouteSettings(name: UsageScreen.profileName.name),
      builder: (_) =>
          ProfileNamePage(settings: widget.settings, profile: profile),
    ),
  );

  Future<void> _select(int profile) async {
    if (_selected) return;
    _selected = true;
    if (widget.configureUnnamed &&
        !widget.settings.profileIsConfigured(profile)) {
      final saved = await _edit(profile: profile);
      if (!mounted) return;
      if (saved == null) {
        _selected = false;
        return;
      }
    }
    widget.onSelected(profile);
  }

  Future<void> _create() async {
    if (_selected) return;
    _selected = true;
    final profile = await _edit();
    if (!mounted) return;
    if (profile == null) {
      _selected = false;
      return;
    }
    widget.onSelected(profile);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.settings,
    builder: (context, _) {
      final query = normalizeWords(_query);
      final profiles = widget.settings.profiles
          .where(
            (p) => normalizeWords(
              '${p.label} ${p.cardNumber} ${p.avatar.name}',
            ).contains(query),
          )
          .toList();
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: widget.allowBack,
          title: Text(
            widget.allowCreation ? 'Quem vai brincar?' : 'Escolher cartão',
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.max(24.0, (constraints.maxWidth - 800) / 2);
              final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 24, side, 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.allowCreation
                                ? 'Toque no seu cartão.'
                                : 'Escolha um cartão.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Buscar cartão',
                              hintText: 'Nome, animal ou número',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                            onChanged: (value) =>
                                setState(() => _query = value),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                          if (widget.allowCreation && _query.isEmpty) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              key: const ValueKey('new_profile'),
                              onPressed: _create,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Novo cartão'),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Qualquer pessoa pode criar um cartão, com nome opcional e o bichinho que preferir.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (profiles.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(side),
                        child: const Text(
                          'Nenhum cartão encontrado. Tente outro nome, animal ou número.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: side),
                      sliver: SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260 * scale,
                          mainAxisExtent: 245 + 70 * scale,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          return Semantics(
                            button: true,
                            label:
                                '${profile.label}, ${profile.cardNumber}, bichinho ${profile.avatar.name.toLowerCase()}',
                            excludeSemantics: true,
                            onTap: () => _select(profile.id),
                            child: SoftCard(
                              color: profileColor(profile.animalId),
                              padding: const EdgeInsets.all(16),
                              onTap: () => _select(profile.id),
                              child: Column(
                                children: [
                                  AnimalPicture(
                                    path: profile.avatar.image,
                                    label: '',
                                    size: 100,
                                    decorative: true,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    profile.label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(profile.cardNumber),
                                  const Spacer(),
                                  Icon(
                                    profile.configured
                                        ? Icons.play_circle_outline_rounded
                                        : Icons.edit_outlined,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Use sempre o seu cartão para guardar suas descobertas.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}
