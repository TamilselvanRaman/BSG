import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/customer_picker_sheet.dart';
import '../../../data/models/bill_model.dart';
import '../../../data/models/partner_models.dart';
import '../../../data/repositories/app_repository.dart';
import '../../catalogue/widgets/product_crop_selector_sheet.dart';
import '../models/report_models.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_summary_card.dart';

class SalesReportScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final String? initialBuyerId;
  final String? initialCropName;

  const SalesReportScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialBuyerId,
    this.initialCropName,
  });

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> with SingleTickerProviderStateMixin {
  AppThemeColors get theme => context.appTheme;

  late TabController _tabController;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  BillType? _billTypeFilter;

  // Selected filters for drill-down views
  String? _selectedBuyerId;
  String? _selectedCropName;

  @override
  void initState() {
    super.initState();
    _selectedBuyerId = widget.initialBuyerId;
    _selectedCropName = widget.initialCropName;

    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 5),
    );
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

  Future<void> _pickBuyer() async {
    final chosen = await CustomerPickerSheet.show(
      context,
      allowCounterSale: false,
      selectedCustomerId: _selectedBuyerId,
    );
    if (!mounted) return;
    if (chosen is Customer) {
      setState(() {
        _selectedBuyerId = chosen.id;
      });
    }
  }

  Future<void> _pickCrop() async {
    final chosen = await ProductCropSelectorSheet.show(
      context,
      allowMultiple: false,
    );
    if (!mounted) return;
    if (chosen != null && chosen.isNotEmpty) {
      setState(() {
        _selectedCropName = chosen.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final report = repo.getSalesReportData(
      fromDate: _fromDate,
      toDate: _toDate,
      type: _billTypeFilter,
    );

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Sales Reports', style: AppTypography.pageTitle.copyWith(color: theme.text)),
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
                  decoration: const InputDecoration(
                    hintText: 'Search buyer, crop or bill number...',
                    prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.border),

          // Scrollable Submenu Tabs (6 options)
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
                Tab(text: 'By Buyer'),
                Tab(text: 'By Crop / Product'),
                Tab(text: 'By Date'),
                Tab(text: 'Bill Details'),
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
                    _buildSalesSummaryView(report),
                  ] else if (_tabController.index == 1) ...[
                    _buildByBuyerView(report),
                  ] else if (_tabController.index == 2) ...[
                    _buildByCropView(report),
                  ] else if (_tabController.index == 3) ...[
                    _buildByDateView(report),
                  ] else if (_tabController.index == 4) ...[
                    _buildBillDetailsView(report),
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

  // 1. Sales Summary
  Widget _buildSalesSummaryView(SalesReportData report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportSummaryCard(
                title: 'Total Sales Revenue',
                amount: AppFormatters.currency(report.totalSales),
                subtitle: '${report.totalBills} bills issued',
                icon: Icons.trending_up_rounded,
                accentColor: theme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Amount Received',
                amount: AppFormatters.currency(report.totalReceived),
                subtitle: 'Cash collections',
                icon: Icons.check_circle_outline_rounded,
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
                title: 'Outstanding Due',
                amount: AppFormatters.currency(report.totalOutstanding),
                subtitle: 'Customer receivables',
                icon: Icons.schedule_rounded,
                accentColor: AppColors.warning,
                iconBg: AppColors.warningBg,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReportSummaryCard(
                title: 'Total Quantity Sold',
                amount: AppFormatters.quantity(report.totalQuantity, 'units'),
                subtitle: 'Weight: ${report.totalWeight.toInt()} Kg',
                icon: Icons.scale_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. By Buyer
  Widget _buildByBuyerView(SalesReportData report) {
    final repo = ref.read(appRepositoryProvider);
    final allCustomers = repo.getCustomers();

    // If a specific buyer is selected, display that buyer's full statement & bills
    if (_selectedBuyerId != null) {
      final cust = allCustomers.where((c) => c.id == _selectedBuyerId).firstOrNull;
      final buyerItem = report.byBuyer.where((b) => b.buyerId == _selectedBuyerId).firstOrNull;
      final buyerName = cust?.name ?? buyerItem?.buyerName ?? 'Selected Buyer';
      final buyerPhone = cust?.phone ?? buyerItem?.phone ?? '';
      final buyerCity = cust?.city ?? '';
      final buyerBills = report.bills.where((b) {
        return b.customerId == _selectedBuyerId || b.customerName.toLowerCase() == buyerName.toLowerCase();
      }).toList();

      final double totalSales = buyerItem?.totalSales ?? buyerBills.fold<double>(0.0, (sum, b) => sum + b.totalAmount);
      final double totalReceived = buyerItem?.amountReceived ?? buyerBills.fold<double>(0.0, (sum, b) => sum + b.amountReceived);
      final double balanceDue = buyerItem?.balanceDue ?? cust?.currentOutstanding ?? (totalSales - totalReceived);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Buyer Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.primary,
                  child: Text(
                    buyerName.isNotEmpty ? buyerName[0].toUpperCase() : 'B',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyerName,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [if (buyerPhone.isNotEmpty) buyerPhone, if (buyerCity.isNotEmpty) buyerCity].join(' • '),
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickBuyer,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: theme.textMuted,
                  onPressed: () => setState(() => _selectedBuyerId = null),
                  tooltip: 'Show all buyers',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Buyer Financial Overview KPIs
          Row(
            children: [
              Expanded(
                child: ReportSummaryCard(
                  title: 'Total Billed',
                  amount: AppFormatters.currency(totalSales),
                  subtitle: '${buyerBills.length} invoices',
                  icon: Icons.receipt_long_rounded,
                  accentColor: theme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReportSummaryCard(
                  title: 'Amount Received',
                  amount: AppFormatters.currency(totalReceived),
                  subtitle: 'Cash & transfers',
                  icon: Icons.check_circle_rounded,
                  accentColor: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
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
                    const Text('Outstanding Balance Due', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.currency(balanceDue),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: balanceDue > 0 ? AppColors.error : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/users/customers/$_selectedBuyerId'),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 14),
                  label: const Text('View Ledger', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Invoices Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sales Invoices for $buyerName', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
              Text('${buyerBills.length} Bills', style: AppTypography.labelMuted),
            ],
          ),
          const SizedBox(height: 10),

          if (buyerBills.isEmpty)
            _buildEmptyCard('No sales bills found for this buyer in the selected date range.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buyerBills.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final b = buyerBills[index];
                return InkWell(
                  onTap: () => context.push('/bills/${b.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(b.billNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: b.type == BillType.cash ? theme.accent : AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    b.type == BillType.cash ? 'CASH' : 'CREDIT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: b.type == BillType.cash ? theme.primary : AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              AppFormatters.currency(b.totalAmount),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${b.productName} • ${AppFormatters.quantity(b.quantity, b.unit)} @ ${AppFormatters.currency(b.sellRate)}',
                          style: TextStyle(fontSize: 12.5, color: theme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppFormatters.date(b.date), style: TextStyle(fontSize: 11, color: theme.textMuted)),
                            Row(
                              children: [
                                Text(
                                  b.status == BillStatus.paid
                                      ? 'Paid'
                                      : b.status == BillStatus.partiallyPaid
                                          ? 'Partially Paid (Due: ${AppFormatters.currency(b.balanceDue)})'
                                          : 'Unpaid (Due: ${AppFormatters.currency(b.balanceDue)})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: b.status == BillStatus.paid
                                        ? const Color(0xFF16A34A)
                                        : AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
                              ],
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

    // Default: List of all buyers with interactive selector bar at top
    final filtered = report.byBuyer.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.buyerName.toLowerCase().contains(_searchQuery) || b.phone.contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buyer Filter Selector Header
        InkWell(
          onTap: _pickBuyer,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_alt_rounded, size: 18, color: theme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by Specific Buyer',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tap to select a buyer and view their full statement',
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('Choose', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Registered Buyers', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
            Text('${filtered.length} Buyers', style: AppTypography.labelMuted),
          ],
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          _buildEmptyCard('No buyers match your filter.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final b = filtered[index];
              return InkWell(
                onTap: () => setState(() => _selectedBuyerId = b.buyerId),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: theme.primary.withValues(alpha: 0.15),
                                child: Text(
                                  b.buyerName.isNotEmpty ? b.buyerName[0].toUpperCase() : 'B',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.primary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(b.buyerName, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${b.billsCount} Bills',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primary),
                            ),
                          ),
                        ],
                      ),
                      if (b.phone.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Phone: ${b.phone}', style: AppTypography.labelMuted),
                      ],
                      Divider(height: 16, color: theme.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Sales', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              Text(AppFormatters.currency(b.totalSales), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Received', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              Text(
                                AppFormatters.currency(b.amountReceived),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Balance Due', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              Text(
                                AppFormatters.currency(b.balanceDue),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: b.balanceDue > 0 ? AppColors.error : theme.text,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('View full report & bills', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: theme.primary)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: theme.primary),
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

  // 3. By Crop / Product
  Widget _buildByCropView(SalesReportData report) {
    // If a specific crop is selected, display that commodity's full breakdown & bills
    if (_selectedCropName != null) {
      final cropItem = report.byCrop.where((c) => c.cropName.toLowerCase() == _selectedCropName!.toLowerCase()).firstOrNull;
      final cropBills = report.bills.where((b) {
        return b.productName.toLowerCase().contains(_selectedCropName!.toLowerCase());
      }).toList();

      final double totalSales = cropItem?.totalSales ?? cropBills.fold<double>(0.0, (sum, b) => sum + b.totalAmount);
      final double totalQty = cropItem?.totalQuantity ?? cropBills.fold<double>(0.0, (sum, b) => sum + b.quantity);
      final double avgRate = cropItem?.averageRate ?? (totalQty > 0 ? totalSales / totalQty : 0.0);
      final String unit = cropItem?.unit ?? 'Kg';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Crop Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.agriculture_rounded, size: 20, color: Color(0xFF16A34A)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCropName!,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Filtered commodity sales statement',
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickCrop,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: theme.textMuted,
                  onPressed: () => setState(() => _selectedCropName = null),
                  tooltip: 'Show all crops',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Product Summary KPIs
          Row(
            children: [
              Expanded(
                child: ReportSummaryCard(
                  title: 'Sales Revenue',
                  amount: AppFormatters.currency(totalSales),
                  subtitle: '${cropBills.length} invoices',
                  icon: Icons.trending_up_rounded,
                  accentColor: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReportSummaryCard(
                  title: 'Quantity Sold',
                  amount: AppFormatters.quantity(totalQty, unit),
                  subtitle: 'Total volume',
                  icon: Icons.scale_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ReportSummaryCard(
                  title: 'Avg Selling Rate',
                  amount: '₹${avgRate.toStringAsFixed(1)} / $unit',
                  subtitle: 'Weighted average price',
                  icon: Icons.price_check_rounded,
                  accentColor: theme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ReportSummaryCard(
                  title: 'Total Invoices',
                  amount: '${cropBills.length}',
                  subtitle: 'Transactions',
                  icon: Icons.receipt_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // All Bills Featuring this Crop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sales Bills with $_selectedCropName', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
              Text('${cropBills.length} Bills', style: AppTypography.labelMuted),
            ],
          ),
          const SizedBox(height: 10),

          if (cropBills.isEmpty)
            _buildEmptyCard('No sales bills found for this crop in the selected date range.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cropBills.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final b = cropBills[index];
                return InkWell(
                  onTap: () => context.push('/bills/${b.id}'),
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
                                Text(b.billNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: b.type == BillType.cash ? theme.accent : AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    b.type == BillType.cash ? 'CASH' : 'CREDIT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: b.type == BillType.cash ? theme.primary : AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text('Buyer: ${b.customerName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(
                              '${AppFormatters.quantity(b.quantity, b.unit)} @ ${AppFormatters.currency(b.sellRate)}',
                              style: TextStyle(fontSize: 11, color: theme.textMuted),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.currency(b.totalAmount),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: theme.primary),
                            ),
                            const SizedBox(height: 2),
                            Text(AppFormatters.date(b.date), style: TextStyle(fontSize: 11, color: theme.textMuted)),
                            const SizedBox(height: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
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

    // Default: List of all crops with interactive selector bar at top
    final filtered = report.byCrop.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.cropName.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crop Filter Selector Header
        InkWell(
          onTap: _pickCrop,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.spa_rounded, size: 18, color: Color(0xFF16A34A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by Specific Good / Product',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tap to pick a commodity and view its complete report',
                        style: TextStyle(fontSize: 11, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('Choose', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Crops & Products', style: AppTypography.sectionHeading.copyWith(color: theme.text)),
            Text('${filtered.length} Commodities', style: AppTypography.labelMuted),
          ],
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          _buildEmptyCard('No crop sales recorded.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final c = filtered[index];
              return InkWell(
                onTap: () => setState(() => _selectedCropName = c.cropName),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF16A34A)),
                              ),
                              const SizedBox(width: 8),
                              Text(c.cropName, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                            ],
                          ),
                          Text(
                            AppFormatters.currency(c.totalSales),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sold: ${AppFormatters.quantity(c.totalQuantity, c.unit)}',
                            style: AppTypography.bodySecondary,
                          ),
                          Text(
                            'Avg Rate: ₹${c.averageRate.toStringAsFixed(1)} / ${c.unit}',
                            style: AppTypography.labelMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'View full product report',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF16A34A)),
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

  // 4. By Date
  Widget _buildByDateView(SalesReportData report) {
    if (report.byDate.isEmpty) return _buildEmptyCard('No sales data for this date range.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: report.byDate.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final d = report.byDate[index];
        final dayBills = report.bills.where((b) {
          return b.date.year == d.date.year && b.date.month == d.date.month && b.date.day == d.date.day;
        }).toList();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.calendar_today_rounded, size: 16, color: theme.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(AppFormatters.date(d.date), style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                    ],
                  ),
                  Text(
                    AppFormatters.currency(d.totalSales),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: theme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${d.billsCount} Bills (Cash: ₹${d.cashSales.toInt()} | Credit: ₹${d.creditSales.toInt()})',
                    style: AppTypography.labelMuted,
                  ),
                  Text(
                    '${dayBills.length} Invoices',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primary),
                  ),
                ],
              ),
              if (dayBills.isNotEmpty) ...[
                const Divider(height: 16),
                ...dayBills.take(3).map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () => context.push('/bills/${b.id}'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${b.billNumber} • ${b.customerName} (${b.productName})',
                                style: const TextStyle(fontSize: 11.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              AppFormatters.currency(b.totalAmount),
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: theme.primary),
                            ),
                          ],
                        ),
                      ),
                    )),
                if (dayBills.length > 3)
                  InkWell(
                    onTap: () => _tabController.animateTo(4),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${dayBills.length - 3} more bills... (View all)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.primary),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  // 5. Sales Bill Details
  Widget _buildBillDetailsView(SalesReportData report) {
    final filtered = report.bills.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.billNumber.toLowerCase().contains(_searchQuery) ||
          b.customerName.toLowerCase().contains(_searchQuery) ||
          b.productName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) return _buildEmptyCard('No bill records found.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = filtered[index];
        return InkWell(
          onTap: () => context.push('/bills/${b.id}'),
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
                        Text(b.billNumber, style: AppTypography.cardTitle),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: b.type == BillType.cash ? theme.accent : AppColors.warningBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            b.type == BillType.cash ? 'CASH' : 'CREDIT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: b.type == BillType.cash ? theme.primary : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${b.customerName} • ${b.productName}', style: AppTypography.bodySecondary),
                    Text(
                      '${AppFormatters.quantity(b.quantity, b.unit)} @ ${AppFormatters.currency(b.sellRate)}',
                      style: AppTypography.labelMuted,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppFormatters.currency(b.totalAmount), style: AppTypography.cardTitle),
                    Text(AppFormatters.date(b.date), style: AppTypography.labelMuted),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 6. Custom Sales Report
  Widget _buildCustomReportView(SalesReportData report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Bill Type', style: AppTypography.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypePill('All Bills', null),
                  const SizedBox(width: 8),
                  _buildTypePill('Cash Only', BillType.cash),
                  const SizedBox(width: 8),
                  _buildTypePill('Credit Only', BillType.credit),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSalesSummaryView(report),
        const SizedBox(height: 14),
        _buildBillDetailsView(report),
      ],
    );
  }

  Widget _buildTypePill(String label, BillType? type) {
    final isSel = _billTypeFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _billTypeFilter = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? theme.primary : AppColors.reportBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSel ? Colors.white : theme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border),
      ),
      child: Center(child: Text(msg, style: AppTypography.bodySecondary)),
    );
  }
}
