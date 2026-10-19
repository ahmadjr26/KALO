import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/meal.dart';
import '../../models/meal_ingredient.dart';
import '../../providers/app_state_provider.dart';
import 'edit_ingredient_sheet.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  final Meal initialMeal;

  const ScanResultScreen({
    super.key,
    required this.initialMeal,
  });

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late Meal _currentMeal;
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _currentMeal = widget.initialMeal;
    _selectedMealType = widget.initialMeal.mealType;
  }

  void _editIngredient(MealIngredient ingredient, int index) async {
    final updated = await showModalBottomSheet<MealIngredient>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditIngredientSheet(ingredient: ingredient),
    );

    if (updated != null && mounted) {
      setState(() {
        final updatedIngredients = List<MealIngredient>.from(_currentMeal.ingredients);
        updatedIngredients[index] = updated;
        _currentMeal = _currentMeal.copyWith(ingredients: updatedIngredients);
      });
    }
  }

  void _confirmAndLog() {
    final finalizedMeal = _currentMeal.copyWith(mealType: _selectedMealType);
    ref.read(appStateProvider.notifier).addMeal(finalizedMeal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.accent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${finalizedMeal.dishName} logged!',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.get('meal_breakdown', lang),
          style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<MealType>(
            initialValue: _selectedMealType,
            onSelected: (type) => setState(() => _selectedMealType = type),
            color: AppColors.surface,
            itemBuilder: (context) => MealType.values.map((type) {
              return PopupMenuItem(
                value: type,
                child: Text(type.label, style: const TextStyle(color: AppColors.text)),
              );
            }).toList(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedMealType.label,
                    style: AppTypography.xs.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      _currentMeal.dishName,
                      style: AppTypography.xl.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 14, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.get('visual_confidence', lang),
                          style: AppTypography.xs.copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_currentMeal.totalCalories.toInt()}',
                                      style: AppTypography.display.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                    Text('${AppStrings.get('consumed', lang)} (${AppStrings.get('kcal', lang)})', style: AppTypography.xs),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.eco_rounded, color: AppColors.accent, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_currentMeal.healthScore}/10',
                                          style: AppTypography.base.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(AppStrings.get('health_score', lang).toUpperCase(), style: AppTypography.xs),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _MacroPill(
                                label: AppStrings.get('protein', lang).toUpperCase(),
                                grams: _currentMeal.totalProtein,
                                color: AppColors.protein,
                              ),
                              _MacroPill(
                                label: AppStrings.get('carbs', lang).toUpperCase(),
                                grams: _currentMeal.totalCarbs,
                                color: AppColors.carbs,
                              ),
                              _MacroPill(
                                label: AppStrings.get('fat', lang).toUpperCase(),
                                grams: _currentMeal.totalFat,
                                color: AppColors.fat,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('nutritional_quality', lang),
                            style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          _FactorRow(label: AppStrings.get('added_sugar', lang), rating: AppStrings.get('optimal', lang), isGood: true),
                          const SizedBox(height: 8),
                          _FactorRow(label: AppStrings.get('processing_level', lang), rating: AppStrings.get('whole_ingredients', lang), isGood: true),
                          const SizedBox(height: 8),
                          _FactorRow(label: AppStrings.get('sodium_content', lang), rating: AppStrings.get('balanced', lang), isGood: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${AppStrings.get('plate_ingredients', lang)} (${_currentMeal.ingredients.length})',
                            style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get('tap_to_adjust', lang),
                          style: AppTypography.xs.copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ..._currentMeal.ingredients.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final MealIngredient item = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: InkWell(
                            onTap: () => _editIngredient(item, index),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: AppTypography.base.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.displayQuantity == item.displayQuantity.toInt() ? item.displayQuantity.toInt() : item.displayQuantity} ${item.displayUnit} (${item.massGrams.toInt()}g)',
                                          style: AppTypography.xs,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${item.calories.toInt()} kcal',
                                        style: AppTypography.base.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                      Text(
                                        'P: ${item.proteinG.toInt()}g  C: ${item.carbsG.toInt()}g  F: ${item.fatG.toInt()}g',
                                        style: AppTypography.xs,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: AppStrings.get('confirm_log_meal', lang),
                size: ButtonSize.lg,
                icon: Icons.check,
                onPressed: _confirmAndLog,
              ),
            ),
          ],
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
          style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800, color: color),
        ),
        Text(label, style: AppTypography.xs),
      ],
    );
  }
}

class _FactorRow extends StatelessWidget {
  final String label;
  final String rating;
  final bool isGood;

  const _FactorRow({
    required this.label,
    required this.rating,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.xs.copyWith(color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGood ? Icons.check_circle_outline : Icons.info_outline,
              size: 14,
              color: isGood ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: 6),
            Text(
              rating,
              style: AppTypography.xs.copyWith(
                color: isGood ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
