import 'package:speech_to_text/speech_to_text.dart';

abstract interface class AnimalSpeech {
  Future<bool> listen({
    required void Function(String) onFinal,
    required void Function() onDone,
    required void Function() onError,
  });
  Future<void> cancel();
}

class DeviceAnimalSpeech implements AnimalSpeech {
  final SpeechToText _speech = SpeechToText();
  int _generation = 0;
  void Function()? _onDone;
  void Function()? _onError;
  @override
  Future<bool> listen({
    required void Function(String) onFinal,
    required void Function() onDone,
    required void Function() onError,
  }) async {
    final generation = ++_generation;
    _onDone = onDone;
    _onError = onError;
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') _onDone?.call();
      },
      onError: (_) => _onError?.call(),
    );
    if (!available || generation != _generation) return false;
    // SpeechToText is a process-wide singleton and keeps initialize callbacks.
    // Rebind them when a new game creates an adapter.
    _speech.statusListener = (status) {
      if (status == 'done') _onDone?.call();
    };
    _speech.errorListener = (_) => _onError?.call();
    final locales = await _speech.locales();
    if (generation != _generation) return false;
    final portuguese = locales.where(
      (locale) => locale.localeId.toLowerCase().replaceAll('-', '_') == 'pt_br',
    );
    if (portuguese.isEmpty) return false;
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: portuguese.first.localeId,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 4),
        partialResults: false,
        cancelOnError: true,
      ),
      onResult: (result) {
        if (result.finalResult && generation == _generation) {
          onFinal(result.recognizedWords);
        }
      },
    );
    return true;
  }

  @override
  Future<void> cancel() {
    _generation++;
    _onDone = null;
    _onError = null;
    return _speech.cancel();
  }
}
