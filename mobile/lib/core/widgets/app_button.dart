import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum ButtonVariant { primary, secondary, outline, destructive, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = AppSpacing.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = theme.primary;
        fgColor = theme.isDark && theme.id == 'midnight' ? Colors.black : Colors.white;
        break;
      case ButtonVariant.secondary:
        bgColor = theme.accent;
        fgColor = theme.text;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = theme.text;
        borderSide = BorderSide(color: theme.border, width: 1.5);
        break;
      case ButtonVariant.destructive:
        bgColor = theme.error;
        fgColor = Colors.white;
        break;
      case ButtonVariant.text:
        bgColor = Colors.transparent;
        fgColor = theme.text;
        break;
    }

    if (onPressed == null && !isLoading) {
      bgColor = theme.isDark ? const Color(0xFF262C30) : const Color(0xFFE8E8E4);
      fgColor = theme.isDark ? const Color(0xFF5A6268) : const Color(0xFFA3A3A0);
      borderSide = BorderSide.none;
    }

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTypography.button.copyWith(color: fgColor),
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: borderSide,
      ),
      minimumSize: Size(isFullWidth ? double.infinity : 0, height ?? AppSpacing.buttonHeight),
    );

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: content,
    );
  }
}
