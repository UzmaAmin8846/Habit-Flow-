import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/password_field.dart';
import '../../../shared/widgets/snack.dart';
import 'auth_providers.dart';
import 'widgets/auth_shell.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .signUp(_name.text, _email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next.hasError) showSnack(context, errorMessage(next.error), error: true);
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return AuthShell(
      title: 'Create account',
      subtitle: 'Start building habits that stick.',
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (v) => Validators.required(v, 'Name'),
              decoration: const InputDecoration(
                  labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 14),
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
              controller: _password,
              validator: Validators.password,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            PasswordField(
              controller: _confirm,
              label: 'Confirm password',
              validator: (v) => v != _password.text ? 'Passwords do not match' : null,
              onSubmitted: _submit,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                      height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Sign up'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(onPressed: () => context.go('/login'), child: const Text('Log in')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
