import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/repositories/app_repository.dart';
import '../models/daily_tally_model.dart';

class DailyTallyDashboardScreen extends ConsumerStatefulWidget {
  const DailyTallyDashboardScreen({super.key});

  @override
  ConsumerState<DailyTallyDashboardScreen> createState() => _DailyTallyDashboardScreenState();
}

class _DailyTallyDashboardScreenState extends ConsumerState<DailyTallyDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allTallies = ref.watch(dailyTalliesProvider);

    // Find tally for selected date or fallback to latest
    final tallyForDay = allTallies.where((t) =>
        t.date.year == _selectedDate.year &&
        t.date.month == _selectedDate.month &&
        t.date.day == _selectedDate.day).firstOrNull;

    final latestTally = tallyForDay ?? allTallies.firstOrNull;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Daily Tally Dashboard',
          style: AppTypography.pageTitle.copyWith(color: theme.text),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: theme.text),
            tooltip: 'Tally History',
            onPressed: () => context.push('/reports/daily-tally/history'),
          ),
          IconButton(
            icon: Icon(Icons.calculate_outlined, color: theme.text),
            tooltip: 'Cash Reconciliation',
            onPressed: () => context.push('/reports/daily-tally/reconciliation'),
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
          // Date Selector Header
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, color: theme.text),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: theme.primary),
                        const SizedBox(width: 8),
                        Text(
                          AppFormatters.date(_selectedDate),
                          style: AppTypography.cardTitle.copyWith(
                            color: theme.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: theme.text),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Primary Balance Summary Banner
          if (latestTally != null) ...[
            _buildBalanceHeroCard(latestTally, theme),
          ] else ...[
            _buildNoTallyCard(theme),
          ],

          const SizedBox(height: 14),

          // Action Quick Buttons Row
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'New Daily Tally',
                  icon: Icons.add_rounded,
                  height: 44,
                  onPressed: () => context.push('/reports/daily-tally/create'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: 'Reconcile Cash',
                  icon: Icons.account_balance_wallet_outlined,
                  variant: ButtonVariant.secondary,
                  height: 44,
                  onPressed: () => context.push('/reports/daily-tally/reconciliation'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (latestTally != null) ...[
            // Breakdown Sections
            Text(
              'Cash Receipts & Inflows',
              style: AppTypography.sectionHeading.copyWith(color: theme.text),
            ),
            const SizedBox(height: 8),
            _buildReceiptsCard(latestTally, theme),

            const SizedBox(height: 16),

            Text(
              'Operating Expenses',
              style: AppTypography.sectionHeading.copyWith(color: theme.text),
            ),
            const SizedBox(height: 8),
            _buildExpensesCard(latestTally, theme),

            const SizedBox(height: 16),

            Text(
              'Party Payments & Bank Deposits',
              style: AppTypography.sectionHeading.copyWith(color: theme.text),
            ),
            const SizedBox(height: 8),
            _buildPartyPaymentsCard(latestTally, theme),

            const SizedBox(height: 20),

            // View Details Button
            AppButton(
              text: 'View Full Register Sheet (${latestTally.tallyNumber})',
              icon: Icons.receipt_long_outlined,
              variant: ButtonVariant.outline,
              onPressed: () => context.push('/reports/daily-tally/${latestTally.id}'),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBalanceHeroCard(DailyTally tally, AppThemeColors theme) {
    Color diffBg;
    Color diffFg;
    String statusText;

    if (tally.isBalanced) {
      diffBg = theme.success.withValues(alpha: 0.15);
      diffFg = theme.success;
      statusText = 'BALANCED (₹0.00)';
    } else if (tally.isSurplus) {
      diffBg = theme.info.withValues(alpha: 0.15);
      diffFg = theme.info;
      statusText = 'SURPLUS (+${AppFormatters.currency(tally.cashDifference)})';
    } else {
      diffBg = theme.error.withValues(alpha: 0.15);
      diffFg = theme.error;
      statusText = 'SHORTAGE (${AppFormatters.currency(tally.cashDifference)})';
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tally.tallyNumber,
                style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: diffBg,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: diffFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Expected Closing Cash',
            style: AppTypography.label.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            AppFormatters.currency(tally.expectedClosingCash),
            style: AppTypography.amountLarge.copyWith(
              color: theme.primary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: theme.border, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  'Opening Cash',
                  AppFormatters.currency(tally.openingCash),
                  theme.text,
                  theme,
                ),
              ),
              Container(width: 1, height: 36, color: theme.border),
              Expanded(
                child: _buildMetricTile(
                  'Available Cash',
                  AppFormatters.currency(tally.totalAvailableCash),
                  theme.text,
                  theme,
                ),
              ),
              Container(width: 1, height: 36, color: theme.border),
              Expanded(
                child: _buildMetricTile(
                  'Actual Counted',
                  AppFormatters.currency(tally.actualCashCounted),
                  tally.isBalanced ? theme.success : (tally.isSurplus ? theme.info : theme.error),
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valueColor, AppThemeColors theme) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelMuted.copyWith(color: theme.textMuted, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNoTallyCard(AppThemeColors theme) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Icon(Icons.edit_calendar_outlined, size: 48, color: theme.primary),
          const SizedBox(height: 12),
          Text(
            'No Tally for Selected Date',
            style: AppTypography.cardTitle.copyWith(
              color: theme.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a daily register tally to balance opening cash, sales, expenses, and cash-in-hand.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Record Tally for ${AppFormatters.date(_selectedDate)}',
            icon: Icons.add_rounded,
            height: 42,
            onPressed: () => context.push('/reports/daily-tally/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsCard(DailyTally tally, AppThemeColors theme) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildItemRow('Today\'s Cash Sales', AppFormatters.currency(tally.cashSales), theme),
          _buildItemRow('Outstanding Collected', AppFormatters.currency(tally.outstandingReceived), theme),
          _buildItemRow('Other Cash Inflow', AppFormatters.currency(tally.otherCashInflow), theme),
          _buildItemRow('Other Cash Received', AppFormatters.currency(tally.otherCashReceived), theme),
          Divider(color: theme.border),
          _buildItemRow(
            'Total Cash Inflows',
            AppFormatters.currency(tally.cashSales + tally.outstandingReceived + tally.otherCashReceived + tally.otherCashInflow),
            theme,
            isBold: true,
            color: theme.success,
          ),
          const SizedBox(height: 6),
          // Digital collections distinct from cash
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.accent,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.qr_code_2_rounded, size: 16, color: theme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Digital Collections (GPay 1 & 2)',
                      style: AppTypography.label.copyWith(color: theme.text, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  AppFormatters.currency(tally.totalDigitalReceived),
                  style: AppTypography.label.copyWith(color: theme.text, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesCard(DailyTally tally, AppThemeColors theme) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildItemRow('Labour Charges', AppFormatters.currency(tally.labourExpense), theme),
          _buildItemRow('Transport / Freight', AppFormatters.currency(tally.transportExpense), theme),
          _buildItemRow('Store Rent', AppFormatters.currency(tally.rentExpense), theme),
          _buildItemRow('Utilities / Power', AppFormatters.currency(tally.utilitiesExpense), theme),
          _buildItemRow('Tea & Refreshments', AppFormatters.currency(tally.teaRefreshmentsExpense), theme),
          _buildItemRow('Other Operating Expenses', AppFormatters.currency(tally.otherExpense), theme),
          Divider(color: theme.border),
          _buildItemRow(
            'Total Cash Expenses',
            AppFormatters.currency(tally.totalCashExpenses),
            theme,
            isBold: true,
            color: theme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildPartyPaymentsCard(DailyTally tally, AppThemeColors theme) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildItemRow('Cash Party Payments', AppFormatters.currency(tally.totalCashPartyPayments), theme),
          _buildItemRow('Bank Transfer to Parties', AppFormatters.currency(tally.totalDigitalPartyPayments), theme),
          _buildItemRow('Bank Cash Deposit', AppFormatters.currency(tally.bankDeposit), theme),
          _buildItemRow('Other Cash Outflow', AppFormatters.currency(tally.otherCashOutflow), theme),
          Divider(color: theme.border),
          _buildItemRow(
            'Total Cash Deductions',
            AppFormatters.currency(tally.totalCashExpenses + tally.totalCashPartyPayments + tally.bankDeposit + tally.otherCashOutflow),
            theme,
            isBold: true,
            color: theme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String title, String amount, AppThemeColors theme, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodySecondary.copyWith(
              color: isBold ? theme.text : theme.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          Text(
            amount,
            style: AppTypography.cardTitle.copyWith(
              color: color ?? theme.text,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
