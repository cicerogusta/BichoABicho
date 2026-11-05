import 'dart:io';
import 'dart:ui' as ui;
import 'package:bicho_a_bicho/app/app.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fakes.dart';
import 'support/profile_navigation.dart';

Future<void> openApp(
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

  testWidgets(
    'a card is selected after opening and new users remain accessible from home',
    (tester) async {
      final settings = AppSettings(MemorySettingsRepository());
      await openApp(tester, settings);
      expect(find.text('Quem vai brincar?'), findsOneWidget);
      expect(find.text('O que vamos descobrir hoje?'), findsNothing);
      await chooseLearner(tester, 'Meu Cachorro');
      expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
      expect(find.text('Trocar'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );

  testWidgets('anyone creates an unnamed elephant card from entry', (
    tester,
  ) async {
    final settings = AppSettings(MemorySettingsRepository());
    await openApp(tester, settings);
    await tester.tap(find.byKey(const ValueKey('new_profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Elefante'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar e brincar'));
    await tester.tap(find.text('Salvar e brincar'));
    await tester.pumpAndSettle();
    expect(settings.profiles.length, 2);
    expect(settings.profile(settings.activeProfile).animalId, 'elephant');
    expect(settings.profile(settings.activeProfile).name, isEmpty);
    expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
    await tester.ensureVisible(find.text(games.first.title));
    await tester.tap(find.text(games.first.title));
    await tester.pumpAndSettle();
    expect(settings.learningHistory.summarize(1).started, 1);
    expect(settings.learningHistory.summarize(0).started, 0);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });

  testWidgets(
    'many cards can be searched and switch independent game histories',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = AppSettings(MemorySettingsRepository());
      for (var i = 1; i <= 12; i++) {
        await settings.createProfile(animalId: 'cat', name: 'Pessoa $i');
      }
      final key = GlobalKey();
      await openApp(tester, settings, captureKey: key);
      if (const bool.fromEnvironment('CAPTURE_PREVIEWS')) {
        await tester.runAsync(() async {
          for (final picture in tester.widgetList<Image>(find.byType(Image))) {
            await precacheImage(picture.image, key.currentContext!);
          }
        });
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'docs/previews/profile_selection.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.enterText(find.byType(TextField), 'Pessoa 12');
      await tester.pumpAndSettle();
      await chooseLearner(tester, 'Pessoa 12');
      expect(settings.activeProfile, 12);
      await tester.ensureVisible(find.text(games.first.title));
      await tester.tap(find.text(games.first.title));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Trocar'));
      await tester.tap(find.text('Trocar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Pessoa 2');
      await tester.pumpAndSettle();
      await chooseLearner(tester, 'Pessoa 2');
      await tester.ensureVisible(find.text(games.first.title));
      await tester.tap(find.text(games.first.title));
      await tester.pumpAndSettle();
      expect(settings.learningHistory.summarize(12).started, 1);
      expect(settings.learningHistory.summarize(2).started, 1);
      expect(settings.profiles.length, 13);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );

  testWidgets('same name and animal are distinguishable by card number', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final settings = AppSettings(MemorySettingsRepository());
    await settings.createProfile(animalId: 'dog', name: 'Ana');
    await settings.createProfile(animalId: 'dog', name: 'Ana');
    await openApp(tester, settings);
    final card = find.bySemanticsLabel('Ana, Cartão 3, bichinho cachorro');
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(settings.activeProfile, 2);
    expect(settings.profiles.length, 3);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });

  testWidgets(
    'fresh launch asks for the saved card without repeating registration',
    (tester) async {
      final repository = MemorySettingsRepository();
      final settings = AppSettings(repository);
      final id = await settings.createProfile(animalId: 'lion', name: 'Lia');
      await settings.selectProfile(id);
      await openApp(tester, settings);
      await chooseLearner(tester, 'Lia');
      await tester.pumpWidget(const SizedBox());
      final restored = AppSettings(repository);
      await restored.load();
      await openApp(tester, restored);
      expect(find.text('Quem vai brincar?'), findsOneWidget);
      await chooseLearner(tester, 'Lia');
      expect(find.text('O que vamos descobrir hoje?'), findsOneWidget);
      expect(restored.activeProfile, id);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
      restored.dispose();
    },
  );

  testWidgets('parents edit name and avatar without switching who is playing', (
    tester,
  ) async {
    final settings = AppSettings(MemorySettingsRepository());
    await settings.createProfile(animalId: 'cat', name: 'Bia');
    await openApp(tester, settings);
    await chooseLearner(tester, 'Meu Cachorro');
    await tester.tap(find.text('Responsáveis'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Editar cartão'));
    await tester.tap(find.text('Editar cartão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bia'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Amiga da turma');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Elefante'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar cartão'));
    await tester.tap(find.text('Salvar cartão'));
    await tester.pumpAndSettle();
    expect(settings.profile(1).name, 'Amiga da turma');
    expect(settings.profile(1).animalId, 'elephant');
    expect(settings.activeProfile, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    settings.dispose();
  });

  testWidgets(
    'search and selection support 200 percent text with many profiles',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final settings = AppSettings(MemorySettingsRepository());
      for (var i = 1; i <= 8; i++) {
        await settings.createProfile(animalId: 'dog', name: 'Pessoa $i');
      }
      await openApp(tester, settings);
      await tester.enterText(find.byType(TextField), 'Pessoa 8');
      await tester.pumpAndSettle();
      await chooseLearner(tester, 'Pessoa 8');
      expect(settings.activeProfile, 8);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      settings.dispose();
    },
  );
}
