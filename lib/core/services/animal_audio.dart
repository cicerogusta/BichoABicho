abstract interface class AnimalAudio {
  Future<void> play(String asset);
  Future<void> stop();
  Future<void> dispose();
}
