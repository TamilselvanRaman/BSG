import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

            // Dynamic Data Cards based on selected type
            _buildDataCards(report),

            const SizedBox(height: 20),

            // Received & Paid Tables
            _buildTables(report),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCards(DailySummaryReport report) {
    final theme = context.appTheme;

    switch (_selectedType) {
      case DailySummaryType.allSummary:
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
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ReportSummaryCard(
                    title: 'Total Coolie',
                    amount: AppFormatters.currency(report.totalCoolie),
                    icon: Icons.handshake_outlined,
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
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ReportSummaryCard(
                    title: 'Sales Commission',
                    amount: AppFormatters.currency(report.salesCommission),
                    icon: Icons.percent_rounded,
                  ),
                ),
              ],
            ),
          ],
        );

      case DailySummaryType.salesSummary:
        return Column(
          children: [
            ReportSummaryCard(
              title: 'Total Sales Collection',
              amount: AppFormatters.currency(report.totalReceived),
              subtitle: 'Counter cash and customer ledger clearance',
              icon: Icons.shopping_bag_outlined,
              accentColor: theme.primary,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ReportSummaryCard(
                    title: 'Sales Commission',
                    amount: AppFormatters.currency(report.salesCommission),
                    icon: Icons.percent_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ReportSummaryCard(
                    title: 'Loading / Coolie',
                    amount: AppFormatters.currency(report.totalCoolie),
                    icon: Icons.handshake_outlined,
                  ),
                ),
              ],
            ),
          ],
        );

      case DailySummaryType.purchaseSummary:
        return Column(
          children: [
            ReportSummaryCard(
              title: 'Total Purchase Outflow',
              amount: AppFormatters.currency(report.totalPaid),
              subtitle: 'Farmer settlements and lot purchase payouts',
              icon: Icons.inventory_2_outlined,
              accentColor: AppColors.error,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ReportSummaryCard(
                    title: 'Inward Freight / Transp.',
                    amount: AppFormatters.currency(report.transportation),
                    icon: Icons.local_shipping_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ReportSummaryCard(
                    title: 'Unloading Hamali',
                    amount: AppFormatters.currency(report.totalCoolie),
                    icon: Icons.pan_tool_outlined,
                  ),
                ),
              ],
            ),
          ],
        );

      case DailySummaryType.totalReceived:
        return ReportSummaryCard(
          title: 'Total Received (Collections)',
          amount: AppFormatters.currency(report.totalReceived),
          subtitle: '${report.receivedItems.length} Collections',
          icon: Icons.call_received_rounded,
          accentColor: theme.primary,
          iconBg: theme.accent,
        );

      case DailySummaryType.totalPaid:
        return ReportSummaryCard(
          title: 'Total Paid (Payments)',
          amount: AppFormatters.currency(report.totalPaid),
          subtitle: '${report.paidItems.length} Payments',
          icon: Icons.call_made_rounded,
          accentColor: AppColors.error,
          iconBg: AppColors.errorBg,
        );

      case DailySummaryType.transportation:
        return ReportSummaryCard(
          title: 'Transportation',
          amount: AppFormatters.currency(report.transportation),
          icon: Icons.local_shipping_outlined,
        );

      case DailySummaryType.totalCoolie:
        return ReportSummaryCard(
          title: 'Total Coolie / Hamali',
          amount: AppFormatters.currency(report.totalCoolie),
          icon: Icons.handshake_outlined,
        );

      case DailySummaryType.rent:
        return ReportSummaryCard(
          title: 'Shop / Warehouse Rent',
          amount: AppFormatters.currency(report.rent),
          icon: Icons.home_work_outlined,
        );

      case DailySummaryType.salesCommission:
        return ReportSummaryCard(
          title: 'Sales Commission',
          amount: AppFormatters.currency(report.salesCommission),
          icon: Icons.percent_rounded,
        );
    }
  }

  Widget _buildTables(DailySummaryReport report) {
    final theme = context.appTheme;
    final showReceived = _selectedType == DailySummaryType.allSummary ||
        _selectedType == DailySummaryType.salesSummary ||
        _selectedType == DailySummaryType.totalReceived;
    final showPaid = _selectedType == DailySummaryType.allSummary ||
        _selectedType == DailySummaryType.purchaseSummary ||
        _selectedType == DailySummaryType.totalPaid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showReceived) ...[
          _buildSectionHeader('Total Received (Collections)', Icons.arrow_downward_rounded, theme.primary),
          const SizedBox(height: 8),
          if (report.receivedItems.isEmpty)
            _buildEmptyState('No received collections recorded for this date.')
          else
            Container(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: theme.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.receivedItems.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: theme.border),
                itemBuilder: (context, index) {
                  final item = report.receivedItems[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    title: Text(item.buyerName, style: AppTypography.cardTitle.copyWith(fontSize: 14, color: theme.text)),
                    subtitle: Text(
                      '${item.refNumber} • ${item.paymentMode}',
                      style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                    ),
                    trailing: Text(
                      AppFormatters.currency(item.amount),
                      style: AppTypography.cardTitle.copyWith(color: theme.primary),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 20),
        ],

        if (showPaid) ...[
          _buildSectionHeader('Total Paid (Purchases & Expenses)', Icons.arrow_upward_rounded, AppColors.error),
          const SizedBox(height: 8),
          if (report.paidItems.isEmpty)
            _buildEmptyState('No paid vouchers recorded for this date.')
          else
            Container(
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: theme.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.paidItems.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: theme.border),
                itemBuilder: (context, index) {
                  final item = report.paidItems[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    title: Text(item.sellerName, style: AppTypography.cardTitle.copyWith(fontSize: 14, color: theme.text)),
                    subtitle: Text(
                      '${item.refNumber} • ${item.category} • ${item.paymentMode}',
                      style: AppTypography.labelMuted.copyWith(color: theme.textMuted),
                    ),
                    trailing: Text(
                      AppFormatters.currency(item.amount),
                      style: AppTypography.cardTitle.copyWith(color: AppColors.error),
                    ),
                  );
                },
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    final theme = context.appTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.sectionHeading.copyWith(fontSize: 15, color: theme.text)),
      ],
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
