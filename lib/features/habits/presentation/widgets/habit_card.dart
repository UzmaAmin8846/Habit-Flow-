import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/habit.dart';
import '../habit_providers.dart';

class HabitCard extends ConsumerWidget {
  const HabitCard({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(habit.colorValue);
    final scheme = Theme.of(context).colorScheme;
    final streak = habit.currentStreak();
    final week = habit.lastDays(7);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/habit/${habit.id}'),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 8, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(habit.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 18,
                              color: streak > 0 ? Colors.orange : scheme.outline),
                          const SizedBox(width: 4),
                          Text('$streak day${streak == 1 ? '' : 's'}',
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                          const Spacer(),
                          for (final done in week)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done ? color : scheme.outlineVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CheckButton(
                  done: habit.doneToday,
                  color: color,
                  onTap: () => ref.read(habitActionsProvider.notifier).toggleToday(habit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.done, required this.color, required this.onTap});
  final bool done;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? color : Colors.transparent,
          border: Border.all(color: color, width: 2.5),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: done
              ? const Icon(Icons.check_rounded, key: ValueKey('done'), color: Colors.white)
              : const SizedBox.shrink(key: ValueKey('todo')),
        ),
      ),
    );
  }
}
