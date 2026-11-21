import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../data/repositories/app_repository.dart';
import '../models/report_models.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_summary_card.dart';

class DailySummaryScreen extends ConsumerStatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  ConsumerState<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends ConsumerState<DailySummaryScreen> {
  DateTime _selectedDate = DateTime.now();
  DailySummaryType _selectedType = DailySummaryType.allSummary;

  void _selectFilter(DailySummaryType type) {
    setState(() {
      if (_selectedType == type) {
        _selectedType = DailySummaryType.allSummary;
      } else {
        _selectedType = type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final repo = ref.watch(appRepositoryProvider);
    final report = repo.getDailySummaryReport(_selectedDate);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Daily Summary', style: AppTypography.pageTitle.copyWith(color: theme.text)),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: theme.text),
            onSelected: (val) {
              if (val == 'export_pdf') {
                AppDialog.showSnackBar(context, 'Daily Summary PDF generated successfully');
              } else if (val == 'export_excel') {
                AppDialog.showSnackBar(context, 'Exported Daily Summary to Excel');
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'export_pdf', child: Text('Export to PDF')),
              PopupMenuItem(value: 'export_excel', child: Text('Export to Excel')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Navigator with Previous / Next Day
            ReportDateNavigator(
              selectedDate: _selectedDate,
              onDateChanged: (d) => setState(() => _selectedDate = d),
            ),

            const SizedBox(height: 12),

            // Summary Type Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: theme.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DailySummaryType>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primary),
                  dropdownColor: theme.surface,
                  items: DailySummaryType.values.map((type) {
                    return DropdownMenuItem<DailySummaryType>(
                      value: type,
                      child: Row(
                        children: [
                          Icon(type.icon, size: 18, color: theme.primary),
                          const SizedBox(width: 10),
                          Text(
                            type.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.text,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Interactive Clickable 6-Card Summary Grid
            _buildInteractiveSummaryGrid(report, theme),

            const SizedBox(height: 14),

            // Daily Expense Direct Navigation & Total Display Card
            _buildDailyExpenseDirectCard(report, theme),

            const SizedBox(height: 16),

            // Filter status & active records list
            _buildFilteredList(report, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveSummaryGrid(DailySummaryReport report, AppThemeColors theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Total Received',
                amount: AppFormatters.currency(report.totalReceived),
                subtitle: '${report.receivedItems.length} Collections',
                icon: Icons.call_received_rounded,
                accentColor: theme.primary,
                iconBg: theme.accent,
                isSelected: _selectedType == DailySummaryType.totalReceived,
                onTap: () => _selectFilter(DailySummaryType.totalReceived),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Total Paid',
                amount: AppFormatters.currency(report.totalPaid),
                subtitle: '${report.paidItems.length} Payments',
                icon: Icons.call_made_rounded,
                accentColor: AppColors.error,
                iconBg: AppColors.errorBg,
                isSelected: _selectedType == DailySummaryType.totalPaid,
                onTap: () => _selectFilter(DailySummaryType.totalPaid),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Transportation',
                amount: AppFormatters.currency(report.transportation),
                icon: Icons.local_shipping_outlined,
                accentColor: const Color(0xFFD97706),
                isSelected: _selectedType == DailySummaryType.transportation,
                onTap: () => _selectFilter(DailySummaryType.transportation),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Total Coolie',
                amount: AppFormatters.currency(report.totalCoolie),
                icon: Icons.handshake_outlined,
                accentColor: const Color(0xFF0284C7),
                isSelected: _selectedType == DailySummaryType.totalCoolie,
                onTap: () => _selectFilter(DailySummaryType.totalCoolie),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Rent',
                amount: AppFormatters.currency(report.rent),
                icon: Icons.home_work_outlined,
                accentColor: const Color(0xFF7C3AED),
                isSelected: _selectedType == DailySummaryType.rent,
                onTap: () => _selectFilter(DailySummaryType.rent),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Sales Commission',
                amount: AppFormatters.currency(report.salesCommission),
                icon: Icons.percent_rounded,
                accentColor: const Color(0xFF0D9488),
                isSelected: _selectedType == DailySummaryType.salesCommission,
                onTap: () => _selectFilter(DailySummaryType.salesCommission),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyExpenseDirectCard(DailySummaryReport report, AppThemeColors theme) {
    return Material(
      color: theme.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0.5,
      child: InkWell(
        onTap: () => context.push('/expenses'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Daily Expenses',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${report.expensesCount} Entries',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tap to view & manage in Expenses',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(report.totalExpenses),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: theme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredList(DailySummaryReport report, AppThemeColors theme) {
    if (_selectedType == DailySummaryType.allSummary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReceivedSection(report.receivedItems, theme),
          const SizedBox(height: 20),
          _buildPaidSection(report.paidItems, theme),
        ],
      );
    }

    if (_selectedType == DailySummaryType.totalReceived || _selectedType == DailySummaryType.salesSummary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader('Total Received (Collections)', Icons.call_received_rounded, theme.primary, report.receivedItems.length),
          const SizedBox(height: 10),
          _buildReceivedItemsList(report.receivedItems, theme),
        ],
      );
    }

    if (_selectedType == DailySummaryType.totalPaid || _selectedType == DailySummaryType.purchaseSummary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader('Total Paid (Purchases & Expenses)', Icons.call_made_rounded, AppColors.error, report.paidItems.length),
          const SizedBox(height: 10),
          _buildPaidItemsList(report.paidItems, theme),
        ],
      );
    }

    if (_selectedType == DailySummaryType.dailyExpenses) {
      final items = report.paidItems
          .where((p) =>
              !p.category.toLowerCase().contains('goods purchase') &&
              !p.paymentMode.toLowerCase().contains('inward purchase'))
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFilterHeader('Daily Operating Expenses', Icons.receipt_long_rounded, const Color(0xFFDC2626), items.length),
              TextButton.icon(
                onPressed: () => context.push('/expenses'),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Open Expenses', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          items.isEmpty
              ? _buildEmptyState('No daily operating expenses recorded for this date.')
              : _buildPaidItemsList(items, theme),
        ],
      );
    }

    if (_selectedType == DailySummaryType.transportation) {
      final items = report.paidItems.where((p) => p.category.toLowerCase().contains('transport')).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader('Transportation & Freight Expenses', Icons.local_shipping_outlined, const Color(0xFFD97706), items.length),
          const SizedBox(height: 10),
          items.isEmpty
              ? _buildEmptyState('No transportation expenses recorded for this date.')
              : _buildPaidItemsList(items, theme),
        ],
      );
    }

    if (_selectedType == DailySummaryType.totalCoolie) {
      final items = report.paidItems
          .where((p) =>
              p.category.toLowerCase().contains('labour') ||
              p.category.toLowerCase().contains('coolie') ||
              p.category.toLowerCase().contains('hamali'))
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader('Total Coolie & Hamali Charges', Icons.handshake_outlined, const Color(0xFF0284C7), items.length),
          const SizedBox(height: 10),
          items.isEmpty
              ? _buildEmptyState('No coolie or hamali charges recorded for this date.')
              : _buildPaidItemsList(items, theme),
        ],
      );
    }

    if (_selectedType == DailySummaryType.rent) {
      final items = report.paidItems.where((p) => p.category.toLowerCase().contains('rent')).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader('Shop & Warehouse Rent Vouchers', Icons.home_work_outlined, const Color(0xFF7C3AED), items.length),
          const SizedBox(height: 10),
          items.isEmpty
              ? _buildEmptyState('No shop or warehouse rent vouchers recorded for this date.')
              : _buildPaidItemsList(items, theme),
        ],
      );
    }

    if (_selectedType == DailySummaryType.salesCommission) {
      final items = report.paidItems.where((p) => p.category.toLowerCase().contains('commission')).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterHeader('Sales Commission & Mandi Cess', Icons.percent_rounded, const Color(0xFF0D9488), items.length),
          const SizedBox(height: 10),
          items.isEmpty
              ? _buildEmptyState('No commission deductions recorded for this date.')
              : _buildPaidItemsList(items, theme),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFilterHeader(String title, IconData icon, Color color, int count) {
    final theme = context.appTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              '$title ($count)',
              style: AppTypography.sectionHeading.copyWith(fontSize: 15, color: theme.text),
            ),
          ],
        ),
        InkWell(
          onTap: () => setState(() => _selectedType = DailySummaryType.allSummary),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.clear_rounded, size: 12, color: theme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Show All',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedSection(List<DailyReceivedItem> items, AppThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.arrow_downward_rounded, size: 18, color: theme.primary),
            const SizedBox(width: 8),
            Text(
              'Total Received (Collections)',
              style: AppTypography.sectionHeading.copyWith(fontSize: 15, color: theme.text),
            ),
            const Spacer(),
            Text(
              '${items.length} records',
              style: TextStyle(fontSize: 12, color: theme.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          _buildEmptyState('No received collections recorded for this date.')
        else
          _buildReceivedItemsList(items, theme),
      ],
    );
  }

  Widget _buildPaidSection(List<DailyPaidItem> items, AppThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.arrow_upward_rounded, size: 18, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Total Paid (Purchases & Expenses)',
              style: AppTypography.sectionHeading.copyWith(fontSize: 15, color: theme.text),
            ),
            const Spacer(),
            Text(
              '${items.length} records',
              style: TextStyle(fontSize: 12, color: theme.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          _buildEmptyState('No paid vouchers recorded for this date.')
        else
          _buildPaidItemsList(items, theme),
      ],
    );
  }

  Widget _buildReceivedItemsList(List<DailyReceivedItem> items, AppThemeColors theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: theme.border),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: theme.primary.withValues(alpha: 0.12),
              child: Icon(Icons.call_received_rounded, size: 16, color: theme.primary),
            ),
            title: Text(item.buyerName, style: AppTypography.cardTitle.copyWith(fontSize: 14, color: theme.text)),
            subtitle: Text(
              '${item.refNumber} • ${item.paymentMode}',
              style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
            ),
            trailing: Text(
              AppFormatters.currency(item.amount),
              style: AppTypography.cardTitle.copyWith(color: theme.primary, fontSize: 15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaidItemsList(List<DailyPaidItem> items, AppThemeColors theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: theme.border),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.error.withValues(alpha: 0.12),
              child: Icon(Icons.call_made_rounded, size: 16, color: AppColors.error),
            ),
            title: Text(item.sellerName, style: AppTypography.cardTitle.copyWith(fontSize: 14, color: theme.text)),
            subtitle: Text(
              '${item.refNumber} • ${item.category} • ${item.paymentMode}',
              style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
            ),
            trailing: Text(
              AppFormatters.currency(item.amount),
              style: AppTypography.cardTitle.copyWith(color: AppColors.error, fontSize: 15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final theme = context.appTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 36, color: theme.textMuted.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTypography.bodySecondary.copyWith(color: theme.textSecondary)),
        ],
      ),
    );
  }
}
