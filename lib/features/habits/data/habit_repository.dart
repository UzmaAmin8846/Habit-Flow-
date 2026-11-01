import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_helpers.dart';
import '../domain/habit.dart';
import 'habit_data_source.dart';

class HabitRepository {
  HabitRepository(this._ds, this._uid);
  final HabitDataSource _ds;
  final String? _uid;

  String get _requireUid {
    final uid = _uid;
    if (uid == null) throw const AppException('You are not signed in.');
    return uid;
  }

  Stream<List<Habit>> watchHabits() =>
      _uid == null ? Stream.value(const <Habit>[]) : _ds.watchHabits(_uid);

  Future<void> addHabit({
    required String title,
    required String description,
    required int colorValue,
  }) =>
      _guard(() => _ds.add(
            _requireUid,
            Habit(
              id: '',
              title: title.trim(),
              description: description.trim(),
              colorValue: colorValue,
              createdAt: DateTime.now(),
            ),
          ));

  Future<void> updateHabit(
    String id, {
    required String title,
    required String description,
    required int colorValue,
  }) =>
      _guard(() => _ds.updateDetails(
            _requireUid,
            id,
            title: title.trim(),
            description: description.trim(),
            colorValue: colorValue,
          ));

  Future<void> toggleToday(Habit habit) => _guard(
        () => _ds.setCompleted(_requireUid, habit.id, dateKey(DateTime.now()), !habit.doneToday),
      );

  Future<void> deleteHabit(String id) => _guard(() => _ds.delete(_requireUid, id));

  Future<void> _guard(Future<void> Function() job) async {
    try {
      await job();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Could not save your changes.');
    }
  }
}
