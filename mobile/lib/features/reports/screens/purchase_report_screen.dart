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

enum PurchaseSummaryFilter {
  allLots,
  payableLots,
  byProduct,
  bySeller,
}

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
  PurchaseSummaryFilter? _summaryFilter = PurchaseSummaryFilter.allLots;

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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                isSelected: _summaryFilter == PurchaseSummaryFilter.allLots,
                onTap: () => setState(() {
                  _summaryFilter = _summaryFilter == PurchaseSummaryFilter.allLots ? null : PurchaseSummaryFilter.allLots;
                }),
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
                isSelected: _summaryFilter == PurchaseSummaryFilter.payableLots,
                onTap: () => setState(() {
                  _summaryFilter = _summaryFilter == PurchaseSummaryFilter.payableLots ? null : PurchaseSummaryFilter.payableLots;
                }),
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
                isSelected: _summaryFilter == PurchaseSummaryFilter.byProduct,
                onTap: () => setState(() {
                  _summaryFilter = _summaryFilter == PurchaseSummaryFilter.byProduct ? null : PurchaseSummaryFilter.byProduct;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Active Sellers',
                amount: '${report.bySeller.length}',
                subtitle: 'Suppliers with inward lots',
                icon: Icons.people_outline_rounded,
                isSelected: _summaryFilter == PurchaseSummaryFilter.bySeller,
                onTap: () => setState(() {
                  _summaryFilter = _summaryFilter == PurchaseSummaryFilter.bySeller ? null : PurchaseSummaryFilter.bySeller;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildPurchaseSummaryFilteredSection(report),
      ],
    );
  }

  Widget _buildPurchaseSummaryFilteredSection(PurchaseReportData report) {
    if (_summaryFilter == PurchaseSummaryFilter.bySeller) {
      final sellers = report.bySeller;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader('Active Suppliers & Sellers', Icons.people_outline_rounded, theme.primary, sellers.length),
          const SizedBox(height: 10),
          if (sellers.isEmpty)
            _buildEmptyCard('No seller purchases recorded.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sellers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final s = sellers[index];
                return InkWell(
                  onTap: () => setState(() => _tabController.animateTo(1)),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.primary.withValues(alpha: 0.12),
                              child: Text(
                                s.sellerName.isNotEmpty ? s.sellerName[0].toUpperCase() : 'S',
                                style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.sellerName, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                                Text('${s.lotsCount} lots • Contact: ${s.phone.isNotEmpty ? s.phone : 'Supplier'}', style: AppTypography.labelMuted),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.currency(s.totalPurchase),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.primary),
                            ),
                            if (s.balancePayable > 0)
                              Text('Due: ${AppFormatters.currency(s.balancePayable)}', style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      );
    }

    if (_summaryFilter == PurchaseSummaryFilter.byProduct) {
      final products = report.byProduct;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader('Purchased Commodities & Crops', Icons.eco_outlined, theme.primary, products.length),
          const SizedBox(height: 10),
          if (products.isEmpty)
            _buildEmptyCard('No commodity purchases recorded.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = products[index];
                return InkWell(
                  onTap: () => setState(() => _tabController.animateTo(2)),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.primary.withValues(alpha: 0.12),
                              child: Icon(Icons.eco_rounded, size: 16, color: theme.primary),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.productName, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                                Text('${p.lotsCount} lots • ${p.totalQuantity.toInt()} ${p.unit}', style: AppTypography.labelMuted),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.currency(p.totalCost),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.primary),
                            ),
                            Text('₹${p.averageCostRate.toStringAsFixed(1)} / ${p.unit}', style: AppTypography.labelMuted),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      );
    }

    if (_summaryFilter == PurchaseSummaryFilter.payableLots) {
      final payableSellers = report.bySeller.where((s) => s.balancePayable > 0).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader('Supplier Payables (Outstanding)', Icons.schedule_rounded, AppColors.warning, payableSellers.length),
          const SizedBox(height: 10),
          if (payableSellers.isEmpty)
            _buildEmptyCard('All supplier payments are up to date! No outstanding payables.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payableSellers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final s = payableSellers[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.warningBg,
                            child: Text(
                              s.sellerName.isNotEmpty ? s.sellerName[0].toUpperCase() : 'S',
                              style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.sellerName, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                              Text('${s.lotsCount} lots • Paid: ${AppFormatters.currency(s.amountPaid)}', style: AppTypography.labelMuted),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Due: ${AppFormatters.currency(s.balancePayable)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warning),
                          ),
                          Text('Total: ${AppFormatters.currency(s.totalPurchase)}', style: AppTypography.labelMuted),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    }

    // Default: all inward lots
    final lots = report.lots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryHeader('All Inward Purchase Lots', Icons.shopping_bag_outlined, theme.primary, lots.length),
        const SizedBox(height: 10),
        if (lots.isEmpty)
          _buildEmptyCard('No purchase lots found for this selection.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lots.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final l = lots[index];
              return InkWell(
                onTap: () => context.push('/lots/${l.id}'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(l.lotNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l.productName,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(l.supplierName, style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                          Text(AppFormatters.date(l.date), style: AppTypography.labelMuted),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppFormatters.currency(l.totalInitialCost),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppFormatters.quantity(l.initialQuantity, l.unit),
                            style: TextStyle(fontSize: 11, color: theme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSummaryHeader(String title, IconData icon, Color color, int count) {
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
        if (_summaryFilter != null)
          InkWell(
            onTap: () => setState(() => _summaryFilter = PurchaseSummaryFilter.allLots),
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
                    'Reset',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.textSecondary),
                  ),
                ],
              ),
            ),
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
