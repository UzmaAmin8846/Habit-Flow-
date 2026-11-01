import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../shared/widgets/async_value_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/snack.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/habit.dart';
import 'habit_providers.dart';
import 'widgets/habit_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(habitActionsProvider, (_, next) {
      if (next.hasError) showSnack(context, errorMessage(next.error), error: true);
    });

    final habits = ref.watch(habitsProvider);
    final user = ref.watch(authStateProvider).value;
    final list = habits.value ?? const <Habit>[];
    final done = list.where((h) => h.doneToday).length;
    final firstName = (user?.displayName ?? '').trim().split(' ').first;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habit/new'),
        icon: const Icon(Icons.add),
        label: const Text('New habit'),
      ),
      body: Column(
        children: [
          _Header(
            name: firstName.isEmpty ? 'there' : firstName,
            done: done,
            total: list.length,
          ),
          Expanded(
            child: AsyncValueView<List<Habit>>(
              value: habits,
              onRetry: () => ref.invalidate(habitsProvider),
              isEmpty: (l) => l.isEmpty,
              empty: EmptyState(
                icon: Icons.self_improvement_rounded,
                title: 'No habits yet',
                message: 'Small steps every day add up.\nCreate your first habit to begin.',
                actionLabel: 'Add a habit',
                onAction: () => context.push('/habit/new'),
              ),
              data: (items) => GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                // 1 column on phones, 2+ on tablets / wide screens.
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 560,
                  mainAxisExtent: 96,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => HabitCard(habit: items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.done, required this.total});
  final String name;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prettyDate(DateTime.now()),
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text('${greeting()}, $name 👋',
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Text(
            total == 0
                ? 'Add a habit to get started'
                : done == total
                    ? 'All done today. Great job! 🎉'
                    : '$done of $total habits done today',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
