import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo Container
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.storefront_rounded,
                  size: 48,
                  color: AppColors.textOnPrimary,
                ),
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: AppSpacing.xxl),

            // Brand Title
            Text(
              'BSG',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.primaryGreen,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w900,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 6),

            Text(
              'Buyer & Seller Goods Management',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

            const SizedBox(height: AppSpacing.xl),

            // Demo Mode Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightGreenSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Interactive Demo Mode',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
