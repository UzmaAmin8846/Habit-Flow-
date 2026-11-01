import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/shared/widgets/async_value_view.dart';

Widget _wrap(AsyncValue<List<int>> value) => MaterialApp(
      home: Scaffold(
        body: AsyncValueView<List<int>>(
          value: value,
          onRetry: () {},
          isEmpty: (l) => l.isEmpty,
          empty: const Text('EMPTY'),
          data: (l) => Text('DATA ${l.length}'),
        ),
      ),
    );

void main() {
  testWidgets('shows loading indicator', (tester) async {
    await tester.pumpWidget(_wrap(const AsyncLoading()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error with retry button', (tester) async {
    await tester.pumpWidget(_wrap(AsyncError('boom', StackTrace.empty)));
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows empty state', (tester) async {
    await tester.pumpWidget(_wrap(const AsyncData(<int>[])));
    expect(find.text('EMPTY'), findsOneWidget);
  });

  testWidgets('shows data', (tester) async {
    await tester.pumpWidget(_wrap(const AsyncData([1, 2, 3])));
    expect(find.text('DATA 3'), findsOneWidget);
  });
}
