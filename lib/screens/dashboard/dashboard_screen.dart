import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final baseProfile = state.profile;
    final profile = authState.profile != null
        ? baseProfile.copyWith(
            calorieBudget: authState.profile!.dailyCalories,
            proteinTargetG: authState.profile!.dailyProtein.round(),
            carbsTargetG: authState.profile!.dailyCarbs.round(),
            fatTargetG: authState.profile!.dailyFat.round(),
          )
        : baseProfile;

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, ${profile.name.split(' ').first} 👋',
                          style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'TODAY\'S NUTRITION',
                          style: AppTypography.xs.copyWith(
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

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
                            '${profile.currentStreak} DAYS',
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
                        AppColors.accent.withAlpha(20),
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
                              label: 'Budget',
                              value: '${profile.calorieBudget}',
                              unit: 'kcal',
                            ),
                          ),
                          Container(width: 1, height: 28, color: AppColors.border),
                          Expanded(
                            child: _MetricStat(
                              label: 'Consumed',
                              value: '${state.totalCaloriesConsumed.toInt()}',
                              unit: 'kcal',
                              color: AppColors.accent,
                            ),
                          ),
                          Container(width: 1, height: 28, color: AppColors.border),
                          Expanded(
                            child: _MetricStat(
                              label: 'Remaining',
                              value: '${state.remainingCalories}',
                              unit: 'kcal',
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
                        'Daily Macronutrients',
                        style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      MacroProgressBar(
                        label: 'Protein',
                        currentGrams: state.totalProteinConsumed,
                        targetGrams: profile.proteinTargetG.toDouble(),
                        color: AppColors.protein,
                      ),
                      const SizedBox(height: 14),
                      MacroProgressBar(
                        label: 'Carbohydrates',
                        currentGrams: state.totalCarbsConsumed,
                        targetGrams: profile.carbsTargetG.toDouble(),
                        color: AppColors.carbs,
                      ),
                      const SizedBox(height: 14),
                      MacroProgressBar(
                        label: 'Healthy Fats',
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
                                        color: AppColors.water.withAlpha(30),
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
                                'of ${profile.waterTargetMl}ml target',
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
                                      color: AppColors.warning.withAlpha(30),
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
                                state.isFasting ? '13h 24m' : 'Eating Window',
                                style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.isFasting ? 'Fat Burning Stage' : 'Fast Complete',
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
                    Text(
                      'Today\'s Meals',
                      style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/food-search'),
                      child: Text(
                        'Database Search',
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
                    onAddTap: () => context.push('/scanner'),
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
  final VoidCallback onAddTap;

  const _MealGroupTile({
    required this.mealType,
    required this.meals,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
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
                        mealType.label,
                        style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (groupCalories > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${groupCalories.toInt()} kcal',
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
                      'No meals logged yet',
                      style: AppTypography.xs.copyWith(color: AppColors.textMuted.withAlpha(160)),
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
                            '${meal.totalCalories.toInt()} kcal',
                            style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700),
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
