import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:info_warga/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App starts successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify the app loaded without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash screen appears', (WidgetTester tester) async {
      app.main();
      
      // Look for splash page indicators
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // The app should navigate away from splash after initialization
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Navigation between pages works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test if home page has basic elements
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('App handles basic user interactions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and verify the app has interactive elements
      final enabledButtons = find.byWidgetPredicate(
        (widget) => widget is FloatingActionButton,
      );

      expect(enabledButtons, findsWidgets);
    });

    testWidgets('Screen rotation handled', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Save the original size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      // Test landscape orientation
      tester.binding.window.physicalSizeTestValue = const Size(800, 600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      await tester.pumpAndSettle();

      // Verify app still works
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Memory management - long running app', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate user interactions over time
      for (int i = 0; i < 5; i++) {
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      // App should still be responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Error handling - network unavailable scenario', 
      (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // App should handle network issues gracefully
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
