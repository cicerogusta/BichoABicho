import '../../../l10n/app_localizations.dart';
import '../domain/profile_catalog.dart';

/// Display labels belong to the UI, not to persisted profile data.
extension ProfileLabels on LearnerProfile {
  String displayName(AppLocalizations strings) =>
      name.isEmpty ? strings.profileDefaultName(avatar.name) : name;

  String displayCardNumber(AppLocalizations strings) =>
      strings.profileCardNumber(id + 1);
}
