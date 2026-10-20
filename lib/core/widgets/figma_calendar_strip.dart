import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FigmaCalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool isArabic;

  const FigmaCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    // Current Monday as start of week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final weekDaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekDaysAr = ['إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final date = startOfWeek.add(Duration(days: i));
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          final label = isArabic ? weekDaysAr[i] : weekDaysEn[i];

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent
                      : (isToday ? AppColors.accentSubtle : Colors.transparent),
                  borderRadius: BorderRadius.circular(14),
                  border: isToday && !isSelected
                      ? Border.all(color: AppColors.accentBorder, width: 1.2)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.xs.copyWith(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isToday ? AppColors.accent : AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: AppTypography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isToday ? AppColors.accent : AppColors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
