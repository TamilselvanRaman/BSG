import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isDanger;
  final bool isLoading;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isDanger = false,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDanger ? AppColors.danger : AppColors.primaryGreen;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? effectiveColor : AppColors.textOnPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(label),
      ],
    );

    Widget button;
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(color: effectiveColor.withValues(alpha: 0.5)),
        ),
        child: content,
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: AppColors.textOnPrimary,
        ),
        child: content,
      );
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }
    return button;
  }
}
