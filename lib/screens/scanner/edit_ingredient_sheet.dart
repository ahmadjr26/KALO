import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/meal_ingredient.dart';

class EditIngredientSheet extends StatefulWidget {
  final MealIngredient ingredient;

  const EditIngredientSheet({
    super.key,
    required this.ingredient,
  });

  @override
  State<EditIngredientSheet> createState() => _EditIngredientSheetState();
}

class _EditIngredientSheetState extends State<EditIngredientSheet> {
  late double _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.ingredient.displayQuantity;
  }

  void _step(double delta) {
    setState(() {
      final updated = (_quantity + delta);
      if (updated > 0.1) {
        _quantity = double.parse(updated.toStringAsFixed(1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final updatedItem = widget.ingredient.scale(_quantity);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderInput,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Adjust Portion',
            style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.ingredient.name,
            style: AppTypography.sm.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  onTap: () => _step(-0.5),
                ),
                Column(
                  children: [
                    Text(
                      '${_quantity == _quantity.toInt() ? _quantity.toInt() : _quantity}',
                      style: AppTypography.display.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${widget.ingredient.displayUnit} (${updatedItem.massGrams.toInt()}g)',
                      style: AppTypography.xs.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
                _StepperButton(
                  icon: Icons.add,
                  onTap: () => _step(0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroMetric(
                label: 'Calories',
                value: '${updatedItem.calories.toInt()} kcal',
                color: AppColors.accent,
              ),
              _MacroMetric(
                label: 'Protein',
                value: '${updatedItem.proteinG.toInt()}g',
                color: AppColors.protein,
              ),
              _MacroMetric(
                label: 'Carbs',
                value: '${updatedItem.carbsG.toInt()}g',
                color: AppColors.carbs,
              ),
              _MacroMetric(
                label: 'Fats',
                value: '${updatedItem.fatG.toInt()}g',
                color: AppColors.fat,
              ),
            ],
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Save Changes',
                  onPressed: () => Navigator.of(context).pop(updatedItem),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 24, color: AppColors.text),
        ),
      ),
    );
  }
}

class _MacroMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.sm.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: AppTypography.xs),
      ],
    );
  }
}
