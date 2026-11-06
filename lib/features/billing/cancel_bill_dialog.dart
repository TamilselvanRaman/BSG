import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/bill.dart';

class CancelBillDialog extends StatefulWidget {
  final Bill bill;
  final void Function(String reason, String cancelledBy) onConfirm;

  const CancelBillDialog({
    super.key,
    required this.bill,
    required this.onConfirm,
  });

  @override
  State<CancelBillDialog> createState() => _CancelBillDialogState();
}

class _CancelBillDialogState extends State<CancelBillDialog> {
  final _reasonCtrl = TextEditingController();
  final _cancelledByCtrl = TextEditingController(text: 'Supervisor Ramanathan');
  String? _error;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _cancelledByCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_reasonCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a cancellation reason');
      return;
    }
    widget.onConfirm(
      _reasonCtrl.text.trim(),
      _cancelledByCtrl.text.trim().isNotEmpty ? _cancelledByCtrl.text.trim() : 'Admin',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasPayments = widget.bill.totalPaymentsApplied > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: AppColors.cardSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.dangerBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cancel Bill Confirmation', style: AppTypography.titleMedium),
                      Text(widget.bill.billNumber, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Informational Notice
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit & Integrity Rules:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• The bill is never deleted. It remains in history with a "Cancelled" status.\n'
                    '• Active sales totals are reversed in reports.\n'
                    '• Customer account ledger is updated with an auditable reversal credit.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),

            if (hasPayments) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.pendingBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.pending.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.pending),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Payments of ${CurrencyFormatter.format(widget.bill.totalPaymentsApplied)} have already been received. In production, an approved refund or advance-credit treatment is required.',
                        style: const TextStyle(fontSize: 11, color: AppColors.pending, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: 'Cancellation Reason *',
              hint: 'e.g. Weighbridge mismatch / Wrong buyer selected',
              controller: _reasonCtrl,
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 11)),
            ],

            const SizedBox(height: AppSpacing.md),

            CustomTextField(
              label: 'Authorized By',
              controller: _cancelledByCtrl,
            ),

            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Close',
                    isOutlined: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Confirm Cancel',
                    isDanger: true,
                    onPressed: _submit,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
