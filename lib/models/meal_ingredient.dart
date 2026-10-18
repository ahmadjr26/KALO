class MealIngredient {
  final String id;
  final String name;
  final double massGrams;
  final double displayQuantity;
  final String displayUnit;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;

  const MealIngredient({
    required this.id,
    required this.name,
    required this.massGrams,
    required this.displayQuantity,
    required this.displayUnit,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
  });

  MealIngredient copyWith({
    String? name,
    double? massGrams,
    double? displayQuantity,
    String? displayUnit,
    double? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
    double? sugarG,
    double? sodiumMg,
  }) {
    return MealIngredient(
      id: id,
      name: name ?? this.name,
      massGrams: massGrams ?? this.massGrams,
      displayQuantity: displayQuantity ?? this.displayQuantity,
      displayUnit: displayUnit ?? this.displayUnit,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      fiberG: fiberG ?? this.fiberG,
      sugarG: sugarG ?? this.sugarG,
      sodiumMg: sodiumMg ?? this.sodiumMg,
    );
  }

  /// Recalculates nutritional values when quantity changes
  MealIngredient scale(double newQuantity) {
    if (displayQuantity <= 0) return this;
    final double ratio = newQuantity / displayQuantity;
    return copyWith(
      displayQuantity: newQuantity,
      massGrams: (massGrams * ratio).roundToDouble(),
      calories: (calories * ratio).roundToDouble(),
      proteinG: double.parse((proteinG * ratio).toStringAsFixed(1)),
      carbsG: double.parse((carbsG * ratio).toStringAsFixed(1)),
      fatG: double.parse((fatG * ratio).toStringAsFixed(1)),
      fiberG: double.parse((fiberG * ratio).toStringAsFixed(1)),
      sugarG: double.parse((sugarG * ratio).toStringAsFixed(1)),
      sodiumMg: (sodiumMg * ratio).roundToDouble(),
    );
  }
}
