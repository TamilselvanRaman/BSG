import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/utils/formatters.dart';

enum PaymentMode {
  cash,
  upiGpay,
  cheque,
  creditUnpaid,
}

class PaymentDetailsStep extends StatelessWidget {
  final double netGoodsAmount;
  final double totalInwardExpenses;
  final TextEditingController advancePaidController;
  final TextEditingController remainingRentController;
  final PaymentMode paymentMode;
  final ValueChanged<PaymentMode> onPaymentModeChanged;
  final TextEditingController paidAmountController;
  final TextEditingController referenceController;
  final TextEditingController notesController;
  final VoidCallback onChanged;
  final bool isEmbedded;

  const PaymentDetailsStep({
    super.key,
    required this.netGoodsAmount,
    required this.totalInwardExpenses,
    required this.advancePaidController,
    required this.remainingRentController,
    required this.paymentMode,
    required this.onPaymentModeChanged,
    required this.paidAmountController,
    required this.referenceController,
    required this.notesController,
    required this.onChanged,
    this.isEmbedded = false,
  });

  double get totalLotValue => netGoodsAmount + totalInwardExpenses;
  double get advancePaid => double.tryParse(advancePaidController.text) ?? 0.0;
  double get remainingRent => double.tryParse(remainingRentController.text) ?? 0.0;
  double get paidNow => double.tryParse(paidAmountController.text) ?? 0.0;

  double get totalPaidSoFar => advancePaid + paidNow;
  double get balanceDue => (totalLotValue - totalPaidSoFar).clamp(0.0, double.infinity);

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;

    String statusText;
    Color statusColor;

    if (totalPaidSoFar >= totalLotValue && totalLotValue > 0) {
      statusText = 'PAID IN FULL';
      statusColor = theme.success;
    } else if (totalPaidSoFar > 0) {
      statusText = 'PARTIAL PAYMENT';
      statusColor = theme.warning;
    } else {
      statusText = 'UNPAID (CREDIT)';
      statusColor = theme.error;
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Total Consignment Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Goods Value:', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                    Text(AppFormatters.currency(netGoodsAmount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Inward Expenses & Mandi Charges:', style: TextStyle(fontSize: 13, color: theme.textSecondary)),
                    Text('+ ${AppFormatters.currency(totalInwardExpenses)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.text)),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: theme.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Consignment Cost', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.text)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppFormatters.currency(totalLotValue),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Advance & Transport Rent
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advance & Logistics Settlement',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    // Advance Paid
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Advance Paid to Farmer (₹)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: advancePaidController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => onChanged(),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              hintText: '0.00',
                              filled: true,
                              fillColor: theme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Remaining Lorry Rent
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remaining Lorry Rent (₹)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: remainingRentController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => onChanged(),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.text),
                            decoration: InputDecoration(
                              prefixText: '₹ ',
                              hintText: '0.00',
                              filled: true,
                              fillColor: theme.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment Mode Selector Cards
          Text(
            'Select Inward Settlement Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.text,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  title: 'Cash',
                  icon: Icons.payments_outlined,
                  isSelected: paymentMode == PaymentMode.cash,
                  onTap: () {
                    onPaymentModeChanged(PaymentMode.cash);
                    onChanged();
                  },
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeCard(
                  title: 'GPay / UPI',
                  icon: Icons.qr_code_scanner_outlined,
                  isSelected: paymentMode == PaymentMode.upiGpay,
                  onTap: () {
                    onPaymentModeChanged(PaymentMode.upiGpay);
                    onChanged();
                  },
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeCard(
                  title: 'Cheque',
                  icon: Icons.subtitles_outlined,
                  isSelected: paymentMode == PaymentMode.cheque,
                  onTap: () {
                    onPaymentModeChanged(PaymentMode.cheque);
                    onChanged();
                  },
                  theme: theme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildModeCard(
                  title: 'Credit',
                  icon: Icons.history_outlined,
                  isSelected: paymentMode == PaymentMode.creditUnpaid,
                  onTap: () {
                    onPaymentModeChanged(PaymentMode.creditUnpaid);
                    paidAmountController.text = '0';
                    onChanged();
                  },
                  theme: theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mode Specific Inputs
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Amount & Reference',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                ),
                const SizedBox(height: 14),

                // Amount Paid Now
                Text(
                  'Amount Paid Now (₹)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: paidAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onChanged(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.text),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    hintText: '0.00',
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                if (paymentMode == PaymentMode.cheque || paymentMode == PaymentMode.upiGpay) ...[
                  const SizedBox(height: 14),
                  Text(
                    paymentMode == PaymentMode.cheque
                        ? 'Bank Name & Cheque Number *'
                        : 'UPI Reference ID / UTR Number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: referenceController,
                    style: TextStyle(fontSize: 13, color: theme.text),
                    decoration: InputDecoration(
                      hintText: paymentMode == PaymentMode.cheque
                          ? 'e.g. SBI Cheque #984210'
                          : 'e.g. UPI Ref #4390192840',
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Notes / Remarks
                Text(
                  'Payment Notes / Supplier Remarks',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13, color: theme.text),
                  decoration: InputDecoration(
                    hintText: 'e.g. Paid via GPay at loading time, balance upon weighment confirmation',
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Outstanding Balance Due Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Outstanding Balance Due', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(balanceDue),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: balanceDue > 0 ? theme.error : theme.success,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total Paid So Far', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(totalPaidSoFar),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

    if (isEmbedded) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildModeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeColors theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primary.withValues(alpha: 0.1) : theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primary : theme.border,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSelected ? theme.primary : theme.textMuted),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? theme.primary : theme.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

