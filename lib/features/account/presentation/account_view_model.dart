import 'package:flutter/foundation.dart';

import '../../../core/analytics/usage_analytics.dart';
import '../domain/account_repository.dart';
import 'account_message.dart';

class AccountViewModel extends ChangeNotifier {
  AccountViewModel(
    this._repository, {
    this.analytics = const NoopUsageAnalytics(),
  });
  final AccountRepository _repository;
  final UsageAnalytics analytics;
  bool _busy = false;
  bool _disposed = false;
  bool get busy => _busy;
  String? get name => _name;
  AccountMessage? get error => _error;
  String? _name;
  AccountMessage? _error;
  Future<void> load() async {
    if (_disposed || _busy) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final currentName = await _repository.currentName();
      if (_disposed) return;
      _name = currentName;
      if (_name != null) {
        analytics.screen(UsageScreen.accountOverview);
      }
    } on UnsupportedError {
      if (_disposed) return;
      _error = AccountMessage.notConfigured;
    } on Exception {
      if (_disposed) return;
      _error = AccountMessage.unavailable;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> submit({
    required String email,
    required String password,
    String? registrationName,
  }) async {
    if (_disposed || _busy) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      final authenticatedName = registrationName == null
          ? await _repository.signIn(email, password)
          : await _repository.register(registrationName, email, password);
      if (_disposed) return;
      _name = authenticatedName;
      analytics.event(
        registrationName == null ? UsageEvent.login : UsageEvent.signUp,
        parameters: {UsageParameter.method: 'password'},
      );
      analytics.screen(UsageScreen.accountOverview);
    } on AccountFailure catch (exception) {
      if (_disposed) return;
      analytics.event(
        UsageEvent.accountFailure,
        parameters: {
          UsageParameter.operation: registrationName == null
              ? 'sign_in'
              : 'register',
          UsageParameter.reason: exception.kind.name,
        },
      );
      _error = switch (exception.kind) {
        AccountFailureKind.emailInUse => AccountMessage.emailInUse,
        AccountFailureKind.invalidEmail => AccountMessage.invalidEmail,
        AccountFailureKind.weakPassword => AccountMessage.weakPassword,
        AccountFailureKind.connection => AccountMessage.connection,
        AccountFailureKind.rateLimited => AccountMessage.rateLimited,
        AccountFailureKind.invalidCredentials =>
          AccountMessage.invalidCredentials,
      };
    } on UnsupportedError {
      if (_disposed) return;
      _error = AccountMessage.notConfigured;
    } on Exception {
      if (_disposed) return;
      _error = AccountMessage.unavailable;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_disposed || _busy) return;
    _busy = true;
    notifyListeners();
    try {
      await _repository.signOut();
      if (_disposed) return;
      analytics.event(UsageEvent.logout);
      analytics.screen(UsageScreen.accountLogin);
      _name = null;
      _error = null;
    } on Exception {
      if (_disposed) return;
      _error = AccountMessage.signOutFailed;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _busy = false;
    super.dispose();
  }
}
