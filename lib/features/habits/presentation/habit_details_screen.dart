import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/snack.dart';
import '../domain/habit.dart';
import 'habit_providers.dart';

class HabitDetailsScreen extends ConsumerWidget {
  const HabitDetailsScreen({super.key, required this.habitId});
  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref
        .watch(habitsProvider)
        .whenData((list) => list.where((h) => h.id == habitId).firstOrNull);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (habit.value != null) ...[
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/habit/$habitId/edit'),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ],
      ),
      body: AsyncValueView<Habit?>(
        value: habit,
        onRetry: () => ref.invalidate(habitsProvider),
        isEmpty: (h) => h == null,
        empty: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Habit not found',
          message: 'It may have been deleted.',
        ),
        data: (h) => _Body(habit: h!),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: const Text('This will remove the habit and all of its history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    final ok = await ref.read(habitActionsProvider.notifier).delete(habitId);
    if (!context.mounted) return;
    if (ok) {
      context.pop();
    } else {
      showSnack(context, errorMessage(ref.read(habitActionsProvider).error), error: true);
    }
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(habit.colorValue);
    final scheme = Theme.of(context).colorScheme;
    final days = habit.lastDays(14);
    final today = dayOnly(DateTime.now());

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(habit.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            if (habit.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(habit.description, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
            const SizedBox(height: 28),
            Center(
              child: SizedBox(
                width: 170,
                height: 170,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: habit.weekProgress()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: value,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(value * 100).round()}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            Text('this week', style: TextStyle(color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                    child: _Stat(
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orange,
                        value: '${habit.currentStreak()}',
                        label: 'Current streak')),
                const SizedBox(width: 12),
                Expanded(
                    child: _Stat(
                        icon: Icons.emoji_events_rounded,
                        color: Colors.amber,
                        value: '${habit.bestStreak}',
                        label: 'Best streak')),
                const SizedBox(width: 12),
                Expanded(
                    child: _Stat(
                        icon: Icons.check_circle_rounded,
                        color: color,
                        value: '${habit.completedDates.length}',
                        label: 'Total days')),
              ],
            ),
            const SizedBox(height: 28),
            Text('Last 14 days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < days.length; i++)
                  _DayChip(
                    letter: weekdayLetter(daysAgo(today, days.length - 1 - i)),
                    done: days[i],
                    color: color,
                  ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: color),
              onPressed: () => ref.read(habitActionsProvider.notifier).toggleToday(habit),
              icon: Icon(habit.doneToday ? Icons.undo_rounded : Icons.check_rounded),
              label: Text(habit.doneToday ? 'Undo today' : 'Mark done today'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.value, required this.label});
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.letter, required this.done, required this.color});
  final String letter;
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? color : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(letter,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: done ? Colors.white : scheme.onSurfaceVariant)),
    );
  }
}
