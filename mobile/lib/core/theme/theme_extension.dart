import 'package:flutter/material.dart';

/// Centralized application theme colors supporting the 5-Theme Customization System.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final String id;
  final String name;
  final String subtitle;
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color border;
  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final bool isDark;

  const AppThemeColors({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.border,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.isDark,
  });

  // -------------------------------------------------------------
  // THEME 01 – CLASSIC (CURRENT DEFAULT)
  // -------------------------------------------------------------
  static const AppThemeColors classic = AppThemeColors(
    id: 'classic',
    name: 'Classic Default',
    subtitle: 'Clean Grayscale & Business Slate',
    background: Color(0xFFF5F6F1),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF252525),
    secondary: Color(0xFF777777),
    accent: Color(0xFFE9EBE5),
    border: Color(0xFFE2E3DE),
    text: Color(0xFF171717),
    textSecondary: Color(0xFF666666),
    textMuted: Color(0xFF8A8A86),
    success: Color(0xFF287A52),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFA66A16),
    info: Color(0xFF426B8A),
    isDark: false,
  );

  // -------------------------------------------------------------
  // THEME 02 – FRESH GREEN WHITE
  // -------------------------------------------------------------
  static const AppThemeColors green = AppThemeColors(
    id: 'green',
    name: 'Fresh Green White',
    subtitle: 'Vibrant Agriculture & Clean White',
    background: Color(0xFFF1F7F2),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF159B45),
    secondary: Color(0xFF66756A),
    accent: Color(0xFFD9F1DF),
    border: Color(0xFFDCE8DF),
    text: Color(0xFF26352B),
    textSecondary: Color(0xFF66756A),
    textMuted: Color(0xFF849488),
    success: Color(0xFF159B45),
    error: Color(0xFFD32F2F),
    warning: Color(0xFFA66A16),
    info: Color(0xFF2E7D32),
    isDark: false,
  );

  // -------------------------------------------------------------
  // THEME 03 – EXECUTIVE NAVY BLUE
  // -------------------------------------------------------------
  static const AppThemeColors navy = AppThemeColors(
    id: 'navy',
    name: 'Executive Navy Blue',
    subtitle: 'Deep Corporate Night & Ocean Blue',
    background: Color(0xFF0B1220),
    surface: Color(0xFF14243B),
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF9CAFC8),
    accent: Color(0xFF1E3554),
    border: Color(0xFF263B59),
    text: Color(0xFFF5F7FB),
    textSecondary: Color(0xFF9CAFC8),
    textMuted: Color(0xFF6B82A3),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF38BDF8),
    isDark: true,
  );

  // -------------------------------------------------------------
  // THEME 04 – ROYAL BURGUNDY IVORY
  // -------------------------------------------------------------
  static const AppThemeColors burgundy = AppThemeColors(
    id: 'burgundy',
    name: 'Royal Burgundy Ivory',
    subtitle: 'Warm Luxury Burgundy & Soft Ivory',
    background: Color(0xFFFFF9F5),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF8B1538),
    secondary: Color(0xFF77717A),
    accent: Color(0xFFF4E2E5),
    border: Color(0xFFEAE3E3),
    text: Color(0xFF282329),
    textSecondary: Color(0xFF77717A),
    textMuted: Color(0xFF99939C),
    success: Color(0xFF287A52),
    error: Color(0xFFC62828),
    warning: Color(0xFFA66A16),
    info: Color(0xFF7C3AED),
    isDark: false,
  );

  // -------------------------------------------------------------
  // THEME 05 – MIDNIGHT DARK
  // -------------------------------------------------------------
  static const AppThemeColors midnight = AppThemeColors(
    id: 'midnight',
    name: 'Midnight Dark',
    subtitle: 'AMOLED Deep Charcoal & Amber Gold',
    background: Color(0xFF101214),
    surface: Color(0xFF1C2226),
    primary: Color(0xFFF59E0B),
    secondary: Color(0xFFA5ADB3),
    accent: Color(0xFF30383D),
    border: Color(0xFF353D42),
    text: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA5ADB3),
    textMuted: Color(0xFF737D84),
    success: Color(0xFF22C55E),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF38BDF8),
    isDark: true,
  );

  static const List<AppThemeColors> allThemes = [
    classic,
    green,
    navy,
    burgundy,
    midnight,
  ];

  static AppThemeColors fromId(String? id) {
    switch (id) {
      case 'green':
        return green;
      case 'navy':
        return navy;
      case 'burgundy':
        return burgundy;
      case 'midnight':
        return midnight;
      case 'classic':
      default:
        return classic;
    }
  }

  @override
  AppThemeColors copyWith({
    String? id,
    String? name,
    String? subtitle,
    Color? background,
    Color? surface,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? border,
    Color? text,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
    bool? isDark,
  }) {
    return AppThemeColors(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      border: border ?? this.border,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      id: t < 0.5 ? id : other.id,
      name: t < 0.5 ? name : other.name,
      subtitle: t < 0.5 ? subtitle : other.subtitle,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      border: Color.lerp(border, other.border, t) ?? border,
      text: Color.lerp(text, other.text, t) ?? text,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      success: Color.lerp(success, other.success, t) ?? success,
      error: Color.lerp(error, other.error, t) ?? error,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppThemeContextExtension on BuildContext {
  AppThemeColors get appTheme =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.classic;
}

