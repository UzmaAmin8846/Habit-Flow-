import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/habit.dart';

/// Firestore CRUD. Path: users/{uid}/habits/{habitId}
/// Firestore caches data on the device, so the app also works offline.
class HabitDataSource {
  HabitDataSource(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('habits');

  Stream<List<Habit>> watchHabits(String uid) => _col(uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Habit.fromDoc).toList());

  Future<void> add(String uid, Habit habit) => _col(uid).add(habit.toMap());

  Future<void> updateDetails(
    String uid,
    String id, {
    required String title,
    required String description,
    required int colorValue,
  }) =>
      _col(uid).doc(id).update({
        'title': title,
        'description': description,
        'colorValue': colorValue,
      });

  Future<void> setCompleted(String uid, String id, String day, bool done) =>
      _col(uid).doc(id).update({
        'completedDates':
            done ? FieldValue.arrayUnion([day]) : FieldValue.arrayRemove([day]),
      });

  Future<void> delete(String uid, String id) => _col(uid).doc(id).delete();
}
