import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';
import '../../data/models/seller_load.dart';

class TransportoScreen extends ConsumerStatefulWidget {
  const TransportoScreen({super.key});

  @override
  ConsumerState<TransportoScreen> createState() => _TransportoScreenState();
}

class _TransportoScreenState extends ConsumerState<TransportoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellerLoads = ref.watch(sellerLoadsProvider);

    // Active lorries
    final vehicleLoads = sellerLoads.where((l) => l.vehicleNumber.isNotEmpty).toList();
    final totalTrucks = vehicleLoads.length;
    final totalBagsInTransit = vehicleLoads.fold(0, (s, l) => s + l.totalBags);

    final filteredLoads = vehicleLoads.where((l) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return l.vehicleNumber.toLowerCase().contains(q) ||
          l.sellerName.toLowerCase().contains(q) ||
          l.village.toLowerCase().contains(q) ||
          l.loadNumber.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transporto (Logistics)',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            Text(
              'Lorries, Drivers & Mandi Gate Movement',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined, color: Color(0xFF1E6B24)),
            tooltip: 'Add Inward Truck',
            onPressed: () => context.push('/seller-loads'),
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
          tabs: [
            Tab(text: 'Inward Lorries (${filteredLoads.length})'),
            const Tab(text: 'Transporter Directory'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'transporto_screen_fab',
        backgroundColor: const Color(0xFF1E6B24),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road),
        label: const Text('Add Inward Lorry', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => context.push('/seller-loads'),
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
                      'Arrival Trucks',
                      '$totalTrucks Lorries',
                      Icons.local_shipping,
                      const Color(0xFF1E6B24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Total Bags',
                      '$totalBagsInTransit BG',
                      Icons.all_inbox_outlined,
                      const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Gate Status',
                      'Platform #2 Active',
                      Icons.warehouse_outlined,
                      const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // Search Box
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            color: Colors.white,
            child: ResponsiveContainer(
              maxWidth: 960,
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search by Vehicle / Lorry No / Route / Farmer...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),

          // Tab Views
          Expanded(
            child: ResponsiveContainer(
              maxWidth: 960,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLorriesList(filteredLoads),
                  _buildTransportersDirectory(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLorriesList(List<SellerLoad> loads) {
    if (loads.isEmpty) {
      return const Center(child: Text('No inward lorries found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: loads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final load = loads[index];
        final bayStatus = index == 0 ? 'Weighbridge Completed' : (index == 1 ? 'Unloading Platform #1' : 'Gate Clearance Done');

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_shipping, color: Color(0xFF1E6B24), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            load.vehicleNumber,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'Load: ${load.loadNumber} • Lot: ${load.effectiveLotNumber}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bayStatus,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Farmer: ${load.sellerName}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF334155)),
                      ),
                      Text(
                        'Route: ${load.village}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${load.totalBags} Bags (${load.commodity})',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Weight: ${load.grossWeight.toStringAsFixed(0)} kg',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.phone_outlined, size: 16),
                      label: const Text('Call Driver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling Driver for ${load.vehicleNumber}: ${load.phone}')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Gate Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gate Pass shared for ${load.vehicleNumber}')),
                        );
                      },
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

  Widget _buildTransportersDirectory() {
    final transporters = [
      {'name': 'Kongu Agri Freight Services', 'contact': 'P. Marimuthu (98421 99120)', 'routes': 'Salem - Namakkal - Tiruppur', 'trucks': '12 Trucks'},
      {'name': 'Cauvery Lorry Movers', 'contact': 'S. Subramani (94432 55410)', 'routes': 'Erode - Bhavani - Dharapuram', 'trucks': '8 Trucks'},
      {'name': 'Thennampalayam Local Auto Association', 'contact': 'M. Karthik (98650 44321)', 'routes': 'Local Mandi Intra-City Delivery', 'trucks': '25 Pickups'},
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: transporters.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = transporters[index];
        return Container(
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
                  child: Icon(Icons.local_shipping_outlined, color: Color(0xFF1E6B24), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    Text(t['contact']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    Text('Route: ${t['routes']!}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(t['trucks']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
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
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
