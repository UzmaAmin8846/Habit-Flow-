import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/habit_data_source.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';

final habitDataSourceProvider =
    Provider((ref) => HabitDataSource(ref.watch(firestoreProvider)));

/// Rebuilt whenever the signed-in user changes -> data is always user-specific.
final habitRepositoryProvider = Provider((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  return HabitRepository(ref.watch(habitDataSourceProvider), uid);
});

/// Live list of habits (real-time Firestore stream).
final habitsProvider = StreamProvider.autoDispose<List<Habit>>(
  (ref) => ref.watch(habitRepositoryProvider).watchHabits(),
);

/// Notifier for write actions: add / update / delete / toggle.
class HabitActions extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  Future<bool> _run(Future<void> Function() job) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(job);
    return !state.hasError;
  }

  Future<bool> add(String title, String description, int color) =>
      _run(() => _repo.addHabit(title: title, description: description, colorValue: color));

  Future<bool> updateHabit(String id, String title, String description, int color) => _run(
      () => _repo.updateHabit(id, title: title, description: description, colorValue: color));

  Future<bool> delete(String id) => _run(() => _repo.deleteHabit(id));

  /// Toggle today's check-in. No loading flicker -> the UI updates instantly
  /// because Firestore applies the write to its local cache first.
  Future<void> toggleToday(Habit habit) async {
    state = await AsyncValue.guard(() => _repo.toggleToday(habit));
  }
}

final habitActionsProvider =
    AsyncNotifierProvider<HabitActions, void>(HabitActions.new);
