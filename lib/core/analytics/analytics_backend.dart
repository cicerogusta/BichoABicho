abstract interface class AnalyticsBackend {
  bool get supported;
  Future<void> configure(bool enabled);
  Future<void> event(String name, Map<String, Object> parameters);
  Future<void> screen(String name);
  Future<void> properties(Map<String, String> values);
  Future<void> reset();
}
