import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 36, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: 'Try Again',
                onPressed: onRetry,
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

