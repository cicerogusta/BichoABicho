import 'dart:convert';
import '../../animals/domain/animal.dart';

String normalizeProfileName(String name) => String.fromCharCodes(
  name.trim().replaceAll(RegExp(r'\s+'), ' ').runes.take(24),
);

class LearnerProfile {
  const LearnerProfile(
    this.id,
    this.animalId,
    this.name, {
    this.configured = true,
  });
  final int id;
  final String animalId;
  final String name;
  final bool configured;
  Animal get avatar => animals.firstWhere((a) => a.id == animalId);
  String get label => name.isEmpty ? 'Meu ${avatar.name}' : name;
  String get cardNumber => 'Cartão ${id + 1}';
}

class ProfileCatalog {
  ProfileCatalog._(Map<int, LearnerProfile> profiles, this.nextId)
    : _profiles = Map.unmodifiable(profiles);
  factory ProfileCatalog.initial() => ProfileCatalog._({
    0: const LearnerProfile(0, 'dog', '', configured: false),
  }, 1);
  final Map<int, LearnerProfile> _profiles;
  final int nextId;
  List<LearnerProfile> get profiles => List.unmodifiable(_profiles.values);
  bool contains(int id) => _profiles.containsKey(id);
  LearnerProfile profile(int id) =>
      _profiles[id] ?? (throw ArgumentError.value(id, 'profile'));

  ProfileCatalog create({required String animalId, String name = ''}) {
    _validateAnimal(animalId);
    return ProfileCatalog._({
      ..._profiles,
      nextId: LearnerProfile(nextId, animalId, normalizeProfileName(name)),
    }, nextId + 1);
  }

  ProfileCatalog update(int id, {String? animalId, String? name}) {
    final current = profile(id);
    final animal = animalId ?? current.animalId;
    _validateAnimal(animal);
    return ProfileCatalog._({
      ..._profiles,
      id: LearnerProfile(
        id,
        animal,
        name == null ? current.name : normalizeProfileName(name),
      ),
    }, nextId);
  }

  static void _validateAnimal(String id) {
    if (!animals.any((animal) => animal.id == id)) {
      throw ArgumentError.value(id, 'animalId');
    }
  }

  String encode() => jsonEncode({
    'version': 1,
    'next_id': nextId,
    'profiles': [
      for (final p in _profiles.values)
        {
          'id': p.id,
          'animal': p.animalId,
          'name': p.name,
          'configured': p.configured,
        },
    ],
  });

  factory ProfileCatalog.decode(String source) {
    final Object? raw = jsonDecode(source);
    if (raw is! Map<String, Object?> ||
        raw['version'] != 1 ||
        raw['next_id'] is! int ||
        raw['profiles'] is! List<Object?>) {
      throw const FormatException('Invalid profile catalog');
    }
    final profiles = <int, LearnerProfile>{};
    for (final row in raw['profiles']! as List<Object?>) {
      if (row is! Map<String, Object?> ||
          row['id'] is! int ||
          (row['id']! as int) < 0 ||
          row['name'] is! String ||
          row['configured'] is! bool ||
          !animals.any((a) => a.id == row['animal'])) {
        throw const FormatException('Invalid profile');
      }
      final id = row['id']! as int;
      if (profiles.containsKey(id)) {
        throw const FormatException('Duplicate profile');
      }
      profiles[id] = LearnerProfile(
        id,
        row['animal']! as String,
        normalizeProfileName(row['name']! as String),
        configured: row['configured']! as bool,
      );
    }
    final nextId = raw['next_id']! as int;
    if (profiles.isEmpty || profiles.keys.any((id) => id >= nextId)) {
      throw const FormatException('Invalid next profile ID');
    }
    return ProfileCatalog._(profiles, nextId);
  }

  /// Retains all identified/used old slots, including previously disabled ones.
  factory ProfileCatalog.migrate(
    Map<String, Object> values,
    Set<int> historyIds,
  ) {
    final count = values['enabled_profiles'];
    final oldCount = count is int && count >= 1 && count <= 3 ? count : 1;
    final active = values['active_profile'];
    final ids = <int>{0, ...historyIds};
    if (active is int && active >= 0 && active < 3) ids.add(active);
    for (var i = 0; i < 3; i++) {
      if (i < oldCount ||
          values['profile_ready_$i'] == true ||
          (values['profile_label_$i'] is String &&
              (values['profile_label_$i']! as String).trim().isNotEmpty)) {
        ids.add(i);
      }
    }
    final ordered = ids.toList()..sort();
    final profiles = <int, LearnerProfile>{};
    for (final id in ordered) {
      final oldLabel = values['profile_label_$id'];
      final name = oldLabel is String ? normalizeProfileName(oldLabel) : '';
      profiles[id] = LearnerProfile(
        id,
        animals[id % animals.length].id,
        name,
        configured: name.isNotEmpty || values['profile_ready_$id'] == true,
      );
    }
    return ProfileCatalog._(profiles, ordered.last + 1);
  }
}
