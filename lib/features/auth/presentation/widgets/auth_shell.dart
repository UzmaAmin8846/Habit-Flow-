import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Gradient background + centered card used by all auth screens.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 64),
                    const SizedBox(height: 8),
                    const Text('HabitFlow',
                        style: TextStyle(
                            color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 24),
                    Card(
                      color: scheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 24),
                            child,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
