import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';
import '../domain/account_repository.dart';

class FirebaseAccountRepository implements AccountRepository {
  @override
  Future<String?> currentName() async {
    final user = (await _auth()).currentUser;
    return user == null ? null : user.displayName ?? '';
  }

  Future<FirebaseAuth> _auth() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return FirebaseAuth.instance;
  }

  @override
  Future<String> signIn(String email, String password) => _perform(() async {
    final auth = await _auth();
    final credential = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user?.displayName ?? '';
  });

  @override
  Future<String> register(String name, String email, String password) =>
      _perform(() async {
        final auth = await _auth();
        final credential = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await credential.user!.updateDisplayName(name.trim());
        return name.trim();
      });

  @override
  Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty) await FirebaseAuth.instance.signOut();
  }

  Future<T> _perform<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseAuthException catch (error) {
      throw AccountFailure(switch (error.code) {
        'email-already-in-use' => AccountFailureKind.emailInUse,
        'invalid-email' => AccountFailureKind.invalidEmail,
        'weak-password' => AccountFailureKind.weakPassword,
        'network-request-failed' => AccountFailureKind.connection,
        'too-many-requests' => AccountFailureKind.rateLimited,
        _ => AccountFailureKind.invalidCredentials,
      });
    }
  }
}
