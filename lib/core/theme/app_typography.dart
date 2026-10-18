import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get xs => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  static TextStyle get sm => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get base => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  static TextStyle get md => GoogleFonts.inter(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  static TextStyle get lg => GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );

  static TextStyle get xl => GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      );

  static TextStyle get display => GoogleFonts.inter(
        fontSize: 38,
        height: 44 / 38,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.text,
      );
}
