import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../core/formatters/date_formatter.dart';
import '../../core/responsive/responsive_container.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/app_state.dart';
import '../../data/models/bill.dart';
import '../../data/models/customer.dart';

class BillsListScreen extends ConsumerStatefulWidget {
  const BillsListScreen({super.key});

  @override
  ConsumerState<BillsListScreen> createState() => _BillsListScreenState();
}

class _BillsListScreenState extends ConsumerState<BillsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Paid', 'Partially Paid', 'Unpaid', 'Cancelled'

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
    final bills = ref.watch(billsProvider);
    final customers = ref.watch(customersProvider);
    final buyers = customers.where((c) => c.customerType != CustomerType.seller).toList();

    final filteredBills = bills.where((b) {
      final cust = customers.cast<Customer?>().firstWhere(
        (c) => c?.id == b.customerId,
        orElse: () => null,
      );
      final custName = cust?.name.toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          b.billNumber.toLowerCase().contains(q) ||
          custName.contains(q);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Paid') return b.status == BillStatus.paid;
      if (_selectedFilter == 'Partially Paid') return b.status == BillStatus.partiallyPaid;
      if (_selectedFilter == 'Unpaid') return b.status == BillStatus.unpaid;
      if (_selectedFilter == 'Cancelled') return b.status == BillStatus.cancelled;
      return true;
    }).toList();

    final filteredBuyers = buyers.where((buyer) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return buyer.name.toLowerCase().contains(q) ||
          buyer.phone.toLowerCase().contains(q) ||
          buyer.village.toLowerCase().contains(q) ||
          buyer.notes.toLowerCase().contains(q);
    }).toList();

    // Financial KPIs
    final totalSales = bills.where((b) => b.status != BillStatus.cancelled).fold(0.0, (s, b) => s + b.currentBillTotal);
    final totalReceived = bills.where((b) => b.status != BillStatus.cancelled).fold(0.0, (s, b) => s + b.totalPaymentsApplied);
    final totalDue = totalSales - totalReceived;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Buy Bill Book (Buyer Invoices & Accounts)',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined, color: Color(0xFF1E6B24)),
            tooltip: 'Add Bill',
            onPressed: () => context.push('/bills/new'),
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
            Tab(text: 'Buyer Invoices (${bills.length})'),
            Tab(text: 'Buyer Accounts (${buyers.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bills_list_fab',
        backgroundColor: const Color(0xFF1E6B24),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Bill', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => context.push('/bills/new'),
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
                      'Total Billed',
                      CurrencyFormatter.format(totalSales),
                      Icons.receipt_long_outlined,
                      const Color(0xFF1E6B24),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Total Collected',
                      CurrencyFormatter.format(totalReceived),
                      Icons.check_circle_outline,
                      const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildKpiCard(
                      'Buyer Balance Due',
                      CurrencyFormatter.format(totalDue > 0 ? totalDue : 0.0),
                      Icons.account_balance_wallet_outlined,
                      const Color(0xFFDC2626),
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
                        hintText: 'Search by Name / Mobile / Short Code / Bill No...',
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
                        _buildFilterPill('All (${bills.length})', 'All'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Unpaid', 'Unpaid'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Partially Paid', 'Partially Paid'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Paid', 'Paid'),
                        const SizedBox(width: 8),
                        _buildFilterPill('Cancelled', 'Cancelled'),
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
                // TAB 1: Buyer Invoices
                _buildInvoicesList(filteredBills, customers),

                // TAB 2: Buyer Accounts
                _buildBuyersList(filteredBuyers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Invoices List
  Widget _buildInvoicesList(List<Bill> bills, List<Customer> customers) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 52, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isEmpty ? 'No invoices found' : 'No bills matching "$_searchQuery"',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E6B24), foregroundColor: Colors.white),
              icon: const Icon(Icons.add),
              label: const Text('Add Bill'),
              onPressed: () => context.push('/bills/new'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: bills.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = bills[index];
        final customer = customers.cast<Customer?>().firstWhere(
          (c) => c?.id == b.customerId,
          orElse: () => null,
        );

        return InkWell(
          onTap: () => context.push('/bills/${b.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Green Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.receipt_long_rounded, color: Color(0xFF1E6B24), size: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Bill details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            b.billNumber,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.fromBillStatus(b.statusLabel),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer?.name ?? 'Wholesale Buyer',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                      ),
                      Text(
                        '${DateFormatter.format(b.billDate)} • ${b.items.isNotEmpty ? b.items.first.description : ""}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(b.currentBillTotal),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF0F172A)),
                    ),
                    if (b.remainingBalance > 0 && b.status != BillStatus.cancelled) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Due: ${CurrencyFormatter.format(b.remainingBalance)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                      ),
                    ],
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBD5E1)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 2: Buyer Accounts matching Photo 2
  Widget _buildBuyersList(List<Customer> buyers) {
    if (buyers.isEmpty) {
      return const Center(child: Text('No buyers found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      itemCount: buyers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final buyer = buyers[index];
        final balance = ref.watch(customerBalanceProvider(buyer.id));

        return InkWell(
          onTap: () => context.push('/customers/${buyer.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Green Circle Silhouette Avatar matching Photo 2
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

                // Name & Subtitle matching Photo 2
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buyer.name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        buyer.notes.isNotEmpty ? buyer.notes : 'Buyer - ${buyer.phone}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      if (buyer.village.isNotEmpty)
                        Text(
                          buyer.village,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                ),

                // Balance & History Link
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance > 0 ? 'Due: ${CurrencyFormatter.format(balance)}' : 'Settled',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: balance > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Ledger', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
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
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
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
