import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';
import '../../data/models/seller_load.dart';
import 'create_seller_load_dialog.dart';

class SellerHistoryScreen extends ConsumerStatefulWidget {
  final String sellerId;

  const SellerHistoryScreen({super.key, required this.sellerId});

  @override
  ConsumerState<SellerHistoryScreen> createState() => _SellerHistoryScreenState();
}

class _SellerHistoryScreenState extends ConsumerState<SellerHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellerLoads = ref.watch(sellerLoadsProvider);
    final customers = ref.watch(customersProvider);
    final allBills = ref.watch(billsProvider);

    // Find all loads matching this seller
    final loads = sellerLoads.where((l) {
      return l.sellerId == widget.sellerId ||
          l.id == widget.sellerId ||
          l.loadNumber.toLowerCase() == widget.sellerId.toLowerCase() ||
          l.sellerName.toLowerCase().contains(widget.sellerId.toLowerCase());
    }).toList();

    // Find linked customer profile if any
    final customer = customers.cast<Customer?>().firstWhere(
      (c) => c?.id == widget.sellerId || (loads.isNotEmpty && c?.name == loads.first.sellerName),
      orElse: () => null,
    );

    final sellerName = customer?.name ?? (loads.isNotEmpty ? loads.first.sellerName : 'Farmer / Seller');
    final farmerCode = loads.isNotEmpty ? loads.first.farmerCode : (customer?.phone ?? 'N/A');
    final phone = customer?.phone ?? (loads.isNotEmpty ? loads.first.phone : '');
    final village = customer?.village ?? (loads.isNotEmpty ? loads.first.village : '');

    // Aggregated Metrics
    final totalLoads = loads.length;
    final totalBags = loads.fold(0, (sum, l) => sum + l.totalBags);
    final totalSoldBags = loads.fold(0.0, (sum, l) => sum + l.soldBags);
    final totalUnsoldBags = loads.fold(0.0, (sum, l) => sum + l.unsoldBags);
    final totalAdvances = loads.fold(0.0, (sum, l) => sum + l.advancePaidToSeller);

    // Match bills linked to this seller's lots
    final sellerLotNumbers = loads.map((l) => l.effectiveLotNumber.toLowerCase()).toSet();
    final linkedBills = allBills.where((b) {
      if (b.items.isEmpty) return false;
      // Match if linked through goods entry or item description
      return sellerLotNumbers.any((lot) =>
          b.items.any((i) => i.description.toLowerCase().contains(lot)) ||
          (b.goodsEntryId != null && sellerLotNumbers.contains(b.goodsEntryId!.toLowerCase())));
    }).toList();

    final totalSalesValue = linkedBills.fold(0.0, (sum, b) => sum + b.currentBillTotal);
    final estimatedPayable = (totalSalesValue * 0.95) - totalAdvances;

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
              sellerName,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
            ),
            Text(
              'Farmer Code: $farmerCode • $village',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF16A34A)),
            tooltip: 'Create New Inward Load',
            onPressed: () => CreateSellerLoadDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E6B24),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          indicatorColor: const Color(0xFF1E6B24),
          indicatorWeight: 3,
          isScrollable: true,
          tabs: [
            Tab(text: 'Inward Loads ($totalLoads)'),
            Tab(text: 'Auction Bills (${linkedBills.length})'),
            const Tab(text: 'Farmer Advances'),
            const Tab(text: 'Farmer Ledger'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Seller Profile & KPI Header
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: ResponsiveContainer(
              maxWidth: 960,
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Color(0xFF16A34A), size: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sellerName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Phone: $phone | $village',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // Action: Add Load Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New Load', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        onPressed: () => CreateSellerLoadDialog.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4 Summary Metric Cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: _buildMetricPill(
                            'Total Bags',
                            '$totalBags BG',
                            Icons.inventory_2_outlined,
                            const Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 120,
                          child: _buildMetricPill(
                            'Sold Bags',
                            '${totalSoldBags.toStringAsFixed(0)} BG',
                            Icons.check_circle_outline,
                            const Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 130,
                          child: _buildMetricPill(
                            'In Hand (Unsold)',
                            '${totalUnsoldBags.toStringAsFixed(0)} BG',
                            Icons.hourglass_bottom,
                            const Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 130,
                          child: _buildMetricPill(
                            'Advances Paid',
                            CurrencyFormatter.format(totalAdvances),
                            Icons.payments_outlined,
                            const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Inward Loads
                _buildLoadsTab(loads),

                // TAB 2: Auction Bills
                _buildBillsTab(linkedBills),

                // TAB 3: Farmer Advances
                _buildAdvancesTab(loads, totalAdvances),

                // TAB 4: Farmer Ledger
                _buildLedgerTab(loads, linkedBills, totalAdvances, estimatedPayable),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Inward Loads
  Widget _buildLoadsTab(List<SellerLoad> loads) {
    if (loads.isEmpty) {
      return const Center(child: Text('No inward loads recorded for this farmer.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: loads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final load = loads[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Load: ${load.loadNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1E6B24)),
                    ),
                  ),
                  Text(
                    'Lot: ${load.effectiveLotNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    DateFormatter.format(load.arrivalDate),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${load.commodity} (${load.varietyGrade})',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${load.totalBags} BG',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)),
                  ),
                ],
              ),
              if (load.vehicleNumber.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Lorry / Vehicle: ${load.vehicleNumber}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    'Sold: ${load.soldBags.toStringAsFixed(0)} BG | Unsold: ${load.unsoldBags.toStringAsFixed(0)} BG',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: load.unsoldBags > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      context.push('/bills/new?lotNumber=${load.effectiveLotNumber}&sellerId=${load.sellerId}');
                    },
                    child: const Text('Auction / Bill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 2: Linked Bills
  Widget _buildBillsTab(List<Bill> bills) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            const Text('No wholesale auction bills linked to this seller yet.', style: TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Bill from Seller Lot'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
              onPressed: () => context.push('/bills/new?sellerId=${widget.sellerId}'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: bills.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = bills[index];
        return InkWell(
          onTap: () => context.push('/bills/${b.id}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.billNumber,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.format(b.billDate),
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    if (b.items.isNotEmpty)
                      Text(
                        b.items.first.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF1E6B24), fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(b.currentBillTotal),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: b.remainingBalance <= 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        b.statusLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: b.remainingBalance <= 0 ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 3: Farmer Advances
  Widget _buildAdvancesTab(List<SellerLoad> loads, double totalAdvances) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Advances Paid to Farmer', style: TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w600)),
                  Text(
                    CurrencyFormatter.format(totalAdvances),
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                  ),
                ],
              ),
              const Icon(Icons.payments_rounded, color: Color(0xFFD97706), size: 36),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Load Advance History', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        ...loads.map((l) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Load: ${l.loadNumber} • ${l.commodity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(DateFormatter.format(l.arrivalDate), style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  ],
                ),
                Text(
                  CurrencyFormatter.format(l.advancePaidToSeller),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFD97706)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // TAB 4: Farmer Ledger
  Widget _buildLedgerTab(List<SellerLoad> loads, List<Bill> bills, double totalAdvances, double estimatedPayable) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Produce Sold Value', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(CurrencyFormatter.format(bills.fold(0.0, (s, b) => s + b.currentBillTotal)), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Commission Deducted (5%)', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    Text('- ${CurrencyFormatter.format(bills.fold(0.0, (s, b) => s + b.currentBillTotal) * 0.05)}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Advances Disbursed', style: TextStyle(fontSize: 13, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                    Text('- ${CurrencyFormatter.format(totalAdvances)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estimated Balance Payable to Farmer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                    Text(
                      CurrencyFormatter.format(estimatedPayable > 0 ? estimatedPayable : 0.0),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: estimatedPayable > 0 ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
