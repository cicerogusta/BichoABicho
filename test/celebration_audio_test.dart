import 'dart:async';
import 'dart:typed_data';

import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_media_message.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

class DelayedStopAudio extends FakeAudio {
  final gate = Completer<void>();
  @override
  Future<void> stop() async {
    await super.stop();
    await gate.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GameViewModel create(
    FakeAudio audio, {
    bool Function()? sound,
    FakeSpeech? speech,
  }) => GameViewModel(
    session: GameSession(kind: GameKind.speaking, choiceCount: 2, rounds: 4),
    audio: audio,
    speech: speech ?? FakeSpeech(),
    soundEnabled: sound ?? () => true,
  );
  test(
    'correct answer plays one short celebration even with repeated taps',
    () async {
      final audio = FakeAudio();
      final model = create(audio);
      model.answer(model.round.answer);
      model.answer(model.round.answer);
      await Future<void>.delayed(Duration.zero);
      expect(audio.playedAssets, [GameViewModel.celebrationAsset]);
      expect(model.index, 0);
      model.dispose();
    },
  );
  test('wrong answers and muted celebrations stay silent', () async {
    final audio = FakeAudio();
    final model = create(audio, sound: () => false);
    model.answer(
      model.round.choices
          .firstWhere((choice) => choice.value != model.round.answer)
          .value,
    );
    await Future<void>.delayed(Duration.zero);
    expect(audio.plays, 0);
    model.answer(model.round.answer);
    await Future<void>.delayed(Duration.zero);
    expect(audio.plays, 0);
    expect(model.feedback, RoundFeedback.correct);
    model.dispose();
  });
  test('voice recognition uses the same celebration as touch', () async {
    final audio = FakeAudio();
    final speech = FakeSpeech();
    final model = create(audio, speech: speech);
    await model.listen();
    speech.onFinal!(model.round.animal.name);
    await Future<void>.delayed(Duration.zero);
    expect(audio.playedAssets, [GameViewModel.celebrationAsset]);
    model.dispose();
  });
  test('pausing before playback prevents late music', () async {
    final audio = DelayedStopAudio();
    final model = create(audio);
    model.answer(model.round.answer);
    final pause = model.pause();
    audio.gate.complete();
    await pause;
    await Future<void>.delayed(Duration.zero);
    expect(audio.plays, 0);
    model.dispose();
  });
  test('leaving a round prevents a pending celebration from playing', () async {
    final audio = DelayedStopAudio();
    final model = create(audio);
    model.answer(model.round.answer);
    final advance = model.next();
    audio.gate.complete();
    await advance;
    expect(audio.plays, 0);
    expect(model.index, 1);
    model.dispose();
  });
  test('muting during preparation is checked before playing', () async {
    var enabled = true;
    final audio = FakeAudio();
    final model = create(audio, sound: () => enabled);
    model.answer(model.round.answer);
    enabled = false;
    await Future<void>.delayed(Duration.zero);
    expect(audio.plays, 0);
    model.dispose();
  });
  test(
    'playback failure preserves success and offers readable feedback',
    () async {
      final audio = FakeAudio()..fail = true;
      final model = create(audio);
      model.answer(model.round.answer);
      await Future<void>.delayed(Duration.zero);
      expect(model.feedback, RoundFeedback.correct);
      expect(model.mediaMessage, GameMediaMessage.celebrationUnavailable);
      await model.next();
      expect(model.index, 1);
      model.dispose();
    },
  );
  test(
    'celebration audio is a valid short PCM asset with a smooth ending',
    () async {
      final data = await rootBundle.load('assets/celebration.wav');
      expect(String.fromCharCodes(data.buffer.asUint8List(0, 4)), 'RIFF');
      expect(data.getUint16(20, Endian.little), 1);
      expect(data.getUint16(22, Endian.little), 1);
      expect(data.getUint32(24, Endian.little), 44100);
      expect(data.getUint32(40, Endian.little), data.lengthInBytes - 44);
      expect((data.lengthInBytes - 44) / 88200, closeTo(1.7, 0.01));
      expect(
        data.getInt16(data.lengthInBytes - 2, Endian.little).abs(),
        lessThan(10),
      );
    },
  );
}
