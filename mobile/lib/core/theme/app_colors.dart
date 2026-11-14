import 'package:flutter/material.dart';
import 'theme_extension.dart';

/// Centralized color tokens for the BSG Application as specified in the
/// BSG Full Implementation Plan.
/// Provides compile-time constants for classic palette while enabling
/// dynamic theme access via `context.appTheme` or `AppColors.of(context)`.
class AppColors {
  AppColors._();

  // Baseline Classic Constants (preserving compile-time const expressions)
  static const Color background = Color(0xFFF5F6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF171717);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF8A8A86);
  static const Color primaryAction = Color(0xFF222222);
  static const Color darkSurface = Color(0xFF303030);
  static const Color border = Color(0xFFE5E5E1);
  static const Color subtleSurface = Color(0xFFEEEEEA);
  static const Color disabledSurface = Color(0xFFE8E8E4);
  static const Color disabledText = Color(0xFFA3A3A0);

  // Limited Semantic Accents
  static const Color success = Color(0xFF287A52);
  static const Color warning = Color(0xFFA66A16);
  static const Color error = Color(0xFFB93838);
  static const Color info = Color(0xFF426B8A);

  // Semantic background tints for badges & chips
  static const Color successBg = Color(0xFFEAF5EE);
  static const Color warningBg = Color(0xFFFDF6E9);
  static const Color errorBg = Color(0xFFFDECEC);
  static const Color infoBg = Color(0xFFEBF3F8);

  // Click Smart Chart Reports System Palette
  static const Color reportPrimary = Color(0xFF159B3D);
  static const Color reportLightGreen = Color(0xFFD9F3E1);
  static const Color reportBackground = Color(0xFFF1F4F1);
  static const Color reportTextPrimary = Color(0xFF292929);
  static const Color reportTextSecondary = Color(0xFF777777);
  static const Color reportBorder = Color(0xFFE5E5E5);

  /// Convenient helper to access active theme colors dynamically from BuildContext.
  static AppThemeColors of(BuildContext context) => context.appTheme;
}
