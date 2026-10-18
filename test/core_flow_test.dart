import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cal_ai_app/main.dart';

void main() {
  testWidgets('End-to-End Vertical Slice: Scan Meal -> Review & Edit -> Log -> Dashboard Updates', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: CalAiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial State: Check initial Remaining Calories
    expect(find.text("TODAY'S NUTRITION"), findsOneWidget);

    // 2. Tap Floating Action Button (Camera)
    final fabFinder = find.byType(FloatingActionButton);
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Camera Scanner Screen is open
    expect(find.text('AI Vision Camera Active'), findsOneWidget);
    expect(find.text('Food Scan'), findsOneWidget);

    // 3. Trigger Photo Capture (Simulate scanning a plate)
    final shutterFinder = find.byKey(const Key('shutter_button'));
    expect(shutterFinder, findsOneWidget);
    await tester.tap(shutterFinder);
    await tester.pump(); // Start simulation

    // Wait for the simulated AI vision scan latency (900ms)
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Verify Scan Result Screen S17
    expect(find.text('Meal Breakdown'), findsOneWidget);
    expect(find.text('Herb-Roasted Chicken Breast with Broccoli'), findsOneWidget);
    expect(find.text('Confirm & Log Meal'), findsOneWidget);

    // 4. Confirm and Log the Meal
    await tester.tap(find.text('Confirm & Log Meal'));
    await tester.pumpAndSettle();

    // 5. Back on Dashboard S15, meal should now be visible in list
    expect(find.text("TODAY'S NUTRITION"), findsOneWidget);
    final mealFinder = find.text('Herb-Roasted Chicken Breast with Broccoli');
    await tester.scrollUntilVisible(mealFinder, 300);
    expect(mealFinder, findsOneWidget);
  });
}
