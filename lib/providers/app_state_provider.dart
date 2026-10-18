import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_database.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';

class AppState {
  final UserProfile profile;
  final List<Meal> meals;
  final int waterIntakeMl;
  final bool isFasting;
  final DateTime? fastStartTime;

  const AppState({
    required this.profile,
    required this.meals,
    this.waterIntakeMl = 1500,
    this.isFasting = true,
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
    return AppState(
      profile: MockDatabase.seedProfile,
      meals: List.from(MockDatabase.seedMeals),
      waterIntakeMl: 1500,
      isFasting: true,
      fastStartTime: DateTime.now().subtract(const Duration(hours: 13, minutes: 24)),
    );
  }

  void addMeal(Meal meal) {
    state = state.copyWith(meals: [meal, ...state.meals]);
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
  }

  void addWater(int ml) {
    final newTotal = (state.waterIntakeMl + ml).clamp(0, 10000);
    state = state.copyWith(waterIntakeMl: newTotal);
  }

  void updateProfile(UserProfile newProfile) {
    state = state.copyWith(profile: newProfile);
  }

  void toggleFasting() {
    if (state.isFasting) {
      state = state.copyWith(isFasting: false, fastStartTime: null);
    } else {
      state = state.copyWith(isFasting: true, fastStartTime: DateTime.now());
    }
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

