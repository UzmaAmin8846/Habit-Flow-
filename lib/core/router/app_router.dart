import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/habits/presentation/habit_details_screen.dart';
import '../../features/habits/presentation/habit_form_screen.dart';
import '../../features/habits/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../services/providers.dart';

/// Makes GoRouter re-run `redirect` whenever the auth state changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

const _authRoutes = {'/login', '/signup', '/reset'};

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = _AuthRefresh(auth.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUser != null;
      final onAuthPage = _authRoutes.contains(state.matchedLocation);
      if (!loggedIn) return onAuthPage ? null : '/login';
      if (onAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/reset', builder: (_, __) => const ResetPasswordScreen()),

      // Bottom navigation: Home + Profile
      ShellRoute(
        builder: (context, state, child) => _AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Full-screen pages with a slide + fade transition.
      // NOTE: '/habit/new' must be declared before '/habit/:id'.
      GoRoute(
        path: '/habit/new',
        pageBuilder: (_, state) => _slideFade(state, const HabitFormScreen()),
      ),
      GoRoute(
        path: '/habit/:id',
        pageBuilder: (_, state) =>
            _slideFade(state, HabitDetailsScreen(habitId: state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (_, state) =>
                _slideFade(state, HabitFormScreen(habitId: state.pathParameters['id'])),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _slideFade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final index = location.startsWith('/profile') ? 1 : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(i == 0 ? '/' : '/profile'),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Habits'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
