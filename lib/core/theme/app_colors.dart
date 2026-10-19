import 'package:flutter/material.dart';

abstract final class AppColors {
  // Surfaces & Backgrounds (Light-first, clean white & warm neutral)
  static const Color bg = Color(0xFFF8FAF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color surfaceMuted = Color(0xFFF3F4F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderInput = Color(0xFFCBD5E1);

  // Typography & Content
  static const Color text = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF94A3B8);

  // Brand Accent (Carefully controlled clinical emerald - never neon)
  static const Color accent = Color(0xFF059669);
  static const Color accentHover = Color(0xFF047857);
  static const Color accentSubtle = Color(0xFFECFDF5);
  static const Color accentBorder = Color(0xFFA7F3D0);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color danger = Color(0xFFE11D48);
  static const Color dangerSubtle = Color(0xFFFFF1F2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSubtle = Color(0xFFFFFBEB);
  static const Color success = Color(0xFF059669);
  static const Color successSubtle = Color(0xFFECFDF5);

  // Nutritional Macro Tokens
  static const Color protein = Color(0xFF2563EB); // Cobalt Blue
  static const Color proteinSubtle = Color(0xFFEFF6FF);
  static const Color carbs = Color(0xFFD97706); // Warm Amber
  static const Color carbsSubtle = Color(0xFFFFFBEB);
  static const Color fat = Color(0xFFE11D48); // Rose
  static const Color fatSubtle = Color(0xFFFFF1F2);
  static const Color calories = Color(0xFF059669); // Emerald
  static const Color water = Color(0xFF0284C7); // Sky Blue
  static const Color waterSubtle = Color(0xFFF0F9FF);

  // Aliases for compatibility
  static const Color accentGlow = Color(0xFF10B981);
  static const Color lightBg = bg;
  static const Color lightSurface = surface;
  static const Color lightSurfaceElevated = surfaceElevated;
  static const Color lightBorder = border;
  static const Color lightBorderInput = borderInput;
  static const Color lightText = text;
  static const Color lightTextMuted = textMuted;
  static const Color lightAccent = accent;
  static const Color lightOnAccent = onAccent;
}
