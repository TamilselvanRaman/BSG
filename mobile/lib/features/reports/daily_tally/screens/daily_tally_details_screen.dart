import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/app_repository.dart';
import '../models/daily_tally_model.dart';

class DailyTallyDetailsScreen extends ConsumerWidget {
  final String id;

  const DailyTallyDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final allTallies = ref.watch(dailyTalliesProvider);
    final tally = allTallies.where((t) => t.id == id).firstOrNull;

    if (tally == null) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: Text('Daily Tally Details', style: TextStyle(color: theme.text))),
        body: Center(
          child: Text('Tally record not found.', style: TextStyle(color: theme.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(tally.tallyNumber, style: AppTypography.pageTitle.copyWith(color: theme.text)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: 'Delete Tally',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: theme.surface,
                  title: Text('Delete Daily Tally?', style: TextStyle(color: theme.text)),
                  content: Text('Are you sure you want to delete ${tally.tallyNumber}?', style: TextStyle(color: theme.textSecondary)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        ref.read(appRepositoryProvider).deleteDailyTally(tally.id);
                        Navigator.pop(ctx);
                        context.pop();
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: theme.border, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Status Banner
          _buildStatusBanner(tally, theme),

          const SizedBox(height: 16),

          // Traditional Mandi Cash Tally Slip (Image 2 format)
          _buildTraditionalMandiSlip(context, ref, tally, theme),

          const SizedBox(height: 16),

          // Audit Table
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cash Register Reconciliation', style: AppTypography.cardTitle.copyWith(color: theme.text, fontWeight: FontWeight.bold)),
                    Text(AppFormatters.date(tally.date), style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                  ],
                ),
                const SizedBox(height: 14),
                _row('Yesterday Closing (Opening Cash)', AppFormatters.currency(tally.openingCash), theme, isAdd: true),
                _row('Cash Sales', AppFormatters.currency(tally.cashSales), theme, isAdd: true),
                _row('Outstanding Collected', AppFormatters.currency(tally.outstandingReceived), theme, isAdd: true),
                if (tally.otherCashReceived > 0)
                  _row('Other Cash Received', AppFormatters.currency(tally.otherCashReceived), theme, isAdd: true),
                if (tally.otherCashInflow > 0)
                  _row('Other Cash Inflow', AppFormatters.currency(tally.otherCashInflow), theme, isAdd: true),
                Divider(color: theme.border),
                _row('Total Available Cash', AppFormatters.currency(tally.totalAvailableCash), theme, isBold: true, highlightColor: theme.success),
                const SizedBox(height: 10),
                // Compact Total Expenses with Full View option
                _rowWithAction(
                  'Today\'s Operating Expenses',
                  '-${AppFormatters.currency(tally.totalCashExpenses)}',
                  theme,
                  actionText: 'Full View',
                  onAction: () => _showFullExpenseModal(context, ref, tally, theme),
                  highlightColor: theme.error,
                ),
                if (tally.totalCashPartyPayments > 0)
                  _row('Cash Party Payments', '-${AppFormatters.currency(tally.totalCashPartyPayments)}', theme, isLess: true),
                if (tally.bankDeposit > 0)
                  _row('Bank Cash Deposit', '-${AppFormatters.currency(tally.bankDeposit)}', theme, isLess: true),
                if (tally.otherCashOutflow > 0)
                  _row('Other Cash Outflow', '-${AppFormatters.currency(tally.otherCashOutflow)}', theme, isLess: true),
                Divider(color: theme.border),
                _row('Expected Closing Cash', AppFormatters.currency(tally.expectedClosingCash), theme, isBold: true, highlightColor: theme.primary),
                const SizedBox(height: 4),
                _row('Actual Cash Counted (Cash in Hand)', AppFormatters.currency(tally.actualCashCounted), theme, isBold: true, highlightColor: tally.isBalanced ? theme.success : (tally.isSurplus ? theme.info : theme.error)),
                const SizedBox(height: 4),
                _row(
                  'Difference (Variance)',
                  tally.isBalanced
                      ? '₹0.00 (Balanced)'
                      : (tally.isSurplus ? '+${AppFormatters.currency(tally.cashDifference)}' : AppFormatters.currency(tally.cashDifference)),
                  theme,
                  isBold: true,
                  highlightColor: tally.isBalanced ? theme.success : (tally.isSurplus ? theme.info : theme.error),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Party Payments Detail
          if (tally.partyPayments.isNotEmpty) ...[
            Text('Party Payments Detail', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: tally.partyPayments.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.partyName, style: AppTypography.cardTitle.copyWith(color: theme.text, fontSize: 13.5)),
                            Text('${p.mode.displayName}${p.reference != null ? ' • ${p.reference}' : ''}', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
                          ],
                        ),
                        Text(AppFormatters.currency(p.amount), style: TextStyle(color: theme.text, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Digital Memo
          if (tally.totalDigitalReceived > 0) ...[
            Text('Digital Inflows Memo (UPI / Bank)', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _row('GPay 1 Received', AppFormatters.currency(tally.gpay1Received), theme),
                  _row('GPay 2 Received', AppFormatters.currency(tally.gpay2Received), theme),
                  Divider(color: theme.border),
                  _row('Total Digital Received', AppFormatters.currency(tally.totalDigitalReceived), theme, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Notes
          if (tally.notes != null && tally.notes!.isNotEmpty) ...[
            Text('Notes & Remarks', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Text(tally.notes!, style: TextStyle(color: theme.text)),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner(DailyTally tally, AppThemeColors theme) {
    Color bg;
    Color fg;
    String status;

    if (tally.isBalanced) {
      bg = theme.success.withValues(alpha: 0.15);
      fg = theme.success;
      status = 'CASH RECONCILED & BALANCED';
    } else if (tally.isSurplus) {
      bg = theme.info.withValues(alpha: 0.15);
      fg = theme.info;
      status = 'SURPLUS OF +${AppFormatters.currency(tally.cashDifference)}';
    } else {
      bg = theme.error.withValues(alpha: 0.15);
      fg = theme.error;
      status = 'SHORTAGE OF ${AppFormatters.currency(tally.cashDifference)}';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(tally.isBalanced ? Icons.check_circle_rounded : Icons.info_outline_rounded, color: fg, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13.5)),
                Text('Recorded on ${AppFormatters.dateTime(tally.createdAt)}', style: AppTypography.labelMuted.copyWith(color: theme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String amount, AppThemeColors theme, {bool isAdd = false, bool isLess = false, bool isBold = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySecondary.copyWith(
              color: isBold ? theme.text : theme.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Text(
            amount,
            style: AppTypography.cardTitle.copyWith(
              color: highlightColor ?? theme.text,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWithAction(
    String label,
    String amount,
    AppThemeColors theme, {
    required String actionText,
    required VoidCallback onAction,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.bodySecondary.copyWith(
                  color: theme.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionText,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primary),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 9, color: theme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: AppTypography.cardTitle.copyWith(
              color: highlightColor ?? theme.text,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionalMandiSlip(BuildContext context, WidgetRef ref, DailyTally tally, AppThemeColors theme) {
    final inwardCashSubtotal = tally.cashSales + tally.outstandingReceived + tally.openingCash;
    final totalOverallCash = tally.actualCashCounted + tally.gpay1Received + tally.gpay2Received;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slip Top Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: theme.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_rounded, size: 18, color: theme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Cash Tally Slip',
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.text,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.border),
                  ),
                  child: Text(
                    AppFormatters.date(tally.date),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primary),
                  ),
                ),
              ],
            ),
          ),

          // 10 Exact Mandi Slip Rows (Matching Traditional Mandi Cash Sheet)
          _buildSlipRow('Cash Sales', AppFormatters.currency(tally.cashSales), theme),
          _buildSlipRow('Outstanding Received', AppFormatters.currency(tally.outstandingReceived), theme),
          _buildSlipRow('Yesterday Cash', AppFormatters.currency(tally.openingCash), theme),
          _buildSlipRow(
            'Total Cash',
            AppFormatters.currency(inwardCashSubtotal),
            theme,
            isHighlight: true,
            highlightColor: theme.success,
          ),
          _buildSlipExpenseRow('Expense', AppFormatters.currency(tally.totalCashExpenses), () => _showFullExpenseModal(context, ref, tally, theme), theme),
          _buildSlipRow('G-Pay 1', AppFormatters.currency(tally.gpay1Received), theme),
          _buildSlipRow('G-Pay 2', AppFormatters.currency(tally.gpay2Received), theme),
          _buildSlipRow(
            'Cash In Hand',
            AppFormatters.currency(tally.actualCashCounted),
            theme,
            isBold: true,
          ),
          _buildSlipRow(
            'Total Cash',
            AppFormatters.currency(totalOverallCash),
            theme,
            isHighlight: true,
            highlightColor: theme.primary,
          ),
          _buildSlipRow(
            'Petti Cash in Hand',
            AppFormatters.currency(tally.pettyCashInHand),
            theme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSlipRow(
    String title,
    String amount,
    AppThemeColors theme, {
    bool isHighlight = false,
    Color? highlightColor,
    bool isBold = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlight
            ? (highlightColor ?? theme.primary).withValues(alpha: 0.08)
            : Colors.transparent,
        border: isLast ? null : Border(bottom: BorderSide(color: theme.border.withValues(alpha: 0.6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isHighlight || isBold ? 14 : 13.5,
              fontWeight: isHighlight || isBold ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? (highlightColor ?? theme.primary) : theme.text,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isHighlight || isBold ? 14.5 : 14,
              fontWeight: isHighlight || isBold ? FontWeight.w800 : FontWeight.w700,
              color: isHighlight ? (highlightColor ?? theme.primary) : theme.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlipExpenseRow(String title, String amount, VoidCallback onFullView, AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.error.withValues(alpha: 0.04),
        border: Border(bottom: BorderSide(color: theme.border.withValues(alpha: 0.6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.error,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onFullView,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Full View',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.error,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 9, color: theme.error),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            '-$amount',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: theme.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullExpenseModal(BuildContext context, WidgetRef ref, DailyTally tally, AppThemeColors theme) {
    final allExpenses = ref.read(appRepositoryProvider).getExpenses().where((e) =>
        e.date.year == tally.date.year &&
        e.date.month == tally.date.month &&
        e.date.day == tally.date.day).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollCtrl) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ListView(
              controller: scrollCtrl,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.outbox_rounded, color: theme.error, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Expense Breakdown",
                              style: AppTypography.cardTitle.copyWith(color: theme.text, fontSize: 16),
                            ),
                            Text(
                              'Total: ${AppFormatters.currency(tally.totalCashExpenses)}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.error),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: AppSpacing.borderRadiusMd,
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    children: [
                      _row('Labour Charges', AppFormatters.currency(tally.labourExpense), theme),
                      _row('Transport / Freight', AppFormatters.currency(tally.transportExpense), theme),
                      _row('Store Rent', AppFormatters.currency(tally.rentExpense), theme),
                      _row('Utilities / Power', AppFormatters.currency(tally.utilitiesExpense), theme),
                      _row('Tea & Refreshments', AppFormatters.currency(tally.teaRefreshmentsExpense), theme),
                      if (tally.otherExpense > 0)
                        _row('Other Operating Expenses', AppFormatters.currency(tally.otherExpense), theme),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Itemized Expense Vouchers (${allExpenses.length})',
                  style: AppTypography.sectionHeading.copyWith(color: theme.text, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (allExpenses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No voucher records logged for today.',
                        style: TextStyle(color: theme.textMuted),
                      ),
                    ),
                  )
                else
                  ...allExpenses.map((exp) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exp.title, style: TextStyle(fontWeight: FontWeight.bold, color: theme.text, fontSize: 13.5)),
                                Text('${exp.category}${exp.paidTo != null ? " • ${exp.paidTo}" : ""}', style: TextStyle(fontSize: 11.5, color: theme.textSecondary)),
                              ],
                            ),
                            Text(
                              AppFormatters.currency(exp.amount),
                              style: TextStyle(fontWeight: FontWeight.w700, color: theme.error, fontSize: 14),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
