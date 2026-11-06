import 'dart:convert';

import 'package:bicho_a_bicho/features/animals/domain/animal_catalog.dart';

import '../../animals/domain/animal.dart';
import '../../games/domain/game_definition.dart';

enum LearningAction { started, correct, incorrect, hint, skipped }

class LearningObservation {
  const LearningObservation({
    required this.game,
    required this.animalId,
    required this.choices,
    required this.action,
    this.firstAttempt = false,
  });
  final GameKind game;
  final String animalId;
  final int choices;
  final LearningAction action;
  final bool firstAttempt;
}

class LearningStats {
  const LearningStats({
    this.started = 0,
    this.answered = 0,
    this.errors = 0,
    this.roundsWithErrors = 0,
    this.correct = 0,
    this.firstTry = 0,
    this.hints = 0,
    this.skipped = 0,
  });
  final int started, answered, errors, roundsWithErrors;
  final int correct, firstTry, hints, skipped;
  double get errorRate => answered == 0 ? 0 : roundsWithErrors / answered;

  LearningStats add(LearningStats other) => LearningStats(
    started: started + other.started,
    answered: answered + other.answered,
    errors: errors + other.errors,
    roundsWithErrors: roundsWithErrors + other.roundsWithErrors,
    correct: correct + other.correct,
    firstTry: firstTry + other.firstTry,
    hints: hints + other.hints,
    skipped: skipped + other.skipped,
  );

  LearningStats observe(LearningObservation observation) => add(
    LearningStats(
      started: observation.action == LearningAction.started ? 1 : 0,
      answered: observation.firstAttempt ? 1 : 0,
      errors: observation.action == LearningAction.incorrect ? 1 : 0,
      roundsWithErrors:
          observation.action == LearningAction.incorrect &&
              observation.firstAttempt
          ? 1
          : 0,
      correct: observation.action == LearningAction.correct ? 1 : 0,
      firstTry:
          observation.action == LearningAction.correct &&
              observation.firstAttempt
          ? 1
          : 0,
      hints: observation.action == LearningAction.hint ? 1 : 0,
      skipped: observation.action == LearningAction.skipped ? 1 : 0,
    ),
  );

  List<int> get _values => [
    started,
    answered,
    errors,
    roundsWithErrors,
    correct,
    firstTry,
    hints,
    skipped,
  ];
  factory LearningStats._decode(Object? raw) {
    if (raw is! List<Object?> ||
        raw.length != 8 ||
        raw.any((v) => v is! int || v < 0)) {
      throw const FormatException('Invalid learning counters');
    }
    final v = raw.cast<int>();
    if (v[1] > v[0] ||
        v[3] > v[1] ||
        v[4] > v[1] ||
        v[5] > v[4] ||
        v[3] > v[2] ||
        v[6] > v[0] ||
        v[7] + v[4] > v[0]) {
      throw const FormatException('Inconsistent learning counters');
    }
    return LearningStats(
      started: v[0],
      answered: v[1],
      errors: v[2],
      roundsWithErrors: v[3],
      correct: v[4],
      firstTry: v[5],
      hints: v[6],
      skipped: v[7],
    );
  }
}

typedef _Bucket = ({int profile, GameKind game, String animal, int choices});

bool _validChoices(GameKind game, int choices) =>
    game == GameKind.drawing ? choices == 0 : [2, 3].contains(choices);

/// Bounded aggregate counters, without names, timestamps or an event log.
class LearningHistory {
  LearningHistory._(Map<_Bucket, LearningStats> buckets)
    : _buckets = Map.unmodifiable(buckets);
  factory LearningHistory.empty() => LearningHistory._({});
  final Map<_Bucket, LearningStats> _buckets;
  Set<int> get profileIds =>
      Set.unmodifiable(_buckets.keys.map((key) => key.profile));

  LearningHistory record(int profile, LearningObservation observation) {
    if (profile < 0 ||
        !animals.any((animal) => animal.id == observation.animalId) ||
        !_validChoices(observation.game, observation.choices)) {
      throw ArgumentError('Invalid learning observation');
    }
    final key = (
      profile: profile,
      game: observation.game,
      animal: observation.animalId,
      choices: observation.choices,
    );
    return LearningHistory._({
      ..._buckets,
      key: (_buckets[key] ?? const LearningStats()).observe(observation),
    });
  }

  LearningHistory clear(int profile) => LearningHistory._({
    for (final entry in _buckets.entries)
      if (entry.key.profile != profile) entry.key: entry.value,
  });

  LearningStats summarize(
    int profile, {
    GameKind? game,
    String? animalId,
    int? choices,
  }) {
    var result = const LearningStats();
    for (final entry in _buckets.entries) {
      final key = entry.key;
      if (key.profile == profile &&
          (game == null || key.game == game) &&
          (animalId == null || key.animal == animalId) &&
          (choices == null || key.choices == choices)) {
        result = result.add(entry.value);
      }
    }
    return result;
  }

  String encode() => jsonEncode({
    'version': 1,
    'buckets': [
      for (final entry in _buckets.entries)
        [
          entry.key.profile,
          entry.key.game.name,
          entry.key.animal,
          entry.key.choices,
          entry.value._values,
        ],
    ],
  });

  List<({Animal animal, LearningStats stats})> rankAnimals(
    int profile, {
    GameKind? game,
    int? choices,
  }) {
    final ranking =
        [
          for (final animal in animals)
            (
              animal: animal,
              stats: summarize(
                profile,
                game: game,
                animalId: animal.id,
                choices: choices,
              ),
            ),
        ].where((entry) => entry.stats.roundsWithErrors > 0).toList()..sort((
          a,
          b,
        ) {
          final rate = b.stats.errorRate.compareTo(a.stats.errorRate);
          if (rate != 0) return rate;
          final rounds = b.stats.roundsWithErrors.compareTo(
            a.stats.roundsWithErrors,
          );
          return rounds != 0 ? rounds : a.animal.name.compareTo(b.animal.name);
        });
    return List.unmodifiable(ranking);
  }

  factory LearningHistory.decode(String source) {
    final Object? raw = jsonDecode(source);
    if (raw is! Map<String, Object?> ||
        raw['version'] != 1 ||
        raw['buckets'] is! List<Object?>) {
      throw const FormatException('Invalid learning history');
    }
    final rows = raw['buckets'] as List<Object?>;
    final buckets = <_Bucket, LearningStats>{};
    for (final Object? row in rows) {
      if (row is! List<Object?> ||
          row.length != 5 ||
          row[0] is! int ||
          (row[0] as int) < 0 ||
          !GameKind.values.any((g) => g.name == row[1]) ||
          !animals.any((a) => a.id == row[2]) ||
          row[3] is! int ||
          !_validChoices(
            GameKind.values.byName(row[1] as String),
            row[3] as int,
          )) {
        throw const FormatException('Invalid learning bucket');
      }
      final key = (
        profile: row[0] as int,
        game: GameKind.values.byName(row[1] as String),
        animal: row[2] as String,
        choices: row[3] as int,
      );
      if (buckets.containsKey(key)) {
        throw const FormatException('Duplicate learning bucket');
      }
      buckets[key] = LearningStats._decode(row[4]);
    }
    return LearningHistory._(buckets);
  }
}
