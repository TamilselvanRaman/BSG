import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/localization/language_provider.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';
import '../../data/models/seller_load.dart';

class CommodityStockAggregate {
  final String commodity;
  final int totalInwardBags;
  final double soldBags;
  final double unsoldBags;
  final double grossWeight;
  final int activeLotsCount;
  final List<SellerLoad> lots;

  const CommodityStockAggregate({
    required this.commodity,
    required this.totalInwardBags,
    required this.soldBags,
    required this.unsoldBags,
    required this.grossWeight,
    required this.activeLotsCount,
    required this.lots,
  });

  double get sellThroughPercent {
    if (totalInwardBags == 0) return 0.0;
    return (soldBags / totalInwardBags).clamp(0.0, 1.0);
  }
}

class StockSummaryScreen extends ConsumerStatefulWidget {
  const StockSummaryScreen({super.key});

  @override
  ConsumerState<StockSummaryScreen> createState() => _StockSummaryScreenState();
}

class _StockSummaryScreenState extends ConsumerState<StockSummaryScreen> {
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final sellerLoads = ref.watch(sellerLoadsProvider);

    // Group loads by commodity
    final Map<String, List<SellerLoad>> grouped = {};
    for (final load in sellerLoads) {
      final key = load.commodity.trim().isEmpty ? 'General Produce' : load.commodity.trim();
      grouped.putIfAbsent(key, () => []).add(load);
    }

    final List<CommodityStockAggregate> aggregates = [];
    grouped.forEach((commodity, loads) {
      final totalInward = loads.fold<int>(0, (sum, l) => sum + l.totalBags);
      final totalSold = loads.fold<double>(0.0, (sum, l) => sum + l.soldBags);
      final totalUnsold = loads.fold<double>(0.0, (sum, l) => sum + l.unsoldBags);
      final totalWeight = loads.fold<double>(0.0, (sum, l) => sum + l.grossWeight);
      final activeLots = loads.where((l) => l.unsoldBags > 0).length;

      aggregates.add(CommodityStockAggregate(
        commodity: commodity,
        totalInwardBags: totalInward,
        soldBags: totalSold,
        unsoldBags: totalUnsold,
        grossWeight: totalWeight,
        activeLotsCount: activeLots,
        lots: loads,
      ));
    });

    // Apply search filter
    final filtered = aggregates.where((a) {
      if (_searchQuery.isEmpty) return true;
      return a.commodity.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final totalWarehouseBags = aggregates.fold<double>(0.0, (sum, a) => sum + a.unsoldBags);
    final totalInwardToday = aggregates.fold<int>(0, (sum, a) => sum + a.totalInwardBags);
    final totalSoldToday = aggregates.fold<double>(0.0, (sum, a) => sum + a.soldBags);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ref.tr('inventory'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            Text(
              '${ref.tr('stockMovementTable')} • ${DateFormatter.format(_selectedDate)}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: AppColors.primaryGreen),
            tooltip: 'Select Stock Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          maxWidth: 1200,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top KPI Summary Cards Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;
                  return Row(
                    children: [
                      Expanded(
                        child: _buildKpiBox(
                          title: ref.tr('closingStock'),
                          value: '${totalWarehouseBags.toInt()} Bags',
                          subtitle: 'Live In-Store Unsold',
                          color: const Color(0xFF1E6B24),
                          icon: Icons.inventory_2_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildKpiBox(
                          title: ref.tr('inwardPurchases'),
                          value: '$totalInwardToday Bags',
                          subtitle: 'Arrival Truck Loads',
                          color: const Color(0xFF2563EB),
                          icon: Icons.local_shipping_rounded,
                        ),
                      ),
                      if (isWide) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKpiBox(
                            title: ref.tr('outwardSales'),
                            value: '${totalSoldToday.toInt()} Bags',
                            subtitle: 'Billed to Wholesale Buyers',
                            color: const Color(0xFF059669),
                            icon: Icons.point_of_sale_rounded,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Search Bar
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search commodity name...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5)),
                ),
              ),

              const SizedBox(height: 18),

              // Section Label: Product-wise stock
              Text(
                ref.tr('productWiseStock').toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 10),

              // Commodity Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final crossAxisCount = isWide ? 3 : 1;

                  if (!isWide) {
                    return Column(
                      children: filtered.map((item) => _buildCommodityCard(context, item)).toList(),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildCommodityCard(context, filtered[i]),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Section Label: Stock Movement Register Table
              Text(
                ref.tr('stockMovementTable').toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 10),

              // Responsive Data Table
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF334155), fontSize: 13),
                    dataTextStyle: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                    columns: [
                      DataColumn(label: Text(ref.tr('commodity'))),
                      DataColumn(label: Text(ref.tr('inwardPurchases'))),
                      DataColumn(label: Text(ref.tr('outwardSales'))),
                      DataColumn(label: Text(ref.tr('closingStock'))),
                      const DataColumn(label: Text('Sell-Through')),
                      const DataColumn(label: Text('Action')),
                    ],
                    rows: filtered.map((item) {
                      final pct = (item.sellThroughPercent * 100).toStringAsFixed(1);
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.eco_rounded, size: 16, color: AppColors.primaryGreen),
                                const SizedBox(width: 8),
                                Text(item.commodity, style: const TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          DataCell(Text('${item.totalInwardBags} BG')),
                          DataCell(Text('${item.soldBags.toInt()} BG')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.unsoldBags > 0 ? AppColors.lightGreenSurface : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item.unsoldBags.toInt()} BG',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: item.unsoldBags > 0 ? AppColors.primaryGreenDark : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: LinearProgressIndicator(
                                    value: item.sellThroughPercent,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
                                    borderRadius: BorderRadius.circular(4),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('$pct%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          DataCell(
                            TextButton.icon(
                              icon: const Icon(Icons.list_alt_rounded, size: 16),
                              label: const Text('View Lots', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              onPressed: () => _showLotDrilldownDialog(context, item),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiBox({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityCard(BuildContext context, CommodityStockAggregate item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreenSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.commodity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.activeLotsCount} Active Lots',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStockStat('Inward', '${item.totalInwardBags} BG'),
              _buildStockStat('Sold', '${item.soldBags.toInt()} BG'),
              _buildStockStat('Stock', '${item.unsoldBags.toInt()} BG', isHighlight: true),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: item.sellThroughPercent,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1E6B24)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isHighlight ? AppColors.primaryGreenDark : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  void _showLotDrilldownDialog(BuildContext context, CommodityStockAggregate item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.commodity} - Lot Inventory',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${item.lots.length} arrival loads make up this commodity inventory.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      itemCount: item.lots.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (c, i) {
                        final lot = item.lots[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreenSurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  lot.effectiveLotNumber,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.primaryGreenDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(lot.sellerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                    Text('${lot.vehicleNumber} • ${lot.varietyGrade}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${lot.unsoldBags.toInt()} BG Unsold',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1E6B24)),
                                  ),
                                  Text(
                                    'of ${lot.totalBags} total',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
