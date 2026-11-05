import 'package:bicho_a_bicho/features/account/domain/account_repository.dart';
import 'package:bicho_a_bicho/features/account/presentation/account_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bicho_a_bicho/core/analytics/usage_analytics.dart';
import 'support/fake_analytics.dart';

class FakeAccountRepository implements AccountRepository {
  String? name;
  AccountFailure? failure;
  int signIns = 0;
  @override
  Future<String?> currentName() async => name;
  @override
  Future<String> register(String name, String email, String password) async {
    if (failure != null) throw failure!;
    return this.name = name;
  }

  @override
  Future<String> signIn(String email, String password) async {
    signIns++;
    if (failure != null) throw failure!;
    return name = 'Responsável';
  }

  @override
  Future<void> signOut() async {
    name = null;
  }
}

void main() {
  test('account analytics never includes identity or credentials', () async {
    final repository = FakeAccountRepository();
    final analytics = RecordingAnalytics();
    final model = AccountViewModel(repository, analytics: analytics);
    await model.submit(
      email: 'private@example.test',
      password: 'private-secret',
      registrationName: 'Private Person',
    );
    expect(analytics.events.single.$1, UsageEvent.signUp);
    expect(analytics.events.single.$2, {UsageParameter.method: 'password'});
    expect(analytics.events.toString(), isNot(contains('private')));
    expect(analytics.screens.last, UsageScreen.accountOverview);
    model.dispose();
  });
  test('account errors only send a categorical reason', () async {
    final repository = FakeAccountRepository()
      ..failure = const AccountFailure(AccountFailureKind.connection);
    final analytics = RecordingAnalytics();
    final model = AccountViewModel(repository, analytics: analytics);
    await model.submit(
      email: 'private@example.test',
      password: 'private-secret',
    );
    expect(analytics.events.single.$1, UsageEvent.accountFailure);
    expect(analytics.events.single.$2, {
      UsageParameter.operation: 'sign_in',
      UsageParameter.reason: 'connection',
    });
    model.dispose();
  });
  test(
    'restores account session, signs out and registers without exposing a password',
    () async {
      final repository = FakeAccountRepository()..name = 'Ana';
      final model = AccountViewModel(repository);
      await model.load();
      expect(model.name, 'Ana');
      await model.signOut();
      expect(model.name, isNull);
      await model.submit(
        email: 'adult@example.test',
        password: 'example-only',
        registrationName: 'João',
      );
      expect(model.name, 'João');
      expect(model.busy, isFalse);
      model.dispose();
    },
  );
  test('maps connection errors and recovers on retry', () async {
    final repository = FakeAccountRepository()
      ..failure = const AccountFailure(AccountFailureKind.connection);
    final model = AccountViewModel(repository);
    await model.submit(email: 'adult@example.test', password: 'example-only');
    expect(model.error, contains('conexão'));
    expect(model.busy, isFalse);
    repository.failure = null;
    await model.submit(email: 'adult@example.test', password: 'example-only');
    expect(model.error, isNull);
    expect(model.name, isNotNull);
    model.dispose();
  });
  test(
    'rapid submissions cannot create duplicate authentication requests',
    () async {
      final repository = FakeAccountRepository();
      final model = AccountViewModel(repository);
      await Future.wait([
        model.submit(email: 'adult@example.test', password: 'example-only'),
        model.submit(email: 'adult@example.test', password: 'example-only'),
      ]);
      expect(repository.signIns, 1);
      model.dispose();
    },
  );
}
