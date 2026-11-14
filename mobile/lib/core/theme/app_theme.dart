import 'package:flutter/material.dart';
import 'theme_extension.dart';
import 'app_theme_data.dart';

/// Centralized ThemeData entry point.
class AppTheme {
  AppTheme._();

  /// Default Classic Light Theme
  static ThemeData get lightTheme => AppThemeDataFactory.create(AppThemeColors.classic);

  /// Generates complete Material 3 ThemeData for any given AppThemeColors configuration
  static ThemeData fromTheme(AppThemeColors theme) {
    return AppThemeDataFactory.create(theme);
  }
}
