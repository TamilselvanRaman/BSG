import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_button.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.lightGreenSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: buttonLabel!,
                onPressed: onButtonPressed!,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
