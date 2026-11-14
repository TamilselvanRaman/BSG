import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_extension.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Factory class to construct rich Material 3 ThemeData from AppThemeColors.
class AppThemeDataFactory {
  AppThemeDataFactory._();

  static ThemeData create(AppThemeColors theme) {
    final brightness = theme.isDark ? Brightness.dark : Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: theme.primary,
      onPrimary: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
      primaryContainer: theme.accent,
      onPrimaryContainer: theme.text,
      secondary: theme.secondary,
      onSecondary: Colors.white,
      secondaryContainer: theme.accent,
      onSecondaryContainer: theme.text,
      tertiary: theme.info,
      onTertiary: Colors.white,
      error: theme.error,
      onError: Colors.white,
      surface: theme.surface,
      onSurface: theme.text,
      onSurfaceVariant: theme.textSecondary,
      outline: theme.border,
      outlineVariant: theme.accent,
      surfaceContainerHighest: theme.background,
    );

    final overlayStyle = theme.isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: theme.surface,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: theme.surface,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    final textTheme = TextTheme(
      displayLarge: AppTypography.pageTitle.copyWith(color: theme.text),
      displayMedium: AppTypography.pageTitle.copyWith(color: theme.text),
      displaySmall: AppTypography.pageTitle.copyWith(color: theme.text),
      headlineLarge: AppTypography.pageTitle.copyWith(color: theme.text),
      headlineMedium: AppTypography.sectionHeading.copyWith(color: theme.text),
      headlineSmall: AppTypography.sectionHeading.copyWith(color: theme.text),
      titleLarge: AppTypography.pageTitle.copyWith(color: theme.text),
      titleMedium: AppTypography.cardTitle.copyWith(color: theme.text),
      titleSmall: AppTypography.cardTitle.copyWith(color: theme.textSecondary),
      bodyLarge: AppTypography.body.copyWith(color: theme.text),
      bodyMedium: AppTypography.body.copyWith(color: theme.text),
      bodySmall: AppTypography.bodySecondary.copyWith(color: theme.textSecondary),
      labelLarge: AppTypography.button.copyWith(color: theme.text),
      labelMedium: AppTypography.label.copyWith(color: theme.textSecondary),
      labelSmall: AppTypography.labelMuted.copyWith(color: theme.textMuted),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: theme.background,
      textTheme: textTheme,
      primaryColor: theme.primary,
      iconTheme: IconThemeData(color: theme.text),
      extensions: [theme],
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.background,
        foregroundColor: theme.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.pageTitle.copyWith(color: theme.text),
        systemOverlayStyle: overlayStyle,
        iconTheme: IconThemeData(color: theme.text),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: theme.text,
        unselectedLabelColor: theme.textSecondary,
        indicatorColor: theme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: theme.border,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: theme.primary,
        foregroundColor: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
        elevation: 2,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: theme.surface,
        modalBackgroundColor: theme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        color: theme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          side: BorderSide(color: theme.border, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: theme.border,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: theme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.border, width: 1.0),
        ),
        titleTextStyle: AppTypography.sectionHeading.copyWith(color: theme.text),
        contentTextStyle: AppTypography.body.copyWith(color: theme.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: theme.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: theme.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: theme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: theme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: BorderSide(color: theme.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: theme.textMuted, fontSize: 13),
        labelStyle: TextStyle(color: theme.textSecondary, fontSize: 13),
        floatingLabelStyle: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: theme.surface,
        indicatorColor: theme.accent,
        elevation: 4,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.text,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: theme.primary, size: 24);
          }
          return IconThemeData(color: theme.textSecondary, size: 24);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
