import 'meal_ingredient.dart';

enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snacks');

  final String label;
  const MealType(this.label);
}

enum MealSource {
  aiPhoto('AI Camera'),
  barcode('Barcode'),
  labelOcr('Label OCR'),
  voice('Voice'),
  manual('Manual');

  final String label;
  const MealSource(this.label);
}

class Meal {
  final String id;
  final String dishName;
  final MealType mealType;
  final MealSource sourceType;
  final DateTime loggedAt;
  final String? photoUrl;
  final int healthScore; // 1 to 10
  final List<MealIngredient> ingredients;
  final String? notes;

  const Meal({
    required this.id,
    required this.dishName,
    required this.mealType,
    required this.sourceType,
    required this.loggedAt,
    this.photoUrl,
    this.healthScore = 8,
    required this.ingredients,
    this.notes,
  });

  double get totalCalories =>
      ingredients.fold(0.0, (sum, item) => sum + item.calories);

  double get totalProtein =>
      ingredients.fold(0.0, (sum, item) => sum + item.proteinG);

  double get totalCarbs =>
      ingredients.fold(0.0, (sum, item) => sum + item.carbsG);

  double get totalFat =>
      ingredients.fold(0.0, (sum, item) => sum + item.fatG);

  Meal copyWith({
    String? dishName,
    MealType? mealType,
    MealSource? sourceType,
    DateTime? loggedAt,
    String? photoUrl,
    int? healthScore,
    List<MealIngredient>? ingredients,
    String? notes,
  }) {
    return Meal(
      id: id,
      dishName: dishName ?? this.dishName,
      mealType: mealType ?? this.mealType,
      sourceType: sourceType ?? this.sourceType,
      loggedAt: loggedAt ?? this.loggedAt,
      photoUrl: photoUrl ?? this.photoUrl,
      healthScore: healthScore ?? this.healthScore,
      ingredients: ingredients ?? this.ingredients,
      notes: notes ?? this.notes,
    );
  }
}
