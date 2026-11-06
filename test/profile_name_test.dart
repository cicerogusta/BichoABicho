import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/core/widgets/soft_card.dart';
import 'package:bicho_a_bicho/features/progress/presentation/profile_name_page.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/capture_preview.dart';
import 'support/fake_analytics.dart';
import 'support/fakes.dart';
import 'support/localization.dart';

Future<void> openPicker(
  WidgetTester tester,
  AppSettings settings, {
  GlobalKey? captureKey,
}) async {
  final app = AnimalApp(settings: settings);
  await tester.pumpWidget(
    captureKey == null ? app : RepaintBoundary(key: captureKey, child: app),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Começar agora'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'Nunito',
    )..addFont(rootBundle.load('fonts/Nunito.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  test(
    'named and unnamed registration restore without emitting personal analytics',
    () async {
      final repository = MemorySettingsRepository();
      final analytics = RecordingAnalytics();
      final settings = AppSettings(repository, analytics: analytics);
      expect(settings.profileIsConfigured(0), isFalse);
      await settings.createProfile(animalId: 'cat');
      await settings.updateProfile(0, name: ' Ana ');
      final restored = AppSettings(repository);
      await restored.load();
      expect(restored.profileIsConfigured(0), isTrue);
      expect(restored.profileIsConfigured(1), isTrue);
      expect(profileLabel(restored, 0), 'Ana');
      expect(profileLabel(restored, 1), 'Meu Gato');
      expect(analytics.events, isEmpty);
      final legacy = AppSettings(
        MemorySettingsRepository()..values = {'profile_label_0': 'Bia'},
      );
      await legacy.load();
      expect(legacy.profileIsConfigured(0), isTrue);
      settings.dispose();
      restored.dispose();
      legacy.dispose();
    },
  );

  testWidgets(
    'selected animal opens a naming page, saves and does not ask again',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MemorySettingsRepository();
      final settings = AppSettings(repository);
      final key = GlobalKey();
      await openPicker(tester, settings, captureKey: key);
      final repeatSelection = tester
          .widget<SoftCard>(
            find
                .ancestor(
                  of: find.text('Meu Cachorro'),
                  matching: find.byType(SoftCard),
                )
                .first,
          )
          .onTap!;
      await tester.tap(find.text('Meu Cachorro'));
      repeatSelection();
      await tester.pumpAndSettle();
      expect(find.byType(ProfileNamePage), findsOneWidget);
      expect(find.text('Seu cartão do cachorro'), findsOneWidget);
      expect(
        tester.widget<AnimalPicture>(find.byType(AnimalPicture).first).path,
        'assets/animal_dog.png',
      );
      if (const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
        await capturePreview(tester, key, 'profile_name');
      }
      await tester.enterText(find.byType(TextFormField), 'Ana');
      await tester.ensureVisible(find.text('Salvar e brincar'));
      await tester.tap(find.text('Salvar e brincar'));
      await tester.pumpAndSettle();
      expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
      expect(profileLabel(settings, 0), 'Ana');
      await tester.pumpWidget(const SizedBox());
      final restored = AppSettings(repository);
      await restored.load();
      await openPicker(tester, restored);
      await tester.tap(find.text('Ana'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileNamePage), findsNothing);
      expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
      restored.dispose();
    },
  );

  testWidgets('back cancels setup and another animal can be selected', (
    tester,
  ) async {
    final settings = AppSettings(MemorySettingsRepository());
    await openPicker(tester, settings);
    await tester.tap(find.text('Meu Cachorro'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(settings.profileIsConfigured(0), isFalse);
    await tester.tap(find.byKey(const ValueKey('new_profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Gato'));
    await tester.pumpAndSettle();
    expect(find.text('Seu cartão do gato'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Lu');
    await tester.ensureVisible(find.text('Salvar e brincar'));
    await tester.tap(find.text('Salvar e brincar'));
    await tester.pumpAndSettle();
    expect(settings.activeProfile, 1);
    expect(profileLabel(settings, 1), 'Lu');
    expect(settings.profileIsConfigured(0), isFalse);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });

  testWidgets('failed save stays on the accessible form and allows retry', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = MemorySettingsRepository();
    final settings = AppSettings(repository);
    await openPicker(tester, settings);
    await tester.ensureVisible(find.byKey(const ValueKey('new_profile')));
    await tester.tap(find.byKey(const ValueKey('new_profile')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Lia');
    repository.fail = true;
    await tester.ensureVisible(find.text('Salvar e brincar'));
    await tester.tap(find.text('Salvar e brincar'));
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível salvar neste aparelho. Tente novamente.'),
      findsOneWidget,
    );
    expect(find.byType(ProfileNamePage), findsOneWidget);
    expect(settings.profiles.length, 2);
    repository.fail = false;
    await tester.ensureVisible(find.text('Salvar e brincar'));
    await tester.tap(find.text('Salvar e brincar'));
    await tester.pumpAndSettle();
    expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
    expect(settings.profiles.length, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });
}
