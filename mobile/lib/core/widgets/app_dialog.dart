import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
        title: Text(title, style: AppTypography.cardTitle),
        content: Text(message, style: AppTypography.bodySecondary),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          AppButton(
            text: cancelLabel,
            variant: ButtonVariant.text,
            isFullWidth: false,
            height: 40,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          AppButton(
            text: confirmLabel,
            variant: isDestructive ? ButtonVariant.destructive : ButtonVariant.primary,
            isFullWidth: false,
            height: 40,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primaryAction,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusSm),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

