import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAction),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppSkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const AppSkeletonLoader({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = AppSpacing.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.subtleSurface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

