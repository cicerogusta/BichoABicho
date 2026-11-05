enum AccountFailureKind {
  emailInUse,
  invalidEmail,
  weakPassword,
  connection,
  rateLimited,
  invalidCredentials,
}

class AccountFailure implements Exception {
  const AccountFailure(this.kind);
  final AccountFailureKind kind;
}

abstract interface class AccountRepository {
  Future<String?> currentName();
  Future<String> signIn(String email, String password);
  Future<String> register(String name, String email, String password);
  Future<void> signOut();
}
