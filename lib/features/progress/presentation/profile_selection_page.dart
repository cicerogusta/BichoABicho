import 'dart:math' as math;

import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';

import '../../../core/analytics/usage_analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../animals/domain/animal.dart';
import '../../settings/presentation/app_settings.dart';
import 'profile_appearance.dart';
import 'profile_labels.dart';
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
              context.l10n.profileSearchIndex(
                p.displayName(context.l10n),
                p.displayCardNumber(context.l10n),
                p.avatar.name,
              ),
            ).contains(query),
          )
          .toList();
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: widget.allowBack,
          title: Text(
            widget.allowCreation
                ? context.l10n.profileSelectionTitle
                : context.l10n.selectProfile,
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
                                ? context.l10n.profileSelectionPrompt
                                : context.l10n.selectProfilePrompt,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: context.l10n.searchProfile,
                              hintText: context.l10n.profileSearchHint,
                              prefixIcon: const Icon(Icons.search_rounded),
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
                              label: Text(context.l10n.newProfile),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.profileCreationDescription,
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
                        child: Text(context.l10n.profileSearchEmpty),
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
                            label: context.l10n.profileAccessibilityLabel(
                              profile.displayName(context.l10n),
                              profile.displayCardNumber(context.l10n),
                              profile.avatar.name.toLowerCase(),
                            ),
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
                                    profile.displayName(context.l10n),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(profile.displayCardNumber(context.l10n)),
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.l10n.profileHistoryReminder,
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
