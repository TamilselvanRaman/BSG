import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';
import '../../data/models/goods_entry.dart';
import '../../data/models/payment.dart';
import '../sharing/whatsapp_share_dialog.dart';
import 'cancel_bill_dialog.dart';
import 'print_bill_voucher_dialog.dart';

class BillDetailScreen extends ConsumerWidget {
  final String billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);
    final bill = bills.cast<Bill?>().firstWhere(
      (b) => b?.id == billId,
      orElse: () => null,
    );

    if (bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: const Center(child: Text('Bill not found')),
      );
    }

    final customers = ref.watch(customersProvider);
    final customer = customers.cast<Customer?>().firstWhere(
      (c) => c?.id == bill.customerId,
      orElse: () => null,
    );

    final entries = ref.watch(goodsEntriesProvider);
    final goodsEntry = bill.goodsEntryId != null
        ? entries.cast<GoodsEntry?>().firstWhere((e) => e?.id == bill.goodsEntryId, orElse: () => null)
        : null;

    final billPayments = ref.watch(paymentsProvider).where((p) => p.billId == bill.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          bill.billNumber,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Color(0xFF475569)),
            tooltip: 'Print Slip',
            onPressed: () {
              if (customer != null) {
                showDialog(
                  context: context,
                  builder: (_) => PrintBillVoucherDialog(
                    bill: bill,
                    customer: customer,
                    goodsEntry: goodsEntry,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF475569)),
            tooltip: 'Share',
            onPressed: () {
              if (customer != null) {
                showDialog(
                  context: context,
                  builder: (_) => WhatsappShareDialog(
                    bill: bill,
                    customer: customer,
                    goodsEntry: goodsEntry,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: 880,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            children: [
              // Cancelled Banner if applicable
              if (bill.status == BillStatus.cancelled) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cancel, color: AppColors.danger, size: 22),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'THIS BILL HAS BEEN CANCELLED',
                              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.danger, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reason: ${bill.cancellationReason}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                            ),
                            if (bill.cancelledAt != null)
                              Text(
                                'Cancelled on ${DateFormatter.formatWithTime(bill.cancelledAt!)} by ${bill.cancelledBy}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Formal Invoice Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BSG',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E6B24),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const Text(
                              'Agro Goods Trading Mandi',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Salem / Erode Mandi Complex, TN',
                              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StatusBadge.fromBillStatus(bill.statusLabel),
                            const SizedBox(height: 6),
                            Text(
                              bill.billNumber,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              DateFormatter.format(bill.billDate),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 24, thickness: 1, color: Color(0xFFE2E8F0)),

                    // Customer & Goods Meta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Billed To (Buyer):', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                customer?.name ?? 'Unknown Buyer',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Color(0xFF0F172A)),
                              ),
                              if (customer?.village.isNotEmpty == true)
                                Text(customer!.village, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              if (customer?.phone.isNotEmpty == true)
                                Text('Ph: ${customer!.phone}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        if (goodsEntry != null)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Linked Goods Lot:', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                const SizedBox(height: 3),
                                Text(
                                  'Lot: ${goodsEntry.lotNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF0F172A)),
                                ),
                                Text(goodsEntry.goodsName, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                if (goodsEntry.vehicleNumber.isNotEmpty)
                                  Text('Veh: ${goodsEntry.vehicleNumber}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Items Table
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEDF2F7),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 4, child: Text('Commodity', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                                Expanded(flex: 2, child: Text('Bags', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                                Expanded(flex: 2, child: Text('Weight', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                                Expanded(flex: 2, child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                                Expanded(flex: 3, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)))),
                              ],
                            ),
                          ),
                          ...bill.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item.description,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.quantity.toStringAsFixed(0)} BG',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.weight.toStringAsFixed(0)} kg',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '₹${item.rate.toStringAsFixed(0)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      CurrencyFormatter.format(item.lineTotal),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Financial Breakdown
                    Column(
                      children: [
                        _row('Subtotal', CurrencyFormatter.format(bill.subtotal)),
                        if (bill.labourCharge > 0)
                          _row('Labour / Hamali Charge', '+ ${CurrencyFormatter.format(bill.labourCharge)}'),
                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                        _row('Current Bill Total', CurrencyFormatter.format(bill.currentBillTotal), isBold: true),
                        if (bill.previousBalanceSnapshot > 0) ...[
                          _row('Previous Outstanding Balance', '+ ${CurrencyFormatter.format(bill.previousBalanceSnapshot)}'),
                          const Divider(height: 14, color: Color(0xFFE2E8F0)),
                          _row('Gross Amount Payable', CurrencyFormatter.format(bill.amountPayable), isBold: true),
                        ],
                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                        if (bill.initialPaymentApplied > 0)
                          _row('Advance Adjusted', '- ${CurrencyFormatter.format(bill.initialPaymentApplied)}', color: const Color(0xFF16A34A)),
                        if (bill.otherPaymentsApplied > 0)
                          _row('Payments Applied', '- ${CurrencyFormatter.format(bill.otherPaymentsApplied)}', color: const Color(0xFF16A34A)),
                        if (bill.totalPaymentsApplied > 0)
                          _row('Total Received', '- ${CurrencyFormatter.format(bill.totalPaymentsApplied)}', isBold: true, color: const Color(0xFF16A34A)),
                        const Divider(height: 16, thickness: 1.5, color: Color(0xFFCBD5E1)),
                        _row(
                          'Outstanding Balance Due',
                          CurrencyFormatter.format(bill.remainingBalance),
                          isBold: true,
                          color: bill.remainingBalance > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Payments History Section if any
              if (billPayments.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payments Received on this Bill',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: billPayments.length,
                        separatorBuilder: (_, _) => const Divider(height: 12),
                        itemBuilder: (context, index) {
                          final p = billPayments[index];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${p.paymentMode} • ${p.reference.isNotEmpty ? p.reference : "Receipt"}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                                  ),
                                  Text(
                                    DateFormatter.formatWithTime(p.paymentDate),
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                              Text(
                                CurrencyFormatter.format(p.amount),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF16A34A)),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // ========================================================
      // MANDI INVOICE ACTION BAR (MATCHING USER PHOTO EXACTLY)
      // Buttons: [CANCEL] (left) | [History] [Pay] [Edit] [Print] [Share] [WhatsApp]
      // ========================================================
      bottomNavigationBar: _buildInvoiceBottomBar(
        context,
        ref,
        bill,
        customer,
        goodsEntry,
        billPayments,
      ),
    );
  }

  // ========================================================
  // BOTTOM ACTION BAR MATCHING USER PHOTO
  // ========================================================
  Widget _buildInvoiceBottomBar(
    BuildContext context,
    WidgetRef ref,
    Bill bill,
    Customer? customer,
    GoodsEntry? goodsEntry,
    List<Payment> billPayments,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // 1. CANCEL button on the left (matches user photo with red badge)
              _buildCancelActionButton(context, ref, bill),

              // Vertical subtle separator
              Container(
                height: 34,
                width: 1,
                color: const Color(0xFFE2E8F0),
                margin: const EdgeInsets.symmetric(horizontal: 2),
              ),

              // Right actions: History, Pay, Edit, Print, Share, WhatsApp
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildActionItem(
                        icon: const Icon(Icons.description_outlined, color: Color(0xFF16A34A), size: 22),
                        label: 'History',
                        onTap: () => _showBillHistoryModal(context, bill, billPayments, customer),
                      ),
                      _buildActionItem(
                        icon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF16A34A), size: 22),
                        label: 'Pay',
                        onTap: () {
                          if (bill.status == BillStatus.cancelled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cannot record payment on a cancelled bill.')),
                            );
                            return;
                          }
                          if (bill.remainingBalance <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Bill is already fully settled! (Balance: ₹0)')),
                            );
                            return;
                          }
                          context.push('/payments/new?billId=${bill.id}&customerId=${bill.customerId}');
                        },
                      ),
                      _buildActionItem(
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF16A34A), size: 22),
                        label: 'Edit',
                        onTap: () {
                          if (bill.status == BillStatus.cancelled) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cancelled bill cannot be edited.')),
                            );
                            return;
                          }
                          _showEditBillModal(context, ref, bill);
                        },
                      ),
                      _buildActionItem(
                        icon: const Icon(Icons.print_outlined, color: Color(0xFF16A34A), size: 22),
                        label: 'Print',
                        onTap: () {
                          if (customer != null) {
                            showDialog(
                              context: context,
                              builder: (_) => PrintBillVoucherDialog(
                                bill: bill,
                                customer: customer,
                                goodsEntry: goodsEntry,
                              ),
                            );
                          }
                        },
                      ),
                      _buildActionItem(
                        icon: const Icon(Icons.share_outlined, color: Color(0xFF16A34A), size: 22),
                        label: 'Share',
                        onTap: () => _shareBillSummary(context, bill, customer, goodsEntry),
                      ),
                      _buildActionItem(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF16A34A), size: 22),
                        label: 'WhatsApp',
                        onTap: () {
                          if (customer != null) {
                            showDialog(
                              context: context,
                              builder: (_) => WhatsappShareDialog(
                                bill: bill,
                                customer: customer,
                                goodsEntry: goodsEntry,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cancel Action Button matching photo with red badge
  Widget _buildCancelActionButton(BuildContext context, WidgetRef ref, Bill bill) {
    final isCancelled = bill.status == BillStatus.cancelled;
    return InkWell(
      onTap: () {
        if (isCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This bill has already been cancelled.')),
          );
          return;
        }
        showDialog(
          context: context,
          builder: (_) => CancelBillDialog(
            bill: bill,
            onConfirm: (reason, cancelledBy) {
              ref.read(appStateProvider.notifier).cancelBill(
                bill.id,
                reason: reason,
                cancelledBy: cancelledBy,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bill ${bill.billNumber} cancelled successfully.'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 23,
                  color: isCancelled ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                Positioned(
                  right: -4,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: isCancelled ? const Color(0xFF94A3B8) : const Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 9, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'CANCEL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isCancelled ? const Color(0xFF94A3B8) : const Color(0xFFDC2626),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom action item with green icon and clean label
  Widget _buildActionItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // AUDIT & PAYMENT HISTORY MODAL
  // ========================================================
  void _showBillHistoryModal(
    BuildContext context,
    Bill bill,
    List<Payment> billPayments,
    Customer? customer,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollCtrl) {
            return SingleChildScrollView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.history_edu_rounded, color: Color(0xFF16A34A), size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Audit History: ${bill.billNumber}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buyer: ${customer?.name ?? "Unknown"} • Date: ${DateFormatter.format(bill.billDate)}',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                  const Divider(height: 24),

                  // Event 1: Bill Generation
                  _buildHistoryTimelineItem(
                    icon: Icons.receipt_long,
                    iconColor: const Color(0xFF16A34A),
                    title: 'Invoice Generated',
                    subtitle: 'Total Amount: ${CurrencyFormatter.format(bill.currentBillTotal)}',
                    time: DateFormatter.formatWithTime(bill.createdAt),
                    details: 'Subtotal: ${CurrencyFormatter.format(bill.subtotal)} | Labour: ${CurrencyFormatter.format(bill.labourCharge)}',
                  ),

                  // Event 2: Payments applied
                  if (billPayments.isNotEmpty) ...[
                    ...billPayments.map((p) {
                      return _buildHistoryTimelineItem(
                        icon: Icons.payments_rounded,
                        iconColor: const Color(0xFF2563EB),
                        title: 'Payment Received (${p.paymentMode})',
                        subtitle: 'Amount: ${CurrencyFormatter.format(p.amount)}',
                        time: DateFormatter.formatWithTime(p.paymentDate),
                        details: 'Ref: ${p.reference.isNotEmpty ? p.reference : "N/A"}${p.notes.isNotEmpty ? " • ${p.notes}" : ""}',
                      );
                    }),
                  ] else ...[
                    _buildHistoryTimelineItem(
                      icon: Icons.hourglass_empty_rounded,
                      iconColor: const Color(0xFFEAB308),
                      title: 'No Direct Payments Recorded',
                      subtitle: 'Remaining balance: ${CurrencyFormatter.format(bill.remainingBalance)}',
                      time: DateFormatter.format(bill.billDate),
                      details: bill.initialPaymentApplied > 0
                          ? 'Advance adjusted: ${CurrencyFormatter.format(bill.initialPaymentApplied)}'
                          : 'Pending settlement',
                    ),
                  ],

                  // Event 3: Cancellation if cancelled
                  if (bill.status == BillStatus.cancelled) ...[
                    _buildHistoryTimelineItem(
                      icon: Icons.cancel,
                      iconColor: const Color(0xFFDC2626),
                      title: 'Bill Cancelled',
                      subtitle: 'Reason: ${bill.cancellationReason}',
                      time: bill.cancelledAt != null ? DateFormatter.formatWithTime(bill.cancelledAt!) : 'N/A',
                      details: 'Cancelled by operator: ${bill.cancelledBy}',
                      isLast: true,
                    ),
                  ],

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Gross Total', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(CurrencyFormatter.format(bill.currentBillTotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Payments Applied', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF16A34A))),
                            Text(CurrencyFormatter.format(bill.totalPaymentsApplied), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF16A34A))),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Outstanding Balance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text(
                              CurrencyFormatter.format(bill.remainingBalance),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: bill.remainingBalance > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required String details,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                const SizedBox(height: 1),
                Text(details, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // EDIT BILL MODAL SHEET
  // ========================================================
  void _showEditBillModal(BuildContext context, WidgetRef ref, Bill bill) {
    if (bill.items.isEmpty) return;
    final item = bill.items.first;

    final weightCtrl = TextEditingController(text: item.weight.toStringAsFixed(0));
    final rateCtrl = TextEditingController(text: item.rate.toStringAsFixed(0));
    final bagsCtrl = TextEditingController(text: item.quantity.toStringAsFixed(0));
    final labourCtrl = TextEditingController(text: bill.labourCharge.toStringAsFixed(0));
    final descCtrl = TextEditingController(text: item.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final w = double.tryParse(weightCtrl.text) ?? 0.0;
            final r = double.tryParse(rateCtrl.text) ?? 0.0;
            final l = double.tryParse(labourCtrl.text) ?? 0.0;
            final sub = w * r;
            final tot = sub + l;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Bill Details',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          bill.billNumber,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Commodity & Variety',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: bagsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Bags (BG)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Net Weight (kg)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: rateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Rate (₹/kg)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: labourCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Labour (₹)',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Calculated Subtotal', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              Text('₹${sub.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('New Total', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              Text('₹${tot.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF16A34A))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              final updatedItem = item.copyWith(
                                description: descCtrl.text.trim(),
                                quantity: double.tryParse(bagsCtrl.text) ?? item.quantity,
                                weight: w,
                                rate: r,
                                lineTotal: sub,
                              );
                              final updatedBill = bill.copyWith(
                                items: [updatedItem],
                                subtotal: sub,
                                labourCharge: l,
                              );
                              ref.read(appStateProvider.notifier).updateBill(updatedBill);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Bill ${bill.billNumber} updated successfully!'),
                                  backgroundColor: const Color(0xFF2E7D32),
                                ),
                              );
                            },
                            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ========================================================
  // SHARE BILL SUMMARY SLIP
  // ========================================================
  void _shareBillSummary(BuildContext context, Bill bill, Customer? customer, GoodsEntry? goodsEntry) {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('       BSG AGRO MANDI TRADERS');
    buffer.writeln('========================================');
    buffer.writeln('INVOICE: ${bill.billNumber}');
    buffer.writeln('DATE: ${DateFormatter.format(bill.billDate)}');
    buffer.writeln('BUYER: ${customer?.name ?? "Wholesale Buyer"}');
    if (customer?.phone.isNotEmpty == true) buffer.writeln('PHONE: ${customer!.phone}');
    if (goodsEntry != null) buffer.writeln('LOT NO: ${goodsEntry.lotNumber}');
    buffer.writeln('----------------------------------------');
    for (final item in bill.items) {
      buffer.writeln('${item.description}: ${item.weight.toStringAsFixed(0)} kg @ ₹${item.rate.toStringAsFixed(0)} = ₹${item.lineTotal.toStringAsFixed(2)}');
    }
    buffer.writeln('----------------------------------------');
    buffer.writeln('SUBTOTAL: ₹${bill.subtotal.toStringAsFixed(2)}');
    if (bill.labourCharge > 0) buffer.writeln('LABOUR: ₹${bill.labourCharge.toStringAsFixed(2)}');
    buffer.writeln('TOTAL AMOUNT: ₹${bill.currentBillTotal.toStringAsFixed(2)}');
    buffer.writeln('PAID: ₹${bill.totalPaymentsApplied.toStringAsFixed(2)}');
    buffer.writeln('BALANCE DUE: ₹${bill.remainingBalance.toStringAsFixed(2)}');
    buffer.writeln('STATUS: ${bill.statusLabel.toUpperCase()}');
    buffer.writeln('========================================');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share Invoice Slip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 140),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(buffer.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy Slip'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invoice details copied to clipboard!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('WhatsApp'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (customer != null) {
                          showDialog(
                            context: context,
                            builder: (_) => WhatsappShareDialog(
                              bill: bill,
                              customer: customer,
                              goodsEntry: goodsEntry,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: color ?? const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
