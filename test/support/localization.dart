import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_catalog.dart';
import 'package:bicho_a_bicho/features/progress/presentation/profile_labels.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

final testStrings = lookupAppLocalizations(const Locale('pt', 'BR'));
final List<GameDefinition> games = gameCatalog(testStrings);

String profileLabel(AppSettings settings, int id) =>
    settings.profile(id).displayName(testStrings);
