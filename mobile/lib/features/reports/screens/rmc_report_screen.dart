import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/app_repository.dart';
import '../models/report_models.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_summary_card.dart';

class RmcReportScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const RmcReportScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<RmcReportScreen> createState() => _RmcReportScreenState();
}

class _RmcReportScreenState extends ConsumerState<RmcReportScreen> with SingleTickerProviderStateMixin {
  AppThemeColors get theme => context.appTheme;

  late TabController _tabController;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 4),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final report = repo.getRmcReportData(
      fromDate: _fromDate,
      toDate: _toDate,
    );

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('RMC Reports', style: AppTypography.pageTitle.copyWith(color: theme.text)),
      ),
      body: Column(
        children: [
          // Filter & Date Header
          Container(
            color: theme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                ReportDateRangePickerBar(
                  fromDate: _fromDate,
                  toDate: _toDate,
                  onRangeChanged: (s, e) => setState(() {
                    _fromDate = s;
                    _toDate = e;
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search buyer, crop or bill number...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Submenu Tabs (5 options)
          Container(
            color: theme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: theme.primary,
              unselectedLabelColor: theme.textSecondary,
              indicatorColor: theme.primary,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'RMC Summary'),
                Tab(text: 'Sales Report'),
                Tab(text: 'Transaction History'),
                Tab(text: 'Date-wise Report'),
                Tab(text: 'RMC Details'),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_tabController.index == 0) ...[
                    _buildRmcSummaryView(report),
                  ] else if (_tabController.index == 1) ...[
                    _buildRmcSalesView(report),
                  ] else if (_tabController.index == 2) ...[
                    _buildRmcHistoryView(report),
                  ] else if (_tabController.index == 3) ...[
                    _buildDateWiseView(report),
                  ] else ...[
                    _buildRmcDetailsView(report),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. RMC Summary
  Widget _buildRmcSummaryView(RmcReportData report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Total RMC Cess Fee',
                amount: AppFormatters.currency(report.totalRmcFee),
                subtitle: 'Rate: ${report.rmcRatePercent.toStringAsFixed(1)}% Mandi Cess',
                icon: Icons.account_balance_outlined,
                accentColor: theme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Taxable Turnover',
                amount: AppFormatters.currency(report.totalTaxableTurnover),
                subtitle: '${report.transactions.length} billed sales',
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'RMC Paid to Board',
                amount: AppFormatters.currency(report.rmcPaid),
                subtitle: 'Submitted remittances',
                icon: Icons.check_circle_outline_rounded,
                accentColor: theme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Pending RMC Liability',
                amount: AppFormatters.currency(report.rmcPending),
                subtitle: 'Due to Market Committee',
                icon: Icons.schedule_rounded,
                accentColor: AppColors.warning,
                iconBg: AppColors.warningBg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Regulated Market Committee Assessment', style: AppTypography.sectionHeading),
              const SizedBox(height: 4),
              Text('Calculated at statutory 1.0% on agricultural produce turnover', style: AppTypography.labelMuted),
              Divider(height: 20, color: theme.border),
              _buildAssessmentRow('Mandi Assessment Basis', 'Sales Invoice Gross Value'),
              _buildAssessmentRow('Statutory Cess Rate', '${report.rmcRatePercent.toStringAsFixed(1)}%'),
              _buildAssessmentRow('Total Eligible Sales', AppFormatters.currency(report.totalTaxableTurnover)),
              _buildAssessmentRow('Gross RMC Levy (₹)', AppFormatters.currency(report.totalRmcFee), isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  // 2. RMC Sales Report
  Widget _buildRmcSalesView(RmcReportData report) {
    final filtered = report.transactions.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.partnerName.toLowerCase().contains(_searchQuery) ||
          t.billNumber.toLowerCase().contains(_searchQuery) ||
          t.productName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) return _buildEmptyCard('No RMC taxable sales recorded.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = filtered[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t.billNumber, style: AppTypography.cardTitle),
                  Text(AppFormatters.date(t.date), style: AppTypography.labelMuted),
                ],
              ),
              const SizedBox(height: 2),
              Text('${t.partnerName} • ${t.productName}', style: AppTypography.bodySecondary),
              Text(
                'Quantity: ${AppFormatters.quantity(t.quantity, t.unit)}',
                style: AppTypography.labelMuted,
              ),
              Divider(height: 16, color: theme.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Turnover: ${AppFormatters.currency(t.taxableAmount)}', style: AppTypography.labelMuted),
                  Row(
                    children: [
                      Text('RMC 1%: ', style: AppTypography.labelMuted),
                      Text(
                        AppFormatters.currency(t.rmcAmount),
                        style: AppTypography.cardTitle.copyWith(color: theme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. RMC History
  Widget _buildRmcHistoryView(RmcReportData report) {
    return _buildRmcSalesView(report);
  }

  // 4. Date-wise RMC Report
  Widget _buildDateWiseView(RmcReportData report) {
    if (report.byDate.isEmpty) return _buildEmptyCard('No RMC date records found.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: report.byDate.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final d = report.byDate[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: theme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppFormatters.date(d.date), style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${d.transactionsCount} Bills • Turnover ${AppFormatters.currency(d.totalTurnover)}',
                    style: AppTypography.labelMuted,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(d.rmcCess),
                    style: AppTypography.cardTitle.copyWith(color: theme.primary),
                  ),
                  Text('RMC Cess', style: AppTypography.labelMuted),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 5. RMC Details
  Widget _buildRmcDetailsView(RmcReportData report) {
    return Column(
      children: [
        _buildRmcSummaryView(report),
        const SizedBox(height: 14),
        _buildRmcSalesView(report),
      ],
    );
  }

  Widget _buildAssessmentRow(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? AppTypography.cardTitle.copyWith(fontSize: 14) : AppTypography.bodySecondary),
          Text(
            val,
            style: isBold
                ? AppTypography.cardTitle.copyWith(fontSize: 15, color: theme.primary)
                : AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Center(child: Text(msg, style: AppTypography.bodySecondary)),
    );
  }
}
