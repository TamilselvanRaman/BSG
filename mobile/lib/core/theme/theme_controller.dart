import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_extension.dart';
import 'theme_storage.dart';

/// Riverpod State Notifier for application-wide dynamic theme switching and persistence.
class ThemeController extends Notifier<AppThemeColors> {
  @override
  AppThemeColors build() {
    // Initial sync with storage
    _initFromStorage();
    return AppThemeColors.classic;
  }

  Future<void> _initFromStorage() async {
    final savedId = await ThemeStorage.loadThemeId();
    if (savedId != null && savedId.isNotEmpty) {
      final theme = AppThemeColors.fromId(savedId);
      _updateSystemOverlay(theme);
      state = theme;
    }
  }

  /// Changes the application theme immediately and saves the preference.
  Future<void> setTheme(String themeId) async {
    final theme = AppThemeColors.fromId(themeId);
    _updateSystemOverlay(theme);
    state = theme;
    await ThemeStorage.saveThemeId(themeId);
  }

  /// Resets theme to the Classic default theme.
  Future<void> resetToDefault() async {
    final defaultTheme = AppThemeColors.classic;
    _updateSystemOverlay(defaultTheme);
    state = defaultTheme;
    await ThemeStorage.clearThemeId();
  }

  void _updateSystemOverlay(AppThemeColors theme) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: theme.surface,
        systemNavigationBarIconBrightness: theme.isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}

/// Global provider for the active theme configuration
final themeControllerProvider =
    NotifierProvider<ThemeController, AppThemeColors>(ThemeController.new);
