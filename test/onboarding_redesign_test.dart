import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cal_ai_app/screens/onboarding/onboarding_flow_screen.dart';
import 'package:cal_ai_app/core/theme/app_theme.dart';
import 'package:cal_ai_app/core/localization/app_localizations.dart';

void main() {
  testWidgets('OnboardingFlowScreen complete 8-step journey test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(() => _EnglishTestLocaleNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const OnboardingFlowScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PRECISION AI NUTRITION'), findsOneWidget);
    expect(find.text('Snap your meal.\nKalo tracks everything.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('What is your primary goal?'), findsOneWidget);
    await tester.tap(find.text('Build Muscle'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What stopped you in the past?'), findsOneWidget);
    await tester.tap(find.text('Manual logging takes too long'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Biological Sex & Age'), findsOneWidget);
    await tester.tap(find.text('Female'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Your Measurements'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Physical Activity Level'), findsOneWidget);
    await tester.tap(find.text('3 - 5 workouts / week'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Target Weight & Pace'), findsOneWidget);
    await tester.tap(find.text('Balanced (Recommended)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Your Custom Nutrition Plan'), findsOneWidget);
    expect(find.text('Target Macro Distribution'), findsOneWidget);
    expect(find.text('Projected Target Timeline'), findsOneWidget);
    expect(find.text('Accept Plan & Continue'), findsOneWidget);
  });
}

class _EnglishTestLocaleNotifier extends LocaleNotifier {
  @override
  AppLanguage build() => AppLanguage.english;
}
