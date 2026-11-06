import 'package:audioplayers/audioplayers.dart';

import 'animal_audio.dart';

class AssetAnimalAudio implements AnimalAudio {
  AudioPlayer? _player;
  Future<void> _queue = Future<void>.value();
  bool _closed = false;
  Future<void> _enqueue(Future<void> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return next;
  }

  @override
  Future<void> play(String asset) => _enqueue(() async {
    if (_closed) return;
    final player = _player ??= AudioPlayer();
    await player.stop();
    await player.setVolume(0.35);
    await player.play(AssetSource(asset));
  });

  @override
  Future<void> stop() => _enqueue(() async {
    await _player?.stop();
  });
  @override
  Future<void> dispose() {
    _closed = true;
    return _enqueue(() async {
      await _player?.dispose();
      _player = null;
    });
  }
}
