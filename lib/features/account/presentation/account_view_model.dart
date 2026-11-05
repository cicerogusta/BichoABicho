import 'package:flutter/foundation.dart';
import '../domain/account_repository.dart';
import '../../../core/analytics/usage_analytics.dart';

class AccountViewModel extends ChangeNotifier {
  AccountViewModel(
    this._repository, {
    this.analytics = const NoopUsageAnalytics(),
  });
  final AccountRepository _repository;
  final UsageAnalytics analytics;
  bool busy = false;
  bool _disposed = false;
  String? name;
  String? error;
  Future<void> load() async {
    busy = true;
    notifyListeners();
    try {
      name = await _repository.currentName();
      if (!_disposed && name != null) {
        analytics.screen(UsageScreen.accountOverview);
      }
    } on UnsupportedError {
      error =
          'Contas ainda não foram configuradas nesta plataforma. As brincadeiras continuam disponíveis.';
    } on Exception {
      error =
          'O serviço de contas está indisponível. Você pode continuar brincando sem conta.';
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> submit({
    required String email,
    required String password,
    String? registrationName,
  }) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      name = registrationName == null
          ? await _repository.signIn(email, password)
          : await _repository.register(registrationName, email, password);
      if (!_disposed) {
        analytics.event(
          registrationName == null ? UsageEvent.login : UsageEvent.signUp,
          parameters: {UsageParameter.method: 'password'},
        );
        analytics.screen(UsageScreen.accountOverview);
      }
    } on AccountFailure catch (exception) {
      analytics.event(
        UsageEvent.accountFailure,
        parameters: {
          UsageParameter.operation: registrationName == null
              ? 'sign_in'
              : 'register',
          UsageParameter.reason: exception.kind.name,
        },
      );
      error = switch (exception.kind) {
        AccountFailureKind.emailInUse =>
          'Este e-mail já tem uma conta. Use a opção Entrar.',
        AccountFailureKind.invalidEmail => 'Confira o endereço de e-mail.',
        AccountFailureKind.weakPassword =>
          'Escolha uma senha mais forte, com pelo menos 8 caracteres.',
        AccountFailureKind.connection =>
          'Confira sua conexão e tente novamente.',
        AccountFailureKind.rateLimited =>
          'Aguarde um pouco antes de tentar novamente.',
        _ =>
          'Não foi possível acessar a conta. Confira os dados e tente novamente.',
      };
    } on UnsupportedError {
      error =
          'Contas ainda não foram configuradas nesta plataforma. As brincadeiras continuam disponíveis.';
    } on Exception {
      error =
          'O serviço de contas está indisponível. Você pode continuar brincando sem conta.';
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      await _repository.signOut();
      if (!_disposed) {
        analytics.event(UsageEvent.logout);
        analytics.screen(UsageScreen.accountLogin);
      }
      name = null;
      error = null;
    } on Exception {
      error = 'Não foi possível sair da conta. Tente novamente.';
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
