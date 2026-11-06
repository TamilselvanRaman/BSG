import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/app_button.dart';
import '../../data/app_state.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        backgroundColor: AppColors.cardSurface,
        title: const Row(
          children: [
            Icon(Icons.restart_alt, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Reset Demo Data?', style: AppTypography.titleMedium),
          ],
        ),
        content: const Text(
          'This action will restore all fictional buyers, goods entries, bills, and payments back to the original demo dataset.\n\nAny records created during this demonstration will be re-initialized.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              ref.read(appStateProvider.notifier).resetDemoData();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo records successfully reset to original seed dataset.'),
                  backgroundColor: AppColors.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset Dataset', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Application Settings'),
      ),
      body: ResponsiveContainer(
        maxWidth: 800,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Business Profile Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreenSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.business_outlined, color: AppColors.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BSG Agro Goods Trading', style: AppTypography.titleMedium),
                            Text('Mandi & Commission Mundy Management', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _settingTile(Icons.phone_outlined, 'Helpline Phone', '+91 98421 00000'),
                  _settingTile(Icons.location_on_outlined, 'Registered Address', 'Main Mandi Complex, Salem / Erode, TN - 636001'),
                  _settingTile(Icons.badge_outlined, 'Mandi License / GST', '33AABCT9988D1Z2'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Billing & System Configuration
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Preferences', style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  _settingTile(Icons.receipt_outlined, 'Bill Number Prefix', 'BILL-2026-'),
                  _settingTile(Icons.currency_rupee, 'Default Currency', 'Indian Rupee (₹ - INR)'),
                  _settingTile(Icons.schedule_outlined, 'Business Timezone', 'Asia/Kolkata (IST +05:30)'),
                  _settingTile(Icons.palette_outlined, 'Design System', 'BSG Green & White Theme'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Demo Mode Management Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.lightGreenSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: AppColors.textOnPrimary, size: 14),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'Interactive Demo Mode Active',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primaryGreenDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All calculations and balances are computed authoritatively in real time from the local repository. You can create, edit, bill, pay, and cancel records freely.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Reset Demo Data to Default',
                    isDanger: true,
                    isOutlined: true,
                    icon: Icons.restart_alt,
                    width: double.infinity,
                    onPressed: () => _showResetConfirmation(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // About Brand
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Application', style: AppTypography.titleMedium),
                  SizedBox(height: 8),
                  Text(
                    'Buyer & Seller Goods Management Application MVP\n'
                    'Developed under the BSG enterprise brand.\n'
                    'Version: 1.0.0 (Client Demonstration Release)',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    ),
  );
}

  Widget _settingTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
