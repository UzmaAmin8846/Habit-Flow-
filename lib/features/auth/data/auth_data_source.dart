import 'package:firebase_auth/firebase_auth.dart';

/// Talks directly to Firebase Auth. No business logic here.
class AuthDataSource {
  AuthDataSource(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> userChanges() => _auth.userChanges();

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signUp(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(name);
  }

  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();
}
