import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/password_field.dart';
import '../../../shared/widgets/snack.dart';
import 'auth_providers.dart';
import 'widgets/auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(_email.text, _password.text);
    // On success the router redirects to Home automatically.
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next.hasError) showSnack(context, errorMessage(next.error), error: true);
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return AuthShell(
      title: 'Welcome back',
      subtitle: 'Log in to keep your streaks alive.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 14),
            PasswordField(
                controller: _password, validator: Validators.password, onSubmitted: _submit),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => context.push('/reset'), child: const Text('Forgot password?')),
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                      height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Log in'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(onPressed: () => context.go('/signup'), child: const Text('Sign up')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
