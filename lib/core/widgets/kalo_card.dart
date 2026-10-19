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
    this.padding = const EdgeInsetsDirectional.all(18),
    this.onTap,
    this.hasGlow = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ??
        (hasGlow ? AppColors.accent : AppColors.border);

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: effectiveBorderColor, width: hasGlow ? 1.5 : 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.accent.withAlpha(20),
          highlightColor: AppColors.surfaceElevated,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
