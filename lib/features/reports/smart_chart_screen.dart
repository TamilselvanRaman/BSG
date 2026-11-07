import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';
import '../../data/models/seller_load.dart';
import '../seller_loads/create_seller_load_dialog.dart';
import '../../core/localization/language_provider.dart';
import '../../core/localization/language_selector_button.dart';

class SmartChartScreen extends ConsumerStatefulWidget {
  const SmartChartScreen({super.key});

  @override
  ConsumerState<SmartChartScreen> createState() => _SmartChartScreenState();
}

class _SmartChartScreenState extends ConsumerState<SmartChartScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int _selectedPeriodIndex = 0; // 0: Today, 1: 7 Days, 2: This Month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellerLoads = ref.watch(sellerLoadsProvider);
    final summary = ref.watch(dailySummaryProvider);
    final metrics = ref.watch(dashboardMetricsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    final filteredLoads = sellerLoads.where((load) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return load.sellerName.toLowerCase().contains(q) ||
          load.loadNumber.toLowerCase().contains(q) ||
          load.lotNumber.toLowerCase().contains(q) ||
          load.vehicleNumber.toLowerCase().contains(q) ||
          load.commodity.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Smart Chart',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
            tooltip: 'New Arrival Lot',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CreateSellerLoadDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B)),
            tooltip: 'Pick Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).setDate(picked);
              }
            },
          ),
          const LanguageSelectorButton(),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreenDark,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3.5,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(text: ref.tr('arrivalAuction')),
            Tab(text: ref.tr('liveChart')),
            Tab(text: ref.tr('salesSummary')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Arrival Auction (Photos 1 & 3)
          _buildArrivalAuctionTab(filteredLoads),

          // TAB 2: Smart Chart (Interactive Graphs & Trends)
          _buildAnalyticsChartsTab(summary, metrics, selectedDate),

          // TAB 3: Sales Summary (Financial Reconciliation)
          _buildSalesSummaryTab(summary),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: ARRIVAL AUCTION (Matching Photos 1 & 3)
  // ==========================================
  Widget _buildArrivalAuctionTab(List<SellerLoad> loads) {
    return ResponsiveContainer(
      maxWidth: 960,
      child: Column(
        children: [
          // Search Bar matching Photo 3: "Search by Seller Name"
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search by Seller Name',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // List of Arrival Lots
          Expanded(
            child: loads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 54, color: Color(0xFFCBD5E1)),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty ? 'No Arrival Lots Found' : 'No lots matching "$_searchQuery"',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: loads.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final load = loads[index];
                      return _buildArrivalLotCard(load);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Card matching Photo 1 & 3 with extreme fidelity!
  Widget _buildArrivalLotCard(SellerLoad load) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Farmer Avatar, Name, Farmer Code, Vehicle, Lot Date, Lot No & Menu
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Green Circle Silhouette Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Color(0xFF16A34A), size: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Farmer Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        load.sellerName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Farmer - ${load.farmerCode} | ${load.maskedPhone}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      if (load.vehicleNumber.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          load.vehicleNumber,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),

                // Lot Date & Lot Number
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Lot Date',
                          style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.format(load.arrivalDate),
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          'Lot No.',
                          style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          load.effectiveLotNumber,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                  ],
                ),

                // 3-dots Menu Popup matching Photo 1: "Create Lot", "Create Bill"
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 150),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onSelected: (val) {
                    if (val == 'create_lot') {
                      showDialog(
                        context: context,
                        builder: (_) => const CreateSellerLoadDialog(),
                      );
                    } else if (val == 'create_bill') {
                      context.push('/bills/new?lotNumber=${load.effectiveLotNumber}&sellerId=${load.sellerId}');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'create_lot',
                      child: Row(
                        children: [
                          Icon(Icons.add_box_outlined, size: 18, color: Color(0xFF475569)),
                          SizedBox(width: 10),
                          Text('Create Lot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'create_bill',
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.primaryGreen),
                          SizedBox(width: 10),
                          Text('Create Bill', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Inner Produce Box matching Photos 1 & 3:
          // Commodity thumbnail (Red Onion), Commodity name, Variety Grade, Unsold/Sold bags, [Auction / Trade] button
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Commodity Thumbnail (Red Onion / Vegetable illustration)
                _buildCommodityThumbnail(load.commodity),
                const SizedBox(width: 12),

                // Produce Title, Variety Grade & Bags Sold/Unsold
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            load.commodity,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '( ${load.varietyGrade} )',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          Text(
                            'Unsold: ${load.unsoldBags.toStringAsFixed(1)} BG',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          Text(
                            'Sold: ${load.soldBags.toStringAsFixed(1)} BG',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Green Action Button: "Auction / Trade" matching Photo 1 & 3!
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Add Bill with lot preselected!
                    context.push('/bills/new?lotNumber=${load.effectiveLotNumber}&sellerId=${load.sellerId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Auction / Trade',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityThumbnail(String commodity) {
    // Red Onion visual badge
    final isTomato = commodity.toLowerCase().contains('tomato');
    final isChilli = commodity.toLowerCase().contains('chilli');

    Color badgeBg = const Color(0xFFFCE7F3);
    Color badgeBorder = const Color(0xFFF472B6);
    String emoji = '🧅';

    if (isTomato) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeBorder = const Color(0xFFF87171);
      emoji = '🍅';
    } else if (isChilli) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeBorder = const Color(0xFF4ADE80);
      emoji = '🌶️';
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeBorder.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  // ==========================================
  // TAB 2: SMART CHART (Analytics & Visuals)
  // ==========================================
  Widget _buildAnalyticsChartsTab(dynamic summary, dynamic metrics, DateTime selectedDate) {
    return ResponsiveContainer(
      maxWidth: 960,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter Pill Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  _buildFilterChip('Today (${DateFormatter.format(selectedDate)})', 0),
                  _buildFilterChip('Last 7 Days', 1),
                  _buildFilterChip('This Month', 2),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Metric Tiles
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: "Today's Turnover",
                    value: CurrencyFormatter.format(summary.activeSalesTotal),
                    subtitle: '${summary.billsCount} Active Bills',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Collections',
                    value: CurrencyFormatter.format(summary.totalCollections),
                    subtitle: '${CurrencyFormatter.format(summary.initialPaymentsReceived)} Advances',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Trading Bar Chart
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hourly Mandi Sales Volume',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const Text('Morning arrival rush vs Evening settlement', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 60,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                const labels = ['5 AM', '7 AM', '9 AM', '11 AM', '1 PM', '3 PM', '5 PM'];
                                final idx = val.toInt();
                                if (idx >= 0 && idx < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(labels[idx], style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _makeBarGroup(0, 20, const Color(0xFF10B981)),
                          _makeBarGroup(1, 48, AppColors.primaryGreen),
                          _makeBarGroup(2, 56, const Color(0xFF15803D)),
                          _makeBarGroup(3, 38, const Color(0xFF10B981)),
                          _makeBarGroup(4, 25, const Color(0xFF0284C7)),
                          _makeBarGroup(5, 30, const Color(0xFF0284C7)),
                          _makeBarGroup(6, 15, const Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Commodity distribution
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Commodity Breakdown (Today)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: AppSpacing.md),
                  _buildCommodityBar('Bellary Onion (வெங்காயம்)', 0.52, '52%', '₹1,24,000', const Color(0xFFF59E0B)),
                  const SizedBox(height: AppSpacing.md),
                  _buildCommodityBar('Country Tomato (தக்காளி)', 0.30, '30%', '₹72,400', const Color(0xFFEF4444)),
                  const SizedBox(height: AppSpacing.md),
                  _buildCommodityBar('Hill Potato (உருளைக்கிழங்கு)', 0.18, '18%', '₹43,600', const Color(0xFF8B5CF6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: SALES SUMMARY (Financial Reconciliation)
  // ==========================================
  Widget _buildSalesSummaryTab(dynamic summary) {
    return ResponsiveContainer(
      maxWidth: 960,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Today's Gross Sales", CurrencyFormatter.format(summary.activeSalesTotal), isBold: true),
                  const Divider(height: 20),
                  _buildSummaryRow("Initial Advances Collected", CurrencyFormatter.format(summary.initialPaymentsReceived)),
                  const SizedBox(height: 8),
                  _buildSummaryRow("Bill Payment Receipts", CurrencyFormatter.format(summary.totalCollections - summary.initialPaymentsReceived)),
                  const Divider(height: 20),
                  _buildSummaryRow("Total Cash & Bank Realized", CurrencyFormatter.format(summary.totalCollections), isBold: true, color: AppColors.primaryGreen),
                  const Divider(height: 20),
                  _buildSummaryRow("Day Outstanding Balance", CurrencyFormatter.format(summary.outstandingBalance), isBold: true, color: const Color(0xFFDC2626)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/reports/daily-summary'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Full Day Close Statement', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: const Color(0xFF334155))),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: color ?? const Color(0xFF0F172A))),
      ],
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedPeriodIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriodIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildCommodityBar(String name, double progress, String percent, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Row(
              children: [
                Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(percent, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}
