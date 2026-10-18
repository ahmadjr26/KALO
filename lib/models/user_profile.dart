class UserProfile {
  final String id;
  final String name;
  final String email;
  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final double targetWeightKg;
  final String activityLevel;
  final String dietaryStyle;
  final int calorieBudget;
  final int proteinTargetG;
  final int carbsTargetG;
  final int fatTargetG;
  final int waterTargetMl;
  final int currentStreak;
  final bool isSubscribed;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.gender = 'Male',
    this.age = 26,
    this.heightCm = 178,
    this.weightKg = 78,
    this.targetWeightKg = 73,
    this.activityLevel = 'Moderately Active',
    this.dietaryStyle = 'High Protein',
    this.calorieBudget = 2150,
    this.proteinTargetG = 160,
    this.carbsTargetG = 210,
    this.fatTargetG = 65,
    this.waterTargetMl = 2500,
    this.currentStreak = 7,
    this.isSubscribed = true,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    String? activityLevel,
    String? dietaryStyle,
    int? calorieBudget,
    int? proteinTargetG,
    int? carbsTargetG,
    int? fatTargetG,
    int? waterTargetMl,
    int? currentStreak,
    bool? isSubscribed,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryStyle: dietaryStyle ?? this.dietaryStyle,
      calorieBudget: calorieBudget ?? this.calorieBudget,
      proteinTargetG: proteinTargetG ?? this.proteinTargetG,
      carbsTargetG: carbsTargetG ?? this.carbsTargetG,
      fatTargetG: fatTargetG ?? this.fatTargetG,
      waterTargetMl: waterTargetMl ?? this.waterTargetMl,
      currentStreak: currentStreak ?? this.currentStreak,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}
