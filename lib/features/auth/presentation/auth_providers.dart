import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/providers.dart';
import '../data/auth_data_source.dart';
import '../data/auth_repository.dart';

final authDataSourceProvider =
    Provider((ref) => AuthDataSource(ref.watch(firebaseAuthProvider)));

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(authDataSourceProvider)));

/// The signed-in user (or null).
final authStateProvider =
    StreamProvider<User?>((ref) => ref.watch(authRepositoryProvider).userChanges);

/// Notifier used by the Login / Sign Up / Reset / Logout actions.
/// AsyncValue gives us loading + error states for free.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> _run(Future<void> Function() job) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(job);
    return !state.hasError;
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signIn(String email, String password) => _run(() => _repo.signIn(email, password));

  Future<bool> signUp(String name, String email, String password) =>
      _run(() => _repo.signUp(name, email, password));

  Future<bool> resetPassword(String email) => _run(() => _repo.resetPassword(email));

  Future<bool> signOut() => _run(_repo.signOut);
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
