import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/app/app_dependencies.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/localization.dart';
import 'support/profile_navigation.dart';

void main() {
  testWidgets(
    'injected adapters survive rebuilds and account access stays replaceable',
    (tester) async {
      final repository = FakeAccountRepository()..name = '';
      final audioInstances = <FakeAudio>[];
      final dependencies = AppDependencies(
        accountRepository: repository,
        createAudio: () {
          final audio = FakeAudio();
          audioInstances.add(audio);
          return audio;
        },
        createSpeech: FakeSpeech.new,
      );
      final settings = AppSettings(MemorySettingsRepository());
      await settings.updateProfile(0, name: 'Lia');
      await tester.pumpWidget(
        AnimalApp(settings: settings, dependencies: dependencies),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(testStrings.startNow));
      await tester.pumpAndSettle();
      await chooseLearner(tester, 'Lia');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(games.first.title));
      await tester.tap(find.text(games.first.title));
      await tester.pumpAndSettle();
      expect(audioInstances, hasLength(1));
      await settings.update(sound: true);
      await tester.pumpAndSettle();
      expect(audioInstances, hasLength(1));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(audioInstances.single.disposed, isTrue);
      await tester.tap(find.text(testStrings.parentsTab));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(testStrings.optionalAccount));
      await tester.tap(find.text(testStrings.optionalAccount));
      await tester.pumpAndSettle();
      expect(
        find.text(testStrings.accountGreeting(testStrings.guardian)),
        findsOneWidget,
      );
      expect(repository.signIns, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );
}
