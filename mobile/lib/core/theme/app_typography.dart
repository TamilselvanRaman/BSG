import 'package:flutter/material.dart';

/// Centralized Typography tokens as per BSG Implementation Plan:
/// - Page title: 22-24sp, semibold
/// - Section heading: 16-18sp, semibold
/// - Card title: 14-16sp, medium/semibold
/// - Body: 14sp
/// - Supporting label: 12sp
/// - Amounts: 20-26sp, semibold, tabular figures
///
/// NOTE: Font styles do not hardcode a single fixed color token so that they
/// dynamically inherit the contextual text color from the active theme
/// (light or dark mode) via `DefaultTextStyle` / `ThemeData.textTheme`.
class AppTypography {
  AppTypography._();

  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static const TextStyle labelMuted = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.2,
  );

  static const TextStyle amount = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -0.5,
  );

  static const TextStyle amountLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: -0.7,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}
