import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cal_ai_app/main.dart';

void main() {
  testWidgets('CalAiApp launches and shows dashboard nutrition headers', (WidgetTester tester) async {
    // Configure standard mobile portrait viewport (iPhone/Pixel dimensions)
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

    // Verify key dashboard UI elements
    expect(find.text("TODAY'S NUTRITION"), findsOneWidget);
    expect(find.text("Daily Macronutrients"), findsOneWidget);
    expect(find.text("Today's Meals"), findsOneWidget);
    expect(find.text("CALORIES LEFT"), findsOneWidget);
  });
}
