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
  bool _isExpensesExpanded = false;

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
            // Traditional Mandi Cash Tally Slip (Image 2 format)
            _buildTraditionalMandiSlip(latestTally, theme),

            const SizedBox(height: 20),

            // Operating Expenses (Collapsed by default, only Total Expenses displayed with Full View option)
            Text(
              'Operating Expenses',
              style: AppTypography.sectionHeading.copyWith(color: theme.text),
            ),
            const SizedBox(height: 8),
            _buildExpensesCard(latestTally, theme),

            const SizedBox(height: 16),

            // Breakdown Sections
            Text(
              'Cash Receipts & Inflows Breakdown',
              style: AppTypography.sectionHeading.copyWith(color: theme.text),
            ),
            const SizedBox(height: 8),
            _buildReceiptsCard(latestTally, theme),

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

  Widget _buildTraditionalMandiSlip(DailyTally tally, AppThemeColors theme) {
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
          _buildSlipExpenseRow('Expense', AppFormatters.currency(tally.totalCashExpenses), tally, theme),
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

  Widget _buildSlipExpenseRow(String title, String amount, DailyTally tally, AppThemeColors theme) {
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
                onTap: () => _showFullExpenseModal(tally, theme),
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

  Widget _buildExpensesCard(DailyTally tally, AppThemeColors theme) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        "Today's Total Expenses",
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      Text(
                        'Total Cash Expenses',
                        style: AppTypography.labelMuted.copyWith(color: theme.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(tally.totalCashExpenses),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpensesExpanded = !_isExpensesExpanded;
                      });
                    },
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
                            _isExpensesExpanded ? 'Hide Details' : 'Full View',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                          Icon(
                            _isExpensesExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: theme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_isExpensesExpanded) ...[
            const SizedBox(height: 12),
            Divider(color: theme.border, height: 1),
            const SizedBox(height: 10),
            _buildItemRow('Labour Charges', AppFormatters.currency(tally.labourExpense), theme),
            _buildItemRow('Transport / Freight', AppFormatters.currency(tally.transportExpense), theme),
            _buildItemRow('Store Rent', AppFormatters.currency(tally.rentExpense), theme),
            _buildItemRow('Utilities / Power', AppFormatters.currency(tally.utilitiesExpense), theme),
            _buildItemRow('Tea & Refreshments', AppFormatters.currency(tally.teaRefreshmentsExpense), theme),
            if (tally.otherExpense > 0)
              _buildItemRow('Other Operating Expenses', AppFormatters.currency(tally.otherExpense), theme),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _showFullExpenseModal(tally, theme),
              borderRadius: AppSpacing.borderRadiusSm,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: AppSpacing.borderRadiusSm,
                  border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 14, color: theme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'View All Expense Vouchers',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullExpenseModal(DailyTally tally, AppThemeColors theme) {
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
                      _buildItemRow('Labour Charges', AppFormatters.currency(tally.labourExpense), theme),
                      _buildItemRow('Transport / Freight', AppFormatters.currency(tally.transportExpense), theme),
                      _buildItemRow('Store Rent', AppFormatters.currency(tally.rentExpense), theme),
                      _buildItemRow('Utilities / Power', AppFormatters.currency(tally.utilitiesExpense), theme),
                      _buildItemRow('Tea & Refreshments', AppFormatters.currency(tally.teaRefreshmentsExpense), theme),
                      _buildItemRow('Other Operating Expenses', AppFormatters.currency(tally.otherExpense), theme),
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
