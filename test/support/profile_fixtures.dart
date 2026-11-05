import 'package:bicho_a_bicho/features/animals/domain/animal.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';

Future<void> ensureProfiles(AppSettings settings, int count) async {
  while (settings.profiles.length < count) {
    final index = settings.profiles.length;
    await settings.createProfile(animalId: animals[index % animals.length].id);
  }
}
