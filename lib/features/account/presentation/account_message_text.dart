import 'package:bicho_a_bicho/l10n/localization.dart';
import 'package:flutter/widgets.dart';

import 'account_message.dart';

extension AccountMessageText on AccountMessage {
  String resolve(BuildContext context) => switch (this) {
    AccountMessage.notConfigured => context.l10n.accountNotConfigured,
    AccountMessage.unavailable => context.l10n.accountUnavailable,
    AccountMessage.emailInUse => context.l10n.accountEmailInUse,
    AccountMessage.invalidEmail => context.l10n.accountInvalidEmail,
    AccountMessage.weakPassword => context.l10n.accountWeakPassword,
    AccountMessage.connection => context.l10n.accountConnection,
    AccountMessage.rateLimited => context.l10n.accountRateLimited,
    AccountMessage.invalidCredentials => context.l10n.accountInvalidCredentials,
    AccountMessage.signOutFailed => context.l10n.accountSignOutFailed,
  };
}
