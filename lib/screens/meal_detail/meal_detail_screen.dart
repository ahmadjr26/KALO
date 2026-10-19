import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/meal.dart';
import '../../providers/app_state_provider.dart';

class MealDetailScreen extends ConsumerWidget {
  final Meal meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Delete Meal?',
          style: AppTypography.base.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to remove "${meal.dishName}" from today\'s log?',
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.sm.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(appStateProvider.notifier).deleteMeal(meal.id);
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(
              'Delete',
              style: AppTypography.sm.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          meal.dishName,
          style: AppTypography.base.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${meal.totalCalories.toInt()}',
                              style: AppTypography.display.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.accent,
                              ),
                            ),
                            Text('CALORIES', style: AppTypography.xs),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            meal.mealType.label,
                            style: AppTypography.xs.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MacroPill(label: 'Protein', grams: meal.totalProtein, color: AppColors.protein),
                        _MacroPill(label: 'Carbs', grams: meal.totalCarbs, color: AppColors.carbs),
                        _MacroPill(label: 'Fat', grams: meal.totalFat, color: AppColors.fat),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Ingredients & Portions',
                style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...meal.ingredients.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${item.displayQuantity == item.displayQuantity.toInt() ? item.displayQuantity.toInt() : item.displayQuantity} ${item.displayUnit} (${item.massGrams.toInt()}g)',
                              style: AppTypography.xs,
                            ),
                          ],
                        ),
                        Text(
                          '${item.calories.toInt()} kcal',
                          style: AppTypography.base.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Delete This Meal',
                variant: ButtonVariant.danger,
                size: ButtonSize.md,
                icon: Icons.delete_outline,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final double grams;
  final Color color;

  const _MacroPill({
    required this.label,
    required this.grams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${grams.toInt()}g',
          style: AppTypography.md.copyWith(fontWeight: FontWeight.w800, color: color),
        ),
        Text(label, style: AppTypography.xs),
      ],
    );
  }
}
