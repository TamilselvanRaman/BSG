import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/date_formatter.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';
import '../../data/models/goods_entry.dart';

class PrintBillVoucherDialog extends StatefulWidget {
  final Bill bill;
  final Customer customer;
  final GoodsEntry? goodsEntry;

  const PrintBillVoucherDialog({
    super.key,
    required this.bill,
    required this.customer,
    this.goodsEntry,
  });

  @override
  State<PrintBillVoucherDialog> createState() => _PrintBillVoucherDialogState();
}

class _PrintBillVoucherDialogState extends State<PrintBillVoucherDialog> {
  int _paperFormatIndex = 0; // 0: 3-inch (80mm Thermal), 1: 2-inch (58mm Thermal), 2: A4 Standard

  String _generateReceiptText() {
    final b = widget.bill;
    final c = widget.customer;
    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('      BSG AGRO GOODS MANDI      ');
    buffer.writeln('  Thennampalayam Market, Tiruppur');
    buffer.writeln('   Phone: 98427 12345 / 86100 54321');
    buffer.writeln('================================');
    buffer.writeln('TAX INVOICE / CASH BILL');
    buffer.writeln('Bill No: ${b.billNumber}');
    buffer.writeln('Date:    ${DateFormatter.format(b.billDate)}');
    buffer.writeln('Buyer:   ${c.name}');
    if (c.phone.isNotEmpty) buffer.writeln('Phone:   ${c.phone}');
    if (widget.goodsEntry?.lotNumber != null && widget.goodsEntry!.lotNumber.isNotEmpty) {
      buffer.writeln('Lot No:  ${widget.goodsEntry!.lotNumber}');
    }
    if (widget.goodsEntry?.vehicleNumber != null && widget.goodsEntry!.vehicleNumber.isNotEmpty) {
      buffer.writeln('Vehicle: ${widget.goodsEntry!.vehicleNumber}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Item / Variety       Wt(kg)  Rate  Total');
    buffer.writeln('--------------------------------');
    for (final item in b.items) {
      final name = item.description.length > 18 ? item.description.substring(0, 18) : item.description.padRight(18);
      buffer.writeln(name);
      final wtStr = '${item.weight.toStringAsFixed(0)}kg'.padRight(8);
      final rateStr = '₹${item.rate.toStringAsFixed(0)}'.padRight(6);
      final totStr = '₹${item.lineTotal.toStringAsFixed(0)}'.padLeft(8);
      buffer.writeln('  $wtStr $rateStr $totStr');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Produce Subtotal:      ₹${b.subtotal.toStringAsFixed(2)}');
    if (b.labourCharge > 0) buffer.writeln('Hamali / Labour:       ₹${b.labourCharge.toStringAsFixed(2)}');
    buffer.writeln('--------------------------------');
    buffer.writeln('TOTAL BILL AMOUNT:     ₹${b.currentBillTotal.toStringAsFixed(2)}');
    if (b.initialPaymentApplied > 0) {
      buffer.writeln('Advance Deducted:    - ₹${b.initialPaymentApplied.toStringAsFixed(2)}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('AMOUNT PAYABLE:        ₹${b.amountPayable.toStringAsFixed(2)}');
    buffer.writeln('Total Paid:            ₹${b.totalPaymentsApplied.toStringAsFixed(2)}');
    buffer.writeln('BALANCE DUE:           ₹${b.remainingBalance.toStringAsFixed(2)}');
    buffer.writeln('================================');
    buffer.writeln('  * Computer Generated Bill *   ');
    buffer.writeln('  Thank You! Visit Again.       ');
    buffer.writeln('================================');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final receiptText = _generateReceiptText();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 520,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.print_rounded, color: AppColors.primaryGreen, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Print Bill & Receipt',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Paper Format Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildPaperPill('3" Thermal (80mm)', 0),
                  _buildPaperPill('2" Mini (58mm)', 1),
                  _buildPaperPill('A4 Invoice', 2),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Thermal Slip Preview Container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB), // thermal receipt cream paper
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    receiptText,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy Slip', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: receiptText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receipt voucher copied to clipboard!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Print Now', style: TextStyle(fontWeight: FontWeight.w800)),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sending ${widget.bill.billNumber} to Bluetooth / USB Thermal Printer...'),
                          backgroundColor: AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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

  Widget _buildPaperPill(String label, int index) {
    final isSelected = _paperFormatIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paperFormatIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primaryGreen : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
