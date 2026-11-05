import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fakes.dart';

void main() {
  test(
    'uses calm, silent defaults and persists settings and session counts',
    () async {
      final repository = MemorySettingsRepository();
      final settings = AppSettings(repository);
      expect(settings.soundEnabled, isFalse);
      expect(settings.calmMode, isTrue);
      await settings.update(sound: true, choices: 3, sessionRounds: 6);
      await settings.recordCompletion('matching');
      final restored = AppSettings(repository);
      await restored.load();
      expect(restored.soundEnabled, isTrue);
      expect(restored.choiceCount, 3);
      expect(restored.rounds, 6);
      expect(restored.rounds, 6);
      expect(restored.completed('matching'), 1);
      await restored.resetProgress();
      expect(restored.totalCompleted, 0);
      expect(restored.choiceCount, 3);
      settings.dispose();
      restored.dispose();
    },
  );
  test('serializes rapid updates and preserves the latest snapshot', () async {
    final repository = MemorySettingsRepository();
    final settings = AppSettings(repository);
    await Future.wait([
      settings.update(sound: true),
      settings.update(choices: 3),
      settings.recordCompletion('counting'),
    ]);
    expect(repository.values['sound'], isTrue);
    expect(repository.values['choices'], 3);
    expect(repository.values['completed_counting'], 1);
    settings.dispose();
  });
  test(
    'storage failure keeps the app usable and exposes save failure',
    () async {
      final repository = MemorySettingsRepository()..fail = true;
      final settings = AppSettings(repository);
      await settings.load();
      expect(settings.storageFailed, isTrue);
      await settings.update(choices: 3);
      expect(settings.choiceCount, 3);
      expect(settings.storageFailed, isTrue);
      repository.fail = false;
      await settings.update(sound: true);
      expect(settings.storageFailed, isFalse);
      settings.dispose();
    },
  );
}
