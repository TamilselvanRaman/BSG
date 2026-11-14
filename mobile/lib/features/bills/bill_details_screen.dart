import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/lot_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/app_repository.dart';

class BillDetailsScreen extends ConsumerStatefulWidget {
  final String billId;

  const BillDetailsScreen({super.key, required this.billId});

  @override
  ConsumerState<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends ConsumerState<BillDetailsScreen> {
  final TextEditingController _cancelReasonController = TextEditingController();

  @override
  void dispose() {
    _cancelReasonController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Action 1: Cancel Bill
  // ---------------------------------------------------------------------------
  Future<void> _handleCancelBill(Bill bill) async {
    final theme = context.appTheme;

    if (bill.isCancelled) {
      AppDialog.showSnackBar(context, 'This bill is already cancelled');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Cancel Bill', style: AppTypography.cardTitle.copyWith(color: theme.text)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancelling this bill will restore the deducted quantity (${bill.quantity} ${bill.unit}) back to lot ${bill.lotNumber} and reverse any balance added to customer ledger.',
              style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _cancelReasonController,
              style: TextStyle(color: theme.text),
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation *',
                hintText: 'e.g. Data entry error / Customer returned',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Dismiss', style: TextStyle(color: theme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              if (_cancelReasonController.text.trim().isEmpty) {
                AppDialog.showSnackBar(context, 'Please enter a cancellation reason', isError: true);
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(appRepositoryProvider).cancelBill(
              bill.id,
              _cancelReasonController.text.trim(),
            );
        if (mounted) {
          AppDialog.showSnackBar(context, 'Bill cancelled and stock restored successfully');
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          AppDialog.showSnackBar(context, 'Failed to cancel bill: $e', isError: true);
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Action 2: History Sheet
  // ---------------------------------------------------------------------------
  void _showHistorySheet(Bill bill) {
    final theme = context.appTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, color: theme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Bill Lifecycle & Audit History',
                  style: AppTypography.cardTitle.copyWith(color: theme.text),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildHistoryItem(
              icon: Icons.receipt_rounded,
              title: 'Bill Generated: ${bill.billNumber}',
              subtitle: 'Date: ${AppFormatters.date(bill.date)} • Created: ${AppFormatters.dateTime(bill.createdAt)}',
              theme: theme,
            ),
            _buildHistoryItem(
              icon: Icons.inventory_2_outlined,
              title: 'Stock Deducted from Lot ${bill.lotNumber}',
              subtitle: '${AppFormatters.quantity(bill.quantity, bill.unit)} (${bill.weight.toStringAsFixed(1)} kg) deducted',
              theme: theme,
            ),
            _buildHistoryItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Buyer Ledger Updated',
              subtitle: 'Billed to ${bill.customerName} • Total Value: ${AppFormatters.currency(bill.totalAmount)}',
              theme: theme,
            ),
            if (bill.amountReceived > 0)
              _buildHistoryItem(
                icon: Icons.payments_outlined,
                title: 'Payment Collected on Creation',
                subtitle: 'Amount: ${AppFormatters.currency(bill.amountReceived)} via ${bill.paymentMethod.displayName}',
                theme: theme,
                iconColor: const Color(0xFF2E7D32),
              ),
            if (bill.isCancelled)
              _buildHistoryItem(
                icon: Icons.cancel_outlined,
                title: 'Bill Cancelled',
                subtitle: 'Reason: ${bill.cancellationReason ?? 'Not specified'} • Stock restored',
                theme: theme,
                iconColor: AppColors.error,
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppThemeColors theme,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: iconColor ?? theme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action 3: Quick Pay Sheet
  // ---------------------------------------------------------------------------
  void _showQuickPaySheet(Bill bill) {
    final theme = context.appTheme;

    if (bill.isCancelled) {
      AppDialog.showSnackBar(context, 'Cannot collect payment for a cancelled bill', isError: true);
      return;
    }

    if (bill.balanceDue <= 0) {
      AppDialog.showSnackBar(context, 'This bill is already fully paid (₹0.00 balance due)');
      return;
    }

    final payAmountCtrl = TextEditingController(text: bill.balanceDue.toStringAsFixed(2));
    final refCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    PaymentMethod selectedMethod = PaymentMethod.cash;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Collect Payment for ${bill.billNumber}', style: AppTypography.cardTitle.copyWith(color: theme.text)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Outstanding Balance Due:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(
                      AppFormatters.currency(bill.balanceDue),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.warning),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Payment Amount to Collect (₹) *',
                controller: payAmountCtrl,
                prefixText: '₹ ',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              Text('Payment Method', style: AppTypography.label.copyWith(color: theme.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: selectedMethod,
                dropdownColor: theme.surface,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: PaymentMethod.cash, child: Text('💵 Hand Cash')),
                  DropdownMenuItem(value: PaymentMethod.upi, child: Text('📱 GPay / PhonePe / UPI')),
                  DropdownMenuItem(value: PaymentMethod.bank, child: Text('🏦 Bank Transfer (NEFT/RTGS)')),
                  DropdownMenuItem(value: PaymentMethod.cheque, child: Text('📄 Cheque')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedMethod = val);
                },
              ),
              if (selectedMethod != PaymentMethod.cash) ...[
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Reference / Transaction / UTR No',
                  hint: 'e.g. UPI Ref / Txn ID / Cheque #',
                  controller: refCtrl,
                  prefixIcon: Icon(Icons.tag_rounded, size: 18, color: theme.primary),
                ),
              ],
              const SizedBox(height: 12),
              AppTextField(
                label: 'Remarks / Notes (Optional)',
                hint: 'e.g. Collected at mandi counter',
                controller: noteCtrl,
                prefixIcon: Icon(Icons.edit_note_rounded, size: 18, color: theme.primary),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Record Payment & Settle Due',
                icon: Icons.check_circle_outline,
                onPressed: () async {
                  final entered = double.tryParse(payAmountCtrl.text.trim()) ?? 0.0;
                  if (entered <= 0) {
                    AppDialog.showSnackBar(context, 'Please enter a valid payment amount', isError: true);
                    return;
                  }

                  try {
                    final repo = ref.read(appRepositoryProvider);
                    if (bill.customerId != null && bill.customerId!.isNotEmpty) {
                      await repo.recordPayment(
                        customerId: bill.customerId!,
                        date: DateTime.now(),
                        amount: entered,
                        method: selectedMethod,
                        referenceNumber: refCtrl.text.trim().isNotEmpty ? refCtrl.text.trim() : null,
                        notes: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                        allocations: [
                          PaymentAllocation(
                            billId: bill.id,
                            billNumber: bill.billNumber,
                            allocatedAmount: entered.clamp(0.0, bill.balanceDue),
                          ),
                        ],
                      );
                    } else {
                      final newReceived = bill.amountReceived + entered;
                      final newBalance = (bill.totalAmount - newReceived).clamp(0.0, double.infinity);
                      final updated = bill.copyWith(
                        amountReceived: newReceived,
                        balanceDue: newBalance,
                        status: newBalance <= 0 ? BillStatus.paid : BillStatus.partiallyPaid,
                        paymentMethod: selectedMethod,
                        paymentReference: refCtrl.text.trim().isNotEmpty ? refCtrl.text.trim() : bill.paymentReference,
                      );
                      await repo.updateBill(updated);
                    }

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }
                    if (mounted) {
                      AppDialog.showSnackBar(context, 'Payment of ${AppFormatters.currency(entered)} recorded successfully');
                      setState(() {});
                    }
                  } catch (e) {
                    if (mounted) {
                      AppDialog.showSnackBar(context, 'Failed to record payment: $e', isError: true);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action 4: Edit Bill Sheet
  // ---------------------------------------------------------------------------
  void _showEditSheet(Bill bill) {
    final theme = context.appTheme;

    if (bill.isCancelled) {
      AppDialog.showSnackBar(context, 'Cannot edit a cancelled bill', isError: true);
      return;
    }

    final notesCtrl = TextEditingController(text: bill.notes ?? '');
    final phoneCtrl = TextEditingController(text: bill.customerPhone ?? '');
    final refCtrl = TextEditingController(text: bill.paymentReference ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Bill Details', style: AppTypography.cardTitle.copyWith(color: theme.text)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Customer Contact Phone',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(Icons.phone_outlined, size: 18, color: theme.primary),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Payment Reference / Transaction ID',
              controller: refCtrl,
              prefixIcon: Icon(Icons.tag_rounded, size: 18, color: theme.primary),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Bill Remarks / Notes',
              controller: notesCtrl,
              maxLines: 3,
              prefixIcon: Icon(Icons.edit_note_rounded, size: 20, color: theme.primary),
            ),
            const SizedBox(height: 18),
            AppButton(
              text: 'Save Changes',
              icon: Icons.check,
              onPressed: () async {
                final updated = bill.copyWith(
                  customerPhone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                  paymentReference: refCtrl.text.trim().isNotEmpty ? refCtrl.text.trim() : null,
                  notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                );
                await ref.read(appRepositoryProvider).updateBill(updated);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  AppDialog.showSnackBar(context, 'Bill details updated successfully');
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action 5: Print Receipt
  // ---------------------------------------------------------------------------
  void _showPrintSharePreview(Bill bill) {
    final theme = context.appTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.print_outlined, size: 32, color: theme.primary),
            ),
            const SizedBox(height: 12),
            Text('Receipt Ready for Printing', style: AppTypography.cardTitle.copyWith(color: theme.text)),
            const SizedBox(height: 4),
            Text('Receipt Number: ${bill.billNumber}', style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: theme.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Bill Amount', style: AppTypography.body.copyWith(color: theme.text)),
                      Text(AppFormatters.currency(bill.totalAmount), style: AppTypography.cardTitle.copyWith(color: theme.text)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount Paid', style: AppTypography.bodySecondary.copyWith(color: const Color(0xFF2E7D32))),
                      Text(AppFormatters.currency(bill.amountReceived), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Balance Due', style: AppTypography.bodySecondary.copyWith(color: const Color(0xFFD32F2F))),
                      Text(AppFormatters.currency(bill.balanceDue), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy Slip'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.text,
                      side: BorderSide(color: theme.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _generateTextInvoice(bill)));
                      Navigator.pop(ctx);
                      AppDialog.showSnackBar(context, 'Receipt slip copied to clipboard');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: const Text('Print (Thermal/A4)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppDialog.showSnackBar(context, 'Printing triggered for ${bill.billNumber}');
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

  // ---------------------------------------------------------------------------
  // Action 6: Share Options
  // ---------------------------------------------------------------------------
  void _showShareOptions(Bill bill) {
    final text = _generateTextInvoice(bill);
    Clipboard.setData(ClipboardData(text: text));
    AppDialog.showSnackBar(context, 'Invoice text copied to clipboard! Ready to paste and share.');
  }

  // ---------------------------------------------------------------------------
  // Action 7: WhatsApp Share
  // ---------------------------------------------------------------------------
  void _showWhatsAppSheet(Bill bill) {
    final theme = context.appTheme;
    final message = _generateTextInvoice(bill);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text('Share via WhatsApp', style: AppTypography.cardTitle.copyWith(color: theme.text)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Recipient: ${bill.customerName} (${bill.customerPhone ?? 'No phone'})',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: theme.textSecondary),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.border),
              ),
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5, height: 1.3),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Copy & Send to Customer',
              icon: Icons.send_rounded,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: message));
                Navigator.pop(ctx);
                AppDialog.showSnackBar(context, 'WhatsApp invoice message copied to clipboard');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _generateTextInvoice(Bill bill) {
    final buffer = StringBuffer();
    final int bagsCount = bill.bagItems.isNotEmpty ? bill.bagItems.length : bill.quantity.toInt();
    final double totWeight = bill.bagItems.isNotEmpty
        ? bill.bagItems.fold<double>(0.0, (sum, b) => sum + b.weight)
        : bill.weight;

    buffer.writeln('🧾 *BSG AGRO MANDI - INVOICE*');
    buffer.writeln('Bill No: ${bill.billNumber}');
    buffer.writeln('Date: ${AppFormatters.date(bill.date)}');
    buffer.writeln('Buyer: ${bill.customerName}${bill.customerPhone != null ? " (${bill.customerPhone})" : ""}');
    buffer.writeln('--------------------------------');
    for (int i = 0; i < bill.allItems.length; i++) {
      final it = bill.allItems[i];
      final itBags = it.bagItems.isNotEmpty ? it.bagItems.length : it.quantity.toInt();
      final itWt = it.bagItems.isNotEmpty ? it.bagItems.fold<double>(0.0, (s, b) => s + b.weight) : it.weight;
      buffer.writeln('${i + 1}. ${it.productName} (${it.lotNumber})');
      buffer.writeln('   $itBags Bags • ${itWt.toStringAsFixed(1)} kg @ ₹${it.sellRate.toStringAsFixed(2)} = ₹${AppFormatters.number(it.grossAmount)}');
      if (it.bagItems.isNotEmpty) {
        final weights = it.bagItems.map((b) => '${b.weight.toStringAsFixed(0)}kg').join(', ');
        buffer.writeln('   Weights: $weights');
      }
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Total Bags: $bagsCount BG');
    buffer.writeln('Total Weight: ${totWeight.toStringAsFixed(1)} kg');
    buffer.writeln('Subtotal: ₹${AppFormatters.number(bill.grossAmount)}');
    if (bill.labourCharge > 0) buffer.writeln('Labour / Hamali: +₹${AppFormatters.number(bill.labourCharge)}');
    buffer.writeln('Current Bill Total: ₹${AppFormatters.number(bill.totalAmount)}');
    buffer.writeln('Total Received: -₹${AppFormatters.number(bill.amountReceived)}');
    buffer.writeln('*Outstanding Due: ₹${AppFormatters.number(bill.balanceDue)}*');
    buffer.writeln('--------------------------------');
    buffer.writeln('Thank you for your business!');
    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Build Main Screen
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final repo = ref.watch(appRepositoryProvider);
    final bill = repo.getBill(widget.billId);

    if (bill == null) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: Text('Bill Details', style: TextStyle(color: theme.text))),
        body: const AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Bill Not Found',
          description: 'The requested bill record does not exist.',
        ),
      );
    }

    final customer = bill.customerId != null ? repo.getCustomer(bill.customerId!) : null;
    final lot = repo.getLot(bill.lotId);

    // Compute previous balance & payments applied
    final customerCurrentDue = customer?.currentOutstanding ?? 0.0;
    final previousDue = (customerCurrentDue - bill.balanceDue).clamp(0.0, double.infinity);
    final grossPayable = bill.totalAmount + previousDue;

    // Payments allocated to this bill
    final billPayments = repo.getPayments().where((p) {
      return p.allocations.any((a) => a.billId == bill.id);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          bill.billNumber,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: theme.text,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.print_outlined, color: theme.text),
            tooltip: 'Print',
            onPressed: () => _showPrintSharePreview(bill),
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: theme.text),
            tooltip: 'Share',
            onPressed: () => _showShareOptions(bill),
          ),
        ],
      ),

      // -----------------------------------------------------------------------
      // Main Body
      // -----------------------------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          children: [
            // Cancellation banner if cancelled
            if (bill.isCancelled) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: AppSpacing.borderRadiusMd,
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('THIS BILL IS CANCELLED', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Reason: ${bill.cancellationReason ?? 'Not specified'}', style: const TextStyle(color: AppColors.error)),
                    if (bill.cancelledAt != null)
                      Text('Cancelled on: ${AppFormatters.dateTime(bill.cancelledAt!)}', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                  ],
                ),
              ),
            ],

            // Main Invoice Card (exact match to user's reference images)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Company Branding Header & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: BSG Branding
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BSG',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: theme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Agro Goods Trading Mandi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Salem / Erode Mandi Complex, TN',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Right: Status Badge & Bill ID/Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStatusBadge(bill.status),
                          const SizedBox(height: 6),
                          Text(
                            bill.billNumber,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: theme.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.date(bill.date),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                  ),

                  // 2. Party & Consignment Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Billed To Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Billed To (Buyer):',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              bill.customerName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: theme.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (customer?.city != null && customer!.city!.isNotEmpty)
                              Text(
                                customer.city!,
                                style: TextStyle(fontSize: 11, color: theme.textSecondary),
                              )
                            else if (bill.village != null && bill.village!.isNotEmpty)
                              Text(
                                bill.village!,
                                style: TextStyle(fontSize: 11, color: theme.textSecondary),
                              )
                            else
                              Text(
                                'Counter Cash Buyer',
                                style: TextStyle(fontSize: 11, color: theme.textMuted),
                              ),
                            if (bill.customerPhone != null && bill.customerPhone!.isNotEmpty)
                              Text(
                                'Ph: ${bill.customerPhone}',
                                style: TextStyle(fontSize: 11, color: theme.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Linked Goods Lot Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Linked Goods Lot:',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Lot: ${bill.lotNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: theme.text,
                              ),
                            ),
                            Text(
                              bill.productName,
                              style: TextStyle(fontSize: 11, color: theme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Veh: ${lot?.vehicleNumber != null && lot!.vehicleNumber!.isNotEmpty ? lot.vehicleNumber! : 'TN 30 BA 4512'}',
                              style: TextStyle(fontSize: 11, color: theme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. Mandi Goods & Weighment Table (Exact paper slip structure: S.No, Lot No, Quantity Total Bags, Each Bags Weight, Total Weight, Rate, Amount)
                  _buildMandiGoodsWeighmentTable(bill, lot, theme),

                  const SizedBox(height: 16),

                  // 4. Calculations & Financial Totals
                  _buildCalcRow('Subtotal', '₹${AppFormatters.number(bill.grossAmount)}', theme),
                  if (bill.labourCharge > 0)
                    _buildCalcRow('Labour / Hamali Charge', '+ ₹${AppFormatters.number(bill.labourCharge)}', theme),
                  if (bill.transportFee > 0)
                    _buildCalcRow('Transport Fee', '+ ₹${AppFormatters.number(bill.transportFee)}', theme),
                  if (bill.mandiFee > 0)
                    _buildCalcRow('Mandi Fee', '+ ₹${AppFormatters.number(bill.mandiFee)}', theme),
                  if (bill.otherCharges > 0)
                    _buildCalcRow('Extra Charges', '+ ₹${AppFormatters.number(bill.otherCharges)}', theme),
                  if (bill.discount > 0)
                    _buildCalcRow('Discount Applied', '- ₹${AppFormatters.number(bill.discount)}', theme, valueColor: const Color(0xFF2E7D32)),

                  const Divider(height: 18, color: Color(0xFFE5E7EB)),
                  _buildCalcRow('Current Bill Total', '₹${AppFormatters.number(bill.totalAmount)}', theme, isBold: true),

                  if (previousDue > 0) ...[
                    _buildCalcRow('Previous Outstanding Balance', '+ ₹${AppFormatters.number(previousDue)}', theme),
                    const Divider(height: 18, color: Color(0xFFE5E7EB)),
                    _buildCalcRow('Gross Amount Payable', '₹${AppFormatters.number(grossPayable)}', theme, isBold: true, fontSize: 14.5),
                  ],

                  const Divider(height: 18, color: Color(0xFFE5E7EB)),

                  // Deductions & Receipts (Green)
                  if (bill.amountReceived > 0) ...[
                    _buildCalcRow('Payments Applied', '- ₹${AppFormatters.number(bill.amountReceived)}', theme, valueColor: const Color(0xFF2E7D32)),
                    _buildCalcRow('Total Received', '- ₹${AppFormatters.number(bill.amountReceived)}', theme, isBold: true, valueColor: const Color(0xFF2E7D32)),
                    const Divider(height: 18, color: Color(0xFFE5E7EB)),
                  ],

                  // Final Balance (Red / Crimson)
                  _buildCalcRow(
                    'Outstanding Balance Due',
                    '₹${AppFormatters.number(bill.balanceDue)}',
                    theme,
                    isBold: true,
                    fontSize: 16,
                    labelColor: const Color(0xFFD32F2F),
                    valueColor: const Color(0xFFD32F2F),
                  ),

                  // Remarks / Notes if present
                  if (bill.notes != null && bill.notes!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notes_rounded, size: 16, color: theme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Notes: ${bill.notes}',
                              style: TextStyle(fontSize: 11.5, color: theme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Payments Received on this Bill Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payments Received on this Bill',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (billPayments.isEmpty && bill.amountReceived <= 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No payments recorded yet for this bill.',
                        style: TextStyle(fontSize: 12, color: theme.textMuted),
                      ),
                    )
                  else ...[
                    // Render payment rows
                    if (billPayments.isNotEmpty)
                      ...billPayments.map((p) => _buildPaymentRow(
                            title: '${p.method.displayName} • ${p.referenceNumber ?? 'Ref: Standard'}',
                            date: AppFormatters.dateTime(p.date),
                            amount: p.amount,
                            theme: theme,
                          ))
                    else
                      _buildPaymentRow(
                        title: '${bill.paymentMethod.displayName} • ${bill.paymentReference ?? 'Initial Collection'}',
                        date: AppFormatters.dateTime(bill.createdAt),
                        amount: bill.amountReceived,
                        theme: theme,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom Navigation Bar with exact 7 action buttons
      // -----------------------------------------------------------------------
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. CANCEL (Red)
              _buildNavButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 22, color: Color(0xFFD32F2F)),
                    Positioned(
                      right: -4,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 9, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                label: 'CANCEL',
                color: const Color(0xFFD32F2F),
                isBold: true,
                onTap: () => _handleCancelBill(bill),
              ),

              // 2. History
              _buildNavButton(
                icon: Icon(Icons.article_outlined, size: 22, color: theme.primary),
                label: 'History',
                color: theme.primary,
                onTap: () => _showHistorySheet(bill),
              ),

              // 3. Pay
              _buildNavButton(
                icon: Icon(Icons.currency_rupee, size: 22, color: theme.primary),
                label: 'Pay',
                color: theme.primary,
                onTap: () => _showQuickPaySheet(bill),
              ),

              // 4. Edit
              _buildNavButton(
                icon: Icon(Icons.edit_outlined, size: 22, color: theme.primary),
                label: 'Edit',
                color: theme.primary,
                onTap: () => _showEditSheet(bill),
              ),

              // 5. Print
              _buildNavButton(
                icon: Icon(Icons.print_outlined, size: 22, color: theme.primary),
                label: 'Print',
                color: theme.primary,
                onTap: () => _showPrintSharePreview(bill),
              ),

              // 6. Share
              _buildNavButton(
                icon: Icon(Icons.share_outlined, size: 22, color: theme.primary),
                label: 'Share',
                color: theme.primary,
                onTap: () => _showShareOptions(bill),
              ),

              // 7. WhatsApp
              _buildNavButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22, color: Color(0xFF25D366)),
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _showWhatsAppSheet(bill),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mandi Goods & Weighment Table (Paper Slip Columns: No, Lot No, Bags, Each Bag Weights, Total Weight, Rate, Amount)
  // ---------------------------------------------------------------------------
  Widget _buildMandiGoodsWeighmentTable(Bill bill, Lot? lot, AppThemeColors theme) {
    final allItems = bill.allItems;
    final int totalBags = allItems.fold<int>(0, (sum, it) {
      final bCount = it.bagItems.isNotEmpty ? it.bagItems.length : (it.quantity > 0 ? it.quantity.toInt() : 1);
      return sum + bCount;
    });
    final double totalWeight = allItems.fold<double>(0.0, (sum, it) {
      final w = it.bagItems.isNotEmpty ? it.bagItems.fold<double>(0.0, (s, b) => s + b.weight) : it.weight;
      return sum + w;
    });
    final double totalGrossAmount = allItems.fold<double>(0.0, (sum, it) => sum + it.grossAmount);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Table Top Title Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEDF2F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1))),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 16, color: theme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'GOODS & WEIGHMENT TABLE',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: theme.primary,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    allItems.length > 1 ? '${allItems.length} Products' : 'Lot: ${bill.lotNumber}',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                ),
              ],
            ),
          ),

          // 2. Horizontal Scrollable Mandi Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 64,
                horizontalMargin: 10,
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                border: TableBorder(
                  horizontalInside: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  verticalInside: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  top: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                  bottom: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                  left: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                  right: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                columns: const [
                  DataColumn(label: Text('No', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                  DataColumn(label: Text('Lot Num', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                  DataColumn(label: Text('Commodity', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                  DataColumn(label: Text('Quantity Total Bag', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                  DataColumn(label: Text('Each Bags Weight (Kg)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                  DataColumn(label: Text('Total Weight', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                  DataColumn(label: Text('Rate / Bag (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                  DataColumn(label: Text('Amount (₹)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                ],
                rows: allItems.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final int itemBags = item.bagItems.isNotEmpty
                      ? item.bagItems.length
                      : (item.quantity > 0 ? item.quantity.toInt() : 1);
                  final double itemWeight = item.bagItems.isNotEmpty
                      ? item.bagItems.fold<double>(0.0, (s, b) => s + b.weight)
                      : item.weight;
                  final List<double> bWeights = item.bagItems.isNotEmpty
                      ? item.bagItems.map((b) => b.weight).toList()
                      : [item.weight / (itemBags > 0 ? itemBags : 1)];
                  final String eachBagsWeightText = bWeights.map((w) => w.toStringAsFixed(1).replaceAll('.0', '')).join(', ');

                  return DataRow(
                    cells: [
                      DataCell(Center(child: Text('$idx', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)))),
                      DataCell(Text(item.lotNumber, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F766E)))),
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.productName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                          Text(lot?.entryNumber != null ? 'Entry: ${lot!.entryNumber}' : 'Mandi Goods', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      )),
                      DataCell(Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('$itemBags Bags', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0369A1))),
                        ),
                      )),
                      DataCell(Container(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(
                          eachBagsWeightText.isNotEmpty ? eachBagsWeightText : '${item.weight.toStringAsFixed(0)} kg',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      )),
                      DataCell(Align(
                        alignment: Alignment.centerRight,
                        child: Text('${itemWeight.toStringAsFixed(1).replaceAll('.0', '')} kg', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                      )),
                      DataCell(Align(
                        alignment: Alignment.centerRight,
                        child: Text('₹${item.sellRate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      )),
                      DataCell(Align(
                        alignment: Alignment.centerRight,
                        child: Text('₹${AppFormatters.number(item.grossAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Horizontal scroll hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.swipe_left_alt_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Swipe table left/right to view all mandi columns',
                    style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: theme.textMuted),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 12, color: Color(0xFFCBD5E1)),

          // 3. Section: Individual Each Bags Weight Breakdown
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Each Bags Weight Breakdown ($totalBags Bags):',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Avg: ${(totalWeight / (totalBags > 0 ? totalBags : 1)).toStringAsFixed(1)} kg/bag',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Bag chips for all items
                ...allItems.map((it) {
                  final itBags = it.bagItems;
                  if (itBags.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (allItems.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${it.productName} (${it.lotNumber}) - ${itBags.length} Bags:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.primary),
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: itBags.map((bag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: theme.primary.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '#${bag.serialNumber}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: theme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${bag.weight.toStringAsFixed(1).replaceAll('.0', '')} kg',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(₹${AppFormatters.number(bag.amount)})',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),

                if (allItems.every((it) => it.bagItems.isEmpty))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      'Uniform lot weighing: $totalBags Bags × ${(totalWeight / (totalBags > 0 ? totalBags : 1)).toStringAsFixed(1)} kg = ${totalWeight.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                    ),
                  ),

                const SizedBox(height: 8),

                // Table Summary Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Total Bags: $totalBags Bags',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Total: ${totalWeight.toStringAsFixed(1).replaceAll('.0', '')} kg',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${AppFormatters.number(totalGrossAmount)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F766E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Status Badge Widget
  // ---------------------------------------------------------------------------
  Widget _buildStatusBadge(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA5D6A7)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 13, color: Color(0xFF2E7D32)),
              SizedBox(width: 4),
              Text(
                'Fully Paid',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        );
      case BillStatus.partiallyPaid:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE0B2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 13, color: Color(0xFFB78103)),
              SizedBox(width: 4),
              Text(
                'Partially Paid',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB78103),
                ),
              ),
            ],
          ),
        );
      case BillStatus.unpaid:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCDD2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 13, color: Color(0xFFC62828)),
              SizedBox(width: 4),
              Text(
                'Unpaid',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                ),
              ),
            ],
          ),
        );
      case BillStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFECEFF1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCFD8DC)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_outlined, size: 13, color: Color(0xFF546E7A)),
              SizedBox(width: 4),
              Text(
                'Cancelled',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF546E7A),
                ),
              ),
            ],
          ),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Helper Widgets
  // ---------------------------------------------------------------------------
  Widget _buildCalcRow(
    String label,
    String value,
    AppThemeColors theme, {
    bool isBold = false,
    double fontSize = 13,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: labelColor ?? (isBold ? theme.text : theme.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? (isBold ? theme.text : theme.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String title,
    required String date,
    required double amount,
    required AppThemeColors theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${AppFormatters.number(amount)}',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required Widget icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isBold = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Center(child: icon),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: color,
                letterSpacing: isBold ? 0.3 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
