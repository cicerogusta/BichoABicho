abstract interface class AnimalSpeech {
  Future<bool> listen({
    required void Function(String) onFinal,
    required void Function() onDone,
    required void Function() onError,
  });
  Future<void> cancel();
}
