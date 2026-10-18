import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import '../models/meal_ingredient.dart';
import '../models/meal_log.dart';
import '../models/profile_model.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class AppState {
  final UserProfile profile;
  final List<Meal> meals;
  final int waterIntakeMl;
  final bool isFasting;
  final DateTime? fastStartTime;

  const AppState({
    required this.profile,
    required this.meals,
    this.waterIntakeMl = 0,
    this.isFasting = false,
    this.fastStartTime,
  });

  double get totalCaloriesConsumed =>
      meals.fold(0.0, (sum, meal) => sum + meal.totalCalories);

  double get totalProteinConsumed =>
      meals.fold(0.0, (sum, meal) => sum + meal.totalProtein);

  double get totalCarbsConsumed =>
      meals.fold(0.0, (sum, meal) => sum + meal.totalCarbs);

  double get totalFatConsumed =>
      meals.fold(0.0, (sum, meal) => sum + meal.totalFat);

  int get remainingCalories {
    final remaining = profile.calorieBudget - totalCaloriesConsumed.toInt();
    return remaining > 0 ? remaining : 0;
  }

  AppState copyWith({
    UserProfile? profile,
    List<Meal>? meals,
    int? waterIntakeMl,
    bool? isFasting,
    DateTime? fastStartTime,
  }) {
    return AppState(
      profile: profile ?? this.profile,
      meals: meals ?? this.meals,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      isFasting: isFasting ?? this.isFasting,
      fastStartTime: fastStartTime ?? this.fastStartTime,
    );
  }
}

class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    final initialState = const AppState(
      profile: UserProfile.defaultUser,
      meals: [],
      waterIntakeMl: 0,
      isFasting: false,
      fastStartTime: null,
    );
    Future.microtask(() => syncFromSupabase());
    return initialState;
  }

  Future<void> syncFromSupabase() async {
    try {
      final supa = SupabaseService.instance;
      final userId = supa.currentUserId;
      if (userId == null) return;

      final cloudProfile = await supa.getProfile(userId);
      if (cloudProfile != null) {
        updateFromSupabaseProfile(cloudProfile);
      }

      final cloudLogs = await supa.getMealLogs();
      if (cloudLogs.isNotEmpty) {
        final List<Meal> convertedMeals = cloudLogs.map((log) {
          final ingredients = log.ingredients.map((ing) {
            return MealIngredient(
              id: ing['name']?.toString() ?? 'item',
              name: ing['name']?.toString() ?? 'Item',
              massGrams: 100.0,
              displayQuantity: 1.0,
              displayUnit: 'serving',
              calories: (ing['calories'] as num?)?.toDouble() ?? 100.0,
              proteinG: (ing['protein'] as num?)?.toDouble() ?? 5.0,
              carbsG: (ing['carbs'] as num?)?.toDouble() ?? 10.0,
              fatG: (ing['fat'] as num?)?.toDouble() ?? 3.0,
            );
          }).toList();

          return Meal(
            id: log.id,
            dishName: log.foodName,
            mealType: MealType.lunch,
            sourceType: MealSource.aiPhoto,
            loggedAt: log.loggedAt,
            ingredients: ingredients,
            healthScore: log.healthScore,
          );
        }).toList();

        state = state.copyWith(meals: convertedMeals);
      }
    } catch (_) {}
  }

  void addMeal(Meal meal) {
    state = state.copyWith(meals: [meal, ...state.meals]);
    try {
      final mealLog = MealLog(
        id: meal.id,
        userId: SupabaseService.instance.currentUserId ?? '',
        foodName: meal.dishName,
        totalCalories: meal.totalCalories.toInt(),
        protein: meal.totalProtein,
        carbs: meal.totalCarbs,
        fat: meal.totalFat,
        healthScore: meal.healthScore,
        ingredients: meal.ingredients
            .map((i) => {
                  'name': i.name,
                  'portion': '${i.massGrams}g',
                  'calories': i.calories.toInt(),
                  'protein': i.proteinG,
                  'carbs': i.carbsG,
                  'fat': i.fatG,
                })
            .toList(),
        loggedAt: meal.loggedAt,
      );
      SupabaseService.instance.insertMealLog(mealLog);
    } catch (_) {}
  }

  void updateMeal(Meal updatedMeal) {
    final updatedList = state.meals.map((m) {
      return m.id == updatedMeal.id ? updatedMeal : m;
    }).toList();
    state = state.copyWith(meals: updatedList);
  }

  void deleteMeal(String mealId) {
    final updatedList = state.meals.where((m) => m.id != mealId).toList();
    state = state.copyWith(meals: updatedList);
    try {
      SupabaseService.instance.deleteMealLog(mealId);
    } catch (_) {}
  }

  void addWater(int ml) {
    final newTotal = (state.waterIntakeMl + ml).clamp(0, 10000);
    state = state.copyWith(waterIntakeMl: newTotal);
  }

  void updateProfile(UserProfile newProfile) {
    state = state.copyWith(profile: newProfile);
  }

  void updateFromSupabaseProfile(ProfileModel cloudProfile) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        calorieBudget: cloudProfile.dailyCalories,
        proteinTargetG: cloudProfile.dailyProtein.round(),
        carbsTargetG: cloudProfile.dailyCarbs.round(),
        fatTargetG: cloudProfile.dailyFat.round(),
        weightKg: cloudProfile.weight,
        heightCm: cloudProfile.height,
        age: cloudProfile.age,
      ),
    );
  }

  void toggleFasting() {
    if (state.isFasting) {
      state = state.copyWith(isFasting: false, fastStartTime: null);
    } else {
      state = state.copyWith(isFasting: true, fastStartTime: DateTime.now());
    }
  }

  void clearUserData() {
    state = const AppState(
      profile: UserProfile.defaultUser,
      meals: [],
      waterIntakeMl: 0,
      isFasting: false,
      fastStartTime: null,
    );
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);
