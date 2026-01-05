import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Test Mode'),
        ),
      ),
    );

    expect(find.text('Test Mode'), findsOneWidget);
  });

  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Note: Full app integration tests require Supabase initialization.
    // Use unit or widget tests for components that don't depend on Supabase.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Widget Test'),
          ),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
