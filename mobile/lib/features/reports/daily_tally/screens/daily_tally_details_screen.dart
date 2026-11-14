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
                _row('Labour Charges', '-${AppFormatters.currency(tally.labourExpense)}', theme, isLess: true),
                _row('Transport / Freight', '-${AppFormatters.currency(tally.transportExpense)}', theme, isLess: true),
                _row('Rent & Utilities', '-${AppFormatters.currency(tally.rentExpense + tally.utilitiesExpense)}', theme, isLess: true),
                _row('Tea & Refreshments', '-${AppFormatters.currency(tally.teaRefreshmentsExpense)}', theme, isLess: true),
                if (tally.otherExpense > 0)
                  _row('Other Expenses', '-${AppFormatters.currency(tally.otherExpense)}', theme, isLess: true),
                if (tally.totalCashPartyPayments > 0)
                  _row('Cash Party Payments', '-${AppFormatters.currency(tally.totalCashPartyPayments)}', theme, isLess: true),
                if (tally.bankDeposit > 0)
                  _row('Bank Cash Deposit', '-${AppFormatters.currency(tally.bankDeposit)}', theme, isLess: true),
                if (tally.otherCashOutflow > 0)
                  _row('Other Cash Outflow', '-${AppFormatters.currency(tally.otherCashOutflow)}', theme, isLess: true),
                Divider(color: theme.border),
                _row('Expected Closing Cash', AppFormatters.currency(tally.expectedClosingCash), theme, isBold: true, highlightColor: theme.primary),
                const SizedBox(height: 4),
                _row('Actual Cash Counted', AppFormatters.currency(tally.actualCashCounted), theme, isBold: true, highlightColor: tally.isBalanced ? theme.success : (tally.isSurplus ? theme.info : theme.error)),
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
}
