import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/widgets/app_button.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';
import '../../data/models/goods_entry.dart';

class WhatsappShareDialog extends StatelessWidget {
  final Bill bill;
  final Customer customer;
  final GoodsEntry? goodsEntry;

  const WhatsappShareDialog({
    super.key,
    required this.bill,
    required this.customer,
    this.goodsEntry,
  });

  String _buildMessage() {
    final buffer = StringBuffer();
    buffer.writeln('🌾 *BSG AGRO GOODS TRADING*');
    buffer.writeln('📍 Main Mandi Road, Salem / Erode, Tamil Nadu');
    buffer.writeln('📞 Contact: +91 98421 00000\n');

    buffer.writeln('📄 *INVOICE: ${bill.billNumber}*');
    buffer.writeln('📅 Date: ${DateFormatter.format(bill.billDate)}');
    buffer.writeln('👤 Buyer: *${customer.name}* (${customer.village})');
    if (goodsEntry != null) {
      buffer.writeln('📦 Lot No: ${goodsEntry!.lotNumber} | Goods: ${goodsEntry!.goodsName}');
    }
    buffer.writeln('--------------------------------');

    for (final item in bill.items) {
      buffer.writeln('• ${item.description}: ${item.weight > 0 ? '${item.weight.toStringAsFixed(0)} kg' : '${item.quantity.toStringAsFixed(0)} units'} @ ₹${item.rate.toStringAsFixed(0)} = ${CurrencyFormatter.format(item.lineTotal)}');
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('Subtotal: ${CurrencyFormatter.format(bill.subtotal)}');
    if (bill.labourCharge > 0) {
      buffer.writeln('Labour / Hamali: ${CurrencyFormatter.format(bill.labourCharge)}');
    }
    buffer.writeln('*Current Bill Total: ${CurrencyFormatter.format(bill.currentBillTotal)}*');

    if (bill.previousBalanceSnapshot > 0) {
      buffer.writeln('Previous Balance: ${CurrencyFormatter.format(bill.previousBalanceSnapshot)}');
      buffer.writeln('Gross Payable: ${CurrencyFormatter.format(bill.amountPayable)}');
    }

    buffer.writeln('--------------------------------');
    if (bill.initialPaymentApplied > 0) {
      buffer.writeln('✅ Initial Advance Deducted: -${CurrencyFormatter.format(bill.initialPaymentApplied)}');
    }
    if (bill.otherPaymentsApplied > 0) {
      buffer.writeln('✅ Other Payments Applied: -${CurrencyFormatter.format(bill.otherPaymentsApplied)}');
    }
    buffer.writeln('Total Paid: ${CurrencyFormatter.format(bill.totalPaymentsApplied)}');

    buffer.writeln('--------------------------------');
    if (bill.status == BillStatus.cancelled) {
      buffer.writeln('⚠️ *STATUS: BILL CANCELLED*');
    } else if (bill.excessCredit > 0) {
      buffer.writeln('✨ *BUYER ADVANCE / CREDIT: ${CurrencyFormatter.format(bill.excessCredit)}*');
    } else {
      buffer.writeln('🚨 *REMAINING DUE: ${CurrencyFormatter.format(bill.remainingBalance)}*');
    }
    buffer.writeln('\n🙏 Thank you for your business! Please settle outstanding balances promptly.');

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final message = _buildMessage();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: AppColors.cardSurface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Color(0xFF25D366), size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WhatsApp Bill Sharing', style: AppTypography.titleMedium),
                      Text('Send bill summary to ${customer.phone}', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Message Preview Box
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Copy Message',
                    isOutlined: true,
                    icon: Icons.copy,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('WhatsApp message copied to clipboard!'),
                          backgroundColor: AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Open WhatsApp',
                    icon: Icons.send,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening WhatsApp for ${customer.name} (${customer.phone}). Message copied!'),
                          backgroundColor: AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
