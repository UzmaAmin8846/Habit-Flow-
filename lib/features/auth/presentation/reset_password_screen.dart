import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/snack.dart';
import 'auth_providers.dart';
import 'widgets/auth_shell.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).resetPassword(_email.text);
    if (!mounted) return;
    if (ok) {
      showSnack(context, 'Reset link sent. Check your inbox.');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
      if (next.hasError) showSnack(context, errorMessage(next.error), error: true);
    });
    final loading = ref.watch(authControllerProvider).isLoading;

    return AuthShell(
      title: 'Reset password',
      subtitle: "We'll email you a link to set a new password.",
      child: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                      height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Send reset link'),
            ),
            TextButton(onPressed: () => context.go('/login'), child: const Text('Back to log in')),
          ],
        ),
      ),
    );
  }
}
