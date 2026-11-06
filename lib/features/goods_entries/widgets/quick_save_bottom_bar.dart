import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/formatters/currency_formatter.dart';

class QuickSaveBottomBar extends StatelessWidget {
  final double totalAmount;
  final double netDue;
  final bool isSaving;
  final VoidCallback onSaveConfirmed;
  final VoidCallback onSaveDraft;

  const QuickSaveBottomBar({
    super.key,
    required this.totalAmount,
    required this.netDue,
    required this.isSaving,
    required this.onSaveConfirmed,
    required this.onSaveDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Live Summary on the left
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NET BALANCE DUE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    CurrencyFormatter.format(netDue > 0 ? netDue : 0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                  Text(
                    'Gross Value: ${CurrencyFormatter.format(totalAmount)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Secondary: Save Draft
            OutlinedButton(
              onPressed: isSaving ? null : onSaveDraft,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                side: const BorderSide(color: AppColors.border, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              ),
              child: const Text(
                'Draft',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Primary: Confirm & Save
            ElevatedButton.icon(
              onPressed: isSaving ? null : onSaveConfirmed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              ),
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                isSaving ? 'Saving...' : 'Confirm Entry',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
