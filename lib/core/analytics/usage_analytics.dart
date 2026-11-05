enum UsageScreen {
  opening,
  playHome,
  animals,
  parents,
  profileSelection,
  profileName,
  reportProfileSelection,
  accountLogin,
  accountRegister,
  accountOverview,
  gameMatching,
  gameLetters,
  gameCounting,
  gameSpeaking,
  gameClues,
  gameStories,
  gameDrawing,
  gameMemory,
}

UsageScreen gameScreenFor(String gameId) => switch (gameId) {
  'matching' => UsageScreen.gameMatching,
  'letters' => UsageScreen.gameLetters,
  'counting' => UsageScreen.gameCounting,
  'speaking' => UsageScreen.gameSpeaking,
  'clues' => UsageScreen.gameClues,
  'stories' => UsageScreen.gameStories,
  'drawing' => UsageScreen.gameDrawing,
  'memory' => UsageScreen.gameMemory,
  _ => throw ArgumentError.value(gameId, 'gameId'),
};

enum UsageEvent {
  openingFinished('opening_finished'),
  navigationSelected('navigation_selected'),
  gameStarted('game_start'),
  roundStarted('round_start'),
  answerSubmitted('answer_submitted'),
  hintUsed('hint_used'),
  roundSkipped('round_skipped'),
  gamePaused('game_paused'),
  gameResumed('game_resumed'),
  gameCompleted('game_complete'),
  gameAbandoned('game_abandoned'),
  animalCounted('animal_counted'),
  animalSoundRequested('animal_sound_requested'),
  speechStarted('speech_started'),
  speechFinished('speech_finished'),
  mediaUnavailable('media_unavailable'),
  settingsChanged('settings_changed'),
  progressReset('progress_reset'),
  login('login'),
  signUp('sign_up'),
  logout('logout'),
  accountFailure('account_failure'),
  consentGranted('analytics_consent_granted');

  const UsageEvent(this.wireName);
  final String wireName;
}

/// No free-text keys or personal identifiers are accepted by the tracking API.
enum UsageParameter {
  gameId('game_id'),
  animalId('animal_id'),
  roundIndex('round_index'),
  roundCount('round_count'),
  choiceCount('choice_count'),
  result('result'),
  inputMethod('input_method'),
  attempts('attempts'),
  correctRounds('correct_rounds'),
  skippedRounds('skipped_rounds'),
  durationMs('duration_ms'),
  reason('reason'),
  feature('feature'),
  operation('operation'),
  setting('setting'),
  value('value'),
  destination('destination'),
  method('method'),
  counted('counted');

  const UsageParameter(this.wireName);
  final String wireName;
}

abstract interface class UsageAnalytics {
  void event(
    UsageEvent event, {
    Map<UsageParameter, Object> parameters = const {},
  });
  void screen(UsageScreen screen);
  void rootScreen(UsageScreen screen);
  void routeScreen(UsageScreen? screen);
  void preferences({
    required bool sound,
    required bool reducedMotion,
    required int choices,
    required int rounds,
  });
}

class NoopUsageAnalytics implements UsageAnalytics {
  const NoopUsageAnalytics();
  @override
  void event(
    UsageEvent event, {
    Map<UsageParameter, Object> parameters = const {},
  }) {}
  @override
  void screen(UsageScreen screen) {}
  @override
  void rootScreen(UsageScreen screen) {}
  @override
  void routeScreen(UsageScreen? screen) {}
  @override
  void preferences({
    required bool sound,
    required bool reducedMotion,
    required int choices,
    required int rounds,
  }) {}
}

Map<String, Object>? validatedParameters(Map<UsageParameter, Object> values) {
  final result = <String, Object>{};
  for (final entry in values.entries) {
    final allowed = switch (entry.key) {
      UsageParameter.gameId => const {
        'matching',
        'letters',
        'counting',
        'speaking',
        'clues',
        'stories',
        'drawing',
        'memory',
      }.contains(entry.value),
      UsageParameter.animalId => const {
        'dog',
        'cat',
        'lion',
        'elephant',
        'cow',
        'horse',
        'sheep',
        'duck',
      }.contains(entry.value),
      UsageParameter.result => const {
        'correct',
        'retry',
        'recognized',
        'no_match',
        'unavailable',
        'cancelled',
      }.contains(entry.value),
      UsageParameter.inputMethod => const {
        'touch',
        'voice',
        'drawing',
      }.contains(entry.value),
      UsageParameter.reason => const {
        'completed',
        'skipped',
        'user',
        'background',
        'unavailable',
        'unsupported',
        'connection',
        'invalidCredentials',
        'emailInUse',
        'invalidEmail',
        'weakPassword',
        'rateLimited',
        'service',
      }.contains(entry.value),
      UsageParameter.feature => const {
        'animal_audio',
        'celebration_audio',
        'speech',
      }.contains(entry.value),
      UsageParameter.operation => const {
        'sign_in',
        'register',
        'sign_out',
      }.contains(entry.value),
      UsageParameter.setting => const {
        'sound_enabled',
        'reduced_motion',
        'choice_count',
        'round_count',
      }.contains(entry.value),
      UsageParameter.value => const {
        'true',
        'false',
        '2',
        '3',
        '4',
        '6',
      }.contains(entry.value),
      UsageParameter.destination => UsageScreen.values.any(
        (screen) => screen.name == entry.value,
      ),
      UsageParameter.method => entry.value == 'password',
      UsageParameter.durationMs =>
        entry.value is int &&
            (entry.value as int) >= 0 &&
            (entry.value as int) <= 86400000,
      _ =>
        entry.value is int &&
            (entry.value as int) >= 0 &&
            (entry.value as int) <= 1000000,
    };
    if (!allowed) return null;
    result[entry.key.wireName] = entry.value;
  }
  return Map.unmodifiable(result);
}
