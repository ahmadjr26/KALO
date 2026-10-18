import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, secondary, ghost, danger }
enum ButtonSize { sm, md, lg }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double height = switch (size) {
      ButtonSize.sm => 36.0,
      ButtonSize.md => 48.0,
      ButtonSize.lg => 56.0,
    };

    final double fontSize = switch (size) {
      ButtonSize.sm => 13.0,
      ButtonSize.md => 15.0,
      ButtonSize.lg => 16.0,
    };

    Color bgColor = switch (variant) {
      ButtonVariant.primary => AppColors.accent,
      ButtonVariant.secondary => AppColors.surface,
      ButtonVariant.ghost => Colors.transparent,
      ButtonVariant.danger => AppColors.danger,
    };

    Color textColor = switch (variant) {
      ButtonVariant.primary => AppColors.onAccent,
      ButtonVariant.secondary => AppColors.text,
      ButtonVariant.ghost => AppColors.textMuted,
      ButtonVariant.danger => Colors.black,
    };

    BorderSide border = switch (variant) {
      ButtonVariant.secondary => const BorderSide(color: AppColors.border, width: 1),
      _ => BorderSide.none,
    };

    return SizedBox(
      height: height,
      child: Material(
        color: onPressed == null || isLoading ? bgColor.withAlpha(120) : bgColor,
        shape: StadiumBorder(side: border),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          splashColor: Colors.white.withAlpha(40),
          highlightColor: Colors.white.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: fontSize + 2, color: textColor),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
