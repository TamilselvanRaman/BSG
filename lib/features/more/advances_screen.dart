import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../data/app_state.dart';
import '../../data/models/payment.dart';
import '../../data/models/seller_load.dart';

class AdvancesScreen extends ConsumerStatefulWidget {
  const AdvancesScreen({super.key});

  @override
  ConsumerState<AdvancesScreen> createState() => _AdvancesScreenState();
}

class _AdvancesScreenState extends ConsumerState<AdvancesScreen> with SingleTickerProviderStateMixin {
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
    final payments = ref.watch(paymentsProvider);
    final customers = ref.watch(customersProvider);

    // Farmer advances from inward loads
    final farmerAdvancesLoads = sellerLoads.where((l) => l.advancePaidToSeller > 0).toList();
    final totalFarmerAdvances = farmerAdvancesLoads.fold(0.0, (s, l) => s + l.advancePaidToSeller);

    // Buyer initial advances/deposits from payments
    final buyerAdvances = payments.where((p) => p.paymentType == PaymentType.initialAdvance).toList();
    final totalBuyerAdvances = buyerAdvances.fold(0.0, (s, p) => s + p.amount);

    final filteredLoads = farmerAdvancesLoads.where((l) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return l.sellerName.toLowerCase().contains(q) ||
          l.loadNumber.toLowerCase().contains(q) ||
          l.effectiveLotNumber.toLowerCase().contains(q) ||
          l.vehicleNumber.toLowerCase().contains(q);
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
              'Advances Register',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            Text(
              'Farmer Inward Advances & Buyer Deposits',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E6B24)),
            tooltip: 'Record Advance',
            onPressed: () => _showRecordAdvanceModal(context),
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
            Tab(text: 'Farmer Inward (${filteredLoads.length})'),
            Tab(text: 'Buyer Deposits (${buyerAdvances.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'advances_screen_fab',
        backgroundColor: const Color(0xFF1E6B24),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.payments_outlined),
        label: const Text('Record Advance', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => _showRecordAdvanceModal(context),
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
                      'Farmer Advances',
                      CurrencyFormatter.format(totalFarmerAdvances),
                      Icons.arrow_upward_rounded,
                      const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Buyer Deposits',
                      CurrencyFormatter.format(totalBuyerAdvances),
                      Icons.arrow_downward_rounded,
                      const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Net Outflow',
                      CurrencyFormatter.format(totalFarmerAdvances - totalBuyerAdvances),
                      Icons.savings_outlined,
                      const Color(0xFF2563EB),
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
                  hintText: 'Search by Farmer / Buyer / Load / Vehicle...',
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
                  _buildFarmerAdvancesList(filteredLoads),
                  _buildBuyerAdvancesList(buyerAdvances, customers),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerAdvancesList(List<SellerLoad> loads) {
    if (loads.isEmpty) {
      return const Center(child: Text('No farmer advances found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: loads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final load = loads[index];
        return InkWell(
          onTap: () => context.push('/sellers/${load.sellerId}'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Load: ${load.loadNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFFB45309)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lot: ${load.effectiveLotNumber}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                    Text(
                      DateFormatter.format(load.arrivalDate),
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            load.sellerName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'Farmer Code: ${load.farmerCode} • ${load.vehicleNumber}',
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.format(load.advancePaidToSeller),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFD97706)),
                        ),
                        const Text(
                          'Advance Paid',
                          style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
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

  Widget _buildBuyerAdvancesList(List<Payment> list, List customers) {
    if (list.isEmpty) {
      return const Center(child: Text('No buyer advance deposits recorded.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = list[index];
        final customer = customers.cast().firstWhere((c) => c.id == p.customerId, orElse: () => null);

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
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.arrow_downward, color: Color(0xFF16A34A), size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.name ?? 'Wholesale Buyer',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      '${DateFormatter.format(p.paymentDate)} • Mode: ${p.paymentMode}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(p.amount),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF16A34A)),
                  ),
                  const Text(
                    'Security Deposit',
                    style: TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.w700),
                  ),
                ],
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

  void _showRecordAdvanceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Record Mandi Advance', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 6),
              const Text('Disburse farmer load advance or record buyer deposit', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFFEF3C7), child: Icon(Icons.payments, color: Color(0xFFD97706))),
                title: const Text('Disburse Farmer Load Advance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                subtitle: const Text('Attach cash advance to incoming arrival load'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/seller-loads');
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFDCFCE7), child: Icon(Icons.account_balance_wallet, color: Color(0xFF16A34A))),
                title: const Text('Receive Buyer Deposit / Advance', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                subtitle: const Text('Record payment receipt from wholesale buyer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/payments/new');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
