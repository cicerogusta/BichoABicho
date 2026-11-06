import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/material.dart';
import '../../../core/analytics/usage_analytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/soft_card.dart';
import '../../settings/presentation/app_settings.dart';
import 'profile_name_page.dart';
import 'profile_selection_page.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({super.key, required this.settings});
  final AppSettings settings;

  Future<void> _create(BuildContext context) async {
    await Navigator.of(context).push<int>(
      MaterialPageRoute(
        settings: RouteSettings(name: UsageScreen.profileName.name),
        builder: (_) =>
            ProfileNamePage(settings: settings, enterAfterSave: false),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final profile = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        settings: RouteSettings(name: UsageScreen.reportProfileSelection.name),
        builder: (context) => ProfileSelectionPage(
          settings: settings,
          allowBack: true,
          allowCreation: false,
          configureUnnamed: false,
          onSelected: (id) => Navigator.pop(context, id),
        ),
      ),
    );
    if (profile == null || !context.mounted) return;
    await Navigator.of(context).push<int>(
      MaterialPageRoute(
        settings: RouteSettings(name: UsageScreen.profileName.name),
        builder: (_) => ProfileNamePage(
          settings: settings,
          profile: profile,
          enterAfterSave: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: settings,
    builder: (context, _) => SoftCard(
      color: AppColors.sage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.profilesOnDevice,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(context.l10n.profileCountDescription(settings.profiles.length)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _create(context),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(context.l10n.createProfile),
              ),
              OutlinedButton.icon(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.l10n.editProfile),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(context.l10n.profileSettingsDescription),
        ],
      ),
    ),
  );
}
