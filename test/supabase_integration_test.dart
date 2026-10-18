import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cal_ai_app/core/config/app_config.dart';
import 'package:cal_ai_app/models/meal_log.dart';
import 'package:cal_ai_app/services/supabase_service.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
    final client = SupabaseClient(
      AppConfig.supabaseUrl,
      AppConfig.supabaseAnonKey,
    );
    SupabaseService.instance.setClient(client);
  });

  test('SupabaseService authenticates and manages profile and meal_logs', () async {
    final supa = SupabaseService.instance;
    expect(supa.isAvailable, isTrue);

    const testEmail = 'kalo_test_user_01@example.com';
    const testPassword = 'KaloSecret2026!';

    final authResponse = await supa.signIn(
      email: testEmail,
      password: testPassword,
    );

    expect(authResponse, isNotNull);
    final user = authResponse?.user;
    expect(user, isNotNull);

    var profile = await supa.getProfile(user!.id);
    if (profile == null) {
      await supa.createDefaultProfile(user.id);
      profile = await supa.getProfile(user.id);
    }

    expect(profile, isNotNull);
    expect(profile?.id, equals(user.id));
    expect(profile?.dailyCalories, isPositive);

    final updatedProfile = profile!.copyWith(dailyCalories: 2350, goal: 'hypertrophy');
    final updateSuccess = await supa.updateProfile(updatedProfile);
    expect(updateSuccess, isTrue);

    final mealLog = MealLog(
      id: '',
      userId: user.id,
      foodName: 'Grilled Ribeye with Asparagus',
      totalCalories: 680,
      protein: 58.0,
      carbs: 6.0,
      fat: 48.0,
      healthScore: 9,
      ingredients: [
        {
          'name': 'Ribeye Steak',
          'portion': '250g',
          'calories': 620,
          'protein': 54.0,
          'carbs': 0.0,
          'fat': 46.0,
        },
        {
          'name': 'Asparagus',
          'portion': '120g',
          'calories': 60,
          'protein': 4.0,
          'carbs': 6.0,
          'fat': 2.0,
        }
      ],
      loggedAt: DateTime.now(),
    );

    final savedMeal = await supa.insertMealLog(mealLog);
    expect(savedMeal, isNotNull);
    expect(savedMeal?.id.isNotEmpty, isTrue);
    expect(savedMeal?.foodName, equals('Grilled Ribeye with Asparagus'));

    final logs = await supa.getMealLogs(user.id);
    expect(logs.isNotEmpty, isTrue);
    expect(logs.any((l) => l.foodName == 'Grilled Ribeye with Asparagus'), isTrue);
  }, timeout: const Timeout(Duration(seconds: 45)));
}
