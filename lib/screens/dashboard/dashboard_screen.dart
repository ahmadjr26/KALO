import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/calorie_ring.dart';
import '../../core/widgets/macro_progress_bar.dart';
import '../../models/meal.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final authState = ref.watch(authProvider);
    final currentLang = ref.watch(localeProvider);
    final isAr = currentLang == AppLanguage.arabic;

    final baseProfile = state.profile;
    final profile = authState.profile != null
        ? baseProfile.copyWith(
            calorieBudget: authState.profile!.dailyCalories,
            proteinTargetG: authState.profile!.dailyProtein.round(),
            carbsTargetG: authState.profile!.dailyCarbs.round(),
            fatTargetG: authState.profile!.dailyFat.round(),
          )
        : baseProfile;

    final rawEmail = authState.user?.email ?? '';
    final displayName = rawEmail.isNotEmpty
        ? rawEmail.split('@').first
        : AppStrings.get('champion', currentLang);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.get('hey', currentLang)}, $displayName 👋',
                            style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.get('today_nutrition', currentLang),
                            style: AppTypography.xs.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            '${profile.currentStreak} ${AppStrings.get('days_streak', currentLang)}',
                            style: AppTypography.xs.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85,
                      colors: [
                        AppColors.accent.withValues(alpha: 0.08),
                        AppColors.surface,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      CalorieBudgetRing(
                        consumedCalories: state.totalCaloriesConsumed.toInt(),
                        calorieBudget: profile.calorieBudget,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricStat(
                              label: AppStrings.get('budget', currentLang),
                              value: '${profile.calorieBudget}',
                              unit: AppStrings.get('kcal', currentLang),
                            ),
                          ),
                          Container(width: 1, height: 28, color: AppColors.border),
                          Expanded(
                            child: _MetricStat(
                              label: AppStrings.get('consumed', currentLang),
                              value: '${state.totalCaloriesConsumed.toInt()}',
                              unit: AppStrings.get('kcal', currentLang),
                              color: AppColors.accent,
                            ),
                          ),
                          Container(width: 1, height: 28, color: AppColors.border),
                          Expanded(
                            child: _MetricStat(
                              label: AppStrings.get('remaining', currentLang),
                              value: '${state.remainingCalories}',
                              unit: AppStrings.get('kcal', currentLang),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'الماكروز اليومية' : 'Daily Macronutrients',
                        style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      MacroProgressBar(
                        label: AppStrings.get('protein', currentLang),
                        currentGrams: state.totalProteinConsumed,
                        targetGrams: profile.proteinTargetG.toDouble(),
                        color: AppColors.protein,
                      ),
                      const SizedBox(height: 14),
                      MacroProgressBar(
                        label: AppStrings.get('carbs', currentLang),
                        currentGrams: state.totalCarbsConsumed,
                        targetGrams: profile.carbsTargetG.toDouble(),
                        color: AppColors.carbs,
                      ),
                      const SizedBox(height: 14),
                      MacroProgressBar(
                        label: AppStrings.get('fat', currentLang),
                        currentGrams: state.totalFatConsumed,
                        targetGrams: profile.fatTargetG.toDouble(),
                        color: AppColors.fat,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/water'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.water_drop, color: AppColors.water, size: 22),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(appStateProvider.notifier).addWater(250);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.water.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        '+250ml',
                                        style: TextStyle(
                                          color: AppColors.water,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${state.waterIntakeMl} ml',
                                style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${isAr ? 'من هدف' : 'of'} ${profile.waterTargetMl}ml',
                                style: AppTypography.xs,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/fasting'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.timer_outlined, color: AppColors.warning, size: 22),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      '16:8 FAST',
                                      style: TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.isFasting
                                    ? (isAr ? 'صيام جارٍ' : 'Fasting')
                                    : (isAr ? 'نافذة الأكل' : 'Eating Window'),
                                style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.isFasting
                                    ? (isAr ? 'مرحلة حرق الدهون' : 'Fat Burning Stage')
                                    : (isAr ? 'اكتمل الصيام' : 'Fast Complete'),
                                style: AppTypography.xs,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.get('logged_meals', currentLang),
                        style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/food-search'),
                      child: Text(
                        isAr ? 'البحث اليدوي' : 'Database Search',
                        style: AppTypography.xs.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.meals.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined, size: 28, color: AppColors.accent),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.get('no_meals_today', currentLang),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.get('start_tracking_hint', currentLang),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/scanner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.bolt, size: 18),
                          label: Text(
                            AppStrings.get('scan_meal_button', currentLang),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final mealType = MealType.values[index];
                    final mealsInGroup = state.meals
                        .where((m) => m.mealType == mealType)
                        .toList();

                    return _MealGroupTile(
                      mealType: mealType,
                      meals: mealsInGroup,
                      currentLang: currentLang,
                      onAddTap: () => context.push('/scanner'),
                      onDeleteMeal: (mealId) {
                        ref.read(appStateProvider.notifier).deleteMeal(mealId);
                      },
                    );
                  },
                  childCount: MealType.values.length,
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 90),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? color;

  const _MetricStat({
    required this.label,
    required this.value,
    required this.unit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.lg.copyWith(
            fontWeight: FontWeight.w800,
            color: color ?? AppColors.text,
          ),
        ),
        Text(
          '$label • $unit',
          style: AppTypography.xs.copyWith(color: AppColors.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MealGroupTile extends StatelessWidget {
  final MealType mealType;
  final List<Meal> meals;
  final AppLanguage currentLang;
  final VoidCallback onAddTap;
  final Function(String) onDeleteMeal;

  const _MealGroupTile({
    required this.mealType,
    required this.meals,
    required this.currentLang,
    required this.onAddTap,
    required this.onDeleteMeal,
  });

  String _getMealTypeLabel(MealType type, bool isAr) {
    if (!isAr) return type.label;
    switch (type) {
      case MealType.breakfast:
        return 'الفطور';
      case MealType.lunch:
        return 'الغداء';
      case MealType.dinner:
        return 'العشاء';
      case MealType.snack:
        return 'سناك وخفايف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = currentLang == AppLanguage.arabic;
    final double groupCalories =
        meals.fold(0.0, (sum, m) => sum + m.totalCalories);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _getMealTypeLabel(mealType, isAr),
                        style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (groupCalories > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${groupCalories.toInt()} ${AppStrings.get('kcal', currentLang)}',
                          style: AppTypography.sm.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    onPressed: onAddTap,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            if (meals.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                child: Row(
                  children: [
                    Text(
                      isAr ? 'لم تسجل وجبة بعد' : 'No meals logged yet',
                      style: AppTypography.xs.copyWith(color: AppColors.textMuted.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: meals.map((meal) {
                  return InkWell(
                    onTap: () => context.push('/meal-detail', extra: meal),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.restaurant_outlined, size: 18, color: AppColors.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.dishName,
                                  style: AppTypography.sm.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'P: ${meal.totalProtein.toInt()}g  •  C: ${meal.totalCarbs.toInt()}g  •  F: ${meal.totalFat.toInt()}g',
                                  style: AppTypography.xs,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${meal.totalCalories.toInt()} ${AppStrings.get('kcal', currentLang)}',
                            style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: Text(
                                    AppStrings.get('delete_meal', currentLang),
                                    style: const TextStyle(color: AppColors.text),
                                  ),
                                  content: Text(
                                    AppStrings.get('delete_meal_confirm', currentLang),
                                    style: const TextStyle(color: AppColors.textMuted),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text(
                                        AppStrings.get('cancel', currentLang),
                                        style: const TextStyle(color: AppColors.textMuted),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        onDeleteMeal(meal.id);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(AppStrings.get('confirm', currentLang)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
