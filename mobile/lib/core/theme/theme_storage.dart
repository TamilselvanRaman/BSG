import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence manager for user's selected application theme.
class ThemeStorage {
  static const String _themeKey = 'bsg_selected_theme_id';

  /// Loads the saved theme ID from local storage.
  static Future<String?> loadThemeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_themeKey);
    } catch (_) {
      return null;
    }
  }

  /// Persists the selected theme ID to local storage.
  static Future<void> saveThemeId(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeId);
    } catch (_) {
      // Graceful fallback if storage fails
    }
  }

  /// Clears the saved theme ID (resets to default).
  static Future<void> clearThemeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
    } catch (_) {
      // Graceful fallback
    }
  }
}

