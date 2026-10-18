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
    this.gender = 'Prefer not to say',
    this.age = 25,
    this.heightCm = 175,
    this.weightKg = 75,
    this.targetWeightKg = 70,
    this.activityLevel = 'Active',
    this.dietaryStyle = 'Balanced',
    this.calorieBudget = 2000,
    this.proteinTargetG = 140,
    this.carbsTargetG = 220,
    this.fatTargetG = 65,
    this.waterTargetMl = 2500,
    this.currentStreak = 1,
    this.isSubscribed = true,
  });

  static const defaultUser = UserProfile(
    id: 'guest_user',
    name: 'Champion',
    email: '',
    gender: 'Prefer not to say',
    age: 26,
    heightCm: 178,
    weightKg: 78,
    targetWeightKg: 73,
    activityLevel: 'Active',
    dietaryStyle: 'Balanced',
    calorieBudget: 2150,
    proteinTargetG: 160,
    carbsTargetG: 210,
    fatTargetG: 65,
    waterTargetMl: 2500,
    currentStreak: 1,
    isSubscribed: true,
  );

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
