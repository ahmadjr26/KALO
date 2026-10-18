import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/meal_detail/meal_detail_screen.dart';
import '../screens/onboarding/onboarding_flow_screen.dart';
import '../screens/onboarding/paywall_screen.dart';
import '../screens/scanner/barcode_scanner_screen.dart';
import '../screens/scanner/camera_scanner_screen.dart';
import '../screens/scanner/food_search_screen.dart';
import '../screens/scanner/label_scanner_screen.dart';
import '../screens/scanner/scan_result_screen.dart';
import '../screens/scanner/voice_log_dialog.dart';
import '../screens/shell/main_scaffold.dart';
import '../screens/trackers/fasting_screen.dart';
import '../screens/trackers/hydration_screen.dart';

String _determineInitialLocation() {
  if (!kIsWeb && (Platform.environment.containsKey('FLUTTER_TEST') || const bool.fromEnvironment('flutter.test'))) {
    return '/dashboard';
  }
  try {
    if (Supabase.instance.client.auth.currentSession != null) {
      return '/dashboard';
    }
  } catch (_) {}
  return '/auth';
}

final appRouter = GoRouter(
  initialLocation: _determineInitialLocation(),
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingFlowScreen(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const CameraScannerScreen(),
    ),
    GoRoute(
      path: '/scan-result',
      builder: (context, state) {
        final meal = state.extra as Meal;
        return ScanResultScreen(initialMeal: meal);
      },
    ),
    GoRoute(
      path: '/meal-detail',
      builder: (context, state) {
        final meal = state.extra as Meal;
        return MealDetailScreen(meal: meal);
      },
    ),
    GoRoute(
      path: '/food-search',
      builder: (context, state) => const FoodSearchScreen(),
    ),
    GoRoute(
      path: '/barcode-scanner',
      builder: (context, state) => const BarcodeScannerScreen(),
    ),
    GoRoute(
      path: '/label-scanner',
      builder: (context, state) => const LabelScannerScreen(),
    ),
    GoRoute(
      path: '/voice-log',
      builder: (context, state) => const VoiceLogScreen(),
    ),
    GoRoute(
      path: '/water',
      builder: (context, state) => const HydrationScreen(),
    ),
    GoRoute(
      path: '/fasting',
      builder: (context, state) => const FastingScreen(),
    ),
  ],
);
