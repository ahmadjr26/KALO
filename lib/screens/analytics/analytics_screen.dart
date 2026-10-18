import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final intakes = [2050, 1980, 2120, 1890, 2250, 2100, 1920];
    const budget = 2150;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Nutrition Analytics',
          style: AppTypography.md.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Caloric Compliance',
                style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Average deficit maintained across 6 of 7 days.',
                style: AppTypography.xs,
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(days.length, (i) {
                        final val = intakes[i];
                        final double fraction = (val / 2500).clamp(0.1, 1.0);
                        final bool withinBudget = val <= budget;

                        return Column(
                          children: [
                            Container(
                              width: 28,
                              height: 140 * fraction,
                              decoration: BoxDecoration(
                                color: withinBudget ? AppColors.accent : AppColors.danger,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              days[i],
                              style: AppTypography.xs.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatTile(label: 'Avg Calories', value: '2,044 kcal'),
                        _StatTile(label: 'Avg Deficit', value: '-380 kcal', color: AppColors.accent),
                        _StatTile(label: 'Compliance', value: '86%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Macro Balance Breakdown',
                style: AppTypography.lg.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _MacroShareRow(label: 'Protein', percent: '32%', grams: '162g avg', color: AppColors.protein),
                    const SizedBox(height: 12),
                    _MacroShareRow(label: 'Carbohydrates', percent: '44%', grams: '215g avg', color: AppColors.carbs),
                    const SizedBox(height: 12),
                    _MacroShareRow(label: 'Healthy Fats', percent: '24%', grams: '58g avg', color: AppColors.fat),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                label: 'Export Nutrition Summary (PDF)',
                variant: ButtonVariant.secondary,
                size: ButtonSize.md,
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report generated and ready to share.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatTile({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.base.copyWith(
            fontWeight: FontWeight.w800,
            color: color ?? AppColors.text,
          ),
        ),
        Text(label, style: AppTypography.xs),
      ],
    );
  }
}

class _MacroShareRow extends StatelessWidget {
  final String label;
  final String percent;
  final String grams;
  final Color color;

  const _MacroShareRow({
    required this.label,
    required this.percent,
    required this.grams,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(label, style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        Row(
          children: [
            Text(grams, style: AppTypography.xs),
            const SizedBox(width: 12),
            Text(percent, style: AppTypography.sm.copyWith(fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ],
    );
  }
}
