import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_notifier.dart';
import '../../../core/utils/app_exception.dart';
import '../../../shared/widgets/snack.dart';
import '../../auth/presentation/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final themeMode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final name = (user?.displayName?.trim().isNotEmpty ?? false) ? user!.displayName! : 'HabitFlow user';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(name.characters.first.toUpperCase(),
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimaryContainer)),
                ),
              ),
              const SizedBox(height: 12),
              Text(name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(user?.email ?? '',
                  textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 28),
              Text('Appearance', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Light')),
                  ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
                  ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Dark')),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setMode(s.first),
              ),
              const SizedBox(height: 28),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Send password reset email'),
                  onTap: user?.email == null
                      ? null
                      : () async {
                          final ok = await ref
                              .read(authControllerProvider.notifier)
                              .resetPassword(user!.email!);
                          if (!context.mounted) return;
                          showSnack(
                            context,
                            ok
                                ? 'Reset link sent to ${user.email}'
                                : errorMessage(ref.read(authControllerProvider).error),
                            error: !ok,
                          );
                        },
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
