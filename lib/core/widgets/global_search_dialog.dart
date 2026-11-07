import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/formatters/currency_formatter.dart';
import '../../data/app_state.dart';
import '../../data/models/customer.dart';
import '../localization/language_provider.dart';

class GlobalSearchDialog extends ConsumerStatefulWidget {
  const GlobalSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const GlobalSearchDialog(),
    );
  }

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    final bills = ref.watch(billsProvider);
    final customers = ref.watch(customersProvider);

    final cleanQuery = _query.trim().toLowerCase();

    // Filter Lots
    final matchingLoads = sellerLoads.where((l) {
      if (cleanQuery.isEmpty) return true;
      return l.loadNumber.toLowerCase().contains(cleanQuery) ||
          l.effectiveLotNumber.toLowerCase().contains(cleanQuery) ||
          l.sellerName.toLowerCase().contains(cleanQuery) ||
          l.vehicleNumber.toLowerCase().contains(cleanQuery) ||
          l.commodity.toLowerCase().contains(cleanQuery);
    }).toList();

    // Filter Bills
    final matchingBills = bills.where((b) {
      if (cleanQuery.isEmpty) return true;
      final cust = customers.cast<Customer?>().firstWhere((c) => c?.id == b.customerId, orElse: () => null);
      final custName = cust?.name.toLowerCase() ?? '';
      return b.billNumber.toLowerCase().contains(cleanQuery) ||
          custName.contains(cleanQuery) ||
          b.items.any((i) => i.description.toLowerCase().contains(cleanQuery));
    }).toList();

    // Filter Buyers
    final matchingBuyers = customers.where((c) {
      if (c.customerType == CustomerType.seller) return false;
      if (cleanQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(cleanQuery) ||
          c.phone.contains(cleanQuery) ||
          c.village.toLowerCase().contains(cleanQuery);
    }).toList();

    // Filter Farmers
    final matchingFarmers = customers.where((c) {
      if (c.customerType == CustomerType.buyer) return false;
      if (cleanQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(cleanQuery) ||
          c.phone.contains(cleanQuery) ||
          c.village.toLowerCase().contains(cleanQuery);
    }).toList();

    final allCount = matchingLoads.length + matchingBills.length + matchingBuyers.length + matchingFarmers.length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 680),
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: (val) => setState(() => _query = val),
                      decoration: InputDecoration(
                        hintText: ref.tr('globalSearchHint'),
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primaryGreenDark,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: AppColors.primaryGreen,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: [
                Tab(text: '${ref.tr('allEntities')} ($allCount)'),
                Tab(text: '${ref.tr('lots')} (${matchingLoads.length})'),
                Tab(text: '${ref.tr('bills')} (${matchingBills.length})'),
                Tab(text: '${ref.tr('buyers')} (${matchingBuyers.length})'),
                Tab(text: '${ref.tr('sellers')} (${matchingFarmers.length})'),
              ],
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

            // Search Results
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: All
                  _buildAllView(context, matchingLoads, matchingBills, matchingBuyers, matchingFarmers),
                  // Tab 1: Lots
                  _buildLotsList(context, matchingLoads),
                  // Tab 2: Bills
                  _buildBillsList(context, matchingBills, customers),
                  // Tab 3: Buyers
                  _buildCustomersList(context, matchingBuyers, isBuyer: true),
                  // Tab 4: Farmers
                  _buildCustomersList(context, matchingFarmers, isBuyer: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllView(
    BuildContext context,
    List matchingLoads,
    List matchingBills,
    List matchingBuyers,
    List matchingFarmers,
  ) {
    if (matchingLoads.isEmpty && matchingBills.isEmpty && matchingBuyers.isEmpty && matchingFarmers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
              SizedBox(height: 8),
              Text('No matching records found', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      children: [
        if (matchingLoads.isNotEmpty) ...[
          _buildCategoryHeader('Auction Lots (${matchingLoads.length})', Icons.description_outlined),
          ...matchingLoads.take(3).map((l) => _buildLotCard(context, l)),
          const SizedBox(height: 10),
        ],
        if (matchingBills.isNotEmpty) ...[
          _buildCategoryHeader('Invoices & Bills (${matchingBills.length})', Icons.receipt_long_outlined),
          ...matchingBills.take(3).map((b) => _buildBillCard(context, b)),
          const SizedBox(height: 10),
        ],
        if (matchingBuyers.isNotEmpty) ...[
          _buildCategoryHeader('Wholesale Buyers (${matchingBuyers.length})', Icons.store_outlined),
          ...matchingBuyers.take(3).map((c) => _buildCustomerCard(context, c, true)),
          const SizedBox(height: 10),
        ],
        if (matchingFarmers.isNotEmpty) ...[
          _buildCategoryHeader('Farmers & Suppliers (${matchingFarmers.length})', Icons.eco_outlined),
          ...matchingFarmers.take(3).map((c) => _buildCustomerCard(context, c, false)),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF475569), letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLotsList(BuildContext context, List loads) {
    if (loads.isEmpty) return _buildEmptyPlaceholder();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: loads.length,
      itemBuilder: (ctx, i) => _buildLotCard(context, loads[i]),
    );
  }

  Widget _buildBillsList(BuildContext context, List bills, List<Customer> customers) {
    if (bills.isEmpty) return _buildEmptyPlaceholder();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: bills.length,
      itemBuilder: (ctx, i) => _buildBillCard(context, bills[i]),
    );
  }

  Widget _buildCustomersList(BuildContext context, List customers, {required bool isBuyer}) {
    if (customers.isEmpty) return _buildEmptyPlaceholder();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: customers.length,
      itemBuilder: (ctx, i) => _buildCustomerCard(context, customers[i], isBuyer),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return const Center(
      child: Text('No results in this category', style: TextStyle(color: Color(0xFF64748B))),
    );
  }

  Widget _buildLotCard(BuildContext context, dynamic load) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGreenSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.local_shipping_outlined, color: AppColors.primaryGreen, size: 20),
        ),
        title: Row(
          children: [
            Text(load.effectiveLotNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(load.commodity, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        subtitle: Text(
          '${load.sellerName} • ${load.vehicleNumber} • ${load.unsoldBags.toInt()} unsold bags',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
        onTap: () {
          Navigator.pop(context);
          context.push('/sellers/${load.sellerId}');
        },
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, dynamic bill) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 20),
        ),
        title: Text(bill.billNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
        subtitle: Text(
          'Total: ${CurrencyFormatter.format(bill.currentBillTotal)} • Balance: ${CurrencyFormatter.format(bill.remainingBalance)}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
        onTap: () {
          Navigator.pop(context);
          context.push('/bills/${bill.id}');
        },
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, dynamic customer, bool isBuyer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isBuyer ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isBuyer ? Icons.storefront_rounded : Icons.agriculture_rounded,
            color: isBuyer ? const Color(0xFFD97706) : const Color(0xFF15803D),
            size: 20,
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
        subtitle: Text(
          '${customer.village} • ${customer.phone}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
        onTap: () {
          Navigator.pop(context);
          context.push('/customers/${customer.id}');
        },
      ),
    );
  }
}
