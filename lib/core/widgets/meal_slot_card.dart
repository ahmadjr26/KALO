import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../models/meal.dart';

class MealSlotCard extends StatelessWidget {
  final String title;
  final String recommendedCal;
  final IconData icon;
  final Color iconBgColor;
  final VoidCallback onAdd;
  final List<Meal> meals;
  final void Function(Meal meal)? onMealTap;
  final void Function(Meal meal)? onMealDelete;

  const MealSlotCard({
    super.key,
    required this.title,
    required this.recommendedCal,
    required this.icon,
    this.iconBgColor = const Color(0xFFCDE26D),
    required this.onAdd,
    this.meals = const [],
    this.onMealTap,
    this.onMealDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasMeals = meals.isNotEmpty;
    final totalSlotCalories = meals.fold<int>(0, (sum, m) => sum + m.totalCalories.toInt());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasMeals ? AppColors.accentBorder : const Color(0xFFE6DAAE).withAlpha(120),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header / Quick Add row
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Circular Icon Thumbnail matching Figma
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: iconBgColor.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 22,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Meal slot labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.base.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasMeals
                              ? '$totalSlotCalories kcal logged • $recommendedCal'
                              : recommendedCal,
                          style: AppTypography.xs.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add button circle matching Figma frame 1:482
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFCDE26D),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.textDark,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logged Meal Items in this slot
          if (hasMeals) ...[
            const Divider(height: 1, color: AppColors.border),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: meals.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, i) {
                final meal = meals[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Circular food thumbnail
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Icon(Icons.restaurant_menu_rounded, size: 18, color: AppColors.textSecondary),
                        ),
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
                            const SizedBox(height: 2),
                            Text(
                              '${meal.totalCalories.toInt()} kcal • P:${meal.totalProtein.round()}g C:${meal.totalCarbs.round()}g F:${meal.totalFat.round()}g',
                              style: AppTypography.xs.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onMealDelete != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          onPressed: () => onMealDelete!(meal),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
