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

class StockReportScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const StockReportScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends ConsumerState<StockReportScreen> with SingleTickerProviderStateMixin {
  AppThemeColors get theme => context.appTheme;

  late TabController _tabController;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
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
    final report = repo.getStockReportData(fromDate: _fromDate, toDate: _toDate);

    final filteredProducts = report.products.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.productName.toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredMovements = report.movements.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m.productName.toLowerCase().contains(_searchQuery) ||
          m.refNumber.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Stock Report', style: AppTypography.pageTitle.copyWith(color: theme.text)),
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
                    hintText: 'Search product or lot reference...',
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
                  // Stock KPI Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Available Stock',
                          amount: AppFormatters.quantity(report.totalClosing, 'units'),
                          subtitle: 'Current in warehouse',
                          icon: Icons.inventory_2_outlined,
                          accentColor: theme.primary,
                          isSelected: _tabController.index == 0,
                          onTap: () => setState(() => _tabController.animateTo(0)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Stock Valuation',
                          amount: AppFormatters.currency(report.totalStockValuation),
                          subtitle: 'Estimated inventory value',
                          icon: Icons.account_balance_wallet_outlined,
                          isSelected: _tabController.index == 0,
                          onTap: () => setState(() => _tabController.animateTo(0)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Inward Purchases',
                          amount: AppFormatters.quantity(report.totalPurchased, 'units'),
                          subtitle: 'Incoming arrivals',
                          icon: Icons.arrow_downward_rounded,
                          isSelected: _tabController.index == 1,
                          onTap: () => setState(() => _tabController.animateTo(1)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ReportSummaryCard(
                          title: 'Sold Outward',
                          amount: AppFormatters.quantity(report.totalSold, 'units'),
                          subtitle: 'Billed sales',
                          icon: Icons.arrow_upward_rounded,
                          accentColor: AppColors.warning,
                          isSelected: _tabController.index == 2,
                          onTap: () => setState(() => _tabController.animateTo(2)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Tabs
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
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Product-wise'),
                        Tab(text: 'Daily Summary'),
                        Tab(text: 'Movement Log'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tab Views
                  if (_tabController.index == 0)
                    _buildProductWiseList(filteredProducts)
                  else if (_tabController.index == 1)
                    _buildDailySummaryStock(report)
                  else
                    _buildMovementLog(filteredMovements),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductWiseList(List<StockReportProductItem> list) {
    if (list.isEmpty) {
      return _buildEmptyBox('No stock items match your filter.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = list[index];
        final remainingPct = item.purchasedQuantity > 0
            ? (item.closingStock / item.purchasedQuantity).clamp(0.0, 1.0)
            : 0.0;

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
                  Text(item.productName, style: AppTypography.cardTitle.copyWith(fontSize: 15.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.closingStock > 0 ? theme.accent : theme.accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.closingStock > 0 ? '${item.activeLotsCount} Active Lots' : 'Sold Out',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: item.closingStock > 0 ? theme.primary : theme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Stock equation: Opening + Inward - Sold = Closing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStockCol('Inward Qty', AppFormatters.quantity(item.purchasedQuantity, item.unit)),
                  _buildStockCol('Sold Qty', AppFormatters.quantity(item.soldQuantity, item.unit)),
                  _buildStockCol(
                    'Closing Stock',
                    AppFormatters.quantity(item.closingStock, item.unit),
                    isHighlight: true,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: remainingPct,
                  minHeight: 5,
                  backgroundColor: theme.background,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    remainingPct > 0.25 ? theme.primary : AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg Cost: ₹${item.averageRate.toStringAsFixed(1)} / ${item.unit}',
                    style: AppTypography.labelMuted,
                  ),
                  Text(
                    'Valuation: ${AppFormatters.currency(item.stockValuation)}',
                    style: AppTypography.label.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailySummaryStock(StockReportData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inventory Equation Reconciliation', style: AppTypography.sectionHeading),
          const SizedBox(height: 4),
          Text('Opening + Purchases - Sales = Closing Stock', style: AppTypography.labelMuted),
          Divider(height: 24, color: theme.border),
          _buildReconcileRow('1. Opening Warehouse Stock', AppFormatters.quantity(data.totalOpening, 'units')),
          _buildReconcileRow('2. (+) Inward Purchases Added', AppFormatters.quantity(data.totalPurchased, 'units'), color: theme.primary),
          _buildReconcileRow('3. (-) Outward Sales Deducted', AppFormatters.quantity(data.totalSold, 'units'), color: AppColors.warning),
          Divider(height: 20, color: theme.border),
          _buildReconcileRow(
            '4. (=) Closing Physical Stock',
            AppFormatters.quantity(data.totalClosing, 'units'),
            isBold: true,
            color: theme.primary,
          ),
          const SizedBox(height: 8),
          _buildReconcileRow(
            'Total Stock Valuation (₹)',
            AppFormatters.currency(data.totalStockValuation),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMovementLog(List<StockMovementItem> movements) {
    if (movements.isEmpty) {
      return _buildEmptyBox('No stock movements recorded in this period.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final m = movements[index];
        final isInward = m.type == 'INWARD LOT';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isInward ? theme.accent : AppColors.warningBg,
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(
                  isInward ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  size: 18,
                  color: isInward ? theme.primary : AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.productName, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                    Text(
                      '${m.refNumber} • ${AppFormatters.date(m.date)}',
                      style: AppTypography.labelMuted,
                    ),
                  ],
                ),
              ),
              Text(
                '${isInward ? '+' : '-'} ${AppFormatters.quantity(m.quantity, m.unit)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isInward ? theme.primary : AppColors.warning,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockCol(String label, String val, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMuted),
        const SizedBox(height: 2),
        Text(
          val,
          style: isHighlight
              ? AppTypography.cardTitle.copyWith(color: theme.primary, fontWeight: FontWeight.bold)
              : AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildReconcileRow(String label, String val, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? AppTypography.cardTitle.copyWith(fontSize: 14) : AppTypography.bodySecondary),
          Text(
            val,
            style: isBold
                ? AppTypography.cardTitle.copyWith(color: color, fontSize: 15)
                : AppTypography.body.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBox(String msg) {
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
