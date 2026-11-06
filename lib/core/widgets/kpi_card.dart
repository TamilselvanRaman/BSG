import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../formatters/currency_formatter.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.subtitle,
    this.subtitleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primaryGreen;
    final effectiveIconBgColor = iconBgColor ?? AppColors.lightGreenSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: effectiveIconBgColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: effectiveIconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(amount),
                style: AppTypography.currencyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: subtitleColor ?? AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
