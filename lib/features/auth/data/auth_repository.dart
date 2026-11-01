import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/app_exception.dart';
import 'auth_data_source.dart';

/// Converts Firebase errors into friendly messages.
class AuthRepository {
  AuthRepository(this._ds);
  final AuthDataSource _ds;

  Stream<User?> get userChanges => _ds.userChanges();

  Future<void> signIn(String email, String password) =>
      _wrap(() => _ds.signIn(email.trim(), password));

  Future<void> signUp(String name, String email, String password) =>
      _wrap(() => _ds.signUp(name.trim(), email.trim(), password));

  Future<void> resetPassword(String email) => _wrap(() => _ds.resetPassword(email.trim()));

  Future<void> signOut() => _wrap(_ds.signOut);

  Future<void> _wrap(Future<void> Function() job) async {
    try {
      await job();
    } on FirebaseAuthException catch (e) {
      throw AppException(_message(e));
    }
  }

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
