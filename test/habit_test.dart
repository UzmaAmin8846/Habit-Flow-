import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/features/habits/domain/habit.dart';

void main() {
  final now = DateTime(2026, 11, 1);

  Habit make(List<String> dates) =>
      Habit(id: '1', title: 'Read', createdAt: now, completedDates: dates);

  group('Habit streaks', () {
    test('counts consecutive days ending today', () {
      final h = make(['2026-11-01', '2026-10-31', '2026-10-30', '2026-10-20']);
      expect(h.currentStreak(now), 3);
    });

    test('streak stays alive if only yesterday is done', () {
      final h = make(['2026-10-31', '2026-10-30']);
      expect(h.currentStreak(now), 2);
    });

    test('streak is 0 after a missed day', () {
      final h = make(['2026-10-28']);
      expect(h.currentStreak(now), 0);
    });

    test('best streak finds the longest run', () {
      final h = make(['2026-10-01', '2026-10-02', '2026-10-03', '2026-10-10', '2026-10-11']);
      expect(h.bestStreak, 3);
    });

    test('weekProgress is completed days / 7', () {
      final h = make(['2026-11-01', '2026-10-31', '2026-10-30', '2026-10-29']);
      expect(h.weekProgress(now), closeTo(4 / 7, 0.0001));
    });
  });
}
