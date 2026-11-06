import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/widgets.dart';

import 'game_media_message.dart';

extension GameMediaMessageText on GameMediaMessage {
  String resolve(BuildContext context) => switch (this) {
    GameMediaMessage.celebrationUnavailable =>
      context.l10n.celebrationUnavailable,
    GameMediaMessage.speechRetry => context.l10n.speechRetry,
    GameMediaMessage.soundDisabled => context.l10n.soundDisabled,
    GameMediaMessage.soundUnavailable => context.l10n.soundUnavailable,
    GameMediaMessage.listening => context.l10n.speechListening,
    GameMediaMessage.speechUnavailable => context.l10n.speechUnavailable,
    GameMediaMessage.speechNoMatch => context.l10n.speechNoMatch,
    GameMediaMessage.speechFinished => context.l10n.speechFinished,
    GameMediaMessage.audioUnavailable => context.l10n.audioUnavailable,
  };
}
