import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';
import '../../data/models/customer.dart';
import '../../data/models/seller_load.dart';
import 'create_seller_load_dialog.dart';

class SellerLoadsScreen extends ConsumerStatefulWidget {
  const SellerLoadsScreen({super.key});

  @override
  ConsumerState<SellerLoadsScreen> createState() => _SellerLoadsScreenState();
}

class _SellerLoadsScreenState extends ConsumerState<SellerLoadsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loads = ref.watch(sellerLoadsProvider);
    final customers = ref.watch(customersProvider);
    final sellers = customers.where((c) => c.customerType == CustomerType.seller || c.customerType == CustomerType.both).toList();

    final filteredLoads = loads.where((l) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          l.loadNumber.toLowerCase().contains(q) ||
          l.effectiveLotNumber.toLowerCase().contains(q) ||
          l.sellerName.toLowerCase().contains(q) ||
          l.village.toLowerCase().contains(q) ||
          l.vehicleNumber.toLowerCase().contains(q) ||
          l.commodity.toLowerCase().contains(q);

      if (!matchesSearch) return false;

      if (_statusFilter == 'Arrived') return l.status == SellerLoadStatus.arrived;
      if (_statusFilter == 'Partially Sold') return l.status == SellerLoadStatus.partiallySold;
      if (_statusFilter == 'Settled') return l.status == SellerLoadStatus.completed;

      return true;
    }).toList();

    final totalActiveLoads = loads.where((l) => l.status != SellerLoadStatus.completed).length;
    final totalBags = loads.fold(0, (sum, l) => sum + l.totalBags);
    final totalAdvances = loads.fold(0.0, (sum, l) => sum + l.advancePaidToSeller);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Sell Bill Book (Farmer & Inward Loads)',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF1E6B24)),
            tooltip: 'New Seller Load',
            onPressed: () => CreateSellerLoadDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E6B24),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          indicatorColor: const Color(0xFF1E6B24),
          indicatorWeight: 3.5,
          tabs: [
            Tab(text: 'Inward Loads & Lots (${loads.length})'),
            Tab(text: 'Farmer Profiles (${sellers.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'seller_loads_fab',
        backgroundColor: const Color(0xFF1E6B24),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Create Seller Load', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => CreateSellerLoadDialog.show(context),
      ),
      body: Column(
        children: [
          // KPI Metric Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: ResponsiveContainer(
              maxWidth: 960,
              child: Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      'Active Loads',
                      '$totalActiveLoads Loads',
                      Icons.local_shipping_outlined,
                      const Color(0xFF1E6B24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Arrived Bags',
                      '$totalBags BG',
                      Icons.all_inbox_outlined,
                      const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Farmer Advances',
                      CurrencyFormatter.format(totalAdvances),
                      Icons.payments_outlined,
                      const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            color: Colors.white,
            child: ResponsiveContainer(
              maxWidth: 960,
              child: Column(
                children: [
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search Farmer Name, Load No, Vehicle, Commodity...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
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
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('All (${loads.length})', 'All'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Arrived', 'Arrived'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Partially Sold', 'Partially Sold'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Settled', 'Settled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Inward Lots & Loads
                _buildInwardLoadsList(filteredLoads),

                // TAB 2: Farmer Profiles
                _buildFarmerProfilesList(sellers, loads),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Inward Loads & Lots
  Widget _buildInwardLoadsList(List<SellerLoad> loads) {
    if (loads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 52, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isEmpty ? 'No seller loads recorded yet' : 'No loads matching "$_searchQuery"',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E6B24), foregroundColor: Colors.white),
              icon: const Icon(Icons.add),
              label: const Text('Create First Load'),
              onPressed: () => CreateSellerLoadDialog.show(context),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: loads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final load = loads[index];
        return _buildSellerLoadCard(load);
      },
    );
  }

  Widget _buildSellerLoadCard(SellerLoad load) {
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
          // Header: Farmer Avatar, Name, Code, Phone, Load & Lot badges
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                InkWell(
                  onTap: () => context.push('/sellers/${load.sellerId}'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Color(0xFF16A34A), size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Code
                Expanded(
                  child: InkWell(
                    onTap: () => context.push('/sellers/${load.sellerId}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          load.sellerName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Farmer - ${load.farmerCode} | ${load.maskedPhone}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        if (load.vehicleNumber.isNotEmpty)
                          Text(
                            'Vehicle: ${load.vehicleNumber}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),

                // Load No & Lot No Chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6B24),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Load: ${load.loadNumber}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lot: ${load.effectiveLotNumber}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                    ),
                    Text(
                      DateFormatter.format(load.arrivalDate),
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Produce Box matching Mandi UI: Commodity, Bags Sold/Unsold, Advances
          Container(
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${load.commodity} (${load.varietyGrade})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (load.advancePaidToSeller > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Advance: ${CurrencyFormatter.format(load.advancePaidToSeller)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Total: ${load.totalBags} BG',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                    ),
                    Text(
                      'Unsold: ${load.unsoldBags.toStringAsFixed(0)} BG',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                    ),
                    Text(
                      'Sold: ${load.soldBags.toStringAsFixed(0)} BG',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Action Buttons: View Full History & Auction / Trade
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        onPressed: () => context.push('/sellers/${load.sellerId}'),
                        child: const Text('History', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          context.push('/bills/new?lotNumber=${load.effectiveLotNumber}&sellerId=${load.sellerId}');
                        },
                        child: const Text('Auction / Bill', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
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

  // TAB 2: Farmer Profiles
  Widget _buildFarmerProfilesList(List<Customer> sellers, List<SellerLoad> loads) {
    if (sellers.isEmpty) {
      return const Center(child: Text('No farmer profiles found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: sellers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final farmer = sellers[index];
        final farmerLoads = loads.where((l) => l.sellerId == farmer.id || l.sellerName == farmer.name).toList();
        final totalFarmerBags = farmerLoads.fold(0, (sum, l) => sum + l.totalBags);
        final totalFarmerAdvances = farmerLoads.fold(0.0, (sum, l) => sum + l.advancePaidToSeller);

        return InkWell(
          onTap: () => context.push('/sellers/${farmer.id}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Color(0xFF16A34A), size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        farmer.notes.isNotEmpty ? farmer.notes : 'Phone: ${farmer.phone}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                      if (farmer.village.isNotEmpty)
                        Text(farmer.village, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${farmerLoads.length} Loads ($totalFarmerBags BG)',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF1E6B24)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Adv: ${CurrencyFormatter.format(totalFarmerAdvances)}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View History', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                        Icon(Icons.chevron_right, size: 14, color: Color(0xFF2563EB)),
                      ],
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

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildFilterPill(String label, String filterKey) {
    final isSelected = _statusFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E6B24) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF1E6B24) : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
