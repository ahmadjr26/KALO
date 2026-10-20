import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/meal.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/meal_slot_card.dart';

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
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Opacity(
              opacity: animValue,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - animValue)),
                child: child,
              ),
            );
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Editorial Header & Weekly Calendar Strip
              SliverToBoxAdapter(
                child: _EditorialHeader(
                  displayName: displayName,
                  streak: profile.currentStreak,
                  currentLang: currentLang,
                  isAr: isAr,
                ),
              ),

              // 2. Compact Horizontal Energy Balance Card (No Donut Ring)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _EnergyBalanceCard(
                    budget: profile.calorieBudget,
                    consumed: state.totalCaloriesConsumed.toInt(),
                    remaining: state.remainingCalories,
                    currentLang: currentLang,
                    isAr: isAr,
                  ),
                ),
              ),

              // 3. 3-Column Macro Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'الماكروز اليومية' : 'Daily Macronutrients',
                        style: AppTypography.sm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _MacroTrioSection(
                        consumedProtein: state.totalProteinConsumed,
                        targetProtein: profile.proteinTargetG,
                        consumedCarbs: state.totalCarbsConsumed,
                        targetCarbs: profile.carbsTargetG,
                        consumedFat: state.totalFatConsumed,
                        targetFat: profile.fatTargetG,
                        isAr: isAr,
                      ),
                    ],
                  ),
                ),
              ),



              // 6. Section Header for Today's Meals
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get('logged_meals', currentLang),
                        style: AppTypography.lg.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/food-search'),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              isAr ? 'البحث اليدوي' : 'Database Search',
                              style: AppTypography.xs.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 7. Meals List or Empty State
              if (state.meals.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _EmptyMealsCard(
                      isAr: isAr,
                      currentLang: currentLang,
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

              // 6. Primary Meal-Logging Hero Banner & Shortcuts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: _QuickLogActionBanner(
                    isAr: isAr,
                    currentLang: currentLang,
                  ),
                ),
              ),

              // 7. Meal Planner Slots matching Figma Frame 1:230
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'جدول الوجبات اليومي' : 'Daily Meal Schedule',
                        style: AppTypography.sm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      MealSlotCard(
                        title: isAr ? 'إضافة فطور' : 'Add Breakfast',
                        recommendedCal: isAr ? 'المقترح 450-650 سعرة' : 'Recommended 450-650 cal',
                        icon: Icons.breakfast_dining_rounded,
                        iconBgColor: const Color(0xFFCDE26D),
                        onAdd: () => context.push('/scanner'),
                      ),
                      MealSlotCard(
                        title: isAr ? 'إضافة غداء' : 'Add Lunch',
                        recommendedCal: isAr ? 'المقترح 600-800 سعرة' : 'Recommended 600-800 cal',
                        icon: Icons.lunch_dining_rounded,
                        iconBgColor: AppColors.figmaAmber,
                        onAdd: () => context.push('/scanner'),
                      ),
                      MealSlotCard(
                        title: isAr ? 'إضافة عشاء' : 'Add Dinner',
                        recommendedCal: isAr ? 'المقترح 500-700 سعرة' : 'Recommended 500-700 cal',
                        icon: Icons.dinner_dining_rounded,
                        iconBgColor: AppColors.figmaRose,
                        onAdd: () => context.push('/scanner'),
                      ),
                    ],
                  ),
                ),
              ),

              // 8. Cohesive Daily Habits (Hydration + Intermittent Fasting)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: _DailyHabitsSection(
                    waterIntakeMl: state.waterIntakeMl,
                    waterTargetMl: profile.waterTargetMl,
                    isFasting: state.isFasting,
                    isAr: isAr,
                    onAddWater: () {
                      ref.read(appStateProvider.notifier).addWater(250);
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. EDITORIAL HEADER & WEEKLY CALENDAR STRIP
// ============================================================================

class _EditorialHeader extends StatelessWidget {
  final String displayName;
  final int streak;
  final AppLanguage currentLang;
  final bool isAr;

  const _EditorialHeader({
    required this.displayName,
    required this.streak,
    required this.currentLang,
    required this.isAr,
  });

  String _formatDateString() {
    final now = DateTime.now();
    final monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthsAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final daysAr = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

    final dayName = isAr ? daysAr[now.weekday - 1] : daysEn[now.weekday - 1];
    final monthName = isAr ? monthsAr[now.month - 1] : monthsEn[now.month - 1];

    if (isAr) {
      return '$dayName، ${now.day} $monthName';
    }
    return '$dayName, $monthName ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular User Avatar matching Figma Frame 1:233
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFCDE26D).withAlpha(50),
                  border: Border.all(color: const Color(0xFFCDE26D), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'K',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preserves TODAY'S NUTRITION label for tests and clear hierarchy
                    Row(
                      children: [
                        Text(
                          AppStrings.get('today_nutrition', currentLang),
                          style: AppTypography.xs.copyWith(
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' • ${_formatDateString()}',
                            style: AppTypography.xs.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppStrings.get('hey', currentLang)}, $displayName',
                      style: AppTypography.lg.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Search circle button matching Figma Frame 1:236
              GestureDetector(
                onTap: () => context.push('/food-search'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(Icons.search_rounded, size: 18, color: AppColors.text),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Streak Capsule with warm amber styling
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningSubtle,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.warning,
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$streak',
                      style: AppTypography.xs.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _WeeklyCalendarStrip(isAr: isAr),
        ],
      ),
    );
  }
}

class _WeeklyCalendarStrip extends StatelessWidget {
  final bool isAr;

  const _WeeklyCalendarStrip({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final daysEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final daysAr = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];

    // Monday of current week
    final monday = now.subtract(Duration(days: todayWeekday - 1));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final date = monday.add(Duration(days: i));
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
          final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isToday ? AppColors.accentSubtle : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAr ? daysAr[i] : daysEn[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                    color: isToday ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                    color: isToday
                        ? AppColors.accent
                        : (isPast ? AppColors.text : AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? AppColors.accent
                        : (isPast ? AppColors.borderInput : Colors.transparent),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================================
// 2. COMPACT HORIZONTAL ENERGY BALANCE CARD (NO DONUT CIRCLE)
// ============================================================================

class _EnergyBalanceCard extends StatelessWidget {
  final int budget;
  final int consumed;
  final int remaining;
  final AppLanguage currentLang;
  final bool isAr;

  const _EnergyBalanceCard({
    required this.budget,
    required this.consumed,
    required this.remaining,
    required this.currentLang,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final double safeBudget = budget > 0 ? budget.toDouble() : 2000.0;
    final double ratio = (consumed / safeBudget).clamp(0.0, 1.0);
    final int percent = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Calories Remaining Hero Typography
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'السعرات المتبقية' : 'CALORIES LEFT',
                    style: AppTypography.xs.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$remaining',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: AppColors.text,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.get('kcal', currentLang),
                        style: AppTypography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$budget ${AppStrings.get('kcal', currentLang)}',
                      style: AppTypography.xs.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Horizontal Progress Track with Animated Fill
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 10,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: ratio),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                        widthFactor: value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percent% ${isAr ? 'مستهلك' : 'consumed'}',
                    style: AppTypography.xs.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(budget - consumed).clamp(0, 9999)} ${AppStrings.get('kcal', currentLang)} ${isAr ? 'متبقي' : 'left'}',
                    style: AppTypography.xs.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // 3-Stat Breakdown Row
          Row(
            children: [
              Expanded(
                child: _MetricStatItem(
                  label: AppStrings.get('budget', currentLang),
                  value: '$budget',
                  unit: AppStrings.get('kcal', currentLang),
                ),
              ),
              Container(width: 1, height: 26, color: AppColors.border),
              Expanded(
                child: _MetricStatItem(
                  label: AppStrings.get('consumed', currentLang),
                  value: '$consumed',
                  unit: AppStrings.get('kcal', currentLang),
                  valueColor: AppColors.accent,
                ),
              ),
              Container(width: 1, height: 26, color: AppColors.border),
              Expanded(
                child: _MetricStatItem(
                  label: AppStrings.get('remaining', currentLang),
                  value: '$remaining',
                  unit: AppStrings.get('kcal', currentLang),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricStatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;

  const _MetricStatItem({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.base.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$label • $unit',
          style: AppTypography.xs.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ============================================================================
// 3. 3-COLUMN MACRONUTRIENT GRID (REPLACES 3-BAR STACK)
// ============================================================================

class _MacroTrioSection extends StatelessWidget {
  final double consumedProtein;
  final int targetProtein;
  final double consumedCarbs;
  final int targetCarbs;
  final double consumedFat;
  final int targetFat;
  final bool isAr;

  const _MacroTrioSection({
    required this.consumedProtein,
    required this.targetProtein,
    required this.consumedCarbs,
    required this.targetCarbs,
    required this.consumedFat,
    required this.targetFat,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroColumnCard(
            badge: 'P',
            label: isAr ? 'البروتين' : 'Protein',
            consumed: consumedProtein.toInt(),
            target: targetProtein > 0 ? targetProtein : 150,
            color: AppColors.protein,
            isAr: isAr,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MacroColumnCard(
            badge: 'C',
            label: isAr ? 'الكارب' : 'Carbs',
            consumed: consumedCarbs.toInt(),
            target: targetCarbs > 0 ? targetCarbs : 200,
            color: AppColors.carbs,
            isAr: isAr,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MacroColumnCard(
            badge: 'F',
            label: isAr ? 'الدهون' : 'Fat',
            consumed: consumedFat.toInt(),
            target: targetFat > 0 ? targetFat : 60,
            color: AppColors.fat,
            isAr: isAr,
          ),
        ),
      ],
    );
  }
}

class _MacroColumnCard extends StatelessWidget {
  final String badge;
  final String label;
  final int consumed;
  final int target;
  final Color color;
  final bool isAr;

  const _MacroColumnCard({
    required this.badge,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final double safeTarget = target > 0 ? target.toDouble() : 1.0;
    final double ratio = (consumed / safeTarget).clamp(0.0, 1.0);
    final int remainingG = (target - consumed).clamp(0, 9999);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Text(
                label,
                style: AppTypography.xs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$consumed',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              Text(
                ' / ${target}g',
                style: AppTypography.xs.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              width: double.infinity,
              color: const Color(0xFFF1F5F9),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: ratio),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return FractionallySizedBox(
                    alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      color: color,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$remainingG ${isAr ? 'جم متبقي' : 'g left'}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. PRIMARY MEAL-LOGGING HERO BANNER & QUICK ACTIONS
// ============================================================================

class _QuickLogActionBanner extends StatelessWidget {
  final bool isAr;
  final AppLanguage currentLang;

  const _QuickLogActionBanner({
    required this.isAr,
    required this.currentLang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06059669),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'سجّل وجبتك بالذكاء الاصطناعي' : 'Snap & Log Meal',
                      style: AppTypography.base.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr
                          ? 'التقاط صورة للطبق، مسح باركود، أو وصف صوتي'
                          : 'Point camera to detect calories & macros',
                      style: AppTypography.xs.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push('/scanner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.bolt_rounded, size: 16),
                label: Text(
                  isAr ? 'مسح الآن' : 'Scan AI',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickActionChip(
                icon: Icons.qr_code_scanner_rounded,
                label: isAr ? 'باركود' : 'Barcode',
                onTap: () => context.push('/barcode-scanner'),
              ),
              Container(width: 1, height: 16, color: AppColors.border),
              _QuickActionChip(
                icon: Icons.mic_rounded,
                label: isAr ? 'صوتي' : 'Voice Log',
                onTap: () => context.push('/voice-log'),
              ),
              Container(width: 1, height: 16, color: AppColors.border),
              _QuickActionChip(
                icon: Icons.search_rounded,
                label: isAr ? 'بحث غذائي' : 'Search',
                onTap: () => context.push('/food-search'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.xs.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. UNIFIED DAILY HABITS (HYDRATION & FASTING)
// ============================================================================

class _DailyHabitsSection extends StatelessWidget {
  final int waterIntakeMl;
  final int waterTargetMl;
  final bool isFasting;
  final bool isAr;
  final VoidCallback onAddWater;

  const _DailyHabitsSection({
    required this.waterIntakeMl,
    required this.waterTargetMl,
    required this.isFasting,
    required this.isAr,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final double safeTarget = waterTargetMl > 0 ? waterTargetMl.toDouble() : 2500.0;
    final double waterRatio = (waterIntakeMl / safeTarget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'عادات اليوم والصحة' : 'Daily Habits & Wellness',
            style: AppTypography.sm.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          // Hydration Tile
          InkWell(
            onTap: () => context.push('/water'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.waterSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.water,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'شرب الماء' : 'Hydration',
                              style: AppTypography.sm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              '$waterIntakeMl / ${waterTargetMl}ml',
                              style: AppTypography.xs.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.water,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 6,
                            width: double.infinity,
                            color: const Color(0xFFE0F2FE),
                            child: FractionallySizedBox(
                              alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                              widthFactor: waterRatio,
                              child: Container(color: AppColors.water),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onAddWater,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.waterSubtle,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: const Text(
                        '+250ml',
                        style: TextStyle(
                          color: AppColors.water,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          // Fasting Tile
          InkWell(
            onTap: () => context.push('/fasting'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.warningSubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'الصيام المتقطع' : 'Intermittent Fasting',
                              style: AppTypography.sm.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warningSubtle,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                isFasting ? (isAr ? 'صيام جارٍ' : 'FASTING') : (isAr ? 'نافذة الأكل' : 'EATING'),
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFasting
                              ? (isAr ? 'مرحلة حرق الدهون • بروتوكول 16:8' : 'Fat Burning Stage • 16:8 Protocol')
                              : (isAr ? 'نافذة تناول الطعام مفتوحة' : 'Eating Window Open • Fast Complete'),
                          style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. MEALS TIMELINE & EMPTY STATE
// ============================================================================

class _EmptyMealsCard extends StatelessWidget {
  final bool isAr;
  final AppLanguage currentLang;

  const _EmptyMealsCard({
    required this.isAr,
    required this.currentLang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.accentSubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_outlined, size: 26, color: AppColors.accent),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.get('no_meals_today', currentLang),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.get('start_tracking_hint', currentLang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/scanner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: Text(
              AppStrings.get('scan_meal_button', currentLang),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
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

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.restaurant_rounded;
      case MealType.dinner:
        return Icons.nights_stay_outlined;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = currentLang == AppLanguage.arabic;
    final double groupCalories =
        meals.fold(0.0, (sum, m) => sum + m.totalCalories);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x040F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(_getMealIcon(mealType), size: 18, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        _getMealTypeLabel(mealType, isAr),
                        style: AppTypography.base.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      if (groupCalories > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentSubtle,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${groupCalories.toInt()} ${AppStrings.get('kcal', currentLang)}',
                            style: AppTypography.xs.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(
                      isAr ? 'لم تسجل وجبة بعد' : 'No meals logged yet',
                      style: AppTypography.xs.copyWith(color: AppColors.textMuted.withValues(alpha: 0.7)),
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
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
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
                                  style: AppTypography.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'P: ${meal.totalProtein.toInt()}g  •  C: ${meal.totalCarbs.toInt()}g  •  F: ${meal.totalFat.toInt()}g',
                                  style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${meal.totalCalories.toInt()} ${AppStrings.get('kcal', currentLang)}',
                            style: AppTypography.sm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  title: Text(
                                    AppStrings.get('delete_meal', currentLang),
                                    style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
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
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
