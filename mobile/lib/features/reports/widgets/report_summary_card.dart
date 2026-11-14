import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

class ReportSummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final Color? iconBg;

  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.isDark ? 0.2 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.25,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBg ?? theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Icon(icon, size: 14, color: accentColor ?? theme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accentColor ?? theme.text,
              letterSpacing: -0.3,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
