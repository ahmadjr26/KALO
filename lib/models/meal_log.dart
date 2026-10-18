import 'dart:convert';

class MealLog {
  final String id;
  final String userId;
  final String foodName;
  final int totalCalories;
  final double protein;
  final double carbs;
  final double fat;
  final int healthScore;
  final List<Map<String, dynamic>> ingredients;
  final DateTime loggedAt;

  const MealLog({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.healthScore,
    required this.ingredients,
    required this.loggedAt,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parsedIngredients = [];
    final rawIngredients = json['ingredients'];
    if (rawIngredients is List) {
      for (final item in rawIngredients) {
        if (item is Map) {
          parsedIngredients.add(Map<String, dynamic>.from(item));
        }
      }
    } else if (rawIngredients is String) {
      try {
        final decoded = jsonDecode(rawIngredients);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              parsedIngredients.add(Map<String, dynamic>.from(item));
            }
          }
        }
      } catch (_) {}
    }

    return MealLog(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      foodName: json['food_name'] as String? ?? 'Meal',
      totalCalories: (json['total_calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      healthScore: (json['health_score'] as num?)?.round() ?? 8,
      ingredients: parsedIngredients,
      loggedAt: json['logged_at'] != null
          ? DateTime.tryParse(json['logged_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'food_name': foodName,
      'total_calories': totalCalories,
      'protein': protein.round(),
      'carbs': carbs.round(),
      'fat': fat.round(),
      'health_score': healthScore,
      'ingredients': ingredients,
      'logged_at': loggedAt.toIso8601String(),
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    if (userId.isNotEmpty) {
      map['user_id'] = userId;
    }
    return map;
  }

  MealLog copyWith({
    String? id,
    String? userId,
    String? foodName,
    int? totalCalories,
    double? protein,
    double? carbs,
    double? fat,
    int? healthScore,
    List<Map<String, dynamic>>? ingredients,
    DateTime? loggedAt,
  }) {
    return MealLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      totalCalories: totalCalories ?? this.totalCalories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      healthScore: healthScore ?? this.healthScore,
      ingredients: ingredients ?? this.ingredients,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}
