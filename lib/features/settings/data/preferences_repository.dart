import 'package:shared_preferences/shared_preferences.dart';
import '../domain/settings_repository.dart';
import '../../games/domain/game_definition.dart';

class PreferencesRepository implements SettingsRepository {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const _key = 'bicho_v2_';
  final Map<String, Object> _savedValues = {};

  @override
  Future<Map<String, Object>> load() async => {
    'sound': await _preferences.getBool('${_key}sound') ?? false,
    'calm': await _preferences.getBool('${_key}calm') ?? true,
    'choices': await _preferences.getInt('${_key}choices') ?? 2,
    'rounds': await _preferences.getInt('${_key}rounds') ?? 4,
    'analytics_enabled':
        await _preferences.getBool('${_key}analytics_enabled') ?? false,
    'analytics_version':
        await _preferences.getInt('${_key}analytics_version') ?? 0,
    'active_profile': await _preferences.getInt('${_key}active_profile') ?? 0,
    'profile_catalog':
        await _preferences.getString('${_key}profile_catalog') ?? '',
    if (await _preferences.getInt('${_key}enabled_profiles')
        case final int count)
      'enabled_profiles': count,
    for (var i = 0; i < 3; i++)
      'profile_label_$i':
          await _preferences.getString('${_key}profile_label_$i') ?? '',
    for (var i = 0; i < 3; i++)
      'profile_ready_$i':
          await _preferences.getBool('${_key}profile_ready_$i') ?? false,
    'learning_history':
        await _preferences.getString('${_key}learning_history') ?? '',
    for (final game in GameKind.values)
      'completed_${game.name}':
          await _preferences.getInt('${_key}completed_${game.name}') ?? 0,
  };

  @override
  Future<void> save(Map<String, Object> values) async {
    for (final entry in values.entries) {
      if (_savedValues[entry.key] == entry.value) continue;
      final value = entry.value;
      if (value is bool) await _preferences.setBool('$_key${entry.key}', value);
      if (value is int) await _preferences.setInt('$_key${entry.key}', value);
      if (value is String) {
        await _preferences.setString('$_key${entry.key}', value);
      }
      _savedValues[entry.key] = value;
    }
  }
}
