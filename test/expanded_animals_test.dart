import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'package:bicho_a_bicho/core/theme/app_theme.dart';
import 'package:bicho_a_bicho/core/widgets/soft_card.dart';
import 'package:bicho_a_bicho/features/animals/domain/animal.dart';
import 'package:bicho_a_bicho/features/animals/presentation/animal_explorer.dart';
import 'package:bicho_a_bicho/features/games/domain/drawing_template.dart';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:bicho_a_bicho/features/settings/presentation/app_settings.dart';
import 'package:bicho_a_bicho/features/opening/presentation/opening_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('all eight animals enter before the five-second opening ends', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.create(),
        home: OpeningPage(onComplete: () => completed = true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(completed, isFalse);
    for (final animal in animals) {
      final picture = find.byWidgetPredicate(
        (widget) => widget is AnimalPicture && widget.path == animal.image,
      );
      expect(picture, findsOneWidget);
      expect(tester.getRect(picture).bottom, lessThan(740));
      expect(
        tester
            .widgetList<Opacity>(
              find.ancestor(of: picture, matching: find.byType(Opacity)),
            )
            .map((w) => w.opacity),
        everyElement(1.0),
      );
    }
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });
  test('every animal is available to compatible games and analytics', () {
    expect(animals.length, 8);
    expect(animals.map((a) => a.id).toSet().length, animals.length);
    expect(animals.map((a) => a.sound).toSet().length, animals.length);
    for (final animal in animals) {
      expect(validatedParameters({UsageParameter.animalId: animal.id}), {
        'animal_id': animal.id,
      });
    }
    for (final kind in GameKind.values) {
      final session = GameSession(
        kind: kind,
        choiceCount: 3,
        rounds: animals.length * 2,
        random: Random(7),
      );
      final supported = kind == GameKind.drawing
          ? animals.where((a) => drawingTemplates.containsKey(a.id))
          : animals;
      expect(
        session.rounds.map((r) => r.animal.id).toSet(),
        supported.map((a) => a.id).toSet(),
      );
      for (final round in session.rounds) {
        expect(
          round.choices.map((c) => c.value).toSet().length,
          round.choices.length,
        );
      }
    }
  });

  test('new recordings are distinct non-silent mono PCM16 WAV assets', () {
    final signatures = <int>{};
    for (final animal in animals.skip(4)) {
      final bytes = File('assets/${animal.sound}').readAsBytesSync();
      final data = ByteData.sublistView(bytes);
      expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
      expect(String.fromCharCodes(bytes.skip(8).take(4)), 'WAVE');
      var offset = 12;
      var foundAudio = false;
      while (offset + 8 <= bytes.length) {
        final chunk = String.fromCharCodes(bytes.skip(offset).take(4));
        final size = data.getUint32(offset + 4, Endian.little);
        if (chunk == 'fmt ') {
          expect(data.getUint16(offset + 8, Endian.little), 1);
          expect(data.getUint16(offset + 10, Endian.little), 1);
          expect(data.getUint32(offset + 12, Endian.little), 22050);
          expect(data.getUint16(offset + 22, Endian.little), 16);
        }
        if (chunk == 'data') {
          expect(size / (22050 * 2), inInclusiveRange(0.4, 6));
          var peak = 0;
          for (var i = offset + 8; i < offset + 8 + size; i += 2) {
            peak = max(peak, data.getInt16(i, Endian.little).abs());
          }
          expect(peak, inInclusiveRange(1000, 21301));
          signatures.add(Object.hash(size, peak));
          foundAudio = true;
        }
        offset += 8 + size + size % 2;
      }
      expect(foundAudio, isTrue);
    }
    expect(signatures.length, 4);
  });

  test(
    'games play the sound of each round including the new animals',
    () async {
      final audio = FakeAudio();
      final model = GameViewModel(
        session: GameSession(
          kind: GameKind.matching,
          choiceCount: 3,
          rounds: animals.length,
          random: Random(4),
        ),
        audio: audio,
        speech: FakeSpeech(),
      );
      addTearDown(model.dispose);
      for (var i = 0; i < animals.length; i++) {
        await model.playSound(true);
        expect(audio.playedAssets.last, model.round.animal.sound);
        await model.next();
      }
      expect(audio.playedAssets.toSet(), animals.map((a) => a.sound).toSet());
    },
  );

  testWidgets('explorer plays every animal and respects mute', (tester) async {
    final settings = AppSettings(MemorySettingsRepository());
    await settings.load();
    await settings.update(sound: true);
    final audio = FakeAudio();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.create(),
        home: Scaffold(
          body: AnimalExplorer(settings: settings, audio: audio),
        ),
      ),
    );
    for (final animal in animals) {
      final card = find.ancestor(
        of: find.text(animal.name),
        matching: find.byType(SoftCard),
      );
      final button = find.descendant(
        of: card,
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(audio.playedAssets.last, animal.sound);
      expect(tester.takeException(), isNull);
    }
    await settings.update(sound: false);
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Ouvir o bichinho').last,
    );
    await tester.pumpAndSettle();
    expect(audio.plays, animals.length);
    await tester.pumpWidget(const SizedBox());
    expect(audio.disposed, isTrue);
    settings.dispose();
  });
}
