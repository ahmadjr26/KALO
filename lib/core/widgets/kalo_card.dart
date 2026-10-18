import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KaloCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsDirectional padding;
  final VoidCallback? onTap;
  final bool hasGlow;
  final Color? borderColor;

  const KaloCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(20),
    this.onTap,
    this.hasGlow = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ??
        (hasGlow ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border);

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: effectiveBorderColor, width: hasGlow ? 1.5 : 1),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.accent.withValues(alpha: 0.1),
          highlightColor: AppColors.surfaceElevated.withValues(alpha: 0.3),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
