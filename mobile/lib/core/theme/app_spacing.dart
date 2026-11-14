import 'package:flutter/material.dart';

/// Spacing and dimensions tokens as specified in Section 2:
/// - Base spacing unit: 4dp
/// - Typical page horizontal padding: 16dp
/// - Section gap: 20-24dp
/// - Card padding: 14-16dp
/// - Input height: 50-54dp
/// - Button height: 48-52dp
/// - Card radius: 12-16dp
/// - Input radius: 10-12dp
class AppSpacing {
  AppSpacing._();

  static const double unit = 4.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  static const double pageHorizontal = 16.0;
  static const double pageVertical = 16.0;
  static const double sectionGap = 20.0;
  static const double cardPadding = 16.0;

  static const double inputHeight = 52.0;
  static const double buttonHeight = 50.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));
}

