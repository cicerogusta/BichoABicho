import 'dart:math';
import 'dart:async';
import 'package:bicho_a_bicho/features/games/domain/game_definition.dart';
import 'package:bicho_a_bicho/features/games/domain/game_session.dart';
import 'package:bicho_a_bicho/features/games/presentation/game_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/fakes.dart';

void main() {
  late GameViewModel model;
  late FakeAudio audio;
  late FakeSpeech speech;
  setUp(() {
    audio = FakeAudio();
    speech = FakeSpeech();
    model = GameViewModel(
      session: GameSession(
        kind: GameKind.speaking,
        choiceCount: 3,
        rounds: 4,
        random: Random(3),
      ),
      audio: audio,
      speech: speech,
    );
  });
  tearDown(() => model.dispose());

  test(
    'retry keeps choices stable; success requires explicit advance',
    () async {
      final round = model.round;
      final choices = round.choices.map((c) => c.value).toList();
      model.answer(choices.firstWhere((value) => value != round.answer));
      expect(model.feedback, RoundFeedback.retry);
      expect(model.index, 0);
      expect(model.round.choices.map((c) => c.value), choices);
      model.answer(round.answer);
      expect(model.feedback, RoundFeedback.correct);
      expect(model.index, 0);
      await Future.wait([model.next(), model.next()]);
      expect(model.index, 1);
      expect(model.feedback, RoundFeedback.none);
      expect(model.attempted, isEmpty);
    },
  );
  test('invalid answers and answers while paused are ignored', () async {
    model.answer('invalid');
    expect(model.feedback, RoundFeedback.none);
    await model.pause();
    model.answer(model.round.answer);
    expect(model.feedback, RoundFeedback.none);
    expect(audio.stops, greaterThan(0));
    model.resume();
    model.answer(model.round.answer);
    expect(model.feedback, RoundFeedback.correct);
  });
  test('session ends without incrementing beyond the last round', () async {
    for (var i = 0; i < 4; i++) {
      await model.next();
    }
    expect(model.finished, isTrue);
    expect(model.index, 3);
    await model.next();
    expect(model.index, 3);
  });
  test(
    'muted sound never starts the player; audio errors remain recoverable',
    () async {
      await model.playSound(false);
      expect(audio.plays, 0);
      expect(model.mediaMessage, contains('desligado'));
      audio.fail = true;
      await model.playSound(true);
      expect(model.mediaBusy, isFalse);
      expect(model.mediaMessage, contains('não pôde'));
      model.answer(model.round.answer);
      expect(model.feedback, RoundFeedback.correct);
    },
  );
  test('speech unavailable allows answering by touch', () async {
    speech.available = false;
    await model.listen();
    expect(model.listening, isFalse);
    expect(model.mediaMessage, contains('tocando'));
    model.answer(model.round.answer);
    expect(model.feedback, RoundFeedback.correct);
  });
  test('late speech callbacks cannot affect a different round', () async {
    await model.listen();
    final callback = speech.onFinal!;
    final previousName = model.round.animal.name;
    await model.next();
    callback(previousName);
    expect(model.feedback, RoundFeedback.none);
    expect(model.index, 1);
  });
  test(
    'speech accepts an animal name within a phrase without judging articulation',
    () async {
      await model.listen();
      speech.onFinal!('É um ${model.round.animal.name.toUpperCase()}!');
      expect(model.feedback, RoundFeedback.correct);
      expect(model.listening, isFalse);
    },
  );
  test(
    'speech mismatch suggests alternatives without marking an error',
    () async {
      await model.listen();
      speech.onFinal!('não entendi');
      expect(model.feedback, RoundFeedback.none);
      expect(model.mediaMessage, contains('tocar'));
    },
  );
  test('disposed model ignores callbacks and releases resources', () async {
    final other = GameViewModel(
      session: model.session,
      audio: audio,
      speech: speech,
    );
    await other.listen();
    final callback = speech.onFinal!;
    other.dispose();
    callback('gato');
    await Future<void>.delayed(Duration.zero);
    expect(audio.disposed, isTrue);
  });
  test(
    'pause during microphone preparation cancels pending recognition',
    () async {
      speech.initialization = Completer<bool>();
      final pending = model.listen();
      await Future<void>.delayed(Duration.zero);
      await model.pause();
      speech.initialization!.complete(true);
      await pending;
      expect(model.listening, isFalse);
      expect(model.paused, isTrue);
      speech.onFinal!(model.round.animal.name);
      expect(model.feedback, RoundFeedback.none);
    },
  );
  test('rapid microphone taps only start one recognition session', () async {
    await Future.wait([model.listen(), model.listen()]);
    expect(speech.listens, 1);
  });
  test(
    'counting never counts one animal twice and resets between rounds',
    () async {
      model.countAnimal(0);
      model.countAnimal(0);
      model.countAnimal(-1);
      model.countAnimal(99);
      expect(model.countedAnimals, {0});
      await model.next();
      expect(model.countedAnimals, isEmpty);
    },
  );
}
