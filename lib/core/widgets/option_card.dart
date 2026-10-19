import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const OptionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.emoji,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.accent.withAlpha(25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.surface
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentBorder
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 20,
                          color: isSelected ? AppColors.accent : AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.accent : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentSubtle : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.accent.withAlpha(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surface
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentBorder
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected ? AppColors.accent : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ] else if (emoji != null) ...[
                  Text(emoji!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTypography.base.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.xs.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.borderInput,
                      width: 1.5,
                    ),
                    color: isSelected ? AppColors.accent : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(Icons.check, size: 14, color: AppColors.onAccent),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
