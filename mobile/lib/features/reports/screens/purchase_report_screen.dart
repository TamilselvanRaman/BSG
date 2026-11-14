import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/app_repository.dart';
import '../models/report_models.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_summary_card.dart';

class PurchaseReportScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const PurchaseReportScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends ConsumerState<PurchaseReportScreen> with SingleTickerProviderStateMixin {
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
      length: 6,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 5),
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
    final report = repo.getPurchaseReportData(
      fromDate: _fromDate,
      toDate: _toDate,
    );

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Purchase Reports', style: AppTypography.pageTitle.copyWith(color: theme.text)),
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
                    hintText: 'Search seller, product or lot number...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Submenu Tabs (6 options)
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
                Tab(text: 'Summary'),
                Tab(text: 'By Seller'),
                Tab(text: 'By Product'),
                Tab(text: 'By Date'),
                Tab(text: 'Purchase Details'),
                Tab(text: 'Custom Report'),
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
                    _buildSummaryView(report),
                  ] else if (_tabController.index == 1) ...[
                    _buildBySellerView(report),
                  ] else if (_tabController.index == 2) ...[
                    _buildByProductView(report),
                  ] else if (_tabController.index == 3) ...[
                    _buildByDateView(report),
                  ] else if (_tabController.index == 4) ...[
                    _buildPurchaseDetailsView(report),
                  ] else ...[
                    _buildCustomReportView(report),
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

  // 1. Summary
  Widget _buildSummaryView(PurchaseReportData report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Total Inward Purchase',
                amount: AppFormatters.currency(report.totalPurchaseAmount),
                subtitle: '${report.totalLots} inward lots',
                icon: Icons.shopping_bag_outlined,
                accentColor: theme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Payable Balance',
                amount: AppFormatters.currency(report.outstandingPayable),
                subtitle: 'Supplier payables',
                icon: Icons.schedule_rounded,
                accentColor: AppColors.warning,
                iconBg: AppColors.warningBg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Total Quantity',
                amount: AppFormatters.quantity(report.totalQuantity, 'units'),
                subtitle: 'Weight: ${report.totalWeight.toInt()} Kg',
                icon: Icons.scale_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Active Sellers',
                amount: '${report.bySeller.length}',
                subtitle: 'Suppliers with inward lots',
                icon: Icons.people_outline_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. By Seller
  Widget _buildBySellerView(PurchaseReportData report) {
    final filtered = report.bySeller.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.sellerName.toLowerCase().contains(_searchQuery) || s.phone.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) return _buildEmptyCard('No sellers found.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final s = filtered[index];
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
                  Text(s.sellerName, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                  Text('${s.lotsCount} Lots', style: AppTypography.labelMuted),
                ],
              ),
              if (s.phone.isNotEmpty) Text('Contact: ${s.phone}', style: AppTypography.labelMuted),
              Divider(height: 16, color: theme.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Inward Cost', style: AppTypography.labelMuted),
                      Text(AppFormatters.currency(s.totalPurchase), style: AppTypography.body),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Payable Balance', style: AppTypography.labelMuted),
                      Text(
                        AppFormatters.currency(s.balancePayable),
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

  // 3. By Product
  Widget _buildByProductView(PurchaseReportData report) {
    final filtered = report.byProduct.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.productName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) return _buildEmptyCard('No product purchases found.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = filtered[index];
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
                  Text(
                    AppFormatters.currency(p.totalCost),
                    style: AppTypography.cardTitle.copyWith(color: theme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity: ${AppFormatters.quantity(p.totalQuantity, p.unit)} (${p.lotsCount} lots)',
                    style: AppTypography.bodySecondary,
                  ),
                  Text(
                    'Avg Cost: ₹${p.averageCostRate.toStringAsFixed(1)} / ${p.unit}',
                    style: AppTypography.labelMuted,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. By Date
  Widget _buildByDateView(PurchaseReportData report) {
    if (report.byDate.isEmpty) return _buildEmptyCard('No purchases recorded for this date range.');

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
                  Text('${d.lotsCount} Inward Lots • ${d.totalQuantity.toInt()} units', style: AppTypography.labelMuted),
                ],
              ),
              Text(
                AppFormatters.currency(d.totalPurchaseAmount),
                style: AppTypography.cardTitle.copyWith(color: theme.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  // 5. Purchase Details
  Widget _buildPurchaseDetailsView(PurchaseReportData report) {
    final filtered = report.lots.where((l) {
      if (_searchQuery.isEmpty) return true;
      return l.lotNumber.toLowerCase().contains(_searchQuery) ||
          l.supplierName.toLowerCase().contains(_searchQuery) ||
          l.productName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) return _buildEmptyCard('No inward lots recorded.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final l = filtered[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: theme.border),
          ),
          child: InkWell(
            onTap: () => context.push('/lots/${l.id}'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.lotNumber, style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text('${l.productName} • ${l.supplierName}', style: AppTypography.bodySecondary),
                    Text(
                      '${AppFormatters.quantity(l.initialQuantity, l.unit)} @ ₹${l.costRate} (Labour: ₹${l.labourCharge.toInt()})',
                      style: AppTypography.labelMuted,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppFormatters.currency(l.totalInitialCost), style: AppTypography.cardTitle),
                    Text(AppFormatters.date(l.date), style: AppTypography.labelMuted),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 6. Custom Report
  Widget _buildCustomReportView(PurchaseReportData report) {
    return Column(
      children: [
        _buildSummaryView(report),
        const SizedBox(height: 14),
        _buildPurchaseDetailsView(report),
      ],
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
