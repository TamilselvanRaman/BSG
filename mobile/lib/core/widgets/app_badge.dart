import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum BadgeVariant { success, warning, error, info, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    Color bg;
    Color fg;

    if (theme.isDark) {
      switch (variant) {
        case BadgeVariant.success:
          bg = theme.success.withValues(alpha: 0.18);
          fg = theme.success;
          break;
        case BadgeVariant.warning:
          bg = theme.warning.withValues(alpha: 0.18);
          fg = theme.warning;
          break;
        case BadgeVariant.error:
          bg = theme.error.withValues(alpha: 0.18);
          fg = theme.error;
          break;
        case BadgeVariant.info:
          bg = theme.info.withValues(alpha: 0.18);
          fg = theme.info;
          break;
        case BadgeVariant.neutral:
          bg = theme.accent;
          fg = theme.textSecondary;
          break;
      }
    } else {
      switch (variant) {
        case BadgeVariant.success:
          bg = AppColors.successBg;
          fg = AppColors.success;
          break;
        case BadgeVariant.warning:
          bg = AppColors.warningBg;
          fg = AppColors.warning;
          break;
        case BadgeVariant.error:
          bg = AppColors.errorBg;
          fg = AppColors.error;
          break;
        case BadgeVariant.info:
          bg = AppColors.infoBg;
          fg = AppColors.info;
          break;
        case BadgeVariant.neutral:
          bg = theme.accent;
          fg = theme.textSecondary;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelMuted.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

