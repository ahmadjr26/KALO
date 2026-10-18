import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final double currentGrams;
  final double targetGrams;
  final Color color;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.currentGrams,
    required this.targetGrams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = targetGrams > 0
        ? (currentGrams / targetGrams).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              '${currentGrams.toInt()}g / ${targetGrams.toInt()}g',
              style: AppTypography.xs.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 8,
            width: double.infinity,
            color: AppColors.border,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
