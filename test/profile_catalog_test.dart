import 'dart:convert';

import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/progress/domain/learning_history.dart';
import 'package:bicho_a_bicho/features/progress/domain/profile_catalog.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/localization.dart';

void main() {
  test(
    'creates and restores many independent users even with repeated names and animals',
    () async {
      final repository = MemorySettingsRepository();
      final settings = AppSettings(repository);
      final ids = await Future.wait(
        List.generate(
          128,
          (_) => settings.createProfile(animalId: 'dog', name: 'Ana'),
        ),
      );
      expect(settings.profiles.length, 129);
      expect(ids.toSet().length, 128);
      await settings.selectProfile(ids.last);
      final record = settings.recorderForActiveProfile();
      record(
        const LearningObservation(
          game: GameKind.matching,
          animalId: 'cat',
          choices: 2,
          action: LearningAction.started,
        ),
      );
      record(
        const LearningObservation(
          game: GameKind.matching,
          animalId: 'cat',
          choices: 2,
          action: LearningAction.incorrect,
          firstAttempt: true,
        ),
      );
      await settings.updateProfile(ids.last, animalId: 'elephant', name: 'Lia');
      final restored = AppSettings(repository);
      await restored.load();
      expect(restored.profiles.length, 129);
      expect(restored.activeProfile, ids.last);
      expect(restored.learningHistory.summarize(ids.last).errors, 1);
      expect(restored.learningHistory.summarize(ids.first).errors, 0);
      expect(restored.profile(ids.last).animalId, 'elephant');
      expect(profileLabel(restored, ids.last), 'Lia');
      final next = await restored.createProfile(animalId: 'cat');
      expect(next, greaterThan(ids.last));
      settings.dispose();
      restored.dispose();
    },
  );

  test(
    'legacy migration preserves names, IDs, hidden history and active selection',
    () async {
      final history = LearningHistory.empty().record(
        2,
        const LearningObservation(
          game: GameKind.counting,
          animalId: 'lion',
          choices: 2,
          action: LearningAction.started,
        ),
      );
      final repository = MemorySettingsRepository()
        ..values = {
          'active_profile': 2,
          'enabled_profiles': 1,
          'profile_label_0': 'Ana',
          'profile_label_1': 'Gui',
          'learning_history': history.encode(),
        };
      final settings = AppSettings(repository);
      await settings.load();
      expect(settings.profiles.map((p) => p.id), [0, 1, 2]);
      expect(settings.activeProfile, 2);
      expect(profileLabel(settings, 0), 'Ana');
      expect(profileLabel(settings, 1), 'Gui');
      expect(settings.learningHistory.summarize(2).started, 1);
      expect(await settings.createProfile(animalId: 'elephant'), 3);
      final restored = AppSettings(repository);
      await restored.load();
      expect(restored.profiles.length, 4);
      expect(restored.learningHistory.summarize(2).started, 1);
      await restored.clearProfileHistory(profile: 3);
      expect(restored.learningHistory.summarize(2).started, 1);
      settings.dispose();
      restored.dispose();
    },
  );

  test(
    'catalog rejects invalid identities and keeps names optional and bounded',
    () {
      final catalog = ProfileCatalog.initial().create(
        animalId: 'cat',
        name: '  Meu\n amigo ',
      );
      expect(catalog.profile(1).name, 'Meu amigo');
      expect(catalog.update(1, name: '').profile(1).name, isEmpty);
      expect(
        catalog.update(1, name: '🐱' * 30).profile(1).name.runes.length,
        24,
      );
      expect(() => catalog.create(animalId: 'unknown'), throwsArgumentError);
      final row = {'id': 0, 'animal': 'dog', 'name': '', 'configured': true};
      for (final raw in [
        {
          'version': 1,
          'next_id': 1,
          'profiles': [row, row],
        },
        {
          'version': 1,
          'next_id': 0,
          'profiles': [row],
        },
        {
          'version': 1,
          'next_id': 1,
          'profiles': [
            {...row, 'animal': 'unknown'},
          ],
        },
      ]) {
        expect(
          () => ProfileCatalog.decode(jsonEncode(raw)),
          throwsFormatException,
        );
      }
    },
  );
}
