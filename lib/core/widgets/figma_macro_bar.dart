import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FigmaMacroBar extends StatelessWidget {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final bool isCompact;

  const FigmaMacroBar({
    super.key,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = proteinG + carbsG + fatG;
    final pPct = total > 0 ? (proteinG / total) : 0.33;
    final cPct = total > 0 ? (carbsG / total) : 0.33;
    final fPct = total > 0 ? (fatG / total) : 0.34;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Multi-segmented horizontal micro-bar matching Figma frames 1:740-742 & 1:825-833
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: isCompact ? 6 : 8,
            width: double.infinity,
            color: AppColors.surfaceMuted,
            child: Row(
              children: [
                Expanded(
                  flex: (pPct * 100).round().clamp(1, 100),
                  child: Container(color: AppColors.protein),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: (cPct * 100).round().clamp(1, 100),
                  child: Container(color: AppColors.carbs),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: (fPct * 100).round().clamp(1, 100),
                  child: Container(color: AppColors.fat),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Labels & values
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _MacroMetric(
              label: 'Protein',
              amount: '${proteinG.round()}g',
              color: AppColors.protein,
              isCompact: isCompact,
            ),
            _MacroMetric(
              label: 'Carbs',
              amount: '${carbsG.round()}g',
              color: AppColors.carbs,
              isCompact: isCompact,
            ),
            _MacroMetric(
              label: 'Fat',
              amount: '${fatG.round()}g',
              color: AppColors.fat,
              isCompact: isCompact,
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroMetric extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool isCompact;

  const _MacroMetric({
    required this.label,
    required this.amount,
    required this.color,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label ',
          style: AppTypography.xs.copyWith(
            fontSize: isCompact ? 10 : 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: AppTypography.xs.copyWith(
            fontSize: isCompact ? 10 : 11,
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
