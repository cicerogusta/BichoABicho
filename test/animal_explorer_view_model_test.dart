import 'dart:async';

import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';
import 'package:bicho_a_bicho/features/animals/presentation/animal_explorer_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_analytics.dart';
import 'support/fakes.dart';

class PendingAudio extends FakeAudio {
  final pending = Completer<void>();

  @override
  Future<void> play(String asset) async {
    await super.play(asset);
    await pending.future;
  }
}

void main() {
  test('muted exploration never starts the audio adapter', () async {
    final audio = FakeAudio();
    final model = AnimalExplorerViewModel(audio, soundEnabled: () => false);
    await model.play(animals.first);
    expect(audio.plays, 0);
    expect(model.message, ExplorerMessage.soundDisabled);
    expect(model.busy, isFalse);
    model.dispose();
  });

  test('playback failures are typed and a later attempt can recover', () async {
    final audio = FakeAudio()..fail = true;
    final analytics = RecordingAnalytics();
    final model = AnimalExplorerViewModel(
      audio,
      soundEnabled: () => true,
      analytics: analytics,
    );
    await model.play(animals.first);
    expect(model.message, ExplorerMessage.soundUnavailable);
    expect(model.busy, isFalse);
    expect(
      analytics.events.where(
        (event) => event.$1 == UsageEvent.mediaUnavailable,
      ),
      hasLength(1),
    );
    audio.fail = false;
    await model.play(animals.last);
    expect(model.message, isNull);
    expect(audio.playedAssets.last, animals.last.sound);
    model.dispose();
  });

  test(
    'rapid requests are ignored and cancellation invalidates late errors',
    () async {
      final audio = PendingAudio();
      final model = AnimalExplorerViewModel(audio, soundEnabled: () => true);
      final playing = model.play(animals.first);
      await model.play(animals.last);
      expect(audio.plays, 1);
      await model.stop();
      audio.pending.completeError(Exception('Canceled playback'));
      await playing;
      expect(model.busy, isFalse);
      expect(model.message, isNull);
      model.dispose();
    },
  );

  test(
    'disposing releases resources and ignores late playback callbacks',
    () async {
      final audio = PendingAudio();
      final model = AnimalExplorerViewModel(audio, soundEnabled: () => true);
      var notifications = 0;
      model.addListener(() => notifications++);
      final playing = model.play(animals.first);
      final beforeDisposal = notifications;
      model.dispose();
      audio.pending.complete();
      await playing;
      await model.play(animals.last);
      expect(notifications, beforeDisposal);
      expect(audio.plays, 1);
      expect(audio.disposed, isTrue);
    },
  );
}
