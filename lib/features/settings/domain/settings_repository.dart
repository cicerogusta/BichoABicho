abstract interface class SettingsRepository {
  Future<Map<String, Object>> load();
  Future<void> save(Map<String, Object> values);
}
