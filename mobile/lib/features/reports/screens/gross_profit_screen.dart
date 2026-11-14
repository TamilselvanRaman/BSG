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

class GrossProfitScreen extends ConsumerStatefulWidget {
  const GrossProfitScreen({super.key});

  @override
  ConsumerState<GrossProfitScreen> createState() => _GrossProfitScreenState();
}

class _GrossProfitScreenState extends ConsumerState<GrossProfitScreen> with SingleTickerProviderStateMixin {
  AppThemeColors get theme => context.appTheme;

  late TabController _tabController;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    final report = repo.getGrossProfitReport(fromDate: _fromDate, toDate: _toDate);

    final filteredProducts = report.productProfits.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.productName.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredTransactions = report.transactions.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.productName.toLowerCase().contains(_searchQuery) ||
          t.customerName.toLowerCase().contains(_searchQuery) ||
          t.billNumber.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Gross Profit', style: AppTypography.pageTitle.copyWith(color: theme.text)),
      ),
      body: Column(
        children: [
          // Filter bar & Date range
          Container(
            color: theme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                ReportDateRangePickerBar(
                  fromDate: _fromDate,
                  toDate: _toDate,
                  onRangeChanged: (start, end) {
                    setState(() {
                      _fromDate = start;
                      _toDate = end;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search product, buyer or bill number...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Gross Profit',
                          amount: AppFormatters.currency(report.grossProfit),
                          subtitle: 'Margin: ${report.profitPercentage.toStringAsFixed(1)}%',
                          icon: Icons.auto_graph_rounded,
                          accentColor: report.grossProfit >= 0 ? theme.primary : AppColors.error,
                          iconBg: report.grossProfit >= 0 ? theme.accent : AppColors.errorBg,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Profit Margin',
                          amount: '${report.profitPercentage.toStringAsFixed(1)}%',
                          subtitle: 'ROI on Goods Sold',
                          icon: Icons.percent_rounded,
                          accentColor: theme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Total Sales Turnover',
                          amount: AppFormatters.currency(report.totalSalesAmount),
                          subtitle: '${report.transactions.length} sales bills',
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Cost of Goods (COGS)',
                          amount: AppFormatters.currency(report.totalPurchaseCost),
                          subtitle: 'Base purchase cost',
                          icon: Icons.shopping_bag_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sub-tabs: Product-wise vs Transaction-wise
                  Container(
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: AppSpacing.borderRadiusMd,
                      border: Border.all(color: theme.border),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: theme.primary,
                      unselectedLabelColor: theme.textSecondary,
                      indicatorColor: theme.primary,
                      indicatorWeight: 2.5,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      tabs: const [
                        Tab(text: 'Product-wise Profit'),
                        Tab(text: 'Transaction Details'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tab contents
                  _tabController.index == 0
                      ? _buildProductProfitList(filteredProducts)
                      : _buildTransactionProfitList(filteredTransactions),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductProfitList(List<ProductProfitItem> list) {
    if (list.isEmpty) {
      return _buildEmptyCard('No product sales recorded in this date range.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = list[index];
        final isProfit = p.grossProfit >= 0;

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
                  Text(p.productName, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isProfit ? theme.accent : AppColors.errorBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${p.profitPercentage.toStringAsFixed(1)}% Margin',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isProfit ? theme.primary : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Sold: ${AppFormatters.quantity(p.quantitySold, p.unit)}',
                style: AppTypography.bodySecondary,
              ),
              Divider(height: 18, color: theme.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sales Value', style: AppTypography.labelMuted),
                      Text(AppFormatters.currency(p.salesValue), style: AppTypography.body),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Purchase Cost', style: AppTypography.labelMuted),
                      Text(AppFormatters.currency(p.purchaseCost), style: AppTypography.body),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Net Profit', style: AppTypography.labelMuted),
                      Text(
                        AppFormatters.currency(p.grossProfit),
                        style: AppTypography.cardTitle.copyWith(
                          color: isProfit ? theme.primary : AppColors.error,
                        ),
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

  Widget _buildTransactionProfitList(List<TransactionProfitItem> list) {
    if (list.isEmpty) {
      return _buildEmptyCard('No sales transactions match the filter.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = list[index];
        final isProfit = t.grossProfit >= 0;

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
              Text(
                '${t.customerName} • ${t.productName}',
                style: AppTypography.bodySecondary,
              ),
              Text(
                'Qty: ${AppFormatters.quantity(t.quantity, t.unit)} (Sell: ₹${t.sellRate} / Cost: ₹${t.costRate})',
                style: AppTypography.labelMuted,
              ),
              Divider(height: 16, color: theme.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sales: ${AppFormatters.currency(t.salesValue)}', style: AppTypography.labelMuted),
                  Text('Cost: ${AppFormatters.currency(t.purchaseCost)}', style: AppTypography.labelMuted),
                  Text(
                    'Profit: ${AppFormatters.currency(t.grossProfit)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: isProfit ? theme.primary : AppColors.error,
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
