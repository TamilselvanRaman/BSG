import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum BadgeType {
  success,
  pending,
  danger,
  info,
  initialPayment,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  factory StatusBadge.fromBillStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const StatusBadge(label: 'Paid', type: BadgeType.success, icon: Icons.check_circle_outline);
      case 'partiallypaid':
      case 'partially paid':
        return const StatusBadge(label: 'Partially Paid', type: BadgeType.pending, icon: Icons.access_time);
      case 'unpaid':
        return const StatusBadge(label: 'Unpaid', type: BadgeType.danger, icon: Icons.error_outline);
      case 'cancelled':
        return const StatusBadge(label: 'Cancelled', type: BadgeType.danger, icon: Icons.cancel_outlined);
      default:
        return StatusBadge(label: status, type: BadgeType.neutral);
    }
  }

  factory StatusBadge.fromCustomerType(String type) {
    switch (type.toLowerCase()) {
      case 'buyer':
        return const StatusBadge(label: 'Buyer', type: BadgeType.info, icon: Icons.shopping_bag_outlined);
      case 'seller':
        return const StatusBadge(label: 'Seller', type: BadgeType.success, icon: Icons.agriculture_outlined);
      case 'both':
        return const StatusBadge(label: 'Buyer & Seller', type: BadgeType.initialPayment, icon: Icons.sync_alt);
      default:
        return StatusBadge(label: type, type: BadgeType.neutral);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case BadgeType.pending:
        bg = AppColors.pendingBg;
        fg = AppColors.pending;
        break;
      case BadgeType.danger:
        bg = AppColors.dangerBg;
        fg = AppColors.danger;
        break;
      case BadgeType.info:
        bg = AppColors.infoBg;
        fg = AppColors.infoBlue;
        break;
      case BadgeType.initialPayment:
        bg = AppColors.initialPaymentBg;
        fg = AppColors.initialPaymentBadge;
        break;
      case BadgeType.neutral:
        bg = AppColors.elevatedSurface;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
