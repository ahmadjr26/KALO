import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle font({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
    bool isArabic = false,
  }) {
    if (isArabic) {
      return GoogleFonts.cairo(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.poppins(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle displayHeadline({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
    bool isArabic = false,
  }) {
    if (isArabic) {
      return GoogleFonts.cairo(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.quicksand(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle get xs => font(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  static TextStyle get sm => font(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get base => font(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
      );

  static TextStyle get md => font(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  static TextStyle get lg => font(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );

  static TextStyle get xl => font(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      );

  static TextStyle get display => displayHeadline(
        fontSize: 38,
        height: 44 / 38,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.text,
      );

  static TextStyle xsArabic([Color? color]) => font(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textMuted,
        isArabic: true,
      );

  static TextStyle smArabic([Color? color]) => font(
        fontSize: 14,
        height: 22 / 14,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.text,
        isArabic: true,
      );

  static TextStyle baseArabic([Color? color]) => font(
        fontSize: 16,
        height: 26 / 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.text,
        isArabic: true,
      );

  static TextStyle mdArabic([Color? color]) => font(
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.text,
        isArabic: true,
      );

  static TextStyle lgArabic([Color? color]) => font(
        fontSize: 20,
        height: 30 / 20,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.text,
        isArabic: true,
      );

  static TextStyle displayArabic([Color? color]) => font(
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w900,
        color: color ?? AppColors.text,
        isArabic: true,
      );
}
