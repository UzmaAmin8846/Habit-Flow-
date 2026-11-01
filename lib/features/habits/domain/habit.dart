import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_helpers.dart';

class Habit {
  const Habit({
    required this.id,
    required this.title,
    this.description = '',
    this.colorValue = 0xFF6C5CE7,
    required this.createdAt,
    this.completedDates = const [],
  });

  final String id;
  final String title;
  final String description;
  final int colorValue;
  final DateTime createdAt;

  /// Days the habit was completed, stored as "yyyy-MM-dd".
  final List<String> completedDates;

  bool isDoneOn(DateTime day) => completedDates.contains(dateKey(day));

  bool get doneToday => isDoneOn(DateTime.now());

  /// Consecutive days up to today (or yesterday, if today is not done yet).
  int currentStreak([DateTime? now]) {
    final set = completedDates.toSet();
    var day = dayOnly(now ?? DateTime.now());
    if (!set.contains(dateKey(day))) day = daysAgo(day, 1);
    var count = 0;
    while (set.contains(dateKey(day))) {
      count++;
      day = daysAgo(day, 1);
    }
    return count;
  }

  int get bestStreak {
    final days = completedDates.map((s) {
      final p = s.split('-');
      return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    }).toSet().toList()
      ..sort();

    var best = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = (prev != null && d.difference(prev).inDays == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  /// Oldest -> newest list of whether each of the last [n] days was done.
  List<bool> lastDays(int n, [DateTime? now]) {
    final today = dayOnly(now ?? DateTime.now());
    return [for (var i = n - 1; i >= 0; i--) isDoneOn(daysAgo(today, i))];
  }

  /// 0.0 - 1.0 : how many of the last 7 days were completed.
  double weekProgress([DateTime? now]) =>
      lastDays(7, now).where((d) => d).length / 7;

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'colorValue': colorValue,
        'createdAt': Timestamp.fromDate(createdAt),
        'completedDates': completedDates,
      };

  factory Habit.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Habit(
      id: doc.id,
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      colorValue: (d['colorValue'] as num?)?.toInt() ?? 0xFF6C5CE7,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedDates: List<String>.from(d['completedDates'] ?? const []),
    );
  }
}
