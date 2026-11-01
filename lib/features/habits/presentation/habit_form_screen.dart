import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/snack.dart';
import 'habit_providers.dart';

/// Used for both "New habit" ([habitId] == null) and "Edit habit".
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});
  final String? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  int _color = AppTheme.habitColors.first.toARGB32();

  bool get _isEdit => widget.habitId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final habits = ref.read(habitsProvider).value ?? [];
      final match = habits.where((h) => h.id == widget.habitId);
      if (match.isNotEmpty) {
        final h = match.first;
        _title.text = h.title;
        _description.text = h.description;
        _color = h.colorValue;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final actions = ref.read(habitActionsProvider.notifier);
    final ok = _isEdit
        ? await actions.updateHabit(widget.habitId!, _title.text, _description.text, _color)
        : await actions.add(_title.text, _description.text, _color);
    if (!mounted) return;
    if (ok) {
      context.pop();
    } else {
      showSnack(context, errorMessage(ref.read(habitActionsProvider).error), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(habitActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit habit' : 'New habit')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 40,
                  validator: (v) => Validators.required(v, 'Title'),
                  decoration: const InputDecoration(
                      labelText: 'Habit name', hintText: 'e.g. Drink 8 glasses of water'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  maxLength: 120,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)', alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                Text('Color', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final c in AppTheme.habitColors)
                      GestureDetector(
                        onTap: () => setState(() => _color = c.toARGB32()),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == c.toARGB32()
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: _color == c.toARGB32()
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Icon(Icons.check),
                  label: Text(_isEdit ? 'Save changes' : 'Create habit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
