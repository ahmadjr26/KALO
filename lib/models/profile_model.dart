class ProfileModel {
  final String id;
  final double weight;
  final double height;
  final int age;
  final String goal;
  final int dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;

  const ProfileModel({
    required this.id,
    this.weight = 70.0,
    this.height = 175.0,
    this.age = 25,
    this.goal = 'maintain',
    this.dailyCalories = 2000,
    this.dailyProtein = 150.0,
    this.dailyCarbs = 200.0,
    this.dailyFat = 65.0,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      height: (json['height'] as num?)?.toDouble() ?? 175.0,
      age: (json['age'] as num?)?.toInt() ?? 25,
      goal: json['goal'] as String? ?? 'maintain',
      dailyCalories: (json['daily_calories'] as num?)?.toInt() ?? 2000,
      dailyProtein: (json['daily_protein'] as num?)?.toDouble() ?? 150.0,
      dailyCarbs: (json['daily_carbs'] as num?)?.toDouble() ?? 200.0,
      dailyFat: (json['daily_fat'] as num?)?.toDouble() ?? 65.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight.round(),
      'height': height.round(),
      'age': age,
      'goal': goal,
      'daily_calories': dailyCalories,
      'daily_protein': dailyProtein.round(),
      'daily_carbs': dailyCarbs.round(),
      'daily_fat': dailyFat.round(),
    };
  }

  ProfileModel copyWith({
    String? id,
    double? weight,
    double? height,
    int? age,
    String? goal,
    int? dailyCalories,
    double? dailyProtein,
    double? dailyCarbs,
    double? dailyFat,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProtein: dailyProtein ?? this.dailyProtein,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      dailyFat: dailyFat ?? this.dailyFat,
    );
  }
}
