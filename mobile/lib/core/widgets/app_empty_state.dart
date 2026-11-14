import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.subtleSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                isFullWidth: false,
                variant: ButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

