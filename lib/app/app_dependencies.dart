import '../core/analytics/usage_analytics.dart';
import '../core/services/animal_audio.dart';
import '../core/services/animal_speech.dart';
import '../core/services/asset_animal_audio.dart';
import '../core/services/device_animal_speech.dart';
import '../features/account/data/firebase_account_repository.dart';
import '../features/account/domain/account_repository.dart';
import '../features/games/domain/game_definition.dart';
import '../features/games/domain/game_session.dart';
import '../features/games/presentation/game_view_model.dart';
import '../features/settings/presentation/app_settings.dart';

/// Composition root: platform adapters are selected outside feature widgets.
class AppDependencies {
  const AppDependencies({
    required this.accountRepository,
    required this.createAudio,
    required this.createSpeech,
  });

  factory AppDependencies.platform() => AppDependencies(
    accountRepository: FirebaseAccountRepository(),
    createAudio: AssetAnimalAudio.new,
    createSpeech: DeviceAnimalSpeech.new,
  );

  final AccountRepository accountRepository;
  final AnimalAudio Function() createAudio;
  final AnimalSpeech Function() createSpeech;

  GameViewModel createGame(
    GameDefinition game,
    AppSettings settings,
    UsageAnalytics analytics,
  ) => GameViewModel(
    session: GameSession(
      kind: game.kind,
      choiceCount: settings.choiceCount,
      rounds: settings.rounds,
    ),
    audio: createAudio(),
    speech: createSpeech(),
    soundEnabled: () => settings.soundEnabled,
    analytics: analytics,
    onObservation: settings.recorderForActiveProfile(),
  );
}
